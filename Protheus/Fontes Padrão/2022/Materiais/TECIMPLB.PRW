#INCLUDE "TECIMPLB.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TopConn.ch" 
#INCLUDE 'protheus.ch'

#DEFINE DEF_TITULO_DO_CAMPO		01	//Titulo do campo
#DEFINE DEF_TOOLTIP_DO_CAMPO	02	//ToolTip do campo
#DEFINE DEF_IDENTIFICADOR		03	//identificador (ID) do Field
#DEFINE DEF_TIPO_DO_CAMPO		04	//Tipo do campo
#DEFINE DEF_TAMANHO_DO_CAMPO	05	//Tamanho do campo
#DEFINE DEF_DECIMAL_DO_CAMPO	06	//Decimal do campo
#DEFINE DEF_CODEBLOCK_VALID		07	//Code-block de validação do campo
#DEFINE DEF_CODEBLOCK_WHEN		08	//Code-block de validação When do campo
#DEFINE DEF_LISTA_VAL			09	//Lista de valores permitido do campo
#DEFINE DEF_OBRIGAT				10	//Indica se o campo tem preenchimento obrigatório
#DEFINE DEF_CODEBLOCK_INIT		11	//Code-block de inicializacao do campo
#DEFINE DEF_CAMPO_CHAVE			12	//Indica se trata de um campo chave
#DEFINE DEF_RECEBE_VAL			13	//Indica se o campo pode receber valor em uma operação de update.
#DEFINE DEF_VIRTUAL				14	//Indica se o campo é virtual
#DEFINE DEF_VALID_USER			15	//Valid do usuario

#DEFINE DEF_ORDEM				16	//Ordem do campo
#DEFINE DEF_HELP				17	//Array com o Help dos campos
#DEFINE DEF_PICTURE				18	//Picture do campo
#DEFINE DEF_PICT_VAR			19	//Bloco de picture Var
#DEFINE DEF_LOOKUP				20	//Chave para ser usado no LooKUp
#DEFINE DEF_CAN_CHANGE			21	//Logico dizendo se o campo pode ser alterado
#DEFINE DEF_ID_FOLDER			22	//Id da Folder onde o field esta
#DEFINE DEF_ID_GROUP			23	//Id do Group onde o field esta
#DEFINE DEF_COMBO_VAL			24	//Array com os Valores do combo
#DEFINE DEF_TAM_MAX_COMBO		25	//Tamanho maximo da maior opção do combo
#DEFINE DEF_INIC_BROWSE			26	//Inicializador do Browse
#DEFINE DEF_PICTURE_VARIAVEL	27	//Picture variavel
#DEFINE DEF_INSERT_LINE			28	//Se verdadeiro, indica pulo de linha após o campo
#DEFINE DEF_WIDTH				29	//Largura fixa da apresentação do campo
#DEFINE DEF_TIPO_CAMPO_VIEW		30	//Tipo do campo

#DEFINE QUANTIDADE_DEFS			30	//Quantidade de DEFs

Static lOrcamento	:= .F.
Static lContrato	:= .F.
Static lOperacional	:= .F.
Static lArmamentos	:= .F.
Static lParametro	:= .T.
Static lOrcPrec		:= .F.
Static lContrat		:= .F.
Static lOperaci		:= .F.
Static lArmamen		:= .F.
Static aParImpl		:= CargaParIm()

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA190G - Mesa Operacional - Alocação Por Horas
 	ModelDef
 		Definição do modelo de Dados

@author	Augusto Albuquerque
@since	03/04/2020
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	
Local oStrAA1	:= FWFormModelStruct():New()
Local aFields	:= {}
Local nX		:= 0
Local nY		:= 0
Local aTables 	:= {}
Local bCommit	:= { |oModel| .T. }
Local bValid := { |oModel| .T. }

oStrAA1:AddTable("   ",{}, STR0001) //"Parametrização"

AADD(aTables, {oStrAA1, "AA1"})

