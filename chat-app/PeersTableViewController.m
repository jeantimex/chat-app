//
//  PeersTableViewController.m
//  chat-app
//
//  Created by Yong Su on 3/10/19.
//  Copyright © 2019 Yong Su. All rights reserved.
//

#import "PeersTableViewController.h"

@interface PeersTableViewController ()

@end

@implementation PeersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _appDelegate.mpcManager.delegate = self;
    
    [_appDelegate.mpcManager.browser startBrowsingForPeers];
    [_appDelegate.mpcManager.advertiser startAdvertisingPeer];
    
    _isAdvertising = YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _appDelegate.mpcManager.foundPeers.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    // Configure the cell...
    cell.textLabel.text = [_appDelegate.mpcManager.foundPeers[indexPath.row] displayName];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MCPeerID *selectedPeer = (MCPeerID *)_appDelegate.mpcManager.foundPeers[indexPath.row];
    
    [_appDelegate.mpcManager.browser invitePeer:selectedPeer toSession:_appDelegate.mpcManager.session withContext:nil timeout:20];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)foundPeer:(MCPeerID *)peerID {
    [self.tableView reloadData];
}

- (void)invitationWasReceived:(MCPeerID *)peerID {
    NSString *fromPeer = [peerID displayName];
    NSString *message = [NSString stringWithFormat:@"%@ wants to chat with you", fromPeer];
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@""
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* acceptButton = [UIAlertAction
                                     actionWithTitle:@"Accept"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                         self->_appDelegate.mpcManager.invitationHandler(YES, self->_appDelegate.mpcManager.session);
                                     }];
    
    UIAlertAction* declineButton = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleCancel
                                 handler:^(UIAlertAction * action) {
                                     self->_appDelegate.mpcManager.invitationHandler(NO, nil);
                                 }];
    
    [alert addAction:acceptButton];
    [alert addAction: declineButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)connectedWithPeer:(MCPeerID *)peerID {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"startGame" sender:self];
    });
}

- (void)lostPeer:(MCPeerID *)peerID {
    [self.tableView reloadData];
}

@end
