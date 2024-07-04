#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "ATFA036L.CH"
#INCLUDE "FWLIBVERSION.CH"

#DEFINE OPER_VISUA		1 //Visualiza
#DEFINE OPER_BAIXA		2 //Baixa Normal
#DEFINE OPER_BXLOT		3 //Baixa em Lote
#DEFINE OPER_CANC		4 //Cancelar Normal
#DEFINE OPER_CANCM		5 //Cancelar Multiplas
#DEFINE OPER_CANLT		6 //Cancelar em lote

STATIC lIsRussia	:= cPaisLoc == "RUS" // CAZARINI - Flag to indicate if is Russia location
Static __xParLot
STATIC lGerPVBra	:= SuperGetMV("MV_ATFGRPV",.F.,.F.) .And. cPaisLoc == "BRA"
Static lExisCPC31	:= NIL

Static __lMetric	:= FwLibVersion() >= "20210517" .And. GetSrvVersion() >= "19.3.0.6"
/*/{Protheus.doc} ATFA036L 

Rotina de Baixa de Ativos em Lote

@author marylly.araujo 
@since 24/03/2014
@version 1.0
/*/

Function ATFA036L()

// Manter esta função para ser posível geral patch

Return

/*{Protheus.doc} ModelDef

Definição do Modelo de Dados u da Rotina de Baixa de Ativos

@author marylly.araujo
@since 25/03/2014
@version 1.0
*/

Static Function ModelDef()
Local oModel	:= Nil
Local aCposTrava:= {}
Local nX		:= 0

/*
 * Cria o objeto do Modelo de Dados
 */
Local oStruLote	:= FWFormStruct(1,'FN8')	//Tipos
Local oStrCab		:= AF036StFN6("FN6")	// Master
Local oStrTip		:= AF036StTip("FN7")	// Tipos
Local oStrSld		:= AF036StVal("FN7")	// Valor
Local oStruPar		:= AT36StPar()
Local oStrVlAcum	:= AT36StVlAc()			// Valores Acumulados

Local cVldBxa
Local bVldBxa
Local cVldCli
Local bVldCli
Local lMostraVal := .T.	

If type('__nOper') == 'U'
	__nOper := 3
EndIf

//Só desabilita o grid de valor se for Brasil e o parâmetro 12 for = 2
If __nOper == OPER_BXLOT .And. cPaisLoc == "BRA" .And. Type("mv_par12") == "N"
	lMostraVal := (mv_par12==1)
EndIF

/*
 * Gatilhos
 */
oStruLote:AddTrigger( 'FN8_BAIXA'	,'FN8_BAIXA'	, { || .T. } , {|| AF036LGatL('_BAIXA')})
oStruLote:AddTrigger( 'FN8_MOTIVO'	,'FN8_MOTIVO'	, { || .T. } , {|| AF036LGatL('_MOTIVO')})
oStruLote:AddTrigger( 'FN8_DTBAIX'	,'FN8_DTBAIX'	, { || .T. } , {|| AF036LGatL('_DTBAIX')})
oStruLote:AddTrigger( 'FN8_DEPREC'	,'FN8_DEPREC'	, { || .T. } , {|| AF036LGatL('_DEPREC')})

oStruLote:AddTrigger( 'FN8_GERANF'	,'FN8_GERANF'	, { || .T. } , {|| AF036LGatL('_GERANF')})
oStruLote:AddTrigger( 'FN8_NUMNF'	,'FN8_NUMNF'	, { || .T. } , {|| AF036LGatL('_NUMNF'	)})
oStruLote:AddTrigger( 'FN8_SERIE'	,'FN8_SERIE'	, { || .T. } , {|| AF036LGatL('_SERIE'	)})
oStruLote:AddTrigger( 'FN8_VALNF'	,'FN8_VALNF'	, { || .T. } , {|| AF036LGatL('_VALNF'	)})

oStruLote:AddTrigger( 'FN8_CLIENT'	,'FN8_CLIENT'	, { || .T. } , {|| AF036LGatL('_CLIENT')})
oStruLote:AddTrigger( 'FN8_LOJA'	,'FN8_LOJA'		, { || .T. } , {|| AF036LGatL('_LOJA'	)})
oStruLote:AddTrigger( 'FN8_CNDPAG'	,'FN8_CNDPAG'	, { || .T. } , {|| AF036LGatL('_CNDPAG'	)})
oStruLote:AddTrigger( 'FN8_TESSAI'	,'FN8_TESSAI'	, { || .T. } , {|| AF036LGatL('_TESSAI'	)})
oStruLote:AddTrigger( 'FN8_NATURE'	,'FN8_NATURE'	, { || .T. } , {|| AF036LGatL('_NATURE'	)})

If lIsRussia .And. __nOper == OPER_BXLOT .And. MV_PAR12 == 1
	//Depreciation rate must be 0 if depreciation bonus
	oStruLote:SetProperty('FN8_BAIXA'	,MODEL_FIELD_VALID	, {|| M->FN8_BAIXA == 0 })
	oStruLote:SetProperty('FN8_BAIXA'	,MODEL_FIELD_INIT	, {|| 0 })
	oStruLote:SetProperty('FN8_DEPREC'	,MODEL_FIELD_INIT	, {|| "0" })
	oStruLote:SetProperty('FN8_MOTIVO'	,MODEL_FIELD_INIT	, {|| "09" })
	
	aCposTrava	:= FWFormStruct(1,'FN8'):GetFields()
	For nX := 1 To Len(aCposTrava)
		oStruLote:SetProperty(Alltrim(aCposTrava[nX][3]), MODEL_FIELD_WHEN, {|| .F. })
	Next nX
	
	oStrCab:SetProperty('FN6_DTBAIX', MODEL_FIELD_WHEN, {|| .F. })
Else
	// necessario fazer chamada da funcao FWBuildFeature quando utiliza variavel de memoria - Neste caso Valid do campo 
	//	oStruLote:SetProperty('FN8_BAIXA'	,MODEL_FIELD_VALID, {|| Vazio() .Or. (Positivo() .And. M->FN8_BAIXA <= 100) })
	cVldBxa := "(Vazio() .Or. (Positivo() .And. M->FN8_BAIXA <= 100))"
	bVldBxa := FWBuildFeature( STRUCT_FEATURE_VALID, cVldBxa )
	oStruLote:SetProperty('FN8_BAIXA',MODEL_FIELD_VALID,bVldBxa)
EndIf
// necessario fazer chamada da funcao FWBuildFeature quando utiliza variavel de memoria - Neste caso Valid do campo 
//oStruLote:SetProperty('FN8_CLIENT'	,MODEL_FIELD_VALID, {|| ExistCpo('SA1',M->FN8_CLIENTE+RTRIM(M->FN8_LOJA),,,,!EMPTY(M->FN8_LOJA)) })
cVldCli := "ExistCpo('SA1',M->FN8_CLIENT+RTRIM(M->FN8_LOJA),,,,!EMPTY(M->FN8_LOJA))"
bVldCli := FWBuildFeature( STRUCT_FEATURE_VALID, cVldCli )
oStruLote:SetProperty('FN8_CLIENT',MODEL_FIELD_VALID,bVldCli)

oStruLote:AddField(STR0002,STR0001 , 'OK', 'L', 1, 0, {  |oModel| AF036AMARK(oModel) }, , , .F., , .F., .F., .F., , )//"Marca/Desmarca Todos"#//'Seleção'

/*
 * Adicional campo OK para controle da operação
 */
bValid := FWBuildFeature(STRUCT_FEATURE_VALID,"AF036TMARK()")
oStrCab:AddField(STR0003,STR0001 , 'OK', 'L', 1, 0, bValid, ,, .F., , .F., .F., .F., , )//'Baixa?'#//'Seleção'
bValid := FWBuildFeature(STRUCT_FEATURE_VALID,"AF036LMARK()")
oStrTip:AddField(STR0003,STR0001 , 'OK', 'L', 1, 0, bValid, , , .F., , .F., .F., .F., , )//'Baixa?'#//'Seleção'

//--------------------------------------------------------------------------------------------
// Desabilita o preenchimento do campo Natureza se não gerar nota e a TES não gerar duplicata
//--------------------------------------------------------------------------------------------
If __nOper == OPER_BXLOT
	oStruLote:SetProperty('FN8_NATURE'	,MODEL_FIELD_WHEN, {|| M->FN8_GERANF == '1' .And. GetAdvFVal("SF4","F4_DUPLIC",XFilial("SF4")+M->FN8_TESSAI,1,"") == 'S' })
	oStrCab:SetProperty('FN6_NATURE'	,MODEL_FIELD_WHEN, {|| oModel:GetModel("FN6ATIVOS"):GetValue("FN6_GERANF") == '1' .And. GetAdvFVal("SF4","F4_DUPLIC",XFilial("SF4")+oModel:GetModel("FN6ATIVOS"):GetValue("FN6_TESSAI"),1,"") == 'S' })
EndIf

/*
 * Criação do Modelo de Dados
 */
oModel := MPFormModel():New('ATFA036L', /*bPreValidacao*/,{ |oModel| AF036LPos(oModel) } /*bPosValidacao*/, { |oModel| AF036GRVLT( oModel ) } /*bGravacao*/ , /*bCancel*/ )

oModel:AddFields('PARAMETROS',/*cOwner*/,oStruPar,/*bPreVld*/,/*bPosVld*/,{|oModel| AF036LtPR( oModel )})

oModel:AddFields('FN8LOTE','PARAMETROS',oStruLote,/*bPreVld*/,/*bPosVld*/,{|oModel| AF036LtCb( oModel )})


/*
 * Atribui os valores para carga do campo - FN6ATIVOS
 */
oModel:AddGrid('FN6ATIVOS'	,'FN8LOTE'		,oStrCab)
oModel:AddGrid('VLRACUM'	,'FN6ATIVOS'	,oStrVlAcum,,,,, {|| {}} )
oModel:GetModel('FN6ATIVOS'):SetLoad({|oModel| AF036Atv( oModel )})

/*
 * Adiciona ao modelo uma estrutura de formulário de edição por grid
 */
oModel:AddGrid('FN7TIPO'	,'FN6ATIVOS',oStrTip	,,,,, {|oModel|AF036LtLt( oModel ) } )  //AF036LtLt 
oModel:AddGrid('FN7VALOR'	,'FN7TIPO'  ,oStrSld	,,,,, {|oModel|AF036LtLv( oModel ) } )

/*
 * Descrição
 */
oModel:SetDescription(STR0004) // "Baixa de Ativos"
oModel:GetModel('PARAMETROS'):SetDescription( STR0005 )	// "Parâmetros de Filtro de Ativo para Baixa em Lote"
oModel:GetModel('FN8LOTE'  ):SetDescription( STR0005 )	// "Parâmetros de Filtro de Ativo para Baixa em Lote"
oModel:GetModel('FN6ATIVOS'):SetDescription( STR0006 )	// 'Informações da Baixa de Ativo em Lote'

oModel:GetModel('FN7TIPO'  ):SetDescription( STR0007 )	// 'Cabeçalho da Baixa do Ativo'
oModel:GetModel('FN7VALOR' ):SetDescription( STR0008 ) // 'Tipos de Ativos'
oModel:GetModel('VLRACUM' ):SetDescription( STR0010 ) // 'Cálculo de Valores Acumulados do Ativo'

/*
 * Desabilita a Gravação automatica dos Model FN6ATIVOS / FN7TIPO / FN7VALOR
 */
oModel:GetModel( 'PARAMETROS' ):SetOnlyQuery ( .T. )
oModel:GetModel( 'FN8LOTE'	):SetOnlyQuery ( .T. )
oModel:GetModel( 'FN6ATIVOS'):SetOnlyQuery ( .T. )

oModel:GetModel( 'FN7TIPO'	):SetOnlyQuery ( .T. )
oModel:GetModel( 'FN7VALOR'	):SetOnlyQuery ( .T. )

oModel:GetModel( 'VLRACUM' ):SetOptional( .T. )

oModel:SetPrimaryKey({"FN8_FILIAL","FN8_LOTE"})

If lMostraVal
	oModel:SetActivate( { |oModel| AT36LAct(oModel) } )
EndIf

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} Af036CodBx

Encontra o Próximo código de LOTE

@author Totvs

@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function Af036CodLT()
Local aArea 		:= GetArea()
Local aAreaFN8 	:= FN8->(GetArea())
Local cCodBx		:= ""
FN8->(dbSetOrder(1))

cCodBx := GETSXENUM("FN8","FN8_LOTE")

While FN8->(dbSeek(xFilial("FN8") + cCodBx ))
	ConfirmSX8()
	cCodBx := GETSXENUM("FN8","FN8_LOTE")
EndDo

RestArea(aAreaFN8)
RestArea(aArea)
Return cCodBx

/*/{Protheus.doc} ViewDef

Definição da Interface da Rotina de Baixa de Ativos (Cancelamento de Múltiplas Baixas)

@author marylly.araujo
@since 24/03/2014
@version 1.0
/*/

Static Function ViewDef()
/*
 * Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
 */
Local oModel		:= FWLoadModel( 'ATFA036L' )
Local oView 		:= Nil

/*
 * Cria a estrutura de dados que será utilizada na View
 */
Local oStrLote		:= FWFormStruct(2, 'FN8' )	//Tipos
Local oStrFN6		:= FWFormStruct(2, 'FN6' )	//Cadastro
Local oStrTipos		:= FWFormStruct(2, 'FN7' )	//Tipos
Local oStrSaldos	:= FWFormStruct(2, 'FN7' )	//Saldos

/*
 * Variáveis de Apoio a Criação de Botões Customizados
 */
Local nBt			:= 0
Local aUsButtons	:= {}
Local lMostraVal 	:= .T.	

//Só desabilita o grid de valor se for Brasil e o parâmetro 12 for = 2
If __nOper == OPER_BXLOT .And. cPaisLoc == "BRA" .And. Type("mv_par12") == "N"
	lMostraVal := (mv_par12==1)
EndIF
/*
 * Remove Campos não Usados - Cabeçalho da Baixa do Ativo
 */
oStrLote:RemoveField( 'FN8_STATUS' )

If lIsRussia .And. __nOper == OPER_BXLOT
	Pergunte("AFA036LOTE", .F.)
	//Rate can't be changed if depreciation bonus
	If MV_PAR12 == 1
		oStrLote:RemoveField( 'FN8_BAIXA' )
		oStrLote:RemoveField( 'FN8_DTBAIX' )
	EndIf
EndIf

/*
 * Remove Campos não Usados - Cabeçalho da Baixa do Ativo
 */
oStrFN6:RemoveField( 'FN6_FILIAL' )
oStrFN6:RemoveField( 'FN6_STATUS' )
If cPaisLoc == "RUS"
	oStrFN6:RemoveField("FN6_NUMNF")
	oStrFN6:RemoveField("FN6_ITEMNF")
EndIf

/*
 * Remove Campos não Usados - Tipos de Ativos
 */
oStrTipos:RemoveField( 'FN7_MOTIVO' )
oStrTipos:RemoveField( 'FN7_SEQREA' )
oStrTipos:RemoveField( 'FN7_SEQ'    )
oStrTipos:RemoveField( 'FN7_CITEM'  )
oStrTipos:RemoveField( 'FN7_CBASE'  )
oStrTipos:RemoveField( 'FN7_ITEM'   )
oStrTipos:RemoveField( 'FN7_CODBX'  )
oStrTipos:RemoveField( 'FN7_MOEDA'  )
oStrTipos:RemoveField( 'FN7_FILORI' )
oStrTipos:RemoveField( 'FN7_STATUS' )
If cPaisLoc <> "RUS"
	oStrTipos:RemoveField( 'FN7_PERCBX' )
	oStrTipos:RemoveField( 'FN7_VLBAIX' )
EndIf
oStrTipos:RemoveField( 'FN7_VLDEPR' )
oStrTipos:RemoveField( 'FN7_VLATU'  )
oStrTipos:RemoveField( 'FN7_DTBAIX' )
oStrTipos:RemoveField( 'FN7_VLRESI'  )

/*
 * Remove Campos não Usados - Saldos de Ativos
 */
oStrSaldos:RemoveField( 'FN7_STATUS' )
oStrSaldos:RemoveField( 'FN7_FILORI' )
oStrSaldos:RemoveField( 'FN7_DTBAIX' )
oStrSaldos:RemoveField( 'FN7_MOTIVO' )
oStrSaldos:RemoveField( 'FN7_SEQREA' )
oStrSaldos:RemoveField( 'FN7_SEQ'    )
oStrSaldos:RemoveField( 'FN7_TPSALD' )
oStrSaldos:RemoveField( 'FN7_TIPO'   )
oStrSaldos:RemoveField( 'FN7_DESCRI' )
oStrSaldos:RemoveField( 'FN7_CITEM'  )
oStrSaldos:RemoveField( 'FN7_CBASE'  )
oStrSaldos:RemoveField( 'FN7_ITEM'   )
oStrSaldos:RemoveField( 'FN7_CODBX'  )

/*
 * Adiciona Campos Virtuais
 */
