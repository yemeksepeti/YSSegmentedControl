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
    
    @IBOutlet weak var newTitleTextField: UITextField!
    
    @IBOutlet weak var offsetBewteenTitlesStepper: UIStepper!
    @IBOutlet weak var offsetBetweenTitlesValueLabel: UILabel!
    
    @IBOutlet weak var bottomLineHeightStepper: UIStepper!
    @IBOutlet weak var bottomLineHeightValueLabel: UILabel!
    
    @IBOutlet weak var shouldEvenlySpaceItemsHorizontallySwitch: UISwitch!
    
    // MARK: Lifecycle
    
    let segmented = YSSegmentedControl(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        segmented.frame = CGRect(x: 0, y: 64, width: view.frame.size.width, height: 44)
        
        var viewState = segmented.viewState
        
        viewState.titles = ["First", "Second", "Third"]
        viewState.unselectedTextAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.gray]
        viewState.selectedTextAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.black]
        
        segmented.viewState = viewState
        
        segmented.action = { control, index in
            print ("segmented did pressed \(index)")
        }
        
        segmented.delegate = self

        navigationItem.titleView = segmented
        
        updateAppearanceConfigurationUI()
    }
    
    // MARK:- Actions
    
    @IBAction func didTapResetButton(_ sender: UIButton) {
        segmented.viewState = YSSegmentedControlViewState()
    }
    
    @IBAction func didToggleSelectorOffsetFromLabelSwitch(_ sender: UISwitch) {
        var viewState = segmented.viewState
        viewState.selectorOffsetFromLabel = sender.isOn ? CGFloat(selectorOffsetFromLabelStepper.value) : nil
        segmented.viewState = viewState
    }

    @IBAction func didChageSelectorOffsetFromlabelStepper(_ sender: UIStepper) {
        selectorOffsetFromLabelSwitch.isOn = true
        selectorOffsetFromLabelValueLabel.text = "\(sender.value)"
        
        var viewState = segmented.viewState
        viewState.selectorOffsetFromLabel = CGFloat(sender.value)
        segmented.viewState = viewState
    }

    @IBAction func didChangeOffsetBetweenTitlesStepper(_ sender: UIStepper) {
        offsetBetweenTitlesValueLabel.text = "\(sender.value)"

        var viewState = segmented.viewState
        viewState.offsetBetweenTitles = CGFloat(sender.value)
        segmented.viewState = viewState
    }
    
    @IBAction func didChangeBottomLineHeigtStepper(_ sender: UIStepper) {
        guard sender.value > 0 else {
            return
        }
        
        bottomLineHeightValueLabel.text = "\(sender.value)"
        
        var viewState = segmented.viewState
        viewState.bottomLineHeight = CGFloat(sender.value)
        segmented.viewState = viewState
    }
    
    @IBAction func didToggleShouldEvenlySpaceItemsHorizontallySwitch(_ sender: UISwitch) {
        var viewState = segmented.viewState
        viewState.shouldEvenlySpaceItemsHorizontally = sender.isOn
        segmented.viewState = viewState
    }
    
    // MARK: Helpers
    
    func updateAppearanceConfigurationUI() {
        selectorOffsetFromLabelValueLabel.text = "\(selectorOffsetFromLabelStepper.value)"
        
        selectorOffsetFromLabelStepper.value = Double(segmented.viewState.selectorOffsetFromLabel ?? 0)
        selectorOffsetFromLabelSwitch.isOn = segmented.viewState.selectorOffsetFromLabel != nil
        selectorOffsetFromLabelValueLabel.text = "\(selectorOffsetFromLabelStepper.value)"
        
        offsetBewteenTitlesStepper.value = Double(segmented.viewState.offsetBetweenTitles)
        offsetBetweenTitlesValueLabel.text = "\(offsetBewteenTitlesStepper.value)"
        
        bottomLineHeightStepper.value = Double(segmented.viewState.bottomLineHeight)
        bottomLineHeightValueLabel.text = "\(bottomLineHeightStepper.value)"
        
        shouldEvenlySpaceItemsHorizontallySwitch.isOn = segmented.viewState.shouldEvenlySpaceItemsHorizontally
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

extension TableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        var viewState = segmented.viewState
        viewState.titles.append(textField.text ?? "")
        segmented.viewState = viewState

        textField.text = ""
        return true
    }
}
