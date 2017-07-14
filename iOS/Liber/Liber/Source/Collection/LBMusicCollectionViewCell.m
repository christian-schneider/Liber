//
//  LBMusicCollectionViewCell.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBMusicCollectionViewCell.h"


@implementation LBMusicCollectionViewCell

/* might or might not be necessary anymore with iOS 10+ 
 sometimes the on device rotation, the cells were not adapting their new size correctly
 from: https://stackoverflow.com/questions/25804588/auto-layout-in-uicollectionviewcell-not-working 
*/

- (void)setBounds:(CGRect)bounds {
 
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}

@end
