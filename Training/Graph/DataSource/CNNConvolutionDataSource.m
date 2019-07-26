//
//  CNNConvolutionDataSource.m
//  Training
//
//  Created by Naruki Chigira on 2018/12/07.
//  Copyright © 2018 Naruki Chigira. All rights reserved.
//

@import Darwin;
#import "CNNConvolutionDataSource.h"
#import "../../AppDelegate.h"

@implementation CNNConvolutionDataShape {
    size_t _kernelWidth;
    size_t _kernelHeight;
    size_t _inputFeatureChannels;
    size_t _outputFeatureChannels;
    size_t _strideX;
    size_t _strideY;
}

- (instancetype)initWithKernelWidth:(size_t)kernelWidth kernelHeight:(size_t)kernelHeight inputFeatureChannels:(size_t)inputFeatureChannels outputFeatureChannels:(size_t)outputFeatureChannels strideX:(size_t)strideX strideY:(size_t)strideY {
    self = [super init];
    if (self) {
        _kernelWidth = kernelWidth;
        _kernelHeight = kernelHeight;
        _inputFeatureChannels = inputFeatureChannels;
        _outputFeatureChannels = outputFeatureChannels;
        _strideX = strideX;
        _strideY = strideY;
    }
    return self;
}

+ (instancetype)shapeWithKernelWidth:(size_t)kernelWidth kernelHeight:(size_t)kernelHeight inputFeatureChannels:(size_t)inputFeatureChannels outputFeatureChannels:(size_t)outputFeatureChannels strideX:(size_t)strideX strideY:(size_t)strideY {
    return [[CNNConvolutionDataShape alloc] initWithKernelWidth:kernelWidth
                                                   kernelHeight:kernelHeight
                                           inputFeatureChannels:inputFeatureChannels
                                          outputFeatureChannels:outputFeatureChannels
                                                        strideX:strideX
                                                        strideY:strideY];
}

- (size_t)kernelWidth {
    return _kernelWidth;
}

- (size_t)kernelHeight {
    return _kernelHeight;
}

- (size_t)inputFeatureChannels {
    return _inputFeatureChannels;
}

- (size_t)outputFeatureChannels {
    return _outputFeatureChannels;
}

- (size_t)strideX {
    return _strideX;
}

- (size_t)strideY {
    return _strideY;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return [CNNConvolutionDataShape shapeWithKernelWidth:_kernelWidth
                                            kernelHeight:_kernelHeight
                                    inputFeatureChannels:_inputFeatureChannels
                                   outputFeatureChannels:_outputFeatureChannels
                                                 strideX:_strideX
                                                 strideY:_strideY];
}

@end


@implementation CNNConvolutionDataSourceProperty

- (instancetype)init {
    self = [super init];
    if (self) {
        self.shape = [[CNNConvolutionDataShape alloc] initWithKernelWidth:0 kernelHeight:0 inputFeatureChannels:0 outputFeatureChannels:0 strideX:0 strideY:0];
        self.biasFileName = @"";
        self.weightsFileName = @"";
        self.fileExtension = @"dat";
        self.label = nil;
    }
    return self;
}

- (instancetype)initWithShape:(nonnull CNNConvolutionDataShape *)shape
                biasFileName:(nonnull NSString *)biasFileName
             weightsFileName:(nonnull NSString *)weightsFileName
               fileExtension:(nullable NSString *)fileExtension
                       label:(nullable NSString *)label {
    self = [super init];
    if (self) {
        self.shape = shape;
        self.biasFileName = biasFileName;
        self.weightsFileName = weightsFileName;
        self.fileExtension = fileExtension != nil ? fileExtension : @"dat";
        self.label = nil;
    }
    return self;
}

+ (instancetype)propertyWithShape:(CNNConvolutionDataShape *)shape biasFileName:(NSString *)biasFileName weightsFileName:(NSString *)weightsFileName fileExtension:(NSString *)fileExtension label:(NSString *)label {
    return [[CNNConvolutionDataSourceProperty alloc] initWithShape:shape
                                                      biasFileName:biasFileName
                                                   weightsFileName:weightsFileName
                                                     fileExtension:fileExtension
                                                             label:label];
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return [CNNConvolutionDataSourceProperty propertyWithShape:_shape.copy
                                                  biasFileName:self.biasFileName
                                               weightsFileName:self.weightsFileName
                                                 fileExtension:self.fileExtension
                                                         label:self.label];
}

@end


@interface CNNConvolutionDataSource ()
@property (nonatomic, assign) id<MTLDevice> device;
@property (nonatomic, retain) CNNConvolutionDataSourceProperty *property;
@property (nonatomic, retain) MPSNNOptimizerStochasticGradientDescent *optimizer;
@property (nonatomic, assign, nonnull) id <MTLCommandQueue> commandQueue;
@end

@implementation CNNConvolutionDataSource {
    MPSVectorDescriptor *_weightsDescriptor;
    MPSVector *_weightsVector;
    MPSVectorDescriptor *_biasDescriptor;
    MPSVector *_biasVector;
    Float32 *_weightsPointer;
    Float32 *_biasPointer;
    MPSCNNConvolutionWeightsAndBiasesState *_weightsAndBiasState;
}

