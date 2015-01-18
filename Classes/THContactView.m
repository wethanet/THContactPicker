//
//  THContactView.m
//  ContactPicker
//
//  Created by Tristan Himmelman on 11/2/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import "THContactView.h"
#import "THContactTextField.h"

@interface THContactView ()<THContactTextFieldDelegate>

@end

@implementation THContactView

#define kHorizontalPadding 10
#define kVerticalPadding 5

#define kDefaultBorderWidth 3
#define kDefaultCornerRadiusFactor 0

#define kColorText [UIColor whiteColor]
#define kColorGradientTop [UIColor colorWithRed:56.0/255.0 green:217.0/255.0 blue:195.0/255.0 alpha:1.0]
#define kColorGradientBottom [UIColor colorWithRed:56.0/255.0 green:217.0/255.0 blue:195.0/255.0 alpha:1.0]
#define kColorBorder [UIColor whiteColor]

#define kColorSelectedText [UIColor whiteColor]
#define kColorSelectedGradientTop [UIColor colorWithRed:46.0/255.0 green:208.0/255.0 blue:105.0/255.0 alpha:1.0]
#define kColorSelectedGradientBottom [UIColor colorWithRed:46.0/255.0 green:208.0/255.0 blue:105.0/255.0 alpha:1.0]
#define kColorSelectedBorder [UIColor whiteColor]

#define k7DefaultBorderWidth 3
#define k7DefaultCornerRadiusFactor 0

#define k7ColorText [UIColor whiteColor]
#define k7ColorGradientTop  [UIColor colorWithRed:56.0/255.0 green:217.0/255.0 blue:195.0/255.0 alpha:1.0]
#define k7ColorGradientBottom  [UIColor colorWithRed:56.0/255.0 green:217.0/255.0 blue:195.0/255.0 alpha:1.0]
#define k7ColorBorder [UIColor whiteColor]

#define k7ColorSelectedText [UIColor whiteColor]
#define k7ColorSelectedGradientTop [UIColor colorWithRed:255.0/255.0 green:64.0/255.0 blue:79.0/255.0 alpha:1.0]
#define k7ColorSelectedGradientBottom [UIColor colorWithRed:255.0/255.0 green:64.0/255.0 blue:79.0/255.0 alpha:1.0]
#define k7ColorSelectedBorder [UIColor whiteColor]

- (id)initWithName:(NSString *)name {
    if ([self initWithName:name style:nil selectedStyle:nil]) {

    }
    return self;
}

- (id)initWithName:(NSString *)name style:(THContactViewStyle *)style selectedStyle:(THContactViewStyle *)selectedStyle {
    if ([self initWithName:name style:style selectedStyle:selectedStyle showComma:NO]){
        
    }
    return self;
}

- (id)initWithName:(NSString *)name style:(THContactViewStyle *)style selectedStyle:(THContactViewStyle *)selectedStyle showComma:(BOOL)showComma {
    self = [super init];
    if (self){
        self.name = name;
        self.isSelected = NO;
        self.showComma = showComma;
        
        // default styles
        if (style == nil) {
            style = [[THContactViewStyle alloc] initWithTextColor:k7ColorText
                                                 gradientTop:k7ColorGradientTop
                                              gradientBottom:k7ColorGradientBottom
                                                 borderColor:k7ColorBorder
                                                 borderWidth:k7DefaultBorderWidth
                                          cornerRadiusFactor:k7DefaultCornerRadiusFactor];
        }
        if (selectedStyle == nil) {
            selectedStyle = [[THContactViewStyle alloc] initWithTextColor:k7ColorSelectedText
                                                         gradientTop:k7ColorSelectedGradientTop
                                                      gradientBottom:k7ColorSelectedGradientBottom
                                                         borderColor:k7ColorSelectedBorder
                                                        borderWidth:k7DefaultBorderWidth
                                                  cornerRadiusFactor:k7DefaultCornerRadiusFactor];
        }
        
        self.style = style;
        self.selectedStyle = selectedStyle;
        [self setupView];
    }
    return self;
}

- (void)setupView {
    // Create Label
    self.label = [[UILabel alloc] init];
    self.label.backgroundColor = [UIColor clearColor];
    self.label.text = self.name;
    [self addSubview:self.label];

    
    self.textField = [[THContactTextField alloc] init];
	self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.delegate = self;
    self.textField.hidden = YES;
    [self addSubview:self.textField];
    
    // Create a tap gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapGesture];
    
    self.maxWidth = 2 * kHorizontalPadding;
    self.minWidth = 2 * kVerticalPadding;
    
    [self adjustSize];
    
    [self unSelect];
}

