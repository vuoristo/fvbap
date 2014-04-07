//
//  Goal.m
//  fvbap
//
//  Created by Risto Vuorio on 23/03/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Goal.h"

@implementation Goal
-(void)didLoadFromCCB {
    self.physicsBody.collisionType = @"goal";
    self.physicsBody.sensor = TRUE;
    
}

@end
