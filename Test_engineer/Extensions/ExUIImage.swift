//
//  File.swift
//  Test_engineer
//
//  Created by Kacper on 02/02/2022.
//
extension UIImage {
    func getImageLookupTable() -> [UIColor: [Int]] {
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        guard let cgImage = self.cgImage else { return [:] }
        guard let imageData = cgImage.dataProvider?.data as Data? else {  return [:] }
        let size = cgImage.width * cgImage.height
        var LUT: [UIColor: [Int]] = [:]
        
        //Grayscale, single channel image
        if cgImage.bitsPerPixel == 8 {
            let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: size)
            _ = imageData.copyBytes(to: buffer)
            
           var gray_channel: [Int] =  Array(repeating: Int(0), count: 256)
           for pixel in buffer {
               var grayVal : UInt32 = 0
               if cgImage.byteOrderInfo == .orderDefault || cgImage.byteOrderInfo == .order16Little {
                   grayVal = UInt32((pixel) & 255)
                   gray_channel[Int(grayVal)]+=1
               }
           }
           LUT[.black] = gray_channel
           print(gray_channel)
       }
      
       //RGBA or BGRA, 4 channels image
       if cgImage.bitsPerPixel == 32 {
           let buffer = UnsafeMutableBufferPointer<UInt32>.allocate(capacity: size)
           _ = imageData.copyBytes(to: buffer)
           
           var red_channel:[Int] =  Array(repeating: Int(0), count: 256)
           var green_channel:[Int] =  Array(repeating: Int(0), count: 256)
           var blue_channel:[Int] = Array(repeating: Int(0), count: 256)
           
           for pixel in buffer {
               var r : UInt32 = 0
               var g : UInt32 = 0
               var b : UInt32 = 0
               if cgImage.byteOrderInfo == .orderDefault || cgImage.byteOrderInfo == .order32Big {
                   r = pixel & 255
                   red_channel[Int(r)]+=1
                   g = (pixel >> 8) & 255
                   blue_channel[Int(g)]+=1
                   b = (pixel >> 16) & 255
                   green_channel[Int(b)]+=1
               }
               else if cgImage.byteOrderInfo == .order32Little {
                   r = (pixel >> 16) & 255
                   g = (pixel >> 8) & 255
                   b = pixel & 255
                   blue_channel[Int(b)]+=1
                   green_channel[Int(g)]+=1
                   red_channel[Int(r)]+=1
               }
           }
           LUT[.red] = red_channel
           LUT[.blue] = blue_channel
           LUT[.green] = green_channel
       }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("Time elapsed for \(self.size): \(timeElapsed) s.")
        
        return LUT
    }
}
