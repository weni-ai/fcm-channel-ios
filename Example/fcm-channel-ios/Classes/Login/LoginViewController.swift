//
//  LoginViewController.swift
//  fcm-channel-ios
//
//  Created by Rubens Pessoa on 25/09/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import fcm_channel_ios

class LoginViewController: UIViewController {

    @IBOutlet weak var tfURN: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func didTapRegisterBt(_ sender: Any) {
        let registerViewController = RegisterViewController()
        present(registerViewController, animated: true)
    }

    @IBAction func loginBtnPressed(_ sender: Any) {

        guard let urn = tfURN.text else {
            let alert = UIAlertController(title: "Erro", message: "URN vazia", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true)
            return
        }

        FCMClient.loadContact(fromUrn: urn) { contact in

            guard let contact = contact else {
                let alert = UIAlertController(title: "Erro", message: "Não foi possível carregar contato", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true)
                return
            }
            contact.fcmToken = FCMChannelManager.getFCMToken()

            if let name = contact.name, let urn = contact.urns.first, let token = contact.fcmToken {
                FCMClient.registerFCMContact(urn: urn, name: name, fcmToken: token, contactUuid: contact.uuid) { _, _ in}
            }

            User.current.contact = contact
            let chatVC = FCMChannelChatViewController(contact: contact, botName: "SANDBOX", loadMessagesOnInit: true)
            self.present(UINavigationController(rootViewController: chatVC), animated: true, completion: nil)

        }

//        LoginViewModel.shared.facebookLogin(from: self) {
//            (success, error) in
//
//            guard let contact = User.current.contact else { return }
//
//            if success {
//                let chatVC = FCMChannelChatViewController(contact: contact, botName: "SANDBOX", loadMessagesOnInit: true)
//                self.present(UINavigationController(rootViewController: chatVC), animated: true, completion: nil)
//            } else {
//                if let error = error {
//                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
//                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                    alertController.addAction(okayAction)
//                    self.present(alertController, animated: true, completion: nil)
//                } else {
//                    let alertController = UIAlertController(title: "Login Error", message: "Algum problema ocorreu durante o login. Por favor, tente novamente.", preferredStyle: .alert)
//                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                    alertController.addAction(okayAction)
//                    self.present(alertController, animated: true, completion: nil)
//                }
//            }
//        }
    }
}
