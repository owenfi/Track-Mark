//
//  SNViewController.m
//  Track Mark
//
//  Created by Owen Imholte on 10/12/13.
//  Copyright (c) 2013 Swinging Sultan. All rights reserved.
//

#import "SNViewController.h"

@interface SNViewController ()

@end

@implementation SNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.playbackPosition.value = 0.0;
    
    NSError *error;
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"dwell35" withExtension:@"m4a"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
    if(error)
        NSLog(@"ERROR LOADING: %@",error);
    
    NSUserDefaults *nsd = [NSUserDefaults standardUserDefaults];
    NSNumber *n = [nsd objectForKey:@"CurrentPosition"];
    self.player.currentTime = n.doubleValue;

    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(update:) userInfo:self repeats:YES];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressPlay:)];
    [self.playButton addGestureRecognizer:longPress];
}

-(void)longPressPlay:(id)sender {
    
    if(!isRemoveActionShowing) {
        isRemoveActionShowing = YES;
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Remove All Edits" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove Notes" otherButtonTitles:nil, nil];
        [actionSheet showInView:self.view];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0) {
        NSLog(@"Remove");
        [self wipeDefaults];
    } else if (buttonIndex == 1) {
        NSLog(@"Cancel");
    } else {
        NSLog(@"2");
    }
    isRemoveActionShowing = NO;
}

-(void)wipeDefaults {
    NSUserDefaults *nsd = [NSUserDefaults standardUserDefaults];
    [nsd removeObjectForKey:@"MISC"];
    [nsd removeObjectForKey:@"LINK"];
    [nsd removeObjectForKey:@"EDIT"];
    [nsd removeObjectForKey:@"CurrentPosition"];
}



-(void)update:(id)sender {
    CGFloat positionDiv = self.player.currentTime / self.player.duration;
    self.playbackPosition.value = positionDiv;
    
    [self updateDetails];
    
    NSUserDefaults *nsd = [NSUserDefaults standardUserDefaults];
    [nsd setObject:[NSNumber numberWithDouble:self.player.currentTime] forKey:@"CurrentPosition"];
}

-(void)updateDetails {
    
    self.playbackDetails.text = [NSString stringWithFormat:@"%@ of %@",
                                 [self timestring:self.player.currentTime],
                                 [self timestring:self.player.duration]];
}

-(NSString *)timestring:(double)input {
    NSInteger ti = (NSInteger)input;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);

    if (hours > 0) {
        return [NSString stringWithFormat:@"%d:%02d:%02d",hours,minutes,seconds];
    } else {
        return [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)sliderMove:(id)sender{
    
    CGFloat newTime = self.player.duration * self.playbackPosition.value;
    self.player.currentTime = newTime;
    
    [self updateDetails];
    
}

-(IBAction)backButton:(id)sender{
    NSTimeInterval time = self.player.currentTime;
    time = time - 46;
    
    if(time < 0)
        time = 0;
    
    self.player.currentTime = time;
}

-(IBAction)playButton:(id)sender{

    if([self.player isPlaying]) {
        [self.player pause];
    } else {
        [self.player play];
    }
}

-(IBAction)sendButton:(id)sender{
    NSUserDefaults *nsd = [NSUserDefaults standardUserDefaults];
    NSArray *one = [nsd objectForKey:@"MISC"];
    NSArray *two = [nsd objectForKey:@"LINK"];
    NSArray *thr = [nsd objectForKey:@"EDIT"];
    [self openMail:[NSString stringWithFormat:@"Message:\n%@ %@ %@",one,two,thr] ];
}


- (void)openMail:(NSString*)message
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:@"Podcast Edit Details"];
        NSArray *toRecipients = [NSArray arrayWithObjects:@"owenimholte@mac.com", nil];
        [mailer setToRecipients:toRecipients];
        //UIImage *myImage = [UIImage imageNamed:@"mobiletuts-logo.png"];
        //NSData *imageData = UIImagePNGRepresentation(myImage);
        //[mailer addAttachmentData:imageData mimeType:@"image/png" fileName:@"mobiletutsImage"];
        [mailer setMessageBody:message isHTML:NO];
        [self presentViewController:mailer animated:YES completion:^{
            NSLog(@"That's all");
        }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:^{
        //La tee dah<#code#>
    }];
}

-(void)logEvent:(NSString*)type {
    NSUserDefaults *nsd = [NSUserDefaults standardUserDefaults];
    NSArray *items = [nsd objectForKey:type];
    if(items == nil)
        items = @[];
    
    NSMutableArray *mutey = [NSMutableArray arrayWithArray:items];
    
    NSString *nextItem = [NSString stringWithFormat:@"%@ %@",type,[self timestring:self.player.currentTime]];
    
    [mutey addObject:nextItem];
    items = [NSArray arrayWithArray:mutey];
    
    [nsd setObject:items forKey:type];
}

-(IBAction)miscButton:(id)sender{
    [self logEvent:@"MISC"];
}
-(IBAction)linkButton:(id)sender{
    [self logEvent:@"LINK"];
}
-(IBAction)editButton:(id)sender{
    [self logEvent:@"EDIT"];
}

@end
