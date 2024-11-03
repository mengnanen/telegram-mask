// 仅TG及其第三方可用，未适配其他应用，非全局版
// 水平很低，代码很乱，仅供参考～
// iOS宝藏 https://t.me/iosrxwy

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CaptainHook/CaptainHook.h>

@interface CalculatorViewController : UIViewController
@property (nonatomic, strong) UILabel *displayLabel;
@property (nonatomic, strong) UILabel *historyLabel;
@property (nonatomic, strong) NSMutableString *currentExpression;
@property (nonatomic, strong) NSMutableString *history;
@property (nonatomic, strong) NSString *customPassword;
@property (nonatomic, assign) BOOL isCustomPasswordEnabled;
@end

@implementation CalculatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.currentExpression = [NSMutableString stringWithString:@""];
    self.history = [NSMutableString stringWithString:@""];
    
    // 读取保存的自定义密码
    self.customPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"customPassword"];
    self.isCustomPasswordEnabled = self.customPassword != nil;  // 判断是否启用了自定义密码
    
    // 不显示状态问题自行调整吧
    [self setNeedsStatusBarAppearanceUpdate];
    
    // 计算器历史记录标签
    self.historyLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, self.view.bounds.size.width - 40, 80)];
    self.historyLabel.text = @"";
    self.historyLabel.font = [UIFont systemFontOfSize:20];
    self.historyLabel.textColor = [UIColor lightGrayColor];
    self.historyLabel.numberOfLines = 0;
    [self.view addSubview:self.historyLabel];
    
    self.displayLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 250, self.view.bounds.size.width - 40, 80)];
    self.displayLabel.text = @"0";
    self.displayLabel.font = [UIFont systemFontOfSize:48];
    self.displayLabel.textAlignment = NSTextAlignmentRight;
    self.displayLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.displayLabel];
    
    // 手势控制，三指双击
    UITapGestureRecognizer *threeFingerDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showCustomPasswordMenu)];
    threeFingerDoubleTap.numberOfTapsRequired = 2;
    threeFingerDoubleTap.numberOfTouchesRequired = 3;
    [self.view addGestureRecognizer:threeFingerDoubleTap];

    UITapGestureRecognizer *twoFingerDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCustomPasswordMenu)];
    twoFingerDoubleTap.numberOfTapsRequired = 2;
    twoFingerDoubleTap.numberOfTouchesRequired = 2;
    [self.view addGestureRecognizer:twoFingerDoubleTap];
    
    [self setupButtons];
}

