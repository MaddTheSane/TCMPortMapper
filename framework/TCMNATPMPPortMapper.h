//
//  TCMNATPMPPortMapper.h
//  Encapsulates libnatpmp, listens for router changes
//
//  Copyright (c) 2007-2008 TheCodingMonkeys: 
//  Martin Pittenauer, Dominik Wagner, <http://codingmonkeys.de>
//  Some rights reserved: <http://opensource.org/licenses/mit-license.php> 
//

#import "TCMPortMapper.h"

#include "natpmp.h"

extern NSString * const TCMNATPMPPortMapperDidFailNotification;
extern NSString * const TCMNATPMPPortMapperDidGetExternalIPAddressNotification;
extern NSString * const TCMNATPMPPortMapperDidBeginWorkingNotification;
extern NSString * const TCMNATPMPPortMapperDidEndWorkingNotification  ;
extern NSString * const TCMNATPMPPortMapperDidReceiveBroadcastedExternalIPChangeNotification;

typedef NS_ENUM(char, TCMPortMappingThreadID) {
    TCMExternalIPThreadID = 0,
    TCMUpdatingMappingThreadID = 1,
};

@interface TCMNATPMPPortMapper : NSObject {
    NSLock *natPMPThreadIsRunningLock;
    int IPAddressThreadShouldQuitAndRestart;
    BOOL UpdatePortMappingsThreadShouldQuit;
    BOOL UpdatePortMappingsThreadShouldRestart;
    TCMPortMappingThreadID runningThreadID;
    NSTimer *_updateTimer;
    NSTimeInterval _updateInterval;
    NSString *_lastExternalIPSenderAddress;
    NSString *_lastBroadcastedExternalIP;
    CFSocketRef _externalAddressChangeListeningSocket;
}

- (void)refresh;
- (void)stop;
- (void)updatePortMappings;
- (void)stopBlocking;

- (void)ensureListeningToExternalIPAddressChanges;
- (void)stopListeningToExternalIPAddressChanges;

@end
