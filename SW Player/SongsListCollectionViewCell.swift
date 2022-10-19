//
//  SongsListCollectionViewCell.swift
//  SW Player
//
//  Created by Shahzaib Mumtaz on 09/09/2022.
//

import UIKit

class SongsListCollectionViewCell: UICollectionViewCell {
    
    //************************************************//
    // MARK:- Creating Outlets.
    //************************************************//
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var totalWatchTime: UILabel!
    @IBOutlet weak var songName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
