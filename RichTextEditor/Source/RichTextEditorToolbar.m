//
//  RichTextEditorToolbar.m
//  RichTextEdtor
//
//  Created by Aryan Gh on 7/21/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
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

#import "RichTextEditorToolbar.h"
#import <CoreText/CoreText.h>
#import "RichTextEditorPopover.h"
#import "RichTextEditorFontSizePickerViewController.h"
#import "RichTextEditorFontPickerViewController.h"
#import "RichTextEditorColorPickerViewController.h"
#import "WEPopoverController.h"
#import "RichTextEditorToggleButton.h"
#import "UIFont+RichTextEditor.h"
#import "UIColor+RichTextEditor.h"

#define ITEM_SEPARATOR_SPACE 5
#define ITEM_TOP_AND_BOTTOM_BORDER 5
#define ITEM_WIDTH 40

@interface RichTextEditorToolbar() <RichTextEditorFontSizePickerViewControllerDelegate, RichTextEditorFontSizePickerViewControllerDataSource, RichTextEditorFontPickerViewControllerDelegate, RichTextEditorFontPickerViewControllerDataSource, RichTextEditorColorPickerViewControllerDataSource, RichTextEditorColorPickerViewControllerDelegate>
@property (nonatomic, strong) id <RichTextEditorPopover> popover;
@property (nonatomic, strong) RichTextEditorToggleButton *btnBold;
@property (nonatomic, strong) RichTextEditorToggleButton *btnItalic;
@property (nonatomic, strong) RichTextEditorToggleButton *btnUnderline;
@property (nonatomic, strong) RichTextEditorToggleButton *btnStrikeThrough;
@property (nonatomic, strong) RichTextEditorToggleButton *btnFontSize;
@property (nonatomic, strong) RichTextEditorToggleButton *btnFont;
@property (nonatomic, strong) RichTextEditorToggleButton *btnBackgroundColor;
@property (nonatomic, strong) RichTextEditorToggleButton *btnForegroundColor;
@property (nonatomic, strong) RichTextEditorToggleButton *btnTextAlignmentLeft;
@property (nonatomic, strong) RichTextEditorToggleButton *btnTextAlignmentCenter;
@property (nonatomic, strong) RichTextEditorToggleButton *btnTextAlignmentRight;
@property (nonatomic, strong) RichTextEditorToggleButton *btnTextAlignmentJustified;
@property (nonatomic, strong) RichTextEditorToggleButton *btnParagraphIndent;
@property (nonatomic, strong) RichTextEditorToggleButton *btnParagraphOutdent;
@property (nonatomic, strong) RichTextEditorToggleButton *btnParagraphFirstLineHeadIndent;
@property (nonatomic, strong) RichTextEditorToggleButton *btnBulletPoint;

// last selection
@property (nonatomic, assign, readonly) NSString* lastSelectedFontName;
@property (nonatomic, assign, readonly) NSInteger lastSelectedFontSize;
@property (nonatomic, assign, readonly) UIColor* lastSelectedForegroundColor;
@property (nonatomic, assign, readonly) UIColor* lastSelectedBackgroundColor;

// preference key prefix
@property (nonatomic, strong) NSString* prefNS;

@end

@implementation RichTextEditorToolbar

#pragma mark - Initialization -

- (id)initWithFrame:(CGRect)frame delegate:(id <RichTextEditorToolbarDelegate>)delegate dataSource:(id <RichTextEditorToolbarDataSource>)dataSource
{
	if (self = [super initWithFrame:frame])
	{
		self.delegate = delegate;
		self.dataSource = dataSource;
		
		// get preference key prefix
		self.prefNS = [self.dataSource preferenceNamespaceForRichTextEditorToolbar];
		
		self.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1];
		self.layer.borderWidth = .7;
		self.layer.borderColor = [UIColor lightGrayColor].CGColor;
		
		[self initializeButtons];
        [self populateToolbar];
	}
	
	return self;
}

#pragma mark - Public Methods -

- (NSString*)lastSelectedFontName {
	NSUserDefaults* d = [NSUserDefaults standardUserDefaults];
	return [d stringForKey:[NSString stringWithFormat:@"%@_fontName", self.prefNS]];
}

- (NSInteger)lastSelectedFontSize {
	NSUserDefaults* d = [NSUserDefaults standardUserDefaults];
	return [d integerForKey:[NSString stringWithFormat:@"%@_fontSize", self.prefNS]];
}

