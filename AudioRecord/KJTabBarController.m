//
//  KJTabBarController.m
//  SocketConnect
//
//  Created by TigerHu on 2023/8/23.
//

#import "KJTabBarController.h"
#import "ViewController.h"

@interface KJTabBarController ()


@end

@implementation KJTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    ViewController *home = [[ViewController alloc]init];
    [self addChildVc:home title:@"首页" image:@"" selectedImage:@""];
    
    UINavigationController *homeNav = [[UINavigationController alloc]initWithRootViewController:home];
    
    self.viewControllers = @[homeNav];
}

- (void)addChildVc:(UIViewController *)childVc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage {
    
    childVc.tabBarItem.title = title;
    childVc.tabBarItem.image = [[UIImage imageNamed:image]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childVc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

@end
