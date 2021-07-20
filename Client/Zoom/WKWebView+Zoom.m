// Copyright Neeva. All rights reserved.

#import "WKWebView+Zoom.h"

#ifdef USE_PRIVATE_WEB_VIEW_ZOOM_API
@implementation WKWebView (Zoom)

- (CGFloat)neeva_zoomAmount {
    // "_viewScale"
    NSArray<NSString *> *chars = @[@"_vi", @"wScal", @""];
    NSNumber *value = [self valueForKey:[chars componentsJoinedByString:@"e"]];
    return [value doubleValue];
}

- (void)setNeeva_zoomAmount:(CGFloat)amount {
    // "_viewScale"
    unichar unichars[2] = {'w', 'S'};
    NSArray<NSString *> *chars = @[@"_v", @"ie", [NSString stringWithCharacters:unichars length:2], @"ca", @"le"];
    [self setValue:[NSNumber numberWithDouble:amount] forKey:[chars componentsJoinedByString:@""]];
}

@end
#endif
