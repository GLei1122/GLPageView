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


//协议
protocol  GLPageViewDelegate{
    
    //var delegateTest: CGFloat {set get} //定义属性,表示可读可写
    
    func pageTabViewDidEndChange()
}

class GLPageView: UIView {

    var delegete: GLPageViewDelegate?
    
    /*pageView背景色，默认white*/
    var pageViewBackgroundColor : UIColor = UIColor.white{
        didSet {
            pageScrollView.backgroundColor = pageViewBackgroundColor
        }
    }
    
    /*pageView size，默认(self.width, 40.0)*/
    var pageViewSize: CGSize = CGSize(width: 0, height: 40)

    /*一页展示最多的item个数，如果比item总数少，按照item总数计算*/
    var maxNumberOfPageItems: NSInteger = 4
    
    /*item的字体大小 默认15*/
    var pageItemFont: UIFont = UIFont.systemFont(ofSize: 15)
    

    /*设置当前选择项（无动画效果）默认第一个 */
    var selectedPageIndex: NSInteger = 0

    
    fileprivate var pageItemWidth: CGFloat = 0
    
    
    /*未选择颜色 默认黑色*/
    var unSelectedColor: UIColor = UIColor.black {
        didSet {
            updateColors(selectBool: false)
        }
    }

    
    /*当前选中颜色 默认红色*/
    var selectedColor: UIColor = UIColor.red {
        didSet {
            updateColors(selectBool: true)
        }
    }
    
    /*是否打开body的边界弹动效果*/
    var bodyBounces: Bool = true {
        didSet {
            bodyScrollView.bounces = bodyBounces
        }
    }
    
    /*Title效果设置*/
    var titleStyle: GLPageTitleStyle = GLPageTitleStyle.Default
    
    /*字体渐变，未选择的item的scale，默认是0.8（0~1）。仅XXPageTabTitleStyleScale生效*/
    var minScale: CGFloat = 0.8
    
    /*Indicator效果设置*/
    var indicatorStyle: GLPageIndicatorStyle = GLPageIndicatorStyle.Default
    
    /*下标高度，默认是2.0*/
    var indicatorHeight: CGFloat = 2.0
    
    /*下标宽度，默认是20。XXPageTabIndicatorStyleFollowText时无效*/
    var indicatorWidth: CGFloat = 20
    
    
    /*标题数组*/
    fileprivate var titlesArray: [String] = []
    fileprivate var controllers: [UIViewController] = []
    
    /*记录上一次的索引 */
    fileprivate var lastSelectedPageIndex: NSInteger = 0
    
    //标题label数组
    fileprivate var pageItemLabels:Array<UILabel>  = []
    
    //animation
    //滑动过程中不允许layoutSubviews
    fileprivate var isNeedRefreshLayout: Bool = true
    //是否是通过点击改变的。因为点击可以长距离点击，部分效果不作处理会出现途中经过的按钮也会依次有效果（仿网易客户端有此效果，个人觉得并不好，头条的客户端更合理）
    fileprivate var isChangeByClick: Bool = false
    
    /* 记录滑动时左边的itemIndex */
    fileprivate var leftItemIndex: NSInteger = 0
    
    /* 记录滑动时右边的itemIndex */
    fileprivate var rightItemIndex: NSInteger = 0
    
    
    /*XXPageTabTitleStyleScale*/
    fileprivate var selectedColorR: CGFloat = 1
    fileprivate var selectedColorG: CGFloat = 0
    fileprivate var selectedColorB: CGFloat = 0
    
    fileprivate var unSelectedColorR: CGFloat = 0
    fileprivate var unSelectedColorG: CGFloat = 0
    fileprivate var unSelectedColorB: CGFloat = 0
    
    
    
    //标题栏
    var pageScrollView:UIScrollView
    //body视图
    var bodyScrollView:UIScrollView
    //下标视图
    var indicatorView:UIView = UIView()
   
    
    
