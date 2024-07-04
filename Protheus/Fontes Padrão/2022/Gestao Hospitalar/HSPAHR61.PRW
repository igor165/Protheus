#INCLUDE "HSPAHR61.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR61  บAutor  ณPatricia Queiroz    บ Data ณ  03/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Declaracoes de Nascidos Vivos                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObs:      ณRelatorio convertido para Relatorios Personalizaveis.       บฑฑ  
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ  
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HSPAHR61()

 Local oReport
 
 If FindFunction("TRepInUse") .And. TRepInUse() 
 	Pergunte("HSPR61", .F.)
  oReport := ReportDef() 
  oReport:PrintDialog()  
 Else  
  HSPAHR61R3()  
 EndIf    
 
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณReportDef บAutor  ณPatricia Queiroz    บ Data ณ  03/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ  
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
 Static Function ReportDef()
 
 Local oReport
 Local oSection1, oSection2
 Local oCell
 
 oReport := TReport():New("HSPAHR61",HS_MontCabe(STR0003, MV_PAR05, MV_PAR06), "HSPR61", {|oReport| R61IMP(oReport)}, STR0001 + STR0002)
 
 oReport:SetPortrait()

 oSection1 := TRSection():New(oReport, STR0003, {"GB2"})
 oCell := TRCell():New(oSection1, " ",,"Nro Decl.",,17)
 oCell := TRCell():New(oSection1, " ",,"Nome da Mae",,40)
 oCell := TRCell():New(oSection1, " ",,"Data Nasc.",,10)
 oCell := TRCell():New(oSection1, " ",,"Hora Nasc.",,10)
    
 Return(oReport)  
 
/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณR61Imp    บAutor  ณPatricia Queiroz    บ Data ณ  03/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ  
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
    
Static Function R61Imp(oReport)

 Local oSection1 := oReport:Section(1)
 Local cParObto  := ""
 Local nTotal    := 0
  
 cParObto := AllTrim(GetMv("MV_TPALTA"))
 
 MakeSqlExp("HSPR61")
 oSection1:BeginQuery()
 
 BeginSql Alias "QRYGB2"
 SELECT GB2_NRODEC, GB2_MAE, GB2_DTNASC, GB2_HORNAS
 FROM %table:GB2% GB2
 WHERE GB2.GB2_FILIAL = %xFilial:GB2% AND GB2.%NotDel%
      AND GB2.GB2_NRODEC <> '          ' AND GB2.GB2_TPALTA <> %Exp:cParObto%
      AND GB2.GB2_DTNASC BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)% 
 ORDER BY GB2_NRODEC     
EndSql

oSection1:EndQuery()

oSection1:Init()
oSection1:PrintLine()
oSection1:Finish() 

DbSelectArea("QRYGB2")

While !oReport:Cancel() .And. !Eof()
  nTotal++ 
  oReport:SkipLine(1)
  If oReport:PageBreak()
 	 oReport:PrintHeader() 
  EndIf 
  oReport:PrintText(QRYGB2->GB2_NRODEC, oReport:Row(), 10) 
  oReport:PrintText(SubStr(QRYGB2->GB2_MAE, 1, 22), oReport:Row(), 300) 
  oReport:PrintText(DTOC(QRYGB2->GB2_DTNASC), oReport:Row(), 950) 
  oReport:PrintText(QRYGB2->GB2_HORNAS, oReport:Row(),1130) 
  oReport:SkipLine(1)
  If oReport:PageBreak()
   oReport:PrintHeader() 
  EndIf  
  
  DbSkip()
    
EndDo

oReport:SkipLine(3)
If oReport:PageBreak()
 oReport:PrintHeader() 
EndIf  
oReport:PrintText(STR0009, oReport:Row(), 10)
oReport:PrintText(Str(nTotal), oReport:Row(), 250) 
oReport:SkipLine(3)
If oReport:PageBreak()
 oReport:PrintHeader() 
EndIf  
oReport:PrintText("______________________________", oReport:Row(), 10)
oReport:SkipLine(1)
If oReport:PageBreak()
 oReport:PrintHeader() 
EndIf  
oReport:PrintText(STR0010, oReport:Row(), 15)

Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR61R3บAutor  ณDaniel Peixoto      บ Data ณ  06/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Declaracoes de Nascidos Vivos                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HSPAHR61R3()

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ Declaracao de Variaveis                                             ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

