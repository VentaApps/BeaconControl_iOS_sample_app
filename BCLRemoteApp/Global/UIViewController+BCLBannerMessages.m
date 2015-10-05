//
//  UIViewController+BCLValidationErrors.m
//  BCLRemoteApp
//
// Copyright (c) 2015, Upnext Technologies Sp. z o.o.
// All rights reserved.
//
// This source code is licensed under the BSD 3-Clause License found in the
// LICENSE.txt file in the root directory of this source tree.
//

#import <objc/runtime.h>
#import "UIViewController+BCLBannerMessages.h"
#import "UIColor+BCLAppColors.h"

static char validationErrorViewKey;
static char topConstraintKey;
static char errorLabelKey;

@implementation UIViewController (BCLValidationErrors)

- (void)presentValidationError:(NSString *)errorMessage completion:(void(^)(BOOL))completion
{
    if (self.bannerView) {
        self.bannerViewLabel.text = errorMessage;
        [self showBannerViewAnimated:YES duration:@(2.0) completion:nil];
    }
}

- (void)presentMessage:(NSString *)message animated:(BOOL)animated warning:(BOOL)isWarning completion:(void (^)(BOOL))completion
{
    if (self.bannerView) {
        [self hideBannerView:NO];
        self.bannerViewLabel.text = message;
        self.bannerView.backgroundColor = isWarning ? [UIColor redAppColor] : [UIColor greenAppColor];
        [self showBannerViewAnimated:animated duration:nil completion:nil];
    }
}

- (void)showBannerViewAnimated:(BOOL)animated duration:(NSNumber *)duration completion:(void(^)(BOOL))completion
{
    __weak typeof(self) weakSelf = self;
    
    void (^finalCompletion)(BOOL finished) = ^void(BOOL finished) {
        if (completion) {
            completion(finished);
        }
        
        if (duration) {
            [weakSelf performSelector:@selector(hideAnimation:) withObject:completion afterDelay:duration.floatValue];
        }
    };
    
    self.bannerView.hidden = NO;
    [UIView animateWithDuration:animated?0.5:0.0 animations:^{
        self.bannerViewTopConstraint.constant = 0.0;
        [self.view layoutIfNeeded];
    } completion:finalCompletion];
}

- (void)hideBannerViewAnimated:(BOOL)animated completion:(void(^)(BOOL))completion
{
    if (!animated) {
        self.bannerViewTopConstraint.constant = -35;
        self.bannerView.hidden = YES;
        return;
    }

    [UIView animateWithDuration:0.5 animations:^{
        self.bannerViewTopConstraint.constant = -35;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.bannerView.hidden = YES;
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)hideBannerView:(BOOL)animated
{
    [self hideBannerViewAnimated:animated completion:nil];
}

- (void)hideAnimation:(void(^)(BOOL))completion
{
    [self hideBannerViewAnimated:YES completion:completion];
}

- (UIView *)bannerView
{
    UIView *validationErrorView = objc_getAssociatedObject(self, &validationErrorViewKey);
    if (!validationErrorView) {
        validationErrorView = [[UIView alloc] initWithFrame:CGRectZero];
        validationErrorView.backgroundColor = [UIColor redAppColor];
        validationErrorView.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = NSDictionaryOfVariableBindings(validationErrorView);
        [self.view addSubview:validationErrorView];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[validationErrorView]|" options:0 metrics:nil views:views]];
        NSLayoutConstraint *topConstraint =  [NSLayoutConstraint constraintWithItem:validationErrorView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.topLayoutGuide
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1.0
                                      constant:-35];
        [self.view addConstraint:topConstraint];

        [validationErrorView addConstraint:[NSLayoutConstraint constraintWithItem:validationErrorView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:35.0]];



        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.textColor = [UIColor whiteColor];
        [validationErrorView addSubview:label];
        [validationErrorView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                        attribute:NSLayoutAttributeCenterY
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:validationErrorView
                                                                        attribute:NSLayoutAttributeCenterY
                                                                       multiplier:1.0
                                                                         constant:0.0]];
        views = NSDictionaryOfVariableBindings(label);
        [validationErrorView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(25)-[label]-(25)-|" options:0 metrics:nil views:views]];


        objc_setAssociatedObject(self, &errorLabelKey, label, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, &validationErrorViewKey, validationErrorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, &topConstraintKey, topConstraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self.view layoutIfNeeded];
    }

    return validationErrorView;
}

- (NSLayoutConstraint *)bannerViewTopConstraint
{
    return objc_getAssociatedObject(self, &topConstraintKey);
}

- (UILabel *)bannerViewLabel
{
    return objc_getAssociatedObject(self, &errorLabelKey);
}



@end
