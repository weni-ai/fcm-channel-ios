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
    
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {

        LoginViewModel.shared.facebookLogin(from: self) {
            (success, error) in

            guard let contact = User.current.contact else { return }

            if success {
                let chatVC = FCMChannelChatViewController(contact: contact, botName: "SANDBOX", loadMessagesOnInit: true)
                self.present(UINavigationController(rootViewController: chatVC), animated: true, completion: nil)
            } else {
                if let error = error {
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: "Login Error", message: "Algum problema ocorreu durante o login. Por favor, tente novamente.", preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}
