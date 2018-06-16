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

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const TCMPortMapperExternalIPAddressDidChange;

extern NSNotificationName const TCMPortMapperWillStartSearchForRouterNotification;
extern NSNotificationName const TCMPortMapperDidFinishSearchForRouterNotification;

extern NSNotificationName const TCMPortMapperDidStartWorkNotification;
extern NSNotificationName const TCMPortMapperDidFinishWorkNotification;

extern NSNotificationName const TCMPortMapperDidReceiveUPNPMappingTableNotification;

extern NSNotificationName const TCMPortMappingDidChangeMappingStatusNotification;

typedef NSString *TCMPortMapProtocol NS_TYPED_ENUM;

extern TCMPortMapProtocol const TCMNATPMPPortMapProtocol NS_SWIFT_NAME(NATPMP);
extern TCMPortMapProtocol const TCMUPNPPortMapProtocol NS_SWIFT_NAME(UPNP);
extern TCMPortMapProtocol const TCMNoPortMapProtocol NS_SWIFT_NAME(none);

typedef NS_ENUM(char, TCMPortMappingStatus) {
    TCMPortMappingStatusUnmapped = 0,
    TCMPortMappingStatusTrying   = 1,
    TCMPortMappingStatusMapped   = 2
};

typedef NS_OPTIONS(unsigned char, TCMPortMappingTransportProtocol) {
    TCMPortMappingTransportProtocolUDP  = 1,
    TCMPortMappingTransportProtocolTCP  = 2,
    TCMPortMappingTransportProtocolBoth = 3
};


@interface TCMPortMapping : NSObject {
    unsigned short _localPort;
    unsigned short _externalPort;
    unsigned short _desiredExternalPort;
    TCMPortMappingStatus _mappingStatus;
    TCMPortMappingTransportProtocol _transportProtocol;
    id  _userInfo;
}
+ (instancetype)portMappingWithLocalPort:(int)aPrivatePort desiredExternalPort:(int)aPublicPort transportProtocol:(TCMPortMappingTransportProtocol)aTransportProtocol userInfo:(nullable id)aUserInfo NS_SWIFT_UNAVAILABLE("Use TCMPortMapping(localPort:desiredExternalPort:transportProtocol:userInfo:) instead");
- (instancetype)initWithLocalPort:(unsigned short)aPrivatePort desiredExternalPort:(unsigned short)aPublicPort transportProtocol:(TCMPortMappingTransportProtocol)aTransportProtocol userInfo:(nullable id)aUserInfo;
@property (readonly) unsigned short desiredExternalPort;
@property (readonly, retain, nullable) id userInfo;
@property (nonatomic) TCMPortMappingStatus mappingStatus;
@property TCMPortMappingTransportProtocol transportProtocol;
@property unsigned short externalPort;
@property (readonly) unsigned short localPort;

@end

@interface TCMPortMapper : NSObject

@property (class, readonly, strong) TCMPortMapper *sharedInstance NS_SWIFT_NAME(shared);
+ (nullable NSString *)manufacturerForHardwareAddress:(NSString *)aMACAddress;
+ (NSString *)sizereducableHashOfString:(NSString *)inString;

- (instancetype)init NS_SWIFT_UNAVAILABLE("Use `TCMPortMapping.shared` instead");

@property (readonly, copy) NSSet<TCMPortMapping*> *portMappings;
@property (readonly, strong) NSMutableSet<TCMPortMapping*> *removeMappingQueue;
- (void)addPortMapping:(TCMPortMapping *)aMapping;
- (void)removePortMapping:(TCMPortMapping *)aMapping;
- (void)refresh;

@property (readonly, getter=isAtWork) BOOL atWork;
@property (readonly, getter=isRunning) BOOL running;
- (void)start;
- (void)stop;
- (void)stopBlocking;

@property (nonatomic, copy, null_resettable) NSString *appIdentifier;

/// will request the complete UPNPMappingTable and deliver it using a \c TCMPortMapperDidReceiveUPNPMappingTableNotification with "mappingTable" in the \c userInfo Dictionary (if current router is a UPNP router)
- (void)requestUPNPMappingTable;
/// this is mainly for Port Map.app and can remove any mappings that can be removed using UPNP (including mappings from other hosts). \c aMappingList is an Array of Dictionaries with the key @"protocol" and @"publicPort".
- (void)removeUPNPMappings:(NSArray<NSDictionary<NSString*,id>*> *)aMappingList;

/// needed for generating a UPNP port mapping description that differs for each user
@property (copy) NSString *userID;
/// we provide a half length md5 has for convenience
/// we could use full length but the description field of the routers might be limited
- (void)hashUserID:(NSString *)aUserIDToHash;

@property (readonly, copy, nullable) NSString *externalIPAddress;
@property (readonly, copy, nullable) NSString *localIPAddress;
@property (readonly, copy) NSString *localBonjourHostName;
@property (copy) TCMPortMapProtocol mappingProtocol;
@property (copy, nullable) NSString *routerName;
@property (readonly, copy, nullable) NSString *routerIPAddress;
@property (readonly, copy, nullable) NSString *routerHardwareAddress;

// private accessors
- (NSMutableSet<NSDictionary<NSString*,id>*> *)_upnpPortMappingsToRemove;


@end

NS_ASSUME_NONNULL_END
