//
//  MessageTableViewCell.m
//  Messenger
//
//  Created by Ignacio Romero Zurbuchen on 9/1/14.
//  Copyright (c) 2014 Slack Technologies, Inc. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "SLKUIConstants.h"
#import "ECAPI.h"
#import "NSDate+NVTimeAgo.h"
#import "ECCommonClass.h"
#import "IonIcons.h"

@implementation MessageTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        // Get logged in user
        
        self.signedInUser = [[ECAPI sharedManager] signedInUser];
        // According to resuse identifier handling subviews
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ConfigureViews:) name:@"configureView" object:nil];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

-(void)ConfigureViews:(NSNotification *)notification
{
    NSString *reuseIdentifier = [notification.userInfo valueForKey:@"reuseIdentifire"];
    if ([reuseIdentifier isEqualToString:messengerMediaCellIdentifier]) {
        [self configureSubviewsForMediaCell];
    } else {
        [self configureSubviewsForChatReaction];
//        ECCommonClass *instance = [ECCommonClass sharedManager];
//        if (instance.isFromChatVC == false){
//            [self configureSubviews];
//        }else{
//            [self configureSubviewsForChatReaction];
//        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"configureView" object:nil];
}

- (void)updateConstraints {
    
    [super updateConstraints];
    // Added constraint for download button
    
    if ([self.reuseIdentifier isEqualToString:messengerMediaCellIdentifier])
    {
        NSLayoutConstraint *downloadButtonCenterX = [NSLayoutConstraint constraintWithItem:self.mediaImageView
                                                                                 attribute:NSLayoutAttributeCenterX
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self.downloadButton
                                                                                 attribute:NSLayoutAttributeCenterX
                                                                                multiplier:1
                                                                                  constant:0];
        
        
        
        NSLayoutConstraint *downloadButtonWidth = [NSLayoutConstraint constraintWithItem:self.downloadButton
                                                                               attribute:NSLayoutAttributeWidth
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:nil
                                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                                              multiplier:1
                                                                                constant:50];
        
        NSLayoutConstraint *downloadButtonHeight = [NSLayoutConstraint constraintWithItem:self.downloadButton
                                                                                attribute:NSLayoutAttributeHeight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:nil
                                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                                               multiplier:1
                                                                                 constant:50];
        
        
        NSLayoutConstraint *downloadButtonCenterY = [NSLayoutConstraint constraintWithItem:self.mediaImageView
                                                                                 attribute:NSLayoutAttributeCenterY
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self.downloadButton
                                                                                 attribute:NSLayoutAttributeCenterY
                                                                                multiplier:1
                                                                                  constant:0];
        [NSLayoutConstraint activateConstraints:@[downloadButtonCenterX, downloadButtonCenterY, downloadButtonWidth, downloadButtonHeight]];
    }
}

-(void)adjustConstraint
{
    NSLayoutConstraint *downloadButtonCenterX = [NSLayoutConstraint constraintWithItem:self.mediaImageView
                                                                             attribute:NSLayoutAttributeCenterX
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.downloadButton
                                                                             attribute:NSLayoutAttributeCenterX
                                                                            multiplier:1
                                                                              constant:0];
    
    
    
    NSLayoutConstraint *downloadButtonWidth = [NSLayoutConstraint constraintWithItem:self.downloadButton
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1
                                                                            constant:50];
    
    NSLayoutConstraint *downloadButtonHeight = [NSLayoutConstraint constraintWithItem:self.downloadButton
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                           multiplier:1
                                                                             constant:50];
    
    
    NSLayoutConstraint *downloadButtonCenterY = [NSLayoutConstraint constraintWithItem:self.mediaImageView
                                                                             attribute:NSLayoutAttributeCenterY
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.downloadButton
                                                                             attribute:NSLayoutAttributeCenterY
                                                                            multiplier:1
                                                                              constant:0];
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSLayoutConstraint activateConstraints:@[downloadButtonCenterX, downloadButtonCenterY, downloadButtonWidth, downloadButtonHeight]];
    });
    
}

