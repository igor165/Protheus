#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWBrowse.ch'
#include 'OGA800A.ch'

Static __cTabFin := ""
Static __cTabDoc := ""
Static __cTabRel := ""
Static __cNamFin := ""
Static __cNamDoc := ""
Static __cNamRel := ""
Static __oBrwFin := Nil
Static __oBrwDoc := Nil
Static __cAviso  := ""
Static __aGeral  := {}

/*/{Protheus.doc} OGA800TPD()
Função para manutenção dos documentos exigidos para aprovação do Aviso PEPRO
@type  Function
@author rafael.kleestadt
@since 12/06/2018
@version 1.0
@param param, param_type, param_descr
@return lRet, Logical, True or False
@example
(examples)
@see (links_or_references)
/*/
Function OGA800A(nAviso, aDctos)
	
	__cAviso := nAviso
	__aGeral := aDctos

	If ValInit()
		CriaBrowse()
 	Else
		__aGeral := {}
	EndIf

Return __aGeral

/*/{Protheus.doc} CriaBrowse()
Função de criação da estrutura das tabs temporarias e da tela
@type  Static Function
@author rafael.kleestadt
@since 12/06/2018
@version 1.0
@param param, param_type, param_descr
@return True, Logical, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function CriaBrowse()
    Local aStrcFin   := {{"", "T_OK", "C", 1,, "@!"}}
	Local aStrcRel   := {}
    Local aIndFin    := {}
	Local aStrcDoc   := {{"", "T_OK", "C", 1,, "@!"}}
    Local aIndDoc    := {}
    Local aIndRel    := {}
    Local aButtons   := {}

    Local aCoors     := FWGetDialogSize(oMainWnd)
	Local oDlg	     := Nil
	Local oFWL		 := Nil
	Local aSize		 := Nil
	Local oSize1     := Nil
	Local oSize2     := Nil
	Local oSize3     := Nil
	Local oPnl1      := Nil
	Local oPnlWnd1	 := Nil
	Local oPnlWnd2	 := Nil
	Local aFilBrwFin := {}
	Local aFilBrwDoc := {}
	Local nCont		 := 0	
	Local nOpcX	     := 1
	Local aHeader	 := {}
	Local oModel     := FwModelActive()
	Local nOperation := oModel:GetOperation()

    //-------------------------------Estrutura da Tabela de Finalidades-----------------------------------//
	AAdd(aStrcFin, {RetTitle("N8A_CODIGO"), "T_CODIGO", TamSX3("N8A_CODIGO")[3], TamSX3("N8A_CODIGO")[1], TamSX3("N8A_CODIGO")[2], PesqPict("N8A","N8A_CODIGO")})
	AAdd(aStrcFin, {RetTitle("N8A_DESFIN"), "T_DESFIN", TamSX3("N8A_DESFIN")[3], TamSX3("N8A_DESFIN")[1], TamSX3("N8A_DESFIN")[2], PesqPict("N8A","N8A_DESFIN")})

    // Definição dos índices da tabela
	aIndFin := {{"", "T_CODIGO"}}

    //--------------------------Estrutura da Tabela de Tipos de Documentos PEPRO--------------------------//
    AAdd(aStrcDoc, {RetTitle("N9S_CODIGO"), "T_CODIGO", TamSX3("N9S_CODIGO")[3], TamSX3("N9S_CODIGO")[1], TamSX3("N9S_CODIGO")[2], PesqPict("N9S","N9S_CODIGO")})
	AAdd(aStrcDoc, {RetTitle("N9S_DESCRI"), "T_DESCRI", TamSX3("N9S_DESCRI")[3], TamSX3("N9S_DESCRI")[1], TamSX3("N9S_DESCRI")[2], PesqPict("N9S","N9S_DESCRI")})

    // Definição dos índices da tabela
	aIndDoc := {{"", "T_CODIGO"}}

	//----------------------------Estrutura da Tabela de Tp. Dcto. x Aviso PEPRO----------------------------//
	AAdd(aStrcRel, {RetTitle("N9V_FILIAL"), "T_FILIAL", TamSX3("N9V_FILIAL")[3], TamSX3("N9V_FILIAL")[1], TamSX3("N9V_FILIAL")[2], PesqPict("N9V","N9V_FILIAL")})
	AAdd(aStrcRel, {RetTitle("N9V_NUMERO"), "T_NUMERO", TamSX3("N9V_NUMERO")[3], TamSX3("N9V_NUMERO")[1], TamSX3("N9V_NUMERO")[2], PesqPict("N9V","N9V_NUMERO")})
	AAdd(aStrcRel, {RetTitle("N9V_CODIGO"), "T_CODIGO", TamSX3("N9V_CODIGO")[3], TamSX3("N9V_CODIGO")[1], TamSX3("N9V_CODIGO")[2], PesqPict("N9V","N9V_CODIGO")})
	AAdd(aStrcRel, {RetTitle("N9V_FINALI"), "T_FINALI", TamSX3("N9V_FINALI")[3], TamSX3("N9V_FINALI")[1], TamSX3("N9V_FINALI")[2], PesqPict("N9V","N9V_FINALI")})

	// Definição dos índices da tabela
	aIndRel := {{"Av_Doc", "T_NUMERO, T_CODIGO"},{"Av_Doc_Fin", "T_NUMERO, T_CODIGO, T_FINALI"}, {"Av_Fin", "T_NUMERO, T_FINALI"}}

    Processa({|| OG710ACTMP(@__cTabFin, @__cNamFin, aStrcFin, aIndFin)}, STR0006) //"Aguarde. Criando a Tabela..."
    Processa({|| OG710ACTMP(@__cTabDoc, @__cNamDoc, aStrcDoc, aIndDoc)}, STR0006) //"Aguarde. Criando a Tabela..."
	Processa({|| OG710ACTMP(@__cTabRel, @__cNamRel, aStrcRel, aIndRel)}, STR0006) //"Aguarde. Criando a Tabela..."

	// Carrega os registros das tabelas temporárias de Finalidades, Tipos de Documentos PEPRO e Tp. Dcto. x Aviso PEPRO.
	Processa({|| InsRegDoc()}, STR0005) //Aguarde. "Selecionando as Dados Disponíveis..."
    
    /************* TELA PRINCIPAL ************************/
	aSize := MsAdvSize()

	//tamanho da tela principal
	oSize1 := FWDefSize():New(.T.)
	oSize1:AddObject('DLG',100,100,.T.,.T.)
	oSize1:SetWindowSize(aCoors)
	oSize1:lProp 	:= .T.
	oSize1:aMargins := {0,0,0,0}
	oSize1:Process()

	oDlg := TDialog():New(oSize1:aWindSize[1], oSize1:aWindSize[2], oSize1:aWindSize[3], oSize1:aWindSize[4], STR0001, , , , , CLR_BLACK, CLR_WHITE, , , .T.) //"Dctos. Exigidos para Comprovação"

	// Desabilita o fechamento da tela através da tela ESC.
	oDlg:lEscClose := .F.

	oPnl1:= tPanel():New(oSize1:aPosObj[1,1], oSize1:aPosObj[1,2],, oDlg,,,,,, oSize1:aPosObj[1,4], oSize1:aPosObj[1,3] - 30)

	// Instancia o layer
	oFWL := FWLayer():New()

	// Inicia o Layer
	oFWL:init( oPnl1, .F. )

	// Cria as divisões horizontais
	oFWL:addLine('MASTER', 100, .F.)
	oFWL:addCollumn('LEFT',  50, .F., 'MASTER')
	oFWL:addCollumn('RIGHT', 50, .F., 'MASTER')

	//cria as janelas
	oFWL:addWindow('LEFT',  'Wnd1', STR0002, 100/*tamanho*/, .F., .T.,, 'MASTER') //"Finalidades"
	oFWL:addWindow('RIGHT', 'Wnd2', STR0003, 100/*tamanho*/, .F., .T.,, 'MASTER') //"Tipos de Documento PEPRO"

    oFWL:setColSplit('LEFT', 0, 'MASTER')

	// Recupera os Paineis das divisões do Layer
	oPnlWnd1 := oFWL:getWinPanel('LEFT',  'Wnd1', 'MASTER')
	oPnlWnd2 := oFWL:getWinPanel('RIGHT', 'Wnd2', 'MASTER')


    //---------------------------------Finalidades---------------------------------//
    aHeader := {}
	
	For nCont := 2  to Len(aStrcFin)
		Aadd(aHeader, {aStrcFin[nCont][1], &("{||"+aStrcFin[nCont][2]+"}"), aStrcFin[nCont][3], aStrcFin[nCont][6], 1, aStrcFin[nCont][4], aStrcFin[nCont][5], .F.})												
		Aadd(aFilBrwFin, {aStrcFin[nCont][2], aStrcFin[nCont][1], aStrcFin[nCont][3], aStrcFin[nCont][4], aStrcFin[nCont][5], aStrcFin[nCont][6]})
	Next nCont

	//- Recupera coordenadas
	oSize2 := FWDefSize():New(.F.)
	oSize2:AddObject(STR0002,100,100,.T.,.T.)//"Finalidades"
	oSize2:SetWindowSize({0, 0, oPnlWnd1:NHEIGHT, oPnlWnd1:NWIDTH})
	oSize2:lProp 	:= .T.
	oSize2:aMargins := {0,0,0,0}
	oSize2:Process()
	
	__oBrwFin := FWBrowse():New()
	__oBrwFin:SetOwner(oPnlWnd1)
	__oBrwFin:SetDataTable(.T.)
	__oBrwFin:SetAlias(__cTabFin)
	__oBrwFin:SetProfileID("FIN")
	__oBrwFin:Acolumns := {}
	__oBrwFin:SetColumns(aHeader)	
	__oBrwFin:DisableReport(.T.)
	__oBrwFin:SetFieldFilter(aFilBrwFin)
	__oBrwFin:SetUseFilter() // Ativa filtro
	__oBrwFin:SetChange({|| AtuBrw()}) //Define o bloco de codigo a ser executado na troca de linha
		
	__oBrwFin:Activate()		
	__oBrwFin:Enable()
	__oBrwFin:Refresh(.T.)
	
    //-----------------------------Tipos de Documento PEPRO-----------------------------//
    aHeader := {}
	
	For nCont := 2  to Len(aStrcDoc)
		Aadd(aHeader, {aStrcDoc[nCont][1], &("{||"+aStrcDoc[nCont][2]+"}"), aStrcDoc[nCont][3], aStrcDoc[nCont][6], 1, aStrcDoc[nCont][4], aStrcDoc[nCont][5], .F.})												
		Aadd(aFilBrwDoc, {aStrcDoc[nCont][2], aStrcDoc[nCont][1], aStrcDoc[nCont][3], aStrcDoc[nCont][4], aStrcDoc[nCont][5], aStrcDoc[nCont][6]})
	Next nCont

	//- Recupera coordenadas 
	oSize3 := FWDefSize():New(.F.)
	oSize3:AddObject(STR0003,100,100,.T.,.T.)//"Tipos de Documento PEPRO"
	oSize3:SetWindowSize({0, 0, oPnlWnd2:NHEIGHT, oPnlWnd2:NWIDTH})
	oSize3:lProp 	:= .T.
	oSize3:aMargins := {0,0,0,0}
	oSize3:Process()
                       
	__oBrwDoc := FWBrowse():New()
	__oBrwDoc:SetOwner(oPnlWnd2)
	__oBrwDoc:SetDataTable(.T.)
    __oBrwDoc:SetAlias(__cTabDoc)
    __oBrwDoc:SetProfileID("DOC")    
    __oBrwDoc:Acolumns := {}
    __oBrwDoc:AddMarkColumns({||IIf((__cTabDoc)->T_OK == "1", "LBOK", "LBNO")}, {|| MarkBrwDoc(__oBrwDoc)}, {|| MarkAllBrw(__oBrwDoc)})
    __oBrwDoc:SetColumns(aHeader)         
    __oBrwDoc:DisableReport(.T.)                              
    __oBrwDoc:SetFieldFilter(aFilBrwDoc)
    __oBrwDoc:SetUseFilter() // Ativa filtro
        
    __oBrwDoc:Activate()
    __oBrwDoc:Enable()
	__oBrwDoc:Refresh(.T.)

    __oBrwDoc:SetFocus()  // Focus no browser de Finalidades - Principal
	__oBrwDoc:GoColumn(1) // Posiciona o Browse 2 na primeira coluna depois da ativação
	
    oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar( oDlg, {|| nOpcX := 1, oDlg:End() },{|| nOpcX := 0, oDlg:End() },, @aButtons ) } )

    If nOpcX = 1 .And. (nOperation == 3 .Or. nOperation == 4)
        GrvN9V()
    EndIf

