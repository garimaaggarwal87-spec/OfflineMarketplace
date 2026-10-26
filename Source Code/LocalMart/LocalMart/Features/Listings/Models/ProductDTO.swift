//
//  ProductDTO.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 22/10/26.
//

import Foundation

struct ProductDTO: Decodable {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let thumbnail: String?
}
