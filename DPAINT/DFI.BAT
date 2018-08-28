echo off
if %3. == .  goto usage
if exist \dfi\disk%1\x1%1%2.dfi  goto okay

echo -- ***** DIGI-FONT file  \dfi\disk%1\x1%1%2.dfi  NOT FOUND. *****
echo --
echo --

:usage
echo -- Before running DFI, you must install a DIGI-FONT (tm) font disk.
echo -- (Available as a separate product from DIGI-FONTS, Inc.)
echo --
echo --
echo -- Usage: dfi DD X FONTNAME
echo -- Where "DD" is the DIGI-FONT disk #.  Note: Must be "01" for #1,
echo --   "02" for #2.  Don't enter just one digit.
echo -- "X" is the font #1 thru 8 on that disk.
echo -- "FONTNAME" is whatever name you choose for the font, up to 8 letters.
echo --   DO NOT put blanks in the name.
echo --
echo -- Example: "dfi 01 3" loads from disk #01, the font #3.
echo -- Digi-font calls this font 1013.
goto end

:okay
echo -- Creating font 1%1%2 (from disk #%1, font #%2) in sizes 24 through 96.
echo --
echo -- You have assigned the name  %3  to the font.
echo -- This name will appear in the Choose Font dialog when Monochrome
echo -- is selected.
echo --
echo -- This takes up to 10 minutes, depending on cpu speed.
echo --
echo -- You may abort at any time by pressing CTRL-C or BREAK.
echo -- When aborting on some computers,
echo -- the current font will be finished before the computer
echo -- asks if you want to "Terminate batch job".
echo -- At that time, press the "y" key, then the "Enter" key.
echo --
echo -- If you abort, the fonts created up to that point will be available --
echo -- the last font created may be garbled; it should not be used.
echo --
echo on
digifont\soft -ap60 -rx21-x7f \dfi\disk%1\x1%1%2.dfi -omonofont\%3.m24
digifont\soft -ap90 -rx21-x7f \dfi\disk%1\x1%1%2.dfi -omonofont\%3.m36
digifont\soft -ap120 -rx21-x7f \dfi\disk%1\x1%1%2.dfi -omonofont\%3.m48
digifont\soft -ap140 -rx21-x7f \dfi\disk%1\x1%1%2.dfi -omonofont\%3.m56
digifont\soft -ap180 -rx21-x7f \dfi\disk%1\x1%1%2.dfi -omonofont\%3.m72
digifont\soft -ap240 -rx21-x7f \dfi\disk%1\x1%1%2.dfi -omonofont\%3.m96
echo off
goto end

:end
