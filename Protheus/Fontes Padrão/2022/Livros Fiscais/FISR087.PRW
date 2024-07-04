#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "FWCOMMAND.CH"
/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exemplo de relatorio usando tReport com uma Section
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC*/

Function FISR087()

local oReport
local cAlias := getNextAlias()
lOCAL cMsgX1	:= ''
Local lContinua	:= .T.

IF SF3->(Columnpos('F3_DIFAL')) > 0

	If Pergunte('FSR087', .T.)
		
		cMsgX1		:= VldSx1()		
		If len(Alltrim(cMsgX1)) > 0				
			MsgAlert(cMsgX1)
			lContinua	:= .F.		
		EndIF
		
		If lContinua
			oReport := reportDef(cAlias, 'FSR087')
			oReport:printDialog()
		EndIF
	EndIf
Else
	Alert('Dicionário desatualizado, favor verificar atualizações sobre a EC 87/15')
EndIF

return
        
//+-----------------------------------------------------------------------------------------------+
//! Rotina para montagem dos dados do relatório.                                  !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportPrint(oReport,cAlias)
              
local oSecao1 := oReport:Section(1)
Local cAliasQry := GetNextAlias()
Local oQuadro		:= oReport:Section(1)
Local oTFont 		:= TFont():New('Arial',,11,,.T.)
Local aEstado		:= {}
Local cUfIE		:= ''
Local nX	:= 0
Local cFiltro	:= ''
Local cJoin		:= ''
Local aSelFil	:={}
local aFil	:= {}
Local nContFil	:= 0
Local aAreaSM0 := SM0->(GetArea())

Aadd(aEstado,{'AC'})
Aadd(aEstado,{'AL'})
Aadd(aEstado,{'AP'})
Aadd(aEstado,{'AM'})
Aadd(aEstado,{'BA'})
Aadd(aEstado,{'CE'})
Aadd(aEstado,{'DF'})
Aadd(aEstado,{'ES'})
Aadd(aEstado,{'GO'})
Aadd(aEstado,{'MA'})
Aadd(aEstado,{'MT'})
Aadd(aEstado,{'MS'})
Aadd(aEstado,{'MG'})
Aadd(aEstado,{'PA'})
Aadd(aEstado,{'PB'})
Aadd(aEstado,{'PR'})
Aadd(aEstado,{'PE'})		
Aadd(aEstado,{'PI'})
Aadd(aEstado,{'RJ'})
Aadd(aEstado,{'RN'})		
Aadd(aEstado,{'RS'})
Aadd(aEstado,{'RO'})
Aadd(aEstado,{'RR'})
Aadd(aEstado,{'SC'})
Aadd(aEstado,{'SP'})
Aadd(aEstado,{'SE'})				
Aadd(aEstado,{'TO'})

//+---------------------------------------------------+
//| TRATAMENTO PARA EXECUÇÃO DE TESTES AUTOMATIZADOS  |
//+---------------------------------------------------+
If !IsBlind()
	aSelFil	:= MatFilCalc( .T. )		
	aFil		:= GetFil(aSelFil)
ElseIf FindFunction("GetParAuto")
		aFil	:= GetParAuto("FISR087TestCase")
	Else
		Aadd(aFil,cFilAnt)
Endif

If len(aFil) ==0
	MsgAlert('Nenhuma filial foi selecionada, o processamento não será realizado.')
