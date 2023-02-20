//
//  CustomButton.swift
//  CheckPlay
//
//  Created by sole on 2023/02/20.
//

import SwiftUI

struct CustomButton {
    
    public enum CustomButtonStyle {
        case plain
    }
   
    
    
    struct CustomButtonView: View {
        public let style: CustomButtonStyle
        public let action: () -> Void
        var body: some View {
            VStack {
                
            }
        }
    }
    init() {
        
    }
}

