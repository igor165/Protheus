#INCLUDE 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA190G.ch"

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

#DEFINE LEGAGENDA	01
#DEFINE LEGSTATUS	02
#DEFINE GRUPO		03
#DEFINE DATREF		04
#DEFINE DATAAG		05
#DEFINE DIASEM		06
#DEFINE HORINI		07
#DEFINE HORFIM		08
#DEFINE CODTEC		09
#DEFINE NOMTEC		10
#DEFINE TIPO		11
#DEFINE ATENDIDA	12
#DEFINE CODABB		13
#DEFINE TURNO		14
#DEFINE SEQ			15
#DEFINE ITEM		16
#DEFINE KEYTGY		17
#DEFINE ITTGY		18
#DEFINE EXSABB		19
#DEFINE HORASTRAB   20
#DEFINE DALOFIM     21
#DEFINE ARRTDV      22
#DEFINE DESCCONF    23

#DEFINE TAMANHO		23

Static aManutPla	:= {}
Static oMdl190D 	:= Nil
Static lAlocAvuls	:= .F.
Static lDelConf     := .F.
Static cSitABB      := "BR_VERDE"

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
Local oStrALC	:= FWFormModelStruct():New()
Local oStrTOT
Local aFields	:= {}
Local nX		:= 0
Local nY		:= 0
Local aTables 	:= {}
Local xAux
Local bCommit	:= { |oModel| AT190GCmt(oModel) }
Local bValid := { |oModel| AT190GVld(oModel) }

If lAlocAvuls
	oStrAA1:AddTable("   ",{}, STR0060) //"Alocação Avulsa"
Else
	oStrAA1:AddTable("   ",{}, STR0001) //"Alocação Por Hora"
EndIf
oStrALC:AddTable("   ",{}, "   ")

AADD(aTables, {oStrAA1, "AA1"})
AADD(aTables, {oStrALC, "ALC"})
If !lAlocAvuls
	oStrTOT	:= FWFormModelStruct():New()
	oStrTOT:AddTable("   ",{}, "   ")
	AADD(aTables, {oStrTOT, "TOT"})
EndIf

For nY := 1 To LEN(aTables)
	aFields := AT190GDef(aTables[nY][2], .T.)

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

xAux := FwStruTrigger( 'ALC_DATREF', 'ALC_DATDIA',;
	'FwFldGet("ALC_DATREF")', .F. )
	oStrALC:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'ALC_DATDIA', 'ALC_SEMANA',;
	'TECCdow(Dow(FwFldGet("ALC_DATDIA")))', .F. )
	oStrALC:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'ALC_SAIDA', 'ALC_TOTHRS',;
	'AT190GHrsT("ALC_ENTRADA")', .F. )
	oStrALC:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'ALC_ENTRADA', 'ALC_TOTHRS',;
	'AT190GHrsT("ALC_SAIDA")', .F. )
	oStrALC:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	
oModel := MPFormModel():New('TECA190G',/*bPreValidacao*/, bValid, bCommit,/*bCancel*/)
oModel:SetDescription( STR0001 ) //"Alocação Por Hora" 

oModel:addFields('AA1MASTER',,oStrAA1)
oModel:SetPrimaryKey({"AA1_FILIAL","AA1_CODTEC"})

oModel:addGrid('ALCDETAIL','AA1MASTER', oStrALC,{|oMdlG,nLine,cAcao,cCampo, xValue, xOldValue| AT190GPrAL(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)},;
{|oMdlG,nLine,cAcao,cCampo| AT190GPoAL(oMdlG, nLine, cAcao, cCampo)})

oModel:GetModel('ALCDETAIL'):SetOnlyQuery(.T.)


oModel:GetModel('ALCDETAIL'):SetOptional(.T.)

oModel:GetModel('AA1MASTER'):SetDescription(STR0061)	//"Informações do Atendente"
oModel:GetModel('ALCDETAIL'):SetDescription(STR0002)	//"Projeção de Alocação"

