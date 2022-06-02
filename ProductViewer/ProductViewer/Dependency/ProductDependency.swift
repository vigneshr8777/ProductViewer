//
//  ProductDependency.swift
//  ProductViewer
//
//  Created by Vignesh Radhakrishnan on 10/03/21.
//

import Foundation

protocol ProductListDependency {
    
}

protocol ProductDetailDependency {
    var productID : String {get set}
}

struct ProductDependency : ProductListDependency,ProductDetailDependency {
    var productID: String
    
    init(productID : String) {
        self.productID = productID
    }
}
extension ProductDependency {
    init() {
        self.init(productID: "")
    }
}
protocol CardDependencyProtocol {
    var dataProvider : DataProvider {get set}
}
struct CardDependency : CardDependencyProtocol {
    var dataProvider : DataProvider
    
    init(dataProvider : CoreDataProvider) {
        self.dataProvider = dataProvider
    }
}
