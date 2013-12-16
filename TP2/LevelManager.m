//
//  LevelManager.m
//  TP2
//
//  Created by AdminMacLC02 on 11/28/13.
//  Copyright (c) 2013 bb. All rights reserved.
//

#import "LevelManager.h"

@implementation LevelManager

+ (LevelManager*)sharedManager {
    static LevelManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        _levelNum = 0;
        _godMode = false;
        _lives = 1;
        _comboCounter = 0;
        _winSize = [CCDirector sharedDirector].winSize;
        _ammo = -1;
        _shotgunMaxAmmo = 30;
        
        Level * level1 = [[Level alloc] initWithLevelNum:1 enemiesNum:10 secsPerSpawn:15 backgroundColor:ccc4(255, 255, 255, 255)];
        Level * level2 = [[Level alloc] initWithLevelNum:2 enemiesNum:100 secsPerSpawn:10 backgroundColor:ccc4(100, 150, 20, 255)];
//        Level * level3 = [[Level alloc] initWithLevelNum:3 enemiesNum:15 secsPerSpawn:0.5 backgroundColor:ccc4(20, 150, 100, 255)];
        _levels = @[level1, level2];
    }
    return self;
}

- (Level *)curLevel {
    if (_levelNum >= _levels.count) {
        return nil;
    }
    return _levels[_levelNum];
}

- (void)reset {
    _levelNum = 0;
    _lives = 3;
    _comboCounter = 0;
    Level * level1 = [[Level alloc] initWithLevelNum:1 enemiesNum:10 secsPerSpawn:15 backgroundColor:ccc4(255, 255, 255, 255)];
    Level * level2 = [[Level alloc] initWithLevelNum:2 enemiesNum:100 secsPerSpawn:10 backgroundColor:ccc4(100, 150, 20, 255)];
    //        Level * level3 = [[Level alloc] initWithLevelNum:3 enemiesNum:15 secsPerSpawn:0.5 backgroundColor:ccc4(20, 150, 100, 255)];
    _levels = @[level1, level2];
}

- (void)reduceAmmo:(int)amount {
    _ammo -= amount;
    if (_ammo  < 0) {
        _ammo = 0;
    }
}

- (void)loadAmmo:(int)amount {
    _ammo += amount;
    if (_ammo  > _shotgunMaxAmmo) {
        _ammo = _shotgunMaxAmmo;
    }
}
@end