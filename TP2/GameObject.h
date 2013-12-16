//
//  GameObject.h
//  Cocos2DSimpleGame
//
//  Created by AdminMacLC04 on 9/19/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "cocos2d.h"

@interface GameObject : CCPhysicsSprite

@property bool active;

- (id)initWithFile:(NSString *)filename;
- (id)initWithSpriteFrameName:(NSString *)spriteFrameName;

@end
