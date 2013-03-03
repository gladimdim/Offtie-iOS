//
//  CollectionViewCustomLayout.m
//  Offtie
//
//  Created by Dmytro Gladkyi on 12/18/12.
//  Copyright (c) 2012 Dmytro Gladkyi. All rights reserved.
//

#import "CollectionViewCustomLayout.h"

@implementation CollectionViewCustomLayout


-(CGSize) collectionViewContentSize {
    CGRect winRect = self.collectionView.bounds;
    CGSize winSize = winRect.size;
    winSize.width = winSize.width * [self.collectionView numberOfItemsInSection:0];
    return winSize;
}

@end
