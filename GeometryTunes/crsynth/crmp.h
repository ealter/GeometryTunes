/* crmp.h - */

/* Copyright (c) 2002-2011 CRIMSON TECHNOLOGY, Inc */

/*
modification history
--------------------
*/

/* 
DESCRIPTION 
*/

#ifndef __INCcrmph
#define __INCcrmph

#ifdef __cplusplus
extern "C" {
#endif

/* includes */

/* defines */

/* CRMP_EXPORTS should be UNDEFINED by applications using crmp.dll */

#ifdef CRMP_STATIC
	#define CRMP_API 
/*	#define CRMP_API */
#else /* CRMP_STATIC */
	#ifdef CRMP_EXPORTS
		#ifdef _MSC_VER
			#define CRMP_API __declspec(dllexport)
		#else /* _MSC_VER */
			#define CRMP_API 
		#endif /* _MSC_VER */
	#else /* CRMP_EXPORTS */
		#ifdef _MSC_VER
			#define CRMP_API  __declspec(dllimport)
		#else /* _MSC_VER */
			#define CRMP_API 
		#endif /* _MSC_VER */
	#endif /* CRMP_EXPORTS */
#endif /* CRMP_STATIC */

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
	CRMP_OK = 0,
	CRMP_ERR_PROTECTION = -1,
	CRMP_ERR_INVALID_HANDLE = -2,
	CRMP_ERR_FILE = -10,
	CRMP_ERR_MEMORY = -20,
	CRMP_ERR_RESOURCE = -30,
	CRMP_ERR_PARAM = -40,
	CRMP_ERR_AUDIO_DRIVER = -100,
	CRMP_ERR_DATA = -200,
	CRMP_ERR_MODULE = -800,
	CRMP_ERR_NOT_SUPPORTED = -900,
	CRMP_ERR_UNDEFINED = -901,
} CRMP_ERR;

typedef enum
{
	/* common controls: 00000 - 09999 */
	CRMP_CTRL_SET_MASTER_VOLUME = 0,	/* master volume */
	CRMP_CTRL_GET_MASTER_VOLUME,
	CRMP_CTRL_SET_MASTER_KEY = 10, /* master key */
	CRMP_CTRL_GET_MASTER_KEY,
	CRMP_CTRL_SET_MASTER_TUNE, /* master tune */
	CRMP_CTRL_GET_MASTER_TUNE,
	CRMP_CTRL_SET_SPEED = 20, /* speed control */
	CRMP_CTRL_GET_SPEED,
	CRMP_CTRL_SET_GUIDE = 30, /* guide melody control */
	CRMP_CTRL_GET_GUIDE,
	CRMP_CTRL_SET_GUIDE_MAIN_CH, /* guide melody target port/channel */
	CRMP_CTRL_GET_GUIDE_MAIN_CH,
	CRMP_CTRL_SET_GUIDE_SUB_CH, /* guide melody target port/channel */
	CRMP_CTRL_GET_GUIDE_SUB_CH,

	CRMP_CTRL_SET_REVERB = 100, /* reverb */
	CRMP_CTRL_GET_REVERB,
	CRMP_CTRL_GET_REVERB_AVAILABLE,
	CRMP_CTRL_SET_CHORUS = 110, /* chorus */
	CRMP_CTRL_GET_CHORUS,
	CRMP_CTRL_GET_CHORUS_AVAILABLE,
	CRMP_CTRL_SET_DELAY = 120, /* delay */
	CRMP_CTRL_GET_DELAY,
	CRMP_CTRL_GET_DELAY_AVAILABLE,

	CRMP_CTRL_SET_SAMPLE_RATE = 200,
	CRMP_CTRL_GET_SAMPLE_RATE,
	CRMP_CTRL_SET_BLOCK_SIZE,
	CRMP_CTRL_GET_BLOCK_SIZE,
	CRMP_CTRL_SET_CHANNELS,
	CRMP_CTRL_GET_CHANNELS,
	CRMP_CTRL_SET_POLY = 210,
	CRMP_CTRL_GET_POLY,

	/* crse controls: 10000 - 19999 */
	CRMP_CTRL_GET_SOUND_LIBRARY_NUM = 11000,
	CRMP_CTRL_SET_SOUND_LIBRARY = CRMP_CTRL_GET_SOUND_LIBRARY_NUM + 10,
	CRMP_CTRL_SET_SOUND_LIBRARY_MEMORY = CRMP_CTRL_GET_SOUND_LIBRARY_NUM + 20,
	CRMP_CTRL_SET_SOUND_LIBRARY_SEL = CRMP_CTRL_GET_SOUND_LIBRARY_NUM + 30,
	CRMP_CTRL_GET_SOUND_LIBRARY_SEL,

	CRMP_CTRL_GET_INSTRUMENT_NAME = 12000,
	CRMP_CTRL_SET_MUTE = 12100,
	CRMP_CTRL_GET_MUTE = 12200,
	CRMP_CTRL_SET_SOLO = 12300,
	CRMP_CTRL_GET_SOLO = 12400,

	/* crmp controls: 20000 - 29999 */
} CRMP_CTRL;

