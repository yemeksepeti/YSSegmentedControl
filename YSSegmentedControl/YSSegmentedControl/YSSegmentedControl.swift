//
//  YSSegmentedControl.swift
//  yemeksepeti
//
//  Created by Cem Olcay on 22/04/15.
//  Copyright (c) 2015 yemeksepeti. All rights reserved.
//

import UIKit

// MARK: - Appearance

public struct YSSegmentedControlAppearance {
    public var backgroundColor: UIColor
    public var selectedBackgroundColor: UIColor
    public var textColor: UIColor
    public var font: UIFont
    public var selectedTextColor: UIColor
    public var selectedFont: UIFont
    public var bottomLineColor: UIColor
    public var selectorColor: UIColor
    public var bottomLineHeight: CGFloat
    public var selectorHeight: CGFloat
    public var labelTopPadding: CGFloat
    
}


// MARK: - Control Item

typealias YSSegmentedControlItemAction = (item: YSSegmentedControlItem) -> Void

class YSSegmentedControlItem: UIControl {
    
    // MARK: Properties
    
    private var willPress: YSSegmentedControlItemAction?
    private var didPressed: YSSegmentedControlItemAction?
    var label: UILabel!
    
    // MARK: Init
    
    init (
        frame: CGRect,
        text: String,
        appearance: YSSegmentedControlAppearance,
        willPress: YSSegmentedControlItemAction?,
        didPressed: YSSegmentedControlItemAction?) {
            super.init(frame: frame)
            self.willPress = willPress
            self.didPressed = didPressed
            label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
            label.textColor = appearance.textColor
            label.font = appearance.font
            label.textAlignment = .Center
            label.text = text
            addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init (coder: aDecoder)
    }
    
    // MARK: Events
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        willPress?(item: self)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        didPressed?(item: self)
    }
}


// MARK: - Control

@objc public protocol YSSegmentedControlDelegate {
    optional func segmentedControlWillPressItemAtIndex (segmentedControl: YSSegmentedControl, index: Int)
    optional func segmentedControlDidPressedItemAtIndex (segmentedControl: YSSegmentedControl, index: Int)
}

public typealias YSSegmentedControlAction = (segmentedControl: YSSegmentedControl, index: Int) -> Void

public class YSSegmentedControl: UIView {
    
    // MARK: Properties
    
    weak var delegate: YSSegmentedControlDelegate?
    var action: YSSegmentedControlAction?
    
    public var appearance: YSSegmentedControlAppearance! {
        didSet {
            self.draw()
        }
    }
    
    var titles: [String]!
    var items: [YSSegmentedControlItem]!
    var selector: UIView!
    
    // MARK: Init
    
    public init (frame: CGRect, titles: [String], action: YSSegmentedControlAction? = nil) {
        super.init (frame: frame)
        self.action = action
        self.titles = titles
        defaultAppearance()
    }
    
    required public init? (coder aDecoder: NSCoder) {
        super.init (coder: aDecoder)
    }
    
    // MARK: Draw
    
    private func reset () {
        for sub in subviews {
            let v = sub
            v.removeFromSuperview()
        }
        items = []
    }
    
    private func draw () {
        reset()
        backgroundColor = appearance.backgroundColor
        let width = frame.size.width / CGFloat(titles.count)
        var currentX: CGFloat = 0
        for title in titles {
            let item = YSSegmentedControlItem(
                frame: CGRect(
                    x: currentX,
                    y: appearance.labelTopPadding,
                    width: width,
                    height: frame.size.height - appearance.labelTopPadding),
                text: title,
                appearance: appearance,
                willPress: { segmentedControlItem in
                    let index = self.items.indexOf(segmentedControlItem)!
                    self.delegate?.segmentedControlWillPressItemAtIndex?(self, index: index)
                },
                didPressed: {
                    segmentedControlItem in
                    let index = self.items.indexOf(segmentedControlItem)!
                    self.selectItemAtIndex(index, withAnimation: true)
                    self.action?(segmentedControl: self, index: index)
                    self.delegate?.segmentedControlDidPressedItemAtIndex?(self, index: index)
            })
            addSubview(item)
            items.append(item)
            currentX += width
        }
        // bottom line
        let bottomLine = CALayer ()
        bottomLine.frame = CGRect(
            x: 0,
            y: frame.size.height - appearance.bottomLineHeight,
            width: frame.size.width,
            height: appearance.bottomLineHeight)
        bottomLine.backgroundColor = appearance.bottomLineColor.CGColor
        layer.addSublayer(bottomLine)
        // selector
        selector = UIView (frame: CGRect (
            x: 0,
            y: frame.size.height - appearance.selectorHeight,
            width: width,
            height: appearance.selectorHeight))
        selector.backgroundColor = appearance.selectorColor
        addSubview(selector)
        
        selectItemAtIndex(0, withAnimation: true)
    }
    
    private func defaultAppearance () {
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
            selectorHeight: 2,
            labelTopPadding: 0)
    }
    
    // MARK: Select
    
    public func selectItemAtIndex (index: Int, withAnimation: Bool) {
        moveSelectorAtIndex(index, withAnimation: withAnimation)
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
    
    private func moveSelectorAtIndex (index: Int, withAnimation: Bool) {
        let width = frame.size.width / CGFloat(items.count)
        let target = width * CGFloat(index)
        UIView.animateWithDuration(withAnimation ? 0.3 : 0,
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
