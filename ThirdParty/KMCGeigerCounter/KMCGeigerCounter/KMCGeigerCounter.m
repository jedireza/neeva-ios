//
//  KMCGeigerCounter.m
//  KMCGeigerCounter
//
//  Created by Kevin Conner on 10/21/14.
//  Copyright (c) 2014 Kevin Conner. All rights reserved.
//

#import "KMCGeigerCounter.h"
#import <AudioToolbox/AudioToolbox.h>

@interface KMCGeigerCounterVC : UIViewController

@property (nonatomic, strong) UILabel *meterLabel;

@end

@implementation KMCGeigerCounterVC

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.meterLabel.frame = CGRectMake(self.meterLabel.frame.origin.x, fmax(0, self.view.window.safeAreaInsets.top - 16),
                                       self.meterLabel.frame.size.width, self.meterLabel.frame.size.height);
}

@end

@interface KMCGeigerCounter ()

@property (nonatomic, readwrite, assign, getter = isRunning) BOOL running;

@property (nonatomic, strong) UIWindow *counterWindow;
@property (nonatomic, strong) KMCGeigerCounterVC *vc;
@property (nonatomic, strong) UIColor *meterPerfectColor;
@property (nonatomic, strong) UIColor *meterGoodColor;
@property (nonatomic, strong) UIColor *meterBadColor;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) SystemSoundID tickSoundID;

@property (nonatomic, assign) NSInteger frameNumber;

@property (nonatomic, assign) NSInteger hardwareFramesPerSecond;
@property (nonatomic, assign) CFTimeInterval *recentFrameTimes; // malloc: CFTimeInterval[hardwareFramesPerSecond]

@end

@implementation KMCGeigerCounter

- (instancetype)initWithWindowScene:(UIWindowScene *)windowScene {
    if (self = [super init]) {
        _counterWindow = [[UIWindow alloc] initWithWindowScene:windowScene];
        _windowLevel = UIWindowLevelStatusBar + 10.0;

        _meterPerfectColor = [KMCGeigerCounter colorWithHex:0x999999 alpha:0.5];
        _meterGoodColor = [KMCGeigerCounter colorWithHex:0x66a300 alpha:0.75];
        _meterBadColor = [KMCGeigerCounter colorWithHex:0xff7f0d alpha:1.0];

        _hardwareFramesPerSecond = [UIScreen mainScreen].maximumFramesPerSecond;

        _recentFrameTimes = malloc(sizeof(*_recentFrameTimes) * _hardwareFramesPerSecond);

        [self enable];
    }
    return self;
}

#pragma mark - Helpers

+ (UIColor *)colorWithHex:(uint32_t)hex alpha:(CGFloat)alpha
{
    CGFloat red   = (CGFloat) ((hex & 0xff0000) >> 16) / 255.0f;
    CGFloat green = (CGFloat) ((hex & 0x00ff00) >> 8)  / 255.0f;
    CGFloat blue  = (CGFloat)  (hex & 0x0000ff)        / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (CFTimeInterval)lastFrameTime
{
    return _recentFrameTimes[self.frameNumber % self.hardwareFramesPerSecond];
}

- (void)recordFrameTime:(CFTimeInterval)frameTime
{
    ++self.frameNumber;
    _recentFrameTimes[self.frameNumber % self.hardwareFramesPerSecond] = frameTime;
}

- (void)clearLastSecondOfFrameTimes
{
    CFTimeInterval initialFrameTime = CACurrentMediaTime();
    for (NSInteger i = 0; i < self.hardwareFramesPerSecond; ++i) {
        _recentFrameTimes[i] = initialFrameTime;
    }
    self.frameNumber = 0;
}

- (void)updateMeterLabel
{
    NSInteger droppedFrameCount = self.droppedFrameCountInLastSecond;
    NSInteger drawnFrameCount = self.drawnFrameCountInLastSecond;

    NSString *droppedString;
    NSString *drawnString;

    if (droppedFrameCount <= 0) {
        self.vc.meterLabel.backgroundColor = self.meterPerfectColor;

        droppedString = @"--";
        self.vc.meterLabel.alpha = 0.5;
    } else {
        self.vc.meterLabel.alpha = 1;
        if (droppedFrameCount <= 2) {
            self.vc.meterLabel.backgroundColor = self.meterGoodColor;
        } else {
            self.vc.meterLabel.backgroundColor = self.meterBadColor;
        }

        droppedString = [NSString stringWithFormat:@"%ld", (long) droppedFrameCount];
    }

    if (drawnFrameCount == -1) {
        drawnString = @"--";
    } else {
        drawnString = [NSString stringWithFormat:@"%ld", (long) drawnFrameCount];
    }

    self.vc.meterLabel.text = [NSString stringWithFormat:@"%@   %@", droppedString, drawnString];
}

- (CFTimeInterval)hardwareFrameDuration
{
    return 1.0 / self.hardwareFramesPerSecond;
}

- (void)displayLinkWillDraw:(CADisplayLink *)displayLink
{
    CFTimeInterval currentFrameTime = displayLink.timestamp;
    CFTimeInterval frameDuration = currentFrameTime - [self lastFrameTime];

    // Frames should be even multiples of hardwareFrameDuration.
    // If a frame takes two frame durations, we dropped at least one, so click.
    if (1.5 < frameDuration / [self hardwareFrameDuration]) {
        AudioServicesPlaySystemSound(self.tickSoundID);
    }

    [self recordFrameTime:currentFrameTime];

    [self updateMeterLabel];
}

#pragma mark -

- (void)start
{
    NSURL *tickSoundURL = [[NSBundle bundleForClass:KMCGeigerCounter.class] URLForResource:@"KMCGeigerCounterTick" withExtension:@"aiff"];
    SystemSoundID tickSoundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) tickSoundURL, &tickSoundID);
    self.tickSoundID = tickSoundID;

    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkWillDraw:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [self clearLastSecondOfFrameTimes];
}