oStrLote:AddField( 'OK'	,'10',STR0002,STR0001,, 'Check' ,,,,,"1",,,,,,, ) //'Baixa?'#//'Baixa?'
oStrFN6:AddField( 'OK'	,'01',STR0003,STR0001,, 'Check' ,,,,,,,,,,,, ) //'Baixa?'#//'Baixa?'
oStrTipos:AddField( 'OK','01',STR0003,STR0001,, 'Check' ,,,,,,,,,,,, ) //'Baixa?'#//'Baixa?'

//---------------------------------------------------------------------
// Desabilita a edicao dos dados em tela na baixa/cancelamento em lote
//---------------------------------------------------------------------
If __nOper == OPER_BXLOT
	oStrFN6:SetProperty('FN6_CODBX'	,MVC_VIEW_CANCHANGE,.F. )  
	oStrFN6:SetProperty('FN6_CBASE'	,MVC_VIEW_CANCHANGE,.F. )  
	oStrFN6:SetProperty('FN6_CITEM'	,MVC_VIEW_CANCHANGE,.F. )   
	oStrFN6:SetProperty('FN6_FILORI',MVC_VIEW_CANCHANGE,.F. )
ElseIf __nOper == OPER_CANLT
	oStrLote:SetProperty( '*' ,MVC_VIEW_CANCHANGE,.F. )
	oStrFN6:SetProperty( '*' ,MVC_VIEW_CANCHANGE, .F. )
	oStrTipos:SetProperty( '*' ,MVC_VIEW_CANCHANGE, .F. )
	oStrSaldos:SetProperty( '*' ,MVC_VIEW_CANCHANGE, .F. )
EndIf

/*
 * Cria o objeto de View
 */
oView := FWFormView():New()

/*
 * Define qual o Modelo de dados será utilizado
 */
oView:SetModel(oModel)
oView:AddField('FORM_LOTE'	,oStrLote	,'FN8LOTE'	)	// Informações da Baixa em Lote
oView:AddGrid('GRID_ATIVO'	,oStrFN6	,'FN6ATIVOS')	// Cabeçalho
oView:AddGrid('GRID_TIPOS'	,oStrTipos	,'FN7TIPO'	)	// Tipos de Ativo

If  lMostraVal .And. cPaisLoc <> "RUS" 
	oView:AddGrid('GRID_SALDOS'	,oStrSaldos	,'FN7VALOR'	)	// Saldos de Ativo
EndIf

/*
 * Criar "box" horizontal para receber algum elemento da view
 */
If lMostraVal
	oView:CreateHorizontalBox( 'BOXLOTE',		30) //Lote
	oView:CreateHorizontalBox( 'BOXCABEC',		30) //Cabeçalho

	If cPaisLoc == "RUS" 
		oView:CreateHorizontalBox( 'BOXTIPOS',		40) //Tipos de Ativos
	Else
		oView:CreateHorizontalBox( 'BOXTIPOS',	20) //Tipos de Ativos
		oView:CreateHorizontalBox( 'BOXSALDOS',	20) //Saldos de Ativo
	Endif
Else	
	oView:CreateHorizontalBox( 'BOXLOTE',		30) //Lote
	oView:CreateHorizontalBox( 'BOXCABEC',		50) //Cabeçalho
	oView:CreateHorizontalBox( 'BOXTIPOS',		20) //Tipos de Ativos
EndIf
/*
 * Relaciona o ID da View com o "box" para exibicao
 */
oView:SetOwnerView('FORM_LOTE'		,'BOXLOTE' )	// Informações da Baixa em Lote
oView:SetOwnerView('GRID_ATIVO'		,'BOXCABEC' )	// Cabeçalho da Baixa do Ativo
oView:SetOwnerView('GRID_TIPOS'		,'BOXTIPOS' )	// Tipos de Ativo


If lMostraVal .And. cPaisLoc <> "RUS" 
	oView:SetOwnerView('GRID_SALDOS'	,'BOXSALDOS')	// Saldos do Ativo
EndIf

/*
 * Habilita a exibição do título do submodelo PARAMETROS
 */
oView:EnableTitleView('GRID_ATIVO'	, STR0012 ) //'Ativos Baixados'
oView:EnableTitleView('GRID_TIPOS'	, STR0011 ) //'Tipos de Ativos'

If lMostraVal .And. cPaisLoc <> "RUS"
	oView:EnableTitleView('GRID_SALDOS', STR0013 ) //'Valor de Baixa'	
EndIf
/*
 * Bloqueia a inclusão de novas linhas
 */
oView:SetNoInsertLine('GRID_ATIVO')
oView:SetNoInsertLine('GRID_TIPOS')
If lMostraVal .And. cPaisLoc <> "RUS"
	oView:SetNoInsertLine('GRID_SALDOS')
EndIf

/*
 * Bloqueia a exclusão de linhas do grid
 */
oView:SetNoDeleteLine('GRID_ATIVO')
oView:SetNoDeleteLine('GRID_TIPOS')

If lMostraVal .And. cPaisLoc <> "RUS"
	oView:SetNoDeleteLine('GRID_SALDOS')
EndIf

/*
 * Acrescentando regra de auto-incremento no campo de Item nos Grids
 */
oView:AddIncrementField( 'GRID_TIPOS'	,'FN7_ITEM' )
If lMostraVal .And. cPaisLoc <> "RUS"
	oView:AddIncrementField( 'GRID_SALDOS'	,'FN7_ITEM' )
EndIf

/*
 * Ao mudar de linha de ativo, aplica refresh no grid de Tipos FN7TIPO
 */
oView:SetViewProperty('GRID_ATIVO','CHANGELINE',{{|| A36LRefTip()}} )

/*
 * Na alteração do tipo, atualiza os valores da grid FN7VALOR
 */
If lMostraVal
	oView:SetViewProperty('GRID_TIPOS' , 'CHANGELINE',{{|oModel|AF036ATU(oModel,,,,.T. )}} )
EndIf
/*
 * Fecha a tela apos a gravação
 */
oView:SetCloseOnOk({||.T.})

/*
 * Inclusão Botões na Ações Relacionadas da Baixa em lote.
 */
If ExistBlock("AF036AUTBT")
	aUsButtons := ExecBlock("AF036AUTBT",.F.,.F.)
	If ValType(aUsButtons) == "A"
		For nBt := 1 To Len(aUsButtons) 
			oView:AddUserButton( aUsButtons[nBt][1], aUsButtons[nBt][3], aUsButtons[nBt][2],NIL,NIL)
		Next nBt
	Endif
EndIf

//----------------------------------------------------------------------------------
// Tratamento para permitir a confirmação do cancelamento da baixa, pois o processo
// é de alteração, porém o campo FN6_STATUS não é mudado em tela e sim na gravação
//----------------------------------------------------------------------------------
If __nOper == OPER_CANLT
	oView:lModify := .T.
	oView:oModel:lModify := .T.
EndIf

Return oView

/*/{Protheus.doc} AF036CancL

Função de Chamada da Tela para informar o código do Lote e efetuar o
para cancelamento de baixas processadas em lote.

@author marylly.araujo
@since 25/03/2014
@version 1.0
/*/
Function AF036CancL()
Local aArea		:= GetArea()
Local oModel	:= Nil //Atribuido abaixo devido a variavel __nOper influenciar na montagem
Local cLote		:= CriaVar("FN8_LOTE",.F.)
Local cFilFN8	:= FWxFilial("FN8")
Local nSuperior	:= 0
Local nEsquerda	:= 0
Local nInferior	:= 130
Local nDireita	:= 300
Local oDlgTela	:= Nil
Local oGetLote	:= Nil
Local nOpcG		:= 0
Local lContinua	:= .T.

__nOper := OPER_CANLT

oModel	:= FWLoadModel('ATFA036L') //Manter a atribuição após a variavel __nOper

oModel:SetOperation(MODEL_OPERATION_UPDATE)

DEFINE MSDIALOG oDlgTela TITLE STR0014 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL//'Cancelamento de Baixa em Lote'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     

oGetLote	:= TGet():New(40,15, BSetGet(cLote),oDlgTela,100,10,"@!",{ || Vazio() .Or. ExistCpo("FN8",cLote)} ,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"FN8",cLote,,,,,,,STR0015+':' ) //"Lote"

ACTIVATE MSDIALOG oDlgTela CENTERED ON INIT EnchoiceBar(oDlgTela,{|| nOpcG:=1,oDlgTela:End()},{||nOpcG:=0,oDlgTela:End()})

If nOpcG == 1

	//Verifica se foi preenchido o lote
	If EMPTY(cLote)
		lContinua := .F.
		Help(" ",1,"A036CANLOT",,STR0018,1,0) //"Lote não informado para cancelamento."
	EndIf
	
	FN6->( dbSetOrder(3) )
	
	//Verifica se o lote foi encontrado
	lContinua := lContinua .And. FN8->(DbSeek(cFilFN8 + cLote ))

	lContinua := lContinua .And. FN6->(DbSeek(xFilial("FN6") + cLote ))

	lContinua := lContinua .And. FN7->(DbSeek(xFilial("FN7") + FN6->FN6_CODBX ))
	
	If !lContinua
		Help(" ",1,"A036CANLOT",,STR0017,1,0) //"Lote informado não encontrado."
	EndIf

	FN6->( dbSetOrder(1) )

	//Verifica se o lote está cancelado
	If lContinua .And. FN8->FN8_STATUS == "2"
		lContinua := .F.
		Help(" ",1,"A036CANLOT",,STR0055,1,0) //"Lote já cancelado."
	EndIf

	If lContinua
		__nOper := OPER_CANLT
		cTitulo      := STR0054 //"Cancelamento"
		cPrograma    := 'ATFA036L'
		nOperation   := MODEL_OPERATION_UPDATE
		nRet         := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/ )
		__nOper := 0
	EndIf

EndIf
__nOper := 0

//------------------------------------------------------------------------------------------------------------
// Desabilita a chamada da tela de inclusão novamente. Foi utilizada a opção de inclusão no cancelamento para
// possibilitar a seleção da filial, pois o posicionamento no browse acabava definindo a filial corrente
//------------------------------------------------------------------------------------------------------------
MBrChgLoop(.F.)

RestArea( aArea )

Return Nil

/*/{Protheus.doc} AF036GRVLT

Função para gravação dos dados de baixa efetuados em Lote.

@author marylly.araujo
@since 26/03/2014
@version 1.0
/*/
Function AF036GRVLT( oModel )
Local oModelLote	:= oModel:GetModel('FN8LOTE')
Local oModelMaster	:= oModel:GetModel('FN6ATIVOS')
Local oModelTipo	:= oModel:GetModel('FN7TIPO')		// Carrega Model VALOR
Local oModelValor	:= oModel:GetModel('FN7VALOR')		// Carrega Model VALOR
Local nCont			:= 1	//Contador de Item do Ativo
Local lOk			:= .T.
Local cAlsAtu		:= Alias()
Local cNota			:= ""
Local cSerie		:= ""
Local nQuant		:= 0
Local nQtdOrig		:= 0
Local lCtbBxInt		:= .F.
Local cIDMOV		:= ""
Local lMovCiap		:= .F.
Local cPadraoAut	:= ""
Local cNFItem		:= ""
Local cFilFN6		:= FWxFilial("FN6")
Local cFilFN8		:= FWxFilial("FN8")
Local nCtnAtivo		:= 0
Local nCtnTipo		:= 0
Local nCtnValor		:= 0
Local cBase			:= ''
Local cItem			:= ''
Local cTipo			:= ''
Local cTpSaldo		:= ''
Local dBaixa036		:= CTOD("  /  /  ")
Local cCodMot		:= ''
Local lQuant		:= .F.
Local cQryBens		:= ''
Local cAlsBens		:= ''
Local aFN6Recnos	:= {}
Local nCtnFN6		:= 0
Local nHdlPrv		:= 0 
Local cLoteAtf		:= LoteCont("ATF")
Local cArquivo		:= ''
Local nTotal		:= 0
Local cCliente		:= ""
Local cLoja			:= ""
Local cCondPag		:= ""
Local nValNF		:= 0
Local cTESSaida		:= ""
Local cProduto		:= ""
Local nQtdBx		:= 0
Local cChavAux		:= ""
Local cFilX			:= cFilAnt
Local cFilAux		:= ""
Local nSaveSx8Len	:= GetSx8Len()
Local aNotas		:= {}
Local cChaveAux		:= ""
Local lAgrupItNF	:= GetAdvFVal("SX1","X1_PRESEL",PadR("AFA036LOTE",Len(SX1->X1_GRUPO))+"11",1,1,.T.) == 2
Local nX			:= 0
Local nY			:= 0
Local lAchou		:= .F.
Local lUsaMNTAT		:= Iif(ALLTRIM(GETMV("MV_NGMNTAT",.F.,"N")) $ "1/3",.T.,.F.) // N-NAO INTEGRA / 1-ALTERACOES NO ATF REPLICARAO NO MNT / 2-ALTERACOES NO MNT REPLICARAO NO ATF / 3-ALTERACOES ATUALIZARAO ATF E MNT			
Local cFilST9		:= FWxFilial("ST9")
Local aAreaSN3		:= {}
Local lAtuCiap		:= .T. //Flag para controle geracao CIAP

Local nSalesCurr	AS NUMERIC
Local cRuCbase		AS CHARACTER
Local cRuItem		AS CHARACTER
Local cClass		AS CHARACTER
Local cInvMsg		AS CHARACTER
Local aInvATF		AS ARRAY
Local aInvATFPrd	AS ARRAY
Local aRuArea		AS ARRAY
Local aRuAreaSN1	AS ARRAY
Local aFARules		AS ARRAY
Local aSaleInvs		AS ARRAY

aFARules			:= {}
aSaleInvs			:= {}

Pergunte('AFA036',.F.)

If lExisCPC31 == Nil
	lExisCPC31 := SN1->(Fieldpos("N1_BLQDEPR")) > 0 .And. cPaisLoc == "BRA" //CPC31, VERIFICA SE O CAMPO EXISTE NA BASE E SE ? DA LOCALIDADE DO BRASIL
EndIF

dbSelectArea( "SN3" )
SN3->(dbSetOrder( 11 ))  // Filial + Código Base + Item Base + Tipo Ativo + Baixa do Ativo + Tipo de Saldo

