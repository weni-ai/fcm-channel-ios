//
//  RestServices.swift
//  fcm-channel-ios
//
//  Created by Alexandre Azevedo on 03/04/19.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

class RestServices {
    static var shared = RestServices()

    private var headers: HTTPHeaders {
        let token = FCMChannelSettings.shared.token
        return ["Authorization": "Token \(token)",
            "Accept": "application/json"]
    }

   private init() {}

    // MARK: - Flow
   func getFlowDefinition(flowUuid: String, completion: @escaping (FCMChannelFlowDefinition?, _ error: Error?) -> Void) {

        let url = "\(FCMChannelSettings.shared.url)\(FCMChannelSettings.shared.V2)definitions.json?flow=\(flowUuid)"

        Alamofire.request(url, method: .get,
                   encoding: JSONEncoding.default,
                   headers: headers).responseObject { (response: DataResponse<FCMChannelFlowDefinition>) in

            switch response.result {

            case .failure(let error):
                print(error.localizedDescription)
                completion(nil, error)

            case .success(let value):
                completion(value, nil)
            }
        }
    }

    func getFlowRuns(contactId: String, completion: @escaping ([FCMChannelFlowRun]?, _ error: Error?) -> Void) {

        guard let minimumDate = getMinimumDate() else {
            completion(nil, FCMChannelError.defaultError(message: "Data não encontrada"))
            return
        }

        let afterDate = FCMChannelDateUtil.dateFormatter(minimumDate)
        let url = "\(FCMChannelSettings.shared.url)\(FCMChannelSettings.shared.V2)runs.json?contact=\(contactId)&after=\(afterDate)"

        Alamofire.request(url,
                          method: .get,
                          encoding: JSONEncoding.default,
                          headers: headers).responseObject { (response: DataResponse<APIResponse<FCMChannelFlowRun>>) in

                            switch response.result {

                            case .failure(let error):
                                print(error.localizedDescription)
                                completion(nil, error)

                            case .success(let value):
                                if let results = value.results, !results.isEmpty {
                                    completion(value.results, nil)
                                } else {
                                    completion(nil, FCMChannelError.defaultError(message: nil))
                                }
                            }
        }
    }

    // MARK: - Messages
    func sendReceivedMessage(urn: String, token: String, message: String, completion:@escaping (_ error: Error?) -> Void) {
        let handlerUrl = FCMChannelSettings.shared.handlerURL
        let channel = FCMChannelSettings.shared.channel

        var formattedUrn = urn
        if urn.starts(with: "fcm:") {
            formattedUrn = String(formattedUrn.dropFirst(4))
        }

        let params = [
            "from": formattedUrn,
            "msg": message,
            "fcm_token": token
        ]

        let url = "\(handlerUrl)\(channel)/receive/"
        Alamofire.request(url, method: .post, parameters: params).responseString { (response) in

            switch response.result {

            case .failure(let error):
                print("error \(String(describing: error.localizedDescription))")
                completion(error)

            case .success(let value):
                print(value)
                completion(nil)
            }
        }
    }

    func loadMessages(contactId: String, completion: @escaping (_ messages: [FCMChannelMessage]?, _ error: Error?) -> Void ) {

        let url = "\(FCMChannelSettings.shared.url)\(FCMChannelSettings.shared.V2)messages.json?contact=\(contactId)"

        Alamofire.request(url, method: .get,
                   encoding: JSONEncoding.default,
                   headers: headers).responseObject { (response: DataResponse<APIResponse<FCMChannelMessage>>) in

                    switch response.result {

                    case .failure(let error):
                        print(error.localizedDescription)
                        completion(nil, error)

                    case .success(let value):
                        if let results = value.results {
                            completion(results, nil)
                        } else {
                            completion(nil, FCMChannelError.defaultError(message: nil))
                        }
                    }
        }
    }

    func loadMessageByID(_ messageID: Int, completion: @escaping (_ message: FCMChannelMessage?, _ error: Error?) -> Void ) {

        let url = "\(FCMChannelSettings.shared.url)\(FCMChannelSettings.shared.V2)messages.json?id=\(messageID)"

        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseObject { (response: DataResponse<APIResponse<FCMChannelMessage>>) in

            switch response.result {

            case .failure(let error):
                print(error.localizedDescription)
                completion(nil, error)

            case .success(let value):
                if let results = value.results, !results.isEmpty {
                    completion(results.first, nil)
                } else {
                    completion(nil, FCMChannelError.notFound(message: "Não foi possível encontrar mensagem"))
                }
            }
        }
    }

