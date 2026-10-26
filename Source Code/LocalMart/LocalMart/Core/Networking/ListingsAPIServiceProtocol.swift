//
//  ListingsAPIServiceProtocol.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 25/10/26.
//

import Foundation
import Combine

protocol ListingsAPIServiceProtocol {

    func fetchProducts() -> AnyPublisher<[ProductDTO], Error>

    func createProduct(
        title: String,
        description: String,
        price: Double
    ) -> AnyPublisher<ProductWriteResponse, Error>

    func updateProduct(
        serverID: Int,
        title: String,
        description: String,
        price: Double
    ) -> AnyPublisher<ProductWriteResponse, Error>
}
