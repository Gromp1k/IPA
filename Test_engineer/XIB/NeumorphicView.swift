//
//  NeumorphicView.swift
//  Test_engineer
//
//  Created by Kacper on 05/02/2022.
//

import UIKit

class NeumorphicView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
     */
    @IBOutlet var contentView: UIView!
    
    override func draw(_ rect: CGRect) { }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
    }
    
    private func customInit(){
        backgroundColor = .clear
        Bundle.main.loadNibNamed("NeumorphicView", owner: self, options: nil)
        addSubview(contentView)
        setupContentView()
        setshadow()
    }

    private func setupContentView() {
        contentView.backgroundColor = .offWhite
        contentView.frame = self.bounds
        self.layer.cornerRadius = 21
        self.contentView.layer.cornerRadius = 21
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func setshadow() {
        self.layer.insertSublayer(darkShadow, at: 0)
        self.layer.insertSublayer(lightShadow, at: 0)
    }

    private lazy var darkShadow: CALayer = {
        let darkShadow = CALayer()
        darkShadow.frame = self.bounds
        darkShadow.cornerRadius = 11
       darkShadow.backgroundColor = UIColor.offWhite.cgColor
        darkShadow.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        darkShadow.shadowOffset = CGSize(width: 4, height: 4)
        darkShadow.shadowOpacity = 1
        darkShadow.shadowRadius = 11
        return darkShadow
    }()
    
    private lazy var lightShadow: CALayer = {
        let lightShadow = CALayer()
        lightShadow.frame = self.bounds
        lightShadow.cornerRadius = 11
        lightShadow.backgroundColor = UIColor.offWhite.cgColor
        lightShadow.shadowColor = UIColor.white.withAlphaComponent(0.9).cgColor
        lightShadow.shadowOffset = CGSize(width: -4, height: -4)
        lightShadow.shadowOpacity = 1
        lightShadow.shadowRadius = 11
        return lightShadow
    }()
    
  
}
extension UIColor {
static let offWhite =  UIColor.init(red: 210/255, green: 215/255, blue: 235/255, alpha: 1)
static let offWhite_ = UIColor.init(red: 210/255, green: 215/255, blue: 235/255, alpha: 1)
static let greenTea = UIColor.init(red: 196/255, green: 214/255, blue: 176/255, alpha: 1)
static let onyx = UIColor.init(red: 49/255, green: 54/255, blue: 56/255, alpha: 1)
static let indygo = UIColor.init(red: 44/255, green: 66/255, blue: 99/255, alpha: 1)
}
