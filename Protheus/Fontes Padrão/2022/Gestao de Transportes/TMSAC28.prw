#INCLUDE 'TMSAC28.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-----------------------------------------------------------------
/*/{Protheus.doc} 	TMSAC28()
Cadastro regra de quitação para frete pagbem

@author     Rodrigo Pirolo
@since      18/01/2022
@version    12.1.31
/*/
//-----------------------------------------------------------

Function TMSAC28()

	Local oBrowse   := Nil
	Local aArea     := GetArea()

	Private aRotina := MenuDef()
	Private cTitulo := STR0001 // "Regras de Quitação do Frete PagBem"

    DbSelectArea("DMZ")
    DMZ->( DbSetOrder(1) )
	If LockByName( 'TMSAC28', .T. )
		//-- Cria browse
		oBrowse := FWMBrowse():New()

		oBrowse:SetAlias( "DMZ" )
        oBrowse:SetMenuDef( "TMSAC28" )
		oBrowse:SetDescription( cTitulo )
		oBrowse:Activate()

	Else
		Help( , , "INFO", , STR0002, 1, 0, , , , , , { STR0003 } ) // STR0002 "O cadastro esta em uso por outro ususario!" STR0003 "Aguarde ou solicite controle sobre a manutenção!"
	EndIf

	RestArea(aArea)

Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Utilizacao de menu Funcional  Uso: TMSAC10

@sample     //MenuDef()
@author     Rodrigo Pirolo
@since      18/01/2022
@version    1.0
/*/
//-----------------------------------------------------------

Static Function MenuDef()

    Local aRotina := {}

    ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.TMSAC28" 	OPERATION 2 ACCESS 0 // "Visualizar"
    ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.TMSAC28"	OPERATION 3 ACCESS 0 // "Incluir"
    ADD OPTION aRotina TITLE STR0007  ACTION "VIEWDEF.TMSAC28" 	OPERATION 4 ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE STR0008  ACTION "VIEWDEF.TMSAC28" 	OPERATION 5 ACCESS 0 // "Excluir"

Return aRotina 

//-----------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do Modelo Uso: TMSAC10

@sample     //ModelDef()
@author     Rodrigo Pirolo
@since      18/01/2022
@version    1.0
/*/
//-----------------------------------------------------------

Static Function ModelDef()

    Local oModel	:= Nil		// Objeto do Model
    Local oStruDMZ	:= Nil		// Recebe a Estrutura da tabela DMZ
    Local bCommit	:= { |oMdl| CommitMdl( oMdl ) }
    Local bPosValid := { |oModel| PosVldMdl( oModel ) }
    Local aTrigger := {}

    oStruDMZ:= FWFormStruct( 1, "DMZ" )

    //FwStruTrigger: ( cDom, cCDom, cRegra, lSeek, cAlias, nOrdem, cChave, cCondic )        
    aTrigger := FwStruTrigger( 'DMZ_TIPTOL', 'DMZ_LIMEXC', "TAC28Gat()", .F., , , , )
    oStruDMZ:AddTrigger(    aTrigger[1],; // [01] identificador (ID) do campo de origem
                            aTrigger[2],; // [02] identificador (ID) do campo de destino
                            aTrigger[3],; // [03] Bloco de código de validação da execução do gatilho
                            aTrigger[4] ) // [04] Bloco de código de execução do gatilho
    
    aTrigger := FwStruTrigger( 'DMZ_TIPTOL', 'DMZ_QUIEXC', "TAC28Gat()", .F., , , , )
    oStruDMZ:AddTrigger(    aTrigger[1],; // [01] identificador (ID) do campo de origem
                            aTrigger[2],; // [02] identificador (ID) do campo de destino
                            aTrigger[3],; // [03] Bloco de código de validação da execução do gatilho
                            aTrigger[4] ) // [04] Bloco de código de execução do gatilho

    aTrigger := FwStruTrigger( 'DMZ_TIPTOL', 'DMZ_PORQUE', "TAC28Gat()", .F., , , , )
    oStruDMZ:AddTrigger(    aTrigger[1],; // [01] identificador (ID) do campo de origem
                            aTrigger[2],; // [02] identificador (ID) do campo de destino
                            aTrigger[3],; // [03] Bloco de código de validação da execução do gatilho
                            aTrigger[4] ) // [04] Bloco de código de execução do gatilho

    aTrigger := FwStruTrigger( 'DMZ_TIPTOL', 'DMZ_QUIQUE', "TAC28Gat()", .F., , , , )
    oStruDMZ:AddTrigger(    aTrigger[1],; // [01] identificador (ID) do campo de origem
                            aTrigger[2],; // [02] identificador (ID) do campo de destino
                            aTrigger[3],; // [03] Bloco de código de validação da execução do gatilho
                            aTrigger[4] ) // [04] Bloco de código de execução do gatilho

    oModel := MPFormModel():New( "TMSAC10", , bPosValid, bCommit /*bCommit*/, /*bCancel*/ ) 

    oModel:AddFields( 'MdFieldDMZ', , oStruDMZ, , , /*Carga*/ )
    oModel:GetModel( 'MdFieldDMZ' ):SetDescription( STR0001 )   //"Controle Parâmetros do CheckList"
    oModel:SetPrimaryKey( { "DMZ_FILIAL", "DMZ_CODIGO"} )
    oModel:SetActivate()
     
