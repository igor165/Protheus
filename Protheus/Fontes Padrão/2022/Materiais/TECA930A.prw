#INCLUDE 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "Fileio.ch"
#INCLUDE "SHELL.ch"
#INCLUDE "TECA930A.ch"

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

Static aMarks 		:= {}
Static aCalcIt		:= {}
Static cCompet		:= ""
Static lMostraHelp	:= .T.
Static oMDl930A		:= Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Definição do modelo de Dados

@author	Augusto Albuquerque
@since 19/10/2020
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel	
Local oStrCNT	:= FWFormModelStruct():New()
Local oStrFIL	:= FWFormModelStruct():New()
Local oStrMED	:= FWFormModelStruct():New()
Local oStrTOT	:= FWFormModelStruct():New()
Local bCommit	:= { |oModel| At930ACmt( oModel )}
Local aFields	:= {}
Local nX		:= 0
Local nY		:= 0
Local aTables 	:= {}
Local xAux

oStrCNT:AddTable("   ",{}, STR0001) //"Apuração Agil"

AADD(aTables, {oStrCNT, "CNT"})
AADD(aTables, {oStrFIL, "FIL"})
AADD(aTables, {oStrMED, "MED"})
AADD(aTables, {oStrTOT, "TOT"})

For nY := 1 To LEN(aTables)
	aFields := AT930ADef(aTables[nY][2])

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

aAux := FwStruTrigger("CNT_NUMERO","CNT_NUMERO",'AT930ALiFil({"FIL_CLIENT", "FIL_LOJA", "FIL_ESTADO"})',.F.,Nil,Nil,Nil)
oStrCNT:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("CNT_VALAPUR","CNT_VALAPUR",'AT930ACalc()',.F.,Nil,Nil,Nil)
oStrCNT:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("CNT_NUMERO","CNT_REVISA",'Posicione("CN9",7,xFilial("CN9")+FwFldGet("CNT_NUMERO")+"05","CN9_REVISA")',.F.,Nil,Nil,Nil)
oStrCNT:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("CNT_NUMERO","CNT_COMPET",'AT930AComp()',.F.,Nil,Nil,Nil)
oStrCNT:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("CNT_COMPET","CNT_COMPET",'AT930AClea()',.F.,Nil,Nil,Nil)
oStrCNT:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("FIL_ESTADO","FIL_ESTADO",'AT930AMunc(FwFldGet("FIL_ESTADO"))',.F.,Nil,Nil,Nil)
oStrFIL:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

xAux := FwStruTrigger( 'MED_MARK', 'MED_MARK','At930AChec()', .F. )
oStrMED:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

aAux := FwStruTrigger("MED_CLIENT","MED_DESCLI",'Posicione("SA1",1,xFilial("SA1")+FwFldGet("MED_CLIENT"),"A1_NOME")',.F.,Nil,Nil,Nil)
oStrMED:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("MED_VALAPU","MED_VALAPU",'AT930ACalc( .T. )',.F.,Nil,Nil,Nil)
oStrMED:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

If isInCallStack("AT930View")
	bCommit := { || .T. }
EndIf

oModel := MPFormModel():New('TECA930A',/*bPreValidacao*/,/*bValid*/,bCommit/*bCommit*/,/*bCancel*/)
oModel:SetDescription( STR0001 ) //"Apuração Agil"

oModel:addFields('CNTMASTER',,oStrCNT )
oModel:SetPrimaryKey({"CNT_NUMERO","CNT_REVISA"})

oModel:addFields('FILMASTER','CNTMASTER',oStrFIL)
oModel:addGrid('MEDDETAIL','FILMASTER',oStrMED)
oModel:addFields('TOTMASTER','FILMASTER',oStrTOT)

oModel:GetModel('FILMASTER'):SetOnlyQuery(.T.)
oModel:GetModel('MEDDETAIL'):SetOnlyQuery(.T.)
oModel:GetModel('TOTMASTER'):SetOnlyQuery(.T.)

oModel:GetModel('TOTMASTER'):SetOptional(.T.)
oModel:GetModel('MEDDETAIL'):SetOptional(.T.)
oModel:GetModel('FILMASTER'):SetOptional(.T.)

oModel:GetModel('CNTMASTER'):SetDescription(STR0002)	//"Contrato"
oModel:GetModel('FILMASTER'):SetDescription(STR0003)	//"Filtros"
oModel:GetModel('MEDDETAIL'):SetDescription(STR0004)	//"Dados"
oModel:GetModel('TOTMASTER'):SetDescription(STR0005)	//"Totalizador"

oModel:SetActivate( {|oModel| InitDados( oModel ) } )
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da interface

@author	Augusto Albuquerque
@since 19/10/2020
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrCNT	:= FWFormViewStruct():New()
Local oStrFIL	:= FWFormViewStruct():New()
Local oStrMED	:= FWFormViewStruct():New()
Local oStrTOT	:= FWFormViewStruct():New()
Local aTables 	:= {}
Local aCampos	:= {}
Local lMonitor	:= IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366
Local aTamHoriBox	:= {}
Local aTamBotao	:= {}
Local aFields
Local nX
Local nY

AADD(aTables, {oStrCNT, "CNT"})
AADD(aTables, {oStrFIL, "FIL"})
AADD(aTables, {oStrMED, "MED"})
AADD(aTables, {oStrTOT, "TOT"})

For nY := 1 to LEN(aTables)
	aFields := AT930ADef(aTables[nY][2])

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

oStrMED:RemoveField("MED_CODTFL")

If isInCallStack("AT930View") .OR. isInCallStack("AT930Estor") 
	oStrCNT:RemoveField("CNT_COMPET")
	oStrMED:RemoveField("MED_MARK")
Else
	oStrCNT:RemoveField("CNT_VIEWCOM")
EndIf

oView := FWFormView():New()
oView:SetModel(oModel)

If lMonitor
	oView:SetContinuousForm()

	AADD(aTamHoriBox, 18.00)
	AADD(aTamHoriBox, 22.00)
	AADD(aTamHoriBox, 05.00)
	AADD(aTamHoriBox, 40.00)
	AADD(aTamHoriBox, 12.00)

	AADD(aTamBotao, 08.00)
	AADD(aTamBotao, 08.00)
Else
	AADD(aTamHoriBox, 13.00)
	AADD(aTamHoriBox, 20.00)
	AADD(aTamHoriBox, 05.00)
	AADD(aTamHoriBox, 50.00)
	AADD(aTamHoriBox, 12.00)

	AADD(aTamBotao, 05.00)
	AADD(aTamBotao, 05.00)
EndIf

oView:AddField('VIEW_CONTRA', oStrCNT, 'CNTMASTER')
oView:AddField('VIEW_FILTRO', oStrFIL, 'FILMASTER')
oView:AddGrid('DETAIL_MED', oStrMED, 'MEDDETAIL')
oView:AddField('VIEW_TOTAL', oStrTOT, 'TOTMASTER')

oView:CreateHorizontalBox( 'CONTRATO' , aTamHoriBox[1] )
oView:CreateHorizontalBox( 'FILTRO', aTamHoriBox[2] )
oView:CreateHorizontalBox( 'BOTOES', aTamHoriBox[3] )
oView:CreateHorizontalBox( 'DADOS', aTamHoriBox[4] )
oView:CreateHorizontalBox( 'TOTALIZADOR', aTamHoriBox[5] )

oView:CreateVerticalBox( 'BUSCAR', aTamBotao[1], 'BOTOES' )
oView:CreateVerticalBox( 'MARCA', aTamBotao[2], 'BOTOES' )

oView:AddOtherObject("MARCTDS",{|oPanel| At930ABusc(oPanel) })
oView:SetOwnerView("MARCTDS","MARCA")

oView:AddOtherObject("BUSCAGD",{|oPanel| At930AMarc(oPanel) })
oView:SetOwnerView("BUSCAGD","BUSCAR")

oView:SetOwnerView('VIEW_CONTRA','CONTRATO')
oView:SetOwnerView('VIEW_FILTRO','FILTRO')
oView:SetOwnerView('DETAIL_MED','DADOS')
oView:SetOwnerView('VIEW_TOTAL','TOTALIZADOR')

oView:EnableTitleView('VIEW_CONTRA', STR0002) 		//"Contrato"
oView:EnableTitleView('VIEW_FILTRO', STR0003)		//"Filtros"
oView:EnableTitleView('VIEW_TOTAL', STR0005)		//"Totalizador"

oView:SetDescription(STR0001) // "Apuração Agil"

SetKey( VK_F10, { || At930AF10() })

oView:AddUserButton(STR0048,"",{|oModel| AT930ATrCl(oModel)},,,) //"Troca de Cliente"

Return oView

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados
@description Retorna em forma de Array as definições dos campos
@return 
@author Augusto Albuquerque
@since  19/10/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT930ADef(cTable)
Local aRet		:= {}
Local aCampos	:= Tec930ACam(cTable)
Local aValor	:= {}
Local aAreaSX3	:= {}
Local aQuebra	:= {}
Local nAux 		:= 0
Local nX
Local nI

If cTable == "CNT"

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0002		//"Contrato"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0002		//"Contrato"
	aRet[nAux][DEF_IDENTIFICADOR] := "CNT_NUMERO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("CN9_NUMERO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_OBRIGAT] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_LOOKUP] := "TFJCTR"
	aRet[nAux][DEF_CODEBLOCK_VALID] := {|oMdl,cField,xNewValue| /*Vazio() .AND. ExistCpo("CN9")*/ At930AVldC(oMdl,cField,xNewValue) }
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0006}	// "Numero do Contrato desejavel para a apuração"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0007		//"Revisão"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0007		//"Revisão"
	aRet[nAux][DEF_IDENTIFICADOR] := "CNT_REVISA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("CN9_REVISA")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }	
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( 'CND_COMPET' )	//"Competência"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( 'CND_COMPET' )	//"Competência"
	aRet[nAux][DEF_IDENTIFICADOR] := "CNT_COMPET"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := TamSX3('CND_COMPET')[3]
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := TamSX3('CND_COMPET')[3]
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3('CND_COMPET')[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := TamSX3('CND_COMPET')[2]
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_OBRIGAT] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_COMBO_VAL] := {"",""}
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }	
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0044}	// "Competencia a ser utilizada na apuração."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( 'CND_COMPET' )	//"Competência"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( 'CND_COMPET' )	//"Competência"
	aRet[nAux][DEF_IDENTIFICADOR] := "CNT_VIEWCOM"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := TamSX3('CND_COMPET')[3]
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := TamSX3('CND_COMPET')[3]
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3('CND_COMPET')[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := TamSX3('CND_COMPET')[2]
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }	
	aRet[nAux][DEF_ORDEM] := "04"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .T.

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0009	//"Valor Apurado"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0009	//"Valor Apurado"
	aRet[nAux][DEF_IDENTIFICADOR] := "CNT_VALAPUR"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 16
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 2
	aRet[nAux][DEF_OBRIGAT] := .F.	
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_ORDEM] := "05"
	aRet[nAux][DEF_PICTURE] := "@E 9,999,999,999,999.99                      "
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0010}	//"Valor a ser apurado no contrato"

	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))	

	For nX := 1 To Len(aCampos)
		aAreaSX3  := SX3->(GetArea())
		If SX3->(MSSeek( aCampos[nX] ))
			aQuebra := {}
			aValor := StrTokArr(AllTrim(X3CBox()),';')
			For nI := 1 To Len(aValor)
				If !Empty(aValor[nI])
					AADD(aQuebra, aValor[nI])
				EndIf
			Next nI
			cSeq := StrZero(VAL("05") + nX, 2)
			AADD(aRet, ARRAY(QUANTIDADE_DEFS))
			nAux := LEN(aRet)
			aRet[nAux][DEF_TITULO_DO_CAMPO] := X3Titulo()	//"Código Municipio"
			aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := X3DescriC()	//"Código Municipio"
			aRet[nAux][DEF_IDENTIFICADOR] := "CNT_"+Right(aCAmpos[nX], Len(aCAmpos[nX]) - 4)
			aRet[nAux][DEF_TIPO_DO_CAMPO] := TamSX3(aCampos[nX])[3]
			aRet[nAux][DEF_TIPO_CAMPO_VIEW] := TamSX3(aCampos[nX])[3]
			aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3(aCampos[nX])[1]
			aRet[nAux][DEF_DECIMAL_DO_CAMPO] := TamSX3(aCampos[nX])[2]
			aRet[nAux][DEF_RECEBE_VAL] := .T.
			aRet[nAux][DEF_OBRIGAT] := .F.
			aRet[nAux][DEF_VIRTUAL] := .T.
			aRet[nAux][DEF_LOOKUP] := GetSX3Cache( aCampos[nX], "X3_F3" )
			aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F.}
			aRet[nAux][DEF_ORDEM] := cSeq
			aRet[nAux][DEF_PICTURE] := X3Picture(aCampos[nX])
			aRet[nAux][DEF_CAN_CHANGE] := .T.
			If !Empty(aQuebra)
				aRet[nAux][DEF_COMBO_VAL] := aQuebra
			EndIf
			//aRet[nAux][DEF_HELP] := {STR0040}	//"Municipio a ser utilizado apenas para filtro dos locais de atendimento."
		EndIf
		SX3->(RestArea(aAreaSX3))
	Next nX