If !lAlocAvuls
	oModel:addFields('TOTDETAIL','AA1MASTER',oStrTOT)
	oModel:GetModel('TOTDETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('TOTDETAIL'):SetOptional(.T.)
	oModel:GetModel('TOTDETAIL'):SetDescription(STR0048) //"Total de Horas" 
EndIf

oModel:SetActivate( {|oModel| InitDados( oModel ) } )

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
Local oStrALC	:= FWFormViewStruct():New()
Local oStrTOT
Local nX
Local nY
Local lMonitor	:= IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366

AADD(aTables, {oStrAA1, "AA1"})
AADD(aTables, {oStrALC, "ALC"})

If !lAlocAvuls
	oStrTOT	:= FWFormViewStruct():New()
	AADD(aTables, {oStrTOT, "TOT"})
EndIf

For nY := 1 to LEN(aTables)
	
	aFields := AT190GDef(aTables[nY][2])

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
		If aTables[nY][2] == "AA1" .AND. !(aFields[nX][DEF_IDENTIFICADOR] $ "AA1_CODTEC|AA1_NOMTEC")
			aTables[nY][1]:RemoveField(aFields[nX][DEF_IDENTIFICADOR])
		EndIf
	Next nX
Next nY


oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_MASTER', oStrAA1, 'AA1MASTER')
oView:AddGrid('DETAIL_ALC', oStrALC, 'ALCDETAIL')
If !lAlocAvuls
	oView:AddField('DETAIL_TOT', oStrTOT, 'TOTDETAIL')
	If lMonitor
		oView:CreateHorizontalBox( 'REALOC_AA1' , 35 )
		oView:CreateHorizontalBox( 'REALOC_ALOC', 60 )
		oView:CreateHorizontalBox( 'TOTAL_HRS', 05 )
	Else
		oView:CreateHorizontalBox( 'REALOC_AA1' , 15 )
		oView:CreateHorizontalBox( 'REALOC_ALOC', 70 )
		oView:CreateHorizontalBox( 'TOTAL_HRS', 15 )
	EndIf
	oView:SetOwnerView('DETAIL_TOT','TOTAL_HRS')
Else
	oView:CreateHorizontalBox( 'REALOC_AA1' , 15 )
	oView:CreateHorizontalBox( 'REALOC_ALOC', 85 )
	oStrALC:RemoveField("ALC_TOTHRS")
EndIf

oStrALC:RemoveField("ALC_DATDIA")

oView:SetOwnerView('VIEW_MASTER','REALOC_AA1')
oView:SetOwnerView('DETAIL_ALC','REALOC_ALOC')
If lMonitor
	oView:SetContinuousForm()
EndIf
If lAlocAvuls
	oView:SetDescription(STR0060) //"Alocação Avulsa"
Else
	oView:SetDescription(STR0001) //"Alocação Por Hora" 
EndIf
oView:EnableTitleView('VIEW_MASTER', 	STR0061) 		//"Informações do Atendente"

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados

@description Bloco de código executado no activate
@param oModel, obj, modelo em ativação

@author	Augusto Albuquerque
@since	03/04/2020
/*/
//------------------------------------------------------------------------------
Static Function InitDados(oModel)
Local oMdlAA1 := oModel:GetModel("AA1MASTER")
Local oStrAA1 := oMdlAA1:GetStruct() 

aManutPla := {}

oMdlAA1:SetValue("AA1_CODTEC", oMdl190d:GetValue("AA1MASTER","AA1_CODTEC"))
oStrAA1:SetProperty("AA1_CODTEC", MODEL_FIELD_WHEN, {|| .F.})
oStrAA1:SetProperty("AA1_NOMTEC", MODEL_FIELD_WHEN, {|| .F.})

If oMdl190d:GetId() == 'TECA190D' .AND. oModel:GetId() == 'TECA190F' 
	oMdlAA1:SetValue("AA1_CODTEC", oMdl190d:GetValue("AA1MASTER","AA1_CODTEC"))
	oStrAA1:SetProperty("AA1_CODTEC", MODEL_FIELD_WHEN, {|| .F.})
	oStrAA1:SetProperty("AA1_NOMTEC", MODEL_FIELD_WHEN, {|| .F.})
	oMdlDTA:SetValue("DTA_DTINI",dDataBase)
	oMdlDTA:SetValue("DTA_DTFIM",dDataBase)
EndIf

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT190GDef
@description Criação dos campos
@return aRet
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT190GDef(cTable, lAtualiza)
Local aRet		:= {}
Local nAux 		:= 0 
Local lCampHrs	:= TecABBPRHR()

Default lAtualiza := .F.

If lAtualiza
	oMdl190d := Nil
	oMdl190d := FwModelActive()
EndIf

If cTable == "AA1"
	aRet := AT190DDef(cTable) 
ElseIf cTable == "ALC"

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0003		//"Agenda"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0003		//"Agenda"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_SITABB"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "BT"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "BT"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_VALID] := {||At330AGtLA()}
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "BR_VERDE"}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0005		//"Data da Alocação"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0005		//"Data da Alocação"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_DATREF"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| dDataBase}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0006}	//"Dia que o atendente estará alocado."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0007	//"Dia da Semana"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0007	//"Dia da Semana"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_SEMANA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 15
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| TECCdow(Dow(dDataBase))}
	aRet[nAux][DEF_CAN_CHANGE] := .F.

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0008	//"Hora de Entrada"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0008	//"Hora de Entrada"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_ENTRADA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 5
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| !Empty( At190dGVal("ALCDETAIL", "ALC_DATREF"))}
	aRet[nAux][DEF_CODEBLOCK_VALID] := {|oMdl,cField,xNewValue| At190dHora(oMdl,cField,xNewValue)}
	aRet[nAux][DEF_OBRIGAT] := .T.	
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "04"
	aRet[nAux][DEF_PICTURE] := "99:99"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0009}	//"Horario inicial da agenda"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0010	//"Hora de Saída"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0010	//"Hora de Saída"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_SAIDA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 5
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| !Empty( At190dGVal("ALCDETAIL", "ALC_DATREF"))}
	aRet[nAux][DEF_CODEBLOCK_VALID] := {|oMdl,cField,xNewValue| At190dHora(oMdl,cField,xNewValue)}
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_OBRIGAT] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "05"
	aRet[nAux][DEF_PICTURE] := "99:99"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0011}	//"Horario final da agenda"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0012 //"Turno" 
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0012//"Turno" 
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_TURNO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 3
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_OBRIGAT] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "06"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| GetTurnTGY( "TURNO" ) }
	aRet[nAux][DEF_CAN_CHANGE] := .T.
    aRet[nAux][DEF_LOOKUP] := "SR6   "
	aRet[nAux][DEF_HELP] := {STR0013}	//"Selecione o turno do atendente."

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0014  //"Sequencia"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0014 //"Sequencia"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_SEQ"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 2
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_OBRIGAT] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| GetTurnTGY( "SEQ" ) }
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| WhensALC("ALC_TURNO")}
	aRet[nAux][DEF_ORDEM] := "07"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_LOOKUP] := "T19SEQ"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0015}	//"Selecione a Sequencia do Turno"

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0016	//"Tipo"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0016	//"Tipo"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_TIPO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_LISTA_VAL] := {"S="+STR0017,"N="+STR0044} //"Trabalhado"#"Não Trabalhado"
	aRet[nAux][DEF_COMBO_VAL] := {"S="+STR0017,"N="+STR0044} //"Trabalhado"#"Não Trabalhado"
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "S" }
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_ORDEM] := "08"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T.}
	aRet[nAux][DEF_HELP] := {STR0023}	//"Tipo de dia: Trabalhado, não trabalhado, folga ou DSR."

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0024  //"Total de Horas"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0024 //"Total de Horas"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_TOTHRS"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := IIF(lCampHrs, TamSX3("TFF_QTDHRS")[1], 5)
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "09"
	aRet[nAux][DEF_PICTURE] := "99:99"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
    aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F.}

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0053 //"Saída intervalo"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0053 //"Saída intervalo"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_INTERV"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_LISTA_VAL] := {"S="+STR0055,"N="+STR0056}
	aRet[nAux][DEF_COMBO_VAL] := {"S="+STR0055,"N="+STR0056}
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "N" }
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_ORDEM] := "10"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T.}
	aRet[nAux][DEF_HELP] := {STR0054} //"Este campo replica a funcionalidade do campo 1a.S.Interb na Tabela de Horários. Marque-o como SIM caso exista outra alocação avulsa e o período entre as duas alocações represente o intervalo. Ex: 08 as 12 / 13 as 18 Se das 12 as 13 não for intervalo, deve-se informar NÃO"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0057		//"Data Dia"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0057		//"Data Dia"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_DATDIA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| dDataBase}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "11"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0006}	//"Dia que o atendente estará alocado."


	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0058	//"Intrajornada?"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0058	//"Intrajornada?"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_HEPLAN"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_LISTA_VAL] := {"1="+STR0055,"2="+STR0056} //"Sim"##"Não"
	aRet[nAux][DEF_COMBO_VAL] := {"1="+STR0055,"2="+STR0056} //"Sim"##"Não"
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "1" }
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_ORDEM] := "12"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T.}
	aRet[nAux][DEF_HELP] := {STR0059}	//"Caso selecione como Sim, o sistema ira quebrar as agendas e realizar as manutenções planejadas, caso tenha."

ElseIf cTable == 'TOT'
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0025  //"Saldo de Horas"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0025 //"Saldo de Horas"
	aRet[nAux][DEF_IDENTIFICADOR] := "TOT_SALHRS"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := IIF(lCampHrs, TamSX3("TFF_QTDHRS")[1], 5)
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "99:99"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "00:00" }
    aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F.}

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0035 //"Horas do Contrato" 
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0035 //"Horas do Contrato" 
	aRet[nAux][DEF_IDENTIFICADOR] := "TOT_CTRSAL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := IIF(lCampHrs, TamSX3("TFF_QTDHRS")[1], 5)
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "99:99"
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| POSICIONE("TFF",1,oMdl190d:GetValue("TGYMASTER", "TGY_FILIAL")+oMdl190d:GetValue("TGYMASTER", "TGY_TFFCOD"),"TFF_HRSSAL") }
	aRet[nAux][DEF_CAN_CHANGE] := .F.
    aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F.}

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0034  //"Horas Restantes" 
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0034 //"Horas Restantes" 
	aRet[nAux][DEF_IDENTIFICADOR] := "TOT_RESTSAL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := IIF(lCampHrs, TamSX3("TFF_QTDHRS")[1], 5)
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := "99:99"
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "00:00" }
	aRet[nAux][DEF_CAN_CHANGE] := .F.
    aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F.}
EndIf

Return (aRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT190GCmt
@description Commit do modelo
@return lRet
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT190GCmt(oModel)
Local aHorEsca	:= {}
Local aHorGrid	:= {}
Local aAgenda 	:= {}
Local cEscala	:= ""
Local cTurno	:= ""
Local cSeq		:= ""
Local cTipo		:= ""
Local dDataRef	:= SToD("")
Local dDataAux	:= SToD("")
Local lRet      := .T.
Local lSubtrai	:= .F.
Local lSaida	:= .F.
Local lManut	:= .F.
Local nLinha    := 1
Local nDifHr	:= 0
Local nPrimeira	:= 0
Local nHorTot	:= ""
Local nEscTot	:= ""
Local oMdlAlc   := oModel:GetModel("ALCDETAIL")
Local oMdlAlc19 := oMdl190D:GetModel("ALCDETAIL")
Local nX
Local nY

aManutPla := {}

oMdlAlc19:SetNoInsertLine(.F.)
oMdlAlc19:SetNoDeleteLine(.F.) 
oMdlAlc19:ClearData()
oMdlAlc19:InitLine()

If TableInDic("TXH")
	For nX := 1 To oMdlAlc:Length()
		If nX == nPrimeira
			Exit
		EndIf
		oMdlAlc:GoLine(nX)
		aHorEsca := {}
		lSaida := .F.
		lSubtrai := .F.

		If !oMdlAlc:IsDeleted() .AND. oMdlAlc:GetValue("ALC_HEPLAN") == "1" .AND. oMdlAlc:GetValue("ALC_SITABB") $ cSitABB
			cTurno := oMdlAlc:GetValue("ALC_TURNO")
			cSeq := oMdlAlc:GetValue("ALC_SEQ")
			cTipo := oMdlAlc:GetValue("ALC_TIPO")
			If !At190gTurno(cTurno)
				cEscala := GetEscala(cTurno, cSeq)
			Else
				cEscala := oMdl190d:GetValue("TGYMASTER", "TGY_ESCALA") 
			EndIf	
			nHorTot := TecConvHr(ElapTime( oMdlAlc:GetValue("ALC_ENTRADA") + ":00", oMdlAlc:GetValue("ALC_SAIDA") + ":00"))
			nEscTot := TecConvHr(HorTotEsca( cEscala, cTurno, cSeq, cValToChar(Dow(oMdlAlc:GetValue("ALC_DATREF"))), @aHorEsca ))
			If nHorTot == nEscTot
				If HoraToInt(oMdlAlc:GetValue("ALC_ENTRADA")) > HoraToInt(aHorEsca[1][1]) .OR. HoraToInt(oMdlAlc:GetValue("ALC_SAIDA")) > HoraToInt(aHorEsca[Len(aHorEsca)][2])
					nDifHr := TecConvHr(ElapTime( aHorEsca[1][1] + ":00", oMdlAlc:GetValue("ALC_ENTRADA") + ":00"))
				Else
					nDifHr := TecConvHr(ElapTime( oMdlAlc:GetValue("ALC_ENTRADA") + ":00", aHorEsca[1][1] + ":00"))
					lSubtrai := .T.
				EndIf
				lManut := EscalManut( cEscala, cTurno, cSeq, cValToChar(Dow(oMdlAlc:GetValue("ALC_DATREF"))), aHorEsca, nDifHr, oMdlAlc:GetValue("ALC_DATREF"), lSubtrai, @lSaida, oMdl190d:GetValue("TGYMASTER", "TGY_TFFCOD") )
				If !Empty(cEscala) .AND. VldEscala(0, cEscala, oMdl190d:GetValue("TGYMASTER", "TGY_TFFCOD")) 
					dDataRef := oMdlAlc:GetValue("ALC_DATREF")
					dDataAux := oMdlAlc:GetValue("ALC_DATREF")
					If ViraDiaHR(aHorEsca, nDifHr, lSubtrai)
						For nY := 1 To Len(aHorEsca)
							If nY == 1
								If lSubtrai
									oMdlAlc:LoadValue("ALC_SAIDA", TecConvHr(SubHoras(TecConvHr(aHorEsca[nY][2]), nDifHr)))
								Else
									oMdlAlc:LoadValue("ALC_SAIDA", TecConvHr(SomaHoras(TecConvHr(aHorEsca[nY][2]), nDifHr)))
								EndIf
								If Len(aHorEsca) == 2 .And. oMdlAlc:GetValue("ALC_INTERV") == "N"
									oMdlAlc:LoadValue("ALC_INTERV",	"S")
								EndIf
							Else
								If aHorEsca[nY-1][2] > aHorEsca[nY][1]
									dDataAux := DaySum(dDataAux,1)
								EndIf
								nLinha := oMdlAlc:AddLine()
								If nPrimeira == 0
									nPrimeira := nLinha
								EndIf
								oMdlAlc:GoLine(nLinha)
								oMdlAlc:SetValue("ALC_DATREF", 	dDataRef)
								oMdlAlc:SetValue("ALC_DATDIA", 	dDataAux)
								If lSubtrai
									oMdlAlc:LoadValue("ALC_ENTRADA", TecConvHr(SubHoras(TecConvHr(aHorEsca[nY][1]), nDifHr)))
									oMdlAlc:LoadValue("ALC_SAIDA", 	TecConvHr(SubHoras(TecConvHr(aHorEsca[nY][2]), nDifHr)))
								Else
									oMdlAlc:LoadValue("ALC_ENTRADA", TecConvHr(SomaHoras(TecConvHr(aHorEsca[nY][1]), nDifHr)))
									oMdlAlc:LoadValue("ALC_SAIDA", 	TecConvHr(SomaHoras(TecConvHr(aHorEsca[nY][2]), nDifHr)))
								EndIf
								oMdlAlc:LoadValue("ALC_TIPO",	cTipo)
								oMdlAlc:LoadValue("ALC_SEQ",	cSeq)
								oMdlAlc:LoadValue("ALC_TURNO",	cTurno)
								If lSaida
									oMdlAlc:LoadValue("ALC_HEPLAN",	"1")
								EndIf
							EndIf
							If TecConvHr(aHorEsca[nY][2]) < TecConvHr(aHorEsca[nY][1])
								dDataAux := DaySum(dDataAux,1)
							EndIf
						Next nY 
					EndIf
				EndIf
			EndIf
		EndIf

	Next nX
EndIf

nLinha := 1

For nX := 1 To oMdlAlc:Length()
	oMdlAlc:GoLine(nX)
	
	If !oMdlAlc:IsDeleted()
		AADD( aAgenda, { oMdlAlc:GetValue("ALC_DATREF"),;
						 oMdlAlc:GetValue("ALC_DATDIA"),;
						 oMdlAlc:GetValue("ALC_ENTRADA"),;
						 oMdlAlc:GetValue("ALC_SAIDA"),;
						 oMdlAlc:GetValue("ALC_TIPO"),;
						 oMdlAlc:GetValue("ALC_SEQ"),;
						 oMdlAlc:GetValue("ALC_TURNO"),;
						 oMdlAlc:GetValue("ALC_INTERV"),;
						 oMdlAlc:GetValue("ALC_SITABB")})
	EndIf
Next nX
ASORT(aAgenda,,, { |x, y| x[1] < y[1]} )

For nX := 1 To Len(aAgenda)	
	If !oMdlAlc19:IsEmpty()
		nLinha := oMdlAlc19:AddLine()
	EndIf

	oMdlAlc19:GoLine(nLinha)

	oMdlAlc19:LoadValue("ALC_SITABB", aAgenda[nX][9])
	oMdlAlc19:LoadValue("ALC_GRUPO", 	1)
	oMdlAlc19:LoadValue("ALC_DATREF", aAgenda[nX][1])
	oMdlAlc19:LoadValue("ALC_DATA", 	aAgenda[nX][2])
	oMdlAlc19:LoadValue("ALC_SEMANA", TECCdow(Dow(aAgenda[nX][2])))
	oMdlAlc19:LoadValue("ALC_ENTRADA", aAgenda[nX][3])
	oMdlAlc19:LoadValue("ALC_SAIDA", 	aAgenda[nX][4])
	oMdlAlc19:LoadValue("ALC_TIPO",	aAgenda[nX][5])
	oMdlAlc19:LoadValue("ALC_SEQ",	aAgenda[nX][6])
	oMdlAlc19:LoadValue("ALC_TURNO",	aAgenda[nX][7])
	oMdlAlc19:LoadValue("ALC_INTERV",	aAgenda[nX][8])
Next nX

lRet := At190dExec("GravaAloc2( .F., @xPar, .T., @xPar2, @xPar3 )", @cSitABB, @oMdl190D, @lDelConf)

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT190GHrsT
@description Função de Calculo para o total de horas do periodo
@return nTot	
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT190GHrsT( cCampo )
Local oModel	:= FwModelActive()
Local oMdlALC	:= oModel:GetModel("ALCDETAIL")
Local cRet		:= "00:00"

If !Empty(oMdlALC:GetValue("ALC_ENTRADA")) .AND. !Empty(oMdlALC:GetValue("ALC_SAIDA"))
	cRet := Left(ElapTime(oMdlALC:GetValue("ALC_ENTRADA")+":00", oMdlALC:GetValue("ALC_SAIDA")+":00"), 5)
EndIf
Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT190GSalH
@description Função de Calculo de saldo de horas
@return nTotal
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT190GSalH( lSubtrai, cOldValue, cNewValue )
Local oModel	:= FwModelActive()
Local oMdlTOT	:= oModel:GetModel("TOTDETAIL")
Local cTotal	:= "00:00"

If lSubtrai
	cTotal := TecConvHr(SomaHoras(SubHoras(TecConvHr(oMdlTOT:GetValue("TOT_SALHRS")), TecConvHr(cOldValue)), TecConvHr(cNewValue)))
Else
	cTotal := TecConvHr(SomaHoras(TecConvHr(oMdlTOT:GetValue("TOT_SALHRS")), TecConvHr(cNewValue)))
EndIf
oMdlTOT:LoadValue("TOT_SALHRS", cTotal)

oMdlTot:LoadValue("TOT_RESTSAL", TecConvHr(SubHoras(TecConvHr(oMdlTOT:GetValue("TOT_CTRSAL")), TecConvHr(cTotal))))

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT190GPrAL
@description Realiza validações da linha do modelo ALC
@return lRet
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT190GPrAL(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)
Local lRet 			:= .T.
Local aSaveLines	:= FWSaveRows()
Local aArea			:= GetArea()
Local oMdlTOT		:= Nil
Local lSubtrai		:= .F.

If !lAlocAvuls
	If cAcao == 'DELETE'
		If TecConvHr(oMdlG:GetValue("ALC_TOTHRS")) > 0
			oMdlTOT := oMdlG:GetModel():GetModel("TOTDETAIL")
			oMdlTOT:LoadValue("TOT_SALHRS", TecConvHr(SubHoras(TecConvHr(oMdlTOT:GetValue("TOT_SALHRS")), TecConvHr(oMdlG:GetValue("ALC_TOTHRS")))))
			oMdlTOT:LoadValue("TOT_RESTSAL", TecConvHr(SubHoras(TecConvHr(oMdlTOT:GetValue("TOT_CTRSAL")), TecConvHr(oMdlTOT:GetValue("TOT_SALHRS")))))
		EndIf
	EndIf

	If cAcao == 'UNDELETE'
		If TecConvHr(oMdlG:GetValue("ALC_TOTHRS")) > 0
			oMdlTOT := oMdlG:GetModel():GetModel("TOTDETAIL")
			oMdlTOT:LoadValue("TOT_SALHRS", TecConvHr(SomaHoras(TecConvHr(oMdlTOT:GetValue("TOT_SALHRS")), TecConvHr(oMdlG:GetValue("ALC_TOTHRS")))))
			oMdlTOT:LoadValue("TOT_RESTSAL", TecConvHr(SubHoras(TecConvHr(oMdlTOT:GetValue("TOT_CTRSAL")), TecConvHr(oMdlTOT:GetValue("TOT_SALHRS")))))
		EndIf
	EndIf
EndIf
If cAcao == 'SETVALUE'

	If cCampo == "ALC_TURNO"
		If !EMPTY(xValue)
			lRet := CheckSR6(AT190dLimp(xValue))
			If !lRet
				Help(,,"AT190GPrAL",, STR0026 ,1,0) //"O turno digitado não foi encontrado."
			EndIf
		EndIf
		WhensALC("ALC_TURNO")
	ElseIf cCampo == "ALC_SEQ"
		If !EMPTY(xValue)
			lRet := CheckSPJ(AT190dLimp(xValue), , oMdlG:GetValue("ALC_TURNO") )
			If !lRet
				Help(,,"AT190GPrAL",, STR0027 ,1,0) //"A sequencia digitada não foi encontrada."
			EndIf
		EndIf
	EndIf
	If (cCampo == "ALC_ENTRADA" .OR. cCampo == "ALC_SAIDA")
		If LEN(ALLTRIM(xValue)) == 5 .AND. AT(":",xValue) == 0
			lRet := .F.
			Help( " ", 1, "AT190GPrAL", Nil, STR0038, 1 )	//"Horário inválido. Por favor, insira um horário no formato HH:MM"
		EndIf
		If AT(":",xValue) == 0 .AND. AtJustNum(Alltrim(xValue)) == Alltrim(xValue) .AND. lRet
			If LEN(Alltrim(xValue)) == 4
				xValue := LEFT(Alltrim(xValue),2) + ":" + RIGHT(Alltrim(xValue),2)
			ElseIf LEN(Alltrim(xValue)) == 2
				xValue := Alltrim(xValue) + ":00"
			ElseIf LEN(Alltrim(xValue)) == 1
				xValue := "0" + Alltrim(xValue) + ":00"
			EndIf
		EndIf
		If lRet
			lRet := AtVldHora(Alltrim(xValue))
		EndIf
	EndIf
	If cCampo == 'ALC_TOTHRS'
		If TecConvHr(xValue) < 0 
			Help(,,"AT190GPrAL",, STR0028 ,1,0) //"O total de Horas do dia não pode ser menor que o total de horas restante."
			lRet := .F.
		EndIf
		If !Empty(xOldValue)
			lSubtrai := .T.
		EndIf
		If !lAlocAvuls
			AT190GSalH( lSubtrai, xOldValue, xValue )
		EndIf
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT190GVld
@description Realiza validações do modelo ALC
@return lRet
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT190GVld( oModel )
Return ChecarConf( oModel )
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT190GPoAL
@description Realiza validações pos linha da ALC
@return lRet
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
function AT190GPoAL(oMdlG, nLine, cAcao, cCampo)
Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet      	:= .T.
Local oMdlFull 		:= oMdlG:GetModel()
Local oMdlTOT

If !lAlocAvuls
	oMdlTOT		:= oMdlFull:GetModel("TOTDETAIL")

	If TecConvHr(oMdlG:GetValue("ALC_TOTHRS")) == 0
		Help(,,"AT190GPoAL",, STR0028 ,1,0) //"O total de Horas do dia não pode ser menor que o total de horas restante."
		lRet := .F.
	ElseIf TecConvHr(oMdlTOT:GetValue("TOT_SALHRS")) < 0
		Help(,,"AT190GPoAL",, STR0030 ,1,0) // "O saldo de horas não pode ser negativo"
		lRet := .F.
	ElseIf SubHoras(TecConvHr(oMdlTOT:GetValue("TOT_CTRSAL")), TecConvHr(oMdlTOT:GetValue("TOT_SALHRS"))) < 0
		Help(,,"AT190GPoAL	",, STR0036 ,1,0) // "O Total de Horas usada para aloação não pode ser maior que o do contrato."
		lRet := .F.
	EndIf
EndIF

FWRestRows( aSaveLines )
RestArea(aArea)

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChecarConf
@description Mensagem de espera para fazer a checagem
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function ChecarConf( oModel )
Local lRet := .T.
FwMsgRun(Nil,{|| ChkConf(@lRet, oModel)}, Nil, STR0032) // "Realizando a checagem de conflitos!"
Return lRet
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WhensALC
@description Checa conflitos
@return lOpc
@author Serviços
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ChkConf( lRet, oModel )
Local aFieldsQry := {'AA1_FILIAL','AA1_CODTEC','AA1_NOMTEC','ABB_DTINI','ABB_HRINI','ABB_DTFIM',;
					'ABB_HRFIM','RA_SITFOLH','RA_ADMISSA','RA_DEMISSA','RF_DATAINI','RF_DFEPRO1','RF_DATINI2',;
					'RF_DFEPRO2','RF_DATINI3','RF_DFEPRO3','R8_DATAINI','R8_DATAFIM',;
					"DTINI", "DTFIM", 'HRINI' ,"HRFIM", "ATIVO", "DTREF"}
Local cFilTFF := xFilial( "TFF", cFilAnt )
Local aArrConfl := {}
Local aArrDem := {}
Local aArrAdi := {}
Local aArrAfast := {}
Local aArrDFer := {}
Local aArrDFer2 := {}
Local aArrDFer3 := {}
Local aAuxAgenda	:= {}
Local aAux		:= {}
Local aAgenda	:= {}
Local aAuxDT	:= {}
Local dUltAloc
Local dDtAlIni
Local dDtAlFim
Local dDtCnfFim
Local dDtCnfIni
Local dDatIni
Local dDatFim
Local dMenorDt
Local lHasConfl	:= .F.
Local lRestrRH	:= .F.
Local oMdlALC	:= oModel:GetModel("ALCDETAIL")
Local cCodTec	:= FwFldGet("AA1_CODTEC")
Local cCodTff	:= oMdl190d:GetValue("TGYMASTER", "TGY_TFFCOD")
Local cNotIdcFal	:= ""
Local nX
Local nJ
Local nC
Local nPos
Local nTXBDtIni
Local nTXBDtFim
Local nPosdIni
Local nPosdFim
Local nPosHrIni
Local nPosHrFim
Local nPosDtRef
Local nHrIniAge
Local nHrIni
Local nHrFimAge
Local nHrFim
Local nAddABB	
Local lGSVERHR := SuperGetMV("MV_GSVERHR",,.F.)
Local lRestrRH := .F.
Local lProcessa := .T.
Local lAterouSeq := .F.
Local lResRHTXB	:= TableInDic("TXB")
Local oView 		:= FwViewActive()
Local lContinua	:= .T.
Local lHelp := .T.
Local nLineBckp := oMdlALC:GetLine()
Local lPergunte	:= .F.
Local nOpc := 1
Local lPostoEnc := .F.
Local dDtEnce	
Local lEnceDT	:= FindFunction("TecEncDtFt") .AND. TecEncDtFt() 
Local lIntermi := .F.
Local nDelet    := 0

SPJ->(dbSetOrder(1))

DbSelectArea("SRA")
SRA->(DbSetOrder(1))

If SRA->(DbSeek(Posicione("AA1",1,xFilial("AA1")+AA1->AA1_CODTEC,"AA1_FUNFIL")+AA1->AA1_CDFUNC))
	If SRA->RA_TPCONTR == "3"
		lIntermi := .T.
	EndIf
EndIf

For nX := 1 To oMdlALC:Length()
	oMdlAlc:GoLine(nX)
	If !oMdlAlc:IsDeleted()
		If ! SPJ->(dbSeek(xFilial("SPJ") + oMdlAlc:GetValue("ALC_TURNO") + oMdlAlc:GetValue("ALC_SEQ")))
				Aviso(STR0049, STR0050 + oMdlAlc:GetValue("ALC_SEQ") + STR0051 + oMdlAlc:GetValue("ALC_TURNO") + STR0052) //Atenção ## a sequência ## do turno ## é inválida
				nOpc := 0
				lRet := .F.
				Exit
		Endif
		If lGSVERHR
			If AsCan( aAgenda,{|e| e[1] == oMdlAlc:GetValue("ALC_DATREF") .AND. ((e[3] <= oMdlALc:GetValue("ALC_ENTRADA") .AND. e[3] >= oMdlALc:GetValue("ALC_ENTRADA"));
					.OR. e[3] <= oMdlALc:GetValue("ALC_SAIDA") .AND. e[3] >= oMdlALc:GetValue("ALC_SAIDA"))}) > 0
				lContinua := .F.
			EndIf
		Else
			If AsCan( aAgenda,{|e| e[1] == oMdlAlc:GetValue("ALC_DATREF")}) > 0 
				lContinua := .F.
			EndIf
		EndIf
		If lIntermi
			aPeriodo := Tec190QPer(AA1->AA1_CDFUNC, AA1->AA1_CODTEC,oMdlAlc:GetValue("ALC_DATREF"), oMdlAlc:GetValue("ALC_DATREF"), Posicione("AA1",1,xFilial("AA1")+AA1->AA1_CODTEC,"AA1_FUNFIL"))
			If Empty(aPeriodo)
				lRet := .F.
				oMdlALC:LoadValue("ALC_SITABB", "BR_AZUL" )
				loop
			Endif	
		EndIf
		AADD( aAgenda, {oMdlAlc:GetValue("ALC_DATREF"),;
						oMdlALc:GetValue("ALC_SAIDA"),;
						oMdlALc:GetValue("ALC_ENTRADA")})
		If lContinua
			cHorIni := oMdlALc:GetValue("ALC_ENTRADA")
			cHorFim := oMdlALc:GetValue("ALC_SAIDA")
			dDatIni := oMdlALc:GetValue("ALC_DATREF")
			dDatFim := If( cHorFim < cHorIni, dDatIni + 1, dDatIni)
			If lEnceDT
				dDtEnce := POSICIONE("TFF",1,cFilTFF+cCodTff,"TFF_DTENCE") 	
			EndIf			

			If lEnceDT .AND. POSICIONE("TFF",1,cFilTFF+cCodTff,"TFF_ENCE") == '1' .AND. dDatIni >= dDtEnce
				nOpc := 0
				lRet := .F.
				lPostoEnc := .T.					
				Help( " ", 1, "AT190GHrsT", Nil,STR0062+DToC(dDtEnce)+STR0063, 1 )	//	"Não é possível gerar nova(s) agenda(s), pois o posto possui encerramento para o dia " ## ". Com isso não é possível gerar agenda após essa data."
			EndIf							
		Else 
			aAteABB := At330AVerABB( dDatIni, dDatFim, cCodTff, cFilTFF, cCodTec, @cNotIdcFal )

			ChkCfltAlc(dDatIni, dDatFim, cCodTec, /*cHoraIni*/, /*cHoraFim*/, .F., @aFieldsQry,;
										@aArrConfl, @aArrDem, @aArrAfast, @aArrDFer, @aArrDFer2, @aArrDFer3,;
										cNotIdcFal,/*lCheckRT*/,/*cFilABB*/,/*dDtRef*/,/*cIdcFal*/,@aArrAdi)
			If !EMPTY(aAteABB)
					aAuxAgenda := ACLONE(aAteABB)
					ASORT(aAuxAgenda,,, { |x, y| x[1] < y[1] } )
				If dDatIni <= aAuxAgenda[1][1] .AND. dDatFim > aAuxAgenda[LEN(aAuxAgenda)][1]
						cSeq := aAuxAgenda[1][8]
						lAterouSeq := .T.
				EndIf
			EndIf

			If lResRHTXB
				nTXBDtIni := AScan(aFieldsQry,{|e| e == 'TXB_DTINI'})
				nTXBDtFim := AScan(aFieldsQry,{|e| e == 'TXB_DTFIM'})
			Endif

			nPosdIni := AScan(aFieldsQry,{|e| e == 'DTINI'})
			nPosdFim := AScan(aFieldsQry,{|e| e == 'DTFIM'})
			nPosHrIni := AScan(aFieldsQry,{|e| e == 'HRINI'})
			nPosHrFim := AScan(aFieldsQry,{|e| e == 'HRFIM'})
			nPosDtRef := AScan(aFieldsQry,{|e| e == 'DTREF'})

			aAux := Array(TAMANHO)
			lRestrRH := .F.

			If !lRestrRH .And. Len(aArrDFer) > 0  
				nPos := Ascan(aArrDFer,{|x| Alltrim(x[1]) == Alltrim(cCodTec) .AND. dDatIni >= x[2] .And. dDatIni <= x[3] } )
				If (lRestrRH :=  nPos > 0)
					lHasConfl := .T.
				EndIf
			EndIf

			If !lRestrRH .And. Len(aArrDFer2) > 0  
				nPos := Ascan(aArrDFer2,{|x| Alltrim(x[1]) == Alltrim(cCodTec) .AND. dDatIni >= x[2] .And. dDatIni <= x[3] } )
				If (lRestrRH :=  nPos > 0)
					lHasConfl := .T.
				EndIf
			EndIf  

			If !lRestrRH .And. Len(aArrDFer3) > 0  
				nPos := Ascan(aArrDFer3,{|x| Alltrim(x[1]) == Alltrim(cCodTec) .AND. dDatIni >= x[2] .And. dDatIni <= x[3] } )
				If (lRestrRH := nPos > 0)
					lHasConfl := .T.
				EndIf
			EndIf

			If !lRestrRH .And. Len(aArrAdi) > 0  
				nPos := Ascan(aArrAdi,{|x| Alltrim(x[1]) == Alltrim(cCodTec) .AND.  dDatIni <= x[2] } )
				If (lRestrRH := nPos > 0)
					lHasConfl := .T.
				EndIf
			EndIf

			If !lRestrRH .And. Len(aArrDem) > 0  
				nPos := Ascan(aArrDem,{|x| Alltrim(x[1]) == Alltrim(cCodTec) .AND.  dDatIni >= x[2] } )
				If (lRestrRH := nPos > 0)
					lHasConfl := .T.
				EndIf
			EndIf

			If !lRestrRH .And. Len(aArrAfast) > 0  
				nPos := Ascan(aArrAfast,{|x| Alltrim(x[1]) == Alltrim(cCodTec) .AND. dDatIni >= x[2] .And. dDatIni <= x[3] } )
				If (lRestrRH := nPos > 0)
					lHasConfl := .T.
				EndIf
			EndIf

			If !lRestrRH .And. Len(aArrConfl) > 0 .And. lResRHTXB
				nPos := Ascan(aArrConfl,{|x| Alltrim(x[2]) == Alltrim(cCodTec) .AND.;
				!Empty(x[nTXBDtIni]) .AND. dDatIni >= sTod(x[nTXBDtIni]) .And.;
				( Empty(x[nTXBDtFim]) .Or. dDatIni <= sTod(x[nTXBDtFim]) ) } )
				If (lRestrRH := nPos > 0)
					lHasConfl := .T.
				EndIf
			EndIf

			If !lRestrRH .And. Len(aArrConfl) > 0  
				nLastPos := 0
				lProcessa := .T.

				Do While lProcessa
					nLastPos++
					nPos := Ascan(aArrConfl,{|x| Alltrim(x[2]) == Alltrim(cCodTec) .And.;
							(dDatIni == x[nPosdIni] .Or.  dDatIni == x[nPosdFim] .Or. dDatFim == x[nPosdIni] .Or.  dDatFim == x[nPosdFim] )}, nLastPos )
					nLastPos := nPos
					If nPos > 0				
						lRestrRH := .T.				
						aAux[EXSABB] := "1"		

						nHrIniAge := VAL(AtJustNum(cHorIni))
						nHrFimAge := VAL(AtJustNum(cHorFim))	
						nHrIni := VAL(AtJustNum(aArrConfl[nPos,nPosHrIni]))
						nHrFim := VAL(AtJustNum(aArrConfl[nPos,nPosHrFim]))
						dDtCnfIni := aArrConfl[nPos,nPosdIni]
						dDtCnfFim := aArrConfl[nPos,nPosdFim]

						dMenorDt := CtoD("")
						aAuxDT := {dDtCnfIni,dDtCnfFim,dDatIni,dDatFim}
						For nC := 1 To LEN(aAuxDT)
							If EMPTY(dMenorDt) .OR. dMenorDt > aAuxDT[nC]
								dMenorDt := aAuxDT[nC]
							EndIf
						Next nC

						nHrIni += 2400 * (dDtCnfIni - dMenorDt)
						nHrFim += 2400 * (dDtCnfFim - dMenorDt)
						nHrIniAge += 2400 * (dDatIni - dMenorDt)
						nHrFimAge += 2400 * (dDatFim - dMenorDt)

						If nHrIniAge >= nHrIni .AND. nHrIniAge <= nHrFim
							lRestrRH := .T.
							aAux[EXSABB] := "1"
							lProcessa := .F.
						ElseIf nHrFimAge >= nHrIni .AND. nHrFimAge <= nHrFim
							lRestrRH := .T.
							aAux[EXSABB] := "1"
							lProcessa := .F.
						ElseIf nHrIniAge <= nHrIni .AND. nHrFimAge >= nHrFim
							lRestrRH := .T.
							aAux[EXSABB] := "1"
							lProcessa := .F.
						ElseIf nHrIniAge >= nHrIni .AND. nHrFimAge <= nHrFim
							lRestrRH := .T.
							aAux[EXSABB] := "1"
							lProcessa := .F.		
						Else
							lRestrRH := .F.
							aAux[EXSABB] := "2"
						EndIf
						If !lGSVERHR .AND. !lRestrRH
							If Ascan(aArrConfl,{|x| Alltrim(x[2]) == Alltrim(cCodTec) .And. (dDatIni == x[nPosDtRef]) }, nLastPos ) > 0
								lRestrRH := .T.
								aAux[EXSABB] := "1"
								lProcessa := .F.
							EndIf
						EndIf			
					Else		
						aAux[EXSABB] := "2"
						lProcessa := .F.
					EndIf
				End 
			Else			
				aAux[EXSABB] := "2"
			EndIf

			If aAux[EXSABB] == "1"
				lHasConfl := .T.
			EndIf	
		EndIf	
	EndIf
	If oMdlALC:Isdeleted()
		nDelet++
	Endif
	oMdlALC:LoadValue("ALC_SITABB", At330ACLgA( , , , lRestrRH))
	If lRestrRH .AND. !lPergunte
		lPergunte := .T.
	EndIf
