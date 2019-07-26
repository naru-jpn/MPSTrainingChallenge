//
//  CNNConvolutionDataSource.h
//  Training
//
//  Created by Naruki Chigira on 2018/12/07.
//  Copyright © 2018 Naruki Chigira. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MetalPerformanceShaders;

/// Representing shape of convolutional network layer.
@interface CNNConvolutionDataShape : NSObject<NSCopying>

/// Initializes information representing shape of convolutional network layer.
///
/// @param kernelWidth Kernel Width
/// @param kernelHeight Kernel Height
/// @param inputFeatureChannels Number feature channels in input of this layer.
/// @param outputFeatureChannels Number feature channels from output of this layer.
/// @param strideX The output stride (downsampling factor) in the x dimension.
/// @param strideY The output stride (downsampling factor) in the y dimension.
- (instancetype)initWithKernelWidth:(size_t)kernelWidth
                       kernelHeight:(size_t)kernelHeight
               inputFeatureChannels:(size_t)inputFeatureChannels
              outputFeatureChannels:(size_t)outputFeatureChannels
                            strideX:(size_t)strideX
                            strideY:(size_t)strideY;

/// Creates information representing shape of convolutional network layer.
///
/// @param kernelWidth Kernel Width
/// @param kernelHeight Kernel Height
/// @param inputFeatureChannels Number feature channels in input of this layer.
/// @param outputFeatureChannels Number feature channels from output of this layer.
/// @param strideX The output stride (downsampling factor) in the x dimension.
/// @param strideY The output stride (downsampling factor) in the y dimension.
+ (instancetype)shapeWithKernelWidth:(size_t)kernelWidth
                        kernelHeight:(size_t)kernelHeight
                inputFeatureChannels:(size_t)inputFeatureChannels
               outputFeatureChannels:(size_t)outputFeatureChannels
                             strideX:(size_t)strideX
                             strideY:(size_t)strideY;

/// Kernel Width
- (size_t)kernelWidth;

/// Kernel Height
- (size_t)kernelHeight;

/// Number feature channels in input of this layer.
- (size_t)inputFeatureChannels;

/// Number feature channels from output of this layer.
- (size_t)outputFeatureChannels;

/// The output stride (downsampling factor) in the x dimension.
- (size_t)strideX;

/// The output stride (downsampling factor) in the y dimension.
- (size_t)strideY;

@end


/// Properties for CNNConvolutionDataSource.
@interface CNNConvolutionDataSourceProperty : NSObject<NSCopying>

/// Initializes information representing shape of convolutional network layer.
///
/// @param shape Representing shape of convolutional network layer.
/// @param biasFileName File name containing bias data.
/// @param weightsFileName File name containing weights data. Sets "dat" if value is nil.
/// @param fileExtension File extension of data file.
/// @param label Label for layer.
- (instancetype)initWithShape:(nonnull CNNConvolutionDataShape *)shape
                 biasFileName:(nonnull NSString *)biasFileName
              weightsFileName:(nonnull NSString *)weightsFileName
                fileExtension:(nullable NSString *)fileExtension
                        label:(nullable NSString *)label;


/// Creates information representing shape of convolutional network layer.
///
/// @param shape Representing shape of convolutional network layer.
/// @param biasFileName File name containing bias data.
/// @param weightsFileName File name containing weights data. Sets "dat" if value is nil.
/// @param fileExtension File extension of data file.
/// @param label Label for layer.
+ (instancetype)propertyWithShape:(nonnull CNNConvolutionDataShape *)shape
                     biasFileName:(nonnull NSString *)biasFileName
                  weightsFileName:(nonnull NSString *)weightsFileName
                    fileExtension:(nullable NSString *)fileExtension
                            label:(nullable NSString *)label;

/// Representing shape of convolutional network layer.
@property (nonatomic, retain, nonnull) CNNConvolutionDataShape *shape;

/// File name containing bias data.
@property (nonatomic, copy, nonnull) NSString *biasFileName;

/// File name containing weights data.
@property (nonatomic, copy, nonnull) NSString *weightsFileName;

/// File extension of data file. Default value is "dat".
@property (nonatomic, copy, nonnull) NSString *fileExtension;

/// Label for layer.
@property (nonatomic, copy, nullable) NSString *label;

@end


/// Data source class for MPSCNNConvolutionDataSource.
@interface CNNConvolutionDataSource : NSObject<MPSCNNConvolutionDataSource>

@property (nonatomic, assign, nonnull, readonly) id <MTLCommandQueue> commandQueue;

/// Property to provide data for layer.
@property (nonatomic, retain, nonnull, readonly) CNNConvolutionDataSourceProperty *property;

/// Initializes data source.
///
/// @param property Property to provide data for layer.
- (instancetype _Nonnull)initWithProperty:(nonnull CNNConvolutionDataSourceProperty *)property
                                   device:(nonnull id<MTLDevice>)device
                             commandQueue:(nonnull id <MTLCommandQueue>)commandQueue;

/// Creates data source.
///
/// @param property Property to provide data for layer.
+ (instancetype _Nonnull)dataSourceWithProperty:(nonnull CNNConvolutionDataSourceProperty *)property
                                         device:(nonnull id<MTLDevice>)device
                                   commandQueue:(nonnull id <MTLCommandQueue>)commandQueue;


@end
