//
//  WorkBenchDetailViewController.m
//  WorkBench
//
//  Created by hamid poursepanj on 11-11-13.
//  Copyright (c) 2011 uottawa. All rights reserved.
//

#import "WorkBenchDetailViewController.h"
#import "WorkBenchMasterViewController.h"
#import <QuartzCore/QuartzCore.h>

#define MG_DEFAULT_SPLIT_POSITION  320.0	// default width of master view in UISplitViewController.
#define THUMB_HEIGHT 150
#define THUMB_V_PADDING 10
#define THUMB_H_PADDING 10
#define CREDIT_LABEL_HEIGHT 20
#define AUTOSCROLL_THRESHOLD 30

@interface WorkBenchDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
- (CGSize)splitViewSizeForOrientation:(UIInterfaceOrientation)theOrientation;
- (void)imageNames;
- (void)toggleThumbView;
- (void)addBarButtonsToNavigationController;
- (IBAction)takePicture:(id)sender;
- (IBAction)sendEmail:(id)sender;
- (IBAction)saveImage:(id)sender;
- (IBAction)saveProjectNot:(id)sender;
- (IBAction)addNotes:(id)sender;
- (IBAction)cancelModalView:(id)sender;
- (IBAction)saveNote:(id)sender;
- (UIImage *)takeViewScreenshot;
- (NSString *)getDate;
- (void)grabTextToAdd:(NSNotification *)notification;
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
@synthesize notesText=_notesText;

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
    //self.ImagesNameArray = [self imageNames];
    
    NSOperationQueue *queue = [NSOperationQueue new];
    
    NSInvocationOperation *operation1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(imageNames) object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(grabTextToAdd:)
                                                 name:@"selftextToAddNotification" object:nil];
    
    [queue addOperation:operation1];
    
    [self addBarButtonsToNavigationController];
    
    [self configureView];
   
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.thumbScrollView=nil;
    self.slideUpView=nil;
    self.masterPopoverController=nil;
    self.detailDescriptionLabel=nil;
    self.ImagesNameArray=nil;
    self.notesText=nil;
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

#pragma mark - 
#pragma mark  geometry of splitview 


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

#pragma mark
#pragma mark creating SlideUpView and ScrollView and attaching them to main view

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
            UIImage *thumbImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_thumb.png", name]];
            //UIImage *scaledImage = [UIImage imageWithCGImage:[thumbImage CGImage] scale:15 orientation:UIImageOrientationUp];
            // NSLog(@"higth of image %f", scaledImage.size.height);
            if (thumbImage) {
                UIImageView *thumbView = [[UIImageView alloc] initWithImage:thumbImage];
                ImageViewForScroller *newThumb = [[ImageViewForScroller alloc] initWithImage:thumbImage];
                newThumb.imageName = [NSString stringWithFormat:@"%@_thumb.png", name];
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

-(void)imageNames {
    
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
    
    self.ImagesNameArray = imageNames;
    
}

#pragma mark
#pragma mark functinalities related to panning and touch 


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self toggleThumbView];   
}


-(void)panGestureForScrollViewImage:(ImageViewForScroller *)draggingThumb{
    
    CGPoint draggingThumbCenter = [self.thumbScrollView convertPoint:draggingThumb.frame.origin toView:self.slideUpView];
    
    if(draggingThumb.stoppedDragging){
        
        if(!CGRectContainsPoint(self.slideUpView.bounds, draggingThumbCenter) ){
            NSLog(@"the thumb is in slideupview border");

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
        
        }else{
            
            [draggingThumb removeFromSuperview];
            ImageViewForScroller *newThumb = [[ImageViewForScroller alloc] initWithImage:draggingThumb.image];
            newThumb.imageName=draggingThumb.imageName;
            newThumb.home = draggingThumb.home;
            newThumb.frame = draggingThumb.home;
            [newThumb setDelegate:self];
            [self.thumbScrollView addSubview:newThumb];
            [newThumb becomeFirstResponder];

        }
    }
    
}

-(void)doubleTap:(ThumbImageView *)tappedImage{
    
    NSLog(@"double tap is selected");
    [tappedImage removeFromSuperview];
    
    //tappedImage =nil;
}

-(void)singleTap:(ThumbImageView *)tappedImage{
     
    UIView *detailview =[[[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] view];
    [detailview bringSubviewToFront:tappedImage];
    detailview=nil;
}

#pragma mark
#pragma mark buttons on the UINavigatorController

-(void)addBarButtonsToNavigationController{
    UIToolbar *tools = [[UIToolbar alloc]
                        initWithFrame:CGRectMake(0.0f, 0.0f, 190.0f, 44.01f)]; // 44.01 shifts it up 1px for some reason
    tools.clearsContextBeforeDrawing = NO;
    tools.clipsToBounds = NO;
    tools.tintColor = [UIColor colorWithWhite:0.305f alpha:0.0f]; // closest I could get by eye to black, translucent style.
    // anyone know how to get it perfect?
    tools.barStyle = -1; // clear background
    NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:3];
  
    
    //create a new project  
    UIBarButtonItem *bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(saveProjectNot:)];
    bi.width = 20.0f;
    [buttons addObject:bi];
    bi=nil;
    
    // Create a standard takePicture button.
    bi = [[UIBarButtonItem alloc]
                           initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePicture:)];
    bi.width = 20.0f;
    [buttons addObject:bi];
    bi=nil;
    
    // Add profile button.
    bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sendEmail:)];
    bi.width = 20.0f;
    [buttons addObject:bi];
    bi=nil;
    
    //add notes to project
    bi = [[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(addNotes:)];
    bi.width = 20.0f;
    [buttons addObject:bi];
    bi=nil;
    
      //saving screenshot into photo library
    bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveImage:)];
    bi.width = 20.0f;
    [buttons addObject:bi];
    bi=nil;


    // Add buttons to toolbar and toolbar to nav bar.
    [tools setItems:buttons animated:NO];
    buttons=nil;
    
    UIBarButtonItem *threeButtons = [[UIBarButtonItem alloc] initWithCustomView:tools];
    tools = nil;
    
  
    [[[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] navigationItem].rightBarButtonItem = threeButtons;
    threeButtons = nil;
}