BEGIN TRANSACTION
	
	If __nOper == OPER_BXLOT//nOperacao == MODEL_OPERATION_UPDATE
		FN8->(RecLock("FN8",.T.))
		FN8->FN8_FILIAL	:= cFilFN8
		FN8->FN8_LOTE		:= oModelLote:GetValue("FN8_LOTE")
		FN8->FN8_MOTIVO	:= oModelLote:GetValue("FN8_MOTIVO")
		FN8->FN8_DTBAIX	:= oModelLote:GetValue("FN8_DTBAIX")
		FN8->FN8_DEPREC	:= oModelLote:GetValue("FN8_DEPREC")
		FN8->FN8_STATUS	:= "1"
		FN8->(MsUnLock())
		cFilAux := oModelMaster:GetValue("FN6_FILORI",1)

		//----------------------------------------------------------------------------------
		// Laco para obter todas as notas que precisam ser geradas para a baixa dos bens
		//----------------------------------------------------------------------------------
		For nCtnAtivo := 1 To oModelMaster:Length()

			oModelMaster:GoLine(nCtnAtivo)

			If oModelMaster:GetValue("FN6_GERANF") == "1" .And. oModelMaster:GetValue("OK",nCtnAtivo) //Gera Nota Fiscal

				cSerie		:= oModelMaster:GetValue("FN6_SERIE")
				cCliente	:= oModelMaster:GetValue("FN6_CLIENT")
				cLoja		:= oModelMaster:GetValue("FN6_LOJA")
				cCondPag	:= oModelMaster:GetValue("FN6_CNDPAG")
				cProduto	:= GetAdvFVal("SN1","N1_PRODUTO",XFilial("SN1")+oModelMaster:GetValue("FN6_CBASE")+oModelMaster:GetValue("FN6_CITEM"),1,"")
				nQtdBx		:= oModelMaster:GetValue("FN6_QTDBX")
				nValNF		:= oModelMaster:GetValue("FN6_VALNF")
				cTESSaida	:= oModelMaster:GetValue("FN6_TESSAI")

				If cPaisLoc == "RUS"
					cClass		:= oModelMaster:GetValue("FN6_NATURE")
					nSalesCurr	:= oModelMaster:GetValue("FN6_SOCURR")
				EndIf

				//------------------------------------------------------
				// Estrutura do Array aNotas
				//------------------------------------------------------
				// aNotas[X][1] - Codigo base do Bem (N1_CBASE)
				// aNotas[X][2] - Numero da Nota Fiscal Gerada (F2_DOC)
				// aNotas[X][3] - Serie da Nota Fiscal (F2_SERIE)
				// aNotas[X][4] - Cliente (F2_CLIENTE)
				// aNotas[X][5] - Loja (F2_LOJA)
				// aNotas[X][6] - Condicao de Pagamento (F2_COND)
				// aNotas[X][7] - Array com os itens da nota
				// aNotas[X][7][X][1] - Item do Ativo (N1_ITEM)
				// aNotas[X][7][X][2] - Produto (N1_PRODUTO)
				// aNotas[X][7][X][3] - Quantidade Baixada
				// aNotas[X][7][X][4] - Valor do item na Nota Fiscal
				// aNotas[X][7][X][5] - TES Saida
				// aNotas[X][7][X][6] - RUS - Oper code
				// aNotas[X][7][X][7] - RUS - Fiscal code
				//------------------------------------------------------

				cChaveAux := oModelMaster:GetValue("FN6_CBASE") + cSerie + cCliente + cLoja + cCondPag

				/* aNotas changed outside Russia scope because the structure
				 * must remain the same for all countries */				

				If lAgrupItNF .And. (nPos := AScan(aNotas,{|x| x[1]+x[3]+x[4]+x[5]+x[6] == cChaveAux })) > 0

					Aadd(aNotas[nPos,7],{oModelMaster:GetValue("FN6_CITEM"),cProduto,nQtdBx,nValNF,cTESSaida})

				Else

					Aadd(aNotas,{oModelMaster:GetValue("FN6_CBASE"),"",cSerie,cCliente,cLoja,cCondPag,{{oModelMaster:GetValue("FN6_CITEM"),cProduto,nQtdBx,nValNF,cTESSaida}}})

				EndIf

			EndIf

		Next nCtnAtivo

		//----------------------------------------------------------------------------------
		// Gera as notas
		//----------------------------------------------------------------------------------
		If ! Empty(aNotas) .And. lOk .And. cPaisLoc == "RUS"
			aRuArea		:= GetArea()
			aRuAreaSN1	:= SN1->(GetArea())
			aInvATFPrd	:= {}

			SN1->(dbSetOrder(1))	// N1_FILIAL+N1_CBASE+N1_ITEM

			For nX := 1 To Len(aNotas)
				cRuCbase	:= aNotas[nX,01]
				For nY := 1 To Len(aNotas[nX,07])
					cRuItem		:= aNotas[nX,07,nY,01]

					lOk		:= SN1->(dbSeek(xFilial("SN1")+cRuCbase+cRuItem))
					If ! lOk
						Exit
					EndIf

					aAdd(aInvATFPrd, {;
						SN1->N1_PRODUTO,;
						aNotas[nX,07,nY,03],;
						aNotas[nX,07,nY,04],;
						cTESSaida})
				Next nY
				If ! lOk
					Exit
				EndIf
			Next nX

			If lOk
				aInvATF	:= AF036RUSOI(;
					cSerie,;
					cCliente,;
					cLoja,;
					cCondPag,;
					cClass,;
					nSalesCurr,;
					aInvATFPrd)
				
				lOk		:= ! Empty(aInvATF)
			EndIf

			If lOk
				cNota	:= aInvAtf[01]

				aAdd(aSaleInvs, cNota)
				For nX := 1 To Len(aNotas)
					aNotas[nX, 02]	:= cNota
				Next nX
			EndIf

			If ! lOk
				oModel:SetErrorMessage("",Nil,oModel:GetId(),"","GERNF",STR0056)	//"O processo de baixa foi interrompido, pois não foi possível criar a nota fiscal de venda."
			EndIf

			RestArea(aRuAreaSN1)
			RestArea(aRuArea)
			Pergunte("AFA036", .F.)
		ElseIf lGerPVBra			
			If !A036GrvNF(cSerie,cCliente,cLoja,cCondPag,cProduto,nQtdBx,nValNF,cTESSaida,,aNotas,oModelMaster:GetValue("FN6_NATURE"))						
				lOK := .F.
				oModel:SetErrorMessage("",,oModel:GetId(),"","GERNF",STR0056) //"O processo de baixa foi interrompido, pois não foi possível criar a nota fiscal de venda."
			EndIf
		ElseIf cPaisLoc <> "RUS"			
			If !AF036GerNF(cSerie,cCliente,cLoja,cCondPag,cProduto,nQtdBx,nValNF,cTESSaida,,aNotas)
				lOK := .F.
				oModel:SetErrorMessage("",,oModel:GetId(),"","GERNF",STR0056) //"O processo de baixa foi interrompido, pois não foi possível criar a nota fiscal de venda."
			EndIf
		EndIf

		If lOK
			For nCtnAtivo := 1 to oModelMaster:Length()
				/*
				* Posiciona no primeiro tipo de ativo
				*/
				oModelMaster:GoLine( nCtnAtivo )
				cFilAnt := oModelMaster:GetValue("FN6_FILORI")

				If nHdlPrv <= 0 .And. MV_PAR03 == 1
					nHdlPrv := HeadProva(cLoteAtf,"ATFA036",Substr(cUsername,1,6),@cArquivo)


				Endif

				cCodMot		:= oModelMaster:GetValue("FN6_MOTIVO")
				cSerie		:= oModelMaster:GetValue("FN6_SERIE")
				cCliente	:= oModelMaster:GetValue("FN6_CLIENT")
				cLoja		:= oModelMaster:GetValue("FN6_LOJA")
				cCondPag	:= oModelMaster:GetValue("FN6_CNDPAG")
				nValNF		:= oModelMaster:GetValue("FN6_VALNF")
				cTESSaida	:= oModelMaster:GetValue("FN6_TESSAI")

				/*
				* Grava somente os registros marcados no grid FN6ATIVOS
				*/
				If oModelMaster:GetValue("OK")

					SN1->(DbSetOrder(1)) //N1_FILIAL+N1_CBASE+N1_ITEM
					SN1->(DbSeek( xFilial("SN1") + oModelMaster:GetValue("FN6_CBASE") + oModelMaster:GetValue("FN6_CITEM") ))

					If cPaisLoc == "RUS"
						aAdd(aFARules, {SN1->N1_CBASE, SN1->N1_ITEM})
					EndIf

					//---------------------------------------------------------
					// Geracao da Nota Fiscal
					//---------------------------------------------------------
					If oModelMaster:GetValue("FN6_GERANF") == "1" //Gera Nota Fiscal

						cProduto	:= GetAdvFVal("SN1","N1_PRODUTO",XFilial("SN1")+oModelMaster:GetValue("FN6_CBASE")+oModelMaster:GetValue("FN6_CITEM"),1,"")
						nQtdBx		:= oModelMaster:GetValue("FN6_QTDBX")

						lAchou := .F.

						For nX := 1 To Len(aNotas)

							If aNotas[nX][1] == oModelMaster:GetValue("FN6_CBASE")

								For nY := 1 To Len(aNotas[nX][7])

									 If aNotas[nX][7][nY][1] == oModelMaster:GetValue("FN6_CITEM")

										lAchou := .T.
										Exit

									 EndIf

								Next nY

								If lAchou
									Exit
								EndIf

							EndIf

						Next nX

						If lAchou
							cNota := aNotas[nX][2]
						EndIf

						If Empty(cNota)
							oModel:SetErrorMessage("",,oModel:GetId(),"","GERNF",STR0056)		//"O processo de baixa foi interrompido, pois não foi possível criar a nota fiscal de venda."
							lOk := .F.
							Exit
						EndIf

					Else
						cNota := oModelMaster:GetValue("FN6_NUMNF")
					EndIf

					FN6->(RecLock("FN6",.T.))
					FN6->FN6_FILIAL	:= cFilFN6
					FN6->FN6_CODBX	:= oModelMaster:GetValue("FN6_CODBX")
					FN6->FN6_CBASE	:= oModelMaster:GetValue("FN6_CBASE")
					FN6->FN6_CITEM	:= oModelMaster:GetValue("FN6_CITEM")
					FN6->FN6_MOTIVO	:= oModelMaster:GetValue("FN6_MOTIVO")
					FN6->FN6_QTDATU	:= oModelMaster:GetValue("FN6_QTDATU")
					FN6->FN6_QTDBX	:= oModelMaster:GetValue("FN6_QTDBX")
					FN6->FN6_PERCBX	:= oModelMaster:GetValue("FN6_PERCBX")
					FN6->FN6_DTBAIX	:= oModelMaster:GetValue("FN6_DTBAIX")
					FN6->FN6_DEPREC	:= oModelMaster:GetValue("FN6_DEPREC")
					FN6->FN6_NUMNF	:= cNota

					If oModelMaster:GetValue("FN6_GERANF") == "1" //Gera Nota Fiscal
						SerieNfId('FN6',1,'FN6_SERIE',oModelMaster:GetValue("FN6_DTBAIX"),,cSerie)
					Else
						SerieNfId('FN6',1,'FN6_SERIE',,,oModelMaster:GetValue("FN6_SERIE"))
					Endif

					FN6->FN6_LOTE	:= oModelMaster:GetValue("FN6_LOTE")
					FN6->FN6_ITEMNF	:= oModelMaster:GetValue("FN6_ITEMNF")
					FN6->FN6_STATUS	:= oModelMaster:GetValue("FN6_STATUS")
					FN6->FN6_FILORI	:= oModelMaster:GetValue("FN6_FILORI")
					FN6->FN6_LOTE	:= oModelLote:GetValue("FN8_LOTE")
					FN6->FN6_GERANF	:= oModelMaster:GetValue("FN6_GERANF")
					FN6->FN6_CLIENT	:= oModelMaster:GetValue("FN6_CLIENT")
					FN6->FN6_LOJA	:= oModelMaster:GetValue("FN6_LOJA")
					FN6->FN6_VALNF	:= oModelMaster:GetValue("FN6_VALNF")
					FN6->FN6_CNDPAG	:= oModelMaster:GetValue("FN6_CNDPAG")
					FN6->FN6_TESSAI	:= oModelMaster:GetValue("FN6_TESSAI")
					If cPaisLoc == "RUS"
						FN6->FN6_SOCURR	:= oModelMaster:GetValue("FN6_SOCURR")
					EndIf
					FN6->FN6_NATURE	:= oModelMaster:GetValue("FN6_NATURE")
					FN6->(MsUnLock())

					nCont := 1
					For nCtnTipo := 1 to oModelTipo:Length()
						/*
						* Posiciona no primeiro tipo de ativo
						*/
						oModelTipo:GoLine( nCtnTipo )
						/*
						* Grava somente os registros marcados no grid FN7TIPO
						*/
						If oModelTipo:GetValue("OK")
							/*
							* Verifica todos os tipos de ativos existentes para o bem selecionado
							*/
							cBase		:= oModelTipo:GetValue("FN7_CBASE" )
							cItem		:= oModelTipo:GetValue("FN7_CITEM")
							cTipo		:= oModelTipo:GetValue("FN7_TIPO" )
							cTpSaldo	:= oModelTipo:GetValue("FN7_TPSALD" )

							SN3->(dbSeek( xFilial("SN3") + cBase + cItem + cTipo + "0" + cTpSaldo ))

							cSerie		:= oModelMaster:GetValue("FN6_SERIE")
							nQtdOrig	:= oModelMaster:GetValue("FN6_QTDATU")
							nQuant		:= oModelMaster:GetValue("FN6_QTDBX")
							lCtbBxInt	:= .F.
							cIDMOV		:=  GetSXENum("SN4","N4_IDMOV",,6)
							lMovCiap	:= .T.
							cPadraoAut	:= ""
							cNFItem		:= oModelMaster:GetValue("FN6_ITEMNF")
							dBaixa036	:= oModelMaster:GetValue("FN6_DTBAIX")
							lQuant		:= AF036VQt(oModelTipo)

							If lOk
								If lExisCPC31
									If oModelMaster:GetValue("FN6_DEPREC") == '3' 
										SN1->(RecLock("SN1"))
										SN1->N1_BLQDEPR := "S"  
										SN1->(MsUnlock())
									EndIF
								EndIF
							EndIF

							/*
							* Faz a gravação e gera novo registro caso seja baixa parcial
							*/
							cSeq := Af036Grava(cAlsAtu, cNota, cSerie,nQuant,nQtdOrig,lCtbBxInt,cIDMOV,lMovCiap,cNFItem,dBaixa036,cCodMot,oModel,lQuant,@nHdlPrv,@nTotal,,,@lAtuCiap)
							If Empty(cSeq)
								lOk := .F.
								Exit
							EndIf
							For nCtnValor := 1 to oModelValor:Length()
								/*
								* Posiciona na primeira moeda
								*/
								oModelValor:GoLine( nCtnValor )

								/*
								* Inicia a gravação
								*/
								FN7->(RecLock("FN7" , .T.))
								FN7->FN7_FILIAL	:= oModelValor:GetValue("FN7_FILIAL" )
								FN7->FN7_CODBX	:= oModelMaster:GetValue("FN6_CODBX")
								FN7->FN7_ITEM	:= AllTrim( Str( nCont ) )
								FN7->FN7_CBASE	:= oModelValor:GetValue("FN7_CBASE")
								FN7->FN7_CITEM	:= oModelValor:GetValue("FN7_CITEM")
								FN7->FN7_TIPO	:= oModelTipo:GetValue("FN7_TIPO")
								FN7->FN7_TPSALD	:= oModelValor:GetValue("FN7_TPSALD")
								FN7->FN7_SEQ	:= cSeq
								FN7->FN7_SEQREA	:= oModelValor:GetValue("FN7_SEQREA")
								FN7->FN7_MOTIVO	:= oModelMaster:GetValue("FN6_MOTIVO")
								FN7->FN7_DTBAIX	:= oModelMaster:GetValue("FN6_DTBAIX")
								FN7->FN7_MOEDA	:= oModelValor:GetValue("FN7_MOEDA")
								FN7->FN7_VLATU	:= oModelValor:GetValue("FN7_VLATU")
								FN7->FN7_VLDEPR	:= oModelValor:GetValue("FN7_VLDEPR")
								FN7->FN7_VLBAIX	:= oModelValor:GetValue("FN7_VLBAIX")
								FN7->FN7_PERCBX	:= oModelValor:GetValue("FN7_PERCBX")
								FN7->FN7_FILORI	:= oModelValor:GetValue("FN7_FILORI")
								FN7->FN7_STATUS	:= oModelValor:GetValue("FN7_STATUS")
								FN7->FN7_VLRESI	:= oModelValor:GetValue("FN7_VLRESI")
								FN7->(MsUnlock("FN7"))

								nCont++
							Next nCtnValor

						EndIf

						If !lOk
							Exit
						EndIf

					Next nCtnTipo
					lAtuCiap := .T.
				EndIf

				// Executa o lançamento padrao por filial.
				If lOk
					If (nCtnAtivo+1) > oModelMaster:Length() .Or. oModelMaster:GetValue("FN6_FILORI",nCtnAtivo+1) != cFilAux
						If nHdlPrv > 0 .And. ( nTotal > 0 )
							RodaProva(nHdlPrv, nTotal)
							cA100Incl(cArquivo,nHdlPrv,3,cLoteAtf,mv_par01 == 1,mv_par02 == 1)
						Endif
						nHdlPrv := 0
						nTotal  := 0
						If (nCtnAtivo+1) <= oModelMaster:Length()
							cFilAux := oModelMaster:GetValue("FN6_FILORI",nCtnAtivo+1)
						EndIf
					EndIf
				Else
					Exit
				EndIf
				
				//---------------------------------------------------------
				//	Integração com MNT 
				//---------------------------------------------------------
				
				
				If lUsaMNTAT .AND. !EMPTY(SN1->N1_CODBEM)
					AFGRBXIntMnt(SN1->N1_CODBEM,SN1->N1_BAIXA,"ATFA036",.F.,cNota)
					aAreaSN3 := SN3->(GetArea())
					dbSelectArea( "ST9" )
					ST9->(dbSetOrder( 1 ))
						
					IF ST9->(dbSeek( cFilST9 + SN1->N1_CODBEM ))							
						ST9->(RecLock("ST9",.F.))
						ST9->T9_SITMAN := "I"
						ST9->(MsUnLock())
					EndIF							
					RestArea( aAreaSN3 )											
				EndIf
				

			Next nCtnAtivo
		EndIf
		If lOk
			If nHdlPrv > 0 .And. ( nTotal > 0 )
				RodaProva(nHdlPrv, nTotal)
				cA100Incl(cArquivo,nHdlPrv,3,cLoteAtf,mv_par01 == 1,mv_par02 == 1)
			Endif
		Else
			DisarmTransaction()
		EndIf
		nHdlPrv := 0
		nTotal  := 0
		
	ElseIf __nOper == OPER_CANLT
		FN8->(DbSetOrder(1)) // Filial + Lote
		If FN8->(DbSeek( cFilFN8 + oModelLote:GetValue("FN8_LOTE") ))
			cAlsBens := GetNextAlias()
			/*
			* Baixa em Lote
			*/
			cQryBens := "SELECT " + CRLF
			cQryBens += " FN7.FN7_CBASE "	+ CRLF
			cQryBens += ", FN7.FN7_CITEM "	+ CRLF
			cQryBens += ", FN7.FN7_TIPO "	+ CRLF
			cQryBens += ", FN7.FN7_TPSALD "	+ CRLF
			cQryBens += ", FN7.FN7_DTBAIX "	+ CRLF
			cQryBens += ", FN7.FN7_SEQ "	+ CRLF
			cQryBens += ", FN7.FN7_MOTIVO "	+ CRLF
			cQryBens += ", FN7.FN7_CODBX "	+ CRLF
			cQryBens += ", FN6.FN6_FILORI "	+ CRLF
			cQryBens += ", FN7.FN7_MOEDA "	+ CRLF
			cQryBens += ", FN6.R_E_C_N_O_ RECNOFN6 "	+ CRLF
			cQryBens += ", FN8.R_E_C_N_O_ RECNOFN8 "	+ CRLF
			cQryBens += ", FN7.R_E_C_N_O_ RECNOFN7 "	+ CRLF
			cQryBens += "FROM " + RetSqlName("FN8") + " FN8 "
			cQryBens += " INNER JOIN " + RetSqlName("FN6") + " FN6 ON FN6.FN6_LOTE = FN8.FN8_LOTE AND FN6.FN6_FILIAL = FN8.FN8_FILIAL "
			cQryBens += " INNER JOIN " + RetSqlName("FN7") + " FN7 ON FN6.FN6_CODBX = FN7.FN7_CODBX AND FN6.FN6_FILIAL = FN7.FN7_FILIAL "
			cQryBens += " WHERE "
			cQryBens += " FN6.D_E_L_E_T_ = ' ' AND FN7.D_E_L_E_T_ = ' ' AND FN8.D_E_L_E_T_ = ' ' "
			cQryBens += "AND FN8.FN8_FILIAL = '" + cFilFN8 + "' "
			cQryBens += "AND FN6.FN6_LOTE = '" + oModelLote:GetValue("FN8_LOTE") + "' "			
			cQryBens += "AND FN6.FN6_STATUS = '1' "
			cQryBens += "AND FN7.FN7_STATUS = '1' "
			cQryBens += "AND FN8.FN8_STATUS = '1' "
			cQryBens += "GROUP BY FN7_CBASE,FN7_CITEM,FN7_TIPO,FN7_TPSALD,FN7_DTBAIX,FN7_SEQ,FN7_MOTIVO,FN7_CODBX,FN6_FILORI,FN6.R_E_C_N_O_,FN8.R_E_C_N_O_,FN7.R_E_C_N_O_,FN7.FN7_MOEDA "
			cQryBens += "ORDER BY FN6_FILORI,FN7_CODBX,FN7_CBASE,FN7_CITEM,FN7_TIPO,FN7_TPSALD , FN7_MOEDA"
			cQryBens := ChangeQuery( cQryBens )
			
			DbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQryBens) , cAlsBens , .T. , .F.)
			TcSetField(cAlsBens,'FN7_DTBAIX','D')
			
			If (cAlsBens)->(!Eof())
				cFilAux := (cAlsBens)->FN6_FILORI
				lOk := .F.
				While (cAlsBens)->(!Eof())
					cFilAnt:= (cAlsBens)->FN6_FILORI
					If nHdlPrv <= 0
						nHdlPrv := HeadProva(cLoteAtf,"ATFA036",Substr(cUsername,1,6),@cArquivo)
					Endif
					
					//Validacao para baixar todos os saldos
					If cChavAux <> (cAlsBens)->FN7_CBASE +(cAlsBens)->FN7_CITEM + (cAlsBens)->FN7_TIPO + (cAlsBens)->FN7_TPSALD
						If aScan(aFN6Recnos,{ |RECNO| RECNO == (cAlsBens)->RECNOFN6} ) == 0
							Aadd(aFN6Recnos,(cAlsBens)->RECNOFN6)
						EndIf
						If (cAlsBens)->FN7_MOEDA == '01'
							FN6->(DbGoTo((cAlsBens)->RECNOFN6))
							lOk := AF036Cance((cAlsBens)->FN7_CBASE,(cAlsBens)->FN7_CITEM,(cAlsBens)->FN7_TIPO,(cAlsBens)->FN7_TPSALD,(cAlsBens)->FN7_DTBAIX,(cAlsBens)->FN7_SEQ,(cAlsBens)->FN7_MOTIVO,@nHdlPrv,@nTotal,(cAlsBens)->FN7_CODBX,cFilFN8,FN6->FN6_NUMNF,FN6->FN6_SERIE,FN6->FN6_CLIENT,FN6->FN6_LOJA)
						EndIf
						cChavAux := (cAlsBens)->FN7_CBASE +(cAlsBens)->FN7_CITEM + (cAlsBens)->FN7_TIPO + (cAlsBens)->FN7_TPSALD
					Else
						lOk := .T.
					EndIf
					
					If lOk
						FN7->(DbGoTo((cAlsBens)->RECNOFN7))
						FN7->(RecLock("FN7",.F.))
						FN7->FN7_STATUS := '2'
						FN7->(MsUnLock())
					Else
						Exit
					EndIf

					If lOk //CPC31
						If lExisCPC31
							SN1->(RecLock("SN1"))
							SN1->N1_BLQDEPR := ""  
							SN1->(MsUnlock())
						Endif
					Endif
					
					If lUsaMNTAT .AND. !EMPTY((cAlsBens)->FN7_CBASE)
						dbSelectArea( "ST9" )
						ST9->(dbSetOrder( 1 ))
						IF ST9->(dbSeek( cFilST9 + AllTrim(FN7->FN7_CBASE) ))							
							ST9->(RecLock("ST9",.F.))
							ST9->T9_SITMAN := "A"
							ST9->(MsUnLock())
						EndIF							
					EndIf
				
					(cAlsBens)->(DbSkip())
					
					If (cAlsBens)->( EOF() ) .Or. (cAlsBens)->FN6_FILORI	 != cFilAux
						If nHdlPrv > 0 .And. ( nTotal > 0 )
							RodaProva(nHdlPrv, nTotal)
							cA100Incl(cArquivo,nHdlPrv,3,cLoteAtf,mv_par01 == 1,mv_par02 == 1)
						Endif
						nHdlPrv := 0
						nTotal  := 0
						If (cAlsBens)->( !EOF() )
							cFilAux := (cAlsBens)->FN6_FILORI
						EndIf
					EndIf
					
				EndDo
			EndIf
			
			If lOk
				For nCtnFN6 := 1 To Len(aFN6Recnos)
					
					FN6->(DbGoTo(aFN6Recnos[nCtnFN6]))
					cFilAnt:= FN6->FN6_FILORI
					
					If lOk
						FN6->(RecLock("FN6",.F.))
						FN6->FN6_STATUS	:= '2'
						FN6->(MsUnLock())
					EndIf
				Next nCtnFN6
				
				FN8->(RecLock("FN8",.F.))
				FN8->FN8_STATUS := '2'
				FN8->(MsUnLock())
			Else
				DisarmTransaction()
			EndIf
			(cAlsBens)->(DbCloseArea())
		EndIf
	EndIf
