#INCLUDE "HSPAHR12.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.CH"
#INCLUDE "Report.ch" 


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HSPAHR12 ³ Autor ³ Patricia Queiroz      ³ Data ³ 08/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio Recrutamento de Doadores                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gestao Hospitalar                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function HSPAHR12()

Local oReport
 
If FindFunction("TRepInUse") .And. TRepInUse() 
	Pergunte("HSPR12", .F.)
 oReport := ReportDef() 
 oReport:PrintDialog()  
Else  
 HSPAHR12R3()  
EndIf 

Return(Nil)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³REPORTDEF ³ Autor ³ Patricia Queiroz      ³ Data ³ 09/11/06 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ReportDef()

Local oReport 
Local oSection1, oSection2, oSection3, oSection4
Local oCell
Local oTotaliz1, oTotaliz2

oReport := TReport():New("HSPAHR12", STR0001, "HSPR12", {|oReport| R12IMP(oReport)}, STR0002 + " " + STR0003)  //"Recrutamento de Doadores"###"Este programa tem como objetivo imprimir relatório "###"de acordo com os parâmetros informados pelo usuário."

oSection1 := TRSection():New(oReport, STR0001, {"GBH"}) //"Recrutamento de Doadores"       

oSection1:SetHeaderBreak(.T.)    //Indica se cabecalho da secao sera impresso em cada quebra
oSection1:SetPageBreak(.F.)      //Indica quebra de pagina no final da secao
oSection1:SetHeaderPage(.F.)     //Indica que cabecalho da secao sera impresso no topo da pagina
oSection1:SetHeaderSection(.T.)  //Indica se cabecalho da secao sera impresso (padrao)   
oCell := TRCell():New(oSection1, "GBH_TPSANG", "GBH", STR0004,,,, {||HS_RDescrB("GBH_TPSANG",AllTrim(("QRYR12")->GBH_TPSANG))})     //"Tipo Sangue"

oSection2 := TRSection():New(oSection1, STR0001, {"GBH"}) //"Recrutamento de Doadores"            
oSection2:SetHeaderBreak(.T.)
oSection2:SetPageBreak(.F.)
oSection2:SetHeaderPage(.F.)     
oSection2:SetHeaderSection(.T.)     
oCell := TRCell():New(oSection2, "GBH_FATORH", "GBH", STR0005,,,, {||HS_RDescrB("GBH_FATORH",AllTrim(("QRYR12")->GBH_FATORH))}) //"Fator RH"

oSection3 := TRSection():New(oSection2, STR0001, {"GCY", "GBH","QRYR12"}) //"Recrutamento de Doadores"
oSection2:SetTotalInLine(.F.)
oSection3:SetHeaderPage(.T.) 
oSection3:SetHeaderBreak(.T.)
oSection3:SetNoFilter({"QRYR12"})     
oCell := TRCell():New(oSection3, "GBH_TPSANG", "GBH", STR0004,, 3,, {||HS_RDescrB("GBH_TPSANG",AllTrim(("QRYR12")->GBH_TPSANG))}) //"Tp. Sangue"   
oCell := TRCell():New(oSection3, "GBH_FATORH", "GBH", STR0005,, 3,, {||HS_RDescrB("GBH_FATORH",AllTrim(("QRYR12")->GBH_FATORH))}) //"Fator RH"   
oCell := TRCell():New(oSection3, "GCY_NOME"  , "GCY", STR0006,, 30) //"Doador"
oCell := TRCell():New(oSection3, "GCY_DATATE", "GCY", STR0007,, 8)  //"Data"
oCell := TRCell():New(oSection3, "GBH_TEL"   , "GBH", STR0008,, 20) //"Telefone"          


DEFINE FUNCTION FROM oSection3:Cell("GBH_TPSANG") OF oSection1 FUNCTION COUNT TITLE "Total por Tipo de Sangue =>" NO END REPORT                  
DEFINE FUNCTION FROM oSection3:Cell("GBH_TPSANG") OF oSection2 FUNCTION COUNT TITLE "Total por Fator Rh       =>" NO END REPORT

Return(oReport)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R12Imp   ³ Autor ³ Patricia Queiroz      ³ Data ³ 09/11/06 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function R12IMP(oReport)

 Local oSection1 := oReport:Section(1) 
 Local oSection2 := oReport:Section(1):Section(1)  
 Local oSection3 := oReport:Section(1):Section(1):Section(1)
 Local cCond     := "%%"
 Local cCond1    := "%%"
 Local cCond2    := "%%"
 
 If MV_PAR09 == 1
  cCond := "%GBH.GBH_TPSANG%"
 ElseIf MV_PAR09 == 2
  cCond := "%GBH.GBH_FATORH%"
 ElseIf MV_PAR09 == 3
  cCond := "%GCY.GCY_NOME%"  
 EndIf
 
 cCond1 := IIF(MV_PAR03 == 1, "% GBH.GBH_TPSANG IN ('0')%", IIF (MV_PAR03 == 2, "% GBH.GBH_TPSANG IN ('1')%", IIF(MV_PAR03 == 3, "% GBH.GBH_TPSANG IN ('2')%", IIF(MV_PAR03 == 4, "%'3'%", "% GBH.GBH_TPSANG IN ('0', '1', '2', '3')%"))))
 cCond2 := IIF(MV_PAR04 == 1, "% GBH.GBH_FATORH IN ('0')%", IIF (MV_PAR04 == 2, "% GBH.GBH_FATORH IN ('1')%", "% GBH.GBH_FATORH IN ('0', '1')%"))
 
 MakeSqlExp("HSPR12")
 oSection1:BeginQuery()

