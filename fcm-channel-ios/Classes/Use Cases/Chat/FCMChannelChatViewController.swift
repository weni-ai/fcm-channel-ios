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
import ObjectMapper

open class FCMChannelChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ISScrollViewPageDelegate {
    
    private var refreshControl: UIRefreshControl!
    
    @IBOutlet weak public var txtMessage: UITextField!
    @IBOutlet weak public var btSend: UIButton!
    @IBOutlet weak public var viewSendHeight: NSLayoutConstraint!
    @IBOutlet weak var viewSendBottom: NSLayoutConstraint!
    @IBOutlet weak public var tableView: UITableView!
    @IBOutlet weak open var viewSend: UIView!
    @IBOutlet weak public var scrollViewPage: ISScrollViewPage!

    var defaultFieldBottonHeight: CGFloat
    var choiceAnswerBorderColor: CGColor
    var choiceAnswerButtonColor: UIColor
    var buttonTitleColor: UIColor

    var currentMessageIsShowingOption = false
    let flowTypeManager = FCMChannelFlowTypeManager()
    public var defaultViewSendHeight = CGFloat(0)

    private var presenter: ChatPresenter?
    open private(set) var messages: [ChatCellViewModel] = []
    
    public init( contact: FCMChannelContact,
                 incomingBubleMsgColor: UIColor = UIColor(with: "#2F97F8"),
                 incomingLabelMsgColor: UIColor = UIColor.black,
                 botName: String,
                 outgoingBubleMsgColor: UIColor = UIColor.groupTableViewBackground,
                 outgoingLabelMsgColor: UIColor = UIColor.gray,
                 choiceAnswerButtonColor: UIColor = UIColor.white,
                 choiceAnswerBorderColor: CGColor = UIColor.clear.cgColor,
                 buttonHeight: CGFloat = CGFloat(20),
                 nibName: String = "FCMChannelChatViewController",
                 bundle: Bundle = Bundle(for: FCMChannelChatViewController.self),
                 loadMessagesOnInit: Bool = true ) {

        defaultFieldBottonHeight = buttonHeight
        buttonTitleColor = outgoingLabelMsgColor
        self.choiceAnswerBorderColor = choiceAnswerBorderColor
        self.choiceAnswerButtonColor = choiceAnswerButtonColor

        super.init(nibName: nibName, bundle: bundle)

        presenter = ChatPresenter(view: self,
                                  contact: contact,
                                  incomingBubleMsgColor: incomingBubleMsgColor,
                                  incomingLabelMsgColor: incomingLabelMsgColor,
                                  botName: botName,
                                  outgoingBubleMsgColor: outgoingBubleMsgColor,
                                  outgoingLabelMsgColor: outgoingLabelMsgColor,
                                  loadMessagesOnInit: loadMessagesOnInit)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false
        setupScrollViewPage()
        setupTableView()
        setupKeyBoardNotification()
        setupPullToRefresh()
        
        txtMessage.delegate = self
        defaultViewSendHeight = viewSendHeight.constant
        edgesForExtendedLayout = UIRectEdge()

        presenter?.onViewDidLoad()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: ISScrollViewPageDelegate
    
    open func scrollViewPageDidScroll(_ scrollView: UIScrollView) {}
    open func scrollViewPageDidChanged(_ scrollViewPage: ISScrollViewPage, index: Int) {}
    
    // MARK: UITextFieldDelegate
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true 
    }
    
    // MARK: Class Methods
    
    private func setupPullToRefresh() {
        self.refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTableView), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    @objc private func reloadTableView(sender: AnyObject) {
        presenter?.onReload()
    }
    
    open func setupKeyBoardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {

        guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        self.viewSendBottom.constant = value.cgRectValue.height
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
        
        self.tableViewScrollToBottom(false)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.viewSendBottom.constant = defaultFieldBottonHeight
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }

    open func setupScrollViewPage() {
        self.scrollViewPage.scrollViewPageType = ISScrollViewPageType.horizontally
        self.scrollViewPage.setPaging(false)
        self.scrollViewPage.scrollViewPageDelegate = self
    }
    
    @objc open func answerTapped(_ button: UIButton) {
        FCMChannelMessage.removeLastMessage()
        currentMessageIsShowingOption = false
        showAnswerOptionWithAnimation(false)
        self.txtMessage.text = button.titleLabel?.text
        self.btSendTapped(self.btSend)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ISAnsweredPollMessageSent"), object: nil, userInfo: ["answerTapped": (button.titleLabel?.text) ?? ""])
        
        self.view.endEditing(true)
        scrollViewPage.setCustomViews([])
    }
    
