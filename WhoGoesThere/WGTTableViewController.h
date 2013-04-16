//
//  WGTTableViewController.h
//  WhoGoesThere
//
//  Created by Dan Reife on 4/9/13.
//  Copyright (c) 2013 Dan Reife. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface WGTTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
