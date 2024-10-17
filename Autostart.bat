:: MISK-Active-Curtain tool by H. Caltenco, Certec, LTH
@echo off

:: show a welcome message
echo\
echo Fluid MISK-AC Batch Program Starter
echo ---------------------------------
echo Hector Caltenco (hector.caltenco@design.lth.se)
echo\
echo (Do not close this window!)
echo\

:: start Protokol OSC forwarding
echo Starting Protokol OSC Monitor: Protokol.exe
echo \

start "Protokol" "C:\Program Files\Protokol\Protokol.exe"

:: start the kinect server
echo Starting Kinect TUIO Server Application: KinectCoreVision.exe
echo\

cd kinectCV_mssdk_dualTuio
start KinectCoreVision.exe

:: start the fluid client
echo Starting Processing TUIO Client Application: MSAFluidTuioDemo.exe
echo\

cd ..
cd MSAFluid-MISK
start MSAFluidTuioDemo.exe

:end