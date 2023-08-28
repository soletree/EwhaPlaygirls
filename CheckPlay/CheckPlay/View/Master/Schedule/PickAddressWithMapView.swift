//
//  PickAddressWithMapView.swift
//  EwhaPlaygirls-admin
//
//  Created by sole on 2023/04/22.
//

import SwiftUI
import CoreLocation
import Contacts

struct PickAddressWithMapView: View {
    @StateObject var webViewModel: WebViewModel = .init()
    @StateObject var locationManager: LocationManager = .init()
    
    @Binding var coordinateList: [Double]
    @Binding var isPresented: Bool
    @State var coordinate: CLLocationCoordinate2D?
    @State var action: Int?
    @Binding var address: String?
    @Environment(\.dismiss) var dismiss
    var body: some View {
        
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    address = nil
                    dismiss()
                }) {
                    Text("창닫기")
                        
                }
                .padding(20)
            }
            if webViewModel.result == nil {
                WebView(url: "https://soletree.github.io/postNum/", viewModel: webViewModel)
                    .onDisappear {
                        locationManager.address = webViewModel.jibunAddress
                        Task {
                            guard let address = locationManager.address else { return }
                            self.address = locationManager.address
                            let coordinate = await addressToCoordinate(address: address)
                            self.coordinateList = coordinate
                            self.coordinate = CLLocationCoordinate2DMake(coordinate[0], coordinate[1])
                            action = 1
                        }
                    }
            }
            else {
                NavigationView {
                    NavigationLink(destination: MapViewSelection(locationManager: locationManager, coordinate: coordinate ?? CLLocationCoordinate2DMake(0, 0)), tag: 1, selection: $action) {}
                        
                }
                .navigationBarBackButtonHidden(true)
                
                
                Spacer()
                Text("핀을 꾹 눌러 위치를 이동시킬 수 있습니다.")
                    .foregroundColor(.gray)
                    .padding(.bottom)
                
                if locationManager.pickedPlacemark == nil {
                    Text(locationManager.address ?? "")
                } else { Text(returnPostalAddress(placemark: locationManager.pickedPlacemark!))}
                VStack {
                    CustomButton(style: .plain, action: {
                        guard let placemark = locationManager.pickedPlacemark else { return }
                        let latitude = placemark.location?.coordinate.latitude as? Double ?? 0
                        let longitude = placemark.location?.coordinate.longitude as? Double ?? 0
                        
                        self.coordinateList = [latitude, longitude]
                        
                        self.locationManager.address = returnPostalAddress(placemark: placemark)
                        self.address = self.locationManager.address
                        dismiss()
                    }).customButton
                }
                .padding(.horizontal, 30)
            }
            
        } // - VStack
        .onAppear {
            locationManager.manager.requestWhenInUseAuthorization()
        }
    }
    
    func returnPostalAddress(placemark: CLPlacemark) -> String {
        let formatter = CNPostalAddressFormatter()
        let addressString = formatter.string(from: placemark.postalAddress!)
        return addressString.replacingOccurrences(of: "\n", with: " ")
    }

}


//MARK: - addressToCoordinate
func addressToCoordinate(address: String) async -> [Double] {
    guard let coordinateString = await GeoCodingService.getCoordinateFromAddress(address: address)
    else { return [0.0, 0.0] }
    return [Double(coordinateString[0]) ?? 0.0, Double(coordinateString[1]) ?? 0.0]
    
} // - addressToCoordinate

