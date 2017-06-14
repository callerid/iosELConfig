//
//  PopupView.swift
//  iosELConfig
//
//  Created by mac on 6/14/17.
//  Copyright © 2017 CallerId.com. All rights reserved.
//

import UIKit

class PopupView: UIViewController {

    var isYesNo = false
    var pubMessage = "none"
    
    @IBOutlet weak var rtbMessage: UITextView!
    @IBOutlet weak var lbTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnNo_Click(_ sender: Any) {
        
        self.view.removeFromSuperview()
        
    }
    
    @IBAction func btnOkay_Click(_ sender: Any) {
        
        if(pubMessage.lowercased().contains("reset") &&
            pubMessage.lowercased().contains("ethernet")){
            ViewController().resetEL()
            
        }
        else if(pubMessage.lowercased().contains("reset") &&
            pubMessage.lowercased().contains("unit")){
            ViewController().resetUnit()
        }
        
        self.view.removeFromSuperview()
        
    }
    
    @IBOutlet weak var btnOkay: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    
    func setText(title: String, message: String,yesOrNo: Bool){
        
        lbTitle.text = title
        rtbMessage.text = message
        pubMessage = message
        
        if(yesOrNo){
            isYesNo = true
            btnOkay.setTitle("Yes", for: UIControlState.normal)
            btnNo.isHidden = false
        }
        
    }

}
