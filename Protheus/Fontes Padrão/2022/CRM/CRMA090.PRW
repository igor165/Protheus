#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRMA090.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA090

Rotina de Anotações

@sample 	CRMA090( cAlias, nRecno )

@param		nOper   -  Tipo de operação que vai ser realizada (incluir/Alterar/excluir)
    		cEntida -  Entidade que deverá ser vinculada oa registro

@return   	Nil

@author	Thamara Villa Jacomo
@since		15/01/2014
@version	11.90
/*/
//------------------------------------------------------------------------------
Function CRMA090(nOper,cEntida)

Local cAlias			:= Alias()
Local nRecNo			:= 0
Local oDlg 			:= Nil
Local oDlgAntCont 	:= Nil
Local oBrwAnota 		:= Nil
Local oMemo			:= Nil
Local cMemo			:= ""
Local lRetorno 		:= .T.
Local oPanel  		:= Nil
Local oCOLRIGHT		:= Nil
Local oCOLLEFT		:= Nil
Local oLayerCont     := Nil

Private aRotina 	:= MenuDef()
Private aChavEnt  	:= {}

Default cEntida      := ""
Default nOper        := 0

cAlias := IIF(ValType(cEntida) == "C" .AND. !Empty(cEntida),cEntida,cAlias)
nRecNo := ( cAlias )->( RecNo() )

If Valtype(nOper) <> "N"
	nOper := 0
EndIf

aChavEnt := CRMA090Chav( cAlias, nRecNo )

If  !Empty(aChavEnt[2]) .AND. nOper <= 0

	oDlg := FWDialogModal():New()
	oDlg:SetBackground(.F.) // .T. -> escurece o fundo da janela
	oDlg:SetEscClose(.F.)//não permite fechar a tela com o ESC
	oDlg:SetSize(270,580) //cria a tela maximizada (chamar sempre antes do CreateDialog)
	oDlg:EnableFormBar(.T.)

	oDlg:CreateDialog() //cria a janela (cria os paineis)
	oPanel := oDlg:getPanelMain()
	If !IsInCallStack( "F300CMTMDL" ) .And. !IsInCallStack( "CRMA800" )
		oDlg:addCloseButton()
		oDlg:SetEscClose(.T.)
	EndIf


	oFWLayer := FWLayer():New()
	oFWLayer:Init( oPanel, .F. )
	oFWLayer:AddCollumn("LEFT_BOX",80,.F.)
	oFWLayer:AddCollumn("RIGTH_BOX",20,.F.)

	oCOLRIGHT := oFWLayer:getColPanel("RIGTH_BOX",Nil)
	oCOLLEFT  := oFWLayer:getColPanel("LEFT_BOX",Nil)

	oLayerCont := FWLayer():New()
	oLayerCont:Init( oCOLRIGHT, .F. )
	oLayerCont:AddCollumn( "COLL1",100,.T.,"LINE1" )
	oLayerCont:addWindow( "COLL1", "WIN1", STR0016, 100, .F., .F.,,"LINE1")// "Conteúdo"
	oDlgAntCont    := oLayerCont:GetWinPanel("COLL1","WIN1","LINE1")

	oBrwAnota := FWMBrowse():New()
	oBrwAnota:SetAlias( "AOB" ) 
    oBrwAnota:SetCanSaveArea(.T.)
    oBrwAnota:SetDescription( STR0001 )//"Anotações"
    oBrwAnota:DisableDetails()
	oBrwAnota:SetFilterDefault( CRM090FilDef(aChavEnt[1], aChavEnt[2]) )
    oBrwAnota:SetOwner( oCOLLEFT )
    oBrwAnota:SetChange( {|| cMemo := AOB->AOB_CONTEU,IiF( ValType( oMemo ) == "O",oMemo:Refresh(),Nil ) } )
    oBrwAnota:SetTotalDefault("AOB_FILIAL","COUNT",STR0015) // "Total de Registros"
    oBrwAnota:SetMainProc("CRMA090")
    oBrwAnota:Activate()

    If IsInCallStack( "F300CMTMDL" ) .Or. IsInCallStack( "CRMA800" )
  		oDlg:AddButton( STR0020, { || A800PropView( ADY->ADY_PROPOS ) }	 	, STR0020, , .T., .F., .T., )//"Visual. Proposta"
  		oDlg:AddButton( STR0022, { || CRM090AtSta( .F. ), oDlg:DeActivate() }	, STR0022, , .T., .F., .T., )//"Sair"
  	EndIf

	//Adiciona o Memo
	@ 000,000 GET oMemo VAR cMemo SIZE 0,0 MEMO HSCROLL OF oDlgAntCont PIXEL READONLY
	oMemo:Align := CONTROL_ALIGN_ALLCLIENT
	oDlg:activate()

ElseIf !Empty(aChavEnt[2]) .AND. nOper > 0

	Do Case
		Case nOper == 3
			FWExecView(STR0017, "CRMA090", 3)//INCLUIR
		Case nOper == 4
			FWExecView(STR0018, "CRMA090", 4)//ALTERAR
		Case nOper == 5
			FWExecView(STR0019, "CRMA090", 5)//EXCLUIR
	EndCase

Else
	Aviso( STR0002, STR0003 +cAlias+ STR0004, { "OK" }, 2 )// "Atenção" ###"Para criar uma anotação é necessário existir uma chave de relacionamento definida para o alias: ## .Consulte o Administrador do sistema."
	lRetorno := .F.
EndIf

Return( lRetorno )
//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()

Modelo de dados (Regra de Negocio)

@return   	oModel - Objeto do modelo

@author	Thamara Villa Jacomo
@since		15/01/2014
@version	11.90
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel
Local oStruAOB		:= FWFormStruct( 1, "AOB" )
Local cTitulo   	:= STR0001 // "Anotações"
Local cCabec  		:= STR0005 // "Cabeçalho"
Local bCommit		:= {|oModel| CRMA090Cmt( oModel )}

If Type("aChavEnt") = "A"
	oStruAOB:SetProperty( "AOB_ENTIDA",MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,'aChavEnt[1]' ) )
	oStruAOB:SetProperty( "AOB_CHAVE",MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,'aChavEnt[2]' ) )
EndIf

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( "CRMA090", /*bPreValidacao*/, /*bPosValidacao*/, bCommit,/*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( "AOBMASTER", /*cOwner*/, oStruAOB )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( cTitulo )

