//
//  TresholdDetailsViewController.swift
//  Test_engineer
//
//  Created by Kacper on 27/01/2022.
//

import UIKit

enum ThresholdTypeCallback{
    case THRESHOLD, THRESHOLD_ADAPTIVE, THRESHOLD_OTSU
}

protocol ThresholdDetailsViewControllerDelegate {
    func thresholdCallback(threshold: Int, type: ThresholdTypeCallback, isForPreview: Bool)
    func cancelOperation()
}

class ThresholdDetailsViewController: UIViewController {
    

    private var CANCEL_FLAG: Bool = false // flag for presentation controller gesture recognizer if tapped background
    @IBOutlet weak var btnApply: NeumorphicView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var slider: UISlider!
    var thresholdCallbackType: ThresholdTypeCallback = .THRESHOLD //default
    var delegate: ThresholdDetailsViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.btnTapped(_:)))
        btnApply.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    deinit{
        if self.CANCEL_FLAG{ self.delegate?.cancelOperation() }
    }
    
    
    @objc func btnTapped(_ sender: UITapGestureRecognizer? = nil) {
        self.delegate?.thresholdCallback(threshold: Int(slider.value), type: self.thresholdCallbackType, isForPreview: false)
        self.CANCEL_FLAG = false
        self.dismiss(animated: true, completion: nil)
    }
    
  
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        self.delegate?.thresholdCallback(threshold: Int(slider.value), type: self.thresholdCallbackType, isForPreview: true)
        self.label.text = "Treshold value : \(Int(slider.value))"
    }
    
}
