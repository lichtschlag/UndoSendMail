//
//  USMHelpers.h
//  UndoSendMail
//
//  Created by Leonhard Lichtschlag on 11/Jul/13.
//  Copyright (c) 2013 Leonhard Lichtschlag. All rights reserved.
//

#include <objc/runtime.h>


// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark C helpers
// ---------------------------------------------------------------------------------------------------------------

//	Extended log if some assumption we have about the inner workings of Mail.app is violated
BOOL USMAssert(BOOL test, NSString *specificWarning);

//	A slightly safer method to swizzle two methods
void USMExchangeMethodImplementations(Method a, Method b);

