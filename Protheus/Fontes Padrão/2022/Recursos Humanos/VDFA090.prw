#include "VDFA090.CH"
#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFA090()
Cadastramento e controle dos períodos de isenção
de IRPF, e das Perícias a serem Realizadas por
aposentados e pensionistas.
@return	NIL
@author	Everson S P Junior			
@since		30/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDFA090()
Local oBrowse
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( "SRA" )
	oBrowse:SetDescription( STR0008 ) //'Controle de Perícias'
	oBrowse:setfilterdefault("RA_CATFUNC =='9' .Or. RA_CATFUNC =='8' .Or. RA_CATFUNC == '7'")
	oBrowse:AddLegend("SRA->RA_CATFUNC $ '7*8' .AND. SRA->RA_SITFOLH==' '   " , 'BR_CINZA')
	oBrowse:AddLegend("SRA->RA_CATFUNC $ '9'  .AND. SRA->RA_SITFOLH==' '   " , 'BR_LARANJA')
	oBrowse:AddLegend("SRA->RA_RESCRAI$'30/31'" , 'BR_PINK')
	oBrowse:AddLegend("SRA->RA_SITFOLH=='D'" 	, 'BR_VERMELHO')
	oBrowse:Activate()
Return NIL

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menudef
aposentados e pensionistas.
@return	NIL
@author	Everson S P Junior			
@since		30/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina Title 'Visualizar'  Action 'VIEWDEF.VDFA090' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title STR0001  Action 'VIEWDEF.VDFA090' OPERATION 4 ACCESS 0//'Manutenção'
	
	aAdd( aRotina, { STR0002,"VDFA090Leg", 0 , 2,,.F.} )	//"Legenda"	

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} TCFA040Leg()
Legendas do workflow
@author Marcos Pereira	
@since 05/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function VDFA090Leg()
Local aLegenda	:= {}
Local aSvKeys	:= GetKeys()
	
	aLegenda := {;
					{ "BR_CINZA" 	, OemToAnsi( STR0003 ) } ,; //"Aposentado"
					{ "BR_LARANJA"  , OemToAnsi( STR0004 ) } ,; //"Pensionista"				
					{ "BR_PINK"		, OemToAnsi( STR0005 ) } ,; //"Transferido"					
					{ "BR_VERMELHO" , OemToAnsi( STR0006 ) }  ; //"Desligado"
				 }
	BrwLegenda(	STR0008 , STR0002 , aLegenda ) //'Controle de Perícias'###"Legenda"
	RestKeys( aSvKeys )

Return( NIL )


//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Cadastramento e controle dos períodos de insenção
de IRPF, e das Perícias a serem Realizadas por
aposentados e pensionistas.
@return	NIL
@author	Everson S P Junior			
@since		30/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruSRA := FWFormStruct( 1, 'SRA', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruRIP := FWFormStruct( 1, 'RIP', /*bAvalCampo*/, /*lViewUsado*/ )
Local bCpoInit1
Local bVldInisen
Local bLinePre
Local bLinePost
Local cCposLib
Local oModel

	cCposLib := "RA_FILIAL,RA_MAT,RA_NOME,RA_ADMISSA"
	SX3->(DbSetOrder(1))
	SX3->(MsSeek("SRA"))
	While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SRA"
		If (!Alltrim(SX3->X3_CAMPO) $ cCposLib) .AND. X3USO(SX3->X3_USADO)
			oStruSRA:SetProperty(Alltrim(SX3->X3_CAMPO), MODEL_FIELD_OBRIGAT, .F. )
		EndIf
		SX3->(dbSkip())
	EndDo


	bCpoInit1  := {|| oModel:GetValue("SRAMASTER", "RA_NOME") } 
	bVldInisen := {|oGrid, nLine, cAction| fVldInisen(oGrid, nLine, cAction)}
	bLinePre   := {|oGrid, nLine, cAction| Vdf90Pre(oGrid, nLine, cAction)}
	oStruRIP:SetProperty('RIP_NOME'  , MODEL_FIELD_INIT   , bCpoInit1 )
	oStruRIP:SetProperty('RIP_MAT'   , MODEL_FIELD_OBRIGAT,.F.)
	oStruRIP:SetProperty('RIP_INISEN', MODEL_FIELD_VALID  , bVldInisen )
	oStruRIP:SetProperty('RIP_INISEN', MODEL_FIELD_WHEN  , bLinePre)
	oStruRIP:SetProperty('RIP_DTPERI', MODEL_FIELD_WHEN  , bLinePre)
	oStruRIP:SetProperty('RIP_FINISE', MODEL_FIELD_WHEN  , bLinePre)

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'VDFA090MVC', /*bPreValidacao*/, /*bPOSValidacao*/ , /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'SRAMASTER', /*cOwner*/, oStruSRA,/* bLOkVld*/, /*bTOkVld*/,/* bLoad*/ )

	bLinePost := {|oGrid| Vdf90LinOk(oGrid)} 
	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid( 'RIPDETAIL', 'SRAMASTER', oStruRIP, /*bLinePre*/, bLinePost, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation( 'RIPDETAIL', { { 'RIP_FILIAL', 'xFilial( "SRA" )' }, { 'RIP_MAT', 'RA_MAT' } }, RIP->( IndexKey( 1 ) ) )

	// Liga o controle de nao repeticao de linha
	oModel:GetModel( 'RIPDETAIL' ):SetUniqueLine( { 'RIP_INISEN' } )

	// Indica que é opcional ter dados informados na Grid
	oModel:GetModel( 'RIPDETAIL' ):SetOptional(.T.)

	oModel:GetModel( 'SRAMASTER' ):SetOnlyView(.T.)

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( 'Controle de Perícias' )
	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'SRAMASTER' ):SetDescription( STR0007 )//'Dados do Servidor/Membro'
	oModel:GetModel( 'RIPDETAIL' ):SetDescription( STR0008  )//'Controle de Perícias'

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Cadastramento e controle dos períodos de insenção
de IRPF, e das Perícias a serem Realizadas por
aposentados e pensionistas.
@return	NIL
@author	Everson S P Junior			
@since		30/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local cCposLib := ""
Local oStruSRA := FWFormStruct( 2, 'SRA' )
Local oStruRIP := FWFormStruct( 2, 'RIP' )
// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'VDFA090' )
Local oView

	cCposLib := "RA_FILIAL,RA_MAT,RA_NOME,RA_ADMISSA"
	SX3->(DbSetOrder(1))
	SX3->(MsSeek("SRA"))
	While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SRA"
		If (!Alltrim(SX3->X3_CAMPO) $ cCposLib) .AND. X3USO(SX3->X3_USADO)
			oStruSRA:RemoveField(Alltrim(SX3->X3_CAMPO))
		EndIf
		SX3->(dbSkip())
	EndDo

	oStruSRA:SetNoFolder()
	oStruRIP:RemoveField('RIP_MAT')

	// Cria o objeto de View
	oView := FWFormView():New()
	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_SRA', oStruSRA, 'SRAMASTER' )

	//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid(  'VIEW_RIP', oStruRIP, 'RIPDETAIL' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 20 )
	oView:CreateHorizontalBox( 'INFERIOR', 80 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_SRA', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_RIP', 'INFERIOR' )

	oView:EnableTitleView('VIEW_SRA',STR0007 )//'Dados do Servidor/Membro'
	oView:EnableTitleView('VIEW_RIP',STR0008 )//'Controle de Perícias'
	
	oView:SetCloseOnOk({ || .T. }) //Não exibe o botão "Salvar e Criar Novo"

