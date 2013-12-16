//
//  Enemy.h
//  TP2
//
//  Created by AdminMacLC02 on 11/21/13.
//  Copyright (c) 2013 bb. All rights reserved.
//

#import "GameObject.h"
#import "GameLayer.h"

@interface Enemy : GameObject {
    NSMutableArray* _path;
    GameLayer * _gameLayer;
    float _speed;
    CGPoint _lastPlayerPosition;
}

@property (nonatomic, strong) ChipmunkShape *shape;

- (id)initWithLayer:(GameLayer *)layer;
@end
