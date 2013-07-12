//
//  USMShieldView.m
//  UndoSendMail
//
//  Created by Leonhard Lichtschlag on 10/Jul/13.
//  Copyright (c) 2013 Leonhard Lichtschlag. All rights reserved.
//

#import "USMShieldView.h"

// ===============================================================================================================
@implementation USMShieldView
// ===============================================================================================================

// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Block all relevant NSEvents, effectively preventing the changing of the message until it is sent
// ---------------------------------------------------------------------------------------------------------------

- (BOOL) acceptsFirstResponder
{
	return YES;
}


- (void) mouseDown:(NSEvent *)theEvent
{}
- (void) mouseMoved:(NSEvent *)theEvent
{}
- (void) mouseDragged:(NSEvent *)theEvent
{}
- (void) mouseUp:(NSEvent *)theEvent
{}

- (void) rightMouseDown:(NSEvent *)theEvent
{}
- (void) rightMouseDragged:(NSEvent *)theEvent
{}
- (void) rightMouseUp:(NSEvent *)theEvent
{}

- (void) otherMouseDown:(NSEvent *)theEvent
{}
- (void) otherMouseDragged:(NSEvent *)theEvent
{}
- (void) otherMouseUp:(NSEvent *)theEvent
{}

- (void) keyDown:(NSEvent *)theEvent
{}
- (void) keyUp:(NSEvent *)theEvent
{}


// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Disable destrucive options from elsewhere in the
// ---------------------------------------------------------------------------------------------------------------

- (BOOL) validateMenuItem:(NSMenuItem *)menuItem
{
	if ([menuItem action] == NSSelectorFromString(@"undo:"))
	{
		return NO;
	}
	else
	{
		return [super validateMenuItem:menuItem];
	}
}


@end
