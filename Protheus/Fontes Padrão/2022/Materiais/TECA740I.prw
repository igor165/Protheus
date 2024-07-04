#INCLUDE 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA740I.CH"

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

Static cTpItem := ""
Static cCodItem := ""
Static cProdut := ""
Static cCodTFJ := ""
Static nValInit := 0
Static lView := .F.
//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA740I

@description  Cronograma de Cobranças

@author	boiani
@since	20/07/2021
/*/
//------------------------------------------------------------------------------
Function TECA740I(oView, lSemView, cSelect)
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,STR0001},{.T.,STR0002},;
                    {.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}} //"Salvar"#"Cancelar"
Local oModel
Local oMdlGrid
Local cSubModel := ""
Local lOrcPrc := SuperGetMv("MV_ORCPRC",,.F.)

Default lSemView := .F.
Default cSelect := ""

cTpItem := ""
cCodItem := ""
cProdut := ""
cCodTFJ := ""
nValInit := 0
lView := .F.

If lSemView .OR. (VALTYPE(oView) == 'O' .AND. oView:GetModel():GetId() == "TECA740")
    If !lSemView
        oModel := oView:GetModel()
        cSelect := oView:GetCurrentSelect()[1]
    Else
        oModel := FwModelActive()
    EndIf

    If cSelect == 'VIEW_RH'
        cSubModel := "TFF_RH"
        cTpItem := "TFF"
    ElseIf cSelect == 'VIEW_MI'
        cSubModel := "TFG_MI"
        cTpItem := "TFG"
    ElseIf cSelect == 'VIEW_MC'
        cSubModel := "TFH_MC"
        cTpItem := "TFH"
    EndIf
    If !EMPTY(cTpItem)
        oMdlGrid := oModel:GetModel(cSubModel)
        cCodItem := oMdlGrid:GetValue(cTpItem+"_COD")
        cProdut := oMdlGrid:GetValue(cTpItem+"_PRODUT")
        cCodTFJ := oModel:GetValue("TFJ_REFER","TFJ_CODIGO")
        nValInit := At740PrxPa(/*cTipo*/,;
                    oMdlGrid:GetValue(cTpItem+"_QTDVEN"),;
                    oMdlGrid:GetValue(cTpItem+"_PRCVEN"),;
                    oMdlGrid:GetValue(cTpItem+"_DESCON"),;
                    oMdlGrid:GetValue(cTpItem+"_TXLUCR"),;
                    oMdlGrid:GetValue(cTpItem+"_TXADM"))
        If oMdlGrid:GetValue(cTpItem+"_COBCTR") != '2'
            If !(oMdlGrid:IsDeleted())
                If oModel:GetValue("TFJ_REFER","TFJ_CNTREC") == '1'
                    If !lOrcPrc
                        lView := (oModel:GetOperation() == MODEL_OPERATION_VIEW .OR. oModel:GetOperation() == MODEL_OPERATION_DELETE)
                        If !lSemView
                            FwExecView( STR0003, "VIEWDEF.TECA740I", MODEL_OPERATION_INSERT,;
                                    /*oOwner*/, {||.T.}, /*bOk*/, 45, aButtons ) //"Cronograma de Cobranças"
                        EndIf
                    Else
                        Help(,, "T740IORC",, STR0004, 1, 0) //"Opção disponível apenas para Planilha de Preços (MV_ORCPRC)"
                    EndIf
                Else
                    Help(,, "T740IREC",, STR0005, 1, 0) //"Opção disponível apenas para contratos recorrentes"
                EndIf
            Else
                Help(,, "T740IDEL",, STR0006, 1, 0) //"Opção não disponível para itens apagados."
            EndIf
        Else
            Help(,, "T740IEXT",, STR0007, 1, 0) //"Opção não disponível para itens que não constam no contrato (Item extra)."
        EndIf
    Else
        Help(,, "T740IPOS",, STR0008, 1, 0) //"Selecione um item de Recursos Humanos, Material de Implantação ou Material de Consumo."
    EndIf
EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Modelo da interface

@author	boiani
@since	19/07/2021
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel	
Local oStrCAB	:= FWFormModelStruct():New()
Local oStrTGT	:= FWFormModelStruct():New()
Local aFields	:= {}
Local nX		:= 0
Local nY		:= 0
Local aTables 	:= {}
Local bValid    := { |oModel| AT740IVld(oModel) }
Local bCommit   := { |oModel| AT740ICmt(oModel) }
Local xAux
Local lExcedente := TecBHasExc()
oStrCAB:AddTable("   ",{}, STR0003	) //"Cronograma de Cobranças"
oStrTGT:AddTable("   ",{}, "   ")

AADD(aTables, {oStrCAB, "CAB"})
AADD(aTables, {oStrTGT, "TGT"})

For nY := 1 To LEN(aTables)
	aFields := AT740IDef(aTables[nY][2])

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

If lExcedente
    xAux := FwStruTrigger( 'TGT_PRDRET', 'TGT_B1DESC',;
        'Posicione("SB1",1,xFilial("SB1") + FwFldGet("TGT_PRDRET"),"B1_DESC")', .F. )
        oStrTGT:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

    xAux := FwStruTrigger( 'TGT_EXCEDT', 'TGT_PRDRET','SPACE(1)', .F. )
        oStrTGT:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

    xAux := FwStruTrigger( 'TGT_EXCEDT', 'TGT_B1DESC','SPACE(1)', .F. )
        oStrTGT:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
EndIf

oModel := MPFormModel():New('TECA740I',/*bPreValidacao*/, bValid, bCommit,/*bCancel*/)
oModel:SetDescription( STR0003 ) //"Cronograma de Cobranças"

oModel:addFields('CABMASTER',,oStrCAB)
oModel:SetPrimaryKey({"CAB_FILIAL","CAB_CODIGO"})

oModel:addGrid('TGTDETAIL','CABMASTER', oStrTGT)

oModel:GetModel('TGTDETAIL'):SetOnlyQuery(.T.)
oModel:GetModel('TGTDETAIL'):SetOptional(.T.)

