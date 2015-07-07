//
//  EndScene.m
//  UdemyBoulderJump
//
//  Created by Erik Arakelyan on 7/7/15.
//  Copyright (c) 2015 Erik Arakelyan. All rights reserved.
//

#import "EndScene.h"
#import "GameScene.h"
@implementation EndScene
-(void)didMoveToView:(SKView *)view
{
    
    self.backgroundColor=[SKColor blackColor];
    SKAction *play=[SKAction playSoundFileNamed:@"gameover.caf" waitForCompletion:NO];
    [self runAction:play];
    SKLabelNode *label=[SKLabelNode labelNodeWithFontNamed:@"Futura Medium"];
    label.text=@"Game Over!";
    label.fontColor=[SKColor whiteColor];
    label.fontSize=45;
    label.position=CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:label];
    
    SKLabelNode *tryAgain=[SKLabelNode labelNodeWithFontNamed:@"Futura Medium"];
    tryAgain.text=@"tap to play again";
    tryAgain.fontColor=[SKColor whiteColor];
    tryAgain.fontSize=24;
    tryAgain.position=CGPointMake(self.size.width/2, -50);
    
    SKAction *moveLabel=[SKAction moveToY:(self.size.height/2 -40) duration:2.0];
    [tryAgain runAction:moveLabel];
    
    [self addChild:tryAgain];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    GameScene *firstScene=[GameScene sceneWithSize:self.size];
    [self.view presentScene:firstScene transition:[SKTransition doorsOpenHorizontalWithDuration:2.0]];
    
}
@end
