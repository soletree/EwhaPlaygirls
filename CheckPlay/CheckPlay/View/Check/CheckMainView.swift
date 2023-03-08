//
//  CheckMainView.swift
//  CheckPlay
//
//  Created by sole on 2023/02/20.
//

import SwiftUI
import MapKit

struct CheckMainView: View {
    @EnvironmentObject var userStore: UserStore
    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37, longitude: 128), latitudinalMeters: 500, longitudinalMeters: 500)
    @State var isActiveMyPage: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            // 현재 날짜
            Text("\(Date().toStringUntilDay())")
                .font(.title.bold())
                .padding(10)
            
            // 지도
            CheckMapView()
    
//            // nfc 버튼
//                .toolbar {
//                    ToolbarItem {
//                        Button(action: {
//                            isActiveMyPage = true
//                        }) {
//                            Image(systemName: "person.circle.fill")
//                                .font(.title3)
//                        }
//                    } // - ToolbarItem
//                } // - toolbar
        } // - VStack

    }
}

