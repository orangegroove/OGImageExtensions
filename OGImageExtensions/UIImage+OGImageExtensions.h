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

#import <UIKit/UIKit.h>

@interface UIImage (OGImageExtensions)

/**
 
 @return
 */
- (BOOL)hasAlpha;

/**
 
 @return
 */
- (UIImage *)imageWithAlpha;

/**
 
 @return
 */
- (UIImage *)circularImage;

/**
 
 @param blurRadius
 @return
 */
- (UIImage *)blurredImageWithBlurRadius:(CGFloat)blurRadius;

/**
 
 @param image
 @return
 */
- (UIImage *)imageMaskedWithImage:(UIImage *)image;

/**
 
 @param image
 @param point
 @return
 */
- (UIImage *)imageByAddingImage:(UIImage *)image atPoint:(CGPoint)point;

/**
 
 @param rect
 @return
 */
- (UIImage *)imageCroppedAtRect:(CGRect)rect;

/**
 
 @param size
 @return
 */
- (UIImage *)imageCenterCroppedToSize:(CGSize)size;

/**
 
 @param size
 @return
 @note Does not preserve aspect ratio
 */
- (UIImage *)imageScaledToSize:(CGSize)size;

/**
 
 @param size
 @return
 @note Preserves aspect ratio
 */
- (UIImage *)imageAspectScaledToAtLeastSize:(CGSize)size;

/**
 
 @param size
 @return
 @note Preserves aspect ratio
 */
- (UIImage *)imageAspectScaledToAtMostSize:(CGSize)size;

/**
 
 @param width
 @return
 @note Preserves aspect ratio
 */
- (UIImage *)imageAspectScaledToAtLeastWidth:(CGFloat)width;

/**
 
 @param width
 @return
 @note Preserves aspect ratio
 */
- (UIImage *)imageAspectScaledToAtMostWidth:(CGFloat)width;

/**
 
 @param height
 @return
 @note Preserves aspect ratio
 */
- (UIImage *)imageAspectScaledToAtLeastHeight:(CGFloat)height;

/**
 
 @param height
 @return
 @note Preserves aspect ratio
 */
- (UIImage *)imageAspectScaledToAtMostHeight:(CGFloat)height;

@end
