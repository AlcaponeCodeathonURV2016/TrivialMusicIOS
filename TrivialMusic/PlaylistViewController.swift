//
//  PlaylistViewController.swift
//  TrivialMusic
//
//  Created by Pau Martín Olmos on 4/11/16.
//  Copyright © 2016 Alcapone Team. All rights reserved.
//

import UIKit

class PlaylistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var titles = ["Featured", "Top Hits", "Pop", "Latin", "Dance", "Rock", "Chill", "Electronic", "Classical"]
    var colors = [0x2ecc71, 0xe67e22, 0x8e44ad, 0x95a5a6, 0x3498db, 0x27ae60, 0x1abc9c, 0xf39c12, 0x34495e]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return titles.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath) as! PlaylistsTableViewCell
        
        cell.playlistTitle.text = titles[indexPath.row]

        let color = UIColorFromRGB(rgbValue: UInt(colors[indexPath.row]))
        cell.contentView.backgroundColor = color
        cell.backgroundColor = color
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "startGameSegue", sender: self)
    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
