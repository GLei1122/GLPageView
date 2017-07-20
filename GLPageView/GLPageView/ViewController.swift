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
        
        let inset: Float = 225.0 / 255.0
        self.view.backgroundColor = UIColor.init(colorLiteralRed: inset, green: inset, blue: inset, alpha: 1)
        
        let titleArray: Array = ["推荐","手游","娱乐","游戏","趣玩"]
        
        let recommend = RecommendVC()
        let phoneGame = PhoneGameVC()
        let entertainment = EntertainmentVC()
        let game = GameVC()
        let funPlay = FunPlayVC()
        
        self.addChildViewController(recommend)
        self.addChildViewController(phoneGame)
        self.addChildViewController(entertainment)
        self.addChildViewController(game)
        self.addChildViewController(funPlay)
        
        let frame = CGRect(x: 0, y: 60, width: self.view.bounds.size.width, height: self.view.bounds.size.height-60-0)
        print(self.view.bounds.size.height)
        print(NSStringFromCGRect(frame))
        pageView = GLPageView.init(frame: frame, childTitles: titleArray, childControllers: self.childViewControllers)
        
        pageView?.maxNumberOfPageItems = 5
        //pageView?.selectedPageIndex = 1;
        pageView?.delegete=self
        
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
extension ViewController: GLPageViewDelegate {
    
    
    
    func pageTabViewDidEndChange() {
        print("哈哈")
        
    }
}
