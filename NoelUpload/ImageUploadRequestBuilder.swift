//
//  ImageUploader.swift
//  NoelUpload
//
//  Created by Franck WERNER on 6/20/19.
//  Copyright © 2019 FranckRJ. All rights reserved.
//

import UIKit
import MobileCoreServices

fileprivate extension Data {
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}

class ImageUploadRequestBuilder {
    static func buildRequest(_ imageToUpload: UIImage) throws -> URLRequest {
        let boundary = generateBoundaryString()
        let url = URL(string: "http://www.noelshack.com/api.php")!
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = try createBody(UIImagePNGRepresentation(imageToUpload)!, boundary)

        return request
    }

    static private func createBody(_ imageRepresentation: Data, _ boundary: String) throws -> Data {
        var body = Data()
        let mimetype = "image/*"

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"fichier\"; filename=\"fichier.jpg\"\r\n")
        body.append("Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageRepresentation)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")

        return body
    }

    static private func generateBoundaryString() -> String {
        return "---------------boundary-\(UUID().uuidString)"
    }
}