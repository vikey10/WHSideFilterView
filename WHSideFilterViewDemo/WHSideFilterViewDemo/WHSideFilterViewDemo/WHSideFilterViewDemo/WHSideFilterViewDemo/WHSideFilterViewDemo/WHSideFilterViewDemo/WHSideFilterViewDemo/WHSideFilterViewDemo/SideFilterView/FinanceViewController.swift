
//
//  FinanceViewController.swift
//  ZBZX
//
//  Created by vikey wang on 4/21/17.
//  Copyright © 2017 vikey wang. All rights reserved.
//

import UIKit


protocol FinanceViewControllerDelegate : class {
    func bidSelected(bidOid:String)
}

class FinanceViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate,UIViewControllerPreviewingDelegate,BidFilterViewDelegate{
    
    var currentPage = 1
    var listIndex = 0
    var isPushToNextVC = false
    var lastRefreshTime = NSDate()
    @IBOutlet weak var tableView: UITableView!
    var bidList: NSMutableArray?
    var countTimeList: NSMutableArray?
    var systemTimeStr:String?
    var countDownTimer: NSTimer?
    var systemTime = ""
    var bidId = ""
    let cellIdentifier = "invest"
    weak var delegate : FinanceViewControllerDelegate?
    var isRefresh = true
    var needRefreshItem  = false
    
//    MAKR:filterView相关参数
    var filterViewAdded = false
    let filterLeadingSpace = kwindow_width * 0.15
    var showFilterPanGesture : UIPanGestureRecognizer?
    var hideFilterPanGesture : UIPanGestureRecognizer?
    var hideFilterTapGesture : UITapGestureRecognizer?
    
    lazy var filterView : BidFilterView = {
        let view = BidFilterView.init(frame:CGRectMake(kwindow_width, 0, kwindow_width*0.85, kwindow_height))
        view.delegate = self
        return view
    }()
    
    lazy var blurView : UIView = {
        let view = UIView.init(frame: CGRectMake(kwindow_width, 0, kwindow_width, kwindow_height))
        view.backgroundColor = UIColor.clearColor()
        return view
    }()
    
    init(){
        super.init(nibName: "FinanceViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        //        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.view.backgroundColor = viewDefaultBackgroundColor
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "理财"
        let invest = UINib(nibName:"InvestTableViewCell", bundle: nil)
        tableView?.registerNib(invest, forCellReuseIdentifier: cellIdentifier)
        self.countTimeList = NSMutableArray()
        addRefreshLoading()
        self.check3dTouch()
        self.showFilterPanGesture = UIPanGestureRecognizer.init(target: self, action: #selector(showFilterView))
        self.hideFilterPanGesture = UIPanGestureRecognizer.init(target: self, action: #selector(showFilterView))
        self.hideFilterTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(hideFilterView))
        self.hideFilterTapGesture?.delegate = self
        self.showFilterPanGesture?.delegate = self
        self.hideFilterPanGesture?.delegate = self
        if UtilityJudge.isPad() == false {
            self.view.addGestureRecognizer(self.showFilterPanGesture!)
        }
        self.automaticallyAdjustsScrollViewInsets = false

        //MARK:定时标
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FinanceViewController.autoBidRefreshData), name: "refreshData", object: nil)
        /*****/
    }

    
    func autoBidRefreshData(){
        tableView!.legendHeader.beginRefreshing()
        tableView?.footer.hidden = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        if self.filterViewAdded == true {
            self.blurView.removeGestureRecognizer(self.hideFilterTapGesture!)
            self.blurView.removeGestureRecognizer(self.hideFilterPanGesture!)
            self.filterView.removeGestureRecognizer(self.hideFilterPanGesture!)
            self.blurView.removeFromSuperview()
            self.filterView.removeFromSuperview()
            self.filterViewAdded = false
        }
        
        if self.navigationController?.viewControllers.count == 1 {
            self.isPushToNextVC = false
        } else {
            self.isPushToNextVC = true
        }
    }
    override func viewDidAppear(animated: Bool) {

        if self.isPushToNextVC == false {
            if bidList?.count == 0 || bidList == nil{
                //没有数据时候自动刷新
                if tableView.header.isRefreshing() == false {
                    tableView!.legendHeader.beginRefreshing()
                    tableView?.footer.hidden = true
                }
            }else {
                let nowSp = NSDate().timeIntervalSince1970
                let lastSp = self.lastRefreshTime.timeIntervalSince1970
                if nowSp - lastSp > 300 {
                    //从其他页面进入
                    if tableView.header.isRefreshing() == false {
                        tableView!.legendHeader.beginRefreshing()
                        tableView?.footer.hidden = true
                    }
                }
            }
        } else {
            self.isPushToNextVC = false
            if self.needRefreshItem == true {
                self.refreshOneItem()
                self.needRefreshItem = false
            }
        }
    }
    
