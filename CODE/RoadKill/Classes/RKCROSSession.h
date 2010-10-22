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
	NSURLConnection *connection;
	ASIHTTPRequest *asiHTTPRequest;
	NSUInteger sessionState;
	NSMutableData *receivedData;
	NSString *receivedString;
	NSString *formToken;
}

typedef enum {
	RKCROSSessionConnecting = 0,
	RKCROSSessionAuthenticated,
	RKCROSSessionFormTokenObtained,
	RKCROSSessionObservationSubmitted,
	RKCROSSessionObservationComplete
	
} RKCROSSessionState;

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) ASIHTTPRequest *asiHTTPRequest;
@property (nonatomic) NSUInteger sessionState;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSString *receivedString;
@property (nonatomic, retain) NSString *formToken;

+ (ASIHTTPRequest *)authenticationRequestWithUsername:(NSString *)username password:(NSString *)password;
- (void)authenticateWithUsername:(NSString *)username password:(NSString *)password;
- (ASIHTTPRequest *)formTokenRequest;
- (void)obtainFormToken;
+ (NSURL *)baseURLForWildlifeServer;
- (BOOL)extractFormTokenFromReceivedString;
- (BOOL)submitObservationReport:(Observation *)report;

- (BOOL)receivedStringShowsSuccessfulSubmission;
@end