oModel:GetModel('CABMASTER'):SetDescription(STR0009) //"Item do Orçamento"
oModel:GetModel('TGTDETAIL'):SetDescription(STR0003) //"Cronograma de Cobranças"

oModel:SetActivate( {|oModel| InitDados( oModel ) } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da interface

@author	boiani
@since	20/07/2021
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel := ModelDef()
Local oView
Local aTables 	:= {}
Local oStrCAB	:= FWFormViewStruct():New()
Local oStrTGT	:= FWFormViewStruct():New()
Local nX
Local nY

AADD(aTables, {oStrCAB, "CAB"})
AADD(aTables, {oStrTGT, "TGT"})

For nY := 1 to LEN(aTables)
	
	aFields := AT740IDef(aTables[nY][2])

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

oView:AddField('VIEW_CAB', oStrCAB, 'CABMASTER')
oView:AddGrid('DETAIL_TGT', oStrTGT, 'TGTDETAIL')

oView:CreateHorizontalBox( 'CONFIG_TFF' , 35 )
oView:CreateHorizontalBox( 'CONFIG_TGY', 65 )

oView:SetOwnerView('VIEW_CAB','CONFIG_TFF')
oView:SetOwnerView('DETAIL_TGT','CONFIG_TGY')

oStrCAB:RemoveField("CAB_FILIAL")
oStrTGT:RemoveField("TGT_RECTGT")

oView:EnableTitleView('VIEW_CAB',STR0010) //"Item do Contrato"

oView:SetDescription(STR0003) //"Cronograma de Cobranças"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} AT740IDef
	Define os campos da tela

@author	boiani
@since	20/07/2021
/*/
//-------------------------------------------------------------------
Function AT740IDef(cTable)
Local aRet		:= {}
Local nAux 		:= 0

If cTable == "CAB"

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
    nAux := LEN(aRet)
    aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes("TFJ_FILIAL", .T.)
    aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes("TFJ_FILIAL", .F.)
    aRet[nAux][DEF_IDENTIFICADOR] := "CAB_FILIAL"
    aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
    aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
    aRet[nAux][DEF_TAMANHO_DO_CAMPO] := Len(cFilAnt)
    aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
    aRet[nAux][DEF_OBRIGAT] := .T.
    aRet[nAux][DEF_RECEBE_VAL] := .T.
    aRet[nAux][DEF_VIRTUAL] := .T.
    aRet[nAux][DEF_ORDEM] := "01"
    aRet[nAux][DEF_PICTURE] := "@!"
    aRet[nAux][DEF_CAN_CHANGE] := .T.
    aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0011 //"Código"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0011 //"Código"
	aRet[nAux][DEF_IDENTIFICADOR] := "CAB_CODIGO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_COD")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| cCodItem}

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0012 //"Tp. Item"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0012 //"Tp. Item"
	aRet[nAux][DEF_IDENTIFICADOR] := "CAB_TPITEM"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 35
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| AT740IGtTp()}

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0013 //"Produto"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0013 //"Produto"
	aRet[nAux][DEF_IDENTIFICADOR] := "CAB_DESCPR"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("B1_DESC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "04"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| ALLTRIM(POSICIONE("SB1",1,xFilial("SB1")+cProdut,"B1_DESC"))}

ElseIf cTable == "TGT"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0014 //"Competência"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0014 //"Competência"
	aRet[nAux][DEF_IDENTIFICADOR] := "TGT_COMPET"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 7
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "99/9999"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
    aRet[nAux][DEF_CODEBLOCK_VALID] := {|oMdl,cField,xNewValue| !EMPTY(xNewValue) .AND.;
                                            At740IVlCp(xNewValue)}

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0015 //"Valor"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0015 //"Valor"
	aRet[nAux][DEF_IDENTIFICADOR] := "TGT_VALOR"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_VLPRPA")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := TamSX3("TFF_VLPRPA")[2]
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "@E 99,999,999,999.99"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
    aRet[nAux][DEF_CODEBLOCK_VALID] := {|oMdl,cField,xNewValue| At740IVlVa(xNewValue)}
    aRet[nAux][DEF_CODEBLOCK_INIT] := {|| nValInit }

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := "RECNO"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := "RECNO"
	aRet[nAux][DEF_IDENTIFICADOR] := "TGT_RECTGT"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 16
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_CAN_CHANGE] := .T.

    If TecBHasExc()
        AADD(aRet, ARRAY(QUANTIDADE_DEFS))
        nAux := LEN(aRet)
        aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0024 //"Excedente?"
        aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0024 //"Excedente?"
        aRet[nAux][DEF_IDENTIFICADOR] := "TGT_EXCEDT"
        aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
        aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
        aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
        aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
        aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
        aRet[nAux][DEF_RECEBE_VAL] := .T.
        aRet[nAux][DEF_VIRTUAL] := .T.
        aRet[nAux][DEF_ORDEM] := "04"
        aRet[nAux][DEF_PICTURE] := "@!"
        aRet[nAux][DEF_CAN_CHANGE] := .T.
        aRet[nAux][DEF_CODEBLOCK_INIT] := {||2}
        aRet[nAux][DEF_LISTA_VAL] := { "1="+STR0022, "2="+STR0023} // SIM ## NÃO  
	    aRet[nAux][DEF_COMBO_VAL] := { "1="+STR0022, "2="+STR0023} // SIM ## NÃO
        aRet[nAux][DEF_CODEBLOCK_VALID] := {|oMdl,cField,xNewValue| At740IVlEx(xNewValue)}

        AADD(aRet, ARRAY(QUANTIDADE_DEFS))
        nAux := LEN(aRet)
        aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0025 //"Cod.Apuração"
        aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0025 //"Cod.Apuração"
        aRet[nAux][DEF_IDENTIFICADOR] := "TGT_CODTFV"
        aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
        aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
        aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGT_CODTFV")[1]
        aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
        aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
        aRet[nAux][DEF_RECEBE_VAL] := .F.
        aRet[nAux][DEF_VIRTUAL] := .T.
        aRet[nAux][DEF_ORDEM] := "05"
        aRet[nAux][DEF_PICTURE] := "@!"
        aRet[nAux][DEF_CAN_CHANGE] := .F.

        AADD(aRet, ARRAY(QUANTIDADE_DEFS))
        nAux := LEN(aRet)
        aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0026 //"Prod.Exceden"
        aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0026 //"Prod.Exceden"
        aRet[nAux][DEF_IDENTIFICADOR] := "TGT_PRDRET"
        aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
        aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
        aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGT_PRDRET")[1]
        aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
        aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
        aRet[nAux][DEF_RECEBE_VAL] := .T.
        aRet[nAux][DEF_VIRTUAL] := .T.
        aRet[nAux][DEF_ORDEM] := "06"
        aRet[nAux][DEF_PICTURE] := "@!"
        aRet[nAux][DEF_CAN_CHANGE] := .T.
        aRet[nAux][DEF_LOOKUP] := "SB1"
        aRet[nAux][DEF_CODEBLOCK_VALID] := {|oMdl,cField,xNewValue| At740IVlPD(xNewValue)}

        AADD(aRet, ARRAY(QUANTIDADE_DEFS))
        nAux := LEN(aRet)
        aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0027 //"Descrição"
        aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0027 //"Descrição"
        aRet[nAux][DEF_IDENTIFICADOR] := "TGT_B1DESC"
        aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
        aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
        aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("B1_DESC")[1]
        aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
        aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
        aRet[nAux][DEF_RECEBE_VAL] := .F.
        aRet[nAux][DEF_VIRTUAL] := .T.
        aRet[nAux][DEF_ORDEM] := "07"
        aRet[nAux][DEF_PICTURE] := "@!"
        aRet[nAux][DEF_CAN_CHANGE] := .F.
    EndIf

    If TecCpoTGT()
        AADD(aRet, ARRAY(QUANTIDADE_DEFS))
        nAux := LEN(aRet)
        aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0035 //"Dt Ini Reaj"
        aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0035 //"Dt Ini Reaj"
        aRet[nAux][DEF_IDENTIFICADOR] := "TGT_DTINI"
        aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
        aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
        aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGT_DTINI")[1]
        aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
        aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
        aRet[nAux][DEF_RECEBE_VAL] := .T.
        aRet[nAux][DEF_VIRTUAL] := .T.
        aRet[nAux][DEF_ORDEM] := "08"
        aRet[nAux][DEF_PICTURE] := "@!"
        aRet[nAux][DEF_CAN_CHANGE] := .T.

        AADD(aRet, ARRAY(QUANTIDADE_DEFS))
        nAux := LEN(aRet)
        aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0036 //"Dt Ini Reaj"
        aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0036 //"Dt Ini Reaj"
        aRet[nAux][DEF_IDENTIFICADOR] := "TGT_DTFIM"
        aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
        aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
        aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGT_DTFIM")[1]
        aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
        aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
        aRet[nAux][DEF_RECEBE_VAL] := .T.
        aRet[nAux][DEF_VIRTUAL] := .T.
        aRet[nAux][DEF_ORDEM] := "09"
        aRet[nAux][DEF_PICTURE] := "@!"
        aRet[nAux][DEF_CAN_CHANGE] := .T.

        AADD(aRet, ARRAY(QUANTIDADE_DEFS))
        nAux := LEN(aRet)
        aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0037 //"Indice"
        aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0037 //"Indice"
        aRet[nAux][DEF_IDENTIFICADOR] := "TGT_INDICE"
        aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
        aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
        aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGT_INDICE")[1]
        aRet[nAux][DEF_DECIMAL_DO_CAMPO] := TamSX3("TGT_INDICE")[2]
        aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
        aRet[nAux][DEF_RECEBE_VAL] := .T.
        aRet[nAux][DEF_VIRTUAL] := .T.
        aRet[nAux][DEF_ORDEM] := "10"
        aRet[nAux][DEF_PICTURE] := GetSX3Cache( "TGT_INDICE", "X3_PICTURE" )
        aRet[nAux][DEF_CAN_CHANGE] := .T.

        AADD(aRet, ARRAY(QUANTIDADE_DEFS))
        nAux := LEN(aRet)
        aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0038 //"Valor Reaj"
        aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0038 //"Valor Reaj"
        aRet[nAux][DEF_IDENTIFICADOR] := "TGT_VALREA"
        aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
        aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
        aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGT_VALREA")[1]
        aRet[nAux][DEF_DECIMAL_DO_CAMPO] := TamSX3("TGT_VALREA")[2]
        aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
        aRet[nAux][DEF_RECEBE_VAL] := .T.
        aRet[nAux][DEF_VIRTUAL] := .T.
        aRet[nAux][DEF_ORDEM] := "11"
        aRet[nAux][DEF_PICTURE] := GetSX3Cache( "TGT_VALREA", "X3_PICTURE" )
        aRet[nAux][DEF_CAN_CHANGE] := .T.

    EndIf

EndIf

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} AT740IGtTp
	Inicialização do campo CAB_TPITEM

@author	boiani
@since	19/07/2021
/*/
//-------------------------------------------------------------------
Static Function AT740IGtTp()
Local cRet := ""

If cTpItem == "TFF"
    cRet := STR0016 //"Recursos Humanos"
ElseIf cTpItem == "TFG"
    cRet := STR0017 //"Material de Implantação"
ElseIf cTpItem == "TFH"
    cRet := STR0018 //"Material de Consumo"
EndIf

Return cRet
//-------------------------------------------------------------------
/*/{Protheus.doc} InitDados
@description Bloco de código executado no activate
@param oModel, obj, modelo em ativação

@author	boiani
@since	19/07/2021
/*/
//-------------------------------------------------------------------
Static Function InitDados(oModel)
Local cAliasQry := GetNextAlias()
Local cSql := ""
Local oMdlTGT := oModel:GetModel("TGTDETAIL")
Local nLinha
Local lExcedente := TecBHasExc()
Local lCpoReaj  := TecCpoTGT()

oModel:SetValue("CABMASTER","CAB_FILIAL",cFilAnt)

cSql += " SELECT TGT.R_E_C_N_O_ REC, TGT.TGT_COMPET, TGT.TGT_VALOR "
If lExcedente
    cSql += " , TGT.TGT_EXCEDT , TGT.TGT_CODTFV, TGT.TGT_PRDRET "
EndIf
If lCpoReaj
    cSql += " , TGT.TGT_DTINI , TGT.TGT_DTFIM, TGT.TGT_INDICE, TGT.TGT_VALREA "
EndIf 
cSql += " FROM " + RetSqlName("TGT") + " TGT "
cSql += " WHERE TGT.D_E_L_E_T_ = ' ' AND TGT.TGT_TPITEM = '" + cTpItem + "' "
cSql += " AND TGT.TGT_CDITEM = '" + cCodItem + "' AND "
cSql += " TGT.TGT_CODTFJ = '" + cCodTFJ + "' AND "
cSql += " TGT.TGT_FILIAL = '"+xFilial("TGT")+"' "
cSql := ChangeQuery(cSql)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
While !(cAliasQry)->(EOF())
    If !oMdlTGT:IsEmpty()
        nLinha := oMdlTGT:AddLine()
    EndIf
    oMdlTGT:GoLine(nLinha)
    oMdlTGT:LoadValue("TGT_COMPET",(cAliasQry)->TGT_COMPET)
    oMdlTGT:LoadValue("TGT_VALOR",(cAliasQry)->TGT_VALOR)
    oMdlTGT:LoadValue("TGT_RECTGT",(cAliasQry)->REC)
    If lExcedente
        If EMPTY((cAliasQry)->TGT_EXCEDT)
            oMdlTGT:LoadValue("TGT_EXCEDT","2")
        Else
            oMdlTGT:LoadValue("TGT_EXCEDT",(cAliasQry)->TGT_EXCEDT)
        EndIf
        oMdlTGT:LoadValue("TGT_CODTFV",(cAliasQry)->TGT_CODTFV)
        oMdlTGT:LoadValue("TGT_PRDRET",(cAliasQry)->TGT_PRDRET)
        oMdlTGT:LoadValue("TGT_B1DESC", Posicione("SB1",1,xFilial("SB1") + (cAliasQry)->TGT_PRDRET,"B1_DESC"))
    EndIf
    If lCpoReaj
        oMdlTGT:LoadValue("TGT_DTINI",StoD((cAliasQry)->TGT_DTINI))
        oMdlTGT:LoadValue("TGT_DTFIM",StoD((cAliasQry)->TGT_DTFIM))
        oMdlTGT:LoadValue("TGT_INDICE",(cAliasQry)->TGT_INDICE)
        oMdlTGT:LoadValue("TGT_VALREA",(cAliasQry)->TGT_VALREA)
    EndIf 
    (cAliasQry)->(DbSkip())
End
(cAliasQry)->(DbCloseArea())
oMdlTGT:GoLine(1)

If lView
    oModel:nOperation := MODEL_OPERATION_VIEW
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} At740IVlCp
    Valid do campo TGT_COMPET

