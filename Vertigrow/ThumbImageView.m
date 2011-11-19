//
//  ThumbImageView.m
//  MGSplitView
//
//  Created by hamid poursepanj on 11-11-08.
//  Copyright (c) 2011 uottawa. All rights reserved.
//

#import "ThumbImageView.h"
#import <QuartzCore/QuartzCore.h>


@interface ThumbImageView ()
- (void)createGestureRecognizers;
@end

@implementation ThumbImageView
@synthesize delegate=_delegate;
@synthesize lastRotation=_lastRotation;
@synthesize firstX=_firstX;
@synthesize firstY=_firstY;
@synthesize frameCenterForSerialization=_frameCenterForSerialization;
@synthesize thumbImageToBeSerialized=_thumbImageToBeSerialized;
@synthesize imageName=_imageName;



- (id)initWithImage:(UIImage *)image  {
    self.thumbImageToBeSerialized = image;
    self = [super initWithImage:self.thumbImageToBeSerialized];
    if (self) {
        [self setUserInteractionEnabled:YES];
        [self setMultipleTouchEnabled:YES];
        [self createGestureRecognizers];
        
    }
    
    return  self;
}
- (void)viewDidUnload{
    self.thumbImageToBeSerialized=nil;
    self.imageName=nil;
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([self.delegate respondsToSelector:@selector(stoppedtracking:)])
        [self.delegate stoppedtracking:self];
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    //if ([self.delegate respondsToSelector:@selector(stoppedtracking:)])
    //[self.delegate stoppedtracking:self];
    
}
#pragma mark -
#pragma mark GestureRecocnizers
- (void)createGestureRecognizers{
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(handlSingleTap:)];
    singleFingerTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleFingerTap];
    [singleFingerTap setDelegate:self];
    //[singleFingerTap release];
    
    UITapGestureRecognizer *singleFingerDTap = [[UITapGestureRecognizer alloc]
                                                initWithTarget:self action:@selector(handlDoubleTap:)];
    singleFingerDTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:singleFingerDTap];
    [singleFingerTap setDelegate:self];
    //[singleFingerDTap release];
    
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panGesture];
    [panGesture setDelegate:self];
    //[panGesture release];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handlePinchGesture:)];
    [self addGestureRecognizer:pinchGesture];
    [pinchGesture setDelegate:self];
    //[pinchGesture release];
    
    UIRotationGestureRecognizer *rotateGesture =
    [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotateGesture:)];
    [self addGestureRecognizer:rotateGesture];
    [rotateGesture setDelegate:self];
    //[rotateGesture release];
    
}

#pragma mark -
#pragma mark handling GestureRecognizers

-(IBAction)handlDoubleTap:(UIGestureRecognizer *)sender{
    
    if ([self.delegate respondsToSelector:@selector(doubleTap:)])
        [self.delegate doubleTap:self];
}
- (IBAction)handlSingleTap:(UIGestureRecognizer *)sender{
    
    if ([self.delegate respondsToSelector:@selector(singleTap:)])
        [self.delegate singleTap:self];
}

- (IBAction)handleRotateGesture:(UIGestureRecognizer *)sender{
    
    
	if(sender.state == UIGestureRecognizerStateEnded) {
        
		self.lastRotation = 0.0;
		return;
	}
    
	CGFloat rotation = 0.0 - (self.lastRotation - [(UIRotationGestureRecognizer*)sender rotation]);
    
	CGAffineTransform currentTransform = sender.view.transform;
	CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform,rotation);
    
	[sender.view setTransform:newTransform];
    
    
	self.lastRotation = [(UIRotationGestureRecognizer*)sender rotation];
    
    
}

- (IBAction)handlePinchGesture:(UIGestureRecognizer *)sender { 
    static CGRect initialBounds;
    
    UIView *_view = sender.view;
    
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        initialBounds = _view.bounds;
    }
    CGFloat factor = [(UIPinchGestureRecognizer *)sender scale];
    
    CGAffineTransform zt = CGAffineTransformScale(CGAffineTransformIdentity, factor, factor);
    _view.bounds = CGRectApplyAffineTransform(initialBounds, zt);
    
    
    if ([self.delegate respondsToSelector:@selector(pinchGesture:)])
        [self.delegate pinchGesture:self];
    
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender {
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.superview];
    //CGPoint newpoint = [[self.view viewWithTag:3001] convertPoint:draggingThumb.frame.origin toView:self.view];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        self.firstX = [sender.view center].x;
        self.firstY = [sender.view center].y;
    }
    
    translatedPoint = CGPointMake(self.firstX+translatedPoint.x, self.firstY+translatedPoint.y);
    
    [sender.view setCenter:translatedPoint];
    self.frameCenterForSerialization = sender.view.center;
    
    if ([self.delegate respondsToSelector:@selector(panGesture:)])
        [self.delegate panGesture:self];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return ![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && ![gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]];
}

#pragma mark -
#pragma mark Archiving objects

-(void) encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeCGPoint:self.frameCenterForSerialization forKey:@"viewFrame" ];    
    NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(self.thumbImageToBeSerialized,0.5)];
    [aCoder encodeDataObject:imageData];
    [aCoder encodeFloat:self.lastRotation forKey:@"lastRotaion"];
    [aCoder encodeFloat:self.firstX forKey:@"firstx"];
    [aCoder encodeFloat:self.firstY forKey:@"firsty"];
    
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    self.frameCenterForSerialization = [aDecoder decodeCGPointForKey:@"viewFrame"];
    NSData *decodedImageData= [aDecoder decodeDataObject];
    self.thumbImageToBeSerialized = [[UIImage alloc] initWithData:decodedImageData];
    self.firstX = [aDecoder decodeFloatForKey:@"firstx"];
    self.firstY = [aDecoder decodeFloatForKey:@"firsty"];
    self.lastRotation = [aDecoder decodeFloatForKey:@"lastRotaion"];
    [self setImage:self.thumbImageToBeSerialized];
    [self setUserInteractionEnabled:YES];
    [self setMultipleTouchEnabled:YES];
    [self createGestureRecognizers];
    return self;
}

@end

