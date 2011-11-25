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
-(void)saveProject:(NSNotification *)notification;
-(void)createNewProject:(NSNotification *)notification;
-(void)grabText:(NSNotification *)notification;
-(void)addEntryToDictionary;
-(void)addEmptyEntryToDictionary;
-(NSString *)getCurrentDate;


@end

@implementation WorkBenchAppDelegate

@synthesize window = _window;
@synthesize splitViewController=_splitViewController;
@synthesize keysArray=_keysArray;
@synthesize key=_key;
@synthesize toBeSavedDictionary=_toBeSavedDictionary;
@synthesize textToAdd=_textToAdd;
@synthesize projectSelected=_projectSelected;
@synthesize notesArray=_notesArray;
@synthesize currentIndex=_currentIndex;

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
                                             selector:@selector(saveProject:)
                                                 name:@"saveProjecttNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(grabText:)
                                                 name:@"textToBeAddedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(createNewProject:)
                                                 name:@"createNewProjectNotification" object:nil];
    


    
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
//receive the text that is passed by detailviewcontroller
-(void)grabText:(NSNotification *)notification{
   
    NSString *text = [[notification userInfo] valueForKey:@"textToBeAdded"];
    NSLog(@"receive the text--%@-- that is passed from detailviewcontroller",text);
    
    if(text){ 
        
        NSLog(@"check the index of selected row --%d--intable",self.currentIndex);
        //check the index of selected row intable
        if(self.currentIndex>=0){
        
            //grab the text saved on disk from previous sesion
            //NSString *temp= [self.notesArray objectAtIndex:self.currentIndex];  
            //NSLog(@"grab the text saved on disk from previous sesion --%@--",temp);
            
            if([text length]>0){
                //temp = [temp stringByAppendingString:[NSString stringWithFormat: @"%@\t", text]];
            
                //update dictionary with the new value
                NSUInteger indexOfLastObject = [[self.toBeSavedDictionary objectForKey:self.key] count];
                [[self.toBeSavedDictionary objectForKey:self.key] replaceObjectAtIndex:(indexOfLastObject-1) withObject:text];
            
                [self.notesArray replaceObjectAtIndex:self.currentIndex withObject:text];
                }
            //temp=nil;
            
            NSLog(@"add the recieved text to the text from the revious session --%@--: ",[self.notesArray objectAtIndex:self.currentIndex]);
            
            }else{
        
                NSLog(@"no project is selected!");
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                          message:@"Please select a project first!"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
                [message show];
                message=nil;

            }
    }
}
-(void)createNewProject:(NSNotification *)notification{

    self.key=nil;
    self.currentIndex=-1;
    self.textToAdd=@"";
    
    [self clearDetailControllerMainView];
    
    [self addEmptyEntryToDictionary];
    NSLog(@"create a new project by adding a an empty entry to dictionary");
     
   /* 
    NSDictionary* dicti = [NSDictionary dictionaryWithObject:self.notesArray forKey:@"notesArrayToUpdate"];
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"notesArrayToUpdateNotification" object:self userInfo:dicti];
    dicti=nil;

    NSLog(@"self.notesArray count %d", [self.notesArray count]);
    
    */
    NSDictionary* dict = [NSDictionary dictionaryWithObject:self.textToAdd forKey:@"selftextToAdd"];
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"selftextToAddNotification" object:self userInfo:dict];
    dict=nil;
    [self  setUptTableView];
    self.projectSelected=NO;
    
}
-(void)addEmptyEntryToDictionary{
    
    //add an empty entry to the dictionary
    
    [self createKey];
    
    //NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSMutableArray *allsubviewsPropertiesArray = [[NSMutableArray alloc] init]; 
    
    //[allsubviewsPropertiesArray addObject:array];    
    [allsubviewsPropertiesArray addObject:@""];
    
    [self.toBeSavedDictionary setObject:allsubviewsPropertiesArray forKey:self.key];
    
    allsubviewsPropertiesArray=nil;
    
    //when an empty entry is added to the dictionary self.keysArray should be updated
    self.keysArray=nil;
    self.keysArray = [[NSMutableArray alloc] init];
    [self.keysArray addObjectsFromArray:[self.toBeSavedDictionary allKeys]];
    
    //when an empty entry is added to the dictionary self.notesArray should be updated
    self.notesArray=nil;
    self.notesArray = [[NSMutableArray alloc] init];
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:[self.toBeSavedDictionary allValues]];
    for (NSMutableArray *value in temp) {
        
        [self.notesArray addObject:[value lastObject]];
    } 
    temp=nil;
    
}
-(void)saveProject:(NSNotification *)notification{
    
    NSLog(@"--saveProject--");
    if(self.currentIndex!=-1){
        
        [self addEntryToDictionary];
    
        //self.keysArray=nil;
        //self.keysArray = [[NSMutableArray alloc] init];
        //[self.keysArray addObjectsFromArray:[self.toBeSavedDictionary allKeys]];
    
        //self.dict=nil;
        //self.dict = [NSDictionary dictionaryWithObject:self.keysArray forKey:@"keysArray"];
        //[self  setUptTableView];
    
        //[self clearDetailControllerMainView];
        //self.key=nil;
    }else{
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                          message:@"Please select a project first!"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
        message=nil;
    }
}

