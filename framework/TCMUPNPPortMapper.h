//
//  TCMUPNPPortMapper.h
//  Encapsulates miniupnp framework
//
//  Copyright (c) 2007-2008 TheCodingMonkeys: 
//  Martin Pittenauer, Dominik Wagner, <http://codingmonkeys.de>
//  Some rights reserved: <http://opensource.org/licenses/mit-license.php> 
//

#import "TCMPortMapper.h"
#import "TCMNATPMPPortMapper.h"
#include "miniwget.h"
#include "miniupnpc.h"
#include "upnpcommands.h"
#include "upnperrors.h"

extern NSNotificationName const TCMUPNPPortMapperDidFailNotification;
extern NSNotificationName const TCMUPNPPortMapperDidGetExternalIPAddressNotification;
extern NSNotificationName const TCMUPNPPortMapperDidBeginWorkingNotification;
extern NSNotificationName const TCMUPNPPortMapperDidEndWorkingNotification;

@interface TCMUPNPPortMapper : NSObject {
    NSLock *_threadIsRunningLock;
    BOOL refreshThreadShouldQuit;
    BOOL UpdatePortMappingsThreadShouldQuit;
    BOOL UpdatePortMappingsThreadShouldRestart;
    TCMPortMappingThreadID runningThreadID;
    NSArray<NSDictionary<NSString*,id>*> *_latestUPNPPortMappingsList;
    struct UPNPUrls _urls;
    struct IGDdatas _igddata;
}

- (void)refresh;
- (void)updatePortMappings;
- (void)stop;
- (void)stopBlocking;
@property (readonly, copy) NSArray<NSDictionary<NSString*,id>*> *latestUPNPPortMappingsList;

@end
