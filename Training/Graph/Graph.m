//
//  Graph.m
//  Training
//
//  Created by Naruki Chigira on 2018/12/08.
//  Copyright © 2018 Naruki Chigira. All rights reserved.
//

@import MetalPerformanceShaders;
#import "Graph.h"
#import "CNNConvolutionDataSource.h"
#import "../AppDelegate.h"

@interface Graph ()
@property (strong, nonatomic) MPSNNImageNode *source;
@property (strong, nonatomic) MPSCNNFullyConnectedNode *fullyConnectedNode;
@property (strong, nonatomic) MPSCNNSoftMaxNode *softMaxNode;
@property (strong, nonatomic) MPSCNNLossNode *lossNode;
@property (strong, nonatomic) MPSNNGradientFilterNode *softMaxGradientNode;
@property (strong, nonatomic) MPSNNGradientFilterNode *fullyConnectedGradientNode;
@property (strong, nonatomic) id<MPSCNNConvolutionDataSource> convolutionDataSource;
@end

@implementation Graph

- (instancetype)init {
    self = [super init];
    if (self) {
        [self buildGraphs];
    }
    return self;
}

- (void)buildGraphs {
    self.convolutionDataSource = [self fullyConnectedNodeDataSourceWithDevice:AppDelegate.instance.GPUDevice];
    
    self.source = [MPSNNImageNode nodeWithHandle:nil];
    self.fullyConnectedNode = [MPSCNNFullyConnectedNode nodeWithSource:_source weights:_convolutionDataSource];
    self.softMaxNode = [MPSCNNSoftMaxNode nodeWithSource:_fullyConnectedNode.resultImage];
    self.lossNode = [MPSCNNLossNode nodeWithSource:_softMaxNode.resultImage lossDescriptor:self.lossDescriptor];
    self.softMaxGradientNode = [_softMaxNode gradientFilterWithSource:_lossNode.resultImage];
    self.fullyConnectedGradientNode = [_fullyConnectedNode gradientFilterWithSource:_softMaxGradientNode.resultImage];

// +[MPSNNGraph graphWithDevice:resultImages:resultsAreNeeded:]: unrecognized selector sent to class *****...
//    NSArray<MPSNNImageNode *> *resultImages = @[_fullyConnectedGradientNode.resultImage, _softMaxNode.resultImage];
//    BOOL *resultsAreNeeded = {NO, YES};
//    self.training = [MPSNNGraph graphWithDevice:AppDelegate.instance.GPUDevice resultImages:resultImages resultsAreNeeded:resultsAreNeeded];
    
    self.training = [MPSNNGraph graphWithDevice:AppDelegate.instance.GPUDevice resultImage:_fullyConnectedGradientNode.resultImage resultImageIsNeeded:NO];
    self.inference = [MPSNNGraph graphWithDevice:AppDelegate.instance.GPUDevice resultImage:_softMaxNode.resultImage resultImageIsNeeded:YES];
}

- (id<MPSCNNConvolutionDataSource>)fullyConnectedNodeDataSourceWithDevice:(id<MTLDevice>)device {
    NSString *biasFileName = @"fully_connected_bias";
    NSString *weightsFileName = @"fully_connected_weights";
    CNNConvolutionDataShape *shape = [CNNConvolutionDataShape shapeWithKernelWidth:28 kernelHeight:28 inputFeatureChannels:1 outputFeatureChannels:10 strideX:1 strideY:1];
    CNNConvolutionDataSourceProperty *property = [CNNConvolutionDataSourceProperty propertyWithShape:shape biasFileName:biasFileName weightsFileName:weightsFileName fileExtension:@"dat" label:@"fullyConnectedNode"];
    id<MPSCNNConvolutionDataSource> dataSource = [CNNConvolutionDataSource dataSourceWithProperty:property device:device];
    return dataSource;
}

- (MPSCNNLossDescriptor *)lossDescriptor {
    MPSCNNLossType lossType = MPSCNNLossTypeSoftMaxCrossEntropy;
    MPSCNNReductionType reductionType = MPSCNNReductionTypeMean;
    MPSCNNLossDescriptor *descriptor = [MPSCNNLossDescriptor cnnLossDescriptorWithType:lossType reductionType:reductionType];
    return descriptor;
}

@end
