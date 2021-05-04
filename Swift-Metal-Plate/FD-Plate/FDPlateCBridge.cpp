//
//  FDPlateCBridge.cpp
//  Hello Metal
//
//  Created by mhamilt7 on 11/03/2021.
//  Copyright © 2021 Passback Systems. All rights reserved.
//

#include "FDPlateCBridge.h"
#include <iostream>
#include "FDPlate.hpp"

void *makePlate()
{
    const double sampleRate = 44.1e3;
    FDPlate::PlateParameters plateParams;
    plateParams.t60 = 0.3;
    plateParams.thickness = 0.0009;
    plateParams.tone = .5;
    plateParams.lengthX = 2.59;
    plateParams.lengthY = 2.59;
    plateParams.bcType = FDPlate::BoundaryCondition::simplySupported;
    
    FDPlate* plate = new FDPlate(sampleRate, plateParams);
    plate->setRc(700.0, 0.13, 0.117);
//    plate->setInitialCondition();
    plate->printCoefs();
    plate->printInfo();
    
    return plate;
}

int getGridSize(void* globalPlate)
{
    FDPlate& plate = *static_cast<FDPlate*>(globalPlate);
    return plate.getGridSize();
}

float* getCurrentState(void* globalPlate)
{
    FDPlate& plate = *static_cast<FDPlate*>(globalPlate);
    return plate.getCurrentState();
}

void updateScheme(void* globalPlate)
{
    FDPlate& plate = *static_cast<FDPlate*>(globalPlate);
    plate.updateScheme();
}

void addForce(void* globalPlate, float force, float xCoord, float yCoord)
{
    FDPlate& plate = *static_cast<FDPlate*>(globalPlate);
    plate.addForce(force, xCoord, yCoord);
}
void clearStates(void* globalPlate)
{
    FDPlate& plate = *static_cast<FDPlate*>(globalPlate);
    plate.clearStates();
}
void destructPlate(void* globalPlate)
{
    if(static_cast<FDPlate*>(globalPlate))
        delete static_cast<FDPlate*>(globalPlate);
}

void bridgetest()
{
    std::cout << "success!\n";
}