ElseIf cTable == 'FIL'

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( 'CXN_CLIENT' )	//"Cliente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( 'CXN_CLIENT' )	//"Cliente"
	aRet[nAux][DEF_IDENTIFICADOR] := "FIL_CLIENT"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("CXN_CLIENT")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_CODEBLOCK_VALID] := {|oMdl,cField,xNewValue| At930AVlCL(oMdl,cField,xNewValue, "FIL") }
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_LOOKUP] := "CNC001"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0043}	//"Cliente a ser utilizado apenas para filtro dos locais de atendimento."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( 'CXN_LJCLI' )	//"Loja"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( 'CXN_LJCLI' )	//"Loja"
	aRet[nAux][DEF_IDENTIFICADOR] := "FIL_LOJA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("CXN_LJCLI")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_CODEBLOCK_VALID] := {|oMdl,cField,xNewValue| At930AVlCL(oMdl,cField,xNewValue, "FIL") }
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| !Empty(FwFldGet("FIL_CLIENT"))}
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0042}	//"Loja a ser utilizado apenas para filtro dos locais de atendimento."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( 'ABS_ESTADO', .F. )	//"Estado do local"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( 'ABS_ESTADO', .F. )	//"Estado do local"
	aRet[nAux][DEF_IDENTIFICADOR] := "FIL_ESTADO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABS_ESTADO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_LOOKUP] := "12"
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CODEBLOCK_VALID] := {|oMdl,cField,xNewValue| At930AVlEs(oMdl,cField,xNewValue) }
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0041}	//"Estado a ser utilizado apenas para filtro dos locais de atendimento."
    
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( 'ABS_CODMUN', .F. )	//"Código Municipio"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( 'ABS_CODMUN', .F. )	//"Código Municipio"
	aRet[nAux][DEF_IDENTIFICADOR] := "FIL_CODMUN"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABS_CODMUN")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F.}
	aRet[nAux][DEF_LOOKUP] := "CC2FIL"
	aRet[nAux][DEF_ORDEM] := "04"
	aRet[nAux][DEF_PICTURE] := "9999999"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0040}	//"Municipio a ser utilizado apenas para filtro dos locais de atendimento."

	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))

	For nX := 1 To Len(aCampos)
		aAreaSX3  := SX3->(GetArea())
		If Left(aCAmpos[nX], 3) $ 'CNA|ABS|CN9|TFJ|TFL' .AND. SX3->(MSSeek( aCampos[nX] ))
			aQuebra := {}
			aValor := StrTokArr(AllTrim(X3CBox()),';')
			For nI := 1 To Len(aValor)
				If !Empty(aValor[nI])
					AADD(aQuebra, aValor[nI])
				EndIf
			Next nI
			cSeq := StrZero(VAL("05") + nX, 2)
			AADD(aRet, ARRAY(QUANTIDADE_DEFS))
			nAux := LEN(aRet)
			aRet[nAux][DEF_TITULO_DO_CAMPO] := X3Titulo()	//"Código Municipio"
			aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := X3DescriC()	//"Código Municipio"
			aRet[nAux][DEF_IDENTIFICADOR] := "FIL_"+Right(aCAmpos[nX], Len(aCAmpos[nX]) - 4)
			aRet[nAux][DEF_TIPO_DO_CAMPO] := TamSX3(aCampos[nX])[3]
			aRet[nAux][DEF_TIPO_CAMPO_VIEW] := TamSX3(aCampos[nX])[3]
			aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3(aCampos[nX])[1]
			aRet[nAux][DEF_DECIMAL_DO_CAMPO] := TamSX3(aCampos[nX])[2]
			aRet[nAux][DEF_RECEBE_VAL] := .T.
			aRet[nAux][DEF_OBRIGAT] := .F.
			aRet[nAux][DEF_VIRTUAL] := .T.
			aRet[nAux][DEF_LOOKUP] := GetSX3Cache( aCampos[nX], "X3_F3" )
			aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F.}
			aRet[nAux][DEF_ORDEM] := cSeq
			aRet[nAux][DEF_PICTURE] := X3Picture(aCampos[nX])
			aRet[nAux][DEF_CAN_CHANGE] := .T.
			If !Empty(aQuebra)
				aRet[nAux][DEF_COMBO_VAL] := aQuebra
			EndIf
			//aRet[nAux][DEF_HELP] := {STR0040}	//"Municipio a ser utilizado apenas para filtro dos locais de atendimento."
		EndIf
		SX3->(RestArea(aAreaSX3))
	Next nX