@author	boiani
@since	19/07/2021
/*/
//-------------------------------------------------------------------
Function At740IVlCp(cValue)
Local lRet := .T.
Local nMes := VAL(LEFT(cValue,2))
Local lExcedente := TecBHasExc()

If nMes > 12 .OR. nMes < 1
    lRet := .F.
EndIf
If LEN(Alltrim(STRTRAN(cValue,"/"))) < 6
    lRet := .F.
EndIf
If lExcedente .AND. lRet .AND. !EMPTY(FwFldGet("TGT_CODTFV")) .AND. FwFldGet("TGT_EXCEDT") == '1'
    Help(,, "At740IVlCp",, STR0028, 1, 0) //"Não é possível modificar a competência de uma parcela já cobrada."
    lRet := .F.
EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} At740IVlVa
    Valid do campo TGT_VALOR

@author	boiani
@since	19/07/2021
/*/
//-------------------------------------------------------------------
Function At740IVlVa(nValue)
Local lRet := nValue >= 0
Local lExcedente := TecBHasExc()

If lExcedente .AND. lRet .AND. !EMPTY(FwFldGet("TGT_CODTFV")) .AND. FwFldGet("TGT_EXCEDT") == '1'
    Help(,, "At740IVlVa",, STR0029, 1, 0) //"Não é possível modificar o valor de uma parcela já cobrada."
    lRet := .F.
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} At740IVlEx
    Valid do campo TGT_EXCEDT

