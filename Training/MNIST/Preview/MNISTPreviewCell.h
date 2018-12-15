//
//  MNISTPreviewCell.h
//  Training
//
//  Created by Naruki Chigira on 2018/12/12.
//  Copyright © 2018 Naruki Chigira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../MNISTSample.h"
#import "../MNISTImageView.h"

@interface MNISTPreviewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet MNISTImageView *previewImageView;

@property (nonatomic, weak) IBOutlet UILabel *labelLabel;

- (void)setMNISTSample:(MNISTSample *)sample;

@end
