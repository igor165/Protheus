#INCLUDE "HSPAHRDE.ch"
#Include "protheus.ch"
#include "TopConn.ch"
#include "report.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRDE  บ Autor ณ Antonio/Marcelo    บ Data ณ  21/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Duplicidade de Pacientes                      บฑฑ 
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObs:      ณ Convertido para relatorios personalizaveis                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRDE()

Local oReport
 If FindFunction("TRepInUse") .And. TRepInUse() 
 	pergunte("HSPRDE",.F.)
  oReport := ReportDef() 
  oReport:PrintDialog()  
 ELSE  
  HSPAHRDER3()  
 EndIF    
Return( Nil )     

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ Antonio /Marcelo      ณ Data ณ 21/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
 Local oReport 
 Local oSection1, oSection2, oSection3
 Local oCell
 Local cResp := IIF(MV_PAR01==1,STR0009,IIF(MV_PAR01==2,STR0010,IIF(MV_PAR01==3,STR0011,IIF(MV_PAR01==4,STR0012,STR0009))))
 Local cPesquisa := STR0014+STR0013+cResp   //###==> Tipo de Pesquisa:"###"Por "

 oReport := TReport():New("HSPAHRDE",STR0003+" - "+cPesquisa,"HSPRDE",{|oReport| RDEIMP(oReport)}, STR0001 + STR0002 + STR0003)  //###"Duplicidade de Pacientes"### "Este programa tem como objetivo imprimir relatorio" ### "de acordo com os parametros informados pelo usuario."
 oReport:SetPortrait() 

 oSection1:= TRSection():New(oReport,STR0019,{"GBH"})
 oSection1:SetHeaderPage(.T.)
 oSection1:SetHeaderBreak(.F.)
 oSection1:SetCols(4)
 oSection1:SetReadOnly()
 oCell := TRCell():New(oSection1,"GBH_CODPAC","GBH",STR0019)  //"Paciente"
 oCell := TRCell():New(oSection1,"GBH_NOME"  ,"GBH"," ")
 oCell := TRCell():New(oSection1,"GBH_DTNASC","GBH",)
 oCell := TRCell():New(oSection1,"GBH_RG"    ,"GBH",)
 oCell := TRCell():New(oSection1,"GBH_CPF"   ,"GBH",)
 
Return( oReport )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ RDEImp   ณ Autor ณ MARCELO JOSE          ณ Data ณ 10/09/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function RDEIMP(oReport)

Local oSection1 := oReport:Section(1)
Local cCond1:= "%%"
Local cBuscChav := ""
Local cSpace    := ""

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)                      

If MV_PAR01 == 1      //Nome 
 cCond1    := "%GBH_NOME%"
 cSpace    := "%PGBH.GBH_NOME <> '"+Space( (TamSx3("GBH_NOME")[1]) )+"'%"
 cBuscChav := "%PGBH.GBH_NOME = GBH.GBH_NOME%"
ElseIf MV_PAR01 == 2  //Data Nascimento
 cCond1    := "%GBH_DTNASC%"                     
 cSpace    := "%PGBH.GBH_DTNASC <> '"+Space( (TamSx3("GBH_DTNASC")[1]) )+"'%"
 cBuscChav := "%PGBH.GBH_DTNASC = GBH.GBH_DTNASC%"
ElseIf MV_PAR01 == 3  //Identidade
 cCond1    := "%GBH_RG%"
 cSpace    := "%PGBH.GBH_RG <> '"+Space( (TamSx3("GBH_RG")[1]) )+"'%"
 cBuscChav := "%PGBH.GBH_RG = GBH.GBH_RG%"
ElseIf MV_PAR01 == 4  //C.P.F.
 cCond1    := "%GBH_CPF%"
 cSpace    := "%PGBH.GBH_CPF <> '"+Space( (TamSx3("GBH_CPF")[1]) )+"'%"
 cBuscChav := "%PGBH.GBH_CPF = GBH.GBH_CPF%"
Else 				          		 //TODOS
 cCond1    := "%GBH_NOME%"
 cSpace    := "%PGBH.GBH_NOME <> '"+Space( (TamSx3("GBH_NOME")[1]) )+"'"
 cSpace    += " AND PGBH.GBH_DTNASC <> '"+Space( (TamSx3("GBH_DTNASC")[1]) )+"'" 
 cSpace    += " AND PGBH.GBH_RG <> '"+Space( (TamSx3("GBH_RG")[1]) )+"'"
 cSpace    += " AND PGBH.GBH_CPF <> '"+Space( (TamSx3("GBH_CPF")[1]) )+"'%"
 cBuscChav := "%PGBH.GBH_NOME = GBH.GBH_NOME AND PGBH.GBH_DTNASC = GBH.GBH_DTNASC AND PGBH.GBH_RG = GBH.GBH_RG AND PGBH.GBH_CPF = GBH.GBH_CPF%"
