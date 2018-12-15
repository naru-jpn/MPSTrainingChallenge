//
//  MNISTImage.h
//  Training
//
//  Created by Naruki Chigira on 2018/12/10.
//  Copyright © 2018 Naruki Chigira. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MNISTImage : NSObject

@property (nonatomic, retain, readonly, nonnull) NSData *data;

- (instancetype)initWithData:(NSData *)data;

+ (instancetype)imageWithData:(NSData *)data;

- (instancetype)initWithValues:(UInt8 *)values;

+ (instancetype)imageWithValues:(UInt8 *)values;

- (NSArray<NSNumber *> *)values;

@end
