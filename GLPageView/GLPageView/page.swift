//
//  page.swift
//  GLPageView
//
//  Created by GL on 2017/7/19.
//  Copyright © 2017年 GL. All rights reserved.
//

import UIKit

class page: UIButton {

    
    //填充色
    var fillColor: UIColor?
    //填充占比
    var process: CGFloat = 0.0
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        
        //填充颜色
        fillColor?.setFill()
        //设置填充的宽度变化
        let tempRect: CGRect = CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width*process, height: rect.size.height)
        //
        UIRectFillUsingBlendMode(tempRect, CGBlendMode.sourceIn)
    }

}
