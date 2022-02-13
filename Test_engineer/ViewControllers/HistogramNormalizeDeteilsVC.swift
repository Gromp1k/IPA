//
//  HistogramNormalizeDeteilsVC.swift
//  Test_engineer
//
//  Created by Kacper on 07/02/2022.
//

import UIKit
protocol HistogramNormalizeDeteilsViewControllerDelegate{
    func normalizeCallback(minVal: Int32, maxVal: Int32, isPreview:Bool )
    func normalizeCallbackCancel()
}

class HistogramNormalizeDeteilsVC: UIViewController {

    private var CANCEL_FLAG: Bool = false
    @IBOutlet weak var sliderMin: UISlider!
    @IBOutlet weak var sliderMax: UISlider!
    
    @IBOutlet weak var labelMin: UILabel!
    @IBOutlet weak var labelMax: UILabel!
    
    @IBOutlet weak var buttonSend: UIButton!
    var delegate: HistogramNormalizeDeteilsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        // Do any additional setup after loading the view.
    }
    
    deinit{
        if self.CANCEL_FLAG {
            self.delegate?.normalizeCallbackCancel()
        }
    }
    
    @IBAction func sendAction(_ sender: Any) {
        delegate?.normalizeCallback(minVal: Int32(sliderMin.value), maxVal: Int32(sliderMax.value), isPreview: false)
        self.CANCEL_FLAG = false
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func minChanged(_ sender: Any) {
        if sliderMin.value > sliderMax.value { sliderMax.value =  sliderMin.value }
        updateLabels()
    }
    
    @IBAction func maxChanged(_ sender: Any) {
        if sliderMax.value < sliderMin.value { sliderMin.value =  sliderMax.value }
        updateLabels()
    }
    
    private func updateLabels(){
        self.labelMin.text = String(Int(self.sliderMin.value))
        self.labelMax.text = String(Int(self.sliderMax.value))
        self.CANCEL_FLAG = true
        delegate?.normalizeCallback(minVal: Int32(sliderMin.value), maxVal: Int32(sliderMax.value),isPreview: true)
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
