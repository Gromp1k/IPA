//
//  HistogramViewController.swift
//  Test_engineer
//
//  Created by Kacper on 31/01/2022.
//
import UIKit
class HistogramViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    private var chart_axes: ChartAxes!
    
    @IBOutlet weak var maxYlabel: UILabel!
    
    var data: [UIColor: [Int]] = [:]
    override func viewDidLoad() {
        view.backgroundColor = UIColor.offWhite
        super.viewDidLoad()
        self.setupUI()
        
        if let result = data.max(by: {$0.value.max() ?? 0 < $1.value.max() ?? 0}),
        let maxValue = result.value.max() {
            self.maxYlabel.text = String(maxValue);
            if maxValue == 0 {
                self.maxYlabel.isHidden = true;
            }
        }
        
        //draw grid
        let chart_grid = ChartGrid(frame: containerView.frame)
        chart_grid.backgroundColor =  UIColor.clear.withAlphaComponent(0)
        containerView.addSubview(chart_grid)
        chart_grid.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chart_grid.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            chart_grid.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            chart_grid.topAnchor.constraint(equalTo: containerView.topAnchor),
            chart_grid.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        //draw data
        for (color, data) in data{
            let  bars = ChartChannelBars(frame: containerView.frame, color: color, data: data )
            bars.backgroundColor =  UIColor.clear.withAlphaComponent(0)
            containerView.addSubview(bars)
            bars.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                bars.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                bars.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                bars.topAnchor.constraint(equalTo: containerView.topAnchor),
                bars.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
        }
        //draw axes
        let chart_axes = ChartAxes(frame: containerView.frame)
        chart_axes.backgroundColor =  UIColor.clear.withAlphaComponent(0)
        containerView.addSubview(chart_axes)
        chart_axes.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
          chart_axes.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
          chart_axes.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
          chart_axes.topAnchor.constraint(equalTo: containerView.topAnchor),
          chart_axes.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    private func setupUI(){
        view.backgroundColor  = .offWhite
    }
}


extension HistogramViewController {
    ///Axes OX and Oy
    private class ChartAxes : UIView{
        override func draw(_ rect: CGRect) {
            do{
                let start = CGPoint(x:rect.origin.x,y:rect.origin.y)
                let joint = CGPoint(x:0,y:rect.height)
                let end = CGPoint(x:rect.width,y:rect.height)
                let axes = UIBezierPath()
                axes.move(to: start)
                axes.addLine(to: joint)
                axes.addLine(to: end)
                axes.lineWidth = 5.0
                UIColor.black.setStroke()
                axes.stroke()
            }
        }
    }

    /// Vertical and horizontal grid
    private class ChartGrid : UIView{
        override func draw(_ rect: CGRect) {
                do{
                    let contour = UIBezierPath()
                    let pattern: [CGFloat] = [10.0, 5.0]
                    [50,100,150,200,255].forEach{ v in
                        let x = ( ( (CGFloat(v) )/255.0) * rect.width )
                        contour.move(to: CGPoint(x: v == 255 ? x : x - 0.5 , y: rect.height))
                        contour.addLine(to: CGPoint(x: v == 255 ? x : x - 0.5 , y: 0))
                    }
                    (0...5).forEach{ h in
                        let y = ( ( CGFloat(h) / 5 ) * rect.height  )
                        contour.move(to: CGPoint(x: 0 , y: y))
                        contour.addLine(to: CGPoint(x: rect.width, y: y))
                    }
                    contour.setLineDash(pattern, count: pattern.count, phase: 0.0)
                    contour.lineWidth = 1.0
                    UIColor.black.withAlphaComponent(0.4).setStroke()
                    contour.stroke()
            }
        }
    }
    
    ///Transofms data to graphics representation
    private class ChartChannelBars : UIView{
        private var color: UIColor = UIColor() // color of given channel
        private var data: [Int] = [] // channel's data
        private var maxValue: Int = 0 // max value at channel's data
     
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) { super.init(frame: frame) }
        
        public convenience init(frame: CGRect ,color: UIColor, data:[Int]) {
            self.init(frame: frame)
            self.color = color
            self.data = data
            self.maxValue = data.max() ?? 0
        }
        
        override func draw(_ rect: CGRect) {
            let oy_offset = 2.5; // axes offset
            let ox_offset = 2.5
            //unit = [ 256 indexes ] * ( [ units per bar ] + [ units per offset ] ) - [ units per offset ( for last bar) ]
            let unit = CGFloat(0.389); // bar is 3 units, offset betweeen bars is 1
            for (index, value) in data.enumerated() {
                let x = oy_offset + CGFloat(index * 4) * unit // FIX ME - padding bottom
                let y = ( ( rect.height - (ox_offset) ) - ( (CGFloat(value) / CGFloat(self.maxValue)) * (rect.height - ox_offset) )  ) + ox_offset
                let bar = CAShapeLayer()
                let barShape =  CGRect(x: x, y:  y - ox_offset, width: 3.0 * unit, height: rect.height - y)
                bar.path = UIBezierPath(rect: barShape).cgPath
                bar.fillColor = self.color.withAlphaComponent(0.7).cgColor
                self.layer.addSublayer(bar)
            }
        }
    }
}
