//
//  DFStoreViewController.m
//  点范
//
//  Created by Masteryi on 16/9/20.
//  Copyright © 2016年 Masteryi. All rights reserved.
//

#import "DFStoreViewController.h"
#import "DFfootDataController.h"
#import "DFfoodCell.h"
#import "DFStoreView.h"
#import "DFtableHeader.h"
#import "DFstotreDataController.h"
#import "DFHTTPSessionManager.h"
#import "DFUser.h"
#import "DFStoreViewModel.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "DFDateViewController.h"

@interface DFStoreViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *tableView;
/** 底部指示器 */
@property (nonatomic,weak)UIView *indicatorView;
/** 选中按钮 */
@property (nonatomic,weak)UIButton *selectButton;
/** 网络管理者 */
@property (nonatomic,strong)DFHTTPSessionManager *manager;
/** 模型数组 */
@property (nonatomic,strong)NSMutableArray<DFStoreViewModel *> *dishArrays;
/** 浏览量 */
@property (nonatomic,strong)UIButton *readBtn;

@property (nonatomic,strong)UIButton *timeBtn;
@end

@implementation DFStoreViewController

static NSString *storeCell = @"storeCell";

#pragma mark - 懒加载
- (DFHTTPSessionManager *)manager{
    if (!_manager) {
        _manager = [DFHTTPSessionManager manager];
    }
    return _manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"店铺名称";

    [self setHeadView];
    [self setTableView];
    [self loadListDishes:0];

}
- (void)loadListDishes:(NSUInteger )property{

    NSString *url = [DishAPI stringByAppendingString:apiStr(@"listDishes.htm")];
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"property"] = @(property);
    parameter[@"id"] = self.distemplateResultID;
    WeakSelf
    [weakSelf.manager POST:url parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD show];
        if (sucess) {
            weakSelf.dishArrays = [DFStoreViewModel mj_objectArrayWithKeyValuesArray:responseObject[@"data"]];
            [weakSelf.tableView reloadData];
            
            [SVProgressHUD dismiss];
        }else{
            [SVProgressHUD dismiss];
            UIAlertController *altrt = [UIAlertController actionWithMessage:MsgMessage];
            [weakSelf presentViewController:altrt animated:YES completion:nil];
        }
      
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
}
- (void)setHeadView{
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 1, fDeviceWidth, 205)];
    headView.backgroundColor = WhiteColor;
   
    
    CGRect frame = CGRectMake(0, 0, self.view.df_width, 145);
    DFStoreView *storeView = [[DFStoreView alloc]initWithFrame:frame];
    storeView.backgroundColor = MainColor;
    storeView.userInteractionEnabled = YES;
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushToStoreData)];
//    [storeView addGestureRecognizer:tap];
    [storeView.timeBtn addTarget:self action:@selector(pushToDate) forControlEvents:UIControlEventTouchUpInside];
    self.timeBtn = storeView.timeBtn;
    [headView addSubview:storeView];
    
    DFtableHeader *tableHead = [[DFtableHeader alloc]initWithFrame:CGRectMake(0, 0, self.view.df_width, 44)];
    tableHead.df_y = headView.df_height - 44;
    tableHead.readBtn.tag = 0;
    tableHead.commentBtn.tag = 1;
    tableHead.orderBtn.tag = 2;

    [tableHead.orderBtn addTarget:self action:@selector(titleClick:) forControlEvents:UIControlEventTouchUpInside];

    [tableHead.commentBtn addTarget:self action:@selector(titleClick:) forControlEvents:UIControlEventTouchUpInside];
    [tableHead.readBtn addTarget:self action:@selector(titleClick:) forControlEvents:UIControlEventTouchUpInside];
    self.readBtn = tableHead.readBtn;

    UIView *indicatorView = [[UIView alloc]init];
    indicatorView.backgroundColor = [UIColor whiteColor];
    indicatorView.df_height = 2;
    indicatorView.df_y = tableHead.df_height - 5;

    [tableHead addSubview:indicatorView];
    self.indicatorView = indicatorView;
    
    [headView addSubview:tableHead];
    
    
    
     [self.view addSubview:headView];
    
}
- (void)setTableView{
  
    CGRect frame = CGRectMake(0, 205 + DFMargin, self.view.df_width, self.view.df_height);
    UITableView *tableView = [[UITableView alloc]initWithFrame:frame style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DFfoodCell class]) bundle:nil] forCellReuseIdentifier:storeCell];
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 144 + 64 + DFMargin, 0);
    [self.view addSubview:tableView];
    self.tableView = tableView;

}
#pragma mark -UITableView 代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.dishArrays.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    DFfoodCell *cell = [tableView dequeueReusableCellWithIdentifier:storeCell forIndexPath:indexPath];
    cell.oderID.text = [NSString stringWithFormat:@"%zd",indexPath.row + 1];
    cell.stroreModel = self.dishArrays[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DFfootDataController *footData = [[DFfootDataController alloc]init];
    [self.navigationController pushViewController:footData animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 83;
}

#pragma mark headView点击事件
-(void)titleClick:(UIButton *)button{
   
    switch (button.tag) {
        case 0:{
            [self loadListDishes:0];
        }
            
            break;
        case 1:{
            [self loadListDishes:1];
        }
            break;
        case 2:{
            [self loadListDishes:2];
        }
            break;
        default:
            break;
    }
    
    self.selectButton.selected = NO;
    button.selected = YES;
    self.selectButton = button;
    
    [UIView animateWithDuration:0.25 animations:^{
    CGFloat titlew = [button.currentTitle sizeWithAttributes:@{NSFontAttributeName : button.titleLabel.font}].width;
    self.indicatorView.df_width = titlew ;
    self.indicatorView.df_x = button.df_x;
        
    }];

}

- (void)pushToStoreData{
    DFstotreDataController *storeData = [[DFstotreDataController alloc]init];
    
    [self.navigationController pushViewController:storeData animated:YES];
}

- (void)pushToDate{
    DFDateViewController *dateCtr = [[DFDateViewController alloc]init];
    dateCtr.block = ^(NSString *str){
        [self.timeBtn setTitle:str forState:UIControlStateNormal];
    };
    [self.navigationController pushViewController:dateCtr animated:YES];
}

#pragma mark - DateDelegate


@end
