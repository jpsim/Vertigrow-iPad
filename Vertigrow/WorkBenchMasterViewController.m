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
@end

@implementation WorkBenchMasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize isVisible=_isVisible;
@synthesize savedData=_savedData;

- (void)awakeFromNib

{  
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    
    //set up tableview 
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupTableViewForKeys:)
                                                 name:@"setUptTableViewNotification" object:nil];
    
    
    [super awakeFromNib];
    
    
}
-(void)setupTableViewForKeys:(NSNotification *)notification{
    if(!self.savedData){
        self.savedData = [[notification userInfo] valueForKey:@"keysArray"];
    }
    if (!self.savedData) {
        self.savedData = [[NSMutableArray alloc] init];
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
	// Do any additional setup after loading the view, typically from a nib.
    self.detailViewController = (WorkBenchDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    //[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    
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
    NSDictionary* dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:row] forKey:@"index"];
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"setupSubviewsNotification" object:self userInfo:dict];
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
        [self.savedData removeObjectAtIndex:row];
        NSLog(@"self.savedData count %d",[self.savedData count]);
        //send a notification to appdelegate to delete the related key-value from dictionary
        NSDictionary* dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:row] forKey:@"keyTobeRemoved"];
        [[NSNotificationCenter defaultCenter]  postNotificationName:@"updateDictionaryNotification" object:self userInfo:dict];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
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
