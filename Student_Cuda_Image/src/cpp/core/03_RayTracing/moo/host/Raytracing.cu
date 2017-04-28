#include "Raytracing.h"

#include <iostream>
#include <assert.h>

#include "Device.h"
#include <assert.h>

#include "length_cm.h"

#include "SphereCreator.h"

using std::cout;
using std::endl;

/*----------------------------------------------------------------------*\
 |*			Declaration 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Imported	 	*|
 \*-------------------------------------*/

extern __global__ void raytraceGM(uchar4* ptrDevPixels,Sphere* ptrDevTabSphere,int nbSpheres,uint w, uint h,float t);
extern __host__ void uploadGPU(Sphere* tabValue);
extern __global__ void raytraceCM(uchar4* ptrDevPixels, uint w, uint h, float t);
extern __global__ void rayTracingSM(uchar4* ptrDevPixels, uint w, uint h, float dt, Sphere* ptrDevTabSphere);
/*--------------------------------------*\
 |*		Public			*|
 \*-------------------------------------*/

/*--------------------------------------*\
 |*		Private			*|
 \*-------------------------------------*/

/*----------------------------------------------------------------------*\
 |*			Implementation 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Public			*|
 \*-------------------------------------*/

/*-------------------------*\
 |*	Constructeur	    *|
 \*-------------------------*/

Raytracing::Raytracing(const Grid& grid, uint w, uint h, float dt) :
	Animable_I<uchar4>(grid, w, h, "Raytracing_Cuda_RGBA_uchar4"), variateurAnimation(Interval<float>(0, 120),dt)
    {
    assert(w == h); // specific rippling

    // Inputs
    this->dt = dt;
    // Tools
    this->t = 0; // protected dans Animable
    this->nbSphere = LENGTH_CM;

    SphereCreator shereCreator(this->nbSphere, w, h); // sur la pile
    Sphere* ptrTabSphere = shereCreator.getTabSphere();

    this->size_octets = sizeof(Sphere) * this->nbSphere;

    // transfert to GM
    toGM(ptrTabSphere); // a implemneter

    // transfert to CM
    fillCM(ptrTabSphere);

    }

Raytracing::~Raytracing()
    {
    Device::free(this->ptrDevTabSphere);
    }

/*-------------------------*\
 |*	Methode		    *|
 \*-------------------------*/

void Raytracing::toGM(Sphere* ptrSphere)
    {

    Device::malloc(&this->ptrDevTabSphere, size_octets);

    Device::memcpyHToD(this->ptrDevTabSphere, ptrSphere, size_octets);
    }

__host__ void Raytracing::fillCM(Sphere* ptrSphere)
    {
// Appelle le service d’upload coté device
    uploadGPU(ptrSphere);
    }

/**
 * Override
 * Call periodicly by the API
 *
 * Note : domaineMath pas use car pas zoomable
 */
void Raytracing::process(uchar4* ptrDevPixels, uint w, uint h, const DomaineMath& domaineMath)
    {
    Device::lastCudaError("rippling rgba uchar4 (before kernel)"); // facultatif, for debug only, remove for release

    // TODO lancer le kernel avec <<<dg,db>>>
    // le kernel est importer ci-dessus (ligne 19)

    t=variateurAnimation.get();
    //raytrace<<<dg,db>>> (ptrDevPixels,this->ptrDevTabSphere,this->nbSphere,w,h,t);
    //raytrace_cm<<<dg,db>>> (ptrDevPixels,w,h,t);
    static int i = 0;

    if (i % 3 == 0)
    {
    raytraceGM<<<dg,db>>>(ptrDevPixels,this->ptrDevTabSphere,this->nbSphere,w,h,t);
    }
    else if (i % 3 == 1)
    {
    raytraceCM<<<dg,db>>>(ptrDevPixels, w, h, t);
    }
    else if (i % 3 == 2)
    {
    rayTracingSM<<<dg,db,size_octets>>>(ptrDevPixels, w, h, t, ptrDevTabSphere);
    }
    i++;
    Device::lastCudaError("rippling rgba uchar4 (after kernel)"); // facultatif, for debug only, remove for release
    }

/**
 * Override
 * Call periodicly by the API
 */
void Raytracing::animationStep()
    {
    t += variateurAnimation.varierAndGet();
    }

/*--------------------------------------*\
 |*		Private			*|
 \*-------------------------------------*/

/*----------------------------------------------------------------------*\
 |*			End	 					*|
 \*---------------------------------------------------------------------*/

