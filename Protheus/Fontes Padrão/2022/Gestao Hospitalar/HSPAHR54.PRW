#INCLUDE "HSPAHR54.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR54  บAutor  ณPatricia Queiroz    บ Data ณ  06/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณMovimentacao Por Inventario (Sintetico)                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObs:      ณRelatorio convertido para Relatorios Personalizaveis.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HSPAHR54()
Local oReport
If FindFunction("TRepInUse") .And. TRepInUse()
	Pergunte("HSPR54", .F.)
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	HSPAHR54R3()
EndIF

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณReportDef บAutor  ณPatricia Queiroz    บ Data ณ  06/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportDef()

Local oReport
Local oSection1
Local oTotaliz1, oTotaliz2

oReport := TReport():New("HSPAHR54", OemToAnsi(STR0001), "HSPR54", {|oReport| R54IMP(oReport)}, STR0018)
oReport:printtext("Periodo ===> : " + DTOC(MV_PAR01) + " a " + DTOC(MV_PAR02);
+ "Local: " + MV_PAR03 + " - " + POSICIONE("SX5", 1, xFilial("SX5") + "AL" + MV_PAR03 , "X5_DESCRI"))

oSection1 := TRSection():New(oReport, STR0020, {"SD3", "SBM"})  //"Movimenta็๕es/Grupo Produtos"
oSection1:SetHeaderBreak(.F.)
oSection1:SetPageBreak(.F.)
oSection1:SetHeaderPage(.T.)
oCell := TRCell():New(oSection1,"D3_GRUPO"  ,"SD3", STR0009)
oCell := TRCell():New(oSection1,"BM_DESC"   ,"SBM", STR0013)
oCell := TRCell():New(oSection1,"D3_ENTRADA",     , STR0014, "999,999,999.99")
oCell := TRCell():New(oSection1,"D3_SAIDA"  ,     , STR0015, "999,999,999.99")

oTotaliz1 := TRFunction():New(oSection1:Cell("D3_ENTRADA"),, "SUM",, STR0016,,,.F.,.T.)
oTotaliz2 := TRFunction():New(oSection1:Cell("D3_SAIDA")  ,, "SUM",, STR0017,,,.F.,.T.)

Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณR54Imp    บAutor  ณPatricia Queiroz    บ Data ณ  06/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R54IMP(oReport)
 Local oSection1 := oReport:Section(1)
 
 //-- Transforma parametros Range em expressao SQL
 MakeSqlExpr(oReport:uParam)         
 
 MakeSqlExp("HSPR54")
 oReport:Section(1):BeginQuery()
 BeginSql Alias "QRYSD3"
  SELECT D3_LOCAL, D3_GRUPO, BM_DESC, 
         SUM(CASE WHEN SD3.D3_TM <  '500' THEN SD3.D3_CUSTO1 ELSE 0 END) D3_ENTRADA, 
         SUM(CASE WHEN SD3.D3_TM >= '500' THEN SD3.D3_CUSTO1 ELSE 0 END) D3_SAIDA
  FROM %table:SD3% SD3  
  JOIN %table:SBM% SBM ON BM_GRUPO = D3_GRUPO AND BM_FILIAL = %xFilial:SBM% AND SBM.%NotDel%
  WHERE SD3.D3_FILIAL = %xFilial:SD3% AND SD3.%NotDel%
     AND SD3.D3_EMISSAO BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
     AND SD3.D3_LOCAL = %Exp:MV_PAR03% 
  GROUP BY D3_LOCAL, D3_GRUPO, BM_DESC    
  ORDER BY D3_GRUPO
 EndSql

 oSection1:EndQuery()
 
 oReport:SetMeter(QRYSD3->(LastRec()))
 oSection1:Print() 
 
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR54R3บ Autor ณ Equipe G. Hospitalar บ Data ณ 11/08/03  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Movimentacao Por Inventario (Sintetico)                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR54R3()
Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

If !Pergunte("HSPR54",.T.)
  Return(Nil)
EndIf

nMaxLin   := HS_MaxLin(cCODIMP)

cTitulo   := STR0001 //"Movimentacao Por Inventario (Sintetico)"
M_PAG     := 1
cTamanho  := "P" // P/M/G
nCaracter := 18
Limite    := 80  // 80/132/220
aOrdem    := {}  // Ordem do Relatorio
nLastKey  := 0
aReturn   := {STR0002, 1, STR0003, 1, 1, 1, "", 1} //"Zebrado"###"Administracao"
cNomProg  := "HSPAHR54"
cNomeRel  := "HSPAHR54"
aDriver   := LeDriver()
cCompac   := aDriver[1]
cNormal   := aDriver[2]
cDrive    := "Epson.drv"
cNomeImp  := "LPT1"
cAlias    := "SD3"
nLin      := 0

cNomeRel := SetPrint(cAlias, cNomeRel, Nil, @cTitulo, "", "", "", .F., "", .T., cTamanho, Nil, Nil, Nil)