typedef enum
{
	/* callback command - callback_parameter */
	CRMP_CALLBACK_TYPE_NULL = -1,

	CRMP_CALLBACK_TYPE_OPEN = 0,
	CRMP_CALLBACK_TYPE_CLOSE,

	CRMP_CALLBACK_TYPE_START = 10,
	CRMP_CALLBACK_TYPE_STOP, /* (unsigned long *) errorcode */
	CRMP_CALLBACK_TYPE_SEEK,

	CRMP_CALLBACK_TYPE_CLOCK = 30,
	CRMP_CALLBACK_TYPE_TEMPO, /* (unsigned long *) usecPerBeat */
	CRMP_CALLBACK_TYPE_TIME_SIGNATURE, /* (unsigned long *) (nn/dd/cc/bb) */
	
	CRMP_CALLBACK_TYPE_CHANNEL_MESSAGE, /* (unsigned long *) (port/status/data0/data1) */
	CRMP_CALLBACK_TYPE_SYSTEM_EXCLUSIVE_MESSAGE, /* (unsigned char *) (data) */
} CRMP_CALLBACK_TYPE;

typedef enum
{
	/* export file types */
	CRMP_WAVE_FILE_RIFF = 0,
	CRMP_WAVE_FILE_AIFF,
} CRMP_WAVE_FILE;

enum 
{
	/* file types */
	CRMP_FILE_FORMAT_SMF_0 = 0x0000,
	CRMP_FILE_FORMAT_SMF_1,
	CRMP_FILE_FORMAT_SMF_2,

	CRMP_FILE_FORMAT_MCOMP_SMF0 = 0x0010,
	CRMP_FILE_FORMAT_MCOMP_SMF1,
	CRMP_FILE_FORMAT_MCOMP_SMF2,
	CRMP_FILE_FORMAT_MCOMP_MFMP,

	/* volume */
	CRMP_VOLUME_MIN = 0,
	CRMP_VOLUME_DEF = 10,
	CRMP_VOLUME_MAX = 10,

	/* key control [semitone] */
	CRMP_KEY_MIN = -24,
	CRMP_KEY_DEF = 0,
	CRMP_KEY_MAX = 24,

	/* fine tune control [cent] */
	CRMP_TUNE_MIN = -100,
	CRMP_TUNE_DEF = 0,
	CRMP_TUNE_MAX = 100,

	/* speed control [%] */
	CRMP_SPEED_MIN = -50,
	CRMP_SPEED_DEF = 0,
	CRMP_SPEED_MAX = 50,

	/* guide control */
	CRMP_GUIDE_MIN = -2,
	CRMP_GUIDE_DEF = 0,
	CRMP_GUIDE_MAX = 2,
};