    fileprivate func showAnswerOptionWithAnimation(_ show: Bool) {
        if show && currentMessageIsShowingOption {
            return
        }
        
        self.viewSendHeight.constant = show == true ? self.viewSendHeight.constant + 54 : self.defaultViewSendHeight
        
        UIView.animate(withDuration: 0.1, animations: {
            self.view.layoutIfNeeded()
        }, completion: { finish in
            guard !self.messages.isEmpty else { return }
            self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .top, animated: false)
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
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
            
        })
    }
    
    func insertRowInIndex(_ indexPath: IndexPath) {
        self.tableView.insertRows(at: [indexPath], with: .fade)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
    
    open func setupTableView() {
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.backgroundColor = UIColor.white
        self.tableView.estimatedRowHeight = 75
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.register(UINib(nibName: "FCMChannelIncomingChatMessageViewCell", bundle: Bundle(for: FCMChannelChatViewController.self)), forCellReuseIdentifier: NSStringFromClass(FCMChannelIncomingChatMessageViewCell.self))
        self.tableView.register(UINib(nibName: "FCMChannelOutgoingChatMessageViewCell", bundle: Bundle(for: FCMChannelChatViewController.self)), forCellReuseIdentifier: NSStringFromClass(FCMChannelOutgoingChatMessageViewCell.self))
        self.tableView.separatorColor = UIColor.clear
    }
    
    // MARK: - Table view data source
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: FCMChannelChatMessageViewCell?
        
        let message = messages[indexPath.row]

        if message.fromUser {
            cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(FCMChannelOutgoingChatMessageViewCell.self), for: indexPath) as? FCMChannelOutgoingChatMessageViewCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(FCMChannelIncomingChatMessageViewCell.self), for: indexPath) as? FCMChannelIncomingChatMessageViewCell
        }

        cell?.setupCell(with: message)
        return cell ?? UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.txtMessage.resignFirstResponder()
    }
    
    // MARK: Button Events
    
    @IBAction public func btSendTapped(_ button: UIButton) {
        guard let text = txtMessage.text, text.count > 0 else { return }
        txtMessage.text = ""
        txtMessage.keyboardType = UIKeyboardType.alphabet
        presenter?.onSendMessage(with: text)
    }
    
    private func checkButtonsValidity(flowRule: FCMChannelFlowRule) -> Bool {
        let typeValidation = self.flowTypeManager.getTypeValidationForRule(flowRule)
        let answerDescription = flowRule.ruleCategory.values.first
        
        if answerDescription == "reply" ||
            answerDescription == "All Responses" ||
            answerDescription == "Other" {
            return false
        } else if typeValidation?.validation == "regex" {
            return false
        }
        return true
    }
    
    private func buildButton(name: String) -> UIButton {
        let button = UIButton()
        button.setTitle(name, for: .normal)

        let stringSize = button.titleLabel?.text?.size(withAttributes: [NSAttributedString.Key.font: button.titleLabel?.font]) ?? .zero
        var width = stringSize.width
        
        if width < 40 {
            width = 50
        }
        
        let frame = CGRect(x: 0, y: 0, width: width + 20, height: 40)
        button.frame = frame
        
        button.contentEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 2
        button.layer.borderColor = self.choiceAnswerBorderColor
        button.backgroundColor = self.choiceAnswerButtonColor
        button.setTitleColor(buttonTitleColor, for: .normal)
        button.addTarget(self, action: #selector(self.answerTapped), for: .touchUpInside)

        return button
    }
}

extension FCMChannelChatViewController: ChatViewContract {

    func showError(message: String) {
        let alertController = UIAlertController(title: "Erro", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        okAction.setValue(UIColor.black, forKey: "titleTextColor")
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }

    func addRow() {
        addRow(scroll: nil)
    }

    func addRow(scroll: Bool?) {

        OperationQueue.main.addOperation {
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.insertRowInIndex(indexPath)
        }

        if let scroll = scroll {
            tableViewScrollToBottom(false)
        }
    }

    func setCurrentRulesets(rulesets: FCMChannelFlowRuleset) {
        self.scrollViewPage.views = []
        var showOptions = false
        var views = [UIView]()

        if let flowRules = rulesets.rules {
            for flowRule in flowRules {

                guard let typeValidation = self.flowTypeManager.getTypeValidationForRule(flowRule) else {
                    return
                }
                let answerDescription = flowRule.ruleCategory.values.first

                if !checkButtonsValidity(flowRule: flowRule) {
                    // Do nothing
                } else {
                    showOptions = true

                    let button = buildButton(name: answerDescription ?? "")

                    self.txtMessage.keyboardType = UIKeyboardType.alphabet
                    let viewSpace = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 40))
                    viewSpace.backgroundColor = UIColor.clear
                    views.append(viewSpace)
                    views.append(button)

                    guard let type = typeValidation.type else { return }

                    switch type {
                    case FCMChannelFlowType.number:
                        self.txtMessage.keyboardType = UIKeyboardType.numberPad
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

    func update(with models: [ChatCellViewModel]) {
        self.messages = models
        self.tableView.reloadData()
        self.tableViewScrollToBottom(true)
    }

    func addQuickRepliesOptions(_ quickReplies: [FCMChannelQuickReply]) {
        self.scrollViewPage.views = []
        var views = [UIView]()
        var showOptions = false

        for quickReply in quickReplies {
            showOptions = true
            let button = buildButton(name: quickReply.title)

            self.txtMessage.keyboardType = UIKeyboardType.alphabet
            let viewSpace = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 40))
            viewSpace.backgroundColor = UIColor.clear
            views.append(viewSpace)
            views.append(button)
        }

        self.scrollViewPage.setCustomViews(views)
        self.showAnswerOptionWithAnimation(showOptions)
        self.currentMessageIsShowingOption = showOptions
    }

    func setLoading(to active: Bool) {
        if active {
            MBProgressHUD.showAdded(to: view, animated: true)
        } else {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
}
