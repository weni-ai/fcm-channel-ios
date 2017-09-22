//
//  ISModalViewController.swift
//  IlhasoftCore
//
//  Created by Daniel Amaral on 01/04/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

open class ISModalViewController: UIViewController {

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor!.withAlphaComponent(0)
    }
    
    //MARK: Class Methods
    
    open func closeWithCompletion(_ completion:@escaping (Void) -> Void) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.backgroundColor = self.view.backgroundColor?.withAlphaComponent(0)
        }, completion: { (finished) -> Void in
            self.dismiss(animated: true, completion: nil)
            completion()
        }) 
    }
    
    open func close() -> Void {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.backgroundColor = self.view.backgroundColor?.withAlphaComponent(0)
        }, completion: { (finished) -> Void in
            self.dismiss(animated: true, completion: nil)
        }) 
    }
    
    open func show(_ animated:Bool,inViewController:UIViewController){
        if animated == true {
            self.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            inViewController.present(self, animated: animated) { () -> Void in
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.view.backgroundColor  = UIColor.black.withAlphaComponent(0.5)
                }) 
            }
        }
    }

    open func show(_ animated: Bool, inViewController viewController:UIViewController, withCompletion:@escaping (Void) -> Void) {
        if animated == true {
            self.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            viewController.present(self, animated: animated) { () -> Void in
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.view.backgroundColor  = UIColor.black.withAlphaComponent(0.5)
                    withCompletion()
                }) 
            }
        }
    }
    
}
