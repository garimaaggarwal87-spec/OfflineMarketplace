//
//  ProductResponse.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 24/10/26.
//

import Foundation

struct ProductResponse: Decodable {
    let products: [ProductDTO]
}
