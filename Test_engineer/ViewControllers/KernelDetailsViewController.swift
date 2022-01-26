//
//  KernelDetailsViewController.swift
//  Test_engineer
//
//  Created by Kacper on 24/01/2022.
//

import Foundation
import UIKit


enum KernelType{
    case c1,c2,c3,c4
}

protocol KernelDetailsViewControllerDelegate{
    func getKernelDetails(kernel size: Int,kernel type: KernelType)
}


class KernelDetailsViewController: UIViewController{
    
    @IBOutlet weak var kernelTypePicker: UIPickerView!
    @IBOutlet weak var kernelSizeSegmentedControl: UISegmentedControl!
    
    var isPointOriginSet: Bool = false
    var pointOrigin: CGPoint?
    
    private var pickerData: [String] = [String]()
    var delegate: KernelDetailsViewControllerDelegate?
    
    override func viewDidLoad() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
       
        
        self.pickerData = ["item1","item2","item3","item4","item5"]
        
        
    }
    
    override func viewDidLayoutSubviews() {
        if !self.isPointOriginSet{
            self.isPointOriginSet = true
            self.pointOrigin = self.view.frame.origin
            self.view.roundCorners([.allCorners], radius: 30)
        }
    }
    
    
    @IBAction func buttonSendData(_ sender: Any) {
        self.delegate?.getKernelDetails(kernel: 1, kernel: .c1)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func panGestureRecognizerAction(sender: UIPanGestureRecognizer){
        let transition = sender.translation(in: view)
        guard transition.y >= 0 else { return }
        view.frame.origin = CGPoint(x:0, y: self.pointOrigin!.y + transition.y)
        if sender.state == .ended{
            let dragVelocity = sender.velocity(in: view)
            
            if dragVelocity.y >= 1300{ self.dismiss(animated: true, completion: nil) }
            else{
                UIView.animate(withDuration: 0.3){
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x:0, y:400)
                }
            }
        }
    }
}
extension KernelDetailsViewController: UIPickerViewDelegate {

    override func didReceiveMemoryWarning(){}
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 130, height: 80))
        label.text = self.pickerData[row]
        label.sizeToFit()
        return label
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerData[row]
    }
}


extension KernelDetailsViewController: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerData.count
    }
}
