//
//  GameViewController.swift
//  TrivialMusic
//
//  Created by Oscar Blanco Castan on 4/11/16.
//  Copyright © 2016 Alcapone Team. All rights reserved.
//

import UIKit

enum GameStatus: String {
    case waiting1, waiting2, ready1, ready2, start
}

class GameViewController: UIViewController {
    var currentGameID : String = ""
    var currentGame : NSDictionary = [:]
    var currentRound = 0
    
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
    }
    @IBAction func secondSongAction(_ sender: Any) {
    }
    @IBAction func thirdSongAction(_ sender: Any) {
    }
    @IBAction func fourthSongAction(_ sender: Any) {
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
        ref.child("available").child("-KVlWmp99cJWt6c8Ahpr").queryOrderedByKey().queryLimited(toFirst: 1).observeSingleEvent(of: .value, with: { (snapshot) in
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
                    //ref.child("available").child("-KVkmH_2UXmctypoELNF").child(self.currentGame).removeValue()
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
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getGame()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ref.removeAllObservers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
