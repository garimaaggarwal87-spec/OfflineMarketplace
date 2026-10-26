//
//  ProductWriteRequest.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 24/10/26.
//

import Foundation

struct ProductWriteRequest: Encodable {
    let title: String
    let description: String
    let price: Double
}
