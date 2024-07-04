#INCLUDE "HSPAHRC7.ch"
#INCLUDE "PROTHEUS.CH"
#include "TopConn.ch"
#INCLUDE "Report.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHRC7 บ       ณ Antonio Carlos     บ Data ณ 22/08/2006  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio para solicitacao de detalhamento dos valores     บฑฑ
ฑฑบ          ณ pagos / glosados pelo convenio.                            บฑฑ
ฑฑบ          ณ Conversใo para relatorios personalizaveis                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHRC7()

Local oReport
If FindFunction("TRepInUse") .And. TRepInUse()
	pergunte("HSPRC7",.F.)
	oReport := ReportDef()
	oReport:PrintDialog()
ELSE
	HSPAHRC7R3()
EndIF
Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ Antonio Carlos        ณ Data ณ 22/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
Local oReport
Local oSection1, oSection2
Local oCell
Local oTotaliz1

oReport := TReport():New("HSPAHRC7",STR0003,"HSPRC7",{|oReport| RC7IMP(oReport)},STR0001 + " " + STR0002)  
 //"Solicita็ใo de Detalhamento"### "Este programa tem como objetivo imprimir relatorio" ### "de acordo com os parametros informados pelo usuario."

oReport:SetLandscape()         // Imprimir relatorio em formato paisagem
//oReport:SetPortrait()          // Imprimir relatorio em formato retrato

oSection1 := TRSection():New(oReport,"Detalhamento",{"GCZ","GBH","GA9","GCM"})
oSection1:SetPageBreak(.F.)
oSection1:SetHeaderPage(.T.)
oSection1:SetHeaderBreak(.F.)    //Define se cabecalho das celulas sera impresso apos quebra TRBreak.
oCell := TRCell():New(oSection1,"GCZ_NRGUIA","GCZ",) 
oCell := TRCell():New(oSection1,"GCZ_REGATE","GCZ",) 
oCell := TRCell():New(oSection1,"GCZ_REGGER","GCZ",STR0016)  //"Paciente"
oCell := TRCell():New(oSection1,"GBH_NOME"  ,"GBH"," ") 
oCell := TRCell():New(oSection1,"GCZ_NRSEQG","GCZ",) 
oCell := TRCell():New(oSection1,"GCZ_CODCON","GCZ",STR0012)  //"Conv๋nio"
oCell := TRCell():New(oSection1,"GA9_NREDUZ","GA9"," ") 
oCell := TRCell():New(oSection1,"GCZ_CODPLA","GCZ",STR0013)  //"Plano"
oCell := TRCell():New(oSection1,"GCM_DESPLA","GCM"," ") 
oCell := TRCell():New(oSection1,"GCZ_VALPAG","GCZ",STR0014)  //"Valor Pago"
oCell := TRCell():New(oSection1,"GCZ_VALGLO","GCZ",STR0015)  //"Valor Glosa"

Return( oReport )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                                        ณ
//ณ Parametros para o construtor inicializar as variaveis de instancia :                                                                                    ณ
//ณ (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/,oSection,condition)  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ RC7Imp   ณ Autor ณ Antonio Carlos        ณ Data ณ 22/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function RC7IMP(oReport)

Local oSection1  := oReport:Section(1)
Local	cCond := "%%"

MakeSqlExpr(oReport:uParam)

If mv_par13 == 1
	cCond := "%AND GCZ.GCZ_NRRPT1 BETWEEN '" + mv_par14 + "' AND '" + mv_par15 + ;
	         "'AND GCZ.GCZ_DTRPT1 BETWEEN '" + DTOS(mv_par16) + "' AND	'" + DTOS(mv_par17) + "'%"
Else
	cCond := "%GCZ_NRRPT1 = ' ' AND GCZ_NRGUIA BETWEEN '" +  mv_par01 + "' AND '" + mv_par02 + ;
	         "' AND GCZ_CODCON BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + ;
	         "' AND GCZ_CODPLA BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + ;
	         "' AND GCZ_DATFAT BETWEEN '" + DTOS(mv_par07) + "' AND '" + DTOS(mv_par08) + ;
	         "' AND GCZ_REGATE BETWEEN '" + mv_par11 + "' AND '" + mv_par12 + ;
	         "' AND GCY_REGGER BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + ;
	         "' AND GCZ_VALPAG > 0 AND GCZ_VALGLO > 0 AND GCZ_VLPAGM = 0 AND GCZ_VLGLOM = 0 AND GCZ_VLPAGT = 0 AND GCZ_VLGLOT = 0 AND GCZ_VLPAGP = 0 AND GCZ_VLGLOP = 0%" 
EndIf

oSection1:BeginQuery()
BeginSql alias "QRYRC7"
SELECT GCZ_NRGUIA, GCZ_NRSEQG, GCZ_REGGER, GBH_NOME, GCZ_REGATE, GCZ_CODPLA, GCM_DESPLA, GCZ_CODCON,;
       GA9_NREDUZ, GCZ_VALPAG, GCZ_VALGLO, GCZ.R_E_C_N_O_  
