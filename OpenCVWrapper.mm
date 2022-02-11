//
//  OpenCVWrapper.m
//  APO
//
//  Created by Kacper on 07/08/2021.
//

#import "OpenCVWrapper.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>


#include <opencv2/core/utility.hpp>
#include "opencv2/imgproc.hpp"
#include "opencv2/highgui.hpp"

#include <cstdio>
#include <iostream>

@implementation OpenCVWrapper : NSObject
///  Convertion of image to grayscale
/// @param image image of type `UIIMage`
/// - Returns: image of type UIImage
+(UIImage *) convertGrayscale:(UIImage *)image{
    cv::Mat img,gray;
    UIImageToMat(image,img);
    if(img.channels()==1) return image;
    cv::cvtColor(img, gray, cv::COLOR_BGR2GRAY);
    return MatToUIImage(gray);
}
///  Negation of image.
///
///  if image format is RGBA it will be change to Grayscale image, then negated
/// @param image image of type `UIIMage`
/// - Returns: image of type UIImage
+(UIImage *) convertNegative:(UIImage *)image{
    cv::Mat img, negate;
    UIImageToMat(image,img);
    if(img.channels()!=1) cv::cvtColor(img, img, cv::COLOR_BGR2GRAY);
    cv::bitwise_not(img,negate);
    return MatToUIImage(negate);
}
///  Convertion of image to binary.
///
///  if image format is RGBA it will be change to Grayscale image,
///             then image is tresholded with treshold=127
/// @param image image of type `UIIMage`
/// - Returns: image of type UIImage
+(UIImage *) convertBinary:(UIImage *)image{
    cv::Mat img;
    UIImageToMat(image,img);
    if(img.channels()!=1) cv::cvtColor(img, img, cv::COLOR_BGR2GRAY);
    cv::threshold(img,img, 128, 255, cv::THRESH_BINARY);
    return MatToUIImage(img);
}
///   Classic image tresholding
///
///  if image format is RGBA it will be change to Grayscale image,
///             then image is tresholded with treshold value equal `level`
/// @param image image of type `UIIMage`
/// @param level value of the treshold
/// - Returns: image of type UIImage
+(UIImage *) thresholding:(UIImage *)image tresholds:(int)level{
    cv::Mat img, gray, binary;
    UIImageToMat(image,img);
    if(img.channels()!=1) cv::cvtColor(img, gray, cv::COLOR_BGR2GRAY);
    cv::threshold(gray,binary, level, 255, cv::THRESH_BINARY);
    return MatToUIImage(binary);
}

///  Adaptive image tresholding
///
///  if image format is RGBA it will be change to Grayscale image,
///             then image is tresholded with treshold value equal `level`
/// @param image image of type `UIIMage`
/// @param level value of the treshold
/// - Returns: image of type UIImage
+(UIImage *) thresholdingAdaptive:(UIImage *)image thresholds:(int)level{
    cv::Mat adapt;
    UIImageToMat(image, adapt);
    if(adapt.channels()!=1) cv::cvtColor(adapt, adapt, cv::COLOR_BGR2GRAY);
    cv::adaptiveThreshold(adapt, adapt, 255, cv::ADAPTIVE_THRESH_MEAN_C, cv::THRESH_BINARY, 11, 5);
    return MatToUIImage(adapt);
}

