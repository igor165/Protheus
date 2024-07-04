#INCLUDE "HSPAHR62.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "Report.ch"
#define ESC          27

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR62  บ Autor ณ ANTONIO CARLOS     บ Data ณ  02/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ ALTAS NO PERIODO POR INTERVALOS DE ALTA                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObs:      ณ Convertido para relatorios personalizaveis                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR62()

Local oReport
Private nQtde:=0
If FindFunction("TRepInUse") .And. TRepInUse()
	pergunte("HSPR62",.F.)
	oReport := ReportDef()
	oReport:PrintDialog()
ELSE      
	HSPAHR62R3()
EndIF
Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ Antonio Carlos        ณ Data ณ 02/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
Local oReport
Local oSection1, oSection2
Local oCell
Local oTotaliz1
Local cPermaDias:= " "
Local nIntAMSP  := 0
Local nIntSPLL  := 0
Local nTotal    := 0

oReport := TReport():New("HSPAHR62",STR0003,"HSPR62",{|oReport| R62IMP(oReport)},STR0001 + " " + STR0002)  
 //"ALTAS NO PERIODO POR INTERVALOS DE ALTA " ### "Este programa tem como objetivo imprimir relatorio" ### "de acordo com os parametros informados pelo usuario."

oReport:SetLandscape()         // Imprimir relatorio em formato paisagem
//oReport:SetPortrait()          // Imprimir relatorio em formato retrato

oSection1 := TRSection():New(oReport,STR0023,{"GCY","GCS"})                  //"Setor"
oCell := TRCell():New(oSection1,"GCY_CODLOC","GCY",STR0004)                  //"S E T O R"
oCell := TRCell():New(oSection1,"GCS_NOMLOC","GCS"," ")                      
oCell := TRCell():New(oSection1,"Funcao","GCS",STR0012,,10,,   {||FS_ValLoc(("QRYGCY")->GCY_CODLOC)} )                      

oSection2 := TRSection():New(oSection1,STR0024,{"GCY","QRYGCY"})           //"Dados do Atendimento"
oSection2:SetNoFilter({"QRYGCY"})
oCell := TRCell():New(oSection2,"GCY_NOME","QRYGCY",STR0025)      	            //"Nome"
oCell := TRCell():New(oSection2,"GCY_REGATE","QRYGCY",STR0026)                //"Atendto"
oCell := TRCell():New(oSection2,"GCY_DATATE","QRYGCY",STR0027,,11)            //"Data Atend."
oCell := TRCell():New(oSection2,"GCY_HORATE","QRYGCY",STR0028,,6)             //"Hora"
oCell := TRCell():New(oSection2,"GCM_DESPLA","QRYGCY",STR0029,,25,,)          //"Plano"
oCell := TRCell():New(oSection2,"cPermaDias",,STR0030,,,,{||FS_Hora()})      //"Permanencia"
oCell := TRCell():New(oSection2,"GCY_DATALT","QRYGCY",STR0031,,11)            //"Alta Medica"
oCell := TRCell():New(oSection2,"GCY_HORALT","QRYGCY",STR0028)                //"Hora"
oCell := TRCell():New(oSection2,"GCY_DATSAI","QRYGCY",STR0032)                //"Saida Posto"
oCell := TRCell():New(oSection2,"GCY_HORSAI","QRYGCY",STR0028)                //"Hora"
oCell := TRCell():New(oSection2,"GCY_DATLIB","QRYGCY",STR0033,,11)            //"Lib. Leito"
oCell := TRCell():New(oSection2,"GCY_HORLIB","QRYGCY",STR0028)                //"Hora"
oCell := TRCell():New(oSection2,"nIntAMSP",,"AM/SP",,10)                     //"Intervalo AM/SP"
oCell := TRCell():New(oSection2,"nIntSPLL",,"SP/LL",,10)                     //"Intervalo SP/LL"
oCell := TRCell():New(oSection2,"nTotal",,STR0034,,10)                       //"Total"


