//
//  MyPageView.swift
//  CheckPlay
//
//  Created by sole on 2023/02/20.
//

import SwiftUI
import AlertToast
import GoogleMobileAds

struct MyPageMasterView: View {
    @EnvironmentObject var userStore: UserStore
    
    var name: String {
        userStore.currentUser?.name ?? "N/A"
    }
    
    var studentCode: String {
        userStore.currentUser?.studentCode ?? "N/A"
    }
    
    var composeMailData: ComposeMailData {
        .init(subject: "[문의하기]",
              recipients: [Bundle.main.object(forInfoDictionaryKey: "DEVELOPER_EMAIL") as? String ?? ""],
              message: "")
    }
    
    var versionInformation: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        return version
    }
    
    @State var isProcessing: Bool = false
    @State var isPresentedLogOutFailureToastAlert: Bool = false
    @State var toastAlertWithLogOut: AlertToast = .init(displayMode: .alert, type: .error(.red))
    
    @State var isPresentedConfirmLogOutAlert: Bool = false
    
    @State var isPresentedContactMailSheet: Bool = false
    @State var isAlertContactMail: Bool = false
    var body: some View {
        VStack {
            
            VStack(alignment: .leading) {
                Text("\(name)님")
                    .foregroundColor(.customGreen)
                    .font(.largeTitle.bold()) +
                Text(" (\(studentCode))")
                    .foregroundColor(.customLightGray)
                    .font(.title.bold())
                Text("환영합니다!")
                    .font(.largeTitle.bold())
                    .padding(.bottom, 15)
                
                
                sectionOfEditProfile
                sectionOfContact
                sectionOfLogOut
                sectionOfMasterMode
                
                // 버전 정보입니다.
                Divider()
                Text("버전 정보 v\(versionInformation)")
                    .font(.caption)
                    .foregroundColor(.customLightGray)
                
                
            } // - VStack
            .padding([.horizontal, .top], 20)
            
            Spacer()
            
            // 광고 섹션입니다.
            GoogleAdView()
                .frame(width: UIScreen.screenWidth, height: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.screenWidth).size.height)
                
           
        } // - VStack
        
        
        // ContactMailSheet입니다.
        .sheet(isPresented: $isPresentedContactMailSheet, content: {
            ContactMailView(data: .constant(composeMailData)) { result in
                print(result)
                switch result{
                case .success(let result):
                    print(result)
                case .failure(let error):
                    print("\(error.localizedDescription)")
                }
            }
        })
        .toast(isPresenting: $isPresentedLogOutFailureToastAlert) {
            toastAlertWithLogOut
        }
        .toast(isPresenting: $isProcessing) {
            AlertToast(displayMode: .alert, type: .loading)
        }
        .alert(
            "정말로 로그아웃하시겠어요?",
            isPresented: $isPresentedConfirmLogOutAlert
        ) {
            Button(role: .cancel, action: {}) {
                Text("취소")
            }
            Button(role: .destructive,
                   action: {
                userStore.isPresentedAdmin = false
                requestLogOut()
            }) {
                Text("로그아웃")
            }
        }
        .alert(isPresented: $isAlertContactMail) {
            Alert(title: Text("\(Bundle.main.object(forInfoDictionaryKey: "DEVELOPER_EMAIL") as? String ?? "")로 문의바랍니다."))
        }
        
    }
    
    //MARK: - Method(requestLogOut)
    func requestLogOut() {
        isProcessing = true
        let logOutResult = userStore.logOut()
        isProcessing = false
        // 로그아웃이 실패하면 알럿을 띄워줍니다.
        if !logOutResult {
            toastAlertWithLogOut.title = "로그아웃 실패"
            toastAlertWithLogOut.subTitle = "다시 시도해주세요."
            toastAlertWithLogOut.type = .error(.red)
        } else {
            toastAlertWithLogOut.title = "로그아웃되었습니다."
            toastAlertWithLogOut.type = .complete(.green)
        }
        isPresentedLogOutFailureToastAlert = true
    } // - requestLogOut
    
    //MARK: - View(sectionOfEditProfile)
    private var sectionOfEditProfile: some View {
        VStack(alignment: .leading) {
            NavigationLink(destination: EditProfileRouteView().environmentObject(userStore)) {
                Text("회원정보 수정")
                    .foregroundColor(.black)
            }
        } // - VStack
    } // - sectionOfEditProfile
    
    //MARK: - View(sectionOfContact)
    private var sectionOfContact: some View {
        VStack(alignment: .leading) {
            Divider()
            Button(action: {
                if ContactMailView.canSendMail {
                   isPresentedContactMailSheet = true
                } else {
                    isAlertContactMail = true
                }
            }) {
                Text("문의하기")
                    .foregroundColor(.black)
            }
        } // - VStack
    } // - sectionOfContact
    
    //MARK: - View(sectionOfLogOut)
    private var sectionOfLogOut: some View {
        VStack(alignment: .leading) {
            Divider()
            Button(action: {
                isPresentedConfirmLogOutAlert = true
            }) {
                Text("로그아웃하기")
                    .foregroundColor(.black)
            }
        } // - VStack
    } // - sectionOfLogOut
    
    private var sectionOfMasterMode: some View {
        VStack(alignment: .leading) {
            Divider()
            Button(action: {
                userStore.isPresentedAdmin = false
            }) {
                Text("일반 모드로 전환하기")
                    .foregroundColor(.black)
            }
        }
    }
    
}

