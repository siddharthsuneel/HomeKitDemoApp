//
//  RoomVC.swift
//  HomeKitDemoApp
//
//  Created by Jyoti on 27/09/16.
//  Copyright © 2016 SiddharthSuneel. All rights reserved.
//


class RoomVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var mainTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")!
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }

}
