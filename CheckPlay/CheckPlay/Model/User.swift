//
//  User.swift
//  CheckPlay
//
//  Created by sole on 2023/02/28.
//

import Foundation

// 유저 모델
struct User {
    var id: String // Firebase uid
    var studentCode: String // 학번 (식별자)
    var name: String // 이름
    var email: String // 이메일
}