- (UIColor*)lastSelectedForegroundColor {
	NSUserDefaults* d = [NSUserDefaults standardUserDefaults];
	NSString* cstr = [d stringForKey:[NSString stringWithFormat:@"%@_foregroundColor", self.prefNS]];
	if(!cstr || [cstr length] <= 0) {
		cstr = @"000000ff";
	}
	return [UIColor rte_colorWithHexString:cstr];
}

- (UIColor*)lastSelectedBackgroundColor {
	NSUserDefaults* d = [NSUserDefaults standardUserDefaults];
	NSString* cstr = [d stringForKey:[NSString stringWithFormat:@"%@_backgroundColor", self.prefNS]];
	if(!cstr || [cstr length] <= 0) {
		cstr = @"00000000";
	}
	return [UIColor rte_colorWithHexString:cstr];
}

- (void)redraw
{
	[self populateToolbar];
}

- (void)updateStateWithAttributes:(NSDictionary *)attributes
{
	UIFont *font = [attributes objectForKey:NSFontAttributeName];
	NSParagraphStyle *paragraphTyle = [attributes objectForKey:NSParagraphStyleAttributeName];
	
	[self.btnFontSize setTitle:[NSString stringWithFormat:@"%.f", font.pointSize] forState:UIControlStateNormal];
	[self.btnFont setTitle:font.familyName forState:UIControlStateNormal];
	
	bool supportBold = [font fontWithBoldTrait:true andItalicTrait:false] != nil;
	bool supportItalic = [font fontWithBoldTrait:false andItalicTrait:true] != nil;
	self.btnBold.enabled = supportBold;
	self.btnItalic.enabled = supportItalic;
	self.btnBold.on = [font isBold];
	self.btnItalic.on = [font isItalic];
	
	self.btnTextAlignmentLeft.on = NO;
	self.btnTextAlignmentCenter.on = NO;
	self.btnTextAlignmentRight.on = NO;
	self.btnTextAlignmentJustified.on = NO;
	self.btnParagraphFirstLineHeadIndent.on = (paragraphTyle.firstLineHeadIndent > paragraphTyle.headIndent) ? YES : NO;
	
	switch (paragraphTyle.alignment)
	{
		case NSTextAlignmentLeft:
			self.btnTextAlignmentLeft.on = YES;
			break;
		case NSTextAlignmentCenter:
			self.btnTextAlignmentCenter.on = YES;
			break;
			
		case NSTextAlignmentRight:
			self.btnTextAlignmentRight.on = YES;
			break;
			
		case NSTextAlignmentJustified:
			self.btnTextAlignmentJustified.on = YES;
			break;
			
		default:
			self.btnTextAlignmentLeft.on = YES;
			break;
	}
	
	NSNumber *existingUnderlineStyle = [attributes objectForKey:NSUnderlineStyleAttributeName];
	self.btnUnderline.on = (!existingUnderlineStyle || existingUnderlineStyle.intValue == NSUnderlineStyleNone) ? NO :YES;
	
	NSNumber *existingStrikeThrough = [attributes objectForKey:NSStrikethroughStyleAttributeName];
	self.btnStrikeThrough.on = (!existingStrikeThrough || existingStrikeThrough.intValue == NSUnderlineStyleNone) ? NO :YES;
	
	// foreground icon
	UIColor* foregroundColor = [attributes objectForKey:NSForegroundColorAttributeName];
	if(foregroundColor) {
		UIImage* img = [UIImage imageNamed:@"forecolor"];
		UIGraphicsBeginImageContext(img.size);
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextTranslateCTM(context, 0, img.size.height);
		CGContextScaleCTM(context, 1, -1);
		CGContextDrawImage(context, CGRectMake(0, 0, img.size.width, img.size.height), img.CGImage);
		CGContextSetFillColorWithColor(context, foregroundColor.CGColor);
		CGContextFillRect(context, CGRectMake(2, 2, 16, 3));
		UIImage* colorImg = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		[self.btnForegroundColor setImage:colorImg forState:UIControlStateNormal];
	}
	
	// background icon
	UIColor* backgroundColor = [attributes objectForKey:NSBackgroundColorAttributeName];
	if(self.stateProvider) {
		UIColor* bg = [self.stateProvider richTextEditorToolbarSelectedBackgroundColor];
		if(bg) {
			backgroundColor = bg;
		}
	}
	if(backgroundColor) {
		UIImage* img = [UIImage imageNamed:@"backcolor"];
		UIGraphicsBeginImageContext(img.size);
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextTranslateCTM(context, 0, img.size.height);
		CGContextScaleCTM(context, 1, -1);
		CGContextDrawImage(context, CGRectMake(0, 0, img.size.width, img.size.height), img.CGImage);
		CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
		CGContextFillRect(context, CGRectMake(2, 2, 12, 12));
		UIImage* colorImg = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		[self.btnBackgroundColor setImage:colorImg forState:UIControlStateNormal];
	}
}

