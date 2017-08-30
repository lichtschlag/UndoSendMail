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


const NSString *const kUndoSendEmailStorageKey			= @"UndoSendEmailStorage";

const NSString *const kOverlayViewKey					= @"overlayView";
const NSString *const kBaseMenuTitleKey					= @"baseMenuTitle";
const NSString *const kEmailSendCommandIsQueuedKey		= @"emailSendCommandIsQueued";
const NSString *const kTimerKey							= @"timer";

const NSTimeInterval kSendDelay = 15.0f;


// =================================================================================================================
@interface DummyDocumentEditor : NSObject
// =================================================================================================================

- (BOOL) validateMenuItemHookedByUndoSendMail:(NSMenuItem*) menuItem;
- (BOOL) sendHookedByUndoSendMail:(id) sender;

@end


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
	[(DummyDocumentEditor *)selfPointer sendHookedByUndoSendMail:selfPointer];
	
	// check if minimized, if so, close the window
	NSWindow *messageWindow = [selfPointer performSelector:@selector(window) withObject:nil];
	BOOL isMinimized = [messageWindow isMiniaturized];
	if (isMinimized)
	{
		[messageWindow close];
	}
}


BOOL sendHookedByUndoSendMail(id selfPointer, SEL _cmd, id sender)
{
	NSWindow *currentWindow = [selfPointer performSelector:@selector(window) withObject:nil];
	NSView *backingView = [currentWindow contentView];
	NSToolbar *windowToolbar = [currentWindow toolbar];
	
	// menu item
	NSMenuItem *messageMenu = [[currentWindow menu] itemAtIndex:5];
	NSMenuItem *sendMenuItem = [[messageMenu submenu] itemAtIndex:0];

	// find the toolbar send: item
	NSToolbarItemGroup *sendItemGroup = [[windowToolbar items] objectAtIndex:0];
	
	//	TODO: make sure we work with different icon orders or no send toolbar item at all
	NSToolbarItem *sendItem = [[sendItemGroup subitems] objectAtIndex:0];

	// step 1
	// get state of the current message and set one if this is the first time we get to act on it
	NSMutableDictionary *ourData;
	ourData = objc_getAssociatedObject(selfPointer, (__bridge const void *)(kUndoSendEmailStorageKey));
	if (!ourData)
	{
		ourData = [@{kEmailSendCommandIsQueuedKey:@NO,
					 kOverlayViewKey:[NSNull null],
					 kTimerKey:[NSNull null],
					 kBaseMenuTitleKey:sendMenuItem.title}
				   mutableCopy];
	}

	// step 2
	// update display and internal state
	if (![ourData[kEmailSendCommandIsQueuedKey] boolValue])
	{
		// view
		NSView *overlayView = [[USMShieldView alloc] initWithFrame:backingView.bounds];
		[backingView addSubview:overlayView];
		[currentWindow makeFirstResponder:overlayView];
		ourData[kOverlayViewKey] = overlayView;
		
		// button state
		NSImage *buttonImage = [NSImage imageNamed:@"NSStopProgressTemplate"];
		
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
		// [NSApp bringMailMainWindowForward];
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
		
		// menu
		[sendMenuItem setTitle:ourData[kBaseMenuTitleKey]];
	}
	
	objc_setAssociatedObject(selfPointer, (__bridge const void *)(kUndoSendEmailStorageKey), ourData, OBJC_ASSOCIATION_RETAIN);
	
	return YES;
}


BOOL validateMenuItemHookedByUndoSendMail(id selfPointer, SEL _cmd, NSMenuItem* menuItem)
{
	// are we on?
	NSMutableDictionary *ourData = objc_getAssociatedObject(selfPointer, (__bridge const void *)(kUndoSendEmailStorageKey));
	BOOL shouldChangeMenuItem = (ourData && [ourData[kEmailSendCommandIsQueuedKey] boolValue] );
	
	// our behaviour
	if (shouldChangeMenuItem &&
		[menuItem action] == NSSelectorFromString(@"send:"))
	{
		[menuItem setTitle:[NSString stringWithFormat:@"Undo %@", ourData[kBaseMenuTitleKey]]];
		return YES;
	}
	
	// default behaviour
	return [(DummyDocumentEditor *)selfPointer validateMenuItemHookedByUndoSendMail:menuItem];
}



