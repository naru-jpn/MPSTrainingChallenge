//
//  Parameter.h
//  Training
//
//  Created by Naruki Chigira on 2019/07/27.
//  Copyright © 2019 Naruki Chigira. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Parameter : NSObject

@property (readonly) NSInteger count;

@property (readonly, nonatomic) NSData *data;

@property (readonly, nonatomic, nonnull) Float32 *values;

- (nullable instancetype)initFromFileURL:(NSURL *)fileURL;

+ (nullable instancetype)parameterFromFileURL:(NSURL *)fileURL;

- (nonnull instancetype)initWithValues:(Float32 *)values count:(NSInteger)count;

+ (nonnull instancetype)parameterWithValues:(Float32 *)values count:(NSInteger)count;

+ (nonnull instancetype)randomParameterWithCount:(NSInteger)count;

- (BOOL)writeToFileURL:(NSURL *)fileURL;

@end

NS_ASSUME_NONNULL_END
