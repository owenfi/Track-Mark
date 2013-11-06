//
//  SNLoadFileViewController.m
//  Track Mark
//
//  Created by Owen Imholte on 10/21/13.
//  Copyright (c) 2013 Swinging Sultan. All rights reserved.
//

#import "SNLoadFileViewController.h"

@interface SNLoadFileViewController ()

@end

@implementation SNLoadFileViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    for (int count = 0; count < (int)[directoryContent count]; count++)
    {
        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
    }
    
    files = [NSMutableArray arrayWithArray:directoryContent];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(section == 0)
        return @"Download:";
    
    if(section == 1)
        return @"Local files:";
    
    if(section == 2)
        return @"Sample:";
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) {
        return 1 + [self.inProgressDownloads count];
    }

    if(section == 1)
        return [files count];
    
    if(section == 2)
        return 1;
    
    return 0;
}

-(NSUInteger)fileIndexForIndexPath:(NSIndexPath*)indexPath {
    
    return indexPath.row;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *URLCellId = @"URLCell";
    
    if(indexPath.section == 0 && indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:URLCellId];
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    // Load the Documents directory file list
    if(indexPath.section == 1) {
        cell.textLabel.text = [[files objectAtIndex:[self fileIndexForIndexPath:indexPath]] stringByRemovingPercentEncoding];
        cell.detailTextLabel.text = @"Row";
    }
    
    if(indexPath.section == 2) {
        cell.textLabel.text = @"Load this empty track to annotate live sessions.";
    }

    // Configure the cell...
    
    return cell;
}

-(IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
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
        [self deleteFileAtIndexPath:indexPath];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(void)deleteFileAtIndexPath:(NSIndexPath*)indexPath {

    dispatch_queue_t queue;
    queue = dispatch_queue_create("com.swingingsultan.filequeue", NULL);
    dispatch_async(queue, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filename = [files objectAtIndex:[self fileIndexForIndexPath:indexPath]];
        
        NSURL *filePath = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:filename]];
        
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:[filePath path] error:&error];
        if(error != nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Delete" message:[error description] delegate:nil cancelButtonTitle:@"Yikes" otherButtonTitles:nil, nil];
            [alert show];
        }
    });
    
    
    [files removeObjectAtIndex:[self fileIndexForIndexPath:indexPath]];

}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}



#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SNViewController *vc = self.delegate;
    [vc loadFileNamed:[files objectAtIndex:[self fileIndexForIndexPath:indexPath]]];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        // Done
    }];
    
}


@end
