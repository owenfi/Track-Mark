//
//  SNAppDelegate.m
//  Track Mark
//
//  Created by Owen Imholte on 10/12/13.
//  Copyright (c) 2013 Swinging Sultan. All rights reserved.
//

#import "SNAppDelegate.h"

@implementation SNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    NSURL *url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    if ([url isFileURL])
    {
        // Handle file being passed in
        
    }
    else
    {
        // Handle custom URL scheme
    }
    
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    //Move the file from Documents/Inbox to Documents/
    
    // TODO: Could make this just iterate across all files in inbox
    dispatch_queue_t queue;
    queue = dispatch_queue_create("com.swingingsultan.filequeue", NULL);
    dispatch_async(queue, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filename = [[url absoluteString] lastPathComponent];
        
        NSURL *filePath = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:filename]];
        
        NSError *error;
        [[NSData dataWithContentsOfURL:url] writeToURL:filePath options:NSDataWritingFileProtectionNone error:&error];
        
        if(error != nil)
            NSLog(@"ERROR: Unable to save file %@",error);
        else {
            [[NSFileManager defaultManager] removeItemAtPath:[url path] error:&error];
            
            if(error != nil)
                NSLog(@"ERROR: Unable to remove %@",error);
        }
        
        //TODO: If the VC has no notes or loaded file then open this file right away

    });

    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
