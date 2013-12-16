//
//  DebugRenderer.m
//  tilegame
//
//  Created by AdminMacLC02 on 11/7/13.
//  Copyright (c) 2013 charlie. All rights reserved.
//

#import "MyDebugRenderer.h"

@implementation MyDebugRenderer

- (id)initWithGraph:(Graph *)graph tileSize:(CGSize)tileSize {
    self = [super init];
    
    if (self != nil) {
        _graph = graph;
        _tileSize = tileSize;
    }
    
    return self;
}

- (void)draw {
    [super draw];
    
    ccDrawColor4B(255, 255, 255, 255);
    glLineWidth(2);
    
    for (Node *node in _graph.nodes) {
        if (node != (id)[NSNull null]) {
            for (Edge *edge in node.edges) {

                CGPoint p1 = ccp(node.x * _tileSize.width + _tileSize.width / 2, node.y * _tileSize.height + _tileSize.height / 2);
                CGPoint p2 = ccp(edge.b.x * _tileSize.width + _tileSize.width / 2, edge.b.y * _tileSize.height + _tileSize.height / 2);
                drawArrowShrinked(p1, p2, 6, 0.6f);
            }
        }
    }
}


void drawArrow(CGPoint start, CGPoint end, float size) {
    // get the arrow dir and normal
    CGPoint dir = ccpMult(ccpNormalize(ccpSub(end, start)), size);
    CGPoint nor = ccpMult(ccp(dir.y, -dir.x), 0.6f);
    
    // render the arrow segment
    ccDrawLine(start, end);
    
    // render the first side of the arrow
    CGPoint arrow = ccpAdd(ccpSub(end, dir), nor);
    ccDrawLine(end, arrow);
    
    // render the second side of the arrow
    arrow = ccpSub(ccpSub(end, dir), nor);
    ccDrawLine(end, arrow);
}

void drawArrowShrinked(CGPoint start, CGPoint end, float size, float shrink) {
    CGPoint mid = ccpMult(ccpAdd(start, end), 0.5f);
    start = ccpAdd(mid, ccpMult(ccpSub(start, mid), shrink));
    end = ccpAdd(mid, ccpMult(ccpSub(end, mid), shrink));
    drawArrow(start, end, size);
}


@end
