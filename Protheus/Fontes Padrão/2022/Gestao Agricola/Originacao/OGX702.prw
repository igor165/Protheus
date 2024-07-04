#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "fwMvcDef.ch"
#INCLUDE "OGX702.ch"

Static __oArqTemp
Static __oArqTmpNCS
Static __oBrowseCt
Static __oBrowse
Static __cMarca		:= GetMark()
Static __cAliGr
Static __aHeader	:= {}
Static __aCpsBrow	:= nil
Static __aCpFiltr	:= {}
Static __cTabFix	:= nil
	
/*/{Protheus.doc} OGX702
//Tela para Selecao de Contratos Futuros
@author carlos.augusto
@since 16/11/2018
@version 1.0
@return ${return}, ${return_description}
@param cFilN79, characters, descricao
@param cNegocio, characters, descricao
@param cVersao, characters, descricao
@param nModo, characters, descricao 1= Depois de Confirmar a fixacao , 2= Acao relacionada OGC004
@type function
/*/
Function OGX702(cFilN79, cNegocio, cVersao, nModo, cTipoNeg)
	Local lRet			:= .T.
	Local aCoors        := FWGetDialogSize( oMainWnd )
	Local aFilBrowCtr	:= {}
	Local nCont			:= 0
	Local oSize
	Local oDlg
	Local oPnl1
	Local oFWL
	Local oPnlWnd1
	Local oPnlWnd2
	
	Private _cFiltro	:= nil


	Default cNegocio	:= ""
	Default cVersao		:= ""
    Default cTipoNeg    := ""
	
	//-- Proteção de Código
	If .Not. TableInDic('NCT') .OR. .Not. TableInDic('NCT')  .OR. .Not. TableInDic('NCT')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif
	
	//tamanho da tela principal
	oSize := FWDefSize():New(.t.) //considerar o enchoice
	oSize:AddObject('DLG',100,100,.T.,.T.)
	oSize:SetWindowSize(aCoors)
	oSize:lProp 	:= .T.
	oSize:aMargins := {0,0,0,0}
	oSize:Process()

	oDlg := TDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4], STR0001, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Seleção de Contratos Futuros"
	oPnl1:= tPanel():New(oSize:aPosObj[1,1],oSize:aPosObj[1,2],,oDlg,,,,,,oSize:aPosObj[1,4],oSize:aPosObj[1,3] - 30 /*enchoice bar*/)

	// Instancia o layer
	oFWL := FWLayer():New()

	// Inicia o Layer
	oFWL:init( oPnl1, .F. )

	// Cria as divisões horizontais
	oFWL:addLine(    'MASTER1' , 40, .F.)
	oFWL:addCollumn( 'TOPO'    ,100, .F., 'MASTER1' )
	oFWL:addLine(    'MASTER2' , 60, .F.)
	oFWL:addCollumn( 'BAIXO'   , 100,.F., 'MASTER2' )

	//cria as janelas
	oFWL:addWindow( 'TOPO' , 'Wnd1', STR0002,  100 /*tamanho*/, .F., .T.,, 'MASTER1' ) //"Previsões de Entrega"
	oFWL:addWindow( 'BAIXO', 'Wnd2', STR0003,  100 /*tamanho*/, .F., .T.,, 'MASTER2' ) //"Contratos Futuros"

	// Recupera os Paineis das divisões do Layer
	oPnlWnd1:= oFWL:getWinPanel( 'TOPO' , 'Wnd1', 'MASTER1' )
	oPnlWnd2:= oFWL:getWinPanel( 'BAIXO', 'Wnd2', 'MASTER2' )
	
	_cFiltro := fMntFiltro() //apropria filtro
	//campos blocos

	Processa({|| __cTabFix := MontaTabel({{"", "N7C_FILIAL+N7C_CODNGC+N7C_VERSAO+N7C_CODCAD+N7C_CODCOM"}})},STR0004)//"Construindo layout da tela."
	Processa({|| fLoadDados(cFilN79, cNegocio, cVersao, nModo)},STR0005) //"Carregando a tabela de dados."

	//atalho de pesquisa
	SetKey( VK_F12, { || OGC180F12(.t.) } )

	//Criando o Browser de Visualização
	__oBrowse := FWMBrowse():New()
    __oBrowse:SetAlias(__cTabFix)
    //__oBrowse:SetDescription( STR0002 )//"Previsões de Entrega"
    __oBrowse:DisableDetails()
    __oBrowse:DisableReport(.T.)
    __oBrowse:SetMenuDef( "" )
    __oBrowse:SetProfileID("OGX702BRW1")
    __oBrowse:bGotFocus := {|tGrid| tGrid:GoColumn(1)}
    
    For nCont := 1  to Len(__aCpsBrow) //desconsiderar STATUS e Tipo
        If !__aCpsBrow[nCont][2] $ "N7C_FILIAL|N7C_OPEFIX"
        	__oBrowse:AddColumn( {__aCpsBrow[nCont][1]  , &("{||"+__aCpsBrow[nCont][2]+"}") ,__aCpsBrow[nCont][3],__aCpsBrow[nCont][6],iif(__aCpsBrow[nCont][3] == "N",2,1),__aCpsBrow[nCont][4],__aCpsBrow[nCont][5],.f.} )
        EndIf
        //If !__aCpsBrow[nCont][2] $ "NCS_FILIAL|NCS_CODIGO|NCS_DATAIN"
	       	aADD(aFilBrowCtr,  {__aCpsBrow[nCont][2], __aCpsBrow[nCont][1], __aCpsBrow[nCont][3], __aCpsBrow[nCont][4], __aCpsBrow[nCont][5], __aCpsBrow[nCont][6] } )
       	//EndIf
        
    Next nCont

    __oBrowse:SetFieldFilter(aFilBrowCtr)
    __oBrowse:Activate(oPnlWnd1)
    
    /**************************************************************************************************************************/
    
    _cFiltro := fMntFiltro() //apropria filtro

	//atalho de pesquisa
	SetKey( VK_F12, { || OGC180F12(.t.) } )
    
	Processa({|| MontaBrw()},STR0004)//"Construindo layout da tela."
	Processa({|| fLoadNCS(cFilN79, cNegocio, cVersao, cTipoNeg)},STR0005) //"Carregando a tabela de dados."    
	
		
	__oBrowseCt :=  FWBrowse():New()
	__oBrowseCt:SetOwner(oPnlWnd2)
	__oBrowseCt:SetDataTable(.T.)
	__oBrowseCt:SetAlias(__cAliGr)
	__oBrowseCt:SetProfileID('2')
	__oBrowseCt:SetFilterDefault("@FILIAL = '" + (__cTabFix)->N7A_FILIAL + "' AND TICKER = '" + (__cTabFix)->N7A_IDXCTF + "' AND CADENCIA = '" + (__cTabFix)->N7A_CODCAD + IIF( .Not. Empty((__cTabFix)->N7C_CODBCO),"' AND BANCO = '" + (__cTabFix)->N7C_CODBCO + "'","' AND 1=1")) //
	__oBrowseCt:Acolumns:= {}
	__oBrowseCt:AddMarkColumns({|| If((__cAliGr)->OK == __cMarca,'LBOK','LBNO')}, {  |__oBrowseCt| OGX702MKUM(__cAliGr, (__cAliGr)->FILIAL, (__cAliGr)->IDCTFT, (__cAliGr)->CADENCIA)},{ |__oBrowseCt| OGX702MK2(__cAliGr,(__cAliGr)->FILIAL, (__cAliGr)->CADENCIA, @__oBrowseCt) })
	__oBrowseCt:setcolumns( __aHeader )
	__oBrowseCt:DisableReport()
	__oBrowseCt:DisableConfig()
	__oBrowseCt:SetFieldFilter( __aCpFiltr ) // Seta os campos para o botão filtro
	__oBrowseCt:SetUseFilter() // Ativa filtro
	__oBrowseCt:SetEditCell( .T. ,) // Permite edição na grid
	__oBrowseCt:acolumns[8]:SetEdit(.T.)
	__oBrowseCt:acolumns[8]:SetReadVar('QTDCTR')
	__oBrowseCt:acolumns[8]:bValid := {|| IIF(ValidRes((__cAliGr)->FILIAL, (__cAliGr)->QTDCTR, (__cAliGr)->QTDE, (__cAliGr)->CADENCIA),__oBrowseCt:Refresh(),.F.)}
	__oBrowseCt:Activate()

	__oBrowse:SetChange ({|| OGX702CG( (__cTabFix)->N7A_FILIAL,(__cTabFix)->N7A_IDXCTF) })
    
    /****************************************************************************************************************************/
    
    Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| lRet := OGX702GRV(@oDlg)  },{|| lRet := .T., oDlg:End() },,/* aChoiceBtn*/) 
    