- (void)configureSubviews
{
    // Handle touchUpInside event for Like label
    self.likeCountLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *likeLabelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLikeComment:)];
    [self.likeCountLabel addGestureRecognizer:likeLabelTapGesture];
    
    //Handle touchUpInside event for reply label
    self.replyLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *replyLabelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapReplyComment:)];
    [self.replyLabel addGestureRecognizer:replyLabelTapGesture];
    
    //Handle touchUpInside event for report label
    self.reportLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *reportLabelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapHideAllCommentsByUser:)];
    [self.reportLabel addGestureRecognizer:reportLabelTapGesture];
    
    NSDictionary *metrics;
    // Disable like button if user has already liked the comment
    if([self.signedInUser.likedCommentIds containsObject:_message.commentId]){
        [self.likeCountLabel setEnabled:NO];
    }
    if (![_message.parantId isEqualToString:@"0"]) {
        [self.replyLabel setHidden:YES];
        metrics = @{@"tumbSize": @(kMessageTableViewCellAvatarHeight),
                    @"padding": @15,
                    @"right": @10,
                    @"left": @45
                    };
    }
    else
    {
        [self.replyLabel setHidden:NO];
        metrics = @{@"tumbSize": @(kMessageTableViewCellAvatarHeight),
                    @"padding": @15,
                    @"right": @10,
                    @"left": @5
                    };
    }
    
    [self.contentView addSubview:self.thumbnailView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.bodyLabel];
    [self.contentView addSubview:self.likeCountLabel];
    [self.contentView addSubview:self.reportLabel];
    [self.contentView addSubview:self.replyLabel];
    
    NSDictionary *views = @{@"thumbnailView": self.thumbnailView,
                            @"titleLabel": self.titleLabel,
                            @"bodyLabel": self.bodyLabel,
                            @"likeCountLabel": self.likeCountLabel,
                            @"reportLabel"   : self.reportLabel,
                            @"replyLabel"    : self.replyLabel
                            };
    
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[thumbnailView(tumbSize)]-right-[titleLabel(>=0)]-right-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[thumbnailView(tumbSize)]-right-[bodyLabel(>=0)]-right-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[thumbnailView(tumbSize)]-right-[likeCountLabel(>=0)]-right-[replyLabel(50)]-right-[reportLabel(50)]-(>=0)-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-right-[thumbnailView(tumbSize)]-(>=0)-|" options:0 metrics:metrics views:views]];
    
    if ([self.reuseIdentifier isEqualToString:MessengerCellIdentifier]) {
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-right-[titleLabel(20)]-(5)-[bodyLabel(>=0@999)]-(5)-[likeCountLabel(20)]-|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-right-[titleLabel(20)]-(5)-[likeCountLabel(20)]-(5)-[reportLabel(20)]-|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-right-[titleLabel(20)]-(5)-[reportLabel(20)]-(5)-[replyLabel(20)]-|" options:0 metrics:metrics views:views]];
    }
    else {
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleLabel]|" options:0 metrics:metrics views:views]];
    }
}

