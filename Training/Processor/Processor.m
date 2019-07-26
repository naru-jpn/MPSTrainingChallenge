//
//  Processor.m
//  Processor
//
//  Created by Naruki Chigira on 2018/12/12.
//  Copyright © 2018 Naruki Chigira. All rights reserved.
//

@import Metal;
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
        self.commandQueue = AppDelegate.instance.CommandQueue;
        self.semaphore_train = dispatch_semaphore_create(1);
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
        
        NSLog(@"Complete epoc: %ld", j+1);

        [self inferenceMNIST:test size:1000 graph:graph.inference];
    }
}

- (id<MTLCommandBuffer>)trainGraph:(MPSNNGraph *)graph mnist:(MNIST *)mnist iteration:(NSUInteger)iteration batchSize:(NSUInteger)batchSize {
    NSMutableArray<MPSImageBatch *> *intermediateImages = [NSMutableArray array];
    NSMutableArray<MPSStateBatch *> *intermediateStates = [NSMutableArray array];

    dispatch_semaphore_wait(_semaphore_train, DISPATCH_TIME_FOREVER);
    id<MTLCommandBuffer> commandBuffer = _commandQueue.commandBuffer;
    MPSImageBatch *imageBatch = [mnist imageBatchWithIteration:iteration batchSize:batchSize];
    MPSStateBatch *stateBatch = [mnist stateBatchWithIteration:iteration batchSize:batchSize];

    MPSImageBatch *outputBatch = @[];
    for (MPSState *state in stateBatch){
        outputBatch = [outputBatch arrayByAddingObject:[(MPSCNNLossLabels *)state lossImage]];
    }
    MPSImageBatch *returnBatch = [graph encodeBatchToCommandBuffer:commandBuffer sourceImages:@[imageBatch] sourceStates:@[stateBatch] intermediateImages:intermediateImages destinationStates:intermediateStates];
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer) {
        dispatch_semaphore_signal(self->_semaphore_train);
//        float loss = [self getTotalLoss:outputBatch];
//        NSLog(@"Total Loss(%ld): %f", iteration, loss);
    }];

    // MARK: これ必要？
    MPSImageBatchSynchronize(returnBatch, commandBuffer);
    MPSImageBatchSynchronize(outputBatch, commandBuffer);

    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];

    return commandBuffer;
}

- (float)getTotalLoss:(MPSImageBatch *)imageBatch {
    NSUInteger batchSize = imageBatch.count;
    float totalLoss = 0.0;
    for (MPSImage *image in imageBatch) {
        float value[1] = {0};
        assert(image.width * image.height * image.featureChannels == 1);
        [image readBytes:(void *)value dataLayout:(MPSDataLayoutHeightxWidthxFeatureChannels) imageIndex:0];
        totalLoss += value[0] / (float)batchSize;
    }
    return totalLoss;
}

- (void)inferenceMNIST:(MNIST *)mnist size:(UInt32)size graph:(MPSNNGraph *)graph {
    [graph reloadFromDataSources];

    dispatch_semaphore_wait(_semaphore_train, DISPATCH_TIME_FOREVER);
    id<MTLCommandBuffer> commandBuffer = _commandQueue.commandBuffer;
    MPSImageBatch *imageBatch = [mnist testImageBatchWithLength:size];
    MPSImageBatch *outputBatch = [graph encodeBatchToCommandBuffer:commandBuffer sourceImages:@[imageBatch] sourceStates:nil intermediateImages:nil destinationStates:nil];

    MPSImageBatchSynchronize(outputBatch, commandBuffer);

    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer) {
        dispatch_semaphore_signal(self->_semaphore_train);
        __block NSInteger countCorrectInference = 0;
        [outputBatch enumerateObjectsUsingBlock:^(MPSImage * _Nonnull outputImage, NSUInteger idx, BOOL * _Nonnull stop) {
            __fp16 results[12] = {};
            MTLRegion region = MTLRegionMake3D(0, 0, 0, 1, 1, 1);
            for (NSInteger i=0; i<=2; i++) {
                [outputImage.texture getBytes:&(results[i*4]) bytesPerRow:sizeof(__fp16)*4 bytesPerImage:sizeof(__fp16)*4 fromRegion:region mipmapLevel:0 slice:i];
            }
            __fp16 max = -1.0;
            NSInteger maxIndex = 0;
            for (NSInteger i=0; i<10; i++) {
                __fp16 value = *(results+i);
                if (value > max) {
                    maxIndex = i;
                    max = value;
                }
            }
            NSInteger answer = [imageBatch[idx].label intValue];
            NSInteger predicate = [[NSString stringWithFormat:@"%ld", maxIndex] intValue];
//            NSLog(@"Predicate: %ld (Correct: %ld)", predicate, answer);
            if (predicate == answer) {
                countCorrectInference++;
            }
        }];
        NSLog(@"Accuracy: %6.2lf%%", (float)countCorrectInference/(float)size*100);
    }];

    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
}

@end