For nY := 1 To LEN(aTables)
	aFields := TecImplBDe(aTables[nY][2])

	For nX := 1 TO LEN(aFields)
		aTables[nY][1]:AddField(aFields[nX][DEF_TITULO_DO_CAMPO],;
						aFields[nX][DEF_TOOLTIP_DO_CAMPO],;
						aFields[nX][DEF_IDENTIFICADOR	],;
						aFields[nX][DEF_TIPO_DO_CAMPO	],;
						aFields[nX][DEF_TAMANHO_DO_CAMPO],;
						aFields[nX][DEF_DECIMAL_DO_CAMPO],;
						aFields[nX][DEF_CODEBLOCK_VALID	],;
						aFields[nX][DEF_CODEBLOCK_WHEN	],;
						aFields[nX][DEF_LISTA_VAL		],;
						aFields[nX][DEF_OBRIGAT			],;
						aFields[nX][DEF_CODEBLOCK_INIT	],;
						aFields[nX][DEF_CAMPO_CHAVE		],;
						aFields[nX][DEF_RECEBE_VAL		],;
						aFields[nX][DEF_VIRTUAL			],;
						aFields[nX][DEF_VALID_USER		])
	Next nX
Next nY

oModel := MPFormModel():New('TECAIMPLAB',/*bPreValidacao*/, bValid, bCommit,/*bCancel*/)
oModel:SetDescription( STR0001 ) //"Parametrização" 

oModel:addFields('AA1MASTER',,oStrAA1)
oModel:SetPrimaryKey({"AA1_DOCUME"})

oModel:GetModel('AA1MASTER'):SetDescription(STR0001)	//"Parametrização"

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da interface

@author	Augusto Albuquerque
@since 03/04/2020
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel := ModelDef()
Local oView
Local aTables 	:= {}
Local oStrAA1	:= FWFormViewStruct():New()
Local nX
Local nY
Local lMonitor	:= IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366

AADD(aTables, {oStrAA1, "AA1"})

For nY := 1 to LEN(aTables)
	
	aFields := TecImplBDe(aTables[nY][2])

	For nX := 1 to LEN(aFields)
		aTables[nY][1]:AddField(aFields[nX][DEF_IDENTIFICADOR],;
						aFields[nX][DEF_ORDEM],;
						aFields[nX][DEF_TITULO_DO_CAMPO],;
						aFields[nX][DEF_TOOLTIP_DO_CAMPO],;
						aFields[nX][DEF_HELP],;
						aFields[nX][DEF_TIPO_CAMPO_VIEW],;
						aFields[nX][DEF_PICTURE],;
						aFields[nX][DEF_PICT_VAR],;
						aFields[nX][DEF_LOOKUP],;
						aFields[nX][DEF_CAN_CHANGE],;
						aFields[nX][DEF_ID_FOLDER],;
						aFields[nX][DEF_ID_GROUP],;
						aFields[nX][DEF_COMBO_VAL],;
						aFields[nX][DEF_TAM_MAX_COMBO],;
						aFields[nX][DEF_INIC_BROWSE],;
						aFields[nX][DEF_VIRTUAL],;
						aFields[nX][DEF_PICTURE_VARIAVEL],;
						aFields[nX][DEF_INSERT_LINE],;
						aFields[nX][DEF_WIDTH])
	Next nX
Next nY

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_MASTER', oStrAA1, 'AA1MASTER')

oView:CreateHorizontalBox( 'REALOC_AA1', 00.01 )

oView:CreateHorizontalBox( 'ID_ABA01_SELECT', 99.99 )

If lOrcamento
	oView:AddOtherObject("MANUT_REL",{|oPanel| OpcOrcament(oPanel) })
	oView:SetOwnerView("MANUT_REL","ID_ABA01_SELECT")
ElseIf lContrato
	oView:AddOtherObject("MANUT_REL",{|oPanel| OpcContrat(oPanel) })
	oView:SetOwnerView("MANUT_REL","ID_ABA01_SELECT")
ElseIf lOperacional
	oView:AddOtherObject("MANUT_REL",{|oPanel| OpcOperaci(oPanel) })
	oView:SetOwnerView("MANUT_REL","ID_ABA01_SELECT")
ElseIf lArmamentos
	oView:AddOtherObject("MANUT_REL",{|oPanel| OpcArmamen(oPanel) })
	oView:SetOwnerView("MANUT_REL","ID_ABA01_SELECT")
ElseIf lParametro
	oView:AddOtherObject("MANUT_REL",{|oPanel| OpcDefini(oPanel) })
	oView:SetOwnerView("MANUT_REL","ID_ABA01_SELECT")
EndIf

oView:SetOwnerView('VIEW_MASTER','REALOC_AA1')

oView:SetDescription(STR0001) //"Parametrização"

