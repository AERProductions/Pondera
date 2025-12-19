
// File:    _flags.dm
// Library: Forum_account.Sidescroller
// Author:  Forum_account
//
// Contents:
//   This file contains descriptions of all compile-time flags the
//   library provides to customize its features. These flags change
//   the code that gets compiled. By excluding features at compile
//   time you improve performance at runtime.
//
//   To use these flags you must define them before the library's code
//   is compiled. There are two ways to do this:
//
//     1. Put the #define statements you need in this file and recompile
//        the library.
//     2. Open the .dme file of the project that references the library
//        and add the necessary #define statements to the top of that
//        .dme file.
//
//   The first method is easiest but forces all projects referencing
//   the library to use the same settings. The second method defines
//   the flags in the project using the library so it's more flexible.


// Enabling the LIBRARY_DEBUG flag (by uncommenting the #define line)
// will enable the library's debugging features (mob.start_trace, debug
// statpanel). The SIDESCROLLER_DEBUG var exists whether the flag is
// set or not, but the statpanel will only appear if the flag is set.
//
// The reason to have this flag is that enabling it will actually change
// the DM code that gets compiled. Many of the movement procs check
// "if(trace)" to see if the debugging trace is enabled - these checks
// take time (not much, but it adds up). By having this flag not set you're
// removing these checks from the code.
#define LIBRARY_DEBUG


// Commenting out this definition removes support for the stepped_on,
// stepped_off, and stepping_on procs. If you don't use these procs,
// disabling them will improve performance.
#define STEPPED_ON
