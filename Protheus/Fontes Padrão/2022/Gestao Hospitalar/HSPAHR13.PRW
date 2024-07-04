#INCLUDE "HSPAHR13.ch"
#Include "protheus.ch"
#include "TopConn.ch"
#INCLUDE "Report.ch" 


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HSPAHR13 ³ Autor ³ Patricia Queiroz      ³ Data ³ 13/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio Envio de Amostras.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gestao Hospitalar                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function HSPAHR13(cCodProt)

Local oReport


If !FindFunction("TRepInUse") .And. TRepInUse() 
	Pergunte("HSPR13", .F.)
 oReport := ReportDef() 
 oReport:PrintDialog()  
Else  
 HSPAHR13R3(cCodProt)  
EndIf 

Return(Nil)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³REPORTDEF ³ Autor ³ Patricia Queiroz      ³ Data ³ 13/02/07 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ReportDef()

Local oReport 
Local oSection1, oSection2 , oSection3
Local oCell
Local cEmp := ""

oReport := TReport():New("HSPAHR13", STR0003, "HSPR13", {|oReport| R13IMP(oReport)}, STR0001 + " " + STR0002)  //"Relatório de Envio de Amostras (sorologia e imunohemato)"###"Este programa tem como objetivo imprimir relatório "###"de acordo com os parâmetros informados pelo usuário."
oReport:SetLandsCape()          

oSection1 := TRSection():New(oReport, STR0003, {"GGQ","SM0"}) //"Relatório de Envio de Amostras (sorologia e imunohemato)"       
oSection1:SetHeaderBreak(.F.)    //Indica se cabecalho da secao sera impresso em cada quebra
oSection1:SetPageBreak(.F.)      //Indica quebra de pagina no final da secao
oSection1:SetHeaderSection(.T.)  //Indica se cabecalho da secao sera impresso (padrao)   
oSection1:SetHeaderPage(.T.)     //Indica que cabecalho da secao sera impresso no topo da pagina
oCell := TRCell():New(oSection1, "cEmp", "SM0", STR0010,, 4,, {|| cEmp := SM0->M0_NOMECOM}) //"Empresa"     

oSection2 := TRSection():New(oSection1, STR0003, {"GGQ"}) //"Relatório de Envio de Amostras (sorologia e imunohemato)"       
oSection2:SetHeaderBreak(.T.)    
oSection2:SetPageBreak(.F.)      
oSection2:SetHeaderSection(.T.)  
oSection2:SetHeaderPage(.T.)     
oCell := TRCell():New(oSection2, "GGP_UNICOL", "GGP", STR0011,, 4) //"Local de Origem"     
oCell := TRCell():New(oSection2, "GGP_DSUNIC", "GGP",,, 42)   
oCell := TRCell():New(oSection2, "GGQ_CDPROT", "GGQ", STR0012,, 6) //"Número Protocolo"    
oCell := TRCell():New(oSection2, "dDataBase" , "GGQ", STR0013,, 6) //"Data do Protocolo"    

