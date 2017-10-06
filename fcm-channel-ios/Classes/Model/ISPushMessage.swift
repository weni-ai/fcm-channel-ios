//
//  ISPushMessage.swift
//  Pods
//
//  Created by Daniel Amaral on 07/06/16.
//
//

import UIKit
import ObjectMapper

public enum ISPushMessageDirection:String {
    case In = "in"
    case Out = "Out"
}

public enum ISPushMessageType:String {
    case Flow = "flow"
    case Inbox = "inbox"
}

open class ISPushMessage: NSObject, Mappable {

    open var id: Int?
    open var channel: ISPushChannel?
    open var broadcast: Int?
    open var contact: ISPushContact?
    open var urn: String?
    open var direction: String?
    open var type: String?
    open var status: String?
    open var archived: String?
    open var visibility: String?
    open var text: String?
    open var labels: [ISPushLabel]?
    open var createdOn: Date?
    open var sentOn: Date?
    open var ruleset: ISPushFlowRuleset?

    public init(msg:String) {
        self.text = msg
        self.direction = ISPushMessageDirection.In.rawValue
    }

    public override init() {
        self.direction = ISPushMessageDirection.Out.rawValue
    }

    required public init?(map: Map){}

    open func mapping(map: Map) {
        self.id              <- map["id"]
        self.broadcast       <- map["broadcast"]
        self.contact         <- map["contact"]
        self.urn             <- map["urn"]
        self.channel         <- map["channel"]
        self.direction       <- map["direction"]
        self.type            <- map["type"]
        self.status          <- map["status"]
        self.archived        <- map["archived"]
        self.visibility      <- map["visibility"]
        self.labels          <- map["labels"]
        self.createdOn       <- (map["created_on"], ISPushRapidPRODateTransform())
        self.sentOn          <- (map["sent_on"], ISPushRapidPRODateTransform())
        self.text            <- map["text"]
        self.ruleset         <- map["ruleset"]
    }
}
