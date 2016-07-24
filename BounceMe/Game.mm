#import "Game.h"
#import "AppDelegate.h"
#import "GB2ShapeCache.h"
#import "FlexibleBall.h"
#import "GTAnimSprite.h"
#import "SBJSON.h"
#import "SimpleAudioEngine.h"
#import "FacebookScorer.h"
#define FbClientID @"386709771449344"

@implementation Game
@synthesize gameOver;
+(CCScene *) scene:(int)sceneIdentifire
{
	CCScene *scene = [CCScene node];
	Game *layer = [Game nodeWithGameLevel:sceneIdentifire];
	[scene addChild: layer];
	return scene;
}

-(void)rotateStars{
    for (int i =0; i<[starsArray count]; i++) {
        CCOrbitCamera *orbit = [CCOrbitCamera actionWithDuration:2.0f radius:1 deltaRadius:0 angleZ:0 deltaAngleZ:360 angleX:0 deltaAngleX:0];
        id reapeat = [CCRepeatForever actionWithAction:orbit];
        CCSprite *spr = [starsArray objectAtIndex:i];
        [spr runAction:reapeat];
    }
}

-(void)showBubble{
    [node gameStarted];
}

-(void)givePhysics:(CCTMXTiledMap*)tiledMap:(float)mapHeight:(int)tileTag:(int)obstacleTag:(int)starTileTag:(BOOL)addStars{
    int gid;
    int nextGid;
    int prevGid;
    layer1 = [tiledMap layerNamed:@"layer1"];
    stars = [tiledMap layerNamed:@"points"];
    stars.visible = NO;
    obstacleLayer1 = [tiledMap layerNamed:@"obstacleLayer1"];
    obstacleLayer2 =[tiledMap layerNamed:@"obstacleLayer2"];
    for (int i=0; i<tiledMap.mapSize.width; i++) {
        for (int j=0; j<tiledMap.mapSize.height; j++) {
            gid = [layer1 tileGIDAt:ccp(i, j)];
            NSDictionary *dict = [tiledMap propertiesForGID:gid];
            NSString *type = [dict objectForKey:@"type"];
            if(type){
                
                if([type isEqualToString:@"base"]){
                    
                    
                    CCSprite *tile = [layer1 tileAt:ccp(i, j)];
                    tile.tag = tileTag;
                    b2BodyDef tileDef;
                    tileDef.type = b2_staticBody;
                    if(tileTag==3){
                        tileDef.position.Set((tile.position.x+tiledMap.position.x+(tile.contentSize.width/2))/(PTM_RATIO), (tile.position.y +tiledMap.position.y + (tile.contentSize.height/8))/PTM_RATIO);
                    }else{
                        tileDef.position.Set((tile.position.x+tiledMap.position.x+(tile.contentSize.width/2))/(PTM_RATIO), (tile.position.y +tiledMap.position.y + (tile.contentSize.height/3))/PTM_RATIO);
                    }
                    tileDef.userData = (__bridge void*)tile;
                    
                    if(i-1 >=0 && i+1 <= tiledMap.mapSize.width-1){
                        nextGid = [layer1 tileGIDAt:ccp(i+1, j)];
                        prevGid = [layer1 tileGIDAt:ccp(i-1, j)];
                        NSDictionary *prev = [tiledMap propertiesForGID:prevGid];
                        NSDictionary *next = [tiledMap propertiesForGID:nextGid];
                        NSString *type1 = [prev objectForKey:@"type"];
                        NSString *type2 = [next objectForKey:@"type"];
                        if(type1 && type2){
                            if([type1 isEqualToString:@"base"] && [type2 isEqualToString:@"base"]){
                                b2PolygonShape tileshape;
                                tileshape.SetAsBox(tile.contentSize.width/(2*PTM_RATIO), tile.contentSize.height/(5*PTM_RATIO));
                                b2FixtureDef tileShapeDef;
                                tileShapeDef.shape = &tileshape;
                                tileShapeDef.density = 1.0f;
                                tileShapeDef.friction = 2.0f;
                                tileShapeDef.restitution = 0.0f;
                                tileShapeDef.filter.groupIndex = -8;
                                tileBody = world->CreateBody(&tileDef);
                                tileFixture = tileBody->CreateFixture(&tileShapeDef);
                            }
                        }else if(type1){
                            if ([type1 isEqualToString:@"base"]) {
                                
                                if(tileTag==3){
                                    tileDef.position.Set((tile.position.x+tiledMap.position.x+(tile.contentSize.width/2)-10)/(PTM_RATIO), (tile.position.y +tiledMap.position.y + (tile.contentSize.height/3)-10)/PTM_RATIO);
                                }else{
                                    tileDef.position.Set((tile.position.x+tiledMap.position.x+(tile.contentSize.width/2)-10)/(PTM_RATIO), (tile.position.y +tiledMap.position.y + (tile.contentSize.height/3)-5)/PTM_RATIO);
                                }
                                tileBody = world->CreateBody(&tileDef);
                                [[GB2ShapeCache sharedShapeCache]
                                 addFixturesToBody:tileBody forShapeName:@"right"];
                            }
                        }else if(type2){
                            if ([type2 isEqualToString:@"base"]) {
                                if(tileTag==3){
                                    tileDef.position.Set((tile.position.x+tiledMap.position.x+(tile.contentSize.width/2)+10)/(PTM_RATIO), (tile.position.y +tiledMap.position.y + (tile.contentSize.height/3)-10)/PTM_RATIO);
                                }else{
                                    tileDef.position.Set((tile.position.x+tiledMap.position.x+(tile.contentSize.width/2)+10)/(PTM_RATIO), (tile.position.y +tiledMap.position.y + (tile.contentSize.height/3)-5)/PTM_RATIO);
                                }
                                tileBody = world->CreateBody(&tileDef);
                                [[GB2ShapeCache sharedShapeCache]
                                 addFixturesToBody:tileBody forShapeName:@"left"];
                            }
                        }
                    }else{
                        b2PolygonShape tileshape;
                        tileshape.SetAsBox(tile.contentSize.width/(2*PTM_RATIO), tile.contentSize.height/(5*PTM_RATIO));
                        b2FixtureDef tileShapeDef;
                        tileShapeDef.shape = &tileshape;
                        tileShapeDef.density = 1.0f;
                        tileShapeDef.friction = 2.0f;
                        tileShapeDef.restitution = 0.0f;
                        tileShapeDef.filter.groupIndex = -8;
                        tileBody = world->CreateBody(&tileDef);
                        tileFixture = tileBody->CreateFixture(&tileShapeDef);
                    }
                }
                
            }
            if(addStars){
                gid = [stars tileGIDAt:ccp(i, j)];
                NSDictionary *dictPoints = [tiledMap propertiesForGID:gid];
                NSString *typePoints =[dictPoints objectForKey:@"type"];
                if(typePoints){
                    if([typePoints isEqualToString:@"points"]){
                        CCSprite *starTile = [stars tileAt:ccp(i, j)];
                        starTile.tag = starTileTag;
                        CCSprite *starSprite = [CCSprite spriteWithFile:@"stern.png"];
                        starSprite.position = ccp(starTile.position.x+starTile.contentSize.width/2, starTile.position.y+tiledMap.position.y+8);
                        starSprite.tag = tileTag;
                        [self addChild:starSprite z:1];
                        [starsArray addObject:starSprite];
                    }
                }
            }
            
            gid = [obstacleLayer1 tileGIDAt:ccp(i, j)];
            NSDictionary *obstacleDict = [tiledMap propertiesForGID:gid];
            NSString *obstacleType = [obstacleDict objectForKey:@"type"];
            if (obstacleType) {
                if ([obstacleType isEqualToString:@"obstacle"]) {
                    CCSprite *obstacleTile = [obstacleLayer1 tileAt:ccp(i, j)];
                    obstacleTile.tag = obstacleTag;
                    b2BodyDef tileDef;
                    tileDef.type = b2_staticBody;
                    tileDef.position.Set((obstacleTile.position.x+tiledMap.position.x+(obstacleTile.contentSize.width/2))/(PTM_RATIO), (obstacleTile.position.y +tiledMap.position.y + (obstacleTile.contentSize.height/2))/PTM_RATIO);
                    tileDef.userData = (__bridge void*)obstacleTile;
                    tileBody = world->CreateBody(&tileDef);
                    b2PolygonShape tileshape;
                    tileshape.SetAsBox(obstacleTile.contentSize.width/(4*PTM_RATIO), obstacleTile.contentSize.height/(4*PTM_RATIO));
                    b2FixtureDef tileShapeDef;
                    tileShapeDef.shape = &tileshape;
                    tileShapeDef.density = 1.0f;
                    tileShapeDef.friction = 1.0f;
                    tileShapeDef.restitution = 0.0f;
                    tileShapeDef.filter.groupIndex = -7;
                    
                    tileFixture = tileBody->CreateFixture(&tileShapeDef);
                    NSString *type1 = [obstacleDict objectForKey:@"showarrow"];
                    if(type1){
                        if([type1 isEqualToString:@"true"]){
                            ArrowBodys arrowBody = {tileBody};
                            _arrowBody.push_back(arrowBody);
                        }
                    }
                }
            }
            
            gid = [obstacleLayer2 tileGIDAt:ccp(i, j)];
            NSDictionary *obstacleDict1 = [tiledMap propertiesForGID:gid];
            NSString *obstacleType1 = [obstacleDict1 objectForKey:@"type"];
            if (obstacleType1) {
                if ([obstacleType1 isEqualToString:@"obstacle"]) {
                    CCSprite *obstacleTile = [obstacleLayer2 tileAt:ccp(i, j)];
                    obstacleTile.tag = obstacleTag;
                    b2BodyDef tileDef;
                    tileDef.type = b2_staticBody;
                    tileDef.position.Set((obstacleTile.position.x+tiledMap.position.x+(obstacleTile.contentSize.width/2))/(PTM_RATIO), (obstacleTile.position.y +tiledMap.position.y + (obstacleTile.contentSize.height/2))/PTM_RATIO);
                    tileDef.userData = (__bridge void*)obstacleTile;
                    tileBody = world->CreateBody(&tileDef);
                    b2PolygonShape tileshape;
                    tileshape.SetAsBox(obstacleTile.contentSize.width/(4*PTM_RATIO), obstacleTile.contentSize.height/(4*PTM_RATIO));
                    b2FixtureDef tileShapeDef;
                    tileShapeDef.shape = &tileshape;
                    tileShapeDef.density = 1.0f;
                    tileShapeDef.friction = 1.0f;
                    tileShapeDef.restitution = 0.0f;
                    tileShapeDef.filter.groupIndex = -7;
                    tileFixture = tileBody->CreateFixture(&tileShapeDef);
                    NSString *type1 = [obstacleDict1 objectForKey:@"showarrow"];
                    if(type1){
                        if([type1 isEqualToString:@"true"]){
                            ArrowBodys arrowBody = {tileBody};
                            _arrowBody.push_back(arrowBody);
                        }
                    }
                }
            }
        }
    }
}

-(void)createBall{
    gameOver=false;
}

