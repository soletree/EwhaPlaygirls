//
//  AttendanceMasterStore.swift
//  CheckPlay
//
//  Created by sole on 2023/08/28.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


// dict [studenctCode : attendanceStatus]
class AttendanceMasterStore : ObservableObject {
    let database = Firestore.firestore()
    // 출석 내역 추가 (만약 반영이 안된 출석 내역이 있을 수 있으므로)
    
    @Published var scheduleIDAndAttendanceDictionary: [String : Attendance] = [:]
    @Published var attendances: [Attendance] = []
    @Published var studentCodeAndAttendanceDictionaryInPeriod: [String : [Attendance]] = [:]
    var scheduleID: String = ""
    
    // 출결 상태를 추가합니다.
    //MARK: - Method(addAttendance)
    func addAttendance(scheduleID: String,
                       date: Date,
                       memberStore: MemberMasterStore) async {
        do {
            for member in memberStore.memberStore {
                // 휴동, 명예졸업이 아닌 경우에만 출석 내역을 추가합니다.
                guard member.memberStatus != .graduated
                else { continue }
                
            
                let attendanceID = UUID().uuidString
                var attendanceStatus = AttendanceStatus.absent.rawValue
                
                // 휴동일 경우 휴동 처리 합니다.
                if member.memberStatus == .rest {
                    attendanceStatus = AttendanceStatus.rest.rawValue
                }
                
                try await database.collection("Attendance")
                    .document(attendanceID)
                    .setData([
                        AttendanceConstant.id : attendanceID,
                        AttendanceConstant.studentCode : member.studentCode,
                        AttendanceConstant.scheduleID : scheduleID,
                        AttendanceConstant.attendanceStatus : attendanceStatus,
                        AttendanceConstant.lateTime : 0,
                        AttendanceConstant.isPaying : false,
                        AttendanceConstant.date : Timestamp(date: date)
                    ])
            }
            
        } catch {
            print("\(error.localizedDescription)")
            }
        
    } // - addAttendance
    
    //MARK: - Method(fetchAttendances)
//    @MainActor
    func fetchAttendances(scheduleID: String) async -> Bool {
//        var newAttendances: [String : [Attendance]] = [:]
        
        DispatchQueue.main.async {
            self.scheduleIDAndAttendanceDictionary = [:]
        }
        do {
            let snapshot = try await database.collection("Attendance")
                .whereField(AttendanceConstant.scheduleID, isEqualTo: scheduleID)
                .getDocuments()
            
            if snapshot.isEmpty { return false }
            
            for document in snapshot.documents {
                let studentCode = document[AttendanceConstant.studentCode] as? String ?? ""
                
                let attendance = Attendance(id: document[AttendanceConstant.id] as? String ?? "",
                           studentCode: document[AttendanceConstant.studentCode] as? String ?? "",
                           scheduleID: document[AttendanceConstant.scheduleID] as? String ?? "",
                           attendanceStatus: AttendanceStatus(rawValue: document[AttendanceConstant.attendanceStatus] as? String ?? "") ?? AttendanceStatus.absent,
                           lateTime: document[AttendanceConstant.lateTime] as? Int ?? 0,
                           isPaying: document[AttendanceConstant.isPaying] as? Bool ?? false,
                            date: document[AttendanceConstant.date] as? Date ?? Date())
                DispatchQueue.main.async {
                    self.scheduleIDAndAttendanceDictionary[studentCode] = attendance
                    
                }
                
            }
            
            //FIXME: Reference to captured var 'fetchSchedules' in concurrently-executing code
//            DispatchQueue.main.async {
//                self.attendances = newAttendances
//            }
            return true
            
        } catch {
            print("\(error.localizedDescription)")
            return false
        }
    } // - fetchAttendances
    
    //MARK: - Method(updateAttendance)
    func updateAttendance(attendance: Attendance) {
        database.collection("Attendance")
            .document(attendance.id)
            .updateData([
//                AttendanceConstant.id : attendance.id,
                AttendanceConstant.studentCode : attendance.studentCode,
//                AttendanceConstant.scheduleID : attendance.scheduleID,
                AttendanceConstant.attendanceStatus : attendance.attendanceStatus.rawValue,
                AttendanceConstant.lateTime : attendance.lateTime,
                AttendanceConstant.isPaying : attendance.isPaying,
//                AttendanceConstant.date : Timestamp(date: attendance.date)
            ])
    } // - updateAttendance
    
    //MARK: - Method(fetchAttendanceInPeriod)
    @MainActor
    func fetchAttendanceInPeriod(year: Int,
                                 period: Period) async -> Bool {
        // 상반기인지(당해 8월까지) 하반기인지(내년 2월까지)
        // 현재까지 출석 가져옴
        // 연도(year)
        let calendar = Calendar.current
        var startDate: Date = .init()
        var endDate: Date = .init()
//        var now: Date = Date(timeIntervalSinceNow: 86400)
        switch period {
        case .firstHalf:
            startDate = calendar.date(from: DateComponents(year: year, month: 3, day: 1)) ?? Date()
            endDate = calendar.date(from: DateComponents(year: year, month: 9, day: 1)) ?? Date()
        case .secondHalf:
            startDate = calendar.date(from: DateComponents(year: year, month: 9, day: 1)) ?? Date()
            endDate = calendar.date(from: DateComponents(year: year + 1, month: 3, day: 1)) ?? Date()
        }
        
        
        var fetchDictionary: [String: [Attendance]] = [:]
        do {
           let snapshot = try await database.collection("Attendance")
                .whereField(AttendanceConstant.date, isGreaterThanOrEqualTo: Timestamp(date:startDate))
                .whereField(AttendanceConstant.date, isLessThanOrEqualTo: Timestamp(date: .init()))
                .whereField(AttendanceConstant.date, isLessThan: Timestamp(date: endDate))
                .getDocuments()
            
            if snapshot.documents.isEmpty {
                DispatchQueue.main.async {
                    self.studentCodeAndAttendanceDictionaryInPeriod = fetchDictionary
                }
                return true
            }
            
            for document in snapshot.documents {
                let studentCode = document[AttendanceConstant.studentCode] as? String ?? ""
                let timestamp = document[AttendanceConstant.date] as? Timestamp
                let attendance = Attendance(id: document[AttendanceConstant.id] as? String ?? "",
                           studentCode: studentCode,
                           scheduleID: document[AttendanceConstant.scheduleID] as? String ?? "",
                           attendanceStatus: AttendanceStatus(rawValue: document[AttendanceConstant.attendanceStatus] as? String ?? "") ?? AttendanceStatus.absent,
                           lateTime: document[AttendanceConstant.lateTime] as? Int ?? 0,
                           isPaying: document[AttendanceConstant.isPaying] as? Bool ?? false,
                                            date: timestamp?.dateValue() ?? Date())
                
                
                fetchDictionary[studentCode, default: []].append(attendance)
            }
            DispatchQueue.main.async {
                self.studentCodeAndAttendanceDictionaryInPeriod = fetchDictionary
            }
            return true
            
        } catch {
            print("\(error.localizedDescription)")
            return false
        }
        
        
        
    } // - fetchAttendanceInPeriod
}
