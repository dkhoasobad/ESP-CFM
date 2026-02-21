
//  Created by 江湖 on 2022/3/14.
//  Copyright © 2022 zibeike. All rights reserved.
//

//江湖QQ351326543 源码仅供学习交流使用
//部分控件Action方法未写 自己完善即可

//可以通过菜单顶部横条来拖动菜单
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AdSupport/AdSupport.h>
#import <AVKit/AVKit.h>
#import "MyCaiDang.h"
#import "fishhook.h"
#include <JRMemory/MemScan.h>

#define 王者防封 @"com.tencent.smoba"
#define 使命防封 @"com.tencent.tmgp.cod"
#define cf功能 @"com.tencent.tmgp.cf"
#define CurrentViewSize self.view.frame.size
#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

@interface MyCaiDang ()<UITableViewDataSource,UITableViewDelegate>

@end

static UIView *UIViewJianghu;
static UITableView *personalTableView;
static float 比例 = 1;
static int 菜单 = 0;
static NSArray *zhugongneng;
static NSArray *dataSource;

static UIView *调试;
static UIView *拖动角标;
static UIButton *群;
static UIButton *源码;
static UILabel *MyLabel;

static NSInteger Hang1 = 1;
static NSInteger Hang2 = 1;
static NSInteger Hang3 = 1;

static UISegmentedControl *segment;
static UISegmentedControl *segment2;
static UISegmentedControl *segment3;

static UIButton *btn;
static UIButton *btn2;
static UIButton *btn3;

static UIButton *秒换;
static uintptr_t moudule_base;
@implementation MyCaiDang
NSString *添加QQ群地址;
NSString * 弹窗标题;
NSString * 弹窗内容;
NSString * 描述内容;
NSString * 菜单标题;
NSString * 官网地址;
NSString * 悬浮球图标地址;
NSString * 添加电报群地址;
//static uintptr_t moudule_base;
//static int64_t (*orig_ts)(int64_t result, unsigned int a2, int a3);
//static int64_t ts(int64_t result, unsigned int a2, int a3){
//    long long addr = (long long)__builtin_return_address(0) - _dyld_get_image_vmaddr_slide(0);
//    if(addr == 0x1029E5498)a2 = 0x1;
//    return orig_ts(result,a2,a3);
//}
#pragma mark - 加载菜单
//extern bool 成功;
+ (void)load{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //if(成功==NO)return;
        [MyCaiDang Mem];
        moudule_base = _dyld_get_image_vmaddr_slide(0);
    });
}

+ (UIWindow *)MYioS{
    if (@available(iOS 13.0, *))
    {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive)
            {
                for (UIWindow *window in windowScene.windows)
                {
                    if (window.isKeyWindow)
                    {
                        return window;
                    }
                }
            }
        }
    }
    else
    {
        return [UIApplication sharedApplication].keyWindow;
    }
    return [UIApplication sharedApplication].keyWindow;
}
static UIButton *按钮;
static NSTimer *防屏蔽;

+ (void)Mem{
    UIWindow *mainWindow = [MyCaiDang MYioS];
    按钮 = [[UIButton alloc] initWithFrame:CGRectMake(kWidth-50,30,50,50)];
    [按钮 setTitle:@"" forState:UIControlStateNormal];
    [按钮 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    按钮.backgroundColor = [UIColor yellowColor];
    [按钮.titleLabel setFont:[UIFont systemFontOfSize:16]];
    按钮.layer.cornerRadius = 按钮.frame.size.width/2;
    按钮.clipsToBounds = YES;
    [按钮 addTarget:self action:@selector(onConsoleButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://www.uplevo.com/blog/wp-content/uploads/2019/06/hinh-anh-nen-3d-dep-nhat.jpg"]];
        UIImage *decodedImage = [UIImage imageWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            按钮.layer.contents = (id)decodedImage.CGImage;
        });
    });
    [mainWindow addSubview:按钮];
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(TuoDong:)];
    [按钮 addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    tap.numberOfTapsRequired = 2;//点击次数
    tap.numberOfTouchesRequired = 3;//手指数
    [mainWindow addGestureRecognizer:tap];
    [tap addTarget:self action:@selector(tapIconView)];
    
    防屏蔽 = [NSTimer scheduledTimerWithTimeInterval:0.2 repeats:YES block:^(NSTimer*t){
        if(!按钮.hidden) {
            [按钮.superview bringSubviewToFront:按钮];
            UIWindow *mainWindow = [MyCaiDang MYioS];
            if(按钮.superview != mainWindow) [mainWindow addSubview:按钮];
        }
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [防屏蔽 invalidate];
    });
    //
}