Return lRet



/*/{Protheus.doc} OGX702GRV
//TODO Descrição auto-gerada.
@author carlos.augusto
@since 20/11/2018
@version 1.0
@return ${return}, ${return_description}
@param oDlg, object, descricao
@type function
/*/
Static Function OGX702GRV(oDlg, lAuto)
	Local lRet			:= .T.
	Local nQtdCadenc	:= 0
	Local nQtdSelec		:= 0
    Local cAliasQry     := GetNextAlias()
    Local cNomeTabela   := __oArqTmpNCS:GetRealName()
	
	dbSelectArea(__cTabFix)
	(__cTabFix)->(dbGoTop())
	While !(__cTabFix)->( Eof() )
		nQtdCadenc := (__cTabFix)->N7C_QTDCTR
	
		dbSelectArea(__cAliGr)
		(__cAliGr)->(dbGoTop())
		(__cAliGr)->(dbSetOrder(2))

		//Encontra bloco do padrão
        BeginSql Alias cAliasQry
            SELECT SUM(QTDCTR) QTDCTR
              FROM %temp-table:cNomeTabela%
             WHERE FILIAL = %Exp:(__cTabFix)->N7A_FILIAL%
               AND TICKER = %Exp:(__cTabFix)->N7A_IDXCTF%
               AND CADENCIA = %Exp:(__cTabFix)->N7A_CODCAD%
               AND OK IS NOT NULL AND OK != ''
               AND %notDel%
        EndSql
		
        nQtdSelec := (cAliasQry)->QTDCTR
        (cAliasQry)->(dbCloseArea())

		If nQtdCadenc != nQtdSelec
			lRet := .F.
			//"Quant. Ctr. Inválida,"A quantidade de contratos futuros é diferente da quantidade da previsão de entrega.
			//"Verifique a previsão de entrega: "
			AGRHELP(STR0006,STR0019,STR0020 + (__cTabFix)->N7A_CODCAD)
			(__cTabFix)->(dbGoTop())
			exit
		EndIf
		(__cTabFix)->( dbSkip() )
		nQtdSelec	:= 0
		nQtdCadenc	:= 0
	EndDo
	
	
	If lRet
		If .Not. lAuto
			__oBrowseCt:SetFilterDefault("")
		EndIf
		
		dbSelectArea(__cTabFix)
		(__cTabFix)->(dbGoTop())
		While !(__cTabFix)->( Eof() )
		
			dbSelectArea(__cAliGr)
			(__cAliGr)->(dbGoTop())
			(__cAliGr)->(dbSetOrder(2))
	
			//Encontra bloco do padrão
			If (__cAliGr)->(DbSeek((__cTabFix)->N7A_FILIAL + (__cTabFix)->N7A_IDXCTF + (__cTabFix)->N7A_CODCAD))
				While (__cAliGr)->(!Eof());
					.And. (__cAliGr)->FILIAL == (__cTabFix)->N7A_FILIAL;
					.And. (__cAliGr)->TICKER == (__cTabFix)->N7A_IDXCTF;		
					.And. (__cAliGr)->CADENCIA == (__cTabFix)->N7A_CODCAD
						If .Not. Empty((__cAliGr)->OK)
                            Reclock("NCT", .T.)
                            NCT->NCT_FILIAL := (__cAliGr)->FILIAL 
                            NCT->NCT_CODNGC := (__cTabFix)->N7C_CODNGC
                            NCT->NCT_VERSAO := (__cTabFix)->N7C_VERSAO
                            NCT->NCT_CODCAD := (__cTabFix)->N7C_CODCAD
                            NCT->NCT_CODCOM := (__cTabFix)->N7C_CODCOM						
                            NCT->NCT_TICKER := (__cAliGr)->TICKER
                            NCT->NCT_QTDCTR := (__cAliGr)->QTDCTR
                            NCT->NCT_CODBCO := (__cTabFix)->N7C_CODBCO
                            NCT->NCT_OPEFIX := (__cTabFix)->N7C_OPEFIX
                            NCT->NCT_IDCTFT := (__cAliGr)->IDCTFT
                            NCT->(MsUnlock())
                        EndIf
				
					(__cAliGr)->(dbSkip())
				EndDo
			EndIf
			(__cTabFix)->( dbSkip() )
		EndDo
	EndIf
	dbSelectArea(__cTabFix)
	(__cTabFix)->(dbGoTop())
	If .Not. lAuto
		__oBrowseCt:SetFilterDefault("@FILIAL = '" + (__cTabFix)->N7A_FILIAL + "' AND TICKER = '" + (__cTabFix)->N7A_IDXCTF + "' AND CADENCIA = '" + (__cTabFix)->N7A_CODCAD + IIF( .Not. Empty((__cTabFix)->N7C_CODBCO),"' AND BANCO = '" + (__cTabFix)->N7C_CODBCO + "'","' AND 1=1"))
		__oBrowse:Refresh(.T.)
	EndIf
	If lRet .And. .Not. lAuto
		MSGINFO(STR0029, STR0030) //Vínculo realizado com sucesso.
        oDlg:End()
	EndIf
