//
//  GameViewController.swift
//  TrivialMusic
//
//  Created by Oscar Blanco Castan on 4/11/16.
//  Copyright © 2016 Alcapone Team. All rights reserved.
//

import UIKit
import AVFoundation

enum GameStatus: String {
    case waiting1, waiting2, ready1, ready2, start
}

class GameViewController: UIViewController {
    var currentGameID : String = ""
    var currentGame : NSDictionary = [:]
    var currentRound = 0
    var currentAnswer = 0
    var player = AVPlayer()
    
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var readyLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    
    @IBOutlet weak var firstSongButton: UIButton!
    @IBOutlet weak var secondSongButton: UIButton!
    @IBOutlet weak var thirdSongButton: UIButton!
    @IBOutlet weak var fourthSongButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var firstPlayerPoints: UILabel!
    @IBOutlet weak var secondPlayerPoints: UILabel!
    
    @IBAction func firstSongAction(_ sender: Any) {
        checkAnswer(pos: 1)
    }
    @IBAction func secondSongAction(_ sender: Any) {
        checkAnswer(pos: 2)
    }
    @IBAction func thirdSongAction(_ sender: Any) {
        checkAnswer(pos: 3)
    }
    @IBAction func fourthSongAction(_ sender: Any) {
        checkAnswer(pos: 4)
    }
    
    func checkAnswer(pos:NSInteger){
        let correctAnswer = ((((self.currentGame.object(forKey: "questions") as! NSArray)[self.currentRound])as! NSDictionary).object(forKey: "solution")as! NSDictionary).object(forKey: "name") as! String
        let selectedAnser = ((((self.currentGame.object(forKey: "questions") as! NSArray)[self.currentRound])as! NSDictionary).object(forKey: "songs")as! NSArray)[pos] as! String
        
        if(correctAnswer == selectedAnser){
//            GoogleWearAlert.showAlert("Success", .success)
//            GoogleWearAlert.showAlert(title: "Success", .success)
        }else{
//            GoogleWearAlert.showAlert(title:"Error", nil, type: .error, duration: 2.0, inViewController: self)
        }
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func waitForStart(){
        ref.child("games").child(self.currentGameID).observe(.value, with: { (snapshot) in
            self.currentGame = snapshot.value as! NSDictionary
            let status = GameStatus.init(rawValue: self.currentGame.object(forKey: "status") as! String)
            
            if(status == GameStatus.start){
                print("strat")
                self.start()
            }
        }) { (error) in print(error.localizedDescription) }
    }
    
    @IBAction func readyAction(_ sender: Any) {
        if currentGameID != "" {
        ref.child("games").child(self.currentGameID).observeSingleEvent(of: .value, with: { (snapshot) in
            self.currentGame = snapshot.value as! NSDictionary
            let status = GameStatus.init(rawValue: self.currentGame.object(forKey: "status") as! String)
            
            if(status == GameStatus.ready2){
                ref.child("games").child(self.currentGameID).updateChildValues(["status": GameStatus.ready1.rawValue])
                
                self.waitForStart()
            }else if (status == GameStatus.ready1){
                ref.child("games").child(self.currentGameID).updateChildValues(["status": GameStatus.start.rawValue])
                
                self.waitForStart()
            }
        }) { (error) in print(error.localizedDescription) }
        }
    }
    
    func getGame(){
        ref.child("available").child("-KVmJv1jrPWCEAUknzwA").queryOrderedByKey().queryLimited(toFirst: 1).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! NSArray
            self.currentGameID = value[0] as! String
            
            ref.child("games").child(self.currentGameID).observeSingleEvent(of: .value, with: { (snapshot) in
                self.currentGame = snapshot.value as! NSDictionary
                let status = GameStatus.init(rawValue: self.currentGame.object(forKey: "status") as! String)
                
                if(status == GameStatus.waiting2){
                    ref.child("games").child(self.currentGameID).updateChildValues(["status": GameStatus.waiting1.rawValue])
                    
                    ref.child("games").child(self.currentGameID).observe(.value, with: { (snapshot) in
                        self.currentGame = snapshot.value as! NSDictionary
                        let status = GameStatus.init(rawValue: self.currentGame.object(forKey: "status") as! String)
                        
                        if(status == GameStatus.ready2){
                            self.readyLabel.text = "Ready?"
                            self.startButton.isHidden = false;
                        }
                    }) { (error) in print(error.localizedDescription) }
                }else if (status == GameStatus.waiting1){
                    ref.child("games").child(self.currentGameID).updateChildValues(["status": GameStatus.ready2.rawValue])
                    self.readyLabel.text = "Ready?"
                    self.startButton.isHidden = false;
                    //ref.child("available").child("-KVm36KKZMeBrFEf-wqM").child(self.currentGame).removeValue()
                    // No s'eliminia
                }
            }) { (error) in print(error.localizedDescription) }
        }) { (error) in print(error.localizedDescription) }
    }
    
    func start(){
        self.firstSongButton.isHidden = false
        self.secondSongButton.isHidden = false
        self.thirdSongButton.isHidden = false
        self.fourthSongButton.isHidden = false
        
        self.startButton.isHidden = true
    
        self.readyLabel.isHidden = true
        
        self.roundLabel.isHidden = false
        
        self.firstPlayerPoints.isHidden = false
        self.secondPlayerPoints.isHidden = false
        
        self.counterLabel.isHidden = false
        
        self.backButton.isHidden = true
        
        updateScreen()
        
    }
    
    func playerDidFinishPlaying(note: NSNotification){
        self.currentRound += 1
        if self.currentRound < 5{
            updateScreen()
        }
    }
    
    func updateScreen(){
        let question = (self.currentGame.value(forKey: "questions") as! NSArray)[self.currentRound] as! NSDictionary
        self.roundLabel.text = "Round \(self.currentRound+1)"
        
        let songs = question.object(forKey: "songs") as! NSArray
        
        self.firstSongButton.setTitle(songs[0] as? String, for: UIControlState.normal)
        self.secondSongButton.setTitle(songs[1] as? String, for: UIControlState.normal)
        self.thirdSongButton.setTitle(songs[2] as? String, for: UIControlState.normal)
        self.fourthSongButton.setTitle(songs[3] as? String, for: UIControlState.normal)
        
        self.firstSongButton.setNeedsDisplay()
        self.secondSongButton.setNeedsDisplay()
        self.thirdSongButton.setNeedsDisplay()
        self.fourthSongButton.setNeedsDisplay()
            
        playSound(question.value(forKey: "previewURL") as! String)
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector:#selector(GameViewController.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)

        getGame()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
        ref.removeAllObservers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func playSound(_ url:String) {
        let playerItem = AVPlayerItem( url:NSURL( string:url ) as! URL )
        player = AVPlayer(playerItem:playerItem)
        
        player.rate = 1.0;
        player.play()
        
        let duration = CMTimeGetSeconds((player.currentItem?.asset.duration)!)
        
        player.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 100), queue: DispatchQueue.main) {
            [unowned self] time in
            let timeString = String(format: "%02.f", duration - CMTimeGetSeconds(time))
            
            self.counterLabel.text = timeString
        }
        
    }

}
