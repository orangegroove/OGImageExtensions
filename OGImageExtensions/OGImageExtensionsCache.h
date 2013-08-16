//
//  OGImageExtensionsCache.h
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

//
//  An in-memory image cache that maps one image per object.
//  The intended use case is persisted images that need to be quickly vended.
//  Based on one source images, the cache can vend circular and blurred images.
//

#import <Foundation/Foundation.h>

/**
 The format in which to store the image.
 */
typedef NS_OPTIONS(uint64_t, OGImageExtensionsCacheFlag)
{
	OGImageExtensionsCacheFlagOriginal	= 0,		// An untouched image
	OGImageExtensionsCacheFlagCircular	= 1 << 0,	// A circular image
	OGImageExtensionsCacheFlagBlurred	= 1 << 1	// A blurred image
};

/**
 This protocol should be implemented by the image vendors, following the pattern that one owner has one image.
 */
@protocol OGImageExtensionsCacheOwnerDelegate <NSObject>

/**
 An identifier unique to this object or image.
 @return The identifier
 */
- (int64_t)ogImageExtensionsIdentifier;

/**
 The image from a store, e.g. a Core Data store.
 @return The image
 */
- (UIImage *)ogImageExtensionsOriginalImage;

@end
@interface OGImageExtensionsCache : NSObject

/**
 Clears the cache completely
 */
- (void)invalidateAllImages;

/**
 Clearls the cache for a specific owner.
 @param owner The owning object
 */
- (void)invalidateImagesForOwner:(id<OGImageExtensionsCacheOwnerDelegate>)owner;

/**
 Returns the original image.
 @param owner The owning object
 @return An image or nil if not available
 */
- (UIImage *)imageForOwner:(id<OGImageExtensionsCacheOwnerDelegate>)owner;

/**
 Returns an image of at most the specified size.
 @param owner The owning object
 @param size The wanted size or CGSizeZero for the original image
 @return An image or nil if not available
 */
- (UIImage *)imageForOwner:(id<OGImageExtensionsCacheOwnerDelegate>)owner size:(CGSize)size;

/**
 Returns an image of at most the specified size with the specified flags.
 @param owner The owning object
 @param size The wanted size or CGSizeZero for the original image
 @param flags See OGImageExtensionsCacheFlag for details
 @return An image or nil if not available
 */
- (UIImage *)imageForOwner:(id<OGImageExtensionsCacheOwnerDelegate>)owner size:(CGSize)size flags:(OGImageExtensionsCacheFlag)flags;

@end
