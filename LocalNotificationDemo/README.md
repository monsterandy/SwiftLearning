# Local Notification 本地通知

### Step 1 申请通知权限

使用通知需要 `import UserNotifications`。`UNUserNotificationCenter`用于管理与通知相关的行为。使用通知必须先通过`requestAuthorization`方法取得用户的授权。

```Swift
UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { (success, error) in
    if success {
        print("Granted")
    } else {
        print("Denied")
    }
}
```

### Step 2 发送通知

发送通知共有四步操作：

1. 使用`UNMutableNotificationContent` 对象创建通知内容数据
2. 使用`UNNotificationAttachment`对象添加通知包含的媒体内容（可选）
3. 使用`UNNotificationRequest`创建通知
4. 将通知交给系统处理

```Swift
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
```

P.S. 点击发送通知后需要按 Home 键使 App 进入后台才能收到通知

![最终效果](https://ws1.sinaimg.cn/large/006tKfTcgy1fk0pd25k7jj30ku112adl.jpg)


