//
//  Level.m
//  TP2
//
//  Created by AdminMacLC02 on 11/28/13.
//  Copyright (c) 2013 bb. All rights reserved.
//

#import "Level.h"

@implementation Level

- (id)initWithLevelNum:(int)levelNum enemiesNum:(int)enemiesNum secsPerSpawn:(float)secsPerSpawn backgroundColor:(ccColor4B)backgroundColor{
    if ((self = [super init])) {
        self.levelNum = levelNum;
        self.secsPerSpawn = secsPerSpawn;
        self.backgroundColor = backgroundColor;
        self.enemiesNum = enemiesNum;
        self.enemiesSpawned = 0;
        self.enemiesKilled = 0;
    }
    return self;
}
@end