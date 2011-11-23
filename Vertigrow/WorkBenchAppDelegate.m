//
//  WorkBenchAppDelegate.m
//  WorkBench
//
//  Created by hamid poursepanj on 11-11-13.
//  Copyright (c) 2011 uottawa. All rights reserved.
//

#import "WorkBenchAppDelegate.h"

NSString * const filenamePrefKey = @"filenamePrefKey";

@interface WorkBenchAppDelegate (AuxilaryMethods)



NSString *pathIndocumentDirectory(NSString *fileName);
- (BOOL)saveChanges;
- (NSString *)allImageViewsArchivePath;
- (void)fetchubViewsIfNecessary;
-(void)setupSubviews:(NSNotification *)notification;
-(void)createKey;
-(void)setUptTableView;
-(void)updateDictionary:(NSNotification *)notification;
-(void)clearDetailControllerMainView;
-(void)createNewProject:(NSNotification *)notification;
-(void)grabText:(NSNotification *)notification;
-(void)addEntryToDictionary;
-(NSString *)getCurrentDate;
@end

@implementation WorkBenchAppDelegate

@synthesize window = _window;
@synthesize splitViewController=_splitViewController;
@synthesize keysArray=_keysArray;
@synthesize key=_key;
@synthesize toBeSavedDictionary=_toBeSavedDictionary;
@synthesize textToAdd=_textToAdd;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    self.splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [self.splitViewController.viewControllers lastObject];
    
    self.splitViewController.delegate = (id)navigationController.topViewController;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupSubviews:)
                                                 name:@"setupSubviewsNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDictionary:)
                                                 name:@"updateDictionaryNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(createNewProject:)
                                                 name:@"createNewProjectNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(grabText:)
                                                 name:@"textToBeAdded" object:nil];

    
    [self fetchubViewsIfNecessary];
    
    [self setUptTableView];

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"entered background");
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [self saveChanges];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
}

-(void)grabText:(NSNotification *)notification{
    NSString *text = [[[notification userInfo] valueForKey:@"textToBeAdded"] stringValue];
    self.textToAdd = [self.textToAdd stringByAppendingString:text];
}
-(void)createNewProject:(NSNotification *)notification{
    
    [self addEntryToDictionary];
    
    self.keysArray=nil;
    self.keysArray = [[NSMutableArray alloc] init];
    [self.keysArray addObjectsFromArray:[self.toBeSavedDictionary allKeys]];
    
    //self.dict=nil;
    //self.dict = [NSDictionary dictionaryWithObject:self.keysArray forKey:@"keysArray"];
    [self  setUptTableView];
    
    [self clearDetailControllerMainView];
    self.key=nil; 
    
}

-(void)clearDetailControllerMainView{
    NSMutableArray *subviewsToBeeleted =[[NSMutableArray alloc] initWithArray:[[[[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] view] subviews]];
    
    for (ThumbImageView *view in subviewsToBeeleted) {
        [view removeFromSuperview];
    }
    subviewsToBeeleted= nil;
}
-(void)setUptTableView{
    
   NSDictionary *dict = [NSDictionary dictionaryWithObject:self.keysArray forKey:@"keysArray"];
    NSLog(@"self.keysArray %d",[self.keysArray count] );
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"setUptTableViewNotification" object:self userInfo:dict];
}

