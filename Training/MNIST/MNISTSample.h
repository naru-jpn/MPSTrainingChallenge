//
//  MNISTSample.h
//  Training
//
//  Created by Naruki Chigira on 2018/12/10.
//  Copyright © 2018 Naruki Chigira. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MNISTLabel.h"
#import "MNISTImage.h"

@interface MNISTSample : NSObject

@property (nonatomic, retain, nullable) MNISTLabel *label;
@property (nonatomic, retain, nullable) MNISTImage *image;

- (nonnull instancetype)initWithLabel:(nullable MNISTLabel *)label image:(nullable MNISTImage *)image;

+ (nonnull instancetype)sampleWithLabel:(nullable MNISTLabel *)label image:(nullable MNISTImage *)image;

@end