Return oView

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecImplDef
@description Criação dos campos
@return aRet
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TecImplBDe(cTable)
Local aRet		:= {}
Local nAux 		:= 0 

If cTable == "AA1"

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := "Documentação"	//"Tipo"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := "Documentação"	//"Tipo"
	aRet[nAux][DEF_IDENTIFICADOR] := "AA1_DOCUME"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 20
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "PARAMETRIZAÇÃO" }
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T.}
	aRet[nAux][DEF_HELP] := {"Configura o orçamento "}	//"Tipo de dia: Trabalhado, não trabalhado, folga ou DSR."

EndIf

Return (aRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetFilCont
@description Manipulação das Variaveis static
@author Augusto Albuquerque
@since  06/05/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function SetFilCont( nStatic, lValor, lLimpa )

Default lLimpa := .F.

If lLimpa
	lOrcamento := .F.
	lContrato := .F.
	lOperacional := .F.
	lArmamentos := .F.
	lParametro	:= .T.
Else
	If nStatic == 1
		lOrcamento := lValor
	ElseIf nStatic == 2
		lContrato := lValor
	ElseIf nStatic == 3
		lOperacional := lValor
	ElseIf nStatic == 4
		lArmamentos := lValor
	ElseIf nStatic == 5
		lParametro	:= lValor
	EndIf
EndIf

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModParamet
@description Manipulação do Array Static
@author Augusto Albuquerque
@since  06/05/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ModParamet( cParamet, xPar, cMsg)
Local nPos := 0

Default cMsg	:= ""
If (nPos := Ascan( aParImpl, { |a| UPPER(a[1]) == UPPER(cParamet)})) > 0
	aParImpl[nPos][2] := xPar
	aParImpl[nPos][3] := .T.
	aParImpl[nPos][4] := cMsg
Else
	AADD(aParImpl, { UPPER(cParamet), xPar, .T., cMsg })
EndIf

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} OpcOrcament
@description Carrega a parte da parametrização do orçamento
@author Augusto Albuquerque
@since  06/05/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static function OpcOrcament(oPanel)
Local aItems 	:= {}
Local aItems1 	:= {}
Local aItems2 	:= {}
Local nRadio 	:= 0
Local nRadio2 	:= 0
Local nRadio1 	:= 0
Local oFont		:= Nil
Local oSay		:= Nil
Local oSay1		:= Nil
Local oSay2		:= Nil
Local oRadio	:= Nil
Local oRadio1	:= Nil
Local oRadio2	:= Nil
Local lMonitor	:= IsBlind() .OR. ((GetScreenRes()[2] <= 1000) .AND. (GetScreenRes()[1] <= 1500)) //786 x 1366

oFont := TFont():New('Arial',,-15,.T.,)

nRadio := IIf(SuperGetMv("MV_ORCPRC",,.T.), 1, 2 )
aItems := {STR0002, STR0003} // 'Orçamento com Tabela de Precificação' ## 'Orçamento com Planilha de Preço (Recomendado)'
oSay:= TSay():Create(oPanel,{||STR0004},01,IIF(lMonitor, 150, 61),,oFont,,,,.T.,,,900,200) // 'Utiliza qual modelo de precificação?'
oRadio := TRadMenu():New (11,IIF(lMonitor, 150, 61),aItems,,oPanel,,,,,,,,300,12,,,,.T., .T.)
oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}
oRadio:bChange := {|| ModParamet("MV_ORCPRC", IIF( nRadio == 1, .T., .F.), IIF( nRadio == 1, STR0005, STR0006))} // "Tabela de Precificação (.T.)" ## "Planilha de Preço (.F.)"

nRadio1 := IIf(SuperGetMV("MV_ORCSIMP",,'2') == '2', 1, 2 )
aItems1 := {STR0007,STR0008} // 'Integrado ao CRM' ## 'Orçamento Simplificado (Recomendado)'
oSay1 := TSay():Create(oPanel,{||STR0009},31,IIF(lMonitor, 150, 61),,oFont,,,,.T.,,,900,200) //'Utiliza a integração do Orçamento de Serviços com o CRM?'
oRadio1 := TRadMenu():New (41,IIF(lMonitor, 150, 61),aItems1,,oPanel,,,,,,,,300,12,,,,.T., .T.)
oRadio1:bSetGet := {|u|Iif (PCount()==0,nRadio1,nRadio1:=u)}
oRadio1:bChange := {|| ModParamet("MV_ORCSIMP", IIF( nRadio1 == 1, '2', '1'), IIF( nRadio1 == 1, STR0010, STR0011))} //"Integrado ao CRM (2)" ## "Orçamento Simplificado(1)"

