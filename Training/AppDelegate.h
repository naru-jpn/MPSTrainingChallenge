//
//  AppDelegate.h
//  Training
//
//  Created by Naruki Chigira on 2018/12/07.
//  Copyright © 2018 Naruki Chigira. All rights reserved.
//

@import MetalPerformanceShaders;
#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic, nullable) UIWindow *window;

@property (strong, nonatomic, nonnull, readonly) id<MTLDevice> GPUDevice;

@property (strong, nonatomic, nonnull, readonly) id<MTLCommandQueue> CommandQueue;

+ (nonnull instancetype)instance;

@end

