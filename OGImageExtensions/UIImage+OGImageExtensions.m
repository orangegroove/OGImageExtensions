//
//  UIImage+OGImageExtensions.m
//
//  Created by Jesper <jesper@orangegroove.net>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

@import CoreImage;
#import "UIImage+OGImageExtensions.h"
#import "OGImageExtensions.h"

@interface UIImage (OrangeExtensionsPrivate)

- (CGAffineTransform)og_transformForSize:(CGSize)size;
- (BOOL)og_transpose;

@end
@implementation UIImage (OrangeExtensions)

#pragma mark - Public

- (UIImage *)og_imageWithModifier:(OGImageExtensionsImageModifier)modifier size:(CGSize)size
{
	UIImage* image = self;
	
	if (!CGSizeEqualToSize(size, CGSizeZero) && !CGSizeEqualToSize(size, image.size))
    {
        image = [image og_imageAspectScaledToAtMostSize:size];
    }
	
	if (modifier & OGImageExtensionsImageModifierCircular)
    {
        image = [image og_circularImage];
    }
	
	if (modifier & OGImageExtensionsImageModifierGrayscale)
    {
        image = [image og_grayscaleImage];
    }
	
	if (modifier & OGImageExtensionsImageModifierBlurred)
    {
        image = [image og_blurredImageWithBlurRadius:4.f];
    }
	
	return image;
}

- (BOOL)og_hasAlpha
{
	CGImageAlphaInfo alpha = CGImageGetAlphaInfo(self.CGImage);
	
	switch (alpha)
    {
		case kCGImageAlphaFirst:
		case kCGImageAlphaLast:
		case kCGImageAlphaPremultipliedFirst:
		case kCGImageAlphaPremultipliedLast:
			return YES;
		default:
			return NO;
	}
}

- (UIImage *)og_imageWithAlpha
{
	if (self.og_hasAlpha) return self;
	
    CGFloat scale       = self.scale;
    CGImageRef imageRef = self.CGImage;
    CGSize size         = self.size;
    CGContextRef ctx    = CGBitmapContextCreate(NULL, size.width * scale, size.height * scale, 8, 0, CGImageGetColorSpace(imageRef), kCGBitmapByteOrderDefault|kCGImageAlphaPremultipliedFirst);
	
	CGContextDrawImage(ctx, (CGRect){0.f, 0.f, size}, imageRef);
	
    CGImageRef alphaImageRef = CGBitmapContextCreateImage(ctx);
    UIImage* alphaImage      = [UIImage imageWithCGImage:alphaImageRef scale:scale orientation:self.imageOrientation];
	
	CGContextRelease(ctx);
	CGImageRelease	(alphaImageRef);
	
	return alphaImage;
}

- (UIImage *)og_circularImage
{
    CGImageRef cgImage = [self og_imageWithAlpha].CGImage;
    CGFloat scale      = self.scale;
    CGRect rect        = {0.f, 0.f, self.size.width * scale, self.size.width * scale};
    CGPoint center     = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGFloat radius     = CGRectGetWidth(rect) / 2;
    CGContextRef ctx   = CGBitmapContextCreate(NULL, CGRectGetWidth(rect), CGRectGetWidth(rect), CGImageGetBitsPerComponent(cgImage), 0, CGImageGetColorSpace(cgImage), CGImageGetBitmapInfo(cgImage));
	
    CGContextSaveGState	  (ctx);
    CGContextBeginPath	  (ctx);
	CGContextMoveToPoint  (ctx, CGRectGetWidth(rect), radius);
	CGContextAddArc		  (ctx, center.x, center.y, radius, 0.f, (CGFloat)(M_PI * 2), 0);
    CGContextClosePath	  (ctx);
    CGContextRestoreGState(ctx);
    CGContextClip		  (ctx);
    CGContextDrawImage	  (ctx, rect, cgImage);
	
    cgImage               = CGBitmapContextCreateImage(ctx);
    UIImage* roundedImage = [UIImage imageWithCGImage:cgImage scale:scale orientation:self.imageOrientation];
	
    CGContextRelease(ctx);
    CGImageRelease	(cgImage);
	
    return roundedImage;
}

