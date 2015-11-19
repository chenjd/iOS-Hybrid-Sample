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
    
    //load external webpage
//    NSURLRequest *urlReq =[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    
    //load yexiaochai's html
    NSBundle *thisBundle = [NSBundle mainBundle];
    NSString *path = [thisBundle pathForResource:@"webapp/hotel/index" ofType:@"html"];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSURLRequest *urlReq = [NSURLRequest requestWithURL:baseURL];
    [self.view addSubview: webView];
    [webView loadRequest:urlReq];
    
    //native call js && load html string
//    [webView loadHTMLString:@"<html><head><script language = 'JavaScript'>function msg(text){alert(text);}</script></head><body style=\"background-color: #0ff000; color: #FFFFFF; font-family: Helvetica; font-size: 10pt; width: 300px; word-wrap: break-word;\"><button type='button' onclick='msg()' >web按钮</button></body></html>" baseURL:nil];
//    [self.view addSubview: webView];

//    
//    

}

//创建button
- (UIButton*)createCtrlButton : (CGRect) rect: (NSString*) title : (SEL) cb{
    UIButton *nativeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    nativeButton.frame = rect;
    nativeButton.backgroundColor = [UIColor clearColor];
    [nativeButton setTitle:title forState:UIControlStateNormal];
    [nativeButton addTarget:self action:@selector(cb) forControlEvents:UIControlEventTouchUpInside];
    return nativeButton;
}

//用来创建一个UITextField，用来在native调用js时向js的函数传送参数
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
    UIButton *nativeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    nativeButton.frame = CGRectMake(20, 350, 280, 20);
    nativeButton.backgroundColor = [UIColor clearColor];
    [nativeButton setTitle:@"native调用web" forState:UIControlStateNormal];
    [nativeButton addTarget:self action:@selector(btnClickMsg) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nativeButton];
}

//native call js
- (void)btnClickMsg{
    [msg setString:@"msg('"];
    [msg appendString:[msgText text]];
    [msg appendString:@"')"];
    [webView stringByEvaluatingJavaScriptFromString:msg];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