oTotaliz1 := TRFunction():new(oSection2:Cell("GCY_DATALT"),,"ONPRINT",,STR0014,,{||(nQtde)},.F.)    //"Total
Return( oReport )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                                        ณ
//ณ Parametros para o construtor inicializar as variaveis de instancia :                                                                                    ณ
//ณ (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/,oSection,condition)  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ R62Imp   ณ Autor ณ Antonio Carlos        ณ Data ณ 04/07/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function R62IMP(oReport)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local cCond := ""
Local cfiltReg:=""

MakeSqlExp("HSPR62")
oReport:Section(1):BeginQuery()

If Empty(mv_par01) .or. Empty(mv_par02)
	Return( NIL )
EndIf

//cCond := "%" + SqlOrder(GCY->(IndexKey(1))) + "%"

BeginSql alias "QRYGCY"
 SELECT GCY_TPALTA, GCY_REGATE, GCY_REGGER, GCY_NOME, GCY_DATATE, GCY_HORATE, GCY_DATALT, GCY_HORALT, GCY_QUAINT,
 GCY_LEIINT, GCY_DATLIB, GCY_HORLIB, GCY_CODLOC, GCY_DATSAI, GCY_HORSAI, GCZ_CODPLA, GCS_NOMLOC, GCM_DESPLA
 FROM %table:GCY% GCY
 JOIN %table:GCZ% GCZ ON GCZ.GCZ_REGATE = GCY.GCY_REGATE AND GCZ.GCZ_FILIAL = %xFilial:GCZ% AND GCZ.%notDel%
 JOIN %table:GCM% GCM ON GCM.GCM_CODPLA = GCZ.GCZ_CODPLA AND GCM.GCM_FILIAL = %xFilial:GCM% AND GCM.%notDel%
 JOIN %table:GCS% GCS ON GCS.GCS_CODLOC = GCY.GCY_CODLOC AND GCS.GCS_FILIAL = %xFilial:GCS% AND GCS.%notDel% 
 WHERE GCY.GCY_FILIAL = %xfilial:GCY% AND GCY.%notDel%
 AND GCY.GCY_CODLOC BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
 AND GCY.GCY_DATALT BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
 //ORDER BY %Exp:cCond%
 ORDER BY   GCY_FILIAL,GCY_CODLOC, GCY_REGATE 
EndSql

 oSection1:EndQuery() 
While !Eof() 
	If ("QRYGCY")->GCY_REGATE <>cfiltReg 
 		nQtde++ 		
		cfiltReg :=("QRYGCY")->GCY_REGATE 
	Endif 
  DbSkip()

End
 oSection2:SetParentQuery()
	oSection2:SetParentFilter( {|G| ("QRYGCY")->GCY_CODLOC == G }, {|| ("QRYGCY")->GCY_CODLOC})
	oReport:SetMeter(QRYGCY->(LastRec()))
 oSection1:Print()

Return( NIL )


Static Function FS_Hora()
 Local nHora     := 0
 Local cPermaDias:= " "
 Local nIntAMSP  := 0
 Local nIntSPLL  := 0
 Local nTotal    := 0

	nHora := SubtHoras(QRYGCY->GCY_DATATE,QRYGCY->GCY_HORATE,QRYGCY->GCY_DATALT,QRYGCY->GCY_HORALT)
	If nHora >= 0         // PERMANENCIA EM DIAS
		cPermaDias := Str((nHora/24),4,0) + STR0008
	EndIf
	
	nIntAMSP := Str(SubtHoras((QRYGCY->GCY_DATALT),(QRYGCY->GCY_HORALT), (QRYGCY->GCY_DATSAI), (QRYGCY->GCY_HORSAI)) ,5,2) + STR0013
	nIntSPLL := Str(SubtHoras((QRYGCY->GCY_DATSAI) ,(QRYGCY->GCY_HORSAI) , (QRYGCY->GCY_DATLIB),(QRYGCY->GCY_HORLIB)),5,2) + STR0013
	nTotal   := Str((Val(nIntAMSP) + Val(nIntSPLL)) ,5,2) + STR0013

