#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE "OGC120C.CH"

#DEFINE __CRLF CHR(13)+CHR(10)

/*{Protheus.doc} OGC120CVIN
//Monta a tela de detalhes para as ações de VINCULAR/DESVINCULAR
@type function
@param cAction, CHAR, (Indica se a função foi chamada pelo botão 1=Vincular, 2=Desvincular
@author roney.maia / marcos.wagner
@since 16/05/2018
*/
Function OGC120CVIN(cAction)
	Local aCoors        := FWGetDialogSize( oMainWnd )
	Local oSize         := {}
	Local oSize1        := {}
	Local oSize2        := {}
	Local oFWL          := ""
	Local oDlg		    := Nil
	Local aFilBrowRA    := {}
	Local aFilBrowPR    := {}
	Local nX            := 0	
	Local NAUXTAM       := 0.5	
	Local cQuery        := ""
    Local cQuery2       := ""	
	Local aColumns      := {}
    Local lRet          := .f.    
    Local aChoiceBtn    := {}
    Local cNomeBr1      := IIF((cAction <> "3" .OR. (cAction == "3" .AND. oTFolder:nOption==2)),STR0005,STR0006) //"RAs"###"Previsões"
    Local cNomeBr2      := IIF(!(cAction $ "3|4|6"), STR0006, STR0007) //Previsões ### NFs
    Local aAreaNJR      := NJR->(GetArea())
	Local aAreaNN7      := NN7->(GetArea())

    Private cCadastro   := ""
	Private _cFiltro    := ""
	Private _cWhere2    := ""

	Private oBrowse1    := Nil  //Browse de RA tela de Vincular
	Private oBrowse2	:= Nil  //Browse de PR tela de Vincular
	Private oTFolder	:= Nil
	Private oPnl1       := Nil


	Private _aFldsGrd1	:= {} // Array com os campos que serao utilizados no Browser
	Private _aFldsGrd2	:= {} // Array com os campos que serao utilizados no Browser
	Private _aFields1	:= {}
	Private _aFields2   := {}
	Private _aIndice    := {}
	
	Private _oOGC120RA	:= Nil  //Objeto fwTemporaryTable
	Private _oOGC120PR	:= Nil  //Objeto fwTemporaryTable
	
	Private _cAliaBrw1	:= "" // Obtem o proximo alias disponivel, tabela temporaria
	Private _cAliaBrw2	:= "" // Obtem o proximo alias disponivel, tabela temporaria
	Private _cContrato  := NN7->NN7_CODCTR
	Private _cItemPF    := NN7->NN7_ITEM
	Private _dDataVenc  := NN7->NN7_DTVENC
	Private _FilOrgPR   := NN7->NN7_FILORG
	Private _lMarca     := .T.
	Private lTemFilVen  := .f.

	Private _lFilExcl   := Iif( Len(Alltrim(FWxFilial("SE1"))) > 2, .T., .F. )	// Indica se usa Gestao Corporativa
	
 	If(cAction == "1")
   		cCadastro := STR0015 //"Vincular"
 	Else
 		cCadastro := STR0016 // "Desvincular"
 	Endif 	
	

    OGC120CGRD(cAction)	

	//Primeira tabela temporária
    If _oOGC120RA != Nil // Se ja existe o objeto de tabela temporária, deleta o mesmo, fechando o alias utilizado
		_oOGC120RA:Delete()
	EndIf

	_cAliaBrw1	:= GetNextAlias() // Obtem o proximo alias disponivel, tabela temporaria
	_oOGC120RA	:= AGRCRTPTB(_cAliaBrw1, {_aFields1, _aIndice } ) // Instancia a tabela temporária com o alias
	
    _cWhere2 := _cFiltro
	cQuery  := IIF(cAction == "1", fQryVincRA(), fQryDesvRA())  //OGC120AQRY(IIF(lInvertGrd,"1","2"), cAction)
    OGC120BTMP(cQuery, _cAliaBrw1, _aFields1) // Monta e carrega a tabela temporária

	//Adiciona os campos do Grid de Previsão
	//Segunda tabela temporária
    If _oOGC120PR != Nil // Se ja existe o objeto de tabela temporária, deleta o mesmo, fechando o alias utilizado
		_oOGC120PR:Delete()
	EndIf
	
	_cAliaBrw2	:= GetNextAlias()
	_oOGC120PR	:= AGRCRTPTB( _cAliaBrw2, {_aFields2, _aIndice } ) // Instancia a tabela temporária com o alias
    
    cQuery2 := iif(cAction == "1", fQryVincPR(), fQryDesvPR()) //OGC120AQRY("2", cAction)
    
    OGC120BTMP(cQuery2, _cAliaBrw2, _aFields2 ) // Monta e carrega a tabela temporária

	//tamanho da tela principal
	oSize := FWDefSize():New(.t.) //considerar o enchoice
	oSize:AddObject('DLG',100,100,.T.,.T.)
	oSize:SetWindowSize(aCoors)
	oSize:lProp 	:= .T.
	oSize:aMargins := {0,0,0,0}
	oSize:Process()

	oDlg := TDialog():New(  oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4], STR0004, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Painel de Previsão Financeira"

	oPnl1:= tPanel():New(oSize:aPosObj[1,1],oSize:aPosObj[1,2],,oDlg,,,,,,oSize:aPosObj[1,4],oSize:aPosObj[1,3] - 30 /*enchoice bar*/)

	// Instancia o layer
	oFWL := FWLayer():New()

	// Inicia o Layer
	oFWL:init( oPnl1, .F. )

	// Cria as divisões horizontais
	oFWL:addLine('MASTER1', 100 , .F.)
	oFWL:addCollumn('TOPO',100,.F., 'MASTER1') //alterado para uma coluna só

	//cria as janelas
	oFWL:addWindow( 'TOPO' , 'Wnd1', cNomeBr1,  50 /*tamanho*/, .T., .F.,, 'MASTER1' ) //"RAs"###"Previsões"
	oFWL:addWindow( 'TOPO', 'Wnd2', cNomeBr2,  50 /*tamanho*/, .T., .F.,, 'MASTER1' ) //Previsões ### NFs
	
	// Recupera os Paineis das divisões do Layer
	oPnlWnd1:= oFWL:getWinPanel( 'TOPO' , 'Wnd1', 'MASTER1' )
	oPnlWnd2:= oFWL:getWinPanel( 'TOPO', 'Wnd2', 'MASTER1' ) //alterado para criar os dois paineis para uma coluna só

	/****************** Recebimentos de Adiantamentos ********************************/
	//realizado implementação do size para que a grid se auto ajuste na opção de maxizar/minimizar
	oSize1 := FWDefSize():New(.F.)
	oSize1:AddObject("TESTE1",100,100,.T.,.T.)
	oSize1:SetWindowSize({0,0,oPnlWnd1:NHEIGHT,oPnlWnd1:NWIDTH})
	oSize1:lProp 	:= .T.
	oSize1:aMargins := {0,0,0,0}
	oSize1:Process()

	//adicionando os widgets de tela
	oBrowse1 := FWMBrowse():New(oPnlWnd1) //incluido o painel aqui conforme exemplos
    oBrowse1:SetAlias(_cAliaBrw1)
    oBrowse1:DisableDetails()
    oBrowse1:SetMenuDef( "" )
    oBrowse1:DisableReport(.T.)
    oBrowse1:DisableSeek(.T.)
    oBrowse1:SetProfileID("OGC120" + cAction + "RA")
    oBrowse1:bGotFocus := {|tGrid| tGrid:GoColumn(1)}

    //Começa em 2 para desconsiderar o MARK
    For nX := 2 to Len(_aFldsGrd1)
        If !(AllTrim(_aFldsGrd1[nX][2]) $ "CHAVESE1") .AND. !(AllTrim(_aFldsGrd1[nX][2]) $ "NJR_CODCTR") 
            AAdd(aColumns,FWBrwColumn():New())
            aColumns[Len(aColumns)]:SetData(&("{||(_cAliaBrw1)->" + _aFldsGrd1[nX][2]+"}"))
            aColumns[Len(aColumns)]:SetTitle(_aFldsGrd1[nX][1])
            aColumns[Len(aColumns)]:SetSize(_aFldsGrd1[nX][4] * nAuxTam )
            aColumns[Len(aColumns)]:SetDecimal(_aFldsGrd1[nX][5])
            aColumns[Len(aColumns)]:SetPicture(_aFldsGrd1[nX][6])
            aColumns[Len(aColumns) ]:SetAlign( 1 )            

            aADD(aFilBrowRA,  {_aFldsGrd1[nX][2], _aFldsGrd1[nX][1], _aFldsGrd1[nX][3], _aFldsGrd1[nX][4], _aFldsGrd1[nX][5], _aFldsGrd1[nX][6] } )
        EndIf
    Next nX

    oBrowse1:SetColumns( aColumns ) // Colunas utilizadas pelo browser
	oBrowse1:SetFieldFilter(aFilBrowRA)
    oBrowse1:Activate(oPnlWnd1)
	oBrowse1:GoColumn(1)

	/****************** PREVISÃO FINANCEIRA ********************************/	
	//realizado implementação do size para que a grid se auto ajuste na opção de maxizar/minimizar
	oSize2 := FWDefSize():New(.F.)
	oSize2:AddObject("TESTE1",100,100,.T.,.T.)
	oSize2:SetWindowSize({0,0,oPnlWnd2:NHEIGHT,oPnlWnd2:NWIDTH})
	oSize2:lProp 	:= .T.
	oSize2:aMargins := {0,0,0,0}
	oSize2:Process()

	oBrowse2 := FWMBrowse():New(oPnlWnd2) //incluido o painel aqui conforme exemplos
    oBrowse2:DisableReport(.T.)
    oBrowse2:DisableDetails()
    oBrowse2:SetAlias(_cAliaBrw2)
    oBrowse2:SetMenuDef( "" )
    oBrowse2:DisableReport(.T.)
    oBrowse2:DisableSeek(.T.)
    oBrowse2:SetProfileID("OGC120" + cAction + "PR")
    oBrowse2:bGotFocus := {|tGrid| tGrid:GoColumn(1)}

    //marcação de itens
    oBrowse2:AddMarkColumns( { ||Iif( !Empty( (_cAliaBrw2)->MARK = "1" ),"LBOK","LBNO" ) },{ |lConfirma, cAction2| OGC120DBCL(.f., cAction)  }, { || OGC120MKCL()  } )

    If cAction $ "1" //Só vai ser apresentada para a funcionalidade de Alocação. 	    
        //legenda
        oBrowse2:AddLegend( "Empty((_cAliaBrw2)->CHAVESE1)", "GREEN" , STR0008) //"Não alocado"
	    oBrowse2:AddLegend( "AllTrim((_cAliaBrw2)->CHAVESE1) = '"+AllTrim((_cAliaBrw1)->(FILIAL+"/"+TIPO+"/"+PREFIXO+"/"+NUMERO+"/"+PARCELA))+"'", "YELLOW" , STR0009) //"Alocado p/ essa RA"
	    oBrowse2:AddLegend( "AllTrim((_cAliaBrw2)->CHAVESE1) <> '"+AllTrim((_cAliaBrw1)->(FILIAL+"/"+TIPO+"/"+PREFIXO+"/"+NUMERO+"/"+PARCELA))+"'", "RED"   , STR0010) //"Alocado p/ outra RA"
    EndIf

	aColumns := {}

	//Começa em 2 para desconsiderar o MARK
    For nX := 2 to Len(_aFldsGrd2)
        // Adciona as colunas que nao sao chave e situacao e não são acoes da compensacao - ou - que não são o item e parcela da nn7 quando for compesar e estorno do compensar
        If !(AllTrim(_aFldsGrd2[nX][2]) $ "CHAVESE1")

            AAdd(aColumns,FWBrwColumn():New())
            aColumns[Len(aColumns)]:SetData(&("{||(_cAliaBrw2)->" + _aFldsGrd2[nX][2]+"}"))
            aColumns[Len(aColumns)]:SetTitle(_aFldsGrd2[nX][1])
            aColumns[Len(aColumns)]:SetSize(_aFldsGrd2[nX][4] * nAuxTam )
            aColumns[Len(aColumns)]:SetDecimal(_aFldsGrd2[nX][5])
            aColumns[Len(aColumns)]:SetPicture(_aFldsGrd2[nX][6])
            aColumns[Len(aColumns) ]:SetAlign( 1 )
            //aColumns[Len(aColumns) ]:SETHEADERCLICK({|A| OGC120HCk2(A)})

            aADD(aFilBrowPR,  {_aFldsGrd2[nX][2], _aFldsGrd2[nX][1], _aFldsGrd2[nX][3], _aFldsGrd2[nX][4], _aFldsGrd2[nX][5], _aFldsGrd2[nX][6] } )
        EndIf
    Next nX

    oBrowse2:SetColumns( aColumns ) // Colunas utilizadas pelo browser
	oBrowse2:SetFieldFilter(aFilBrowPR)
    oBrowse2:Activate(oPnlWnd2)
	oBrowse2:GoColumn(1)

	oBrowse1:SetChange ({|| OGC120Chng(cAction) })

    OGC120Chng(cAction)

    aChoiceBtn := {{STR0014,              {|| OGC120BGRV(cAction), OGC120CUPD(cAction), oDlg:End()}, STR0014},; // # Salvar e Fechar # Salvar e Fechar    		       
				   {STR0053,              {|| OGC120CINRA()}       , STR0053},; //""Incluir RA" "
				   {STR0034+cNomeBr1,     {|| oBrowse1:Report()} , STR0034+cNomeBr1},; //"Imprimir "
    		       {STR0034+cNomeBr2,     {|| oBrowse2:Report()} , STR0034+cNomeBr2}} //"Imprimir "

	Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|cAcao| lRet := OGC120BGRV(cAction), OGC120CUPD(cAction)  } , {|| lRet := .f., oDlg:End() }, , aChoiceBtn) //"Deseja salvar os dados?"

	//SetKey(VK_F11, Nil)    

	RestArea(aAreaNJR)
	RestArea(aAreaNN7)

