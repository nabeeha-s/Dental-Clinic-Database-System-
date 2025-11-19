#!/bin/sh
#export LD_LIBRARY_PATH=/usr/lib/oracle/12.1/client64/lib

sqlplus64 "nsaniyat/05163393@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=oracle12c.scs.ryerson.ca)(Port=1521))(CONNECT_DATA=(SID=orcl12c)))" <<EOF

DBMS_OUTPUT.PUT_LINE('Data already populated in create_tables.sh via Oracle12c.sql');

COMMIT;
EXIT;
EOF