//
//  il2pp_hack.m
//  HOK
//
//  Created by macgu on 2020/12/28.
//  Copyright © 2020年 macgu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <dlfcn.h>
#include <mach-o/dyld.h>
#include <vector>
#import <objc/runtime.h>
#import "MyCaiDang.h"
#include "CodePatch.h"//Ncicon
#import "fishhook.h"


uintptr_t moudule_base;
uint64_t mh_baseaddr;
int64_t Global_Camera;
int64_t My_Pawn;
int64_t My_weaponFireComponent;

float screenX;
float screenY;
#define __int64 int64_t
#define QWORD(x) *(long long*)(moudule_base + x)

//============变量赋值=============
static bool MenuFlag = NO;//默认关闭菜单
static bool HuiZhiFlag = YES;//默认开启绘制
static bool ZhuizongFlag = NO;//默认关闭追踪
static bool ZiMiaoFlag = NO;//默认关闭自瞄
static NSString *ZhuizongZZ =@"开启追踪";//追踪按钮默认显示文字
static NSString *HuiZhiZZ = @"关闭绘制";//绘制按钮默认显示文字
//================================
class Vector3
{
public:
    float x,y,z;
    void operator= (float a){
        x = a;
        y = a;
        z = a;
        
    }
    void operator= (Vector3 v){
        x = v.x;
        y = v.y;
        z = v.z;
    }
    Vector3 operator-(const Vector3 &a)const
    {
        return Vector3(x - a.x, y - a.y, z - a.z);
    }
    Vector3 operator/(float a) const
    {
        float temp = 1.0f / a;
        return Vector3(x*temp, y*temp, z*temp);
    }
    Vector3 operator*(float a /*标量*/) const
    {
        return Vector3(x*a, y*a, z*a);
    }
    Vector3 operator+(const Vector3 &a)const
    {
        return Vector3(x+a.x,y+a.y,z+a.z);
    }
    Vector3(float nx, float ny, float nz) :x(nx), y(ny), z(nz){}
    Vector3(){}
    
    static Vector3 CVector3ToRotation(Vector3 v1) {
        Vector3 V = Vector3(0,0,0);
        V.y = atan2(v1.y,v1.x);
        V.x = atan2(v1.z,sqrt(v1.x*v1.x+v1.y*v1.y));
        V.z = 0;
        return V;
    }
    static Vector3 FRotationToCVector3(Vector3 v1){
        float CP, SP, CY, SY;
        CP = cos(v1.x);
        SP = sin(v1.x);
        CY = cos(v1.y);
        SY = sin(v1.y);
        return Vector3(CP*CY,CP*SY,SP);
    }
    static float CDistance(Vector3 v1,Vector3 v2){
        return sqrt(pow(v1.x-v2.x,2)+pow(v1.y-v2.y,2)+pow(v1.z-v2.z,2));
    }
    static Vector3 CMiddlePoint(Vector3 v1,Vector3 v2){
        Vector3 ret = Vector3(0,0,0);
        ret.x = (v1.x+v2.x)/2;
        ret.y = (v1.y+v2.y)/2;
        ret.z = (v1.z+v2.z)/2;
        return ret;
    }
    float  operator*(const Vector3 &a)const
    {
        return x*a.x + y*a.y + z*a.z;
    }
    Vector3 operator+(const float &a)const
    {
        return Vector3(x+a,y+a,z+a);
    }
    Vector3 operator-(const float &a)const
    {
        return Vector3(x-a,y-a,z-a);
    }
};
class FQuat
{
public:
    float x,y,z,w;
    
    void operator= (float a){
        x = a;
        y = a;
        z = a;
        w = a;
        
    }
    void operator= (FQuat v){
        x = v.x;
        y = v.y;
        z = v.z;
        w = v.w;
        
    }
    FQuat(float nx, float ny, float nz,float nw) :x(nx), y(ny), z(nz), w(nw){}
    FQuat(){}
    static FQuat CVector3ToQuat(Vector3 v1){
        const float YawRad = atan2(v1.y, v1.x);
        const float PitchRad = atan2(v1.z, sqrt(v1.x*v1.x + v1.y*v1.y));
        float SP, SY;
        float CP, CY;
        SP = sin(PitchRad/2);
        CP = cos(PitchRad/2);
        SY = sin(YawRad/2);
        CY = cos(YawRad/2);
        FQuat RotationQuat = FQuat(0,0,0,0);
        RotationQuat.x =  SP*SY;
        RotationQuat.y = -SP*CY;
        RotationQuat.z =  CP*SY;
        RotationQuat.w =  CP*CY;
        return RotationQuat;
    }
    
};

