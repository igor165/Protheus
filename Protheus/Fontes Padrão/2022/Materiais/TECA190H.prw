#INCLUDE 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA190H.CH"

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

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA190H - Mesa Operacional - Compensação
 	ModelDef
 		Definição do modelo de Dados

@author	boiani
@since	29/06/2020
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oStrAA1	:= FWFormModelStruct():New()
Local oStrDTA	:= FWFormModelStruct():New()
Local aTables 	:= {}
Local nX        := 0
Local nY        := 0
Local bCommit	:= { |oModel| AT190HCmt( oModel ) }
Local bValid := { |oModel| AT190hVld( oModel ) }

oStrAA1:AddTable("   ",{}, STR0001) //"Compensação"
oStrDTA:AddTable("   ",{}, "   ")

AADD(aTables, {oStrAA1, "AA1"})
AADD(aTables, {oStrDTA, "DTA"})

For nY := 1 To LEN(aTables)
	aFields := AT190HDef(aTables[nY][2])

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

xAux := FwStruTrigger( 'AA1_CODTEC', 'AA1_NOMTEC',;
	'Posicione("AA1",1,xFilial("AA1") + FwFldGet("AA1_CODTEC"),"AA1_NOMTEC")', .F. )
	oStrAA1:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'DTA_DTCOMP', 'DTA_DSCOMP',;
	'TECCdow(DOW(STOD(DToS(FwFldGet("DTA_DTCOMP")))))', .F. )
	oStrDTA:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'DTA_DTTRAB', 'DTA_DSTRAB',;
	'TECCdow(DOW(STOD(DToS(FwFldGet("DTA_DTTRAB")))))', .F. )
	oStrDTA:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

oModel := MPFormModel():New('TECA190H',/*bPreValidacao*/,bValid,bCommit,/*bCancel*/)
oModel:SetDescription( STR0001 ) //"Compensação"

oModel:addFields('AA1MASTER',,oStrAA1)
oModel:SetPrimaryKey({"AA1_CODTEC"})

oModel:addGrid('DTADETAIL','AA1MASTER', oStrDTA, {|oMdlG,nLine,cAcao,cCampo, xValue, xOldValue| PrelinDTA(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)})

oModel:GetModel('DTADETAIL'):SetOnlyQuery(.T.)
oModel:GetModel('DTADETAIL'):SetOptional(.T.)

oModel:GetModel('AA1MASTER'):SetDescription(STR0002) //"Atendente"
oModel:GetModel('DTADETAIL'):SetDescription(STR0003) //"Datas de Compensação"