oModel:GetModel( "AOBMASTER" ):SetDescription( cCabec )

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

View - Interface de interacao com o Modelo de Dados (Model)

@return   	oView - Objeto da View

@author	Thamara Villa Jacomo
@since		15/01/2014
@version	11.90
/*/
//------------------------------------------------------------------------------

Static Function ViewDef()

Local oModel	:= FWLoadModel( "CRMA090" )
Local oStruAOB	:= FWFormStruct( 2, "AOB" ) 
Local oView   	:= FWFormView():New()

oView:SetModel( oModel )

oStruAOB:RemoveField( "AOB_ENTIDA" )
oStruAOB:RemoveField( "AOB_CHAVE" )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( "VIEW_AOB", oStruAOB, "AOBMASTER" )

oView:AddUserButton( STR0012, "CLIPS",{ |oView| MsDocument( "AOB", AOB->( RecNo() ), 1 ) },,,{MODEL_OPERATION_VIEW} ) //Só visualiza dos anexos.
oView:AddUserButton( STR0012, "CLIPS",{ |oView| CRM090Doc( oModel ) },,,{MODEL_OPERATION_UPDATE} )  

oView:CreateHorizontalBox( "SUPERIOR", 100 )
oView:SetOwnerView( "VIEW_AOB", "SUPERIOR" )

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA090Chav()

Posiciona no Alias vigente

@sample 	CRMA090Chav( cAlias, nRecNo )

@param		cAlias -  Alias da Tabela  posicionada
@param		nRecno -  Numero do registro

@return   	aResult -	Array onde [1]=Alias da Tabela e [2]=Chave Única

@author	Thamara Villa Jacomo
@since		16/01/2014
@version	11.90
/*/
//------------------------------------------------------------------------------
Function CRMA090Chav(cAlias, nRecNo)

Local aArea		:= GetArea()
Local aAreaSX2 	:= SX2->(GetArea())
Local aChave	:= {"",""}
Local cChave	:= ""
Local cUnico	:= ""

If !Empty(cAlias)
	cUnico := FWX2Unico(cAlias)
	IF	! Empty(cUnico)
		(cAlias)->(DBGoTo(nRecNo))
		cChave := (cAlias)->&(cUnico)
		aChave := {cAlias, cChave}
	EndIf
EndIf

RestArea(aAreaSX2)
RestArea(aArea)
aSize(aAreaSX2,0)
aSize(aArea,0)
Return(aChave)

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

MenuDef - Operações que serão utilizadas pela aplicação

@return   	aRotina - Array das operações

