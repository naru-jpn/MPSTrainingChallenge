//
//  MNISTPreviewViewController.m
//  Training
//
//  Created by Naruki Chigira on 2018/12/11.
//  Copyright © 2018 Naruki Chigira. All rights reserved.
//

#import "MNISTPreviewViewController.h"
#import "MNISTPreviewCell.h"

@interface MNISTPreviewViewController ()

@end

@implementation MNISTPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView reloadData];
}

- (void)setSamples:(NSArray<MNISTSample *> *)samples {
    _samples = samples;
    if (self.isViewLoaded) {
        [_tableView reloadData];
    }
}

#pragma mark - Actions

- (void)onCloseClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _samples.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MNISTPreviewCell *cell = (MNISTPreviewCell *)[tableView dequeueReusableCellWithIdentifier:@"MNISTPreviewCell" forIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    MNISTPreviewCell *previewCell = (MNISTPreviewCell *)cell;
    [previewCell setMNISTSample:_samples[indexPath.row]];
}

@end
