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
#import "RTEColorPickerView.h"

@interface RichTextEditorColorPickerViewController ()

@property (nonatomic, strong) RTEColorPickerView* colorPickerView;

@end

@implementation RichTextEditorColorPickerViewController

#pragma mark - VoewController Methods -

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// load color picker view
	self.colorPickerView = [[NSBundle mainBundle] loadNibNamed:@"RTEColorPicker" owner:RTEColorPickerView.class options:nil][0];
	
	// add
	self.colorPickerView.translatesAutoresizingMaskIntoConstraints = false;
	[self.view addSubview:self.colorPickerView];
	[self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.colorPickerView
															 attribute:NSLayoutAttributeTop
															 relatedBy:NSLayoutRelationEqual
																toItem:self.view
															 attribute:NSLayoutAttributeTop
															multiplier:1
															  constant:0],
								[NSLayoutConstraint constraintWithItem:self.colorPickerView
															 attribute:NSLayoutAttributeLeft
															 relatedBy:NSLayoutRelationEqual
																toItem:self.view
															 attribute:NSLayoutAttributeLeft
															multiplier:1
															  constant:0],
								[NSLayoutConstraint constraintWithItem:self.colorPickerView
															 attribute:NSLayoutAttributeBottom
															 relatedBy:NSLayoutRelationEqual
																toItem:self.view
															 attribute:NSLayoutAttributeBottom
															multiplier:1
															  constant:0],
								[NSLayoutConstraint constraintWithItem:self.colorPickerView
															 attribute:NSLayoutAttributeRight
															 relatedBy:NSLayoutRelationEqual
																toItem:self.view
															 attribute:NSLayoutAttributeRight
															multiplier:1
															  constant:0]]];
	
	// set predefined colors
	if(self.dataSource && [self.dataSource respondsToSelector:@selector(predefinedColorsForColorPickerViewController:)]) {
		self.colorPickerView.predefinedColors = [self.dataSource predefinedColorsForColorPickerViewController:self];
	} else {
		self.colorPickerView.predefinedColors = @[];
	}
	
	// set action and delegate
	self.colorPickerView.action = self.action;
	self.colorPickerView.delegate = self.delegate;
	
	// set content size
	CGSize contentSize = self.colorPickerView.minimumSize;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
	self.preferredContentSize = contentSize;
#else
	self.contentSizeForViewInPopover = contentSize;
#endif
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	// save recent color
	[self.colorPickerView saveRecentColor];
}

@end

