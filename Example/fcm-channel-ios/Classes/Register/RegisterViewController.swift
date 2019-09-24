//
//  RegisterViewController.swift
//  fcm-channel-ios_Example
//
//  Created by Alexandre Azevedo on 22/04/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding
import fcm_channel_ios

class RegisterViewController: UIViewController {

    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfUrn: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func ddTapRegisterBt(_ sender: Any) {
        guard let fcmToken = FCMChannelManager.getFCMToken(),
            let name = tfName.text,
            let urn = tfUrn.text,
            urn != "",
            name != "" else { return }

        FCMClient.registerFCMContact(urn: urn, name: name, fcmToken: fcmToken) { uuid, error in

            guard let uuid = uuid else {
                let alert = UIAlertController(title: "Erro", message: "Erro ao criar contato", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true)
                return
            }

            FCMClient.loadContact(fromUUID: uuid) { (contact, error) in

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
                User.current.contact = contact
                let chatVC = FCMChannelChatViewController(contact: contact, botName: "SANDBOX", loadMessagesOnInit: true)
                self.present(UINavigationController(rootViewController: chatVC), animated: true, completion: nil)
            }
        }
    }
}
