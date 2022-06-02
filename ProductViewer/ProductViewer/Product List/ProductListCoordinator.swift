//
//  ProductListCoordinator.swift
//  ProductViewer
//
//  Created by Vignesh Radhakrishnan on 10/03/21.
//

import UIKit

final class ProductListCoordinator {
    
    var navigationController:UINavigationController!
    
    func getProductListController() ->UINavigationController {
        let vc = ProductListViewController.prepareVC(withDependency : ProductDependency())
        vc.listViewControllerDelegate = self
        self.navigationController = UINavigationController(rootViewController: vc)
        return self.navigationController
    }
}
extension ProductListCoordinator : ProductListViewControllerDelegate {
    
    
    func showCartScreen() {
        let vc = CartViewController.prepareVC(withDependency : CardDependency(dataProvider: CoreDataProvider.sharedInstance))
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        navigationController.present(nav, animated: true, completion: nil)
    }
    
    func didChooseProduct(productID: String) {
        let vc = ProductDetailViewController.prepareVC(withDependency : ProductDependency(productID: productID))
        return self.navigationController.pushViewController(vc, animated: true)
    }
}
extension ProductListCoordinator : CartListViewControllerDelegate {
    func didChooseProductFromCart(productID: String,nav : UINavigationController) {
        let vc = ProductDetailViewController.prepareVC(withDependency : ProductDependency(productID: productID))
        return nav.pushViewController(vc, animated: true)
    }
}
