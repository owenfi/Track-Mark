//
//  SNViewController.h
//  Track Mark
//
//  Created by Owen Imholte on 10/12/13.
//  Copyright (c) 2013 Swinging Sultan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MessageUI.h>

@interface SNViewController : UIViewController <MFMailComposeViewControllerDelegate, UIActionSheetDelegate> {
    bool isRemoveActionShowing;
}

@property (nonatomic, retain) AVAudioPlayer *player;
@property (nonatomic, retain) NSTimer *updateTimer;
@property (nonatomic, retain) IBOutlet UISlider *playbackPosition;
@property (nonatomic, retain) IBOutlet UILabel *playbackDetails;
@property (nonatomic, retain) IBOutlet UIButton *playButton;

-(IBAction)sliderMove:(id)sender;
-(IBAction)backButton:(id)sender;
-(IBAction)playButton:(id)sender;
-(IBAction)sendButton:(id)sender;

-(IBAction)miscButton:(id)sender;
-(IBAction)linkButton:(id)sender;
-(IBAction)editButton:(id)sender;

@end
