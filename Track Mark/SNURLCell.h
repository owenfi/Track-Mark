//
//  SNURLCell.h
//  Track Mark
//
//  Created by Owen Imholte on 11/6/13.
//  Copyright (c) 2013 Swinging Sultan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNURLCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet UITextField *path;
-(IBAction)downloadFile:(id)sender;

@end
