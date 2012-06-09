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


// Removed the URL prefix from dropped paths (yes its a class method)
-(NSString *)removeFilePrefixFromString:(NSString*)string;



@end