END TRANSACTION

// Confirma o cCodBaixa
While (GetSx8Len() > nSaveSx8Len)
	ConfirmSX8()
Enddo

if cPaisLoc == "RUS"
	ProcFARules(aFARules)

	If ! IsBLind()
		cInvMsg		:= ""
		For nX := 1 To Len(aSaleInvs)
			cInvMsg	+= IIf(Empty(cInvMsg), "", ", ")
			cInvMsg	+= aSaleInvs[nX]
		Next nX
		If ! Empty(cInvMsg)
			MsgInfo(STR0059 + cInvMsg)	// "The following invoices were generated as sale: "
		EndIf
	EndIf
EndIf

cFilAnt := cFilX


Return lOk

/*/{Protheus.doc} AF036BxLote

Função de Chamada da Tela para informar os parâmetros de filtros dos ativos e efetuar a baixa em Lote.

@author marylly.araujo
@since 26/03/2014
@version 1.0
/*/

Function AF036BxLote(xParLot,xOpcAuto)
Local aArea	:= GetArea()
Local nOpc	:= MODEL_OPERATION_UPDATE
Local lRet	:= .T.

DEFAULT xParLot := Nil
DEFAULT xOpcAuto :=  Nil

SaveInter() //Salva estado dos parâmetros

//Não remover ajusta porque o execauto utiliza nas rotinas de integração.
If xParLot <> Nil .And. xOpcAuto <> Nil

	__xParLot := xParLot

	If xOpcAuto == 3
		nOpc := MODEL_OPERATION_UPDATE
	EndIf

Else
	If !Pergunte("AFA036LOTE",.T.)
		Help(" ",1,"A036LOT",,STR0019,1,0) //"Processamento de baixa em Lote cancelada."
		lRet := .F.
	EndIf
EndIf
If lRet

	__nOper := OPER_BXLOT
		
	MsgRun( STR0020,, {|| FWExecView(STR0021,'ATFA036L',nOpc,/*oDlg*/,{ || .T. },/*bOk*/,/*nPercReducao*/,/*aEnableButtons*/,/*bCancel*/,/*cOperatId*/,/*cToolBar*/,/*oModel*/) } ) //"Processando..."##"Baixa de ativos em Lote"

	__nOper := 0

EndIf

If lRet .And. __lMetric
	ATF036LMetrics("01", Nil, "001", Alltrim(ProcName()), Nil)
EndIf

RestInter() //Restaura estado dos parâmetros
RestArea( aArea )

Return lRet

/*/{Protheus.doc} AF036Atv

Carrega os dados do grid de cabeçalho da baixa (Tabela FN6)

@author marylly.araujo
@since 25/03/2014
@version 1.0
@param oModel Objeto do Modelo de Dados da Rotina de Baixa de Ativos
/*/

Function AF036Atv(oModel)
Local oModelPrinc		:= oModel:GetModel()
Local oModelPar			:= oModelPrinc:GetModel("PARAMETROS")
Local oModelLote		:= oModelPrinc:GetModel("FN8LOTE")
Local oModelFN6			:= oModelPrinc:GetModel("FN6ATIVOS")
Local aDados			:= {}
Local cFilFN6			:= FWxFilial("FN6")
Local cQryBens			:= ''
Local cAlsBens			:= GetNextAlias()
Local cDeprec			:= GETMV('MV_ATFDPBX')
Local cLote				:= oModelLote:GetValue("FN8_LOTE")
Local lQryFil			:= ExistBlock("AF36AFIL")
Local oFN6Struct		:= oModelFN6:GetStruct()
Local aCposVlr			:= oFN6Struct:GetFields()
Local nContCpo			:= 0
Local aFilCpos 			:= {}
Local lRusDepBonus		:= .F.
Local cRusTypeDepBonus	:= "  "
Local nLenFilSN1        := Len(Alltrim(xFilial("SN1")))
Local cSubStr           := Iif(Alltrim(TcGetDb()) $ "MSSQL7|MSSQL","SUBSTRING", "SUBSTR") 

If lIsRussia .And. __nOper == OPER_BXLOT
	lRusDepBonus	:= oModelPar:GetValue("DEPRBONUS") == 1
	If lRusDepBonus
		cRusTypeDepBonus	:= "01"
	EndIf
EndIf

Pergunte("AFA036",.F.)

If __nOper == OPER_BXLOT
	/*
	* Baixa em Lote
	*/
	cQryBens := "SELECT DISTINCT " + CRLF
	cQryBens += "N1_FILIAL "	+ CRLF
	cQryBens += ",N1_DESCRIC "	+ CRLF
	cQryBens += ",N1_CBASE "	+ CRLF
	cQryBens += ",N1_ITEM "		+ CRLF
	cQryBens += ",N1_QUANTD "	+ CRLF
	cQryBens += ",N3_FILORIG FILORIG "	+ CRLF
	cQryBens += " FROM " + RetSqlName("SN1") + " SN1 " + CRLF
	cQryBens += " INNER JOIN " + RetSqlName("SN3") + " SN3 " + " ON " + CRLF
	cQryBens += " SN1.N1_FILIAL = SN3.N3_FILIAL " + CRLF
	cQryBens += " AND SN1.N1_CBASE = SN3.N3_CBASE " + CRLF
	cQryBens += " AND SN1.N1_ITEM  = SN3.N3_ITEM  " + CRLF	
	cQryBens += " WHERE " + CRLF
	cQryBens += " SN1.D_E_L_E_T_ = ' ' " + CRLF
 	cQryBens += " AND SN3.D_E_L_E_T_ = ' ' " + CRLF
	cQryBens += " AND SN1.N1_QUANTD > 0 " + CRLF
	If cPaisLoc == "RUS"
		cQryBens += " AND SN1.N1_STATUS = '1' " + CRLF
	Else
		cQryBens += " AND SN1.N1_STATUS IN ('0','1') " + CRLF
	EndIf
	cQryBens += " AND SN1.N1_FILIAL BETWEEN '"	+ oModelPar:GetValue("FILIALDE")		+ "' AND '" + oModelPar:GetValue("FILIALATE")		+ "' " + CRLF
	cQryBens += " AND SN1.N1_GRUPO BETWEEN	'"		+ oModelPar:GetValue("GRUPODE")			+ "' AND '" + oModelPar:GetValue("GRUPOATE")		+ "' " + CRLF
	cQryBens += " AND SN1.N1_CBASE BETWEEN	'"		+ oModelPar:GetValue("CODIGODE")		+ "' AND '" + oModelPar:GetValue("CODIGOATE")		+ "' " + CRLF
	cQryBens += " AND SN1.N1_ITEM BETWEEN	'"		+ oModelPar:GetValue("ITEMDE")			+ "' AND '" + oModelPar:GetValue("ITEMATE")		+ "' " + CRLF
	cQryBens += " AND SN1.N1_AQUISIC BETWEEN '"	+ DTOS(oModelPar:GetValue("DATADE"))	+ "' AND '" + DTOS(oModelPar:GetValue("DATAATE"))+ "' " + CRLF
	
	/*
	* Ponto de Entrada para filtro da seleção de ativos na tela de baixa de ativos em lote
	*/
	If lQryFil
		cQryBens += " AND " + ExecBlock("AF36AFIL",.F.,.F.) + CRLF
	EndIf
	
	cQryBens += " ORDER BY " + CRLF
	cQryBens += " N1_FILIAL ,N1_CBASE,N1_ITEM " + CRLF

	If lIsRussia
		cQryBens	:= RU01XFN005(lRusDepBonus, cRusTypeDepBonus, oModelPar) // Old AF036RUQRY
	EndIf
	
	cQryBens := ChangeQuery( cQryBens )
	
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQryBens) , cAlsBens , .T. , .F.)
	While (cAlsBens)->(!Eof())
		
		/*
		* Carrega os dados do bem selecionado para executação da baixa manual
		*/
		cCod := Af036CodBx()
		For nContCpo := 1 To Len(aCposVlr)
			
			cCampo := Alltrim(aCposVlr[nContCpo][3])
			
			If cCampo == "FN6_FILIAL"
				AADD(aFilCpos,cFilFN6)
			ElseIf lRusDepBonus .And. AllTrim(cCampo) $ "FN6_BAIXA|FN6_DEPREC|FN6_MOTIVO|FN6_PERCBX"
				If cCampo $ "FN6_BAIXA|FN6_PERCBX"
					AADD(aFilCpos,(cAlsBens)->FM1_BONUS)
				ElseIf cCampo == "FN6_DEPREC"
					AADD(aFilCpos,"0")
				ElseIf cCampo == "FN6_MOTIVO"
					AADD(aFilCpos,"09")
				EndIf
			ElseIf cPaisLoc == "RUS" .And. cCampo == "FN6_BAIXA"
				AADD(aFilCpos, 0)
			ElseIf cCampo == "FN6_CODBX"
				AADD(aFilCpos,cCod)
			ElseIf cCampo == "FN6_CBASE"
				AADD(aFilCpos,(cAlsBens)->N1_CBASE )
			ElseIf cCampo == "FN6_CITEM"
				AADD(aFilCpos,(cAlsBens)->N1_ITEM)
			ElseIf cCampo == "FN6_DESCRI"
				AADD(aFilCpos,(cAlsBens)->N1_DESCRIC)
			ElseIf cCampo == "FN6_DTBAIX"
				AADD(aFilCpos,dDataBase)
			ElseIf cCampo == "FN6_QTDATU"
				AADD(aFilCpos,(cAlsBens)->N1_QUANTD)
			ElseIf cCampo == "FN6_DEPREC"
				AADD(aFilCpos,cDeprec)
			ElseIf cCampo == "FN6_GERANF"
				AADD(aFilCpos,'2')
			ElseIf cCampo == "FN6_SERIE"
				AADD(aFilCpos,SerieNfId('FN6',5,'FN6_SERIE'))
			ElseIf cCampo == "FN6_LOTE"
				AADD(aFilCpos,cLote)
			ElseIf cCampo == "FN6_STATUS"
				AADD(aFilCpos,'1'	)
			ElseIf cCampo == "FN6_FILORI"
				AADD(aFilCpos,Iif(Empty((cAlsBens)->N1_FILIAL),(cAlsBens)->FILORIG,(cAlsBens)->N1_FILIAL))
			ElseIf cCampo == "OK"
				AADD(aFilCpos,.F.)
			Else
				AADD(aFilCpos,CriaVar(cCampo) )
			EndIf
			
		Next nContCpo
		
		AADD(aDados,{0,aFilCpos})
		
		aFilCpos := {}
		
		
		(cAlsBens)->(DbSkip())
	EndDo
