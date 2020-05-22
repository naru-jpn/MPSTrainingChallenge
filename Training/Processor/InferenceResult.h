//
//  InferenceResult.h
//  Training
//
//  Created by Naruki Chigira on 2019/07/28.
//  Copyright © 2019 Naruki Chigira. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface InferenceResult : NSObject

@property (readonly) NSInteger countTrials;

@property (readonly) NSInteger countCorrect;

@property (readonly) float accuracy;

+ (nonnull instancetype)resultWithCountTrials:(NSInteger)countTrials countCorrect:(NSInteger)countCorrect;

@end

NS_ASSUME_NONNULL_END
