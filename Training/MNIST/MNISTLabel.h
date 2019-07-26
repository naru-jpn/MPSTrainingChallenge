//
//  MNISTLabel.h
//  Training
//
//  Created by Naruki Chigira on 2018/12/10.
//  Copyright © 2018 Naruki Chigira. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MNISTLabel : NSObject

@property (nonatomic, retain, readonly, nonnull) NSData *data;

- (nonnull instancetype)initWithData:(nonnull NSData *)data;

+ (nonnull instancetype)labelWithData:(nonnull NSData *)data;

- (nonnull instancetype)initWithValue:(nonnull UInt8 *)value;

+ (nonnull instancetype)labelWithValue:(nonnull UInt8 *)value;

- (UInt8)value;

/// Return data formated floating point for label value.
/// (ex. 3 -> [0,0,0,1,0,0,0,0,0,0])
- (nonnull NSData *)alignedData;

@end
