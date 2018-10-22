//
//  RichTextEditorFontSizePickerViewController.m
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

#import "RichTextEditorFontSizePickerViewController.h"

@interface RichTextEditorFontSizePickerViewController ()

@property (nonatomic, assign) int maxVisibleFontSize;

@end

@implementation RichTextEditorFontSizePickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.maxVisibleFontSize = 0;
	NSArray *customizedFontSizes = [self.dataSource richTextEditorFontSizePickerViewControllerCustomFontSizesForSelection];
	
	if (customizedFontSizes)
		self.fontSizes = customizedFontSizes;
	else
		self.fontSizes = @[@8, @10, @12, @14, @16, @18, @20, @22, @24, @26, @28, @30];
	
	self.tableview.frame = self.view.bounds;
	
	[self.view addSubview:self.tableview];
	
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
    
    self.preferredContentSize = CGSizeMake(200, 400);
#else
    
	self.contentSizeForViewInPopover = CGSizeMake(200, 400);
#endif

}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	// show selected font
	NSInteger idx = [self.fontSizes indexOfObject:@(self.dataSource.lastSelectedFontSize)];
	if(idx != -1) {
		NSIndexPath* idxPath = [NSIndexPath indexPathForRow:idx inSection:0];
		[self.tableview scrollToRowAtIndexPath:idxPath
							  atScrollPosition:UITableViewScrollPositionMiddle
									  animated:false];
	}
}

#pragma mark - IBActions -

- (void)closeSelected:(id)sender
{
	[self.delegate richTextEditorFontSizePickerViewControllerDidSelectClose];
}

#pragma mark - UITableView Delegate & Datasrouce -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.fontSizes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"FontSizeCell";
	
	NSNumber *fontSize = [self.fontSizes objectAtIndex:indexPath.row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (!cell)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	
	cell.textLabel.text = fontSize.stringValue;
	cell.textLabel.font = [UIFont boldSystemFontOfSize:fontSize.intValue];
	cell.textLabel.adjustsFontSizeToFitWidth = true;
	cell.textLabel.numberOfLines = 1;
	cell.textLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSNumber *fontSize = [self.fontSizes objectAtIndex:indexPath.row];
	[self.delegate richTextEditorFontSizePickerViewControllerDidSelectFontSize:fontSize];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	int fontSize = [self.fontSizes[indexPath.row] intValue];
	NSString* str = [NSString stringWithFormat:@"%d", fontSize];
	if(self.maxVisibleFontSize > 0 && fontSize > self.maxVisibleFontSize) {
		fontSize = self.maxVisibleFontSize;
	}
	CGRect rect = [str boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
									options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
								 attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]}
									context:nil];
	if(rect.size.width < tableView.bounds.size.width) {
		return MAX(32, rect.size.height);
	} else {
		if(self.maxVisibleFontSize == 0) {
			self.maxVisibleFontSize = fontSize;
		}
		rect = [str boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
								 options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
							  attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:self.maxVisibleFontSize]}
								 context:nil];
		return rect.size.height;
	}
}

#pragma mark - Setter & Getter -

- (UITableView *)tableview
{
	if (!_tableview)
	{
		_tableview = [[UITableView alloc] initWithFrame:self.view.bounds];
		_tableview.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_tableview.delegate = self;
		_tableview.dataSource = self;
	}
	
	return _tableview;
}

@end