Return lRet

/*/{Protheus.doc} ValidRes
//TODO Descrição auto-gerada.
@author carlos.augusto
@since 20/11/2018
@version 1.0
@return ${return}, ${return_description}
@param cFilCt, characters, descricao
@param cCodNCS, characters, descricao
@param nQtdSel, numeric, descricao
@param nQtdeCtr, numeric, descricao
@param cCadencia, characters, descricao
@type function
/*/
Static Function ValidRes(cFilCt, cCodNCS, nQtdSel, nQtdeCtr, cCadencia)
	Local aSaveLines := FWSaveRows()
	Local lRet := .T.
	Local cNomeTabela := __oArqTmpNCS:GetRealName()
	Local nRes	:= 0
	
	If nQtdSel > nQtdeCtr
		lRet := .F.
		//"Quant. Ctr. Inválida","Quantidade de contratos disponíveis menor do que a selecionada.","Verifique o campo de quantidade."
		AGRHELP(STR0006,STR0007,STR0008)
	EndIf
	
	If lRet
	
		cQry := "SELECT SUM(QTDCTR) QTDCTR2 FROM " + cNomeTabela + " WHERE FILIAL = '" + cFilCt + "' " + ;
	            " AND IDCTFT = '" + cCodNCS + "' " +  " AND CADENCIA != '" + cCadencia + "' AND D_E_L_E_T_ = ' '"
		
		nRes := getDataSqa(cQry)
		
		If (nRes[1] + nQtdSel) > nQtdeCtr
			lRet := .F.
			//"Quant. Ctr. Inválida Cadências","Quantidade de contratos disponíveis menor do que a selecionada.",
			//"Verifique as quantidades selecionadas em todas as cadências."
			AGRHELP(STR0009,STR0007,STR0010)
		EndIf
	
		DbSelectArea(__cAliGr)
	EndIf
	
	
	If nQtdSel > 0 .And. lRet
		(__cAliGr)->OK := __cMarca
	ElseIf nQtdSel = 0
		(__cAliGr)->OK := ' '
	EndIf

	FwRestRows(aSaveLines)
Return lRet



/*/{Protheus.doc} OGX702MKUM
//TODO Descrição auto-gerada.
@author carlos.augusto
@since 20/11/2018
@version 1.0
@return ${return}, ${return_description}
@param __cAliGr, , descricao
@param cFilCt, characters, descricao
@param cCodNCS, characters, descricao
@param cCadencia, characters, descricao
@type function
/*/
Static Function OGX702MKUM(__cAliGr, cFilCt, cCodNCS, cCadencia)	
	Local cAliasQry   := nil
    Local cNomeTabela := __oArqTmpNCS:GetRealName()
    Local nQtd        := 0
    Local aArea       := (__cAliGr)->(GetArea())
    Local lMarca      := .t.

    If !(__cAliGr)->( Eof() )		
		If (__cAliGr)->OK = __cMarca
			lMarca := .f.
            nQtd := (__cAliGr)->QTDCTR 
            RecLock(__cTabFix, .F.)            
            (__cTabFix)->QTDALOC -= nQtd
            MsUnlock(__cTabFix)
            
            RecLock(__cAliGr, .F.)
			(__cAliGr)->OK := ' '
			(__cAliGr)->QTDCTR -= nQtd
			MsUnlock(__cAliGr)            
		Else
			If (__cTabFix)->QTDALOC == (__cTabFix)->N7C_QTDCTR
                AGRHELP("Ajuda","Quantidade de contratos futuros já foi atendida.")
                Return .T.
            Else
                lMarca := .t.
                RecLock(__cAliGr, .F.)
                (__cAliGr)->OK := __cMarca		
                nQtd := Iif( ((__cTabFix)->N7C_QTDCTR - (__cTabFix)->QTDALOC) > (__cAliGr)->QTDE, (__cAliGr)->QTDE, (__cTabFix)->N7C_QTDCTR - (__cTabFix)->QTDALOC) 
                (__cAliGr)->QTDCTR += nQtd
                MsUnlock(__cAliGr)

                RecLock(__cTabFix, .F.)
                (__cTabFix)->QTDALOC += nQtd
                MsUnlock(__cTabFix)
            EndIf
		EndIf
	EndIf	    

    cAliasQry   := GetNextAlias()

    BeginSql Alias cAliasQry
        SELECT IDCTFT,  R_E_C_N_O_ recno
          FROM %temp-table:cNomeTabela%
          WHERE CADENCIA <>  %EXP:(__cTabFix)->N7A_CODCAD%
            AND IDCTFT    =  %EXP:(__cAliGr)->IDCTFT%
    EndSql    
    
    While (cAliasQry)->(!Eof())
        (__cAliGr)->(dbgoto( (cAliasQry)->recno))                
        RecLock(__cAliGr,.f.)
            If lMarca
                (__cAliGr)->QTDE -= nQtd
            else
                (__cAliGr)->QTDE += nQtd
            EndIf
        (__cAliGr)->(MsUnlock())                                        
        (cAliasQry)->(dbskip())    
    EndDo      

    (cAliasQry)->(dbCloseArea())

    RestArea(aArea)
