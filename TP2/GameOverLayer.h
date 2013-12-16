//
//  GameOverLayer.h
//  TP2
//
//  Created by AdminMacLC02 on 11/27/13.
//  Copyright (c) 2013 bb. All rights reserved.
//

#import "cocos2d.h"

@interface GameOverLayer : CCLayerColor
{
    CCLayerColor* _callerLayer;
}

+(CCScene *) sceneWithWon:(BOOL)won caller:(CCLayerColor*)caller;
- (id)initWithWon:(BOOL)won caller:(CCLayerColor*)callerLayer;

@end