//
//  Parameter.m
//  Training
//
//  Created by Naruki Chigira on 2019/07/27.
//  Copyright © 2019 Naruki Chigira. All rights reserved.
//

#import "Parameter.h"

@interface Parameter()

@property (readwrite) NSInteger count;

@property (nonatomic, retain) NSData *data;

@end

@implementation Parameter

- (nullable instancetype)initFromFileURL:(NSURL *)fileURL {
    self = [super init];
    if (self) {
        NSData *data = [NSData dataWithContentsOfURL:fileURL];
        if (data == nil) {
            NSLog(@"File is not found at %@", fileURL);
            return nil;
        }
        [data getBytes:&_count range:NSMakeRange(0, sizeof(int32_t))];

        NSRange range = NSMakeRange(sizeof(int32_t), sizeof(Float32)*self.count);
        if (range.location + range.length > data.length) {
            NSLog(@"Invalid data format. (Actual data length: %ld, Applied length: (%ld, %ld))", data.length, range.location, range.length);
            return nil;
        }
        NSData *parameters = [data subdataWithRange:range];
        self.data = parameters.copy;
    }
    return self;
}

- (nonnull instancetype)initWithValues:(Float32 *)values count:(NSInteger)count {
    self = [super init];
    if (self) {
        self.count = count;
        NSData *data = [NSData dataWithBytes:values length:sizeof(Float32)*count];
        self.data = data;
    }
    return self;
}

+ (nullable instancetype)parameterFromFileURL:(NSURL *)fileURL {
    return [[Parameter alloc] initFromFileURL:fileURL];
}

+ (instancetype)parameterWithValues:(Float32 *)values count:(NSInteger)count {
    return [[Parameter alloc] initWithValues:values count:count];
}

+ (nonnull instancetype)randomParameterWithCount:(NSInteger)count {
    NSInteger length = sizeof(Float32)*count;
    Float32 *parameters = malloc(length);
    for (int i = 0; i < count; i++) {
        parameters[i] = (Float32)arc4random() / (Float32)UINT32_MAX;
    }
    return [Parameter parameterWithValues:parameters count:count];
}

- (Float32 *)values {
    return (Float32 *)[self.data bytes];
}

- (BOOL)writeToFileURL:(NSURL *)fileURL {
    NSMutableData *data = [NSMutableData data];

    NSData *countData = [NSData dataWithBytes:&_count length:sizeof(int32_t)];
    [data appendData:countData];

    NSData *valuesData = [NSData dataWithBytes:self.values length:sizeof(Float32)*_count];
    [data appendData:valuesData];

    return [data writeToURL:fileURL atomically:true];
}

@end
