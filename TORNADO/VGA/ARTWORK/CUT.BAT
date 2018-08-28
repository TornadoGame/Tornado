if "%2" == "" goto onefile

vgacut %1.lbm %2.bt2 /b

goto end

:onefile

vgacut %1.lbm %1.bt2 /b

:end

