//
//  ImageViewForScroller.m
//  WorkBench
//
//  Created by hamid poursepanj on 11-11-14.
//  Copyright (c) 2011 uottawa. All rights reserved.
//

#import "ImageViewForScroller.h"

@implementation ImageViewForScroller
@synthesize delegate=_delegate;
@synthesize stoppedDragging=_stoppedDragging;
@synthesize firstX=_firstX;
@synthesize firstY=_firstY;
@synthesize home=_home;
@synthesize imageName=_imageName;

- (id)initWithImage:(UIImage *)image {
    
    self = [super initWithImage:image];
    if (self) {
        [self setUserInteractionEnabled:YES];
        //[self setMultipleTouchEnabled:YES];
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handlePanGesture:)];
        [self addGestureRecognizer:panGesture];
        [panGesture setDelegate:self];
        
    }
    
    return  self;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([self.delegate respondsToSelector:@selector(thumbImageInScrollViewTouched:)])
        [self.delegate thumbImageInScrollViewTouched:self];
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender {
    self.stoppedDragging =NO;
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.superview];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        self.firstX = [sender.view center].x;
        self.firstY = [sender.view center].y;
    }
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded){
        self.stoppedDragging = YES;
    }
    translatedPoint = CGPointMake(self.firstX + translatedPoint.x,self.firstY + translatedPoint.y);
    
    [sender.view setCenter:translatedPoint];
    
    if ([self.delegate respondsToSelector:@selector(panGestureForScrollViewImage:)])
        [self.delegate panGestureForScrollViewImage:self];
}
- (void)viewDidUnload{
    self.imageName=nil;
}
@end
