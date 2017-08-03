//
//  ViewController.swift
//  YSSegmentedControl
//
//  Created by Cem Olcay on 22/04/15.
//  Copyright (c) 2015 Cem Olcay. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: Lifecycle
    
    let segmented = YSSegmentedControl(frame: .zero, titles: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Demo"

        segmented.frame = CGRect(x: 0, y: 64, width: view.frame.size.width, height: 44)
        segmented.titles = ["First", "Second", "Third"]
        segmented.action = { control, index in
            print ("segmented did pressed \(index)")
        }
        
        segmented.delegate = self
        view.addSubview(segmented)
    }
    
    @IBAction func didToggleSelectorSpansFullItemWidthSwitch(_ sender: UISwitch) {
        var appearance = segmented.appearance
        appearance?.selectorSpansFullItemWidth = sender.isOn
        segmented.appearance = appearance
    }
    
}

extension ViewController: YSSegmentedControlDelegate {
    func segmentedControl(_ segmentedControl: YSSegmentedControl, willPressItemAt index: Int) {
        print ("[Delegate] segmented will press \(index)")
    }
    
    func segmentedControl(_ segmentedControl: YSSegmentedControl, didPressItemAt index: Int) {
        print ("[Delegate] segmented did press \(index)")
    }
}
