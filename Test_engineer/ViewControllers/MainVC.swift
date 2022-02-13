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

    private var previewImage = UIImage()
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
    private var BITWISE_PICK_FLAG = false /// case: callback from SideMenu to perform bitwise - flag if PHPicker updates or not PresentedImage.image
    ///
    private var BITWISE_TYPE_FLAG: OperationTypes.ControllerTypes.BitwiseTypes? /// pass callback from SideMenu with Bitwise's kind operation to perform
    private var BLUR_TYPE_FLAG: OperationTypes.ControllerTypes.BlurTypes? /// pass callback from SideMenu with Bitwise's kind operation to perform///
    
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
                controller.thresholdCallbackType = .THRESHOLD_OTSU
            case .STANDARD:
                controller.thresholdCallbackType = .THRESHOLD
            case .ADAPTIVE:
                controller.thresholdCallbackType = .THRESHOLD_ADAPTIVE
            }
            controller.transitioningDelegate = self
            controller.modalPresentationStyle = .custom
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
                self.BLUR_TYPE_FLAG = blur
                guard let controller = storyboard?.instantiateViewController(withIdentifier: "KernelDetailsViewController") as? KernelDetailsViewController else{ return }
                controller.transitioningDelegate = self
                controller.modalPresentationStyle = .custom
                controller.delegate = self
                present(controller,animated: true)
                break
            
            case .HISTROGRAM_VC:
                guard let controller = storyboard?.instantiateViewController(withIdentifier: "HistogramViewController") as? HistogramViewController else{ return }
                controller.data = imageModel.LookupTable
                present(controller,animated: true)
            
            case .BITWISE_VC(let bitwiseType):
            if(imageModel.IMAGE_LOADED_FLAG){
                    self.BITWISE_PICK_FLAG = true // true => image from PHPicker won't be set as presentedImage.image
                    self.BITWISE_TYPE_FLAG = bitwiseType
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
    
    private func updatePreviewImage(){
        self.presentedImage.image =  self.previewImage
    }
    
    private func updateModelImage(){
        self.presentedImage.image =  imageModel.Image
        DispatchQueue.global().async {
            self.imageModel.LookupTable = self.imageModel.Image.getImageLookupTable()
        }
    }
    
    ///Function to handle callback from SideMenuViewController - perform operation
    private func modifyImage(_ modification: OperationTypes.ModificationTypes){
     
           // guard let image = self.presentedImage.image else {return}
            if(imageModel.IMAGE_LOADED_FLAG){
            switch modification{
                case .SAVE_IMAGE_TO_FILE:
                    let imageSaver = ImageSaver()
                    imageSaver.writeToPhotoAlbum(image:  imageModel.Image)
                    break
                case .DELETE_PRESENTED_IMAGE:
                    self.presentedImage.image = UIImage(systemName:"square.stack.3d.down.right")!.withTintColor(.indygo)
                    self.imageModel.Image = UIImage()
                    self.imageModel.IMAGE_LOADED_FLAG = false
                break
                    
                case .GRAYSCALE:  imageModel.Image = OpenCVWrapper.convertGrayscale( imageModel.Image)
                    
                case .BINARY:  imageModel.Image = OpenCVWrapper.convertBinary( imageModel.Image)
                    
                case .NEGATE:  imageModel.Image = OpenCVWrapper.convertNegative( imageModel.Image)
                    
                case .EQUALIZE:  imageModel.Image = OpenCVWrapper.histEqualization( imageModel.Image)
                   
                case .ERODE:  imageModel.Image = OpenCVWrapper.morphErode( imageModel.Image)
                    
                case .DILATE:  imageModel.Image = OpenCVWrapper.morphDilate( imageModel.Image)
                    
                case .OPEN:  imageModel.Image = OpenCVWrapper.morphOpen( imageModel.Image)
                   
                case .CLOSE:  imageModel.Image = OpenCVWrapper.morphClose( imageModel.Image)
                    
                case .SKELETONIZE:  imageModel.Image = OpenCVWrapper.morphSkale( imageModel.Image)
                  
                case .WATERSHED:   imageModel.Image = OpenCVWrapper.watershed( imageModel.Image)
            }
        }
        if imageModel.IMAGE_LOADED_FLAG{ self.updateModelImage() }
    }
}

extension MainViewController : ThresholdDetailsViewControllerDelegate {
    func cancelOperation() { self.updateModelImage() }
    
