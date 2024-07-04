#INCLUDE "OGA255.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"


/** {Protheus.doc} OGA255
Rotina de Romaneio de Compra utilizada para entradas de cargas onde a emissão do documento
do Romaneio é obrigatório. Esta rotina permite a atualização do saldo fisico, porem quando
uma nota fiscal acompanhar o mesmo deve atualizar tambem o saldo fiscal

@param: 	Nil
@author: 	Bruna Rocio
@since: 	13/10/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA255( cAlias, nReg, nAcao )
	Local oMBrowse		:= Nil
	Private aIniPad		:= {'' ,'','','' }
	Private nDecPeso		:= SuperGetMV("MV_OGDECPS",,0)


	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NJJ" )
	oMBrowse:SetDescription( STR0001 ) //"Romaneios"

	oMBrowse:AddLegend( "NJJ_STATUS=='0'", "RED"		, X3CboxDesc( "NJJ_STATUS", "0" ) ) //"Pendente"
	oMBrowse:AddLegend( "NJJ_STATUS=='1'", "YELLOW"	, X3CboxDesc( "NJJ_STATUS", "1" ) ) //"Completo"
	oMBrowse:AddLegend( "NJJ_STATUS=='2'", "ORANGE"	, X3CboxDesc( "NJJ_STATUS", "2" ) ) //"Atualizado"
	oMBrowse:AddLegend( "NJJ_STATUS=='3'", "GREEN"	, X3CboxDesc( "NJJ_STATUS", "3" ) ) //"Encerrado"
	oMBrowse:AddLegend( "NJJ_STATUS=='4'", "BLACK"	, X3CboxDesc( "NJJ_STATUS", "4" ) ) //"Cancelado"

	oMBrowse:SetFilterDefault( "NJJ_TIPENT == '1'") //Gerencial

	oMbrowse:DisableDetails()
	oMBrowse:Activate()

	//SetKey( VK_F11, bTeclaF11 )

Return( )


/** {Protheus.doc} MenuDef
Funcao que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Bruna Rocio
@since: 	13/10/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function MenuDef()
	Local aRotina := {}
	Local nx      := 0

	aAdd( aRotina, { STR0006	   , "PesqBrw"			, 0, 1, 0, .t. } ) //"Pesquisar"
	aAdd( aRotina, { STR0007		, "ViewDef.OGA255"	, 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0008		, "ViewDef.OGA255"	, 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0009		, "ViewDef.OGA255"	, 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0081		, "OGA250ATUC"		, 0, 4, 0, Nil } ) //"Atualizar"
	aAdd( aRotina, { STR0011		, "OGA250REA"			, 0, 4, 0, Nil } ) //"Reabrir"
	aAdd( aRotina, { STR0084		, "OGA250CAN"			, 0, 4, 0, Nil } ) //"Cancelar"
	aAdd( aRotina, { STR0013		, "OGR250"				, 0, 8, 0, Nil } ) //"Imprimir"
	aAdd( aRotina, { STR0089    , "AGRCONHECIM('NJJ')", 0, 4, 0, Nil } ) //"Conhecimento"
	aAdd( aRotina, { STR0012		, "ViewDef.OGA255"	, 0, 5, 0, Nil } ) //"Excluir"
	aAdd( aRotina, { STR0149		, "OGA250HIS"			, 0, 7, 0, Nil } ) //"Histórico"
	aAdd( aRotina, { "Registro de Entrega"	, "OGA250REG(NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM)"	   , 0, 4, 0, .F. } ) //"Registro de Entrega"
	
	If ExistBlock('OG255MNU')
		aRetM := ExecBlock('OG255MNU',.F.,.F.)
		If Type("aRetM") == 'A'
			For nx := 1 To Len(aRetM)
				Aadd(aRotina,aRetM[nx])
			Next nx 
		EndIf
	EndIf 	
Return( aRotina )


/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Bruna Rocio
@since: 	13/10/2014
@Uso: 		OGA255 - Romaneio de Compra
*/
Static Function ModelDef()
	Local oStruNJJ := FWFormStruct( 1, "NJJ" )
	Local oStruNJM := FWFormStruct( 1, "NJM" )
	Local bFldPre  := { |oFldModel, cAction, cIDField, xValue| PreFldNJJ( oFldModel, cAction, cIDField, xValue ) }
	Local oModel

	oStruNJJ:AddTrigger( "NJJ_PLACA" , "NJJ_CODMOT", { || .T. }, { | x | fTrgPlaca( x ) } )
	oStruNJJ:AddTrigger( "NJJ_TIPO"  , "NJJ_DSTIPO", { || .t. }, { || SubStr( Posicione( "SX5", 1, xFilial("SX5") + "K5" + FwFldGet( "NJJ_TIPO" ), "X5_DESCRI" ), 1, TamSX3( "NJJ_DSTIPO" )[1] ) } )
	oStruNJJ:AddTrigger( "NJJ_CODCTR", "NJJ_CODENT", { || .T. }, { | x | fTrgIniCtr( x ) } )

	oStruNJJ:SetProperty( "NJJ_CODENT", MODEL_FIELD_VALID, {| oField | OGA255TAB( oField ) } )
	oStruNJJ:SetProperty( "NJJ_LOJENT", MODEL_FIELD_VALID, {| oField | OGA255TAB( oField ) } )
	oStruNJJ:SetProperty( "NJJ_ENTENT", MODEL_FIELD_VALID, {| oField | OGA255TAB( oField ) } )
	oStruNJJ:SetProperty( "NJJ_ENTLOJ", MODEL_FIELD_VALID, {| oField | OGA255TAB( oField ) } )
	oStruNJJ:SetProperty( "NJJ_DOCSER", MODEL_FIELD_VALID, {| oField | OGA255TAB( oField ) } )
	oStruNJJ:SetProperty( "NJJ_DOCNUM", MODEL_FIELD_VALID, {| oField | OGA255TAB( oField ) } )
	oStruNJJ:SetProperty( "NJJ_DOCEMI", MODEL_FIELD_VALID, {| oField | OGA255TAB( oField ) } )
	oStruNJJ:SetProperty( "NJJ_DOCESP", MODEL_FIELD_VALID, {| oField | OGA255TAB( oField ) } )
	oStruNJJ:SetProperty( "NJJ_CHVNFE", MODEL_FIELD_VALID, {| oField | OGA255TAB( oField ) } )
	oStruNJJ:SetProperty( "NJJ_QTDFIS", MODEL_FIELD_VALID, {| oField | OGA255TAB( oField ) } )
	oStruNJJ:SetProperty( "NJJ_VLRUNI", MODEL_FIELD_VALID, {| oField | OGA255TAB( oField ) } )
	oStruNJJ:SetProperty( "NJJ_VLRTOT", MODEL_FIELD_VALID, {| oField | OGA255TAB( oField ) } )
	oStruNJJ:SetProperty( "NJJ_CODSAF", MODEL_FIELD_VALID, {| oField | OGA255TAB( oField ) } )
	oStruNJJ:SetProperty( "NJJ_CODPRO", MODEL_FIELD_VALID, {| oField | OGA255TAB( oField ) } )
	oStruNJJ:SetProperty( "NJJ_LOCAL" , MODEL_FIELD_VALID, {| oField | OGA255TAB( oField ) } )

	oStruNJJ:SetProperty( "NJJ_CODAUT", MODEL_FIELD_VALID, {| oField | fInTransp( oField ) } )

	oStruNJM:SetProperty( "NJM_CODCTR", MODEL_FIELD_VALID, {| oField | OGA330VLD(FwFldGet('NJM_CODCTR'),FwFldGet('NJJ_TIPO')).And.OGA255VCTR() } )
	oStruNJJ:SetProperty( "NJJ_TABELA", MODEL_FIELD_VALID, {|| .T. })

	oStruNJJ:SetProperty( "NJJ_DOCSER", MODEL_FIELD_WHEN , {|| .T. })
	oStruNJJ:SetProperty( "NJJ_DOCNUM", MODEL_FIELD_WHEN , {|| .T. })
	oStruNJJ:SetProperty( "NJJ_DOCESP", MODEL_FIELD_WHEN , {|| .T. })
	oStruNJJ:SetProperty( "NJJ_CHVNFE", MODEL_FIELD_WHEN , {|| .T. })
	oStruNJJ:SetProperty( "NJJ_DOCEMI", MODEL_FIELD_WHEN , {|| .T. })
	oStruNJJ:SetProperty( "NJJ_QTDFIS", MODEL_FIELD_WHEN , {|| .T. })
	oStruNJJ:SetProperty( "NJJ_VLRUNI", MODEL_FIELD_WHEN , {|| .T. })
	oStruNJJ:SetProperty( "NJJ_VLRTOT", MODEL_FIELD_WHEN , {|| .T. })

	oStruNJM:SetProperty( "NJM_DOCSER", MODEL_FIELD_WHEN , {|| .T. })
	oStruNJM:SetProperty( "NJM_DOCNUM", MODEL_FIELD_WHEN , {|| .T. })
	oStruNJM:SetProperty( "NJM_DOCESP", MODEL_FIELD_WHEN , {|| .T. })
	oStruNJM:SetProperty( "NJM_CHVNFE", MODEL_FIELD_WHEN , {|| .T. })
	oStruNJM:SetProperty( "NJM_DOCEMI", MODEL_FIELD_WHEN , {|| .T. })
	oStruNJM:SetProperty( "NJM_QTDFIS", MODEL_FIELD_WHEN , {|| .T. })
	oStruNJM:SetProperty( "NJM_VLRUNI", MODEL_FIELD_WHEN , {|| .T. })
	oStruNJM:SetProperty( "NJM_VLRTOT", MODEL_FIELD_WHEN , {|| .T. })

	oStruNJJ:SetProperty( "NJJ_TIPENT", MODEL_FIELD_INIT , {|| "1" } ) // 1=Gerencial
	oStruNJJ:SetProperty( "NJJ_TPFORM", MODEL_FIELD_INIT , {|| "2" } ) // 2=Não (form. próprio)
	oStruNJJ:SetProperty( "NJJ_STAFIS", MODEL_FIELD_INIT , {|| "3" } ) // 3=Gerencial
	oStruNJJ:SetProperty( "NJJ_STSCLA", MODEL_FIELD_INIT , {|| "1" } ) // 1=Classificado
	oStruNJJ:SetProperty( "NJJ_STATUS", MODEL_FIELD_INIT , {|| "1" } ) // 1=Completo

	oStruNJM:SetProperty( "NJM_TPFORM", MODEL_FIELD_INIT , {|| "2" } ) // 2=Não (form. próprio)
	oStruNJM:SetProperty( "NJM_STAFIS", MODEL_FIELD_INIT , {|| "3" } ) // 3=Gerencial

	oStruNJJ:SetProperty("NJJ_TIPO"  ,MODEL_FIELD_OBRIGAT,.F.)
	oStruNJJ:SetProperty("NJJ_CODENT",MODEL_FIELD_OBRIGAT,.F.)
	oStruNJJ:SetProperty("NJJ_LOJENT",MODEL_FIELD_OBRIGAT,.F.)
	oStruNJJ:SetProperty("NJJ_ENTENT",MODEL_FIELD_OBRIGAT,.F.)
	oStruNJJ:SetProperty("NJJ_ENTLOJ",MODEL_FIELD_OBRIGAT,.F.)

	oStruNJM:RemoveField( "NJM_CODROM" )

	oModel:= MPFormModel():New( "OGA255", , , {| oModel | GrvModelo( oModel ) } )

	oModel:SetVldActivate( { |oMod| fVldActivate( oMod ) } )

	oModel:AddFields( "NJJUNICO", Nil, oStruNJJ, bFldPre, { |x| PosFldNJJ( x ) } )
	oModel:AddGrid( "NJMUNICO", "NJJUNICO", oStruNJM, , { |x| PosLGrdNJM( x ) }, , { |x| PosGrdNJM( x ) } )

	oModel:SetRelation( "NJMUNICO", { { "NJM_FILIAL", "xFilial( 'NJM' )" }, { "NJM_CODROM", "NJJ_CODROM" } }, NJM->( IndexKey( 1 ) ) )

	oModel:GetModel( "NJMUNICO" ):SetOptional( .t. )

	oModel:SetDescription( STR0014 ) //"Romaneio"
	oModel:GetModel( "NJJUNICO" ):SetDescription( STR0015 ) //"Cabecalho do Romaneio"
	oModel:GetModel( "NJMUNICO" ):SetDescription( STR0017 ) //"Itens de Comercialização"

	oModel:SetActivate(   { | oModel | fIniModelo( oModel, oModel:GetOperation() ) } )
	oModel:SetDeActivate( { | oModel | fFimModelo( oModel )                        } )

