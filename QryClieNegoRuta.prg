SELECT Maeclien.*, Maenegoc.codred, Maenegoc.coddsto, "024" AS codzona,;
  "013" AS codloca, "13" AS codruta, Maerutas.orden, Maenegoc.codtineg,;
  Maenegoc.nomnego, Maenegoc.dirnego, Maenegoc.telnego,;
  Maenegoc.barrionego, Maenegoc.coddepto, Maenegoc.codciuda,;
  Maenegoc.estado, Maenegoc.e_mail;
 FROM  vsideg!maeclien INNER JOIN vsideg!maenegoc;
   ON  Maeclien.ideclien = Maenegoc.ideclien;
    INNER JOIN vsideg!maerutas ;
   ON  Maenegoc.codred = Maerutas.codred;
   AND  Maenegoc.coddsto = Maerutas.coddsto;
   AND  Maenegoc.codzona = Maerutas.codzona;
   AND  Maenegoc.codloca = Maerutas.codloca;
   AND  Maenegoc.ideclien = Maerutas.ideclien;
 WHERE Maenegoc.codred = "001";
   AND Maenegoc.coddsto = "001";
   AND Maenegoc.codzona = "012";
   AND Maenegoc.codloca = "002";
 ORDER BY Maerutas.codruta, Maerutas.orden
