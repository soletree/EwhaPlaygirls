//
//  EPButton.swift
//  CheckPlay
//
//  Created by sole on 2023/02/20.
//

import SwiftUI

struct EPButton<Label: View>: View {
    let action: () -> ()
    @ViewBuilder let label: () -> Label
    
    var body: some View {
        Button(action: action) {
            label()
                .pretendard(size: .m, weight: .semibold)
                .foregroundStyle(Color.white)
                .padding(.vertical, 18)
                .padding(.horizontal, 20)
                .background(Color.brandColor)
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
}

#Preview {
    EPButton(action: {}) {
        Text("장바구니로 이동")
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
    }
}


