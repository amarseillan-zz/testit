//
//  Graph.h
//  HalfLife2D
//
//  Created by AdminMacLC02 on 10/31/13.
//  Copyright 2013 AdminMacLC04. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Node : NSObject

@property (nonatomic) int x;
@property (nonatomic) int y;
@property (nonatomic,strong) NSMutableArray* edges;
@property (nonatomic,strong) Node* parent;
@property (nonatomic) int g;
@property (nonatomic) int h;

-(id)initWith:(CGPoint)point;
-(CGPoint)getCoordinates;
@end

@interface Edge : NSObject

//@property (nonatomic, weak) Node* a;
@property (nonatomic, weak) Node* b;
@property (nonatomic) float cost;

-(id)initWith:(Node*)to cost:(float)cost;

@end

@interface Graph : NSObject {

    int width;
    int height;
}

@property (nonatomic, strong) NSMutableArray* nodes;


-(id)initWithMap:(CCTMXTiledMap*) tileMap;

-(NSMutableArray*) findPathFrom:(Node*)start to:(Node*)end;

- (void)printPath:(NSArray *)path;

-(Node*) nodeForIndex:(int)index;
@end
