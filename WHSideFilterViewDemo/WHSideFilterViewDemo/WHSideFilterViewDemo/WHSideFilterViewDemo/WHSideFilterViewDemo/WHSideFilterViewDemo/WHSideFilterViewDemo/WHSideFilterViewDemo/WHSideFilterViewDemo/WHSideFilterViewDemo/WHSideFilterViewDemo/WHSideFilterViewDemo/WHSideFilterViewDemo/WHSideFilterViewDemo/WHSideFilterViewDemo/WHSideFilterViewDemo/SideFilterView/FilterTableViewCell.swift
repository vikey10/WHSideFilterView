//
//  FilterTableViewCell.swift
//  ZBZX
//
//  Created by vikey wang on 4/21/17.
//  Copyright © 2017 vikey wang. All rights reserved.
//

import UIKit

protocol FilterTableViewCellDelegate {
    func filterItemClicked()
}

class FilterTableViewCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    var items : Array<String> = []
    let itemHeight = 30
    let selectedIndex = 0
    var mainCollectionView : UICollectionView?
    let filterCollectionReuseidentifier = "collectionCellIdentifier"
    var selectedItems = NSMutableArray() 

    var flowLayout : UICollectionViewFlowLayout?
    var selectedAll = false
    var collectionColums : Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    init(items:Array<String>,columCount:CGFloat,inout selectedIndex:NSMutableArray){
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: "filterCell")
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.items = items
        self.selectedItems = selectedIndex
        self.flowLayout = UICollectionViewFlowLayout.init()
        self.flowLayout!.itemSize = CGSizeMake(kwindow_width*0.85/columCount-5,30)
        self.flowLayout!.minimumLineSpacing = 2
        self.flowLayout!.minimumInteritemSpacing = 0.5

        self.mainCollectionView = UICollectionView.init(frame: CGRectZero, collectionViewLayout: self.flowLayout!)
        self.mainCollectionView?.delegate = self
        self.mainCollectionView?.dataSource = self
        self.mainCollectionView?.backgroundColor = UIColor.whiteColor()
        self.mainCollectionView?.allowsMultipleSelection = true
        
        self.contentView.addSubview(self.mainCollectionView!)
        
        self.mainCollectionView?.registerClass(FilterCollectionCell.self, forCellWithReuseIdentifier: filterCollectionReuseidentifier)
        self.mainCollectionView!.alwaysBounceVertical = false
        self.mainCollectionView?.pagingEnabled = true
        self.mainCollectionView?.bounces = false
        self.mainCollectionView!.alwaysBounceHorizontal = false
        self.mainCollectionView?.snp_makeConstraints(closure: { (make) in
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.left.equalToSuperview().offset(2)
            make.right.equalToSuperview().offset(-2)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: collection delegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let zeroIndex = NSIndexPath.init(forRow: 0, inSection: indexPath.section)
        if indexPath.row == 0  {
            self.selectedAll = true
            if self.selectedItems.count > 0 {
                self.selectedItems.removeAllObjects()
                collectionView.reloadData()
            }
        } else {
            if self.selectedAll == true {
                collectionView.deselectItemAtIndexPath(zeroIndex , animated: true)
                self.selectedItems.removeObject(self.items[0])
            }
            self.selectedAll = false
        }
        
        self.selectedItems.addObject(self.items[indexPath.row])
        collectionView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.None)
        if self.selectedItems.count == self.items.count - 1 && self.selectedAll == false && self.items.count > 1 {
            self.selectedAll = true
            for index in 0..<self.selectedItems.count {
                collectionView.deselectItemAtIndexPath(NSIndexPath.init(forRow: index+1, inSection: indexPath.section), animated: true)
            }
            collectionView.selectItemAtIndexPath(zeroIndex, animated: true, scrollPosition: UICollectionViewScrollPosition.None)
            self.selectedItems.removeAllObjects()
            self.selectedItems.addObject(self.items[0])

           
        }
    }
    
    //MARK: collection dataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(filterCollectionReuseidentifier, forIndexPath: indexPath) as! FilterCollectionCell
        cell.layer.cornerRadius = 3
        if indexPath.row < items.count {
            cell.label.text = items[indexPath.row]
        }
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }

    
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
            return true
    }
    
    func resetItems() {
        if self.selectedItems.count > 0 {
            self.selectedItems.removeAllObjects()
            self.mainCollectionView?.reloadData()
        }
    }
    

}



