//
//  EmptyRequestView.swift
//  CheckPlay
//
//  Created by sole on 2023/08/28.
//

import SwiftUI

struct EmptyRequestView: View {
    var body: some View {
        VStack {
            Image(systemName: "xmark.bin")
                .resizable()
                .frame(width: UIScreen.screenHeight * 0.2,
                       height: UIScreen.screenWidth * 0.3)
                .padding(10)
                .foregroundColor(.customLightGray)
            
            Text("공결 신청할 수 있는")
                .font(.system(size: 25, weight: .semibold))
                .foregroundColor(.customLightGray)
            
            Text("일정이 없습니다!")
                .font(.system(size: 25, weight: .semibold))
                .foregroundColor(.customLightGray)

        }
    }
}
