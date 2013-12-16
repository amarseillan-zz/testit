//
//  GameOverLayer.m
//  TP2
//
//  Created by AdminMacLC02 on 11/27/13.
//  Copyright (c) 2013 bb. All rights reserved.
//

#import "GameOverLayer.h"
#import "HelloWorldLayer.h"
#import "GameLayer.h"
#import "LevelManager.h"

@implementation GameOverLayer

+(CCScene *) sceneWithWon:(BOOL)won caller:(CCLayerColor*)callerLayer {
    CCScene *scene = [CCScene node];
    GameOverLayer *layer = [[GameOverLayer alloc] initWithWon:won caller:callerLayer];
    [scene addChild: layer];
    return scene;
}

- (id)initWithWon:(BOOL)won caller:(CCLayerColor*) callerLayer {
    
    
    if ((self = [super initWithColor:ccc4(255, 255, 255, 255)])) {
        
        _callerLayer = callerLayer;
        CCSprite* image;
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        if (won) {
//            [LevelManager sharedManager].levelNum++;
//            Level * curLevel = [[LevelManager sharedManager] curLevel];
//            if (curLevel) {
//                message = [NSString stringWithFormat:@"Get ready for level %d!", curLevel.levelNum];
//                [LevelManager sharedManager].lives = ((HelloWorldLayer*)_callerLayer).lives;
//                [LevelManager sharedManager].comboCounter = ((HelloWorldLayer*)_callerLayer).comboCounter;
//            } else {
            image = [[CCSprite alloc] initWithFile:@"Brix_Winning_Screen.bmp"];
            [[LevelManager sharedManager] reset];
//            }
        } else {
            image = [[CCSprite alloc] initWithFile:@"Brix_Losing_Screen.bmp"];
            [[LevelManager sharedManager] reset];
        }
        [image setScaleX:winSize.width/ image.contentSize.width];
        [image setScaleY:winSize.height/ image.contentSize.height];
        image.position = ccp(winSize.width/2,winSize.height/2);
        [self addChild:image];
        
        [self runAction:
         [CCSequence actions:
          [CCDelayTime actionWithDuration:6],
          [CCCallBlockN actionWithBlock:^(CCNode *node) {
             [[CCDirector sharedDirector] replaceScene:[GameLayer scene]];
         }],
          nil]];
    }
    return self;
}

@end
