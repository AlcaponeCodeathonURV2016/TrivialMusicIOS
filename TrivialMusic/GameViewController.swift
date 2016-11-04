//
//  GameViewController.swift
//  TrivialMusic
//
//  Created by Oscar Blanco Castan on 4/11/16.
//  Copyright © 2016 Alcapone Team. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    var currentGame : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("----")
        ref.child("available").observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                print(value)
        
                print("----------")
                self.currentGame = value?["username"] as! String
            
            }) { (error) in
                print(error.localizedDescription)
        }
        // Do any additional setup after loading the view.
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
