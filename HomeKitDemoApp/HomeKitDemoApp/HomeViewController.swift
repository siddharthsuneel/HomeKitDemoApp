//
//  HomeViewController.swift
//  HomeKitDemoApp
//
//  Created by Siddharth Suneel on 21/09/16.
//  Copyright © 2016 SiddharthSuneel. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet var homeButton: UIButton!
    @IBOutlet var addBeaconButton: UIButton!
    var homeKitUtil:HomeKitUtility? = HomeKitUtility.sharedInstance
    
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
        
        let rightButton = UIBarButtonItem(title: "Find Bridge", style: UIBarButtonItemStyle.Done , target: self, action:#selector(HomeViewController.rightBarbuttonAction))
        self.navigationItem.rightBarButtonItem = rightButton
        
        homeButton.layer.cornerRadius = homeButton.frame.size.width / 2
        homeButton.layer.borderColor = UIColor.blueColor().CGColor
        homeButton.layer.borderWidth = 2.0
        
        addBeaconButton.layer.cornerRadius = addBeaconButton.frame.size.width / 2
        addBeaconButton.layer.borderColor = UIColor.blueColor().CGColor
        addBeaconButton.layer.borderWidth = 2.0
    }
    
    func rightBarbuttonAction(){
        homeKitUtil?.initializeHomeKit()
    }
    
}
