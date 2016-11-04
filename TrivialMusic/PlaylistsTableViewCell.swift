//
//  PlaylistsTableViewCell.swift
//  TrivialMusic
//
//  Created by Pau Martín Olmos on 4/11/16.
//  Copyright © 2016 Alcapone Team. All rights reserved.
//

import UIKit

class PlaylistsTableViewCell: UITableViewCell {

    @IBOutlet weak var playlistTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