Else
	For nContFil := 1 to Len(aFil)
		cUfIE	:= ''
		SM0->(DbGoTop ())
		SM0->(MsSeek (aFil[nContFil][1]+aFil[nContFil][2], .T.))	//Pego a filial mais proxima
		cFilAnt := FWGETCODFILIAL

		For nX	:= 1 to Len(aEstado)
			If !Empty(IESubTrib(aEstado[nX][1],.T.))
				cUfIE	+=  Iif(empty(cUfIE),'',',' ) + "'" + aEstado[nX][1] + "'"
			EndIf
		Next nX

		cJoin 	:= '%'
		cJoin	+= RetSqlName("SF2") + " SF2 ON( SF2.F2_FILIAL = '"	+ xFilial('SF2') + "' AND SF2.F2_DOC = SF3.F3_NFISCAL AND SF2.F2_SERIE = SF3.F3_SERIE AND SF2.F2_CLIENTE = SF3.F3_CLIEFOR AND SF2.F2_LOJA = SF3.F3_LOJA AND SF2.F2_EMISSAO = SF3.F3_ENTRADA AND SF2.D_E_L_E_T_	= '') "
		cJoin 	+= '%'
		cFiltro := "%"
		cFiltro += "SF3.F3_FILIAL		= '"	+ xFilial('SF3')				+ "' AND "
		cFiltro += "SF3.F3_ENTRADA		>= '" 	+ %Exp:DToS (mv_par01)% 		+ "' AND "
		cFiltro += "SF3.F3_ENTRADA		<= '" 	+ %Exp:DToS (mv_par02)% 		+ "' AND "
		cFiltro += "(SF3.F3_DIFAL 		> 0 OR (SF3.F3_BASEDES 	> 0 AND  SUBSTRING(SF3.F3_CFO,1,1)>='5'))  AND "		

		If Empty(cUfIE)
			cUfIE	:= "'" + SuperGetMV("MV_ESTADO") + "'"
		EndIF
		
		If mv_par03 == 2 
			//Somente com IE
			cFiltro += IIf(!Empty(cUfIE),"SF3.F3_ESTADO IN ("+ cUfIE + ")	AND "," 1=0 AND ")
			//tratamento para não dar erro quando buscar a IE e não encontrar	
		ElseIf mv_par03 == 3 
			//Somente sem IE
			cFiltro += IIf(!Empty(cUfIE),"SF3.F3_ESTADO NOT IN ("+ cUfIE + ")	AND "," ")
			//tratamento para não dar erro quando buscar a IE e não encontrar
		EndIF
		cFiltro += "SF3.F3_DTCANC 		= '' AND "	
		cFiltro += "SF3.D_E_L_E_T_		= '' "
		cFiltro += "%"
		
		oSecao1:BeginQuery()
		
		BeginSql Alias cAliasQry
		
			COLUMN F3_ENTRADA AS DATE
			COLUMN F3_DTCANC AS DATE
			COLUMN F3_EMISSAO AS DATE
						
			SELECT
				SF2.F2_GNRDIF, SUBSTRING(SF2.F2_GNRDIF, 4, 9) AS F2_NUMTIT, SUBSTRING(SF2.F2_GNRDIF, 1, 3) AS F2_PREFIXO,F2_GNRFECP, 
				SF3.F3_FILIAL, SF3.F3_CFO, SF3.F3_NFISCAL, SF3.F3_SERIE, SF3.F3_DIFAL, SF3.F3_ICMSCOM, SF3.F3_VFCPDIF, SF3.F3_ESTADO,
				SF3.F3_EMISSAO, SF3.F3_CLIEFOR, SF3.F3_LOJA, SF3.F3_TIPO,  SF3.F3_VALCONT,SF3.F3_BASEICM
			FROM
				%TABLE:SF3% SF3 
			LEFT JOIN %Exp:cJoin%
			WHERE
				%Exp:cFiltro%
			ORDER BY 
				SF3.F3_FILIAL,SF3.F3_ESTADO, SF3.F3_NFISCAL
		EndSql
		
		oReport:SetTitle("Listagem Documento Fiscal - EC 87/15")
		oSecao1:EndQuery()
		oReport:SetMeter((cAliasQry)->(RecCount()))
		oSecao1:Print() 
	
	Next nContFil
	
	RestArea (aAreaSM0)
	cFilAnt := FWGETCODFILIAL

EndIF

return

//+-----------------------------------------------------------------------------------------------+
//! Função para criação da estrutura do relatório.                                                !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportDef(cAlias,cPerg)

