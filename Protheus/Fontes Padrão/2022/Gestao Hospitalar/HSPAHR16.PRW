#INCLUDE "HSPAHR16.ch"
#INCLUDE "HSPAHR16.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.CH"
#INCLUDE "Report.ch" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR16บ Autor ณ Patricia Queiroz   บ Data ณ  11/01/07     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Carta de Agradecimento                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHR16()

Local cDesc1  := STR0001 //"Este programa tem como objetivo imprimir relat๓rio "
Local cDesc2  := STR0002 //"de acordo com os parโmetros informados pelo usuแrio."
Local cDesc3  := ""
Local cPict   := STR0003 //"Carta de Agradecimento"
Local titulo  := STR0003 //"Carta de Agradecimento"
Local nLin    := 80
Local Cabec1  := ""
Local Cabec2  := ""
Local imprime := .T.
Local aOrd    := {}

Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 220
Private tamanho     := "M"
Private nomeprog    := "HSPAHR16" 
Private nTipo       := 15
Private aReturn     := {STR0004, 1, STR0005, 2, 2, 1, "", 1}   //"Zebrado"###"Administra็ใo"
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "HSPAHR16"
Private cString     := "GCY"
Private cPerg       := "HSPR16"
Private aVetor      := {}
Private nMaxLin     := 0 // quantidade maxima de linhas p/ impressao
Private nTipRel     := 0
Private dData_De    := ""
Private dData_Ate   := "" 
Private cTpSang     := ""
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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณRUNREPORT บ Autor ณPatricia Queiroz    บ Data ณ  11/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1, Cabec2, Titulo, nLin)   

 Local cSQL   := ""
 Local cFicha := GETMV("MV_CAGRADE")

 DbSelectArea("GCY")

 cSQL := "SELECT GCY.GCY_NOME, MAX(GCY.GCY_DATATE) GCY_DAT, GCY.GCY_REGATE, GCY.GCY_LOCATE, GBH.GBH_CODPAC, GBH.GBH_TPSANG, GBH.GBH_FATORH "
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

 cSQL += "GROUP BY GCY.GCY_NOME, GCY.GCY_REGATE, GCY.GCY_LOCATE, GBH.GBH_CODPAC, GBH.GBH_TPSANG, GBH.GBH_FATORH "
 
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
 	HS_MsgInf(STR0006, STR0007, STR0008) //"Nao hแ dados a serem impressos para a seleใo efetuada!"###"Aten็ใo"###"Verifique a sele็ใo"
 EndIf 

 While !Eof()

  IncRegua()
 
  If lAbortPrint
 	 @nLin, 000 PSAY STR0009 //"*** CANCELADO PELO OPERADOR ***"
 	 Exit
  EndIf 

  DbSelectArea("GCS")
  DbSetOrder(1)
  DbSeek(xFilial("GCS") + QRY->GCY_LOCATE) 
  
  DbSelectArea("GCY")
  DbSetOrder(1)
  DbSeek(xFilial("GCY") + QRY->GCY_REGATE) 
 
  DbSelectArea("GBH")
  DbSetOrder(1)
  DbSeek(xFilial("GBH") + QRY->GBH_CODPAC) 
 
  HSPFITXT(cFicha)
 
  DbCloseArea()
 
  DbSelectArea("QRY")
  DbSkip()
 
 EndDo

DbCloseArea()

SET DEVICE TO SCREEN
 If aReturn[5] == 1
 	DbCommitAll()
	 SET PRINTER TO
	 OurSpool(wnrel)
 EndIf

 MS_FLUSH()

Return(Nil)