Return .T.

/*/{Protheus.doc} GrvN9V
Função de atualização dos dados do modelo do array geral
@type  Static Function
@author rafel.kleestadt
@since 12/06/2018
@version 1.0
@param param, param_type, param_descr
@return True, Logical, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function GrvN9V()

	__aGeral := {}

	DbSelectArea(__cTabRel)
	(__cTabRel)->(DbSetOrder(1))
	(__cTabRel)->(DbGoTop())
	While (__cTabRel)->( !Eof() )

		Aadd(__aGeral, {(__cTabRel)->(T_FILIAL), (__cTabRel)->(T_NUMERO), (__cTabRel)->(T_CODIGO), (__cTabRel)->(T_FINALI)})

		(__cTabRel)->(DbSkip())
	EndDo

Return .T.

/*/{Protheus.doc} InsRegDoc()
Função de carga inicial nas tabelas temporarias
@type  Static Function
@author rafael.kleesatdt
@since 12/06/2018
@version 1.0
@param param, param_type, param_descr
@return True, Logical, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function InsRegDoc()
Local nX      := 0

// Limpa a tabela temporária
DbSelectArea(__cTabFin)
(__cTabFin)->(DbSetorder(1))
ZAP

// Limpa a tabela temporária
dbSelectArea(__cTabDoc)
(__cTabDoc)->( dbSetorder(1) )
ZAP

