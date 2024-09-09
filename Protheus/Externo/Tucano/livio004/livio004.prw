#INCLUDE 'PROTHEUS.CH'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TRYEXCEPTION.CH"

// #include "colors.ch"
// #INCLUDE "TBICONN.CH"
Static aParBal      := nil      // -- Será inicializada na funcao no Activate do Model (Devido a Error log se executado em MDI )--/

/* Variavel Estatica */
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

/*/{Protheus.doc} User Function LIVIO001
      (Tela de inclus?o de informaç?es para pesagem de gado de saida)
      @type  Function
      @author André A. Alves
      @since 02/01/2021
      @version 1
      @param param_name, param_type, param_descr
      @return return_var, return_type, return_description
      @example
      (examples)
      @see (links_or_references)
      /*/
User Function LIVIO004()            //  U_LIVIO004()

	Local cAlias      := "SZJ"
	Local _aAux       := {}
	Local nI          := 0
	Private _aEmprs   := {}
	Private cCadastro := "Pesagem do Gado Saida"
	Private aRotina   := {}

	aAdd( aRotina, { 'Pesquisar'            , "AxPesqui"     , 0, 1, 0, nil  } )
	aAdd( aRotina, { 'Visualizar'           , "U_LV0004"     , 0, 2, 0, nil  } )
	aAdd( aRotina, { 'Incluir'              , "U_LV0004"     , 0, 3, 0, nil  } )
	aAdd( aRotina, { 'Alterar'              , "U_LV0004"     , 0, 4, 0, nil  } )
	aAdd( aRotina, { 'Excluir'              , "U_LV0004"     , 0, 5, 0, nil  } )
	aAdd( aRotina, { "Legenda"              , "U_LegZamS()"  , 0, 6, 0, nil  } )
	aAdd( aRotina, { "Resumo de Embarque"   , "U_LVRELT05"  , 0, 7, 0, nil  } )
//aAdd( aRotina, { "Imprimir"             , "U_LVRELT05"  , 0, 7, 0, nil  } )
	aAdd( aRotina, { 'Imprimir Ticket (F9)', "U_mbPesoPrint()", 0, 8, 0, nil  } )

	SetKey( VK_F9, { || U_mbPesoPrint() } )

// dbSelectArea(cAlias)
// dbSetOrder(1)
// mBrowse(6,1,22,75,cAlias,,,,,, /* aCores */)

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( cAlias )
	oBrowse:SetMenuDef("LIVIO004")
	oBrowse:SetDescription( cCadastro )

	oBrowse:AddLegend( "SZJ->ZJ_PESOL == 0", "GREEN" , "Aberto"    )
	oBrowse:AddLegend( "!SZJ->ZJ_PESOL == 0", "RED"   , "Finalizada" )

	_aAux := FWEmpLoad(.F.) // pegar empresas existentes no sistema
	for nI := 1 to len(_aAux)
		If aScan( _aEmprs, { |x| x == _aAux[nI, 01] } ) == 0
			aAdd( _aEmprs, _aAux[nI,01] ) // vetor com lista de empresas no SIGAMAT
		EndIf
	next nI
	oBrowse:Activate()

Return Nil

User function LegZamS()

	Local aLegenda := {{ 'BR_VERDE'   , "Aberto"      },;
		{ 'BR_VERMELHO', "Finalizado"  } }
	BrwLegenda(cCadastro, "Legenda", aLegenda)
Return .T.


/* MB : 17.11.2021
      -> Tela Modelo 3;
            -> preenchimento do cabeçalho (ja existente),
      inclusao de GRID, para selecionar lotes (ZSG) */
User Function LV0004(cAlias, nReg, nOpc)

Local nGDOpc        := Iif( nOpc == 2, 0, GD_INSERT + GD_UPDATE + GD_DELETE)
Local nOpcA         := 0
Local oGrpCabe      := nil, oMGet := nil
Local aSize         :={}, aObjects := {}, aInfo := {}, aPObjs := {}, aButtons := {}

Local nDist         := 3
Local nI            := 0
Local lDel 			:= .T.

Local aSZJHead      :={}, aSZJCols := {}, nGUSZJ := 0
Local aZSGHead      :={}, aZSGCols := {}, nGUZSG := 0

// Local _cErro := ""

Private oZSGGtDad   := nil

Private aGets       := {}
Private aTela       := {}

Private aMatQtd  	:= {}
// Posição das colunas
// SZJ
Private nPZJCODIGO  := 0
Private nPZJITEM    := 0
Private nPZJCHVNF   := 0
Private nPZJEMISNF   := 0
//Private nPZJDIGNF   := 0
Private nPZJDOC     := 0
Private nPZJSERIE   := 0
Private nPZJFORNEC  := 0
Private nPZJLOJAF   := 0
Private nPZJNOME    := 0
Private nPZJPESOL   := 0
Private nPZJQTDNF   := 0
Private nPZJQTEMB   := 0
Private nPZJTR1    	:= 0
Private nPZJPS1   	:= 0
Private nPZJTR2    	:= 0
Private nPZJPS2   	:= 0
Private nPZJPRODUTO := 0
Private nPZJPEMAN1  := 0
Private nPZJPEMAN2  := 0
Private nPZJPEMAN3  := 0
Private nPZJPEMAN4  := 0
Private nPZJDATA1   := 0
Private nPZJHORA1   := 0
Private nPZJDATA2   := 0
Private nPZJHORA2   := 0
Private nPZJDATA3   := 0
Private nPZJHORA3   := 0
Private nPZJDATA4   := 0
Private nPZJHORA4   := 0
Private nPZJMOTORI  := 0
Private nPZJCTE     := 0
Private nPZJMINUTA  := 0
Private nPZJGTA     := 0
Private NPZJEMPFIL  := 0
Private NPZJTPPES  := 0
// ZSG
Private nPZSGCODIGO := 0
Private nPZSGLOTE   := 0
Private nPZSGDATASE := 0
Private nPZSGUSUARI := 0
Private nPZSGRCNOD3 := 0
Private nPZSGQUANT  := 0
Private nPZSGUSUARI := 0
Private nPZSGPRODUT := 0
Private nPZSGPRDDES := 0
Private nPZSGLOCAL  := 0
Private nPZSGRACA  := 0
Private nPZSGCHVNF  := 0
Private nPZSGEMPFIL := 0
Private oDlg        := nil


IF nOpc == 3
	If !ParamBox({{2,"Tipo de Pesagem",1,{"S=Simples","D=Dupla"},122,".T.",.F.}},"Informe o Tipo de Pesagem")
		MsgInfo("Informe o tipo de pesagem!")
		return nil
	endif
endif

if Type( "MV_PAR01" ) == "N"
	if MV_PAR01 == 1
		MV_PAR01 := "S"
	else 
		MV_PAR01 := "D"
	endif 
endif

RegToMemory( cAlias, nOpc == 3 )

aSize := MsAdvSize( .T. )
AAdd( aObjects, { 100 , 50, .T. , .T. , .F. } )
AAdd( aObjects, { 100 , 50, .T. , .T. , .F. } )

aInfo  := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
aPObjs := MsObjSize(aInfo, aObjects, .T., .F.) 

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From 0,0 to aSize[6],aSize[5] PIXEL STYLE ;
                  nOR( WS_VISIBLE, DS_MODALFRAME )  // tirar o X da tela | tirar o botao X da tela |
oDlg:lMaximized := .T.

oGrpNFat := TGroup():New( aPObjs[1, 1]+nDist, aPObjs[1, 2]+nDist, aPObjs[1, 3], aPObjs[1, 4],;
			            "Notas Fiscais Faturadas", oDlg/* oTFoldeP:aDialogs[1] */,,, .T.,)

U_BDados( "SZJ", @aSZJHead, @aSZJCols, @nGUSZJ, 1, , IIf( nOpc != 3, "'" + M->ZJ_CODIGO + "' == SZJ->ZJ_CODIGO", nil  ) )
oSZJGtDad := MsNewGetDados():New( 0, 0, 0, 0, nGDOpc, "U_fSZJLinOk()", /* cTudoOk */, ;
							  "+ZJ_ITEM" , , , , "U_fSZJFieldOK()" /* cFieldOK */, ,;
                              "u_fSZJDelOk()", ;
				      		  oGrpNFat /* oTFoldeG:aDialogs[1] */, ;
							  aClone(aSZJHead), aClone( aSZJCols ) )
oSZJGtDad:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

nPZJCODIGO  := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_CODIGO" } )
nPZJITEM    := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_ITEM"   } )
nPZJCHVNF   := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_CHVNF"  } )
nPZJEMISNF  := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_EMISNF" } )

nPZJDOC     := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_DOC"    } )
nPZJSERIE   := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_SERIE"  } )

nPZJFORNEC  := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_FORNEC" } )
nPZJLOJAF   := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_LOJAF"  } )
nPZJNOME    := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_NOME"   } )

nPZJQTDNF   := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_QTDNF"  } )
nPZJQTEMB   := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_QTEMB"  } )
nPZJTR1    	:= aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_TARACAM"} )
nPZJPS1   	:= aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_PESOCAM"} )
nPZJTR2    	:= aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_TARACA1"} )
nPZJPS2   	:= aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_PESCAM2"} )
nPZJPESOL   := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_PESOL"  } )
nPZJPESMED  := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_MEDNF"  } )
nPZJPRODUTO := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_PRODUTO"} )
nPZJPEMAN1  := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_PEMAN1" } )
nPZJPEMAN2  := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_PEMAN2" } )
nPZJPEMAN3  := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_PEMAN3" } )
nPZJPEMAN4  := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_PEMAN4" } )

nPZJDATA1 := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_DATA1"} )
nPZJHORA1 := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_HORA1"} )
nPZJDATA2 := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_DATA2"} )
nPZJHORA2 := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_HORA2"} )
nPZJDATA3 := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_DATA3"} )
nPZJHORA3 := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_HORA3"} )
nPZJDATA4 := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_DATA4"} )
nPZJHORA4 := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_HORA4"} )

NPZJTPPES := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_TPPES"} )

nPZJCODMOT  := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_CODMOT"   } )
nPZJPLACA   := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_PLACA"    } )
nPZJMOTORI  := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_MOTORIS"  } )
nPZJCTE     := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_CTE"      } )
nPZJMINUTA  := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_NMINUTA"  } )
nPZJGTA     := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_GTA"      } )
nPZJEMPFIL  := aScan( oSZJGtDad:aHeader, { |x| AllTrim(x[2]) == "ZJ_EMPFIL"   } )

If Len(aSZJCols)==1 .AND. Empty( aSZJCols[ 01, nPZJCODIGO ] ) // nOpc == 3
	oSZJGtDad:aCols[ 01, nPZJCODIGO  ]/* aSZJCols[ 01, nPZJCODIGO ] */ := GETSX8NUM('SZJ','ZJ_CODIGO')      // M->ZJ_CODIGO 
	oSZJGtDad:aCols[ 01, nPZJITEM    ]/* aSZJCols[ 01, nPZJITEM   ] */ := StrZero( 1, TamSX3('ZJ_ITEM')[1]) // M->ZJ_ITEM   
	oSZJGtDad:aCols[ 01, NPZJTPPES   ]/* aSZJCols[ 01, nPZJITEM   ] */ := MV_PAR01 // M->ZJ_TPPES   
EndIf

oGrpItens := TGroup():New( aPObjs[2, 1]+nDist, aPObjs[2, 2]+nDist, aPObjs[2, 3], aPObjs[2, 4],;
			            "Lotes Faturados", oDlg/* oTFoldeP:aDialogs[1] */,,, .T.,)

U_BDados( "ZSG", @aZSGHead, @aZSGCols, @nGUZSG, 1, , IIf( nOpc != 3, "'" + M->ZJ_CODIGO + "' == ZSG->ZSG_CODIGO", nil  ) )
oZSGGtDad := MsNewGetDados():New( 0, 0, 0, 0, nGDOpc, "U_fZSGLinOk()", /* cTudoOk */, ;
							  "+ZSG_ITEM" , , , , "U_fZSGFieldOK()" /* cFieldOK */, ,;
                              "u_fZSGDelOk()", ;
				      		  oGrpItens /* oTFoldeG:aDialogs[1] */, ;
							  aClone(aZSGHead), aClone( aZSGCols ) )
oZSGGtDad:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

nPZSGCODIGO := aScan( oZSGGtDad:aHeader, { |x| AllTrim(x[2]) == "ZSG_CODIGO" } )
nPZSGSZJITE := aScan( oZSGGtDad:aHeader, { |x| AllTrim(x[2]) == "ZSG_SZJITE" } )
nPZSGITEM   := aScan( oZSGGtDad:aHeader, { |x| AllTrim(x[2]) == "ZSG_ITEM" } )
nPZSGLOTE   := aScan( oZSGGtDad:aHeader, { |x| AllTrim(x[2]) == "ZSG_LOTE" } )
nPZSGDATA   := aScan( oZSGGtDad:aHeader, { |x| AllTrim(x[2]) == "ZSG_DATA" } )
nPZSGDATASE := aScan( oZSGGtDad:aHeader, { |x| AllTrim(x[2]) == "ZSG_DATASE" } )
nPZSGUSUARI := aScan( oZSGGtDad:aHeader, { |x| AllTrim(x[2]) == "ZSG_USUARI" } )
nPZSGQUANT  := aScan( oZSGGtDad:aHeader, { |x| AllTrim(x[2]) == "ZSG_QUANT"  } )
nPZSGPRODUT := aScan( oZSGGtDad:aHeader, { |x| AllTrim(x[2]) == "ZSG_PRODUT"  } )
nPZSGPRDDES := aScan( oZSGGtDad:aHeader, { |x| AllTrim(x[2]) == "ZSG_PRDDES"  } )
nPZSGLOCAL  := aScan( oZSGGtDad:aHeader, { |x| AllTrim(x[2]) == "ZSG_LOCAL"  } )
nPZSGUSUARI := aScan( oZSGGtDad:aHeader, { |x| AllTrim(x[2]) == "ZSG_USUARI" } )
nPZSGRCNOD3 := aScan( oZSGGtDad:aHeader, { |x| AllTrim(x[2]) == "ZSG_RCNOD3" } )
nPZSGRACA 	:= aScan( oZSGGtDad:aHeader, { |x| AllTrim(x[2]) == "ZSG_RACA" } )
nPZSGCHVNF  := aScan( oZSGGtDad:aHeader, { |x| AllTrim(x[2]) == "ZSG_CHVNF" } )

nPZSGEMPFIL := aScan( oZSGGtDad:aHeader, { |x| AllTrim(x[2]) == "ZSG_EMPFIL"  } )

// Inicialização de Campos
If  Len(aZSGCols)==1 .AND. Empty( aZSGCols[ 01, nPZSGITEM ] )
	oZSGGtDad:aCols[ 01, nPZSGCODIGO ] 	:= oSZJGtDad:aCols[ 01, nPZJCODIGO]
	oZSGGtDad:aCols[ 01, nPZSGITEM ]	:= StrZero( 1, TamSX3('ZSG_ITEM')[1])
	oZSGGtDad:aCols[ 01, NPZJTPPES ]	:= MV_PAR01
