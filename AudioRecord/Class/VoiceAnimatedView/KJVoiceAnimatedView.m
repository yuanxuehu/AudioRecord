//
//  KJVoiceAnimatedView.m
//  AudioRecord
//
//  Created by TigerHu on 2023/8/24.
//

#import "KJVoiceAnimatedView.h"
#import "Masonry.h"

@interface KJVoiceAnimatedView ()
@property (nonatomic, strong) UIImageView *leftImgView;
@property (nonatomic, strong) UIImageView *rightImgView;
@end

@implementation KJVoiceAnimatedView

- (void)dealloc {
    NSLog(@"%@",[self class]);
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self _setUpDefaultInfo];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setUpDefaultInfo];
    }
    return self;
}

- (void)_setUpDefaultInfo
{
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];

    NSMutableArray *imgArr = [NSMutableArray array];
    for (int i = 1; i < 7; i++) {
        NSString *imgName = [NSString stringWithFormat:@"icon_equipment_tip_%d",i];
        UIImage *img = [UIImage imageNamed:imgName];
        [imgArr addObject:img];
    }
    self.rightImgView.animationImages = imgArr;
    self.rightImgView.animationDuration = .8f;//一次循环时间
    self.hidden = YES;
}

- (void)startAniamted
{
    [self.rightImgView startAnimating];
    self.hidden = NO;
}

- (void)stopAnimated
{
    [self.rightImgView stopAnimating];
    self.hidden = YES;
}

- (NSString *)_bundleImageName:(NSString *)name
{
    //获取路径
    NSString * path = [[NSBundle mainBundle] pathForResource:@"KJVoiceAnimatedView" ofType:@"bundle"];
    return [[path stringByAppendingPathComponent:@"image"] stringByAppendingPathComponent:name];
}

#pragma mark - Lazy Load

- (UIImageView *)leftImgView
{
    if (!_leftImgView) {
        _leftImgView = [UIImageView new];
        [self addSubview:_leftImgView];
        
        [_leftImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self).mas_offset(15);
            make.left.mas_equalTo(self).mas_offset(10);
            make.bottom.mas_equalTo(self).mas_offset(-15);
            make.width.mas_equalTo(self.rightImgView);
            make.right.mas_equalTo(self.rightImgView.mas_left).offset(-5);
        }];
    }
    return _leftImgView;
}

- (UIImageView *)rightImgView
{
    if (!_rightImgView) {
        _rightImgView = [UIImageView new];
        [self addSubview:_rightImgView];
        
        [_rightImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(10, 10, 10, 10));
        }];
    }
    return _rightImgView;
}

@end

