//
//  ApplyView.swift
//  CheckPlay
//
//  Created by sole on 2023/03/07.
//
import SwiftUI
import WebKit

struct RequestView: View {
    var body: some View {
        VStack {
            CafeWebView()
        }
    }
}

//MARK: - CafeWebView
struct CafeWebView: UIViewRepresentable {
    private var urlRequest: URLRequest {
        guard let url = URL(string: "https://cafe.naver.com/ewhaplaygirls")
        else { return .init(url: .applicationDirectory) }
        return .init(url: url)
    }
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        let webView = WKWebView()
        
        // addSubview
        view.addSubview(webView)
        
        // layout
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        webView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        webView.load(urlRequest)
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType,
                      context: Context) {
    }
}


#Preview {
    RequestView()
}
