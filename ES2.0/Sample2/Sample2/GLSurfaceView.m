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
  GLuint shaderProgram;
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
  
  // 頂点シェダーオブジェクト生成
  GLuint vertShader = glCreateShader(GL_VERTEX_SHADER);
  // 頂点シェーダーソースコード
  const char *vertShaderSource = "attribute mediump vec4 pos;"
                                 "void main() {"
                                 "  gl_Position = pos;"
                                 "}";
  // シェーダーオブジェクトとソースコードを結びつける
  glShaderSource(vertShader, 1, &vertShaderSource, NULL);
  // GLSLのコンパイル
  glCompileShader(vertShader);
  
  {
    // エラーチェック
    GLint result;
    glGetShaderiv(vertShader, GL_COMPILE_STATUS, &result);
    
    // ログを取得
    if (result == GL_FALSE) {
      // サイズを取得
      GLint log_length;
      glGetShaderiv(vertShader, GL_INFO_LOG_LENGTH, &log_length);
      
      // 文字列を取得
      GLsizei max_length;
      GLsizei length;
      GLchar log[max_length];
      glGetShaderInfoLog(vertShader, max_length, &length, log);
      NSLog(@"%s", log);
    }
  }
  
  
  
  // フラグメントシェダーオブジェクト生成
  GLuint fragShader = glCreateShader(GL_FRAGMENT_SHADER);
  // フラグメントシェーダーソースコード
  const char *fragShaderSource = "void main() {"
                                 "  gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);"
                                 "}";
  // シェーダーオブジェクトとソースコードを結びつける
  glShaderSource(fragShader, 1, &fragShaderSource, NULL);
  // GLSLのコンパイル
  glCompileShader(fragShader);
  
  // プログラムオブジェクトの生成
  shaderProgram = glCreateProgram();
  // 頂点シェーダーとプログラムオブジェクトを結びつける
  glAttachShader(shaderProgram, vertShader);
  // フラグメントシェーダーとプログラムオブジェクトを結びつける
  glAttachShader(shaderProgram, fragShader);
  // リンク
  glLinkProgram(shaderProgram);
  GLint linked;
  glGetProgramiv(shaderProgram, GL_LINK_STATUS, &linked);
  if (linked == GL_FALSE) {
    NSLog(@"%@", @"リンクエラー");
  }
  
  // シェーダーの利用を開始する
  glUseProgram(shaderProgram);
}

- (void)layoutSubviews
{
  glViewport(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)update:(NSTimer *)timer
{
  // カラーバッファのクリア
  glClear(GL_COLOR_BUFFER_BIT);
  // 頂点シェーダーのpos変数の位置を取得する
  GLint posLocation = glGetAttribLocation(shaderProgram, "pos");
  // 頂点データアクセスを有効にする
  glEnableVertexAttribArray(posLocation);
  // 頂点データ
  GLfloat vertex[] = {
    0.0f, 0.5f, 0.0f,
    -0.5f, -0.5f, 0.0f,
    0.5f, -0.5f, 0.0f
  };
  // 頂点データを作成する
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, vertex);
  // 描画する
  glDrawArrays(GL_TRIANGLES, 0, 3);
  
  [_context presentRenderbuffer:GL_RENDERBUFFER];
  /*
  GLfloat rgba[4];
  glGetFloatv(GL_COLOR_CLEAR_VALUE, rgba);
  NSLog(@"%f %f %f %f", rgba[0], rgba[1], rgba[2], rgba[3]);
   */
}

@end
