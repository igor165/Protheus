#Include "HSPAHRDR.ch"
#Include "protheus.ch"
#include "TopConn.ch"
#INCLUDE "Report.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHRDR บ       ณ Antonio Carlos     บ Data ณ 21/08/2006  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Censo Ocupacional por Data                                 บฑฑ
ฑฑบ          ณ Conversใo para relatorios personalizaveis                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHRDR()

Local oReport
Private cGcsTipLoc := "3"

If FindFunction("TRepInUse") .And. TRepInUse()
 pergunte("HSPRDR",.F.)
 oReport := ReportDef()
 oReport:PrintDialog()
ELSE   
 HSPAHRDRR3()
EndIF
Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ Antonio Carlos        ณ Data ณ 21/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
Local oReport
Local oSection1, oSection2
Local oCell
Local oTotaliz1

oReport := TReport():New("HSPAHRDR",STR0003,"HSPRDR",{|oReport| RDRIMP(oReport)},STR0001 + " " + STR0002)  
 //"Censo Ocupacional por Data"### "Este programa tem como objetivo imprimir relatorio" ### "de acordo com os parametros informados pelo usuario."

oReport:SetLandscape()         // Imprimir relatorio em formato paisagem
//oReport:SetPortrait()          // Imprimir relatorio em formato retrato

oSection1 := TRSection():New(oReport,STR0011,{"GCY","GCS"})   //"Setor"
oSection1:SetPageBreak(.F.)
oSection1:SetHeaderBreak(.T.)    //Define se cabecalho das celulas sera impresso apos quebra TRBreak.
oCell := TRCell():New(oSection1,"GCY_CODLOC","GCY",) 
oCell := TRCell():New(oSection1,"GCS_NOMLOC","GCS",)    
 
oSection2 := TRSection():New(oSection1,STR0003,{"GCY","SRA","GCW","GCM"})
oSection2:SetPageBreak(.F.)
oSection2:SetHeaderPage(.T.)
oSection2:SetHeaderBreak(.F.)    //Define se cabecalho das celulas sera impresso apos quebra TRBreak.
oCell := TRCell():New(oSection2,"GCY_QUAINT","GCY",) 
oCell := TRCell():New(oSection2,"GCY_LEIINT","GCY",) 
oCell := TRCell():New(oSection2,"GCY_NOME","GCY",) 
oCell := TRCell():New(oSection2,"GCY_REGGER","GCY",) 
oCell := TRCell():New(oSection2,"GCY_REGATE","GCY",) 
oCell := TRCell():New(oSection2,"GCY_DATATE","GCY",)  //"Data..:"
oCell := TRCell():New(oSection2,"GCY_HORATE","GCY",) 
oCell := TRCell():New(oSection2,"cACOMPA","GCY",STR0017,,,,{||IIF(("QRYRDR")->GCY_ACOMPA=="0",STR0013,STR0014)})  //"Acomp."###"Sim"###"Nใo"
oCell := TRCell():New(oSection2,"GCM_DESPLA","GCM",STR0018)  //"Conv๋nio"
oCell := TRCell():New(oSection2,"RA_NOME","SRA",STR0019)      //"M้dico Resp."
oCell := TRCell():New(oSection2,"GCW_DESCLI","GCW",STR0020)  //"Clํnica"

oTotaliz1 := TRFunction():new(oSection2:Cell("GCY_LEIINT"),,"COUNT",,STR0010,,,.T.,.F.,.F.,,)   //"Total de Leitos no Setor"

Return( oReport )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                                        ณ
//ณ Parametros para o construtor inicializar as variaveis de instancia :                                                                                    ณ
//ณ (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/,oSection,condition)  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ RDRImp   ณ Autor ณ Antonio Carlos        ณ Data ณ 21/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function RDRIMP(oReport)

Local oSection1  := oReport:Section(1)
Local oSection2  := oReport:Section(1):Section(1)
Local cTipLoc    := "3"
Local cCtaPar    := "1"