EndIf     

oSection1:BeginQuery()
BeginSql alias "QRYRDE"
 SELECT GBH_CODPAC, GBH_NOME, GBH_DTNASC, GBH_RG, GBH_CPF
 FROM %table:GBH% GBH
 WHERE GBH.GBH_FILIAL = %xFilial:GBH% AND GBH.%NotDel%
 AND EXISTS
   ( SELECT GBH_NOME
    FROM %table:GBH% PGBH
    WHERE PGBH.GBH_FILIAL = %xFilial:GBH% AND PGBH.%NotDel%
    AND %Exp:cSpace%
    AND %Exp:cBuscChav%
    AND PGBH.GBH_CODPAC <> GBH.GBH_CODPAC )
 ORDER BY %Exp:cCond1%
EndSql
oSection1:EndQuery()
oSection1:Print() // processa as informacoes da tabela principal
oReport:SetMeter(QRYRDE->(LastRec()))
 
Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRDER3บ Autor ณ Cibele Peria       บ Data ณ  16/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Duplicidade de Pacientes                      บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAltera็๕esณ L.Gustavo Caloi 28/03/06 -> Padroniza็ใo da HS_MsgInf()    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRDER3()

 Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2 := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3 := STR0003 //"Duplicidade de Pacientes"
 Local aOrd   := {}
 Private nPesquisa := 0
 Private Titulo := cDesc3
 Private Cabec1 := STR0004 //"Paciente                                 Paciente"
