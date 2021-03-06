//
//  DFSettingViewController.m
//  点范
//
//  Created by Masteryi on 2016/10/15.
//  Copyright © 2016年 Masteryi. All rights reserved.
//

#import "DFSettingViewController.h"
#import "DFSettingHeader.h"
#import "DFUser.h"
#import "DFIdeaBackViewController.h"
#import "DFHTTPSessionManager.h"
#import "DFVersionViewController.h"

@interface DFSettingViewController ()

@property (nonatomic,strong)NSArray *settingArray;

@property (nonatomic,strong)DFHTTPSessionManager *manager;

@end

@implementation DFSettingViewController

static NSString * SettingCell = @"SettingCell";

#pragma mark - 懒加载
- (NSArray *)settingArray{
    if (!_settingArray) {
        _settingArray = [NSArray array];
    }
    return _settingArray;
}
- (DFHTTPSessionManager *)manager{
    if (!_manager) {
        _manager = [DFHTTPSessionManager manager];
    }
    return _manager;
}
#pragma mark - 初始化
- (instancetype)initWithStyle:(UITableViewStyle)style{
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:SettingCell];
    _settingArray = @[@"当前版本",
                      @"意见反馈",
                      @"商务合作",
                      @"关于我们",
                      @"退出登录"];
    self.tableView.contentInset = UIEdgeInsetsMake(-44, 0, 0, 0);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) return 1;
    return _settingArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SettingCell forIndexPath:indexPath];
    switch (indexPath.section) {
        case 0:{
            
            DFSettingHeader *header = [[DFSettingHeader alloc]initWithFrame:CGRectMake(0, 0, fDeviceWidth, 150)];
            [cell.contentView addSubview:header];
            
        }
            break;
        case 1:{
            cell.textLabel.text = _settingArray[indexPath.row];
            cell.textLabel.font = [UIFont systemFontOfSize:14];
        }
            
        default:
            break;
    }
 
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) return 150;
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 4:{
                //初始化提示框；
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定退出登录？" preferredStyle:  UIAlertControllerStyleAlert];
                
                [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    //点击按钮的响应事件；
                    [self loginout];
                    
                }]];
                
                [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }]];
                
                //弹出提示框；
                [self presentViewController:alert animated:true completion:nil];
            }
               
                break;
            case 1:{
                DFIdeaBackViewController *ideaBack = [[DFIdeaBackViewController alloc]init];
                [self.navigationController pushViewController:ideaBack animated:YES];
            }
                break;
            case 0:{
                DFVersionViewController *version = [[DFVersionViewController alloc]init];
                [self.navigationController pushViewController:version animated:YES];
            }
                break;
            default:
                break;
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)loginout{
    NSString *url = [AccountAPI stringByAppendingString:apiStr(@"loginOut.htm")];
    __weak typeof(self) weakSelf = self;
    [weakSelf.manager POST:url parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (sucess) {
            [[DFUser sharedManager]didLogout];
            
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        }else{
            UIAlertController *alter = [UIAlertController actionWithMessage:MsgMessage];
            [weakSelf presentViewController:alter animated:YES completion:^{
                
            }];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       
    }];
}
@end
