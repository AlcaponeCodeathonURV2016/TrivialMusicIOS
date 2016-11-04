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
    
    @IBAction func readyAction(_ sender: Any) {
        if currentGameID != "" {
        ref.child("games").child(self.currentGameID).observeSingleEvent(of: .value, with: { (snapshot) in
            self.currentGame = snapshot.value as! NSDictionary
            let status = GameStatus.init(rawValue: self.currentGame.object(forKey: "status") as! String)
            
            if(status == GameStatus.ready2){
                ref.child("games").child(self.currentGameID).updateChildValues(["status": GameStatus.ready1.rawValue])
            }else if (status == GameStatus.ready1){
                ref.child("games").child(self.currentGameID).updateChildValues(["status": GameStatus.start.rawValue])
                
                ref.child("games").child(self.currentGameID).observe(.value, with: { (snapshot) in
                    self.currentGame = snapshot.value as! NSDictionary
                    let status = GameStatus.init(rawValue: self.currentGame.object(forKey: "status") as! String)
                    
                    if(status == GameStatus.start){
                        self.start()
                    }
                }) { (error) in print(error.localizedDescription) }
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
                }else if (status == GameStatus.waiting1){
                    ref.child("games").child(self.currentGameID).updateChildValues(["status": GameStatus.ready2.rawValue])
                    //ref.child("available").child("-KVkmH_2UXmctypoELNF").child(self.currentGame).removeValue()
                    // No s'eliminia
                }
            }) { (error) in print(error.localizedDescription) }
        }) { (error) in print(error.localizedDescription) }
    }
    
    func start(){
    
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
