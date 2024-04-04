//
//  Schedule.swift
//  CheckPlay
//
//  Created by sole on 2023/03/06.
//

import Foundation
import CoreLocation
// 스케줄 - 출석, 스케줄 - 공결 신청

struct Schedule {
    var id: String // 식별자
    var date: Date // 일시
//    var latitude: Double // 위도
//    var longitude: Double // 경도
//    var address: String // 도로명 주소
//    var detailedAddress: String // 상세주소
//    
//    var location: CLLocationCoordinate2D {
//        .init(latitude: self.latitude, longitude: self.longitude)
//    } // 모임 장소
//    
//    init(id: String,
//         date: Date,
//         latitude: Double,
//         longitude: Double, address: String,
//         detailedAddress: String) {
//        self.id = id
//        self.date = date
//        self.latitude = latitude
//        self.longitude = longitude
//        self.address = address
//        self.detailedAddress = detailedAddress
//    }
    
    static let defaultModel = Schedule(id: "unknown",
                                          date: Date())

    
//    static let defaultModel = Schedule(id: "unknown",
//                                       date: Date(),
//                                       latitude: 0,
//                                       longitude: 0,
//                                       address: "unknown",
//                                       detailedAddress: "unknown")
}