typedef struct _bounds{
    Vector3 center;
    Vector3 extents;
    Vector3 max;
    Vector3 min;
    Vector3 sie;
    
}Bounds;
typedef struct _entity{
    Vector3 Location;
    Vector3 HeadPosition;
    Vector3 CenterPosition;
    bool CanUseHeadBone;
    float HP;
    NSString *name;
}Entity;
float CFViewMatrix[16];
float projectionMatrix[16];
float PV[16];
std::vector<Entity>Entitys;
int64_t AttackableTargetClass;
int64_t (*GetMainCamera)();
void (*WorldToViewPortPoint)(int64_t no,int64_t a1,Vector3& a2,Vector3& a3);
int64_t (*FindObjectsOfType)(int64_t a1,int64_t a2);
int64_t (*GetTypeFromHandle)(int64_t a1,int64_t a2,int64_t a3);
int64_t (*GetGame)();
int64_t (*GetItem)(int64_t a1,uint32_t a2);
Vector3 (*Get_TargetCenterPosition)(int64_t a1);
Vector3 (*Get_TargetTopPosition)(int64_t a1);
Vector3 (*Get_TargetCenterOffset)(int64_t a1);
FQuat (*LookRotaion)(Vector3 forward);
int64_t (*Get_LocalPawn)();
int64_t (*GetGameObject)(int64_t a1);
int64_t (*GetTransform)(int64_t a1);
bool (*IsLocalPlayer)(int64_t a1);
void (*GetViewMatrix)(int64_t a1,float *a2);
void (*GetProjectionMatrix)(int64_t a1,float *a2);
float (*Get_Health)(int64_t a1);
Vector3 (*GetPosition)(int64_t a1);
int64_t (*Get_CachedCharController)(int64_t a1);
float (*CharController_get_radius)(int64_t a1);
void (*CharController_set_radius)(int64_t a1,float a2);
bool (*Get_isAiming)(int64_t a1);
int64_t (*GetCurrentFireComponent)(int64_t a1);
int64_t (*GetCurrentWeapon)(int64_t a1);
int64_t (*Weapon_GetCurrentFireComponent)(int64_t a1);
int32_t (*GetLocalPlayerCamp)();
Vector3 (*GetPlayerHeadPosition)(int64_t a1);
int64_t (*GetHeadTransForm)(int64_t a1);
bool (*orig_CalWeaponFire)(int64_t a1,Vector3 startPos,Vector3 dir,int64_t a4);
static IMP _Nullable (*my_class_replaceMethod)(Class _Nullable __unsafe_unretained cls,SEL _Nonnull name,IMP _Nonnull imp,const char* _Nullable types);
Vector3 TraceTarget = Vector3(0, 0, 0);
bool shouldTrace = NO;

static char * mystrcpy(char *dst,const char *src)   //[1]
{
    assert(dst != NULL && src != NULL);    //[2]
    
    char *ret = dst;  //[3]
    
    while ((*dst++=*src++)!='\0'); //[4]
    
    return ret;
}
static long long htoi(const char *str)
{
    int length = strlen(str);
    char revstr[16] = {0}; //根据十六进制字符串的长度，这里注意数组不要越界
    long long num[16] = {0};
    long long count = 1;
    long long result = 0;
    
    mystrcpy(revstr, str);
    
    for(int i = length - 1; i >= 0; i--)
    {
        if((revstr[i] >= '0') && (revstr[i] <= '9'))
        {
            num[i] = revstr[i] - 48;   //字符0的ASCII值为48
        }
        else if((revstr[i] >= 'a') && (revstr[i] <= 'f'))
        {
            num[i] = revstr[i] - 'a' + 10;
        }
        else if((revstr[i] >= 'A') && (revstr[i] <= 'F'))
        {
            num[i] = revstr[i] - 'A' + 10;
        }
        else
        {
            num[i] = 0;
        }
        
        result += num[i] * count;
        count *= 16; //十六进制(如果是八进制就在这里乘以8)
    }
    
    return result;
}
//=================子弹追踪=============================
//段落注释 需要用/*开始和*/结束