#pragma mark - IBActions -

- (void)boldSelected:(UIButton *)sender
{
	[self.delegate richTextEditorToolbarDidSelectBold];
}

- (void)italicSelected:(UIButton *)sender
{
	[self.delegate richTextEditorToolbarDidSelectItalic];
}

- (void)underLineSelected:(UIButton *)sender
{
	[self.delegate richTextEditorToolbarDidSelectUnderline];
}

- (void)strikeThroughSelected:(UIButton *)sender
{
	[self.delegate richTextEditorToolbarDidSelectStrikeThrough];
}

- (void)bulletPointSelected:(UIButton *)sender
{
	[self.delegate richTextEditorToolbarDidSelectBulletPoint];
}

- (void)paragraphIndentSelected:(UIButton *)sender
{
	[self.delegate richTextEditorToolbarDidSelectParagraphIndentation:ParagraphIndentationIncrease];
}

- (void)paragraphOutdentSelected:(UIButton *)sender
{
	[self.delegate richTextEditorToolbarDidSelectParagraphIndentation:ParagraphIndentationDecrease];
}

- (void)paragraphHeadIndentOutdentSelected:(UIButton *)sender
{
	[self.delegate richTextEditorToolbarDidSelectParagraphFirstLineHeadIndent];
}

- (void)fontSizeSelected:(UIButton *)sender
{
	if(self.popover && [[self.popover contentViewController] isKindOfClass:RichTextEditorFontSizePickerViewController.class]) {
		[self.popover dismissPopoverAnimated:YES];
		self.popover = nil;
	} else {
		RichTextEditorFontSizePickerViewController *fontSizePicker = [[RichTextEditorFontSizePickerViewController alloc] init];
		fontSizePicker.delegate = self;
		fontSizePicker.dataSource = self;
		[self presentViewController:fontSizePicker fromView:sender];
	}
}

- (void)fontSelected:(UIButton *)sender
{
	if(self.popover && [[self.popover contentViewController] isKindOfClass:RichTextEditorFontPickerViewController.class]) {
		[self.popover dismissPopoverAnimated:YES];
		self.popover = nil;
	} else {
		RichTextEditorFontPickerViewController *fontPicker= [[RichTextEditorFontPickerViewController alloc] init];
		fontPicker.fontNames = [self.dataSource fontFamilySelectionForRichTextEditorToolbar];
		fontPicker.delegate = self;
		fontPicker.dataSource = self;
		[self presentViewController:fontPicker fromView:sender];
	}
}

- (void)textBackgroundColorSelected:(UIButton *)sender
{
	// if background popover is opened, dismiss it, otherwise show new popover
	if(self.popover && [self.popover isPopoverVisible] && [[self.popover contentViewController] isKindOfClass:RichTextEditorColorPickerViewController.class] &&
	   ((RichTextEditorColorPickerViewController*)[self.popover contentViewController]).action == RichTextEditorColorPickerActionTextBackgroundColor) {
		[self.popover dismissPopoverAnimated:YES];
		self.popover = nil;
	} else {
		RichTextEditorColorPickerViewController *colorPicker = [[RichTextEditorColorPickerViewController alloc] init];
		colorPicker.action = RichTextEditorColorPickerActionTextBackgroundColor;
		colorPicker.delegate = self;
		colorPicker.dataSource = self;
		[self presentViewController:colorPicker fromView:sender];
	}
}

