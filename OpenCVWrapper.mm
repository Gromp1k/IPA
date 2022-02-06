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
+(UIImage *) tresholding:(UIImage *)image tresholds:(int)level{
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
+(UIImage *) tresholdingAdaptive:(UIImage *)image tresholds:(int)level{
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
+(UIImage *) tresholdingOtsu:(UIImage *)image tresholds:(int)level{
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
///
///
///
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
    int mask1[3][3] = {{1,1,1},{1,1,1},{1,1,1}};
    int mask2[3][3] = {{1,-2,1},{-2,4,-2},{1,-2,1}};
    cv::Mat ms1 = cv::Mat(3,3,CV_64F,mask1);
    cv::Mat ms2 = cv::Mat(3,3,CV_64F,mask2);
    cv::Mat step1, step2, img;
    UIImageToMat(image, img);
    cv::filter2D(img,step1,img.depth(),ms1);
    cv::filter2D(step1,step2,step1.depth(),ms2);
    return MatToUIImage(step2);
}
///  Equalization of the image
///
/// Performs equalization operation  the image
/// @param image image of type `UIIMage`
///
/// - Returns: image of type UIImage
+(UIImage *) equalization:(UIImage *)image{
    cv::Mat eqz;
    UIImageToMat(image, eqz);
    if(eqz.channels()!=1)
        cv::cvtColor(eqz ,eqz, cv::COLOR_BGR2GRAY);
    cv::equalizeHist(eqz, eqz);
    return MatToUIImage(eqz);
}





+(UIImage *) watershed:(UIImage *)image{
    cv::Mat src, dest;
    UIImageToMat(image, src); // convert source src to Mat
    cvtColor(src, src, cv::COLOR_BGRA2BGR); // change 4 to 3 channels


    // Change the background from white to black, since that will help later to extract better results during the use of Distance Transform
    cv::Mat mask;
    inRange(src, cv::Scalar(255,255,255), cv::Scalar(255,255,255), mask);
    src.setTo(cv::Scalar(0,0,0),mask);

    // an approximation of second derivative, a quite strong kernel
    cv::Mat kernel = (cv::Mat_<float>(3,3) <<
                    1,  1, 1,
                    1, -8, 1,
                    1,  1, 1);

    /*
     laplacian filtering as it is
     convert everything in something more deeper then CV_8U cause the kernel has some negative values
     correct with uint8 - possible negative number will be truncated
     */
    cv::Mat laplacian;
    cv::filter2D(src, laplacian, CV_32F, kernel);

    cv::Mat sharp;
    src.convertTo(sharp, CV_32F);

    cv::Mat result = sharp - laplacian;

    // convert back to 8bits gray scale
    result.convertTo(result, CV_8UC3);
    laplacian.convertTo(laplacian, CV_8UC3);

    //binary image from source image
    cv::Mat bnr;
    cv::cvtColor(result, bnr, cv::COLOR_BGRA2GRAY);
    cv::threshold(bnr, bnr, 40, 255, cv::THRESH_BINARY | cv::THRESH_OTSU);

    // Perform the distance transform algorithm
    cv::Mat dist;
    cv::distanceTransform(bnr, dist, cv::DIST_L2, cv::DIST_MASK_3);

    // Normalize the distance image for range = {0.0, 1.0} (to visualize and threshold it)
    cv::normalize(dist, dist, 0, 1.0, cv::NORM_MINMAX);

    // Threshold to obtain the peaks - the markers for the foreground objects
    cv::threshold(dist, dist, 0.4, 1.0, cv::THRESH_BINARY);

    // Dilate a bit the dist image
    cv::Mat kernel1 = cv::Mat::ones(3, 3, CV_8U);
    cv::dilate(dist, dist, kernel1);

    //CV_8U version of the distance image - FIX_ME : for findContours()
    cv::Mat dist_8u;
    dist.convertTo(dist_8u, CV_8U);

    // Find total markers
    std::vector< std::vector< cv::Point> > contours;
    cv::findContours(dist_8u, contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);

    //the marker image for the watershed algorithm
    cv::Mat markers = cv::Mat::zeros(dist.size(), CV_32S);

    // Draw the foreground markers
    for(size_t i = 0; i < contours.size(); ++i) cv::drawContours(markers, contours, static_cast<int>(i), cv::Scalar(static_cast<int>(i)+1), -1);

    // Draw the background marker
    cv::circle(markers, cv::Point(5,5), 3, cv::Scalar(255), -1);
    cv::Mat markers8u;
    markers.convertTo(markers8u, CV_8U, 10);

    // Perform the watershed algorithm
    cv::watershed(result, markers);

    cv::Mat mark;
    markers.convertTo(mark, CV_8U);
    cv::bitwise_not(mark, mark);

    //Generate random colors
    std::vector<cv::Vec3b> colors;
        for (size_t i = 0; i < contours.size(); i++)
        {
            int b = cv::theRNG().uniform(0, 256);
            int g = cv::theRNG().uniform(0, 256);
            int r = cv::theRNG().uniform(0, 256);
            colors.push_back(cv::Vec3b((uchar)b, (uchar)g, (uchar)r));
        }

        //Create the result image
        cv::Mat dst = cv::Mat::zeros(markers.size(), CV_8UC3);

        //Fill labeled objects with random color
        for (int i = 0; i < markers.rows; i++)
            for (int j = 0; j < markers.cols; j++) {
                int index = markers.at<int>(i,j);
                if (index > 0 && index <= static_cast<int>(contours.size())) dst.at<cv::Vec3b>(i,j) = colors[index-1];
            }

    return MatToUIImage(dst);
    
//        class WatershedSegmenter{
//        private:
//            cv::Mat markers;
//        public:
//            void setMarkers(cv::Mat& markerImage){ markerImage.convertTo(markers, CV_32S);}
//
//            cv::Mat process(cv::Mat &image)
//            {
//                cv::watershed(image, markers);
//                markers.convertTo(markers,CV_8UC3);
//                return markers;
//            }
//        };
//
//        cv::Mat src;
//        UIImageToMat(image, src); // convert source src to Mat
//        cvtColor(src, src, cv::COLOR_BGRA2BGR); // change 4 to 3 channels
//
//        cv::Mat blank(src.size(),CV_8U,cv::Scalar(0xFF));
//        cv::Mat dest;
//        cv::Mat markers(src.size(),CV_8U,cv::Scalar(-1));
//
//        markers(cv::Rect(0,0,src.cols, 5)) = cv::Scalar::all(1);
//        markers(cv::Rect(0,src.rows-5,src.cols, 5)) = cv::Scalar::all(1);
//        markers(cv::Rect(0,0,5,src.rows)) = cv::Scalar::all(1);
//        markers(cv::Rect(src.cols-5,0,5,src.rows)) = cv::Scalar::all(1);
//
//        int centreW = src.cols/4;
//        int centreH = src.rows/4;
//
//        markers(cv::Rect((src.cols/2)-(centreW/2),(src.rows/2)-(centreH/2), centreW, centreH)) = cv::Scalar::all(2);
//        markers.convertTo(markers,cv::COLOR_BGR2GRAY);
//
//        WatershedSegmenter segmenter;
//        segmenter.setMarkers(markers);
//        cv::Mat wshedMask = segmenter.process(src);
//        cv::Mat mask;
//        cv::convertScaleAbs(wshedMask, mask, 1, 0);
//        cv::threshold(mask, mask, 1, 255, cv::THRESH_BINARY);
//        cv::bitwise_and(src, src, dest, mask);
//        dest.convertTo(dest,CV_8U);
//
//    return MatToUIImage(dest);
    
    
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
