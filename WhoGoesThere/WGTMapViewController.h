//
//  WGTMapViewController.h
//  WhoGoesThere
//
//  Created by Dan Reife on 4/16/13.
//  Copyright (c) 2013 Dan Reife. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "WGTAppDelegate.h"

@interface WGTMapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
