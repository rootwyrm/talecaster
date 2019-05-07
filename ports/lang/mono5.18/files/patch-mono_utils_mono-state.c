--- mono/utils/mono-state.c.orig   2019-02-15 17:39:41.880483000 +0000
+++ mono/utils/mono-state.c        2019-02-15 17:40:17.080418000 +0000
@@ -11,7 +11,9 @@
 #ifndef DISABLE_CRASH_REPORTING

 #include <config.h>
-#include <glib.h>
+/* #include <glib.h> */
+#include <sys/types.h>
+#include <sys/stat.h>
 #include <mono/utils/mono-state.h>
 #include <mono/utils/mono-threads-coop.h>
 #include <mono/metadata/object-internals.h>