bool CalWeaponFire(int64_t a1,Vector3 startPos,Vector3 dir,int64_t a4){
    
    if(追踪开关){
        float dis = Vector3::CDistance(TraceTarget, startPos);
        Vector3 delta = TraceTarget - startPos;
        Vector3 newdir = delta/dis;
        return orig_CalWeaponFire(a1,startPos,newdir,a4);//
        
    }
    return orig_CalWeaponFire(a1,startPos,dir,a4);
}

//==========================================================
float (*Get_MaxHealth)(int64_t a2);
void printMatrix(float*m){
    NSString *str = @"";
    for (int i = 0; i<4; i++) {
        int time = 0;
        while (time<4) {
            str = [str stringByAppendingString:[NSString stringWithFormat:@"%f",m[i*4+time]]];
            time++;
        }
        str = [str stringByAppendingString:@"\n"];
    }
    //        NSLog(@"+[HOOK]%@",str);
}

void CalPV(){
    for (int hang = 0; hang<4; hang++) {
        for(int lie = 0; lie<4; lie++){
            float total = 0;
            for (int i = 0; i<4; i++) {
                total += CFViewMatrix[hang*4+i]*projectionMatrix[4*i+lie];
            }
            PV[hang*4+lie] = total;
        }
    }
    
    
}
bool isVaildPtr(long long ptr){
    return ptr >= mh_baseaddr && ptr <= 0x300000000 ? YES : NO;
}

