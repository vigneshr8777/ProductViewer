//
//  CoreDataHelper.swift
//  ProductViewer
//
//  Created by Vignesh Radhakrishnan on 11/03/21.
//

import Foundation
import CoreData

class CoreDataHelper {
    
    static let sharedInstance = CoreDataHelper()
    
    //Connecting the database
    let stack = CoreDataStack(modelName: "ProductViewer")!
    var context:NSManagedObjectContext
    
    private init() {
        context = stack.context
    }
}