Return .T.


/*/{Protheus.doc} OGX702MK2
//TODO Descrição auto-gerada.
@author carlos.augusto
@since 20/11/2018
@version 1.0
@return ${return}, ${return_description}
@param __cAliGr, , descricao
@param cFilCt, characters, descricao
@param cCodNCS, characters, descricao
@param cCadencia, characters, descricao
@param __oBrowseCt, , descricao
@type function
/*/
Static Function OGX702MK2(__cAliGr, cFilCt, cCodNCS, cCadencia, __oBrowseCt)
	Local aSaveLines := FWSaveRows()
	Local cNomeTabela := __oArqTmpNCS:GetRealName()
	Local cQry
	Local nRes

	dbSelectArea(__cAliGr)
	(__cAliGr)->( dbGoTop() )
	While !(__cAliGr)->( Eof() )

		If (__cAliGr)->OK = __cMarca
			RecLock(__cAliGr, .F.)
			(__cAliGr)->OK := ' '
			(__cAliGr)->QTDCTR := 0
			MsUnlock(__cAliGr)
		Else
			RecLock(__cAliGr, .F.)
			(__cAliGr)->OK := __cMarca
			If (__cAliGr)->QTDCTR = 0
				cQry := "SELECT SUM(QTDCTR) QTDCTR2 FROM " + cNomeTabela + " WHERE FILIAL = '" + cFilCt + "' " + ;
						" AND IDCTFT = '" + cCodNCS + "' " +  " AND CADENCIA != '" + cCadencia + "' AND D_E_L_E_T_ = ' '"
	            nRes := getDataSqa(cQry)
				(__cAliGr)->QTDCTR := (__cAliGr)->QTDE - nRes[1]
			EndIf
			MsUnlock(__cAliGr)
		EndIf

		(__cAliGr)->( dbSkip() )
	EndDo

	(__cAliGr)->( dbGoTop() )
	__oBrowseCt:Refresh()
	FwRestRows(aSaveLines)
Return


/*/{Protheus.doc} OGX702CG
//TODO Descrição auto-gerada.
@author carlos.augusto
@since 20/11/2018
@version 1.0
@return ${return}, ${return_description}
@param cFilN7A, characters, descricao
@param cIdxCtf, characters, descricao
@type function
/*/
Function OGX702CG( cFilN7A, cIdxCtf )
    If Valtype(__oBrowseCt) == "O" 
		//__oBrowseCt:SetFilterDefault( "@NCS_FILIAL = '" + cFilN7A + "' AND NCS_TICKER = '"+cIdxCtf+"'  " )
		__oBrowseCt:SetFilterDefault("@FILIAL = '" + (__cTabFix)->N7A_FILIAL + "' AND TICKER = '" + (__cTabFix)->N7A_IDXCTF + "' AND CADENCIA = '" + (__cTabFix)->N7A_CODCAD + IIF( .Not. Empty((__cTabFix)->N7C_CODBCO),"' AND BANCO = '" + (__cTabFix)->N7C_CODBCO + "'","' AND 1=1"))
	EndIf

	__oBrowseCt:Refresh()    
Return


