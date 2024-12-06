#pragma once

#include "core/SkCanvas.h"
#include "SkiaUIContext.h"

class ITestDraw {

public:

    ITestDraw(std::shared_ptr<SkiaUIContext>& context) {
        this->context = context;
    };

    virtual ~ITestDraw() {};
    
    virtual void setSource(const char *path) = 0;

    virtual void doDrawTest(int drawCount, SkCanvas *canvas, int viewWidth, int viewHeight) = 0;

    virtual std::shared_ptr<SkiaUIContext> &getContext() {
        return context;
    }

    virtual void onShow() {
        
    }

    virtual void onHide() {
        
    }
    
    virtual void setTitle(const char* title) {
        this->title = title;
    }
    
    virtual void playNext() = 0;
    
    virtual void playPrevious() = 0;
    
    virtual void pauseOrPlay() = 0;

protected:

    std::shared_ptr<SkiaUIContext> context = nullptr;

    std::string title;
    
};
