//
//  NSMutableArray+Queue.h
//  
//
//  Created by Andrew Cavanagh on 7/19/15.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Queue)
- (void)push:(id)obj;
- (id)pop;
- (id)topObject;
@end
