//
//  UIViewController+Additions.m
//  BCWallet
//
//  Created by Cody Singleton on 2/24/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import "UIViewController+Additions.h"

@implementation UIViewController (Additions)

-(void)setFontFamily:(NSString*)fontFamily forView:(UIView*)view includingSubViews:(BOOL)includeSubViews
{
    if ([view isKindOfClass:[UILabel class]])
    {
        UILabel *label = (UILabel *)view;
        [label setFont:[UIFont fontWithName:fontFamily size:[[label font] pointSize]]];
    }
    
    if (includeSubViews)
    {
        for (UIView *subview in view.subviews)
        {
            [self setFontFamily:fontFamily forView:subview includingSubViews:YES];
        }
    }
}

@end