oSection3 := TRSection():New(oSection2, STR0003, {"GGQ", "GGO", "GGP", "QRY13"}) //"Relatório de Envio de Amostras (sorologia e imunohemato)"           
oSection3:SetHeaderBreak(.T.)
oSection3:SetPageBreak(.F.)
oSection3:SetHeaderSection(.T.)
oSection3:SetHeaderPage(.T.)   
oSection3:SetNoFilter({"QRYR13"})     
oCell := TRCell():New(oSection3, "GGP_CDAMOT", "QRYR13", STR0014,,8,, {|| QRYR13->GGP_CDAMOT + QRYR13->GGP_CDITEM}) //"N. Amostra"
oCell := TRCell():New(oSection3, "GGO_DATSOL", "QRYR13", STR0015,,8)   //"Dt. Coleta"
oCell := TRCell():New(oSection3, "GGO_HORSOL", "QRYR13", STR0016,,5)   //"Hr. Coleta"
oCell := TRCell():New(oSection3, "GGP_CDTIPA", "QRYR13", STR0017,,6)   //"Tp. Amostra"
oCell := TRCell():New(oSection3, "GGG_DSTIPA", "QRYR13", STR0018,,20)  //"Descrição"
oCell := TRCell():New(oSection3, "GGQ_DATSAI", "QRYR13", STR0019,,8)   //"Dt. Saida"
oCell := TRCell():New(oSection3, "GGQ_HORSAI", "QRYR13", STR0020,,5)   //"Hr. Saida"
oCell := TRCell():New(oSection3, "GGQ_RESLIB", "QRYR13", STR0021,,20)  //"Resp. Liberação"
oCell := TRCell():New(oSection3, "GGQ_TEMPSA", "QRYR13", STR0022,,4)   //"T. Saida"
oCell := TRCell():New(oSection3, "GGQ_MOTRES", "QRYR13", STR0023,, 20) //"Transp. Por"  
oCell := TRCell():New(oSection3, "GGQ_TIPTRA", "QRYR13", STR0024,, 15) //"Tp. Transp"
oCell := TRCell():New(oSection3, "GGQ_DATREC", "QRYR13", STR0025,, 8)  //"Dt. Ent"
oCell := TRCell():New(oSection3, "GGQ_HORCHE", "QRYR13", STR0026,, 5)  //"Hr. Ent"
oCell := TRCell():New(oSection3, "GGQ_RESREC", "QRYR13", STR0027,, 20) //"Resp. Receb"
oCell := TRCell():New(oSection3, "GGQ_TEMPCH", "QRYR13", STR0028,, 4)  //"T. Receb"

oSection2:SetParentRecno()

TRFunction():New(oSection3:Cell("GGP_CDAMOT")	,/* cID */,"COUNT",,/*cTitle*/,"9999",/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/, oSection2)


Return(oReport)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R13Imp   ³ Autor ³ Patricia Queiroz      ³ Data ³ 13/02/07 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function R13IMP(oReport)

 Local oSection1 := oReport:Section(1) 
 Local oSection2 := oReport:Section(1):Section(1)  
 Local oSection3 := oReport:Section(1):Section(1):Section(1)  
 Local cCond     := "%%"
 Local cCond1    := "%%"
 

 If !Empty(cCodProt)
  cCond := "%GGQ.GGQ_CDPROT = '" + cCodProt + "'%"
 Else
  cCond := "%GGQ.GGQ_CDPROT BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' %" 
 EndIf 
 
 If !Empty(cCodProt)
  cCond1 := "% GGP.GGP_CDSITA IN ('1', '2') %" 
 ElseIf !Empty(MV_PAR03)
  If MV_PAR03 == 1
   cCond1 := "% GGP.GGP_CDSITA = '1' %"
  ElseIf MV_PAR03 == 2
   cCond1 := "% GGP.GGP_CDSITA = '2' %" 
  EndIf
 EndIf
 
MakeSqlExp("HSPR13")
oSection1:BeginQuery()

BeginSql Alias "QRYR13"
 SELECT GGQ.GGQ_CDPROT, GGQ.GGQ_HORSAI, GGQ.GGQ_DATSAI, GGQ.GGQ_DATREC, GGQ.GGQ_TIPTRA, GGQ.GGQ_MOTRES, GGQ.GGQ_RESLIB, GGQ.GGQ_TEMPSA, 
  GGQ.GGQ_TIPTRA, GGQ.GGQ_HORCHE, GGQ.GGQ_RESREC, GGQ.GGQ_TEMPCH, GGP.GGP_CDAMOT, GGP.GGP_CDITEM, GGP.GGP_CDTIPA, GGP.GGP_UNICOL, 
  GGP.GGP_DSUNIC, GGG.GGG_DSTIPA, GGO.GGO_DATSOL, GGO.GGO_HORSOL
 FROM %table:GGQ% GGQ
 LEFT JOIN %table:GGP% GGP ON GGP.GGP_CDPROT = GGQ.GGQ_CDPROT AND GGP.GGP_FILIAL = %xFilial:GGP% AND GGP.%NotDel%
 LEFT JOIN %table:GGO% GGO ON GGO.GGO_CDCOLE = GGP.GGP_CDCOLE AND GGO.GGO_FILIAL = %xFilial:GGO% AND GGO.%NotDel%
 LEFT JOIN %table:GGG% GGG ON GGG.GGG_CDTIPA = GGP.GGP_CDTIPA AND GGG.GGG_FILIAL = %xFilial:GGG% AND GGG.%NotDel% 
 WHERE GGQ.GGQ_FILIAL = %xFilial:GGQ% AND GGQ.%NotDel%
  AND %Exp:cCond%
  AND %Exp:cCond1% 
 ORDER BY GGP.GGP_UNICOL 