     //MARK: - 初始化
    init(frame: CGRect , childTitles: Array<String> , childControllers: Array<UIViewController>) {
       
        pageScrollView = UIScrollView()
        bodyScrollView = UIScrollView()
        controllers = childControllers;
        titlesArray = childTitles;
        
        super.init(frame: frame)
        
        //创建标题view
        initPageView()
        //创建
        initBodyView()
        
    }
    private func initPageView() {
        
        pageViewSize = CGSize(width: self.bounds.size.width, height: 40);
        pageScrollView.showsVerticalScrollIndicator = false;
        pageScrollView.showsHorizontalScrollIndicator = false;
        pageScrollView.backgroundColor = pageViewBackgroundColor
        pageScrollView.delegate = self
        //超出父视图,子视图裁剪
        pageScrollView.clipsToBounds = true
        self.addSubview(pageScrollView);
        
        //遍历
        print(selectedPageIndex)
        
        for (index,str) in titlesArray.enumerated() {
            let pageItem: GLPageTitleLabel = GLPageTitleLabel()
            pageItem.font = pageItemFont;
            pageItem.text = str;
            pageItem.textColor =  index==selectedPageIndex ? selectedColor : unSelectedColor;
            pageItem.textAlignment = NSTextAlignment.center;
            pageItem.isUserInteractionEnabled = true;
            pageItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeChildControllerOnClick(tap:))))
            pageScrollView.addSubview(pageItem)
            pageItemLabels.append(pageItem)
        }
        //添加下标
        indicatorView.backgroundColor = selectedColor
        self.addSubview(indicatorView)
    }
    private func initBodyView() {
        
        bodyScrollView.showsVerticalScrollIndicator = false
        bodyScrollView.showsHorizontalScrollIndicator = false
        bodyScrollView.isPagingEnabled = true
        bodyScrollView.bounces = bodyBounces
        bodyScrollView.delegate = self
        
        for childController in controllers {
            if childController.view.superview != bodyScrollView {
                bodyScrollView.addSubview(childController.view)
            }
        }
        self.addSubview(bodyScrollView)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        
        if isNeedRefreshLayout {
            
            if pageViewSize.height <= 0 {
                pageViewSize.height = 40
            }
            if pageViewSize.width <= 0 {
                pageViewSize.width = self.bounds.size.width
            }
            
            //每个item的宽度
            pageItemWidth = pageViewSize.width / CGFloat((pageItemLabels.count < maxNumberOfPageItems ? pageItemLabels.count : maxNumberOfPageItems));
            pageScrollView.frame = CGRect(x: 0, y: 0, width: pageViewSize.width, height: pageViewSize.height)
            pageScrollView.contentSize = CGSize(width: pageItemWidth * CGFloat(pageItemLabels.count), height: 0)
            
            for (index,itemLabel) in pageItemLabels.enumerated() {
                
                itemLabel.frame = CGRect(x: pageItemWidth * CGFloat(index), y: 0, width: pageItemWidth, height: pageViewSize.height)
            }
            
            
            if titleStyle == GLPageTitleStyle.Default {
                //文字颜色切换
                self.changeSelectedItemToNextItem(selectedPageIndex)
            }
//
            //下标view frame
            self.layoutIndicatorView()
            
            //body layout
            print("---%f",self.bounds.size.height)
            bodyScrollView.frame = CGRect(x: 0, y: pageViewSize.height, width: self.bounds.size.width, height: self.bounds.size.height-pageViewSize.height)
            bodyScrollView.contentSize = CGSize(width: self.bounds.size.width * CGFloat(pageItemLabels.count), height: 0)
            bodyScrollView.contentOffset = CGPoint(x: self.bounds.size.width * CGFloat(selectedPageIndex), y: 0)
            
            
            self.reviseTabContentOffsetBySelectedIndex(false)
            
            for (index,childController) in controllers.enumerated() {
                childController.view.frame = CGRect(x: self.bounds.size.width * CGFloat(index), y: 0, width: bodyScrollView.bounds.size.width, height: bodyScrollView.bounds.size.height)
            }
        }
        
        
    }

    //MARK: - 点击分类切换
    func changeChildControllerOnClick(tap: UITapGestureRecognizer)  {
        print("哈哈")
        //获取点击的label
        let index: NSInteger = pageItemLabels.index(of: tap.view as! UILabel)!
        //如果不是当前选中的
        if index != selectedPageIndex {
            
            if titleStyle == GLPageTitleStyle.Default {
                //文字颜色切换
                self.changeSelectedItemToNextItem(index)
            }
            isChangeByClick = true
           
            leftItemIndex = index > selectedPageIndex ? selectedPageIndex : index
            rightItemIndex = index > selectedPageIndex ? index : selectedPageIndex
            
            selectedPageIndex = index
        
            
            
            bodyScrollView.setContentOffset(CGPoint(x: bodyScrollView.frame.size.width * CGFloat(selectedPageIndex), y: 0), animated: false)
        }
        
    }
    /**
        一般常用改变selected Item方法(无动画效果，直接变色)
     */
    func changeSelectedItemToNextItem(_ index: NSInteger) {
        
        let currentPageItem = pageItemLabels[selectedPageIndex];
        let nextPageItem = pageItemLabels[index];
        currentPageItem.textColor = unSelectedColor;
        nextPageItem.textColor = selectedColor;
    }
   
    
    
    
        /**
     根据选择项修正Page的展示区域
     */
    func reviseTabContentOffsetBySelectedIndex(_ isAnimate: Bool) {
        
        
        let currentPageItem = pageItemLabels[selectedPageIndex]
        let selectedItemCenterX = currentPageItem.center.x
        
        var reviseX: CGFloat = 0.0
        
        if selectedItemCenterX + pageViewSize.width*0.5 >= pageScrollView.contentSize.width {
            //不足以到中心，靠右
            reviseX = CGFloat(pageScrollView.contentSize.width - pageViewSize.width);
            
        }else if selectedItemCenterX - pageViewSize.width*0.5 <= 0 {
            //不足以到中心，靠左
            reviseX = 0;
            
        }else{
            reviseX = CGFloat(selectedItemCenterX - pageViewSize.width * 0.5); //修正至中心
        }
        
        //如果前后没有偏移量差，setContentOffset实际不起作用；或者没有动画效果
        if fabsf(Float(pageScrollView.contentOffset.x-reviseX)) < 1 || !isAnimate {
           
            self.finishReviseTabContentOffset()
        }
        pageScrollView.setContentOffset(CGPoint(x: reviseX, y: 0), animated: isAnimate)
        
       
        
    }
    /**
     tabview修正完成后的操作，无论是点击还是滑动body，此方法都是真正意义上的最后一步
     */
    func finishReviseTabContentOffset() {
        
        isNeedRefreshLayout = true
        isChangeByClick = false
        
        if lastSelectedPageIndex != selectedPageIndex {
            self.delegete?.pageTabViewDidEndChange()
        }
        
        lastSelectedPageIndex = selectedPageIndex
      
    }
   
    
    
    

    
    
    func layoutIndicatorView() {
        
        let indicatorWidth = self.getIndicatorWidthWithTitle(titlesArray[selectedPageIndex])
        let selectPageItem = pageItemLabels[selectedPageIndex];
        
        indicatorView.frame = CGRect(x: selectPageItem.center.x-indicatorWidth*0.5-pageScrollView.contentOffset.x, y: pageViewSize.height-indicatorHeight, width: indicatorWidth, height: indicatorHeight)
    }
    
    /**
     根据对应文本计算下标线宽度
     */
    
    func getIndicatorWidthWithTitle(_ title: String) -> CGFloat {
        if indicatorStyle == GLPageIndicatorStyle.Default || indicatorStyle == GLPageIndicatorStyle.Stretch{
            return indicatorWidth;
        }else {
            if title.characters.count < 2 {
                return 40
            }else{
                return CGFloat(title.characters.count) * pageItemFont.pointSize + 12
            }
            
        }
    }
    
    //MARK: - didSet
    
    // 更新颜色
    private func updateColors(selectBool: Bool) {
        
        if selectBool {
        
            pageItemLabels[selectedPageIndex].textColor = selectedColor
            indicatorView.backgroundColor = selectedColor
            
            let rgb: [CGFloat] = getRGBWithColor(color: selectedColor)
            selectedColorR = rgb[0]
            selectedColorG = rgb[1]
            selectedColorB = rgb[2]
            
        }else{
            
            for (index,item) in pageItemLabels.enumerated() {
                item.textColor = index == selectedPageIndex ? selectedColor : unSelectedColor
            }
            let rgb: [CGFloat] = getRGBWithColor(color: unSelectedColor)
            unSelectedColorR = rgb[0]
            unSelectedColorG = rgb[1]
            unSelectedColorB = rgb[2]
            
        }
        
        
    }
    
    
}
//MARK: - extension
extension GLPageView: UIScrollViewDelegate {
    
    
    
