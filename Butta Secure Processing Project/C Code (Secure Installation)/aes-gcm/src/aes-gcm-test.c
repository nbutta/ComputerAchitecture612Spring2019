/*
 * aes-gcm-test.c
 */

#define AES_DEBUG
#include "aes.h"

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

const unsigned char t3_key[] = {
    0xfe, 0xff, 0xe9, 0x92, 0x86, 0x65, 0x73, 0x1c, 0x6d, 0x6a, 0x8f, 0x94, 0x67, 0x30, 0x83, 0x08
};
//const unsigned char t3_iv[] = {
//    0xca, 0xfe, 0xba, 0xbe, 0xfa, 0xce, 0xdb, 0xad, 0xde, 0xca, 0xf8, 0x88
//};


//const unsigned char t3_aad[] = {};
const unsigned char t3_aad_2[] = {
	0xfe, 0xed, 0xfa, 0xce, 0xde, 0xad, 0xbe, 0xef, 0xfe, 0xed, 0xfa, 0xce, 0xde, 0xad, 0xbe, 0xef,
	0xab, 0xad, 0xda, 0xd2};

//const unsigned char t3_plain[] = {
//    0xd9, 0x31, 0x32, 0x25, 0xf8, 0x84, 0x06, 0xe5, 0xa5, 0x59, 0x09, 0xc5, 0xaf, 0xf5, 0x26, 0x9a,
//    0x86, 0xa7, 0xa9, 0x53, 0x15, 0x34, 0xf7, 0xda, 0x2e, 0x4c, 0x30, 0x3d, 0x8a, 0x31, 0x8a, 0x72,
//    0x1c, 0x3c, 0x0c, 0x95, 0x95, 0x68, 0x09, 0x53, 0x2f, 0xcf, 0x0e, 0x24, 0x49, 0xa6, 0xb5, 0x25,
//    0xb1, 0x6a, 0xed, 0xf5, 0xaa, 0x0d, 0xe6, 0x57, 0xba, 0x63, 0x7b, 0x39, 0x1a, 0xaf, 0xd2, 0x55
//};
//const unsigned char t3_plain_2[] = {
//    0xd9, 0x31, 0x32, 0x25, 0xf8, 0x84, 0x06, 0xe5, 0xa5, 0x59, 0x09, 0xc5, 0xaf, 0xf5, 0x26, 0x9a,
//    0x86, 0xa7, 0xa9, 0x53, 0x15, 0x34, 0xf7, 0xda, 0x2e, 0x4c, 0x30, 0x3d, 0x8a, 0x31, 0x8a, 0x72,
//    0x1c, 0x3c, 0x0c, 0x95, 0x95, 0x68, 0x09, 0x53, 0x2f, 0xcf, 0x0e, 0x24, 0x49, 0xa6, 0xb5, 0x25,
//    0xb1, 0x6a, 0xed, 0xf5, 0xaa, 0x0d, 0xe6, 0x57, 0xba, 0x63, 0x7b, 0x39
//};
//const unsigned char t3_crypt[] = {
//    0x42, 0x83, 0x1e, 0xc2, 0x21, 0x77, 0x74, 0x24, 0x4b, 0x72, 0x21, 0xb7, 0x84, 0xd0, 0xd4, 0x9c,
//    0xe3, 0xaa, 0x21, 0x2f, 0x2c, 0x02, 0xa4, 0xe0, 0x35, 0xc1, 0x7e, 0x23, 0x29, 0xac, 0xa1, 0x2e,
//    0x21, 0xd5, 0x14, 0xb2, 0x54, 0x66, 0x93, 0x1c, 0x7d, 0x8f, 0x6a, 0x5a, 0xac, 0x84, 0xaa, 0x05,
//    0x1b, 0xa3, 0x0b, 0x39, 0x6a, 0x0a, 0xac, 0x97, 0x3d, 0x58, 0xe0, 0x91, 0x47, 0x3f, 0x59, 0x85
//};
//const unsigned char t3_crypt_2[] = {
//    0x42, 0x83, 0x1e, 0xc2, 0x21, 0x77, 0x74, 0x24, 0x4b, 0x72, 0x21, 0xb7, 0x84, 0xd0, 0xd4, 0x9c,
//    0xe3, 0xaa, 0x21, 0x2f, 0x2c, 0x02, 0xa4, 0xe0, 0x35, 0xc1, 0x7e, 0x23, 0x29, 0xac, 0xa1, 0x2e,
//    0x21, 0xd5, 0x14, 0xb2, 0x54, 0x66, 0x93, 0x1c, 0x7d, 0x8f, 0x6a, 0x5a, 0xac, 0x84, 0xaa, 0x05,
//    0x1b, 0xa3, 0x0b, 0x39, 0x6a, 0x0a, 0xac, 0x97, 0x3d, 0x58, 0xe0, 0x91
//};
//const unsigned char t3_tag[] = {
//    0x4d, 0x5c, 0x2a, 0xf3, 0x27, 0xcd, 0x64, 0xa6, 0x2c, 0xf3, 0x5a, 0xbd, 0x2b, 0xa6, 0xfa, 0xb4
//};
//const unsigned char t3_tag_2[] = {
//    0x5b, 0xc9, 0x4f, 0xbc, 0x32, 0x21, 0xa5, 0xdb, 0x94, 0xfa, 0xe9, 0x5a, 0xe7, 0x12, 0x1a, 0x47
//};

