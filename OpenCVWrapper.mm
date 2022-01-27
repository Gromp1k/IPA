//
//  OpenCVWrapper.m
//  APO
//
//  Created by Kacper on 07/08/2021.
//

#import "OpenCVWrapper.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>

/**
        Implementation of OpenCVWrapperOpenCVWrapper.h interface.
 */
@implementation OpenCVWrapper : NSObject


///  Convertion of image to grayscale
/// @param src image of type `UIIMage`
/// - Returns: image of type UIImage
+(UIImage *) convertGrayscale:(UIImage *)src{
    cv::Mat img,gray;
    UIImageToMat(src,img);
    if(img.channels()==1) return src;
    cv::cvtColor(img, gray, cv::COLOR_BGR2GRAY);
    return MatToUIImage(gray);
}
///  Negation of image.
///
///  if image format is RGBA it will be change to Grayscale image, then negated
/// @param src image of type `UIIMage`
/// - Returns: image of type UIImage
+(UIImage *) convertNegative:(UIImage *)src{
    cv::Mat img, negate;
    UIImageToMat(src,img);
    if(img.channels()!=1){
        cv::cvtColor(img, img, cv::COLOR_BGR2GRAY);
    }
    cv::bitwise_not(img,negate);
    return MatToUIImage(negate);
}
///  Convertion of image to binary.
///
///  if image format is RGBA it will be change to Grayscale image,
///             then image is tresholded with treshold=127
/// @param src image of type `UIIMage`
/// - Returns: image of type UIImage
+(UIImage *) convertBinary:(UIImage *)src{
    cv::Mat img;
    UIImageToMat(src,img);
    if(img.channels()!=1)
        cv::cvtColor(img, img, cv::COLOR_BGR2GRAY);
    cv::threshold(img,img, 128, 255, cv::THRESH_BINARY);
    return MatToUIImage(img);
}
///   Classic image tresholding
///
///  if image format is RGBA it will be change to Grayscale image,
///             then image is tresholded with treshold value equal `level`
/// @param src image of type `UIIMage`
/// @param level value of the treshold
/// - Returns: image of type UIImage
+(UIImage *) tresholding:(UIImage *)src tresholds:(int)level{
    cv::Mat img, gray, binary;
    UIImageToMat(src,img);
    if(img.channels()!=1)
        cv::cvtColor(img, gray, cv::COLOR_BGR2GRAY);
    
    cv::threshold(gray,binary, level, 255, cv::THRESH_BINARY);
    return MatToUIImage(binary);
}

///  Adaptive image tresholding
///
///  if image format is RGBA it will be change to Grayscale image,
///             then image is tresholded with treshold value equal `level`
/// @param src image of type `UIIMage`
/// @param level value of the treshold
/// - Returns: image of type UIImage
+(UIImage *) tresholdingAdaptive:(UIImage *)src tresholds:(int)level{
    cv::Mat adapt;
    UIImageToMat(src, adapt);
    if(adapt.channels()!=1)
        cv::cvtColor(adapt, adapt, cv::COLOR_BGR2GRAY);
    cv::adaptiveThreshold(adapt, adapt, 255, cv::ADAPTIVE_THRESH_MEAN_C, cv::THRESH_BINARY, 11, 5);
    return MatToUIImage(adapt);
}

