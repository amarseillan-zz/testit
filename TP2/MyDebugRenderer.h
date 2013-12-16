//
//  DebugRenderer.h
//  tilegame
//
//  Created by AdminMacLC02 on 11/7/13.
//  Copyright (c) 2013 charlie. All rights reserved.
//

#import "cocos2d.h"
#import "Graph.h"

@interface MyDebugRenderer : CCNode

@property (nonatomic, weak) Graph *graph;
@property (nonatomic) CGSize tileSize;

- (id)initWithGraph:(Graph *)graph tileSize:(CGSize)tileSize;
- (void)draw;
@end
