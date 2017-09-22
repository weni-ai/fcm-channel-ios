//
//  URCurrentPollView.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 18/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import MDHTMLLabel
import MBProgressHUD
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


@objc public protocol ISPushCurrentPollViewDelegate {
    @objc optional func onBoundsChanged(_ currentPollView:ISPushCurrentPollView,currentPollHeight:CGFloat)
    @objc optional func didFinishAnswerFlow(_ currentPollView:ISPushCurrentPollView,didReceiveLastMessage:Bool)
    @objc optional func didFinishLoadFlow(_ currentPollView:ISPushCurrentPollView)
}

open class ISPushCurrentPollView: UITableViewCell, ISPushChoiceResponseDelegate, ISPushOpenFieldResponseDelegate, MDHTMLLabelDelegate {
    
    @IBOutlet weak var lbCurrentPoll: UILabel!
    @IBOutlet weak var lbFlowName: UILabel!
    @IBOutlet weak var btNext: UIButton!
    @IBOutlet weak var viewResponses: UIView!
    @IBOutlet weak var lbQuestion: MDHTMLLabel!
    @IBOutlet weak var constraintHeaderHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintQuestionHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintResponseHeight: NSLayoutConstraint!
    @IBOutlet weak var btSwitchLanguage: UIButton!
    
    var actionSheetLanguage: UIAlertController!
    open var delegates: [ISPushCurrentPollViewDelegate]?
    
    let responseHeight = 47
    let flowTypeManager = ISPushFlowTypeManager()
    
    var languages = Set<String>()
    var selectedLanguage:String?
    
    var responses:[ISPushRulesetResponse] = []
    var currentFlow:ISPushFlowDefinition?
    var currentActionSet:ISPushFlowActionSet?
    var currentRuleset:ISPushFlowRuleset?
    
    open var viewController:UIViewController!
    open var contact:ISPushContact!
    var flowDefinition:ISPushFlowDefinition!
    var flowRuleset:ISPushFlowRuleset?
    var flowActionSet:ISPushFlowActionSet?
    
    open var flowIsLoaded = false
    
    var flowRule:ISPushFlowRule?
    var response:String?
    
    open var btNextTitle = "Próximo"
    open var currentPollTitle = "Enquete Atual"
    open var switchLanguageTitle = "Mudar Idioma"
    open var sendingAnswerMessage = "Enviando respostas..."
    open var sendingAnswerError = "Erro ao enviar mensagem..."
    open var cancelTitle = "Cancelar"
    open var noAnswerTitle = "Obrigado por participar!"
    open var btNextColor = UIColor.green
    open var btNextTitleColor = UIColor.white    
    open var removeHeader = false
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.delegates = []
        btNext.layer.cornerRadius = 5
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: Responses delegates
    
    func onChoiceSelected(_ flowRule: ISPushFlowRule) {
        self.flowRule = flowRule
        self.response = self.getResponseFromRule(flowRule)
        unselectResponses()
    }
    
    func onOpenFieldResponseChanged(_ flowRule: ISPushFlowRule, text: String) {
        self.flowRule = flowRule
        self.response = text
        unselectResponses()
    }
    
    //MARK: Actions
    
    @IBAction func switchLanguage(_ sender: AnyObject) {
        viewController.present(actionSheetLanguage, animated: true, completion: nil)
    }
    
    //MARK: MDHTMLLabelDelegate
    
    open func htmlLabel(_ label: MDHTMLLabel!, didSelectLinkWith URL: Foundation.URL!) {
        if let url = URL {
            UIApplication.shared.openURL(url)
        }
    }
    
    //MARK: Class Methods
    