oModel:SetActivate( {|oModel| InitDados( oModel ) } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da interface

@author	boiani
@since 29/06/2020
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 		:= ModelDef()
Local oView
Local aTables 		:= {}
Local aFields       := {}
Local oStrAA1		:= FWFormViewStruct():New()
Local oStrDTA		:= FWFormViewStruct():New()
Local nX
Local nY

AADD(aTables, {oStrAA1, "AA1"})
AADD(aTables, {oStrDTA, "DTA"})

For nY := 1 to LEN(aTables)
	aFields := AT190HDef(aTables[nY][2])

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

oStrDTA:RemoveField("DTA_TFFCOD")

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_MASTER', oStrAA1, 'AA1MASTER')
oView:AddGrid('VIEW_DTA',  oStrDTA, 'DTADETAIL')

oView:CreateHorizontalBox( 'COMP_AA1' , 25 )
oView:CreateHorizontalBox( 'COMP_DTA' , 75 )

oView:SetOwnerView('VIEW_MASTER','COMP_AA1')
oView:SetOwnerView('VIEW_DTA','COMP_DTA')

oView:EnableTitleView('VIEW_MASTER',STR0002) //"Atendente"
oView:EnableTitleView('VIEW_DTA'   ,STR0004) //"Período de Compensação"

oView:SetDescription(STR0001) //"Compensação"

Return oView
//------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados

@description Bloco de código executado no activate
@param oModel, obj, modelo em ativação

@author	boiani
@since 29/06/2020
/*/
//------------------------------------------------------------------------------
Static Function InitDados(oModel)
Local oMdl190d := FwModelActive()
Local oMdlAA1 := oModel:GetModel("AA1MASTER")
Local oMdlDTA := oModel:GetModel("DTADETAIL")
Local oStrAA1 := oMdlAA1:GetStruct() 
Local oStrDTA := oMdlDTA:GetStruct() 
Local aMarks := ACLONE(At190DSMar())
Local dDataRef := STod("")
Local nLinha := 0
Local nX

If oMdl190d:GetId() == 'TECA190D' .AND. oModel:GetId() == 'TECA190H' 
    oMdlAA1:SetValue("AA1_CODTEC", oMdl190d:GetValue("AA1MASTER","AA1_CODTEC"))
    //oMdlAA1:LoadValue("AA1_NOMTEC", oMdl190d:GetValue("AA1MASTER","AA1_NOMTEC"))
    oStrAA1:SetProperty("AA1_CODTEC", MODEL_FIELD_WHEN, {|| .F.})
    oStrAA1:SetProperty("AA1_NOMTEC", MODEL_FIELD_WHEN, {|| .F.})
    For nX := 1 To LEN(aMarks)
        If !EMPTY(aMarks[nX][1]) .AND. HasABN(aMarks[nX][1])
            If dDataRef <> aMarks[nX][9]
                If !oMdlDTA:IsEmpty()
                    nLinha := oMdlDTA:AddLine()
                EndIf
                oMdlDTA:GoLine(nLinha)
                oMdlDTA:SetValue("DTA_DTCOMP", aMarks[nX][9])
				oMdlDTA:SetValue("DTA_TFFCOD", Posicione("ABQ",1,xFilial("ABQ") + aMarks[nX][8],"ABQ_CODTFF"))
            EndIf
            dDataRef := aMarks[nX][9]
        EndIf
    Next nX
    oStrDTA:SetProperty("DTA_DTCOMP", MODEL_FIELD_WHEN, {|| .F.})
    oStrDTA:SetProperty("DTA_DSCOMP", MODEL_FIELD_WHEN, {|| .F.})
	oStrDTA:SetProperty("DTA_TFFCOD", MODEL_FIELD_WHEN, {|| .F.})
    oMdlDTA:SetNoInsertLine(.T.)
    oMdlDTA:SetNoDeleteLine(.T.)
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190HDef

@description Retorna em forma de Array as definições dos campos
@param cTable, string, define de qual tabela devem ser os campos retornados
@return aRet, array, definição dos campos

@author	boiani
@since	29/06/2020
/*/
//------------------------------------------------------------------------------
Function AT190HDef(cTable)
Local aRet		:= {}
Local nAux 		:= 0

If cTable == "AA1"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes("AA1_CODTEC")  //"Codigo do Atendente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes("AA1_CODTEC", .F.) //"Codigo do Atendente"
	aRet[nAux][DEF_IDENTIFICADOR] := "AA1_CODTEC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_CODTEC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes("AA1_NOMTEC") //"Nome Atendente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes("AA1_NOMTEC", .F.) //"Nome Atendente"
	aRet[nAux][DEF_IDENTIFICADOR] := "AA1_NOMTEC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_NOMTEC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

ElseIf cTable == "DTA"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0005 //"Dia Compensado"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0005 //"Dia Compensado"
	aRet[nAux][DEF_IDENTIFICADOR] := "DTA_DTCOMP"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0006 //"Dia da Semana"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0006 //"Dia da Semana"
	aRet[nAux][DEF_IDENTIFICADOR] := "DTA_DSCOMP"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 25
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0007//"Dia Trabalhado"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0007//"Dia Trabalhado"
	aRet[nAux][DEF_IDENTIFICADOR] := "DTA_DTTRAB"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0008} //"Dia em que o atendente trabalhará para compensar o dia no campo Dia Compensado"

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0006//"Dia da Semana"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0006//"Dia da Semana"
	aRet[nAux][DEF_IDENTIFICADOR] := "DTA_DSTRAB"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 25
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "04"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes("TFF_COD") //Codigo da TFF
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes("TFF_COD", .F.)//Codigo da TFF
	aRet[nAux][DEF_IDENTIFICADOR] := "DTA_TFFCOD"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_COD")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "05"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.

EndIf

Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PrelinDTA
@description Função de prelin do mo DTA
@author Augusto Albuquerque
@since  06/07/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function PrelinDTA(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)
Local lRet 		:= .T.
Local aSaveLines	:= FWSaveRows()
Local aArea		:= GetArea()
Local oView		:= FwViewActive()
Local oModel	:= oMdlG:GetModel()
Local oMdlAA1	:= oModel:GetModel("AA1MASTER")
Local oMdlDTA	:= oModel:GetModel("DTADETAIL")
Local cMsg		:= ""