@author	boiani
@since	08/10/2021
/*/
//-------------------------------------------------------------------
Function At740IVlEx(cValor)
Local lRet := .T.
If cValor == '2' .AND. !EMPTY(FwFldGet("TGT_CODTFV"))
    Help(,, "T740IVlEx",, STR0030, 1, 0) //"Não é possível modificar o tipo de uma parcela já cobrada."
    lRet := .F.
EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} At740IVlPD
    Valid do campo TGT_EXCEDT

@author	boiani
@since	08/10/2021
/*/
//-------------------------------------------------------------------
Function At740IVlPD(cValor)
Local lRet := .T.
If !EMPTY(cValor) .AND. FwFldGet("TGT_EXCEDT") != '1'
    Help(,, "At740IVlPD",, STR0031, 1, 0) //"Campo disponível apenas para cobrança excedente."
    lRet := .F.
EndIf
If !EMPTY(cValor)
    lRet := lRet .AND. ExistCpo("SB1",cValor,1)
EndIf
If lRet .AND. !EMPTY(FwFldGet("TGT_CODTFV")) .AND. FwFldGet("TGT_EXCEDT") == '1'
    Help(,, "At740IVlPD",, STR0032, 1, 0) //"Não é possível modificar o produto de uma parcela já cobrada."
    lRet := .F.
EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} AT740ICmt
    commit do modelo

