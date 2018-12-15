//
//  MNIST.m
//  Training
//
//  Created by Naruki Chigira on 2018/12/10.
//  Copyright © 2018 Naruki Chigira. All rights reserved.
//

@import Darwin;
#import "MNIST.h"

@interface MNIST ()
@property (nonatomic) MNISTDatasetType datasetType;
@property (nonatomic, retain, nonnull) NSArray<MNISTSample *> *samples;
@property (nonatomic, retain, nonnull) NSArray<MNISTLabel *> *labels;
@property (nonatomic, retain, nonnull) NSArray<MNISTImage *> *images;
@end

@implementation MNIST

- (instancetype)initWithDatasetType:(MNISTDatasetType)datasetType {
    self = [super init];
    if (self) {
        _datasetType = datasetType;
        [self loadLabels];
        [self loadImages];
        NSMutableArray<MNISTSample *> *samples = [NSMutableArray new];
        for (NSInteger i=0; i<MIN(_labels.count, _images.count); i++) {
            [samples addObject:[MNISTSample sampleWithLabel:_labels[i] image:_images[i]]];
        }
        self.samples = samples;
    }
    return self;
}

+ (instancetype)mnistWithDatasetType:(MNISTDatasetType)datasetType {
    return [[MNIST alloc] initWithDatasetType:datasetType];
}

- (void)loadLabels {
    NSURL *url = [self urlForLabelDataWithDatasetType:_datasetType];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    size_t corsor = 0;
    
    int32_t magic_num;
    [data getBytes:&magic_num range:[MNIST rangeWithMoved:sizeof(int32_t) fromCorsor:&corsor]];
    magic_num = CFSwapInt32(magic_num); // 2049
    
    int32_t count;
    [data getBytes:&count range:[MNIST rangeWithMoved:sizeof(int32_t) fromCorsor:&corsor]];
    count = CFSwapInt32(count); // 60000 or 10000
    
    size_t labelSize = sizeof(uint8_t);
    NSMutableArray<MNISTLabel *> *labels = [NSMutableArray new];
    for (NSInteger i=0; i<count; i++) {
        NSData *labelData = [data subdataWithRange:[MNIST rangeWithMoved:labelSize fromCorsor:&corsor]];
        MNISTLabel *label = [MNISTLabel labelWithData:labelData];
        [labels addObject:label];
    }
    self.labels = labels;
}

- (void)loadImages {
    NSURL *url = [self urlForImageDataWithDatasetType:_datasetType];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    size_t corsor = 0;
    
    int32_t magic_num;
    [data getBytes:&magic_num range:[MNIST rangeWithMoved:sizeof(int32_t) fromCorsor:&corsor]];
    magic_num = CFSwapInt32(magic_num); // 2051
    
    int32_t count;
    [data getBytes:&count range:[MNIST rangeWithMoved:sizeof(int32_t) fromCorsor:&corsor]];
    count = CFSwapInt32(count); // 60000 or 10000
    
    int32_t width;
    [data getBytes:&width range:[MNIST rangeWithMoved:sizeof(int32_t) fromCorsor:&corsor]];
    width = CFSwapInt32(width); // 28
    
    int32_t height;
    [data getBytes:&height range:[MNIST rangeWithMoved:sizeof(int32_t) fromCorsor:&corsor]];
    height = CFSwapInt32(height); // 28
    
    size_t imageSize = sizeof(uint8_t)*width*height;
    NSMutableArray<MNISTImage *> *images = [NSMutableArray new];
    for (NSInteger i=0; i<count; i++) {
        NSData *imageData = [data subdataWithRange:[MNIST rangeWithMoved:imageSize fromCorsor:&corsor]];
        MNISTImage *image = [MNISTImage imageWithData:imageData];
        [images addObject:image];
    }
    self.images = images;
}

#pragma mark - Informations

- (NSURL *)urlForLabelDataWithDatasetType:(MNISTDatasetType)datasetType {
    switch (datasetType) {
        case MNISTDatasetTypeTraining: {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"train-labels" ofType:@"idx1-ubyte"];
            return [NSURL fileURLWithPath:path];
        }
        case MNISTDatasetTypeTest: {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"t10k-labels" ofType:@"idx1-ubyte"];
            return [NSURL fileURLWithPath:path];
        }
        default:
            return [NSURL new];
    }
}

- (NSURL *)urlForImageDataWithDatasetType:(MNISTDatasetType)datasetType {
    switch (datasetType) {
        case MNISTDatasetTypeTraining: {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"train-images" ofType:@"idx3-ubyte"];
            return [NSURL fileURLWithPath:path];
        }
        case MNISTDatasetTypeTest: {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"t10k-images" ofType:@"idx3-ubyte"];
            return [NSURL fileURLWithPath:path];
        }
        default:
            return [NSURL new];
    }
}

#pragma mark - Utilities

+ (NSRange)rangeWithMoved:(size_t)moved fromCorsor:(size_t *)corsor {
    NSRange range = NSMakeRange(*corsor, moved);
    *corsor += moved;
    return range;
}

@end