If cAcao == 'SETVALUE'
	If cCampo == 'DTA_DTTRAB'
		If !DiaTrab( DToS(xValue), oMdlAA1:GetValue("AA1_CODTEC"), @cMsg, oMdlDTA:GetValue("DTA_TFFCOD") )
			lRet := .F.
			Help( " ", 1, "PrelinDTA", Nil, cMsg, 1 )
		EndIf
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DiaTrab
@description Função que retorna se ele tem TGY para o dia e não tem agenda(ABB)
@author Augusto Albuquerque
@since  06/07/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function DiaTrab( cDataRef, cCodAtend, cMsg, cCodTFF )
Local lRet		:= .T.
Local cQuery 	:= ""
Local cAliasTGY	:= GetNextAlias() 
Local cAliasABB	:= GetNextAlias() 

cQuery := ""
cQuery += " SELECT 1 REC "
cQuery += " FROM " + RetSqlName("TGY") + " TGY "
cQuery += " WHERE TGY.TGY_ATEND = '" + cCodAtend + "' "
cQuery += " AND ( TGY.TGY_DTINI <= '" + cDataRef + "' AND TGY.TGY_ULTALO >= '" + cDataRef + "' ) "
cQuery += " AND TGY.TGY_ULTALO <> ' ' "
cQuery += " AND TGY.TGY_CODTFF = '" + cCodTFF + "' "
cQuery += " AND TGY.TGY_FILIAL = '" + xFilial("TGY") + "' "
cQuery += " AND TGY.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTGY, .F., .T.)

If (cAliasTGY)->(EOF())
	lRet := .F.
	cMsg := STR0009 //"Não é possivel selecionar data superior a configuração de alocação (verificar Posto x Funcionário - Tabela TGY)."
Else
	cQuery := ""
	cQuery += " SELEC 1 REC "
	cQuery += " FROM " + RetSqlName("ABB") + " ABB "
	cQuery += " INNER JOIN " + RetSqlName("TDV") + " TDV "
	cQuery += " ON TDV.TDV_CODABB = ABB.ABB_CODIGO "
	cQuery += " AND TDV.TDV_FILIAL = '" + xFilial("TDV") + "' "
	cQuery += " AND TDV.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE TDV.TDV_DTREF = '" + cDataRef + "' "
	cQuery += " AND ABB.ABB_CODTEC = '" + cCodAtend + "' "
	cQuery += " AND ABB.ABB_FILIAL = '" + xFilial("ABB") + "' "
	cQuery += " AND ABB.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasABB, .F., .T.)

	If !(cAliasABB)->(EOF())
		lRet := .F.
		cMsg := STR0010 //"O atendente já possui agenda no dia selecionado."
	EndIf

	(cAliasABB)->(dbCloseArea())
EndIf

(cAliasTGY)->(dbCloseArea())
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT190HCmt
@description Função de commit do modelo
@author Augusto Albuquerque
@since  06/07/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT190HCmt(oModel)
Local cCodABB	:= ""
Local aAbbAnt	:= ACLONE(At190DSMar())
Local aAbbNew	:= {}
Local aCampoABB	:= {}
Local nCampoABB	:= 0
Local oMdlDTA	:= oModel:GetModel("DTADETAIL")
Local dDataIni	:= SToD("")
Local dDataFim	:= SToD("")
Local dDataRef	:= SToD("")
Local nX

dbSelectArea("ABB")
ABB->(dbSetOrder(8))

dbSelectArea("TDV")
TDV->(dbSetOrder(1))