-(void)playBtnPress{
    doRandomAnimation = NO;
    gamestarted=YES;
    if (volume) {
        [self playBackGroundInGamePlay];
    }
    node->fixtureDef.density = 1.0;
    world->DestroyBody(holdingBody1);
    world->DestroyBody(holdingBody2);
    world->DestroyBody(holdingBody3);
    playershadow.visible = false;
    playerBackground.visible=false;
    [self performSelector:@selector(rotateStars)];
    [self runAction:[CCMoveTo actionWithDuration:1.0 position:ccp(0, 0)]];
    [self performSelector:@selector(showBubble) withObject:self afterDelay:0.5];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

-(void)disablebuttons{
    [pauseImage setIsEnabled:NO];
    [restartImage setIsEnabled:NO];
    [quiteImage setIsEnabled:NO];
    [thirdMenuImage setIsEnabled:NO];
    ArrowSprite.zOrder=-10;
}

-(void)enablebuttons{
    [pauseImage setIsEnabled:YES];
    [restartImage setIsEnabled:YES];
    [quiteImage setIsEnabled:YES];
    [thirdMenuImage setIsEnabled:YES];
}

-(void)invisibleAllbuttons{
    thirdMenu.visible = NO;
    restartMenu.visible = NO;
    quiteMenu.visible = NO;
    keepMapMoving = TRUE;
    gameOver = NO;
    blankLayer.visible = NO;
    ArrowSprite.zOrder=2;
}

-(void)pauseMenuAnimation{
    [self disablebuttons];
    keepMapMoving = false;
    
    gameOver = YES;
    [self performSelector:@selector(enablebuttons) withObject:nil afterDelay:1.0];
    if (menuOpen) {
        menuOpen = NO;
        for (int i = 1002; i<=1004; i++) {
            int magicNum= i-1002;
            radius = 90;
            id delay = [CCDelayTime actionWithDuration: magicNum * 0.2];
            id action1 = [CCRotateBy actionWithDuration:0.5 angle:720];
            id action2 = [CCMoveTo actionWithDuration:0.25 position:ccp(pauseMenu.position.x, pauseMenu.position.y)];
            float theta = deltaAngle*(magicNum);
            float x = (radius * cosf(-1*theta));
            float y = (radius * sinf(-1*theta));
            id doAction1 = [CCMoveTo actionWithDuration:0.25 position:ccp(x+pauseMenu.position.x,y+pauseMenu.position.y)];
            
            id action_1 = [CCSpawn actions:action1,[CCSequence actions:doAction1,action2, nil], nil];
            id action = [CCSequence actions:delay,action_1,nil];
            if(magicNum ==2){
                thirdMenu.contentSize = CGSizeZero;
                [thirdMenu runAction:action];
            }else if(magicNum == 1){
                quiteMenu.contentSize = CGSizeZero;
                [quiteMenu runAction:action];
            }else if(magicNum == 0){
                restartMenu.contentSize = CGSizeZero;
                [restartMenu runAction:action];
            }
            [self performSelector:@selector(invisibleAllbuttons) withObject:self afterDelay:1];
            playbtnpressed = NO;
            [pauseImage setNormalImage:[CCSprite spriteWithFile:@"pausePlay.png"]];
            [pauseImage setSelectedImage:[CCSprite spriteWithFile:@"pausePlay.png"]];
            [pauseMenu runAction:[CCRotateBy actionWithDuration:0.2 angle:-720]];
            [pauseImage runAction:[CCScaleTo actionWithDuration:0.2 scale:0.75
                                   ]];
        }
    }else{
        pauseMenu.contentSize = CGSizeZero;
        [pauseImage setNormalImage:[CCSprite spriteWithFile:@"resumePlay.png"]];
        [pauseImage setSelectedImage:[CCSprite spriteWithFile:@"resumePlay.png"]];
        [pauseMenu runAction:[CCRotateBy actionWithDuration:0.2 angle:720]];
        [pauseImage runAction:[CCScaleTo actionWithDuration:0.2 scale:1]];
        thirdMenu.position = ccp(pauseMenu.position.x, pauseMenu.position.y);
        blankLayer.visible = YES;
        menuOpen = YES;
        for(int i = 1004;i>=1002;i--){
            radius = 65;
            int magicNum= 1004-i;
            id delay = [CCDelayTime actionWithDuration: magicNum * 0.3];
            float theta = deltaAngle*(magicNum);
            float x = (radius * cosf(-1*theta));
            float y = (radius * sinf(-1*theta));
            id doAction1 = [CCMoveTo actionWithDuration:0.05 position:ccp(x+pauseMenu.position.x,y+pauseMenu.position.y)];
            radius = 25;
            x = (radius * cosf(-1*theta));
            y = (radius * sinf(-1*theta));
            id doAction2 = [CCMoveTo actionWithDuration:0.05 position:ccp(x+pauseMenu.position.x,y+pauseMenu.position.y)];
            
            radius=45;
            x = (radius * cosf(-1*theta));
            y = (radius * sinf(-1*theta));
            id doAction3 = [CCMoveTo actionWithDuration:0.05 position:ccp(x+pauseMenu.position.x,y+pauseMenu.position.y)];
            id action = [CCSequence actions:delay,doAction1,doAction2,doAction3, nil];
            if(magicNum ==0){
                restartMenu.visible = YES;
                restartMenu.position = ccp(pauseMenu.position.x, pauseMenu.position.y);
                
                [restartMenu runAction:action];
            }else if(magicNum == 1){
                quiteMenu.visible = YES;
                quiteMenu.position = ccp(pauseMenu.position.x, pauseMenu.position.y);
                [quiteMenu runAction:action];
            }else if(magicNum == 2){
                thirdMenu.visible = YES;
                quiteMenu.position = ccp(pauseMenu.position.x, pauseMenu.position.y);
                [thirdMenu runAction:action];
            }
        }
    }
}
-(void)getRating{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"firstRun"]){
        if(![[NSUserDefaults standardUserDefaults] objectForKey:@"rateUs"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rate Us" message:@" Hey! If you enjoyed this cute free game then a single like on itunes will motivate us to even deliver better." delegate:self cancelButtonTitle:@"Not now please" otherButtonTitles:@"Oh! Sure", nil];
            [alert show];
        }
    }
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == 1)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"rateUs"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/bounceme!/id692676722?ls=1&mt=8"]];
    }
}
-(void)animatedScene{
    self.isTouchEnabled = NO;
    background1 = [CCSprite spriteWithFile:@"background.png"];
    background1.position = ccp(screenSize.width/2, screenSize.height/2+screenSize.height);
    [self addChild:background1 z:-5];
    layer11 = [CCSprite spriteWithFile:@"layer1.png"];
    layer11.position = ccp(screenSize.width/2, 5*screenSize.height/2 + 15);
    [self addChild:layer11 z:-3];
    double time = 1;
    id delay = [CCDelayTime actionWithDuration: time];
    id action = [CCMoveTo actionWithDuration:2 position:ccp(screenSize.width/2, 3*screenSize.height/2 + 15)];
    id ease = [CCEaseBounceOut actionWithAction:action];
    id doIt = [CCSequence actions:delay,ease, nil];
    [layer11 runAction: doIt];
    
    menuOpen = NO;
    fshareFlag = NO;
    statsFlag = NO;
    volumeFlag = NO;
    blankLayer = [CCSprite spriteWithFile:@"blankLayer.png"];
    blankLayer.position = ccp(screenSize.width/2, (3*screenSize.height/2));
    blankLayer.visible = NO;
    [self addChild:blankLayer z:85];
    blankLayer.opacity = 255;
    frontImage = [CCMenuItemImage itemWithNormalImage:@"999_1.png" selectedImage:@"999_1.png" target:self  selector:@selector(doAnimation)];
    frontImage.scale = 0.75;
    frontMenu = [CCMenu menuWithItems:frontImage, nil];
    frontMenu.position = ccp(25, (2*screenSize.height-25)+screenSize.height);
    [self addChild:frontMenu z:100];
    time = 1;
    delay = [CCDelayTime actionWithDuration: time];
    action = [CCMoveTo actionWithDuration:2 position:ccp(25, 2*screenSize.height-25)];
    ease = [CCEaseBounceOut actionWithAction:action];
    doIt = [CCSequence actions:delay,ease, nil];
    [frontMenu runAction:doIt];
    firstMenuImage = [CCMenuItemImage itemWithNormalImage:@"1000.png" selectedImage:@"1000_1.png" target:self selector:@selector(fshare)];
    firstMenu = [CCMenu menuWithItems:firstMenuImage, nil];
    firstMenu.visible = NO;
    firstMenu.position = ccp(25, 2*screenSize.height-25);
    [self addChild:firstMenu z:90];
    secondMenuImage = [CCMenuItemImage itemWithNormalImage:@"1001.png" selectedImage:@"1001_1.png"target:self selector:@selector(stats)];
    secondMenu = [CCMenu menuWithItems:secondMenuImage, nil];
    secondMenu.visible = NO;
    secondMenu.position =ccp(25, 2*screenSize.height-25);
    [self addChild:secondMenu z:90];
    if(volume){
        thirdMenuImage = [CCMenuItemImage itemWithNormalImage:@"1002.png" selectedImage:@"1002.png" target:self selector:@selector(volumeOnOff)];
    }else{
        thirdMenuImage = [CCMenuItemImage itemWithNormalImage:@"1002_1.png" selectedImage:@"1002_1.png" target:self selector:@selector(volumeOnOff)];
    }
    thirdMenu = [CCMenu menuWithItems:thirdMenuImage, nil];
    thirdMenu.visible = NO;
    thirdMenu.position = ccp(25, 2*screenSize.height-25);
    [self addChild:thirdMenu z:90];
    
    layer2 = [CCSprite spriteWithFile:@"layer2.png"];
    layer2.position = ccp(screenSize.width/2, screenSize.height/1.5+screenSize.height);
    layer2.opacity = 0;
    [self addChild:layer2 z:-1];
    time=3;
    delay = [CCDelayTime actionWithDuration: time];
    CCFadeTo *fadeIn = [CCFadeTo actionWithDuration:2 opacity:255];
    doIt = [CCSequence actions:delay,fadeIn, nil];
    [layer2 runAction:doIt];
    
    playerBackground = [CCSprite spriteWithFile:@"playerBackground.png"];
    playerBackground.position = ccp(screenSize.width/3.6, screenSize.height*1.712+screenSize.height);
    playerBackground.scale = 0.75;
    [self addChild:playerBackground z:-2];
    [self performSelector:@selector(createBall) withObject:self afterDelay:3.0];
    time = 4.5;
    
    playershadow = [CCSprite spriteWithFile:@"playershadow.png"];
    playershadow.position = ccp(screenSize.width/3.6, (screenSize.height/1.4)+screenSize.height - 33);
    playershadow.opacity = 0.0f;
    playershadow.scale=2;
    prvposition = ((screenSize.height*1.712+screenSize.height)-playerBackground.position.y)/screenSize.height;
    [self addChild:playershadow z:10];
    delay = [CCDelayTime actionWithDuration: time];
    fadeIn = [CCFadeTo actionWithDuration:1 opacity:255];
    doIt = [CCSequence actions:delay,fadeIn, nil];
    [playershadow runAction:doIt];
    
    frame_normal   = [GTAnimSprite spriteWithFile:@"playButton.png"];
    frame_normal.position = ccp(screenSize.width/1.25, screenSize.height/6.6+screenSize.height);
    frame_normal.opacity = 0;
    [self addChild:frame_normal];
    time=6;
    delay = [CCDelayTime actionWithDuration: time];
    action = [CCFadeTo actionWithDuration:1 opacity:255];
    doIt = [CCSequence actions:delay,action,[CCCallBlock actionWithBlock:^{
        self.isTouchEnabled = YES;
        [self getRating];
    }], nil];
    [frame_normal runAction:doIt];
    pauseImage = [CCMenuItemImage itemWithNormalImage:@"pausePlay.png" selectedImage:@"pausePlay.png" target:self selector:@selector(pauseMenuAnimation)];
    pauseImage.scale = 0.75;
    pauseMenu = [CCMenu menuWithItems:pauseImage, nil];
    pauseMenu.visible = NO;
    [self addChild:pauseMenu z:95];
    quiteImage = [CCMenuItemImage itemWithNormalImage:@"1003.png" selectedImage:@"1003_1.png" target:self selector:@selector(goToMainMenu)];
    quiteMenu = [CCMenu menuWithItems:quiteImage, nil];
    [self addChild:quiteMenu z:90];
    quiteMenu.visible = NO;
    restartImage = [CCMenuItemImage itemWithNormalImage:@"1004.png" selectedImage:@"1004_1.png" target:self selector:@selector(restartGame)];
    restartMenu = [CCMenu menuWithItems:restartImage, nil];
    restartMenu.visible = NO;
    [self addChild:restartMenu z:90];
}

