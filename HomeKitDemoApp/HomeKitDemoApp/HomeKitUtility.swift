//
//  HomeKitUtility.swift
//  HomeKitDemoApp
//
//  Created by Siddharth Suneel on 23/09/16.
//  Copyright © 2016 SiddharthSuneel. All rights reserved.
//

import UIKit
import HomeKit

@objc protocol PushLinkDelegate {
    
    optional func buttonNotPressedTime(timeLeft:Float)
}

@objc protocol HomeKitConnectionDelegate{
    optional func connectionUpdated()
}

class HomeKitUtility: NSObject, HMHomeManagerDelegate, HMHomeDelegate, HMAccessoryDelegate, HMAccessoryBrowserDelegate {
    
    var pushLinkDelegate: PushLinkDelegate?
    var connectionDelegate: HomeKitConnectionDelegate?
    var homeManager = HMHomeManager()
    
    var phHueSDK : PHHueSDK?
    var bridgeSearch:PHBridgeSearching?
    var phResourcesCache:PHBridgeResourcesCache?
    var bridgesFound : Dictionary<String,String>?
    var accessoryBrowser:HMAccessoryBrowser = HMAccessoryBrowser()
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
        let timer = NSTimer(timeInterval: 60, target: self, selector: #selector(HomeKitUtility.loadConnectedBridgeValues), userInfo: nil, repeats: true);
        timer.fire();
        
        print("initializing HomeKit");
        self.homeManager.delegate = self;
        self.homes.removeAll(keepCapacity: false);
        for home in homeManager.homes{
            self.homes.append(home);
            
        }
        
        self.accessoryBrowser.delegate = self;
        
        self.accessoryBrowser.startSearchingForNewAccessories();
        
        self.initializePHHueSDK();
    }
    
    func isPrimaryHomeExist(homeName:String!) -> Bool{
        
        var isPrimaryHomeExist:Bool = false;
        
        if(homeManager.primaryHome != nil){
            if(homeManager.primaryHome!.name == homeName){
                isPrimaryHomeExist = true;
            }
        }
        else{
            isPrimaryHomeExist = false;
        }
        
        return isPrimaryHomeExist;
    }
    
    func addHome(homeName:String!, completionHandler completion: ((Bool, NSError?) -> Void)!){
        
        print("ADD HOME");
         
        homeManager.addHomeWithName(homeName, completionHandler: { (home:HMHome?, error:NSError?) -> Void in
            if(error != nil){
                print(error);
                completion(false, error);
            }
            else{
                let filteredHomes = self.homes.filter { (_home) -> Bool in
                    _home.name == home!.name;
                };
                if(filteredHomes.count > 0){
                    let index:Int? = self.homes.indexOf(filteredHomes.last!);
                    if(index == nil){
                        self.homes.append(home!);
                    }
                    else{
                        self.homes[index!] = home!;
                    }
                }
                else{
                    self.homes.append(home!);
                }
                completion(true, nil);
            }
        })
        
    }

    func initializePHHueSDK(){
        self.phHueSDK = PHHueSDK();
        self.phHueSDK!.startUpSDK();
        self.phHueSDK!.enableLogging(true);
        self.registerPHHueSDKNotifications();
        self.enableLocalHeartbeat();
    }
    
    func registerPHHueSDKNotifications(){
        self.phNotificationManager.registerObject(self, withSelector: #selector(HomeKitUtility.checkConnectionState), forNotification: LOCAL_CONNECTION_NOTIFICATION);
        self.phNotificationManager.registerObject(self, withSelector: #selector(HomeKitUtility.noLocalConnection), forNotification: NO_LOCAL_CONNECTION_NOTIFICATION);
        //        self.phNotificationManager.registerObject(self, withSelector: Selector("notAuthenticated"), forNotification: NO_LOCAL_AUTHENTICATION_NOTIFICATION);
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
        self.connectionDelegate?.connectionUpdated!()
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
                    self.connectionDelegate?.connectionUpdated!()
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
                print("ipAddress of bridge : " + ipAddress)
                
                self.phHueSDK?.setBridgeToUseWithId(macAddress, ipAddress: ipAddress)
//                self.phHueSDK?.setBridgeToUseWithIpAddress(ipAddress, macAddress: macAddress)
                self.startBridgeAuthentication()
                
            }
            else{
                self.bridgesFound = nil
                self.noBridgeFoundAction()
            }
            
        })
        
    }
    
    func startBridgeAuthentication(){
        
        let alertView:UIAlertView = UIAlertView(title: "", message:"Please click Bridge Button for authentication", delegate: nil, cancelButtonTitle: "Ok");
        alertView.show();
        
        self.phHueSDK?.startPushlinkAuthentication();
    }
    
    //MARK :- Private Methods
    
    func noBridgeFoundAction(){
        
        let alertView:UIAlertView = UIAlertView(title: "Try Again", message:"No Bridge Found", delegate: nil, cancelButtonTitle: "OK");
        alertView.show();
        
    }
    //Mark:- Alert View Delegate Methods
    
    
    
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
            self.connectionDelegate?.connectionUpdated!()
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
        self.connectionDelegate?.connectionUpdated!()
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
//        let alertView:UIAlertView = UIAlertView(title: "", message:"Authentication failed", delegate: nil, cancelButtonTitle: "Ok");
//        alertView.show();
        
        let alertView:UIAlertView = UIAlertView(title: "Try Again", message:"Push link button not pressed !", delegate: nil, cancelButtonTitle: "Ok");
        alertView.show();
    }
    
    /**
     Notification receiver which is called when the pushlinking failed because the local connection to the bridge was lost
     */
    func noLocalConnection() {
        self.connectionDelegate?.connectionUpdated!()
        let alertView:UIAlertView = UIAlertView(title: "Try Again", message:"Connection with Bridge Lost", delegate: nil, cancelButtonTitle: "Ok");
        alertView.show();
    }
    
    /**
     Notification receiver which is called when the pushlinking failed because we do not know the address of the local bridge
     */
    func noLocalBridge() {
        self.connectionDelegate?.connectionUpdated!()
        let alertView:UIAlertView = UIAlertView(title: "Try Again", message:"Local Bridge Not Found", delegate: nil, cancelButtonTitle: "Ok");
        alertView.show();
    }
    
    /**
     This method is called when the pushlinking is still ongoing but no button was pressed yet.
     @param notification The notification which contains the pushlinking percentage which has passed.
     */
    func buttonNotPressed(notification:NSNotification) {
//        let alertView:UIAlertView = UIAlertView(title: "", message:"Push link button not pressed !", delegate: nil, cancelButtonTitle: "Ok");
//        alertView.show();
        
        let dict : NSDictionary = notification.userInfo!
        let progressPercent:AnyObject? = dict.objectForKey("progressPercentage")
        let progressBarValue:Float? = (progressPercent?.floatValue)!/100
        self.pushLinkDelegate?.buttonNotPressedTime!(progressBarValue!)
    }
    
}