static Vector3 WorldToScreen(Vector3  obj, float* matrix) {
    Vector3 screen;
    float w = matrix[3] * obj.x + matrix[7] * obj.y + matrix[11] * obj.z + matrix[15];
    if (w < 0.5)w = 0.5;
    //    NSLog(@"+[HOOK]%f %f",(matrix[0] * obj.x + matrix[4] * obj.y + matrix[8] * obj.z + matrix[12]) / w,(matrix[1] * obj.x + matrix[5] * obj.y + matrix[9] * obj.z + matrix[13]) / w);
    
    float x = (screenX/2) + (matrix[0] * obj.x + matrix[4] * obj.y + matrix[8] * obj.z + matrix[12]) / w * (screenX/2);
    float y = (screenY/2) - (matrix[1] * obj.x + matrix[5] * obj.y + matrix[9] * obj.z + matrix[13]) / w * (screenY/2);
    screen.x = x;
    screen.y = y;
    return screen;
}
//====================================基质内透=======================================================
//static void cftoushi(RegisterContext *reg_ctx, const HookEntryInfo *info){
// if(*(int32_t*)(reg_ctx->general.regs.x20 + 0x444 )== 2048)*(int32_t*)(reg_ctx->general.regs.x20 + 0x444) = 10888;
//}
//==================================================================================================
static void __attribute__((constructor)) InitFun(){
    mh_baseaddr = (uint64_t)_dyld_get_image_header(0);
    moudule_base = _dyld_get_image_vmaddr_slide(0);
    void *handle = dlopen(NULL,RTLD_NOW | RTLD_GLOBAL);
    my_class_replaceMethod = (IMP  _Nullable (*)(__unsafe_unretained Class _Nullable, SEL _Nonnull, IMP _Nonnull, const char * _Nullable))dlsym(handle, "class_replaceMethod");
    //==========================HOOK基址==============================
    //===============================================================
    //=======================cfm全局透视=================================
    //DobbyInstrument((void*)(moudule_base + htoi("0x104C3B068")), cftoushi);//基址
    //================================================================
    //===================================子弹追踪不支持免越狱====================================
    //搜protected virtual bool CalcWeaponFire(Vector3 startPos, Vector3 dir, ref List<ImpactInfo> impactList) { }  追踪
    DobbyHook((void*)(moudule_base + htoi("0x102DA814C")), (void*)CalWeaponFire, (void**)&orig_CalWeaponFire);//追踪❤
    //========================================================================================
    
    //=========搜索public static Camera get_main() { }    第一个==================
    GetMainCamera = (typeof(GetMainCamera))(moudule_base + htoi("0x104F8C1A4"));//①
    
    //=========搜索public virtual Vector3 get_TargetCenterPostion() { }  第二个=============
    Get_TargetCenterPosition = (typeof(Get_TargetCenterPosition))(moudule_base + htoi("0x10296AF28"));//②
    //FindObjectsOfType = (typeof(FindObjectsOfType))(moudule_base + 0x1045145D8);
    //GetTypeFromHandle = (typeof(GetTypeFromHandle))(moudule_base + 0x1046DAFE8);
    
    //=========搜索public static BaseGame get_Game() { }  第三个=============
    GetGame = (typeof(GetGame))(moudule_base + htoi("0x102AB5BD8"));//③
    //Get_Health = (typeof(Get_Health))(moudule_base + 0x101F9C00C);
    //Get_MaxHealth = (typeof(Get_MaxHealth))(moudule_base + 0x101F9C13C);
    
    //=========搜索public T get_Item(int index) { }  第四个=============
    GetItem = (typeof(GetItem))(moudule_base + htoi("0x104706BF8"));//④第2个
    
    //=========搜索public Vector3 get_position() { }  第五个=============
    GetPosition = (typeof(GetPosition))(moudule_base + htoi("0x10501E8AC"));//

public class Transform : Component, IEnumerable // TypeDefIndex: 1808


    //IsLocalPlayer = (typeof(IsLocalPlayer))(moudule_base + 0x1021F63D0);
    
    //=========搜索public static Pawn get_LocalPawn() { }  第六个=============
    Get_LocalPawn = (typeof(Get_LocalPawn))(moudule_base + htoi("0x102AB6128"));//⑥
    
    //=========搜索public GameObject get_gameObject() { }  第七个=============
//public class Component : Object 
    Get_TargetCenterOffset = (typeof(Get_TargetCenterOffset))(moudule_base + htoi("0x104F94AE8"));//自瞄⑦
    GetGameObject = (typeof(GetGameObject))(moudule_base + htoi("0x104F94AE8"));//自瞄⑦
    
    //=========搜索public Transform get_transform() { }  第八个============
    GetTransform = (typeof(GetTransform))(moudule_base + htoi("0x104F949E8"));//⑧
    
    //=========搜索private void INTERNAL_get_worldToCameraMatrix(out Matrix4x4 value) { }  第九个=======
    GetViewMatrix = (typeof(GetViewMatrix))(moudule_base + htoi("0x104F8A678"));//⑨
    
    //=========搜索private void INTERNAL_get_projectionMatrix(out Matrix4x4 value) { }  第十个======
    GetProjectionMatrix = (typeof(GetProjectionMatrix))(moudule_base + htoi("0x104F8A818"));//⑩
    
    //=========搜索public static ECamp GetLocalPlayerCamp() { }  第十一个======
    GetLocalPlayerCamp = (typeof(GetLocalPlayerCamp))(moudule_base + htoi("0x102AB6838"));//⑪
    
    //=========搜索public Vector3 get_PlayerHeadPosition() { }  第十二个======
    GetPlayerHeadPosition = (typeof(GetPlayerHeadPosition))(moudule_base + htoi("0x102B6A314"));//⑫
    
    //=========搜索public virtual Transform GetHeadTransform() { }  第十三个======
    GetHeadTransForm = (typeof(GetHeadTransForm))(moudule_base + htoi("0x102B6A140"));//⑬
    
    // Get_TargetTopPosition = (typeof(Get_TargetTopPosition)moud
    
    //=========搜索public static Quaternion LookRotation(Vector3 forward) { }  第十四个======
    LookRotaion = (typeof(LookRotaion))(moudule_base + htoi("0x104FEB704"));//⑭
    // Get_CachedCharController = (typeof(Get_CachedCharController))(moudule_base + 0x101BB4018);
    //CharController_get_radius = (typeof(CharController_get_radius))(moudule_base + 0x1044CBAC0);
    //CharController_set_radius = (typeof(CharController_set_radius))(moudule_base + 0x1044CBB24);
    //Get_isAiming = (typeof(Get_isAiming))(moudule_base + 0x1022D52D8);
    
    //=========搜索public WeaponFireComponent get_CurrentFireComponent() { }  第十五个======
    GetCurrentFireComponent = (typeof(GetCurrentFireComponent))(moudule_base + htoi("0x102C36460"));//⑮
    
    //=========搜索public virtual Weapon get_CurrentWeapon() { }  第十六个======
    GetCurrentWeapon = (typeof(GetCurrentWeapon))(moudule_base + htoi("0x102B68220"));//⑯
    // Weapon_GetCurrentFireComponent = (typeof(Weapon_GetCurrentFireComponent))(moudule_base + 0x101DF4E34);
    
    
    
    
}
static void drawRectFunc(id class1,SEL sel,CGRect rect){
//    血量开关=[[NSUserDefaults standardUserDefaults] boolForKey:@"血量开关"];
//    射线开关=[[NSUserDefaults standardUserDefaults] boolForKey:@"射线开关"];
//    名字开关=[[NSUserDefaults standardUserDefaults] boolForKey:@"名字开关"];
//    过直播开关=[[NSUserDefaults standardUserDefaults] boolForKey:@"过直播开关"];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if(!isVaildPtr(Global_Camera))return;
    Vector3 target;
    float delta = -1;
    Vector3 target_screen;
    
    for (Entity e : Entitys) {
        CGPoint point;
        Vector3 screen;
        //printMatrix(PV);
        
        screen = WorldToScreen(e.Location,PV);
        //NSLog(@"+[HOOK]%f %f",screen.x,screen.y);
        
        point.x = screen.x;
        point.y = screen.y;
        float di = sqrt(pow(screen.x-screenX/2, 2) + pow(screen.y-screenY/2,2));
        if(delta == -1 || delta > di){
            delta = di;
            target_screen = e.CanUseHeadBone ? WorldToScreen(e.HeadPosition, PV) : WorldToScreen(e.CenterPosition, PV);
            target = e.CanUseHeadBone ? e.HeadPosition : e.CenterPosition;
        }
        if (血量开关) {
            CGRect bloodRect = CGRectMake(screen.x-25, screen.y, 50, 50/13.8);
            CGRect RealBlood = CGRectMake(screen.x-25, screen.y, 50*(e.HP/100), 50/13.8);
            CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
            CGContextAddRect(context, RealBlood);
            CGContextDrawPath(context, kCGPathFill);
            CGContextSetLineWidth(context, 1);
            CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
            CGContextAddRect(context, bloodRect);
        }
        
        
        for (int i = 0; i<5; i++) {
            CGContextMoveToPoint(context, screen.x-25+(i+1)*50/6, screen.y);
            CGContextAddLineToPoint(context, screen.x-25+(i+1)*50/6, screen.y+50/13.8);
        }
        CGContextDrawPath(context, kCGPathStroke);
        if (名字开关) {
            NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            [paragraphStyle setAlignment:NSTextAlignmentCenter];
            CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
            CGContextSetLineWidth(context, 0.6);
            
            CGContextSetTextDrawingMode(context, kCGTextStroke);
            [e.name drawInRect:CGRectMake(point.x-100,point.y+50/13.8, 200, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10],NSForegroundColorAttributeName:[UIColor blackColor],NSParagraphStyleAttributeName:paragraphStyle}];
            CGContextSetTextDrawingMode(context, kCGTextFill);
            [e.name drawInRect:CGRectMake(point.x-100,point.y+50/13.8, 200, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10],NSForegroundColorAttributeName:[UIColor greenColor],NSParagraphStyleAttributeName:paragraphStyle}];
        }
        if (射线开关) {
            CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextMoveToPoint(context, screenX/2, 15);
            CGContextAddLineToPoint(context, point.x, point.y);
            CGContextDrawPath(context, kCGPathStroke);
        }
        
        
    }
    //====================限制子弹追踪=========================
    //也可以全部用//注释，都可以
    shouldTrace = NO;
    if(delta != -1){
        shouldTrace = YES;
        TraceTarget = target;
    }
    
}

