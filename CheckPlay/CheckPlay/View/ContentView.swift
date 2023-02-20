//
//  ContentView.swift
//  CheckPlay
//
//  Created by sole on 2023/02/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            
            // 출석체크 탭
            CheckMainView()
                .tabItem {
                    Image(systemName: "checkmark.circle.fill")
                    Text("출석체크")
                }
            
            // 출석현황 탭
            Text("123")
                .tabItem {
                    Image(systemName: "list.clipboard")
                    Text("출석현황")
                }
            
            // 공결신청 탭 
            Text("123")
                .tabItem {
                    Image(systemName: "square.and.pencil")
                    Text("공결신청")
                }
        }
        
        
    }
}