-(void)nonAnimatedScene{
    background1 = [CCSprite spriteWithFile:@"background.png"];
    background1.position = ccp(screenSize.width/2, screenSize.height/2+screenSize.height);
    [self addChild:background1 z:-5];
    layer11 = [CCSprite spriteWithFile:@"layer1.png"];
    layer11.position = ccp(screenSize.width/2, 3*screenSize.height/2 + 15);
    [self addChild:layer11 z:-3];
    
    menuOpen = NO;
    fshareFlag = NO;
    statsFlag = NO;
    volumeFlag = NO;
    blankLayer = [CCSprite spriteWithFile:@"blankLayer.png"];
    blankLayer.position = ccp(screenSize.width/2, (3*screenSize.height/2));
    blankLayer.visible = NO;
    [self addChild:blankLayer z:85];
    blankLayer.opacity = 255;
    frontImage = [CCMenuItemImage itemWithNormalImage:@"999_1.png" selectedImage:@"999_1.png" target:self  selector:@selector(doAnimation)];
    frontImage.scale = 0.75;
    frontMenu = [CCMenu menuWithItems:frontImage, nil];
    frontMenu.position = ccp(25, 2*screenSize.height-25);
    [self addChild:frontMenu z:100];
    firstMenuImage = [CCMenuItemImage itemWithNormalImage:@"1000.png" selectedImage:@"1000_1.png" target:self selector:@selector(fshare)];
    firstMenu = [CCMenu menuWithItems:firstMenuImage, nil];
    firstMenu.visible = NO;
    firstMenu.position = ccp(25, 2*screenSize.height-25);
    [self addChild:firstMenu z:90];
    secondMenuImage = [CCMenuItemImage itemWithNormalImage:@"1001.png" selectedImage:@"1001_1.png"target:self selector:@selector(stats)];
    secondMenu = [CCMenu menuWithItems:secondMenuImage, nil];
    secondMenu.visible = NO;
    secondMenu.position =ccp(25, 2*screenSize.height-25);
    [self addChild:secondMenu z:90];
    if(volume){
        thirdMenuImage = [CCMenuItemImage itemWithNormalImage:@"1002.png" selectedImage:@"1002.png" target:self selector:@selector(volumeOnOff)];
    }else{
        thirdMenuImage = [CCMenuItemImage itemWithNormalImage:@"1002_1.png" selectedImage:@"1002_1.png" target:self selector:@selector(volumeOnOff)];
    }
    thirdMenu = [CCMenu menuWithItems:thirdMenuImage, nil];
    thirdMenu.visible = NO;
    thirdMenu.position = ccp(25, 2*screenSize.height-25);
    [self addChild:thirdMenu z:90];
    
    layer2 = [CCSprite spriteWithFile:@"layer2.png"];
    layer2.position = ccp(screenSize.width/2, screenSize.height/1.5+screenSize.height);
    [self addChild:layer2 z:-1];
    
    playerBackground = [CCSprite spriteWithFile:@"playerBackground.png"];
    playerBackground.position = ccp(screenSize.width/3.6, screenSize.height*1.712+screenSize.height);
    playerBackground.scale = 0.75;
    [self addChild:playerBackground z:-2];
    gameOver=false;
    
    playershadow = [CCSprite spriteWithFile:@"playershadow.png"];
    playershadow.position = ccp(screenSize.width/3.6, (screenSize.height/1.4)+screenSize.height - 33);
    playershadow.opacity = 255.0f;
    playershadow.scale=2;
    prvposition = ((screenSize.height*1.712+screenSize.height)-playerBackground.position.y)/screenSize.height;
    [self addChild:playershadow z:10];
    
    frame_normal   = [GTAnimSprite spriteWithFile:@"playButton.png"];
    frame_normal.position = ccp(screenSize.width/1.25, screenSize.height/6.6+screenSize.height);
    [self addChild:frame_normal];
    pauseImage = [CCMenuItemImage itemWithNormalImage:@"pausePlay.png" selectedImage:@"pausePlay.png" target:self selector:@selector(pauseMenuAnimation)];
    pauseImage.scale = 0.75;
    pauseMenu = [CCMenu menuWithItems:pauseImage, nil];
    pauseMenu.visible = NO;
    [self addChild:pauseMenu z:95];
    quiteImage = [CCMenuItemImage itemWithNormalImage:@"1003.png" selectedImage:@"1003_1.png" target:self selector:@selector(goToMainMenu)];
    quiteMenu = [CCMenu menuWithItems:quiteImage, nil];
    [self addChild:quiteMenu z:90];
    quiteMenu.visible = NO;
    restartImage = [CCMenuItemImage itemWithNormalImage:@"1004.png" selectedImage:@"1004_1.png" target:self selector:@selector(restartGame)];
    restartMenu = [CCMenu menuWithItems:restartImage, nil];
    restartMenu.visible = NO;
    [self addChild:restartMenu z:90];
    [self getRating];
}
-(void)volumeOnOff{
    if(volume){
        volume = FALSE;
        node->volume = FALSE;
        [self stopBackGroundMusic];
        [thirdMenuImage setNormalImage:[CCSprite spriteWithFile:@"1002_1.png"]];
        [thirdMenuImage setSelectedImage:[CCSprite spriteWithFile:@"1002_1.png"]];
        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"volume"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        volume = TRUE;
        node->volume =TRUE;
        [self playBackGroundMusic];
        
        if(gamestarted){
            [self playBackGroundInGamePlay];
        }else{
            [self playBackgroundInMainMenu];
        }
        [thirdMenuImage setNormalImage:[CCSprite spriteWithFile:@"1002.png"]];
        [thirdMenuImage setSelectedImage:[CCSprite spriteWithFile:@"1002.png"]];
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"volume"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
-(void)intturuptHandler{
    if (!gameOver) {
        [self pauseMenuAnimation];
    }
}
-(id) initWithGameLevel:(int)level
{
    if( (self=[super init]) ){
        self.tag=777;
        removeArrowBody=YES;
        findNewBodyForArrow=YES;
        self.isTouchEnabled = YES;
        self.isAccelerometerEnabled = YES;
        keepMapMoving = FALSE;
        gameOver = TRUE;
        setCenter = TRUE;
        makeBorders = false;
        playbtnpressed = NO;
        pauseMenuOpen = NO;
        doRandomAnimation=YES;
        gamestarted=NO;
        isInstructionShown=NO;
        addnewMap = YES;
        count=0;
        fontSize = 16;
        takenTotalStars = 0;
        deltaAngle = (M_PI/2)/2.15;
        startAdDingStarstoTotalStars=1;
        screenSize = [CCDirector sharedDirector].winSize;
        speed  = 1;
        speedUpTime =1;
        starsArray = [[NSMutableArray alloc]init];
        takenStars = [[NSMutableArray alloc]init];
        
        gameScores = [[NSUserDefaults standardUserDefaults] objectForKey:@"scores"];
        
        if(gameScores == nil || [gameScores count]==0){
            gameScores = [[NSMutableArray alloc] init];
            for (int i =0; i<10; i++) {
                [gameScores addObject:[NSNumber numberWithInt:0]];
            }
        }
        gameTimes = [[NSUserDefaults standardUserDefaults] objectForKey:@"times"];
        if(gameTimes == nil | [gameTimes count]==0){
            gameTimes = [[NSMutableArray alloc] init];
            for (int i = 0 ; i<10; i++) {
                [gameTimes addObject:[NSNumber numberWithInteger:0]];
            }
        }
        b2Vec2 gravity;
        gravity.Set(0.0f, -10.0f);
        
        world = new b2World(gravity);
        world->SetContinuousPhysics(true);
        _contactListener = new MyContactListener();
        world->SetContactListener(_contactListener);
        
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"sidePlateform.plist"];
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"spike.plist"];
        
        defaultMap = [CCTMXTiledMap tiledMapWithTMXFile:@"bgdefaultmap.tmx"];
        heightDefaultMap=defaultMap.mapSize.height*defaultMap.tileSize.height;
        defaultMap.anchorPoint = ccp(0, 0);
        defaultMap.position= ccp(0,screenSize.height-heightDefaultMap);
		[self addChild:defaultMap];
        
        map1 = [CCTMXTiledMap tiledMapWithTMXFile:@"bgmap11.tmx"];
        heightMap1 = map1.mapSize.height*map1.tileSize.height;
        map1.position = ccp(0, defaultMap.position.y-heightMap1);
        [self addChild:map1 z:-1];
        [self givePhysics:map1:heightMap1:1:11:111:YES];
        
        map2 = [CCTMXTiledMap tiledMapWithTMXFile:@"bgmap22.tmx"];
        heightMap2 = map2.mapSize.height*map2 .tileSize.height;
        map2.position = ccp(0,map1.position.y-heightMap2);
        [self addChild:map2 z:-1];
        map2.visible = NO;
        [self givePhysics:map2:heightMap2:2:22:222:YES];
        
        map3 = [CCTMXTiledMap tiledMapWithTMXFile:@"bgmap33.tmx"];
        heightMap3 = map3.mapSize.height*map3 .tileSize.height;
        map3.position = ccp(0, map2.position.y-heightMap3);
        [self addChild:map3 z:-1];
        map3.visible=NO;
        [self givePhysics:map3:heightMap3:3:33:333:YES];
        
        makeMapVisible = map1.position.y+heightMap1;
        toMakeMapVisible=2;
        
        map4 = [CCTMXTiledMap tiledMapWithTMXFile:@"bgmap44.tmx"];
        heightMap4 = map4.mapSize.height*map4 .tileSize.height;
        map4.position = ccp(0, map3.position.y-heightMap4);
        [self addChild: map4 z:-1];
        map4.visible=NO;
        [self givePhysics:map4:heightMap4:4:44:444:YES];
        totalStars = [starsArray count];
        totalHightOfMaps = heightMap1 + heightMap2 + heightMap3 + heightMap4;
        
        nextUpdateMapPosition =  map3.position.y;
        nextUpdateMap = 1;
		
        m_debugDraw = new GLESDebugDraw(PTM_RATIO);
        world->SetDebugDraw(m_debugDraw);
        uint32 flags = 0;
        flags += b2Draw::e_shapeBit;
        flags += b2Draw::e_jointBit;
        flags += b2Draw::e_aabbBit;
        flags += b2Draw::e_pairBit;
        flags += b2Draw::e_centerOfMassBit;
        m_debugDraw->SetFlags(flags);
        
        Float32 holdPointy = ((screenSize.height/1.4)+screenSize.height - 45)/PTM_RATIO;
        Float32 holdPointLeftx = (screenSize.width/3.6-35)/PTM_RATIO;
        Float32 holdPointRightx =(screenSize.width/3.6+35)/PTM_RATIO;
        groundBodyDef.position.Set(0, 0);
        holdingBody1 = world->CreateBody(&groundBodyDef);
        screenBorderShape.Set(b2Vec2(holdPointLeftx,holdPointy), b2Vec2(holdPointRightx,holdPointy));
        holdBottom = holdingBody1->CreateFixture(&screenBorderShape, 0);
        Float32 holdPointy1 = ((screenSize.height)+(screenSize.height) - 60)/PTM_RATIO;
        screenBorderShape.Set(b2Vec2(holdPointLeftx,holdPointy), b2Vec2(holdPointLeftx-0.1,holdPointy1));
        holdingBody2 = world->CreateBody(&groundBodyDef);
        holdleft = holdingBody2->CreateFixture(&screenBorderShape, 0);
        screenBorderShape.Set(b2Vec2(holdPointRightx,holdPointy), b2Vec2(holdPointRightx+0.1,holdPointy1));
        holdingBody3 = world->CreateBody(&groundBodyDef);
        holdRight = holdingBody3->CreateFixture(&screenBorderShape, 0);
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"playerAnimation.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"arrow_arrow.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"pop_pop.plist"];
        CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"playerAnimation.png"];
        CCSpriteBatchNode *spriteSheet1 = [CCSpriteBatchNode batchNodeWithFile:@"pop_pop.png"]; 
        CCSpriteBatchNode *spriteSheet2 = [CCSpriteBatchNode batchNodeWithFile:@"arrow_arrow.png"];
        [self addChild:spriteSheet2];
        [self addChild:spriteSheet];
        [self addChild:spriteSheet1];
        [self schedule:@selector(update:)];
        [self schedule:@selector(tick:)];
        bottomCloud = [CCSprite spriteWithFile:@"cloud3.png"];
        bottomCloud.position = ccp(screenSize.width/2, -1*self.position.y+bottomCloud.contentSize.height/2);
        [self addChild:bottomCloud z:10];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"starcollect_1.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"eyespopup_1.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"bubbleblast_1.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"GameoverBallFall_1.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"b3_1.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"b4_1.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"b5_1.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"magic1.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"eyesanimation_1.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"winning_1.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"sad.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"BackGroundMusic.caf"];
        
        node = [FlexibleBall node];
        int volumeInd = [[[NSUserDefaults standardUserDefaults] objectForKey:@"volume"] intValue];
        if(volumeInd==0){
            volume = TRUE;
            node->volume=TRUE;
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"volume"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self playBackgroundInMainMenu];
            [self playBackGroundMusic];
        }else if(volumeInd == 1){
            volume = TRUE;
            [self playBackgroundInMainMenu];
            [self playBackGroundMusic];
        }else if(volumeInd == 2){
            volume = FALSE;
            
        }
        
        if (level == 1) {
            
            float x1 = screenSize.width/4+7;
            float y1 = 2 * screenSize.height + screenSize.height/1.7;
            [node createSoftBall:world:x1:y1];
            [self addChild:node];
            self.position = ccp(0, -screenSize.height);
            [self performSelector:@selector(animatedScene)];
            [UIApplication sharedApplication].idleTimerDisabled = NO;
        }else if(level == 2){
            float x1 = screenSize.width/4+7;
            float y1 =  screenSize.height + screenSize.height/1.3;
            [node createSoftBall:world:x1:y1];
            [self addChild:node];
            self.position = ccp(0, -screenSize.height);
            [self performSelector:@selector(nonAnimatedScene)];
            [UIApplication sharedApplication].idleTimerDisabled = NO;
        }else if(level == 3){
            if(volume){
                [self playBackGroundInGamePlay];
            }
            doRandomAnimation=NO;
            playbtnpressed=YES;
            float x1 = screenSize.width/4;
            float y1 = screenSize.height + screenSize.height/1.3;
            [node createSoftBall:world:x1:y1];
            [self addChild:node];
            node->fixtureDef.density = 1.0;
            world->DestroyBody(holdingBody1);
            world->DestroyBody(holdingBody2);
            world->DestroyBody(holdingBody3);
            playershadow.visible = false;
            playerBackground.visible=false;
            [self performSelector:@selector(rotateStars)];
            [self performSelector:@selector(showBubble) withObject:self afterDelay:0.5];
            gameOver = false;
            self.position = ccp(0, 0);
            pauseImage = [CCMenuItemImage itemWithNormalImage:@"pausePlay.png" selectedImage:@"pausePlay.png" target:self selector:@selector(pauseMenuAnimation)];
            pauseImage.scale = 0.75;
            pauseMenu = [CCMenu menuWithItems:pauseImage, nil];
            pauseMenu.visible = NO;
            [self addChild:pauseMenu z:95];
            quiteImage = [CCMenuItemImage itemWithNormalImage:@"1003.png" selectedImage:@"1003_1.png" target:self selector:@selector(goToMainMenu)];
            quiteMenu = [CCMenu menuWithItems:quiteImage, nil];
            [self addChild:quiteMenu z:90];
            quiteMenu.visible = NO;
            restartImage = [CCMenuItemImage itemWithNormalImage:@"1004.png" selectedImage:@"1004_1.png" target:self selector:@selector(restartGame)];
            restartMenu = [CCMenu menuWithItems:restartImage, nil];
            restartMenu.visible = NO;
            [self addChild:restartMenu z:90];
            frontImage = [CCMenuItemImage itemWithNormalImage:@"999_1.png" selectedImage:@"999_1.png" target:self  selector:@selector(doAnimation)];
            frontImage.scale = 0.75;
            frontMenu = [CCMenu menuWithItems:frontImage, nil];
            frontMenu.position = ccp(25, 2*screenSize.height-25);
            [self addChild:frontMenu z:100];
            firstMenuImage = [CCMenuItemImage itemWithNormalImage:@"1000.png" selectedImage:@"1000_1.png" target:self selector:@selector(fshare)];
            firstMenu = [CCMenu menuWithItems:firstMenuImage, nil];
            firstMenu.visible = NO;
            firstMenu.position = ccp(25, 2*screenSize.height-25);
            [self addChild:firstMenu z:95];
            secondMenuImage = [CCMenuItemImage itemWithNormalImage:@"1001.png" selectedImage:@"1001_1.png"target:self selector:@selector(stats)];
            secondMenu = [CCMenu menuWithItems:secondMenuImage, nil];
            secondMenu.visible = NO;
            secondMenu.position =ccp(25, 2*screenSize.height-25);
            [self addChild:secondMenu z:90];
            if(volume){
                thirdMenuImage = [CCMenuItemImage itemWithNormalImage:@"1002.png" selectedImage:@"1002.png" target:self selector:@selector(volumeOnOff)];
            }else{
                thirdMenuImage = [CCMenuItemImage itemWithNormalImage:@"1002_1.png" selectedImage:@"1002_1.png" target:self selector:@selector(volumeOnOff)];
            }
            
            thirdMenu = [CCMenu menuWithItems:thirdMenuImage, nil];
            thirdMenu.visible = NO;
            thirdMenu.position = ccp(25, 2*screenSize.height-25);
            [self addChild:thirdMenu z:90];
            blankLayer = [CCSprite spriteWithFile:@"blankLayer.png"];
            blankLayer.position = ccp(screenSize.width/2, (3*screenSize.height/2));
            blankLayer.visible = NO;
            [self addChild:blankLayer z:85];
            [UIApplication sharedApplication].idleTimerDisabled = YES;
            
            
        }
	}
	return self;
}
-(void)playBackgroundInMainMenu{
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:1];
}
-(void)playBackGroundInGamePlay{
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.3];
}
-(void)playBackGroundMusicInDisplayScore{
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.1];
}
-(void)playBackGroundMusic{
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"BackGroundMusic.caf"];
}
-(void)stopBackGroundMusic{
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
}
-(void)fshare{
    int j=[[gameScores objectAtIndex:0]intValue];
    if(j==0)
    {
        UIAlertView *objAlert = [[UIAlertView alloc]initWithTitle:@"BounceMe Alert" message:@"Sorry! You can't share 0 score" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [objAlert show];
        
    }
    
    
    else
    {
        [[FacebookScorer sharedInstance] postToWallWithDialogNewHighscore:j];
    }
}

-(void)enabledMenu{
    [frontImage setIsEnabled:YES];
    [firstMenuImage setIsEnabled:YES];
    [secondMenuImage setIsEnabled:YES];
    [thirdMenuImage setIsEnabled:YES];
}

-(void)disableMenu{
    [frontImage setIsEnabled:NO];
    [firstMenuImage setIsEnabled:NO];
    [secondMenuImage setIsEnabled:NO];
    [thirdMenuImage setIsEnabled:NO];
}

-(void)removeStatistic{
    //    [[CCDirector sharedDirector] setAnimationInterval:1.0/60];
    [self removeChild:cancleMenu cleanup: YES];
    [self removeChild:statisticbg cleanup: YES];
    [table removeFromSuperview];
    [self enabledMenu];
    blankLayer.zOrder = 85;
}
-(void)stats{
    //    [[CCDirector sharedDirector] setAnimationInterval:1.0/30.0];
    [self disableMenu];
    
    blankLayer.zOrder = 100;
    
    statisticbg = [CCSprite spriteWithFile:@"scorebg11.png"];
    statisticbg.position = ccp(self.position.x+screenSize.width/2, -1*self.position.y + screenSize.height/2);
    statisticbg.opacity = 255;
    [self addChild:statisticbg z:105];
    gameScores = [[NSUserDefaults standardUserDefaults] objectForKey:@"scores"];
    gameTimes = [[NSUserDefaults standardUserDefaults] objectForKey:@"times"];
    if(gameScores == nil || [gameScores count]==0){
        gameScores = [[NSMutableArray alloc] init];
        for (int i =0; i<10; i++) {
            [gameScores addObject:[NSNumber numberWithInt:0]];
        }
    }
    for (int i = 0; i < N_OF_SECTION; i++)
    {
        count1[i] = N_OF_ROW;
    }
    CGRect frame;
    if((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && (([[UIScreen mainScreen] bounds].size.height == 568) ||([[UIScreen mainScreen] bounds].size.width == 568))) {
        frame = CGRectMake(10, 164, 360, 230);
    }else{
        frame = CGRectMake(10, 120, 360, 230);
    }
    table = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    table.layer.cornerRadius = 5;
    table.layer.borderColor = [UIColor blackColor].CGColor;
    table.layer.borderWidth = 0;
    table.backgroundColor = [UIColor clearColor];
    
    table.rowHeight = 50;
    table.separatorColor = [UIColor clearColor];
    table.allowsSelection = NO; // cell can't select
    table.alpha = 0;
    table.dataSource = self;
    table.delegate = self;
    [[[CCDirector sharedDirector] view] addSubview:table];
    
    [UIView animateWithDuration:0.1 animations:^(void){
        table.alpha = 1.0;
    }];
    CCMenuItemImage *cancleImage= [CCMenuItemImage itemWithNormalImage:@"red-cancel.png" selectedImage:@"red-cancel-press.png"target:self selector:@selector(removeStatistic)];
    cancleImage.scale = 0.6;
    cancleMenu = [CCMenu menuWithItems:cancleImage, nil];
    cancleMenu.position = ccp(statisticbg.position.x + 130,statisticbg.position.y+290/2);
    [self addChild:cancleMenu z:107];
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellCustom";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];        
    
    
    
    UILabel* Label = [[UILabel alloc] initWithFrame:CGRectMake(40,10, 150, 23)];
    int sec1;
    int min1;
    int hour1;
    int totalSeconds = [[gameTimes objectAtIndex:indexPath.row] intValue];
    if (totalSeconds <60) {
        sec1 = totalSeconds;
        min1 = 0;
        hour1 = 0;
    }else if(totalSeconds < 3600){
        sec1 = totalSeconds%60;
        min1 = (totalSeconds-sec1)/60;
        hour1 = 0;
    }else{
        sec1 = totalSeconds%60;
        int totalMinuts = totalSeconds /60;
        min1 = totalMinuts%60;
        hour1 = (totalMinuts-min1);
    }
    [Label setText:[NSString stringWithFormat:@"%.2d:%.2d:%.2d",hour1,min1,sec1]];
    Label.font = [UIFont fontWithName:@"DigifaceWide" size:22];
    Label.textAlignment = UITextAlignmentCenter;
    Label.textColor = [UIColor whiteColor];
    [Label setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
    [cell addSubview:Label]; 
    
    
    
    UILabel* Label1 = [[UILabel alloc] initWithFrame:CGRectMake(170,10, 170, 23)];
    
    [Label1 setText:[NSString stringWithFormat:@"%d",[[gameScores objectAtIndex:indexPath.row] intValue]]];
    Label1.textAlignment = UITextAlignmentCenter;
    Label1.font = [UIFont fontWithName:@"GROBOLD" size:22];
    Label1.textColor = [UIColor colorWithRed:168.0/255.0 green:208.0/255.0 blue:255.0/255.0 alpha:1];
    [Label1 setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
    [cell addSubview:Label1]; 
    
    
    
    UILabel* Label2 = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 40, 23)];
    Label2.font = [UIFont fontWithName:@"Times New Roman" size:22];
    [Label2 setText:[NSString stringWithFormat:@"%d",indexPath.row+1]];
    Label2.textColor = [UIColor colorWithRed:255.0/255.0 green:210.0/255.0 blue:2.0/255.0 alpha:1];
    [Label2 setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
    Label2.textAlignment = UITextAlignmentCenter;
    [cell addSubview:Label2]; 
    
    return cell;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return N_OF_SECTION;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    count1[indexPath.section]--;
//    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//}
-(void)sound{
    if (volume) {
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:4.0];
        [[SimpleAudioEngine sharedEngine] playEffect:@"eyespopup_1.caf"];
    }
    
}

-(void) invisibleAll{
    firstMenu.visible = NO;
    secondMenu.visible = NO;
    thirdMenu.visible = NO;
    blankLayer.visible = NO;
}


-(void)doAnimation{
    [self disableMenu];
    
    [self performSelector:@selector(enabledMenu) withObject:nil afterDelay:1.0];
    if (menuOpen) {
        menuOpen = NO;
        
        for (int i = 1002; i>=1000; i--) {
            int magicNum= 1002-i;
            radius = 90;
            id delay = [CCDelayTime actionWithDuration: magicNum * 0.2];
            id action1 = [CCRotateBy actionWithDuration:0.5 angle:720];
            id action2 = [CCMoveTo actionWithDuration:0.25 position:ccp(25, 2*screenSize.height-25)];
            float theta = deltaAngle*(magicNum);
            float x = (radius * cosf(-1*theta));
            float y = (radius * sinf(-1*theta));
            id doAction1 = [CCMoveTo actionWithDuration:0.25 position:ccp(x+12.5,y+2*screenSize.height-25)];
            
            id action_1 = [CCSpawn actions:action1,[CCSequence actions:doAction1,action2, nil], nil];
            id action = [CCSequence actions:delay,action_1,nil];
            if(magicNum ==2){
                thirdMenu.contentSize = CGSizeZero;
                
                [thirdMenu runAction:action];
            }else if(magicNum == 1){
                secondMenu.contentSize = CGSizeZero;
                [secondMenu runAction:action];
            }else if(magicNum == 0){
                firstMenu.contentSize = CGSizeZero;
                [firstMenu runAction:action];
            }
            [self performSelector:@selector(invisibleAll) withObject:nil afterDelay:1];
            [secondMenuImage setNormalImage:[CCSprite spriteWithFile:@"1001.png"]];
            statsFlag = NO;
            [firstMenuImage setNormalImage:[CCSprite spriteWithFile:@"1000.png"]];
            fshareFlag = NO;
            playbtnpressed = NO;
            [frontMenu runAction:[CCRotateBy actionWithDuration:0.2 angle:-360]];
            [frontImage runAction:[CCScaleTo actionWithDuration:0.2 scale:0.75
                                   ]];
        }
    }else{
        frontMenu.contentSize = CGSizeZero;
        [frontMenu runAction:[CCRotateBy actionWithDuration:0.2 angle:360]];
        [frontImage runAction:[CCScaleTo actionWithDuration:0.2 scale:1]];
        [secondMenuImage setNormalImage:[CCSprite spriteWithFile:@"1001.png"]];
        [firstMenuImage setNormalImage:[CCSprite spriteWithFile:@"1000.png"]];
        blankLayer.visible = YES;
        menuOpen = YES;
        for(int i = 1000;i<1003;i++){
            radius = 65;
            int magicNum= i-1000;
            id delay = [CCDelayTime actionWithDuration: magicNum * 0.3];
            float theta = deltaAngle*(magicNum);
            float x = (radius * cosf(-1*theta));
            float y = (radius * sinf(-1*theta));
            id doAction1 = [CCMoveTo actionWithDuration:0.05 position:ccp(x+screenSize.width/9,y+2*screenSize.height-25)];
            radius = 25;
            x = (radius * cosf(-1*theta));
            y = (radius * sinf(-1*theta));
            id doAction2 = [CCMoveTo actionWithDuration:0.05 position:ccp(x+25,y+2*screenSize.height-25)];
            
            radius=45;
            x = (radius * cosf(-1*theta));
            y = (radius * sinf(-1*theta));
            id doAction3 = [CCMoveTo actionWithDuration:0.05 position:ccp(x+25,y+2*screenSize.height-25)];
            id action = [CCSequence actions:delay,doAction1,doAction2,doAction3, nil];
            if(magicNum ==0){
                firstMenu.visible = YES;
                
                [firstMenu runAction:action];
            }else if(magicNum == 1){
                secondMenu.visible = YES;
                [secondMenu runAction:action];
            }else if(magicNum == 2){
                thirdMenu.visible = YES;
                [thirdMenu runAction:action];
            }
            
            playbtnpressed = YES;
        }
    }
}
-(void)setCenterSelecrtor:(ccTime)dt{
    Float32 x = MAX(player.position.x, screenSize.width/2);
    Float32 y = MAX(player.position.y, -1*self.position.y);
    x=MIN(x, self.position.x+screenSize.width/2);
    y=MIN(y,-1*self.position.y+screenSize.height/2);
    CGPoint goodPoint = ccp(x, y);
    CGPoint centerOfScreen = ccp(screenSize.width/2, screenSize.height/2);
    CGPoint difference = ccpSub(centerOfScreen, goodPoint);
    self.position = difference;
}
-(void)stopscheduledSelector{
    [self unschedule:@selector(setCenterSelecrtor:)];
}
-(void)blastAnimation:(BOOL)isHighScore{
    prevX = self.position.x;
    prevY = self.position.y;
    float diff_y  = -1*self.position.y + screenSize.height/2 - node->innerCircleBody->GetPosition().y*PTM_RATIO;
    CCMoveTo *moveBy = [CCMoveTo actionWithDuration:0.5 position:ccp(self.position.x,self.position.y + diff_y)];
    [self runAction:moveBy];
    [self schedule:@selector(setCenterSelecrtor:)];
    [self performSelector:@selector(stopscheduledSelector) withObject:self afterDelay:2.6];
    player =  [CCSprite spriteWithFile:@"blink1.png"];
    //player.rotation =  -1 * CC_RADIANS_TO_DEGREES(node->innerCircleBody->GetAngle());
    player.position = ccp(node->innerCircleBody->GetPosition().x*PTM_RATIO, node->innerCircleBody->GetPosition().y*PTM_RATIO);
    [self addChild:player];
    NSMutableArray *walkAnimFrames = [NSMutableArray array];
    NSMutableArray *walkAnimDown = [NSMutableArray array];
    
    if(volume){
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:2.0];
        [[SimpleAudioEngine sharedEngine] playEffect:@"bubbleblast_1.caf"];
    }
    
    
    for (int i=1; i<=5; i++) {
        [walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"blast%d.png",i]]];
    }
    for (int k=0; k<=81;k++) {
        [walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"pop%d.png",k]]];
    }
    for (int k = 82; k<=140; k++) {
        [walkAnimDown addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"pop%d.png",k]]];
    }
    CCAnimation *walkAnim = [CCAnimation
                             animationWithSpriteFrames:walkAnimFrames delay:0.02f];
    CCAnimation *walkAnim1 = [CCAnimation
                              animationWithSpriteFrames:walkAnimDown delay:0.015f];
    
    [player runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.2],[CCSpawn actions:[CCCallBlock actionWithBlock:^{
        [self performSelector:@selector(sound) withObject:nil afterDelay:0.22+(0.02*5)];
        
    }], [CCAnimate actionWithAnimation:walkAnim],nil],[CCSpawn actions:[CCCallBlock actionWithBlock:^{
        if(volume){
            [[SimpleAudioEngine sharedEngine]setEffectsVolume:2.0f];
            [[SimpleAudioEngine sharedEngine]playEffect:@"GameoverBallFall_1.caf"];
        }
        
    }], [CCAnimate actionWithAnimation:walkAnim1],nil], nil]];
    //    [player runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.2],[CCAnimate actionWithAnimation:walkAnim],[CCAnimate actionWithAnimation:walkAnim1], nil]];
    //    //[player runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.3+0.55],action, nil]];
    id action1 = [CCMoveTo actionWithDuration:2 position:ccp(player.position.x,player.position.y-2*screenSize.height)];
    [player runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.25+1.8],action1, nil]];
    
    prevX = self.position.x;
    prevY = -1*self.position.y;
    [self performSelector:@selector(displayScore) withObject:self afterDelay:3.4];
}