ElseIf __nOper == OPER_CANLT
	
	cQryBens := "SELECT " + CRLF
	cQryBens += " FN6.FN6_FILIAL " + CRLF
	cQryBens += ",FN6.FN6_CODBX " + CRLF
	cQryBens += ",FN6.FN6_CBASE " + CRLF
	cQryBens += ",FN6.FN6_CITEM " + CRLF
	cQryBens += ",SN1.N1_DESCRIC " + CRLF
	cQryBens += ",FN6.FN6_MOTIVO " + CRLF
	cQryBens += ",FN6.FN6_QTDATU " + CRLF
	cQryBens += ",FN6.FN6_QTDBX " + CRLF
	cQryBens += ",FN6.FN6_PERCBX " + CRLF
	cQryBens += ",FN6.FN6_DTBAIX " + CRLF
	cQryBens += ",FN6.FN6_DEPREC " + CRLF
	cQryBens += ",FN6.FN6_NUMNF " + CRLF
	cQryBens += ",FN6." + SerieNfId('FN6',3,'FN6_SERIE') + CRLF
	cQryBens += ",FN6.FN6_LOTE " + CRLF
	cQryBens += ",FN6.FN6_ITEMNF " + CRLF
	cQryBens += ",FN6.FN6_STATUS " + CRLF
	cQryBens += ",FN6.FN6_FILORI " + CRLF
	cQryBens += ",FN6.FN6_GERANF " + CRLF
	cQryBens += ",FN6.FN6_CLIENT " + CRLF
	cQryBens += ",FN6.FN6_LOJA " + CRLF
	cQryBens += ",FN6.FN6_VALNF " + CRLF
	cQryBens += ",FN6.FN6_CNDPAG " + CRLF
	cQryBens += ",FN6.FN6_TESSAI " + CRLF
	If cPaisLoc == "RUS"
		cQryBens += ",FN6.FN6_SOCURR " + CRLF
	EndIf
	cQryBens += ",FN6.FN6_NATURE " + CRLF
	cQryBens += " FROM " + RetSqlName("FN6") + " FN6 " + CRLF
	If FWModeAccess("SN1",1) = "E".and. FWModeAccess("SN1",2) = "E" .and.FWModeAccess("SN1",3) = "E"
		cQryBens += " INNER JOIN " + RetSqlName("SN1") + " SN1 ON SN1.N1_CBASE = FN6.FN6_CBASE AND SN1.N1_ITEM = FN6.FN6_CITEM AND SN1.N1_FILIAL = FN6.FN6_FILORI "
	ElseIf Empty(xFilial("SN1"))  //TOTALMENTE compartilhado
	 	cQryBens += " INNER JOIN " + RetSqlName("SN1") + " SN1 ON SN1.N1_CBASE = FN6.FN6_CBASE AND SN1.N1_ITEM = FN6.FN6_CITEM AND SN1.N1_FILIAL = ' ' "
	Else  //Compartilhado na filial ou unidade de negócio
	 	cQryBens += " INNER JOIN " + RetSqlName("SN1") + " SN1 ON SN1.N1_CBASE = FN6.FN6_CBASE AND SN1.N1_ITEM = FN6.FN6_CITEM "
		cQryBens += "		                               AND SN1.N1_FILIAL = "+ cSubStr +"(FN6.FN6_FILORI,1, "+Alltrim(Str(nLenFilSN1))+")"
	Endif
	cQryBens += " WHERE "
	cQryBens += "     FN6.FN6_FILIAL = '" + xFilial("FN6") + "' "
	cQryBens += " AND FN6.FN6_LOTE = '" + cLote + "' "
	cQryBens += " AND FN6.FN6_STATUS = '1' "
	cQryBens += " AND FN6.D_E_L_E_T_ = ' ' "
	cQryBens += " AND SN1.D_E_L_E_T_ = ' ' "
	cQryBens := ChangeQuery( cQryBens )
	
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQryBens) , cAlsBens , .T. , .F.)
	TcSetField(cAlsBens,'FN6_DTBAIX','D')
	While (cAlsBens)->(!Eof())
		
		For nContCpo := 1 To Len(aCposVlr)
			
			cCampo := Alltrim(aCposVlr[nContCpo][3])
			
			If cCampo == "FN6_FILIAL"
				AADD(aFilCpos,(cAlsBens)->FN6_FILIAL)
			ElseIf cCampo == "FN6_CODBX"
				AADD(aFilCpos,(cAlsBens)->FN6_CODBX)
			ElseIf cCampo == "FN6_CBASE"
				AADD(aFilCpos,(cAlsBens)->FN6_CBASE )
			ElseIf cCampo == "FN6_CITEM"
				AADD(aFilCpos,(cAlsBens)->FN6_CITEM)
			ElseIf cCampo == "FN6_DESCRI"
				AADD(aFilCpos,(cAlsBens)->N1_DESCRIC)
			ElseIf cCampo == "FN6_DTBAIX"
				AADD(aFilCpos,(cAlsBens)->FN6_DTBAIX)
			ElseIf cCampo == "FN6_BAIXA"
				AADD(aFilCpos,0.0)
			ElseIf cCampo == "FN6_QTDATU"
				AADD(aFilCpos,(cAlsBens)->FN6_QTDATU)
			ElseIf cCampo == "FN6_QTDBX"
				AADD(aFilCpos,(cAlsBens)->FN6_QTDBX)
			ElseIf cCampo == "FN6_PERCBX"
				AADD(aFilCpos,(cAlsBens)->FN6_PERCBX)
			ElseIf cCampo == "FN6_MOTIVO"
				AADD(aFilCpos,(cAlsBens)->FN6_MOTIVO)
			ElseIf cCampo == "FN6_DEPREC"
				AADD(aFilCpos,(cAlsBens)->FN6_DEPREC)
			ElseIf cCampo == "FN6_GERANF"
				AADD(aFilCpos,(cAlsBens)->FN6_GERANF)
			ElseIf cCampo == "FN6_NUMNF"
				AADD(aFilCpos,(cAlsBens)->FN6_NUMNF)
			ElseIf cCampo == "FN6_SERIE"
				AADD(aFilCpos,(cAlsBens)->&(SerieNfId('FN6',3,'FN6_SERIE')))
			ElseIf cCampo == "FN6_LOTE"
				AADD(aFilCpos,(cAlsBens)->FN6_LOTE)
			ElseIf cCampo == "FN6_ITEMNF"
				AADD(aFilCpos,(cAlsBens)->FN6_ITEMNF)
			ElseIf cCampo == "FN6_STATUS"
				AADD(aFilCpos,(cAlsBens)->FN6_STATUS)
			ElseIf cCampo == "FN6_FILORI"
				AADD(aFilCpos,(cAlsBens)->FN6_FILORI)
			ElseIf cCampo == "FN6_CLIENT"
				AADD(aFilCpos,(cAlsBens)->FN6_CLIENT)
			ElseIf cCampo == "FN6_LOJA"
				AADD(aFilCpos,(cAlsBens)->FN6_LOJA)
			ElseIf cCampo == "FN6_VALNF"
				AADD(aFilCpos,(cAlsBens)->FN6_VALNF)
			ElseIf cCampo == "FN6_CNDPAG"
				AADD(aFilCpos,(cAlsBens)->FN6_CNDPAG)
			ElseIf cCampo == "FN6_TESSAI"
				AADD(aFilCpos,(cAlsBens)->FN6_TESSAI)
			ElseIf cPaisLoc == "RUS" .And. cCampo == "FN6_SOCURR"
				AADD(aFilCpos,(cAlsBens)->FN6_SOCURR)	
			ElseIf cCampo == "FN6_NATURE"
				AADD(aFilCpos,(cAlsBens)->FN6_NATURE)
			ElseIf cCampo == "OK"
				AADD(aFilCpos,.T.)
			Else
				AADD(aFilCpos,CriaVar(cCampo) )
			EndIf
			
		Next nContCpo
		
		AADD(aDados,{0,aFilCpos})
		
		aFilCpos := {}

		(cAlsBens)->(DbSkip())
	EndDo
	If Len(aDados) == 0
		If MV_PAR04 == 1
			Help(" ",1,"A036NCAN",,STR0022,1,0) //"Ativo sem baixa para efetuar cancelamento."
		ElseIf MV_PAR04 == 2
			Help(" ",1,"A036NCAN2",,STR0023,1,0) //"Baixa de ativo já cancelada."
		EndIf
	EndIf
EndIf

Return aDados

/*/{Protheus.doc} AF036LotLt

Função que retorna a carga da grid de Tipos de Ativos

@author marylly.araujo
@since 25/03/2014
@version 1.0
@param oModel Objeto do Modelo de Dados da Rotina de Baixa de Ativos
/*/
Function AF036LtLt(oModel)
Local aArea				:= GetArea()
Local aSN1Area			:= {}
Local aSN3Area			:= {}
Local aFN6Area			:= {}
Local aFN7Area			:= {}
Local aRetTip			:= {}
Local aCgTipo			:= {}
Local cBase				:= ''
Local cItem				:= ''
Local cFilOri			:= ""
Local cFilShare			:= ""
Local cFilFN7			:= FWxFilial("FN7")
Local cCtnItem			:= 1
Local nTamItem			:= TamSX3("FN7_ITEM")[1]
Local cIdBaixa			:= ''
Local oModelPai			:= oModel:GetModel()
Local lRusDepBonus		:= .F.
Local cRusTypeDepBonus	:= "  "

DbSelectArea('SN1')
aSN1Area	:= SN1->(GetArea())
DbSelectArea('SN3')
aSN3Area	:= SN3->(GetArea())
DbSelectArea('FN6')
aFN6Area	:= FN6->(GetArea())
DbSelectArea('FN7')
aFN7Area	:= FN7->(GetArea())

cBase 	:= oModel:GetModel("FN6ATIVOS"):GetValue("FN6ATIVOS","FN6_CBASE")
cItem	:= oModel:GetModel("FN6ATIVOS"):GetValue("FN6ATIVOS","FN6_CITEM")
cFilOri	:= oModel:GetModel():GetModel("FN6ATIVOS"):GetValue("FN6_FILORI")
cFilShare := FwxFilial("SN1",cFilOri)
           
cIdBaixa:= oModel:GetModel("FN6ATIVOS"):GetValue("FN6ATIVOS","FN6_CODBX")

If lIsRussia .And. __nOper == OPER_BXLOT
	lRusDepBonus	:= oModelPai:GetModel("PARAMETROS"):GetValue("DEPRBONUS") == 1
	If lRusDepBonus
		cRusTypeDepBonus	:= "01"
	EndIf
EndIf

/*
 * Pesquisa a SN1 correpondente ao item selecionado
 */
dbSelectArea( "SN1" )
SN1->(dbSetOrder( 1 ))
SN1->(dbSeek( cFilShare + cBase + cItem ))

If __nOper == OPER_BXLOT
	/*
	* Verifica todos os tipos de ativos existentes para o bem selecionado
	*/
	cFilShare := FwxFilial("SN3",cFilOri)
	SN3->(dbSeek( cFilShare + cBase + cItem ))
	
	/*
	* Carrega array para exibição no grid
	*/
	While SN3->(!Eof()) .And. ( cFilShare + SN1->N1_CBASE + SN1->N1_ITEM == SN3->N3_FILIAL + SN3->N3_CBASE + SN3->N3_ITEM )
		aCgTipo := {}

		lRusFiltroDepBonus	:= .T.
		If lIsRussia .And. lRusDepBonus
			lRusFiltroDepBonus	:= lRusFiltroDepBonus .And. AllTrim(SN3->N3_TIPO) == cRusTypeDepBonus
			lRusFiltroDepBonus	:= lRusFiltroDepBonus .And. SN3->N3_OPER == "1"
			lRusFiltroDepBonus	:= lRusFiltroDepBonus .And. SN3->N3_TPDEPR <> "N"
			lRusFiltroDepBonus	:= lRusFiltroDepBonus .And. (oModelPai:GetModel("PARAMETROS"):GetValue("DEPBNSTYPE") != 1 .Or. SN3->N3_DINDEPR >= FirstDay(dDataBase) .And. SN3->N3_DINDEPR <= LastDay(dDataBase))
		EndIf

		If SN3->N3_BAIXA == '0' .And. lRusFiltroDepBonus
			Aadd(aCgTipo,{"FN7_FILIAL"	,cFilFN7														})
			Aadd(aCgTipo,{"FN7_CODBX"	,oModel:GetModel("FN6ATIVOS"):GetValue("FN6ATIVOS","FN6_CODBX")	})
			Aadd(aCgTipo,{"FN7_ITEM"	,PADL(cCtnItem,nTamItem,"0")									})
			Aadd(aCgTipo,{"FN7_CBASE"	,oModel:GetModel("FN6ATIVOS"):GetValue("FN6ATIVOS","FN6_CBASE")	})
			aadd(aCgTipo,{"FN7_CITEM"	,oModel:GetModel("FN6ATIVOS"):GetValue("FN6ATIVOS","FN6_CITEM")	})
			Aadd(aCgTipo,{"FN7_DESCRI"	,SN3->N3_HISTOR													})
			Aadd(aCgTipo,{"FN7_TIPO"	,SN3->N3_TIPO													})
			Aadd(aCgTipo,{"FN7_TPSALD"	,SN3->N3_TPSALDO												})
			Aadd(aCgTipo,{"FN7_SEQ"		,SN3->N3_SEQ													})
			Aadd(aCgTipo,{"FN7_MOEDA"	,'01'															})
			Aadd(aCgTipo,{"FN7_SEQREA"	,SN3->N3_SEQREAV												})
			Aadd(aCgTipo,{"FN7_MOTIVO"	,oModel:GetModel("FN6ATIVOS"):GetValue("FN6ATIVOS","FN6_MOTIVO")})
			Aadd(aCgTipo,{"FN7_DTBAIX"	,dDataBase														})
			Aadd(aCgTipo,{"FN7_VLATU"	,0																})
			Aadd(aCgTipo,{"FN7_VLDEPR"	,0																})
			Aadd(aCgTipo,{"FN7_VLBAIX"	,0																})
			Aadd(aCgTipo,{"FN7_PERCBX"	,0																})
			Aadd(aCgTipo,{"FN7_STATUS"	,oModel:GetModel("FN6ATIVOS"):GetValue("FN6ATIVOS","FN6_STATUS")})
			Aadd(aCgTipo,{"FN7_FILORI"	,cFilOri														})
			Aadd(aCgTipo,{"FN7_VLRESI"	,0																})
			If cPaisLoc == "RUS"
				aAdd(aCgTipo,{"FN7_VORIG"	, SN3->N3_VORIG1 })
				aAdd(aCgTipo,{"FN7_CALCDP"	, 0              })
				aAdd(aCgTipo,{"VRACUMVAL"   , SN3->N3_VRDACM1})
				aAdd(aCgTipo,{"FN7_VRDACM"	, SN3->N3_VRDACM1})
				aAdd(aCgTipo,{"FN7_CARRYV"	, SN3->(N3_VORIG1+N3_AMPLIA1-N3_VRDACM1)})
			EndIf
			Aadd(aCgTipo,{"UPDATE"		,.F.															})
			Aadd(aRetTip,{ 0, Af36MntFN7(oModelPai,aCgTipo,'FN7TIPO') })
			cCtnItem++
		EndIf
		SN3->(dbSkip())
	EndDo	
ElseIf __nOper == OPER_CANLT
	DbSelectArea("FN7")
	FN7->(DbSetOrder(1)) // Filial + Código da Baixa
	SN3->(dbSetOrder( 1 ))//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
	
	FN7->(DbSeek( cFilFN7 + cIdBaixa ) )
	
	/*
	* Carrega array para exibição no grid
	*/
	While FN7->(!Eof()) .And. ( cFilFN7 + cIdBaixa == FN7->FN7_FILIAL + FN7->FN7_CODBX)
		If SN3->(dbSeek( xFilial("SN3",FN7->FN7_FILORI) + FN7->FN7_CBASE + FN7->FN7_CITEM + FN7->FN7_TIPO ))
			
			If FN7->FN7_MOEDA == '01'
				aCgTipo := {}
				Aadd(aCgTipo,{"FN7_FILIAL"	,FN7->FN7_FILIAL	})
				Aadd(aCgTipo,{"FN7_CODBX"	,FN7->FN7_CODBX		})
				Aadd(aCgTipo,{"FN7_ITEM"	,FN7->FN7_ITEM		})
				Aadd(aCgTipo,{"FN7_CBASE"	,FN7->FN7_CBASE		})
				aadd(aCgTipo,{"FN7_CITEM"	,FN7->FN7_CITEM		})
				Aadd(aCgTipo,{"FN7_DESCRI"	,SN3->N3_HISTOR		})
				Aadd(aCgTipo,{"FN7_TIPO"	,FN7->FN7_TIPO		})
				Aadd(aCgTipo,{"FN7_TPSALD"	,FN7->FN7_TPSALD	})
				Aadd(aCgTipo,{"FN7_SEQ"		,FN7->FN7_SEQ		})
				Aadd(aCgTipo,{"FN7_MOEDA"	,FN7->FN7_MOEDA		})
				Aadd(aCgTipo,{"FN7_SEQREA"	,FN7->FN7_SEQREA	})
				Aadd(aCgTipo,{"FN7_MOTIVO"	,FN7->FN7_MOTIVO	})
				Aadd(aCgTipo,{"FN7_DTBAIX"	,FN7->FN7_DTBAIX	})
				Aadd(aCgTipo,{"FN7_VLATU"	,FN7->FN7_VLATU		})
				Aadd(aCgTipo,{"FN7_VLDEPR"	,FN7->FN7_VLDEPR	})
				Aadd(aCgTipo,{"FN7_VLBAIX"	,FN7->FN7_VLBAIX	})
				Aadd(aCgTipo,{"FN7_PERCBX"	,FN7->FN7_PERCBX	})
				Aadd(aCgTipo,{"FN7_STATUS"	,FN7->FN7_STATUS 	})
				Aadd(aCgTipo,{"FN7_FILORI"	,FN7->FN7_FILORI	})
				Aadd(aCgTipo,{"FN7_VLRESI"	,FN7->FN7_VLRESI	})
				If cPaisLoc == "RUS"
					aAdd(aCgTipo,{"FN7_VORIG"	, SN3->N3_VORIG1 })
					aAdd(aCgTipo,{"FN7_CALCDP"	, 0              })
					aAdd(aCgTipo,{"VRACUMVAL"   , SN3->N3_VRDACM1})
					aAdd(aCgTipo,{"FN7_VRDACM"	, SN3->N3_VRDACM1})
					aAdd(aCgTipo,{"FN7_CARRYV"	, SN3->(N3_VORIG1+N3_AMPLIA1-N3_VRDACM1)})
				EndIf
				Aadd(aCgTipo,{"UPDATE"		,.T.					})
				
				Aadd(aRetTip,{ 0, Af36MntFN7(oModelPai,aCgTipo,'FN7TIPO') })
			EndIf
		EndIf
		FN7->(dbSkip())
	EndDo
