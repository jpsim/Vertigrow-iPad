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
-(void)setupView;
@end

@implementation WorkBenchAppDelegate

@synthesize window = _window;
@synthesize savedObjectsArray=_savedObjectsArray;
@synthesize splitViewController=_splitViewController;
@synthesize fileNamesArray=_fileNamesArray;
@synthesize fileName=_fileName;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    
    self.splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [self.splitViewController.viewControllers lastObject];
    self.splitViewController.delegate = (id)navigationController.topViewController;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupView:)
                                                 name:@"MyNotification" object:nil];
    
           
    return YES;
}
-(void)setupView:(NSNotification *)notification{
    
    int index = [[[notification userInfo] valueForKey:@"index"] intValue];
    NSLog(@"i have got %d",index);
    
    [self fetchubViewsIfNecessary];
    if(self.savedObjectsArray){
        
        for (ThumbImageView *subview in self.savedObjectsArray) {
            [[[[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] view] addSubview:subview];
            [subview setDelegate:[[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] ];
            
        }
    }
    
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
    
    //save all objects on the detailImageView in savedObjectsArray array
    //self.savedObjectsArray = [[NSMutableArray alloc] init];

    NSLog(@"the first time");
    CFUUIDRef newUniqueID = CFUUIDCreate (kCFAllocatorDefault);
    
    // Create a string from unique identifier
    CFStringRef newUniqueIDString =
    CFUUIDCreateString (kCFAllocatorDefault, newUniqueID);
    
    NSString *key  =  (__bridge NSString*)newUniqueIDString;
    self.fileName = [NSString stringWithFormat:@"%@.data",key];
    
   
    [self.savedObjectsArray addObjectsFromArray:[[[[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] view] subviews]];
    
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
- (void)fetchubViewsIfNecessary
{
    NSLog(@"i am in fetchubViewsIfNecessary");
    if(!self.fileName){
        self.fileName = [[NSUserDefaults standardUserDefaults] objectForKey:filenamePrefKey];
         NSLog(@"the name of the file %@",self.fileName);
    }else{
        NSLog(@"the self.fileName is empty");
    }
    // If we don't currently have an self.savedObjectsArray array, try to read one from disk
    if (!self.savedObjectsArray) {
        NSLog(@"file path: %@",[self allImageViewsArchivePath]);
        NSString *path =[self allImageViewsArchivePath];
        self.savedObjectsArray  = [NSKeyedUnarchiver unarchiveObjectWithFile:path] ;
        
    }
    // If we tried to read one from disk but does not exist, then create a new one
    if (!self.savedObjectsArray) {
        self.savedObjectsArray = [[NSMutableArray alloc] init];    
    }
    /*if(!self.fileNamesArray){
        NSString *pathToFileNames = pathIndocumentDirectory(@"fileNames.data");
        self.fileNamesArray = [NSKeyedUnarchiver unarchiveObjectWithFile:pathToFileNames];
    }
    if(!self.fileNamesArray){
        self.fileNamesArray = [[NSMutableArray alloc] init]; 
    }*/
    
}
- (NSString *)allImageViewsArchivePath
{
    // The returned path will be Sandbox/Documents/allsubviews.data
    // Both the saving and loading methods will call this method to get the same path,
    // preventing a typo in the path name of either method
    
    return pathIndocumentDirectory(self.fileName);
}
- (BOOL)saveChanges
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (ThumbImageView *view in self.savedObjectsArray) {
        [array insertObject:view.imageName atIndex:0];
        
    }
    [[NSUserDefaults standardUserDefaults] setObject:self.fileName forKey:filenamePrefKey];
    
    return ([NSKeyedArchiver archiveRootObject: self.savedObjectsArray
                                        toFile:[self allImageViewsArchivePath]]);
   
           
}
@end
