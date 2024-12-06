#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#include "functional"

class HYVideoFrameData {
public:
    uint8_t *yData;
    uint8_t *uvData;
    int width;
    int height;
    int yStride;
    int uvStride;
    int64_t pts;

    HYVideoFrameData()
        : yData(nullptr)
        , uvData(nullptr)
        , width(0)
        , height(0)
        , yStride(0)
        , uvStride(0)
        , pts(0) {}

    ~HYVideoFrameData() {
        if (yData) {
            delete[] yData;
            yData = nullptr;
        }
        if (uvData) {
            delete[] uvData;
            uvData = nullptr;
        }
    }
};

using VideoEndCallback = std::function<void()>;

@interface HYVideoDecoder : NSObject

- (instancetype)init: (void *)context callback:(VideoEndCallback)callback;
- (void)setSource: (const char*)path;
- (const HYVideoFrameData*)getFrameData;
- (void)start;
- (void)pause;
- (void)stop;
- (bool)isPaused;

@end