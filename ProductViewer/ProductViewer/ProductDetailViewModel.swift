//
//  ProductDetailViewModel.swift
//  ProductViewer
//
//  Created by Vignesh Radhakrishnan on 10/03/21.
//

import Foundation

protocol DetailViewStateDelegate: class {
    func onStateChange(_ state: DetailViewState)
}

enum DetailViewState {
    case loading
    case requestSuccess
    case requestFailure(String)
    case networkFailure(String)
}

struct ProductDetailContentViewModel {
    let imageURL : String
    let productDescription : String
    let price : String
    let title : String
}

final class ProductDetailViewModel {
    
    private let service: ProductDetailsService
    private let productID : String
    private var product : Product?
    var delegate: DetailViewStateDelegate?
    var detailContentViewModel : ProductDetailContentViewModel?
    
    init(withDependency dependency:ProductDetailDependency,service: ProductDetailsService = ProductsService()) {
        self.productID = dependency.productID
        self.service = service
    }
    func addToCart(completion: @escaping (_ result:Result<String, Error>)->Void) {
        if let product = product {
            CoreDataProvider.sharedInstance.addToCart(product: product, completion: completion)
        }
    }
    
    func fetchProductDetail() {
        self.delegate?.onStateChange(.loading)
        self.service.getProductDetail(id: productID) { (result) in
            switch result {
            case .success(let product):
                self.product = product
                self.detailContentViewModel = ProductDetailContentViewModel(imageURL: product.imageURL, productDescription: product.productDescription, price:  product.regularPrice.displayString, title: self.product?.title ?? "")
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
