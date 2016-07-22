//
//  LabelTextVertical.m
//  Opencv_test
//
//  Created by 魏唯隆 on 16/7/15.
//  Copyright © 2016年 魏唯隆. All rights reserved.
//

#define labelWidth 20
#define labelHeight 20

#import "LabelTextVertical.h"

@implementation LabelTextVertical
{
    NSMutableArray *array;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        array = @[].mutableCopy;
    }
    return self;
}

#pragma mark setTransform
- (void)setAngle:(CGFloat)angle{
    _angle = angle;
    self.transform = CGAffineTransformMakeRotation(_angle);
}

- (void)setText:(NSString *)text{
    _text = text;
    for(int i = 0; i < text.length; i++){
        [array addObject:[text substringWithRange:NSMakeRange(i, 1)]];
    }
    
    [self createLabel];
}

- (void)createLabel{
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8+ idx*labelWidth, 8, labelWidth, labelHeight)];
        label.text = obj;
        label.transform = CGAffineTransformMakeRotation(-_angle);
        label.textColor = [UIColor orangeColor];
        [self addSubview:label];
    }];
}

@end