EndSql

oSection1:EndQuery() 

oSection2:SetParentQuery()                                                                  
oSection2:SetParentFilter({|L| QRYR13->GGP_UNICOL == L}, {|| QRYR13->GGP_UNICOL})           

oSection3:SetParentQuery()                                                                  
oSection3:SetParentFilter({|S| QRYR13->GGP_UNICOL == S}, {|| QRYR13->GGP_UNICOL})

oSection1:SetMeter(QRYR13->(LastRec()))
oSection1:Print() 

Return(Nil)





/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±              
±±ºPrograma  ³RelAmostraº Autor ³ Patricia Queiroz   º Data ³  26/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Envio de Amostras                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±         
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPAHR13R3(cCodProt)                                                            
                 
Local cSQL       := ""
Local cLocal     := ""
Local nTot       := 0
Local oPrn 
Local nMarSup	   := 0         
Local nPriLinBar := 0
Local cTipoBar   := ""
Local nColBar    := 0
Local lDigBar	   := .F.
Local cCorBar	   := Nil
Local lHoriBar   := Nil
Local nLargBar   := 0
Local nAltuBar   := 0
Local lBanbar	   := .T.
Local cFonBar	   := Nil
Local cModBar	   := Nil
Local lNovaPag   := .F.
Local lCabec     := .T.
                     
Private oFont	  := TFont():New("Courier New"	  , 09, 09,, .T.,,,,, .F.)
Private oFont1	 := TFont():New("Courier New"	  , 09, 09,, .F.,,,,, .F.)
Private nCol1   := 0
Private nCol2   := 0         
Private nCol3   := 0
Private nEspLin	:= 0

If !Pergunte("HSPR13", .T.)
	Return()
EndIf

cCdPro_De  := MV_PAR01
cCdPro_Ate := MV_PAR02
cTipProt   := MV_PAR03
nTpImp     := MV_PAR04
cCodImp    := MV_PAR05


cSQL := "SELECT GGQ.GGQ_CDPROT, GGQ.GGQ_HORSAI, GGQ.GGQ_DATSAI, GGQ.GGQ_DATREC, GGQ.GGQ_TIPTRA, GGQ.GGQ_MOTRES, GGQ.GGQ_RESLIB, GGQ.GGQ_TEMPSA, "
cSQL += " GGQ.GGQ_TIPTRA, GGQ.GGQ_HORCHE, GGQ.GGQ_RESREC, GGQ.GGQ_TEMPCH, GGP.GGP_CDAMOT, GGP.GGP_CDITEM, GGP.GGP_CDTIPA, GGP.GGP_UNICOL, GGP.GGP_DSUNIC, GGG.GGG_DSTIPA, GGO.GGO_DATSOL, GGO.GGO_HORSOL"
cSQL += " FROM " + RetSQLName("GGQ") + " GGQ"
cSQL += " LEFT JOIN " + RetSQLName("GGP") + " GGP ON GGP.GGP_FILIAL = '" + xFilial("GGP") + "' AND GGP.D_E_L_E_T_ <> '*' AND GGP.GGP_CDPROT = GGQ.GGQ_CDPROT"
cSQL += " LEFT JOIN " + RetSQLName("GGO") + " GGO ON GGO.GGO_FILIAL = '" + xFilial("GGO") + "' AND GGO.D_E_L_E_T_ <> '*' AND GGO.GGO_CDCOLE = GGP.GGP_CDCOLE"
cSQL += " LEFT JOIN " + RetSQLName("GGG") + " GGG ON GGG.GGG_FILIAL = '" + xFilial("GGG") + "' AND GGG.D_E_L_E_T_ <> '*' AND GGG.GGG_CDTIPA = GGP.GGP_CDTIPA"
cSQL += " WHERE GGQ.GGQ_FILIAL = '" + xFilial("GGQ") + "' AND GGQ.D_E_L_E_T_ <> '*'"

