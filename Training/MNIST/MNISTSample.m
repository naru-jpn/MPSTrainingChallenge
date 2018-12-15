//
//  MNISTSample.m
//  Training
//
//  Created by Naruki Chigira on 2018/12/10.
//  Copyright © 2018 Naruki Chigira. All rights reserved.
//

#import "MNISTSample.h"

@implementation MNISTSample

- (instancetype)initWithLabel:(MNISTLabel *)label image:(MNISTImage *)image {
    self = [super init];
    if (self) {
        self.label = label;
        self.image = image;
    }
    return self;
}

+ (instancetype)sampleWithLabel:(MNISTLabel *)label image:(MNISTImage *)image {
    return [[MNISTSample alloc] initWithLabel:label image:image];
}

@end
