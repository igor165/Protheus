#Include 'Mdta686.ch'
#include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} mdta686
Monta o Browse da rotina.

@author	Gabriel Sokacheski
@since 01/09/2021

/*/
//-------------------------------------------------------------------
Function mdta686()

    Local aCampos := {;
        'TNY_NUMFIC',;
        'TNY_NOMFIC',;
        'TNY_DTINIC',;
        'TNY_HRINIC',;
        'TNY_DTFIM',;
        'TNY_HRFIM',;
        'TNY_CID',;
        'TNY_EMITEN',;
        'TNY_NOMUSU',;
        'TNY_NATEST',;
        'TNY_DTCONS',;
        'TNY_HRCONS',;
        'TNY_INDMED',;
        'TNY_OCORRE',;
        'TNY_ACIDEN',;
        'TNY_ATEANT';
    }

    Private oMark := FWMarkBrowse():New()

    Private cMarca := GetMark() // Marcação do browse
    Private cTabela := GetNextAlias() // Tabela temporária utilizada na rotina
    Private cProcesso := '' // Variável necessária no fonte gpea240
    Private cPrograma := 'MDTA685' // Variável necessária no fonte mdta685

    oMark:SetAlias( 'TNY' ) // Define da tabela a ser utilizada
    oMark:SetOnlyFields( aCampos ) // Define os campos apresentados em tela
    oMark:SetFieldMark( 'TNY_COMUOK' ) // Define o campo que sera utilizado para a marcação
    oMark:SetFilterDefault( 'TNY_COMUOK != "OK"' )
    oMark:SetDescription( STR0001 ) // "Atestados não comunicados"

    fTabela() // Cria e popula a tabela temporária

    oMark:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Define as opções da rotina.

@author	Gabriel Sokacheski
@since 01/09/2021

@return	aRotina, array, Contendo as opções da rotina..
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

    Local aRotina := {}

    aAdd( aRotina, { STR0002, 'Mdt686Comu', 0, 2, 0, Nil } ) // "Comunicar"
    aAdd( aRotina, { STR0003, 'VIEWDEF.mdta686', 0, 2, 0, Nil } ) // "Visualizar"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface da rotina.

@author	Gabriel Sokacheski
@since 01/09/2021

@return	oView, Objeto, Contendo a interface.
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

    Local oView := FWLoadView( 'mdta685' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} fTabela
Cria e popula uma tabela temporária com os registros que serão
utilizados na rotina.

@author	Gabriel Sokacheski
@since 01/03/2022

/*/
//-------------------------------------------------------------------
Static Function fTabela()

    Local aCampos := {}
    Local aLoadSM0 := FwLoadSM0()

    Local cQuery := GetNextAlias()
    Local cTabFil := GetNextAlias()
    Local cNomTabFil := ''

    Local nI := 0

    Local oTabFil := FwTemporaryTable():New( cTabFil ) // Tabela das filiais que o usuário possui acesso
    Local oTabela := FwTemporaryTable():New( cTabela ) // Tabela de registros da rotina

    aAdd( aCampos, { 'GRUPO', 'C', Len( cEmpAnt ), 0 } )
    aAdd( aCampos, { 'FILIAL', 'C', TamSx3( 'TNY_FILIAL' )[1], 0 } )
    aAdd( aCampos, { 'TNY_FILIAL', 'C', TamSx3( 'TNY_FILIAL' )[1], 0 } )
    aAdd( aCampos, { 'TM0_FILIAL', 'C', TamSx3( 'TM0_FILIAL' )[1], 0 } )
    aAdd( aCampos, { 'TNP_FILIAL', 'C', TamSx3( 'TNP_FILIAL' )[1], 0 } )

    oTabFil:SetFields( aCampos )
    oTabFil:AddIndex( '01', { 'FILIAL' } )
    oTabFil:Create()

    aCampos := {}

    aAdd( aCampos, { 'GRUPO', 'C', Len( cEmpAnt ), 0 } )
    aAdd( aCampos, { 'FILIAL', 'C', TamSx3( 'TNY_FILIAL' )[1], 0 } )
    aAdd( aCampos, { 'TNY_FILIAL', 'C', TamSx3( 'TNY_FILIAL' )[1], 0 } )
    aAdd( aCampos, { 'TNY_NUMFIC', 'C', TamSx3( 'TNY_NUMFIC' )[1], 0 } )
    aAdd( aCampos, { 'TNY_NOMFIC', 'C', TamSx3( 'TNY_NOMFIC' )[1], 0 } )
    aAdd( aCampos, { 'TNY_DTINIC', 'D', TamSx3( 'TNY_DTINIC' )[1], 0 } )
    aAdd( aCampos, { 'TNY_HRINIC', 'C', TamSx3( 'TNY_HRINIC' )[1], 0 } )
    aAdd( aCampos, { 'TNY_DTFIM', 'D', TamSx3( 'TNY_DTFIM' )[1], 0 } )
    aAdd( aCampos, { 'TNY_HRFIM', 'C', TamSx3( 'TNY_HRFIM' )[1], 0 } )
    aAdd( aCampos, { 'TNY_CID', 'C', TamSx3( 'TNY_CID' )[1], 0 } )
    aAdd( aCampos, { 'TNY_EMITEN', 'C', TamSx3( 'TNY_EMITEN' )[1], 0 } )
    aAdd( aCampos, { 'TNY_NOMUSU', 'C', TamSx3( 'TNY_NOMUSU' )[1], 0 } )
    aAdd( aCampos, { 'TNY_NATEST', 'C', TamSx3( 'TNY_NATEST' )[1], 0 } )
    aAdd( aCampos, { 'TNY_DTCONS', 'D', TamSx3( 'TNY_DTCONS' )[1], 0 } )
    aAdd( aCampos, { 'TNY_HRCONS', 'C', TamSx3( 'TNY_HRCONS' )[1], 0 } )
    aAdd( aCampos, { 'TNY_INDMED', 'C', TamSx3( 'TNY_INDMED' )[1], 0 } )
    aAdd( aCampos, { 'TNY_OCORRE', 'C', TamSx3( 'TNY_OCORRE' )[1], 0 } )
    aAdd( aCampos, { 'TNY_ACIDEN', 'C', TamSx3( 'TNY_ACIDEN' )[1], 0 } )
    aAdd( aCampos, { 'TNY_ATEANT', 'C', TamSx3( 'TNY_ATEANT' )[1], 0 } )
    aAdd( aCampos, { 'TNY_COMUOK', 'C', TamSx3( 'TNY_COMUOK' )[1], 0 } )

    oTabela:SetFields( aCampos )
    oTabela:AddIndex( '01', { 'TNY_NUMFIC' } )
    oTabela:AddIndex( '02', { 'TNY_NATEST' } )
    oTabela:AddIndex( '03', { 'TNY_NOMFIC' } )
    oTabela:Create()

    dbSelectArea( cTabFil )

    For nI := 1 To Len( aLoadSM0 )

        If aLoadSM0[ nI, 11 ] // Verifica se o usuário tem acesso a filial

            RecLock( cTabFil, .T. )

                ( cTabFil )->GRUPO := aLoadSM0[ nI, 1 ] // Código do grupo da qual a filial pertence
                ( cTabFil )->FILIAL := aLoadSM0[ nI, 2 ] // Código da filial com todos os níveis
                ( cTabFil )->TNY_FILIAL := xFilial( 'TNY', aLoadSM0[ nI, 2 ] ) // Código da filial com compartilhamento da TNY
                ( cTabFil )->TM0_FILIAL := xFilial( 'TM0', aLoadSM0[ nI, 2 ] ) // Código da filial com compartilhamento da TM0
                ( cTabFil )->TNP_FILIAL := xFilial( 'TNP', aLoadSM0[ nI, 2 ] ) // Código da filial com compartilhamento da TNP

            ( cTabFil )->( MsUnlock() )

        EndIf

    Next nI

    cNomTabFil := oTabFil:GetRealName()

    BeginSQL Alias cQuery
		SELECT
            TNY.TNY_FILIAL, TNY.TNY_NUMFIC, TM0.TM0_NOMFIC, TNY.TNY_DTINIC, TNY.TNY_HRINIC, TNY.TNY_DTFIM, TNY.TNY_HRFIM, TNY.TNY_CID,
            TNY.TNY_EMITEN, TNP.TNP_NOME, TNY.TNY_NATEST, TNY.TNY_DTCONS, TNY.TNY_HRCONS, TNY.TNY_INDMED, TNY.TNY_OCORRE, TNY.TNY_ACIDEN,
            TNY.TNY_ATEANT, FIL.GRUPO, FIL.FILIAL
		FROM
            %table:TNY% TNY
                INNER JOIN %temp-table:cNomTabFil% FIL ON
                    FIL.TNY_FILIAL = TNY.TNY_FILIAL
                INNER JOIN %table:TM0% TM0 ON 
                    TM0.TM0_FILIAL = FIL.TM0_FILIAL
                    AND TM0.TM0_NUMFIC = TNY.TNY_NUMFIC 
                    AND TM0.%notDel% 
                INNER JOIN %table:TNP% TNP ON 
                    TNP.TNP_FILIAL = FIL.TNP_FILIAL
                    AND TNP.TNP_EMITEN = TNY.TNY_EMITEN
                    AND TNP.%notDel%
		WHERE
			TNY.TNY_COMUOK != 'OK'
			AND TNY.%notDel%
        GROUP BY TNY.TNY_FILIAL, TNY.TNY_NUMFIC, TM0.TM0_NOMFIC, TNY.TNY_DTINIC, TNY.TNY_HRINIC, TNY.TNY_DTFIM,
            TNY.TNY_HRFIM, TNY.TNY_CID, TNY.TNY_EMITEN, TNP.TNP_NOME, TNY.TNY_NATEST, TNY.TNY_DTCONS, TNY.TNY_HRCONS,
            TNY.TNY_INDMED, TNY.TNY_OCORRE, TNY.TNY_ACIDEN, TNY.TNY_ATEANT, FIL.GRUPO, FIL.FILIAL
	EndSQL

    ( cTabFil )->( DbCloseArea() )

    ( cQuery )->( DbGoTop() )

    dbSelectArea( cTabela )

    While ( cQuery )->( !EoF() )

        RecLock( cTabela, .T. )

            ( cTabela )->TNY_FILIAL := ( cQuery )->TNY_FILIAL
            ( cTabela )->TNY_NUMFIC := ( cQuery )->TNY_NUMFIC
            ( cTabela )->TNY_NOMFIC := ( cQuery )->TM0_NOMFIC
            ( cTabela )->TNY_DTINIC := StoD( ( cQuery )->TNY_DTINIC )
            ( cTabela )->TNY_HRINIC := ( cQuery )->TNY_HRINIC
            ( cTabela )->TNY_DTFIM := StoD( ( cQuery )->TNY_DTFIM )
            ( cTabela )->TNY_HRFIM := ( cQuery )->TNY_HRFIM
            ( cTabela )->TNY_CID := ( cQuery )->TNY_CID
            ( cTabela )->TNY_EMITEN := ( cQuery )->TNY_EMITEN
            ( cTabela )->TNY_NOMUSU := ( cQuery )->TNP_NOME
            ( cTabela )->TNY_NATEST := ( cQuery )->TNY_NATEST
            ( cTabela )->TNY_DTCONS := StoD( ( cQuery )->TNY_DTCONS )
            ( cTabela )->TNY_HRCONS := ( cQuery )->TNY_HRCONS
            ( cTabela )->TNY_INDMED := ( cQuery )->TNY_INDMED
            ( cTabela )->TNY_OCORRE := ( cQuery )->TNY_OCORRE
            ( cTabela )->TNY_ACIDEN := ( cQuery )->TNY_ACIDEN
            ( cTabela )->TNY_ATEANT := ( cQuery )->TNY_ATEANT
            ( cTabela )->GRUPO := ( cQuery )->GRUPO
            ( cTabela )->FILIAL := ( cQuery )->FILIAL

        ( cTabela )->( MsUnlock() )

        ( cQuery )->( DbSkip() )

    End

    ( cQuery )->( DbCloseArea() )
    ( cTabela )->( dbGoTop() )