//const unsigned char demo_pt1[] = {
//    0x20, 0x01, 0x00, 0x01
//};
//const unsigned char demo_pt2[] = {
//    0x20, 0x02, 0x00, 0x01
//};
//const unsigned char demo_pt3[] = {
//    0x20, 0x03, 0x00, 0x01
//};
//const unsigned char demo_pt4[] = {
//    0x20, 0x04, 0x00, 0x01
//};
//
//const unsigned char * demo_imem [4] = {demo_pt1, demo_pt2, demo_pt3, demo_pt4};

void printUnsgndCharArr(unsigned char* arr, int length) {
	int i = 0;
    for (i = 1; i < length+1 ; i++) {
    	printf("%.2X",arr[i-1]);
//    	if (i%16 == 0 && i != 0) {
//    		printf("\n");
//    	}
    }
    printf("\n");
}

void printCipherTextToFile (FILE * fp, unsigned char* arr, int length) {
	int i = 0;
    for (i = 1; i < length+1 ; i++) {
    	fprintf(fp, "%.2X", arr[i-1]);
    	if (i%4 == 0 && i != 0) {
    		fprintf(fp, "\n");
    	}
    }
    //fprintf(fp, "\n");
}

void printSignatureToFile (FILE * fp, unsigned char* arr, int length) {
	int i = 0;
    for (i = 1; i < length+1 ; i++) {
    	fprintf(fp, "%.2X", arr[i-1]);
    	//if (i%8 == 0 && i != 0) {
    	//	fprintf(fp, "\n");
    	//}
    }
    fprintf(fp, "\n");
}

char* stoupper(char str[])
{
      int i = 0;

      while(str[i])
      {
          str[i]=toupper(str[i]);
          i++;
      }
      return str;
}

