//
//  ViewController.swift
//  LocalNotificationDemo
//
//  Created by Andy Ma on 2017/9/29.
//  Copyright © 2017年 Andy Ma. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { (success, error) in
            if success {
                print("Granted")
            } else {
                print("Denied")
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendNotification(_ sender: Any) {
        // Step 1
        let content = UNMutableNotificationContent()
        content.title = "Notification Tutorial"
        content.subtitle = "from @monslab"
        content.body = "Hello Notification"
        
        // Step 2
        let imgName = "appimg"
        guard let imageURL = Bundle.main.url(forResource: imgName, withExtension: "png") else { return }
        let attachment = try! UNNotificationAttachment(identifier: imgName, url: imageURL, options: .none)
        content.attachments = [attachment]
        
        // Step 3
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "notification.id.01", content: content, trigger: trigger)
        print("send")

        // Step 4
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    

}

