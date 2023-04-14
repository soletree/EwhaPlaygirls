//
//  GoogleAdView.swift
//  CheckPlay
//
//  Created by sole on 2023/04/08.
//

import SwiftUI
import GoogleMobileAds

struct GoogleAdView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let bannerSize = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.screenWidth)
        let banner = GADBannerView(adSize: bannerSize)
        banner.rootViewController = viewController
        viewController.view.addSubview(banner)
        viewController.view.frame = CGRect(origin: .zero, size: bannerSize.size)
        banner.adUnitID = "\(Bundle.main.object(forInfoDictionaryKey: "GoogleAdUnitID") ?? "")"
        
        banner.load(GADRequest())
        return viewController
    }

  func updateUIViewController(_ viewController: UIViewController, context: Context) {

  }
}


