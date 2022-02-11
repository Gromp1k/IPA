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
    func thresholdCallback(threshold: Int, type: ThresholdTypeCallback)
}

class ThresholdDetailsViewController: UIViewController {
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var siderLabel: UILabel!
    var delegate: ThresholdDetailsViewControllerDelegate?
    var inputFlag: ThresholdTypeCallback = .THRESHOLD
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func sendData(_ sender: Any) {
        delegate?.thresholdCallback(threshold: Int(slider.value), type: self.inputFlag)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
