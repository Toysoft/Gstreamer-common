dnl pkg-config-based checks for GStreamer modules and dependency modules

dnl generic:
dnl GST_PKG_CHECK_MODULES([PREFIX], [WHICH], [REQUIRED])
dnl sets HAVE_[$PREFIX], [$PREFIX]_*
dnl GST_CHECK_MODULES([PREFIX], [MODULE], [MINVER], [NAME], [REQUIRED])
dnl sets HAVE_[$PREFIX], [$PREFIX]_*

dnl specific:
dnl GST_CHECK_GST([MAJMIN], [MINVER], [REQUIRED])
dnl   also sets/ACSUBSTs GST_TOOLS_DIR and GST_PLUGINS_DIR
dnl GST_CHECK_GST_BASE([MAJMIN], [MINVER], [REQUIRED])
dnl GST_CHECK_GST_GDP([MAJMIN], [MINVER], [REQUIRED])
dnl GST_CHECK_GST_CONTROLLER([MAJMIN], [MINVER], [REQUIRED])
dnl GST_CHECK_GST_CHECK([MAJMIN], [MINVER], [REQUIRED])
dnl GST_CHECK_GST_PLUGINS_BASE([MAJMIN], [MINVER], [REQUIRED])
dnl   also sets/ACSUBSTs GSTPB_PLUGINS_DIR

AC_DEFUN([GST_PKG_CHECK_MODULES],
[
  which="[$2]"
  dnl not required by default, since we use this mostly for plugin deps
  required=ifelse([$3], , "no", [$3])

  PKG_CHECK_MODULES([$1], $which,
    [
      HAVE_[$1]="yes"
    ],
    [
      HAVE_[$1]="no"
      AC_MSG_RESULT(no)
      if test "x$required" = "xyes"; then
        AC_MSG_ERROR($[$1]_PKG_ERRORS)
      else
        AC_MSG_NOTICE($[$1]_PKG_ERRORS)
      fi
    ])

  dnl AC_SUBST of CFLAGS and LIBS was not done before automake 1.7
  dnl It gets done automatically in automake >= 1.7, which we now require
]))

AC_DEFUN([GST_CHECK_MODULES],
[
  module=[$2]
  minver=[$3]
  name="[$4]"
  required=ifelse([$5], , "yes", [$5]) dnl required by default

  PKG_CHECK_MODULES([$1], $module >= $minver,
    [
      HAVE_[$1]="yes"
    ],
    [
      HAVE_[$1]="no"
      AC_MSG_RESULT(no)
      AC_MSG_NOTICE($[$1]_PKG_ERRORS)
      if test "x$required" = "xyes"; then
        AC_MSG_ERROR([no $module >= $minver ($name) found])
      else
        AC_MSG_NOTICE([no $module >= $minver ($name) found])
      fi
    ])

  dnl AC_SUBST of CFLAGS and LIBS was not done before automake 1.7
  dnl It gets done automatically in automake >= 1.7, which we now require
]))

AC_DEFUN([GST_CHECK_GST],
[
  GST_CHECK_MODULES(GST, gstreamer-[$1], [$2], [GStreamer], [$3])
  GST_TOOLS_DIR=`$PKG_CONFIG --variable=toolsdir gstreamer-[$1]`
  if test -z $GST_TOOLS_DIR; then
    AC_MSG_ERROR(
      [no tools dir set in GStreamer pkg-config file; core upgrade needed.])
  fi
  AC_SUBST(GST_TOOLS_DIR)

  dnl check for where core plug-ins got installed
  dnl this is used for unit tests
  GST_PLUGINS_DIR=`$PKG_CONFIG --variable=pluginsdir gstreamer-[$1]`
  if test -z $GST_PLUGINS_DIR; then
    AC_MSG_ERROR(
      [no pluginsdir set in GStreamer pkg-config file; core upgrade needed.])
  fi
  AC_SUBST(GST_PLUGINS_DIR)
])

AC_DEFUN([GST_CHECK_GST_BASE],
[
  GST_CHECK_MODULES(GST_BASE, gstreamer-base-[$1], [$2],
    [GStreamer Base Libraries], [$3])
])
  
AC_DEFUN([GST_CHECK_GST_GDP],
[
  GST_CHECK_MODULES(GST_GDP, gstreamer-dataprotocol-[$1], [$2],
    [GStreamer Data Protocol Library], [$3])
])
  
AC_DEFUN([GST_CHECK_GST_CONTROLLER],
[
  GST_CHECK_MODULES(GST_CONTROLLER, gstreamer-controller-[$1], [$2],
    [GStreamer Controller Library], [$3])
])  

AC_DEFUN([GST_CHECK_GST_CHECK],
[
  GST_CHECK_MODULES(GST_CHECK, gstreamer-check-[$1], [$2],
    [GStreamer Check unittest Library], [$3])
])

AC_DEFUN([GST_CHECK_GST_PLUGINS_BASE],
[
  GST_CHECK_MODULES(GST_PLUGINS_BASE, gstreamer-plugins-base-[$1], [$2],
    [GStreamer Base Plug-ins Library], [$3])

  dnl check for where base plug-ins got installed
  dnl this is used for unit tests
  GSTPB_PLUGINS_DIR=`$PKG_CONFIG --variable=pluginsdir gstreamer-plugins-base-[$1]`
  if test -z $GSTPB_PLUGINS_DIR; then
    AC_MSG_ERROR(
      [no pluginsdir set in GStreamer Base Plug-ins pkg-config file])
  fi
  AC_SUBST(GSTPB_PLUGINS_DIR)
])