Return(cPermaDias,nIntAMSP,	nIntSPLL,nTotal)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR62  บ Autor ณ MARCELO JOSE       บ Data ณ  25/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ ALTAS NO PERIODO POR INTERVALOS DE ALTA                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR62R3()

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := STR0003 //"ALTAS NO PERIODO POR INTERVALOS DE ALTA "
Local cPict          := ""
Local titulo         := STR0003 //"ALTAS NO PERIODO POR INTERVALOS DE ALTA "
Local nLin           := 80
                           
Local Cabec1         := STR0004 //"S E T O R"
Local Cabec2         := STR0005  //Nome                                  Atendimento  Data Aten.  Hora  Plano                           Permanencia  Alta Medica  Hora   Saida do Posto  Hora  Lib. Leito  Hora   Intervalo AM\SP  Intervalo SP\LL  Total
Local imprime        := .T.
Local aOrd           := {}

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 132
Private tamanho      := "G"
Private nomeprog     := "HSPAHR62R3" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo        := 15
Private aReturn      := { STR0006, 1, STR0007, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHR62R3" /* Coloque aqui o nome do arquivo usado para impressao em disco */
Private cString      := "GCY"
Private cPerg        := "HSPR62"
Private aVetor       := {}
Private nTotGer      := 0

Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

If !Pergunte(cPerg,.T.)
	return
EndIf

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2

Processa({|| HS_MontaM()})

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

If nLastKey == ESC
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == ESC
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

//******************************************************************************************************************
//*****************************  Funcao HS_MontaM() monta matriz ***************************************************
//******************************************************************************************************************

Static Function HS_MontaM()

Local cNrseqg  := "", nHora := 0 
Local nIntAMSP := 0, 	nIntSPLL := 0
Local cRegtot:=""

#IFDEF TOP
	
	If TCSrvType() <> "AS/400"
		bWhile := {||!Eof()}
		cAliasGCY := "R62QRY"
		
		dbSelectArea("GCY")
		dbSetOrder(1)
		cQuery := "SELECT "
		cQuery += "GCY.GCY_TPALTA, GCY.GCY_REGATE, GCY.GCY_REGGER, GCY.GCY_NOME, GCY.GCY_DATATE, GCY.GCY_HORATE, "
		cQuery += "GCY.GCY_DATALT, GCY.GCY_HORALT, GCY.GCY_QUAINT, GCY.GCY_LEIINT, GCY.GCY_DATLIB, GCY.GCY_HORLIB, "
		cQuery += "GCY.GCY_CODLOC, GCS.GCS_NOMLOC, GCM.GCM_DESPLA, GCY.GCY_DATSAI, GCY.GCY_HORSAI "
		cQuery += "FROM " + RetSqlName("GCY") + " GCY "
		cQuery += "JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_REGATE = GCY.GCY_REGATE AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 	cQuery += "JOIN " + RetSqlName("GCM") + " GCM ON GCM.GCM_CODPLA = GCZ.GCZ_CODPLA AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
 	cQuery += "JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GCY.GCY_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' " 
		cQuery += "WHERE GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
		cQuery += "AND GCY.GCY_CODLOC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
		
		If !Empty(MV_PAR01) .AND. !Empty(MV_PAR02)
			cQuery += " AND GCY.GCY_DATALT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
		EndIf
//		cQuery += "ORDER BY "+SqlOrder(GCY->(IndexKey()))
		cQuery += "ORDER BY GCY.GCY_FILIAL, GCY.GCY_CODLOC, GCY.GCY_REGATE"
		
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasGCY,.T.,.T.)
		
		DbSelectArea(cAliasGCY)
		
		While (cAliasGCY)->(Eval(bWhile))
			
			cArqOld := Alias()
			

			AADD(aVetor,{"","","","","","","","","","","","","","","","",""} )
			aVetor[Len(aVetor), 1] := (cAliasGCY)->GCY_CODLOC
			aVetor[Len(aVetor), 2] := (cAliasGCY)->GCS_NOMLOC
			aVetor[Len(aVetor), 3] := (cAliasGCY)->GCY_NOME
			aVetor[Len(aVetor), 4] := (cAliasGCY)->GCY_REGATE
			aVetor[Len(aVetor), 5] := StoD((cAliasGCY)->GCY_DATATE)
			aVetor[Len(aVetor), 6] := (cAliasGCY)->GCY_HORATE
			aVetor[Len(aVetor), 7] := (cAliasGCY)->GCM_DESPLA
			
			nHora := SubtHoras(StoD( (cAliasGCY)->GCY_DATATE ),(cAliasGCY)->GCY_HORATE , StoD( (cAliasGCY)->GCY_DATALT ), (cAliasGCY)->GCY_HORALT )
			If nHora >= 0 /* PERMANENCIA EM DIAS */
				aVetor[Len(aVetor), 8] := nHora / 24
			EndIf

			aVetor[Len(aVetor), 9] := StoD((cAliasGCY)->GCY_DATALT )
			aVetor[Len(aVetor),10] := (cAliasGCY)->GCY_HORALT
			aVetor[Len(aVetor),11] := StoD((cAliasGCY)->GCY_DATSAI)
			aVetor[Len(aVetor),12] := (cAliasGCY)->GCY_HORSAI
			aVetor[Len(aVetor),13] := StoD((cAliasGCY)->GCY_DATLIB )
			aVetor[Len(aVetor),14] := (cAliasGCY)->GCY_HORLIB
			nIntAMSP := SubtHoras(StoD((cAliasGCY)->GCY_DATALT), (cAliasGCY)->GCY_HORALT, StoD((cAliasGCY)->GCY_DATSAI), (cAliasGCY)->GCY_HORSAI)
			nIntSPLL := SubtHoras(StoD((cAliasGCY)->GCY_DATSAI), (cAliasGCY)->GCY_HORSAI, StoD((cAliasGCY)->GCY_DATLIB), (cAliasGCY)->GCY_HORLIB)
			aVetor[Len(aVetor),15] := IIF(nIntAMSP >= 0, nIntAMSP, 0) 
			aVetor[Len(aVetor),16] := IIF(nIntSPLL >= 0, nIntSPLL, 0) 
			aVetor[Len(aVetor),17] := aVetor[Len(aVetor),15] + aVetor[Len(aVetor),16] 
			DbSelectArea(cArqOld)
			
			If aVetor[Len(aVetor), 4]<>cRegtot
				nTotGer++
				cRegtot:=aVetor[Len(aVetor), 4]
			Endif
			DbSkip()
		EndDo
	EndIf
	
	DbSelectArea(cAliasGCY)
	dbCloseArea()
	
