//
//  WGTMapViewController.m
//  WhoGoesThere
//
//  Created by Dan Reife on 4/16/13.
//  Copyright (c) 2013 Dan Reife. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "WGTMapViewController.h"
#import "CyclicMutableArray.h"


@interface WGTMapViewController ()

@end

@implementation WGTMapViewController

CyclicMutableArray *pins;
NSNumber *selectedPin;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Get the locationManager from the AppDelegate, init if necessary
    WGTAppDelegate *delegate = (WGTAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (delegate.locationManager == nil) {
        delegate.locationManager = [[CLLocationManager alloc] init];
    }
    
    // Assign the locationManager's and mapView's delegates
    delegate.locationManager.delegate = self;
    self.mapView.delegate = self;
    
    // Update location if possible, otherwise request user to allow location updates
    if ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)) {
        [self centerViewAtLocation:delegate.locationManager.location:NO];
        [delegate.locationManager startUpdatingLocation];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                        message:@"To re-enable, please go to: \nSettings > Privacy > Location."
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    // Set up the gesture recognizer for dropping a pin
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressRecognizer.delaysTouchesBegan = YES;
    longPressRecognizer.delaysTouchesEnded = YES;
    [self.mapView addGestureRecognizer:longPressRecognizer];
    
    //UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    //[self.mapView addGestureRecognizer:tapRecognizer];
    
    self.populateButton.action = @selector(populate);
    self.populateButton.target = self;
    
    // Set up the array of pins
    pins = [[CyclicMutableArray alloc] initWithCapacity:4];
    
    // None are selected
    selectedPin = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
}

#pragma mark - MKMapViewDelegate methods



- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    /*BOOL began = NO;
    NSArray *grs = self.mapView.gestureRecognizers;
    for (UIGestureRecognizer *gr in grs) {
        if (gr.state == UIGestureRecognizerStateBegan) began = YES;
    }*/
    //if (began) {
        selectedPin = [NSNumber numberWithInt:[view.annotation.subtitle intValue] - 1];
        NSLog(@"didSelect pin (%@)",selectedPin);
    //}
    
    //view.canShowCallout = YES;
    //NSLog(@"Called didSelect, selected pin = %@",selectedPin);
    
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    [self.mapView deselectAnnotation:view.annotation animated:NO];
    //view.canShowCallout = NO;
    NSLog(@"didDeselect pin (%@)",selectedPin);
    selectedPin = nil;
}

#pragma mark - Map methods

- (void) centerViewAtLocation:(CLLocation *)location
                             :(BOOL)animated {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, 7500, 7500);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
    [self.mapView setRegion:adjustedRegion animated:animated];
}

- (void)addPinToMapAtCoordinate:(CLLocationCoordinate2D) coordinate
{
    //NSLog(@"Adding pin");
    // Set up the new pin
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    pin.coordinate = coordinate;
    pin.title = @"Pin";
    NSString *number;
    
    // Adjust the number of each pin if you're going to replace
    // the least recently added one
    if ([pins count] == 4) {
        for (MKPointAnnotation *p in pins) {
            NSInteger n = [p.subtitle integerValue];
            p.subtitle = [NSString stringWithFormat:@"%d",n - 1];
        }
        number = [NSString stringWithFormat:@"%d",4];
    }
    else {
        number = [NSString stringWithFormat:@"%d",[pins count] + 1];
    }
    
    pin.subtitle = number;
    if ([pins count] == 4) {
        [self.mapView removeAnnotation:[pins firstObject]];
    }
    [pins addObject:pin];
    [self.mapView addAnnotation:pin];
    
    MKAnnotationView *view = [self.mapView viewForAnnotation:pin];
   // [view setSelected:NO];
    //view.canShowCallout = NO;
    //[self mapView:self.mapView didDeselectAnnotationView:view];
    //[self mapView:self.mapView didDeselectAnnotationView:[self.mapView viewForAnnotation:pin]];
    //[self.mapView deselectAnnotation:pin animated:NO];
    NSLog(@"Added pin (%@) and selected pin (%@)",number,selectedPin);
}

- (void)replacePinAtIndex:(NSNumber *)index
           WithCoordinate:(CLLocationCoordinate2D) coordinate
{
    //NSLog(@"Replacing pin");
    MKPointAnnotation *old = [pins objectAtIndex:[index unsignedIntegerValue]];
    MKPointAnnotation *replacement = [[MKPointAnnotation alloc] init];
    
    replacement.coordinate = coordinate;
    replacement.title = @"Pin";
    replacement.subtitle = old.subtitle;
    
    [pins replaceObjectAtIndex:[index unsignedIntegerValue] withObject:replacement];
    [self.mapView removeAnnotation:old];
    [self.mapView addAnnotation:replacement];
    NSLog(@"Replaced pin (%@) and selected pin (%@)",index,selectedPin);
    //[self.mapView deselectAnnotation:replacement animated:NO];
    
    //for (NSObject<MKAnnotation> *annotation in [self.mapView selectedAnnotations]) {
    //    [self.mapView deselectAnnotation:(id <MKAnnotation>)annotation animated:NO];
    //}
    //MKAnnotationView *view = [self.mapView viewForAnnotation:replacement];
    //view.canShowCallout = NO;
    // [self mapView:self.mapView didDeselectAnnotationView:view];
}

-(MKAnnotationView *)viewForPinWithCoordinate:(CLLocationCoordinate2D) coordinate {
    for (MKPointAnnotation *pin in pins) {
        if ((pin.coordinate.latitude == coordinate.latitude) && (pin.coordinate.longitude == coordinate.longitude)) {
            return [self.mapView viewForAnnotation:pin];
        }
    }
    return nil;
}

-(void)handleLongPress:(UIGestureRecognizer*)sender
{
    // Get the coordinate for the touch
    CGPoint point = [sender locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        // Add a pin if none were selected
        if (selectedPin == nil) {
            [self addPinToMapAtCoordinate:coordinate];
        }
        else { // replace the selected pin
            [self replacePinAtIndex:selectedPin
                     WithCoordinate:coordinate];
        }
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        MKAnnotationView *view = [self viewForPinWithCoordinate:coordinate];
        if (view != nil) {
            //view.canShowCallout = NO;
            [self mapView:self.mapView didDeselectAnnotationView:view];
        }
    }
}

-(void) populate {
    NSLog(@"populate");
    if (!self.friendPickerController) {
        self.friendPickerController = [[FBFriendPickerViewController alloc]
                                       initWithNibName:nil bundle:nil];
        
        // Set the friend picker delegate
        self.friendPickerController.delegate = self;
        
        self.friendPickerController.title = @"Select friends";
    }
    
    [self.friendPickerController loadData];
    [self.navigationController pushViewController:self.friendPickerController
                                         animated:true];
}

@end
