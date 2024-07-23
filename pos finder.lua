XPOS = string.format("%.2f", GetPlayerRawXPos())
YPOS = string.format("%.2f", GetPlayerRawYPos())
ZPOS = string.format("%.2f", GetPlayerRawZPos())
yield("/echo " .. XPOS .. ", " .. YPOS .. ", " .. ZPOS)