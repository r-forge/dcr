@echo off
echo.
echo dclone tests
echo.
cd \svn\dcr\devel\tests
echo.
echo build source package
echo.
R CMD build "c:/svn/dcr/pkg/dclone"
echo.
echo build binary package
echo.
R CMD build "c:/svn/dcr/pkg/dclone" --binary
echo.
echo install source package
echo.
R CMD INSTALL dclone_1.3-6.tar.gz
echo.
echo check package
echo.
R CMD check "c:/svn/dcr/pkg/dclone" --outdir="c:/svn/dcr/devel/tests/"
echo.
echo.
echo run dontrun examples
echo.
R CMD BATCH --vanilla "c:/svn/dcr/devel/dctests.R" "c:/svn/dcr/devel/tests/dctests.log"
echo.
echo done
exit