    open func setupLayoutParameters(_ contact:ISPushContact!,btNextTitle:String?,currentPollTitle:String?,switchLanguageTitle:String?,sendingAnswerMessage:String?,sendingAnswerError:String?,cancelTitle:String?,noAnswerTitle:String?,btNextColor:UIColor?,btNextTitleColor:UIColor?,removeHeader:Bool!) {
        self.contact = contact
        self.removeHeader = removeHeader
        self.btNextTitle = btNextTitle != nil ? btNextTitle! : self.btNextTitle
        self.currentPollTitle = currentPollTitle != nil ? currentPollTitle! : self.currentPollTitle
        self.switchLanguageTitle = switchLanguageTitle != nil ? switchLanguageTitle! : self.switchLanguageTitle
        self.sendingAnswerMessage = sendingAnswerMessage != nil ? sendingAnswerMessage! : self.sendingAnswerMessage
        self.sendingAnswerError = sendingAnswerError != nil ? sendingAnswerError! : self.sendingAnswerError
        self.cancelTitle = cancelTitle != nil ? cancelTitle! : self.cancelTitle
        self.noAnswerTitle = noAnswerTitle != nil ? noAnswerTitle! : self.noAnswerTitle
        self.btNextColor = btNextColor != nil ? btNextColor! : self.btNextColor
        self.btNextTitleColor = btNextTitleColor != nil ? btNextTitleColor! : self.btNextTitleColor
        setupUI()
    }
    
    open func setupUI() {
        self.btNext.setTitle(self.btNextTitle, for: UIControlState())
        self.btNext.backgroundColor = self.btNextColor
        self.btNext.titleLabel?.textColor = self.btNextTitleColor
        self.lbCurrentPoll.text = self.currentPollTitle
        self.btSwitchLanguage.setTitle(switchLanguageTitle, for: UIControlState())
        if removeHeader {
            self.constraintHeaderHeight.constant = 0
            updateTopViewHeight(self.getCurrentPollHeight())
        }
    }
    
    fileprivate func setupNextStep(_ destination:String?) {
        self.currentActionSet = ISPushFlowManager.getFlowActionSetByUuid(currentFlow!, destination: destination, currentActionSet: currentActionSet)
        self.currentRuleset = ISPushFlowManager.getRulesetForAction(currentFlow!, actionSet: currentActionSet)
    }
    
