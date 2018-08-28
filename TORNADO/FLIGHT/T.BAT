flight %1 %2 %3 %4 %5 %6 %7 %8 %9

@echo off

echo.
echo 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

rem ***** SYSTEM ERRORS *****

if errorlevel 255 goto err_255
if errorlevel 254 goto err_254
if errorlevel 253 goto err_253
if errorlevel 252 goto err_252
if errorlevel 251 goto err_251
if errorlevel 250 goto err_250
if errorlevel 249 goto err_249
if errorlevel 248 goto err_248
if errorlevel 247 goto err_247
if errorlevel 246 goto err_246
if errorlevel 245 goto err_245
if errorlevel 244 goto err_244
if errorlevel 243 goto err_243
if errorlevel 242 goto err_242
if errorlevel 241 goto err_241
if errorlevel 240 goto err_240
if errorlevel 239 goto err_239
if errorlevel 238 goto err_238
if errorlevel 237 goto err_237
if errorlevel 236 goto err_236
if errorlevel 235 goto err_235
if errorlevel 234 goto err_234
if errorlevel 233 goto err_233
if errorlevel 232 goto err_232

rem ***** UNKNOWN CONDITION *****

if errorlevel 26 goto err_26

rem ***** END OF GAME CONDITIONS *****

if errorlevel 25 goto err_25
if errorlevel 24 goto err_24
if errorlevel 23 goto err_23
if errorlevel 22 goto err_22
if errorlevel 21 goto err_21
if errorlevel 20 goto err_20
if errorlevel 19 goto err_19
if errorlevel 18 goto err_18
if errorlevel 17 goto err_17
if errorlevel 16 goto err_16
if errorlevel 15 goto err_15
if errorlevel 14 goto err_14
if errorlevel 13 goto err_13
if errorlevel 12 goto err_12
if errorlevel 11 goto err_11
if errorlevel 10 goto err_10
if errorlevel 9 goto err_9
if errorlevel 8 goto err_8
if errorlevel 7 goto err_7
if errorlevel 6 goto err_6
if errorlevel 5 goto err_5
if errorlevel 4 goto err_4
if errorlevel 3 goto err_3
if errorlevel 2 goto err_2
if errorlevel 1 goto err_1 
if errorlevel 0 goto err_0

goto end

:err_0
echo DieFlag = 0: Non-game termination.
goto end

:err_1
echo DieFlag = 1: Quit game.
goto end

:err_2
echo DieFlag = 2: Hypoxia.
goto end

:err_3
echo DieFlag = 3: Aircraft break up due to excess buffeting.
goto end

:err_4
echo DieFlag = 4: Crashed into hill.
goto end

:err_5
echo DieFlag = 5: Crashed into ground.
goto end

:err_6
echo DieFlag = 6: Ditched.
goto end

:err_7
echo DieFlag = 7: Ground speed too high.
goto end

:err_8
echo DieFlag = 8: Crashed - sink rate too high.
goto end

:err_9
echo DieFlag = 9: Crashed - too much roll on landing.
goto end

:err_10
echo DieFlag = 10: Crashed - nose wheel collapsed on landing.
goto end

:err_11
echo DieFlag = 11: Crashed - tail scrape on landing.
goto end

:err_12
echo DieFlag = 12: Crashed - gear collapsed on landing.
goto end

:err_13
echo DieFlag = 13: Destroyed by fire.
goto end

:err_14
echo DieFlag = 14: Ejected.
goto end

:err_15
echo DieFlag = 15: Shot down by missile.
goto end

:err_16
echo DieFlag = 16: Shot down by cannon fire.
goto end

:err_17
echo DieFlag = 17: Shot down by SAM.
goto end

:err_18
echo DieFlag = 18: Shot down by AAA.
goto end

:err_19
echo DieFlag = 19: Destroyed by ground explosion.
goto end

:err_20
echo DieFlag = 20: Destroyed by air explosion.
goto end

:err_21
echo DieFlag = 21: Crashed into ground object.
goto end

:err_22
echo DieFlag = 22: Crashed into mobile object.
goto end

:err_23
echo DieFlag = 23: Two player win.
goto end

:err_24
echo DieFlag = 24: Two player draw.
goto end

:err_25
echo DieFlag = 25: Two player lose.
goto end

:err_26
echo ***** DieFlag not recognised *****
goto end

:err_232
echo DieFlag = 232: System error - music card not present.
goto end

:err_233
echo DieFlag = 233: System error - error occurred loading music driver.
goto end

:err_234
echo DieFlag = 234: System error - error occurred allocating mem for music driver.
goto end

:err_235
echo DieFlag = 235: System error - comms sync timeout / user abort.
goto end

:err_236
echo DieFlag = 236: System error - global timeout.
goto end

:err_237
echo DieFlag = 237: System error - error occurred loading MISCDATA.IN.
goto end

:err_238
echo DieFlag = 238: System error - error occurred saving IMPACT.OUT.
goto end

:err_239
echo DieFlag = 239: System error - error occurred loading PREVIEW.BT2.
goto end

:err_240
echo DieFlag = 240: System error - error occurred loading digitized picture.
goto end

:err_241
echo DieFlag = 241: System error - sound card not present.
goto end

:err_242
echo DieFlag = 242: System error - error occurred loading sound driver.
goto end

:err_243
echo DieFlag = 243: System error - error occurred allocating mem for sound driver.
goto end

:err_244
echo DieFlag = 244: System error - error occurred resizing memory.
goto end

:err_245
echo DieFlag = 245: System error - Map test completed ok.
goto end

:err_246
echo DieFlag = 246: System error - error occurred saving MSECDEF.OUT.
goto end

:err_247
echo DieFlag = 247: System error - error occurred loading MSECDEF.IN.
goto end

:err_248
echo DieFlag = 248: System error - error occurred saving OBSECDEF.OUT.
goto end

:err_249
echo DieFlag = 249: System error - error occurred loading OBSECDEF.IN.
goto end

:err_250
echo DieFlag = 250: System error - error occurred loading LAYER.IN.
goto end

:err_251
echo DieFlag = 251: System error - error occurred saving GAMEPLAY.OUT.
goto end

:err_252
echo DieFlag = 252: System error - error occurred loading GAMEPLAY.IN.
goto end

:err_253
echo DieFlag = 253: System error - error occurred loading palette RGB data.
goto end

:err_254
echo DieFlag = 254: System error - error occurred loading panel data.
goto end

:err_255
echo DieFlag = 255: System error - mouse driver not present.
goto end

:end

echo 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
echo.

