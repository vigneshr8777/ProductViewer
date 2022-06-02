//
//  ProductListService.swift
//  ProductViewer
//
//  Created by Vignesh Radhakrishnan on 10/03/21.
//

import Foundation

protocol ProductListService {
    func getProducts(completion: @escaping ((Result<[Product], Error>) -> Void))
}
protocol ProductDetailsService {
    func getProductDetail(id : String,completion: @escaping ((Result<Product, Error>) -> Void))
}
final class ProductsService:ProductListService,ProductDetailsService {
    
    private let api: ProductsAPI
    
    init(api: ProductsAPI = ProductsAPIManager()) {
        self.api = api
    }
    
    func getProducts(completion: @escaping ((Result<[Product], Error>) -> Void)) {
        api.getProducts { (result) in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    func getProductDetail(id : String,completion: @escaping ((Result<Product, Error>) -> Void)) {
        api.getProductDetail(id: id, completion: { (result) in
            DispatchQueue.main.async {
                completion(result)
            }
        })
    }
}
