//
//  NSData+OGImageExtensions.h
//  OGImageExtensionsProject
//
//  Created by Jesper on 02/01/14.
//  Copyright (c) 2014 Orange Groove. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, OGImageExtensionsImageType)
{
	OGImageExtensionsImageTypeUnknown,
	OGImageExtensionsImageTypePNG,
	OGImageExtensionsImageTypeJPEG,
	OGImageExtensionsImageTypeTIFF,
	OGImageExtensionsImageTypeBMP,
	OGImageExtensionsImageTypeGIF
};

@interface NSData (OGImageExtensions)

/**
 
 Original code by https://github.com/NSProgrammer
 */
- (OGImageExtensionsImageType)typeOfImageData;

@end