If nLastKey == 27
 Return(Nil)
EndIf

SetDefault(aReturn, cAlias)

If nLastKey == 27
 Return
EndIf

Processa({|| RptProc() } )  //Gera e imprime o relatorio
Return(Nil)

///////////////////////////////////////////////////////////////
//   Funcao.:   RptProc                                      //
//   Objetivo.: Enviar o Relatorio para Tela ou Impressora   //
///////////////////////////////////////////////////////////////
Static Function RptProc()

Local nCt := 0

DbSelectArea("SD3")
DBGoTop()
nTReg := RecCount()

DBGoTop()
DbSetOrder(6) // filial, emissao , sequencia, chave, codigo
DbSeek(xFilial("SD3") + DTOS(MV_PAR01) + "  ",.T.)

ProcRegua(nTReg)

aDados := {}
Total1 := Total2 := 0

//1o Elemento - Grupo   	   C	3	0	C๓digo de Movimenta็ใo	     @!	    SD3->D3_GRUPO
//2o Elemento - Descricao      C	30	0	Descri็ใo da Movimenta็ใo    @!		SBM->BM_DESC
//3o Elemento - Total          N    15  4   Total do Consumo             @E     SD3->D3_QUANT * SD3->D3_CUSTO1

While !Eof() .And. DTOS(SD3->D3_EMISSAO) <= DTOS(MV_PAR02)
  If SD3->D3_LOCAL <> MV_PAR03
    DBskip()
    Loop
  EndIf
	
  Grupo := SD3->D3_GRUPO
	
  DbSelectArea("SBM")
  Dbsetorder(1)
  DbSeek(xFilial("SBM") + SD3->D3_GRUPO)
  If Found()
	Descricao := SBM->BM_DESC
  Else
    Descricao := Space(30)
  EndIf
  IncProc(STR0004 + DTOC(SD3->D3_EMISSAO)) //"Processando "
	
  nPos := Ascan(aDados,{|x| x[1] == SD3->D3_GRUPO})
	
  If nPos > 0
   If SD3->D3_TM < '500'
    aDados[nPos,3] := aDados[nPos,3] + SD3->D3_CUSTO1
   ElseIf SD3->D3_TM >= '500'
   	aDados[nPos,4] := aDados[nPos,4] + SD3->D3_CUSTO1
   EndIf
  Else
   If SD3->D3_TM < '500'
	   AADD(aDados, {Grupo, Descricao, SD3->D3_CUSTO1, 0})
	  ElseIf SD3->D3_TM >= '500'
	   AADD(aDados, {Grupo, Descricao, 0, SD3->D3_CUSTO1})
   EndIf
  EndIf
	
  DbSelectArea("SD3")
  DbSkip()
	
EndDo

Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer

DBSelectArea("SX5")
DBSetOrder(1)
DBSeek(xFilial("SX5") + "AL" + MV_PAR03)

aSort(aDados,,,{|x,y| x[1] < y[1]})
Setprc(0,0)

cCabec1 := STR0005 + DTOC(MV_PAR01) + STR0006 + DTOC(MV_PAR02) + STR0007 + MV_PAR03 + "-" + AllTrim(SX5->X5_DESCRI)  //"Periodo:  "###" a "###"   Almoxarifado.: "
cCabec2 := STR0008 //"Grupo    Descricao                                    ENTRADAS         SAIDAS"
cCab_   := Repl("-",80)
aTotal  := {0,0}

ProcRegua(Len(aDados))
For nCt := 1 to Len(aDados)
 IncProc(STR0009 + aDados[nCt,2]) //"Grupo"
 If (nLin == 0 .OR. nLin > nMaxLin)
  nLin := Cabec(ctitulo, cCabec1, cCabec2, cNomProg, cTamanho, nCaracter) + 1
 EndIf
	
 @ nLin,00 PSAY aDados[nCt,1]
 @ nLin,09 PSAY aDados[nCt,2]
 @ nLin,49 PSAY TRANSFORM(aDados[nCt,3], "@E 999,999,999.99")
 @ nLin,65 PSAY TRANSFORM(aDados[nCt,4], "@E 999,999,999.99")
 nLin++
 If nlin >= (nMaxLin - 2)
  nlin := 0
 EndIf
 aTotal[1] += aDados[nCt,3]
 aTotal[2] += aDados[nCt,4]
 
Next

If aTotal[1] > 0 .Or. aTotal[2] > 0
 @ nlin,00 PSAY Repl("_",80) ;  nLin++
 @ nLin,00 PSAY STR0010 //"Total Geral de Consumo"
 @ nLin,49 PSAY TRANSFORM(aTotal[1],"@E 999,999,999.99")
 @ nLin,65 PSAY TRANSFORM(aTotal[2],"@E 999,999,999.99")
 nLin++
EndIf

If aReturn[5] == 1
 DbCommitAll()
 SET PRINTER TO
 OurSpool(cNomeRel)
EndIf
Eject
Ms_Flush()
Return(Nil)