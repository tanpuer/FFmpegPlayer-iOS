#pragma once

#include <include/core/SkPicture.h>
#include "SkiaUIContext.h"
#include "ITestDraw.h"
#include "TouchEvent.h"

class HYSkiaUIApp {
    
public:
    
    HYSkiaUIApp(int width, int height, NSThread *skiaUIThread);
    
    ~HYSkiaUIApp();
    
    SkPicture* doFrame(long time);
    
    void dispatchTouchEvent(TouchEvent *touchEvent);
    
    void setVelocity(float x, float y);
    
    void onBackPressed(float distance);
    
    void onBackMoved(float distance);
    
    void onShow();
    
    void onHide();
    
    void playNext();
    
    void playPrevious();
    
    void pauseOrPlay();
    
private:
    
    int _width = 0;
    
    int _height = 0;
    
    std::shared_ptr<SkiaUIContext> _context;
    
    std::unique_ptr<ITestDraw> testDraw;
    
    int drawCount = 0;
    
    std::unique_ptr<TouchEvent> mTouchEvent;
};
