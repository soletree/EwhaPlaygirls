//
//  MemberMasterStore.swift
//  CheckPlay
//
//  Created by sole on 2023/08/28.
//

import Foundation
import FirebaseFirestore

class MemberMasterStore: ObservableObject {
    let database = Firestore.firestore()
    
    @Published var memberStore: [Member] = []
    @Published var studentCodeAndMemberDictionary: [String : Member] = [:]
    
    //MARK: - Method(addMember)
    func addMember(member: Member) async -> Bool {
        do {
            try await database.collection("Member")
                .document("\(member.studentCode)")
                .setData([
                    MemberConstant.studentCode : member.studentCode,
                    MemberConstant.name : member.name,
                    MemberConstant.memberStatus : member.memberStatus.rawValue
                ])
            
            DispatchQueue.main.async {
                self.memberStore.append(member)
                self.studentCodeAndMemberDictionary[member.studentCode] = member
                self.memberStore.sort { $0.studentCode < $1.studentCode }
            }
            
            return true
        } catch {
            print("\(error.localizedDescription)")
            return false
        }
    }
    
    //MARK: - Method(deleteMember) -> 클라이언트 단에서 되도록 사용하지 않도록 주의
    func deleteMember(studentCode: String) async -> Bool {
        // 회원탈퇴 메서드 + 재가입 불가하도록 Member에서 삭제 -> 더이상 동아리 회원이 아닌 사람을 삭제
        do {
            try await database.collection("Member")
                .document(studentCode)
                .delete()
            
            let snapshot = try await database.collection("Attendance")
                .whereField(AttendanceConstant.studentCode, isEqualTo: studentCode)
                .getDocuments()
            
            // 출석 정보가 없는 경우에도 정상적으로 처리된 것으로 간주합니다.
            if snapshot.documents.isEmpty { return true }
            
            for document in snapshot.documents {
                try await database.collection("Attendance")
                    .document(document.documentID)
                    .delete()
            }

            return true
        } catch {
            print("\(error.localizedDescription)")
            return false
        }
        
    }
    
    //MARK: - Method(fetchMembers)
    @MainActor
    func fetchMembers() async -> Bool {
        var fetchMembers: [Member] = []
        do {
            let snapshot = try await database.collection("Member")
//                .whereField(MemberConstant.memberStatus,
//                            isNotEqualTo: MemberStatus.graduated.rawValue)
                .getDocuments()
            
            if snapshot.documents.isEmpty {
                // 문서가 빈 경우에도 배열에 반영합니다.
                DispatchQueue.main.async {
                    self.studentCodeAndMemberDictionary = [:]
                    self.memberStore = fetchMembers
                }
                return true
            }
            for document in snapshot.documents {
                let member = Member(studentCode: document[MemberConstant.studentCode] as? String ?? "",
                                    name: document[MemberConstant.name] as? String ?? "",
                                    memberStatus: MemberStatus(rawValue: document[MemberConstant.memberStatus] as? String ?? "") ?? MemberStatus.graduated)
                
                fetchMembers.append(member)
                
                DispatchQueue.main.async {
                    self.studentCodeAndMemberDictionary[member.studentCode] = member
                    fetchMembers.sort { $0.studentCode < $1.studentCode }
                    self.memberStore = fetchMembers
                }
            }
            return true
        } catch {
            print("\(error.localizedDescription)")
            return false
        }
    } // - fetchMembers
    
    
    
    //MARK: - Method(updateMember)
    func updateMember(member: Member) {
        database.collection("Member")
            .document(member.studentCode)
            .setData([
                MemberConstant.studentCode : member.studentCode,
                MemberConstant.name : member.name,
                MemberConstant.memberStatus : member.memberStatus.rawValue
            ])
    } // - updateMember
    
}
