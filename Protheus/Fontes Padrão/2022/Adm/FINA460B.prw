#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "FWBROWSE.CH"
#Include "ApWizard.ch"
#INCLUDE "FINA460A.CH"

#DEFINE OPER_BLOQUEAR		10
#DEFINE OPER_DESBLOQUEAR    11
#DEFINE OPER_CANCELAR		12
#DEFINE OPER_INCLUI			13
#DEFINE OPER_ALTERA			14
#DEFINE OPER_EFETIVAR		15
#DEFINE OPER_LIQUIDAR		16
#DEFINE OPER_RELIQUIDAR		17
#DEFINE ENTER				Chr(13)+ Chr(10)

Function FINA460B()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Função responsavel pela View da rotina de liquidação a receber
quando utilizamos a leitora de cheques 
@author lucas.oliveira
@since 13/10/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= FWLoadModel("FINA460A")
Local oView		:= FWFormView():New()
Local oStruFO0	:= FWFormStruct(2,"FO0")
Local oStruFOB	:= FWFormStruct(2,"FO0")
Local oStruFO1	:= F460BCpoFO1(2)

Local oStruFO2	:= FWFormStruct(2,"FO2")
Local aAuxFO0	:= aClone(oStruFO0:GetFields())
Local aAuxFO1	:= aClone(oStruFO1:GetFields())
Local aAuxFO2	:= aClone(oStruFO2:GetFields())

Local nTimeOut  := SuperGetMv("MV_FATOUT",.F.,900)*1000 	//Estabelece 15 minutos para que o usuarios selecione - 
Local nTimeMsg  := SuperGetMv("MV_MSGTIME",.F.,120)*1000 	//Estabelece 02 minutos para exibir a mensagem para o usuário

Local lExisTxMoe:= ExistFunc("FA460TXMOE")

Local lCpoTxMoed:= FO0->(ColumnPos("FO0_TXMOED")) > 0
Local lCpoFO1Ad := FO1->(ColumnPos("FO1_VLADIC")) > 0
Local lCpCalJur	:= FO0->(ColumnPos("FO0_CALJUR")) > 0 .And. FO2->(ColumnPos("FO2_TXCALC")) > 0 .And. FO2->(ColumnPos("FO2_VLRJUR")) > 0  // Proteção criada para versão 12.1.27
Local lIntPFS   := FindFunction("JLiqView") .And. AliasInDic("OHT") .And. SuperGetMV("MV_JURXFIN",,.F.) // Integração SIGAFIN x SIGAPFS

Local nX		:= 0

oStruFO0:SetProperty( 'FO0_DATA'	, MVC_VIEW_ORDEM,	'05')
oStruFO0:SetProperty( 'FO0_DTVALI'	, MVC_VIEW_ORDEM,	'06')
oStruFO0:SetProperty( 'FO0_STATUS'	, MVC_VIEW_ORDEM,	'07')
oStruFO0:SetProperty( 'FO0_CLIENT'	, MVC_VIEW_ORDEM,	'08')
oStruFO0:SetProperty( 'FO0_LOJA'	, MVC_VIEW_ORDEM,	'09')
oStruFO0:SetProperty( 'FO0_NUMLIQ'	, MVC_VIEW_ORDEM,	'11')
oStruFO0:SetProperty( 'FO0_NATURE'	, MVC_VIEW_ORDEM,	'12')
oStruFO0:SetProperty( 'FO0_MOEDA'	, MVC_VIEW_ORDEM,	'13')
oStruFO0:SetProperty( 'FO0_COND'	, MVC_VIEW_ORDEM,	'14')
oStruFO0:SetProperty( 'FO0_TIPO'	, MVC_VIEW_ORDEM,	'15')
oStruFO0:SetProperty( 'FO0_TXJUR'	, MVC_VIEW_ORDEM,	'16')
oStruFO0:SetProperty( 'FO0_TXMUL'	, MVC_VIEW_ORDEM,	'17')
oStruFO0:SetProperty( 'FO0_TXJRG'	, MVC_VIEW_ORDEM,	'18')

