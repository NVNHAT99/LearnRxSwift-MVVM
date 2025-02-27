//
//  MultiplePartParameterEncoder.swift
//  MVVM-RxSwift
//
//  Created by Nhat on 2/27/25.
//

import Foundation
struct MultiplePartParameterEncoder {
    public func encode(urlRequest: inout URLRequest, with parameters: MultipartFormData) throws {
        urlRequest.httpBody = try parameters.encode()
        urlRequest.setValue("no-cache", forHTTPHeaderField: "cache-control")
        urlRequest.setValue("multipart/form-data; boundary=\(parameters.boundary)", forHTTPHeaderField: "content-type")
    }
}
