#INCLUDE "pcoa105.ch"
#INCLUDE "Protheus.ch"

// INCLUIDO PARA TRADUวรO DE PORTUGAL

Static nQtdEntid //alteracao


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ PCOA105  ณ Autor ณ Edson Maricate        ณ Data ณ27-01-2004ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Cadastramento de Totais da Planilha e Visao Orcamentaria   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAPCO                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณ BOPS ณ  Motivo da Alteracao                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ            ณ        ณ      ณ                                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function PCOA105()
                                     
Local aRet 		:= { 1 }
Local aParamBox := { { 3, STR0054, 1, { STR0008, STR0009 }, 95, , .F. } }	 // "Tipo de Cadastro" ### "Totais da Planilha Or็amentแria" ### "Totais da Visใo Or็amentแria"

Private cCadastro	:= STR0001 // Totalizadores
Private aRotina := MenuDef()


If ParamBox( aParamBox, STR0007, @aRet, , , .F. )		
	If aRet[1] == 1
		cCadastro += STR0055	// " da Planilha Or็amentแria"
	Else
		cCadastro += STR0056	// " da Visใo Or็amentแria"
	EndIf

	mBrowse( 06, 01, 22, 75, If( aRet[1]==1, "AKK", "AKQ" ) )

EndIf	

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Pcoa105Brw บAutor  ณGustavo Henrique  บ Data ณ  08/12/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Manutencao na tabela de totais da planilha orcamentaria    บฑฑ
ฑฑบ          ณ (AKK) ou visao orcamentaria (AKQ).                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totais e acumulados da planilha ou visao orcamentaria      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Pcoa105Brw( cAlias, nReg, nOpcx )
                                        
Local oWizard
Local lParam       
Local lParam2     
Local lParam3
Local l105Inclui := .F.
Local nTamTitAKK  := TamSX3("AKK_DESCRI")[1]
Local nTamTitAKQ  := TamSX3("AKK_DESCRI")[1]
Local aArea		 := GetArea()
Local aConfig    := {}

Local aParam1   := {} /*{ { 3,  STR0010, 1	,;	// "Selecione o Campo"
						{	STR0011		,;	// "Classe Or็amentแria"
							STR0012		,;	// "Centro de Custo"
							STR0013		,;	// "Item Contแbil"
							STR0014		,;	// "Classe de Valor"
							STR0015		,;	// "Opera็ใo"
							STR0016 }, 95,, .F. } }	// "Outro" */

Local aConfig1  := { 1 }

Local aParam2   := {	{ 1, STR0017, Space(nTamTitAKK), "", "PCOA105VDE(aRet[1],"+ Str(nTamTitAKK)+")", "", "", , .T. },; 	// "Total Por "
				 		{ 1, STR0018, Space(nTamTitAKQ), "", "PCOA105VDE(aRet[2],"+ Str(nTamTitAKQ)+")", "", "", , .T. } }		// "Acumulado Por "
					
Local aConfig2  := { Space(nTamTitAKK), Space(nTamTitAKQ) }

Local aParam3	:=	{	{ 1, STR0019, Space(03)	, "@!"	, "PCOA105Vld( aRet[1], 1)"				, "SX21", "", 35, .T. },;	// "Entidade Origem"
						{ 1, STR0020, Space(01), "9"	, "PCOA105Vld( aRet[1] + aRet[2], 2)"	, ""	, "", 25, .T. },;	// "Ordem Pesquisa"
						{ 1, STR0021, Space(15)	, "@!"	, "PCOA105Vld( aRet[3], 3)"				, ""    , "", 65, .T. },;	// "Campo Origem"
						{ 1, STR0022, Space(15)	, "@!"	, "PCOA105Vld( aRet[4], 3)"				, ""    , "", 65, .T. },;	// "Descricใo"     
						{ 1, STR0023, Space(15)	, "@!"	, "PCOA105Vld( aRet[5], 3)"				, ""    , "", 65, .T. } }	// "Campo Destino" 

Local aConfig3	:= { Space(03), Space(01), Space(15), Space(15), Space(15) }  

Local nI := 0 

Private nOpca	:= 2    


aParam1   := { { 3,  STR0010, 1	,;	// "Selecione o Campo"
						{	STR0011		,;	// "Classe Or็amentแria"
							STR0012		,;	// "Centro de Custo"
							STR0013		,;	// "Item Contแbil"
							STR0014		,;	// "Classe de Valor"
							STR0015		,;	// "Opera็ใo"
							STR0016		,;	// "Outro"
							STR0057 }, 95,, .F. } } //"Unidade Or็amentแria"

CT0->(dbSetOrder(1)) 

If nQtdEntid == NIL 
	If cPaisLoc == "RUS" 
		nQtdEntid := PCOQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor.
	Else
		nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	EndIf
EndIf

For nI := 5 to nQtdEntid 
	CT0->(dbSeek(xFilial("CT0")+StrZero(nI,2,0)))
	aAdd(aParam1[1][4], CT0->CT0_DESC)
Next nI

Do Case

	Case aRotina[nOpcX][4] == 2
		AxVisual(cAlias,nReg,nOpcx)

	Case aRotina[nOpcX][4] == 3 
		l105Inclui := .T.

	Case aRotina[nOpcX][4] == 4
		AxAltera(cAlias,nReg,nOpcx)

	Case aRotina[nOpcX][4] == 5
		AxDeleta(cAlias,nReg,nOpcx)
		
EndCase

If l105Inclui

	oWizard := APWizard():New(	STR0024 /*<chTitle>*/,; //"Atencao"
								STR0025 /*<chMsg>*/, STR0001/*<cTitle>*/, ; //"Este assistente lhe ajudara a criar um totalizados para as planilhas or็amentแrias."###"Cadastro de Totais da Planilha"
								STR0026 + CRLF +;	// "Voce deverแ informar um campo do item da planilha or็amentแria para gerar "
								STR0027 + CRLF +;	// "as colunas de total e aculumado. "
								STR0028 + CRLF +;	// 'Para prosseguir voc๊ deverแ selecionar a op็ใo "Avan็ar".'
								STR0029,;			// 'Se deseja criar manualmente a regra do totalizador e acumulado, selecione a op็ใo "Cancelar"'
								{ || .T. } /*<bNext>*/, ;
								{ || .T. } /*<bFinish>*/,;
								/*<.lPanel.>*/, , , /*<.lNoFirst.>*/)
	
	oWizard:NewPanel( 	STR0030 /*<chTitle>*/,; 	// "Totalizador"
						STR0031 /*<chMsg>*/, ; 		// "Informe o campo que deseja totalizar os itens da planilha orcamentแria."
						{ || .T. }/*<bBack>*/, ;
						{ || A105Suges( aConfig1[1], @aConfig2, .T. , nTamTitAKK, nTamTitAKK) }/*<bNext>*/, ;
						{ || .T. }/*<bFinish>*/,;
						.T./*<.lPanel.>*/,;
						{ || A105Campos(oWizard, @lParam, aParam1, aConfig1 ) }/*<bExecute>*/ )
						  
	oWizard:NewPanel(	STR0032	/*<chTitle>*/,;  	// "Titulos"
					 	STR0033 /*<chMsg>*/,;  		// "Informe os titulos do totalizador e acumulador."
						{ || .T. }/*<bBack>*/, ;
						{ || A105Suges( aConfig1[1], @aConfig3, .F. , nTamTitAKK, nTamTitAKQ) }/*<bNext>*/, ;
						{ || .T. }/*<bFinish>*/,;
						.T./*<.lPanel.>*/, ;
						{ || A105Campos(oWizard, @lParam2, aParam2, aConfig2 ) }/*<bExecute>*/ )
	
	oWizard:NewPanel(	STR0034 /*<chTitle>*/,;		// "Detalhes dos campos"
	 					STR0035 /*<chMsg>*/, ; 		// "Informe o campo para totaliza็ใo na origem e no item da planilha or็amentแria."
	 					{ || .T. }/*<bBack>*/, ;
	 					{ || .T. }/*<bNext>*/, ;
	 					{ || if( PCO105Tok(aParam3, aConfig3),(nOpca := 1, .T.),.F.) }/*<bFinish>*/, ;
	 					.T./*<.lPanel.>*/, ;
	 					{ || A105Campos(oWizard, @lParam3, aParam3, aConfig3 )  }/*<bExecute>*/ )
	
	oWizard:Activate(	.T./*<.lCenter.>*/,;
					 	{ || .T. }/*<bValid>*/, ;
						{ || .T. }/*<bInit>*/, ;
						{ || .T. }/*<bWhen>*/ )
                               
 	If nOpca == 1               
 		PcoGrvTotPlan( aConfig1[1], aParam1[1,4], aConfig2, aConfig3 )
	Else
		RollBackSX8()	
	EndIf

