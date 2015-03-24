//
//  PassbookCell.swift
//  PassbookLayout
//
//  Created by 田程元 on 15/3/23.
//  Copyright (c) 2015年 田程元. All rights reserved.
//

import UIKit

class PassbookCell: UICollectionViewCell {
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubtitle: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    let names = ["pass-mockup-red", "pass-mockup-blue", "pass-mockup-ive"]
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setStyle(style:Int){
        imageView.image = UIImage(named: names[style])
    }
}
