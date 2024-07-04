#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TECA810.CH'

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA810
	Cadastro Kit para Alocaçaõ
@sample 	TECA810() 
@since		29/08/2013       
@version	P11.90
/*/
//------------------------------------------------------------------------------
Function TECA810()

Local oBrw := FwMBrowse():New()

oBrw:SetAlias( 'TEZ' )
oBrw:SetMenudef( "TECA810" )
oBrw:SetDescription( OEmToAnsi( STR0001 ) ) // "Kits para Locação"
oBrw:Activate()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} Menudef
	Rotina para construção do menu
@sample 	Menudef() 
@since		29/08/2013       
@version 	P11.90
@return 	aMenu, ARRAY, lista de opções disponíveis para usuário x rotina
/*/
//------------------------------------------------------------------------------
Static Function Menudef()

Local aMenu := {}

ADD OPTION aMenu Title STR0002  Action 'PesqBrw'        OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aMenu Title STR0003  Action 'VIEWDEF.TECA810' OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aMenu Title STR0004  Action 'VIEWDEF.TECA810' OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aMenu Title STR0005  Action 'VIEWDEF.TECA810' OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aMenu Title STR0006  Action 'VIEWDEF.TECA810' OPERATION 5 ACCESS 0 //"Excluir"

Return aMenu

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@since 29/08/2013
@version 	P11.90
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView := Nil
Local oMdlKit := ModelDef()

Local oStrCabec := FWFormStruct( 2,'TEZ', {|cCampo|  ( Alltrim( cCampo )$"TEZ_PRODUT+TEZ_PRODES" ) } )
Local oStrGrid  := FWFormStruct( 2,'TEZ', {|cCampo| !( Alltrim( cCampo )$"TEZ_PRODUT+TEZ_PRODES" ) } )

oStrGrid:RemoveField( "TEZ_PRODUT" )

oView := FWFormView():New()

oView:SetModel(oMdlKit)
oView:SetDescription(STR0007) // "Cadastro de Kit"

oView:AddField("CABEC",oStrCabec,"TEZ_CABEC")
oView:AddGrid("GRID",oStrGrid,"TEZ_GRID")

//--------------------------------------
//		Cria os Box's
//--------------------------------------
oView:CreateHorizontalBox( "SUPERIOR", 10 )  // Cabeçalho
oView:CreateHorizontalBox( "INFERIOR", 90 )  // Grid

