//
//  ScheduleStore.swift
//  EwhaPlaygirls-admin
//
//  Created by sole on 2023/03/04.
//

import Foundation
import FirebaseFirestore

class ScheduleMasterStore : ObservableObject {
    let database = Firestore.firestore()
    
    @Published var schedules: [Schedule] = []
    
    //MARK: - Method(addSchedule) -> attendance,
    func addSchedule(schedule: Schedule) async {
        do {
            try await database.collection("Schedule")
                .document(schedule.id)
                .setData([
                    ScheduleConstant.id : schedule.id,
                    ScheduleConstant.date : schedule.date,
                    ScheduleConstant.latitude : schedule.latitude,
                    ScheduleConstant.longitude : schedule.longitude,
                    ScheduleConstant.address : schedule.address,
                    ScheduleConstant.detailedAddress : schedule.detailedAddress
                ])
            schedules.append(schedule)
            DispatchQueue.main.async {
                self.schedules = self.schedules.sorted{ $0.date < $1.date }
            }
        } catch {
            print("\(error.localizedDescription)")
        }
        
    } // - addSchedule
    
    //MARK: - Method(deleteSchedule)
    func deleteSchedule(scheduleID: String) async -> Bool {
        do {
            // 일정 삭제
            try await database.collection("Schedule")
                .document(scheduleID)
                .delete()
            
            // 일정과 관련된 출석 내역도 모두 삭제
            let snapshot = try await database.collection("Attendance")
                .whereField(AttendanceConstant.scheduleID, isEqualTo: scheduleID)
                .getDocuments()
            
            if snapshot.documents.isEmpty { return true }
                
            for document in snapshot.documents {
                let attendanceID = document[AttendanceConstant.id] as? String ?? DefaultValue.defaultString
                try await database.collection("Attendance").document(attendanceID).delete()
            }
            
            return true
        } catch {
            print("\(error.localizedDescription)")
            return false
        }
    }
    
    
    //MARK: - Method(fetchSchedules)
    @MainActor
    func fetchSchedules() async -> Bool {
        var fetchSchedules: [Schedule] = []
        do {
            let snapshot = try await database.collection("Schedule")
                .getDocuments()
            if snapshot.isEmpty {
                // 아무 일정이 없는 경우에도 빈 배열을 반환해야 합니다.
                DispatchQueue.main.async {
                    self.schedules = fetchSchedules
                }
                return true
            }
            for document in snapshot.documents {
                let timeStamp = document[ScheduleConstant.date] as? Timestamp
                
                let schedule = Schedule(id: document[ScheduleConstant.id] as? String ?? "",
                                        date: timeStamp?.dateValue() ?? Date(),
                                        latitude: document[ScheduleConstant.latitude] as? Double ?? 0,
                                        longitude: document[ScheduleConstant.longitude] as? Double ?? 0,
                                        address: document[ScheduleConstant.address] as? String ?? "",
                                        detailedAddress: document[ScheduleConstant.detailedAddress] as? String ?? "")
                fetchSchedules.append(schedule)
                
            }
            DispatchQueue.main.async {
                self.schedules = fetchSchedules.sorted { $0.date > $1.date }
            }
            
            return true
            
        } catch {
            print("\(error.localizedDescription)")
            return false
        }
    } // - fetchSchedules
    
    /// 일정을 업데이트하는 메서드입니다.
    //MARK: - updateSchedule
    func updateSchedule(schedule: Schedule) async -> Bool {
        do {
            try await database.collection("Schedule")
                .document(schedule.id)
                .updateData([
                    ScheduleConstant.longitude: schedule.longitude,
                    ScheduleConstant.latitude: schedule.latitude,
                    ScheduleConstant.address: schedule.address,
                    ScheduleConstant.detailedAddress: schedule.detailedAddress
                ])
            
            return true
        } catch {
            print("\(error.localizedDescription)")
            return false
        }
    } // - updateSchedule
}


