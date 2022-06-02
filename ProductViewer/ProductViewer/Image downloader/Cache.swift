//
//  Cache.swift
//  ProductViewer
//
//  Created by Vignesh Radhakrishnan on 10/03/21.
//

import Foundation

protocol Cache {
    func configure(maxMemory : Int)
    func getData(forKey key: String) -> Data?
    func setData(_ data: Data?,forKey key: String)
    func clearData()
}

final class SimpleCache: Cache {
    
    static let sharedCache: Cache = SimpleCache()
    
    private let cache: NSCache<NSString, NSData>
    
    private init() {
        cache = NSCache<NSString, NSData>()
        configure(maxMemory: 50*1024*1024)
    }
    
    func configure(maxMemory : Int) {
        cache.totalCostLimit = maxMemory
    }
    
    func getData(forKey key: String) -> Data? {
        return cache.object(forKey: NSString.init(string: key)) as Data?
    }
    
    func setData(_ data: Data?,forKey key: String) {
        guard let data = data else {
            return
        }
        let finalData = NSData.init(data: data)
        cache.setObject(finalData, forKey: NSString.init(string: key), cost: finalData.length)
    }
    
    func clearData() {
        cache.removeAllObjects()
    }
}
