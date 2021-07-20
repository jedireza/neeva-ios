// Copyright Neeva. All rights reserved.

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef USE_PRIVATE_WEB_VIEW_ZOOM_API
@interface WKWebView (Zoom)

@property CGFloat neeva_zoomAmount;

@end
#endif

NS_ASSUME_NONNULL_END
