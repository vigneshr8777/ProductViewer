//
//  Parser.swift
//  ProductViewer
//
//  Created by Vignesh Radhakrishnan on 10/03/21.
//

import Foundation

struct Parser<T: Codable> {
    func decode(data: Data) throws -> T  {
        var result: T
        do {
            result = try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw error
        }
        return result
    }
    
    func encode(model: T) throws -> Data {
        var data: Data
        do {
            data = try JSONEncoder().encode(model)
        } catch {
            throw error
        }
        return data
    }
}