/*/{Protheus.doc} fMntFiltro
//TODO Descrição auto-gerada.
@author carlos.augusto
@since 20/11/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function fMntFiltro()
	Local cFiltro := ""
	cFiltro +=  "  AND 1=1"
return cFiltro



/*/{Protheus.doc} MontaTabel
@author Equipe Agroindustria
@since 09/11/2018
@version 1.0
@return ${return}, ${return_description}
@param __aCpsBrow, array, descricao
@param aIdxTab, array, descricao
@type function
/*/
Static Function MontaTabel(aIdxTab)
    Local nCont 	:= 0
    Local cTabela	:= ''
	Local aStrTab 	:= {}	//Estrutura da tabela

	__aCpsBrow := {{AgrTitulo("N7A_FILIAL"),"N7A_FILIAL",TamSX3("N7A_FILIAL")[3],TamSX3("N7A_FILIAL")[1],TamSX3("N7A_FILIAL")[2],PesqPict("N7A","N7A_FILIAL")},;//
					{AgrTitulo("N7A_CODCAD"),"N7A_CODCAD",TamSX3("N7A_CODCAD")[3],TamSX3("N7A_CODCAD")[1],TamSX3("N7A_CODCAD")[2],PesqPict("N7A","N7A_CODCAD")},;//
					{AgrTitulo("N7A_IDXCTF"),"N7A_IDXCTF",TamSX3("N7A_IDXCTF")[3],TamSX3("N7A_IDXCTF")[1],TamSX3("N7A_IDXCTF")[2],PesqPict("N7A","N7A_IDXCTF")},;
					{AgrTitulo("N7C_FILIAL"),"N7C_FILIAL",TamSX3("N7C_FILIAL")[3],TamSX3("N7C_FILIAL")[1],TamSX3("N7C_FILIAL")[2],PesqPict("N7C","N7C_FILIAL")},;
					{AgrTitulo("N7C_CODNGC"),"N7C_CODNGC",TamSX3("N7C_CODNGC")[3],TamSX3("N7C_CODNGC")[1],TamSX3("N7C_CODNGC")[2],PesqPict("N7C","N7C_CODNGC")},;
					{AgrTitulo("N7C_VERSAO"),"N7C_VERSAO",TamSX3("N7C_VERSAO")[3],TamSX3("N7C_VERSAO")[1],TamSX3("N7C_VERSAO")[2],PesqPict("N7C","N7C_VERSAO")},;
					{AgrTitulo("N7C_CODCAD"),"N7C_CODCAD",TamSX3("N7C_CODCAD")[3],TamSX3("N7C_CODCAD")[1],TamSX3("N7C_CODCAD")[2],PesqPict("N7C","N7C_CODCAD")},;
					{AgrTitulo("N7C_CODCOM"),"N7C_CODCOM",TamSX3("N7C_CODCOM")[3],TamSX3("N7C_CODCOM")[1],TamSX3("N7C_CODCOM")[2],PesqPict("N7C","N7C_CODCOM")},;
					{AgrTitulo("N7C_QTDCTR"),"N7C_QTDCTR",TamSX3("N7C_QTDCTR")[3],TamSX3("N7C_QTDCTR")[1],TamSX3("N7C_QTDCTR")[2],PesqPict("N7C","N7C_QTDCTR")},;
					{AgrTitulo("N7C_CODBCO"),"N7C_CODBCO",TamSX3("N7C_CODBCO")[3],TamSX3("N7C_CODBCO")[1],TamSX3("N7C_CODBCO")[2],PesqPict("N7C","N7C_CODBCO")},;
					{STR0024                ,"DESBANCO"  ,TamSX3("X5_DESCRI")[3] ,TamSX3("X5_DESCRI")[1] ,TamSX3("X5_DESCRI")[2] ,PesqPict("SX5","X5_DESCRI")},;//Nome do banco					
                    {AgrTitulo("N7C_OPEFIX"),"N7C_OPEFIX",TamSX3("N7C_OPEFIX")[3],TamSX3("N7C_OPEFIX")[1],TamSX3("N7C_OPEFIX")[2],PesqPict("N7C","N7C_OPEFIX")}} 			
                    

    //-- Busca no __aCpsBrow as propriedades para criar as colunas
    For nCont := 1 to Len(__aCpsBrow)
        aADD(aStrTab,{__aCpsBrow[nCont][2], __aCpsBrow[nCont][3], __aCpsBrow[nCont][4], __aCpsBrow[nCont][5] })
    Next nCont

    aADD(aStrTab,{"QTDALOC", TamSX3("N7C_QTDCTR")[3], TamSX3("N7C_QTDCTR")[1], TamSX3("N7C_QTDCTR")[2] })

   	//-- Tabela temporaria de pendencias
   	cTabela  := GetNextAlias()
   	//-- A função AGRCRTPTB está no fonte AGRUTIL01 - Funções Genericas
    __oArqTemp := AGRCRTPTB(cTabela, {aStrTab, aIdxTab})
Return cTabela


/*/{Protheus.doc} MontaBrw
//TODO Descrição auto-gerada.
@author carlos.augusto
@since 20/11/2018
@version 1.0
@return ${return}, ${return_description}
@param __aHeader, , descricao
@param __aCpFiltr, , descricao
@type function
/*/
Static Function MontaBrw()
	Local aStruct	:= {}
	
	aAdd(aStruct, {"OK"			, "C", 2, 0, , }) //Seleção
	AAdd(aStruct, {"FILIAL"		, TamSX3("NCS_FILIAL")[3], TamSX3("NCS_FILIAL")[1], TamSX3("NCS_FILIAL")[2]})
	AAdd(aStruct, {"TICKER"		, TamSX3("NCS_TICKER")[3], TamSX3("NCS_TICKER")[1], TamSX3("NCS_TICKER") [2]})
	AAdd(aStruct, {"VALOR"		, TamSX3("NCS_VALOR")[3] , TamSX3("NCS_VALOR")[1] , TamSX3("NCS_VALOR")[2]})
	AAdd(aStruct, {"QTDE"		, TamSX3("NCS_QTDE")[3]  , TamSX3("NCS_QTDE")[1]  , TamSX3("NCS_QTDE") [2]})
	AAdd(aStruct, {"QTDCTR"		, TamSX3("NCS_QTDE")[3]  , TamSX3("NCS_QTDE")[1]  , TamSX3("NCS_QTDE") [2]})
	AAdd(aStruct, {"QTDTRAB"	, TamSX3("NCS_QTDE")[3]  , TamSX3("NCS_QTDE")[1]  , TamSX3("NCS_QTDE") [2]}) //Trabalhando 
	AAdd(aStruct, {"CADENCIA"	, TamSX3("N7C_CODCAD")[3], TamSX3("N7C_CODCAD")[1], TamSX3("N7C_CODCAD") [2]})
	AAdd(aStruct, {"IDCTFT" 	, TamSX3("NCS_CODIGO")[3] , TamSX3("NCS_CODIGO")[1] , TamSX3("NCS_CODIGO") [2]})
	AAdd(aStruct, {"BANCO" 		, TamSX3("N7C_CODBCO")[3], TamSX3("N7C_CODBCO")[1], TamSX3("N7C_CODBCO") [2]})
	AAdd(aStruct, {"DESBANCO" 	, TamSX3("X5_DESCRI")[3] , TamSX3("X5_DESCRI")[1] , TamSX3("X5_DESCRI") [2]})
	
	__cAliGr := GetNextAlias()	
	__oArqTmpNCS := AGRCRTPTB(__cAliGr, {aStruct, {{"","FILIAL,TICKER,VALOR"},{"","FILIAL,TICKER,CADENCIA"}, {"","IDCTFT"}}})

	__aHeader := {}
	// Campos que serão mostrados na grid
	aAdd(__aHeader, {STR0011,{||(__cAliGr)->FILIAL}, TamSX3("NCS_FILIAL")[3],X3PICTURE("NCS_FILIAL")	, 1 ,TamSX3("NCS_FILIAL")[1] ,TamSX3("NCS_FILIAL")[2] ,.F.})//Filial
	aAdd(__aHeader, {STR0012,{||(__cAliGr)->TICKER}, TamSX3("NCS_TICKER")[3],X3PICTURE("NCS_TICKER")	, 1 ,TamSX3("NCS_TICKER") [1],TamSX3("NCS_TICKER") [2] ,.F.})//Ticker
	aAdd(__aHeader, {STR0014,{||(__cAliGr)->VALOR} , TamSX3("NCS_VALOR")[3] ,X3PICTURE("NCS_VALOR")	, 1 ,TamSX3("NCS_VALOR")[1]  ,TamSX3("NCS_VALOR")[2] ,.F.})//Valor
	aAdd(__aHeader, {STR0026,{||(__cAliGr)->QTDTRAB}, TamSX3("NCS_QTDE")[3]  ,X3PICTURE("NCS_QTDE")	, 1 ,TamSX3("NCS_QTDE") [1]  ,TamSX3("NCS_QTDE") [2] ,.T.})//Qtd Trab.
	aAdd(__aHeader, {STR0016,{||(__cAliGr)->QTDE}  , TamSX3("NCS_QTDE")[3]  ,X3PICTURE("NCS_QTDE")	, 1 ,TamSX3("NCS_QTDE") [1]  ,TamSX3("NCS_QTDE") [2] ,.T.})//Qtd Disp
	aAdd(__aHeader, {STR0017,{||(__cAliGr)->QTDCTR}, TamSX3("NCS_QTDE")[3]  ,X3PICTURE("NCS_QTDE")	, 1 ,TamSX3("NCS_QTDE") [1]  ,TamSX3("NCS_QTDE") [2] ,.T.})//Quant Selec
	aAdd(__aHeader, {STR0027,{||(__cAliGr)->BANCO}, TamSX3("N7C_CODBCO")[3]  ,X3PICTURE("N7C_CODBCO")	, 1 ,TamSX3("N7C_CODBCO") [1]  ,TamSX3("N7C_CODBCO") [2] ,.T.})//Banco
	aAdd(__aHeader, {STR0024,{||(__cAliGr)->DESBANCO}, TamSX3("X5_DESCRI")[3]  ,X3PICTURE("X5_DESCRI")	, 1 ,TamSX3("X5_DESCRI") [1]  ,TamSX3("X5_DESCRI") [2] ,.T.})//"Nome do Banco"
		
	__aCpFiltr := {}
	// Campos para o botão de filtro
	AAdd(__aCpFiltr, {"FILIAL" ,STR0011,TamSX3("NCS_FILIAL")[3],TamSX3("N83_FILORG")[1],TamSX3("N83_FILORG")[2],X3PICTURE("N83_FILORG")}) 
	AAdd(__aCpFiltr, {"TICKER" ,STR0012,TamSX3("NCS_TICKER")[3],TamSX3("NCS_TICKER")[1],TamSX3("NCS_TICKER")[2],X3PICTURE("NCS_TICKER")}) 
	AAdd(__aCpFiltr, {"VALOR"  ,STR0014,TamSX3("NCS_VALOR")[3] ,TamSX3("NCS_VALOR")[1] ,TamSX3("NCS_VALOR")[2] ,X3PICTURE("NCS_VALOR")})
	AAdd(__aCpFiltr, {"QTDE"   ,STR0016,TamSX3("NCS_QTDE")[3]  ,TamSX3("NCS_QTDE")[1]  ,TamSX3("NCS_QTDE")[2]  ,X3PICTURE("NCS_QTDE")})

Return 

/*/{Protheus.doc} fLoadDados
//Carrega os dados da Tabela Temporária
@author jean.schulze
@since 09/11/2018
@version 1.0
@return ${return}, ${return_description}
@param cFiltro, characters, descricao
@type function
/*/
Static Function fLoadDados(cFilN79, cNegocio, cVersao, nModo, cTipoNeg)
	Local cNomeTabela := __oArqTemp:GetRealName()
	Local cAliasQry 	:= GetNextAlias()
	Local cQuery		:= ""
	
	//limpa a tabela temporária
	DbSelectArea((__cTabFix))
	TCSqlExec(  "DELETE  FROM " +  cNomeTabela       )
	
	//monta po filtro padrão
	cQuery := " SELECT N7A_FILIAL, N7A_CODNGC, N7A_CODCAD, N7A_IDXCTF, N7A_MEMBAR, " 
	cQuery += " N7C_FILIAL, N7C_CODNGC, N7C_VERSAO, N7C_CODCAD, N7C_CODCOM, N7C_QTDCTR, "
	cQuery += " N7C_CODBCO, N7C_OPEFIX "
	cQuery += "   FROM " + RetSqlName('N7A')+ " N7A "
	cQuery += " INNER JOIN " + retSqlName('N7C')+" N7C" +" ON "	
	cQuery += " (N7A.N7A_FILIAL = N7C.N7C_FILIAL AND "
	cQuery += "  N7A.N7A_CODNGC = N7C.N7C_CODNGC AND "
	cQuery += "  N7A.N7A_VERSAO = N7C.N7C_VERSAO AND "
	cQuery += "  N7A.N7A_CODCAD = N7C.N7C_CODCAD)  "
	cQuery += "  WHERE N7A.N7A_FILIAL 	= '"+ cFilN79	+"' "
	cQuery += "	   AND N7A.N7A_CODNGC 	= '"+ cNegocio 	+"'	"
	cQuery += "	   AND N7A.N7A_VERSAO   = '"+ cVersao 	+"'	"
	cQuery += "	   AND N7A.D_E_L_E_T_   = ' ' "
	cQuery += "	   AND N7C.N7C_HEDGE    = '1' "
	cQuery += "	   AND N7C.N7C_QTDCTR > 0 "
 

	If nModo = 1
		cQuery += "	   AND N7A.N7A_QTDINT > 0 "
		cQuery += "	   AND N7C.N7C_VLRCOM > 0 "
	EndIf
	
	cQuery += "	   AND N7C.D_E_L_E_T_   = ' ' "	 	
	cQuery := ChangeQuery( cQuery )

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)
	
	//apropriação de dados
	DbselectArea( cAliasQry )
	DbGoTop()
	While ( cAliasQry )->( !Eof() )

		Reclock(__cTabFix, .T.)
		
		(__cTabFix)->N7A_FILIAL  := (cAliasQry)->N7A_FILIAL //Trabalhando
		(__cTabFix)->N7A_CODCAD  := (cAliasQry)->N7A_CODCAD
		(__cTabFix)->N7A_IDXCTF	:= (cAliasQry)->N7A_IDXCTF
		(__cTabFix)->N7C_QTDCTR	:= (cAliasQry)->N7C_QTDCTR
		(__cTabFix)->N7C_FILIAL	:= (cAliasQry)->N7C_FILIAL
		(__cTabFix)->N7C_CODNGC	:= (cAliasQry)->N7C_CODNGC
		(__cTabFix)->N7C_VERSAO	:= (cAliasQry)->N7C_VERSAO
		(__cTabFix)->N7C_CODCAD	:= (cAliasQry)->N7C_CODCAD
		(__cTabFix)->N7C_CODCOM	:= (cAliasQry)->N7C_CODCOM
		(__cTabFix)->N7C_OPEFIX	:= (cAliasQry)->N7C_OPEFIX
		(__cTabFix)->N7C_CODBCO	:= (cAliasQry)->N7C_CODBCO
		
		(__cTabFix)->DESBANCO	:= POSICIONE("SX5",1,FWXFILIAL("SX5")+"K6"+(cAliasQry)->N7C_CODBCO,"X5_DESCRI") 
		
		
		(__cTabFix)->(MsUnlock())
		(cAliasQry)->(dbSkip())
		enddo
		(cAliasQry)->(dbCloseArea())

Return(.t.)


Static Function fLoadNCS(cFilN79, cNegocio, cVersao, cTipoNeg)
	Local cNomeTabela := __oArqTmpNCS:GetRealName()
	Local cAliasQry 	:= GetNextAlias()	
	Local cTpCtr		:= ""
	Local nQtdTrab		:= 0
	Local cSql			:= ""
    Local lAchou        := .F.
	
	//limpa a tabela temporária
	DbSelectArea((__cAliGr))
	TCSqlExec(  "DELETE  FROM " +  cNomeTabela       )
	     
	cSql := "Select N7C.N7C_OPEFIX "+;
	    			" From " + RetSqlName("N7C") + " N7C "+;
	    				" INNER JOIN  " + RetSqlName("N79") + " N79 "+;
	    					" ON (N79.N79_FILIAL = N7C.N7C_FILIAL AND "+;
	    						" N79.N79_CODNGC = N7C.N7C_CODNGC AND "+;
	    						" N79.N79_VERSAO = N7C.N7C_VERSAO) "+;
	    							" Where N7C_FILIAL = '" + cFilN79 + "'"+;
	    								" AND N7C_CODNGC  = '" + cNegocio + "'"+;
	    								" AND N7C_VERSAO  = '" + cVersao + "'"+;
	    								" AND N79.N79_TIPO = '2' "+;
	    								" AND N7C.N7C_QTDCTR > 0 "+;
	    								" AND N7C.N7C_HEDGE = '1' "+;
	    								" AND N7C.D_E_L_E_T_ = ' ' "+;
	    								" AND N79.D_E_L_E_T_ = ' ' "
	cTpCtr = getDataSql(cSql)    

    If cTpCtr $ "1|3" .and. cTipoNeg == "2" //venda
        cTpCtr := "2" //venda
    ElseIf cTpCtr $ "2|3" .and. cTipoNeg == "1" //compra
        cTpCtr := "2" //compra
    EndIf
	     
	//monta po filtro padrão

	BeginSql Alias cAliasQry
        SELECT N7A_FILIAL, 
               N7A_CODCAD, 
               NCS_FILIAL, 
               NCS_TICKER, 
               NCS_VALOR, 
               NCS_QTDE, 
               NCS_CODIGO, 
               NCS_CPARTE, 
               NCS_POSICA
         FROM %table:NCS% NCS
        INNER JOIN %table:N7A% N7A ON N7A.N7A_FILIAL = %xFilial:N7A% AND N7A.N7A_IDXCTF = NCS.NCS_TICKER AND N7A.%notDel%
        INNER JOIN %table:N79% N79 ON N79.N79_FILIAL = %xFilial:N79% AND N79.N79_CODNGC = N7A.N7A_CODNGC AND N79.%notDel%
         WHERE NCS.NCS_FILIAL = %xFilial:NCS%
           AND NCS.NCS_POSICA   = %Exp:cTpCtr%
           AND NCS.NCS_QTDE     > 0 
           AND NCS.%notDel%
           AND N7A.N7A_CODNGC 	= %Exp:cNegocio%
           AND N7A.N7A_VERSAO   = %Exp:cVersao%
           AND N79.N79_CODSAF   = NCS.NCS_SAFRA
           AND N79.N79_CODPRO   = NCS.NCS_COMMOD           
    EndSql
	
	//apropriação de dados
	DbselectArea( cAliasQry )
	DbGoTop()
	While ( cAliasQry )->( !Eof() )
	    lAchou := .T.
        cSql := "Select SUM(NCT.NCT_QTDCTR) From " + RetSqlName("NCT") + " NCT "+;
							  " Inner Join " + RetSqlName("N79") + " N79 ON "+;
							  	"(NCT.NCT_FILIAL = N79.N79_FILIAL      "+;
							  	" AND NCT.NCT_CODNGC = N79.N79_CODNGC  "+;
							  	" AND NCT.NCT_VERSAO = N79.N79_VERSAO) "+;							  
							  		" Where NCT.D_E_L_E_T_ = ' '"  +;							  			
							  			" AND N79.D_E_L_E_T_ = ' '"+;
							  			" AND N79.N79_STATUS = '2'"+;
										" AND NCT.NCT_IDCTFT = '" + (cAliasQry)->NCS_CODIGO + "'";							  			
		
        nQtdTrab = getDataSql(cSql)
		
        Reclock(__cAliGr, .T.)
		
		(__cAliGr)->FILIAL  := (cAliasQry)->N7A_FILIAL
		(__cAliGr)->TICKER  := (cAliasQry)->NCS_TICKER
		(__cAliGr)->VALOR	:= (cAliasQry)->NCS_VALOR
		(__cAliGr)->QTDE	:= ((cAliasQry)->NCS_QTDE - nQtdTrab)
		(__cAliGr)->CADENCIA := (cAliasQry)->N7A_CODCAD
		(__cAliGr)->IDCTFT	:=  (cAliasQry)->NCS_CODIGO
		(__cAliGr)->BANCO	:=  (cAliasQry)->NCS_CPARTE
		(__cAliGr)->QTDTRAB	:= nQtdTrab
		
		(__cAliGr)->DESBANCO	:= POSICIONE("SX5",1,FWXFILIAL("SX5")+"K6"+(cAliasQry)->NCS_CPARTE,"X5_DESCRI")
		
		(__cAliGr)->(MsUnlock())
		(cAliasQry)->(dbSkip())
	enddo
	(cAliasQry)->(dbCloseArea())

    If !lAchou        
        AGRHELP(STR0031,STR0032, STR0033) //"Não foram encontrados contratos futuros para vínculo." //"Verifique se existe contrato futuro com saldo e cadastrado com Produto, Safra, Índice (ticker) e Banco iguais aos dados dessa fixação."  
    EndIf

Return(.t.)

/*/{Protheus.doc} OGX702BXFUT
    Função para baixar manualmente o saldo do contrato futuro
    @type  Function
    @author user
    @since 29/06/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function OGX702BXFUT(cFilNgc, cCodNgc, cVersao)
    Local cAliasQry := GetNextAlias()    

    BeginSql Alias cAliasQry
        SELECT SUM(NCT_QTDCTR) NCT_QTDCTR, NCT_IDCTFT NCT_IDCTFT
        FROM %table:NCT% NCT
        WHERE NCT_FILIAL = %exp:cFilNgc%
          AND NCT_CODNGC = %exp:cCodNgc%
          AND NCT_VERSAO = %exp:cVersao%
          AND %notDel%
        GROUP BY NCT_IDCTFT
    EndSql

    NCS->(dbSetOrder(1))    
    While (cAliasQry)->(!Eof())       
        
        If NCS->(dbSeek(xFilial("NCS")+(cAliasQry)->NCT_IDCTFT))
            If Reclock("NCS", .F.)
                NCS->NCS_QTDE -= (cAliasQry)->NCT_QTDCTR            
                NCS->(MsUnlock())        
            EndIf
        EndIf
        (cAliasQry)->(dbSkip())
    EndDo    

    (cAliasQry)->(dbCloseArea())

