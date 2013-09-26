//
//  OGImageExtensionsPersistor.m
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

#import "OGImageExtensionsPersistor.h"
#import "UIImage+OGImageExtensions.h"

@interface OGImageExtensionsPersistor ()

@property (strong, nonatomic) NSString*	baseDirectory;

- (NSArray *)existingKeys;

- (NSString *)pathForKey:(NSString *)key;
- (NSString *)pathForKey:(NSString *)key modifier:(OGImageExtensionsImageModifier)modifier size:(CGSize)size;

- (NSDate *)creationDateForKey:(NSString *)key;
- (NSDate *)lastAccessDateForKey:(NSString *)key;


@end
@implementation OGImageExtensionsPersistor

#pragma mark - Lifecycle

- (id)init
{
	return nil;
}

- (id)initWithNamespace:(NSString *)namespace type:(OGImageExtensionsPersistorType)type
{
	if (!namespace.length)
		return nil;
	
	if (self = [super init]) {
		
		_namespace		= [namespace copy];
		_type			= type;
		
		switch (type) {
			case OGImageExtensionsPersistorTypeTemporary: // Library/Caches, delete automatically later
			case OGImageExtensionsPersistorTypeReloadable: // Library/Caches
				
				_baseDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
				break;
				
			case OGImageExtensionsPersistorTypeBackedUp: // Documents
			case OGImageExtensionsPersistorTypeUserGenerated: // Documents, with do not back attribute
				
				_baseDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
				break;
		}
		
		if (!namespace.length)
			namespace = @"nonamespace/";
		
		if (![namespace hasSuffix:@"/"])
			namespace = [namespace stringByAppendingString:@"/"];
		
		_baseDirectory = [_baseDirectory stringByAppendingFormat:@"/OGImageExtensionsPersistor/%@", namespace];
	}
	
	return self;
}

- (void)dealloc
{
	if (self.type == OGImageExtensionsPersistorTypeTemporary)
		[self removeAllImages];
}

#pragma mark - Public

- (BOOL)persistImage:(UIImage *)image forKey:(NSString *)key
{
	return [self persistImage:image forKey:key modifier:OGImageExtensionsImageModifierNone size:CGSizeZero];
}

