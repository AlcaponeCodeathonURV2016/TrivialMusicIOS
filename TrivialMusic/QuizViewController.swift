//
//  QuizViewController.swift
//  TrivialMusic
//
//  Created by Oscar Blanco Castan on 5/11/16.
//  Copyright © 2016 Alcapone Team. All rights reserved.
//

import UIKit
import FirebaseDatabase
import AVFoundation

enum GameStatus: String {
    case waiting1, waiting2, start, finished
}

class QuizViewController: UIViewController {
    
    var statusListener : FIRDatabaseReference!
    var gameListener : FIRDatabaseReference!
    
    var currentGame : NSDictionary = [:]
    var currentRound = 0
    var countdownTimerValue = 3
    var countdownTimer : Timer = Timer()
    var playerID : String = ""
    var playerOID : String = ""
    var id : String = ""
    var player = AVPlayer()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightScoreLabel: UILabel!
    @IBOutlet weak var leftScoreLabel: UILabel!
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var song1Button: UIButton!
    @IBOutlet weak var song2Button: UIButton!
    @IBOutlet weak var song3Button: UIButton!
    @IBOutlet weak var song4Button: UIButton!
    
    @IBAction func songButtonPresed(sender: UIButton) {
        let question = (self.currentGame.value(forKey: "questions") as! NSArray)[self.currentRound] as! NSDictionary
        let answer = (question.object(forKey: "songs") as! NSArray)[sender.tag-1] as! String
        let correct = ((question.object(forKey: "solution") as! NSDictionary).object(forKey: "name") as! String)
        
        if(correct == answer){
            print("Correct answer")
            ref.child("games").child(id).child("\(playerID)points").runTransactionBlock { (currentData: FIRMutableData) -> FIRTransactionResult in
                var value = currentData.value as? Int
                
                if value == nil {
                    value = 0
                }
                
                currentData.value = value! + 20
                return FIRTransactionResult.success(withValue: currentData)
            }
            self.titleLabel.text = "Yeah!!!"
            ref.child("games").child(id).updateChildValues(["\(playerOID)status":"blocked"])
        
//            player.replaceCurrentItem(with: nil)
//            self.playerDidFinishPlaying(note: )
        }else{
            self.titleLabel.text = "Ouch!!! Nice try"
        }
        self.song1Button.isEnabled = false
        self.song2Button.isEnabled = false
        self.song3Button.isEnabled = false
        self.song4Button.isEnabled = false
    }
    
    func setupListener(id:String){
        statusListener.child("games").child(id).child("status").observe(.value, with: { (snapshot) in
            let statusString = snapshot.value as! String
            let status = GameStatus.init(rawValue: statusString)
            
            if(status == GameStatus.waiting1){
                print("Game Status: waiting1")
            
            }else if(status == GameStatus.start){
                print("Game Status: start")
                self.start()
            }else if(status == GameStatus.finished){
                print("Game Status: finished")
                self.finished()
                
            }
            
        }) { (error) in print(error.localizedDescription) }
    
        gameListener.child("games").child(id).observe(.value, with: { (snapshot) in
            let game = snapshot.value as! NSDictionary
            self.currentGame = game
            
            let points = self.currentGame.object(forKey: "\(self.playerID)points") ?? 0
            self.leftScoreLabel.text = "\(points)"
            let points1 = self.currentGame.object(forKey: "\(self.playerOID)points") ?? 0
            self.rightScoreLabel.text = "\(points1)"
            
            if((self.currentGame.object(forKey: "\(self.playerID)status") as! String) == "blocked"){
                self.titleLabel.text = "Opponent was faster!!!"
                self.song1Button.isEnabled = false
                self.song2Button.isEnabled = false
                self.song3Button.isEnabled = false
                self.song4Button.isEnabled = false
            }
        }) { (error) in print(error.localizedDescription) }
    }
    
