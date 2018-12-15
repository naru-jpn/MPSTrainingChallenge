//
//  MNISTImageView.m
//  Training
//
//  Created by Naruki Chigira on 2018/12/10.
//  Copyright © 2018 Naruki Chigira. All rights reserved.
//

#import "MNISTImageView.h"
#import "MNIST.h"

@interface MNISTImageView ()
@property (nonatomic, retain, nullable) NSArray<NSNumber *> *values;
@end

@implementation MNISTImageView

- (void)setImage:(MNISTImage *)image {
    _image = image;
    if (image == nil) {
        self.values = nil;
    } else {
        self.values = image.values;
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat backgroundColor[4] = {1.0f, 1.0f, 1.0f, 1.0f};
    CGContextSetFillColor(context, backgroundColor);
    CGContextFillRect(context, rect);
    
    if (_values == nil) {
        return;
    }
    
    CGSize cellSize = CGSizeMake(rect.size.height/(CGFloat)MNIST_IMAGE_HEIGHT, rect.size.width/(CGFloat)MNIST_IMAGE_WIDTH);
    for (NSInteger j=0; j<MNIST_IMAGE_HEIGHT; j++) {
        CGFloat y = cellSize.height*j;
        for (NSInteger i=0; i<MNIST_IMAGE_WIDTH; i++) {
            CGFloat x = cellSize.width*i;
            CGRect filledRect = CGRectMake(x, y, cellSize.width, cellSize.height);
            
            NSInteger index = MNIST_IMAGE_HEIGHT*j + i;
            NSInteger value = [_values[index] integerValue];
            CGFloat grayScale = 1.0f - ((CGFloat)value)/255.0f;
            CGFloat color[4] = {grayScale, grayScale, grayScale, 1.0f};
            CGContextSetFillColor(context, color);
            CGContextFillRect(context, filledRect);
        }
    }
}

@end
