//
//  MenuViewController.m
//  Training
//
//  Created by Naruki Chigira on 2018/12/07.
//  Copyright © 2018 Naruki Chigira. All rights reserved.
//

@import MetalPerformanceShaders;
#import "MenuViewController.h"
#import "AppDelegate.h"
#import "Graph.h"
#import "MNIST/MNIST.h"
#import "MNIST/Preview/MNISTPreviewViewController.h"
#import "Processor/MNIST+Training.h"
#import "Processor/Processor.h"

@interface MenuViewController ()
@property (nonatomic, retain) Graph *graph;
@property (nonatomic, retain) MNIST *mnistTraning;
@property (nonatomic, retain) MNIST *mnistTest;
@property (nonatomic, retain) Processor *processor;
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadGraph];
    [self loadMNIST];
    [self loadProcessor];
}

#pragma mark - Load

- (void)loadGraph {
    self.graph = [Graph new];
}

- (void)loadMNIST {
    self.mnistTraning = [MNIST mnistWithDatasetType:MNISTDatasetTypeTraining];
    self.mnistTest = [MNIST mnistWithDatasetType:MNISTDatasetTypeTest];
}

- (void)loadProcessor {
    self.processor = [Processor new];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self showMNISTPreviewActionSheet];
            break;
        case 1:
            [self startTraining];
            break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Controls

- (void)showMNISTPreviewActionSheet {
    NSString *title = @"Select dataset to preview";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    // Traning Dataset
    [alertController addAction:[UIAlertAction actionWithTitle:@"Training" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        MNISTPreviewViewController *previewViewController = [[UIStoryboard storyboardWithName:@"MNISTPreviewViewController" bundle:nil] instantiateInitialViewController];
        [self.navigationController pushViewController:previewViewController animated:YES];
        [previewViewController setSamples:self.mnistTraning.samples];
    }]];
    // Test Dataset
    [alertController addAction:[UIAlertAction actionWithTitle:@"Test" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        MNISTPreviewViewController *previewViewController = [[UIStoryboard storyboardWithName:@"MNISTPreviewViewController" bundle:nil] instantiateInitialViewController];
        [self.navigationController pushViewController:previewViewController animated:YES];
        [previewViewController setSamples:self.mnistTest.samples];
    }]];
    // Cancel
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)startTraining {
    [_processor trainGraph:_graph training:_mnistTraning test:_mnistTest epocs:10 iterationsPerEpoc:15 batchSize:40];
//    [_processor inferenceMNIST:_mnistTest size:1000 graph:_graph.inference];
}

@end
