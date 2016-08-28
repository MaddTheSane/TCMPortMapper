//
//  TCMPortMapper.h
//  Establishes port mapping via upnp or natpmp
//
//  Copyright (c) 2007-2008 TheCodingMonkeys: 
//  Martin Pittenauer, Dominik Wagner, <http://codingmonkeys.de>
//  Some rights reserved: <http://opensource.org/licenses/mit-license.php> 
//

#import <Foundation/Foundation.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>

extern NSString * const TCMPortMapperExternalIPAddressDidChange;

extern NSString * const TCMPortMapperWillStartSearchForRouterNotification;
extern NSString * const TCMPortMapperDidFinishSearchForRouterNotification;

extern NSString * const TCMPortMapperDidStartWorkNotification;
extern NSString * const TCMPortMapperDidFinishWorkNotification;

extern NSString * const TCMPortMapperDidReceiveUPNPMappingTableNotification;

extern NSString * const TCMPortMappingDidChangeMappingStatusNotification;


extern NSString * const TCMNATPMPPortMapProtocol;
extern NSString * const TCMUPNPPortMapProtocol;  
extern NSString * const TCMNoPortMapProtocol;

typedef NS_ENUM(NSInteger, TCMPortMappingStatus) {
    TCMPortMappingStatusUnmapped = 0,
    TCMPortMappingStatusTrying   = 1,
    TCMPortMappingStatusMapped   = 2
};

typedef NS_ENUM(NSInteger, TCMPortMappingTransportProtocol) {
    TCMPortMappingTransportProtocolUDP  = 1,
    TCMPortMappingTransportProtocolTCP  = 2,
    TCMPortMappingTransportProtocolBoth = 3
};


@interface TCMPortMapping : NSObject {
    int _localPort;
    int _externalPort;
    int _desiredExternalPort;
    id  _userInfo;
    TCMPortMappingStatus _mappingStatus;
    TCMPortMappingTransportProtocol _transportProtocol;
}
+ (instancetype)portMappingWithLocalPort:(int)aPrivatePort desiredExternalPort:(int)aPublicPort transportProtocol:(TCMPortMappingTransportProtocol)aTransportProtocol userInfo:(id)aUserInfo;
- (instancetype)initWithLocalPort:(int)aPrivatePort desiredExternalPort:(int)aPublicPort transportProtocol:(TCMPortMappingTransportProtocol)aTransportProtocol userInfo:(id)aUserInfo;
@property (readonly) int desiredExternalPort;
@property (readonly, retain) id userInfo;
@property (nonatomic) TCMPortMappingStatus mappingStatus;
@property TCMPortMappingTransportProtocol transportProtocol;
@property int externalPort;
@property (readonly) int localPort;

@end

@interface TCMPortMapper : NSObject {
    NSMutableSet *_portMappings;
    NSMutableSet *_removeMappingQueue;
    BOOL _isRunning;
    NSString *_localIPAddress;
    NSString *_externalIPAddress;
    int _NATPMPStatus;
    int _UPNPStatus;
    NSString *_mappingProtocol;
    NSString *_routerName;
    int _workCount;
    BOOL _localIPOnRouterSubnet;
    BOOL _sendUPNPMappingTableNotification;
    NSString *_userID;
    NSMutableSet *_upnpPortMappingsToRemove;
    NSTimer *_upnpPortMapperTimer;
    BOOL _ignoreNetworkChanges;
    BOOL _refreshIsScheduled;
    NSString *_appIdentifier;
}

+ (TCMPortMapper *)sharedInstance;
#if __has_feature(objc_class_property)
@property (class, readonly, strong) TCMPortMapper *sharedInstance;
#endif
+ (NSString *)manufacturerForHardwareAddress:(NSString *)aMACAddress;
+ (NSString *)sizereducableHashOfString:(NSString *)inString;

@property (readonly, copy) NSSet<TCMPortMapping*> *portMappings;
@property (readonly, strong) NSMutableSet *removeMappingQueue;
- (void)addPortMapping:(TCMPortMapping *)aMapping;
- (void)removePortMapping:(TCMPortMapping *)aMapping;
- (void)refresh;

@property (readonly, getter=isAtWork) BOOL atWork;
@property (readonly, getter=isRunning) BOOL running;
- (void)start;
- (void)stop;
- (void)stopBlocking;

@property (nonatomic, copy) NSString *appIdentifier;

/// will request the complete UPNPMappingTable and deliver it using a TCMPortMapperDidReceiveUPNPMappingTableNotification with "mappingTable" in the userInfo Dictionary (if current router is a UPNP router)
- (void)requestUPNPMappingTable;
/// this is mainly for Port Map.app and can remove any mappings that can be removed using UPNP (including mappings from other hosts). aMappingList is an Array of Dictionaries with the key @"protocol" and @"publicPort".
- (void)removeUPNPMappings:(NSArray *)aMappingList;

/// needed for generating a UPNP port mapping description that differs for each user
@property (copy) NSString *userID;
/// we provide a half length md5 has for convenience
/// we could use full length but the description field of the routers might be limited
- (void)hashUserID:(NSString *)aUserIDToHash;

@property (readonly, copy) NSString *externalIPAddress;
@property (readonly, copy) NSString *localIPAddress;
@property (readonly, copy) NSString *localBonjourHostName;
@property (copy) NSString *mappingProtocol;
@property (copy) NSString *routerName;
@property (readonly, copy) NSString *routerIPAddress;
@property (readonly, copy) NSString *routerHardwareAddress;

// private accessors
- (NSMutableSet *)_upnpPortMappingsToRemove;


@end