BeginSql Alias "QRYR12"
 SELECT GCY.GCY_NOME, MAX(GCY.GCY_DATATE) GCY_DAT, GBH.GBH_TPSANG, GBH.GBH_FATORH, GBH.GBH_TEL
 FROM %table:GCY% GCY
 JOIN %table:GBH% GBH ON GBH.GBH_CODPAC = GCY.GCY_REGGER AND GBH.GBH_FILIAL = %xFilial:GBH% AND GBH.%NotDel%
 WHERE GCY.GCY_FILIAL = %xFilial:GCY% AND GCY.%NotDel%
   AND GCY.GCY_ATENDI = %Exp:'3'%
   AND GCY.GCY_DATATE BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)% 
   AND %Exp:cCond1%
   AND %Exp:cCond2%   
   AND GCY.GCY_LOCATE = %Exp:MV_PAR08%
   AND GBH.GBH_CEP BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06% 
   AND GBH.GBH_CDFORE = %Exp:MV_PAR07%      
 GROUP BY GCY.GCY_REGATE, GCY.GCY_NOME, GBH.GBH_TPSANG, GBH.GBH_FATORH, GBH.GBH_TEL
 ORDER BY %Exp:cCond%
EndSql

oSection1:EndQuery() 

oSection2:SetParentQuery()                                                                  
oSection2:SetParentFilter({|L| QRYR12->GBH_TPSANG == L}, {|| QRYR12->GBH_TPSANG})

oSection3:SetParentQuery()                                                                  
oSection3:SetParentFilter({|S| QRYR12->GBH_FATORH + QRYR12->GBH_TPSANG == S}, {|| QRYR12->GBH_FATORH + QRYR12->GBH_TPSANG})  

oSection1:Print() 

Return(Nil)







/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHR12R3º Autor ³ Patricia Queiroz   º Data ³  06/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Recrutamento de Doadores                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPAHR12R3()

Local cDesc1  := STR0002 //"Este programa tem como objetivo imprimir relatório "
Local cDesc2  := STR0003 //"de acordo com os parâmetros informados pelo usuário."
Local cDesc3  := ""
Local cPict   := STR0001 //"Recrutamento de Doadores"
Local titulo  := STR0001 //"Recrutamento de Doadores"
Local nLin    := 80
Local Cabec1  := ""
Local Cabec2  := ""
Local imprime := .T.
Local aOrd    := {}

Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 220
Private tamanho     := "M"
Private nomeprog    := "HSPAHR12" 
Private nTipo       := 15
Private aReturn     := {STR0010, 1, STR0011, 2, 2, 1, "", 1} //"Zebrado"###"Administração"
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "HSPAHR12"
Private cString     := "GCY"
Private cPerg       := "HSPR12"
Private aVetor      := {}
Private nMaxLin     := 0 // quantidade maxima de linhas p/ impressao
Private cSQL        := ""  
Private nTipRel     := 0
Private dData_De    := ""
Private dData_Ate   := "" 
Private cTpSang     := ""
Private cLote       := ""
Private cFatRh      := ""
Private cCep_De     := ""
Private cCep_Ate    := ""
Private cFRecrut    := ""
Private cLocAte     := ""
Private cOrdem      := ""
Private cCodImp     := ""

If !Pergunte(cPerg, .T.)
	Return(Nil)
EndIf  

dData_De  := MV_PAR01
dData_Ate := MV_PAR02
cTpSang   := MV_PAR03
cFatRh    := MV_PAR04                                  
cCep_De   := MV_PAR05
cCep_Ate  := MV_PAR06                                                                    
cFRecrut  := MV_PAR07
cLocAte   := MV_PAR08
cOrdem    := MV_PAR09
cCodImp   := MV_PAR10

nMaxLin := HS_MaxLin(cCodImp)
nLin    := nMaxLin * 2

wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .T., Tamanho,, .F.)

If nLastKey == 27
	Return(Nil)
EndIf

SetDefault(aReturn, cString)

If nLastKey == 27
	Return(Nil)
EndIf

nTipo := If(aReturn[4] == 1, 15, 18)
RptStatus({|| RunReport(Cabec1, Cabec2, Titulo, nLin)}, Titulo)

