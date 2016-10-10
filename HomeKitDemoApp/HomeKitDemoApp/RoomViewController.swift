//
//  RoomViewController.swift
//  HomeKitDemoApp
//
//  Created by Siddharth Suneel on 07/10/16.
//  Copyright © 2016 SiddharthSuneel. All rights reserved.
//

import UIKit

class RoomViewController: UIViewController {
    
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var slider: UISlider!
    @IBOutlet var controlSwitch: UISwitch!
    
    var redBtn:UIButton?
    var blueBtn:UIButton?
    var greenBtn:UIButton?
    var yellowBtn:UIButton?
    var effect1btn:UIButton?
    var effect2btn:UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUp()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUp(){
        self.view.backgroundColor = UIColor.whiteColor()
        
//        redBtn = UIButton(frame: CGRectZero)
//        redBtn?.backgroundColor = UIColor.redColor()
//        redBtn?.layer.borderColor = UIColor.blackColor().CGColor
//        redBtn?.layer.borderWidth = 1.0
//        self.view.addSubview(redBtn!)
//        
//        blueBtn = UIButton(frame: CGRectZero)
//        blueBtn?.backgroundColor = UIColor.redColor()
//        blueBtn?.layer.borderColor = UIColor.blackColor().CGColor
//        blueBtn?.layer.borderWidth = 1.0
//        self.view.addSubview(blueBtn!)
//        
//        greenBtn = UIButton(frame: CGRectZero)
//        greenBtn?.backgroundColor = UIColor.redColor()
//        greenBtn?.layer.borderColor = UIColor.blackColor().CGColor
//        greenBtn?.layer.borderWidth = 1.0
//        self.view.addSubview(greenBtn!)
//        
//        yellowBtn = UIButton(frame: CGRectZero)
//        yellowBtn?.backgroundColor = UIColor.redColor()
//        yellowBtn?.layer.borderColor = UIColor.blackColor().CGColor
//        yellowBtn?.layer.borderWidth = 1.0
//        self.view.addSubview(yellowBtn!)
//        
//        effect1btn = UIButton(frame: CGRectZero)
//        effect1btn?.backgroundColor = UIColor.redColor()
//        effect1btn?.layer.borderColor = UIColor.blackColor().CGColor
//        effect1btn?.layer.borderWidth = 1.0
//        self.view.addSubview(effect1btn!)
//        
//        effect2btn = UIButton(frame: CGRectZero)
//        effect2btn?.backgroundColor = UIColor.redColor()
//        effect2btn?.layer.borderColor = UIColor.blackColor().CGColor
//        effect2btn?.layer.borderWidth = 1.0
//        self.view.addSubview(effect2btn!)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
//        let btnSize:CGFloat = 75.0
//        
//        redBtn?.layer.cornerRadius = btnSize/2
//        blueBtn?.layer.cornerRadius = btnSize/2
//        greenBtn?.layer.cornerRadius = btnSize/2
//        yellowBtn?.layer.cornerRadius = btnSize/2
//        effect1btn?.layer.cornerRadius = btnSize/2
//        effect2btn?.layer.cornerRadius = btnSize/2
//        
//        let vPadding:CGFloat = 50.0
//        let hPadding:CGFloat = 30.0
//        
//        var x = CGRectGetMaxX(slider.frame)
//        var y = CGRectGetMaxY(slider.frame)
//        y = y + vPadding
//        redBtn?.frame = CGRectMake(x, y, btnSize, btnSize)
//        
//        x =
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
