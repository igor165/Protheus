#INCLUDE 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA930B.ch"

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

Static aDados	:= {}	//Array para popular o grid de contratos

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Definição do modelo de Dados

@author	Luiz Gabriel
@since 22/06/2020
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel	
Local oStrDAT		:= FWFormModelStruct():New()
Local oStrFIL		:= FWFormModelStruct():New()
Local aFields		:= {}
Local nX			:= 0
Local nY			:= 0
Local aTables 		:= {}
Local bCommit		:= { |oModel| At930BCmt( oModel )}

oStrDAT:AddTable("   ",{}, STR0001) //"Monitor de Apuração"
oStrFIL:AddTable("   ",{}, "   ")

AADD(aTables, {oStrDAT, "DAT"})
AADD(aTables, {oStrFIL, "ORC"})

For nY := 1 To LEN(aTables)
	aFields := AT930BTbl(aTables[nY][2])

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

oModel := MPFormModel():New('TECA930B',/*bPreValidacao*/,/*bPosValidacao*/,bCommit,/*bCancel*/)
oModel:AddFields('DATMASTER',/*cOwner*/,oStrDAT,,/*bPosValidacao*/,/*bFieldAbp*/,/*bCarga*/,/*bFieldTfl*/)

oModel:addGrid('ORCMASTER','DATMASTER',oStrFIL)

oModel:setDescription(STR0001) //"Monitor de Apuração"

oModel:SetPrimaryKey({'DAT_INI'})

oModel:GetModel('DATMASTER'):SetDescription(STR0001) //"Monitor de Apuração"
oModel:GetModel('ORCMASTER'):SetDescription(STR0002) //"Contratos"

oModel:GetModel('DATMASTER'):SetOnlyView(.T.)
oModel:GetModel('DATMASTER'):SetOnlyQuery(.T.)
oModel:GetModel('ORCMASTER'):SetOptional(.T.)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da interface

@author	Luiz Gabriel
@since 22/06/2020
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= Nil
Local oModel 	:= ModelDef()
Local oStrDAT	:= FWFormViewStruct():New()
Local oStrFIL	:= FWFormViewStruct():New()
Local aTables 	:= {}
Local aFields	:= {}
Local nX		:= 0
Local nY		:= 0

AADD(aTables, {oStrDAT, "DAT"})
AADD(aTables, {oStrFIL, "ORC"})

For nY := 1 to LEN(aTables)
	aFields := AT930BTbl(aTables[nY][2])

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

oStrFIL:RemoveField("ORC_VARSTA")

oView:AddField('VIEW_MASTER', oStrDAT, 'DATMASTER')

oView:AddGrid('VIEW_ORC',  oStrFIL, 'ORCMASTER')
oView:EnableTitleView('VIEW_ORC', STR0002) //"Contratos"

oView:CreateHorizontalBox('DATA',   10)
oView:CreateHorizontalBox('Contratos', 90)

oView:SetOwnerView('VIEW_MASTER','DATA')
oView:SetOwnerView('VIEW_ORC','Contratos')

oView:SetDescription(STR0001) // "Monitor de Apuração"

SetKey( VK_F8, { || At930BAtua() })
SetKey( VK_F12, { || At930BpuAg() })

oView:AddUserButton(STR0003,"",{|| At930BAtua()},,,) //"Atualizar(F8)"

oView:AddUserButton(STR0004,"",{|| At930BpuAg()},,,) //"Incluir Apuração(F12)"

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT930BTbl

@description Retorna em forma de Array as definições dos campos

@param cTable, string, define de qual tabela devem ser os campos retornados

@return aRet, array, definição dos campos

