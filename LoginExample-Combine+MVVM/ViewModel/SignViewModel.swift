//
//  SignViewModel.swift
//  LoginExample-Combine+MVVM
//
//  Created by 안정흠 on 2023/04/18.
//

import Foundation
import Combine

final class SignViewModel {
    enum Input {
        case viewApear
        case idTextChanged(id: String)
        case passwordTextChanged(password: String)
        case againTextChanged(again: String)
        case signInButtonTapped
        case signUpButtonTapped
    }
    enum Output {
        case toggleButton(isEnable: Bool)
        case signUpButtonTapped
        case signInButtonTapped
    }
    
    private var bag = Set<AnyCancellable>()
    private let output: PassthroughSubject<Output, Never> = .init()
    
    private var userID: PassthroughSubject<String, Never> = .init()
    private var userPassword: PassthroughSubject<String, Never> = .init()
    private var againPassword: PassthroughSubject<String, Never> = .init()
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .viewApear:
                    self?.signInCheck()
                    self?.signUpCheck()
                case .idTextChanged(let id):
                    self?.userID.send(id)
                case .passwordTextChanged(let password):
                    self?.userPassword.send(password)
                case .againTextChanged(let again):
                    self?.againPassword.send(again)
                case .signInButtonTapped:
                    self?.signInButtonTapped()
                case .signUpButtonTapped:
                    self?.signUpButtonTapped()
                }
            }
            .store(in: &bag)
        return output.eraseToAnyPublisher()
    }
    
    private func signInCheck() {
        output.send(.toggleButton(isEnable: false))
        userID.combineLatest(userPassword) { id, password in
            if id.count >= 5 && password.count >= 5 {
                return true
            }
            return false
        }
        .sink { [weak self] isEnable in
            self?.output.send(.toggleButton(isEnable: isEnable))
        }
        .store(in: &bag)
    }
    
    private func signUpCheck() {
        userID
            .combineLatest(userPassword, againPassword) { again, password, id in
                if id.count >= 5 && password.count >= 5 && password.elementsEqual(again) {
                    return true
                }
                return false
            }
            .sink { [weak self] isEnable in
                self?.output.send(.toggleButton(isEnable: isEnable))
            }
            .store(in: &bag)
    }
    
    private func signUpButtonTapped() {
        //유저 정보 저장
        output.send(.signUpButtonTapped)
    }
    private func signInButtonTapped() {
        //유저 정보 확인
        output.send(.signInButtonTapped)
    }
}
