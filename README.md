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
pod 'fcm-channel-ios', :git => 'https://github.com/push-flow/fcm-channel-ios.git', :branch => 'feature/swift5'
```

## License

fcm-channel-ios is available under the AGPL-3.0 license. See the LICENSE file for more info.


## How to use

Before making any Push calls or using the chat view, configure the fcm-channel by calling:

`FCMClient.setup("<push authorization token>", channel: "<channel id>", url: "<push url(optional)>")`

Replace the values in brackets with their appropriate values.
FCMClient is responsible for making calls to Push API.

You'll have to notify Push when new messages arrive via push notifications. Add this piece of code to AppDelegate:
~~~~
@available(iOS 10.0, *)
func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    //Enter on touch notification
    let userInfo = response.notification.request.content.userInfo
    if FCMChannelContact.current() != nil {
        var notificationType: String? = nil

        if let type = userInfo["type"] as? String {
            notificationType = type
        } else if let type = userInfo["gcm.notification.type"] as? String {
            notificationType = type
        }

        guard let type = notificationType else { return }

        switch type {
            case "rapidpro":
                let application = UIApplication.shared
                if application.applicationState != .active {
                    application.applicationIconBadgeNumber = 1
                }
                NotificationCenter.default.post(name: Notification.Name(rawValue: "newMessageReceived"), object: userInfo)
            default:
                break
        }
    }
}
~~~~

## API call methods:

These methods can be called from FCMClient.

### Flow

`open class func getFlowDefinition(_ flowUuid: String, completion: @escaping (FCMChannelFlowDefinition?) -> Void)`

`open class func getFlowRuns(_ contact: FCMChannelContact, completion: @escaping ([FCMChannelFlowRun]?) -> Void)`

### Messages
`open class func sendReceivedMessage(_ contact: FCMChannelContact, message: String, completion: @escaping (_ success: Bool) -> Void)`

`open class func loadMessages(contact: FCMChannelContact, completion: @escaping (_ messages:[FCMChannelMessage]?) -> Void )`

`open class func loadMessageByID(_ messageID: Int, completion: @escaping (_ message: FCMChannelMessage?) -> Void ) `

### Contact
`open class func loadContact(fromUrn urn: String, completion: @escaping (_ contact: FCMChannelContact?) -> Void) `

`open class func fetchContact(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) `

`open class func registerFCMContact(_ contact: FCMChannelContact, completion: @escaping (_ uuid: String?, _ error: Error?) -> Void) `

`open class func savePreferedLanguage(_ language:String) `

`open class func getPreferedLanguage() -> String`


