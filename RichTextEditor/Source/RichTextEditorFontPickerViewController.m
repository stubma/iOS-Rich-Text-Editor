//
//  RichTextEditorFontViewController.m
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

#import "RichTextEditorFontPickerViewController.h"

@implementation RichTextEditorFontPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSArray *customizedFontFamilies = [self.dataSource richTextEditorFontPickerViewControllerCustomFontFamilyNamesForSelection];
	
	if (customizedFontFamilies) {
		self.fontNames = customizedFontFamilies;
	} else {
		self.fontNames = [[UIFont familyNames] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    }
	
	self.tableview.frame = self.view.bounds;
	
	[self.view addSubview:self.tableview];
	
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
    
    self.preferredContentSize = CGSizeMake(250, 400);
#else
    
	self.contentSizeForViewInPopover = CGSizeMake(250, 400);
#endif

}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	// show last selected font name
	NSInteger idx = [self.fontNames indexOfObject:self.dataSource.lastSelectedFontName];
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
	[self.delegate richTextEditorFontPickerViewControllerDidSelectClose];
}

#pragma mark - UITableView Delegate & Datasrouce -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.fontNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"FontSizeCell";
	
	NSString *fontName = [self.fontNames objectAtIndex:indexPath.row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (!cell)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	
	cell.textLabel.text = fontName;
	cell.textLabel.font = [UIFont fontWithName:fontName size:16];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *fontName = [self.fontNames objectAtIndex:indexPath.row];
	[self.delegate richTextEditorFontPickerViewControllerDidSelectFontWithName:fontName];
}

#pragma mark - Setter & Getter -

- (UITableView *)tableview
{
	if (!_tableview)
	{
		_tableview = [[UITableView alloc] initWithFrame:self.view.bounds];
		_tableview.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		_tableview.delegate = self;
		_tableview.dataSource = self;
	}

	return _tableview;
}

@end
