#INCLUDE "PROTHEUS.CH"
#INCLUDE "TECA240.CH"

Function TECA240()

MsgInfo(STR0089) //"Assistente Para Cancelamento de Contratos: Rotina Descontinuada!"

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt240GerOsบAutor  ณVendas CRM          บ Data ณ  24/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGeracao da Ordem de Servico inicial para apontamentos das   บฑฑ
ฑฑบ          ณdespesas.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function At240GerOs(	cCodProp	, aChaveAA3	, cCondPV	, cOcorren	,;
						cContMnt	, cNumOS	, dDataInc, cTpCont,cCodEnt, cCodLoja, lAutomato )

Local lRet		:= .T.

Local aCab		:= {}
Local aItens	:= {}
Local aItem		:= {}

Local dDataBkp	:= dDataBase

Local nX		:= 0
Local cFileLog	:= ""
Local cPath		:= "\"

Private lMsErroAuto	:= .F.

Default dDataInc := dDataBase
Default cTpCont  := "1"
Default cCodEnt	:= ""
Default cCodLoja	:= ""
Default lAutomato	:= .F.

AB6->(DbSetOrder(1))

If !EMPTY(cCodProp)
	ADY->(DbSetOrder(1)) //ADY_FILIAL+ADY_PROPOS
	ADY->(DbSeek(xFilial("ADY") + cCodProp))
	cCodEnt := ADY->ADY_CODIGO
	cCodLoja := ADY->ADY_LOJA
EndIf

cNumOS := GetSXENum("AB6","AB6_NUMOS")
While AB6->(DbSeek(xFilial("AB6")+cNumOS))
	ConfirmSX8()
	cNumOS := GetSXENum("AB6","AB6_NUMOS")
End
RollBackSx8()

dDataBase := dDataInc

aAdd(aCab,{"AB6_NUMOS"	,cNumOS				,Nil})
aAdd(aCab,{"AB6_CODCLI"	,cCodEnt				,Nil})
aAdd(aCab,{"AB6_LOJA"	,cCodLoja				,Nil})
aAdd(aCab,{"AB6_EMISSA"	,dDataInc			,Nil})
aAdd(aCab,{"AB6_CONPAG"	,cCondPV			,Nil})
aAdd(aCab,{"AB6_HORA"	,Time()				,Nil})
aAdd(aCab,{"AB6_TPCONT"	,cTpCont				,Nil})
aAdd(aCab,{"AB6_CONTRT"	,cContMnt			,Nil})

AA3->(DbSetOrder(4))	//Chave da base utilizada(Indice 4): AA3_FILIAL+AA3_CODFAB+AA3_LOJAFA+AA3_CODPRO+AA3_NUMSER

For nX := 1 to Len(aChaveAA3)
	AA3->(DbSeek(aChaveAA3[nX]))
	aItem:= {}
	aAdd(aItem,{"AB7_ITEM"		,StrZero(nX,2)  	,Nil})
	aAdd(aItem,{"AB7_TIPO"		,"1"				,Nil})
	aAdd(aItem,{"AB7_CODPRO"	,AA3->AA3_CODPRO	,Nil})
	aAdd(aItem,{"AB7_NUMSER"	,AA3->AA3_NUMSER	,Nil})
	aAdd(aItem,{"AB7_CODPRB"	,cOcorren			,Nil})
	aAdd(aItens,aClone(aItem))
Next nX

TECA450(,aCab,aItens,,3)

dDataBase := dDataBkp

If lMsErroAuto
	lRet := .F.
	ConOut(STR0068) //"Erro na inclusao da Ordem de Servi็o!"
	If !lAutomato
	MostraErro()
	Else
	   cFileLog := MostraErro(cPath)
	   ConOut(cFileLog)		//Endif
	EndIf
EndIf

Return lRet

