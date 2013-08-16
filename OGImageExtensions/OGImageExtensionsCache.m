//
//  OGImageExtensionsCache.m
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

#import "OGImageExtensionsCache.h"
#import "UIImage+OGImageExtensions.h"

@interface OGImageExtensionsCache ()

@property (strong, nonatomic) NSMutableDictionary*	cache;

- (NSNumber *)keyForOwner:(id<OGImageExtensionsCacheOwnerDelegate>)owner;
- (NSString *)keyForSize:(CGSize)size flags:(uint64_t)flags;

@end
@implementation OGImageExtensionsCache

#pragma mark - Lifecycle

- (id)init
{
	if (self = [super init]) {
		
	}
	
	return self;
}

#pragma mark - Public

- (void)invalidateAllImages
{
	self.cache = nil;
}

- (void)invalidateImagesForOwner:(id<OGImageExtensionsCacheOwnerDelegate>)owner
{
	[self.cache removeObjectForKey:[self keyForOwner:owner]];
}

- (UIImage *)imageForOwner:(id<OGImageExtensionsCacheOwnerDelegate>)owner
{
	return [self imageForOwner:owner size:CGSizeZero flags:OGImageExtensionsCacheFlagOriginal];
}

- (UIImage *)imageForOwner:(id<OGImageExtensionsCacheOwnerDelegate>)owner size:(CGSize)size
{
	return [self imageForOwner:owner size:size flags:OGImageExtensionsCacheFlagOriginal];
}

- (UIImage *)imageForOwner:(id<OGImageExtensionsCacheOwnerDelegate>)owner size:(CGSize)size flags:(OGImageExtensionsCacheFlag)flags
{
	NSNumber* ownerKey						= [self keyForOwner:owner];
	NSString* imageKey						= [self keyForSize:size flags:flags];
	NSMutableDictionary* ownerDictionary	= self.cache[ownerKey];
	UIImage* image							= ownerDictionary[imageKey];
	
	if (!ownerDictionary) {
		
		ownerDictionary			= [NSMutableDictionary dictionary];
		self.cache[ownerKey]	= ownerDictionary;
	}
	
	if (!image) {
		
		UIImage* originalImage = [owner ogImageExtensionsOriginalImage];
		
		if (originalImage) {
			
			image = [originalImage imageAspectScaledToAtMostSize:size];
			
			if (flags & OGImageExtensionsCacheFlagCircular)
				image = [image circularImage];
			
			if (flags & OGImageExtensionsCacheFlagBlurred)
				image = [image blurredImageWithBlurRadius:4.f];
		}
	}
	
	return image;
}

#pragma mark - Private

- (NSNumber *)keyForOwner:(id<OGImageExtensionsCacheOwnerDelegate>)owner
{
	return @(owner.ogImageExtensionsIdentifier);
}

- (NSString *)keyForSize:(CGSize)size flags:(uint64_t)flags
{
	return [NSString stringWithFormat:@"%f%f%llu", size.width, size.height, flags];
}

#pragma mark - Properties

- (NSMutableDictionary *)cache
{
	if (_cache)
		return _cache;
	
	_cache = [NSMutableDictionary dictionary];
	
	return _cache;
}

@end
