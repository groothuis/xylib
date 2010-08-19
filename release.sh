
VERSION=0.7

if [ $# -eq 0 ]; then
    echo Usage: $0 step
    echo Steps to prepare a new release:
    echo 0. check version numbers and soname
    echo 1. test compilation
    echo 2. make tarball
    echo 3. make Windows binaries
    echo 4. prepare RPMs in OBS
    echo 5. prepare DEBs in Launchpad
    echo 6. SourceForge file release
    echo 7. update webpage
    echo 8. announce at FreshMeat
    exit
fi

arg=$1

# 0. check version numbers and soname
if [ $arg -eq 0 ]; then
    echo version: $VERSION
    echo in xylib/xylib.h:
    grep 'define XYLIB_VERSION' xylib/xylib.h
    echo in README:
    grep '.tar.bz2' README
    grep '.zip' README
    echo in xylib/Makefile.am:
    grep 'version-info' xylib/Makefile.am
    echo in xylib_capi.py:
    grep LoadLibrary xylib_capi.py
    echo in README:
    grep "\* $VERSION" README
    echo svnversion: `svnversion`
fi

# 1. test compilation from svn
if [ $arg -eq 1 ]; then
    rm -rf svn_copy
    mkdir svn_copy
    cd svn_copy
    svn co https://xylib.svn.sourceforge.net/svnroot/xylib/trunk xylib
    cd xylib
    autoreconf -i || exit 1
    ./configure --prefix=`pwd`/install_dir --disable-static || exit 1
    make dist-bzip2 || exit 1
    make || exit 1
    mkdir install_dir
    make install || exit
    install_dir/bin/xyconv -v || exit 1
    cd .. # svn_copy
    tar xjf xylib/xylib-*.tar.bz2
    cd xylib-*
    ./configure --disable-shared && make || exit
fi

# 2. make tarball
if [ $arg -eq 2 ]; then
    mv svn_copy/xylib/xylib-*.tar.bz2 . && echo OK
    #make dist-bzip2
fi

# 3. make Windows binaries 
if [ $arg -eq 3 ]; then
    mkdir -p xylib_win-$VERSION/docs
    cp -r svn_copy/xylib/install_dir/include/xylib/ xylib_win-$VERSION
    make index.html
    cp index.html README.dev TODO COPYING sample-urls xylib_win-$VERSION/docs
    echo copy files xylib.dll and xyconv.exe to `pwd`/xylib_win-$VERSION
    echo and do:  zip -r xylib_win-$VERSION.zip xylib_win-$VERSION/

fi

# 4. prepare RPMs in OBS
if [ $arg -eq 4 ]; then
    echo TODO
fi

# 5. prepare DEBs in Launchpad
if [ $arg -eq 5 ]; then
    echo TODO
fi

# 6. SourceForge file release
if [ $arg -eq 6 ]; then
scp xylib-$VERSION.tar.bz2 xylib_win-$VERSION.zip `whoami`,xylib@frs.sourceforge.net:/home/frs/project/x/xy/xylib/
echo add new release:
echo https://sourceforge.net/project/admin/explorer.php?group_id=204287
fi

# 7. update webpage
if [ $arg -eq 7 ]; then
    make index.html
    scp index.html `whoami`,xylib@web.sourceforge.net:htdocs/
fi

# 8. announce at FreshMeat
if [ $arg -eq 8 ]; then
    grep -5 "\* $VERSION" README | tail -6
    echo
    echo http://freshmeat.net/projects/xylib/releases/new
fi

# 102. make Windows static lib for linking with fityk
if [ $arg -eq 102 ]; then
    rm -rf mingw32
    mkdir mingw32
    cd mingw32
    MDIR=$HOME/local/mingw32msvc
    ../configure --host=i586-mingw32msvc --enable-static --disable-shared \
	         CPPFLAGS="-I$HOME/local/src/boost_1_42_0/ -I$MDIR/include/" \
		 CXXFLAGS="-O3" LDFLAGS="-s -L$MDIR/lib" --without-bzlib \
		 --prefix=$MDIR && \
    make install
fi
