//
//  ViewController.swift
//  Novel Noise
//
//  Created by Broque Thomas on 3/17/19.
//  Copyright © 2019 BTBuilds. All rights reserved.
//

import UIKit
import Speech
import YoutubePlayer_in_WKWebView

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    
    @IBOutlet weak var playerView: WKYTPlayerView!
    
    @IBOutlet weak var speechText: UILabel!
    
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private var audioEngine = AVAudioEngine()
    
    private var temporaryString = ""
    
    private var checkString = ""
    
    private var pauseCount = 0
    
    private var timer = Timer()
    
    private var running = false
    
    private var currentStream = ""
    
    private var activeStream = false
    
    private let playVars = ["controls": 1, "playsinline": 1, "autohide": 1, "showinfo": 1, "autoplay": 1, "modestbranding": 1]
    
    private var ensureStreamLoaded = 0
    
    private var testArray = ["here on my own", "my room", "french peaking"]
    private var streams = ["KQap5sj5TL4", "_Sf2Luv3_s0", "9t7DRLeofT8"]
    // MARK: UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable the record buttons until authorization has been granted.
        //recordButton.isEnabled = false
        
        startTimer()
        
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Configure the SFSpeechRecognizer object already
        // stored in a local member variable.
        speechRecognizer.delegate = self
        //playerView.load(withVideoId: "Mc0TMWYTU_k", playerVars: playVars)
        
        // Make the authorization request.
        SFSpeechRecognizer.requestAuthorization { authStatus in
            
            // Divert to the app's main thread so that the UI
            // can be updated.
            /*
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.recordButton.isEnabled = true
                    
                case .denied:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("User denied access to speech recognition", for: .disabled)
                    
                case .restricted:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition restricted on this device", for: .disabled)
                    
                case .notDetermined:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition not yet authorized", for: .disabled)
                }
            }
             */
        }
    }
    
    
    
    @IBAction func startStop(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            //recordButton.isEnabled = false
            //recordButton.setTitle("Stopping", for: .disabled)
        } else {
            do {
                
                try startRecording()
                //recordButton.setTitle("Stop Recording", for: [])
            } catch {
                //recordButton.setTitle("Recording Not Available", for: [])
            }
        }
    }
    
    private func startRecording() throws {
        
        // Cancel the previous task if it's running.
        print("Made it in here")
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        // Configure the audio session for the app.
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        // Create a recognition task for the speech recognition session.
        // Keep a reference to the task so that it can be canceled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            var modify = ""
            if let result = result {
                // Update the text view with the results.
                if self.checkLength(theString: result.bestTranscription.formattedString){
                    modify = self.changeLength(theString: result.bestTranscription.formattedString)
                }else{
                    modify = result.bestTranscription.formattedString
                }
                self.temporaryString = modify
                self.speechText.text = modify
                isFinal = result.isFinal
                
            }
            
            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                print("got here")
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }

        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        // Let the user know to start talking.
        speechText.text = "(Go ahead, I'm listening)"
    }
    
    // MARK: SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            //recordButton.isEnabled = true
            //recordButton.setTitle("Start Recording", for: [])
        } else {
            //recordButton.isEnabled = false
            //recordButton.setTitle("Recognition Not Available", for: .disabled)
        }
    }
    
    func checkLength(theString: String) -> Bool{
        var array = theString.components(separatedBy: " ")
        if array.count > 8{
            /*
             if timer.isValid{
             
             }else{
             startTimer()
             }
             */
            return true
        }else{
            return false
        }
        return false
    }
    
    func changeLength(theString: String) -> String{
        var array = theString.components(separatedBy: " ")
        var count = array.count
        var newArray = [array[count-8], array[count-7], array[count-6], array[count-5], array[count-4], array[count-3], array[count-2], array[count-1]]
        
        return newArray.joined(separator:" ")
    }
    
    func resetRecord(){
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            //recordButton.isEnabled = false
            //recordButton.setTitle("Stopping", for: .disabled)
        } else {
            do {
                
                try startRecording()
                //recordButton.setTitle("Stop Recording", for: [])
            } catch {
                //recordButton.setTitle("Recording Not Available", for: [])
            }
        }
    }
    
    // MARK: Interface Builder actions
    
    @objc func checkSpokenWord(){
        if ensureStreamLoaded == 8{
            initialLaunch()
            ensureStreamLoaded = 0
        }
        ensureStreamLoaded += 1
        if temporaryString != ""{
            if checkString == temporaryString{
                pauseCount += 1
            }else{
                pauseCount = 0
            }
            if pauseCount == 3{
                print("doing it")
                checkSentence()
                pauseCount = 0
            }
            if pauseCount == 0 {
                checkString = temporaryString
            }
        }
    }
    
    func checkSentence(){
        var index = 0
        for x in testArray{
            if x == retrievePartial(total: getSentenceLength(words: x)) {
                if currentStream == streams[index]{
                    
                }else{
                    resetRecord()
                    playerView.load(withVideoId: streams[index], playerVars: playVars)
                    currentStream = streams[index]
                    playerView.playVideo()
                }
                
            }
            index += 1
        }
    }
    
    func initialLaunch(){
        playerView.playVideo()
    }
    
    func getSentenceLength(words: String) -> Int{
        let array = words.components(separatedBy: " ")
        return array.count
    }
    
    func retrievePartial(total: Int) -> String{
        var array = checkString.components(separatedBy: " ")
        var totalCopy = total
        var output = ""
        while totalCopy > 0 {
            output += array[array.count-totalCopy] + " "
            totalCopy -= 1
        }
        print(output)
        output = output.trimmingCharacters(in: .whitespaces)
        return output
        
    }
    
    func startTimer(){
        
        if running{
            
        }else{
            running = true
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: (#selector(ViewController.checkSpokenWord)), userInfo: nil, repeats: true)
        }
        
    }
    
    
    
}

