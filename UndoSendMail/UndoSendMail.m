//
//  UndoSendMail.m
//  UndoSendMail
//
//  Created by Leonhard Lichtschlag on 9/Jul/13.
//  Copyright (c) 2013 Leonhard Lichtschlag. All rights reserved.
//

#import "UndoSendMail.h"
#import "USMHelpers.h"
#import <objc/runtime.h>
#import "USMMailDocumentEditorTweaks.h"


// ===============================================================================================================
@implementation UndoSendMail
// ===============================================================================================================

// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Install into Mail.app
// ---------------------------------------------------------------------------------------------------------------

// called the first time the class is used
+ (void) initialize
{
	[super initialize];
    
	Class DocumentEditorClass = NSClassFromString(@"MailDocumentEditor");
	if (!DocumentEditorClass)
		DocumentEditorClass = NSClassFromString(@"DocumentEditor");
	if (USMAssert((BOOL)DocumentEditorClass, @"Unable to find a DocumentEditor class"))
	{
		// TODO: what does this do?
//		[UndoSendMail registerBundle];
		
		[USMMailDocumentEditorTweaks installSendListener];
		NSLog(@"UndoSendMail has successfully loaded.");
	}
	else
		NSLog(@"Fail to load UndoSendMail, plug-in remains inactive until next Mail.app launch");
	
	// for DEBUG
//	double delayInSeconds = 1.0;
//	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//		[UndoSendMail installFScript];
//	});
}


+ (void) registerBundle
{
	// I do not know what this does, the GrowlMail source does this...
    if (class_getClassMethod(NSClassFromString(@"MVMailBundle"), @selector(registerBundle)))
	{
		[NSClassFromString(@"MVMailBundle") performSelector:@selector(registerBundle)];
	}
}


+ (void) installFScript
{
	[[NSBundle bundleWithPath:@"/Library/Frameworks/FScript.framework"] load];

	SEL FScriptCall = sel_registerName("insertInMainMenu");
	
    if (class_getClassMethod(NSClassFromString(@"FScriptMenuItem"), FScriptCall))
		[NSClassFromString(@"FScriptMenuItem") performSelector:FScriptCall];
}




@end