static void tick(){
    //Tick();
    Global_Camera = GetMainCamera();
    if(!isVaildPtr(Global_Camera))return;
    int64_t Game = GetGame();
    if(!isVaildPtr(Game))return;
    My_Pawn = Get_LocalPawn();
    int32_t LocalCamp = GetLocalPlayerCamp();
    //NSLog(@"+[HOOK]%d",LocalCamp);
    GetViewMatrix(Global_Camera,CFViewMatrix);
    GetProjectionMatrix(Global_Camera,projectionMatrix);
    CalPV();
    Entitys.clear();
    
    //private UnityTool.ListWN<Pawn> m_AllPlayerPawns;sou
    int64_t all_players = *(long long*)(Game + htoi("0x68"));
    if(!isVaildPtr(all_players))return;
    int32_t count = *(int32_t*)(all_players + htoi("0x18"));
    // NSLog(@"+[HOOK]all_player %d",count);
    for (int i =0; i<count; i++) {
        int64_t player = GetItem(all_players,i);
        //NSLog(@"+[HOOK][%d]%llX",i,player);
        if(!isVaildPtr(player))continue;
        //搜protected PlayerInfo m_PlayerInfo;  偏移
        int64_t playerInfo = *(long long*)(player + htoi("0x400"));
        if(!isVaildPtr(playerInfo))continue;
        //搜索private bool m_PlayerInfoToHeadShow;  队友
        int32_t Camp = *(int32_t*)(playerInfo + htoi("0xF4"));
        if(Camp == LocalCamp)continue;
        //搜索private float m_Health;   血量
        if(*(float*)(playerInfo + htoi("0x110")) <= 0.0f)continue;
        Entity Pawn;
        //protected string m_NickName;  名字
        int64_t Nickname = *(long long*)(playerInfo + htoi("0x70"));
        NSString *m_NickName = isVaildPtr(Nickname) ? [[NSString alloc] initWithCharacters:(const unsigned short*)(Nickname+htoi("0x14")) length:*(int32_t*)(Nickname + htoi("0x10"))] : @"UnknownName";
        int64_t headBone = GetHeadTransForm(player);
        Pawn.CanUseHeadBone = isVaildPtr(headBone) ? YES : NO;
        if(isVaildPtr(headBone))Pawn.HeadPosition = GetPosition(headBone);
        Pawn.CenterPosition = Get_TargetCenterPosition(player);
        //Vector3 center = Get_TargetCenterPosition(player);
        //Vector3 offset = Get_TargetCenterOffset(player);
        //Vector3 Loc = Vector3(center.x, center.y, center.z);
        Pawn.Location = GetPlayerHeadPosition(player);
        //搜索private float m_Health;   血量
        Pawn.HP = *(float*)(playerInfo + htoi("0x110"));
        Pawn.name = m_NickName;
        Entitys.push_back(Pawn);
        
    }
}
@interface HanBo : UIView
@property (strong, nonatomic, nullable) CADisplayLink *displayLink;
@property (strong, nonatomic, nullable) UIView *autoFire;
@end
@implementation HanBo
- (void)Tickfuncc{
    tick();
    [self setNeedsDisplay];
}
- (void)startDraw{
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(Tickfuncc)];
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}


