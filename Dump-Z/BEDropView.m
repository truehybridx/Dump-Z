//
//  BEDropView.m
//  Dump-Z
//
//  Created by Brandon Etheredge on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BEDropView.h"
#import "AppDelegate.h"

@implementation BEDropView
@synthesize nsImageObj;


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    self.nsImageObj = nil;
    
    [self registerForDraggedTypes:[NSArray arrayWithObjects: 
								   NSFilenamesPboardType, nil]];
    
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor blackColor] set];
    NSRectFill( dirtyRect );

    [super drawRect:dirtyRect];
} // end drawRect


#pragma mark - Draggin Functions

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask]) 
		== NSDragOperationGeneric) {
		
        return NSDragOperationGeneric;
		
    } // end if
	
    // not a drag we can use
	return NSDragOperationNone;	
	
} // end draggingEntered

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
    return YES;
} // end prepareForDragOperation




- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *zPasteboard = [sender draggingPasteboard];
	
    NSURL *urlFromPasteboard = [NSURL URLFromPasteboard:zPasteboard];
    
    NSString *pathString = [self removeFilePrefixFromString:[urlFromPasteboard absoluteString]];
    
    // Start processing the given file
    [self processFileAtPath:pathString];
    
    return YES;
    	
} // end performDragOperation


- (void)concludeDragOperation:(id <NSDraggingInfo>)sender {
   // [self setNeedsDisplay:YES];
} // end concludeDragOperation


#pragma mark - My Stuff

-(void)processFileAtPath:(NSString*)path
{
    NSLog(@"Processing File Path");
    
    NSString *workingPath;
    NSString *destinationPath;
    // Check if the path is to a directory (App Bundle) or a Binary
    // If its to a directory, try to find the binary
    // If its to a binary, prompt for a save location, class-dump it
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDir] && isDir) {
        // Attempt to find the binary
        workingPath = [self binaryPathFromDirectoryPath:path];
    } else {
        // Is not a directory, so we will assume its the binary
        workingPath = path;
    }
    
    // One last check to make sure of valid File Path
    if (! [fileManager fileExistsAtPath:workingPath]) {
        NSLog(@"Bad File Name");
        // Alert the user and return
        [self alertBadFileDrop];
        return;
    }
    
    // We should have a valid path to a binary by now

    
    // Prompt the user for a destination directory.
    NSOpenPanel *destinationPanel	= [NSOpenPanel openPanel];
    [destinationPanel setCanChooseDirectories:YES];
    [destinationPanel setCanCreateDirectories:YES];
    NSInteger panelInt = [destinationPanel runModal];
    
    if (panelInt == NSOKButton) {
        NSLog(@"Ok button pressed");
    } else if (panelInt == NSCancelButton) {
        NSLog(@"Cancel Button Pressed");
    } else {
        NSLog(@"Something Else was pressed 0_o");
    }
    
    destinationPath = [self removeFilePrefixFromString:[[destinationPanel URLs].lastObject absoluteString]];
    
    NSLog(@"Destination Path is %@", destinationPath);
    // SHould have workingPath and destinationPath now, make it happen
    
    [self classDumpWithPath:workingPath andDestination:destinationPath];
    
}

-(void)classDumpWithPath:(NSString*)path andDestination:(NSString*)destination
{
    if (path == nil || destination == nil || [path isEqualToString:@""] || [destination isEqualToString:@""]) {
        NSLog(@"Something went wrong. Path or Destination is invalid");
        return;
    }
    
    // Verify the path... maybe too much??
    NSFileManager *fileMan = [NSFileManager defaultManager];
    if (![fileMan fileExistsAtPath:path]) {
        NSLog(@"SOurce file doesnt exist... HOW?!?");
        return;
    }
    
    // Start NSTask
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:[[NSBundle mainBundle] pathForResource:@"class-dump-z" ofType:@""]];
    
    NSArray *args = [NSArray arrayWithObjects:@"-H", [NSString stringWithFormat:@"%@", path], @"-o", [NSString stringWithFormat:@"%@", destination], nil];
    
    [task setArguments:args];
    [task launch];
    [task waitUntilExit];

    int retStat = [task terminationStatus];
    [task release];
    
    // Check for output
    if (retStat == 0) {
        NSLog(@"All was well");
        [self alertSuccesfulDumpWithDestination:destination];
    } else {
        NSLog(@"Something bad happened");
    }


}

// Get the binary path in case the user dropped an app bundle
-(NSString *)binaryPathFromDirectoryPath:(NSString*)directory
{
    NSString *appBundleName = [directory lastPathComponent]; 
    NSString *appBinaryName = [appBundleName substringToIndex:[appBundleName length] -4];
    
    NSString *pathToBinary = [directory stringByAppendingPathComponent:appBinaryName];
    
    
    return pathToBinary;
}

// Alert the user to bad file path (how did they with drag and drop?!?!)
-(void)alertBadFileDrop
{
    
}

-(void)alertSuccesfulDumpWithDestination:(NSString*)destination
{
    AppDelegate *delegate = [NSApplication sharedApplication].delegate;
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Ok"];
    [alert setMessageText:@"Dump Success"];
    [alert setInformativeText:[NSString stringWithFormat:@"Dumped to %@", destination]];
    [alert beginSheetModalForWindow:delegate.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
    [alert release];
    
}

// String Utility Method
-(NSString *)removeFilePrefixFromString:(NSString*)string
{
    // Removes the "file:/localhost" portion of from self
    
    NSString *newString = [string stringByReplacingOccurrencesOfString:@"file://localhost"
                                                            withString:@""];
    
    return newString;
    
}

@end
