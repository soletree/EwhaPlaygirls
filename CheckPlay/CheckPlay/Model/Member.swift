//
//  Member.swift
//  EwhaPlaygirls-admin
//
//  Created by sole on 2023/03/04.
//

import Foundation

enum MemberStatus: String {
    case new = "신입부원" // 신입부원
    case official = "정식부원" // 정식부원
    case graduated = "명예졸업" // 명예졸업 부원
    case rest = "휴동"
}

struct Member {
    var studentCode: String
    var name: String
    var memberStatus: MemberStatus
    // 출석률 (60퍼 / 40퍼) -> 클라이언트 단에서 계산하는 게 맞지 않을까?
    // 전체 기간 중 출석률 (40프로)
    
    static let defaultModel = Member(studentCode: "unknown",
                                     name: "unknown",
                                     memberStatus: .graduated)
}
