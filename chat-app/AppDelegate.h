//
//  AppDelegate.h
//  chat-app
//
//  Created by Yong Su on 3/6/19.
//  Copyright © 2019 Yong Su. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPCManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MPCManager *mpcManager;

@end