Next nX

oMdlALC:GoLine(nLineBckp)

If !lHelp .OR. lPergunte
	nOpc := Aviso( STR0039, STR0040, {STR0041, STR0042}) // "Atenção" ## "Uma ou mais agendas possui confilto deseja continuar com as validações ou visualizar as agendas?" ## "Continuar" ## "Visualizar"
EndIf
If nOpc == 1 .And. lRet
	lRet := At190dExec("VldGrvAloc( @xPar, @xPar2 )", @cSitABB, @lDelConf)
else
	lRet := .F.
EndIf
If !lRet .AND. !IsBlind()
	Help(,,"AT190GHrsT",, STR0043 ,1,0) // "Operação Cancelada."
	If lPostoEnc		
		Help( " ", 1, "AT190GHrsT", Nil,STR0062+DToC(dDtEnce)+STR0063, 1 )	//	"Não é possível gerar nova(s) agenda(s), pois o posto possui encerramento para o dia " ## ". Com isso não é possível gerar agenda após essa data."
	EndIf
oView:Refresh("DETAIL_ALC")	
EndIf

IF oMdlALC:Length() == nDelet
	lRet := .F.
	Help(,,"AT190GHrsT",, STR0064 ,1,0) // "Operação Cancelada."
Endif

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WhensALC@description Faz o travamento do campo na estrutura ALC
@return lOpc
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function WhensALC( cCampo )
Local oModel := FwModelActive()
Local oMdlALC := oModel:GetModel("ALCDETAIL")
Local lOpc := .T.

