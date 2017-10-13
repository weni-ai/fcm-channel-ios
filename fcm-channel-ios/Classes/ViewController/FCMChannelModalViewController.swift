////
////  FCMChannelModalViewController.swift
////  IlhasoftSample
////
////  Created by Daniel Amaral on 30/05/16.
////  Copyright © 2016 ilhasoft. All rights reserved.
////
//
//import UIKit
//
//open class FCMChannelModalViewController: ISModalViewController, FCMChannelCurrentPollViewDelegate, UIGestureRecognizerDelegate {
//
//    @IBOutlet var backgroundView:UIView!
//    @IBOutlet var heightConstraint:NSLayoutConstraint!
//
//    var contact:FCMChannelContact!
//    open var currentPollView:FCMChannelCurrentPollView!
//
//    override open func viewDidLoad() {
//        super.viewDidLoad()
//    }
//
//    open override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        setupUdoView()
//
//        if !RapidProAPI.sendingAnswers && !currentPollView.flowIsLoaded {
//            currentPollView.loadCurrentFlow()
//        }
//    }
//
//    open override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        currentPollView.frame = CGRect(x: 0, y: 0, width: self.backgroundView.frame.size.width, height: currentPollView.frame.size.height)
//    }
//
//    public init(contact:FCMChannelContact,currentPollView:FCMChannelCurrentPollView) {
//        self.contact = contact
//        self.currentPollView = currentPollView
//        super.init(nibName: "FCMChannelModalViewController", bundle: Bundle(for: FCMChannelModalViewController.self))
//        self.currentPollView.delegates!.append(self)
//    }
//
//    required public init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    //MARK: FCMChannelCurrentPollViewDelegate
//
//    open func onBoundsChanged(_ currentPollView: FCMChannelCurrentPollView, currentPollHeight: CGFloat) {
//        self.heightConstraint.constant = currentPollHeight
//        UIView.animate(withDuration: 0.3, animations: {
//            self.backgroundView.layer.opacity = 1
//        })
//    }
//
//    //MARK: Class Methods
//
//    fileprivate func setupUdoView() {
//
//        self.backgroundView.addSubview(currentPollView)
//        currentPollView.btNext.backgroundColor = UIColor.black
//
//        self.view.isUserInteractionEnabled = true
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(close))
//        tapGesture.delegate = self
//        tapGesture.numberOfTapsRequired = 1
//        self.view.addGestureRecognizer(tapGesture)
//
//    }
//
//    //MARK: UIGestureRecognizerDelegate
//
//    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//
//        if !self.backgroundView.bounds.contains(touch.location(in: self.backgroundView)) {
//            return true
//        }
//
//        return false
//    }
//
//}

