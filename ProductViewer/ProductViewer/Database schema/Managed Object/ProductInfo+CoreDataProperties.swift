//
//  ProductInfo+CoreDataProperties.swift
//  ProductViewer
//
//  Created by Vignesh Radhakrishnan on 11/03/21.
//
//

import Foundation
import CoreData


extension ProductInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductInfo> {
        return NSFetchRequest<ProductInfo>(entityName: "ProductInfo")
    }

    @NSManaged public var aisle: String?
    @NSManaged public var price: String?
    @NSManaged public var productDescription: String?
    @NSManaged public var productID: Int32
    @NSManaged public var title: String?
    @NSManaged public var imageURL: String?

}

extension ProductInfo : Identifiable {

}
