//
//  MemberMainView.swift
//  EwhaPlaygirls-admin
//
//  Created by sole on 2023/03/04.
//

import SwiftUI
import AlertToast
import GoogleMobileAds

struct MemberMasterMainView: View {
    @EnvironmentObject var memberStore: MemberMasterStore
    
    @State var members: [Member] = []
    
    @State var isPresentedAddMemberSheet: Bool = false
    @State var isPresentedAddMemberAlert: Bool = false
    @State var isPresentedEditMemberSheet: Bool = false
    @State var isPresentedEditMemberAlert: Bool = false
    
    
    @State var pickedMember: Member = .defaultModel
    
    @State var searchText: String = ""
    
    let filterStandard: [String] = ["학번순", "이름순", "명예졸업", "정식부원", "신입부원", "휴동"]
    @State var selectedStandard: String = "학번순"
    
    var body: some View {
        VStack {
            List {
                // 왜 member를 binding으로 바꿔야만 반영될까?
                ForEach(members, id: \.self.studentCode) { member in
                    MemberRow(member: .constant(member),
                              isPresentedEditMemberSheet: $isPresentedEditMemberSheet,
                              isPresentedEditMemberAlert: $isPresentedEditMemberAlert)
                    
                    // member row를 swipe시 나타나는 액션입니다.
                        .swipeActions {
                            Button(action: {
                                pickedMember = member
                        
                                isPresentedEditMemberSheet = true
                            }) {
                                Image(systemName: "square.and.pencil")
                            }
                            .tint(.orange)
                        }
                }
                
            }
            
            // 광고 부분입니다.
            GoogleAdView()
                .frame(width: UIScreen.main.bounds.width,
                       height: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width).size.height)
            
            .toolbar {
                Picker("", selection: $selectedStandard) {
                    ForEach(filterStandard, id: \.self) {
                        Text($0)
                            .foregroundColor(.customGreen)
                    }
                }
                .foregroundColor(.customGreen)
                
                Button(action: {
                    isPresentedAddMemberSheet = true
                }) {
                    Image(systemName: "plus")
                }
            }
            
            .navigationBarTitle("회원관리")
        } // - VStack
        .sheet(isPresented: $isPresentedAddMemberSheet) {
            if #available(iOS 16, *) {
                AddMemberMasterView(isPresentedAddMemberAlert: $isPresentedAddMemberAlert)
                    .environmentObject(memberStore)
                    .presentationDetents([.fraction(0.6)])
                    .presentationDragIndicator(.visible)
            } else {
                AddMemberMasterView(isPresentedAddMemberAlert: $isPresentedAddMemberAlert)
                    .environmentObject(memberStore)
            }
            
            
        }
        .sheet(isPresented: $isPresentedEditMemberSheet) {
            if #available(iOS 16, *) {
                EditMemberView(
                               isPresentedEditMemberSheet: $isPresentedEditMemberSheet,
                               isPresentedEditMemberAlert: $isPresentedEditMemberAlert,
                               member: $pickedMember)
                    .environmentObject(memberStore)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            } else {
                EditMemberView(
                               isPresentedEditMemberSheet: $isPresentedEditMemberSheet,
                               isPresentedEditMemberAlert: $isPresentedEditMemberAlert,
                               member: $pickedMember)
                    .environmentObject(memberStore)
                
            }
        }
        
        .toast(isPresenting: $isPresentedAddMemberAlert) {
            AlertToast(displayMode: .alert,
                       type: .complete(.green),
                       title: "회원 등록이 완료되었습니다.")
        }
        .toast(isPresenting: $isPresentedEditMemberAlert) {
            AlertToast(displayMode: .alert,
                       type: .complete(.green),
                       title: "변경 완료!")
        }
        .task {
            await memberStore.fetchMembers()
        }
        // 초기 뷰 세팅시 list에 memberstore를 업데이트하기 위해 작성했습니다.
        .onReceive(memberStore.$memberStore) { output in
            members = output
        }
        .refreshable {
            selectedStandard = filterStandard[0]
            Task {
                await memberStore.fetchMembers()
                members = memberStore.memberStore
            }
        }
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer,
            prompt: "검색어를 입력하세요"
        )
        .onChange(of: searchText, perform: { newValue in
            if newValue.isEmpty {
                members = memberStore.memberStore
            } else {
                members = memberStore.memberStore.filter({ member in
                    return member.name.contains(newValue)
                })
            }
        })
        .onChange(of: selectedStandard) { newValue in
            if newValue == "학번순" {
                members = memberStore.memberStore
                members.sort {
                    $0.studentCode < $1.studentCode
                }
            } else if newValue == "이름순" {
                members = memberStore.memberStore
                    members.sort {
                        $0.name < $1.name
                    }
            } else if newValue == "명예졸업" {
                members = memberStore.memberStore.filter { member in
                    member.memberStatus == .graduated
                }
            }
            else if newValue == "정식부원" {
                members = memberStore.memberStore.filter { member in
                    member.memberStatus == .official
                }
            }
            else if newValue == "신입부원" {
                members = memberStore.memberStore.filter { member in
                    member.memberStatus == .new
                }
            }
            else if newValue == "휴동" {
                members = memberStore.memberStore.filter { member in
                    member.memberStatus == .rest
                }
            }
            else {
                members = memberStore.memberStore
            }
        }