EndIf

AAdd( aButtons, { "AUTOM", { || U_EstornoBaixa() }, "Realizar Estorno da Baixa dos Animais (F7)" } )
AAdd( aButtons, { "AUTOM", { || U_fBxaAnimais()  }, "Realizar Baixa dos Animais (F8)" } )
AAdd( aButtons, { "AUTOM", { || U_fPegaPeso(nOpc)  }  , "Captura Peso (F10)" } )

SetKey( VK_F7, { || U_EstornoBaixa() } )
SetKey( VK_F8, { || U_fBxaAnimais()  } )
SetKey( VK_F10,{ || U_fPegaPeso(nOpc)  } )

ACTIVATE MSDIALOG oDlg ;
          ON INIT EnchoiceBar(oDlg,;
                              { || nOpcA := 1, Iif( fVldOk() .and. Obrigatorio(aGets, aTela),;
							  								 oDlg:End(),;
															 nOpcA := 0 )},;
                              { || nOpcA := 0, oDlg:End() },, aButtons )
If nOpc == 3 .or. nOpc == 4
 	If nOpcA == 0
		RollbackSX8()
 	ElseIf nOpcA == 1
		Begin Transaction
			For nI := 1 to Len(oSZJGtDad:aCols)
				If !oSZJGtDad:aCols[nI][ Len(oSZJGtDad:aCols[1]) ]
					
					// If Empty( _cErro )
						DbSelectArea( "SZJ" )
						SZJ->( DbSetOrder( 1 ) )
						RecLock( "SZJ", lRecLock := !DbSeek( xFilial("SZJ") +;
													oSZJGtDad:aCols[nI, nPZJCODIGO] +;
													oSZJGtDad:aCols[nI, nPZJITEM  ] ) )
							U_GrvCpo( "SZJ", oSZJGtDad:aCols, oSZJGtDad:aHeader, nI )
							If lRecLock
							 	SZJ->ZJ_FILIAL := xFilial("SZJ")
							EndIf
						SZJ->( MsUnlock() )
					// EndIf
				Else // Se o registro foi excluido e existe no banco apaga
					DbSelectArea( "SZJ" )
					SZJ->( DbSetOrder( 1 ) )
					If SZJ->( DbSeek( xFilial("SZJ") + oSZJGtDad:aCols[nI, nPZJCODIGO] + oSZJGtDad:aCols[nI, nPZJITEM] ) )
						RecLock("SZJ", .F.)
							SZJ->( DbDelete() )
						SZJ->( MsUnlock() )
					EndIf
				EndIf
			Next i 

		   // LOTES SB8
			For nI := 1 to Len(oZSGGtDad:aCols)
				If !oZSGGtDad:aCols[nI][ Len(oZSGGtDad:aCols[1]) ] 
					 If !EMPTY( oZSGGtDad:aCols[ nI, nPZSGLOTE ])  // MB : 26.12.22 Tirei a pedido do toshio
						 If Empty( oZSGGtDad:aCols[ nI, nPZSGEMPFIL ] )
							Alert("Utilize a Consulta Padrão [F3] para escolher o LOTE, dados não serão salvos pois o campo 'Emp e Fil' (Empresa e Filial da NF) Não está preenchido  ")
							Return Nil
						 EndIf
						
						// If Empty( _cErro )
							DbSelectArea( "ZSG" )
							ZSG->( DbSetOrder( 1 ) )
							RecLock( "ZSG", lRecLock := !DbSeek( xFilial("ZSG") +;
													oZSGGtDad:aCols[ nI, nPZSGCODIGO ] +;
													oZSGGtDad:aCols[ nI, nPZSGSZJITE ] +;
													oZSGGtDad:aCols[ nI, nPZSGITEM   ] ) )
								U_GrvCpo( "ZSG", oZSGGtDad:aCols, oZSGGtDad:aHeader, nI )
								If lRecLock
									ZSG->ZSG_FILIAL := xFilial("ZSG")
								EndIf
								ZSG->( MsUnlock() )
						// EndIf
					 EndIf
				Else // Se o registro foi excluido e existe no banco apaga
					DbSelectArea( "ZSG" )
					ZSG->( DbSetOrder( 1 ) )
					If ZSG->( DbSeek( xFilial("ZSG") + oZSGGtDad:aCols[ nI, nPZSGCODIGO ] + oZSGGtDad:aCols[ nI, nPZSGSZJITE ] + oZSGGtDad:aCols[ nI, nPZSGITEM ] ) )
						RecLock("ZSG", .F.)
							ZSG->( DbDelete() )
						ZSG->( MsUnlock() )
					EndIf
				EndIf
			Next i 
				While __lSX8
					ConfirmSX8()
				EndDo
        End Transaction
	EndIf

ElseIf nOpc == 5

	DbSelectArea( "ZSG" )
	ZSG->( DbSetOrder( 1 ) )
	For nI := 1 to Len(oZSGGtDad:aCols)
		If ZSG->( DbSeek( xFilial("ZSG") + oZSGGtDad:aCols[ nI, nPZSGCODIGO ] + oZSGGtDad:aCols[ nI, nPZSGSZJITE ] + oZSGGtDad:aCols[ nI, nPZSGITEM ] ) )
			IF !Empty(ZSG->ZSG_DATASE)
				MsgAlert("Esta pesagem ja teve saída de animais do estoque, deve-se estornar a baixa do estoque antes de fazer a exclusão")
				lDel := .f. 
				exit
			elseif !Empty(ZSG->ZSG_CODZAB) .or. !Empty(ZSG->ZSG_DTABAT)
				MsgAlert("Esta pesagem está vinculada à um abate, entrar em contato com o responsável para desfazer o vinculo pesagem e abate")
				lDel := .f. 
				exit
			ENDIF 
		EndIf
	Next nI
	
	if lDel
		DbSelectArea( "SZJ" )
		SZJ->( DbSetOrder( 1 ) )
		For nI := 1 to Len(oSZJGtDad:aCols)
			If SZJ->( DbSeek( xFilial("SZJ") + oSZJGtDad:aCols[nI, nPZJCODIGO] + oSZJGtDad:aCols[nI, nPZJITEM] ) )
				RecLock("SZJ", .F.)
					SZJ->( DbDelete() )
				SZJ->( MsUnlock() )
			EndIf
		Next nI

		DbSelectArea( "ZSG" )
		ZSG->( DbSetOrder( 1 ) )
		For nI := 1 to Len(oZSGGtDad:aCols)
			If ZSG->( DbSeek( xFilial("ZSG") + oZSGGtDad:aCols[ nI, nPZSGCODIGO ] + oZSGGtDad:aCols[ nI, nPZSGSZJITE ] + oZSGGtDad:aCols[ nI, nPZSGITEM ] ) )
				RecLock("ZSG", .F.)
					ZSG->( DbDelete() )
				ZSG->( MsUnlock() )
			EndIf
		Next nI
	EndIf

	if !lDel 
		lDel := .T. 
	endif 
EndIf

return nil

/*---------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                        |
 | Data:     10.12.2021                                                            |
 | Cliente:  Tucano                                                                |
 | Desc:     									                                   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras:                                                                         |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.:     -                                                                     |
 '---------------------------------------------------------------------------------*/
User Function fSZJLinOk( )
	// MsgInfo("fSZJLinOk")
Local lRet := Obrigatorio(aGets, aTela)
Local nPos    := oSZJGtDad:nAt
	If Empty(oSZJGtDad:aCols[nPos, nPZJEMISNF])
		oSZJGtDad:aCols[nPos, nPZJEMISNF] := dDataBase
	EndIf
	//If Empty(oSZJGtDad:aCols[nPos, nPZJDIGNF])
	//	oSZJGtDad:aCols[nPos, nPZJDIGNF] := dDataBase
	//EndIf
	If !(lRet := !Empty(oSZJGtDad:aCols[nPos, nPZJQTDNF]))
		MsgAlert("Campo QUANTIDADE não informado na linha: " + cValToChar(nPos),;
				 "Atenção"+ CRLF +"Campo não informado")
	EndIf
Return lRet

/*---------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                        |
 | Data:     10.12.2021                                                            |
 | Cliente:  Tucano                                                                |
 | Desc:     									                                   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras:                                                                         |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.:     -                                                                     |
 '---------------------------------------------------------------------------------*/
User Function fSZJFieldOK( )
Local nPos     := oSZJGtDad:nAt, nAux := 0
Local cCodigo  := ""
Local _cQry    := ""
Local cAlias   := GetNextAlias()
Local cAliasX  := GetNextAlias()
Local cAliasZ  := GetNextAlias()
Local cAliasY  := GetNextAlias()



	If nPos > 1 .and. Empty(oSZJGtDad:aCols[ nPos, nPZJCODIGO])
		If !Empty( cCodigo := oSZJGtDad:aCols[ nPos-1, nPZJCODIGO] )
			oSZJGtDad:aCols[ nPos, nPZJCODIGO] := cCodigo
		EndIf
	EndIf

	If (oSZJGtDad:oBrowse:nColPos == nPZJCHVNF )

		If Empty( &(ReadVar()) )
			oSZJGtDad:aCols[ nPos, nPZJDOC    ] := ""
			oSZJGtDad:aCols[ nPos, nPZJSERIE  ] := ""
			oSZJGtDad:aCols[ nPos, nPZJFORNEC ] := ""
			oSZJGtDad:aCols[ nPos, nPZJLOJAF  ] := ""
			oSZJGtDad:aCols[ nPos, nPZJNOME   ] := ""
			Return .F.
		EndIf

		If Len(oSZJGtDad:aCols)>1 .AND.;
			(nAux:=aScan( oSZJGtDad:aCols, { |x| x[nPZJCHVNF] == &(ReadVar()) } ) ) > 0 .AND.;
		    (nPos<>nAux .and. oSZJGtDad:aCols[ nPos, nPZJCHVNF] <> &(ReadVar()))

			/*Arthur Toshio 27/09/2022*/
			dbUseArea(.T.,'TOPCONN',TCGENQRY(,, ;		
				  _cQry := " SELECT * " + CRLF +;
							 " FROM SD2010 SD2 " + CRLF +;
							 " JOIN SF2010 SF2 ON " + CRLF +;
								  " SD2.D2_FILIAL = SF2.F2_FILIAL " + CRLF +;
							  " AND SD2.D2_DOC = SF2.F2_DOC " + CRLF +;
							  " AND SD2.D2_SERIE = SF2.F2_SERIE " + CRLF +;
							  " AND SD2.D2_CLIENTE = SF2.F2_CLIENTE " + CRLF +;
							  " AND SD2.D2_LOJA = SF2.F2_LOJA " + CRLF +;
							  " AND SD2.D2_EMISSAO = SF2.F2_EMISSAO " + CRLF +;
							  " AND SF2.D_E_L_E_T_ = ' ' " + CRLF +;
							  " WHERE F2_CHVNFE = '" + &(ReadVar()) + "' " + CRLF +;
								" AND F2_CHVNFE + D2_COD NOT IN ( " + CRLF +;
								                               " SELECT ZJ.ZJ_CHVNF+ZJ.ZJ_PRODUTO " + CRLF +;
									                             " FROM SZJ010 ZJ " + CRLF +;
									                            " WHERE ZJ.ZJ_CHVNF + ZJ.ZJ_PRODUTO = SF2.F2_CHVNFE + SD2.D2_COD " + CRLF +;
									                              " AND ZJ.D_E_L_E_T_ = ' ' ) "  ;
				), cAlias ,.F.,.F.)
			If (cAlias)->(Eof())					
				MsgAlert("A chave informada: " + &(ReadVar()) + " não pode ser utilizada porque ja foi registrada na linha: "+;
						cValToChar(nAux) + " (" + AllTrim(Extenso( nAux, 1)) + ")", "Atenção")
				Return .F.
			EndIf
			(cAlias)->(DbCloseArea())
		Endif

		dbUseArea(.T.,'TOPCONN',TCGENQRY(,, ;
						_cQry := " SELECT 	* " + CRLF +;
								 " FROM 	" + RetSqlName("SZJ") + " " + CRLF +;
								 " WHERE	ZJ_CHVNF = '" + &(ReadVar()) + "' " + CRLF +;
								 " 	    AND ZJ_CHVNF + ZJ_PRODUTO not in ( " + CRLF +;
																		  " SELECT F2_CHVNFE + D2_COD" + CRLF +;
																		    " FROM SD2010 SD2 " + CRLF +;
																		    " JOIN SF2010 SF2 ON " + CRLF +;
																		         " SD2.D2_FILIAL = SF2.F2_FILIAL " + CRLF +;
																		     " AND SD2.D2_DOC = SF2.F2_DOC " + CRLF +;
																		     " AND SD2.D2_SERIE = SF2.F2_SERIE " + CRLF +;
																		     " AND SD2.D2_CLIENTE = SF2.F2_CLIENTE " + CRLF +;
																		     " AND SD2.D2_LOJA = SF2.F2_LOJA " + CRLF +;
																		     " AND SD2.D2_EMISSAO = SF2.F2_EMISSAO " + CRLF +;
																		     " AND SF2.D_E_L_E_T_ = ' ' " + CRLF +;
																		   " WHERE SD2.D_E_L_E_T_ = ' ' ) " + CRLF +;
								 " 	    AND D_E_L_E_T_ = ' '" ;
				), cAliasZ ,.F.,.F.)
		If !(cAliasZ)->(Eof())
			MsgAlert("A chave informada: " + AllTrim(&(ReadVar())) + " não pode ser utilizada porque ja foi registrada na pesagem: "+;
					 (cAliasZ)->ZJ_CODIGO + "-" + (cAliasZ)->ZJ_ITEM, "Atenção")
			(cAliasZ)->(DbCloseArea())

			If Empty( oSZJGtDad:aCols[ nPos, nPZJCHVNF] )
				oSZJGtDad:aCols[ nPos, nPZJDOC    ] := ""
				oSZJGtDad:aCols[ nPos, nPZJSERIE  ] := ""
				oSZJGtDad:aCols[ nPos, nPZJFORNEC ] := ""
				oSZJGtDad:aCols[ nPos, nPZJLOJAF  ] := ""
				oSZJGtDad:aCols[ nPos, nPZJNOME   ] := ""
			EndIf
			Return .F.
		endIf
		(cAliasZ)->(DbCloseArea())

		dbUseArea(.T.,'TOPCONN',TCGENQRY(,, ;
						_cQry := " SELECT	DISTINCT	D2_GRUPO " + CRLF +;
								 " FROM		" + RetSqlName("SF2") + " F2 " + CRLF +;
								 " JOIN		" + RetSqlName("SD2") + " D2	ON F2_FILIAL  =  '" + xFilial('SF2') + "' AND F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA " + CRLF +;
								 " 					AND D2.D_E_L_E_T_ = ' ' " + CRLF +;
								 " WHERE	F2_FILIAL	=  '" + xFilial('SF2') + "'" + CRLF +;
								 "      AND F2_CHVNFE	=  '" + &(ReadVar()) + "'"+ CRLF +;
								 " 		AND F2.D_E_L_E_T_ = ' ' " ;
				), cAliasY ,.F.,.F.)
		If !(cAliasY)->(Eof())
			If !( Left((cAliasY)->D2_GRUPO,2) $ GetMV( 'MB_LIVIO4C',, '05') ) // GRUPO DO PRODUTO
				MsgAlert("O grupo encontrado na chave: " + &(ReadVar()) + " não possui produtos relacionados "+;
						 " ao grupo de bovinos, grupo encontrado na NF: " + (cAliasY)->D2_GRUPO, "Atenção")
				(cAliasY)->(DbCloseArea())
				Return .F.
			EndIf
		endIf
		(cAliasY)->(DbCloseArea())
		
		dbUseArea(.T.,'TOPCONN',TCGENQRY(,, ;
					   	_cQry := " SELECT		--	F2_CHVNFE, * " + CRLF +;
								 " 			F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, A1_NOME, F2_EMISSAO, D2_COD, " + CRLF +;
								 "  		SUM(D2_QUANT) QUANT, COUNT(*) QTD " + CRLF +;
								 " FROM		" + RetSqlName("SF2") + " F2 " + CRLF +;
								 " JOIN		" + RetSqlName("SD2") + " D2	ON F2_FILIAL  =  '" + xFilial('SF2') + "' AND F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA " + CRLF +;
								 " 					AND D2.D_E_L_E_T_ = ' ' " + CRLF +;
								 " JOIN		" + RetSqlName("SA1") + " A1	ON A1_FILIAL = '" + xFilial('SA1') + "' AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA  " + CRLF +;
								 " 					AND A1.D_E_L_E_T_ = ' ' " + CRLF +;
								 " WHERE	F2_FILIAL	=  '" + xFilial('SF2') + "'" + CRLF +;
								 "      AND F2_CHVNFE	=  '" + &(ReadVar()) + "'" + CRLF +;
								 " 		AND F2.D_E_L_E_T_ = ' ' " + CRLF +;
								 " 		AND  F2.F2_CHVNFE + D2_COD NOT IN ( SELECT ZJ_CHVNF + ZJ_PRODUTO FROM SZJ010 ZJ WHERE ZJ_CHVNF + ZJ_PRODUTO <> F2_CHVNFE + D2_DOC AND ZJ.D_E_L_E_T_ = ' ' ) " + CRLF +;
								 " GROUP BY	F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, A1_NOME, F2_EMISSAO, D2_COD " ;
				), cAliasX ,.F.,.F.)
		If !(cAliasX)->(Eof())
			if nPZJDOC>0
				oSZJGtDad:aCols[ nPos, nPZJDOC    ] := (cAliasX)->F2_DOC
			EndIf
			if nPZJSERIE>0
				oSZJGtDad:aCols[ nPos, nPZJSERIE  ] := (cAliasX)->F2_SERIE
			EndIf
			if nPZJFORNEC>0
				oSZJGtDad:aCols[ nPos, nPZJFORNEC ] := (cAliasX)->F2_CLIENTE
			EndIf
			if nPZJLOJAF>0
				oSZJGtDad:aCols[ nPos, nPZJLOJAF  ] := (cAliasX)->F2_LOJA
			EndIf
			if nPZJNOME>0
				oSZJGtDad:aCols[ nPos, nPZJNOME   ] := (cAliasX)->A1_NOME
			EndIf
			if nPZJQTDNF>0
				oSZJGtDad:aCols[ nPos, nPZJQTDNF  ] := (cAliasX)->QUANT
			EndIf
			if nPZJEMISNF>0
				oSZJGtDad:aCols[ nPos, nPZJEMISNF ] := sToD((cAliasX)->F2_EMISSAO)
			EndIf
			if nPZJPRODUTO>0
				oSZJGtDad:aCols[ nPos, nPZJPRODUTO] := (cAliasX)->D2_COD
			EndIf
		EndIf
		(cAliasX)->(DbCloseArea())
	EndIf