EndIf

RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ A105Suges บ Autor ณ Gustavo Henrique  บ Data ณ  07/12/05   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Sugestao de preenchimento para os campos do Wizard         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpN1 - Campo selecionado para criar o totalizador         บฑฑ
ฑฑบ          ณ ExpA1 - Array para preenchimento das sugestoes             บฑฑ
ฑฑบ          ณ ExpL1 - Indica se deve sugerir a tela de wizard referente  บฑฑ
ฑฑบ          ณ         aos titulos ou a tela de preenchimento dos campos  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Cadastro de totais/acumulados da planilha e visao orcament.บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A105Suges( nCampo, aCampos, lTitulos, nTamTitAKK, nTamTitAKQ)
Local nI		:= 0 
Local lRet := .T.

Do Case

	Case nCampo == 1	// Classe Orcamentaria
		If lTitulos
			aCampos[1] := Padr(STR0036, nTamTitAKK)	// "Total por Classe"
			aCampos[2] := Padr(STR0037, nTamTitAKQ)	// "Acumulado por Classe"
		Else
			aCampos[1] := "AK6"   
			aCampos[2] := "1"
			aCampos[3] := "AK6->AK6_CODIGO" 
			aCampos[4] := "AK6->AK6_DESCRI" 
			aCampos[5] := "AK2->AK2_CLASSE"
		EndIf	
	    	
	Case nCampo == 2	// Centro de Custo
		If lTitulos
			aCampos[1] := Padr(STR0038,nTamTitAKK) 	// "Total por C.C."
			aCampos[2] := Padr(STR0039,nTamTitAKQ)	// "Acumulado por C.C."
		Else
			aCampos[1] := "CTT"          
			aCampos[2] := "1"
			aCampos[3] := "CTT->CTT_CUSTO "  
			aCampos[4] := "CTT->CTT_DESC01" 
			aCampos[5] := "AK2->AK2_CC    "
		EndIf
			
	Case nCampo == 3	// Item Contabil
		If lTitulos
			aCampos[1] := Padr(STR0040,nTamTitAKK)	// "Total por Item"
			aCampos[2] := Padr(STR0041,nTamTitAKQ)	// "Acumulado por Item"
		Else
			aCampos[1] := "CTD"
			aCampos[2] := "1"
			aCampos[3] := "CTD->CTD_ITEM  "     
			aCampos[4] := "CTD->CTD_DESC01" 
			aCampos[5] := "AK2->AK2_ITCTB "
		EndIf
				
	Case nCampo == 4	// Classe de Valor
		If lTitulos
			aCampos[1] := Padr(STR0042,nTamTitAKK)	// "Total por Cl. Valor"
			aCampos[2] := Padr(STR0043,nTamTitAKQ)	// "Acumulado Cl. Valor"
		Else
			aCampos[1] := "CTH"             
			aCampos[2] := "1"
			aCampos[3] := "CTH->CTH_CLVL  "    
			aCampos[4] := "CTH->CTH_DESC01" 
			aCampos[5] := "AK2->AK2_CLVLR "
		EndIf
		
	Case nCampo == 5	// Operacao
		If lTitulos
			aCampos[1] := Padr(STR0044,nTamTitAKK)	// "Total por Operacao"
			aCampos[2] := Padr(STR0045,nTamTitAKQ)	// "Acumulado Operacao"
		Else
			aCampos[1] := "AKF"             
			aCampos[2] := "1"
			aCampos[3] := "AKF->AKF_CODIGO" 
			aCampos[4] := "AKF->AKF_DESCRI" 
			aCampos[5] := "AK2->AK2_OPER  "
		EndIf	
			
	Case nCampo == 6	// Outro
		If lTitulos
			aCampos[1] := Padr(STR0046,nTamTitAKK)	// "Total por"
			aCampos[2] := Padr(STR0047,nTamTitAKQ)	// "Acumulado por"
		Else
			aCampos[1] := Space(03) 
			aCampos[2] := "1"
			aCampos[3] := Space(15)
			aCampos[4] := Space(15) 
			aCampos[5] := Space(15)
		EndIf
			
	Case (nCampo == 7) // Unidade Or็amentแria //alteracao
		If lTitulos
			aCampos[1] := Padr(STR0058,nTamTitAKK) //"Total por Unidade Or็amentแria"
			aCampos[2] := Padr(STR0059,nTamTitAKQ) //"Acumulado Unidade Or็amentแria"
		Else
			aCampos[1] := "AMF" 
			aCampos[2] := "1"
			aCampos[3] := "AMF->AMF_CODIGO"
			aCampos[4] := "AMF->AMF_DESCRI"
			aCampos[5] := "AK2->AK2_UNIORC"
		EndIf

	Case (nCampo == 7) // Unidade Or็amentแria campo nao presente
	
		HELP(" ",1,"PCO105UNO",, STR0062 ,1,0)	  //"Unidade Or็amentแria nใo criada. Execute o update PCO()  com versใo de 26/04/2013 ou posterior."
		lRet := .F.
			
	Otherwise //alteracao

		CT0->(dbSetOrder(1)) //alteracao

		For nI := 5 to nQtdEntid //alteracao
			CT0->(DbSeek(XFilial("CT0")+StrZero(nI,2,0)))

			If nCampo == nI + 3
				If lTitulos
					aCampos[1] := Padr(STR0046+" "+CT0->CT0_DESC,nTamTitAKK) //"Total por"
					aCampos[2] := Padr(STR0060+" "+CT0->CT0_DESC,nTamTitAKQ) //"Acumulado"
				Else
					aCampos[1] := CT0->CT0_ALIAS
					aCampos[2] := "1"
					aCampos[3] := CT0->CT0_ALIAS + "->" + CT0->CT0_CPOCHV
					aCampos[4] := CT0->CT0_ALIAS + "->" + CT0->CT0_CPODSC
					aCampos[5] := "AK2->AK2_ENT" + StrZero(nI,2) 
				EndIf
			EndIf

		Next nI

EndCase
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ A105CpoTot  บAutor  ณ Gustavo Henrique บ Data ณ 20/07/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao para escolha da entidade e campo de origem          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Cadastro de totais da planilha                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A105Campos(oWizard, lParam, aParametros, aConfig, aCampos)

