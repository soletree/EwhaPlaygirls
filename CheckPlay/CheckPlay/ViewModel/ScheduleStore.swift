//
//  ScheduleStore.swift
//  CheckPlay
//
//  Created by sole on 2023/03/06.
//

import Foundation
import FirebaseFirestore
import Firebase

class ScheduleStore: ObservableObject {
    let database = Firestore.firestore()
    @Published var schedules: [Schedule] = []
    
    //MARK: - Method(fetchSchedulesUntilThreeDaysLater)
    /// 현재로부터 3일 뒤의 스케줄만 fetch 해오는 메서드입니다.
    /// - return: fetch 성공 여부. fetch가 성공하면 true를 반환합니다.
    @MainActor
    func fetchSchedulesUntilThreeDaysLater() async -> Bool {
        
        let calendar = Calendar.current
        let today = Date().returnDateOfToday()
        let startDate =  calendar.date(from: DateComponents(year: today.0, month: today.1, day: today.2 + 2)) ?? Date()
        var fetchedSchedules: [Schedule] = []
        
        do {
            let snapshot = try await database.collection("Schedule")
                .whereField(ScheduleConstant.date, isGreaterThanOrEqualTo: Timestamp(date: startDate))
                .getDocuments()
            
            
            if snapshot.documents.isEmpty { return true }
            for document in snapshot.documents {
                let timestamp = document[ScheduleConstant.date] as? Timestamp
                let schedule = Schedule(id: document[ScheduleConstant.id] as? String ?? DefaultValue.defaultString,
                                        date: timestamp?.dateValue() ?? Date(),
                                        latitude: document[ScheduleConstant.latitude] as? Double ?? 0,
                                        longitude: document[ScheduleConstant.longitude] as? Double ?? 0,
                                        address: document[ScheduleConstant.address] as? String ?? DefaultValue.defaultString,
                                        detailedAddress: document[ScheduleConstant.detailedAddress] as? String ?? DefaultValue.defaultString)
                fetchedSchedules.append(schedule)
            }
            DispatchQueue.main.async {
                self.schedules = fetchedSchedules.sorted{ $0.date < $1.date }
            }
            
            return true
            
        } catch {
            print("\(error.localizedDescription)")
            return false
        }
    } // - fetchSchedulesUntilThreeDaysLater
}



enum Period: Int {
    case firstHalf = 3
    case secondHalf = 9
}
