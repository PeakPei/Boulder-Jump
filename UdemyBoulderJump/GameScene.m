//
//  GameScene.m
//  UdemyBoulderJump
//
//  Created by Erik Arakelyan on 7/4/15.
//  Copyright (c) 2015 Erik Arakelyan. All rights reserved.
//

#import "GameScene.h"
#import "EndScene.h"
@interface GameScene()

@property SKSpriteNode *charachter;
@property SKSpriteNode *boulder;
@property SKSpriteNode *shadow;
@property SKLabelNode *score;
@property SKAction *jumpMov;
@property SKAction *jumpAnim;
@property BOOL isJumping;
@property BOOL isDamaged;
@property int hitCount;

@end
@implementation GameScene
@synthesize charachter,boulder,score,shadow;

static const uint32_t boulderCategory   = 0x1;
static const uint32_t charachterCategory  = 0x1 << 1;
static const uint32_t lowEdgeCategory = 0x1 << 2;
static const uint32_t edgeCategory   = 0x1 << 3;
static const uint32_t bottomEdgeCategory = 0x1 <<4;



-(void)didBeginContact:(SKPhysicsContact *)contact
{
    
    SKPhysicsBody *notTheBall;
    if(contact.bodyA.categoryBitMask<contact.bodyB.categoryBitMask)
    {
        notTheBall=contact.bodyB;
    }else{ notTheBall=contact.bodyA;}
    
    if(notTheBall.categoryBitMask==charachterCategory && _isDamaged==NO)
    {
        [self doDamage:charachter];
    }
    if(notTheBall.categoryBitMask==lowEdgeCategory)
    {
        NSLog(@"here");
        [boulder removeFromParent];
    }

    

}

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
   
    
    self.physicsBody=[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.categoryBitMask=edgeCategory;
    self.physicsWorld.contactDelegate=self;

    SKSpriteNode *landscape=[SKSpriteNode spriteNodeWithImageNamed:@"landscape"];
    landscape.position=CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:landscape];
    [self addChild:[self creatCharacter]];
    
    
    [self performSelector:@selector(creatBoulder) withObject:nil afterDelay:3.0];
    
    SKSpriteNode *railing=[SKSpriteNode spriteNodeWithImageNamed:@"railing"];
    railing.position=CGPointMake(680, 530);
    railing.zPosition=50;
    [self addChild:railing];
    [self addBottomEdge];
    [self addLowEdge];
    [self setUpActions];
    
    score=[SKLabelNode labelNodeWithFontNamed:@"Futura Medium"];
    score.color=[SKColor redColor];
    score.fontSize=45;
    score.position=CGPointMake(self.size.width-100, self.size.height-100);
    score.text=@"0";
    [self addChild:score];


}
-(void)addBottomEdge
{
    SKNode *bottomEdge=[SKNode node];
    bottomEdge.physicsBody=[SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(200, 520) toPoint:CGPointMake(self.size.width, 520)];
    bottomEdge.physicsBody.categoryBitMask=bottomEdgeCategory;
    [self addChild:bottomEdge];
    
    
}
-(void)addLowEdge
{
    SKNode *LowEdge=[SKNode node];
    LowEdge.physicsBody=[SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0, 20) toPoint:CGPointMake(self.size.width, 20)];
    LowEdge.physicsBody.categoryBitMask=lowEdgeCategory;
    [self addChild:LowEdge];
    
    
}

-(SKSpriteNode *)creatCharacter
{
    charachter=[SKSpriteNode spriteNodeWithImageNamed:@"character_base"];
    charachter.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:self.charachter.frame.size];
    charachter.physicsBody.categoryBitMask=charachterCategory;
    charachter.physicsBody.collisionBitMask=bottomEdgeCategory |edgeCategory;

    charachter.position=CGPointMake(CGRectGetMidX(self.frame)+50, CGRectGetMidY(self.frame)+50);
    charachter.name=@"Character";
    charachter.zPosition=100;
    charachter.physicsBody.affectedByGravity=NO;
    return charachter;

}