    //降速结束
    /*手指滑动会触发该方法，setContentOffset:animated:不会触发*/
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == bodyScrollView {
            selectedPageIndex = NSInteger(bodyScrollView.contentOffset.x / bodyScrollView.bounds.size.width)
            self.reviseTabContentOffsetBySelectedIndex(true)
        }
        
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == bodyScrollView {
            self.reviseTabContentOffsetBySelectedIndex(true)
        }else{
            self.finishReviseTabContentOffset()
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == pageScrollView {
            
            isNeedRefreshLayout = false
            let selectPageItem: GLPageTitleLabel = pageItemLabels[selectedPageIndex] as! GLPageTitleLabel
            
            let indicatorViewX: CGFloat = selectPageItem.center.x - indicatorView.bounds.size.width * 0.5 - scrollView.contentOffset.x
            
            indicatorView.frame = CGRect(x: indicatorViewX, y: indicatorView.bounds.origin.y, width: indicatorView.bounds.size.width, height: indicatorView.bounds.size.height)
            
        } else if scrollView == bodyScrollView {
            
            //未初始化时不处理
            if bodyScrollView.contentSize.width <= 0 {
                return
            }
            //滚动过程中不允许layout
            isNeedRefreshLayout = false
            
            //获取当前左右item index(点击方式已获知左右index，无需根据contentoffset计算)
            
            if !isChangeByClick {
                if bodyScrollView.contentOffset.x <= 0 {  //左边界
                    leftItemIndex = 0
                    rightItemIndex = 0
                }else if bodyScrollView.contentOffset.x >= bodyScrollView.contentSize.width - bodyScrollView.bounds.size.width {  //右边界
                    
                    leftItemIndex = pageItemLabels.count - 1
                    rightItemIndex = pageItemLabels.count - 1
                    
                }else {
                    leftItemIndex = NSInteger(bodyScrollView.contentOffset.x / bodyScrollView.bounds.size.width)
                    rightItemIndex = leftItemIndex + 1;
                }
            }
            
            
            //调整title
            changeTitleStyle()
            
            //调整下标
            switch indicatorStyle {
            case .Default:
                changeIndicatorFrame()
                break
            case .FollowText:
                changeIndicatorFrame()
                break
            case .Stretch:
                if(isChangeByClick) {
                    
                    changeIndicatorFrame()
                    
                } else {
                    
                    changeIndicatorFrameByStretch()
                }
                break
            default:
                break
            }
        }
    }
  
