#include <iostream>
#include <stdlib.h>
#include <assert.h>

#include "cudaTools.h"
#include "Device.h"
#include "Options.h"

#include  "LimitsTools.h"

using std::cout;
using std::endl;

/*----------------------------------------------------------------------*\
 |*			Declaration 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Imported	 	*|
 \*-------------------------------------*/

extern int mainCore();
extern int mainTest();

/*--------------------------------------*\
 |*		Public			*|
 \*-------------------------------------*/

int main(void);

/*--------------------------------------*\
 |*		Private			*|
 \*-------------------------------------*/

static int use(Options& option);
static void initCuda(Options& option);
static int start(Options& option);

/*----------------------------------------------------------------------*\
 |*			Implementation 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Public			*|
 \*-------------------------------------*/

int main(void)
    {
    // LimitsTools::rappelTypeSize();

    // Server Cuda1: in [0,5]	(6 Devices)
    // Server Cuda2: in [0,3]	(4 Devices)
    // Server Cuda3: in [0,2]	(2 Devices)
    int DEVICE_ID = 0;
    bool IS_TEST = false;

    Options option(IS_TEST, DEVICE_ID);

    return use(option);
    }

int use(Options& option)
    {
    if (Device::isCuda())
	{
	initCuda(option);

	int isOk = start(option);

	Device::reset();  //cudaDeviceReset causes the driver to clean up all state. While not mandatory in normal operation, it is good practice.

	return isOk;
	}
    else
	{
	return EXIT_FAILURE;
	}
    }

void initCuda(Options& option)
    {
    int deviceId = option.getDeviceId();

    // Choose current device (state of host-thread)
    Device::setDevice(deviceId);

    // It can be usefull to preload driver, by example to practice benchmarking! (sometimes slow under linux)
    Device::loadCudaDriver(deviceId);
    // Device::loadCudaDriverAll();// Force driver to be load for all GPU
    }

int start(Options& option)
    {
    // print
	{
	//Device::printAll();
	Device::printAllSimple();
	Device::printCurrent();
	//Device::print(option.getDeviceId());
	}

    if (option.isTest())
	{
	return mainTest();
	}
    else
	{
	return mainCore();
	}
    }

/*----------------------------------------------------------------------*\
 |*			End	 					*|
 \*---------------------------------------------------------------------*/