- (BOOL)persistImage:(UIImage *)image forKey:(NSString *)key modifier:(OGImageExtensionsImageModifier)modifier size:(CGSize)size
{
	NSFileManager* fm	= [NSFileManager defaultManager];
	NSString* path		= [self pathForKey:key modifier:modifier size:size];
	NSData* data		= UIImagePNGRepresentation(image);
	NSError* error		= nil;
	
	if (![fm createDirectoryAtPath:[self pathForKey:key] withIntermediateDirectories:YES attributes:nil error:&error]) {
#ifdef DEBUG
		OGImageExtensionsLog(@"Error creating directory for key %@ at %@: %@", key, [self pathForKey:key], error);
#endif
		return NO;
	}
	else if (![fm createFileAtPath:path contents:data attributes:@{NSFileCreationDate: [NSDate date]}]) {
#ifdef DEBUG
		OGImageExtensionsLog(@"Error creating file for key %@ at %@: %@", key, path, error);
#endif
		return NO;
	}
	
	if (self.type == OGImageExtensionsPersistorTypeUserGenerated) {
		
		NSError* error	= nil;
		BOOL success	= [[NSURL fileURLWithPath:path] setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
		
		if (!success) {
#ifdef DEBUG
			OGImageExtensionsLog(@"Error setting attribute: %@", error);
#endif
			return NO;
		}
	}
	
	return YES;
}

- (UIImage *)imageForKey:(NSString *)key
{
	return [self imageForKey:key modifier:OGImageExtensionsImageModifierNone size:CGSizeZero scale:[UIScreen mainScreen].scale];
}

- (UIImage *)imageForKey:(NSString *)key modifier:(OGImageExtensionsImageModifier)modifier size:(CGSize)size scale:(CGFloat)scale
{
	NSFileManager* fm	= [NSFileManager defaultManager];
	NSData* data		= [fm contentsAtPath:[self pathForKey:key modifier:modifier size:size]];
	
	if (data)
		return [UIImage imageWithData:data scale:scale];
	
	data = [fm contentsAtPath:[self pathForKey:key modifier:OGImageExtensionsImageModifierNone size:CGSizeZero]];
	
	if (data) {
		
		UIImage* image = [[UIImage imageWithData:data scale:scale] imageWithModifier:modifier size:size];
		
		[self persistImage:image forKey:key modifier:modifier size:size];
		
		return image;
	}
	
	return nil;
}

- (void)removeImagesForKey:(NSString *)key
{
	NSError* error	= nil;
	BOOL success	= [[NSFileManager defaultManager] removeItemAtPath:[self pathForKey:key] error:&error];
	
#ifdef DEBUG
	if (!success)
		OGImageExtensionsLog(@"Error removing images for key %@ at %@: %@", key, [self pathForKey:key], error);
#endif
}

- (void)removeAllImages
{
	NSError* error	= nil;
	BOOL success	= [[NSFileManager defaultManager] removeItemAtPath:self.baseDirectory error:nil];
	
#ifdef DEBUG
	if (!success)
		OGImageExtensionsLog(@"Error removing images at %@: %@", self.baseDirectory, error);
#endif
}

- (void)removeImagesCreatedEarlierThan:(NSDate *)date
{
	if (!date)
		return;
	
	NSArray* keys = [self existingKeys];
	
	for (NSString* key in keys)
		if ([date laterDate:[self creationDateForKey:key]] == date)
			[self removeImagesForKey:key];
}

- (void)removeImagesAccessedEarlierThan:(NSDate *)date
{
	if (!date)
		return;
	
	NSArray* keys = [self existingKeys];
	
	for (NSString* key in keys)
		if ([date laterDate:[self lastAccessDateForKey:key]] == date)
			[self removeImagesForKey:key];
}

#pragma mark - Private

- (NSArray *)existingKeys
{
	NSMutableArray* keys	= [NSMutableArray array];
	NSError* error			= nil;
	NSArray* paths			= [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.baseDirectory error:&error];
	
	if (!paths) {
#ifdef DEBUG
		OGImageExtensionsLog(@"Error retrieving paths: %@", error);
#endif
		return nil;
	}
	
	for (NSString* path in paths) {
		
		NSString* key = path;
		
		if ([key hasSuffix:@"/"])
			key = [key stringByReplacingCharactersInRange:NSMakeRange(key.length-1, 1) withString:@""];
		
		[keys addObject:[key substringFromIndex:[key rangeOfString:@"/" options:NSBackwardsSearch].location]];
	}
	
	return [NSArray arrayWithArray:keys];
}

- (NSString *)pathForKey:(NSString *)key
{
	return [self.baseDirectory stringByAppendingFormat:@"%@", key];
}

- (NSString *)pathForKey:(NSString *)key modifier:(OGImageExtensionsImageModifier)modifier size:(CGSize)size
{
	return [self.baseDirectory stringByAppendingFormat:@"%@/%llu%0.f%0.f", key, modifier, size.width, size.height];
}

- (NSDate *)creationDateForKey:(NSString *)key
{
	NSError* error				= nil;
	NSString* path				= [self pathForKey:key modifier:OGImageExtensionsImageModifierNone size:CGSizeZero];
	NSDictionary* attributes	= [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
	
	if (attributes)
		return attributes[NSFileCreationDate];
#ifdef DEBUG
	else
		OGImageExtensionsLog(@"Error retrieving creation date for key %@ at %@: %@", key, path, error);
#endif
	
	return nil;
}

- (NSDate *)lastAccessDateForKey:(NSString *)key
{
	NSDate* lastDate	= nil;
	NSError* error		= nil;
	NSString* path		= [self pathForKey:key];
	NSArray* files		= [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
	
	if (files.count)
		for (NSString* filePath in files) {
			
			NSError* fileError	= nil;
			NSDate* date		= nil;
			NSURL* url			= [NSURL fileURLWithPath:filePath];
			
			if (![url getResourceValue:&date forKey:NSURLContentAccessDateKey error:&fileError]) {
#ifdef DEBUG
				OGImageExtensionsLog(@"Error retrieving access date for key %@ at %@: %@", key, path, error);
#endif
			}
			else if (date)
				lastDate = [date laterDate:lastDate];
		}
#ifdef DEBUG
	else if (!files)
		OGImageExtensionsLog(@"Error retrieving contents of directory for key %@ at %@: %@", key, path, error);
#endif
	
	return lastDate;
}

@end