/*#INCLUDE "FWBROWSE.CH"

//Itens do browse de propostas
#DEFINE P_MARCA  1
#DEFINE P_PROPOS 2
#DEFINE P_REVISA 3
#DEFINE P_OPORTU 4
#DEFINE P_CLIENT 5
#DEFINE P_LOJA   6
#DEFINE P_NOME   7
#DEFINE P_DATA   8
#DEFINE P_TIPO   9

//Itens do browse de base de atendimento
#DEFINE B_MARCA  1
#DEFINE B_CODPRO 2
#DEFINE B_DESCRI 3
#DEFINE B_NUMSER 4
#DEFINE B_SITE   5
#DEFINE B_CODFAB 6
#DEFINE B_LOJFAB 7


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTECA240   บAutor  ณVendas CRM          บ Data ณ  04/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณWizard para inclusao de contratos de servicos e manutencao  บฑฑ
ฑฑบ          ณa partir de propostas comerciais das oportunidades de venda บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGATEC                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Function TECA240(lAutomato)

Local oWizard 		:= Nil
Local oPanel		:= Nil
Local oPesq1		:= Nil
Local oPesq2		:= Nil
Local oPeriodo		:= Nil
Local oOk			:= Nil
Local oNo			:= Nil
Local oLbxProp		:= Nil
Local oLbxBase		:= Nil

Local nValMens		:= 0
Local nTamTES		:= TamSx3("F4_CODIGO")[1]
Local nTamCond		:= TamSx3("E4_CODIGO")[1]
Local nTamProd		:= TamSx3("B1_COD")[1]
Local nTamClass	:= TamSx3("AAM_CLASSI")[1]
Local nTamServ		:= TamSx3("AA5_CODSER")[1]
Local nTamOco		:= TamSx3("AAG_CODPRB")[1]

Local cWizTitle	:= STR0001	//"Assistente para gera็ใo de contratos"
Local cPesq1		:= Space(40)
Local cPesq2		:= Space(40)
Local cPeriodo		:= ""
Local cTES			:= Space(nTamTES)
Local cCondPV		:= Space(nTamCond)
Local cCondCalc	:= Space(nTamCond)
Local cProdMens	:= Space(nTamProd)
Local cClassfic	:= Space(nTamClass)
Local cServCob		:= Space(nTamServ)
Local cServNCob	:= Space(nTamServ)
Local cOcorren		:= Space(nTamOco)
Local cCodProp		:= ""
Local cRevProp		:= ""
Local cContMnt		:= ""
Local cContSrv		:= ""
Local cCCusto		:= Space(9)

Local dValidade	:= cToD("")
Local dFimCobr		:= cToD("")

Local aPeriodo		:= {STR0002,STR0003,STR0004,STR0005}  //"1 M๊s"###"3 Meses"###"6 Meses"###"1 Ano"
Local aMeses		:= {1,3,6,12}
Local aPropostas	:= {}
Local aBase		:= {}
Local aChaveAA3	:= {}

Local bFinish		:= NIL

Local lGera		:= .F.

Default lAutomato := .F.

//Inicializa os objetos que exibirao as imagens
oOk := LoadBitMap(GetResources(), "LBOK")
oNo := LoadBitMap(GetResources(), "LBNO")

aPropostas	:= At240Prop(aMeses[1])

If !lAutomato
	bFinish		:= {||lGera := At240Fim(oLbxProp	, oLbxBase	, @cCodProp	, @cRevProp	,;
										@aChaveAA3	, cTES		, cCondPV	, cCondCalc	,;
										dValidade	, cProdMens	, cClassfic	, cServCob	,;
										cServNCob	, cOcorren	, dFimCobr	, lAutomato	)}

	//Criacao do Wizard
	//"Gera็ใo de contratos para presta็ใo de servi็os"###"Assistente"
	//"Este assistente irแ auxiliar no processo de gera็ใo do contrato de presta็ใo de servi็os a partir de uma proposta comercial"

	oWizard := ApWizard():new(cWizTitle,STR0007,STR0008,STR0009,{||.T.},{||.T.},.T.,sem uso,sem uso,.F.,{0,0,480,600})

	//Listar propostas nใo processadas que estao configuradas para gerar contratos
	oWizard:newPanel( cWizTitle, STR0010, {||.T.}, {||At240VldPr(oLbxProp)}, {||.T.}, .F., {||.T.} ) //"Selecione uma proposta comercial"

	//Listar base instalada do cliente
	oWizard:newPanel( cWizTitle, STR0011,{||.T.}, {||At240VldBA(oLbxBase)}, {||.T.}, .F., {||At240Base(oLbxProp,oLbxBase,@aBase)}) //"Selecione uma refer๊ncia de atendimento"

	//Particularidades dos contratos
	oWizard:newPanel( cWizTitle, STR0012, {||.T.}, {||.T.}, bFinish, .F., {||.T.} ) //"Informe os detalhes para gera็ใo dos contratos"


	//Painel para selecao da proposta
	oPanel := oWizard:GetPanel(2)
		@ 005,007 MsGet oPesq1 VAR cPesq1 OF oPanel SIZE 105,10 PIXEL
	 	@ 005,115 BUTTON STR0013	SIZE 30,12 OF oPanel PIXEL Action(Tk040Busca(@oLbxProp,cPesq1,@oPesq1,.T.))	//"Pesquisar"
	 	@ 005,150 BUTTON STR0014	SIZE 30,12 OF oPanel PIXEL Action(Tk040Busca(@oLbxProp,cPesq1,@oPesq1,.F.))	//"Pr๓ximo"
		@ 007,185 SAY STR0015 OF oPanel PIXEL SIZE 90,9 //"Proposta do(s) ๚ltimo(s)"
		@ 005,258 COMBOBOX oPeriodo VAR cPeriodo ITEMS aPeriodo OF oPanel SIZE 40,10 PIXEL;
			ON CHANGE (	aPropostas := At240Prop(aMeses[oPeriodo:nAt]),;
						oLbxProp:SetArray(aPropostas),;
						oLbxProp:bLine := { ||{If(aPropostas[oLbxProp:nAt,P_MARCA],oOk,oNo),;
							aPropostas[oLbxProp:nAt,P_PROPOS],;
							aPropostas[oLbxProp:nAt,P_REVISA],;
							aPropostas[oLbxProp:nAt,P_OPORTU],;
							aPropostas[oLbxProp:nAt,P_CLIENT],;
							aPropostas[oLbxProp:nAt,P_LOJA  ],;
							aPropostas[oLbxProp:nAt,P_NOME  ],;
							aPropostas[oLbxProp:nAt,P_DATA  ],;
							X3Combo("ADY_TPCONT",aPropostas[oLbxProp:nAt,P_TIPO])}},;
						oLbxProp:Refresh())

		@ 021,007 LISTBOX oLbxProp FIELDS;
				HEADER  ""		,;
						STR0016	,; //"Proposta"
						STR0017	,; //"Revisใo"
						STR0018	,; //"Oportunidade"
						STR0019	,; //"Cliente"
						STR0020	,; //"Loja"
						STR0021	,; //"Nome"
						STR0022	,; //"Emissao"
						STR0023	,; //"Tipo"
				SIZE 290,140 OF oPanel PIXEL;
				ON dblClick(aEval(aPropostas, {|x|x[P_MARCA] := .F.}), aPropostas[oLbxProp:nAt,P_MARCA] := .T., oLbxProp:Refresh())

		oLbxProp:SetArray(aPropostas)
		oLbxProp:bLine := { ||{If(aPropostas[oLbxProp:nAt,P_MARCA],oOk,oNo),;
							aPropostas[oLbxProp:nAt,P_PROPOS],;
							aPropostas[oLbxProp:nAt,P_REVISA],;
							aPropostas[oLbxProp:nAt,P_OPORTU],;
							aPropostas[oLbxProp:nAt,P_CLIENT],;
							aPropostas[oLbxProp:nAt,P_LOJA  ],;
							aPropostas[oLbxProp:nAt,P_NOME  ],;
							aPropostas[oLbxProp:nAt,P_DATA  ],;
							X3Combo("ADY_TPCONT",aPropostas[oLbxProp:nAt,P_TIPO])}}

	//Painel para selecao da base de atendimento
	oPanel := oWizard:GetPanel(3)

		aBase := {{.F.,"","","",""}}

		@ 005,007 MsGet oPesq2 VAR cPesq2 OF oPanel SIZE 105,10 PIXEL
	 	@ 005,115 BUTTON STR0013	SIZE 30,12 OF oPanel PIXEL Action(Tk040Busca(@oLbxBase,cPesq2,@oPesq2,.T.))	//"Pesquisar"
	 	@ 005,150 BUTTON STR0014	SIZE 30,12 OF oPanel PIXEL Action(Tk040Busca(@oLbxBase,cPesq2,@oPesq2,.F.))	//"Pr๓ximo"
		@ 005,185 BUTTON STR0074	SIZE 30,12 OF oPanel PIXEL Action(IIF(At240Suges(oLbxProp,aPropostas,oLbxBase,@aBase,lAutomato),At240Base(oLbxProp,oLbxBase,@aBase),Nil)) //"Sugestใo"

		@ 005,247 BUTTON STR0024	SIZE 50,12 OF oPanel PIXEL Action(IIF(At240IncBA()==1,At240Base(oLbxProp,oLbxBase,@aBase),Nil)) //"Incluir nova"


		@ 021,007 LISTBOX oLbxBase FIELDS;
				HEADER  ""		,;
						STR0025	,; //"Produto"
						STR0026	,; //"Descri็ใo"
						STR0027	,; //"Identificador"
						STR0028	,; //"Site"
				SIZE 290,140 OF oPanel PIXEL;
				ON dblClick(aBase[oLbxBase:nAt,B_MARCA] := !aBase[oLbxBase:nAt,B_MARCA], oLbxBase:Refresh())

		oLbxBase:SetArray(aBase)
		oLbxBase:bLine := { || {If(	aBase[oLbxBase:nAt,B_MARCA],oOk,oNo),;
									aBase[oLbxBase:nAt,B_CODPRO]		,;
									aBase[oLbxBase:nAt,B_DESCRI]		,;
									aBase[oLbxBase:nAt,B_NUMSER]		,;
									aBase[oLbxBase:nAt,B_SITE]			}}
		oLbxBase:Refresh()


	//Detaljes dos contratos
	oPanel := oWizard:GetPanel(4)

	//TES para produtos enviados mensalmente
	@ 007,010 SAY STR0029 OF oPanel PIXEL SIZE 200,9 //"TES para produtos enviados mensalmente"
	@ 005,230 MsGet cTES		OF oPanel SIZE 30,10 F3 "SF4" PIXEL VALID ExistCpo("SF4",cTES,1)

	//Condi็ใo de pagamento dos pedidos automแticos mensais
	@ 022,010 SAY STR0030 OF oPanel PIXEL SIZE 200,9 //"Condi็ใo de pagamento dos pedidos automแticos mensais"
	@ 020,230 MsGet cCondPV		OF oPanel SIZE 30,10 F3 "SE4" PIXEL VALID ExistCpo("SE4",cCondPV,1)

	//Condi็ใo para cแlculo da data da gera็ใo do pedido mensal
	@ 037,010 SAY STR0031 OF oPanel PIXEL SIZE 200,9 //"Condi็ใo para cแlculo da data da gera็ใo do pedido mensal"
	@ 035,230 MsGet cCondCalc	OF oPanel SIZE 30,10 F3 "SE4" PIXEL VALID ExistCpo("SE4",cCondCalc,1)

	//Fim da validade do contrato(somente contrato fixo/mensal)
	@ 052,010 SAY STR0032 OF oPanel PIXEL SIZE 200,9 //"Fim da validade do contrato(somente contrato fixo/mensal)"
	@ 050,230 MsGet dValidade	OF oPanel SIZE 50,10 PIXEL VALID (empty(dValidade) .OR. (dValidade > dDataBase))

	//Fim da validade do contrato(somente contrato fixo/mensal)
	@ 067,010 SAY STR0070 OF oPanel PIXEL SIZE 200,9 //"Fim da cobran็a do contrato"
	@ 065,230 MsGet dFimCobr	OF oPanel SIZE 50,10 PIXEL VALID (!empty(dFimCobr) .AND. (dFimCobr > dDataBase))

	//Produto de refer๊ncia para cobran็a de mensalidade
	@ 082,010 SAY STR0033 OF oPanel PIXEL SIZE 200,9	//"Produto de refer๊ncia para cobran็a de mensalidade"
	@ 080,230 MsGet cProdMens	OF oPanel SIZE 60,10 PIXEL F3 "SB1" VALID ExistCpo("SB1",cProdMens,1)

	//Valor da mensalidade fixa (opcional)
	@ 097,010 SAY STR0034 OF oPanel PIXEL SIZE 200,9 //"Valor da mensalidade fixa (opcional)"
	@ 095,230 MsGet nValMens	OF oPanel SIZE 60,10 PIXEL VALID Positivo(nValMens) PICTURE pesqPict("AAH","AAH_VALOR")

	//Classifica็ใo do contrato de servi็os
	@ 112,010 SAY STR0035 OF oPanel PIXEL SIZE 200,9 //"Classifica็ใo do contrato de servi็os"
	@ 110,230 MsGet cClassfic	OF oPanel SIZE 30,10 PIXEL F3 "A7" VALID ExistCpo("SX5","A7" + cClassfic)

	//C๓digo do servi็o para cobran็a do cliente
	@ 127,010 SAY STR0036 OF oPanel PIXEL SIZE 200,9 //"C๓digo do servi็o para cobran็a do cliente"
	@ 125,230 MsGet cServCob	OF oPanel SIZE 30,10 PIXEL F3 "AA5" VALID ExistCpo("AA5",cServCob,1)

	//C๓digo do servi็o sem cobran็a para o cliente
	@ 142,010 SAY STR0037 OF oPanel PIXEL SIZE 200,9 //"C๓digo do servi็o sem cobran็a para o cliente"
	@ 140,230 MsGet cServNCob	OF oPanel SIZE 30,10 PIXEL F3 "AA5" VALID ExistCpo("AA5",cServNCob,1)

	//Ocorr๊ncia padrใo para abertura da ordem de servi็o mensal
	@ 157,010 SAY STR0038 OF oPanel PIXEL SIZE 200,9 //"Ocorr๊ncia padrใo para abertura da Ordem de Servi็o mensal"
	@ 155,230 MsGet cOcorren	OF oPanel SIZE 30,10 PIXEL F3 "AAG" VALID ExistCpo("AAG",cOcorren,1)


	//C๓digo do Centro de Custo para gera็ใo do Contrato de Manuten็ใo
	@ 172,010 SAY STR0072 OF oPanel PIXEL SIZE 200,9 //"C๓digo do Centro de Custo para gera็ใo do Contrato de Manuten็ใo"
	@ 170,230 MsGet cCCusto	OF oPanel SIZE 30,10 PIXEL F3 "CTT" VALID ExistCpo( "CTT", cCCusto, 1 ).AND. At240VldCC(cCCusto)

	oWizard:activate( .T., {||lGera .OR. MsgYesNo(STR0039)}, <bInit>, <bWhen> ) //"Confirma a saํda do assistente para gera็ใo de contratos?"

Else
	If FindFunction("GetParAuto")
		aRetAuto := GetParAuto("TECA240TESTCASE")

		cCodProp  := aRetAuto [1]
		cRevProp  := aRetAuto [2]
		aChaveAA3 := aRetAuto [3]
		cTES      := aRetAuto [4]
		cCondPV   := aRetAuto [5]
		cCondCalc := aRetAuto [6]
		dValidade := aRetAuto [7]
		cProdMens := aRetAuto [8]
		cClassfic := aRetAuto [9]
		cServCob  := aRetAuto [10]
		cServNCob := aRetAuto [11]
		cOcorren  := aRetAuto [12]
		dFimCobr  := aRetAuto [13]
		nValMens  := aRetAuto [14]
		cContMnt  := aRetAuto [15]
		cContSrv  := aRetAuto [16]
		cCCusto   := aRetAuto [17]
		aAutoLoc  := aClone(aRetAuto [21])

		aPropostas := At240Prop(aRetAuto [22])

		If (nPos := Ascan(aPropostas, {|x| x[P_PROPOS] + x[P_REVISA] == cCodProp + cRevProp } )) > 0
			aPropostas[nPos,P_MARCA] := .T.

			If Len(aAutoLoc) >= 1
			  At240Suges(oLbxProp,aPropostas,oLbxBase,@aBase,lAutomato, aAutoLoc)
			EndIf


			lGera := At240Fim(oLbxProp	, oLbxBase	, @cCodProp	, @cRevProp	,;
										@aChaveAA3	, cTES		, cCondPV	, cCondCalc	,;
										dValidade	, cProdMens	, cClassfic	, cServCob	,;
										cServNCob	, cOcorren	, dFimCobr, lAutomato )
		Else
			Help(" ",1,"At240Prop" ,NIL, STR0088, 1, 0 ) //"Nใo localizadas propostas vแlidas para o contrato"
		EndIf
	EndIf
EndIf

If lGera
	At240Gera(	cCodProp	, cRevProp	, aChaveAA3	, cServCob	,;
			cServNCob	, cCondCalc	, dValidade	, cCondPV	,;
			nValMens	, cProdMens	, cOcorren	, @cContMnt	,;
			@cContSrv	, cClassfic	, dFimCobr, cCCusto, lAutomato)
EndIf

Return


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt240Prop บAutor  ณVendas CRM          บ Data ณ  04/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarga das propostas comerciais do periodo solicitado        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpN1 - Quantidade de meses a considerar (retroativamente)  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA240                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function At240Prop(nQtdMeses)

Local aArea		:= GetArea()
Local aProp		:= {}
Local dCorte	:= dDataBase - (nQtdMeses * 30)
Local cAliasAD1	:= "AD1"
Local cFilAD1	:= xFilial("AD1")
Local cFilADY	:= xFilial("ADY")
Local cQuery	:= ""

DbSelectArea("ADY")
DbSetOrder(1) //ADY_FILIAL+ADY_PROPOS

cAliasAD1 := GetNextAlias()

cQuery := "SELECT AD1_FILIAL, AD1_DATA, AD1_STATUS, AD1_PROPOS, AD1_CODCLI, AD1_LOJCLI"
cQuery += " FROM " + RetSqlName("AD1")
cQuery += " WHERE AD1_FILIAL = '" + cFilAD1 + "' AND AD1_DATA >= '" + DtoS(dCorte) + "'"
cQuery += " AND AD1_STATUS = '9' AND AD1_PROPOS <> ' ' AND D_E_L_E_T_ = ' '"
cQuery += " ORDER BY AD1_FILIAL,AD1_DATA,AD1_NROPOR"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAD1,.T.,.T.)

TCSetField(cAliasAD1,"AD1_DATA","D")

While	!(cAliasAD1)->(Eof()) 				.AND.;
		(cAliasAD1)->AD1_FILIAL == cFilAD1	.AND.;
		(cAliasAD1)->AD1_DATA <= dDataBase

	If (cAliasAD1)->AD1_STATUS == "9" .AND. !Empty((cAliasAD1)->AD1_PROPOS)
		If ADY->(Dbseek(cFilADY + (cAliasAD1)->AD1_PROPOS)) .AND. Empty(ADY->ADY_PROCES) .AND. ADY->ADY_TPCONT $ "23"
			cNome := POSICIONE("SA1",1,xFilial("SA1")+ADY->ADY_CODIGO+ADY->ADY_LOJA,"A1_NOME")
			//Considerar os DEFINES no inicio do fonte
			aAdd(aProp,{	.F.						,;	// Marca
							ADY->ADY_PROPOS			,;	// Proposta
							ADY->ADY_PREVIS			,;	// Revisao Proposta
							ADY->ADY_OPORTU			,;	// Oportunidade
							(cAliasAD1)->AD1_CODCLI	,;	// Codigo
							(cAliasAD1)->AD1_LOJCLI	,;	// Loja
							cNome		   			,;	// Nome do cliente
							ADY->ADY_DATA  			,;	// Emissao
							ADY->ADY_TPCONT			})	// Tipo de contrato
		EndIf
	EndIf
	(cAliasAD1)->(DbSkip())

End

(cAliasAD1)->(DbCloseArea())

//Se nao encontrou propostas, inicializa um array vazio
If Len(aProp) == 0
	aProp :={{.F.,"","","","","","","",""}}
EndIf

RestArea(aArea)

Return aProp


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt240VldPrบAutor  ณVendas CRM          บ Data ณ  06/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a selecao da proposta comercial                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto da listbox de Propostas                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA240                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function At240VldPr(oLbxProp)

Local lRet		:= .T.
Local nItSel	:= 0

nItSel := aScan(oLbxProp:aArray,{|x| x[P_MARCA] })

If nItSel == 0
	MsgInfo(STR0040) //"Selecione a oportunidade / proposta para gera็ใo dos contratos"
	lRet := .F.
ElseIf Empty(oLbxProp:aArray[nItSel][P_PROPOS])
	MsgInfo(STR0041) //"Nใo hแ nenhuma oportunidade encerrada com propostas para gera็ใo de contratos no perํodo selecionado"
	lRet := .F.
EndIf

Return lRet


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt240VldPrบAutor  ณVendas CRM          บ Data ณ  10/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a selecao da base de atendimento                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto da listbox de Base de atendimento            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA240                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function At240VldBA(oLbxBase)

Local lRet 		:= .T.
Local nItSel	:= 0

nItSel := aScan(oLbxBase:aArray,{|x| x[B_MARCA] })

If nItSel == 0
	MsgInfo(STR0042) //"Selecione a base de atendimento para gera็ใo dos contratos."
	lRet := .F.
ElseIf Empty(oLbxBase:aArray[nItSel][B_NUMSER])
	MsgInfo(STR0043) //"A base de atendimento selecionada ้ invแlida."
	lRet := .F.
EndIf
Return lRet


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt240Base บAutor  ณVendas CRM          บ Data ณ  06/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega os itens da base de atendimento (AA3) pertencentes  บฑฑ
ฑฑบ          ณao cliente da proposta que nao estao vinculados a contratos บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto contendo a relacao de propostas              บฑฑ
ฑฑบ          ณExpA2 - Array que armazenara a base de atendimento          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA240                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function At240Base(oLbxProp,oLbxBase,aBase)

Local aArea		:= GetArea()

Local nItSel 	:= aScan(oLbxProp:aArray,{|x| x[P_MARCA] })

Local cAliasAA3	:= "AA3"
Local cFilAA3	:= xFilial("AA3")
Local cCodCli	:= oLbxProp:aArray[nItSel][P_CLIENT]
Local cLojCli	:= oLbxProp:aArray[nItSel][P_LOJA]
Local cDescPro	:= ""
Local cQuery	:= ""

Local oOk := LoadBitMap(GetResources(), "LBOK")
Local oNo := LoadBitMap(GetResources(), "LBNO")

aBase := {}

cAliasAA3 := GetNextAlias()

cQuery := "SELECT AA3_FILIAL, AA3_CODCLI, AA3_LOJA, AA3_NUMSER, AA3_CODPRO, AA3_SITE, AA3_CODFAB, AA3_LOJAFA, AA3_CONTRT"
cQuery += " FROM " + RetSqlName("AA3")
cQuery += " WHERE AA3_FILIAL = '" + cFilAA3 + "' AND D_E_L_E_T_ = ' '"
cQuery += " AND AA3_EQALOC = '2' AND AA3_CONTRT = ' ' "
cQuery += " AND AA3_LOJA = '" + cLojCli + "' AND AA3_CODCLI = '" + cCodCli + "'"
cQuery += " ORDER BY AA3_FILIAL,AA3_CODCLI,AA3_LOJA,AA3_CODPRO,AA3_NUMSER"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAA3,.T.,.T.)

While	!(cAliasAA3)->(Eof()) 				.AND.;
		(cAliasAA3)->AA3_CODCLI == cCodCli	.AND.;
		(cAliasAA3)->AA3_LOJA == cLojCli

	If Empty((cAliasAA3)->AA3_CONTRT)

		cDescPro := Posicione("SB1",1,xFilial("SB1")+(cAliasAA3)->AA3_CODPRO,"B1_DESC")

		aAdd(aBase,{.F.							,;	//Marca
					(cAliasAA3)->AA3_CODPRO		,;	//Cod. Produto
					cDescPro					,;	//Descricao
					(cAliasAA3)->AA3_NUMSER		,;	//Id. Unico
					(cAliasAA3)->AA3_SITE		,;	//Site
					(cAliasAA3)->AA3_CODFAB		,;	//Cod. Fabricante
					(cAliasAA3)->AA3_LOJAFA		})	//Loja Fabricante

	EndIf

	(cAliasAA3)->(dbSkip())

End

(cAliasAA3)->(DbCloseArea())

If Len(aBase) == 0
	aBase := {{.F.,"","","",""}}
EndIf

oLbxBase:SetArray(aBase)
oLbxBase:bLine := { || {If(	aBase[oLbxBase:nAt,1],oOk,oNo),;
							aBase[oLbxBase:nAt,2],;
							aBase[oLbxBase:nAt,3],;
							aBase[oLbxBase:nAt,4],;
							aBase[oLbxBase:nAt,5]}}
oLbxBase:Refresh()

RestArea(aArea)

Return .T.


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt240IncBAบAutor  ณVendas CRM          บ Data ณ  09/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPermite a inclusao de uma nova Base de Atendimento          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA240                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function At240IncBA()

Local aArea		:= GetArea()
Local nOpcA		:= 0

SaveInter()

Private aRotina := {	{ STR0044	,"AxPesqui"  	,0	,1	,0	,.F.},;//"Pesquisar"
						{ STR0045	,"At040Visua"	,0	,2	,0	,.T.},;	//"Visualizar"
						{ STR0046	,"At040Inclu"	,0	,3	,0	,.T.}} 	//"Incluir"

Private cCadastro := STR0073 // "Base de Atendimento"

ALTERA	:= .F.
INCLUI	:= .T.

nOpcA := At040Inclu("AA3",0,3)

RestInter()
RestArea(aArea)

Return nOpcA


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt240Fim  บAutor  ณVendas CRM          บ Data ณ  16/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao geral antes do inicio do processamento do wizard. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPO1-Objeto do listbox de propostas                        บฑฑ
ฑฑบ          ณEXPO2-Objeto do listbox de base instalada                   บฑฑ
ฑฑบ          ณEXPC3-Codigo da proposta selecionada (REFERENCIA)           บฑฑ
ฑฑบ          ณEXPC4-Chave da base de atendimento selecionada (REFERENCIA) บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA240                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function At240Fim(	oLbxProp	, oLbxBase	, cCodProp	, cRevProp	,;
							aChaveAA3	, cTES		, cCondPV	, cCondCalc	,;
							dValidade	, cProdMens	, cClassfic	, cServCob	,;
							cServNCob	, cOcorren	, dFimCobr,lAutomato	)

Local lRet 		:= .T.
Local nIt		:= 0
Local cCliente	:= ""
Local cTipoCnt	:= ""
Local cErro		:= ""
Default lAutomato := .F.

//Codigo da proposta selecionada
If !lAutomato
	nIt 		:= 	aScan(oLbxProp:aArray,{|x| x[P_MARCA] })
	cCodProp 	:= 	oLbxProp:aArray[nIt,P_PROPOS]
	cRevProp 	:= 	oLbxProp:aArray[nIt,P_REVISA]
	cCliente	:=  oLbxProp:aArray[nIt,P_CLIENT]+"/"+oLbxProp:aArray[nIt,P_LOJA]+" "+AllTrim(oLbxProp:aArray[nIt,P_NOME])
	cTipoCnt	:= 	oLbxProp:aArray[nIt,P_TIPO  ]
Else
	If FindFunction("GetParAuto")
		aRetAuto := GetParAuto("TECA240TESTCASE")

		nIt  		:= 	aRetAuto[18]
		cCodProp 	:= 	aRetAuto[1]
		cRevProp 	:= 	aRetAuto[2]
		cCliente	:= 	aRetAuto[19]
		cTipoCnt	:= 	aRetAuto[20]
	EndIf

EndIf


//Chave da base utilizada(Indice 4): AA3_FILIAL+AA3_CODFAB+AA3_LOJAFA+AA3_CODPRO+AA3_NUMSER
aChaveAA3 := {}
If !lAutomato
	For nIt := 1 to Len(oLbxBase:aArray)
		If oLbxBase:aArray[nIt][B_MARCA]
			AAdd(aChaveAA3,	xFilial("AA3") 					+;
				  			oLbxBase:aArray[nIt,B_CODFAB]	+;
							oLbxBase:aArray[nIt,B_LOJFAB] 	+;
							oLbxBase:aArray[nIt,B_CODPRO] 	+;
							oLbxBase:aArray[nIt,B_NUMSER])
		EndIf
	Next nIt
Else
	aChaveAA3 := aRetAuto[3]
EndIf

//Valida o preenchimento do TES para envio mensal
SF4->(DbSetOrder(1))
If Empty(cTES) .OR. !SF4->(DbSeek(xFilial("SF4")+cTES)) .OR. cTES < "500"
	cErro := STR0047 //"O TES selecionado para envio mensal de produtos ้ invแlido"
Else
	If cTipoCnt == "2" //Pre-Determinado
		If !(SF4->F4_DUPLIC == "N" .AND. SF4->F4_ESTOQUE == "S")
			cErro := STR0048 //"A TES utilizada no envio de produtos mensais para contrato Pr้-Determinado nใo deve gerar duplicatas e deve movimentar estoque."
		EndIf
	ElseIf cTipoCnt == "3" //Fixo
		If !(SF4->F4_DUPLIC == "S" .AND. SF4->F4_ESTOQUE == "S")
			cErro := STR0049 //"A TES utilizada no envio de produtos mensais para contrato Fixo deve gerar duplicatas e movimentar estoque."
		EndIf
	EndIf
EndIf

//Valida a condicao do pedido
If Empty(cErro) .AND. Empty(cCondPV)
	cErro := STR0050 //"A condi็ใo de pagamento selecionada para utiliza็ใo nos pedidos automแticos mensais ้ invแlida"
EndIf

//Valida a condicao do calculo da geracao do pedido mensal (contratos)
If Empty(cErro) .AND. Empty(cCondCalc)
	cErro := STR0051 //"A condi็ใo de pagamento selecionada para cแlculo da data da gera็ใo do pedido mensal ้ invแlida"
EndIf

//Valida a data de validade do contrato
If Empty(cErro) .AND. cTipoCnt == "2" .AND. Empty(dValidade)
	cErro := STR0052 //"O tipo de contrato definido na proposta exige a defini็ใo de uma data para o encerramento do contrato."
EndIf

//Valida o produto a ser utilizado no contrato de manutencao
If Empty(cErro) .AND. Empty(cProdMens)
	cErro := STR0053 //"Defina um produto para indicar a cobran็a do contrato."
EndIf

//Valida a classificacao do contrato
If Empty(cErro) .AND. Empty(cClassfic)
	cErro := STR0054 //"Defina uma classifica็ใo para o contrato."
EndIf

//Valida o contrato de servico para cobrar do cliente
AA5->(DbSetOrder(1))
If Empty(cErro) .AND. (Empty(cServCob) .OR. !AA5->(DbSeek(xFilial("AA5")+cServCob)) .OR. AA5->AA5_PRCCLI == 0)
	cErro := STR0055 //"O servi็o para cobran็a do cliente nใo ้ vแlido."
EndIf

//Valida o contrato de servico para nao cobrar do cliente
If Empty(cErro) .AND. (Empty(cServNCob) .OR. !AA5->(DbSeek(xFilial("AA5")+cServNCob)) .OR. AA5->AA5_PRCCLI <> 0)
	cErro := STR0056 //"O servi็o sem cobran็a do cliente nใo ้ vแlido."
EndIf

//Valida a ocorrencia para utilizacao nas ordens de servico
If Empty(cErro) .AND. Empty(cOcorren)
	cErro := STR0057 //"Defina uma ocorr๊ncia para abertura das Ordens de Servi็o mensais."
EndIf

If Empty(dFimCobr)
	cErro := STR0071 //"Informe a data limite para cobran็a dos contratos"
EndIf

//Apresenta a mensagem de erro
If !Empty(cErro)
	lRet := .F.
	If !lAutomato
	MsgInfo(cErro)
	Else
		Help(" ",1,"At240Fim" ,NIL, cErro, 1, 0 )
	EndIf
EndIf

If lRet
	If !lAutomato
		lRet := MsgYesNo(STR0058 + cCodProp +STR0059 + cCliente + " ?") //"Confirma a gera็ใo do contrato para a proposta " ### ", do cliente "
	Else
		lRet := .T.
	EndIf
EndIf

Return lRet


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt240Gera บAutor  ณVendas CRM          บ Data ณ  16/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGeracao do grupo de cobertura e dos contratos               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC01-Codigo da proposta comercial                         บฑฑ
ฑฑบ          ณEXPC02-Chave unica da base instalada                        บฑฑ
ฑฑบ          ณEXPA03-Lista de bases de atendimento encontradas            บฑฑ
ฑฑบ          ณEXPC04-Servico para cobrar cliente                          บฑฑ
ฑฑบ          ณEXPC05-Servico para nao cobrar cliente                      บฑฑ
ฑฑบ          ณEXPC06-Condicao para calculo da geracao da cobranca/envio   บฑฑ
ฑฑบ          ณEXPCD7-Data de validade dos contratos                       บฑฑ
ฑฑบ          ณEXPC08-Condicao de pagamento para os PV's gerados           บฑฑ
ฑฑบ          ณEXPCN9-Valor da mensalidade do contrato de manutencao       บฑฑ
ฑฑบ          ณEXPC10-Produto da mensalidade                               บฑฑ
ฑฑบ          ณEXPC11-Ocorrencia utilizada na abertura das OS              บฑฑ
ฑฑบ          ณEXPC12-(REFERENCIA) Codigo do contrato de manutencao gerado บฑฑ
ฑฑบ          ณEXPC13-(REFERENCIA) Codigo do contrato de servico gerado    บฑฑ
ฑฑบ          ณEXPC14-Classificacao do contrato de servicos                บฑฑ
ฑฑบ          ณEXPD15-Data para termino da cobranca dos contratos          บฑฑ
ฑฑบ          ณEXPD16-Centro de custo para o Contrato de Manuten็ใo        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA240                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function At240Gera(	cCodProp	, cRevProp	, aChaveAA3	, cServCob	,;
							cServNCob	, cCondCalc	, dValidade	, cCondPV	,;
							nValMens	, cProdMens	, cOcorren	, cContMnt	,;
							cContSrv	, cClassfic , dFimCobr, cCCusto, lAutomato	)

Local aDemanda	:= {}
Local cGrpCob	:= ""
Local cOS		:= ""
Local lRet		:= .T.

DEFAULT lAutomato := .F.

Begin Transaction

//Geracao do grupo de cobertura
lRet := At240Grupo(	cCodProp	, cRevProp	, @aDemanda	, cServCob	,;
					cServNCob	, @cGrpCob	, lAutomato)

//Geracao do contrato de manutencao
If lRet
	lRet := At240CntMn(	cGrpCob		, aDemanda	, aChaveAA3	, cCodProp	,;
						cRevProp	, cCondCalc	, dValidade	, cCondPV	,;
						nValMens	, cProdMens	, cOcorren	, @cContMnt	,;
						dFimCobr	, cCCusto, lAutomato )
EndIf

//Geracao do contrato de servicos
If lRet
	lRet := At240CntSv(	cCodProp	, cRevProp	, @cContSrv	, cClassfic	,;
						dValidade	, cCondCalc	, cCondPV	, dFimCobr, lAutomato	)
EndIf

//Registra a proposta como processada
If lRet
	ADY->(DbSetOrder(1))
	ADY->(DbSeek(xFilial("ADY")+cCodProp))
	RecLock("ADY",.F.)
	ADY->ADY_PROCES := "S"
	MsUnLock()
EndIf

If lRet
	At240ImpCA(cCodProp,cRevProp,cContMnt)
EndIf

If !lRet
	DisarmTransaction()
EndIf

End Transaction
MsUnlockAll()

If lRet
	If !lAutomato
		//Marcar a proposta como processada
		Aviso(STR0060,; //"Gera็ใo de contratos"
			STR0061+CRLF+; //"Contratos gerados com sucesso."
			STR0062 + cContMnt + CRLF +; //"Contrato de manuten็ใo: "
			Iif(!Empty(cContSrv),(STR0063  + cContSrv + CRLF),"") ,; //"Contrato de servi็o: "
			{"Ok"},3)
	EndIf
Else
   If !lAutomato
	MsgStop(STR0065) //"Problemas ao gerar os contratos"
   Else
    	Help(" ",1,"At240Gera" ,NIL, STR0065, 1, 0 )
   EndIf
EndIf

Return Nil


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt240GrupoบAutor  ณVendas CRM          บ Data ณ  19/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGeracao do grupo de cobertura sobre a proposta comercial    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 - Codigo da proposta comercial                        บฑฑ
ฑฑบ          ณEXPC2 - Revisao da proposta comercial                       บฑฑ
ฑฑบ          ณEXPA3 - (Referencia) Array com as demandas encontradas      บฑฑ
ฑฑบ          ณEXPC4 - Codigo do servico para cobrar cliente               บฑฑ
ฑฑบ          ณEXPC5 - Codigo do servico para nao cobrar cliente           บฑฑ
ฑฑบ          ณEXPC6 - (Referencia) grupo de cobertura gerado              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA240                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function At240Grupo(	cCodProp	, cRevProp	, aDemanda	, cServCob	,;
							cServNCob	, cGrpCob	, lAutomato)

Local aCabGrpC	:= {}
Local aIteGrpC	:= {}
Local aAux		:= {}
Local aErro		:= {}

Local nX		:= 0
Local nI		:= 0
Local nJ		:= 0

Local lRet		:= .T.

Local oModel	:= Nil
Local oAux		:= Nil
Local oStruct	:= Nil
Local nItErro  	:= 0
Local cFileLog	:= ""
Local cPath		:= "\"

Default lAutomato := .F.

//Carrega as demandas da proposta
aDemanda := At240LePro(cCodProp,cRevProp,"3")

If Len(aDemanda) > 0

	DbSelectArea("AAA")
	DbSetOrder(1)//AAA_FILIAL+AAA_CODGRP

	//Monta o cabecalho
	cGrpCob	:= GetSXENum("AAA","AAA_CODGRP")

	While AAA->(DbSeek(xFilial("AAA")+cGrpCob))
		ConfirmSX8()
		cGrpCob	:= GetSXENum("AAA","AAA_CODGRP")
	End

	aCabGrpC := {	{"AAA_CODGRP",cGrpCob				},;
					{"AAA_DESCRI",STR0066 + cCodProp	},; //"Grupo de cobertura proposta: "
					{"AAA_CODSER",cServCob				}}

	//Monta os itens
	For nX := 1 to Len(aDemanda)
		AAdd(aIteGrpC,{	{"AAB_CODPRO",aDemanda[nX][1]	},;
						{"AAB_CODSER",cServNCob			}})
	Next nX

	//Executa a inclusao automatica utilizando os recursos do MVC.
	oModel := FWLoadModel( 'TECA230' )

	oModel:SetOperation( 3 )
	oModel:Activate()

	oAux    := oModel:GetModel( 'AAAMASTER' )
	oStruct := oAux:GetStruct()
	aAux	:= oStruct:GetFields()

	For nI := 1 To Len( aCabGrpC )
		If aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCabGrpC[nI][1] ) } ) > 0
			If !( lAux := oModel:SetValue( 'AAAMASTER', aCabGrpC[nI][1], aCabGrpC[nI][2] ) )
				lRet    := .F.
				Exit
			EndIf
		EndIf
	Next

	If lRet
		oAux     := oModel:GetModel( 'AABDETAIL' )
		oStruct  := oAux:GetStruct()
		aAux	 := oStruct:GetFields()
		For nI := 1 To Len( aIteGrpC )
			If nI > 1
				If  ( nItErro := oAux:AddLine() ) <> nI
					lRet    := .F.
					Exit
				EndIf
			EndIf
			For nJ := 1 To Len( aIteGrpC[nI] )
				If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aIteGrpC[nI][nJ][1] ) } ) ) > 0
					If !( lAux := oModel:SetValue( 'AABDETAIL', aIteGrpC[nI][nJ][1], aIteGrpC[nI][nJ][2] ) )
						lRet    := .F.
						nItErro := nI
						Exit
					EndIf
				EndIf
			Next
			If !lRet
				Exit
			EndIf
		Next
	EndIf

	If lRet
		If ( lRet := oModel:VldData() )
			lRet := oModel:CommitData()
		EndIf
	EndIf

	//Exibe o log com a mensagem de erro, quando ocorrer algum problema.
	If !lRet

		aErro   := oModel:GetErrorMessage()

		AutoGrLog( "Source Form ID:            " + ' [' + AllToChar( aErro[1]  ) + ']' )
		AutoGrLog( "Source Field ID:           " + ' [' + AllToChar( aErro[2]  ) + ']' )
		AutoGrLog( "Form Error ID:             " + ' [' + AllToChar( aErro[3]  ) + ']' )
		AutoGrLog( "Field Error ID:            " + ' [' + AllToChar( aErro[4]  ) + ']' )
		AutoGrLog( "Error ID:                  " + ' [' + AllToChar( aErro[5]  ) + ']' )
		AutoGrLog( "Error message:             " + ' [' + AllToChar( aErro[6]  ) + ']' )
		AutoGrLog( "Solution message:          " + ' [' + AllToChar( aErro[7]  ) + ']' )
		AutoGrLog( "Assigned value:            " + ' [' + AllToChar( aErro[8]  ) + ']' )
		AutoGrLog( "Previous value:            " + ' [' + AllToChar( aErro[9]  ) + ']' )

		If nItErro > 0
			AutoGrLog( "Error in Item:             " + ' [' + AllTrim( AllToChar( nItErro  ) ) + ']' )
		EndIf

		If !lAutomato
		MostraErro()
		Else
		   cFileLog := MostraErro(cPath)
		   ConOut("Erro na rotina At240Grupo " + cFileLog)
		EndIf
	EndIf

	oModel:DeActivate()

EndIf

Return lRet


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt240CntMnบAutor  ณVendas CRM          บ Data ณ  20/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGeracao do contrato de manutencao a partir dos itens da pro-บฑฑ
ฑฑบ          ณposta comercial.                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 - Codigo do grupo de cobertura utilizado              บฑฑ
ฑฑบ          ณEXPA2 - Array contendo as quantidades de demandas           บฑฑ
ฑฑบ          ณEXPA3 - Chave da base instalada utilizada para cobertura    บฑฑ
ฑฑบ          ณEXPC4 - Codigo da proposta comercial                        บฑฑ
ฑฑบ          ณEXPC5 - Revisao da proposta                                 บฑฑ
ฑฑบ          ณEXPC6 - Condicao para calculo da data de geracao            บฑฑ
ฑฑบ          ณEXPD7 - Data de validade do contrato                        บฑฑ
ฑฑบ          ณEXPC8 - Condicao de pagamento para o PV gerado no contrato  บฑฑ
ฑฑบ          ณEXPN9 - Valor da mensalidade                                บฑฑ
ฑฑบ          ณEXPC10- Produto discriminado na mensalidade                 บฑฑ
ฑฑบ          ณEXPC11- Codigo da ocorrencia utilizada na OS inicial        บฑฑ
ฑฑบ          ณEXPC12- (REFERENCIA) Codigo do contrato gerado              บฑฑ
ฑฑบ          ณEXPD13- Data para termino da cobranca do contrato           บฑฑ
ฑฑบ          ณEXPD14- Centro de Custo do Contrato de Manuten็ใo           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA240                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function At240CntMn(	cGrpCob		, aDemanda	, aChaveAA3	, cCodProp	,;
							cRevProp	, cCondCalc	, dValidade	, cCondPV	,;
							nValMens	, cProdMens	, cOcorren	, cContMnt	,;
							dFimCobr	, cCCusto, lAutomato )
Local cTpCont		:= ""
Local cModLib		:= ""
Local aCabec		:= {}
Local aItens		:= {}
Local aItem			:= {}
Local aGrupo		:= {}
Local nX			:= 0
Local lRet			:= .T.
Local cFileLog	:= ""
Local cPath		:= "\"

Default lAutomato	:= .F.

Private lMsErroAuto	:= .F.

ADY->(DbSetOrder(1)) //ADY_FILIAL+ADY_PROPOS
ADY->(DbSeek(xFilial("ADY") + cCodProp))

//Contrato Pre-Determinado 	= Tempo Determinado
//Contrato Fixo 			= Vitalicio
cTpCont 	:= Iif(ADY->ADY_TPCONT == "2", "2", "1")

//Contrato Pre-Determinado 	= Liberacao fixa
//Contrato Fixo 			= Liberacao mensal
cModLib 	:= Iif(ADY->ADY_TPCONT == "2", "1", "2")

AAH->(DbSetOrder(1))
cContMnt	:= GetSXENum("AAH","AAH_CONTRT")
While AAH->(DbSeek(xFilial("AAH")+cContMnt))
	ConfirmSX8()
	cContMnt := GetSXENum("AAH","AAH_CONTRT")
End
RollBackSx8()

aAdd(aCabec,{"AAH_CONTRT"	,cContMnt			,Nil})
aAdd(aCabec,{"AAH_CODCLI"	,ADY->ADY_CODIGO	,Nil})
aAdd(aCabec,{"AAH_LOJA"		,ADY->ADY_LOJA		,Nil})
aAdd(aCabec,{"AAH_TPCONT"	,cTpCont			,Nil})
aAdd(aCabec,{"AAH_CONPAG"	,cCondCalc			,Nil})
aAdd(aCabec,{"AAH_INIVLD"	,dDataBase			,Nil})
aAdd(aCabec,{"AAH_FIMVLD"	,dValidade			,Nil})
aAdd(aCabec,{"AAH_CPAGPV"	,cCondPV			,Nil})
aAdd(aCabec,{"AAH_VALOR"	,nValMens			,Nil})
aAdd(aCabec,{"AAH_CODPRO"	,cProdMens			,Nil})
aAdd(aCabec,{"AAH_INICOB"	,dDataBase			,Nil})
aAdd(aCabec,{"AAH_FIMCOB"	,dFimCobr			,Nil})
aAdd(aCabec,{"AAH_CODGRP"	,cGrpCob			,Nil})
aAdd(aCabec,{"AAH_PROPOS"	,cCodProp			,Nil})
aAdd(aCabec,{"AAH_REVPRO"	,cRevProp			,Nil})
aAdd(aCabec,{"AAH_OCOROS"	,cOcorren			,Nil})
AAdd(aCabec,{"AAH_CCUSTO"	,cCCusto			,Nil})

If !Empty(ADY->ADY_CLIENT)
	aAdd(aCabec,{"AAH_CLIENT"	,ADY->ADY_CLIENT	,Nil})
	aAdd(aCabec,{"AAH_LOJENT"	,ADY->ADY_LOJENT	,Nil})
EndIf

//Chave da base utilizada(Indice 4): AA3_FILIAL+AA3_CODFAB+AA3_LOJAFA+AA3_CODPRO+AA3_NUMSER
AA3->(DbSetOrder(4))

For nX := 1 to Len(aChaveAA3)
	AA3->(DbSeek(aChaveAA3[nX]))
	aItem := {}
	aAdd(aItem,{"AA3_CODFAB", AA3->AA3_CODFAB	} )
	aAdd(aItem,{"AA3_LOJAFA", AA3->AA3_LOJAFA	} )
	aAdd(aItem,{"AA3_CODPRO", AA3->AA3_CODPRO	} )
	aAdd(aItem,{"AA3_NUMSER", AA3->AA3_NUMSER	} )
	aAdd(aItem,{"M_A_R_K_"	, .T. 				} )
	aAdd(aItens,aItem)
Next nX

For nX := 1 to Len(aDemanda)
	AAdd(aGrupo,Array(3))
	aGrupo[nX][1] := {"AAQ_CODPRO", aDemanda[nX][1]	, Nil}	//Produto controlado
	aGrupo[nX][2] := {"AAQ_MODLIB", cModLib			, Nil}	//1=Fixo;2=Mensal
	aGrupo[nX][3] := {"AAQ_QTDLIB", aDemanda[nX][2]	, Nil}	//Quantidade liberada
Next nX

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//| Teste de Inclusao                                            |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
TECA200(NIL,aCabec,aItens,3,aGrupo)

If lMsErroAuto
	If !lAutomato
		Mostraerro()
		MsgAlert(STR0067) //"Erro ao gerar o contrato de manuten็ใo"
	Else
		ConOut(STR0067 + " - " + cFileLog) //"Erro ao gerar o contrato de manuten็ใo"
	EndIf
	lRet := .F.
Else //se gerou corretamente o contrato, copia os beneficios da proposta
	At240Benef(cCodProp, cRevProp, cContMnt)
EndIf

Return lRet


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt240LeProบAutor  ณVendas CRM          บ Data ณ  18/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLeitura dos produtos de acordo com o tipo, na proposta en-  บฑฑ
ฑฑบ          ณcerrada.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1-Codigo da proposta comercial                          บฑฑ
ฑฑบ          ณEXPC2-Revisao da proposta comercial                         บฑฑ
ฑฑบ          ณEXPC3-Tipo (1:Kit-Basico,2:Mensal,3:Demanda)                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA240                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function At240LePro(cCodProp,cRevProp,cTipo)

Local aArea		:= GetArea()
Local aRet		:= {}
Local nPos		:= 0
Local cFilADZ	:= xFilial("ADZ")
Local nDecs		:= TamSX3("ADZ_PRCVEN")[2]

DbSelectArea("ADZ")
DbSetOrder(3) //ADZ_FILIAL+ADZ_PROPOS+ADZ_REVISA+ADZ_FOLDER+ADZ_ITEM
DbSeek(cFilADZ + cCodProp + cRevProp)

While !ADZ->(Eof()) 			.AND.;
	ADZ->ADZ_FILIAL == cFilADZ	.AND.;
	ADZ->ADZ_PROPOS == cCodProp	.AND.;
	ADZ->ADZ_REVISA == cRevProp

	If ADZ->ADZ_TPPROD == cTipo
		nPos := aScan(aRet,{|x| x[1] == ADZ->ADZ_PRODUT})
		If nPos == 0
			AAdd(aRet,{ADZ->ADZ_PRODUT,ADZ->ADZ_QTDVEN, (ADZ->ADZ_PRCVEN * ADZ->ADZ_QTDVEN) })
		Else
			aRet[nPos][2] += ADZ->ADZ_QTDVEN
			aRet[nPos][3] += (ADZ->ADZ_PRCVEN * ADZ->ADZ_QTDVEN)
		EndIf
	EndIf
	ADZ->(DbSkip())
End

//Calcula o preco unitario medio
For nPos := 1 to Len(aRet)
	aRet[nPos][3] := Round(aRet[nPos][3]/aRet[nPos][2],nDecs)
Next nPos

RestArea(aArea)

Return aRet





ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt240CntSvบAutor  ณVendas CRM          บ Data ณ  31/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGeracao do contrato de servicos a partir dos itens da proposบฑฑ
ฑฑบ          ณta comercial.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 - Codigo da proposta comercial                        บฑฑ
ฑฑบ          ณEXPC2 - Revisao da proposta comercial                       บฑฑ
ฑฑบ          ณEXPC3 - (Referencia)Codigo do contrato de servicos gerado   บฑฑ
ฑฑบ          ณEXPC4 - Classificacao do contrato de servicos               บฑฑ
ฑฑบ          ณEXPD5 - Validade do contrato de servicos                    บฑฑ
ฑฑบ          ณEXPC6 - Condicao para calculo da geracao da cobranca/envio  บฑฑ
ฑฑบ          ณEXPC7 - Condicao de pagamento para os PV's gerados          บฑฑ
ฑฑบ          ณEXPC8 - Data para termino da cobranca do contrato           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA240                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function At240CntSv(	cCodProp	, cRevProp	, cContSrv	, cClassfic	,;
							dValidade	, cCondCalc	, cCondPV	, dFimCobr, lAutomato	)

Local lRet		:= .T.

Local aProdutos	:= {}
Local aCabec    := {}
Local aItens    := {}
Local aItem     := {}

Local cTpCont	:= ""

Local nX		:= 0
Local nQuantEnv	:= 0
Local nMeses	:= 0
Local nDecimal	:= TamSX3("AAN_QUANT")[2]
Local cFileLog	:= ""
Local cPath		:= "\"
Local nValorTot	:= 0


Default lAutomato := .F.


PRIVATE lMsErroAuto := .F.

//Carrega produtos de envio mensal
aProdutos := At240LePro(cCodProp,cRevProp,"2")

If Len(aProdutos) > 0

	ADY->(DbSetOrder(1)) //ADY_FILIAL+ADY_PROPOS
	AAM->(DbSetOrder(1)) //AAM_FILIAL+AAM_CONTRT

	cContSrv := GetSXENum("AAM","AAM_CONTRT")
	While AAM->(DbSeek(xFilial("AAM")+cContSrv))
		ConfirmSX8()
		cContSrv := GetSXENum("AAM","AAM_CONTRT")
	End
	RollBackSx8()

	ADY->(DbSeek(xFilial("ADY")+cCodProp))

	//3-Contrato Fixo 				= 1-Vitalicio
	//2-Contrato Pre-Determinado 	= 2-Tempo Determinado

	//ADY_TPCONT -> 1=Nenhum;2=Pre-Determinado;3=Fixo

	cTpCont 	:= Iif(ADY->ADY_TPCONT == "2", "2", "1")

	aAdd(aCabec,{"AAM_CONTRT" ,cContSrv			,Nil})
	aAdd(aCabec,{"AAM_CODCLI" ,ADY->ADY_CODIGO	,Nil})
	aAdd(aCabec,{"AAM_LOJA"   ,ADY->ADY_LOJA	,Nil})
	aAdd(aCabec,{"AAM_TPCONT" ,cTpCont			,Nil})
	aAdd(aCabec,{"AAM_CLASSI" ,cClassfic		,Nil})
	aAdd(aCabec,{"AAM_ABRANG" ,"1"				,Nil})
	aAdd(aCabec,{"AAM_STATUS" ,"1"				,Nil})
	aAdd(aCabec,{"AAM_INIVIG" ,dDataBase		,Nil})
	aAdd(aCabec,{"AAM_FIMVIG" ,dValidade		,Nil})
	aAdd(aCabec,{"AAM_CPAGPV" ,cCondPV			,Nil})
	aAdd(aCabec,{"AAM_PROPOS" ,cCodProp			,Nil})
	aAdd(aCabec,{"AAM_REVPRO" ,cRevProp			,Nil})

	If !Empty(ADY->ADY_CLIENT)
		aAdd(aCabec,{"AAM_CLIENT"	,ADY->ADY_CLIENT	,Nil})
		aAdd(aCabec,{"AAM_LOJENT"	,ADY->ADY_LOJENT	,Nil})
	EndIf

	//Tempo determinado
	If cTpCont == "2"
		//Calcula a quantidade de contratos gerados no periodo
		nMeses := (Year(dValidade)*12 + Month(dValidade)) - (Year(dDataBase)*12 + Month(dDataBase))
		If (day(dValidade) >= day(dDataBase))
			nMeses++
		EndIf
	EndIf

	For nX := 1 to Len(aProdutos)

		If cTpCont == "1"
			nQuantEnv := aProdutos[nX][2]
		Else
			nQuantEnv := Round(aProdutos[nX][2]/nMeses,nDecimal)
		EndIf

		nValorTot := nQuantEnv *  aProdutos[nX][3]
		aItem := {}
		AAdd(aItem,{"AAN_ITEM"		,StrZero(nX,2)		,NIL 			})
		aAdd(aItem,{"AAN_CODPRO"	,aProdutos[nX][1]	,NIL 			})
		aAdd(aItem,{"AAN_QUANT"		,nQuantEnv			,NIL 			})
		aAdd(aItem,{"AAN_VLRUNI"	,aProdutos[nX][3]	,NIL			})
		aAdd(aItem,{"AAN_VALOR"		,nValorTot			,NIL			})
		aAdd(aItem,{"AAN_CONPAG"	,cCondCalc			,NIL 			})
		aAdd(aItem,{"AAN_INICOB"	,dDataBase			,NIL 			})
		aAdd(aItem,{"AAN_FIMCOB"	,dFimCobr			,NIL 			})

		aAdd(aItens,aClone(aItem))
	Next nX

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//| Teste de Inclusao                                            |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	TECA250(NIL,aCabec,aItens,NIL,NIL,3)

	If lMsErroAuto
		lRet := .F.
		ConOut(STR0069) //"Erro na inclusao do contrato de servi็os!"
		If !lAutomato

		MostraErro()
		Else
			cFileLog := MostraErro(cPath)
			ConOut(cFileLog)
		EndIf

	EndIf

End

Return lRet


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt240ImpCAบAutor  ณVendas CRM          บ Data ณ  06/12/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImporta a configuracao da alocacao da ABO para ABQ.		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 - Codigo da proposta comercial.                       บฑฑ
ฑฑบ          ณEXPC2 - Revisao da proposta comercial.                      บฑฑ
ฑฑบ          ณEXPC3 - Numero do Contrato.								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA240                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function At240ImpCA(cCodProp,cRevProp,cContMnt)

Local cItem	:= StrZero(0,TAMSX3("ABQ_ITEM")[1])
Local aArea 	:= GetArea()

DbSelectArea("ABO")
DbSetOrder(1)

If DbSeek(xFilial("ABO")+cCodProp+cRevProp)

	DbSelectArea("ABQ")
	DbSetOrder(2)//ABQ_FILIAL+ABQ_CONTRT+ABQ_ORIGEM

	If !DbSeek(xFilial("ABQ")+cContMnt+Space(TamSx3("ABQ_ORIGEM")[1]))
		While ABO->( ABO->(!Eof()) .AND. ABO->ABO_FILIAL+ABO->ABO_PROPOS+ABO->ABO_REVPRO == xFilial("ABO")+cCodProp+cRevProp )
			ABQ->(RecLock("ABQ",.T.))
			cItem := Soma1(cItem)
			Replace ABQ_FILIAL 	With xFilial("ABQ")
			Replace ABQ_CONTRT 	With cContMnt
			Replace ABQ_ITEM   	With cItem
			Replace ABQ_PRODUT 	With ABO->ABO_PRODUT
			Replace ABQ_TPPROD 	With ABO->ABO_TPPROD
			Replace ABQ_TPREC  	With ABO->ABO_TPREC
			Replace ABQ_CARGO  	With ABO->ABO_CARGO
			Replace ABQ_FUNCAO 	With ABO->ABO_FUNCAO
			Replace ABQ_PERINI  With ABO->ABO_PERINI
			Replace	ABQ_PERFIM 	With ABO->ABO_PERFIM
			Replace ABQ_TURNO	With ABO->ABO_TURNO
			Replace ABQ_HRSEST	With ABO->ABO_HRSEST
			Replace ABQ_FATOR   With ABO->ABO_FATOR
			Replace ABQ_TOTAL   With ABO->ABO_TOTAL
			Replace ABQ_SALDO   With ABO->ABO_TOTAL
			ABQ->(MsUnlock())
			ABO->(DbSkip())
		End
	EndIf
EndIf

RestArea(aArea)

Return( .T. )


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt240SugesบAutor  ณVendas CRM          บ Data ณ  18/01/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSugestao de base de atendimento utilizado cadastro de locaisบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPO1 - ListBox proposta comercial.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA240                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function At240Suges(oLbxProp,aPropostas,oLbxBase,aBase,lAutomato, aAutoLoc)

Local aAreaADZ		:= ADZ->(GetArea())					// Area da tabela ADZ.
Local lRetorno		:= .T.								// Retorno da rotina.
Local nPos			:= 0								// Posicao da marca.
Local cCodProp		:= ""								// Codigo da proposta comercial.
Local cRevProp		:= ""								// Revisao da proposta comercial.
Local cIdUnico		:= ""								// Identificador da base.
Local aLocais 		:= {}								// Locais de atendimento.
Local oDlg			:= Nil								// Dialog principal.
Local aSize	 		:= FWGetDialogSize( oMainWnd ) 		// Array com tamanho da janela.
Local oColSugest	:= Nil								// Coluna sugestao de base de atendimento.
Local oBrwSugest	:= Nil								// Browse sugestao de base de atendimento.

Local nI := 1
Default lAutomato := .F.
Default aAutoLoc  := {}

//Codigo da proposta selecionada
If !lAutomato
	nPos 		:= 	aScan(oLbxProp:aArray,{|x| x[P_MARCA]})
	cCodProp 	:= 	oLbxProp:aArray[nPos,P_PROPOS]
	cRevProp 	:= 	oLbxProp:aArray[nPos,P_REVISA]
Else
	nPos 		:= 	aScan(aPropostas,{|x| x[P_MARCA]})
	cCodProp 	:= 	aPropostas[nPos,P_PROPOS]
	cRevProp 	:= aPropostas[nPos,P_REVISA]
EndIf


DbSelectArea("ADY")
DbSetOrder(1) //ADY_FILIAL+ADY_PROPOS

If DbSeek(xFilial("ADY")+cCodProp)

	// ADZ_FILIAL+ADZ_PROPOS+ADZ_REVISA+ADZ_FOLDER+ADZ_ITEM
	DbSelectArea("ADZ")
	DbSetOrder(3)

	If DbSeek(xFilial("ADZ")+cCodProp+cRevProp)
		aAdd( aLocais,{ADY->ADY_CODIGO										,;
			ADY->ADY_LOJA													,;
			ADZ->ADZ_PRODUT													,;
			Posicione("SB1",1,xFilial("SB1")+ADZ->ADZ_PRODUT,"B1_DESC")		,;
			Space(TAMSX3("AA3_NUMSER")[1])									,;
			ADZ->ADZ_LOCAL													,;
			Posicione("ABS",1,xFilial("ABS")+ADZ->ADZ_LOCAL,"ABS_DESCRI")	} )
	EndIf

	If !lAutomato
		If Len(aLocais) > 0

			DEFINE DIALOG oDlg TITLE STR0075 FROM aSize[1]*0.47,aSize[2]*0.75 TO aSize[3]*0.47,aSize[4]*0.75 PIXEL  // "Sugestใo de Bases de Atendimento"

			DEFINE FWBROWSE oBrwSugest DATA ARRAY ARRAY aLocais LINE BEGIN 1 EDITCELL { |lCancel,oBrowse| At240VdEdt(lCancel,oBrowse,aLocais) } OF oDlg

			ADD COLUMN oColSugest DATA &("{ || aLocais[oBrwSugest:At()][3] }")  TITLE TxDadosCpo("AA3_CODPRO")[1] SIZE TamSX3("AA3_CODPRO")[1] OF oBrwSugest   											// "Produto/Eqto"
			ADD COLUMN oColSugest DATA &("{ || aLocais[oBrwSugest:At()][4] }")  TITLE TxDadosCpo("AA3_DESPRO")[1] SIZE TamSX3("AA3_DESPRO")[1] OF oBrwSugest   											// "Desc.Produto"
			ADD COLUMN oColSugest DATA &("{ || aLocais[oBrwSugest:At()][5] }")  TITLE TxDadosCpo("AA3_NUMSER")[1] SIZE TamSX3("AA3_NUMSER")[1] PICTURE "@!" EDIT  READVAR "cIdUnico" OF oBrwSugest  		// "Id.Unico"
			ADD COLUMN oColSugest DATA &("{ || aLocais[oBrwSugest:At()][6] }")  TITLE TxDadosCpo("AA3_CODLOC")[1] SIZE TamSX3("AA3_CODLOC")[1] OF oBrwSugest   											// "Cod. Local"
			ADD COLUMN oColSugest DATA &("{ || aLocais[oBrwSugest:At()][7] }")  TITLE TxDadosCpo("ABS_DESCRI")[1] SIZE TamSX3("ABS_DESCRI")[1] OF oBrwSugest    											// "Descri็ใo."

			ACTIVATE FWBROWSE oBrwSugest

			ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IIF(At240VdGvb(aLocais),MsgRun(STR0076,STR0077,{|| At240GvBse(aLocais),oDlg:End()}),lRetorno := .F. )},{|| lRetorno := .F.,oDlg:End()}) CENTERED // "Gerando as bases de atendimento..."###"Aguarde"
		Else
			MsgAlert(STR0078,STR0079)  // "Nใo hแ sugestใo de bases de atendimento para esta proposta comercial."###"Aten็ใo"
			lRetorno := .F.
		EndIf
	Else
		For nI:= 1 To Len(aAutoLoc)
			If (nPos := Ascan(aLocais, { |x| x[1]+x[2]+x[3]+x[6] == aAutoLoc[nI,1]+aAutoLoc[nI,2]+aAutoLoc[nI,3]+aAutoLoc[nI,4] })) > 0
				aLocais[nPos,5] := aAutoLoc[nI,5]
			EndIf
		Next nI
		lRetorno := .F.
		If At240VdGvb(aLocais)
			lRetorno := At240GvBse(aLocais, lAutomato)
		EndIf

	EndIf
Else
	MsgStop(STR0080,STR0079)// "Proposta comercial nใo localizada."###"Aten็ใo"
	lRetorno := .F.
EndIf

ADZ->(RestArea(aAreaADZ))

Return( lRetorno )



ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt240VdEdtบAutor  ณVendas CRM          บ Data ณ  18/01/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a edi็ใo do browse sugestใo de base de atendimento.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPL1 - Usuario cancelou a edicao?.                         บฑฑ
ฑฑบ          ณEXPO2 - Browse sugestใo de base de atendimento.             บฑฑ
ฑฑบ          ณEXPA3 - Locais de atendimento.						      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA240                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function At240VdEdt(lCancel,oBrowse,aLocais)

Local lRetorno	:= .T.						// Retorno da rotina.
Local nX		:= 0						// Incremento utilizado no For.
Local cConteudo	:= &(ReadVar())				// Conteudo em memoria do campo.
Local cChvPos	:= ""						// Chave posicionada.
Local cChvAtu	:= ""						// Chave atual.
Local nAux		:= 0						// Variavel auxiliar da linha do aCols.


If Type("n") <> "U"
	nAux := n
	n := Nil
EndIf

If !lCancel

	cChvPos := aLocais[oBrowse:nAt][1]+aLocais[oBrowse:nAt][2]+aLocais[oBrowse:nAt][3]+cConteudo

	RegToMemory("AA3",.T.,.F.,.F.)

	For nX := 1 To Len(aLocais)

		cChvAtu := aLocais[nX][1]+aLocais[nX][2]+aLocais[nX][3]+aLocais[nX][5]

		If nX <> oBrowse:nAt .AND. !Empty(cConteudo) .AND. cChvAtu == cChvPos
			MsgStop(STR0081,STR0079)	// "Identificador jแ informado para este produto."###"Aten็ใo"
			lRetorno := .F.
			Exit
		EndIf

		If lRetorno

			M->AA3_CODCLI	:= aLocais[nX][1]
			M->AA3_LOJA 	:= aLocais[nX][2]
			M->AA3_CODPRO	:= aLocais[nX][3]
			M->AA3_NUMSER	:= cConteudo

			If !( At040SkSer() .AND. ExistChav("AA3",M->AA3_CODCLI+M->AA3_LOJA+M->AA3_CODPRO+M->AA3_NUMSER) )
				lRetorno := .F.
				Exit
			EndIf

		EndIf

	Next nX

	If lRetorno
		aLocais[oBrowse:nAt][5] := cConteudo
	EndIf

EndIf

If nAux <> 0
	n := nAux
EndIf

Return( lRetorno )



ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณAt240GvBseบAutor  ณVendas CRM          บ Data ณ    18/01/13  	 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณValida o browse sugestao de base de atendimento antes de gravarบฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPA1 - Locais de atendimento.                       		     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA240                                                        บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function At240VdGvb(aLocais)

Local lRetorno := .T.	// Retorno da rotina.

aEval(aLocais,{|x| IIF(Empty(x[5]),lRetorno := .F., Nil)})

If !lRetorno
	MsgStop(STR0082,STR0079) // "Identificador nใo informado."##"Aten็ใo"
EndIf

Return( lRetorno )


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออออปฑฑ
ฑฑบPrograma  ณAt240GvBseบAutor  ณVendas CRM          บ Data ณ  18/01/13     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑบDesc.     ณGrava a base de atendimento atraves dos locais de atendimento.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPA1 - Locais de atendimento.                       		    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA240                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function At240GvBse(aLocais, lAutomato)

Local lRetorno	:= .T.			// Retorno da rotina.
Local nX		:= 0			// Incremento utilizado no For.
Local aCabec	:= {}			// Array que contem o cabe็alho da tabela AA3.
Local aItens	:= {}			// Array itens da base de atendimento.
Local cFileLog	:= ""
Local cPath		:= "\"


Private lMsErroAuto	:= .F.

Default lAutomato := .F.

For nX := 1 To Len(aLocais)

	Aadd(aCabec,{"AA3_FILIAL"	,xFilial("AA3")	,Nil})
	Aadd(aCabec,{"AA3_CODCLI"	,aLocais[nX][1]	,Nil})
	Aadd(aCabec,{"AA3_LOJA"  	,aLocais[nX][2]	,Nil})
	Aadd(aCabec,{"AA3_CODPRO"	,aLocais[nX][3]	,Nil})
	Aadd(aCabec,{"AA3_NUMSER"	,aLocais[nX][5]	,Nil})
	Aadd(aCabec,{"AA3_DTVEN"	,Date()			,Nil})
	Aadd(aCabec,{"AA3_CODLOC"	,aLocais[nX][6]	,Nil})

	MsExecAuto( {|w,x,y,z| TECA040(w,x,y,z)},Nil,aCabec,aItens, 3)

	If lMsErroAuto .AND. !lAutomato
		MostraErro()
	ElseIf lMsErroAuto
		cFileLog := MostraErro(cPath)
		ConOut(cFileLog)
	EndIf

	aCabec	:= {}
	aItens	:= {}

Next nX

Return( lRetorno )


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออออปฑฑ
ฑฑบPrograma  ณAt240BenefบAutor  ณVendas CRM          บ Data ณ  14/02/13     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑบDesc.     ณCopia os beneficios da proposta para o contrato              .บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPc1 - Codigo da proposta comercial                 		   บฑฑ
ฑฑ           ณEXPc2 - Revisao da proposta                            		   บฑฑ
ฑฑ           ณEXPc3 - Codigo do contrato de manutencao              		   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA240                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function At240Benef(cCodProp, cRevProp, cContMnt)

Local aArea 		:= GetArea()
Local aAreaABP 	:= ABP->(GetArea())
Local aTemp		:= {}
Local aABPDuplic	:= {}
Local nI			:= 0
Local nCntFor		:= 0

DbSelectArea("ABP")
DbSetOrder(1) //ABP_FILIAL+ABP_COD+ABP_ENTIDA+ABP_REVISA+ABP_CODPRO+ABP_ITEM+ABP_BENEFI

If DbSeek(xFilial("ABP") + PADR(cCodProp,15) + '1' + cRevProp)

	While ABP->(!EOF()) .AND. ABP->ABP_FILIAL == xFilial("ABP") .AND. TRIM(ABP->ABP_COD) == TRIM(cCodProp) .AND. ABP->ABP_REVISA == cRevProp
		For nI := 1 To ABP->(FCount())
			aAdd(aTemp,{FieldName(nI),&("ABP->"+FieldName(nI))})
		Next nI
		aAdd(aABPDuplic,aTemp)
		aTemp := {}
		ABP->(DbSkip())
	End
	For nI:= 1 to Len(aABPDuplic)
		RecLock("ABP",.T.)
		For nCntFor := 1 To ABP->(FCount())
			Do Case
			Case ( FieldName(nCntFor) == "ABP_COD" )
				FieldPut(nCntFor,cContMnt)
			Case ( FieldName(nCntFor) == "ABP_REVISA" )
				FieldPut(nCntFor,'')
			Case ( FieldName(nCntFor) == "ABP_ENTIDA" )
				FieldPut(nCntFor,'2')
			OtherWise
				FieldPut(nCntFor,aABPDuplic[nI][nCntFor][2])
			EndCase
		Next nCntFor
		ABP->( MsUnLock() )
	Next nI
EndIf


ABP->(RestArea(aAreaABP))
RestArea(aArea)

Return


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออออปฑฑ
ฑฑบPrograma  ณAt240VldCCบAutor  ณVendas CRM          บ Data ณ  26/03/13     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑบDesc.     ณValida o Centro de Custo.										   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC - Centro de Custo do Contrato                       	   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA240                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function At240VldCC(cCCusto)
Local lRet 	:= .F.
Local aArea	:= GetArea()

Default cCCusto := ""

//Verifica se o centro de custo ้ do tipo Analitico
If !Empty(cCCusto)
	If Posicione( "CTT",1,xFilial("CTT")+cCCusto,"CTT_CLASSE ")	==	"2"
		lRet := .T.
	Else
		Aviso( STR0083, STR0084 + STR0085 + CHR(13) + STR0086, { STR0087 } ,2) //"Atencao !"#"O Centro de Custo para o contrato deverแ ser do tipo analํtico, pois serแ feito lan็amento contแbil e nใo ้ possivel realizแ-lo quando o centro de custo ้ sint้tico ! "#"Ok"
	EndIf
Else
	//Retorna .T. para nใo tornar o centro de custo obrigatorio
	lRet := .T.
EndIf

RestArea(aArea)

Return(lRet)*/


