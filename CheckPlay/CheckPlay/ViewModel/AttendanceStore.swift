//
//  AttendanceStore.swift
//  CheckPlay
//
//  Created by sole on 2023/03/06.
//

import Foundation
import FirebaseFirestore

class AttendanceStore: ObservableObject {
    let database = Firestore.firestore()
    @Published var attendances: [Attendance] = []
    
    //MARK: - Method(fetchAttendance)
    @MainActor
    func fetchAttendance(studentCode: String) async -> Bool {
        var fetchAttendances: [Attendance] = []
        do {
            let snapshot = try await database.collection("Attendance")
                .whereField(AttendanceConstant.studentCode, isEqualTo: studentCode)
                .getDocuments()
            
            // 문서가 없음. fetch 자체는 성공이라 true 반환
            if snapshot.documents.isEmpty { return true }
            
            for document in snapshot.documents {
                let timestamp = document[AttendanceConstant.date] as? Timestamp
                let date = timestamp?.dateValue() ?? Date()
                if date > Date() { continue }
                
                let attendance = Attendance(id: document[AttendanceConstant.id] as? String ?? "",
                                            studentCode: document[AttendanceConstant.studentCode] as? String ?? "",
                                            scheduleID: document[AttendanceConstant.scheduleID] as? String ?? "",
                                            attendanceStatus: AttendanceStatus(rawValue:  document[AttendanceConstant.attendanceStatus] as? String ?? "") ?? .absent,
                                            lateTime: document[AttendanceConstant.lateTime] as? Int ?? 0,
                                            isPaying: document[AttendanceConstant.isPaying] as? Bool ?? false,
                                            date: date)
                
                
                fetchAttendances.append(attendance)
            }
            
            DispatchQueue.main.async {
                self.attendances = fetchAttendances.sorted { $0.date > $1.date }
            }
            return true
        } catch {
            print("\(error.localizedDescription)")
            return false
        }
    } // - fetchAttendance
    
    //MARK: - Method(fetchScheduleInPeriod)
    func fetchScheduleInPeriod(year: Int, period: Period) async -> Bool {
        let calendar = Calendar.current
        let nowTimeStamp = Timestamp(date: .init())
        var startDate: Date = .init()
        var endDate: Date = .init()
        
        switch period {
        case .firstHalf:
            startDate = calendar.date(from: DateComponents(year: year, month: 3, day: 1)) ?? Date()
            endDate = calendar.date(from: DateComponents(year: year, month: 9 , day: 1)) ?? Date()
        case.secondHalf:
            startDate = calendar.date(from: DateComponents(year: year, month: 9, day: 1)) ?? Date()
            endDate = calendar.date(from: DateComponents(year: year + 1, month: 3, day: 1)) ?? Date()
        }
        
        do {
            let snapshot = try await database.collection("Attendance")
                .whereField(ScheduleConstant.date, isGreaterThanOrEqualTo: Timestamp(date: startDate))
                .whereField(ScheduleConstant.date, isLessThanOrEqualTo: nowTimeStamp)
                .whereField(ScheduleConstant.date, isLessThan: Timestamp(date: endDate))
                .getDocuments()
            
            if snapshot.documents.isEmpty { return true }
            
            for document in snapshot.documents {
                let timestamp = document[AttendanceConstant.date] as? Timestamp
                let attendance = Attendance(id: document[AttendanceConstant.id] as? String ?? "",
                                            studentCode: document[AttendanceConstant.studentCode] as? String ?? "",
                                            scheduleID: document[AttendanceConstant.scheduleID] as? String ?? "",
                                            attendanceStatus: AttendanceStatus(rawValue: document[AttendanceConstant.attendanceStatus] as? String ?? "") ?? .absent,
                                            lateTime: document[AttendanceConstant.lateTime] as? Int ?? 0,
                                            isPaying: document[AttendanceConstant.isPaying] as? Bool ?? false,
                                            date: timestamp?.dateValue() ?? Date())
            }
            return true
            
        } catch {
            print("\(error.localizedDescription)")
            return false
        }
    } // - fetchScheduleInPeriod
    
    //MARK: - Method(updateAttendance)
    func updateAttendance(attendanceID: String, attendanceStatus: AttendanceStatus, lateTime: Int = 0) async -> Bool {
        do {
            try await database.collection("Attendance")
                .document(attendanceID)
                .updateData([AttendanceConstant.attendanceStatus : attendanceStatus.rawValue])
                
//            try await database.collection("Attendance")
//                .document(attendanceID)
//                .setValue(AttendanceConstant.lateTime, forKey: lateTime)
            
                    
            return true
        } catch {
            print("\(error.localizedDescription)")
            return false
        }
    } // - updateAttendance
    
    func findAttendanceWithScheduleID(scheduleID: String, studentCode: String) async -> Result<String, StoreError> {
        do {
            let snapshot = try await database.collection("Attendance")
                .whereField(AttendanceConstant.scheduleID, isEqualTo: scheduleID)
                .getDocuments()
            
            if snapshot.documents.isEmpty { return .failure(.fetchError) }
            
            for document in snapshot.documents {
                if studentCode == document[AttendanceConstant.studentCode] as? String ?? DefaultValue.defaultString {
                    return .success(document[AttendanceConstant.id] as? String ?? DefaultValue.defaultString)
                }
            }
            
            return .failure(.fetchError)
        } catch {
            print("\(error.localizedDescription)")
            return .failure(.fetchError)
        }
    }
}

enum StoreError: Error {
    case fetchError
}
