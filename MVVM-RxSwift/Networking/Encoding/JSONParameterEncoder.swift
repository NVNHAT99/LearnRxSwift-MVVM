//
//  JSONParameterEncoder.swift
//  MVVM-RxSwift
//
//  Created by Nhat on 2/23/25.
//

import Foundation

public struct JSONParameterEncoder: ParameterEncoder {
    public func encode(from urlRequest: inout URLRequest, with paramters: Parameters) throws {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: paramters, options: .prettyPrinted)
            urlRequest.httpBody = jsonData
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-type")
            }
        } catch {
            throw NetworkError.encodingFailed
        }
    }
}
