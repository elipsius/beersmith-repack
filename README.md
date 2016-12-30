# beersmith-repack
using alien did not repack the deb package correctly so I had to make some hacky correction but it works

I am not affiliated with beersmith.com or it's creator, this is just a repackage suite of scripts created to repack the deb file they provide to rpm.  I don't promise it will work correctly all the time please feel free to modify as needed. 

obtain beersmith deb package from here: http://beersmith.com/download-beersmith/

to repack the to an rpm replace the dummy file in the DEBPACKAGE folder with an official one from the site and then run:
* make all
