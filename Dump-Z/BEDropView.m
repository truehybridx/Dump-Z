//
//  BEDropView.m
//  Dump-Z
//
//  Created by Brandon Etheredge on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BEDropView.h"
#import "BEDumpController.h"

@interface BEDropView ()
{
   // NSString *currentDroppedPath;
}

@end

@implementation BEDropView
@synthesize nsImageObj;


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    self.nsImageObj = [NSImage imageNamed:@"DropZone.png"];
    
    
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    //[[NSColor blackColor] set];
    //NSRectFill( dirtyRect );
    NSRect zOurBounds = [self bounds];
    [super drawRect:dirtyRect];
    
    [self.nsImageObj compositeToPoint:(zOurBounds.origin) operation:NSCompositeSourceOver];
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
    
    BEDumpController *dumpController = [[BEDumpController alloc] init];
    NSString* pathString = [dumpController removeFilePrefixFromString:[urlFromPasteboard absoluteString]] ;
    
    // Start processing the given file
    // [self processFileAtPath:pathString];
    [dumpController processFileAtPath:pathString];
    [dumpController release];
    
    return YES;
    	
} // end performDragOperation


- (void)concludeDragOperation:(id <NSDraggingInfo>)sender {
   // [self setNeedsDisplay:YES];
    
    // Start working from here
    
    
} // end concludeDragOperation





@end
