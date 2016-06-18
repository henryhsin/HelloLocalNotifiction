//
//  MasterViewController.swift
//  HelloLocalNotifiction
//
//  Created by 辛忠翰 on 2016/6/18.
//  Copyright © 2016年 Keynote. All rights reserved.
//

import UIKit
import CoreLocation


class MasterViewController: UITableViewController, CLLocationManagerDelegate {

    var detailViewController: DetailViewController? = nil
    var objects = [AnyObject]()
    var locationManager = CLLocationManager()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        registerNotificationSettings()
        
        locationManager.delegate = self
        //若是想要只有在user使用app時才更新user位置時用requestWhenInUseAuthorization，記得需在Info.plist中新增NSLocationWhenInUseUsageDescription
        locationManager.requestWhenInUseAuthorization()
        //若是app在背景中也想更新user位置時用requestAlwaysAuthorization，記得需在Info.plist中新增NSLocationAlwaysUsageDescription
        locationManager.requestAlwaysAuthorization()

print(CLLocationManager.authorizationStatus())
        print("GG")
        
        self.setMonitoredRegion()
        self.createTimerbasedNotification()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // status is not determined
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            showAlert("status is not determined")
            locationManager.requestAlwaysAuthorization()
        }
            // authorization were denied
        else if CLLocationManager.authorizationStatus() == .Denied {
            showAlert("Location services were previously denied. Please enable location services for this app in Settings.")
        }
            // we do have authorization
        else if CLLocationManager.authorizationStatus() == .AuthorizedAlways {
            showAlert("good")
            locationManager.startUpdatingLocation()
        }
        else if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            showAlert("AuthorizedWhenInUse")
            locationManager.requestAlwaysAuthorization()
        }
        else if CLLocationManager.authorizationStatus() == .Restricted{
            showAlert("restricted")
            locationManager.startUpdatingLocation()
        }

    }


    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        self.createTimerbasedNotification()
    }
    
       // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! NSDate
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = objects[indexPath.row] as! NSDate
        cell.textLabel!.text = object.description
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    
    // 用來和系統溝通，我們的app需要哪些溝通服務
    private func registerNotificationSettings(){
        //forTypes中裝入我們想要通知使用者的方式，有發出聲音、跳出警告視窗、在icon上出現！這三種方式
        let settings = UIUserNotificationSettings(forTypes: [.Sound,.Alert,.Badge], categories: nil)
        
        //再將settings加入到我們的registerUserNotificationSettings中
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    //基於時間的notification
    private func createTimerbasedNotification(){
        let notification = UILocalNotification()
        //notification要出現的文字
        notification.alertBody = "I am remind message"
        //icon上出現的數字
        notification.applicationIconBadgeNumber = 99
        //notification發生時所撥的音檔
        //        notification.soundName = ""
        notification.fireDate = NSDate().dateByAddingTimeInterval(10.0)
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    //基於region的notifiction
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let current = locations[0] as CLLocation
        let currentLocation = CLLocationCoordinate2DMake(current.coordinate.latitude, current.coordinate.longitude)
        print(currentLocation)
        print("!!")
    }
    func setMonitoredRegion() {
        //指定一個區域的中心經緯度
        let regionCoordinate = CLLocationCoordinate2DMake(24.798620, 120.996747)
        
        //region
        let regionA = CLCircularRegion(center: regionCoordinate, radius: 50, identifier: "RegionA")
        locationManager.startMonitoringForRegion(regionA)
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        print("Entered Region \(region.identifier)")
        let notification = UILocalNotification()
        notification.region = region
        notification.alertBody = "User enter region!!"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        print("Exited Region \(region.identifier)")
        let notification = UILocalNotification()
        notification.region = region
        notification.alertBody = "User exit region!!"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

    
    // MARK: - Helpers
    
    func showAlert(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

}