typedef enum {
	CRMP_SOUND_LIBRARY_SEL_MODE_NORAMAL = 0,
} CRMP_SOUND_LIBRARY_SEL_MODE;

/* typedefs */

typedef void *CRMP_HANDLE;

typedef void (*CRMP_CALLBACK) (CRMP_HANDLE handle, CRMP_CALLBACK_TYPE type, void *data, void *user);

typedef int (*CRMP_CALLBACK_BOUNCE) (int percent, void *user);

typedef struct {
	int index;
	LPCTSTR path;
} CRMP_SOUND_LIBRARY;

typedef struct {
	int index;
	char *address;
	unsigned long size;
} CRMP_SOUND_LIBRARY_MEMORY;

typedef struct {
	int module;
	int part;
	int index;
	CRMP_SOUND_LIBRARY_SEL_MODE mode;
} CRMP_SOUND_LIBRARY_SEL;

typedef struct {
	int size;

	/* status */
	CRMP_ERR (*initialize) (CRMP_HANDLE *handle, CRMP_CALLBACK callback, void *user, void *target, const unsigned char *key);
	CRMP_ERR (*initializeWithSoundLib) (CRMP_HANDLE *handle, CRMP_CALLBACK callback, void *user, LPCTSTR libraryPath, void *target, const unsigned char *key);
	CRMP_ERR (*initializeWithSoundLibMemory) (CRMP_HANDLE *handle, CRMP_CALLBACK callback, void *user, char *libraryAddress, unsigned long librarySize, void *target, const unsigned char *key);
	CRMP_ERR (*exit) (CRMP_HANDLE handle);

	/* wave device */
	int (*getNumDrivers) (CRMP_HANDLE handle);
	int (*getNumDevices) (CRMP_HANDLE handle, LPCTSTR driver);
	LPCTSTR (*getDriverName) (CRMP_HANDLE handle, int index);
	LPCTSTR (*getDeviceName) (CRMP_HANDLE handle, LPCTSTR driver, int index);
	void (*showDeviceControlPanel) (CRMP_HANDLE handle, LPCTSTR driver, LPCTSTR device);
	CRMP_ERR (*open) (CRMP_HANDLE handle, LPCTSTR driver, LPCTSTR device);
	CRMP_ERR (*close) (CRMP_HANDLE handle);

	/* play */
	CRMP_ERR (*start) (CRMP_HANDLE handle);
	CRMP_ERR (*stop) (CRMP_HANDLE handle);
	CRMP_ERR (*seek) (CRMP_HANDLE handle, unsigned long tick);
	int (*isPlaying) (CRMP_HANDLE handle);

	/* export */
	CRMP_ERR (*bounce) (CRMP_HANDLE handle, LPCTSTR path, CRMP_WAVE_FILE type, CRMP_CALLBACK_BOUNCE callback, void *user);

	/* file */
	CRMP_ERR (*setFile) (CRMP_HANDLE handle, LPCTSTR path);
	CRMP_ERR (*setFileMemory) (CRMP_HANDLE handle, char *address, unsigned long size);
	CRMP_ERR (*getFileMemory) (CRMP_HANDLE handle, char **address, unsigned long *size);
	CRMP_ERR (*getFileInfo) (CRMP_HANDLE handle, int *format, unsigned short *division, unsigned long *totaltick, unsigned long *totaltime);

	/* etc */
	CRMP_ERR (*ctrl) (CRMP_HANDLE handle, CRMP_CTRL ctrl, void *data, int size);
	void (*version) (CRMP_HANDLE handle, LPTSTR engine, int engineSize, LPTSTR player, int playerSize);
} CRMP_FUNC;

typedef CRMP_FUNC *(*CRMP_LOAD) (void);

/* function declarations */

CRMP_API CRMP_FUNC *crmpLoad (void);

#ifdef __cplusplus
}
#endif

#endif /* __INCcrmph */

