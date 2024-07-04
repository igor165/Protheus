#INCLUDE "Oga430F.ch"
#include "Totvs.ch"
#include "Protheus.ch"
#include "fwMbrowse.ch"
#include "fWmvcDef.ch"

#define COL_COUNT	21
#define COL_MARK 	1
#define COL_ITEMFX	2
#define COL_CODROM	3
#define COL_ITEROM	4
#define COL_QTDFIS	5
#define COL_QTDFCO	6
#define COL_QTDENT	7
#define COL_SLDENT	8
#define COL_QTDMRK	9
#define COL_TIPMOV	10
#define COL_VAZIO	11
#define COL_VRENT	12		//Vr. total da Entrga (D1_TOTAL - DEVOLUÇÃO)
#define COL_VRIMP	13		//Vr.Imposto da NF (<< Senar, Fethab(MT), Facs (MT),FUNRURAL>,FUNDERSUL (MS) >>)]
#define COL_VRFRE	14   	//Vr. do Frete
#define COL_VRSEG	15		//Vr. do Seguro
#define COL_VRDACES 16		//Vr. da Desp.Acessoria
#define COL_SERIE	17		//Serie  Doc fiscal
#define COL_DOC		18		//Docto Fiscal
#define COL_FORMUL	19		//Formul Doc fiscal
#define COL_RECNO	20		//Recno do Item da Nota Fiscal
#define COL_TPCLAS 	21		//Recno do Item da Nota Fiscal
#define NKATOTAL	'3'		// NKA_TPVLR == 3 Indica que é o Total


//--<< Vars Utilizadas composição de Preços >>--
Static XaGrvNKA	:= {}
//--<<--------------------------------------->>--

/*Rotina para cadastro de Fixações de Preço
@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	04/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA430F()
	Local oMBrowse	

	oMBrowse	:= FWMBrowse():New()
	oMBrowse:SetAlias( "NN8" )
	oMBrowse:SetDescription( STR0001 ) //"Fixações"
	oMBrowse:SetMenuDef( "OGA430F" )
	oMBrowse:AddLegend( "NN8_STATUS=='0'", "WHITE"	, X3CboxDesc( "NN8_STATUS", "0" ) ) //Prevista
	oMBrowse:AddLegend( "NN8_STATUS=='1'", "RED"	, X3CboxDesc( "NN8_STATUS", "1" ) ) //Aberta
	oMBrowse:AddLegend( "NN8_STATUS=='2'", "YELLOW"	, X3CboxDesc( "NN8_STATUS", "2" ) ) //Parcial
	oMBrowse:AddLegend( "NN8_STATUS=='3'", "GREEN"	, X3CboxDesc( "NN8_STATUS", "3" ) ) //Fechada
	oMBrowse:AddLegend( "NN8_STATUS=='4'", "PINK"	, X3CboxDesc( "NN8_STATUS", "4" ) ) //Contrato Cancelado
	oMBrowse:Activate()
Return()

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Equipe Agroindustria
@since: 	04/11/2014
@Uso: 		OGA430F - Fixações
*/
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0002, 'PesqBrw'         , 0, 1, 0, .T. } ) 		//'Pesquisar'
	aAdd( aRotina, { STR0003, 'ViewDef.OGA430F', 0, 2, 0, Nil } ) 		//'Visualizar'
	aAdd( aRotina, { STR0004, 'ViewDef.OGA430F', 0, 3, 0, Nil } ) 		//'Incluir'
	If cPaisLoc <> "PAR" .and. cPaisLoc <> "ARG" 
		aAdd( aRotina, { STR0005, 'ViewDef.OGA430F', 0, 4, 0, Nil } ) 		//'Alterar'
	EndIf
	aAdd( aRotina, { STR0006, 'ViewDef.OGA430F', 0, 5, 0, Nil } ) 		//'Excluir'
	aAdd( aRotina, { STR0007, 'ViewDef.OGA430F', 0, 8, 0, Nil } ) 		//'Imprimir'
	aAdd( aRotina, { STR0043, 'OGR344(NN8->NN8_CODCTR, NN8->NN8_ITEMFX)', 0, 8, 0, Nil } ) 	//"Imprimir Word"
	aAdd( aRotina, { STR0044, 'staticcall(OGA430F, OGA430FVINC,	2)'	, 0, 9, 0, Nil } ) 			//"Desvincula Doc"
	aAdd( aRotina, { STR0045, 'staticcall(OGA430F, OGA430FVINC,	1)'	, 0, 9, 0, Nil } ) 			//"Vincula Doc"
	aAdd( aRotina, { "Histórico"    , "OGA430FHIS"       	, 0, 7, 0, Nil } ) //"Histórico"      

Return aRotina

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Equipe Agroindustria
@since: 	04/11/2014
@Uso: 		OGA430F - Fixações
*/
Static Function ModelDef()
	Local oStruNN8 	 := FWFormStruct( 1, "NN8" )
	Local cCodCtr	 := NJR->( NJR_CODCTR )
	Local nMoeda 	 := NJR->( NJR_MOEDA )
	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	Local oModel 	:= MPFormModel():New( "OGA430F" ,  /*bPre*/, /*bPost*/{| oMod | PosModelo( oMod ) }, {| oModel | OG430GRVMD( oModel ) } , /*bCancel*/  )	

	/*/
	!-------------------------------------------------------!
	! Devido a Termos Un. medida do Produto e Um. de Preço;	!
	! Ajusto os titulos de Qtds. para Conter a Un de medida	!
	! do produto. E os Vlrs. para conter a Um. de Preço		!
	! A alteração dos tits. devem ser feitas no modeldef		!
	!  	ATENCAO: DEVE-SE ALTERAR A DESCRICAO NO MODEL TAMBEM	! 
	!	PARA FUNCIONAR OS FILTROS DO GRID 						!
	!-------------------------------------------------------!
	/*/
	oStruNN8:SetProperty( 'NN8_QTDFIX' , MODEL_FIELD_TITULO, "Qt.Fix/" + ALLTRIM(NJR->NJR_UM1PRO) ) 	//#Qt.Fix/
	oStruNN8:SetProperty( 'NN8_VLRUNI' , MODEL_FIELD_TITULO, "Vlr.Un/" + ALLTRIM(NJR->NJR_UMPRC) ) 		//#Vlr.Un/
	oStruNN8:SetProperty( 'NN8_VALUNI' , MODEL_FIELD_TITULO, "Val.Un/" + ALLTRIM(NJR->NJR_UMPRC) ) 		//#Val.Un/
	/*/ -- o Vr. total n. precisa mostrar que é em Sacos ---//
	oStruNN8:SetProperty( 'NN8_VLRTOT' , MVC_VIEW_TITULO, "Vlr.Total/" + ALLTRIM(NJR->NJR_UMPRC) ) 	//#Vlr.Total/
	oStruNN8:SetProperty( 'NN8_VALTOT' , MVC_VIEW_TITULO, "Val.Total/" + ALLTRIM(NJR->NJR_UMPRC) ) 	//#Qt.Fix/
	/*/
	oStruNN8:SetProperty( 'NN8_VLRLIQ' , MODEL_FIELD_TITULO, "Vlr.Liq/" + ALLTRIM(NJR->NJR_UMPRC) ) 		//#Vlr.Liq/
	oStruNN8:SetProperty( 'NN8_VALLIQ' , MODEL_FIELD_TITULO, "Val.Liq/" + ALLTRIM(NJR->NJR_UMPRC) )			//#Val.Liq/
	//----------------------------------------------------------------------------------------------------------------------

	// Adding Gatilhos
	oStruNN8:AddTrigger( "NN8_MOEDA", 	"NN8_VLRLIQ"          , {|| .T. }  , {|| fAtuVrsLiq()}  )	// Recalc. Vrs. Liquidos 
	oStruNN8:AddTrigger( "NN8_QTDFIX", 	"NN8_VLRLIQ"          , {|| .T. }  , {|| fAtuVrsLiq()}  )	// Recalc. Vrs. Liquidos
	oStruNN8:AddTrigger( "NN8_VLRUNI", 	"NN8_VLRLIQ"          , {|| .T. }  , {|| fAtuVrsLiq()}  )	// Recalc. Vrs. Liquidos	
	oStruNN8:AddTrigger( "NN8_TXMOED", 	"NN8_VLRLIQ"          , {|| .T. }  , {|| fAtuVrsLiq()}  )	// Recalc. Vrs. Liquidos

	oModel:AddFields( "NN8UNICO", Nil, oStruNN8 )
	oModel:SetDescription( STR0001 ) //"Fixações"
	oModel:GetModel( "NN8UNICO" ):SetDescription( STR0009 ) //"Dados das Fixações"

	oStruNN8:SetProperty( "NN8_CODCTR" , MODEL_FIELD_INIT , {| x | x := cCodCtr }  )
	oStruNN8:SetProperty( "NN8_ITEMFX" , MODEL_FIELD_INIT , {| x | x := fNextItem( oModel ) } )
	oStruNN8:SetProperty( "NN8_MOEDA"  , MODEL_FIELD_INIT , {| x | x := nMoeda }  )
	oStruNN8:SetProperty( "NN8_QTDFIX" , MODEL_FIELD_INIT , {| x | x := fSldAFixar( oModel ) } )

	If cPaisLoc == "PAR" .Or. cPaisLoc == "ARG"   
		oStruNN8:SetProperty( "NN8_ITORIG", MODEL_FIELD_INIT , {| x | x := NN8->(NN8_ITEMFX) }  )
	Else
		If !Empty(NN8->NN8_DATREF) 
			oStruNN8:SetProperty( "NN8_DATREF", MODEL_FIELD_INIT , {| x | x := NN8->(NN8_DATREF) }  )
		EndIF
	EndIf

	oStruNN8:SetProperty( "NN8_DATINI" 	, MODEL_FIELD_VALID	, {| oField | ValNN8DATINI( oField ) } )
	oStruNN8:SetProperty( "NN8_QTDFIX" 	, MODEL_FIELD_VALID	, {| oField | ValValores( oField,'NN8_QTDFIX' ) } )
	/*/	
	oStruNN8:SetProperty( "NN8_TXMOED" 	, MODEL_FIELD_VALID	, {| oField | ValValores( oField,'NN8_TXMOED' ) } )
	oStruNN8:SetProperty( "NN8_VLRUNI" 	, MODEL_FIELD_VALID	, {| oField | ValValores( oField,'NN8_VLRUNI' ) } )
	/*/
	oModel:SetVldActivate( {|oModel| VldActivMD( oModel,cCodCtr ) } )
	oModel:SetActivate(    {|oModel|   ActiveMD( oModel ) }  )

