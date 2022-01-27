//
//  HamburgerViewController.swift
//  Test_engineer
//
//  Created by Kacper on 19/01/2022.
//

import UIKit

protocol SideMenuViewControllerDelegate{
    func hideSideMenu() 
    func performAction(_ type:OperationTypes)
}

class SideMenuViewController: UIViewController {

    @IBOutlet weak var authorSectionView: UIView!
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbDescription: UILabel!
    
    var delegate: SideMenuViewControllerDelegate?
    var mainViewController: MainViewController?
    
    private var menuData: [ExpandingCellModel] = []
    private var isImageLoaded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuData = setupFullData()
        setupUI()
    }
}

extension SideMenuViewController: MainViewControllerDelegate,UITableViewDelegate, UITableViewDataSource{
    
    func isImageLoaded(_ isLoaded: Bool) {
        self.isImageLoaded = isLoaded
        print("MenuDelegate in Side menu: IsImageLoaded? \(self.isImageLoaded)")
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return  menuData.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      //  refreshMenu()
            if(indexPath.row == 0){
                let cell = tableView.dequeueReusableCell(withIdentifier: "ExpandingCell", for: indexPath) as! ExpandingCell
                    cell.title.text = menuData[indexPath.section].Label
                    cell.imgArrow.image = UIImage(systemName: menuData[indexPath.row].IsExpanded ? "arrow.up":"arrow.down")
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "OperationCell", for: indexPath) as! OperationCell
                cell.title.text = menuData[indexPath.section].Operations[indexPath.row-1].Label
                return cell
            }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // refreshMenu()
            let section = self.menuData[section]
            return section.IsExpanded ? section.Operations.count+1 : 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // refreshMenu()
        tableView.deselectRow(at: indexPath, animated: true)
        
        menuData[indexPath.section].IsExpanded = (indexPath.row == 0) ? !menuData[indexPath.section].IsExpanded : false
        tableView.reloadSections([indexPath.section], with: .none)
        
        if indexPath.row != 0 {
            self.delegate?.hideSideMenu()
            self.delegate?.performAction(menuData[indexPath.section].Operations[indexPath.row-1].Operation)
        }
    }
}



extension SideMenuViewController{    
    private func setupFullData() ->[ExpandingCellModel] {
        var array: [ExpandingCellModel] = []
        array.append(ExpandingCellModel(label: "File", operations: [
            OperationCellModel(label: "Open", operation: .presentController(.IMAGE_PICKER_VC)),
            OperationCellModel(label: "Save", operation: .modifyImage(.SAVE_IMAGE_TO_FILE)),
            OperationCellModel(label: "Close", operation: .modifyImage(.DELETE_PRESENTED_IMAGE))]
        ))
        
        array.append(ExpandingCellModel(label: "Convertions", operations: [
            OperationCellModel(label: "Grayscale", operation: .modifyImage(.GRAYSCALE)),
            OperationCellModel(label: "Binary", operation: .modifyImage(.BINARY)),
            OperationCellModel(label: "Negate", operation: .modifyImage(.NEGATE)),
            OperationCellModel(label: "Equalize", operation: .modifyImage(.EQUALIZE)),
            OperationCellModel(label: "Treshold", operation: .presentController(.TRESHOLD_VC(.STANDARD))),
            OperationCellModel(label: "Otsu treshold", operation: .presentController(.TRESHOLD_VC(.OTSU)))]
        ))
        
        array.append(ExpandingCellModel(label: "Blurs", operations: [
            OperationCellModel(label: "Blur", operation: .presentController(.KERNEL_VC)),
            OperationCellModel(label: "Gaussian Blur", operation: .presentController(.KERNEL_VC)),
            OperationCellModel(label: "Sobel blur", operation: .presentController(.KERNEL_VC)),
            OperationCellModel(label: "Laplasian blur", operation: .presentController(.KERNEL_VC)),
            OperationCellModel(label: "Canny blur", operation: .presentController(.KERNEL_VC)),
            OperationCellModel(label: "Otsu treshold", operation: .presentController(.KERNEL_VC))]
        ))
        
        array.append(ExpandingCellModel(label: "Bitwise Operation", operations: [
            OperationCellModel(label: "AND", operation: .presentController(.BITWISE_VC)),
            OperationCellModel(label: "OR", operation: .presentController(.BITWISE_VC)),
            OperationCellModel(label: "NOT", operation: .presentController(.BITWISE_VC)),
            OperationCellModel(label: "XOR", operation: .presentController(.BITWISE_VC))]
        ))
        
        array.append(ExpandingCellModel(label: "Morphology Operation", operations: [
            OperationCellModel(label: "Erode", operation: .modifyImage(.GRAYSCALE)),
            OperationCellModel(label: "Dilate", operation: .modifyImage(.BINARY)),
            OperationCellModel(label: "Open", operation: .modifyImage(.NEGATE)),
            OperationCellModel(label: "Close", operation: .modifyImage(.EQUALIZE)),
            OperationCellModel(label: "Skale", operation: .presentController(.IMAGE_PICKER_VC))]
        ))
        
        array.append(ExpandingCellModel(label: "Histogram", operations: [
            OperationCellModel(label: "Histogram", operation: .presentController(.HISTROGRAM_VC)),
            OperationCellModel(label: "Lookup table", operation: .presentController(.LOOKUP_TABLE_VC))]
        ))
        
        
        array.append(ExpandingCellModel(label: "Live Feed", operations: [
            OperationCellModel(label: "Face Detection", operation: .presentController(.FACE_DETECTION_VC)),
            OperationCellModel(label: "Cells Segmentation", operation: .presentController(.CELLS_DETECTION_VC))]
        ))
        return array
    }
    
    private func setupUI() ->Void{
        self.authorSectionView.layer.cornerRadius = 30 // raw: -30 | given value is -value at top and leading anchor at authorSectionView
        self.authorSectionView.clipsToBounds = true
        
        self.imgProfilePic.layer.cornerRadius = 45 // Circle Ratio NxN : Radius = N/2
        self.imgProfilePic.clipsToBounds = true
    }
}



