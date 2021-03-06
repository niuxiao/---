//
//  ViewController.m
//  Test1030
//
//  Created by 哈哈 on 18/10/16.
//  Copyright © 2018年 哈哈. All rights reserved.
//

#import "GPUImageCameraViewController.h"
#import "LMFilterChooserView.h"
#import "LMCameraManager.h"
#import "LMCameraFilters.h"
#import <GPUImage/GPUImage.h>
//    判断是否是iphone4
#define IS_IPHONE4 ([UIScreen mainScreen].bounds.size.height == 480)


#define iphone4_image_scale 480 / 320

#define iphone6_image_scale 500 / 375

#define upblackview_height 40.0f

#define downblackview_height 100.0f

@interface GPUImageCameraViewController () {
    GPUImageStillCamera *videoCamera;
    GPUImageView *view1;
}

//    滤镜数组
@property (nonatomic , strong) NSArray *filters;

//    选择效果视图
@property (nonatomic , strong) LMCameraManager *cameraManager;
//    闪光灯按钮
@property (nonatomic , strong) UIButton *flashButton;
//    摄像头位置按钮
@property (nonatomic , strong) UIButton *cameraPostionButton;
//    拍照
@property (nonatomic , strong) UIButton *snapshotButton;
/// 返回
@property (nonatomic , strong) UIButton *backButton;

//    background black view
@property (nonatomic , strong) UIView  *upBlackView;
@property (nonatomic , strong) UIView  *downBlackView;
//    filters选择器
@property (nonatomic , strong) LMFilterChooserView *filterChooserView;

@end

@implementation GPUImageCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.cameraManager startCamera];
    [self.view addSubview:self.upBlackView];
    [self.upBlackView addSubview:self.cameraPostionButton];
    [self.upBlackView addSubview:self.flashButton];
    [self.view addSubview:self.downBlackView];
    [self.downBlackView addSubview:self.snapshotButton];
    [self.downBlackView addSubview:self.backButton];
    [self.filterChooserView addFilters:self.filters];
    [self.view addSubview:self.filterChooserView];
}


#pragma mark 滤镜组
- (NSArray *)filters {
    if (!_filters) {
        
#warning  滤镜需要自定义，demo只是演示来用
        
        GPUImageFilterGroup *f1 = [LMCameraFilters normal];
        [videoCamera addTarget:f1];
        
        GPUImageFilterGroup *f2 = [LMCameraFilters contrast];
        [videoCamera addTarget:f2];
        
        GPUImageFilterGroup *f3 = [LMCameraFilters exposure];
        [videoCamera addTarget:f3];
        
        GPUImageFilterGroup *f4 = [LMCameraFilters saturation];
        [videoCamera addTarget:f4];
        
        GPUImageFilterGroup *f5 = [LMCameraFilters testGroup1];
        [videoCamera addTarget:f5];
        GPUImageFilterGroup *f6 = [LMCameraFilters sketchFilter];
        [videoCamera addTarget:f6];
        GPUImageFilterGroup *f7 = [LMCameraFilters sphereFilter];
        [videoCamera addTarget:f7];
        
        GPUImageFilterGroup *f8 = [LMCameraFilters bulgeDistortionFilter];
        [videoCamera addTarget:f8];
        
        GPUImageFilterGroup *f9 = [LMCameraFilters toonFilter];
        [videoCamera addTarget:f9];
        
        GPUImageFilterGroup *f10 = [LMCameraFilters embossFilter];
        [videoCamera addTarget:f10];
        
        GPUImageFilterGroup *f12 = [LMCameraFilters swirlFilter];
        [videoCamera addTarget:f12];
        GPUImageFilterGroup *f11 = [LMCameraFilters selectiveBlurFilter];
        [videoCamera addTarget:f11];
        
        GPUImageFilterGroup *f13 = [LMCameraFilters VignetteFilter];
        [videoCamera addTarget:f13];
        NSArray *arr = [NSArray arrayWithObjects:f1,f6,f7,f8,f9,f10,f11,f12,f13,f2,f3,f4,f5,nil];
        _filters = arr;
    }
    return _filters;
}

#pragma mark 选择滤镜视图

- (LMFilterChooserView *)filterChooserView {
    if (!_filterChooserView) {
        float screen_width = [UIScreen mainScreen].bounds.size.width;
        float screen_height = [UIScreen mainScreen].bounds.size.height;
        LMFilterChooserView *scrollView = [[LMFilterChooserView alloc] initWithFrame:CGRectMake(0, screen_height - downblackview_height - 130.0f, screen_width, 130.0f)];
        __weak GPUImageCameraViewController *weakSelf = self;
        [scrollView addSelectedEvent:^(GPUImageFilterGroup *filter, NSInteger idx) {
            [weakSelf.cameraManager setFilterAtIndex:idx];
        }];
        _filterChooserView = scrollView;
    }
    return _filterChooserView;
}

#pragma mark 上黑色视图
- (UIView *)upBlackView {
    if (!_upBlackView) {
        float x = 0;
        float y = 0;
        float width = [UIScreen mainScreen].bounds.size.width;
        float height = upblackview_height;
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        view.userInteractionEnabled = YES;
        [self.view addSubview:view];
        _upBlackView = view;
    }
    return _upBlackView;
}

