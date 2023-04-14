//
//  LauchScreenView.swift
//  CheckPlay
//
//  Created by sole on 2023/03/21.
//

import SwiftUI

struct LauchScreenView: View {
    var body: some View {
        VStack {
            LottieView(name: "loading-airplane-green")
                .frame(height: UIScreen.screenHeight * 0.3)
                
            Text("로딩 중...")
                .font(.title3.bold())
            
            
        } // - VStack
    }
}