Return lRet

/*{Protheus.doc} OGC120CGRD
(Função que inicializa e monta o Browse de consulta)
@type function
@params lTodos Boolean : Indica que irá desconsiderar os valores dos parametros do Pergunte OGC12002
        cAction Char   : Indica a ação 1: Vincular / 2: Desvincular / 3: Detalhar / 4: Compensar / 5: Contato / 6: Estorno Compensar
@author Marcos Wagner / MRFerrari
@since 09/04/2018
@version 1.0
*/
Function OGC120CGRD(cAction)    
    Local nIt	    := 0    
	Local cTitValRA := IIF(cAction = "1", STR0017, STR0018)

    //Pergunte("OGC12002", .F.)

    _aIndice := {}
    _nIdx    := 0
    //MANTER ESSA ORDER POIS a variável _nIdx indica qual o indice para cCpoDoc1
    aAdd(_aIndice,  {"1" , "FILIAL"} )
    _nIdx++

    aAdd(_aIndice,  {"2" , "COD_CLIE,NOME_CLIE" })
    _nIdx++

    aAdd(_aIndice,  {"3" , "LOJA" })
    _nIdx++

    aAdd(_aIndice,  {"4" , "TIPO,PREFIXO,NUMERO,PARCELA"} )
    _nIdx++
    aAdd(_aIndice,  {"5" , "CHAVESE1" } )
    aAdd(_aIndice,  {"6" , "TIPO+NUMERO"} )

    aAdd(_aIndice,  {"7" , "VENCIMENTO" } )
    _nIdx++

    //******************************************RECEBIMENTO DE ANDIANTAMENTO ***************************************************************** */

    //Define as colunas do Browse RA de Acordo com SX3 Para Buscar Tamanho,decimais Etc;
    //Manter aFldsGrd separado pois os campos das consultas podem ser tratados separadamente
    _aFldsGrd1 := {}
    aAdd(_aFldsGrd1, {"MARK" , "MARK"    	, "C" ,  1, , "@!"})

    // Filial
    aAdd(_aFldsGrd1, /* 05 */{AgrTitulo("E1_FILIAL")  , "FILEMP"	, TamSX3("E1_FILIAL" )[3]	, TamSX3("E1_FILIAL" )[1] , TamSX3("E1_FILIAL" )[2]	, PesqPict("SE1","E1_FILIAL") 	})
	aAdd(_aFldsGrd1, /* 05 */{AgrTitulo("E1_FILORIG")  , "FILIAL"	, TamSX3("E1_FILIAL" )[3]	, TamSX3("E1_FILIAL" )[1] , TamSX3("E1_FILIAL" )[2]	, PesqPict("SE1","E1_FILIAL") 	})

    // Cliente
  
    aAdd(_aFldsGrd1, /* 03 */{AgrTitulo("E1_NOMCLI")  , "NOME_CLIE"	, TamSX3("E1_NOMCLI" )[3]	, TamSX3("E1_NOMCLI" )[1] , TamSX3("E1_NOMCLI" )[2]	, PesqPict("SE1","E1_NOMCLI") 	})
	
	// Emissao
    aAdd(_aFldsGrd1, /* 10 */{AgrTitulo("E1_EMISSAO")  , "EMISSAO", TamSX3("E1_EMISSAO" )[3]	, TamSX3("E1_EMISSAO" )[1] , TamSX3("E1_EMISSAO" )[2]	, PesqPict("SE1","E1_EMISSAO") 	})
    // Vencimento
    aAdd(_aFldsGrd1, /* 10 */{AgrTitulo("E1_VENCTO")  , "VENCIMENTO"	, TamSX3("E1_VENCTO" )[3]	, TamSX3("E1_VENCTO" )[1] , TamSX3("E1_VENCTO" )[2]	, PesqPict("SE1","E1_VENCTO") 	})
	
    aAdd(_aFldsGrd1, /* 11 */{cTitValRA , "VALOR"	        , TamSX3("E1_VALOR" )[3]	, TamSX3("E1_VALOR" )[1]  , TamSX3("E1_VALOR" )[2]	, PesqPict("SE1","E1_VALOR") 	}) //"Valor Título (A)"	

	If cAction =="1" //Vincular
        aAdd(_aFldsGrd1, /* 14 */{STR0019 , "PSOMAPVRA"	    , TamSX3("E1_SALDO" )[3]	, TamSX3("E1_SALDO" )[1]  , TamSX3("E1_SALDO" )[2]	, PesqPict("SE1","E1_SALDO") 	}) //"Parcial Vinculado (D)" 
    EndIf
	// Moeda
    aAdd(_aFldsGrd1, /* 04 */{AgrTitulo("E1_MOEDA")   , "MOEDA"	, TamSX3("E1_MOEDA" )[3]	, TamSX3("E1_MOEDA" )[1]  , TamSX3("E1_MOEDA" )[2]	, PesqPict("SE1","E1_MOEDA") 	})

	aAdd(_aFldsGrd1, /* 08 */{AgrTitulo("E1_NUM") 	  , "NUMERO", TamSX3("E1_NUM" )[3]		, TamSX3("E1_NUM" )[1]	  , TamSX3("E1_NUM" )[2]	, PesqPict("SE1","E1_NUM") 		})	
    aAdd(_aFldsGrd1, /* 09 */{AgrTitulo("E1_PARCELA") , "PARCELA", TamSX3("E1_PARCELA" )[3]	, TamSX3("E1_PARCELA" )[1], TamSX3("E1_PARCELA" )[2], "##" 	})

	aAdd(_aFldsGrd1, /* 06 */{AgrTitulo("E1_PREFIXO") , "PREFIXO", TamSX3("E1_PREFIXO" )[3]	, TamSX3("E1_PREFIXO" )[1], TamSX3("E1_PREFIXO" )[2], PesqPict("SE1","E1_PREFIXO") 	})
    aAdd(_aFldsGrd1, /* 07 */{AgrTitulo("E1_TIPO") 	  , "TIPO"	,     TamSX3("E1_TIPO" )[3]		, TamSX3("E1_TIPO" )[1]	  , TamSX3("E1_TIPO" )[2]	, PesqPict("SE1","E1_TIPO") 	})
    	
	aAdd(_aFldsGrd1, /* 01 */{AgrTitulo("E1_CLIENTE") , "COD_CLIE", TamSX3("E1_CLIENTE" )[3]	, TamSX3("E1_CLIENTE")[1] , TamSX3("E1_CLIENTE")[2]	, PesqPict("SE1","E1_CLIENTE") 	})
    
	// Loja
    aAdd(_aFldsGrd1, /* 02 */{AgrTitulo("E1_LOJA") 	  , "LOJA"	, TamSX3("E1_LOJA" )[3]		, TamSX3("E1_LOJA" )[1]	  , TamSX3("E1_LOJA" )[2]	, PesqPict("SE1","E1_LOJA") 	})
	// Documento
        
    //aAdd(_aFldsGrd1, /* 15 */{STR0018 , "SOMAPVRA"	    , TamSX3("E1_SALDO" )[3]	, TamSX3("E1_SALDO" )[1]  , TamSX3("E1_SALDO" )[2]	, PesqPict("SE1","E1_SALDO") 	}) //"Vinculado (B)"     
 
    // Definicao de campo chave com o tamanho dos campos que compoe a chave mais os caracteres de separação que totalizam 4 '/'
    aAdd(_aFldsGrd1,/* 19 */{STR0020, "CHAVESE1", "C", (TamSX3("E1_TIPO" )[1]+TamSX3("E1_PREFIXO" )[1]+TamSX3("E1_NUM" )[1]+TamSX3("E1_PARCELA" )[1]+TamSX3("NN7_FILORG" )[1]+TamSX3("E1_LOJA" )[1]) + 5, TamSX3("E1_TIPO" )[2], "@!" }) //"Chave"
    _aFields1 := {}

	For nIt := 1  to Len(_aFldsGrd1)
       	aAdd(_aFields1, {_aFldsGrd1[nIt][2], _aFldsGrd1[nIt][3], _aFldsGrd1[nIt][4], _aFldsGrd1[nIt][5]})
    Next nIt

    //******************************************PREVISAO FINANCEIRA ***************************************************************** */
    _aFldsGrd2 := {}

    aAdd(_aFldsGrd2, {"MARK" , "MARK"    	, "C" ,  1, , "@!"}) 
        
    // Filial
    aAdd(_aFldsGrd2, /* 05 */{AgrTitulo("NN7_FILORG")  , "FILIAL"	, TamSX3("NN7_FILORG" )[3]	, TamSX3("NN7_FILORG" )[1] , TamSX3("NN7_FILORG" )[2]	, PesqPict("NN7","NN7_FILORG") 	})  
	
	// Vencimento
    aAdd(_aFldsGrd2, /* 11 */{AgrTitulo("NN7_DTVENC")  , "VENCIMENTO"	, TamSX3("NN7_DTVENC" )[3]	, TamSX3("NN7_DTVENC" )[1] , TamSX3("NN7_DTVENC" )[2]	, PesqPict("NN7","NN7_DTVENC") 	})  

	aAdd(_aFldsGrd2, /* 12 */{STR0021 , "VALOR"	    , TamSX3("NN7_VALOR" )[3]	, TamSX3("NN7_VALOR" )[1]  , TamSX3("NN7_VALOR" )[2]	, PesqPict("NN7","NN7_VALOR") 	}) //"Valor Previsao (A)"
    aAdd(_aFldsGrd2, /* 16 */{STR0018 , "SOMAPVRA"	, TamSX3("E1_SALDO" )[3]	, TamSX3("E1_SALDO" )[1]  , TamSX3("E1_SALDO" )[2]	, PesqPict("SE1","E1_SALDO") 	})          //"Vinculado (B)"    
   
    If cAction =="1" //Vincular
        aAdd(_aFldsGrd2, /* 15 */{STR0019 , "PSOMAPVRA"	, TamSX3("E1_SALDO" )[3]	, TamSX3("E1_SALDO" )[1]  , TamSX3("E1_SALDO" )[2]	, PesqPict("SE1","E1_SALDO") 	}) //"Parcial Vinculado (D)"       
    EndIf
    
	aAdd(_aFldsGrd2, /* 16 */{AgrTitulo("NJR_CTREXT") , "NJR_CTREXT", TamSX3("NJR_CTREXT")[3]	, TamSX3("NJR_CTREXT")[1] , TamSX3("NJR_CTREXT" )[2], PesqPict("NJR","NJR_CTREXT") 	})	
	aAdd(_aFldsGrd2, /* 08 */{AgrTitulo("E1_NUM") 	  , "NUMERO"	, TamSX3("E1_NUM" )[3]		, TamSX3("E1_NUM" )[1]	  , TamSX3("E1_NUM" )[2]	, PesqPict("SE1","E1_NUM") 		})	
	aAdd(_aFldsGrd2, /* 19 */{AgrTitulo("NN7_ITEM")	  , "NN7_ITEM"	, TamSX3("NN7_ITEM" )[3]	, TamSX3("NN7_ITEM" )[1]  , TamSX3("NN7_ITEM" )[2]	, PesqPict("NN7","NN7_ITEM") 	})
	aAdd(_aFldsGrd2, /* 20 */{AgrTitulo("E1_PARCELA") , "PARCELA"   , TamSX3("E1_PARCELA" )[3]	, TamSX3("E1_PARCELA" )[1], TamSX3("E1_PARCELA" )[2], "##" 	})	    
	aAdd(_aFldsGrd2, /* 18 */{AgrTitulo("N9I_CODPRO") , "B1_DESC"   , TamSX3("B1_DESC" )[3]	    , TamSX3("B1_DESC" )[1]   , TamSX3("B1_DESC" )[2]   , PesqPict("SB1" ,"B1_DESC") 	})      

	aAdd(_aFldsGrd2, /* 16 */{AgrTitulo("NJR_CODCTR") , "NJR_CODCTR", TamSX3("NJR_CODCTR")[3]	, TamSX3("NJR_CODCTR")[1] , TamSX3("NJR_CODCTR" )[2], PesqPict("NJR","NJR_CODCTR") 	})
    aAdd(_aFldsGrd2, /* 17 */{AgrTitulo("NJR_CODSAF") , "NJR_CODSAF", TamSX3("NJR_CODSAF") [3]	, TamSX3("NJR_CODSAF")[1] , TamSX3("NJR_CODSAF") [2], PesqPict("NJR","NJR_CODSAF")	})
        
    // Moeda
    aAdd(_aFldsGrd2, /* 04 */{AgrTitulo("NN7_MOEDA")   , "MOEDA"	, TamSX3("NN7_MOEDA" )[3]	, TamSX3("NN7_MOEDA" )[1]  , TamSX3("NN7_MOEDA" )[2]	, PesqPict("NN7","NN7_MOEDA") 	})  
    // Documento
    aAdd(_aFldsGrd2, /* 06 */{AgrTitulo("E1_PREFIXO") , "PREFIXO", TamSX3("E1_PREFIXO" )[3]	, TamSX3("E1_PREFIXO" )[1], TamSX3("E1_PREFIXO" )[2], PesqPict("SE1","E1_PREFIXO") 	})
    aAdd(_aFldsGrd2, /* 07 */{AgrTitulo("E1_TIPO") 	  , "TIPO"	,     TamSX3("E1_TIPO" )[3]		, TamSX3("E1_TIPO" )[1]	  , TamSX3("E1_TIPO" )[2]	, PesqPict("SE1","E1_TIPO") 	})
    
	// Cliente
    aAdd(_aFldsGrd2, /* 01 */{AgrTitulo("NJ0_CODCLI") , "COD_CLIE", TamSX3("NJ0_CODCLI" )[3]	, TamSX3("NJ0_CODCLI")[1] , TamSX3("NJ0_CODCLI")[2]	, PesqPict("NJ0","NJ0_CODCLI") 	})
    aAdd(_aFldsGrd2, /* 02 */{AgrTitulo("NJ0_NOME")  ,  "NOME_CLIE"	, TamSX3("NJ0_NOME" )[3]	, TamSX3("NJ0_NOME" )[1] , TamSX3("NJ0_NOME" )[2]	, PesqPict("NJ0","NJ0_NOME") 	})  
    // Loja
    aAdd(_aFldsGrd2, /* 03 */{AgrTitulo("NJ0_LOJCLI") , "LOJA"	, TamSX3("NJ0_LOJCLI" )[3]	, TamSX3("NJ0_LOJCLI" )[1]  , TamSX3("NJ0_LOJCLI" )[2]	, PesqPict("NJ0","NJ0_LOJCLI") 	})  
       
    // Definicao de campo chave com o tamanho dos campos que compoe a chave mais os caracteres de separação que totalizam 4 '/'
    aAdd(_aFldsGrd2, /* 21 */{STR0020, "CHAVESE1", "C", (TamSX3("E1_TIPO" )[1]+TamSX3("E1_PREFIXO" )[1]+TamSX3("E1_NUM" )[1]+TamSX3("E1_PARCELA" )[1]+TamSX3("NN7_FILORG" )[1]+TamSX3("E1_LOJA" )[1]) + 5, TamSX3("E1_TIPO" )[2], "@!" }) //"Chave"        
    
    _aFields2 := {}
    For nIt := 1  to Len(_aFldsGrd2)
    	aAdd(_aFields2, {_aFldsGrd2[nIt][2], _aFldsGrd2[nIt][3], _aFldsGrd2[nIt][4], _aFldsGrd2[nIt][5]})
    Next nIt    

    /* CAMPOS NÃO APRESENTADOS NA GRID DA PREVISAO*/
    aAdd(_aFields2, { "NJR_FILIAL", TamSX3("NJR_FILIAL" )[3]	, TamSX3("NJR_FILIAL" )[1], TamSX3("NJR_FILIAL" )[2] })    
    aAdd(_aFields2, { "NN7_PARCEL", TamSX3("NN7_PARCEL" )[3]	, TamSX3("NN7_PARCEL" )[1], TamSX3("NN7_PARCEL" )[2] })
    
