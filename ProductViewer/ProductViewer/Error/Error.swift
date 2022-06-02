//
//  Error.swift
//  ProductViewer
//
//  Created by Vignesh Radhakrishnan on 10/03/21.
//

import Foundation

enum Error: LocalizedError {
    // represent status code error.
    case httpError(HTTPError)
    //represent URL loading system defined by apple like no internet.
    case urlLoadingError(URLLoadingError)
    case parsingError(String)
    case unknownError(String)
    
    var localizedDescription: String {
        let string: String
        switch self {
        case .httpError(let error):
            string = error.localizedDescription
        case .urlLoadingError(let error):
            string = error.localizedDescription
        case .parsingError(let error):
            string = error
        case .unknownError(let error):
            string = error
        }
        return string
    }
}

extension Error {
    enum HTTPError: RawRepresentable, LocalizedError {
        case serverError(Int)
        case clientError(Int)
        
        var localizedDescription: String {
            let string: String
            switch self {
            case .serverError:
                string = "Internal server error"
            case .clientError(let code):
                if code == 422 {
                    string = "Validation Errors"
                } else if code == 404 {
                    string = "Not found"
                } else {
                    string = "API error"
                }
            }
            return string
        }
        
        typealias RawValue = Int
        
        init?(rawValue: RawValue) {
            switch rawValue {
            case 400..<500:
                self = .clientError(rawValue)
            case 500..<600:
                self = .serverError(rawValue)
            default:
                return nil
            }
        }
        
        var rawValue: RawValue {
            let value: Int
            switch self {
            case .clientError(let number):
                value = number
            case .serverError(let number):
                value = number
            }
            return value
        }
    }
    
    enum URLLoadingError: RawRepresentable, LocalizedError {
        
        case notConnectedToInternet
        case badURL
        case cannotConnectToHost
        case cannotFindHost
        case badServerResponse
        case unknown
        
        var localizedDescription: String {
            let string: String
            switch self {
            case .notConnectedToInternet:
                string = "Please check your internet connection"
            case .badURL:
                string = "URL malformed"
            case .cannotConnectToHost:
                string = "An attempt to connect to a host failed."
            case .cannotFindHost:
                string = "The host name for a URL couldn’t be resolved."
            case .badServerResponse:
                string = "Received bad data from server."
            case .unknown:
                string = "Unknown error occured."
            }
            return string
        }
        
        typealias RawValue = Int
        
        init(rawValue: RawValue) {
            let value = -rawValue
            switch value {
            case 1000:
                self = .badURL
            case 1003:
                self = .cannotFindHost
            case 1004:
                self = .cannotConnectToHost
            case 1009:
                self = .notConnectedToInternet
            case 1011:
                self = .badServerResponse
            default:
                self = .unknown
            }
        }
        
        var rawValue: RawValue {
            var value: Int
            switch self {
            case .badURL:
                value = 1000
            case .cannotFindHost:
                value = 1003
            case .cannotConnectToHost:
                value = 1004
            case .notConnectedToInternet:
                value = 1009
            case .badServerResponse:
                value = 1011
            default:
                value = 10000
            }
            value = -value
            return value
        }
    }
}

extension Error {
    init?(response: URLResponse?) {
        guard let response = response as? HTTPURLResponse, let httpError = Error.HTTPError.init(rawValue: response.statusCode) else {
            return nil
        }
        self = Error.httpError(httpError)
    }
}

extension Error {
    init?(error: Swift.Error?) {
        guard let error = error as NSError? else {
            return nil
        }
        if error.domain == NSURLErrorDomain {
            self = Error.urlLoadingError(Error.URLLoadingError.init(rawValue: error.code))
        } else if error is DecodingError {
            self = Error.parsingError(error.localizedDescription)
        } else {
            self = Error.unknownError(error.localizedDescription)
        }
    }
}