    // MARK: - Contact

    private func loadContact(fromURL url: URL, completion: @escaping (_ contact: FCMChannelContact?, _ error: Error?) -> Void) {
        Alamofire.request(url,
                          method: .get,
                          encoding: URLEncoding.default,
                          headers: headers)
            .responseJSON { (response: DataResponse<Any>) in

                if let response = response.result.value as? [String: Any] {
                    guard let result = (response["results"] as? [[String: Any]])?.first else {
                        completion(nil, FCMChannelError.notFound(message: response["detail"] as? String))
                        return
                    }

                    let contact = Mapper<FCMChannelContact>().map(JSON: result)

                    if let contact = contact {
                        if contact.fcmToken == nil {
                            contact.fcmToken = ""
                        }
                        completion(contact, nil)
                    } else {
                        completion(contact, FCMChannelError.mappingError)
                    }
                }
        }
    }

    func loadContact(fromUUID uuid: String, completion: @escaping (_ contact: FCMChannelContact?, _ error: Error?) -> Void) {
        let url: URL! = URL(string: "\(FCMChannelSettings.shared.url)\(FCMChannelSettings.shared.V2)contacts.json?uuid=\(uuid)")
        loadContact(fromURL: url, completion: completion)
    }

    func loadContact(fromUrn urn: String, completion: @escaping (_ contact: FCMChannelContact?, _ error: Error?) -> Void) {
        let url: URL! = URL(string: "\(FCMChannelSettings.shared.url)\(FCMChannelSettings.shared.V2)contacts.json?urn=\(urn)")
        loadContact(fromURL: url, completion: completion)
    }

    func fetchContact(completion: @escaping (_ error: Error?) -> Void) {
        guard let contact = FCMChannelContact.current(), let urn = contact.urn else {
            completion(FCMChannelError.noContact)
            return
        }

        let url = "\(FCMChannelSettings.shared.url)\(FCMChannelSettings.shared.V2)contacts.json?urn=\(urn)"

        Alamofire.request(url, method: .get, headers: headers).responseJSON { (response: DataResponse<Any>) in

            if let responseValue = response.result.value as? [String: Any] {
                guard let results = responseValue["results"] as? [[String: Any]], results.count > 0 else {
                    completion(FCMChannelError.notFound(message: (response.result.value as? [String: String])?["detail"]))
                    return
                }

                guard let data = results.first else {
                    completion(FCMChannelError.notFound(message: "Nenhum contato encontrado"))
                    return
                }

                guard let contact = Mapper<FCMChannelContact>().map(JSONObject: data) else {
                    completion(response.result.error)
                    return
                }

                FCMChannelContact.setActive(contact: contact)
                completion(nil)
            } else if let error = response.result.error {
                completion(error)
            }
        }
    }

    func registerFCMContact(urn: String, name: String, fcmToken: String, contactUuid: String? = nil, completion: @escaping (_ uuid: String?, _ error: Error?) -> Void) {

        let url = "\(FCMChannelSettings.shared.handlerURL)\(FCMChannelSettings.shared.channel)/register/"

        var filteredUrn = urn

        if filteredUrn.hasPrefix("fcm:") {
            filteredUrn = String(filteredUrn.dropFirst(4))
        }

        var params = ["urn": filteredUrn,
                      "name": name,
                      "fcm_token": fcmToken] as [String: Any]

        if let contactUuid = contactUuid {
            params["contact_uuid"] = contactUuid
        }

        Alamofire.request(url, method: .post, parameters: params).responseJSON( completionHandler: { response in

            switch response.result {

            case .failure(let error):
                print("error \(String(describing: error.localizedDescription))")
                completion(nil, error)

            case .success(let value):
                if let response = value as? [String: String], let uuid = response["contact_uuid"] {
                    completion(uuid, nil)
                } else {
                    completion(nil, nil)
                }
            }
        })
    }

    // MARK: - Class Functions
    private func getMinimumDate() -> Date? {
        let date = Date()
        let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        var offsetComponents = DateComponents()
        offsetComponents.month = -1
        return (gregorian as NSCalendar).date(byAdding: offsetComponents, to: date, options: [])
    }
}
