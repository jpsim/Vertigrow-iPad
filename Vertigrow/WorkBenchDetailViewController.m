//
//  WorkBenchDetailViewController.m
//  WorkBench
//
//  Created by hamid poursepanj on 11-11-13.
//  Copyright (c) 2011 uottawa. All rights reserved.
//

#import "WorkBenchDetailViewController.h"
#import "WorkBenchMasterViewController.h"


#define MG_DEFAULT_SPLIT_POSITION		320.0	// default width of master view in UISplitViewController.
#define THUMB_HEIGHT 180
#define THUMB_V_PADDING 10
#define THUMB_H_PADDING 10
#define CREDIT_LABEL_HEIGHT 20

#define AUTOSCROLL_THRESHOLD 30

@interface WorkBenchDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
- (CGSize)splitViewSizeForOrientation:(UIInterfaceOrientation)theOrientation;
- (NSArray *)imageNames;
- (void)toggleThumbView;
@end

@implementation WorkBenchDetailViewController

@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize masterNavController=_masterNavController;
@synthesize slideUpView=_slideUpView;
@synthesize thumbScrollView=_thumbScrollView;
@synthesize detailNavController=_detailNavController;
@synthesize ImagesNameArray=_ImagesNameArray;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.masterNavController = [self.splitViewController.viewControllers objectAtIndex:0];
    self.detailNavController = [self.splitViewController.viewControllers objectAtIndex:1];
	// Do any additional setup after loading the view, typically from a nib.
    self.ImagesNameArray = [self imageNames];
    [self configureView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
  
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
  
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight );
   
}

#pragma mark - Split view


- (IBAction)sildeMasterViewLeftRight:(id)sender {
    
    CGRect masterRect, detailRect;
    
    float _splitPosition = MG_DEFAULT_SPLIT_POSITION;
    
    CGSize fullSize = [self splitViewSizeForOrientation:self.interfaceOrientation];
	float width = fullSize.width;
	float height = fullSize.height;
    CGRect newFrame = CGRectMake(0, 0, width, height);
    
       
    newFrame.size.width = _splitPosition;
    masterRect = newFrame;
    
    newFrame.origin.x += newFrame.size.width;
    newFrame.size.width = width;
    detailRect = newFrame;
    
    [UIView beginAnimations:@"toggleMaster" context:nil];
    [UIView setAnimationDuration:0.3];
    
    float x = [self.view convertPoint:self.view.frame.origin toView:self.splitViewController.view].x;
    
    // Position master and detail
    if(x == 0){     
        
        self.masterNavController.view.frame = masterRect;
        [[[self.splitViewController.viewControllers objectAtIndex:1] view ] setFrame:detailRect];
   
    }else if( x == 320){
            
        self.masterNavController.view.frame = CGRectZero;
        [[[self.splitViewController.viewControllers objectAtIndex:1] view ] setFrame:CGRectMake(0, 0, fullSize.width, fullSize.height)];
    }
    
   [UIView commitAnimations];
    
}

- (CGSize)splitViewSizeForOrientation:(UIInterfaceOrientation)theOrientation
{
	UIScreen *screen = [UIScreen mainScreen];
	CGRect fullScreenRect = screen.bounds; // always implicitly in Portrait orientation.
	CGRect appFrame = screen.applicationFrame;
	
	// Find status bar height by checking which dimension of the applicationFrame is narrower than screen bounds.
	// Little bit ugly looking, but it'll still work even if they change the status bar height in future.
	float statusBarHeight = MAX((fullScreenRect.size.width - appFrame.size.width), (fullScreenRect.size.height - appFrame.size.height));
	
	// Initially assume portrait orientation.
	float width = fullScreenRect.size.width;
	float height = fullScreenRect.size.height;
	
	// Correct for orientation.
	if (UIInterfaceOrientationIsLandscape(theOrientation)) {
		width = height;
		height = fullScreenRect.size.width;
	}
	
	// Account for status bar, which always subtracts from the height (since it's always at the top of the screen).
	height -= statusBarHeight;
	
	return CGSizeMake(width, height);
}


