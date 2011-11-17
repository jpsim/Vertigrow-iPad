//
//  ThumbImageView.h
//  MGSplitView
//
//  Created by hamid poursepanj on 11-11-08.
//  Copyright (c) 2011 uottawa. All rights reserved.
//

@protocol ThumbImageViewDelegate;

@interface ThumbImageView : UIImageView<UIGestureRecognizerDelegate,NSCoding>

@property(nonatomic,assign) CGFloat lastRotation;
@property(nonatomic,assign)CGFloat firstX;
@property(nonatomic,assign)CGFloat firstY;

//bunch of instance variables for serialization

@property(nonatomic,assign) CGPoint frameCenterForSerialization; 
@property(nonatomic,assign)CGRect boundForSerialization;
@property(nonatomic,assign) CGAffineTransform transformForSerialization;


@property(nonatomic,retain) UIImage *thumbImageToBeSerialized;
@property(nonatomic,strong) id<ThumbImageViewDelegate> delegate;
@property(nonatomic,retain) NSString *imageName;
@end



@protocol ThumbImageViewDelegate <NSObject>
@optional
-(void)panGesture:(ThumbImageView *)tiv;
-(void)pinchGesture:(ThumbImageView *)tiv;
-(void)singleTap:(ThumbImageView *)tiv;
-(void)stoppedtracking:(ThumbImageView *)tiv;
-(void)doubleTap:(ThumbImageView *)tiv;

@end