-(void)clearDetailControllerMainView{
    
    NSMutableArray *subviewsToBeeleted =[[NSMutableArray alloc] initWithArray:[[[[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] view] subviews]];
    
    for (ThumbImageView *view in subviewsToBeeleted) {
        [view removeFromSuperview];
    }
    subviewsToBeeleted= nil;
}
-(void)setUptTableView{
    
    NSLog(@"setUptTableView is called and self.keyArray is passed to masterViewController!");
    NSDictionary *dict = [NSDictionary dictionaryWithObject:self.keysArray forKey:@"keysArray"];
    NSLog(@"self.keysArray has %d elements before it is passed to masterViewController",[self.keysArray count] );
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"setUptTableViewNotification" object:self userInfo:dict];
    
}

-(void)updateDictionary:(NSNotification *)notification{
    
    NSLog(@"updateDictionary is called!");
    self.currentIndex=-1;
    self.textToAdd=@"";
    
    NSUInteger index = [[[notification userInfo] valueForKey:@"keyTobeRemoved"] intValue];
    
    NSString *keytTobeRemoved = [[self.toBeSavedDictionary allKeys] objectAtIndex:index];
    [self.toBeSavedDictionary removeObjectForKey:keytTobeRemoved];
    
    //update keys array 
    self.keysArray=nil;
    self.keysArray = [[NSMutableArray alloc] init];
    [self.keysArray addObjectsFromArray:[self.toBeSavedDictionary allKeys]];
    
    self.key=nil;

    //I have to update self.notesArray; The above code delete the whole array including the note as well
    self.notesArray=nil;
    self.notesArray = [[NSMutableArray alloc] init];
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:[self.toBeSavedDictionary allValues]];

    for (NSMutableArray *value in temp) {
        [self.notesArray addObject:[value lastObject]];  
        
    } 
    temp=nil;
    
    //NSLog(@"self.keysArray %d", [self.keysArray count]);
    NSLog(@"the current key is: %@ ", self.key);
    [self clearDetailControllerMainView];
    
}
-(void)setupSubviews:(NSNotification *)notification{
    

    [self clearDetailControllerMainView];
    NSLog(@"clearDetailControllerMainView is called to clean up detailview from all its subviews");
    
    NSInteger index = [[[notification userInfo] valueForKey:@"index"] intValue];
    NSLog(@"setupSubviews is called because a row number %d is selected",index);
    
    self.currentIndex=index;
    NSLog(@"self.currentIndex is updated to the selected row index");
    
    self.projectSelected= YES;
    
    //get the key for the selected project in tableview
    self.key = [self.keysArray objectAtIndex:index];
    NSLog(@"Now we get the key  for the selected row from self.keysArray and initialize the self.key to --%@-- , this is the key for the currently selected row", self.key);
    
    self.textToAdd = [self.notesArray objectAtIndex:index];
    NSLog(@"Grab the text and send it to detailviewcontroller to be shown in modal view for notes --%@--", self.textToAdd);
    
    //send self.textToAdd to detailviewcontroller
    NSDictionary* dict = [NSDictionary dictionaryWithObject:self.textToAdd forKey:@"selftextToAdd"];
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"selftextToAddNotification" object:self userInfo:dict];
    dict=nil;
    
    /*
    NSDictionary* dicti = [NSDictionary dictionaryWithObject:self.notesArray forKey:@"notesArrayToUpdate"];
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"notesArrayToUpdateNotification" object:self userInfo:dicti];
    dicti=nil;
    */
    
    //get the array containing all the subviews serialized properties required for the recreation of suviews
    
    NSMutableArray *savedSubviewsArray = [self.toBeSavedDictionary objectForKey:self.key];
    
    //NSLog(@"there are %d subviews to be added!", [savedSubviewsArray count]);
    
    if(savedSubviewsArray && ![[savedSubviewsArray objectAtIndex:0] isKindOfClass:[NSString class]] ){

        //NSLog(@"savedSubviewsArray count : %d", [savedSubviewsArray count]);
        
          for(NSMutableArray *propertiesArray in savedSubviewsArray){
            
             
              if([ propertiesArray isKindOfClass:[NSString class]]){
                  NSLog(@"I grabbed %@ which is string so i continue to the next element!",propertiesArray);
                  continue;
              }
              
              //grab the name of the image file located on Supporting Files Directory
            NSString *fileName = [propertiesArray objectAtIndex:0];
            //NSLog(@" i am going to grab %@ image",fileName);
            
            //grab the imgae with the same file name
            UIImage *thumbImage = [UIImage imageNamed:fileName];
              
            // create the ThumbImageView to be added to the detailviewcontrollers's main view 
            ThumbImageView *addIt =  [[ThumbImageView alloc] initWithImage:thumbImage];
            
            //setup the properties of ThumbImageView
            addIt.imageName = [propertiesArray objectAtIndex:0]; 
            
            addIt.center = [[propertiesArray objectAtIndex:1] CGPointValue];
            //NSLog(@"addIt.center %@", NSStringFromCGPoint(addIt.center));
            
            addIt.bounds = [[propertiesArray objectAtIndex:2] CGRectValue]; 
            //NSLog(@"addIt.bounds: %@", NSStringFromCGRect(addIt.bounds));
            
            addIt.transform = [[propertiesArray objectAtIndex:3] CGAffineTransformValue];
            //NSLog(@"addIt.transform: %@",NSStringFromCGAffineTransform(addIt.transform));
            
            //add the image to the detailviewcontrollers's main view 
            [[[[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] view] addSubview:addIt];
            [addIt setDelegate:[[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] ];
        }
    }
    
    savedSubviewsArray= nil;

}

- (void)fetchubViewsIfNecessary
{
    NSLog(@"fetchubViewsIfNecessary is called when program runs for the first time");  
    self.projectSelected=NO;
    
    if(!self.toBeSavedDictionary){
        NSString *path =[self allImageViewsArchivePath];
        self.toBeSavedDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
    }
    
    if(!self.toBeSavedDictionary){
        self.toBeSavedDictionary = [NSMutableDictionary dictionary];
    }
    
    //if the dictionary is not empty it means there exists at least one project
    NSLog(@"initialize keysArray to an empty Array!");
    if(!self.keysArray){
        
        self.keysArray = [[NSMutableArray alloc] init];
    }
    NSLog(@"chck if there is any saved project on the disk, if yes then populate the keysArray with all the keys in the dictionary saved on the disk! ");
    if([self.toBeSavedDictionary count]>0){  
        
        [self.keysArray addObjectsFromArray:[self.toBeSavedDictionary allKeys]];
        
    }
    NSLog(@"initialize notesArray to an empty Array!");
    if(!self.notesArray){
        self.notesArray =[[NSMutableArray alloc] init];
    }
    
    //NSLog(@"count %d",[self.toBeSavedDictionary count]);
    NSLog(@"check to see if there is any saved project on the disk");
    if([self.toBeSavedDictionary count]>0){ 
        
        NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:[self.toBeSavedDictionary allValues]];
        
        //NSLog(@"temp count %d", [temp count]);
        for (NSMutableArray *value in temp) {
            [self.notesArray addObject:[value lastObject]];  
            
        } 
        //NSLog(@"self.notesArray count: %d",[self.notesArray count]);
        temp=nil;
        NSLog(@"iterate through all the projects and save related notes to a new array called self.notesArray which has %d elements",[self.notesArray count]);
    }
    
    if(!self.textToAdd){
        self.textToAdd=@"";
    }
    NSLog(@"self.currentIndex represents the index of selected row in the table, at this time it is initialized to -1 which means there is no project selected! ");
    
    self.currentIndex=-1;
   // NSLog(@"exit fetchubViewsIfNecessary");
    
}