-(void)restartGame{
    [CCAnimationCache purgeSharedAnimationCache];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
    [[CCDirector sharedDirector] purgeCachedData];
    [[CCTextureCache sharedTextureCache] removeAllTextures]; 
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1 scene:[Game scene:3] withColor:ccWHITE]];
}

-(void)goToMainMenu{
    [CCAnimationCache purgeSharedAnimationCache];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
    [[CCDirector sharedDirector] purgeCachedData];
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1 scene:[Game scene:2] withColor:ccWHITE]];
}

-(void)displayStars{
    CCSprite *glow = [CCSprite spriteWithFile:@"glow.png"];
    CCSprite *black1 = [CCSprite spriteWithFile:@"starBackground.png"];
    [self addChild:black1 z:105];
    CCSprite *black2 = [CCSprite spriteWithFile:@"starBackground.png"];[self addChild:black2 z:105];
    CCSprite *black3 = [CCSprite spriteWithFile:@"starBackground.png"];[self addChild:black3 z:105];
    
    black2.position = ccp(scorebg.position.x, scorebg.position.y + 1.8*glow.contentSize.height + screenSize.height);
    black1.position = ccp(scorebg.position.x- 1.6*glow.contentSize.width, scorebg.position.y+40+ screenSize.height);
    black3.position = ccp(scorebg.position.x+ 1.6 *glow.contentSize.width, scorebg.position.y+40+ screenSize.height);
    
    id jump = [CCJumpTo actionWithDuration:1 position:ccp(scorebg.position.x, scorebg.position.y + 1.8*glow.contentSize.height) height:-180 jumps:1];
    [black2 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5],jump, nil]];
    
    jump = [CCJumpTo actionWithDuration:1 position:ccp(scorebg.position.x- 1.6*glow.contentSize.width, scorebg.position.y+40) height:-180 jumps:1];
    [black1 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5],jump, nil]];
    
    jump = [CCJumpTo actionWithDuration:1 position:ccp(scorebg.position.x+ 1.6 *glow.contentSize.width, scorebg.position.y+40) height:-180 jumps:1];
    [black3 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5],jump, nil]];
    if(gotStar==1){
        [self performSelector:@selector(magicalsound) withObject:nil afterDelay:1.8];    
        [self performSelector:@selector(animateGlowStars:) withObject:black1 afterDelay:2.0];
    }
    else if(gotStar==2){
        [self performSelector:@selector(animateGlowStars:) withObject:black1 afterDelay:2.0];
        [self performSelector:@selector(magicalsound) withObject:nil afterDelay:1.8];
        [self performSelector:@selector(animateGlowStars:) withObject:black2 afterDelay:2.5];
        [self performSelector:@selector(magicalsound) withObject:nil afterDelay:2.3];
    }else if(gotStar==3){
        [self performSelector:@selector(animateGlowStars:) withObject:black1 afterDelay:2.0];
        [self performSelector:@selector(magicalsound) withObject:nil afterDelay:1.8];
        [self performSelector:@selector(animateGlowStars:) withObject:black2 afterDelay:2.5];
        [self performSelector:@selector(magicalsound) withObject:nil afterDelay:2.3];
        [self performSelector:@selector(animateGlowStars:) withObject:black3 afterDelay:3.0];
        [self performSelector:@selector(magicalsound) withObject:nil afterDelay:2.8];
    }
    
}
-(void)magicalsound{
    if (volume) {
        [[SimpleAudioEngine sharedEngine]setEffectsVolume:1.0f];
        [[SimpleAudioEngine sharedEngine]playEffect:@"magic1.caf"];
    }
}
-(void)animateGlowStars:(CCSprite*)baseSprite{
    CCSprite* star = [CCSprite spriteWithFile:@"mainStar.png"];
    star.position = ccp(baseSprite.position.x, baseSprite.position.y);
    star.scale = 2
    ;
    star.opacity =110;
    
    id scaleDownAction2 = [CCEaseInOut actionWithAction:[CCScaleTo actionWithDuration:0.3 scale:1] rate:10];
    
    CCFadeTo *opacity2 = [CCFadeTo actionWithDuration:0.3 opacity:255];
    id action = [CCSequence actions:[CCDelayTime actionWithDuration:0.2],[CCCallBlock actionWithBlock:^{
        emitter =[CCParticleSystemQuad particleWithFile:@"stars.plist"];
        
        emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"stern.png"];
        emitter.blendAdditive =YES;
        emitter.autoRemoveOnFinish = YES;
        emitter.speed = 70.0f;
        emitter.duration = 2.0f;
        emitter.angle = 90;
    	emitter.scale =1.0;
        emitter.life =2.0;
        emitter.lifeVar=0.3;
        emitter.startSpin =200;
        emitter1 =[CCParticleSystemQuad particleWithFile:@"stars.plist"];
        emitter1.texture = [[CCTextureCache sharedTextureCache] addImage: @"stern.png"];
        emitter1.blendAdditive =YES;
        emitter1.autoRemoveOnFinish = YES;
        emitter1.speed = 70.0f;
        emitter1.duration = 2.0f;
        emitter1.angle = 120;
        emitter1.life =2.0;
        emitter1.lifeVar=0.3;
        emitter1.scale = 1.0;
        emitter1.startSpin =200;
        emitter2 =[CCParticleSystemQuad particleWithFile:@"stars.plist"];
        emitter2.texture = [[CCTextureCache sharedTextureCache] addImage: @"stern.png"];
        emitter2.blendAdditive =YES;
        emitter2.autoRemoveOnFinish = YES;
        emitter2.speed = 70.0f;
        emitter2.duration = 2.0f;
        emitter2.angle = 180;
        emitter2.life =2.0;
        emitter2.lifeVar=0.3;
        emitter2.scale = 1.0;
        emitter2.startSpin =200;
        emitter3 =[CCParticleSystemQuad particleWithFile:@"stars.plist"];
        emitter3.texture = [[CCTextureCache sharedTextureCache] addImage: @"stern.png"];
        emitter3.blendAdditive =YES;
        emitter3.autoRemoveOnFinish = YES;
        emitter3.speed =70.0f;
        emitter3.duration = 2.0f;
        emitter3.angle =0;
        emitter3.life =2.0;
        emitter3.lifeVar=0.3;
        emitter3.scale = 1.0;
        emitter3.startSpin =200;
        emitter4 =[CCParticleSystemQuad particleWithFile:@"stars.plist"];
        emitter4.texture = [[CCTextureCache sharedTextureCache] addImage: @"stern.png"];
        emitter4.blendAdditive =YES;
        emitter4.autoRemoveOnFinish = YES;
        emitter4.speed = 70.0f;
        emitter4.duration = 2.0f;
        emitter4.angle = 90;
        emitter4.scale =1.2;
        emitter4.life =2.0;
        emitter4.lifeVar=0.3;
        emitter4.startSpin =200;
        
        emitter5 =[CCParticleSystemQuad particleWithFile:@"stars.plist"];
        emitter5.texture = [[CCTextureCache sharedTextureCache] addImage: @"stern.png"];
        emitter5.blendAdditive =YES;
        emitter5.autoRemoveOnFinish = YES;
        emitter5.speed = 70.0f;
        emitter5.duration = 2.0f;
        emitter5.angle = -90;
        emitter5.life =2.0;
        emitter5.lifeVar=0.3;
        emitter5.scale = 1.2;
        emitter5.startSpin =200;
        emitter6 =[CCParticleSystemQuad particleWithFile:@"stars.plist"];
        emitter6.texture = [[CCTextureCache sharedTextureCache] addImage: @"stern.png"];
        emitter6.blendAdditive =YES;
        emitter6.autoRemoveOnFinish = YES;
        emitter6.speed = 70.0f;
        emitter6.duration = 2.0f;
        emitter6.angle = -50;
        emitter6.life =2.0;
        emitter6.lifeVar=0.3;
        emitter6.scale = 1.2;
        emitter6.startSpin =200;
        emitter7 =[CCParticleSystemQuad particleWithFile:@"stars.plist"];
        emitter7.texture = [[CCTextureCache sharedTextureCache] addImage: @"stern.png"];
        emitter7.blendAdditive =YES;
        emitter7.autoRemoveOnFinish = YES;
        emitter7.speed =70.0f;
        emitter7.duration = 2.0f;
        emitter7.angle = -120;
        emitter7.life =2.0;
        emitter7.lifeVar=0.3;
        emitter7.scale = 1.2;
        emitter7.startSpin =200;
        emitter8 =[CCParticleSystemQuad particleWithFile:@"stars.plist"];
        emitter8.texture = [[CCTextureCache sharedTextureCache] addImage: @"stern.png"];
        emitter8.blendAdditive =YES;
        emitter8.autoRemoveOnFinish = YES;
        emitter8.speed = 70.0f;
        emitter8.duration = 2.0f;
        emitter8.angle = 120;
        emitter8.scale =1.0;
        emitter8.life =2.0;
        emitter8.lifeVar=0.3;
        emitter8.startSpin =200;
        emitter9 =[CCParticleSystemQuad particleWithFile:@"stars.plist"];
        emitter9.texture = [[CCTextureCache sharedTextureCache] addImage: @"stern.png"];
        emitter9.blendAdditive =YES;
        emitter9.autoRemoveOnFinish = YES;
        emitter9.speed = 70.0f;
        emitter9.duration = 2.0f;
        emitter9.angle = 60;
        emitter9.life =2.0;
        emitter9.lifeVar=0.3;
        emitter9.scale = 1.0;
        emitter9.startSpin =200;
        emitter10 =[CCParticleSystemQuad particleWithFile:@"stars.plist"];
        emitter10.texture = [[CCTextureCache sharedTextureCache] addImage: @"stern.png"];
        emitter10.blendAdditive =YES;
        emitter10.autoRemoveOnFinish = YES;
        emitter10.speed = 70.0f;
        emitter10.duration = 2.0f;
        emitter10.angle = 120;
        emitter10.life =2.0;
        emitter10.lifeVar=0.3;
        emitter10.scale = 1.0;
        emitter10.startSpin =200;
        emitter11 =[CCParticleSystemQuad particleWithFile:@"stars.plist"];
        emitter11.texture = [[CCTextureCache sharedTextureCache] addImage: @"stern.png"];
        emitter11.blendAdditive =YES;
        emitter11.autoRemoveOnFinish = YES;
        emitter11.speed =70.0f;
        emitter11.duration = 2.0f;
        emitter11.angle = 30;
        emitter11.life =2.0;
        emitter11.lifeVar=0.3;
        emitter11.scale = 1.0;
        emitter11.startSpin =200;
        emitter12 =[CCParticleSystemQuad particleWithFile:@"stars.plist"];
        emitter12.texture = [[CCTextureCache sharedTextureCache] addImage: @"stern.png"];
        emitter12.blendAdditive =YES;
        emitter12.autoRemoveOnFinish = YES;
        emitter12.speed =70.0f;
        emitter12.duration = 2.0f;
        emitter12.angle = -120;
        emitter12.life =2.0;
        emitter12.lifeVar=0.3;
        emitter12.scale = 1.0;
        emitter12.startSpin =200;
        emitter13 =[CCParticleSystemQuad particleWithFile:@"stars.plist"];
        emitter13.texture = [[CCTextureCache sharedTextureCache] addImage: @"stern.png"];
        emitter13.blendAdditive =YES;
        emitter13.autoRemoveOnFinish = YES;
        emitter13.speed =70.0f;
        emitter13.duration = 2.0f;
        emitter13.angle = -90;
        emitter13.life =2.0;
        emitter13.lifeVar=0.3;
        emitter13.scale = 1.0;
        emitter13.startSpin =200;
        emitter14 =[CCParticleSystemQuad particleWithFile:@"stars.plist"];
        emitter14.texture = [[CCTextureCache sharedTextureCache] addImage: @"stern.png"];
        emitter14.blendAdditive =YES;
        emitter14.autoRemoveOnFinish = YES;
        emitter14.speed =70.0f;
        emitter14.duration = 2.0f;
        emitter14.angle = -140;
        emitter14.life =2.0;
        emitter14.lifeVar=0.3;
        emitter14.scale = 1.0;
        emitter14.startSpin =200;
        emitter15 =[CCParticleSystemQuad particleWithFile:@"stars.plist"];
        emitter15.texture = [[CCTextureCache sharedTextureCache] addImage: @"stern.png"];
        emitter15.blendAdditive =YES;
        emitter15.autoRemoveOnFinish = YES;
        emitter15.speed =70.0f;
        emitter15.duration = 2.0f;
        emitter15.angle = -90;
        emitter15.life =2.0;
        emitter15.lifeVar=0.3;
        emitter15.scale = 1.0;
        emitter15.startSpin =200;
        emitter16 =[CCParticleSystemQuad particleWithFile:@"stars.plist"];
        emitter16.texture = [[CCTextureCache sharedTextureCache] addImage: @"stern.png"];
        emitter16.blendAdditive =YES;
        emitter16.autoRemoveOnFinish = YES;
        emitter16.speed =70.0f;
        emitter16.duration = 2.0f;
        emitter16.angle = -120;
        emitter16.life =2.0;
        emitter16.lifeVar=0.3;
        emitter16.scale = 1.0;
        emitter16.startSpin =200;
        emitter17 =[CCParticleSystemQuad particleWithFile:@"stars.plist"];
        emitter17.texture = [[CCTextureCache sharedTextureCache] addImage: @"stern.png"];
        emitter17.blendAdditive =YES;
        emitter17.autoRemoveOnFinish = YES;
        emitter17.speed =70.0f;
        emitter17.duration = 2.0f;
        emitter17.angle = -120;
        emitter17.life =2.0;
        emitter17.lifeVar=0.3;
        emitter17.scale = 1.0;
        emitter17.startSpin =200;
        emitter18 =[CCParticleSystemQuad particleWithFile:@"stars.plist"];
        emitter18.texture = [[CCTextureCache sharedTextureCache] addImage: @"stern.png"];
        emitter18.blendAdditive =YES;
        emitter18.autoRemoveOnFinish = YES;
        emitter18.speed =70.0f;
        emitter18.duration = 2.0f;
        emitter18.angle = 0;
        emitter18.life =2.0;
        emitter18.lifeVar=0.3;
        emitter18.scale = 1.0;
        emitter18.startSpin =200;
        emitter19 =[CCParticleSystemQuad particleWithFile:@"stars.plist"];
        emitter19.texture = [[CCTextureCache sharedTextureCache] addImage: @"stern.png"];
        emitter19.blendAdditive =YES;
        emitter19.autoRemoveOnFinish = YES;
        emitter19.speed =70.0f;
        emitter19.duration = 2.0f;
        emitter19.angle = 120;
        emitter19.life =2.0;
        emitter19.lifeVar=0.3;
        emitter19.scale = 1.0;
        emitter19.startSpin =200;
        emitter.position = ccp(baseSprite.position.x +29/2 , baseSprite.position.y +65/2);
        emitter1.position = ccp(baseSprite.position.x -29/2, baseSprite.position.y +65/2);
        emitter2.position = ccp(baseSprite.position.x -71/2  , baseSprite.position.y );
        emitter3.position = ccp(baseSprite.position.x +71/2 , baseSprite.position.y );
        emitter4.position = ccp(baseSprite.position.x-51/2 , baseSprite.position.y +48/2);
        emitter5.position = ccp(baseSprite.position.x+51/2, baseSprite.position.y +48/2 );
        emitter6.position = ccp(baseSprite.position.x -67/2 , baseSprite.position.y +25/2);
        emitter7.position = ccp(baseSprite.position.x +67/2 , baseSprite.position.y +25/2);
        emitter8.position = ccp(baseSprite.position.x -60/2 , baseSprite.position.y +36/2);
        emitter9.position = ccp(baseSprite.position.x +60/2, baseSprite.position.y +36/2);
        emitter10.position =ccp(baseSprite.position.x +29/2 , baseSprite.position.y -65/2);
        emitter11.position = ccp(baseSprite.position.x -29/2, baseSprite.position.y -65/2);
        emitter12.position = ccp(baseSprite.position.x -71/2  , baseSprite.position.y-10/2);
        emitter13.position = ccp(baseSprite.position.x -71/2  , baseSprite.position.y-10/2);
        emitter14.position = ccp(baseSprite.position.x-51/2 , baseSprite.position.y -48/2);
        emitter15.position = ccp(baseSprite.position.x+51/2 , baseSprite.position.y -48/2);
        emitter16.position =  ccp(baseSprite.position.x -67/2 , baseSprite.position.y -25/2);
        emitter17.position =  ccp(baseSprite.position.x +67/2 , baseSprite.position.y -25/2);
        emitter18.position = ccp(baseSprite.position.x -60/2 , baseSprite.position.y -36/2);
        emitter19.position = ccp(baseSprite.position.x +60/2 , baseSprite.position.y -36/2);
        
        [self addChild:emitter z:105];
        [self addChild:emitter1 z:105];
        [self addChild:emitter2 z:105];
        [self addChild:emitter3 z:105];
        [self addChild:emitter4 z:105];
        [self addChild:emitter5 z:105];
        [self addChild:emitter6 z:105];
        [self addChild:emitter7 z:105];
        [self addChild:emitter8 z:105];
        [self addChild:emitter9 z:105];
        [self addChild:emitter10 z:105];
        [self addChild:emitter11 z:105];
        [self addChild:emitter12 z:105];
        [self addChild:emitter13 z:105];
        [self addChild:emitter14 z:105];
        [self addChild:emitter15 z:105];
        [self addChild:emitter16 z:105];
        [self addChild:emitter17 z:105];
        [self addChild:emitter18 z:105];
        [self addChild:emitter19 z:105];
        
        [emitter autoRemoveOnFinish];
        [emitter1 autoRemoveOnFinish];
        [emitter2 autoRemoveOnFinish];
        [emitter3 autoRemoveOnFinish];
        [emitter4 autoRemoveOnFinish];
        [emitter5 autoRemoveOnFinish];
        [emitter6 autoRemoveOnFinish];
        [emitter7 autoRemoveOnFinish];
        [emitter8 autoRemoveOnFinish];
        [emitter9 autoRemoveOnFinish];
        [emitter10 autoRemoveOnFinish];
        [emitter11 autoRemoveOnFinish];
        [emitter12 autoRemoveOnFinish];
        [emitter13 autoRemoveOnFinish];
        [emitter14 autoRemoveOnFinish];
        [emitter15 autoRemoveOnFinish];
        [emitter16 autoRemoveOnFinish];
        [emitter17 autoRemoveOnFinish];
        [emitter18 autoRemoveOnFinish];
        [emitter19 autoRemoveOnFinish];
    }], nil];
    CCSequence *scaleSeq2 = [CCSpawn actions:action,[CCSequence actions: scaleDownAction2,opacity2, nil], nil];
    [star runAction:scaleSeq2];
    [self addChild:star z:107];
}