// Limpa a tabela temporária
dbSelectArea(__cTabRel)
(__cTabRel)->( dbSetorder(1) )
ZAP

//------------------Carga Tab. Finalidades------------------//
DbselectArea( "N8A" )
N8A->(DbGoTop())
While N8A->( !Eof() )

     RecLock(__cTabFin, .T.)
		(__cTabFin)->T_CODIGO  := N8A->N8A_CODIGO
		(__cTabFin)->T_DESFIN  := N8A->N8A_DESFIN
    (__cTabFin)->(MsUnlock())

    N8A->(DbSkip())
EndDo
N8A->(DbCloseArea())

//------------------Carga Tab. Tipos de Documento PEPRO------------------//
DbselectArea( "N9S" )
N9S->(DbGoTop())
While N9S->( !Eof() )

    RecLock(__cTabDoc, .T.)
		(__cTabDoc)->T_OK      := ""
		(__cTabDoc)->T_CODIGO  := N9S->N9S_CODIGO
		(__cTabDoc)->T_DESCRI  := N9S->N9S_DESCRI
    (__cTabDoc)->(MsUnlock())

    N9S->(DbSkip())
EndDo
N9S->(DbCloseArea())

//----------Carga Tab. Relacionamento Aviso PEPRO x Tipos de Documento PEPRO x Finalidades------------//
For nX := 1 to Len(__aGeral)
	
	RecLock(__cTabRel, .T.)
		(__cTabRel)->T_FILIAL := __aGeral[nX, 1]
		(__cTabRel)->T_NUMERO := __aGeral[nX, 2]
		(__cTabRel)->T_CODIGO := __aGeral[nX, 3]
		(__cTabRel)->T_FINALI := __aGeral[nX, 4]
	(__cTabRel)->(MsUnlock())

