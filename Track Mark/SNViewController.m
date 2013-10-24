//
//  SNViewController.m
//  Track Mark
//
//  Created by Owen Imholte on 10/12/13.
//  Copyright (c) 2013 Swinging Sultan. All rights reserved.
//

#import "SNViewController.h"
#import "SNLoadFileViewController.h"

@interface SNViewController ()

@end

@implementation SNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSUserDefaults *nsd = [NSUserDefaults standardUserDefaults];

    [self loadFileNamed:[nsd objectForKey:@"CurrentFileName"]];

    NSNumber *n = [nsd objectForKey:@"CurrentPosition"];
    self.player.currentTime = n.doubleValue;
    self.playbackPosition.value = self.player.currentTime;

    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(update:) userInfo:self repeats:YES];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressPlay:)];
    [self.playButton addGestureRecognizer:longPress];
}

-(void)loadFileNamed:(NSString*)filename {
    
    if(filename != nil) {
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:filename];
        
        NSURL *audioPath = [NSURL fileURLWithPath:filePath];
        
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioPath error:&error];
        if(error) {
            NSLog(@"ERROR LOADING: %@",error);
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:filename forKey:@"CurrentFileName"];
        }
    }
}


-(void)longPressPlay:(id)sender {
    
    if(!isRemoveActionShowing) {
        //If any edits exist then show warning, otherwise
        
        if([self isAnyEditMade]) {
            
            isRemoveActionShowing = YES;
            
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Loading a new file will remove annotations." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove Annotations and Load" otherButtonTitles:nil, nil];
            [actionSheet showInView:self.view];
            
        } else {
            
            [self loadNewAudioFile];
            
        }
        

    }
}

-(BOOL)isAnyEditMade {
    
    NSUserDefaults *nsd = [NSUserDefaults standardUserDefaults];
    NSArray *a = [nsd objectForKey:@"MISC"];
    NSArray *b = [nsd objectForKey:@"LINK"];
    NSArray *c = [nsd objectForKey:@"EDIT"];
    
    if(a.count > 0 || b.count > 0 || c.count > 0) {
        return TRUE;
    }
    
    return FALSE;
}

-(void)loadNewAudioFile {
    // First remove
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    UIViewController *uivc = [storyboard instantiateViewControllerWithIdentifier:@"Loader"];
    SNLoadFileViewController *loadFileTableVC = uivc.childViewControllers[0];
    loadFileTableVC.delegate = self;
    
    [self presentViewController:uivc animated:YES completion:^{
        // Done showing
    }];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0) {
        NSLog(@"Remove");
        [self wipeDefaults];
        [self loadNewAudioFile];
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
    if (isScrubbing) {
        // Do nothing if scrubbing
        
    } else {
        CGFloat positionDiv = self.player.currentTime / self.player.duration;
        self.playbackPosition.value = positionDiv;
        
        [self updateDetails:self.player.currentTime];
    }
    
    NSUserDefaults *nsd = [NSUserDefaults standardUserDefaults];
    [nsd setObject:[NSNumber numberWithDouble:self.player.currentTime] forKey:@"CurrentPosition"];
}

-(void)updateDetails:(NSTimeInterval)theTime {
    
    NSString *filePrettyStr = [[self.player.url absoluteString] lastPathComponent];
    filePrettyStr = [filePrettyStr stringByRemovingPercentEncoding];
    filePrettyStr = [filePrettyStr stringByRemovingPercentEncoding]; //silly but there are double percent encoded strings (i.e. a %25 followed be 20, which expands to %20...)
    self.playbackDetails.text = [NSString stringWithFormat:@"%@ of %@ for file %@",
                                 [self timestring:theTime],
                                 [self timestring:self.player.duration],
                                 filePrettyStr];
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
    isScrubbing = YES;
    
    CGFloat newTime = self.player.duration * self.playbackPosition.value;
//    self.player.currentTime = newTime;
    
    [self updateDetails:newTime];
    
}

-(IBAction)sliderTouchUp:(id)sender {
    CGFloat newTime = self.player.duration * self.playbackPosition.value;
    self.player.currentTime = newTime;
    [self updateDetails:self.player.currentTime];
    isScrubbing = NO;
}

-(IBAction)backButton:(id)sender{
    NSTimeInterval time = self.player.currentTime;
    time = time - 45;
    
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
    
    NSString *filename = [[self.player.url absoluteString] lastPathComponent];
    [self openMail:[NSString stringWithFormat:@"Details for file:%@\n%@ %@ %@",filename,one,two,thr]];
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