Return

/*{Protheus.doc} OGC120CGRV
//Trata a gravacao das acoes de Vincular e Desvincular.
@author roney.maia / marcelo.ferrari / Marcos.wagner
@since 16/05/2018
@version 1.0
@return ${return}, ${.T. - Valido / .F. - Invalido}
@Param cAction, char, indica a ação 1: Vincular / 2:Desvincular
@type function
*/
Function OGC120CGRV(cAction)
    Local aAreaN9G      := N9G->(GetArea())
    Local aAreaNN7      := NN7->(GetArea())
    Local lRet          := .T.
	Local cKeyCtrNN7    := ""
	Local lAchou        := .F.
	Local lDesvinc      := .F.
    Local aRetorno      := {}	
    Local nVlrComp      := 0
    Local nValPrev      := 0
    Local cMsg          := ""
    Local lContinua     := .T.    
    Local nVlrVinc      := 0
    Local aChave        := {}    
    Local nValComp      := 0
    Local nValDesv      := 0    
    Local nValBaixa     := 0
    
    // ##### REALIZA A GRAVACAO COMda BASE NOS BROWSERS E ALIAS POSICIONADOS COM USO DE VARIAVEIS PRIVADAS A PARTIR DO FONTE OGC120 #####
    BEGIN TRANSACTION 
        (_cAliaBrw2)->(dbGoTop())
        While !(_cAliaBrw2)->(Eof()) .AND. lRet
            If !Empty((_cAliaBrw2)->CHAVESE1) .and. (_cAliaBrw2)->MARK == "1"						
                //validação para nao permitir vinculo entre titulo com moeda diferentes.
				//não é possivel realizar conversao devido nao saber qual cotação usar
				If (_cAliaBrw1)->MOEDA <> (_cAliaBrw2)->MOEDA
					MsgInfo(STR0047)  //"Não é permitido vinculo de títulos com Moedas diferentes."
					lRet := .F.
					exit
				EndIf

				aChave := StrToKArr2( (_cAliaBrw2)->CHAVESE1, "/", .T.  ) //Dados RA Vínculado

                N9G->(dbGoTop())
                cKeyCtrNN7 := FwXFilial("N9G") + (_cAliaBrw2)->NJR_CODCTR+(_cAliaBrw2)->NN7_ITEM+(_cAliaBrw2)->PARCELA

                //Cria ponto de entrada validação vínculo/desvinculo
                If ExistBlock("OGC120CVLD")                    
                    Iif (cAction == "1", nVlrVinc := (_cAliaBrw2)->PSOMAPVRA, nVlrVinc := (_cAliaBrw2)->SOMAPVRA) 
                    aDadosPR := {(_cAliaBrw2)->NJR_FILIAL,  ; //[01] Filial do contrato
                                 (_cAliaBrw2)->NJR_CODCTR,  ; //[02] Código do Contrato
                                 (_cAliaBrw2)->NN7_ITEM,    ; //[03] Item da previsão financeira
                                 (_cAliaBrw2)->NN7_PARCEL,  ; //[04] Parcela da previsão financeira                                                                  
                                 nVlrVinc                   } //[05] Valor informado para vínculo/desvínculo                                                                   
                                
                    lContinua := ExecBlock("OGC120CVLD",.F.,.F.,{ cAction, aDadosPR, aChave})
                    If ValType( lContinua ) == "L"
                        If !lContinua
                            lRet := .F.
                            exit
                        EndIf
                    EndIf	
                EndIf              
				

                If cAction == "1"	                   
                    nSaldoRa := (_cAliaBrw1)->VALOR - (_cAliaBrw2)->PSOMAPVRA                        
                    nValor   := (_cAliaBrw2)->PSOMAPVRA
                    nVlrComp := (_cAliaBrw2)->PSOMAPVRA 
                    aDadosN9G := {(_cAliaBrw2)->NJR_CODCTR,(_cAliaBrw2)->NN7_ITEM,(_cAliaBrw2)->PARCELA,nSaldoRa,nValor, nVlrComp}
                    nValBaixa := 0
                        
                    //Posiciona no primeiro registro da N9G para o contrato/Item/Parcela
                    lAchou := .F.
                    If (N9G->(DbSeek( cKeyCtrNN7 )))
                        //Varre os registros da N9G em busca de algum relacionamento existente de RAxPV
                        While !(N9G->(Eof())) .AND.( (_cAliaBrw2)->NJR_CODCTR  == N9G->N9G_CODCTR  .AND. ;
                                                    (_cAliaBrw2)->NN7_ITEM   == N9G->N9G_ITEMPV  .AND. ;
                                                    (_cAliaBrw2)->PARCELA == N9G->N9G_PARPV   .AND. ;
                                                    AllTrim(N9G->N9G_TPOPER) == 'RAxPV')         .AND. ;
                                                    !lAchou
    
                            //Verifica se o Relacionamento existente é para o mesmo titulo de RA
                            If (alltrim(N9G->N9G_TIPO)   == alltrim(aChave[1]) .AND. ;
                                alltrim(N9G->N9G_PREFIX) == alltrim(aChave[2]) .AND. ;
                                alltrim(N9G->N9G_NUM)    == alltrim(aChave[3]) .AND. ;
                                alltrim(N9G->N9G_PARTT)  == alltrim(aChave[4]) .AND. ;
                                alltrim(N9G->N9G_FILTIT) == alltrim(aChave[5]) ) .OR. ;
                                (Empty(N9G->N9G_TIPO+N9G->N9G_PREFIX+N9G->N9G_NUM+N9G->N9G_PARTT+N9G->N9G_FILTIT))
                                
                                lAchou := .T.
                                Exit  //Sai do Laço no registro corrente da N9G
                            EndIf
                            N9G->(dbSkip())
                        EndDo
                    EndIf

                    If !(lAchou)
                        //Insere um registro na N9G com o valor máximo permitido até o limite do saldo da RA
                        If nSaldoRa >= 0 .AND. RecLock("N9G", .T.)
                            N9G->N9G_FILIAL     := FwXfilial("N9G")
                            N9G->N9G_CODCTR     := (_cAliaBrw2)->NJR_CODCTR
                            N9G->N9G_ITEMPV     := (_cAliaBrw2)->NN7_ITEM
                            N9G->N9G_PARPV      := (_cAliaBrw2)->PARCELA
                            N9G->N9G_TIPO       := aChave[1]
                            N9G->N9G_PREFIX     := aChave[2]
                            N9G->N9G_NUM        := aChave[3]
                            N9G->N9G_PARTT      := aChave[4]
                            N9G->N9G_FILTIT     := aChave[5]
                            N9G->N9G_TPOPER     := "RAxPV"
                            N9G->N9G_VALOR      := nValor
                            N9G->(MsUnlock())
                        Else
                            MsgInfo(STR0001)  //"Se a coluna 'Saldo Previsão' for menor que zero então não deve gravar os vinculos. Ajustar para q fique >= 0"
                            lRet := .F.
                            Exit
                        EndIf
                    Else
                        //Atualiza o registro corrente da N9G com o valor marcado
                        nSaldoRa := (_cAliaBrw1)->VALOR - (_cAliaBrw2)->PSOMAPVRA                        
                        nValor   := (_cAliaBrw2)->PSOMAPVRA + N9G->N9G_VALOR
                        nVlrComp := (_cAliaBrw2)->PSOMAPVRA                         

                        If nSaldoRa >= 0 
                            RecLock("N9G", .F.)
                                N9G->N9G_TIPO   := aChave[1]
                                N9G->N9G_PREFIX := aChave[2]
                                N9G->N9G_NUM    := aChave[3]
                                N9G->N9G_PARTT  := aChave[4]
                                N9G->N9G_FILTIT := aChave[5]
                                N9G->N9G_TPOPER := "RAxPV"
                                N9G->N9G_VALOR  := nValor
                            N9G->(MsUnlock())
                        Else    
                            MsgInfo(STR0001)  //"Se a coluna 'Saldo Previsão' for menor que zero então não deve gravar os vinculos. Ajustar para q fique >= 0"
                            lRet := .F.
                            Exit
                        EndIf
                    EndIf                    
                    
                    If lRet
                        If !fAtuN84((_cAliaBrw2)->NJR_CODCTR,(_cAliaBrw2)->NN7_ITEM,"V")
                            lRet := .F.
                            Exit
                        EndIf
                        
                        fBaixNFXRA(aChave, @nValBaixa)                        

                        //realiza a baixa da PR ao vincular com a RA, diminui o saldo e incrementa o valor do campo NN7_VLCOMP - Valor compensado
                        OGX018ASLD(FwxFilial("NN7"), (_cAliaBrw2)->NJR_CODCTR, (_cAliaBrw2)->NN7_ITEM, (_cAliaBrw2)->PARCELA, ;
                                { {"NN7_VLRAVI", (_cAliaBrw2)->PSOMAPVRA, "SOMA"},  ;
                                {"NN7_VLTNCO",  nValBaixa               , "SUBT"},  ;					
                                {"NN7_VLCOMP",  nVlrComp - nValBaixa    , "SOMA"},  ; //desconsidera o valor que foi baixado
                                {"NN7_VLSALD",  nVlrComp - nValBaixa    , "SUBT"},  ; //desconsidera o valor que foi baixado
                                {"NN7_STSTIT",  "2"                     , "ATU" }   ;
                                })
                    EndIf

                ElseIf cAction == "2"                 
                   aChave := StrToKArr2( (_cAliaBrw2)->CHAVESE1, "/", .T.  )
                    
                    //monta a chave para estorno de dados
                    cChaveN9G :=  xFilial("N9G") + (_cAliaBrw2)->NJR_CODCTR + (_cAliaBrw2)->NN7_ITEM + (_cAliaBrw2)->PARCELA + aChave[3] + SUBSTR(aChave[4],1,2) + aChave[2] + aChave[1] + "RAxPV" 		

                    //posiciona novamente - execauto desposicionar...
                    N9G->(dbSetOrder(1))				
                    If N9G->(DbSeek(cChaveN9G))
                        nValComp := fGetVlComp((_cAliaBrw2)->NJR_CODCTR, ;
                                               (_cAliaBrw2)->NN7_ITEM,   ;                                               
                                               (_cAliaBrw1)->TIPO,       ;
                                               (_cAliaBrw1)->PREFIXO,    ;
                                               (_cAliaBrw1)->NUMERO,     ;
                                               (_cAliaBrw1)->PARCELA,    ;
                                               (_cAliaBrw1)->FILIAL)                        
                        
                        If nValComp > 0 .and. N9G->N9G_VALOR - nValComp > 0
                            cMsg := STR0061 +__CRLF+__CRLF+; //A remoção do vínculo será parcial, pois existem títulos baixados.
                                    STR0023 +" "+(_cAliaBrw2)->NJR_CODCTR +__CRLF+; //Contrato:
                                    STR0024 +" "+(_cAliaBrw2)->NN7_ITEM +__CRLF+; //Item Prev:
                                    STR0062 +transform(nValComp, "@E 9,999,999.99") +__CRLF+; //"Valor dos títulos compensados: "
                                    STR0063 +transform(N9G->N9G_VALOR - nValComp, "@E 9,999,999.99") +__CRLF+__CRLF+;
                                    STR0064 //"Deseja continuar?"
                            
                            If !MsgYesNo(cMsg, STR0032)
                                lRet := .F.
                            EndIf                       
                        EndIf

                        If lRet
                            nValDesv := N9G->N9G_VALOR - nValComp                        

                            Iif(N9G->N9G_VALOR > nValDesv, lTotal := .f., lTotal := .t.)

                            if RecLock("N9G", .F.)
                                iif(!lTotal, N9G->N9G_VALOR := N9G->N9G_VALOR - nValDesv, N9G->(dbDelete()))                            
                                N9G->(MsUnlock())
                            endif
                            aRetorno := {.t., nValDesv}
                        Else
                            aRetorno := {.f., 0}
                        EndIf
                    Else
                        //NÃO ENCONTROU O REGISTRO DA RA VINCULADA na SE1 
                        //Remover todo o Vinculo
                        aRetorno := {.f., N9G->N9G_VALOR }
                        if RecLock("N9G", .F.)
                            N9G->(dbDelete())
                            N9G->(MsUnlock())
                        endif
                    EndIf
                    
                    if aRetorno[1] //se o processo de remoção ocorreu corretamente                     	
                     	lDesvinc := .t.
	                    If aRetorno[2] > 0 // se o valor estornado é maior que 0                                                          
	                        //ajusta saldos da Previsão Financeira
	                        OGX018ASLD(FwxFilial("NN7"), (_cAliaBrw2)->NJR_CODCTR, (_cAliaBrw2)->NN7_ITEM, (_cAliaBrw2)->PARCELA, ;
				                        { {"NN7_VLRAVI",  aRetorno[2]               , "SUBT"},  ;
				                          {"NN7_VLCOMP",  aRetorno[2]               , "SUBT"},  ;                                                               
				                          {"NN7_STATUS",  "1"                      , "SUBT"}   ;                                                               
				                        })				
	
	                        //realiza a baixa da PR ao vincular com a RA, diminui o saldo e incrementa o valor do campo NN7_VLCOMP - Valor compensado
	                        If NN7->(DbSeek(FwxFilial("NN7") + (_cAliaBrw2)->NJR_CODCTR + (_cAliaBrw2)->NN7_ITEM + (_cAliaBrw2)->PARCELA))                                
	                            If ALLTRIM(NN7->NN7_TIPEVE) != "1"
	                                nValPrev := NN7->NN7_VALOR - (NN7->NN7_VLRAVI + NN7_VLTNCO)
	                                OGX018ASLD(FwxFilial("NN7"), NN7->NN7_CODCTR, NN7->NN7_ITEM, NN7->NN7_PARCEL, {{"NN7_VLSALD",  nValPrev, "ATU"}, {"NN7_STSTIT", "2", "ATU"}})                            
	                            EndIf                                    
	                        EndIf 
	                    Else
	                        cMsg := STR0022 + __CRLF //Previsão possui todo seu valor compensado. Não é possível remover os vínculos.
	                        cMsg += STR0023 +  (_cAliaBrw2)->NJR_CODCTR + __CRLF //Contrato
	                        cMsg += STR0024 +  (_cAliaBrw2)->NN7_ITEM   + __CRLF //"Item Prev: "
	                        MsgInfo(cMsg)
	                        lRet := .f.
	                        lDesvinc := .F. //coloca pra falso para nao exibir mensagens
	                        Exit                                
	                    EndIf  
	                else 
	                    lRet := .f.
	                    lDesvinc := .F. //coloca pra falso para nao exibir mensagens
                    endif       

                    If lRet
                        If !fAtuN84((_cAliaBrw2)->NJR_CODCTR,(_cAliaBrw2)->NN7_ITEM,"D")
                            lRet := .F.
                            Exit
                        EndIf                            
                    EndIf
                EndIf            

                //chama a função que varre a NN7 toda e reajusta os titulos provisórios. deve ser no while devido o contrato ser diferente nos registros
                If lRet
                    aRetorno := OGX018ATPR(FWxfilial("NJR"), (_cAliaBrw2)->NJR_CODCTR, "OGC120")

                    If !aRetorno[1,1]
                        MsgInfo(aRetorno[1,2])
                        lRet := .f.
                        lDesvinc := .F. //coloca pra falso para nao exibir mensagens
                        Exit                                
                    EndIf                
                EndIf

            EndIf
           
            (_cAliaBrw2)->(dbSkip())
        EndDo

        If !lRet 
            DisarmTransaction()
            Break
        EndIf

    END TRANSACTION

    If lDesvinc 
		MsgInfo(STR0002) //"Vínculos retirados com sucesso."
	Endif
    RestArea(aAreaNN7)
    RestArea(aAreaN9G)

