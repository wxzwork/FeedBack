//
//  ViewController.m
//  意见反馈与评分
//
//  Created by WOSHIPM on 16/7/11.
//  Copyright © 2016年 WOSHIPM. All rights reserved.
//

#import "ViewController.h"
#import <YWFeedbackFMWK/YWFeedbackKit.h>
#import "TWMessageBarManager.h"
#import <StoreKit/StoreKit.h>

@interface ViewController ()<SKStoreProductViewControllerDelegate>
@property (nonatomic,   weak) UINavigationController *weakDetailNavigationController;
@property (nonatomic, strong) YWFeedbackKit *feedbackKit;
@property (nonatomic, assign) YWEnvironment environment;
@property (nonatomic, strong) NSString *appKey;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //阿里百川反馈包中的yw_1222.jpg需要换成你自己的，你在阿里百川平台上申请成功后下载SDK就会包含自己的yw_1222.jpg
    self.title = @"意见反馈与给app评分";
    self.view.backgroundColor = [UIColor whiteColor];
//    替换成你在阿里百川申请的appkey
    self.appKey = @"23404705";
    self.environment = YWEnvironmentRelease;
    
    UIButton *feedbackButton = [UIButton buttonWithType:UIButtonTypeSystem];
    feedbackButton.frame = CGRectMake(100, 150, 100, 50);
    [self.view addSubview:feedbackButton];
    [feedbackButton setTitle:@"意见反馈" forState:UIControlStateNormal];
    [feedbackButton addTarget:self action:@selector(actionOpenFeedback) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *markButton = [UIButton buttonWithType:UIButtonTypeSystem];
    markButton .frame = CGRectMake(100, 200, 100, 50);
    [self.view addSubview:markButton];
    [markButton setTitle:@"评分" forState:UIControlStateNormal];
    [markButton addTarget:self action:@selector(markButtonAction) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)markButtonAction{
//    //第一种评分方式： 跳转到AppStore评分,去AppStore将自己的app地址拷贝下来
//    NSString *baseUrl = @"你的app地址" ;
//    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:baseUrl]];
    
    
// 第二种评分方式： 应用内给app评分，可返回之前的页面
    SKStoreProductViewController *storeProductVC =[[SKStoreProductViewController alloc]init];
    
        storeProductVC.delegate = self;
    
        //第一个参数为应用标识id构成的字典。第二个参数是一个block回调。
    NSString *str = @"appStore上的ID";
        [storeProductVC loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier: str } completionBlock:^(BOOL result, NSError *error) {
    
            if (result) {
    
    
    
                [self presentViewController:storeProductVC animated:YES completion:^{
    
                }];
    
    
    
            }else{
    
                NSLog(@"错误：%@" ,error);
    
            }
    
        }];
}



//SKStoreProductViewController代理方法

-(void)productViewControllerDidFinish:(SKStoreProductViewController*)viewController

{
    
    //返回上一个页面
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


#pragma mark -- 调起意见反馈
- (void )actionOpenFeedback{
    self.tabBarController.tabBar.hidden = YES;
    //    替换成你在阿里百川申请的appkey
    self.appKey = @"23404705";
    
    self.feedbackKit = [[YWFeedbackKit alloc] initWithAppKey:self.appKey];
    
    _feedbackKit.environment = self.environment;
    
#warning 设置App自定义扩展反馈数据
    _feedbackKit.extInfo = @{@"loginTime":[[NSDate date] description],
                             @"visitPath":@"登陆->关于->反馈",
                             @"应用自定义扩展信息":@"开发者可以根据需要设置不同的自定义信息，方便在反馈系统中查看"};
#warning 自定义反馈页面配置
    _feedbackKit.customUIPlist = [NSDictionary dictionaryWithObjectsAndKeys:@"/te\'st\\Value1\"", @"testKey1", @"test<script>alert(\"error.yaochen\")</alert>Value2", @"testKey2", nil];
    
    [self _openFeedbackViewController];
}


#pragma mark 弹出反馈页面
- (void)_openFeedbackViewController
{
    __weak typeof(self) weakSelf = self;
    
    [_feedbackKit makeFeedbackViewControllerWithCompletionBlock:^(YWFeedbackViewController *viewController, NSError *error) {
        if ( viewController != nil ) {
#warning 这里可以设置你需要显示的标题以及nav的leftBarButtonItem，rightBarButtonItem
            viewController.title = @"意见反馈";
            //
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
            
          
            [self.navigationController pushViewController:viewController animated:YES];
            
            viewController.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
            self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
            viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:weakSelf action:@selector(cancelButtonAction)];
            viewController.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1];
            viewController.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1],NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:18]};
            viewController.tabBarController.tabBar.hidden = YES;
            
            
            __weak typeof(nav) weakNav = nav;
            
            [viewController setOpenURLBlock:^(NSString *aURLString, UIViewController *aParentController) {
                UIViewController *webVC = [[UIViewController alloc] initWithNibName:nil bundle:nil];
                UIWebView *webView = [[UIWebView alloc] initWithFrame:webVC.view.bounds];
                webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
                
                [webVC.view addSubview:webView];
                [weakNav pushViewController:webVC animated:YES];
                [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:aURLString]]];
            }];
        } else {
            NSString *title = [error.userInfo objectForKey:@"msg"]?:@"接口调用失败，请保持网络通畅！";
            
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:title description:nil
                                                                  type:TWMessageBarMessageTypeError];
        }
    }];
}

-(void)cancelButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
