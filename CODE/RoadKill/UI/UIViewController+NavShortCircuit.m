//
//  UIViewController+NavShortCircuit.m
//  RoadKill
//
//  Created by Gerard Hickey on 1/4/11.
//  Copyright 2011 Seattle RoadKill Team. All rights reserved.
//

#import "UIViewController+NavShortCircuit.h"
#import "Debug.h"


@implementation UIViewController (NavShortCircuit)

- (UIViewController *) popToController {
    RKLog(@"popToController called: %@", [self description]);
    UIViewController *vc = [self.parentViewController popToController];
    return vc;
}

@end