If lCpCalJur
	oStruFO0:SetProperty( 'FO0_CALJUR'	, MVC_VIEW_ORDEM,	'19')
Endif

If lCpoTxMoed .And. lExisTxMoe
	oStruFO0:SetProperty( 'FO0_TXMOED'	, MVC_VIEW_ORDEM,	'19')
Endif

oStruFO0:AddField(	"FO0_RAZAO", "10", OemToAnsi(STR0015), OemToAnsi(STR0015), {}, "G", "@!")//"Razão social"

If Empty(MV_PAR09) .Or. MV_PAR09 = 1
	oStruFO0:AddField(	"FO0_VLRLIQ", "20", STR0102, STR0102, {}, "N", PesqPict("FO2","FO2_VALOR") ) //"Valor Total a Liquidar"
	oStruFO0:AddField(	"FO0_VLRNEG", "21", STR0103, STR0103, {}, "N", PesqPict("FO2","FO2_VALOR") ) //"Valor Total Negociado"
	oStruFO0:AddField(	"FO0_VLRJUR", "22", STR0138, STR0138, {}, "N", PesqPict("FO2","FO2_VALOR") ) //"Valor Total Juros"
	oStruFO0:AddField(	"FO0_TTLTIT", "23", STR0137, STR0137, {}, "C" )	//"Qtde Títulos"
Else
	oStruFOB:AddField(	"FO0_VLRLIQ", "20", STR0102, STR0102, {}, "N", PesqPict("FO2","FO2_VALOR") ) //"Valor Total a Liquidar"
	oStruFOB:AddField(	"FO0_VLRNEG", "21", STR0103, STR0103, {}, "N", PesqPict("FO2","FO2_VALOR") ) //"Valor Total Negociado"
	oStruFOB:AddField(	"FO0_VLRJUR", "22", STR0138, STR0138, {}, "N", PesqPict("FO2","FO2_VALOR") ) //"Valor Total Juros"
	oStruFOB:AddField(	"FO0_TTLTIT", "23", STR0137, STR0137, {}, "C" )	//"Qtde Títulos"
Endif

If FwIsInCallStack("F460AIncl") .OR. FwIsInCallStack("F460AltSim") .Or. ( FwIsInCallStack("TMKA271D") .And. !FwIsInCallStack("F460AEfet") )
	oStruFO0:AddField( 'FO0_EFETIVA', '04', STR0049, STR0050, {	STR0051/*"Para efetivar esta simulação, selecione a "*/, STR0052/*"opção 'Sim' e clique em salvar para que"*/, STR0053 /*" o sistema realize a efetivação."*/}, 'Combo' ,,,,,,,{'1='+STR0047, '2='+STR0048},,'2='+STR0048,.T.,, )
EndIf

oStruFO2:AddField(	"FO2_VLPARC", "12", STR0088, "Vlr. Parc. Gerar", {}, "N", PesqPict("FO2","FO2_VALOR") )		//"Vlr. Parc. Gerar"

oStruFO2:SetProperty( 'FO2_PREFIX'	, MVC_VIEW_ORDEM,	'04')
oStruFO2:SetProperty( 'FO2_NUM'		, MVC_VIEW_ORDEM,	'05')
oStruFO2:SetProperty( 'FO2_PARCEL'	, MVC_VIEW_ORDEM,	'06')
oStruFO2:SetProperty( 'FO2_TIPO'	, MVC_VIEW_ORDEM,	'07')
oStruFO2:SetProperty( 'FO2_VALOR'	, MVC_VIEW_ORDEM,	'08')
oStruFO2:SetProperty( 'FO2_TXJUR'	, MVC_VIEW_ORDEM,	'09')
oStruFO2:SetProperty( 'FO2_VLJUR'	, MVC_VIEW_ORDEM,	'11')

If lCpCalJur
	oStruFO2:SetProperty( 'FO2_TXCALC'	, MVC_VIEW_ORDEM,	'12')
Endif

