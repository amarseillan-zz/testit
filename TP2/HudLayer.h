//
//  HudLayer.h
//  TP2
//
//  Created by AdminMacLC02 on 11/21/13.
//  Copyright (c) 2013 bb. All rights reserved.
//

#import "cocos2d.h"
#import "GameLayer.h"
#import "Level.h"
#import "SneakyJoystick.h"
#import "SneakyJoystickSkinnedBase.h"

@interface HudLayer : CCLayerColor

@property (nonatomic) GameLayer * gameLayer;
@property int monstersDestroyed;
@property (nonatomic) Level* level;
@property int lives;
@property int comboCounter;
@property SneakyJoystick *leftJoystick;

- (void)numCollectedChanged:(int)numCollected;

- (void)projectileButtonTapped:(id)sender;

- (void)updateEnemyCounter:(int)num;
@end