If Empty(oMdlALC:GetValue(cCampo))
	lOpc := .F.
EndIf

Return lOpc

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckSR6
@description Fazer a checagem na tabela SR6 para ver se o registro existe
@return lRet
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function CheckSR6( xValue, cFilCtr )
Local cQry
Local lRet := .T.
Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
Default cFilCtr := cFilAnt
cQry := " SELECT 1 "
cQry += " FROM " + RetSqlName("SR6") + " SR6 "
cQry += " WHERE SR6.R6_FILIAL = '" +  xFilial('SR6', IIF(lMV_MultFil,cFilCtr,cFilAnt)) + "' AND "
cQry += " SR6.D_E_L_E_T_ = ' ' "
cQry += " AND SR6.R6_TURNO = '" + xValue + "' "
If (QryEOF(cQry))
	lRet := .F.
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckSPJ
@description Fazer a checagem na tabela SPJ para ver se o registro existe
@return lRet
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function CheckSPJ( xValue, cFilCtr, cTurno )
Local cQry
Local lRet := .T.
Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
Default cFilCtr := cFilAnt
cQry := " SELECT 1 "
cQry += " FROM " + RetSqlName("SPJ") + " SPJ "
cQry += " WHERE SPJ.PJ_FILIAL = '" +  xFilial('SPJ', IIF(lMV_MultFil,cFilCtr,cFilAnt)) + "' AND "
cQry += " SPJ.D_E_L_E_T_ = ' ' "
cQry += " AND SPJ.PJ_TURNO = '" + cTurno + "' "
cQry += " AND SPJ.PJ_SEMANA = '" + xValue + "' "
If (QryEOF(cQry))
	lRet := .F.
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} QryEOF()