Return lRet

/*{Protheus.doc} OGC120CPAR
//Função de insercao e validacao 
do vinculo parcial.
@author roney.maia
@since 24/04/2018
@version 1.0
@type function
*/
Function OGC120CPAR()

    Local aArea         := GetArea()
    Local oSize         := Nil
    Local oMStru        := FwFormModelStruct():New()
    Local oVStru        := FwFormViewStruct():New()
    Local oModel        := FwFormModel():New("OGC120CPAR", , , {|| .T.}, {|| .T.}) // Instancia um modelo
    Local oView         := FwFormView():New() // Instancia uma View
    Local oViewExec     := FWViewExec():New() // Instancia um Executor de View
    Local aButtons 	    := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T., "Confirmar"},{.T., "Cancelar"},{.F., Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} // # "Confirmar" # "Cancelar"
	Local nWidth        := 0
    Local nHeight       := 0
    Local nValor        := 0    
	Local nValRA        := (_cAliaBrw1)->VALOR - (_cAliaBrw1)->PSOMAPVRA
	Local nValPF        := (_cAliaBrw2)->VALOR - (_cAliaBrw2)->SOMAPVRA
    Local bInit         := {|| Iif(nValPF > nValRA, nValRA, nValPF ) }
	
    oSize   := FwDefSize():New(.T.) // Considera a enchoice bar

	nWidth  := (oSize:AWINDSIZE[4] * 0.15) // 15% da largura total da tela
    nHeight := (oSize:AWINDSIZE[3] * 0.15) // 15% da altura total da tela

    oMStru:AddField(STR0011	                            ,;  	// [01] C Titulo do campo // # "Valor"
					STR0011	                            ,;   	// [02] C ToolTip do campo // # "Valor"
     				"VALORPARC" 		                ,;    	// [03] C identificador (ID) do Field
         			TamSX3("E1_VALOR" )[3] 		        ,;    	// [04] C Tipo do campo
            		TamSX3("E1_VALOR" )[1] 			    ,;    	// [05] N Tamanho do campo
              		TamSX3("E1_VALOR" )[2] 		        ,;    	// [06] N Decimal do campo
                	Nil                                 ,;    	// [07] B Code-block de validacao do campo
                 	Nil					                ,;     	// [08] B Code-block de validacao When do campo
                  	Nil 				                ,;    	// [09] A Lista de valores permitido do campo
                   	.T. 				                ,;  	// [10] L Indica se o campo tem preenchimento obrigatorio
                    bInit		                        ,;   	// [11] B Code-block de inicializacao do campo
                    Nil 				                ,;  	// [12] L Indica se trata de um campo chave
                    .T. )    	                                // [13] L Indica se o campo pode receber valor em uma operacaoo de update.

    oVStru:AddField("VALORPARC"	                        ,;  	// [01] C Id do Campo
					"01"	                            ,;   	// [02] C Ordem
     				STR0011 		                    ,;    	// [03] C Titulo do campo // # "Valor"
         			STR0012                         	,;    	// [04] C Descrição do campo // # "Valor de vinculo entre RA e PR"
            		{STR0012} 	                        ,;    	// [05] A Array com Help // # "Valor de vinculo entre RA e PR"
              		TamSX3("E1_VALOR" )[3] 				,;    	// [06] C Tipo do campo
                	PesqPict("SE1","E1_VALOR") 		    ,;    	// [07] C Picture
                 	Nil					                ,;     	// [08] B Bloco de Picture Var
                  	Nil 				                ,;    	// [09] C Consulta F3
                   	.T. 				                ,;  	// [10] L Indica se o campo é evitável
                    Nil		                            ,;   	// [11] C Pasta do campo
                    Nil 				                ,;  	// [12] C Agrupamento do campo
                    Nil 				                ,;     	// [13] A Lista de valores permitido do campo (Combo)
                    Nil                                 ,;      // [14] N Tamanho Maximo da maior opção do combo
                    Nil                                 ,;      // [15] C Inicializador de Browse
                    Nil                                 ,;      // [16] L Indica se o campo é virtual
                    Nil )                                       // [17] C Picture Variável


    oModel:SetDescription(STR0013) // Pré requisito para criação de uma view # Contato // # "Valor a vincular"
    oModel:AddFields("FIELDVPARC", , oMStru) // Pre requisito para criacao de uma view
    oModel:GetModel("FIELDVPARC"):SetDescription(STR0013) // # "Valor a vincular"
    oModel:SetPrimaryKey({"VALORPARC"})

    oView:SetModel(oModel)
    oView:AddField("VIEWVPARC", oVStru, "FIELDVPARC")

    oView:CreateHorizontalBox("BOXVIEWVPARC", 100)
    oView:SetOwnerView("VIEWVPARC", "BOXVIEWVPARC")

    oView:SetViewProperty("VIEWVPARC", "SETLAYOUT", {FF_LAYOUT_VERT_DESCR_TOP, 1}) // Seta o layout de forma vertical com 1 coluna
 
    oViewExec:SetView(oView)
    oViewExec:setOperation(MODEL_OPERATION_INSERT)
    oViewExec:SetButtons(aButtons)
    oViewExec:SetTitle(STR0013) // # "Valor a vincular"
    oViewExec:SetOk({|oVw| OGC120CPOK(oModel, @nValor, oView)})
    oViewExec:SetSize(nHeight, nWidth) // Dimensões da tela
  
    oViewExec:openView(.F.)

    RestArea(aArea)

