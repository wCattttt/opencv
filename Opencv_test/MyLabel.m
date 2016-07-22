//
//  MyLabel.m
//  Opencv_test
//
//  Created by 魏唯隆 on 16/7/15.
//  Copyright © 2016年 魏唯隆. All rights reserved.
//

#import "MyLabel.h"

@implementation MyLabel

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

//- (void)drawRect:(CGRect)rect {
//    
//}

- (void)setTransform:(CGAffineTransform)transform{
//    transform.ty = 10;
    NSLog(@"%f", transform.a);  // 0.707107
    NSLog(@"%f", transform.b);  // 0.707107
    NSLog(@"%f", transform.c);  // -0.707107
    NSLog(@"%f", transform.d);  // 0.707107
    NSLog(@"%f", transform.tx); // 0
    NSLog(@"%f", transform.ty); // 0
    
//    坐标X按照a进行缩放，Y按照d进行缩放 ɵ就是旋转的角度
    
    transform.a = 0.8;    // 字的朝向 左右
    transform.b = 0.8;    // 字的延伸方向
    transform.c = 0;    // 字的变化 左右
    transform.d = 0.8;    // 字的朝向 左右
    [super setTransform:transform];
//    [super setTransform:CGAffineTransformMake(transform.a, transform.b, -0.8, transform.d, 0, 0)];
    
}


@end
