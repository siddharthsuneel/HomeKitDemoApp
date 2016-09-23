//
//  HomeKitUtility.swift
//  HomeKitDemoApp
//
//  Created by Siddharth Suneel on 23/09/16.
//  Copyright © 2016 SiddharthSuneel. All rights reserved.
//

import UIKit
import HomeKit

class HomeKitUtility: NSObject, HMHomeManagerDelegate, HMHomeDelegate {
    
    var homeManager = HMHomeManager()
    var homes:NSMutableArray! = []
    var accessories:NSMutableArray! = []

    
    class var sharedInstance: HomeKitUtility {
        struct Static {
            static var instance: HomeKitUtility?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = HomeKitUtility()
            
            
        }
        
        return Static.instance!
    }

    //MARK: - Initialisation Methods
    func initializeHomeKit(){
        print("initializing HomeKit");
        self.homeManager.delegate = self;
    }

}
