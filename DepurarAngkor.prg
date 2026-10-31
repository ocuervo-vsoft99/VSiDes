DELETE FROM MaeAngkor WHERE DATE(VAL(SUBSTR(MaeAngkor.fechafe,1,4)),VAL(SUBSTR(MaeAngkor.fechafe,6,2)), VAL(SUBSTR(MaeAngkor.fechafe,9,2))) < (DATE(2023,03,01) - 90)
PACK