Return(Nil)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³RUNREPORT º Autor ³Patricia Queiroz    º Data ³  06/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1, Cabec2, Titulo, nLin)   

 Local cSQL    := "", cTipSang := "", cFatoRh  := ""
 Local nTotSang := 0, nTotRh := 0


 /*         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21       22
  0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789*/

 Cabec1 := STR0012 //"Tp. Sangue  Fator Rh  Doador                                         Data      Telefone" 

 DbSelectArea("GCY")

 cSQL := "SELECT GCY.GCY_NOME, MAX(GCY.GCY_DATATE) GCY_DAT, GBH.GBH_TPSANG, GBH.GBH_FATORH, GBH.GBH_TEL "
 cSQL += "FROM " + RetSqlName("GCY") + " GCY "
 cSQL += "JOIN " + RetSqlName("GBH") + " GBH ON GBH.GBH_CODPAC = GCY.GCY_REGGER AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
 cSQL += "WHERE GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSQL += "AND GCY.GCY_ATENDI = '3' "
 cSQL += "AND GCY.GCY_DATATE BETWEEN '" + DTOS(dData_De) + "' AND '" + DTOS(dData_Ate) + "' " 
 cSQL += "AND GCY.GCY_LOCATE = '" + cLocAte + "' "
 cSQL += "AND GBH.GBH_CEP BETWEEN '" + cCep_De + "' AND '" + cCep_Ate + "' " 
 cSQL += "AND GBH.GBH_CDFORE = '" + cFRecrut + "' "                                             
 
 If cTpSang == 1
  cSQL += "AND GBH.GBH_TPSANG IN ('0') "
 ElseIf cTpSang == 2
  cSQL += "AND GBH.GBH_TPSANG IN ('1') "
 ElseIf cTpSang == 3
  cSQL += "AND GBH.GBH_TPSANG IN ('2') "  
 ElseIf cTpSang == 4
  cSQL += "AND GBH.GBH_TPSANG IN ('3') "    
 Else 
  cSQL += "AND GBH.GBH_TPSANG IN ('0', '1', '2', '3') "
 EndIf
 
 If cFatRh == 1
  cSQL += "AND GBH.GBH_FATORH IN ('0') "
 ElseIf cFatRh == 2
  cSQL += "AND GBH.GBH_FATORH IN ('1') "
 Else
  cSQL += "AND GBH.GBH_FATORH IN ('0', '1') "
 EndIf         

 cSQL += "GROUP BY GCY.GCY_REGATE, GCY.GCY_NOME, GBH.GBH_TPSANG, GBH.GBH_FATORH, GBH.GBH_TEL "
 
 If cOrdem == 1
  cSQL += "ORDER BY GBH.GBH_TPSANG "
 ElseIf cOrdem == 2
  cSQL += "ORDER BY GBH.GBH_FATORH "
 ElseIf cOrdem == 3
  cSQL += "ORDER BY GCY.GCY_NOME "  
 EndIf
 
 cSQL := ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRY"

DbSelectArea("QRY")
DbGoTop()

SetRegua(100)

If Eof()
	HS_MsgInf(STR0013, STR0014, STR0015) //"Nao há dados a serem impressos para a seleão efetuada!"###"Atenção"###"Verifique a seleção" 
EndIf

cTipSang := QRY->GBH_TPSANG  
cFatoRh  := QRY->GBH_FATORH

While !Eof()

 IncRegua()
 
 If lAbortPrint
	 @nLin, 000 PSAY STR0016 //"*** CANCELADO PELO OPERADOR ***"
	 Exit
 EndIf   
 
 If nLin > nMaxLin
		Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
		nLin := 8
	EndIf

 If QRY->GBH_TPSANG <> cTipSang 
  nLin := nLin + 2
  @nLin, 000 PSAY STR0017 + STR(nTotSang)  //"==> Total Tp. Sangue: "
  nLin := nLin + 2
  nTotSang := 0
 EndIf 
 cTipSang  := QRY->GBH_TPSANG

 
 If QRY->GBH_FATORH <> cFatoRh
  nLin := nLin + 2
  @nLin, 000 PSAY STR0018 + STR(nTotRh)  //"==> Total Fator Rh:   "
  nLin := nLin + 2
  nTotRh := 0
 EndIf 
 cFatoRh := QRY->GBH_FATORH

 @nLin, 000 PSAY HS_RDescrB("GBH_TPSANG", AllTrim(QRY->GBH_TPSANG))
 @nLin, 012 PSAY HS_RDescrB("GBH_FATORH", AllTrim(QRY->GBH_FATORH))
 @nLin, 022 PSAY QRY->GCY_NOME 
 @nLin, 069 PSAY IIF(Empty(QRY->GCY_DAT), " ", HS_DTOC(STOD(QRY->GCY_DAT), 1))
 @nLin, 079 PSAY QRY->GBH_TEL
 nLin++

 nTotSang++
 nTotRh++
 
 DbSkip()
 
EndDo

nLin := nLin + 2
@nLin, 000 PSAY STR0017 + STR(nTotSang)  //"==> Total Tp. Sangue: " 

DbCloseArea()

SET DEVICE TO SCREEN
 If aReturn[5] == 1
 	DbCommitAll()
	 SET PRINTER TO
	 OurSpool(wnrel)
 EndIf

 MS_FLUSH()

Return(Nil)