@author	Thamara Villa Jacomo
@since		15/01/2014
@version	11.90
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE  STR0007  	ACTION 	"VIEWDEF.CRMA090" 	OPERATION 2	ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE  STR0008	ACTION 	"VIEWDEF.CRMA090" 	OPERATION 3	ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE  STR0009	ACTION 	"VIEWDEF.CRMA090" 	OPERATION 4	ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE  STR0010	ACTION 	"VIEWDEF.CRMA090"	OPERATION 5	ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE  STR0011 	ACTION 	"VIEWDEF.CRMA090" 	OPERATION 9	ACCESS 0 //"Copiar"
ADD OPTION aRotina TITLE  STR0012	ACTION 	"CRM090Doc()"		OPERATION 7	ACCESS 0 //"Anexos"
ADD OPTION aRotina TITLE  STR0013	 ACTION 'CRM90DocVi()'	   	OPERATION 8	ACCESS 0 //"Visualizar Anexo"

Return( aRotina )

//-------------------------------------------------------------------------
/*/{Protheus.doc} CRM090Doc()

Chama função de inclusão de arquivos

@return   	Nil

@author	Thamara Villa Jacomo
@since		16/01/2014
@version	11.90
/*/
//-------------------------------------------------------------------------
Function CRM090Doc( oModel )

Local nLRecAfter	:= 0
Local nLRecBefore	:= 0
Local lProcProp	:= IsInCallStack( "F300CMTMDL" ) .Or. IsInCallStack( "CRMA800" )
Local lCRM090VUPL	:= ExistBlock("CRM090VUPL")
Local lContinua	:= .T.

Default oModel := Nil

If lCRM090VUPL
	lContinua := ExecBlock("CRM090VUPL", .F., .F., { lProcProp })
	If ValType( lContinua ) <> "L"
		lContinua := .F.
	EndIf
EndIf

If lContinua

	If lProcProp
		nLRecAfter := CRM90LRAC9( AOB->AOB_IDNOTA )
	EndIf

	If MsDocument( "AOB", AOB->( RecNo() ), 2 )

		If lProcProp

			DbSelectArea( "AC9" )
			AC9->( DbSetOrder( 2 ) ) //AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT+AC9_CODOBJ

			If AC9->( DbSeek( xFilial( "AC9" ) + "AOB" + xFilial( "AOB" ) +  AOB->AOB_IDNOTA  ) )

				nLRecBefore := CRM90LRAC9( AOB->AOB_IDNOTA )

				If nLRecBefore > nLRecAfter
					CRM090AtSta(.T.)
				EndIf

			EndIf

		EndIf

	EndIf

EndIf

Return Nil


//-------------------------------------------------------------------------
/*/{Protheus.doc} CRM90LRAC9

Retorna o ultimo RecNo da AC9 com o objeto vinculado.

@param		cIdNota	, caracter	, Id da Anotação.
@return   	nLastRec	, numerico	, Numero do RecNo da AC9 com objeto vinculado.

@author	Thamara Villa Jacomo
@since		02/08/2015
@version	12
/*/
//-------------------------------------------------------------------------
Static Function CRM90LRAC9( cIdNota )

Local aArea		:= GetArea()
Local nLastRec	:= 0
Local cTemp 		:= ""

Default cIdNota := ""

If !Empty( cIdNota )

	cTemp := GetNextAlias()

	BeginSQL Alias cTemp

		SELECT AC9.R_E_C_N_O_
		FROM
			%Table:AC9% AC9
			INNER JOIN %Table:ACB% ACB ON AC9.AC9_CODOBJ = ACB.ACB_CODOBJ
		WHERE
			AC9.AC9_FILIAL = %xFilial:AC9%	AND
			AC9.AC9_ENTIDA = %Exp:"AOB"%  	AND
			AC9.AC9_FILENT = %xFilial:ACB%	AND
			AC9.AC9_CODENT = %Exp:cIdNota%	AND
			ACB.ACB_FILIAL = %xFilial:ACB% 	AND
			ACB.ACB_OBJETO <> %Exp:" "%		AND
			AC9.%NotDel%						AND
			ACB.%NotDel%
		ORDER BY AC9.R_E_C_N_O_ DESC
	EndSql

	If (cTemp)->( !Eof() )
		nLastRec := (cTemp)->( R_E_C_N_O_ )
	EndIf

	(cTemp)->( DBCloseArea() )

EndIf

RestArea(aArea)

Return( nLastRec )

//-------------------------------------------------------------------------
/*/{Protheus.doc} CRM90DocVi()

Chama função de visualização de arquivos
	
@return   	Nil

@author	Thamara Villa Jacomo
@since		17/01/2014
@version	11.90
/*/
//-------------------------------------------------------------------------
Function CRM90DocVi()

