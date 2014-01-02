//
//  NSData+OGImageExtensions.m
//  OGImageExtensionsProject
//
//  Created by Jesper on 02/01/14.
//  Copyright (c) 2014 Orange Groove. All rights reserved.
//

#import "NSData+OGImageExtensions.h"

@implementation NSData (OGImageExtensions)

- (OGImageExtensionsImageType)typeOfImageData
{
	if (self.length < 4)
		return OGImageExtensionsImageTypeUnknown;
	
	const unsigned char* bytes = self.bytes;
	
	if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4e && bytes[3] == 0x47)
		return OGImageExtensionsImageTypePNG;
	
	if (bytes[0] == 0xff && bytes[1] == 0xd8 && bytes[2] == 0xff && bytes[3] == 0xe0)
		return OGImageExtensionsImageTypeJPEG;
	
	if (bytes[0] == 0x49 && bytes[1] == 0x49 && bytes[2] == 0x2a)
		return OGImageExtensionsImageTypeTIFF;
	
	if (bytes[0] == 0x42 && bytes[1] == 0x4d)
		return OGImageExtensionsImageTypeBMP;
	
	if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46)
		return OGImageExtensionsImageTypeGIF;
	
	return OGImageExtensionsImageTypeUnknown;
}

@end
