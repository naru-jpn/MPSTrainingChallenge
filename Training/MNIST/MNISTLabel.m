//
//  MNISTLabel.m
//  Training
//
//  Created by Naruki Chigira on 2018/12/10.
//  Copyright © 2018 Naruki Chigira. All rights reserved.
//

#import "MNISTLabel.h"
#import "MNIST.h"

@interface MNISTLabel ()
@property (nonatomic, retain, nonnull) NSData *data;
@end

@implementation MNISTLabel

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        self.data = data;
    }
    return self;
}

+ (instancetype)labelWithData:(NSData *)data {
    return [[MNISTLabel alloc] initWithData:data];
}

- (instancetype)initWithValue:(uint8_t *)value {
    size_t length = sizeof(uint8_t);
    NSData *data = [NSData dataWithBytes:value length:length];
    return [MNISTLabel labelWithData:data];
}

+ (instancetype)labelWithValue:(uint8_t *)value {
    return [[MNISTLabel alloc] initWithValue:value];
}

- (uint8_t)value {
    uint8_t value;
    [_data getBytes:&value range:NSMakeRange(0, sizeof(UInt8))];
    return value;
}

- (NSData *)alignedData {
    float labels[MNIST_LABELS] = {};
    labels[self.value] = 1.0;
    return [NSData dataWithBytes:labels length:sizeof(float)*MNIST_LABELS];
}

@end
