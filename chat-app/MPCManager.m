//
//  MPCManager.m
//  chat-app
//
//  Created by Yong Su on 3/9/19.
//  Copyright © 2019 Yong Su. All rights reserved.
//

#import "MPCManager.h"

@implementation MPCManager

@synthesize delegate;

- (id)initWithDisplayName:(NSString *)displayName andServiceType:(NSString *)serviceType {
    self = [super init];
    
    if (self) {
        _peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
        
        _session = [[MCSession alloc] initWithPeer:_peerID];
        _session.delegate = self;
        
        _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_peerID serviceType:serviceType];
        _browser.delegate = self;
        
        _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_peerID discoveryInfo:nil serviceType:serviceType];
        _advertiser.delegate = self;
        
        _foundPeers = [[NSMutableArray alloc] init];
    }
    
    return self;
}

# pragma mark - MCNearbyServiceBrowserDelegate

- (void)browser:(nonnull MCNearbyServiceBrowser *)browser foundPeer:(nonnull MCPeerID *)peerID withDiscoveryInfo:(nullable NSDictionary<NSString *,NSString *> *)info {
    [_foundPeers addObject:peerID];
    
    if ([self->delegate respondsToSelector:@selector(foundPeer:)]) {
        [self->delegate foundPeer:peerID];
    }
}

- (void)browser:(nonnull MCNearbyServiceBrowser *)browser lostPeer:(nonnull MCPeerID *)peerID {
    for (NSUInteger i = 0; i < [_foundPeers count]; i++) {
        if ([_foundPeers objectAtIndex:i] == peerID) {
            [_foundPeers removeObjectAtIndex:i];
            break;
        }
    }
    
    if ([self->delegate respondsToSelector:@selector(lostPeer:)]) {
        [self->delegate lostPeer:peerID];
    }
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    if ([self->delegate respondsToSelector:@selector(didNotStartBrowsingForPeers:)]) {
        [self->delegate didNotStartBrowsingForPeers:error];
    }
}

# pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(nonnull MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(nonnull MCPeerID *)peerID withContext:(nullable NSData *)context invitationHandler:(nonnull void (^)(BOOL, MCSession * _Nullable))invitationHandler {
    _invitationHandler = invitationHandler;
    
    if ([self->delegate respondsToSelector:@selector(invitationWasReceived:)]) {
        [self->delegate invitationWasReceived:peerID];
    }
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error {
    if ([self->delegate respondsToSelector:@selector(didNotStartAdvertisingPeer:)]) {
        [self->delegate didNotStartAdvertisingPeer:error];
    }
}

# pragma mark - MCSession Delegate method implementation

- (void)session:(nonnull MCSession *)session peer:(nonnull MCPeerID *)peerID didChangeState:(MCSessionState)state {
    switch (state) {
        case MCSessionStateConnected:
        {
            if ([self->delegate respondsToSelector:@selector(connectedWithPeer:)]) {
                [self->delegate connectedWithPeer:peerID];
            }
            break;
        }
        case MCSessionStateConnecting:
        {
            NSLog(@"Connecting to session");
        }
        default:
        {
            NSLog(@"Did not connect to session");
        }
    }
}

- (void)session:(nonnull MCSession *)session didReceiveData:(nonnull NSData *)data fromPeer:(nonnull MCPeerID *)peerID {
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:data, @"data", peerID, @"fromPeer", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedMPCDataNotification" object:dictionary];
}

- (void)session:(nonnull MCSession *)session didFinishReceivingResourceWithName:(nonnull NSString *)resourceName fromPeer:(nonnull MCPeerID *)peerID atURL:(nullable NSURL *)localURL withError:(nullable NSError *)error {
}

- (void)session:(nonnull MCSession *)session didReceiveStream:(nonnull NSInputStream *)stream withName:(nonnull NSString *)streamName fromPeer:(nonnull MCPeerID *)peerID {
}

- (void)session:(nonnull MCSession *)session didStartReceivingResourceWithName:(nonnull NSString *)resourceName fromPeer:(nonnull MCPeerID *)peerID withProgress:(nonnull NSProgress *)progress {
}

# pragma mark - Public method implementation

- (BOOL)sendData:(NSDictionary *)dictionary toPeer:(MCPeerID *)peerID {
    NSData *dataToSend = [NSKeyedArchiver archivedDataWithRootObject:dictionary requiringSecureCoding:NO error:nil];
    NSArray *peers = [[NSArray alloc] initWithObjects:peerID, nil];
    NSError *error = nil;
    if (![_session sendData:dataToSend toPeers:peers withMode:MCSessionSendDataReliable error:&error]) {
        return NO;
    }
    return YES;
}

@end