MakeSqlExpr(oReport:uParam)
oSection1:BeginQuery()
BeginSql alias "QRYRDR"
 SELECT GCY_CODLOC, GCS_NOMLOC, GCY_QUAINT, GCY_LEIINT, GCY_NOME  , GCY_REGGER, GCY_REGATE, GCY_DATATE,; 
        GCY_HORATE, GD4_CODCON, GD4_CODPLA, GCY_ACOMPA, GCM_DESPLA, GCY_CODCRM, RA_NOME   , GCW_DESCLI 
 FROM %table:GCY% GCY                                   
 JOIN %table:GCS% GCS ON GCS.GCS_CODLOC = GCY.GCY_CODLOC AND GCS.GCS_FILIAL = %xFilial:GCS% AND GCS.%notDel% AND GCS.GCS_TIPLOC = %Exp:cTipLoc%
 JOIN %table:GD4% GD4 ON GD4.GD4_REGGER = GCY.GCY_REGGER AND GD4.GD4_FILIAL = %xFilial:GD4% AND GD4.GD4_IDPADR = %Exp:cCtaPar% AND GD4.%notDel%
 JOIN %table:GCM% GCM ON GCM.GCM_CODPLA = GD4.GD4_CODPLA AND GCM.GCM_FILIAL = %xFilial:GCM% AND GCM.%notDel%
 JOIN %table:SRA% SRA ON SRA.RA_CODIGO  = GCY.GCY_CODCRM AND SRA.RA_FILIAL  = %xFilial:SRA% AND SRA.%notDel%
 JOIN %table:GCW% GCW ON GCW.GCW_CODCLI = GCY.GCY_CODCLI AND GCW.GCW_FILIAL = %xFilial:GCW% AND GCW.%notDel%
 JOIN %table:GAV% GAV ON GAV.GAV_CODLOC = GCY.GCY_CODLOC AND GAV.GAV_QUARTO = GCY.GCY_QUAINT AND GAV.GAV_LEITO = GCY.GCY_LEIINT AND GAV.GAV_FILIAL = %xFilial:GAV% AND GAV.%notDel% AND GAV.GAV_ESTATI = '1'
 WHERE GCY.GCY_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% AND GCY.%notDel%
   AND GCY.GCY_TPALTA <> '99'
   AND GCY.GCY_DATSAI = ' '  
   AND GCY.GCY_CODLOC BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
   AND GD4.GD4_CODPLA BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
   AND GCY.GCY_CODCRM BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
   AND GCY.GCY_HORATE BETWEEN %Exp:MV_PAR09% AND %Exp:MV_PAR10%
   AND GCY.GCY_DATATE <= %Exp:MV_PAR11%
   AND GD4.GD4_CODCON BETWEEN %Exp:MV_PAR12% AND %Exp:MV_PAR13%
 ORDER BY GCY_CODLOC, GCY_LEIINT 
EndSql

 oSection1:EndQuery()
 oSection2:SetParentQuery()
 oSection2:SetParentFilter( {|G| ("QRYRDR")->GCY_CODLOC == G }, {|| ("QRYRDR")->GCY_CODLOC})
 
 oSection1:Print() // processa as informacoes da tabela principal
 oReport:SetMeter(QRYRDR->(LastRec()))
                   
Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRDRR3บ Autor ณ Mario Arizono      บ Data ณ  08/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Censo Ocupacional por Data                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAltera็๕esณ L.Gustavo Caloi 28/03/06 -> Padroniza็ใo da HS_MsgInf()    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHRDRR3()


/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ Declaracao de Variaveis                                             ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local titulo         := STR0003 //"Censo Ocupacional por Data"
Local nLin           := 80 
Local Cabec1         := ""
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd        := {}    

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "G"
Private nomeprog     := "HSPAHRDR" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo        := 18
Private aReturn      := {STR0004 , 1, STR0005, 2, 2, 1, "", 1}     //"Administracao"###"Zebrado"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHRDR" /* Coloque aqui o nome do arquivo usado para impressao em disco */
Private cPerg        := "HSPRDR"
Private cString  := ""

Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