    func thresholdCallback(threshold: Int, type: ThresholdTypeCallback, isForPreview: Bool) {
        if self.imageModel.IMAGE_LOADED_FLAG {
            switch type {
                case .THRESHOLD:
                    if isForPreview {
                        self.previewImage = OpenCVWrapper.thresholding( imageModel.Image, tresholds: Int32(threshold))
                        self.updatePreviewImage()
                    }
                    else{
                        imageModel.Image = OpenCVWrapper.thresholding( imageModel.Image, tresholds: Int32(threshold))
                        self.updateModelImage()
                    }
                   
                case .THRESHOLD_ADAPTIVE:
                    if isForPreview{
                        self.previewImage = OpenCVWrapper.thresholdingAdaptive(imageModel.Image, thresholds: Int32(threshold))
                        self.updatePreviewImage()
                    }
                    else{
                        imageModel.Image = OpenCVWrapper.thresholdingAdaptive(imageModel.Image, thresholds: Int32(threshold))
                        self.updateModelImage()
                    }
                    
                case .THRESHOLD_OTSU:
                    if isForPreview{
                        self.previewImage = OpenCVWrapper.thresholdingAdaptive(imageModel.Image, thresholds: Int32(threshold))
                        self.updatePreviewImage()
                    }
                    else{
                        imageModel.Image = OpenCVWrapper.thresholdingOtsu(imageModel.Image, thresholds: Int32(threshold))
                        self.updateModelImage()
                    }
                
            }
            
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
                    if(self.BITWISE_PICK_FLAG){
                        switch self.BITWISE_TYPE_FLAG{
                        case .AND: self.imageModel.Image = OpenCVWrapper.bitwiseAND(self.imageModel.Image, with: image); break
                        case .XOR: self.imageModel.Image = OpenCVWrapper.bitwiseXOR(self.imageModel.Image, with: image); break
                        case .OR: self.imageModel.Image = OpenCVWrapper.bitwiseOR(self.imageModel.Image, with: image); break
                            /// .NOR handled - doesn't need extra image paramater, bases on presentedImage.image
                        default: break
                        }
                    }
                    else{
                        self.imageModel.Image = image
                        self.imageModel.IMAGE_LOADED_FLAG = true
                        self.delegate?.isImageLoaded(true)
                    }
                    DispatchQueue.global().async {self.imageModel.LookupTable =  self.imageModel.Image.getImageLookupTable() }
                    self.presentedImage.image = self.imageModel.Image
                    self.BITWISE_PICK_FLAG = false // set flag as default
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
    func getKernelDetailsCancel() { self.updateModelImage() }
    
    func getKernelDetails(kernel size: Int, isPreview: Bool) {
        if( imageModel.IMAGE_LOADED_FLAG){
            switch self.BLUR_TYPE_FLAG{
                case .BLUR:
                    if isPreview{
                        self.previewImage = OpenCVWrapper.blur(imageModel.Image, withKernel: Int32(size))
                        self.updatePreviewImage()
                    }
                    else{
                        imageModel.Image = OpenCVWrapper.blur(imageModel.Image, withKernel: Int32(size))
                        self.updateModelImage()
                    }
                break
                
                case .CANNY:
                    if isPreview{
                        self.previewImage = OpenCVWrapper.blurCanny( imageModel.Image, withKernel: Int32(size))
                        self.updatePreviewImage()
                    }
                    else{
                        imageModel.Image =  OpenCVWrapper.blurCanny( imageModel.Image, withKernel: Int32(size))
                        self.updateModelImage()
                    }
                break
                
                case .LAPLASSIAN:
                    if isPreview{
                        self.previewImage = OpenCVWrapper.blurLaplacian( imageModel.Image, withKernel: Int32(size))
                        self.updatePreviewImage()
                    }
                    else{
                        imageModel.Image =  OpenCVWrapper.blurLaplacian( imageModel.Image, withKernel: Int32(size))
                        self.updateModelImage()
                    }
                break
                
                case .GAUSSIAN:
                    if isPreview{
                        self.previewImage = OpenCVWrapper.blurGaussian(imageModel.Image, withKernel: Int32(size))
                        self.updatePreviewImage()
                    }
                    else{
                        imageModel.Image =  OpenCVWrapper.blurGaussian(imageModel.Image, withKernel: Int32(size))
                        self.updateModelImage()
                    }
                break
                
                case .SOBEL:
                    if isPreview{
                        self.previewImage = OpenCVWrapper.blurSobel(imageModel.Image, withKernel: Int32(size))
                        self.updatePreviewImage()
                    }
                    else{
                        imageModel.Image =  OpenCVWrapper.blurSobel(imageModel.Image, withKernel: Int32(size)) 
                        self.updateModelImage()
                    }
                break
                default: break
            }
        }
    }
}

extension MainViewController: HistogramNormalizeDeteilsViewControllerDelegate{
    func normalizeCallbackCancel(){ self.updateModelImage() }
    
    func normalizeCallback(minVal: Int32, maxVal: Int32, isPreview: Bool) {
        if self.imageModel.IMAGE_LOADED_FLAG {
            if isPreview {
                self.previewImage = OpenCVWrapper.histNormalize(self.imageModel.Image, min: minVal, max: maxVal)
                self.updatePreviewImage()
            }
            else {
                imageModel.Image = OpenCVWrapper.histNormalize(self.imageModel.Image, min: minVal, max: maxVal)
                self.updateModelImage()
            }
        }
    }
}
