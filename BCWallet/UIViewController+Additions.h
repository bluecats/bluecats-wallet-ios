//
//  UIViewController+BCExtra.h
//  BCWallet
//
//  Created by Cody Singleton on 2/24/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (BCExtra)

-(void)setFontFamily:(NSString*)fontFamily forView:(UIView*)view includingSubViews:(BOOL)includeSubViews;

@end