//        .onSubmit(of: .search) {
//            .filter { member in
//                member.name.contains(searchText)
//            }
//        }
    }
    
    //MARK: - Method(deleteMember)
    func deleteMember(atOffsets: IndexSet) async {
        let deletedMember = memberStore.memberStore[atOffsets.first!]
        memberStore.memberStore.remove(atOffsets: atOffsets)
        await memberStore.deleteMember(studentCode: deletedMember.studentCode)
    } // - deleteMember
}

struct MemberRow: View {
    @EnvironmentObject var memberStore: MemberMasterStore
    @Binding var member: Member
    
    // 다음 뷰에 넘겨주기 위해 바인딩 값으로 받습니다.
    @Binding var isPresentedEditMemberSheet: Bool
    @Binding var isPresentedEditMemberAlert: Bool
    
    var memberStatusColor: Color {
        switch member.memberStatus {
        case .new:
            return Color.green
        case.official:
            return Color.orange
        case .graduated:
            return Color.black
        case .rest:
            return Color.purple
        }
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("\(member.name) (\(member.studentCode))")
                Text("\(member.memberStatus.rawValue)")
                    .foregroundColor(memberStatusColor)
            }
        } // - VStack
//        .fullScreenCover(isPresented: $isPresentedEditMemberSheet){
      
    }
}


//MARK: - View(EditMemberView)
/// 멤버 정보를 변경할 수 있는 뷰입니다.
struct EditMemberView: View {
    let memberStatusList: [MemberStatus] = [.new, .official, .graduated, .rest]
    @EnvironmentObject var memberStore: MemberMasterStore
    
    @State var isProcessing: Bool = false
    
    @Binding var isPresentedEditMemberSheet: Bool
    @Binding var isPresentedEditMemberAlert: Bool
    
    @State var isPresentedDeleteMemeberAlert: Bool = false
    
    @Binding var member: Member
    @State var name: String = ""
    @State var memberStatus: MemberStatus = .new
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("회원 정보 변경")
                .font(.system(size: 32, weight: .semibold))
            
            VStack {
                CustomTextField(style: .plain, title: "이름", text: $name).customTextField
                
                Text("\(member.studentCode)")
                
                
                
                
                Picker("", selection: $memberStatus) {
                    ForEach(memberStatusList, id: \.self) {
                        Text($0.rawValue)
                            .foregroundColor(.customGreen)
                    }
                }
                .foregroundColor(.customGreen)
                
                CustomButton(style: .plain) {
                    member.name = name
                    member.memberStatus = memberStatus
                    memberStore.updateMember(member: member)
                    
                    Task {
                        await memberStore.fetchMembers()
                    }
                    
                    isPresentedEditMemberSheet = false
                    isPresentedEditMemberAlert = true
                }.customButton
                    .disable(isProcessing)
                
                // 멤버를 삭제하는 버튼입니다.
                Button(action: {
                    // 알럿 띄우기
                    isPresentedDeleteMemeberAlert = true
                }) {
                    Text("삭제하기")
                        .foregroundColor(.customGray)
                        .font(.system(size: 15))
                }
                
            }
        } // - VStack
        .disabled(isProcessing)
        .padding(10)
        .onAppear {
            name = member.name
            memberStatus = member.memberStatus
        }
        .toast(isPresenting: $isProcessing) {
            AlertToast(displayMode: .alert, type: .loading)
        }
        .alert("정말로 삭제하시겠어요?", isPresented: $isPresentedDeleteMemeberAlert) {
            Button(role: .cancel, action: {}) {
                Text("취소")
            }
            Button(role: .destructive, action: {
                // unregister user
                isProcessing = true
                Task {
                    guard await memberStore.deleteMember(studentCode: member.studentCode)
                    else {
                        // 오류 발생
                        isProcessing = false
//                        isPresentedEditMemberAlert = true
                        return
                    }
                    // fetch의 성공여부는 이 로직에서 크게 중요한 요소가 아니기에 성공여부에 따른 분기처리는 하지 않았습니다.
                    await memberStore.fetchMembers()
                    
                    isPresentedEditMemberSheet = false
                    isPresentedEditMemberAlert = true
                    isProcessing = false
                }
            }) {
                Text("삭제하기")
            }
        }
    }
    
} // - EditMemberView



