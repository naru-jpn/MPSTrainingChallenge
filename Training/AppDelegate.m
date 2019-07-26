//
//  AppDelegate.m
//  Training
//
//  Created by Naruki Chigira on 2018/12/07.
//  Copyright © 2018 Naruki Chigira. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (strong, nonatomic, nonnull) id<MTLDevice> GPUDevice;
@property (strong, nonatomic, nonnull) id<MTLCommandQueue> CommandQueue;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.GPUDevice = MTLCreateSystemDefaultDevice();
    self.CommandQueue = _GPUDevice.newCommandQueue;
    return YES;
}

+ (instancetype)instance {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end