Return cTabela

//-------------------------------------------------------------------
/*/{Protheus.doc} fAllMark
Marca ou desmarca todos os registros do browse.

@author	Gabriel Sokacheski
@since 02/03/2022

/*/
//-------------------------------------------------------------------
Static Function fAllMark()

    // As instruções dadas ao markbrowse e a tabela temporária são as mesmas
    oMark:GoTop( .T. )

    While ( cTabela )->( !EoF() )

        oMark:MarkRec()

        ( cTabela )->( DbSkip() )

    End

    oMark:Refresh( .T. )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Mdt686Comu
Comunica os afastamentos dos atestados selecionados.

@author	Gabriel Sokacheski
@since 01/09/2021

/*/
//-------------------------------------------------------------------
Function Mdt686Comu()

    Local cMarca := oMark:Mark() // Retorna identificador do markBrowse
    Local cEmpBkp := cEmpAnt
    Local cFilBkp := cFilAnt

    Local oModel

    Default lBloqFol := .T.

    dbSelectArea( 'TNY' )
    dbSetOrder( 2 )

    While ( cTabela )->( !EoF() )

        If ( cTabela )->TNY_NATEST == ( 'TNY' )->TNY_NATEST .Or. dbSeek( ( cTabela )->TNY_FILIAL + ( cTabela )->TNY_NATEST )

            If oMark:IsMark( cMarca ) .And. ( 'TNY' )->TNY_COMUOK != 'OK'

                If ( cTabela )->FILIAL != cFilAnt

                    cEmpAnt := ( cTabela )->GRUPO
                    cFilAnt := ( cTabela )->FILIAL

                EndIf

                FreeObj( oModel )
                oModel := FWLoadModel( 'mdta685' )
                oModel:SetOperation( 4 )
                oModel:Activate()

                a685Update( Nil, oModel, Nil, .T. )

                If !lBloqFol // Quando o afastamento não foi bloqueado pela folha

                    RecLock( 'TNY', .F. )
                        ( 'TNY' )->TNY_COMUOK := 'OK' // Marca atestado como comunicado na TNY
                    ( 'TNY' )->( MsUnLock() )

                    ( cTabela )->( dbDelete() )

                Else // Caso bloquado, interrompe o processo

                    Exit

                EndIf

            EndIf

        EndIf

        ( cTabela )->( dbSkip() )

    End

    ( cTabela )->( dbGoTop() )

    cEmpAnt := cEmpBkp
    cFilAnt := cFilBkp

Return
