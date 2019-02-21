//
//  UIColor+HexColors.m
//  KiwiHarness
//
//  Created by Tim on 07/09/2012.
//  Copyright (c) 2012 Charismatic Megafauna Ltd. All rights reserved.
//

#import "UIColor+RichTextEditor.h"

@implementation UIColor (HexColors)

+(UIColor *)rte_colorWithHexString:(NSString *)hexString {
	if ([hexString length] != 8 && [hexString length] != 6) {
		return [UIColor blackColor];
	}
	
	// Brutal and not-very elegant test for non hex-numeric characters
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^a-fA-F|0-9]" options:0 error:NULL];
	NSUInteger match = [regex numberOfMatchesInString:hexString options:NSMatchingReportCompletion range:NSMakeRange(0, [hexString length])];
	
	if (match != 0) {
		return [UIColor blackColor];
	}
	
	NSRange rRange = NSMakeRange(0, 2);
	NSString *rComponent = [hexString substringWithRange:rRange];
	NSUInteger rVal = 0;
	NSScanner *rScanner = [NSScanner scannerWithString:rComponent];
	[rScanner scanHexInt:(unsigned int *)&rVal];
	float rRetVal = (float)rVal / 254;
	
	
	NSRange gRange = NSMakeRange(2, 2);
	NSString *gComponent = [hexString substringWithRange:gRange];
	NSUInteger gVal = 0;
	NSScanner *gScanner = [NSScanner scannerWithString:gComponent];
	[gScanner scanHexInt:(unsigned int *)&gVal];
	float gRetVal = (float)gVal / 254;
	
	NSRange bRange = NSMakeRange(4, 2);
	NSString *bComponent = [hexString substringWithRange:bRange];
	NSUInteger bVal = 0;
	NSScanner *bScanner = [NSScanner scannerWithString:bComponent];
	[bScanner scanHexInt:(unsigned int *)&bVal];
	float bRetVal = (float)bVal / 254;
	
	float aRetVal = 1.0f;
	if([hexString length] > 6) {
		NSRange aRange = NSMakeRange(6, 2);
		NSString *aComponent = [hexString substringWithRange:aRange];
		NSUInteger aVal = 0;
		NSScanner *aScanner = [NSScanner scannerWithString:aComponent];
		[aScanner scanHexInt:(unsigned int *)&aVal];
		aRetVal = (float)aVal / 254;
	}
	
	return [UIColor colorWithRed:rRetVal green:gRetVal blue:bRetVal alpha:aRetVal];
}

+(NSString *)rte_hexValuesFromUIColor:(UIColor *)color {
	if (!color) {
		return @"00000000";
	}
	
	if (color == [UIColor whiteColor]) {
		// Special case, as white doesn't fall into the RGB color space
		return @"ffffffff";
	}
	
	CGFloat red;
	CGFloat blue;
	CGFloat green;
	CGFloat alpha;
	
	[color getRed:&red green:&green blue:&blue alpha:&alpha];
	
	int redDec = (int)(red * 255);
	int greenDec = (int)(green * 255);
	int blueDec = (int)(blue * 255);
	int alphaDec = (int)(alpha * 255);
	
	NSString *returnString = [NSString stringWithFormat:@"%02x%02x%02x%02x", (unsigned int)redDec, (unsigned int)greenDec, (unsigned int)blueDec, (unsigned int)alphaDec];
	
	return returnString;
}

@end
