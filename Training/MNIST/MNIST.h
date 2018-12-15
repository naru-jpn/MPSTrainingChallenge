//
//  MNIST.h
//  Training
//
//  Created by Naruki Chigira on 2018/12/10.
//  Copyright © 2018 Naruki Chigira. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MNISTSample.h"

static const size_t MNIST_SAMPLES_TRAINING = 60000;
static const size_t MNIST_IMAGE_WIDTH = 28;
static const size_t MNIST_IMAGE_HEIGHT = 28;
static const size_t MNIST_LABELS = 10;

typedef NS_ENUM(NSInteger, MNISTDatasetType) {
    MNISTDatasetTypeTraining,
    MNISTDatasetTypeTest
};

@interface MNIST : NSObject

@property (readonly, nonatomic) MNISTDatasetType datasetType;

@property (nonatomic, retain, readonly, nonnull) NSArray<MNISTSample *> *samples;

- (instancetype)initWithDatasetType:(MNISTDatasetType)datasetType;

+ (instancetype)mnistWithDatasetType:(MNISTDatasetType)datasetType;

+ (NSRange)rangeWithMoved:(size_t)moved fromCorsor:(size_t *)corsor;

@end
