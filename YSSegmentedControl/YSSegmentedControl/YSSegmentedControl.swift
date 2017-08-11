//
//  YSSegmentedControl.swift
//  yemeksepeti
//
//  Created by Cem Olcay on 22/04/15.
//  Copyright (c) 2015 yemeksepeti. All rights reserved.
//

import UIKit

// MARK:- ViewState

public struct YSSegmentedControlViewState {
    public var backgroundColor: UIColor
    public var selectedBackgroundColor: UIColor
    
    public var unselectedTextAttributes: [String : Any]
    public var selectedTextAttributes: [String : Any]
    
    public var bottomLineColor: UIColor
    public var bottomLineHeight: CGFloat
    public var selectorColor: UIColor
    public var selectorHeight: CGFloat
    public var itemTopPadding: CGFloat
    
    /**
     The distance between the top of the selector and the bottom
     of the label.
     If this is nil, then the selector will be anchored on the bottom
     of the segmented control;
     otherwise the selector will be this distance from the bottom of the label.
     */
    public var selectorOffsetFromLabel: CGFloat?
    
    /**
     The horizontal distance between the trailing edge of each title
     and its subsequent title's leading edge.
     */
    public var offsetBetweenTitles: CGFloat
    
    /**
     The titles that show inside the segmented control.
     */
    public var titles: [String]
    
    init() {
        backgroundColor = .clear
        selectedBackgroundColor = .clear
        unselectedTextAttributes = [:]
        selectedTextAttributes = [:]
        bottomLineColor = .black
        bottomLineHeight = 0.5
        selectorColor = .black
        selectorHeight = 2
        itemTopPadding = 0
        selectorOffsetFromLabel = nil
        offsetBetweenTitles = 48
        titles = []
    }
}

// MARK: - Control Item

typealias YSSegmentedControlItemAction = (_ item: YSSegmentedControlItem) -> Void

class YSSegmentedControlItem: UIControl {
    
    // MARK:- State

    struct ViewState {
        var title: String
        var titleAttributes: [String : Any]
        var horizontalTrailingOffset: CGFloat
        var backgroundColor: UIColor
        
        init() {
            title = ""
            titleAttributes = [:]
            horizontalTrailingOffset = 48
            backgroundColor = .clear
        }
    }
    
    var viewState = ViewState() {
        didSet {
            update()
        }
    }
    
    // MARK:- Actions
    
    private var willPress: YSSegmentedControlItemAction?
    private var didPress: YSSegmentedControlItemAction?
    
    // MARK:- UI
    
    let label = UILabel()
    
    private var labelTrailingConstraint: NSLayoutConstraint?
    
    // MARK: Init
    
    init(frame: CGRect,
         willPress: YSSegmentedControlItemAction?,
         didPress: YSSegmentedControlItemAction?) {
        self.willPress = willPress
        self.didPress = didPress

        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init (coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        labelTrailingConstraint = NSLayoutConstraint(item: label,
                                                     attribute: .trailing,
                                                     relatedBy: .equal,
                                                     toItem: self,
                                                     attribute: .trailing,
                                                     multiplier: 1.0,
                                                     constant: 0)
        addConstraint(labelTrailingConstraint!)
        
        addConstraint(NSLayoutConstraint(item: label,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .leading,
                                         multiplier: 1.0,
                                         constant: 0.0))
        
        
        addConstraint(NSLayoutConstraint(item: label,
                                         attribute: .centerY,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .centerY,
                                         multiplier: 1.0,
                                         constant: 0.0))
        
        let views: [String: Any] = ["label": label]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=0)-[label]-(>=0)-|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: views))
    }
    
    // MARK:- State
    
    private func update() {
        label.attributedText = NSAttributedString(string: viewState.title, attributes: viewState.titleAttributes)
        labelTrailingConstraint?.constant = -viewState.horizontalTrailingOffset
        
        backgroundColor = viewState.backgroundColor
        
        setNeedsLayout()
    }
    
    // MARK: Events
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        willPress?(self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        didPress?(self)
    }
}


// MARK: - Control

public protocol YSSegmentedControlDelegate: class {
    func segmentedControl(_ segmentedControl: YSSegmentedControl, willPressItemAt index: Int)
    func segmentedControl(_ segmentedControl: YSSegmentedControl, didPressItemAt index: Int)
}

public typealias YSSegmentedControlAction = (_ segmentedControl: YSSegmentedControl, _ index: Int) -> Void

public class YSSegmentedControl: UIView {
    
    // MARK:- Properties
    
    weak var delegate: YSSegmentedControlDelegate?
    public var action: YSSegmentedControlAction?
    
    private var selectedIndex = 0
    
    public var viewState = YSSegmentedControlViewState() {
        didSet {
            update(oldValue)
        }
    }
    
    private var items = [YSSegmentedControlItem]()
    
    private var scrollView = UIScrollView()
    