nRadio2 := IIf(SuperGetMv("MV_GSLE",,.T.), 1, 2 )
aItems2 := {STR0012,STR0013} //'Sim' ## 'Não (Recomendado)'
oSay2 := TSay():Create(oPanel,{||STR0014},61,IIF(lMonitor, 150, 61),,oFont,,,,.T.,,,900,200) //'Utiliza Locação de Equipamentos?'
oRadio2 := TRadMenu():New (71,IIF(lMonitor, 150, 61),aItems2,,oPanel,,,,,,,,300,12,,,,.T., .T.)
oRadio2:bSetGet := {|u|Iif (PCount()==0,nRadio2,nRadio2:=u)}
oRadio2:bChange := {|| ModParamet("MV_GSLE", IIF( nRadio2 == 1, .T., .F.), IIF( nRadio2 == 1, STR0015, STR0016))} // "Utilizara a Locação de Equipamentos (.T.)" ## "Não Utilizara a Locação de Equipamentos (.F.)"

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} OpcContrat
@description Carrega a parte da parametrização do contrato e preficicação
@author Augusto Albuquerque
@since  06/05/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function OpcContrat(oPanel)
Local aItems 	:= {}
Local aItems1 	:= {}
Local aItems2 	:= {}
Local lMonitor	:= IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366
Local nRadio 	:= 0
Local nRadio2 	:= 0
Local nRadio1 	:= 0
Local oFont		:= Nil
Local oSay		:= Nil
Local oSay1		:= Nil
Local oSay2		:= Nil
Local oRadio	:= Nil
Local oRadio1	:= Nil
Local oRadio2	:= Nil

oFont := TFont():New('Arial',,-15,.T.,)

nRadio := IIf(SuperGetMV("MV_GSDSGCN",,'2') == '2', 1, 2 )
aItems := {STR0017, STR0018} //'Itens Desagrupados (Recomendado)' ## 'Itens Agrupados'
oSay := TSay():Create(oPanel,{||STR0019},11,IIF(lMonitor, 150, 61),,oFont,,,,.T.,,,900,200) //'Utiliza qual modelo de Faturamento ?'
oRadio := TRadMenu():New (21,IIF(lMonitor, 150, 61),aItems,,oPanel,,,,,,,,300,12,,,,.T., .T.)
oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}
oRadio:bChange := {|| ModParamet("MV_GSDSGCN", IIF( nRadio == 1, '2', '1'), IIF( nRadio == 1, STR0020, STR0021))} // "Orçamento com Itens Agrupados na Nota (2)" ## "Orçamento com Itens Desagrupados na Nota (1)"

nRadio1 := IIf(SuperGetMV("MV_GSISS",, .F.), 1, 2 )
aItems1 := {STR0012, STR0013}// 'Sim' ## 'Não (Recomendado)'
oSay1 := TSay():Create(oPanel,{||STR0022},41,IIF(lMonitor, 150, 61),,oFont,,,,.T.,,,900,200) // 'Utiliza o Agrupamento de Produto de Serviço e Pedido de Venda ?'
oRadio1 := TRadMenu():New (51,IIF(lMonitor, 150, 61),aItems1,,oPanel,,,,,,,,300,12,,,,.T., .T.)
oRadio1:bSetGet := {|u|Iif (PCount()==0,nRadio1,nRadio1:=u)}
oRadio1:bChange := {|| ModParamet("MV_GSISS", IIF( nRadio1 == 1, .T., .F.), IIF( nRadio1 == 1, STR0023, STR0024))} //"Utiliza Agrupamento de Porduto de Serviço e Pedido de Venda  (.T.)" ## "Não Utiliza Agrupamento de Porduto de Serviço e Pedido de Venda  (.F.)"

