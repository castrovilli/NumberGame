//
//  AppHelper.m
//  Donde Comer
//
//  Created by Mandaron on 09.02.14.
//  Copyright (c) 2014 Mandaron Mobile. All rights reserved.
//

#import "AppHelper.h"

@implementation AppHelper

+ (BOOL)isPhone {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
}

@end