- (void)configureNewCell {
    // Handle touchUpInside event for Like label
    self.likeCountLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *likeLabelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLikeComment:)];
    [self.likeCountLabel addGestureRecognizer:likeLabelTapGesture];
    
    //Handle touchUpInside event for reply label
    self.replyLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *replyLabelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapReplyComment:)];
    [self.replyLabel addGestureRecognizer:replyLabelTapGesture];
    
    //Handle touchUpInside event for report label
    self.reportLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *reportLabelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapHideAllCommentsByUser:)];
    [self.reportLabel addGestureRecognizer:reportLabelTapGesture];
    
    //Handle touchUpInside event for viewReply label
    self.viewReplyLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *viewReplyLabelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapViewReplyByUser:)];
    [self.viewReplyLabel addGestureRecognizer:viewReplyLabelTapGesture];
    
    NSDictionary *metrics;
    // Disable like button if user has already liked the comment
    if([self.signedInUser.likedCommentIds containsObject:_message.commentId]){
        [self.likeCountLabel setEnabled:NO];
    }
    
    if (![_message.parantId isEqualToString:@"0"]) {
        //Child
        [self.replyLabel setHidden:YES];
        [self.viewReplyLabel setHidden:YES];
        metrics = @{@"tumbSize": @(kMessageTableViewCellAvatarHeight),
                    @"padding": @15,
                    @"right": @10,
                    @"left": @45
                    };
    }
    else{
        //This is parent
        [self.replyLabel setHidden:NO];
        [self.viewReplyLabel setHidden:NO];
        metrics = @{@"tumbSize": @(kMessageTableViewCellAvatarHeight),
                    @"padding": @15,
                    @"right": @10,
                    @"left": @5
                    };
    }
    
    [self.contentView addSubview:self.thumbnailView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.bodyLabel];
    [self.contentView addSubview:self.likeCountLabel];
    [self.contentView addSubview:self.reportLabel];
    [self.contentView addSubview:self.replyLabel];
    [self.contentView addSubview:self.favImageView];
    [self.contentView addSubview:self.viewReplyLabel];
    
    NSDictionary *views = @{@"thumbnailView": self.thumbnailView,
                            @"titleLabel": self.titleLabel,
                            @"bodyLabel": self.bodyLabel,
                            @"likeCountLabel": self.likeCountLabel,
                            @"reportLabel"   : self.reportLabel,
                            @"replyLabel"    : self.replyLabel,
                            @"favImageView"    : self.favImageView,
                            @"viewReplyLabel"    : self.viewReplyLabel
                            };
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[thumbnailView(tumbSize)]-right-[titleLabel(>=0)]-right-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[thumbnailView(tumbSize)]-right-[bodyLabel(>=0)]-right-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[thumbnailView(tumbSize)]-right-[likeCountLabel(>=0)]-right-[replyLabel(50)]" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[thumbnailView(tumbSize)]-right-[viewReplyLabel(>=0)]-right-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-right-[thumbnailView(tumbSize)]-(>=0)-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-right-[favImageView(tumbSize)]-(>=0)-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[favImageView(tumbSize)]-right-|" options:0 metrics:metrics views:views]];
    
    if ([self.reuseIdentifier isEqualToString:MessengerCellIdentifier]) {
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-right-[titleLabel(20)]-(5)-[bodyLabel(>=0@999)]-(5)-[likeCountLabel(20)]-(10)-[viewReplyLabel(20)]" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-right-[titleLabel(20)]-(5)-[bodyLabel(20)]-(5)-[replyLabel(20)]" options:0 metrics:metrics views:views]];
    }
    else {
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleLabel]|" options:0 metrics:metrics views:views]];
    }
    [self layoutIfNeeded];
}

- (void)configureSubviewsForChatReaction
{
    NSLog(@"message.parantId: %@", _message.parantId);
    
    // check parent commentID with child parentID
    ECCommonClass *instance = [ECCommonClass sharedManager];
    
    if ([_message.parantId isEqualToString:@"0"]){
        [self configureNewCell];
        
    }else{
        if (instance.isFromChatVC == false){
            if ([instance.parentCommentIDArray containsObject:_message.parantId]){
                [self configureNewCell];
            }else{
                NSLog(@"Hide cell...!");
            }
        }else{
            if ([instance.parentCommentIDs containsObject:_message.parantId]){
                [self configureNewCell];
            }else{
                NSLog(@"Hide cell...!");
            }
        }
    }
}

