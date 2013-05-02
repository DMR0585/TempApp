//
//  UserArea.m
//  WhoGoesThere
//
//  Created by Dan Reife on 4/23/13.
//  Copyright (c) 2013 Dan Reife. All rights reserved.
//

#import "UserArea.h"

@implementation UserArea

CLLocationDegrees lowest;
CLLocationDegrees highest;
CLLocationDegrees left;
CLLocationDegrees right;

-(id) initWithCoordinates:(NSArray *)cs {
    
    // initialize to minimums, maximums
    CLLocationDegrees minLatitude = 90;
    CLLocationDegrees maxLatitude = -90;
    CLLocationDegrees minLongitude = 180;
    CLLocationDegrees maxLongitude = -180;
    
    // establish the min and max latitude and longitude
    // of all the locations in the array
    for (int i = 0; i < [cs count]; i++) {
        CLLocation *l = (CLLocation *)[cs objectAtIndex:i];
        
        if (l.coordinate.latitude < minLatitude) {
            minLatitude = l.coordinate.latitude;
        }
        if (l.coordinate.latitude > maxLatitude) {
            maxLatitude = l.coordinate.latitude;
        }
        if (l.coordinate.longitude < minLongitude) {
            minLongitude = l.coordinate.longitude;
        }
        if (l.coordinate.longitude > maxLongitude) {
            maxLongitude = l.coordinate.longitude;
        }
    }
    
    lowest = minLatitude;
    highest = maxLatitude;
    left = minLongitude;
    right = maxLongitude;
    
    return self;
}

-(BOOL) containsUser:(PFUser *)user {
    NSMutableDictionary *dictionary = [user objectForKey:@"location"];
    if (dictionary != nil) {
        NSNumber *lat = [dictionary objectForKey:@"latitude"];
        double latitude = 0.0;
        if (lat != nil) latitude = [lat doubleValue];
        else latitude = -100.0;
        
        NSNumber *lon = [dictionary objectForKey:@"longitude"];
        double longitude = 0.0;
        if (lon != nil) longitude = [lon doubleValue];
        else longitude = -100.0;
        
        if (latitude != -100.0 && longitude != -100.0) {
            return (lowest < latitude && latitude < highest &&
                    left < longitude && longitude < right);
        }
    }
    return NO;
    
    
}

@end
