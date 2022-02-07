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
        self.layer.cornerRadius = 16
        self.contentView.layer.cornerRadius = 16
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func setshadow() {
        self.layer.insertSublayer(darkShadow, at: 0)
        self.layer.insertSublayer(lightShadow, at: 0)
    }

    private lazy var darkShadow: CALayer = {
        let darkShadow = CALayer()
        darkShadow.frame = self.bounds
        darkShadow.cornerRadius = 16
       darkShadow.backgroundColor = UIColor.offWhite.cgColor
        darkShadow.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        darkShadow.shadowOffset = CGSize(width: 6, height: 10)
        darkShadow.shadowOpacity = 1
        darkShadow.shadowRadius = 15
        return darkShadow
    }()
    
    private lazy var lightShadow: CALayer = {
        let lightShadow = CALayer()
        lightShadow.frame = self.bounds
        lightShadow.cornerRadius = 15
        lightShadow.backgroundColor = UIColor.offWhite.cgColor
        lightShadow.shadowColor = UIColor.white.withAlphaComponent(0.9).cgColor
        lightShadow.shadowOffset = CGSize(width: -5, height: -5)
        lightShadow.shadowOpacity = 1
        lightShadow.shadowRadius = 8
        return lightShadow
    }()
    
  
}