FROM %table:GA9% GA9, %table:GBH% GBH, %table:GCM% GCM, %table:GCY% GCY, %table:GCZ% GCZ 
WHERE GA9.%notDel% AND GBH.%notDel% AND GCM.%notDel% AND GCZ.%notDel% AND GCY.%notDel% 
  AND GA9_FILIAL = %xFilial:GA9% AND GBH_FILIAL = %xFilial:GBH% AND GCM_FILIAL = %xFilial:GCM%  
  AND GCZ_FILIAL = %xFilial:GCZ% AND GCY_FILIAL = %xFilial:GCY%  
  AND GCZ_REGATE = GCY_REGATE AND GCZ_CODCON = GA9_CODCON AND GCZ_CODCON = GCM_CODCON  
  AND GCZ_CODPLA = GCM_CODPLA AND GBH_CODPAC = GCY_REGGER  
  AND %Exp:cCond%
  ORDER BY GCZ_REGGER, GCZ_REGATE, GCZ_NRGUIA, GCZ_NRSEQG
EndSql

	oSection1:EndQuery()
 oSection1:Print() // processa as informacoes da tabela principal
 oReport:SetMeter(QRYRC7->(LastRec()))
                   
Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRC7R3บ Autor ณ Alessandro Freire  บ Data ณ  17/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio para solicitacao de detalhamento dos valores     บฑฑ
ฑฑบ          ณ pagos / glosados pelo convenio.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ 
ฑฑบAltera็๕esณ L.Gustavo Caloi 28/03/06 -> Padroniza็ใo da HS_MsgInf()    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHRC7R3()

Local cDesc1        := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3        := STR0003 //"Solicita็ใo de Detalhamento"
Local cPict         := ""
Local titulo       	:= STR0003 //"Solicita็ใo de Detalhamento"
Local nLin         	:= 80

Local Cabec1       	:= STR0004 //"Guia                        R.A.   Paciente                                             Convenio                 Plano                                   Valor Pago   Valor Glosa"
Local Cabec2       	:= ""
Local imprime      	:= .T.
Local aOrd										:= {}