Return .T.

/*---------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                        |
 | Data:     10.12.2021                                                            |
 | Cliente:  Tucano                                                                |
 | Desc:     									                                   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras:                                                                         |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.:     -                                                                     |
 '---------------------------------------------------------------------------------*/
User Function fSZJDelOk( )
// 	MsgInfo("fSZJDelOk")
Local nI        := 0
Local lErro		:= .F.
Local nZSGTotQtd := 0
Local nSZJ      := 0, nSZJTot := Len(oSZJGtDad:aCols)
Local nZSG      := 0, nZSGTot := Len(oZSGGtDad:aCols)

For nSZJ := oSZJGtDad:nAt to nSZJTot
	If nSZJ == oSZJGtDad:nAt
		For nZSG := 1 to nZSGTot
			if oSZJGtDad:aCols[ nSZJ, nPZJCHVNF ] == oZSGGtDad:aCols[ nZSG, nPZSGCHVNF ]
				// If nZSG==oZSGGtDad:nAt //  Empty( oZSGGtDad:aCols[ nZSG, nPZSGCHVNF ] )
				// 	nZSGTotQtd += &(ReadVar())
				// Else
					nZSGTotQtd += oZSGGtDad:aCols[ nZSG, nPZSGQUANT ]
				// EndIf
			EndIf
		Next 
		If lErro := (nZSGTotQtd > 0)
			MsgAlert("A NF: " + AllTrim(oSZJGtDad:aCols[ nSZJ, nPZJDOC ]) + "-" + AllTrim(oSZJGtDad:aCols[ nSZJ, nPZJSERIE ]) +;
					" na linha: " + cValToChar(nSZJ) + " não pode ser excluida pois ja foi referenciada com os lotes.", "AVISO")
			Exit
		EndIf
	EndIf
Next 

Return !lErro

/*=======================================================================================================================
	MB : 22.11.2021
		-> Validação da linha:
			1. Verificar quantidade informada da linha se nao ultrapassa o definido no 
				registro da nota;
=======================================================================================================================*/
User Function fZSGLinOk( nTotal, lFieldOK )
Default nTotal   := 0
Default lFieldOK := .F.
/*
Local nI         := 0
Local nLinSZJ    := oSZJGtDad:nAt
Local nSZJAtu    := 1
Local nSZJTot    := Len(oSZJGtDad:aCols)
Local nZSGAtu    := 1
Local nZSGTot    := Len(oZSGGtDad:aCols)


While nSZJAtu <= nSZJTot

	// For nZSGAtu := 1 to Len(oZSGGtDad:aCols)
	While nZSGAtu <= nZSGTot

		If oSZJGtDad:aCols[ nLinSZJ, nPZJCHVNF ] = oZSGGtDad:aCols[ nZSGAtu, nPZSGCHVNF ] 
			nTotal += oZSGGtDad:aCols[ nZSGAtu, nPZSGQUANT ]
		EndIf
	EndDo
	// Next nZSGAtu

	nSZJAtu++
EndDo

------------------------------------------------------------------------------------------------------------------------------

For nI := 1 to Len(oZSGGtDad:aCols)

	if nI == oZSGGtDad:nAt
		oZSGGtDad:aCols[ oZSGGtDad:nAt, nPZSGCHVNF ] := oSZJGtDad:aCols[ nLinSZJ, nPZJCHVNF ]
	EndIf

	If oSZJGtDad:aCols[ nLinSZJ, nPZJCHVNF ] <> oZSGGtDad:aCols[ nI, nPZSGCHVNF ] 
		Loop
	EndIf

	If oZSGGtDad:aCols[ nI, Len(oZSGGtDad:aCols[nI]) ]
		Loop
	EndIf

	if lFieldOK .and. ( nI == oZSGGtDad:oBrowse:nAt )
		Loop
	EndIf

	nTotal += oZSGGtDad:aCols[ nI, nPZSGQUANT ]

Next nI

If nTotal > oSZJGtDad:aCols[ nLinSZJ, nPZJQTDNF ] // M->ZJ_QTDNF
	Alert("Quantidade definida para baixar ultrapassou a quantidade da nota fiscal.")
	Return .F.
EndIf
*/

Return .T.

/*=======================================================================================================================
	MB : 22.11.2021
		-> Validação da Campos:
			1. 
=======================================================================================================================*/
User Function fZSGFieldOK()
Local aAreaSB1     := SB1->(GetArea())
Local lRet         := .T.
Local nI           := 0
Local nZSGTotQtd   := 0
Local nSZJ         := 0, nZSG :=0, nPos := 0
Local nZSGAtu      := 0

Private aChvChange := {}
Private lContinua  := .T.
Private nSZJAtu    := 0, nSZJTot := Len(oSZJGtDad:aCols), cSZJChave := "", nSZJQtde := 0
Private nZSGTot := Len(oZSGGtDad:aCols)

	// oZSGGtDad:oBrowse:nColPos : Pegar Posição das Colunas
	If ( oZSGGtDad:oBrowse:nColPos == nPZSGLOTE ) .OR. ( oZSGGtDad:oBrowse:nColPos == nPZSGPRODUT )

		oZSGGtDad:aCols[ oZSGGtDad:nAt, nPZSGPRDDES ] := Posicione('SB1', 1, xFilial('SB1')+oZSGGtDad:aCols[ oZSGGtDad:nAt, nPZSGPRODUT ], 'B1_DESC')

	ElseIf ( oZSGGtDad:oBrowse:nColPos == nPZSGQUANT )

		If &(ReadVar()) <= 0
			MsgAlert("Favor informar a quantidade do lote." + CRLF + "Esta operação será cancelada.", "Atenção")
			lRet := .F.
		EndIf
		
		If lRet
			// fCriaMatriz()
			aMatQtd := {}
			For nSZJ := 1 to nSZJTot
				nZSGTotQtd   := 0
				For nZSG := 1 to nZSGTot
					if oSZJGtDad:aCols[ nSZJ, nPZJCHVNF ] == oZSGGtDad:aCols[ nZSG, nPZSGCHVNF ]
						If nZSG==oZSGGtDad:nAt //  Empty( oZSGGtDad:aCols[ nZSG, nPZSGCHVNF ] )
							nZSGTotQtd += &(ReadVar())
						Else
							nZSGTotQtd += oZSGGtDad:aCols[ nZSG, nPZSGQUANT ]
						EndIf
					EndIf
				Next nZSG
				aAdd( aMatQtd, {;
						oSZJGtDad:aCols[ nSZJ, nPZJCODIGO],;              // 01 
						oSZJGtDad:aCols[ nSZJ, nPZJITEM  ],;              // 02 
						oSZJGtDad:aCols[ nSZJ, nPZJCHVNF ],;              // 03 
						oSZJGtDad:aCols[ nSZJ, nPZJQTDNF ],;              // 04 Qtd Total Cab
						nZSGTotQtd						  ,;              // 05 Qtd Total Item
						oSZJGtDad:aCols[ nSZJ, nPZJQTDNF ]-nZSGTotQtd } ) // 06 Sobra
			Next nSZJ

			lRet := .F.
			If Empty( oZSGGtDad:aCols[ oZSGGtDad:nAt, nPZSGCHVNF ] ) /* oZSGGtDad:aCols[ oZSGGtDad:nAt, Len(oZSGGtDad:aCols[1])-1 ] == 0 */
				For nI := 1 to Len(aMatQtd)
					If aMatQtd[nI, 06] > 0
						If &(ReadVar()) <= aMatQtd[nI, 06]
							aMatQtd[nI, 05] += &(ReadVar())
							aMatQtd[nI, 06] -= &(ReadVar())
							fZSGPreenche( aMatQtd[nI, 01], aMatQtd[nI, 02], aMatQtd[nI, 03] )		
							lRet := .T.
						Else
							Alert("Quantidade definida para baixar ultrapassou a quantidade da nota fiscal." +CRLF+;
								"Qtd NF.....: " + cValToChar( aMatQtd[nI, 04] ) +CRLF+;
								"Qtd Lote...: " + cValToChar( aMatQtd[nI, 05] + &(ReadVar()) ) +CRLF+;
								"Ultrapassou: " + cValToChar( ABS(aMatQtd[nI, 04] - ( aMatQtd[nI, 05] + &(ReadVar()) ) ) ) )
						EndIf
						Exit
					EndIf
				Next nI
			Else // Edição
				nPos := aScan( aMatQtd, { |x| x[3] == oZSGGtDad:aCols[ oZSGGtDad:nAt, nPZSGCHVNF  ] })
				if nPos > 0 .and. aMatQtd[nPos, 06] > 0 .and. &(ReadVar()) <= aMatQtd[nPos, 06]
					aMatQtd[nPos, 05] += &(ReadVar())
					aMatQtd[nPos, 06] -= &(ReadVar())
					fZSGPreenche( aMatQtd[nPos, 01], aMatQtd[nPos, 02], aMatQtd[nPos, 03] )
					lRet := .T.
				Else
					If nPos > 0
					Alert("Quantidade definida para baixar ultrapassou a quantidade da nota fiscal." +CRLF+;
							"Qtd NF.....: " + cValToChar( aMatQtd[nPos, 04] ) +CRLF+;
							"Qtd Lote...: " + cValToChar( nZSGTotQtd ) +CRLF+;
  							"Ultrapassou: " + cValToChar( ABS(aMatQtd[nPos, 04] - nZSGTotQtd ) ) )
					EndIf
				EndIf
			EndIf
		EndIf

	EndIf
	oZSGGtDad:Refresh()
	RestArea(aAreaSB1)
	// Alert("Validação de Campos.")
Return lRet


Static Function fZSGSomaQtd( _cChave )
Local nZSGAtu := 0
Local nZSGTotQtd := 0

	For nZSGAtu := 1 to nZSGTot
		// If _cChave == oZSGGtDad:aCols[ enZSGAtu, nPZSGCHVNF ] /* .OR.;
		//	Empty( oZSGGtDad:aCols[ oZSGGtDad:nAt, nPZSGCHVNF ] ) */
		//
		//	nZSGTotQtd += iIf( nZSGAtu==oZSGGtDad:nAt,;
		//				&(ReadVar()),;
		//				oZSGGtDad:aCols[ nZSGAtu, nPZSGQUANT ] )
		//EndIf
		If _cChave == oZSGGtDad:aCols[ nZSGAtu, nPZSGCHVNF ] .AND. ;
			nZSGAtu <> oZSGGtDad:nAt

			nZSGTotQtd += oZSGGtDad:aCols[ nZSGAtu, nPZSGQUANT ]
		EndIf
	Next nZSGAtu
Return nZSGTotQtd

// Static Function fZSGPreenche( )
// 	// If Empty(oZSGGtDad:aCols[ oZSGGtDad:nAt, nPZSGCHVNF  ])
// 		oZSGGtDad:aCols[ oZSGGtDad:nAt, nPZSGCODIGO ] := oSZJGtDad:aCols[ nSZJAtu, nPZJCODIGO]
// 		oZSGGtDad:aCols[ oZSGGtDad:nAt, nPZSGSZJITE ] := oSZJGtDad:aCols[ nSZJAtu, nPZJITEM] 
// 		oZSGGtDad:aCols[ oZSGGtDad:nAt, nPZSGCHVNF  ] := oSZJGtDad:aCols[ nSZJAtu, nPZJCHVNF ]
// 	// EndIf
// Return nil

