/*
    A plain C++ translation unit. It has never heard of cppy: it includes
    a header and links an object file, as it would with any library.
*/

#include <stdio.h>

#include "api.hpp"

int main()
{
        VEC2 v = {3.0, 4.0};
        VEC2 scaled = Scaled(v);

        printf("dot(v, v)   = %.1f\n", v.Dot(v));
        printf("scaled      = (%.1f, %.1f)\n", scaled.x, scaled.y);
        printf("ScaleFactor = %.1f\n", ScaleFactor);
        printf("Twice(21)   = %d\n", Twice(21));
        return 0;
}
