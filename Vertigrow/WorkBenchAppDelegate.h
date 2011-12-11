//
//  WorkBenchAppDelegate.h
//  WorkBench
//
//  Created by hamid poursepanj on 11-11-13.
//  Copyright (c) 2011 uottawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThumbImageView.h"


@interface WorkBenchAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate> {
    UITextField *projNameField;
}

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,retain)UISplitViewController *splitViewController;

@property (nonatomic, retain) NSMutableDictionary *toBeSavedDictionary;
@property (nonatomic, retain) NSMutableArray *keysArray;
@property(nonatomic,retain) NSString *key;
@property(nonatomic,retain) NSString *textToAdd;
@property(nonatomic,assign) BOOL projectSelected;
@property(nonatomic,retain) NSMutableArray *notesArray;
@property(nonatomic,assign) NSInteger currentIndex;
@end
