//
//  RKCROSSession.h
//  RoadKill
//
//  Created by Hal Mueller on 10/4/10.
//

#import <Foundation/Foundation.h>

// encapsulate the credentials for a session with the CROS server
@interface RKCROSSession : NSObject {
	NSURLConnection *connection;
	NSUInteger sessionState;
	NSMutableData *receivedData;
	NSString *receivedString;
}

typedef enum {
	RKCROSSessionConnecting = 0,
	RKCROSSessionAuthenticated,
	RKCROSSessionFormTokenObtained,
	RKCROSSessionObservationSubmitted,
	RKCROSSessionObservationComplete
	
} RKCROSSessionState;

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic) NSUInteger sessionState;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSString *receivedString;

+ (NSMutableURLRequest *)authenticationRequestWithUsername:(NSString *)username password:(NSString *)password;
- (void)authenticateWithUsername:(NSString *)username password:(NSString *)password;
- (void)doSomethingWithResponse:(NSURLResponse *)response;
- (NSMutableURLRequest *)formTokenRequest;
- (void)obtainFormToken;
@end
