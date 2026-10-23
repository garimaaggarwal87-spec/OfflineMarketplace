//
//  APIConfiguration.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 22/10/26.
//

import Foundation

enum APIConfiguration {
    static let baseURL = URL(string: "https://dummyjson.com")!
    static let productsURL = baseURL.appending(path: "products")
}
