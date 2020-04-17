//
//  ChatPresenter.swift
//  FCM Channel iOS Example
//
//  Created by Alexandre Azevedo on 28/03/19.
//

import Foundation

class ChatPresenter {
    private weak var view: ChatViewContract?

    private var messageList = [FCMChannelMessage]()
    private var contact: FCMChannelContact?
    private var loadMessagesOnInit = false
    private var useLocalCache = false
    private var urn: String?
    private var fcmToken: String?
    private var botImage: UIImage?

    open var incomingBubleMsgColor: UIColor
    open var incomingLabelMsgColor: UIColor
    open var outgoingBubleMsgColor: UIColor
    open var outgoingLabelMsgColor: UIColor
    open var botName: String
    private var nextPageToken: String?
    
    private var contactToken: String? {
        return self.contact?.fcmToken ?? fcmToken
    }

    private var contactUrn: String? {
        return self.contact?.urn ?? urn
    }
    
    private var initialPayload: String? {
        return FCMChannelSettings.getInitialPayload()
    }

    init(view: ChatViewContract,
         contact: FCMChannelContact,
         botImage: UIImage? = nil,
         incomingBubleMsgColor: UIColor = UIColor(with: "#2F97F8"),
         incomingLabelMsgColor: UIColor = UIColor.black,
         botName: String,
         outgoingBubleMsgColor: UIColor = UIColor.groupTableViewBackground,
         outgoingLabelMsgColor: UIColor = UIColor.gray,
         loadMessagesOnInit: Bool = true,
         useLocalCache: Bool = false) {

        self.view = view
        self.contact = contact
        self.botImage = botImage
        self.incomingBubleMsgColor = incomingBubleMsgColor
        self.incomingLabelMsgColor = incomingLabelMsgColor
        self.botName = botName
        self.outgoingBubleMsgColor = outgoingBubleMsgColor
        self.outgoingLabelMsgColor = outgoingLabelMsgColor
        self.loadMessagesOnInit = loadMessagesOnInit
        self.useLocalCache = useLocalCache
    }

    init(view: ChatViewContract,
         fcmToken: String?,
         urn: String?,
         botImage: UIImage? = nil,
         incomingBubleMsgColor: UIColor = UIColor(with: "#2F97F8"),
         incomingLabelMsgColor: UIColor = UIColor.black,
         botName: String,
         outgoingBubleMsgColor: UIColor = UIColor.groupTableViewBackground,
         outgoingLabelMsgColor: UIColor = UIColor.gray,
         useLocalCache: Bool = false) {

        self.view = view
        self.fcmToken = fcmToken
        self.urn = urn
        self.botImage = botImage
        self.incomingBubleMsgColor = incomingBubleMsgColor
        self.incomingLabelMsgColor = incomingLabelMsgColor
        self.botName = botName
        self.outgoingBubleMsgColor = outgoingBubleMsgColor
        self.outgoingLabelMsgColor = outgoingLabelMsgColor
        self.useLocalCache = useLocalCache
    }

    // MARK: - Action

    func onReachTop() {
        if nextPageToken != nil {
            loadData()
        }
    }

    func onSendMessage(with text: String, show: Bool = true) {

        guard let urn = contactUrn else {
            print("FCMChannel Error: Missing contact urn")
            return
        }

        guard let fcmToken = contactToken else {
            print("FCMChannel Error: Missing contact token")
            return
        }
        
        let message = FCMChannelMessage(msg: text)

        FCMClient.sendReceivedMessage(urn: urn, token: fcmToken, message: text, completion: { error in
            if error != nil {}
        })
        
        if show {
            self.messageList.append(message)
            if useLocalCache {
                FCMCache.addMessage(message)
            } else {
                FCMChannelMessage.addLastMessage(message: message)
            }
        }
        
        self.loadCurrentRuleset()

        didUpdateMessages()
    }

