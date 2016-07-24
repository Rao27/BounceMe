#import <Foundation/Foundation.h>
#import <Box2D.h>
@interface GB2ShapeCache : NSObject 
{
    NSMutableDictionary *shapeObjects_;
    float ptmRatio_;
}

+ (GB2ShapeCache *)sharedShapeCache;
-(void) addShapesWithFile:(NSString*)plist;
-(void) addFixturesToBody:(b2Body*)body forShapeName:(NSString*)shape;
-(CGPoint) anchorPointForShape:(NSString*)shape;
-(float) ptmRatio;
@end
