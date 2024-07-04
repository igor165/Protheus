#include "protheus.ch"
#INCLUDE "REPORT.CH"
#INCLUDE "TECR890.CH"
Static cAutoPerg := "TECR890"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TECR890   ºAutor  ³Microsiga           º Data ³  24/03/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realizar a listagem dos funcionários que estão Afastados   º±±
±±º          ³ pelo INSS para controle do órgão regulamentador da área de º±±
±±º          ³ segurança (Policia Federal)                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TECR890()

Local oReport	:= Nil

Private cPerg	:= "TECR890"

Pergunte(cPerg,.F.)

oReport	:= ReportDef()
oReport:PrintDialog()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportDef ºAutor  ³Microsiga           º Data ³  24/03/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressão do relatório TECR890                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportDef()

Local oReport	:= Nil
Local oSection1	:= Nil
Local oSection2	:= Nil

Private cAliasSRA	:= "SRA"
If TYPE("cPerg") == "U"
	cPerg	:= "TECR890"
EndIf
oReport := TReport():New("TECR890",STR0001,cPerg,{|oReport| PrintReport(oReport)},STR0002) //"Relatorio de Afastados INSS" "Afastados INSS"

oSection1 := TRSection():New(oReport,STR0003,"SRJ") //"Funções"

TRCell():New(oSection1,"RJ_FUNCAO","SRJ")
TRCell():New(oSection1,"RJ_DESC","SRJ",STR0004) //"Nome da Função"

oSection2 := TRSection():New(oSection1,STR0005,"SRA") //"Funcionários"

TRCell():New(oSection2,"RA_MAT","SRA",STR0006) //"Código"
TRCell():New(oSection2,"RA_NOME","SRA",STR0007) //"Funcionário"
TRCell():New(oSection2,"ABS_LOCAL" ,/*Tabela*/,"Local",PesqPict("ABS","ABS_LOCAL"),TamSX3("ABS_LOCAL")[1],/*lPixel*/,{||Getlocal()})
TRCell():New(oSection2,"SITUAC",/*Tabela*/,STR0008,"@"						 ,15					,/*lPixel*/,{||STR0011})	// "Situação" "Afastado INSS"
TRCell():New(oSection2,"R8_TIPOAFA","SR8")
TRCell():New(oSection2,"R8_DATAINI","SR8")
TRCell():New(oSection2,"R8_DATAFIM","SR8")
TRCell():New(oSection2,"RA_TNOTRAB","SRA")
TRCell():New(oSection2,"ENTRA1" ,/*Tabela*/,STR0009,PesqPict("SPJ","PJ_ENTRA1"),TamSX3("PJ_ENTRA1")[1],/*lPixel*/,{||GetSPJ("ENTRA1")}) //"Início Turno"
TRCell():New(oSection2,"SAIDA2" ,/*Tabela*/,STR0010,PesqPict("SPJ","PJ_SAIDA2"),TamSX3("PJ_SAIDA2")[1],/*lPixel*/,{||GetSPJ("SAIDA2")}) //"Fim Turno"

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrintReportºAutor  ³Microsiga          º Data ³  24/03/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PrintReport(oReport)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local cFiltro   := ""
Local cSeek	  := ""

Private cAliasSRA	:= GetNextAlias()


cPart	:= "%"
cPart	+= " R8_TIPOAFA = '"+MV_PAR02+"' "
cPart  += " AND ((R8_DURACAO = '0' AND R8_DATAFIM = '') OR R8_DURACAO > '15') "
cPart	+= " AND R8_DATAINI < '"+Dtos(dDatabase-14)+"'"
cPart  += " AND (R8_DATAFIM >= '"+Dtos(dDatabase)+"' OR R8_DATAFIM = '') "

If !Empty(MV_PAR01)
	cPart	+= " AND RJ_FUNCAO = '"+MV_PAR01+"' AND "
Else
	cPart += " AND "
EndIf
cPart	+= "%"

oSection1:BeginQuery()

