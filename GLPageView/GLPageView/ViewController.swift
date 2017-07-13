//
//  ViewController.swift
//  GLPageView
//
//  Created by GL on 2017/7/11.
//  Copyright © 2017年 GL. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let ming: Person = Person()
    var pageView: GLPageView? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ming.name="哈利波特"
        
        var myContext = "啦啦"
        
        ming.addObserver(self, forKeyPath: "name", options: NSKeyValueObservingOptions.old , context: &myContext)
        
        let titleArray: Array = ["体育","娱乐","新闻"]
        for _ in titleArray {
            
            let sport: BaseViewController = BaseViewController()
            self.addChildViewController(sport)
        }
        
        pageView = GLPageView.initWithChildControllers(childTitles: titleArray, childControllers: self.childViewControllers)
        pageView?.frame=CGRect(x: 0, y: 60, width: self.view.bounds.size.width, height: self.view.bounds.size.height-60)
        pageView?.backgroundColor=UIColor.red
        
        self.view.addSubview(pageView!)
        
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        ming.setValue("哈利", forKey: "name")
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
//        print(keyPath!);
//        
//        print(context!);
//        
//        print(change!);
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