- (void)stop
{
    [self.displayLink invalidate];
    self.displayLink = nil;

    AudioServicesDisposeSystemSoundID(self.tickSoundID);
    self.tickSoundID = 0;
}

- (void)setRunning:(BOOL)running
{
    if (_running != running) {
        if (running) {
            [self start];
        } else {
            [self stop];
        }

        _running = running;
    }
}

#pragma mark -

- (void)applicationDidBecomeActive
{
    self.running = YES;
}

- (void)applicationWillResignActive
{
    self.running = NO;
}

#pragma mark -

- (void)enable
{
    self.vc = [[KMCGeigerCounterVC alloc] init];
    self.counterWindow.rootViewController = self.vc;
    self.counterWindow.windowLevel = self.windowLevel;
    self.counterWindow.userInteractionEnabled = NO;

    CGFloat const kMeterWidth = 105.0;
    CGFloat const kMeterHeight = 15.0;

    self.vc.meterLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.counterWindow.bounds) - kMeterWidth) / 2.0,
                                                                self.counterWindow.safeAreaInsets.top - 16,
                                                                kMeterWidth, kMeterHeight)];
    self.vc.meterLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    self.vc.meterLabel.font = [UIFont boldSystemFontOfSize:12.0];
    self.vc.meterLabel.backgroundColor = [UIColor grayColor];
    self.vc.meterLabel.textColor = [UIColor whiteColor];
    self.vc.meterLabel.textAlignment = NSTextAlignmentCenter;
    self.vc.meterLabel.layer.cornerRadius = 11;
    self.vc.meterLabel.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
    self.vc.meterLabel.layer.masksToBounds = YES;
    [self.vc.view addSubview:self.vc.meterLabel];

    self.counterWindow.hidden = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];

    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        self.running = YES;
    }
}

- (void)disable
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.running = NO;

    self.vc = nil;
    self.counterWindow = nil;
}

#pragma mark - Init/dealloc

- (void)dealloc
{
    [_displayLink invalidate];

    if (_tickSoundID) {
        AudioServicesDisposeSystemSoundID(_tickSoundID);
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    if (_recentFrameTimes) {
        free(_recentFrameTimes);
        _recentFrameTimes = nil;
    }
}

#pragma mark - Public interface

+ (instancetype)sharedGeigerCounter
{
    static KMCGeigerCounter *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[KMCGeigerCounter alloc] init];
    });
    return instance;
}

- (void)setWindowLevel:(UIWindowLevel)windowLevel
{
    _windowLevel = windowLevel;
    self.counterWindow.windowLevel = windowLevel;
}

- (NSInteger)droppedFrameCountInLastSecond
{
    NSInteger droppedFrameCount = 0;

    CFTimeInterval lastFrameTime = CACurrentMediaTime() - [self hardwareFrameDuration];
    for (NSInteger i = 0; i < self.hardwareFramesPerSecond; ++i) {
        if (1.0 <= lastFrameTime - _recentFrameTimes[i]) {
            ++droppedFrameCount;
        }
    }

    return droppedFrameCount;
}

- (NSInteger)drawnFrameCountInLastSecond
{
    if (!self.running || self.frameNumber < self.hardwareFramesPerSecond) {
        return -1;
    }

    return self.hardwareFramesPerSecond - self.droppedFrameCountInLastSecond;
}

@end
