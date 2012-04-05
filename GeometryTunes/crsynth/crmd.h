/* crmd.h - crsynth midi driver library */

/* Copyright (c) 2007-2011 CRIMSON TECHNOLOGY, Inc */

/*
modification history
--------------------
*/

/* 
DESCRIPTION 
*/

#ifndef __INCcrmdh
#define __INCcrmdh

#ifdef __cplusplus
extern "C" {
#endif

/* includes */

/* defines */

/* CRMD_EXPORTS should be UNDEFINED by applications using crmd.dll */

#ifdef CRMD_STATIC
	#define CRMD_API 
/*	#define CRMD_API */
#else /* CRMD_STATIC */
	#ifdef CRMD_EXPORTS
		#ifdef _MSC_VER
			#define CRMD_API __declspec(dllexport)
		#else /* _MSC_VER */
			#define CRMD_API 
		#endif /* _MSC_VER */
	#else /* CRMD_EXPORTS */
		#ifdef _MSC_VER
			#define CRMD_API  __declspec(dllimport)
		#else /* _MSC_VER */
			#define CRMD_API 
		#endif /* _MSC_VER */
	#endif /* CRMD_EXPORTS */
#endif /* CRMD_STATIC */

#ifndef _MSC_VER
	#ifndef __TCHAR_DEFINED
		typedef char TCHAR;
		typedef char *LPSTR;
		typedef TCHAR * LPTSTR;
		typedef const TCHAR *LPCTSTR;
		#define __TCHAR_DEFINED
	#endif
#endif /* _MSC_VER */

typedef enum
{
	/* errors */
	CRMD_OK = 0,
	CRMD_ERR_PROTECTION = -1,
	CRMD_ERR_INVALID_HANDLE = -2,
	CRMD_ERR_FILE = -10,
	CRMD_ERR_MEMORY = -20,
	CRMD_ERR_RESOURCE = -30,
	CRMD_ERR_PARAM = -40,
	CRMD_ERR_AUDIO_DRIVER = -100,
	CRMD_ERR_DATA = -200,
	CRMD_ERR_MODULE = -800,
	CRMD_ERR_NOT_SUPPORTED = -900,
	CRMD_ERR_UNDEFINED = -901,
} CRMD_ERR;

typedef enum
{
	/* common controls: 00000 - 09999 */
	CRMD_CTRL_SET_MASTER_VOLUME = 0,	/* master volume */
	CRMD_CTRL_GET_MASTER_VOLUME,

	CRMD_CTRL_SET_REVERB = 100, /* reverb */
	CRMD_CTRL_GET_REVERB,
	CRMD_CTRL_GET_REVERB_AVAILABLE,
	CRMD_CTRL_SET_CHORUS = 110, /* chorus */
	CRMD_CTRL_GET_CHORUS,
	CRMD_CTRL_GET_CHORUS_AVAILABLE,
	CRMD_CTRL_SET_DELAY = 120, /* delay */
	CRMD_CTRL_GET_DELAY,
	CRMD_CTRL_GET_DELAY_AVAILABLE,

	CRMD_CTRL_SET_SAMPLE_RATE = 200,
	CRMD_CTRL_GET_SAMPLE_RATE,
	CRMD_CTRL_SET_CHANNELS,
	CRMD_CTRL_GET_CHANNELS,
	CRMD_CTRL_SET_BLOCK_SIZE,
	CRMD_CTRL_GET_BLOCK_SIZE,
	CRMD_CTRL_SET_BUFFERS,
	CRMD_CTRL_GET_BUFFERS,
	CRMD_CTRL_SET_POLY = 210,
	CRMD_CTRL_GET_POLY,

	/* crse controls: 10000 - 19999 */
	CRMD_CTRL_GET_SOUND_LIBRARY_NUM = 11000,
	CRMD_CTRL_SET_SOUND_LIBRARY = CRMD_CTRL_GET_SOUND_LIBRARY_NUM + 10,
	CRMD_CTRL_SET_SOUND_LIBRARY_MEMORY = CRMD_CTRL_GET_SOUND_LIBRARY_NUM + 20,
	CRMD_CTRL_SET_SOUND_LIBRARY_SEL = CRMD_CTRL_GET_SOUND_LIBRARY_NUM + 30,
	CRMD_CTRL_GET_SOUND_LIBRARY_SEL,

	CRMD_CTRL_GET_INSTRUMENT_NAME = 12000,
	CRMD_CTRL_SET_MUTE = 12100,
	CRMD_CTRL_GET_MUTE = 12200,
	CRMD_CTRL_SET_SOLO = 12300,
	CRMD_CTRL_GET_SOLO = 12400,

	/* crmd controls: 30000 - 39999 */

} CRMD_CTRL;

typedef enum
{
	/* callback command - callback_parameter */
	CRMD_CALLBACK_TYPE_NULL = -1,

	CRMD_CALLBACK_TYPE_OPEN = 0, /* [reserved only] */
	CRMD_CALLBACK_TYPE_CLOSE, /* [reserved only] */

	CRMD_CALLBACK_TYPE_START = 10, /* - */
	CRMD_CALLBACK_TYPE_STOP, /* (DWORD *) errorcode */
	CRMD_CALLBACK_TYPE_FRAME,

	CRMD_CALLBACK_TYPE_FILE_START = 20,
	CRMD_CALLBACK_TYPE_FILE_STOP,
	CRMD_CALLBACK_TYPE_FILE_SEEK,

	CRMD_CALLBACK_TYPE_CLOCK = 30, /* - */
	CRMD_CALLBACK_TYPE_TEMPO, /* (DWORD *) usecPerBeat */
	CRMD_CALLBACK_TYPE_TIME_SIGNATURE, /* (unsigned long *) (nn/dd/cc/bb) */

	CRMD_CALLBACK_TYPE_CHANNEL_MESSAGE, /* (unsigned long *) (port/status/data0/data1) */
	CRMD_CALLBACK_TYPE_SYSTEM_EXCLUSIVE_MESSAGE, /* (unsigned char *) (data) */
} CRMD_CALLBACK_TYPE;

enum 
{
	/* file types */
	CRMD_FILE_FORMAT_SMF_0 = 0x0000,
	CRMD_FILE_FORMAT_SMF_1,
	CRMD_FILE_FORMAT_SMF_2,

	CRMD_FILE_FORMAT_MCOMP_SMF0 = 0x0010,
	CRMD_FILE_FORMAT_MCOMP_SMF1,
	CRMD_FILE_FORMAT_MCOMP_SMF2,
	CRMD_FILE_FORMAT_MCOMP_MFMP,

	/* volume */
	CRMD_VOLUME_MIN = 0,
	CRMD_VOLUME_DEF = 10,
	CRMD_VOLUME_MAX = 10,
};

typedef enum {
	CRMD_SOUND_LIBRARY_SEL_MODE_NORMAL = 0,
} CRMD_SOUND_LIBRARY_SEL_MODE;

/* typedefs */

typedef void *CRMD_HANDLE;

typedef void (*CRMD_CALLBACK) (CRMD_HANDLE handle, CRMD_CALLBACK_TYPE type, void *data, void *user);

typedef struct {
	int index;
	LPCTSTR path;
} CRMD_SOUND_LIBRARY;

typedef struct {
	int index;
	char *address;
	unsigned long size;
} CRMD_SOUND_LIBRARY_MEMORY;

typedef struct {
	int module;
	int part;
	int index;
	CRMD_SOUND_LIBRARY_SEL_MODE mode;
} CRMD_SOUND_LIBRARY_SEL;

typedef struct {
	long sampleFrames;
	void *data;
} CRMD_FRAME;

typedef struct {
	int size;

	/* status */
	CRMD_ERR (*initialize) (CRMD_HANDLE *handle, CRMD_CALLBACK callback, void *user, void *target, const unsigned char *key);
	CRMD_ERR (*initializeWithSoundLib) (CRMD_HANDLE *handle, CRMD_CALLBACK callback, void *user, LPCTSTR libraryPath, void *target, const unsigned char *key);
	CRMD_ERR (*initializeWithSoundLibMemory) (CRMD_HANDLE *handle, CRMD_CALLBACK callback, void *user, char *libraryAddress, unsigned long librarySize, void *target, const unsigned char *key);
	CRMD_ERR (*exit) (CRMD_HANDLE handle);

	/* wave device */
	int (*getNumDrivers) (CRMD_HANDLE handle);
	int (*getNumDevice) (CRMD_HANDLE handle, LPCTSTR driver);
	LPCTSTR (*getDriverName) (CRMD_HANDLE handle, int index);
	LPCTSTR (*getDeviceName) (CRMD_HANDLE handle, LPCTSTR driver, int index);
	void (*showDeviceControlPanel) (CRMD_HANDLE handle, LPCTSTR driver, LPCTSTR device);
	CRMD_ERR (*open) (CRMD_HANDLE handle, LPCTSTR driver, LPCTSTR device);
	CRMD_ERR (*close) (CRMD_HANDLE handle);

	/* play */
	CRMD_ERR (*start) (CRMD_HANDLE handle);
	CRMD_ERR (*stop) (CRMD_HANDLE handle);
	int (*isPlaying) (CRMD_HANDLE handle);

	/* midi message */
	void (*setChannelMessage) (CRMD_HANDLE handle, unsigned char port, unsigned char status, unsigned char data1, unsigned char data2);
	void (*setSystemExclusiveMessage) (CRMD_HANDLE handle, unsigned char port, unsigned char status, unsigned char *data, int size);

	/* file */
	CRMD_ERR (*setFile) (CRMD_HANDLE handle, LPCTSTR path);
	CRMD_ERR (*setFileMemory) (CRMD_HANDLE handle, char *address, unsigned long size);
	CRMD_ERR (*getFileMemory) (CRMD_HANDLE handle, char **address, unsigned long *size);
	CRMD_ERR (*getFileInfo) (CRMD_HANDLE handle, int *format, unsigned short *division, unsigned long *totaltick, unsigned long *totaltime);
	CRMD_ERR (*startFilePlay) (CRMD_HANDLE handle);
	CRMD_ERR (*stopFilePlay) (CRMD_HANDLE handle);
	CRMD_ERR (*seekFilePlay) (CRMD_HANDLE handle, unsigned long tick);
	int (*isFilePlaying) (CRMD_HANDLE handle);

	/* etc */
	CRMD_ERR (*ctrl) (CRMD_HANDLE handle, CRMD_CTRL ctrl, void *data, int size);
	void (*version) (CRMD_HANDLE handle, LPTSTR engine, int engineSize, LPTSTR player, int playerSize);
} CRMD_FUNC;

typedef CRMD_FUNC *(*CRMD_LOAD) (void);

/* function declarations */

CRMD_API CRMD_FUNC *crmdLoad (void);

#ifdef __cplusplus
}
#endif

#endif /* __INCcrmdh */