oStruFO2:SetProperty( 'FO2_VLRJUR'	, MVC_VIEW_ORDEM,	'13')
oStruFO2:SetProperty( 'FO2_VLPARC'	, MVC_VIEW_ORDEM,	'14')
oStruFO2:SetProperty( 'FO2_ACRESC'	, MVC_VIEW_ORDEM,	'15')
oStruFO2:SetProperty( 'FO2_DECRES'	, MVC_VIEW_ORDEM,	'16')
oStruFO2:SetProperty( 'FO2_TOTAL'	, MVC_VIEW_ORDEM,	'17')
oStruFO2:SetProperty( 'FO2_BANCO'	, MVC_VIEW_ORDEM,	'18')
oStruFO2:SetProperty( 'FO2_AGENCI'	, MVC_VIEW_ORDEM,	'19')
oStruFO2:SetProperty( 'FO2_CONTA'	, MVC_VIEW_ORDEM,	'20')
oStruFO2:SetProperty( 'FO2_NUMCH'	, MVC_VIEW_ORDEM,	'21')
oStruFO2:SetProperty( 'FO2_EMITEN'	, MVC_VIEW_ORDEM,	'22')

oStruFO2:SetProperty( 'FO2_PARCEL'	, MVC_VIEW_PICT,	'@!')

oStruFO2:SetProperty( 'FO2_VLJUR' 	, MVC_VIEW_TITULO, 'Vlr.Adicional Negoc.' )


oView:SetModel(oModel)

If Empty(MV_PAR09) .Or. MV_PAR09 = 1
	oView:AddField("VIEW_FO0", oStruFO0, "MASTERFO0")
	oView:AddGrid("VIEW_FO1", oStruFO1, "TITSELFO1")
	oView:AddGrid("VIEW_FO2",	oStruFO2, "TITGERFO2")
	
	oView:CreateHorizontalBox("BOXFO0", 30)
	oView:CreateHorizontalBox("BOXFO1", 35)
	oView:CreateHorizontalBox("BOXFO2", 35)
	
	oView:SetOwnerView("VIEW_FO0", "BOXFO0")
	oView:SetOwnerView("VIEW_FO1", "BOXFO1")
	oView:SetOwnerView("VIEW_FO2", "BOXFO2")
	
	oView:AddOtherObject("btnMarcaDesm", {|oPanel,oView| F460Botao(oPanel,oView,oModel)})
	oView:SetOwnerView("btnMarcaDesm",'BOXFO1')
	
	oView:EnableTitleView("VIEW_FO1", OemToAnsi(STR0016)) // "Títulos Selecionados"
	oView:EnableTitleView("VIEW_FO2", OemToAnsi(STR0017)) // "Títulos Gerados"
	