EndIf

RestArea(aArea)
RestArea(aSN1Area)
RestArea(aSN3Area)
RestArea(aFN6Area)
RestArea(aFN7Area)

Return aRetTip

/*/{Protheus.doc} AF036LtLv

Função que retorna a carga da grid de Valor de Ativos

@author marylly.araujo
@since 25/03/2014
@version 1.0
@param oModel Objeto do Modelo de Dados da Rotina de Baixa de Ativos
/*/
Function AF036LtLv(oModel)
Local oModelPai		:= oModel:GetModel()	// Carrega Model Master
Local oModelMaster	:= oModel:GetModel('FN6ATIVOS')
Local oModelTipo	:= oModel:GetModel('FN7TIPO')
Local aArea			:= GetArea()
Local aRetVal		:= {}
Local aCgTipo		:= {}
Local nX			:= 0
Local nTamMoeda		:= TamSX3("FN7_MOEDA")[1]
Local nTamItem		:= TamSX3("FN7_ITEM")[1]
Local cFilFN7		:= FWxFilial("FN7")
Local __nQuantas	:= AtfMoedas()
Local cFilOri		:= oModel:GetModel():GetModel("FN7TIPO"):GetValue("FN7_FILORI")
Local cFilShare		:= FwxFilial("SN3",cFilOri)

Local cBase 		:= oModelTipo:GetValue('FN7TIPO',"FN7_CBASE")
Local cItem 		:= oModelTipo:GetValue('FN7TIPO',"FN7_CITEM")
Local cTipo 		:= oModelTipo:GetValue('FN7TIPO',"FN7_TIPO")
Local cTpSaldo 		:= oModelTipo:GetValue('FN7TIPO',"FN7_TPSALD")
Local cSeqReav 		:= oModelTipo:GetValue('FN7TIPO',"FN7_SEQREA")
Local cSeq 			:= oModelTipo:GetValue('FN7TIPO',"FN7_SEQ")
Local cDtBx			:= DTOS(oModelTipo:GetValue('FN7TIPO',"FN7_DTBAIX"))
Local nPerBaixa		:= 0


If lIsRussia .And. __nOper == OPER_BXLOT .And. oModelPai:GetModel('PARAMETROS'):GetValue("DEPRBONUS") == 1
	nPerBaixa	:= oModelMaster:GetValue("FN6ATIVOS" , "FN6_BAIXA")
EndIf

If __nOper == OPER_BXLOT
	
	If Val(GetAdvFVal("SN3","N3_BAIXA",cFilShare+oModelTipo:GetValue("FN7TIPO","FN7_CBASE")+oModelTipo:GetValue("FN7TIPO","FN7_CITEM"),1,"",.T.)) == 0
		For nX := 1 To __nQuantas
			aCgTipo := {}
			Aadd(aCgTipo,{"FN7_FILIAL"	,cFilFN7											})
			Aadd(aCgTipo,{"FN7_CODBX"	,oModelMaster:GetValue("FN6ATIVOS" , "FN6_CODBX" )	})
			Aadd(aCgTipo,{"FN7_ITEM"	,PadL(nX,nTamItem,"0")								})
			Aadd(aCgTipo,{"FN7_CBASE"	,oModelMaster:GetValue("FN6ATIVOS" , "FN6_CBASE" )	})
			aadd(aCgTipo,{"FN7_CITEM"	,oModelMaster:GetValue("FN6ATIVOS" , "FN6_CITEM" )	})
			Aadd(aCgTipo,{"FN7_DESCRI"	,SN3->N3_HISTOR										})
			Aadd(aCgTipo,{"FN7_TIPO"	,oModelTipo:GetValue("FN7TIPO","FN7_TIPO")			})
			Aadd(aCgTipo,{"FN7_TPSALD"	,oModelTipo:GetValue("FN7TIPO","FN7_TPSALD")		})
			Aadd(aCgTipo,{"FN7_SEQ"		,oModelTipo:GetValue("FN7TIPO","FN7_SEQ")			})
			Aadd(aCgTipo,{"FN7_MOEDA"	,PADL(nX,nTamMoeda, "0")							})
			Aadd(aCgTipo,{"FN7_SEQREA"	,oModelTipo:GetValue("FN7TIPO","FN7_SEQREA")		})
			Aadd(aCgTipo,{"FN7_MOTIVO"	,oModelMaster:GetValue("FN6ATIVOS" , "FN6_MOTIVO")	})
			Aadd(aCgTipo,{"FN7_DTBAIX"	,oModelMaster:GetValue("FN6ATIVOS" , "FN6_DTBAIX")	})
			Aadd(aCgTipo,{"FN7_VLATU"	,0													})
			Aadd(aCgTipo,{"FN7_VLDEPR"	,0													})
			Aadd(aCgTipo,{"FN7_VLBAIX"	,0													})
			Aadd(aCgTipo,{"FN7_PERCBX"	,nPerBaixa											})
			Aadd(aCgTipo,{"FN7_STATUS"	,'1'												})
			Aadd(aCgTipo,{"FN7_FILORI"	,cFilOri											})
			Aadd(aCgTipo,{"FN7_VLRESI"	,0													})
			Aadd(aCgTipo,{"UPDATE"		,.F.												})
			
			Aadd(aRetVal,{ 0, Af36MntFN7(oModelPai,aCgTipo,'FN7VALOR') })
			
		Next nX
	EndIf
ElseIf __nOper == OPER_CANLT
	FN7->(dbSetOrder(2))//FN7_FILIAL+FN7_FILORI+FN7_CBASE+FN7_CITEM+FN7_TIPO+FN7_TPSALD+FN7_SEQREA+FN7_SEQ+DTOS(FN7_DTBAIX)+FN7_ITEM :TODO: Fazer query.
	
	If FN7->(dbSeek( xFilial("FN7") + cFilOri + cBase + cItem + cTipo + cTpSaldo + cSeqReav + cSeq + cDtBx ))
		
		While FN7->(!EOF()) .And. FN7->(FN7_FILIAL+FN7_FILORI+FN7_CBASE+FN7_CITEM+FN7_TIPO+FN7_TPSALD+FN7_SEQREA+FN7_SEQ+DTOS(FN7_DTBAIX)) == xFilial("FN7") + cFilOri + cBase + cItem + cTipo + cTpSaldo + cSeqReav + cSeq + cDtBx 
			If SN3->(dbSeek( xFilial("SN3",FN7->FN7_FILORI) + FN7->FN7_CBASE + FN7->FN7_CITEM + FN7->FN7_TIPO ))
				aCgTipo := {}
				Aadd(aCgTipo,{"FN7_FILIAL"	,FN7->FN7_FILIAL	})
				Aadd(aCgTipo,{"FN7_CODBX"	,FN7->FN7_CODBX		})
				Aadd(aCgTipo,{"FN7_ITEM"	,FN7->FN7_ITEM		})
				Aadd(aCgTipo,{"FN7_CBASE"	,FN7->FN7_CBASE		})
				aadd(aCgTipo,{"FN7_CITEM"	,FN7->FN7_CITEM		})
				Aadd(aCgTipo,{"FN7_DESCRI"	,SN3->N3_HISTOR		})
				Aadd(aCgTipo,{"FN7_TIPO"	,FN7->FN7_TIPO		})
				Aadd(aCgTipo,{"FN7_TPSALD"	,FN7->FN7_TPSALD	})
				Aadd(aCgTipo,{"FN7_SEQ"		,FN7->FN7_SEQ		})
				Aadd(aCgTipo,{"FN7_MOEDA"	,FN7->FN7_MOEDA		})
				Aadd(aCgTipo,{"FN7_SEQREA"	,FN7->FN7_SEQREA	})
				Aadd(aCgTipo,{"FN7_MOTIVO"	,FN7->FN7_MOTIVO	})
				Aadd(aCgTipo,{"FN7_DTBAIX"	,FN7->FN7_DTBAIX	})
				Aadd(aCgTipo,{"FN7_VLATU"	,FN7->FN7_VLATU		})
				Aadd(aCgTipo,{"FN7_VLDEPR"	,FN7->FN7_VLDEPR	})
				Aadd(aCgTipo,{"FN7_VLBAIX"	,FN7->FN7_VLBAIX	})
				Aadd(aCgTipo,{"FN7_PERCBX"	,FN7->FN7_PERCBX	})
				Aadd(aCgTipo,{"FN7_STATUS"	,FN7->FN7_STATUS	})
				Aadd(aCgTipo,{"FN7_FILORI"	,FN7->FN7_FILORI	})
				Aadd(aCgTipo,{"FN7_VLRESI"	,FN7->FN7_VLRESI	})
				Aadd(aCgTipo,{"UPDATE"		,.T.				})
				Aadd(aRetVal,{ 0, Af36MntFN7(oModelPai,aCgTipo,'FN7VALOR') })
			EndIf
			FN7->(dbSkip())
		EndDo
	EndIf
EndIf
RestArea(aArea)


Return aRetVal

/*/{Protheus.doc} AF036LotPR

Função que carrega o submodelo de parâmetros da baixa em lote.

@author marylly.araujo
@since 27/03/2014
@version 1.0
@param oModel Objeto do Modelo de Dados da Rotina de Baixa de Ativos
/*/

Function AF036LtPR(oModel)
Local aRetPar	:= {}
Local aFilCpos	:= {}
Local nX		:= 0

/*
 * Carrega os dados do bem selecionado para executação da baixa manual
 */
Pergunte("AFA036LOTE",.F.)

If FwIsInCallStack("AF036BxLote") .And. __xParLot <> Nil
	For nX := 1 to Len(__xParLot)
		&("MV_PAR"+STRZERO(nX,2)) := __xParLot[nX][2]
	Next nX
EndIf

aAdd(aFilCpos,MV_PAR01)
aAdd(aFilCpos,MV_PAR02)
aAdd(aFilCpos,MV_PAR03)
aAdd(aFilCpos,MV_PAR04)
aAdd(aFilCpos,MV_PAR05)
aAdd(aFilCpos,MV_PAR06)
aAdd(aFilCpos,MV_PAR07)
aAdd(aFilCpos,MV_PAR08)
aAdd(aFilCpos,MV_PAR09)
aAdd(aFilCpos,MV_PAR10)
If lIsRussia
	aAdd(aFilCpos,MV_PAR12)
	aAdd(aFilCpos,MV_PAR13)
EndIf
aRetPar := {aFilCpos,0}

Return aRetPar

/*/{Protheus.doc} AF036LotCb

Carrega os dados do cabeçalho da baixa em Lote (Tabela FN8)

@author marylly.araujo
@since 26/03/2014
@version 1.0
@param oModel Objeto do Modelo de Dados da Rotina de Baixa de Ativos
/*/

Function AF036LtCb(oModel)
Local aFilCpos		:= {}
Local aDados		:= {}
Local aFields		:= oModel:oFormModelStruct:GetFields()
Local nX			:= 1
Local lRusDepBonus	:= lIsRussia .And. __nOper == OPER_BXLOT .And. MV_PAR12 == 1

If __nOper == OPER_BXLOT
	/*
	 * Carrega os dados do bem selecionado para executação da baixa manual
	 */
	For nX:= 1 to Len(aFields)

		If AllTrim(aFields[nX][3]) == "FN8_DTBAIX"
			aAdd(aFilCpos,DDATABASE		) //FN8_DTBAIX
		ElseIf AllTrim(aFields[nX][3]) == "FN8_FILIAL"
			aAdd(aFilCpos,FWxFilial("FN8")		) //FN8_FILIAL
		ElseIf AllTrim(aFields[nX][3]) == "FN8_DEPREC"
			aAdd(aFilCpos,IIf(lRusDepBonus, "0", GETMV('MV_ATFDPBX'))	) //FN8_DEPREC
		ElseIf AllTrim(aFields[nX][3]) == "FN8_LOTE"
			aAdd(aFilCpos,Af036CodLT()	) //FN8_LOTE
		ElseIf AllTrim(aFields[nX][3]) == "FN8_MOTIVO"
			aAdd(aFilCpos, IIf(lRusDepBonus, "09", CriaVar("FN8_MOTIVO")) ) //FN8_MOTIVO
		ElseIf AllTrim(aFields[nX][3]) == "OK"
			aAdd(aFilCpos,.F.	) 
		EndIf

		If nX > Len(aFilCpos)
			aAdd(aFilCpos,	CriaVar( AllTrim(aFields[nX][3]))	)
		EndIf
	Next nX
ElseIf __nOper == OPER_CANLT
	For nX:= 1 to Len(aFields)
		If AllTrim(aFields[nX][3]) == "FN8_FILIAL"
			aAdd(aFilCpos,FN8->FN8_FILIAL	) //FN8_FILIAL
		ElseIf AllTrim(aFields[nX][3]) == "FN8_LOTE"
			aAdd(aFilCpos,FN8->FN8_LOTE		) //FN8_LOTE
		ElseIf AllTrim(aFields[nX][3]) == "FN8_MOTIVO"
			aAdd(aFilCpos,FN8->FN8_MOTIVO	) //FN8_MOTIVO
		ElseIf AllTrim(aFields[nX][3]) == "FN8_DTBAIX"
			aAdd(aFilCpos,FN8->FN8_DTBAIX	) //FN8_DTBAIX
		ElseIf AllTrim(aFields[nX][3]) == "FN8_DEPREC"
			aAdd(aFilCpos,FN8->FN8_DEPREC	) //FN8_DEPREC
		ElseIf AllTrim(aFields[nX][3]) == "FN8_STATUS"
			aAdd(aFilCpos,FN8->FN8_STATUS	) //FN8_STATUS
		ElseIf AllTrim(aFields[nX][3]) == "OK"
			aAdd(aFilCpos,.F.	) 
		EndIf

		If nX > Len(aFilCpos)
			aAdd(aFilCpos,	CriaVar( AllTrim(aFields[nX][3]))	)
		EndIf	
	Next nX
EndIf

aDados := {aFilCpos,0}

Return aDados


/*/{Protheus.doc} AF036LMARK

Função que retorna a carga da grid de Tipos de Ativos

@author marylly.araujo
@since 27/03/2014
@version 1.0
/*/
Function AF036LMARK()
Local aArea			:= GetArea() 
Local aSN3Area 		:= SN3->(GetArea())
Local oModel		:= FWModelActive()
Local oView			:= FWViewActive()
Local oModelMaster 	:= oModel:GetModel('FN6ATIVOS')			// Carrega Model Master
Local oModelTipo 	:= oModel:GetModel('FN7TIPO')			// Carrega Model TIPO
Local cBase			:= oModelMaster:GetValue("FN6_CBASE")	// Codigo Base
Local cItem			:= oModelMaster:GetValue("FN6_CITEM")	// Codigo Item
Local cTipo			:= oModelTipo:GetValue("FN7_TIPO" 	)	// Tipo de Ativo
Local cTpSaldo		:= oModelTipo:GetValue("FN7_TPSALD" )	// Tipo de Saldo
Local aSaveLines 	:= FWSaveRows()
Local lRet 			:= .T.
Local nX			:= 0
Local lMarcardo		:= .F.
Local cMarcaTipo	:= ""
Local nLinPos		:= oModelTipo:GetLine()
Local lMarca		:= oModelTipo:GetValue("OK",nLinPos)
Local lFilter		:= ExistBlock("F036FIL")
Local cFilX			:= cFilAnt
Local cTypes10		:= IIF(lIsRussia,"|" + AtfNValMod({1}, "|"),"") // CAZARINI - 24/03/2017 - If is Russia, add new valuations models - main models

cFilAnt := oModelMaster:GetValue("FN6_FILORI")