@author	boiani
@since	19/07/2021
/*/
//-------------------------------------------------------------------
Function AT740ICmt(oModel)
Local oMdlTGT := oModel:GetModel("TGTDETAIL")
Local nX
Local cCompet := ""
Local nValor := 0
Local nRECNO := 0
Local cProdRet := ""
Local cExcedt := ""
Local lExcedente := TecBHasExc()
Local lCpoReaj  := TecCpoTGT()
Local dDtIni    := cTod('')
Local dDtFim    := cTod('')
Local nIndice   := 0
Local nValRea   := 0

DbSelectArea("TGT")

Begin Transaction
    For nX := 1 To oMdlTGT:Length()
        oMdlTGT:GoLine(nX)
        cCompet := oMdlTGT:GetValue("TGT_COMPET")
        nValor := oMdlTGT:GetValue("TGT_VALOR")
        nRECNO := oMdlTGT:GetValue("TGT_RECTGT")
        If lExcedente
            cProdRet := oMdlTGT:GetValue("TGT_PRDRET")
            cExcedt := oMdlTGT:GetValue("TGT_EXCEDT")
        EndIf
        If lCpoReaj
            dDtIni  := oMdlTGT:GetValue("TGT_DTINI")
            dDtFim  := oMdlTGT:GetValue("TGT_DTFIM")
            nIndice := oMdlTGT:GetValue("TGT_INDICE")
            nValRea := oMdlTGT:GetValue("TGT_VALREA")
        EndIf 
        If !EMPTY( nRECNO )
            TGT->(DbGoTo(nRECNO))
            If oMdlTGT:isDeleted()
                Reclock("TGT",.F.)
                    TGT->(DbDelete())
                TGT->(MsUnlock())
            Else
                Reclock("TGT",.F.)
                    TGT->TGT_COMPET := cCompet
                    TGT->TGT_VALOR := nValor
                    If lExcedente
                        TGT->TGT_PRDRET := cProdRet
                        TGT->TGT_EXCEDT := cExcedt
                    EndIf
                    If lCpoReaj
                        TGT->TGT_DTINI := dDtIni
                        TGT->TGT_DTFIM := dDtFim
                        TGT->TGT_INDICE := nIndice
                        TGT->TGT_VALREA := nValRea
                    EndIf 
                TGT->(MsUnlock())
            EndIf
        ElseIf !(oMdlTGT:isDeleted())
            TGTInsert(cCompet,nValor,cProdRet,cExcedt,dDtIni,dDtFim,nIndice,nValRea)
        EndIf
    Next nX
End Transaction

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} TGTInsert
    Insere os registros na TGT

@author	boiani
@since	19/07/2021
/*/
//-------------------------------------------------------------------
Static Function TGTInsert(cCompet,nValor,cProdRet,cExcedt,dDtIni,dDtFim,nIndice,nValRea)
Local lExcedente := TecBHasExc()
Local lCpoReaj  := TecCpoTGT()

TGT->(RecLock("TGT",.T.))
    TGT->TGT_FILIAL := xFilial("TGT")
    TGT->TGT_CODIGO := GETSXENUM('TGT','TGT_CODIGO')
    TGT->TGT_CDITEM := cCodItem
    TGT->TGT_COMPET := cCompet
    TGT->TGT_TPITEM := cTpItem
    TGT->TGT_VALOR := nValor
    TGT->TGT_CODTFJ := cCodTFJ
    If lExcedente
        TGT->TGT_PRDRET := cProdRet
        TGT->TGT_EXCEDT := cExcedt
    EndIf
    If lCpoReaj
        TGT->TGT_DTINI := dDtIni
        TGT->TGT_DTFIM := dDtFim
        TGT->TGT_INDICE := nIndice
        TGT->TGT_VALREA := nValRea
    EndIf 
TGT->(MsUnlock())
TGT->(ConfirmSX8())
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} AT740IVld
    Validação do modelo antes do commit

@author	boiani
@since	19/07/2021
/*/
//-------------------------------------------------------------------
Function AT740IVld(oModel)
Local lRet := .T.
Local nX
Local oMdlTGT := oModel:GetModel("TGTDETAIL")
Local aComps := {}
Local lExcedente := TecBHasExc()
Local cExcedente := ""

For nX := 1 To oMdlTGT:Length()
    oMdlTGT:GoLine(nX)
    cExcedente := '2'
    If lExcedente .AND. !EMPTY(oMdlTGT:GetValue("TGT_EXCEDT"))
        cExcedente := oMdlTGT:GetValue("TGT_EXCEDT")
    EndIf
    If EMPTY( STRTRAN(oMdlTGT:GetValue("TGT_COMPET"),"/"))
        Help(,, "T740INOC",, STR0019, 1, 0) //"A competência não está preenchida para todos os itens."
        lRet := .F.
        Exit
    Else
        If EMPTY(aComps) .OR. ASCAN(aComps, {|a| a[1] == oMdlTGT:GetValue("TGT_COMPET") .AND. a[2] == cExcedente}) == 0
            AADD(aComps, {oMdlTGT:GetValue("TGT_COMPET"), cExcedente})
        Else
            Help(,, "T740IDUP",, STR0020 + oMdlTGT:GetValue("TGT_COMPET") + STR0021, 1, 0) //"A competência " ## " está duplicada."
            lRet := .F.
            Exit
        EndIf
    EndIf
    If lExcedente .AND. cExcedente == '1' .AND. oMdlTGT:GetValue("TGT_VALOR") == 0
        Help(,, "T740IZER",, STR0033 + oMdlTGT:GetValue("TGT_COMPET") + STR0034, 1, 0) // "O item excedente da competência " ## " não possui valor informado."
        lRet := .F.
        Exit
    EndIf
Next nX

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} Tec740IExc
    Apaga a TGT relacionada ao orçamento

@author	boiani
@since	19/07/2021
/*/
//-------------------------------------------------------------------
Function Tec740IExc(cTFJ, cTFL, cTFF, cTFG, cTFH, nOper)
Local aArea := GetArea()
Local cSql := ""
Local cAliasQry := GetNextAlias()