Return oModel 

//-----------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da View Uso: TMSAC28

@sample     //ViewDef()
@author     Rodrigo Pirolo
@since      18/01/2022
@version    1.0
/*/
//-----------------------------------------------------------

Static Function ViewDef()

    Local oModel    := Nil		// Objeto do Model 
    Local oStruDMZ  := Nil		// Recebe a Estrutura da tabela DMZ
    Local oView					// Recebe o objeto da View

    oModel      := FwLoadModel("TMSAC28")
    oStruDMZ    := FWFormStruct( 2, "DMZ" )

    oView       := FwFormView():New()

    oView:SetModel(oModel)     
    oView:AddField( 'VwFieldDMZ', oStruDMZ, 'MdFieldDMZ' )
    oView:CreateHorizontalBox( 'CABECALHO', 100 )
    oView:SetOwnerView( 'VwFieldDMZ', 'CABECALHO' )

Return oView

//-----------------------------------------------------------------
/*/{Protheus.doc} TAC28Gat()
Função para zerar os campos de porcentagem e quilos ao mudar o
tipo de tolerância.

@sample     //CommitMdl()
@author     Rodrigo Pirolo
@since      18/01/2022
@version    1.0
/*/
//-----------------------------------------------------------

Function TAC28Gat()

    Local nRet := 0

    nRet    := 0

Return nRet

//-----------------------------------------------------------------
/*/{Protheus.doc} CommitMdl()
Definição da CommitMdl Uso: TMSAC28

@sample     //CommitMdl()
@author     Rodrigo Pirolo
@since      18/01/2022
@version    1.0
/*/
//-----------------------------------------------------------

Static Function CommitMdl(oModel)

	Begin Transaction
		FwFormCommit(oModel ,/*bBefore*/,/*bAfter*/,/*bAfterSTTS*/)
	End Transaction

Return .T.

//-----------------------------------------------------------
/*/{Protheus.doc} PosVldMdl()
pos validações Uso: TMSAO52

@sample     //ViewDef()
@author     Rodrigo Pirolo
@since      18/01/2022
@version    1.0
/*/
//-----------------------------------------------------------

Static Function PosVldMdl(oModel)

    Local lRet			:= .T. 
    Local aAreaDMZ		:= DMZ->(GetArea())
    Local nOperation	:= oModel:GetOperation()
    Local cAliasQry		:= ""

    If ( nOperation == 3 .Or. nOperation == 4 ) .And. FwFldGet("DMZ_PADRAO") == "1"

        cAliasQry	:= GetNextAlias()

        cQuery	:= " SELECT DMZ.DMZ_CODIGO "
        cQuery	+= " FROM " + RetSQLName("DMZ") + " DMZ "
        cQuery	+= " WHERE DMZ_FILIAL = '" + xFilial("DMZ") + "' "
        cQuery	+= " AND DMZ_CODIGO <> '" + FwFldGet("DMZ_CODIGO")  + "' "
        cQuery	+= " AND DMZ_PADRAO = '1' " //-- Desbloqueado
        cQuery	+= " AND DMZ.D_E_L_E_T_ = '' "
                                
        DbUseArea( .T., 'TOPCONN', TCGENQRY( , , cQuery ), cAliasQry, .F., .T. )

        If (cAliasQry)->( !Eof() )
            lRet	:= .F. 
        EndIf

        (cAliasQry)->( DbCloseArea() )
        
        If !lRet
            Help( "", 1, "TMSAC2801", , STR0009, 1, 0, , , , , , { STR0010 } ) // STR0009 "Este cadastro permite apenas uma regra padrão no Sistema." STR0010 "Se necessita cadastrar uma nova regra padrão, altere regra padrão antiga para efetivar esta nova regra."
        EndIf

    EndIf

    RestArea(aAreaDMZ)

Return lRet