nRadio2 := 1
aItems2 := {STR0025,STR0012} // 'Não' ## 'Sim'
oSay2 := TSay():Create(oPanel,{||STR0026},71,IIF(lMonitor, 150, 61),,oFont,,,,.T.,,,900,200) // 'Utiliza Contrato Recorrente?'
oRadio2 := TRadMenu():New (81,IIF(lMonitor, 150, 61),aItems2,,oPanel,,,,,,,,300,12,,,,.T., .T.)
oRadio2:bSetGet := {|u|Iif (PCount()==0,nRadio2,nRadio2:=u)}
oRadio2:bChange := {|| ModParamet("Recorrente", IIF( nRadio2 == 2, .T., .F.), IIF( nRadio2 == 2, STR0027, STR0028))} // "Utiliza Contrato Recorrente" ## "Não Utiliza Contrato Recorrente"

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} OpcOperaci
@description Carrega a parte da parametrização do operacional
@author Augusto Albuquerque
@since  06/05/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function OpcOperaci(oPanel)
Local aItems	:= {}
Local aItems1	:= {}
Local aItems2	:= {}
Local aItems3	:= {}
Local aItems4	:= {}
Local aItems5	:= {}
Local aItems6	:= {}
Local aItems7	:= {}
Local aItems8	:= {}
Local lMonitor	:= IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366
Local nRadio := 0
Local nRadio2 := 0
Local nRadio1 := 0
Local nRadio3 := 0
Local nRadio4 := 0
Local nRadio5 := 0
Local nRadio6 := 0
Local nRadio7 := 0
Local nRadio8 := 0
Local oFont 	:= Nil
Local oSay		:= Nil
Local oSay1		:= Nil
Local oSay2		:= Nil
Local oSay3		:= Nil
Local oSay4		:= Nil
Local oSay5		:= Nil
Local oSay6		:= Nil
Local oSay7		:= Nil
Local oSay8		:= Nil
Local oRadio	:= Nil
Local oRadio1 	:= Nil
Local oRadio2 	:= Nil
Local oRadio3 	:= Nil
Local oRadio4 	:= Nil
Local oRadio5 	:= Nil
Local oRadio6 	:= Nil
Local oRadio7 	:= Nil
Local oRadio8 	:= Nil


oFont := TFont():New('Arial',,-15,.T.,)

nRadio := IIf(SuperGetMV("MV_GSGEHOR",,.F.), 2, 1 )
aItems := {STR0025, STR0029} // 'Não' ## 'Sim (Recomendado)'
oSay := TSay():Create(oPanel,{||STR0030},11,IIF(lMonitor, 150, 61),,oFont,,,,.T.,,,900,200) // 'Utiliza Flexibilização de Horário ?'
oRadio := TRadMenu():New (21,IIF(lMonitor, 150, 61),aItems,,oPanel,,,,,,,,300,12,,,,.T., .T.)
oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}
oRadio:bChange := {|| ModParamet("MV_GSGEHOR", IIF( nRadio == 2, .T., .F.), IIF( nRadio == 1, STR0031, STR0032))} // "Não Utiliza flexibilização de Horario (.F.)" ## "Utiliza flexibilização de Horario (.T.)"

nRadio1 := IIf(SuperGetMV("MV_TECXRH",, .T.), 2, 1 )
aItems1 := {STR0025, STR0029} //'Não' ## 'Sim (Recomendado)'
oSay1 := TSay():Create(oPanel,{||STR0033},31,IIF(lMonitor, 150, 61),,oFont,,,,.T.,,,900,200) // 'Utiliza Integração com o RH Protheus?'
oRadio1 := TRadMenu():New (41,IIF(lMonitor, 150, 61),aItems1,,oPanel,,,,,,,,300,12,,,,.T., .T.)
oRadio1:bSetGet := {|u|Iif (PCount()==0,nRadio1,nRadio1:=u)}
oRadio1:bChange := {|| ModParamet("MV_TECXRH", IIF( nRadio1 == 2, .T., .F.), IIF( nRadio1 == 1, STR0034, STR0035))} // "Não Integrara com RH (.F.)" ## "Integração com RH (.T.)"

nRadio2 := IIf(SuperGetMV("MV_GSVERHR",, .F.), 2, 1 )
aItems2 := {STR0036,STR0037} // 'Verifica o dia trabalhado' ## 'Verifica horario e dia trabalhado (Recomendado)'
oSay2 := TSay():Create(oPanel,{||STR0038},51,IIF(lMonitor, 150, 61),,oFont,,,,.T.,,,900,200) // 'Utiliza qual criterio de conflito de agenda ?'
oRadio2 := TRadMenu():New (61,IIF(lMonitor, 150, 61),aItems2,,oPanel,,,,,,,,300,12,,,,.T., .T.)
oRadio2:bSetGet := {|u|Iif (PCount()==0,nRadio2,nRadio2:=u)}
oRadio2:bChange := {|| ModParamet("MV_GSVERHR", IIF( nRadio2 == 2, .T., .F.), IIF( nRadio2 == 1, STR0039, STR0040))} // "Verifica apenas o dia trabalhado (.F.)" ## "Verifica horario trabalhado + dia trabalhado (.T.)"

