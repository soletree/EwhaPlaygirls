//
//  LaunchScreenView.swift
//  CheckPlay
//
//  Created by sole on 2023/03/21.
//

import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        VStack {
            LottieView(name: "loading-airplane-green")
                .frame(height: UIScreen.screenHeight * 0.3)
                
            Text("로딩 중이에요")
                .pretendard(size: .l,
                            weight: .bold)
                .foregroundStyle(Color.gray300)
            Text("잠시만 기다려주세요!")
                .pretendard(size: .xxs,
                            weight: .medium)
                .foregroundStyle(Color.gray300)

        } // - VStack
    }
}

#Preview {
    LaunchScreenView()
}