-(BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation{
    return YES;
}  

- (NSArray *)imageNames {
    
    // the filenames are stored in a plist in the app bundle, so create array by reading this plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Images" ofType:@"plist"];
    NSData *plistData = [NSData dataWithContentsOfFile:path];
    NSString *error; NSPropertyListFormat format;
    NSArray *imageNames = [NSPropertyListSerialization propertyListFromData:plistData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:&format
                                                           errorDescription:&error];
    if (!imageNames) {
        NSLog(@"Failed to read image names. Error: %@", error);
    }
    
    return imageNames;
}
- (void)createSlideUpViewIfNecessary {
    
    if (!self.slideUpView) {
        
        [self createThumbScrollViewIfNecessary];
        
        CGRect bounds = [[self view] bounds];
        float thumbHeight = [self.thumbScrollView frame].size.height;
        
        // create container view that will hold scroll view and label
        CGRect frame = CGRectMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds)+44, bounds.size.width,thumbHeight);
         self.slideUpView = [[UIView alloc] initWithFrame:frame];
        [self.slideUpView setBackgroundColor:[UIColor blackColor]];
        [self.slideUpView setOpaque:NO];
        [self.slideUpView setAlpha:0.75];
        
        [self.detailNavController.view addSubview:self.slideUpView];
       
        // add subviews to container view
        [self.slideUpView addSubview:self.thumbScrollView];
                     
    }    
}

- (void)createThumbScrollViewIfNecessary {
    
    if (!self.thumbScrollView) {        
        
        float scrollViewHeight = THUMB_HEIGHT + THUMB_V_PADDING;
        float scrollViewWidth  = [[self view] bounds].size.width;
        self.thumbScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
        [self.thumbScrollView setCanCancelContentTouches:NO];
        [self.thumbScrollView setClipsToBounds:NO];
        
        // now place all the thumb views as subviews of the scroll view 
        // and in the course of doing so calculate the content width
        float xPosition = THUMB_H_PADDING;
        for (NSString *name in self.ImagesNameArray) {
            UIImage *thumbImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", name]];
            UIImage *scaledImage = [UIImage imageWithCGImage:[thumbImage CGImage] scale:15 orientation:UIImageOrientationUp];
           // NSLog(@"higth of image %f", scaledImage.size.height);
            if (scaledImage) {
                UIImageView *thumbView = [[UIImageView alloc] initWithImage:scaledImage];
                ImageViewForScroller *newThumb = [[ImageViewForScroller alloc] initWithImage:scaledImage];
                newThumb.imageName = [NSString stringWithFormat:@"%@.png", name];
                [newThumb setDelegate:self];
               
                CGRect frame = [thumbView frame];
                frame.origin.y = THUMB_V_PADDING;
                frame.origin.x = xPosition;
                [thumbView setFrame:frame];
                newThumb.home = frame;
                [newThumb setFrame:frame];
                
                [self.thumbScrollView addSubview:thumbView];
                [self.thumbScrollView addSubview:newThumb];
                [thumbView resignFirstResponder];
                [newThumb becomeFirstResponder];
                
                xPosition += (frame.size.width + THUMB_H_PADDING);
            }
        }
        [self.thumbScrollView setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    }    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
   
    [self toggleThumbView];   
}
 

-(void)panGestureForScrollViewImage:(ImageViewForScroller *)draggingThumb{
   
    if(draggingThumb.stoppedDragging){
        [draggingThumb removeFromSuperview];
        
        ThumbImageView *addIt =  [[ThumbImageView alloc] initWithImage:draggingThumb.image];
        addIt.imageName=draggingThumb.imageName;
        
        addIt.center = [self.slideUpView convertPoint:draggingThumb.center toView:self.detailNavController.topViewController.view];
        [self.view addSubview:addIt];
        
        
        
        ImageViewForScroller *newThumb = [[ImageViewForScroller alloc] initWithImage:draggingThumb.image];
        newThumb.imageName=draggingThumb.imageName;
        newThumb.home = draggingThumb.home;
        newThumb.frame = draggingThumb.home;
        [newThumb setDelegate:self];
        [self.thumbScrollView addSubview:newThumb];
        [newThumb becomeFirstResponder];
    
    }
}
- (void)toggleThumbView {
    [self createSlideUpViewIfNecessary]; // no-op if slideUpView has already been created
    CGRect frame = [self.slideUpView frame];
    if (thumbViewShowing) {
        frame.origin.y += frame.size.height;
    } else {
        frame.origin.y -= frame.size.height;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [self.slideUpView setFrame:frame];
    [UIView commitAnimations];
    
    thumbViewShowing = !thumbViewShowing;
}
@end
