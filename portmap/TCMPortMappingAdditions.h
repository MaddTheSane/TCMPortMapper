//
//  TCMPortMappingAdditions.h
//
//  Copyright (c) 2007-2008 TheCodingMonkeys: 
//  Martin Pittenauer, Dominik Wagner, <http://codingmonkeys.de>
//  Some rights reserved: <http://opensource.org/licenses/mit-license.php> 
//

#import <Foundation/Foundation.h>
#import <TCMPortMapper/TCMPortMapper.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCMPortMapping (TCMPortMappingAdditions)

+ (instancetype)portMappingWithDictionaryRepresentation:(NSDictionary<NSString*,id> *)aDictionary;
@property (readonly, copy) NSDictionary<NSString*,id> *dictionaryRepresentation;

@end

NS_ASSUME_NONNULL_END
