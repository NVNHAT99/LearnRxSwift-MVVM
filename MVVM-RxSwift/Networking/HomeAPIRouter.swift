//
//  HomeAPIRouter.swift
//  IOS-Challenge
//
//  Created by Nhat on 12/14/24.
//

import Foundation

enum HomeAPIRouter: APIRouterProtocol {
    case getImage(pageIndex: Int, limit: Int = 100)
    
    var baseURL: String {
        return "https://picsum.photos/v2"
    }
    
    var endPoint: String {
        switch self {
        case .getImage(let pageIndex, let limit):
            return "/list?page=\(pageIndex)&limit=\(limit)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getImage:
            return .get
        }
    }
    
    var headers: [String : String]? {
        return [
            HTTPHeaderField.acceptType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue
        ]
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .getImage:
            return nil
        }
    }
    
    
}
