//
//  HomeViewModel.swift
//  IOS-Challenge
//
//  Created by Nhat on 12/14/24.
//

import Foundation
import RxSwift
import RxCocoa

protocol HomeViewModelprotocol: AnyObject {
    var fetchTrigger: PublishRelay<Void> { get }
    var refreshTrigger: PublishRelay<Void> { get }
    var loadMoreTrigger: PublishRelay<Void> { get }
    var searchTrigger: PublishRelay<String> { get }
    var dataSource: Observable<[ItemImageModelSection]> { get }
    var isLoading: Observable<Bool> { get }
    var error: Observable<Error> { get }
    
    func getItem(at index: Int) -> ItemImageModel?
    func getSearchText() -> String
    func getNumberOfItems() -> Int
}

final class HomeViewModel: HomeViewModelprotocol {
    // MARK: - Public Properties
    // like PublishSubject but nerver emit completed and error
    let fetchTrigger: PublishRelay<Void> = PublishRelay<Void>()
    let refreshTrigger: PublishRelay<Void> = PublishRelay<Void>()
    let loadMoreTrigger: PublishRelay<Void> = PublishRelay<Void>()
    let searchTrigger: PublishRelay<String> = PublishRelay<String>()
    let dataSource: Observable<[ItemImageModelSection]>
    let isLoading: Observable<Bool>
    let error: Observable<Error>
    // MARK: - Private Properties
    // behaviorRelay
    // là một wrap của observable
    // không bao giờ phát ra lỗi hoặc completed
    // sẽ phát đi các giá trị cuối cùng của nó cho các subscirber khi đăng ký tới nó.
    private var originalItems: [ItemImageModel] = []
    private let filteredItemsRelay = BehaviorRelay<[ItemImageModel]>(value: [])
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<Error>()
    private let disposeBag = DisposeBag()
    // not save the old value, this is an observable and Observer at the same time
    private let searchSubject = PublishSubject<String>()
    
    var itemCount: Int {
        return 1
    }
    
    private var currentPage: Int = 1
    private var dataSourceSearch: [ItemImageModel] = []
    private var isFirstLoad: Bool = true
    
    private var searchWorkItem: DispatchWorkItem?
    private var searchQueue = DispatchQueue(label: "search.queue", qos: .userInitiated)
    private var searchText: String = ""
    
    init() {
        self.dataSource = filteredItemsRelay.map({ items in
            [ItemImageModelSection(header: "",
                                   items: items)]
        })
        self.isLoading = loadingRelay.asObservable()
        self.error = errorRelay.asObservable()
        setupBinding()
    }
    
    private func setupBinding() {
        bindSearch()
        bindDataFlows()
    }
    
    private func bindSearch() {
        searchTrigger
            .debounce(.milliseconds(1000), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] query in
                self?.searchText = query
                self?.filterItems(with: query)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindDataFlows() {
        // Initial fetch
        let fetchItems = fetchTrigger
            .do(onNext: { [weak self] _ in
                self?.loadingRelay.accept(true)
            })
            .flatMapLatest { [weak self] _ -> Observable<[ItemImageModel]> in
               guard let self = self else { return .just([]) }
                return self.fetchImages(page: 1)
            }
        
        // Pull to refresh
        let refreshItems = refreshTrigger
            .do(onNext: { [weak self] _ in
                self?.loadingRelay.accept(true)
            })
            .flatMapLatest { [weak self] _ -> Observable<[ItemImageModel]> in
               guard let self = self else { return .just([]) }
                self.currentPage = 1
                return self.fetchImages(page: 1)
            }
        
        // Load more
        let loadMoreItems = loadMoreTrigger
            .filter { [weak self] _ in
               guard let self = self else { return false }
                return !self.isFirstLoad && !self.loadingRelay.value
            }
            .do(onNext: { [weak self] _ in
                self?.loadingRelay.accept(true)
            })
            .flatMapLatest { [weak self] _ -> Observable<[ItemImageModel]> in
               guard let self = self else { return .just([]) }
                return self.fetchImages(page: self.currentPage + 1)
                    .do(onNext: { [weak self] _ in
                        self?.currentPage += 1
                    })
            }
        
        // Merge all flows
        Observable.merge(fetchItems, refreshItems, loadMoreItems)
            .subscribe(onNext: { [weak self] items in
                guard let self = self else { return }
                let isAppending = self.currentPage > 1
                self.handleFetchSuccess(items, isAppending: isAppending)
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchImages(page: Int) -> Observable<[ItemImageModel]> {
        NetworkService.shared.request(HomeAPIRouter.getImage(pageIndex: page, limit: 100))
            .catch { [weak self] error in
                self?.handleError(error)
                return .just([])
            }
    }
    
    private func handleFetchSuccess(_ response: [ItemImageModel], isAppending: Bool = false) {
        isFirstLoad = false
        loadingRelay.accept(false)
        
        if isAppending {
            originalItems += response
        } else {
            originalItems = response
        }
        
        filterItems(with: searchText)
    }
    
    private func handleError(_ error: Error) {
        errorRelay.accept(error)
        loadingRelay.accept(false)
        print("API call failed: \(error)")
    }
    
    private func filterItems(with query: String) {
        let filtered = query.isEmpty ? originalItems :
        originalItems.filter {
            ($0.author ?? "").contains(query) || ($0.id ?? "").contains(query)
        }
        filteredItemsRelay.accept(filtered)
    }
    
    func getItem(at index: Int) -> ItemImageModel? {
        return nil
    }
    
    func getSearchText() -> String {
        return searchText
    }
    
    func getNumberOfItems() -> Int {
        return filteredItemsRelay.value.count
    }
}


