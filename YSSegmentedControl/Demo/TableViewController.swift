//
//  ViewController.swift
//  YSSegmentedControl
//
//  Created by Cem Olcay on 22/04/15.
//  Copyright (c) 2015 Cem Olcay. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    // MARK: Demo
    
    @IBOutlet weak var selectorOffsetFromLabelStepper: UIStepper!
    @IBOutlet weak var selectorOffsetFromLabelSwitch: UISwitch!
    @IBOutlet weak var selectorOffsetFromLabelValueLabel: UILabel!
    
    // MARK: Lifecycle
    
    let segmented = YSSegmentedControl(frame: .zero, titles: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        segmented.frame = CGRect(x: 0, y: 64, width: view.frame.size.width, height: 44)
        segmented.titles = ["First", "Second", "Third"]
        segmented.action = { control, index in
            print ("segmented did pressed \(index)")
        }
        
        segmented.delegate = self
        
        var appearance = segmented.appearance
        appearance?.textAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.gray]
        appearance?.selectedTextAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.black]
        segmented.appearance = appearance

        navigationItem.titleView = segmented
        
        selectorOffsetFromLabelValueLabel.text = "\(selectorOffsetFromLabelStepper.value)"
        
        selectorOffsetFromLabelStepper.value = Double(segmented.appearance.selectorOffsetFromLabel ?? 0)
        selectorOffsetFromLabelSwitch.isOn = segmented.appearance.selectorOffsetFromLabel != nil
        selectorOffsetFromLabelValueLabel.text = "\(selectorOffsetFromLabelStepper.value)"
    }
    
    @IBAction func didToggleSelectorSpansFullItemWidthSwitch(_ sender: UISwitch) {
        var appearance = segmented.appearance
        appearance?.selectorSpansFullItemWidth = sender.isOn
        segmented.appearance = appearance
    }
    
    @IBAction func didToggleSelectorOffsetFromLabelSwitch(_ sender: UISwitch) {
        var appearance = segmented.appearance
        appearance?.selectorOffsetFromLabel = sender.isOn ? CGFloat(selectorOffsetFromLabelStepper.value) : nil
        segmented.appearance = appearance
    }

    @IBAction func didChageSelectorOffsetFromlabelStepper(_ sender: UIStepper) {
        selectorOffsetFromLabelSwitch.isOn = true
        selectorOffsetFromLabelValueLabel.text = "\(sender.value)"
        
        var appearance = segmented.appearance
        appearance?.selectorOffsetFromLabel = CGFloat(sender.value)
        segmented.appearance = appearance
    }
}

extension TableViewController: YSSegmentedControlDelegate {
    func segmentedControl(_ segmentedControl: YSSegmentedControl, willPressItemAt index: Int) {
        print ("[Delegate] segmented will press \(index)")
    }
    
    func segmentedControl(_ segmentedControl: YSSegmentedControl, didPressItemAt index: Int) {
        print ("[Delegate] segmented did press \(index)")
    }
}
