//
//  CusomSheet.swift
//  CheckPlay
//
//  Created by sole on 2023/05/02.
//
import UIKit
import SwiftUI
//import SwiftUI


class ModalViewController: UIViewController {
    override func viewDidLoad() {
        if let sheetPresentationController = sheetPresentationController {
            sheetPresentationController.detents = [.medium(),
                                                   .large()]
        }
    }
}

struct CustomSheet: UIViewRepresentable {
    var name : String
    
    func makeUIView(context: UIViewRepresentableContext<CustomSheet>) -> UIView {
        let view = UIView()
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

extension View {
    func halfSheet() {
        let view = UIViewController()
        let nav = UINavigationController(rootViewController: view)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(),
                             .large()]
        }
        view.present(nav, animated: true)
        
    }
}
