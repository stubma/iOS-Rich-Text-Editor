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
#import "UIColor+RichTextEditor.h"

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

- (IBAction)onBackClicked:(id)sender;

@end

@implementation RTEColorPickerView

- (void)awakeFromNib {
	[super awakeFromNib];
	
	// border
	self.colorsImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
	self.colorsImageView.layer.borderWidth = 1;
	self.selectedColorView.layer.borderColor = [UIColor lightGrayColor].CGColor;
	self.selectedColorView.layer.borderWidth = 1;
	self.backButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
	self.backButton.layer.borderWidth = 1;
	
	// hide custom panel first
	self.customPanel.hidden = true;
	
	// default columns
	self.colorColumns = 10;
	
	// collection view
	[self.predefinedCollectionView registerNib:[UINib nibWithNibName:@"RTEColorBlock" bundle:[NSBundle mainBundle]]
					forCellWithReuseIdentifier:@"block"];
	UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.predefinedCollectionView.collectionViewLayout;
	layout.itemSize = CGSizeMake(24, 24);
	layout.minimumLineSpacing = 2;
	layout.minimumInteritemSpacing = 2;
	[self.recentCollectionView registerNib:[UINib nibWithNibName:@"RTEColorBlock" bundle:[NSBundle mainBundle]]
				forCellWithReuseIdentifier:@"block"];
	layout = (UICollectionViewFlowLayout*)self.recentCollectionView.collectionViewLayout;
	layout.itemSize = CGSizeMake(24, 24);
	layout.minimumLineSpacing = 2;
	layout.minimumInteritemSpacing = 2;
}

- (CGSize)minimumSize {
	// total height, width
	CGFloat height = 0, width = 0;

	// layout of predefined colors
	UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.predefinedCollectionView.collectionViewLayout;
	
	// width
	width = self.colorColumns * layout.itemSize.width + (self.colorColumns - 1) * layout.minimumLineSpacing;
	
	// the predefined colors must be set to evaluate size
	if(self.predefinedColors) {
		// label height
		height += self.predefinedColorsLabel.frame.size.height;
		height += 2;
		
		// get rows of predefined colors
		NSInteger rows = (self.predefinedColors.count + self.colorColumns - 1) / self.colorColumns;
		height += rows * layout.itemSize.height;
		height += (rows - 1) * layout.minimumInteritemSpacing;
	}
	
	// recent label
	height += 5;
	height += self.recentUsedColorsLabel.frame.size.height;
	height += 2;
	
	// recent colors use one row
	height += layout.itemSize.height;
	
	// return
	return CGSizeMake(width, height);
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

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	if(collectionView == self.predefinedCollectionView) {
		return self.predefinedColors.count;
	} else {
		return 0;
	}
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	UICollectionViewCell* c = [collectionView dequeueReusableCellWithReuseIdentifier:@"block" forIndexPath:indexPath];
	if(collectionView == self.predefinedCollectionView) {
		NSString* colorStr = self.predefinedColors[indexPath.row];
		RTEColorBlockCell* cell = (RTEColorBlockCell*)c;
		cell.colorView.backgroundColor = [UIColor rte_colorWithHexString:colorStr];
	}
	return c;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

@end
