//
//  NSData+OGImageExtensions.m
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

#import "NSData+OGImageExtensions.h"
#import "OGImageExtensions.h"

@implementation NSData (OGImageExtensions)

- (OGImageExtensionsImageType)og_typeOfImageData
{
	if (self.length < 4) return OGImageExtensionsImageTypeUnknown;
	
	const unsigned char* bytes = self.bytes;
	
	if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4e && bytes[3] == 0x47) return OGImageExtensionsImageTypePNG;
	if (bytes[0] == 0xff && bytes[1] == 0xd8 && bytes[2] == 0xff && bytes[3] == 0xe0) return OGImageExtensionsImageTypeJPEG;
	if (bytes[0] == 0x49 && bytes[1] == 0x49 && bytes[2] == 0x2a)                     return OGImageExtensionsImageTypeTIFF;
	if (bytes[0] == 0x42 && bytes[1] == 0x4d)                                         return OGImageExtensionsImageTypeBMP;
	if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46)                     return OGImageExtensionsImageTypeGIF;
	
	return OGImageExtensionsImageTypeUnknown;
}

@end