If !Empty(cCodProt)
 cSQL += " AND GGQ.GGQ_CDPROT = '" + cCODPROT + "'"
Else 
 cSQL += " AND GGQ.GGQ_CDPROT BETWEEN '" + cCdPro_De + "' AND '" + cCdPro_Ate + "' "
EndIf

If Type("cAmostra") <> "U"
 If !Empty(cAmostra)
  cSQL += " AND GGP.GGP_CDAMOT IN (" + cAmostra + ") "
 EndIf 
EndIf 

If !Empty(cTipProt) 
 If cTipProt == 1
  cSQL += " AND GGP.GGP_CDSITA = '1' "
 ElseIf cTipProt == 2
  cSQL += " AND GGP.GGP_CDSITA = '2' " 
 EndIf                                 
Else
 cSQL += " AND GGP.GGP_CDSITA IN ('1', '2') "   
EndIf 

cSQL := ChangeQuery(cSQL)
TCQUERY cSQL NEW ALIAS "QRY"


DbSelectArea("QRY")
DbGoTop()

If Eof()
	HS_MsgInf(STR0004, STR0009, STR0005)   //"Nenhuma informação foi encontrada para a seleção!"###"Atenção"###"Verifique a seleção"
EndIf


oPrn:=TMSPrinter():New()
oPrn:Setup()

nEspLin	   :=   50   	             // espaçamento entre linha
nMarSup	   :=  080   	             // margen superior
nCol1 	    :=  015		               // margen da coluna1
nCol2 	    :=  617		               // margen da coluna2
nCol3 	    :=  817		               // margen da coluna3
nPriLinBar := (0.60) / nTpImp
cTipoBar   := GETMV("MV_TPCODB")   // Parâmetro que define o tipo do código de barras
nColBar    := (1) / nTpImp         //Numero da coluna em centimentros 0
nLargBar   := (0.015 / nTpImp) 	   //Numero do Tamanho da barra em centimetros  0.025 1/3 M/mm
nAltuBar   := (0.2 / nTpImp)		     //Numero da Altura da barra em milimetros    1.5

oPrn:StartPage()
nLin 	  := nMarSup      // Linha inicial
nLinBar	:= nPriLinBar   // Linha inicial do codigo de barra


