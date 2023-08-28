//
//  LoginStore.swift
//  CheckPlay
//
//  Created by sole on 2023/02/27.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

enum SignUpError: Error {
    case invalidEmailFormat // 유효하지 않은 이메일 형식
    case duplicatedEmail // 중복된 이메일
    case invalidStudentCode // 검증되지 않은 학번
    case unsafetyPassword // 안전하지 않은 비밀번호
    case alreadySigned // 이미 가입한
    case unknown // 알 수 없는 오류
}


class UserStore: ObservableObject {
    let database = Firestore.firestore()
    
    /// 로그인한 상태인지 아닌지 판별하는 변수입니다. 로그인시 true로 설정됩니다.
    @Published var isLogin: Bool = false
    
    /// 로그인과 관련된 작업이 진행중일 때 true로 설정됩니다.
    /// isLoginProcessing이 true일 때 뷰에서 다른 action이 일어나지 못하도록 막습니다.
    @Published var isLoginProcessing: Bool = false
    
    /// 현재 로그인된 유저의 정보를 담습니다.
    @Published var currentUser: User?
    
    /// UserStore에서 관련된 로직을 처리하다가 에러가 발생하면 true로 설정됩니다.
    @Published var isError: Bool = false
    
    /// 관리자 모드로 전환하는지 확인하는 Bool 값입니다.
    @Published var isPresentedAdmin: Bool = false
    
    
    /// 회원가입 로직을 처리하는 메서드입니다.
    func signUp(email: String,
                password: String,
                name: String,
                studentCode: String) async -> Bool {
        
        let firebaseSignUpResult = await firebaseSignUp(email: email, password: password)
        
        // 파이어베이스 회원가입
        switch firebaseSignUpResult {
            //성공했으면
        case .success(let result):
            // db에 유저를 등록합니다.
            let newUser: User = .init(id: result.user.uid, studentCode: studentCode, name: name, email: email)
            if await !addUserToDatabase(user: newUser)
            { return false }
            return true
            // 실패했으면 오류를 반환합니다.
        case .failure(_):
            return false
        }
//        return .failure(.alreadySigned)
        // 파이어베이스 회원가입
    }
    
