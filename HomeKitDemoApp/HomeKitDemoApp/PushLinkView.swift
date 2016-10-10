//
//  PushLinkView.swift
//  HomeKitDemoApp
//
//  Created by Siddharth Suneel on 28/09/16.
//  Copyright © 2016 SiddharthSuneel. All rights reserved.
//

import UIKit

class PushLinkView: UIView,PushLinkDelegate {

    @IBOutlet var progressView: UIProgressView!
    let homeKitUtil:HomeKitUtility? = HomeKitUtility.sharedInstance
    
    func initWithNib()-> UIView{
        self.setUp()
        return UINib(nibName: "PushLinkView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
        
    }
    
    func setUp(){
        homeKitUtil?.pushLinkDelegate = self
    }
    
    func buttonNotPressedTime(timeLeft: Float) {
        self.progressView.progress = timeLeft
    }
    
}
