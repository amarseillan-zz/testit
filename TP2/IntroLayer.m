//
//  IntroLayer.m
//  Cocos2DSimpleGame
//
//  Created by Ray Wenderlich on 11/13/12.
//  Copyright Razeware LLC 2012. All rights reserved.
//

#import "IntroLayer.h"
#import "GameLayer.h"
#import "HelloWorldLayer.h"

@implementation IntroLayer

+ (CCScene *)scene {
    CCScene *scene = [CCScene node];
    IntroLayer *layer = [IntroLayer node];
    
    // add layer as a child to scene
    [scene addChild: layer];
    
    // return the scene
    return scene;
}

- (id)init {
    self = [super init];
    
    if (self != nil) {
        // ask director for the window size
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCSprite *background;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            background = [CCSprite spriteWithFile:@"Default.png"];
            background.rotation = 90;
        } else {
            background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
        }
        background.position = ccp(size.width/2, size.height/2);
        
        // add the label as a child to this Layer
        [self addChild: background];
    }
    
    return self;
}

- (void)onEnter {
    [super onEnter];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameLayer scene]]];
}

@end
