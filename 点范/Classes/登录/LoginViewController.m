//
//  LoginViewController.m
//  点范
//
//  Created by Masteryi on 16/9/5.
//  Copyright © 2016年 Masteryi. All rights reserved.
//

#import "LoginViewController.h"
#import "DFRegisterViewController.h"
#import "DFButton.h"
#import "DFHomeViewController.h"
#import "AFNetworking.h"
#import "DFUser.h"
#import "SVProgressHUD.h"
#import "DFForgetPassword.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSnsPlatformManager.h"
#import "UMSocial.h"
#import "DFHTTPSessionManager.h"
#import "UMSocialDataService.h"
#import<CommonCrypto/CommonDigest.h>  

@interface LoginViewController ()<UMSocialUIDelegate>
/** 登录按钮 **/
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
/** 电话号码 **/
@property (weak, nonatomic) IBOutlet UITextField *accont;
/** 密码 **/
@property (weak, nonatomic) IBOutlet UITextField *pwdText;
/** 网络 */
@property (nonatomic,strong)DFHTTPSessionManager *manager;

@property (nonatomic,assign) NSString *usid;

@property (nonatomic,strong)NSString *token;

@property (nonatomic,strong)NSString *username;

//@property (nonatomic,strong) NSNumber* code;


@end

@implementation LoginViewController

- (DFHTTPSessionManager *)manager{
    if (!_manager) {
        _manager = [DFHTTPSessionManager manager];
        
    }
    return _manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"登录";
    //输入框添加监听
    self.loginBtn.enabled = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged) name:UITextFieldTextDidChangeNotification object:nil];
    
    //设置按钮
    [self.loginBtn CornerAndShdow];
    
    //登录事件
    [self.loginBtn addTarget:self action:@selector(loginSuccess) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)QQLogin:(id)sender {
    UMSocialDataService *service = [[UMSocialDataService alloc]init];
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        //          获取微博用户名、uid、token等
        
        if (response.responseCode == UMSResponseCodeSuccess) {
            NSDictionary *dict = [UMSocialAccountManager socialAccountDictionary];
        
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:snsPlatform.platformName];
            NSLog(@"%@",snsAccount.iconURL);
            //本地保存
            NSString *url = [AccountAPI stringByAppendingString:apiStr(@"thPartyLogin.htm")];
            
            NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
            parameter[@"openId"] = snsAccount.usid;
            [self.manager POST:url parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"%@",responseObject);
                //数据存储
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                [userDefault setObject:snsAccount.userName forKey:@"username"];
                [userDefault setObject:responseObject[@"data"][@"token"] forKey:@"token"];
                [userDefault setObject:snsAccount.iconURL forKey:@"icon"];
                [userDefault synchronize];
                [[DFUser sharedManager]initWithDict:userDefault];
                [[DFUser sharedManager]saveIcon:userDefault];
                
               
                [self back];

                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"%@",error);
            }];
            
        }});
    
    
    
}

/**
 第三方登录数据持久化
 */
- (void)loginThiid{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:self.username forKey:@"username"];
    [userDefault setObject:self.token forKey:@"token"];
    [userDefault synchronize];
    [[DFUser sharedManager]initWithDict:userDefault];
    [self back];
    
    NSLog(@"username = %@,token = %@",[DFUser sharedManager].username,[DFUser sharedManager].token);
}


- (IBAction)weChatLogin:(id)sender {
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        //          获取微博用户名、uid、token等
        
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            NSDictionary *dict = [UMSocialAccountManager socialAccountDictionary];
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:snsPlatform.platformName];
            
            NSLog(@"\nusername = %@,\n usid = %@,\n token = %@ iconUrl = %@,\n unionId = %@,\n thirdPlatformUserProfile = %@,\n thirdPlatformResponse = %@ \n, message = %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL, snsAccount.unionId, response.thirdPlatformUserProfile, response.thirdPlatformResponse, response.message);
            
            
        }});

    
}

- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response{
}

-(void)didCloseUIViewController:(UMSViewControllerType)fromViewControllerType{
    DFFunc
}


//当页面出现时候清除输入框内容
- (void)viewWillAppear:(BOOL)animated{
 
    self.accont.text = nil;
    self.pwdText.text = nil;
}
#pragma mark -监听事件
- (void)textFieldChanged{
    

    if (self.accont.text.length && self.pwdText.text.length ) {
        self.loginBtn.enabled = YES;
        
    }else{
        self.loginBtn.enabled = NO;
    }
}
#pragma mark -注册点击事件
- (IBAction)register:(id)sender {
    DFRegisterViewController *registerVc = [[DFRegisterViewController alloc]init];
    [self.navigationController pushViewController:registerVc animated:YES];
}
#pragma mark - 登录事件
- (void)loginSuccess{
    
    NSMutableDictionary *parmates = [NSMutableDictionary dictionary];
    NSString *result = [self.pwdText.text MD5];
    parmates[@"password"] = result;
    parmates[@"username"] = self.accont.text;
    
    [[AFHTTPSessionManager manager]POST:@"http://10.0.0.30:8080/appMember/account/login.htm" parameters:parmates progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSNumber *compareCode = [NSNumber numberWithInt:0];
        NSNumber *code = responseObject[@"code"];
        if ([code isEqualToNumber:compareCode]) {
            [SVProgressHUD showWithStatus:@"正在登录"];
            //数据存储
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:self.accont.text forKey:@"username"];
            [userDefault setObject:responseObject[@"data"][@"token"] forKey:@"token"];
            [userDefault synchronize];
            [[DFUser sharedManager]initWithDict:userDefault];
            [self loadIcon];
            [self dismissViewControllerAnimated:YES completion:nil];
            //直接返回主控制器
            [self back];

        }else{
        //初始化提示框；
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:responseObject[@"data"][@"errMsg"] preferredStyle:  UIAlertControllerStyleAlert];

        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //点击按钮的响应事件；
        }]];

        //弹出提示框；
        [self presentViewController:alert animated:true completion:nil];
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];

    
}

- (void)loadIcon{
    
    NSString *url = [MemberAPI stringByAppendingString:apiStr(@"getAvator.htm")];
    NSLog(@"tokrn = %@",[DFUser sharedManager].token);
    [self.manager POST:url parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *imgName = responseObject[@"data"];
        if (imgName.length > 0) {
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:imgName forKey:@"icon"];
            [userDefault synchronize];
            [[DFUser sharedManager] saveIcon:userDefault];
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}


//取消动画，并通知上一个页面返回首页
- (void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"backback" object:nil];
    
}
#pragma  mark - 忘记密码
- (IBAction)forget:(id)sender {
    DFForgetPassword *forget = [[DFForgetPassword alloc]init];
    [self.navigationController pushViewController:forget animated:YES];
}


- (IBAction)back:(id)sender {
   
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [SVProgressHUD dismiss];
}

@end