#pragma mark 下黑色视图
- (UIView *)downBlackView {
    if (!_downBlackView) {
        float x = 0;
        float y = [UIScreen mainScreen].bounds.size.height - downblackview_height;
        float width = [UIScreen mainScreen].bounds.size.width;
        float height = downblackview_height;
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [self.view addSubview:view];
        _downBlackView = view;
    }
    return _downBlackView;
}

#pragma mark 摄像头管理器
- (LMCameraManager *)cameraManager {
    if (!_cameraManager) {
        CGRect rect;
        float width = [UIScreen mainScreen].bounds.size.width;
        
        if (IS_IPHONE4) rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, width * iphone4_image_scale);
        else  rect = CGRectMake(0, 40, width, width * iphone6_image_scale);
        
        LMCameraManager *cameraManager = [[LMCameraManager alloc] initWithFrame:rect superview:self.view];
        [cameraManager addFilters:self.filters];
        [cameraManager setfocusImage:[UIImage imageNamed:@"touch_focus_x"]];
        _cameraManager = cameraManager;
    }
    return _cameraManager;
}

#pragma mark 闪光灯按钮
- (UIButton *)flashButton {
    if (!_flashButton) {
        float width = 40.0f;
        float height = 40.0f;
        float x = [UIScreen mainScreen].bounds.size.width - width;
        float y = 0;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 2;
        [button setImage:[UIImage imageNamed:@"flashing_auto"] forState:UIControlStateNormal];
        button.frame = CGRectMake(x, y, width, height);
        [button addTarget:self action:@selector(selectedButton:) forControlEvents:UIControlEventTouchUpInside];
        _flashButton = button;
    }
    return _flashButton;
}

#pragma mark 摄像头位置按钮

- (UIButton *)cameraPostionButton {
    if (!_cameraPostionButton) {
        float width = 40.0f;
        float height = 40.0f;
        float x = 0;
        float y = 0;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 3;
        [button setImage:[UIImage imageNamed:@"btn_flip_a"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"btn_flip_b"] forState:UIControlStateHighlighted];
        button.frame = CGRectMake(x, y, width, height);
        [button addTarget:self action:@selector(selectedButton:) forControlEvents:UIControlEventTouchUpInside];
        _cameraPostionButton = button;
    }
    return _cameraPostionButton;
}

#pragma mark 快照按钮

- (UIButton *)snapshotButton {
    if (!_snapshotButton) {
        float width = 80.0f;
        float height = 80.0f;
        
        CGPoint center = CGPointMake(self.downBlackView.bounds.size.width / 2, self.downBlackView.bounds.size.height / 2);
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 1;
        [button setTitle:@"拍照" forState:UIControlStateNormal];
        button.backgroundColor = [UIColor redColor];
        button.bounds = CGRectMake(0, 0, width, height);
        button.center = center;
        [button addTarget:self action:@selector(selectedButton:) forControlEvents:UIControlEventTouchUpInside];
        _snapshotButton = button;
    }
    return _snapshotButton;
}

#pragma mark 返回按钮
-(UIButton*)backButton{
    if (!_backButton) {
        CGPoint center = CGPointMake(20, self.downBlackView.bounds.size.height / 2);

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 4;
        [button setTitle:@"返回" forState:UIControlStateNormal];
        button.backgroundColor = [UIColor redColor];
        button.center = center;
        button.bounds = CGRectMake(0, 0, 44, 44);
        [button addTarget:self action:@selector(selectedButton:) forControlEvents:UIControlEventTouchUpInside];
        _backButton = button;
    }
    
    return _backButton;
    
}

#pragma mark 按钮点击事件
- (void)selectedButton:(UIButton *)button {
    
    switch (button.tag) {
        case 1:
            [self snapshot];
            break;
        case 2:
            [self changeFlashMode:button];
            break;
        case 3:
            [self changeCameraPostion];
            break;
        case 4:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        default:
            break;
    }
}

#pragma mark 拍照

- (void)snapshot {
    
    [self.cameraManager snapshotSuccess:^(UIImage *image) {
        
        NSLog(@"%@",image);
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    } snapshotFailure:^{
        NSLog(@"拍照失败");
    }];
}

#pragma mark 改变摄像头位置
- (void)changeCameraPostion {
    if (self.cameraManager.position == LMCameraManagerDevicePositionBack){
        self.cameraManager.position = LMCameraManagerDevicePositionFront;
        self.flashButton.hidden = YES;
    }
    else{
        self.cameraManager.position = LMCameraManagerDevicePositionBack;
        self.flashButton.hidden = NO;
    }
}

#pragma mark 改变闪光灯状态
- (void)changeFlashMode:(UIButton *)button {
    switch (self.cameraManager.flashMode) {
        case LMCameraManagerFlashModeAuto:
            self.cameraManager.flashMode = LMCameraManagerFlashModeOn;
            [button setImage:[UIImage imageNamed:@"flashing_on"] forState:UIControlStateNormal];
            break;
        case LMCameraManagerFlashModeOff:
            self.cameraManager.flashMode = LMCameraManagerFlashModeAuto;
            [button setImage:[UIImage imageNamed:@"flashing_auto"] forState:UIControlStateNormal];
            break;
        case LMCameraManagerFlashModeOn:
            self.cameraManager.flashMode = LMCameraManagerFlashModeOff;
            [button setImage:[UIImage imageNamed:@"flashing_off"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}



@end