ElseIf cTable == 'MED'

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0017	//"Mark"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0017	//"Mark"
	aRet[nAux][DEF_IDENTIFICADOR] := "MED_MARK"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "L"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "CHECK"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_CODEBLOCK_VALID] := {|oMdl,cField,xNewValue| AT930AMark(oMdl,cField,xNewValue) }
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0018	//"Local de Atendimento"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0018	//"Local de Atendimento"
	aRet[nAux][DEF_IDENTIFICADOR] := "MED_LOCAL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABS_LOCAL")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( 'ABS_DESCRI', .F. )	//"Descrição do Local       "
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( 'ABS_DESCRI', .F. )	//"Descrição do Local       "
	aRet[nAux][DEF_IDENTIFICADOR] := "MED_DESLOC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABS_DESCRI")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( 'CNA_NUMERO', .F. )	//"Numero da Planilha       "
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( 'CNA_NUMERO', .F. )	//"Numero da Planilha       "
	aRet[nAux][DEF_IDENTIFICADOR] := "MED_NUMPLA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("CNA_NUMERO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "04"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0011	//"Cliente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0011	//"Cliente"
	aRet[nAux][DEF_IDENTIFICADOR] := "MED_CLIENT"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("CXN_CLIENT")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_CODEBLOCK_VALID] := {|oMdl,cField,xNewValue| At930AVlCL(oMdl,cField,xNewValue, "MED") }
	aRet[nAux][DEF_LOOKUP] := "CNC001"
	aRet[nAux][DEF_ORDEM] := "05"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0039}	//"Cliente utilizado na apuração."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0019	//"Descri. Cliente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0019	//"Descri. Cliente"
	aRet[nAux][DEF_IDENTIFICADOR] := "MED_DESCLI"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("A1_NOME")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "07"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0012	//"Loja"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0012	//"Loja"
	aRet[nAux][DEF_IDENTIFICADOR] := "MED_LOJA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("CXN_LJCLI")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_CODEBLOCK_VALID] := {|oMdl,cField,xNewValue| At930AVlCL(oMdl,cField,xNewValue, "MED") }
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| !Empty(FwFldGet("MED_CLIENT"))}
	aRet[nAux][DEF_ORDEM] := "06"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0038}	//"Loja utilizado na apuração."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( 'ABS_ESTADO', .F. )	//"Estado do local"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( 'ABS_ESTADO', .F. )	//"Estado do local"
	aRet[nAux][DEF_IDENTIFICADOR] := "MED_ESTADO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABS_ESTADO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "08"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( 'ABS_CODMUN', .F. )	//"Código Municipio"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( 'ABS_CODMUN', .F. )	//"Código Municipio"
	aRet[nAux][DEF_IDENTIFICADOR] := "MED_CODMUN"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABS_CODMUN")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "09"
	aRet[nAux][DEF_PICTURE] := "9999999                                      "
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( 'ABS_MUNIC', .F. )	//"Município do local"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( 'ABS_MUNIC', .F. )	//"Município do local"
	aRet[nAux][DEF_IDENTIFICADOR] := "MED_MUNIC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABS_MUNIC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "10"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( 'CNA_SALDO', .F. )	//"Saldo da Planilha"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( 'CNA_SALDO', .F. )	//"Saldo da Planilha"
	aRet[nAux][DEF_IDENTIFICADOR] := "MED_SALPLA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := TamSX3("CNA_SALDO")[3]
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := TamSX3("CNA_SALDO")[3]
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("CNA_SALDO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := TamSX3("CNA_SALDO")[2]
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "11"
	aRet[nAux][DEF_PICTURE] := "@E 9,999,999,999,999.99                      "
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0021	//"Saldo da Comp."	
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0021	//"Saldo da Comp."	
	aRet[nAux][DEF_IDENTIFICADOR] := "MED_SALCOM"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := TamSX3("CNA_SALDO")[3]
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := TamSX3("CNA_SALDO")[3]
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("CNA_SALDO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := TamSX3("CNA_SALDO")[2]
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "12"
	aRet[nAux][DEF_PICTURE] := "@E 9,999,999,999,999.99                      "
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0022	//"Valor Apurar"	
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0022	//"Valor Apurar"	
	aRet[nAux][DEF_IDENTIFICADOR] := "MED_VALAPU"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 16
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 2
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "13"
	aRet[nAux][DEF_PICTURE] := "@E 999,999,999.99                            "
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0037}	//"Valor a ser apurado da planilha."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0023 //"Codigo TFL"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0023	//"Codigo TFL"
	aRet[nAux][DEF_IDENTIFICADOR] := "MED_CODTFL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFL_CODIGO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := TamSX3("TFL_CODIGO")[2]
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "14"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
ElseIf cTable == 'TOT'
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0024 //"Total"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0024 //"Total"
	aRet[nAux][DEF_IDENTIFICADOR] := "TOT_SALDO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 16
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 2
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@E 999,999,999.99                            "
	aRet[nAux][DEF_CAN_CHANGE] := .F.
EndIf

Return (aRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados
@description Bloco de código executado no activate
@return 
@author Augusto Albuquerque
@since  19/10/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function InitDados(oModel)
Local oMdlCNT := oModel:GetModel("CNTMASTER")
Local oMdlFIL := oModel:GetModel("FILMASTER")
Local oMdlMED := oModel:GetModel("MEDDETAIL")
Local oStrCNT := oMdlCNT:GetStruct() 
Local cCodMed := ""

AT930ALiFil({"FIL_CLIENT", "FIL_LOJA", "FIL_ESTADO"}, .F., oModel)

If isInCallStack("AT930View") .OR. isInCallStack("AT930Estor") 
	oStrCNT:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.) 
	
	cCodMed := CodMedicao( TFV->TFV_CODIGO )

	DbSelectArea("CND")
	CND->(dbSetOrder(7))

	oMdlCNT:LoadValue("CNT_NUMERO", TFV->TFV_CONTRT)
	oMdlCNT:LoadValue("CNT_REVISA", TFV->TFV_REVISA)

	If CND->(MSSeek(xFilial("CND")+TFV->TFV_CONTRT+TFV->TFV_REVISA+cCodMed))
		oMdlCNT:LoadValue("CNT_VIEWCOM", CND->CND_COMPET)
	EndIf
	AT930ABus2( .T., TFV->TFV_CODIGO, oModel, cCodMed )
	oStrCNT:SetProperty("*", MODEL_FIELD_WHEN, {|| .F.})

EndIf

oMdlMED:SetNoInsertLine(.T.)
oMdlMED:SetNoDeleteLine(.T.)
oMdlMED:SetNoUpdateLine(.T.)

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT930ALiFil
@description Liberação dos campos no grid de filtro
@return 
@author Augusto Albuquerque
@since  19/10/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT930ALiFil( aCampos, lLibera, oModel, lFiltro)
Local oModel    := IIF(oModel <> Nil, oModel, FwModelActive())
Local oView 	:= FwViewActive()
Local oMdlFil	:= oModel:GetModel("FILMASTER")
Local oMdlCNT	:= oModel:GetModel("CNTMASTER")
Local oMdlTOT	:= oModel:GetModel("TOTMASTER")
Local oStrFIL 	:= oMdlFil:GetStruct()
Local oStrCNT 	:= oMdlCNT:GetStruct() 
Local aCampPE	:= Tec930ACam("FIL")
Local nX

Default lLibera := !Empty(FwFldGet("CNT_NUMERO"))
Default lFiltro	:= .F.

For nX := 1 To Len(aCampos)
	oStrFIL:SetProperty(aCampos[nX], MODEL_FIELD_WHEN, {|| lLibera})
	If !lLibera
		oMdlFil:LoadValue(aCampos[nX], "")
	EndIf
Next nX
If ASCAN(aCampos, {|a| a == "FIL_CLIENT"}) > 0
	For nX := 1 To Len(aCampPE)
		If Left(aCampPE[nX], 3) $ 'CNA|ABS|CN9|TFJ|TFL'
			oStrFIL:SetProperty("FIL_"+Right(aCampPE[nX], Len(aCampPE[nX]) - 4), MODEL_FIELD_WHEN, {|| lLibera})
			If !lLibera
				oMdlFil:LoadValue("FIL_"+Right(aCampPE[nX], Len(aCampPE[nX]) - 4), "")
			EndIf
		EndIf
	Next nX
EndIf
If !lFiltro
	oStrCNT:SetProperty("CNT_COMPET", MODEL_FIELD_WHEN, {|| lLibera})
	aCampPE	:= Tec930ACam("CNT")
	For nX := 1 To Len(aCampPE)
		oStrCNT:SetProperty("CNT_"+Right(aCampPE[nX], Len(aCampPE[nX]) - 4), MODEL_FIELD_WHEN, {|| lLibera})
		If !lLibera
			oMdlCNT:LoadValue("CNT_"+Right(aCampPE[nX], Len(aCampPE[nX]) - 4), "")
		EndIf
	Next nX
EndIf

If !isInCallStack("InitDados")
	If !lFiltro
		oMdlCNT:LoadValue("CNT_COMPET", "")
		oMdlCNT:LoadValue("CNT_VALAPUR", 0)
		AT930AClea( oModel, , .T., ,.T.)
		oMdlTOT:LoadValue("TOT_SALDO", 0)
	EndIf

	If !isBlind()
		oView:Refresh()
	EndIf
EndIf

Return 

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At930ABusc
@description Cria o botão de buscar
@return 
@author Augusto Albuquerque
@since  19/10/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930ABusc(oPanel)
Local lMonitor := IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366
Local aTamanho := {}

If lMonitor
	AADD(aTamanho, 52.00)
Else
	AADD(aTamanho, 44.00)
EndIf

If !(isInCallStack("AT930View") .OR. isInCallStack("AT930Estor")) 
	TButton():New( (oPanel:nHeight / 2) - 13, (oPanel:nWidth/2) - aTamanho[1], STR0013 , oPanel, { || FwMsgRun(Nil,{|| AT930ABus2()}, Nil, STR0027) },43,12,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Buscar (F10)" ## "Buscando Informações..."
EndIf

Return Nil

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At930AMarc
@description Cria o botão "Marca Todos"
@return 
@author Augusto Albuquerque
@since  19/10/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930AMarc(oPanel)
Local lMonitor := IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366
Local aTamanho := {}

If lMonitor
	AADD(aTamanho, 52.00)
Else
	AADD(aTamanho, 44.00)
EndIf

If !(isInCallStack("AT930View") .OR. isInCallStack("AT930Estor") )
	TButton():New( (oPanel:nHeight / 2) - 13, (oPanel:nWidth/2) - aTamanho[1], STR0014 , oPanel, { || FwMsgRun(Nil,{|| At930aMrkT() }, Nil, STR0059) },43,12,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Marca Todos" ## "Marcando..."
EndIf

Return Nil

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At930AVlEs
@description Limpa os campos de municipio caso não seja selecionado nenhum estado
@return lRet
@author Augusto Albuquerque
@since  14/10/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930AVlEs(oMdl,cField,xNewValue)
Local lRet		:= .T.

If !Empty( xNewValue )
	lRet := ExistCpo("SX5","12"+xNewValue)
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At930AVlCL
@description  Retorna se existe o cliente/loja na CNC
@return lRet
@author Augusto Albuquerque
@since  14/10/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930AVlCL( oMdl, cCampo, xValue, cAba )
Local oModel	:= oMdl:GetModel()
Local cContrato	:= oModel:GetValue("CNTMASTER","CNT_NUMERO")
Local cRevisa	:= oModel:GetValue("CNTMASTER","CNT_REVISA")
Local cClient	:= ""
Local lRet		:= .T.

DbSelectArea("CNC")
CNC->(dbSetOrder(3))

If !Empty(xValue)
	If 'LOJA' $ cCampo 
		cClient := oMdl:GetValue(cAba+"_CLIENT")
		lRet := CNC->(MSSeek(xFilial("CNC")+cContrato+cRevisa+cClient+xValue))
	Else
		lRet := CNC->(MsSeek(xFilial("CNC")+cContrato+cRevisa+xValue))
	EndIf
Else
	If 'CLIENT' $ cCampo 
		oMdl:LoadValue(cAba+"_CLIENT", "")
	EndIf
EndIf
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT930AComp
@description Retorna As Competências do contrato
@return lRet
@author Augusto Albuquerque
@since  14/10/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT930AComp()
Local aCompets		:= CtrCompets()
Local nX
Local oModel 		:= FwModelActive()
Local oView 		:= FwViewActive()

For nX := 1 to Len(aCompets)
	aCompets[nX] := CVALTOCHAR(nX)+'='+aCompets[nX]
Next nX

oView:SetFieldProperty("CNTMASTER","CNT_COMPET","COMBOVALUES",{aCompets}) 

oView:Refresh()

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT930ABus2
@description Busca as informações do contrato(TFL).
@return lRet
@author Augusto Albuquerque
@since  14/10/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT930ABus2( lView, cCodApurac, oModel, cCodMed )
Local oModel 		:= IIF( oModel <> Nil, oModel, FwModelActive())
Local oView 		:= FwViewActive()
Local oMdlCNT 		:= oModel:GetModel("CNTMASTER")
Local oMdlMED 		:= oModel:GetModel("MEDDETAIL")
Local oMdlFIL 		:= oModel:GetModel("FILMASTER")
Local oMdlTOT		:= oModel:GetModel("TOTMASTER")
Local aCampos		:= Tec930ACam("FIL")
Local cContrato		:= oMdlCNT:GetValue("CNT_NUMERO")
Local cRevisa		:= oMdlCNT:GetValue("CNT_REVISA")
Local cCliente		:= oMdlFIL:GetValue("FIL_CLIENT")
Local cLoja			:= oMdlFIL:GetValue("FIL_LOJA")
Local cEstado		:= oMdlFIL:GetValue("FIL_ESTADO")
Local cCodMun		:= oMdlFIL:GetValue("FIL_CODMUN")
Local cCompetB		:= IIF(lView, oMdlCNT:GetValue("CNT_VIEWCOM") ,oMdlCNT:GetValue("CNT_COMPET"))
Local cAbsCliFat	:= ""
Local cAbsLojfat	:= ""
Local aCompets		:= {}
Local cQuery		:= ""
Local lCronogFi		:= .F.
Local lCliFat		:= .F.
Local lCheck		:= .F.
Local nLinha		:= 1
Local nTotGer		:= 0
Local nTotMed		:= 0
Local nX

Default lView 		:= .F.
Default cCodApurac	:= ""

AT930AClea( oModel, @oMdlMED, .F., oView, isInCallStack("InitDados") )

aMarks 	:= {}
aCalcIt	:= {}
cCompet	:= ""
oMDl930A := Nil

If  ( (!Empty(cCompetB) .AND. !isInCallStack("InitDados")) .OR. !Empty(cContrato) ).AND. At930VldCont( cContrato, cRevisa )
	If AT930VldCt( oModel )
		lCronogFi := CronogFina(cContrato)
		If !lView
			aCompets := CtrCompets()
			For nX := 1 To Len(aCompets)
				If Val(cCompetB) == nX
					cCompetB := aCompets[nX]
					Exit
				EndIf
			Next nX
		EndIf
		cQuery := ""
		cQuery += " SELECT ABS.ABS_LOCAL, ABS_DESCRI, ABS_ESTADO, ABS_CODMUN, ABS_MUNIC, CNA_NUMERO, CNA.CNA_CLIENT, CNA.CNA_LOJACL, CNA_SALDO, TFL.TFL_CODIGO, CNA.CNA_VLTOT, "
		cQuery += " ABS.ABS_CLIFAT, ABS.ABS_LJFAT "
		If lCronogFi
			cQuery += " , CNF.CNF_SALDO, CNF.CNF_COMPET"
		EndIf
		cQuery += " FROM " + RetSqlName("ABS") + " ABS "
		cQuery += " INNER JOIN " + RetSqlName("TFL") + " TFL "
		cQuery += " ON TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
		cQuery += " AND TFL.D_E_L_E_T_ = ' ' "
		cQuery += " AND TFL.TFL_ENCE <> '1' "
		cQuery += " AND TFL.TFL_LOCAL = ABS.ABS_LOCAL "
		cQuery += " INNER JOIN " + RetSqlName("CNA") + " CNA "
		cQuery += " ON CNA.CNA_NUMERO = TFL.TFL_PLAN "
		cQuery += " AND CNA.CNA_CONTRA = TFL.TFL_CONTRT "
		cQuery += " AND CNA.CNA_REVISA = TFL.TFL_CONREV "
		cQuery += " AND CNA.D_E_L_E_T_ = ' ' "
		cQuery += " AND CNA.CNA_FILIAL = '" + xFilial("CNA") + "' "
		cQuery += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
		cQuery += " ON  TFL.TFL_CODPAI = TFJ.TFJ_CODIGO  "
		cQuery += " AND TFJ.D_E_L_E_T_ = ' ' "
		cQuery += " AND TFJ.TFJ_STATUS = '1' "
		cQuery += " AND TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' "
		cQuery += " INNER JOIN " + RetSqlName("CN9") + " CN9 "
		cQuery += " ON CN9.D_E_L_E_T_ = ' ' "
		cQuery += " AND TFJ.TFJ_CONTRT = CN9.CN9_NUMERO "
		cQuery += " AND TFJ.TFJ_CONREV = CN9.CN9_REVISA "
		If lCronogFi
			cQuery += " INNER JOIN " + RetSQLName("CNF") + " CNF ON "
			cQuery += "	CNA.CNA_FILIAL = CNF.CNF_FILIAL	"
			cQuery += "	AND CNA.CNA_CONTRA = CNF.CNF_CONTRA	"
			cQuery += "	AND CNA.CNA_REVISA = CNF.CNF_REVISA	"
			cQuery += "	AND CNA.CNA_CRONOG = CNF.CNF_NUMERO	"
			cQuery += " AND CNF.CNF_COMPET = '"+cCompetB+"'"
			cQuery += "	AND CNF.D_E_L_E_T_ = ' ' "
		EndIf
		cQuery += " AND CN9.CN9_FILIAL = '" + xFilial("CN9") + "' "
		cQuery += " WHERE TFL.TFL_CONTRT = '" + cContrato + "' "
		cQuery += " AND TFL.TFL_CONREV = '" + cRevisa + "' "
		cQuery += " AND ABS.ABS_FILIAL = '" + xFilial("ABS") + "' "
		cQuery += " AND ABS.D_E_L_E_T_ = ' ' "
		If !Empty(cEstado)
			cQuery += " AND ABS.ABS_ESTADO = '" + cEstado + "' "
			If !Empty(cCodMun)
				cQuery += " AND ABS.ABS_CODMUN = '" + cCodMun + "' "
			EndIf
		EndIf
		If !Empty(cCliente)
			cQuery += " AND CNA.CNA_CLIENT = '" + cCliente + "' "
			If !Empty(cLoja)
				cQuery += " AND CNA.CNA_LOJACL = '" + cLoja + "' "
			EndIf 
		EndIf
		If Len(aCampos) > 0
			For nX := 1 To Len(aCampos)
				If Left(aCampos[nX], 3) $ 'CNA|ABS|CN9|TFJ|TFL'
					cCampo := "FIL_"+Right(aCampos[nX], Len(aCampos[nX]) - 4)
					If !Empty(oMdlFIL:GetValue(cCampo))
						cQuery += " AND " + aCampos[nX] + " = '" + oMdlFIL:GetValue(cCampo) + "' "
					EndIf
				EndIf
			Next nX
		EndIf
		cQuery += " ORDER BY CNA.CNA_NUMERO "

		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		If lView
			DbSelectArea("CXN")
			CXN->(dbSetOrder(1))
		EndIf
		If !((cAliasQry)->(EOF()))
			while !((cAliasQry)->(EOF()))
				If lView
						nTotMed := TotApurac( cCodApurac, (cAliasQry)->(TFL_CODIGO))
						nTotGer	+= nTotMed
						If lCronogFi
							oMdlCNT:LoadValue("CNT_COMPET", (cAliasQry)->(CNF_COMPET))
						EndIf
				EndIf
				If !lView .OR. nTotMed > 0
					If !oMdlMED:IsEmpty()
						nLinha := oMdlMED:AddLine()
					EndIf
					oMdlMED:GoLine(nLinha)
					If lView
						oMdlMED:LoadValue("MED_VALAPU", nTotMed)	
					EndIf
					oMdlMED:LoadValue("MED_LOCAL", (cAliasQry)->(ABS_LOCAL))
					oMdlMED:LoadValue("MED_DESLOC", (cAliasQry)->(ABS_DESCRI))
					oMdlMED:LoadValue("MED_NUMPLA", (cAliasQry)->(CNA_NUMERO))
					If lView
						lCheck := .F.
						If CXN->(MSSeek(xFilial("CXN")+cContrato+cRevisa+cCodMed))
							oMdlMED:LoadValue("MED_CLIENT", CXN->CXN_CLIENT)
							oMdlMED:LoadValue("MED_LOJA"  , CXN->CXN_LJCLI)
						EndIf
					Else
						lCliFat := .F.

						If !Empty(Alltrim((cAliasQry)->(ABS_CLIFAT))) .AND. !Empty(Alltrim((cAliasQry)->(ABS_LJFAT)))
							cQuery := " SELECT 1 R_E_C_N_O_ "
							cQuery += " FROM   "+RetSqlName("CNC")+" CNC "
							cQuery += " WHERE  CNC.CNC_FILIAL = '"+xFilial("CNC")+"' "
							cQuery += " AND    CNC.CNC_NUMERO = '"+cContrato+"' "
							cQuery += " AND    CNC.CNC_REVISA = '"+cRevisa+"' "
							cQuery += " AND    CNC.CNC_CLIENT = '"+(cAliasQry)->(ABS_CLIFAT)+"' "
							cQuery += " AND    CNC.CNC_LOJACL = '"+(cAliasQry)->(ABS_LJFAT)+"' "
							cQuery += " AND    CNC.D_E_L_E_T_ = '' "
							cQuery := ChangeQuery(cQuery)
							cAliasCNC := GetNextAlias()
							DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCNC,.T.,.T.)
							If (cAliasCNC)->(!EOF())
								lCliFat:= .T.
							EndIf
							(cAliasCNC)->(DbCloseArea())
						EndIf

						If lCliFat
							oMdlMED:LoadValue("MED_CLIENT", (cAliasQry)->(ABS_CLIFAT))
							oMdlMED:LoadValue("MED_LOJA"  , (cAliasQry)->(ABS_LJFAT))
						Else
							oMdlMED:LoadValue("MED_CLIENT", (cAliasQry)->(CNA_CLIENT))
							oMdlMED:LoadValue("MED_LOJA"  , (cAliasQry)->(CNA_LOJACL))
						ENdIf
					EndIf
					oMdlMED:LoadValue("MED_DESCLI", Posicione("SA1",1,xFilial("SA1")+oMdlMED:GetValue("MED_CLIENT")+oMdlMED:GetValue("MED_LOJA"),"A1_NOME"))
					oMdlMED:LoadValue("MED_ESTADO", (cAliasQry)->(ABS_ESTADO))
					oMdlMED:LoadValue("MED_CODMUN", (cAliasQry)->(ABS_CODMUN))
					oMdlMED:LoadValue("MED_MUNIC", (cAliasQry)->(ABS_MUNIC))
					oMdlMED:LoadValue("MED_SALPLA", (cAliasQry)->(CNA_VLTOT))
					If lCronogFi
						oMdlMED:LoadValue("MED_SALCOM", (cAliasQry)->(CNF_SALDO))
					Else
						oMdlMED:LoadValue("MED_SALCOM", SaldCNB(cContrato, cRevisa, (cAliasQry)->(CNA_NUMERO)))
					EndIf
					oMdlMED:LoadValue("MED_CODTFL", (cAliasQry)->(TFL_CODIGO))
				EndIf
				(cAliasQry)->(dbSkip())
			EndDo
		EndIf
		(cAliasQry)->(dbCloseArea())
		oMdlMED:GoLine(1)
	EndIf
EndIf

oMdlMED:SetNoInsertLine(.T.)
oMdlMED:SetNoDeleteLine(.T.)
If lView
	oMdlTOT:LoadValue("TOT_SALDO", nTotGer)
EndIf
If !IsBlind() .AND. VALTYPE(oView) == "O" .AND. !lView
	oView:Refresh()
EndIf

Return	

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At930AChec
@description Mark do grid de medição
@return lRet
@author Augusto Albuquerque
@since  25/11/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930AChec()
Local oMdlFull 	:= FwModelActive()
Local oView  	:= FwViewActive()
Local oMdlMED 	:= oMdlFull:GetModel('MEDDETAIL')
Local oMdlCNT	:= oMdlFull:GetModel('CNTMASTER')
Local oStrCNT	:= oMdlCNT:GetStruct() 
Local lMark 	:= oMdlMED:GetValue("MED_MARK")
Local lGatilho	:= IsInCallStack("At930aMrkT")

lMostraHelp := .T.
If lMark
	AADD(aMarks, {oMdlMED:GetValue("MED_CODTFL"),;
				  oMdlMED:GetValue("MED_SALCOM")})

	AADD( aCalcIT, { oMdlMED:GetValue("MED_CODTFL") })
	oStrCNT:SetProperty("CNT_VALAPUR", MODEL_FIELD_WHEN, {|| .T.})
Else
	aMarks[ASCAN(aMarks, {|a| a[1] == oMdlMED:GetValue("MED_CODTFL")})][1] := ""
	If ASCAN(aMarks, {|a| !EMPTY(a[1])}) == 0
		aMarks := {}
		oStrCNT:SetProperty("CNT_VALAPUR", MODEL_FIELD_WHEN, {|| .F.})
	EndIf
	aCalcIT[ASCAN(aCalcIT, {|a| a[1] == oMdlMED:GetValue("MED_CODTFL")})][1] := ""
	If ASCAN(aCalcIT, {|a| !EMPTY(a[1])}) == 0
		aCalcIT := {}
	EndIf
EndIf

If !lGatilho .AND. !isBlind()
	oView:Refresh()
EndIf

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At930aMrkT
@description Função de marcar todos
@return lRet
@author Augusto Albuquerque
@since  25/11/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930aMrkT()
Local oModel 	:= FwModelActive()
Local oView  	:= FwViewActive()
Local oMdlGrd	:= oModel:GetModel('MEDDETAIL')
Local nLine
Local nX

nLine := oMdlGrd:GetLine()

If !(oMdlGrd:isEmpty())
	For nX := 1 To oMdlGrd:Length()
		oMdlGrd:GoLine(nX)
		oMdlGrd:SetValue("MED_MARK", !(oMdlGrd:GetValue("MED_MARK")))
	Next nX
	oMdlGrd:GoLine(nLine)
	If !IsBlind()
		oView:Refresh()
	EndIf
EndIf

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT930AClea
@description Função para limpar o grid de medições
@return lRet
@author Augusto Albuquerque
@since  25/11/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT930AClea( oModel, oMdlMED, lTrava, oView, lView )
Local oMdlCNT	:= Nil
Local oStrCNT	:= Nil
Local oMdlTOT	:= Nil

Default oModel	:= FwModelActive()
Default oMdlMED := oModel:GetModel('MEDDETAIL')
Default lTrava	:= .T.
Default oView	:= FwViewActive()
Default lView	:= .F.

aMarks 	:= {}
aCalcIt	:= {}
cCompet	:= ""
lMostraHelp := .T.

oMDl930A := Nil
oMdlCNT := oModel:GetModel("CNTMASTER")
oMdlTot	:= oModel:GetModel("TOTMASTER")

oMdlCNT:LoadValue("CNT_VALAPUR", 0)
oStrCNT	:= oMdlCNT:GetStruct() 
oStrCNT:SetProperty("CNT_VALAPUR", MODEL_FIELD_WHEN, {|| .F.})

oMdlTot:LoadValue("TOT_SALDO", 0)

oMdlMED:ClearData()
oMdlMED:InitLine()
oMdlMED:SetNoInsertLine(lTrava)
oMdlMED:SetNoDeleteLine(lTrava)
oMdlMED:SetNoUpdateLine(lTrava)

If !IsBlind() .AND. !lView
	oView:Refresh()
EndIf

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT930ACalc
@description tela para o calculo
@return lRet
@author Augusto Albuquerque
@since  25/11/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT930ACalc( lGatilho )
If !isBlind()
	FwMsgRun(Nil,{|| CalcGeral(lGatilho) }, Nil, STR0060) //"Realizando os Calculos..."
Else
	CalcGeral(lGatilho)
EndIf
Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CalcGeral
@description Função para calculo das TFL seleciona(s) e calcular os itens de RH, MI e MC
@return lRet
@author Augusto Albuquerque
@since  25/11/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function CalcGeral( lGatilho )
Local oMdlFull	:= FwModelActive()
Local oView  	:= FwViewActive()
Local oMdlCNT	:= oMdlFull:GetModel('CNTMASTER')
Local oMdlMED	:= oMdlFull:GetModel('MEDDETAIL')
Local oMdlTOT	:= oMdlFull:GetModel('TOTMASTER')
Local aPlaMark	:= {}
Local cContrato	:= oMdlCNT:GetValue("CNT_NUMERO")
Local cRevisa	:= oMdlCNT:GetValue("CNT_REVISA")
Local nLineBckp	:= oMdlMED:GetLine()
Local nValTot 	:= 0
Local nDistri	:= 0
Local nSalPlans	:= 0
Local nAuxTot	:= 0
Local nTotApu	:= 0
Local nTotPla	:= 0
local nAuxFalt	:= 0
Local nPosTFL	:= 0
Local nX
Local nY
Local lTabPre	:= SuperGetMv("MV_ORCPRC",, .F. )

Default lGatilho := .F.

If !oMdlMED:IsEmpty() .AND. ( Len(aMarks) > 0 .OR. lGatilho )
	If lGatilho
		nValTot := FwFldGet("MED_VALAPU")
		oMdlMED:SetValue("MED_MARK", .T.)
	Else
		nValTot := oMdlCNT:GetValue("CNT_VALAPUR")
	EndIf

	If lGatilho
		AADD(aPlaMark, {oMdlMED:GetValue("MED_CODTFL"),;
						 oMdlMED:GetValue("MED_SALCOM")})
		nSalPlans :=  oMdlMED:GetValue("MED_SALCOM")
	Else
		For nX := 1 To Len(aMarks)
			If !Empty(aMarks[nX][1])
				AADD( aPlaMark, aMarks[nX] )
				nSalPlans += aMarks[nX][2]
			EndIf
		Next nX	
	EndIf

	If nValTot <= Round(nSalPlans,2)
		nAuxDis	:= 0
		For nX := 1 To Len(aPlaMark)
			nDistri := aPlaMark[nX][2] / nSalPlans
			If nValTot * nDistri <= aPlaMark[nX][2]
				If Len(aPlaMark[nX]) > 2
					aPlaMark[nX][3] := Round(nValTot * nDistri, 2)
					aPlaMark[nX][4] := .F.
				Else
					AADD( aPlaMark[nX],  Round(nValTot * nDistri, 2) ) 
					AADD( aPlaMark[nX],  .F. )
				EndIf
				nAuxDis += aPlaMark[nX][3]
			Else
				If Len(aPlaMark[nX]) > 2
					aPlaMark[nX][3] := aPlaMark[nX][2]
					aPlaMark[nX][4] := .T.
				Else
					AADD( aPlaMark[nX],  aPlaMark[nX][2] ) 
					AADD( aPlaMark[nX],  .T. )
				EndIf
				nAuxDis += aPlaMark[nX][2]
			EndIf
		Next nX
		If nAuxDis < nValTot
			nAuxTot := nValTot - nAuxDis
			aPlaMark[1][3] += nAuxTot
		EndIf
		For nX := 1 To Len(aPlaMark)
			If oMdlMED:SeekLine({{ "MED_CODTFL", aPlaMark[nX][1] }},,.T. )
				nTotPla := CalcItens( cContrato, cRevisa, lTabPre, aPlaMark[nX][1], aPlaMark[nX][3], aPlaMark[nX][2],oMdlMED:GetValue("MED_NUMPLA") )
				nTotApu += nTotPla
				oMdlMED:LoadValue("MED_VALAPU", nTotPla)
			EndIF
		Next nX
		If nValTot <> nTotApu
			If lGatilho
				nPosTFL := ASCAN( aCalcIt, { |x| x[1] == oMdlMED:GetValue("MED_CODTFL")})
				If nPosTFL > 0
					For nY := 2 To Len(aCalcIt[nPosTFL])
						If nValTot < nTotApu
							nAuxFalt := nTotApu - nValTot
							aCalcIt[nPosTFL][nY][5] -= nAuxFalt 
							nTotApu -= nAuxFalt
							oMdlMED:LoadValue("MED_VALAPU", oMdlMED:GetValue("MED_VALAPU") - nAuxFalt)
						Else
							nAuxFalt := nValTot - nTotApu
							aCalcIt[nPosTFL][nY][5] += nAuxFalt 
							nTotApu += nAuxFalt
							oMdlMED:LoadValue("MED_VALAPU", oMdlMED:GetValue("MED_VALAPU") + nAuxFalt)
						EndIf
						If nTotApu == nValTot
							Exit
						EndIf
					Next nY
				EndIf
			Else
				For nX := 1 To Len(aPlaMark)
					If oMdlMED:SeekLine({{ "MED_CODTFL", aPlaMark[nX][1] }},,.T. )
						nPosTFL := ASCAN( aCalcIt, { |x| x[1] == aPlaMark[nX][1]})
						If nPosTFL > 0
							For nY := 2 To Len(aCalcIt[nPosTFL])
								If nValTot < nTotApu
									nAuxFalt := nTotApu - nValTot
									aCalcIt[nPosTFL][nY][5] -= nAuxFalt 
									nTotApu -= nAuxFalt
									oMdlMED:LoadValue("MED_VALAPU", oMdlMED:GetValue("MED_VALAPU") - nAuxFalt)
								Else
									nAuxFalt := nValTot - nTotApu
									aCalcIt[nPosTFL][nY][5] += nAuxFalt 
									nTotApu += nAuxFalt
									oMdlMED:LoadValue("MED_VALAPU", oMdlMED:GetValue("MED_VALAPU") + nAuxFalt)
								EndIf
								If nTotApu == nValTot
									Exit
								EndIf
							Next nY
							Exit
						EndIf
					EndIF
				Next nX
			EndIf
		EndIf
	Else
		AtShowLog(STR0053 + cValToChar(nValTot) + STR0054 + cValToChar(nSalPlans) + STR0055,STR0056,/*lVScroll*/,/*lHScroll*/,/*lWrdWrap*/,.F.) // "O valor inserido (" ## ") é maior que o saldo das planilhas selecionadas (" ## ") não foi inserido nenhum valor." ## "Valor da Apuração"
	EndIf
	If lGatilho
		CalcTotApu(oMdlFull)
	Else
		oMdlTOT:LoadValue("TOT_SALDO", nTotApu)
	EndIf
EndIf
oMdlMed:GoLine(nLineBckp)
If !IsBlind()
	oView:Refresh()
EndIf
Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CalcItens
@description Função para popular o array de itens calculados de acordo com os valores passador.
@return lRet
@author Augusto Albuquerque
@since  25/11/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function CalcItens( cContrato, cRevisa, lTabPre, cNumpla, nValTot, nValTotCNB,cPlanCNB )
Local aItens	:= {}
Local cQuery	:= ""
Local cAliasTFF	:= GetNextAlias()
Local cAliasMAT	:= GetNextAlias()
Local cNumPai	:= cNumpla
Local lAgrup	:= SuperGetMv("MV_GSDSGCN",, '2' ) == '2'
Local nSalPlans	:= 0
Local nItens	:= 0
Local nDistri	:= 0
Local nPosTFL	:= 0
Local nDistAux	:= 0
Local nRet		:= 0
Local nPosAux	:= 0
Local nX		:= 0
Local nValor	:= 0
Local lDsgCN 	:= At930Agrup(cContrato,cRevisa) //verifica como o contrato foi gerado
Local lCronogFi := CronogFina(cContrato)

DbSelectArea("CNB")

nPosTFL := ASCAN( aCalcIt, { |x| x[1] == cNumpla})

If nPosTFL > 0 .AND. Len(aCalcIt[nPosTFL]) > 1
	nItens := Len(aCalcIt[nPosTFL]) - 1
	aAdd(aItens,aCalcIt[nPosTFL][Len(aCalcIt[nPosTFL])])
Else
	cQuery := ""
	cQuery += " SELECT TFF.TFF_COD, " 
	cQuery += " TFF.TFF_PRODUT,TFF.TFF_ITCNB, "
	cQuery += " TFF.TFF_QTDVEN, TFF.TFF_PRCVEN "
	cQuery += " FROM " + RetSqlName("TFF") + " TFF "
	cQuery += " WHERE  TFF.TFF_FILIAL = '" +  xFilial("TFF") + "' AND TFF.D_E_L_E_T_ = ' ' "
	cQuery += " AND TFF.TFF_CODPAI = '"  + cNumpla + "' "
	cQuery += " AND TFF.TFF_COBCTR = '1' "
	cQuery += " AND TFF.TFF_ENCE <> '1' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTFF, .F., .T.)
	While !((cAliasTFF)->(EOF()))
		If !lTabPre
			cNumPai := (cAliasTFF)->(TFF_COD)
		EndIf
		If lDsgCN .And. !lCronogFi
			nValor := A930SldCNB(cContrato,cRevisa,cPlanCNB,(cAliasTFF)->(TFF_ITCNB),.F.)
		ElseIf lCronogFi
			nValor := nValTotCNB
		EndIf
		AADD(aItens, {(cAliasTFF)->(TFF_COD),;
								cNumpla,;
								Iif(nValor > 0,nValor,(cAliasTFF)->(TFF_QTDVEN) * (cAliasTFF)->(TFF_PRCVEN)),;
								cNumpla,;
								0,;
								"RH"})
		nSalPlans += (cAliasTFF)->(TFF_QTDVEN) * (cAliasTFF)->(TFF_PRCVEN)
		nItens++
		If !lTabPre
			cQry := ""
			cQry += " SELECT TFG.TFG_COD, TFG.TFG_QTDVEN, TFG.TFG_PRCVEN, TFG.TFG_ITCNB "
			cQry += " FROM " + RetSqlName("TFG") + " TFG "
			cQry += " WHERE  TFG.TFG_FILIAL = '" +  xFilial("TFG") + "' AND TFG.D_E_L_E_T_ = ' ' "
			cQry += " AND TFG.TFG_CODPAI = '"  + cNumPai + "' "
			cQry += " AND TFG.TFG_COBCTR = '1' "

			cQry := ChangeQuery(cQry)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasMAT, .F., .T.)
			While !((cAliasMAT)->(EOF()))
				If lDsgCN
					nValor := A930SldCNB(cContrato,cRevisa,cPlanCNB,(cAliasMAT)->(TFG_ITCNB),.F.)
				ElseIf lCronogFi
					nValor := nValTotCNB
				EndIf
				AADD(aItens, {(cAliasMAT)->(TFG_COD),;
									cNumpla,;
									Iif(nValor > 0,nValor,(cAliasMAT)->(TFG_QTDVEN) * (cAliasMAT)->(TFG_PRCVEN)),;
									cNumpla,;
									0,;
									"MI"})
				nSalPlans += (cAliasMAT)->(TFG_QTDVEN) * (cAliasMAT)->(TFG_PRCVEN)
				nItens++
				(cAliasMAT)->(dbSkip())
			EndDo
			(cAliasMAT)->(dbCloseArea())

			cAliasMAT := GetNextAlias()
			cQry := ""
			cQry += " SELECT TFH.TFH_COD, TFH.TFH_QTDVEN, TFH.TFH_PRCVEN, TFH.TFH_ITCNB "
			cQry += " FROM " + RetSqlName("TFH") + " TFH "
			cQry += " WHERE  TFH.TFH_FILIAL = '" +  xFilial("TFH") + "' AND TFH.D_E_L_E_T_ = ' ' "
			cQry += " AND TFH.TFH_CODPAI = '"  + cNumPai + "' "
			cQry += " AND TFH.TFH_COBCTR = '1' "

			cQry := ChangeQuery(cQry)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasMAT, .F., .T.)
			While !((cAliasMAT)->(EOF()))
				If lDsgCN
					nValor := A930SldCNB(cContrato,cRevisa,cPlanCNB,(cAliasMAT)->(TFH_ITCNB),.F.)
				ElseIf lCronogFi
					nValor := nValTotCNB
				EndIf
				AADD(aItens, {(cAliasMAT)->(TFH_COD),;
									cNumpla,;
									Iif(nValor > 0,nValor,(cAliasMAT)->(TFH_QTDVEN) * (cAliasMAT)->(TFH_PRCVEN)),;
									cNumpla,;
									0,;
									"MC"})
				nSalPlans += (cAliasMAT)->(TFH_QTDVEN) * (cAliasMAT)->(TFH_PRCVEN)
				nItens++
				(cAliasMAT)->(dbSkip())
			EndDo
			(cAliasMAT)->(dbCloseArea())
		EndIf
		(cAliasTFF)->(dbSkip())
	EndDo
	(cAliasTFF)->(dbCloseArea())
	If lTabPre
		cQry := ""
		cQry += " SELECT TFG.TFG_COD, TFG.TFG_QTDVEN, TFG.TFG_PRCVEN, TFG.TFG_ITCNB "
		cQry += " FROM " + RetSqlName("TFG") + " TFG "
		cQry += " WHERE  TFG.TFG_FILIAL = '" +  xFilial("TFG") + "' AND TFG.D_E_L_E_T_ = ' ' "
		cQry += " AND TFG.TFG_CODPAI = '"  + cNumPai + "' "
		cQry += " AND TFG.TFG_COBCTR = '1' "

		cQry := ChangeQuery(cQry)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasMAT, .F., .T.)
		While !((cAliasMAT)->(EOF()))
			If lDsgCN
				nValor := A930SldCNB(cContrato,cRevisa,cPlanCNB,(cAliasMAT)->(TFG_ITCNB),.F.)
			ElseIf lCronogFi
				nValor := nValTotCNB
			EndIf
			AADD(aItens, {(cAliasMAT)->(TFG_COD),;
								cNumpla,;
								Iif(nValor > 0,nValor,(cAliasMAT)->(TFG_QTDVEN) * (cAliasMAT)->(TFG_PRCVEN)),;
								cNumpla,;
								0,;
								"MI"})
			nSalPlans += (cAliasMAT)->(TFG_QTDVEN) * (cAliasMAT)->(TFG_PRCVEN)
			nItens++
			(cAliasMAT)->(dbSkip())
		EndDo
		(cAliasMAT)->(dbCloseArea())
		
		cAliasMAT := GetNextAlias()
		cQry := ""
		cQry += " SELECT TFH.TFH_COD, TFH.TFH_QTDVEN, TFH.TFH_PRCVEN, TFH.TFH_ITCNB "
		cQry += " FROM " + RetSqlName("TFH") + " TFH "
		cQry += " WHERE  TFH.TFH_FILIAL = '" +  xFilial("TFH") + "' AND TFH.D_E_L_E_T_ = ' ' "
		cQry += " AND TFH.TFH_CODPAI = '"  + cNumPai + "' "
		cQry += " AND TFH.TFH_COBCTR = '1' "

		cQry := ChangeQuery(cQry)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasMAT, .F., .T.)
		While !((cAliasMAT)->(EOF()))
			If lDsgCN
				nValor := A930SldCNB(cContrato,cRevisa,cPlanCNB,(cAliasMAT)->(TFH_ITCNB),.F.)
			ElseIf lCronogFi
				nValor := nValTotCNB
			EndIf
			AADD(aItens, {(cAliasMAT)->(TFH_COD),;
								cNumpla,;
								Iif(nValor > 0,nValor,(cAliasMAT)->(TFH_QTDVEN) * (cAliasMAT)->(TFH_PRCVEN)),;
								cNumpla,;
								0,;
								"MC"})
			nSalPlans += (cAliasMAT)->(TFH_QTDVEN) * (cAliasMAT)->(TFH_PRCVEN)
			nItens++
			(cAliasMAT)->(dbSkip())
		EndDo
		(cAliasMAT)->(dbCloseArea())
	EndIf