Executa uma qry e retorna se EOF

@author boiani
@since 29/07/2019
/*/
//------------------------------------------------------------------------------
Static Function QryEOF(cSql, lChangeQry)
Local lRet := .F.
Local cAliasQry := GetNextAlias()
Default lChangeQry := .T.
If lChangeQry
	cSql := ChangeQuery(cSql)
EndIf
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
lRet := (cAliasQry)->(EOF())
(cAliasQry)->(DbCloseArea())
Return lRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTurnTGY
@description retorno do ultimo turno da TGY
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function GetTurnTGY( cCampo )
Local cQry		:= ""
Local cRet 		:= ""
Local cAliasQry := GetNextAlias()
Local cContCamp	:= ""
Local cCodTDX	:= ""

If !lAlocAvuls
	cQry := " SELECT TGY.TGY_TURNO, TGY.TGY_ULTALO, TGY.TGY_SEQ, TGY.TGY_CODTDX "
	cQry += " FROM " + RetSqlName("TGY") + " TGY "
	cQry += " WHERE TGY.TGY_FILIAL = '" +  xFilial('TGY') + "' AND "
	cQry += " TGY.D_E_L_E_T_ = ' ' "
	cQry += " AND TGY.TGY_ATEND = '" + oMdl190d:GetValue("AA1MASTER","AA1_CODTEC") + "' "
	cQry += " ORDER BY TGY_ULTALO DESC "

	cQry := ChangeQuery(cQry)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasQry, .F., .T.)
	If !(cAliasQry)->(EOF())
		If cCampo == 'TURNO'
			cRet := (cAliasQry)->TGY_TURNO
		Else
			cRet := (cAliasQry)->TGY_SEQ
		EndIf
		cCodTDX := (cAliasQry)->TGY_CODTDX
	EndIf

	(cAliasQry)->(DbCloseArea())

	If Empty(cRet)
		If cCampo == 'TURNO'
			cContCamp := "TFF_TURNO"
		Else
			cContCamp := "TFF_SEQTRN"
		EndIf
		cRet := POSICIONE("TFF",1,oMdl190d:GetValue("TGYMASTER", "TGY_FILIAL")+oMdl190d:GetValue("TGYMASTER", "TGY_TFFCOD"), cContCamp)
	EndIf
Else
	If VALTYPE(oMdl190D) == "O" .AND. oMdl190D:GetId() = "TECA190D" .AND. !EMPTY(oMdl190D:GetValue("TGYMASTER","TGY_ESCALA"))
		If cCampo == 'TURNO'
			cAliasQry := GetNextAlias()
			cQry := ""
			cQry += " SELECT TDX.TDX_TURNO FROM " + RetSqlName("TDX") + " TDX "
			cQry += " WHERE TDX.D_E_L_E_T_ = ' ' AND TDX.TDX_FILIAL = '" +  xFilial('TDX') + "' AND "
			cQry += " TDX.TDX_CODTDW = '" + oMdl190D:GetValue("TGYMASTER","TGY_ESCALA") + "' "
			cQry := ChangeQuery(cQry)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasQry, .F., .T.)
			If !(cAliasQry)->(EOF())
				cRet := (cAliasQry)->TDX_TURNO
			EndIf
			(cAliasQry)->(DbCloseArea())
		EndIf	
	EndIf	
EndIf 

Return cRet
/*/{Protheus.doc} At190GAlAv()

