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
    private var contact: FCMChannelContact

    private var loadMessagesOnInit = false
    open var botName: String
    open var preferences: ChatPreferences

    init(view: ChatViewContract,
         contact: FCMChannelContact,
         botName: String,
         loadMessagesOnInit: Bool,
         preferences: ChatPreferences) {

        self.view = view
        self.contact = contact
        self.preferences = preferences
        self.botName = botName
        self.loadMessagesOnInit = loadMessagesOnInit
    }

    // MARK: - Action
    func onSendMessage(with text: String) {

        self.messageList.append(FCMChannelMessage(msg: text))
        self.loadCurrentRulesetDelayed(delay: 3)

        FCMClient.sendReceivedMessage(contact, message: text, completion: { success in
            if success {}
        })

        didUpdateMessages()
    }

    func onViewDidLoad() {
        if loadMessagesOnInit {
            loadData()
            loadCurrentRulesetDelayed()
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(newMessageReceived),
                                               name:NSNotification.Name(rawValue: "newMessageReceived"),
                                               object: nil)
    }

    func onReload() {
        loadData()
        loadCurrentRulesetDelayed()
    }

    // MARK: - Data

     @objc open func newMessageReceived(_ notification: Notification) {

        let message = FCMChannelMessage()

        let object = notification.object as? [String: AnyObject]

        let text = object?["message"] as? String
        message.text = text
        message.id = Int(object?["message_id"] as? String ?? "")

        if let metadata = object?["metadata"] as? String, let json = convertStringToDictionary(json: metadata) {
            if let quick_replies = json["quick_replies"] as? [String] {
                message.quickReplies = quick_replies.map { FCMChannelQuickReply($0) }
            }
        }

        //TODO: temporary workaround for duplicated push notifications. Remove as soon as Push fixes this.
        guard !messageList.contains(where: {$0.id == message.id}) else { return }

        messageList.append(message)
        didUpdateMessages()
        FCMChannelMessage.addLastMessage(message: message)
        loadCurrentRulesetDelayed(delay: 1)
    }

    private func getLastRuleset(from flowRun: FCMChannelFlowRun) {
        if isFlowActive(flowRun: flowRun), let latestFlowStep = flowRun.path.last {
            loadFlow(flowRun: flowRun, latestFlowStep: latestFlowStep)
        }
    }

    private func loadFlow(flowRun: FCMChannelFlowRun, latestFlowStep: FCMChannelFlowStep) {
        if let uuid = flowRun.flow.uuid {
            FCMClient.getFlowDefinition(uuid) { flowDefinition in
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

    private func loadData() {
        view?.setLoading(to: true)
        FCMClient.loadMessages(contact: contact) { (messages) in
            self.view?.setLoading(to: false)
            guard let messages = messages else { return }
            var testMessages: [String] = []
            testMessages.append(" 🕞 clock330  🏹 bow_and_arrow  😷 mask  🇹🇩 Chad             ☎ telephone                🔽 arrow_down_small 🙋🏿                🏉 rugby_football                ☪ star_and_crescent                🚿 shower                ☦ orthodox_cross                🔶 large_orange_diamond                🇸🇻 El Salvador                🚵🏿‍♀                🆚 vs                🍤 fried_shrimp                👊🏻                🔼 arrow_up_small                🔎 mag_right                🇿🇲 Zambia                🚜 tractor                🎭 performing_arts                ☺ white smiling face                🙋🏽‍♂                📬 mailbox_with_mail ")
            testMessages.append("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Convallis posuere morbi leo urna. google.com Laoreet non curabitur gravida arcu ac tortor dignissim. Eu consequat ac felis donec et odio pellentesque. Purus sit http://google.com amet luctus venenatis lectus.")
            testMessages.append("ellus molestie nunc non blandit massa. In hendrerit gravida rutrum quisque non. Eu feugiat pretium nibh ipsum. Id semper risus in hendrerit gravida rutrum. Sit amet risus nullam eget felis eget nunc lobortis. Integer enim neque volutpat ac tincidunt vitae semper quis lectus. Bibendum arcu vitae elementum curabitur vitae nunc sed. Elementum facilisis leo vel fringilla est ullamcorper eget nulla. Aliquam ultrices sagittis orci a scelerisque. Posuere ac ut consequat semper. Eget nunc lobortis mattis aliquam faucibus purus in massa.")
            testMessages.append("Tortor at auctor urna nunc id cursus metus aliquam eleifend. Tincidunt nunc pulvinar sapien et ligula ullamcorper. Arcu risus quis varius quam quisque id diam. Duis ut diam quam nulla porttitor massa id neque. Sed ullamcorper morbi tincidunt ornare. Libero nunc consequat interdum varius. Risus viverra adipiscing at in tellus")
            self.messageList = messages.reversed()
            self.messageList.append(contentsOf: testMessages.map( {
                    let message = FCMChannelMessage(msg: $0)
                message.id = Int.random(in: 0..<670)
                    return message
            }))
            self.didUpdateMessages()
        }
    }

    private func loadCurrentRulesetDelayed(delay: Int? = 2) {

        if let message = FCMChannelMessage.lastMessage() {
            DispatchQueue.main.async { //asyncAfter(deadline: .now() + Double(delay!)) {
                if let quickReplies = message.quickReplies {
                    self.view?.addQuickRepliesOptions(quickReplies)
                }
            }
        } else {

            DispatchQueue.main.async { //After(deadline: .now() + Double(delay!)) {
                FCMClient.getFlowRuns(self.contact, completion: { (flowRuns: [FCMChannelFlowRun]?) -> Void in
                    if let flowRun = flowRuns?.first {
                        self.getLastRuleset(from: flowRun)
                    }
                })
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
            let msgColor = fromUser ? preferences.incomingLabelMsgColor : preferences.outgoingLabelMsgColor
            let bubbleColor = fromUser ? preferences.incomingBubleMsgColor : preferences.outgoingBubleMsgColor
            let username: String? = fromUser ? nil : botName
            let linkColor = fromUser ? preferences.incomingLinkColor : preferences.outgoingLinkColor

            return ChatCellViewModel(key: message.id ?? 0,
                                    msgColor: msgColor,
                                    bubbleColor: bubbleColor,
                                    userName: username,
                                    text: message.text,
                                    fromUser: fromUser,
                                    linkColor: linkColor)
        }
    }

    private func isFlowActive(flowRun: FCMChannelFlowRun) -> Bool {
        guard let exit_type = flowRun.exitType else {
            return true
        }

        //        let exitType = !(exit_type == "completed" || exit_type == "expired")

        if flowRun.path != nil && !flowRun.path.isEmpty {
            return true
        }
        return false
    }
}
