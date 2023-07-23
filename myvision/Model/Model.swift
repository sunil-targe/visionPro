//
//  Model.swift
//  myvision
//
//  Created by Sunil Targe on 2023/7/3.
//

import Foundation

struct Follower: Decodable, Identifiable, Hashable {
    let login: String
    let id: Int
    let avatarUrl: String
}

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
