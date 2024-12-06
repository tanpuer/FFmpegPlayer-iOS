#include "HYSkiaUIApp.hpp"
#import <include/core/SkPictureRecorder.h>
#import <include/core/SkCanvas.h>
#import <include/core/SkPaint.h>
#include "SimpleVideoTest.h"

HYSkiaUIApp::HYSkiaUIApp(int width, int height, NSThread *skiaUIThread) {
    _width = width;
    _height = height;
    _context = std::make_shared<SkiaUIContext>(skiaUIThread);
    testDraw = std::make_unique<SimpleVideoTest>(_context);
}

HYSkiaUIApp::~HYSkiaUIApp() {
    
}

SkPicture* HYSkiaUIApp::doFrame(long time) {
    _context->setTimeMills(time);
    SkPictureRecorder recorder;
    auto recordingCanvas = recorder.beginRecording(_width, _height);
    testDraw->doDrawTest(drawCount, recordingCanvas, _width, _height);
    auto picture = recorder.finishRecordingAsPicture();
    picture->ref();
    return picture.get();
}

void HYSkiaUIApp::dispatchTouchEvent(TouchEvent *touchEvent) {
    
}

void HYSkiaUIApp::setVelocity(float x, float y) {
    
}

void HYSkiaUIApp::onBackPressed(float distance) {
    
}

void HYSkiaUIApp::onBackMoved(float distance) {
    
}

void HYSkiaUIApp::onShow() {
    
}

void HYSkiaUIApp::onHide() {
    
}

void HYSkiaUIApp::playNext() {
    testDraw->playNext();
}

void HYSkiaUIApp::playPrevious() {
    testDraw->playPrevious();
}

void HYSkiaUIApp::pauseOrPlay() {
    testDraw->pauseOrPlay();
}
