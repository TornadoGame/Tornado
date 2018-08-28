CLS

ThetaR = 12

INPUT "Takeoff speed (kts) ... ", Vto
INPUT "Takeoff run (ft) ...... ", Dto

Vto = Vto * 1.7

Vrotate = Vto * 7 / 8

Accel = (Vto * Vto) / (2 * Dto)

tr = Vto / (8 * Accel)

ThetaRRate = ThetaR / tr

Vtrim = (4 * Vto * TAN(ThetaR * 3.146 / 180)) + Vto

tl = (Vtrim - Vto) / Accel

ThetaLRate = ThetaR / tl

PRINT "=========================================================="
PRINT "Rotation speed (ft/sec*8)        = "; CINT(Vrotate * 8)
PRINT "Acceleration (ft/sec/sec*8)      = "; CINT(Accel * 8)
PRINT "Rotation rate (fine pdegs / sec) = "; CINT((ThetaRRate / 360) * 65536)
PRINT "Lift rate (fine pdegs / sec)     = "; CINT((ThetaLRate / 360) * 65536)
PRINT "Manoeuvre speed (kts)            = "; CINT(Vtrim / 1.7)

END

