echo off
echo -- Creating CENTURY, ITALIC, and SYMBOL fonts in sizes 24 through 96.
echo --
echo -- This takes 20 minutes on a standard AT, time depends on cpu speed.
echo --
echo -- You may abort at any time by pressing CTRL-C or BREAK.
echo -- When aborting on some computers,
echo -- the current font will be finished before the computer
echo -- asks if you want to "Terminate batch job".
echo -- At that time, press the "y" key, then the "Enter" key.
echo --
echo -- If you abort, the fonts created up to that point will be available --
echo -- the last font created may be garbled; it should not be used.
echo -- Later, you may type CENTURY again to start over.
echo --
echo on
digifont\soft -ap60 -rx21-x7f digifont\x1092.dfi -omonofont\century.m24
digifont\soft -ap90 -rx21-x7f digifont\x1092.dfi -omonofont\century.m36
digifont\soft -ap120 -rx21-x7f digifont\x1092.dfi -omonofont\century.m48
digifont\soft -ap140 -rx21-x7f digifont\x1092.dfi -omonofont\century.m56
digifont\soft -ap180 -rx21-x7f digifont\x1092.dfi -omonofont\century.m72
digifont\soft -ap240 -rx21-x7f digifont\x1092.dfi -omonofont\century.m96

digifont\soft -ap60 -rx21-x7f digifont\x1093.dfi -omonofont\italic.m24
digifont\soft -ap90 -rx21-x7f digifont\x1093.dfi -omonofont\italic.m36
digifont\soft -ap120 -rx21-x7f digifont\x1093.dfi -omonofont\italic.m48
digifont\soft -ap140 -rx21-x7f digifont\x1093.dfi -omonofont\italic.m56
digifont\soft -ap180 -rx21-x7f digifont\x1093.dfi -omonofont\italic.m72
digifont\soft -ap240 -rx21-x7f digifont\x1093.dfi -omonofont\italic.m96

digifont\soft -ap60 -rx21-x7f digifont\x1005.dfi -omonofont\symbols.m24
digifont\soft -ap90 -rx21-x7f digifont\x1005.dfi -omonofont\symbols.m36
digifont\soft -ap120 -rx21-x7f digifont\x1005.dfi -omonofont\symbols.m48
digifont\soft -ap140 -rx21-x7f digifont\x1005.dfi -omonofont\symbols.m56
digifont\soft -ap180 -rx21-x7f digifont\x1005.dfi -omonofont\symbols.m72
digifont\soft -ap220 -rx21-x7a -rx7e digifont\x1005.dfi -omonofont\symbols.m96
