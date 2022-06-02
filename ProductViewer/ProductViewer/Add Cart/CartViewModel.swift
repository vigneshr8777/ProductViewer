//
//  CartViewModel.swift
//  ProductViewer
//
//  Created by Vignesh Radhakrishnan on 11/03/21.
//

import Foundation

final class CartViewModel : ListViewModel {
    
    var delegate: ListViewStateDelegate?
    typealias CellViewModel = ProductListCell.ViewModel
    private var cellViewModels : [CellViewModel] = []
    private var dataProvider : DataProvider
    
    init(withDependency dependency:CardDependencyProtocol) {
        self.dataProvider = dependency.dataProvider
    }
    
    func fetchItems() {
       let products = self.dataProvider.fetchCartItems()
        let viewModels = products.map { (product) -> CellViewModel in
            return CellViewModel(product: product)
        }
        self.cellViewModels = viewModels
        self.delegate?.onStateChange(.requestSuccess)
    }
    
    func deleteCart(indexPath : IndexPath,completion: @escaping (_ result:Result<Bool, Error>)->Void) {
        if let productID = Int(self.cellViewModels[indexPath.row].ID) {
            self.dataProvider.deleteCart(productID: productID) { (result) in
                switch result {
                  
                case .success(_):
                    self.cellViewModels.remove(at: indexPath.row)
                    completion(.success(true))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
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
    func numberOfItems() ->Int {
        return cellViewModels.count
    }
    
}