///  Otsu image tresholding
///
///  if image format is RGBA it will be change to Grayscale image,
///             then image is tresholded with treshold value equal `level`
/// @param src image of type `UIIMage`
/// @param level value of the treshold
+(UIImage *) tresholdingOtsu:(UIImage *)src tresholds:(int)level{
    cv::Mat ret2;
    UIImageToMat(src, ret2);
    if(ret2.channels()!=1)
        cv::cvtColor(ret2, ret2, cv::COLOR_BGR2GRAY);
    cv::GaussianBlur(ret2, ret2, cv::Size(5,5), 0);
    cv::threshold(ret2,ret2,0,255,cv::THRESH_BINARY+cv::THRESH_OTSU);
    return MatToUIImage(ret2);
}
///  Watershed  image tresholding
///
///  if image format is RGBA it will be change to Grayscale image,
///             then image is tresholded with treshold value equal `level`
/// @param src image of type `UIIMage`
/// @param level value of the treshold
/// - Returns: image of type UIImage
+(UIImage *) tresholdingWatershed:(UIImage *)src tresholds:(int)level{
    cv::Mat ret2, open, bg,unkown, mark;
    UIImageToMat(src, ret2);
    cv::cvtColor(ret2, ret2, cv::COLOR_BGR2GRAY);
    cv::threshold(ret2,ret2,0,255,cv::THRESH_BINARY+cv::THRESH_OTSU);
    int mask1[3][3] = {{1,1,1},{1,1,1},{1,1,1}};
    cv::Mat ms1 = cv::Mat(3,3,CV_64F,mask1);
    cv::morphologyEx(ret2, open, cv::MORPH_OPEN, ms1);
    cv::dilate(open, open, ms1);
    bg = cv::Mat(open);
    cv::distanceTransform(open, open, cv::DIST_L2, 5);
    double min, max;
    cv::minMaxLoc(open, &min, &max);
    cv::threshold(open, open, 0.5 * max,255,0);
    cv::subtract(bg, open, unkown);
    cv::connectedComponents(open,open);
    return MatToUIImage(ret2);
}
///  Classic image blur
///
///  if image format is RGBA it will be change to Grayscale image,
///             then image is tresholded with treshold value equal `level`
/// @param src image of type `UIIMage`
/// @param kernelSize size of kernel
///  Warning: kernelSize must be odd!
/// - Returns: image of type UIImage
+(UIImage *) blur:(UIImage *)src withKernel:(int)kernelSize{
    cv::Mat blur;
    UIImageToMat(src, blur);
    cv::Size size = cv::Size ((int)(size_t)kernelSize, (int)(size_t)kernelSize);
    cv::blur(blur,blur,size);
    return MatToUIImage(blur);
}
///  Gaussian image blur
///
///  if image format is RGBA it will be change to Grayscale image,
///             then image is tresholded with treshold value equal `level`
/// @param src image of type `UIIMage`
/// @param kernelSize size of kernel
///  Warning: kernelSize must be odd!
/// - Returns: image of type UIImage
+(UIImage *) blurGaussian:(UIImage *)src withKernel:(int )kernelSize{
    cv::Mat blur;
    UIImageToMat(src, blur);
    cv::Size size = cv::Size ((int)(size_t)kernelSize, (int)(size_t)kernelSize);
    cv::GaussianBlur(blur, blur, size, 0);
    return MatToUIImage(blur);
}
///  Sobel image blur
///
///  if image format is RGBA it will be change to Grayscale image,
///             then image is tresholded with treshold value equal `level`
/// @param src image of type `UIIMage`
/// @param kernelSize size of kernel
///  Warning: kernelSize must be odd!
/// - Returns: image of type UIImage
+(UIImage *) blurSobel:(UIImage *)src withKernel:(int)kernelSize{
    cv::Mat blur; // 1 2 1 FIX !!
    UIImageToMat(src, blur);
    cv::Size size = cv::Size ((int)(size_t)kernelSize, (int)(size_t)kernelSize);
    cv::GaussianBlur(blur, blur, size, 0);
    return MatToUIImage(blur);
}
///  Laplacian  image blur
///
///  if image format is RGBA it will be change to Grayscale image,
///             then image is tresholded with treshold value equal `level`
/// @param src source image of type `UIIMage`
/// @param kernelSize size of kernel ( Integer type )
///  Warning: kernelSize must be odd!
/// - Returns: image of type UIImage
+(UIImage *) blurLaplacian:(UIImage *)src withKernel:(int)kernelSize{
    cv::Mat blur;
    UIImageToMat(src, blur);
    cv::Laplacian(blur, blur, blur.depth() , (int)(int64)kernelSize);
    return MatToUIImage(blur);
}
///  Canny image blur
///
///  if image format is RGBA it will be change to Grayscale image,
///             then image is tresholded with treshold value equal `level`
/// @param src source image of type `UIIMage`
/// @param kernelSize size of kernel
///  Warning: kernelSize must be odd!
/// - Returns: image of type UIImage
+(UIImage *) blurCanny:(UIImage *)src withKernel:(int)kernelSize{
    cv::Mat blur,edges;
    UIImageToMat(src, blur);
    cv::Canny(blur, edges, 100, 200);
    return MatToUIImage(edges);
}
///  Median image blur
///
///  if image format is RGBA it will be change to Grayscale image,
///             then image is tresholded with treshold value equal `level`
/// @param src image of type `UIIMage`
/// @param kernelSize size of kernel
///  Warning: kernelSize must be odd!
/// - Returns: image of type UIImage
+(UIImage *) blurMedian:(UIImage *)src withKernel:(int)kernelSize{
    cv::Mat median;
    UIImageToMat(src, median);
    cv::medianBlur(median, median, (int)(int64)kernelSize);
    return MatToUIImage(median);
}