- (void)setupButtons {
    NSArray *buttons = @[
        @[@"C", @"（", @"）", @"/"],
        @[@"7", @"8", @"9", @"*"],
        @[@"4", @"5", @"6", @"-"],
        @[@"1", @"2", @"3", @"+"],
        @[@"0", @".", @"="]
    ];

    CGFloat buttonWidth = (self.view.bounds.size.width - 100) / 4;
    CGFloat buttonHeight = 70;
    CGFloat yOffset = self.view.bounds.size.height - 5 * buttonHeight - 160;

    for (int row = 0; row < buttons.count; row++) {
        NSArray *rowButtons = buttons[row];
        for (int col = 0; col < rowButtons.count; col++) {
            NSString *title = rowButtons[col];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            
            if ([title isEqualToString:@"0"]) {
                button.frame = CGRectMake(20, yOffset + row * (buttonHeight + 20), buttonWidth * 2 + 20, buttonHeight);
                button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                button.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
            } else if ([title isEqualToString:@"."]) {
                button.frame = CGRectMake(20 + 2 * (buttonWidth + 20), yOffset + row * (buttonHeight + 20), buttonWidth, buttonHeight);
            } else if ([title isEqualToString:@"="]) {
                button.frame = CGRectMake(20 + 3 * (buttonWidth + 20), yOffset + row * (buttonHeight + 20), buttonWidth, buttonHeight);
            } else {
                button.frame = CGRectMake(20 + col * (buttonWidth + 20), yOffset + row * (buttonHeight + 20), buttonWidth, buttonHeight);
            }
            
            [button setTitle:title forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:28];
            
            if ([title isEqualToString:@"="]) {
                button.backgroundColor = [UIColor systemRedColor];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            } else if ([title isEqualToString:@"+"] || [title isEqualToString:@"-"] || [title isEqualToString:@"*"] || [title isEqualToString:@"/"]) {
                button.backgroundColor = [UIColor systemGreenColor];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            } else {
                button.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            
            button.layer.cornerRadius = buttonHeight / 2;
            button.layer.masksToBounds = YES;
            [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:button];
        }
    }
}

- (void)buttonTapped:(UIButton *)sender {
    NSString *title = sender.titleLabel.text;
    
    title = [title stringByReplacingOccurrencesOfString:@"（" withString:@"("];
    title = [title stringByReplacingOccurrencesOfString:@"）" withString:@")"];
    
    if ([title isEqualToString:@"="]) {
        if (self.currentExpression.length == 0) {
            self.displayLabel.text = @"0";
            return;
        }
        
        NSString *result = [self calculateExpression:self.currentExpression];
        if ([result isEqualToString:@"iOS宝藏：别乱玩哦～"]) {
            self.displayLabel.font = [UIFont systemFontOfSize:18];
        } else {
            self.displayLabel.font = [UIFont systemFontOfSize:48];
        }
        
        self.displayLabel.text = result;
        
        NSString *historyEntry = [NSString stringWithFormat:@"%@ = %@", self.currentExpression, result];
        [self.history appendFormat:@"%@\n", historyEntry];
        self.historyLabel.text = self.history;
        self.currentExpression = [NSMutableString stringWithString:result];
    } else if ([title isEqualToString:@"C"]) {
        self.currentExpression = [NSMutableString stringWithString:@""];
        self.displayLabel.text = @"0";
        self.historyLabel.text = @"";
        self.displayLabel.font = [UIFont systemFontOfSize:48];
    } else {
        [self.currentExpression appendString:title];
        self.displayLabel.text = self.currentExpression;
        self.displayLabel.font = [UIFont systemFontOfSize:48];
    }

    NSString *currentPassword = [self getCurrentPassword];
    if ([self.currentExpression isEqualToString:currentPassword]) {
        [self hideCalculatorView];
    }
}

- (NSString *)calculateExpression:(NSString *)expression {
    @try {
        NSString *floatExpression = [expression stringByReplacingOccurrencesOfString:@"/" withString:@".0/"];
        floatExpression = [floatExpression stringByReplacingOccurrencesOfString:@"*" withString:@".0*"];
        
        // 使用 NSExpression 进行运算
        NSExpression *exp = [NSExpression expressionWithFormat:floatExpression];
        id result = [exp expressionValueWithObject:nil context:nil];
        
        if ([result isKindOfClass:[NSNumber class]]) {
            NSNumber *numberResult = (NSNumber *)result;
            double doubleResult = numberResult.doubleValue;
            if (fmod(doubleResult, 1) == 0) {
                return [NSString stringWithFormat:@"%.0f", doubleResult];  // 如果是整数
            } else {
                return [NSString stringWithFormat:@"%.2f", round(doubleResult * 100) / 100];  // 小数保留两位
            }
        }
        return [NSString stringWithFormat:@"%@", result];
    } @catch (NSException *exception) {
        return @"iOS宝藏：别乱玩哦～";  // 错误提示
    }
}

- (NSString *)getCurrentPassword {
    if (self.isCustomPasswordEnabled && self.customPassword) {
        return self.customPassword;
    } else {
        return [self getCurrentTimePassword];
    }
}

- (NSString *)getCurrentTimePassword {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [formatter setDateFormat:@"HHmm"];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    return currentTime;
}

- (void)hideCalculatorView {
    [self.view removeFromSuperview];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    for (UIView *subview in keyWindow.subviews) {
        if ([subview isKindOfClass:[CalculatorViewController class]]) {
            [subview removeFromSuperview];
        }
    }
    keyWindow.hidden = YES;
}

// 显示自定义密码设置窗口
- (void)showCustomPasswordMenu {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"iOS宝藏"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *setCustomPasswordAction = [UIAlertAction actionWithTitle:@"自定义密码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self verifyCurrentPasswordBeforeSetting];
    }];
    
    UIAlertAction *changePasswordAction = [UIAlertAction actionWithTitle:@"关闭自定义" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self verifyCurrentPasswordBeforeDisabling];
    }];
    
    UIAlertAction *morePluginsAction = [UIAlertAction actionWithTitle:@"更多插件" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tg://resolve?domain=iosrxwy"] options:@{} completionHandler:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:setCustomPasswordAction];
    [alert addAction:changePasswordAction];
    [alert addAction:morePluginsAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

// 先验证当前密码，然后设置新密码
- (void)verifyCurrentPasswordBeforeSetting {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请输入当前密码"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"当前密码";
        textField.secureTextEntry = YES;
    }];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *inputPassword = alert.textFields[0].text;
        if ([inputPassword isEqualToString:[self getCurrentPassword]]) {
            [self setCustomPassword];
        } else {
            [self showError:@"密码不正确"];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:confirmAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

// 设置新密码并保存到NSUserDefaults
- (void)setCustomPassword {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设置自定义密码"
                                                                   message:@"请输入新密码"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"新密码";
        textField.secureTextEntry = YES;
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"再次输入新密码";
        textField.secureTextEntry = YES;
    }];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *newPassword = alert.textFields[0].text;
        NSString *confirmPassword = alert.textFields[1].text;
        if ([newPassword isEqualToString:confirmPassword]) {
            self.customPassword = newPassword;
            self.isCustomPasswordEnabled = YES;
            
            // 保存自定义密码到NSUserDefaults
            [[NSUserDefaults standardUserDefaults] setObject:self.customPassword forKey:@"customPassword"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self showSuccess:@"自定义密码已设置"];
        } else {
            [self showError:@"两次密码不一致"];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:confirmAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

// 验证当前密码然后关闭自定义密码
- (void)verifyCurrentPasswordBeforeDisabling {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"输入当前密码"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"当前密码";
        textField.secureTextEntry = YES;
    }];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *inputPassword = alert.textFields[0].text;
        if ([inputPassword isEqualToString:[self getCurrentPassword]]) {
            self.isCustomPasswordEnabled = NO;
            self.customPassword = nil;
            
            // 移除保存的自定义密码
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"customPassword"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self showSuccess:@"自定义密码已关闭"];
        } else {
            [self showError:@"密码不正确"];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:confirmAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showSuccess:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"成功"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showError:(NSString *)errorMessage {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误"
                                                                   message:errorMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)hideCustomPasswordMenu {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

CHDeclareClass(AppDelegate)

CHOptimizedMethod(2, self, BOOL, AppDelegate, application, UIApplication *, application, didFinishLaunchingWithOptions, NSDictionary *, launchOptions) {
    CHSuper(2, AppDelegate, application, application, didFinishLaunchingWithOptions, launchOptions);
    
    CalculatorViewController *calculatorVC = [[CalculatorViewController alloc] init];
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    window.windowLevel = UIWindowLevelAlert + 999;  // 其他应用自测吧，这里是为了保证最上层
    window.rootViewController = calculatorVC;
    [window makeKeyAndVisible];
    
    [UIApplication sharedApplication].delegate.window = window;
    return YES;
}

CHConstructor {
    CHLoadLateClass(AppDelegate);
    CHClassHook(2, AppDelegate, application, didFinishLaunchingWithOptions);
}

// 移除分割线 by level3tjg

@interface ASDisplayNode : NSObject
@property id supernode;
- (BOOL)isSeparatorNode;
@end

@interface CALayer (AsyncDisplayKit)
@property ASDisplayNode *asyncdisplaykit_node;
@end

%hook CALayer
- (void)setBackgroundColor:(CGColorRef)color {
    if ([self.asyncdisplaykit_node isSeparatorNode])
        color = UIColor.clearColor.CGColor;
    %orig;
}
%end

%hook ASDisplayNode
%new
- (BOOL)isSeparatorNode {
    for (NSString *name in @[
        @"separatorNode",
        @"topSeparatorNode",
        @"bottomSeparatorNode",
        @"topStripeNode",
        @"bottomStripeNode"
    ]) {
        if ([self isEqual:object_getIvar(self.supernode, class_getInstanceVariable(object_getClass(self.supernode), name.UTF8String))]) {
            return YES;
        }
    }
    return NO;
}
%end

// 原生键盘暗黑增强 by dayanch96

@interface UIView (Private)
@property (nonatomic, assign, readonly) BOOL _mapkit_isDarkModeEnabled;

- (UIViewController *)_viewControllerForAncestor;
@end

static BOOL isDarkMode(UIView *view) {
    if ([view respondsToSelector:@selector(_mapkit_isDarkModeEnabled)]) {
        return view._mapkit_isDarkModeEnabled;
    }

    return view._viewControllerForAncestor.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
}

@interface UIKeyboard : UIView // Regular keyboard
+ (instancetype)activeKeyboard;
@end

%hook UIKeyboard
- (void)displayLayer:(id)arg1 {
    %orig;

    self.backgroundColor = isDarkMode(self) ? [UIColor blackColor] : [UIColor clearColor];
}
%end

@interface UIPredictionViewController : UIViewController // Keyboard with enabled predictions panel
@end

%hook UIPredictionViewController
- (id)_currentTextSuggestions {
    UIKeyboard *keyboard = [%c(UIKeyboard) activeKeyboard];

    if (isDarkMode(keyboard)) {
        [self.view setBackgroundColor:[UIColor blackColor]];
        keyboard.backgroundColor = [UIColor blackColor];
    } else {
        [self.view setBackgroundColor:[UIColor clearColor]];
        keyboard.backgroundColor = [UIColor clearColor];
    }

    return %orig;
}
%end

@interface UIKeyboardDockView : UIView // Dock under keyboard for notched devices
@end

%hook UIKeyboardDockView
- (void)layoutSubviews {
    %orig;

    self.backgroundColor = isDarkMode(self) ? [UIColor blackColor] : [UIColor clearColor];
}
%end

%hook UIInputView
- (void)layoutSubviews {
    %orig;

    if ([self isKindOfClass:NSClassFromString(@"TUIEmojiSearchInputView")] // Emoji searching panel
     || [self isKindOfClass:NSClassFromString(@"_SFAutoFillInputView")]) { // Autofill password
        self.backgroundColor = isDarkMode(self) ? [UIColor blackColor] : [UIColor clearColor];
    }
}
%end

@interface UIKBVisualEffectView : UIVisualEffectView
@property (nonatomic, copy, readwrite) NSArray *backgroundEffects;
@end

%hook UIKBVisualEffectView
- (void)layoutSubviews {
    %orig;

    if (isDarkMode(self)) {
        self.backgroundEffects = nil;
        self.backgroundColor = [UIColor blackColor];
    }
}
%end
