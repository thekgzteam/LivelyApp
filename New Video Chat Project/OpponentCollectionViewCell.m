//
//  OpponentCollectionViewCell.m
//  
//
//  Created by Edil Ashimov on 12/2/15.
//
//

#import "OpponentCollectionViewCell.h"

@interface OpponentCollectionViewCell ()

//@property (strong, nonatomic) UITapGestureRecognizer *doubleTapGestureRecognizer;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation OpponentCollectionViewCell

- (void)setVideoView:(UIView *)videoView {

    if (_videoView != videoView) {

        [_videoView removeFromSuperview];
        _videoView = videoView;
        _videoView.frame = self.bounds;
        [self.containerView insertSubview:self.videoView atIndex:0];
    }
}

- (void)layoutSubviews {

    [super layoutSubviews];

    if (CGRectEqualToRect(_videoView.bounds, self.bounds)) {

        return;
    }
    _videoView.frame = self.bounds;
}

//- (void)setConnectionState:(QBRTCConnectionState)connectionState {
//
//    if (_connectionState != connectionState) {
//        _connectionState = connectionState;
//
//        switch (connectionState) {
//
//            case QBRTCConnectionNew:
//
//                break;
//
//            case QBRTCConnectionPending:
//                //                [self.activityIndicator stopAnimating];
//
//                break;
//
//            case QBRTCConnectionChecking:
//
//                //                [self.activityIndicator startAnimating];
//
//                break;
//
//            case QBRTCConnectionConnecting:
//
//                //                [self.activityIndicator startAnimating];
//
//                break;
//
//            case QBRTCConnectionConnected:
//
//                //                [self.activityIndicator stopAnimating];
//
//                break;
//
//            case QBRTCConnectionClosed:
//
//                //                [self.activityIndicator stopAnimating];
//
//                break;
//
//            case QBRTCConnectionHangUp:
//
//                //                [self.activityIndicator stopAnimating];
//
//                break;
//
//            case QBRTCConnectionRejected:
//
//                //                [self.activityIndicator stopAnimating];
//
//                break;
//
//            case QBRTCConnectionNoAnswer:
//
//                //                [self.activityIndicator stopAnimating];
//
//                break;
//
//            case QBRTCConnectionDisconnectTimeout:
//
//                //                [self.activityIndicator stopAnimating];
//
//                break;
//
//            case QBRTCConnectionDisconnected:
//
//                //                [self.activityIndicator startAnimating];
//                
//                break;
//            default:
//                break;
//        }
//    }
//}
@end
