//
//  FCMChannelQuestionViewController.swift
//  Pods
//
//  Created by Daniel Amaral on 07/06/16.
//
//

import UIKit
import ISScrollViewPageSwift
import MBProgressHUD

open class FCMChannelChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ISScrollViewPageDelegate {
    
    public var messageList = [FCMChannelMessage]()
    public var contact:FCMChannelContact!
    
    private var refreshControl: UIRefreshControl!
    
    open var incomingBubleMsgColor: UIColor!
    open var incomingLabelMsgColor: UIColor!
    open var outgoingBubleMsgColor: UIColor!
    open var outgoingLabelMsgColor: UIColor!
    open var botName: String!
    
    var defaultFieldBottonHeight: CGFloat!
    var choiceAnswerBorderColor: CGColor!
    var choiceAnswerButtonColor: UIColor!
    
    @IBOutlet public var txtMessage:UITextField!
    @IBOutlet public var btSend:UIButton!
    @IBOutlet public var viewSendHeight:NSLayoutConstraint!
    @IBOutlet var viewSendBottom:NSLayoutConstraint!
    @IBOutlet public var tableView:UITableView!
    @IBOutlet open var scrollView:UIScrollView!
    @IBOutlet open var viewSend:UIView!
    @IBOutlet public var scrollViewPage: ISScrollViewPage!
    
    var loadMessagesOnInit: Bool = false
    var currentMessageIsShowingOption = false
    let flowTypeManager = FCMChannelFlowTypeManager()
    public var defaultViewSendHeight = CGFloat(0)
    
    public init( contact: FCMChannelContact,
                 incomingBubleMsgColor: UIColor = UIColor(with: "#2F97F8"),
                 incomingLabelMsgColor: UIColor = UIColor.black,
                 botName: String,
                 outgoingBubleMsgColor: UIColor = UIColor.groupTableViewBackground,
                 outgoingLabelMsgColor: UIColor = UIColor.gray,
                 choiceAnswerButtonColor: UIColor = UIColor.white,
                 choiceAnswerBorderColor: CGColor = UIColor.clear.cgColor,
                 bottonHeight: CGFloat = CGFloat(20),
                 nibName: String = "FCMChannelChatViewController",
                 bundle: Bundle = Bundle(for: FCMChannelChatViewController.self),
                 loadMessagesOnInit: Bool = true ) {
        
        self.contact = contact
        self.defaultFieldBottonHeight = bottonHeight
        self.choiceAnswerBorderColor = choiceAnswerBorderColor
        self.choiceAnswerButtonColor = choiceAnswerButtonColor
        self.incomingBubleMsgColor = incomingBubleMsgColor
        self.incomingLabelMsgColor = incomingLabelMsgColor
        self.botName = botName
        self.outgoingBubleMsgColor = outgoingBubleMsgColor
        self.outgoingLabelMsgColor = outgoingLabelMsgColor
        self.loadMessagesOnInit = loadMessagesOnInit
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(newMessageReceived), name:NSNotification.Name(rawValue: "newMessageReceived"), object: nil)
        
        automaticallyAdjustsScrollViewInsets = false
        setupScrollViewPage()
        setupTableView()
        setupKeyBoardNotification()
        setupPullToRefresh()
        
        if loadMessagesOnInit {
            self.loadData()
            self.loadCurrentRulesetDelayed()
        }
        
        self.txtMessage.delegate = self
        defaultViewSendHeight = viewSendHeight.constant
        self.edgesForExtendedLayout = UIRectEdge();
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MAR: ISScrollViewPageDelegate
    
    open func scrollViewPageDidScroll(_ scrollView: UIScrollView) {}
    open func scrollViewPageDidChanged(_ scrollViewPage: ISScrollViewPage, index: Int) {}
    
    //MARK: UITextFieldDelegate
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: Class Methods
    
    private func setupPullToRefresh() {
        self.refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTableView), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    @objc private func reloadTableView(sender: AnyObject) {
        self.loadData()
        self.loadCurrentRulesetDelayed()
    }
    
    open func setupKeyBoardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.viewSendBottom.constant = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
        
        self.tableViewScrollToBottom(false)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.viewSendBottom.constant = defaultFieldBottonHeight
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    open func newMessageReceived(_ notification:Notification) {
        
        let message = FCMChannelMessage()
        
        let object = notification.object as! [String: AnyObject]
        
        let text = object["message"] as! String
        message.text = text
        message.id = Int(object["message_id"] as! String)
        
        self.messageList.append(message)
        print(message)
        let indexPath = IndexPath(row: self.messageList.count - 1, section: 0)
        insertRowInIndex(indexPath)
        
        checkIfMessageHasAnswerOptions()
    }
    
    open func setupScrollViewPage() {
        self.scrollViewPage.scrollViewPageType = ISScrollViewPageType.horizontally
        self.scrollViewPage.setPaging(false)
        self.scrollViewPage.scrollViewPageDelegate = self
    }
    
