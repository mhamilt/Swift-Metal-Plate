//
//  FDPlateCBridge.hpp
//  Hello Metal
//
//  Created by mhamilt7 on 11/03/2021.
//  Copyright © 2021 Passback Systems. All rights reserved.
//

#ifndef FDPlateCBridge_hpp
#define FDPlateCBridge_hpp

#ifdef __cplusplus
extern "C" {
#endif
const void* makePlate();

int     getGridSize     (void* globalPlate);
float*  getCurrentState (void* globalPlate);
void    updateScheme    (void* globalPlate);
void    destructPlate   (void* globalPlate);

void    bridgetest();
#ifdef __cplusplus
}
#endif

#endif /* FDPlateCBridge_hpp */
