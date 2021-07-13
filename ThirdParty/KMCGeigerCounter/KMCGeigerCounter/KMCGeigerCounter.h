//
//  KMCGeigerCounter.h
//  KMCGeigerCounter
//
//  Created by Kevin Conner on 10/21/14.
//  Copyright (c) 2014 Kevin Conner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMCGeigerCounter : NSObject

-(void)disable;

// The meter draws over the status bar. Set the window level manually if your own custom windows obscure it.
@property (nonatomic, assign) UIWindowLevel windowLevel;

@property (nonatomic, readonly, getter = isRunning) BOOL running;
@property (nonatomic, readonly) NSInteger droppedFrameCountInLastSecond;
@property (nonatomic, readonly) NSInteger drawnFrameCountInLastSecond; // -1 until one second of frames have been collected

- (nonnull instancetype)initWithWindowScene:(nonnull UIWindowScene *)windowScene;

@end