    //增加上拉，下拉控件
    func addRefreshLoading(){
        weak var weakSelf = self
        //下拉刷新
        tableView!.addLegendHeaderWithRefreshingBlock { () -> Void in
            
            if NSUserDefaults.standardUserDefaults().objectForKey((weakSelf?.tableView?.header.dateKey)!) != nil {
                weakSelf?.lastRefreshTime = NSUserDefaults.standardUserDefaults().objectForKey((self.tableView?.header.dateKey)!) as! NSDate
            }
            
            weakSelf?.currentPage = 1
            weakSelf?.isRefresh = true
            weakSelf?.refreshData()
            
        }
        //上拉加载更多
        tableView!.addLegendFooterWithRefreshingBlock { () -> Void in
            weakSelf?.currentPage += 1
            weakSelf?.isRefresh = false
            weakSelf?.refreshData()
        }
    }
    
    func refreshOneItem(){
        //子页面退出，需要拿点击的page
        let parameters = ["currentPage":listIndex+1,"perPage":1]
        HttpClient.POST(investList, parameters: parameters, success: { (dataTask, object) -> Void in
            self.refreshOneItemSuccess(dataTask,object: object)
            
        }) { (dataTask, error) -> Void in
            
        }
    }
    
    
    func refreshOneItemSuccess(dataTask: NSURLSessionDataTask?, object: AnyObject){
        let json = JSON(object)
        let base = BaseEntity().toModel(json)
        if base.error_code == 0{
            let obj = base.data
            let bidContent = BidListContent()
            //            print(listIndex)
            let tmpId = (bidContent.toModelArray(obj!).firstObject as! BidListContent).bidId
            if tmpId == self.bidId && tmpId != "" {
                bidList?.replaceObjectAtIndex(listIndex, withObject: bidContent.toModelArray(obj!).firstObject!)
                let indexPath = NSIndexPath.init(forRow: listIndex, inSection: 0)
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            }
        }
    }
    
    
    //上拉，下拉刷新数据
    func refreshData(){
        
        let parameters = ["currentPage":currentPage,"perPage":count]
        HttpClient.POST(investList, parameters: parameters, success: { (dataTask, object) -> Void in
            self.loadDidListSuccess(dataTask,object: object)
            self.addRightNaviItem()
        }) { (dataTask, error) -> Void in
            self.loadDidListError(dataTask, error: error)
        }
    }
    
    func addRightNaviItem() {
        let filterBtn = UIButton.init(frame: CGRectMake(0, 0, 80, 44))
        filterBtn.setTitle("筛选", forState: UIControlState.Normal)
        filterBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
        filterBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        filterBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
        filterBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        filterBtn.addTarget(self, action:#selector(filterBid), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: filterBtn)
    }
    
    func filterBid() {
        self.addFilterViewAndGestures()
        self.changeStatusBarStyle()
        UIView.animateWithDuration(0.3) {
            var filterFrame = self.filterView.frame
            filterFrame.origin.x = kwindow_width*0.15
            self.filterView.frame = filterFrame
            self.blurView.frame = CGRectMake(0, 0, kwindow_width, kwindow_height)
            self.blurView.layer.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5).CGColor
        }
    }
    
