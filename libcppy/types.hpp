#pragma once

#include <stddef.h>
#include <stdint.h>

typedef void VOID;

typedef int8_t I8;
typedef int16_t I16;
typedef int32_t I32;
typedef int64_t I64;

typedef uint8_t U8;
typedef uint16_t U16;
typedef uint32_t U32;
typedef uint64_t U64;

typedef U8 BOOL;
#define TRUE 1
#define FALSE 0

#if defined(__FLT16_MANT_DIG__) && (!defined(__clang_major__) || __clang_major__ >= 15)
typedef _Float16 F16;
#endif
typedef float F32;
typedef double F64;

typedef char C8;

#if SIZE_MAX == UINT32_MAX
typedef U32 UW;
typedef I32 IW;
#define UW_MAX 0xFFFFFFFFU
#elif SIZE_MAX == UINT64_MAX
typedef U64 UW;
typedef I64 IW;
#define UW_MAX 0xFFFFFFFFFFFFFFFFULL
#else
#error "unsupported size_t size"
#endif
