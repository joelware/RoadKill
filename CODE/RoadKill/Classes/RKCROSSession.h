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
@property (nonatomic) BOOL isAsynchronous;

+ (ASIHTTPRequest *)authenticationRequestWithUsername:(NSString *)username password:(NSString *)password;
- (void)authenticateWithUsername:(NSString *)username password:(NSString *)password;
- (ASIHTTPRequest *)formTokenRequest;
- (void)obtainFormToken;
+ (NSURL *)baseURLForWildlifeServer;
- (BOOL)extractFormTokenFromReceivedString;
- (BOOL)receivedStringShowsSuccessfulSubmission;
- (NSString *)observationIDFromResponseHeaders:(NSDictionary *)headers;
- (BOOL)submitObservationReport:(Observation *)report
				 asynchronously:(BOOL)async;

- (BOOL)receivedStringShowsSuccessfulSubmission;
@end