    //MARK: request server
    //请求成功
    func loadDidListSuccess(dataTask: NSURLSessionDataTask?, object: AnyObject) -> Void{
        //        print(object)
        let json = JSON(object)
        let base = BaseEntity().toModel(json)
        if base.error_code == 0{
            if base.systemTime == "" || base.systemTime == nil {
                base.systemTime = DateHelper.convertToStringWithInputDate(NSDate(), dateFormat: DateFormatType.yyyyMMddHHmmss)
            }
            self.systemTime = base.systemTime!
            let obj = base.data
            let bidContent = BidListContent()
            
            if self.tableView.footer.isRefreshing(){       //上拉加载
                self.tableView.footer.endRefreshing()
                bidList?.addObjectsFromArray(bidContent.toModelArray(obj!) as [AnyObject])
                
                //MARK: 定时标
                //倒计时的数组
                //                self.addCountTimeDataFrom(bidContent.toModelArray(obj!) as [AnyObject])
                /*********/
            }else{                                           //下拉刷新
                self.tableView!.header.endRefreshing()
                bidList?.removeAllObjects()
                bidList = bidContent.toModelArray(obj!)
                
                //MARK: 定时标
                //倒计时的数组
                //                self.countTimeList?.removeAllObjects()
                //                self.addCountTimeDataFrom(bidList!)
                /*********/
            }
            
            if bidList != nil{
                self.tableView.footer.hidden = bidList?.count == 0 ? true : false
            }
            
            //MARK:定时标
            //            if self.countDownTimer == nil {
            //                self.countDownTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(FinanceViewController.timerEvent), userInfo: nil, repeats: true)
            //                NSRunLoop.currentRunLoop().addTimer(self.countDownTimer!, forMode:NSRunLoopCommonModes)
            //            }
            /*****/
            self.tableView!.reloadData()
            if UtilityJudge.isPad() && self.bidList?.count > 0 {
                if  self.bidList?.count <= 20 {
                    self.tableView.selectRowAtIndexPath(NSIndexPath.init(forRow: 0, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.None)
                    self.tableView(self.tableView, didSelectRowAtIndexPath: NSIndexPath.init(forRow: 0, inSection: 0))
                } else {
                    self.tableView.selectRowAtIndexPath(NSIndexPath.init(forRow: listIndex, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.None)
                    self.tableView(self.tableView, didSelectRowAtIndexPath: NSIndexPath.init(forRow: listIndex, inSection: 0))
                }
                
            }
            
        } else {
            
            self.showMessageHUD(base.message!)
            if self.tableView.footer.isRefreshing(){       //上拉加载
                self.tableView.footer.endRefreshing()
                self.currentPage = self.currentPage - 1
            }
            else{                                           //下拉刷新
                self.tableView!.header.endRefreshing()
            }
        }
    }
    
    //请求失败
    func loadDidListError(dataTask: NSURLSessionDataTask?, error: NSError) -> Void{
        
        if self.tableView.header.isRefreshing(){            //下拉刷新
            self.tableView!.header.endRefreshing()
        } else if self.tableView.footer.isRefreshing(){       //上拉加载
            self.currentPage = self.currentPage - 1
            self.tableView.footer.endRefreshing()
        }
        
        if bidList != nil{
            self.tableView.footer.hidden = bidList?.count == 0 ? true : false
        }
        
        self.showMessageHUD(failureTips)
        self.tableView!.reloadData()
    }
    /**
     * 方法描述：定时器事件
     */
    func timerEvent(){
        for i in 0..<(self.countTimeList?.count)! {
            let timeModel = self.countTimeList![i] as! TimeModel
            timeModel.countDownAction()
        }
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationTimeCell", object: nil)
    }
    //MARK: tableView delegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! InvestTableViewCell
        cell.dataSource((bidList?.objectAtIndex(indexPath.row))! as! BidListContent)
        
        //MARK:定时标
        //        let model = self.countTimeList![indexPath.row] as! TimeModel
        //        cell.loadCountDownTimeData(model, indexpath: indexPath)
        /*********/
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        listIndex = indexPath.row
        let bidContent = bidList![indexPath.row] as! BidListContent
        if  bidContent.progress < 100 {
            self.needRefreshItem = true
        }
        self.bidId = bidContent.bidId!
        
        if UtilityJudge.isPad() {
            self.delegate?.bidSelected(bidContent.bidId!)
        } else {
            let bidDetail = BidDetailViewController(nibName:"BidDetailViewController", bundle: nil)
            bidDetail.bidOid = bidContent.bidId
            bidDetail.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(bidDetail, animated: true)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        
    }
    //MARK:定时标
    //    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    //        let tmpCell = cell as! InvestTableViewCell
    //        tmpCell.isDisplayed = true
    //        tmpCell.loadCountDownTimeData((self.countTimeList?.objectAtIndex(indexPath.row))! as! TimeModel, indexpath: indexPath)
    //    }
    //    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    //        let tmpCell = cell as! InvestTableViewCell
    //        tmpCell.isDisplayed = false
    //    }
    /********/
    //MARK: tableView dataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 143
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = bidList{
            return list.count
        }else{
            return 0
        }
    }
    //MARK:peek手势
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        if #available(iOS 9.0, *) {
            // 获取用户手势点所在cell的下标。同时判断手势点是否超出tableView响应范围
            guard UtilityJudge.isPad() == false else {return nil}
            let offsetY = self.tableView.contentOffset.y
            guard let indexPath = tableView.indexPathForRowAtPoint(CGPoint.init(x: location.x, y: location.y-self.tableView.frame.origin.y+offsetY)),
                _ = tableView.cellForRowAtIndexPath(indexPath) else { return nil }
            
            let bidContent = bidList![indexPath.row] as! BidListContent
            let bidDetailVC = BidDetailViewController(nibName:"BidDetailViewController", bundle: nil)
            bidDetailVC.bidOid = bidContent.bidId
            bidDetailVC.hidesBottomBarWhenPushed = true
            let cellFrame = tableView.cellForRowAtIndexPath(indexPath)!.frame
            previewingContext.sourceRect = view.convertRect(cellFrame, fromView: tableView)
            
            return bidDetailVC
        } else {
            return nil
            // Fallback on earlier versions
        }
    }
    
    //MARK: pop手势 重按进入详情页
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        self.showViewController(viewControllerToCommit, sender: self)
    }
    func check3dTouch() {
        
        if #available(iOS 9.0, *) {
            
            self.registerForPreviewingWithDelegate(self, sourceView: self.view)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FinanceViewController.touch3dAction(_:)), name: "invest", object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FinanceViewController.touch3dAction(_:)), name: "calculator", object: nil)
        } else {
            // Fallback on earlier versions
        }
    }
    func touch3dAction(noti:NSNotification) {
    
        let bidDetail = noti.object as! BidDetail
        if noti.name == "invest" {
            let invest = InvestViewController(nibName:"InvestViewController",bundle: nil)
            invest.bidDetail = bidDetail
            invest.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(invest, animated: true)
        } else {
            let calculator = CalculatorViewController(nibName:"CalculatorViewController",bundle: nil)
            calculator.bidDetail = bidDetail
            calculator.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(calculator, animated: true)
        }
    }
    //MARK: Utility
    
    /**
     * 方法描述：从请求回来的数组里取出标的时间并计算出倒计时间添加到倒计时的数组
     * －parameter：array 请求回来的数组
     */
    func addCountTimeDataFrom(array:NSArray) {
        for obj in array {
            let detail = obj as! BidListContent
            
            var countSecond = 0
            //            if detail.bidTime == "" {
            //                detail.bidTime! = "2016-08-11 18:30:00"
            //            }
            if detail.bidTime! != "" {
                let bidTime = DateHelper.convertToNsDateWithInputDateString(detail.bidTime!, dateFormat: DateFormatType.yyyyMMddHHmmss)
                let systemSp = DateHelper.convertToNsDateWithInputDateString(self.systemTime, dateFormat: DateFormatType.yyyyMMddHHmmss).timeIntervalSince1970
                let bidTimeSp = Int(bidTime.timeIntervalSince1970)
                countSecond = bidTimeSp - Int(systemSp)
            }
            self.countTimeList?.addObject(TimeModel.init(seconds: countSecond))
        }
    }
    
    
    //    MARK:showFilterViewGesture
    func showFilterView(gr:UIPanGestureRecognizer) {
        self.changeStatusBarStyle()
        if self.filterViewAdded == false {
            self.addFilterViewAndGestures()
        }
        var offsetX : CGFloat = 0.0
        if gr == self.showFilterPanGesture {
            self.blurView.frame = CGRectMake(0, 0, kwindow_width, kwindow_height)
            offsetX = self.showFilterPanGesture!.translationInView(self.view).x
            gr.setTranslation(CGPointZero, inView: self.view)
        } else if gr == self.hideFilterPanGesture {
            offsetX = gr.translationInView(self.filterView).x
            gr.setTranslation(CGPointZero, inView: self.filterView)
        }
        var frame = self.filterView.frame
        frame.origin.x += offsetX
        if frame.origin.x < filterLeadingSpace{
            frame.origin.x = filterLeadingSpace
        }
        self.filterView.frame = frame
        //        变更blurView的背景颜色
        self.blurView.layer.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(((kwindow_width - self.filterView.frame.origin.x)/(kwindow_width*0.85))*0.5).CGColor
        if gr.state == UIGestureRecognizerState.Ended {
            var originX = self.filterView.frame.origin.x
            if originX < filterLeadingSpace {
                originX = filterLeadingSpace
            } else if originX > kwindow_width*0.5 {
                originX = kwindow_width
                self.blurView.frame = CGRectMake(kwindow_width, 0, kwindow_width, kwindow_height)
            } else if originX > filterLeadingSpace && originX < kwindow_width {
                originX = filterLeadingSpace
            }
            var filterFrame = self.filterView.frame
            filterFrame.origin.x = originX
            if originX <= self.filterLeadingSpace && gr == self.showFilterPanGesture {
                self.blurView.addGestureRecognizer(self.hideFilterPanGesture!)
                self.filterView.addGestureRecognizer(self.hideFilterPanGesture!)
            } else if originX >= kwindow_width && gr == self.hideFilterPanGesture {
                self.blurView.removeGestureRecognizer(self.hideFilterPanGesture!)
                self.filterView.removeGestureRecognizer(self.hideFilterPanGesture!)
            }
            var blurOriginX = self.blurView.frame.origin.x
            if originX >= kwindow_width {
                blurOriginX = kwindow_width
            } else {
                blurOriginX = 0
            }
            self.blurView.frame = CGRectMake(blurOriginX, 0, kwindow_width, kwindow_height)
            UIView.animateWithDuration(0.2, animations: {
                self.filterView.frame = filterFrame
                if blurOriginX == kwindow_width {
                   UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
                   self.setNeedsStatusBarAppearanceUpdate()
                } else {
                    UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
                    self.setNeedsStatusBarAppearanceUpdate()
                }
            })
        }
    }
    
    func hideFilterView() {
        UIView.animateWithDuration(0.2) {
            self.filterView.frame = CGRectMake(kwindow_width, 0, kwindow_width*0.85, kwindow_height)
            self.blurView.frame = CGRectMake(kwindow_width, 0, kwindow_width, kwindow_height)
            self.changeStatusBarStyle()
        }
    }
    
//    MAKR:BidFilterViewDelegate
    func commitFilterResult(selectedItems: NSMutableArray) {
        print("commit button clicked!")
        print(selectedItems)
        self.hideFilterView()
    }
    
    func addFilterViewAndGestures() {
        self.tabBarController?.view.addSubview(self.blurView)
        self.tabBarController?.view.addSubview(self.filterView)
        self.filterView.addGestureRecognizer(self.hideFilterPanGesture!)
        self.blurView.addGestureRecognizer(self.hideFilterTapGesture!)
        self.filterViewAdded = true
    }
    
    func changeStatusBarStyle() {
        if UIApplication.sharedApplication().statusBarStyle == UIStatusBarStyle.Default {
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
            self.setNeedsStatusBarAppearanceUpdate()
        } else {
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
