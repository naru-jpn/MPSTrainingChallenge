//
//  Processor.h
//  Processor
//
//  Created by Naruki Chigira on 2018/12/12.
//  Copyright © 2018 Naruki Chigira. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../MNIST/MNIST.h"
#import "../Graph/Graph.h"
#import "InferenceResult.h"

@interface Processor : NSObject

- (void)trainGraph:(Graph *)graph training:(MNIST *)training test:(MNIST *)test epocs:(NSUInteger)epocs iterationsPerEpoc:(NSUInteger)iterationsPerEpoc batchSize:(NSUInteger)batchSize;

- (void)inferenceMNIST:(MNIST *)mnist size:(UInt32)size graph:(MPSNNGraph *)graph completion:(void (^)(InferenceResult *))completion;

@end
