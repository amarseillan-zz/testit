//
//  Level.h
//  TP2
//
//  Created by AdminMacLC02 on 11/28/13.
//  Copyright (c) 2013 bb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Level : NSObject

@property (nonatomic, assign) int levelNum;
@property (nonatomic, assign) int enemiesNum;
@property (nonatomic, assign) int enemiesSpawned;
@property (nonatomic, assign) int enemiesKilled;
@property (nonatomic, assign) float secsPerSpawn;
@property (nonatomic, assign) ccColor4B backgroundColor;

- (id)initWithLevelNum:(int)levelNum enemiesNum:(int)enemiesNum secsPerSpawn:(float)secsPerSpawn backgroundColor:(ccColor4B)backgroundColor;
@end

