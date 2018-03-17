//
//  RKComment+Submarine.h
//  
//
//  Created by Julian Weiss on 8/14/15.
//
//

#import "RKComment.h"

@interface RKComment (Submarine)

/**
  The CSS class value for the author of the link.
  */
@property (copy) NSString *submarineAuthorFlairClass;

/**
  The flair text value for the author of the link.
  */
@property (copy) NSString *submarineAuthorFlairText;

@end