-(void)creatBoulder
{
    boulder=[SKSpriteNode spriteNodeWithImageNamed:@"boulder"];
    boulder.physicsBody=[SKPhysicsBody bodyWithCircleOfRadius:boulder.frame.size.width/2];//this action must be done before giving any properties to the sprite
    boulder.position=CGPointMake(760, 580);
    boulder.name = @"boulder";
    boulder.zPosition=2;
    boulder.physicsBody.categoryBitMask=boulderCategory;
    boulder.physicsBody.affectedByGravity=YES;
    boulder.physicsBody.collisionBitMask= bottomEdgeCategory | edgeCategory |lowEdgeCategory;
    boulder.physicsBody.contactTestBitMask=bottomEdgeCategory | edgeCategory |charachterCategory |lowEdgeCategory;
    boulder.physicsBody.linearDamping=0;
    boulder.physicsBody.friction=0;
    boulder.physicsBody.allowsRotation=NO;
    [self addChild:boulder];

    CGVector vector=CGVectorMake(-3000,0);
    [boulder.physicsBody applyForce:vector];

    
    shadow=[SKSpriteNode spriteNodeWithImageNamed:@"shadow"];
    shadow.position=CGPointMake(0,-64);
    shadow.name=@"shadow";
    shadow.xScale=1.5;
    shadow.zPosition=1;
    [boulder addChild:shadow];
    
       float random=arc4random_uniform(3)+3;
    [self performSelector:@selector(creatBoulder) withObject:nil afterDelay:random];
}

-(void) setUpActions {
    
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"character"]; // don't put .atlas in there
    
    SKTexture *jumpTex1 = [atlas textureNamed:@"character_jump1.png"];
    SKTexture *jumpTex2 = [atlas textureNamed:@"character_jump2.png"];
    SKTexture *jumpTex3 = [atlas textureNamed:@"character_jump3.png"];
    
    NSArray *atlasTexture = @[jumpTex1, jumpTex2, jumpTex3];
    NSArray *atlasTexture2 = @[jumpTex2,jumpTex1];
    
    SKAction* atlasAnimation = [SKAction animateWithTextures:atlasTexture timePerFrame:0.1];
    SKAction* wait = [SKAction waitForDuration:0.4];
    
    SKAction* atlasAnimation2 = [SKAction animateWithTextures:atlasTexture2 timePerFrame:0.1];
    SKAction *resetTexture = [SKAction setTexture:[SKTexture textureWithImageNamed:@"character_base.png"] ];
    
    _jumpAnim= [SKAction sequence:@[atlasAnimation, wait, atlasAnimation2, resetTexture ]];
    
    //// create a second set of actions...
    
    SKAction* moveUp = [SKAction moveByX:0 y:220 duration:0.4];
    SKAction* moveUp2 = [SKAction moveByX:0 y:70 duration:0.6];
    SKAction* moveDown = [SKAction moveByX:0 y:-290 duration:0.6];
    SKAction* done = [SKAction performSelector:@selector(jumpDone) onTarget:self];
    _jumpMov = [SKAction sequence:@[moveUp, moveUp2, moveDown,done]];
    
}
-(void) jumpDone {
    
    _isJumping = NO;
    NSLog(@"jump finished");
    int score1=[score.text intValue];
    score1++;
    score.text=[NSString stringWithFormat:@"%d",score1];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_isJumping==NO)
    {
        [charachter runAction:self.jumpAnim];
        [charachter runAction:self.jumpMov];
        _isJumping=YES;
    }
    

}

-(void)update:(CFTimeInterval)currentTime {
    
    
    
}


-(void) doDamage:(SKSpriteNode*)character {
    
    _isDamaged = YES;
    
    _hitCount ++;
    
    SKAction* push = [SKAction moveByX:-50 y:0 duration:0.2];
    [character runAction:push];
    
    SKAction *pulseRed = [SKAction sequence:@[
                                              [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1.0 duration:0.5],
                                              [SKAction colorizeWithColorBlendFactor:0.0 duration:0.5],
                                              [SKAction performSelector:@selector(damageDone) onTarget:self]
                                              ]];
    
    [character runAction:pulseRed];
    
}

-(void) damageDone {
    
    _isDamaged = NO;
    
    if ( _hitCount == 3) {
        
        [self gameOver];
    }
    
    
}

-(void) gameOver {

    NSLog(@"GAME OVER, MAN");
    EndScene *end=[EndScene sceneWithSize:self.size];
    [self.view presentScene:end transition:[SKTransition doorsCloseHorizontalWithDuration:0.5]];
}


@end
