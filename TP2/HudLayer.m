//
//  HudLayer.m
//  TP2
//
//  Created by AdminMacLC02 on 11/21/13.
//  Copyright (c) 2013 bb. All rights reserved.
//

#import "HudLayer.h"
#import "LevelManager.h"
#import "GameOverLayer.h"
#import "GameLayer.h"


@implementation HudLayer
{
    CCLabelTTF *_label;
    CCLabelTTF *_enemyCountLabel;
    CCLabelTTF *_levelLabel;
    CCLabelTTF *_livesLabel;
    CCLabelTTF *_pauseLabel;
    CCLabelTTF *_comboLabel;
    CCLabelTTF *_ammoLabel;
    NSMutableArray* _heartSprites;
    CGSize winSize;
    
    
}

-(void)initJoystick{
    SneakyJoystickSkinnedBase *joyStickBase = [[SneakyJoystickSkinnedBase alloc] init];
    joyStickBase.backgroundSprite = [CCSprite spriteWithFile:@"BaseJoystick.png"];
    joyStickBase.thumbSprite = [CCSprite spriteWithFile:@"Joystick.png"];
    joyStickBase.joystick = [[SneakyJoystick alloc] initWithRect:CGRectMake(0, 0, 120, 120)];
    joyStickBase.position = ccp(55, 55);
    [self addChild:joyStickBase];
    self.leftJoystick = joyStickBase.joystick;
}

- (id)init
{
    self = [super init];
    if (self) {
        winSize = [[CCDirector sharedDirector] winSize];
        
        _level = [LevelManager sharedManager].curLevel;
        
        _label = [CCLabelTTF labelWithString:@"0" fontName:@"Verdana-Bold" fontSize:18.0];
        _label.color = ccc3(0,0,0);
        int margin = 10;
        _label.position = ccp(winSize.width - (_label.contentSize.width/2) - margin, winSize.height - _label.contentSize.height/2 - margin);
        [self addChild:_label];
        
        CCMenuItem *on;
        CCMenuItem *off;
        
        on = [CCMenuItemImage itemWithNormalImage:@"projectile-button-on.png"
                                    selectedImage:@"projectile-button-on.png" target:nil selector:nil];
        off = [CCMenuItemImage itemWithNormalImage:@"projectile-button-off.png"
                                     selectedImage:@"projectile-button-off.png" target:nil selector:nil];
        
        CCMenuItemToggle *toggleItem = [CCMenuItemToggle itemWithTarget:self
                                                               selector:@selector(projectileButtonTapped:) items:off, on, nil];
        CCMenu *toggleMenu = [CCMenu menuWithItems:toggleItem, nil];
        toggleMenu.position = ccp(100, 32);
        [self addChild:toggleMenu];
        
        NSString* enemyCountMessage = [NSString stringWithFormat: @"Enemies killed %d/%d", _monstersDestroyed, _level.enemiesNum];        
        _enemyCountLabel = [CCLabelTTF labelWithString:enemyCountMessage fontName:@"Arial" fontSize:18];
        _enemyCountLabel.color = ccc3(0,0,0);
        CGPoint point = ccp(0, winSize.height);
        point.x += _enemyCountLabel.contentSize.width/2;
        point.y -= _enemyCountLabel.contentSize.height/2;
        _enemyCountLabel.position = point;
        [self addChild:_enemyCountLabel];
        
        [self initJoystick];
        
    }
    return self;
}

-(void)numCollectedChanged:(int)numCollected
{
    _label.string = [NSString stringWithFormat:@"%d",numCollected];
}

- (void)projectileButtonTapped:(id)sender
{
    if (_gameLayer.mode == 1) {
        _gameLayer.mode = 0;
    } else {
        _gameLayer.mode = 1;
    }
}

-(void)showLabel:(CCLabelTTF*)label at:(CGPoint)point withMessage:(NSString*)message fontSize:(int)fontSize {

}

-(void) resetComboCounter {
    _comboCounter = 0;
    [_comboLabel setString:[NSString stringWithFormat: @"Combo: x%d", _comboCounter]];
}

- (void)nextSceneWithWon:(bool)won {
    CCScene *gameOverScene = [GameOverLayer sceneWithWon:won caller:self];
    [CCDirector sharedDirector].scheduler.timeScale = 1;
    [[CCDirector sharedDirector] replaceScene:gameOverScene];
}

-(void)updateEnemyCounter:(int)num {
    NSString* enemyCountMessage = [NSString stringWithFormat: @"Enemies killed %d/%d", num, _level.enemiesNum];
    _enemyCountLabel.string = enemyCountMessage;
}

@end