Return( oModel )

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Bruna Rocio
@since: 	13/10/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function ViewDef()
	Local oStruNJJ 	:= FWFormStruct( 2, "NJJ" )
	Local oStruNJM 	:= FWFormStruct( 2, "NJM" )
	Local oModel   	:= FWLoadModel( "OGA255" )
	Local oView    	:= FWFormView():New()
	Local cFormulario	:= IIf( NJM->( NJM_TPFORM ) = "1", "S", "N" )

	oStruNJM:RemoveField( "NJM_CODROM" )

	oView:SetModel( oModel )
	oView:AddField( "VIEW_NJJ", oStruNJJ, "NJJUNICO" )
	oView:AddGrid ( "VIEW_NJM", oStruNJM, "NJMUNICO" )

	If cFormulario == "N"
		oStruNJM:SetProperty( "NJM_VLRUNI" , MVC_VIEW_CANCHANGE, .T. )
		oStruNJM:SetProperty( "NJM_VLRTOT" , MVC_VIEW_CANCHANGE, .T. )
	EndIf

	oStruNJJ:RemoveField( "NJJ_PSBASE" )
	oStruNJJ:RemoveField( "NJJ_PSLIQU" )
	oStruNJJ:RemoveField( "NJJ_PSDESC" )
	oStruNJJ:RemoveField( "NJJ_DATPS1" )
	oStruNJJ:RemoveField( "NJJ_HORPS1" )
	oStruNJJ:RemoveField( "NJJ_PESO1"  )
	oStruNJJ:RemoveField( "NJJ_MODPS1" )
	oStruNJJ:RemoveField( "NJJ_DATPS2" )
	oStruNJJ:RemoveField( "NJJ_HORPS2" )
	oStruNJJ:RemoveField( "NJJ_PESO2"  )
	oStruNJJ:RemoveField( "NJJ_MODPS2" )
	oStruNJJ:RemoveField( "NJJ_TRANSF" )
	oStruNJJ:RemoveField( "NJJ_STSCLA" )
	oStruNJJ:RemoveField( "NJJ_PSSUBT" )
	oStruNJJ:RemoveField( "NJJ_PSEXTR" )
	oStruNJJ:RemoveField( "NJJ_PESAGE" )
	oStruNJJ:RemoveField( "NJJ_STSPES" ) 
	oStruNJJ:RemoveField( "NJJ_TKTCLA" )
	oStruNJJ:RemoveField( "NJJ_TABELA" )
	oStruNJJ:RemoveField( "NJJ_FILREL" )
	oStruNJJ:RemoveField( "NJJ_ROMREL" )
	oStruNJJ:RemoveField( "NJJ_TPFORM" )
	oStruNJJ:RemoveField( "NJJ_NFPSER" )
	oStruNJJ:RemoveField( "NJJ_NFPNUM" )
	oStruNJJ:RemoveField( "NJJ_FRETE" )
	oStruNJJ:RemoveField( "NJJ_SEGURO" )
	oStruNJJ:RemoveField( "NJJ_DESPES" )
	oStruNJJ:RemoveField( "NJJ_MSGNFS" )
	oStruNJJ:RemoveField( "NJJ_TPFRET" )
	oStruNJJ:RemoveField( "NJJ_TRSERV" )
	oStruNJJ:RemoveField( "NJJ_ROMORI" )
	oStruNJJ:RemoveField( "NJJ_TES" )

	oStruNJM:RemoveField( "NJM_TPFORM" )
	oStruNJM:RemoveField( "NJM_NFPSER" )
	oStruNJM:RemoveField( "NJM_NFPNUM" )
	oStruNJM:RemoveField( "NJM_FRETE" )
	oStruNJM:RemoveField( "NJM_SEGURO" )
	oStruNJM:RemoveField( "NJM_DESPES" )
	oStruNJM:RemoveField( "NJM_MSGNFS" )
	oStruNJM:RemoveField( "NJM_TRSERV" )

	oView:AddIncrementField( "VIEW_NJM", "NJM_ITEROM" )

	oView:CreateHorizontalBox( "SUPERIOR" , 70 )
	oView:CreateHorizontalBox( "INFERIOR" , 30 )

	oView:CreateFolder( "GRADES", "INFERIOR")
	oView:AddSheet( "GRADES", "PASTA01", STR0019) //"Comercialização"

	oView:CreateHorizontalBox( "PASTA_NJM", 100, , , "GRADES", "PASTA01" )

	oView:SetOwnerView( "VIEW_NJJ", "SUPERIOR" )
	oView:SetOwnerView( "VIEW_NJM", "PASTA_NJM" )

	oView:EnableTitleView( "VIEW_NJJ" )
	oView:EnableTitleView( "VIEW_NJM" )

	//--					Adicionando Grupos na view						--//
	oStruNJJ:AddGroup( 'GRUPOA', '', '', 1 )
	oStruNJJ:AddGroup( 'GRUPOB', Chr(09), '', 2 )	
	oStruNJJ:AddGroup( 'GRUPOC', Chr(09), '', 3 )
	oStruNJJ:AddGroup( 'GRUPOD', '', '', 4 )

	//-- Atribuindo Todos os Campos ao Grupo D (campos que fica em outras abas) --//
	oStruNJJ:SetProperty( '*' , MVC_VIEW_GROUP_NUMBER, 'GRUPOD' )

	//-- Atribuindo os campos ao Grupo A--//
	oStruNJJ:SetProperty( 'NJJ_CODROM' , MVC_VIEW_GROUP_NUMBER, 'GRUPOA' )
	oStruNJJ:SetProperty( 'NJJ_TIPO' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPOA' )
	oStruNJJ:SetProperty( 'NJJ_DSTIPO' , MVC_VIEW_GROUP_NUMBER, 'GRUPOA' )
	oStruNJJ:SetProperty( 'NJJ_CODCTR' , MVC_VIEW_GROUP_NUMBER, 'GRUPOA' )
	oStruNJJ:SetProperty( 'NJJ_CODAUT' , MVC_VIEW_GROUP_NUMBER, 'GRUPOA' )

	//-- Atribuindo os campos ao Grupo B --//
	oStruNJJ:SetProperty( 'NJJ_PLACA'  , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJJ:SetProperty( 'NJJ_CODTRA' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJJ:SetProperty( 'NJJ_NOMTRA' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJJ:SetProperty( 'NJJ_CODMOT' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJJ:SetProperty( 'NJJ_NOMMOT' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJJ:SetProperty( 'NJJ_CODENT' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJJ:SetProperty( 'NJJ_LOJENT' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJJ:SetProperty( 'NJJ_NOMENT' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJJ:SetProperty( 'NJJ_NLJENT' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJJ:SetProperty( 'NJJ_ENTENT' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJJ:SetProperty( 'NJJ_ENTLOJ' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJJ:SetProperty( 'NJJ_ENTNOM' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJJ:SetProperty( 'NJJ_ENTNLJ' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )

	//-- Atribuindo os campos ao Grupo C --//
	oStruNJJ:SetProperty( 'NJJ_DOCSER' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJJ:SetProperty( 'NJJ_DOCNUM' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJJ:SetProperty( 'NJJ_DOCEMI' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJJ:SetProperty( 'NJJ_DOCESP' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJJ:SetProperty( 'NJJ_CHVNFE' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJJ:SetProperty( 'NJJ_QTDFIS' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJJ:SetProperty( 'NJJ_VLRUNI' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJJ:SetProperty( 'NJJ_VLRTOT' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJJ:SetProperty( 'NJJ_OBS' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )

	///=== Define métodos do View ===/// 
	oView:SetAfterViewActivate( { | oMod | fAftViewActiv( oMod ) } )

	oView:SetFieldAction( 'NJJ_CODAUT', { |oView| fIniAutz(oView) } )

	oView:SetCloseOnOk( {|| .t. } )

Return( oView )

/** {Protheus.doc} fAftViewActiv
Função para setar o ambiente na ativação da view, chamada no SetAfterViewActivate()

@param: 	oModel
@return:	NIL
@author: 	Marlon Richard Trettin
@since: 	26/01/2015
@Uso: 		OGA250 - Romaneio
*/
Static Function fAftViewActiv( oModel )
	Local oView			:= FwViewActive()

	//--Ajustando Qdo o Grid da NJM, Ganhar e Perder o Foco--//
	oView:GetViewObj("VIEW_NJM")[3]:obrowse:obrowse:bGotfocus:={||lFcoGrdNjm:=.t.}
	oView:GetViewObj("VIEW_NJM")[3]:obrowse:obrowse:bLostFocus:={||lFcoGrdNjm:=.f.}

Return NIL


/** {Protheus.doc} fVldActivate
Função que valida a execução de operações de Alteração ou Exclusão.

@param: 	oModel
@return:	.T. ou .F.
@author: 	Marlon Richard Trettin
@since: 	30/07/2014
@Uso: 		OGA250 - Romaneio
*/
Static Function fVldActivate( oModel )

	Local nOpc := oModel:GetOperation()

	/* --- Alteração --- */
	If nOpc == MODEL_OPERATION_UPDATE
		If NJJ->( NJJ_STATUS ) $ "3|4" //3=Confirmado; 4=Cancelado
			Help( ,, STR0021,, STR0108+NJJ->( NJJ_STATUS )+" - "+X3CboxDesc( "NJJ_STATUS", NJJ->( NJJ_STATUS ) ), 1, 0,) //"HELP"##"Operação não permitida para Romaneio com status "
			Return( .F. )
		EndIf
	EndIf

	/* --- Exclusão  --- */
	If nOpc == MODEL_OPERATION_DELETE 
		If .Not. ( NJJ->( NJJ_STATUS ) $ "0|1" ) //0=Pendente; 1=Completo
			Help( ,, STR0021,, STR0108+NJJ->( NJJ_STATUS )+" - "+X3CboxDesc( "NJJ_STATUS", NJJ->( NJJ_STATUS ) ), 1, 0,) //"HELP"##"Operação não permitida para Romaneio com status "
			Return( .F. )
		EndIf
	EndIf

Return( .T. )

/** {Protheus.doc} PosLGrdNJM


@param: 	oNJM - Gride do modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Bruna Rocio
@since: 	13/10/2014
@Uso: 		OGA255 - Romaneio
*/
Static Function PosLGrdNJM( oNJM )
	Local lRetorno	:= .t.
	Local nX      	:= 0
	Local aCposObr 	:= { "NJM_DOCNUM", "NJM_DOCESP", "NJM_DOCEMI", "NJM_QTDFIS", "NJM_VLRUNI", "NJM_VLRTOT" }
	Local oNJJ			:= oNJM:GetModel():GetModel( "NJJUNICO" )

	If oNJJ:GetValue( "NJJ_STATUS" ) == "1" // 1=Completo
		If .Not. oNJM:IsDeleted() .And. oNJM:GetValue( "NJM_TPFORM" ) == "2" // 2=Não (form. próprio)
			For nX := 1 to Len( aCposObr )
				If Empty( oNJM:GetValue( aCposObr[ nX ] ) )
					Help(, , "Ajuda", , STR0022, 1, 0 ) //"Em caso de formulario de terceiro( nao proprio ), favor prencher todos os campos referentes a este."
					lRetorno := .f.
					Exit
				EndIf
			Next nX
		EndIf
	EndIf

Return( lRetorno )


/** {Protheus.doc} PosGrdNJM


@param: 	oNJM - Gride do modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Bruna Rocio
@since: 	13/10/2014
@Uso: 		OGA255 - Romaneio
*/
Static Function PosGrdNJM( oNJM )
	Local lRetorno	:= .t.
	Local oNJJ			:= oNJM:GetModel():GetModel( "NJJUNICO" )
	Local nLinha		:= 0
	Local nX      	:= 0
	Local nPerDiv 	:= 0
	Local nSomaNJM	:= 0

	If oNJJ:GetValue( "NJJ_STATUS" ) == "1"

		If oNJM:Length() > 0

			nLinha := oNJM:GetLine()
			For nX := 1 to oNJM:Length()
				oNJM:GoLine( nX )
				If .Not. oNJM:IsDeleted()
					oNJM:SetValue( "NJM_QTDFCO", Round( ( oNJJ:GetValue( "NJJ_QTDFIS" ) * ( oNJM:GetValue( "NJM_PERDIV" ) / 100 ) ), nDecPeso ) )														
					nSomaNJM += oNJM:GetValue( "NJM_QTDFCO" )
					nPerDiv += oNJM:GetValue( "NJM_PERDIV" )
				EndIf
			Next nX

			// Se deu alguma diferença no total por conta de arredondamento
			If nSomaNJM <> oNJJ:GetValue( "NJJ_QTDFIS" )
				oNJM:SetValue( "NJM_QTDFCO", oNJM:GetValue( "NJM_QTDFCO" ) + ( oNJJ:GetValue( "NJJ_QTDFIS" ) - nSomaNJM ) )	// Ajusta a diferença no último item do romaneio													
			EndIf

			oNJM:GoLine( nLinha )

			If nPerDiv <> 100
				Help(, , STR0062, , STR0028, 1, 0 ) //"Ajuda"###"O percentual de rateio por Entidade/Contrato deve ser de 100%."
				lRetorno := .F.
			EndIf
		Endif

	EndIf

Return( lRetorno )

/** {Protheus.doc} PreFldNJJ
Pre-edição do structure NJJ.

@param: 	oFieldModel - Field do modelo de dados
@param: 	cAction - "SETVALUE" / "CANSETVALUE"
@param: 	cIDField - identificador do campo que está sendo atualizado
@param: 	xValue -  valor que está sendo atribuido

@return:	lRetorno - verdadeiro ou falso
@author: 	Marlon Richard Trettin
@since: 	06/03/2015
@Uso: 		OGA255 - Romaneio Gerencial
*/
Static Function PreFldNJJ(oNJJ, cAction, cIDField, xValue)
	Local xValueAnt	

	If cAction == "SETVALUE"
		xValueAnt := oNJJ:GetValue( cIDField )	
		If oNJJ:GetValue( "NJJ_STATUS" ) $ "2|3"
			If AllTrim(cIDField) $ "NJJ_QTDFIS,NJJ_VLRUNI,NJJ_VLRTOT"
				If xValue <> xValueAnt
					Help(, , STR0021, , STR0131, 1, 0 ) //"Não é permitido alterar este campo em Romaneio com Status -Atualizado- ou -Confirmado-."
					Return( .F. )
				EndIf
			EndIf
		EndIf

	EndIf

Return( .T. )

/** {Protheus.doc} PosFldNJJ


@param: 	oNJJ - Enchoice do modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Bruna Rocio
@since: 	13/10/2014
@Uso: 		OGA255 - Romaneio
*/
Static Function PosFldNJJ( oNJJ )
	Local lRetorno  := .t.
	Local nX        := 0
	Local aCposObr := { "NJJ_CODSAF", "NJJ_QTDFIS" }

	If oNJJ:GetValue( "NJJ_STATUS" ) = "2"
		For nX := 1 to Len( aCposObr )
			If Empty( oNJJ:GetValue( aCposObr[ nX ] ) )
				Help(, , STR0021, , STR0029, 1, 0 ) //"Ajuda"###"Para fechamento do romaneio os campos de Safra,Peso Subtotal são obrigatórios."
				lRetorno := .f.
				Exit
			EndIf
		Next nX
	EndIf

Return( lRetorno )


/** {Protheus.doc} GrvModelo
Funcao para gravar dados adicionais e o modelo de dados

@param:     oModel - Modelo de Dados
@return:    .t.
@author:    Bruna Rocio
@since:     13/10/2014
@Uso:       OGA255 – Romaneio
@Ponto de Entrada: Bruna Rocio
@Data: 25/08/2014
*/
Static Function GrvModelo( oModel )
	Local aAreaAtu    := GetArea()
	Local nOperation  := oModel:GetOperation()
	Local oModelNJJ   :=oModel:GetModel( "NJJUNICO" )	

	FWFormCommit( oModel )

	If nOperation == MODEL_OPERATION_INSERT
		AGRGRAVAHIS(,,,,{"NJJ",xFilial("NJJ")+oModelNJJ:Getvalue('NJJ_CODROM'),"3",STR0008})// Incluir
	Endif

	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE 

		// Alimenta os campos de quantidade do romaneio
		If RecLock('NJJ', .f.)
			NJJ->( NJJ_PESO1 )  := NJJ->( NJJ_QTDFIS )
			NJJ->( NJJ_PSSUBT ) := NJJ->( NJJ_QTDFIS )
			NJJ->( NJJ_PSBASE ) := NJJ->( NJJ_QTDFIS )
			NJJ->( NJJ_PSLIQU ) := NJJ->( NJJ_QTDFIS )
			NJJ->( NJJ_DATPS1 ) := dDataBase
			NJJ->( NJJ_DATPS2 ) := dDataBase

			msUnlock()
		EndIf

	EndIf

	RestArea( aAreaAtu )
Return( .T. )


/** {Protheus.doc} fTrgPlaca
Gatilho no campo Placa que busca o código do motorista

@param: 	oParModel - modelo de dados
@return:	cCodMot
@author: 	Marlon Richard Trettin
@since: 	25/09/14
@Uso: 		OGA250
*/
Static Function fTrgPlaca( oParModel )
	Local oModel		:= oParModel:GetModel()
	Local oNJJ			:= oModel:GetModel( "NJJUNICO" )
	Local oView		:= FwViewActive()
	Local cPlaca		:= oNJJ:GetValue( "NJJ_PLACA" )
	Local cCodMot		:= oNJJ:GetValue( "NJJ_CODMOT" )

	If !Empty( cPlaca )

		dbSelectArea( "DA3" ) // Cadastro de veículos
		dbSetOrder( 1 )
		If dbSeek( xFilial( "DA3" ) + cPlaca )

			cCodMot := DA3->( DA3_MOTORI )

		EndIf

		oNJJ:SetValue( "NJJ_CODMOT", cCodMot )
		oView:Refresh()

	EndIf

Return( cCodMot )


/** {Protheus.doc} OGA255VCTR


@param: 	Nil
@return:	Nil
@author: 	Bruna Rocio
@since: 	13/10/2014
@Uso: 		OGA255 - Romaneio
*/
Function OGA255VCTR( pcOrigem, pcCodCtr )
	Local aAreaAtu 	:= GetArea()
	Local aAreaNJR 	:= NJR->( GetArea() )
	Local aAreaNNY 	:= NNY->( GetArea() )
	Local lRetorno 	:= .t.
	Local lCadenciaGer  := .F.
	Local oModel		:= FwModelActive()

	Local oNJM
	Local oNJJ
	Local cSafra		:= ""	
	Local cCodCtr		:= ""

	Default pcOrigem := "VIEW"

	If oModel = nil
		oModel := FwLoadMOdel('OGA255')
	EndIf 

	oNJM := oModel:GetModel( "NJMUNICO" )
	oNJJ := oModel:GetModel( "NJJUNICO" )

	If pcOrigem == "VIEW"
		cSafra		:= oNJJ:GetValue( "NJJ_CODSAF" )
		cCodCtr	:= oNJM:GetValue( "NJM_CODCTR" )
	Else
		cSafra	:= NJJ->( NJJ_CODSAF )
		cCodCtr	:= pcCodCtr
	EndIf

	If .Not. Empty( cCodCtr )

		dbSelectArea( "NJR" )
		dbSetOrder( 1 )
		If .Not. dbSeek( FWxFilial( "NJR" ) + cCodCtr )
			Help(, , STR0021, , STR0030, 1, 0 ) //"Ajuda"###"Não existe o -Contrato- informado."
			lRetorno := .f.
		Else
			If NJR->( NJR_CODSAF ) <> cSafra
				Help(, , STR0021, , STR0033, 1, 0 ) //"Ajuda"###"O contrato esta com -Safra- diferente do romaneio."
				lRetorno := .f.					
			EndIf				
		EndIf

		dbSelectArea( "NNY" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "NNY" ) + cCodCtr)
		While .Not. NNY->( Eof() ) .And. NNY->( NNY_FILIAL ) + NNY->( NNY_CODCTR ) == xFilial( "NNY" ) + cCodCtr
			If NNY->( NNY_TIPENT ) == '1' //Gerencial
				lCadenciaGer := .T.
			Endif
			NNY->( dbSkip() )
		EndDo
		If .Not. lCadenciaGer
			Help(, , STR0021, , STR0083, 1, 0 ) //"Ajuda"###"Contrato informado nao possui cadência gerencial."
			lRetorno := .f.
		Endif	
	Endif

	RestArea( aAreaNNY )
	RestArea( aAreaNJR )
	RestArea( aAreaAtu )
Return( lRetorno )


/** {Protheus.doc} OGA280TAB
Função para gatilho de preenchimento de campos da NJM com o correspondente da NJJ

@param: 	Nil
@author: 	Ana Laura Olegini
@since: 	12/08/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function OGA255TAB ( oField )

	Local lRetorno 	:= .T.
	Local oModel		:= FwModelActive()
	Local oNJM			:= oModel:GetModel( "NJMUNICO" )
	Local oNJJ			:= oModel:GetModel( "NJJUNICO" )

	oNJM:GoLine( 1 )

	If ! Empty(oNJJ:GetValue( "NJJ_CODENT" ))  
		oNJM:SetValue( "NJM_CODENT", oNJJ:GetValue( "NJJ_CODENT" ) )
	EndIf

	If ! Empty(oNJJ:GetValue( "NJJ_LOJENT" ))  
		oNJM:SetValue( "NJM_LOJENT", oNJJ:GetValue( "NJJ_LOJENT" ) )
	EndIf

	If Empty(oNJJ:GetValue( "NJJ_ENTENT" ))  
		oNJJ:SetValue( "NJJ_ENTENT", oNJJ:GetValue( "NJJ_CODENT" ) )
	EndIf

	If Empty(oNJJ:GetValue( "NJJ_ENTLOJ" ))
		oNJJ:SetValue( "NJJ_ENTLOJ", oNJJ:GetValue( "NJJ_LOJENT" ) )
	EndIf

	If oNJM:GetValue( "NJM_PERDIV" ) == 0
		oNJM:SetValue( "NJM_PERDIV", 100 )
	EndIf

	If ! Empty(oNJJ:GetValue( "NJJ_CODSAF" ))
		oNJM:SetValue( "NJM_CODSAF", oNJJ:GetValue( "NJJ_CODSAF" ) )
	EndIf

	If ! Empty(oNJJ:GetValue( "NJJ_CODPRO" ))
		oNJM:SetValue( "NJM_CODPRO", oNJJ:GetValue( "NJJ_CODPRO" ) )
	EndIf

	If ! Empty(oNJJ:GetValue( "NJJ_LOCAL" ))
		If ExistCpo('NNR', oNJJ:GetValue( "NJJ_LOCAL" ) )
			oNJM:SetValue( "NJM_LOCAL", oNJJ:GetValue( "NJJ_LOCAL" ) )
		Else
			Return( .F. )
		EndIf
	EndIf

	If ! Empty(oNJJ:GetValue( "NJJ_DOCSER" ))
		oNJM:SetValue( "NJM_DOCSER", oNJJ:GetValue( "NJJ_DOCSER" ) )
	EndIf
	If ! Empty(oNJJ:GetValue( "NJJ_DOCNUM" ))
		oNJM:SetValue( "NJM_DOCNUM", oNJJ:GetValue( "NJJ_DOCNUM" ) )
	EndIf
	If ! Empty(oNJJ:GetValue( "NJJ_DOCEMI" ))
		oNJM:SetValue( "NJM_DOCEMI", oNJJ:GetValue( "NJJ_DOCEMI" ) )
	EndIf
	If ! Empty(oNJJ:GetValue( "NJJ_DOCESP" ))
		oNJM:SetValue( "NJM_DOCESP", oNJJ:GetValue( "NJJ_DOCESP" ) )
	EndIf
	If ! Empty(oNJJ:GetValue( "NJJ_CHVNFE" ))
		oNJM:SetValue( "NJM_CHVNFE", oNJJ:GetValue( "NJJ_CHVNFE" ) )
	EndIf
	If ! Empty(oNJJ:GetValue( "NJJ_QTDFIS" ))
		oNJM:SetValue( "NJM_QTDFIS", oNJJ:GetValue( "NJJ_QTDFIS" ) )
	EndIf
	If ! Empty(oNJJ:GetValue( "NJJ_VLRUNI" ))
		oNJM:SetValue( "NJM_VLRUNI", oNJJ:GetValue( "NJJ_VLRUNI" ) )
	EndIf
	If ! Empty(oNJJ:GetValue( "NJJ_VLRTOT" ))
		oNJM:SetValue( "NJM_VLRTOT", oNJJ:GetValue( "NJJ_VLRTOT" ) )
	EndIf

Return( lRetorno )

/** {Protheus.doc} fIniAutz
Inicialização do campo NJM_CODAUT no grid com 
os dados do campo NJJ_CODAUT

@param: 	oNJM - model ativo
@return:	NJM_CODAUT Atualizado na view;
@author: 	Gilson Venturi
@since: 	13/08/2015
@Uso: 		OGA255 - Romaneio
*/
Static Function fIniAutz( oView )
	Local oNJM		:= oView:GetModel():GetModel( "NJMUNICO" )

	oNJM:LoadValue('NJM_CODAUT', FWFLDGET("NJJ_CODAUT") )

	oView:Refresh()

Return( nil )

/** {Protheus.doc} fInTransp
Função para atualizar transportadora de acordo com autorizacao informada.

@param: 	Nil
@author: 	Gilson Venturi
@since: 	13/08/2015
@Uso: 		OGA255
*/
Static Function fInTransp ( oField )

	Local aAreaNJP	:= NJP->( GetArea() )
	Local oModel		:= FwModelActive()
	Local oNJJ 		:= oModel:GetModel( "NJJUNICO" )
	Local cCodCtr 	:= oNJJ:GetValue( "NJJ_CODCTR" )
	Local cCodAUT 	:= oNJJ:GetValue( "NJJ_CODAUT" )

	If .Not. Empty( cCodCtr ) .And. .Not. Empty( cCodAut ) 

		dbSelectArea( "NJP" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "NJP" ) + cCodCtr + cCodAut )
			oNJJ:SetValue( "NJJ_CODTRA", NJP->( NJP_CODTRA ) )
		Endif
	Endif

	RestArea( aAreaNJP )
Return( .T. )

/** {Protheus.doc} fTrgIniCtr
Função para atualizar de forma automática alguns campos do romaneio com dados do contrato.

@param: 	Nil
@author: 	Gilson Venturi
@since: 	13/08/2015
@Uso: 		OGA250
*/
Static Function fTrgIniCtr ( oParModel )
	Local aAreaNJR	:= NJR->( GetArea() )
	Local oModel		:= oParModel:GetModel()
	Local oNJJ 		:= oModel:GetModel( "NJJUNICO" )
	Local oNJM 		:= oModel:GetModel( "NJMUNICO" )
	Local cCodCtr		:= oNJJ:GetValue( "NJJ_CODCTR" )
	Local cCodEnt		:= space( TAMSX3("NJR_CODENT")[1] )
	Local nLinha 		:= oNJM:GetLine()

	If .Not. Empty( cCodCtr )
		dbSelectArea( "NJR" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "NJR" ) + cCodCtr )

			oNJJ:SetValue( "NJJ_CODENT", NJR->( NJR_CODENT ) )
			oNJJ:SetValue( "NJJ_LOJENT", NJR->( NJR_LOJENT ) )
			oNJJ:SetValue( "NJJ_CODSAF", NJR->( NJR_CODSAF ) )			
			oNJJ:SetValue( "NJJ_CODPRO", NJR->( NJR_CODPRO ) )

			oNJM:GoLine(1)
			oNJM:SetValue( "NJM_CODCTR", oNJJ:GetValue( "NJJ_CODCTR" ) )
			If NJM->(ColumnPos("NJM_GENMOD")) > 0 
				oNJM:SetValue( "NJM_GENMOD", Posicione("NJR",1,FwxFilial("NJR")+ oNJJ:GetValue( "NJJ_CODCTR" ) ) )
			EndIf
			oNJM:GoLine(nLinha)

			cCodEnt := NJR->( NJR_CODENT )

		Endif
	Endif

	RestArea( aAreaNJR )
Return( cCodEnt )
/**{Protheus.doc}
Rotina que Mostra o Saldo do Produto, pode ser utilizada tanto
no cabeçalho do romaneio qto nos itens do romaneio;

@param oVIEW
@return Consulta de Saldos
@author Emerson Coelho
@since 09/092015
@version 1.0
/*/

Static Function fShowSaldo( )

	Local oView			:= FwViewActive()
	Local oModel        := FWModelActive()
	Local oModeLNJJ		:= oModel:GetModel("NJJUNICO")
	Local oModeLNJM		:= oModel:GetModel("NJMUNICO")
	Local cProduto		:= Criavar('B1_COD', .F. )
	Local nHdlCodPro	:= oView:GetViewObj("VIEW_NJJ")[3]:GetFWEditCTRL("NJJ_CODPRO"):OCtrl:OGet:HWND 	//Get o Handle do NJJ_CODPRO

	Local lConsultar	:=.t.
	Local nObjHasFoc	:= Getfocus()
	Local nPJMCodPro 	:= gdFieldPos('NJM_CODPRO', oView:GetViewObj("VIEW_NJM")[3]:obrowse:Aheader ) 	//Encontra a coluna onde esta o NJM_CODPRO. no Grid
	Local nLinNJM 		:= oModeLNJM:GetLine()															//Linha no Momento do click   do F4 Qdo no Grid
	Local nColNJM		:= oView:GetViewObj("VIEW_NJM")[3]:obrowse:obrowse:ColPos						//Coluna no Momento do click  do F4, Qdo no Grid

	IF nObjHasFoc == nHdlCodPro
		cProduto	:= oModelNJJ:GetValue("NJJ_CODPRO")
	ElseIF ( Type("lFcoGrdNjm") <> "U"  .and. lFcoGrdNjm )		//Indica que o Grid esta Com o Foco.
		IF nColNJM == nPJMCodPro		// Se a Coluna em q o Foco se encontra for igual a Coluna do NJM_CODPRO no Grid
			cProduto	:= cProduto	:= oModelNJM:GetValue("NJM_CODPRO",nLinNJM)
		Else
			lConsultar := .f.
		EndIF
	Else
		lConsultar := .f.
	EndIF

	IF lConsultar
		DbSelectArea('SB1')
		SB1->( DbSetOrder(1) )
		IF SB1->(DbSeek(Fwxfilial('SB1') + cProduto ))
			MaViewSB2( cProduto )
		Else
			Help( ,, STR0021,,STR0174 + cProduto, 1, 0,) //"HELP"##"'Produto não Cadastrado'"
		EndIF
	Else
		Help( ,, STR0021,,STR0175, 1, 0,) //"HELP"##"Para utilizar a consulta poicione o cursor em um campo de codigo do produto"
	EndIF

Return ( nil )


/** {Protheus.doc} 
Função que Inicializa / Activate o modelo de dados

@param: 	oModel - Modelo de dados
@param: 	nOperation - Opcao escolhida pelo usuario no menu (incluir/alterar/excluir)
@return:	lRetorno - verdadeiro ou falso
@author: 	E Coelho
@since: 	10/09/2015
@Uso: 		AgroIndustria
*/
Static Function finimodelo( oModel , nOperation )

	SetKey( VK_F4, { || fShowSaldo() } ) 		// Setanto F4 para Mosrar,Consulta de Saldos

Return( .t. )

/** {Protheus.doc} 7 ffimModelo
Função executada no Deactivate do modelo de dados

@param: 	oModel - Modelo de dados
@param: 	nOperation - Opcao escolhida pelo usuario no menu (incluir/alterar/excluir)
@return:	lRetorno - verdadeiro ou falso
@author: 	E Coelho
@since: 	10/09/2015
@Uso: 		AgroIndustria
*/
Static Function fFimModelo( oModel )

	SetKey (VK_F4, nil)

Return( .t. )
