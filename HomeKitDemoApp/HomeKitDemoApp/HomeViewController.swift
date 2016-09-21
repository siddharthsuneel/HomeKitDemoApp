//
//  HomeViewController.swift
//  HomeKitDemoApp
//
//  Created by Siddharth Suneel on 21/09/16.
//  Copyright © 2016 SiddharthSuneel. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet var addHomeButton: UIButton!
    @IBOutlet var addBeaconButton: UIButton!
    
    // MARK: - View LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUp()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    // MARK: - Private Methods
    
    func setUp(){
        addHomeButton.layer.cornerRadius = addHomeButton.frame.size.width / 2
        addHomeButton.layer.borderColor = UIColor.blueColor().CGColor
        addHomeButton.layer.borderWidth = 2.0
        
        addBeaconButton.layer.cornerRadius = addHomeButton.frame.size.width / 2
        addBeaconButton.layer.borderColor = UIColor.blueColor().CGColor
        addBeaconButton.layer.borderWidth = 2.0
    }
    
}
