//
//  USMShieldView.m
//  UndoSendMail
//
//  Created by Leonhard Lichtschlag on 10/Jul/13.
//  Copyright (c) 2013 Leonhard Lichtschlag. All rights reserved.
//

#import "USMShieldView.h"
#import <QuartzCore/QuartzCore.h>

// ===============================================================================================================
@implementation USMShieldView
// ===============================================================================================================

- (id) initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
		self.wantsLayer = YES;
		self.layer.backgroundColor = CGColorCreateGenericGray(0.4, 0.3);
		[self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    }
    return self;
}


- (void) viewDidMoveToSuperview
{
	[self flashInstructions];
}


- (void) flashInstructions
{
//	// compute some metrics for the text
	NSDictionary* textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSFont labelFontOfSize:24.0], NSFontAttributeName,
									CGColorCreateGenericGray(0.40, 1.0), NSForegroundColorAttributeName, nil];
	NSMutableAttributedString* text = [[NSMutableAttributedString alloc] initWithString:@"Your Email will be sent in a moment."
																			 attributes:textAttributes];

	NSRect maximumTextArea = NSInsetRect(self.bounds, 20.0, 20.0);
	NSRect computedTextArea = [text boundingRectWithSize:maximumTextArea.size options:0];

	// display
	CATextLayer *textLayer = [CATextLayer new];
	textLayer.bounds = NSRectToCGRect(computedTextArea);
	textLayer.cornerRadius = 8.0f;
	textLayer.string = text;

	CAConstraint *xConstraint = [CAConstraint constraintWithAttribute:kCAConstraintMidX
															 relativeTo:@"superlayer"
															  attribute:kCAConstraintMidX];
	CAConstraint *yConstraint = [CAConstraint constraintWithAttribute:kCAConstraintMidY
															 relativeTo:@"superlayer"
															attribute:kCAConstraintMaxY
																scale:0.10
															   offset:0.0];
	self.layer.layoutManager = [CAConstraintLayoutManager layoutManager];
	[textLayer addConstraint:xConstraint];
	[textLayer addConstraint:yConstraint];
	[self.layer addSublayer:textLayer];
	textLayer.actions = @{@"position":[NSNull null]};
	
	// add animation to fade out
	CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fadeAnimation.fromValue = [NSNumber numberWithFloat:1.0];
	fadeAnimation.toValue = [NSNumber numberWithFloat:0.0];
	fadeAnimation.duration = 0.8;
	[textLayer addAnimation:fadeAnimation forKey:@"opacityAnimation"];
	textLayer.opacity = 0.0;
}


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
#pragma mark Disable destructive options from elsewhere in the app
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