Default cTFJ := ""
Default cTFL := ""
Default cTFF := ""
Default cTFG := ""
Default cTFH := ""

If nOper == MODEL_OPERATION_DELETE
    cSql += " SELECT TGT.TGT_CODIGO "
    cSql += " FROM " + RetSqlName("TFL") + " TFL "
    cSql += " INNER JOIN " + RetSqlName("TFF") + " TFF ON "
    cSql += " TFF.TFF_CODPAI = TFL.TFL_CODIGO AND "
    cSql += " TFF.TFF_FILIAL = TFL.TFL_FILIAL AND "
    cSql += " TFF.D_E_L_E_T_ = ' ' "
    cSql += " LEFT JOIN " + RetSqlName("TFH") + " TFH ON "
    cSql += " TFH.TFH_CODPAI = TFF.TFF_COD AND "
    cSql += " TFH.TFH_FILIAL = TFF.TFF_FILIAL AND "
    cSql += " TFH.D_E_L_E_T_ = ' ' "
    cSql += " LEFT JOIN " + RetSqlName("TFG") + " TFG ON "
    cSql += " TFG.TFG_CODPAI = TFF.TFF_COD AND "
    cSql += " TFG.TFG_FILIAL = TFF.TFF_FILIAL AND "
    cSql += " TFG.D_E_L_E_T_ = ' ' "
    cSql += " LEFT JOIN " + RetSqlName("TGT") + " TGT ON "
    cSql += " ( "
    cSql += " (TGT.TGT_TPITEM = 'TFF' AND TGT.TGT_CDITEM = TFF.TFF_COD) OR "
    cSql += " (TGT.TGT_TPITEM = 'TFH' AND TGT.TGT_CDITEM = TFH.TFH_COD) OR "
    cSql += " (TGT.TGT_TPITEM = 'TFG' AND TGT.TGT_CDITEM = TFG.TFG_COD) "
    cSql += " ) AND "
    cSql += " TGT.TGT_FILIAL = TFL.TFL_FILIAL AND "
    cSql += " TGT.D_E_L_E_T_ = ' ' "
    cSql += " WHERE TFL.D_E_L_E_T_ = ' ' "
    cSql += " AND TFL.TFL_CODPAI = '"+cTFJ+"' "
    cSql += " AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
ElseIf !EMPTY(cTFJ)
    cSql += " SELECT TGT.TGT_CODIGO FROM " + RetSqlName("TGT") + " TGT "
    cSql += " WHERE TGT.D_E_L_E_T_ = ' ' AND TGT.TGT_CODTFJ = '"+cTFJ+"' "
    If !EMPTY(cTFF)
        cSql += " AND TGT.TGT_TPITEM = 'TFF' AND TGT.TGT_CDITEM = '"+cTFF+"' "
    ElseIf !EMPTY(cTFG)
        cSql += " AND TGT.TGT_TPITEM = 'TFG' AND TGT.TGT_CDITEM = '"+cTFG+"' "
    ElseIf !Empty(cTFH)
        cSql += " AND TGT.TGT_TPITEM = 'TFH' AND TGT.TGT_CDITEM = '"+cTFH+"' "
    EndIf
EndIf
If !Empty(cSql)
    cSql := ChangeQuery(cSql)
    dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)

    DbSelectArea("TGT")
    DbSetOrder(1)

    While !(cAliasQry)->(EOF())
        If !EMPTY((cAliasQry)->TGT_CODIGO)
            If TGT->(DbSeek(xFilial("TGT") + (cAliasQry)->TGT_CODIGO))
                Reclock("TGT",.F.)
                    TGT->(DbDelete())
                TGT->(MsUnlock())
            EndIf
        EndIf
        (cAliasQry)->(DbSkip())
    End
    (cAliasQry)->(DbCloseArea())

    RestArea(aArea)
EndIf
Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} TEC740iTFJ
    Copia a TGT de um Orçamento em revisão para o novo orçamento