Static Function fZSGPreenche( cCodigo, cItem, cChave )
	// If Empty(oZSGGtDad:aCols[ oZSGGtDad:nAt, nPZSGCHVNF  ])
		oZSGGtDad:aCols[ oZSGGtDad:nAt, nPZSGCODIGO ] := cCodigo
		oZSGGtDad:aCols[ oZSGGtDad:nAt, nPZSGSZJITE ] := cItem
		oZSGGtDad:aCols[ oZSGGtDad:nAt, nPZSGCHVNF  ] := cChave
	// EndIf
Return nil

/*=======================================================================================================================
	MB : 22.11.2021
		-> Validação ao clicar no botao SALVAR;a
			1. Validacao total, comparando as 2 tabelas: SZJ x ZSG
=======================================================================================================================*/
Static Function fVldOk()
//Local lRet := U_fZSGLinOk( )
Local lRet     := .T.
Local nI       := 0
Local nTotSZJ  := 0
Local nTotZSG  := 0
Local _cErro   := ""
Local cPlaca   := ""
Local cCodMot  := ""
Local cMinuta  := ""
Local cCte     := ""
Local dData1   := ""
Local dData2   := ""
Local dData3   := ""
Local dData4   := ""
Local cHora1   := ""
Local cHora2   := ""
Local cHora3   := ""
Local cHora4   := ""
Local cFornece := ""
Local cMotori  := ""
Local nPesLq   := 0
Local nQtd     := 0
Local nQtEmb   := 0

	if oSZJGtDad:aCols[1][ nPZJQTEMB ] == 0 .and. oSZJGtDad:aCols[1][ nPZJTR1 ] > 0 .and. oSZJGtDad:aCols[1][ nPZJPS1 ]
		lRet := .F.
		MSGALERT( "Preencha o Campo Qt Embarque na linha 1", "Atenção!" )
	else
	
		For nI := 1 to Len(oSZJGtDad:aCols)
			nQtEmb += oSZJGtDad:aCols[ nI, nPZJQTEMB ]
		Next nI

		For nI := 1 to Len(oZSGGtDad:aCols)
			nQtd += oZSGGtDad:aCols[ nI, nPZSGQUANT ]
		Next nI

		if nQtd != nQtEmb
			MSGALERT( "Quantidade de animais na NF e Lotes Embarcados não conferem.", "Atenção!" )
		endif

		nQtd := 0 
		nQtEmb := 0
		if lRet 
			For nI := 1 to Len(oSZJGtDad:aCols)
				nTotSZJ += oSZJGtDad:aCols[ nI, nPZJQTDNF ]
				If Empty( oSZJGtDad:aCols[ nI, nPZJCHVNF ] )
					_cErro += Iif(Empty(_cErro), "", CRLF) + "Campo Chave NF no Cabeçalho da linha: " + cValToChar(nI) + " não informado;"
					Exit
				EndIf
			Next nI

			If !Empty(_cErro)
				lRet := .F.
				MsgAlert(_cErro, "Erro" )
			EndIf

			If  lRet
				For nI := 1 to Len(oZSGGtDad:aCols)
					if Len(oZSGGtDad:aCols) == 1 .and. Empty( oZSGGtDad:aCols[ 01, nPZSGQUANT ] )
						Loop
					EndIf

					If oZSGGtDad:aCols[ nI, nPZSGQUANT ] > 0 .and. Empty( oZSGGtDad:aCols[ nI, nPZSGLOTE ] )
						MsgAlert( "O Campo LOTE nao foi informado na linha: " + cValToChar(nI), "Erro")
						lRet := .F.
						Exit
					EndIf

					If Empty( oZSGGtDad:aCols[ nI, nPZSGLOTE  ] )
						MsgAlert( Iif(Empty(_cErro), "", CRLF) + "Campo Lote na linha: " + cValToChar(nI) + " não informado;", "Erro")
						lRet := .F.
						Exit
					EndIf

					If !oZSGGtDad:aCols[ nI, Len(oZSGGtDad:aCols[nI]) ]
						nTotZSG += oZSGGtDad:aCols[ nI, nPZSGQUANT ]
					EndIf
				Next nI
			EndIf

			If lRet
				If !(lRet := (!nTotSZJ < nTotZSG))
					MsgAlert( "A quantidade selecionada dos lotes nao pode ser maior que a quantidade definida nas Notas fiscais.", "Erro")
				EndIf
			EndIf

				/*
					05/09/2022 Toshio
					Alteração para percorrer a SZJ E PREENCHER CAMPOS 
						PLACA - ZJ_PLACA, MOTORISTA - ZJ_CODMOT, CTE ZJ_CTE, MINUTA ZJ_MINUTA, GTA ZJ_GTA
				//atualizar apenas quando há segunda pesagem  (peso liquido)
				*/ 

			cFornece := oSZJGtDad:aCols[ 1, nPZJFORNEC ]
			For nI := 1 to Len(oSZJGtDad:aCols)
				If !(cFornece == oSZJGtDad:aCols[ nI, nPZJFORNEC ])
					If !MsgYesNo("A Pesagem contem nota de CLIENTES DIFERENTES, deseja continuar salvando a pesagem  ?", "Validar Notas / Fornecedor")
						lRet := .f.
					EndIf
				EndIf
			Next nI

			For nI := 1 to Len(oSZJGtDad:aCols)
				If nI == 1 .and. oSZJGtDad:aCols[ nI, nPZJPESOL ] > 0
					cPlaca  := oSZJGtDad:aCols[ nI, nPZJPLACA ]
					cCodMot := oSZJGtDad:aCols[ nI, nPZJCODMOT ]
					cMotori := oSZJGtDad:aCols[ nI, nPZJMOTORI ]
					cMinuta := oSZJGtDad:aCols[ nI, nPZJMINUTA ]
					cCte    := oSZJGtDad:aCols[ nI, nPZJCTE ]
					dData1  := oSZJGtDad:aCols[ nI, nPZJDATA1 ]
					cHora1  := oSZJGtDad:aCols[ nI, nPZJHORA1 ]
					dData2  := oSZJGtDad:aCols[ nI, nPZJDATA2 ]
					cHora2  := oSZJGtDad:aCols[ nI, nPZJHORA2 ]
					dData3  := oSZJGtDad:aCols[ nI, nPZJDATA3 ]
					cHora3  := oSZJGtDad:aCols[ nI, nPZJHORA3 ]
					dData4  := oSZJGtDad:aCols[ nI, nPZJDATA4 ]
					cHora4  := oSZJGtDad:aCols[ nI, nPZJHORA4 ]
					nPesLq  := oSZJGtDad:aCols[ nI, nPZJPESOL ]
					nQtd    := oSZJGtDad:aCols[ nI, nPZJQTDNF ]
					nQtEmb  := oSZJGtDad:aCols[ nI, nPZJQTEMB ]
				ElseIf (!nI == 1) //.and. (oSZJGtDad:aCols[ nI, nPZJPESOL ] == 0)
					oSZJGtDad:aCols[ nI, nPZJPLACA ]  := cPlaca
					oSZJGtDad:aCols[ nI, nPZJCODMOT ] := cCodMot
					oSZJGtDad:aCols[ nI, nPZJMOTORI ] := cMotori
					oSZJGtDad:aCols[ nI, nPZJMINUTA ] := cMinuta
					oSZJGtDad:aCols[ nI, nPZJCTE ]    := cCte
					If !Empty(dData1) .and. !Empty(dData2) .and. !Empty(dData3) .and. !Empty(dData4)
						oSZJGtDad:aCols[ nI, nPZJDATA1 ]  := dData1
						oSZJGtDad:aCols[ nI, nPZJHORA1 ]  := cHora1
						oSZJGtDad:aCols[ nI, nPZJDATA2 ]  := dData2
						oSZJGtDad:aCols[ nI, nPZJHORA2 ]  := cHora2
						oSZJGtDad:aCols[ nI, nPZJDATA3 ]  := dData3
						oSZJGtDad:aCols[ nI, nPZJHORA3 ]  := cHora3
						oSZJGtDad:aCols[ nI, nPZJDATA4 ]  := dData4
						oSZJGtDad:aCols[ nI, nPZJHORA4 ]  := cHora4
					EndIf
					oSZJGtDad:aCols[ nI, nPZJPESOL ]  := nPesLq

					nQtd += oSZJGtDad:aCols[ nI, nPZJQTEMB ]
				EndIf
			Next nI

			// Atualiza Coluna Peso Médio Na pesagem
			For nI := 1 to Len(oSZJGtDad:aCols)

				oSZJGtDad:aCols[ nI, nPZJQTEMB]   := nQtEmb
				oSZJGtDad:aCols[ nI, nPZJPESMED]  := nPesLq / nQtEmb
			Next nI

		endif
	endif

Return lRet


/*=======================================================================================================================
	MB : 24.11.2021
		-> Validação ao clicar no botao SALVAR;a
			1. 
=======================================================================================================================*/
User Function fZSGDelOk()
Local lRet   := .F.
Local nLinha := oZSGGtDad:nAt

	if !(lRet := Empty(oZSGGtDad:aCols[ nLinha, nPZSGDATASE ]))
		MsgAlert( "Esta linha nao pode ser excluida pois o produto já foi realizado a baixa.", "Atenção")
	EndIf