- (BOOL)saveChanges
{
    NSLog(@"saveChanges");
  
    NSUInteger i=0;
    for (NSMutableArray *element in [self.toBeSavedDictionary allValues]) {
       
        NSUInteger lastIndex = [element count];
        
        [element replaceObjectAtIndex:(lastIndex-1) withObject:[self.notesArray objectAtIndex:i]];
        i++;
    }
    //[self addEntryToDictionary]; 
    
    return ([NSKeyedArchiver archiveRootObject: self.toBeSavedDictionary
                                        toFile:[self allImageViewsArchivePath]]);
    
}
-(void)addEntryToDictionary{
    
    NSLog(@"addEntryToDictionary is called!");
    
    //extract all subview from the detailview controller's main view
    NSMutableArray *allsubviewsArray = [[NSMutableArray alloc] init]; 
    
    [allsubviewsArray addObjectsFromArray:[[[[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] view] subviews]]; 
    
    //NSLog(@"allsubviewsArray: %d ", [allsubviewsArray count]);
    
    NSMutableArray *allsubviewsPropertiesArray = [[NSMutableArray alloc] init]; 
    if ([allsubviewsArray count]>0) {
        
        for (ThumbImageView *view in allsubviewsArray) {
            
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            
            [array insertObject:view.imageName atIndex:0];
            
            NSValue *frameCenter = [NSValue valueWithCGPoint:view.center];
            //NSLog(@"view.frameCenterForSerialization: %@", NSStringFromCGPoint(view.center));
            [array insertObject:frameCenter atIndex:1];
            
            
            NSValue *bound = [NSValue valueWithCGRect:view.bounds];
            //NSLog(@"view.boundForSerialization: %@", NSStringFromCGRect(view.bounds));
            [array insertObject:bound atIndex:2];
            
            NSValue *transform = [NSValue valueWithCGAffineTransform:view.transform];
            //NSLog(@"view.transformForSerialization: %@",NSStringFromCGAffineTransform(view.transform));
            [array insertObject:transform atIndex:3];
        
            
            [allsubviewsPropertiesArray addObject:array];
            array=nil;
        }
    }  
    
    NSString *temp = [[self.toBeSavedDictionary objectForKey:self.key] lastObject];
    [allsubviewsPropertiesArray addObject:temp];
    //NSLog(@"allsubviewsPropertiesArray count: %d",[allsubviewsPropertiesArray count]);
    if(!self.key){
        [self createKey];
    }
    [self.toBeSavedDictionary setObject:allsubviewsPropertiesArray forKey:self.key];
    //NSLog(@"self.toBeSavedDictionary count %d", [self.toBeSavedDictionary count]);
    
    allsubviewsArray=nil;
    allsubviewsPropertiesArray=nil;

}
-(void)createKey{

    /*CFUUIDRef newUniqueID = CFUUIDCreate (kCFAllocatorDefault);
    
    // Create a string from unique identifier
    CFStringRef newUniqueIDString =
    CFUUIDCreateString (kCFAllocatorDefault, newUniqueID);
    
    NSString *key  =  (__bridge NSString*)newUniqueIDString;
     */
    
    //self.key = [NSString stringWithFormat:@"%@.data",key];
   self.key = [self getCurrentDate];
   NSLog(@"createKey is called and key: %@  is created!",self.key);
    
}
-(NSString *)getCurrentDate{
    NSLog(@"getCurrentDate");
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

