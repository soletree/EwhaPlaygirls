//
//  GeoCodingResponse.swift
//  CheckPlay
//
//  Created by sole on 2023/08/28.
//

import Foundation
struct GeoCodingResponse: Codable {
    let status: String
    let meta: Meta
    let addresses: [Address]
    let errorMessage: String
}

// MARK: - Address
struct Address: Codable {
    let roadAddress, jibunAddress, englishAddress: String
    let addressElements: [AddressElement]
    let x, y: String
    let distance: Double
}

// MARK: - AddressElement
struct AddressElement: Codable {
    let types: [String]
    let longName, shortName, code: String
}

// MARK: - Meta
struct Meta: Codable {
    let totalCount, page, count: Int
}