void stringToCharArr(char* block_in, unsigned char* pt_buf) {
	int i = 0;
	char byte[3];
	//printf(block_in);
	char* block = stoupper(block_in);
	//printf(block);
	while (block[i] != '\n' && block[i] != '\0') {
    //for (i = 0; block[i] != '\n' || block[i] != '\0'; i+=2) {
    	memset(byte, 0, 3);
    	strncpy(byte, &block[i], 2);
    	//byte[2] = '\0';
        if (strcmp(byte, "00") == 0) {
        	pt_buf[i/2] = 0x00;
        } else if (strcmp(byte, "01") == 0) {
        	pt_buf[i/2] = 0x01;
        } else if (strcmp(byte, "02") == 0) {
        	pt_buf[i/2] = 0x02;
        } else if (strcmp(byte, "03") == 0) {
        	pt_buf[i/2] = 0x03;
        } else if (strcmp(byte, "04") == 0) {
        	pt_buf[i/2] = 0x04;
        } else if (strcmp(byte, "05") == 0) {
        	pt_buf[i/2] = 0x05;
        } else if (strcmp(byte, "06") == 0) {
        	pt_buf[i/2] = 0x06;
        } else if (strcmp(byte, "07") == 0) {
        	pt_buf[i/2] = 0x07;
        } else if (strcmp(byte, "08") == 0) {
        	pt_buf[i/2] = 0x08;
        } else if (strcmp(byte, "09") == 0) {
        	pt_buf[i/2] = 0x09;
        } else if (strcmp(byte, "0A") == 0) {
        	pt_buf[i/2] = 0x0A;
        } else if (strcmp(byte, "0B") == 0) {
        	pt_buf[i/2] = 0x0B;
        } else if (strcmp(byte, "0C") == 0) {
        	pt_buf[i/2] = 0x0C;
        } else if (strcmp(byte, "0D") == 0) {
        	pt_buf[i/2] = 0x0D;
        } else if (strcmp(byte, "0E") == 0) {
        	pt_buf[i/2] = 0x0E;
        } else if (strcmp(byte, "0F") == 0) {
        	pt_buf[i/2] = 0x0F;
        } else if (strcmp(byte, "10") == 0) {
        	pt_buf[i/2] = 0x10;
        } else if (strcmp(byte, "11") == 0) {
        	pt_buf[i/2] = 0x11;
        } else if (strcmp(byte, "12") == 0) {
        	pt_buf[i/2] = 0x12;
        } else if (strcmp(byte, "13") == 0) {
        	pt_buf[i/2] = 0x13;
        } else if (strcmp(byte, "14") == 0) {
        	pt_buf[i/2] = 0x14;
        } else if (strcmp(byte, "15") == 0) {
        	pt_buf[i/2] = 0x15;
        } else if (strcmp(byte, "16") == 0) {
        	pt_buf[i/2] = 0x16;
        } else if (strcmp(byte, "17") == 0) {
        	pt_buf[i/2] = 0x17;
        } else if (strcmp(byte, "18") == 0) {
        	pt_buf[i/2] = 0x18;
        } else if (strcmp(byte, "19") == 0) {
        	pt_buf[i/2] = 0x19;
        } else if (strcmp(byte, "1A") == 0) {
        	pt_buf[i/2] = 0x1A;
        } else if (strcmp(byte, "1B") == 0) {
        	pt_buf[i/2] = 0x1B;
        } else if (strcmp(byte, "1C") == 0) {
        	pt_buf[i/2] = 0x1C;
        } else if (strcmp(byte, "1D") == 0) {
        	pt_buf[i/2] = 0x1D;
        } else if (strcmp(byte, "1E") == 0) {
        	pt_buf[i/2] = 0x1E;
        } else if (strcmp(byte, "1F") == 0) {
        	pt_buf[i/2] = 0x1F;
        } else if (strcmp(byte, "20") == 0) {
        	pt_buf[i/2] = 0x20;
        } else if (strcmp(byte, "21") == 0) {
        	pt_buf[i/2] = 0x21;
        } else if (strcmp(byte, "22") == 0) {
        	pt_buf[i/2] = 0x22;
        } else if (strcmp(byte, "23") == 0) {
        	pt_buf[i/2] = 0x23;
        } else if (strcmp(byte, "24") == 0) {
        	pt_buf[i/2] = 0x24;
        } else if (strcmp(byte, "25") == 0) {
        	pt_buf[i/2] = 0x25;
        } else if (strcmp(byte, "26") == 0) {
        	pt_buf[i/2] = 0x26;
        } else if (strcmp(byte, "27") == 0) {
        	pt_buf[i/2] = 0x27;
        } else if (strcmp(byte, "28") == 0) {
        	pt_buf[i/2] = 0x28;
        } else if (strcmp(byte, "29") == 0) {
        	pt_buf[i/2] = 0x29;
        } else if (strcmp(byte, "2A") == 0) {
        	pt_buf[i/2] = 0x2A;
        } else if (strcmp(byte, "2B") == 0) {
        	pt_buf[i/2] = 0x2B;
        } else if (strcmp(byte, "2C") == 0) {
        	pt_buf[i/2] = 0x2C;
        } else if (strcmp(byte, "2D") == 0) {
        	pt_buf[i/2] = 0x2D;
        } else if (strcmp(byte, "2E") == 0) {
        	pt_buf[i/2] = 0x2E;
        } else if (strcmp(byte, "2F") == 0) {
        	pt_buf[i/2] = 0x2F;
        } else if (strcmp(byte, "30") == 0) {
        	pt_buf[i/2] = 0x30;
        } else if (strcmp(byte, "31") == 0) {
        	pt_buf[i/2] = 0x31;
        } else if (strcmp(byte, "32") == 0) {
        	pt_buf[i/2] = 0x32;
        } else if (strcmp(byte, "33") == 0) {
        	pt_buf[i/2] = 0x33;
        } else if (strcmp(byte, "34") == 0) {
        	pt_buf[i/2] = 0x34;
        } else if (strcmp(byte, "35") == 0) {
        	pt_buf[i/2] = 0x35;
        } else if (strcmp(byte, "36") == 0) {
        	pt_buf[i/2] = 0x36;
        } else if (strcmp(byte, "37") == 0) {
        	pt_buf[i/2] = 0x37;
        } else if (strcmp(byte, "38") == 0) {
        	pt_buf[i/2] = 0x38;
        } else if (strcmp(byte, "39") == 0) {
        	pt_buf[i/2] = 0x39;
        } else if (strcmp(byte, "3A") == 0) {
        	pt_buf[i/2] = 0x3A;
        } else if (strcmp(byte, "3B") == 0) {
        	pt_buf[i/2] = 0x3B;
        } else if (strcmp(byte, "3C") == 0) {
        	pt_buf[i/2] = 0x3C;
        } else if (strcmp(byte, "3D") == 0) {
        	pt_buf[i/2] = 0x3D;
        } else if (strcmp(byte, "3E") == 0) {
        	pt_buf[i/2] = 0x3E;
        } else if (strcmp(byte, "3F") == 0) {
        	pt_buf[i/2] = 0x3F;
        } else if (strcmp(byte, "40") == 0) {
        	pt_buf[i/2] = 0x40;
        }  else if (strcmp(byte, "41") == 0) {
        	pt_buf[i/2] = 0x41;
        } else if (strcmp(byte, "42") == 0) {
        	pt_buf[i/2] = 0x42;
        } else if (strcmp(byte, "43") == 0) {
        	pt_buf[i/2] = 0x43;
        } else if (strcmp(byte, "44") == 0) {
        	pt_buf[i/2] = 0x44;
        } else if (strcmp(byte, "45") == 0) {
        	pt_buf[i/2] = 0x45;
        } else if (strcmp(byte, "46") == 0) {
        	pt_buf[i/2] = 0x46;
        } else if (strcmp(byte, "47") == 0) {
        	pt_buf[i/2] = 0x47;
        } else if (strcmp(byte, "48") == 0) {
        	pt_buf[i/2] = 0x48;
        } else if (strcmp(byte, "49") == 0) {
        	pt_buf[i/2] = 0x49;
        } else if (strcmp(byte, "4A") == 0) {
        	pt_buf[i/2] = 0x4A;
        } else if (strcmp(byte, "4B") == 0) {
        	pt_buf[i/2] = 0x4B;
        } else if (strcmp(byte, "4C") == 0) {
        	pt_buf[i/2] = 0x4C;
        } else if (strcmp(byte, "4D") == 0) {
        	pt_buf[i/2] = 0x4D;
        } else if (strcmp(byte, "4E") == 0) {
        	pt_buf[i/2] = 0x4E;
        } else if (strcmp(byte, "4F") == 0) {
        	pt_buf[i/2] = 0x4F;
        } else if (strcmp(byte, "50") == 0) {
        	pt_buf[i/2] = 0x50;
        }  else if (strcmp(byte, "51") == 0) {
        	pt_buf[i/2] = 0x51;
        } else if (strcmp(byte, "52") == 0) {
        	pt_buf[i/2] = 0x52;
        } else if (strcmp(byte, "53") == 0) {
        	pt_buf[i/2] = 0x53;
        } else if (strcmp(byte, "54") == 0) {
        	pt_buf[i/2] = 0x54;
        } else if (strcmp(byte, "55") == 0) {
        	pt_buf[i/2] = 0x55;
        } else if (strcmp(byte, "56") == 0) {
        	pt_buf[i/2] = 0x56;
        } else if (strcmp(byte, "57") == 0) {
        	pt_buf[i/2] = 0x57;
        } else if (strcmp(byte, "58") == 0) {
        	pt_buf[i/2] = 0x58;
        } else if (strcmp(byte, "59") == 0) {
        	pt_buf[i/2] = 0x59;
        } else if (strcmp(byte, "5A") == 0) {
        	pt_buf[i/2] = 0x5A;
        } else if (strcmp(byte, "5B") == 0) {
        	pt_buf[i/2] = 0x5B;
        } else if (strcmp(byte, "5C") == 0) {
        	pt_buf[i/2] = 0x5C;
        } else if (strcmp(byte, "5D") == 0) {
        	pt_buf[i/2] = 0x5D;
        } else if (strcmp(byte, "5E") == 0) {
        	pt_buf[i/2] = 0x5E;
        } else if (strcmp(byte, "5F") == 0) {
        	pt_buf[i/2] = 0x5F;
        } else if (strcmp(byte, "60") == 0) {
        	pt_buf[i/2] = 0x60;
        } else if (strcmp(byte, "61") == 0) {
        	pt_buf[i/2] = 0x61;
        } else if (strcmp(byte, "62") == 0) {
        	pt_buf[i/2] = 0x62;
        } else if (strcmp(byte, "63") == 0) {
        	pt_buf[i/2] = 0x63;
        } else if (strcmp(byte, "64") == 0) {
        	pt_buf[i/2] = 0x64;
        } else if (strcmp(byte, "65") == 0) {
        	pt_buf[i/2] = 0x65;
        } else if (strcmp(byte, "66") == 0) {
        	pt_buf[i/2] = 0x66;
        } else if (strcmp(byte, "67") == 0) {
        	pt_buf[i/2] = 0x67;
        } else if (strcmp(byte, "68") == 0) {
        	pt_buf[i/2] = 0x68;
        } else if (strcmp(byte, "69") == 0) {
        	pt_buf[i/2] = 0x69;
        } else if (strcmp(byte, "6A") == 0) {
        	pt_buf[i/2] = 0x6A;
        } else if (strcmp(byte, "6B") == 0) {
        	pt_buf[i/2] = 0x6B;
        } else if (strcmp(byte, "6C") == 0) {
        	pt_buf[i/2] = 0x6C;
        } else if (strcmp(byte, "6D") == 0) {
        	pt_buf[i/2] = 0x6D;
        } else if (strcmp(byte, "6E") == 0) {
        	pt_buf[i/2] = 0x6E;
        } else if (strcmp(byte, "6F") == 0) {
        	pt_buf[i/2] = 0x6F;
        } else if (strcmp(byte, "70") == 0) {
        	pt_buf[i/2] = 0x70;
        } else if (strcmp(byte, "71") == 0) {
        	pt_buf[i/2] = 0x71;
        } else if (strcmp(byte, "72") == 0) {
        	pt_buf[i/2] = 0x72;
        } else if (strcmp(byte, "73") == 0) {
        	pt_buf[i/2] = 0x73;
        } else if (strcmp(byte, "74") == 0) {
        	pt_buf[i/2] = 0x74;
        } else if (strcmp(byte, "75") == 0) {
        	pt_buf[i/2] = 0x75;
        } else if (strcmp(byte, "76") == 0) {
        	pt_buf[i/2] = 0x76;
        } else if (strcmp(byte, "77") == 0) {
        	pt_buf[i/2] = 0x77;
        } else if (strcmp(byte, "78") == 0) {
        	pt_buf[i/2] = 0x78;
        } else if (strcmp(byte, "79") == 0) {
        	pt_buf[i/2] = 0x79;
        } else if (strcmp(byte, "7A") == 0) {
        	pt_buf[i/2] = 0x7A;
        } else if (strcmp(byte, "7B") == 0) {
        	pt_buf[i/2] = 0x7B;
        } else if (strcmp(byte, "7C") == 0) {
        	pt_buf[i/2] = 0x7C;
        } else if (strcmp(byte, "7D") == 0) {
        	pt_buf[i/2] = 0x7D;
        } else if (strcmp(byte, "7E") == 0) {
        	pt_buf[i/2] = 0x7E;
        } else if (strcmp(byte, "7F") == 0) {
        	pt_buf[i/2] = 0x7F;
        } else if (strcmp(byte, "80") == 0) {
        	pt_buf[i/2] = 0x80;
        } else if (strcmp(byte, "81") == 0) {
        	pt_buf[i/2] = 0x81;
        } else if (strcmp(byte, "82") == 0) {
        	pt_buf[i/2] = 0x82;
        } else if (strcmp(byte, "83") == 0) {
        	pt_buf[i/2] = 0x83;
        } else if (strcmp(byte, "84") == 0) {
        	pt_buf[i/2] = 0x84;
        } else if (strcmp(byte, "85") == 0) {
        	pt_buf[i/2] = 0x85;
        } else if (strcmp(byte, "86") == 0) {
        	pt_buf[i/2] = 0x86;
        } else if (strcmp(byte, "87") == 0) {
        	pt_buf[i/2] = 0x87;
        } else if (strcmp(byte, "88") == 0) {
        	pt_buf[i/2] = 0x88;
        } else if (strcmp(byte, "89") == 0) {
        	pt_buf[i/2] = 0x89;
        } else if (strcmp(byte, "8A") == 0) {
        	pt_buf[i/2] = 0x8A;
        } else if (strcmp(byte, "8B") == 0) {
        	pt_buf[i/2] = 0x8B;
        } else if (strcmp(byte, "8C") == 0) {
        	pt_buf[i/2] = 0x8C;
        } else if (strcmp(byte, "8D") == 0) {
        	pt_buf[i/2] = 0x8D;
        } else if (strcmp(byte, "8E") == 0) {
        	pt_buf[i/2] = 0x8E;
        } else if (strcmp(byte, "8F") == 0) {
        	pt_buf[i/2] = 0x8F;
        } else if (strcmp(byte, "90") == 0) {
        	pt_buf[i/2] = 0x90;
        } else if (strcmp(byte, "91") == 0) {
        	pt_buf[i/2] = 0x91;
        } else if (strcmp(byte, "92") == 0) {
        	pt_buf[i/2] = 0x92;
        } else if (strcmp(byte, "93") == 0) {
        	pt_buf[i/2] = 0x93;
        } else if (strcmp(byte, "94") == 0) {
        	pt_buf[i/2] = 0x94;
        } else if (strcmp(byte, "95") == 0) {
        	pt_buf[i/2] = 0x95;
        } else if (strcmp(byte, "96") == 0) {
        	pt_buf[i/2] = 0x96;
        } else if (strcmp(byte, "97") == 0) {
        	pt_buf[i/2] = 0x97;
        } else if (strcmp(byte, "98") == 0) {
        	pt_buf[i/2] = 0x98;
        } else if (strcmp(byte, "99") == 0) {
        	pt_buf[i/2] = 0x99;
        } else if (strcmp(byte, "9A") == 0) {
        	pt_buf[i/2] = 0x9A;
        } else if (strcmp(byte, "9B") == 0) {
        	pt_buf[i/2] = 0x9B;
        } else if (strcmp(byte, "9C") == 0) {
        	pt_buf[i/2] = 0x9C;
        } else if (strcmp(byte, "9D") == 0) {
        	pt_buf[i/2] = 0x9D;
        } else if (strcmp(byte, "9E") == 0) {
        	pt_buf[i/2] = 0x9E;
        } else if (strcmp(byte, "9F") == 0) {
        	pt_buf[i/2] = 0x9F;
        } else if (strcmp(byte, "A0") == 0) {
        	pt_buf[i/2] = 0xA0;
        } else if (strcmp(byte, "A1") == 0) {
        	pt_buf[i/2] = 0xA1;
        } else if (strcmp(byte, "A2") == 0) {
        	pt_buf[i/2] = 0xA2;
        } else if (strcmp(byte, "A3") == 0) {
        	pt_buf[i/2] = 0xA3;
        } else if (strcmp(byte, "A4") == 0) {
        	pt_buf[i/2] = 0xA4;
        } else if (strcmp(byte, "A5") == 0) {
        	pt_buf[i/2] = 0xA5;
        } else if (strcmp(byte, "A6") == 0) {
        	pt_buf[i/2] = 0xA6;
        } else if (strcmp(byte, "A7") == 0) {
        	pt_buf[i/2] = 0xA7;
        } else if (strcmp(byte, "A8") == 0) {
        	pt_buf[i/2] = 0xA8;
        } else if (strcmp(byte, "A9") == 0) {
        	pt_buf[i/2] = 0xA9;
        } else if (strcmp(byte, "AA") == 0) {
        	pt_buf[i/2] = 0xAA;
        } else if (strcmp(byte, "AB") == 0) {
        	pt_buf[i/2] = 0xAB;
        } else if (strcmp(byte, "AC") == 0) {
        	pt_buf[i/2] = 0xAC;
        } else if (strcmp(byte, "AD") == 0) {
        	pt_buf[i/2] = 0xAD;
        } else if (strcmp(byte, "AE") == 0) {
        	pt_buf[i/2] = 0xAE;
        } else if (strcmp(byte, "AF") == 0) {
        	pt_buf[i/2] = 0xAF;
        } else if (strcmp(byte, "B0") == 0) {
        	pt_buf[i/2] = 0xB0;
        } else if (strcmp(byte, "B1") == 0) {
        	pt_buf[i/2] = 0xB1;
        } else if (strcmp(byte, "B2") == 0) {
        	pt_buf[i/2] = 0xB2;
        } else if (strcmp(byte, "B3") == 0) {
        	pt_buf[i/2] = 0xB3;
        } else if (strcmp(byte, "B4") == 0) {
        	pt_buf[i/2] = 0xB4;
        } else if (strcmp(byte, "B5") == 0) {
        	pt_buf[i/2] = 0xB5;
        } else if (strcmp(byte, "B6") == 0) {
        	pt_buf[i/2] = 0xB6;
        } else if (strcmp(byte, "B7") == 0) {
        	pt_buf[i/2] = 0xB7;
        } else if (strcmp(byte, "B8") == 0) {
        	pt_buf[i/2] = 0xB8;
        } else if (strcmp(byte, "B9") == 0) {
        	pt_buf[i/2] = 0xB9;
        } else if (strcmp(byte, "BA") == 0) {
        	pt_buf[i/2] = 0xBA;
        } else if (strcmp(byte, "BB") == 0) {
        	pt_buf[i/2] = 0xBB;
        } else if (strcmp(byte, "BC") == 0) {
        	pt_buf[i/2] = 0xBC;
        } else if (strcmp(byte, "BD") == 0) {
        	pt_buf[i/2] = 0xBD;
        } else if (strcmp(byte, "BE") == 0) {
        	pt_buf[i/2] = 0xBE;
        } else if (strcmp(byte, "BF") == 0) {
        	pt_buf[i/2] = 0xBF;
        } else if (strcmp(byte, "C0") == 0) {
        	pt_buf[i/2] = 0xC0;
        } else if (strcmp(byte, "C1") == 0) {
        	pt_buf[i/2] = 0xC1;
        } else if (strcmp(byte, "C2") == 0) {
        	pt_buf[i/2] = 0xC2;
        } else if (strcmp(byte, "C3") == 0) {
        	pt_buf[i/2] = 0xC3;
        } else if (strcmp(byte, "C4") == 0) {
        	pt_buf[i/2] = 0xC4;
        } else if (strcmp(byte, "C5") == 0) {
        	pt_buf[i/2] = 0xC5;
        } else if (strcmp(byte, "C6") == 0) {
        	pt_buf[i/2] = 0xC6;
        } else if (strcmp(byte, "C7") == 0) {
        	pt_buf[i/2] = 0xC7;
        } else if (strcmp(byte, "C8") == 0) {
        	pt_buf[i/2] = 0xC8;
        } else if (strcmp(byte, "C9") == 0) {
        	pt_buf[i/2] = 0xC9;
        } else if (strcmp(byte, "CA") == 0) {
        	pt_buf[i/2] = 0xCA;
        } else if (strcmp(byte, "CB") == 0) {
        	pt_buf[i/2] = 0xCB;
        } else if (strcmp(byte, "CC") == 0) {
        	pt_buf[i/2] = 0xCC;
        } else if (strcmp(byte, "CD") == 0) {
        	pt_buf[i/2] = 0xCD;
        } else if (strcmp(byte, "CE") == 0) {
        	pt_buf[i/2] = 0xCE;
        } else if (strcmp(byte, "CF") == 0) {
        	pt_buf[i/2] = 0xCF;
        } else if (strcmp(byte, "D0") == 0) {
        	pt_buf[i/2] = 0xD0;
        } else if (strcmp(byte, "D1") == 0) {
        	pt_buf[i/2] = 0xD1;
        } else if (strcmp(byte, "D2") == 0) {
        	pt_buf[i/2] = 0xD2;
        } else if (strcmp(byte, "D3") == 0) {
        	pt_buf[i/2] = 0xD3;
        } else if (strcmp(byte, "D4") == 0) {
        	pt_buf[i/2] = 0xD4;
        } else if (strcmp(byte, "D5") == 0) {
        	pt_buf[i/2] = 0xD5;
        } else if (strcmp(byte, "D6") == 0) {
        	pt_buf[i/2] = 0xD6;
        } else if (strcmp(byte, "D7") == 0) {
        	pt_buf[i/2] = 0xD7;
        } else if (strcmp(byte, "D8") == 0) {
        	pt_buf[i/2] = 0xD8;
        } else if (strcmp(byte, "D9") == 0) {
        	pt_buf[i/2] = 0xD9;
        } else if (strcmp(byte, "DA") == 0) {
        	pt_buf[i/2] = 0xDA;
        } else if (strcmp(byte, "DB") == 0) {
        	pt_buf[i/2] = 0xDB;
        } else if (strcmp(byte, "DC") == 0) {
        	pt_buf[i/2] = 0xDC;
        } else if (strcmp(byte, "DD") == 0) {
        	pt_buf[i/2] = 0xDD;
        } else if (strcmp(byte, "DE") == 0) {
        	pt_buf[i/2] = 0xDE;
        } else if (strcmp(byte, "DF") == 0) {
        	pt_buf[i/2] = 0xDF;
        } else if (strcmp(byte, "E0") == 0) {
        	pt_buf[i/2] = 0xE0;
        } else if (strcmp(byte, "E1") == 0) {
        	pt_buf[i/2] = 0xE1;
        } else if (strcmp(byte, "E2") == 0) {
        	pt_buf[i/2] = 0xE2;
        } else if (strcmp(byte, "E3") == 0) {
        	pt_buf[i/2] = 0xE3;
        } else if (strcmp(byte, "E4") == 0) {
        	pt_buf[i/2] = 0xE4;
        } else if (strcmp(byte, "E5") == 0) {
        	pt_buf[i/2] = 0xE5;
        } else if (strcmp(byte, "E6") == 0) {
        	pt_buf[i/2] = 0xE6;
        } else if (strcmp(byte, "E7") == 0) {
        	pt_buf[i/2] = 0xE7;
        } else if (strcmp(byte, "E8") == 0) {
        	pt_buf[i/2] = 0xE8;
        } else if (strcmp(byte, "E9") == 0) {
        	pt_buf[i/2] = 0xE9;
        } else if (strcmp(byte, "EA") == 0) {
        	pt_buf[i/2] = 0xEA;
        } else if (strcmp(byte, "EB") == 0) {
        	pt_buf[i/2] = 0xEB;
        } else if (strcmp(byte, "EC") == 0) {
        	pt_buf[i/2] = 0xEC;
        } else if (strcmp(byte, "ED") == 0) {
        	pt_buf[i/2] = 0xED;
        } else if (strcmp(byte, "EE") == 0) {
        	pt_buf[i/2] = 0xEE;
        } else if (strcmp(byte, "EF") == 0) {
        	pt_buf[i/2] = 0xEF;
        } else if (strcmp(byte, "F0") == 0) {
        	pt_buf[i/2] = 0xF0;
        }  else if (strcmp(byte, "F1") == 0) {
        	pt_buf[i/2] = 0xF1;
        } else if (strcmp(byte, "F2") == 0) {
        	pt_buf[i/2] = 0xF2;
        } else if (strcmp(byte, "F3") == 0) {
        	pt_buf[i/2] = 0xF3;
        } else if (strcmp(byte, "F4") == 0) {
        	pt_buf[i/2] = 0xF4;
        } else if (strcmp(byte, "F5") == 0) {
        	pt_buf[i/2] = 0xF5;
        } else if (strcmp(byte, "F6") == 0) {
        	pt_buf[i/2] = 0xF6;
        } else if (strcmp(byte, "F7") == 0) {
        	pt_buf[i/2] = 0xF7;
        } else if (strcmp(byte, "F8") == 0) {
        	pt_buf[i/2] = 0xF8;
        } else if (strcmp(byte, "F9") == 0) {
        	pt_buf[i/2] = 0xF9;
        } else if (strcmp(byte, "FA") == 0) {
        	pt_buf[i/2] = 0xFA;
        } else if (strcmp(byte, "FB") == 0) {
        	pt_buf[i/2] = 0xFB;
        } else if (strcmp(byte, "FC") == 0) {
        	pt_buf[i/2] = 0xFC;
        } else if (strcmp(byte, "FD") == 0) {
        	pt_buf[i/2] = 0xFD;
        } else if (strcmp(byte, "FE") == 0) {
        	pt_buf[i/2] = 0xFE;
        } else if (strcmp(byte, "FF") == 0) {
        	pt_buf[i/2] = 0xFF;
        } else {
        	printf("ERROR\n");
        }

        i+=2;
    }
}

