//
//  AppDelegate.h
//  Dump-Z
//
//  Created by Brandon Etheredge on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) IBOutlet NSTextField *destLabel;

-(IBAction)destButtonClicked:(id)sender;

- (void)updateLabel;


@end