- (void)textForegroundColorSelected:(UIButton *)sender
{
	// if foreground popover is opened, dismiss it, otherwise show new popover
	if(self.popover && [self.popover isPopoverVisible] && [[self.popover contentViewController] isKindOfClass:RichTextEditorColorPickerViewController.class] &&
	   ((RichTextEditorColorPickerViewController*)[self.popover contentViewController]).action == RichTextEditorColorPickerActionTextForegroudColor) {
		[self.popover dismissPopoverAnimated:YES];
		self.popover = nil;
	} else {
		RichTextEditorColorPickerViewController *colorPicker = [[RichTextEditorColorPickerViewController alloc] init];
		colorPicker.action = RichTextEditorColorPickerActionTextForegroudColor;
		colorPicker.delegate = self;
		colorPicker.dataSource = self;
		[self presentViewController:colorPicker fromView:sender];
	}
}

- (void)textAlignmentSelected:(UIButton *)sender
{
	NSTextAlignment textAlignment = NSTextAlignmentLeft;
	
	if (sender == self.btnTextAlignmentLeft)
		textAlignment = NSTextAlignmentLeft;
	else if (sender == self.btnTextAlignmentCenter)
		textAlignment = NSTextAlignmentCenter;
	else if (sender == self.btnTextAlignmentRight)
		textAlignment = NSTextAlignmentRight;
	else if (sender == self.btnTextAlignmentJustified)
		textAlignment = NSTextAlignmentJustified;
	
	[self.delegate richTextEditorToolbarDidSelectTextAlignment:textAlignment];
}

#pragma mark - Private Methods -

