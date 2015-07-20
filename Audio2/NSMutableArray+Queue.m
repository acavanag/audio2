//
//  NSMutableArray+Queue.m
//  
//
//  Created by Andrew Cavanagh on 7/19/15.
//
//

#import "NSMutableArray+Queue.h"

@implementation NSMutableArray (Queue)

- (void)push:(id)obj
{
    [self addObject:obj];
}

- (id)pop
{
    id topObject = [self topObject];
    if (topObject) {
        [self removeObjectAtIndex:0];
        return topObject;
    }
    return nil;
}

- (id)topObject
{
    if (self.count > 0) {
        return self[0];
    }
    return nil;
}

@end
