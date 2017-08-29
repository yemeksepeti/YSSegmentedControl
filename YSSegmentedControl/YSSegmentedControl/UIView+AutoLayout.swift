//
//  UIView+AutoLayout.swift
//  YSSegmentedControl
//
//  Created by Josh Sklar on 2/1/17.
//  Copyright © 2017 StockX. All rights reserved.
//

import UIKit

extension UIView {
    
    // MARK: Edges
    
    /**
     Makes the edges of the receiver equal to the edges of `view`.
     
     Note: `view` must already be constrained, and both the receiver
     and `view` must have a common superview.
     */
    func makeEdgesEqualTo(_ view: UIView) {
        makeAttribute(.leading, equalToOtherView: view, attribute: .leading)
        makeAttribute(.trailing, equalToOtherView: view, attribute: .trailing)
        makeAttribute(.top, equalToOtherView: view, attribute: .top)
        makeAttribute(.bottom, equalToOtherView: view, attribute: .bottom)
    }
    
    /**
     Makes the edges of the receiver equal to its superview with an otion to
     specify an inset value.
     
     If the receiver does not have a superview, this does nothing.
     */
    func makeEdgesEqualToSuperview(inset: CGFloat = 0) {
        makeAttributesEqualToSuperview([.leading, .top], offset: inset)
        makeAttributesEqualToSuperview([.trailing, .bottom], offset: -inset)
    }
    
    // MARK: Attributes
    
    /**
     Creates and applies a constraint with the given attribute equal to that
     same attribute of the superview, and returns the constraint.
     */
    func makeConstraintEqualToSuperview(_ attribute: NSLayoutAttribute) -> NSLayoutConstraint? {
        guard let superview = superview else {
            return nil
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: attribute,
                                            relatedBy: .equal,
                                            toItem: superview,
                                            attribute: attribute,
                                            multiplier: 1.0,
                                            constant: 0.0)
        superview.addConstraint(constraint)
        return constraint
    }
    /**
     Applies constraints to the receiver with attributes `attributes` all
     equal to its superview.
     */
    func makeAttributesEqualToSuperview(_ attributes: [NSLayoutAttribute], offset: CGFloat = 0) {
        makeAttributes(attributes, relationToSuperview: .equal, offset: offset)
    }
    
    func makeAttributesGreaterThanOrEqualToSuperview(_ attributes: [NSLayoutAttribute], offset: CGFloat = 0) {
        makeAttributes(attributes, relationToSuperview: .greaterThanOrEqual, offset: offset)
    }
    
    func makeAttributesLessThanOrEqualToSuperview(_ attributes: [NSLayoutAttribute], offset: CGFloat = 0) {
        makeAttributes(attributes, relationToSuperview: .lessThanOrEqual, offset: offset)
    }
    
    func makeAttributes(_ attributes: [NSLayoutAttribute], relationToSuperview relation: NSLayoutRelation = .equal, offset: CGFloat = 0) {
        guard let superview = superview else {
            return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        attributes.forEach {
            superview.addConstraint(NSLayoutConstraint(item: self,
                                                       attribute: $0,
                                                       relatedBy: relation,
                                                       toItem: superview,
                                                       attribute: $0,
                                                       multiplier: 1.0,
                                                       constant: offset))
        }
    }
    
    /**
     Creates and applies a constraint to the receiver with attribute
     `attribute` and the specified constant, and returns the constraint.
     */
    func makeConstraint(for attribute: NSLayoutAttribute, equalTo constant: CGFloat) -> NSLayoutConstraint? {
        guard let superview = superview else {
            return nil
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: attribute,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1.0,
                                            constant: constant)
        superview.addConstraint(constraint)
        return constraint
    }
    
    /**
     Applies a constraint to the receiver with attribute `attribute` and
     the specified constant.
     */
    func makeAttribute(_ attribute: NSLayoutAttribute, equalTo constant: CGFloat) {
        guard let superview = superview else {
            return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: attribute,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1.0,
                                            constant: constant)
        superview.addConstraint(constraint)
    }
    
    /**
     Applies a constraint with the attribute `attribute` from the receiver to
     the view `otherView` with attribute `attribute`.
     */
    func makeAttribute(_ attribute: NSLayoutAttribute,
                       equalToOtherView otherView: UIView,
                       attribute otherAttribute: NSLayoutAttribute,
                       constant: CGFloat = 0) {
        guard let sv = otherView.superview,
            sv == self.superview else {
                return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let attribute = NSLayoutConstraint(item: self,
                                           attribute: attribute,
                                           relatedBy: .equal,
                                           toItem: otherView,
                                           attribute: otherAttribute,
                                           multiplier: 1.0,
                                           constant: constant)
        sv.addConstraint(attribute)
    }
    
    
    // MARK: Utility
    
    /**
     Removes all the constrains where the receiver is either the
     firstItem or secondItem.
     
     If the receiver does not have a superview, this only removes the
     constraints that the receiver owns.
     */
    func removeAllConstraints() {
        guard let superview = superview else {
            removeConstraints(constraints)
            return
        }
        
        for constraint in superview.constraints where (constraint.firstItem as? UIView == self || constraint.secondItem as? UIView == self) {
            superview.removeConstraint(constraint)
        }
        
        removeConstraints(constraints)
    }
}
