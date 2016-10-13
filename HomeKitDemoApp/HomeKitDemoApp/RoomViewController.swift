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
        
        let switchState:Bool = (selectedLight?.lightState.on.boolValue)!
        self.controlSwitch.setOn(switchState, animated: true)
        self.controlSwitch.addTarget(self, action:#selector(RoomViewController.switchValueChangedAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        self.slider.value = ((selectedLight?.lightState.brightness.floatValue)! / 250.0)
        self.brightnessValueLbl.text = "\(self.slider.value * 250)"
        self.brightnessValueLbl.accessibilityHint = "Brightness of the Hue lamp is \(self.brightnessValueLbl.text)"
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
    
    func changeLightColor(){
//        let lightState:PHLightState = PHLightState.init()
    
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
                let alertView:UIAlertView = UIAlertView(title: "Error !", message:error.debugDescription, delegate: nil, cancelButtonTitle: "OK");
                alertView.show();
            }
        })
        
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
