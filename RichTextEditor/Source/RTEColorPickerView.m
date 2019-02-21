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

#import "RTEColorPickerView.h"
#import "UIView+RichTextEditor.h"

@interface RTEColorPickerView ()

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *colorsImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *selectedColorView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *backButton;

- (IBAction)onBackClicked:(id)sender;

@end

@implementation RTEColorPickerView

- (void)awakeFromNib {
	[super awakeFromNib];
	
	// init
	self.colorsImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
	self.colorsImageView.layer.borderWidth = 1;
	self.selectedColorView.layer.borderColor = [UIColor lightGrayColor].CGColor;
	self.selectedColorView.layer.borderWidth = 1;
	self.backButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
	self.backButton.layer.borderWidth = 1;
}

#pragma mark - Private Methods -

- (void)populateColorsForPoint:(CGPoint)point
{
	self.selectedColorView.backgroundColor = [self.colorsImageView colorOfPoint:point];
}

#pragma mark - Touch Detection -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint locationPoint = [[touches anyObject] locationInView:self.colorsImageView];
	[self populateColorsForPoint:locationPoint];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint locationPoint = [[touches anyObject] locationInView:self.colorsImageView];
	[self populateColorsForPoint:locationPoint];
}

- (IBAction)onBackClicked:(id)sender {
}

@end
