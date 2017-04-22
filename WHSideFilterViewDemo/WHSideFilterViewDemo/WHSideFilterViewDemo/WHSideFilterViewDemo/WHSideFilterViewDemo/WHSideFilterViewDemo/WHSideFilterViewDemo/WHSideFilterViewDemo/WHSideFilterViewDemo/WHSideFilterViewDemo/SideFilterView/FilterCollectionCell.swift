//
//  FilterCollectionCell.swift
//  ZBZX
//
//  Created by vikey wang on 4/21/17.
//  Copyright © 2017 vikey wang. All rights reserved.
//

import UIKit

class FilterCollectionCell: UICollectionViewCell {
    
    lazy var label : UILabel = {
        let lb = UILabel.init()
        lb.textAlignment = NSTextAlignment.center
        lb.textColor = questionnariePopTextColor
        lb.font = UIFont.systemFont(ofSize: 12)
        lb.adjustsFontSizeToFitWidth = true
        return lb
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = lineColor
        self.selectedBackgroundView = UIImageView.init(image: Utility.imageWithColor(barTintColor))
        self.selectedBackgroundView?.layer.cornerRadius = 3
        self.contentView.addSubview(label)
        self.label.snp_makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
  
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