#ENDIF

Return(Nil)

/*******************************************************************************************************************/
/* Funcao    RUNREPORT  Autor : AP6 IDE               Data   25/05/05                                              */
/* Descricao Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS monta a janela com a regua de processamento*/
/* Uso       Programa principal                                                                                    */
/*******************************************************************************************************************/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nTotal := 0, nCodVer := "", nCtaFor := 0
Local cRegAntes:="" 

If nLin > nMaxLin
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 10
Endif

For nCtaFor := 1 To LEN(aVetor)
	
	If lAbortPrint
		@nLin,00 PSAY STR0009 //"INTERROMPIDO PELO USUARIO"
		Exit
	Endif
	
	If nLin > nMaxLin
		@ nLin,01 Psay STR0010 //"continua..."
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 10
		If nCodVer == aVetor[nCtaFor,1]
			@ nLin,00 Psay STR0011 + aVetor[nCtaFor,2]  //"...continuacao de "
			nLin++
		Endif
	Endif
	
	If Len(aVetor) >= 1
		If nCtaFor == 1 .OR. nCodVer != aVetor[nCtaFor,1]
			If nCtaFor > 1
				nLin++
				@ nLin,00 Psay STR0012 + str(nTotal,3,0)  //"Total de Altas por setor: "
				nLin++
				@ nLin,00 Psay Replicate("_",228)
				nLIn++
				nTotal := 0
			Endif
			@ nLin,00 Psay aVetor[nCtaFor,1] + space(2) + aVetor[nCtaFor,2]
			nLin+=2
			nCodVer := aVetor[nCtaFor,1]
		ENDIF
	ENDIF
