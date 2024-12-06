#pragma once

#include "ITestDraw.h"
#include <effects/SkRuntimeEffect.h>
#include "HYVideoDecoder.h"
#include <core/SkPaint.h>
#include <skparagraph/include/TypefaceFontProvider.h>
#include <skparagraph/include/ParagraphBuilder.h>

class SimpleVideoTest: public ITestDraw {
    
public:
    
    SimpleVideoTest(std::shared_ptr<SkiaUIContext>& context);
    
    ~SimpleVideoTest();
    
    virtual void doDrawTest(int drawCount, SkCanvas *canvas, int viewWidth, int viewHeight) override;
    
    virtual void setSource(const char *path) override;
    
    virtual void setTitle(const char *title) override;
    
    virtual void playNext() override;
    
    virtual void playPrevious() override;
    
    virtual void pauseOrPlay() override;
    
private:
    
    sk_sp<SkRuntimeEffect> runtimeEffect = nullptr;
    
    HYVideoDecoder* videoDecoder = nullptr;
    
    std::unique_ptr<Paragraph> paragraph = nullptr;
    
    std::vector<std::string> mp4Files;
    
    int index = 0;
    
    void setMp4();
    
};
