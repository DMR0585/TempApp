//
//  CyclicMutableArray.m
//  WhoGoesThere
//
//  Created by Dan Reife on 4/10/13.
//  Copyright (c) 2013 Dan Reife. All rights reserved.
//

#import "CyclicMutableArray.h"

@implementation CyclicMutableArray

NSUInteger first = 0;
NSUInteger last = 0;
NSUInteger size = 0;
NSMutableArray *array;

- (id) initWithCapacity:(NSUInteger)numItems {
    array = [[NSMutableArray alloc] initWithCapacity:numItems];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) firstObject {
    return [array objectAtIndex:first];
}

- (id) lastObject {
    return [array objectAtIndex:last - 1];
}

#pragma mark - NSArray primitive methods (override)

- (NSUInteger) count {
    return [array count];
}

- (id)objectAtIndex:(NSUInteger)index {
    return [array objectAtIndex:index];
}


#pragma mark - NSMutableArray primitive methods (override)

- (void)insertObject:(id)pin atIndex:(NSUInteger)index {
    [array insertObject:pin atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [array removeObjectAtIndex:index];
}

- (void)addObject:(id)pin {
    if ([self count] == 4) {
        [array replaceObjectAtIndex:first withObject:pin];
        last = first;
        if (++first == 4) first = 0;
    }
    else {
        [array insertObject:pin atIndex:last];
        if (++last == 4) last = 0;
    }
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)pin {
    [array replaceObjectAtIndex:index withObject:pin];
}



@end