Else
	oView:AddField("VIEW_FO0", oStruFO0, "MASTERFO0")
	
	oView:CreateHorizontalBox('GERAL',85)
	oView:CreateHorizontalBox('BARRA',15)
	
	oView:AddField("VIEW_FOB", oStruFOB, "MASTERFO0")
	oView:SetOwnerView("VIEW_FOB", "BARRA")
	
	oView:CreateFolder('PASTAS','GERAL')
	oView:AddSheet('PASTAS','PASTA1', STR0059 ) // "Liquidação a Receber"
	oView:CreateHorizontalBox('ID_PASTA_MASTERFO0',100,,,'PASTAS', 'PASTA1' )
	
	oView:SetOwnerView('MASTERFO0','ID_PASTA_MASTERFO0')
	oView:AddSheet('PASTAS','PASTA2', STR0016 ) // "Títulos Selecionados"
	oView:CreateHorizontalBox('ID_PASTA_TITSELFO1',100,,,'PASTAS', 'PASTA2' )
	
	oView:AddGrid("VIEW_FO1", oStruFO1, "TITSELFO1")
	oView:SetOwnerView("VIEW_FO1", "ID_PASTA_TITSELFO1")
	
	oView:AddSheet('PASTAS','PASTA3', STR0017 ) // "Títulos Gerados"
	oView:CreateHorizontalBox('ID_PASTA_TITGERFO2',100,,,'PASTAS', 'PASTA3' )
	
	oView:AddGrid("VIEW_FO2",	oStruFO2, "TITGERFO2")
	oView:SetOwnerView("VIEW_FO2", "ID_PASTA_TITGERFO2")
	
	oView:AddOtherObject("btnMarcaDesm", {|oPanel,oView| F460Botao(oPanel,oView,oModel)})
	oView:SetOwnerView("btnMarcaDesm",'ID_PASTA_TITSELFO1')
	
	oView:EnableTitleView("VIEW_FOB",  STR0181 ) // "Títulos Totalizados" # "Totalizadores"
	
	oStruFOB:RemoveField("FO0_PROCES")
	oStruFOB:RemoveField("FO0_VERSAO")
	oStruFOB:RemoveField("FO0_NUMLIQ")
	oStruFOB:RemoveField("FO0_DATA")
	oStruFOB:RemoveField("FO0_DTVALI")
	oStruFOB:RemoveField("FO0_COND")
	oStruFOB:RemoveField("FO0_TXJUR")
	oStruFOB:RemoveField("FO0_TXMUL")
	oStruFOB:RemoveField("FO0_TXJRG")

	If lCpCalJur
		oStruFOB:RemoveField("FO0_CALJUR")
	Endif

	oStruFOB:RemoveField("FO0_CLIENT")
	oStruFOB:RemoveField("FO0_LOJA")
	oStruFOB:RemoveField("FO0_NATURE")
	oStruFOB:RemoveField("FO0_STATUS")
	oStruFOB:RemoveField("FO0_MOEDA")
	oStruFOB:RemoveField("FO0_BKPSTT")
	oStruFOB:RemoveField("FO0_ORIGEM")
	oStruFOB:RemoveField("FO0_CODLIG")
	oStruFOB:RemoveField("FO0_TIPO")
	oStruFOB:RemoveField("FO0_TXMOED")
	
Endif

oView:SetNoInsertLine("VIEW_FO1")
oView:SetNoDeleteLine("VIEW_FO1")

oView:SetViewProperty("VIEW_FO1", "GRIDFILTER", {.T.}) 

If Empty(MV_PAR09) .Or. MV_PAR09 = 1
	If _nOper == OPER_LIQUIDAR
		oView:EnableTitleView("VIEW_FO0", OemToAnsi( STR0059 ))//"Liquidação a Receber"
	ElseIf _nOper == OPER_RELIQUIDAR
		oView:EnableTitleView("VIEW_FO0", OemToAnsi( STR0060 ))//"Reliquidação a Receber"
	EndIf
Endif

For nX := 1 To Len(aAuxFO0)
	If aAuxFO0[nX][1] $ "FO0_BKPSTT|FO0_ORIGEM|FO0_CODLIG|"
		oStruFO0:RemoveField( aAuxFO0[nX][1] )
	EndIf
Next nX

For nX := 1 To Len(aAuxFO1)
	If !FwIsInCallStack("TMKA271D")
		If aAuxFO1[nX][1] $ "FO1_FILIAL|FO1_PROCES|FO1_VERSAO|FO1_IDDOC|FO1_DESJUR"
			oStruFO1:RemoveField( aAuxFO1[nX][1] )
		EndIf
	Else
		If aAuxFO1[nX][1] $ "FO1_FILIAL|FO1_PROCES|FO1_VERSAO|FO1_IDDOC"
			oStruFO1:RemoveField( aAuxFO1[nX][1] )
		EndIf	
	EndIf
Next nX

For nX := 1 To Len(aAuxFO2)
	If aAuxFO2[nX][1] $ "FO2_PROCES|FO2_VERSAO|FO2_IDSIM|"
		oStruFO2:RemoveField( aAuxFO2[nX][1] )
	EndIf
Next nX

oView:SetFieldAction("FO0_TXJUR",{|oModel| F460JurMul(oModel, "FO0_TXJUR" )} )
oView:SetFieldAction("FO0_TXMUL",{|oModel| F460JurMul(oModel, "FO0_TXMUL" )} )

