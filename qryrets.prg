SELECT MaeFacEn.facnro, MaeFacEn.facfecha, MaeFacEn.ideclien, MaeClien.rasoclien, ;
	MaeFacEn.valorfact, MaeFacRt.vlrrtefte,;
	MaeFacRt.vlrrteiva, MaeFacRt.vlrrteica;
 FROM  vsideg!maefacen INNER JOIN vsideg!maefacrt ;
   ON  MaeFacEn.facnro = Maefacrt.facnro;
   INNER JOIN maeclien ;
   ON MaeFacEn.ideclien = MaeClien.ideclien ;
 WHERE Maefacen.facfecha BETWEEN DATE(2020,01,01) AND DATE(2020,12,31) ;
 ORDER BY Maefacen.facfecha, MaeFacEn.facnro
