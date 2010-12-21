//
//  Debug.h
//  RoadKill
//
//  Created by Gerard Hickey on 12/7/10.
//  Copyright 2010 Seattle RoadKill Team. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef DEBUG

    #ifndef DEBUG_CONTROLS
        #define DEBUG_CONTROLS 1
    
        /*********************************************************
            The following defines control turning on and off
            of debugging statements. This allows debugging 
            to be turned on for specific modules without 
            having to see all the debugging statements from
            all the different modules. 
        *********************************************************/
    
        #define  CALLS                    1
        #define  MESG                     0
    
    
        #define UI                        0
    
    
    
    
    
        /* debugging statements */
        #define DLOG(cntl,args...)   if (cntl == 1) { RKLog(args) } 
        #define DLogMethod(cntl)     if (cntl == 1) { LogMethod() }
    
    #endif


#else  

    #define DLOG(cntl,args...)
    #define DLogMethod(cntl)

#endif
