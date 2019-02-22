//
//  RichTextEditorFontSizePickerViewController.h
//  RichTextEdtor
//
//  Created by Luma on 2/21/19.
//  Copyright (c) 2013 Luma. All rights reserved.
//
// https://github.com/aryaxt/iOS-Rich-Text-Editor
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "RTELocalization.h"

#ifdef cplusplus
extern "C" {
#endif
	
NSString* _RTE_L(NSString* key) {
	NSString* lan = [[NSLocale preferredLanguages] objectAtIndex:0];
	if(!lan) {
		lan = @"en";
	}
	if([lan length] > 2) {
		lan = [lan substringToIndex:2];
	}
	BOOL isChinese = [@"zh" isEqualToString:lan];
	NSString* lprojDir = isChinese ? @"zh-Hans.lproj" : @"en.lproj";
	NSString* path = [[NSBundle mainBundle] pathForResource:@"RichTextEditor" ofType:@"strings" inDirectory:lprojDir];
	NSDictionary *localizedDict = [[NSDictionary alloc] initWithContentsOfFile:path];
	return localizedDict[key];
}
	
#ifdef cplusplus
}
#endif
