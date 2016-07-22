//
//  CarIdentifyViewController.m
//  Opencv_test
//
//  Created by 魏唯隆 on 16/7/14.
//  Copyright © 2016年 魏唯隆. All rights reserved.
//

#import "CarIdentifyViewController.h"

#import "SampleBase.h"
#import "SampleFacade.h"
#import "UIImage2OpenCV.h"
#import "EdgeDetectionSample.h"

#import <opencv2/highgui/ios.h>
#import <opencv2/highgui/cap_ios.h>

#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>


@interface CarIdentifyViewController ()<CvVideoCameraDelegate>
{
    cv::Mat outputFrame;
}
@property (readonly) SampleFacade * currentSample;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *curCameraBarBt;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *camceraBarBt;
@property (nonatomic, strong) CvVideoCamera* videoSource;
@end

@implementation CarIdentifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _currentSample = [[SampleFacade alloc] initWithSample:  new EdgeDetectionSample()];
    
    [self _initSourceWithPosition:AVCaptureDevicePositionBack];
}

- (void)_initSourceWithPosition:(AVCaptureDevicePosition)position{
    self.videoSource = [[CvVideoCamera alloc] initWithParentView:self.imageView];
    self.videoSource.defaultAVCaptureDevicePosition = position;
    self.videoSource.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1280x720;
    self.videoSource.defaultFPS = 30;
    //self.videoSource.imageWidth = 1280;
    //self.videoSource.imageHeight = 720;
    self.videoSource.delegate = self;
    self.videoSource.recordVideo = NO;
    self.videoSource.grayscaleMode = NO;
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.videoSource start];
}
- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.videoSource stop];
}

#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus
- (void) processImage:(cv::Mat&)image
{
    // Do some OpenCV stuff with the image
    [self.currentSample processFrame:image into:outputFrame];
    
    // outputFrame.copyTo(image);
}
#endif

- (IBAction)currentCamera:(id)sender {
    if(self.videoSource.defaultAVCaptureDevicePosition == AVCaptureDevicePositionBack){
        [_videoSource stop];
        _videoSource = nil;
        [self _initSourceWithPosition:AVCaptureDevicePositionFront];
        _curCameraBarBt.title = @"后置";
        [_videoSource start];
    }else{
        [_videoSource stop];
        _videoSource = nil;
        [self _initSourceWithPosition:AVCaptureDevicePositionBack];
        _curCameraBarBt.title = @"前置";
        [_videoSource start];
    }
}

- (IBAction)reCamera:(id)sender {
    _camceraBarBt.enabled = YES;
    [self.videoSource start];
    _imageView.transform = CGAffineTransformMakeRotation(M_PI*2);
    _imageView.image = nil;
    
}

- (IBAction)cancera:(id)sender {
    UIBarButtonItem *barBt = (UIBarButtonItem *)sender;
    barBt.enabled = NO;
    [self.videoSource stop];
    UIImage *image = [UIImage imageWithMat:outputFrame.clone() andDeviceOrientation:[[UIDevice currentDevice] orientation]];
    _imageView.image = image;
    _imageView.transform = CGAffineTransformMakeRotation(M_PI);
    
//    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL)
    {
        NSLog(@"Error during saving image: %@", error);
    }
}



/*
- (void)cvImage{
     CGRect rect = [UIScreen mainScreen].bounds;
     self.imageView.frame = rect;
     
     UIImage *image = [UIImage imageNamed:@"京A88731.jpg"];
     // Convert UIImage * to cv::Mat
     UIImageToMat(image, cvImage);
     if (!cvImage.empty()) {
     cv::Mat gray;
     // Convert the image to grayscale;
     cv::cvtColor(cvImage, gray, CV_RGBA2GRAY);
     // Apply Gaussian filter to remove small edges
     cv::GaussianBlur(gray, gray, cv::Size(5,5), 1.2,1.2);
     // Calculate edges with Canny
     cv::Mat edges;
     cv::Canny(gray, edges, 0, 60);
     // Fill image with white color
     cvImage.setTo(cv::Scalar::all(255));
     // Change color on edges
     cvImage.setTo(cv::Scalar(0,128,255,255),edges);
     // Convert cv::Mat to UIImage* and show the resulting image
     self.imageView.image = MatToUIImage(cvImage);
     }

}
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
