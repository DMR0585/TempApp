//
//  WGTAppDelegate.m
//  WhoGoesThere
//
//  Created by Dan Reife on 4/9/13.
//  Copyright (c) 2013 Dan Reife. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "WGTAppDelegate.h"
#import "WGTTableViewController.h"
#import "WGTLoginViewController.h"


@interface WGTAppDelegate ()

@end

@implementation WGTAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    // WGTTableViewController *controller = (WGTTableViewController *)navigationController.topViewController;
    // controller.managedObjectContext = self.managedObjectContext;
    
    // Override point for customization after application launch.
    
    
    // Set up the Parse backend and log in
    [Parse setApplicationId: @"wyorofSE4rd43Upn1BBrW9tWeMQJB5vpr1Kf5ro9"
                  clientKey: @"o3ej55V3ph8Myom4VZjSX5oq8NtN3pzgcChFmp2t"];
    [PFAnalytics trackAppOpenedWithLaunchOptions: launchOptions];
    [PFFacebookUtils initializeFacebook];
    
    //if ([PFUser currentUser] == nil) {
       // [self logIn];
    //}
    
    //PFUser *user = [PFUser currentUser];
    
    //NSLog(@"Username = %@, pw = %@",user.username, user.password);
     /*
    [user removeObject:@"Dan" forKey:@"first_name"];
    [user removeObject:@"Reife" forKey:@"last_name"];
    [user removeObject:@"Dan" forKey:@"first_name"];
    [user removeObject:@"Reife" forKey:@"last_name"];
    [user removeObject:@"Dan" forKey:@"first_name"];
    [user removeObject:@"Reife" forKey:@"last_name"];
     
    
    [user addObject:@"Dan" forKey:@"first_name"];
    [user addObject:@"Reife" forKey:@"last_name"];
    [user save];
    [self updateUserInfoFromFacebook:user];
    [user refresh];
      */
    //NSString *firstName = [user objectForKey:@"first_name"];
    //NSString *lastName = [user objectForKey:@"last_name"];
    //NSLog(@"Username = %@, First name: %@, Last name: %@",user.username, firstName, lastName);
    
    //NSLog(@"In DFLWO, after login, user = %@",[PFUser currentUser]);
    
    // Set up the location manager
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    // Update location if possible, otherwise request user to allow location updates
    //[self.locationManager startUpdatingLocation];
    // Assign the locationManager's delegate and other settings
    [self.locationManager setDelegate:self];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([PFUser currentUser] == nil) {
        //[self logIn];
    }
    //[self.locationManager startUpdatingLocation];
    
    
    /* From before Parse was integrated, will delete*/
    /*
    // See if we have a valid token for the current state.
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        // Yes, so just open the session (this won't display any UX).
        [self openSession];
    } else {
        // No, display the login page.
        [self showLoginView];
    }
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    // When location is updated, add a pin and move the view.
    CLLocation *location = [locations lastObject];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"latitude"];
    [dictionary setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"longitude"];
    
    PFUser *user = [PFUser currentUser];
    if ([user objectForKey:@"location"] == nil) {
        [user addObject:dictionary forKey:@"location"];
    }
    else {
        [user setObject:dictionary forKey:@"location"];
    }
    
    
    //NSLog(@"Updated user's location to %@",[[PFUser currentUser] objectForKey:@"location"]);
}

/*
- (void) updateUserInfoFromFacebook:(PFUser *) user {
    
    
    // Create request for user's Facebook data
    FBRequest *request = [FBRequest requestForMe];
    
    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *data = (NSDictionary *)result;
            
            NSString *username = data[@"username"];
            NSString *firstname = data[@"first_name"];
            NSString *lastname = data[@"last_name"];
            NSString *email = data[@"email"];
            
           // NSLog(@"from FBRequest: username = %@, first = %@, last = %@, email = %@",username, firstname, lastname, email);
            
            if (username != nil) {
                NSLog(@"About to set %@ (username)",username);
                user.username = username;
                NSLog(@"Set %@ (username)",user.username);
            }
            if (email != nil) {
                //NSLog(@"set email");
                user.email = email;
            }
            if (firstname != nil && [user objectForKey:@"first_name"] == nil) {
                NSLog(@"About to add %@ (first name)",firstname);
                [user addObject:firstname forKey:@"first_name"];
                NSString *s = [user objectForKey:@"first_name"];
                NSLog(@"Added %@ (first name)",s);
            }
            if (lastname != nil && [user objectForKey:@"last_name"] == nil) {
                NSLog(@"About to add %@ (last name)",lastname);
                [user addObject:lastname forKey:@"last_name"];
                NSString *s = [user objectForKey:@"last_name"];
                NSLog(@"Added %@ (last name)",s);
            }
        }
        NSString *f = [[PFUser currentUser] objectForKey:@"first_name"];
        NSString *l = [[PFUser currentUser] objectForKey:@"last_name"];
        NSLog(@"Before save, username = %@, first = %@, last = %@",[PFUser currentUser].username,f,l);
        if (![user save]) {
            NSLog(@"DIDN'T SAVE");
        }
        else NSLog(@"saved!");
        f = [[PFUser currentUser] objectForKey:@"first_name"];
        l = [[PFUser currentUser] objectForKey:@"last_name"];
        NSLog(@"After save, before refresh, username = %@, first = %@, last = %@",[PFUser currentUser].username,f,l);
        [user refresh];
        f = [[PFUser currentUser] objectForKey:@"first_name"];
        l = [[PFUser currentUser] objectForKey:@"last_name"];
        NSLog(@"After refresh, username = %@, first = %@, last = %@",[PFUser currentUser].username,f,l);
    }];
    
    NSString *firstname = [user objectForKey:@"first_name"];
    NSString *lastname = [user objectForKey:@"last_name"];
    
    NSLog(@"from user: username = %@, first = %@, last = %@",user.username, firstname, lastname);
    
    NSString *fname = [[PFUser currentUser] objectForKey:@"first_name"];
    NSString *lname = [[PFUser currentUser] objectForKey:@"last_name"];
    NSLog(@"from user: username = %@, first = %@, last = %@",[PFUser currentUser].username, firstname, lastname);
}
*/

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"WhoGoesThere" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"WhoGoesThere.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(void)logIn{
    NSLog(@"logIn");
    
    UINavigationController *nc = (UINavigationController *) self.window.rootViewController;
    UIViewController *topViewController = nc.navigationController.topViewController;
    
    // The permissions requested from the user
    NSArray *permissionsArray = @[@"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        //[_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            NSLog(@"login failed (!user)");
            if (!error) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
            NSLog(@"Uh oh. An error occurred: %@", error);
            }
        } else {
            
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
                
            } else {
                NSLog(@"User with facebook logged in!");
                
            }
            
            
            if ([[topViewController presentedViewController] isKindOfClass:[WGTLoginViewController class]]) {
                [topViewController dismissViewControllerAnimated:YES completion:nil]; // *** instead of dismissModalViewControllerAnimated
            }
        }
    }];
    PFUser *user = [PFUser currentUser];
    
    NSLog(@"Username = %@, pw = %@",user.username, user.password);
    
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

