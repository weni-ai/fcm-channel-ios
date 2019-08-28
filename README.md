# FCM Channel iOS

FCM Channel iOS is a client library for [Push](http://push.al) platform that can be used inside iOS apps to enable users receive and send messages through Firebase Cloud Messaging channel.

[![CI Status](http://img.shields.io/travis/rubenspessoa/fcm-channel-ios.svg?style=flat)](https://travis-ci.org/rubenspessoa/fcm-channel-ios)
[![Version](https://img.shields.io/cocoapods/v/fcm-channel-ios.svg?style=flat)](http://cocoapods.org/pods/fcm-channel-ios)
[![License](https://img.shields.io/cocoapods/l/fcm-channel-ios.svg?style=flat)](http://cocoapods.org/pods/fcm-channel-ios)
[![Platform](https://img.shields.io/cocoapods/p/fcm-channel-ios.svg?style=flat)](http://cocoapods.org/pods/fcm-channel-ios)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

fcm-channel-ios is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'fcm-channel-ios', :git => 'https://github.com/push-flow/fcm-channel-ios.git', :branch => 'master'
```

## License

fcm-channel-ios is available under the AGPL-3.0 license. See the LICENSE file for more info.


## How to use

### Firebase Notifications Config:
Make sure that you have a working Firebase project and that your app is setup correctly to receive notifications via FCM. More information can be found [here](https://firebase.google.com/docs/cloud-messaging/ios/client)

### Configure Messages:
Before making any Push calls or using the chat view, configure the fcm-channel by calling:

`FCMClient.setup("<push authorization token>", channel: "<channel id>", url: "<push url(optional)>")`

Replace the values in brackets with their appropriate values.
FCMClient is responsible for making calls to Push API.

You'll have to notify FCMChannel library when new messages arrive. This will be done using Firebase.
In AppDelegate, add this piece of code to application(_ , didFinishLaunchingWithOptions):

~~~~
    FirebaseApp.configure()
    Messaging.messaging().delegate = self
    Messaging.messaging().shouldEstablishDirectChannel = true
~~~~

Add this to your MessagingDelegate class:

~~~~
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        var notificationType: String? = nil
        
        if let type = userInfo["type"] as? String {
            notificationType = type
        } else if let type = userInfo["gcm.notification.type"] as? String {
            notificationType = type
        }
        
        guard let type = notificationType else {
            return
        }
        
        switch type {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "newMessageReceived"), object: userInfo)
        default:
            break
        }
    }
~~~~

### Configure contact:

When Firebase returns a refreshed FCM token, you'll need to update this on your Push contact.
Call function:

~~~~
    registerFCMContact(urn: String, name: String, fcmToken: String, contactUuid: String? = nil, completion: @escaping (_ uuid: String?, _ error: Error?) -> Void)    
~~~~

with the correct contact info including contact uuid and the refreshed token.


This will notify FCMChannel library when messages from RapidPro arrive.

## API call methods:

These methods can be called from FCMClient.

### Flow

`getFlowDefinition(flowUuid: String, completion: @escaping (FCMChannelFlowDefinition?, _ error: Error?) -> Void)`

`getFlowRuns(contactId: String, completion: @escaping ([FCMChannelFlowRun]?, _ error: Error?) -> Void)`

### Messages

`sendReceivedMessage(urn: String, token: String, message: String, completion: @escaping (_ error: Error?) -> Void)`

`loadMessages(contactId: String, completion: @escaping (_ messages: [FCMChannelMessage]?, _ error: Error?) -> Void )`

`loadMessageByID(_ messageID: Int, completion: @escaping (_ message: FCMChannelMessage?, _ error: Error?) -> Void )`

### Contact

`loadContact(fromUrn urn: String, completion: @escaping (_ contact: FCMChannelContact?, _ error: Error?) -> Void)`

`loadContact(fromUUID uuid: String, completion: @escaping (_ contact: FCMChannelContact?, _ error: Error?) -> Void)`

`registerFCMContact(urn: String, name: String, fcmToken: String, contactUuid: String? = nil, completion: @escaping (_ uuid: String?, _ error: Error?) -> Void)`

`savePreferedLanguage(_ language: String)`

`getPreferedLanguage() -> String`


