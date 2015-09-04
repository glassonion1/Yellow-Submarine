//
//  GLSurfaceView.m
//  Sample1
//
//  Created by Taisuke Fujita on 2015/08/21.
//  Copyright (c) 2015年 Taisuke Fujita. All rights reserved.
//

#import "GLSurfaceView.h"


// シェーダーをコンパイルする関数
GLuint compileShader(GLuint shaderType, const GLchar *source)
{
  // シェダーオブジェクト生成
  GLuint shader = glCreateShader(shaderType);
  // シェーダーオブジェクトとソースコードを結びつける
  glShaderSource(shader, 1, &source, NULL);
  // GLSLのコンパイル
  glCompileShader(shader);
  
  // エラーチェック
  GLint result;
  glGetShaderiv(shader, GL_COMPILE_STATUS, &result);
  // ログを取得
  if (result == GL_FALSE) {
    // サイズを取得
    GLint log_length;
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &log_length);
    
    // 文字列を取得
    GLsizei max_length;
    GLsizei length;
    GLchar log[max_length];
    glGetShaderInfoLog(shader, max_length, &length, log);
    NSLog(@"%s", log);
  }
  assert(result == GL_TRUE);
  return shader;
}


@implementation GLSurfaceView {
  EAGLContext *_context;
  GLuint _shaderProgram;
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
  
  
  // 頂点シェーダーソースコード
  const GLchar *vertShaderSource = "attribute mediump vec4 pos;"
                                   "void main() {"
                                   "  gl_Position = pos;"
                                   "}";
  // 頂点シェダーオブジェクト生成
  GLuint vertShader = compileShader(GL_VERTEX_SHADER, vertShaderSource);
  
  // フラグメントシェーダーソースコード
  const GLchar *fragShaderSource = "void main() {"
                                   "  gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);"
                                   "}";
  // フラグメントシェダーオブジェクト生成
  GLuint fragShader = compileShader(GL_FRAGMENT_SHADER, fragShaderSource);
  
  // プログラムオブジェクトの生成
  _shaderProgram = glCreateProgram();
  // 頂点シェーダーとプログラムオブジェクトを結びつける
  glAttachShader(_shaderProgram, vertShader);
  // フラグメントシェーダーとプログラムオブジェクトを結びつける
  glAttachShader(_shaderProgram, fragShader);
  // リンク
  glLinkProgram(_shaderProgram);
  
  // シェーダーオブジェクトの解放
  glDeleteShader(vertShader);
  glDeleteShader(fragShader);
  
  GLint linked;
  glGetProgramiv(_shaderProgram, GL_LINK_STATUS, &linked);
  if (linked == GL_FALSE) {
    NSLog(@"%@", @"リンクエラー");
  }
  
  // シェーダーの利用を開始する
  glUseProgram(_shaderProgram);
  
  // 背景色の設定
  glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT);
}

- (void)layoutSubviews
{
  // ViewPortの設定
  glViewport(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)update:(NSTimer *)timer
{
  // 頂点シェーダーのpos変数の位置を取得する
  GLint posLocation = glGetAttribLocation(_shaderProgram, "pos");
  // pos変数へのアクセスを有効にする
  glEnableVertexAttribArray(posLocation);
  // 頂点データ
  const GLfloat vertex[] = {
    0.0f, 0.5f,
    -0.5f, -0.5f,
    0.5f, -0.5f,
  };
  // 頂点データを作成する
  glVertexAttribPointer(posLocation, 2, GL_FLOAT, GL_FALSE, 0, vertex);
  // 描画する
  glDrawArrays(GL_TRIANGLES, 0, 3);
  
  [_context presentRenderbuffer:GL_RENDERBUFFER];
  /*
  GLfloat rgba[4];
  glGetFloatv(GL_COLOR_CLEAR_VALUE, rgba);
  NSLog(@"%f %f %f %f", rgba[0], rgba[1], rgba[2], rgba[3]);
   */
}

- (void)dealloc
{
  // シェーダーの利用を終了する
  glUseProgram(0);
  // シェーダープログラムの解放
  glDeleteProgram(_shaderProgram);
}

@end