While !Eof() 

 MSBAR(cTipoBar, nLinBar, nColBar, QRY->GGQ_CDPROT, oPrn, lDigBar, cCorBar, lHOriBar, nLargBar, nAltuBar, lBanbar, cFonBar, cModBar, .F.)	

	If lCabec
	 FS_ImpCabe(oPrn)
	 lCabec := .F.
	EndIf
	
 If cLocal <> QRY->GGP_UNICOL
	 oPrn:Say(nLin, 015, QRY->GGP_UNICOL + " - " + QRY->GGP_DSUNIC, oFont1, 100)
	 oPrn:Say(nLin, 979, QRY->GGQ_CDPROT, oFont1, 100)
  oPrn:Say(nLin, 1400, HS_DTOC(dDataBase, 1), oFont1, 100)
  nLin += nEspLin                            
  oPrn:Say(nLin, nCol1, Repl("-", 220), oFont, 100)
  nLin += nEspLin
 EndIf 
  
 oPrn:Say(nLin, 015, QRY->GGP_CDAMOT + QRY->GGP_CDITEM, oFont1, 100)
 oPrn:Say(nLin, 250, IIF(Empty(QRY->GGO_DATSOL), "", HS_DTOC(STOD(QRY->GGO_DATSOL), 1)), oFont1, 100)
 oPrn:Say(nLin, 480, QRY->GGO_HORSOL, oFont1, 100) 
 oPrn:Say(nLin, 720, QRY->GGP_CDTIPA, oFont1, 100) 
 oPrn:Say(nLin, 979, SubStr(QRY->GGG_DSTIPA, 1, 20), oFont1, 100) 
 oPrn:Say(nLin, 1400, IIF(Empty(QRY->GGQ_DATSAI), "", HS_DTOC(STOD(QRY->GGQ_DATSAI), 1)), oFont1, 100)  
 oPrn:Say(nLin, 1610, QRY->GGQ_HORSAI, oFont1, 100) 
 oPrn:Say(nLin, 1835, SubStr(QRY->GGQ_RESLIB, 1, 20), oFont1, 100) 
 oPrn:Say(nLin, 2250, PADL(TRANSFORM(QRY->GGQ_TEMPSA , "@E 99.9"), 4), oFont1, 100) 
 nLin += nEspLin 
 oPrn:Say(nLin, 015, SubStr(QRY->GGQ_MOTRES, 1, 20), oFont1, 100) 
 oPrn:Say(nLin, 480, SubStr(QRY->GGQ_TIPTRA, 1, 15), oFont1, 100) 
 oPrn:Say(nLin, 1400, IIF(Empty(QRY->GGQ_DATREC), "", HS_DTOC(STOD(QRY->GGQ_DATREC), 1)), oFont1, 100) 
 oPrn:Say(nLin, 1610, QRY->GGQ_HORCHE, oFont1, 100) 
 oPrn:Say(nLin, 1835, SubStr(QRY->GGQ_RESREC, 1, 20), oFont1, 100) 
 oPrn:Say(nLin, 2250, PADL(TRANSFORM(QRY->GGQ_TEMPCH , "@E 99.9"), 4), oFont1, 100) 
 nLin += nEspLin
 
 cLocal := QRY->GGP_UNICOL
 nTot++
 
 DbSkip()
 
EndDo

nLin += nEspLin
oPrn:Say(nLin, 015, STR0029 + Str(nTot), oFont, 100) //"Total de Amostras:"


If !Eof() 
 If lNovaPag .Or. nLin >= 1800
		lNovaPag := .F.
		nLin 	   := nMarSup      // linha incial
		nLinBar	 := nPriLinBar   // Linha inciial do codigo de barra
		oPrn:EndPage()
		oPrn:StartPage()		
	Else
		lNovaPag := .T.
		nLin	    := 1800
		nLinBar	+= (14.8 / nTpImp)
	EndIf
EndIf

DbClosearea()

oPrn:Preview()
oPrn:End()  

MS_FLUSH()

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FS_ImpCabe º Autor ³ Patricia Queiroz   º Data ³  12/02/07  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para montar o cabecalho.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_ImpCabe(oPrn)
                
 nLin += nEspLin
 oPrn:Say(nLin, 1200, STR0003, oFont, 100) //"Relatório de Envio de Amostras (sorologia e imunohemato)"
 nLin += nEspLin
 oPrn:Say(nLin, nCol1, Repl("-", 220), oFont, 100) 
 nLin += nEspLin            
 
 oPrn:Say(nLin, nCol1, STR0010 + " - " + SM0->M0_NOMECOM, oFont, 100) //"Empresa"  
 nLin += nEspLin            
 
 oPrn:Say(nLin, nCol1, STR0006, oFont, 100) //"Local de Origem                                  Número Protocolo      Data do Protocolo" 
 nLin += nEspLin                                   
 oPrn:Say(nLin, nCol1, Repl("-", 220), oFont, 100) 
 nLin += nEspLin                                   
 oPrn:Say(nLin, nCol1, STR0007, oFont, 100) //"N. Amostra  Dt. Coleta  Hr. Coleta  Tp. Amostra  Descrição             Dt. Saida  Hr. Saida  Resp. Liberação       T. Saida" 
 nLin += nEspLin
 oPrn:Say(nLin, nCol1, STR0008, oFont, 100) //"Trasnp. Por             Tp. Transp                                     Dt. Ent    Hr. Ent    Resp. Receb           T. Receb"
 nLin += nEspLin
 oPrn:Say(nLin, nCol1, Repl("-", 220), oFont, 100) 
 nLin += (2 * nEspLin)

Return(Nil)