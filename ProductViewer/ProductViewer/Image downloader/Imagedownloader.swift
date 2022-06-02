//
//  Imagedownloader.swift
//  ProductViewer
//
//  Created by Vignesh Radhakrishnan on 10/03/21.
//

import Foundation
import UIKit.UIImage

final class ImageDownloader {
    
    static let sharedImageDownloader = ImageDownloader()
    private var cache: Cache?
    private var networkManager: NetworkManager?
    private let queue = DispatchQueue(label: "queue.imagedownload", attributes: .concurrent)
    private init() {
        configure()
    }
    
    func configure(cache: Cache = SimpleCache.sharedCache, networkManager: NetworkManager = ProductNetworkManager.sharedNetworkManager) {
        self.cache = cache
        self.networkManager = networkManager
    }
    
    func download(path: String, completion: @escaping (UIImage?) -> Void) {
        queue.async { [weak self] in
            guard let self = self else {
                return
            }
            if let cachedData = self.cache?.getData(forKey: path), let image = UIImage.init(data: cachedData) {
                DispatchQueue.main.async {
                    completion(image)
                }
                return
            }
            let info = RequestInfo(path: path, parameters: nil, method: .get)
            self.networkManager?.download(requestInfo: info) { (result) in
                if let data = try? result.get(), let image = UIImage.init(data: data) {
                    self.queue.sync {
                        self.cache?.setData(data, forKey: info.path)
                        DispatchQueue.main.async {
                            completion(image)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }
    }
}


