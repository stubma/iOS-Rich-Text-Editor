//
//  RichTextEditorColorPickerViewController.m
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

#import "RichTextEditorColorPickerViewController.h"
#import "UIColor+RichTextEditor.h"

@interface RichTextEditorColorPickerViewController ()

@property (nonatomic, assign, readonly) UIColor* lastSelectedForegroundColor;
@property (nonatomic, assign, readonly) UIColor* lastSelectedBackgroundColor;

@end

@implementation RichTextEditorColorPickerViewController

#pragma mark - VoewController Methods -

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	CGSize contentSize = CGSizeMake(self.view.frame.size.width - 10, 100);
	
	self.selectedColorView = [[UIView alloc] initWithFrame:CGRectMake(contentSize.width - 30, (contentSize.height - 30) / 2, 35, 30)];
	self.selectedColorView.backgroundColor = self.action == RichTextEditorColorPickerActionTextForegroudColor ? self.lastSelectedForegroundColor : self.lastSelectedBackgroundColor;
	self.selectedColorView.layer.borderColor = [UIColor lightGrayColor].CGColor;
	self.selectedColorView.layer.borderWidth = 1;
	self.selectedColorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	[self.view addSubview:self.selectedColorView];
	
	self.colorsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"colors.jpg"]];
	self.colorsImageView.frame = CGRectMake(0, 0, contentSize.width - 5 - self.selectedColorView.frame.size.width, contentSize.height);
	self.colorsImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
	self.colorsImageView.layer.borderWidth = 1;
	self.colorsImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:self.colorsImageView];
	
	if ([self.dataSource richTextEditorColorPickerViewControllerShouldDisplayToolbar])
	{
		CGFloat reservedSizeForStatusBar = (
											UIDevice.currentDevice.systemVersion.floatValue >= 7.0
											&& !(   UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad
												 && self.modalPresentationStyle==UIModalPresentationFormSheet
												 )
											) ? 20.:0.; //Add the size of the status bar for iOS 7, not on iPad presenting modal sheet
		
		CGFloat toolbarHeight = 44 +reservedSizeForStatusBar;
		
		UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, contentSize.width, toolbarHeight)];
		toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[self.view addSubview:toolbar];
		
		UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																						   target:nil
																						   action:nil];
		
		UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																				  target:self
																				  action:@selector(doneSelected:)];
		
		UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																				   target:self
																				   action:@selector(closeSelected:)];
		
		UIBarButtonItem *selectedColorItem = [[UIBarButtonItem alloc] initWithCustomView:self.selectedColorView];
		
		[toolbar setItems:@[closeItem, flexibleSpaceItem, selectedColorItem, doneItem]];
		[self.view addSubview:toolbar];
		
		self.colorsImageView.frame = CGRectMake(2, toolbarHeight+2, contentSize.width-4, contentSize.height - (toolbarHeight+4));
	}
	
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
	self.preferredContentSize = contentSize;
#else
	self.contentSizeForViewInPopover = contentSize;
#endif
}

- (UIColor*)lastSelectedForegroundColor {
	NSUserDefaults* d = [NSUserDefaults standardUserDefaults];
	NSString* cstr = [d stringForKey:@"RichTextEditor_foregroundColor"];
	if(!cstr || [cstr length] <= 0) {
		cstr = @"000000ff";
	}
	return [UIColor rte_colorWithHexString:cstr];
}

- (UIColor*)lastSelectedBackgroundColor {
	NSUserDefaults* d = [NSUserDefaults standardUserDefaults];
	NSString* cstr = [d stringForKey:@"RichTextEditor_backgroundColor"];
	if(!cstr || [cstr length] <= 0) {
		cstr = @"00000000";
	}
	return [UIColor rte_colorWithHexString:cstr];
}

#pragma mark - Private Methods -

- (void)populateColorsForPoint:(CGPoint)point
{
	self.selectedColorView.backgroundColor = [self.colorsImageView colorOfPoint:point];
}

#pragma mark - IBActions -

- (IBAction)doneSelected:(id)sender
{
	[self.delegate richTextEditorColorPickerViewControllerDidSelectColor:self.selectedColorView.backgroundColor withAction:self.action];
}

- (IBAction)closeSelected:(id)sender
{
	[self.delegate richTextEditorColorPickerViewControllerDidSelectClose];
}

#pragma mark - Touch Detection -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint locationPoint = [[touches anyObject] locationInView:self.colorsImageView];
	[self populateColorsForPoint:locationPoint];
	[self doneSelected:nil];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint locationPoint = [[touches anyObject] locationInView:self.colorsImageView];
	[self populateColorsForPoint:locationPoint];
	[self doneSelected:nil];
}

@end