- (void)adjustSize {
    // Adjust the label frames
    [self.label sizeToFit];
    CGRect frame = self.label.frame;
    frame.origin.x = kHorizontalPadding;
    frame.origin.y = kVerticalPadding;
    
    CGFloat maxWidth = self.maxWidth - 2 * kHorizontalPadding;
    CGFloat minWidth = self.minWidth - 2 * kHorizontalPadding;
    
    if (minWidth < maxWidth) {
        if (frame.size.width < minWidth) {
            frame.size.width = minWidth;
        }else{
            if (frame.size.width > maxWidth ) {
                frame.size.width = maxWidth;
            }
        }
    }
    
    if (frame.size.height < self.minHeight) {
        frame.size.height = self.minHeight;
    }

    self.label.frame = frame;

    
    // Adjust view frame
    self.bounds = CGRectMake(0, 0, frame.size.width + 2 * kHorizontalPadding + 20, frame.size.height + 2 * kVerticalPadding);
    
    // Create gradient layer
    if (self.gradientLayer == nil){
        self.gradientLayer = [CAGradientLayer layer];
        [self.layer insertSublayer:self.gradientLayer atIndex:0];
    }
    self.gradientLayer.frame = self.bounds;

    // Round the corners
    CALayer *viewLayer = [self layer];
    viewLayer.masksToBounds = YES;
}

- (void)setFont:(UIFont *)font {
    self.label.font = font;

    [self adjustSize];
}

- (void)select {
    if ([self.delegate respondsToSelector:@selector(contactViewWasSelected:)]){
        [self.delegate contactViewWasSelected:self];
    }
    
    CALayer *viewLayer = [self layer];
    viewLayer.borderColor = self.selectedStyle.borderColor.CGColor;
    self.gradientLayer.colors = [NSArray arrayWithObjects:(id)[self.selectedStyle.gradientTop CGColor], (id)[self.selectedStyle.gradientBottom CGColor], nil];
    
    self.label.textColor = self.selectedStyle.textColor;
    self.layer.borderWidth = self.selectedStyle.borderWidth;
    if (self.selectedStyle.cornerRadiusFactor > 0) {
        self.layer.cornerRadius = self.bounds.size.height / self.selectedStyle.cornerRadiusFactor;
    } else {
        self.layer.cornerRadius = 0;
    }
    
    self.isSelected = YES;
    
    [self.textField becomeFirstResponder];
}

- (void)unSelect {
    CALayer *viewLayer = [self layer];
    viewLayer.borderColor = self.style.borderColor.CGColor;
    
    self.gradientLayer.colors = [NSArray arrayWithObjects:(id)[self.style.gradientTop CGColor], (id)[self.style.gradientBottom CGColor], nil];
    
    self.label.textColor = self.style.textColor;
    self.layer.borderWidth = self.style.borderWidth;
    if (self.style.cornerRadiusFactor > 0) {
        self.layer.cornerRadius = self.bounds.size.height / self.style.cornerRadiusFactor;
    }
    else {
        self.layer.cornerRadius = 0;
    }

    [self setNeedsDisplay];
    self.isSelected = NO;
    
    [self.textField resignFirstResponder];
}

- (void)handleTapGesture {
    if (self.isSelected){
        [self unSelect];
    } else {
        [self select];
    }
}

#pragma mark - UITextViewDelegate



- (void)textFieldDidHitBackspaceWithEmptyText:(THContactTextField *)textView {
    self.textField.hidden = NO;
    
    // Capture "delete" key press when cell is empty
    if ([self.delegate respondsToSelector:@selector(contactViewShouldBeRemoved:)]){
        [self.delegate contactViewShouldBeRemoved:self];
    }
}

- (void)textFieldDidChange:(THContactTextField *)textField{
	
    [self unSelect];
    if ([self.delegate respondsToSelector:@selector(contactViewWasUnSelected:)]){
        [self.delegate contactViewWasUnSelected:self];
    }
	self.textField.text = nil;
}

#pragma mark - UITextInputTraits

- (void)setKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance {
    self.textField.keyboardAppearance = keyboardAppearance;
}

- (UIKeyboardAppearance)keyboardAppearance {
    return self.textField.keyboardAppearance;
}

@end