If lParam == NIL
	A105Rest_Par(aConfig)
	ParamBox(aParametros ,, aConfig,,,.F.,120,3, oWizard:oMPanel[oWizard:nPanel])  
	lParam := .T.
Else
	A105Rest_Par(aConfig)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ A105Rest_Par บAutor ณGustavo Henrique  บ Data ณ 05/12/05   บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao para restauracao dos conteudos das variaveis MV_PAR บฑฑ
ฑฑบ          ณ na navegacao entre os paineis do assistente de copia       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Cadastro de Totais da Planilha                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A105Rest_Par(aParam)

Local nX
Local cVarMem  
Local nLen := Len(aParam)

For nX := 1 To nLen
	cVarMem := "MV_PAR"+AllTrim(StrZero(nX,2,0))
	&(cVarMem) := aParam[nX]	
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัอออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณ PcoGrvTotPlan บAutor ณ Gustavo Henrique  บ Data ณ 08/12/05 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯอออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Grava o codigo fonte ADVPL referente aos totais das tabelasบฑฑ
ฑฑบ          ณ Totais Planilha (AKK) e Totais Visao Gerencial (AKQ).      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Planilha Orcamentaria                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoGrvTotPlan( nCampo, aNomeCpo, aTitulos, aDetalhe )

Local aProgPlan  := {}
Local aProgVis   := {}
Local nY         := 0
Local nTipo		 := 1		
Local nLenPlan	 := 0
Local nLenVis	 := 0
Local cMemoBlock := ""
Local cCodPlan   := ""
Local cCodVis    := ""

For nTipo := 1 To 2		// 1=Total ou 2=Acumulado
	                   
	cCodPlan := GetSX8Num( "AKK", "AKK_COD" )
	
	AKK->( dbSetOrder(1) )
	
	If ! AKK->(dbSeek( xFilial("AKK") + cCodPlan ))
		
		cMemoBlock	:= ""                         
		aProgPlan	:= A105GerPlan( nCampo, aNomeCpo, aDetalhe, nTipo )
		nLenPlan	:= Len(aProgPlan)
	
		For nY := 1 To nLenPlan
			cMemoBlock += aProgPlan[nY] + CRLF
		Next	
	                       
		RecLock("AKK", .T.)
		AKK->AKK_FILIAL	:= xFilial("AKK")
		AKK->AKK_COD 	:= cCodPlan
		AKK->AKK_DESCRI	:= aTitulos[nTipo]
		AKK->AKK_BLOCK	:= cMemoBlock
		AKK->(MsUnLock())
	
		If  __lSX8 
			ConfirmSX8()
		Else
			RollBackSX8()
		Endif
	
	EndIf
                                         
	cCodVis	:= GetSX8Num("AKQ","AKQ_COD")
	
	AKQ->( dbSetOrder(1) )
	
	If ! AKQ->(dbSeek( xFilial("AKQ") + cCodVis ))

		cMemoBlock	:= ""
		aProgVis	:= A105GerVis( nCampo, aNomeCpo, aDetalhe, nTipo )
		nLenVis		:= Len( aProgVis )

		For nY := 1 To nLenVis
			cMemoBlock += aProgVis[nY] + CRLF
		Next	
	                       
		RecLock("AKQ", .T.)
		AKQ->AKQ_FILIAL	:= xFilial("AKQ")
		AKQ->AKQ_COD 	:= cCodVis
		AKQ->AKQ_DESCRI	:= aTitulos[nTipo]
		AKQ->AKQ_BLOCK	:= cMemoBlock
		AKQ->(MsUnLock())
		
		If  __lSX8 
			ConfirmSX8()
		Else
			RollBackSX8()
		Endif

	EndIf
	
Next nTipo

Return	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ A105GerPlan บ Autor ณ Gustavo Henrique  บ Data ณ  05/12/05  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Monta codigo fonte do totalizador dinamico utilizado no     บฑฑ
ฑฑบ          ณ cadastro da planilha orcamentaria.                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpN1 : Campo selecionado para totalizacao                  บฑฑ
ฑฑบ          ณ ExpA2 : Array com a descricao das opcoes de campos para     บฑฑ
ฑฑบ          ณ         totalizacao.                                        บฑฑ
ฑฑบ          ณ ExpA3 : Campos de detalhe nas entidades de origem e destino บฑฑ
ฑฑบ          ณ ExpN4 : 1=Totalizar                                         บฑฑ
ฑฑบ          ณ         2=Acumular                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totalizadores da Planilha Orcamentaria                      บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A105GerPlan( nCampo, aNomeCpo, aDetalhe, nTipo )

Local nCor		:= 0
Local lQuery	:= .F.
Local cCpoIt	:= ""
Local aProgAKK	:= {}
Local aCores	:= {{ { "102, 184, 255" }, { "186, 230, 255" } },;	
					{ { "170, 170, 120" }, { "210, 170, 120" } },;
					{ { "120, 190, 120" }, { "120, 240, 180" } } }

// Campo da tabela de destino sem referencia do alias
cCpoIt	:= SubStr( aDetalhe[5], At(">",aDetalhe[5])+1, Len(aDetalhe[5]) )
nCor	:= Mod( nCampo, Len(aCores) ) + 1
                     