-(void)displayScore{
    
    CCLabelTTF *scoreaLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"\n%d",(int)gameScore] fontName:@"GROBOLD" fontSize:40];
    CCSprite *blankLayer1 = [CCSprite spriteWithFile:@"blankLayer.png"];
    blankLayer1.position = ccp(self.position.x + screenSize.width/2, -1*self.position.y + screenSize.height/2);
    [pauseImage setIsEnabled:NO];
    if(gotStar==3){
        CCSprite *cup ;
        cup = [CCSprite spriteWithFile:@"cup.png"];
        cup.position = ccp(blankLayer1.position.x, blankLayer1.position.y-30);
        cup.opacity = 0;
        [self addChild:cup z:105];
        CCFadeTo *fadeTo1 = [CCFadeTo actionWithDuration:1 opacity:255];
        [cup runAction:fadeTo1];
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"winning_1.caf"];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.5];
        scorebg = [CCSprite spriteWithFile:@"scorebg.png"];
        scoreaLabel.position = ccp(blankLayer1.position.x,(cup.position.y-cup.contentSize.height/2));
    }else if(gotStar==2){
        scorebg = [CCSprite spriteWithFile:@"you-got-gutts.png"];
        scoreaLabel.position = ccp(blankLayer1.position.x, blankLayer1.position.y-30);
    }else if(gotStar==1){
        scorebg = [CCSprite spriteWithFile:@"you-can-do-better.png"];
        scoreaLabel.position = ccp(blankLayer1.position.x, blankLayer1.position.y-30);
    }else if(gotStar==0){
        CCSprite *sadFace ;
        sadFace = [CCSprite spriteWithFile:@"sad.png"];
        sadFace.position = ccp(blankLayer1.position.x, blankLayer1.position.y-25);
        sadFace.opacity = 0;
        [self addChild:sadFace z:105];
        CCFadeTo *fadeTo1 = [CCFadeTo actionWithDuration:1 opacity:255];
        [sadFace runAction:fadeTo1];
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"sad.caf"];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:2];
        
        scorebg = [CCSprite spriteWithFile:@"that-was-miserable.png"];
        scoreaLabel.position = ccp(blankLayer1.position.x,(sadFace.position.y-sadFace.contentSize.height/2)-8);
    }
    scorebg.position = ccp(self.position.x + screenSize.width/2, -1*self.position.y + screenSize.height/2);
    scorebg.opacity = 0;
    [self addChild:scorebg z:100];
    CCFadeTo *fadeTo = [CCFadeTo actionWithDuration:1 opacity:255];
    [scorebg runAction:fadeTo];
    [self performSelector:@selector(displayStars)];
    
    blankLayer1.opacity = 0;
    [self addChild:blankLayer1 z:98];
    
    fadeTo =[CCFadeTo actionWithDuration:0.5 opacity:150];
    [blankLayer1 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1],fadeTo, nil]];
    CCMenuItemImage *restartMenuImage = [CCMenuItemImage itemWithNormalImage:@"restartedButton.png" selectedImage:@"selectedRestartButton.png" target:self selector:@selector(restartGame)];
    restartMenuImage.scale = 0.73;
    CCMenu *restartMenu1 = [CCMenu menuWithItems:restartMenuImage, nil];
    restartMenu1.position = ccp(blankLayer1.position.x-120, blankLayer1.position.y-120);
    CCMenuItemImage *gotToMainMenuIage = [CCMenuItemImage itemWithNormalImage:@"red-cancel.png" selectedImage:@"red-cancel-press.png" target:self selector:@selector(goToMainMenu)];
    gotToMainMenuIage.scale = 0.73;
    CCMenu *goToMainMenu = [CCMenu menuWithItems:gotToMainMenuIage, nil];
    goToMainMenu.position =ccp(blankLayer1.position.x+120, blankLayer1.position.y-120);
    [self addChild:restartMenu1 z:105];
    [self addChild:goToMainMenu z:105];
    [restartMenuImage runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2.5],[CCCallBlock actionWithBlock:^{
        restartMenuImage.visible = YES;
    }],nil]];
    [gotToMainMenuIage runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2.8],[CCCallBlock actionWithBlock:^{
        gotToMainMenuIage.visible = YES;
    }],nil]];
    
    
    
    
    scoreaLabel.opacity =0;
    [self addChild:scoreaLabel z:106];
    fadeTo = [CCFadeTo actionWithDuration:1 opacity:255];
    [scoreaLabel runAction:fadeTo];
}

