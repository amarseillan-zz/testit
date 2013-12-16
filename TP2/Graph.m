 //
//  Graph.m
//  HalfLife2D
//
//  Created by AdminMacLC02 on 10/31/13.
//  Copyright 2013 AdminMacLC04. All rights reserved.
//

#import "Graph.h"


@implementation Graph


-(void)addNode:(CGPoint)point {
    [_nodes addObject: [[Node alloc] initWith:point]];
}

-(id)initWithMap:(CCTMXTiledMap*) tileMap {
    self = [super init];
    
    if (self != nil) {
        width = tileMap.mapSize.width;
        height = tileMap.mapSize.height;
        
        self.nodes = [[NSMutableArray alloc] init];
        for (int i = 0; i < width; i++) {
            for (int j = 0; j < height; j++) {
                
                CCTMXLayer* background = [tileMap layerNamed:@"Background"];
                uint32_t tileGID = [background tileGIDAt:CGPointMake(i, height - 1 - j)];
                NSDictionary* properties = [tileMap propertiesForGID:tileGID];
                
                if (![[properties objectForKey: @"Walkable"] isEqualToString:@"False"]) {
                    [self addNode:ccp(i,j)];
                } else {
                    [self.nodes addObject: [NSNull null]];
                }
            }
        }
        
        for (Node* node in _nodes) {
            
            if (node == (id)[NSNull null]) {
                continue;
            }
            NSArray* directions = [[NSArray alloc] initWithObjects:[NSValue valueWithCGPoint:ccp(0,1)], [NSValue valueWithCGPoint:ccp(0,-1)], [NSValue valueWithCGPoint:ccp(1,0)], [NSValue valueWithCGPoint:ccp(-1,0)], nil ];
            
            for (NSValue* value in directions) {
            
                if (value != (id)[NSNull null]) {
                    int neighbourX = node.x + [value CGPointValue].x;
                    int neighboiurY = node.y + [value CGPointValue].y;
                    
                    if (neighbourX < 0 || neighbourX >= width || neighboiurY < 0 || neighboiurY >= height) {
                        continue;
                    }
                    Node *neighbour = [_nodes objectAtIndex:(neighbourX*height + neighboiurY)];
                    if (neighbour != (id)[NSNull null]) {
                        [node.edges addObject: [[Edge alloc] initWith: neighbour cost:0]];
                    }
                }
            }
        }
    
    }
    return self;
}

- (void)printPath:(NSArray *)path {
    NSMutableString *str = [NSMutableString string];
    [str appendString:@"(\n"];
    for (Node *node in path) {
        [str appendFormat:@"\t[%d %d]\n", node.x, node.y];
    }
    [str appendString:@")"];
    NSLog(@"%@", str);
}

- (NSMutableArray*) findPathFrom:(Node*)start to:(Node*)end {

    NSMutableArray* closedList = [[NSMutableArray alloc] init];  //closedList
    NSMutableArray* frontier = [[NSMutableArray alloc] init]; //openList
    Node* lowestNode = nil;
    
    if (start == nil || start == (id)[NSNull null]) {
        return closedList;
    }
    start.g = 0;
//    NSLog(@"%@", start.parent);
    start.h = [self calcH:start toReach:end];
    if (start.parent != nil)
//    NSLog(@"%d ,%d", start.parent.x, start.parent.y);
    start.parent = nil;
    [frontier addObject:start];
    while(lowestNode != end && frontier.count > 0) {
        lowestNode = [self getMinimumFNode:frontier];
        [frontier removeObject:lowestNode];
        [closedList addObject:lowestNode];
        
//        NSLog(@"a-start %d, %d", lowestNode.x, lowestNode.y);
        for (Edge* edge in lowestNode.edges) {
            
            Node* childNode = edge.b;
            if ([closedList containsObject:childNode]) {
                continue;
            }
            
            bool visited = [frontier containsObject:childNode];
            if (!visited) {
                childNode.parent = lowestNode;
                childNode.g = lowestNode.g + 1;
                childNode.h = [self calcH:childNode toReach:end];
                [frontier addObject:childNode];
            } else {
                if (lowestNode.g + 1 < childNode.g) {
                    childNode.parent = lowestNode;
                    childNode.g = lowestNode.g + 1;
                }
            }            
        }
    }
    
    if (lowestNode != end) {
        end = [self getMinimumHNode:closedList];
    }
    
    NSMutableArray* retPath = [NSMutableArray array];
    Node* last = end;
    while (last != nil) {
//        NSLog(@"%d", retPath.count);
        [retPath insertObject:last atIndex:0];
        last = last.parent;
    }
    return retPath;
}

-(Node*) getMinimumFNode:(NSMutableArray*)frontier {
    int minF = INFINITY;
    Node* minFNode = nil;
    for (Node* node in frontier) {
        if (node.g + node.h < minF) {
            minF = node.g + node.h;
            minFNode = node;
        }
    }
    return minFNode;
}

-(Node*) getMinimumHNode:(NSMutableArray*) closedList {
    int minH = INFINITY;
    Node* minHNode = nil;
    for (Node* node in closedList) {
        
//        NSLog(@"minH - %d, %d, %d", node.x, node.y, node.h);
        if (node.h < minH) {
            minH = node.h;
            minHNode = node;
        }
    }
    return minHNode;
}

-(int) calcH:(Node*)node toReach:(Node*)end {
    return abs(end.x - node.x) + abs(end.y - node.y);
}

-(Node*) nodeForIndex:(int)index {
    return [_nodes objectAtIndex:index];
}
@end

@implementation Edge

-(id)initWith:(Node*)to cost:(float)cost {
    self = [super init];
    
    if (self != nil) {
        self.b = to;
        self.cost = cost;
    }
    return self;
}
@end

@implementation Node

-(id)initWith:(CGPoint)point {
    self = [super init];
    
    if (self != nil) {
        self.x = point.x;
        self.y = point.y;
        self.edges = [[NSMutableArray alloc] init];
    }
    return self;
}

-(CGPoint)getCoordinates {
    return ccp(self.x,self.y);
}
@end