@author	Luiz Gabriel
@since	22/06/2020
/*/
//------------------------------------------------------------------------------
Function AT930BTbl(cTable)
Local aRet := {}
Local nAux := 0

If cTable == "DAT"  //Cabeçalho

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0005	//"Ultima Atualização"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0005	//"Ultima Atualização"
	aRet[nAux][DEF_IDENTIFICADOR] := "DAT_DTREF"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 22
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| dToc(dDataBase) + " " + Time()}
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0006}	//"Data de atualização"

ElseIf cTable == "ORC" //Contratos

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0007	//"Legenda"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0007	//"Legenda"
	aRet[nAux][DEF_IDENTIFICADOR] := "ORC_LEGEND"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "BT"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "BT"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_VALID] := {||At930BLeg()}
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "BR_VERDE"}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0008 // "Contrato"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0008 // "Contrato"
	aRet[nAux][DEF_IDENTIFICADOR] := "ORC_FILCTR"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("CN9_FILIAL")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0009}	//"Filial do Contrato"

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0010 // "Contrato"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0010 // "Contrato"
	aRet[nAux][DEF_IDENTIFICADOR] := "ORC_CTR"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("CN9_NUMERO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0011}	//"Contrato Apurado"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0012 // "Revisão"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0012 // "Revisão"
	aRet[nAux][DEF_IDENTIFICADOR] := "ORC_REVISA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("CN9_REVISA")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0013}	//"Revisão do contrato"

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0014 //"Valor Apurado"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0014 //"Valor Apurado"
	aRet[nAux][DEF_IDENTIFICADOR] := "ORC_VALAPUR"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 16
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 2
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "06"
	aRet[nAux][DEF_PICTURE] := "@E 9,999,999,999,999.99                      "
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0014}	//"Valor Apurado"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0015	//"Chave Thread
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0015	//"Chave Thread"
	aRet[nAux][DEF_IDENTIFICADOR] := "ORC_VARSTA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 40
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
    aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "07"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .F. 

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0016	//"Filial Medição
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0016//"Filial Medição"
	aRet[nAux][DEF_IDENTIFICADOR] := "ORC_FILMED"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("CND_FILIAL")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
    aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "08"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .F. 

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0017	//"Num. Medição
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0017	//"Num. Medição"
	aRet[nAux][DEF_IDENTIFICADOR] := "ORC_NUMMED"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("CND_NUMMED")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
    aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "09"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .F. 

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0018	//"Num. Apuracão
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0018	//"Num. Apuracão"
	aRet[nAux][DEF_IDENTIFICADOR] := "ORC_NUMAPUR"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFW_APURAC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
    aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "10"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .F. 

EndIf

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At930BLeg

@description Cria as informações referentes a legenda do grid da Apuração

@author	Luiz Gabriel
@since 10/08/2021
/*/
//------------------------------------------------------------------------------
Function At930BLeg()

Local oLegABB := FwLegend():New()

oLegABB:Add( "", "BR_AMARELO" 	, STR0019 )	//"Processando..."
oLegABB:Add( "", "BR_VERMELHO" 	, STR0020 )	//""Apuração com Erro"
oLegABB:Add( "", "BR_VERDE"	    , STR0021 ) //"Apuração Finalizada"

oLegABB:View()

DelClassIntf()

