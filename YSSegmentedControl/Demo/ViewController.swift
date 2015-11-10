//
//  ViewController.swift
//  YSSegmentedControl
//
//  Created by Cem Olcay on 22/04/15.
//  Copyright (c) 2015 Cem Olcay. All rights reserved.
//

import UIKit

class ViewController: UIViewController, YSSegmentedControlDelegate {

    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor (white: 240.0/255.0, alpha: 1)
        navigationItem.title = "Demo"
        
        let segmented = YSSegmentedControl(
            frame: CGRect(
                x: 0,
                y: 64,
                width: view.frame.size.width,
                height: 44),
            titles: [
                "First",
                "Second",
                "Third"
            ],
            action: {
                control, index in
                print ("segmented did pressed \(index)")
            })
        segmented.delegate = self
        view.addSubview(segmented)
    }
    
    // MARK: YSSegmentedControlDelegate
    
    func segmentedControlWillPressItemAtIndex(segmentedControl: YSSegmentedControl, index: Int) {
        print ("[Delegate] segmented will press \(index)")
    }
    
    func segmentedControlDidPressedItemAtIndex(segmentedControl: YSSegmentedControl, index: Int) {
        print ("[Delegate] segmented did pressed \(index)")
    }
}

