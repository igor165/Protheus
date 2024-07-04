#include "OGA285.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"

// -- Constantes -- //
#define COL_COUNT       17

#define COL_MARK    1
#define COL_CODCTR  2
#define COL_ITEM    3
#define COL_TIPO    4
#define COL_DATINI  5
#define COL_DATFIM  6
#define COL_QTDINT  7
#define COL_VINCU   8
#define COL_SALDO   9
#define COL_ALOCA   10
#define COL_TIPENT  11
#define COL_ENTORI  12
#define COL_LOJORI  13
#define COL_ENTORN  14
#define COL_ENTDES  15
#define COL_LOJDES  16
#define COL_ENTDEN  17


#Define  CTRATOCPRA '1'
#Define  CTRATOVND  '2'

// --Staticas -- //
STATIC xTpCtrato :=  nil

/** {Protheus.doc} OGA285

@param:     Nil
@author:    Bruna Fagundes Rocio
@since:     05/05/2015
@Uso:       SIGAAGR - Originação de Grãos
*/
Function OGA285( pTipo, pContrato, cTpCtrato) 

    Local aCords        := FWGetDialogSize( oMainWnd )
    Local oFwLayer      := Nil
    Local oPnCad        := Nil
    Local nX            := 0
    Local lRetorno      := .T.
    Local cTitBrwCad    := ''
    Local aColumns      := {}

    
    Local aRetTRB := {} // Variável que recebe o retorno da criação das tabelas temporárias

    //--- Definição da estrutura da tabela temporária de Cadência ---//
    //[n][01] Nome do campo
    //[n][02] Tipo
    //[n][03] Tamanho
    //[n][04] Decimal
    //[n][05] Titulo     
    //[n][06] Picture
    Local aEstruCtr := { { "OK", "C", 2, 0 , , } , ;
    { "C_FILIAL"    , "C", TamSX3( "NNY_FILIAL" )[1]    , 0 , RetTitle( "NNY_FILIAL" )  , PesqPict("NNY","NNY_FILIAL")  },;
    { "C_CODCTR"    , "C", TamSX3( "NNY_CODCTR" )[1]    , 0 , RetTitle( "NNY_CODCTR" )  , PesqPict("NNY","NNY_CODCTR")  },;
    { "C_ITEM"      , "C", TamSX3( "NNY_ITEM" )[1]      , 0 , STR0001                   , PesqPict("NNY","NNY_ITEM")    },;
    { "C_ENTORI"    , "C", TamSX3( "NNY_ENTORI" )[1 ]   , 0 , STR0002                   , PesqPict("NNY","NNY_ENTORI")  },;
    { "C_LOJORI"    , "C", TamSX3( "NNY_LOJORI" )[1 ]   , 0 , STR0003                   , PesqPict("NNY","NNY_LOJORI")  },;
    { "C_ENTORIN"   , "C", TamSX3( "NJ0_NOME" )[ 1 ]    , 0 , STR0027                   , PesqPict("NJ0","NJ0_NOME")    },;
    { "C_TIPENT"    , "C", TamSX3( "NNY_TIPENT" )[ 1 ]  , 0 , RetTitle( "NNY_TIPENT" )  , PesqPict("NNY","NNY_TIPENT")  },;
    { "C_TIPO"      , "C", 10                           , 0 , STR0004                   , "@" },;
    { "C_DATINI"    , "D", 8                            , 0 , Alltrim( RetTitle( "NNY_DATINI" )),  "@D" },;
    { "C_DATFIM"    , "D", 8                            , 0 , Alltrim( RetTitle( "NNY_DATFIM" )),  "@D" },;
    { "C_QTDINT"    , "N", TamSX3( "NNY_QTDINT" )[ 1 ]  , 2 , STR0028                   , "@E 999,999,999.99"            },;
    { "C_QTDVINC"   , "N", TamSX3( "NNY_QTDINT" )[ 1 ]  , 2 , STR0029                   , "@E 999,999,999,999,999.99"    },; 
    { "C_QTDSLD"    , "N", TamSX3( "NNY_QTDINT" )[ 1 ]  , 2 , STR0030                   , "@E 999,999,999,999,999.99"    },;                     
    { "C_RECNO"     , "N", 18                           , 0 , "RECNO", "@ 9999999999"} } 

    // { "C_QTDSLD", "N", TamSX3( "NNY_QTDINT" )[ 1 ], 2  , STR0005,   "@E 999,999,999,999,999.99" },;

    Local aCpBrwCtr := {}
    Local aIndCtr   := { "C_FILIAL+C_CODCTR+C_ITEM" } // Definição dos índices

    //--- Definição da estrutura da tabela temporária de Detalhe Cadência Relacionada ---//
    //--- Grid inferior---//
    Local aEstruDrf := {{ "OK", "C", 2, 0 , , } ,;
    { "D_FILIAL"    , "C", TamSX3( "NNY_FILIAL" )[ 1 ]  , 0 , RetTitle( "NNY_FILIAL" )  , PesqPict("NNY","NNY_FILIAL")  },;
    { "D_CODCTR"    , "C", TamSX3( "NNY_CODCTR" )[ 1 ]  , 0 , RetTitle( "NNY_CODCTR" )  , PesqPict("NNY","NNY_CODCTR")  },;
    { "D_ITEM"      , "C", TamSX3( "NNY_ITEM" )[ 1 ]    , 0 , STR0001                   , PesqPict("NNY","NNY_ITEM")    },;
    { "D_ENTORI"    , "C", TamSX3( "NNY_ENTORI" )[ 1 ]  , 0 , STR0002                   , PesqPict("NNY","NNY_ENTORI")  },;
    { "D_LOJORI"    , "C", TamSX3( "NNY_LOJORI" )[ 1 ]  , 0 , STR0003                   , PesqPict("NNY","NNY_LOJORI")  },;
    { "D_ENTORIN"   , "C", TamSX3( "NJ0_NOME" )[ 1 ]    , 0 , STR0027                   , PesqPict("NJ0","NJ0_NOME")    },;   
    { "D_DATINI"    , "D", 8                            , 0 , Alltrim( RetTitle( "NNY_DATINI" )),  "@D" },;
    { "D_DATFIM"    , "D", 8                            , 0 , Alltrim( RetTitle( "NNY_DATFIM" )),  "@D" },;
    { "D_QTDINT"    , "N", TamSX3( "NNY_QTDINT" )[ 1 ]  , 2 , STR0028                   , "@E 999,999,999.99"           },;   
    { "D_QTDVINC"   , "N", TamSX3( "NNY_QTDINT" )[ 1 ]  , 2 , STR0029                   , "@E 999,999,999,999,999.99"   },; 
    { "D_QTDVINC1"  , "N", TamSX3( "NNY_QTDINT" )[ 1 ]  , 2 , STR0031                   , "@E 999,999,999,999,999.99"   },; 
    { "D_QTDSLD"    , "N", TamSX3( "NNY_QTDINT" )[ 1 ]  , 2 , STR0030                   , "@E 999,999,999,999,999.99"   },;
    { "D_RECNO"     , "N", 18, 0, "RECNO", "@ 9999999999"} }

    Local aIndDrf    := { "D_FILIAL+D_CODCTR+D_ITEM" } // Definição dos índices

    Private oDlg            := Nil
    Private oPnDet      := Nil
    Private cAliasCtr 
    Private cTrabCtr
    Private oBrwCad

    Private cAliasDrf 
    Private cTrabDrf
    Private oBrwDet

    Private cNoFldCTR    := "OK,C_FILIAL,C_CODCTR,C_TIPENT,C_RECNO"
    //Private cNoFldDRF  := "D_FILIAL,D_CTRORI,D_ITEORI,D_RECNO"

    Private aCpBrwDrf  := {}
    Private cMarca     := GetMark()
    Private cPergunta  := "OGA285"
    Private nTotFilho  := 0
    Private aIndice1, aIndice2

    //-- Se xTpCtrato, não estiver inicializada Inicializa --//
    IF xTpCtrato == nil
        fGetTpCtr(pContrato)
    EndIF

    // Tabela temporária de Cadência
    aRetTRB := AGRCRIATRB( , aEstruCtr, aIndCtr, FunName(), .T. )

    cTrabCtr    := aRetTRB[3] //Nome do arquivo temporário 
    cAliasCtr   := aRetTRB[4] //Nome do alias do arquivo temporario
    aCpBrwCtr   := aRetTRB[5] //Matriz com a estrutura do arquivo temporario + label e picture

    aIndice1    := AGRINDICONS(aIndCtr, aCpBrwCtr )

    // Tabela temporária de Detalhe Cadência Relacionada 
    aRetTRB := AGRCRIATRB( , aEstruDrf, aIndDrf, FunName(), .T. )

    cTrabDrf    := aRetTRB[3] //Nome do arquivo temporário 
    cAliasDrf   := aRetTRB[4] //Nome do alias do arquivo temporario
    aCpBrwDrf   := aRetTRB[5] //Matriz com a estrutura do arquivo temporario + label e picture

    aIndice2    := AGRINDICONS(aIndDrf, aCpBrwDrf )


    //************ Montagem da tela ************//

    aTitulo := {"Detalhes","Alocar"}  // "Dados Gerais" ### "Endere‡os"
    aPages  := {"OGA285A","OGA285B"}

    oDlg := TDialog():New( aCords[ 1 ], aCords[ 2 ], aCords[ 3 ], aCords[ 4 ], STR0008, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) 

    //--- Layers ---//
    oFwLayer:= FwLayer():New()
    oFwLayer:Init( oDlg, .f., .t. )

    // Cadência
    oFWLayer:AddLine( 'LinCad', 50, .F. )
    oFWLayer:AddCollumn( 'ColSaldo', 100, .T., 'LinCad' )
    oPnCad := oFWLayer:GetColPanel( 'ColSaldo', 'LinCad')

    // Detalhes
    oFWLayer:AddLine( 'LinDetalhe', 50, .F. )
    oFWLayer:AddCollumn( 'ColContrato', 100, .T., 'LinDetalhe' )
    oPnDet := oFWLayer:GetColPanel( 'ColContrato', 'LinDetalhe')

    //--- Conteúdo dos panels ---//
    //--- Abastecendo os Arqs. dos Grids pela 1a. Vez
    lRetorno := A285Load( pContrato)
    If lRetorno = .F.
        Return .T.
    Endif


    // --Ajustando Propriedades do Browse OBRWCAD --            
    //-- Montando o Titulo Dinamico do 1o. Browse
    IF xTpCtrato == CTRATOCPRA
        cTitBrwCad      := STR0032 + pContrato  //"Cadencia(s) e Quantidades do Contrato de Compra: "
    ElseIF xTpCtrato == CTRATOVND
        cTitBrwCad      := STR0033 + pContrato  //"Cadencia(s) e Quantidades do Contrato de Venda : "  
    EndIF

    DEFINE FWFormBrowse oBrwCad DATA TABLE ALIAS cAliasCTR DESCRIPTION cTitBrwCad OF oPnCad //"Cadência"
    oBrwCad:SetTemporary(.T.)
    oBrwCad:SetdbFFilter(.T.)
    oBrwCad:SetUseFilter(.T.)   
    oBrwCad:SetFieldFilter(AGRITEMCBRW(aCpBrwCtr))  
    oBrwCad:SetSeek(,aIndice1)  
    
    For nX := 1 To Len( aCpBrwCtr )
        If !( aCpBrwCtr[nX,1] $ cNoFldCTR )

            AAdd( aColumns,FWBrwColumn():New() )

            /* Vars. Utilizadas para melhor entendimento */
            cCampo      := aCpBrwCtr[nX,1]
            cTipo       := aCpBrwCtr[nX,2]
            cTitulo     := aCpBrwCtr[nX,5]
            nTamanho    := aCpBrwCtr[nX,3]
            nDecimal    := aCpBrwCtr[nX,4]
            cPicture    := aCpBrwCtr[nX,6]


            aColumns[ Len(aColumns) ]:SetData( &("{||" + cCampo +"}")   )
            aColumns[ Len(aColumns) ]:SetType( cTipo                        )       
            aColumns[ Len(aColumns) ]:SetTitle( cTitulo                 )
            aColumns[ Len(aColumns) ]:SetSize(nTamanho                  )
            aColumns[ Len(aColumns) ]:SetDecimal(nDecimal                   )
            aColumns[ Len(aColumns) ]:SetPicture( cPicture                  )       
            aColumns[ Len(aColumns) ]:SetAlign( If(cTipo == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento
        EndIF
    nExt nX

    oBrwCad:SetColumns( aColumns )
    oBrwCad:bChange := {|| A285LoadDet() } 
    oBrwCad:AddButton(STR0009,  {|| PreAloca(pTipo, pContrato,  ) },,,,,,'10')  //Alocar
    oBrwCad:DisableDetails()
    ACTIVATE FWFormBrowse oBrwCad

    oDlg:Activate( , , , .t., { || .t. }, , { || } )

    //--- Apaga as tabelas temporárias ---//
    AGRDELETRB( cAliasCTR, cTrabCTR )
    AGRDELETRB( cAliasDRF, cTrabDRF )  

Return( )

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param:     Nil
@return:    aRotina - Array com os itens do menu
@author:    Bruna Fagundes Rocio
@since:     04/02/2015
*/

Static Function MenuDef()    
    Local aRotina := {}

    aAdd( aRotina, { "DUMMY"    , "PesqBrw"   , 0, 1, 0, .t. } ) 

Return( aRotina )


/** {Protheus.doc} fMarcar()
Marca/Desmarca registro

    @param      Browse 
    @sample     fMarcar(oBrowse)
    @return    Nil.
    @author    Agro
    @since      27/01/2015
    @version    P11
/*/
Static Function fMarcar( oMrkBrowse)
    
    If !(oMrkBrowse:Alias())->( Eof() )     
        RecLock(oMrkBrowse:Alias(),.F.)
        (oMrkBrowse:Alias())->OK  := IIf((oMrkBrowse:Alias())->OK==cMarca,' ',cMarca)
        (oMrkBrowse:Alias())->(MsUnLock())
        
    EndIf

oMrkBrowse:Refresh()    
Return( .T. )

/** {Protheus.doc} OGA285CHK
Função para marcar/desmarcar todos

@param:     Nil
@author:    Bruna Rocio
@since:     01/12/2014
@Uso:       SIGAAGR - Originação de Grãos
*/
Function OGA285CHK( pcAliasTRB, pOBrw )

    If lSelAll
        OGA285SEL( pcAliasTRB )
    Else
        OGA285UNSEL( pcAliasTRB )       
    Endif

    DbSelectArea(pcAliasTRB)
    (pcAliasTRB)->( DbGoTop() )

    pOBrw:Refresh()

Return 

/** {Protheus.doc} OGA285UNSEL
Função chamada para verificar a existência de registro selecionado 

@param:     Nil
@author:    Bruna Rocio
@since:     01/12/2014
@Uso:       SIGAAGR - Originação de Grãos
*/
Function OGA285UNSEL( pcAliasTRB )

    dbSelectArea(pcAliasTRB)
    (pcAliasTRB)->( dbGoTop() )
    While !(pcAliasTRB)->( Eof() )

        RecLock(pcAliasTRB,.f.)
        (pcAliasTRB)->OK := ' '
        msUnLock(pcAliasTRB)        
        (pcAliasTRB)->( dbSkip() )
    EndDo
Return 

/** {Protheus.doc} OGA285SEL
Função chamada para verificar a existência de registro selecionado 

@param:     Nil
@author:    Bruna Rocio
@since:     01/12/2014
@Uso:       SIGAAGR - Originação de Grãos
*/
Function OGA285SEL( pcAliasTRB )

    dbSelectArea(pcAliasTRB)
    (pcAliasTRB)->( dbGoTop() )
    While !(pcAliasTRB)->( Eof() )

        RecLock(pcAliasTRB,.f.)
        (pcAliasTRB)->OK := cMarca
        msUnLock(pcAliasTRB)

        (pcAliasTRB)->( dbSkip() )
    EndDo
Return 


/** {Protheus.doc} A285Load

@param:     Nil
@return:    
@author:    Bruna Fagundes Rocio
@since:     06/05/2015
*/
Function A285Load(pContrato)

    Local aAreaAtu   := GetArea()
    Local cAliasCad  := GetNextAlias() 
    Local nCount     := 0

    /******* CABEÇALHOS CADÊNCIAS ********/
    //--- Apaga conteúdo anterior da tabela temporária cAliasCTR ---//
    A285ZapTRB( cAliasCTR )

    BeginSql Alias cAliasCad

    SELECT ' ' as OK
    ,NNY_FILIAL 
    ,NNY_CODCTR 
    ,NNY_ITEM
    ,NNY_ENTORI
    ,NNY_LOJORI
    ,NNY_ENTDES
    ,NNY_LOJDES
    ,NNY_QTDINT
    ,NNY_DATINI
    ,NNY_DATFIM
    ,NNY_TIPENT
    ,NNY.R_E_C_N_O_ AS NNY_RECNO
    FROM %Table:NNY% NNY
    WHERE NNY.%notDel%
    AND NNY_FILIAL = %xFilial:NNY%
    AND NNY_CODCTR = %exp:pContrato%     
    GROUP BY NNY_FILIAL 
    ,NNY_CODCTR
    ,NNY_ITEM
    ,NNY_ENTORI
    ,NNY_LOJORI
    ,NNY_ENTDES
    ,NNY_LOJDES  
    ,NNY_QTDINT
    ,NNY_DATINI  
    ,NNY_DATFIM
    ,NNY_TIPENT  
    ,NNY.R_E_C_N_O_
    EndSQL

    DbselectArea( cAliasCad )
    DbGoTop()
    While ( cAliasCad )->( !Eof() ) 

        nCount++

        RecLock( cAliasCTR, .T. )
        ( cAliasCTR )->OK      := ( cAliasCad )->OK
        ( cAliasCTR )->C_FILIAL := ( cAliasCad )->NNY_FILIAL
        ( cAliasCTR )->C_CODCTR     := ( cAliasCad )->NNY_CODCTR
        ( cAliasCTR )->C_ITEM   := ( cAliasCad )->NNY_ITEM
    
        ( cAliasCTR )->C_ENTORI     := ( cAliasCad )->NNY_ENTORI
        ( cAliasCTR )->C_LOJORI     := ( cAliasCad )->NNY_LOJORI

        ( cAliasCTR )->C_ENTORIN    := Posicione("NJ0",1,FwxFilial("NJ0")+( cAliasCTR )->( C_ENTORI + C_LOJORI) ,"NJ0->NJ0_NOME")

        ( cAliasCTR )->C_QTDINT :=  ( cAliasCad )->NNY_QTDINT
        ( cAliasCTR )->C_DATINI := StoD(( cAliasCad )->NNY_DATINI)
        ( cAliasCTR )->C_DATFIM := StoD(( cAliasCad )->NNY_DATFIM)
        ( cAliasCTR )->C_QTDINT := ( cAliasCad )->NNY_QTDINT
        ( cAliasCTR )->C_QTDVINC:= SldCadenc( ( cAliasCad )->NNY_CODCTR,( cAliasCad )->NNY_ITEM )
        ( cAliasCTR )->C_QTDSLD := ( cAliasCTR )->C_QTDINT -  ( cAliasCTR )->C_QTDVINC
        ( cAliasCTR )->C_TIPO   := X3CboxDesc("NNY_TIPENT",(cAliasCad)->NNY_TIPENT)
        ( cAliasCTR )->C_TIPENT := ( cAliasCad )->NNY_TIPENT
        ( cAliasCTR )->C_RECNO  := ( cAliasCad )->NNY_RECNO

        ( cAliasCTR )->( MsUnLock() )
        ( cAliasCad )->( DbSkip() )
    EndDo
    ( cAliasCad )->( DbCloseArea() )

    If nCount = 0
        Help(, , STR0026, , STR0012, 1, 0 )
        Return .F.
    Endif

    If Type("oBrwCad") <> "U"
        oBrwCad:Refresh(.T.)    
    EndIf

    RestArea( aAreaAtu )
Return ( .t. )

/** {Protheus.doc} A285Load
Posiciona nas cadências relacionadas

@param:     Nil
@author:    Bruna Fagundes Rocio
@since:     06/05/2015
*/

Function A285LoadDet( )

    Local aAreaAtu      := GetArea()
    Local cAliasDet     := GetNextAlias()
    Local cCtr          := ( cAliasCTR )->C_CODCTR
    Local cIte          := ( cAliasCTR )->C_ITEM
    Local cFiltroCtr    := ''
    Local cTitBrwDet    := ''

    IF xTpCtrato == CTRATOCPRA  //Encontro os Vinculos desse Contrato de Compras ...
        cFiltroCTR := "%NKB_CTRCOM = '"         + cCtr + "'"
        cFiltroCTR += " AND NKB_SEQCDC = '"     + cIte + "'%"

        cTitBrwDet      := STR0034 + cIte + STR0035 + cCtr  //"Cadencia(s) e quantidades em Ctrs. Venda Vinculadas à Cadencia: "#" do Contrato de Compra : "
    ElseIF xTpCtrato == CTRATOVND
        cFiltroCTR := "%NKB_CTRVND = '"         + cCtr + "'"
        cFiltroCTR += " AND NKB_SEQCDV = '"     + cIte + "'%" 

        cTitBrwDet      := STR0034 + cIte + STR0036 + cCtr  //"Cadencia(s) e quantidades em Ctrs. Compra Vinculadas à Cadencia: "#" do Contrato de Venda : "       
    EndIF


    /*************************************/
    /******** DETALHE CADÊNCIAS **********/
    //--- Apaga conteúdo anterior da tabela temporária cAliasQry ---//

    A285ZapTRB( cAliasDRF )
    nTotFilho := 0

    ///If pTipo = '1' //Compra

    BeginSql Alias cAliasDet
    Select NKB_FILIAL
    ,NKB_CTRCOM
    ,NKB_SEQCDC
    ,NKB_CTRVND
    ,NKB_SEQCDV
    ,NKB_QTDADE
    ,NKB_PRAZOV
    ,NKB_ENTLOC
    ,NKB_LOJLOC
    ,NKB.R_E_C_N_O_ AS NKB_RECNO
    FROM %Table:NKB% NKB
    WHERE NKB.%notDel%
    AND NKB_FILIAL = %xFilial:NKB%
    //AND NKB_CTRCOM = %exp:cCtr%
    //AND NKB_SEQCDC = %exp:cIte%
    And %exp:cFiltroCTR%
    GROUP BY NKB_FILIAL
    ,NKB_CTRCOM
    ,NKB_SEQCDC
    ,NKB_CTRVND
    ,NKB_SEQCDV
    ,NKB_QTDADE
    ,NKB_PRAZOV
    ,NKB_ENTLOC
    ,NKB_LOJLOC
    ,NKB.R_E_C_N_O_  
    EndSql       

    DbselectArea( cAliasDet )
    DbGoTop()
    While ( cAliasDet )->( !Eof() ) 

        RecLock( cAliasDRF, .T. )

        ( cAliasDRF )->D_FILIAL := ( cAliasDet )->NKB_FILIAL

        IF xTpCtrato == CTRATOCPRA      //Encontro os Vinculos desse Contrato de Compras ...
            ( cAliasDRF )->D_CODCTR := ( cAliasDet )->NKB_CTRVND
            ( cAliasDRF )->D_ITEM   := ( cAliasDet )->NKB_SEQCDV
        ElseIF xTpCtrato == CTRATOVND
            ( cAliasDRF )->D_CODCTR := ( cAliasDet )->NKB_CTRCOM
            ( cAliasDRF )->D_ITEM   := ( cAliasDet )->NKB_SEQCDC
        EndIF

        ( cAliasDRF )->D_ENTORI     := POSICIONE('NNY', 1,xFILIAL('NNY')+( ( cAliasDRF )->D_CODCTR + D_ITEM ), 'NNY_ENTORI')    
        ( cAliasDRF )->D_LOJORI     := NNY->NNY_LOJORI
        ( cAliasDRF )->D_ENTORIN    := Posicione("NJ0",1,FwxFilial("NJ0")+( ( cAliasDRF )->D_ENTORI+D_LOJORI) ,"NJ0->NJ0_NOME")             
        ( cAliasDRF )->D_DATINI     := NNY->NNY_DATINI
        ( cAliasDRF )->D_DATFIM     := NNY->NNY_DATFIM // StoD(( cAliasDet )->NKB_PRAZOV)
        ( cAliasDRF )->D_QTDINT     := NNY->NNY_QTDINT

        ( cAliasDRF )->D_QTDVINC    := ( cAliasDet )->NKB_QTDADE //Vinculado no contrato
        
        ( cAliasDRF )->D_QTDVINC1    := OG285CTRV(NNY->NNY_CODCTR,NNY->NNY_ITEM,NNY->NNY_QTDINT, xTpCtrato )//Vinculado em tds os ctr.
        ( cAliasDRF )->D_QTDSLD     := ( cAliasDRF )->D_QTDINT -  ( cAliasDRF )->D_QTDVINC1

        ( cAliasDRF )->D_RECNO      := ( cAliasDet )->NKB_RECNO
        ( cAliasDRF )->( MsUnLock() )
        ( cAliasDet )->( DbSkip() )
    EndDo

    ( cAliasDet )->( DbCloseArea() )

    fGObrwDet( cTitBrwDet )    //Gerando o Browse De Detalhe

    RestArea( aAreaAtu )
Return ( .t. )

/** {Protheus.doc} A285ZapTRB
Apaga todos os dados de uma tabela temporária.

@param:     Nil
@author:    Bruna Rocio
@since:     Bruna Rocio
@Uso:       SIGAAGR - Originação de Grãos
*/
Static Function A285ZapTRB( pcAliasTRB )
    Local aAreaAtu      := GetArea()

    If Select( pcAliasTRB ) > 0
        DbSelectArea( pcAliasTRB )
        Zap
    Endif   
    RestArea( aAreaAtu )
Return

/** {Protheus.doc} PreAloca

@param:     Nil
@author:    Bruna Rocio
@since:     12/05/2015
@Uso:       
*/
Static Function PreAloca(cTipo, cContrato)
    Local aRetorno := {}
    Local lRetorno := .t.

    IF (cAliasCTR)->C_QTDSLD == 0
        Help(, , STR0026, , STR0037, 1, 0 ) //'Qt. cadencia já se encontra totalmente comprometida.'
        Return .f.
    EndIF


    //Parâmetros Alocação
    Pergunte(cPergunta)

    aRetorno := SelCadAloc( cTipo, cContrato, (cAliasCTR)->C_QTDSLD )

    IF Len(aRetorno) > 0
        lRetorno := RCadCreate( cTipo, aRetorno )

        If lRetorno 
            ///285Load(cContrato)   // Força Refresh do Browse superior
            
            RecLock(cAliasCTR,.F.)
            ( cAliasCTR )->C_QTDVINC:= SldCadenc( ( cAliasCTR )->C_CODCTR,( cAliasCTR )->C_ITEM )
            ( cAliasCTR )->C_QTDSLD := ( cAliasCTR )->C_QTDINT -  ( cAliasCTR )->C_QTDVINC
            
            A285LoadDet()           // força Refresh do Browse inferior
            
            obrwCAD:Refresh()
            obrwDET:Refresh(.t.)
        Endif
    else 
        lRetorno := .F.
    endif


Return ( lRetorno )

/** {Protheus.doc} SelCadAloc

@param:     Nil
@author:    Bruna Rocio
@since:     12/05/2015
@Uso:       
*/
Static Function SelCadAloc( cTipo, cContrato, nQtd)
    Local aRetorno  := {}
    Local aAreaAtu  := GetArea()
    Local oSize     := Nil
    Local oDlg          := Nil
    Local oPnUm     := Nil
    Local oPnDois       := Nil
    Local oFont     := Nil
    Local oStO          := LoadBitmap( GetResources(), "unchecked_15" )
    Local oStX          := LoadBitmap( GetResources(), "checked_15" )
    Local aButtons  := {}
    Local aAux          := {}
    Local nOpcao        := 0
    Local nY            := 0
    Local cFiltroNJR    := ""
    Local cFiltroNNY    := ""
    Local cTitle        := ''
    Local cProduto   := ""
    Local cSafra     := ""
    Local cAliasAlc  := GetNextAlias()

    Private oBrowse := Nil
    Private oSayB       := Nil
    Private nQtdAl  := nQtd
    Private nQtdSel := 0

    DbSelectArea('NJR')
    NJR->( DbSetOrder(1) )
    NJR->( dbSeek( xFilial( "NJR" ) + cContrato ))

    cProduto := NJR->NJR_CODPRO
    cSafra   := NJR->NJR_CODSAF


    // Ajustando Filtros dos Contratos a Considerar //
    IF NJR->NJR_TIPO == CTRATOCPRA  // Se é Cpra Listo os de Venda
        cFiltroNJR := " AND NJR.NJR_TIPO   =  '" + CTRATOVND + "'"
        cFiltroNJR += " AND NJR.NJR_STATUS <> 'E' AND NJR.NJR_STATUS <> 'F' "
        cTitle := STR0038   //"Cadências para Relacionamento Ref. aos Ctrs. de Vendas"
    ElseIF NJR->NJR_TIPO == CTRATOVND
        cFiltroNJR := " AND NJR.NJR_TIPO   = '" + CTRATOCPRA + "'"
        cFiltroNJR += " AND NJR.NJR_STATUS <> 'E' AND NJR.NJR_STATUS <> 'F' "        
        cTitle := STR0039   //"Cadências para Relacionamento Ref. aos Ctrs. de Compras "       

    EndIF

    cFiltroNJR += " AND NJR.NJR_CODSAF = '" + cSafra + "' "
    cFiltroNNY := " AND NNY.NNY_FILIAL = '" + xFilial('NNY') + "' "

    If MV_PAR01 = 1
        cFiltroNNY  += " AND NNY.NNY_DATINI >= '" + DtoS(( cAliasCTR )->C_DATINI) + "' "
    Endif

    If MV_PAR02 = 1
        cFiltroNJR  += " AND NJR.NJR_CODPRO = '" + cProduto + "' "       
    Endif

    cFiltroNNY := "%" + cFiltroNNY + "%"
    cFiltroNJR := "%" + cFiltroNJR + "%"
    // Fim Ajustando filtros dos Contratos a Considerar //

    ////aAdd( aButtons, { "", {|| EditQtd() }, OemToAnsi( "Editar" ) } )

    BeginSql Alias cAliasAlc
    Select NNY_FILIAL
    ,NNY_CODCTR
    ,NNY_ITEM
    ,NNY_ENTORI
    ,NNY_LOJORI
    ,NNY_ENTDES
    ,NNY_LOJDES
    ,NNY_DATINI
    ,NNY_DATFIM
    ,NNY_TIPENT
    ,NNY_QTDINT
    ,NNY.R_E_C_N_O_ AS NNY_RECNO
    FROM %Table:NNY% NNY
    RIGHT JOIN %Table:NJR% NJR
    ON NJR.NJR_FILIAL = %xFilial:NJR%
    AND NJR.NJR_CODCTR = NNY.NNY_CODCTR
    %exp:cFiltroNJR%
    WHERE NNY.%notDel%
    %exp:cFiltroNNY%                  
    GROUP BY NNY_FILIAL
    ,NNY_CODCTR
    ,NNY_ITEM
    ,NNY_ENTORI
    ,NNY_LOJORI
    ,NNY_ENTDES
    ,NNY_LOJDES
    ,NNY_DATINI
    ,NNY_DATFIM
    ,NNY_TIPENT
    ,NNY_QTDINT
    ,NNY.R_E_C_N_O_ 
    
    ORDER BY NNY_CODCTR
    EndSql       

    /*************************************/
    DbselectArea( cAliasAlc )
    DbGoTop()
    While ( cAliasAlc )->( !Eof() ) 

        aAdd( aAux, Array( COL_COUNT ) )
        aAux[ Len( aAux ), COL_MARK     ] := "0"
        aAux[ Len( aAux ), COL_CODCTR   ] := Alltrim( ( cAliasAlc )->NNY_CODCTR )
        aAux[ Len( aAux ), COL_ITEM     ] := Alltrim( ( cAliasAlc )->NNY_ITEM   )
        aAux[ Len( aAux ), COL_ENTORI   ] := Alltrim( ( cAliasAlc )->NNY_ENTORI )
        aAux[ Len( aAux ), COL_LOJORI   ] := Alltrim( ( cAliasAlc )->NNY_LOJORI )
        aAux[ Len( aAux ), COL_ENTDES   ] := Alltrim( ( cAliasAlc )->NNY_ENTDES )
        aAux[ Len( aAux ), COL_LOJDES   ] := Alltrim( ( cAliasAlc )->NNY_LOJDES )
        aAux[ Len( aAux ), COL_TIPO     ] := Alltrim( X3CboxDesc('NNY_TIPENT',( cAliasAlc )->NNY_TIPENT) )
        aAux[ Len( aAux ), COL_DATINI   ] := StoD( ( cAliasAlc )->NNY_DATINI )
        aAux[ Len( aAux ), COL_DATFIM   ] := StoD( ( cAliasAlc )->NNY_DATFIM )
        aAux[ Len( aAux ), COL_QTDINT   ] := ( cAliasAlc )->NNY_QTDINT
        aAux[ Len( aAux ), COL_VINCU    ] := OG285CTRV(( cAliasAlc )->NNY_CODCTR,( cAliasAlc )->NNY_ITEM,( cAliasAlc )->NNY_QTDINT, xTpCtrato )
        aAux[ Len( aAux ), COL_ALOCA    ] :=  0
        aAux[ Len( aAux ), COL_SALDO    ] :=  aAux[ Len( aAux ), COL_QTDINT     ] - aAux[ Len( aAux ), COL_VINCU    ]       
        aAux[ Len( aAux ), COL_TIPENT   ] := ( cAliasAlc )->NNY_TIPENT
        aAux[ Len( aAux ), COL_ENTORN   ] := Alltrim( POSICIONE('NJ0', 1,xFILIAL('NJ0')+ ( cAliasAlc )->(NNY_ENTORI+NNY_LOJORI), 'NJ0_NOME') )
        aAux[ Len( aAux ), COL_ENTDEN   ] := Alltrim( POSICIONE('NJ0', 1,xFILIAL('NJ0')+ ( cAliasAlc )->(NNY_ENTDES+NNY_LOJDES), 'NJ0_NOME') )


        ( cAliasAlc )->( DbSkip() )
    EndDo
    ( cAliasAlc )->( DbCloseArea() )

    If Len(aAux) <= 0
        //Alert(STR0014)
        Help(, , STR0026, , STR0014, 1, 0 )
    else 
        oSize := FwDefSize():New()
        oSize:AddObject( "P1", 50, 80, .t., .t., .t. )
        oSize:AddObject( "P2", 50, 20, .t., .t., .t. )
        oSize:lProp     := .t.
        oSize:aMargins  := { 3, 3, 3, 3 }
        oSize:Process()

        oDlg := TDialog():New( oSize:aWindSize[ 1 ], oSize:aWindSize[ 2 ], oSize:aWindSize[ 3 ]-50, oSize:aWindSize[ 4 ] - 250 , cTitle /*Titulo*/,,,,,CLR_BLACK,CLR_WHITE,,,.t.)

        oPnUm       := tPanel():New( oSize:GetDimension( "P1", "LININI" ), oSize:GetDimension( "P1", "COLINI" ), "", oDlg,,,,CLR_BLACK,CLR_WHITE,oSize:GetDimension( "P1", "XSIZE" )-120,oSize:GetDimension( "P1", "YSIZE" ) )
        oPnDois     := tPanel():New( oSize:GetDimension( "P2", "LININI" ), oSize:GetDimension( "P2", "COLINI" ), "", oDlg,,,,CLR_BLACK,CLR_WHITE,oSize:GetDimension( "P2", "XSIZE" ) - 120 ,oSize:GetDimension( "P2", "YSIZE" )-10 )

        // Label que mostra a Descrição das Entidades no Rodape do Browse
        
        oFont   := TFont():New( "Courier new", , -12, .t. )
        oSayEntOri:= TSay():New( 01, 001, {|| 'Courier' }, oPnDois, , oFont, , , , .t., CLR_BLACK, CLR_GRAY, 250, 10 )
        oSayEntOri:lTransparent := .f.
        oSayEntDes:= TSay():New( 01, 260, {|| 'Courier' }, oPnDois, , oFont, , , , .t., CLR_BLACK, CLR_GRAY, 250, 10 )
        oSayEntDes:lTransparent := .f. 
        //--Label das Qtds. no Rodape do Browse
        oSayA:= TSay():New( 12, 001, {|| RetTextoA( aAux, nQtd,cContrato ) }, oPnDois, , oFont, , , , .t., CLR_BLACK, CLR_GRAY, 250, 10 )
        oSayA:lTransparent := .f.
        oSayB:= TSay():New( 12, 260, {|| RetTextoB( aAux, nQtd,cContrato ) }, oPnDois, , oFont, , , , .t., CLR_BLACK, CLR_GRAY, 250, 10 )
        oSayB:lTransparent := .f.


        oBrowse := TCBrowse():New( 01, 01, 260, 156, , , , oPnUm, , , , , , , , , , , , .f., ,.t., , .f. )

        oBrowse:AddColumn( TCColumn():New( ""           , { || IIf( aAux[oBrowse:nAt, COL_MARK ] == "1", oStX, oStO ) } ,,,,"CENTER", 040,.t.,.t.,,,,.f.,) )
        oBrowse:AddColumn( TCColumn():New( STR0015      , { || aAux[ oBrowse:nAt, COL_CODCTR    ] }  ,,,,"LEFT",    ,.f.,.t.,,,,.f.,) )
        oBrowse:AddColumn( TCColumn():New( STR0016      , { || aAux[ oBrowse:nAt, COL_ITEM      ] }  ,,,,"LEFT",    ,.f.,.t.,,,,.f.,) )
        oBrowse:AddColumn( TCColumn():New( STR0004      , { || aAux[ oBrowse:nAt, COL_TIPO  ] } ,,,,"LEFT"  ,    ,.f.,.t.,,,,.f.,) )
        oBrowse:AddColumn( TCColumn():New( STR0017      , { || Transform( aAux[ oBrowse:nAt, COL_DATINI ], "@D" ) } ,,,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )
        oBrowse:AddColumn( TCColumn():New( STR0018      , { || Transform( aAux[ oBrowse:nAt, COL_DATFIM ], "@D" ) } ,,,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )
        oBrowse:AddColumn( TCColumn():New( STR0052      , { || Transform( aAux[ oBrowse:nAt, COL_QTDINT ], "@E 999,999,999,999,999.99" ) }  ,,,,"RIGHT",    ,.f.,.t.,,,,.f.,) )
        oBrowse:AddColumn( TCColumn():New( STR0053      , { || Transform( aAux[ oBrowse:nAt, COL_VINCU ], "@E 999,999,999,999,999.99" ) }  ,,,,"RIGHT",    ,.f.,.t.,,,,.f.,) )     
        oBrowse:AddColumn( TCColumn():New( STR0054      , { || Transform( aAux[ oBrowse:nAt, COL_SALDO  ], "@E 999,999,999,999,999.99" ) }  ,,,,"RIGHT",    ,.f.,.t.,,,,.f.,) ) 
        oBrowse:AddColumn( TCColumn():New( STR0009      , { || Transform( aAux[ oBrowse:nAt, COL_ALOCA  ], "@E 999,999,999,999,999.99" ) }  ,,,,"RIGHT",    ,.f.,.t.,,,,.f.,) )
        oBrowse:SetArray( aAux )
        oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
        oBrowse:bLDblClick      := {|| editContrato(@aAux, oBrowse)}
        oBrowse:bSeekChange     := {|| fShowEntds(@aAux,oBrowse:nAt,@oSayEntORI,@oSayEntDES)}

        fShowEntds(@aAux,oBrowse:nAt,@oSayEntORI,@oSayEntDES)

        oDlg:Activate( , , , .t., {|| nQtd >= nQtdSel }, , { || EnchoiceBar( oDlg, {|| nOpcao := 1, oDlg:End() },{|| nOpcao := 0, oDlg:End() },, @aButtons ) } )

        If nOpcao = 1
            For nY := 1 to Len( aAux )
                If aAux[ nY, COL_MARK ] = "1"
                    aAdd( aRetorno, aAux[ nY ] )
                EndIf
            Next nY
        EndIf
    endif

    RestArea( aAreaAtu )
Return( aRetorno )

/** {Protheus.doc} editContrato
Função para Editar o Cpo de Qtd. a Vincular

@param:     Nil
@author:    Bruna Rocio
@since:     06/02/2015
@Uso:       SIGAAGR - Originação de Grãos
*/
Static Function editContrato( aArr, oObj)

    Local nAlcTotTmp := nQtdAl  //Inserido para resetar a variavel e calcular quanto ja foi distribuido. Vini
    Local nTempVal   := 0       // variavel utilizada para calculo de diferença
    
    If  oObj:ColPos = COL_MARK

        IF aArr[oBrowse:nAt, COL_ALOCA] == 0
           aArr[oObj:nAt, COL_ALOCA] := aArr[oObj:nAt, COL_SALDO]
           //oObj:Refresh()
        EndIF
        /*Vinicius 28/04/2016*/ 
        IF aArr[oBrowse:nAt, COL_MARK] == '0' // Está indo Marcar
           nQtdAl -= nQtdSel   // calcula quantidade restante.
           IF nQtdAl == 0
                Help(, , STR0026, , STR0049, 1, 0 ) //'Não é possivel alocar; A Qt. informada, somada à Qt. que já se encontra selecionada é maior que a Qt. a Alocar'
                aArr[oObj:nAt, COL_ALOCA] := 0
                nQtdAl := nAlcTotTmp // zerando variavel.
                Return(.f.)
            EndIf 
            /*Vinicius 28/04/2016*/ 
            /*Variavel suporta total alocação.*/         
            IF nQtdAl < aArr[oObj:nAt, COL_ALOCA]  
            
                aArr[oObj:nAt, COL_ALOCA] := nQtdAl         
                nQtdSel += nQtdAl
                nQtdAl := nAlcTotTmp
            /*Vinicius 28/04/2016*/ 
            /*Variavel suporta alocação parcial.*/    
            ElseiF nQtdAl > aArr[oObj:nAt, COL_ALOCA] 
            
               nTempVal := nQtdAl - aArr[oObj:nAt, COL_ALOCA]// Calculo da alocação parcial.                                            
               aArr[oObj:nAt, COL_ALOCA] := (nQtdAl - nTempVal) 
               nQtdSel += (nQtdAl - nTempVal) 
               nQtdAl := nAlcTotTmp // ZERA VARIAVEL
            EndIf
            
        Else  // Está Indo Desmarcar
        
            nTempVal :=  nQtdAl - aArr[oObj:nAt, COL_ALOCA]// Calculo da Deslocação parcial.
            nQtdSel -= (nQtdAl - nTempVal) 
            aArr[oObj:nAt, COL_ALOCA] := 0   
        EndIF

        MarcaUm( aArr, oBrowse:nAt, aArr[oBrowse:nAt, COL_ALOCA])

        oSayB:Refresh()
        oObj:Refresh()
        oObj:SetFocus()
    ElseIf  oObj:ColPos = COL_ALOCA .and. aArr[oObj:nAt, COL_SALDO] > 0
        IF ! aArr[oObj:nAt, COL_MARK] = '0'
            Help(, , STR0026, , STR0041, 1, 0 ) //'Cadencia já se encontra selecionada. Para Alterar a Qt. Alocada, desmarque a cadência e selecione posterior a alteração.'
            Return (.f.)
        Endif
        While .t.
        
            lEditCell(@aArr,oObj,"@E 999,999,999,999,999.99",COL_ALOCA)
            IF !aArr[oObj:nAt, COL_ALOCA] <= aArr[oObj:nAt, COL_SALDO]
                Help(, , STR0026, , STR0042, 1, 0 )     //'Qt.informada maior que saldo disponivel para alocar.'
            ElseIF aArr[oObj:nAt, COL_ALOCA] < 0        //Não Pode ser Qtd. Negativa
                Help(, , STR0026, , STR0043, 1, 0 )     //'Qt. informada não pode ser negativa.'
            ElseIF aArr[oObj:nAt, COL_ALOCA] + nQtdSel > nQtdAl  
                Help(, , STR0026, , STR0044, 1, 0 )     //'Qt. informada somada à Qt. ja selecionada maior que a Qt. a Alocar'
            Else
                If aArr[oObj:nAt, COL_ALOCA] > 0 
                    aArr[oObj:nAt, COL_MARK] := '1'
                    nQtdSel += aArr[oObj:nAt, COL_ALOCA]
                 EndIf
                 Exit 
            EndIF
            
        EndDo
        oObj:Refresh()
        oSayB:Refresh()
        oObj:SetFocus()     
    Endif

Return (.t.)

/** {Protheus.doc} RCadCreate

@param:     Nil
@author:    Bruna Fagundes Rocio
@since:     13/05/2015
@Uso:       SIGAAGR - Originação de Grãos
*/
Static Function RCadCreate(pTipo, aCadencia )
    Local lRetorno  := .t.
    Local nX        := 0
    Local lGrava    := .t.

    For nX := 1 to Len( aCadencia )

        If pTipo = '1' //Compra
            // Qdo ja existir Regrava
            NKB->(DbSetOrder(1))    //NKB_FILIAL+NKB_CTRCOM+NKB_SEQCDC+NKB_CTRVND+NKB_SEQCDV
            lGrava:= NKB->(DbSeek(fWXfilial('NKB')+ (cAliasCTR)->( C_CODCTR+C_ITEM)+aCadencia[nX,COL_CODCTR]+aCadencia[nX,COL_ITEM]))
            
            RecLock('NKB',!lGrava)
            NKB->NKB_FILIAL := xFilial('NKB')
            NKB->NKB_CTRCOM := (cAliasCTR)->C_CODCTR 
            NKB->NKB_SEQCDC := (cAliasCTR)->C_ITEM
            NKB->NKB_CTRVND := aCadencia[nX,COL_CODCTR]
            NKB->NKB_SEQCDV := aCadencia[nX,COL_ITEM]                       
            NKB->NKB_QTDADE += aCadencia[nX,COL_ALOCA]
            NKB->NKB_PRAZOC := (cAliasCTR)->C_DATFIM
            NKB->NKB_PRAZOV := aCadencia[nX,COL_DATFIM] //StoD(aCadencia[nX,COL_DATFIM])
            NKB->NKB_ENTLOC := aCadencia[nX,COL_ENTDES]
            NKB->NKB_LOJLOC := aCadencia[nX,COL_LOJDES]             
            NKB->(MsUnLock())   

        Else //Venda
            // Qdo ja existir Regrava
            NKB->(DbSetOrder(1))    //NKB_FILIAL+NKB_CTRCOM+NKB_SEQCDC+NKB_CTRVND+NKB_SEQCDV
            lGrava:= NKB->(DbSeek(fWXfilial('NKB')+ aCadencia[nX,COL_CODCTR]+aCadencia[nX,COL_ITEM]+(cAliasCTR)->( C_CODCTR+C_ITEM )))
            
            RecLock('NKB', !lGrava )
            NKB->NKB_FILIAL := xFilial('NKB')
            NKB->NKB_CTRCOM := aCadencia[nX,COL_CODCTR]  
            NKB->NKB_SEQCDC := aCadencia[nX,COL_ITEM] 
            NKB->NKB_CTRVND := (cAliasCTR)->C_CODCTR
            NKB->NKB_SEQCDV := (cAliasCTR)->C_ITEM                      
            NKB->NKB_QTDADE += aCadencia[nX,COL_ALOCA]
            NKB->NKB_PRAZOC := aCadencia[nX,COL_DATFIM]
            NKB->NKB_PRAZOV := (cAliasCTR)->C_DATFIM
            NKB->NKB_ENTLOC := aCadencia[nX,COL_ENTORI]
            NKB->NKB_LOJLOC := aCadencia[nX,COL_LOJORI]                     
            NKB->(MsUnLock())
        Endif       
    Next nX     

Return ( lRetorno )


/** {Protheus.doc} MarcaUm
Marca um item do browse que dispõe as cadências diponíveis para alocação

@param:     Nil
@author:    Bruna Fagundes Rocio
@since:     12/05/2015
@Uso:       SIGAAGR - Originação de Grãos
*/

Static Function MarcaUm( aItsMrk, nLinMrk, nQtd )
    Do Case
        Case aItsMrk[ nLinMrk, COL_MARK ] == "0"
        aItsMrk[ nLinMrk, COL_MARK      ] := "1"
        Case aItsMrk[ nLinMrk, COL_MARK ] == "1"
        aItsMrk[ nLinMrk, COL_MARK ] := "0"
    EndCase
Return( )

/** {Protheus.doc} RetTexto

@param:     Nil
@author:    Bruna Fagundes Rocio
@since:     12/05/2015
@Uso:       SIGAAGR - Originação de Grãos
*/

Static Function RetTextoA( aItsMrk, nQtd,cContrato )
    Local cTexto        := ""
    Local cTextoA       := ''

    IF xTpCtrato == CTRATOCPRA
        cTextoA := STR0045 + cContrato + " Qt: "    //"Qt. a Vincular Ref. ao Ctr. Compra: "
    ElseIF xTpCtrato == CTRATOVND
        cTextoA:= STR0046 + cContrato + " Qt: "     //"Qt. a Vincular Ref. ao Ctr. Venda: "
    EndIF
    cTexto := cTextoA + AllTrim( Transform( nQtd, "@E 999,999,999.99" ) )

Return( cTexto )

/** {Protheus.doc} RetTextoB

@param:     Nil
@author:    Bruna Fagundes Rocio
@since:     12/05/2015
@Uso:       SIGAAGR - Originação de Grãos
*/

Static Function RetTextoB( aItsMrk, nQtd,cContrato )
    Local cTexto        := ""
    Local cTextoB       := ''

    IF xTpCtrato == CTRATOCPRA
        cTextoB:= STR0047       //"Qt. Selec. em Ctrs. de Venda: " 
    ElseIF xTpCtrato == CTRATOVND
        cTextoB:= STR0048       //"Qt. Selec. em Ctrs. de Compra: "     
    EndIF

    cTexto:= cTextoB + Alltrim( Transform( nQtdSel, "@E 999,999,999.99" ) )
Return( cTexto )


/** {Protheus.doc} SldCadenc
Calcula saldo disponível cadenc

@param:     Nil
@author:    Bruna Fagundes Rocio
@since:     09/12/2014
@Uso:       SIGAAGR - Originação de Grãos
*/
Static Function SldCadenc(pContrato,pItem)
    Local nQtalocada    := 0
    Local nIndice       := 1
    Local cChave        := ''

    dbSelectArea('NKB')

    IF xTpCtrato == CTRATOCPRA
        nIndice := 1 //NKB_FILIAL+NKB_CTRCOM+NKB_SEQCDC+NKB_CTRVND+NKB_SEQCDV
        cChave:="NKB->(NKB_FILIAL+NKB_CTRCOM+NKB_SEQCDC)"                                                                                                          
    ElseIF  xTpCtrato == CTRATOVND
        nIndice := 3 //NKB_FILIAL+NKB_CTRVND+NKB_SEQCDV
        cChave:="NKB->(NKB_FILIAL+NKB_CTRVND+NKB_SEQCDV)"
    EndIF

    NKB->( dbSetOrder( nIndice ) )
    NKB->( DbSeek( FwXFilial('NKB') + pContrato + pItem ))

    While NKB->(! Eof() ) .and. &(cChave) == FwXFilial('NKB') + pContrato + pItem                                                                                                            
        nQtalocada += NKB->NKB_QTDADE
        NKB->( DbSkip() )
    EndDo


Return ( nQtalocada )




/** {Protheus.doc} OG285CTRV
Calcula saldo disponível da cadencia
do contrato que será vinculado
@param:     Nil
@author:    Bruna Fagundes Rocio
@since:     09/12/2014
@Uso:       SIGAAGR - Originação de Grãos
*/
Function OG285CTRV(pContrato,pItem,nQtdIni,cTpCtrato)
Local nQtalocada    := 0
Local nIndice       := 1
Local cChave        := ''

dbSelectArea('NKB')
// ** Aqui é o Ctrario seo Ctrato Selecionado é Venda
// ** Entao a Lista de contratos para vincular tem que
// ** ser compra, por isso qdo for CTRAtoCpra utilizo
// ** Indice de venda
IF cTpCtrato == CTRATOCPRA
    nIndice := 3 //NKB_FILIAL+NKB_CTRVND+NKB_SEQCDV
    cChave:="NKB->(NKB_FILIAL+NKB_CTRVND+NKB_SEQCDV)"       
ElseIF  cTpCtrato == CTRATOVND
    nIndice := 1 //NKB_FILIAL+NKB_CTRCOM+NKB_SEQCDC+NKB_CTRVND+NKB_SEQCDV
    cChave:="NKB->(NKB_FILIAL+NKB_CTRCOM+NKB_SEQCDC)"   
EndIF

NKB->( dbSetOrder( nIndice ) )
NKB->( DbSeek( FwXFilial('NKB') + pContrato + pItem ))

While NKB->(! Eof() ) .and. &(cChave) == FwXFilial('NKB') + pContrato + pItem                                                                                                            
    nQtalocada += NKB->NKB_QTDADE
    NKB->( DbSkip() )
EndDo


Return ( nQtalocada )

/** {Protheus.doc} fGetTpCtr
Função que identifica o Tipo do Contrato,
necessita NN8 posicionada no ctrato 
@param:     nil
@return:    xTpCtrato preenchida
@author:    Emerson Coelho
@since:     14/01/2015
@Uso:       OGA360
*/
Static Function fGetTpCtr(pContrato)

    NJR->( dbSetOrder( 1 ) )
    IF NJR->( dbSeek( xFilial( "NJR" ) + pContrato ) )
        IF NJR->NJR_TIPO == '1'
            xTpCtrato := CTRATOCPRA 
        ElseIF NJR->NJR_TIPO == '2'
            xTpCtrato := CTRATOVND 
        EndIF
    EndIF

Return  


/** {Protheus.doc} fGObrwDet
Função que cria o Objeto ObrwDet
@param:     Titulo a Ser Mostrado no Browse
@return:    ObrwDet Criado e Ativado 
@author:    Emerson Coelho
@since:     14/01/2015
@Uso:       OGA285
*/

Static Function fGObrwDet( cTitBrwDet  )
    Local nX        := 0
    Local cNoFldDRF  := "D_OK,D_FILIAL,D_RECNO,"
    Local ACOLUMNS  := {}

    If Type("oBrwDet") <> "U"
        oBrwDet:SetDescription( cTitBrwDet )
        //obrwdet:obrowseui:cdescription:=cTitBrwDet
        //oBrwDet:Refresh( .t. )
        //obrwdet:disable()
        oBrwDet:Refresh( .t. )
        //obrwdet:enable()
        //alert('eme')
        //obrwdet:obackpanel:deactivate()
        //oBrwDet:Refresh( .t. )        
        Return()
    EndIF

    DEFINE FWFormBrowse oBrwDet DATA TABLE ALIAS cAliasDRF DESCRIPTION cTitBrwDet OF oPnDet //"Detalhes"
    oBrwDet:SetTemporary(.T.)
    oBrwDet:SetdbFFilter(.T.)
    oBrwDet:SetUseFilter(.T.)   
    oBrwDet:SetFieldFilter(AGRITEMCBRW(aCpBrwDrf))  
    oBrwDet:SetSeek(,aIndice2)
    
    For nX := 1 To Len( aCpBrwDrf )
        If !( aCpBrwDrf[nX,1] $ cNoFldDRF )

            AAdd( aColumns,FWBrwColumn():New() )

            /* Vars. Utilizadas para melhor entendimento */
            cCampo      := aCpBrwDrf[nX,1]
            cTipo       := aCpBrwDrf[nX,2]
            cTitulo     := aCpBrwDrf[nX,5]
            nTamanho    := aCpBrwDrf[nX,3]
            nDecimal    := aCpBrwDrf[nX,4]
            cPicture    := aCpBrwDrf[nX,6]

            aColumns[ Len(aColumns) ]:SetData( &("{||" + cCampo +"}")   )
            aColumns[ Len(aColumns) ]:SetType( cTipo                        )       
            aColumns[ Len(aColumns) ]:SetTitle( cTitulo                 )
            aColumns[ Len(aColumns) ]:SetSize(nTamanho                  )
            aColumns[ Len(aColumns) ]:SetDecimal(nDecimal                   )
            aColumns[ Len(aColumns) ]:SetPicture( cPicture                  )       
            aColumns[ Len(aColumns) ]:SetAlign( If(cTipo == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento
        EndIF
    nExt nX
    

    ADD MARKCOLUMN oColumn DATA { || IIf(( cAliasDRF )->OK == cMarca,'LBOK','LBNO') } ;
    DOUBLECLICK { |oBrwDet| fMarcar( oBrwDet) } ;
    HEADERCLICK { |oBrwDet| fMarcar( oBrwDet) } OF oBrwDet

    oBrwDet:DisableDetails()
    oBrwDet:AddButton('Deletar Vínculo', {|| fDelVinc( oBrwDet ) },,,,,,'10')
    oBrwDet:AddButton(STR0011, {|| oDlg:End() },,,,,,'10')
    oBrwDet:SetColumns( aColumns )      
    ACTIVATE FWFormBrowse oBrwDet
Return()    

/** {Protheus.doc} fGetTpCtr
Função responsavel por mostrar a 
Descrição da Entidade de Origem e Destino da Cadencia 
@param:     ->Array que contem as infs. do Browse
->Linha Atual do Browse
->Ponteiro do objeto Say do Rodape que mostra  
a descrição da Ent. Origem
->Ponteiro do objeto Say do Rodape que mostra  
a descrição da Ent. Destino.

@return:    xTpCtrato preenchida
@author:    Emerson Coelho
@since:     14/01/2015
@Uso:       OGA360
*/
Static Function fShowEntds(aDados, nPosLin, oSayEntOri,oSayEntDes)

    Local cCadOriNom    :=''
    Local cCadDESNom    :=''
    Local cTxtCadORI    := ''
    Local cTxtCadDES    := ''

    cCadOriNom  :=  Alltrim(Posicione("NJ0",1,FwxFilial("NJ0")+aDados[nPosLin,COL_ENTORI]+  aDados[nPosLin,COL_LOJORI],"NJ0->NJ0_NOME"))
    cCadDESNom  :=  Alltrim( Posicione("NJ0",1,FwxFilial("NJ0")+aDados[nPosLin,COL_ENTDES]+ aDados[nPosLin,COL_LOJDES],"NJ0->NJ0_NOME"))

    cTxtCadORI  := STR0050 + aDados[nPosLin,COL_ENTORI] + "-" + aDados[nPosLin,COL_LOJORI]   // Codigo e Lja da Cadencia
    cTxtCadORI  += cCadOriNom  //Descricao da Entidade de Origem

    cTxtCadDES  := STR0051 + aDados[nPosLin,COL_ENTDES] + "-" + aDados[nPosLin,COL_LOJDES]   // Codigo e Lja da Cadencia
    cTxtCadDES  += cCadOriNom  //Descricao da Entidade de Origem

    cTxtRet := cTxtCadori + "   " + cTxtCadDes 

    oSayEntori:SetText( cTxtCadORI )
    oSayEntDes:SetText( cTxtCadDES )

Return (  )



/** {Protheus.doc} fDelVinc
Função responsavel por eliminar
os vinculos dos registros selecionados
 
@param:     nIl
@return:    Registros da NKB Selecionados Eliminados
@author:    Emerson Coelho
@since:     14/01/2015
@Uso:       OGA360
*/
Static Function FdelVinc(oBrwDet)
Local cAlias    := oBrwDet:Alias()

// irei Varrer o Arquivo do Browse todo, poderia criar um Indice para filtrar somente os Marcados
// Mas como não serão milhares e nem mesmo mais de 50 registros. Creio q não haverá
//problema de performance varrer todo o arquivo do browse
(cAlias)->( DbGoTop() )

While (cAlias)->( !Eof() )
 IF (cAlias)->OK == cMarca   // Eliminando Registros Selecionados.
    // Deletando Registro da NKB Tab. vinculos //
    NKB->(DBGOTO((cAlias)->D_RECNO))
    RecLock("NKB",.F.)
    NKB->( DbDelete() )
    NKB->( MsUnlock() )
    //--Deletando Registros Arq. Temp Do Browse //
    RecLock(cAlias,.F.)
    (cAlias)->( DbDelete() )
    (cAlias)->( MsUnlock() )
 EndIF
(cAlias)->(  DbSkip() )
EndDo
//nLinBrwCad:= oBrwCad:nAt
///a285Load( NJR->NJR_CODCTR )  //forçar Atualização do Grid Superior apos eliminar registros vinculados.

    RecLock(cAliasCTR,.F.)
    ( cAliasCTR )->C_QTDVINC:= SldCadenc( ( cAliasCTR )->C_CODCTR,( cAliasCTR )->C_ITEM )
    ( cAliasCTR )->C_QTDSLD := ( cAliasCTR )->C_QTDINT -  ( cAliasCTR )->C_QTDVINC
    
    obrwCAD:Refresh()
    obrwDET:Refresh(.t.)
Return

