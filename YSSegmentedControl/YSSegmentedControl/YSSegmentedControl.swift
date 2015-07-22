//
//  YSSegmentedControl.swift
//  yemeksepeti
//
//  Created by Cem Olcay on 22/04/15.
//  Copyright (c) 2015 yemeksepeti. All rights reserved.
//

import UIKit

// MARK: - Appearance

struct YSSegmentedControlAppearance {
    
    var backgroundColor: UIColor
    var selectedBackgroundColor: UIColor
    
    var textColor: UIColor
    var font: UIFont
    
    var selectedTextColor: UIColor
    var selectedFont: UIFont
    
    var bottomLineColor: UIColor
    var selectorColor: UIColor
    
    var bottomLineHeight: CGFloat
    var selectorHeight: CGFloat
}


// MARK: - Control Item

typealias YSSegmentedControlItemAction = (item: YSSegmentedControlItem) -> Void

class YSSegmentedControlItem: UIControl {
    
    // MARK: Properties
    
    var action: YSSegmentedControlItemAction?
    var label: UILabel!
    
    
    // MARK: Init
    
    init (frame: CGRect, text: String, appearance: YSSegmentedControlAppearance, action: YSSegmentedControlItemAction?) {
        super.init(frame: frame)
        self.action = action
        
        label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        label.textColor = appearance.textColor
        label.font = appearance.font
        label.textAlignment = .Center
        label.text = text
        
        addSubview(label)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init (coder: aDecoder)
    }
    
    
    // MARK: Events
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        action?(item: self)
    }
}


// MARK: - Control

@objc protocol YSSegmentedControlDelegate {
    optional func segmentedControlWillPressItemAtIndex (segmentedControl: YSSegmentedControl, index: Int)
    optional func segmentedControlDidPressedItemAtIndex (segmentedControl: YSSegmentedControl, index: Int)
}

typealias YSSegmentedControlAction = (segmentedControl: YSSegmentedControl, index: Int) -> Void

class YSSegmentedControl: UIView {
    
    // MARK: Properties
    
    weak var delegate: YSSegmentedControlDelegate?
    var action: YSSegmentedControlAction?
    
    var appearance: YSSegmentedControlAppearance! {
        didSet {
            self.draw()
        }
    }
    
    var titles: [String]!
    var items: [YSSegmentedControlItem]!
    
    var selector: UIView!
    
    
    // MARK: Init
    
    init (frame: CGRect, titles: [String]) {
        super.init (frame: frame)
        commonInit(titles)
    }
    
    init (frame: CGRect, titles: [String], action: YSSegmentedControlAction?) {
        super.init (frame: frame)
        self.action = action
        commonInit(titles)
    }

    func commonInit (titles: [String]) {
        self.titles = titles
        defaultAppearance()
    }
    
    required init (coder aDecoder: NSCoder) {
        super.init (coder: aDecoder)
    }
    
    
    // MARK: Draw
    
    func reset () {

        for sub in subviews {
            let v = sub as UIView
            v.removeFromSuperview()
        }
        
        items = []
    }
    
    func draw () {
        reset()
        
        backgroundColor = appearance.backgroundColor
        
        let width = frame.size.width / CGFloat(titles.count)
        var currentX: CGFloat = 0
        
        for title in titles {
            
            let item = YSSegmentedControlItem(
                frame: CGRect(
                    x: currentX,
                    y: 0,
                    width: width,
                    height: frame.size.height),
                text: title,
                appearance: appearance,
                action: {
                    segmentedControlItem in
                    
                    let index = self.items.indexOf(segmentedControlItem)!
                    self.selectItemAtIndex(index)
                    self.action?(segmentedControl: self, index: index)
                })
            
            addSubview(item)
            items.append(item)
            
            currentX += width
        }
        
        let bottomLine = CALayer ()
        bottomLine.frame = CGRect(
            x: 0,
            y: frame.size.height - appearance.bottomLineHeight,
            width: frame.size.width,
            height: appearance.bottomLineHeight)
        bottomLine.backgroundColor = appearance.bottomLineColor.CGColor
        layer.addSublayer(bottomLine)
        
        selector = UIView (frame: CGRect (
            x: 0,
            y: frame.size.height - appearance.selectorHeight,
            width: width,
            height: appearance.selectorHeight))
        selector.backgroundColor = appearance.selectorColor
        addSubview(selector)
        
        selectItemAtIndex(0)
    }
    
    func defaultAppearance () {
        appearance = YSSegmentedControlAppearance(
            
            backgroundColor: UIColor.clearColor(),
            selectedBackgroundColor: UIColor.clearColor(),
            
            textColor: UIColor.grayColor(),
            font: UIFont.systemFontOfSize(15),
            
            selectedTextColor: UIColor.blackColor(),
            selectedFont: UIFont.systemFontOfSize(15),
            
            bottomLineColor: UIColor.blackColor(),
            selectorColor: UIColor.blackColor(),
            
            bottomLineHeight: 0.5,
            selectorHeight: 2)
    }
    
    
    // MARK: Select
    
    func selectItemAtIndex (index: Int) {
        
        moveSelectorAtIndex(index)
        
        for item in items {
            if item == items[index] {
                item.label.textColor = appearance.selectedTextColor
                item.label.font = appearance.selectedFont
                item.backgroundColor = appearance.selectedBackgroundColor
            } else {
                item.label.textColor = appearance.textColor
                item.label.font = appearance.font
                item.backgroundColor = appearance.backgroundColor
            }
        }
    }
    
    func moveSelectorAtIndex (index: Int) {
        
        let width = frame.size.width / CGFloat(items.count)
        let target = width * CGFloat(index)
        
        UIView.animateWithDuration(0.3,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [],
            animations: {
                [unowned self] in
                self.selector.frame.origin.x = target
            },
            completion: nil)
    }
    
}