//                  0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.
 Private Cabec2 := STR0005 //"Dt Nasc. Identidade      C.P.F           Dt Nasc. Identidade      C.P.F"
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 180
 Private Tamanho     := "P"
 Private NomeProg    := "HSPAHRDE" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo       := 18
 Private aReturn     := { STR0006, 1, STR0007, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
 Private nLastKey    := 0
 Private cbtxt       := Space(10)
 Private cbcont      := 00
 Private CONTFL      := 01
 Private m_pag       := 01
 Private wnrel       := NomeProg
 Private nTam        := 80 

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ PARAMETROS                                                         ณ
 //ณ MV_PAR01	Pesquisar por                                             ณ
 //| MV_PAR02 Impressora ?                                              |
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 cPerg := "HSPRDE"

 If !Pergunte(cPerg,.T.)
  return
 EndIf

 nMaxLin := HS_MaxLin(cCODIMP)
 
 nPesquisa  := mv_par01

 wnrel := SetPrint("GBH", NomeProg, "", @Titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 If nLastKey == 27
  Return()
 Endif

 SetDefault(aReturn, "GBH")
 If nLastKey == 27
  Return()
 Endif

 nTipo := If(aReturn[4]==1,15,18)
 RptStatus({|| RunReport(nPesquisa) }, Titulo)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Cibele Peria       บ Data ณ  09/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de execucao do relatorio                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport(nPesquisa)
 Local   cSql    := ""
 Private cChave  := "", cChave_Ant := ""
 Private cCodPac_Ant := ""
 Private cNome_Ant   := ""
 Private dDtNasc_Ant := ""
 Private cRG_Ant     := ""
 Private cCPF_Ant    := ""
 Private cChave_Imp  := ""
 Private nLin        := nMaxLin * 2
 Private nLin1   := 0
 Private nLin2   := 0
 Private nOpcao  := IIF(nPesquisa == 5, 1, nPesquisa)
 Private aImp    := {}
 Private cPesquisa := ""
 Private lPriPag   := .T.
 
 Private lLoop  := .T.
 While lLoop
  cSQL := FS_SQL(nOpcao)
  TCQUERY cSQL NEW ALIAS "QRY"
  DbSelectArea("QRY")
  If Eof()
   HS_MsgInf(STR0008, STR0017, STR0018) //"Nenhum dado foi encontrado para a selecao efetuada."###"Aten็ใo"###"Rotina de execucao do relatorio"
   DbCloseArea()
   Return()
  Endif
  cChave_Ant := ""
  cChave_Imp := ""
  aImp       := {}
  nLin       :=  nMaxLin * 2
  lPriPag    := .T.
  
  If nOpcao == 1
   cPesquisa := STR0009 //"Nome"
  ElseIf nOpcao == 2
   cPesquisa := STR0010 //"Data Nascimento"
  ElseIf nOpcao == 3
   cPesquisa := STR0011 //"Identidade"
  ElseIf nOpcao == 4
   cPesquisa := STR0012 //"C.P.F."
  Endif
  cPesquisa := STR0013 + cPesquisa //"Por "
  
  //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
  //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
  DbSelectArea("GBH")
  SetRegua(RecCount())
  DbSelectArea("QRY")
  DbGoTop()
  While !EOF()                                                                                
   IncRegua()
   
   If nOpcao == 1
    cChave := QRY->GBH_NOME
   ElseIf nOpcao == 2
    cChave := QRY->GBH_DTNASC + QRY->GBH_NOME
   ElseIf nOpcao == 3
    cChave := QRY->GBH_RG
   ElseIf nOpcao == 4
    cChave := QRY->GBH_CPF
   Endif
        
   If !Empty(cChave)
    If !Empty(cChave_Ant)
     If cChave == cChave_Ant
      FS_Imprime(cChave)
     Endif
    Endif
 
    cChave_Ant  := cChave
    cCodPac_Ant := QRY->GBH_CODPAC
    cNome_Ant   := QRY->GBH_NOME
    dDtNasc_Ant := QRY->GBH_DTNASC
    cRG_Ant     := QRY->GBH_RG
    cCPF_Ant    := QRY->GBH_CPF
   
   Endif 
   DbSkip()

  End
  If len(aImp) > 0
   FS_Imp()
  Endif
  DbCloseArea()  
  
  If nPesquisa == 5 //Se for a opcao Todos, tem que processar todos os selects.
   If nOpcao < 4
    nOpcao += 1
   Else
    lLoop := .F.
   Endif  
  Else
   lLoop := .F.
  Endif
   
 End
 
   
 SET DEVICE TO SCREEN
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH()

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Imprimeบ Autor ณ Cibele Peria       บ Data ณ  16/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Impressao da duplicidade                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Imprime()
         
 If (!Empty(cChave_Imp) .and. cChave_Ant <> cChave_Imp) .or. len(aImp) == 2
  FS_Imp()
  aImp := {}
 Endif
 
 If cChave_Ant <> cChave_Imp
  aAdd(aImp, {cCodPac_Ant, cNome_Ant, dDtNasc_Ant, cRG_Ant, cCPF_Ant} )
  cChave_Imp := cChave_Ant
 Endif
 
 aAdd(aImp, {QRY->GBH_CODPAC, QRY->GBH_NOME, QRY->GBH_DTNASC, QRY->GBH_RG, QRY->GBH_CPF} )
 
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Imp    บ Autor ณ Cibele Peria       บ Data ณ  16/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Impressao dos dados do paciente                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Imp()
 Local nCol1 := 0, nCol2 := 41
 
 If nLin+2 > nMaxLin
  FS_Cabec()
 Endif

 nLin += 1
 @nLin, nCol1 PSAY aImp[1,1] + "-" + SUBSTR(aImp[1,2], 1, 32)
 If len(aImp) == 2
  @nLin, nCol2 PSAY aImp[2,1] + "-" + SUBSTR(aImp[2,2], 1, 32)  
 Endif 
 nLin += 1
 @nLin, nCol1    PSAY STOD(aImp[1,3])
 @nLin, nCol1+9  PSAY aImp[1,4]
 @nLin, nCol1+25 PSAY TRANSFORM(aImp[1,5], "@R 999.999.999-99")
 If len(aImp) == 2
  @nLin, nCol2    PSAY STOD(aImp[2,3])
  @nLin, nCol2+9  PSAY aImp[2,4]
  @nLin, nCol2+25 PSAY TRANSFORM(aImp[2,5], "@R 999.999.999-99")
 Endif 

 nLin += 1 
Return()
        
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Cibele Peria       บ Data ณ  16/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Cabecalho do relatorio                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Cabec()
 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, ,.T.) 
 nLin := 8
 If lPriPag
  nLin += 1
  @nLin, 000 PSAY STR0014 + cPesquisa //"===> Tipo de Pesquisa: "
  nLin += 1
  lPriPag := .F.
 Endif 
Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_SQL    บ Autor ณ Cibele Peria       บ Data ณ  16/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Monta comando SQL conforme opcao de pesquisa               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_SQL(nOpcao)
 Local cSQL := ""
   
 cSQL := "SELECT"
 cSQL += " GBH.GBH_CODPAC, GBH.GBH_NOME, GBH.GBH_DTNASC, GBH.GBH_RG, GBH.GBH_CPF"
 cSQL += " FROM " + RetSQLName("GBH") + " GBH"
 cSQL += " WHERE GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*'"
 If nOpcao == 1
  cSQL += " ORDER BY GBH.GBH_NOME, GBH.GBH_CODPAC"
 ElseIf nOpcao == 2 
  cSQL += " ORDER BY GBH.GBH_DTNASC, GBH.GBH_NOME, GBH_CODPAC"
 ElseIf nOpcao == 3 
  cSQL += " ORDER BY GBH.GBH_RG, GBH.GBH_NOME, GBH.GBH_CODPAC"
 ElseIf nOpcao == 4 
  cSQL += " ORDER BY GBH.GBH_CPF, GBH.GBH_NOME, GBH.GBH_CODPAC"
 Endif
 
Return(cSQL)