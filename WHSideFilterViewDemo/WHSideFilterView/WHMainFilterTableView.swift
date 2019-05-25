//
//  MainFilterView.swift
//  WHSideFilterViewDemo
//
//  Created by vikey wang on 4/22/17.
//  Copyright © 2017 vikey wang. All rights reserved.
//

import Foundation
import UIKit

protocol WHMainFilterTableViewDelegate : class {
    func commitFilterResult(selectedItems:NSMutableArray)
}

class WHMainFilterTableView: UIView,UITableViewDelegate,UITableViewDataSource {
    
    let colums : CGFloat = 3
    var data =  Array<Dictionary<String,Array<String>>>()
    var selectedTypes = Array<NSMutableArray>()
    weak var delegate : WHMainFilterTableViewDelegate?
   

     init(frame: CGRect,dataSource: Array<Dictionary<String,Array<String>>>,returnData : inout NSMutableArray) {
        super.init(frame: frame)
        self.data = dataSource
        self.configUI()
        self.commitBtn.addTarget(self, action: #selector(commitBtnClicked), for: UIControlEvents.touchUpInside)
        self.resetBtn.addTarget(self, action: #selector(resetBtnClicked), for: UIControlEvents.touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configUI() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 80
        self.addSubview(self.tableView)
        self.addSubview(self.commitBtn)
        self.addSubview(self.resetBtn)
    }
    
    //MARK:commit button touchUpInside Event
    func  commitBtnClicked() {
        let selectedInfo = NSMutableArray()
        for index in 0..<self.selectedTypes.count {
            if self.selectedTypes[index].count > 0 {
                selectedInfo.add(self.data[index].first!.key + ":" + self.getSelectedItemInfo(items: self.selectedTypes[index]))
            }
        }
        self.delegate?.commitFilterResult(selectedItems: selectedInfo)
        self.resetBtnClicked()
    }
    
    //MAKR:Reset button touchUpInside Event
    func resetBtnClicked() {
        self.tableView.reloadData()
        self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
        for item in self.selectedTypes {
            item.removeAllObjects()
        }
    }
    
    //MARK:UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.data[section].first?.key
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.selectedTypes.count < indexPath.section + 1 {
            let selectedArr = NSMutableArray()
            self.selectedTypes.append(selectedArr)
        }
        let cell = WHFilterTableViewCell.init(items:(self.data[indexPath.section].first?.value)!,columCount:self.colums,selectedIndex: &self.selectedTypes[indexPath.section])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 0.1))
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rows = self.data[indexPath.section].first!.value.count/Int(colums) +  (self.data[indexPath.section].first!.value.count%Int(colums) > 0 ? 1 : 0)
        return CGFloat(rows*30+10 + (rows-1)*2)
    }
    
    
    func getSelectedItemInfo(items:NSMutableArray) -> String {
        if items.count <= 0 {
            return ""
        }
        var str = ""
        for item in items {
            str += item as! String
            str += ","
        }
        
        return str
   }
    
    //MAKR:lazy var commitBtn resetBtn tableView
    lazy var commitBtn : UIButton = {
        let btn = UIButton.init(frame: CGRect.init(x:  self.frame.size.width/2, y: self.frame.size.height - 40 , width: self.frame.size.width/2, height: 40))
        btn.setBackgroundImage(Utility.imageWithColor(color: UIColor.init(red: 251/255.0, green: 75/255.0, blue: 70/255.0, alpha: 1)), for: UIControlState.normal)
        btn.setTitle("Commit", for: UIControlState.normal)
        btn.setTitleColor(UIColor.white, for: UIControlState.normal)
        return btn
    }()
    
    lazy var resetBtn : UIButton = {
        let btn = UIButton.init(frame: CGRect.init(x: 0 , y: self.frame.size.height - 40, width: self.frame.size.width/2, height: 40))
        btn.setBackgroundImage(Utility.imageWithColor(color: UIColor.white), for: UIControlState.normal)
        btn.setTitle("Reset", for: UIControlState.normal)
        btn.setTitleColor(UIColor.black, for: UIControlState.normal)
        return btn
    }()
    
    lazy var tableView : UITableView = {
        let tb = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height - 40), style: UITableViewStyle.grouped)
        tb.separatorStyle = UITableViewCellSeparatorStyle.none
        return tb
    }()
    
}