Return oModel


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Equipe Agroindustria
@since: 	04/11/2014
@Uso: 		OGA430F
*/
Static Function ViewDef()
	Local oStruNN8 	:= FWFormStruct( 2, "NN8" )
	Local oModel   	:= FWLoadModel( "OGA430F" )
	Local oView    	:= FWFormView():New()
	Local nOperation	:= oModel:GetOperation()
	Local cTipFix		:= NJR->( NJR_TIPFIX ) //1=Fixo; 2=A Fixar

	oView:SetModel( oModel )
	oView:AddField( "VIEW_NN8", oStruNN8, "NN8UNICO" )
	oView:CreateHorizontalBox( "UM"  , 100 )
	oView:SetOwnerView( "VIEW_NN8", "UM"   )
	oView:EnableTitleView( "VIEW_NN8" )
	oView:SetCloseOnOk( {||.t.} )

	If nOperation == MODEL_OPERATION_UPDATE
		oStruNN8:SetProperty( "NN8_TIPOFX", MVC_VIEW_CANCHANGE, .F. )
	EndIf

	If cTipFix == '1' .and. cPaisLoc <> "PAR" .and. cPaisLoc <> "ARG" // Se tipo de fixação = Fixa
		oStruNN8:SetProperty( "NN8_TIPOFX", MVC_VIEW_CANCHANGE, .F. )
	//	oStruNN8:SetProperty( "NN8_QTDFIX", MVC_VIEW_CANCHANGE, .F. )
	EndIf

	/* Removendo cpos que não quero que aparecam na view Porem devem estar no modeldef.*/
	oStruNN8:RemoveField("NN8_FREFIN")
	oStruNN8:RemoveField("NN8_SEGFIN")
	oStruNN8:RemoveField("NN8_DSPFIN")
	oStruNN8:RemoveField("NN8_QTDFIN")
	oStruNN8:RemoveField("NN8_VLRFIN")
	/****************************************************/
	/*/
	!-------------------------------------------------------!
	! Devido a Termos Un. medida do Produto e Um. de Preço;	!
	! Ajusto os titulos de Qtds. para Conter a Un de medida	!
	! do produto. E os Vlrs. para conter a Um. de Preço		!
	! A alteração dos tits. devem ser feitas no modeldef		!
	!  	ATENCAO: DEVE-SE ALTERAR A DESCRICAO NO MODEL TAMBEM	! 
	!	PARA FUNCIONAR OS FILTROS DO GRID 						!
	!-------------------------------------------------------!
	/*/
	oStruNN8:SetProperty( 'NN8_QTDFIX' , MVC_VIEW_TITULO, STR0046 + ALLTRIM(NJR->NJR_UM1PRO) ) 		//#Qt.Fix/
	oStruNN8:SetProperty( 'NN8_VLRUNI' , MVC_VIEW_TITULO, STR0047 + ALLTRIM(NJR->NJR_UMPRC) ) 		//#Vlr.Un/
	oStruNN8:SetProperty( 'NN8_VALUNI' , MVC_VIEW_TITULO, STR0048 + ALLTRIM(NJR->NJR_UMPRC) ) 		//#Val.Un/
	/*/ -- o Vr. total n. precisa mostrar que é em Sacos ---//
	oStruNN8:SetProperty( 'NN8_VLRTOT' , MVC_VIEW_TITULO, "Vlr.Total/" + ALLTRIM(NJR->NJR_UMPRC) ) 	//#Vlr.Total/
	oStruNN8:SetProperty( 'NN8_VALTOT' , MVC_VIEW_TITULO, "Val.Total/" + ALLTRIM(NJR->NJR_UMPRC) ) 	//#Qt.Fix/
	/*/
	oStruNN8:SetProperty( 'NN8_VLRLIQ' , MVC_VIEW_TITULO, STR0049 + ALLTRIM(NJR->NJR_UMPRC) ) 		//#Vlr.Liq/
	oStruNN8:SetProperty( 'NN8_VALLIQ' , MVC_VIEW_TITULO, STR0050 + ALLTRIM(NJR->NJR_UMPRC) )		//#Val.Liq/
	//-------------------------------------------------------	

	//--					Adicionando Grupos na view						--//
	oStruNN8:AddGroup( 'GRUPOA', ''/*'Dados da Fixação'*/	, '', 1 )
	oStruNN8:AddGroup( 'GRUPOB', STR0051					, '', 2 )	//'Valores da Fixação Moeda 1'	
	oStruNN8:AddGroup( 'GRUPOC', STR0052					, '', 3 )	//'Valores da Fixação Moeda Outra Moeda'

	//-- 	Atribuindo Todos os Campos ao Grupo A			 	--//
	oStruNN8:SetProperty( '*' , MVC_VIEW_GROUP_NUMBER, 'GRUPOA' )

	//-- Atribuindo os Campos de Valor na 1a. Moeda ao Grupo B 	--//
	oStruNN8:SetProperty( 'NN8_VLRUNI' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNN8:SetProperty( 'NN8_VLRLIQ' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNN8:SetProperty( 'NN8_VLRTOT' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNN8:SetProperty( 'NN8_VLRLQT' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )

	//-- Atribuindo os Campos de Valores na Tx. Moeda Informada ao Grupo C	--//
	oStruNN8:SetProperty( 'NN8_MOEDA' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNN8:SetProperty( 'NN8_TXMOED' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )		
	oStruNN8:SetProperty( 'NN8_VALUNI' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNN8:SetProperty( 'NN8_VALLIQ' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNN8:SetProperty( 'NN8_VALTOT' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNN8:SetProperty( 'NN8_VALLQT' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )

	oView:AddUserButton( STR0053, '', {|| OGA430fPrc() } )        //'Composição de Preços

Return oView


/** {Protheus.doc} VldActivMD
Função que Valida o modelo de dados ( pré-valida a entrada na tela )

@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Equipe Agroindustria
@since: 	08/11/2014
@Uso: 		OGA430F
*/
///Static Function fVldActivate( oModel )

Static Function  VldActivMD ( oModel, cCodCtr )
	Local nOperation	:= oModel:GetOperation()

	DbSelectArea( "NJR" )
	DbSetOrder( 1 )
	DbSeek( FWxFilial( "NJR" ) + cCodCtr )


	If nOperation == MODEL_OPERATION_INSERT
		If NN8->( NN8_STATUS ) <> "1" .and. (cPaisLoc == "PAR" .or. cPaisLoc == "ARG")
			Help( ,, STR0011,, STR0012 + X3CboxDesc( "NN8_STATUS", "1" ), 1, 0,) //"HELP"##"Operação não permitida para Fixação com STATUS diferente de 1="Aberta
			Return( .F. )
		EndIf

		If NN8->( NN8_QTDFIX ) == 0 .and. (cPaisLoc == "PAR" .or. cPaisLoc == "ARG") //Pré-Contrato *DEKALPAR
			Help( ,, STR0011,, "Não possui saldo a fixar!", 1, 0,) //"HELP"##"Operação não permitida para Pré-Contratos."
			Return( .F. )
		EndIf

		If NJR->( NJR_MODELO ) == "1" //Pré-Contrato
			Help( ,, STR0011,, STR0015 , 1, 0,) //"HELP"##"Operação não permitida para Pré-Contratos."
			Return( .F. )
		EndIf

		If !( NJR->( NJR_STATUS ) $ "A|I" ) //Se status do contrato for diferente de Aberto ou Iniciado
			Help( ,, STR0011,, STR0016+NJR->( NJR_STATUS )+"="+ X3CboxDesc( "NJR_STATUS", NJR->( NJR_STATUS ) ) , 1, 0,) //"HELP"##"Operação não permitida para Contratos com STATUS igual a "
			Return( .F. )
		EndIf
	EndIF

	If nOperation == MODEL_OPERATION_DELETE .Or. nOperation == MODEL_OPERATION_UPDATE

		If nOperation == MODEL_OPERATION_DELETE .and. (cPaisLoc == "PAR" .or. cPaisLoc == "ARG") .and. NN8->( NN8_ITEMFX )  == "001" //Basis *DEKALPAR
			Help( ,, STR0011,, "Primeira negociação não pode ser eliminada!", 1, 0,) //"HELP"##"Operação não permitida para Fixação com STATUS diferente de 1="Aberta
			Return( .F. )
		EndIf
		If NN8->( NN8_STATUS ) <> "1"
			Help( ,, STR0011,, STR0012 + X3CboxDesc( "NN8_STATUS", "1" ), 1, 0,) //"HELP"##"Operação não permitida para Fixação com STATUS diferente de 1="Aberta
			Return( .F. )
		EndIf
	EndIf
	//Sistema não pode excluir, senão perderemos o histórico de preço fechado do contrato na criação dele.
	//Ajustar para bloquear as ações de excluir, alterar e incluir quando contrato é fixo. - DAGROCCO-3589
	If NJR->NJR_TIPFIX == '1' .AND. ( nOperation == MODEL_OPERATION_DELETE .Or. nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_INSERT )
		Help( ,, STR0011,, "Não é possivel incluir, alterar e excluir fixações de um contrato com precificação fixa.", 1, 0,) //"HELP"##
		Return( .F. )
	EndIf
Return( .T. )


/** {Protheus.doc} ActiveMD
Função que executada  na ativação do modelo apos a validadcao

@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Emerson Coelho
@since: 	01/06/2016
@Uso: 		OGA430F
*/
Static Function  ActiveMD ( oModel )
	XaGrvNKA	:= {}	// Inicializando Variavel Staticas
Return( .T. )

/** {Protheus.doc} fNextItem
Função que retorna o número do próximo item da fixação.

@param: 	oModel - Modelo
@return:	cItemFx - Item da fixação
@author: 	Equipe Agroindustria
@since: 	06/11/2014
@Uso: 		OGA430F
*/
Static Function fNextItem( oModel )
	Local aSaveArea 	:= GetArea()
	Local cAliasQry 	:= GetNextAlias()
	Local cCodCtr 		:= NJR->( NJR_CODCTR )
	Local cItemFx		:= oModel:GetValue( "NN8UNICO", "NN8_ITEMFX" )

	BeginSql Alias cAliasQry
	SELECT MAX(NN8_ITEMFX) as NN8_ITEMFX
	FROM %Table:NN8% NN8
	WHERE NN8.%notDel%
	AND NN8_FILIAL = %XFilial:NN8%
	AND NN8_CODCTR = %exp:cCodCtr%
	EndSQL

	DbselectArea( cAliasQry )
	DbGoTop()
	If ( cAliasQry )->( !Eof() )
		If !Empty( AllTrim( ( cAliasQry )->NN8_ITEMFX ) )
			cItemFx := Soma1( ( cAliasQry )->NN8_ITEMFX )
		Else
			cItemFx := StrZero( 1, TamSX3( "NN8_ITEMFX" )[1] )
		EndIf
	Else
		cItemFx := StrZero( 1, TamSX3( "NN8_ITEMFX" )[1] )
	EndIf
	( cAliasQry )->( DbCloseArea() )

	RestArea( aSaveArea )
Return( cItemFx )


/** {Protheus.doc} fSldAFixar
Função que retorna o saldo a fixar do contrato.

@param: 	oModel - Modelo
@return:	nSldAFixar - Saldo a fixar
@author: 	Equipe Agroindustria
@since: 	18/11/2014
@Uso: 		OGA430F
*/
Static Function fSldAFixar( oModel )
	Local aSaveArea 	:= GetArea()
	Local cCodCtr 		:= NJR->( NJR_CODCTR )

	Local aQtds		:= OGX010QCtr( cCodCtr ) // Retorna as quantidades do contrato
	Local nQtdCtr		:= aQtds[1]
	Local nQtdFxCtr	:= aQtds[9]
	Local nSldAFixar  := nQtdCtr - nQtdFxCtr

	If cPaisLoc == "PAR" .or. cPaisLoc == "ARG"
		nSldAFixar  := NN8->NN8_QTDFIX
	EndIf

	
	RestArea( aSaveArea )
Return( nSldAFixar )


/** {Protheus.doc} ValNN8DATINI
Valida o campo NN8_DATINI e automaticamente preenche NN8_DATFIN

@param: 	oField 
@return:	lRetorno - verdadeiro ou falso
@author: 	Equipe Agroindustria
@since: 	18/11/2014
@Uso: 		OGA430F
*/
Static Function ValNN8DATINI( oFldNN8 )
	Local lRetorno 	:= .T.

	If Empty(oFldNN8:GetValue( "NN8_DATFIN" ))
		oFldNN8:SetValue( "NN8_DATFIN", oFldNN8:GetValue( "NN8_DATINI" ) )
	EndIf
Return( lRetorno )


/** {Protheus.doc} ValValores
Valida e preenche automaticamente os campos de quantidade e valores

@param: 	oField 
@return:	lRetorno - verdadeiro ou falso
@author: 	Equipe Agroindustria
@since: 	18/11/2014
@Uso: 		OGA430F
*/
Static Function ValValores( oFldNN8, cCpoAtual )
	Local lRetorno		:= .t.
	Local aAreaAtu		:= GetArea()
	Local nQtdFix		:= oFldNN8:GetValue( "NN8_QTDFIX" )
	// -- Consistindo Qtd a Fixar c. Saldo a Fixar (EC,09/02/2015)-- //	
	Local aQtds		:= OGX010QCtr( NJR->NJR_CODCTR ) // Retorna as quantidades do contrato
	Local nQtdCtr		:= aQtds[1]
	Local nQtdFxCtr	:= aQtds[9]
	Local nSldAFixar  := nQtdCtr - nQtdFxCtr

	If cPaisLoc == "PAR" .or. cPaisLoc == "ARG"
		//*Dekalpar baixa o saldo a fixar
		dbSelectArea("NN8")
		NN8->( dbSetOrder(1) )  //Contrato + Tipo + Item Fix
		NN8->(DbSeek(xFilial("NN8") + oFldNN8:GetValue('NN8_CODCTR') + oFldNN8:GetValue('NN8_ITORIG')  ))

		If cCpoAtual == "NN8_QTDFIX"
			IF ( nQtdFix > NN8->NN8_QTDFIX )
				Return(.f.)
			EndIF
		EndIF
	Else
		If cCpoAtual == "NN8_QTDFIX"
			IF ( nQtdFix > nSldAFixar )
				Return(.f.)
			EndIF
		EndIF
	EndIF

	RestArea( aAreaAtu )
Return( lRetorno )


/** {Protheus.doc} PosModelo
Pós validação do modelo, antes da gravação.

@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Equipe Agroindustria
@since: 	21/10/2014
@Uso: 		OGA430F
*/
Static Function PosModelo( oParModel )
	Local aAreaAtu		:= GetArea()
	Local aAreaNJR		:= NJR->( GetArea() )
	Local lRetorno		:= .T.
	Local oModel		:= oParModel:GetModel()
	Local nOperation	:= oModel:GetOperation()
	Local cCodCtr		:= oModel:GetValue( "NN8UNICO", "NN8_CODCTR" )
	Local nQtdFix		:= oModel:GetValue( "NN8UNICO", "NN8_QTDFIX" )
	Local nQtEmAlt		:= 0	// Conterá a qtd. Gravada da Fixação Antes do Confirma da Alteração
	Local nQtdEnt		:= oModel:GetValue( "NN8UNICO", "NN8_QTDENT" )
	Local dDatIni		:= oModel:GetValue( "NN8UNICO", "NN8_DATINI" )
	Local dDatFin		:= oModel:GetValue( "NN8UNICO", "NN8_DATFIN" )
	Local aQtds			:= OGX010QCtr( cCodCtr ) // Retorna as quantidades do contrato
	Local nQtdCtr		:= aQtds[1]
	Local nQtdFxCtr		:= aQtds[9]
	Local nSldAFixar  	:= nQtdCtr - nQtdFxCtr

	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE

		IF nOperation == MODEL_OPERATION_UPDATE .and. cPaisLoc <> "PAR" .and. cPaisLoc <> "ARG"
			nQtEmAlt := NN8->NN8_QTDFIX
		Else 
			nQtEmAlt := 0
		EndIF

		// Verifica se quantidade fixada for menor que a qtde entregue da fixação
		If nQtdFix <  nQtdEnt
			Help( ,, STR0011,, STR0017 , 1, 0,) //"HELP"##"A qtde fixada não pode ser menor que a qtde entregue da fixação."
			lRetorno := .f.
		EndIf

		// Verifica se quantidade fixada é maior que saldo a fixar do contrato
		If nQtdFix > ( nSldAFixar + nQtEmAlt ) .and. cPaisLoc <> "PAR" .and. cPaisLoc <> "ARG"
			Help( ,, STR0011,, STR0013+Transform(nSldAFixar,PesqPict("NN8","NN8_QTDFIX")) , 1, 0,) //"HELP"##"O saldo máximo a fixar do contrato é
			lRetorno := .f.
		EndIf

		// Data de iníncio de entrega não pode ser maior que a data de final de entrega
		If dDatIni > dDatFin
			Help( ,, STR0011,, STR0014 , 1, 0,) //"HELP"##"Data de Início de Entrega não pode ser maior que a Data Final de Entrega"
			lRetorno := .f.
		EndIf
		// Valida se tem outra fixação com NN8_TIPOFX = '0' (Prevista)
		AGRGRAVAHIS("Histórico","NN8",xFilial("NN8")+oModel:GetValue( "NN8UNICO", "NN8_CODCTR" )+oModel:GetValue( "NN8UNICO", "NN8_ITEMFX" ),"N")
	Else
		AGRGRAVAHIS(,,,,{"NN8",xFilial("NN8")+oModel:GetValue( "NN8UNICO", "NN8_CODCTR" )+oModel:GetValue( "NN8UNICO", "NN8_ITEMFX" ),"5","EXCLUIR"}) //Excluir
	EndIf

	RestArea( aAreaAtu )
	RestArea( aAreaNJR )
Return( lRetorno )


/** {Protheus.doc} OG430GRVMD
Funcao para gravar dados adicionais e o modelo de dados

@param: 	oModel - Modelo de Dados
@return:	lRetorno - .t. ou .f.
@author: 	Emerson Coelho
@since: 	01/06/2016
@Uso: 		OGA430F ( Registro de Fixação )
*/
Static Function OG430GrvMd (oModel)
	Local lRetorno 			:= .T.
	Local nOperation		:= oModel:GetOperation()
	Local oMDNN8			:= oModel:GetModel( "NN8UNICO" )
	Local cCodCtr			:= oMdNN8:GetValue('NN8_CODCTR')
	Local cItemFx			:= oMdNN8:GetValue('NN8_ITEMFX')

	IF nOperation == MODEL_OPERATION_INSERT .or.  nOperation == MODEL_OPERATION_UPDATE
		// Grava o Modelo e Chama função que Grava a Composição de Prc ( NKA )
		lRetorno:=FWFormCommit( oModel,/*[bBefore]*/, /*[bAfter]*/, /*[bAfterSTTS]*/, {|| OGA420NKAW( XaGrvNKA, cItemFx  ) }, /*[bABeforeTTS]*/, /*<bIntegEAI >*/)
		If cPaisLoc == "PAR" .or. cPaisLoc == "ARG"
				//*Dekalpar baixa o saldo a fixar // so paraguai
				dbSelectArea("NN8")
				NN8->( dbSetOrder(1) )  //Contrato + Tipo + Item Fix
				NN8->(DbSeek(xFilial("NN8") + cCodCtr + oMdNN8:GetValue('NN8_ITORIG')  ))
				RecLock("NN8",.F.)
				NN8->NN8_QTDFIX :=  NN8->NN8_QTDFIX - oMdNN8:GetValue('NN8_QTDFIX')
				NN8->( MsUnLock() )
		EndIf
	ElseIF nOperation == MODEL_OPERATION_DELETE 
		// Deleta o Modelo e Chama a Função que Deleta a Composição de Prc ( NKA )
		lRetorno:=FWFormCommit( oModel,/*[bBefore]*/, /*[bAfter]*/, /*[bAfterSTTS]*/, {|| OGA420NKAD( cCodCtr, cItemFx  ) }, /*[bABeforeTTS]*/, /*<bIntegEAI >*/)
		If cPaisLoc == "PAR" .or. cPaisLoc == "ARG"
			//*Dekalpar volta o saldo a fixar //so paraguai
			dbSelectArea("NN8")
			NN8->( dbSetOrder(1) )  //Contrato + Tipo + Item Fix
			If NN8->(DbSeek(xFilial("NN8") + cCodCtr + oMdNN8:GetValue('NN8_ITORIG')  ))
				RecLock("NN8",.F.)
				NN8->NN8_QTDFIX :=  NN8->NN8_QTDFIX + oMdNN8:GetValue('NN8_QTDFIX')
				NN8->( MsUnLock() )
			EndIf
		EndIf
	EndIF

Return( lRetorno )


/** {Protheus.doc} OGA430Vinc()
Funcao para vincular ou desvincular notas a fixações

@param: 	pnOpc
@return:	Nil
@author: 	Equipe Agroindustria
@since: 	18/11/2014
@Uso: 		OGA430 - Fixação de Preço
*/
Function OGA430FCPR( pnOpc )
	Local aAreaAtu		:= GetArea()
	Local cAliasQry 	:= ''//GetNextAlias()
	Local aAux			:= {}
	Local lOk			:= .F.
	Local nY			:= 0
	Local cCodCtr 		:= NN8->NN8_CODCTR
	Local cItemFx		:= NN8->NN8_ITEMFX
	Local nRecNN8 		:= NN8->( Recno() )
	Local cAuxItemFx 	:= " "
	Local cAuxMark		:= " "
	Local nAuxQtdMrk  	:= 0
	Local nQtdMrk		:= 0
	Local cCodRom 		:= ''
	Local cIteRom 		:= ''
	Local nQtdEnt 		:= 0
	Local cTipMov 		:= ''
	Local nQtaVinc 		:= 0
	Local nVlrEnt		:= 0 
	Local nVlrImp		:= 0
	Local nFreteNF		:= 0
	Local nSeguroNF		:= 0
	Local nDespesaNF  	:= 0
	Local nQtNF			:= 0
	Local NVlrUni 		:= 0
	Local nVrFretFix	:= 0
	Local nVrSegufix	:= 0
	Local nVrDespFix	:= 0
	Local nVlFixB		:= 0
	Local nPesoFco      := 0
	Local nQtd          := 0
	Local nCol          := 0

	If NN8->( NN8_TIPOFX ) $ '02' // 0=Á fixar; 1=Firme; 2=Basis ; 3=Provisorio 
		If cPaisLoc == "PAR" .or. cPaisLoc == "ARG"
			Help( , , STR0011, , STR0058, 1, 0 ) //"AJUDA"###"Operação não permitida para fixações do tipo '0=Afixar e 2=Basis'."
		Else
			Help( , , STR0011, , STR0054, 1, 0 ) //"AJUDA"###"Operação não permitida para fixações do tipo '0=Prevista'."
		EndIf
		Return( Nil )
	EndIf

	cAliasQry := fQryRomCpr( pnOpc, NN8->NN8_CODCTR, NN8->NN8_ITEMFX )

	DbselectArea( cAliasQry )
	DbGoTop()
	While .Not. ( cAliasQry )->( Eof() )

		nPesoFco := IIf((cAliasQry)->NJJ_PESO3 <> 0,(cAliasQry)->NJJ_PESO3,(cAliasQry)->NJM_QTDFCO  ) 

		Do Case
			Case Empty((cAliasQry)->NJJ_TPCLAS)
			nQtd := (cAliasQry)->D1_QUANT
			nCol := COL_QTDFIS
			Case (cAliasQry)->NJJ_TPCLAS == '1' //Fisica
			nQtd := nPesoFco
			nCol := COL_QTDFCO
			Case (cAliasQry)->NJJ_TPCLAS == '2' //Fiscal
			nQtd := (cAliasQry)->NJM_QTDFIS
			nCol := COL_QTDFIS
		EndCase

		nSldRomVnc := nQtd - ( cAliasQry )->( D1_QTDEDEV )	- ( cAliasQry )->QTVINCULAD //- D1_QTDFIX )

		If pnOpc = 2 // 2=Desvincular
			cAuxMark	:= "0"
			cAuxItemFx	:= cItemFx
			nAuxQtdMrk	:= ( cAliasQry )->QTVINCULAD

			// -- Verificando se o Romaneio a Desvincular Já Possui Nf. de Compl Se Sim n. Podera Desnvincular -- //
			DbSelectArea('NKC')
			NKC->( dbSetOrder( 1 ) )	//NKC_FILIAL+NKC_CODCTR+NKC_ITEMFX+NKC_CODROM+NKC_ITEROM
			cChave	:= fWxFilial( 'NKC' ) + NN8->(NN8_CODCTR + NN8_ITEMFX) + ( cAliasQry )->( D1_CODROM + D1_ITEROM )
			NKC->( dbSeek( cChave ) )
			IF FWxFilial( "NKC" ) + NKC->( NKC_CODCTR + NKC_ITEMFX + NKC_CODROM + NKC_ITEROM ) == cChave
				cAuxmark := '2'
			EndIf
			//---------------------------------------------------------------------------------------------------	//
		Else // 1=Vincular
			cAuxMark	:= "0"
			cAuxItemFx	:= IIf( ( nQtd - (cAliasQry)->D1_QTDEDEV ) > 0, " ", "( ... )" ) //- D1_QTDFIX ) > 0, " ", "( ... )" )
			nAuxQtdMrk	:= 0
			IF nSldRomVnc == 0 // --se n. existir saldo no romaneio para Vincular --//
				cAuxmark := '2'
			EndIF
		EndIf

		aAdd( aAux, Array( COL_COUNT ) )
		aAux[ Len( aAux ), COL_MARK 	] := cAuxMark
		aAux[ Len( aAux ), COL_ITEMFX	] := cAuxItemFx
		aAux[ Len( aAux ), COL_CODROM 	] := ( cAliasQry )->( D1_CODROM )
		aAux[ Len( aAux ), COL_ITEROM 	] := ( cAliasQry )->( D1_ITEROM )
		aAux[ Len( aAux ), COL_QTDFIS 	] := ( cAliasQry )->( NJM_QTDFIS - D1_QTDEDEV )	
		aAux[ Len( aAux ), COL_QTDFCO 	] := ( nPesoFco - (cAliasQry)->D1_QTDEDEV )  	
		aAux[ Len( aAux ), COL_QTDENT 	] := nQtd       				
		aAux[ Len( aAux ), COL_SLDENT 	] := nSldRomVnc
		aAux[ Len( aAux ), COL_QTDMRK 	] := nAuxQtdMrk
		aAux[ Len( aAux ), COL_VAZIO 	] := ""
		aAux[ Len( aAux ), COL_VRENT 	] := A410Arred( ( cAliasQry )->D1_TOTAL * ( aAux[ Len( aAux ), nCol ] / (cAliasQry )->D1_QUANT ),				'D1_TOTAL')
		// [ -- Impostos a Considerados neste momento  (<< Senar, Fethab(MT), Facs (MT),FUNRURAL>,FUNDERSUL (MS) >>)]
		nVrImposto:= IIF(cPaisLoc <> "PAR" .and. cPaisLoc <> "ARG",(cAliasQry)->D1_VLSENAR + (cAliasQry)->D1_VALFET + ( cAliasQry )->D1_VALFAC + ( cAliasQry )->D1_VALFUN + ( cAliasQry )->D1_VALFDS + ( cAliasQry )->D1_VALINS , 0 )
		aAux[ Len( aAux ), COL_VRIMP 	] := nVrImposto

		// -  Frete/Seguro/Despesas acessorias  Do docto Fiscal - //
		aAux[ Len( aAux ), COL_VRFRE 	] := ( cAliasQry )->D1_VALFRE 
		aAux[ Len( aAux ), COL_VRSEG 	] := ( cAliasQry )->D1_SEGURO
		aAux[ Len( aAux ), COL_VRDACES 	] := ( cAliasQry )->D1_DESPESA

		// - Dados doc fiscal - //
		aAux[ Len( aAux ), COL_SERIE 	] := ( cAliasQry )->D1_SERIE 
		aAux[ Len( aAux ), COL_DOC 		] := ( cAliasQry )->D1_DOC

		aAux[ Len( aAux ), COL_FORMUL 	] := ( cAliasQry )->D1_FORMUL
		// - Recno para Posterior Leitura - //
		aAux[ Len( aAux ), COL_RECNO 	] := ( cAliasQry )->D1_RECNO

		// - Tipo de Classificação - //
		aAux[ Len( aAux ), COL_TPCLAS 	] := ( cAliasQry )->NJJ_TPCLAS

		nQtdMrk += nAuxQtdMrk

		( cAliasQry )->( DbSkip() )

	EndDo
	( cAliasQry )->( dbCloseArea() )

	If Len( aAux ) <= 0
		Help( , , STR0011, , STR0018, 1, 0 ) //"AJUDA"###"Nenhuma romaneio encontrado!"
		Return( Nil )
	EndIf

	// --Montagem da tela --//
	lOk := nil
	lOK := fMontaTela(  PnOpc, aAux, nQtdMrk )
	// --Montagem da Tela --//

	If lOk
		If pnOpc == 1 // Vincula
			For nY := 1 to Len( aAux )
				If aAux[ nY, COL_MARK ] = "1" //Marcado

					cCodRom 	:= aAux[ nY, COL_CODROM ]
					cIteRom 	:= aAux[ nY, COL_ITEROM ]
					nQtdEnt 	:= aAux[ nY, nCol       ]
					cTipMov 	:= aAux[ nY, COL_TIPMOV ]
					nQtaVinc 	:= aAux[ nY, COL_QTDMRK ]
					nVlrEnt		:= aAux[ nY, COL_VRENT  ] 
					nVlrImp		:= aAux[ nY, COL_VRIMP  ]
					nFreteNF	:= aAux[ nY, COL_VRFRE 	]
					nSeguroNF	:= aAux[ nY, COL_VRSEG 	]
					nDespesaNF  := aAux[ nY, COL_VRDACES]
					nQtNF		:= aAux[ nY, COL_QTDENT ]

					nVlrUni := Posicione( "NJM", 1, xFilial("NJM")+cCodRom+cIteRom , "NJM_VLRUNI")

					// - Frete/Seguro/Despesas Acess. Ref. a Qt. Vinculada a fixação -
					nVrFretFix	:= 0
					nVrSegufix	:= 0
					nVrDespFix	:= 0
					fRateiaDsp(cCodCtr,cCodRom,cIteRom ,nQtNF,nQtdEnt,nQtaVinc,nFreteNF,nSeguroNF,nDespesaNF,@nVrFretFix,@nVrSegufix,@nVrDespFix)
					nVlFixB		:= fNNCVLFIXB( nQTaVinc )

					dbSelectArea( "NNC" )
					NNC->( dbSetOrder( 1 ) ) //NNC_FILIAL+NNC_CODCTR+NNC_ITEMFX+NNC_CODROM+NNC_ITEROM
					If dbSeek( xFilial("NNC") + cCodCtr + cItemFx + cCodRom + cIteRom )
						RecLock( "NNC", .f. )
						NNC->( NNC_QTDFIX )  += nQTaVinc
						NNC->( MsUnLock() )
					Else
						RecLock( "NNC", .t. )
						NNC->NNC_FILIAL 	:= xFilial( "NNC" )
						NNC->NNC_CODCTR 	:= cCodCtr
						NNC->NNC_ITEMFX 	:= cItemFx
						NNC->NNC_CODROM 	:= cCodRom
						NNC->NNC_ITEROM 	:= cIteRom
						NNC->NNC_QTDENT 	:= nQtdEnt
						NNC->NNC_VLENT   	:= nVlrEnt		

						NNC->NNC_QTDFIX  	:= nQTaVinc 	//-- Qtidade Vinculada desse romaneio à Fixação --//
						NNC->NNC_VRENPF		:= a410Arred(nVlrEnt * (NNC->NNC_QTDFIX / NNC->NNC_QTDENT),'D1_TOTAL')
						///NNC->NNC_VLFIXB		:= a410Arred( NN8->NN8_VLRTOT  * ( NNC->NNC_QTDFIX  / NN8-> NN8_QTDFIX ), 'D1_TOTAL' )
						NNC->NNC_VLFIXB		:=  nVlFixB
						NNC->NNC_VLIMPE		:= nVlrImp
						NNC->NNC_VLIMPF		:= a410Arred( nVlrImp * (NNC->NNC_VRENPF / NNC->NNC_VLENT), 'D1_TOTAL' )

						NNC->NNC_SERDOC  	:= aAux[ nY, COL_SERIE	]
						NNC->NNC_NUMDOC		:= aAux[ nY, COL_DOC	]
						NNC->NNC_FORMUL 	:= aAux[ nY, COL_FORMUL	]
						NNC->NNC_DOCVUN  	:= nVlrUni

						// -  Frete/Seguro/Despesas acessorias do Docto- //
						NNC->NNC_VLNFFR  	:= nFreteNF
						NNC->NNC_VLNFSE  	:= nSeguroNF 
						NNC->NNC_VLNFDA  	:= nDespesaNF

						// -  Frete/Seguro/Despesas acessorias ref a qtd fixada //
						NNC->NNC_VLFRET  	:= nVrFretFix
						NNC->NNC_VLSEGU  	:= nVrSegufix 
						NNC->NNC_VLDESP  	:= nVrDespFix

						NNC->( MsUnLock() )
					EndIf

					RecLock( "NNC", .f. )
					NNC->NNC_STATUS := OG430STAT( NNC->(Recno() )  )
					NNC->( MsUnLock() )
				EndIf
			Next nY
		Else //Desvincula
			For nY := 1 to Len( aAux )
				If aAux[ nY, COL_MARK ] = "1" //Desmarcado
					cCodRom := aAux[ nY, COL_CODROM ]
					cIteRom := aAux[ nY, COL_ITEROM ]

					dbSelectArea( "NNC" )
					dbSetOrder( 1 )
					If dbSeek( xFilial("NNC") + cCodCtr + cItemFx + cCodRom + cIteRom)
						RecLock( "NNC", .f. )
						NNC->( dbDelete() )
						NNC->( MsUnLock() )
					EndIf
				EndIf
			Next nY
		EndIf

		// Somatória de todas quantidades entregues
		cAliasQry 	:= GetNextAlias()
		BeginSql Alias cAliasQry
		SELECT 
		CASE 
		WHEN SUM(NNC_QTDFIX) IS NULL THEN 0
		ELSE SUM(NNC_QTDFIX)
	END AS NNC_QTDFIX
	FROM %Table:NNC% NNC
	WHERE 	NNC.%NotDel%
	AND 	NNC.NNC_FILIAL = %XFilial:NNC%
	AND 	NNC.NNC_CODCTR = %exp:cCodCtr%
	AND 	NNC.NNC_ITEMFX = %exp:cItemFx%
	EndSql

	DbselectArea( cAliasQry )
	If .Not. ( cAliasQry )->( Eof() )
		nQtdMrk := ( cAliasQry )->NNC_QTDFIX
	EndIf
	( cAliasQry )->( dbCloseArea() )

	// Atualiza a Fixação
	DbSelectArea( "NN8" )
	DbGoTo( nRecNN8 )
	If RecLock( "NN8", .f. )
		NN8->NN8_QTDENT 	:= nQtdMrk
		NN8->NN8_STATUS		:= iIf( NN8->NN8_QTDENT >= NN8->NN8_QTDFIX, "3",; //3=Fechada
		IIf( NN8->NN8_QTDENT < NN8->NN8_QTDFIX .And. NN8->NN8_QTDENT > 0, "2", "1") ) // 2=Parcial; 1=Aberta
		NN8->( msUnlock() )
	EndIf

	_oBrwNN8:Refresh()

	EndIf

	RestArea(aAreaAtu)
	// -- Fim OGA430FCPR --
Return( .F. )

/** {Protheus.doc} OGA430FVND()
Funcao para vincular ou desvincular notas a fixações ref. 
aos Contratos de venda;

@param: 	pnOpc
@return:	Nil
@author: 	Emerson ( Baseado na Funcao OGA430FPRC ) 
@since: 	29/06/2015
@Uso: 		OGA430 - Fixação de Preço
*/
Function OGA430FVND( PnOpc )
	Local aAreaAtu		:= GetArea()
	Local cAliasQry 	:= GetNextAlias()
	Local aAux			:= {}
	Local lOk			:= .F.
	Local nY			:= 0
	Local cCodCtr 		:= NN8->( NN8_CODCTR )
	Local cItemFx		:= NN8->( NN8_ITEMFX )
	Local nRecNN8 		:= NN8->( Recno() )
	Local cAuxItemFx 	:= " "
	Local cAuxMark		:= " "
	Local nAuxQtdMrk  	:= 0
	Local nQtdMrk		:= 0
	Local cCodRom 		:= ''
	Local cIteRom 		:= ''
	Local nQtdEnt 		:= 0
	Local cTipMov 		:= ''
	Local nQtaVinc 		:= 0
	Local nVlrEnt		:= 0 
	Local nVlrImp		:= 0
	Local nFreteNF		:= 0
	Local nSeguroNF		:= 0
	Local nDespesaNF  	:= 0
	Local nQtNF			:= 0
	Local NVlrUni 		:= 0
	Local nVrFretFix	:= 0
	Local nVrSegufix	:= 0
	Local nVrDespFix	:= 0
	Local nVlFixB		:= 0
	Local nPesoFco      := 0
	Local nQtd          := 0
	Local nCol          := 0
	Local lN8K			:= AGRTABDIC({"N8K"}) //verifica se tabela N8K existe, tabela liberado P12.1.23
    Local nComplOrig    := 0

	If NN8->( NN8_TIPOFX ) <> "1" // 0=Prevista; 1=Firme
		Help( , , STR0011, , STR0054, 1, 0 ) //"AJUDA"###"Operação não permitida para fixações do tipo '0=Prevista'."
		Return( Nil )
	EndIf

	cAliasQry := fQryRomVnd( pnOpc, NN8->NN8_CODCTR, NN8->NN8_ITEMFX )

	cCampoCtr := Iif(AGRTABDIC({"N8K"}),"N8K_CODCTR","D2_CTROG" ) 

	DbselectArea( cAliasQry )
	DbGoTop()
	While .Not. ( cAliasQry )->( Eof() )

		If Posicione('NJR',1,FwxFilial('NJR')+(cAliasQry)->&cCampoCtr,'NJR_OPEFUT') == '1' .and.;			
		Posicione('SF4',1,fwxFilial("SF4")+(cAliasQry)->D2_TES ,'F4_ESTOQUE') == "S" //não movimenta
			( cAliasQry )->( DbSkip() )
			Loop //volta
		EndIf
		nPesoFco := IIf((cAliasQry)->NJJ_PESO3 <> 0,(cAliasQry)->NJJ_PESO3,(cAliasQry)->NJM_QTDFCO  ) 

		Do Case
			Case Empty((cAliasQry)->NJJ_TPCLAS)
			nQtd := (cAliasQry)->D2_QUANT
			nCol := COL_QTDFIS
			Case (cAliasQry)->NJJ_TPCLAS == '1' //Fisica
			nQtd := nPesoFco
			nCol := COL_QTDFCO
			Case (cAliasQry)->NJJ_TPCLAS == '2' //Fiscal
			nQtd := (cAliasQry)->NJM_QTDFIS
			nCol := COL_QTDFIS
		EndCase

		nSldRomVnc := nQtd - ( cAliasQry )->( D2_QTDEDEV )	- ( cAliasQry )->QTVINCULAD //- D1_QTDFIX )

		If pnOpc = 2 // 2=Desvincular
			cAuxMark	:= "0"
			cAuxItemFx	:= cItemFx
			nAuxQtdMrk	:= ( cAliasQry )->QTVINCULAD

			// -- Verificando se o Romaneio a Desvincular Já Possui Nf. de Compl Se Sim n. Podera Desnvincular -- //
			DbSelectArea('NKC')
			NKC->( dbSetOrder( 1 ) )	//NKC_FILIAL+NKC_CODCTR+NKC_ITEMFX+NKC_CODROM+NKC_ITEROM
			If lN8K //liberado P12.1.23. VERIFICA SE NÃO EXISTE D2_CTROG POIS ESTE FOI CRIADO VIA UPDDISTR LEGADO
			   cChave	:= fWxFilial( 'NKC' ) + NN8->(NN8_CODCTR + NN8_ITEMFX) + ( cAliasQry )->( N8K_CODROM + N8K_ITEROM )
			Else
			  cChave	:= fWxFilial( 'NKC' ) + NN8->(NN8_CODCTR + NN8_ITEMFX) + ( cAliasQry )->( D2_CODROM + D2_ITEROM )
			EndIf
			NKC->( dbSeek( cChave ) )
			IF FWxFilial( "NKC" ) + NKC->( NKC_CODCTR + NKC_ITEMFX + NKC_CODROM + NKC_ITEROM ) == cChave
				cAuxmark := '2'
			EndIf
			//---------------------------------------------------------------------------------------------------	//
		Else // 1=Vincular
			cAuxMark	:= "0"
			cAuxItemFx	:= iIf( ( cAliasQry )->( D2_QUANT - D2_QTDEDEV ) > 0, " ", "( ... )" ) //- D2_QTDFIX ) > 0, " ", "( ... )" )
			nAuxQtdMrk	:= 0
			IF nSldRomVnc == 0 // --se n. existir saldo no romaneio para Vincular --//
				cAuxmark := '2'
			EndIF
		EndIf

		aAdd( aAux, Array( COL_COUNT ) )
		aAux[ Len( aAux ), COL_MARK 	] := cAuxMark
		aAux[ Len( aAux ), COL_ITEMFX	] := cAuxItemFx
		If lN8K //Liberado P12.1.23. VERIFICA SE NÃO EXISTE D2_CTROG POIS ESTE FOI CRIADO VIA UPDDISTR LEGADO
		   aAux[ Len( aAux ), COL_CODROM 	] := ( cAliasQry )->( N8K_CODROM )
		   aAux[ Len( aAux ), COL_ITEROM 	] := ( cAliasQry )->( N8K_ITEROM )
		Else
		   aAux[ Len( aAux ), COL_CODROM 	] := ( cAliasQry )->( D2_CODROM )
		   aAux[ Len( aAux ), COL_ITEROM 	] := ( cAliasQry )->( D2_ITEROM )
		EndIf	
		aAux[ Len( aAux ), COL_QTDFIS 	] := ( cAliasQry )->( NJM_QTDFIS - D2_QTDEDEV )	
		aAux[ Len( aAux ), COL_QTDFCO 	] := ( nPesoFco - (cAliasQry)->D2_QTDEDEV )  	
		aAux[ Len( aAux ), COL_QTDENT 	] := nQtd
		aAux[ Len( aAux ), COL_SLDENT 	] := nSldRomVnc
		aAux[ Len( aAux ), COL_QTDMRK 	] := nAuxQtdMrk
		aAux[ Len( aAux ), COL_VAZIO 	] := ""
		aAux[ Len( aAux ), COL_VRENT 	] := A410Arred( ( cAliasQry )->D2_TOTAL * ( aAux[ Len( aAux ), nCol ] / (cAliasQry )->D2_QUANT ),				'D2_TOTAL')

		// [ -- Impostos a Considerados neste momento  (<< Senar, Fethab(MT), Facs (MT),FUNRURAL>,FUNDERSUL (MS) >>)]
		nVrImposto							:= IIF(cPaisLoc <> "PAR" .and. cPaisLoc <> "ARG",(cAliasQry)->(D2_VLSENAR+D2_VALFET+D2_VALFAC+D2_VALFUN+D2_VALFDS),0) 
		aAux[ Len( aAux ), COL_VRIMP 	]	:= nVrImposto

		// -  Frete/Seguro/Despesas acessorias - //
		aAux[ Len( aAux ), COL_VRIMP 	] := nVrImposto
		aAux[ Len( aAux ), COL_VRFRE 	] := ( cAliasQry )->D2_VALFRE 
		aAux[ Len( aAux ), COL_VRSEG 	] := ( cAliasQry )->D2_SEGURO
		aAux[ Len( aAux ), COL_VRDACES 	] := ( cAliasQry )->D2_DESPESA

		// - Dados doc fiscal - //
		aAux[ Len( aAux ), COL_SERIE 	] := ( cAliasQry )->D2_SERIE 
		aAux[ Len( aAux ), COL_DOC 		] := ( cAliasQry )->D2_DOC
		aAux[ Len( aAux ), COL_FORMUL 	] := 'S' //( cAliasQry )->D2_FORMUL ( nao utilize D2_FORMUL PQ ELE ESTÁ VAZIO)
		// - Recno para Posterior Leitura - //
		aAux[ Len( aAux ), COL_RECNO 	] := ( cAliasQry )->D2_RECNO

		// - Tipo de Classificação - //
		aAux[ Len( aAux ), COL_TPCLAS 	] := ( cAliasQry )->NJJ_TPCLAS

		nQtdMrk += nAuxQtdMrk

		( cAliasQry )->( DbSkip() )
	EndDo
	( cAliasQry )->( dbCloseArea() )

	If Len( aAux ) <= 0
		Help( , , STR0011, , STR0018, 1, 0 ) //"AJUDA"###"Nenhuma romaneio encontrado!"
		Return( Nil )
	EndIf

	// --Montagem da tela --//
	lOk := nil
	lOK := fMontaTela(  PnOpc, aAux, nQtdMrk )
	// --Montagem da Tela --//

	If lOk
		If pnOpc == 1 // Vincula
			For nY := 1 to Len( aAux )
				If aAux[ nY, COL_MARK ] = "1" //Marcado
					cCodRom 	:= aAux[ nY, COL_CODROM ]
					cIteRom 	:= aAux[ nY, COL_ITEROM ]
					nQtdEnt 	:= aAux[ nY, nCol       ]
					cTipMov 	:= aAux[ nY, COL_TIPMOV ]
					nQtaVinc 	:= aAux[ nY, COL_QTDMRK ]
					nVlrEnt		:= aAux[ nY, COL_VRENT  ] 
					nVlrImp		:= aAux[ nY, COL_VRIMP  ]
					nFreteNF	:= aAux[ nY, COL_VRFRE 	]
					nSeguroNF	:= aAux[ nY, COL_VRSEG 	]
					nDespesaNF  := aAux[ nY, COL_VRDACES]
					nQtNF		:= aAux[ nY, COL_QTDENT ]

					nVlrUni := Posicione( "NJM", 1, xFilial("NJM")+cCodRom+cIteRom , "NJM_VLRUNI")

					// - Frete/Seguro/Despesas Acess. Ref. a Qt. Vinculada a fixação -
					nComplOrig  := fComplOrg(cCodRom)
					nVrFretFix	:= 0
					nVrSegufix	:= 0
					nVrDespFix	:= 0
					fRateiaDsp(cCodCtr,cCodRom,cIteRom ,nQtNF,nQtdEnt,nQtaVinc,nFreteNF,nSeguroNF,nDespesaNF,@nVrFretFix,@nVrSegufix,@nVrDespFix)
					nVlFixB		:= fNNCVLFIXB( nQTaVinc )
					dbSelectArea( "NNC" )
					NNC->(dbSetOrder( 1 ) ) // NNC_FILIAL+NNC_CODCTR+NNC_ITEMFX+NNC_CODROM+NNC_ITEROM
					If dbSeek( xFilial("NNC") + cCodCtr + cItemFx + cCodRom + cIteRom )
						RecLock( "NNC", .f. )
						//NNC->( NNC_QTDENT )	+= nQtdEnt
						NNC->( NNC_QTDFIX )  += nQTaVinc
                        NNC->( NNC_VLCMPL)   += nComplOrig
						NNC->( MsUnLock() )
					Else
						RecLock( "NNC", .t. )
						NNC->NNC_FILIAL		:= FwxFilial( "NNC" )
						NNC->NNC_CODCTR		:= cCodCtr
						NNC->NNC_ITEMFX		:= cItemFx
						NNC->NNC_CODROM		:= cCodRom
						NNC->NNC_ITEROM		:= cIteRom
						NNC->NNC_QTDENT		:= nQtdEnt
						NNC->NNC_VLENT  	:= nVlrEnt
						///NNC->NNC_VLRLIQ  	:= 0			// Neste momento n. será utilizado.
						NNC->NNC_QTDFIX  	:= nQTaVinc 	//-- Qtidade Vinculada desse romaneio à Fixação --//

						NNC->NNC_VRENPF		:= a410Arred(nVlrEnt * (NNC->NNC_QTDFIX / NNC->NNC_QTDENT),					'D2_TOTAL'	)
						//NNC->NNC_VLFIXB		:= a410Arred( NN8->NN8_VLRTOT  * ( NNC->NNC_QTDFIX  / NN8-> NN8_QTDFIX ), 	'D2_TOTAL'	)
						NNC->NNC_VLFIXB		:=   nVlFixB
						NNC->NNC_VLIMPE		:= nVlrImp
						NNC->NNC_VLIMPF		:= a410Arred( nVlrImp * (NNC->NNC_VRENPF / NNC->NNC_VLENT), 				'D2_TOTAL' )

						NNC->NNC_SERDOC  	:= aAux[ nY, COL_SERIE 	]
						NNC->NNC_NUMDOC 	:= aAux[ nY, COL_DOC 		]
						NNC->NNC_FORMUL 	:= aAux[ nY, COL_FORMUL 	]
						NNC->NNC_DOCVUN  	:= nVlrUni

						// -  Frete/Seguro/Despesas acessorias do Docto- //
						NNC->NNC_VLNFFR  	:= aAux[ nY, COL_VRFRE 	]
						NNC->NNC_VLNFSE  	:= aAux[ nY, COL_VRSEG 	] 
						NNC->NNC_VLNFDA  	:= aAux[ nY, COL_VRDACES 	]

						// -  Frete/Seguro/Despesas acessorias ref a qtd fixada //
						NNC->NNC_VLFRET  	:= nVrFretFix
						NNC->NNC_VLSEGU  	:= nVrSegufix 
						NNC->NNC_VLDESP  	:= nVrDespFix
                        NNC->NNC_VLCMPL     := nComplOrig


						NNC->( MsUnLock() )
					EndIf
					// Atualiza o Status, da NNC, utilizado desta forma para poder centralizar a chamada
					RecLock( "NNC", .f. )
					NNC->NNC_STATUS := OG430STAT( NNC->(Recno() )  )
					NNC->( MsUnLock() )
				EndIf
			Next nY
		Else //Desvincula
			For nY := 1 to Len( aAux )
				If aAux[ nY, COL_MARK ] = "1" //Desmarcado
					cCodRom := aAux[ nY, COL_CODROM ]
					cIteRom := aAux[ nY, COL_ITEROM ]

					dbSelectArea( "NNC" )
					dbSetOrder( 1 )
					If dbSeek( xFilial("NNC") + cCodCtr + cItemFx + cCodRom + cIteRom)
						RecLock( "NNC", .f. )
						NNC->( dbDelete() )
						NNC->( MsUnLock() )
					EndIf
				EndIf
			Next nY
		EndIf

		// Somatória de todas quantidades entregues
		cAliasQry 	:= GetNextAlias()
		BeginSql Alias cAliasQry
		SELECT CASE 
		WHEN SUM(NNC_QTDFIX) IS NULL THEN 0
		ELSE SUM(NNC_QTDFIX)
	END AS NNC_QTDFIX
	FROM %Table:NNC% NNC
	WHERE NNC.%NotDel%
	AND NNC.NNC_FILIAL = %XFilial:NNC%
	AND NNC.NNC_CODCTR = %exp:cCodCtr%
	AND NNC.NNC_ITEMFX = %exp:cItemFx%
	EndSql

	DbselectArea( cAliasQry )
	If .Not. ( cAliasQry )->( Eof() )
		nQtdMrk := ( cAliasQry )->( NNC_QTDFIX )
	EndIf
	( cAliasQry )->( dbCloseArea() )

	// Atualiza a Fixação
	DbSelectArea( "NN8" )
	DbGoTo( nRecNN8 )
	If RecLock( "NN8", .f. )
		NN8->( NN8_QTDENT ) := nQtdMrk
		NN8->( NN8_STATUS ) := iIf( NN8->( NN8_QTDENT ) >= NN8->( NN8_QTDFIX ), "3",; //3=Fechada
		iIf( NN8->( NN8_QTDENT ) < NN8->( NN8_QTDFIX ) .And. NN8->( NN8_QTDENT ) > 0, "2", "1") ) // 2=Parcial; 1=Aberta
		NN8->( msUnlock() )
	EndIf

	_oBrwNN8:Refresh()

	EndIf

	RestArea(aAreaAtu)
Return( .F. )

/** {Protheus.doc} MarcaUm
Funcao para seleção de notas a serem vinculadas
@param:	aItsMrk
@param:	nLinMrk
@author: 	Equipe Agroindustria 
@since: 	18/11/2014
@Uso: 		OGA430
*/
Static Function MarcaUm( aItsMrk, nLinMrk, pnOpc, lMarkAll )
	Local cChave	:=''
	Default lMarkAll	:= .f.

	Do Case
		Case aItsMrk[ nLinMrk, COL_MARK ] == "0" // Marcar

		If pnOpc == 1 // 1=Vincular
			If aItsMrk[ nLinMrk, COL_SLDENT ] == 0
				// Abre browser com as fixações X romaneios
				DetalheNNC( aItsMrk, nLinMrk )
				Return( Nil )
			EndIf

			If aItsMrk[ nLinMrk, COL_SLDENT ] <= nSldEnt
				aItsMrk[ nLinMrk, COL_QTDMRK ] := aItsMrk[ nLinMrk, COL_SLDENT ]
				aItsMrk[ nLinMrk, COL_SLDENT ] := 0
			Else
				aItsMrk[ nLinMrk, COL_QTDMRK ] := nSldEnt
				aItsMrk[ nLinMrk, COL_SLDENT ] -= nSldEnt
			EndIf

			nSldEnt -=	aItsMrk[ nLinMrk, COL_QTDMRK ]
			nQtdMrk +=	aItsMrk[ nLinMrk, COL_QTDMRK ]

			If  aItsMrk[ nLinMrk, COL_QTDMRK ] > 0 //-- Vai Marcar o Chkbox--//
				aItsMrk[ nLinMrk, COL_MARK ] := "1"
			Else
				aItsMrk[ nLinMrk, COL_MARK ] := "0"
			EndIf
		Else // -- Desnvincular --//
			///nSldEnt +=	aItsMrk[ nLinMrk, COL_QTDMRK ]
			///nQtdMrk -=	aItsMrk[ nLinMrk, COL_QTDMRK ]

			// -- Verificando se o Romaneio a Desvincular Já Possui Nf. de Compl Se Sim n. Podera Desnvincular -- //
			DbSelectArea('NKC')
			NKC->( dbSetOrder( 1 ) )	//NKC_FILIAL+NKC_CODCTR+NKC_ITEMFX+NKC_CODROM+NKC_ITEROM
			cChave	:= fWxFilial( 'NKC' ) + NN8->(NN8_CODCTR + NN8_ITEMFX) + aItsMrk[ nLinMrk, COL_CODROM ] + aItsMrk[ nLinMrk, COL_ITEROM ]

			NKC->( dbSeek( cChave ) )
			IF FWxFilial( "NKC" ) + NKC->( NKC_CODCTR + NKC_ITEMFX + NKC_CODROM + NKC_ITEROM ) == cChave
				fMLegenda()
			Else							
				aItsMrk[ nLinMrk, COL_MARK ] := "1"
			EndIf

		EndIf

		Case aItsMrk[ nLinMrk, COL_MARK ] == "1" // Desmarcar

		If pnOpc == 1 // 1=Vincular
			aItsMrk[ nLinMrk, COL_SLDENT ] += aItsMrk[ nLinMrk, COL_QTDMRK ]
			nQtdMrk -=	aItsMrk[ nLinMrk, COL_QTDMRK ]
			nSldEnt +=	aItsMrk[ nLinMrk, COL_QTDMRK ]
			aItsMrk[ nLinMrk, COL_QTDMRK ] := 0
			If nSldEnt > nQtdFix
				nSldEnt := nQtdFix
			EndIf
		EndIF

		aItsMrk[ nLinMrk, COL_MARK ] := "0"

	EndCase

	IF .not. lmarkall   //Indica q não stá sendo marcado/desmarcado TODOS.
		onSldEnt:Refresh()
		onQtdMrk:Refresh()
		oBrowse:Refresh()
	EndIF	

Return( Nil )

/** {Protheus.doc} DetalheNNC
Abre um browser com os registros de NNC pertencentes ao romaneio

@param:	Nil
@author: 	Marlon Richard Trettin 
@since: 	18/11/2014
@Uso: 		OGA430
*/
Static Function DetalheNNC( aItsMrk, nLinMrk )

	Local aSaveArea 	:= GetArea()
	Local oJnl, oFwLayer, oPn, oBrwNNC2
	Local aButtons	:= {}

	Local cCodRom := aItsMrk[ nLinMrk, COL_CODROM ]
	Local cIteRom := aItsMrk[ nLinMrk, COL_ITEROM ]

	oJnl := TDialog():New( 0, 0, 300, 600, STR0030, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Fixações do Romaneio"

	oFwLayer := FwLayer():New()
	oFwLayer:Init( oJnl, .f., .t. )
	oFWLayer:AddLine( 'UP', 100, .F. )
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
	oPn := oFWLayer:GetColPanel( 'ALL', 'UP' )

	oBrwNNC2 := FwMBrowse():New()
	oBrwNNC2:SetOwner( oPn )
	oBrwNNC2:SetAlias( "NNC" )
	oBrwNNC2:SetMenuDef( " " )
	oBrwNNC2:SetFilterDefault( "NNC_CODROM=='"+cCodRom+"' .And. NNC_ITEROM=='"+cIteRom+"'" )
	oBrwNNC2:SetDescription( STR0030+":  "+cCodRom+"  "+cIteRom ) //"Fixações do Romaneio" XXXXXX XXX
	oBrwNNC2:SetOnlyFields( { 'NNC_CODCTR', 'NNC_ITEMFX', 'NNC_CODROM', 'NNC_ITEROM', 'NNC_QTDENT' } )
	oBrwNNC2:SetProfileID( "4" )
	oBrwNNC2:DisableConfig()
	oBrwNNC2:DisableDetails()
	oBrwNNC2:ForceQuitButton()
	oBrwNNC2:Activate()

	//oJnl:Activate( , , , .t., { || .t. }, , { || } )
	oJnl:Activate( , , , .t., {|| .t. }, , { || EnchoiceBar( oJnl, {|| oJnl:End() },{|| oJnl:End() },, @aButtons ) } )

	oBrwNNC2:DeActivate()
	RestArea( aSaveArea )
Return( Nil )

/** {Protheus.doc} OGA430fPRC
Rotina para Chamada da função de composicao de precos OGA420
@param: 	Nil
@author: 	Emerson Coelho
@since: 	02/10/2014
@Uso: 		SIGAARM - Originação de Grãos
*/
Static Function OGA430fPrc()
	Local aAreaAtu 		:= GetArea()
	Local aAreaNJR		:= NJR->( GetArea() )
	Local aCompPrc 		:= {}  //aGrvNKA
	Local oModel 		:= FWModelActive()
	Local oView			:= FwViewActive()
	Local cNjrCodCtr	:= CRIAVAR('NJR_CODCTR', 	.F.) 
	Local cProduto 		:= CriaVar('NJR_CODPRO',	.F.)
	Local cTipoCtr		:= CriaVar('NJR_TIPO',		.F.)  
	Local dDtFixa  		:= oModel:GetValue( "NN8UNICO", "NN8_DATA" 	 )
	Local dDEntrIni		:= oModel:GetValue( "NN8UNICO", "NN8_DATINI" )
	Local dDEntrFim		:= oModel:GetValue( "NN8UNICO", "NN8_DATFIN" )
	Local nQtfixar  	:= oModel:GetValue( "NN8UNICO", "NN8_QTDFIX" )
	Local cITEMFX		:= oModel:GetValue( "NN8UNICO", "NN8_ITEMFX" )
	Local cNk7Aplica 	:= CriaVar('NK7_APLICA',	.F.)
	Local cNjrUm1Pro	:= CriaVar('NJR_UM1PRO',	.F.)
	Local nNjrMoeda		:= CriaVar('NJR_MOEDA',		.F.)
	Local cNjrUmPrc		:= CriaVar('NJR_UMPRC',		.F.)
	Local nOperation	:= oModel:GetOperation()
	Local lEditar 		:= iIF(nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE,.t., .f. )
	Local nPosTotal		:= 0
	Local lContinua		:= .t.
    Local cTipFix		:= oModel:GetValue( "NN8UNICO", "NN8_TIPOFX" ) //TIPO DA FIXAÇÃO //DAGROGAP-1445
    Local cItOrig 		:= IIF( TYPE( "NN8_ITORIG" ) != "U" , oModel:GetValue( "NN8UNICO", "NN8_ITORIG" ) , "") //FIXAÇÃO DE ORIGEM //DAGROGAP-1445

	If cPaisLoc != "PAR" .AND. cPaisLoc != "ARG"
		If !Empty(oModel:GetValue( "NN8UNICO", "NN8_DATREF")) 
			dDtFixa := oModel:GetValue( "NN8UNICO", "NN8_DATREF")
		EndIF
	EndIF
	
	cNjrCodCtr	:= oModel:GetValue( "NN8UNICO", "NN8_CODCTR" )
	DbSelectArea('NJR')
	NJR->(DbSetOrder(1) ) //NJR_FILIAL+NJR_CODCTR
	IF .not. NJR->(DbSeek(FwXfilial('NJR') + cNJRCodCtr ))
		Help( , , STR0011, , STR0056 , 1, 0 ) //"AJUDA"#'Contrado não encontrado'
		lContinua := .f.
	EndIF

	IF lContinua
		cProduto 	:=  NJR->NJR_CODPRO
		cTipoCtr	:=  NJR->NJR_TIPO
		cNk7Aplica 	:=  IIF( cTipoCTR == '1' , 'C', 'V')   // '1' == Ctr. Compra ( NK7_APLICA = 'C'),  '2' == Ctr. Venda ( NK7_APLICA == 'V')
		cNjrUm1Pro	:=  NJR->NJR_UM1PRO
		cNjrUmPrc	:=  NJR->NJR_UMPRC
		nNjrMoeda	:=  NJR->NJR_MOEDA

		IF Len( XaGrvNKA ) == 0
			aCompPrc	:= OGA420NKAR( cNjrCodCtr , cITEMFX ) 	//--<< Le a NKA e Recebe Retorno do Array com os Dados >>--
		Else
			aCompPrc := aClone( XaGrvNKA )
		EndIF 

		//Validar se os Campos que são necessarios Para Chamar a função não estão Vazio
		Do Case
			Case Empty( cProduto  )
			Help( , , STR0011, , STR0036 , 1, 0 ) //"AJUDA"###"Informe produto para o Contrato"
			lContinua := .f.
			Case Empty( dDEntrIni )
			Help( , , STR0011, , STR0037, 1, 0 ) //"AJUDA"###"Informe Data Cadencia para o Contrato"
			lContinua := .f.
			Case Empty( dDEntrFim )
			Help( , , STR0011, , STR0037, 1, 0 ) //"AJUDA"###"Informe Cadencia para o Contrato"
			lContinua := .f.
			Case nQtfixar == 0 .AND. lEditar
			Help( , , STR0011, , STR0040, 1, 0 ) //"AJUDA"###"Informe Qtidade para o Contrato"
			lContinua := .f.
			Case Empty( cNjrUm1Pro )
			Help( , , STR0011, , STR0039, 1, 0 ) //"AJUDA"###"Informe Unidade de medida para o Contrato"
			lContinua := .f.
			Case Empty( nNjrMoeda  )
			Help( , , STR0011, , STR0038, 1, 0 ) //"AJUDA"###"Informe Moeda do Contrato"
			lContinua := .f.
		EndCase

		IF lContinua
			aCompPrc := OGA420( cNjrCodCtr , cProduto , dDtfixa , dDEntrIni , dDEntrFim , nQtfixar , cNk7Aplica, cNjrUm1Pro, cNjrUmPrc, nNjrMoeda, aCompPrc, lEditar, nil, nil, nil, nil, nil, cTipFix, cItOrig)            
			IF lEditar
				XaGrvNKA := aCompPrc
				IF Len ( XaGrvNKA ) > 0 //--<< Encontro onde está o total no Array  NKA_TPVLR == '3' Indica que é Total>>--
					nPosTotal := aSCAN( XaGrvNKA, {|XaGrvNKA| XaGrvNKA[07] == NKATOTAL })
					IF nPosTotal > 0
						//--<< Atualiza NJR_VLRUNI com o Dado que veio da Composição de preço >>-- 
						oModel:SetValue( "NN8UNICO", "NN8_VLRUNI", aCompPrc[nPosTotal,11] ) 		// Seta o vr. na unidade de medida de preço //
						// Utilizado o valid field pois ao confirmar pela segunda vez exibia a msg "Formulário não alterado, não precisa ser salvo"
						// A funcao valid field tambem atribui valor. A diferenca eh que o formulario reconhece a alteracao.
						IF .not. oView = nil
							oView:ValidField("NN8UNICO","NN8_VLRUNI",fWFldGet('NN8_VLRUNI'),.T.)
						EndIF
					EndIF
				EndIF
			EndIF
		EndIF
	EndIF

	RestArea( aAreaAtu )
	RestArea( aAreaNJR )

Return ( lcontinua )


/** {Protheus.doc} fGetImg
Retorna a Imagem ref. a Checado, nao Checado e Diabilitado,
cfe o Vr. do Campo
@param: 	cAux := ( '0' Marcado, '1' Não Marcado, '2' Disabilitado (não pode marcar ou desmarcar) 
@author: 	Emerson Coelho
@since: 	02/10/2014
@Uso: 		SIGAAGR - Equipe Agroindustria
*/
static function fgetimg( cAux )
	Local ochkd		:= LoadBitmap( GetResources(), "checked" )
	Local oUnChKd	:= LoadBitmap( GetResources(), "unchecked" )
	Local oDisable	:= LoadBitmap( GetResources(), "disable.bmp" )

	Local oImg

	IF cAux == '1'
		oImg	:=	oChkd
	ElseIF cAux == '0'
		oImg	:=	oUnChKd
	ElseIF cAux == '2'
		oImg	:=	oDisable
	EndIF
Return ( oImg )


/*/{Protheus.doc} LMLegenda
Monta a legenda dos registros apresentados no Grid.
@author William Matos Gundim Junior.
@since 05/11/2013
@version 11.9
/*/
Function fMLegenda()
	Local oLegenda  :=  FWLegend():New()

	oLegenda:Add("","DISABLE.BMP",	STR0041)
	oLegenda:Add("","",				STR0042)

	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()
Return .T.


/** {Protheus.doc} OG430FTxa
Encontra o Vr. Liq. da Fixação , abatendo os impostos : Funrural,Fethab,Fabov,Facs
@param: 	cTpDoc 	-> Tipo de Documento ('E')->Entrada
cCliFor	-> Fornecedor
cLoja		-> Loja do fornecedor
cProd		-> Proudto
cTES		->	TES
nQtd		-> Qtidade
nVrUni		-> Valor Unitario
@Return	nVrLiqTot	-> Valor Liquido a Receber com Impostos deduzidos;
@author: 	Emerson Coelho
@since: 	02/10/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OG430FTxa(cTpDoc, cCliFor, cLoja, cProd, cTES, nQtd, nVrUni )
	Local nVrLiqTot	 := 0
	Local aAreaAtu	 := getarea()
	Local nValMerc	 := 0
	Local nValAux	 := 0
	Local nSenar     := 0
	Local nValFet    := 0
	Local nValFac    := 0
	Local nFundersul := 0

	Default cTpDoc 	:= "E"
	Default cCliFor	:= "165636549"
	Default cLoja	:= "02"
	Default cProd	:= "030300001"
	Default cTES	:= "001"
	Default nQtd	:= 7000
	Default nVrUni	:= 0.016667

	nValmerc :=	A410ARRED(nQtd * nVrUni, 'D1_TOTAL')

	If cTpDoc == "E" // Docto de Entrada

		//-- Salva situação atual --//
		MaFisSave()
		MaFisEnd()

		//-- Executa regras a respeito da inicialização das regras fiscais caso não estejam inicializadas --/
		If !MaFisFound("NF")	
			dbSelectArea("SA2")
			SA2->(dbSetOrder(1))
			SA2->(dbGoTop())
			SA2->(dbSeek(xFilial("SA2") + cCliFor + cLoja))

			//-- Efetua inicialização das regras fiscais para o calculo --//
			// Inicializa a função fiscal
			// 		Parâmetros da função MaFisIni():
			// 			1-Codigo Cliente/Fornecedor
			// 			2-Loja do Cliente/Fornecedor
			// 			3-C:Cliente , F:Fornecedor
			// 			4-Tipo da NF
			// 			5-Tipo do Cliente/Fornecedor

			MaFisIni(SA2->A2_COD, SA2->A2_LOJA, "F", "N", Nil, MaFisRelImp("MT100",{"SF1","SD1"}),, !.T., NIL, NIL, NIL)
			MaFisAlt("NF_UFORIGEM"	, SA2->A2_EST)
			MaFisAlt("NF_ESPECIE"	, "SPED")

			//-- Posiciona no Codigo do item --//
			dbSelectArea("SB1")
			SB1->(dbSetOrder(1))
			SB1->(dbGoTop())
			SB1->(dbSeek(xFilial("SB1") + cProd ))
			//--Buscando a TES --//
			dbSelectArea("SF4")
			SF4->(dbSetOrder(1))
			SF4->(dbSeek(xFilial("SF4") + cTES ))
			//-- Adiionando os dados do Item ao processamento Fiscal --

			// Agrega os itens para a função fiscal

			// 		Parâmetros da função MaFisAdd():
			// 			1-Codigo do Produto ( Obrigatorio )
			// 			2-Codigo do TES ( Opcional )
			// 			3-Quantidade ( Obrigatorio )
			// 			4-Preco Unitario ( Obrigatorio )
			// 			5-Valor do Desconto ( Opcional )
			// 			6-Numero da NF Original ( Devolucao/Benef )
			// 			7-Serie da NF Original ( Devolucao/Benef )
			// 			8-RecNo da NF Original no arq SD1/SD2
			// 			9-Valor do Frete do Item ( Opcional )
			// 			10-Valor da Despesa do item ( Opcional )
			// 			11-Valor do Seguro do item ( Opcional )
			// 			12-Valor do Frete Autonomo ( Opcional )
			// 			13-Valor da Mercadoria ( Obrigatorio )
			// 			14-Valor da Embalagem ( Opiconal )

			MaFisAdd(SB1->B1_COD, SF4->F4_CODIGO, nQtd, nVrUni, 0, "", "", , 0, 0, 0, 0, nValMerc, 0, SB1->(RecNo()))

			//aSimula := MaFisRet(,"NF_IMPOSTOS")  // -- Armazena os Impostos aqui terá todos os impostos -- //

			nValorDup	  := MaFisRet(,"NF_TOTAL")		//-- Retornando Vr. da Duplicata		--//
			//a composição do funrural é formada por NF_INSS + NF_VLSENAR porém quando a empresa tem 
			//liminar ela paga somente o senar
			nFunRural	  := MaFisRet(,"NF_FUNRURAL")	//-- Retornando Vr. Funrural			--//
			If cPaisLoc <> "PAR" .and. cPaisLoc <> "ARG"
				nSenar	   := MaFisRet(,"NF_VLSENAR")
				//nInss	   := MaFisRet(,"NF_INSS")
				nValFet    := MaFisRet(,"NF_VALFET")		//-- Retornando Vr. Fethab(MT)			--//
				nValFac    := MaFisRet(,"NF_VALFAC")		//-- Retornando Vr. Facs (MT)			--//
				nFundersul := MaFisRet(,"IT_VALFDS")		//-- Retornando Vr. do Fundersul (MS)	--//
			EndIf
			nValFab       := MaFisRet(,"NF_VALFAB")  	//-- Retornando Vr. Fabov				--//

			nValAux		  := IIf(nFunRural=0,nSenar,nFunRural)

			/*/
			!---------------------------------------------------------------------------------------------	!
			!	Atençaõ: 	Não levamos em consideração que na natureza financeira tbem tem varios impostos	! 
			!				a serem deduzidos ou não. Alinhado c. vitor q decidiu nesse momento não tratar 	!
			!				esta questão. ( Para nos basearmos em como fazer isso verificar a rotina 		!
			!				A103ATUSE2 do MATA103)															!	
			!---------------------------------------------------------------------------------------------	!
			/*/

			nVrLiqTot	:= nValorDup -(nValAux - nValFet - nValFab - nValFac - nFundersul)

			MaFisEnd() //-- Finaliza as Funções fiscais --//
		EndIf
	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Executa regras em torno da simulação de impostos através do documento fiscal de saída³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄADÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Executa regras a respeito da inicialização das regras fiscais caso não estejam inicializadas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		If !MaFisFound("NF")
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1))
			SA1->(dbGoTop())
			SA1->(dbSeek(xFilial("SA2") + cCliFor + cLoja))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³Efetua inicialização das regras fiscais para o calculo³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			MaFisIni(SA1->A1_COD, SA1->A1_LOJA, "C", "N", Nil, MaFisRelImp("MT100",{"SF2","SD2"}),, !.T., NIL, NIL, NIL)
			MaFisAlt("NF_UFORIGEM"	, SA1->A1_EST)
			MaFisAlt("NF_ESPECIE"	, "SPED")

			//-- Posiciona no Codigo do item --//
			dbSelectArea("SB1")
			SB1->(dbSetOrder(1))
			SB1->(dbGoTop())
			SB1->(dbSeek(xFilial("SB1") + cProd ))
			//--Buscando a TES --//
			dbSelectArea("SF4")
			SF4->(dbSetOrder(1))
			SF4->(dbSeek(xFilial("SF4") + cTES ))
			//-- Adiionando os dados do Item ao processamento Fiscal --
			// Agrega os itens para a função fiscal

			// 		Parâmetros da função MaFisAdd():
			// 			1-Codigo do Produto ( Obrigatorio )
			// 			2-Codigo do TES ( Opcional )
			// 			3-Quantidade ( Obrigatorio )
			// 			4-Preco Unitario ( Obrigatorio )
			// 			5-Valor do Desconto ( Opcional )
			// 			6-Numero da NF Original ( Devolucao/Benef )
			// 			7-Serie da NF Original ( Devolucao/Benef )
			// 			8-RecNo da NF Original no arq SD1/SD2
			// 			9-Valor do Frete do Item ( Opcional )
			// 			10-Valor da Despesa do item ( Opcional )
			// 			11-Valor do Seguro do item ( Opcional )
			// 			12-Valor do Frete Autonomo ( Opcional )
			// 			13-Valor da Mercadoria ( Obrigatorio )
			// 			14-Valor da Embalagem ( Opiconal )

			MaFisAdd(SB1->B1_COD, SF4->F4_CODIGO, nQtd, nVrUni, 0, "", "", , 0, 0, 0, 0, nValMerc, 0, SB1->(RecNo()))			

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³Compõe array de retorno com as informações³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//aSimula := MaFisRet(,"NF_IMPOSTOS")

			nValorDup	  := MaFisRet(,"NF_TOTAL")		//-- Retornando Vr. da Duplicata		--//
			//a composição do funrural é formada por NF_INSS + NF_VLSENAR porém quando a empresa tem 
			//liminar ela paga somente o senar
			nFunRural	  := MaFisRet(,"NF_FUNRURAL")	//-- Retornando Vr. Funrural			--//
			If cPaisLoc <> "PAR" .and. cPaisLoc <> "ARG"
				nSenar	   := MaFisRet(,"NF_VLSENAR")
				//nInss	   := MaFisRet(,"NF_INSS")
				nValFet    := MaFisRet(,"NF_VALFET")		//-- Retornando Vr. Fethab(MT)			--//
				nValFac    := MaFisRet(,"NF_VALFAC")		//-- Retornando Vr. Facs (MT)			--//
				nFundersul := MaFisRet(,"IT_VALFDS")		//-- Retornando Vr. do Fundersul (MS)	--//
			EndIf
			nValFab       := MaFisRet(,"NF_VALFAB")  	//-- Retornando Vr. Fabov				--//

			nValAux		  := IIf(nFunRural=0,nSenar,nFunRural)

			/*/
			!---------------------------------------------------------------------------------------------	!
			!	Atençaõ: 	Não levamos em consideração que na natureza financeira tbem tem varios impostos	! 
			!				a serem deduzidos ou não. Alinhado c. vitor q decidiu nesse momento não tratar 	!
			!				esta questão. ( Para nos basearmos em como fazer isso verificar a rotina 		!
			!				A103ATUSE2 do MATA103)															!	
			!---------------------------------------------------------------------------------------------	!
			/*/

			nVrLiqTot	:= nValorDup -(nValAux - nValFet - nValFab - nValFac - nFundersul)
			MaFisEnd()		// Finaliza as Funcoes Fiscais de Calculo
		EndIf
	EndIF

	RestArea( aAreaAtu )
	Return ( nVrLiqTot )

	//-------------------------------------------------------------------
	/*/{Protheus.doc} fAtuVrsLiq(oView)
	Rotina Que Atualiza os Vrs. da fixação.
	@author Emerson coelho
	@param oVIEW
	@return lRet
	@since 13/11/2014
	@version 1.0
	/*/
//------------------------------------------------------------------
Static Function fAtuVrsLiq(  )
	Local oModel     	:=	FWModelActive()
	Local nQtfixar		:=	oModel:GetValue( "NN8UNICO", "NN8_QTDFIX" )
	Local nNN8_VlrUni	:= 	oModel:GetValue( "NN8UNICO", "NN8_VLRUNI" )
	Local nPosCpo		:= 	0

	aVrSemImps := {}  		// Conterá Campo e seu respectivo Vr. Campo  aVrSemImps{{'NN8_VALUNI', nValor}}


	IF FWFLDGET('NN8_MOEDA') == 1
		oModel:LoadValue("NN8UNICO", "NN8_TXMOED", 0 )
	EndIF


	aVrSemImps := 	OG430VrSFx(;
	/*Codigo da entidade */	NJR->NJR_CODENT,;
	/*Loja   da entidade */	NJR->NJR_LOJENT,;
	/*Codigo do produto  */	NJR->NJR_CODPRO,;
	/*Un.Medida Produto  */	NJR->NJR_UM1PRO,;
	/*Un.Medida Preço  	 */	NJR->NJR_UMPRC,;			
	/*TES				 */ NJR->NJR_TESEST,;
	/*Qtd a Fiscar		 */	nQtfixar,;
	/*Valor un. na Um Prç*/ nNN8_VlrUni,;
	/*Moeda				 */ FWFLDGET('NN8_MOEDA'),;
	/*Tp Ctrato (2 venda)*/ NJR->NJR_TIPO,;
	/*Dt.fixac/ConvMoeda*/	dDataBase,;
	/*Taxa da moeda		*/  NN8_TXMOED)

	nPosCpo 		:=	ASCAN(aVrSemImps,{|x| x[1] == 'NN8_TXMOED' })
	oModel:SetValue("NN8UNICO", "NN8_TXMOED", aVrSemImps[ nPosCpo,2 ] )

	nPosCpo 		:=	ASCAN(aVrSemImps,{|x| x[1] == 'NN8_VALUNI' })
	oModel:SetValue("NN8UNICO", "NN8_VALUNI", aVrSemImps[ nPosCpo,2 ] ) 	

	nPosCpo 		:=	ASCAN(aVrSemImps,{|x| x[1] == 'NN8_VALTOT' })
	oModel:SetValue("NN8UNICO", "NN8_VALTOT", aVrSemImps[ nPosCpo,2 ] )

	nPosCpo 		:=	ASCAN(aVrSemImps,{|x| x[1] == 'NN8_VALLQT' })
	oModel:SetValue("NN8UNICO", "NN8_VALLQT", aVrSemImps[ nPosCpo,2 ] )	 				

	nPosCpo 		:=	ASCAN(aVrSemImps,{|x| x[1] == 'NN8_VALLIQ' })
	oModel:SetValue("NN8UNICO", "NN8_VALLIQ", aVrSemImps[ nPosCpo,2 ] )

	nPosCpo 		:=	ASCAN(aVrSemImps,{|x| x[1] == 'NN8_VLRTOT' })
	oModel:SetValue("NN8UNICO", "NN8_VLRTOT", aVrSemImps[ nPosCpo,2 ] )

	nPosCpo 		:=	ASCAN(aVrSemImps,{|x| x[1] == 'NN8_VLRLQT' })
	oModel:SetValue("NN8UNICO", "NN8_VLRLQT", aVrSemImps[ nPosCpo,2 ] )

	nPosCpo 		:=	ASCAN(aVrSemImps,{|x| x[1] == 'NN8_VLRLIQ' })
	nVlrLiq			:= aVrSemImps[ nPosCpo,2 ]
	oModel:SetValue("NN8UNICO", "NN8_VLRLIQ", aVrSemImps[ nPosCpo,2 ] )



	//oView:Refresh()
Return ( nVlrLiq )

/*---------------------------------------------------------------------------------------------------
{Protheus.doc} fmarkAll
Rotina para Marcar / DesMarcar Todos Seguindo a Regra de negocio, onde
não podemos Marcar romaneios de forma que se exceda a qtidade da fixação
e ainda em alguns casos ter que vincular um romaneio de forma parcial
para fechar a qtd. entregue com a qtd fixada. 
@author Agro
@param 	aRomaneios	(array contendo os romaneios q o browse ira mostrar);
pnOpc 		(Contendo 1 Vem da ação relacionada Vincular, 2 Vem da açao relacionada Desvincular) 
@return oBrowse Atualizado
@since 05/08/2015
@version 1.0
----------------------------------------------------------------------------------------------------*/
Static Function fMarkAll( aRomaneios, pnOpc )
	Local nI			:= 1
	Local cMarca		:= '' 	// '1' -> Indica que stá selecionado, '0'-> Indica que não stá selecionado
	Local cTipo := VALTYPE( aRomaneios )

	cMarca := IIF(_lMarkAll,'0','1') 	//_lMarkAll == .t. Indica que todos estão vinculados.

	If cTipo == "O"
		aRomaneios := aRomaneios:AARRAY
	EndIF

	For nI := 1 to Len( aRomaneios ) Step 1
		IF ! aRomaneios[ nI, COL_MARK ] == cMarca
			// Utilizo o MarcaUm para manter a logica de poder marcar somente romaneios até 
			// atingir o vr. da fixação e tbem ter que utilizar a qtidade de um romaneio de 
			//forma parcial  
			MarcaUm( aRomaneios, nI, pnOpc, .t. ) 
		EndIF
	Next nI

	_lMarkAll := !_lMarkAll

	onSldEnt:Refresh()
	onQtdMrk:Refresh()
	oBrowse:Refresh()

	Return( nil )

	//-------------------------------------------------------------------
	/*/{Protheus.doc} OGA430FVINC()
	Rotina de Chamada da Função de Vinc/Desvinc de acordo com o	tipo do Contrato ( Venda ou Compra )
	@author Emerson coelho
	@param nOpcao = 1  = Vincular , 2 = Desvincular
	@return lRet
	@since 13/11/2014
	@version 1.0
	/*/
//------------------------------------------------------------------
Static Function OGA430FVINC( nOpcao )
	Local lCtrVnd		:= IIF( Posicione( "NJR", 1, xFilial( "NJR" ) + NN8->NN8_CODCTR, "NJR_TIPO" ) == '2', .t., .f. ) //1 Cpra , 2 Venda
	Local  cChamar		:= ''

	IF lCtrVnd // se Ctrato de Venda
		cChamar := 'OGA430FVND(' + cValToChar(nOpcao) + ')'
	Else // Senao é Ctrato de Compra
		cChamar := 'OGA430FCPR(' + cvaltochar(nOpcao) + ')'
	EndIF
	&cChamar //-- Executa a Funcao --
Return ( nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} fMontaTela
Rotina que monta a Tela para selecionar
os romaneios a Vincular/Desvincular a uma Fixação
@author Emerson coelho
@param 	nOpcao 		->	1  = Vincular;
->	2 = Desvincular;
aAux		->	aRray com os Romaneios a Vincular ou Desnvicular;
nQtdMrkAux 	-> Contem a Qtidade Já vinculada Relacionado ao Item de Fixação;
@return lRet
@since 13/11/2014
@version 1.0
/*/
Static Function fMontaTela(PnOpc, aAux, nQtdMrkAux)
	Local oSize			:= Nil
	Local oDlg			:= Nil
	Local oPnUm			:= Nil
	Local aButtons		:= {}
	Local lOk			:= .F.
	Local cCodCtr 		:= NN8->NN8_CODCTR
	Local cItemFx		:= NN8->( NN8_ITEMFX )

	Private nQtdFix		:= NN8->( NN8_QTDFIX )
	Private nQtdEnt		:= NN8->( NN8_QTDENT )
	Private nSldEnt		:= NN8->( NN8_QTDFIX ) - NN8->( NN8_QTDENT )
	Private nQtdMrk		:= nQtdMrkAux
	Private onQtdMrk, onQtdEnt
	Private oBrowse	:= Nil
	Private _lMarkAll	:= .f.		//Variavel de controle Se estão todos marcados ou Não

	// Retirado Emerson 11/05/2016 aAdd(aButtons, { "", { || EditQtd( pnOpc )	}, OemToAnsi( "Editar Qtde." ) } ) //"Editar Qtde."	
	aAdd(aButtons, { "", { || fMLegenda() 			}, OemToAnsi( STR0055 ) } ) 		//"Legenda"

	//// Montagem da tela ////
	oSize := FwDefSize():New()
	oSize:AddObject( "P1", 60, 80, .t., .t., .t. )
	oSize:lProp := .t.
	oSize:aMargins := { 3, 3, 3, 3 }
	oSize:Process()

	oDlg    := TDialog():New( 0, 0, 450, 780, iIf(pnOpc==1, STR0019, STR0020),,,,, CLR_BLACK, CLR_WHITE,,, .t. ) //#"Vinculação de Documentos com a Fixação",#"Desvinculação de Documentos com a Fixação"
	oPnUm 	:= tPanel():New( 60, 3, "", oDlg,,,, CLR_BLACK, CLR_WHITE, 385, 160 )
	oBrowse := TCBrowse():New( 01, 01, 200, 156, , , , oPnUm, , , , , , , , , , , , .f., ,.t., , .f. )

	cTitleCol1	:= ""
	cTitleCol2	:= STR0021 		//#"Fixação"
	cTitleCol3	:= STR0022 		//# "Romaneio"
	cTitleCol4	:=	STR0023 	//#"Item Rom."
	cTitleCol5	:=	STR0024		//#"Qtd. Fiscal"
	cTitleCol6	:= STR0025		//#"Qtd. Entregue"
	cTitleCol7	:= STR0026		//#"Sld. a Vinc. Entr."
	cTitleCol8  := IIF(pnOpc ==1, STR0027, STR0028)	//#"Qtd. a Vincular",#"Qtd. Vinculada")
	cTitleCol9  := STR0057		//#"Qtd. Física"
	oBrowse:AddColumn( TCColumn():New( cTitleCol1,  { || fGetImg( aAux[oBrowse:nAt, COL_MARK ] )}                                 ,,,,"CENTER", ,.t.,.t.,,,,.f.,) )
	oBrowse:AddColumn( TCColumn():New( cTitleCol2,	{ || aAux[ oBrowse:nAt, COL_ITEMFX 		] }									,,,,"LEFT"	, ,.f.,.t.,,,,.f.,) ) //"Fixação"
	oBrowse:AddColumn( TCColumn():New( cTitleCol3,	{ || aAux[ oBrowse:nAt, COL_CODROM		] }									,,,,"LEFT"	, ,.f.,.t.,,,,.f.,) ) //"Romaneio"
	oBrowse:AddColumn( TCColumn():New( cTitleCol4,	{ || aAux[ oBrowse:nAt, COL_ITEROM		] }									,,,,"LEFT"	, ,.f.,.t.,,,,.f.,) ) //"Item Rom."
	oBrowse:AddColumn( TCColumn():New( cTitleCol5,	{ || Transform( aAux[ oBrowse:nAt, COL_QTDFIS ]	, "@E 999,999,999,999" ) }	,,,,"RIGHT"	, ,.f.,.t.,,,,.f.,) ) //"Qtd. Fiscal"
	oBrowse:AddColumn( TCColumn():New( cTitleCol9,	{ || Transform( aAux[ oBrowse:nAt, COL_QTDFCO ]	, "@E 999,999,999,999" ) }	,,,,"RIGHT"	, ,.f.,.t.,,,,.f.,) ) //"Qtd. Fisico"
	oBrowse:AddColumn( TCColumn():New( cTitleCol6,	{ || Transform( aAux[ oBrowse:nAt, COL_QTDENT ]	, "@E 999,999,999,999" ) }	,,,,"RIGHT"	, ,.f.,.t.,,,,.f.,) ) //"Qtd. Entregue"
	oBrowse:AddColumn( TCColumn():New( cTitleCol7,	{ || Transform( aAux[ oBrowse:nAt, COL_SLDENT ]	, "@E 999,999,999,999" ) }	,,,,"RIGHT"	, ,.f.,.t.,,,,.f.,) ) //"Sld. a Vinc. Entr."
	oBrowse:AddColumn( TCColumn():New( cTitleCol8,	{ || Transform( aAux[ oBrowse:nAt, COL_QTDMRK ]	, "@E 999,999,999,999" ) }	,,,,"RIGHT"	, ,.f.,.t.,,,,.f.,) ) //"Qtd. a Vincular"
	////oBrowse:AddColumn( TCColumn():New( " "  					, { || aAux[ oBrowse:nAt, COL_VAZIO	] }												,,,,"LEFT"		, ,.f.,.t.,,,,.f.,) )

	oBrowse:SetArray( aAux )
	oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowse:bLDblClick := {|| MarcaUm( aAux, oBrowse:nAt, pnOpc ) }
	oBrowse:bHeaderClick := { |aAux, pnOpc| iif(pnOpc == 1, fMarkAll(aAux, pnOpc),) }

	oSay0	 := TSay():New( 034, 005, {|| OemToAnsi( RetTitle( "NN8_CODCTR" )+": "+cCodCtr+"    "+RetTitle( "NN8_ITEMFX" )+": "+cItemFx ) }, oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 150, 010 ) //Contrato: XXXXXX     Item Fix.: XXX
	oSay1	 := TSay():New( 034, 140, {|| OemToAnsi( RetTitle( "NN8_QTDFIX" )+":" ) }													   , oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 050, 010 ) //"Qtd. Fixada"
	oSay11	 := TSay():New( 034, 190, {|| OemToAnsi( Transform( nQtdFix, PesqPict("NN8","NN8_QTDFIX") ) ) }								   , oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 060, 010 )
	oSay2	 := TSay():New( 034, 250, {|| OemToAnsi( RetTitle( "NN8_QTDENT" )+":" ) }													   , oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 050, 010 ) //"Qtd.Entregue"
	oSay2	 := TSay():New( 034, 300, {|| OemToAnsi( Transform( nQtdEnt, PesqPict("NN8","NN8_QTDFIX") ) ) }								   , oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 060, 010 )
	oSay3	 := TSay():New( 044, 140, {|| OemToAnsi( STR0026+":" ) } 																	   , oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 050, 010 ) //"Sld. a Vinc. Entr."
	onSldEnt := TSay():New( 044, 190, {|| OemToAnsi( Transform( nSldEnt, PesqPict("NN8","NN8_QTDFIX") ) ) } 							   , oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 060, 010 )
	///oSay4 	:= TSay():New( 014, 250, {|| OemToAnsi( "Qtd. a Vincular"+":" ) } 														   , oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 050, 010 ) //"Qtd. a Vincular"
	oSay4	 := TSay():New( 044, 250, {|| IIF(pnOpc ==1, STR0027, STR0029)+":"  } 														   , oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 050, 010 ) //#"Qtd. a Vincular","Qtd. a Desvincular")
	onQtdMrk := TSay():New( 044, 300, {|| OemToAnsi( Transform( nQtdMrk, PesqPict("NN8","NN8_QTDFIX") ) ) }								   , oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 060, 010 )

	//Instrui a trazer os roameneios marcados
	fMarkAll(aAux, pnOpc)

	oDlg:Activate( , , , .t., {|| .t. }, , { || EnchoiceBar( oDlg, {|| lOk := .T., oDlg:End() },{|| lOk := .F., oDlg:End() },, @aButtons ) } )

Return ( lok )	


/** {Protheus.doc} OG430VrSFx
Encontra Vrs. da Fixacao, Baseado na fAtuVrsLiq() do OGA430F
Retirandos os Impostos como FUNRURAL, Etc.
@param:    	cCodEnt	-> Cod. da Entidade
cLjaEnt	-> Lja da Entidade
cCodProd-> Codigo do produto
cUm1Pro	-> Unidade Medida 1 do produto
cUmPrc	-> Unidade medida de preço do produto
cTes	-> Codigo da TES do contrato
nQtdFix	-> Qtidade a Fixar
nVlrUni	-> Vr. Unitario na UM. Preço ( Ex. Um produto KG, UM preco S6 Sacas de 60 kgs.)
nMoeda	-> Moeda da Fixação
cTpCtrto-> Tipo de Contrato
Dt. para conversao da moeda
nTxMoedTel->Taxa de Conversão a utilizar

@Retorno   	Array contento os cpos de Vrs. Para a Fixação.			
@author:     Emerson Coelho
@since:     02/10/2014
@Uso:         SIGAAGR - Originação de Grãos
*/
Function OG430VrSFx(cCodEnt,cLjaEnt,cCodPro,cUM1Pro,cUmPrc,cTes,nQtdFix,nVlrUni, nMoeda,cTpCtrto,dDtFixa,nTxMoedTel )
	
	Local nTxMoed 		:= 0
	Local nVlrTot		:= 0
	Local nVlrLiq		:= 0
	Local nValUni		:= 0
	Local nValTot		:= 0
	Local nValLiq		:= 0
	Local nVrUnLiq		:= 0
	Local aVrSemImps	:= {} // Array de Retorno   

	//-- Vars da Função OG430TXA	--//    
	Local cClifor		:= ''
	Local cCliforLja	:= ''
	Local cproduto		:= cCodPro
	Local nVrTotLiq		:=	0
	Local cTpdoc		:=''

	Default nTxMoedTel	:= 0

	IF nMoeda == 1
		nTxMoed	:= 0
	ElseIF nTxMoedTel > 0 
		nTxMoed :=  nTxMoedTel
	Else
		nTxMoed	:= xMoeda(1, nMoeda ,1, dDtfixa, TamSX3("NN8_TXMOED")[2] )
	EndIF

	// -- Encontra Fornecedor ou Cliente ----------------------------------------------------------------------
	IF cTpCtrto == '1'
		cClifor		:= Posicione("NJ0",1,FwxFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0->NJ0_CODFOR")	// Cod Forn.
		cCliforLja	:= Posicione("NJ0",1,FwxFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0->NJ0_LOJFOR")	// Loja Forn
		cTpDoc		:= 'E'
	ElseIF cTpCtrto == '2'
		cClifor		:= Posicione("NJ0",1,FwxFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0->NJ0_CODCLI")	// Cod 	Cliente
		cCliforLja	:= Posicione("NJ0",1,FwxFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0->NJ0_LOJCLI")	// Loja Cliente
		cTpDoc		:= 'S'	   
	EndIF
	//----------------------------------------------------------------------------------------------------------

	nVrTotLiq		:= OG430FTxa(cTpDoc, cClifor, cCliforLja, cProdUTO, cTES, nQtdFix, nVlrUni ) // Vr. Liq. Total da Fixaxao ( Verifique os Impostos Retidos )

	nVrUnLiq		:= Round( (nVrtotLiq / nQtdFix), TamSX3("NN8_VLRLIQ")[2] ) 			//--Encontro valor Unitario Liquido--//
 
	If nMoeda = 1
	
		nVlrTot := OGA420TOT(nVlrUni, nQtdFix, AGRX001( cUmPrc,cUM1Pro ,1, /*cProduto*/ )) //Garantindo integridade entre UMProduto, e UMPRC
		nValUni := nVlrUni
		nValTot := OGA420TOT(nValUni, nQtdFix, AGRX001( cUmPrc,cUM1Pro ,1, /*cProduto*/ )) //Garantindo integridade entre UMProduto, e UMPRC
		///nVlrLiq := nValLiq
		nVlrLiq	:= nVrUnLiq
		nValLiq	:= nVrUnLiq
	Else
		nVlrTot 	:= Round( nVlrUni * AGRX001( cUm1Pro, cUmPrc, nQtdFix, cproduto ) ,2 ) //Garantindo integridade entre UMProduto, e UMPRC
		nVlrLiq	:= nVrUnLiq

		If nTxMoedTel <= 0
			nValUni := Round(xMoeda( nVlrUni, nMoeda, 1, dDataBase,TamSX3("NN8_TXMOED")[2] ),TamSX3("NN8_VALUNI")[2] )
		Else
			nValUni := Round(nVlrUni / nTxMoed, TamSX3("NN8_VALUNI")[2] )
		EndIf
		nValTot := Round( nValUni * AGRX001( cUm1Pro, cUmPrc, nQtdFix, cproduto ) ,2 )  //Garantindo integridade entre UMProduto, e UMPRC

		If nTxMoedTel <= 0
			nValliq := Round(xMoeda( nVlrliq, 1, nMoeda, dDataBase,TamSX3("NN8_TXMOED")[2] ), TamSX3("NN8_VALLIQ")[2] ) 
		Else
			nValLiq := Round(nVlrliq / nTxMoed, TamSX3("NN8_VALLIQ")[2] )
		EndIf

	EndIf

	aVrSemImps := {}

	aAdd(aVrSemImps,{'NN8_TXMOED',nTxMoed} )  //Vr. Unitario 	2a Moeda
	aAdd(aVrSemImps,{'NN8_VALUNI',nValUni} )  //Vr. Unitario 	2a Moeda
	aAdd(aVrSemImps,{'NN8_VALTOT',nValTot} )  //Vr. Total Bruto 2a Moeda
	aAdd(aVrSemImps,{'NN8_VALLIQ',nValLiq} )  //Vr. Liq S/iMPS	2a Moeda
	aAdd(aVrSemImps,{'NN8_VALLQT',a410Arred(nValTot * (nValLiq / nValUni),"D1_TOTAL")} ) //Vr.Liq S/Imps OM. Moeda

	aAdd(aVrSemImps,{'NN8_VLRUNI',nVlrUni} )  	//Vr. Unitario 	1a Moeda
	aAdd(aVrSemImps,{'NN8_VLRTOT',nVlrTot} )	//Vr. Total 1a. Moeda
	aAdd(aVrSemImps,{'NN8_VLRLIQ',nVlrLiq} )	//Vr. Liq	1a. Moeda
	aAdd(aVrSemImps,{'NN8_VLRLQT',a410Arred(nVlrTot * (nVlrLiq / nVlrUni),"D1_TOTAL")} ) // Vr. Liq S/Imps 1a. Moeda

Return( aVrSemImps )

/** {Protheus.doc} fRateiaDsp()
__Função que Rateia Frete/Seguro/Despesas acessorias
na Qtd. Fixada
__	 O ERP nas devoluções n. devolve Vr. de Frete, portanto
sempre considero o Valor total das depspesas mesmo que se teve
devolução ( D1_VALFRE/ D1_SEGURO / D1_DESPESA)

@param:    	cCodCtr		-> codigo do contrato do Romaneio sendo vinculado
cCodrom		-> Codigo do Romaneio Sendo vinculado
cIterom		-> Item do romaneio sendo vinculado
nQtdNF		-> Quantidade Ref. a Despesa no Docto Fiscal
nQtdFix		-> Qtidade Fiscal = D?_quant - D?_QTDDEV   ( Qtd. Total a Considerar na fixação )
nQtdfix		-> Quantidade Fixada deste docto Fiscal
nFreteNF	-> Vr. do Frete  do	Docto Fiscal
nSeguroNF	-> Vr. do Seguro do	Docto Fiscal
nDespesaNF	-> Vr. de Otrs. Desps. do Docto. Fiscal
nVrFretFix	-> Vr. do Frete  da Fixação Contendo 0 Passado Como Ponteiro
nVrSegufix	-> Vr. do Seguro da Fixação Contendo 0 Passado Como Ponteiro
nVrDespFix	-> Vr. da Despes da Fixação Contendo 0 Passado Como Ponteiro
@Retorno   	Variaveis Passadas como Ponteiro nVrFreFix,nVrSegfix,nVrSegfix Atualizadas		
@author:    Emerson Coelho
@since:     08/02/2016
@Uso:         SIGAAGR - Originação de Grãos
*/

Static Function fRateiaDsp(cCodCtr,cCodRom,cIteRom ,nQtdNF,nQtdFis,nQtdFix,nFreteNF,nSeguroNF,nDespesaNF,nVrFretFix,nVrSegufix,nVrDespFix)
	Local aAreaAtu		:= GetArea()
	Local aAreaNNC		:= NNC->( GetArea() )
	Local nAuxFrete 	:= A410Arred( nFreteNF   * (  nQtdFix / nQtdNF),'D1_TOTAL' )
	Local nAuxSeguro	:= A410Arred( nSeguroNF  * (  nQtdFix / nQtdNF),'D1_TOTAL' )
	Local nAuxDespes	:= A410Arred( nDespesaNF * (  nQtdFix / nQtdNF),'D1_TOTAL' )
	Local lMultFixs		:= .f.
	Local cNNCIdx2		:= ''

	// -- Vars. Auxilo para Encontrar Qtds/Vrs.Despesas do Romaneio em outras Fixações 	--//
	Local nQtdFixRom	:= 0	
	Local nFreFixRom	:= 0
	Local nSegFixRom	:= 0
	Local nDspFixRom	:= 0 
	//-- 																				--//														

	IF ! nQtdfix = nQtdFis   // Qtidade fixada Diferente da Quantidade a Considerar do Docto, Indica que o Romaneio Participa de Multiplas Fixações)
		lMultFixs := .t.
	EndIF 

	IF lMultfixs    // Verifico se Este vinculo É Totaliza o Qtd. Fiscal toda ou Somente um pedaço
		dbSelectArea( "NNC" )
		NNC->(dbSetOrder( 2 ))	//NNC_FILIAL+NNC_CODCTR+NNC_CODROM+NNC_ITEROM
		cNNCIdx2 :=  fWXFilial("NNC") + cCodCtr + cCodRom + cIteRom

		nQtdFixRom	:= 0	
		nFreFixRom	:= 0
		nSegFixRom	:= 0
		nDspFixRom	:= 0

		If NNC->(dbSeek( cNNCIdx2 ))
			While NNC->( !eof() ) .and. NNC->(NNC_FILIAL+NNC_CODCTR+NNC_CODROM+NNC_ITEROM) == cNNCIdx2
				nQtdFixRom	+= NNC->NNC_QTDFIX	
				nFreFixRom	+= NNC->NNC_VLFRET
				nSegFixRom	+= NNC->NNC_VLSEGU
				nDspFixRom	+= NNC->NNC_VLDESP
				NNC->( dbSkip() ) 
			EnddO
		EndIF

		IF nQtdFis == (nQtdFixRom + nQtdfix)  	// Se a Qtidade Ja Fixada desse romaneio + q Qtidade q Está Sendo Fixada for Igual a Qtd. Fiscal
			// Indica que Toda Qt. do romaneio está sendo Utilizada, Então Garanto q o Vr. das Depsesas
			// Frete/Seguro/Despesas Sejam Iguais as do Docto fiscal efetuando possiveis ajuste de arred. do calc.
			nAuxFrete 	:= nFreteNF		- nFreFixRom
			nAuxSeguro	:= nSeguroNF	- nSegFixRom
			nAuxDespes	:= nDespesaNF	- nDspFixRom
		EndIF 
	EndIF

	// -- Alimentando Variaveis Passadas como Ponteiro -- //
	nVrFretFix 	:= nAuxFrete
	nVrSegufix	:= nAuxSeguro
	nVrDespFix	:= nAuxDespes

	RestArea( aAreaAtu )
	RestArea( aAreaNNC )
Return()


/** {Protheus.doc} fQryRomCpr()
Função q Monta a Qry dos romaneios, ref. a contrato de Compra a
Serem vinculados ou Desvinculados;

@param:    	-> PnOpc		-> 1 = Vinculando / 2=Desvinculando
@Retorno   	-> Alias da Query		
@author:    Emerson Coelho
@since:     08/02/2016
@Uso:         SIGAAGR - Originação de Grãos
*/
STatic Function	fQryRomCpr( pnOPc, cCodCtr, cNN8_ITEMFX )
	Local cAliasQry		:= GetNextAlias()
	Local cWhere		:= ''
	Local cFilRomDe     := IIf(Empty(xFilial("NJR")),Replicate( " ", TamSX3("NJJ_FILIAL")[1] ),xFilial("NJJ"))  //"Filial De"
	Local cFilRomAte    := IIf(Empty(xFilial("NJR")),Replicate( "Z", TamSX3("NJJ_FILIAL")[1] ),xFilial("NJJ")) 	//"Filial Ate"		
	Local cFilSD1De     := IIf(Empty(xFilial("NJR")),Replicate( " ", TamSX3("D1_FILIAL")[1]  ),xFilial("SD1"))  //"Filial De"
	Local cFilSD1Ate    := IIf(Empty(xFilial("NJR")),Replicate( "Z", TamSX3("D1_FILIAL")[1]  ),xFilial("SD1"))  //"Filial Ate"
	Local cFilNNCDe     := IIf(Empty(xFilial("NJR")),Replicate( " ", TamSX3("NNC_FILIAL")[1] ),xFilial("NNC"))  //"Filial De"
	Local cFilNNCAte    := IIf(Empty(xFilial("NJR")),Replicate( "Z", TamSX3("NNC_FILIAL")[1] ),xFilial("NNC"))  //"Filial Ate"
	Local cFilNJ0De     := IIf(Empty(xFilial("NJR")),Replicate( " ", TamSX3("NJ0_FILIAL")[1] ),xFilial("NJ0"))  //"Filial De"
	Local cFilNJ0Ate    := IIf(Empty(xFilial("NJR")),Replicate( "Z", TamSX3("NJ0_FILIAL")[1] ),xFilial("NJ0"))  //"Filial Ate"
	Local cProdCTR      := Posicione("NJR",1,xFilial("NJR")+cCodCtr,"NJR_CODPRO")

	cWhere := "%"
	cWhere += "		SD1.D1_FILIAL 	>= '" + cFilSD1De + "' "
	cWhere += "	AND	SD1.D1_FILIAL 	<= '" + cFilSD1Ate + "' "
	cWhere += " AND	SD1.D1_CTROG 	= '" + cCodCtr + "'"
	cWhere += " AND	SD1.D1_COD 	    = '" + cProdCTR + "'"
    cWhere += " AND NJJ.NJJ_CODPRO  = '" + cProdCTR + "'"
	cWhere += " AND	SD1.D1_TES   	= NJM.NJM_TES "				// -- Garanto q o D1_tes Seja Igual a Tes do Romaneio, Para evitar retorno no d1 de nfs. de transito --//
	cWhere += " AND	(SD1.D1_QUANT 	- SD1.D1_QTDEDEV > 0) "  	//Garantindo que o roamenio n. esta com a Qtidade toda devolvida ou n. tem qtd. Zerada
	cWhere += " AND	SD1.D1_TIPO 	= 'N' " 
	cWhere += " AND	SD1.D_E_L_E_T_ = ' ' "

	IF pnOpc == 2	//Considerando Apenas itens que já estão vinculados
		cWhere += " AND    ( "
		cWhere += " 	SELECT " 
		cWhere += " 	SUM(NNC_QTDFIX) FROM " + RETSQLTAB("NNC")  	//-- Repeti o Sql q gera a Coluna Qtvinculad, para filtrar somente itens q possuem qtvinc. > 0
		cWhere += "		WHERE	NNC.NNC_CODCTR = SD1.D1_CTROG  "
		cWhere += "		AND 	NNC.NNC_CODROM = SD1.D1_CODROM "
		cWhere += "		AND 	NNC.NNC_ITEROM = SD1.D1_ITEROM "
		cWhere += "		AND		NNC.NNC_FILIAL >= '" + cFilNNCDe  + "' "
		cWhere += "		AND		NNC.NNC_FILIAL <= '" + cFilNNCAte + "' "
		cWhere += " 	AND     NNC.NNC_ITEMFX = '" + cNN8_ITEMFX 	+ "' "		//-- So é relevante o que é da fixação selecionada --//
		cWhere += "		AND		NNC.D_E_L_E_T_ = ' ' "
		cWhere += ") > 0 "
		cWhere += "%"
	Else
		cWhere += "%"
	EndIF

	BeginSql Alias cAliasQry
	Select
	(
	SELECT SUM(NNC_QTDFIX) FROM %Table:NNC% NNC
	WHERE	NNC.NNC_CODCTR = SD1.D1_CTROG
	AND 	NNC.NNC_CODROM = SD1.D1_CODROM
	AND 	NNC.NNC_ITEROM = SD1.D1_ITEROM
	AND	NNC.NNC_FILIAL >= %Exp:cFilNNCDe% 
	AND	NNC.NNC_FILIAL <= %Exp:cFilNNCAte% 
	AND 	NNC.%NotDel%
	) AS QTVINCULAD,
	SD1.R_E_C_N_O_ AS D1_RECNO,
	SD1.*,
	NJM.NJM_QTDFCO, NJM.NJM_QTDFIS, 
	NJJ.NJJ_PESO3, NJJ.NJJ_TPCLAS
	FROM  %Table:SD1C% SD1
	LEFT JOIN %Table:NJ0% NJ0 	
	ON 	NJ0.NJ0_CODFOR 	= SD1.D1_FORNECE
	AND	NJ0_LOJFOR 		= SD1.D1_LOJA
	AND NJ0.NJ0_FILIAL 	>= %Exp:cFilNJ0De% 
	AND NJ0.NJ0_FILIAL 	<= %Exp:cFilNJ0Ate% 
	AND NJ0.%NotDel%
	LEFT JOIN %Table:NJM% NJM	
	ON 	NJM.NJM_DOCSER	= SD1.D1_SERIE
	AND	NJM.NJM_DOCNUM 	= SD1.D1_DOC
	AND NJM.NJM_CODENT 	= NJ0_CODENT
	AND  NJM.NJM_LOJENT	=  NJ0.NJ0_LOJENT
	AND NJM.NJM_FILIAL 	>= %Exp:cFilRomDe% 
	AND NJM.NJM_FILIAL 	<= %Exp:cFilRomAte% 
	AND	NJM.%NotDel%
	LEFT JOIN %Table:NJJ% NJJ 
	ON  NJJ.NJJ_FILIAL 	= NJM.NJM_FILIAL
	AND NJJ.NJJ_CODROM	= NJM.NJM_CODROM
	AND	NJJ.%NotDel%
	WHERE
	%EXP:cWhere%
	ORDER BY SD1.D1_EMISSAO, NJM.NJM_CODROM
	EndSql	
Return( cAliasQry )


/** {Protheus.doc} fQryRomVnd()
Função q Monta a Qry dos romaneios, ref. a contrato de Venda  a
Serem vinculados ou Desvinculados;

@param:    	-> PnOpc		-> 1 = Vinculando / 2=Desvinculando
@Retorno   	-> Alias da Query		
@author:    Emerson Coelho
@since:     08/02/2016
@Uso:         SIGAAGR - Originação de Grãos
*/
Static Function	fQryRomVnd( pnOPc, cCodCtr, cNN8_ITEMFX )
	Local cAliasQry		:= GetNextAlias()
	Local cQuery		:= ''
	Local cFilRomDe     := IIf(Empty(xFilial("NJR")),Replicate( " ", TamSX3("NJJ_FILIAL")[1] ),xFilial("NJJ"))  //"Filial De"
	Local cFilRomAte    := IIf(Empty(xFilial("NJR")),Replicate( "Z", TamSX3("NJJ_FILIAL")[1] ),xFilial("NJJ")) 	//"Filial Ate"		
	Local cFilSD2De     := IIf(Empty(xFilial("NJR")),Replicate( " ", TamSX3("D2_FILIAL")[1]  ),xFilial("SD2"))  //"Filial De"
	Local cFilSD2Ate    := IIf(Empty(xFilial("NJR")),Replicate( "Z", TamSX3("D2_FILIAL")[1]  ),xFilial("SD2"))  //"Filial Ate"
	Local cFilNNCDe     := IIf(Empty(xFilial("NJR")),Replicate( " ", TamSX3("NNC_FILIAL")[1] ),xFilial("NNC"))  //"Filial De"
	Local cFilNNCAte    := IIf(Empty(xFilial("NJR")),Replicate( "Z", TamSX3("NNC_FILIAL")[1] ),xFilial("NNC"))  //"Filial Ate"
	Local cFilNJ0De     := IIf(Empty(xFilial("NJR")),Replicate( " ", TamSX3("NJ0_FILIAL")[1] ),xFilial("NJ0"))  //"Filial De"
	Local cFilNJ0Ate    := IIf(Empty(xFilial("NJR")),Replicate( "Z", TamSX3("NJ0_FILIAL")[1] ),xFilial("NJ0"))  //"Filial Ate"
	Local lN8K			:= AGRTABDIC({"N8K"}) //verifica se tabela N8K existe, tabela liberado P12.1.23
	Local cProdCtr      := Posicione("NJR",1,xFilial("NJR")+cCodCtr,"NJR_CODPRO")

	//BeginSql Alias cAliasQry
	cAliasQry := GetNextAlias()
	cQuery := " Select "
	cQuery += " ( "
	cQuery += " 	SELECT SUM(NNC_QTDFIX) FROM " + RetSqlName("NNC") + " NNC "
	cQuery += " 	WHERE	NNC.NNC_CODCTR = N8K.N8K_CODCTR "
	cQuery += " 		AND 	NNC.NNC_CODROM = N8K.N8K_CODROM "
	cQuery += " 		AND 	NNC.NNC_ITEROM = N8K.N8K_ITEROM "
	cQuery += " 		AND 	NNC.NNC_FILIAL >= '"+cFilNNCDe+"' "
	cQuery += " 		AND		NNC.NNC_FILIAL <= '"+cFilNNCAte+"' "
	cQuery += "			AND	NNC.D_E_L_E_T_ = '' "
	cQuery += " ) AS QTVINCULAD, "
	cQuery += " SD2.R_E_C_N_O_ AS D2_RECNO, "
	cQuery += " SD2.*, " 
	cQuery += " NJM.NJM_QTDFCO, NJM.NJM_QTDFIS, " 
	cQuery += " NJJ.NJJ_PESO3, NJJ.NJJ_TPCLAS, "
	cQuery += " N8K.N8K_CODCTR, "
	cQuery += " N8K.N8K_SAFRA, "
	cQuery += " N8K.N8K_CODROM, "
	cQuery += " N8K.N8K_ITEROM "
	cQuery += " FROM  " + RetSqlName("SD2") + " SD2 "
	cQuery += " INNER JOIN " + RetSqlName("N8K") + " N8K " 
	cQuery += " 	ON  N8K.N8K_FILIAL 	= SD2.D2_FILIAL "
	cQuery += " 	AND N8K.N8K_DOC 	= SD2.D2_DOC "
	cQuery += " 	AND N8K.N8K_SERIE 	= SD2.D2_SERIE "
	cQuery += " 	AND N8K.N8K_CLIFOR 	= SD2.D2_CLIENTE "
	cQuery += " 	AND N8K.N8K_LOJA 	= SD2.D2_LOJA "
	cQuery += " 	AND N8K.N8K_ITEDOC 	= SD2.D2_ITEM "
	cQuery += " 	AND N8K.N8K_PRODUT 	= SD2.D2_COD "
	cQuery += " 	AND N8K.D_E_L_E_T_ = '' "	
	cQuery += " LEFT JOIN " + RetSqlName("NJ0") + " NJ0 " 
	cQuery += " 	ON 	NJ0.NJ0_CODCLI 	= SD2.D2_CLIENTE "
	cQuery += " 	AND NJ0_LOJCLI 		= SD2.D2_LOJA "
	cQuery += " 	AND NJ0.NJ0_FILIAL 	>= '"+cFilNJ0De+"' "
	cQuery += " 	AND NJ0.NJ0_FILIAL 	<= '"+cFilNJ0Ate+"' "
	cQuery += " 	AND NJ0.D_E_L_E_T_ = '' "
	cQuery += " LEFT JOIN " + RetSqlName("NJM") + " NJM " 
	cQuery += " 	ON 	NJM.NJM_DOCSER	= SD2.D2_SERIE "
	cQuery += " 	AND NJM.NJM_DOCNUM 	= SD2.D2_DOC "
	cQuery += " 	AND NJM.NJM_CODENT 	= NJ0_CODENT "
	cQuery += " 	AND  NJM.NJM_LOJENT	=  NJ0.NJ0_LOJENT "
	cQuery += " 	AND NJM.NJM_FILIAL 	>= '"+cFilRomDe+"' "
	cQuery += " 	AND NJM.NJM_FILIAL 	<= '"+cFilRomAte+"' "
	cQuery += " 	AND	NJM.D_E_L_E_T_ = '' "
	cQuery += " LEFT JOIN " + RetSqlName("NJJ") + "  NJJ " 
	cQuery += " 	ON  NJJ.NJJ_FILIAL 	= NJM.NJM_FILIAL "
	cQuery += " 	AND NJJ.NJJ_CODROM	=  NJM.NJM_CODROM "
	cQuery += " 	AND	NJJ.D_E_L_E_T_ = '' "
	
	cQuery += " WHERE "	
	cQuery += "		SD2.D2_FILIAL 	>= '" + cFilSD2De + "' "
	cQuery += "	AND	SD2.D2_FILIAL 	<= '" + cFilSD2Ate + "' "
	If lN8K //Liberado P12.1.23. VERIFICA SE NÃO EXISTE D2_CTROG POIS ESTE FOI CRIADO VIA UPDDISTR LEGADO
	   cQuery += " AND	N8K.N8K_CODCTR 	= '" + cCodCtr + "'"
	Else
	   cQuery += " AND	SD2.D2_CTROG 	= '" + cCodCtr + "'"
	EndIf
	cQuery += " AND NJJ.NJJ_CODPRO  = '" + cProdCTR + "'"
	cQuery += " AND	SD2.D2_COD 	    = '" + cProdCTR + "'"
	cQuery += " AND	SD2.D2_TES   	= NJM.NJM_TES "				// -- Garanto q o D2_tes Seja Igual a Tes do Romaneio, Para evitar retorno no D2 de nfs. de transito --//
	cQuery += " AND	(SD2.D2_QUANT 	- SD2.D2_QTDEDEV > 0) "  	//Garantindo que o roamenio n. esta com a Qtidade toda devolvida ou n. tem qtd. Zerada
	cQuery += " AND	SD2.D2_TIPO 	= 'N' " 
	cQuery += " AND	SD2.D_E_L_E_T_ = ' ' "

	IF pnOpc == 2	//Considerando Apenas itens que já estão vinculados
		cQuery += " AND    ( "
		cQuery += " 	SELECT " 
		cQuery += " 	SUM(NNC_QTDFIX) FROM " + RetSqlName("NNC") + " NNC "  	//-- Repeti o Sql q gera a Coluna Qtvinculad, para filtrar somente itens q possuem qtvinc. > 0
		If lN8K  //Liberado P12.1.23. VERIFICA SE NÃO EXISTE D2_CTROG POIS ESTE FOI CRIADO VIA UPDDISTR LEGADO
		   cQuery += "		WHERE	NNC.NNC_CODCTR = N8K.N8K_CODCTR "
		   cQuery += "		AND 	NNC.NNC_CODROM = N8K.N8K_CODROM "
		   cQuery += "		AND 	NNC.NNC_ITEROM = N8K.N8K_ITEROM "
		Else
		   cQuery += "		WHERE	NNC.NNC_CODCTR = SD2.D2_CTROG  "
		   cQuery += "		AND 	NNC.NNC_CODROM = SD2.D2_CODROM "
		   cQuery += "		AND 	NNC.NNC_ITEROM = SD2.D2_ITEROM "
		EndIf
		cQuery += "		AND		NNC.NNC_FILIAL >= '" + cFilNNCDe  + "' "
		cQuery += "		AND		NNC.NNC_FILIAL <= '" + cFilNNCAte + "' "
		cQuery += " 	   	AND     NNC.NNC_ITEMFX = '" + cNN8_ITEMFX 	+ "' "		//-- So é relevante o que é da fixação selecionada --//
		cQuery += "		AND		NNC.D_E_L_E_T_ = ' ' "
		cQuery += ") > 0 "
	EndIF
	
	cQuery += " ORDER BY SD2.D2_EMISSAO, NJM.NJM_CODROM " 
	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.) 

Return( cAliasQry )


/** {Protheus.doc} fNNCVLFIXB
Qto Vou fixar a Qtd do romaneio sempre Calculo o Vr. da  fixação da entrega, de forma
acumulada, Isso melhora o Calculo de arredondamento;

@param:    	-> nQtVincul Qtd a vincular
@Retorno   	-> NNC_VLFIXB		
@author:    Emerson Coelho
@since:     08/02/2016
@Uso:         SIGAAGR - Originação de Grãos
*/
Static Function fNNCVLFIXB( nQtVincul )
	Local nVLFIXB		:= 0
	Local cAliasQry 	:= GetNextAlias()
	Local aAreaAtu	 	:= GetArea()
	Local aAreaNNC		:= NNC->( GetArea() )
	Local nVrFixAcum	:= 0
	
	Local cFilNNCDe     := IIf(Empty(xFilial("NJR")),Replicate( " ", TamSX3("NNC_FILIAL")[1] ),xFilial("NNC"))  //"Filial De"
	Local cFilNNCAte    := IIf(Empty(xFilial("NJR")),Replicate( "Z", TamSX3("NNC_FILIAL")[1] ),xFilial("NNC"))  //"Filial Ate"
	
	// Somatória de todas quantidades entregues
	cAliasQry 	:= GetNextAlias()
	BeginSql Alias cAliasQry
	SELECT 
	CASE 
	WHEN SUM(NNC_QTDFIX) IS NULL THEN 0
	ELSE SUM(NNC_QTDFIX)
	END AS QTDFIXACUM,
	CASE 
	WHEN SUM(NNC_VLFIXB) IS NULL THEN 0
	ELSE SUM(NNC_VLFIXB)
	END AS VLFIXBACUM

	FROM %Table:NNC% NNC
	WHERE 	NNC.%NotDel%
	AND 	NNC.NNC_FILIAL >= %Exp:cFilNNCDe% 
	AND		NNC.NNC_FILIAL <= %Exp:cFilNNCAte%
	AND 	NNC.NNC_CODCTR = %exp:NN8->NN8_CODCTR%
	AND 	NNC.NNC_ITEMFX = %exp:NN8->NN8_ITEMFX%
	EndSql

	(cAliasQry)->( DbGotop() )

	// Vr. Acumulado Vinculado a Fixação contanto já com a Entrega q está sendo marcada Será:
	// Vr. Total da Fixação Bruto * (Qtd. Vinculada de forma acumulada + a Qtidade da Entrega q está sendo marcada) / Qtidade Total da Fixação
	nVrFixAcum 	:= a410Arred( NN8->NN8_VLRTOT  * ( (( cAliasQry )->QTDFIXACUM + nQtvincul)  / NN8-> NN8_QTDFIX ), 'D1_TOTAL' )
	// o Vr. da Fixação é Igual:
	// o Vr. TotalAcumulado considerando a entrega - o que já estava acumulado sem a Entrega.
	nVlFixb 	:= nVrFixAcum - ( cAliasQry )->VLFIXBACUM
	RestArea( aAreaAtu )
	RestArea( aAreaNNC )		
Return( nVlFIXB )		

/** {Protheus.doc} OGA430FHIS
Descrição: Mostra em tela de Historico do contrato

@param:     Nil
@author:    Gilson Venturi
@since:     31/03/2015
@Uso:       OGA290 
*/
Function OGA430FHIS()
	Local cChaveI := "NN8->("+Alltrim(AGRSEEKDIC("SIX","NN81",1,"CHAVE"))+")"
	Local cChaveA := &(cChaveI)+Space(Len(NK9->NK9_CHAVE)-Len(&cChaveI))

	AGRHISTTABE("NN8",cChaveA)
Return		

/*/{Protheus.doc} fComplOrg
	Função para verificar se existem romaneios de complemento emitidos na origem, por meio
	da opção Outras Ações -> Nota Complementar do OGA250.
	@type  Static Function
	@author rafael.voltz
	@since 02/06/2020
	@version 1.0
	@param cCodCtr, char, Código do contrato
	@param cCodRom, char, Código do romaneio
	@return nVlrCompl, decimal, Valor do complemento
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function fComplOrg(cCodRom as char)
	Local cAliasQ    as char
	Local nVlrCompl  as numeric

    Default _lHasND4 := .F.
    Default cCodRom  := ""
	
	nVlrCompl := 0

	If TableInDic('ND4') 
		cAliasQ := GetNextAlias()

		BeginSql Alias cAliasQ
			SELECT SUM(NJM_VLRTOT) VLR_COMPL
  			  FROM %table:NJM% NJM 
 			 WHERE NJM.NJM_FILIAL = %xFilial:NJM%
  			   AND NJM.NJM_CODROM IN (SELECT ND4_ROMREL 
                                        FROM %table:ND4% ND4 
						               WHERE ND4.ND4_FILIAL = NJM.NJM_FILIAL
						                AND ND4.ND4_CODROM = %Exp:cCodRom%
						                AND ND4.ND4_TIPREL = 'C'
						                AND ND4.%notDel% )
            AND NJM.%notDel%
		EndSql	

        If (cAliasQ)->VLR_COMPL > 0
            nVlrCompl := (cAliasQ)->VLR_COMPL
        EndIF

        (cAliasQ)->(dbCloseArea())
    EndIf

Return nVlrCompl
