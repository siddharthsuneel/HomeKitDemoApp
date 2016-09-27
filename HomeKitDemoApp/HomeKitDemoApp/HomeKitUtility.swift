//
//  HomeKitUtility.swift
//  HomeKitDemoApp
//
//  Created by Siddharth Suneel on 23/09/16.
//  Copyright © 2016 SiddharthSuneel. All rights reserved.
//

import UIKit
import HomeKit

class HomeKitUtility: NSObject, HMHomeManagerDelegate, HMHomeDelegate, HMAccessoryDelegate, HMAccessoryBrowserDelegate {
    
    var homeManager = HMHomeManager()

    var phHueSDK : PHHueSDK?
    var bridgeSearch:PHBridgeSearching?
    var phResourcesCache:PHBridgeResourcesCache?
    var bridgesFound : Dictionary<String,String>?
    var phNotificationManager : PHNotificationManager = PHNotificationManager.defaultManager()
    
    var homes:Array<HMHome> = [];
    var accessories:Array<HMAccessory> = [];
    var phAccessories:Array<PHLight> = [];
    var selectedPhAccessories:Array<PHLight> = [];
    
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
        let timer = NSTimer(timeInterval: 10, target: self, selector: #selector(HomeKitUtility.loadConnectedBridgeValues), userInfo: nil, repeats: true);
        timer.fire();
        
        print("initializing HomeKit");
        self.homeManager.delegate = self;
    }

    func initializePHHueSDK(){
        self.phHueSDK = PHHueSDK();
        self.phHueSDK!.startUpSDK();
        self.phHueSDK!.enableLogging(true);
        self.enableLocalHeartbeat();
    }
    