@author	boiani
@since	22/07/2021
/*/
//-------------------------------------------------------------------
Function TEC740iTFJ(cTFJAnt, cTFJNova, cContrato, cRev)
Local cSql := ""
Local cAliasQry := GetNextAlias()
Local aArea := GetArea()
Local aRevPlaIt := {}
Local nAux := 0
Local lExcedente := TecBHasExc()
Local lCpoReaj  := TecCpoTGT()

Default cContrato := ""
Default cRev := ""
Default cTFJAnt := ""
Default cTFJNova := ""

If EMPTY(cTFJAnt) .AND. !EMPTY(cContrato)
    cSql := ""
    cSql += " SELECT TFJ.TFJ_CODIGO FROM " + RetSqlName("TFJ") + " TFJ "
    cSql += " WHERE TFJ.TFJ_STATUS = '1' AND TFJ.D_E_L_E_T_ = ' ' AND "
    cSql += " TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND TFJ.TFJ_CONTRT = '" + cContrato + "' "
    cSql += " AND TFJ.TFJ_CONREV = '" + cRev + "' "
    cSql := ChangeQuery(cSql)
    dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
    If !(cAliasQry)->(EOF())
        cTFJAnt := (cAliasQry)->TFJ_CODIGO
    EndIf
    (cAliasQry)->(DbCloseArea())
EndIf

If isInCallStack("AplicaRevi")
    cAliasQry := GetNextAlias()
    cSql := ""
    cSql += " SELECT TFF.TFF_COD, TFF.TFF_CODREL, TFH.TFH_COD, TFH.TFH_CODREL, TFG.TFG_COD, TFG.TFG_CODREL "
    cSql += " FROM " + RetSqlName("TFF") + " TFF "
    cSql += " INNER JOIN " + RetSqlName("TFL") + " TFL ON "
    cSql += " TFL.TFL_FILIAL = TFF.TFF_FILIAL AND "
    cSql += " TFL.D_E_L_E_T_ = ' ' AND "
    cSql += " TFL.TFL_CODIGO = TFF.TFF_CODPAI AND "
    cSql += " TFL.TFL_CODPAI = '" + cTFJNova + "' "
    cSql += " LEFT JOIN " + RetSqlName("TFH") + " TFH ON "
    cSql += " TFH.TFH_FILIAL = TFF.TFF_FILIAL AND "
    cSql += " TFH.TFH_CODPAI = TFF.TFF_COD AND "
    cSql += " TFH.D_E_L_E_T_ = ' ' "
    cSql += " LEFT JOIN " + RetSqlName("TFG") + " TFG ON "
    cSql += " TFG.TFG_FILIAL = TFF.TFF_FILIAL AND "
    cSql += " TFG.TFG_CODPAI = TFF.TFF_COD AND "
    cSql += " TFG.D_E_L_E_T_ = ' ' "
    cSql := ChangeQuery(cSql)
    dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)

    While !(cAliasQry)->(EOF())
        If !EMPTY((cAliasQry)->TFF_COD) .AND. !EMPTY((cAliasQry)->TFF_CODREL)
            AADD(aRevPlaIt, {"TFF", (cAliasQry)->TFF_CODREL, (cAliasQry)->TFF_COD})
        EndIf
        If !EMPTY((cAliasQry)->TFH_COD) .AND. !EMPTY((cAliasQry)->TFH_CODREL)
            AADD(aRevPlaIt, {"TFH", (cAliasQry)->TFH_CODREL, (cAliasQry)->TFH_COD})
        EndIf
        If !EMPTY((cAliasQry)->TFG_COD) .AND. !EMPTY((cAliasQry)->TFG_CODREL)
            AADD(aRevPlaIt, {"TFG", (cAliasQry)->TFG_CODREL, (cAliasQry)->TFG_COD})
        EndIf
        (cAliasQry)->(DbSkip())
    End
    (cAliasQry)->(DbCloseArea())
EndIf

cAliasQry := GetNextAlias()
cSql := ""
cSql += " SELECT TGT.TGT_TPITEM , TGT.TGT_CDITEM , TGT.TGT_COMPET , TGT.TGT_VALOR "
If lExcedente
    cSql += " , TGT.TGT_EXCEDT , TGT.TGT_CODTFV , TGT.TGT_PRDRET "
EndIf
If lCpoReaj
    cSql += " , TGT.TGT_DTINI , TGT.TGT_DTFIM, TGT.TGT_INDICE, TGT.TGT_VALREA "
EndIf
cSql += " FROM " + RetSqlName("TGT") + " TGT "
cSql += " WHERE TGT.D_E_L_E_T_ = ' ' AND TGT.TGT_CODTFJ = '" + cTFJAnt + "' "
cSql += " AND TGT.TGT_FILIAL = '"+xFilial("TGT")+"' "
cSql := ChangeQuery(cSql)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)

While !(cAliasQry)->(EOF())
    DbSelectArea("TGT")
    Reclock("TGT",.T.)
        TGT->TGT_FILIAL := xFilial("TGT")
        TGT->TGT_CODIGO := At740INum('TGT','TGT_CODIGO',1)
        TGT->TGT_TPITEM := (cAliasQry)->TGT_TPITEM
        If EMPTY(aRevPlaIt) .OR.;
                (nAux := ASCAN(aRevPlaIt, {|a| a[1] == (cAliasQry)->TGT_TPITEM .AND. a[2] == (cAliasQry)->TGT_CDITEM})) == 0
            TGT->TGT_CDITEM := (cAliasQry)->TGT_CDITEM
        Else
            TGT->TGT_CDITEM := aRevPlaIt[nAux][3]
        EndIf
        TGT->TGT_COMPET := (cAliasQry)->TGT_COMPET
        TGT->TGT_VALOR := (cAliasQry)->TGT_VALOR
        TGT->TGT_CODTFJ := cTFJNova
        If lExcedente
            TGT->TGT_EXCEDT := (cAliasQry)->TGT_EXCEDT
            TGT->TGT_CODTFV := (cAliasQry)->TGT_CODTFV
            TGT->TGT_PRDRET := (cAliasQry)->TGT_PRDRET
        EndIf
        If lCpoReaj
            TGT->TGT_DTINI := StOD((cAliasQry)->TGT_DTINI)
            TGT->TGT_DTFIM := StOD((cAliasQry)->TGT_DTFIM)
            TGT->TGT_INDICE := (cAliasQry)->TGT_INDICE
            TGT->TGT_VALREA := (cAliasQry)->TGT_VALREA
        EndIf 
    TGT->(MsUnlock())
    TGT->(ConfirmSX8())
    (cAliasQry)->(DbSkip())
End

(cAliasQry)->(DbCloseArea())
RestArea(aArea)

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} At740IAtCd
    Atualiza o campo TGT_CDITEM para o novo código, no commit do orçamento revisado

@author	boiani
@since	22/07/2021
/*/
//-------------------------------------------------------------------
Function At740IAtCd(cTipo, cOld, cNew, cTFJ)
Local aArea := GetArea()
Local cSql := ""
Local cAliasQry := GetNextAlias()

cSql += " SELECT TGT.R_E_C_N_O_ REC FROM " + RetSqlName("TGT") + " TGT "
cSql += " WHERE TGT.TGT_CODTFJ = '"+cTFJ+"' AND TGT.TGT_TPITEM = '"+cTipo+"' AND "
cSql += " TGT.TGT_CDITEM = '" + cOld + "' AND TGT.TGT_FILIAL = '"+xFilial("TGT")+"' AND "
cSql += " TGT.D_E_L_E_T_ = ' ' "
cSql := ChangeQuery(cSql)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)

While !(cAliasQry)->(EOF())
    DbSelectArea("TGT")
    TGT->(DbGoTo((cAliasQry)->REC))
    Reclock("TGT",.F.)
        TGT->TGT_CDITEM := cNew
    TGT->(MsUnlock())
    (cAliasQry)->(DbSkip())
End

