//
//  WGTLoginViewController.m
//  WhoGoesThere
//
//  Created by Dan Reife on 4/16/13.
//  Copyright (c) 2013 Dan Reife. All rights reserved.
//


#import <FacebookSDK/FacebookSDK.h>
#import "WGTLoginViewController.h"
#import "WGTAppDelegate.h"

@interface WGTLoginViewController ()

@end

@implementation WGTLoginViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)signUp{
    PFUser *user = [PFUser currentUser];
    NSLog(@"User = %@",user);
    
    
    
    
    //NSLog(@"Username = %@, pw = %@",user.username, user.password);
    //[self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)fuckshitup{
    
        // The permissions requested from the user
        NSArray *permissionsArray = @[@"email", @"user_relationships", @"user_birthday", @"user_location"];
        
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
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        PFUser *user = [PFUser currentUser];
        
        NSLog(@"Username = %@, pw = %@",user.username, user.password);
        
    
    
    
}

- (void)openSession {
    NSLog(@"openSession called");
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         NSLog(@"openActiveSession completed");
         [self sessionStateChanged:session state:state error:error];
     }];
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error {
    [self logStuffWithString:@"From sessionStateChanged"];
    switch (state) {
        case FBSessionStateOpen: {
            NSLog(@"About to call logInToParse");
            [self logInToParse];
            break;
        }
        case FBSessionStateClosed: {
            
            break;
        }
        case FBSessionStateClosedLoginFailed: {
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        }
        default: {
            break;
        }
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

- (void) logInToParse {
    FBAccessTokenData *token = [[FBSession activeSession] accessTokenData];
    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    FBRequest *request = [FBRequest requestForMe];
    [connection addRequest:request
         completionHandler:^(FBRequestConnection *connection,
                             NSDictionary<FBGraphUser> *user,
                             NSError *error) {
             if (!error) {
                 // And log in to Parse
                 [PFFacebookUtils logInWithFacebookId:user.id
                                          accessToken:token.accessToken
                                       expirationDate:token.expirationDate
                                                block:^(PFUser *u, NSError *error) {
                                //[self updateUserInfoFromFacebook:u];
                                                    NSLog(@"Successfully logged in %@ when already connected to Facebook!",u);
                                                    if (u != nil && [PFFacebookUtils isLinkedWithUser:u]) [self dismissViewControllerAnimated:YES completion:nil];
                                                }];
             }
         }];
    [connection start];
}

-(IBAction)logIn{
    PFUser *user = [PFUser currentUser];
    
    if (user == nil) {
        [self logStuffWithString:@"From logIn"];
        
        
        // If there's a session open
        if ([FBSession activeSession].state == FBSessionStateOpen) {
            // Request the user's info
            FBRequestConnection *connection = [[FBRequestConnection alloc] init];
            FBRequest *request = [FBRequest requestForMe];
            [connection addRequest:request
                 completionHandler:^(FBRequestConnection *connection,
                                     NSDictionary<FBGraphUser> *user,
                                     NSError *error) {
                     if (!error) {
                         // And log in to Parse
                         FBAccessTokenData *data = [[PFFacebookUtils session] accessTokenData];
                         [PFFacebookUtils logInWithFacebookId:user.id
                                                  accessToken:data.accessToken
                                               expirationDate:data.expirationDate
                                                        block:^(PFUser *u, NSError *error) {
                                [self updateUserInfoFromFacebook:u];
                                 NSLog(@"Successfully logged in %@ when already connected to Facebook!",u);
                                if (u != nil && [PFFacebookUtils isLinkedWithUser:u]) [self dismissViewControllerAnimated:YES completion:nil];
                                                        }];
                     }
                 }];
            [connection start];
        }
        else {
            [PFFacebookUtils logInWithPermissions:nil
                                            block:^(PFUser *user, NSError *error) {
                NSLog(@"Logged in %@ to Parse and Facebook",user);
                                                [self updateUserInfoFromFacebook:user];
                if (user != nil && [PFFacebookUtils isLinkedWithUser:user]) [self dismissViewControllerAnimated:YES completion:nil];
                                            }];
        }
    }
}

- (void) updateUserInfoFromFacebook:(PFUser *) user {
    
    
    // Create request for user's Facebook data
    FBRequest *request = [FBRequest requestForMe];
    
    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *dictionary = (NSDictionary *)result;
            
            
            /*
            NSData *d1 = [dictionary[@"username"] dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *username = [NSDictionary dictionaryWithObject:[NSJSONSerialization JSONObjectWithData:d1 options:0 error:nil] forKey:@"username"];
            NSLog(@"d1 = %@, usernamedict = %@",d1,username);
            
            NSData *d2 = [dictionary[@"first_name"] dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *firstname = [NSJSONSerialization JSONObjectWithData:d2 options:0 error:nil];
            
            NSData *d3 = [dictionary[@"last_name"] dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *lastname = [NSDictionary dictionaryWithObject:[NSJSONSerialization JSONObjectWithData:d3 options:0 error:nil] forKey:@"last_name"];
            
            NSData *d4 = [dictionary[@"email"] dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *email = [NSJSONSerialization JSONObjectWithData:d4 options:0 error:nil];
            NSLog(@"d4 = %@, emaildict = %@",d4,email);
            
            NSData *d5 = [dictionary[@"id"] dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *FBid = [NSJSONSerialization JSONObjectWithData:d5 options:0 error:nil];
            */
            
            
            
            
            
            
            
            NSString *username = dictionary[@"username"];
            NSString *firstname = dictionary[@"first_name"];
            NSString *lastname = dictionary[@"last_name"];
            NSString *email = dictionary[@"email"];
            NSString *FBid = dictionary[@"id"];
            
            if (username != nil) {
                user.username = username;
            }
            if (email != nil) {
                user.email = email;
            }
            if (firstname != nil) {
                if ([user objectForKey:@"first_name"] == nil) {
                    [user addObject:firstname forKey:@"first_name"];
                }
                else {
                    [user setObject:firstname forKey:@"first_name"];
                }
            }
            if (lastname != nil) {
                if ([user objectForKey:@"last_name"] == nil) {
                    [user addObject:lastname forKey:@"last_name"];
                }
                else {
                    [user setObject:lastname forKey:@"last_name"];
                }
            }
            if (FBid != nil) {
                if ([user objectForKey:@"FBid"] == nil) {
                    [user addObject:FBid forKey:@"FBid"];
                }
                else {
                    [user setObject:FBid forKey:@"FBid"];
                }
            }
        }
    }];
}


