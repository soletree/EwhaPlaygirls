//
//  ApplyStore.swift
//  CheckPlay
//
//  Created by sole on 2023/03/08.
//

import Foundation
import FirebaseFirestore

class RequestStore: ObservableObject {
    let database = Firestore.firestore()
    @Published var applies = []
    
    //MARK: - Method(addRequest)
    func addRequest(request: Request) async -> Bool{
        do {
            try await database.collection("Request")
                .document(request.id)
                .setData([
                    RequestConstant.id : request.id,
                    RequestConstant.scheduleID : request.scheduleID,
                    RequestConstant.studentCode : request.studentCode,
                    RequestConstant.content : request.content
                ])
            
            return true
        } catch {
            print("\(error.localizedDescription)")
            return false
        }
    } // - addRequest
    
    //MARK: - Method(isAlreadyInRequest)
    func isAlreadyInRequest(scheduleID: String, studentCode: String) async -> Bool {
        do {
            let snapshot = try await database.collection("Request")
                .whereField(RequestConstant.id, isEqualTo: "\(scheduleID)_\(studentCode)")
                .getDocuments()
            
            if snapshot.documents.isEmpty { return false }
            return true
        } catch {
            print("\(error.localizedDescription)")
            return false
        }
    } // - isAlreadyInRequest
    
}
