//
//  SNLoadFileViewController.h
//  Track Mark
//
//  Created by Owen Imholte on 10/21/13.
//  Copyright (c) 2013 Swinging Sultan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNViewController.h"

@interface SNLoadFileViewController : UITableViewController {
    NSMutableArray *files;
}

@property (nonatomic, weak) id delegate;

-(IBAction)cancel:(id)sender;

@end
