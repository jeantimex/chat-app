//
//  PeersTableViewController.h
//  chat-app
//
//  Created by Yong Su on 3/10/19.
//  Copyright © 2019 Yong Su. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MPCManager.h"

@interface PeersTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, MPCManagerDelegate>

@property (strong, nonatomic) AppDelegate *appDelegate;

@property (assign, nonatomic) BOOL isAdvertising;

@end
