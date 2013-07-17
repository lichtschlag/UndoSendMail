//
//  USMMailDocumentEditorTweaks.m
//  UndoSendMail
//
//  Created by Leonhard Lichtschlag on 9/Jul/13.
//  Copyright (c) 2013 Leonhard Lichtschlag. All rights reserved.
//

#import "USMMailDocumentEditorTweaks.h"

#import "NSApplication+UndoSendMail.h"
#import "USMHelpers.h"

#import <objc/objc-runtime.h>
#import "USMShieldView.h"
// #import "MailHeaders.h"


const NSString *const kUndoSendEmailStorageKey			= @"UndoSendEmailStorage";

const NSString *const kOverlayViewKey					= @"overlayView";
const NSString *const kEmailSendCommandIsQueuedKey		= @"emailSendCommandIsQueued";
const NSString *const kTimerKey							= @"timer";

const NSTimeInterval kSendDelay = 15.0f;


// =================================================================================================================
@interface USMMailDocumentEditorTweaks ()
// =================================================================================================================

- (void) timerFired:(NSTimer *)timer;
- (void) sendHookedByUndoSendMail:(id)sender;

@end


// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Timer callback
// ---------------------------------------------------------------------------------------------------------------

void timerFired(id selfPointer, SEL _cmd, NSTimer *theTimer)
{
	// remember: ourSend: will be send: after the swizzle
	[selfPointer performSelector:@selector(sendHookedByUndoSendMail:) withObject:selfPointer];
}


BOOL sendHookedByUndoSendMail(id selfPointer, SEL _cmd, id sender)
{
	// step 1
	// get state of the current message and set one if this is the first time we get to act on it
	NSMutableDictionary *ourData;
	ourData = objc_getAssociatedObject(selfPointer, (__bridge const void *)(kUndoSendEmailStorageKey));
	
	if (!ourData)
	{
		ourData = [@{kEmailSendCommandIsQueuedKey:@NO,
					 kOverlayViewKey:[NSNull null],
					 kTimerKey:[NSNull null]}
				   mutableCopy];
	}
	
	
	// step 2
	// update display and internal state
	NSWindow *currentWindow = [selfPointer performSelector:@selector(window) withObject:nil];
	NSView *backingView = [currentWindow contentView];
	NSToolbar *windowToolbar = [currentWindow toolbar];
	
	// find the toolbar send: item
	NSToolbarItemGroup *sendItemGroup = [[windowToolbar items] firstObject];

	//	TODO: make sure we work with different icon orders or no send toolbar item at all
	
	NSToolbarItem *sendItem = [[sendItemGroup subitems] firstObject];
	
	if (![ourData[kEmailSendCommandIsQueuedKey] boolValue])
	{
		// view
		NSView *overlayView = [[USMShieldView alloc] initWithFrame:backingView.bounds];
//		overlayView.wantsLayer = YES;
//		overlayView.layer.backgroundColor = CGColorCreateGenericGray(0.5, 0.5);
//		[overlayView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable ];
		[backingView addSubview:overlayView];
		[currentWindow makeFirstResponder:overlayView];
		ourData[kOverlayViewKey] = overlayView;
		
		// button state
//		NSURL *imageURL = [[NSBundle bundleForClass:[USMShieldView class]] URLForImageResource:@"TB_Send_Fullscreen copy"];
//		NSImage *buttonImage = [[NSImage alloc] initByReferencingURL:imageURL];
		NSImage *buttonImage = [NSImage imageNamed:@"NSStopProgressTemplate"];
//		[buttonImage setName:@"TB_UndoSend_Fullscreen"];
		
		[sendItem setToolTip:@"Undo Send"];
		[sendItem setLabel:@"Undo Send"];
		[sendItem setImage:buttonImage];
		
		// timer
		NSTimer *ourTimer = [NSTimer scheduledTimerWithTimeInterval:kSendDelay
															 target:selfPointer
														   selector:@selector(timerFired:)
														   userInfo:nil repeats:NO];
		ourData[kTimerKey] = ourTimer;
		
		// bool
		ourData[kEmailSendCommandIsQueuedKey] = @YES;
		
		// order window out
		//		[NSApp bringMailMainWindowForward];
	}
	else
	{
		// view
		NSView *overlayView = ourData[kOverlayViewKey];
		[overlayView removeFromSuperview];
		ourData[kOverlayViewKey] = [NSNull null];
		
		// button state
		[sendItem setToolTip:@"Send"];
		[sendItem setLabel:@"Send"];
		[sendItem setImage:[NSImage imageNamed:@"TB_SendTemplate"]];
		
		// timer
		NSTimer *ourTimer = ourData[kTimerKey];
		[ourTimer invalidate];
		ourData[kTimerKey] = [NSNull null];
		
		// bool
		ourData[kEmailSendCommandIsQueuedKey] = @NO;
	}
	
	objc_setAssociatedObject(selfPointer, (__bridge const void *)(kUndoSendEmailStorageKey), ourData, OBJC_ASSOCIATION_RETAIN);
	
	return YES;
}



// ===============================================================================================================
@implementation USMMailDocumentEditorTweaks
// ===============================================================================================================

+ (void) installSendListener
{
	Class MDEClass = NSClassFromString(@"MailDocumentEditor");
	if (!MDEClass)
		MDEClass = NSClassFromString(@"DocumentEditor");
	if (USMAssert((BOOL)MDEClass, @"Could not hook UndoSendMail: DocumentEditor class missing"))
	{
		// step 1 install ourSend: message on the MailDocumentEditor
		class_addMethod(MDEClass, @selector(sendHookedByUndoSendMail:), (IMP) sendHookedByUndoSendMail, "v@:@");
		
		// step 2 swap the two send: message implementations
		Method sendMethodFromMail = class_getInstanceMethod(MDEClass, @selector(send:));
		if (USMAssert((BOOL)sendMethodFromMail, @"Unable to find - (void) send: original method"))
		{
			Method sendMethodFromUndoSendMail = class_getInstanceMethod(MDEClass, @selector(sendHookedByUndoSendMail:));
			USMAssert((BOOL)sendMethodFromUndoSendMail, @"Unable to find - (void) send: replacement method");
			
			USMExchangeMethodImplementations(sendMethodFromMail, sendMethodFromUndoSendMail);
		}
		
		// step 3: install the timerFired: message on the MailDocumentEditor
		class_addMethod(MDEClass, @selector(timerFired:), (IMP) timerFired, "v@:@");
	}
}


// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Placeholder Methods
// ---------------------------------------------------------------------------------------------------------------

// These methods declare selectors, this way unknown selector warnings actually warn us of an error on our behalf
// and ARC can figure out the memory management at compile time.

- (void) timerFired:(NSTimer *)timer
{
	USMAssert(NO, @"A Placeholder method was called, this shouldnever happen");
}

- (void) sendHookedByUndoSendMail:(id)sender
{
	USMAssert(NO, @"A Placeholder method was called, this shouldnever happen");
}

- (void) send:(id)sender
{
	USMAssert(NO, @"A Placeholder method was called, this shouldnever happen");
}


@end