local cTitle  := "Listagem Documento Fiscal EC 87/15"
local cHelp   := "Listagem dos documentos fiscais com cálculo do DIFAL, referente a Emenda Constitucional 87 de 2015."
local oReport
local oSection1
Local aFields   := { }
Local nI	:= 0
Local oBreak 

oReport := TReport():New('FISR087',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},cHelp)
oReport:SetLandscape()

//Primeira seção
oSection1 := TRSection():New(oReport,"Notas Fiscais",{"SF3"}) 

TRCell():New(oSection1,"F3_FILIAL",		"SF3", "Filial")
TRCell():New(oSection1,"F3_ESTADO",		"SF3", "Destino")
TRCell():New(oSection1,"F3_NFISCAL",	"SF3", "NF")
TRCell():New(oSection1,"F3_SERIE",		"SF3", "Série")
TRCell():New(oSection1,"F3_EMISSAO", 	"SF3", "Emissão")
TRCell():New(oSection1,"F3_CFO",		"SF3", "CFOP")
TRCell():New(oSection1,"F3_CLIEFOR",  	"SF3", "Clie/For")
TRCell():New(oSection1,"F3_LOJA",	  	"SF3", "Loja")
TRCell():New(oSection1,"F3_TIPO",	  	"SF3", "Tipo")
TRCell():New(oSection1,"F3_VALCONT", 	"SF3", "Valor Contábil")
TRCell():New(oSection1,"F3_BASEICM", 	"SF3", "Base ICMS")
TRCell():New(oSection1,"F3_DIFAL",	 	"SF3", "Difal Destino") 
TRCell():New(oSection1,"F3_ICMSCOM", 	"SF3", "Difal Origem")
TRCell():New(oSection1,"F3_VFCPDIF", 	"SF3", "FECP Destino")
TRCell():New(oSection1,"F2_GNRDIF", 	"SF3", "N.Guia")
TRCell():New(oSection1,"F2_NUMTIT",		"SF3", "N. do Título")
TRCell():New(oSection1,"F2_PREFIXO",	"SF3", "Prefixo")
TRCell():New(oSection1,"F2_GNRFECP",	"SF3", "N.Guia FECP")

oBreak := TRBreak():New(oSection1,oSection1:Cell("F3_ESTADO"),"Estado",.t.,'Estado',.T.)
oSection1:SetHeaderBreak(.T.) //Imprime cabeçalho das células após quebra
oSection1:SetPageBreak(.T.) //Pula de página após quebra
oSection1:SetHeaderSection(.T.)

Return(oReport)


Static Function GetFil(aSelFil)

Local aAreaSM0	:= {}
Local aSM0			:= {}
local nFil			:= 0

aAreaSM0 := SM0->(GetArea())
DbSelectArea("SM0")

//--------------------------------------------------------
//Irá preencher aSM0 somente com as filiais selecionadas
//pelo cliente  
//--------------------------------------------------------
If Len(aSelFil)> 0

	SM0->(DbGoTop())
	If SM0->(MsSeek(cEmpAnt))
		Do While !SM0->(Eof()) 
			nFil := Ascan(aSelFil,{|x|AllTrim(x[2])==Alltrim(SM0->M0_CODFIL) .And. x[4] == SM0->M0_CGC})
			If nFil > 0 .And. aSelFil[nFil][1] .AND. cEmpAnt == SM0->M0_CODIGO
				Aadd(aSM0,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOME,SM0->M0_CGC})
			EndIf
			SM0->(dbSkip())
		Enddo
	EndIf
	
	SM0->(RestArea(aAreaSM0))
EndIF

Return aSM0

Static Function VldSx1()
Local cMensagem	:= ''

If Empty(mv_par01) 
	cMensagem	:= 'É necessário informar data inicial
ElseIf Empty(mv_par02)
	cMensagem	:= 'É necessário informar data final'
ElseIF mv_par02 < mv_par01 
	cMensagem	:= 'Data Final deverá ser maior que data inicial'
EndIF

Return cMensagem