- (void)configureSubviewsForMediaCell{
    // Handle touchUpInside event for Like label
    self.likeCountLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *likeLabelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLikeComment:)];
    [self.likeCountLabel addGestureRecognizer:likeLabelTapGesture];
    
    //Handle touchUpInside event for reply label
    self.replyLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *replyLabelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapReplyComment:)];
    [self.replyLabel addGestureRecognizer:replyLabelTapGesture];
    
    //Handle touchUpInside event for report label
    self.reportLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *reportLabelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapHideAllCommentsByUser:)];
    [self.reportLabel addGestureRecognizer:reportLabelTapGesture];
    
    NSDictionary *metrics;
    // Disable like button if user has already liked the comment
    if([self.signedInUser.likedCommentIds containsObject:_message.commentId]){
        [self.likeCountLabel setEnabled:NO];
    }
    
    if (![_message.parantId isEqualToString:@"0"]) {
        [self.replyLabel setHidden:YES];
        metrics = @{@"tumbSize": @(kMessageTableViewCellAvatarHeight),
                    @"padding": @15,
                    @"right": @10,
                    @"left": @45
                    };
        [super layoutSubviews];
    }
    else
    {
        [self.replyLabel setHidden:NO];
        metrics = @{@"tumbSize": @(kMessageTableViewCellAvatarHeight),
                    @"padding": @15,
                    @"right": @10,
                    @"left": @5
                    };
        [super layoutSubviews];
    }
    
    [self.contentView addSubview:self.thumbnailView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.mediaImageView];
    [self.contentView addSubview:self.likeCountLabel];
    [self.contentView addSubview:self.downloadButton];
    [self.contentView addSubview:self.indicator];
    [self.contentView bringSubviewToFront:self.indicator];
    [self.contentView addSubview:self.reportLabel];
    [self.contentView addSubview:self.replyLabel];
    
    NSDictionary *views = @{@"thumbnailView": self.thumbnailView,
                            @"titleLabel": self.titleLabel,
                            @"mediaImage": self.mediaImageView,
                            @"likeCountLabel": self.likeCountLabel,
                            @"reportLabel"   : self.reportLabel,
                            @"replyLabel"    : self.replyLabel
                            };
    
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[thumbnailView(tumbSize)]-right-[titleLabel(>=0)]-right-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[thumbnailView(tumbSize)]-right-[mediaImage(250)]" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[thumbnailView(tumbSize)]-right-[likeCountLabel(>=0)]-right-[replyLabel(50)]-right-[reportLabel(50)]-(>=0)-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-right-[thumbnailView(tumbSize)]-(>=0)-|" options:0 metrics:metrics views:views]];
    
    if ([self.reuseIdentifier isEqualToString:messengerMediaCellIdentifier]) {
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-right-[titleLabel(20)]-left-[mediaImage(250)]-20-[likeCountLabel(20)]-|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-right-[titleLabel(35)]-left-[mediaImage(250)]-20-[reportLabel(20)]-|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-right-[titleLabel(50)]-left-[mediaImage(250)]-20-[replyLabel(20)]-|" options:0 metrics:metrics views:views]];
    }
    else {
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleLabel]|" options:0 metrics:metrics views:views]];
    }
    [self adjustConstraint];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.mediaImageView.image = NULL;
    CGFloat pointSize = [MessageTableViewCell smallFontSize];
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize:pointSize];
    self.bodyLabel.font = [UIFont systemFontOfSize:pointSize];
    self.likeCountLabel.font = [UIFont systemFontOfSize:pointSize];
    self.viewReplyLabel.font = [UIFont systemFontOfSize:pointSize];
    
    self.titleLabel.text = @"";
    self.bodyLabel.text = @"";
    self.likeCountLabel.text = @"";
    self.viewReplyLabel.text = @"ViewReply";
}

#pragma mark - Getters
- (UILabel *)bodyLabel {
    if (!_bodyLabel) {
        _bodyLabel = [UILabel new];
        _bodyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _bodyLabel.backgroundColor = [UIColor clearColor];
        _bodyLabel.userInteractionEnabled = NO;
        _bodyLabel.numberOfLines = 0;
        _bodyLabel.textColor = [UIColor darkGrayColor];
        _bodyLabel.font = [UIFont systemFontOfSize:[MessageTableViewCell smallFontSize]];
    }
    return _bodyLabel;
}

- (UIActivityIndicatorView *)indicator {
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.color = [UIColor colorWithRed:171.0/255.0 green:57.0/255.0 blue:158.0/255.0 alpha:1.0];
        [_indicator setCenter:self.mediaImageView.center];
    }
    return _indicator;
}

-(UIButton *)downloadButton{
    if (!_downloadButton){
        _downloadButton = [UIButton new];
        _downloadButton.translatesAutoresizingMaskIntoConstraints = NO;
        _downloadButton.backgroundColor = [UIColor clearColor];
        //        if ([_message.commentType isEqualToString:@"image"]) {
        //            [_downloadButton setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
        [_downloadButton addTarget:self
                            action:@selector(downloadButtonClicked:)
                  forControlEvents:UIControlEventTouchUpInside];
        //
        //        }
        //        else
        //        {
        //            [_downloadButton setBackgroundImage:[UIImage imageNamed:@"play-button"] forState:UIControlStateNormal];
        //            [_downloadButton setImage:[UIImage imageNamed:@"play-button"] forState:UIControlStateNormal];
        
        //        }
    }
    
    return _downloadButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.userInteractionEnabled = NO;
        _titleLabel.numberOfLines = 0;
        _titleLabel.textColor = [UIColor grayColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:[MessageTableViewCell smallFontSize]];
    }
    return _titleLabel;
}

- (UILabel *)likeCountLabel {
    if (!_likeCountLabel) {
        _likeCountLabel = [UILabel new];
        _likeCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _likeCountLabel.backgroundColor = [UIColor clearColor];
        _likeCountLabel.userInteractionEnabled = NO;
        _likeCountLabel.numberOfLines = 0;
        _likeCountLabel.textColor = [UIColor blueColor];
        _likeCountLabel.font = [UIFont systemFontOfSize:[MessageTableViewCell smallFontSize]];
    }
    return _likeCountLabel;
}