Local cDesc1  := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2  := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3  := ""
Local cPict   := ""
Local titulo  := STR0003 //"Decl. Nascidos Vivo"
Local nLin    := 80
Local Cabec1  := ""
Local Cabec2  := ""
Local imprime := .T.
Local aOrd 	  := {}    

Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 80                  
Private tamanho     := "P"
Private nomeprog    := "HSPAHR61" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo       := 18
Private aReturn     := {STR0004, 1, STR0005, 2, 2, 1, "", 1}      //"Zebrado"###"Administracao"
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "HSPAHR61" /* Coloque aqui o nome do arquivo usado para impressao em disco */
Private cPerg       := "HSPR61"

Private cString := "GB2"

Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ PARAMETROS                                                         ณ
  ณ MV_PAR01	Da Data                                                   ณ
  ณ MV_PAR02	Ate Data                                                  ณ
/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ*/

If !Pergunte(cPerg, .T.)
  Return
EndIf    

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2

wnrel := SetPrint(cString, nomeprog, cPerg, @Titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .T., Tamanho,, .F.)

If nLastKey == 27
	Return(Nil)
EndIf

SetDefault(aReturn, cString)

If nLastKey == 27
   Return
EndIf

nTipo := If(aReturn[4] == 1, 15, 18)

 // Processamento RPTSTATUS monta janela com a regua de processamento.
RptStatus({|| RunReport(Cabec1, Cabec2, Titulo, nLin)}, Titulo)

Return

/* 
*****************************************************************************************************************
Funcao     RUNREPORT  Autor : AP6 IDE               Data   06/06/05
Descricao  Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS monta a janela com a regua de processamento.
Uso        Programa principal 
*/

Static Function RunReport(Cabec1, Cabec2, Titulo, nLin)

Local Nct 	   := 0
Local nTREG    := 0
Local cParObto := ""

aDados := {}

cParObto := AllTrim(GetMv("MV_TPALTA"))

DbSelectArea("GB2")
DbSetOrder(4)       //Filial + Setor  + Data de Lan็amento
DBGoTop()   
DbSeek(xFilial("GB2") + DTOS(MV_PAR01), .T.)
Do While !Eof() .And. GB2->GB2_FILIAL == xFilial("GB2") .And. DTOS(GB2->GB2_DTNASC) >= DTOS(MV_PAR01) .And. DTOS(GB2->GB2_DTNASC) <= DTOS(MV_PAR02)  
  If Empty(GB2->GB2_NRODEC) .Or. GB2->GB2_TPALTA $ cParObto
    DbSkip()
    Loop
  EndIf
   Aadd(aDados, {GB2->GB2_NRODEC, SUBSTR(GB2->GB2_MAE,1,35), DTOC(GB2->GB2_DTNASC), GB2->GB2_HORNAS})	   
   nTReg := nTReg + 1
   DbSkip()
EndDo

aSort(aDados,,, {|x,y| x[1] < y[1]})

Cabec1 := STR0006 + DTOC(MV_PAR01) + STR0007 + DTOC(MV_PAR02)  //"Perํodo:  "###" a "
        /*                     1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
                     0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
Cabec2 := STR0008 //"Nro.Decl.        Nome da Mae                           Data Nasc.       Hora Nasc."

ProcRegua(Len(aDados))

nTotal := 0

For nCt := 1 to Len(aDados)
  If ( nLin == 0 .Or. nLin > nMaxLin )
       nLin := Cabec(titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo) + 1
  EndIf

  @ nLin,000  PSAY aDados[nCt, 1]
  @ nLin,017  PSAY aDados[nCt, 2]
  @ nLin,055  PSAY aDados[nCt, 3]
  @ nLin,072  PSAY aDados[nCt, 4]
  nLin++  
  
  If nlin >= (nMaxLin - 2)
    nlin := 0
  EndIf
  
  nTotal := nTotal + 1
	              
Next

If nTotal > 0           
  nLin := nLin + 2
  @ nLin,00 PSAY STR0009 + TRANSFORM(nTotal, "@E 99999")  //"Quantidade de Declara็๕es ---> "
  nLin := nLin + 3
  @ nLin,00 PSAY "_______________________________"
  nLin := nLin + 1
  @ nLin,00 PSAY STR0010 //"  Assinatura do Responsแvel    "
EndIf 

 // Finaliza a execucao do relatorio...
SET DEVICE TO SCREEN

If aReturn[5] == 1
   DbCommitAll()
   SET PRINTER TO
   OurSpool(wnRel)
EndIf

Ms_Flush()

Return