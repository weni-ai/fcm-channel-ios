//
//  FCMChannelMessage.swift
//  Pods
//
//  Created by Daniel Amaral on 07/06/16.
//
//

import UIKit
import ObjectMapper

public enum FCMChannelMessageDirection:String {
    case In = "in"
    case Out = "Out"
}

public enum FCMChannelMessageType:String {
    case Flow = "flow"
    case Inbox = "inbox"
}

open class FCMChannelMessage: NSObject, Mappable {

    open var id: Int?
    open var channel: FCMChannelModel?
    open var broadcast: Int?
    open var contact: FCMChannelContact?
    open var urn: String?
    open var direction: String?
    open var type: String?
    open var status: String?
    open var archived: String?
    open var visibility: String?
    open var text: String?
    open var labels: [FCMChannelLabel]?
    open var createdOn: Date?
    open var sentOn: Date?
    open var ruleset: FCMChannelFlowRuleset?

    public init(msg:String) {
        self.text = msg
        self.direction = FCMChannelMessageDirection.In.rawValue
    }

    public override init() {
        self.direction = FCMChannelMessageDirection.Out.rawValue
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
        self.createdOn       <- (map["created_on"], FCMChannelDateTransform())
        self.sentOn          <- (map["sent_on"], FCMChannelDateTransform())
        self.text            <- map["text"]
        self.ruleset         <- map["ruleset"]
    }
}
