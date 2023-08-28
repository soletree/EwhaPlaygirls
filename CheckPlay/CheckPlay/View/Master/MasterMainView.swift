//
//  MasterMainView.swift
//  CheckPlay
//
//  Created by sole on 2023/08/28.
//

import SwiftUI

struct MasterMainView: View {
    var body: some View {
        VStack {
            TabView {
                NavigationView {
                    MemberMasterMainView()
                }
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("회원 관리")
                }
                NavigationView {
                    ScheduleMasterMainView()
                }
                .tabItem {
                    Image(systemName: "calendar")
                    Text("일정 관리")
                }
                NavigationView {
                    AttendanceMasterMainView()
                }
                .tabItem {
                    Image(systemName: "checkmark.circle.fill")
                    Text("출결 관리")
                }
                
                NavigationView {
                    MyPageMasterView()
                }
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("마이페이지")
                }
            }
        }
    }
    
}
