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
    
    public var unselectedTextAttributes: [NSAttributedStringKey : Any]
    public var selectedTextAttributes: [NSAttributedStringKey : Any]
    
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
     Whether or not the items should be evenly spaced horizontally,
     or laid out sequentially, one directly after the other.
     
     If this is set to true, then the first item will be constrained
     to the leading edge of the superview, and the last label will be
     constrained to the trailing edge of the superview, and all labels in
     between will be evenly spaced.
     
     If this is set to false, then the labels are laid out sequentially,
     one directly after the other, and they scroll if they extend off the edge
     of the superview.
     
     Defaults to false.
     */
    public var shouldEvenlySpaceItemsHorizontally: Bool
    
    /**
     Whether or not the selector should be the same size as the item text,
     or a proportion of the screen
     */
    public var shouldSelectorBeSameWidthAsText: Bool
    
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
        shouldEvenlySpaceItemsHorizontally = false
        shouldSelectorBeSameWidthAsText = false
        titles = []
    }
}

// MARK: - Control Item

typealias YSSegmentedControlItemAction = (_ item: YSSegmentedControlItem) -> Void

class YSSegmentedControlItem: UIControl {
    
    // MARK:- State

    struct ViewState {
        var title: String
        var titleAttributes: [NSAttributedStringKey : Any]
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
    
    /**
     Array of all spacer views that are used to evenly space out the items
     when shouldEvenlySpaceItemsHorizontally is set to true.
     */
    private var spacerViews = [UIView]()
    
    private var scrollView = UIScrollView()
    
    private var selector = UIView()
    private var selectorHeightConstraint: NSLayoutConstraint?

    private var bottomLine = UIView()
    private var bottomLineHeightConstraint: NSLayoutConstraint?
    
    fileprivate var selectorLeadingConstraint: NSLayoutConstraint?
    fileprivate var selectorWidthConstraint: NSLayoutConstraint?
    fileprivate var selectorBottomConstraint: NSLayoutConstraint?
    
    /**
     A view to horizontally constrain the scrollView to have
     equal width to its superview.
     
     This is used when shouldEvenlySpaceItemsHorizontally is set to true
     so that the width of the scrollView is fixed so that we can add
     horizontal spacer views.
     */
    fileprivate let horizontalScrollViewConstrainingView = UIView()
    
    // MARK:- Init
    
    public init (frame: CGRect, viewState: YSSegmentedControlViewState? = nil, action: YSSegmentedControlAction? = nil) {
        super.init (frame: frame)
        self.action = action
        
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
        
        if let viewState = viewState {
            self.viewState = viewState
        }
    }
    
    required public init? (coder aDecoder: NSCoder) {
        super.init (coder: aDecoder)
    }
    
    // MARK:- ViewState
    
    /**
     Removes all the items and their associated views (such as spacer views
     and other constraining views) from the scrollView.
     */
    private func removeItemsAndAssociatedViews() {
        items.forEach { $0.removeFromSuperview() }
        items.removeAll()
        spacerViews.forEach { $0.removeFromSuperview() }
        spacerViews.removeAll()
        horizontalScrollViewConstrainingView.removeFromSuperview()
    }
    
    /**
     Lays out all of the YSSegmentedControlItems by adding them to the subview,
     and then constrainign them properly based on the state).
     */
    private func layoutItems() {
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

        if viewState.shouldEvenlySpaceItemsHorizontally {
            scrollView.addSubview(horizontalScrollViewConstrainingView)
            
            _ = horizontalScrollViewConstrainingView.makeConstraint(for: .height, equalTo: 0)
            
            addConstraint(NSLayoutConstraint(item: horizontalScrollViewConstrainingView,
                                             attribute: .width,
                                             relatedBy: .equal,
                                             toItem: self,
                                             attribute: .width,
                                             multiplier: 1.0,
                                             constant: 0.0))
            
            horizontalScrollViewConstrainingView.makeAttributesEqualToSuperview([.top])
            horizontalScrollViewConstrainingView.makeAttributesEqualToSuperview([.leading, .trailing])
        }

        // Constrain all the items
        for (index, item) in items.enumerated() {
            item.translatesAutoresizingMaskIntoConstraints = false
            
            // Horizontal constraints
            
            // First
            if index == 0 {
                item.makeAttributesEqualToSuperview([.leading])
            }
            // Middle or last
            else {
                let previousItem = items[index - 1]
                
                if viewState.shouldEvenlySpaceItemsHorizontally {
                    let newSpacerView = UIView()
                    newSpacerView.translatesAutoresizingMaskIntoConstraints = false
                    scrollView.addSubview(newSpacerView)
                    spacerViews.append(newSpacerView)
                    
                    newSpacerView.makeAttribute(.leading, equalToOtherView: previousItem, attribute: .trailing)
                    newSpacerView.makeAttribute(.trailing, equalToOtherView: item, attribute: .leading)
                    _ = newSpacerView.makeConstraint(for: .height, equalTo: 0)
                    newSpacerView.makeAttribute(.centerY, equalToOtherView: previousItem, attribute: .centerY)
                    scrollView.addConstraint(NSLayoutConstraint(item: newSpacerView,
                                                                attribute: .width,
                                                                relatedBy: .greaterThanOrEqual,
                                                                toItem: nil,
                                                                attribute: .notAnAttribute,
                                                                multiplier: 1.0,
                                                                constant: 10))
                    
                    if spacerViews.count > 1 {
                        let previousSpacerView = spacerViews[spacerViews.count - 2]
                        newSpacerView.makeAttribute(.width, equalToOtherView: previousSpacerView, attribute: .width)
                    }
                }
                else {
                    item.makeAttribute(.leading, equalToOtherView: previousItem, attribute: .trailing)
                }
            }
            
            // Last
            if index == items.count - 1 {
                item.makeAttributesEqualToSuperview([.trailing])
            }
            
            // Vertical constraints
            
            let views = ["item": item]
            scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[item]|", options: [], metrics: nil, views: views))
            // Need to add this height constraint because the scrollView won't stretch the label to the bottom
            item.makeAttributesEqualToSuperview([.height])
        }
    }
    
    private func update(_ oldViewState: YSSegmentedControlViewState) {
        // If the number of titles have changed, re-add all of the items.
        if oldViewState.titles.count != viewState.titles.count ||
            oldViewState.shouldEvenlySpaceItemsHorizontally != viewState.shouldEvenlySpaceItemsHorizontally {
            
            // Remove all items
            removeItemsAndAssociatedViews()
            layoutItems()
            
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
            
            /**
             If shouldEvenlySpaceItemsHorizontally is set to true, don't add
             any trailing offset, as we want the items to be evenly spaced.
             Or, if that is set ot false, then don't add horizontal trailing
             offset to the last one, otherwise there is potentially unecessary scrolling.
             */
            if self.viewState.shouldEvenlySpaceItemsHorizontally ||
                index == items.count - 1 {
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
        
        guard index < items.count else {
            return
        }
        
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