MsDocument( 'AOB', AOB->(RECNO()), 2 )

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} CRMA090Cmt()

@Sample CRMA090Cmt( oModel )

Commit

@param		oModel -  Modelo de Dados

@return   	Verdadeiro

@author	Thamara Villa Jacomo
@since		17/01/2014
@version	11.90
/*/
//---------------------------------------------------------------------------
Static Function CRMA090Cmt( oModel )

Local aArea 		:= GetArea()
Local nOperation	:= oModel:GetOperation()
Local oMdlAOB		:= oModel:GetModel( "AOBMASTER" )

If nOperation == MODEL_OPERATION_UPDATE
	oMdlAOB:SetValue( "AOB_DTNOTA", dDataBase )
EndIf

If nOperation == MODEL_OPERATION_DELETE
	MsDocument( "AOB", AOB->( RecNo() ),2,,3 )
EndIf


FWFormCommit( oModel, Nil/*bBefore*/, Nil/*bAfter*/  )

RestArea( aArea )

Return( .T. )

//-------------------------------------------------------------------------
/*/{Protheus.doc} CRMA090Del()

Exclusão dos registros ligados às anotações

@Sample CRMA090Del( cTabel, nRec )

@param		cTabel -  Alias da Tabela
@param		nRec   -  Numero do registro

@return   	Verdadeiro

@author	Thamara Villa Jacomo
@since		17/01/2014
@version	11.90
/*/
//---------------------------------------------------------------------------
Function CRMA090Del( cTabel, nRec )

Local aArea			:= GetArea()
Local aAreaAOB		:= AOB->( GetArea() )
Local aTabChav		:= {}
Local lExclui		:= .T.

Default cTabel		:= ""
Default nRec		:= 0

If !Empty( cTabel ) .And. nRec > 0
	aTabChav := CRMA090Chav( cTabel, nRec )

	AOB->( DbSelectArea( "AOB" ) )
	AOB->( DbSetOrder( 2 ) )//AOB_FILIAL+AOB_ENTIDA+AOB_CHAVE
	If AOB->( DbSeek( xFilial( "AOB" ) + aTabChav[1] + aTabChav[2] ) )
		While AOB->AOB_ENTIDA == aTabChav[1] .And. AOB->AOB_CHAVE == PadR( aTabChav[2], TamSX3( "AOB_CHAVE" )[1] )
			Reclock( "AOB", .F. )
			AOB->( DbDelete() )
			AOB->( MsUnlock() )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui a amarracao com os conhecimentos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MsDocument( "AOB", AOB->( Recno() ), 2, , 3 )

			AOB->( DbSkip() )
		EndDo
	EndIf
Else
	lExclui := .F.
		Aviso( STR0002, STR0014, { "OK" }, 2 ) // "Atenção", "Não foi possível excluir o(s) registro(s) de Anotação"
EndIf

RestArea( aAreaAOB )
RestArea( aArea )

Return ( lExclui )
//-----------------------------------------------------------------------
/*/{Protheus.doc} CRM090AtSta()

Responsável por atualizar os status G = Upload pendente e
H = Aguardando análise da proposta comercial

@Sample 	CRM090AtSta()

@return   	.T. - Lógico - Verdadeiro

@author	Thamara Villa
@since		04/12/2015
@version	12.1.7
/*/
//-----------------------------------------------------------------------
Static Function CRM090AtSta(lUpLoad)

Local cStatus 		:= "" //Upload pendente.
Local dDateUpl		:= cTod( "//" )
Local cUsrUpl		:= ""
Local cHrUpl		:= ""			
Local nTipoDtUpload	:= SuperGetMv( "MV_TPDTUPL",,1 )
Local lUpdated		:= .F.
	
Default lUpload	:= .F.

//-------------------------------------------------------------------
// Atualiza o status da proposta para atualizar no painel.
//-------------------------------------------------------------------
If ADY->ADY_STATUS  $ "B|D|G|H"
	If lUpload
		cStatus 	:= "H" //Aguardando análise
		dDateUpl	:= Iif(nTipoDtUpload==1,dDataBase,Date())
		cUsrUpl		:= If(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr())
		cHrUpl		:= Time()
		lUpdated	:= .T.
	Else
		//Se no encerramento da oportunidade de venda o usuario nao fez o upload deixa pendente.
		If IsInCallStack( "FT300ORCPED" ) .And. ADY->ADY_STATUS <> "H"
			cStatus 	:= "G" //Upload pendente.
			dDateUpl	:= cTod( "//" )
			cUsrUpl		:= ""
			cHrUpl		:= ""
			lUpdated	:= .T.
		EndIf			
	EndIf