// ===============================================================================================================
@implementation USMMailDocumentEditorTweaks
// ===============================================================================================================

+ (void) installSendListener
{
	Class MDEClass = NSClassFromString(@"MailDocumentEditor");
	if (!MDEClass)
		MDEClass = NSClassFromString(@"DocumentEditor");
    if (!MDEClass)
        MDEClass = NSClassFromString(@"ComposeViewController");
	if (USMAssert((MDEClass != NULL), @"Could not hook UndoSendMail: DocumentEditor class missing"))
	{
		// step 1 install ourSend: message on the MailDocumentEditor
		class_addMethod(MDEClass, @selector(sendHookedByUndoSendMail:), (IMP) sendHookedByUndoSendMail, "v@:@");
		
		// step 2 swap the two send: message implementations
		Method sendMethodFromMail = class_getInstanceMethod(MDEClass, @selector(send:));

		if (USMAssert((sendMethodFromMail != NULL), @"Unable to find - (void) send: original method"))
		{
			Method sendMethodFromUndoSendMail = class_getInstanceMethod(MDEClass, @selector(sendHookedByUndoSendMail:));
			USMAssert((sendMethodFromUndoSendMail != NULL), @"Unable to find - (void) send: replacement method");
			
			USMExchangeMethodImplementations(sendMethodFromMail, sendMethodFromUndoSendMail);
		}
		
		// step 3: install the timerFired: message on the MailDocumentEditor
		class_addMethod(MDEClass, @selector(timerFired:), (IMP) timerFired, "v@:@");
	}
}


+ (void) installMenuValidation
{
	Class MDEClass = NSClassFromString(@"MailDocumentEditor");
	if (!MDEClass)
		MDEClass = NSClassFromString(@"DocumentEditor");
    if (!MDEClass)
        MDEClass = NSClassFromString(@"ComposeViewController");
	if (USMAssert((MDEClass != NULL), @"Could not hook UndoSendMail: DocumentEditor class missing"))
	{
		// step 1 install our validateMenuItem: message on the MailDocumentEditor
		class_addMethod(MDEClass, @selector(validateMenuItemHookedByUndoSendMail:), (IMP) validateMenuItemHookedByUndoSendMail, "v@:@");
		
		// step 2 swap the two validateMenuItem: message implementations
		Method validateMethodFromMail = class_getInstanceMethod(MDEClass, @selector(validateMenuItem:));
		
		if (USMAssert((validateMethodFromMail != NULL), @"Unable to find - (void) validateMenuItem: original method"))
		{
			Method validateMethodFromUndoSendMail = class_getInstanceMethod(MDEClass, @selector(validateMenuItemHookedByUndoSendMail:));
			USMAssert((validateMethodFromUndoSendMail != NULL), @"Unable to find - (void) validateMenuItem: replacement method");
			
			USMExchangeMethodImplementations(validateMethodFromMail, validateMethodFromUndoSendMail);
		}
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
	USMAssert(NO, @"A Placeholder method was called, this should never happen");
}

- (void) sendHookedByUndoSendMail:(id)sender
{
	USMAssert(NO, @"A Placeholder method was called, this should never happen");
}

- (void) send:(id)sender
{
	USMAssert(NO, @"A Placeholder method was called, this should never happen");
}

- (BOOL) validateMenuItem:(NSMenuItem *)menuItem
{
	USMAssert(NO, @"A Placeholder method was called, this should never happen");
	return YES;
}

- (BOOL) validateMenuItemHookedByUndoSendMail:(NSMenuItem *)menuItem
{
	USMAssert(NO, @"A Placeholder method was called, this should never happen");
	return YES;
}


@end







