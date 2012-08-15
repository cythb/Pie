//
//  ViewController.m
//  Pie
//
//  Created by Haibo Tang on 12-8-14.
//  Copyright (c) 2012年 Haibo Tang. All rights reserved.
//

#import "ViewController.h"
#import "Pie.h"

@interface ViewController ()<PieDataSource>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    Pie *pie = [[Pie alloc] initWithCenter:self.view.center radius:160];
    pie.dataSource = self;
    [self.view addSubview:pie];
    [pie release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - PieDataSource
- (NSInteger)numOfPie{
    return 3;
}
- (CGFloat)persentForIndex:(NSInteger)index{
    switch (index) {
        case 0:
            return 0.2;
            break;
        case 1:
            return 0.2;
            break;
        case 2:
            return 0.6;
            break;
            
        default:
            return 0;
            break;
    }
}
- (UIColor *)colorForIndex:(NSInteger)index{
    switch (index) {
        case 0:
            return [UIColor redColor];
            break;
        case 1:
            return [UIColor blueColor];
            break;
        case 2:
            return [UIColor greenColor];
            break;
            
        default:
            return nil;
            break;
    }
}
- (NSString *)titleForIndex:(NSInteger)index{
    switch (index) {
        case 0:
            return @"A市占有率";
            break;
        case 1:
            return @"B市占有率";
            break;
        case 2:
            return @"C市占有率";
            break;
            
        default:
            return nil;
            break;
    }
}
@end
