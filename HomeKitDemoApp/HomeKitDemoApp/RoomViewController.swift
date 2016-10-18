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
    @IBOutlet var brightnessValueLbl: UILabel!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var bluebutton: UIButton!
    @IBOutlet weak var redbutton: UIButton!
    
    var selectedLight:PHLight?
    var bridgeSendAPI:PHBridgeSendAPI? = PHBridgeSendAPI()
    
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        let backButton = UIBarButtonItem(
            title: "Back",
            style: UIBarButtonItemStyle.Plain, // Note: .Bordered is deprecated
            target: nil,
            action: nil
        )
        self.navigationController!.navigationBar.topItem!.backBarButtonItem = backButton
        self.accessSetup();
        let switchState:Bool = (selectedLight?.lightState.on.boolValue)!
        self.controlSwitch.setOn(switchState, animated: true)
        self.controlSwitch.addTarget(self, action:#selector(RoomViewController.switchValueChangedAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        self.slider.value = ((selectedLight?.lightState.brightness.floatValue)! / 250.0)
        self.brightnessValueLbl.text = "\(self.slider.value * 250)"
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    func switchValueChangedAction(aSwitch:UISwitch){
        let lightState:PHLightState = PHLightState.init()
        
        let value = aSwitch.on
        lightState.setOnBool(value)
        self.updateLightState((self.selectedLight?.identifier)!, aLightState: lightState)
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        let lightState:PHLightState = PHLightState.init()
        let brightness = Int(sender.value * 250)
        self.brightnessValueLbl.text = "\(brightness)"
        lightState.brightness = NSNumber.init(integer: brightness)
        self.updateLightState((self.selectedLight?.identifier)!, aLightState: lightState)
    }
    
    
    func updateLightState(aLightIdentifier:String, aLightState:PHLightState){
        bridgeSendAPI?.updateLightStateForId(aLightIdentifier, withLightState: aLightState, completionHandler: { (error) in
            if error != nil{
                let alertView:UIAlertView = UIAlertView(title: "Error !", message:error.description, delegate: nil, cancelButtonTitle: "OK");
                alertView.show();
            }
        })
        
    }

    @IBAction func redBtnClick(sender: AnyObject) {
        let lightState:PHLightState = PHLightState.init()
        lightState.hue = NSNumber.init(int: 0)
        lightState.saturation = NSNumber.init(int: 100)
        self.updateLightState((self.selectedLight?.identifier)!, aLightState: lightState)
    }
    
    
    @IBAction func blueBtnClick(sender: AnyObject) {
        let lightState:PHLightState = PHLightState.init()
        lightState.x = NSNumber.init(float: 0.229)
        lightState.y = NSNumber.init(float: 0.1559)
        self.updateLightState((self.selectedLight?.identifier)!, aLightState: lightState)
    }
    
    
    @IBAction func yellowBtnClick(sender: AnyObject) {
        let lightState:PHLightState = PHLightState.init()
        lightState.x = NSNumber.init(float: 0.859)
        lightState.y = NSNumber.init(float: 0.899)
        self.updateLightState((self.selectedLight?.identifier)!, aLightState: lightState)
    }
    
   
    func accessSetup(){
        let value = (selectedLight?.lightState.brightness.floatValue)!

        let msgStr : String = "You are on the Room screen. You can set the brightness and color of the light of Hue Lamp. Scroll the slider left or right to set the brightness and in oder to set the color of the light tap on the color. Current brightness of the Hue lamp is \(value)"
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, msgStr);

    }
    
}
