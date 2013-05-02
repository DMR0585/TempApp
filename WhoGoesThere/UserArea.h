//
//  UserArea.h
//  WhoGoesThere
//
//  Created by Dan Reife on 4/23/13.
//  Copyright (c) 2013 Dan Reife. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>

@interface UserArea : NSObject

-(id)initWithCoordinates:(NSArray *)cs;
-(BOOL) containsUser:(PFUser *)user;

@end
