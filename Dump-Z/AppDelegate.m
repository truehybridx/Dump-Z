//
//  AppDelegate.m
//  Dump-Z
//
//  Created by Brandon Etheredge on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "BEDumpController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize destLabel = _destLabel;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    [self updateLabel];
    
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
    NSLog(@"%@", filename);
    return YES;
}

- (void)updateLabel
{
    NSUserDefaults *appSettings = [NSUserDefaults standardUserDefaults];
    
    
    NSString *destValue = [appSettings stringForKey:@"savedDestination"];
    
    if (destValue == nil) {
        [_destLabel setStringValue:@"Not Set, Please use Button"];
    } else {
        [_destLabel setStringValue:destValue];
    }
}

-(IBAction)destButtonClicked:(id)sender
{
    NSUserDefaults *appSettings = [NSUserDefaults standardUserDefaults];
    
    // Prompt the user for a destination directory.
    BEDumpController *dumpController = [[BEDumpController alloc] init];
    NSOpenPanel *destinationPanel	= [NSOpenPanel openPanel];
    [destinationPanel setCanChooseDirectories:YES];
    [destinationPanel setCanCreateDirectories:YES];
    [destinationPanel runModal];
    
    NSString *destinationPath = [destinationPanel.URLs.lastObject path];
    
    [appSettings setObject:destinationPath forKey:@"savedDestination"];
    [appSettings synchronize];
    
    [_destLabel setStringValue:destinationPath];
    
    [dumpController release];
    
}


@end
