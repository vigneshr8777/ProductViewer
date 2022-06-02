//
//  Product.swift
//  ProductViewer
//
//  Created by Vignesh Radhakrishnan on 10/03/21.
//

import Foundation

struct Response: Codable {
    let products: [Product]
    
}

// MARK: - Product
struct Product: Codable {
    let id: Int
    let title, aisle, productDescription: String
    let imageURL: String
    let salePrice : Price?
    let regularPrice : Price

    enum CodingKeys: String, CodingKey {
        case id, title, aisle
        case productDescription = "description"
        case imageURL = "image_url"
        case regularPrice = "regular_price"
        case salePrice = "sale_price"
    }
}

// MARK: - Price
struct Price: Codable {
    let amountInCents: Int
    let currencySymbol, displayString: String

    enum CodingKeys: String, CodingKey {
        case amountInCents = "amount_in_cents"
        case currencySymbol = "currency_symbol"
        case displayString = "display_string"
    }
}
