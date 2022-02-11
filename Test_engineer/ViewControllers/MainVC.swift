//
//  ViewController.swift
//  Test_engineer
//
//  Created by Kacper on 19/01/2022.
//

import UIKit
import PhotosUI

protocol MainViewControllerDelegate{ func isImageLoaded(_ isLoaded:Bool) }

class MainViewController: UIViewController {
   
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var sideMenuBackgroundView: UIView!
    @IBOutlet weak var sideMenuView: UIView!
    @IBOutlet weak var presentedImage: UIImageView!
    @IBOutlet weak var menuViewLeadingConstraint: NSLayoutConstraint!
    
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
    

    var delegate: MainViewControllerDelegate? /// delegate of MainViewContoller
    var sideMenuViewController: SideMenuViewController?
    var kernelDetailsViewController: KernelDetailsViewController?
    var normalizeDetailsViewController: HistogramNormalizeDeteilsVC?
    var tresholdDetaildVC : ThresholdDetailsViewController?
    
    
    private var isSideMenuPresented:Bool = false
    private var isBitwisePick = false /// case: callback from SideMenu to perform bitwise - flag if PHPicker updates or not PresentedImage.image
    ///
    private var bitwiseOperationType: OperationTypes.ControllerTypes.BitwiseTypes? /// pass callback from SideMenu with Bitwise's kind operation to perform
    private var blurOperationType: OperationTypes.ControllerTypes.BlurTypes? /// pass callback from SideMenu with Bitwise's kind operation to perform///
    
    private var imageModel = ImageModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    /// Segues between ViewControllers ( with Protocol-Delegate communication pattern)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MainVC_SideMenuVC_Segue" {
                    if let controller = segue.destination as? SideMenuViewController{
                self.sideMenuViewController = controller
                self.sideMenuViewController?.delegate = self
                self.delegate = self.sideMenuViewController
            }
        }
        else if segue.identifier == "MainVC_KernelDetailsViewController_Segue" {
            if let controller = segue.destination as? KernelDetailsViewController {
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
    
    ///Function to handle callback from SideMenuViewController - presenting controllers
    private func presentController(_ controller: OperationTypes.ControllerTypes){
        switch controller{
        
        case .SEGMENTATION_VC:
            guard let controller = storyboard?.instantiateViewController(withIdentifier: "LiveSegmentationViewController") as? LiveSegmentationViewController else{ return }
            present(controller,animated: true)
            break
            
        case .THRESHOLD_VC(let threshold):
            guard let controller = storyboard?.instantiateViewController(withIdentifier: "ThresholdDetailsViewController") as? ThresholdDetailsViewController else{ return }
            controller.delegate = self
            switch threshold {
            case .OTSU:
                controller.inputFlag = .THRESHOLD
            case .STANDARD:
                controller.inputFlag = .THRESHOLD
            case .ADAPTIVE:
                controller.inputFlag = .THRESHOLD_ADAPTIVE
            }
            present(controller,animated: true)
            
                break
            case .IMAGE_PICKER_VC:
                var config = PHPickerConfiguration()
                config.filter = .images
                config.selectionLimit = 1
                let picker = PHPickerViewController(configuration: config)
                picker.delegate = self
                present(picker, animated: true)
                break
            
            case .CAMERE_PHOTO_VC:
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.allowsEditing = false
                picker.delegate = self
                present(picker, animated: true)
                break
            
            case .FACE_DETECTION_VC:
                guard let controller = storyboard?.instantiateViewController(withIdentifier: "LiveFeedViewController") as? LiveFeedViewController else{ return }
                present(controller,animated: true)
                break
            case .KERNEL_VC(let blur):
                self.blurOperationType = blur
                guard let controller = storyboard?.instantiateViewController(withIdentifier: "KernelDetailsViewController") as? KernelDetailsViewController else{ return }
                controller.transitioningDelegate = self
                controller.modalPresentationStyle = .custom
                controller.delegate = self
                self.kernelDetailsViewController = controller
                present(controller,animated: true)
                break
            case .HISTROGRAM_VC:
                guard let controller = storyboard?.instantiateViewController(withIdentifier: "HistogramViewController") as? HistogramViewController else{ return }
                controller.data = imageModel.LookupTable
                present(controller,animated: true)
            case .BITWISE_VC(let bitwiseType):
            if(imageModel.IsImageLoaded){
                    self.isBitwisePick = true // true => image from PHPicker won't be set as presentedImage.image
                    self.bitwiseOperationType = bitwiseType
                    if bitwiseType == .NOR { imageModel.Image = OpenCVWrapper.bitwiseNOT(imageModel.Image) }
                    else{
                        var config = PHPickerConfiguration()
                        config.filter = .any(of: [.images,.livePhotos])
                        config.selectionLimit = 1
                        let picker = PHPickerViewController(configuration: config)
                        picker.delegate = self
                        self.present(picker, animated: true)
                    }
                }
                break
           
            case .NORMALIZE_HISTOGRAM_DETAILS_VC:
                guard let controller = storyboard?.instantiateViewController(withIdentifier: "HistogramNormalizeDeteilsVC") as?  HistogramNormalizeDeteilsVC else{ return }
                controller.transitioningDelegate = self
                controller.modalPresentationStyle = .custom
                controller.delegate = self
                present(controller,animated: true)
                break
            
            default:
                break
        }
    }
    
    private func updateImage(){
        self.presentedImage.image =  imageModel.Image
        DispatchQueue.global().async {
            self.imageModel.LookupTable = self.imageModel.Image.getImageLookupTable()
        }
    }
    
    ///Function to handle callback from SideMenuViewController - perform operation
    private func modifyImage(_ modification: OperationTypes.ModificationTypes){
           // guard let image = self.presentedImage.image else {return}
            if(imageModel.IsImageLoaded){
            switch modification{
                case .SAVE_IMAGE_TO_FILE:
                    let imageSaver = ImageSaver()
                    imageSaver.writeToPhotoAlbum(image:  imageModel.Image)
                    break
                case .DELETE_PRESENTED_IMAGE:
                    imageModel.Image = UIImage() //Set "image not presented" graphics
                    imageModel.IsImageLoaded = false // set flag to false
                    self.delegate?.isImageLoaded(false) // send state of flag to all listeners via delegate
                    break
                case .GRAYSCALE:  imageModel.Image = OpenCVWrapper.convertGrayscale( imageModel.Image)
                    break
                case .BINARY:  imageModel.Image = OpenCVWrapper.convertBinary( imageModel.Image)
                    break
                case .NEGATE:  imageModel.Image = OpenCVWrapper.convertNegative( imageModel.Image)
                    break
                case .EQUALIZE:  imageModel.Image = OpenCVWrapper.histEqualization( imageModel.Image)
                    break
                case .ERODE:  imageModel.Image = OpenCVWrapper.morphErode( imageModel.Image)
                    break
                case .DILATE:  imageModel.Image = OpenCVWrapper.morphDilate( imageModel.Image)
                    break
                case .OPEN:  imageModel.Image = OpenCVWrapper.morphOpen( imageModel.Image)
                    break
                case .CLOSE:  imageModel.Image = OpenCVWrapper.morphClose( imageModel.Image)
                    break
                case .SKELETONIZE:  imageModel.Image = OpenCVWrapper.morphSkale( imageModel.Image)
                    break
                case .WATERSHED:   imageModel.Image = OpenCVWrapper.watershed( imageModel.Image)
                    break
            }
                self.updateImage()
        }
    }
}

extension MainViewController : ThresholdDetailsViewControllerDelegate {
    func thresholdCallback(threshold: Int, type: ThresholdTypeCallback) {
        if self.imageModel.IsImageLoaded {
            switch type {
            case .THRESHOLD: imageModel.Image = OpenCVWrapper.thresholding( imageModel.Image, tresholds: Int32(threshold))
                break
            case .THRESHOLD_ADAPTIVE: imageModel.Image = OpenCVWrapper.thresholdingAdaptive(imageModel.Image, thresholds: Int32(threshold))
                break
            case .THRESHOLD_OTSU: imageModel.Image = OpenCVWrapper.thresholdingOtsu(imageModel.Image, thresholds: Int32(threshold))
                break
            }
            self.updateImage()
        }
    }
}


extension MainViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else{ return }
        self.imageModel.Image = image
        self.presentedImage.image = image
    }


}