Return nValor

/*{Protheus.doc} OGC120CPOK
//Confirmar da tela de vinculo parcial
@author roney.maia
@since 24/04/2018
@version 1.0
@return ${return}, ${.T. - Valido, .F. - Invalido}
@param oModel, object, Modelo da tela
@type function
*/
Static Function OGC120CPOK(oModel, nValor, oView)

    Local lRet      := .T.
    Local nValorAux := oModel:GetModel("FIELDVPARC"):GetValue("VALORPARC")

    If nValorAux < 0
        nValorAux := nValorAux * -1
    EndIf

    If (_cAliaBrw2)->MARK == "1" .AND. (AllTrim((_cAliaBrw2)->CHAVESE1) == AllTrim((_cAliaBrw1)->(TIPO+'|'+PREFIXO+'|'+NUMERO+'|'+PARCELA+'|'+FILIAL))) // Entao valida o desmarcar da previsao da Acao Vincular
        If (_cAliaBrw1)->PSOMAPVRA < nValorAux
            Help(" ",1,"OGC120CRAPR001") // # Valor informado é superior ao saldo disponível para a Ra. # Informar um valor igual ou inferior ao saldo disponível para a Ra.
            Return .F.
        EndIf
        If (_cAliaBrw2)->PSOMAPVRA < nValorAux
            Help(" ",1,"OGC120CRAPR002") // # Valor informado é superior ao saldo disponível para a previsão financeira. # Informar um valor igual ou inferior ao saldo disponível para a previsão financeira.
            Return .F.
        EndIf    
    EndIf

    nValor := nValorAux // Atribuicao de retorno da funcao

    lRet := .F. // Não remover essa variavel de retorno
    oView:SetModified(.F.) 
    oView:ButtonCancelAction()

Return lRet

/*{Protheus.doc} OGC120CUPD
//Atualiza temporarias dos browsers de vinculo e
desvinculo.
@author roney.maia
@since 28/05/2018
@version 1.0
@param cAction, character, 1 - Vincular , 2 - Desvincular 
@type function
*/
Static Function OGC120CUPD(cAction, lF11)

    Default lF11   := .f.

    //Primeira tabela temporária
    If _oOGC120RA != Nil // Se ja existe o objeto de tabela temporária, deleta o mesmo, fechando o alias utilizado
		_oOGC120RA:Delete()
	EndIf

	If select(_cAliaBrw1) > 0
        (_cAliaBrw1)->(dbCloseArea())
    EndIf    
    
	_oOGC120RA	:= AGRCRTPTB(_cAliaBrw1, {_aFields1, _aIndice} ) // Instancia a tabela temporária com o alias
	
    _cWhere2 := _cFiltro
	cQuery  := IIF(cAction == "1", fQryVincRA(lF11), fQryDesvRA(lF11)) //OGC120AQRY("1", cAction)
	OGC120BTMP(cQuery, _cAliaBrw1, _aFields1) // Monta e carrega a tabela temporária

	//Adiciona os campos do Grid de Previsão
	//Segunda tabela temporária
    If _oOGC120PR != Nil // Se ja existe o objeto de tabela temporária, deleta o mesmo, fechando o alias utilizado
		_oOGC120PR:Delete()
	EndIf
	
	If select(_cAliaBrw2) > 0
        (_cAliaBrw2)->(dbCloseArea())
    EndIf    
    
	_oOGC120PR	:= AGRCRTPTB( _cAliaBrw2, {_aFields2, _aIndice } ) // Instancia a tabela temporária com o alias
    
    cQuery2 :=  IIF(cAction == "1", fQryVincPR(lF11), fQryDesvPR(lF11)) 
    
    OGC120BTMP(cQuery2, _cAliaBrw2, _aFields2 ) // Monta e carrega a tabela temporária

    oBrowse1:SetAlias(_cAliaBrw1)
    oBrowse2:SetAlias(_cAliaBrw2)

    oBrowse1:UpdateBrowse()
    oBrowse2:UpdateBrowse()

    oBrowse2:GoColumn(1)

    OGC120Chng(cAction)
   
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fQryVincRA
Função responsável por montar a query de RA no browse de vínculo
@Param lF11 Boolean Indica se a chamada é da execução do filtro
@author  Rafael Voltz
@since   31/07/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function fQryVincRA(lF11)
  Local cQuery    := ""
  Local cWhere    := ""  
  Local cFiltroRA := ""
  Local cCliRa    := ""  
  Local aTipos    := {}
  Local cTipsTit  := SuperGetMv("MV_AGRO023", .F., "")  
  Local nIt       := 0
  
  Default lF11 := .F.

	DbSelectArea("NJR")
	NJR->(DbSetOrder(1)) // NJR_FILIAL+NJR_CODCTR
	If NJR->(DbSeek(xFilial("NN7")+_cContrato))
	    cCliRa  := Posicione('NJ0',1,xFilial('NJ0')+NJR->NJR_CODENT+NJR->NJR_LOJENT,'NJ0_CODCLI')   
	EndIf
	
    If !Empty(cTipsTit) // Verifica o conteudo dos tipos de titulo para atribuicao ao filtro
        aTipos := Separa(cTipsTit, ";")

        cFiltroRA += "AND ("
        For nIt := 1 To Len(aTipos)
            cFiltroRA +=  "SE1.E1_TIPO = '" +  AllTrim(aTipos[nIt])  + "' OR "
        Next nIt

        cFiltroRA := Substr(cFiltroRA, 1, Len(cFiltroRA) - 4) + ") "
    Else
        cFiltroRA += "AND SE1.E1_TIPO = 'RA' "
	EndIf

    //Não considera para vínculo as RAs criadas pelo painel
    cFiltroRA += " AND SE1.E1_PREFIXO != 'CTR'" 


    //Pergunte('OGC12003', .F.) // Filtro inicial

    
    If !Empty(cCliRa)
        cWhere += " AND SE1.E1_CLIENTE = '" + cCliRa + "' "
    EndIf

	cWhere += cFiltroRA

    cQuery := "    SELECT  E1_FILIAL  FILEMP,       "  
    cQuery += "            E1_FILORIG FILIAL,       "
	cQuery += "            E1_VENCTO  VENCIMENTO,   "
	cQuery += "            E1_EMISSAO EMISSAO,      "
    cQuery += "            E1_NUM     NUMERO,       "
    cQuery += "            E1_PARCELA PARCELA,      "    
    cQuery += "            E1_SALDO   VALOR,        "
	cQuery += "            E1_TIPO    TIPO,         "
    cQuery += "            E1_PREFIXO PREFIXO,      "
    cQuery += "            E1_MOEDA   MOEDA,        "   
    cQuery += "            E1_CLIENTE COD_CLIE,     "
	cQuery += "            E1_NOMCLI  NOME_CLIE,    "
	cQuery += "            E1_LOJA    LOJA         "
    cQuery += "    FROM "  + RetSqlName("SE1") + " SE1 "
    cQuery += "    LEFT JOIN "  + RetSqlName("N9G") + " N9G ON SE1.E1_FILORIG = N9G.N9G_FILTIT "
    cQuery += "          AND N9G.N9G_PREFIX = SE1.E1_PREFIXO "
    cQuery += "          AND N9G.N9G_TIPO   = SE1.E1_TIPO    "
    cQuery += "          AND N9G.N9G_NUM    = SE1.E1_NUM     "
    cQuery += "          AND N9G.N9G_PARTT  = SE1.E1_PARCELA "    
    cQuery += "          AND N9G.D_E_L_E_T_ = ''        "  
    If !_lFilExcl //Se filial nao for exclusiva eu uso apenas a empresa
		cQuery += "    WHERE SE1.E1_FILIAL = '"+ Alltrim(xFilial("SE1",_FilOrgPR)) + "' "
	Else
		cQuery += "    WHERE SE1.E1_FILIAL = '"+ _FilOrgPR + "' "
	Endif
    cQuery += "      AND SE1.D_E_L_E_T_ = '' "		
    cQuery += cWhere
	cQuery += "    GROUP BY SE1.E1_FILIAL, "
	cQuery += "             SE1.E1_FILORIG,  "
    cQuery += "             SE1.E1_CLIENTE,  "
    cQuery += "             SE1.E1_NOMCLI,   "
    cQuery += "             SE1.E1_LOJA,     "
    cQuery += "             SE1.E1_VENCTO,   "
    cQuery += "             SE1.E1_EMISSAO,  "
    cQuery += "             SE1.E1_MOEDA,    "
    cQuery += "             SE1.E1_TIPO,     "
    cQuery += "             SE1.E1_PREFIXO,  "
    cQuery += "             SE1.E1_NUM,      "
    cQuery += "             SE1.E1_PARCELA,  "
    cQuery += "             SE1.E1_VALOR,    "
    cQuery += "             SE1.E1_SALDO     "
    cQuery += "    HAVING (SE1.E1_SALDO - ISNULL(SUM(N9G.N9G_VALOR), 0)) > 0 "
    cQuery += "    ORDER BY E1_FILORIG,"
    cQuery += "             E1_CLIENTE ,"
    cQuery += "             E1_NOMCLI ,"
    cQuery += "             E1_LOJA   ,"
    cQuery += "             E1_VENCTO "    
    
	cQuery := ChangeQuery(cQuery)
		
