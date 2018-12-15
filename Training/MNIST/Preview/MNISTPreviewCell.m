//
//  MNISTPreviewCell.m
//  Training
//
//  Created by Naruki Chigira on 2018/12/12.
//  Copyright © 2018 Naruki Chigira. All rights reserved.
//

#import "MNISTPreviewCell.h"

@implementation MNISTPreviewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [_previewImageView.layer setShadowColor:[UIColor blackColor].CGColor];
    [_previewImageView.layer setShadowOpacity:0.3];
    [_previewImageView.layer setShadowOffset:CGSizeMake(0, 1)];
    [_previewImageView.layer setShadowRadius:1.6];
}

- (void)setMNISTSample:(MNISTSample *)sample {
    _previewImageView.image = sample.image;
    _labelLabel.text = @(sample.label.value).description;
}

@end
