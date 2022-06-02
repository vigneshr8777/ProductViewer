//
//  CoreDataProvider.swift
//  ProductViewer
//
//  Created by Vignesh Radhakrishnan on 11/03/21.
//

import Foundation
import CoreData

protocol DataProvider {
    func fetchCartItems() -> [ProductInfo]
    func deleteCart(productID : Int,completion: @escaping (_ result:Result<Bool, Error>)->Void)
}
final class CoreDataProvider : DataProvider {
    
    static let sharedInstance = CoreDataProvider()
    let helper = CoreDataHelper.sharedInstance
    
    private init() {
        
    }
    
    func fetchCartItems() ->[ProductInfo] {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductInfo")
        do {
            if let products = try helper.context.fetch(fr) as? [ProductInfo] {
                return products
            }
        } catch {
            print(error)
        }
        return []
    }
    func deleteCart(productID : Int,completion: @escaping (_ result:Result<Bool, Error>)->Void) {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductInfo")
        let predicate = NSPredicate(format: "productID == %d", productID)
        fr.predicate = predicate
        do {
            if let result = try helper.context.fetch(fr) as? [ProductInfo],let productInfo = result.first  {
                helper.context.delete(productInfo)
                completion(.success(true))
            }
        }catch {
            completion(.failure(error as! Error))
        }
    }
    
    func addToCart(product : Product,completion: @escaping (_ result:Result<String, Error>)->Void) {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductInfo")
        let predicate = NSPredicate(format: "productID == %d", product.id)
        fr.predicate = predicate
        var message : String = ""
        do {
            if let result = try helper.context.fetch(fr) as? [ProductInfo],let productInfo = result.first  {
                productInfo.productID = Int32(product.id)
                productInfo.title = product.title
                productInfo.productDescription = product.productDescription
                productInfo.aisle = product.aisle
                productInfo.price = product.regularPrice.displayString
                productInfo.imageURL = product.imageURL
                
                message = "Already this product added to the cart"
            } else {
                guard let productInfo = NSEntityDescription.insertNewObject(
                    forEntityName: "ProductInfo",
                    into: helper.context) as? ProductInfo else { return }
                
                productInfo.productID = Int32(product.id)
                productInfo.title = product.title
                productInfo.productDescription = product.productDescription
                productInfo.price = product.regularPrice.displayString
                productInfo.aisle = product.aisle
                productInfo.imageURL = product.imageURL
                
                message = "This Product added to cart"
            }
            save()
            completion(.success(message))
        }catch {
            completion(.failure(error as! Error))
        }
    }
    func save() {
        do {
            try helper.context.save()
            print("saved")
        }
        catch
        {
            print("error in saving context")
        }
    }
}
