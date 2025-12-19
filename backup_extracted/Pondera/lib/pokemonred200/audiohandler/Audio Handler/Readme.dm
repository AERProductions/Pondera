/******************************************************
********************AUDIO HANDLER**********************
* This Library was made by me to manage all sounds in *
* all of my BYOND games. It's really simple to use.   *
* To use it, simply add it to your player definition  *
* or client definition and assign it. As such:        *
*                                                     *
*                                                     *
*                                                     *
* mob                                                 *
*	New()                                             *
*		Audio.owner = src                             *
*	var                                               *
*		audiohandler/Audio=new                        *
*Or, you can do:                                      *
* client                                              *
*	New()                                             *
*		Audio.owner = mob                             *
*	var                                               *
*		audiohandler/Audio=new                        *
*                                                     *
*                                                     *
*                                                     *
*Then, simply call the Audio object's procs to use the*
*object.                                              *
*                                                     *
*                                                     *
*                                                     *
*You will need to give each sound a unique ID to      *
*access them with the audiohandler object, unless you *
*redefine any of the audiohandler's procs yourself.   *
*******************************************************/