- (UILabel *)reportLabel {
    if (!_reportLabel) {
        _reportLabel = [UILabel new];
        _reportLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _reportLabel.backgroundColor = [UIColor clearColor];
        _reportLabel.userInteractionEnabled = NO;
        _reportLabel.numberOfLines = 0;
        _reportLabel.textColor = [UIColor blueColor];
        _reportLabel.font = [UIFont systemFontOfSize:[MessageTableViewCell smallFontSize]];
    }
    return _reportLabel;
}

- (UILabel *)replyLabel {
    if (!_replyLabel) {
        _replyLabel = [UILabel new];
        _replyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _replyLabel.backgroundColor = [UIColor clearColor];
        _replyLabel.userInteractionEnabled = NO;
        _replyLabel.numberOfLines = 0;
        _replyLabel.textColor = [UIColor blueColor];
        _replyLabel.font = [UIFont systemFontOfSize:[MessageTableViewCell smallFontSize]];
    }
    return _replyLabel;
}

- (UILabel *)viewReplyLabel {
    if (!_viewReplyLabel) {
        _viewReplyLabel = [UILabel new];
        _viewReplyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _viewReplyLabel.backgroundColor = [UIColor clearColor];
        _viewReplyLabel.userInteractionEnabled = NO;
        _viewReplyLabel.numberOfLines = 0;
        _viewReplyLabel.textColor = [UIColor blueColor];
        _viewReplyLabel.font = [UIFont systemFontOfSize:[MessageTableViewCell smallFontSize]];
    }
    return _viewReplyLabel;
}

- (UIImageView *)thumbnailView {
    if (!_thumbnailView) {
        _thumbnailView = [UIImageView new];
        _thumbnailView.translatesAutoresizingMaskIntoConstraints = NO;
        _thumbnailView.userInteractionEnabled = NO;
        _thumbnailView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        
        _thumbnailView.layer.cornerRadius = kMessageTableViewCellAvatarHeight/2.0;
        _thumbnailView.layer.masksToBounds = YES;
    }
    return _thumbnailView;
}

- (UIImageView *)favImageView {
    if (!_favImageView) {
        _favImageView = [UIImageView new];
        _favImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _favImageView.userInteractionEnabled = NO;
        //        _favImageView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        [self.favImageView setImage:[IonIcons imageWithIcon:ion_ios_heart  size:30.0 color:[UIColor redColor]]];
        _favImageView.layer.cornerRadius = kMessageTableViewCellAvatarHeight/2.0;
        _favImageView.layer.masksToBounds = YES;
    }
    return _favImageView;
}

- (UIImageView *)mediaImageView {
    if (!_mediaImageView) {
        _mediaImageView = [UIImageView new];
        _mediaImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _mediaImageView.backgroundColor = [UIColor clearColor];
        _mediaImageView.contentMode = UIViewContentModeScaleAspectFill;
        _mediaImageView.layer.cornerRadius = 5.0;
        _mediaImageView.clipsToBounds = YES;
        _mediaImageView.layer.borderWidth = 1.0;
        _mediaImageView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor lightGrayColor]);
    }
    return _mediaImageView;
}

+ (CGFloat)defaultFontSize {
    CGFloat pointSize = 16.0;
    
    NSString *contentSizeCategory = [[UIApplication sharedApplication] preferredContentSizeCategory];
    pointSize += SLKPointSizeDifferenceForCategory(contentSizeCategory);
    
    return pointSize;
}

+ (CGFloat)smallFontSize {
    CGFloat pointSize = 12.0;
    
    NSString *contentSizeCategory = [[UIApplication sharedApplication] preferredContentSizeCategory];
    pointSize += SLKPointSizeDifferenceForCategory(contentSizeCategory);
    
    return pointSize;
}

