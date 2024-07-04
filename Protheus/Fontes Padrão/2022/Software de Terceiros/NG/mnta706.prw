#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'MNTA706.CH'

Static lIntFin := SuperGetMv( 'MV_NGMNTFI', .F., 'N' ) == 'S' // Integra��o com m�dulo Financeiro (SIGAFIN)

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA706
Programa de Cadastro de Documentos

@type function

@author Cristiano Kair
@since 29/05/2020

@return Nil
/*/
//---------------------------------------------------------------------
Function MNTA706()

    If FindFunction('NGREL27OUT') .And. NGREL27OUT()

        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias( 'TS0' )
        oBrowse:SetDescription( STR0001 ) //'Cadastro de Documentos'
        oBrowse:Activate()

    Else

        Help( , , STR0002,; // "Aten��o"
                , STR0003, 1, 0 ) // "A rotina MNTA706 est� dispon�vel apenas a partir do release 12.1.27 Outubro"

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Defini��o do Menu

@type static function

@author Cristiano Kair
@since 29/05/2020

@return Objeto, Objeto do Modelo MVC
/*/
//---------------------------------------------------------------------

Static Function MenuDef()
//Inicializa MenuDef com todas as op��es
Return FWMVCMenu( 'MNTA706' )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados da rotina

@type static function

@author Cristiano Kair
@since 29/05/2020

@return Objeto, Objeto do Modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

    Local oModel
    Local oStruTS0 := FWFormStruct( 1, 'TS0' )

    oModel := MPFormModel():New( 'MNTA706', /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/ )
    oModel:SetDescription( STR0001 ) //'Cadastro de Documentos'
    oModel:AddFields( 'MNTA706_TS0', /*cOwner*/, oStruTS0 )

    // Bloco de c�digo para validar a ativa��o do modelo
    oModel:SetVldActivate( { |oModel| ValidActv() } )

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface da rotina

@type static function

@author Cristiano Kair
@since 29/05/2020

@return Objeto, Objeto da View MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

    Local oModel  := FWLoadModel( 'MNTA706' )
    Local oStrTS0 := FWFormStruct( 2, 'TS0' )
    Local oView

    oView := FWFormView():New()
    oView:SetModel( oModel )

    oView:AddField( 'MNTA706_TS0', oStrTS0 )

    oView:CreateHorizontalBox( 'BOX_MNTA706_TS0', 100 )
    oView:SetOwnerView( 'MNTA706_TS0', 'BOX_MNTA706_TS0' )

	NGMVCUserBtn( oView )

Return oView

//----------------------------------------------------------------------------
/*/{Protheus.doc} ValidActv
Fun��o respons�vel por validar a ativa��o do modelo de dados.

@type static function

@author Cristiano Kair
@since 22/06/2020

@return L�gico, Retorna verdadeiro caso a ativa��o seja permitida.
/*/
//----------------------------------------------------------------------------
Static Function ValidActv()

	Local lRetorno := .T.

    If !FindFunction('NGREL27OUT') .Or. !NGREL27OUT()

        Help( , , STR0002,;//"Aten��o"
                , STR0003, 1, 0 )//"A rotina MNTA706 est� dispon�vel apenas a partir do release 12.1.27 Outubro."

		lRetorno := .F.

	Endif

Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA706VLD
Fun��o de valida��o dos campos do modelo.
Presente no X3_VALID.

@type Static Function
@version V12

@author Cristiano Kair
@since 17/06/2020

@param cCampo, caracter, campo

