//
//  HomeViewController.swift
//  HomeKitDemoApp
//
//  Created by Siddharth Suneel on 21/09/16.
//  Copyright © 2016 SiddharthSuneel. All rights reserved.
//

import UIKit
import HomeKit
import Speech

var kIdentifierForLight1 = "one"
var kIdentifierForLight2 = "two"
var kIdentifierForLight3 = "three"
var kOnIdentifier = "on"
var kOffIdentifier = "off"

var kKeyForIdentifier = "identifier"

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,HomeKitConnectionDelegate, SFSpeechRecognizerDelegate {

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
    
    //MARK: - SpeechKit Var Initialisation
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var microphoneButton: UIButton!
    
    // handles the speech recognition requests
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    // task where it gives you the result of the recognition
    private var recognitionTask: SFSpeechRecognitionTask?
    
    // audio engine. It is responsible for providing your audio input.
    private let audioEngine = AVAudioEngine()
    
    //en-US - speech recognizer knows what language the user is speaking in. This is the object that handles speech recognition.
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    
    // MARK: - View LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.accessSetUp()
    }
    
    // MARK: - Private Methods
    
    func setUp(){

        self.title = "DMI HomeKit App"
        homeKitUtil?.connectionDelegate = self
        let rightButton = UIBarButtonItem(title: "Find Bridge", style: UIBarButtonItemStyle.done , target: self, action:#selector(HomeViewController.rightBarbuttonAction))
        self.navigationItem.rightBarButtonItem = rightButton
        
        self.navigationItem.rightBarButtonItem?.accessibilityLabel = "Find Bridge"
        self.navigationItem.rightBarButtonItem?.accessibilityHint = "This will start searching the available bridge and shows the list of bridges"

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receiveNotificationForSpeechText),
            name: NSNotification.Name(rawValue: "Command"),
            object: nil)
        
        initialSetup()
        
        authorizeSpeechRecognizer()

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func rightBarbuttonAction(){
        homeKitUtil?.searchForBridgeLocal()
    }
    
    func startSpeakRecognition(){
        
    }
    
    // MARK: - Table View Data Source + Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.lightsArray.count) + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ??
            UITableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        
        if (indexPath.row == 0) {
            cell.textLabel?.text = "List Of Available Lights"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
        }
        else{
            let dict: PHLight = (self.lightsArray.object(at: indexPath.row - 1) as? PHLight)!
            cell.textLabel?.text = "Light " + dict.identifier
            if (dict.lightState.reachable == 1) {
                 cell.detailTextLabel?.text = "Available/Reachable"
                cell.textLabel?.accessibilityLabel = "\(dict.name) is Reachable"
            }
            else{
                cell.detailTextLabel?.text = "Not Available/Not Reachable"
                cell.textLabel?.accessibilityLabel = "\(dict.name) is not Reachable"
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.default
            
        }
        cell.textLabel?.isAccessibilityElement=true
        cell.detailTextLabel?.isAccessibilityElement=false
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row != 0) {
            let dict: PHLight = (self.lightsArray.object(at: indexPath.row - 1) as? PHLight)!
            let roomVC:RoomViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RoomViewController") as! RoomViewController
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
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            if(cache!.lights != nil){
                self.lightsArray.removeAllObjects()
                for object in self.cache!.lights.values {
                    //                    print(object)
                    self.lightsArray.add(object)
                }
                self.mainTableView.reloadData()
            }
        }
        
        if  (homeKitUtil!.phHueSDK!.localConnected() == false){
            self.statusValueLbl.text = "Not Connected"
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        else{
            self.statusValueLbl.text = "Connected"
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
    }
    
    @IBAction func addBeacon(_ sender: AnyObject) {

    }
   
    func accessSetUp(){
        var msgStr : String = "You are at the Home screen."
        if(self.statusValueLbl.text == "Not Connected")
        {
            msgStr += "Bridge is not connected. You need to tap on the find bridge in the top right corner of the screen in order to search for bridge."
        }
        else{
            msgStr += "You connected with the bridge. Please select the connected bridge from the list to proceed further"
        }
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, msgStr);
    }
    
    //MARK: - Speech Recognition Methods
    
    func authorizeSpeechRecognizer()
    {
        //let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
        speechRecognizer?.delegate = self
        
        //authorize the speech recognizer
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus
            {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
    }
    
    func initialSetup()
    {
        microphoneButton.isEnabled = false
    }
    
    
    @IBAction func microphoneTapped(_ sender: AnyObject)
    {
        if audioEngine.isRunning
        {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            microphoneButton.isEnabled = false
            microphoneButton.setTitle("Start", for: .normal)
        }
        else
        {
            startRecording()
            microphoneButton.setTitle("Stop", for: .normal)
        }
    }
    
    func startRecording()
    {
        if recognitionTask != nil
        {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do
        {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        }
        catch
        {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else
        {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else
        {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil
            {
                self.textView.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
                
                if(isFinal)
                {
                    NotificationCenter.default.post(name: Notification.Name("Command"), object: self.textView.text)
                    
                    self.textView.text = ""
                }
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.microphoneButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0) // Intermittent crash here....
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        textView.text = "Say something, I'm listening!"
        
    }
    
    
    // If speech recognition is unavailable or changes its status, the microphoneButton.enable property should be set. For this scenario, we implement the availabilityDidChange method of the SFSpeechRecognizerDelegate protocol.
    
    //This method will be called when the availability changes. If speech recognition is available, the record button will also be enabled.
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }
    
    func receiveNotificationForSpeechText(notificationObj : Notification){
        let roomVC:RoomViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RoomViewController") as! RoomViewController
        let lightCount = lightsArray.count - 1
        let text:NSString = notificationObj.object as! NSString
        
        if text.contains(kIdentifierForLight1) {
            for index in 0...lightCount{
                let dict: PHLight = (self.lightsArray.object(at: index) as? PHLight)!
                let lightId:NSString = (dict.identifier as NSString)
                if (lightId.isEqual(to: "1")) {
                    roomVC.selectedLight = dict
                    roomVC.title = "Light "+dict.identifier
                    if ((dict.lightState.reachable) == 1) {
                        let lightState:PHLightState = PHLightState.init()
                        if text.contains(kOnIdentifier) {
                            lightState.setOn(true)
                        }
                        else if text.contains(kOffIdentifier){
                            lightState.setOn(false)
                        }
                        roomVC.updateLightState((dict.identifier)!, aLightState: lightState)
                        self.navigationController?.pushViewController(roomVC, animated: true)
                    }
                    else{
                        let alertView:UIAlertView = UIAlertView(title: "Light is not reachable !", message:"Please make sure light is connected to power.", delegate: nil, cancelButtonTitle: "Ok");
                        alertView.show();
                    }
                }
            }
            
        }
        else if text.contains(kIdentifierForLight2){
            for index in 0...lightCount{
                let dict: PHLight = (self.lightsArray.object(at: index) as? PHLight)!
                let lightId:NSString = (dict.identifier as NSString)
                if (lightId.isEqual(to: "2")) {
                    roomVC.selectedLight = dict
                    roomVC.title = "Light "+dict.identifier
                    if ((dict.lightState.reachable) == 1) {
                        let lightState:PHLightState = PHLightState.init()
                        if text.contains(kOnIdentifier) {
                            lightState.setOn(true)
                        }
                        else if text.contains(kOffIdentifier){
                            lightState.setOn(false)
                        }
                        roomVC.updateLightState((dict.identifier)!, aLightState: lightState)
                        self.navigationController?.pushViewController(roomVC, animated: true)
                    }
                    else{
                        let alertView:UIAlertView = UIAlertView(title: "Light is not reachable !", message:"Please make sure light is connected to power.", delegate: nil, cancelButtonTitle: "Ok");
                        alertView.show();
                    }
                }
            }
        }
        else if text.contains(kIdentifierForLight3){
            for index in 0...lightCount{
                let dict: PHLight = (self.lightsArray.object(at: index) as? PHLight)!
                let lightId:NSString = (dict.identifier as NSString)
                if (lightId.isEqual(to: "3")) {
                    roomVC.selectedLight = dict
                    roomVC.title = "Light "+dict.identifier
                    if ((dict.lightState.reachable) == 1) {
                        let lightState:PHLightState = PHLightState.init()
                        if text.contains(kOnIdentifier) {
                            lightState.setOn(true)
                        }
                        else if text.contains(kOffIdentifier){
                            lightState.setOn(false)
                        }
                        roomVC.updateLightState((dict.identifier)!, aLightState: lightState)
                        self.navigationController?.pushViewController(roomVC, animated: true)
                    }
                    else{
                        let alertView:UIAlertView = UIAlertView(title: "Light is not reachable !", message:"Please make sure light is connected to power.", delegate: nil, cancelButtonTitle: "Ok");
                        alertView.show();
                    }
                }
            }
        }
    }
}