    open func reloadCurrentFlowSection() {
        
        var currentPollHeight:CGFloat = self.frame.size.height
        
        if !ISPushFlowManager.isLastActionSet(currentActionSet) {
            self.setupData(currentFlow!, flowActionSet: currentActionSet!, flowRuleset: currentRuleset, contact: contact!)
            currentPollHeight = self.getCurrentPollHeight()
            
        }else if currentActionSet == nil {
            let hud = MBProgressHUD.showAdded(to: self, animated: true)
            hud.labelText = sendingAnswerMessage
            
            ISPushManager.sendRulesetResponses(contact, responses: responses, completion: { () -> Void in
                hud.hide(true)
                
                DispatchQueue.main.async {
                    
                    self.responses = []
                    if let delegates = self.delegates {
                        for delegate in delegates where delegate.didFinishAnswerFlow != nil {
                            delegate.didFinishAnswerFlow!(self, didReceiveLastMessage: false)
                        }
                    }
                }
            })
            
            self.endEditing(true)
            
        }else{
            self.setupDataWithNoAnswer(currentFlow, flowActionSet: currentActionSet, flowRuleset: currentRuleset, contact: contact)
            
            currentPollHeight = self.getCurrentPollHeight() - 30
            let hud = MBProgressHUD.showAdded(to: self, animated: true)
            hud.labelText = sendingAnswerMessage
            
            ISPushManager.sendRulesetResponses(contact, responses: responses, completion: { () -> Void in
                hud.hide(true)
                
                DispatchQueue.main.async {
                    self.responses = []
                    
                    if let delegates = self.delegates {
                        for delegate in delegates where delegate.didFinishAnswerFlow != nil {
                            delegate.didFinishAnswerFlow!(self, didReceiveLastMessage: true)
                        }
                    }
                }
            })
        }            
        
        self.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: currentPollHeight)
        updateTopViewHeight(currentPollHeight)
    }
    
    open func loadCurrentFlow() {
        ISPushManager.getFlowRuns(contact, completion: { (flowRuns: [ISPushFlowRun]?) -> Void in
            if let flowRuns = flowRuns {
                if ((!flowRuns.isEmpty) && ISPushFlowManager.isFlowActive(flowRuns[0])) {
                    ISPushManager.getFlowDefinition(flowRuns[0].flow_uuid, completion: {
                        (flowDefinition: ISPushFlowDefinition) -> Void in
                        self.currentFlow = flowDefinition
                        self.btNext.addTarget(self, action: #selector(self.moveToNextStep), for: UIControlEvents.touchUpInside)
                        self.setupNextStep(self.currentFlow!.entry)
                        self.flowIsLoaded = true
                        
                        if let delegates = self.delegates {
                            for delegate in delegates where delegate.didFinishLoadFlow != nil {
                                delegate.didFinishLoadFlow!(self)
                            }
                        }
                        
                        self.reloadCurrentFlowSection()
                    })
                }
            }
        })
    }
    
    func updateTopViewHeight(_ newHeight:CGFloat) {
        if let delegates = delegates {
            for delegate in delegates where delegate.onBoundsChanged != nil{
                delegate.onBoundsChanged!(self, currentPollHeight: newHeight)
            }
        }
    }
    
    func moveToNextStep() {
        if self.flowRule != nil {
            responses.append(self.getResponse())
            setupNextStep(self.flowRule?.destination)
            
            reloadCurrentFlowSection()
            
        } else {
            UIAlertView(title: nil, message: sendingAnswerError, delegate: self, cancelButtonTitle: "OK").show()
        }
    }
    
    func unselectResponses() {
        let viewResponsesChildren = viewResponses.subviews as! [ISPushResponseView]
        for responseView in viewResponsesChildren {
            if(responseView.flowRule.uuid != self.flowRule!.uuid) {
                responseView.unselectResponse()
            }
        }
    }
    
    func getCurrentPollHeight() -> CGFloat {
        return constraintHeaderHeight.constant + constraintQuestionHeight.constant + constraintResponseHeight.constant + 66 + btSwitchLanguage.frame.size.height
    }
    
    func getResponse() -> ISPushRulesetResponse {
        return ISPushRulesetResponse(rule: self.flowRule!, response: self.response!)
    }
    
    fileprivate func getResponseFromRule(_ rule:ISPushFlowRule) -> String {
        var response = rule.test?.base
        if response == nil && rule.test?.test != nil
            && rule.test?.test.values.count > 0 {
            response = rule.test?.test[(flowDefinition?.baseLanguage)!]
        }
        return response!
    }
    
    func setupData(_ flowDefinition: ISPushFlowDefinition, flowActionSet: ISPushFlowActionSet, flowRuleset:ISPushFlowRuleset?, contact:ISPushContact) {
        self.flowRule = nil
        self.response = nil
        
        self.contact = contact
        self.flowDefinition = flowDefinition
        self.flowRuleset = flowRuleset
        self.flowActionSet = flowActionSet
        self.lbFlowName.text = flowDefinition.metadata?.name
        
        self.btNext.isHidden = false
        
        setupNextStep()
    }
    
    func setupDataWithNoAnswer(_ flowDefinition: ISPushFlowDefinition?, flowActionSet: ISPushFlowActionSet?, flowRuleset:ISPushFlowRuleset?, contact:ISPushContact?) {
        self.flowRule = nil
        self.response = nil
        
        self.contact = contact
        self.flowDefinition = flowDefinition
        self.flowRuleset = flowRuleset
        self.flowActionSet = flowActionSet
        self.lbFlowName.text = flowDefinition?.metadata?.name
        
        removeAnswersViewOfLastQuestion()
        setupLanguages()
        setupQuestionTitle()
        
        self.btNext.isHidden = true
        self.constraintResponseHeight.constant = CGFloat(viewResponses.subviews.count * responseHeight)
    }
    
    func setupNextStep() {
        setupLanguages()
        setupQuestionTitle()
        setupQuestionAnswers()
    }
    
    func getChoiceResponse(_ flowRule:ISPushFlowRule, frame:CGRect) -> ISPushResponseView {
        let choiceResponseView = Bundle(for: ISPushCurrentPollView.self).loadNibNamed("ISPushChoiceResponseView", owner: self, options: nil)?[0] as! ISPushChoiceResponseView
        choiceResponseView.frame = frame
        choiceResponseView.delegate = self
        return choiceResponseView
    }
    
    func getOpenFieldResponse(_ flowRule:ISPushFlowRule, frame:CGRect) -> ISPushResponseView {
        let openFieldResponseView = Bundle(for: ISPushCurrentPollView.self).loadNibNamed("ISPushOpenFieldResponseView", owner: self, options: nil)?[0] as! ISPushOpenFieldResponseView
        openFieldResponseView.frame = frame
        openFieldResponseView.delegate = self
        return openFieldResponseView
    }
    
    fileprivate func setupLanguages() {
        for action in flowActionSet!.actions! {
            for key in action.message.keys {
                languages.insert(key)
            }
        }
        
        btSwitchLanguage.isHidden = languages.count <= 1
        
        actionSheetLanguage = UIAlertController(title: nil, message: switchLanguageTitle, preferredStyle: .actionSheet)
        
//        for language in languages.sort() {
//            let languageDescription = ISPushCountry.getLanguageDescription(language, type: ISPushCountryCodeType.ISO3) ?? language
//            
//            let switchLanguageAction = UIAlertAction(title: languageDescription, style: .Default, handler: {
//                (alert: UIAlertAction!) -> Void in
//                
//                ISPushSettings.savePreferedLanguage(language)
//                
//                self.selectedLanguage = language
//                self.setupQuestionTitle()
//                for responseView in self.viewResponses.subviews as! [ISPushResponseView] {
//                    responseView.selectedLanguage = language
//                }
//
//            })
//            actionSheetLanguage.addAction(switchLanguageAction)
//        }
        
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        actionSheetLanguage.addAction(cancelAction)
    }
    
    fileprivate func setupQuestionTitle() {
        self.lbQuestion.htmlText = ISPushFlowManager.translateFields(contact, message: (flowActionSet?.actions?[0].message == nil || flowActionSet?.actions?[0].message.count == 0 ? noAnswerTitle : flowActionSet?.actions?[0].message[getSelectedLanguage()])!)
        self.lbQuestion.delegate = self
        let sizeThatFitsTextView = lbQuestion.sizeThatFits(CGSize(width: lbQuestion.frame.size.width, height: CGFloat.greatestFiniteMagnitude));
        constraintQuestionHeight.constant = sizeThatFitsTextView.height;
    }
    
    fileprivate func removeAnswersViewOfLastQuestion() {
        let array = self.viewResponses.subviews as [UIView]
        for view in array {
            view.removeFromSuperview()
        }
    }
    
    fileprivate func setupQuestionAnswers() {
        
        removeAnswersViewOfLastQuestion()
        
        guard let flowRuleset = flowRuleset else {
            self.constraintResponseHeight.constant = 0
            return
        }
        
        for flowRule in (flowRuleset.rules)! {
            if !ISPushFlowManager.hasRecursiveDestination(flowDefinition, ruleSet: flowRuleset, rule: flowRule) {
                
                let frame = CGRect(x: 0, y: CGFloat(viewResponses.subviews.count * responseHeight), width: viewResponses.frame.width, height: CGFloat(responseHeight))
                var responseView:ISPushResponseView?
                
                let typeValidation = flowTypeManager.getTypeValidationForRule(flowRule)
                switch typeValidation.type! {
                case ISPushFlowType.openField:
                    responseView = getOpenFieldResponse(flowRule, frame: frame)
                    break
                case ISPushFlowType.choice:
                    responseView = getChoiceResponse(flowRule, frame: frame)
                    break
                case ISPushFlowType.number:
                    responseView = getOpenFieldResponse(flowRule, frame: frame)
                    break
                default: break
                }
                
                responseView?.setFlowRule(flowDefinition, flowRule: flowRule)
                responseView?.selectedLanguage = self.selectedLanguage
                self.viewResponses.addSubview(responseView!)
                self.constraintResponseHeight.constant = CGFloat(viewResponses.subviews.count * responseHeight)
            }
        }
    }
    
    fileprivate func getSelectedLanguage() -> String {
        return (selectedLanguage != nil && (flowActionSet?.actions?[0].message.keys.contains(selectedLanguage!))! ? selectedLanguage : flowDefinition.baseLanguage)!
    }
}
