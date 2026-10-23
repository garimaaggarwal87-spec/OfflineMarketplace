//
//  ProductDTO.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 22/10/26.
//

import Foundation

struct ProductResponse: Decodable {
    let products: [ProductDTO]
}

struct ProductDTO: Decodable {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let thumbnail: String?
}

struct ProductWriteRequest: Encodable {
    let title: String
    let description: String
    let price: Double
}

struct ProductWriteResponse: Decodable {
    let id: Int?
    let title: String?
    let description: String?
    let price: Double?
}
