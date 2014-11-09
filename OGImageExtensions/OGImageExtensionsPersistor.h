//
//  OGImageExtensionsPersistor.h
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

// namespace and keys can't contain slashes

#import "OGImageExtensionsCommon.h"

typedef NS_ENUM(int8_t, OGImageExtensionsPersistorType)
{
	OGImageExtensionsPersistorTypeTemporary,		 // Will be removed when the persistor is deallocated
	OGImageExtensionsPersistorTypeReloadable,	 // Can be removed by the system when needed
	OGImageExtensionsPersistorTypeUserGenerated, // Never removed by system
	OGImageExtensionsPersistorTypeBackedUp		 // Never removed by system, and is backed up to iCloud
};

@interface OGImageExtensionsPersistor : NSObject

@property (copy, nonatomic, readonly)	NSString*						namespace;
@property (assign, nonatomic, readonly)	OGImageExtensionsPersistorType	type;

- (id)initWithNamespace:(NSString *)namespace type:(OGImageExtensionsPersistorType)type;

- (BOOL)persistImage:(UIImage *)image forKey:(NSString *)key;
- (BOOL)persistImage:(UIImage *)image forKey:(NSString *)key modifier:(OGImageExtensionsImageModifier)modifier size:(CGSize)size;

- (UIImage *)imageForKey:(NSString *)key;
- (UIImage *)imageForKey:(NSString *)key modifier:(OGImageExtensionsImageModifier)modifier size:(CGSize)size scale:(CGFloat)scale;

- (void)removeImagesForKey:(NSString *)key;
- (void)removeAllImages;

- (void)removeImagesCreatedEarlierThan:(NSDate *)date;
- (void)removeImagesAccessedEarlierThan:(NSDate *)date;

- (NSString *)filePathForKey:(NSString *)key modifier:(OGImageExtensionsImageModifier)modifier size:(CGSize)size;

@end
