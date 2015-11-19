//
//  ViewController.m
//  hy
//
//  Created by chenjd on 15/11/17.
//  Copyright © 2015年 chenjd. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    webView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.view addSubview: webView];
    
    UIButton *button1 = [self createCtrlButton:CGRectMake(20, 550, 300, 100) :@"native call js sample" :@selector(createNativeCallJsSample)];
    [self.view addSubview:button1];
    
    UIButton *button2 = [self createCtrlButton:CGRectMake(20, 600, 300, 100) :@"js call native sample" :@selector(createJsCallNativeSample)];
    [self.view addSubview:button2];
}

//创建button
- (UIButton*)createCtrlButton : (CGRect) rect : (NSString*) title : (SEL) action{
    UIButton *nativeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    nativeButton.frame = rect;
    nativeButton.backgroundColor = [UIColor clearColor];
    [nativeButton setTitle:title forState:UIControlStateNormal];
    [nativeButton addTarget:self action: action forControlEvents:UIControlEventTouchUpInside];
    return nativeButton;
}

///////#region Native 调用 Js

//打开native调用js的例子
- (void)createNativeCallJsSample{
    [webView loadHTMLString:@"<html><head><script language = 'JavaScript'>function msg(text){alert(text);}</script></head><body style=\"background-color: #0ff000; color: #FFFFFF; font-family: Helvetica; font-size: 10pt; width: 300px; word-wrap: break-word;\"><button type='button' onclick=\"msg('Js调用')\" style=\"margin:30 auto;width:100;height:25;\">web button</button></body></html>" baseURL:nil];
    [self createNativeTextField];
    [self createNativeCallJsButton];
}

//创建一个UITextField，用来在native调用js时向js的函数传送参数
- (void)createNativeTextField{
    msgText = [[UITextField alloc] initWithFrame:CGRectMake(10, 400, 300, 40)];
    msgText.borderStyle = UITextBorderStyleRoundedRect;
    msgText.font = [UIFont systemFontOfSize:15];
    msgText.placeholder = @"传入js的msg函数的参数";
    msgText.autocorrectionType = UITextAutocorrectionTypeNo;
    msgText.keyboardType = UIKeyboardTypeDefault;
    msgText.returnKeyType = UIReturnKeyDone;
    msgText.clearButtonMode = UITextFieldViewModeWhileEditing;
    msgText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:msgText];
    msg = [[NSMutableString alloc] init];
}

//创建一个按钮,用来演示Native调用js
- (void)createNativeCallJsButton{
    nativeCallJsBtn = [self createCtrlButton : CGRectMake(20, 350, 280, 20) : @"native调用web" : @selector(btnClickMsg)];
    [self.view addSubview:nativeCallJsBtn];
}

//native call js
- (void)btnClickMsg{
    [msg setString:@"msg('"];
    [msg appendString:@"native调用js："];
    [msg appendString:[msgText text]];
    [msg appendString:@"')"];
    [webView stringByEvaluatingJavaScriptFromString:msg];
}
/////////#endregion


///////#region JS 调用 Native
//打开js调用native的例子
-(void)viewWillAppear:(BOOL)animated{
    webView.delegate = self;
}

//
-(void) initTestView{
    [msgText removeFromSuperview];
    [nativeCallJsBtn removeFromSuperview];
}
//加载叶小钗的web页面
- (void)createJsCallNativeSample{
    [self initTestView];
    //load yexiaochai's html
    NSBundle *thisBundle = [NSBundle mainBundle];
    NSString *path = [thisBundle pathForResource:@"webapp/hotel/index" ofType:@"html"];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSURLRequest *urlReq = [NSURLRequest requestWithURL:baseURL];
    [webView loadRequest:urlReq];
}
//按照和web端规定的格式，获取数据
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL * url = [request URL];
    if ([[url scheme] isEqualToString:@"hybrid"]) {
        
        NSString *actionType = request.URL.host;
        NSDictionary *actionDict = [self getDicFromUrl : url];
        [self doActionType:actionType : actionDict];
        return NO;
    }
    return YES;
}

//从url中获取web传来的参数
- (NSDictionary *) getDicFromUrl : (NSURL *)url{
    NSArray* paramArray = [[url query] componentsSeparatedByString:@"param="];
    NSString* paramStr = paramArray[1];
    NSString *jsonDictString = [paramStr stringByRemovingPercentEncoding];
    NSData *jsonData = [jsonDictString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&e];
    return dict;
}
//根据web的指示，native端相应的做出回应
-(void) doActionType : (NSString*) type : (NSDictionary*) dict{
    
    if ([type isEqualToString:@"forward"]) {
        [webView goForward];
    }
    if([dict[@"type"] isEqualToString: @"webview"]){
        [self web2Web: dict[@"topage"]];
    }
    else if ([dict[@"type"] isEqualToString: @"native"]){
        [self web2Native];
    }

}

//Web通过Native新建一个新的Web
-(void) web2Web : (NSString*) topage{
    NSBundle *thisBundle = [NSBundle mainBundle];
    NSString *path = [thisBundle pathForResource:topage ofType:@"html"];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSURLRequest *urlReq = [NSURLRequest requestWithURL:baseURL];
    [webView loadRequest:urlReq];
}

//Web通过Native新建一个新的Native页面
-(void) web2Native{
    UIAlertController * alertView = [UIAlertController alertControllerWithTitle:@"Native控件" message:@"通过Web页面创建的Native控件" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alertView addAction:defaultAction];
    [self presentViewController:alertView animated:YES completion:nil];

}

/////////#endregion




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