Return (.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At930BAtua
@description Atualização da rotina
@return lRet
@author	Luiz Gabriel
@since 10/08/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930BAtua()
Local oModel    := FwModelActive()
Local oView 	:= FwViewActive()
Local oMdlDat   := Nil
Local cTime     := ""
Local nX		:= 0
Local oMdlGrd	:= Nil
Local nLinha	:= 0

If ValType(oModel)=='O' .and. oModel:GetId()== 'TECA930B'
    oMdlDat := oModel:GetModel('DATMASTER')
    cTime     := dToc(dDataBase) + " " + Time()
    oMdlDat:LoadValue("DAT_DTREF", cTime)

	oMdlGrd := oModel:GetModel("ORCMASTER")

	If !oMdlGrd:IsEmpty()
		nLinha	:= oMdlGrd:Length()
		For nX := 1 To nLinha
			 oMdlGrd:GoLine(nX)
			 If GetGlbValue(oMdlGrd:GetValue("ORC_CTR")) <> '1' 
			 	At930VarSta(oMdlGrd)
			 EndIf
		Next nX
		oMdlGrd:GoLine(1)
	EndIf

EndIf

If !IsBlind() .AND. VALTYPE(oView) == "O"
	oView:Refresh()
EndIf

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At930BpuAg
@description Realiza a abertura da apuração agil e atualiza o grid com os dados
@return lRet
@author	Luiz Gabriel
@since 10/08/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930BpuAg()
Local lRet 		:= .T.
Local oModel    := FwModelActive()
Local oView 	:= FwViewActive()
Local nLinha	:= 1
Local nX		:= 0
Local oMdlCTR	:= oModel:GetModel("ORCMASTER")

aDados := {}

//Abre a rotina de apuração agil
At930ApuAg()

//Desabilita o F10 criado no TECA930A
SetKey(VK_F10,Nil)

If Len(aDados) > 0
	//Informa a medição incluido no grid de contrato
	If !oMdlCTR:IsEmpty()
		nLinha := oMdlCTR:AddLine()
	EndIf

	oMdlCTR:GoLine(nLinha)

	For nX := 1 To Len(aDados)
		oMdlCTR:LoadValue(aDados[nX][1],aDados[nX][2])
	Next nX

	If !IsBlind() .AND. VALTYPE(oView) == "O"
		oMdlCTR:GoLine(1)
		oView:Refresh()
	EndIf
EndIf	

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At930BContr
@description Preenche a array aDados para utilização no preenchimento do grid
@return lRet
@author	Luiz Gabriel
@since 10/08/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930BContr(cContrato,cRevisao,nValApur,cVarStatus)
Local lRet	:= .T.

aAdd(aDados,{"ORC_LEGEND","BR_AMARELO"})
aAdd(aDados,{"ORC_FILCTR",xFilial("CN9")})
aAdd(aDados,{"ORC_CTR",cContrato})
aAdd(aDados,{"ORC_REVISA",cRevisao})
aAdd(aDados,{"ORC_VALAPUR",nValApur})
aAdd(aDados,{"ORC_VARSTA",cVarStatus})

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At930bStatus
@description Preenche a variavel global com as informações de filial e numero da medição para utilização
na atualização do status
@return
@author	Luiz Gabriel
@since 10/08/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930bStatus(cVarStatus,cFilMed,cNumMed)

//Chave da thread
PutGlbValue(cVarStatus, cFilMed + cNumMed )
GlbUnLock()

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At930VarSta
@description Ao Atualizar a tela verifica se o contrato já foi processado e verifica se já foi finalizado ou está com
erro
@return
@author	Luiz Gabriel
@since 10/08/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At930VarSta(oMdlGrd)
Local cQuery	:= ""
Local cAliasMED	:= GetNextAlias()
Local cChaveMed := GetGlbValue(Alltrim(oMdlGrd:GetValue("ORC_VARSTA")))
Local cFilMed	:= Substr(cChaveMed,1,TamSX3("CND_FILIAL")[1]) 
Local cNumMed	:= Substr(cChaveMed,TamSX3("CND_FILIAL")[1]+1,TamSX3("CND_NUMMED")[1])
Local cContra	:= oMdlGrd:GetValue("ORC_CTR")

cQuery += " SELECT CND.CND_NUMMED,TFW_APURAC "
cQuery += " FROM " + RetSqlName("CND") + " CND "
cQuery += " INNER JOIN " + RetSqlName("TFW") + " TFW "
cQuery += " ON TFW.TFW_FILIAL = '" + xFilial("TFW") + "' "
cQuery += " AND TFW.TFW_NUMMED = CND.CND_NUMMED "
cQuery += " AND TFW.D_E_L_E_T_ = ' ' "
cQuery += " WHERE CND.CND_FILIAL = '" + cFilMed + "' "
cQuery += " AND CND.CND_NUMMED = '" + cNumMed + "' "
cQuery += " AND CND.CND_CONTRA = '" + cContra + "' "
cQuery += " AND CND.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasMED, .F., .T.)

If !((cAliasMED)->(EOF()))
	oMdlGrd:LoadValue("ORC_LEGEND","BR_VERDE")
	oMdlGrd:LoadValue("ORC_FILMED",cFilMed)
	oMdlGrd:LoadValue("ORC_NUMMED",cNumMed)
	oMdlGrd:LoadValue("ORC_NUMAPUR",(cAliasMED)->TFW_APURAC)
Else
	oMdlGrd:LoadValue("ORC_LEGEND","BR_VERMELHO")
EndIF

(cAliasMED)->(dbCloseArea())

ClearGlbValue(cChaveMed)

Return