+ (void)tapIconView
{
    按钮.hidden = !按钮.hidden;
}

+ (void)TuoDong:(UIPanGestureRecognizer *)recognizer{
    CGPoint translation = [recognizer translationInView:按钮];
    if(recognizer.state == UIGestureRecognizerStateBegan){
    }else if(recognizer.state == UIGestureRecognizerStateChanged){
        按钮.center = CGPointMake(按钮.center.x + translation.x, 按钮.center.y + translation.y);
        [recognizer setTranslation:CGPointZero inView:按钮];
    }else if(recognizer.state == UIGestureRecognizerStateEnded){
        CGFloat newX=按钮.center.x;
        CGFloat newY=按钮.center.y;
        按钮.center = CGPointMake(newX, newY);
        [recognizer setTranslation:CGPointZero inView:按钮];
    }
}

#pragma mark - 菜单标题栏
+ (void)onConsoleButtonTapped{
    if(菜单 == 0){
        菜单 = 1;
        CGFloat Width = 350; CGFloat Height = 370;
        UIWindow *mainWindow1 = [MyCaiDang MYioS];
        
        
        UIViewJianghu = [[UIView alloc]
                         initWithFrame:CGRectMake(0,0, Width, Height)];
        UIViewJianghu.backgroundColor=[UIColor whiteColor];
        UIViewJianghu.layer.borderWidth = 0;
        UIViewJianghu.layer.cornerRadius = 10;
        UIViewJianghu.hidden=NO;
        UIViewJianghu.center = mainWindow1.center;
        UIViewJianghu.alpha = 0.0f;
        [mainWindow1 addSubview:UIViewJianghu];
        [UIView animateWithDuration:1 animations:^{
            UIViewJianghu.alpha = 1;
        }];
        
        UIView *h = [[UIView alloc]
                     initWithFrame:CGRectMake(0,0, UIViewJianghu.frame.size.width, 30)];
        h.backgroundColor=[UIColor whiteColor];
        h.layer.cornerRadius = 10;
        [UIViewJianghu addSubview:h];
        
        UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(movingBtn:)];
        [h addGestureRecognizer:pan];
        
        UIButton *touxiang = [[UIButton alloc]
                              initWithFrame:CGRectMake(10,5, 30, 30)];
        touxiang.backgroundColor=[UIColor blackColor];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://www.uplevo.com/blog/wp-content/uploads/2019/06/hinh-anh-nen-3d-dep-nhat.jpg"]];
            UIImage *decodedImage = [UIImage imageWithData:imageData];
            
            dispatch_async(dispatch_get_main_queue(), ^{touxiang.layer.contents = (id)decodedImage.CGImage;});
            
        });
        touxiang.clipsToBounds = YES;
        touxiang.layer.cornerRadius = CGRectGetWidth(touxiang.bounds) / 2;
        [touxiang addTarget:self action:@selector(调试) forControlEvents:UIControlEventTouchUpInside];
        [h addSubview:touxiang];
        
        UILabel *BT = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, h.frame.size.width, 30)];
        BT.numberOfLines = 0;
        BT.lineBreakMode = NSLineBreakByCharWrapping;
        BT.text = @"H2Q";
        BT.textAlignment = NSTextAlignmentCenter;
        BT.font = [UIFont boldSystemFontOfSize:15];
        BT.textColor = [UIColor blackColor];
        [h addSubview:BT];
        
        UIButton *关闭 = [[UIButton alloc]
                        initWithFrame:CGRectMake(h.frame.size.width-50,5, 50, 20)];
        [关闭 setTitle:@"x" forState:UIControlStateNormal];
        [关闭 setTitleColor:[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f] forState:UIControlStateNormal];//p1颜色
        [关闭.titleLabel setFont:[UIFont systemFontOfSize:15]];//字体大小
        关闭.clipsToBounds = YES;
        关闭.layer.cornerRadius = CGRectGetWidth(关闭.bounds) / 2;
        [关闭 addTarget:self action:@selector(关闭菜单) forControlEvents:UIControlEventTouchUpInside];
        [h addSubview:关闭];
        
        personalTableView = [[UITableView alloc]initWithFrame:CGRectMake(5,35,UIViewJianghu.frame.size.width-10,UIViewJianghu.frame.size.height-35) style:UITableViewStyleGrouped];
        personalTableView.backgroundColor = [UIColor whiteColor];
        personalTableView.bounces = YES;
        personalTableView.dataSource = (id<UITableViewDataSource>) self;
        personalTableView.delegate = (id<UITableViewDelegate>) self;
        personalTableView.showsVerticalScrollIndicator = NO;
        personalTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        personalTableView.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        [UIViewJianghu addSubview:personalTableView];
    }else{
        UIViewJianghu.hidden = NO;
        [UIView animateKeyframesWithDuration:0.7 delay:0 options:0 animations:^{
            [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.4 animations:^{
                UIViewJianghu.transform = CGAffineTransformMakeScale(比例+0.05, 比例+0.05);
            }];
            [UIView addKeyframeWithRelativeStartTime:0.4 relativeDuration:0.7 animations:^{
                UIViewJianghu.transform = CGAffineTransformMakeScale(比例, 比例);
            }];
        }completion:nil];
    }
    
}