///  Bitwise operation - AND
/// @param src image of type `UIIMage`
/// @param second image of type `UIIMage`
///  Warning: if one of images is grayscale, result will be grayscale also
/// - Returns: image of type UIImage
+(UIImage *) bitwiseAND:(UIImage *)src withImage:(UIImage *)second{
    cv::Mat add,tmp,scd,ret;
    UIImageToMat(src, add);
    UIImageToMat(second, tmp);
    if(tmp.channels()!=add.channels()){
        cv::cvtColor(tmp, tmp, cv::COLOR_BGR2GRAY);
    }
    cv::resize(tmp, scd, add.size());
    cv::bitwise_and(add, scd, ret);
    return MatToUIImage(ret);
}
///  Bitwise operation - OR
///
/// @param src image of type `UIIMage`
/// @param second image of type `UIIMage`
///  Warning: if one of images is grayscale, result will be grayscale also
/// - Returns: image of type UIImage
+(UIImage *) bitwiseOR:(UIImage *)src withImage:(UIImage *)second{
    cv::Mat add,tmp,scd;
    UIImageToMat(src, add);
    UIImageToMat(second, tmp);
    if(tmp.channels()!=add.channels()){
        cv::cvtColor(tmp, tmp, cv::COLOR_BGR2GRAY);
    }
    cv::resize(tmp, scd, add.size());
    cv::bitwise_or(add, scd, add);
    return MatToUIImage(add);
}
///  Bitwise operation - NOT
///
///
///
/// @param src image of type `UIIMage`
///
/// - Returns: image of type UIImage
+(UIImage *) bitwiseNOT:(UIImage *)src{
    cv::Mat img, mask;
    UIImageToMat(src, img);
    if(img.channels()!=1)
        cv::cvtColor(img, img, cv::COLOR_BGR2GRAY);
    cv::threshold(img, mask, 66, 255, cv::THRESH_BINARY);
    return MatToUIImage(mask);
  
}
///  Bitwise operation - XOR
///
/// @param src image of type `UIIMage`
/// @param second image of type `UIIMage`
///  Warning: if one of images is grayscale, result will be grayscale also
/// - Returns: image of type UIImage
+(UIImage *) bitwiseXOR:(UIImage *)src withImage:(UIImage *)second{
    cv::Mat add,tmp,scd;
    UIImageToMat(src, add);
    UIImageToMat(second, tmp);
    if(tmp.channels()!=add.channels()){
        cv::cvtColor(tmp, tmp, cv::COLOR_BGR2GRAY);
    }
    cv::resize(tmp, scd, add.size());
    cv::bitwise_or(add, scd, add);
    return MatToUIImage(add);
}
///  Morphology operation - Erode
///
/// Eroses the image
/// @param src image of type `UIIMage`
///
/// - Returns: image of type UIImage
+(UIImage *) morphErode:(UIImage *)src{
    cv::Mat ero;
    UIImageToMat(src, ero);
    cv::erode(ero,ero, cv::getStructuringElement(cv::MORPH_RECT, cv::Size(5,5) ));
    return MatToUIImage(ero);
}
///  Morphology operation - Dilate
///
/// Dilates  the image
/// @param src image of type `UIIMage`
///
/// - Returns: image of type UIImage
+(UIImage *) morphDilate:(UIImage *)src{
    cv::Mat dil;
    UIImageToMat(src, dil);
    cv::dilate(dil,dil, cv::getStructuringElement(cv::MORPH_RECT, cv::Size(5,5) ));
    return MatToUIImage(dil);
}
///  Morphology operation - Open
///
/// Performs opening operation  the image
/// @param src image of type `UIIMage`
///
/// - Returns: image of type UIImage
+(UIImage *) morphOpen:(UIImage *)src{
    cv::Mat open;
    UIImageToMat(src, open);
    cv::morphologyEx(open, open, cv::MORPH_OPEN, cv::getStructuringElement(cv::MORPH_RECT, cv::Size(5,5)));
    return MatToUIImage(open);
}
///  Morphology operation - Close
///
/// Performs closing operation  the image
/// @param src image of type `UIIMage`
///
/// - Returns: image of type UIImage
+(UIImage *) morphClose:(UIImage *)src{
    cv::Mat close;
    UIImageToMat(src, close);
    cv::morphologyEx(close,close, cv::MORPH_CLOSE, cv::getStructuringElement(cv::MORPH_RECT, cv::Size(5,5)));
    return MatToUIImage(close);
}
///  Morphology operation - Skale
///
/// Performs skaling operation  the image
/// @param src image of type `UIIMage`
///
/// - Returns: image of type UIImage
+(UIImage *) morphSkale:(UIImage *)src{
    int mask1[3][3] = {{1,1,1},{1,1,1},{1,1,1}};
    int mask2[3][3] = {{1,-2,1},{-2,4,-2},{1,-2,1}};
    cv::Mat ms1 = cv::Mat(3,3,CV_64F,mask1);
    cv::Mat ms2 = cv::Mat(3,3,CV_64F,mask2);
    cv::Mat step1, step2, img;
    UIImageToMat(src, img);
    cv::filter2D(img,step1,img.depth(),ms1);
    cv::filter2D(step1,step2,step1.depth(),ms2);
    return MatToUIImage(step2);
}
///  Equalization of the image
///
/// Performs equalization operation  the image
/// @param src image of type `UIIMage`
///
/// - Returns: image of type UIImage
+(UIImage *) equalization:(UIImage *)src{
    cv::Mat eqz;
    UIImageToMat(src, eqz);
    if(eqz.channels()!=1)
        cv::cvtColor(eqz ,eqz, cv::COLOR_BGR2GRAY);
    cv::equalizeHist(eqz, eqz);
    return MatToUIImage(eqz);
}
/// Depth
///
///  Gives details about depth of the image
/// @param src image of type `UIIMage`
///
/// - Returns: count of channels in image of type Integer
+(int) depth:(UIImage *)src{
    cv::Mat ret;
    UIImageToMat(src, ret);
    return ret.channels();
}
///  Get Pixel At
///
/// Performs opening operation  the image
/// @param src image of type `UIIMage`
/// @param src X coordinate of image of type `Int`
/// @param src Y coordinate of image of type `Int`
/// - Returns: avarage pixel value from all of his channels ( channel Alpha not included ) of type 'Int'
+(int) getPixelAt:(UIImage *)src X:(int)x Y:(int)y{
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(src.CGImage));
    const UInt8* data = CFDataGetBytePtr(pixelData);
    cv::Mat ret;
    UIImageToMat(src, ret);
    const int channels = ret.channels();
    UInt8 grayColor = 0;
    int pixelInfo = channels==1 ? ((src.size.width  * y) + x ) * 1 : ((src.size.width  * y) + x ) * 4; // The image is png
    if(channels == 1){
        grayColor = data[pixelInfo];
    }
    else{
        for(int i =0; i < 3; ++i)
            grayColor+=data[pixelInfo+i];
        grayColor /= 3;
    }
    CFRelease(pixelData);
    return static_cast<int>(grayColor);
}
@end
