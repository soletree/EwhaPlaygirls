//
//  NFCSheetView.swift
//  CheckPlay
//
//  Created by sole on 2023/03/18.
//

import SwiftUI
import CoreNFC

struct NFCSheetView: View {
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onAppear {
                print(NFCReaderSession.readingAvailable)
            }
    }
        
}


