//
//  GLPageView.swift
//  GLPageView
//
//  Created by GL on 2017/7/11.
//  Copyright © 2017年 GL. All rights reserved.
//

import UIKit

enum GLPageTitleStyle {
    case Default  //默认
    case Gradient //文字渐变
    case Blend    //文字填充
}
enum GLPageIndicatorStyle {
    case Default
    case FollowText //跟随文本长度变化
    case Stretch  //拉伸
}

class GLPageView: UIView {

    var titles: [String] = []
    
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        //_childControllers = childControllers;
        
        //[self initBaseSettings];
        //[self initTabView];
        //[self initMainView];
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    class func initWithChildControllers(childTitles: Array<String>,childControllers: Array<Any>) -> GLPageView {
       
        let abc = self.init()
        
        //titles = childTitles;
        
        
        return abc
        
    }
    
    
}



