# How to save Orbbec SDK v2 log

This guide explains how to save logs from OrbbecViewer and Orbbec SDK v2 applications on both Windows and Linux.

## How to save logs using OrbbecViewer
First, set the log level to Debug. To enable device firmware logs,check the Heartbeat option.


![image](../Images/OrbbecViewer_setLog.png)

Logs are saved in the Log folder located in the same directory as OrbbecViewer.

### windows

On Windows, the log path is as follows:

![image](../Images/OrbbecViewer_windows_log.png)


### Linux (x64/ARM64)
On Linux (x64/ARM64), the log path is as follows
![image](../Images/OrbbecViewer_linux_log.png)


- Note:If the SDK is installed via the installer, the logs are saved in the Log directory alongside OrbbecViewer in the installation path.

## How to save logs in an Orbbec SDK v2 application

### windows
- Copy OrbbecSDKConfig.xml to the same directory as OrbbecSDK.dll.
- Set File Log level to 0 (Debug).

![image](../Images/windows_sdk_level.png)

- To enable firmware logging, set DefaultHeartBeat to 1 in the corresponding device section.
Example for Gemini 335LE:
```
    <Gemini335Le>
        <!-- Whether to enable heartbeat by default -->
            <DefaultHeartBeat>1</DefaultHeartBeat>
    </Gemini335Le>
``` 
- Logs are stored in the Log folder alongside the application. Example

![image](../Images/windows_sdk_log.png)




### Linux (x64/ARM64)
- Copy OrbbecSDKConfig.xml to the same directory as libOrbbecSDK.so.
- Set File Log level to 0 (Debug).

![image](../Images/linux_log_level.png)
- Enable firmware logging by setting DefaultHeartBeat to 1 in the device section.Example for Gemini 335LE:
```
    <Gemini335Le>
        <!-- Whether to enable heartbeat by default -->
            <DefaultHeartBeat>1</DefaultHeartBeat>
    </Gemini335Le>
``` 
- Logs are stored in the Log folder alongside the application. Example:
![image](../Images/linux_sdk_log.png)








