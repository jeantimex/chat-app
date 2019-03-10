//
//  MPCManager.h
//  chat-app
//
//  Created by Yong Su on 3/9/19.
//  Copyright © 2019 Yong Su. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@protocol MPCManagerDelegate <NSObject>

@required
- (void)lostPeer:(MCPeerID *)peerID;
- (void)foundPeer:(MCPeerID *)peerID;
- (void)connectedWithPeer:(MCPeerID *)peerID;
- (void)invitationWasReceived:(MCPeerID *)peerID;

@optional
- (void)didNotStartBrowsingForPeers:(NSError *)error;
- (void)didNotStartAdvertisingPeer:(NSError *)error;

@end

@interface MPCManager : NSObject <MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate>

@property (nonatomic, weak) id <MPCManagerDelegate, NSObject> delegate;

@property (strong, nonatomic) MCPeerID *peerID;
@property (strong, nonatomic) MCSession *session;
@property (strong, nonatomic) MCNearbyServiceBrowser *browser;
@property (strong, nonatomic) MCNearbyServiceAdvertiser *advertiser;

@property (copy, nonatomic) NSMutableArray *foundPeers;
@property (copy, nonatomic) void (^invitationHandler)(BOOL, MCSession * _Nullable);

//
//  Public Methods
//

- (BOOL)sendData:(NSDictionary *)data toPeer:(MCPeerID *)peerID;

@end