nCampoABB := Len(aCampoABB)
For nX := 1 To Len(aAbbAnt)
	If  ABB->(DbSeek(xFilial("ABB")+aAbbAnt[nX][1])) .AND. TDV->(DbSeek(xFilial("TDV")+aAbbAnt[nX][1]))
		AADD(aAbbNew, { ABB->ABB_CODTEC,; //1
		 				ABB->ABB_ENTIDA,;	//2
						ABB->ABB_CHAVE,;	//3
						ABB->ABB_NUMOS,;	//4
						ABB->ABB_DTINI,;	//5
						ABB->ABB_HRINI,;	//6
						ABB->ABB_DTFIM,;	//7
						ABB->ABB_HRFIM,;	//8
						ABB->ABB_HRTOT,;	//9
						ABB->ABB_OBSERV,;	//10
						ABB->ABB_SACRA,;	//11
						ABB->ABB_CHEGOU,;	//12
						ABB->ABB_ATENDE,;	//13
						ABB->ABB_IDCFAL,;	//14
						ABB->ABB_LOCAL,;	//15
						ABB->ABB_TIPOMV,;	//16
						TDV->TDV_CODABB,;	//17
						TDV->TDV_DTREF,; 	//18
						TDV->TDV_TURNO,;	//19
						TDV->TDV_SEQTRN,;	//20
						TDV->TDV_TPEXTN,;	//21
						TDV->TDV_TPEXT,;	//22
						TDV->TDV_NONHOR,;	//23
						TDV->TDV_CODREF,;	//24
						TDV->TDV_INSREP,;	//25
						TDV->TDV_TPDIA,;	//26
						TDV->TDV_HRMEN,;	//27
						TDV->TDV_HRMAI,;	//28
						TDV->TDV_INTVL1,;	//29
						TDV->TDV_INTVL2,;	//30
						TDV->TDV_INTVL3,;	//31
						TDV->TDV_FERIAD,;	//32
						TDV->TDV_FTPEXT,;	//33
						TDV->TDV_FEXTN,;	//34
						TDV->TDV_CODFER,;	//35
						TDV->TDV_GRUPO,;	//36
						TDV->TDV_FERSAI,;	//37
						TDV->TDV_FSTPEX,;	//38
						TDV->TDV_FSEXTN})	//39
	EndIf

Next nX

dbSelectArea("ABR")
ABR->(dbSetOrder(1))

For nX := 1 To Len(aAbbNew)
	
	//{ {"TXB_DTINI", aGeral[nY][3]}}
	If oMdlDTA:SeekLine({ {"DTA_DTCOMP", aAbbNew[nX][18]}},,.T. )
		dDataRef := oMdlDTA:GetValue("DTA_DTTRAB")
		dDataIni := oMdlDTA:GetValue("DTA_DTTRAB")
		If oMdlDTA:GetValue("DTA_DTCOMP") <> aAbbNew[nX][5]
			dDataIni := oMdlDTA:GetValue("DTA_DTTRAB") + 1
		EndIf
		If oMdlDTA:GetValue("DTA_DTCOMP") <> aAbbNew[nX][7]
			dDataFim := oMdlDTA:GetValue("DTA_DTTRAB") + 1
		Else
			dDataFim := oMdlDTA:GetValue("DTA_DTTRAB")
		EndIf
	EndIf

	cCodAbb := AtABBNumCd()
	RecLock('ABB', .T.)
		ABB->ABB_FILIAL	:= xFilial( 'ABB' )
		ABB->ABB_CODIGO	:= cCodABB
		ABB->ABB_CODTEC	:= aAbbNew[nX][1]
		ABB->ABB_ENTIDA	:= aAbbNew[nX][2]
		ABB->ABB_NUMOS	:= aAbbNew[nX][4]
		ABB->ABB_CHAVE	:= aAbbNew[nX][3]
		ABB->ABB_DTINI	:= dDataIni
		ABB->ABB_HRINI	:= aAbbNew[nX][6]
		ABB->ABB_DTFIM	:= dDataFim
		ABB->ABB_HRFIM	:= aAbbNew[nX][8]
		ABB->ABB_HRTOT	:= aAbbNew[nX][9]
		ABB->ABB_SACRA 	:= aAbbNew[nX][11]
		ABB->ABB_CHEGOU	:= aAbbNew[nX][12]
		ABB->ABB_ATENDE	:= aAbbNew[nX][13]
		ABB->ABB_MANUT	:= '2'
		ABB->ABB_ATIVO	:= '1'
		ABB->ABB_IDCFAL	:= aAbbNew[nX][14]
		ABB->ABB_LOCAL	:= aAbbNew[nX][15]
		ABB->ABB_TIPOMV := aAbbNew[nX][16]
		Replace ABB->ABB_OBSERV	With (STR0011 + DToC(oMdlDTA:GetValue("DTA_DTCOMP"))) //"Compensação do dia : "
	ABB->(MsUnLock())
	ConfirmSX8()

	RecLock('TDV', .T.)
		TDV->TDV_FILIAL := xFilial("TDV")
		TDV->TDV_CODABB := cCodABB
		TDV->TDV_DTREF	:= dDataRef
		TDV->TDV_TURNO	:= aAbbNew[nX][19]
		TDV->TDV_SEQTRN	:= aAbbNew[nX][20]
		TDV->TDV_TPEXTN	:= aAbbNew[nX][21]
		TDV->TDV_TPEXT	:= aAbbNew[nX][22]
		TDV->TDV_NONHOR	:= aAbbNew[nX][23]
		TDV->TDV_CODREF	:= aAbbNew[nX][24]
		TDV->TDV_INSREP	:= aAbbNew[nX][25]
		TDV->TDV_TPDIA	:= aAbbNew[nX][26]
		TDV->TDV_HRMEN	:= aAbbNew[nX][27]
		TDV->TDV_HRMAI	:= aAbbNew[nX][28]
		TDV->TDV_INTVL1	:= aAbbNew[nX][29]
		TDV->TDV_INTVL2	:= aAbbNew[nX][30]
		TDV->TDV_INTVL3	:= aAbbNew[nX][31]
		TDV->TDV_FERIAD	:= aAbbNew[nX][32]
		TDV->TDV_FTPEXT	:= aAbbNew[nX][33]
		TDV->TDV_FEXTN	:= aAbbNew[nX][34]
		TDV->TDV_CODFER	:= aAbbNew[nX][35]
		TDV->TDV_GRUPO	:= aAbbNew[nX][36]
		TDV->TDV_FERSAI	:= aAbbNew[nX][37]
		TDV->TDV_FSTPEX	:= aAbbNew[nX][38]
		TDV->TDV_FSEXTN	:= aAbbNew[nX][39]
	TDV->(MsUnLock())
	ConfirmSX8()

	If  ABR->(DbSeek(xFilial("ABR")+aAbbAnt[nX][1]))
		RecLock('ABR',.F.)
			ABR->ABR_COMPEN := cCodABB
		ABR->(MsUnLock())
	EndIf
