//
//  MNIST+Training.h
//  Training
//
//  Created by Naruki Chigira on 2018/12/12.
//  Copyright © 2018 Naruki Chigira. All rights reserved.
//

@import MetalPerformanceShaders;
#import <Foundation/Foundation.h>
#import "../MNIST/MNIST.h"

@interface MNIST (Training)

- (nonnull MPSImageBatch *)imageBatchWithRange:(NSRange)range;

- (nonnull MPSImageBatch *)imageBatchWithIteration:(NSUInteger)iteration batchSize:(NSUInteger)batchSize;

- (nonnull MPSStateBatch *)stateBatchWithRange:(NSRange)range;

- (nonnull MPSStateBatch *)stateBatchWithIteration:(NSUInteger)iteration batchSize:(NSUInteger)batchSize;

@end
