//
//  NFCSheetView.swift
//  CheckPlay
//
//  Created by sole on 2023/03/18.
//

import SwiftUI
import CoreNFC
import SwiftNFC


@available(iOS 13.0, *)
public class NFCReader: NSObject, ObservableObject,
                        NFCNDEFReaderSessionDelegate {
    
    public var startAlert = "NFC 태그를 핸드폰 가까이에 두세요."
    public var endAlert = ""
    
    @Published public var msg = "Scan to read or Edit here to write..."
    public var raw = "Raw Data available after scan."

    public var session: NFCNDEFReaderSession?
    
    public func read() {
        guard NFCNDEFReaderSession.readingAvailable else {
            print("Error")
            return
        }
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = self.startAlert
        session?.begin()
    }
    
    public func readerSession(_ session: NFCNDEFReaderSession,
                              didDetectNDEFs messages: [NFCNDEFMessage]) {
        DispatchQueue.main.async {
            self.msg = messages.map {
                $0.records.map {
                    String(decoding: $0.payload, as: UTF8.self)
                }.joined(separator: "\n")
            }.joined(separator: " ")
            
            self.raw = messages.map {
                $0.records.map {
                    "\($0.typeNameFormat) \(String(decoding:$0.type, as: UTF8.self)) \(String(decoding:$0.identifier, as: UTF8.self)) \(String(decoding: $0.payload, as: UTF8.self))"
                }.joined(separator: "\n")
            }.joined(separator: " ")
            
            session.alertMessage = self.endAlert != "" ? self.endAlert : "NFC 태그 읽기 성공"
        }
    }
    
    public func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
    }
    
    public func readerSession(_ session: NFCNDEFReaderSession,
                              didInvalidateWithError error: Error) {
        print("Session did invalidate with error: \(error)")
        self.session = nil
    }
}