Private lEnd        := .F.
Private lAbortPrint	:= .F.
Private limite      := 220
Private tamanho    	:= "G"
Private nomeprog    := "HSPAHRC7"
Private nTipo       := 15
Private aReturn     := { STR0005, 1, STR0006, 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey    := 0
Private cPerg       := "HSPRC7"
Private cbtxt      	:= Space(10)
Private cbcont     	:= 00
Private CONTFL     	:= 01
Private m_pag      	:= 01
Private wnrel      	:= "HSPAHRC7"

Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

dbSelectArea("GCZ")
dbSetOrder(1)

pergunte(cPerg,.T.)

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2

wnrel := SetPrint("GCZ",NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,"GCZ")

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Alessandro Freire  บ Data ณ  17/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local cQry						:= ""
Local cSeq						:= GetSxeNum("GCZ", "GCZ_NRRPT1")
Local lImpresso	:= .f.
Local aNrSeqG			:= {}
Local ni								:= 0

/*
01 - Guia Inicial
02 - Guia Final
03 - Convenio Inicial
04 - Convenio Final
05 - Plano Inicial
06 - Plano Final
07 - Faturado de
08 - Faturado Ate
09 - Paciente de
10 - Paciente at้
11 - Registro de
12 - Registro at้
13 - Reemissao 1= sim, 2=nao
14 - Numero de
15 - Numero at้
16 - Emissao de
17 - Emissao at้
*/

// Executa a query para buscar os resultados

cQry := "SELECT GCZ_NRGUIA TRB_NRGUIA, GCZ_NRSEQG TRB_NRSEQG, GCZ_REGGER TRB_REGGER, GBH_NOME TRB_NOME, "
cQry += "       GCZ_REGATE TRB_REGATE, GCZ_CODPLA TRB_CODPLA, GCM_DESPLA TRB_DESPLA, GCZ_CODCON TRB_CODCON,"
cQry += "       GA9_NREDUZ TRB_NREDUZ, GCZ_VALPAG TRB_VALPAG, GCZ_VALGLO TRB_VALGLO, GCZ.R_E_C_N_O_ TRB_REC "

cQry += "FROM "+RetSqlName("GA9")+" GA9, "+RetSqlName("GBH")+" GBH, "+RetSqlName("GCM")+" GCM, "+RetSqlName("GCY")+" GCY, "+RetSqlName("GCZ")+" GCZ "

cQry += "WHERE GA9.D_E_L_E_T_ <> '*' AND "
cQry += "      GBH.D_E_L_E_T_ <> '*' AND "
cQry += "      GCM.D_E_L_E_T_ <> '*' AND "
cQry += "      GCZ.D_E_L_E_T_ <> '*' AND "
cQry += "      GCY.D_E_L_E_T_ <> '*' AND "

cQry += "      GA9_FILIAL = '" + xFilial("GA9") + "' AND "
cQry += "      GBH_FILIAL = '" + xFilial("GBH") + "' AND "
cQry += "      GCM_FILIAL = '" + xFilial("GCM") + "' AND "
cQry += "      GCZ_FILIAL = '" + xFilial("GCZ") + "' AND "
cQry += "      GCY_FILIAL = '" + xFilial("GCY") + "' AND "
If mv_par13 == 1
	cQry += "     GCZ_NRRPT1 BETWEEN '" + mv_par14 + "' AND '" + mv_par15 + "' AND "
	cQry += "     GCZ_DTRPT1 BETWEEN '" + DTOS(mv_par16) + "' AND '" + DTOS(mv_par17) + "' AND "
Else
	cQry += "      GCZ_NRRPT1 = ' ' AND "
	cQry += "      GCZ_NRGUIA BETWEEN '" + mv_par01 + "' AND '"+mv_par02+"' AND "
	cQry += "      GCZ_CODCON BETWEEN '" + mv_par03 + "' AND '"+mv_par04+"' AND "
	cQry += "      GCZ_CODPLA BETWEEN '" + mv_par05 + "' AND '"+mv_par06+"' AND "
	cQry += "      GCZ_DATFAT BETWEEN '" + DTOS(mv_par07)+ "' AND '" + DTOS(mv_par08) + "' AND "
	cQry += "      GCZ_REGATE BETWEEN '" + mv_par11 + "' AND '" + mv_par12 + "' AND "
	cQry += "      GCY_REGGER BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "' AND "

	cQry += "      GCZ_VALPAG > 0 AND "
	cQry += "      GCZ_VALGLO > 0 AND "
	cQry += "      GCZ_VLPAGM = 0 AND "
	cQry += "      GCZ_VLGLOM = 0 AND "
	cQry += "      GCZ_VLPAGT = 0 AND "
	cQry += "      GCZ_VLGLOT = 0 AND "
	cQry += "      GCZ_VLPAGP = 0 AND "
	cQry += "      GCZ_VLGLOP = 0 AND "
EndIf
cQry += "      GCZ_REGATE = GCY_REGATE AND "
cQry += "      GCZ_CODCON = GA9_CODCON AND "
cQry += "      GCZ_CODCON = GCM_CODCON AND "
cQry += "      GCZ_CODPLA = GCM_CODPLA AND "
cQry += "      GBH_CODPAC = GCY_REGGER "

cQry += " ORDER BY TRB_REGGER, TRB_REGATE, TRB_NRGUIA, TRB_NRSEQG"
cQry := ChangeQuery(cQry)

dbUseArea(.t.,"TOPCONN",TcGenQry(,,cQry),"TRB",.f.,.f.)

dbSelectArea("TRB")
SetRegua(RecCount())
dbGoTop()

While !EOF()
	
	If lAbortPrint
		@nLin,00 PSAY STR0007 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Impressao do cabecalho do relatorio. . .                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	If nLin > nMaxLin
		Cabec(Titulo + STR0008 + cSeq,Cabec1,Cabec2,NomeProg,Tamanho,nTipo) //" - Documento No. "
		nLin := 8
	Endif
	
	@ nLin,000 PSAY ALLTRIM(TRB->TRB_NRGUIA) +"/"+ TRB->TRB_NRSEQG
	@ nLin,028 PSAY TRB->TRB_REGATE
	@ nLin,035 PSAY TRB->TRB_REGGER + "-"
	@ nLin,042 PSAY TRB->TRB_NOME
	@ nLin,088 PSAY TRB->TRB_CODCON + "-"
	@ nLin,092 PSAY TRB->TRB_NREDUZ 
	@ nLin,113 PSAY TRB->TRB_CODPLA + "-"
	@ nLin,120 PSAY TRB->TRB_DESPLA
	@ nLin,152 PSAY TRB->TRB_VALPAG PICTURE "@E 99,999.9999"
	@ nLin,166 PSAY TRB->TRB_VALGLO PICTURE "@E 99,999.9999"
	
	nLin := nLin + 1
	AAdd(aNrSeqG, TRB->TRB_NRSEQG)
	
	dbSkip()
EndDo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SET DEVICE TO SCREEN


If mv_par13 == 2
	cQry := "UPDATE "+RetSqlName("GCZ")+" "
	cQry += "SET GCZ_NRRPT1 = '" + cSeq + "', "
	cQry += "    GCZ_DTRPT1 = '" + DTOS(dDataBase) + "', "

	cQry += "    GCZ_STATUS = '6' "
	
	cQry += " WHERE GCZ_NRSEQG IN ( "
	                                 
	For nI := 1 to Len(aNrSeqG)
		cQry += "'" + aNrSeqG[nI] + "'" + iif(len(aNrSeqG) < nI, ", ", "")
	Next nI
	
	cQry += " )"
	TcSqlExec(cQry)		
EndIf


If lImpresso
	HS_MsgInf( STR0009 + AllTrim(Str(nSeq)), STR0010,  STR0011) //"Na necessidade de reemissใo, o n๚mero desta solicita็ใo ้ "###"Aten็ใo"###"Rotina de Finaliza็ใo de relatorio"
EndIf

dbSelectArea("TRB")
dbCloseArea()

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return