oView:SetFieldAction("FO1_MARK", {|oModel| F460TitGer(oModel, "FO1_MARK", ,.T. )} )
oView:SetFieldAction("FO1_TXJUR",{|oModel| F460JurMul(oModel, "FO1_TXJUR" )} )
oView:SetFieldAction("FO1_TXMUL",{|oModel| F460JurMul(oModel, "FO1_TXMUL" )} )
oView:SetFieldAction("FO1_VLJUR",{|oModel| F460JurMul(oModel, "FO1_VLJUR" )} )
oView:SetFieldAction("FO1_VLDIA",{|oModel| F460JurMul(oModel, "FO1_VLDIA" )} )
oView:SetFieldAction("FO1_VLMUL",{|oModel| F460JurMul(oModel, "FO1_VLMUL" )} )
oView:SetFieldAction("FO1_DESCON",{|oModel| F460JurMul(oModel, "FO1_DESCON" )} )

If lCpoFO1Ad
	oView:SetFieldAction("FO1_VLADIC",{|oModel| F460JurMul(oModel, "FO1_VLADIC" )} )
Endif

//Caso seja uma operação de bloqueio, desbloqueio, cancelamento ou efetivação de simulação de liquidação, nao permito a inclusão e deleção de linhas.
If _nOper == OPER_BLOQUEAR .OR. _nOper == OPER_DESBLOQUEAR .OR. _nOper == OPER_CANCELAR .OR. _nOper == OPER_EFETIVAR
	oView:SetOnlyView("VIEW_FO0")
	oView:SetOnlyView("VIEW_FO1")
	oView:SetOnlyView("VIEW_FO2")
	oView:SetNoInsertLine("VIEW_FO2")
	oView:SetNoDeleteLine("VIEW_FO2")
EndIf

If lIntPFS // Integração SIGAFIN x SIGAPFS
	JLiqView(oView)
EndIf

oView:SetTimer( nTimeMsg, { || F460ATime() } )

Return oView

//-------------------------------------------------------------------
/* {Protheus.doc} F460BCpoFO1

Função criar um campo virtual para montagem da grid de seleção dos títulos

@author	Pâmela Bernardo
@since		15/10/2015
@Version	V12.1.8
@Project 	P12
@aparam  	nTipo, indica se é 1 = model ou 2 = view 
@Return		
*/
//-------------------------------------------------------------------

