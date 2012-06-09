//
//  BEDumpController.m
//  Dump-Z
//
//  Created by Brandon Etheredge on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BEDumpController.h"
#import "AppDelegate.h"

@implementation BEDumpController

// Will verify the path is to a Binary or App bundle
// Then Ask for destination (if none has been selected previously)
// Then preform dump
-(void)processFileAtPath:(NSString *)path
{
    // Get the full binary path, if nil then they dropped a directory or a Mac App Bundle
    NSString *binaryPath = [self getFullBinaryPath:path];
    if (!binaryPath) {
        NSLog(@"Must be a directory or something else");
        [self alertBadPath];
        return;
    }
    
    
    [self classDumpTheBinary:binaryPath];
    
    
}

// Alerts to the user
// A bad object has been dropped (Directory, Mac App Bundle, Cydia)
- (void)alertBadPath
{
    AppDelegate *delegate = [NSApplication sharedApplication].delegate;
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Ok"];
    [alert setMessageText:@"Bad Path"];
    [alert setInformativeText:@"Only Binaries and iOS App Bundles \nAre Supported"];
    [alert beginSheetModalForWindow:delegate.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
    [alert release];
}

// Task appears to have completed successfully
- (void)alertTaskCompleted:(NSString*)destPath
{
    AppDelegate *delegate = [NSApplication sharedApplication].delegate;
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Ok"];
    [alert setMessageText:@"Dump Completed"];
    [alert setInformativeText:[NSString stringWithFormat:@"Headers are located: \n%@", destPath]];
    [alert beginSheetModalForWindow:delegate.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
    [alert release];
}

- (void)alertTaskFailed
{
    AppDelegate *delegate = [NSApplication sharedApplication].delegate;
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Ok"];
    [alert setMessageText:@"Dump Failed"];
    [alert setInformativeText:@"Please verify correct binary"];
    [alert beginSheetModalForWindow:delegate.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
    [alert release];
}

// By now, path needs to be to the binary
- (void)classDumpTheBinary:(NSString*)path
{
    NSString *binaryName = [self getNameOfBinary:path];
    NSString *destPath = [NSString stringWithFormat:@"%@%@_Headers", [self getDestinationPath],binaryName];
    
    // Build the NSTask
    NSTask *dumpTask = [[NSTask alloc] init];
    [dumpTask setLaunchPath:[[NSBundle mainBundle] pathForResource:@"class-dump-z" ofType:@""]];
    
    // Get our arguments
    NSArray *args = [NSArray arrayWithObjects:@"-H",path,@"-o", destPath, nil];
    
    
        
    // Run the task
    [dumpTask setArguments:args];
    [dumpTask launch];
    [dumpTask waitUntilExit];
    [dumpTask release];
    
    // Check the for errors... apparently Class-Dump-Z always exits with 0 even if it has an error -_-
//    int retStat = [dumpTask terminationStatus];
//    
//    if (retStat == 0) {
//        NSLog(@"Task happened successfully");
//    } else {
//        NSLog(@"SOmething bad happened");
//    }
//    
//    [dumpTask release];
    
    
    // Check that Headers directory has been created successfully
    NSFileManager *fileMan = [NSFileManager defaultManager];
    BOOL isDir;
    if ([fileMan fileExistsAtPath:destPath isDirectory:&isDir] && isDir) {
        // Directory exists, assume it was successful
        [self alertTaskCompleted:destPath];
    } else {
        // Operation was not success.... just tell the user i guess.
        [self alertTaskFailed];
    }
    
}

// Prompts user for a destination UNLESS one has previously been set
// Implement Saving destination later
-(NSString*)getDestinationPath
{
    NSUserDefaults *appSettings = [NSUserDefaults standardUserDefaults];
    
    // Check for existing destination path
    NSString *destPath = [appSettings stringForKey:@"savedDestination"];
    
    // If its nil, prompt for a new one, being sure to save it.
    if (destPath == nil) {
        // Path is nil, prompt for one being sure to save it
        NSOpenPanel *destinationPanel	= [NSOpenPanel openPanel];
        [destinationPanel setCanChooseDirectories:YES];
        [destinationPanel setCanCreateDirectories:YES];
        [destinationPanel runModal];
        
        destPath = [self removeFilePrefixFromString:[[destinationPanel URLs].lastObject absoluteString]];
        
        [appSettings setObject:destPath forKey:@"savedDestination"];
        [appSettings synchronize];
        
        [(AppDelegate*)[NSApplication sharedApplication].delegate updateLabel];
    }
    
    // Dest path should be valid, return it
    
    return destPath;
}


// Checks to see if path goes to a Binary or an App bundle
-(NSString*)getFullBinaryPath:(NSString*)path
{
    NSString *binaryPath;
    NSFileManager *fileMan = [NSFileManager defaultManager];
    
    BOOL isDir;
    BOOL isExists = [fileMan fileExistsAtPath:path isDirectory:&isDir];
    
    if (isExists) {
        // Exists
        if (isDir) {
            // Is directory
            
            if ([path hasSuffix:@".app"]) {
                // Assumed to be app bundle, add the binary name to it
                NSString *binaryName = [self getNameOfBinary:path];
                binaryPath = [path stringByAppendingPathComponent:binaryName];
            }
            
        } else {
            // Assumed to be binary already
            binaryPath = path;
        }
    }
    
    return binaryPath;
}

// String Utility Method
-(NSString *)removeFilePrefixFromString:(NSString*)string
{
    // Removes the "file:/localhost" portion of from self
    
    NSString *newString = [string stringByReplacingOccurrencesOfString:@"file://localhost"
                                                            withString:@""];
    
    return newString;
    
}

// Gets the Binary name to use for destination folder (to organize things)
-(NSString *)getNameOfBinary:(NSString*)path
{
    NSString *lastComponent = [path lastPathComponent];
    NSString *binaryName;
    
    if ([lastComponent hasSuffix:@".app"]) {
        // Is app bundle so remove the suffix
        binaryName = [lastComponent substringToIndex:[lastComponent length]-4];
    } else {
        // Already binary
        binaryName = lastComponent;
    }
    
    
    return binaryName;
}


-(void)dealloc
{
    [super dealloc];
}

@end