Return lRet
/* 02.12.2023 */
User Function fPegaPeso(nOpc)
	Local aArea         := GetArea()
	Local nPeso 		:= 0
	Local nOpcA
	Local nPeso1            := 0
	Local nPeso2            := 0
	Local nLinha 		:= oZSGGtDad:nAt
	Local lPesagManu	:= .f.
	
	if nOpc == 3 .or. nOpc == 4

		IF aParBal == nIl     // Para Ser Inicializado Somente Qdo ainda não foi
			aParBal := AGRX003E( .f., 'OGA050001' )
		EndIF
		// SE PESAGEM SIMPLES
		IF oSZJGtDad:aCols[nLinha,NPZJTPPES] == 'S'
				
			If oSZJGtDad:aCols[nLinha,nPZJTR1] == 0 .or. oSZJGtDad:aCols[nLinha,nPZJPS1] == 0
				AGRX003A( @nPeso, .t., aParBal, /*cMask*/,@lPesagManu, nPeso1, nPeso2, nOpcA )
				if nPeso > 0
					If oSZJGtDad:aCols[nLinha,nPZJTR1] == 0
						oSZJGtDad:aCols[nLinha,nPZJTR1] := nPeso 
						oSZJGtDad:aCols[nLinha,nPZJDATA1] := Date()
						oSZJGtDad:aCols[nLinha,nPZJHORA1] := Time()
						
						oSZJGtDad:aCols[nLinha,nPZJPEMAN1] := iif(lPesagManu,"M","A")
						
					elseif oSZJGtDad:aCols[nLinha,nPZJTR1] > 0//nOpcA == 2
						oSZJGtDad:aCols[nLinha,nPZJPS1] := nPeso

						oSZJGtDad:aCols[nLinha,nPZJPESOL] := nPeso - oSZJGtDad:aCols[nLinha,nPZJTR1]
						oSZJGtDad:aCols[nLinha,nPZJDATA2] := Date()
						oSZJGtDad:aCols[nLinha,nPZJHORA2] := Time()

						oSZJGtDad:aCols[nLinha,nPZJPEMAN2] := iif(lPesagManu,"M","A")
					EndIf
				endif
			Else 
				If oSZJGtDad:aCols[nLinha,nPZJTR1] > 0 .and. oSZJGtDad:aCols[nLinha,nPZJPS1] > 0 // se os 2 pesos tiverem preenchidos
					If(MsgYesNo('Peso Tara e Peso de saída Preenchidos, deseja ALTERAR o PESO DE SAÍDA ???'))
						AGRX003A( @nPeso, .t., aParBal, /*cMask*/,@lPesagManu, nPeso1, nPeso2, nOpcA )
						if nPeso > 0
							oSZJGtDad:aCols[nLinha,nPZJPS1] := nPeso
							oSZJGtDad:aCols[nLinha,nPZJPESOL] := nPeso - oSZJGtDad:aCols[nLinha,nPZJTR1]
							oSZJGtDad:aCols[nLinha,nPZJDATA2] := Date()
							oSZJGtDad:aCols[nLinha,nPZJHORA2] := Time()
							oSZJGtDad:aCols[nLinha,nPZJPEMAN2] := iif(lPesagManu,"M","A")
						EndIf
					Else
						If(MsgYesNo('Peso Tara e Peso de saída Preenchidos, deseja ALTERAR o PESO TARA ???'))
							AGRX003A( @nPeso, .t., aParBal, /*cMask*/,@lPesagManu, nPeso1, nPeso2, nOpcA )
							if nPeso > 0
								oSZJGtDad:aCols[nLinha,nPZJTR1] := nPeso
								oSZJGtDad:aCols[nLinha,nPZJDATA1] := Date()
								oSZJGtDad:aCols[nLinha,nPZJHORA1] := Time()
								oSZJGtDad:aCols[nLinha,nPZJPEMAN1] := iif(lPesagManu,"M","A")
							EndIf
						EndIf	
					EndIf
				endif
			EndIf
		elseif oSZJGtDad:aCols[nLinha,NPZJTPPES] == 'D'
			If oSZJGtDad:aCols[nLinha,nPZJTR1] == 0 .or. oSZJGtDad:aCols[nLinha,nPZJPS1] == 0 .or.;
				oSZJGtDad:aCols[nLinha,nPZJTR2] == 0 .or. oSZJGtDad:aCols[nLinha,nPZJPS2] == 0 
				
				//AGRX003A( @nPeso, .t., aParBal, /*cMask*/,@lPesagManu, nPeso1, nPeso2, nOpcA )
				nPeso := 10
				if nPeso > 0
					If oSZJGtDad:aCols[nLinha,nPZJTR1] == 0 // PRIMEIRA TARA
						oSZJGtDad:aCols[nLinha,nPZJTR1] := nPeso 
						oSZJGtDad:aCols[nLinha,nPZJDATA1] := Date()
						oSZJGtDad:aCols[nLinha,nPZJHORA1] := Time()
						
						oSZJGtDad:aCols[nLinha,nPZJPEMAN1] := iif(lPesagManu,"M","A")
						
					elseif oSZJGtDad:aCols[nLinha,nPZJTR1] > 0 .and. oSZJGtDad:aCols[nLinha,nPZJTR2] == 0 // SEGUNDA TARA
						oSZJGtDad:aCols[nLinha,nPZJTR2] := nPeso

						oSZJGtDad:aCols[nLinha,nPZJDATA3] := Date()
						oSZJGtDad:aCols[nLinha,nPZJHORA3] := Time()

						oSZJGtDad:aCols[nLinha,nPZJPEMAN3] := iif(lPesagManu,"M","A")
					elseif oSZJGtDad:aCols[nLinha,nPZJTR2] > 0 .AND. oSZJGtDad:aCols[nLinha,nPZJPS1] == 0// PRIMEIRO PESO FINAL
						oSZJGtDad:aCols[nLinha,nPZJPS1] := nPeso

						oSZJGtDad:aCols[nLinha,nPZJDATA2] := Date()
						oSZJGtDad:aCols[nLinha,nPZJHORA2] := Time()

						oSZJGtDad:aCols[nLinha,nPZJPEMAN2] := iif(lPesagManu,"M","A")
					elseif oSZJGtDad:aCols[nLinha,nPZJPS1] > 0 // PRIMEIRO PESO FINAL
						oSZJGtDad:aCols[nLinha,nPZJPS2] := nPeso

						oSZJGtDad:aCols[nLinha,nPZJPESOL] := ABS((oSZJGtDad:aCols[nLinha,nPZJTR1] + oSZJGtDad:aCols[nLinha,nPZJTR2]) -;
															 (nPeso + oSZJGtDad:aCols[nLinha,nPZJPS1]))

						oSZJGtDad:aCols[nLinha,nPZJDATA4] := Date()
						oSZJGtDad:aCols[nLinha,nPZJHORA4] := Time()

						oSZJGtDad:aCols[nLinha,nPZJPEMAN4] := iif(lPesagManu,"M","A")
					EndIf
				endif
			Else
				If oSZJGtDad:aCols[nLinha,nPZJTR1] > 0 .and. oSZJGtDad:aCols[nLinha,nPZJPS1] > 0 .and. ;
					oSZJGtDad:aCols[nLinha,nPZJTR2] > 0 .and. oSZJGtDad:aCols[nLinha,nPZJPS2] > 0 

					If ParamBox({{2,"Qual Pesagem?",1,{"1=1º Pesagem","2=2º Pesagem","3=3º Pesagem","4=4º Pesagem"},122,".T.",.F.}}, "Informe a Pesagem")
						
						if Type( "MV_PAR01" ) == "N"
							MV_PAR01 := LTrim(Str(MV_PAR01))
						endif

						if MV_PAR01 == "1"
							//AGRX003A( @nPeso, .t., aParBal, /*cMask*/,@lPesagManu, nPeso1, nPeso2, nOpcA )
							nPeso := 10
							if nPeso > 0
								oSZJGtDad:aCols[nLinha,nPZJTR1] 	:= nPeso
								oSZJGtDad:aCols[nLinha,nPZJPESOL]	:= abs((nPeso + oSZJGtDad:aCols[nLinha,nPZJTR2]) - ;
																		(oSZJGtDad:aCols[nLinha,nPZJPS1] + oSZJGtDad:aCols[nLinha,nPZJPS2]))
								oSZJGtDad:aCols[nLinha,nPZJDATA1] 	:= Date()
								oSZJGtDad:aCols[nLinha,nPZJHORA1] 	:= Time()
								oSZJGtDad:aCols[nLinha,nPZJPEMAN1] 	:= iif(lPesagManu,"M","A")
							EndIf
						elseif MV_PAR01 == "2"
							//AGRX003A( @nPeso, .t., aParBal, /*cMask*/,@lPesagManu, nPeso1, nPeso2, nOpcA )
							nPeso := 20
							if nPeso > 0
								oSZJGtDad:aCols[nLinha,nPZJTR2] 	:= nPeso
								oSZJGtDad:aCols[nLinha,nPZJPESOL]	:= abs((nPeso + oSZJGtDad:aCols[nLinha,nPZJTR1]) - ;
																	   (oSZJGtDad:aCols[nLinha,nPZJPS1] + oSZJGtDad:aCols[nLinha,nPZJPS2]))
								oSZJGtDad:aCols[nLinha,nPZJDATA3] 	:= Date()
								oSZJGtDad:aCols[nLinha,nPZJHORA3] 	:= Time()
								oSZJGtDad:aCols[nLinha,nPZJPEMAN3] 	:= iif(lPesagManu,"M","A")
							EndIf
						elseif MV_PAR01 == "3"
							//AGRX003A( @nPeso, .t., aParBal, /*cMask*/,@lPesagManu, nPeso1, nPeso2, nOpcA )
							nPeso := 30
							if nPeso > 0
								oSZJGtDad:aCols[nLinha,nPZJPS1] 	:= nPeso
								oSZJGtDad:aCols[nLinha,nPZJPESOL]	:= abs((oSZJGtDad:aCols[nLinha,nPZJTR2] + oSZJGtDad:aCols[nLinha,nPZJTR1]) - ;
																	   (nPeso + oSZJGtDad:aCols[nLinha,nPZJPS2]))
								oSZJGtDad:aCols[nLinha,nPZJDATA2] 	:= Date()
								oSZJGtDad:aCols[nLinha,nPZJHORA2] 	:= Time()
								oSZJGtDad:aCols[nLinha,nPZJPEMAN2] 	:= iif(lPesagManu,"M","A")
							EndIf
						elseif MV_PAR01 == "4"
							//AGRX003A( @nPeso, .t., aParBal, /*cMask*/,@lPesagManu, nPeso1, nPeso2, nOpcA )
							nPeso := 40
							if nPeso > 0
								oSZJGtDad:aCols[nLinha,nPZJPS1] 	:= nPeso
								oSZJGtDad:aCols[nLinha,nPZJPESOL]	:= abs((oSZJGtDad:aCols[nLinha,nPZJTR2] + oSZJGtDad:aCols[nLinha,nPZJTR1]) - ;
																	   (nPeso + oSZJGtDad:aCols[nLinha,nPZJPS1]))
								oSZJGtDad:aCols[nLinha,nPZJDATA4] 	:= Date()
								oSZJGtDad:aCols[nLinha,nPZJHORA4] 	:= Time()
								oSZJGtDad:aCols[nLinha,nPZJPEMAN4] 	:= iif(lPesagManu,"M","A")
							EndIf
						endif 
					EndIf
				endif
			EndIf
		endif
	endif

	RestArea(aArea)
Return 

/*=======================================================================================================================
	MB : 22.11.2021
		-> Realizar a Baixa dos Animais;
=======================================================================================================================*/
User Function fBxaAnimais()
	Local aArea         := GetArea()
	Local cMsg          := ""
	Local nI            := 0
	Local cQry          := ""
	Local cCC           := ""
	Local RECNOSD3      := 0
	Local _aAreaSM0     := {}
	Local cAlias 		:= GetNextAlias()
	Local aItem			:= {}
	Local aItens		:= {}
	Local aCab 			:= {}

	PRIVATE lMsErroAuto := .F.
	Private INCLUI      := .T.

	dbSelectArea("SM0")
	_aAreaSM0 := SM0->(GetArea())
	_cEmpBkp  := SM0->M0_CODIGO //Guardo a empresa atual
	_cFilBkp  := SM0->M0_CODFIL //Guardo a filial atual
		
	// BeginTran()
	Begin Transaction
		TryException

			For nI := 1 to Len(oZSGGtDad:aCols)
				If oZSGGtDad:aCols[ nI, Len(oZSGGtDad:aCols[nI]) ]
					Loop
				EndIf
				
				If oZSGGtDad:aCols[ nI, nPZSGRCNOD3 ] ==  0  // If !Empty( oZSGGtDad:aCols[ nLinha, nPZSGRCNOD3 ] )
					If oZSGGtDad:aCols[ nI, nPZSGLOCAL ]== "06" //GetMV( 'MB_LIVIO4B',, '02.30.01')
						cCC :=  GetMV( 'MB_LIVIO4B',, '02.30.01')
						exit
					Else
						cCC :=  '02.40.01'
						exit
					EndIf
				EndIf
			Next nI
			
			cDocumento := SubStr(oZSGGtDad:aCols[ nI, nPZSGCHVNF ],26,9)

			cQry := " select * " + CRLF 
			cQry += " from "+RetSqlName("SD3")+" SD3" + CRLF 
			cQry += " WHERE SD3.D3_FILIAL = '"+FwxFilial("SD3")+"' " + CRLF 
			cQry += " AND SD3.D3_DOC = '"+cDocumento+"'" + CRLF 
			cQry += " AND SD3.D3_ESTORNO = ' ' " + CRLF 
			cQry += " AND SD3.D_E_L_E_T_ = ' '" + CRLF 

			MpSysOpenQuery(cQry,cAlias)

			if !(cAlias)->(EOF()) 
				FWAlertError("O Documento "+cDocumento+" já existe na tabela SD3 e por isso a baixa do estoque não utilizara o mesmo numero da NF para o campo DOC.", "Numero de Documento")
				cDocumento := NextNumero("SD3",2,"D3_DOC",.T.)
			EndIf

			(cAlias)->(DBCLOSEAREA(  ))

			aCab := {{"D3_DOC" 		, cDocumento						, NIL},;
					{"D3_FILIAL"	, xFilial("ZSG")			 		, NIL},;
					{"D3_TM" 		, GetMV("MB_TMBAIXA",, "905") 		, NIL},;
					{"D3_CC" 		, cCC								, NIL},;
					{"D3_EMISSAO" 	, dDataBase							, NIL}}
					
			For nI := 1 to Len(oZSGGtDad:aCols)
				If oZSGGtDad:aCols[ nI, Len(oZSGGtDad:aCols[nI]) ]
					Loop
				EndIf

				If oZSGGtDad:aCols[ nI, nPZSGRCNOD3 ] >  0  // If !Empty( oZSGGtDad:aCols[ nLinha, nPZSGRCNOD3 ] )
					// MsgInfo("A Baixa na linha: " + cValToChar(nI) + " não sera realizada, pois a mesma ja se encontrada baixada.", "Atenção")
					cMsg += iIf(Empty(cMsg), "", CRLF) + "A Baixa na linha: " + cValToChar(nI) + " não sera realizada, pois a mesma ja se encontrada baixada."
				Else
					If oZSGGtDad:aCols[ nI, nPZSGQUANT ] >  0

						DbSelectArea("SF5")
						If SF5->(DbSeek( xFilial("SF5") + GetMV("MB_TMBAIXA",, "905") ))
							ConOut("SF5")
						EndIf
						
						cQry := " select * " + CRLF 
						cQry += " from "+RetSqlName("SB8")+" SB8" + CRLF 
						cQry += " WHERE SB8.B8_FILIAL = '"+FwxFilial("SB8")+"' " + CRLF 
						cQry += " AND SB8.B8_PRODUTO = '"+AllTrim(oZSGGtDad:aCols[ nI, nPZSGPRODUT ])+"'" + CRLF 
						cQry += " AND SB8.B8_LOTECTL = '"+oZSGGtDad:aCols[ nI, nPZSGLOTE ]+"' " + CRLF 
						cQry += " AND SB8.B8_LOCAL = '"+oZSGGtDad:aCols[ nI, nPZSGLOCAL ]+"' " + CRLF 
						cQry += " AND SB8.D_E_L_E_T_ = ' '" + CRLF

						cAlias:=GetNextAlias()
						MpSysOpenQuery(cQry, cAlias)

						if !(cAlias)->(EOF()) .and. (cAlias)->B8_SALDO >= oZSGGtDad:aCols[ nI, nPZSGQUANT ] .and. oZSGGtDad:aCols[ nI, nPZSGQUANT ] > 0

							aItem := {{"D3_COD" 		, AllTrim(oZSGGtDad:aCols[ nI, nPZSGPRODUT ]) 	,NIL},;
									{"D3_UM" 		, POSICIONE("SB1",1,xFilial("SB1") +;
													AllTrim(oZSGGtDad:aCols[ nI, nPZSGPRODUT ]),;
													"B1_UM")										,NIL},; 
									{"D3_QUANT" 	, oZSGGtDad:aCols[ nI, nPZSGQUANT ] 			,NIL},;
									{"D3_LOCAL" 	, oZSGGtDad:aCols[ nI, nPZSGLOCAL ] 			,NIL},;
									{"D3_LOTECTL" 	, oZSGGtDad:aCols[ nI, nPZSGLOTE ]				,NIL},;
									{"D3_FORNECE" 	, M->ZJ_FORNEC									,NIL},;
									{"D3_NOMEFOR" 	, AllTrim(Posicione( 'SA2' , 1, xFilial( 'SA2' )+M->ZJ_FORNEC , 'A2_NOME' ) ),NIL}}
							
							aAdd(aItens,aClone(aItem))
						Else
							FWAlertError("O Produto: '" +AllTrim(oZSGGtDad:aCols[ nI, nPZSGPRODUT ])+ "', Lote  '"+oZSGGtDad:aCols[ nI, nPZSGLOTE ]+"'  não possui saldo suficiente parar realizar a baixa do estoque", "Saldo Insuficiente")
						EndIf
						(cAlias)->(DBCLOSEAREA(  ))
					EndIf
				EndIf
			Next nI

			If !Empty(cMsg)
				MsgInfo(cMsg)
			EndIf
			
			if Len(aItens) > 0
				MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,aItens,3)
				
				if lMsErroAuto
					Mostraerro() 
				else 
					RecnoSD3 := SD3->(Recno())
					nLinhas := ''
					For nI := 1 To Len(oZSGGtDad:aCols)
						If oZSGGtDad:aCols[ nI, Len(oZSGGtDad:aCols[nI]) ]
							Loop
						EndIf

						If oZSGGtDad:aCols[ nI, nPZSGRCNOD3 ] ==  0  .and. oZSGGtDad:aCols[ nI, nPZSGQUANT ] >  0
							nLinhas += '| ' + AllTrim(cValToChar(nI)) + " |"
							
							oZSGGtDad:aCols[ nI, nPZSGDATASE ] := dDataBase
							oZSGGtDad:aCols[ nI, nPZSGUSUARI ] := cUserName
							oZSGGtDad:aCols[ nI, nPZSGRCNOD3 ] := RecnoSD3
						endif 
					Next nI 
					
					MsgInfo('Realizada Baixa de estoque DOC: '+Alltrim(SD3->D3_DOC) + CRLF + 'linhas: ' + nLinhas)
				endif
			endif

		CatchException Using oException
			MsgAlert(oException:ErrorStack)
			DisarmTransaction()
		EndException
	End Transaction

RestArea(aArea)
Return nil
/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 26.11.2021                                                           |
 | Cliente  : Tucano                                                               |
 | Desc		:                                                    			       |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '---------------------------------------------------------------------------------*/
