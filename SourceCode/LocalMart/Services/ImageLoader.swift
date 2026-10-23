//
//  ThumbnailImageCache.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 22/10/26.
//

import Foundation
import UIKit

final class ImageLoader {

    static let shared = ImageLoader()

    private let cache = NSCache<NSString, UIImage>()

    private init() {}

    func cachedImage(for key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    // MARK: - Load Remote Image

    func loadRemoteImage(from urlString: String) async throws -> UIImage {
        let key = "remote:\(urlString)" as NSString

        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }

        cache.setObject(image, forKey: key)

        return image
    }

    // MARK: - Load Local Image

    func loadLocalImage(from filename: String) throws -> UIImage {
        let key = "local:\(filename)" as NSString

        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }

        let documentsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        let fileURL = documentsURL.appendingPathComponent(filename)
        let data = try Data(contentsOf: fileURL)

        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }

        cache.setObject(image, forKey: key)

        return image
    }
}
