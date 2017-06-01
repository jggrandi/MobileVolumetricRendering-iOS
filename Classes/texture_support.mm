/*
 *  texture_support.cpp
 *  Volume
 *
 *  Created by Henrique Debarba on 25/10/2010.
 *
 */

#include "texture_support.h"
#include <stdio.h>
#include <stdlib.h>


GLuint loadTexture(NSString *inFileName, int inWidth, int inHeight) {
	glEnable(GL_TEXTURE_2D);
	//glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);  
	GLuint texture;
	glGenTextures(1, &texture);
	glBindTexture(GL_TEXTURE_2D, texture);
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); 
//	glBlendFunc(GL_ONE, GL_SRC_COLOR);
	
	NSString *extension = [inFileName pathExtension];
	NSString *baseFilenameWithExtension = [inFileName lastPathComponent];
	NSString *baseFilename = [baseFilenameWithExtension substringToIndex:[baseFilenameWithExtension length] - [extension length] - 1];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:baseFilename ofType:extension];
	NSData *texData = [[NSData alloc] initWithContentsOfFile:path];
	
	// Assumes pvr4 is RGB not RGBA, which is how texturetool generates them
	if ([extension isEqualToString:@"pvr4"])
		glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG, inWidth, inHeight, 0, (inWidth * inHeight) / 2, [texData bytes]);
	else if ([extension isEqualToString:@"pvr2"])
		glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG, inWidth, inHeight, 0, (inWidth * inHeight) / 2, [texData bytes]);
	else
	{
		UIImage *image = [[UIImage alloc] initWithData:texData];
	
		if (image == nil)
			return 0;
//		CFDataRef imgData = (CFDataRef)texData;
//		CGDataProviderRef imgDataProvider = CGDataProviderCreateWithCFData (imgData);
		//CGImageRef image = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
//		CGColorSpaceRef colorSpace2 = CGColorSpaceCreateDeviceGray();
//		GLuint width = 128;
//		GLuint height = 2048;
//		CGImageRef imageRef = CGImageCreate(width, height, 16, 16, 2*width, colorSpace2,kCGBitmapByteOrder16Big, imgDataProvider, NULL, 0, kCGColorSpaceModelMonochrome);
		
		GLuint width = CGImageGetWidth(image.CGImage);
		GLuint height = CGImageGetHeight(image.CGImage);


		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		
		char *imageData = (char*) malloc( height * width * 4 );
		CGContextRef context = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaNoneSkipLast |/*kCGImageAlphaPremultipliedLast |*/ kCGBitmapByteOrder32Big );

//		unsigned short *imageData = malloc( height * width *16);
//		CGContextRef context = CGBitmapContextCreate( imageData, width, height, 16, 2 * width, colorSpace2, kCGImageAlphaNone | kCGBitmapByteOrder16Big/*kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big*/ );

		CGColorSpaceRelease( colorSpace );
		CGContextClearRect( context, CGRectMake( 0, 0, width, height ) );
		CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), image.CGImage );
//		CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), imageRef );		
		/*glGenTextures(1, &textureID);
		glBindTexture(GL_TEXTURE_2D, textureID);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);*/
		//glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
		
		float *imageData2 = (float*)malloc( sizeof(float) * height * width);

		float menorvalor=9999;
		float maiorvalor=0;
		for (int i=0; i< height * width ; i++){
			//if (imageData[i*4+1]<-5 || imageData[i*4+1]>1)
			//	imageData[i*4+1]=0;
			float aux =	(float)imageData[i*4+1];
//			if (aux<1)
//			aux =	aux/3.0f;
	/*		if (imageData[i*4+1]==-8)
				aux =	aux+5;
			if (imageData[i*4+1]==-7)
				aux =	aux+5;
			if (imageData[i*4+1]==-5)
				aux =	aux+5;
			if (imageData[i*4+1]==-6)
				aux =	aux+5;
	*/		imageData2[i]= ((float)imageData[i*4])+(aux)*256.0f;
			
	//		imageData2[i]= ((float)imageData[i*4])+((float)imageData[i*4+1])*256.0f;
			//imageData2[i]=imageData2[i]*-1.0f;
			if (imageData2[i]<menorvalor)
				menorvalor=imageData2[i];
			if (imageData2[i]>maiorvalor)
				maiorvalor=imageData2[i];
			//mediump float temp = texture2D(texture,texcoord.xy).y;
			//temp= (1.0-temp) * 256.0;
			//imageData2[i]=imageData2[i]-1144.0;
			//imageData2[i]=-(imageData2[i]);
			//texCol.x = (texCol.x  + temp)/256.0;
			
		}
		menorvalor=menorvalor;
		maiorvalor=maiorvalor;
		float minValue = -1024.0;
		float maxValue = 3071.0;
		for (int i=0; i< height * width ; i++){
			//imageData2[i]-=1000;
			imageData2[i]= (imageData2[i] - minValue)/(maxValue-minValue);
			if (imageData2[i]<0.0f)
				imageData2[i]=0.0f;
			if (imageData2[i]>1.0f )
				imageData2[i]=1.0f;
			//imageData2[i] = 1.0f - imageData2[i];
			//mediump float temp = texture2D(texture,texcoord.xy).y;
			//temp= (1.0-temp) * 256.0;
			
			//texCol.x = (texCol.x  + temp)/256.0;
		}
		
		glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, width, height, 0, GL_LUMINANCE,  GL_FLOAT /*GL_UNSIGNED_SHORT*/, imageData2);
		
		glGenerateMipmap(GL_TEXTURE_2D);
		//glGenerateMipmapEXT(GL_TEXTURE_2D);  //Generate mipmaps now!!!
		//GLuint errorcode = glGetError();
		CGContextRelease(context);
		
		free(imageData);
		[image release];
	}
	return texture;
}

