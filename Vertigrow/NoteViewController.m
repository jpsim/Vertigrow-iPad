//
//  NoteViewController.m
//  Vertigrow
//
//  Created by hamid poursepanj on 11-11-22.
//  Copyright (c) 2011 uottawa. All rights reserved.
//

#import "NoteViewController.h"

@implementation NoteViewController


-(void)viewDidLoad{
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0,0,500,600)];
     [self.view addSubview:textView];
    textView=nil;
    
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight );
}
@end