#pragma mark - MessageTableViewCellDelegate Methods
-(void)didTapLikeComment:(id)sender{
    NSLog(@"MessageTableViewCell - CommentId: %@ - UserId: %@", _message.commentId, self.signedInUser.userId);
    
    [[ECAPI sharedManager] likeComment:_message.commentId userId:self.signedInUser.userId callback:^(NSDictionary *jsonDictionary,NSError *error) {
        if (error) {
            NSLog(@"Error adding user: %@", error);
        } else {
            // Format date
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
            NSDate *created_atFromString = [[NSDate alloc] init];
            created_atFromString = [dateFormatter dateFromString:_message.created_at];
            NSString *ago = [created_atFromString formattedAsTimeAgo];
            NSInteger newLikeCount = [_message.likeCount intValue];
            self.likeCountLabel.textColor = [UIColor lightGrayColor];
            
            ECCommonClass *instance = [ECCommonClass sharedManager];
            if (instance.isFromChatVC == false){
                self.likeCountLabel.text = [NSString stringWithFormat:@"%@ \u2022 Liked \u2022 %@", ago, [NSString stringWithFormat:@"%ld", (long)newLikeCount + 1]];
            }else{
                self.likeCountLabel.text = [NSString stringWithFormat:@"%@, %@ Liked", ago, [NSString stringWithFormat:@"%ld", (long)newLikeCount + 1]];
                //                DCChatReactionViewController *dc = [DCChatReactionViewController new];
                //                [dc.chatTableView reloadData];
            }
        }
    }];
}


-(void)didTapReportComment:(id)sender {
    NSLog(@"Report Tapped");
    NSLog(@"CommentId: %@ - UserId: %@", _message.commentId, self.signedInUser.userId);
    [[ECAPI sharedManager] reportComment:_message.commentId userId:self.signedInUser.userId callback:^(NSDictionary *jsonDictionarty, NSError *error){
        
        if (error) {
            NSLog(@"Error adding user: %@", error);
            NSLog(@"%@", error);
        } else {
            [[ECCommonClass sharedManager] alertViewTitle:@"SUCCESS" message:@"Comment reported successfully"];
            NSLog(@"%@",jsonDictionarty);
        }
    }];
}

-(void)didTapHideAllCommentsByUser:(id)sender {
    NSLog(@"Report Tapped");
    NSLog(@"CommentId: %@ - UserId: %@", _message.commentId, self.signedInUser.userId);
    if ([self.delegate respondsToSelector:@selector(hideAllCommentsByUser:)]) {
        [[self delegate] hideAllCommentsByUser:self.message];
    }
}

-(void)didTapDeleteCommentByUser:(id)sender {
    NSLog(@"Report Tapped");
    NSLog(@"CommentId: %@ - UserId: %@", _message.commentId, self.signedInUser.userId);
    if ([self.delegate respondsToSelector:@selector(hideAllCommentsByUser:)]) {
        [[self delegate] hideAllCommentsByUser:self.message];
    }
}

-(void)didTapReplyComment:(id)sender {
    //Storing values to display in replyview.
    [[NSUserDefaults standardUserDefaults] setValue:_message.commentId forKey:@"parantId"];
    [[NSUserDefaults standardUserDefaults] setValue:self.message.user.firstName forKey:@"userName"];
    //Firing notificattion to SLKTextviewViewController for presant reply view.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"replyComment" object:nil];
}

-(void)didTapViewReplyByUser:(id)sender {
    NSLog(@"CommentId: %@ - UserId: %@", _message.commentId, self.signedInUser.userId);
    [[NSUserDefaults standardUserDefaults] setValue:_message.commentId forKey:@"commentIdForChat"];
    
    ECCommonClass *instance = [ECCommonClass sharedManager];
    
    if (instance.isFromChatVC == false){
        if(instance.parentCommentIDArray == nil){
            instance.parentCommentIDArray = [[NSMutableArray alloc] init];
        }
        if ([instance.parentCommentIDArray containsObject:_message.commentId]){
            [instance.parentCommentIDArray removeObject:_message.commentId];
        }else{
            [instance.parentCommentIDArray addObject:_message.commentId];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"viewReplyNewTap" object:nil];
    
    }else{
        if(instance.parentCommentIDs == nil){
            instance.parentCommentIDs = [[NSMutableArray alloc] init];
        }
        if ([instance.parentCommentIDs containsObject:_message.commentId]){
            [instance.parentCommentIDs removeObject:_message.commentId];
        }else{
            [instance.parentCommentIDs addObject:_message.commentId];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"viewReplyTap" object:nil];
    }
}

-(void)downloadButtonClicked:(UIButton *)sender{
    if ([_message.commentType isEqualToString:@"image"]) {
        if ([self.delegate respondsToSelector:@selector(downloadButtonClickedForImage:forCell:)]) {
            [[self delegate] downloadButtonClickedForImage:[sender tag] forCell:self];
        }
    }
    else{
        if ([self.delegate respondsToSelector:@selector(playButtonPressed:)]) {
            [[self delegate] playButtonPressed:self.message];
        }
    }
}
@end
