# Green Hill CD
**WARNING: Right now, the code needs to be cleaned up, so don't expect it to be user-friendly at the moment.**

Green Hill ported over Palmtree Panic in the _Sonic CD_ Sega CD engine.

## Engine Changes
 - Chunks can now be stored anywhere within the MMD, rather than being hardcoded to **$210000**
 - Ported _Sonic 1_ object data format
 - Switched back over to Enigma-compressed blocks
 - Removed most _Sonic CD_ features for Sonic, except for the extended camera, as the original code was **insanely** hackish