nRadio3 := IIf(SuperGetMV("MV_GSMSFIL",, .F.), 2, 1 )
aItems3 := {STR0025,STR0029} // 'Não' ## 'Sim (Recomendado)'
oSay3 := TSay():Create(oPanel,{||STR0041},71,IIF(lMonitor, 150, 61),,oFont,,,,.T.,,,900,200) // 'Utiliza a mesa em modo Multifilial?'
oRadio3 := TRadMenu():New (81,IIF(lMonitor, 150, 61),aItems3,,oPanel,,,,,,,,300,12,,,,.T., .T.)
oRadio3:bSetGet := {|u|Iif (PCount()==0,nRadio3,nRadio3:=u)}
oRadio3:bChange := {|| ModParamet("MV_GSMSFIL", IIF( nRadio3 == 2, .T., .F.), IIF( nRadio3 == 1, STR0042, STR0043))} // "Utilização da Mesa em modo normal (.F.)" ## "Utilização da Mesa em modo Multifilial (.T.)"

nRadio4 := IIf(SuperGetMV("MV_GSPNMTA",, .F.), 2, 1 )
aItems4 := {STR0044,STR0045} // 'Projeção de agendas customizadas - ponto de entrada' ## 'Projeção Padrão (Recomendado)'
oSay4 := TSay():Create(oPanel,{||STR0046},91,IIF(lMonitor, 150, 61),,oFont,,,,.T.,,,900,200) // 'Utiliza a projeção de agendas customizada?'
oRadio4 := TRadMenu():New (101,IIF(lMonitor, 150, 61),aItems4,,oPanel,,,,,,,,300,12,,,,.T., .T.)
oRadio4:bSetGet := {|u|Iif (PCount()==0,nRadio4,nRadio4:=u)}
oRadio4:bChange := {|| ModParamet("MV_GSPNMTA", IIF( nRadio4 == 2, .T., .F.), IIF( nRadio4 == 1, STR0047, STR0048))}// "Projeção de agendas customizadas - ponto de entrada (.F.)" ## "Projeção Padrão (.T.)"

nRadio5 := IIf(SuperGetMV("MV_GSHRPON",, '2') == '2', 1, 2 )
aItems5 := {STR0025,STR0012} // 'Não' ## 'Sim'
oSay5 := TSay():Create(oPanel,{||STR0049},111,IIF(lMonitor, 150, 61),,oFont,,,,.T.,,,900,200) // 'Utiliza a Integração com APP Meu Posto?'
oRadio5 := TRadMenu():New (121,IIF(lMonitor, 150, 61),aItems5,,oPanel,,,,,,,,300,12,,,,.T., .T.)
oRadio5:bSetGet := {|u|Iif (PCount()==0,nRadio5,nRadio5:=u)}
oRadio5:bChange := {|| ModParamet("MV_GSHRPON", IIF( nRadio5 == 1, '2', '1'), IIF( nRadio5 == 1, STR0050, STR0051))} // "Não Utiliza a integração com APPS (.F.)" ## "Utiliza a integração com APPS (.T.)"

nRadio6 := IIf(SuperGetMV("MV_BENEXGS",, .T.), 2, 1 )
aItems6 := {STR0025,STR0029} // 'Não' ## 'Sim (Recomendado)'
oSay6 := TSay():Create(oPanel,{||STR0052},131,IIF(lMonitor, 150, 61),,oFont,,,,.T.,,,900,200) // 'Utiliza o calculo retroativo de beneficios integrado com o GS?'
oRadio6 := TRadMenu():New (141,IIF(lMonitor, 150, 61),aItems6,,oPanel,,,,,,,,300,12,,,,.T., .T.)
oRadio6:bSetGet := {|u|Iif (PCount()==0,nRadio6,nRadio6:=u)}
oRadio6:bChange := {|| ModParamet("MV_BENEXGS", IIF( nRadio6 == 2, .T., .F.), IIF( nRadio6 == 1, STR0053, STR0054))} // "Não utiliza calculo retroativo nos beneficio (.F.)" ## "utiliza calculo retroativo nos beneficio (.T.)"

