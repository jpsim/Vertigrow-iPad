//
//  WorkBenchMasterViewController.m
//  WorkBench
//
//  Created by hamid poursepanj on 11-11-13.
//  Copyright (c) 2011 uottawa. All rights reserved.
//

#import "WorkBenchMasterViewController.h"
#import "WorkBenchDetailViewController.h"

@interface WorkBenchMasterViewController (utilities) 
-(void)setupTableViewForKeys:(NSNotification *)notification;
//-(void)grabNotesArray:(NSNotification *)notification;
-(void)addCreateNewProjectButtonNavigationController;
@end

@implementation WorkBenchMasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize isVisible=_isVisible;
@synthesize savedData=_savedData;
//@synthesize notesArray=_notesArray;
- (void)awakeFromNib

{  
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    
    //set up tableview 
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupTableViewForKeys:)
                                                 name:@"setUptTableViewNotification" object:nil];
    
    /*[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(grabNotesArray:)
                                                 name:@"notesArrayToUpdateNotification" object:nil];*/
    
    
    [super awakeFromNib];
    
    
}
/*-(void)grabNotesArray:(NSNotification *)notification{
    if(!self.notesArray){
        self.notesArray = [[notification userInfo] valueForKey:@"notesArrayToUpdate"];
    }
    if (!self.notesArray) {
        self.notesArray = [[NSMutableArray alloc] init];
    }
    if(self.notesArray){
        self.notesArray = [[notification userInfo] valueForKey:@"notesArrayToUpdate"];
    }
}*/
-(void)setupTableViewForKeys:(NSNotification *)notification{
    
    //update self.savedData with the new self.keysArray
    if(self.savedData){
        
        self.savedData = [[NSMutableArray alloc] init];
        self.savedData = [[notification userInfo] valueForKey:@"keysArray"];
        NSLog(@"i am populating self.savedData with self.keysArray again! but why?");
    }
    NSLog(@"setupTableViewForKeys method in mastredetail controller is called ");
    if(!self.savedData){
        self.savedData = [[notification userInfo] valueForKey:@"keysArray"];
        NSLog(@"self.savedData is populated with self.keysarray data and has %d elements", [self.savedData count]);
    }
    if (!self.savedData) {
        self.savedData = [[NSMutableArray alloc] init];
        NSLog(@"self.saveData is initialized to an empty array because there self.keysArray is empty");
    }
    
    [self.tableView reloadData];
    
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
	// Do any additional setup after loading the view, typically from a nib.
    self.detailViewController = (WorkBenchDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    //[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    [self addCreateNewProjectButtonNavigationController];
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
    self.isVisible= YES;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    self.isVisible=NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}
-(void)addCreateNewProjectButtonNavigationController{
    
    //add button to master controller
    UIBarButtonItem *bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewProject:)];
    bi.width = 20.0f;
    
    [[[[self.splitViewController.viewControllers objectAtIndex:0] viewControllers] objectAtIndex:0] navigationItem].rightBarButtonItem =bi;
    bi=nil;

}
- (IBAction)createNewProject:(id)sender{
    NSLog(@"a notification sent to AppDelegate asking for creation of a new project");
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"createNewProjectNotification" object:self userInfo:nil];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight );
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section{
    return [self.savedData count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    //Configure the cell.
    NSUInteger row = [indexPath row];
    cell.textLabel.text = [self.savedData objectAtIndex:row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSUInteger row = [indexPath row];
    
    NSString *projectDate = [self.savedData objectAtIndex:row];
    NSLog(@"row number %d with the content of --%@-- is selected",row,projectDate);
    
    [[[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] navigationItem].title=projectDate;
    
    NSDictionary* dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:row] forKey:@"index"];
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"setupSubviewsNotification" object:self userInfo:dict];
    NSLog(@"the index for selected row is passed to AppDelegate via notification");
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        
        NSUInteger row = [indexPath row]; 
        NSLog(@"key for the row to be removed: %@ ",[self.savedData objectAtIndex:row]);
        
        [self.savedData removeObjectAtIndex:row];
        //NSLog(@"self.savedData count %d",[self.savedData count]);
        
        //send a notification to appdelegate to delete the related key-value from dictionary
        NSDictionary* dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:row] forKey:@"keyTobeRemoved"];
        [[NSNotificationCenter defaultCenter]  postNotificationName:@"updateDictionaryNotification" object:self userInfo:dict];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        //update the title of the detailviewcontroller
        [[[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] navigationItem].title=@"New Project";
        
    }else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

@end