Return cQuery


//-------------------------------------------------------------------
/*/{Protheus.doc} fQryVincPR
Função responsável por montar a query de PR no browse vinculo
@Param lF11 Boolean Indica se a chamada é da execução do filtro
@author  Rafael Voltz
@since   31/07/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function fQryVincPR(lF11)
  Local cQuery  := ""
  Local cWhere  := ""
  Local cCliPrv := ""  
  Default lF11 := .F.

	DbSelectArea("NJR")
	NJR->(DbSetOrder(1)) // NJR_FILIAL+NJR_CODCTR
	If NJR->(DbSeek(xFilial("NN7")+_cContrato))
	   cCliPrv  := Posicione('NJ0',1,xFilial('NJ0')+NJR->NJR_CODENT+NJR->NJR_LOJENT,'NJ0_CODCLI')   	 
	EndIf    
    
	If !Empty(cCliPrv)
        cWhere += "AND NJ0.NJ0_CODCLI = '" + cCliPrv + "' "            
    EndIf

    cQuery := " SELECT DISTINCT NN7.NN7_FILORG  FILIAL,     "
    cQuery += "                 NJ0.NJ0_CODCLI  COD_CLIE,   "
    cQuery += "                 NJ0.NJ0_NOME    NOME_CLIE,  "
    cQuery += "                 NJ0.NJ0_LOJCLI  LOJA,       "
    cQuery += "                 NJR.NJR_FILIAL  NJR_FILIAL, "
    cQuery += "                 NJR.NJR_CODCTR  NJR_CODCTR, "
    cQuery += "                 NJR.NJR_CTREXT  NJR_CTREXT, "    
    cQuery += "                 SB1.B1_DESC     B1_DESC,    "
    cQuery += "                 NJR.NJR_CODSAF  NJR_CODSAF, "
    cQuery += "                 NN7.NN7_DTVENC  VENCIMENTO, "
    cQuery += "                 NN7.NN7_MOEDA   MOEDA,      "
    cQuery += "                 'PR'            TIPO,       "
    cQuery += "                 'CTR'           PREFIXO,    "
    cQuery += "                 NN7.NN7_CODCTR  NUMERO,     "
    cQuery += "                 NN7.NN7_PARCEL  PARCELA,    "
    cQuery += "                 NN7.NN7_ITEM    NN7_ITEM,   "                                                  
    cQuery += "                 NN7.NN7_VALOR   VALOR,      "
    cQuery += "                 NN7.NN7_VLRAVI  SOMAPVRA  "
    cQuery += "      FROM "  + RetSqlName("NJR") + " NJR     "
    cQuery += "INNER JOIN "  + RetSqlName("NN7") + " NN7 ON NN7.NN7_FILIAL = NJR.NJR_FILIAL "
    cQuery += "       AND NN7.NN7_CODCTR = NJR.NJR_CODCTR    "
    cQuery += "       AND NN7.D_E_L_E_T_ = ''                "
    cQuery += "INNER JOIN "  + RetSqlName("NJ0") + " NJ0 ON NJ0.NJ0_FILIAL = '"+ xFilial("NJ0") + "' "
    cQuery += "       AND NJ0.NJ0_CODENT = NJR.NJR_CODENT "
    cQuery += "       AND NJ0.NJ0_LOJENT = NJR.NJR_LOJENT "
    cQuery += "       AND NJ0.D_E_L_E_T_ = '' "    
	cQuery +=  "  INNER JOIN " + RetSqlName('SB1')+ " SB1 ON SB1.B1_FILIAL = '" +  xFilial('SB1') +  "'"
	cQuery +=  "    AND SB1.B1_COD     = NJR.NJR_CODPRO "      
	cQuery +=  "    AND SB1.D_E_L_E_T_ = '' " 
    cQuery += "     WHERE NJR.NJR_FILIAL = '"+ xFilial("NJR") + "' "
	If !_lFilExcl //Se filial nao for exclusiva eu uso apenas a empresa
		cQuery += "    AND SUBSTRING(NN7.NN7_FILORG,1,2) = '"+  Alltrim(xFilial("SE1",_FilOrgPR)) + "' "
	Else
		cQuery += "    AND NN7.NN7_FILORG = '"+ _FilOrgPR + "' "
	Endif
    cQuery +=       " AND NN7.NN7_VALOR > 0 " //traz somente valor maior que zero 	
	cQuery +=  cWhere
    cQuery += "       AND NJR.D_E_L_E_T_ = ''  "           
    cQuery += "       AND NJR.NJR_STATUS IN ('A','I','F')  "           
    cQuery +=       " AND (NN7.NN7_VLSALD > 0 OR NN7.NN7_VLRAVI < NN7.NN7_VLTEMI) "     
	cQuery +=       " AND NN7.NN7_DTVENC <= '" + dtos(_dDataVenc) + "' "
    cQuery += "  ORDER BY NN7.NN7_FILORG , "
	cQuery +=           " NN7.NN7_DTVENC , "
    cQuery +=           " NJ0.NJ0_CODCLI , "
    cQuery +=           " NJ0.NJ0_NOME   , "
    cQuery +=           " NJ0.NJ0_LOJCLI , "
    cQuery +=           " NJR.NJR_FILIAL , "
    cQuery +=           " NJR.NJR_CODCTR , "
    cQuery +=           " NJR.NJR_CTREXT , "    
    cQuery +=           " SB1.B1_DESC    , "
    cQuery +=           " NJR.NJR_CODSAF , "   
    cQuery +=           " NN7.NN7_MOEDA    "   
            
    cQuery := ChangeQuery(cQuery)

Return cQuery    

//-------------------------------------------------------------------
/*/{Protheus.doc} fQryDesvRA
Função responsável por montar a query de RA no browse de desvinculo
@Param lF11 Boolean Indica se a chamada é da execução do filtro
@author  Rafael Voltz
@since   31/07/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function fQryDesvRA(lF11)
  Local cQuery    := ""
  Local cWhere    := ""
  Local cCliRa    := ""

  Default lF11 := .F.

 	DbSelectArea("NJR")
	NJR->(DbSetOrder(1)) // NJR_FILIAL+NJR_CODCTR
	If NJR->(DbSeek(xFilial("NN7")+_cContrato))
	    cCliRa  := Posicione('NJ0',1,xFilial('NJ0')+NJR->NJR_CODENT+NJR->NJR_LOJENT,'NJ0_CODCLI')   
	EndIf

    //Pergunte('OGC12003', .F.) // Filtro inicial

     If !Empty(cCliRa)
        cWhere += " AND SE1.E1_CLIENTE = '" + cCliRa + "' "        
    EndIf

	cQuery := "    SELECT  E1_FILIAL  FILEMP,       "  
    cQuery += "            E1_FILORIG FILIAL,       "
    cQuery += "            E1_CLIENTE COD_CLIE,     "
    cQuery += "            E1_NOMCLI  NOME_CLIE,    "    
    cQuery += "            E1_LOJA    LOJA,         "
    cQuery += "            E1_VENCTO  VENCIMENTO,   "
    cQuery += "            E1_EMISSAO EMISSAO,      "
    cQuery += "            E1_MOEDA   MOEDA,        "
    cQuery += "            E1_TIPO    TIPO,         "
    cQuery += "            E1_PREFIXO PREFIXO,      "
    cQuery += "            E1_NUM     NUMERO,       "
    cQuery += "            E1_PARCELA PARCELA,      "    
    cQuery += "            E1_VALOR   VALOR         "    
    cQuery += "    FROM "  + RetSqlName("SE1") + " SE1 "
    cQuery += "    INNER JOIN "  + RetSqlName("N9G") + " N9G ON SE1.E1_FILORIG = N9G.N9G_FILTIT "
    cQuery += "          AND N9G.N9G_PREFIX = SE1.E1_PREFIXO "
    cQuery += "          AND N9G.N9G_TIPO   = SE1.E1_TIPO    "
    cQuery += "          AND N9G.N9G_NUM    = SE1.E1_NUM     "
    cQuery += "          AND N9G.N9G_PARTT  = SE1.E1_PARCELA "      
    cQuery += "          AND N9G.D_E_L_E_T_ = ''        "
    cQuery += "    WHERE SE1.E1_FILIAL = '"+ xFilial("SE1") + "' "
    cQuery += "      AND SE1.D_E_L_E_T_ = '' "
    cQuery += cWhere
	cQuery += "      AND SE1.E1_TIPO = 'RA' "	
	cQuery += "      AND N9G.N9G_ITEMPV =  '" + _cItemPF + "'" 
	cQuery += "      AND N9G.N9G_CODCTR =  '" + _cContrato + "'" 
    cQuery += "    GROUP BY SE1.E1_FILIAL, "
	cQuery += "             SE1.E1_FILORIG,  "
    cQuery += "             SE1.E1_CLIENTE,  "
    cQuery += "             SE1.E1_NOMCLI,   "
    cQuery += "             SE1.E1_LOJA,     "
    cQuery += "             SE1.E1_VENCTO,   "
    cQuery += "             SE1.E1_EMISSAO,  "
    cQuery += "             SE1.E1_MOEDA,    "
    cQuery += "             SE1.E1_TIPO,     "
    cQuery += "             SE1.E1_PREFIXO,  "
    cQuery += "             SE1.E1_NUM,      "
    cQuery += "             SE1.E1_PARCELA,  "
    cQuery += "             SE1.E1_VALOR,    "
    cQuery += "             SE1.E1_SALDO     "    
    cQuery += "    ORDER BY E1_FILORIG,"
    cQuery += "             E1_CLIENTE ,"
    cQuery += "             E1_NOMCLI ,"
    cQuery += "             E1_LOJA   ,"
    cQuery += "             E1_VENCTO "    
    
    cQuery := ChangeQuery(cQuery)

Return cQuery