@end
HanBo * Global_DrawView;
CADisplayLink *displayLink;
@interface NSObject(huizhi)



@end
@implementation NSObject(huizhi)

/*
 - (void)RayLineBtn:(UITapGestureRecognizer *)btn{
 if(btn.state == UIGestureRecognizerStateEnded){
 screenX = [UIScreen mainScreen].bounds.size.width;
 screenY = [UIScreen mainScreen].bounds.size.height;
 HanBo *view = [[HanBo alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.origin.y, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
 view.layer.opacity = 1.0;
 [view setBackgroundColor:[UIColor clearColor]];
 [view setUserInteractionEnabled:NO];
 Global_DrawView = view;
 
 [[UIApplication sharedApplication].keyWindow addSubview:Global_DrawView];
 
 displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick)];
 
 [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
 }
 
 }
 */
+ (void)load{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        screenX = [UIScreen mainScreen].bounds.size.width;
        screenY = [UIScreen mainScreen].bounds.size.height;
        my_class_replaceMethod(HanBo.class, NSSelectorFromString(@"drawRect:"), (IMP)drawRectFunc, method_getTypeEncoding(class_getInstanceMethod(HanBo.class, @selector(drawRect:))));
        HanBo *view = [[HanBo alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.origin.y, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        view.layer.opacity = 1.0;
        [view setBackgroundColor:[UIColor clearColor]];
        [view setUserInteractionEnabled:NO];
        Global_DrawView = view;
        [[[[UIApplication sharedApplication] windows]lastObject] addSubview:Global_DrawView];
//        if (过直播开关) {
//            UITextField *HideView = [[UITextField alloc] initWithFrame:Global_DrawView.frame];
//            HideView.secureTextEntry = YES;
//            [HideView.subviews.firstObject setUserInteractionEnabled:YES];
//            [HideView.subviews.firstObject addSubview:Global_DrawView];
//            [HideView setUserInteractionEnabled:NO];
//            [[UIApplication sharedApplication].keyWindow addSubview:HideView];
//        }
        [view startDraw];
    });
}