Next nX

Return .T.

/*/{Protheus.doc} MarkBrwDoc
Função que atualiza as tabelas conforme registro selecionado na tela
@type  Static Function
@author rafael.kleestadt
@since 12/06/2018
@version 1.0
@param oBrwObj, object, objeto do browse de documentos
@return True, Logical, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function MarkBrwDoc(oBrwObj)
Local lMarcar    := .F.
Local cAliasBrw  := oBrwObj:Alias()
Local oModel     := FwModelActive()
Local nOperation := oModel:GetOperation()

//Não permite alteração se for visualização e exclusão
If nOperation == 1 .Or. nOperation == 5
	Return .T.
EndIf

If Empty((cAliasBrw )->T_OK)
	lMarcar := .T.				
EndIf

If lMarcar

	If RecLock(cAliasBrw, .F.)
		(cAliasBrw)->T_OK := "1"
		(cAliasBrw)->(MsUnlock())
	EndIf

	DbselectArea(__cTabRel)
	(__cTabRel)->(DbSetOrder(2))
	If !(__cTabRel)->(DbSeek(__cAviso + STR((__cTabDoc)->T_CODIGO, 6, 0) + (__cTabFin)->T_CODIGO))
		RecLock(__cTabRel, .T.)	
			(__cTabRel)->T_FILIAL := FwxFilial("N9N")
			(__cTabRel)->T_NUMERO := __cAviso
			(__cTabRel)->T_CODIGO := (__cTabDoc)->T_CODIGO
			(__cTabRel)->T_FINALI := (__cTabFin)->T_CODIGO
		(__cTabRel)->(MsUnlock())
	EndIf

Else

	If RecLock(cAliasBrw, .F.)
		(cAliasBrw)->T_OK := ""
		(cAliasBrw)->(MsUnlock())
	EndIf

	DbselectArea(__cTabRel)
	(__cTabRel)->(DbSetOrder(2))
	If (__cTabRel)->(DbSeek(__cAviso + STR((__cTabDoc)->T_CODIGO, 6, 0) + (__cTabFin)->T_CODIGO))
		RecLock(__cTabRel, .F.)	
			(__cTabRel)->(DbDelete())
		(__cTabRel)->(MsUnlock())
	EndIf

EndIf

Return .T.

/*/{Protheus.doc} AtuBrw()
Função que atualiza a __cTabDoc para ajustar a visualização conforme dados da __cTabRel
@type  Static Function
@author rafael.kleestadt
@since 12/06/2018
@version 1.0
@param param, param_type, param_descr
@return True, Logical, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function AtuBrw()

