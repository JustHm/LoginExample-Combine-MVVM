//
//  ViewController.swift
//  LoginExample-Combine+MVVM
//
//  Created by 안정흠 on 2023/04/18.
//

import UIKit
import Combine

final class SignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var signInButton: UIButton!
    
    private let vm = SignViewModel()
    private let input: PassthroughSubject<SignViewModel.Input, Never> = .init()
    private var bag = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        input.send(.viewApear)
    }
    
    private func bind() {
        let output = vm.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .toggleButton(let isEnable):
                    self?.signInButton.isEnabled = isEnable
                case .signInButtonTapped:
                    self?.showAlert()
                default: break
                }
            }
            .store(in: &bag)
    }

    @IBAction func passwordFieldChanged(_ sender: UITextField) {
        guard let text = sender.text else { return }
        input.send(.passwordTextChanged(password: text))
    }
    @IBAction func idTextFieldChanged(_ sender: UITextField) {
        guard let text = sender.text else { return }
        input.send(.idTextChanged(id: text))
    }
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        input.send(.signInButtonTapped)
    }
}

extension SignInViewController {
    private func showAlert() {
        let alert = UIAlertController(title: "로그인 성공", message: "성공", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
