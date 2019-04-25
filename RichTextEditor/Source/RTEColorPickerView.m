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
#import "RTEColorBlockCell.h"
#import "RTEAddColorCell.h"
#import "UIColor+RichTextEditor.h"
#import "RTELocalization.h"

@interface RTEColorPickerView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *colorsImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *selectedColorView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *backButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *customPanel;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *blockPanel;
@property (unsafe_unretained, nonatomic) IBOutlet UICollectionView *predefinedCollectionView;
@property (unsafe_unretained, nonatomic) IBOutlet UICollectionView *recentCollectionView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *predefinedColorsLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *recentUsedColorsLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UISlider *alphaSlider;
@property (nonatomic, strong) NSIndexPath* selectedColorIndexPath;
@property (nonatomic, assign) UICollectionView* activeCollectionView;
@property (nonatomic, strong) NSMutableArray<NSString*>* recentColors;
@property (nonatomic, assign) BOOL colorChanged;

// selected color in block panel
@property (nonatomic, assign, readonly) UIColor* selectedBlockColor;

- (IBAction)onBackClicked:(id)sender;
- (IBAction)onAlphaChanged:(id)sender;

@end

@implementation RTEColorPickerView

- (void)awakeFromNib {
	[super awakeFromNib];
	
	// init
	self.predefinedColors = @[];
	self.activeCollectionView = self.predefinedCollectionView;
	self.recentColors = [NSMutableArray array];
	
	// border
	self.colorsImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
	self.colorsImageView.layer.borderWidth = 1;
	self.selectedColorView.layer.borderColor = [UIColor lightGrayColor].CGColor;
	self.selectedColorView.layer.borderWidth = 1;
	
	// hide custom panel first
	self.customPanel.hidden = true;
	
	// text
	self.predefinedColorsLabel.text = _RTE_L(@"predefined.colors");
	self.recentUsedColorsLabel.text = _RTE_L(@"recently.used.colors");
	
	// default columns
	self.colorColumns = 11;
	
	// default alpha
	self.alphaSlider.value = 1;
	
	// collection view
	[self.predefinedCollectionView registerNib:[UINib nibWithNibName:@"RTEColorBlock" bundle:[NSBundle mainBundle]]
					forCellWithReuseIdentifier:@"block"];
	UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.predefinedCollectionView.collectionViewLayout;
	layout.itemSize = CGSizeMake(28, 28);
	layout.minimumLineSpacing = 1;
	layout.minimumInteritemSpacing = 1;
	[self.recentCollectionView registerNib:[UINib nibWithNibName:@"RTEColorBlock" bundle:[NSBundle mainBundle]]
				forCellWithReuseIdentifier:@"block"];
	[self.recentCollectionView registerNib:[UINib nibWithNibName:@"RTEAddColor" bundle:[NSBundle mainBundle]]
				forCellWithReuseIdentifier:@"add"];
	layout = (UICollectionViewFlowLayout*)self.recentCollectionView.collectionViewLayout;
	layout.itemSize = CGSizeMake(28, 28);
	layout.minimumLineSpacing = 1;
	layout.minimumInteritemSpacing = 1;
}

- (CGSize)minimumSize {
	// total height, width
	CGFloat height = 0, width = 0;

	// layout of predefined colors
	UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.predefinedCollectionView.collectionViewLayout;
	
	// width
	width = self.colorColumns * layout.itemSize.width + (self.colorColumns - 1) * layout.minimumInteritemSpacing;
	
	// label height
	height += self.predefinedColorsLabel.frame.size.height;
	height += 2;
	
	// get rows of predefined colors
	NSInteger rows = (self.predefinedColors.count + self.colorColumns - 1) / self.colorColumns;
	height += rows * layout.itemSize.height;
	height += (rows - 1) * layout.minimumLineSpacing;
	
	// recent label
	height += 5;
	height += self.recentUsedColorsLabel.frame.size.height;
	height += 2;
	
	// recent colors use one row
	height += layout.itemSize.height;
	
	// return
	return CGSizeMake(width, height);
}

- (UIColor *)selectedBlockColor {
	if(self.selectedColorIndexPath) {
		NSString* str = self.activeCollectionView == self.predefinedCollectionView ? self.predefinedColors[self.selectedColorIndexPath.row] : self.recentColors[self.selectedColorIndexPath.row];
		return [UIColor rte_colorWithHexString:str];
	}
	return nil;
}