EndIf
If nItens > 0
	For nX := 1 To Len(aItens)
		If nX == Len(aItens)
			nDistri := 1 - nDistAux
		Else
			If !lCronogFi
				nDistri := aItens[nX][3] / nValTotCNB
			Else
				nDistri := (aItens[nX][3] / nItens) / nValTotCNB
			EndIf	
		EndIf
		If Round(nValTot * nDistri, 2) <= Round(aItens[nX][3],2)
			aItens[nX][5] := Round(nValTot * nDistri, 2)  
			nRet += aItens[nX][5]
		EndIf
		nDistAux += nDistri
		If lAgrup
			//ASCAN( aCalcIt, { |x| x[1] == oMdlMed:GetValue("MED_CODTFL") } )
			If (nPosAux := aScan(aCalcIt[nPosTFL], { |x| x[6] == aItens[nX][6]}, 2)) > 0
				aCalcIt[nPosTFL][nPosAux][5] += aItens[nX][5]
			Else
				AADD(aCalcIt[nPosTFL], aItens[nX])
			EndIf	
		Else
			AADD(aCalcIt[nPosTFL], aItens[nX])
		EndIF
	Next nX
EndIf

Return nRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At930ACmt
@description Commit da apuração agil
@return lRet
@author Augusto Albuquerque
@since  25/11/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930ACmt(oModel)
Local lRet := .T.
Local lMonitor	:= FWIsInCallStack("At930MoApu")