- (void)populateToolbar
{
    // Remove any existing subviews.
    for (UIView *subView in self.subviews)
	{
        [subView removeFromSuperview];
    }
    
    // Populate the toolbar with the given features.
    RichTextEditorFeature features = [self.dataSource featuresEnabledForRichTextEditorToolbar];
    UIView *lastAddedView = nil;
    
    self.hidden = (features == RichTextEditorFeatureNone);
	
	if (self.hidden)
		return;
	
	// Font selection
	if (features & RichTextEditorFeatureFont || features & RichTextEditorFeatureAll)
	{
		UIView *separatorView = [self separatorView];
		[self addView:self.btnFont afterView:lastAddedView withSpacing:YES];
		[self addView:separatorView afterView:self.btnFont withSpacing:YES];
		lastAddedView = separatorView;
	}
	
	// Font size
	if (features & RichTextEditorFeatureFontSize || features & RichTextEditorFeatureAll)
	{
		UIView *separatorView = [self separatorView];
		[self addView:self.btnFontSize afterView:lastAddedView withSpacing:YES];
		[self addView:separatorView afterView:self.btnFontSize withSpacing:YES];
		lastAddedView = separatorView;
	}
	
	// Background color
	if (features & RichTextEditorFeatureTextBackgroundColor || features & RichTextEditorFeatureAll)
	{
		[self addView:self.btnBackgroundColor afterView:lastAddedView withSpacing:YES];
		lastAddedView = self.btnBackgroundColor;
	}
	
	// Text color
	if (features & RichTextEditorFeatureTextForegroundColor || features & RichTextEditorFeatureAll)
	{
		[self addView:self.btnForegroundColor afterView:lastAddedView withSpacing:YES];
		lastAddedView = self.btnForegroundColor;
	}
	
	// Separator view after color section
	if (features & RichTextEditorFeatureTextBackgroundColor || features & RichTextEditorFeatureTextForegroundColor || features & RichTextEditorFeatureAll)
	{
		UIView *separatorView = [self separatorView];
		[self addView:separatorView afterView:lastAddedView withSpacing:YES];
		lastAddedView = separatorView;
	}
	
	// Bold
	if (features & RichTextEditorFeatureBold || features & RichTextEditorFeatureAll)
	{
		[self addView:self.btnBold afterView:lastAddedView withSpacing:YES];
		lastAddedView = self.btnBold;
	}
	
	// Italic
	if (features & RichTextEditorFeatureItalic || features & RichTextEditorFeatureAll)
	{
		[self addView:self.btnItalic afterView:lastAddedView withSpacing:YES];
		lastAddedView = self.btnItalic;
	}
	
	// Underline
	if (features & RichTextEditorFeatureUnderline || features & RichTextEditorFeatureAll)
	{
		[self addView:self.btnUnderline afterView:lastAddedView withSpacing:YES];
		lastAddedView = self.btnUnderline;
	}
	
	// Strikethrough
	if (features & RichTextEditorFeatureStrikeThrough || features & RichTextEditorFeatureAll)
	{
		[self addView:self.btnStrikeThrough afterView:lastAddedView withSpacing:YES];
		lastAddedView = self.btnStrikeThrough;
	}
	
	// Separator view after font properties.
	if (features & RichTextEditorFeatureBold || features & RichTextEditorFeatureItalic || features & RichTextEditorFeatureUnderline || features & RichTextEditorFeatureStrikeThrough || features & RichTextEditorFeatureAll)
	{
		UIView *separatorView = [self separatorView];
		[self addView:separatorView afterView:lastAddedView withSpacing:YES];
		lastAddedView = separatorView;
	}
	
	// Align left
	if (features & RichTextEditorFeatureTextAlignmentLeft || features & RichTextEditorFeatureAll)
	{
		[self addView:self.btnTextAlignmentLeft afterView:lastAddedView withSpacing:YES];
		lastAddedView = self.btnTextAlignmentLeft;
	}
	
	// Align center
	if (features & RichTextEditorFeatureTextAlignmentCenter || features & RichTextEditorFeatureAll)
	{
		[self addView:self.btnTextAlignmentCenter afterView:lastAddedView withSpacing:YES];
		lastAddedView = self.btnTextAlignmentCenter;
	}
	
	// Align right
	if (features & RichTextEditorFeatureTextAlignmentRight || features & RichTextEditorFeatureAll)
	{
		[self addView:self.btnTextAlignmentRight afterView:lastAddedView withSpacing:YES];
		lastAddedView = self.btnTextAlignmentRight;
	}
	
	// Align justified
	if (features & RichTextEditorFeatureTextAlignmentJustified || features & RichTextEditorFeatureAll)
	{
		[self addView:self.btnTextAlignmentJustified afterView:lastAddedView withSpacing:YES];
		lastAddedView = self.btnTextAlignmentJustified;
	}
	
	// Separator view after alignment section
	if (features & RichTextEditorFeatureTextAlignmentLeft || features & RichTextEditorFeatureTextAlignmentCenter || features & RichTextEditorFeatureTextAlignmentRight || features & RichTextEditorFeatureTextAlignmentJustified || features & RichTextEditorFeatureAll)
	{
		UIView *separatorView = [self separatorView];
		[self addView:separatorView afterView:lastAddedView withSpacing:YES];
		lastAddedView = separatorView;
	}
	
	// Paragraph indentation
	if (features & RichTextEditorFeatureParagraphIndentation || features & RichTextEditorFeatureAll)
	{
		[self addView:self.btnParagraphOutdent afterView:lastAddedView  withSpacing:YES];
		[self addView:self.btnParagraphIndent afterView:self.btnParagraphOutdent withSpacing:YES];
		lastAddedView = self.btnParagraphIndent;
	}
	
	// Paragraph first line indentation
	if (features & RichTextEditorFeatureParagraphFirstLineIndentation || features & RichTextEditorFeatureAll)
	{
		[self addView:self.btnParagraphFirstLineHeadIndent afterView:lastAddedView withSpacing:YES];
		lastAddedView = self.btnParagraphFirstLineHeadIndent;
	}
	
	// Separator view after Indentation
	if (features & RichTextEditorFeatureParagraphIndentation || features & RichTextEditorFeatureParagraphFirstLineIndentation || features & RichTextEditorFeatureAll)
	{
		UIView *separatorView = [self separatorView];
		[self addView:separatorView afterView:lastAddedView withSpacing:YES];
		lastAddedView = separatorView;
	}
}

