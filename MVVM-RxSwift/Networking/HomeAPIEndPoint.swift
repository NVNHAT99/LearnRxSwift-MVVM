//
//  HomeAPIRouter.swift
//  IOS-Challenge
//
//  Created by Nhat on 12/14/24.
//

import Foundation

enum HomeAPIEndPoint: EndPointType {
    case getImage(pageIndex: Int, limit: Int = 100)
    
    var baseURL: URL {
        return URL(string: "https://picsum.photos/v2")!
    }
    
    var path: String {
        switch self {
        case .getImage:
            return "/list"
        }
    }
    
    public var timeoutInterval: Double? {
        return 30.0
    }
    
    var method: HTTPMethod {
        switch self {
        case .getImage:
            return .get
        }
    }
    
    var headers: [String : String]? {
        return [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue
        ]
    }
    
    var task: HTTPTask {
        switch self {
        case .getImage(let pageIndex,
                       let limit):
            var params = Parameters()
            params["page"] = pageIndex
            params["limit"] = limit
            return .requestParameters(bodyParameters: nil,
                                      urlParameters: params, parameterEncoding: .urlEncoding)
        }
    }
    
}