- (IBAction)saveProjectNot:(id)sender{
    
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"saveProjecttNotification" object:self userInfo:nil];
    
}

- (IBAction)saveImage:(id)sender{
    
	UIImageWriteToSavedPhotosAlbum([self takeViewScreenshot], self, nil, nil); 
}

#pragma -mark
#pragma modal view for Notes

- (IBAction)addNotes:(id)sender{
    
    NoteViewController *NotesController = [[NoteViewController alloc] init];
  
    NotesController.text=self.notesText;
    UINavigationController *navcont = [[UINavigationController alloc]
                                                 initWithRootViewController:NotesController];
    
    UIBarButtonItem *biLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelModalView:)];
     biLeft.width = 20.0f;
    
    UIBarButtonItem *biRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveNote:)];
    biLeft.width = 20.0f;
     
    [NotesController.navigationItem setLeftBarButtonItem:biLeft];
    [NotesController.navigationItem setRightBarButtonItem:biRight];
    [NotesController.navigationItem setTitle:@"Note"];
    
    navcont.delegate=self;
    navcont.modalPresentationStyle = UIModalPresentationFormSheet;
    navcont.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentModalViewController:navcont animated:YES];
    
    navcont.view.superview.bounds = CGRectMake(0, 0, 500, 600);
    navcont=nil;
    NotesController=nil;
    
}

-(void)grabTextToAdd:(NSNotification *)notification{
    
    self.notesText = [[notification userInfo] valueForKey:@"selftextToAdd"];
    NSLog(@"text to be shown in modelView is received --%@--", self.notesText);
    
}

//grab the text from modal view and pass it with a notification to AppDelegate
-(IBAction)saveNote:(id)sender{
   
    NSString *text = [[[[[[[self modalViewController] childViewControllers] objectAtIndex:0] view] subviews]objectAtIndex:0] text]; 
    
    NSDictionary* dict = [NSDictionary dictionaryWithObject:text forKey:@"textToBeAdded"];
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"textToBeAddedNotification" object:self userInfo:dict];
    
    [self dismissModalViewControllerAnimated:YES];
     NSLog(@"grab the text --%@-- from modal view and pass it with a notification to AppDelegate",text);
}
-(IBAction)cancelModalView:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark
#pragma mark taking picture using camera

- (IBAction)takePicture:(id)sender{
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    // If our device has a camera, we want to take a picture, otherwise, we
    // just pick from photo library
    if ([UIImagePickerController
         isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    // This line of code will generate 2 warnings right now, ignore them
    [imagePicker setDelegate:self];
    
    // Place image picker on the screens
    [self presentModalViewController:imagePicker animated:YES];
    
    // The image picker will be retained by ItemDetailViewController
    // until it has been dismissed
    imagePicker=nil;
}


- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    // Get picked image from info dictionary
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    NSString  const *keyForCameraImage = @"hamid";
    NSMutableDictionary *cameraImageDictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
    [cameraImageDictionary setObject:image forKey:keyForCameraImage];
    
    //NSData *cameraImageData = UIImageJPEGRepresentation(image, 0.5);      
    //NSString *cameraImagefilename = [NSString stringWithFormat:@"%@.jpg",[self getDate]];
    
    

    UIImageView *cameraPicView = [[UIImageView alloc]initWithImage:[cameraImageDictionary objectForKey:keyForCameraImage] ];
    
        // save in photo gallery then retrieve it from photogallery
    [[[[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] view] addSubview:cameraPicView];
    
    cameraPicView = nil;
    
    [self configureView];
    
    // Take image picker off the screen -
    // you must call this dismiss method
    [self dismissModalViewControllerAnimated:YES];
    
}

#pragma mark
#pragma mark attaching picture to email and send it

- (IBAction)sendEmail:(id)sender{
    
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    
    if([MFMailComposeViewController canSendMail])
    {
        [controller setSubject:[NSString stringWithFormat:@"Vertigrow mockup"]];
        
        UIImage *image = [self takeViewScreenshot];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);      
        NSString *filename = [NSString stringWithFormat:@"%@.jpg",[self getDate]];
        [controller addAttachmentData:imageData mimeType:@"image/jpg" fileName:filename];
        
        [controller setMessageBody:[NSString stringWithFormat:@"here is the copy of the mockup!"] isHTML:NO]; 
        
        [self presentModalViewController:controller animated:YES];
    }
    controller=nil;
    
}


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result)
    
    {
            
        case MFMailComposeResultCancelled:
            [self dismissModalViewControllerAnimated:YES];
            break;
            
        case MFMailComposeResultSent:
            [self dismissModalViewControllerAnimated:YES];
            break;
            
        case MFMailComposeResultFailed: 
            NSLog(@"Failed!");
            break;
            
        case MFMailComposeResultSaved:
            [self dismissModalViewControllerAnimated:YES];
            break;
            
        default:   
            NSLog(@"Result: Something went wrong!");           
            break;
    }

}

-(UIImage *)takeViewScreenshot{
    
    UIGraphicsBeginImageContext([[[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] view].bounds.size);
    
    [[[[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] view ].layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}

-(NSString *)getDate{
    NSDate* now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:now];
    
    NSDate *date = [dateComponents date];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    gregorian=nil;
    
    return dateString;
}
@end
