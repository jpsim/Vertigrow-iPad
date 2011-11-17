//
//  ImageViewForScroller.h
//  WorkBench
//
//  Created by hamid poursepanj on 11-11-14.
//  Copyright (c) 2011 uottawa. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol ImageViewForScrollerDelegate;

@interface ImageViewForScroller : UIImageView<UIGestureRecognizerDelegate>{
    
}
@property(nonatomic,assign) BOOL stoppedDragging;
@property(nonatomic,assign) CGRect home;
@property(nonatomic,strong) id<ImageViewForScrollerDelegate> delegate;
@property(nonatomic,assign)CGFloat firstX;
@property(nonatomic,assign)CGFloat firstY;
@property(nonatomic,retain) NSString *imageName;
@end

@protocol ImageViewForScrollerDelegate <NSObject>
@optional
-(void)thumbImageInScrollViewTouched:(ImageViewForScroller *)ivs;
-(void)panGestureForScrollViewImage:(ImageViewForScroller *)ivs;
@end