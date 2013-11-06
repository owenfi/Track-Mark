//
//  SNURLCell.m
//  Track Mark
//
//  Created by Owen Imholte on 11/6/13.
//  Copyright (c) 2013 Swinging Sultan. All rights reserved.
//

#import "SNURLCell.h"

@implementation SNURLCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)downloadFile:(id)sender {
    NSLog(@"Download now");
    [self.path resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"Return key pressed");
    [textField resignFirstResponder];
    return YES;
}

-(void)validateURLAndDownload {
    
    
    
}

-(BOOL)checkValidURL:(NSString*)testURL {
    return NO;
}

-(void)startDownload {
    // I think I might push this into the app delegate or some related class to keep the DLs
    // in progress while allowing this view to be closed and cleaned up.
}

@end