BeginSql Alias cAliasSRA
	
	SELECT 
		RA_FILIAL, RJ_FUNCAO, RJ_DESC, RA_MAT, 
		RA_NOME, RA_TNOTRAB, R8_TIPOAFA, R8_DATAINI, 
		R8_DATAFIM,R8_DURACAO,RA_VIEMRAI, RA_TIPOADM, 
		RA_CATFUNC
	FROM %table:SR8% SR8
	INNER JOIN
		%Table:SRA% SRA 
	ON 
		SRA.RA_FILIAL = %xfilial:SRA% 
	AND 
		SRA.RA_MAT = SR8.R8_MAT
	AND 
		SRA.%NotDel%
	INNER JOIN
		%Table:SRJ% SRJ 
	ON 
		SRJ.RJ_FILIAL = %xfilial:SRJ% 
	AND 
		SRJ.RJ_FUNCAO = SRA.RA_CODFUNC
	AND 
		SRJ.%NotDel%
	WHERE 
		%Exp:cPart%
		
		SR8.%NotDel%
	ORDER BY RA_MAT
	
EndSql

oSection1:EndQuery()

oSection2:SetParentQuery()
oSection2:SetParentFilter({|cParam| (cAlias)->RJ_FUNCAO == cParam .and. Fm400Filtro() },{|| (cAlias)->RJ_FUNCAO})


oSection1:Print()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Getlocal  ºAutor  ³Microsiga           º Data ³  30/03/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca o último local de alocação do funcionário            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Getlocal

Local aArea	:= GetArea()
Local cRet	:= ""
Local cMatric	:= (cAliasSRA)->RA_MAT
Local dDataIni	:= (cAliasSRA)->R8_DATAINI
Local cAliasTmp	:= GetNextAlias()
Local cFilter	:= ""

cFilter	+= "%"
cFilter	+= " AND AA1_CDFUNC = '"+cMatric+"'
cFilter	+= " AND ABB_DTINI <= '"+Dtos(dDataIni)+"'
cFilter	+= "%"


BeginSql Alias cAliasTmp
	
	SELECT ABB_CODTEC, 
			ABB_DTINI, 
			ABB_HRINI, 
			ABB_DTFIM, ABB_HRFIM, 
			ABS_LOCAL, 
			ABS_DESCRI
	FROM %table:ABB% ABB, 
		%table:ABS% ABS, 
		%table:AA1% AA1
	WHERE 
		ABB.%notDel%
	AND 
		ABS.%notDel%
	AND
		AA1.%notDel%
	AND 
		ABB_FILIAL = %xfilial:ABB%
	AND 
		ABS_FILIAL = %xfilial:ABS%
	AND 
		AA1_FILIAL = %xfilial:AA1%
	AND 
		ABB.ABB_LOCAL = ABS.ABS_LOCAL
	AND 
		ABB.ABB_CODTEC = AA1.AA1_CODTEC
		%Exp:cFilter%
	ORDER BY ABB_DTINI DESC, 
			ABB_HRINI DESC
	
EndSql


cRet	:= (cAliasTmp)->ABS_LOCAL

RestArea(aArea)

Return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Getlocal  ºAutor  ³Microsiga           º Data ³  30/03/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca o último local de alocação do funcionário            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GetSPJ(cEntSai)

Local aArea	:= GetArea()
Local aAreaSPJ	:= SPJ->(GetArea())
Local dRet	:= ctod("  /  /  ")
Local cTnotrab	:= (cAliasSRA)->RA_TNOTRAB
Local cAliasTmp	:= GetNextAlias()
Local cFilter	:= ""


//Posiciona no registro da tabela SPJ - Turno de trabalho
SPJ->(DbsetOrder(1))
SPJ->(DbSeek(xFilial("SPJ")+cTnotrab))
While SPJ->(!Eof()) .and. SPJ->PJ_FILIAL == xFilial("SPJ") .and. SPJ->PJ_TURNO == cTnotrab
	If SPJ->PJ_TPDIA == "S"
		If cEntSai == "ENTRA1"
			dRet	:= SPJ->PJ_ENTRA1
		Else
			dRet	:= SPJ->PJ_SAIDA2
		EndIf
		Exit
	EndIf
	SPJ->(Dbskip())
End

RestArea(aAreaSPJ)
RestArea(aArea)

Return dRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPergTRp
Retorna o nome do Pergunte utilizado no relatório
Função utilizada na automação
@author Mateus Boiani
@since 31/10/2018
@return cAutoPerg, string, nome do pergunte
/*/
//-------------------------------------------------------------------------------------
Static Function GetPergTRp()

Return cAutoPerg