- (void)setAction:(RichTextEditorColorPickerAction)action {
	_action = action;
	
	// reload recent used colors
	NSString* key = action == RichTextEditorColorPickerActionTextForegroudColor ? @"rte_fg_recent" : @"rte_bg_recent";
	NSUserDefaults* d = [NSUserDefaults standardUserDefaults];
	NSData* data = [d objectForKey:key];
	NSArray* arr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	[self.recentColors removeAllObjects];
	[self.recentColors addObjectsFromArray:arr];
	
	// reload ui
	[self.recentCollectionView reloadData];
}

- (void)saveRecentColor {
	if(self.colorChanged) {
		NSString* colorStr = [UIColor rte_hexValuesFromUIColor:self.selectedColorView.backgroundColor];
		[self.recentColors removeObject:colorStr];
		[self.recentColors insertObject:colorStr atIndex:0];
		while (self.recentColors.count > self.colorColumns - 1) {
			[self.recentColors removeLastObject];
		}
		NSString* key = self.action == RichTextEditorColorPickerActionTextForegroudColor ? @"rte_fg_recent" : @"rte_bg_recent";
		NSUserDefaults* d = [NSUserDefaults standardUserDefaults];
		NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self.recentColors];
		[d setObject:data forKey:key];
		[d synchronize];
	}
}

- (IBAction)onBackClicked:(id)sender {
	// show block panel
	self.blockPanel.hidden = false;
	self.customPanel.hidden = true;
	
	// if color is changed in custom panel, clear selection of block panel
	if(![self.selectedColorView.backgroundColor isEqual:self.selectedBlockColor]) {
		self.selectedColorIndexPath = nil;
		[self.activeCollectionView reloadData];
	}
}

- (IBAction)onAlphaChanged:(id)sender {
	self.selectedColorView.backgroundColor = [self.selectedColorView.backgroundColor colorWithAlphaComponent:self.alphaSlider.value];
	self.colorChanged = true;
	[self.delegate richTextEditorColorPickerViewControllerDidSelectColor:self.selectedColorView.backgroundColor
															  withAction:self.action];
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
	self.colorChanged = true;
	[self.delegate richTextEditorColorPickerViewControllerDidSelectColor:self.selectedColorView.backgroundColor
															  withAction:self.action];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint locationPoint = [[touches anyObject] locationInView:self.colorsImageView];
	[self populateColorsForPoint:locationPoint];
	self.colorChanged = true;
	[self.delegate richTextEditorColorPickerViewControllerDidSelectColor:self.selectedColorView.backgroundColor
															  withAction:self.action];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	NSString* type = @"block";
	if(collectionView == self.recentCollectionView && indexPath.row >= self.recentColors.count) {
		type = @"add";
	}
	if([@"block" isEqualToString:type]) {
		if(![indexPath isEqual:self.selectedColorIndexPath]) {
			// set selected index path
			NSIndexPath* oldSelected = self.selectedColorIndexPath;
			self.selectedColorIndexPath = indexPath;
			
			// change active collection view
			UICollectionView* oldActive = self.activeCollectionView;
			self.activeCollectionView = collectionView;
			
			// reload old
			if(oldSelected) {
				[oldActive reloadItemsAtIndexPaths:@[oldSelected]];
			}
			
			// reload new
			[collectionView reloadItemsAtIndexPaths:@[indexPath]];
			
			// delegate
			self.selectedColorView.backgroundColor = self.selectedBlockColor;
			self.colorChanged = true;
			[self.delegate richTextEditorColorPickerViewControllerDidSelectColor:self.selectedColorView.backgroundColor
																	  withAction:self.action];
		}
	} else if([@"add" isEqualToString:type]) {
		// show custom panel
		self.blockPanel.hidden = true;
		self.customPanel.hidden = false;
	}
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	if(collectionView == self.predefinedCollectionView) {
		return self.predefinedColors.count;
	} else {
		return self.recentColors.count + 1;
	}
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	NSString* type = @"block";
	if(collectionView == self.recentCollectionView && indexPath.row >= self.recentColors.count) {
		type = @"add";
	}
	UICollectionViewCell* c = [collectionView dequeueReusableCellWithReuseIdentifier:type forIndexPath:indexPath];
	if([@"block" isEqualToString:type]) {
		NSString* colorStr = collectionView == self.predefinedCollectionView ? self.predefinedColors[indexPath.row] : self.recentColors[indexPath.row];
		RTEColorBlockCell* cell = (RTEColorBlockCell*)c;
		if(self.activeCollectionView == collectionView && [indexPath isEqual:self.selectedColorIndexPath]) {
			cell.borderView.layer.borderColor = [UIColor blueColor].CGColor;
		} else {
			cell.borderView.layer.borderColor = [UIColor clearColor].CGColor;
		}
		cell.colorView.backgroundColor = [UIColor rte_colorWithHexString:colorStr];
	}
	return c;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

@end
