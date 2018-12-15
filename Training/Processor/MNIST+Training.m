//
//  MNIST+Training.m
//  Training
//
//  Created by Naruki Chigira on 2018/12/12.
//  Copyright © 2018 Naruki Chigira. All rights reserved.
//

@import CoreGraphics;
#import "MNIST+Training.h"
#import "../AppDelegate.h"

@implementation MNIST (Training)

- (MPSImageBatch *)imageBatchWithRange:(NSRange)range {
    NSArray<MNISTSample *> *samples = [self.samples subarrayWithRange:range];
    NSMutableArray<MPSImage *> *results = [NSMutableArray new];
    for (NSInteger i=0; i<samples.count; i++) {
        MPSImage *image = [self imageWithSample:samples[i]];
        image.label = @(i).description;
        [results addObject:image];
    }
    return results;
}

- (MPSImageBatch *)imageBatchWithIteration:(NSUInteger)iteration batchSize:(NSUInteger)batchSize {
    NSRange range = NSMakeRange(iteration*batchSize, batchSize);
    return [self imageBatchWithRange:range];
}

- (MPSStateBatch *)stateBatchWithRange:(NSRange)range {
    NSArray<MNISTSample *> *samples = [self.samples subarrayWithRange:range];
    NSMutableArray<MPSState *> *results = [NSMutableArray new];
    for (NSInteger i=0; i<samples.count; i++) {
        MPSState *state = [self stateWithSample:samples[i]];
        state.label = @(i).description;
        [results addObject:state];
    }
    return results;
}

- (MPSStateBatch *)stateBatchWithIteration:(NSUInteger)iteration batchSize:(NSUInteger)batchSize {
    NSRange range = NSMakeRange(iteration*batchSize, batchSize);
    return [self stateBatchWithRange:range];
}

- (nonnull MPSImage *)imageWithSample:(MNISTSample *)sample {
    size_t width = MNIST_IMAGE_WIDTH;
    size_t height = MNIST_IMAGE_HEIGHT;
    
    NSData *data = sample.image.data;
    
    size_t corsor = 0;
    size_t count = width*height;
    uint8_t *values = malloc(sizeof(uint8_t)*count);
    for (NSInteger i=0; i<count; i++) {
        uint8_t value;
        [data getBytes:&value range:[MNIST rangeWithMoved:sizeof(UInt8) fromCorsor:&corsor]];
        values[i] = value;
    }
    
    MTLTextureDescriptor *descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Unorm width:width height:height mipmapped:NO];
    id<MTLTexture> texture = [AppDelegate.instance.GPUDevice newTextureWithDescriptor:descriptor];
    MTLRegion region = MTLRegionMake2D(0, 0, width, height);
    [texture replaceRegion:region mipmapLevel:0 withBytes:values bytesPerRow:sizeof(uint8_t)*width];
    
    free(values);
    
    return [[MPSImage alloc] initWithTexture:texture featureChannels:1];
}

- (nonnull MPSState *)stateWithSample:(MNISTSample *)sample {
    NSData *alignedData = sample.label.alignedData.copy;
    MTLSize size = MTLSizeMake(1, 1, MNIST_LABELS);
    MPSCNNLossDataDescriptor *descriptor = [MPSCNNLossDataDescriptor cnnLossDataDescriptorWithData:alignedData layout:MPSDataLayoutFeatureChannelsxHeightxWidth size:size];
    return [[MPSCNNLossLabels alloc] initWithDevice:AppDelegate.instance.GPUDevice labelsDescriptor:descriptor];
}

@end
