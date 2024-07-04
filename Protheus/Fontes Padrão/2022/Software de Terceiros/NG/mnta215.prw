#INCLUDE "MNTA215.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE _nVersao 2 //Versao do fonte

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA215
Cadastro de Ocorr�ncias de Irregularidade

@author Andr� Felipe Joriatti
@since 07/04/2014
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Function MNTA215()

	Local aNGBEGINPRM := NGBEGINPRM( _nVersao )
	Local oBrowse

	// Checa se parametro de irregularidade "MV_NGTNDFL" esta habilidado
	If !NGCHKIRREG()
		Return .T.
	EndIf

	// Seta visualiza��o de vers�o para tecla F9 
	SetKey( VK_F9, { || NGVersao( "MNTA215",_nVersao ) } )

	oBrowse := FWMBrowse():New()
		oBrowse:SetAlias( "TP8" )
		oBrowse:SetMenuDef( "MNTA215" )
		oBrowse:SetDescription( STR0006 ) // "Ocorr�ncias de Irregularidades"
		oBrowse:Activate()

	NGRETURNPRM( aNGBEGINPRM )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Op��es de menu

@author Vitor Emanuel Batista
@since 10/02/2012
@version P11
@return aRotina - Estrutura
	[n,1] Nome a aparecer no cabecalho
	[n,2] Nome da Rotina associada
	[n,3] Reservado
	[n,4] Tipo de Transa��o a ser efetuada:
		1 - Pesquisa e Posiciona em um Banco de Dados
		2 - Simplesmente Mostra os Campos
		3 - Inclui registros no Bancos de Dados
		4 - Altera o registro corrente
		5 - Remove o registro corrente do Banco de Dados
		6 - Altera��o sem inclus�o de registros
		7 - C�pia
		8 - Imprimir
	[n,5] Nivel de acesso
	[n,6] Habilita Menu Funcional
/*/
//---------------------------------------------------------------------

Static Function MenuDef()
// Inicializa MenuDef com todas as op��es
Return FWMVCMenu( "MNTA215" )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Regras de Modelagem da gravacao

@author Andr� Felipe Joriatti
@since 07/04/2014
@version P11
@return Model
/*/
//---------------------------------------------------------------------

Static Function ModelDef()

	Local oModel
	Local oStructTP8

	oStructTP8 := FWFormStruct( 1,"TP8" )

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( "MNTA215",/*bPre*/,,,/*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
	oModel:AddFields( "MNTA215_TP8",Nil,oStructTP8,/*bPre*/,/*bPost*/,/*bLoad*/ )

	// Descri��o do Model
	oModel:SetDescription( STR0006 ) // "Ocorr�ncias de Irregularidades"

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Regras de Interface com o Usuario

@author Andr� Felipe Joriatti
@since 07/04/2014
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Static Function ViewDef()

	Local oModel := FWLoadModel( "MNTA215" )
	Local oView  := Nil

	oStruTP8 := FWFormStruct( 2,"TP8" )

	oView := FWFormView():New()

	// Objeto do model a se associar a view.
	oView:SetModel( oModel )

	// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( "MNTA215_TP8",oStruTP8, /*cLinkID*/ )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( "MASTER",100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )

	// Associa um View a um box
	oView:SetOwnerView( "MNTA215_TP8","MASTER" )

	//Inclus�o de itens nas A��es Relacionadas de acordo com O NGRightClick
	NGMVCUserBtn(oView)

Return oView


//---------------------------------------------------------------------
/*/{Protheus.doc} MNT215VLCP
Valida��es de campos da rotina

@param String cCampo: indica campo para validar
@author Andr� Felipe Joriatti
@since 08/04/2014
@version P11
@return Boolean lRet: conforme valida��o
/*/
//---------------------------------------------------------------------

Function MNT215VLCP( cCampo )

	Local lRet := .T.
	
	If cCampo == "TP8_CODBEM"
		lRet := EXISTCPO("ST9",M->TP8_CODBEM) .And.;
			EXISTCHAV("TP8",M->TP8_CODBEM+M->TP8_CODIRE+DTOS(M->TP8_DTOCOR)+M->TP8_HROCOR)
	ElseIf cCampo == "TP8_CODIRE"
		lRet := EXISTCPO("TP7",M->TP8_CODIRE) .And.;
			EXISTCHAV("TP8",M->TP8_CODBEM+M->TP8_CODIRE+DTOS(M->TP8_DTOCOR)+M->TP8_HROCOR)
	ElseIf cCampo == "TP8_DTOCOR"
		lRet := EXISTCHAV("TP8",M->TP8_CODBEM+M->TP8_CODIRE+DTOS(M->TP8_DTOCOR)+M->TP8_HROCOR)
	ElseIf cCampo == "TP8_HROCOR"
		lRet := NGVALHORA(M->TP8_HROCOR,.T.) .And.;
			EXISTCHAV("TP8",M->TP8_CODBEM+M->TP8_CODIRE+DTOS(M->TP8_DTOCOR)+M->TP8_HROCOR)
	EndIf

Return lRet