@end


// ******* UNUSED METHODS **********
/*

 - (void)openSession {
 NSLog(@"openSession called");
 
 // Set permissions required from the facebook user account
 NSArray *permissionsArray = @[@"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
 
 UINavigationController *nc = (UINavigationController *) self.window.rootViewController;
 UIViewController *topViewController = nc.navigationController.topViewController;
 
 NSLog(@"%@",[PFUser currentUser].username);
 if ([PFUser currentUser].username == nil) {
 [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
 //[_activityIndicator stopAnimating]; // Hide loading indicator
 if (!user) {
 NSLog(@"Login failed (!user)");
 if (!error) {
 NSLog(@"Uh oh. The user cancelled the Facebook login.");
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
 [alert show];
 } else {
 NSLog(@"Uh oh. An error occurred: %@", error);
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
 [alert show];
 }
 } else if (user.isNew) {
 NSLog(@"User with facebook signed up and logged in!");
 if ([[topViewController presentedViewController] isKindOfClass:[WGTLoginViewController class]]) {
 [topViewController dismissViewControllerAnimated:YES completion:nil]; // *** instead of dismissModalViewControllerAnimated
 }
 } else {
 NSLog(@"User with facebook logged in!");
 
 if ([[topViewController presentedViewController] // *** instead of modalViewController
 isKindOfClass:[WGTLoginViewController class]]) {
 [topViewController dismissViewControllerAnimated:YES completion:nil]; // *** instead of dismissModalViewControllerAnimated
 }
 }
 }];
 }
 
 if (![PFUser currentUser]) {
 NSLog(@"No current user");
 [[FBSession activeSession] closeAndClearTokenInformation];
 // Login PFUser using facebook
 
 
 [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
 //[_activityIndicator stopAnimating]; // Hide loading indicator
 
 if (!user) {
 if (!error) {
 NSLog(@"Uh oh. The user cancelled the Facebook login.");
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
 [alert show];
 } else {
 NSLog(@"Uh oh. An error occurred: %@", error);
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
 [alert show];
 }
 } else if (user.isNew) {
 NSLog(@"User with facebook signed up and logged in!");
 if ([[topViewController presentedViewController] isKindOfClass:[WGTLoginViewController class]]) {
 [topViewController dismissViewControllerAnimated:YES completion:nil]; // *** instead of dismissModalViewControllerAnimated
 }
 } else {
 NSLog(@"User with facebook logged in!");
 
 if ([[topViewController presentedViewController] // *** instead of modalViewController
 isKindOfClass:[WGTLoginViewController class]]) {
 [topViewController dismissViewControllerAnimated:YES completion:nil]; // *** instead of dismissModalViewControllerAnimated
 }
 }
 }];
 }
 
 //[_activityIndicator startAnimating]; // Show loading indicator until login is finished
 
//Before using Parse

 [FBSession openActiveSessionWithReadPermissions:nil
 allowLoginUI:YES
 completionHandler:
 ^(FBSession *session,
 FBSessionState state, NSError *error) {
 [self sessionStateChanged:session state:state error:error];
 }];
}


 
 
 
 
 
 # pragma mark - Facebook Login
 
 - (void)showLoginView
 {
 UINavigationController *nc = (UINavigationController *)self.window.rootViewController;
 UIViewController *topViewController = nc.topViewController;
 UIViewController *presentedViewController = [topViewController presentedViewController];
 
 // If the login screen is not already displayed, display it. If the login screen is
 // displayed, then getting back here means the login in progress did not successfully
 // complete. In that case, notify the login view so it can update its UI appropriately.
 if (![presentedViewController isKindOfClass:[WGTLoginViewController class]]) {
 UIStoryboard *sb = self.window.rootViewController.storyboard;
 WGTLoginViewController* loginViewController = (WGTLoginViewController *) [sb instantiateViewControllerWithIdentifier:@"FBLoginVC"];
 [topViewController presentViewController:loginViewController animated:NO completion:nil];
 } else {
 WGTLoginViewController* loginViewController = (WGTLoginViewController*)presentedViewController;
 [loginViewController loginFailed];
 }
 }
 
 - (void)sessionStateChanged:(FBSession *)session
 state:(FBSessionState) state
 error:(NSError *)error
 {
 
 switch (state) {
 case FBSessionStateOpen: {
 UINavigationController *nc = (UINavigationController *) self.window.rootViewController;
 UIViewController *topViewController = nc.navigationController.topViewController;
 if ([[topViewController presentedViewController] // *** instead of modalViewController
 isKindOfClass:[WGTLoginViewController class]]) {
 [topViewController dismissViewControllerAnimated:YES completion:nil]; // *** instead of dismissModalViewControllerAnimated
 }
 NSLog(@"Open");
 }
 break;
 case FBSessionStateClosed: NSLog(@"Closed");
 case FBSessionStateClosedLoginFailed:
 NSLog(@"Failed");
 // Once the user has logged in, we want them to
 // be looking at the root view.
 [(UINavigationController *)self.window.rootViewController popToRootViewControllerAnimated:NO];
 
 [FBSession.activeSession closeAndClearTokenInformation];
 
 [self showLoginView];
 break;
 default:
 NSLog(@"default");
 break;
 }
 
 if (error) {
 UIAlertView *alertView = [[UIAlertView alloc]
 initWithTitle:@"Error"
 message:error.localizedDescription
 delegate:nil
 cancelButtonTitle:@"OK"
 otherButtonTitles:nil];
 [alertView show];
 }
 }

*/