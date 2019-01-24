//
//  AddToPlaylistPopUpViewController.m
//  EventChat
//
//  Created by Mindbowser on 21/01/19.
//  Copyright © 2019 Jigish Belani. All rights reserved.
//

#import "AddToPlaylistPopUpViewController.h"
#import "AddToPlaylistPopUpCollectionViewCell.h"

@interface AddToPlaylistPopUpViewController ()

@end

@implementation AddToPlaylistPopUpViewController

#pragma mark - ViewController LifeCycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.8f];
    if (self.isImageSelected){
        [self.collectionPlaylistView setHidden: YES];
        [self.vwNew setHidden: NO];
        [self initialSetup];
    }else{
        [self.vwNew setHidden: YES];
        [self.collectionPlaylistView setHidden: NO];
    }
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if (newLength > 0){
        [self.cancelButton setTitle:@"Save" forState:UIControlStateNormal];
    }else{
        [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    }
//    return (newLength > 1) ? NO : YES;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - IBAction Methods

- (IBAction)actionOnPlusButton:(id)sender {
    NSLog(@"add button click...");
}

- (IBAction)actionOnButtonClick:(id)sender {
    [self removeAnimation];
}

- (IBAction)actionOnVwCancelButton:(id)sender {
    NSLog(@"Title: %@", self.cancelButton.titleLabel.text);
    if ([self.cancelButton.titleLabel.text  isEqual: @"Save"]){
        
    }else{
        
    }
    [self removeAnimation];
}

#pragma mark - CollectionView DataSource and Delegate Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 21;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AddToPlaylistPopUpCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AddToPlaylistPopUpCollectionViewCell" forIndexPath:indexPath];
    NSString *intVal = [NSString stringWithFormat:@"%ld", (long)indexPath.row + 1];
    [cell.playlistNameLabel setText:intVal];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"IndexPath.Row: %ld", (long)indexPath.row);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100, 100);
}

#pragma mark - Instance Methods

-(void)removeAnimation{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFromTop;
    transition.subtype = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.view removeFromSuperview];
    [self.view setAlpha:0.0];
    [self.playlistDelegate updateUI];
}

-(void)initialSetup{
    self.vwNew.layer.cornerRadius = 5.0;
    self.vwNew.layer.masksToBounds = YES;
    self.vwNew.layer.borderWidth = 5;
    self.vwNew.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

/*
 
 func showAnimate()
 {
 self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
 self.view.alpha = 0.0;
 UIView.animate(withDuration: 0.25, animations: {
 self.view.alpha = 1.0
 self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
 });
 }
 
 func removeAnimate()
 {
 UIView.animate(withDuration: 0.25, animations: {
 self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
 self.view.alpha = 0.0;
 }, completion:{(finished : Bool)  in
 if (finished)
 {
 self.view.removeFromSuperview()
 }
 });
 }
 
 */
 
@end