- (void)initializeButtons
{
	self.btnFont = [self buttonWithImageNamed:@"dropDownTriangle.png"
										width:120
								  andSelector:@selector(fontSelected:)];
	[self.btnFont setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
	NSString* fontName = self.lastSelectedFontName;
	[self.btnFont setTitle:fontName ? fontName : @"Font" forState:UIControlStateNormal];
	
	
	self.btnFontSize = [self buttonWithImageNamed:@"dropDownTriangle.png"
											width:50
									  andSelector:@selector(fontSizeSelected:)];
	[self.btnFontSize setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
	NSInteger fontSize = self.lastSelectedFontSize;
	if(fontSize <= 0) {
		fontSize = 16;
	}
	[self.btnFontSize setTitle:[NSString stringWithFormat:@"%ld", fontSize]
					  forState:UIControlStateNormal];
	
	self.btnBold = [self buttonWithImageNamed:@"bold.png"
								  andSelector:@selector(boldSelected:)];
	
	
	self.btnItalic = [self buttonWithImageNamed:@"italic.png"
									andSelector:@selector(italicSelected:)];
	
	
	self.btnUnderline = [self buttonWithImageNamed:@"underline.png"
									   andSelector:@selector(underLineSelected:)];
	
	self.btnStrikeThrough = [self buttonWithImageNamed:@"strikethrough"
										   andSelector:@selector(strikeThroughSelected:)];
	
	
	self.btnTextAlignmentLeft = [self buttonWithImageNamed:@"justifyleft.png"
											   andSelector:@selector(textAlignmentSelected:)];
	
	
	self.btnTextAlignmentCenter = [self buttonWithImageNamed:@"justifycenter.png"
												 andSelector:@selector(textAlignmentSelected:)];
	
	
	self.btnTextAlignmentRight = [self buttonWithImageNamed:@"justifyright.png"
												andSelector:@selector(textAlignmentSelected:)];
	
	self.btnTextAlignmentJustified = [self buttonWithImageNamed:@"justifyfull.png"
													andSelector:@selector(textAlignmentSelected:)];
	
	self.btnForegroundColor = [self buttonWithImageNamed:@"forecolor.png"
											 andSelector:@selector(textForegroundColorSelected:)];
	
	self.btnBackgroundColor = [self buttonWithImageNamed:@"backcolor.png"
											 andSelector:@selector(textBackgroundColorSelected:)];
	
	self.btnBulletPoint = [self buttonWithImageNamed:@"bullist.png"
										 andSelector:@selector(bulletPointSelected:)];
	
	self.btnParagraphIndent = [self buttonWithImageNamed:@"indent.png"
											 andSelector:@selector(paragraphIndentSelected:)];
	
	self.btnParagraphOutdent = [self buttonWithImageNamed:@"outdent.png"
											  andSelector:@selector(paragraphOutdentSelected:)];
	
	self.btnParagraphFirstLineHeadIndent = [self buttonWithImageNamed:@"firstLineIndent.png"
														  andSelector:@selector(paragraphHeadIndentOutdentSelected:)];
	
	// notify delegate for first name
	if(fontName) {
		[self.delegate richTextEditorToolbarDidSelectFontWithName:fontName];
	}
	[self.delegate richTextEditorToolbarDidSelectFontSize:@(fontSize)];
	[self.delegate richTextEditorToolbarDidSelectTextForegroundColor:self.lastSelectedForegroundColor];
	[self.delegate richTextEditorToolbarDidSelectTextBackgroundColor:self.lastSelectedBackgroundColor];
}

- (RichTextEditorToggleButton *)buttonWithImageNamed:(NSString *)image width:(NSInteger)width andSelector:(SEL)selector
{
	RichTextEditorToggleButton *button = [[RichTextEditorToggleButton alloc] init];
	[button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
	[button setFrame:CGRectMake(0, 0, width, 0)];
	[button.titleLabel setFont:[UIFont boldSystemFontOfSize:10]];
	[button.titleLabel setTextColor:[UIColor blackColor]];
	[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
	
	// set disabled image
	NSString* name = [NSString stringWithFormat:@"%@_disabled", image];
	UIImage* disabledImg = [UIImage imageNamed:name];
	if(disabledImg) {
		[button setImage:disabledImg forState:UIControlStateDisabled];
	}
	
	return button;
}

- (RichTextEditorToggleButton *)buttonWithImageNamed:(NSString *)image andSelector:(SEL)selector
{
	return [self buttonWithImageNamed:image width:ITEM_WIDTH andSelector:selector];
}

- (UIView *)separatorView
{
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, self.frame.size.height)];
	view.backgroundColor = [UIColor lightGrayColor];
	
	return view;
}

- (void)addView:(UIView *)view afterView:(UIView *)otherView withSpacing:(BOOL)space
{
	CGRect otherViewRect = (otherView) ? otherView.frame : CGRectZero;
	CGRect rect = view.frame;
	rect.origin.x = otherViewRect.size.width + otherViewRect.origin.x;
	if (space)
		rect.origin.x += ITEM_SEPARATOR_SPACE;
	
	rect.origin.y = ITEM_TOP_AND_BOTTOM_BORDER;
	rect.size.height = self.frame.size.height - (2*ITEM_TOP_AND_BOTTOM_BORDER);
	view.frame = rect;
	view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	
	[self addSubview:view];
	[self updateContentSize];
}

- (void)updateContentSize
{
	NSInteger maxViewlocation = 0;
	
	for (UIView *view in self.subviews)
	{
		NSInteger endLocation = view.frame.size.width + view.frame.origin.x;
		
		if (endLocation > maxViewlocation)
			maxViewlocation = endLocation;
	}
	
	self.contentSize = CGSizeMake(maxViewlocation+ITEM_SEPARATOR_SPACE, self.frame.size.height);
}

- (void)presentViewController:(UIViewController *)viewController fromView:(UIView *)view
{
	id <RichTextEditorPopover> popover = [self popoverWithViewController:viewController];
	[popover presentPopoverFromRect:view.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

- (id <RichTextEditorPopover>)popoverWithViewController:(UIViewController *)viewController
{
	id <RichTextEditorPopover> popover;
	
	if (!popover)
	{
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		{
			popover = (id<RichTextEditorPopover>) [[UIPopoverController alloc] initWithContentViewController:viewController];
		}
		else
		{
			popover = (id<RichTextEditorPopover>) [[WEPopoverController alloc] initWithContentViewController:viewController];
		}
	}
	
	[self.popover dismissPopoverAnimated:YES];
	self.popover = popover;
	
	return popover;
}

- (void)dismissViewController
{
	[self.popover dismissPopoverAnimated:YES];
}

#pragma mark - RichTextEditorColorPickerViewControllerDelegate & RichTextEditorColorPickerViewControllerDataSource Methods -

- (void)richTextEditorColorPickerViewControllerDidSelectColor:(UIColor *)color withAction:(RichTextEditorColorPickerAction)action
{
	if (action == RichTextEditorColorPickerActionTextBackgroundColor)
	{
		[self.delegate richTextEditorToolbarDidSelectTextBackgroundColor:color];
	}
	else
	{
		[self.delegate richTextEditorToolbarDidSelectTextForegroundColor:color];
	}
}

- (void)richTextEditorColorPickerViewControllerDidSelectClose
{
	[self dismissViewController];
}

- (NSArray<NSString*>*)predefinedColorsForColorPickerViewController:(RichTextEditorColorPickerViewController*)cpvc {
	if(self.dataSource && [self.dataSource respondsToSelector:@selector(predefinedColorsForRichTextEditorToolbar)]) {
		if(cpvc.action == RichTextEditorColorPickerActionTextForegroudColor) {
			return [self.dataSource predefinedColorsForRichTextEditorToolbar];
		} else {
			return [self.dataSource predefinedBgColorsForRichTextEditorToolbar];
		}
	}
	return @[];
}

#pragma mark - RichTextEditorFontSizePickerViewControllerDelegate & RichTextEditorFontSizePickerViewControllerDataSource Methods -

- (void)richTextEditorFontSizePickerViewControllerDidSelectFontSize:(NSNumber *)fontSize
{
	[self.delegate richTextEditorToolbarDidSelectFontSize:fontSize];
	[self dismissViewController];
}

- (void)richTextEditorFontSizePickerViewControllerDidSelectClose
{
	[self dismissViewController];
}

- (NSArray *)richTextEditorFontSizePickerViewControllerCustomFontSizesForSelection
{
	return [self.dataSource fontSizeSelectionForRichTextEditorToolbar];
}

#pragma mark - RichTextEditorFontPickerViewControllerDelegate & RichTextEditorFontPickerViewControllerDataSource Methods -

- (void)richTextEditorFontPickerViewControllerDidSelectFontWithName:(NSString *)fontName
{
	[self.delegate richTextEditorToolbarDidSelectFontWithName:fontName];
	[self dismissViewController];
}

- (void)richTextEditorFontPickerViewControllerDidSelectClose
{
	[self dismissViewController];
}

- (NSArray *)richTextEditorFontPickerViewControllerCustomFontFamilyNamesForSelection
{
	return [self.dataSource fontFamilySelectionForRichTextEditorToolbar];
}

@end