Return oView


//------------------------------------------------------------------------------
/*/{Protheus.doc} Vdf90LinOk()
Validação Linha OK do modelo
@return	lRet, lógico, resultado da validação do modelo
@author	esther.viveiro
@since		25/09/2018
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function Vdf90LinOk(oGrid)
Local lRet	:= .T.
Local nLine	:= oGrid:GetLine()

	If !oGrid:IsDeleted() .AND. !oGrid:IsInserted() .AND. oGrid:IsUpdated() //linha foi alterada
		RIP->(DbGoTo( oGrid:GetDataId(nLine)))
		If !(oGrid:GetValue("RIP_INISEN") == RIP->RIP_INISEN) .OR. !(oGrid:GetValue("RIP_FINISE") == RIP->RIP_FINISE)
			//Se data de email preenchida RIP_DTENVI -E- data Inicio/Fim alteradas RIP_INISEN e RIP_FINISE
			//-- limpar o campo DataEnvio E-mail
			oGrid:ClearField("RIP_DTENVI")
		EndIf
	EndIf

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} Vdf90Pre()
Validação para alteração dos campos RIP_INISEN e RIP_FINISE. 
Não permite alterar período de vigência que já foram concluídos.
@author		esther.viveiro
@since		25/09/2018
@version	P12
@param		oGrid, objeto, informações do grid em alteração.
@return		lRet, lógico, resultado da validação do modelo
/*/
//------------------------------------------------------------------------------
Static Function Vdf90Pre(oGrid)
Local lRet	:= .T.
Local nLine	:= oGrid:GetLine()

	If !oGrid:IsDeleted() .AND. !oGrid:IsInserted() .AND. nLine < oGrid:Length() .AND. !Empty(oGrid:GetValue("RIP_DTENVI",nLine+1)) .AND. !Empty(oGrid:GetValue("RIP_DTPERI"))
	//Quando a linha não é a última ou penúltima (sendo que o e-mail da última não foi enviado) - Não permite alterar registro
		Help(,,"Help",,OemToAnsi(STR0014),1,0) //"Registro não pode ser alterado. Apenas períodos de vigência em andamento ou não iniciados podem ser alterados."
		lRet := .F.
	EndIf

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} fVldInisen()
Validação do campo RIP_INISEN. Não é permitido inclusão de período de vigência com data menor à vigência anterior.
@author		esther.viveiro
@since		25/09/2018
@version	P12
@param		oGrid, objeto, informações do grid em alteração.
@return		lRet, lógico, resultado da validação do modelo
/*/
//------------------------------------------------------------------------------
Static Function fVldInisen(oGrid) 
Local lRet	:= .T.
Local nLine	:= oGrid:GetLine()

	If oGrid:IsInserted() .AND. nLine > 1 //não é a primeira linha
		If oGrid:GetValue("RIP_INISEN",nLine) < oGrid:GetValue("RIP_FINISE",nLine-1) //se o novo periodo for menor que o ultimo, nao permite inclusao
			Help(,,"Help",,OemToAnsi(STR0015),1,0) //"Início do novo período de Isenção deve ser posterior ao final do último período cadastrado."
			lRet := .F.
		EndIf
	EndIf

Return lRet