User Function EstornoBaixa()
	Local aArea     := FwGetArea()
    Local aAreaSD3  
	Local nLinha    := oZSGGtDad:nAt
	Local nRecnoSD3 := oZSGGtDad:aCols[ nLinha, nPZSGRCNOD3 ]
	Local nI 
	Local aCab		:= {}
	Local aItem		:= {}
	Local aItens	:= {}
	Local cChave	:= ""

    Private lMsErroAuto := .F.

	Private L185
	Private L240AUTO
	Private AACHO
	Private CCUSMED

	If Empty( nRecnoSD3 )
		MsgAlert("Não sera possivel estornar a linha: " + cValToChar(nLinha) + " pois a mesma ainda nao teve a baixa realizada.",;
				"Atenção")
		RestArea(aArea)
		Return nil
	EndIf

	Begin Transaction
		
		DbSelectArea("SD3")
		SD3->(dbGoTo(nRecnoSD3))

		if SD3->D3_ESTORNO <> 'S'		
			aAreaSD3 := SD3->(FWGetArea())

			cChave   := SD3->D3_FILIAL + SD3->D3_DOC

			aCab := {;
				{"D3_DOC", SD3->D3_DOC, Nil};
			}

			While !SD3->(EoF()) .And. SD3->D3_FILIAL + SD3->D3_DOC == cChave
				IncProc("Adicionando produto " + Alltrim(SD3->D3_COD) + "...")
	
				aItem := {}
				aAdd(aItem, {"D3_COD",     SD3->D3_COD,   Nil})
				aAdd(aItem, {"D3_UM",      SD3->D3_UM,    Nil})
				aAdd(aItem, {"D3_QUANT",   SD3->D3_QUANT, Nil})
				aAdd(aItem, {"D3_LOCAL",   SD3->D3_LOCAL, Nil})
				aAdd(aItem, {"D3_ESTORNO", "S",           Nil})
				aAdd(aItens, aClone(aItem))
	
				SD3->(DbSkip())
			EndDo

			FWRestArea(aAreaSD3)

			MsExecAuto({|x, y, z| MATA241(x, y, z)}, aCab, aItens, 6)
			
			If lMsErroAuto
				MostraErro()
			Else
				For nI := 1 to Len(oZSGGtDad:aCols)
					If nRecnoSD3 == oZSGGtDad:aCols[ nI, nPZSGRCNOD3 ]
						oZSGGtDad:aCols[ nI, nPZSGDATASE ] := sToD("")
						oZSGGtDad:aCols[ nI, nPZSGUSUARI ] := ""
						oZSGGtDad:aCols[ nI, nPZSGRCNOD3 ] := 0
					EndIf
				next nI

				FWAlertSuccess("Documento foi estornado com sucesso!", "Atenção")
			EndIf
		endif 

	End Transaction
	// EndIf
	FwRestArea(aArea)
Return nil
/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 20.12.2021                                                           |
 | Cliente  : Tucano                                                               |
 | Desc		: Impressão de Ticket de Pesagem;                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '---------------------------------------------------------------------------------*/
User Function mbPesoPrint()

// Local cFilePrinter := "Ticket-" + AllTrim(cPlacaTGet) + "-" + DtoS(dDataBase) + '-' + StrTran(Time(),":","") + ".rel"
Local cFilePrinter := ""
Private oPrinter   := nil

If TYPE("INCLUI") == "U"
	Private INCLUI := .F.
endif

	cFilePrinter := "Ticket-" +;
					  AllTrim(iIf(INCLUI, M->ZJ_PLACA, SZJ->ZJ_PLACA)) + "-" +;
					  DtoS(dDataBase) + "-" +;
					  AllTrim(iIf(INCLUI, M->ZJ_CODIGO, SZJ->ZJ_CODIGO)) + ".rel"
					  // iIf(GetServerIP()=="192.168.0.250", " " + StrTran(Time(),":",""), "") + 

    oPrinter := FWMSPrinter():New( cFilePrinter, IMP_PDF/*nDevice*/ , .F./*lAdjustToLegacy*/, /*cPathInServer*/, .T./*lDisabeSetup*/,;
        /*lTReport*/, /*@oPrintSetup*/, /*cPrinter*/, /*lServer*/, .F./*lPDFAsPNG*/, /*lRaw*/,;
        .T. /*lViewPDF*/, /*nQtdCopy*/ )
    oPrinter:StartPage()
    // oPrinter:SetResolution(72)
    oPrinter:SetPortrait()
    oPrinter:SetPaperSize(DMPAPER_A4) // DMPAPER_A4 = A4 210 x 297 mm
    oPrinter:SetMargin(60,60,60,60) // nEsquerda, nSuperior, nDireita, nInferior
    oPrinter:cPathPDF := "C:\TOTVS_RELATORIOS\" // Caso seja utilizada impressão em IMP_PDF

    RptStatus({|lEnd| ImpTicket(@lEnd)}, "Imprimindo relatorio...") //"A imprimir relatório..."

Return nil


/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  ImpTicket 	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  29.09.2020                   	          	            	              |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
Static Function ImpTicket( lEnd )
Local _aAreaSM0 := {}
Local lRestEmp  := .F.


	ZSG->(DbSetorder(1))
	If ZSG->(DbSeek( xFilial("ZSG")+SZJ->ZJ_CODIGO ))
		dbSelectArea("SM0")
		If lRestEmp := (SM0->M0_CODIGO <> Left( ZSG->ZSG_EMPFIL, 2))
			_aAreaSM0 := SM0->(GetArea())
			// _cEmpBkp  := SM0->M0_CODIGO //Guardo a empresa atual
			// _cFilBkp  := SM0->M0_CODFIL //Guardo a filial atual
			__cEmp := Left(  ZSG->ZSG_EMPFIL , 02)
			__cFil := Right( ZSG->ZSG_EMPFIL , 02)
			SM0->(dbSetOrder(1))
			SM0->(dbSeek( __cEmp + __cFil, .T.)) //Posiciona Empresa
		EndIf
	EndIf

		fImpTicket( lEnd )

	 If lRestEmp
	 		SM0->(dbSetOrder(1))
	 		SM0->(RestArea(_aAreaSM0)) //Restaura Tabela
	 		// cFilAnt := SM0->M0_CODFIL //Restaura variaveis de ambiente
	 		// cEmpAnt := SM0->M0_CODIGO
	 EndIf

Return

Static Function fImpTicket( lEnd )
    // Local nSizePage    := 0
    // Local _cBaia           := ""
	Local _cTEMP := ""
    Private nRow           := 30, nColLabel:=30, nColInfo :=110
    Private cTxtAux        := ""
    Private cLogo          := "\system\lgrl" + AllTrim(cEmpAnt) + ".bmp"
    // Private nBckTamLin := nTamLin
    Private cReplc         := 65
    Private nTotLinOBS     := 4
	Private  _nTaraCam     := 0
	Private  _nPesoCam     := 0
	Private _nQuantLote	   := 0
	Private  _nQuantNF     := 0
    Private cUltTrato      := ""
	Private _cNotasFiscais := ""
	Private _cLote 		   := ""

    // _cBaia := iIf(INCLUI, M->ZJ_BAIA, SZJ->ZJ_BAIA)
    // If ( iIf(INCLUI, M->ZJ_FORNEC, SZJ->ZJ_FORNEC) == "C" ) .AND.;
    //     (iIf(INCLUI, M->ZJ_CODFOR, SZJ->ZJ_CODFOR) == GetMV("MB_PSGCFOR",,"000001")) .AND.;
    //     !Empty(_cBaia)
    //     cUltTrato := fQryUltTrato( _cBaia )
    // EndIf

    nTotLinha := (14/* linhas de textos */+3 /* linhas graficas de separacao */+nTotLinOBS/*linhas do campo de observacao*/)+2
    nTamLin   := /* 20 */ /* 19 */ 18.5

    // nSizePage := oPrinter:nPageWidth / oPrinter:nFactorHor //Largura da página em cm dividido pelo fator horizontal, retorna tamanho da página em pixels

    oPrinter:Box( nRow*0.6, nBoxCol:=nColLabel*0.6, nBoxBottom:=(nTamLin*nTotLinha)*0.96, nBoxRight:=int(oPrinter:nPageWidth/4.15), cBoxPixel:="-4" )// ( 130, 10, 600, 900, "-4")
    _cTEMP:=GetNextAlias()
	If LoadPesagens( @_cTEMP, iIf(INCLUI, M->ZJ_FILIAL, SZJ->ZJ_FILIAL), iIf(INCLUI, M->ZJ_CODIGO, SZJ->ZJ_CODIGO) )
		_cNotasFiscais := AllTrim((_cTEMP)->ZJ_DOC)
		_cLote         := AllTrim((_cTEMP)->ZSG_LOTE)
		_nQuantNF      := (_cTEMP)->ZJ_QTDNF
		_nQuantLote    := (_cTEMP)->ZSG_QUANT
		
		if (_cTEMP)->ZJ_TPPES == 'S' 
			_nTaraCam      := (_cTEMP)->ZJ_TARACAM
			_nPesoCam      := (_cTEMP)->ZJ_PESOCAM
		elseif (_cTEMP)->ZJ_TPPES == 'D'
			_nTaraCam      := (_cTEMP)->ZJ_TARACAM + (_cTEMP)->ZJ_TARACA1
			_nPesoCam      := (_cTEMP)->ZJ_PESOCAM + (_cTEMP)->ZJ_PESCAM2
		endif
	EndIf
	fQuadro(1)

    // nRow+=nTamLin
    cTxtAux := Replicate("-", cReplc) + "recorte-aqui" + Replicate("-", cReplc)
    // oPrinter:Say ( nRow+=nTamLin/* *0.8 */, nColLabel    ,  cTxtAux /*cText>*/, oFontRecor/*oFont*/, /*nWidth*/, RGB(255,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow:=nBoxBottom+(nTamLin/2)+(nTamLin/5), nColLabel    ,  cTxtAux /*cText>*/, oFontRecor/*oFont*/, /*nWidth*/, RGB(255,0,0)/*nClrText*/, /*nAngle*/ )

    oPrinter:Box( nRow+=(nTamLin/2), nBoxCol, nBoxBottom*2, nBoxRight/*nRight*/, "-4"/*cPixel*/ )// ( 130, 10, 600, 900, "-4")
    nRow+=(nTamLin/2)+(nTamLin/5)
    fQuadro(2)

    oPrinter:EndPage()
    oPrinter:Preview()
    FreeObj(oPrinter)
    oPrinter := Nil

    /// nTamLin := nBckTamLin
	If SELECT("QRYTMP") > 0 
		QRYTMP->(DbCloseArea())
	EndIf
Return nil

// ##########################################################################

