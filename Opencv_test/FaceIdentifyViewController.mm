//
//  FaceIdentifyViewController.m
//  Opencv_test
//
//  Created by 魏唯隆 on 16/7/18.
//  Copyright © 2016年 魏唯隆. All rights reserved.
//

#import "FaceIdentifyViewController.h"

#import <opencv2/highgui/ios.h>
#import <opencv2/highgui/cap_ios.h>

#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import "opencv2/opencv.hpp"



UIImage *image = nil;
int currentvalue = 9;

@interface FaceIdentifyViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    __weak IBOutlet UIImageView *_img;
    __weak IBOutlet UISwitch *dogeSwitch;
    
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation FaceIdentifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.indicator.hidden = YES;
    
    
}

- (void) opencvFaceDetect  {
    UIImage* img = _img.image;
    if(img) {
        [self.view bringSubviewToFront:self.indicator];
        [self.indicator startAnimating];  //因为人脸检測比較耗时，于是使用载入指示器
        
        cvSetErrMode(CV_ErrModeParent);
        IplImage *image = [self CreateIplImageFromUIImage:img];
        
        IplImage *grayImg = cvCreateImage(cvGetSize(image), IPL_DEPTH_8U, 1); //先转为灰度图
        cvCvtColor(image, grayImg, CV_BGR2GRAY);
        
        //将输入图像缩小倍数倍以加快处理速度
        int scale = 1;  // 缩小倍数越大处理越快，准确度越低
        IplImage *small_image = cvCreateImage(cvSize(image->width/scale,image->height/scale), IPL_DEPTH_8U, 1);
        cvResize(grayImg, small_image, CV_INTER_NN);
        
        //载入分类器
        NSString *path = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt2" ofType:@"xml"];
        CvHaarClassifierCascade* cascade = (CvHaarClassifierCascade*)cvLoad([path cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, NULL);
        CvMemStorage* storage = cvCreateMemStorage(0);
        cvClearMemStorage(storage);
        
        //关键部分，使用cvHaarDetectObjects进行检測，得到一系列方框
        CvSeq* faces = cvHaarDetectObjects(small_image, cascade, storage ,1.1, currentvalue, CV_HAAR_DO_CANNY_PRUNING, cvSize(0,0), cvSize(0, 0));
        
        NSLog(@"faces:%d",faces->total);
        cvReleaseImage(&small_image);
        cvReleaseImage(&image);
        cvReleaseImage(&grayImg);
        
        if(faces->total > 0){
            //创建画布将人脸部分标记出
            CGImageRef imageRef = img.CGImage;
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGContextRef contextRef = CGBitmapContextCreate(NULL, img.size.width, img.size.height,8, img.size.width * 4,colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
            
            CGContextDrawImage(contextRef, CGRectMake(0, 0, img.size.width, img.size.height), imageRef);
            
            CGContextSetLineWidth(contextRef, 4);
            CGContextSetRGBStrokeColor(contextRef, 1.0, 0.0, 0.0, 1);
            
            //对人脸进行标记，假设isDoge为Yes则在人脸上贴图
            for(int i = 0; i < faces->total; i++) {
                
                // Calc the rect of faces
                CvRect cvrect = *(CvRect*)cvGetSeqElem(faces, i);
                CGRect face_rect = CGContextConvertRectToDeviceSpace(contextRef, CGRectMake(cvrect.x*scale, cvrect.y*scale , cvrect.width*scale, cvrect.height*scale));
                
                if(dogeSwitch.on) {
                    CGContextDrawImage(contextRef, face_rect, [UIImage imageNamed:@"doge.png"].CGImage);
                } else {
                    CGContextStrokeRect(contextRef, face_rect);
                }
                
            }
            
            _img.image = [UIImage imageWithCGImage:CGBitmapContextCreateImage(contextRef)];
            CGContextRelease(contextRef);
            CGColorSpaceRelease(colorSpace);
            
        }
        
        cvReleaseMemStorage(&storage);
        cvReleaseHaarClassifierCascade(&cascade);
    }
    
    [self.indicator stopAnimating];
    self.indicator.hidden = YES;
}

- (IplImage *)CreateIplImageFromUIImage:(UIImage *)image {
    CGImageRef imageRef = image.CGImage;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    IplImage *iplimage = cvCreateImage(cvSize(image.size.width, image.size.height), IPL_DEPTH_8U, 4);
    CGContextRef contextRef = CGBitmapContextCreate(iplimage->imageData, iplimage->width, iplimage->height,
                                                    iplimage->depth, iplimage->widthStep,
                                                    colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, image.size.width, image.size.height), imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplimage, ret, CV_RGBA2BGR);
    cvReleaseImage(&iplimage);
    
    return ret;
}



- (IBAction)SelectImg:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"选择图片来源" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction *action) {
        
    }];
    UIAlertAction *selectLibAction = [UIAlertAction actionWithTitle:@"从手机相册选择" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        UIImagePickerController *libPickController = [[UIImagePickerController alloc] init];
        libPickController.delegate = self;
        libPickController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:libPickController animated:YES completion:nil];
        
    }];
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"拍照" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        UIImagePickerController *photoPickController = [[UIImagePickerController alloc] init];
        photoPickController.delegate = self;
        photoPickController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:photoPickController animated:YES completion:nil];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:takePhotoAction];
    [alertController addAction:selectLibAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)FaceIdentify:(id)sender {
    [self.view bringSubviewToFront:self.indicator];
    self.indicator.hidden = NO;
    [self.indicator startAnimating];
    [NSThread detachNewThreadSelector:@selector(opencvFaceDetect) toTarget:self withObject:nil];
}

#pragma mark 选择照片协议
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    _img.image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
