//
//  SignUpViewController.swift
//  LoginExample-Combine+MVVM
//
//  Created by 안정흠 on 2023/04/18.
//

import UIKit
import Combine

final class SignUpViewController: UIViewController {
    
    @IBOutlet weak var signUpButton: UIButton!
    
    let vm = SignViewModel()
    private let input: PassthroughSubject<SignViewModel.Input, Never> = .init()
    private var bag = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        input.send(.viewApear(type: .signUp))
    }
    
    private func bind() {
        let output = vm.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .toggleButton(let isEnable):
                    self?.signUpButton.isEnabled = isEnable
                case .signUpButtonTapped:
                    self?.showAlert()
                default: break
                }
            
            }
            .store(in: &bag)
        
    }
    
    @IBAction func againFieldChanged(_ sender: UITextField) {
        guard let text = sender.text else { return }
        input.send(.idTextChanged(id: text))
    }
    @IBAction func passwordFieldChanged(_ sender: UITextField) {
        guard let text = sender.text else { return }
        input.send(.passwordTextChanged(password: text))
    }
    @IBAction func idFieldChanged(_ sender: UITextField) {
        guard let text = sender.text else { return }
        input.send(.againTextChanged(again: text))
    }
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        input.send(.signUpButtonTapped)
    }
}

extension SignUpViewController {
    private func showAlert() {
        let alert = UIAlertController(title: "회원가입 완료", message: "로그인 화면에서 로그인 해주세요", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        }))
        present(alert, animated: true)
    }
}
