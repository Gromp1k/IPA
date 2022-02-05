//
//  KernelDetailsViewController.swift
//  Test_engineer
//
//  Created by Kacper on 24/01/2022.
//

import Foundation
import UIKit



protocol KernelDetailsViewControllerDelegate{
    func getKernelDetails(kernel size: Int)
}

class KernelDetailsViewController: UIViewController{
    
    @IBOutlet weak var kernelSizeSegmentedControl: UISegmentedControl!
    
    var isPointOriginSet: Bool = false
    var pointOrigin: CGPoint?
    
    private var kernelIndex: Int = 0
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    var delegate: KernelDetailsViewControllerDelegate?
    
    override func viewDidLoad() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
    }
    
    override func viewDidLayoutSubviews() {
        if !self.isPointOriginSet{
            self.isPointOriginSet = true
            self.pointOrigin = self.view.frame.origin
            self.view.roundCorners([.allCorners], radius: 30)
        }
    }
    
    @IBAction func buttonSendData(_ sender: Any) {
        // indexes from 0,1 or 2, kernel size is 3,5 or 7
        self.delegate?.getKernelDetails(kernel: ((self.segment.selectedSegmentIndex << 1) + 3) );
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
