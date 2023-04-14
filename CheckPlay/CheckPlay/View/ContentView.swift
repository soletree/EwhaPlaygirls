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
            NavigationView {
                CheckMainView()
            }
            .tabItem {
                Image(systemName: "checkmark.circle.fill")
                Text("출석체크")
            }
            
            
            // 출석현황 탭
            NavigationView {
                AttendanceMainView()
            }
            .tabItem {
                Image(systemName: "list.clipboard")
                Text("출석현황")
            }
            
            // 공결신청 탭
            NavigationView {
                RequestView()
            }
            .tabItem {
                Image(systemName: "square.and.pencil")
                Text("공결신청")
            }
            
            // 마이페이지 탭
            NavigationView {
                MyPageView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("마이페이지")
            }
            
        }
        
        
    }
}
