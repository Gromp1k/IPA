//
//  LiveCellsViewController.swift
//  Test_engineer
//
//  Created by Kacper on 11/02/2022.
//

import UIKit
import AVFoundation
// Inherit AVCaptureVideoDataOutputSampleBufferDelegate to implement buffer processing delegate
class LiveSegmentationViewController: UIViewController {
   
    
    private var modifiedView = UIImageView()
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private var faceLayers: [CAShapeLayer] = []

    override func viewDidLoad() {
        modifiedView.frame = self.view.frame
        self.view.addSubview(self.modifiedView)
        super.viewDidLoad()
        setupCamera()
        captureSession.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer.frame = CGRect(x: 20, y: 100, width: 374, height: 219)
    }
    
    private func setupCamera() {
        // detect camera object from the divice
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
        if let device = deviceDiscoverySession.devices.first {
            if let deviceInput = try? AVCaptureDeviceInput(device: device) {
                if captureSession.canAddInput(deviceInput) {
                    captureSession.addInput(deviceInput)
                    setupPreview()
                }
            }
        }
    }
    
    // add preview layer and details to the view
    private func setupPreview() {


        //TO-DO: Fix PxlFormat for ImageModel UIImage!!! 17/01
        self.videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]

        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera queue"))
        self.captureSession.addOutput(self.videoDataOutput)
        
        let videoConnection = self.videoDataOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
    }
}

extension LiveSegmentationViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    //method called every received frame
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        //check if buffer exists
       // guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        
        let image:UIImage = self.captureImage(sampleBuffer)
        
        DispatchQueue.main.async {
            self.modifiedView.image = image
        }
    }
    // Create UIImage from sampleBuffer
    func captureImage(_ sampleBuffer:CMSampleBuffer) -> UIImage {

        // Fetch an image
        let imageBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        //　Lock the page address
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0) )
            
        // Image data information
        let baseAddress: UnsafeMutableRawPointer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)!
            
        let bytesPerRow: Int = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width: Int = CVPixelBufferGetWidth(imageBuffer)
        let height: Int = CVPixelBufferGetHeight(imageBuffer)
        let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue|CGBitmapInfo.byteOrder32Little.rawValue as UInt32

        //RGB color space
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let newContext: CGContext = CGContext(data: baseAddress,                                      width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)!
        // Quartz Image
        let imageRef: CGImage = newContext.makeImage()!
            
        // UIImage
        let cameraImage: UIImage = UIImage(cgImage: imageRef)
        
        // Sobel edge fileter
        let resultImage: UIImage = OpenCVWrapper.watershed(cameraImage)

        return resultImage

    }
    
}
















/*
 var input:AVCaptureDeviceInput! // Video input
 var output:AVCaptureVideoDataOutput! // Video output
 var cameraView:UIImageView! // View for preview
 var session:AVCaptureSession! // session
 var camera:AVCaptureDevice! // Camera device
 override func viewDidLoad() {
     super.viewDidLoad()
     // Do any additional setup after loading the view, typically from a nib.
 }

 override func didReceiveMemoryWarning() {
     super.didReceiveMemoryWarning()
     // Dispose of any resources that can be recreated.
 }
 
 //　View initialization
 override func viewWillAppear(_ animated: Bool) {
     
     // Fit the preview image to display
     let screenWidth = UIScreen.main.bounds.size.width;
     let screenHeight = UIScreen.main.bounds.size.height;
     cameraView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: screenHeight))
     
     // Detect the back camera
     // In case of selfie, use AVCaptureDevicePosition.Front
     session = AVCaptureSession()
     for captureDevice in AVCaptureDevice.devices() {
         if (captureDevice as AnyObject).position == AVCaptureDevice.Position.back {
             camera = captureDevice as? AVCaptureDevice
             break
         }
     }
     
     // Fetch an image
     do {
         input = try AVCaptureDeviceInput(device: camera) as AVCaptureDeviceInput
     } catch let error as NSError {
         print(error)
     }
     
     if( session.canAddInput(input)) {
         session.addInput(input)
     }
     
     // Put the image to image processing
     output = AVCaptureVideoDataOutput()
     output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String : Int(kCVPixelFormatType_32BGRA)]
     
     // Delegate
     let queue: DispatchQueue = DispatchQueue(label: "videoqueue" , attributes: [])
     output.setSampleBufferDelegate(self, queue: queue)
     
     // Discard frames which have too long delay
     output.alwaysDiscardsLateVideoFrames = true
     
     // Put the output to session
     if session.canAddOutput(output) {
         session.addOutput(output)
     }
     
     // Fix the camera rotation
     for connection in output.connections {
         if let conn = connection as? AVCaptureConnection {
             if conn.isVideoOrientationSupported {
                 conn.videoOrientation = AVCaptureVideoOrientation.portrait
             }
         }
     }
     
     self.view.addSubview(cameraView)
     
     session.startRunning()
 }

 // Update view
 func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
         
     let image:UIImage = self.captureImage(sampleBuffer)
     
     DispatchQueue.main.async {
         self.cameraView.image = image
     }
 }
 
 // Create UIImage from sampleBuffer
 func captureImage(_ sampleBuffer:CMSampleBuffer) -> UIImage {

     // Fetch an image
     let imageBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
     
     //　Lock the page address
     CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0) )
         
     // Image data information
     let baseAddress: UnsafeMutableRawPointer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)!
         
     let bytesPerRow: Int = CVPixelBufferGetBytesPerRow(imageBuffer)
     let width: Int = CVPixelBufferGetWidth(imageBuffer)
     let height: Int = CVPixelBufferGetHeight(imageBuffer)
     let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue|CGBitmapInfo.byteOrder32Little.rawValue as UInt32

     //RGB color space
     let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
     let newContext: CGContext = CGContext(data: baseAddress,                                      width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)!
     // Quartz Image
     let imageRef: CGImage = newContext.makeImage()!
         
     // UIImage
     let cameraImage: UIImage = UIImage(cgImage: imageRef)
     
     // Sobel edge fileter
     let resultImage: UIImage = OpenCVWrapper.convertGrayscale(cameraImage)

     return resultImage

 }
 
 */