//          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21
//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//Nome                                  Atendimento  Data Aten.  Hora  Plano                           Permanencia  Alta Medica  Hora   Saida do Posto  Hora  Lib. Leito  Hora   Intervalo AM\SP  Intervalo SP\LL  Total

	@ nLin, 00 Psay SUBSTR(aVetor[nCtaFor, 3], 1, 35)
	@ nLin, 38 Psay aVetor[nCtaFor, 4]
	@ nLin, 51 Psay aVetor[nCtaFor, 5]
	@ nLin, 63 Psay aVetor[nCtaFor, 6]
	@ nLin, 69 Psay aVetor[nCtaFor, 7]
	@ nLin,101 Psay Transform(aVetor[nCtaFor, 8], "9999") + STR0008  //" dia(s)"
	@ nLin,114 Psay aVetor[nCtaFor, 9]
	@ nLin,127 Psay aVetor[nCtaFor,10] /*hora da alta  */
	@ nLin,134 Psay aVetor[nCtaFor,11] /*saida do posto*/
	@ nLin,150 Psay aVetor[nCtaFor,12]
	@ nLin,156 Psay aVetor[nCtaFor,13] /*libera leito  */
	@ nLin,168 Psay aVetor[nCtaFor,14]
	@ nLin,175 Psay Transform(aVetor[nCtaFor,15], "@E 99.99") + STR0013 //" hrs."
	@ nLin,192 Psay Transform(aVetor[nCtaFor,16], "@E 99.99") + STR0013 //" hrs."
	@ nLin,209 Psay Transform(aVetor[nCtaFor,17], "@E 99.99") + STR0013 //" hrs."
	
	nLin++
	If aVetor[nCtaFor, 4]<>cRegAntes 
		nTotal++
		cRegAntes:=aVetor[nCtaFor, 4]
	Endif
	
next
nLin++
@ nLin,00 Psay STR0012 + str(nTotal,3,0)  //"Total de Altas por setor: "
nLin++
@ nLin,00 Psay Replicate("_",220)
nLin++
@ nLin,00 Psay STR0014 + str(nTotGer,4,0)  //"Total de Altas no Periodo: "
nLin++
@ nLin,00 Psay Replicate("=",220)

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ValLoc  บAutor  ณMicrosiga           บ Data ณ  08/18/09  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalcula Quantidade alta  por setor Formato R4               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function FS_ValLoc(cCodLoc)
Local nQuanti:=0
Local cQuery:=""

cQuery := "SELECT "
cQuery += "COUNT(DISTINCT(GCY.GCY_REGATE)) AS QTDE
cQuery += "  FROM " + RetSqlName("GCY") + " GCY "
cQuery += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_REGATE = GCY.GCY_REGATE AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
cQuery += " JOIN " + RetSqlName("GCM") + " GCM ON GCM.GCM_CODPLA = GCZ.GCZ_CODPLA AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
cQuery += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GCY.GCY_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' " 
cQuery += " WHERE GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
cQuery += " AND GCY.GCY_CODLOC ='"+cCodLoc+"' " 
		
If !Empty(MV_PAR01) .AND. !Empty(MV_PAR02)
	cQuery += " AND GCY.GCY_DATALT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
EndIf

cQuery :=  ChangeQuery(cQuery)


TCQUERY cQuery NEW ALIAS "QRY_LOC"
DbSelectArea("QRY_LOC")
DbGoTop()
 
nQuanti:=QRY_LOC->QTDE
  
QRY_LOC->(dbCloseArea()) 
 
Return(nQuanti)
