//
//  ViewController.swift
//  Test_engineer
//
//  Created by Kacper on 19/01/2022.
//

import UIKit
import PhotosUI


protocol MainViewControllerDelegate{
    func isImageLoaded(_ isLoaded:Bool)
}

class MainViewController: UIViewController {
   
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var sideMenuBackgroundView: UIView!
    @IBOutlet weak var sideMenuView: UIView!
    @IBOutlet weak var presentedImage: UIImageView!
    @IBOutlet weak var menuViewLeadingConstraint: NSLayoutConstraint!
    
    var delegate: MainViewControllerDelegate?
    var sideMenuViewController: SideMenuViewController?
    var kernelDetailsViewController: KernelDetailsViewController?
    
    private var isSideMenuPresented:Bool = false
    private var isImageLoaded:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "MainVC_SideMenuVC_Segue")
        {
            if let controller = segue.destination as? SideMenuViewController
            {
                self.sideMenuViewController = controller
                self.sideMenuViewController?.delegate = self
                self.delegate = self.sideMenuViewController
            }
        }
        else if (segue.identifier == "MainVC_KernelDetailsViewController_Segue")
        {
            if let controller = segue.destination as? KernelDetailsViewController
            {

                self.kernelDetailsViewController = controller
                self.kernelDetailsViewController?.delegate = self
                self.kernelDetailsViewController?.transitioningDelegate = self
                self.kernelDetailsViewController?.modalPresentationStyle = .custom
            }
        }
    }
    
    private func setupUI(){
        self.sideMenuBackgroundView.isHidden = true
        self.headerView.layer.cornerRadius = 40
        self.headerView.clipsToBounds = true
    }
    
    
    @IBAction func showMenu(_ sender: Any) {
        self.sideMenuBackgroundView.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.menuViewLeadingConstraint.constant = 10
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.sideMenuBackgroundView.alpha = 0.65
            self.sideMenuBackgroundView.isHidden = false
            UIView.animate(withDuration: 0.1) {
                self.menuViewLeadingConstraint.constant = 0
                self.view.layoutIfNeeded()
            } completion: { _ in
                self.isSideMenuPresented = true
            }
        }
    }
    
    @IBAction func hideMenu(_ sender: Any) { self._hideMenu() }
   
    private func _hideMenu(){
        UIView.animate(withDuration: 0.25) {
            self.menuViewLeadingConstraint.constant = 10
            self.view.layoutIfNeeded()
        } completion: { (status) in
            self.sideMenuBackgroundView.alpha = 0.0
            UIView.animate(withDuration: 0.1) {
                self.menuViewLeadingConstraint.constant = -280
                self.view.layoutIfNeeded()
            } completion: { (status) in
                self.sideMenuBackgroundView.isHidden = true
                self.isSideMenuPresented = false
            }
        }
    }
    
    
    private func presentController(_ controller: OperationType.ControllerType){
        print("-Controller: \(controller)")
        switch controller{
            case .imagePickerVC:
                var config = PHPickerConfiguration()
                config.filter = .images
                config.selectionLimit = 1
            
                let picker = PHPickerViewController(configuration: config)
                picker.delegate = self
                present(picker, animated: true)
                break
            
        case .faceDetectionVC:
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "LiveFeedViewController") as? LiveFeedViewController else{ return }
            present(vc,animated: true)
            
        case .cellDetectionVC:
            guard let controller = storyboard?.instantiateViewController(withIdentifier: "KernelDetailsViewController") as? KernelDetailsViewController else{ return }
            controller.transitioningDelegate = self
            controller.modalPresentationStyle = .custom
            controller.delegate = self
            self.kernelDetailsViewController = controller
            present(controller,animated: true) 
            break
            default:
                break
        }
    }
    
    private func modifyImage(_ modification: OperationType.ModificationType){
        print("-Modification: \(modification)")
        switch modification{
        case .saveImage:
            if(self.isImageLoaded){
                guard let imageToSave = self.presentedImage.image else {return}
                let imageSaver = ImageSaver()
                imageSaver.writeToPhotoAlbum(image: imageToSave)
            }
            break
        default:
            break
        }
    }
}

//TEST

//END OF TEST

extension MainViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension MainViewController:  PHPickerViewControllerDelegate{
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self){
            let previousImage = self.presentedImage.image
            itemProvider.loadObject(ofClass: UIImage.self){ [weak self] image, error in
                DispatchQueue.main.async {
                    guard let self = self, let image = image as? UIImage, self.presentedImage.image == previousImage else {
                        return
                    }
                    self.presentedImage.image = image
                }
            }
            self.isImageLoaded = true;
            self.delegate?.isImageLoaded(true)
        }
    }
}
extension MainViewController: SideMenuViewControllerDelegate{

    func hideSideMenu() { _hideMenu() }
    
    func performAction(_ type: OperationType) {
        print("SideMenuDelegate in MainVC:")
        switch type{
        case .presentController(let controller):
            self.presentController(controller)
            break
        case .modifyImage(let modification):
            self.modifyImage(modification)
            break
        }
    }
}


extension MainViewController: KernelDetailsViewControllerDelegate{
    func getKernelDetails(kernel size: Int, kernel type: KernelType) {
        print("callback baby! \(size) \(type)")
    }
    
    
}
