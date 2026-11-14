#import "GRVGitHubCell.h"
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIKit.h>

@implementation GRVGitHubCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];
    if (self) {
        self.textLabel.text = @"ymkeee";
        self.textLabel.font = [UIFont boldSystemFontOfSize:17];
        self.detailTextLabel.text = @"https://github.com/ymkeee";
        self.detailTextLabel.textColor = [UIColor systemGrayColor];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/ymkeee"]
                                           options:@{}
                                 completionHandler:nil];
    }
}

@end