Função utilizada para instanciar o modelo desconsiderando a alocação por hora

@author boiani
@since 28/08/2020
/*/
//------------------------------------------------------------------
Function At190GAlAv(cCodAtend)

Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},;
                    {.T.,STR0046},{.T.,STR0047},{.T.,Nil},{.T.,Nil},{.T.,Nil},; //"Salvar"##"Cancelar"
                    {.T.,Nil},{.T.,Nil},{.T.,Nil}}
lAlocAvuls := .T.
FwExecView( STR0045, "VIEWDEF.TECA190G", MODEL_OPERATION_INSERT, /*oOwner*/, {||.T.}, /*bOk*/, 45, aButtons ) //"Alocação Avulsa"
lAlocAvuls := .F.
Return 

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecGetAvul
@description retorno a variavel static para saber se é alocação por hora ou avulsa.
@author Augusto Albuquerque
@since  13/01/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TecGetAvul()
Return lAlocAvuls

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EscalManut
@description Realiza a logica a popula o array para ser usado na manutenção planejada.
@author Augusto Albuquerque
@since  30/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function EscalManut( cEscala, cTurno, cSeq, cDiaSem, aHorEsca, nDifHr, dDataRef, lSubtrai, lSaida, cCodTFF )
Local cAliasTDX	:= GetNextAlias()
Local cQuery 	:= ""
Local cSpcCdTFF	:= Space(TamSx3("TFF_COD")[1])
Local cHrIni	:= ""
Local cHrFim	:= ""
Local lMtFilTFF := TXH->( ColumnPos("TXH_MTFIL")) > 0
Local lFeriad   := TXH->( ColumnPos("TXH_FERIAD")) > 0
Local lRet		:= .F.
Local nCount	:= 0
Local nAux		:= 0

