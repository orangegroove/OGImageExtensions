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

#import <CoreImage/CoreImage.h>
#import "UIImage+OGImageExtensions.h"

@interface UIImage (OrangeExtensionsPrivate)

- (CGAffineTransform)transformForSize:(CGSize)size;
- (BOOL)transpose;

@end
@implementation UIImage (OrangeExtensions)

#pragma mark - Public

- (BOOL)hasAlpha
{
	CGImageAlphaInfo alpha = CGImageGetAlphaInfo(self.CGImage);
	
	switch (alpha) {
		case kCGImageAlphaFirst:
		case kCGImageAlphaLast:
		case kCGImageAlphaPremultipliedFirst:
		case kCGImageAlphaPremultipliedLast:
			return YES;
		default:
			return NO;
	}
}

- (UIImage *)imageWithAlpha
{
	if (self.hasAlpha)
		return self;
	
	CGImageRef imageRef	= self.CGImage;
	CGSize size			= self.size;
	CGContextRef ctx	= CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, CGImageGetColorSpace(imageRef), kCGBitmapByteOrderDefault|kCGImageAlphaPremultipliedFirst);
	
	CGContextDrawImage(ctx, (CGRect){0.f, 0.f, size}, imageRef);
	
	CGImageRef alphaImageRef	= CGBitmapContextCreateImage(ctx);
	UIImage* alphaImage			= [UIImage imageWithCGImage:alphaImageRef];
	
	CGContextRelease(ctx);
	CGImageRelease	(alphaImageRef);
	
	return alphaImage;
}

- (UIImage *)circularImage
{
	CGImageRef cgImage	= [self imageWithAlpha].CGImage;
	CGSize size			= self.size;
	CGRect rect			= {0.f, 0.f, size.width, size.width};
	CGPoint center		= CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
	CGFloat radius		= CGRectGetWidth(rect) / 2;
    CGContextRef ctx	= CGBitmapContextCreate(NULL, CGRectGetWidth(rect), CGRectGetWidth(rect), CGImageGetBitsPerComponent(cgImage), 0, CGImageGetColorSpace(cgImage), CGImageGetBitmapInfo(cgImage));
	
    CGContextSaveGState		(ctx);
    CGContextBeginPath		(ctx);
	CGContextMoveToPoint	(ctx, CGRectGetWidth(rect), radius);
	CGContextAddArc			(ctx, center.x, center.y, radius, 0.f, (CGFloat)(M_PI * 2), 0);
    CGContextClosePath		(ctx);
    CGContextRestoreGState	(ctx);
    CGContextClip			(ctx);
    CGContextDrawImage		(ctx, rect, cgImage);
	
    cgImage					= CGBitmapContextCreateImage(ctx);
    UIImage* roundedImage	= [UIImage imageWithCGImage:cgImage scale:self.scale orientation:self.imageOrientation];
	
    CGContextRelease(ctx);
    CGImageRelease	(cgImage);
	
    return roundedImage;
}

- (UIImage *)blurredImageWithBlurRadius:(CGFloat)blurRadius
{
    CIContext* context		= [CIContext contextWithOptions:nil];
    CIImage* sourceImage	= [CIImage imageWithCGImage:[self imageWithAlpha].CGImage];
    CIFilter* clamp			= [CIFilter filterWithName:@"CIAffineClamp"];
    CIFilter* gaussianBlur	= [CIFilter filterWithName:@"CIGaussianBlur"];
    
    if (!clamp || !gaussianBlur)
		return self;
	
    [clamp			setValue:sourceImage							forKey:kCIInputImageKey];
    [gaussianBlur	setValue:[clamp valueForKey:kCIOutputImageKey]	forKey:kCIInputImageKey];
    [gaussianBlur	setValue:@(blurRadius)							forKey:kCIInputRadiusKey];
    
    CIImage* blurredOutput	= [gaussianBlur valueForKey:kCIOutputImageKey];
	CGImageRef cgImage		= [context createCGImage:blurredOutput fromRect:sourceImage.extent];
	UIImage* blurredImage	= [UIImage imageWithCGImage:cgImage];
	
	CGImageRelease(cgImage);
	return blurredImage;
}

- (UIImage *)imageMaskedWithImage:(UIImage *)image
{
	CGImageRef imageRef			= image.CGImage;
	CGSize size					= image.size;
	CGImageRef maskRef			=  CGImageMaskCreate(size.width, size.height, CGImageGetBitsPerComponent(imageRef), CGImageGetBitsPerPixel(imageRef), CGImageGetBytesPerRow(imageRef), CGImageGetDataProvider(imageRef), NULL, false);
	CGImageRef maskedImageRef	= CGImageCreateWithMask(self.CGImage, maskRef);
	UIImage* maskedImage		= [UIImage imageWithCGImage:maskedImageRef];
	
	CGImageRelease(maskRef);
	CGImageRelease(maskedImageRef);
	
    return maskedImage;
}

- (UIImage *)imageByAddingImage:(UIImage *)image atPoint:(CGPoint)point
{
	UIGraphicsBeginImageContextWithOptions(self.size, NO, image.scale);
	
	[self drawInRect:(CGRect){0.f, 0.f, self.size}];
	[image drawAtPoint:point];
	
	UIImage* mergedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return mergedImage;
}