    //MARK: - Method(signUp)
    /// 파이어베이스를 통한 회원가입 메서드입니다.
    /// 반환값: 회원가입 성공 여부 (Bool)
    func firebaseSignUp(email: String,
                        password: String) async -> Result<AuthDataResult, SignUpError> {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            return .success(result)
        } catch {
            print("\(error.localizedDescription)")
            return .failure(.unsafetyPassword)
        }
    } // - signUp
    
    //MARK: - Method(isEmailInDatabase)
    /// 이메일 중복확인 메서드입니다.
    /// 반환값: 이메일 중복여부(Bool) 중복시 true 반환
    func isValidEmail(email: String) async -> Bool {
        // 이메일이 이메일의 format을 만족하는지 확인합니다.
        if !email.isValidEmailFormat() { return false }
        
        // 이메일의 중복여부를 확인합니다.
        do {
            let snapshot = try await database.collection("User")
                .whereField(UserConstant.userEmail, isEqualTo: email)
                .getDocuments()
            
            if snapshot.documents.isEmpty { return true }
            else { return false }
            
        } catch {
            print("\(error.localizedDescription)")
            return false
        }
    } // - isEmailInDatabase
    
    //MARK: - Method(verifyStudentCode)
    /// db 상에 등록된 학번과 이름인지 검증하는 메서드입니다.
    /// 반환값: 검증 완료 여부 (검증되었으면 true 반환)
    func isValidStudentCode(name: String,
                            studentCode: String) async -> Bool {
        guard !studentCode.isEmpty else { return false }
        do {
            let document = try await database.collection("Member").document("\(studentCode)")
                .getDocument()
            
            // db 상에 존재하는 학번인지 검증
            if !document.exists { return false }
            // 등록된 학번과 매치되는 이름인지 검증
            if name != document[UserConstant.userName] as? String ?? "N/A" {
                return false
            }
            
            // 이미 가입된 학번인지 확인
            let snapshot = try await database.collection("User")
                .whereField(UserConstant.userStudentCode, isEqualTo: studentCode)
                .getDocuments()
            
            // 이미 가입된 학번임
            if !snapshot.documents.isEmpty { return false }

            return true
        } catch {
            print("\(error.localizedDescription)")
            return false
        }
    } // - isValidStudentCode
    
    //MARK: - Method(addUserToDatabase)
    /// 파이어베이스스토어에 유저를 등록하는 메서드입니다.
    func addUserToDatabase(user: User) async -> Bool {
        do {
            try await database.collection("User")
                .document("\(user.id)")
                .setData([
                    UserConstant.userID : user.id,
                    UserConstant.userStudentCode: user.studentCode,
                    UserConstant.userEmail : user.email,
                    UserConstant.userName : user.name
                ])
            return true
        } catch {
            print("\(error.localizedDescription)")
            return false
        }
    } // - addUserToDatabase
    
    
    //MARK: - Method(login)
    /// FirebaseAuth를 통해 로그인하는 메서드입니다.
    /// 반환값: 로그인 성공 여부 (Bool)
    func logIn(email: String,
               password: String) async -> Bool {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            
            // 유저 fetch에 실패하면 로그인 실패
            let fetchResult = await fetchUser(uid: authResult.user.uid)
            if fetchResult {
                DispatchQueue.main.async {
                    self.isLogin = true
                }
                return true
            }
            else { return false }
        } catch {
            print("\(error.localizedDescription)")
            return false
        }
    } // - login
    
    
    //MARK: - Method(fetchUser)
    /// 유저의 uid로 데이터베이스에서 User data를 fetch합니다.
    /// 반환값: 유저 fetch 성공 여부 (Bool)
    func fetchUser(uid: String) async -> Bool {
        do {
            let document = try await database.collection("User")
                .document("\(uid)")
                .getDocument()
            let id = document[UserConstant.userID] as? String ?? ""
            let studentCode = document[UserConstant.userStudentCode] as? String ?? ""
            let name = document[UserConstant.userName] as? String ?? ""
            let email = document[UserConstant.userStudentCode] as? String ?? ""
            
            DispatchQueue.main.async {
                self.currentUser = .init(id: id, studentCode: studentCode, name: name, email: email)
            }
            
            return true
        } catch {
            print("\(error.localizedDescription)")
            return false
        }
    } // - fetchUser
    
    
    //MARK: - Method(logOut)
    /// 로그아웃 메서드입니다.
    func logOut() -> Bool {
        do {
            try Auth.auth().signOut()
            isLogin = false
            currentUser = nil
            return true
        } catch {
            print("\(error.localizedDescription)")
            return false
        }
    } // - logOut
    
    //MARK: - Method(relogInAndReauthentication)
    func relogInAndReauthentication(password: String) async -> Bool {
        guard let user = Auth.auth().currentUser
        else { return false }
        
        do {
            try await Auth.auth().signIn(withEmail: user.email ?? DefaultValue.defaultString, password: password)
                
            return true
        } catch {
            print("\(error.localizedDescription)")
            return false
        }
    } // - relogInAndReauthentication
    
    //MARK: - Method
    func updatePassword(updatedPassword: String) async -> Bool {
        guard let user = Auth.auth().currentUser else { return false }
        
        do {
            // password 정규식에 맞는지 확인
    
            try await user.updatePassword(to: updatedPassword)
            return true
        } catch {
            print("\(error.localizedDescription)")
            return false
        }
    } // - updatePassword
    
    func verifyEmail() async {
        guard let currentUser = Auth.auth().currentUser
        else { print("current user가 없습니다."); return }
        do {
            try await currentUser.sendEmailVerification()
            
        } catch {
            print("\(error.localizedDescription)")
        }
        
    }
    
    /// 회원탈퇴가 성공적으로 이루어지면 true를 반환합니다.
    func deleteUser() async -> Bool {
        guard let user = Auth.auth().currentUser else { return false }
        do {
            // Authentication에서 삭제
            try await Auth.auth().currentUser?.delete()
            
            // User collection에서 삭제
            try await database.collection("User")
                .document(user.uid)
                .delete()
            
            return true
            
        } catch {
            print("\(error.localizedDescription )")
            return false
        }
            
    } // - deleteUser
}


extension String {
    /// 이메일이 format에 맞는지 판별하는 메서드입니다.
    /// - return: format에 맞는 이메일이면 true를 반환합니다.
    func isValidEmailFormat() -> Bool {
        // 이메일 정규식입니다.
        let emailRegex =  "^([a-zA-Z0-9._-])+@[a-zA-Z0-9.-]+.[a-zA-Z]{3,20}$"
        return self.range(of: emailRegex, options: .regularExpression) != nil
    }
    
    /// 비밀번호가 format에 맞는지 판별하는 메서드입니다.
    /// 8~50자 이내 
    /// - return: format에 맞는 비밀번호면 true를 반환합니다.
    func isValidPasswordFormat() -> Bool {
        // 비밀번호 정규식입니다.
        let passwordRegex = "^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{6,50}$"
        return self.range(of: passwordRegex, options: .regularExpression) != nil
    }
}
