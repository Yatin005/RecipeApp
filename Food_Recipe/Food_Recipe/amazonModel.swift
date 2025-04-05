//
//  AmazonModel.swift
//  Food_Recipe
//
//  Created by Yatin Parulkar on 2025-04-04.
//

import Foundation

// MARK: - Generic API Response

struct APIResponse: Codable {
    let data: ResponseData?
    let message: String?
    let statusCode: Int?
}

// MARK: - Generic Response Data

struct ResponseData: Codable {
    let results: [Product]?
    let productDetail: ProductDetail?
    let totalResults: Int?

    enum CodingKeys: String, CodingKey {
        case results, productDetail
        case totalResults = "total_results"
    }
}

// MARK: - Generic Product Detail

struct ProductDetail: Codable {
    let title: String?
    let image: String?
    let description: String?
    let price: Price?
    let discountedPrice: Price?

    enum CodingKeys: String, CodingKey {
        case title, image, description, price
        case discountedPrice = "discounted_price"
    }
}

// MARK: - Supporting Objects

struct Price: Codable {
    let raw: String?
    let amount: Double?
    let currency: String?
}

