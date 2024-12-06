#include "SimpleVideoTest.h"
#include <core/SkImage.h>
#include <skparagraph/include/TypefaceFontProvider.h>
#include <skparagraph/include/FontCollection.h>

SimpleVideoTest::SimpleVideoTest(std::shared_ptr<SkiaUIContext>& context): ITestDraw(context) {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSArray *bundleFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mainBundle.bundlePath error:nil];
    
    for (NSString *file in bundleFiles) {
        if ([file.pathExtension.lowercaseString isEqualToString:@"mp4"]) {
            mp4Files.push_back(file.UTF8String);
        }
    }
    auto assetManager = getContext()->getAssetManager();
    const char *kYUVtoRGBShader = assetManager->readFile("nv12_fragment_shader.glsl");
    auto [effect, error] = SkRuntimeEffect::MakeForShader(SkString(kYUVtoRGBShader));
    if (!effect) {
        ALOGD("set shader source failed %s", error.data())
        return;
    }
    runtimeEffect = effect;
    
    index = 0;
    setMp4();
}

SimpleVideoTest::~SimpleVideoTest() {
    [videoDecoder stop];
    videoDecoder = nullptr;
}

void SimpleVideoTest::setSource(const char *path) {
    MeasureTime measureTime("VideoView setSource");
    if (videoDecoder != nullptr) {
        [videoDecoder stop];
        videoDecoder = nullptr;
    }
    videoDecoder = [[HYVideoDecoder alloc]init:(void *)(getContext().get()) callback:[this]() { index++; setMp4(); }
    ];
    [videoDecoder setSource:path];
}

void SimpleVideoTest::doDrawTest(int drawCount, SkCanvas *canvas, int viewWidth, int viewHeight) {
    if (videoDecoder == nullptr) {
        return;
    }
    auto yuvData = [videoDecoder getFrameData];
    if (yuvData == nullptr) {
        return;
    }
    canvas->clear(SK_ColorBLACK);
    int width = yuvData->width;
    int height = yuvData->height;
    int ySize = yuvData->yStride * height;
    int uvSize = yuvData->uvStride * height / 2;
    if (runtimeEffect != nullptr) {
        auto y_imageInfo = SkImageInfo::Make(yuvData->yStride, height, kGray_8_SkColorType, kPremul_SkAlphaType);
        auto uv_imageInfo = SkImageInfo::Make(yuvData->uvStride / 2, height / 2, kR8G8_unorm_SkColorType, kPremul_SkAlphaType);
        sk_sp<SkData> y_data = SkData::MakeWithCopy(yuvData->yData, ySize);
        sk_sp<SkData> uv_data = SkData::MakeWithCopy(yuvData->uvData, uvSize);
        if (!uv_data) {
            ALOGD("Failed to create UV data copy");
            return;
        }
        auto y_image = SkImages::RasterFromData(y_imageInfo, y_data, yuvData->yStride);
        if (!y_image) {
            ALOGD("Failed to create Y texture");
            return;
        }
        auto uv_image = SkImages::RasterFromData(uv_imageInfo, uv_data, yuvData->uvStride);
        if (!uv_image) {
            ALOGD("Failed to create UV texture. Possible reasons:");
            ALOGD("1. Stride alignment: %d", yuvData->uvStride);
            ALOGD("2. Required size: %zu, Actual size: %zu",
                  uv_imageInfo.computeMinByteSize(),
                  uv_data->size());
            return;
        }
        SkRuntimeShaderBuilder builder(runtimeEffect);
        builder.child("y_tex") = y_image->makeShader(SkSamplingOptions());
        builder.child("uv_tex") = uv_image->makeShader(SkSamplingOptions());
        float widthRatio = viewWidth * 1.0f / width;
        float heightRatio = viewHeight * 1.0f / height;
        float ratio = std::min(widthRatio, heightRatio);
        builder.uniform("widthRatio") = ratio;
        builder.uniform("heightRatio") = ratio;
        sk_sp<SkShader> shader = builder.makeShader();
        SkPaint skPaint;
        skPaint.setShader(std::move(shader));
        canvas->save();
        if (widthRatio > heightRatio) {
            canvas->translate((viewWidth - width * ratio) / 2.0, 0);
        } else {
            canvas->translate(0, (viewHeight - height * ratio) / 2.0);
        }
        canvas->drawRect(SkRect::MakeXYWH(0, 0, width * ratio, height * ratio), skPaint);
        canvas->restore();
        
        if (paragraph != nullptr) {
            paragraph->layout(viewWidth);
            paragraph->paint(canvas, 0, 0);
        }
    }
}

void SimpleVideoTest::setTitle(const char *title) {
    ITestDraw::setTitle(title);
    skia::textlayout::ParagraphStyle paraStyle;
    auto paragraphBuilder = ParagraphBuilder::make(paraStyle, getContext()->getFontCollection());
    TextStyle textStyle;
    textStyle.setFontSize(100);
    textStyle.setColor(SK_ColorGREEN);
    textStyle.setFontFamilies({SkString("Alimama")});
    paragraphBuilder->pushStyle(textStyle);
    paragraphBuilder->addText(title);
    paragraph = paragraphBuilder->Build();
}

void SimpleVideoTest::setMp4() {
    int size = (int)mp4Files.size();
    if (index >= size) {
        index = 0;
    } else if (index < 0) {
        index = size - 1;
    }
    auto file = mp4Files[index].c_str();
    setSource(file);
    setTitle(file);
}

void SimpleVideoTest::playNext() {
    index++;
    setMp4();
}

void SimpleVideoTest::playPrevious() {
    index--;
    setMp4();
}

void SimpleVideoTest::pauseOrPlay() {
    if (videoDecoder == nullptr) {
        return;
    }
    if ([videoDecoder isPaused]) {
        [videoDecoder start];
    } else {
        [videoDecoder pause];
    }
}
