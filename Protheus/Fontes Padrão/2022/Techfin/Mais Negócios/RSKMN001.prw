#Include 'Protheus.ch'
#INCLUDE "RSKMN001.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RSKMN001
Esta rotina apresenta ao usuário a tela para execução da função de 
ajuste das chaves duplicadas que podem ocorrer na tabela AGB, após a 
atualização do X2_UNICO desta tabela.

@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author Marcia Junko
@since 05/11/2021
/*/
//-------------------------------------------------------------------
Main Function RSKMN001( lAutomato )
    Local   aSay      := {}
    Local   aButton   := {}
    Local   aMarcadas := {}
    Local   cTitulo   := STR0001    //"ATUALIZAÇÃO DE BASE DE DADOS"
    Local   cDesc1    := STR0002    //"Este processo tem como finalidade ajustar as chaves duplicadas que podem ocorrer na "
    Local   cDesc2    := STR0003    //"tabela AGB, após a atualização do X2_UNICO desta tabela para uso do Mais Negócios."
    Local   lOk       := .F.
    
    Default lAutomato := .F.

    Private oMainWnd  := NIL
    Private oProcess  := NIL

    //----------------------------------------------------------------------
    // À partir da release 12.1.33 este ajuste é realizado por um RBE chamado 
    // dentro do UPDDISTR, mas como funções do tipo RBE são chamadas somente 
    // em migrações de release, foi necessário criar esta rotina para executar 
    // a validação e ajuste de possíveis chaves duplicadas na tabela AGB, 
    // utilizado pelo produto Mais Negócios e que devido à Carol, necessita 
    // que as tabelas tenham o X2_UNICO informado e como esta tabela é antiga, 
    // pode haver duplicidade na base de dados.
    // O produto Mais Negócios é disponibilizado à partir da release 12.1.25
    //----------------------------------------------------------------------
    If lAutomato .Or. ( GetRPORelease() == "12.1.025" .Or. GetRPORelease() == "12.1.027" )

        TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top

        __cInterNet := NIL
        __lPYME     := .F.

        Set Dele On

        // Mensagens de Tela Inicial
        aAdd( aSay, cDesc1 )
        aAdd( aSay, cDesc2 )

        // Botoes Tela Inicial
        aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
        aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

        If !lAutomato
            FormBatch(  cTitulo,  aSay,  aButton )
        ENDIF

        If lOk .Or. lAutomato
            aMarcadas := EscEmpresa( lAutomato )
            If Len( aMarcadas ) > 0
                If lAutomato .Or. MsgNoYes( STR0004, cTitulo )  //"Deseja realmente executar essa operação?"
                    If !lAutomato 
                        oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAutomato ) }, STR0005, STR0006, .F. )    //"Atualizando"###"Aguarde, atualizando tabela AGB..."                
                        oProcess:Activate()
                    else
                        lOk := FSTProc( .F., aMarcadas, lAutomato )
                    EndIf
                    
                    If lOk
                        IW_MsgBox( STR0007, "UPD AGB", "INFO" )     //"Processo de atualização concluído."
                    Else
                        IW_MsgBox( STR0008, "UPD AGB", "STOP" )     //"Processo de atualização não concluído."
                    EndIf
                Else
                    IW_MsgBox( STR0009, "UPD AGB", "ALERT" )    //"Processo abortado pelo usuário."
                EndIf
            Else
                IW_MsgBox( STR0010, "UPD AGB", "ALERT" )    //"Por favor, selecione ao menos 1 Empresa \ Filial para prosseguir com o processamento"
            EndIf
        EndIf

        If !lAutomato 
            RpcClearEnv()
        EndIf
    else
        ApMsgStop( STR0029 )    //"Esta rotina está disponível para execução nos releases 12.1.25 e 12.1.27. Para o release 12.1.33 ou posteriores, o processo será executado automanticamente pelo UPDDISTR."
    EndIf
Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Chama a rotina de ajuste do Faturamento (RBE_TMK)
@param @lEnd, boolean, variável de controle
@param aMarcadas, array, lista de empresas

@author Marcia Junko
@since 05/11/2021
/*/
//-------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lAutomato )
    Local lRet      := .T.
    Local nInd      := 0

    Default lAutomato := .F.

    Private aArqUpd   := {}
    Public oMsgItem3

    RpcClearEnv()
    RpcSetType( 3 )

    If !lAutomato
        oProcess:SetRegua1( len( aMarcadas ) )
        oProcess:IncRegua1( STR0011 + Alltrim( Str( nInd ) ) + '\' + Alltrim( Str( Len( aMarcadas ) ) ) )   //"Ajustando registros: " 
        oProcess:SetRegua2( 1 )
    EndIf
    For nInd := 1 To Len( aMarcadas )
        If !lAutomato
            oProcess:IncRegua1( STR0011 + Alltrim( Str( nInd ) ) + '\' + Alltrim( Str( Len( aMarcadas ) ) ) )   //"Ajustando registros: " 
            oProcess:IncRegua2( STR0012 + aMarcadas[ nInd ][ 01 ] )     //"Efetuando ajuste para a empresa "
        EndIf
        lRet := RpcSetEnv( aMarcadas[ nInd ][ 01 ], aMarcadas[ nInd ][ 02 ] )

        If !( lRet )
            ConOut( '[ '+ Dtoc( MsDate() ) +' ][ '+ Time() +' ] - ' + STR0013 + ' [ '+ aMarcadas[ nInd ][ 01 ] +' ][ '+ aMarcadas[ nInd ][ 02 ] +' ]' )     //"Não foi possivel inicializar o ambiente da Empresa "
        Else
            If lRet
                RBE_TMK( NIL, '1' )
            EndIf
        EndIf
    Next 
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} EscEmpresa
Apresenta a tela de seleção de empresas

@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@return array, lista de empresas selecioandas.
@author Marcia Junko
@since 05/11/2021
/*/
//-------------------------------------------------------------------
Static Function EscEmpresa( lAutomato )
    Local   aRet     := {}
    Local   aVetor   := {}
    Local   oDlg     := NIL
    Local   oChkMar  := NIL
    Local   oLbx     := NIL
    Local   oMascEmp := NIL
    Local   oButMarc := NIL
    Local   oButDMar := NIL
    Local   oButInv  := NIL
    Local   oSay     := NIL
    Local   oOk      := LoadBitmap( GetResources(), "LBOK" )
    Local   oNo      := LoadBitmap( GetResources(), "LBNO" )
    Local   lChk     := .F.
    Local   lTeveMarc:= .F.
    Local   cVar     := ""
    Local   cMascEmp := "??"
    Local   cMascFil := "??"
    Local   aMarcadas  	:= {}

    Default lAutomato := .F. 

    aVetor := CarregaEmpresas()

    If !lAutomato
        DEFINE MSDialog  oDlg Title "" From 0, 0 To 270, 396 Pixel

            oDlg:cToolTip := STR0014    //"Tela para seleção múltipla de Empresas/Filiais"
            oDlg:cTitle   := STR0015    //"Selecione a(s) empresa(s) para atualização"

            @ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", STR0016, STR0017, STR0018 Size 178, 095 Of oDlg Pixel    //"Empresa"###"Filial"###"Nome Filial"    
            oLbx:SetArray(  aVetor )
            oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), aVetor[oLbx:nAt, 2], aVetor[oLbx:nAt, 3], aVetor[oLbx:nAt, 5]}}
            oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar, lAutomato ), oChkMar:Refresh(), oLbx:Refresh()}
            oLbx:cToolTip   :=  oDlg:cTitle
            oLbx:lHScroll   := .F. 

            @ 112, 10 CheckBox oChkMar Var  lChk Prompt STR0019 Message  Size 40, 007 Pixel Of oDlg on Click MarcaTodos( lChk, @aVetor, oLbx, lAutomato )     //"Todos"

            @ 123, 10 Button oButInv Prompt STR0020  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar, lAutomato ), VerTodos( aVetor, @lChk, oChkMar, lAutomato ) ) ;
            Message STR0021 Of oDlg      //"Inverter"###"Inverter seleção"

            // Marca/Desmarca por mascara
            @ 113, 51 Say  oSay Prompt STR0016 Size  40, 08 Of oDlg Pixel   //"Empresa"
            @ 112, 80 MSGet oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), cMascFil := StrTran( cMascFil, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
            Message STR0022 Of oDlg    //"Máscara empresa ( ?? )"

            @ 123, 50 Button oButMarc Prompt STR0023    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T., lAutomato ), VerTodos( aVetor, @lChk, oChkMar, lAutomato ) ) ;
            Message STR0024 Of oDlg   //"Marcar"###"Marcar usando máscara ( ?? )"
            @ 123, 80 Button oButDMar Prompt STR0025 Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F., lAutomato ), VerTodos( aVetor, @lChk, oChkMar, lautomato ) ) ;
            Message STR0026 Of oDlg   //"Desmarcar"###"Desmarcar usando máscara ( ?? )" 

            Define SButton From 123, 125 Type 1 Action ( RetSelecao( @aRet, aVetor), oDlg:End() ) OnStop STR0027  Enable Of oDlg    //"Confirma a seleção"
            Define SButton From 123, 158 Type 2 Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) OnStop STR0028 Enable Of oDlg  //"Abandona a seleção"
        
        ACTIVATE MSDialog  oDlg CENTERED
    else
        aEval(aVetor, { |x| x[1] := .T. })
        RetSelecao( @aRet, aVetor)
    ENDIF
Return  aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CarregaEmpresas
Função que carrega a lista de empresas existentes no SIGAMAT

@author Marcia Junko
@since 05/11/2021
/*/
//-------------------------------------------------------------------
Static Function CarregaEmpresas( )
    Local aSM0 := {}
    Local aVetor := {}
    Local aMarcadas := {}
    Local nInd  := 0

    OpenSm0()
    
    aSm0 := FwLoadSm0()
    For nInd := 1 To Len( aSm0 )
        If Ascan( aVetor, {|x| AllTrim( x[ 2 ]  ) == AllTrim( aSm0[ nInd ][ 1 ] ) } ) == 0
            Aadd(  aVetor, { Ascan( aMarcadas, {|x| AllTrim( x[ 1 ] ) == AllTrim( aSm0[ nInd ][ 1 ] ) .And. AllTrim( x[ 2 ] ) == AllTrim( aSm0[ nInd ][ 2 ] ) } ) > 0, aSm0[ nInd ][ 1 ], aSm0[ nInd ][ 2 ], AllTrim( aSm0[ nInd ][ 6 ] ), AllTrim( aSm0[ nInd ][ 7 ] ) } )
        EndIf
    Next nInd
Return aVetor


//-------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Função que seleciona todos os itens do array e atualiza a lista

@param lMarca, boolean, indica se deve selecionar ou não item
@param aVetor, array, lista dos itens
@param lLbx, object, objeto da lista
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author Marcia Junko
@since 05/11/2021
/*/
//-------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx, lAutomato )
    Local  nI := 0

    Default lAutomato := .F.

    For nI := 1 To Len( aVetor )
        aVetor[nI][1] := lMarca
    Next nI

    If !lAutomato
        oLbx:Refresh()
    EndIf
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
Função que seleciona todos os itens do array e atualiza a lista

@param aVetor, array, lista dos itens
@param oLbx, object, objeto da lista
@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author Marcia Junko
@since 05/11/2021
/*/
//-------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx, lAutomato )
    Local  nI := 0

    Default lAutomato := .F.

    For nI := 1 To Len( aVetor )
        aVetor[nI][1] := !aVetor[nI][1]
    Next nI

    If !lAutomato
        oLbx:Refresh()
    EndIf
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
Função que retorna os dados da forma que eles devem ser processados

@param @aRet, array, lista que será processada
@param aVetor, array, lista dos itens

@author Marcia Junko
@since 05/11/2021
/*/
//-------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
    Local  nI    := 0

    aRet := {}
    For nI := 1 To Len( aVetor )
        If aVetor[nI][1]
            aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } ) 
        EndIf
    Next nI
Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} MarcaMas
Função que marca\desmarca os itens do array

@param oLbx, object, objeto da lista
@param aVetor, array, lista dos itens
@param cMascEmp, caracter,  mascara
@param lMarDes, boolean, Indica se o item deve ser marcado (.T.) ou demarcado (.F.)
@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author Marcia Junko
@since 05/11/2021
/*/
//-------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes, lAutomato )
    Local cPos1 := SubStr( cMascEmp, 1, 1 )
    Local cPos2 := SubStr( cMascEmp, 2, 1 )
    Local nPos  := 1
    Local nZ    := 0

    Default lAutomato := .F.

    If !lAutomato 
        nPos := oLbx:nAt
    EndIf
    
    For nZ := 1 To Len( aVetor )
        If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
            If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
                aVetor[nZ][1] := lMarDes
            EndIf
        EndIf
    Next

    If !lAutomato 
        oLbx:nAt := nPos
        oLbx:Refresh()
    EndIf
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
Função que valida se os itens estão marcados e atualiza o checkbox

@param aVetor, array, lista dos itens
@param @lChk, boolean, Indica deve apresentar marcado ou desmarcado
@param @oChkMar, object, Objeto do checkbox
@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author Marcia Junko
@since 05/11/2021
/*/
//-------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar, lAutomato )
    Local lTTrue := .T.
    Local nI     := 0

    Default lAutomato := .F.

    For nI := 1 To Len( aVetor )
        lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
    Next nI

    lChk := IIf( lTTrue, .T., .F. )

    If !lAutomato
        oChkMar:Refresh()
    EndIf
Return NIL

