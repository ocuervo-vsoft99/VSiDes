SELECT MaeFacPr.codprov, MaeFacPr.codlin, MaeFacPr.codarti,;
							MaeArtic.nolaarti;
							FROM  maefacpr INNER JOIN maeartic ;
							ON  MaeFacPr.codprov+MaeFacPr.codlin+MaeFacPr.codarti = MaeArtic.codprov+MaeArtic.codlin+MaeArtic.codarti;
							WHERE MaeFacPr.facnro = MaeFacDe.facnro;
							AND MaeFacPr.consecu = MaeFacDe.consecu;
							AND MaeFacPr.codprov+MaeFacPr.codlin+MaeFacPr.codarti NOT IN;
							(SELECT MaePromo.codprov+MaePromo.codlin+MaePromo.codarti FROM MaePromo ;
							WHERE MaePromo.provpro+MaePromo.linpro+MaePromo.artipro = MaeFacDe.codprov+MaeFacDe.codlin+MaeFacDe.codarti)