//
//  InferenceResult.m
//  Training
//
//  Created by Naruki Chigira on 2019/07/28.
//  Copyright © 2019 Naruki Chigira. All rights reserved.
//

#import "InferenceResult.h"

@interface InferenceResult()

@property (readwrite) NSInteger countTrials;
@property (readwrite) NSInteger countCorrect;
@property (readwrite) float accuracy;

@end


@implementation InferenceResult

- (nonnull instancetype)initWithCountTrials:(NSInteger)countTrials countCorrect:(NSInteger)countCorrect {
    self = [super init];
    if (self) {
        self.countTrials = countTrials;
        self.countCorrect = countCorrect;
        self.accuracy = (float)countCorrect/(float)countTrials*100;
    }
    return self;
}

+ (nonnull instancetype)resultWithCountTrials:(NSInteger)countTrials countCorrect:(NSInteger)countCorrect {
    return [[InferenceResult alloc] initWithCountTrials:countTrials countCorrect:countCorrect];
}

@end
