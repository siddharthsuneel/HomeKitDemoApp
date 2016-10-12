//
//  HomeViewController.swift
//  HomeKitDemoApp
//
//  Created by Siddharth Suneel on 21/09/16.
//  Copyright © 2016 SiddharthSuneel. All rights reserved.
//

import UIKit
import HomeKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,HomeKitConnectionDelegate {

    @IBOutlet var statusValueLbl: UILabel!
    @IBOutlet var statusLbl: UILabel!
    @IBOutlet var mainTableView: UITableView!
    @IBOutlet var addBeaconButton: UIButton!
    @IBOutlet var bridgeIdLbl: UILabel!
    @IBOutlet var ipAddlbl: UILabel!
    @IBOutlet var ipAddValueLbl: UILabel!
    @IBOutlet var bridgeIdValueLbl: UILabel!
    
    var homes:Array<HMHome>? = []
    var lightsArray:NSMutableArray = []
    
    var homeKitUtil:HomeKitUtility? = HomeKitUtility.sharedInstance
    var cache:PHBridgeResourcesCache?
    
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
        
        self.title = "DMI HomeKit App"
        homeKitUtil?.connectionDelegate = self
        let rightButton = UIBarButtonItem(title: "Find Bridge", style: UIBarButtonItemStyle.Done , target: self, action:#selector(HomeViewController.rightBarbuttonAction))
        self.navigationItem.rightBarButtonItem = rightButton
       
    }
    
    func rightBarbuttonAction(){
        homeKitUtil?.searchForBridgeLocal()
    }
    
    // MARK: - Table View Data Source + Delegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 5
        return (self.lightsArray.count) + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") ??
            UITableViewCell.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        
        if (indexPath.row == 0) {
            cell.textLabel?.text = "List Of Available Lights"
            cell.textLabel?.font = UIFont.boldSystemFontOfSize(20.0)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
        }
        else{
            let dict: PHLight = (self.lightsArray.objectAtIndex(indexPath.row - 1) as? PHLight)!
            cell.textLabel?.text = dict.name
            if (dict.lightState.reachable == 1) {
                 cell.detailTextLabel?.text = "Available/Reachable"
            }
            else{
                cell.detailTextLabel?.text = "Not Available/Not Reachable"
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.Default
        }

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row != 0) {
            let dict: PHLight = (self.lightsArray.objectAtIndex(indexPath.row - 1) as? PHLight)!
            let roomVC:RoomViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("RoomViewController") as! RoomViewController
            roomVC.title = dict.name
            roomVC.selectedLight = dict
            self.navigationController?.pushViewController(roomVC, animated: true)
        }
    }
    
    //MARK :- HomeKit Connection Delegate Method
    
    func connectionUpdated() {
        cache = PHBridgeResourcesReader.readBridgeResourcesCache()
        
        if (cache != nil && cache?.bridgeConfiguration != nil && cache?.bridgeConfiguration.ipaddress != nil) {
            self.bridgeIdValueLbl.text = cache?.bridgeConfiguration.bridgeId
            self.ipAddValueLbl.text = cache?.bridgeConfiguration.ipaddress
            self.navigationItem.rightBarButtonItem?.enabled = false
            if(cache!.lights != nil){
                self.lightsArray.removeAllObjects()
                for object in self.cache!.lights.values {
                    //                    print(object)
                    self.lightsArray.addObject(object)
                }
                self.mainTableView.reloadData()
            }
        }
        
        if  (homeKitUtil!.phHueSDK!.localConnected() == false){
            self.statusValueLbl.text = "Not Connected"
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
        else{
            self.statusValueLbl.text = "Connected"
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
        
    }
    
    
}