    //MARK: - Title animation
    
    func changeTitleStyle() {
        
        
        //bodyScrollView的偏移百分比
        let bodyOffsetPercent: CGFloat = bodyScrollView.contentOffset.x / CGFloat(bodyScrollView.bounds.size.width) - CGFloat(leftItemIndex)
        switch titleStyle {
        case .Default:
            if !isChangeByClick {
                //滑动超过页面一半,切换视图和文字
                if bodyOffsetPercent > 0.5 {
                    self.changeSelectedItemToNextItem(rightItemIndex)
                    selectedPageIndex = rightItemIndex
                }else {
                    self.changeSelectedItemToNextItem(leftItemIndex)
                    selectedPageIndex = leftItemIndex
                }
            }
            break
        case .Gradient:
            
            //当页面不在左边界 右边界时
            if leftItemIndex != rightItemIndex {
                
                let rightScale: CGFloat = bodyOffsetPercent
                
                let leftScale = 1 - rightScale

                //颜色渐变
                let difR = selectedColorR - unSelectedColorR
                let difG = selectedColorG - unSelectedColorG
                let difB = selectedColorB - unSelectedColorB
                
                print("difR = , difG = , difB=",difR,difG,difB)
                
                print(unSelectedColorR+leftScale*difR)
                print(unSelectedColorG+leftScale*difG)
                print(unSelectedColorB+leftScale*difB)
                
                
                let leftItemColor = UIColor.init(colorLiteralRed: Float(unSelectedColorR+leftScale*difR), green: Float(unSelectedColorG+leftScale*difG), blue: Float(unSelectedColorB+leftScale*difB), alpha: 1)
                
                let rightItemColor = UIColor.init(colorLiteralRed: Float(unSelectedColorR+rightScale*difR), green: Float(unSelectedColorG+rightScale*difG), blue: Float(unSelectedColorB+rightScale*difB), alpha: 1)
                
                let leftPageItem = pageItemLabels[leftItemIndex]
                let rightPageItem = pageItemLabels[rightItemIndex]
                
                leftPageItem.textColor = leftItemColor;
                rightPageItem.textColor = rightItemColor;
                
                //字体渐变
              
                let left: CGFloat = minScale+(1-minScale)*leftScale
                print("left = ",left)
                leftPageItem.transform = CGAffineTransform.init(scaleX: left, y: left)
                
                let right: CGFloat = minScale+(1-minScale)*rightScale
                print("right = ",right)
                rightPageItem.transform = CGAffineTransform.init(scaleX: right, y: right)
                
            }

            break
        case .Blend:
            
            if leftItemIndex != rightItemIndex {
               
                //起点和终点不处理，终点时左右index已更新，会绘画错误（你可以注释看看）
                if bodyOffsetPercent == 0 {
                    return
                }
                let leftPageItem: GLPageTitleLabel = pageItemLabels[leftItemIndex] as! GLPageTitleLabel
                let rightPageItem: GLPageTitleLabel = pageItemLabels[rightItemIndex] as! GLPageTitleLabel
                leftPageItem.textColor = selectedColor;
                rightPageItem.textColor = unSelectedColor;
            
                leftPageItem.fillColor = unSelectedColor;
                rightPageItem.fillColor = selectedColor;
                leftPageItem.process = bodyOffsetPercent
                rightPageItem.process = bodyOffsetPercent
            }
            
            break
        default:
            break
        }
        
    }
    
