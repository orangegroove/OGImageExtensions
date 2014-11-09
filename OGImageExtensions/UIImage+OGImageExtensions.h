//
//  UIImage+OGImageExtensions.h
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

#import "OGImageExtensionsCommon.h"

@interface UIImage (OGImageExtensions)

/**
 
 @return
 */
- (BOOL)og_hasAlpha;

/**
 
 @return
 */
- (UIImage *)og_imageWithAlpha;

/**
 
 @return
 */
- (UIImage *)og_circularImage;

/**
 
 @return
 */
- (UIImage *)og_grayscaleImage;

/**
 
 @param blurRadius
 @return
 */
- (UIImage *)og_blurredImageWithBlurRadius:(CGFloat)blurRadius;

/**
 
 @param image
 @return
 */
- (UIImage *)og_imageMaskedWithImage:(UIImage *)image;

/**
 
 @param image
 @param point
 @return
 */
- (UIImage *)og_imageByAddingImage:(UIImage *)image atPoint:(CGPoint)point;

/**
 
 @param rect
 @return
 */
- (UIImage *)og_imageCroppedAtRect:(CGRect)rect;

/**
 
 @param size
 @return
 */
- (UIImage *)og_imageCenterCroppedToSize:(CGSize)size;

/**
 
 @param size
 @return
 @note Does not preserve aspect ratio
 */
- (UIImage *)og_imageScaledToSize:(CGSize)size;

/**
 
 @param size
 @return
 @note Preserves aspect ratio
 */
- (UIImage *)og_imageAspectScaledToAtLeastSize:(CGSize)size;

/**
 
 @param size
 @return
 @note Preserves aspect ratio
 */
- (UIImage *)og_imageAspectScaledToAtMostSize:(CGSize)size;

/**
 
 @param width
 @return
 @note Preserves aspect ratio
 */
- (UIImage *)og_imageAspectScaledToAtLeastWidth:(CGFloat)width;

/**
 
 @param width
 @return
 @note Preserves aspect ratio
 */
- (UIImage *)og_imageAspectScaledToAtMostWidth:(CGFloat)width;

/**
 
 @param height
 @return
 @note Preserves aspect ratio
 */
- (UIImage *)og_imageAspectScaledToAtLeastHeight:(CGFloat)height;

/**
 
 @param height
 @return
 @note Preserves aspect ratio
 */
- (UIImage *)og_imageAspectScaledToAtMostHeight:(CGFloat)height;

/**
 
 @param modifier
 @param size
 @return
 */
- (UIImage *)og_imageWithModifier:(OGImageExtensionsImageModifier)modifier size:(CGSize)size;

@end
