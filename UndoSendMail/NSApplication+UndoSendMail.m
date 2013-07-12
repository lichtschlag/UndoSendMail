//
//  NSApplication+UndoSendMail.m
//  UndoSendMail
//
//  Created by Leonhard Lichtschlag on 11/Jul/13.
//  Copyright (c) 2013 Leonhard Lichtschlag. All rights reserved.
//

#import "NSApplication+UndoSendMail.h"


// =================================================================================================================
@implementation NSApplication (UndoSendMail)
// =================================================================================================================

NSString *const kMainMailWindowName      = @"MouseTrackingWindow";

- (void) bringMainMailWindowForward;
{
	NSArray *windows = [self orderedWindows];
	NSWindow *foundWindow = nil;
	for (NSWindow *aWindow in windows)
	{
		if ([aWindow isKindOfClass:NSClassFromString(kMainMailWindowName)])
		{
			foundWindow = aWindow;
			break;
		}
	}
	
	if (foundWindow)
		[foundWindow makeKeyAndOrderFront:self];
}


@end
