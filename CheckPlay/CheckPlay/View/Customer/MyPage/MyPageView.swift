//
//  MyPageView.swift
//  CheckPlay
//
//  Created by sole on 2023/02/20.
//

import SwiftUI
import AlertToast

struct MyPageView: View {
    @EnvironmentObject var userStore: UserStore
    @StateObject var alertViewModel: AlertViewModel = .init()
    var user: User {
        userStore.currentUser ?? .defaultModel
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
    @State var isPresentedEditProfileView: Bool = false
    @State var isPresentedConfirmLogOutAlert: Bool = false
    
    @State var isPresentedContactMailSheet: Bool = false
    @State var isAlertContactMail: Bool = false
    
    var body: some View {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    HStack(spacing: 10) {
                        Text("\(user.name)님")
                            .pretendard(size: .xxl,
                                        weight: .semibold)
                            .foregroundStyle(Color.brandColor)
                        Image(systemName: "baseball.fill")
                            .resizable()
                            .frame(width: 30,
                                   height: 30)
                            .foregroundStyle(Color.gray100)
                            .background(Color.yellow)
                            .clipShape(Circle())
                        
                        Spacer()
                    }
                    Text("안녕하세요!")
                        .pretendard(size: .xl,
                                    weight: .semibold)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                .background(Color.subColor300)
                
                Group {
                    sectionOfEditProfile
                    sectionOfContact
                    sectionOfLogOut
                }
                .padding(.horizontal, 20)
                
                Divider()
                // 버전 정보입니다.
                HStack {
                    Spacer()
                    Text("버전 정보 v\(versionInformation)")
                        .pretendard(size: .xxs,
                                    weight: .light)
                        .foregroundStyle(Color.gray300)
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 20)
                
                Spacer()
            } // - VStack
            .navigationDestination(isPresented: $isPresentedEditProfileView) {
                EditProfileView()
                .environmentObject(userStore)
            }
        
        // ContactMailSheet입니다. 
        .sheet(isPresented: $isPresentedContactMailSheet, content: {
            ContactMailView(data: .constant(composeMailData)) { result in
                switch result{
                case .success(let result):
                    print(result)
                case .failure(let error):
                    print("\(error.localizedDescription)")
                }
            }
        })
        .toast(isPresenting: $alertViewModel.isError) {
            alertViewModel.errorAlert
        }
        .toast(isPresenting: $alertViewModel.isProcessing) {
            alertViewModel.loadingAlert
        }
        .alert(
            "정말로 로그아웃하시겠어요?",
            isPresented: $isPresentedConfirmLogOutAlert
        ) {
            Button(role: .cancel, action: {}) {
                Text("취소")
            }
            Button(role: .destructive,
                   action: { requestLogOut() }) {
                Text("로그아웃")
            }
        }
        .alert(isPresented: $isAlertContactMail) {
            Alert(title: Text("\(Bundle.main.object(forInfoDictionaryKey: "DEVELOPER_EMAIL") as? String ?? "")로 문의바랍니다."))
        }
    }
    
    //MARK: - Method(requestLogOut)
    func requestLogOut() {
        alertViewModel.isProcessing = true
        let logOutResult = userStore.logOut()
        alertViewModel.isProcessing = false
        
        // 로그아웃이 실패하면 알럿을 띄워줍니다.
        if !logOutResult {
            let title = "로그아웃에 실패했어요"
            let subtitle = "다시 시도해주세요."
            alertViewModel.setErrorTitle(title: title,
                                         subTitle: subtitle)
            alertViewModel.isError = true
        } else {
            let title = "로그아웃했어요!"
            alertViewModel.isComplete = true
        }
    } // - requestLogOut
    
    //MARK: - View(sectionOfEditProfile)
    private var sectionOfEditProfile: some View {
        HStack {
            Text("회원정보 수정")
                .pretendard(size: .s,
                            weight: .regular)
                .foregroundStyle(Color.black)
            Spacer()
        } // - HStack
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            isPresentedEditProfileView = true
        }
    } // - sectionOfEditProfile
    
    //MARK: - View(sectionOfContact)
    private var sectionOfContact: some View {
        HStack {
            Text("문의하기")
                .pretendard(size: .s,
                            weight: .regular)
                .foregroundStyle(Color.black)
            Spacer()
        } // - HStack
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            if ContactMailView.canSendMail {
               isPresentedContactMailSheet = true
            } else {
                isAlertContactMail = true
            }
        }
    } // - sectionOfContact
    
    //MARK: - View(sectionOfLogOut)
    private var sectionOfLogOut: some View {
        HStack {
            Text("로그아웃")
                .pretendard(size: .s,
                            weight: .regular)
                    .foregroundStyle(Color.black)
            Spacer()
        } // - VStack
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            isPresentedConfirmLogOutAlert = true
        }
    } // - sectionOfLogOut
}

#Preview {
    MyPageView()
        .environmentObject(UserStore())
}