+(void)关闭追踪{
    DobbyHook((void*)(moudule_base + htoi("0x102DA814C")), (void*)CalWeaponFire, (void**)&orig_CalWeaponFire);
}

+(void)菜单{
    //    if(btn.state == UIGestureRecognizerStateEnded){
    //======================创建一个一级菜单主页======================
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"wy" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    //======================创建第一个一级菜单按钮======================
    UIAlertAction *HuiZhi = [UIAlertAction actionWithTitle:HuiZhiZZ style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if(HuiZhiFlag == YES){
            HuiZhiFlag = NO;
            HuiZhiZZ  = @"开启绘制";
        }else{
            HuiZhiFlag = YES;
            HuiZhiZZ = @"关闭绘制";
        }
    }];
    //======================创建第二个一级菜单按钮======================
    UIAlertAction *ZhuiZong = [UIAlertAction actionWithTitle:ZhuizongZZ style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if(ZhuizongFlag == YES){
            ZhuizongFlag = NO;
            ZhuizongZZ  = @"开启追踪";
        }else{
            ZhuizongFlag = YES;
    //DobbyHook((void*)(moudule_base + htoi("0x102BBE750")), (void*)CalWeaponFire, (void**)&orig_CalWeaponFire);
            ZhuizongZZ = @"关闭追踪";
        }
    }];
    //======================创建第三个一级菜单按钮======================
    //        UIAlertAction *QunLiao = [UIAlertAction actionWithTitle:@"加入群聊" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
    //            //======================一键加群============================
    //            NSString *urlStr = [NSString stringWithFormat:@"mqqapi://card/show_pslcard?src_type=internal&version=1&uin=%@&key=%@&card_type=group&source=external&jump_from=webapi", @"513416765",@"3758d4d62333201984c0af3c9779ee16f198d9956e0037da55f8636e81bebf76"];
    //            NSURL *url = [NSURL URLWithString:urlStr];
    //            if([[UIApplication sharedApplication] canOpenURL:url]){
    //                [[UIApplication sharedApplication] openURL:url];
    //            }
    //        }];
    UIAlertAction *OFF = [UIAlertAction actionWithTitle:@"关闭菜单" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
    }];
    
    //========================添加按钮图标到主菜单======================
    //添加顺序决定按钮位置显示顺序
    [alert addAction:HuiZhi];//添加绘制按钮
    [alert addAction:ZhuiZong];//添加追踪按钮
    //        [alert addAction:QunLiao];//添加加入群聊按钮
    [alert addAction:OFF];//添加关闭按钮
    //========================添加主菜单视图===========================
    [[[[UIApplication sharedApplication] windows] objectAtIndex:0].rootViewController presentViewController:alert animated:YES completion:nil];
    //}
}
@end
