//
//  AdminStore.swift
//  CheckPlay
//
//  Created by sole on 2023/08/28.
//

import FirebaseFirestore

struct AdminStore {
    let database = Firestore.firestore()
    
    static func login(id: String, password: String) async -> Bool {
        do {
            let documentID = Bundle.main.object(forInfoDictionaryKey: "VALID_NFC_TAG")
            let document = try await AdminStore().database.collection("Admin")
            .document("EwhaPlaygirls")
            .getDocument()
            
            guard id == document["id"] as? String ?? ""
            else { return false }
            
            guard password == document["password"] as? String ?? ""
            else { return false }
            
            return true
        } catch {
            print("error adminStore.login")
            return false
        }
    }
}
