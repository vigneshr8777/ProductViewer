//
//  ProductAPI.swift
//  ProductViewer
//
//  Created by Vignesh Radhakrishnan on 10/03/21.
//

struct Server {
    static let baseurl = "https://api.target.com/mobile_case_study_deals/v1"
    struct Endpoint {
        static let products = Server.baseurl + "/" + "deals"
        static let productDetail = Server.baseurl + "/deals/%@"
    }
}

protocol ProductsAPI {
    func getProducts(completion: @escaping ((Result<[Product], Error>) -> Void))
    func getProductDetail(id: String, completion: @escaping ((Result<Product,Error>) -> Void))
}

struct ProductsAPIManager: ProductsAPI {
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = ProductNetworkManager.sharedNetworkManager) {
        self.networkManager = networkManager
    }
    
    func getProducts(completion: @escaping ((Result<[Product], Error>) -> Void)) {
        networkManager.request(requestInfo: RequestInfo(path: Server.Endpoint.products, parameters: nil, method: .get)) { (result) in
            switch result {
            case .success(let data):
                do {
                    let response = try Parser<Response>().decode(data: data)
                    completion(.success(response.products))
                } catch {
                    if let error = Error.init(error: error) {
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    func getProductDetail(id: String, completion: @escaping ((Result<Product,Error>) -> Void)) {
        let requestPath = String(format: Server.Endpoint.productDetail, id)
        networkManager.request(requestInfo: RequestInfo(path: requestPath, parameters: ["format":"json"], method: .get)) { (result) in
            switch result {
            case .success(let data):
                do {
                    let product = try Parser<Product>().decode(data: data)
                    completion(.success(product))
                } catch {
                    if let error = Error.init(error: error) {
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

