#INCLUDE "JURA154.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA154
Pedido Rh

@author Raphael Zei Cartaxo Silva
@since 01/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA154 ( cProcesso )
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NUN" )
oBrowse:SetLocate()
If !Empty( cProcesso )
	oBrowse:SetFilterDefault( "NUN_CAJURI == '" + cProcesso + "'" )
EndIf	
oBrowse:SetMenuDef( 'JURA154' )  
JurSetBSize( oBrowse, '50,50,50' )
JurSetLeg( oBrowse, "NUN" )
oBrowse:Activate()

Return NIL
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Raphael Zei Cartaxo Silva
@since 01/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA154", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA154", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA154", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA154", 0, 5, 0, NIL } ) // "Excluir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Pedido Rh

@author Raphael Zei Cartaxo Silva
@since 01/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel := FwLoadModel( "JURA154" )
Local cParam := AllTrim( SuperGetMv('MV_JDOCUME',,'1'))  
Local oStructNUN
Local oStructNUP
Local oView
//--------------------------------------------------------------
//Montagem da interface via dicionario de dados
//--------------------------------------------------------------
oStructNUN := FWFormStruct( 2, "NUN" )
oStructNUP := FWFormStruct( 2, "NUP" )

oStructNUP:RemoveField( "NUP_CPEDRH" )

//--------------------------------------------------------------
//Montagem do View normal se Container
//--------------------------------------------------------------
JurSetAgrp( 'NUN',, oStructNUN )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:SetDescription( STR0007 ) // "Pedido Rh"
oView:EnableControlBar( .T. )
oView:SetUseCursor( .T. )


oView:AddField( "JURA154_VIEW" , oStructNUN , "NUNMASTER"  )
oView:AddGrid(  "JURA154_GRID" , oStructNUP , "NUPDETAIL"  )

oView:CreateHorizontalBox( "FORMFIELD", 30 )
oView:CreateHorizontalBox( "GRID"     , 70 )

oView:SetOwnerView( "JURA154_VIEW" , "FORMFIELD"  )
oView:SetOwnerView( "JURA154_GRID" , "GRID"       )

oView:AddIncrementField( "JURA154_GRID", "NUP_COD"  )

If !(cParam == '1' .AND. IsPlugin()) 
	oView:AddUserButton( STR0012, "CLIPS", {| oView | J154RetRecno("NUP_COD"), JURANEXDOC("NUN","NUNMASTER","NUN_CAJURI","NUN_COD","NUP","NUPDETAIL","NUP_COD") } )
EndIf 

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Pedido Rh

@author Raphael Zei Cartaxo Silva
@since 01/07/09
@version 1.0

@obs NUNMASTER - Cabecalho Pedido Rh / NUPDETAIL - Itens Pedido Rh
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStructNUN := NIL
Local oStructNUP := NIL
Local oModel     := NIL

//-----------------------------------------
//Monta a estrutura do formulário com base no dicionário de dados
//-----------------------------------------
oStructNUN := FWFormStruct(1,"NUN")
oStructNUP := FWFormStruct(1,"NUP")

oStructNUP:RemoveField( "NUP_CPEDRH" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MpFormModel():New( "JURA154", /*Pre-Validacao*/, {|oModel| JURA154TOK(oModel)}/*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados da Pedido Rh"

oModel:AddFields( "NUNMASTER", /*cOwner*/, oStructNUN, /*Pre-Validacao*/,/*Pos-Validacao*/)
oModel:AddGrid( "NUPDETAIL", "NUNMASTER" /*cOwner*/, oStructNUP, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )

oModel:GetModel( "NUNMASTER" ):SetDescription( STR0009 ) // "Cabecalho Pedido Rh"
oModel:GetModel( "NUPDETAIL" ):SetDescription( STR0010 ) // "Itens Pedido Rh"

oModel:SetRelation( "NUPDETAIL", { { "NUP_FILIAL", "XFILIAL('NUP')" }, { "NUP_CPEDRH", "NUN_COD" } }, NUP->( IndexKey( 1 ) ) )

//oModel:GetModel( "NUPDETAIL" ):SetUniqueLine( { "NUP_CPEDRH" , "NUP_CTPDOC" } )

JurSetRules( oModel, 'NUNMASTER',, 'NUN' )
JurSetRules( oModel, 'NUPDETAIL',, 'NUP' )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} IsJurTab
Função para calcular a data de audiência pendente mais recente do Assunto Jurídico corrente

