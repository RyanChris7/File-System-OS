#include "file_system.h"
#include <cuda.h>
#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>

__device__ __managed__ u32 gtime = 0;


__device__ void fs_init(FileSystem *fs, uchar *volume, int SUPERBLOCK_SIZE,
							int FCB_SIZE, int FCB_ENTRIES, int VOLUME_SIZE,
							int STORAGE_BLOCK_SIZE, int MAX_FILENAME_SIZE, 
							int MAX_FILE_NUM, int MAX_FILE_SIZE, int FILE_BASE_ADDRESS)
{
  // init variables
  fs->volume = volume;

  // init constants
  fs->SUPERBLOCK_SIZE = SUPERBLOCK_SIZE;
  fs->FCB_SIZE = FCB_SIZE;
  fs->FCB_ENTRIES = FCB_ENTRIES;
  fs->STORAGE_SIZE = VOLUME_SIZE;
  fs->STORAGE_BLOCK_SIZE = STORAGE_BLOCK_SIZE;
  fs->MAX_FILENAME_SIZE = MAX_FILENAME_SIZE;
  fs->MAX_FILE_NUM = MAX_FILE_NUM;
  fs->MAX_FILE_SIZE = MAX_FILE_SIZE;
  fs->FILE_BASE_ADDRESS = FILE_BASE_ADDRESS;
	fs->head = (u32) 0x0000FFFF;
	fs->tail= (u32) 0x0000FFFF;
}

__device__ u32 fs_open(FileSystem *fs, char *s, int op)
{
 /* Implement open operation here */
	u32 hex = 0x0000FFFF;
	u32 bit8 = 0x000000FF;
	char n[20];
	char x;
	for(int i = 0;i < fs->FCB_ENTRIES;i++){
		for (int j = 0; j < fs->MAX_FILENAME_SIZE; j++) {
			x = fs->volume[fs->SUPERBLOCK_SIZE + i * fs->FCB_SIZE + j];
			if (x == '\0') break;
			n[j] = x;
		}
		
		hex = (fs->volume[fs->SUPERBLOCK_SIZE + i * fs->FCB_SIZE + x] << 8) + fs->volume[fs->SUPERBLOCK_SIZE + i * fs->FCB_SIZE + (x+1)];
	}

	if(hex == 0x0000FFFF){
		if(op == G_READ){
			printf("FILE IS NOT ON THE DISK!!");
			return (u32) 0x0000FFFF;
		}else {
			for(int i = 0; i < fs->FCB_ENTRIES;i++){
				if(((fs->volume[fs->SUPERBLOCK_SIZE + i * fs->FCB_SIZE + 22] << 8) + fs->volume[fs->SUPERBLOCK_SIZE + i * fs->FCB_SIZE + 23]) == hex){
					hex = i;
					break;
				}
			}
			u32 value1 = fs->SUPERBLOCK_SIZE + hex * fs->FCB_SIZE;
			fs->volume[value1 + 22] = 0;
			fs->volume[value1 + 23] = 0;
			for(int i = 0; i < fs->MAX_FILENAME_SIZE; i++){
				fs->volume[value1 + i] = s[i];
				if(s[i] == '\0')break;
			}

			u32 value2 = fs->SUPERBLOCK_SIZE + fs->head * fs->FCB_SIZE;
			if(fs->head == (u32) 0x0000FFFF) fs->tail = hex;
			else{
				fs->volume[value2 + 26] = hex & bit8;
				fs->volume[value2 + 27] = hex & bit8;
				fs->volume[value2 + 30] = hex & bit8;
				fs->volume[value2 + 31] = hex & bit8;
			}
			fs->volume[value1 + 24] = fs->head & bit8;
			fs->volume[value1 + 25] = fs->head & bit8;
			fs->volume[value1 + 28] = fs->head & bit8;
			fs->volume[value1 + 29] = fs->head & bit8;
			fs->head = hex;
		}
		return hex;
	}
}

__device__ void fs_read(FileSystem *fs, uchar *output, u32 size, u32 fp)
{
	/* Implement read operation here */
}

__device__ u32 fs_write(FileSystem *fs, uchar* input, u32 size, u32 fp)
{
	/* Implement write operation here */
}
__device__ void fs_gsys(FileSystem *fs, int op)
{
	/* Implement LS_D and LS_S operation here */
}

__device__ void fs_gsys(FileSystem *fs, int op, char *s)
{
	/* Implement rm operation here */
}
