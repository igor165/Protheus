#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#include "TOPCONN.CH"
#include "RWMAKE.CH"
#Include "TryException.ch"
#include "fwmvcdef.ch"


#DEFINE oFBar      TFont():New( "Courier New"/*cName*/, /*uPar2*/, -04/*nHeight*/, /*uPar4*/, .F./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFTitLabel TFont():New( "Courier New"/*cName*/, /*uPar2*/, -16/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFLabel    TFont():New( "Courier New"/*cName*/, /*uPar2*/, -08/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFInfo     TFont():New( "Arial"      /*cName*/, /*uPar2*/, -12/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFInfoOBS  TFont():New( "Arial"      /*cName*/, /*uPar2*/, -09/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFontRecor TFont():New( "Tahoma"     /*cName*/, /*uPar2*/, -07/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )

#DEFINE CSSLABEL "QLabel {" +;
    "font-size:12px;" +;
    "font: 12px Arial;" +;
    "}"

/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  MBESTPES 	            	          	            	                  |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  23.09.2020                   	          	            	              |
 | Desc:  Esta rotina irá gerar as telas para o controle de pesagem;              |
 |        Estará presente nesta rotina a impressao do ticket de pesagem;          |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
User Function MBESTPES()

    Private oMBSaveLog	:= MBSaveLog():New() as object
    Private cF3CodCFPes  := ""
    Private cF3LojCFPes  := ""
    Private cF3NomCFPes  := ""
    Private cPlacaTGet   := Iif(ValType(cPlacaTGet)=="U", CriaVar( 'DA3_PLACA' , .F.), cPlacaTGet )
    Private nQualPesagem := 0

    Private cCadastro    := "Cadastro de Peso do Balanção"
    Private cAlias       := "ZPB"
    Private aRotina      := MenuDef()
    /*
    Private aGets       := {}
    Private aTela       := {}
    */
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias( cAlias )
    oBrowse:SetMenuDef("MBESTPES")
    oBrowse:SetDescription( cCadastro )

    oBrowse:AddLegend( "ZPB->ZPB_STATUS <> 'F'", "GREEN" , "Aberto" )
    oBrowse:AddLegend( "ZPB->ZPB_STATUS == 'F'", "RED"   , "Finalizada" )

    oBrowse:Activate()

Return nil


Static Function MenuDef()
    Local aRotina := {}
    //aAdd( aRotina, { 'Visualizar'           , 'U_COMM12VA', 0, 2, 0, nil  } )
    aAdd( aRotina, { 'Pesquisar'            , 'AxPesqui'      , 0, 1, 0 } )
    aAdd( aRotina, { 'Visualizar'           , 'AxVisual'      , 0, 2, 0 } )
    aAdd( aRotina, { 'Pesagens'         	, 'U_Tela1Pesagem', 0, 3, 0 } ) // aAdd( aRotina, { 'Incluir'              , 'AxInclui'      , 0, 3, 0, nil  } )
    aAdd( aRotina, { 'Alterar'              , 'U_Tela2Pesagem', 0, 4, 0 } ) // aAdd( aRotina, { 'Alterar'              , 'AxAltera'      , 0, 4, 0 } )
    aAdd( aRotina, { 'Excluir'              , 'AxDeleta'      , 0, 5, 0 } )
    aAdd( aRotina, { 'Incluir'              , 'AxInclui'      , 0, 6, 0 } )
    aAdd( aRotina, { 'Imprimir Ticket'      , 'StaticCall(MBESTPES, mbPesoPrint)', 0, 7, 0 } )
    aAdd( aRotina, { 'Legenda'         		, 'U_LegPesagem', 0, 9, 0 } )
Return aRotina