+ (void)调试{
    NSURL * urlStr = [NSURL URLWithString:官网地址];
    [[UIApplication sharedApplication] openURL:urlStr options:@{} completionHandler:nil];
}

+ (void)addShadowToView:(UIView *)theView withColor:(UIColor *)theColor {
    // 阴影颜色
    theView.layer.shadowColor = theColor.CGColor;
    // 阴影偏移，默认(0, -3)
    theView.layer.shadowOffset = CGSizeMake(0,0);
    // 阴影透明度，默认0
    theView.layer.shadowOpacity = 0.5;
    // 阴影半径，默认3
    theView.layer.shadowRadius = 5;
}

+ (void)关闭菜单{
    [UIView animateWithDuration:0.5 animations:^{
        UIViewJianghu.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    } completion:^(BOOL finished) {
        UIViewJianghu.hidden = YES;
        调试.alpha = 0;
        调试.hidden = YES;
    }];
}

+ (void)movingBtn:(UIPanGestureRecognizer *)recognizer{
    CGPoint translation = [recognizer translationInView:UIViewJianghu];
    if(recognizer.state == UIGestureRecognizerStateBegan){
    }else if(recognizer.state == UIGestureRecognizerStateChanged){
        UIViewJianghu.center = CGPointMake(UIViewJianghu.center.x + translation.x, UIViewJianghu.center.y + translation.y);
        [recognizer setTranslation:CGPointZero inView:UIViewJianghu];
    }else if(recognizer.state == UIGestureRecognizerStateEnded){
        CGFloat newX2=UIViewJianghu.center.x;
        CGFloat newY2=UIViewJianghu.center.y;
        UIViewJianghu.center = CGPointMake(newX2, newY2);
        [recognizer setTranslation:CGPointZero inView:UIViewJianghu];
    }
}



#pragma mark - TbaleView的数据源代理方法实现

+ (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 3;
}



+ (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //一行几个 这里必须写 不然就是空白
    //retunr x 就是x行
    if(section == 0)
        return 3;
    
    if(section == 1)
        return 3;
    
    return 0;
}