-(IBAction)logout {
    if ([PFFacebookUtils session].state == FBSessionStateOpen) {
    [PFUser logOut];
    [[FBSession activeSession] closeAndClearTokenInformation];
    }
}

-(void)logStuffWithString:(NSString *)s {
    NSLog(@"%@",s);
    FBSession *fbs = [FBSession activeSession];
    if (fbs.state == FBSessionStateOpen) {
        NSLog(@"FBSession state is open");
    }
    if (fbs.state == FBSessionStateOpenTokenExtended) {
        NSLog(@"FBSession state is open token extended");
    }
    if (fbs.state == FBSessionStateClosed) {
        NSLog(@"FBSession state is closed");
    }
    if (fbs.state == FBSessionStateClosedLoginFailed) {
        NSLog(@"FBSession state is closed login failed");
    }
    if (fbs.state == FBSessionStateCreated) {
        NSLog(@"FBSession state is created");
    }
    if (fbs.state == FBSessionStateCreatedOpening) {
        NSLog(@"FBSession state is created opening");
    }
    if (fbs.state == FBSessionStateCreatedTokenLoaded) {
        NSLog(@"FBSession state is created token loaded");
    }
    if ([PFFacebookUtils session] != fbs) {
        if ([PFFacebookUtils session].state == FBSessionStateOpen) {
            NSLog(@"PFSession state is open");
        }
        if ([PFFacebookUtils session].state == FBSessionStateOpenTokenExtended) {
            NSLog(@"PFSession state is open token extended");
        }
        if ([PFFacebookUtils session].state == FBSessionStateClosed) {
            NSLog(@"PFSession state is closed");
        }
        if ([PFFacebookUtils session].state == FBSessionStateClosedLoginFailed) {
            NSLog(@"PFSession state is closed login failed");
        }
        if ([PFFacebookUtils session].state == FBSessionStateCreated) {
            NSLog(@"PFSession state is created");
        }
        if ([PFFacebookUtils session].state == FBSessionStateCreatedOpening) {
            NSLog(@"PFSession state is created opening");
        }
        if ([PFFacebookUtils session].state == FBSessionStateCreatedTokenLoaded) {
            NSLog(@"PFSession state is created token loaded");
        }
    }
    NSLog(@"Current PFUser = %@",[PFUser currentUser]);
}


@end
