//
//  ViewController.swift
//  HomeKitDemoApp
//
//  Created by Siddharth Suneel on 05/09/16.
//  Copyright © 2016 SiddharthSuneel. All rights reserved.
//

import UIKit

class ConnectcBridgeVC: UIViewController {

    @IBOutlet var bridgeLbl: UILabel!
    
    @IBOutlet var connectBridgeBtn: UIButton!
    var homeKitUtil:HomeKitUtility? = HomeKitUtility.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialSetup()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: Private Methods
    
    func initialSetup(){
        homeKitUtil?.initializeHomeKit()
        
        connectBridgeBtn.layer.borderWidth = 1.0
        connectBridgeBtn.layer.borderColor = UIColor.blackColor().CGColor
        
    }
    
    @IBAction func connectBridgeAction(sender: AnyObject) {
        
//        let vc = AppliancesVC(nibName: "AppliancesVC", bundle: nil)
//        navigationController?.pushViewController(vc, animated: true)

        
//        let obj = self.storyboard?.instantiateViewControllerWithIdentifier("AppliancesVC") as! AppliancesVC
//        self.navigationController?.pushViewController(obj, animated: true)
        
        let obj = self.storyboard?.instantiateViewControllerWithIdentifier("RoomVC") as! RoomVC
        self.navigationController?.pushViewController(obj, animated: true)
        
    }

}

