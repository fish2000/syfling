//
//  main.m
//  syfling
//
//  Created by FI$H 2000 on 4/12/15.
//  Copyright (c) 2015 Objects In Space And Time. All rights reserved.
//

#include <iostream>
#include <string>
#include <cstdio>
#include <cstring>
#include <sysexits.h>
#include <getopt.h>

#include "filesystem/path.h"
#include "filesystem/resolver.h"

using namespace filesystem;

static double const AppVersion = 1.0;

static void version()
{
    fprintf(stdout, "%1$s %2$.1f (WHENEVER)\n", getprogname(), AppVersion);
}

static void usage(FILE* io = stdout)
{
    fprintf(io,
            "%1$s %2$.1f (WHENEVER)\n"
            "Usage: %1$s [-hv] ...\n"
            "Options:\n"
            " -h, --help                Show this information.\n"
            " -v, --version             Print version information.\n"
            "\n", getprogname(),        AppVersion
            );
}

static void syfling(std::string const& pth)
{
    path p(pth);
    CF::URL url = CF::URL::FileSystemURL(pth);
    CF::String imtype;
    CGImageRef image;
    CGImageSourceRef cfsrc;

    if (p.is_file()) {
        cfsrc = CGImageSourceCreateWithURL(url, NULL);
        image = CGImageSourceCreateImageAtIndex(cfsrc, 0, NULL);
        imtype = CGImageSourceGetType(cfsrc);

        std::cout << "IMAGE: "  <<  pth  <<  std::endl
                  << "\t"       <<  "("  <<  imtype     <<   ")"  <<  std::endl;

    }
}

int main (int argc, char* const* argv)
{
    @autoreleasepool {
        extern int optind;

        static struct option const longopts[] = {
            { "help",             no_argument,         0,      'h'   },
            { "version",          no_argument,         0,      'v'   },
            { 0,                  0,                   0,      0     }
        };

        int ch;
        while((ch = getopt_long(argc, argv, "hv", longopts, NULL)) != -1)
        {
            switch(ch)
            {
                case 'h': usage();             return EX_OK;
                case 'v': version();           return EX_OK;
                default:  usage(stderr);       return EX_USAGE;
            }
        }

        argc -= optind;
        argv += optind;

        if(argc == 0)
        {
            usage(); return EX_OK;
        }
        else
        {
            for(int i = 0; i < argc; ++i) { syfling(path::join(path::cwd(), argv[i])); }
        }
        
        return EX_OK;
    }
}