+ (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}


+ (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 20;
}
static NSDateFormatter *ttime;
static UIDevice *myDevice;
+ (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{    
    NSString *headerLabel;
    if (section == 0)
        headerLabel = @"Draw ESP";
    
    if (section == 1)
        headerLabel = @"Memory";

    return headerLabel;
}

+ (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    myDevice = [UIDevice currentDevice];
    [myDevice setBatteryMonitoringEnabled:YES];
    double batLeft = (float)[myDevice batteryLevel] * 100;
    
    ttime = [[NSDateFormatter alloc] init];
    [ttime setDateFormat:@"yyyy/MM/dd"];
    
    NSString *copyright;
    if (section == 0){
        copyright = [NSString stringWithFormat:@"Time:%@ Date:%0.0f",[ttime stringFromDate:[NSDate date]],batLeft];
    }
    
    //    if (section == 1){
    //        copyright = @"调节小地图大小 左右位置";
    //    }
    //
    //    if (section == 2){
    //        copyright = @"先开启视距再调节 调节好切换相机高度即可生效";
    //    }
    
    return copyright;
}

+ (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section

{
    
    //设置文字
    
    view.tintColor = [UIColor colorWithRed:239 / 255.0 green:238 / 255.0 blue:245 / 255.0 alpha:1];
    
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    header.textLabel.textAlignment=NSTextAlignmentCenter;
    
    header.textLabel.font = [UIFont boldSystemFontOfSize:12];
    
}


+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
BOOL 过直播开关 = NO;
BOOL 射线开关,血量开关,名字开关,追踪开关,自瞄开关,透视开关;
#pragma mark - 菜单图层
+ (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }else
    {
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
    }
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    
    CGRect rectInTableView = [tableView rectForRowAtIndexPath:indexPath];
    CGRect rect = [tableView convertRect:rectInTableView toView:[tableView superview]];
    btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 60, 30)];
    秒换 = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 60, 30)];
    
    if(indexPath.section==0){
        if(indexPath.row==0){
            cell.textLabel.text = @"Line Esp";
            UISwitch* switchView = [[UISwitch alloc]init];
            switchView.on = 射线开关;
            switchView.tag=1;
            [switchView addTarget:self
                           action:@selector(功能开关:)
                 forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switchView;
        }
        if(indexPath.row==1){
            cell.textLabel.text = @"Máu Esp";
            UISwitch* switchView = [[UISwitch alloc]init];
            switchView.on = 血量开关;
            switchView.tag=2;
            [switchView addTarget:self
                           action:@selector(功能开关:)
                 forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switchView;
        }
        if(indexPath.row==2){
            cell.textLabel.text = @"Tên Esp";
            UISwitch* switchView = [[UISwitch alloc]init];
            switchView.on = 名字开关;
            switchView.tag=3;
            [switchView addTarget:self
                           action:@selector(功能开关:)
                 forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switchView;
        }
    }
    if(indexPath.section==1){
        if(indexPath.row==0){
            cell.textLabel.text = @"Aimbot";
            UISwitch* switchView = [[UISwitch alloc]init];
            switchView.on = 自瞄开关;
            switchView.tag=6;
            [switchView addTarget:self
                           action:@selector(功能开关:)
                 forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switchView;
        }
        if(indexPath.row==1){
            cell.textLabel.text = @"Line";
            UISwitch* switchView = [[UISwitch alloc]init];
            switchView.on = 过直播开关;
            switchView.tag=5;
            [switchView addTarget:self
                           action:@selector(功能开关:)
                 forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switchView;
        }
        if(indexPath.row==2){
            cell.textLabel.text = @"BullerTrack";
            UISwitch* switchView = [[UISwitch alloc]init];
            switchView.on = 追踪开关;
            switchView.tag=7;
            [switchView addTarget:self
                           action:@selector(功能开关:)
                 forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switchView;
        }
    }
    

    
    return cell;
}
#pragma mark - 控件功能
+(void)功能开关:(UISwitch *)jiaa{
    if(jiaa.tag==1){
        if(jiaa.on){
            射线开关=YES;
        }else{
            射线开关=NO;
        }
    }else  if(jiaa.tag==2){
        if(jiaa.on){
            血量开关=YES;
        }else{
            血量开关=NO;
        }
    }else  if(jiaa.tag==3){
        if(jiaa.on){
            名字开关=YES;
        }else{
            名字开关=NO;
        }
    }else  if(jiaa.tag==5){
        if(jiaa.on){
            过直播开关=YES;
        }else{
            过直播开关=NO;
        }
    }else  if(jiaa.tag==6){
        if(jiaa.on){
            自瞄开关=YES;
            
            JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
            AddrRange range = (AddrRange){0x100000000,0x160000000};
            uint32_t search = 1063339950; //搜索值
            engine.JRScanMemory(range, &search, JR_Search_Type_SInt);
            
            vector<void*>results = engine.getAllResults();
            uint32_t modify = 1080033280;//全改
            for(int i = 0; i < results.size(); i++){
                engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_SInt);
            }
            
        }else{
            自瞄开关=NO;
        }
    }
    else  if(jiaa.tag==7){
        if(jiaa.on){
            追踪开关=YES;
           
            }
            
        }else{
            追踪开关=NO;
            [MyCaiDang 关闭追踪];
        }
      }

//+ (void)guanwang{
//    NSURL * urlStr = [NSURL URLWithString:官网地址];
//    [[UIApplication sharedApplication] openURL:urlStr options:@{} completionHandler:nil];
//}
//
//+ (void)tjdb{
//    NSURL * urlStr = [NSURL URLWithString:添加电报群地址];
//    [[UIApplication sharedApplication] openURL:urlStr options:@{} completionHandler:nil];
//}
//
//+ (void)jiaqun{
//    NSURL * urlStr = [NSURL URLWithString:添加QQ群地址];
//    [[UIApplication sharedApplication] openURL:urlStr options:@{} completionHandler:nil];
//}

CGFloat newx;
CGFloat newy;
+ (void)boardWillShow:(NSNotification *)sender{
    newx = UIViewJianghu.center.x;
    newy = UIViewJianghu.center.y;
    [UIView animateWithDuration:0.2 animations:^{
        UIViewJianghu.frame = CGRectMake(UIViewJianghu.frame.origin.x,0,UIViewJianghu.frame.size.width,UIViewJianghu.frame.size.height);
    }];
}

+ (void)boardDidHide:(NSNotification *)sender{
    [UIView animateWithDuration:0.2 animations:^{
        UIViewJianghu.center = CGPointMake(newx,newy);
    }];
}

+ (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
    
}

#pragma mark - 菜单点击文字触发功能
+ (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [personalTableView deselectRowAtIndexPath:[personalTableView indexPathForSelectedRow] animated:YES];
    
    
}



+ (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 设置cell的背景色为透明，如果不设置这个的话，则原来的背景色不会被覆盖
    cell.backgroundColor = UIColor.clearColor;
    
    // 圆角弧度半径
    CGFloat cornerRadius = 10.0f;
    
    // 创建一个shapeLayer
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    // 显示选中
    CAShapeLayer *backgroundLayer = [[CAShapeLayer alloc] init];
    //   创建一个可变的图像Path句柄，该路径用于保存绘图信息
    CGMutablePathRef pathRef = CGPathCreateMutable();
    //   获取cell的size
    //    第一个参数,是整个 cell 的 bounds, 第二个参数是距左右两端的距离,第三个参数是距上下两端的距离
    CGRect bounds = CGRectInset(cell.bounds, 0, 0);
    
    //      CGRectGetMinY：返回对象顶点坐标
    //      CGRectGetMaxY：返回对象底点坐标
    //      CGRectGetMinX：返回对象左边缘坐标
    //      CGRectGetMaxX：返回对象右边缘坐标
    //      CGRectGetMidX: 返回对象中心点的X坐标
    //      CGRectGetMidY: 返回对象中心点的Y坐标
    //      这里要判断分组列表中的第一行，每组section的第一行，每组section的中间行
    NSInteger rows = [tableView numberOfRowsInSection:indexPath.section];
    BOOL addLine = NO;
    if (rows == 1) {
        // 初始起点为cell的左侧中间坐标
        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMidY(bounds));
        // 起始坐标为左下角，设为p，（CGRectGetMinX(bounds), CGRectGetMinY(bounds)）为左上角的点，设为p1(x1,y1)，(CGRectGetMidX(bounds), CGRectGetMinY(bounds))为顶部中点的点，设为p2(x2,y2)。然后连接p1和p2为一条直线l1，连接初始点p到p1成一条直线l，则在两条直线相交处绘制弧度为r的圆角。
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
        
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
        
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMinX(bounds), CGRectGetMaxY(bounds), cornerRadius);
        
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMinX(bounds), CGRectGetMidY(bounds), cornerRadius);
        // 终点坐标为右下角坐标点，把绘图信息都放到路径中去,根据这些路径就构成了一块区域了
        CGPathAddLineToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMidY(bounds));
    } else if (indexPath.row == 0) {
        // 初始起点为cell的左下角坐标
        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
        // 起始坐标为左下角，设为p，（CGRectGetMinX(bounds), CGRectGetMinY(bounds)）为左上角的点，设为p1(x1,y1)，(CGRectGetMidX(bounds), CGRectGetMinY(bounds))为顶部中点的点，设为p2(x2,y2)。然后连接p1和p2为一条直线l1，连接初始点p到p1成一条直线l，则在两条直线相交处绘制弧度为r的圆角。
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
        
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
        // 终点坐标为右下角坐标点，把绘图信息都放到路径中去,根据这些路径就构成了一块区域了
        CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
        addLine = YES;
    } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
        // 初始起点为cell的左上角坐标
        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
        
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
        
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
        // 添加一条直线，终点坐标为右下角坐标点并放到路径中去
        CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
    } else {
        // 添加cell的rectangle信息到path中（不包括圆角）
        CGPathAddRect(pathRef, nil, bounds);
        addLine = YES;
    }
    
    // 把已经绘制好的可变图像路径赋值给图层，然后图层根据这图像path进行图像渲染render
    layer.path = pathRef;
    backgroundLayer.path = pathRef;
    
    // 注意：但凡通过Quartz2D中带有creat/copy/retain方法创建出来的值都必须要释放[UIColor colorWithRed:239 / 255.0 green:238 / 255.0 blue:245 / 255.0 alpha:1];
    CFRelease(pathRef);
    
    // 按照shape layer的path填充颜色，类似于渲染render
    layer.fillColor = [UIColor colorWithRed:239 / 255.0 green:238 / 255.0 blue:245 / 255.0 alpha:1].CGColor;
    
    // view大小与cell一致
    UIView *roundView = [[UIView alloc] initWithFrame:bounds];
    
    // 添加自定义圆角后的图层到roundView中
    [roundView.layer insertSublayer:layer atIndex:0];
    roundView.backgroundColor = UIColor.clearColor;
    
    // cell的背景view
    cell.backgroundView = roundView;
    
    // 添加分割线
    if (addLine == YES) {
        
        CALayer *lineLayer = [[CALayer alloc] init];
        
        CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
        
        lineLayer.frame = CGRectMake(18, bounds.size.height-lineHeight, bounds.size.width, lineHeight);
        
        lineLayer.backgroundColor = tableView.separatorColor.CGColor;
        
        [layer addSublayer:lineLayer];
        
    }
    
    // 以上方法存在缺陷当点击cell时还是出现cell方形效果，因此还需要添加以下方法
    // 如果你 cell 已经取消选中状态的话,那以下方法是不需要的.
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:bounds];
    backgroundLayer.fillColor = tableView.separatorColor.CGColor;
    [selectedBackgroundView.layer insertSublayer:backgroundLayer atIndex:0];
    selectedBackgroundView.backgroundColor = UIColor.clearColor;
    cell.selectedBackgroundView = selectedBackgroundView;
    
    
    
}
+ (void)showMessage:(NSString *)message duration:(NSTimeInterval)time
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        
        UIWindow * window = [UIApplication sharedApplication].keyWindow;
        UIView *showview =  [[UIView alloc]init];
        showview.backgroundColor = [UIColor blackColor];
        showview.frame = CGRectMake(1, 1, 1, 1);
        showview.alpha = 1.0f;
        showview.layer.cornerRadius = 5.0f;
        showview.layer.masksToBounds = YES;
        [window addSubview:showview];//1C1F9F8AF636B
        
        UILabel *label = [[UILabel alloc]init];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15.f],
                                     NSParagraphStyleAttributeName:paragraphStyle.copy};
        
        CGSize labelSize = [message boundingRectWithSize:CGSizeMake(207, 999)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:attributes context:nil].size;
        
        label.frame = CGRectMake(10, 5, labelSize.width +20, labelSize.height);
        label.text = message;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor blackColor];
        label.font = [UIFont boldSystemFontOfSize:15];
        [showview addSubview:label];
        
        showview.frame = CGRectMake((screenSize.width - labelSize.width - 20)/2,
                                    screenSize.height - 300,
                                    labelSize.width+40,
                                    labelSize.height+10);
        [UIView animateWithDuration:time animations:^{
            showview.alpha = 0;
        } completion:^(BOOL finished) {
            [showview removeFromSuperview];
        }];
    });
}

//- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
//    <#code#>
//}
//
//- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//
//}
//
//- (void)encodeWithCoder:(nonnull NSCoder *)coder {
//    <#code#>
//}
//
//+ (nonnull instancetype)appearance {
//    <#code#>
//}
//
//+ (nonnull instancetype)appearanceForTraitCollection:(nonnull UITraitCollection *)trait {
//    <#code#>
//}
//
//+ (nonnull instancetype)appearanceForTraitCollection:(nonnull UITraitCollection *)trait whenContainedIn:(nullable Class<UIAppearanceContainer>)ContainerClass, ... {
//    <#code#>
//}
//
//+ (nonnull instancetype)appearanceForTraitCollection:(nonnull UITraitCollection *)trait whenContainedInInstancesOfClasses:(nonnull NSArray<Class<UIAppearanceContainer>> *)containerTypes {
//    <#code#>
//}
//
//+ (nonnull instancetype)appearanceWhenContainedIn:(nullable Class<UIAppearanceContainer>)ContainerClass, ... {
//    <#code#>
//}
//
//+ (nonnull instancetype)appearanceWhenContainedInInstancesOfClasses:(nonnull NSArray<Class<UIAppearanceContainer>> *)containerTypes {
//    <#code#>
//}
//
//- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
//    <#code#>
//}
//
//- (CGPoint)convertPoint:(CGPoint)point fromCoordinateSpace:(nonnull id<UICoordinateSpace>)coordinateSpace {
//    <#code#>
//}
//
//- (CGPoint)convertPoint:(CGPoint)point toCoordinateSpace:(nonnull id<UICoordinateSpace>)coordinateSpace {
//    <#code#>
//}
//
//- (CGRect)convertRect:(CGRect)rect fromCoordinateSpace:(nonnull id<UICoordinateSpace>)coordinateSpace {
//    <#code#>
//}
//
//- (CGRect)convertRect:(CGRect)rect toCoordinateSpace:(nonnull id<UICoordinateSpace>)coordinateSpace {
//    <#code#>
//}
//
//- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
//    <#code#>
//}
//
//- (void)setNeedsFocusUpdate {
//    <#code#>
//}
//
//- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
//    <#code#>
//}
//
//- (void)updateFocusIfNeeded {
//    <#code#>
//}
//
//- (nonnull NSArray<id<UIFocusItem>> *)focusItemsInRect:(CGRect)rect {
//    <#code#>
//}

@end
