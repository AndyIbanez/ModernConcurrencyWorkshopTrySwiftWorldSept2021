//
//  ViewController.swift
//  AsyncStreamDemo2
//
//  Created by Andy Ibanez on 9/17/21.
//

import UIKit

class TimerStream {
    let interval: TimeInterval
    private (set) var invalidated: Bool = false
    
    init(interval: TimeInterval) {
        self.interval = interval
    }
    
    func invalidate() {
        self.invalidated = true
    }
    
    func start() -> AsyncStream<Date> {
        AsyncStream(Date.self) { continuation in
            Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
                if self.invalidated {
                    timer.invalidate()
                    continuation.finish()
                } else {
                    continuation.yield(Date())
                }
            }
        }
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let timer = TimerStream(interval: 1)
        let startDate = Date()
        
        Task {
            for await date in timer.start() {
                print("The date is \(date.formatted())")
                let seconds = Calendar.current.dateComponents([.second], from: startDate, to: date).second!
                if seconds > 5 {
                    timer.invalidate()
                }
            }
            print("Done printing")
        }
    }


}