If !isBlind() .And. !lMonitor
	FwMsgRun(Nil,{|| lRet := Commit930A(oModel) }, Nil, STR0058) //"Preparando a Apuração..."
Elseif lMonitor
	lRet := PrepMultTh(oModel)
ElseIf isBlind() .And. !lMonitor
	lRet := Commit930A(oModel)
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Commit930A
@description Commit da apuração agil
@return lRet
@author Augusto Albuquerque
@since  25/11/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Commit930A( oModel )
Local oMdl930 	:= FwLoadModel("TECA930")
Local oMdlTWB	:= Nil
Local oMdlTFW	:= Nil 
Local oMdlTFX	:= Nil 
Local oMdlTFY	:= Nil 
LOcal oMDlTFV	:= Nil
Local oMdlCNT 	:= oModel:GetModel("CNTMASTER")
Local oMdlMED	:= oModel:GetModel("MEDDETAIL")
Local oMdlTOT	:= oModel:GetModel("TOTMASTER")
Local aErroMVC	:= {}
Local aErrors	:= {}
Local cMsg		:= ""
Local nPosTFL	:= 0
Local lRet		:= .T.
Local nX
Local nZ

oMDl930A := Nil
Pergunte("TEC930",.F.)
MV_PAR01	:= oMdlCNT:GetValue("CNT_NUMERO")
MV_PAR02	:= dDataBase
MV_PAR03	:= dDataBase + 30
MV_PAR04	:= ""
MV_PAR05	:= 1