    @objc fileprivate func answerTapped(_ button:UIButton) {
        currentMessageIsShowingOption = false
        showAnswerOptionWithAnimation(false)
        self.txtMessage.text = button.titleLabel?.text
        self.btSendTapped(self.btSend)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ISAnsweredPollMessageSent"), object: nil, userInfo: ["answerTapped": (button.titleLabel?.text)!])
        
        self.view.endEditing(true)
    }
    
    fileprivate func showAnswerOptionWithAnimation(_ show:Bool) {
        
        if show && currentMessageIsShowingOption{
            return
        }
        
        self.viewSendHeight.constant = show == true ? self.viewSendHeight.constant + 54 : self.defaultViewSendHeight
        
        UIView.animate(withDuration: 0.1, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (finish) in
            self.tableView.scrollToRow(at: IndexPath(row: self.messageList.count - 1, section: 0), at: UITableViewScrollPosition.top, animated: false)
        })
    }
    
    fileprivate func tableViewScrollToBottom(_ animated: Bool) {
        
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: animated)
            }
            
        })
    }
    
    fileprivate func checkIfMessageHasAnswerOptions() {
        self.scrollViewPage.views = []
        let message = self.messageList.last
        var showOptions = false
        var views = [UIView]()
        
        RapidProAPI.getMessageByID(message!.id!) { (message) in
            
            if let message = message {
                
                if let ruleset = message.ruleset {
                    
                    for flowRule in (ruleset.rules)! {
                        
                        let typeValidation = self.flowTypeManager.getTypeValidationForRule(flowRule)
                        
                        let answerDescription = flowRule.ruleCategory.values.first
                        
                        if answerDescription == "reply" || answerDescription == "All Responses" || answerDescription == "Other" {
                            continue
                        } else {
                            showOptions = true
                        }
                        
                        let button = UIButton()
                        button.setTitle(answerDescription, for: UIControlState.normal)
                        
                        var stringSize = button.titleLabel!.text!.size(attributes: [NSFontAttributeName : button.titleLabel!.font])
                        var width = stringSize.width
                        
                        if width < 40 {
                            width = 50
                        }
                        
                        var frame = CGRect(x: 0, y: 0, width: width + 20, height: 40)
                        button.frame = frame
                        
                        //button.contentEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
                        button.layer.cornerRadius = 20
                        button.layer.borderWidth = 2
                        button.layer.borderColor = self.choiceAnswerBorderColor//UIColor.white.cgColor
                        button.backgroundColor = self.choiceAnswerButtonColor
                        button.setTitleColor(self.incomingLabelMsgColor, for: UIControlState.normal)
                        button.addTarget(self, action: #selector(self.answerTapped), for: UIControlEvents.touchUpInside)
                        
                        self.txtMessage.keyboardType = UIKeyboardType.alphabet
                        views.append(button)
                        
                        switch typeValidation.type! {
                        case FCMChannelFlowType.openField:
                            break
                        case FCMChannelFlowType.choice:
                            break
                        case FCMChannelFlowType.number:
                            self.txtMessage.keyboardType = UIKeyboardType.numberPad
                            break
                        default: break
                        }
                        
                    }
                    self.scrollViewPage.setCustomViews(views)
                    
                    self.showAnswerOptionWithAnimation(showOptions)
                    self.currentMessageIsShowingOption = showOptions
                }
            }
        }
    }
    
    open func loadData() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        RapidProAPI.getMessagesFromContact(contact) { (messages) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let messages = messages {
                self.messageList = messages
                self.messageList = self.messageList.reversed()
                self.tableView.reloadData()
                self.tableViewScrollToBottom(true)
            }
        }
    }
    
    func insertRowInIndex(_ indexPath:IndexPath) {
        self.tableView.insertRows(at: [indexPath], with: UITableViewRowAnimation.bottom)
        self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: false)
    }
    
    open func setupTableView() {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.delegate = self
        self.tableView.backgroundColor = UIColor.white
        self.tableView.estimatedRowHeight = 75
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.register(UINib(nibName: "FCMChannelIncomingChatMessageViewCell", bundle: Bundle(for: FCMChannelChatViewController.self)), forCellReuseIdentifier: NSStringFromClass(FCMChannelIncomingChatMessageViewCell.self))
        self.tableView.register(UINib(nibName: "FCMChannelOutgoingChatMessageViewCell", bundle: Bundle(for: FCMChannelChatViewController.self)), forCellReuseIdentifier: NSStringFromClass(FCMChannelOutgoingChatMessageViewCell.self))
        self.tableView.separatorColor = UIColor.clear
    }
    
    // MARK: - Table view data source
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageList.count
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:FCMChannelChatMessageViewCell?
        
        let message = self.messageList[(indexPath as NSIndexPath).row]
        
        if message.direction == FCMChannelMessageDirection.In.rawValue {
            cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(FCMChannelOutgoingChatMessageViewCell.self), for: indexPath) as! FCMChannelOutgoingChatMessageViewCell
            cell!.setupLayout(incomingLabelMsgColor, bubbleColor: incomingBubleMsgColor, userName: nil)
        }else {
            cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(FCMChannelIncomingChatMessageViewCell.self), for: indexPath) as! FCMChannelIncomingChatMessageViewCell
            cell!.setupLayout(outgoingLabelMsgColor, bubbleColor: outgoingBubleMsgColor, userName: botName)
        }
        
        cell!.setupCell(with: message)
        
        return cell!
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        self.txtMessage.resignFirstResponder()
    }
    
    //MARK: Button Events
    
    @IBAction public func btSendTapped(_ button:UIButton) {
        
        if let text = self.txtMessage.text {
            
            if text.characters.count > 0 {
                
                RapidProAPI.sendMessage(contact, message: text, completion: {
                    success in
                    
                    if success {
                        
                        self.txtMessage.text = ""
                        
                        self.messageList.append(FCMChannelMessage(msg:text))
                        
                        OperationQueue.main.addOperation {
                            let indexPath = IndexPath(row: self.messageList.count - 1, section: 0)
                            self.insertRowInIndex(indexPath)
                        }
                        
                        self.tableViewScrollToBottom(false)
                        
                        self.loadCurrentRulesetDelayed()
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64(500000000))) {
                            self.loadData()
                        }
                    }
                    
                })
                
                self.txtMessage.keyboardType = UIKeyboardType.alphabet
            }
        }
    }
    
    func loadCurrentRulesetDelayed() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64(500000000))) {
            RapidProAPI.getFlowRuns(self.contact, completion: { (flowRuns: [FCMChannelFlowRun]?) -> Void in
                if let flowRuns = flowRuns {
                    self.getLastRuleset(from: flowRuns.first!)
                }
            })
        }
    }
    
    private func getLastRuleset(from flowRun: FCMChannelFlowRun) {
        if isValidRuleset(flowRun: flowRun) {
            let latestFlowStep = flowRun.path.last
            loadFlow(flowRun: flowRun, latestFlowStep: latestFlowStep!)
        }
    }
    
    private func isValidRuleset(flowRun: FCMChannelFlowRun) -> Bool {
        return FCMChannelFlowManager.isFlowActive(flowRun) && flowRun.path != nil && flowRun.path.count > 0
    }
    
    private func loadFlow(flowRun: FCMChannelFlowRun, latestFlowStep: FCMChannelFlowStep) {
        if let uuid = flowRun.flow.uuid {
            RapidProAPI.getFlowDefinition(uuid) {
                (flowDefinition) in
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
                        setCurrentRulesets(rulesets: ruleset)
                    }
                }
            }
        }
    }
    
    private func getIndexForStepUuid(uuid: String, flow: FCMChannelFlow) -> Int? {
        if let rulesets = flow.ruleSets {
            for (i, ruleset) in rulesets.enumerated() {
                if ruleset.uuid == uuid {
                    return i
                }
            }
        }
        
        return nil
    }
    
    private func setCurrentRulesets(rulesets: FCMChannelFlowRuleset) {
        self.scrollViewPage.views = []
        let message = self.messageList.last
        var showOptions = false
        var views = [UIView]()

        if let flowRules = rulesets.rules {
            for flowRule in flowRules {

                let typeValidation = self.flowTypeManager.getTypeValidationForRule(flowRule)
                
                let answerDescription = flowRule.ruleCategory.values.first
                
                if answerDescription == "reply" || answerDescription == "All Responses" || answerDescription == "Other" {
                    // Do nothing
                } else {
                    showOptions = true
                    
                    let button = UIButton()
                    button.setTitle(answerDescription, for: UIControlState.normal)
                    
                    var stringSize = button.titleLabel!.text!.size(attributes: [NSFontAttributeName : button.titleLabel!.font])
                    var width = stringSize.width
                    
                    if width < 40 {
                        width = 50
                    }
                    
                    var frame = CGRect(x: 0, y: 0, width: width + 20, height: 40)
                    button.frame = frame
                    
                    button.contentEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
                    button.layer.cornerRadius = 20
                    button.layer.borderWidth = 2
                    button.layer.borderColor = self.choiceAnswerBorderColor//UIColor.white.cgColor
                    button.backgroundColor = self.choiceAnswerButtonColor
                    button.setTitleColor(self.incomingLabelMsgColor, for: UIControlState.normal)
                    button.addTarget(self, action: #selector(self.answerTapped), for: UIControlEvents.touchUpInside)
                    
                    self.txtMessage.keyboardType = UIKeyboardType.alphabet
                    views.append(button)
                    
                    switch typeValidation.type! {
                    case FCMChannelFlowType.openField:
                        break
                    case FCMChannelFlowType.choice:
                        break
                    case FCMChannelFlowType.number:
                        self.txtMessage.keyboardType = UIKeyboardType.numberPad
                        break
                    default:
                        break
                    }
                }
            }
           
            self.scrollViewPage.setCustomViews(views)
            self.showAnswerOptionWithAnimation(showOptions)
            self.currentMessageIsShowingOption = showOptions
        }
    }
}

