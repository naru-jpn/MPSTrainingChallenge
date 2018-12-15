//
//  MNISTPreviewViewController.h
//  Training
//
//  Created by Naruki Chigira on 2018/12/11.
//  Copyright © 2018 Naruki Chigira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../MNISTSample.h"

@interface MNISTPreviewViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, retain, nullable) NSArray<MNISTSample *> *samples;

- (IBAction)onCloseClicked:(id)sender;

@end
