//
//  HomeHomeViewController.swift
//  IOS-Challenge
//
//  Created by Nhat on 12/15/24.
//

import UIKit
import RxSwift
import RxDataSources
import RxCocoa

class HomeViewController: UIViewController {
    @IBOutlet weak var searchView: CommonSearchView!
    @IBOutlet weak var tableView: UITableView!
    
    let indicator = UIActivityIndicatorView(style: .large)
    private let viewModel: HomeViewModelprotocol
    private let refreshControl = UIRefreshControl()
    
    private let disposeBag = DisposeBag()
    private lazy var dataSource = RxTableViewSectionedReloadDataSource<ItemImageModelSection>(
        configureCell: { [weak self] (_ , tableView, indexPath, item) in
            guard let self = self else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageItemTableViewCell", for: indexPath) as! ImageItemTableViewCell
            if let url = URL(string: item.downloadURL ?? "") {
                if let cacheImage = ImageDownloadManager.shared.getCacheImage(with: item.downloadURL ?? "") {
                    cell.configCell(with: item, image: cacheImage)
                } else {
                    cell.configCell(with: item)
                    ImageDownloadManager.shared.downloadImage(with: url) { [weak self] uiImage in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            self.tableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                    }
                }
            }
            return cell
        }
    )
        
    init(viewModel: HomeViewModelprotocol) {
        self.viewModel = viewModel
        super.init(nibName: "HomeViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        setupSearchView()
        setupBinding()
        setupLoadmore()
        viewModel.fetchTrigger.accept(())
    }
    
    private func setupUI() {
        tableView.register(UINib(nibName: "ImageItemTableViewCell", bundle: nil), forCellReuseIdentifier: "ImageItemTableViewCell")
        tableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        indicator.center = view.center
        self.view.addSubview(indicator)
    }
    
    private func setupLoadmore() {
        tableView.rx.willDisplayCell
            .map { [weak self] cell, indexPath in
                guard let self = self else { return false }
                return indexPath.row == self.viewModel.getNumberOfItems() - 3
            }
            .distinctUntilChanged()
            .filter { $0 }
            .map { _ in
                return ()
            }
            .bind(to: self.viewModel.loadMoreTrigger)
            .disposed(by: disposeBag)
    }
    
    private func setupSearchView() {
        self.searchView.setTextfieldDelegate(self)
        self.searchView.applySwipeTyping()
        // thực hiện logic search và validate convert loại bỏ dấu khỏi string ở đây
        // ví dụ a->s-> á ( bởi vì shouldChangeCharactersIn sẽ có string mới là "as" nó không check có dấu được cho nên cần handle ở dây )
        self.searchView.handleTextDidChange = { [weak self] text in
            guard let self = self else { return }
            let pattern = "^[a-zA-Z0-9!@#$%^&*():.,<>/\\[\\]?]+$"
            let regex = try? NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: text.utf16.count)
            
            if text == "" {
                self.viewModel.searchTrigger.accept(text)
            } else if regex?.firstMatch(in: text, range: range) == nil {
                let newString = text.folding(options: .diacriticInsensitive, locale: .current)
                self.searchView.updateTextSearch(newString)
            } else {
                self.viewModel.searchTrigger.accept(text)
            }
        }
    }
    
    
    @objc
    private func handlePullToRefresh() {
        viewModel.refreshTrigger.accept(())
    }
    
    private func setupBinding() {
        viewModel.dataSource
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .asDriver(onErrorJustReturn: false)
            .drive { [weak self] isLoading in
                if isLoading {
                    self?.indicator.startAnimating()
                } else {
                    self?.indicator.stopAnimating()
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.error
            .asDriver(onErrorJustReturn: NSError())
            .drive { [weak self] error in
                print("nothing change here just some error")
            }
            .disposed(by: disposeBag)
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let data = viewModel.getItem(at: indexPath.row) {
            let width = CGFloat(data.width ?? 0)
            let height = CGFloat(data.height ?? 0)
            let ratio = height / width
            /// pading bottom cell là 8
            /// height của stackview chứa 2 label là 52
            return tableView.frame.width * ratio + 52 + 8
        }
        return 300
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}

extension HomeViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 15
        let currentText = textField.text ?? ""
        
        if string.isEmpty {
            return true
        }
        
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        if updatedText.count > maxLength {
            return false
        }
        // giới hạn ký tự hợp lệ được phép nhập
        let pattern = "^[a-zA-Z0-9!@#$%^&*():.,<>/\\[\\]?]+$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: updatedText.utf16.count)
        
        if regex?.firstMatch(in: updatedText, range: range) == nil {
            // nếu chuỗi này là chuỗi không hợp lệ
            // loại bỏ ký dấu khỏi chuỗi và update lại text, tiến hành validate lại text
            let newString = updatedText.folding(options: .diacriticInsensitive, locale: .current)
            textField.text = newString
        }
        return regex?.firstMatch(in: updatedText, range: range) != nil
    }
}