Static Function fQuadro( nQuadro )
    Local cAux      := ""
	Local cProduto  := ""
    Local nCol2     := 185
    Local nCol3     := 325
	

    Default nQuadro := 0

    oPrinter:Say ( nRow         , nColLabel, PADC(AllTrim(SM0->M0_NOMECOM), cReplc*1.1 )/*cText>*/, oFTitLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Line( nRow+=nTamLin-10/*nTop*/, nBoxCol/*nLeft*/, nRow/*nBottom*/, nBoxRight/*nRight*/, /*nColor*/, cBoxPixel/*cPixel*/ )

    oPrinter:Say ( nRow+=nTamLin, nColLabel, "CPF............:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo , SM0->M0_CGC/*cText>*/,oFInfo /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

    oPrinter:Say ( nRow         , nColLabel+nCol3, "Inscr. Estadual:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo +nCol3, SM0->M0_INSC/*cText>*/,oFInfo /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

    oPrinter:Say ( nRow+=nTamLin, nColLabel, "Fone...........:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo , SM0->M0_TEL/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

    oPrinter:Say ( nRow         , nColLabel+nCol3, "E-Mail.........:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo +nCol3, "leonardo@livioeoutro.com.br"/*cText>*/,oFInfo /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

    cTxtAux := AllTrim( SM0->M0_ENDENT )+" - "+AllTrim(SM0->M0_BAIRENT)+" - CEP: "+AllTrim(SM0->M0_CEPENT)
    oPrinter:Say ( nRow+=nTamLin, nColLabel, "Endereço.......:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo , cTxtAux/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

    // ----------------------------------------------------------------------------------------------------------------------------
    // Linha
    oPrinter:Line( nRow+=nTamLin-5/*nTop*/, nBoxCol/*nLeft*/, nRow/*nBottom*/, nBoxRight/*nRight*/, /*nColor*/, cBoxPixel/*cPixel*/ )
    oPrinter:Say ( nRow+=nTamLin, nColLabel      , "Ticket.........:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo , dToS(iIf(INCLUI, M->ZJ_EMISNF, SZJ->ZJ_EMISNF))+'-'+iIf(INCLUI, M->ZJ_CODIGO, SZJ->ZJ_CODIGO);
        /*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

    oPrinter:Say ( nRow         , nColLabel+nCol3, "Impressão......:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo+nCol3, DtoC(MsDate())+" às "+SubS(Time(),1,5) /*cText>*/,oFInfo /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Line( nRow+=nTamLin-5/*nTop*/, nBoxCol/*nLeft*/, nRow/*nBottom*/, nBoxRight/*nRight*/, /*nColor*/, cBoxPixel/*cPixel*/ )
    // Linha
    // ----------------------------------------------------------------------------------------------------------------------------

    if nQuadro==2
        nBitMWidth:=150
        oPrinter:SayBitmap ( nRow+10/* -nColLabel *//*nRow*/, nBoxRight-nBitMWidth-5/* -nColLabel *//*nCol*/, cLogo/*cBitmap*/, int(nBitMWidth*0.9), int(nBitMWidth/2)/*nHeight*/ )
    EndIf

    oPrinter:Say ( nRow+=nTamLin, nColLabel, "Placa de cavalo:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo , iIf(INCLUI, M->ZJ_PLACA, SZJ->ZJ_PLACA)/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    
    // If ( iIf(INCLUI, M->ZJ_FORNEC, SZJ->ZJ_FORNEC) == "C" )
        cAux := "Cliente........:"
    // Else
    //     cAux := "Fornecedor.....:"
    // EndIf
	_cNomeCliente := Posicione('SA1', 1, xFilial('SA1')+iIf(INCLUI, M->ZJ_FORNEC, SZJ->ZJ_FORNEC)+iIf(INCLUI, M->ZJ_LOJAF, SZJ->ZJ_LOJAF), 'A1_NOME')
    oPrinter:Say ( nRow+=nTamLin, nColLabel, cAux/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo , _cNomeCliente/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

    oPrinter:Say ( nRow+=nTamLin, nColLabel, "CPF / CNPJ.....:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    // If !Empty(iIf(INCLUI, M->ZJ_CPFMOT, SZJ->ZJ_CPFMOT))
    // If !Empty(iIf(INCLUI, M->ZJ_CPFMOT, SZJ->ZJ_CPFMOT))
    oPrinter:Say ( nRow     , nColInfo , Transform( SA1->A1_CGC, X3Picture("A1_CGC"))/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    // EndIf

    oPrinter:Say ( nRow+=nTamLin, nColLabel, "Motorista......:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo , iIf(INCLUI, M->ZJ_MOTORIS, SZJ->ZJ_MOTORIS)/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

    oPrinter:Say ( nRow+=nTamLin, nColLabel, "Notas Fiscais..:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    
	// _cNotasFiscais := LoadPesagens( "NFs", iIf(INCLUI, M->ZJ_CODIGO, SZJ->ZJ_CODIGO), @nZJPESOCAM, @nZJTARACAM )
    iIf(INCLUI, M->ZJ_DOC+'-'+M->ZJ_SERIE, SZJ->ZJ_DOC+'-'+SZJ->ZJ_SERIE)
	oPrinter:Say ( nRow         , nColInfo , _cNotasFiscais /*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

	cProduto := Posicione("SB1", 1, xFilial("SB1")+iIf(INCLUI, M->ZJ_PRODUTO, SZJ->ZJ_PRODUTO),"B1_DESC")
    oPrinter:Say ( nRow+=nTamLin, nColLabel, "Produto........:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo , cProduto/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

    // oPrinter:Say ( nRow         , nColLabel+nCol3, "Baia........:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    // oPrinter:Say ( nRow         , nColInfo+nCol3 , iIf(INCLUI, M->ZJ_BAIA, SZJ->ZJ_BAIA)/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	cAux := AllTrim(Transform( iIf(INCLUI, M->ZJ_PESOCAM + M->ZJ_PESCAM2, SZJ->ZJ_PESOCAM + SZJ->ZJ_PESCAM2), X3Picture("ZJ_PESOCAM") ) )
    oPrinter:Say ( nRow+=nTamLin, nColLabel, "Peso Entrada...:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo ,  cAux/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

    If !Empty(StrTran(DtoC(iIf(INCLUI, M->ZJ_DATA2, SZJ->ZJ_DATA2)),"/","")+StrTran(iIf(INCLUI, M->ZJ_HORA2, SZJ->ZJ_HORA2),":",""))
        cAux := DtoC(iIf(INCLUI, M->ZJ_DATA1, SZJ->ZJ_DATA1))+" - "+SubS(iIf(INCLUI, M->ZJ_HORA1, SZJ->ZJ_HORA1),1,5)
        oPrinter:Say ( nRow         , nColInfo+nCol3, cAux /*cText>*/, oFInfo /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    EndIf

	cAux := AllTrim(Transform( iIf(INCLUI, M->ZJ_TARACAM + M->ZJ_TARACA1, SZJ->ZJ_TARACAM + SZJ->ZJ_TARACA1), X3Picture("ZJ_TARACAM") ) )
    oPrinter:Say ( nRow+=nTamLin, nColLabel, "Peso Saida.....:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo ,  cAux/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

    If !Empty(StrTran(DtoC(iIf(INCLUI, M->ZJ_DATA2, SZJ->ZJ_DATA2)),"/","")+StrTran(iIf(INCLUI, M->ZJ_HORA2, SZJ->ZJ_HORA2),":",""))
        cAux := DtoC(iIf(INCLUI, M->ZJ_DATA2, SZJ->ZJ_DATA2))+" - "+SubS(iIf(INCLUI, M->ZJ_HORA2, SZJ->ZJ_HORA2),1,5)
        oPrinter:Say ( nRow         , nColInfo+nCol3, cAux /*cText>*/, oFInfo /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    EndIf

    oPrinter:Say ( nRow+=nTamLin, nColLabel, "Peso Líquido...:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    // oPrinter:Say ( nRow         , nColInfo , AllTrim(Transform( Abs( nZJPESOCAM-nZJTARACAM ), X3Picture("ZJ_TARACAM") ) )/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo , AllTrim(Transform( iIf(INCLUI, M->ZJ_PESOL, SZJ->ZJ_PESOL), X3Picture("ZJ_PESOL") ) ) /*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

	oPrinter:Say ( nRow+=nTamLin, nColLabel, "Peso Médio.....:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo , AllTrim(Transform( iIf(INCLUI, M->ZJ_MEDNF, SZJ->ZJ_MEDNF), X3Picture("ZJ_MEDNF") ) )/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

    oPrinter:Say ( nRow+=nTamLin, nColLabel, "Número CTE.....:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/    )
    oPrinter:Say ( nRow         , nColInfo , AllTrim( iIf(INCLUI, M->ZJ_CTE, SZJ->ZJ_CTE))/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

    oPrinter:Say ( nRow         , nColLabel+nCol2, "Número GTA.....:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/    )
    oPrinter:Say ( nRow         , nColInfo+nCol2 , AllTrim( iIf(INCLUI, M->ZJ_GTA, SZJ->ZJ_GTA))/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

    oPrinter:Say ( nRow         , nColLabel+nCol3, "Número Minuta..:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/    )
    oPrinter:Say ( nRow         , nColInfo+nCol3 , AllTrim( iIf(INCLUI, M->ZJ_NMINUTA, SZJ->ZJ_NMINUTA))/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

	oPrinter:Say ( nRow+=nTamLin, nColLabel, "Lote.....:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/    )
    oPrinter:Say ( nRow         , nColInfo-30 , _cLote      /*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

	If _nQuantNF == _nQuantLote
		//oPrinter:Say ( nRow         , nColLabel+nCol2, "Quant.NF...:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
		//oPrinter:Say ( nRow         , nColInfo +nCol2, AllTrim(Transform( _nQuantNF, X3Picture("ZSG_QUANT") ) )/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
		
		oPrinter:Say ( nRow         , nColLabel+nCol3+105, "Quant. Carreg e Em NF:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
		oPrinter:Say ( nRow         , nColInfo +nCol3+120, AllTrim(Transform( _nQuantLote, X3Picture("ZSG_QUANT") ) )/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	Else
		oPrinter:Say ( nRow         , nColLabel+nCol3+105, "Quant.Carreg:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
		oPrinter:Say ( nRow         , nColInfo +nCol3+120, AllTrim(Transform( _nQuantLote, X3Picture("ZSG_QUANT") ) )/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	EndIf

    //If !Empty( cUltTrato )
    //    oPrinter:Say ( nRow     , nColLabel+nCol3, "Ultimo Trato:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    //    oPrinter:Say ( nRow     , nColInfo+nCol3 , cUltTrato/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    //EndIf

    oPrinter:Say ( nRow+=nTamLin, nColLabel, "Observação.....:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    nCountLinOBS := 0
    cTamOBS      := 123
    cTexto       := StrTran( AllTrim(iIf(INCLUI, M->ZJ_OBS, SZJ->ZJ_OBS)), Chr(13)+Chr(10), " ")
    nRow         -= nTamLin
    While .T.
        nCountLinOBS += 1
        oPrinter:Say ( nRow +=nTamLin, nColInfo , SubS(Upper(cTexto),1,cTamOBS)/*cText>*/, oFInfoOBS/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
        cTexto := SubS(cTexto, cTamOBS+1)
        if (nCountLinOBS==nTotLinOBS) .OR. Empty(cTexto)
            exit
        Endif
    EndDo

    //nRow += (nTamLin*(nTotLinOBS-nCountLinOBS))
	oPrinter:Say ( nRow+=nTamLin, nCol2, "Assinatura Motorista................................................................"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

Return 


/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  fQryUltTrato 	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  15.12.2020                   	          	            	              |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
Static Function fQryUltTrato( cBaia )
Local cRetorno := ""

_cQry := " SELECT Z0W_LOTE, " + CRLF +;
         " 	      MAX(Z0W_DATA) DATA," + CRLF +;
         " 	      SUBSTRING(MAX(Z0W_DATA+Z0W_HORFIN),9,5) HORA" + CRLF +;
         " FROM " + RetSqlName("Z0W") + "" + CRLF +;
         " WHERE Z0W_FILIAL = '" + xFilial('Z0W') + "'" + CRLF +;
         " AND Z0W_LOTE = '" + cBaia + "'" + CRLF +;
         " AND (Z0W_QTDREA > 0 OR Z0W_PESDIG > 0)" + CRLF +;
         " AND D_E_L_E_T_ = ' '" + CRLF +;
         " GROUP BY Z0W_LOTE"
dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),"TEMPSQL",.F.,.F.)
If !TEMPSQL->(Eof()) 
    cRetorno := /*AllTrim(TEMPSQL->Z0W_LOTE) + ': ' +*/dToC(sToD(TEMPSQL->DATA)) + ' - ' + TEMPSQL->HORA
    // TEMPSQL->(DBSkip())
EndIf
TEMPSQL->(DbCloseArea())

Return cRetorno

/* MB : 20.12.2021
	-> Carrega todas as notas da pessagem; */
// Static Function LoadPesagens( cTipo, _cCodigo, nZJPESOCAM, nZJTARACAM )
Static Function LoadPesagens( _cTEMP, _cFilial, _cCodigo )
Local _cQry  := ""

	
	nZJPESOCAM := 0
	nZJTARACAM := 0

		_cQry := " WITH SZJ AS ( " + CRLF 
        _cQry += " 	SELECT		* " + CRLF 
        _cQry += " 	FROM		" + RetSqlName("SZJ") + "  ZJ " + CRLF 
        _cQry += " 	WHERE		ZJ.R_E_C_N_O_ = (SELECT   MIN(R_E_C_N_O_) R_E_C_N_O_ " + CRLF 
        _cQry += " 								 FROM     " + RetSqlName("SZJ") + " ZJ2 " + CRLF 
        _cQry += " 								 WHERE    ZJ2.ZJ_CODIGO = ZJ.ZJ_CODIGO " + CRLF 
        _cQry += " 									  AND ZJ_FILIAL+ZJ_CODIGO = '" + _cFilial + _cCodigo + "'  " + CRLF 
        _cQry += " 									  AND ZJ2.D_E_L_E_T_=' ' " + CRLF 
        _cQry += " 								 ) " + CRLF 
        _cQry += "             AND ZJ.D_E_L_E_T_=' ' " + CRLF 
        _cQry += " ) " + CRLF 
        _cQry += "  " + CRLF 
        _cQry += " , DADOS AS ( " + CRLF 
        _cQry += " 	SELECT		ZJ_FILIAL, ZJ_CODIGO, ZJ_ITEM,  " + CRLF 
        _cQry += " 				ZJ_PESOCAM,ZJ_TARACA1,ZJ_TARACAM,ZJ_PESCAM2, ZJ_MEDNF,ZJ_TPPES " + CRLF 
        _cQry += " 				, RTRIM(ZSG_LOTE) ZSG_LOTE " + CRLF 
        _cQry += " 				, SUM(ZSG_QUANT) ZSG_QUANT " + CRLF 
        _cQry += " 	FROM		SZJ " + CRLF
        _cQry += " 	  LEFT JOIN " + RetSqlName("ZSG") + " ZSG ON ZJ_FILIAL=ZSG_FILIAL " + CRLF 
        _cQry += " 					   AND ZJ_CODIGO=ZSG_CODIGO " + CRLF 
        _cQry += " 					   AND ZSG.D_E_L_E_T_ = ' ' " + CRLF 
        _cQry += " 					   --AND ZJ_ITEM  =ZSG_SZJITE " + CRLF 
        _cQry += " 	GROUP BY    ZJ_FILIAL, ZJ_CODIGO, ZJ_ITEM,  " + CRLF 
        _cQry += " 				ZJ_PESOCAM,ZJ_TARACA1,ZJ_TARACAM,ZJ_PESCAM2, ZJ_MEDNF,ZJ_TPPES, " + CRLF 
        _cQry += " 				ZSG_LOTE " + CRLF 
        _cQry += " ) " + CRLF 
        _cQry += "  " + CRLF 
        _cQry += " , GRUPO1 AS ( " + CRLF 
        _cQry += " 	SELECT		ZJ_FILIAL, ZJ_CODIGO, ZJ_ITEM,  " + CRLF 
        _cQry += " 				ZJ_PESOCAM,ZJ_TARACA1,ZJ_TARACAM,ZJ_PESCAM2, ZJ_MEDNF,ZJ_TPPES " + CRLF 
        _cQry += " 				, STRING_AGG(ZSG_LOTE, ', ') WITHIN GROUP (ORDER BY  ZSG_LOTE) AS ZSG_LOTE " + CRLF 
        _cQry += " 				, SUM(ZSG_QUANT) ZSG_QUANT " + CRLF 
        _cQry += " 	FROM		DADOS  " + CRLF 
        _cQry += " 	GROUP BY	ZJ_FILIAL, ZJ_CODIGO, ZJ_ITEM,  " + CRLF 
        _cQry += " 				ZJ_PESOCAM,ZJ_TARACA1,ZJ_TARACAM,ZJ_PESCAM2, ZJ_MEDNF,ZJ_TPPES " + CRLF 
        _cQry += " ) " + CRLF 
        _cQry += "  " + CRLF 
        _cQry += " SELECT		G.*, SUM(Z.ZJ_QTDNF) ZJ_QTDNF " + CRLF 
        _cQry += " 		  , STRING_AGG(ZJ_DOC, ', ') WITHIN GROUP (ORDER BY  ZJ_DOC) AS ZJ_DOC " + CRLF 
        _cQry += " FROM		GRUPO1 G " + CRLF 
        _cQry += "        JOIN " + RetSqlName("SZJ") + " Z ON Z.ZJ_FILIAL=G.ZJ_FILIAL " + CRLF 
        _cQry += " 					AND Z.ZJ_CODIGO=G.ZJ_CODIGO " + CRLF 
        _cQry += " 					AND Z.D_E_L_E_T_=' ' " + CRLF 
        _cQry += " -- WHERE	    G.ZJ_FILIAL+G.ZJ_CODIGO = '" + _cFilial + _cCodigo + "'  " + CRLF 
        _cQry += " GROUP BY	G.ZJ_FILIAL , G.ZJ_CODIGO , G.ZJ_ITEM,  " + CRLF 
        _cQry += " 		    ZSG_LOTE, " + CRLF 
        _cQry += " 		    ZSG_QUANT, " + CRLF 
        _cQry += " 			G.ZJ_PESOCAM,G.ZJ_TARACA1,G.ZJ_TARACAM,G.ZJ_PESCAM2,G.ZJ_MEDNF,G.ZJ_TPPES"

		MpSysOpenQuery(_cQry,_cTEMP)

	/* 
	If cTipo == "NFs"
		While !QRYTMP->(Eof())
			cRet += Iif(Empty(cRet), "", " / ") +;
					QRYTMP->ZJ_ITEM + ": " +;
					AllTrim(QRYTMP->ZJ_DOC  ) + "-" +;
					AllTrim(QRYTMP->ZJ_SERIE)
					
			nZJPESOCAM += QRYTMP->ZJ_PESOCAM
			nZJTARACAM += QRYTMP->ZJ_TARACAM
			QRYTMP->(DbSkip())
		EndDo
	EndIf
    */
// Return cRet
Return !(_cTEMP)->(Eof())
/* 
	MB: 23.12.2021
		Consulta Antiga: F2CHV 
		Consulta Nova  : SF2PSB 
 */
User Function SF2PSB()

	Local lRet       := .T.
	Local _cQry      := ""
	Local aDados	 := {}
	Local _cCampos := ""
	Local nI       := 0

	Public __cChaveNF  := ""
	Public __cDoc      := ""
	Public __cSerie    := ""
	Public __cCliente  := ""
	Public __cLoja     := ""
	Public __cNome     := ""
	Public __cProd     := ""
	Public __dData     := sTod("")
	Public __nQuant    := 0
	Public nRecnoSF2   := ""


	_cCampos := "+';'+F2_FILIAL" + CRLF +;
		"+';'+F2_DOC" + CRLF +;
		"+';'+F2_SERIE" + CRLF +;
		"+';'+F2_CLIENTE" + CRLF +;
		"+';'+F2_LOJA" + CRLF +;
		"+';'+A1_NOME" + CRLF +;
		"+';'+F2_CHVNFE" + CRLF +;
		"+';'+CAST(SUM(D2_QUANT) AS VARCHAR)" + CRLF +;
		"+';'+D2_COD" + CRLF +;
		"+';'+B1_DESC" + CRLF +;
		"+';'+F2_EMISSAO" + CRLF +;
		"+';'+D2_GRUPO" + CRLF +;
		"+';'+CAST(F2.R_E_C_N_O_ AS VARCHAR) AS RESULTADO "

/* nao pode usar RetSqlName */
	_cQry := " SELECT * " + CRLF +;
		" FROM( " + CRLF

	_cSel := ""
	For nI := 1 to GetMV("MB_QTEMPVL",, 2) // Len(_aEmprs)
		_cSel += Iif(Empty(_cSel), "", CRLF + " 	UNION ALL " + CRLF ) +;
			" 		SELECT 	    '"+ StrZero(nI, LEN(cFilAnt))/* _aEmprs[nI] */ +"' " + CRLF +;
			_cCampos + CRLF +;
			" FROM		       SF2"+ StrZero(nI, LEN(cFilAnt)) +"0 " + " F2 " + CRLF +;
			"             JOIN SD2"+ StrZero(nI, LEN(cFilAnt)) +"0 " + " D2 ON /*F2_FILIAL = '" + xFilial('SF2') + "' AND*/  F2_FILIAL = D2_FILIAL " + CRLF +;
			"                  AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE " + CRLF +;
			"                  AND F2_CLIENTE = D2_CLIENTE " + CRLF +;
			"                  AND F2_LOJA = D2_LOJA  " + CRLF +;
			" 					AND LEFT(D2_GRUPO, 2) IN (" + GetMV( 'MB_LIVIO4C',, "('05')") + ") " + CRLF +;
			" 					AND F2_CHVNFE <> ' ' " + CRLF +;
			" 					--AND F2_TIPO = 'N' " + CRLF +;
			" 					AND D2.D_E_L_E_T_ = ' '  " + CRLF +;
			" 			   JOIN	SB1"+ StrZero(nI, LEN(cFilAnt)) +"0 " + " B1 ON B1_FILIAL = ' ' AND B1_COD=D2_COD " + CRLF +;
			" 					AND B1.D_E_L_E_T_ = ' ' " + CRLF +;
			"             JOIN SA1"+ StrZero(nI, LEN(cFilAnt)) +"0 "  + " A1	ON A1_FILIAL = '" + xFilial('SA1') + "' AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA  " + CRLF +;
			" 					AND A1.D_E_L_E_T_ = ' ' " + CRLF +;
			" 		  LEFT JOIN SZJ"+ StrZero(nI, LEN(cFilAnt)) +"0 " + " ZJ ON ZJ_CHVNF = F2_CHVNFE" + CRLF +;
			" 		            AND ZJ.D_E_L_E_T_ = ' ' " + CRLF +;
			" WHERE 	( ZJ_CHVNF IS NULL OR ZJ_CHVNF = '" + Space(TamSX3('ZJ_CHVNF')[1]) + "')" + CRLF +;
			"      AND ( " + CRLF +;
			"  	        F2_DOC LIKE '%%' " + CRLF +;
			"  		 OR F2_CLIENTE LIKE '%%' " + CRLF +;
			"  		 OR F2_CHVNFE LIKE '%%' " + CRLF +;
			"  		 OR D2_COD LIKE '%%' " + CRLF +;
			"         OR B1_DESC LIKE '%%' " + CRLF +;
			"           )" + CRLF +;
			" 		AND F2.D_E_L_E_T_ = ' '  " + CRLF+;
			"  GROUP BY F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, A1_NOME, F2_CHVNFE, D2_COD, B1_DESC, F2_EMISSAO, D2_GRUPO, F2.R_E_C_N_O_  " + CRLF
	Next nI

	_cQry  += _cSel
	_cQry  += " ) DADOS " + CRLF +;
		" ORDER BY 	1"
/* 
_cQry := " SELECT       " +;
         	       "F2_DOC"+;
         	       "+';'+F2_SERIE"+;
         	       "+';'+F2_CLIENTE"+;
         	       "+';'+F2_LOJA"+;
         	       "+';'+A1_NOME"+;
         	       "+';'+F2_CHVNFE"+;
         	       "+';'+CAST(D2_QUANT AS VARCHAR)"+;
         	       "+';'+D2_COD"+;
         	       "+';'+B1_DESC"+;
         	       "+';'+D2_GRUPO"+;
         	       "+';'+CAST(F2.R_E_C_N_O_ AS VARCHAR) AS RESULTADO " + CRLF +;
         " FROM		        " + RetSqlName("SF2") + " F2 " + CRLF +;
         "             JOIN " + RetSqlName("SD2") + " D2 ON F2_FILIAL = '" + xFilial('SF2') + "' AND F2_FILIAL = D2_FILIAL " + CRLF +;
		 "                  AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE " + CRLF +;
		 "                  AND F2_CLIENTE = D2_CLIENTE " + CRLF +;
		 "                  AND F2_LOJA = D2_LOJA  " + CRLF +;
         " 					AND LEFT(D2_GRUPO, 2) IN (" + GetMV( 'MB_LIVIO4C',, "('05')") + ") " + CRLF +;
         " 					AND F2_CHVNFE <> ' ' " + CRLF +;
         " 					--AND F2_TIPO = 'N' " + CRLF +;
         " 					AND D2.D_E_L_E_T_ = ' '  " + CRLF +;
         " 			   JOIN	" + RetSqlName("SB1") + " B1 ON B1_FILIAL = ' ' AND B1_COD=D2_COD " + CRLF +;
         " 					AND B1.D_E_L_E_T_ = ' ' " + CRLF +;
		 "             JOIN " + RetSqlName("SA1") + " A1	ON A1_FILIAL = '" + xFilial('SA1') + "' AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA  " + CRLF +;
		 " 					AND A1.D_E_L_E_T_ = ' ' " + CRLF +;
		 " 		  LEFT JOIN " + RetSqlName("SZJ") + " ZJ ON ZJ_CHVNF = F2_CHVNFE" + CRLF +;
         " 		            AND ZJ.D_E_L_E_T_ = ' ' " + CRLF +;
		 " WHERE 	( ZJ_CHVNF IS NULL OR ZJ_CHVNF = '" + Space(TamSX3('ZJ_CHVNF')[1]) + "')" + CRLF +;
		  "     AND ( " + CRLF +;
		 "  	        F2_DOC LIKE '%%' " + CRLF +;
		 "  		 OR F2_CLIENTE LIKE '%%' " + CRLF +;
		 "  		 OR F2_CHVNFE LIKE '%%' " + CRLF +;
		 "  		 OR D2_COD LIKE '%%' " + CRLF +;
		 "         OR B1_DESC LIKE '%%' " + CRLF +;
		"           )" + CRLF +;
		" 		AND F2.D_E_L_E_T_ = ' '  "  */

MemoWrite( Iif(GetRemoteType()==2, "/data/", "C:\totvs_relatorios\") + "Livio004_SF2PSB.sql" , _cQry)

aDados := U_fBsGenerico("Notas Fiscais Faturadas", _cQry,;
			  /* 01 */  {"Empresa",;
			  /* 02 */  "Filial",;
			  /* 03 */  "Nota Fiscal",;
			  /* 04 */  "Serie",;
			  /* 05 */  "Cliente",;
			  /* 06 */  "Loja",;
			  /* 07 */  "Nome do Cliente",;
			  /* 08 */  "Chave NFe",;
			  /* 09 */  "Quant",;
			  /* 10 */  "Cod. Produto",;
			  /* 11 */  "Desc. Produto",;
			  /* 12 */  "Dt Emissao",;
			  /* 13 */  "Grupo",;
			  /* 14 */  "R_E_C_N_O_"},;
			  /* 01 */  ,,{ 06,;
			  /* 02 */	    06,;
			  /* 03 */	    12,;
			  /* 04 */	    06,;
			  /* 05 */	    13,;
			  /* 06 */	    06,;
			  /* 07 */	    45,;
			  /* 08 */	    45,;
			  /* 09 */	    15,;
			  /* 10 */	    15,;
			  /* 08 */	    30,;
			  /* 11 */	    08,;
			  /* 12 */	    10,;
			  /* 13 */	    10 })
If Len(aDados) > 0
	__cChaveNF  := aDados[08]
	__cDoc      := aDados[03]
    __cSerie    := aDados[04]
    __cCliente  := aDados[05]
	__cLoja     := aDados[06]
	__cNome     := aDados[07]
	__dData     := sTod(aDados[12])
	__nQuant    := aDados[09]
	// nRecnoSF2   := aDados[09]
	__cProd     := aDados[10]

	oSZJGtDad:aCols[ oSZJGtDad:nAt, nPZJPRODUTO ] := __cProd
	_cEmpFil := PADL(aDados[01], LEN(SM0->M0_CODIGO), "0") + PADL(aDados[02], LEN(SM0->M0_CODIGO), "0")
	oSZJGtDad:aCols[ oSZJGtDad:nAt, nPZJEMPFIL ] := _cEmpFil

Else
	__cChaveNF  := ""
	__cDoc      := ""
	__cSerie    := ""
	__cCliente  := ""
	__cLoja     := ""
	__Nome      := ""
	oSZJGtDad:aCols[ oSZJGtDad:nAt, nPZJNOME ]   := ""
	oSZJGtDad:aCols[ oSZJGtDad:nAt, nPZJEMPFIL ] := ""
	 
	// nRecnoSF2   := ""
EndIf

Return lRet

/* 
		X3_ARQUIVO $ ('SZJ,SZG')
		INDICE $ ('SZJ,SZG')
*/

User Function SB8ZSG()

	Local lRet     := .T.
	Local _cQry    := ""
	Local _cCampos := ""
	Local aDados   := {}
	Local _cEmpFil := ""
	Local nI       := 0

	Public __cLote := ""
	Public __cArmz := ""
	Public __cProd := ""

	_cCampos := "+';'+ B8_FILIAL " + CRLF +;
		"+';'+ rTrim(B8_LOTECTL) " + CRLF +;
		"+';'+ (B8_X_CURRA) " + CRLF +;
		"+';'+ rTrim(B8_LOCAL) " + CRLF +;
		"+';'+ rTrim(B8_PRODUTO) " + CRLF +;
		"+';'+ CAST(B8_XDATACO AS VARCHAR) " + CRLF +;
		"+';'+ CAST(B8_XPESTOT AS VARCHAR) " + CRLF +;
		"+';'+ CAST(B8_XPESOCO AS VARCHAR) " + CRLF +;
		"+';'+ CAST(B8_SALDO   AS VARCHAR) " + CRLF +; // "+';'+ B8_FILIAL+B8_LOTECTL+B8_X_CURRA " + CRLF +;
		"+';'+ CAST(R_E_C_N_O_ AS VARCHAR) AS RESULTADO "

/* nao pode usar RetSqlName */
	_cQry := " SELECT * " + CRLF +;
		" FROM( " + CRLF

	_cSel := ""
	_cSel += " 		SELECT 	'"+cEmpAnt+ "' "+ _cCampos +" "+ CRLF +;
		" 		FROM		"+RetSqlName("SB8")+" " + CRLF +;
		" 		WHERE		B8_SALDO > 0 AND D_E_L_E_T_ = ' ' " +CRLF +;
		"         AND       B8_FILIAL = '"+cFilAnt+"' " + CRLF +;
		" 		  AND       (B8_FILIAL LIKE  '%%' " + CRLF +;
		" 		   OR        B8_X_CURRA LIKE '%%' " + CRLF +;
		" 		   OR        B8_LOTECTL LIKE '%%')"

//For nI := 1 to GetMV("MB_QTEMPVL",, 2) // Len(_aEmprs)
//	_cSel += Iif(Empty(_cSel), "", CRLF + " 	UNION ALL " + CRLF ) +;
//	        " 		SELECT 	    '"+ StrZero(nI, LEN(cFilAnt))/* _aEmprs[nI] */ +"' " + CRLF +;
//					_cCampos + CRLF +;
//			" 		FROM		SB8"+ StrZero(nI, LEN(cFilAnt))/* _aEmprs[nI] */ +"0 " + CRLF +;
//			" 		WHERE		B8_SALDO > 0 AND D_E_L_E_T_ = ' ' " +CRLF
//			IF GetMV("MB_QTEMPVL",, 2) == 1
//   _cSel += "         AND       B8_FILIAL = '"+cFilAnt+"' " 
//			EndIf			
//   _cSel += " 		  AND       (B8_FILIAL LIKE  '%%' " + CRLF +;
//			" 		   OR        B8_X_CURRA LIKE '%%' " + CRLF +;
//			" 		   OR        B8_LOTECTL LIKE '%%')" 
//Next nI

	_cQry  += _cSel
	_cQry  += " ) DADOS " + CRLF +;
		" ORDER BY 	1"

	MemoWrite( Iif(GetRemoteType()==2, "/data/", "C:\totvs_relatorios\") + "Livio004_SB8ZSG.sql" , _cQry)

	aDados := U_fBsGenerico("Lotes com saldo em estoque", _cQry,;
			  /* 01 */  {"EMPRESA",;
			  /* 02 */   "FILIAL",;
			  /* 03 */   "Lote",;
			  /* 04 */   "Curral",;
			  /* 05 */   "Armazem",;
			  /* 06 */   "Produto",;
			  /* 07 */   "Dt Confinamento",;
			  /* 08 */   "Peso Total",;
			  /* 09 */   "Peso Confinamento",;
			  /* 10 */   "Saldo",; // /* 10 */   "Chave",;
			  /* 11 */   "R_E_C_N_O_"},;
			  /* 01 */  ,,{ 10,;
			  /* 02 */	    10,;
			  /* 03 */	    15,;
			  /* 04 */	    15,;
			  /* 05 */	    10,;
			  /* 06 */	    25,;
			  /* 07 */	    15,;
			  /* 08 */	    15,;
			  /* 09 */	    15,;
			  /* 10 */	    15,;
			  /* 11 */	    10 })
		If Len(aDados) > 0
		__cLote := aDados[03]
		__cArmz := aDados[05]
		__cProd := aDados[06]

		_cEmpFil := PADL(aDados[01], LEN(SM0->M0_CODIGO), "0") + PADL(aDados[02], LEN(SM0->M0_CODIGO), "0")
		oZSGGtDad:aCols[ oZSGGtDad:nAt, nPZSGEMPFIL ] := _cEmpFil

		// nRecno := aDados[09]
	Else
		__cLote := ""
		__cArmz := ""
		__cProd := ""
		oZSGGtDad:aCols[ oZSGGtDad:nAt, nPZSGEMPFIL ] := ""
	EndIf

Return lRet
User Function LV04WH()
	Local lRet := oSZJGtDad:aCols[ 01, NPZJTPPES  ] == 'D'
Return lRet