@param 	cAssuntoJuridico  	Código do Assunto Jurídico (CAJURI)

@Return dRet	         	Data de retorno

@sample
JUR154PXAU( NUN->NUN_CAJURI )

@author Raphael Zei
@since 09/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR154PXAU( cAssuntoJuridico )
Local dRet   := CTOD('')
Local cTmp   := GetNextAlias()
Local cQuery := ''
Local aArea  := GetArea()

ParamType 0 Var cAssuntoJuridico As Character

cQuery += "  SELECT MIN(NTA_DTFLWP) AUD "
cQuery += "    FROM " + RetSqlName( "NTA" ) + " NTA, "
cQuery += "         " + RetSqlName( "NQS" ) + " NQS, "
cQuery += "         " + RetSqlName( "NQN" ) + " NQN  "
cQuery += "   WHERE NTA_CTIPO  = NQS_COD "
cQuery += "     AND NTA_CRESUL = NQN_COD "
cQuery += "     AND NTA_FILIAL = '" + xFilial( 'NTA' ) + "' "
cQuery += "     AND NQS_FILIAL = '" + xFilial( 'NQS' ) + "' "
cQuery += "     AND NQN_FILIAL = '" + xFilial( 'NQN' ) + "' "
cQuery += "     AND NTA_CAJURI =  '" + cAssuntoJuridico + "' "
cQuery += "     AND NQS_TIPO = 2 "
cQuery += "     AND NQN_TIPO = 1 "
cQuery += "     AND NTA.D_E_L_E_T_ = ' ' "
cQuery += "     AND NQS.D_E_L_E_T_ = ' ' "
cQuery += "     AND NQN.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery( cQuery )

dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cTmp, .T., .F. )

If !(cTmp)->( EOF() )
	dRet := STOD((cTmp)->AUD)
EndIf

(cTmp)->( dbCloseArea() )

RestArea( aArea )

Return dRet     

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA154TOK
Validação ao salvar
             
@param 	oModel  	Model a ser verificado	
@Return lRet	 .T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 24/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURA154TOK( oModel )
Local lRet := .T.
Local nOpc := oModel:GetOperation()
Local cParam := AllTrim( SuperGetMv('MV_JDOCUME',,'1'))  

If nOpc > 2 .And. lRet

	lRet := JURSITPROC(oModel:GetValue("NUNMASTER","NUN_CAJURI"), 'MV_JTVENPH')
	
	If lRet .And. oModel:lModify
		MsgAlert('Alteração realizada com sucesso!','Alterar')
	Endif 
  
	If nOpc == 5
		If cParam == '1'
			lRet := JurExcAnex ('NUP',oModel:GetValue("NUPDETAIL","NUP_COD"))		
			//lRet := JurExcAnex ('NUN',oModel:GetValue("NUNMASTER","NUN_COD"),oModel:GetValue("NUNMASTER","NUN_CAJURI"),'2')		
		Else
			lRet := JurExcAnex ('NUP',oModel:GetValue("NUNMASTER","NUN_COD")+oModel:GetValue("NUPDETAIL","NUP_COD")+oModel:GetValue("NUPDETAIL","NUP_CTPDOC"))		
			//lRet := JurExcAnex ('NUN',oModel:GetValue("NUNMASTER","NUN_COD"),oModel:GetValue("NUNMASTER","NUN_CAJURI"),'2')		
		EndIf
	EndIf	

EndIf  

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J154RetRecno
Retorna o Recno para que seja feita a rotina de anexos

@author Jorge Luis Branco Martins Junior
@since 23/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J154RetRecno(cCod)
	POSICIONE('NUP',2,XFILIAL('NUP')+FwfldGet(cCod),'NUP_COD')
Return 	