@return L�gico, Retorna .T. se validar regras de neg�cio
/*/
//---------------------------------------------------------------------
Function MNTA706VLD( cCampo )

	Local oModel    := FWModelActive()
    Local oModelTS0 := oModel:GetModel( 'MNTA706_TS0' )
    Local lRetorno  := .T.

	Default cCampo := ''

    Do Case

        //--------------------------------------------------------------------------
        // TS0_DOCTO - Codigo da Taxa
        //--------------------------------------------------------------------------
        Case cCampo == 'TS0_DOCTO'

            // Consiste a chave �nica da tabela
            If !Empty( oModelTS0:GetValue( cCampo ) )
                lRetorno := ExistChav( 'TS0', oModelTS0:GetValue( cCampo ) )
            EndIf

        //--------------------------------------------------------------------------
        // TS0_VALID - Validade do Documento
        //--------------------------------------------------------------------------
        Case cCampo == 'TS0_VALID'

            // A validade deve ser maior que zero
            If !Empty( oModelTS0:GetValue( cCampo ) )
                lRetorno := Positivo( oModelTS0:GetValue( cCampo ) )
            EndIf

        //--------------------------------------------------------------------------
        // TS0_UNIDAD - Unidade
        //--------------------------------------------------------------------------
        Case cCampo == 'TS0_UNIDAD'

            // A unidade deve ser uma das op��es dispon�veis no combobox
            If !Empty( oModelTS0:GetValue( cCampo ) )
                lRetorno := Pertence( '12', oModelTS0:GetValue( cCampo ) )
            EndIf

        //--------------------------------------------------------------------------
        // TS0_AVIVEN - Dias Aviso Antes Vencimento
        //--------------------------------------------------------------------------
        Case cCampo == 'TS0_AVIVEN'

            // Dias de Ativo deve ser maior que zero
            If !Empty( oModelTS0:GetValue( cCampo ) )
                lRetorno := Positivo( oModelTS0:GetValue( cCampo ) )
            EndIf

        //--------------------------------------------------------------------------
        // TS0_TIPO - Tipo do T�tulo
        //--------------------------------------------------------------------------
        Case cCampo == 'TS0_TIPO'

            // Tipo deve ser v�lido, existindo no SX5
            If !Empty( oModelTS0:GetValue( cCampo ) )
                lRetorno := ExistCpo( 'SX5','05' + oModelTS0:GetValue( cCampo ) )
            EndIf

        //--------------------------------------------------------------------------
        // TS0_NATURE - C�digo da Natureza
        //--------------------------------------------------------------------------
        Case cCampo == 'TS0_NATURE'

            // Natureza deve ser v�lida, existindo na SED
            If !Empty( oModelTS0:GetValue( cCampo ) )
                lRetorno := ExistCpo( 'SED', oModelTS0:GetValue( cCampo ) )
            EndIf

        //--------------------------------------------------------------------------
        // TS0_FORNEC - C�digo do Fornecedor
        //--------------------------------------------------------------------------
        Case cCampo == 'TS0_FORNEC'

            // Fornecedor deve ser v�lida, existindo na SA2
            If !Empty( oModelTS0:GetValue( cCampo ) )
                lRetorno := ExistCpo( 'SA2', oModelTS0:GetValue( cCampo ) )
            EndIf

        //--------------------------------------------------------------------------
        // TS0_LOJA - Loja do Fornecedor
        //--------------------------------------------------------------------------
        Case cCampo == 'TS0_LOJA'

            // Fornecedor e Loja devem ser v�lidos, existindo na SA2
            If !Empty( oModelTS0:GetValue( cCampo ) )
                lRetorno := ExistCpo( 'SA2', oModelTS0:GetValue( 'TS0_FORNEC' ) + oModelTS0:GetValue( cCampo ) )
            EndIf

        //--------------------------------------------------------------------------
        // TS0_CONPAG - Condi��o de Pagamento
        //--------------------------------------------------------------------------
        Case cCampo == 'TS0_CONPAG'

            // Condi��o de Pagamento deve ser v�lida, existindo na SE4
            If !Empty( oModelTS0:GetValue( cCampo ) )
                lRetorno := ExistCpo( 'SE4', oModelTS0:GetValue( cCampo ) )
            EndIf

    EndCase

Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA706WHE
Fun��o de modo de edi��o dos campos do modelo.
Presente no X3_WHEN.

@type Static Function
@version V12

@author Cristiano Kair
@since 17/06/2020

@param cCampo, caracter, Campo que est� sendo verificado

@return L�gico, Define se o campo ser� aberto para edi��o.
/*/
//---------------------------------------------------------------------
Function MNTA706WHE( cCampo )

	Local lRetorno := .T.

	Default cCampo := ''

    Do Case

        //--------------------------------------------------------------------------
        // TS0_TIPO - Tipo do T�tulo
        //--------------------------------------------------------------------------
        Case cCampo == 'TS0_TIPO'
            lRetorno := lIntFin

        //--------------------------------------------------------------------------
        // TS0_NATURE - C�digo da Natureza
        //--------------------------------------------------------------------------
        Case cCampo == 'TS0_NATURE'
            lRetorno := lIntFin

        //--------------------------------------------------------------------------
        // TS0_PREFIX - Prefixo do T�tulo
        //--------------------------------------------------------------------------
        Case cCampo == 'TS0_PREFIX'
            lRetorno := lIntFin

    EndCase


Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA706INI
Fun��o de inicializador padr�o dos campos do modelo.
Presente no X3_RELACAO.

@type Static Function
@version V12

@author Cristiano Kair
@since 17/06/2020

@param cCampo, caracter, Campo que est� sendo verificado

@return L�gico, Preenche campos virtuais e campos que necessitam de
                valores padr�es j� na inclus�o
/*/
//---------------------------------------------------------------------
Function MNTA706INI( cCampo )

	Local xRetorno

	Default cCampo := ''

    Do Case

        //--------------------------------------------------------------------------
        // TS0_UNIDAD - Unidade
        //--------------------------------------------------------------------------
        Case cCampo == 'TS0_UNIDAD'
            xRetorno := '1' // Dias

        //--------------------------------------------------------------------------
        // TS0_NOMFOR - Nome do Fornecedor
        //--------------------------------------------------------------------------
        Case cCampo == 'TS0_NOMFOR'
            xRetorno := IIf( Inclui, '', Posicione( 'SA2', 1, xFilial( 'SA2' ) + TS0->TS0_FORNEC + TS0->TS0_LOJA , 'A2_NOME' ) )

    EndCase


Return xRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA706INB
Fun��o de inicializador de browse dos campos do modelo.
Presente no X3_INIBRW.

@type Static Function
@version V12

@author Cristiano Kair
@since 17/06/2020

@param cCampo, Caracter, Campo que est� sendo verificado

@return L�gico, Preenche campo virtual no browse
/*/
//---------------------------------------------------------------------
Function MNTA706INB( cCampo )

	Local xRetorno

	Default cCampo := ''

    Do Case

        //--------------------------------------------------------------------------
        // TS0_NOMFOR - Nome do Fornecedor
        //--------------------------------------------------------------------------
        Case cCampo == 'TS0_NOMFOR'
            xRetorno := Posicione( 'SA2', 1, xFilial( 'SA2' ) + TS0->TS0_FORNEC + TS0->TS0_LOJA , 'A2_NOME' )

    EndCase

Return xRetorno
