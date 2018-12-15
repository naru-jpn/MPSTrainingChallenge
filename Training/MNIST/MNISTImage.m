//
//  MNISTImage.m
//  Training
//
//  Created by Naruki Chigira on 2018/12/10.
//  Copyright © 2018 Naruki Chigira. All rights reserved.
//

@import Darwin;
#import "MNISTImage.h"
#import "MNIST.h"

@interface MNISTImage ()
@property (nonatomic, retain, nonnull) NSData *data;
@end

@implementation MNISTImage

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        self.data = data;
    }
    return self;
}

+ (instancetype)imageWithData:(NSData *)data {
    return [[MNISTImage alloc] initWithData:data];
}

- (instancetype)initWithValues:(UInt8 *)values {
    size_t length = sizeof(UInt8)*MNIST_IMAGE_WIDTH*MNIST_IMAGE_HEIGHT;
    NSData *data = [NSData dataWithBytes:&values length:length];
    return [MNISTImage imageWithData:data];
}

+ (instancetype)imageWithValues:(UInt8 *)values {
    return [[MNISTImage alloc] initWithValues:values];
}

- (NSArray<NSNumber *> *)values {
    size_t corsor = 0;
    size_t count = MNIST_IMAGE_WIDTH*MNIST_IMAGE_HEIGHT;
    NSMutableArray *array = [NSMutableArray new];
    for (NSInteger i=0; i<count; i++) {
        UInt8 value;
        [_data getBytes:&value range:[MNIST rangeWithMoved:sizeof(UInt8) fromCorsor:&corsor]];
        [array addObject:[NSNumber numberWithInt:value]];
    }
    return array;
}

@end
