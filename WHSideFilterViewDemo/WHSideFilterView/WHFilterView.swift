//
//  FilterView.swift
//  WHSideFilterViewDemo
//
//  Created by vikey wang on 4/22/17.
//  Copyright © 2017 vikey wang. All rights reserved.
//

import UIKit

class WHFilterView: UIView,UIGestureRecognizerDelegate,WHMainFilterTableViewDelegate {
    
    let filterTableViewRatio : CGFloat = 0.85
    let filterLeadingSpace = screen_width * 0.15
    lazy var filterTableView : WHMainFilterTableView = {
        let filterView = WHMainFilterTableView.init(frame: CGRect.init(x: screen_width, y: 0, width: screen_width*self.filterTableViewRatio, height: screen_height), dataSource: self.dataSource, returnData: &self.returnData)
        filterView.delegate = self
        return filterView
    }()
    
    lazy var bgBlurView : UIView = {
        let view  = UIView.init(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.frame.size.width, height: self.frame.size.height)))
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    var hideFilterPanGesture : UIPanGestureRecognizer?
    var hideFilterTapGesture : UITapGestureRecognizer?
    var dataSource =  Array<Dictionary<String,Array<String>>>()
    var returnData = NSMutableArray()

    init(frame: CGRect,dataSource: Array<Dictionary<String,Array<String>>>) {
        super.init(frame: CGRect.init(origin: CGPoint.init(x: screen_width, y: 0), size: CGSize.init(width: screen_width*2, height: screen_height)))
        self.dataSource = dataSource
        self.backgroundColor = UIColor.clear
        self.hideFilterPanGesture = UIPanGestureRecognizer.init(target: self, action: #selector(panHidden))
        self.hideFilterTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapHidden))
        self.hideFilterTapGesture?.delegate = self
        self.hideFilterPanGesture?.delegate = self
        self.bgBlurView.addGestureRecognizer(self.hideFilterTapGesture!)
        self.filterTableView.addGestureRecognizer(self.hideFilterPanGesture!)
        self.addSubview(self.bgBlurView)
        self.addSubview(self.filterTableView)
    }
    
    //    MARK:showFilterViewGesture
    func tapHidden(gr:UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.2) {
            self.filterTableView.frame = CGRect.init(x: screen_width, y: 0, width: screen_width*0.85, height: screen_height)
            self.frame = CGRect.init(x: screen_width, y: 0, width: screen_width*2, height: screen_height)
        }
    }
    
    func panHidden(gr:UIPanGestureRecognizer) {
        let offsetX = gr.translation(in: self.filterTableView).x
        if offsetX > 0 {
            self.move(offsetX: offsetX)
        }
        gr.setTranslation(CGPoint.zero, in: self.filterTableView)
        if gr.state == UIGestureRecognizerState.ended {
            self.moveEnded()
        }
    }
    
    
    //显示页面
    func show() {
        guard  self.frame.origin.x >= screen_width else {
            return
        }
        self.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: screen_width, height: screen_height))
        UIView.animate(withDuration: 0.2) {
            self.bgBlurView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            var tableViewFrame = self.filterTableView.frame
            tableViewFrame.origin.x = self.filterLeadingSpace
            self.filterTableView.frame = tableViewFrame
        }
    }
    
    func move(offsetX:CGFloat) {
        var frame = self.filterTableView.frame
        frame.origin.x += offsetX
        if frame.origin.x < filterLeadingSpace{
            frame.origin.x = filterLeadingSpace
        }
        self.filterTableView.frame = frame
        self.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: screen_width, height: screen_height))
        self.bgBlurView.backgroundColor = UIColor.black.withAlphaComponent(((screen_width - self.filterTableView.frame.origin.x)/(screen_width*0.85))*0.5)
        
    }
    
    func moveEnded() {
        var originX = self.filterTableView.frame.origin.x
        if originX < filterLeadingSpace {
            originX = filterLeadingSpace
        } else if originX > screen_width*0.5 {
            originX = screen_width
            self.frame = CGRect.init(x: screen_width, y: 0, width: screen_width*2, height: screen_height)
        } else if originX > filterLeadingSpace && originX < screen_width {
            originX = filterLeadingSpace
        }
        var filterFrame = self.filterTableView.frame
        filterFrame.origin.x = originX
        var blurOriginX = self.frame.origin.x
        if originX >= screen_width {
            blurOriginX = screen_width
        } else {
            blurOriginX = 0
        }
        self.frame = CGRect.init(x: blurOriginX, y: 0, width: screen_width, height: screen_height)
        UIView.animate(withDuration: 0.2) { 
            self.filterTableView.frame = filterFrame
        }
    }
    
    //    MAKR:BidFilterViewDelegate
    func commitFilterResult(selectedItems: NSMutableArray) {
        print("commit button clicked!")
        self.tapHidden(gr: self.hideFilterTapGesture!)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "filterCommitted"), object: selectedItems)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