Next nX
Return .T.
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} HasABN
@description Verifica se determinada ABB possui compensação
@author Augusto Albuquerque
@since  06/07/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function HasABN( cCodABB )
Local cQuery    := ""
Local cAliasABN := GetNextAlias()
Local lRet      := .T.

cQuery := ""
cQuery += " SELECT ABN.ABN_TIPO "
cQuery += " FROM " + RetSqlName("ABN") + " ABN "
cQuery += " INNER JOIN " + RetSqlName("ABR") + " ABR "
cQuery += " ON ABR.ABR_FILIAL = '" + xFilial("ABR") + "' "
cQuery += " AND ABR.D_E_L_E_T_ = '' "
cQuery += " AND ABR.ABR_MOTIVO = ABN.ABN_CODIGO "
cQuery += " AND ABR.ABR_AGENDA = '" + cCodABB + "' "
cQuery += " INNER JOIN " + RetSqlName("ABB") + " ABB "
cQuery += " ON ABB.ABB_FILIAL = '" + xFilial("ABB") + "' "
cQuery += " AND ABB.ABB_CODIGO = ABR.ABR_AGENDA "
cQuery += " AND ABB.D_E_L_E_T_ = '' "
cQuery += " WHERE ABN.ABN_FILIAL = '" + xFilial("ABN") + "' "
cQuery += " AND ABN.D_E_L_E_T_ = '' "

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasABN, .F., .T.)

If !(cAliasABN)->(EOF())
    lRet := (cAliasABN)->ABN_TIPO == '09' 
EndIf

(cAliasABN)->(dbCloseArea())

Return lRet
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT190hVld
@description Prevalid do Modelo
@author mateus.barbosa
@since  07/07/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT190hVld(oModel)
Local lRet		:= .T.
Local aData		:= {}
Local oMdlDTA	:= oModel:GetModel("DTADETAIL")
Local nX

For nX := 1 To oMdlDTA:Length()
	oMdlDTA:GoLine(nX)
	If EMPTY(oMdlDTA:GetValue("DTA_DTTRAB"))
		lRet := .F.
		Help(,1,"AT190hVld",,STR0012 + DtoC(oMdlDTA:GetValue("DTA_DTCOMP")), 1) //"Necessário informar um dia trabalhado para a data "
		Exit
	EndIf
	If ASCAN( aData, oMdlDTA:GetValue("DTA_DTTRAB")) > 0
		lRet := .F.
		Help(,1,"AT190hVld",,STR0013 + DtoC(oMdlDTA:GetValue("DTA_DTTRAB")) + STR0014, 1) //"Não é possivel selecionar o mesmo dia(" ## ") para ser trabalhado mais de uma vez."
		Exit
	EndIf
	AADD( aData, oMdlDTA:GetValue("DTA_DTTRAB"))
Next nX

Return lRet