- (UIImage *)imageCroppedAtRect:(CGRect)rect
{
	CGImageRef imageRef	= CGImageCreateWithImageInRect(self.CGImage, rect);
	UIImage* image		= [UIImage imageWithCGImage:imageRef];
	
	CGImageRelease(imageRef);
	return image;
}

- (UIImage *)imageCenterCroppedToSize:(CGSize)size
{
	CGSize currentSize = self.size;
	
	if (size.width >= currentSize.width && size.height >= currentSize.height)
		return self;
	
	CGFloat x = MAX((currentSize.width - size.width) / 2, 0.f);
	CGFloat y = MAX((currentSize.height - size.height) / 2, 0.f);
	
	return [self imageCroppedAtRect:(CGRect){x, y, size}];
}

- (UIImage *)imageScaledToSize:(CGSize)size
{
	CGFloat scale				= self.scale;
	CGAffineTransform transform	= [self transformForSize:size];
	CGRect rect					= CGRectIntegral(self.transpose ? (CGRect){0.f, 0.f, size.height, size.width} : (CGRect){0.f, 0.f, size});
	CGImageRef imageRef			= [self imageWithAlpha].CGImage;
	CGContextRef ctx			= CGBitmapContextCreate(NULL, (size_t)(size.width * scale), (size_t)(size.height * scale), CGImageGetBitsPerComponent(imageRef), 0, CGImageGetColorSpace(imageRef), CGImageGetBitmapInfo(imageRef));
	
	CGContextConcatCTM				(ctx, transform);
	CGContextScaleCTM				(ctx, scale, scale);
	CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
	CGContextDrawImage				(ctx, rect, imageRef);
	
	CGImageRef scaledImageRef	= CGBitmapContextCreateImage(ctx);
	UIImage* scaledImage		= [UIImage imageWithCGImage:scaledImageRef scale:scale orientation:self.imageOrientation];
	
	CGContextRelease(ctx);
	CGImageRelease	(scaledImageRef);
	
	return scaledImage;
}

- (UIImage *)imageAspectScaledToAtLeastSize:(CGSize)size
{
	CGSize currentSize = self.size;
	
	if (currentSize.width >= size.width && currentSize.height >= size.height)
		return self;
	
	CGFloat widthScale	= currentSize.width / size.width;
	CGFloat heightScale	= currentSize.height / size.height;
	CGSize widthSize	= {currentSize.width / widthScale, currentSize.height / widthScale};
	CGSize heightSize	= {currentSize.width / heightScale, currentSize.height / heightScale};
	
	if (widthSize.height < heightSize.height && widthSize.height >= size.height)
		return [self imageScaledToSize:widthSize];
	
	return [self imageScaledToSize:heightSize];
}

- (UIImage *)imageAspectScaledToAtMostSize:(CGSize)size
{
	CGSize currentSize = self.size;
	
	if (size.width >= currentSize.width && size.height >= currentSize.height)
		return self;
	
	CGFloat widthScale	= currentSize.width / size.width;
	CGFloat heightScale	= currentSize.height / size.height;
	CGSize widthSize	= {currentSize.width / widthScale, currentSize.height / widthScale};
	CGSize heightSize	= {currentSize.width / heightScale, currentSize.height / heightScale};
	
	if (widthSize.height > heightSize.height && size.height >= widthSize.height)
		return [self imageScaledToSize:widthSize];
	
	return [self imageScaledToSize:heightSize];
}

- (UIImage *)imageAspectScaledToAtLeastWidth:(CGFloat)width
{
	CGSize size = self.size;
	
	if (size.width >= width)
		return self;
	
	CGFloat scale	= size.width / width;
	CGSize newSize	= {size.width / scale, size.height / scale};
	
	return [self imageScaledToSize:newSize];
}

- (UIImage *)imageAspectScaledToAtMostWidth:(CGFloat)width
{
	CGSize size = self.size;
	
	if (width >= size.width)
		return self;
	
	CGFloat scale	= size.width / width;
	CGSize newSize	= {size.width / scale, size.height / scale};
	
	return [self imageScaledToSize:newSize];
}

- (UIImage *)imageAspectScaledToAtLeastHeight:(CGFloat)height
{
	CGSize size = self.size;
	
	if (size.height >= height)
		return self;
	
	CGFloat scale	= size.height / height;
	CGSize newSize	= {size.width / scale, size.height / scale};
	
	return [self imageScaledToSize:newSize];
}

- (UIImage *)imageAspectScaledToAtMostHeight:(CGFloat)height
{
	CGSize size = self.size;
	
	if (height >= size.height)
		return self;
	
	CGFloat scale	= size.height / height;
	CGSize newSize	= {size.width / scale, size.height / scale};
	
	return [self imageScaledToSize:newSize];
}

#pragma mark - Helpers

- (CGAffineTransform)transformForSize:(CGSize)size
{
	CGAffineTransform transform = CGAffineTransformIdentity;
	
	switch (self.imageOrientation) {
			
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
	
	switch (self.imageOrientation) {
			
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

- (BOOL)transpose
{
	switch (self.imageOrientation) {
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
