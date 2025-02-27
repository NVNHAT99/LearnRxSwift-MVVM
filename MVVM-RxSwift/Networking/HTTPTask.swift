//
//  HTTPTask.swift
//  MVVM-RxSwift
//
//  Created by Nhat on 2/23/25.
//

import Foundation

public typealias HTTPHeaders = [String: String]

public enum HTTPTask {
    case request
    
    case requestParameters(
        bodyParameters: Parameters?,
        urlParameters: Parameters?,
        parameterEncoding: ParameterEncoding
    )
    
    case requestParametersAndHeaders(
        bodyParameters: Parameters?,
        urlParameters: Parameters?,
        additionHeaders: HTTPHeaders?,
        parameterEncoding: ParameterEncoding
    )
    case requestMultiPart(
        bodyParameters: MultipartFormData,
        urlParameters: Parameters?,
        additionHeaders: HTTPHeaders?,
        parameterEncoding: ParameterEncoding
    )
}
