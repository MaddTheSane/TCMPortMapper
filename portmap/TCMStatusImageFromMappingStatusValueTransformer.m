
#import "TCMStatusImageFromMappingStatusValueTransformer.h"
#import <Cocoa/Cocoa.h>

@implementation TCMStatusImageFromMappingStatusValueTransformer
+ (Class)transformedValueClass {
    return [NSImage class];
}

- (id)transformedValue:(id)value {
    if ([value isKindOfClass:[NSNumber class]]) {
        switch([value intValue]) {
            case 2: return [NSImage imageNamed:NSImageNameStatusAvailable];
            case 1: return [NSImage imageNamed:NSImageNameStatusPartiallyAvailable];
            default: return [NSImage imageNamed:NSImageNameStatusUnavailable];
        }
    } else {
        return [NSImage imageNamed:NSImageNameStatusNone];
    }
}
@end
