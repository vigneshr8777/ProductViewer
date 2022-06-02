//
//  NetworkManager.swift
//  ProductViewer
//
//  Created by Vignesh Radhakrishnan on 10/03/21.
//

import Foundation

protocol NetworkManager {
    typealias resultHandler = (Result<Data,Error>) -> Void
    func configure(session: URLSession)
    func request(requestInfo: RequestInfo, completion: @escaping resultHandler)
    func download(requestInfo: RequestInfo, completion: @escaping resultHandler)
}

struct RequestInfo {
    var path: String
    var parameters: [String: Any]?
    var method: HTTPMethod
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case update = "PUT"
    }
}

final class ProductNetworkManager: NetworkManager {
    
    static let sharedNetworkManager: NetworkManager = ProductNetworkManager()
    private var session: URLSession!
    
    private init() {
        configure()
    }
    
    func configure(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func request(requestInfo: RequestInfo, completion: @escaping (Result<Data, Error>) -> Void) {
        do {
            let urlRequest = try URLRequest.prepare(fromRequestInfo: requestInfo)
            session.dataTask(with: urlRequest) { (data, response, error) in
                if let responseError = Error.init(response: response) {
                    completion(.failure(responseError))
                } else if let httpError = Error.init(error: error) {
                    completion(.failure(httpError))
                } else if let data = data {
                    completion(.success(data))
                }
                }.resume()
        } catch {
            if let error = Error.init(error: error) {
                completion(.failure(error))
            }
        }
    }
    
    func download(requestInfo: RequestInfo, completion: @escaping (Result<Data, Error>) -> Void) {
        do {
            let urlRequest = try URLRequest.prepare(fromRequestInfo: requestInfo)
            session.downloadTask(with: urlRequest) { (url, response, error) in
                if let responseError = Error.init(response: response) {
                    completion(.failure(responseError))
                } else if let httpError = Error.init(error: error) {
                    completion(.failure(httpError))
                } else if let url = url, let data = try? Data.init(contentsOf: url) {
                    completion(.success(data))
                }
                }.resume()
        } catch {
            if let error = Error.init(error: error) {
                completion(.failure(error))
            }
        }
    }
}

extension URLRequest {
    static func prepare(fromRequestInfo info: RequestInfo) throws -> URLRequest {
        guard let url = URL.init(string: info.path), url.isValidURL() else {
            throw NSError.init(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: nil)
        }
        switch info.method {
        case .get:
            var queryItems: [URLQueryItem] = []
            if let data = info.parameters as? [String: String] {
                for (key, value) in data {
                    let item = URLQueryItem(name: key, value: value)
                    queryItems.append(item)
                }
            }
            guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw NSError.init(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: nil)
            }
            if !queryItems.isEmpty {
                urlComponents.queryItems = queryItems
            }
            guard let resultURL = urlComponents.url else {
                throw NSError.init(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: nil)
            }
            var urlRequest = URLRequest(url: resultURL)
            urlRequest.httpMethod = info.method.rawValue
            urlRequest.setValue("application/json", forHTTPHeaderField: "accept")
            return urlRequest
        case .post:
            fallthrough
        case .update:
            var urlRequest = URLRequest(url: url)
            if let parameters = info.parameters, let data = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) {
                urlRequest.httpBody = data
            }
            urlRequest.httpMethod = info.method.rawValue
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-type")
            urlRequest.setValue("application/json", forHTTPHeaderField: "accept")
            return urlRequest
        }
        
    }
}

extension URL {
    func isValidURL() -> Bool {
        return !(self.host?.isEmpty ?? true)
    }
}