///  Otsu image tresholding
///
///  if image format is RGBA it will be change to Grayscale image,
///             then image is tresholded with treshold value equal `level`
/// @param image image of type `UIIMage`
/// @param level value of the treshold
+(UIImage *) thresholdingOtsu:(UIImage *)image thresholds:(int)level{
    cv::Mat ret2;
    UIImageToMat(image, ret2);
    if(ret2.channels()!=1) cv::cvtColor(ret2, ret2, cv::COLOR_BGR2GRAY);
    cv::GaussianBlur(ret2, ret2, cv::Size(5,5), 0);
    cv::threshold(ret2,ret2,0,255,cv::THRESH_BINARY+cv::THRESH_OTSU);
    return MatToUIImage(ret2);
}
///  Watershed  image tresholding
///
///  if image format is RGBA it will be change to Grayscale image,  then image is tresholded with treshold value equal `level`
/// @param image image of type `UIIMage`
/// @param level value of the treshold
/// - Returns: image of type UIImage
+(UIImage *) tresholdingWatershed:(UIImage *)image tresholds:(int)level{
    cv::Mat ret2, open, bg,unkown, mark;
    UIImageToMat(image, ret2);
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
/// @param image image of type `UIIMage`
/// @param kernelSize size of kernel
///  Warning: kernelSize must be odd!
/// - Returns: image of type UIImage
+(UIImage *) blur:(UIImage *)image withKernel:(int)kernelSize{
    cv::Mat blur;
    UIImageToMat(image, blur);
    cv::Size size = cv::Size ((int)(size_t)kernelSize, (int)(size_t)kernelSize);
    cv::blur(blur,blur,size);
    return MatToUIImage(blur);
}
///  Gaussian image blur
///
///  if image format is RGBA it will be change to Grayscale image,
///             then image is tresholded with treshold value equal `level`
/// @param image image of type `UIIMage`
/// @param kernelSize size of kernel
///  Warning: kernelSize must be odd!
/// - Returns: image of type UIImage
+(UIImage *) blurGaussian:(UIImage *)image withKernel:(int )kernelSize{
    cv::Mat blur;
    UIImageToMat(image, blur);
    cv::Size size = cv::Size ((int)(size_t)kernelSize, (int)(size_t)kernelSize);
    cv::GaussianBlur(blur, blur, size, 0);
    return MatToUIImage(blur);
}
///  Sobel image blur
///
///  if image format is RGBA it will be change to Grayscale image,
///             then image is tresholded with treshold value equal `level`
/// @param image image of type `UIIMage`
/// @param kernelSize size of kernel
///  Warning: kernelSize must be odd!
/// - Returns: image of type UIImage
+(UIImage *) blurSobel:(UIImage *)image withKernel:(int)kernelSize{
    cv::Mat blur; // 1 2 1 FIX !!
    UIImageToMat(image, blur);
    cv::Size size = cv::Size ((int)(size_t)kernelSize, (int)(size_t)kernelSize);
    cv::GaussianBlur(blur, blur, size, 0);
    return MatToUIImage(blur);
}
///  Laplacian  image blur
///
///  if image format is RGBA it will be change to Grayscale image,
///             then image is tresholded with treshold value equal `level`
/// @param image source image of type `UIIMage`
/// @param kernelSize size of kernel ( Integer type )
///  Warning: kernelSize must be odd!
/// - Returns: image of type UIImage
+(UIImage *) blurLaplacian:(UIImage *)image withKernel:(int)kernelSize{
    cv::Mat blur;
    
    UIImageToMat(image, blur);
    cv::Laplacian(blur, blur, blur.depth() , (int)(size_t)kernelSize);
    return MatToUIImage(blur);
}
///  Canny image blur
///
///  if image format is RGBA it will be change to Grayscale image,
///             then image is tresholded with treshold value equal `level`
/// @param image source image of type `UIIMage`
/// @param kernelSize size of kernel
///  Warning: kernelSize must be odd!
/// - Returns: image of type UIImage
+(UIImage *) blurCanny:(UIImage *)image withKernel:(int)kernelSize{
    cv::Mat blur,edges;
    UIImageToMat(image, blur);
    cv::Canny(blur, edges, 100, 200);
    return MatToUIImage(edges);
}
///  Median image blur
///
///  if image format is RGBA it will be change to Grayscale image,
///             then image is tresholded with treshold value equal `level`
/// @param image image of type `UIIMage`
/// @param kernelSize size of kernel
///  Warning: kernelSize must be odd!
/// - Returns: image of type UIImage
+(UIImage *) blurMedian:(UIImage *)image withKernel:(int)kernelSize{
    cv::Mat median;
    UIImageToMat(image, median);
    cv::medianBlur(median, median, (int)(int64)kernelSize);
    return MatToUIImage(median);
}

///  Bitwise operation - AND
/// @param image image of type `UIIMage`
/// @param second image of type `UIIMage`
///  Warning: if one of images is grayscale, result will be grayscale also
/// - Returns: image of type UIImage
+(UIImage *) bitwiseAND:(UIImage *)image withImage:(UIImage *)second{
    cv::Mat add,tmp,scd,ret;
    UIImageToMat(image, add);
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
/// @param image image of type `UIIMage`
/// @param second image of type `UIIMage`
///  Warning: if one of images is grayscale, result will be grayscale also
/// - Returns: image of type UIImage
+(UIImage *) bitwiseOR:(UIImage *)image withImage:(UIImage *)second{
    cv::Mat add,tmp,scd;
    UIImageToMat(image, add);
    UIImageToMat(second, tmp);
    if(tmp.channels()!=add.channels()){
        cv::cvtColor(tmp, tmp, cv::COLOR_BGR2GRAY);
    }
    cv::resize(tmp, scd, add.size());
    cv::bitwise_or(add, scd, add);
    return MatToUIImage(add);
}
///  Bitwise operation - NOT
/// @param image image of type `UIIMage`
///
/// - Returns: image of type UIImage
+(UIImage *) bitwiseNOT:(UIImage *)image{
    cv::Mat img, mask;
    UIImageToMat(image, img);
    if(img.channels()!=1)
        cv::cvtColor(img, img, cv::COLOR_BGR2GRAY);
    cv::threshold(img, mask, 66, 255, cv::THRESH_BINARY);
    return MatToUIImage(mask);
  
}
///  Bitwise operation - XOR
///
/// @param image image of type `UIIMage`
/// @param second image of type `UIIMage`
///  Warning: if one of images is grayscale, result will be grayscale also
/// - Returns: image of type UIImage
+(UIImage *) bitwiseXOR:(UIImage *)image withImage:(UIImage *)second{
    cv::Mat add,tmp,scd;
    UIImageToMat(image, add);
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
/// @param image image of type `UIIMage`
///
/// - Returns: image of type UIImage
+(UIImage *) morphErode:(UIImage *)image{
    cv::Mat ero;
    UIImageToMat(image, ero);
    cv::erode(ero,ero, cv::getStructuringElement(cv::MORPH_RECT, cv::Size(5,5) ));
    return MatToUIImage(ero);
}
///  Morphology operation - Dilate
///
/// Dilates  the image
/// @param image image of type `UIIMage`
///
/// - Returns: image of type UIImage
+(UIImage *) morphDilate:(UIImage *)image{
    cv::Mat dil;
    UIImageToMat(image, dil);
    cv::dilate(dil,dil, cv::getStructuringElement(cv::MORPH_RECT, cv::Size(5,5) ));
    return MatToUIImage(dil);
}
///  Morphology operation - Open
///
/// Performs opening operation  the image
/// @param image image of type `UIIMage`
///
/// - Returns: image of type UIImage
+(UIImage *) morphOpen:(UIImage *)image{
    cv::Mat open;
    UIImageToMat(image, open);
    cv::morphologyEx(open, open, cv::MORPH_OPEN, cv::getStructuringElement(cv::MORPH_RECT, cv::Size(5,5)));
    return MatToUIImage(open);
}
///  Morphology operation - Close
///
/// Performs closing operation  the image
/// @param image image of type `UIIMage`
///
/// - Returns: image of type UIImage
+(UIImage *) morphClose:(UIImage *)image{
    cv::Mat close;
    UIImageToMat(image, close);
    cv::morphologyEx(close,close, cv::MORPH_CLOSE, cv::getStructuringElement(cv::MORPH_RECT, cv::Size(5,5)));
    return MatToUIImage(close);
}
///  Morphology operation - Skale
///
/// Performs skaling operation  the image
/// @param image image of type `UIIMage`
///
/// - Returns: image of type UIImage
+(UIImage *) morphSkale:(UIImage *)image{
    cv::Mat src;
    UIImageToMat(image, src);
    if(src.channels()!=1) cv::cvtColor(src, src, cv::COLOR_BGR2GRAY);
    cv::threshold(src, src, 127, 255, cv::THRESH_BINARY);
    cv::Mat skel(src.size(), CV_8UC1);
    cv::Mat temp;
    cv::Mat eroded;
    cv::Mat element = cv::getStructuringElement(cv::MORPH_CROSS, cv::Size(3, 3));
    bool done;
    do
    {
      cv::erode(src, eroded, element);
      cv::dilate(eroded, temp, element); // temp = open(img)
      cv::subtract(src, temp, temp);
      cv::bitwise_or(skel, temp, skel);
      eroded.copyTo(src);
     
      done = (cv::countNonZero(src) == 0);
    } while (!done);
    
    return MatToUIImage(skel);
    
}
///  Equalization of the image's histogram
///
/// Performs equalization operation  the image
/// @param image image of type `UIIMage`
///
/// - Returns: image of type UIImage
+(UIImage *) histEqualization:(UIImage *)image{
    cv::Mat eqz;
    UIImageToMat(image, eqz);
    if(eqz.channels()!=1)
        cv::cvtColor(eqz ,eqz, cv::COLOR_BGR2GRAY);
    cv::equalizeHist(eqz, eqz);
    return MatToUIImage(eqz);
}

///  Normalization of the image's histogram
///
/// Performs normalization operation  the image
/// @param image image of type `UIIMage`
///
/// - Returns: image of type UIImage
+(UIImage *) histNormalize:(UIImage *)image min:(int)minVal max:(int)maxVal{
    cv::Mat norm;
    UIImageToMat(image, norm);
    cv::normalize(norm, norm, minVal,maxVal,cv::NORM_MINMAX  );
    return MatToUIImage(norm);
    
}





class WatershedSegmenter{
private:
    cv::Mat markers;
public:
    void setMarkers(cv::Mat& markerImage)
    {
        markerImage.convertTo(markers, CV_32S);
    }

    cv::Mat process(cv::Mat &image)
    {
        cv::watershed(image, markers);
        markers.convertTo(markers,CV_8U);
        return markers;
    }
};



using namespace cv;
using namespace std;


/*
 img[markers == -1] = [255,0,0]
 img.setTo(Scalar(255,0,0), markers==-1);
 */
+(UIImage *) watershed:(UIImage *)image{
   // V1
//    cv::Mat src;
//    UIImageToMat(image, src);
//    cv::cvtColor(src,src,cv::COLOR_RGBA2BGR);
//
//        cv::Mat bw;
//    cv::cvtColor(src, bw, cv::COLOR_BGR2GRAY);
//    cv::threshold(bw, bw, 35, 255, THRESH_BINARY);
//
//    // Perform the distance transform algorithm
//        cv::Mat dist;
//    cv::distanceTransform(bw, dist, DIST_L2, DIST_MASK_3);
//
//    // Normalize the distance image for range = {0.0, 1.0}
//        // so we can visualize and threshold it
//        cv::normalize(dist, dist, 0, 1., cv::NORM_MINMAX);
//
//    // Threshold to obtain the peaks
//        // This will be the markers for the foreground objects
//    cv::threshold(dist, dist, .5, 1., THRESH_BINARY);
////        cv::imshow("dist2", dist);
//
//    // Create the CV_8U version of the distance image
//        // It is needed for cv::findContours()
//        cv::Mat dist_8u;
//        dist.convertTo(dist_8u, CV_8U);
//
//    // Find total markers
//        std::vector<std::vector<cv::Point> > contours;
//    cv::findContours(dist_8u, contours, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
//        int ncomp = contours.size();
//
//    // Create the marker image for the watershed algorithm
//        cv::Mat markers = cv::Mat::zeros(dist.size(), CV_32SC1);
//
//    // Draw the foreground markers
//        for (int i = 0; i < ncomp; i++)
//            cv::drawContours(markers, contours, i, cv::Scalar::all(i+1), -1);
//
//    // Draw the background marker
//    cv::circle(markers, cv::Point(5,5), 3, CV_RGB(255,255,255), -1);
////    cv::imshow("markers", markers*10000);
//
//    // Generate random colors
//        std::vector<cv::Vec3b> colors;
//        for (int i = 0; i < ncomp; i++)
//        {
//            int b = cv::theRNG().uniform(0, 255);
//            int g = cv::theRNG().uniform(0, 255);
//            int r = cv::theRNG().uniform(0, 255);
//
//            colors.push_back(cv::Vec3b((uchar)b, (uchar)g, (uchar)r));
//        }
//    // Create the result image
//        cv::Mat dst = cv::Mat::zeros(markers.size(), CV_8UC3);
//
//        // Fill labeled objects with random colors
//        for (int i = 0; i < markers.rows; i++)
//        {
//            for (int j = 0; j < markers.cols; j++)
//            {
//                int index = markers.at<int>(i,j);
//                if (index > 0 && index <= ncomp)
//                    dst.at<cv::Vec3b>(i,j) = colors[index-1];
//                else
//                    dst.at<cv::Vec3b>(i,j) = cv::Vec3b(0,0,0);
//            }
//        }
//
//    return(MatToUIImage(dst));
    
    
    
    
    //V2
    cv::Mat src;
    UIImageToMat(image, src);
    cv::cvtColor(src,src,cv::COLOR_RGBA2RGB);
    
    cv::Mat gray;
    cv::cvtColor(src, gray, cv::COLOR_RGB2GRAY);
    
    cv::Mat thresh;
    cv::threshold(gray, thresh, 0, 255, cv::THRESH_BINARY_INV+cv::THRESH_OTSU);
    
    cv::Mat kernel = cv::Mat::ones(3, 3, CV_8U);
    cv::Point anchor = cv::Point(-1,-1);
    
    cv::Mat open;
    cv::morphologyEx(thresh, open, cv::MORPH_OPEN, kernel,anchor,2);
    
    cv::Mat sure_bg;
    cv::dilate(open,sure_bg, kernel,anchor,3);
    
    cv::Mat dist_trn;
    cv::distanceTransform(open, dist_trn, cv::DIST_L2, cv::DIST_MASK_3);
    
    cv::Mat ret, sure_fg;
    
    double maxV;
    cv::minMaxLoc(dist_trn, 0, &maxV);
    cv::threshold(dist_trn,sure_fg,0.7*maxV,255,0);
    sure_fg.convertTo(sure_fg, CV_8UC1);
    
    cv::Mat unknown;
    cv::subtract(sure_bg, sure_fg, unknown);
    
    cv::Mat markers;
    cv::connectedComponents(sure_fg, markers);
    markers += 1;
    
    /*
     img[markers == -1] = [255,0,0]
     img.setTo(Scalar(255,0,0), markers==-1);
     */
    markers.setTo(cv::Scalar(0), unknown==255);
    cv::watershed(src,markers);
    
    src.setTo(Scalar(255,0,0), markers==-1);
    
    return MatToUIImage(src);
}



/// Depth
///
///  Gives details about depth of the image
/// @param image image of type `UIIMage`
///
/// - Returns: count of channels in image of type Integer
+(int) depth:(UIImage *)image{
    cv::Mat ret;
    UIImageToMat(image, ret);
    return ret.channels();
}
///  Get Pixel At
///
/// Performs opening operation  the image
/// @param image image of type `UIIMage`
/// @param image X coordinate of image of type `Int`
/// @param image Y coordinate of image of type `Int`
/// - Returns: avarage pixel value from all of his channels ( channel Alpha not included ) of type 'Int'
+(int) getPixelAt:(UIImage *)image X:(int)x Y:(int)y{
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    const UInt8* data = CFDataGetBytePtr(pixelData);
    cv::Mat ret;
    UIImageToMat(image, ret);
    const int channels = ret.channels();
    UInt8 grayColor = 0;
    int pixelInfo = channels==1 ? ((image.size.width  * y) + x ) * 1 : ((image.size.width  * y) + x ) * 4; // The image is png
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