    //MARK: - Indicator animation
    
    func changeIndicatorFrame() {
        
        //计算indicator此时的centerx
        let nowIndicatorCenterX: CGFloat = pageItemWidth*(0.5+bodyScrollView.contentOffset.x/bodyScrollView.bounds.size.width)
        
        //计算此时body的偏移量在一页中的占比
        var relativeLocation: CGFloat = (bodyScrollView.contentOffset.x/bodyScrollView.bounds.size.width - CGFloat(leftItemIndex)) / CGFloat(rightItemIndex - leftItemIndex)
        
        //记录左右对应的indicator宽度
        let leftIndicatorWidth: CGFloat = getIndicatorWidthWithTitle(titlesArray[leftItemIndex])
        
        let rightIndicatorWidth: CGFloat = getIndicatorWidthWithTitle(titlesArray[rightItemIndex])
        
        //左右边界的时候，占比清0
        if leftItemIndex == rightItemIndex {
            relativeLocation = 0.0
        }
        
        //基于从左到右方向（无需考虑滑动方向），计算当前中心轴所处位置的长度
        
        let nowIndicatorWidth: CGFloat = leftIndicatorWidth + (rightIndicatorWidth - leftIndicatorWidth) * relativeLocation
        
        
        indicatorView.frame = CGRect(x: nowIndicatorCenterX - nowIndicatorWidth * 0.5 - pageScrollView.contentOffset.x, y: indicatorView.frame.origin.y, width: nowIndicatorWidth, height: indicatorView.bounds.size.height)
        
        
    }
    
    func changeIndicatorFrameByStretch()  {
        
        if indicatorWidth <= 0 {
            return
        }
        //计算此时body的偏移量在一页中的占比
        var relativeLocation: CGFloat = (bodyScrollView.contentOffset.x / bodyScrollView.bounds.size.width - CGFloat(leftItemIndex)) / CGFloat(rightItemIndex - leftItemIndex)
        
        //左右边界的时候，占比清0
        if leftItemIndex == rightItemIndex {
            relativeLocation = 0
        }
        
        let leftPageItem = pageItemLabels[leftItemIndex]
        let rightPageItem = pageItemLabels[rightItemIndex]
        
        //当前的frame
        var nowFrame: CGRect = CGRect(x: 0, y: indicatorView.frame.origin.y, width: 0, height: indicatorView.bounds.size.height)
        //计算宽度
        if relativeLocation <= 0.5 {
            
            nowFrame.size.width = indicatorWidth + pageItemWidth * (relativeLocation / 0.5)
            nowFrame.origin.x = (leftPageItem.center.x - pageScrollView.contentOffset.x) - indicatorWidth * 0.5
        } else {
            nowFrame.size.width = indicatorWidth + pageItemWidth * ((1 - relativeLocation) / 0.5)
            nowFrame.origin.x = (rightPageItem.center.x - pageScrollView.contentOffset.x) + indicatorWidth * 0.5 - nowFrame.size.width
            
        }
        indicatorView.frame = nowFrame
        
        
    }
    
    
    /**
     获取color的rgb值
     */
    
    func getRGBWithColor(color: UIColor) -> Array<CGFloat> {
        
        var R: CGFloat = 0
        var G: CGFloat = 0
        var B: CGFloat = 0
        
        let numComponents: Int = color.cgColor.numberOfComponents
        let components: [CGFloat] = color.cgColor.components!
        if numComponents == 4 {
            R = components[0];
            G = components[1];
            B = components[2];
        }
        return [R,G,B]
    }
    
    
    
    
}