nRadio7 := IIf(SuperGetMV("MV_GSBENAG",, .F.), 1, 2 )
aItems7 := {STR0012,STR0013} // 'Sim' ## 'Não (Recomendado)'
oSay7 := TSay():Create(oPanel,{||STR0055},151,IIF(lMonitor, 150, 61),,oFont,,,,.T.,,,900,200) // 'Verifica agenda para Calcular Beneficios?'
oRadio7 := TRadMenu():New (161,IIF(lMonitor, 150, 61),aItems7,,oPanel,,,,,,,,300,12,,,,.T., .T.)
oRadio7:bSetGet := {|u|Iif (PCount()==0,nRadio7,nRadio7:=u)}
oRadio7:bChange := {|| ModParamet("MV_GSBENAG", IIF( nRadio7 == 1, .T., .F.), IIF( nRadio7 == 1, STR0056, STR0057))} // "Verifica agenda para o calculo de beneficios (.T.)" ## "Não Verifica agenda para o calculo de beneficios (.T.)"

nRadio8 := IIF(SuperGetMv("MV_NG2GS",.F.,.F.), 2, 1)
aItems8 := {STR0025, STR0012} // 'Não' ##  'Sim'
oSay8 := TSay():Create(oPanel,{||STR0058},171,IIF(lMonitor, 150, 61),,oFont,,,,.T.,,,900,200) // 'Utiliza Integração com Medicina do trabalho?'
oRadio8 := TRadMenu():New (181,IIF(lMonitor, 150, 61),aItems8,,oPanel,,,,,,,,300,12,,,,.T., .T.)
oRadio8:bSetGet := {|u|Iif (PCount()==0,nRadio8,nRadio8:=u)}
oRadio8:bChange := {|| ModParamet("MV_NG2GS", IIF( nRadio8 == 2, .T., .F.), IIF( nRadio8 == 1, STR0059, STR0060))} // "Não Utiliza Integração com MDT (.F.)" ## "Utiliza Integração com MDT (.T.)"

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} OpcArmamen
@description Carrega a parte da parametrização do armamento
@author Augusto Albuquerque
@since  06/05/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function OpcArmamen(oPanel)
Local aItems	:= {}
Local aItems2	:= {}
Local lMonitor	:= IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366
Local nRadio	:= 0
Local nRadio1	:= 0
Local oFont 	:= Nil
Local oSay		:= Nil
Local oSay2		:= Nil
Local oRadio2 	:= Nil
Local oRadio 	:= Nil

oFont := TFont():New('Arial',,-15,.T.,)

nRadio := 1
aItems := {STR0025, STR0012} // 'Não' ## 'Sim'
oSay := TSay():Create(oPanel,{||STR0061},11,IIF(lMonitor, 150, 61),,oFont,,,,.T.,,,900,200) // 'Utiliza Armamento Multifilial?'
oRadio := TRadMenu():New (21,IIF(lMonitor, 150, 61),aItems,,oPanel,,,,,,,,300,12,,,,.T., .T.)
oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}
oRadio:bChange := {|| ModParamet("Armamento", IIF( nRadio == 2, .T., .F.), IIF( nRadio == 1, STR0062, STR0063))} // "Armamento normal" ## "Armamento MultiFilial"

nRadio1 := IIF(SuperGetMV("MV_GSXNFE",,.F.), 2, 1)
aItems2 := {STR0025, STR0012} // 'Não' ## 'Sim'
oSay2 := TSay():Create(oPanel,{||STR0064},41,IIF(lMonitor, 150, 61),,oFont,,,,.T.,,,900,200) // 'Utiliza a inclusão de NFe de Entrada Cadastra Armamentos Automaticamente ?'
oRadio2 := TRadMenu():New (51,IIF(lMonitor, 150, 61),aItems2,,oPanel,,,,,,,,300,12,,,,.T., .T.)
oRadio2:bSetGet := {|u|Iif (PCount()==0,nRadio1,nRadio1:=u)}
oRadio2:bChange := {|| ModParamet("MV_GSXNFE", IIF( nRadio1 == 2, .T., .F.), IIF( nRadio1 == 1, STR0065, STR0066))} // "Não integra com NFe (.F.)" ## "Integra com NFe (.T.)"

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CargaParIm
@description Carrega o array statico com os parametros para a implantação
@author Augusto Albuquerque
@since  06/05/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function CargaParIm()
Local aRet	:= {}