If lFilter
	lMarca := ExecBlock("F036FIL",.F.,.F.)
	oModelTipo:SetValue("OK" , lMarca)
EndIf


If __nOper != OPER_VISUA .AND.  __nOper != OPER_CANLT
	/*
	 * Posiciona no SN3 selecionado
	 */
	dbSelectArea("SN3")
	
	
	SN3->(DBSetOrder(11)) // Filial + Código Base + Item Base + Tipo Ativo + Baixa do Ativo + Tipo de Saldo
	SN3->(dbSeek( xFilial("SN3") + cBase + cItem + cTipo + "0" + cTpSaldo ))
	
	/*
	 * Verifica se a conta contabil foi preenchida
	 */
	If Empty(SN3->N3_CCONTAB)
		Help(" ",1,"A036CTAV",,STR0024,1,0) //"Este bem nao tem a conta do bem preenchida. Verifique se ja foi classifcado"
		oModelTipo:LoadValue("OK" , .F. )
		lRet := .F.
	EndIf
	
	If Upper(AllTrim(SN3->N3_TPDEPR)) == "A"
		lRet := ATFVALIND()
		oModelTipo:LoadValue("OK" , lRet )
	EndIf
	
	lMarcardo := oModelTipo:GetValue("OK")
	
	/*
	 * Os registos do Tipo 14 somente serão seleccionados através do Tipo 10
	 */
	If cTipo == '14'
		Help(" ",1,"ATFNO14" ,,STR0025,1,0)//"Os registos do Tipo 14 somente poderão ser seleccionados através do Tipo 10. Seleccione o Tipo 10 e o Tipo 14 será seleccionado automaticamente para o processo."
		lRet := .F.
	EndIf
	
	/*
	 * Os registos do Tipo 15 somente serão seleccionados através do Tipo 10
	 */
	If cTipo == '15'
		Help(" ",1,"ATFNO15" ,,STR0026,1,0)//"Os registos do Tipo 14 somente poderão ser seleccionados através do Tipo 10. Seleccione o Tipo 10 e o Tipo 14 será seleccionado automaticamente para o processo."
		lRet := .F.
	EndIf
	
	If lRet
		If cTipo $ ("10" + cTypes10)
			cMarcaTipo := "14#15"
		ElseIf cTipo == "13"
			cMarcaTipo := "15"
		EndIf
	
		If !Empty(cMarcaTipo)
			For nX := 1 to oModelTipo:Length()
				oModelTipo:Goline( nx )
				If oModelTipo:GetValue("FN7_TIPO") $ cMarcaTipo .And. oModelTipo:GetValue("FN7_TPSALD") == cTpSaldo 
					oModelTipo:LoadValue("OK" , lMarcardo )
					lRet := .T.
				EndIf
			Next nX
		Endif
	EndIf 
	
	If oView != Nil .And. oView:IsActive()
		oView:Refresh("FN7TIPO")
	EndIf	
	
Else
	lRet := .F.
EndIf

cFilAnt := cFilX
RestArea(aArea)
RestArea(aSN3Area)
FWRestRows(aSaveLines)

Return lRet

/*/{Protheus.doc} AF036TMARK

Função que retorna a carga da grid de Tipos de Ativos

@author marylly.araujo
@since 27/03/2014
@version 1.0
/*/
Function AF036TMARK()
Local oModel		:= FWModelActive()
Local oModelFN6		:= oModel:GetModel("FN6ATIVOS")
Local oModelFN7		:= oModel:GetModel("FN7TIPO")
Local lRet			:= .T.
Local aSaveLines	:= FWSaveRows()
Local nLinPos		:= oModelFN6:GetLine()
Local lMarca		:= oModelFN6:GetValue("OK",nLinPos)
Local nX			:= 0
Local oView			:= FWViewActive()

If lMarca
	lRet := AF036DtBx(.T.,.F.,oModel)
	lMarca := lRet
Endif

For nX := 1 to oModelFN7:Length()
	oModelFN7:GoLine(nX)
	oModelFN7:LoadValue("OK",lMarca)
Next nX

FWRestRows( aSaveLines )

If oView != Nil .And. oView:IsActive()
	oModelFN7:GoLine(1)
	oView:Refresh("FN7TIPO")
EndIf
		
Return lRet

/*/{Protheus.doc} AT36StPar

Estrutura de dados para armazenar no modelo os valores acumulados necessário para a análise da baixa de ativo.

@author marylly.araujo
@since 08/04/2014
@version 1.0
/*/
Function AT36StPar()

Local oStruPar	:= FWFormModelStruct():New()

oStruPar:AddField(	;
STR0027				, ;	// [01] Titulo do campo	//"Filial De"
STR0027				, ;	// [02] ToolTip do campo	//"Filial De"
"FILIALDE"			, ;	// [03] Id do Field
"C"					, ;	// [04] Tipo do campo
FWSizeFilial()		, ;	// [05] Tamanho do campo
0					, ;	// [06] Decimal do campo
{ || .T. }			, ;	// [07] Code-block de validação do campo
, ;	// [08] Code-block de validação When do campo
, ;	// [09] Lista de valores permitido do campo
.F.)// [10] Indica se o campo tem preenchimento obrigatório

oStruPar:AddField(	  ;
STR0028				, ;	// [01] Titulo do campo	//"Filial Até"
STR0028				, ;	// [02] ToolTip do campo	//"Filial Até"
"FILIALATE"			, ;	// [03] Id do Field
"C"					, ;	// [04] Tipo do campo
FWSizeFilial()		, ;	// [05] Tamanho do campo
0					, ;	// [06] Decimal do campo
{ || .T. }			, ;	// [07] Code-block de validação do campo
, ;	// [08] Code-block de validação When do campo
, ;	// [09] Lista de valores permitido do campo
.F.)// [10] Indica se o campo tem preenchimento obrigatório

oStruPar:AddField(	  ;
STR0029			 	, ;	// [01] Titulo do campo		//"Grupo de Bens De"
STR0029				, ;	// [02] ToolTip do campo	//"Grupo de Bens De"
"GRUPODE"			, ;	// [03] Id do Field
"C"					, ;	// [04] Tipo do campo
TamSX3(IIf(lIsRussia, "FM1_CODE", "NG_GRUPO"))[1], ;	// [05] Tamanho do campo
0					, ;	// [06] Decimal do campo
{ || .T. }			, ;	// [07] Code-block de validação do campo
, ;	// [08] Code-block de validação When do campo
, ;	// [09] Lista de valores permitido do campo
.F.)// [10] Indica se o campo tem preenchimento obrigatório

oStruPar:AddField(	  ;
STR0030				, ;	// [01] Titulo do campo	//"Grupo de Bens Até"
STR0030				, ;	// [02] ToolTip do campo	//"Grupo de Bens Até"
"GRUPOATE"			, ;	// [03] Id do Field
"C"					, ;	// [04] Tipo do campo
TamSX3(IIf(lIsRussia, "FM1_CODE", "NG_GRUPO"))[1], ;	// [05] Tamanho do campo
0					, ;	// [06] Decimal do campo
{ || .T. }			, ;	// [07] Code-block de validação do campo
, ;	// [08] Code-block de validação When do campo
, ;	// [09] Lista de valores permitido do campo
.F.)// [10] Indica se o campo tem preenchimento obrigatório

oStruPar:AddField(	  ;
STR0031 				, ;	// [01] Titulo do campo	//"Código de Bem De"
STR0031					, ;	// [02] ToolTip do campo	//"Código de Bem De"
"CODIGODE"				, ;	// [03] Id do Field
"C"						, ;	// [04] Tipo do campo
TamSX3("N1_CBASE")[1]	, ;	// [05] Tamanho do campo
0						, ;	// [06] Decimal do campo
{ || .T. }				, ;	// [07] Code-block de validação do campo
, ;	// [08] Code-block de validação When do campo
, ;	// [09] Lista de valores permitido do campo
.F.)// [10] Indica se o campo tem preenchimento obrigatório

oStruPar:AddField(	  ;
STR0032					, ;	// [01] Titulo do campo	//"Código de Bem Até"
STR0032					, ;	// [02] ToolTip do campo	//"Código de Bem Até"
"CODIGOATE"				, ;	// [03] Id do Field
"C"						, ;	// [04] Tipo do campo
TamSX3("N1_CBASE")[1]	, ;	// [05] Tamanho do campo
0						, ;	// [06] Decimal do campo
{ || .T. }				, ;	// [07] Code-block de validação do campo
, ;	// [08] Code-block de validação When do campo
, ;	// [09] Lista de valores permitido do campo
.F.)// [10] Indica se o campo tem preenchimento obrigatório

oStruPar:AddField(	  ;
STR0033	 				, ;	// [01] Titulo do campo		//"Item de Bem De"
STR0033					, ;	// [02] ToolTip do campo	//"Item de Bem De"
"ITEMDE"				, ;	// [03] Id do Field
"C"						, ;	// [04] Tipo do campo
TamSX3("N1_ITEM")[1]	, ;	// [05] Tamanho do campo
0						, ;	// [06] Decimal do campo
{ || .T. }				, ;	// [07] Code-block de validação do campo
, ;	// [08] Code-block de validação When do campo
, ;	// [09] Lista de valores permitido do campo
.F.)// [10] Indica se o campo tem preenchimento obrigatório

oStruPar:AddField(	  ;
STR0034					, ;	// [01] Titulo do campo		//"Item de Bem Até"
STR0034					, ;	// [02] ToolTip do campo	//"Item de Bem Até"
"ITEMATE"				, ;	// [03] Id do Field
"C"						, ;	// [04] Tipo do campo
TamSX3("N1_ITEM")[1]	, ;	// [05] Tamanho do campo
0						, ;	// [06] Decimal do campo
{ || .T. }				, ;	// [07] Code-block de validação do campo
, ;	// [08] Code-block de validação When do campo
, ;	// [09] Lista de valores permitido do campo
.F.)// [10] Indica se o campo tem preenchimento obrigatório

oStruPar:AddField( ;
STR0035					, ;	// [01] Titulo do campo		//"Data Aquisição De"
STR0035					, ;	// [02] ToolTip do campo	//"Data Aquisição De"
"DATADE"				, ;	// [03] Id do Field
"D"						, ;	// [04] Tipo do campo
8						, ;	// [05] Tamanho do campo
0						, ;	// [06] Decimal do campo
{ || .T. }				, ;	// [07] Code-block de validação do campo
, ;	// [08] Code-block de validação When do campo
, ;	// [09] Lista de valores permitido do campo
.F.)// [10] Indica se o campo tem preenchimento obrigatório

oStruPar:AddField( ;
STR0036					, ;	// [01] Titulo do campo		//"Data Aquisição Até"
STR0036					, ;	// [02] ToolTip do campo	//"Data Aquisição Até"
"DATAATE"				, ;	// [03] Id do Field
"D"						, ;	// [04] Tipo do campo
8						, ;	// [05] Tamanho do campo
0						, ;	// [06] Decimal do campo
{ || .T. }				, ;	// [07] Code-block de validação do campo
, ;	// [08] Code-block de validação When do campo
, ;	// [09] Lista de valores permitido do campo
.F.)// [10] Indica se o campo tem preenchimento obrigatório

If lIsRussia
	oStruPar:AddField( ;
	STR0057					, ;	// [01] Titulo do campo		//"Depreciation Bonus?"
	STR0057					, ;	// [02] ToolTip do campo	//"Depreciation Bonus?"
	"DEPRBONUS"				, ;	// [03] Id do Field
	"N"						, ;	// [04] Tipo do campo
	1						, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	, ;	// [08] Code-block de validação When do campo
	{"Yes","No"}, ;	// [09] Lista de valores permitido do campo
	.F.)// [10] Indica se o campo tem preenchimento obrigatório
	
	oStruPar:AddField( ;
	STR0058					, ;	// [01] Titulo do campo		//"Type?"
	STR0058					, ;	// [02] ToolTip do campo	//"Type?"
	"DEPBNSTYPE"			, ;	// [03] Id do Field
	"N"						, ;	// [04] Tipo do campo
	1						, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	, ;	// [08] Code-block de validação When do campo
	{"01","11"}, ;	// [09] Lista de valores permitido do campo
	.F.)// [10] Indica se o campo tem preenchimento obrigatório
EndIf

Return oStruPar

/*/{Protheus.doc} AT36VlAct

Função de atualização dos valores de baixa

@author marylly.araujo
@since 15/04/2014
@version 1.0
/*/

Function AT36LAct(oModel)
Local aArea			:= GetArea()
Local aSN1Area		:= SN1->(GetArea())
Local aSN3Area		:= SN3->(GetArea())
Local lRet			:= .T.
Local oModelAtv		:= oModel:GetModel("FN6ATIVOS")
Local oModelTipo	:= oModel:GetModel("FN7TIPO")
Local oModelValor	:= oModel:GetModel("FN7VALOR")
Local nCtnAtv		:= 0
Local nCtnTipo		:= 0

If __nOper == OPER_BXLOT
	For nCtnAtv := 1 To oModelAtv:Length()
		oModelAtv:GoLine(nCtnAtv)	
		For nCtnTipo := 1 To oModelTipo:Length()
			oModelTipo:GoLine(nCtnTipo)
			AF036ATU(oModel,,,__nOper)
		Next nCtnTipo
	Next nCtnAtv
EndIf


oModelAtv:GoLine(1)
oModelTipo:GoLine(1)
oModelValor:GoLine(1)
RestArea(aSN1Area)
RestArea(aSN3Area)
RestArea(aArea)
Return lRet

/*/{Protheus.doc} AF036LPos

Validacoes para a baixa em lote

@author Totvs
@since 22/04/2014
@version 12
/*/
Function AF036LPos(oModel)
Local aArea			:= GetArea()
Local oView			:= FWViewActive()
Local oModelMaster	:= oModel:GetModel('FN6ATIVOS')
Local oModelTipo	:= oModel:GetModel('FN7TIPO')
Local oModelValor	:= oModel:GetModel('FN7VALOR')
Local nCtnAtivo		:= 0
Local nCtnTipo		:= 0
Local cMotivo		:= ""
Local cSerie		:= ""
Local lGeraNF		:= .F. 	//Define se a Nota Fiscal sera gerada na baixa do bem
Local cCliente		:= ""			//Cliente
Local cLoja			:= ""				//Loja
Local cTESSaida		:= ""			//Tipo de Saida
Local cCondPag		:= ""			//Condicao de Pagamento
Local cNatureza		:= ""			//Natureza
Local nValNF		:= 0			//Valor da NF
Local cTipAtivNF	:= SuperGetMV("MV_ATFMBNF",.F.,"")				//Parametro com os tipos de ativos que podem ser baixados
Local lRet			:= .T.
Local cFilX			:= cFilAnt
Local aSaveLines 	:= FWSaveRows()
Local nCont			:= 0
Local nI 			:= 0

If __nOper == OPER_BXLOT .And. cPaisLoc=="BRA" .And. Type("mv_par12") == "N"
	If MV_PAR12 == 2
		nPerBaixa := oModel:GetModel("FN8LOTE"):GetValue("FN8_BAIXA")
		For nI := 1 to oModelMaster:Length()
			oModelMaster:GoLine( nI ) 
			oModelMaster:RunTrigger("FN6_BAIXA")
		Next nY		
	EndIf
EndIf

SA1->(DbSetOrder(1))
SE4->(DbSetOrder(1))
SED->(DbSetOrder(1))
SF4->(DbSetOrder(1))

If lExisCPC31 == Nil
	lExisCPC31 := SN1->(Fieldpos("N1_BLQDEPR")) > 0 .And. cPaisLoc == "BRA" //CPC31, VERIFICA SE O CAMPO EXISTE NA BASE E SE ? DA LOCALIDADE DO BRASIL
EndIF

