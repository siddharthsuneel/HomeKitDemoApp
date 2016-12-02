//
//  ViewController.swift
//  SpeechTest
//
//  Created by DMI on 01/12/16.
//  Copyright © 2016 DMI. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    
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

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initialSetup()
        
        authorizeSpeechRecognizer()
    }
    
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
            microphoneButton.setTitle("Start Recording", for: .normal)
        }
        else
        {
            startRecording()
            microphoneButton.setTitle("Stop Recording", for: .normal)
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
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