AADD( aRet, {"MV_ORCPRC", SuperGetMV("MV_ORCPRC",,.T.), .F., "" })
AADD( aRet, {"MV_ORCSIMP", SuperGetMV("MV_ORCSIMP",,'2'), .F., "" })
AADD( aRet, {"MV_GSLE", SuperGetMV("MV_GSLE",,.T.), .F., "" })
AADD( aRet, {"MV_GSDSGCN", SuperGetMV("MV_GSDSGCN",,'2'), .F., "" })
AADD( aRet, {"MV_GSISS", SuperGetMV("MV_GSISS",,.T.), .F., "" })
AADD( aRet, {"Recorrente", .F., .F., "" })
AADD( aRet, {"MV_GSGEHOR", SuperGetMV("MV_GSGEHOR",,.F.), .F., "" })
AADD( aRet, {"MV_TECXRH", SuperGetMV("MV_TECXRH",, .T.), .F., "" })
AADD( aRet, {"MV_GSVERHR", SuperGetMV("MV_GSVERHR",, .F.), .F., "" })
AADD( aRet, {"MV_GSMSFIL", SuperGetMV("MV_GSMSFIL",, .F.), .F., "" })
AADD( aRet, {"MV_GSPNMTA", SuperGetMV("MV_GSPNMTA",, .F.), .F., "" })
AADD( aRet, {"MV_GSHRPON", SuperGetMV("MV_GSHRPON",, '2'), .F., "" })
AADD( aRet, {"MV_BENEXGS", SuperGetMV("MV_BENEXGS",, .T.), .F., "" })
AADD( aRet, {"MV_GSBENAG", SuperGetMV("MV_GSBENAG",, .F.), .F., "" })
AADD( aRet, {"MV_NG2GS", SuperGetMV("MV_NG2GS",, .F.), .F., "" })
AADD( aRet, {"Armamento", .F., .F., "" })
AADD( aRet, {"MV_GSXNFE", SuperGetMV("MV_GSXNFE",,.F.), .F., "" })

Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetParImpl
@description Retorna o Array com as variaveis de implantação
@author Augusto Albuquerque
@since  06/05/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function GetParImpl()
Return aParImpl

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} OpcDefini
@description Carrega a parte da parametrização para definir as implantações
@author Augusto Albuquerque
@since  06/05/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static function OpcDefini(oPanel)
Local oChkFer 	:= Nil
Local oChkFer2 	:= Nil
Local oChkFer3 	:= Nil
Local oChkFer4 	:= Nil
Local oFont		:= Nil
Local oSay		:= Nil

oFont := TFont():New('Arial',,-16)

oChkFer := TCheckBox():New(41,01,STR0067,{||lOrcPrec},oPanel,250,250,,{||lOrcPrec := !lOrcPrec},oFont,,,,,.T.,,,) //"Orçamento e Precificação"
oChkFer2 := TCheckBox():New(58,01,STR0068,{||lContrat},oPanel,250,250,,{||lContrat := !lContrat},oFont,,,,,.T.,,,) // "Contratos"
oChkFer3 := TCheckBox():New(75,01,STR0069,{||lOperaci},oPanel,250,250,,{||lOperaci := !lOperaci},oFont,,,,,.T.,,,) // "Operacional"
oChkFer4 := TCheckBox():New(92,01,STR0070,{||lArmamen},oPanel,250,250,,{||lArmamen := !lArmamen},oFont,,,,,.T.,,,) // "Armamentos"

oFont := TFont():New('Arial',,-17)

oSay:= TSay():Create(oPanel,{||STR0071},01,01,,oFont,,,,.T.,,,800,200) // 'Por favor, selecione as opções que serão configuradas nesta execução do Facilitador de Implantação. '
oSay:= TSay():Create(oPanel,{||STR0072},11,01,,oFont,,,,.T.,,,800,200) // 'Não se preocupe, é possível configurar novamente todas as opções em uma nova execução. '

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetImplaF
@description Retorna um array com as variaveis de implantação a serem utilizadas
@author Augusto Albuquerque
@since  06/05/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function GetImplaF()
Return {lOrcPrec, lContrat, lOperaci, lArmamen}
