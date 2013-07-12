//
//  USMHelpers.m
//  UndoSendMail
//
//  Created by Leonhard Lichtschlag on 11/Jul/13.
//  Copyright (c) 2013 Leonhard Lichtschlag. All rights reserved.
//

#import "USMHelpers.h"


// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark C helpers
// ---------------------------------------------------------------------------------------------------------------

//	Adapted from GrowlMail at https://github.com/rudyrichter/GrowlMail
//
//	Copyright (c) The Growl Project, 2004-2010
//	Copyright (c) Rudy Richter, 2011-2013
//	All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modification, are permitted provided that
//	the following conditions are met:
//
//	1. Redistributions of source code must retain the above copyright
//	notice, this list of conditions and the following disclaimer.
//	2. Redistributions in binary form must reproduce the above copyright
//	notice, this list of conditions and the following disclaimer in the
//	documentation and/or other materials provided with the distribution.
//	3. Neither the name of Growl nor the names of its contributors
//	may be used to endorse or promote products derived from this software
//	without specific prior written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
//	PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY
//	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//	PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
//	OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

BOOL USMAssert(BOOL test, NSString *specificWarning)
{
	if (!test)
	{
		NSLog(@"WARNING: Mail.app is not behaving in the way that UndoSendMail expects."
			  "This is probably because UndoSendMail is incompatible with the version of Mail you're using.");
		if (specificWarning)
			NSLog(@"Furthermore, the caller provided a more specific message: %@", specificWarning);
		NSLog(@"%@", [NSThread callStackSymbols]);
	}
	return test;
}


void USMExchangeMethodImplementations(Method a, Method b)
{
	USMAssert((a && b),
			  [NSString stringWithFormat:@"Attempt to swizzle fewer than two method implementations: %s and %s",
			   a ? sel_getName(method_getName(a)) : NULL, b ? sel_getName(method_getName(b)) : NULL]);
	method_exchangeImplementations(a, b);
}