If __nOper == OPER_BXLOT
	
	//------------------------------------------
	// Validacoes para a geracao da Nota Fiscal
	//------------------------------------------
	
	//Validação CPC31 tipo de venda sem depreciar, não pode ser em baixa parcial
	//NÃO REMOVER
	If lRet .And. lExisCPC31 .And. oModel:GetModel("FN8LOTE"):GetValue("FN8_DEPREC") == '3' .And. oModel:GetModel("FN8LOTE"):GetValue("FN8_BAIXA") <> 100
		lRet := .F.
		Help("",1,STR0060,,STR0061,1,0) // Depreciar - Opção 3 ## Opção:  3 - Não Deprecia Baixa/posteriormente, não é possivel baixar um bem parcialmente com está opção, utilize a baixa total do bem"
	Endif

	For nCtnAtivo := 1 to oModelMaster:Length()
		lRet := lRet .And. AF036DtBx(.F.,.T.,oModel)
		If !lRet
			Exit
		EndIf
		oModelMaster:GoLine( nCtnAtivo )
		If oModelMaster:GetValue("OK")
			nCont++
			cMotivo		:= oModelMaster:GetValue( 'FN6_MOTIVO')
			cSerie		:= oModelMaster:GetValue( 'FN6_SERIE' )
			lGeraNF		:= oModelMaster:GetValue( 'FN6_GERANF') == "1" 	//Define se a Nota Fiscal sera gerada na baixa do bem
			cCliente	:= oModelMaster:GetValue( 'FN6_CLIENT')			//Cliente
			cLoja		:= oModelMaster:GetValue( 'FN6_LOJA')			//Loja
			cTESSaida	:= oModelMaster:GetValue( 'FN6_TESSAI')			//Tipo de Saida
			cCondPag	:= oModelMaster:GetValue( 'FN6_CNDPAG')			//Condicao de Pagamento
			cNatureza	:= oModelMaster:GetValue( 'FN6_NATURE')			//Natureza
			nValNF		:= oModelMaster:GetValue( 'FN6_VALNF')			//Valor da NF
			cFilAnt		:= oModelMaster:GetValue( 'FN6_FILORI')
			cBase		:= oModelMaster:GetValue( 'FN6_CBASE')
			cItem		:= oModelMaster:GetValue( 'FN6_CITEM')
			
			//------------------------------------------------------
			//Verifica o motivo da baixa com os motivos permitidos
			//------------------------------------------------------
			If lRet .And. (cMotivo == '01') .And. Empty(nValNF)
				lRet := .F.
				Help(" ",1, "AF036LPos1",,STR0052+ " " + STR0049 + cFilAnt + " "+STR0050 + cBase + " " + STR0051+ cItem,1,0) //"Para o motivo de baixa 01 - Venda, o valor da nota fiscal é obrigatório"##"Filial de Origem: "##"Código Base: "##"Item: "
			EndIf
		
			If lRet .And. lGeraNF
				
				//---------------------------------
				// Valida se a Serie foi informada
				//---------------------------------
				If lRet .And. Empty(cSerie)
					lRet := .F.
					Help(" ",1, "AF036LPo2",,STR0037 + " " + STR0049 + cFilAnt + " "+STR0050 + cBase + " " + STR0051+ cItem ,1,0) //"Informe a série para a geração da Nota Fiscal."##"Filial de Origem: "##"Código Base: "##"Item: "
				EndIf
				
				//------------------------------------------------------
				//Verifica o motivo da baixa com os motivos permitidos
				//------------------------------------------------------
				If lRet .And. !(cMotivo $ cTipAtivNF)
					lRet := .F.
					Help(" ",1, "AF036LPo3",,STR0038+ " " + STR0049 + cFilAnt + " "+STR0050 + cBase + " " + STR0051+ cItem,1,0) //"Não é possivel gerar a nota fiscal para o motivo da baixa selecionado. Ver o parâmetro MV_ATFMBNF."##"Filial de Origem: "##"Código Base: "##"Item: "
				EndIf
				
				//----------------------------------------------
				//Verifica se o cliente e loja foram informados
				//----------------------------------------------
				If lRet .And. !SA1->(dbSeek(xFilial("SA1") + cCliente + cLoja) )
					lRet := .F.
					Help(" ",1, "AF036LPo4",,STR0039+ " " + STR0049 + cFilAnt + " "+STR0050 + cBase + " " + STR0051+ cItem,1,0) //"O Cliente e Loja devem ser informados para a geração da nota fiscal."##"Filial de Origem: "##"Código Base: "##"Item: "
				EndIf
				
				//--------------------------------------------
				// Verifica se o TES de saida esta preenchida
				//--------------------------------------------
				If lRet
					If SF4->(dbSeek(xFilial("SF4") + cTESSaida) )
						//---------------------------------------------------------------------------------------
						// Verifica se a TES esta configura para gerar duplicata e se a Natureza esta preenchida
						//---------------------------------------------------------------------------------------
						If lRet .And. SF4->F4_DUPLIC == 'S' .And. !SED->(dbSeek(xFilial("SED") + cNatureza) )
							lRet := .F.
							Help(" ",1, "AF036LPos6",,STR0041+ " " + STR0049 + cFilAnt + " "+STR0050 + cBase + " " + STR0051+ cItem,1,0) //"Para Tipo de Saída que atualize o financeiro a Natureza deverá ser informada."##"Filial de Origem: "##"Código Base: "##"Item: "
						EndIf
					Else
						lRet := .F.
						Help(" ",1, "AF036LPos7",,STR0042+ " " + STR0049 + cFilAnt + " "+STR0050 + cBase + " " + STR0051+ cItem,1,0) //"O Tipo de Saída precisa ser informada para a geracao da nota fiscal."##"Filial de Origem: "##"Código Base: "##"Item: "
					EndIf
				EndIf
				
				//------------------------------------------------------
				// Verifica se a condicao de pagamento foi informada
				//------------------------------------------------------
				If lRet .And. !SE4->(dbSeek(xFilial("SE4") + cCondPag) )
					lRet := .F.
					Help(" ",1, "AF036LPos8",,STR0043+ " " + STR0049 + cFilAnt + " "+STR0050 + cBase + " " + STR0051+ cItem,1,0) //"A condição de pagamento precisa ser informada para a geracao da nota fiscal."##"Filial de Origem: "##"Código Base: "##"Item: "
				EndIf
				
				//-----------------------------------------
				// Verifica se o Valor da NF foi informado
				//-----------------------------------------
				If lRet .And. nValNF == 0
					lRet := .F.
					Help(" ",1, "AF036LPos9",,STR0044+ " " + STR0049 + cFilAnt + " "+STR0050 + cBase + " " + STR0051+ cItem,1,0) //"Informe o valor da nota fiscal."##"Filial de Origem: "##"Código Base: "##"Item: "
				EndIf
				
				//-------------------------------------------------------
				//Verifica se todos os tipos estao selecionados
				//-------------------------------------------------------
				If lRet
					For nCtnTipo := 1 to oModelTipo:Length()
						oModelTipo:GoLine( nCtnTipo )
						If !oModelTipo:GetValue("OK")
							lRet := .F.
							Help(" ",1, "AF036LPos10",,STR0045+ " " + STR0049 + cFilAnt + " "+STR0050 + cBase + " " + STR0051+ cItem,1,0) //"Todos os tipos devem ser selecionados para a geracao da nota fiscal."##"Filial de Origem: "##"Código Base: "##"Item: "
							Exit
						EndIf
					Next nCtnTipo
				EndIf
				
				//-----------------------------------------------------------------
				//Verifica se há os tipos 01-Depreciacao Fiscal ou 03-Adiantamento
				//-----------------------------------------------------------------
				If lRet
					lRet := .F.
					For nCtnTipo := 1 to oModelTipo:Length()
						oModelTipo:GoLine( nCtnTipo )
						If oModelTipo:GetValue("OK") .And. oModelTipo:GetValue("FN7_TIPO") $ "01|03"
							lRet := .T.
							Exit
						EndIf
					Next nCtnTipo
					If !lRet
						Help(" ",1, "AF036LPos11",,STR0046+ " " + STR0049 + cFilAnt + " "+STR0050 + cBase + " " + STR0051+ cItem ,1,0) //"Para a geração da nota fiscal o ativo precisa ter os tipos 01 ou 03."##"Filial de Origem: "##"Código Base: "##"Item: "
					EndIf
					
				EndIf
				
				//------------------------------------
				//Verificacoes dos ativos selecionados
				//-----------------------------------
				If lRet
					
					//----------------------------------------------------------
					// Verifica se a quantidade de baixa foi digitada. Para a geracao da NF deve ser maior que zero.
					//----------------------------------------------------------
					If oModelMaster:GetValue( 'FN6_QTDBX',nCtnAtivo ) == 0
						Help(" ",1, "AF036LPos12",, STR0047+ " " + STR0049 + cFilAnt + " "+STR0050 + cBase + " " + STR0051+ cItem,1,0) //"Quantidade de Baixa deve ser maior que zero."##"Filial de Origem: "##"Código Base: "##"Item: "
						lRet := .F.
					EndIf
					
					//----------------------------------------------------------
					//Verifica se o Ativo possui produto cadastrado (N1_PRODUTO)
					//----------------------------------------------------------
					If lRet .And. Empty(GetAdvFVal("SN1","N1_PRODUTO",XFILIAL("SN1")+oModelMaster:GetValue( 'FN6_CBASE',nCtnAtivo )+oModelMaster:GetValue( 'FN6_CITEM',nCtnAtivo ),1,""))
						lRet := .F.
						Help(" ",1, "AF036LPos13",,STR0048+ " " + STR0049 + cFilAnt + " "+STR0050 + cBase + " " + STR0051+ cItem,1,0) //"O ativo não possui produto relacionado em seu cadastro para a geracao da nota fiscal."##"Filial de Origem: "##"Código Base: "##"Item: "
					EndIf
				EndIf
				
			EndIf
			
			//Validação CPC31 tipo de venda sem depreciar, não pode ser em baixa parcial
			//NÃO REMOVER
			If lRet .And. lExisCPC31 .And. oModelMaster:GetValue( 'FN6_DEPREC') == '3' .And. oModelMaster:GetValue( 'FN6_BAIXA') <> 100
				lRet := .F.
				Help("",1,STR0060,,STR0061,1,0) // Depreciar - Opção 3 ## Opção:  3 - Não Deprecia Baixa/posteriormente, não é possivel baixar um bem parcialmente com está opção, utilize a baixa total do bem"
			Endif

			If lRet
				lRet := AF036VLBX(oModelMaster,oModelTipo,oModelValor)
			EndIf
			
			lRet := lRet .And. AF036DtBx(.F.,.F.,oModel)
			
		EndIf
	Next
		
	If lRet .And. Empty(nCont)
		lRet := .F.
		Help(" ",1, "AF036LPos14",,STR0053,1,0) //"Por favor selecionar ativo para baixa"
	EndIf
	
EndIf

FWRestRows(aSaveLines)
If !lRet
	oModelMaster:GoLine( nCtnAtivo - 1 )
Endif
RestArea(aArea)

If oView != Nil .And. oView:IsActive()
	oView:Refresh()
EndIf

cFilAnt := cFilX

Return lRet

/*/{Protheus.doc} AF036LGatL

Funcao para replicar os dados do cabecalho para os itens

@author Totvs
@since 23/04/2014
@version 12
/*/
Function AF036LGatL(cCampo, oMdl)
Local oModel		:= IIf(Empty(oMdl), FWModelActive(), oMdl)
Local oModelFN8		:= oModel:GetModel("FN8LOTE")
Local oModelFN6		:= oModel:GetModel("FN6ATIVOS")
Local xValCpo		:= Nil
Local oView			:= FWViewActive()
Local aSaveLines 	:= FWSaveRows()

Default cCampo	:= ""

xValCpo := oModelFN8:GetValue("FN8" + cCampo)

If oView != Nil
	MsgRun( STR0020,, {|| AF036LGVal(oModelFN6,cCampo,xValCpo,oModel) } )//"Processando..."
Else
	AF036LGVal(oModelFN6,cCampo,xValCpo,oModel)
EndIf

If "FN8" + cCampo == "FN8_GERANF" .And. xValCpo == "1"
	oModelFN8:LoadValue('FN8_NUMNF','')
	If   oView <> Nil .And. oView:IsActive() .and. !IsBlind()
		oView:Refresh("FN8LOTE")
	EndIf
EndIf

FWRestRows(aSaveLines)

If oView != Nil .And. oView:IsActive() .And. !isBlind()
	oView:Refresh()
	oView:Refresh("FN8LOTE")
EndIf	

Return xValCpo

/*/{Protheus.doc} AF036LGVal

Funcao para replicar a marcação para todos os itens

@author Totvs
@since 23/04/2014
@version 12
/*/
Function AF036LGVal(oModelFN6,cCampo,xValCpo,oModel)
Local nY 	:= 1
Local lRet	:= .F.
Local oModelPar	  AS OBJECT
Local lAtuVal := .T.
Local nPerBaixa := 0
Local nQtdBaixa := 0
Local nQtdAtual := 0

If __nOper == OPER_BXLOT .And. cPaisLoc=="BRA" .And. Type("mv_par12") == "N"
	If MV_PAR12 == 2
		lAtuVal	  := .F.
		nPerBaixa := oModel:GetModel("FN8LOTE"):GetValue("FN8_BAIXA")
	EndIf
EndIf

For nY := 1 to oModelFN6:Length()
	oModelFN6:GoLine( nY ) //Posiciona no primeiro tipo de ativo

	If cPaisLoc == "RUS" .And. cCampo == "_BAIXA"
		oModelPar	:= oModel:GetModel("PARAMETROS")
		If ! Empty(oModelPar) .And. oModelPar:GetValue("DEPRBONUS") == 1
			xValCpo	:= oModelFN6:GetValue("FN6_BAIXA")
			oModelFN6:LoadValue("FN6_BAIXA", 0)
		EndIf
	EndIf

	If lAtuVal
		lRet := oModelFN6:SetValue("FN6" + cCampo ,xValCpo )	
	Else				
		lRet := oModelFN6:LoadValue("FN6" + cCampo ,xValCpo )	
		If cCampo == "_BAIXA"
			oModelFN6:LoadValue("FN6_PERCBX" , nPerBaixa )

			nQtdAtual := oModelFN6:GetValue("FN6_QTDATU") 
			nQtdBaixa := IIf(nPerBaixa > 0,(nPerBaixa/100) * nQtdAtual , 0)
			oModelFN6:LoadValue("FN6_QTDBX" , nQtdBaixa )	
		EndIf
	EndIf
	
Next nY

Return lRet

/*/{Protheus.doc} AF036AMARK

Funcao para replicar a marcação para todos os itens

@author Totvs
@since 23/04/2014
@version 12
/*/
Function AF036AMARK(oModel)
Local oModel		:= oModel:GetModel()
Local oModelFN8		:= oModel:GetModel("FN8LOTE")
Local oModelFN6		:= oModel:GetModel("FN6ATIVOS")
Local oModelFN7		:= oModel:GetModel("FN7TIPO")
Local lRet			:= .T.
Local oView			:= FWViewActive()
Local aSaveLines 	:= FWSaveRows()
Local nX			:= 0
Local nY			:= 0
Local lMarca		:= oModelFN8:GetValue("OK")

For nY := 1 to oModelFN6:Length()
	oModelFN6:GoLine( nY )
	oModelFN6:LoadValue("OK",lMarca)	
	For nX:= 1 to oModelFN7:Length()
		oModelFN7:GoLine( nX )
		oModelFN7:LoadValue("OK",lMarca)
	Next nX	
Next nY

FWRestRows(aSaveLines)

If oView != Nil .And. oView:IsActive()
	oModelFN6:GoLine( 1 )
	oView:Refresh("FN6ATIVOS")	
	oView:Refresh("FN7TIPO")	
EndIf	

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} ProcFARules

Enforce localization rules

@param		ARRAY aFARules
@return		None
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        EV01A012RU
/*/
//-----------------------------------------------------------------------
Static Function ProcFARules(aFARules AS ARRAY)
Local nX		AS NUMERIC
Local cBase		AS CHARACTER
Local cItem		AS CHARACTER
Local aProc		AS ARRAY
aProc		:= {}

For nX := 1 To Len(aFARules)
	cBase		:= aFARules[nX,01]
	cItem		:= aFARules[nX,02]

	If Empty(AScan(aProc, cBase + cItem))
		RU01RULES(cBase, cItem)
		aAdd(aProc, cBase + cItem)
	EndIf
Next nX

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} ProcFARules

Aplica um refresh na grid de tipo 
Ao mudar o registro no grid de Ativos, o sistema estava trazendo o grid 
de tipos FN7TIPO desposicionado


@param		None
@return		None
@author 	TOTVS
@since 		15/05/2021
/*/
//-----------------------------------------------------------------------
Static Function A36LRefTip()
Local oView	:= FWViewActive()

If oView != Nil .And. oView:IsActive()
	oView:Refresh("FN7TIPO")
EndIf	

Return 

/*/{Protheus.doc} ATFA036LMetrics
	(long_description)
	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function ATF036LMetrics(cEvent, nStart, cSubEvent, cSubRoutine, nQtdReg)

Local cFunBkp	:= ""
Local cFunMet	:= ""

Local cIdMetric  := ""
Local nValue := 0
Local dDateSend := CtoD("") 
Local nLapTime := 0

Default cEvent := ""
Default nStart := 0
Default cSubEvent := ""
Default cSubRoutine := Alltrim(ProcName(1))
Default nQtdReg := 0

//Só capturar metricas se a versão da lib for superior a 20210517
If __lMetric .And. !Empty(cEvent)
	//grava funname atual na variavel cFunBkp
	cFunBkp := FunName()

	If cEvent == "01"

		//Evento 001 - Metrica de tempo médio
		If cSubEvent == '001' 
			
			cFunMet := cFunMet := Iif(AllTrim(cFunBkp)=='RPC',"RPCATFA036",cFunBkp)
			SetFunName(cFunMet)
			
			//atribuicao das variaveis que serao utilizadas pelo FwCustomMetrics
			cSubRoutine := Alltrim(cSubRoutine)
			cIdMetric  := "ativo-fixo--protheus_ativofixoprotheus_baixadeativo_total_total"
			nValue := 1
			dDateSend := LastDay( Date() ) 
			nLapTime := 0

			// Metrica
			FWCustomMetrics():SetSumMetric(cSubRoutine, cIdMetric, nValue, dDateSend, nLapTime)

		EndIf
		
	EndIf

	//Restaura setfunname a partir da variavel salva cFunBkp
	SetFunName(cFunBkp)
EndIf

Return 
