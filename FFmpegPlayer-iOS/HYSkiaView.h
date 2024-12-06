#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYSkiaView : UIView

- (void)onBackPressed: (float)distance;

- (void)onBackMoved: (float)distance;

- (void)playNext;

- (void)playPrevious;

- (void)pauseOrPlay;

@end

NS_ASSUME_NONNULL_END