//--------------------------------------
//		Associa os componentes ao Box
//--------------------------------------
oView:SetOwnerView( 'CABEC', 'SUPERIOR' ) 
oView:SetOwnerView( 'GRID' , 'INFERIOR' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@since 29/08/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel := Nil

Local oStrCabec := FWFormStruct(1,'TEZ', {|cCampo|  ( Alltrim( cCampo )$"TEZ_PRODUT+TEZ_PRODES" ) } )
Local oStrGrid  := FWFormStruct(1,'TEZ', {|cCampo| !( Alltrim( cCampo )$"TEZ_PRODES" ) } )

oStrGrid:SetProperty( "TEZ_PRODUT", MODEL_FIELD_OBRIGAT, .F. )

oModel := MPFormModel():New('TECA810')
oModel:AddFields("TEZ_CABEC",/*cOwner*/,oStrCabec)
oModel:AddGrid("TEZ_GRID", "TEZ_CABEC", oStrGrid, {|oMdlG,nLine,cAcao,cCampo| At810DelPrd( oMdlG,nLine,cAcao,cCampo ) },/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*bLoad*/)

oModel:SetRelation("TEZ_GRID",{ { "TEZ_FILIAL", "xFilial('TEZ')" }, { "TEZ_PRODUT", "TEZ_PRODUT" } },TEZ->(IndexKey( 1 ) ) )
oModel:SetPrimaryKey( {} )

//Define que o item do kit deve ser uma chave unica
oModel:GetModel( "TEZ_GRID" ):SetUniqueLine({"TEZ_ITPROD"})

oModel:SetDescription(STR0007) // 'Cadastro de Kit'

Return oModel


//------------------------------------------------------------------------------
/*/{Protheus.doc} At810VldKey
	Valida a chave do cadastro de Kit para Locação
@sample 	At810VldKey() 
@since		29/08/2013       
@version	P11.90
@return 	lRet, LOGICO, permite ou não a inclusão daquele registro
/*/
//------------------------------------------------------------------------------
Function At810VldKey()

Local lRet := ( ExistCpo( "SB1", FwFldGet("TEZ_PRODUT"), 1 ) .And. ;
				Posicione( "SB1", 1, xFilial("SB1")+FwFldGet("TEZ_PRODUT"), "B1_TIPO" ) == "KT" )

If lRet 
	TEZ->( DbSetOrder( 1 ) ) // TEZ_FILIAL+TEZ_PRODUT
	
	If ( TEZ->( DbSeek( xFilial("TEZ")+FwFldGet("TEZ_PRODUT") ) ) )
		lRet := .F.
		Help( , ,'PRODKIT',, STR0008,1,0) //"Produto referência para o kit não pode estar em duas composições ao mesmo tempo." 
	EndIf

	If lRet
		lRet := At810KitHp(FwFldGet("TEZ_PRODUT"))
	Endif
EndIf

Return lRet 

//------------------------------------------------------------------------------
/*/{Protheus.doc} At810VldItem
	Valida a chave do cadastro de Kit para Locação
@sample 	At810VldItem() 
@since		29/08/2013       
@version	P11.90
@return 	lRet, LOGICO, permite ou não a inclusão daquele registro
/*/
//------------------------------------------------------------------------------
Function At810VldItem()

Local lRet := ( ExistCpo( "SB1", FwFldGet("TEZ_ITPROD"), 1 ) .And. ;
				Posicione( "SB1", 1, xFilial("SB1")+FwFldGet("TEZ_ITPROD"), "B1_TIPO" ) != "KT" )

If lRet
	lRet := At810KitHp(FwFldGet("TEZ_ITPROD"))

  If lRet
  	dbSelectArea("SB5")
  	SB5->(dbSetOrder(1))
  	If SB5->(dbSeek(xFilial("SB5")+FwFldGet("TEZ_ITPROD")))
  		If SB5->B5_ISIDUNI == "2"
  			MsgInfo( STR0009 ) //"O produto selecionado não é controlado por ID único, a quantidade do(s) equipamento(s) na separação ou reserva, deverá ser preenchida manualmente."
  		Endif
  	Endif
  EndIf
Endif

Return lRet 

//------------------------------------------------------------------------------
/*/{Protheus.doc} At810IniItDes
	Inicializa a descrição do produto
@sample 	At810IniItDes() 
@since		29/08/2013       
@version	P11.90
@return 	cDescricao, CHARACTER, conteúdo da descrição 
/*/
//------------------------------------------------------------------------------
Function At810IniItDes()

Local cDescricao := ""
Local oMdlAtivo  := FwModelActive()
Local oMdlGrid   := Nil

If oMdlAtivo:GetId()=="TECA810"
	
	oMdlGrid := oMdlAtivo:GetModel( "TEZ_GRID" )
	
	If oMdlGrid:GetOperation()!=MODEL_OPERATION_INSERT .And. oMdlGrid:GetLine()==0
		
		cDescricao := POSICIONE( "SB1", 1, xFilial("SB1")+TEZ->TEZ_ITPROD,"B1_DESC" )
	EndIf

EndIf

Return cDescricao

//------------------------------------------------------------------------------
/*/{Protheus.doc} At810DelPrd
	Valida a exclusão do item do grid
@sample 	At810DelPrd() 
@since		29/08/2013       
@version	P11.90
@param  	oMdlGrid, OBJECT, modelo de dados do grid
@return 	lRet, LOGIC, pode ou não realizar a exclusão da linha 
/*/
//------------------------------------------------------------------------------
Static Function At810DelPrd( oMdlG,nLine,cAcao,cCampo )

Local lRet := .T.
Local cCodKit := M->TEZ_PRODUT
Local cQryAlias := GetnextAlias()

If oMdlG:GetOperation()==MODEL_OPERATION_UPDATE .And. Alltrim( cAcao ) == "DELETE"

	
	#IFDEF TOP
		// Executa a consulta na tabela de movimento
		BeginSql Alias cQryAlias
		
			SELECT 
				1 
			FROM 
				%Table:TEZ% TEZ
			WHERE 	TEZ.%NotDel% AND TEZ.TEZ_FILIAL = %xFilial:TEZ% AND 
					TEZ.TEZ_PRODUT = %Exp:cCodKit% AND TEZ.TEZ_ITPROD = %Exp:oMdlG:GetValue("TEZ_ITPROD")% AND
			EXISTS ( SELECT 1 FROM %Table:TEW% TEW
			WHERE
				TEW.%NotDel% AND TEW.TEW_FILIAL = %xFilial:TEW% AND  
				TEW.TEW_PRODUT = TEZ.TEZ_ITPROD AND TEW.TEW_CODKIT = TEZ.TEZ_PRODUT )
		
		EndSql
	
		If (cQryAlias)->( !EOF() )
			lRet := .F.
		EndIf
	
	#ENDIF
	


EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At810IsKit
	Verifica se é um kit
@sample 	At810IsKit() 
@since		14/02/2014       
@version	P12
@param  	cChave, CHAR, chave para a consulta
@return 	lRet, LOGIC, pode ou não realizar a exclusão da linha 
/*/
//------------------------------------------------------------------------------
Function At810IsKit( cChave )

Local lRet     := .F.
Local aSave    := GetArea()
Local aSaveTEZ := {}

DEFAULT cChave := ''

If !Empty( cChave )

	DbSelectArea('TEZ')
	
	aSaveTEZ := TEZ->( GetArea() )
	
	TEZ->(DbSetOrder(1)) // TEZ_FILIAL+TEZ_PRODUT+TEZ_ITPROD

	lRet := TEZ->( DbSeek( cChave ) )

	RestArea(aSaveTEZ)

EndIf

RestArea(aSave)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At810GetKit
	Monta a estrutura do kit no formato :: { cod. do prod. item , qtde }
@sample 	At810IsKit() 
@since		14/02/2014       
@version	P12
@param  	cChave, CHAR, chave para a consulta.. Exemplo:  xFilial('TEZ')+SB1->B1_COD
@return 	aRet, ARRAY, estrutura do kit no formato:
				{ { COD PROD ITEM, QUANTIDADE } , { COD PROD ITEM 2, QUANTIDADE }, ... }
/*/
//------------------------------------------------------------------------------
Function At810GetKit( cChave )

Local aKit      := {}
Local aSave    := GetArea()
Local aSaveTEZ := {}

DEFAULT cChave := ''

If !Empty( cChave )

	DbSelectArea('TEZ')
	
	aSaveTEZ := TEZ->( GetArea() )
	
	TEZ->(DbSetOrder(1)) // TEZ_FILIAL+TEZ_PRODUT+TEZ_ITPROD

	If TEZ->( DbSeek( cChave ) )
		
		While TEZ->( !EOF() ) .And. TEZ->(TEZ_FILIAL+TEZ_PRODUT) == cChave
			aAdd( aKit, { TEZ->TEZ_ITPROD, TEZ->TEZ_ITQTDE } )
			TEZ->( DbSkip() )
		End
	
	EndIf

	RestArea(aSaveTEZ)
EndIf

RestArea(aSave)

Return aKit
//------------------------------------------------------------------------------
/*/{Protheus.doc} At810KitHp
	Help da validação do Kit e itens do Kit.
@sample 	At810KitHp() 
@since		26/10/2016       
@version	P12.1.14
@param  	cCodProd , CHAR, chave para a consulta
@return 	lRet, LOGIC, pode ou não realizar inclusão ou alteração
/*/
//------------------------------------------------------------------------------
Static Function At810KitHp(cCodPrd)
Local lRet 		:=	.T.
Default cCodPrd := ""

DbSelectArea("SB5")
SB5->(DbSetOrder(1))	
If SB5->(DbSeek(xFilial("SB5")+cCodPrd))
	If SB5->B5_GSMI == "1"
		lRet := .F.	
		Help( , , "At810KitHp", ,STR0010, 1, 0,,,,,,;
			{STR0011}) //"Produto está configurado como material de implantação." # "Informe o produto que esteja configurado como locação de equipamento."
	Elseif SB5->B5_GSMC == "1"
		lRet := .F.	
		Help( , , "At810KitHp", ,STR0012, 1, 0,,,,,,;
			{STR0011}) //"Produto está configurado como material de consumo." # "Informe o produto que esteja configurado como locação de equipamento."
	Elseif SB5->B5_GSLE == "2"
		lRet := .F.	
		Help( , , "At810KitHp", ,STR0013, 1, 0,,,,,,;
			{STR0011}) //"Produto não está configurado como locação de equipamento." # "Informe o produto que esteja configurado como locação de equipamento."
	Endif	
Else
	lRet := .F.	
	Help( , , "At810KitHp", ,STR0014, 1, 0,,,,,,;
		{STR0011}) //"Produto está configurado como material de implantação." # "Informe o produto que esteja configurado como locação de equipamento."		
Endif

Return lRet
