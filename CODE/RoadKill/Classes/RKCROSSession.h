//
//  RKCROSSession.h
//  RoadKill
//
//  Created by Hal Mueller on 10/4/10.
//
// encapsulate the credentials for a session with the CROS server

#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"

@class Observation;
@class ASIHTTPRequest;

@interface RKCROSSession : NSObject <ASIHTTPRequestDelegate> {
	Observation *observation;
	ASIHTTPRequest *asiHTTPRequest;
	NSUInteger sessionState;
	NSString *formToken;
	NSString *username;
	NSString *password;
	BOOL isAynchronous;
}

typedef enum {
	RKCROSSessionConnecting = 0,
	RKCROSSessionAuthenticated,
	RKCROSSessionFormTokenObtained,
	RKCROSSessionObservationSubmitted,
	RKCROSSessionObservationComplete
	
} RKCROSSessionState;

@property (nonatomic, retain) Observation *observation;
@property (nonatomic, retain) ASIHTTPRequest *asiHTTPRequest;
@property (nonatomic) NSUInteger sessionState;
@property (nonatomic, retain) NSString *formToken;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic) BOOL isAsynchronous;

extern NSString *RKCROSSessionSucceededNotification;
extern NSString *RKCROSSessionFailedNotification;


- (BOOL)beginTransactionAsynchronously:(BOOL)async;
+ (RKCROSSession *)submissionForObservation:(Observation *)report
							   withUsername:(NSString *)username
							   password:(NSString *)password
									  start:(BOOL)startNow;
- (void)startAsynchronously;
- (void)startSynchronously;
- (void)cancel;
+ (ASIHTTPRequest *)authenticationRequestWithUsername:(NSString *)username password:(NSString *)password;

@end
