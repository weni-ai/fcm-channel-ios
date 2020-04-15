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

        FCMClient.loadContact(fromUrn: "fcm:\(urn)") { contact, error in
            if let error = error {
                let alert = UIAlertController(title: "Erro", message: error.localizedDescription, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true)
                return
            }

            guard let contact = contact else {
                return
            }

            contact.fcmToken = FCMChannelManager.getFCMToken()

            if let name = contact.name, let urn = contact.urn, let token = contact.fcmToken {
                FCMClient.registerFCMContact(urn: urn, name: name, fcmToken: token, contactUuid: contact.uuid) { _, _ in}
            }

            User.current.contact = contact
            let chatVC = FCMChannelChatViewController(contact: contact, botName: "SANDBOX", loadMessagesOnInit: true)
            self.present(UINavigationController(rootViewController: chatVC), animated: true, completion: nil)
        }
    }
}