cQuery := ""
cQuery += " SELECT TXH.TXH_CODTCU, TXH.TXH_CODTFF, TXH.TXH_HORAFI, TXH.TXH_HORAIN, TXH.TXH_MANUT, TXH.TXH_CODPAI, TXH.TXH_CODIGO, "
cQuery += " TDX.TDX_SEQTUR, TGW.TGW_DIASEM, TGW.TGW_HORINI, TGW.TGW_HORFIM, TGW.TGW_EFETDX "
If lMtFilTFF
	cQuery += " , TXH.TXH_MTFIL "
EndIf
If lFeriad
	cQuery += " , TXH.TXH_FERIAD "
EndIf
cQuery += " FROM " + RetSqlName("TXH") + " TXH "
cQuery += " INNER JOIN " + RetSqlName("TGW") + " TGW "
cQuery += " ON TGW.TGW_FILIAL = '" + xFilial("TGW") + "' "
cQuery += " AND TGW.TGW_COD = TXH.TXH_CODPAI "
cQuery += " AND TGW.TGW_STATUS = '1' "
cQuery += " AND TGW.TGW_DIASEM = '" + cDiaSem + "' "
cQuery += " AND TGW.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN " + RetSqlName("TDX") + " TDX "
cQuery += " ON TDX.TDX_FILIAL = '" + xFilial("TDX") + "' "
cQuery += " AND TDX.TDX_COD = TGW.TGW_EFETDX "
cQuery += " AND TDX.TDX_TURNO = '" + cTurno + "' "
cQuery += " AND TDX.TDX_SEQTUR = '" + cSeq + "' "
cQuery += " AND TDX.TDX_CODTDW = '" + cEscala + "' "
cQuery += " AND TDX.D_E_L_E_T_ = ' ' "
cQuery += " WHERE "
cQuery += " TXH.TXH_FILIAL = '" + xFilial("TXH") + "' "
cQuery += " AND TXH.D_E_L_E_T_ = ' ' "
cQuery += " AND (TXH.TXH_CODTFF = '" + cCodTFF + "' OR TXH.TXH_CODTFF = '" + cSpcCdTFF +"') " 

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTDX, .F., .T.)

While !(cAliasTDX)->(EOF())
	nCount++
	If nCount > 1
		lSaida := .T.
	EndIf
	nAux := At580GEnSa(	(cAliasTDX)->(TGW_EFETDX)	,;
						(cAliasTDX)->(TGW_DIASEM),;
						(cAliasTDX)->(TGW_HORINI),;
						(cAliasTDX)->(TGW_HORFIM) )

	cHrIni	:= aHorEsca[nAux][1]
	cHrFim	:= aHorEsca[nAux][2]
	If (cAliasTDX)->(TGW_HORINI) <> TecConvHr((cAliasTDX)->(TXH_HORAIN))
		cHrIni := IntToHora(Round((HoraToInt((cAliasTDX)->(TXH_HORAIN))-HoraToInt(TecConvHr((cAliasTDX)->(TGW_HORINI))))+HoraToInt(cHrIni),2))
	Endif
	
	If (cAliasTDX)->(TGW_HORFIM) <> TecConvHr((cAliasTDX)->(TXH_HORAFI))
		cHrFim := IntToHora(Round((HoraToInt((cAliasTDX)->(TXH_HORAFI))-HoraToInt(TecConvHr((cAliasTDX)->(TGW_HORFIM))))+HoraToInt(cHrFim),2))
	Endif
	
	AADD(aManutPla, {(cAliasTDX)->(TXH_CODTCU),;	//[1]
					(cAliasTDX)->(TXH_CODTFF),;	//[2]
					IIF(lSubtrai, TecConvHr(SubHoras(TecConvHr(cHrFim), nDifHr)), TecConvHr(SomaHoras(TecConvHr(cHrFim), nDifHr))),;				//[3]
					IIF(lSubtrai, TecConvHr(SubHoras(TecConvHr(cHrIni), nDifHr)), TecConvHr(SomaHoras(TecConvHr(cHrIni), nDifHr))),;				//[4]
					(cAliasTDX)->(TXH_MANUT),;	//[5]
					(cAliasTDX)->(TDX_SEQTUR),;	//[6]
					(cAliasTDX)->(TGW_DIASEM),;	//[7]
					IIF(lSubtrai, SubHoras(TecConvHr( aHorEsca[nAux][1] ), nDifHr), SomaHoras(TecConvHr( aHorEsca[nAux][1] ), nDifHr)),;	//[8]
					IIF(lSubtrai, SubHoras(TecConvHr( aHorEsca[nAux][2] ), nDifHr), SomaHoras(TecConvHr( aHorEsca[nAux][2] ), nDifHr)),;  //[9]
					Iif(lMtFilTFF ,(cAliasTDX)->(TXH_MTFIL),""),; //[10]
					IIF(lFeriad, IIF(EMPTY((cAliasTDX)->(TXH_FERIAD)),"3",(cAliasTDX)->(TXH_FERIAD)), "3"),;	//[11]
					(cAliasTDX)->(TXH_CODPAI),;  //[12]
					(cAliasTDX)->(TXH_CODIGO)})  //[14]
	lRet := .T.
	(cAliasTDX)->(DbSkip())
