//
//  Graph.h
//  Training
//
//  Created by Naruki Chigira on 2018/12/08.
//  Copyright © 2018 Naruki Chigira. All rights reserved.
//

@import MetalPerformanceShaders;
#import <Foundation/Foundation.h>

@interface Graph : NSObject

#pragma mark - Graphs

@property (strong, nonatomic) MPSNNGraph *training;

@property (strong, nonatomic) MPSNNGraph *inference;

#pragma mark - Layers

@property (strong, nonatomic, readonly) MPSNNImageNode *source;

@property (strong, nonatomic, readonly) MPSCNNFullyConnectedNode *fullyConnectedNode;

@property (strong, nonatomic, readonly) MPSCNNSoftMaxNode *softMaxNode;

@property (strong, nonatomic, readonly) MPSCNNLossNode *lossNode;

@property (strong, nonatomic, readonly) MPSNNGradientFilterNode *fullyConnectedGradientNode;

@property (strong, nonatomic, readonly) id<MPSCNNConvolutionDataSource> convolutionDataSource;

@end