lQuery := (TCGetDB() # "AS/400")

If nTipo == 1	// Total
	// Esta consulta apresenta os valores Totais da Planilha Or็amentแria detalhadas por
	aAdd(aProgAKK, 'cDescri := "' + STR0048 + aNomeCpo[nCampo] + '"' )	
	//  nos periodos do Or็amento. Posicionando-se sobre a Conta Or็amentแria os valores sใo atualizados pelo m้todo Up-Down fornecendo assim uma
	aAdd(aProgAKK, 'cDescri += "' + STR0049 + '"' )	 
	// " visใo Totalizadora deste Or็amento."		
	aAdd(aProgAKK, 'cDescri += "' + STR0050 + '"' )
	aAdd(aProgAKK, '')	
EndIf

aAdd(aProgAKK, 'cTrbAlias := Alias()' )
aAdd(aProgAKK, '')
aAdd(aProgAKK, 'dbSelectArea("AK3")' )
aAdd(aProgAKK, 'aTrb_AK3 := GetArea()' )
aAdd(aProgAKK, '')
aAdd(aProgAKK, 'dbSelectArea("AK2")' )
aAdd(aProgAKK, 'aTrb_AK2 := GetArea()' )
aAdd(aProgAKK, '')
aAdd(aProgAKK, 'dbSelectArea("' + aDetalhe[1] + '")' )
aAdd(aProgAKK, 'aTrb_' + aDetalhe[1] + ' := GetArea()' )
aAdd(aProgAKK, '')
aAdd(aProgAKK, 'dbSelectArea(cTrbAlias)' )
aAdd(aProgAKK, 'nStyle := 3' )
aAdd(aProgAKK, 'cClrLegend := PcoRetRGB(' + aCores[nCor,nTipo,1] + ')' )
aAdd(aProgAKK, 'cClrData := PcoRetRGB(230,230,230)' )
aAdd(aProgAKK, '')
aAdd(aProgAKK, 'aRet := {}' )
aAdd(aProgAKK, 'aPeriodos := PcoRetPer()' )
aAdd(aProgAKK, 'aCols := Array(Len(aPeriodos)+1)' )
aAdd(aProgAKK, 'nCols := Len(aPeriodos)+1' )
aAdd(aProgAKK, 'aAuxRet:= {}' )
aAdd(aProgAKK, 'nx := 1' )
aAdd(aProgAKK, 'cPlanoCVO := ""' )
aAdd(aProgAKK, 'aAdd(aRet,Array(Len(aPeriodos)+1))' )
aAdd(aProgAKK, 'aRet[1][1] := "' + aNomeCpo[nCampo] + '"' )
aAdd(aProgAKK, 'aCols[1] := 100' )
aAdd(aProgAKK, '')
aAdd(aProgAKK, 'If AK3->(AK3_ORCAME+AK3_VERSAO) # AK1->(AK1_CODIGO+AK1_VERSAO)' )
aAdd(aProgAKK, '   AK3->( dbSetOrder(1) )' )
aAdd(aProgAKK, '   AK3->( dbSeek(xFilial("AK3") + AK1->(AK1_CODIGO+AK1_VERSAO+PadR(AK1_CODIGO,TamSX3("AK3_CO")[1]) )))' )
aAdd(aProgAKK, 'EndIf')
aAdd(aProgAKK, '')
aAdd(aProgAKK, 'nz := 2' )
aAdd(aProgAKK, 'While nz <= Len(aCols)' )
aAdd(aProgAKK, '   aRet[1][nz] := aPeriodos[nz-1]' )
aAdd(aProgAKK, '   aCols[nz] := 70' )
aAdd(aProgAKK, '   nz++' )
aAdd(aProgAKK, 'EndDo' )
aAdd(aProgAKK, '')
aAdd(aProgAKK, 'If AK3->(AK3_ORCAME+AK3_VERSAO) # AK1->(AK1_CODIGO+AK1_VERSAO)' )
aAdd(aProgAKK, '   AK3->( dbSetOrder(1) )' )
aAdd(aProgAKK, '   AK3->( dbSeek(xFilial("AK3") + AK1->(AK1_CODIGO+AK1_VERSAO+PadR(AK1_CODIGO,TamSX3("AK3_CO")[1]) )))' )
aAdd(aProgAKK, 'EndIf' ) 
aAdd(aProgAKK, '')
aAdd(aProgAKK, 'cCOs	:= "' +"'"+ '"+AK3->AK3_CO+"' +"'"+ ',"' )
aAdd(aProgAKK, 'aAdd(aAuxRet,{AK3->AK3_CO ,AK3->AK3_DESCRI})' )
aAdd(aProgAKK, 'aVet:=PcoRetFilhos(AK3->AK3_ORCAME,AK3->AK3_VERSAO,AK3->AK3_CO)' )
aAdd(aProgAKK, 'While nx <= Len(aVet)' )
aAdd(aProgAKK, '   AK3->(dbGoto(aVet[nx]))' )
aAdd(aProgAKK, '   If AK3->AK3_TIPO=="2"' )
aAdd(aProgAKK, '       aAdd(aAuxRet,{AK3->AK3_CO ,AK3->AK3_DESCRI } )' )
aAdd(aProgAKK, '       cCOs	+= "' +"'"+ '"+AK3->AK3_CO+"' +"'"+ ',"' )
aAdd(aProgAKK, '   Endif' )
aAdd(aProgAKK, '   nx++' )
aAdd(aProgAKK, 'EndDo' )
aAdd(aProgAKK, '')
aAdd(aProgAKK, 'cCOs	:=	Left(cCOs,len(cCOs)-1)' )
aAdd(aProgAKK, 'nx := 1' )
aAdd(aProgAKK, '')
If lQuery
	aAdd(aProgAKK, 'cQuery := "SELECT '+cCpoIt+', AK2_PERIOD, AK2_CLASSE, SUM(AK2_VALOR) AK2_VALOR "' )
	aAdd(aProgAKK, 'cQuery += "FROM "+RetSqlName("AK2")+ " AK2 "' )
	aAdd(aProgAKK, 'cQuery += " WHERE AK2_FILIAL = '+"'"+'"+xFilial('+"'"+'AK2'+"'"+')+"'+"'"+' AND "' )
	aAdd(aProgAKK, 'cQuery += " AK2_ORCAME = '+"'"+'" +AK3->AK3_ORCAME+"'+"'"+' AND "' )
	aAdd(aProgAKK, 'cQuery += " AK2_VERSAO = '+"'"+'" +AK3->AK3_VERSAO+"'+"'"+' AND "' )
	aAdd(aProgAKK, 'cQuery += " AK2_CO IN ("+cCOs+") AND"' )
	aAdd(aProgAKK, 'cQuery += " D_E_L_E_T_ = '+"' '"+'"' )
	aAdd(aProgAKK, 'cQuery += " GROUP BY '+cCpoIt+', AK2_PERIOD, AK2_CLASSE "' )
	aAdd(aProgAKK, 'cQuery := ChangeQuery(cQuery)' )
	aAdd(aProgAKK, 'dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )' )
	aAdd(aProgAKK, '')
	aAdd(aProgAKK, 'nCont := 0')
	aAdd(aProgAKK, 'dbEval( {|| nCont ++ } )')
	aAdd(aProgAKK, 'ProcRegua(nCont)')
	aAdd(aProgAKK, 'dbGoTop()')	
	aAdd(aProgAKK, '')	
	aAdd(aProgAKK, 'While !Eof()' )
	If aDetalhe[1]=="CTT"
		aAdd(aProgAKK, '	If PcoCC_User(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,2,"CCUSTO",AK3->AK3_VERSAO,QRYTRB->' + cCpoIt + ')')
	ElseIf aDetalhe[1]=="CTD"
		aAdd(aProgAKK, '	If PcoIC_User(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,2,"ITMCTB",AK3->AK3_VERSAO,QRYTRB->' + cCpoIt + ')')
	ElseIf aDetalhe[1]=="CTH"
		aAdd(aProgAKK, '	If PcoCV_User(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,2,"CLAVLR",AK3->AK3_VERSAO,QRYTRB->' + cCpoIt + ')')
	EndIf
	aAdd(aProgAKK, '   IncProc()')	
	aAdd(aProgAKK, '   ' )
	aAdd(aProgAKK, '   nPosIt := aScan(aRet,{|x| SubStr(x[1],1,Len(QRYTRB->'+cCpoIt+')) == QRYTRB->'+cCpoIt+'})' )
	aAdd(aProgAKK, '   If nPosIt > 0' )
	aAdd(aProgAKK, '      nPosHead := aScan(aPeriodos,{|x| DToS(CtoD(SubStr(x,1,10)))==QRYTRB->AK2_PERIOD})' )
	aAdd(aProgAKK, '      If nPosHead > 0' )
	
	If nTipo == 1		// Total
		aAdd(aProgAKK, '        If aRet[nPosIt][nPosHead+1]<> Nil' )
		aAdd(aProgAKK, '            aRet[nPosIt][nPosHead+1] := PcoPlanCel(QRYTRB->AK2_VALOR+PcoPlanVal(aRet[nPosIt][nPosHead+1],QRYTRB->AK2_CLASSE),QRYTRB->AK2_CLASSE)' )
		aAdd(aProgAKK, '        Else' )
		aAdd(aProgAKK, '            aRet[nPosIt][nPosHead+1] := PcoPlanCel(QRYTRB->AK2_VALOR,QRYTRB->AK2_CLASSE)' )
		aAdd(aProgAKK, '        EndIf' )
	Else				// Acumulado
		aAdd(aProgAKK, 'nv := nPosHead+1' )
		aAdd(aProgAKK, '')
		aAdd(aProgAKK, '        While nv <= Len(aCols)' )
		aAdd(aProgAKK, '           If aRet[nPosIt][nv]<> Nil' )
		aAdd(aProgAKK, '                aRet[nPosIt][nv] := PcoPlanCel(QRYTRB->AK2_VALOR+PcoPlanVal(aRet[nPosIt][nv],QRYTRB->AK2_CLASSE),QRYTRB->AK2_CLASSE)' )
		aAdd(aProgAKK, '           Else'  )
		aAdd(aProgAKK, '                 aRet[nPosIt][nv] := PcoPlanCel(QRYTRB->AK2_VALOR,QRYTRB->AK2_CLASSE)' )
		aAdd(aProgAKK, '           EndIf' )
		aAdd(aProgAKK, '           nv++'  )
		aAdd(aProgAKK, '        EndDo' )
		aAdd(aProgAKK, '')	
	EndIf
	
	aAdd(aProgAKK, '      EndIf' )
	aAdd(aProgAKK, '   Else' )
	aAdd(aProgAKK, '      aAdd(aRet,Array(Len(aPeriodos)+1))' )
	aAdd(aProgAKK, '      dbSelectArea("'+aDetalhe[1]+'")' )
	aAdd(aProgAKK, '      dbSetOrder('+aDetalhe[2]+')' )
	If aDetalhe[1] == "CV0"
		Aadd(aProgAKK, '      cPlanoCVO := GetAdvFVal("CT0","CT0_ENTIDA",XFilial("CT0")+"'+Right(cCpoIt,2)+'",1,"") ')
		Aadd(aProgAKK, '      DbSeek(XFilial()+cPlanoCVO+QRYTRB->'+cCpoIt+')' )
	Else
		Aadd(aProgAKK, '      DbSeek(XFilial()+QRYTRB->'+cCpoIt+')' )
	EndIf
	aAdd(aProgAKK, '      aRet[Len(aRet)][1] := QRYTRB->'+cCpoIt+'+ " - " + AllTrim('+aDetalhe[4]+')' )
	aAdd(aProgAKK, '      ny := 2' )
	aAdd(aProgAKK, '      nLenPer := Len(aPeriodos)' )
	aAdd(aProgAKK, '      While ny <= nLenPer+1' )
	aAdd(aProgAKK, '         aRet[Len(aRet)][ny] := PcoPlanCel(0,QRYTRB->AK2_CLASSE)' )
	aAdd(aProgAKK, '         ny++' )
	aAdd(aProgAKK, '      EndDo' )
	aAdd(aProgAKK, '      nPosHead := aScan(aPeriodos,{|x| DTOS(Ctod(SubStr(x,1,10)))==QRYTRB->AK2_PERIOD})' )
	aAdd(aProgAKK, '   If nPosHead > 0' )
	
	If nTipo == 1	// Total
		aAdd(aProgAKK, '       If aRet[Len(aRet)][nPosHead+1]<> Nil' )
		aAdd(aProgAKK, '           aRet[Len(aRet)][nPosHead+1] := PcoPlanCel(QRYTRB->AK2_VALOR+PcoPlanVal(aRet[Len(aRet)][nPosHead+1],QRYTRB->AK2_CLASSE),QRYTRB->AK2_CLASSE)' )
		aAdd(aProgAKK, '       Else' )
		aAdd(aProgAKK, '           aRet[Len(aRet)][nPosHead+1] := PcoPlanCel(QRYTRB->AK2_VALOR,QRYTRB->AK2_CLASSE)' )
		aAdd(aProgAKK, '       EndIf' )
	Else			// Acumulado
		aAdd(aProgAKK, '       nv := nPosHead+1' )
		aAdd(aProgAKK, '       While nv <= Len(aCols)' )
		aAdd(aProgAKK, '          If aRet[Len(aRet)][nv]<> Nil' )
		aAdd(aProgAKK, '              aRet[Len(aRet)][nv] := PcoPlanCel(QRYTRB->AK2_VALOR+PcoPlanVal(aRet[Len(aRet)][nv],QRYTRB->AK2_CLASSE),QRYTRB->AK2_CLASSE)' )
		aAdd(aProgAKK, '          Else' )
		aAdd(aProgAKK, '              aRet[Len(aRet)][nv] := PcoPlanCel(QRYTRB->AK2_VALOR,QRYTRB->AK2_CLASSE)' )
		aAdd(aProgAKK, '          EndIf' )
		aAdd(aProgAKK, '          nv++' )
		aAdd(aProgAKK, '       EndDo' )
	EndIf	
	
	aAdd(aProgAKK, '        EndIf' )
	aAdd(aProgAKK, '     EndIf' )
	If aDetalhe[1] $ "CTT#CTD#CTH"
		aAdd(aProgAKK, 'EndIf' )
	EndIf
	aAdd(aProgAKK, '     dbSelectArea("QRYTRB")')
	aAdd(aProgAKK, '     dbSkip()' )
	aAdd(aProgAKK, '')
	aAdd(aProgAKK, 'EndDo' )
	aAdd(aProgAKK, 'dbCloseArea()' )
	aAdd(aProgAKK, '')
Else
	aAdd(aProgAKK, 'ProcRegua(Len(aAuxRet))' )
	aAdd(aProgAKK, 'While nx <= Len(aAuxRet)' )
	aAdd(aProgAKK, 'IncProc()' )
	aAdd(aProgAKK, 'dbSelectArea("AK2")' )
	aAdd(aProgAKK, 'dbSetOrder(1)' )
	aAdd(aProgAKK, 'dbSeek(xFilial()+AK3->AK3_ORCAME+AK3->AK3_VERSAO+aAuxRet[nx][1])' )
	aAdd(aProgAKK, '')
	aAdd(aProgAKK, 'While !Eof() .And. xFilial()+AK3->AK3_ORCAME+AK3->AK3_VERSAO+aAuxRet[nx][1]==AK2->Ak2_FILIAL+AK2->AK2_ORCAME+AK2->AK2_VERSAO+AK2->AK2_CO' )
	aAdd(aProgAKK, 'nPosIt := aScan(aRet,{|x| Substr(x[1],1,Len('+aDetalhe[5]+')) == '+aDetalhe[5]+'})' )
	aAdd(aProgAKK, 'If nPosIt > 0' )
	aAdd(aProgAKK, 'nPosHead := aScan(aPeriodos,{|x| CToD(SubStr(x,1,10))==AK2->AK2_PERIOD})' )
	aAdd(aProgAKK, 'If nPosHead > 0')
	
	If nTipo == 1	// Total
		aAdd(aProgAKK, 'If aRet[nPosIt][nPosHead+1] <> NIL' )
		aAdd(aProgAKK, 'aRet[nPosIt][nPosHead+1] := PcoPlanCel(AK2->AK2_VALOR+PcoPlanVal(aRet[nPosIt][nPosHead+1],AK2->AK2_CLASSE),AK2->AK2_CLASSE)' )
		aAdd(aProgAKK, 'Else' )              
		aAdd(aProgAKK, 'aRet[nPosIt][nPosHead+1] := PcoPlanCel(AK2->AK2_VALOR,AK2->AK2_CLASSE)' )
		aAdd(aProgAKK, 'EndIf' )
	Else			// Acumulado
		aAdd(aProgAKK, 'nv := nPosHead+1' )
		aAdd(aProgAKK, '')
		aAdd(aProgAKK, 'While nv <= Len(aCols)' )
		aAdd(aProgAKK, 'If aRet[nPosIt][nv]<> Nil' )
		aAdd(aProgAKK, 'aRet[nPosIt][nv] := PcoPlanCel(AK2->AK2_VALOR+PcoPlanVal(aRet[nPosIt][nv],AK2->AK2_CLASSE),AK2->AK2_CLASSE)' )
		aAdd(aProgAKK, 'Else'  )
		aAdd(aProgAKK, 'aRet[nPosIt][nv] := PcoPlanCel(AK2->AK2_VALOR,AK2->AK2_CLASSE)' )
		aAdd(aProgAKK, 'EndIf' )
		aAdd(aProgAKK, 'nv++'  )
		aAdd(aProgAKK, 'EndDo' )
		aAdd(aProgAKK, '')	
	EndIf	
	
	aAdd(aProgAKK, 'EndIf' )       
	aAdd(aProgAKK, 'Else' )
	aAdd(aProgAKK, 'aAdd(aRet,Array(Len(aPeriodos)+1))' )
	aAdd(aProgAKK, 'dbSelectArea("'+aDetalhe[1]+'")' )
	aAdd(aProgAKK, 'dbSetOrder('+aDetalhe[2]+' )')
	aAdd(aProgAKK, 'dbSeek(xFilial()+'+aDetalhe[5]+')' )       
	aAdd(aProgAKK, 'aRet[Len(aRet)][1] := '+aDetalhe[3]+' + " - " + AllTrim('+aDetalhe[4]+')' )
	aAdd(aProgAKK, '')
	aAdd(aProgAKK, 'ny := 2' )
	aAdd(aProgAKK, 'While ny <= Len(aPeriodos)+1' )
	aAdd(aProgAKK, 'aRet[Len(aRet)][ny] := PcoPlanCel(0,AK2->AK2_CLASSE)' )
	aAdd(aProgAKK, 'ny++' )
	aAdd(aProgAKK, 'EndDo' )
	aAdd(aProgAKK, '')
	aAdd(aProgAKK, 'nPosHead := aScan(aPeriodos,{|x| CToD(SubStr(x,1,10))==AK2->AK2_PERIOD})' )
	aAdd(aProgAKK, 'If nPosHead > 0' )
	
	If nTipo == 1	// Total
		aAdd(aProgAKK, 'If aRet[Len(aRet)][nPosHead+1]<> NIL' )
		aAdd(aProgAKK, 'aRet[Len(aRet)][nPosHead+1] := PcoPlanCel(AK2->AK2_VALOR+PcoPlanVal(aRet[Len(aRet)][nPosHead+1],AK2->AK2_CLASSE),AK2->AK2_CLASSE)' )
		aAdd(aProgAKK, 'Else' )
		aAdd(aProgAKK, 'aRet[Len(aRet)][nPosHead+1] := PcoPlanCel(AK2->AK2_VALOR,AK2->AK2_CLASSE)' )
		aAdd(aProgAKK, 'EndIf' )
	Else			// Acumulado
		aAdd(aProgAKK, 'nv := nPosHead+1' )
		aAdd(aProgAKK, 'While nv <= Len(aCols)' )
		aAdd(aProgAKK, 'If aRet[Len(aRet)][nv]<> Nil' )
		aAdd(aProgAKK, 'aRet[Len(aRet)][nv] := PcoPlanCel(AK2->AK2_VALOR+PcoPlanVal(aRet[Len(aRet)][nv],AK2->AK2_CLASSE),AK2->AK2_CLASSE)' )
		aAdd(aProgAKK, 'Else' )
		aAdd(aProgAKK, 'aRet[Len(aRet)][nv] := PcoPlanCel(AK2->AK2_VALOR,AK2->AK2_CLASSE)' )
		aAdd(aProgAKK, 'EndIf' )
		aAdd(aProgAKK, 'nv++' )
		aAdd(aProgAKK, 'EndDo' )
	EndIf
	
	aAdd(aProgAKK, 'EndIf' )
	aAdd(aProgAKK, 'EndIf' )
	aAdd(aProgAKK, 'dbSelectArea("AK2")' )
	aAdd(aProgAKK, 'dbSkip()' )
	aAdd(aProgAKK, '')
	aAdd(aProgAKK, 'EndDo' )
	aAdd(aProgAKK, 'nx++' )
	aAdd(aProgAKK, 'EndDo' )
	aAdd(aProgAKK, '')
EndIf
aAdd(aProgAKK, 'RestArea(aTrb_AK2)' )
aAdd(aProgAKK, 'RestArea(aTrb_AK3)' )
aAdd(aProgAKK, 'RestArea(aTrb_'+aDetalhe[1]+')' )
aAdd(aProgAKK, 'dbSelectArea(cTrbAlias)' )
aAdd(aProgAKK, '')
aAdd(aProgAKK, 'Return({aRet,aCols, nCols})' )

Return(aProgAKK)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ A105GerVis  บ Autor ณ Gustavo Henrique  บ Data ณ  08/12/05  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Monta codigo fonte do totalizador dinamico utilizado no     บฑฑ
ฑฑบ          ณ cadastro de visao orcamentaria.                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpN1 : Campo selecionado para totalizacao                  บฑฑ
ฑฑบ          ณ ExpA2 : Array com a descricao das opcoes de campos para     บฑฑ
ฑฑบ          ณ         totalizacao.                                        บฑฑ
ฑฑบ          ณ ExpA3 : Campos de detalhe nas entidades de origem e destino บฑฑ
ฑฑบ          ณ ExpN4 : 1=Totalizar                                         บฑฑ
ฑฑบ          ณ         2=Acumular                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totalizadores da Planilha Orcamentaria                      บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A105GerVis( nCampo, aNomeCpo, aDetalhe, nTipo )

Local nCor     := 0
Local cCpoIt   := ""
Local aProgAKQ := {}

Local aCores   := {	{ { "102, 184, 255" }, { "186, 230, 255" } },;	
					{ { "170, 170, 120" }, { "210, 170, 120" } },;
					{ { "120, 190, 120" }, { "120, 240, 180" } } }

// Campo da tabela de destino sem referencia do alias
cCpoIt  := SubStr( aDetalhe[5], At(">",aDetalhe[5])+1, Len(aDetalhe[5]) )
nCor	:= Mod( nCampo, Len(aCores) ) + 1

If nTipo == 1	// Total                                               
	// "Esta consulta apresenta os valores Totais da Planilha Visao Or็amentแria detalhadas por "
	aAdd(aProgAKQ, 'cDescri := "' + STR0051 + aNomeCpo[nCampo] + '"' )
	// " nos periodos do Or็amento. Posicionando-se sobre a Conta Or็amentแria os valores sใo atualizados pelo m้todo Up-Down fornecendo assim"
	aAdd(aProgAKQ, 'cDescri += "' + STR0052 + '"' )
	// " uma visใo Totalizadora deste Or็amento."
	aAdd(aProgAKQ, 'cDescri += "' + STR0053 + '"' )
	aAdd(aProgAKQ, '')
EndIf
	
aAdd(aProgAKQ, 'cTrbAlias := Alias()' )
aAdd(aProgAKQ, '')
aAdd(aProgAKQ, 'dbSelectArea("AKO")' )
aAdd(aProgAKQ, 'aTrb_AKO := GetArea()' )
aAdd(aProgAKQ, '')
aAdd(aProgAKQ, 'dbSelectArea("TMPAK2")' )
aAdd(aProgAKQ, 'aTrb_TMPAK2 := GetArea()' )
aAdd(aProgAKQ, '')
aAdd(aProgAKQ, 'dbSelectArea("' + aDetalhe[1] + '")' )
aAdd(aProgAKQ, 'aTrb_' + aDetalhe[1] + ' := GetArea()' )
aAdd(aProgAKQ, '')
aAdd(aProgAKQ, 'dbSelectArea(cTrbAlias)' )
aAdd(aProgAKQ, 'nStyle := 3' )
aAdd(aProgAKQ, 'cClrLegend := PcoRetRGB('+aCores[nCor,nTipo,1]+')' )
aAdd(aProgAKQ, 'cClrData := PcoRetRGB(230,230,230)' )
aAdd(aProgAKQ, '')
aAdd(aProgAKQ, 'aRet := {}' )
aAdd(aProgAKQ, 'aPeriodos := VisRetPer()' )
aAdd(aProgAKQ, 'aCols := Array(Len(aPeriodos)+1)' )
aAdd(aProgAKQ, 'nCols := Len(aPeriodos)+1' )
aAdd(aProgAKQ, 'aAuxRet:= {}' )
aAdd(aProgAKQ, 'nx := 1' )
aAdd(aProgAKQ, 'aAdd(aRet,Array(Len(aPeriodos)+1))' )
aAdd(aProgAKQ, 'aRet[1][1] := "' + aNomeCpo[nCampo] + '"' )
aAdd(aProgAKQ, 'aCols[1] := 100' )
aAdd(aProgAKQ, '')
aAdd(aProgAKQ, 'nz := 2' )
aAdd(aProgAKQ, 'While nz <= Len(aCols)' )
aAdd(aProgAKQ, 'aRet[1][nz] := aPeriodos[nz-1]' )
aAdd(aProgAKQ, 'aCols[nz] := 70' )
aAdd(aProgAKQ, 'nz++' )
aAdd(aProgAKQ, 'EndDo' )
aAdd(aProgAKQ, '')
aAdd(aProgAKQ, 'aAdd(aAuxRet,{AKO->AKO_CO ,AKO->AKO_DESCRI})' )
aAdd(aProgAKQ, 'aVet:=PcoGerRetFilhos(AKO->AKO_CODIGO,AKO->AKO_CO)' )
aAdd(aProgAKQ, 'While nx <= Len(aVet)' )
aAdd(aProgAKQ, 'AKO->(dbGoto(aVet[nx]))' )
aAdd(aProgAKQ, 'aAdd(aAuxRet,{AKO->AKO_CO ,AKO->AKO_DESCRI } )' )
aAdd(aProgAKQ, 'nx++' )
aAdd(aProgAKQ, 'EndDo' )
aAdd(aProgAKQ, '')
aAdd(aProgAKQ, 'ProcRegua(Len(aAuxRet))')
aAdd(aProgAKQ, 'nx := 1' )
aAdd(aProgAKQ, 'While nx <= Len(aAuxRet)' )
aAdd(aProgAKQ, 'IncProc()' )
aAdd(aProgAKQ, 'dbSelectArea("TMPAK2")' )
aAdd(aProgAKQ, 'dbSetOrder(1)' )
aAdd(aProgAKQ, 'dbSeek(xFilial("AK2")+PadR(AKO->AKO_CODIGO, Len(AK1->AK1_CODIGO))+aAuxRet[nx][1])')
aAdd(aProgAKQ, '')
aAdd(aProgAKQ, 'While !Eof() .And. xFilial("AK2")+PadR(AKO->AKO_CODIGO, Len(AK1->AK1_CODIGO))+aAuxRet[nx][1]==TMPAK2->(AK2_FILIAL+AK2_ORCAME+AK2_CO)' )
aAdd(aProgAKQ, 'nPosIt := aScan(aRet,{|x| Substr(x[1],1,Len(TMPAK2->'+cCpoIt+')) == TMPAK2->'+cCpoIt+'})' )
aAdd(aProgAKQ, 'If nPosIt > 0' )
aAdd(aProgAKQ, 'nPosHead := aScan(aPeriodos,{|x| CToD(SubStr(x,1,10))==TMPAK2->AK2_PERIOD})' )
aAdd(aProgAKQ, 'If nPosHead > 0')

If nTipo == 1	// Total
	aAdd(aProgAKQ, 'If aRet[nPosIt][nPosHead+1] <> NIL' )
	aAdd(aProgAKQ, 'aRet[nPosIt][nPosHead+1] := PcoPlanCel(TMPAK2->AK2_VALOR+PcoPlanVal(aRet[nPosIt][nPosHead+1],AK2->AK2_CLASSE),TMPAK2->AK2_CLASSE)' )
	aAdd(aProgAKQ, 'Else' )              
	aAdd(aProgAKQ, 'aRet[nPosIt][nPosHead+1] := PcoPlanCel(TMPAK2->AK2_VALOR,TMPAK2->AK2_CLASSE)' )
	aAdd(aProgAKQ, 'EndIf' )
Else			// Acumulado
	aAdd(aProgAKQ, 'nv := nPosHead+1' )
	aAdd(aProgAKQ, '')
	aAdd(aProgAKQ, 'While nv <= Len(aCols)' )
	aAdd(aProgAKQ, 'If aRet[nPosIt][nv]<> Nil' )
	aAdd(aProgAKQ, 'aRet[nPosIt][nv] := PcoPlanCel(TMPAK2->AK2_VALOR+PcoPlanVal(aRet[nPosIt][nv],TMPAK2->AK2_CLASSE),TMPAK2->AK2_CLASSE)' )
	aAdd(aProgAKQ, 'Else'  )
	aAdd(aProgAKQ, 'aRet[nPosIt][nv] := PcoPlanCel(TMPAK2->AK2_VALOR,TMPAK2->AK2_CLASSE)' )
	aAdd(aProgAKQ, 'EndIf' )
	aAdd(aProgAKQ, 'nv++'  )
	aAdd(aProgAKQ, 'EndDo' )
	aAdd(aProgAKQ, '')	
EndIf	

aAdd(aProgAKQ, 'EndIf' )       
aAdd(aProgAKQ, 'Else' )
aAdd(aProgAKQ, 'aAdd(aRet,Array(Len(aPeriodos)+1))' )
aAdd(aProgAKQ, 'dbSelectArea("'+aDetalhe[1]+'")' )
aAdd(aProgAKQ, 'dbSetOrder('+aDetalhe[2]+' )')
aAdd(aProgAKQ, 'dbSeek(xFilial()+TMPAK2->'+cCpoIt+')' )       
aAdd(aProgAKQ, 'aRet[Len(aRet)][1] := '+aDetalhe[3]+' + " - " + AllTrim('+aDetalhe[4]+')' )
aAdd(aProgAKQ, '')
aAdd(aProgAKQ, 'ny := 2' )
aAdd(aProgAKQ, 'While ny <= Len(aPeriodos)+1' )
aAdd(aProgAKQ, 'aRet[Len(aRet)][ny] := PcoPlanCel(0,TMPAK2->AK2_CLASSE)' )
aAdd(aProgAKQ, 'ny++' )
aAdd(aProgAKQ, 'EndDo' )
aAdd(aProgAKQ, '')
aAdd(aProgAKQ, 'nPosHead := aScan(aPeriodos,{|x| CToD(SubStr(x,1,10))==TMPAK2->AK2_PERIOD})' )
aAdd(aProgAKQ, 'If nPosHead > 0' )

If nTipo == 1	// Total
	aAdd(aProgAKQ, 'If aRet[Len(aRet)][nPosHead+1]<> NIL' )
	aAdd(aProgAKQ, 'aRet[Len(aRet)][nPosHead+1] := PcoPlanCel(TMPAK2->AK2_VALOR+PcoPlanVal(aRet[Len(aRet)][nPosHead+1],TMPAK2->AK2_CLASSE),TMPAK2->AK2_CLASSE)' )
	aAdd(aProgAKQ, 'Else' )
	aAdd(aProgAKQ, 'aRet[Len(aRet)][nPosHead+1] := PcoPlanCel(TMPAK2->AK2_VALOR,TMPAK2->AK2_CLASSE)' )
	aAdd(aProgAKQ, 'EndIf' )
Else			// Acumulado
	aAdd(aProgAKQ, 'nv := nPosHead+1' )
	aAdd(aProgAKQ, 'While nv <= Len(aCols)' )
	aAdd(aProgAKQ, 'If aRet[Len(aRet)][nv]<> Nil' )
	aAdd(aProgAKQ, 'aRet[Len(aRet)][nv] := PcoPlanCel(TMPAK2->AK2_VALOR+PcoPlanVal(aRet[Len(aRet)][nv],TMPAK2->AK2_CLASSE),TMPAK2->AK2_CLASSE)' )
	aAdd(aProgAKQ, 'Else' )
	aAdd(aProgAKQ, 'aRet[Len(aRet)][nv] := PcoPlanCel(TMPAK2->AK2_VALOR,TMPAK2->AK2_CLASSE)' )
	aAdd(aProgAKQ, 'EndIf' )
	aAdd(aProgAKQ, 'nv++' )
	aAdd(aProgAKQ, 'EndDo' )
EndIf

aAdd(aProgAKQ, 'EndIf' )
aAdd(aProgAKQ, 'EndIf' )
aAdd(aProgAKQ, 'dbSelectArea("TMPAK2")' )
aAdd(aProgAKQ, 'dbSkip()' )
aAdd(aProgAKQ, '')
aAdd(aProgAKQ, 'EndDo' )
aAdd(aProgAKQ, 'nx++' )
aAdd(aProgAKQ, 'EndDo' )
aAdd(aProgAKQ, '')
aAdd(aProgAKQ, 'RestArea(aTrb_TMPAK2)' )
aAdd(aProgAKQ, 'RestArea(aTrb_AKO)' )
aAdd(aProgAKQ, 'RestArea(aTrb_'+aDetalhe[1]+')' )
aAdd(aProgAKQ, 'dbSelectArea(cTrbAlias)' )
aAdd(aProgAKQ, '')
aAdd(aProgAKQ, 'Return({aRet,aCols, nCols})' )

Return( aProgAKQ )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PCOA105Vld บAutor  ณ Gustavo Henrique บ Data ณ  09/12/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validar o preenchimento dos campos do Wizard               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1 : Valor para pesquisa nas tabelas do dicionario      บฑฑ
ฑฑบ          ณ ExpN1 : Tipo de pesquisa no dicionario.                    บฑฑ
ฑฑบ          ณ         1 - Dicionario de Tabelas (SX2)                    บฑฑ
ฑฑบ          ณ         2 - Dicionario de Indices (SIX)                    บฑฑ
ฑฑบ          ณ         3 - Dicionario de Campos  (SX3)                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Cadastro de Totais da Planilha e Visao Orcamentaria        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA105Vld( cValor, nTipo )

Local lRet		:= .T.
Local aAreaSX3	:= SX3->( GetArea() )
Local aAreaSX2  := SX2->( GetArea() )
Local aAreaSIX  := SIX->( GetArea() )

SX3->( dbSetOrder( 2 ) )

Do Case

	Case nTipo == 1		// SX2
		lRet := SX2->( dbSeek( cValor ) )
	
	Case nTipo == 2		// SIX
		lRet := SIX->( dbSeek( cValor ) )
	
	Case nTipo == 3		// SX3                
		nPosRef := At( ">", cValor ) + 1
		If nPosRef > 0
			cValor := SubStr( cValor, nPosRef, Len( cValor ) )
		EndIf	  
		
		lRet := SX3->( dbSeek( cValor ) )

EndCase

If ! lRet
	Help( "", 1, "REGNOIS" )
EndIf	

RestArea( aAreaSX3 )
RestArea( aAreaSX2 )
RestArea( aAreaSIX )

Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Ana Paula N. Silva     ณ Data ณ10/12/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ		1 - Pesquisa e Posiciona em um Banco de Dados         ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function MenuDef()
Local aRotina 	:= {	{ STR0002, "AxPesqui"  , 0, 1, ,.F.},;  //"Pesquisar"
							{ STR0003, "Pcoa105Brw", 0, 2},;  //"Visualizar"
							{ STR0004, "Pcoa105Brw", 0, 3},;  //"Incluir"
							{ STR0005, "Pcoa105Brw", 0, 4},;  //"Alterar"
							{ STR0006, "Pcoa105Brw", 0, 5} }  //"Excluir"
Return(aRotina)							
                           
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCO105Tok บAutor  ณAlexandre Circenis  บ Data ณ  07/03/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida os preenchimento dos campos do wizard no momento da บฑฑ
ฑฑบ          ณ confirmacao final do wizard                                บฑฑ
ฑฑบ          ณ Essa validacao foi incluida para que o bloco de codigo     บฑฑ
ฑฑบ          ณ gerado nao venha incompleto causando problemas nas rotinas บฑฑ
ฑฑบ          ณ pcor020, pcor040, pcor050, pcor060, Na montagem da Planilhaบฑฑ
ฑฑบ          ณ orcamentaria.                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PCO105Tok(aParam3, aConfig3)
local nX
Local lRet := .T. 
Local cMsg := "" 
Local nCount := 0

for nX := Len(aParam3) to 1 STEP -1 
	if Empty( aConfig3[nX])
		cMsg := " "+ aParam3[nX, 2] + If(!Empty(cMsg),If (nCount>1,",", " e"), "") +cMsg
		lRet := .F.
		nCount++
	endif
next

if !lRet
	HELP(" ",1,"PCO105TOK",, STR0061 + cMsg,1,0) //"Os seguintes campos devem ser preenchidos:"	
endif      

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA105VDEบAutor  ณAlexandre Circenis  บ Data ณ  03/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida o campo de descri็ใo                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA105VDE(cDesc, nTam)
Local lRet := .T.               

if Len(Alltrim(cDesc)) > nTam
	HELP(" ",1,"PCO105VDE",,STR0063+" "+Alltrim(Str(nTam,3,0))+" "+STR0064 ,1,0) //A descri็ใo ultrapassou o tamanho Maximo permitido de ## caracteres	
	lRet := .F.
endif           

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOXFUN   บAutor  ณMicrosiga           บ Data ณ  02/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoRetFilhos(corcame,cVersao,cCO,aRet)
Local aArea	:= GetArea()
Local aAreaAK3	:= AK3->(GetArea())
DEFAULT aRet := {}

If aRet == Nil .And. !Empty(aRet)
	aRet := {}	
	dbSelectArea("AK3")
	dbSetOrder(1)
	MsSeek(xFilial()+cOrcame+cVersao+cCO)
	aAdd(aRet,AK3->(RecNo()))
EndIf

dbSelectArea("AK3")
dbSetOrder(2)
MsSeek(xFilial()+cOrcame+cVersao+cCO)
While !Eof() .And. AK3->AK3_FILIAL+AK3->AK3_ORCAME+AK3->AK3_VERSAO+AK3->AK3_PAI==xFilial("AK3")+cOrcame+cVersao+cCO
	aAdd(aRet,AK3->(RecNo()))
	PcoRetFilhos(AK3->AK3_ORCAME,AK3->AK3_VERSAO,AK3->AK3_CO,aRet)	
	dbSelectArea("AK3")
	dbSkip()
End

RestArea(aAreaAK3)
RestArea(aArea)
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOXFUN   บAutor  ณMicrosiga           บ Data ณ  02/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoRetRGB(R,G,B)

Return RGB(R,G,B)