    func onViewDidLoad() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(newMessageReceived),
                                               name: NSNotification.Name(rawValue: "newMessageReceived"),
                                               object: nil)
        
        if loadMessagesOnInit {
            loadData()
        } else if(useLocalCache) {
            loadDataFromCache()
            return
        }
    }

    func onReload() {
        nextPageToken = nil
        loadData(replace: true)
        loadCurrentRuleset()
    }

    // MARK: - Data

     @objc open func newMessageReceived(_ notification: Notification) {

        let message = FCMChannelMessage()

        let object = notification.object as? [String: AnyObject]

        let text = object?["message"] as? String
        message.text = text
        message.id = Int(object?["message_id"] as? String ?? "")

        if let quick_replies = object?["quick_replies"] as? String,
            let json = try? JSONSerialization.jsonObject(with: Data("{\"quick_replies\": \(quick_replies)}".utf8), options: []) as? [String: Any],
            let quickReplies = json["quick_replies"] as? [String] {
            message.quickReplies = quickReplies.map { FCMChannelQuickReply($0) }
        }

        //TODO: temporary workaround for duplicated push notifications. Remove as soon as Push fixes this.
        guard !messageList.contains(where: {$0.id == message.id}) else { return }

        messageList.append(message)
        didUpdateMessages()
        
        if useLocalCache {
            FCMCache.addMessage(message)
        } else {
            FCMChannelMessage.addLastMessage(message: message)
        }
        
        loadCurrentRuleset()
    }

    private func getLastRuleset(from flowRun: FCMChannelFlowRun) {
        if isFlowActive(flowRun: flowRun), let latestFlowStep = flowRun.path.last {
            loadFlow(flowRun: flowRun, latestFlowStep: latestFlowStep)
        }
    }

    private func loadFlow(flowRun: FCMChannelFlowRun, latestFlowStep: FCMChannelFlowStep) {
        if let uuid = flowRun.flow.uuid {
            FCMClient.getFlowDefinition(flowUuid: uuid) { flowDefinition, error in
                if let lastFlow = flowDefinition?.flows?.last {
                    self.getRulesetFor(flow: lastFlow, flowStep: latestFlowStep)
                }
            }
        }
    }

    private func getRulesetFor(flow: FCMChannelFlow, flowStep: FCMChannelFlowStep) {
        if let uuid = flowStep.node {
            if let index = getIndexForStepUuid(uuid: uuid, flow: flow) {
                if index >= 0 {
                    if let ruleset = flow.ruleSets?[index] {
                        view?.setCurrentRulesets(rulesets: ruleset)
                    }
                }
            }
        }
    }
    
    private func loadDataFromCache() {
        messageList = FCMCache.getMessages()
        
        if messageList.isEmpty, let initialPayload = self.initialPayload {
            onSendMessage(with: initialPayload, show: false)
        }
        
        loadCurrentRuleset()
        self.didUpdateMessages()
    }

    private func loadData(replace: Bool = false) {
        guard let contact = self.contact else { return }
        view?.setLoading(to: true)
        FCMClient.loadMessages(contactId: contact.uuid, pageToken: nextPageToken) { (response, error) in
            self.view?.setLoading(to: false)

            if let error = error {
                self.view?.showError(message: error.localizedDescription)
            }

            if replace {
                self.messageList = response?.results ?? []
            } else {
                for message in response?.results ?? []  where
                    !self.messageList.reversed().contains(where: { $0.id == message.id }) {
                        self.messageList.insert(message, at: 0)
                }
            }

            self.nextPageToken = response?.next
            
            if self.messageList.isEmpty, let initialPayload = self.initialPayload {
                self.onSendMessage(with: initialPayload, show: false)
            }

            self.didUpdateMessages()
            self.loadCurrentRuleset()
        }
    }

    private func loadCurrentRuleset() {

        if let message = useLocalCache ?
                FCMCache.getLastMessage() : FCMChannelMessage.lastMessage(),
            (message.direction == FCMChannelMessageDirection.In.rawValue || message.id == messageList.last?.id) {
            DispatchQueue.main.async { [weak self] in
                self?.view?.addQuickRepliesOptions(message.quickReplies ?? [])
            }
        } else if let contact = self.contact {
            FCMClient.getFlowRuns(contactId: contact.uuid) { (flowRuns: [FCMChannelFlowRun]?, error: Error?) in
                if error == nil, let flowRun = flowRuns?.first {
                    self.getLastRuleset(from: flowRun)
                }
            }
        }
    }

    // MARK: - Util

    private func getIndexForStepUuid(uuid: String, flow: FCMChannelFlow) -> Int? {
            return flow.ruleSets?.enumerated()
                .first(where: { $0.element.uuid == uuid })?.offset
    }

    func convertStringToDictionary(json: String) -> [String: AnyObject]? {
        if let data = json.data(using: String.Encoding.utf8) {

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                return json as? [String: AnyObject]
            } catch let error {
                print(error.localizedDescription)
                return nil
            }
        }
        return nil
    }

    private func didUpdateMessages() {
        view?.update(with: getModels())
    }

    private func getModels() -> [ChatCellViewModel] {

        return messageList.map { message in

            let fromUser = message.direction == FCMChannelMessageDirection.In.rawValue
            let msgColor = fromUser ? incomingLabelMsgColor : outgoingLabelMsgColor
            let bubbleColor = fromUser ? incomingBubleMsgColor : outgoingBubleMsgColor
            let username: String? = fromUser ? nil : botName
            let image: UIImage? = fromUser ? nil : botImage

            return ChatCellViewModel(msgColor: msgColor,
                                    bubbleColor: bubbleColor,
                                    userName: username,
                                    text: message.text,
                                    image: image,
                                    fromUser: fromUser)
        }
    }

    private func isFlowActive(flowRun: FCMChannelFlowRun) -> Bool {
        guard flowRun.exitType != nil else {
            return true
        }

        return flowRun.path != nil && !flowRun.path.isEmpty
    }
}
