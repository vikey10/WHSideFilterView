//
//  FilterTableViewCell.swift
//  ZBZX
//
//  Created by vikey wang on 4/21/17.
//  Copyright © 2017 vikey wang. All rights reserved.
//

import UIKit

class WHFilterTableViewCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    var items : Array<String> = []
    let itemHeight = 30
    let selectedIndex = 0
    var mainCollectionView : UICollectionView?
    let filterCollectionReuseidentifier = "collectionCellIdentifier"
    var selectedItems = NSMutableArray() 
    var selectedAll = false
    var flowLayout : UICollectionViewFlowLayout?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    init(items:Array<String>,columCount:CGFloat, selectedIndex:inout NSMutableArray){
        super.init(style: UITableViewCellStyle.default, reuseIdentifier: "filterCell")
        self.backgroundColor = UIColor.groupTableViewBackground
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.items = items
        self.selectedItems = selectedIndex
        //初始化collection的flowLayout
        self.flowLayout = UICollectionViewFlowLayout.init()
        self.flowLayout!.itemSize = CGSize.init(width: screen_width*0.85/columCount-5, height: 30)
        self.flowLayout!.minimumLineSpacing = 2
        self.flowLayout!.minimumInteritemSpacing = 0.5
        //初始化collectionView
        let rows = items.count/Int(columCount) +  (items.count%Int(columCount) > 0 ? 1 : 0)
        self.mainCollectionView = UICollectionView.init(frame: CGRect.init(x: 2, y:  5, width: screen_width*0.85 - 4, height: CGFloat(rows*30+10 + (rows-1)*2) - 10), collectionViewLayout: self.flowLayout!)
        self.mainCollectionView?.delegate = self
        self.mainCollectionView?.dataSource = self
        self.mainCollectionView?.backgroundColor = UIColor.groupTableViewBackground
        self.mainCollectionView?.allowsMultipleSelection = true
        self.contentView.addSubview(self.mainCollectionView!)
        
        self.mainCollectionView?.register(WHFilterCollectionCell.self, forCellWithReuseIdentifier: filterCollectionReuseidentifier)
        self.mainCollectionView?.bounces = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: collection delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let zeroIndex = IndexPath.init(row: 0, section: indexPath.section)
        if indexPath.row == 0  {
            self.selectedAll = true
            if self.selectedItems.count > 0 {
                self.selectedItems.removeAllObjects()
                collectionView.reloadData()
            }
        } else {
            if self.selectedAll == true {
                collectionView.deselectItem(at: zeroIndex , animated: true)
                self.selectedItems.remove(self.items[0])
            }
            self.selectedAll = false
        }
        
        self.selectedItems.add(self.items[indexPath.row])
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.top)
        if self.selectedItems.count == self.items.count - 1 && self.selectedAll == false && self.items.count > 1 {
            self.selectedAll = true
            for index in 0..<self.selectedItems.count {
                collectionView.deselectItem(at: IndexPath.init(row: index+1, section: indexPath.section), animated: true)
            }
            collectionView.selectItem(at: zeroIndex, animated: true, scrollPosition: UICollectionViewScrollPosition.top)
            self.selectedItems.removeAllObjects()
            self.selectedItems.add(self.items[0])   
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.selectedItems.remove(self.items[indexPath.row])
    }
    
    //MARK: collection dataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterCollectionReuseidentifier, for: indexPath) as! WHFilterCollectionCell
        if indexPath.row < self.items.count {
            cell.label.text = self.items[indexPath.row]
        }
        return cell
    }
}



