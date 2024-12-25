//
//  HomeViewModel.swift
//  IOS-Challenge
//
//  Created by Nhat on 12/14/24.
//

import Foundation

protocol HomeViewModelprotocol: AnyObject {
    var itemCount: Int { get }
    var onDataUpdated: (() -> Void)? { get set }
    var onUpdateIndicator: ((Bool) -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }
    func fetchData()
    func getItem(at index: Int) -> ItemImageModel?
    func loadMore()
    func pullToRefresh()
    func search(_ text: String)
    func getSearchText() -> String
}

final class HomeViewModel: HomeViewModelprotocol {
    var onDataUpdated: (() -> Void)?
    var onError: ((any Error) -> Void)?
    var onUpdateIndicator: ((Bool) -> Void)?
    var itemCount: Int {
        if dataSourceSearch.count > 0 {
            return dataSourceSearch.count
        } else {
            return dataSource.count
        }
    }

    private var currentPage: Int = 1
    private var dataSource: [ItemImageModel]
    private var dataSourceSearch: [ItemImageModel] = []
    private var isFirstLoad: Bool = true
    
    private var searchWorkItem: DispatchWorkItem?
    private var searchQueue = DispatchQueue(label: "search.queue", qos: .userInitiated)
    private var searchText: String = ""
    
    init(dataSource: [ItemImageModel] = []) {
        self.dataSource = dataSource
    }
    
    func fetchData() {
        self.onUpdateIndicator?(true)
        NetworkService.shared.request(HomeAPIRouter.getImage(pageIndex: self.currentPage, limit: 100),
                                      responseType: [ItemImageModel].self) { [weak self] result in
            guard let self else { return }
            isFirstLoad = false
            self.onUpdateIndicator?(false)
            switch result {
            case .success(let data):
                self.dataSource = data
                self.dataSourceSearch = self.dataSource.filter({($0.author ?? "").contains(self.searchText) || ($0.id ?? "").contains(self.searchText)})
                self.onDataUpdated?()
            case .failure(let failure):
                print("nhatlun: call API fail rồi kìa : \(failure)")
                self.onError?(failure)
            }
        }
    }
    
    func loadMore() {
        if !isFirstLoad {
            self.onUpdateIndicator?(true)
            NetworkService.shared.request(HomeAPIRouter.getImage(pageIndex: self.currentPage + 1, limit: 100),
                                          responseType: [ItemImageModel].self) { [weak self] result in
                guard let self = self else { return }
                self.onUpdateIndicator?(false)
                switch result {
                case .success(let data):
                    self.currentPage += 1
                    self.dataSource.append(contentsOf: data)
                    self.dataSourceSearch = self.dataSource.filter({($0.author ?? "").contains(self.searchText) || ($0.id ?? "").contains(self.searchText)})
                    self.onDataUpdated?()
                case .failure(let failure):
                    print("nhatlun: call API fail rồi kìa : \(failure)")
                    self.onError?(failure)
                }
            }
        }
    }
    
    func pullToRefresh() {
        NetworkService.shared.request(HomeAPIRouter.getImage(pageIndex: 1, limit: 100),
                                      responseType: [ItemImageModel].self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.currentPage = 1
                self.dataSource = data
                self.dataSourceSearch = data.filter({($0.author ?? "").contains(self.searchText) || ($0.id ?? "").contains(self.searchText)})
                self.onDataUpdated?()
            case .failure(let failure):
                print("nhatlun: call API fail rồi kìa : \(failure)")
                self.onError?(failure)
            }
        }
    }
    
    func search(_ text: String) {
        self.searchText = text
        self.searchWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.onUpdateIndicator?(true)
            self.dataSourceSearch = self.dataSource.filter({($0.author ?? "").contains(text)})
            self.onDataUpdated?()
        }
        
        self.searchWorkItem = workItem
        searchQueue.asyncAfter(deadline: .now() + 2.0, execute: workItem)
    }
    
    func getItem(at index: Int) -> ItemImageModel? {
        if dataSourceSearch.count > 0 {
            guard index < dataSourceSearch.count else { return nil }
            return dataSourceSearch[index]
        } else {
            guard index < dataSource.count else { return nil }
            return dataSource[index]
        }
    }
    
    func getSearchText() -> String {
        return searchText
    }
}