GLuint loadRAWTexture(NSString *inFileName, int inWidth, int inHeight, int inDepth) {
	
	short **imageData;
	//char **imageData;
	FILE* inFile;
	int width = inWidth;
	int height = inHeight;
	int depth = inDepth;
	
	// allocate memory for the image matrix
	imageData = (short**)malloc((depth) * sizeof(short*));
	for (int i=0; i < depth; i++)
		imageData[i] = (short*)malloc(sizeof(short) * width * height);
	
/*    imageData = (char**)malloc((depth) * sizeof(char*));
	for (int i=0; i < depth; i++)
		imageData[i] = (char*)malloc(sizeof(char) * width * height);
*/
	int widthxheight = width*height;
	//inFileName
	if( inFile = fopen( [inFileName cStringUsingEncoding:1], "r" )  ){
		// read file into image matrix
		for( int i = 0; i < depth; i++ ){
			for( int j = 0; j < widthxheight; j++ ){
				short value;
				fread( &value, 1, sizeof(short), inFile );
				//char value;
				//fread( &value, 1, sizeof(char), inFile );
				imageData[i][j] = value;
			}
		}
		fclose(inFile);
	}else {
		abort();
	}

	float *textureData;
    int supportedSize;// = 4096;
    glGetIntegerv(GL_MAX_TEXTURE_SIZE, &supportedSize);
	//int texWidth = 2048;
	//int texHeight = 2048;
	int texWidth = supportedSize;
	int texHeight = supportedSize;
	
	// allocate memory for the image matrix
	textureData = (float*)malloc(sizeof(float) * texWidth * texHeight);
	
	float minValue = -1024.0;
	float maxValue = 3071.0;

	for (int i=0; i< texHeight * texWidth ; i++){
		textureData[i]=0.0f;
	}

    int octaveSupSize = supportedSize/8;
    int stepSize = (width*8)/supportedSize;
	for( int i = 0; i < depth; i++ ){
		for( int j = 0; j < widthxheight; j+=stepSize ){
			//int j2 = j/2;
			//int coord = ((i/8)*256+((j/512)/2))*2048 + (i%8)*256 + ((j%512)/2);
			int coord = ((i/8)*octaveSupSize+(j/width)/stepSize)*supportedSize + (i%8)*octaveSupSize + ((j%width)/stepSize);
			textureData[coord] = ((float)imageData[i][j] - minValue)/(maxValue-minValue);
			if (textureData[coord] < 0.0f)
				textureData[coord] = 0.0f;
			if (textureData[coord] > 1.0f )
				textureData[coord] = 1.0f;
		}
	}
 
/*
    int octaveSupSize = supportedSize/16;
    int stepSize = (width*16)/supportedSize;
	for( int i = 0; i < depth; i++ ){
		for( int j = 0; j < widthxheight; j+=stepSize ){
			//int j2 = j/2;
			//int coord = ((i/8)*256+((j/512)/2))*2048 + (i%8)*256 + ((j%512)/2);
			int coord = ((i/16)*octaveSupSize+(j/width)/stepSize)*supportedSize + (i%16)*octaveSupSize + ((j%width)/stepSize);
			textureData[coord] = ((float)imageData[i][j] - minValue)/(maxValue-minValue);
			if (textureData[coord] < 0.0f)
				textureData[coord] = 0.0f;
			if (textureData[coord] > 1.0f )
				textureData[coord] = 1.0f;
		}
	}
*/
/*	float *textureData;
	int texWidth = 512;
	int texHeight = 512;
	
	// allocate memory for the image matrix
	textureData = (float*)malloc(sizeof(float) * texWidth * texHeight);
	
	float minValue = -1024.0;
	float maxValue = 3071.0;
	
	for (int i=0; i< texHeight * texWidth ; i++){
		textureData[i]=0.0f;
	}
	for( int i = 0; i < depth; i++ ){
		for( int j = 0; j < widthxheight; j+=8 ){
			//int j2 = j/2;
			int coord = ((i/8)*64+((j/512)/8))*512 + (i%8)*64 + ((j%512)/8);
			int coord = ((i/8)*64+((j/512)/8))*512 + (i%8)*64 + ((j%512)/8);
			textureData[coord] = ((float)imageData[i][j] - minValue)/(maxValue-minValue);
			if (textureData[coord] < 0.0f)
				textureData[coord] = 0.0f;
			if (textureData[coord] > 1.0f )
				textureData[coord] = 1.0f;
		}
	}
	*/
	glEnable(GL_TEXTURE_2D);
	//glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);  
	GLuint texture;
	glGenTextures(1, &texture);
	glBindTexture(GL_TEXTURE_2D, texture);
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); 
	//	glBlendFunc(GL_ONE, GL_SRC_COLOR);
	
		
	glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, texWidth, texHeight, 0, GL_LUMINANCE,  GL_FLOAT /*GL_UNSIGNED_SHORT*/, textureData);
		
	glGenerateMipmap(GL_TEXTURE_2D);

	return texture;
}
