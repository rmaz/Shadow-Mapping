//
//  ShadowMapping
//
//  Created by Richard on 62/3/12.
//  Copyright (c) 2012 BDP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDPShadowBuffer : NSObject

@property (nonatomic, assign, readonly) GLuint bufferID;
@property (nonatomic, assign, readonly) GLuint depthTexture;
@property (nonatomic, assign, readonly) CGSize bufferSize;

@end