    func registerPHHueSDKNotifications(){
        self.phNotificationManager.registerObject(self, withSelector: #selector(HomeKitUtility.checkConnectionState), forNotification: LOCAL_CONNECTION_NOTIFICATION);
        self.phNotificationManager.registerObject(self, withSelector: #selector(HomeKitUtility.noLocalConnection), forNotification: NO_LOCAL_CONNECTION_NOTIFICATION);
//        self.phNotificationManager.registerObject(self, withSelector: #selector("notAuthenticated"), forNotification: NO_LOCAL_AUTHENTICATION_NOTIFICATION);
        self.phNotificationManager.registerObject(self, withSelector: #selector(HomeKitUtility.authenticationSuccess), forNotification: PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION);
        self.phNotificationManager.registerObject(self, withSelector: #selector(HomeKitUtility.authenticationFailed), forNotification: PUSHLINK_LOCAL_AUTHENTICATION_FAILED_NOTIFICATION);
        self.phNotificationManager.registerObject(self, withSelector: #selector(HomeKitUtility.noLocalBridge), forNotification: PUSHLINK_NO_LOCAL_BRIDGE_KNOWN_NOTIFICATION);
        self.phNotificationManager.registerObject(self, withSelector: #selector(HomeKitUtility.buttonNotPressed(_:)), forNotification: PUSHLINK_BUTTON_NOT_PRESSED_NOTIFICATION);
        
    }
    
    func enableLocalHeartbeat() {
        /***************************************************
         The heartbeat processing collects data from the bridge
         so now try to see if we have a bridge already connected
         *****************************************************/
        
        self.phResourcesCache = PHBridgeResourcesReader.readBridgeResourcesCache();
        
        if self.phResourcesCache == nil {
            
            // Automaticly start searching for bridges if cache is nil
            self.searchForBridgeLocal();
            
        }
        else{
            
            if self.phResourcesCache!.bridgeConfiguration != nil && self.phResourcesCache!.bridgeConfiguration.ipaddress != nil {
                print("connecting");
                
                // Enable heartbeat with interval of 10 seconds
                self.phHueSDK?.enableLocalConnection();
            }
            else{
                // Automaticly start searching for bridges
                self.searchForBridgeLocal();
            }
        }
        
    }
    
    func disableLocalHeartbeat() {
        self.phHueSDK?.disableLocalConnection();
    }
    func loadConnectedBridgeValues(){
        /***************************************************
         The heartbeat processing collects data from the bridge
         so now try to see if we have a bridge already connected
         *****************************************************/
        
        if(self.phHueSDK != nil){
            
            self.phResourcesCache = PHBridgeResourcesReader.readBridgeResourcesCache();
            
            if self.phResourcesCache == nil {
                
                // Automaticly start searching for bridges
                self.searchForBridgeLocal();
                
            }
            else{
                
                if self.phResourcesCache!.bridgeConfiguration != nil && self.phResourcesCache!.bridgeConfiguration.ipaddress != nil {
                    self.phAccessories.removeAll(keepCapacity: false);
                    
                    if(self.phResourcesCache!.lights != nil){
                        for object in self.phResourcesCache!.lights {
                            
                            let light:PHLight = object.1 as! PHLight;
                            
                            if(light.lightState.reachable.boolValue){
                                print(light);
                                self.phAccessories.append(light);
                            }
                            
                        }
                    }
                    
                }
            }
            
        }
        
    }
    
    func searchForBridgeLocal(){
        self.disableLocalHeartbeat();
        
        self.bridgeSearch = PHBridgeSearching(upnpSearch: true, andPortalSearch: true, andIpAdressSearch: true)
        self.bridgeSearch!.startSearchWithCompletionHandler({ bridgesFound -> Void in
        
            if bridgesFound.count > 0{
                
                self.bridgesFound = (bridgesFound as? Dictionary<String,String>)
                let macAddress:String = self.bridgesFound!.keys.first!
                let ipAddress:String = self.bridgesFound![macAddress]!
                
                self.phHueSDK?.setBridgeToUseWithIpAddress(ipAddress, macAddress: macAddress)
                self.phHueSDK?.startPushlinkAuthentication()
                
            }
            else{
                self.bridgesFound = nil
                self.searchForBridgeLocal()
            }
            
        })
        
    }
    
    func startBridgeAuthentication(){
        
        let alertView:UIAlertView = UIAlertView(title: "", message:"Please click Bridge Button for authentication", delegate: nil, cancelButtonTitle: "Ok");
        alertView.show();
        
        self.phHueSDK?.startPushlinkAuthentication();
    }
    
    
    //MARK:- Notification Functions
    
    /**
     Notification receiver which is called when the pushlinking was successful
     */
    
    func checkConnectionState() {
        if (self.phHueSDK!.localConnected() == false) {
            // Dismiss modal views when connection is lost
            
            print ("No connection at all");
            // No connection at all, show connection popup
            
        }
        else {
            
            print ("One of the connections is made");
            // One of the connections is made, remove popups and loading views
            
        }
    }

    func authenticationSuccess() {
        /***************************************************
         The notification PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION
         was received. We have confirmed the bridge.
         De-register for notifications and call
         pushLinkSuccess on the delegate
         *****************************************************/
        
        let alertView:UIAlertView = UIAlertView(title: "", message:"Authentication is successful", delegate: nil, cancelButtonTitle: "Ok");
        alertView.show();
        // Deregister for all notifications
        self.phNotificationManager.deregisterObjectForAllNotifications(self);
        
        self.phResourcesCache = PHBridgeResourcesReader.readBridgeResourcesCache();
        
        if self.phResourcesCache == nil {
            
            // Automaticly start searching for bridges
            self.searchForBridgeLocal();
            
        }
        else{
            print(self.phResourcesCache?.lights);
        }
        
        // Inform delegate
        //    [self.delegate pushlinkSuccess];
    }
    
    /**
     Notification receiver which is called when the pushlinking failed because the time limit was reached
     */
    func authenticationFailed() {
        let alertView:UIAlertView = UIAlertView(title: "", message:"Authentication failed", delegate: nil, cancelButtonTitle: "Ok");
        alertView.show();
    }
    
    /**
     Notification receiver which is called when the pushlinking failed because the local connection to the bridge was lost
     */
    func noLocalConnection() {
        
    }
    
    /**
     Notification receiver which is called when the pushlinking failed because we do not know the address of the local bridge
     */
    func noLocalBridge() {

    }
    
    /**
     This method is called when the pushlinking is still ongoing but no button was pressed yet.
     @param notification The notification which contains the pushlinking percentage which has passed.
     */
    func buttonNotPressed(notification:NSNotification) {
        
    }

}
