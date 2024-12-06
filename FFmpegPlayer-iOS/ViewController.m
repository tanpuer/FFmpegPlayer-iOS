#import "ViewController.h"
#import "HYSkiaView.h"

@interface ViewController ()

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *_leftEdgePanGesture;
@property (nonatomic, strong) HYSkiaView *_skiaView;

@property (nonatomic, strong) UIButton *prevButton;
@property (nonatomic, strong) UIButton *playPauseButton;
@property (nonatomic, strong) UIButton *nextButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    int width = [UIScreen mainScreen].bounds.size.width;
    int height = [UIScreen mainScreen].bounds.size.height;
    CGFloat statusBarHeight = 0;
    if (@available(iOS 13.0, *)) {
        UIWindowScene *windowScene = (UIWindowScene *)UIApplication.sharedApplication.connectedScenes.anyObject;
        statusBarHeight = windowScene.statusBarManager.statusBarFrame.size.height;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        statusBarHeight = UIApplication.sharedApplication.statusBarFrame.size.height;
#pragma clang diagnostic pop
    }
    height -= statusBarHeight;
    self._skiaView = [[HYSkiaView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    [self.view addSubview: self._skiaView];
    self._skiaView.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(iOS 11.0, *)) {
        UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
        [NSLayoutConstraint activateConstraints:@[
            [self._skiaView.topAnchor constraintEqualToAnchor:safeArea.topAnchor],
            [self._skiaView.leadingAnchor constraintEqualToAnchor:safeArea.leadingAnchor],
            [self._skiaView.trailingAnchor constraintEqualToAnchor:safeArea.trailingAnchor],
            [self._skiaView.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor]
        ]];
    }
    self._leftEdgePanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftEdgePan:)];
    self._leftEdgePanGesture.edges = UIRectEdgeLeft;
    self._leftEdgePanGesture.delegate = (id)self;
    [self.view addGestureRecognizer:self._leftEdgePanGesture];
    
    [self addControlButtons];
}

- (void)handleLeftEdgePan:(UIScreenEdgePanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
    if (translation.x < 0) {
        translation.x = 0.0f;
    }
    switch (recognizer.state) {
        case UIGestureRecognizerStateChanged: {
            CGFloat scale = [[UIScreen mainScreen]scale];
            [self._skiaView onBackMoved:translation.x * scale];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            CGFloat scale = [[UIScreen mainScreen]scale];
            [self._skiaView onBackPressed:translation.x * scale];
            break;
        }
        default:
            break;
    }
}

- (void)addControlButtons {
    CGFloat buttonWidth = 60;
    CGFloat buttonHeight = 40;
    CGFloat buttonSpacing = 20;
    CGFloat bottomMargin = 50;
    
    // 创建上一首按钮
    self.prevButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.prevButton setTitle:@"⏮" forState:UIControlStateNormal];
    self.prevButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.prevButton];
    [self.prevButton addTarget:self action:@selector(prevButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    // 创建播放/暂停按钮
    self.playPauseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.playPauseButton setTitle:@"⏯" forState:UIControlStateNormal];
    self.playPauseButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.playPauseButton];
    [self.playPauseButton addTarget:self action:@selector(playPauseButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    // 创建下一首按钮
    self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.nextButton setTitle:@"⏭" forState:UIControlStateNormal];
    self.nextButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.nextButton];
    [self.nextButton addTarget:self action:@selector(nextButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    // 设置按钮约束
    if (@available(iOS 11.0, *)) {
        UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
        [NSLayoutConstraint activateConstraints:@[
            // 播放/暂停按钮居中
            [self.playPauseButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [self.playPauseButton.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor constant:-bottomMargin],
            [self.playPauseButton.widthAnchor constraintEqualToConstant:buttonWidth],
            [self.playPauseButton.heightAnchor constraintEqualToConstant:buttonHeight],
            
            // 上一首按钮在播放按钮左边
            [self.prevButton.rightAnchor constraintEqualToAnchor:self.playPauseButton.leftAnchor constant:-buttonSpacing],
            [self.prevButton.centerYAnchor constraintEqualToAnchor:self.playPauseButton.centerYAnchor],
            [self.prevButton.widthAnchor constraintEqualToConstant:buttonWidth],
            [self.prevButton.heightAnchor constraintEqualToConstant:buttonHeight],
            
            // 下一首按钮在播放按钮右边
            [self.nextButton.leftAnchor constraintEqualToAnchor:self.playPauseButton.rightAnchor constant:buttonSpacing],
            [self.nextButton.centerYAnchor constraintEqualToAnchor:self.playPauseButton.centerYAnchor],
            [self.nextButton.widthAnchor constraintEqualToConstant:buttonWidth],
            [self.nextButton.heightAnchor constraintEqualToConstant:buttonHeight],
        ]];
    }
}

- (void)prevButtonTapped {
    [self._skiaView playPrevious];
}

- (void)playPauseButtonTapped {
    [self._skiaView pauseOrPlay];
}

- (void)nextButtonTapped {
    [self._skiaView playNext];
}

@end

