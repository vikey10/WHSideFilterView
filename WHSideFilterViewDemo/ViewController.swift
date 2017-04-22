//
//  ViewController.swift
//  WHSideFilterViewDemo
//
//  Created by vikey wang on 4/21/17.
//  Copyright © 2017 vikey wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIGestureRecognizerDelegate {

    var showFilterPanGesture : UIPanGestureRecognizer?
    var dataSource = Array<Dictionary<String,Array<String>>>()
       
    lazy var filterView : WHFilterView = {
        let view = WHFilterView.init(frame: CGRect.zero, dataSource: self.dataSource)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let brandTypes : Dictionary<String,Array<String>> = ["Brand" : ["All","Nike","Adidas","Puma","Skechers","Saucony","Reebok"]]
        let sizeTypes : Dictionary<String,Array<String>>   = ["Size": ["All","5","6","7","8","9"]]
        let styleTypes : Dictionary<String,Array<String>> = ["Gender" : ["All","Female","Male"]]
        let lengthTypes : Dictionary<String,Array<String>> = ["Season" : ["All","Spring","Summer","Autumn","Winter"]]
        self.dataSource = [brandTypes,sizeTypes,styleTypes,lengthTypes]
        
        self.showFilterPanGesture = UIPanGestureRecognizer.init(target: self, action: #selector(showFilterView))
        self.showFilterPanGesture?.delegate = self
        self.view.addGestureRecognizer(self.showFilterPanGesture!)
        self.tabBarController?.view.addSubview(self.filterView)
        NotificationCenter.default.addObserver(self, selector: #selector(searchItems), name: NSNotification.Name(rawValue: "filterCommitted"), object: nil)
    }
    

    

    @IBAction func filterBtnClicked(_ sender: Any) {
        self.filterView.show()
    }
    
    
    //    MARK:showFilterViewGesture
    func showFilterView(gr:UIPanGestureRecognizer) {
        
        let offsetX = gr.translation(in: self.view).x
        gr.setTranslation(CGPoint.zero, in: self.view)
        if offsetX < 0 {
            self.filterView.move(offsetX: offsetX)
        }
        if gr.state == UIGestureRecognizerState.ended {
            self.filterView.moveEnded()
        }
    }

    //searchFunc
    func searchItems(notification:Notification) {
        print(notification.object ?? "")
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

