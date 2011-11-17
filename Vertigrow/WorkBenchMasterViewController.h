//
//  WorkBenchMasterViewController.h
//  WorkBench
//
//  Created by hamid poursepanj on 11-11-13.
//  Copyright (c) 2011 uottawa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class WorkBenchDetailViewController;

@interface WorkBenchMasterViewController : UITableViewController

@property (strong, nonatomic) WorkBenchDetailViewController *detailViewController;
@property(nonatomic,retain) NSString *savedData;

@property(nonatomic,assign) BOOL isVisible;

@end