-(void)updateDictionary:(NSNotification *)notification{
    
    NSUInteger index = [[[notification userInfo] valueForKey:@"keyTobeRemoved"] intValue];
    NSString *keytTobeRemoved = [[self.toBeSavedDictionary allKeys] objectAtIndex:index];
    [self.toBeSavedDictionary removeObjectForKey:keytTobeRemoved];
    NSLog(@"self.keysArray %d", [self.keysArray count]);
    
    [self clearDetailControllerMainView];
    
}
-(void)setupSubviews:(NSNotification *)notification{
    
    [self clearDetailControllerMainView];
    
    NSUInteger index = [[[notification userInfo] valueForKey:@"index"] intValue];
    NSLog(@"i have got %d",index);
    
    
    //get the key for the selected project in tableview
    self.key = [self.keysArray objectAtIndex:index];
    NSLog(@"self.key %@", self.key);
    
    
    //get the array containing all the subviews serialized properties required for the recreation of suviews
    NSArray *savedSubviewsArray = [self.toBeSavedDictionary objectForKey:self.key];
    NSLog(@"there are %d subviews to be added!", [savedSubviewsArray count]);
    
    
    if(savedSubviewsArray){
        
        for(NSMutableArray *propertiesArray in savedSubviewsArray){
            
            //grab the name of the image file located on Supporting Files Directory
            NSString *fileName = [propertiesArray objectAtIndex:0];
            NSLog(@" i am going to grab %@ image",fileName);
            
            //grab the imgae with the same file name
            UIImage *thumbImage = [UIImage imageNamed:fileName];
            
            //scale the image 
            //UIImage *scaledImage = [UIImage imageWithCGImage:[thumbImage CGImage] scale:15 orientation:UIImageOrientationUp];
            
            // create the ThumbImageView to be added to the detailviewcontrollers's main view 
            ThumbImageView *addIt =  [[ThumbImageView alloc] initWithImage:thumbImage];
            
            //setup the properties of ThumbImageView
            addIt.imageName = [propertiesArray objectAtIndex:0]; 
            
            addIt.center = [[propertiesArray objectAtIndex:1] CGPointValue];
            NSLog(@"addIt.center %@", NSStringFromCGPoint(addIt.center));
            
            addIt.bounds = [[propertiesArray objectAtIndex:2] CGRectValue]; 
            NSLog(@"addIt.bounds: %@", NSStringFromCGRect(addIt.bounds));
            
            addIt.transform = [[propertiesArray objectAtIndex:3] CGAffineTransformValue];
            NSLog(@"addIt.transform: %@",NSStringFromCGAffineTransform(addIt.transform));
            
            //add the image to the detailviewcontrollers's main view 
            [[[[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] view] addSubview:addIt];
            [addIt setDelegate:[[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] ];
        }
    }
    
    savedSubviewsArray= nil;
}

- (void)fetchubViewsIfNecessary
{
    
    if(!self.toBeSavedDictionary){
        NSString *path =[self allImageViewsArchivePath];
        self.toBeSavedDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
    }
    
    if(!self.toBeSavedDictionary){
        self.toBeSavedDictionary = [NSMutableDictionary dictionary];
    }
    
    //if the dictionary is not empty it means there exists at least one project
    if(!self.keysArray){
        
        self.keysArray = [[NSMutableArray alloc] init];
    }
    
    if([self.toBeSavedDictionary count]>0){  
        
        [self.keysArray addObjectsFromArray:[self.toBeSavedDictionary allKeys]];
        
    }
}

- (BOOL)saveChanges
{
    [self addEntryToDictionary];    
    return ([NSKeyedArchiver archiveRootObject: self.toBeSavedDictionary
                                        toFile:[self allImageViewsArchivePath]]);
    
}
-(void)addEntryToDictionary{
    //extract all subview from the detailview controller's main view
    NSMutableArray *allsubviewsArray = [[NSMutableArray alloc] init]; 
    
    [allsubviewsArray addObjectsFromArray:[[[[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] view] subviews]]; 
    NSLog(@"allsubviewsArray: %d ", [allsubviewsArray count]);
    
    NSMutableArray *allsubviewsPropertiesArray = [[NSMutableArray alloc] init]; 
    if ([allsubviewsArray count]>0) {
        
        for (ThumbImageView *view in allsubviewsArray) {
            
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            
            [array insertObject:view.imageName atIndex:0];
            
            NSValue *frameCenter = [NSValue valueWithCGPoint:view.center];
            NSLog(@"view.frameCenterForSerialization: %@", NSStringFromCGPoint(view.center));
            [array insertObject:frameCenter atIndex:1];
            
            
            NSValue *bound = [NSValue valueWithCGRect:view.bounds];
            NSLog(@"view.boundForSerialization: %@", NSStringFromCGRect(view.bounds));
            [array insertObject:bound atIndex:2];
            
            NSValue *transform = [NSValue valueWithCGAffineTransform:view.transform];
            NSLog(@"view.transformForSerialization: %@",NSStringFromCGAffineTransform(view.transform));
            [array insertObject:transform atIndex:3];
        
            
            [allsubviewsPropertiesArray addObject:array];
            array=nil;
        }
    }  
    NSLog(@"allsubviewsPropertiesArray count: %d",[allsubviewsPropertiesArray count]);
    if(!self.key){
        [self createKey];
    }
    [self.toBeSavedDictionary setObject:allsubviewsPropertiesArray forKey:self.key];
    NSLog(@"self.toBeSavedDictionary count %d", [self.toBeSavedDictionary count]);
    
    allsubviewsArray=nil;
    allsubviewsPropertiesArray=nil;

}
-(void)createKey{
    
    
    NSLog(@"the first time");
    /*CFUUIDRef newUniqueID = CFUUIDCreate (kCFAllocatorDefault);
    
    // Create a string from unique identifier
    CFStringRef newUniqueIDString =
    CFUUIDCreateString (kCFAllocatorDefault, newUniqueID);
    
    NSString *key  =  (__bridge NSString*)newUniqueIDString;
     */
    
    //self.key = [NSString stringWithFormat:@"%@.data",key];
   self.key = [self getCurrentDate];
    NSLog(@" new key %@",self.key);
    
}
-(NSString *)getCurrentDate{
    NSDate* now = [NSDate date];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm:ss"];
    
    
    NSString *theDate = [dateFormatter stringFromDate:now];
    NSString *theTime = [timeFormatter stringFromDate:now]; 
    
    NSString *modifiedTime =  [NSString stringWithFormat:@"/%@", theTime];

    NSString *dateString = [theDate stringByAppendingString:modifiedTime];
    
    theDate=nil;
    theTime=nil;
    
    return dateString;
}

- (NSString *)allImageViewsArchivePath
{
    // The returned path will be Sandbox/Documents/allsubviews.data
    // Both the saving and loading methods will call this method to get the same path,
    // preventing a typo in the path name of either method
    
    return pathIndocumentDirectory(@"saved.data");
}

@end

NSString *pathIndocumentDirectory(NSString *fileName)
{
    
    NSArray *documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask, YES);
    // Get one and only document directory from that list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    // Append passed in file name to that directory, return it
    return [documentDirectory stringByAppendingPathComponent:fileName];
}

