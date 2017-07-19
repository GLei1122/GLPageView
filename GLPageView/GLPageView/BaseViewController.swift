//
//  BaseViewController.swift
//  GLPageView
//
//  Created by GL on 2017/7/13.
//  Copyright © 2017年 GL. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    
    let label: UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        label.frame = CGRect(x: 50, y: 200, width: 100, height: 20)
        label.textColor=UIColor.red;
        label.textAlignment = NSTextAlignment.center;
        self.view.addSubview(label)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