    func getGame(completion: @escaping (_ id: String) -> Void) {
        ref.child("games").queryOrdered(byChild: "status").queryStarting(atValue: "waiting").queryLimited(toFirst: 1).observeSingleEvent(of: .value, with: { (snapshot) in
            let values = snapshot.value as! NSDictionary
            let id = values.allKeys[0] as! String
            let game = values.allValues[0] as! NSDictionary
            
            self.currentGame = game
            
            if(GameStatus.init(rawValue: game.object(forKey: "status") as! String) == GameStatus.waiting2){
                ref.child("games").child(id).updateChildValues(["status": GameStatus.waiting1.rawValue, "player1": uid!, "player1points": 0, "player1status": "ready"])
                self.playerID = "player1"
                self.playerOID = "player2"
            }else{
                ref.child("games").child(id).updateChildValues(["status": GameStatus.start.rawValue, "player2": uid!, "player2points": 0, "player2status": "ready"])
                self.playerID = "player2"
                self.playerOID = "player1"
            }
            
            completion(id)
        }) { (error) in print(error.localizedDescription) }
    }
    
    func showCountdown(){
        self.mainLabel.isHidden = false
        self.countdownTimerValue = 3
    }
    
    func countdownUpdate(){
        if(self.countdownTimerValue > 0) {
            self.countdownTimerValue -= 1
            self.mainLabel.text = String(self.countdownTimerValue)
        }else{
            self.mainLabel.text = "Start!!"
            self.countdownTimer.invalidate()
        }
    }
    
    func start(){
//        self.showCountdown()
        
    
        updateScreen()
        
    }
    
    func updateScreen(){
        ref.child("games").child(id).updateChildValues(["\(playerID)status":"ready"])
        self.song1Button.isHidden = false
        self.song2Button.isHidden = false
        self.song3Button.isHidden = false
        self.song4Button.isHidden = false
        
        self.song1Button.isEnabled = true
        self.song2Button.isEnabled = true
        self.song3Button.isEnabled = true
        self.song4Button.isEnabled = true
        
        self.rightScoreLabel.isHidden = false
        self.leftScoreLabel.isHidden = false
        self.titleLabel.isHidden = false
        self.mainLabel.isHidden = false
        
        let question = (self.currentGame.value(forKey: "questions") as! NSArray)[self.currentRound] as! NSDictionary
        self.titleLabel.text = "Round \(self.currentRound+1)"
        
        let songs = question.object(forKey: "songs") as! NSArray
        
        self.song1Button.setTitle(songs[0] as? String, for: UIControlState.normal)
        self.song2Button.setTitle(songs[1] as? String, for: UIControlState.normal)
        self.song3Button.setTitle(songs[2] as? String, for: UIControlState.normal)
        self.song4Button.setTitle(songs[3] as? String, for: UIControlState.normal)
        
        self.song1Button.isEnabled = true
        self.song2Button.isEnabled = true
        self.song3Button.isEnabled = true
        self.song4Button.isEnabled = true
        
        playSound(url: question.value(forKey: "previewURL")! as! String)
      
        
    }
    
    func playSound(
        url:String) {
        let playerItem = AVPlayerItem( url:NSURL( string:url ) as! URL )
        player = AVPlayer(playerItem:playerItem)
        
        player.rate = 1.0;
        player.play()
        
        let duration = CMTimeGetSeconds((player.currentItem?.asset.duration)!)
        
        player.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 100), queue: DispatchQueue.main) {
            [unowned self] time in
            let timeString = String(format: "%02.f", duration - CMTimeGetSeconds(time))
            
            self.mainLabel.text = timeString
        }
    }
    
    func playerDidFinishPlaying(note: NSNotification){
        self.currentRound += 1
        if self.currentRound < 5{
            updateScreen()
        }else{
            finished()
        }
    }
    
    func finished(){
        var title = "You won!!!"
        if((self.currentGame.object(forKey: "\(self.playerID)points") as! NSInteger) < (self.currentGame.object(forKey: "\(self.playerOID)points") as! NSInteger)){
            title = "You lose!!!"
        }else if((self.currentGame.object(forKey: "\(self.playerID)points") as! NSInteger) == (self.currentGame.object(forKey: "\(self.playerOID)points") as! NSInteger)){
            title = "Draw"
        }
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
            action in
            
            self.navigationController?.popViewController(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.text = "Waiting..."
        self.titleLabel.isHidden = false
        
        self.countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countdownUpdate), userInfo: nil, repeats: true)
        NotificationCenter.default.addObserver(self, selector:#selector(QuizViewController.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        
        statusListener = FIRDatabase.database().reference()
        gameListener = FIRDatabase.database().reference()
        
        getGame(){
            (id: String) in
            self.id = id
            self.setupListener(id: id)
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
