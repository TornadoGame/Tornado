DECLARE SUB Cyclic (x1%, y1%, x2%, y2%, x3%, y3%)

SCREEN 12

WINDOW (-8192, 8191)-(8191, -8192)

KEY(11) ON
KEY(12) ON
KEY(13) ON
KEY(14) ON

ON KEY(11) GOSUB UpKey
ON KEY(12) GOSUB LtKey
ON KEY(13) GOSUB RtKey
ON KEY(14) GOSUB DnKey

px% = 500
py% = 500

DO

update% = 0

CLS

LINE (-8192, 0)-(8191, 0), 12, , -21846
LINE (0, 8191)-(0, -8192), 12, , -21846

CALL Cyclic(0, 4000, 4000, 0, px%, py%)
CALL Cyclic(4000, 0, 0, -4000, px%, py%)
CALL Cyclic(0, -4000, -4000, 0, px%, py%)
CALL Cyclic(-4000, 0, 0, 4000, px%, py%)

LINE (px% - 100, py%)-(px% + 100, py%)
LINE (px%, py% - 100)-(px%, py% + 100)

WHILE update% = 0
WEND

LOOP

STOP

UpKey:
py% = py% + 100
update% = 1
RETURN

DnKey:
py% = py% - 100
update% = 1
RETURN

LtKey:
px% = px% - 100
update% = 1
RETURN

RtKey:
px% = px% + 100
update% = 1
RETURN

END

SUB Cyclic (x1%, y1%, x2%, y2%, x3%, y3%)
'
LINE (x1%, y1%)-(x2%, y2%), 10

dx1& = x1% - x2%
dy1& = y1% - y2%
dx2& = x2% - x3%
dy2& = y2% - y3%

result& = (dx2& * dy1&) - (dx1& * dy2&)

IF result& < 0 THEN
   PRINT "FAIL: ";
ELSE
   PRINT "PASS: ";
END IF

PRINT result&

END SUB