Return 

/*/{Protheus.doc} OGX702RTFUT
    Função para retornar manualmente o saldo do contrato futuro
    @type  Function
    @author user
    @since 29/06/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function OGX702RTFUT(cFilNgc, cCodNgc, cVersao)
    Local cAliasQry := GetNextAlias() 
    Local lPrimeira := .T.
    Local nVlEst    := 0
    Local nSldEst   := 0

    BeginSql Alias cAliasQry
        SELECT N79_FILIAL,
               N79_NGCREL, 
               N79_VRSREL,
               N7A_CODCAD,
               N7C_QTDCTR,
               N7C_CODCOM,
               NCT_IDCTFT,
	           NCT_TICKER,
               NCT.R_E_C_N_O_ recnoNCT
          FROM %table:N79% N79
         INNER JOIN %table:N7A% N7A ON N7A_FILIAL = N79_FILIAL AND N7A_CODNGC = N79_CODNGC AND N7A_VERSAO = N79_VERSAO AND N7A.%notDel%
         INNER JOIN %table:N7C% N7C ON N7C_FILIAL = N7A_FILIAL AND N7C_CODNGC = N7A_CODNGC AND N7C_VERSAO = N7A_VERSAO AND N7C_CODCAD = N7A_CODCAD AND N7C_HEDGE = '1'         AND N7C.%notDel%
         INNER JOIN %table:NCT% NCT ON NCT_FILIAL = N7C_FILIAL AND NCT_CODNGC = N79_NGCREL AND NCT_VERSAO = N79_VRSREL AND NCT_CODCAD = N7C_CODCAD AND NCT_CODCOM = N7C_CODCOM AND NCT.%notDel%
         WHERE N79.N79_FILIAL = %Exp:cFilNgc%
           AND N79.N79_CODNGC = %Exp:cCodNgc%
           AND N79.N79_VERSAO = %Exp:cVersao%
           AND N79.%notDel%
    EndSql   

    NCT->(dbSetOrder(1))
    NCS->(dbSetOrder(1))
    While (cAliasQry)->(!Eof())
        If lPrimeira
            nSldEst := (cAliasQry)->N7C_QTDCTR
            lPrimeira := .F.
        EndIf 

        If nSldEst == 0
            exit
        EndIf
        
        NCT->(dbgoto( (cAliasQry)->recnoNCT ))
        If RecLock("NCT", .F.)
            If (NCT->NCT_QTDCTR - nSldEst) < 0
                nVlEst := NCT->NCT_QTDCTR
            else
                nVlEst := nSldEst
            EndIf
            If (NCT->NCT_QTDCTR - nVlEst) == 0
                NCT->(dbdelete())
            else                
                NCT->NCT_QTDCTR -= nVlEst                
            EndIf
            nSldEst -= nVlEst
            
            NCT->(MsUnlock())

            If NCS->(dbSeek(xFilial("NCS")+(cAliasQry)->NCT_IDCTFT))
                If Reclock("NCS", .F.)
                    NCS->NCS_QTDE += nVlEst
                    NCS->(MsUnlock())        
                EndIf
            EndIf
        EndIf
        (cAliasQry)->(dbSkip())
    EndDo

    (cAliasQry)->(dbCloseArea())

Return 
			
/*/{Protheus.doc} OGX702REM
    Função para remover os vínculos com contratos futuros
    @type  Function
    @author user
    @since 29/06/2020
    @version version
    @param cFilN79, characters, descricao
    @param cNegocio, characters, descricao
    @param cVersao, characters, descricao
    @return     
    /*/
Function OGX702REM(cFilN79, cNegocio, cVersao)
    Local aAreaN79 := N79->(GetArea())
    Local aAreaNCT := NCT->(GetArea())    
    Local lRet     := .T.

    Begin Transaction
        NCT->(dbSetOrder(1))        
        If NCT->(DbSeek(cFilN79 + cNegocio + cVersao))
            While NCT->(!Eof()) .And. NCT->(NCT_FILIAL + NCT_CODNGC + NCT_VERSAO) == (cFilN79 + cNegocio + cVersao)                
                /* devolve saldo aos contratos*/
                If lRet := Reclock("NCT", .F.)
                    NCT->(dbdelete())
                    NCT->(MsUnlock())
                EndIf
                NCT->(dbskip())
            EndDo
        EndIf

        If !lRet
            DisarmTransaction()
            break
        EndIf 
    End Transaction
    
    RestArea(aAreaN79)
    RestArea(aAreaNCT)   

Return lRet

/*/{Protheus.doc} OGX702TEMFUT
    Funçaõ para verificar se existe vinculos de contratos com a fixação
    @type  Function
    @author user
    @since 29/06/2020
    @version version
    @param cFilN79, characters, descricao
    @param cNegocio, characters, descricao
    @param cVersao, characters, descricao
    @return lRet, Logical, Indica se tem vínculo (.T.) ou não (.F.)    
    /*/
Function OGX702TEMFUT(cFilN79, cNegocio, cVersao)
    Local cAliasQry := GetNextAlias()    
    Local lRet      := .F.

    BeginSql Alias cAliasQry
        SELECT COUNT(*) COUNT
        FROM %table:NCT% NCT
        WHERE NCT_FILIAL = %exp:cFilN79%
          AND NCT_CODNGC = %exp:cNegocio%
          AND NCT_VERSAO = %exp:cVersao%
          AND %notDel%        
    EndSql

    If (cAliasQry)->COUNT > 0
        lRet := .T.
    EndIf

    (cAliasQry)->(dbCloseArea())

Return lRet
