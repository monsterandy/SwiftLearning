# GCD 与 Dispatch Queue

首先，GCD的核心词是 dispatch queue。一个队列实际上就是一系列的代码块，这些代码可以在主线程或者后台线程中以同步或者异步的方式执行。一旦队列创建完成，操作系统就接管了这个队列，并将其分配到任意一个核心中进行处理。不管有多少个队列，它们都能被系统正确地管理，这些并不需要开发者手动管理。队列遵循先入先出（FIFO）模式，这意味着先进队列的任务先被执行。

接下来，另一个重要的概念是 WorkItem（任务项）。一个任务项就是一个代码块，它可以随同队列的创建一起被创建，也可以被封装起来，然后在之后的代码中进行复用。任务项的代码就是 dispatch queue 将会执行的代码。队列中的任务项也是遵循 FIFO 模式。这些执行可以是同步的，也可以是异步的。对于同步的情况下，应用会一直堵塞当前线程，直到这段代码执行完成。而当异步执行的时候，应用先执行任务项，不等待执行结束，立即返回。

了解完这两个概念之后，我们还需要知道一个队列可以是串行或并行的。在串行队列的，一个任务项只有在前一个任务项完成之后才能执行，而在并行队列中，所有的任务项都可以并行执行。

对于主队列的操作要格外小心，因为这个队列要负责界面响应和用户交互。而且，所有与用户界面相关的更新都必须在主线程执行。如果尝试在后台线程更新 UI，系统并不保证这个更新何时会发生。但是，所有发生在界面更新前的任务都可以在后台线程执行。举例来说，我们可以在从队列，或者后台队列中下载图片数据，然后在主线程中更新相应的 image view。

### 认识 Dispatch Queue

```Swift
let queue = DispatchQueue(label: "com.monslab.myqueue")
```

label 是队列的独一无二的标签。接下来使用闭包创建最简单的队列代码。

```Swift
queue.sync {
    for i in 0..<10 {
        print("🔴 ",i)
    }
}
```

注意上面创建的队列是同步执行的，后续任务会等待其执行完毕才会继续。
将`sync`改为`async`可以使队列变为异步执行方式。

### Quality Of Service（QoS）和优先级

可以使用`qos`属性在创建队列时指定队列的优先级。
QoS 可用的取值参考[这个文档](https://developer.apple.com/library/content/documentation/Performance/Conceptual/EnergyGuide-iOS/PrioritizeWorkWithQoS.html)

* `userInteractive`
* `userInitiated`
* `default`
* `utility`
* `background`
* `unspecified`

以下代码演示了 QoS 的使用方法。

```Swift
func queuesWithQoS() {
    let queue1 = DispatchQueue(label: "com.monslab.queue1", qos: DispatchQoS.userInitiated)
    let queue2 = DispatchQueue(label: "com.monslab.queue2", qos: DispatchQoS.utility)
    
    queue1.async {
        for i in 0..<10 {
            print("🔴 ",i)
        }
    }
    
    queue2.async {
        for i in 100..<110 {
            print("🔵 ",i)
        }
    }
    
    for i in 1000..<1010 {
        print("Ⓜ️", i)
    }
}
```

### 并行队列

在上面的例子中，不同队列之间并行，但是单一队列中却是串行执行的。
通过在创建队列时更改`attributes`参数为`concurrent`，可以使队列内并行。

同时，`attributes`参数还可以接受另一个`initiallyInactive`值。这个取值将会使队列变为手动触发执行。

```Swift
concurrentQueues()
if let queue = inactiveQueue {
    queue.activate()
}
```

```Swift
var inactiveQueue: DispatchQueue!
func concurrentQueues() {
    let anotherQueue = DispatchQueue(label: "com.monslab.anotherQueue", qos: .utility, attributes: [.concurrent, .initiallyInactive])
    inactiveQueue = anotherQueue
    
    anotherQueue.async {
        for i in 0..<10 {
            print("🔴 ",i)
        }
    }
    
    anotherQueue.async {
        for i in 100..<110 {
            print("🔵 ",i)
        }
    }
    
    anotherQueue.async {
        for i in 1000..<1010 {
            print("⚫️", i)
        }
    }  
}    
```

### 延时队列

队列的使用中有一个`asyncAfter(deadline:) {}`方法，可以实现队列的延迟执行。

```Swift
func queueWithDelay() {
    let delayQueue = DispatchQueue(label: "com.monslab.delayqueue", qos: .userInitiated)
    
    print(Date())
    
    let additionalTime: DispatchTimeInterval = .seconds(2)
    
    delayQueue.asyncAfter(deadline: .now() + additionalTime) {
        print(Date())
    }   
}  
```

`DispatchTime`参数也可以直接接受`Double`类型的值。

### 主队列与全局队列

主队列专门用于执行UI相关的操作，而全局队列是系统默认提供的一个队列，让我们可以在无需手动创建队列的情况下使用。
全局队列依然可以使用`qos`参数。

```Swift
DispatchQueue.global().async {
    if let data = try? Data(contentsOf: url!) {
        DispatchQueue.main.async {
            memberAvatar.image = UIImage(data: data)
        }
    }
}
```

### DispathWorkItem 对象

`DispathWorkItem`是一个代码块，可以在任意队列上调用。其中的代码可以在后台也可以在主线程运行。

```Swift
func useWorkItem() {
    var value = 10
    
    let workItem = DispatchWorkItem {
        value += 5
    }
    
    workItem.perform()
    
    let queue = DispatchQueue.global(qos: .utility)
    
    queue.async(execute: workItem)
    
    workItem.notify(queue: DispatchQueue.main) {
        print("value = ", value)
    }
}
```