- (instancetype)initWithProperty:(CNNConvolutionDataSourceProperty *)property device:(id<MTLDevice>)device commandQueue:(id<MTLCommandQueue>)commandQueue {
    self = [super init];
    if (self) {
        self.property = property;
        self.optimizer = [[MPSNNOptimizerStochasticGradientDescent alloc] initWithDevice:device learningRate:0.01f];
        self.commandQueue = commandQueue;

        const char *path_bias = [[NSBundle mainBundle] pathForResource:_property.biasFileName ofType:_property.fileExtension].UTF8String;
        int32_t fd_b = open(path_bias, O_RDONLY, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH);
        if (fd_b == -1) {
            [NSException raise:@"FailedToOpenBiasParameterFile" format:@"Failed to open file named %@.%@", _property.biasFileName, _property.fileExtension];
        }

        const char *path_weights = [[NSBundle mainBundle] pathForResource:_property.weightsFileName ofType:_property.fileExtension].UTF8String;
        int32_t fd_w = open(path_weights, O_RDONLY, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH);
        if (fd_w == -1) {
            [NSException raise:@"FailedToOpenWeightParameterFile" format:@"Failed to open file named %@.%@", _property.weightsFileName, _property.fileExtension];
        }

        float *biasPointer = (float *)mmap(NULL, [self biasDataLength], PROT_READ, MAP_FILE | MAP_SHARED, fd_b, 0);
        float *weightsPointer = (float *)mmap(NULL, [self weightsDataLength], PROT_READ, MAP_FILE | MAP_SHARED, fd_w, 0);

        _biasDescriptor = [MPSVectorDescriptor vectorDescriptorWithLength:[self biasLength] dataType:MPSDataTypeFloat32];
        _biasVector = [[MPSVector alloc] initWithDevice:device descriptor:_biasDescriptor];
        _biasPointer = (float *)_biasVector.data.contents;
        memcpy(_biasPointer, biasPointer, [self biasDataLength]);

        _weightsDescriptor = [MPSVectorDescriptor vectorDescriptorWithLength:[self weightsLength] dataType:MPSDataTypeFloat32];
        _weightsVector = [[MPSVector alloc] initWithDevice:device descriptor:_weightsDescriptor];
        _weightsPointer = (float *)_weightsVector.data.contents;
        memcpy(_weightsPointer, weightsPointer, [self weightsDataLength]);

        munmap(biasPointer, [self biasDataLength]);
        munmap(weightsPointer, [self weightsDataLength]);

        _weightsAndBiasState = [[MPSCNNConvolutionWeightsAndBiasesState alloc] initWithWeights:_weightsVector.data biases:_biasVector.data];
    }
    return self;
}

+ (instancetype)dataSourceWithProperty:(CNNConvolutionDataSourceProperty *)property device:(id<MTLDevice>)device commandQueue:(id<MTLCommandQueue>)commandQueue {
    return [[CNNConvolutionDataSource alloc] initWithProperty:property device:device commandQueue:commandQueue];
}

- (size_t)biasLength {
    return _property.shape.outputFeatureChannels;
}

- (size_t)biasDataLength {
    return self.biasLength*sizeof(Float32);
}

- (size_t)weightsLength {
    size_t kernelWidth = _property.shape.kernelWidth;
    size_t kernelHeight = _property.shape.kernelHeight;
    size_t inputFeatureChannels = _property.shape.inputFeatureChannels;
    size_t outputFeatureChannels = _property.shape.outputFeatureChannels;
    return inputFeatureChannels*kernelWidth*kernelHeight*outputFeatureChannels;
}

- (size_t)weightsDataLength {
    return self.weightsLength*sizeof(Float32);
}

- (NSString * _Nullable)label {
    return _property.label;
}

- (BOOL)load {
    [self checkpoint];
    return TRUE;
}

- (void)purge {
//    munmap(_biasPointer, [self biasDataLength]);
//    munmap(_weightsPointer, [self weightsDataLength]);
}

- (float *)biasTerms {
    return _biasPointer;
}

- (void * _Nonnull)weights {
    return _weightsPointer;
}

- (MPSDataType)dataType {
    return MPSDataTypeFloat32;
}

- (MPSCNNConvolutionDescriptor * _Nonnull)descriptor {
    size_t kernelWidth = _property.shape.kernelWidth;
    size_t kernelHeight = _property.shape.kernelHeight;
    size_t inputFeatureChannels = _property.shape.inputFeatureChannels;
    size_t outputFeatureChannels = _property.shape.outputFeatureChannels;
    
    MPSCNNConvolutionDescriptor *descriptor = [MPSCNNConvolutionDescriptor cnnConvolutionDescriptorWithKernelWidth:kernelWidth kernelHeight:kernelHeight inputFeatureChannels:inputFeatureChannels outputFeatureChannels:outputFeatureChannels];
    descriptor.strideInPixelsX = _property.shape.strideX;
    descriptor.strideInPixelsY = _property.shape.strideY;
    descriptor.groups = 1;
    return descriptor;
}

- (MPSCNNConvolutionWeightsAndBiasesState *)updateWithCommandBuffer:(id<MTLCommandBuffer>)commandBuffer gradientState:(MPSCNNConvolutionGradientState *)gradientState sourceState:(MPSCNNConvolutionWeightsAndBiasesState *)sourceState {
    MPSStateBatchIncrementReadCount(@[sourceState], 1);
    [_optimizer encodeToCommandBuffer:commandBuffer convolutionGradientState:gradientState convolutionSourceState:sourceState inputMomentumVectors:nil resultState:_weightsAndBiasState];
    return _weightsAndBiasState;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return [CNNConvolutionDataSource dataSourceWithProperty:_property.copy device:_device commandQueue:_commandQueue];
}

- (void)checkpoint {
    @autoreleasepool{
        id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer]; //[MPSCommandBuffer commandBufferFromCommandQueue:_commandQueue];
        [_weightsAndBiasState synchronizeOnCommandBuffer:commandBuffer];
        [commandBuffer commit];
        [commandBuffer waitUntilCompleted];
    }
}

@end