If oMdlTOT:GetValue("TOT_SALDO") > 0

	If isInCallStack("AT930Estor") //Caso estorno, muda o campo de competencia que esta na tela.
		AT930SPAR4(oMdlCNT:GetValue("CNT_VIEWCOM"))
	Else
		cCompet	:= oMdlCNT:GetValue("CNT_COMPET")
		AT930SPAR4(CtrCompets()[Val(cCompet)])
	EndIf
	
	Begin Transaction
		If isInCallStack("AT930Estor") 
			oMdl930:SetOperation(MODEL_OPERATION_DELETE)
			If oMdl930:Activate()
				FwMsgRun(Nil,{|| lRet := At930Commit( oMdl930 )}, Nil, STR0025) //"Estornando..."
			EndIf
		Else
			If !Empty(cCompet) .AND. !Empty(aMarks) .AND. !Empty(aCalcIT)
				oMdl930:SetOperation(MODEL_OPERATION_INSERT)
				If oMdl930:Activate()
					oMdlTFV	:= oMdl930:GetModel("TFVMASTER")
					oMdlTWB	:= oMdl930:GetModel("TWBDETAIL")
					oMdlTFW	:= oMdl930:GetModel("TFWDETAIL")
					oMdlTFX	:= oMdl930:GetModel("TFXDETAIL")
					oMdlTFY	:= oMdl930:GetModel("TFYDETAIL")

					lRet := lRet .AND.  oMdlTFV:SetValue("TFV_AGRUP", "1")
					lRet := lRet .AND. oMdlTFV:SetValue("TFV_HREXTR", "1")
					lRet := lRet .AND. oMdlTFV:SetValue("TFV_MEDAGI", "1")
					If lRet
						For nX := 1 To oMdlMed:Length()
							oMdlMed:GoLine(nX)
							If oMdlMed:GetValue("MED_MARK") .AND. oMdlMed:GetValue("MED_VALAPU") > 0
								nPosTFL	:= ASCAN( aCalcIt, { |x| x[1] == oMdlMed:GetValue("MED_CODTFL") } )
								If nPosTFL > 0
									For nZ := 2 To Len(aCalcIt[nPosTFL])
										If aCalcIt[nPosTFL][nZ][6] == "RH"
											If oMdlTFW:SeekLine({{ "TFW_CODTFF", aCalcIt[nPosTFL][nZ][1] }},,.T. )
												lRet := lRet .AND. oMdlTFW:SetValue("TFW_VLRMED", aCalcIt[nPosTFL][nZ][5])
											EndIf
										EndIf
										If aCalcIt[nPosTFL][nZ][6] == "MI"
											If oMdlTFX:SeekLine({{ "TFX_CODTFG", aCalcIt[nPosTFL][nZ][1] }},,.T. )
												lRet := lRet .AND. oMdlTFX:SetValue("TFX_VLRMED", aCalcIt[nPosTFL][nZ][5])
											EndIf
										EndIf
										If aCalcIt[nPosTFL][nZ][6] == "MC"
											If oMdlTFY:SeekLine({{ "TFY_CODTFH", aCalcIt[nPosTFL][nZ][1] }},,.T. )
												lRet := lRet .AND. oMdlTFY:SetValue("TFY_VLRMED", aCalcIt[nPosTFL][nZ][5])
											EndIf
										EndIf
										If !lRet
											Exit
										EndIf
									Next nZ
								EndIf
								If oMdlTWB:SeekLine({{ "TWB_CODTFL", oMdlMed:GetValue("MED_CODTFL") }},,.T. )
									lRet := lRet .AND. oMdlTWB:SetValue("TWB_CLIENT", oMdlMed:GetValue("MED_CLIENT"))
									lRet := lRet .AND. oMdlTWB:SetValue("TWB_LOJA", oMdlMed:GetValue("MED_LOJA"))
								EndIf
							EndIf
						Next nX
						If ExistBlock("At930ACm")
							lRet := ExecBlock("At930ACm",.F.,.F., {oModel, oMdl930} )
						EndIf
						oMDl930A := oModel
						If !lRet .OR. !Commit930( @oMdl930 )
							lRet := .F.
							aErroMVC := oMdl930:GetErrorMessage()
							If !Empty(aErroMVC[6])
								CargaErroM(@aErrors, aErroMVC)
							EndIf	
							DisarmTransacation()
						EndIf
					Else
						aErroMVC := oMdl930:GetErrorMessage()
						If !Empty(aErroMVC[6])
							CargaErroM(@aErrors, aErroMVC)
						EndIf	
						DisarmTransacation()
					EndIf
					oMdl930:DeActivate()
					oMdl930:Destroy()
					FWModelActive(oModel)
				EndIf
			Else
				lRet := .F.
				Help(,,'At930ACmt',,STR0049,1,0) //"Não é possivel salvar, por favor selecione uma planilha e insira um valor."
			EndIf
		EndIf
	End Transaction
	If !EMPTY(aErrors)
		For nX := 1 To LEN(aErrors)
			For nZ := 1 To LEN(aErrors[nX])
				cMsg += If(Empty(aErrors[nX][nZ]), aErrors[nX][nZ], aErrors[nX][nZ] + CRLF )
			Next
			cMsg += CRLF + REPLICATE("-",30) + CRLF
		Next
		If !ISBlind()
			AtShowLog(cMsg,STR0026,/*lVScroll*/,/*lHScroll*/,/*lWrdWrap*/,.F.)	//"Inclusão da Apuração"
		EndIf
	EndIf
Else
	lRet := .F.
	Help(,,"At930ACmt",, STR0057,1,0) // "Nenhum valor foi preenchido nas planilhas a serem medidas."
EndIf

AT930SPAR4("")

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Commit930
@description commit do teca930.
@return lRet
@author Augusto Albuquerque
@since  25/11/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Commit930( oMdl930, lThread )
Local lRet	:= .T.

Default lThread := .F.

If !lThread
	MsgRun( STR0015, STR0016, {|| lRet := oMdl930:VldData() .AND. oMdl930:CommitData() } ) // "Processando" ## "Aguarde"
Else
	lRet := oMdl930:VldData() .AND. oMdl930:CommitData()
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TotApurac
@description Função para contar o totais e preencher o valor na campo TOT_SALDO na view e deleção.
@return lRet
@author Augusto Albuquerque
@since  25/11/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function TotApurac( cCodApurac, cCodTFL )
Local cQuery	:= ""
Local cAliasTWB	:= GetNextAlias()
Local nRet		:= 0

cQuery := ""
cQuery += " SELECT TFW_VLRMED "
cQuery += " FROM " + RetSqlName("TFW") + " TFW "
cQuery += " WHERE TFW.TFW_FILIAL = '" + xFilial("TFW") + "' "
cQuery += " AND TFW.TFW_CODTFL = '" + cCodTFL + "' "
cQuery += " AND TFW.TFW_APURAC = '" + cCodApurac + "' "
cQuery += " AND TFW.D_E_L_E_T_ = ' ' "

cQuery += " UNION ALL"

cQuery += " SELECT TFX_VLRMED " 
cQuery += " FROM " + RetSqlName("TFX") + " TFX " 
cQuery += " WHERE TFX.TFX_FILIAL = '" + xFilial("TFX") + "' " 
cQuery += " AND TFX.TFX_CODTFL = '" + cCodTFL + "' "
cQuery += " AND TFX.TFX_APURAC = '" + cCodApurac + "' "
cQuery += " AND TFX.D_E_L_E_T_ = ' ' "

cQuery += " UNION ALL"

cQuery += " SELECT TFY_VLRMED "
cQuery += " FROM " + RetSqlName("TFY") + " TFY "
cQuery += " WHERE TFY.TFY_FILIAL = '" + xFilial("TFY") + "' "
cQuery += " AND TFY.TFY_CODTFL = '" + cCodTFL + "' "
cQuery += " AND TFY.TFY_APURAC = '" + cCodApurac + "' "
cQuery += " AND TFY.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTWB, .F., .T.)

While !((cAliasTWB)->(EOF()))
	nRet += (cAliasTWB)->(TFW_VLRMED) 
	(cAliasTWB)->(dbSkip())
EndDo
(cAliasTWB)->(dbCloseArea())

Return nRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CalcTotApu
@description Função para contar o totais e preencher o valor na campo TOT_SALDO
@return lRet
@author Augusto Albuquerque
@since  25/11/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function CalcTotApu(oModel)
Local oMdlTOT	:= oModel:GetModel("TOTMASTER")
Local oMdlMED	:= oModel:GetModel("MEDDETAIL")
Local nLineBckp := oMdlMed:GetLine()
Local nTot		:= 0
Local nX

For nX := 1 To oMdlMed:Length()
	oMdlMed:GoLine(nX)
	nTot += oMdlMed:GetValue("MED_VALAPU")
Next nX
oMdlTOT:LoadValue("TOT_SALDO", nTot)

oMdlMed:GoLine(nLineBckp)

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At930AF10
@description Função ao clicar F10
@return lRet
@author Augusto Albuquerque
@since  25/11/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930AF10()

IF !(isInCallStack("AT930View") .OR. isInCallStack("AT930Estor") )
	FwMsgRun(Nil,{|| AT930ABus2()}, Nil, STR0027) //"Buscando Informações..."
EndIf

Return 

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CargaErroM
@description Preencher o Array aErrors
@return lRet
@author Augusto Albuquerque
@since  25/11/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static function CargaErroM(aErrors, aErroMVC)
AADD(aErrors, {	 STR0028 + ' [' + AllToChar( aErroMVC[1] ) + ']',;	//"Id do formulário de origem:"
									 STR0029 + ' [' + AllToChar( aErroMVC[2] ) + ']',;	//"Id do campo de origem:"
									 STR0030 + ' [' + AllToChar( aErroMVC[3] ) + ']',;	//"Id do formulário de erro:"
									 STR0031 + ' [' + AllToChar( aErroMVC[4] ) + ']',;	//"Id do campo de erro:"
									 STR0032 + ' [' + AllToChar( aErroMVC[5] ) + ']',;	//"Id do erro:"
									 STR0033 + ' [' + AllToChar( aErroMVC[6] ) + ']',;	//"Mensagem do erro:"
									 STR0034 + ' [' + AllToChar( aErroMVC[7] ) + ']',;	//"Mensagem da solução:"
									 STR0035 + ' [' + AllToChar( aErroMVC[8] ) + ']',;	//"Valor atribuído:"
									 STR0036 + ' [' + AllToChar( aErroMVC[9] ) + ']';	//"Valor anterior:"
									 })
Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT930AMunc
@description Gatilho do campo FIL_ESTADO para travar o campo de codigo caso limpe o campo
@return lRet
@author Augusto Albuquerque
@since  26/11/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT930AMunc( cEstado )
Local oMdlFull 	:= FwModelActive()
Local oMdlFIL 	:= oMdlFull:GetModel('FILMASTER')

If Empty( cEstado )
	oMdlFIL:LoadValue("FIL_CODMUN", "")
	AT930ALiFil({"FIL_CODMUN"}, .F., Nil, .T.)
Else
	AT930ALiFil({"FIL_CODMUN"}, .T., Nil, .T.)
EndIf

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT930AMunc
@description Gatilho do campo FIL_ESTADO para travar o campo de codigo caso limpe o campo
@return lRet
@author Augusto Albuquerque
@since  26/11/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930AStaCo()
Local cRet 		:= ""
Local lMonitor	:= FWIsInCallStack("ApurJobAux")

If !lMonitor
	If cCompet <> Nil .AND. !Empty(cCompet)
		cRet := cCompet
	Else
		cRet := '1'
	EndIf
Else
	cRet := GetGlbValue(cVarThread + "COMPET")	
EndIf

Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT930ATrCl
@description Aberta tela para selecionar o cliente e loja e replicar para os locais selecionados.
@return lRet
@author Augusto Albuquerque
@since  26/11/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT930ATrCl( oModel )
Local cCliente 		:= "" + Space(TamSX3("CXN_CLIENT")[1])+ ""
Local cLoja 		:= "" + Space(TamSX3("CXN_LJCLI")[1])+ ""
Local lRet 			:= .T.
Local oDlgSelect	:= Nil
Local oRefresh		:= Nil
Local oExit			:= Nil
Local oMdlMED		:= oModel:GetModel("MEDDETAIL")
Local cContrato		:= oModel:GetModel("CNTMASTER"):GetValue("CNT_NUMERO")
Local cRevisa		:= oModel:GetModel("CNTMASTER"):GetValue("CNT_REVISA")
Local oView			:= Nil
Local nX
Local nLineBckp		:= 0

