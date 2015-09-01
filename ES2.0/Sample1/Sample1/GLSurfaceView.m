//
//  GLSurfaceView.m
//  Sample1
//
//  Created by Taisuke Fujita on 2015/08/21.
//  Copyright (c) 2015年 Taisuke Fujita. All rights reserved.
//

#import "GLSurfaceView.h"

@implementation GLSurfaceView {
  EAGLContext *_context;
}

+ (Class)layerClass {
  return [CAEAGLLayer class];
}

// ストーリーボードから呼ばれるイニシャライザ
- (instancetype)initWithCoder:(NSCoder*)coder
{
  if ((self = [super initWithCoder:coder])) {
    [self setUp];
    // ゲームループ
    [NSTimer scheduledTimerWithTimeInterval:1/60.0f target:self selector:@selector(update:) userInfo:nil repeats:YES];
  }
  return self;
}

- (void)setUp
{
  // レイヤーのセットアップ
  CAEAGLLayer *layer = (CAEAGLLayer*)self.layer;
  layer.opaque = YES;
  // コンテキストオブジェクトのセットアップ
  _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
  [EAGLContext setCurrentContext:_context];
  // レンダーバッファーのセットアップ
  GLuint renderBuffer;
  glGenRenderbuffers(1, &renderBuffer);
  glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
  [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
  // フレームバッファーのセットアップ
  GLuint frameBuffer;
  glGenFramebuffers(1, &frameBuffer);
  glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
}

- (void)update:(NSTimer *)timer
{
  glClearColor(0, 1.0f, 1.0f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT);
  [_context presentRenderbuffer:GL_RENDERBUFFER];
  /*
  GLfloat rgba[4];
  glGetFloatv(GL_COLOR_CLEAR_VALUE, rgba);
  NSLog(@"%f %f %f %f", rgba[0], rgba[1], rgba[2], rgba[3]);
   */
}

@end
