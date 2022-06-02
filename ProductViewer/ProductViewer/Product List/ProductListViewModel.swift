//
//  ProductListViewModel.swift
//  ProductViewer
//
//  Created by Vignesh Radhakrishnan on 10/03/21.
//

import Foundation

protocol ListViewStateDelegate: class {
    func onStateChange(_ state: ListViewState)
}

enum ListViewState {
    case loading
    case requestSuccess
    case requestFailure(String)
    case networkFailure(String)
}

protocol ListViewModel {
    var delegate: ListViewStateDelegate? {get set}
    func numberOfSections() -> Int
    func numberOfItems(inSection index: Int) -> Int
    func getCellViewModel(atIndex index:Int, inSection sectionIndex: Int) -> ListCellViewModel
    func fetchItems()
    func numberOfItems() ->Int
    func deleteCart(indexPath : IndexPath,completion: @escaping (_ result:Result<Bool, Error>)->Void)
}
extension ListViewModel {
    func deleteCart(indexPath : IndexPath,completion: @escaping (_ result:Result<Bool, Error>)->Void) {}
}

final class ProductListViewModel : ListViewModel {
    
    var delegate: ListViewStateDelegate?
    private var products: [Product] = []
    typealias CellViewModel = ProductListCell.ViewModel
    private let service: ProductListService
    private var cellViewModels : [CellViewModel] = []
    
    init(withDependency dependency:ProductListDependency,service: ProductListService = ProductsService()) {
        self.service = service
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfItems(inSection index: Int) -> Int {
        return cellViewModels.count
    }
    
    func getCellViewModel(atIndex index:Int, inSection sectionIndex: Int) -> ListCellViewModel {
        return cellViewModels[index]
    }
    
    private func handleSuccess() {
        let viewModels = self.products.map { (product) -> CellViewModel in
            return CellViewModel(product: product)
        }
        self.cellViewModels = viewModels
    }
    
    func numberOfItems() ->Int {
        return cellViewModels.count
    }
    func fetchItems() {
        self.delegate?.onStateChange(.loading)
        service.getProducts { (result) in
            switch result {
            case .success(let products) :
                self.products = products
                self.handleSuccess()
                self.delegate?.onStateChange(.requestSuccess)
            case .failure(let error):
                switch error {
                case .urlLoadingError(let urlLoading):
                    if urlLoading == .notConnectedToInternet {
                        self.delegate?.onStateChange(.networkFailure(error.localizedDescription))
                    } else {
                        fallthrough
                    }
                default:
                    self.delegate?.onStateChange(.requestFailure(error.localizedDescription))
                }
            }
        }
    }
}
