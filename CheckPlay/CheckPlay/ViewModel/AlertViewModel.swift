//
//  AlertViewModel.swift
//  CheckPlay
//
//  Created by sole on 1/16/24.
//

import SwiftUI
import AlertToast

class AlertViewModel: ObservableObject {
    @Published var isProcessing: Bool = false
    @Published var isError: Bool = false
    @Published var isComplete: Bool = false
    
    private var errorTitle: String?
    private var errorSubTitle: String?
    private var completeTitle: String?
    private var completSubTitle: String?
    
    func setAlertTitle() {
        
    }
    
    var errorAlert: AlertToast {
        AlertToast(displayMode: .alert,
                   type: .error(.red),
                   title: self.errorTitle,
                   subTitle: self.errorSubTitle)
    }
    
    var loadingAlert: AlertToast {
        AlertToast(displayMode: .alert,
                   type: .loading)
    }
    
    var completAlert: AlertToast {
        AlertToast(displayMode: .alert,
                   type: .complete(.subColor300),
                   title: completeTitle,
                   subTitle: completSubTitle)
    }
    
    func setErrorTitle(title: String? = nil,
                       subTitle: String? = nil) {
        self.errorTitle = title
        self.errorSubTitle = subTitle
    }
    
    func setCompleteTitle(title: String? = nil,
                          subTitle: String? = nil) {
        self.completeTitle = title
        self.completSubTitle = subTitle
    }
    
}