Static Function F460BCpoFO1(nTipo) 
	Local oStruFO1 := FWFormStruct( nTipo,"FO1")
	Local lMostraMark	:= (FwIsInCallStack("F460AIncl") .Or. FwIsInCallStack("A460Liquid"))
	
	Default nTipo := 1 

	If nTipo == 1

		oStruFO1:AddField( ""					,"","FO1_MARK"		,"L", 1						,0,,,,.F.,,,,.T.)
		oStruFO1:AddField(OemToAnsi(STR0018)	,"","FO1_PREFIX"	,"C",TamSX3("E1_PREFIXO")[1],0,,,,.F.,,,,.T.)//"Prefixo"
		oStruFO1:AddField(OemToAnsi(STR0019)	,"","FO1_NUM"		,"C",TamSX3("E1_NUM")[1]	,0,,,,.F.,,,,.T.)//"Número"
		oStruFO1:AddField(OemToAnsi(STR0020)	,"","FO1_PARCEL"	,"C",TamSX3("E1_PARCELA")[1],0,,,,.F.,,,,.T.)//"Parcela"
		oStruFO1:AddField(OemToAnsi(STR0021)	,"","FO1_TIPO"		,"C",TamSX3("E1_TIPO")[1]	,0,,,,.F.,,,,.T.)//"Tipo"
		oStruFO1:AddField(OemToAnsi(STR0022)	,"","FO1_NATURE"	,"C",TamSX3("E1_NATUREZ")[1],0,,,,.F.,,,,.T.)//"Natureza"
		oStruFO1:AddField(OemToAnsi(STR0023)	,"","FO1_CLIENT"	,"C",TamSX3("E1_CLIENTE")[1],0,,,,.F.,,,,.T.)//"Cliente"
		oStruFO1:AddField(OemToAnsi(STR0024)	,"","FO1_LOJA"		,"C",TamSX3("E1_LOJA")[1]	,0,,,,.F.,,,,.T.)//"Loja"
		oStruFO1:AddField(OemToAnsi(STR0025)	,"","FO1_EMIS"		,"D",TamSX3("E1_EMISSAO")[1],0,,,,.F.,,,,.T.)//"Emissão"
		oStruFO1:AddField(OemToAnsi(STR0026)	,"","FO1_VENCTO"	,"D",TamSX3("E1_VENCTO")[1]	,0,,,,.F.,,,,.T.)//"Vencimento"
		oStruFO1:AddField(OemToAnsi(STR0097)	,"","FO1_VENCRE"	,"D",TamSX3("E1_VENCREA")[1],0,,,,.F.,,,,.T.)//"Vencimento Real"
		oStruFO1:AddField(OemToAnsi(STR0027)	,"","FO1_BAIXA"		,"D",TamSX3("E1_BAIXA")[1]	,0,,,,.F.,,,,.T.)//"Ult Baixa"
		oStruFO1:AddField(OemToAnsi(STR0028)	,"","FO1_VLBAIX"	,"N",TamSX3("E1_VALOR")[1]	,2,,,,.F.,,,,.T.)//"Valor de baixa"
		oStruFO1:AddField(OemToAnsi(STR0029)	,"","FO1_VALCVT"	,"N",TamSX3("E1_VALOR")[1]	,2,,,,.F.,,,,.T.)//"Vlr Convertido"
		oStruFO1:AddField(OemToAnsi(STR0030)	,"","FO1_HIST"		,"C",TamSX3("E1_HIST")[1]	,0,,,,.F.,,,,.T.)//"Histórico"
		
		oStruFO1:AddField(OemToAnsi(STR0030)	,"","FO1_CCUST"     ,"C",TamSX3("E1_CCUSTO")[1] ,0,,,,.F.,,,,.T.)//Centro de Custo
		oStruFO1:AddField(OemToAnsi(STR0030)	,"","FO1_ITEMCT"    ,"C",TamSX3("E1_ITEMCTA")[1],0,,,,.F.,,,,.T.)//ITEM DA CONTA
		oStruFO1:AddField(OemToAnsi(STR0030)	,"","FO1_CLVL"      ,"C",TamSX3("E1_CLVL")[1]   ,0,,,,.F.,,,,.T.)//Classe de Valor
		
		If X3USO(GetSx3Cache( "E1_CREDIT", "X3_USADO" ) )
			oStruFO1:AddField(OemToAnsi(STR0030)	,"","FO1_CREDIT"      ,"C",TamSX3("E1_CREDIT")[1]   ,0,,,,.F.,,,,.T.)//Conta Credito
		Endif

		If X3USO(GetSx3Cache( "E1_DEBITO", "X3_USADO" ))
			oStruFO1:AddField(OemToAnsi(STR0030)	,"","FO1_DEBITO"      ,"C",TamSX3("E1_DEBITO")[1]   ,0,,,,.F.,,,,.T.)//Conta Debito
		Endif
							
	Else 

		If lMostraMark
			oStruFO1:AddField("FO1_MARK"	, "01",""					,"",{},"L",""		)
		Endif
		oStruFO1:AddField("FO1_PREFIX"	, "03",OemToAnsi(STR0018)		,"",{},"C","@!"	)
		oStruFO1:AddField("FO1_NUM"		, "04",OemToAnsi(STR0019)		,"",{},"C","@!"	)
		oStruFO1:AddField("FO1_PARCEL"	, "05",OemToAnsi(STR0020)		,"",{},"C","@!"	)
		oStruFO1:AddField("FO1_TIPO"	, "06",OemToAnsi(STR0021)		,"",{},"C","@!"	)
		oStruFO1:AddField("FO1_NATURE"	, "07",OemToAnsi(STR0022)		,"",{},"C","@!"	)
		oStruFO1:AddField("FO1_CLIENT"	, "08",OemToAnsi(STR0023)		,"",{},"C","@!"	)
		oStruFO1:AddField("FO1_LOJA"	, "09",OemToAnsi(STR0024)		,"",{},"C","@!"	)
		oStruFO1:AddField("FO1_EMIS"	, "10",OemToAnsi(STR0025)		,"",{},"D",""	)
		oStruFO1:AddField("FO1_VENCTO"	, "11",OemToAnsi(STR0026)		,"",{},"D",""	)
		oStruFO1:AddField("FO1_VENCRE"	, "12",OemToAnsi(STR0097)		,"",{},"D",""	)
		oStruFO1:AddField("FO1_BAIXA"	, "16",OemToAnsi(STR0027)		,"",{},"D",""	)
		oStruFO1:AddField("FO1_VLBAIX"	, "17",OemToAnsi(STR0028)		,"",{},"N",PesqPict("SE1", "E1_VALOR"))
		oStruFO1:AddField("FO1_VALCVT"	, "18",OemToAnsi(STR0029)		,"",{},"N",PesqPict("SE1", "E1_VALOR"))
		oStruFO1:AddField("FO1_CCUST" 	, "29",OemToAnsi(STR0165)       ,"",{},"C","@!" )
		oStruFO1:AddField("FO1_ITEMCT"	, "30",OemToAnsi(STR0166)       ,"",{},"C","@!" )
		oStruFO1:AddField("FO1_CLVL"	, "31",OemToAnsi(STR0167)       ,"",{},"C","@!" )
		
		If X3USO(GetSx3Cache( "E1_CREDIT", "X3_USADO" ) )
			oStruFO1:AddField("FO1_CREDIT"	, "33",OemToAnsi(STR0171)      ,"",{},"C","@!" )
		Endif

		If X3USO(GetSx3Cache( "E1_DEBITO", "X3_USADO" ))
			oStruFO1:AddField("FO1_DEBITO"	, "32",OemToAnsi(STR0170)       ,"",{},"C","@!" )	
		Endif

		oStruFO1:AddField("FO1_HIST"	, "34",OemToAnsi(STR0030)		,"",{},"C","@!"	)
		
		oStruFO1:SetProperty( 'FO1_FILORI'	, MVC_VIEW_ORDEM,	'02')
		oStruFO1:SetProperty( 'FO1_MOEDA'	, MVC_VIEW_ORDEM,	'13')
		oStruFO1:SetProperty( 'FO1_TXMOED'	, MVC_VIEW_ORDEM,	'14')
		oStruFO1:SetProperty( 'FO1_SALDO'	, MVC_VIEW_ORDEM,	'15')
		oStruFO1:SetProperty( 'FO1_TXJUR'	, MVC_VIEW_ORDEM,	'19')
		oStruFO1:SetProperty( 'FO1_VLDIA'	, MVC_VIEW_ORDEM,	'20')
		oStruFO1:SetProperty( 'FO1_VLJUR'	, MVC_VIEW_ORDEM,	'21')
		oStruFO1:SetProperty( 'FO1_TXMUL'	, MVC_VIEW_ORDEM,	'22')
		oStruFO1:SetProperty( 'FO1_VLMUL'	, MVC_VIEW_ORDEM,	'23')
		oStruFO1:SetProperty( 'FO1_DESCON'	, MVC_VIEW_ORDEM,	'24')
		oStruFO1:SetProperty( 'FO1_VLABT'	, MVC_VIEW_ORDEM,	'25')
		oStruFO1:SetProperty( 'FO1_ACRESC'	, MVC_VIEW_ORDEM,	'26')
		oStruFO1:SetProperty( 'FO1_DECRES'	, MVC_VIEW_ORDEM,	'27')
		oStruFO1:SetProperty( 'FO1_TOTAL'	, MVC_VIEW_ORDEM,	'28')

	Endif

 Return oStruFO1