/*
 ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ PARAMETROS                                                       ณ
 ณ MV_PAR01 Da Filial                                               ณ
 ณ MV_PAR02 Ate Filial                                              ณ
 ณ MV_PAR03 Do Setor                                                ณ
 ณ MV_PAR04 Ate Setor                                               ณ
 ณ MV_PAR05 Do Plano                                                ณ
 ณ MV_PAR06 Ate Plano                                               ณ
 ณ MV_PAR07 Do Medico                                               ณ
 ณ MV_PAR08 Ate Medico                                              ณ
 ณ MV_PAR09 Da Hora                                                 ณ
 ณ MV_PAR10 Ate Hora                                                ณ
 ณ MV_PAR11 Data                                                    ณ  
 ณ MV_PAR12 Do Convenio                                             ณ
 ณ MV_PAR13 Ate Convenio                                            ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

If !Pergunte(cPerg,.T.)
 return
EndIf

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
 Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)


RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Mario Arizono     บ Data ณ  08/07/05   บฑฑ
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

Local cSQL       := "" 
Private cCodLoc  := ""      
Private nTotLei  := 0

 cSQL := "SELECT GCY.GCY_CODLOC, GCS.GCS_NOMLOC, GCY.GCY_QUAINT, GCY.GCY_LEIINT, GCY.GCY_NOME, GCY.GCY_REGGER, GCY.GCY_REGATE, "
 cSQL += " GCY.GCY_DATATE, GCY.GCY_HORATE, GD4.GD4_CODCON, GD4.GD4_CODPLA, GCY.GCY_ACOMPA, GCM.GCM_DESPLA, GCY.GCY_CODCRM, SRA.RA_NOME, GCW.GCW_DESCLI "
 cSQL += " FROM " + RetSQLName("GCY") + " GCY"                                   
 cSQL += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GCY.GCY_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_TIPLOC = '3' "
 cSQL += " JOIN " + RetSQLName("GD4") + " GD4 ON GD4.GD4_REGGER = GCY.GCY_REGGER AND GD4.GD4_FILIAL = '" + xFilial("GD4") + "' AND GD4.D_E_L_E_T_ <> '*' AND GD4.GD4_IDPADR = '1' "
 cSQL += " JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_CODPLA = GD4.GD4_CODPLA AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO  = GCY.GCY_CODCRM AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GCW") + " GCW ON GCW.GCW_CODCLI = GCY.GCY_CODCLI AND GCW.GCW_FILIAL = '" + xFilial("GCW") + "' AND GCW.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GAV") + " GAV ON GAV.GAV_CODLOC = GCY.GCY_CODLOC AND GAV.GAV_QUARTO = GCY.GCY_QUAINT AND GAV.GAV_LEITO = GCY.GCY_LEIINT AND GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*' AND GAV.GAV_ESTATI = '1'"
 cSQL += " WHERE"
 cSQL += "     GCY.GCY_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "  
 cSQL += " AND GCY.GCY_TPALTA <> '99'"
 cSQL += " AND GCY.GCY_DATSAI = ' '"
 cSQL += " AND GCY.GCY_CODLOC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
 cSQL += " AND GD4.GD4_CODPLA BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
 cSQL += " AND GCY.GCY_CODCRM BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "    
 cSQL += " AND GCY.GCY_HORATE BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
 cSQL += " AND GCY.GCY_DATATE <= '" + DTOS(MV_PAR11) + "' 
 cSQL += " AND GD4.GD4_CODCON BETWEEN '" + MV_PAR12 + "' AND '" + MV_PAR13 + "' "
 cSQL += " ORDER BY GCY_CODLOC, GCY_LEIINT "
 
 cSQL :=  ChangeQuery(cSQL)

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
                                
 If Eof()
  HS_MsgInf(STR0006, STR0015, STR0016) //"Nenhum dado foi encontrado para a selecao efetuada!"###"Aten็ใo"###"Funcao aux. chamada pela RPTSTATUS"
 Endif

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

 SetRegua(100)

 While !EOF()

  IncRegua()
   
   If lAbortPrint
      @nLin,00 PSAY STR0007 //"*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif
   
   If nLin > nMaxLin
        /*                     1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
                     0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
 Cabec1 := STR0008//"Quarto  Leito  Nome                                          Pront.    Atend.  Hr.Ent. Acomp.  Convenio                                Medico Resp.                   Clinica"   
      Cabec2 := "" 
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 9
   Endif

  If cCodLoc <> QRY->GCY_CODLOC
    If !EMPTY(cCodLoc)
      @nLin,000 PSAY STR0010 + TRANSFORM(nTotLei, "@E 999999")    //"Total de Leitos no Setor......: "
       nLin +=2
    EndIf 
    //@nLin,000 PSAY STR0012 + DTOC(STOD(QRY->GCY_DATATE)) //"Data..:"     
    @nLin,000 PSAY STR0011 + QRY->GCY_CODLOC + " - " + QRY->GCS_NOMLOC  //"Setor..: "
    cCodLoc := QRY->GCY_CODLOC
    nTotLei := 0
    nLin +=2
  EndIf                                        
                    
  @nLin,000 PSAY QRY->GCY_QUAINT
  @nLin,008 PSAY QRY->GCY_LEIINT
  @nLin,015 PSAY QRY->GCY_NOME
  @nLin,061 PSAY QRY->GCY_REGGER
  @nLin,071 PSAY QRY->GCY_REGATE
  @nLin,079 PSAY DTOC(STOD(QRY->GCY_DATATE))   
  @nLin,091 PSAY QRY->GCY_HORATE
  DO CASE
   CASE QRY->GCY_ACOMPA == "0"
     @nLin,099 PSAY STR0013 //"Sim"
   CASE QRY->GCY_ACOMPA == "1"
     @nLin,099 PSAY STR0014 //"Nao"
  END CASE
  @nLin,107 PSAY QRY->GCM_DESPLA
  @nLin,137 PSAY QRY->RA_NOME
  @nLin,173 PSAY QRY->GCW_DESCLI
  nTotLei ++
  
  dbSkip() /* Avanca o ponteiro do registro no arquivo */  
  
  nLin +=2
  
  If EOF()
    @nLin,000 PSAY STR0010 + TRANSFORM(nTotLei, "@E 999999")    //"Total de Leitos no Setor......: "
  EndIf
 
EndDo
                                                                                        


/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ Finaliza a execucao do relatorio...                                 ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

SET DEVICE TO SCREEN

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ Se impressao em disco, chama o gerenciador de impressao...          ณ                                            
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()
DBCloseArea()

Return   
