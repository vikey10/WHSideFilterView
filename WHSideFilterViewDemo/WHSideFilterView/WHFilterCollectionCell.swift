//
//  FilterCollectionCell.swift
//  ZBZX
//
//  Created by vikey wang on 4/21/17.
//  Copyright © 2017 vikey wang. All rights reserved.
//

import UIKit

class WHFilterCollectionCell: UICollectionViewCell {
    
    lazy var label : UILabel = {
        let lb = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        lb.textAlignment = NSTextAlignment.center
        lb.textColor = UIColor.black
        lb.font = UIFont.systemFont(ofSize: 12)
        lb.adjustsFontSizeToFitWidth = true
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 3
        self.backgroundColor = UIColor.white
        self.selectedBackgroundView = UIImageView.init(image: Utility.imageWithColor(color: UIColor.init(red: 251/255.0, green: 75/255.0, blue: 70/255.0, alpha: 1)))
        self.selectedBackgroundView?.layer.cornerRadius = 3
        self.selectedBackgroundView?.clipsToBounds = true
        self.contentView.addSubview(label)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
