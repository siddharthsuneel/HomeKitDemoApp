//
//  HomeViewController.swift
//  HomeKitDemoApp
//
//  Created by Siddharth Suneel on 21/09/16.
//  Copyright © 2016 SiddharthSuneel. All rights reserved.
//

import UIKit
import HomeKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet var homeButton: UIButton!
    @IBOutlet var addBeaconButton: UIButton!
    var homes:Array<HMHome>?
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
        homeButton.hidden = true
//        addBeaconButton.layer.cornerRadius = addBeaconButton.frame.size.width / 2
//        addBeaconButton.layer.borderColor = UIColor.blueColor().CGColor
//        addBeaconButton.layer.borderWidth = 2.0
    }
    
    func rightBarbuttonAction(){
        homeKitUtil?.initializeHomeKit()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") ??
            UITableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        
        if(indexPath.row == 4){
            cell.textLabel?.text = "Add Home"
        }
        else{
            cell.textLabel?.text = "Home"
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row == 4){
            self.addHomeMethod()
        }
        else{
            self.segueToSelectedHome()
        }
    }
    
    //MARK :- Private Methods
    
    func addHomeMethod(){
        let alert:UIAlertController = UIAlertController(title: "Add Home", message: "Add new home to current list of homes", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler(nil)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction!) -> Void in
            
            let textField = alert.textFields?[0]
            
            if(HomeKitUtility.sharedInstance.isPrimaryHomeExist(textField!.text) == false){
                
                HomeKitUtility.sharedInstance.addHome(textField!.text, completionHandler: { (success, error:NSError?) -> Void in
                    if(success){
                        self.homes = HomeKitUtility.sharedInstance.homes;
                        self.homes?.sortInPlace({ (home1:HMHome, home2:HMHome) -> Bool in
                            home1.name < home2.name;
                        });
                        
                        self.mainTableView.reloadData();
                    }
                })
            }
            else{
                
                let alertView:UIAlertView = UIAlertView(title: "Home already exist", message: "Home with \(textField!.text) is already existing.", delegate: nil, cancelButtonTitle: "Ok");
                alertView.show();
            }
            
        }));
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func segueToSelectedHome(){
               
    }
}
