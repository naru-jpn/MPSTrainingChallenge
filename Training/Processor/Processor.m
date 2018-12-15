//
//  Processor.m
//  Processor
//
//  Created by Naruki Chigira on 2018/12/12.
//  Copyright © 2018 Naruki Chigira. All rights reserved.
//

@import MetalPerformanceShaders;
@import Accelerate;
#import "Processor.h"
#import "../Processor/MNIST+Training.h"
#import "../AppDelegate.h"

@interface Processor ()
@property (strong, nonatomic) id<MTLCommandQueue> commandQueue;
@property (nonatomic) dispatch_semaphore_t semaphore_train;
@property (nonatomic) dispatch_semaphore_t semaphore_test;
@end

@implementation Processor

- (instancetype)init {
    self = [super init];
    if (self) {
        self.commandQueue = [AppDelegate.instance.GPUDevice newCommandQueue];
        self.semaphore_train = dispatch_semaphore_create(2);
        self.semaphore_test = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)trainGraph:(Graph *)graph training:(MNIST *)training test:(MNIST *)test epocs:(NSUInteger)epocs iterationsPerEpoc:(NSUInteger)iterationsPerEpoc batchSize:(NSUInteger)batchSize {
    if (epocs*iterationsPerEpoc*batchSize > training.samples.count) {
        [NSException raise:@"TooLargeParameterSetForTrainingGraph" format:@"epocs: %ld, iterationsPerEpoc: %ld, batchSize: %ld", epocs, iterationsPerEpoc, batchSize];
    }
    
    id<MTLCommandBuffer> latestCommandBuffer;
    for (NSInteger j=0; j<epocs; j++) {
        for (NSInteger i=0; i<iterationsPerEpoc; i++) {
            NSInteger iteration = iterationsPerEpoc*j + i;
            latestCommandBuffer = [self trainGraph:graph.training mnist:training iteration:iteration batchSize:batchSize];
        }
        [latestCommandBuffer waitUntilCompleted];
        
        // TODO: Inference
    }
}

- (void)inferenceMNIST:(MNIST *)mnist range:(NSRange)range graph:(MPSNNGraph *)graph {
    
    MPSImageBatch *imageBatch = [mnist imageBatchWithRange:range];
    [graph executeAsyncWithSourceImages:imageBatch completionHandler:^(MPSImage *result, NSError *error){
        
        float16_t results[12] = {};
        MTLRegion region = MTLRegionMake3D(0, 0, 0, 1, 1, 1);
        for (NSInteger i=0; i<=2; i++) {
            [result.texture getBytes:&(results[i*4]) bytesPerRow:sizeof(float16_t)*4 bytesPerImage:sizeof(float16_t)*4 fromRegion:region mipmapLevel:0 slice:i];
        }
        printf("%s", results);
    }];
}

- (id<MTLCommandBuffer>)trainGraph:(MPSNNGraph *)graph mnist:(MNIST *)mnist iteration:(NSUInteger)iteration batchSize:(NSUInteger)batchSize {
    NSMutableArray<MPSImageBatch *> *intermediateImages = [NSMutableArray array];
    NSMutableArray<MPSStateBatch *> *intermediateStates = [NSMutableArray array];
    
    dispatch_semaphore_wait(_semaphore_train, DISPATCH_TIME_FOREVER);
    id<MTLCommandBuffer> commandBuffer = _commandQueue.commandBuffer;
    MPSImageBatch *imageBatch = [mnist imageBatchWithIteration:iteration batchSize:batchSize];
    MPSStateBatch *stateBatch = [mnist stateBatchWithIteration:iteration batchSize:batchSize];
    [graph encodeBatchToCommandBuffer:commandBuffer sourceImages:@[imageBatch] sourceStates:@[stateBatch] intermediateImages:intermediateImages destinationStates:intermediateStates];
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer) {
        dispatch_semaphore_signal(self->_semaphore_train);
    }];
    [commandBuffer commit];
    
    return commandBuffer;
}

@end