//-------------------------------------------------------------------
/*/{Protheus.doc} fQryDesvPR
Função responsável por montar a query de PR no browse desvinculo
@Param lF11 Boolean Indica se a chamada é da execução do filtro
@author  Rafael Voltz
@since   31/07/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function fQryDesvPR(lF11)
  Local cQuery  := ""
  Local cWhere  := ""
  Local cCliPrv := ""
  
  Default lF11 := .F.

    DbSelectArea("NJR")
	NJR->(DbSetOrder(1)) // NJR_FILIAL+NJR_CODCTR
	If NJR->(DbSeek(xFilial("NN7")+_cContrato))
	   cCliPrv  := Posicione('NJ0',1,xFilial('NJ0')+NJR->NJR_CODENT+NJR->NJR_LOJENT,'NJ0_CODCLI')   	  
	EndIf
   
    If !Empty(cCliPrv)
        cWhere += "AND NJ0.NJ0_CODCLI = '" + cCliPrv + "' "        
    EndIf

    cQuery := " SELECT DISTINCT NN7.NN7_FILORG  FILIAL,     "
    cQuery += "                 NJ0.NJ0_CODCLI  COD_CLIE,   "
    cQuery += "                 NJ0.NJ0_NOME    NOME_CLIE,  "
    cQuery += "                 NJ0.NJ0_LOJCLI  LOJA,       "
    cQuery += "                 NJR.NJR_FILIAL  NJR_FILIAL, "
    cQuery += "                 NJR.NJR_CODCTR  NJR_CODCTR, "
    cQuery += "                 NJR.NJR_CTREXT  NJR_CTREXT, "    
    cQuery += "                 SB1.B1_DESC     B1_DESC,    "
    cQuery += "                 NJR.NJR_CODSAF  NJR_CODSAF, "
    cQuery += "                 NN7.NN7_DTVENC  VENCIMENTO, "
    cQuery += "                 NN7.NN7_MOEDA   MOEDA,      "
    cQuery += "                 'PR'            TIPO,       "
    cQuery += "                 'CTR'           PREFIXO,    "
    cQuery += "                 NN7.NN7_CODCTR  NUMERO,     "
    cQuery += "                 NN7.NN7_PARCEL  PARCELA,    "
    cQuery += "                 NN7.NN7_ITEM    NN7_ITEM,   "    
    cQuery += "                 (N9G_TIPO||'/'||N9G_PREFIX||'/'||N9G_NUM||'/'||N9G_PARTT||'/'||N9G_FILTIT) CHAVESE1, "
    cQuery += "                 NN7.NN7_VALOR   VALOR,      "
    cQuery += "                 ISNULL( SUM(N9G_VALOR), 0) SOMAPVRA   "
    cQuery += "      FROM "  + RetSqlName("NJR") + " NJR     "
    cQuery += "INNER JOIN "  + RetSqlName("NN7") + " NN7 ON NN7.NN7_FILIAL = NJR.NJR_FILIAL "
    cQuery += "       AND NN7.NN7_CODCTR = NJR.NJR_CODCTR    "
    cQuery += "       AND NN7.D_E_L_E_T_ = ''                "
    cQuery += "INNER JOIN "  + RetSqlName("NJ0") + " NJ0 ON NJ0.NJ0_FILIAL = '"+ xFilial("NJ0") + "' "
    cQuery += "       AND NJ0.NJ0_CODENT = NJR.NJR_CODENT "
    cQuery += "       AND NJ0.NJ0_LOJENT = NJR.NJR_LOJENT "
    cQuery += "       AND NJ0.D_E_L_E_T_ = '' "
    cQuery += "INNER JOIN "  + RetSqlName("N9G") + " N9G ON N9G.N9G_FILIAL = NN7.NN7_FILIAL "
    cQuery += "       AND N9G.N9G_CODCTR = NN7.NN7_CODCTR "
    cQuery += "       AND N9G.N9G_ITEMPV = NN7.NN7_ITEM   "        
    cQuery += "       AND N9G.D_E_L_E_T_ = ''        "    
	cQuery +=  "  INNER JOIN " + RetSqlName('SB1')+ " SB1 ON SB1.B1_FILIAL = '" +  xFilial('SB1') +  "'"
	cQuery +=  "    AND SB1.B1_COD     = NJR.NJR_CODPRO "      
	cQuery +=  "    AND SB1.D_E_L_E_T_ = '' " 
    cQuery += "     WHERE NJR.NJR_FILIAL = '"+ xFilial("NJR") + "' "
    cQuery +=       " AND NN7.NN7_VALOR > 0 " //traz somente valores maior que zero
	cQuery +=  cWhere
    cQuery += "       AND NJR.D_E_L_E_T_ = ''  "  
    cQuery += "       AND NJR.NJR_STATUS IN ('A','I','F')  "           
    cQuery += "       AND N9G.N9G_CODCTR =  '" + _cContrato + "'" 
    cQuery += "       AND NN7.NN7_VLRAVI > 0   "             
    cQuery += "    GROUP BY NN7.NN7_FILORG , "
    cQuery += "             NJ0.NJ0_CODCLI , "
    cQuery += "             NJ0.NJ0_NOME   , "
    cQuery += "             NJ0.NJ0_LOJCLI , "
    cQuery += "             NJR.NJR_FILIAL , "
    cQuery += "             NJR.NJR_CODCTR , "
    cQuery += "             NJR.NJR_CTREXT , "    
    cQuery += "             SB1.B1_DESC    , "
    cQuery += "             NJR.NJR_CODSAF , "
    cQuery += "             NN7.NN7_DTVENC , "
    cQuery += "             NN7.NN7_MOEDA  , "    
    cQuery += "             NN7.NN7_CODCTR , "
    cQuery += "             NN7.NN7_PARCEL , "
    cQuery += "             NN7.NN7_ITEM   , "
    cQuery += "             NN7.NN7_VALOR  , "    
    cQuery += "             N9G.N9G_TIPO   , "
    cQuery += "             N9G.N9G_PREFIX , "
    cQuery += "             N9G.N9G_NUM    , "
    cQuery += "             N9G.N9G_PARTT  , "
    cQuery += "             N9G.N9G_FILTIT  "    
    cQuery += "  ORDER BY NN7.NN7_FILORG , "    
    cQuery += "           NJ0.NJ0_NOME   , "
    cQuery += "           NJ0.NJ0_LOJCLI , "    
    cQuery += "           NJR.NJR_CODCTR   "    

    cQuery := ChangeQuery(cQuery)

Return cQuery    

//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuN84
Funcao responsável por atualizar N84  -CONDIÇÃO DE PAGAMENTO
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function fAtuN84(cCtr,cItem,cAcao)

Local cAliasQry := GetNextAlias()
Local aAreaN84  := N84->(GetArea())
Local aAreaNN7  := NN7->(GetArea())
Local lRet      := .T.

    /* Caso ainda há RA vinculadas, não deve retirar a flag de pgto vinculado na N84 */
    IF cAcao == "D"
        NN7->(dbSetOrder(1))
        If NN7->(DbSeek(xFilial("NN7")+cCtr+cItem))
            If NN7->NN7_VLRAVI > 0
                RestArea(aAreaNN7)
                Return .T.
            EndIf
        EndIf
    EndIf

    BeginSQL Alias cAliasQry
        SELECT N9J_SEQCP
        FROM %table:N9J% N9J 
        WHERE N9J.N9J_FILIAL = %xFilial:N9J%
          AND N9J.N9J_CODCTR = %Exp:cCtr%
          AND N9J.N9J_SEQPF  = %Exp:cItem%
          AND N9J.%notDel%
    EndSql

    While (cAliasQry)->(!Eof())
        N84->(dbSetOrder(1))
        If N84->(DbSeek(xFilial("N84")+cCtr+(cAliasQry)->N9J_SEQCP))
            If RecLock("N84",.F.)
                If cAcao == "V"
                    N84->N84_PAGVNC := "1"
                Else
                    N84->N84_PAGVNC := "0"
                EndIf

                N84->(MsUnlock())
            Else
                lRet := .F.
                Exit
            EndIf
        EndIf
        (cAliasQry)->(dbSkip())
    EndDo

    (cAliasQry)->(DbCloseArea())

    RestArea(aAreaN84)
    RestArea(aAreaNN7)

Return lRet


/*{Protheus.doc} OGC120CINRA
//Chama função de inclusão de RA padrão do sistema
@author filipe.olegini
@since 05/12/2018
@version 1.0
@type function
*/
Function OGC120CINRA()

	FINA040(,3)
		
	OGC120CUPD('1') 	
	
Return .T.


/*/{Protheus.doc} OGC120BXNF
	Função responsável por gerar o pagamento para o contrato da NF
	@type  Function
	@author Gustavo Pereira
	@since 20/03/2019
	@version version
	@param nOpc  , numeric, Opção 3- Baixa| 4- Cancelar Baixa 
	@param nValor, numeric, Valor a ser baixado	
/*/
Function OGC120BXNF(nOpc, nValor)
	
	/* Função descontinuada */

Return