-(void) gameOver{
    if(volume){
        [self playBackGroundMusicInDisplayScore];
    }
    mTimeLbl.visible = NO;
    pauseMenu.visible = NO;
    scoreCountLabel.visible = NO;
    countSprite.visible = NO;
    bottomCloud.visible=NO;
    float ratio = (float)takenTotalStars/(float)totalStars;
    ratio = ratio*100;
    if(ratio <20){
        gotStar=0;
    }else if(ratio >= 20 && ratio <45){
        gotStar=1;
    }else if(ratio >=45 && ratio <85){
        gotStar=2;
    }else if(ratio >=85){
        gotStar=3;
    }
    keepMapMoving = false;
    BOOL isHighScore = NO;
    gameScore = sec*10 + min*60*10 + hours*60*60*10 + takenTotalStars*10;
    gameTime =sec + min*60 + hours*60*60;
    if(!gameOver){
        gameOver=YES;
        int i;
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        NSMutableArray *tempTimeArray = [[NSMutableArray alloc] init];
        
        for ( i= 0; i<[gameScores count]; i++) {
            if(gameScore > [[gameScores objectAtIndex:i] doubleValue]){
                [tempArray addObject:[NSNumber numberWithInt:gameScore]];
                [tempTimeArray addObject:[NSNumber numberWithInt:gameTime]];
                break;
            }else{
                [tempArray addObject:[NSNumber numberWithInt:[[gameScores objectAtIndex:i] doubleValue]]];
                [tempTimeArray addObject:[NSNumber numberWithInt:[[gameTimes objectAtIndex:i]doubleValue]]];
            }
        }
        if(i < [gameScores count]-1){
            for(int j = i+1;j<[gameScores count];j++){
                [tempArray addObject:[NSNumber numberWithInt:[[gameScores objectAtIndex:i] doubleValue]]];
                [tempTimeArray addObject:[NSNumber numberWithInt:[[gameTimes objectAtIndex:i++]doubleValue]]];
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:tempArray forKey:@"scores"];
        [[NSUserDefaults standardUserDefaults] setObject:tempTimeArray forKey:@"times"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    [self blastAnimation:isHighScore];
    node->invisible = YES;
    [takenStars removeAllObjects];
    takenStars = nil;
    [starsArray removeAllObjects];
    starsArray = nil;
    [ArrowSprite stopAllActions];
    ArrowSprite.visible= false;
}
-(void) showInstruction{
    blankLayer.position = ccp(self.position.x + screenSize.width/2, screenSize.height/2 + -1*self.position.y);
    introductionScreen = [CCSprite spriteWithFile:@"introduction-screen.png"];
    introductionScreen.position = ccp(self.position.x + screenSize.width/2, screenSize.height/2 + -1*self.position.y);
    [self addChild:introductionScreen z:100];
}
-(void)removeInformation{
    blankLayer.visible = NO;
    gameOver = NO;
    keepMapMoving=TRUE;
    [self removeChild:introductionScreen cleanup:YES];
    [self enablebuttons];
}
-(void)makeBorders{
    ArrowSprite = [CCSprite spriteWithSpriteFrameName:@"errow1.png"];
    [self addChild:ArrowSprite z:2];
    CCOrbitCamera *orbit = [CCOrbitCamera actionWithDuration:2.0f radius:1 deltaRadius:0 angleZ:0 deltaAngleZ:360 angleX:0 deltaAngleX:0];
    NSMutableArray *walkAnimFrames = [NSMutableArray array];
    for (int i=2; i<7; i++) {
        [walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"errow%d.png",i]]];

    }
    CCAnimation *walkAnim = [CCAnimation
                             animationWithSpriteFrames:walkAnimFrames delay:0.02f];
    [ArrowSprite runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnim]]];
    [ArrowSprite runAction:[CCRepeatForever actionWithAction:orbit]];
    spike = [CCSprite spriteWithFile:@"spike.png"];
    spike.tag =6;
    spike.position = ccp(self.position.x+screenSize.width/2, -1*self.position.y+screenSize.height);
    [self addChild:spike];
    
    spikeBodyDef.position.Set((self.position.x+screenSize.width/2)/PTM_RATIO, (-1*self.position.y+screenSize.height)/PTM_RATIO);
    spikeBodyDef.userData = (__bridge void*)spike;
    spikeBody=world->CreateBody(&spikeBodyDef);
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:spikeBody forShapeName:@"spike"];
    
    widthInMeters = (screenSize.width)/ PTM_RATIO;
    heightInMeters = (screenSize.height)  / PTM_RATIO;
    lowerLeftCorner = b2Vec2(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    lowerRightCorner = b2Vec2(self.position.x/PTM_RATIO+widthInMeters, self.position.y/PTM_RATIO);
    upperLeftCorner = b2Vec2(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO+heightInMeters);
    upperRightCorner = b2Vec2(self.position.x/PTM_RATIO+widthInMeters, self.position.y/PTM_RATIO+heightInMeters);
    groundBodyDef.position.Set(0, 0);
    groundBody = world->CreateBody(&groundBodyDef);
    
    
    screenBorderShape.Set(lowerRightCorner, upperRightCorner);
    right = groundBody->CreateFixture(&screenBorderShape, 0);
    screenBorderShape.Set(upperRightCorner, upperLeftCorner);
    top = groundBody->CreateFixture(&screenBorderShape, 0);
    screenBorderShape.Set(upperLeftCorner, lowerLeftCorner);
    left =groundBody->CreateFixture(&screenBorderShape, 0);
    screenBorderShape.Set(lowerLeftCorner, lowerRightCorner);
    
    bottom = groundBody->CreateFixture(&screenBorderShape, 0);
    countSprite = [CCSprite spriteWithFile:@"stern.png"];
    countSprite.visible = NO;
    [self addChild:countSprite z:10];
    scoreCountLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%.3d/%.3d",takenTotalStars,totalStars] fontName:@"Marker Felt" fontSize:fontSize];
    [self addChild:scoreCountLabel z:10];
    scoreCountLabel.visible = NO;
    mTimeLbl = [CCLabelTTF labelWithString:@"00:00:00" fontName:@"DigifaceWide" fontSize:fontSize];
    [self addChild:mTimeLbl z:10];
    countSprite.visible = YES;
    pauseMenu.position = ccp(25,-1*self.position.y + screenSize.height-30);
    pauseMenu.visible = YES;
    scoreCountLabel.visible = YES;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];  
    if (![defaults objectForKey:@"firstRun"]){
        isInstructionShown=YES;
        [self showInstruction];
        [self disablebuttons];
        keepMapMoving=false;
        gameOver = YES;
        [defaults setObject:[NSDate date] forKey:@"firstRun"];
        [defaults synchronize];
    }else{
        keepMapMoving = TRUE;
    }
}
-(void) changeBaselocation:(int)n:(CCTMXTiledMap*)map:(int) obstacleTag:(int)starBodyTag{
    if(addnewMap){
        for(b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {
            if (b->GetUserData() != NULL) {
                CCSprite *tileSprite = (__bridge CCSprite*)b->GetUserData();
                if(tileSprite.tag ==n || tileSprite.tag == obstacleTag){
                    world->DestroyBody(b);
                }
            }
        }
        if(n==1){
            [self removeChild:map1 cleanup:YES];
            map1 = [CCTMXTiledMap tiledMapWithTMXFile:@"bgmap1.tmx"];
            map1.position = ccp(0, map4.position.y-heightMap1);
            [self addChild:map1 z:-1];
            [self givePhysics:map1:heightMap1:1:11:111:NO];
        }else if(n==2){
            [self removeChild:map2 cleanup:YES];
            map2 = [CCTMXTiledMap tiledMapWithTMXFile:@"bgmap2.tmx"];
            heightMap2 = map2.mapSize.height*map2 .tileSize.height/2;
            map2.position = ccp(0,map1.position.y-heightMap2);
            [self addChild:map2 z:-1];
            [self givePhysics:map2:heightMap2:2:22:222:NO];
        }else if(n==3){
            [self removeChild:map3 cleanup:YES];
            map3 = [CCTMXTiledMap tiledMapWithTMXFile:@"bgmap3.tmx"];
            heightMap3 = map3.mapSize.height*map3 .tileSize.height/2;
            map3.position = ccp(0, map2.position.y-heightMap3);
            [self addChild:map3 z:-1];
            [self givePhysics:map3:heightMap3:3:33:333:NO];
        }else if(n==4){
            [self removeChild:map4 cleanup:YES];
            map4 = [CCTMXTiledMap tiledMapWithTMXFile:@"bgmap4.tmx"];
            heightMap4 = map4.mapSize.height*map4 .tileSize.height/2;
            map4.position = ccp(0, map3.position.y-heightMap4);
            [self addChild:map4 z:-1];
            [self givePhysics:map4:heightMap4:4:44:444:NO];
            addnewMap=NO;
        }
    }
    else
    {
        for(b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {
            if (b->GetUserData() != NULL) {
                CCSprite *tileSprite = (__bridge CCSprite*)b->GetUserData();
                if(tileSprite.tag ==n){
                    if(n==3){
                        b->SetTransform(b2Vec2(b->GetPosition().x,(b->GetPosition().y*PTM_RATIO - totalHightOfMaps)/PTM_RATIO), 0);
                    }else{
                        b->SetTransform(b2Vec2(b->GetPosition().x,(b->GetPosition().y*PTM_RATIO - totalHightOfMaps)/PTM_RATIO), 0);
                    }
                    b->SetAwake(true);
                }
                if(tileSprite.tag ==obstacleTag){
                    b->SetTransform(b2Vec2((tileSprite.position.x+tileSprite.contentSize.width/2)/PTM_RATIO,(tileSprite.position.y+map.position.y+tileSprite.contentSize.height/2)/PTM_RATIO), 0);
                    b->SetAwake(true);
                }
                
                
            }
        }
    }
    if(startAdDingStarstoTotalStars-- <= 0){
        totalStars = totalStars + StarsToBeAdded;
    }
    StarsToBeAdded =0;
    
    for(int i=0;i<[starsArray count];i++){
        
        CCSprite *starSprite = [starsArray objectAtIndex:i];
        if(starSprite.tag == n){
            starSprite.position = ccp(starSprite.position.x, starSprite.position.y -totalHightOfMaps);
            starSprite.opacity = 255;
            starSprite.scale = 1;
            StarsToBeAdded++;
        }
    }
    for (int i =0; i<[takenStars count]; i++) {
        CCSprite *sprite = [takenStars  objectAtIndex:i];
        if(sprite.tag == n){
            [takenStars removeObjectAtIndex:i--];
        }
    }
}

-(void) draw {
    //    world->DrawDebugData();
}

-(void)tick:(ccTime)dt{
    count = count +1;
    if((int)count%180 == 0 && doRandomAnimation){
        [node doRandomAnimation];
    }
    if((int)count % 120 == 0 && !doRandomAnimation && keepMapMoving){
        [node makeAnimationDown];
    }
    
    if (!gameOver) {
        int32 velocityIteration = 8;
        int32 positonIteration = 3;
        world->Step(dt, velocityIteration, positonIteration);
        if(node->innerCircleBody->GetLinearVelocity().y < -15){
            node->innerCircleBody->SetLinearVelocity(b2Vec2(node->innerCircleBody->GetLinearVelocity().x, -15));
        }
        if(keepMapMoving){
            spikeBody->SetTransform(b2Vec2(spikeBody->GetPosition().x, (spikeBody->GetPosition().y*PTM_RATIO-speed)/PTM_RATIO), 0);
            CCSprite *spikeSprite = (__bridge CCSprite*)spikeBody->GetUserData();
            spikeSprite.position = ccp(spikeBody->GetPosition().x * PTM_RATIO,
                                       spikeBody->GetPosition().y * PTM_RATIO-8);
            spikeSprite.rotation = -1 * CC_RADIANS_TO_DEGREES(spikeBody->GetAngle());
            gameOver = YES;
            gameOver = NO;
        }
    }
    
    if(setCenter){
        if(node->innerCircleBody->GetPosition().y*PTM_RATIO -100<(3/2)*heightDefaultMap){
            [self makeBorders];
            setCenter = false;
            
        }
    }
}

-(void) update:(ccTime)dt{
    if(playershadow.visible == true){
        prvposition = ((screenSize.height*1.712+screenSize.height)-playerBackground.position.y)/screenSize.height;
        playershadow.scaleX = 1/prvposition;
        playerBackground.position = ccp(node->innerCircleBody->GetPosition().x*PTM_RATIO, node->innerCircleBody->GetPosition().y*PTM_RATIO -5);
    }
    
    if (!gameOver) {
        std::vector<MyContact>::iterator pos;
        for (pos=_contactListener->_contacts.begin();pos != _contactListener->_contacts.end(); ++pos){
            MyContact contact = *pos;
            b2Body *bodyA = contact.fixtureA->GetBody();
            b2Body *bodyB = contact.fixtureB->GetBody();
            if(bodyA && bodyB){
                if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
                    CCSprite *spriteA = (__bridge CCSprite *) bodyA->GetUserData();
                    CCSprite *spriteB = (__bridge CCSprite *) bodyB->GetUserData();
                    if (volume) {
                        if((spriteA.tag==1 && spriteB.tag==5 )||(spriteA.tag==5 && spriteB.tag==1)||(spriteA.tag==2 && spriteB.tag==5)||(spriteA.tag==5 && spriteB.tag==2)||(spriteA.tag==3 && spriteB.tag==5)||(spriteA.tag==5 && spriteB.tag==3)||(spriteA.tag==4 && spriteB.tag==5)||(spriteA.tag==5 && spriteB.tag==4)){
                            
                            if(node->innerCircleBody->GetLinearVelocity().y>9){
                                [[SimpleAudioEngine sharedEngine] playEffect:@"b3_1.caf"];
                                [[SimpleAudioEngine sharedEngine]setEffectsVolume:0.3f];
                            }
                            else if(node->innerCircleBody->GetLinearVelocity().y>4){
                                [[SimpleAudioEngine sharedEngine] playEffect:@"b4_1.caf"];
                                [[SimpleAudioEngine sharedEngine]setEffectsVolume:0.3f];
                            }
                            else if(node->innerCircleBody->GetLinearVelocity().y>2)
                            {
                                [[SimpleAudioEngine sharedEngine] playEffect:@"b5_1.caf"];
                                [[SimpleAudioEngine sharedEngine]setEffectsVolume:0.3f];
                            }
                            
                        }
                    }
                    
                    
                    if((spriteA.tag == 5 && spriteB.tag ==11)||(spriteA.tag == 11 && spriteB.tag ==5)||(spriteA.tag == 5 && spriteB.tag ==22)||(spriteA.tag == 22 && spriteB.tag ==5)||(spriteA.tag == 5 && spriteB.tag ==33)||(spriteA.tag == 33 && spriteB.tag ==5)||(spriteA.tag == 5 && spriteB.tag ==44)||(spriteA.tag == 44 && spriteB.tag ==5)||(spriteA.tag == 5 && spriteB.tag ==6)||(spriteA.tag == 6 && spriteB.tag ==5)){
                        spike.visible = NO;
                        [self gameOver];
                    }
                }
            }
        }
        if(node){
            CGRect Ball = CGRectMake((node->innerCircleBody->GetPosition().x*PTM_RATIO)-15,(node->innerCircleBody->GetPosition().y*PTM_RATIO)-15,30, 30);
            
            for (int i =0 ; i < [starsArray count]; i++) {
                CCSprite *starSprite = [starsArray objectAtIndex:i];
                
                CGRect targetRect = CGRectMake(
                                               starSprite.position.x - (starSprite.contentSize.width/2),
                                               starSprite.position.y - (starSprite.contentSize.height/2),
                                               starSprite.contentSize.width,
                                               starSprite.contentSize.height);
                
                if(CGRectIntersectsRect(Ball,targetRect)||CGRectContainsRect(Ball, targetRect)){
                    if(![takenStars containsObject:starSprite]){
                        CCFadeTo *fadeTo = [CCFadeTo actionWithDuration:0.5 opacity:0];
                        CCScaleBy *scaleTo = [CCScaleBy actionWithDuration:0.5 scale:4];
                        CCParticleSystem *system = [CCParticleSystemQuad particleWithFile:@"stars.plist"];
                        system.texture = [[CCTextureCache sharedTextureCache] addImage: @"stern.png"];
                        system.position = ccp(starSprite.position.x,starSprite.position.y);
                        system.life = 1;
                        system.lifeVar = 1;
                        system.autoRemoveOnFinish = YES;
                        [self addChild:system z:1];
                        [starSprite runAction:[CCSpawn actions:fadeTo,scaleTo,[CCCallBlock actionWithBlock:^{
                            if (volume) {
                                [[SimpleAudioEngine sharedEngine]setEffectsVolume:1.0f];
                                [[SimpleAudioEngine sharedEngine] playEffect:@"starcollect_1.caf"];
                            }
                            
                        }],nil]];
                        [takenStars addObject:starSprite];
                        takenTotalStars++;
                    }
                    
                }
            }
        }
        
        if ((findNewBodyForArrow==true)&&keepMapMoving) {
            int smallestDistance = 10000;
            std::vector<ArrowBodys>::iterator arrowPos;
            for (arrowPos=_arrowBody.begin(); arrowPos!=_arrowBody.end(); ++arrowPos) {
                ArrowBodys body = *arrowPos;
                b2Body *arrowSingleBody = body.body;
                if(-1*self.position.y-arrowSingleBody->GetPosition().y*PTM_RATIO<smallestDistance){
                    toBeDeletedArrow=arrowPos;
                    ArrowXPosition=arrowSingleBody->GetPosition().x*PTM_RATIO;
                    showArrowUpto=arrowSingleBody->GetPosition().y*PTM_RATIO-32;
                    smallestDistance=-1*self.position.y-arrowSingleBody->GetPosition().y*PTM_RATIO;
                    ArrowSprite.position = ccp(arrowSingleBody->GetPosition().x*PTM_RATIO, -1*self.position.y+40);
                }
            }
            if (removeArrowBody) {
                _arrowBody.erase(toBeDeletedArrow);
            }
            findNewBodyForArrow=false;
            ArrowSprite.visible = true;
        }
        
    }
    if(keepMapMoving){
        int y = self.position.y;
        y = y+speed;
        self.position = ccp(self.position.x, y);
        
        if(-1*self.position.y<makeMapVisible){
            if(toMakeMapVisible==1){
                map1.visible = YES;
                toMakeMapVisible=2;
                makeMapVisible=map1.position.y+heightMap1/2;
            }else if(toMakeMapVisible==2){
                map2.visible=YES;
                toMakeMapVisible=3;
                makeMapVisible=map2.position.y+heightMap2/2;
            }else if(toMakeMapVisible==3){
                map3.visible=YES;
                toMakeMapVisible=4;
                makeMapVisible=map3.position.y+heightMap3/2;
            }else if(toMakeMapVisible==4){
                map4.visible=YES;
                toMakeMapVisible=1;
                makeMapVisible=map4.position.y+heightMap4/2;
            }
        }
        if(!makeBorders){
            makeBorders = true;
        }
        
        groundBody->DestroyFixture(top);
        groundBody->DestroyFixture(bottom);
        groundBody->DestroyFixture(left);
        groundBody->DestroyFixture(right);
        
        lowerLeftCorner = b2Vec2(self.position.x/PTM_RATIO, -1 * self.position.y/PTM_RATIO);
        lowerRightCorner = b2Vec2(self.position.x/PTM_RATIO+widthInMeters, -1 * self.position.y/PTM_RATIO);
        upperLeftCorner = b2Vec2(self.position.x/PTM_RATIO, -1 * self.position.y/PTM_RATIO+heightInMeters);
        upperRightCorner = b2Vec2(self.position.x/PTM_RATIO+widthInMeters, -1 * self.position.y/PTM_RATIO+heightInMeters);
        groundBodyDef.position.Set(0, 0);
        
        screenBorderShape.Set(lowerLeftCorner, lowerRightCorner);
        bottom = groundBody->CreateFixture(&screenBorderShape, 0);
        screenBorderShape.Set(lowerRightCorner, upperRightCorner);
        right = groundBody->CreateFixture(&screenBorderShape, 0);
        screenBorderShape.Set(upperRightCorner, upperLeftCorner);
        top = groundBody->CreateFixture(&screenBorderShape, 0);
        screenBorderShape.Set(upperLeftCorner, lowerLeftCorner);
        left =groundBody->CreateFixture(&screenBorderShape,0);
        mTimeInSec +=dt;
        
        float digit_min = mTimeInSec/60.0f;
        float digit_hour = (digit_min)/60.0f;
        float digit_sec = ((int)mTimeInSec%60);
        
        min = (int)digit_min;
        if(min == speedUpTime){
            speedUpTime ++;
            speed = speed + 0.5;
        }
        hours = (int)digit_hour;
        sec = (int)digit_sec;
        [scoreCountLabel setString:[NSString stringWithFormat:@"%.3d/%.3d",takenTotalStars,totalStars]];
        scoreCountLabel.position=ccp(screenSize.width-50, -1*self.position.y + screenSize.height-30);
        mTimeLbl.position = ccp(self.position.x + screenSize.width/2-30, -1*self.position.y + screenSize.height-30);
        [mTimeLbl setString:[NSString stringWithFormat:@"Time-%.2d:%.2d:%.2d",hours, min,sec]];
        pauseMenu.position = ccp(25,-1*self.position.y + screenSize.height-30);
        countSprite.position = ccp(screenSize.width-93, -1*self.position.y + screenSize.height-30);
        blankLayer.position = ccp(self.position.x + screenSize.width/2, screenSize.height/2 + -1*self.position.y);
        bottomCloud.position = ccp(screenSize.width/2, -1*self.position.y+bottomCloud.contentSize.height/2);
        ArrowSprite.position = ccp(ArrowSprite.position.x, -1*self.position.y+40);
        if(!pauseMenu.visible){
            pauseMenu.visible = YES;
        }
        if (-1*self.position.y<showArrowUpto) {
            findNewBodyForArrow=true;
            ArrowSprite.visible = false;
        }
        if(-1*self.position.y < nextUpdateMapPosition){
            if(nextUpdateMap == 1){
                if(!addnewMap){
                    map1.position = ccp(map1.position.x, map4.position.y -heightMap1 );
                }
                nextUpdateMap = 2;
                nextUpdateMapPosition = map4.position.y;
                [self changeBaselocation:1:map1:11:111];
            }else if(nextUpdateMap == 2){
                if(!addnewMap){
                    map2.position = ccp(map2.position.x, map1.position.y -heightMap2);
                }
                nextUpdateMap = 3;
                nextUpdateMapPosition = map1.position.y;
                [self changeBaselocation:2:map2:22:222];
            }else if(nextUpdateMap == 3){
                if(!addnewMap){
                    map3.position = ccp(0, map2.position.y-heightMap3);
                }
                nextUpdateMap = 4;
                nextUpdateMapPosition = map2.position.y;
                [self changeBaselocation:3:map3:33:333];
            }else if(nextUpdateMap == 4){
                if(!addnewMap){
                    map4.position = ccp(0, map3.position.y-heightMap4);
                }
                nextUpdateMap = 1;
                nextUpdateMapPosition = map3.position.y;
                [self changeBaselocation:4:map4:44:444];
            }
        }
        
    }
}
+(id)nodeWithGameLevel:(int)level{
    return  [[self alloc] initWithGameLevel:level];
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
    if(!setCenter){
        b2Vec2 gravity(acceleration.x * 30, -50);
        world->SetGravity(gravity);
    }
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!setCenter) {
        UITouch *touchpoint = [touches anyObject];
        CGPoint firstlocation = [touchpoint locationInView:[touchpoint view]];
        firstlocation = [[CCDirector sharedDirector] convertToGL:firstlocation];
        [node bounce:firstlocation];
    }
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];
    UITouch * touch = [[allTouches allObjects] objectAtIndex:0];
    CGPoint endpoint = [touch locationInView:[touch view]];
    endpoint = [[CCDirector sharedDirector] convertToGL:endpoint];
    if(!playbtnpressed){
        endpoint = [frame_normal convertToNodeSpace:endpoint];
        BOOL touchedCard = CGRectContainsPoint([frame_normal textureRect], endpoint);
        if(touchedCard){
            [self playBtnPress];
            playbtnpressed = YES;
        }
    }
    
    if(isInstructionShown){
        [self removeInformation];
        isInstructionShown = false;
    }
    
}

-(void)cleanup{
    [super cleanup];
}

@end