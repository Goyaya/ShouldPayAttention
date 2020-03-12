//
//  ViewController.m
//  AVFoundation
//
//  Created by Gaoyang on 2020/3/12.
//  Copyright © 2020 Goyaya. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *cell = sender;
    if ([cell isKindOfClass:UITableViewCell.class]) {
        segue.destinationViewController.title = cell.textLabel.text;
    }
}

@end