(cAliasQry)->(DbCloseArea())
RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} At740IAuto
    Atualiza / insere a TGT sem a necessidade de abrir a tela

@author	boiani
@since	22/07/2021
/*/
//-------------------------------------------------------------------
Function At740IAuto(cTGTTPITEM, cTGTCDITEM, cTGTCOMPET, nTGTVALOR, cTGTCODTFJ,cCompetAnt,lInclui)
Local lRet := .T.
Local oMdl740I
Local oMdlTGT
Local nX
Local lAchou := .F.

Default cCompetAnt := ""
Default lInclui := .T.

lView := .F.
cProdut := ""
nValInit := 0

cTpItem := cTGTTPITEM
cCodItem := cTGTCDITEM
cCodTFJ := cTGTCODTFJ

oMdl740I := FwLoadModel("TECA740I")
oMdl740I:SetOperation( MODEL_OPERATION_INSERT )

If lRet := oMdl740I:Activate()
    oMdlTGT := oMdl740I:GetModel("TGTDETAIL")
    If !Empty(cCompetAnt) .And. oMdlTGT:SeekLine({{"TGT_COMPET",cCompetAnt}})
        If lInclui
            lRet := lRet .AND. oMdlTGT:SetValue("TGT_COMPET", cTGTCOMPET)
            lRet := lRet .AND. oMdlTGT:SetValue("TGT_VALOR", nTGTVALOR)
            lAchou := .T.
        Else
            oMdlTGT:DeleteLine()
            lAchou := .T.
        EndIf    
    Else
        For nX := 1 To oMdlTGT:Length()
            oMdlTGT:GoLine(nX)
            If oMdlTGT:GetValue("TGT_COMPET") == cTGTCOMPET
                lRet := lRet .AND. oMdlTGT:SetValue("TGT_VALOR", nTGTVALOR)
                lAchou := .T.
                Exit
            EndIf
        Next nX
    EndIf    
EndIf

IF !lAchou .AND. lRet .And. lInclui
    oMdlTGT:GoLine(oMdlTGT:Length())
    If !oMdlTGT:IsEmpty()
       oMdlTGT:GoLine(oMdlTGT:AddLine())
    EndIf
    lRet := lRet .AND. oMdlTGT:SetValue("TGT_COMPET", cTGTCOMPET)
    lRet := lRet .AND. oMdlTGT:SetValue("TGT_VALOR", nTGTVALOR)
EndIf

If lRet
    lRet := lRet .AND. oMdl740I:VldData() .And. oMdl740I:CommitData()
EndIf

cTpItem := ""
cCodItem := ""
cCodTFJ := ""

oMdl740I:DeActivate()
oMdl740I:Destroy()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At740IExce
    insere a TGT de excedentes sem a necessidade de abrir a tela

@author	Luiz Gabriel
@since	22/07/2021
/*/
//-------------------------------------------------------------------
Function At740IExce(cTGTTPITEM, cTGTCDITEM, cTGTCOMPET, nTGTVALOR, cTGTCODTFJ,cProdRet,dDataDe,dDataAte,nPerc,nValRet)
Local lRet      := .T.
Local oMdl740I  := Nil 
Local oMdlTGT   := Nil
Local lCpoTGT   := TecCpoTGT()

Default dDataDe     := CTOD('')
Default dDataAte    := CTOD('')
Default nPerc       := 0
Default nValRet     := 0

lView := .F.
cProdut := ""
nValInit := 0

cTpItem := cTGTTPITEM
cCodItem := cTGTCDITEM
cCodTFJ := cTGTCODTFJ

oMdl740I := FwLoadModel("TECA740I")
oMdl740I:SetOperation( MODEL_OPERATION_INSERT )

If lRet := oMdl740I:Activate()
    oMdlTGT := oMdl740I:GetModel("TGTDETAIL")
    If oMdlTGT:SeekLine({{"TGT_COMPET",cTGTCOMPET}})
        nLine := oMdlTGT:AddLine()
        oMdlTGT:GoLine(nLine)
    EndIf
    lRet := lRet .AND. oMdlTGT:SetValue("TGT_COMPET", cTGTCOMPET)
    lRet := lRet .AND. oMdlTGT:SetValue("TGT_VALOR", nTGTVALOR)
    lRet := lRet .AND. oMdlTGT:SetValue("TGT_EXCEDT", "1")
    lRet := lRet .AND. oMdlTGT:SetValue("TGT_PRDRET", cProdRet)
    If lCpoTGT
        lRet := lRet .AND. oMdlTGT:LoadValue("TGT_DTINI", dDataDe)
        lRet := lRet .AND. oMdlTGT:LoadValue("TGT_DTFIM", dDataAte)
        lRet := lRet .AND. oMdlTGT:LoadValue("TGT_INDICE", nPerc)
        lRet := lRet .AND. oMdlTGT:LoadValue("TGT_VALREA", nValRet)
    EndIf    
EndIf

If lRet
    lRet := lRet .AND. oMdl740I:VldData() .And. oMdl740I:CommitData()
EndIf

cTpItem := ""
cCodItem := ""
cCodTFJ := ""

oMdl740I:DeActivate()
oMdl740I:Destroy()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At740INum

Função de inicializador padrão de auto numeração com confirmação de gravação

@author Luiz Gabriel
@since 03/01/2022
/*/
//-------------------------------------------------------------------

Static Function At740INum(cAlias, cCampo, nQualndex)

Local aArea     := GetArea()
Local aAreaTmp  := (cAlias)->(GetArea())
Local cProxNum  := ""

Default nQualndex := 1
         
cProxNum  := GetSx8Num(cAlias, cCampo,, nQualndex)

dbSelectArea(cAlias)
dbSetOrder(nQualndex)
  
While dbSeek( xFilial( cAlias ) + cProxNum )
    If ( __lSx8 )
		ConfirmSX8()
	EndIf
    cProxNum := GetSx8Num(cAlias, cCampo,, nQualndex)
End

RestArea(aAreaTmp)
RestArea(aArea)

Return(cProxNum)