If !Empty(cContrato) .AND. !oMdlMED:IsEmpty()
	DEFINE MSDIALOG oDlgSelect FROM 0,0 TO 150,180 PIXEL TITLE STR0011 //"Cliente"
		@ 5, 9 SAY STR0011 SIZE 50, 30 PIXEL // "Cliente"

		oNameLike := TGet():New( 015, 009, { | u | If(PCount() > 0, cCliente := u, cCliente) },oDlgSelect, ;
							075, 010, "!@",, 0, 16777215,,.F.,,.T.,,.F.,;
							,.F.,.F.,{|| .T.},.F.,.F. ,,"cCliente",,,,.T.  )
		oNameLike:cF3 := 'CNC001'

		@ 30, 9 SAY STR0012 SIZE 60, 30 PIXEL //"Loja"

		oNameLike := TGet():New( 40, 009, { | u | If(PCount() > 0, cLoja := u, cLoja) },oDlgSelect, ;
							75, 10, "!@",, 0, 16777215,,.F.,,.T.,,.F.,;
							,.F.,.F.,{|| .T.},.F.,.F. ,,"cLoja",,,,.T.  )
		oExit := TButton():New( 058	, 055, STR0045,oDlgSelect,{|| lRet := .F., oDlgSelect:End() }, 30,10,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Sair"

		oRefresh := TButton():New( 058, 010, STR0046,oDlgSelect,{|| SubCLiok(oDlgSelect, cContrato, cRevisa, cCliente, cLoja)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Confirma" ## "Realizando manutenção"

	ACTIVATE MSDIALOG oDlgSelect CENTER

	IF lRet .AND. !(Empty(cCliente) .OR. Empty(cLoja))
		oView := FwViewActive()
		nLineBckp := oMdlMED:GetLine()
		For nX := 1 To oMdlMED:Length()
			oMdlMED:GoLine(nX)
			If oMdlMED:GetLine("MED_MARK")
				oMdlMED:LoadValue("MED_CLIENT", cCliente)
				oMdlMED:LoadValue("MED_LOJA", cLoja)
			EndIf
		Next nX
		oMdlMED:GoLine(nLineBckp)
		If !IsBlind()
			oView:Refresh()
		EndIf
	EndIF
EndIf

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SubCLiok
@description validar se o cliente e loja estão selecionadas de acordo com o contrato.
@return lRet
@author Augusto Albuquerque
@since  30/11/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function SubCLiok(oDlgSelect, cContrato, cRevisa, cClient, cLoja)

CNC->(dbSetOrder(3))

If (Empty(cClient) .OR. Empty(cLoja)) .OR. !(CNC->(MSSeek(xFilial("CNC")+cContrato+cRevisa+cClient+cLoja)))
	MsgInfo(STR0047) //"Por favor selecionar um cliente ou uma loja, valido."
Else
	oDlgSelect:End()
EndIf

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tec930ACam
@description Executar ponto de entrada para retornar os campos a serem adicionados
@return aRet
@author Augusto Albuquerque
@since  08/12/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Tec930ACam( cTipo )
Local aRet	:= {}

If ExistBlock("At930ACa")
	aRet := ExecBlock("At930ACa",.F.,.F., {cTipo} )
EndIf

Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At930AGMdl
@description Retorna a Variavel Static do Modelo do Teca930A
@return oMdl930A
@author Augusto Albuquerque
@since  05/01/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930AGMdl()
Return oMdl930A

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At930AVldC
@description Valida o numero do contrato
@return lRet
@author Augusto Albuquerque
@since  06/01/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930AVldC(oMdl, cCampo, xValue)
Local lRet 		:= .T.
Local lMonitor	:= FWIsInCallStack("At930MoApu")

If !Empty( xValue )
	lRet := ExistCpo("CN9",xValue+"05",7)
	If lRet .And. lMonitor .And. GetGlbValue(xValue) == '1'
		lRet := .F.
		oMdl:GetModel():SetErrorMessage(oMdl:GetId(),STR0062,oMdl:GetModel():GetId(),STR0062,STR0062,;
			STR0063, STR0064 ) //"Contrato"#"Contrato está sendo processado!"#"Selecione outro contrato ou aguarde a medição ser finalizada!"
	EndIf
	If lRet
		If !At740Recor(xValue) .AND. TecVlPrPar()
			cRevisa := Posicione("CN9",7,xFilial("CN9")+xValue+"05","CN9_REVISA")
			lRet := VlrProxPar( xValue, cRevisa)
		EndIf
	EndIf
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT930AMark
@description Valid do campo Mark
@return lRet
@author Augusto Albuquerque
@since  08/01/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT930AMark(oMdlMED,cField,xNewValue)
Local aCompets	:= {}//CtrCompets()
Local oModel 	:= oMdlMED:GetModel()
Local oMdlCNT	:= oModel:GetModel("CNTMASTER")
Local cContra	:= oMdlCNT:GetValue("CNT_NUMERO")
Local cRevisa	:= oMdlCNT:GetValue("CNT_REVISA")
Local cNumPla	:= oMdlMED:GetValue("MED_NUMPLA")
Local cCNDCompe := AllTrim( oMdlCNT:GetValue("CNT_COMPET") )
Local cProMed	:= ""
Local dProMed	:= SToD("")	
Local lRet 		:= .T.
Local lRecorre	:= At740Recor(cContra) 	
Local nX		

If cField == 'MED_MARK' .AND. xNewValue
	If !lRecorre
		aCompets := CtrCompets()
		dProMed := Posicione("CNA",1,xFilial("CNA")+cContra+cRevisa+cNumPla,"CNA_PROMED")
		cProMed := StrZero( Month( dProMed ), 2 ) + "/" + CValToChar( Year( dProMed ) )

		
		For nX := 1 To Len(aCompets)
			If Val(cCNDCompe) == nX
				cCNDCompe := aCompets[nX]
				Exit
			EndIf
		Next nX
		If AllTrim( cProMed ) <> cCNDCompe
			lRet := .F.
			If lMostraHelp
				Help(,,"AT930AMED",, STR0050 + cProMed,1,0) //"Para marcar a planilha recorrente é necessário mudar a competência para "
				lMostraHelp := .F.
			EndIf
		Endif
	EndIf
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VlrProxPar
@description Verifica se usa a Pro-Rata
@return lRet
@author Augusto Albuquerque
@since  08/01/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function VlrProxPar( cContrato, cRevisa)
Local cQuery	:= ""
Local cAliasTFL	:= GetNextAlias()
Local lRet		:= .T.
Local nTotParc	:= 0
Local nTotPag	:= 0

cQuery := ""
cQuery += " SELECT TFL.TFL_TOTRH, TFL.TFL_TOTMI, TFL.TFL_TOTMC, TFL_VLPRPA "
cQuery += " FROM " + RetSqlName("TFL") + " TFL "
cQuery += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
cQuery += " ON  TFL.TFL_CODPAI = TFJ.TFJ_CODIGO  "
cQuery += " AND TFJ.D_E_L_E_T_ = ' ' "
cQuery += " AND TFJ.TFJ_STATUS = '1' "
cQuery += " AND TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' "
cQuery += " WHERE TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
cQuery += " AND TFL.TFL_CONTRT = '" + cContrato + "' "
cQuery += " AND TFL.TFL_CONREV = '" + cRevisa + "' "
cQuery += " AND TFL.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTFL, .F., .T.)

If !((cAliasTFL)->(EOF()))
	while !((cAliasTFL)->(EOF()))
		nTotParc := (cAliasTFL)->(TFL_VLPRPA)
		nTotPag := (cAliasTFL)->(TFL_TOTRH) + (cAliasTFL)->(TFL_TOTMI) + (cAliasTFL)->(TFL_TOTMC)
		If nTotParc <> 0 .AND. nTotPag <> nTotParc
			lRet := .F.
			Help(,,"At930AVldC",, STR0051,1,0) //"Não é possivel utilizar apuração agil com Pro-Rata configurado."
			Exit
		EndIf
		(cAliasTFL)->(dbSkip())
	EndDo
Else
	lRet := .F.
	Help(,,"At930AVldC",, STR0052,1,0) // "Não foi possivel localizar o contrato ativo, sem revisão em andamento."
EndIf

(cAliasTFL)->(dbCloseArea())

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SaldCNB
@description Saldo da planilha de acordo com a CNB
@return lRet
@author Augusto Albuquerque
@since  11/01/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function SaldCNB( cContra, cRevisa, cPla)
Local cQuery 	:= ""
Local cAliasCNB	:= GetNextAlias()
Local nRet		:= 0
Local nAux		:= 0

cQuery := ""
cQuery += " SELECT CNB.CNB_ITEM, CNB.CNB_SLDMED, CNB.CNB_VLUNIT "
cQuery += " FROM " + RetSqlName("CNB") + " CNB "
cQuery += " WHERE CNB.CNB_FILIAL = '" + xFilial("CNB") + "' "
cQuery += " AND CNB.CNB_CONTRA = '" + cContra + "' "
cQuery += " AND CNB.CNB_REVISA = '" + cRevisa + "' "
cQuery += " AND CNB.CNB_NUMERO = '" + cPla + "' "
cQuery += " AND CNB.CNB_ATIVO = '1' "
cQuery += " AND CNB.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasCNB, .F., .T.)

If !((cAliasCNB)->(EOF()))
	while !((cAliasCNB)->(EOF()))
		nSaldo := (cAliasCNB)->(CNB_SLDMED) - Cn121QtdBlq(cContra,cRevisa,cPla,(cAliasCNB)->(CNB_ITEM))
		nVlUnit := (cAliasCNB)->(CNB_VLUNIT)
		nAux := nSaldo * nVlUnit
		nRet += nAux
		(cAliasCNB)->(dbSkip())
	EndDo
EndIf

(cAliasCNB)->(dbCloseArea())

Return nRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CodMedicao
@description Retorna o codigo da apuração 
@return cRet
@author Augusto Albuquerque
@since  12/01/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function CodMedicao( cCodApu )
Local aArea		:= GetArea()
Local cQuery	:= ""
Local cRet		:= ""
Local cAliasMED	:= GetNextAlias()

cQuery := ""
cQuery += " SELECT TFW.TFW_NUMMED, TFX.TFX_NUMMED, TFY.TFY_NUMMED "
cQuery += " FROM " + RetSqlName("TWB") + " TWB "
cQuery += " LEFT JOIN " + RetSqlName("TFW") + " TFW "
cQuery += " ON TWB.TWB_CODTFV = TFW.TFW_APURAC "
cQuery += " AND TFW.TFW_FILIAL = '" + xFilial("TFW") + "' "
cQuery += " AND TFW.D_E_L_E_T_ = ' ' "
cQuery += " LEFT JOIN " + RetSqlName("TFX") + " TFX "
cQuery += " ON TFX.TFX_APURAC = TWB.TWB_CODTFV "
cQuery += " AND TFX.TFX_FILIAL = '" + xFilial("TFX") + "' "
cQuery += " AND TFX.D_E_L_E_T_ = ' ' "
cQuery += " LEFT JOIN " + RetSqlName("TFY") + " TFY "
cQuery += " ON TFY.TFY_APURAC = TWB.TWB_CODTFV "
cQuery += " AND TFY.TFY_FILIAL = '" + xFilial("TFY") + "' "
cQuery += " AND TFY.D_E_L_E_T_ = ' ' "
cQuery += " WHERE TWB.TWB_CODTFV = '" + cCodApu + "' "
cQuery += " AND TWB.TWB_FILIAL = '" + xFilial("TWB") + "' "
cQuery += " AND TWB.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY TFW.TFW_NUMMED, TFX.TFX_NUMMED, TFY.TFY_NUMMED "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasMED, .F., .T.)

If !((cAliasMED)->(EOF()))
	If !Empty((cAliasMED)->(TFW_NUMMED))
		cRet := (cAliasMED)->(TFW_NUMMED)
	ElseIf !Empty((cAliasMED)->(TFX_NUMMED))
		cRet := (cAliasMED)->(TFX_NUMMED)
	ElseIf !Empty((cAliasMED)->(TFY_NUMMED))
		cRet := (cAliasMED)->(TFY_NUMMED)
	EndIf 
EndIf

(cAliasMED)->(dbCloseArea())

RestArea(aArea)

Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CronogFina
@description Retorna se o contrato tem cronograma financeiro
@return lRet
@author Augusto Albuquerque
@since  15/01/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function CronogFina( cContra )
Local cQuery	:= ""
Local cAliasCnf	:= GetNextAlias()
Local lRet 		:= .F.

cQuery := ""
cQuery += " SELECT 1 "
cQuery += " FROM " + RetSqlName("CNF") + " CNF "
cQuery += " WHERE CNF.CNF_FILIAL = '" + xFIlial("CNF") + "' "
cQuery += " AND CNF.CNF_CONTRA = '" + cContra + "' "
cQuery += " AND CNF.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasCnf, .F., .T.)

If !((cAliasCnf)->(EOF()))
	lRet := .T.
EndIF
(cAliasCnf)->(dbCloseArea())

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At930Agrup
	Verifica se o contrato foi criado agrupado ou desagrupado

@sample At930Agrup(cContrato,cRevisa)

@author	Luiz Gabriel
@since		17/08/2021
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function At930Agrup(cContrato,cRevisa)
Local lDsgCN 		:= .F.
Local cAliasTFL		:= GetNextAlias()

BeginSql Alias cAliasTFL

	SELECT TFJ.TFJ_DSGCN
  	  FROM %table:TFL% TFL
	       JOIN %table:ABS% ABS ON ABS.ABS_FILIAL = %xFilial:ABS%
	                           AND ABS.ABS_LOCAL = TFL.TFL_LOCAL
	                           AND ABS.%NotDel%
	       JOIN %table:TFJ% TFJ ON TFJ.TFJ_FILIAL = %xFilial:TFJ%
	                           AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI
	                           AND TFJ.%NotDel%
	 WHERE TFL.TFL_FILIAL = %xFilial:TFL%
	   AND TFL.TFL_CONTRT = %Exp:cContrato%
	   AND TFL.TFL_CONREV = %Exp:cRevisa%
	   AND TFL.%NotDel%

EndSql

If (cAliasTFL)->(!Eof())
	lDsgCN := (cAliasTFL)->(TFJ_DSGCN) == '1'
EndIf

(cAliasTFL)->(dBCloseArea())

Return lDsgCN

//------------------------------------------------------------------------------
/*/{Protheus.doc} PrepMultTh
	Função que prepara para o mult-thread, faz a quebra de acordo com os parametros e inicia o job

@sample PrepMultTh(oModel)
@author	Luiz Gabriel
@since		29/07/2021
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function PrepMultTh(oModel)
LOcal aProcs	:= {}
Local lRet		:= .T.
Local oMdlCNT 	:= oModel:GetModel("CNTMASTER")
Local oMdlMED	:= oModel:GetModel("MEDDETAIL")
Local oMdlTOT	:= oModel:GetModel("TOTMASTER")
Local lTotValor	:= oMdlTOT:GetValue("TOT_SALDO") > 0
Local cContrato	:= oMdlCNT:GetValue("CNT_NUMERO")
Local cRevisao	:= oMdlCNT:GetValue("CNT_REVISA")
Local aMed		:= {}
Local nTotalReg	:= 0
Local nNumProc	:= 1
Local cCompet	:= oMdlCNT:GetValue("CNT_COMPET")
Local nValApur 	:= oMdlCNT:GetValue("CNT_VALAPUR") 


aMed	:= At930aMed(oMdlMED)
nTotalReg 	:= Len(aMed)
aProcs := TecPrepMarc(nNumProc,nTotalReg)

//Inicializa as Threads Transação controlada nas Threads
StartJob("At930MaJob", GetEnvServer(), .F., cEmpAnt,cFilAnt,aProcs[1][1],;
		aProcs[1][3],__cUserId,cUserName,cAcesso,cUsuario,aProcs[1][2],;
		aProcs[1][4], cFilant, 1,aCalcIT,aMed,lTotValor,cContrato,cCompet,aMarks )

At930BContr(cContrato,cRevisao,nValApur,cContrato+aProcs[1][3])

return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecPrepMarc
	Função de quebra dos registro por trhead.

@sample TecPrepMarc(nNumProc,nTotalReg)
@author Luiz Gabriel
@since		29/07/2021
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function TecPrepMarc(nNumProc,nTotalReg)
Local aProcs 		:= Array(nNumProc)
Local nX		 	:= 0
Local cRaizNome		:= "TEC930APUR"
Local cDirSem  		:= "\Semaforo\"
Local cNomeArq		:= ""
Local cMarca  		:= ""
Local nRegAProc		:= 0 // Registros a processar
Local nRegJProc		:= 0 // Total de registros já processados
Local cVarStatus	:= ""

//Cria a pasta do semaforo caso não exista
If !ExistDir(cDirSem)
	MontaDir(cDirSem)
EndIf

//Realiza o calculos das quantidades de registros
//que cada thread irá processar                 
For nX := 1 to Len(aProcs)
	cNomeArq 	:= cDirSem + cRaizNome +cEmpAnt + cFilAnt +cValtoChar(nX)+cValtoChar(INT(Seconds())) + '.lck'
	cMarca		:= GetMark()
	nRegAProc	:= IIf( nX == 1 , 1 , aProcs[nX-1,4]+1 )
	nRegJProc	+= IIf( nX == Len(aProcs), nTotalReg-nRegJProc, Int(nTotalReg / nNumProc) )
	cVarStatus  :="c930Ap"+cEmpAnt+cFilAnt+StrZero(nX,2)+cMarca
	PutGlbValue(cVarStatus,"0")
	GlbUnLock()
	aProcs[nX]	:= {cNomeArq,nRegAProc,cVarStatus,nRegJProc, cMarca}
Next nX

Return aProcs

//------------------------------------------------------------------------------
/*/{Protheus.doc} At930aMed
	Função que preenche o array com os dados do grid de medição

@sample At930aMed(oMdlMED)
@author	Luiz Gabriel
@since		29/07/2021
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function At930aMed(oMdlMED)
Local aMed		:= Array(oMdlMED:Length())
Local nX		:= 0
Local cCodTFL	:= ""
Local lMarca	:= .F.
Local nVlApu	:= 0
Local cClient	:= ""
Local cLoja		:= ""

For nX := 1 to Len(aMed)
	oMdlMed:GoLine(nX)
	cCodTFL 	:= oMdlMed:GetValue("MED_CODTFL")
	lMarca		:= oMdlMed:GetValue("MED_MARK")
	nVlApu		:= oMdlMed:GetValue("MED_VALAPU")
	cClient		:= oMdlMed:GetValue("MED_CLIENT")
	cLoja		:= oMdlMed:GetValue("MED_LOJA")
	aMed[nX]	:= {cCodTFL,lMarca,nVlApu,cClient,cLoja}
Next nX

Return aMed

//------------------------------------------------------------------------------
/*/{Protheus.doc} At930MaJob
	Função do mult-thread, processamento

@sample t930MaJob(cEmpX,cFilX,cFileLck,cVarStatus,cXUserId,cXUserName,cXAcesso,cXUsuario,;
					nIni, nFim, cFilTec, nThread,aCalcIT,aMed,lTotValor,cContrato,cCompet,aMarks)
@author	Luiz Gabriel
@since		29/07/2021
@version	P12
/*/
//------------------------------------------------------------------------------
Function At930MaJob(cEmpX,cFilX,cFileLck,cVarStatus,cXUserId,cXUserName,cXAcesso,cXUsuario,;
					nIni, nFim, cFilTec, nThread,aCalcIT,aMed,lTotValor,cContrato,cCompet,aMarks)
Local lRet		 := .T.
Local aPut		:= {}

Private cVarThread := cContrato + cVarStatus

Private lMsErroAuto 
Private lMsHelpAuto 
Private lAutoErrNoFile
Private Inclui 

Default nOpc := 3

//Abre o arquivo de Lock parao controle externo das threads?
AADD( aPut, {"Marc"})
// STATUS 1 - Iniciando execucao do Job
PutGlbValue(cVarStatus, "1" )
GlbUnLock()

PutGlbVars("Registros", aPut )

//Seta job para nao consumir licensas
RpcSetType(3)
RpcClearEnv()
// Seta job para empresa filial desejada
RpcSetEnv( cEmpX,cFilX,,,,,)

// STATUS 2 - Conexao efetuada com sucesso
PutGlbValue(cVarStatus, "2" )
GlbUnLock()

//Contrato sendo processado
PutGlbValue(cContrato, "1" )
GlbUnLock()

//Valor da Competencia
PutGlbValue(cVarThread + "COMPET", cCompet )
GlbUnLock()

//Set o usuario para buscar as perguntas do profile
lMsErroAuto := .F.
lMsHelpAuto := .T. 
lAutoErrNoFile := .T.
Inclui := .T.

__cUserId := cXUserId 
cUserName := cXUserName
cAcesso   := cXAcesso
cUsuario  := cXUsuario

//Realiza o processamento
PutGlbValue("Ini" + cValtoChar(nThread), cValtoChar(nIni) )
PutGlbValue("Fim" + cValtoChar(nThread), cValtoChar(nFim) )

lRet := At930AuxJob(cFilTec, nIni, nFim, nThread, cVarStatus, .F., nOpc, aCalcIT,aMed,lTotValor,cContrato,cCompet,aMarks)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At930AuxJob
	Função de processamento, envia as planilhas a serem medidas 

@sample At930AuxJob(cFilTec, nIni, nFim, nThread,cVarStatus, lPrincipal, nOpc,aCalcIT,aMed,;
							lTotValor,cContrato,cCompet,aMarks)
@author	Luiz Gabriel
@since		29/07/2021
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function At930AuxJob(cFilTec, nIni, nFim, nThread,cVarStatus, lPrincipal, nOpc,aCalcIT,aMed,;
							lTotValor,cContrato,cCompet,aMarks)
Local lRet 			:= .T.
Local aConcluido	:= {}
Local nX			:= 0
Local lMV_GSLOG 	:= SuperGetMV('MV_GSLOG',,.F.)
Local oGsLog		:= GsLog():New(lMV_GSLOG)

If GetGlbValue(cVarStatus) <> '3'
	aConcluido := ApurJobAux(nIni,nFim,aCalcIT,aMed,lTotValor,cContrato,cCompet,aMarks,nThread)
	If Len(aConcluido) > 0
		lRet := aConcluido[1]
		If !lRet .And. !Empty(aConcluido[2]) .And. lMV_GSLOG
			oGsLog:addLog("MonitorApur "+ cContrato, STR0061 ) //"Mensagem de Erro: "
			oGsLog:addLog("MonitorApur "+ cContrato, aConcluido[2] ) 
			oGsLog:printLog("MonitorApur "+ cContrato)
		EndIf
		ClearGlbValue( "Ini" + cValtoChar(nX) )
		ClearGlbValue( "Fim" + cValtoChar(nX) )
		ClearGlbValue(cVarStatus)
		ClearGlbValue(cContrato)
		ClearGlbValue("Registros")
		ClearGlbValue(cVarThread + "COMPET")
	Endif
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ApurJobAux
	Função de gravação das medições

@sample ApurJobAux(nIni, nFim,aCalcIT,aMed,lTotValor,cContrato,cCompet,aMarks)

@author	Luiz Gabriel
@since		29/07/2021
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function ApurJobAux(nIni, nFim,aCalcIT,aMed,lTotValor,cContrato,cCompet,aMarks,nThread)
Local oMdl930 	:= FwLoadModel("TECA930")
Local oMdlTWB	:= Nil
Local oMdlTFW	:= Nil 
Local oMdlTFX	:= Nil 
Local oMdlTFY	:= Nil 
Local oMDlTFV	:= Nil
Local cMsg		:= ""
Local nPosTFL	:= 0
Local lRet		:= .T.
Local nX		:= 0
Local nZ		:= 0
Local aRet		:= {}
Local aErroMVC	:= {}
Local aErrors	:= {}

oMDl930A := Nil

Pergunte("TEC930",.F.)
MV_PAR01	:= cContrato
MV_PAR02	:= dDataBase
MV_PAR03	:= dDataBase + 30
MV_PAR04	:= ""
MV_PAR05	:= 1

If lTotValor

	AT930SPAR4(CtrCompets()[Val(cCompet)])

	Begin Transaction
		If !Empty(cCompet) .AND. !Empty(aMarks) .AND. !Empty(aCalcIT)
			oMdl930:SetOperation(MODEL_OPERATION_INSERT)
			If oMdl930:Activate()
				oMdlTFV	:= oMdl930:GetModel("TFVMASTER")
				oMdlTWB	:= oMdl930:GetModel("TWBDETAIL")
				oMdlTFW	:= oMdl930:GetModel("TFWDETAIL")
				oMdlTFX	:= oMdl930:GetModel("TFXDETAIL")
				oMdlTFY	:= oMdl930:GetModel("TFYDETAIL")

				lRet := lRet .AND.  oMdlTFV:SetValue("TFV_AGRUP", "1")
				lRet := lRet .AND. oMdlTFV:SetValue("TFV_HREXTR", "1")
				lRet := lRet .AND. oMdlTFV:SetValue("TFV_MEDAGI", "1")
				If lRet
					For nX := nIni To nFim
						If aMed[nX][2] .AND. aMed[nX][3] > 0
							nPosTFL	:= ASCAN( aCalcIt, { |x| x[1] == aMed[nX][1] } )
							If nPosTFL > 0
								For nZ := 2 To Len(aCalcIt[nPosTFL])
									If aCalcIt[nPosTFL][nZ][6] == "RH"
										If oMdlTFW:SeekLine({{ "TFW_CODTFF", aCalcIt[nPosTFL][nZ][1] }},,.T. )
											lRet := lRet .AND. oMdlTFW:SetValue("TFW_VLRMED", aCalcIt[nPosTFL][nZ][5])
										EndIf
									EndIf
									If aCalcIt[nPosTFL][nZ][6] == "MI"
										If oMdlTFX:SeekLine({{ "TFX_CODTFG", aCalcIt[nPosTFL][nZ][1] }},,.T. )
											lRet := lRet .AND. oMdlTFX:SetValue("TFX_VLRMED", aCalcIt[nPosTFL][nZ][5])
										EndIf
									EndIf
									If aCalcIt[nPosTFL][nZ][6] == "MC"
										If oMdlTFY:SeekLine({{ "TFY_CODTFH", aCalcIt[nPosTFL][nZ][1] }},,.T. )
											lRet := lRet .AND. oMdlTFY:SetValue("TFY_VLRMED", aCalcIt[nPosTFL][nZ][5])
										EndIf
									EndIf
									If !lRet
										Exit
									EndIf
								Next nZ
							EndIf
							If oMdlTWB:SeekLine({{ "TWB_CODTFL", aMed[nX][1] }},,.T. )
								lRet := lRet .AND. oMdlTWB:SetValue("TWB_CLIENT", aMed[nX][4])
								lRet := lRet .AND. oMdlTWB:SetValue("TWB_LOJA", aMed[nX][5])
							EndIf
						EndIf
					Next nX
					If !lRet .OR. !Commit930( @oMdl930, .T. )
						lRet := .F.
						aErroMVC := oMdl930:GetErrorMessage()
						If !Empty(aErroMVC[6])
							CargaErroM(@aErrors, aErroMVC)
						EndIf	
						DisarmTransacation()
					EndIf
				Else
					aErroMVC := oMdl930:GetErrorMessage()
					If !Empty(aErroMVC[6])
						CargaErroM(@aErrors, aErroMVC)
					EndIf		
					DisarmTransacation()
				EndIf
				oMdl930:DeActivate()
				oMdl930:Destroy()
			EndIf
		Else
			lRet := .F.
			cMsg := STR0049
		EndIf
	End Transaction
Else
	lRet := .F.
	cMsg := STR0057
EndIf

If !EMPTY(aErrors)
	For nX := 1 To LEN(aErrors)
		For nZ := 1 To LEN(aErrors[nX])
			cMsg += If(Empty(aErrors[nX][nZ]), aErrors[nX][nZ], aErrors[nX][nZ] + CRLF )
		Next
		cMsg += CRLF + REPLICATE("-",30) + CRLF
	Next
EndIf

AADD( aRet,  lRet  )
AADD( aRet,  cMsg  )

AT930SPAR4("")

Return aRet
