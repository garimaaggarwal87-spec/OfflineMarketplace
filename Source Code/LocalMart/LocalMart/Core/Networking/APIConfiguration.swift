//
//  APIConfiguration.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 22/10/26.
//

import Foundation

struct APIConfiguration {

    private static let scheme = "https"
    private static let host = "dummyjson.com"
    private static let resourcePath = "products"

    private static var baseComponents: URLComponents {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = "/\(resourcePath)"
        return components
    }

    static func makeURL(path: String = "", queryItems: [URLQueryItem] = []) -> URL? {
        var components = baseComponents

        if !path.isEmpty {
            components.path += "/" + path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        }

        components.queryItems = queryItems.isEmpty ? nil : queryItems
        return components.url
    }
}