extension MainViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension MainViewController:  PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
       
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self){
            let previousImage = imageModel.Image
            itemProvider.loadObject(ofClass: UIImage.self){ [weak self] image, error in
                DispatchQueue.main.async { [self] in
                    guard let self = self, let image = image as? UIImage, self.imageModel.Image == previousImage else {return}
                    if(self.isBitwisePick){
                        switch self.bitwiseOperationType{
                        case .AND: self.imageModel.Image = OpenCVWrapper.bitwiseAND(self.imageModel.Image, with: image); break
                        case .XOR: self.imageModel.Image = OpenCVWrapper.bitwiseXOR(self.imageModel.Image, with: image); break
                        case .OR: self.imageModel.Image = OpenCVWrapper.bitwiseOR(self.imageModel.Image, with: image); break
                            /// .NOR handled - doesn't need extra image paramater, bases on presentedImage.image
                        default: break
                        }
                    }
                    else{
                        self.imageModel.Image = image
                        self.imageModel.IsImageLoaded = true
                        self.delegate?.isImageLoaded(true)
                    }
                    DispatchQueue.global().async {self.imageModel.LookupTable =  self.imageModel.Image.getImageLookupTable() }
                    self.presentedImage.image = self.imageModel.Image
                    self.isBitwisePick = false // set flag as default
                }
            }
        }
    }
}

/// Callback from SideMenuViewController
extension MainViewController: SideMenuViewControllerDelegate{
    func hideSideMenu() { _hideMenu() }
    func performAction(_ type: OperationTypes) {
       // print("SideMenuDelegate in MainVC:")
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

/// Callback from KernelDetailsViewController
extension MainViewController: KernelDetailsViewControllerDelegate{
    ///Get Kernel Size +(Border type)? for Blur operations
    func getKernelDetails(kernel size: Int){
        if( imageModel.IsImageLoaded){
            switch self.blurOperationType{
            case .BLUR:  imageModel.Image = OpenCVWrapper.blur(imageModel.Image, withKernel: Int32(size));break
                case .CANNY:  imageModel.Image = OpenCVWrapper.blurCanny( imageModel.Image, withKernel: Int32(size));break
                case .LAPLASSIAN: imageModel.Image = OpenCVWrapper.blurLaplacian( imageModel.Image, withKernel: Int32(size));break
                case .GAUSSIAN:  imageModel.Image = OpenCVWrapper.blurGaussian(imageModel.Image, withKernel: Int32(size));break
                case .SOBEL: imageModel.Image = OpenCVWrapper.blurSobel(imageModel.Image, withKernel: Int32(size)) ;break
                default: break
            }
            self.updateImage()
        }
       
    }
}

extension MainViewController:HistogramNormalizeDeteilsViewControllerDelegate{
    func normalizeCallback(minVal: Int32, maxVal: Int32) {
        print(minVal, maxVal)
        if self.imageModel.IsImageLoaded {
            imageModel.Image = OpenCVWrapper.histNormalize(self.imageModel.Image, min: minVal, max: maxVal)
            self.updateImage()
        }
    }
}