EndIf

If lUpdated
	RecLock("ADY",.F.)
		ADY->ADY_STATUS	:= cStatus
		ADY->ADY_DTUPL	:= dDateUpl
		ADY->ADY_USRUPL	:= cUsrUpl
		ADY->ADY_HRUPLO	:= cHrUpl
	ADY->( MsUnLock() )
EndIf

Return .T.


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM090FilDef()

Monta filtro padrão para o browse de anotações.

@param		cEntity	, caracter, Entidade que será aplicada o filtro.
@param		cKey	, caracter, Chave da entidade.

@author		Squad CRM / Faturamento
@since		08/08/2018
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Static Function CRM090FilDef(cEntity, cKey) 
Local cFilter	:= ""
Local lHConvEnt	:= SuperGetMv("MV_CRMFAOB",.F.,.F.) 
Local cFilSA1	:= ""
Local cFilSUS	:= ""
Local cFilACH	:= ""

Default cEntity := "" 
Default cKey	:= ""

If lHConvEnt
	Do Case
		Case cEntity == "SA1"

			//US_FILIAL+US_CODCLI+US_LOJACLI    
			SUS->(DBSetOrder(5))
			If SUS->( DBSeek( xFilial("SUS") + SA1->A1_COD + SA1->A1_LOJA ) )

				cFilSUS := "( AOB_ENTIDA == 'SUS' .And. AOB_CHAVE == '" + SUS->US_FILIAL + SUS->US_COD + SUS->US_LOJA + "' ) "
				
				//ACH_FILIAL+ACH_CODPRO+ACH_LOJPRO
				ACH->(DBSetOrder(4))
				If ACH->( DBSeek( xFilial("ACH") + SUS->US_COD + SUS->US_LOJA ) )
					cFilACH := "( AOB_ENTIDA == 'ACH' .And. AOB_CHAVE == '" + ACH->ACH_FILIAL + ACH->ACH_CODIGO + ACH->ACH_LOJA + "' ) "
				EndIf
			EndIf

		Case cEntity == "SUS"

			//A1_FILIAL+A1_COD+A1_LOJA   
			SA1->(DBSetOrder(1))
			If SA1->( DBSeek( xFilial("SA1") + SUS->US_CODCLI + SUS->US_LOJACLI ) )
				cFilSA1 := "( AOB_ENTIDA == 'SA1' .And. AOB_CHAVE == '" + SA1->A1_FILIAL + SA1->A1_COD + SA1->A1_LOJA + "' ) "
			EndIf

			//ACH_FILIAL+ACH_CODPRO+ACH_LOJPRO
			ACH->(DBSetOrder(4))
			If ACH->( DBSeek( xFilial("ACH") + SUS->US_COD + SUS->US_LOJA ) )
				cFilACH := "( AOB_ENTIDA == 'ACH' .And. AOB_CHAVE == '" + ACH->ACH_FILIAL + ACH->ACH_CODIGO + ACH->ACH_LOJA + "' ) "
			EndIf

		Case cEntity == "ACH"

			//US_FILIAL+US_COD+US_LOJA
			SUS->(DBSetOrder(1))
			If SUS->( DBSeek( xFilial("ACH") + ACH->ACH_CODPRO + ACH->ACH_LOJPRO ) )
				cFilSUS := "( AOB_ENTIDA == 'SUS' .And. AOB_CHAVE == '" + SUS->US_FILIAL + SUS->US_COD + SUS->US_LOJA + "' ) "
				
				//A1_FILIAL+A1_COD+A1_LOJA
				SA1->(DBSetOrder(1))
				If SA1->( DBSeek( xFilial("SA1") + SUS->US_CODCLI + SUS->US_LOJACLI ) )
					cFilSA1 := "( AOB_ENTIDA == 'SA1' .And. AOB_CHAVE == '" + SA1->A1_FILIAL + SA1->A1_COD + SA1->A1_LOJA + "' ) "
				EndIf
			EndIf

	EndCase
EndIf 

cFilter	:= "( AOB_ENTIDA == '" + cEntity + "' .And. AOB_CHAVE == '" + cKey + "' )"

If !Empty( cFilSA1 )
	cFilter += " .Or. " + cFilSA1   
EndIf

If !Empty( cFilSUS )
	cFilter += " .Or. " + cFilSUS 
EndIf

If !Empty( cFilACH )
	cFilter += " .Or. " + cFilACH 
EndIf

Return cFilter 