/*{Protheus.doc} BaixNFXRA
//Relaciona a NF à previsão e faz a baixa do valor dela na SE1
@author gustavo.pereira
@since 18/05/2018
@version 1
@param aChave, characters, Código do contato
@param cFilOrg, characters, Codigo do Romaneio
@param cItemRom,characters, Item do Romaneio
@param cItemPe, characters, Item da Previsão de Entrega
@param cSeqPri, characters, Sequencia Regra Fiscal
@type function
*/
Static Function fBaixNFXRA(aChave, nValBaixa)

	Local aAreaN9G   := N9G->(GetArea())
	Local aAreaN9M   := N9M->(GetArea())
	Local aAreaSE1   := SE1->(GetArea())
	Local aAreaNN7   := NN7->(GetArea())
	Local aSE1Ra     := {}	
	Local aSE1Bx     := {}	
    Local cAliasN9K  := GetNextAlias()
	Local cAliasNF   := GetNextAlias()
	Local nRecnoRA   := 0	
	Local nSaldoRA   := 0
	Local nNf        := 0
    Local cFilOrg    := aChave[5]

    SE1->(dbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
	If SE1->(dbSeek(cFilOrg + aChave[2] + aChave[3] + aChave[4] + aChave[1]))
        nRecnoRA   := SE1->( Recno() )
        nSaldoRA   := SE1->E1_SALDO
    EndIf

	//Busco as notas pela previsão posicionada
	cQuery := "SELECT E1_CLIENTE, E1_LOJA, E1_NUM, E1_PREFIXO, E1_PARCELA, E1_FILORIG " 
	cQuery +=  " FROM " + RetSqlname("SE1") + " SE1"
	cQuery +=  " INNER JOIN " +RetSqlname("N9K") + " N9K ON N9K.N9K_FILTIT = SE1.E1_FILORIG  "
	cQuery +=		" AND N9K.N9K_PREFIX = SE1.E1_PREFIXO "
	cQuery +=		" AND N9K.N9K_NUM 	 = SE1.E1_NUM "
	cQuery +=		" AND N9K.N9K_PARCEL = SE1.E1_PARCELA "
	cQuery +=		" AND N9K.N9K_TIPO   = SE1. E1_TIPO "   					
	cQuery +=		" AND N9K.D_E_L_E_T_ = SE1.D_E_L_E_T_ "   
	cQuery += " WHERE N9K.D_E_L_E_T_ = '' "
	cQuery +=   " AND N9K_FILIAL  = '" + (_cAliaBrw2)->FILIAL + "'" 	
	cQuery +=    "AND N9K.N9K_CODCTR = '" + (_cAliaBrw2)->NJR_CODCTR + "'" 
	cQuery +=   " AND N9K.N9K_SEQPF  = '" + (_cAliaBrw2)->NN7_ITEM   + "'"
	cQuery +=   " AND E1_TIPO    = 'NF' " 
	cQuery +=   " AND E1_SALDO > 0 "	
	
	cQuery := ChangeQuery( cQuery )

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasN9K,.T.,.T.)

	aAdd(aSE1Ra,{aChave[3],             ; //[1] NUMERO
				nRecnoRA,		        ; //[2] RECNO
				nSaldoRA,				; //[3] SALDO											
				aChave[2], 				; //[4] PREFIXO
				aChave[4], 				; //[5] PARCELA
				cFilOrg, 				; //[6] FILORIG
				aChave[1],				; //[7] TIPO																													
				}) //adiciono o RECNO da RA que será baixada			
	
	While (cAliasN9K)->(!Eof())		

		cQuery := ""

		//busca o Recno do NF possicionado
		cQuery := "SELECT SE1.E1_SALDO,  " 
		cQuery +=  		 "SE1.E1_VALOR, "
		cQuery +=  		 "SE1.R_E_C_N_O_ as RECNO, "
		cQuery +=  		 "N8L.N8L_CODROM, "
		cQuery +=  		 "N8L.N8L_ITEROM, "
		cQuery +=  		 "N8L.N8L_FILORI, "
		cQuery +=  		 "N8L.N8L_CODCTR, "
		cQuery +=  		 "N8L.N8L_PREFIX, "
		cQuery +=  		 "N8L.N8L_NUM, "
		cQuery +=  		 "N8L.N8L_PARCEL, "
		cQuery +=  		 "N8L.N8L_TIPO, "					
		cQuery +=  		 "SE1.E1_MOEDA, "					
		cQuery +=  		 "SE1.E1_CLIENTE, "					
		cQuery +=  		 "SE1.E1_LOJA, "					
		cQuery +=  		 "SE1.E1_FILIAL, "
		cQuery +=  		 "N9K.N9K_FILIAL, "
		cQuery +=  		 "N9K.N9K_SEQPF "					
		cQuery +=  " FROM " + RetSqlname("SE1") + " SE1"
		cQuery +=  " INNER JOIN " +RetSqlname("N8L") + " N8L ON N8L.N8L_FILIAL = SE1.E1_FILIAL "
		cQuery +=		" AND N8L.N8L_FILORI = SE1.E1_FILORIG "
		cQuery +=		" AND N8L.N8L_PREFIX = SE1.E1_PREFIXO"
		cQuery +=		" AND N8L.N8L_NUM    = SE1.E1_NUM"
		cQuery +=		" AND N8L.N8L_PARCEL = SE1.E1_PARCELA"
		cQuery +=		" AND N8L.N8L_TIPO   = SE1.E1_TIPO   "
		cQuery +=		" AND N8L.D_E_L_E_T_ = SE1.D_E_L_E_T_ "   
		cQuery +=  " INNER JOIN " +RetSqlname("N9K") + " N9K ON N9K.N9K_FILTIT = SE1.E1_FILORIG  "
		cQuery +=		" AND N9K.N9K_PREFIX = SE1.E1_PREFIXO "
		cQuery +=		" AND N9K.N9K_NUM 	 = SE1.E1_NUM "
		cQuery +=		" AND N9K.N9K_PARCEL = SE1.E1_PARCELA "
		cQuery +=		" AND N9K.N9K_TIPO   = SE1. E1_TIPO "   					
		cQuery +=		" AND N9K.D_E_L_E_T_ = SE1.D_E_L_E_T_ "   
		cQuery += " WHERE SE1.D_E_L_E_T_ = '' "
		cQuery +=   " AND E1_FILIAL  = N8L.N8L_FILIAL " //CRIAR CAMPO N9K
		cQuery +=   " AND E1_CLIENTE = '" + (cAliasN9K)->E1_CLIENTE  + "'" 
		cQuery +=   " AND E1_LOJA    = '" + (cAliasN9K)->E1_LOJA + "'" 
		cQuery +=   " AND E1_NUM     = '" + (cAliasN9K)->E1_NUM + "'" 
		cQuery +=   " AND E1_PREFIXO = '" + (cAliasN9K)->E1_PREFIXO + "'" 
		cQuery +=   " AND E1_PARCELA = '" + (cAliasN9K)->E1_PARCELA + "'" 
		cQuery +=   " AND E1_FILORIG = '" + (cAliasN9K)->E1_FILORIG + "'" 
		cQuery +=   " AND E1_TIPO    = 'NF' " 		
		cQuery +=   " AND E1_SALDO > 0 "

		cQuery := ChangeQuery( cQuery )

		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasNF,.T.,.T.)

		//Grava a chave[3] para vincular RAXNF devido a grid possibilitar selecionar RA e NF diferentes
		If (cAliasNF)->(!EOF())
			aAdd(aSE1Bx,{aChave[3],				; //[1]
						(cAliasNF)->RECNO,	 	; //[2] //adiciono o RECNO da RA que será baixada						
						(cAliasNF)->E1_SALDO, 	; //[3]
						(cAliasNF)->E1_VALOR, 	; //[4]
						(cAliasNF)->N8L_CODROM, ; //[5]	 
						(cAliasNF)->N8L_ITEROM, ; //[6]	 
						(cAliasNF)->N8L_FILORI, ; //[7]	 
						(cAliasNF)->N8L_CODCTR,	; //[8]
						(cAliasNF)->N8L_PREFIX,	; //[9]
						(cAliasNF)->N8L_NUM,	; //[10]
						(cAliasNF)->N8L_PARCEL,	; //[11]
						(cAliasNF)->N8L_TIPO,	; //[12]
						(cAliasNF)->E1_MOEDA,	; //[13]
						(cAliasNF)->E1_CLIENTE,	; //[14]
						(cAliasNF)->E1_LOJA,	; //[15]
						0,						; //[16] valor 
						(cAliasNF)->N9K_SEQPF,	; //[17]
						(cAliasNF)->E1_FILIAL,	; //[18]
						(cAliasNF)->N9K_FILIAL,	; //[19]
						}) 
		EndIf
		(cAliasNF)->(dbCloseArea())

		(cAliasN9K)->(dbSkip())		
		
	EndDo
	

	//Garante que as NF selecionadas seja da RA correta
	For nNf := 1 To Len(aSE1Bx)
		nAbatim  := 0 
		nValPrev := 0

		If aSE1Bx[nNf][1] == aSE1Ra[1][1]
			cChave := PADR(aSE1Bx[nNF,18],TamSX3("E1_FILORIG" )[1])
			cChave += PADR(aSE1Bx[nNF,14],TamSX3("E1_CLIENTE" )[1])
			cChave += PADR(aSE1Bx[nNF,15],TamSX3("E1_LOJA" )[1])
			cChave += PADR(aSE1Bx[nNF,09],TamSX3("E1_PREFIXO" )[1])
			cChave += PADR(aSE1Bx[nNF,10],TamSX3("E1_NUM" )[1])
			cChave += PADR(aSE1Bx[nNF,11],TamSX3("E1_PARCELA" )[1])
			cChave += PADR(aSE1Bx[nNF,12],TamSX3("E1_TIPO" )[1])
			
			SE1->(dbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO    					
			If SE1->(dbSeek(cChave))
				nAbatim  := SomaAbat(aSE1Bx[nNF,9],aSE1Bx[nNF,10],aSE1Bx[nNF,11],"R",aSE1Bx[nNF,13],dDataBase,aSE1Bx[nNF,14],aSE1Bx[nNF,15])														
			EndIf	

			aSE1Bx[nNf][16] := aSE1Bx[nNf][3] - nAbatim
			
			If nSaldoRA > 0

				nSaldoRA := nSaldoRA - aSE1Bx[nNf][16]

				If nSaldoRA > aSE1Bx[nNf][16] 
					nVlrCompen := aSE1Bx[nNf][16] 
				Else
					nVlrCompen := nSaldoRA
				EndIf

				nValBaixa += nVlrCompen
                lRet := MaIntBxCR(3, {aSE1Bx[nNf][2]}, ,{aSE1Ra[1][2]}, ,{.F.,.F.,.F.,.F.,.F.,.F.}, , , , , nVlrCompen, , , , , , .T.)				    																					

				If lRet
					//se retornou OK na baixa realiza o vinculo na tabela N9M
					If !(N9M->(DbSeek(aSE1Bx[nNF,19] + aSE1Bx[nNF,8] + aSE1Bx[nNF,5] + aSE1Bx[nNF,6] + aSE1Bx[nNF,7] + aSE1Bx[nNF,9] + aSE1Bx[nNF,10] + aSE1Bx[nNF,11] + aSE1Bx[nNF,12] + aSE1Ra[1][6] + aSE1Ra[1][4] + aSE1Ra[1][1] + aSE1Ra[1][5] + aSE1Ra[1][7])))
						RecLock("N9M",.T.)	
							N9M->N9M_FILIAL := aSE1Bx[nNF,19]
							N9M->N9M_CODCTR := aSE1Bx[nNF,8]
							N9M->N9M_CODROM := aSE1Bx[nNF,5]
							N9M->N9M_ITEROM := aSE1Bx[nNF,6]
							N9M->N9M_FILTIT := aSE1Bx[nNF,7]
							N9M->N9M_PREFIX := aSE1Bx[nNF,9]
							N9M->N9M_NUM    := aSE1Bx[nNF,10]
							N9M->N9M_PARCEL := aSE1Bx[nNF,11]
							N9M->N9M_TIPO   := aSE1Bx[nNF,12]
							N9M->N9M_FILTIC := aSE1Ra[1][6]
							N9M->N9M_PREFIC := aSE1Ra[1][4]
							N9M->N9M_NUMC   := aSE1Ra[1][1]
							N9M->N9M_PARCEC := aSE1Ra[1][5]
							N9M->N9M_TIPOC  := aSE1Ra[1][7]
							N9M->N9M_VALCOM := nVlrCompen
							N9M->N9M_FILCOM := xFilial("FK1")
					Else
						RecLock("N9M",.F.)	
						N9M->N9M_VALCOM += nVlrCompen
					EndIf

					N9M->(MsUnlock())																	
				Else
					Help('',1, "OGC120BBXCP") //Problema ao realizar a baixa dos titulos.
					DisarmTransaction()
					break
					lRet := .f.
				EndIf
			Endif
		Endif
	Next

	RestArea(aAreaN9G)
	RestArea(aAreaN9M)
	RestArea(aAreaSE1)
	RestArea(aAreaNN7)

Return .T.


/*/{Protheus.doc} fGetVlComp
    (long_description)
    @type  Static Function
    @author rafael.voltz
    @since 15/10/2019
    @version version
    @param cContrato, char, Código do Contrato
    @param cItemPrev, char, Item da Previsão Financeira    
    @return nValComp, numeric, Valor já compensado    
    /*/
Static Function fGetVlComp(cContrato, cItemPrev, cTipo, cPrefixo, cNum, cParcela, cFilialRA) 
    Local cAliasQry as char
    Local nValComp  as numeric

    cAliasQry := GetNextAlias()

    BeginSql Alias cAliasQry 
        SELECT SUM(N9M_VALCOM) N9M_VALCOM
            FROM %table:N9M% N9M, 
                 %table:N9G% N9G
          WHERE N9G.N9G_CODCTR = %Exp:cContrato%
            AND N9G.N9G_ITEMPV = %Exp:cItemPrev%            
            AND N9G.N9G_FILTIT = N9M.N9M_FILTIC 
            AND N9G.N9G_PREFIX = N9M.N9M_PREFIC
            AND N9G.N9G_NUM    = N9M.N9M_NUMC   
            AND N9G.N9G_PARTT  = N9M.N9M_PARCEC
            AND N9G.N9G_TIPO   = N9M.N9M_TIPOC
            AND N9G.N9G_FILIAL = N9M.N9M_FILIAL
            AND N9G.N9G_CODCTR = N9M.N9M_CODCTR  
            AND N9M.N9M_FILTIC = %Exp:cFilialRA%
            AND N9M.N9M_NUMC   = %Exp:cNum%
            AND N9M.N9M_PREFIC = %Exp:cPrefixo%
            AND N9M.N9M_PARCEC = %Exp:cParcela%
            AND N9M.N9M_TIPOC  = %Exp:cTipo%
            AND N9M.%NotDel%
            AND N9G.%NotDel%
    EndSql

    nValComp := (cAliasQry)->N9M_VALCOM

    (cAliasQry)->(dbCloseArea())

Return nValComp
