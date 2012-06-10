//
//  BEDumpController.h
//  Dump-Z
//
//  Created by Brandon Etheredge on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BEDumpController : NSObject

// Will verify the path is to a Binary or App bundle
// Then Ask for destination (if none has been selected previously)
// Then preform dump
-(void)processFileAtPath:(NSString *)path;

// Alerts to the user
// A bad object has been dropped (Directory, Mac App Bundle, Cydia)
- (void)alertBadPath;

// By now, path needs to be to the binary
- (void)classDumpTheBinary:(NSString*)path;

// Prompts user for a destination UNLESS one has previously been set
// Implement Saving destination later
-(NSString*)getDestinationPath;

// Checks to see if path goes to a Binary or an App bundle
-(NSString*)getFullBinaryPath:(NSString*)path;

// Gets the Binary name to use for destination folder (to organize things)
-(NSString *)getNameOfBinary:(NSString*)path;

// Removed the URL prefix from dropped paths (yes its a class method)
-(NSString *)removeFilePrefixFromString:(NSString*)string;

@end