- (UIImage *)og_grayscaleImage
{
    static uint8_t kRed        = 1;
    static uint8_t kGreen      = 2;
    static uint8_t kBlue       = 3;
    CGRect rect                = {0.f, 0.f, self.size.width * self.scale, self.size.height * self.scale};
    size_t width               = (size_t)CGRectGetWidth(rect);
    size_t height              = (size_t)CGRectGetHeight(rect);
    size_t size                = width * height * sizeof(uint32_t);
    uint32_t* buffer           = (uint32_t *)malloc(size);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	memset(buffer, 0, size);
	
	CGContextRef ctx = CGBitmapContextCreate(buffer, width, height, 8, width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little|kCGImageAlphaPremultipliedLast);
	
	CGContextDrawImage(ctx, CGRectMake(0.f, 0.f, width, height), self.CGImage);
	
	for (size_t y = 0; y < height; y++)
		for (size_t x = 0; x < width; x++) {
			
            uint8_t* pixel = (uint8_t *)&buffer[y * width + x];
            uint8_t gray   = (uint8_t)((30 * pixel[kRed] + 59 * pixel[kGreen] + 11 * pixel[kBlue]) / 100);

            pixel[kRed]    = gray;
            pixel[kGreen]  = gray;
            pixel[kBlue]   = gray;
		}
	
	CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
	UIImage* image		= [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
	
	CGContextRelease   (ctx);
	CGColorSpaceRelease(colorSpace);
	free			   (buffer);
	CGImageRelease	   (imageRef);
	
	return image;
}

- (UIImage *)og_blurredImageWithBlurRadius:(CGFloat)blurRadius
{
    CIContext* context     = [CIContext contextWithOptions:nil];
    CIImage* sourceImage   = [CIImage imageWithCGImage:[self og_imageWithAlpha].CGImage];
    CIFilter* clamp        = [CIFilter filterWithName:@"CIAffineClamp"];
    CIFilter* gaussianBlur = [CIFilter filterWithName:@"CIGaussianBlur"];
    
    if (!clamp || !gaussianBlur) return self;
	
    [clamp		  setValue:sourceImage							 forKey:kCIInputImageKey];
    [gaussianBlur setValue:[clamp valueForKey:kCIOutputImageKey] forKey:kCIInputImageKey];
    [gaussianBlur setValue:@(blurRadius)							 forKey:kCIInputRadiusKey];
    
    CIImage* blurredOutput = [gaussianBlur valueForKey:kCIOutputImageKey];
    CGImageRef cgImage     = [context createCGImage:blurredOutput fromRect:sourceImage.extent];
    UIImage* blurredImage  = [UIImage imageWithCGImage:cgImage scale:self.scale orientation:self.imageOrientation];
	
	CGImageRelease(cgImage);
	return blurredImage;
}

- (UIImage *)og_imageMaskedWithImage:(UIImage *)image
{
    CGFloat scale             = self.scale;
    CGImageRef imageRef       = image.CGImage;
    CGSize size               = image.size;
    CGImageRef maskRef        = CGImageMaskCreate(size.width * scale, size.height * scale, CGImageGetBitsPerComponent(imageRef), CGImageGetBitsPerPixel(imageRef), CGImageGetBytesPerRow(imageRef), CGImageGetDataProvider(imageRef), NULL, false);
    CGImageRef maskedImageRef = CGImageCreateWithMask(self.CGImage, maskRef);
    UIImage* maskedImage      = [UIImage imageWithCGImage:maskedImageRef scale:scale orientation:self.imageOrientation];
	
	CGImageRelease(maskRef);
	CGImageRelease(maskedImageRef);
	
    return maskedImage;
}

- (UIImage *)og_imageByAddingImage:(UIImage *)image atPoint:(CGPoint)point
{
	UIGraphicsBeginImageContextWithOptions(self.size, NO, image.scale);
	
	[self drawInRect:(CGRect){0.f, 0.f, self.size}];
	[image drawAtPoint:point];
	
	UIImage* mergedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return mergedImage;
}

- (UIImage *)og_imageCroppedAtRect:(CGRect)rect
{
	CGFloat scale		= self.scale;
	rect.size.width	   *= scale;
	rect.size.height   *= scale;
	CGImageRef imageRef	= CGImageCreateWithImageInRect(self.CGImage, rect);
	UIImage* image		= [UIImage imageWithCGImage:imageRef scale:scale orientation:self.imageOrientation];
	
	CGImageRelease(imageRef);
	return image;
}

- (UIImage *)og_imageCenterCroppedToSize:(CGSize)size
{
	CGSize currentSize = self.size;
	
	if (size.width >= currentSize.width && size.height >= currentSize.height)
		return self;
	
	CGFloat x = MAX((currentSize.width - size.width) / 2, 0.f);
	CGFloat y = MAX((currentSize.height - size.height) / 2, 0.f);
	
	return [self og_imageCroppedAtRect:(CGRect){x, y, size}];
}

- (UIImage *)og_imageScaledToSize:(CGSize)size
{
	CGFloat scale				= self.scale;
	CGAffineTransform transform	= [self og_transformForSize:size];
	CGRect rect					= CGRectIntegral(self.og_transpose ? (CGRect){0.f, 0.f, size.height, size.width} : (CGRect){0.f, 0.f, size});
	CGImageRef imageRef			= [self og_imageWithAlpha].CGImage;
	CGContextRef ctx			= CGBitmapContextCreate(NULL, (size_t)(size.width * scale), (size_t)(size.height * scale), CGImageGetBitsPerComponent(imageRef), 0, CGImageGetColorSpace(imageRef), CGImageGetBitmapInfo(imageRef));
	
	CGContextConcatCTM				(ctx, transform);
	CGContextScaleCTM				(ctx, scale, scale);
	CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
	CGContextDrawImage				(ctx, rect, imageRef);
	
    CGImageRef scaledImageRef = CGBitmapContextCreateImage(ctx);
    UIImage* scaledImage      = [UIImage imageWithCGImage:scaledImageRef scale:scale orientation:self.imageOrientation];
	
	CGContextRelease(ctx);
	CGImageRelease	(scaledImageRef);
	
	return scaledImage;
}

- (UIImage *)og_imageAspectScaledToAtLeastSize:(CGSize)size
{
	CGSize currentSize = self.size;
	
	if (currentSize.width >= size.width && currentSize.height >= size.height) return self;
	
	CGFloat widthScale	= currentSize.width / size.width;
	CGFloat heightScale	= currentSize.height / size.height;
	CGSize widthSize	= {currentSize.width / widthScale, currentSize.height / widthScale};
	CGSize heightSize	= {currentSize.width / heightScale, currentSize.height / heightScale};
	
	if (widthSize.height < heightSize.height && widthSize.height >= size.height)
    {
        return [self og_imageScaledToSize:widthSize];
    }
	
	return [self og_imageScaledToSize:heightSize];
}

- (UIImage *)og_imageAspectScaledToAtMostSize:(CGSize)size
{
	CGSize currentSize = self.size;
	
	if (size.width >= currentSize.width && size.height >= currentSize.height) return self;
	
	CGFloat widthScale	= currentSize.width / size.width;
	CGFloat heightScale	= currentSize.height / size.height;
	CGSize widthSize	= {currentSize.width / widthScale, currentSize.height / widthScale};
	CGSize heightSize	= {currentSize.width / heightScale, currentSize.height / heightScale};
	
	if (widthSize.height > heightSize.height && size.height >= widthSize.height)
    {
        return [self og_imageScaledToSize:widthSize];
    }
	
	return [self og_imageScaledToSize:heightSize];
}

- (UIImage *)og_imageAspectScaledToAtLeastWidth:(CGFloat)width
{
	CGSize size = self.size;
	
	if (size.width >= width) return self;
	
    CGFloat scale  = size.width / width;
    CGSize newSize = {size.width / scale, size.height / scale};
	
	return [self og_imageScaledToSize:newSize];
}

- (UIImage *)og_imageAspectScaledToAtMostWidth:(CGFloat)width
{
	CGSize size = self.size;
	
	if (width >= size.width) return self;
	
    CGFloat scale  = size.width / width;
    CGSize newSize = {size.width / scale, size.height / scale};
	
	return [self og_imageScaledToSize:newSize];
}

- (UIImage *)og_imageAspectScaledToAtLeastHeight:(CGFloat)height
{
	CGSize size = self.size;
	
	if (size.height >= height) return self;
	
    CGFloat scale  = size.height / height;
    CGSize newSize = {size.width / scale, size.height / scale};
	
	return [self og_imageScaledToSize:newSize];
}

- (UIImage *)og_imageAspectScaledToAtMostHeight:(CGFloat)height
{
	CGSize size = self.size;
	
	if (height >= size.height) return self;
	
    CGFloat scale  = size.height / height;
    CGSize newSize = {size.width / scale, size.height / scale};
	
	return [self og_imageScaledToSize:newSize];
}

#pragma mark - Helpers

- (CGAffineTransform)og_transformForSize:(CGSize)size
{
	CGAffineTransform transform = CGAffineTransformIdentity;
	
	switch (self.imageOrientation)
    {
		case UIImageOrientationDown:
		case UIImageOrientationDownMirrored:
			
			transform = CGAffineTransformTranslate(transform, size.width, size.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationLeft:
		case UIImageOrientationLeftMirrored:
			
			transform = CGAffineTransformTranslate(transform, size.width, 0.f);
			transform = CGAffineTransformRotate(transform, M_PI_2);
			break;
			
		case UIImageOrientationRight:
		case UIImageOrientationRightMirrored:
			
			transform = CGAffineTransformTranslate(transform, 0.f, size.height);
			transform = CGAffineTransformRotate(transform, -M_PI_2);
			break;
			
		default:
			break;
	}
	
	switch (self.imageOrientation)
    {
		case UIImageOrientationUpMirrored:
		case UIImageOrientationDownMirrored:
			
			transform = CGAffineTransformTranslate(transform, size.width, 0.f);
			transform = CGAffineTransformScale(transform, -1.f, 1.f);
			break;
			
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRightMirrored:
			
			transform = CGAffineTransformTranslate(transform, size.height, 0.f);
			transform = CGAffineTransformScale(transform, -1.f, 1.f);
			break;
			
		default:
			break;
	}
	
	return transform;
}

- (BOOL)og_transpose
{
	switch (self.imageOrientation)
    {
		case UIImageOrientationLeft:
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRight:
		case UIImageOrientationRightMirrored:
			return YES;
		default:
			return NO;
	}
}

@end
