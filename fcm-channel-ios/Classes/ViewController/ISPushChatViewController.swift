//
//  ISPushQuestionViewController.swift
//  Pods
//
//  Created by Daniel Amaral on 07/06/16.
//
//

import UIKit
import ISScrollViewPageSwift
import MBProgressHUD

open class ISPushChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ISScrollViewPageDelegate {

    public var messageList = [ISPushMessage]()
    public var contact:ISPushContact!

    open var incomingBubleMsgColor:UIColor!
    open var incomingLabelMsgColor:UIColor!
    open var outgoingBubleMsgColor:UIColor!
    open var outgoingLabelMsgColor:UIColor!
    open var botName:String!

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
    @IBOutlet public var scrollViewPage:ISScrollViewPage!

    var loadMessagesOnInit: Bool = false
    var currentMessageIsShowingOption = false
    let flowTypeManager = ISPushFlowTypeManager()
    public var defaultViewSendHeight = CGFloat(0)
    
    public init(contact:ISPushContact,
                incomingBubleMsgColor:UIColor = UIColor(with: "#2F97F8"),
                incomingLabelMsgColor:UIColor = UIColor.white,
                botName:String!,
                outgoingBubleMsgColor:UIColor = UIColor.groupTableViewBackground,
                outgoingLabelMsgColor:UIColor = UIColor.gray,
                choiceAnswerButtonColor: UIColor,
                choiceAnswerBorderColor: CGColor,
                bottonHeight: CGFloat,
                nibName: String,
                bundle: Bundle,
                loadMessagesOnInit: Bool) {
        
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
        
        if loadMessagesOnInit { self.loadData() }

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
        
        let message = ISPushMessage()
        
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
        
        ISPushManager.getMessageByID(message!.id!) { (message) in
            
            if let message = message {
                
                if let ruleset = message.ruleset {
                    
                    for flowRule in (ruleset.rules)! {
                        
                        let typeValidation = self.flowTypeManager.getTypeValidationForRule(flowRule)
                        
                        let answerDescription = flowRule.ruleCategory.values.first
                        
                        if answerDescription == "reply" || answerDescription == "All Responses" || answerDescription == "Other" {
                            continue
                        }else {
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
                            case ISPushFlowType.openField:
                                break
                            case ISPushFlowType.choice:
                                break
                            case ISPushFlowType.number:
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
        ISPushManager.getMessagesFromContact(contact) { (messages) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let messages = messages {
                self.messageList = messages
                self.messageList = self.messageList.reversed()
                self.tableView.reloadData()
                self.tableViewScrollToBottom(true)
                self.checkIfMessageHasAnswerOptions()
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
        self.tableView.register(UINib(nibName: "ISPushIncomingChatMessageViewCell", bundle: Bundle(for: ISPushChatViewController.self)), forCellReuseIdentifier: NSStringFromClass(ISPushIncomingChatMessageViewCell.self))
        self.tableView.register(UINib(nibName: "ISPushOutgoingChatMessageViewCell", bundle: Bundle(for: ISPushChatViewController.self)), forCellReuseIdentifier: NSStringFromClass(ISPushOutgoingChatMessageViewCell.self))
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
        
        var cell:ISPushChatMessageViewCell?
        
        let message = self.messageList[(indexPath as NSIndexPath).row]
        
        if message.direction == ISPushMessageDirection.In.rawValue {
            cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(ISPushOutgoingChatMessageViewCell.self), for: indexPath) as! ISPushOutgoingChatMessageViewCell
            cell!.setupLayout(incomingLabelMsgColor, bubbleColor: incomingBubleMsgColor, userName: nil)
        }else {
            cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(ISPushIncomingChatMessageViewCell.self), for: indexPath) as! ISPushIncomingChatMessageViewCell
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
                
                self.txtMessage.text = ""
                
                self.messageList.append(ISPushMessage(msg:text))
                    
                OperationQueue.main.addOperation {
                    let indexPath = IndexPath(row: self.messageList.count - 1, section: 0)
                    self.insertRowInIndex(indexPath)
                }
                
                //self.tableViewScrollToBottom(false)
                
                let rulesetResponse = ISPushRulesetResponse(rule: nil, response: text)
                ISPushManager.sendRulesetResponses(contact, responses: [rulesetResponse], completion: { })
                    
                self.txtMessage.keyboardType = UIKeyboardType.alphabet
            }
        
        }
    }
    
}
