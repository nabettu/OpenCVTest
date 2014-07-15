//
//  TopViewController.m
//  opencv
//
//  Created by tatsuaki watanabe on 2014/07/16.
//  Copyright (c) 2014年 tatsuaki watanabe. All rights reserved.
//

#import "TopViewController.h"

@interface TopViewController ()

@end

@implementation TopViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //タイトル追加
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.text = @"OpenCV test APP";
    titleLabel.numberOfLines = 2;
    titleLabel.font = [UIFont systemFontOfSize:40];
    titleLabel.frame = CGRectMake(0, 50, 320, 100);
    titleLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    //start button create
    UIImageView *startBtn = [[UIImageView alloc]init];
    startBtn.backgroundColor = [UIColor colorWithRed:1.0 green:0.5 blue:0.2 alpha:1];
    startBtn.frame = CGRectMake(110, 400, 100, 50);
    [self.view addSubview:startBtn];
    startBtn.clipsToBounds = YES;
    startBtn.layer.cornerRadius = 20;
    UILabel *btnLabel = [[UILabel alloc]init];
    btnLabel.text = @"Camera";
    btnLabel.font = [UIFont systemFontOfSize:20];
    btnLabel.frame = CGRectMake(0, 0, 100, 50);
    btnLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    btnLabel.textAlignment = NSTextAlignmentCenter;
    [startBtn addSubview:btnLabel];
    startBtn.userInteractionEnabled = YES;
    startBtn.tag = 100;
    UITapGestureRecognizer *startBtnGesture = [[UITapGestureRecognizer alloc]initWithTarget:
                                               self action:@selector(tapAction:)];
    [startBtn addGestureRecognizer:startBtnGesture];
    
    
}

- (void)tapAction:(UIGestureRecognizer*)gesture
{
    //self.view.backgroundColor = [UIColor blackColor];
    // 1.何をおしたか判別　=> tagを使う
    if(gesture.view.tag == 100){
        pic = [[UIImagePickerController alloc]init];
        pic.delegate = (id)self;
        pic.sourceType = UIImagePickerControllerSourceTypeCamera;
        pic.allowsEditing = TRUE;
        
        [self presentViewController:pic animated:YES completion:nil];
        
        cv::Mat srcMat = [self cvMatFromUIImage:pic];
        cv::Mat greyMat;
        cv::cvtColor(srcMat, greyMat, CV_BGR2GRAY);
        
        return [self UIImageFromCVMat:greyMat];
    }
    return;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

- (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                              //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

@end