EndDo
(cAliasTDX)->(DbCloseArea())
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetEscala
@description Retorna a escala conforme o turno e sequencia
@author Augusto Albuquerque
@since  30/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function GetEscala( cTurno, cSeq )
Local cAliasTDX	:= GetNextAlias()
Local cQuery 	:= ""
Local cRet		:= ""

cQuery += " SELECT TDX.TDX_CODTDW "
cQuery += " FROM " + RetSqlName("TDX") + " TDX "
cQuery += " Where TDX.TDX_FILIAL = '" + xFilial("TDX") + "' "
cQuery += " AND TDX.TDX_TURNO = '" + cTurno + "' "
cQuery += " AND TDX.TDX_SEQTUR = '" + cSeq + "' "
cQuery += " AND TDX.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTDX, .F., .T.)

If !(cAliasTDX)->(EOF())
	cRet := (cAliasTDX)->TDX_CODTDW
EndIf
(cAliasTDX)->(DbCloseArea())
Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} HorTotEsca
@description Função para retornar o horario total trabalhado na escala
@author Augusto Albuquerque
@since  30/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function HorTotEsca( cEscala, cTurno, cSeq, cDiaSem, aHorEsca )
Local cAliasTDX	:= GetNextAlias()
Local cQuery 	:= ""
Local cRet		:= TecConvHr(0)
Local cHorIni	:= ""
Local cHorFim	:= ""

cQuery += " SELECT TGW.TGW_HORINI, TGW.TGW_HORFIM "
cQuery += " FROM " + RetSqlName("TDX") + " TDX "
cQuery += " INNER JOIN " + RetSqlName("TGW") + " TGW "
cQuery += " ON TGW.TGW_FILIAL = '" + xFilial('TGW') + "' "
cQuery += " AND TDX.TDX_COD = TGW.TGW_EFETDX "
cQuery += " AND TGW.TGW_STATUS != '3' "
cQuery += " AND TGW.TGW_DIASEM = '" + cDiaSem + "' "
cQuery += " AND TGW.D_E_L_E_T_ = ' ' "
cQuery += " Where TDX.TDX_FILIAL = '" + xFilial("TDX") + "' "
cQuery += " AND TDX.TDX_TURNO = '" + cTurno + "' "
cQuery += " AND TDX.TDX_SEQTUR = '" + cSeq + "' "
cQuery += " AND TDX.TDX_CODTDW = '" + cEscala + "' "
cQuery += " AND TDX.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTDX, .F., .T.)

While !(cAliasTDX)->(EOF())
	If Empty(cHorIni)
		cHorIni := TecConvHr((cAliasTDX)->TGW_HORINI)
	EndIf
	cHorFim := TecConvHr((cAliasTDX)->TGW_HORFIM)
	AADD( aHorEsca, {TecConvHr((cAliasTDX)->TGW_HORINI),;
					TecConvHr((cAliasTDX)->TGW_HORFIM)})
	(cAliasTDX)->(DbSkip())
EndDo
(cAliasTDX)->(DbCloseArea())

If !Empty(cHorIni) .AND. !Empty(cHorFim)
	cRet := ElapTime(cHorIni + ":00", cHorFim + ":00")
EndIf

Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetManutPla
@description retorno a variavel static para ser usada na manutenção planejada.
@author Augusto Albuquerque
@since  30/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function GetManutPla()
Return aManutPla

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT190GManP
@description Retorna se o mesmo deve entrar para a manutenção planejada ou não.
@author Augusto Albuquerque
@since  30/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT190GManP( dDataRef )
Local oModel	:= FwModelActive()
Local oMdlAlc	:= oModel:GetModel("ALCDETAIL")
Local lRet		:= .F.

oMdlAlc:GoLine(1)

If oMdlAlc:SeekLine({{"ALC_DATREF",dDataRef}})
	lRet := oMdlAlc:GetValue("ALC_HEPLAN") == "1"
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViraDiaHR
@description Verifica se a virada de dia é na mesma entrada ou saida
@author Augusto Albuquerque
@since  14/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ViraDiaHR(aHorEsca, nDifHr, lSubtrai)
Local lRet		:= .T.
Local cAux		:= ""
Local nViraNew 	:= 0
Local nViraEsc 	:= 0
Local nHorIni	:= 0
Local nHorFim	:= 0
Local nHrInPr	:= 0
Local nTotal	:= Len(aHorEsca)
Local nX

For nX := 1 To nTotal
	nHorIni := TecConvHr(aHorEsca[nX][1])
	nHorFim := TecConvHr(aHorEsca[nX][2])
	If  nHorIni > nHorFim .OR. (nX < nTotal .AND. nHorFim > TecConvHr(aHorEsca[nX+1][1]) )
		nViraEsc := nX
	EndIf

	If lSubtrai
		If (nHorIni := SubHoras(nHorIni, nDifHr)) >= 24
			cAux := "0." + (right(TecConvHr(nHorIni), 2)) 
			nHorIni := (24 - Int(nHorIni)) + TecConvHr(cAux)
		EndIf

		If (nHorFim := SubHoras(nHorFim, nDifHr)) >= 24
			cAux := "0." + (right(TecConvHr(nHorFim), 2)) 
			nHorFim := (24 - Int(nHorFim)) + TecConvHr(cAux)
		EndIf

		If nX < nTotal .AND. (nHrInPr := SubHoras(TecConvHr(aHorEsca[nX+1][1]), nDifHr)) >= 24
			cAux := "0." + (right(TecConvHr(nHrInPr), 2)) 
			nHrInPr := (24 - Int(nHrInPr)) + TecConvHr(cAux)
		EndIf
	Else
		If (nHorIni := SomaHoras(nHorIni, nDifHr)) >= 24
			cAux := "0." + (right(TecConvHr(nHorIni), 2)) 
			nHorIni := (24 - Int(nHorIni)) + TecConvHr(cAux)
		EndIf

		If (nHorFim := SomaHoras(nHorFim, nDifHr)) >= 24
			cAux := "0." + (right(TecConvHr(nHorFim), 2)) 
			nHorFim := (24 - Int(nHorFim)) + TecConvHr(cAux)
		EndIf

		If nX < nTotal .AND. (nHrInPr := SomaHoras(TecConvHr(aHorEsca[nX+1][1]), nDifHr)) >= 24
			cAux := "0." + (right(TecConvHr(nHrInPr), 2)) 
			nHrInPr := (24 - Int(nHrInPr)) + TecConvHr(cAux)
		EndIf
	EndIf

	If nHorIni > nHorFim .OR. ( nX < nTotal .AND. nHorFim > nHrInPr )
		nViraNew := nX
	EndIf
Next nX

lRet := nViraEsc == nViraNew

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViraDiaHR
@description Verifica se o turno utilizado é diferente da escala do posto
@author Luiz Gabriel
@since  26/05/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At190gTurno(cTurno)
Local lRet		:= .T.
Local cAliasQry := GetNextAlias()
Local cQry		:= ""

cQry := ""
cQry += " SELECT TDX.TDX_TURNO FROM " + RetSqlName("TDX") + " TDX "
cQry += " WHERE TDX.D_E_L_E_T_ = ' ' AND TDX.TDX_FILIAL = '" +  xFilial('TDX') + "' AND "
cQry += " TDX.TDX_CODTDW = '" + oMdl190D:GetValue("TGYMASTER","TGY_ESCALA") + "' "
cQry += " AND TDX.TDX_TURNO = '" + cTurno + "' "

cQry := ChangeQuery(cQry)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasQry, .F., .T.)
If (cAliasQry)->(EOF())
	lRet := .F.
EndIf
(cAliasQry)->(DbCloseArea())
Return lRet