#define MAXCHAR 1000
int main(int argc, const char **argv) {
	int result;

	//***** TO UPDATE *****
	int bits_per_block = 32;
	int instructions_per_block = bits_per_block / 32;
	int num_instructions = 7;
	int total_blocks = num_instructions / instructions_per_block;
	//int total_blocks = 7;
	//***** TO UPDATE *****

	char str[MAXCHAR];
	char block[MAXCHAR];

    FILE *fp1;
    FILE *fp2;
    FILE *fp3;
    FILE *fp4;

    //***** TO UPDATE *****
    char* filename1 = "C:\\Users\\j39950\\Desktop\\demo2\\demo2_imem_encrypted.hex";
    char* filename2 = "C:\\Users\\j39950\\Desktop\\demo2\\demo2_imem_signatures_ct.hex";
    char* filename3 = "C:\\Users\\j39950\\Desktop\\demo2\\demo2_imem_signatures_pt.hex";
    char* filename4 = "C:\\Users\\j39950\\Desktop\\demo2\\imem.hex";
    //***** TO UPDATE *****

    unsigned char* pt_buf   = malloc(4*instructions_per_block);
    unsigned char* ct_buf   = malloc(4*instructions_per_block);
    unsigned char* tag_buf  = malloc(16);
    unsigned char* ct2_buf  = malloc(4*instructions_per_block);
    unsigned char* tag2_buf = malloc(16);
    unsigned char* iv_buf   = malloc(12);

    fp1 = fopen(filename1, "w+");
    fp2 = fopen(filename2, "w+");
    fp3 = fopen(filename3, "w+");
    fp4 = fopen(filename4, "r");

    if (fp4 == NULL){
        printf("Could not open file %s",filename3);
        return 1;
    }

    int block_count = 0;
    int ic;
    char addr_str[25];
    int address = 0;

    int j, k;
    for (k = 0; k < total_blocks; k++) {
        memset(block, 0, MAXCHAR);
        sprintf(addr_str, "%024X", address);
        printf(addr_str);
        printf("\n");

        ic = 0;
        for (j = 0; j < instructions_per_block; j++) {
        	if (fgets(str, MAXCHAR, fp4) != NULL) {
        		ic++;
            	strncpy(block+(j*8), str, 9);
        	} else {
        		break;
        	}
        }
        //*(block+(j*8)) = '\n';
        printf(block);
        printf("\n");

        memset(pt_buf, 0, 4*instructions_per_block);
        memset(ct_buf, 0, 4*instructions_per_block);
        memset(tag_buf, 0, 16);
        memset(ct2_buf, 0, 4*instructions_per_block);
        memset(tag2_buf, 0, 16);
        memset(iv_buf, 0, 12);


        stringToCharArr(addr_str, iv_buf);
        printUnsgndCharArr(iv_buf, 12);
        //printUnsgndCharArr(t3_iv, 12);

        stringToCharArr(block, pt_buf);

        result = aes_gcm_ae(t3_key, sizeof(t3_key),
                            iv_buf, 12,
                            pt_buf, 4*ic,
                            t3_aad_2, sizeof(t3_aad_2),
                            ct_buf, tag_buf);

        result = aes_gcm_ae(t3_key, sizeof(t3_key),
                            iv_buf, 12,
                            ct_buf, 4*ic,
                            t3_aad_2, sizeof(t3_aad_2),
                            ct2_buf, tag2_buf);

       	printf("Block %d:\n", block_count);
        printUnsgndCharArr(pt_buf, 4*ic);
        printf("Ciphertext %d:\n", block_count);
        printUnsgndCharArr(ct_buf, 4*ic);
        printf("Ciphertext Tag %d:\n", block_count);
        printUnsgndCharArr(tag_buf, 16);
        //printUnsgndCharArr(ct2_buf, 4);
        printf("Plaintext Tag %d:\n", block_count);
        printUnsgndCharArr(tag2_buf, 16);
        printf("\n");

        printCipherTextToFile(fp1, ct_buf, 4*ic);
        printSignatureToFile(fp2, tag_buf, 16);
        printSignatureToFile(fp3, tag2_buf, 16);

        block_count++;
        address = address + (instructions_per_block*4);
    }

	fclose(fp1);
	fclose(fp2);
	fclose(fp3);
	fclose(fp4);
    return 0;
}
