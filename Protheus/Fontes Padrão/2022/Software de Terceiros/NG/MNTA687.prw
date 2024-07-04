#Include 'MNTA687.ch'
#Include 'Protheus.ch'
#INCLUDE 'FWMVCDef.ch'

#Define _nVersao 001 //Vers�o do fonte

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA687
Motivos de Suspens�es de Aluguel

@author Pedro Henrique Soares de Souza
@since 02/08/2014

@return Nil
/*/
//---------------------------------------------------------------------
Function MNTA687()

	Local aNGBeginPrm := NGBeginPrm( _nVersao )
	Local oBrowse

	If !MntCheckCC("MNTA687")
		Return .F.
	EndIf
	
	oBrowse := FWMBrowse():New()
	
		oBrowse:SetAlias( "TVC" )           // Alias da tabela utilizada
		oBrowse:SetMenuDef( "MNTA687" )     // Nome do fonte onde esta a fun��o MenuDef
		oBrowse:SetDescription( STR0001 )   // Descri��o do browse ## "Motivos de Suspens�es de Aluguel"
		
		oBrowse:Activate()
    
	NGReturnPrm(aNGBeginPrm)
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Inicializa MenuDef com todas as op��es

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
    
@author Pedro Henrique Soares de Souza
@since 02/08/2014
/*/
//---------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( 'MNTA687' )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Regras de Modelagem da grava��o

@return oModel

@author Pedro Henrique Soares de Souza
@since 02/08/2014
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

    Local oModel, oStructTVC := FWFormStruct(1, "TVC")

    //Cria o objeto do Modelo de Dados
    oModel := MPFormModel():New("MNTA687", /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)

    //Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
    oModel:AddFields("MNTA687_TVC", Nil, oStructTVC, /*bPre*/, /*bPost*/, /*bLoad*/)

    oModel:SetDescription( STR0001 )

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Regras de Interface com o usu�rio

@return oView

@author Pedro Henrique Soares de Souza
@since 02/08/2014
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

    Local oModel := FWLoadModel("MNTA687")
    Local oView  := FWFormView():New()

    //Objeto do model a se associar a view.
    oView:SetModel(oModel)

    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
    oView:AddField( "MNTA687_TVC", FWFormStruct(2, "TVC"), /*cLinkID*/ )

    //Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox( "MASTER" , 100, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )

    //Associa um View a um box
    oView:SetOwnerView( "MNTA687_TVC" , "MASTER" )

    //Inclus�o de itens nas A��es Relacionadas de acordo com O NGRightClick
	NGMVCUserBtn(oView)
    
Return oView