DbSelectArea(__cTabDoc)
(__cTabDoc)->(DbGoTop())
While (__cTabDoc)->( !Eof() )

	RecLock(__cTabDoc, .F.)	
		(__cTabDoc)->T_OK := ""
	(__cTabDoc)->(MsUnlock())	

	(__cTabDoc)->(DbSkip())
EndDo

DbSelectArea(__cTabRel)
(__cTabRel)->(DbSetOrder(3))
If (__cTabRel)->(dbSeek(__cAviso + (__cTabFin)->T_CODIGO))
	While (__cTabRel)->( !Eof() ) .And. (__cTabRel)->T_NUMERO + (__cTabRel)->T_FINALI == __cAviso + (__cTabFin)->T_CODIGO

		DbSelectArea(__cTabDoc)
		(__cTabDoc)->(DbSetOrder(1))
		If (__cTabDoc)->(dbSeek((__cTabRel)->T_CODIGO))

			RecLock(__cTabDoc, .F.)	
				(__cTabDoc)->T_OK  := "1"
			(__cTabDoc)->(MsUnlock())
			
		EndIf

	(__cTabRel)->(DbSkip())
	EndDo
EndIf

If Valtype(__oBrwDoc) <> 'U'
	__oBrwDoc:Refresh(.T.)
EndIf

Return .T.

/*/{Protheus.doc} MarkAllBrw()
Seleção de todos os itens do browse [Documentos]
@type  Static Function
@author rafael.kleestadt
@since 12/06/2018
@version 1.0
@param oBrwObj, object, objeto do modelo.
@return True, Logical, True or False.
@example
(examples)
@see (links_or_references)
/*/
Static function MarkAllBrw(oBrwObj)
	
	(oBrwObj:Alias())->(DbGoTop())
	(oBrwObj:Alias())->(DbSetOrder(1))
	If (oBrwObj:Alias())->(DbSeek((oBrwObj:Alias())->T_CODIGO))
		
		While !(oBrwObj:Alias())->(Eof())		
			MarkBrwDoc(oBrwObj)
			(oBrwObj:Alias())->(DbSkip())
		EndDo
	EndIf

	__oBrwDoc:Refresh(.T.)
		
	oBrwObj:SetFocus()

Return .T.

/*/{Protheus.doc} ValInit()
Função para realizar as validações antes de abrir a tela
@type  Static Function
@author rafael.kleestadt
@since 12/06/2018
@version 1.0
@param oModel, object, objeto do modelo.
@return True, Logical, True or False.
@example
(examples)
@see (links_or_references)
/*/
Static Function ValInit()

 	If Empty(__cAviso)
		Help(" ", 1, ".OGA800A00001.") //##Problema: Número do Aviso PEPRO não informado. 
		Return .F.                     //##Solução: Informe o número do Aviso PEPRO para usar esta funcionalidade.
	EndIf

	DbselectArea("N8A")
	N8A->(DbGoTop())
	If N8A->( Eof() )
		Help(" ", 1, ".OGA800A00002.") //##Problema: Não á finalidades cadastradas.
		Return .F.                     //##Solução: Cadastre as finalidades para usar esta funcionalidade.
	EndIf
	N8A->(DbCloseArea())

	DbselectArea("N9S")
	N9S->(DbGoTop())
	If N9S->( Eof() )
		Help(" ", 1, ".OGA800A00003.") //##Problema: Não á tipos de documentos cadastrados.
		Return .F.                     //##Solução: Cadastre os tipos de documentos para usar esta funcionalidade.
	EndIf
	N9S->(DbCloseArea())

Return .T.