    private var selector = UIView()
    private var selectorHeightConstraint: NSLayoutConstraint?

    private var bottomLine = UIView()
    private var bottomLineHeightConstraint: NSLayoutConstraint?
    
    fileprivate var selectorLeadingConstraint: NSLayoutConstraint?
    fileprivate var selectorWidthConstraint: NSLayoutConstraint?
    fileprivate var selectorBottomConstraint: NSLayoutConstraint?
    
    // MARK:- Init
    
    public init (frame: CGRect, viewState: YSSegmentedControlViewState? = nil, action: YSSegmentedControlAction? = nil) {
        super.init (frame: frame)
        self.action = action
        
        if let viewState = viewState {
            self.viewState = viewState
        }
        
        // bottomLine
        addSubview(bottomLine)
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        var views = ["bottomLine": bottomLine]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomLine]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomLine]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: views))
        bottomLineHeightConstraint = NSLayoutConstraint(item: bottomLine,
                                                        attribute: .height,
                                                        relatedBy: .equal,
                                                        toItem: nil,
                                                        attribute: .notAnAttribute,
                                                        multiplier: 1.0,
                                                        constant: viewState?.bottomLineHeight ?? 0)
        addConstraint(bottomLineHeightConstraint!)
        
        // scrollView
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        views = ["scrollView": scrollView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: views))
        // selector
        scrollView.addSubview(selector)
        selector.translatesAutoresizingMaskIntoConstraints = false
        selectorHeightConstraint = NSLayoutConstraint(item: selector,
                                                      attribute: .height,
                                                      relatedBy: .equal,
                                                      toItem: nil,
                                                      attribute: .notAnAttribute,
                                                      multiplier: 1.0,
                                                      constant: viewState?.selectorHeight ?? 0)
        scrollView.addConstraint(selectorHeightConstraint!)
    }
    
    required public init? (coder aDecoder: NSCoder) {
        super.init (coder: aDecoder)
    }
    
    // MARK:- ViewState
    
    private func update(_ oldViewState: YSSegmentedControlViewState) {
        // If the number of titles have changed, re-add all of the items.
        if oldViewState.titles.count != viewState.titles.count {
            // Remove all items
            items.forEach { $0.removeFromSuperview() }
            items.removeAll()
            
            // Re-Add all items
            for _ in viewState.titles {
                let item = YSSegmentedControlItem(
                    frame: .zero,
                    willPress: { [weak self] segmentedControlItem in
                        guard let weakSelf = self else {
                            return
                        }
                        
                        let index = weakSelf.items.index(of: segmentedControlItem)!
                        weakSelf.delegate?.segmentedControl(weakSelf, willPressItemAt: index)
                    },
                    didPress: { [weak self] segmentedControlItem in
                        guard let weakSelf = self else {
                            return
                        }
                        
                        let index = weakSelf.items.index(of: segmentedControlItem)!
                        weakSelf.selectItem(at: index, withAnimation: true)
                        weakSelf.action?(weakSelf, index)
                        weakSelf.delegate?.segmentedControl(weakSelf, didPressItemAt: index)
                })
                
                scrollView.addSubview(item)
                items.append(item)
            }
            
            // Constrain all the items
            for (index, item) in items.enumerated() {
                item.translatesAutoresizingMaskIntoConstraints = false

                // Horizontal constraints
                
                // First
                if index == 0 {
                    scrollView.addConstraint(NSLayoutConstraint(item: item,
                                                                attribute: .leading,
                                                                relatedBy: .equal,
                                                                toItem: scrollView,
                                                                attribute: .leading,
                                                                multiplier: 1.0,
                                                                constant: 0.0))
                }
                // Middle or last
                else {
                    let previousItem = items[index - 1]
                    scrollView.addConstraint(NSLayoutConstraint(item: item,
                                                                attribute: .leading,
                                                                relatedBy: .equal,
                                                                toItem: previousItem,
                                                                attribute: .trailing,
                                                                multiplier: 1.0,
                                                                constant: 0))
                }
                // Last
                if index == items.count - 1 {
                    scrollView.addConstraint(NSLayoutConstraint(item: item,
                                                                 attribute: .trailing,
                                                                 relatedBy: .equal,
                                                                 toItem: scrollView,
                                                                 attribute: .trailing,
                                                                 multiplier: 1.0,
                                                                 constant: 0.0))
                }
                
                // Vertical constraints
                
                let views = ["item": item]
                scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[item]|", options: [], metrics: nil, views: views))
                // Need to add this height constraint because the scrollView won't stretch the label to the bottom
                scrollView.addConstraint(NSLayoutConstraint(item: item,
                                                            attribute: .height,
                                                            relatedBy: .equal,
                                                            toItem: scrollView,
                                                            attribute: .height,
                                                            multiplier: 1.0,
                                                            constant: 0.0))
            }
            
            // If titles have been removed such the selectedIndex is out of
            // bounds, bump it back by 1.
            if selectedIndex >= viewState.titles.count {
                selectedIndex = viewState.titles.count > 0 ? viewState.titles.count - 1 : 0
            }
        }
        
        // Update the states of all the items
        assert(viewState.titles.count == items.count, "There was a different number of titles than items. These should always be in sync.")
        
        for (index, item) in items.enumerated() {
            var viewState = item.viewState
            viewState.title = self.viewState.titles[index]
            
            // Don't add horizontal trailing offset to the last one,
            // otherwise there is unecessary scrolling.
            if index == items.count - 1 {
                viewState.horizontalTrailingOffset = 0
            }
            else {
                viewState.horizontalTrailingOffset = self.viewState.offsetBetweenTitles
            }
            
            item.viewState = viewState
        }
        
        // Other viewState properties
        backgroundColor = viewState.backgroundColor
        
        // bottom line
        bottomLineHeightConstraint?.constant = viewState.bottomLineHeight
        bottomLine.backgroundColor = viewState.bottomLineColor
        
        // selector
        selectorHeightConstraint?.constant = viewState.selectorHeight
        selector.backgroundColor = viewState.selectorColor
        
        selectItem(at: selectedIndex, withAnimation: false)
        
        setNeedsLayout()
    }
    
    // MARK: Select
    
    public func selectItem(at index: Int, withAnimation animation: Bool) {
        self.selectedIndex = index
        moveSelector(at: index, withAnimation: animation)
        
        assert(index < items.count, "index was out of bounds of items")
        
        // scroll to the selected item if its bounds are out of the scrollview
        let selectedItemFrame = items[index].frame
        let scrollViewContentOffsetRightPoint = scrollView.contentOffset.x + scrollView.bounds.size.width
        let selectedItemFrameRightPoint = selectedItemFrame.origin.x + selectedItemFrame.size.width
        
        if selectedItemFrame.origin.x < scrollView.contentOffset.x ||
            scrollViewContentOffsetRightPoint < selectedItemFrameRightPoint {
            scrollView.scrollRectToVisible(selectedItemFrame, animated: animation)
        }
        
        for item in items {
            if item == items[index] {
                var viewState = item.viewState
                viewState.titleAttributes = self.viewState.selectedTextAttributes
                viewState.backgroundColor = self.viewState.selectedBackgroundColor
                item.viewState = viewState
            }
            else {
                var viewState = item.viewState
                viewState.titleAttributes = self.viewState.unselectedTextAttributes
                viewState.backgroundColor = self.viewState.backgroundColor
                item.viewState = viewState
            }
        }
    }
    
    private func moveSelector(at index: Int, withAnimation animation: Bool) {
        guard items.count > selectedIndex else {
            return
        }
        
        scrollView.layoutIfNeeded()

        if let selectorWidthConstraint = selectorWidthConstraint {
            scrollView.removeConstraint(selectorWidthConstraint)
        }
        if let selectorLeadingConstraint = selectorLeadingConstraint {
            scrollView.removeConstraint(selectorLeadingConstraint)
        }
        if let selectorBottomConstraint = selectorBottomConstraint {
            scrollView.removeConstraint(selectorBottomConstraint)
        }
        
        let item = items[selectedIndex]
        
        let horizontalConstrainingView = item.label
        
        selectorLeadingConstraint = NSLayoutConstraint(item: selector,
                                                       attribute: .leading,
                                                       relatedBy: .equal,
                                                       toItem: horizontalConstrainingView,
                                                       attribute: .leading,
                                                       multiplier: 1.0,
                                                       constant: 0)
        
        selectorWidthConstraint = NSLayoutConstraint(item: selector,
                                                     attribute: .width,
                                                     relatedBy: .equal,
                                                     toItem: horizontalConstrainingView,
                                                     attribute: .width,
                                                     multiplier: 1.0,
                                                     constant: 0)
        
        if let selectorOffsetFromLabel = viewState.selectorOffsetFromLabel {
            selectorBottomConstraint = NSLayoutConstraint(item: selector,
                                                          attribute: .top,
                                                          relatedBy: .equal,
                                                          toItem: item.label,
                                                          attribute: .bottom,
                                                          multiplier: 1.0,
                                                          constant: selectorOffsetFromLabel)
        }
        else {
            selectorBottomConstraint = NSLayoutConstraint(item: selector,
                                                          attribute: .bottom,
                                                          relatedBy: .equal,
                                                          toItem: scrollView,
                                                          attribute: .bottom,
                                                          multiplier: 1.0,
                                                          constant: 0)
        }
        
        
        scrollView.addConstraints([selectorWidthConstraint!, selectorLeadingConstraint!, selectorBottomConstraint!])
        
        UIView.animate(withDuration: animation ? 0.3 : 0,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0,
                       options: [],
                       animations: {
                        [unowned self] in
                        
                        self.scrollView.layoutIfNeeded()
            },
                       completion: nil)
    }
}
