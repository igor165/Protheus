#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKA510A.CH"
#INCLUDE "TCBROWSE.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "TMKDEF.CH"    

#DEFINE NUMITENS 9999		//Nr. maximo de Itens na MsGetDados 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHelpDeskListDialogบAutor  ณVendas Clientes     บ Data ณ  18/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de gerenciamento de pendencias                                บฑฑ
ฑฑบ          ณ                                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class HelpDeskListDialog

	DATA oGetDados																		// Objeto GetDados
	DATA oCheckBox																		// Objeto do checkbox
	DATA oObj																			// Objeto de tela
	DATA aYesFields																		// Define quais os campos que serao mostrados
	DATA aColsADE                                                                       // Colunas da GetDados
	DATA aHeaderADE																		// Cabecalho da GetDados
	DATA aPosObj																		// Posicao da Tela
	DATA aInfo																			// Array com as coordenadas 
	DATA aObjects  																		// Array do objeto
	DATA aSize																			// Array com a dimensao de tela
	DATA aColsOrder																		// Colunas e ordem de exibi็ใo
	DATA cAliasUser    																	// Tabela ser utilizada
	DATA cTabelaAux																		// Tabela Auxiliar
	DATA cTabelaFlw							  											// Tabela Auxiliar de Follow Up
	DATA oDlg																			// Objeto de tela
	DATA lSupervisor																	// Indica se e um supervisor
	DATA cOperador
	DATA cPosto
	DATA nOrder
	DATA cFilter																		//Armazena o filtro configurado pelo usuแrio
	DATA cBrwFilter																		//Armazena o filtro utilizado pelo Browse
	DATA aCores	
	DATA aStatusSLA																		//Bitmaps com cores dos status do SLA
	DATA aPercSLA																		//Percentuais transcorridos de SLA
	DATA aBkpSetkey																		//Armazena a funcao padrao associado ao botao de atalho do sistema
	Data lViewTeamTask																	//Indica se o analista visualizara as pendencias da Equipe
	Data lViewAll																		//visualiza todos os chamados da empresa
	Data lSelectAll																		//Seleciona todos os chamados
	Data cTeamOper																		//Armazena a string de busca dos analista da equipe
	Data aRecnoAnt
	Data nRecnoPos
	Data nMaxRowsPerPage
	Data aIniBrwFields
	Data cPagePos
	Data cPagePosBkp          
	Data cPageTot 
	Data aSetField
	Data aSQLFields																		// Armazena todos os campos reais da tabela
	Data cSQLFields																		// Armazena todos os campos reais da tabela em formato SQL
	Data MV_PAR01																		// MV_PAR01 - Do Chamado                                                         ณ
	Data MV_PAR02																		// MV_PAR02 - Ate o chamado                                                      ณ
	Data MV_PAR03																		// MV_PAR03 - Do Cliente                                                         ณ
	Data MV_PAR04																		// MV_PAR04 - Da Loja                                                            ณ	
	Data MV_PAR05																		// MV_PAR05 - Ate o Cliente                                                      ณ
	Data MV_PAR06																		// MV_PAR06 - Ate a Loja                                                         ณ	
	Data MV_PAR07																		// MV_PAR07 - De                                                        		 ณ
	Data MV_PAR08																		// MV_PAR08 - Ate                                                                ณ
	Data MV_PAR09																		// MV_PAR09 - Do Analista                                               		 ณ
	Data MV_PAR10 																		// MV_PAR10 - Ate o Analista                                                     ณ		
	Data MV_PAR11 																		//ณMV_PAR11 - Qtd chamados p/ pagina ?                                           ณ	
	Data MV_PAR12																		//ณMV_PAR12 - Status de chamados a serem exibidos                                ณ		
	Data oTimer																			// Objeto Timer
	Data oCustomProfile																	// Objeto Memo para exibir a descri็ใo do perfil da entidade
	Data cCustomProfile																	// Campo texto a ser exibido no perfil da entidade
	Data oIncident																		// Objeto Memo para exibir o incidente do chamado
	Data cIncident																		// Campo texto a ser exibido no incidente
	Data aShortcutMap																	// Relacao de rotinas e teclas de atalho
	Data nTotal																			// Guarda o Total de registros exibidos
	Data oTotal																			// Objeto que vai exibir o total de registros
	Data lWereIncluded																	// Se houve alguma inclusใo de chamado
	Data aFollowUp                                                                      // Chamados com indicacao de Follow Up
	Data oListFollow                                                                    // Objeto LISTBOX que contem os chamados com Follow-Up
	Data cRed
	Data cGray
	Data cBlue
	Data cGreen
	Data cOrange
	Data cBlack
	Data cWhite
	Data cYellow
	Data oTFolder																		// Objeto TFolder
	Data oTEdit																			// Objeto TSimpleEditor
		
	Method New() Constructor															// Metodo Construtor
	Method Tk510Tela()																	// Tela principal
	Method IniciaVar()																	// Inicializa as variaveis						
	Method Tk510ACols()																	// Regra para se montar o aCols
	Method Tk510ProACols()																// Regra para se montar o aCols
	Method Tk510Filtra()																// Monta a query para carregar o aCols
	Method BuildAcols()																	// Adiciona informacoes na aCols
	Method Tk510TaskBar( bOk, bCancel, aIdxEval )										// Cria a barra de botoes
	Method Tk503chkBox()																// Faz o controle do checkbox
	Method TK510Funcoes( nOpc, aIdxEval ) 												// Funcoes de tela
	Method GetFieldPos(cField, nPos, aAuxHeader)
	Method Distribute()
	Method TransfLote()
	Method EncerraLote()
	Method AssumeLote()
	Method Transfer()           
	Method AlterOp(cCodCall, cAgent, cPosto)
	Method TkOrder(cPos, aIdxEval)
	Method DialogLabel()
	Method Tk510Filt()
	Method SetFilter()
	Method SetAtalho(aIdxEval)
	Method RestAtalho()
	Method Find()
	Method pgNext()
	Method pgPrevious()
	Method pgFirst()
	Method pgLast()
	Method posPage(cFieldName, xValue)
	Method getMaxRowsPP()
	Method setParameters()
	Method Refresh()
	Method ConfigCols()																	// Manuten็ใo da ordem das colunas e sua exibi็ใo.
	Method ChangeColsOrder()                                       						// Ordena o aHeader para a exibi็ใo das colunas de acordo com o configurado.
	Method SaveConfig()																	// Salva as configura็๕es de exibi็ใo do service desk.
	Method LoadConfig()																	// Carrega as configura็๕es de exibi็ใo do service desk.
	Method LoadProfile()																// Carrega as informa็๕es do perfil da entidade.
	Method SetProfile()																	// Carrega as informa็๕es do perfil da entidade.
	Method LoadIncident()																// Carrega as informa็๕es do incidente relatado no chamado.
	Method SetIncident()																// Carrega as informa็๕es do incidente relatado no chamado.
	Method Associar()																	// Associar o chamado aos outros chamados marcados
	Method LoadFilter()																	// Carrega os filtros salvos para o usuario atual
	Method AddFilter()																	// Adiciona Filtros aos filtros do usuario
	Method EditFilter()																	// Edita o filtro selecionado pelo operador
	Method DelFilter()																	// Apaga o filtro selecionado pelo usuario
	Method SelectCall(lUnLock)															// Marca ou desmarca todos os chamados
	Method Shortcut()																	// Retorna a tecla de atalho para uma rotina
	Method RefreshTotPage()																// Atualiza o total de pแginas quando um filtro ้ utilizado.
	Method Free()
	Method Duplicate()																	// Duplica o chamado selecionado
	Method LoadDetalhes()																// Carrega os detalhes do chamado
	Method SetDetalhes()																// Carrega os detalhes do chamado
	
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNew       บAutor  ณVendas Clientes     บ Data ณ  18/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Metodo construtor                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New() Class HelpDeskListDialog
Local aOpcoes := {STR0015, STR0016} //"Analista" # "Equipe"
Local aBkpCores	:= {}
Local oDlgOper    
Local oCbx 
Local cCbx := ""
Local nSelected := 1     
Local lEnable 	:= .F.
Local nX		:= 0
Local cLegsSLA	:= SuperGetMv("MV_TMKLEGS",,"1=50;2=70;3=80;4=100")
Local nCores	:= 0

	Self:cRed	:= TMKChkColor("BR_VERMELHO")
	Self:cGray	:= TMKChkColor("BR_CINZA")
	Self:cBlue	:= TMKChkColor("BR_AZUL")
	Self:cGreen	:= TMKChkColor("BR_VERDE")
	Self:cOrange:= TMKChkColor("BR_LARANJA")
	Self:cBlack := TMKChkColor("BR_BLACK")
	Self:cWhite	:= TMKChkColor("BR_BRANCO")
	Self:cYellow:= TMKChkColor("BR_AMARELO")

	Self:oDlg			:= Nil
	Self:oGetDados		:= Nil
	Self:oObj			:= TeleServiceUserDialog():New()
	Self:aYesFields    	:= {}
	Self:aColsADE		:= {}
	Self:aHeaderADE		:= {}
	Self:aPosObj		:= {}
	Self:aInfo			:= {}
	Self:aObjects  		:= {}
	Self:aSize			:= {} 
	Self:aFollowUp      := {}
	Self:cAliasUser    	:= "ADE"
	Self:cTabelaAux		:= ""
	Self:cTabelaFlw		:= ""
	Self:cOperador 		:= 	TkOperador()													// Retorna o operador que esta acessando a tela de pendencias
	Self:cFilter		:= ""
	Self:cBrwFilter		:= ""
	Self:aCores			:= 	{	{"!Empty(ADE->ADE_DTEXPI) .AND. Tk510LegendRed()" 	, Self:cRed		},;		//Prazo de SLA ultrapassado
								{"Empty( ADE->ADE_OPERAD )" 						, Self:cGray	},;		//Chamado nใo distribuido
 								{"ADE->ADE_STATUS == '2'"							, Self:cBlue	},;		//Chamado Pendente
 								{"ADE->ADE_STATUS == '1'"							, Self:cGreen	}}		//Chamado em aberto
	Self:aBkpSetkey		:= {} 
	Self:lViewTeamTask	:= .F.								
	Self:cPosto		:= ""
	Self:aRecnoAnt	:= {}
	Self:nRecnoPos	:= 0
	Self:nOrder		:= 1
	Self:nMaxRowsPerPage	:= 10
	Self:aIniBrwFields	:= {}
	Self:cPagePos	:= "1     " 
	Self:cPagePosBkp	:= "1      " 
	Self:aSetField	:= {} 
	Self:aSQLFields	:= {}
	Self:cSQLFields	:= ""
	Self:lViewAll	:= .F.
	Self:cCustomProfile := ""
	Self:cIncident	:= ""
	Self:aStatusSLA	:= {Self:cGreen,Self:cYellow,Self:cOrange,Self:cRed} //Verde,Amarelo,Laranja e Vermelho 	
 	Self:aPercSLA 	:= StrToKArr(cLegsSLA,';')
 	Self:aShortcutMap := {}     
 	Self:lWereIncluded := .F.
	
	//Adiciona legenda para chamados recorrentes

	aBkpCores	:= aClone(Self:aCores)
	Self:aCores	:= {}
	aAdd(Self:aCores,{"ADE->ADE_RECORR == '1'", Self:cWhite})
	For nX := 1 to Len(aBkpCores)
		AAdd(Self:aCores,aBkpCores[nX])
	Next nX

	 	
 	//Garante que serao apenas 4 cores em uso
 	nCores := Len(Self:aPercSLA)
 	If nCores <> 4
 		aSize(Self:aPercSLA,4)
 		For nX := nCores+1 to 4
 			Self:aPercSLA[nX] := "99=0"
 		Next nX
 	EndIf

 	//Ordena os valores
 	aSort(Self:aPercSLA,,,{|x,y| Left(x,1)< Left(y,1)})
 	
 	For nX := 1 to Len(Self:aPercSLA)
 		Self:aPercSLA[nX] := Val(SubStr(Self:aPercSLA[nX],Rat("=",Self:aPercSLA[nX])+1,Len(Self:aPercSLA[nX])))
 	Next nX
	
	DbSelectArea("SU7")
	DbSetOrder(4)
	If MsSeek(xFilial("SU7")+__cUserId)
		Self:cPosto			:= 	SU7->U7_POSTO	// Posiciona e retorna o valor do U7_POSTO	
		//Self:cOperador		:= 	SU7->U7_COD
		If SU7->U7_TIPO == "2"
			Self:lSupervisor	:=	.T.
		Else
			Self:lSupervisor	:=	.F.		
		EndIf   
		//If SU7->U7_TIPOATE == "4" .OR. SU7->U7_TIPOATE == "6"	//TODOS OU TELEATENDIMENTO
			lEnable := .T.
		//EndIf		
	EndIf  
             
	If lEnable
		DbSelectArea("SU0")
		DbSetOrder(1)
		If MsSeek(xFilial("SU0")+Self:cPosto)
			If SU0->U0_PENDCHA == "1" 
				Self:lViewTeamTask	:=  .F.
			ElseIf SU0->U0_PENDCHA == "2" //Equipe/Analista  
				Self:lViewTeamTask	:=  .T.				
			ElseIf SU0->U0_PENDCHA == "4"  
				Self:lViewTeamTask	:=  .T.
				If Self:lSupervisor
					Self:lViewAll	:= .T.
				EndIf
			ElseIf SU0->U0_PENDCHA == "3"
				
				If Self:lSupervisor //Pergunte	
					aAdd(aOpcoes, "Todos")
				EndIf
			
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//|Pega o ramal e o LinkID da estacao |
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				DEFINE MSDIALOG oDlgOper FROM 0,0 TO 160,200 PIXEL TITLE "Service Desk" //"Dados da esta็ใo"
				
					@ 05,10 SAY STR0017 SIZE 80,15 OF oDlgOper PIXEL //"Informe quais pendencias serใo apresentadas :"
					@ 25,10 MSCOMBOBOX oCbx VAR cCbx ITEMS aOpcoes SIZE 075, 65 OF oDlgOper PIXEL ON CHANGE nSelected := oCbx:nAt		                   
				
					@ 45,25 BUTTON STR0018 SIZE 40,12 OF oDlgOper PIXEL ACTION oDlgOper:End();nSelected := oCbx:nAt //"Confirmar"
						
				ACTIVATE MSDIALOG oDlgOper CENTER 		
				If nSelected  == 1 //Analista
					Self:lViewTeamTask	:=  .F.			
				ElseIf nSelected  == 2 //Equipe                  
					Self:lViewTeamTask	:=  .T.
				ElseIf nSelected  == 3 //Todos
				   	Self:lViewAll	:= .T.	                  
				EndIf 
			EndIf
		EndIf
		
		/*If Self:lViewTeamTask				
			#IFDEF TOP		
				cQuery := "	SELECT * FROM " + RetSQLName("SU7") + " SU7"
				cQuery += "	WHERE SU7.U7_FILIAL = '" + xFilial("SU7") + "' AND"
				cQuery += "	SU7.U7_POSTO 	= '" + Self:cPosto + "' AND"                     
				cQuery += "	SU7.D_E_L_E_T_<>'*'"
			
				cQuery := ChangeQuery(cQuery)
				DbSelectArea("SU7")
				DbCloseArea()		
				DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "SU7", .F., .T.)		
			#ELSE       		
				DbSelectArea("SU7")
				DbSetOrder(1)
				DbGoTop()    
			#ENDIF                
			
			Self:cTeamOper := ""
			While SU7->(!EOF())
				If SU7->U7_POSTO == Self:cPosto
				    Self:cTeamOper += SU7->U7_COD + ","
				EndIf
				DbSkip()
			End	                                         
			If !Empty(Self:cTeamOper)
				Self:cTeamOper := Left(Self:cTeamOper,Len(Self:cTeamOper)-1) //Tira a ultima virgula da string		
	    	Endif		
			DbSelectArea("SU7")
			DbCloseArea()	 
			DbSelectArea("SU7")
			DbSetOrder(1)			
	    	
		EndIf	*/
	EndIf

Return Self


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk510Tela บAutor  ณVendas Clientes     บ Data ณ  18/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria a tela                                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Tk510Tela() Class HelpDeskListDialog
Local oCombo	:= Nil
Local oComboFil	:= Nil  
Local oLayer    := Nil
Local oRodape   := Nil 
Local oDlgIncid := Nil
Local oDlgObs   := Nil   
Local oDlgFollow:= Nil
Local cAgent  	:= ""
Local cFiltro	:= ""
Local aItems 	:= {}
Local aFiltros	:= {{},{},{}}
Local cIdxCampo := ""		
Local iAux		:= 0
Local aIndex	:= {}
Local nIndex	:= 0
Local lTK510FIL := ExistBlock("TK510FIL")
Local lTK510COR := ExistBlock("TK510COR")
Local cAt510Fil := ""
Local aTK510COR	:= {}
Local aBkpSetkey:= Array(3)
Local nIt		:= 0     
Local cTitle 	:= ""    
Local nItens 	:= 0  
Local lMarca	:= .F. 
Local nSecsRef	:= SuperGetMv("MV_TMKREFR",,180000)
Local oPanel 	:= Nil 
Local lECMFTPP  := SuperGetMv("MV_ECMFTPP",.T.,21)
Local nTop   	:= 0
Local nBottom	:= 0  
Local aTFolder := {STR0186,STR0187}       			 // Geral | Detalhe do chamado
                 
Private aIdxEval := {}
Private aIdxChave:= {}
                    
Self:oObj:service := TeleServicing():New() 
Self:oObj:service:load( Self:oObj:GetModel() ) 

If Self:oObj:service:tableStructureInfo:master:alias == "ADE"

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCarga dos filtros salvos para o usuarioณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aFiltros := Self:LoadFilter()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPergunte - TMK510A                                                            ณ
	//ณMV_PAR01 - Do Chamado                                                         ณ
	//ณMV_PAR02 - Ate o chamado                                                      ณ
	//ณMV_PAR03 - Do Cliente                                                         ณ
	//ณMV_PAR04 - Da Loja                                                            ณ	
	//ณMV_PAR05 - Ate o Cliente                                                      ณ
	//ณMV_PAR06 - Ate a Loja                                                         ณ	
	//ณMV_PAR07 - De                                                        		 ณ
	//ณMV_PAR08 - Ate                                                                ณ
	//ณMV_PAR09 - Do Analista                                               		 ณ
	//ณMV_PAR10 - Ate o Analista                                                     ณ	
	//ณMV_PAR11 - Qtd chamados p/ pagina ?                                           ณ	
	//ณMV_PAR12 - Status de chamados a serem exibidos                                ณ		
	//ณMV_PAR13 - Exibe a tela de parametros ao acessar o Service Desk ?             ณ		
	//ณMV_PAR14 - Exibir todos os meus grupos?                                       ณ		
	//ณMV_PAR15 - Utiliza Follow Up ?                                                ณ		
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Pergunte("TMK510A",.F.)
	
	If MV_PAR13 == 1 .AND. !Pergunte("TMK510A",.T.)	
		Return()		
	EndIf
	
	Self:setParameters()    
	Self:nMaxRowsPerPage := Self:getMaxRowsPP()

	nOpc := 2
	
	If lTK510COR              
		aTK510COR := ExecBlock("TK510COR",.F.,.F., {Self:aCores})
		If ValType(aTK510COR) == "A" .AND. Len(aTK510COR) > 0
			Self:aCores := aClone(FWChkColor(aTK510COR))
		EndIf
	EndIf
	
	If lTK510FIL                                                        
		cAt510Fil := ExecBlock("TK510FIL",.F.,.F.)
		If ( ValType(cAt510Fil) == "C" ) .And. !Empty(cAt510Fil)
			Self:cBrwFilter := cAt510Fil
		EndIf			
	EndIf		

	//Inclui os filtros da tela atraves do arquivo SIX.
	DbSelectArea("SIX")
	DbSetOrder(1)
	If DbSeek("ADE")
		nIndex := 1
		While (SIX->(!EOF()) .AND. SIX->INDICE == "ADE")				
			nItens++
			If SIX->SHOWPESQ == "S"
				aIndex := {}
				cIdxCampo := SIX->CHAVE
				cIdxCampo += "+"
				While .T.
					iAux := At("+", cIdxCampo)
					If iAux <= 0
						Exit		
					EndIf		       
					aAdd(aIndex, {AllTrim(SubStr(cIdxCampo, 0, iAux-1)),""})	
					cIdxCampo :=	SubStr(cIdxCampo, iAux+1, Len(cIdxCampo))
				End
				For nIt := 2 To Len(aIndex)						
					iAux := AScan(Self:aHeaderADE, &("{|x|AllTrim(x[2])=='"+ AllTrim(aIndex[nIt][1]) +"'}") )	
					aIndex[nIt][2] := iAux 
				Next nIt                               
				
				cIdxCampo := ""
				cLIdxCampo := ""				
				For nIt := 2 To Len(aIndex)		 
					If aIndex[nIt][2] > 0 
						iAux := AllTrim(Str(aIndex[nIt][2]))
						If Empty(cLIdxCampo)				
							cLIdxCampo += "AllTrim(x[" + iAux + "])"
						Else
							cLIdxCampo += "+ AllTrim(x[" + iAux + "])"
						EndIf
					EndIf
				Next nIt								

				cRIdxCampo := ""				
				For nIt := 2 To Len(aIndex)		 
					If aIndex[nIt][2] > 0 
						iAux := AllTrim(Str(aIndex[nIt][2]))
						If Empty(cRIdxCampo)				
							cRIdxCampo += "AllTrim(y[" + iAux + "])"
						Else
							cRIdxCampo += "+ AllTrim(y[" + iAux + "])"
						EndIf
					EndIf
				Next nIt					
				cIdxCampo := "{|x,y|(" + cLIdxCampo + ")<(" + cRIdxCampo + ")}"			 
													
				aAdd(aIdxEval, cIdxCampo)                    
				aAdd(aItems, AllTrim(Str(nIndex)) + "=" + SIX->DESCRICAO)
				//aAdd(aIdxChave, SIX->ORDEM)                             
				aAdd(aIdxChave, AllTrim(Str(nItens)))                             
				nIndex++
			EndIf
			SIX->(DbSkip())
		End
	EndIf     

	// Inicializa as variaves de tela
	Self:IniciaVar()		
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInforma ao gerenciador de m๚ltiplos grupos de atendimentoณ
	//ณque a rotina service desk estแ em execu็ใo.              ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	TK091Start( SERVICEDESK )
			  		
	DbSelectArea( Self:cAliasUser ) 
	If Self:lSupervisor		
		cTitle := " - [" + STR0019 + "]" //Supervisor
	EndIf
	DEFINE MSDIALOG Self:oDlg TITLE STR0225 + " - " + TK091Titulo(Self:cOperador) + cTitle FROM Self:aSize[7],0 TO Self:aSize[6],Self:aSize[5] OF oMainWnd PIXEL STYLE nOR( WS_VISIBLE ,DS_MODALFRAME )	//"Central de Servi็os"
	Self:oDlg:lMaximized := .T.

	oPanel:= tPanel():New(0,0,,Self:oDlg,,,,,,0,0)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAjusta o posicionamento da MsNewGetDados conformeณ
    //ณposicionamento da EnchoiceBar.                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nBottom := 80 
	nTop := -10
	
	@ 07,04  SAY STR0020 PIXEL SIZE 55,9 OF oPanel		// "Ordem :"
	oCombo := TComboBox():New(05,29,{|u|if(PCount()>0,cAgent:=u,cAgent)},aItems,100,20,oPanel,,{||Self:TkOrder(Val(cAgent), aIdxEval)},,,,.T.,,,,,,,,,'cAgent')
	
	@ 07,132 SAY STR0089 PIXEL SIZE 55,9 Of oPanel //"Filtro :"
	oComboFil := TComboBox():New(05,152,{|u|if(PCount()>0,cFiltro:=u,cFiltro)},aFiltros[1],100,20,oPanel,,,,,,.T.,,,,,,,,,'cFiltro')	
	
	TBtnBmp2():New (08,507,25,25,"FILTRO1",,,,{||Self:cFilter := aFiltros[2,oComboFil:nAt],Self:TK510Funcoes(8,aIdxEval)},oPanel,STR0090) //"Executa o filtro selecionado"
	TBtnBmp2():New (08,532,25,25,"BMPINCLUIR",,,,{||If(Self:AddFilter(@oComboFil,@aFiltros),Self:TK510Funcoes(8,aIdxEval),.F.)},oPanel,STR0091) //"Incluir filtro"
	TBtnBmp2():New (08,558,25,25,"NOTE",,,,{||If(Self:EditFilter(@oComboFil,@aFiltros),Self:TK510Funcoes(8,aIdxEval),.F.)},oPanel,STR0092) //"Editar o filtro selecionado"
	TBtnBmp2():New (08,583,25,25,"EXCLUIR",,,,{||If(Self:DelFilter(@oComboFil,@aFiltros),Self:TK510Funcoes(8,aIdxEval),.F.)},oPanel,STR0093) //"Excluir o filtro selecionado"

	oTk510Tela:oGetDados := MsNewGetDados():New(Self:aPosObj[1,1]+nTop, Self:aPosObj[1,2], Self:aPosObj[1,3]-nBottom, Self:aPosObj[1,4], ;
												0, /*"Tk510ALinOk"*/, /*"Tk510ATudOk"*/,,,,4096,,,,oPanel,Self:aHeaderADE, Self:aColsADE)

	oTk510Tela:OGETDADOS:NAT := 1   
	
	Self:oCheckBox := TCheckBox():New(Self:aPosObj[1,3]-75,Self:aPosObj[1,2],STR0102,{|u| If(PCount()>0,Self:lSelectAll:=u,Self:lSelectAll)},oPanel,109,09,,{||Self:SelectCall()},,,,,,.T.) //"Marca/Desmarca todos"
	@ Self:aPosObj[1,3]-75,(Self:oDlg:NCLIENTWIDTH/2)-40 SAY oTotal PROMPT STR0118 + " " + CValToChar(Self:nTotal) OF oPanel PIXEL SIZE 150,10
	
	oRodape := TPanel():New(Self:aPosObj[2,1]-70,Self:aPosObj[2,2],'',oPanel,,.T.,.T.,,,oPanel:nClientWidth/2-10,oPanel:nClientHeight/2-(Self:aPosObj[1,3]-35),.F.,.F. )	
		
	Self:oTFolder := TFolder():New(0,0,aTFolder,,oRodape,,,,.T.,,(oRodape:nClientWidth/2),(oRodape:nClientHeight/2))
   	Self:oTFolder:Align := CONTROL_ALIGN_ALLCLIENT	    
    Self:oTFolder:bSetOption :={|nFSel| If(nFSel==2,Self:LoadDetalhes(),"") }
    
    @ 12,Self:aPosObj[1,4]*1.9-210	BTNBMP RESOURCE "PGPREV" 		SIZE 40,20  OF oPanel PIXEL MESSAGE STR0021	WHEN Len(Self:aRecnoAnt)>1 ACTION Eval({||Self:pgFirst()})   //"Primeira pแgina"
	@ 12,Self:aPosObj[1,4]*1.9-175	BTNBMP RESOURCE "PMSSETAESQ"	SIZE 30,20  OF oPanel PIXEL MESSAGE STR0022	WHEN Len(Self:aRecnoAnt)>1 ACTION Eval({||Self:pgPrevious()})  //"Pแgina anterior"
	
	@ 05,Self:aPosObj[1,4]-103 MSGET oPagePos VAR Self:cPagePos Picture "@999999" OF oPanel PIXEL VALID {||Self:posPage(, , .T., Val(Self:cPagePos))} When .T. SIZE 25 ,9 	
	@ 05,Self:aPosObj[1,4]-070 MSGET oPagePos VAR Self:cPageTot Picture "" OF oPanel PIXEL VALID {||} When .F. SIZE 25 ,9 	
	@ 07,Self:aPosObj[1,4]-075 SAY "/" PIXEL SIZE 55,9 OF oPanel				
	
	@ 12,Self:aPosObj[1,4]*1.9-25	BTNBMP RESOURCE "PMSSETADIR" 	SIZE 30,20  OF oPanel PIXEL MESSAGE STR0023 	WHEN Self:nRecnoPos>0 ACTION Eval({||Self:pgNext()})  //"Pr๓xima pแgina"
	@ 12,Self:aPosObj[1,4]*1.9		BTNBMP RESOURCE "PGNEXT" 		SIZE 40,20  OF oPanel PIXEL MESSAGE STR0024	WHEN Self:nRecnoPos>0 ACTION Eval({||Self:pgLast()})  //"ฺltima pแgina"
	
    // Pasta - Geral
	oLayer := FWLayer():New() 
	oLayer:Init(Self:oTFolder:aDialogs[1],.F.,.T.)           
	
	// Pasta - Detalhe do Chamado
	Self:oTEdit := TSimpleEditor():New(0,0,Self:oTFolder:aDialogs[2],(oRodape:nClientWidth/2)-2,(oRodape:nClientHeight/2)-30,,.F.)
	                                     
	#IFDEF TOP
	If (MV_PAR15 == 2) 
	#ENDIF
		oLayer:AddCollumn("INCIDENTE",50,.T.)
		oLayer:AddWindow("INCIDENTE","oDlgIncid",STR0103,100,.F.,.T.,,,{ || }) //"Incidente"
		oDlgIncid := oLayer:GetWinPanel("INCIDENTE","oDlgIncid")
		@ 001,001 GET Self:oIncident Var Self:cIncident SIZE (oDlgIncid:nClientWidth/2)-4,oDlgIncid:nClientHeight/2-5  OF oDlgIncid MULTILINE NO VSCROLL Pixel READONLY

		oLayer:AddCollumn("OBSERVACOES",50,.T.)
		oLayer:AddWindow("OBSERVACOES","oDlgObs",STR0080,100,.F.,.T.,,,{ || }) //"Observa็๕es do Perfil:"
		oDlgObs := oLayer:GetWinPanel("OBSERVACOES","oDlgObs")
		@ 001,001 GET Self:oCustomProfile Var Self:cCustomProfile SIZE oDlgObs:nClientWidth/2-4,oDlgObs:nClientHeight/2-5  OF oDlgObs MULTILINE NO VSCROLL Pixel READONLY

	#IFDEF TOP 
	Else
		oLayer:AddCollumn("INC",35,.F.)
		oLayer:AddWindow("INC","oDlgIncid",STR0103,100,.F.,.T.,,,{ || }) //"Incidente"
		oDlgIncid := oLayer:GetWinPanel("INC","oDlgIncid")
		@ 001,001 GET Self:oIncident Var Self:cIncident SIZE 100,100  OF oDlgIncid MULTILINE NO VSCROLL Pixel READONLY
		Self:oIncident:Align := CONTROL_ALIGN_ALLCLIENT	
                                              
		oLayer:AddCollumn("OBS",35,.F.)
		oLayer:AddWindow("OBS","oDlgObs",STR0080,100,.F.,.T.,,,{ || }) //"Observa็๕es do Perfil:"
		oDlgObs := oLayer:GetWinPanel("OBS","oDlgObs")
		@ 001,001 GET Self:oCustomProfile Var Self:cCustomProfile SIZE 10,10  OF oDlgObs MULTILINE NO VSCROLL Pixel READONLY
		Self:oCustomProfile:Align := CONTROL_ALIGN_ALLCLIENT
		
		oLayer:SetColSplit("OBS", CONTROL_ALIGN_LEFT)
				
		oLayer:AddCollumn("FOLLOWUP",30,.F.)
		oLayer:AddWindow("FOLLOWUP","oDlgFollow",STR0171,100,.F.,.T.,,,{ || }) //"Follow Up"
		oDlgFollow := oLayer:GetWinPanel("FOLLOWUP","oDlgFollow")

		oLayer:SetColSplit("FOLLOWUP", CONTROL_ALIGN_LEFT)
		
		Self:oListFollow:= TWBrowse():New(1,1,1,1,,{STR0172,STR0171},,oDlgFollow,,,,,; //"Chamado"###"Follow Up"
			{|| Iif(!Empty(Self:oListFollow:aArray[Self:oListFollow:nAt][1]),Self:TK510Funcoes( 4, aIdxEval, Self:oListFollow:aArray[Self:oListFollow:nAt][1]),.F.) },,,,,,,.F.,,.T.,,.F.,,,)

		Self:oListFollow:Align := CONTROL_ALIGN_ALLCLIENT 
				
		If Len(Self:aFollowUp) <= 0
			AAdd(Self:aFollowUp,{"",""})
		Else
			ASort(Self:aFollowUp,,,{|x,y| x[2] < y[2] })
		EndIf
	
		Self:oListFollow:SetArray(Self:aFollowUp)
		Self:oListFollow:bLine := {||{	Self:aFollowUp[Self:oListFollow:nAt][1],;
										Self:aFollowUp[Self:oListFollow:nAt][2] }}
								
	EndIf	
	#ENDIF

	oTk510Tela:oGetDados:oBrowse:bLdblclick := {||oTk510Tela:Tk503ChkBox()}
	oTk510Tela:oGetDados:oBrowse:bChange := {|| Self:LoadProfile(), Self:LoadIncident() }
	
	oTk510Tela:oGetDados:Refresh()
	
	If nSecsRef > 0
		DEFINE TIMER Self:oTimer INTERVAL nSecsRef ACTION ( oTk510Tela:Refresh(),oTk510Tela:oGetDados:Refresh() ) OF Self:oDlg	
		Self:oTimer:Activate()
	EndIf
			
	ACTIVATE MSDIALOG Self:oDlg ON INIT (oTk510Tela:Tk510TaskBar(,,aIdxEval))
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAo encerrar a tela : Limpa as teclas de atalhoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู				
	Self:RestAtalho()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInforma ao gerenciador de m๚ltiplos grupos de atendimento ณ
	//ณque a rotina srevice desk nใo estแ mais em execu็ใo.      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	TK091End( SERVICEDESK )

Else
	Aviso(STR0025, STR0026, {"OK"})			// "Aviso" # "Usuแrio pertence a uma equipe nใo autorizada para utilizar a solu็ใo de Help Desk."
EndIf

TMKFree( Self:oObj:service )

Return( Nil )   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSetAtalho บAutor  ณVendas Clientes     บ Data ณ  21/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Define os botoes de atalho a serem utilizados pelo usuario บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method SetAtalho(aIdxEval) Class HelpDeskListDialog  
Local aTeclaPesq
Local lTk510Atalho := ExistBlock("TK510ATL")			// Ponto de Entrada para definir as teclas de atalho da tela.
	
	Self:aBkpSetkey := {}
	
	// CTRL + Seta Esquerda
	aAdd(Self:aBkpSetkey, {26, Setkey(26)})
	Setkey(26,	{||	Self:pgPrevious()}) 	
	// CTRL + Seta Direita
	aAdd(Self:aBkpSetkey, {2, Setkey(2)})
	Setkey(2,	{||	Self:pgNext()})  
	
	aTeclaPesq := Self:ShortCut(10) //tecla de pesquisa
	
	aAdd(Self:aBkpSetkey, {aTeclaPesq[1],{|| Self:Find() } } ) //Atribui 
	Setkey(aTeclaPesq[1],{|| Self:Find() } )  
	
	If lTk510Atalho
		ExecBlock("TK510ATL",.F.,.F.,{})
	EndIf
			
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRestAtalhoบAutor  ณVendas Clientes     บ Data ณ  21/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Restaura a funcao padrao dos botoes de atalho.             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method RestAtalho(aIdxEval) Class HelpDeskListDialog
Local nI := 0

DEFAULT aIdxEval 	:= {}

If Empty(aIdxEval) .Or. !IsInCallStack("Tk510Funcoes")
	For nI := 1 To Len(Self:aBkpSetkey)
   		Setkey(Self:aBkpSetkey[nI,1], Self:aBkpSetkey[nI,2])		
	Next nI
Else
	Setkey(Self:Shortcut(1)[1],{||Self:Tk510Funcoes( 3, aIdxEval )})	// Incluir
	Setkey(Self:Shortcut(2)[1],{||Self:Tk510Funcoes( 4, aIdxEval )}) 	// Alterar
	Setkey(Self:Shortcut(3)[1],{||Self:Tk510Funcoes( 2, aIdxEval )})	// Visualizar
	Setkey(Self:Shortcut(4)[1],{||Self:Tk510Funcoes( 9, aIdxEval )})	// "Informe os parametros para visualiza็ใo dos chamados" # "Parametros"
	Setkey(Self:Shortcut(5)[1],{||Self:Tk510Funcoes( 6, aIdxEval )})	// Chamados
	Setkey(Self:Shortcut(6)[1],{||Self:Tk510Funcoes( 5, aIdxEval )}) 	//"Distribuir"
	Setkey(Self:Shortcut(7)[1],{||Self:Tk510Funcoes( 13, aIdxEval )})	//"Associar"
	Setkey(Self:Shortcut(8)[1],{||Self:Tk510Funcoes( 14, aIdxEval )})	//"Transf.Grupo"
	Setkey(Self:Shortcut(15)[1],{||Self:Tk510Funcoes( 15, aIdxEval )})	//"Encerrar"
	Setkey(Self:Shortcut(16)[1],{||Self:Tk510Funcoes( 16, aIdxEval )})	//"Assumir"
	Setkey(Self:Shortcut(14)[1],{||Self:Tk510Funcoes( 7, aIdxEval )})	// Transferir
	Setkey(Self:Shortcut(9)[1],{||Self:DialogLabel()})// "Legendas"
	Setkey(Self:Shortcut(10)[1],{||Self:Find()})// "Pesquisa"
	Setkey(Self:Shortcut(11)[1],{||TMKA510HI()})// "Consulta o hist๓rico de chamados" #"Hist๓rico"
	Setkey(Self:Shortcut(12)[1],{||Self:Refresh()})// "Atualiza a lista de chamados" # "Atualiza"
	Setkey(Self:Shortcut(13)[1],{||Self:Tk510Funcoes( 10, aIdxEval )})// "Configura็๕es" # "Config"
	Setkey(Self:Shortcut(17)[1],{||Self:Tk510Funcoes( 17, aIdxEval )})//"Duplicar o chamado selecionado" #"Duplicar"
	Setkey(Self:Shortcut(18)[1],{||Self:Tk510Funcoes( 18, aIdxEval )})//"Exibe chamados recorrentes" # "Recorrencia"
EndIf

Return Nil
          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkOrder   บAutor  ณVendas Clientes     บ Data ณ  21/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Altera a ordem exibida.                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method TkOrder(nPos, aIdxEval, lUpdate) Class HelpDeskListDialog
Default lUpdate := .T.
	
//Desmarca e desbloqueia os chamados.
Self:SelectCall(.T.)

Self:nOrder := nPos	
If Self:oTimer <> Nil
	Self:oTimer:DeActivate()
EndIf
If lUpdate    
	Self:aColsADE 	:= {}	
	aCols	:= {}
	Self:Tk510ACols(.T.)
EndIf
Self:oGetDados:SetArray(Self:aColsADE, .F.) 
Self:oGetDados:ForceRefresh()
Self:LoadProfile()
Self:LoadIncident()         
If Self:oTimer <> Nil
	Self:oTimer:Activate()	
EndIf   

If Len(Self:aFollowUp) <= 0
	AAdd(Self:aFollowUp,{"",""})
Else
	ASort(Self:aFollowUp,,,{|x,y| x[2] < y[2] })
EndIf

If Self:oListFollow <> Nil
	Self:oListFollow:SetArray(Self:aFollowUp)
	Self:oListFollow:bLine := {||{	Self:aFollowUp[Self:oListFollow:nAt][1],;
									Self:aFollowUp[Self:oListFollow:nAt][2] }}
	Self:oListFollow:Refresh()
EndIf

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIniciaVar บAutor  ณVendas Clientes     บ Data ณ  21/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inicializa as variaveis de tela aCols e aHeader            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method IniciaVar() Class HelpDeskListDialog

	Local aArea			:= GetArea()
	Local bMontCols 	:= {|| Self:Tk510ACols() }				//Bloco de codigo para montagem do aCols
	Local nI			:= 0									// Utilzado em lacos em loop
	Local cMetMemberFn	:= "MethIsMemberOf"
	
	Default nOpc := 2
	
	Self:aSize    		:= MsAdvSize(.T.,.F.,400)
	aAdd( Self:aObjects, { 090, 075, .T., .T. } )
	aAdd( Self:aObjects, { 002, 003, .T., .T. } )
	aAdd( Self:aObjects, { 008, 017, .T., .T., .T. } )
	Self:aInfo 			:= { Self:aSize[1], Self:aSize[2], Self:aSize[3], Self:aSize[4], 3, 3 } 
	Self:aPosObj		:= MsObjSize( Self:aInfo, Self:aObjects, .T. )
	
	Self:aYesFields := {} 
	Self:aIniBrwFields := {}     

	AADD(Self:aHeaderADE,{"","CHECKBOX","@BMP",20,00,,,"C",,"V","",,".T."} )
	AADD(Self:aHeaderADE,{STR0176,"SEMAFORO","@BMP",1,00,,,"C",,"V","",,".T."} )    // "Chamado"
	AADD(Self:aHeaderADE,{STR0104,"SLA","@BMP",1,0,,,"C",,"V","",,".T."} )			//"SLA"
	AADD(Self:aHeaderADE,{STR0105,"PSLA","@E 99999.99",8,2,,,"C",,"V","",,".T."} )	//% SLA
	AADD(Self:aHeaderADE,{STR0106,"HSLA","@!",10,2,,,"C",,"V","",,".T."} )			//Hr.SLA
	If &cMetMemberFn.( WFTemplate():New(), "GETHEADWF" )
		AADD(Self:aHeaderADE,{STR0177,"WF","@BMP",1,0,,,"C",,"V","",,".T."} )		// "Workflow"
	EndIf
	
	DbSelectArea("SX3")
	DbSetOrder( 1 )
	DbSeek( Self:cAliasUser )
	While !Eof() .And. Upper( SX3->X3_ARQUIVO ) == Upper( Self:cAliasUser )
		If cNivel >= SX3->X3_Nivel .And. Upper( SX3->X3_BROWSE ) == "S"
			AADD( Self:aYesFields, SX3->X3_CAMPO )
			AADD( Self:aIniBrwFields, {SX3->X3_CAMPO,	SX3->X3_INIBRW})

			Aadd(Self:aHeaderADE,{ 	AllTrim(X3Titulo())	,;	//1
							SX3->X3_CAMPO		,;	//2
							SX3->X3_PICTURE		,;	//3
							SX3->X3_TAMANHO		,;	//4
							SX3->X3_DECIMAL		,;	//5
							SX3->X3_VALID		,;	//6	
							SX3->X3_USADO		,;	//7
							SX3->X3_TIPO		,;	//8
							SX3->X3_ARQUIVO		,;	//9
							SX3->X3_CONTEXT		,;	//10
							X3CBox()			,;	//11		
							SX3->X3_RELACAO		,;	//12
							".T." } )				//13
		
		EndIf

		If	AllTrim(Upper(SX3->X3_TIPO)) $ "D|L"
			aAdd(Self:aSetField, {SX3->X3_CAMPO, SX3->X3_TIPO})
		ElseIf AllTrim(Upper(SX3->X3_TIPO)) == "N"
		  	aAdd(Self:aSetField, {SX3->X3_CAMPO, SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})	     
		EndIf

		If SX3->X3_CONTEXT == "R" .OR. AllTrim(SX3->X3_CONTEXT)==""
			aAdd(Self:aSQLFields, SX3->X3_CAMPO)
		EndIf
		Dbskip()
	End
		
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCarrega as configura็๕es de exibi็ใo do service desk.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Self:LoadConfig()						
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAltera a ordem e exibi็ใo dos campos de acordo com o ณ
	//ณdefinido pelo usuแrio.                               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Self:ChangeColsOrder()
							
	If Len(Self:aSQLFields)>0
		Self:cSQLFields := Self:aSQLFields[1] 
		For nI := 2 To Len(Self:aSQLFields)
			Self:cSQLFields += ", " + Self:aSQLFields[nI]
		Next nI
	EndIf
	
	aHeader := {}
	aHeader := aClone(Self:aHeaderADE)
	Self:Tk510ACols() 	
    
Return( Nil )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMKA510   บAutor  ณMicrosiga           บ Data ณ  01/23/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz o tratamento para mostrar o checkbox                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Tk503ChkBox() Class HelpDeskListDialog

Local nPosCod := 0
Local cCodigo := ""

Self:GetFieldPos("ADE_CODIGO", @nPosCod, Self:aHeaderADE)

// Protecao para quando nao houver chamados deixando o aCols como NIL
cCodigo := oTk510Tela:oGetDados:aCols[oTk510Tela:oGetDados:nAt, nPosCod]
If ValType( cCodigo ) <> "C"
	Return
EndIf

ADE->(dbSetOrder(1))
ADE->(dbSeek(xFilial("ADE") + cCodigo ) )

If oTk510Tela:oGetDados:aCols[oTk510Tela:oGetDados:nAt, 1] == "LBOK"
	TK510UsrLock("U", ADE->ADE_CODIGO, TkOperador(), .F.)
	oTk510Tela:oGetDados:aCols[oTk510Tela:oGetDados:nAt, 1] := "LBNO"
Else
	//Verifica se o chamado estแ bloqueado, caso contrแrio faz o bloqueio.
	If TK510UsrLock("L", ADE->ADE_CODIGO, TkOperador(), .F.)
		oTk510Tela:oGetDados:aCols[oTk510Tela:oGetDados:nAt, 1] := "LBOK"
	Else
		Aviso(STR0179,; 				//"Help Desk"
		STR0180 + ADE->ADE_OPEUSO +;	//"Este chamado encontra-se em atendimento pelo Analista - "
		" - " + FATPDObfuscate( AllTrim(Posicione("SU7", 1, xFilial("SU7")+ADE->ADE_OPEUSO, "U7_NOME")),"U7_NOME",,.T.) +;
		STR0181,{"OK"})					//", e nใo poderแ ser selecionado at้ que o analista libere o chamado."	
	EndIf
EndIf

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMKA510   บAutor  ณMicrosiga           บ Data ณ  01/22/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta a barra de ferramentas superior.                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Tk510TaskBar( bOk, bCancel, aIdxEval ) Class HelpDeskListDialog

Local lTK510ABTN 	:= ExistBlock("TK510ABTN")	//Ponto de Entrada para alterar o array de botoes
Local aBtnAux		:= {}
Local aBotoes		:= {}   
Local aAtalho		:= {Nil,""}

	//Criacao dos botoes e atalhos
	aAtalho := Self:Shortcut(1)
	AAdd(Self:aShortcutMap,{STR0009,aAtalho[2],aAtalho[1],"1"})
	AADD( aBotoes, { "BPMSDOCI"		, {||Self:Tk510Funcoes( 3, aIdxEval )	}	, STR0009,	STR0009, aAtalho[1], aAtalho[2]	} )	// Incluir

	aAtalho := Self:Shortcut(2)
	AAdd(Self:aShortcutMap,{STR0003,aAtalho[2],aAtalho[1],"2"})
	AADD( aBotoes, { "BPMSDOCA"		, {||Self:Tk510Funcoes( 4, aIdxEval )	}	, STR0003,	STR0003, aAtalho[1], aAtalho[2]	} )	// Alterar

	aAtalho := Self:Shortcut(3)
	AAdd(Self:aShortcutMap,{STR0011,aAtalho[2],aAtalho[1],"3"})
	AADD( aBotoes, { "BMPVISUAL"	, {||Self:Tk510Funcoes( 2, aIdxEval )	}	, STR0011,	STR0011, aAtalho[1], aAtalho[2]	} )	// Visualizar

	aAtalho := Self:Shortcut(4)
	AAdd(Self:aShortcutMap,{STR0030,aAtalho[2],aAtalho[1],"4"})
	AADD( aBotoes, { "PARAMETROS"	, {||Self:Tk510Funcoes( 9, aIdxEval )	}	, STR0029,	STR0030, aAtalho[1], aAtalho[2]	} )	// "Informe os parametros para visualiza็ใo dos chamados" # "Parametros"

	aAtalho := Self:Shortcut(5)
	AAdd(Self:aShortcutMap,{STR0031,aAtalho[2],aAtalho[1],"5"})
	AADD( aBotoes, { "ATALHO"		, {||Self:Tk510Funcoes( 6, aIdxEval )	}	, STR0031,	STR0031, aAtalho[1], aAtalho[2]	} )	// Chamados

	If Self:lSupervisor
		aAtalho := Self:Shortcut(6)
		AAdd(Self:aShortcutMap,{STR0012,aAtalho[2],aAtalho[1],"6"})
		AADD( aBotoes, { "ATALHO"	, {||Self:Tk510Funcoes( 5, aIdxEval )}	, STR0012,STR0012, aAtalho[1], aAtalho[2]	} ) //"Distribuir"
	EndIF

	If Tk510VerButton("Associar",Self:oObj:Service:id)
		aAtalho := Self:Shortcut(7)
		AAdd(Self:aShortcutMap,{STR0081,aAtalho[2],aAtalho[1],"7"})
		AADD( aBotoes, { "ATALHO"	, {||Self:Tk510Funcoes( 13, aIdxEval )}	, STR0081,STR0081, aAtalho[1], aAtalho[2]	} )	//"Associar"
	EndIf
	
	If Tk510VerButton("Transf.Grupo",Self:oObj:Service:id)
		aAtalho := Self:Shortcut(14)
		AAdd(Self:aShortcutMap,{STR0081,aAtalho[2],aAtalho[1],"7"})
		AADD( aBotoes, { "ATALHO"	, {||Self:Tk510Funcoes( 14, aIdxEval )}	, STR0175,STR0175, aAtalho[1], aAtalho[2] } ) //"Transf.Grupo"
	EndIf
	
	aAtalho := Self:Shortcut(15)
	AAdd(Self:aShortcutMap,{STR0081,aAtalho[2],aAtalho[1],"7"})
	AADD( aBotoes, { "ATALHO"	, {||Self:Tk510Funcoes( 15, aIdxEval )}	, STR0119,STR0119, aAtalho[1], aAtalho[2]	} )	//"Encerrar"

	aAtalho := Self:Shortcut(16)
	AAdd(Self:aShortcutMap,{STR0081,aAtalho[2],aAtalho[1],"7"})
	AADD( aBotoes, { "ATALHO"	, {||Self:Tk510Funcoes( 16, aIdxEval )}	, STR0120,STR0120, aAtalho[1], aAtalho[2]	} )	//"Assumir"

	AADD( aBotoes, { "MSGFORWD"	, {||Self:Tk510Funcoes( 19, aIdxEval )}, STR0199,STR0199, , 	} ) //"Gerar Planilha Excel"
	
	aAtalho := Self:Shortcut(8)
	AAdd(Self:aShortcutMap,{STR0032,aAtalho[2],aAtalho[1],"8"})
	AADD( aBotoes, { "BMPGROUP"	, {||Self:Tk510Funcoes( 7, aIdxEval )}	, STR0032,STR0032, aAtalho[1], aAtalho[2]		} )	// Transferir

	aAtalho := Self:Shortcut(9)
	AAdd(Self:aShortcutMap,{STR0033,aAtalho[2],aAtalho[1],"9"})
	AADD( aBotoes, { "PCOIMG32"		, {||Self:DialogLabel()}					, STR0033,STR0033, aAtalho[1], aAtalho[2]	} )	// "Legendas"

	aAtalho := Self:Shortcut(10)
	AAdd(Self:aShortcutMap,{STR0034,aAtalho[2],aAtalho[1],"10"})
	AADD( aBotoes, { "PESQUISA"		, {||Self:Find()}							, STR0034,STR0034, aAtalho[1], aAtalho[2]	} )	// "Pesquisa"

	aAtalho := Self:Shortcut(11)
	AAdd(Self:aShortcutMap,{STR0036,aAtalho[2],aAtalho[1],"11"})
	AADD( aBotoes, { "SDUIMPORT"	, {||TMKA510HI()}							, STR0035,STR0036, aAtalho[1], aAtalho[2]	} )	// "Consulta o hist๓rico de chamados" #"Hist๓rico"

	aAtalho := Self:Shortcut(12)
	AAdd(Self:aShortcutMap,{STR0067,aAtalho[2],aAtalho[1],"12"})
	AADD( aBotoes, { "RELOAD"		, {||Self:Refresh()}						, STR0066,STR0067, aAtalho[1], aAtalho[2]	} )	// "Atualiza a lista de chamados" # "Atualiza" 

	aAtalho := Self:Shortcut(13)
	AAdd(Self:aShortcutMap,{STR0069,aAtalho[2],aAtalho[1],"13"})
	AADD( aBotoes, { "INSTRUME"		, {||Self:Tk510Funcoes( 10, aIdxEval )}		, STR0069,STR0068, aAtalho[1], aAtalho[2]	} )	// "Configura็๕es" # "Config" 	

	aAtalho := Self:Shortcut(17)
	AAdd(Self:aShortcutMap,{STR0168,aAtalho[2],aAtalho[1],"17"})
	AADD( aBotoes, { "S4WB005N"		, {||Self:Tk510Funcoes( 17, aIdxEval )}		, STR0167,STR0168, aAtalho[1], aAtalho[2] 	} )	//"Duplicar o chamado selecionado" #"Duplicar"

	aAtalho := Self:Shortcut(18)
	AAdd(Self:aShortcutMap,{STR0170,aAtalho[2],aAtalho[1],"18"})
	AADD( aBotoes, { "DEVOLNF"		, {||Self:Tk510Funcoes( 18, aIdxEval )}		, STR0169,STR0170, aAtalho[1], aAtalho[2] 	} )	// "Exibe chamados recorrentes" # "Recorrencia"

	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณConfiguracao de teclas de atalho (apenas versao 11 e acima)ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	AAdd(aBotoes,{"ATALHO",{||TkCfgAtalho(Self:aShortcutMap,"TMKA510A")}	, STR0117,STR0117,,}) //"Configurar atalhos"

	//Botoes do usuario	
	If lTK510ABTN               
		aBtnAux := ExecBlock("TK510ABTN", .F., .F., {aBotoes, aIdxEval})			
		If ValType(aBtnAux) == "A"
			aBotoes := aClone(aBtnAux)	
		EndIf
	EndIf

	//Define os botoes de atalho da tela de pendencia	
	Self:SetAtalho(aIdxEval)	

Return( EnchoiceBar(Self:oDlg, {|| Self:SelectCall(.T.), Self:oDlg:End()}, {|| Self:SelectCall(.T.), Self:oDlg:End()}, .F., aBotoes ) )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk510Filt บAutor  ณVendas Clientes     บ Data ณ  24/05/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Seleciona o filtro para exibicao dos dados na tela de pend.บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Tk510Filt() Class HelpDeskListDialog
Local oWnd		 := GetWndDefault()
Local cDesc 	 := "" 					// Descricao do SX5
Local lRet 		 := .F.					// Retorno da funcao
Local cDescFiltro:= ""					// Conteudo do filtro
Local oDlgFiltro						// Dialog para apresentacao do filtro
Local oDescFiltro						// Objeto com a selecao do filtro
Local cFiltro	:= ""					//Armazena temporariamente o filtro da tela

DbSelectArea("ADE")

If !Empty(Self:cFilter)
	cDescFiltro := MontDescr("ADE",Self:cFilter)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualiza a descricao da selecao.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG oDlgFiltro FROM  00,00 TO 200,310 TITLE STR0028 PIXEL  // //"Filtro"

	@02,02 TO 75,153 LABEL STR0037 OF oDlgFiltro PIXEL     //"Descri็ใo do Filtro"
	@10,05 MSGET oDescFiltro VAR cDescFiltro PICTURE "@!" SIZE 145,60 OF oDlgFiltro PIXEL COLOR CLR_RED WHEN .F.
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFiltro para a selecao dos registros da entidadeณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DEFINE SBUTTON FROM 80,20  TYPE 17 ENABLE OF oDlgFiltro ACTION (lRet:=.T.,;
																	cFiltro  := BuildExpr("ADE",oWnd),;
																	cDescFiltro := MontDescr("ADE",cFiltro),;
																	oDescFiltro:Refresh()) //Monta o filtro

	DEFINE SBUTTON FROM 80,55  TYPE 3 ENABLE OF oDlgFiltro ACTION (	lRet:=.T.,;
																	cFiltro:= "",;
																	cDescFiltro := MontDescr("ADE",cFiltro),;
																	oDescFiltro:Refresh()) //Exclui o filtro
																	
	DEFINE SBUTTON FROM 80,90  TYPE 1 ENABLE OF oDlgFiltro ACTION oDlgFiltro:End() //Fecha a tela e mantem o filtro
	
	DEFINE SBUTTON FROM 80,125 TYPE 2 ENABLE OF oDlgFiltro ACTION (	lRet:=.F.,;
																	cDescFiltro:="",;
																	oDescFiltro:Refresh(),;																	
																	oDlgFiltro:End())// Cancela o filtro
																
ACTIVATE MSDIALOG oDlgFiltro CENTERED

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualiza o filtro da tela.      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet
	Self:cFilter := cFiltro
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSetFilter บAutor  ณVendas Clientes     บ Data ณ  24/05/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Define a expressao de filtro na tabela de atendimentos.    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method SetFilter() Class HelpDeskListDialog
Local aArea := GetArea()
Local cEntidade := "ADE"

DbSelectArea(cEntidade)
DbCloseArea()
ChkFile(cEntidade)

Set Filter To &(Self:cFilter)

RestArea(aArea)
Return Nil 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMKA510   บAutor  ณMicrosiga           บ Data ณ  01/21/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Tk510ACols(lUpdate)  Class HelpDeskListDialog
	Processa( {|| Self:Tk510ProACols(lUpdate)}, "Service Desk", STR0038, .T.)  // "Selecionando chamados..."
Return( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMKA510   บAutor  ณMicrosiga           บ Data ณ  01/21/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Tk510ProACols(lUpdate)  Class HelpDeskListDialog

Local nI 			:= 0		// Variavel do FOR
Local lFiltra		:= !Empty(self:cFilter)  
Local cFilADE		:= xFilial("ADE")

Local aArea			:= ADE->(GetArea())

Default lUpdate := .T.

Private INCLUI := .F.
Private ALTERA := .T.  
                 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLimpa as informa็๕es de perfilณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Self:setProfile("")
Self:SetIncident("")
Self:aFollowUp := {}

ProcRegua(3)

If lUpdate 
	IncProc(STR0039)	 // "Selecionando registros..."
	Self:Tk510Filtra()
	Self:aRecnoAnt := {}
	Self:nRecnoPos := 0 
	Self:cPagePos := "1     "
EndIf
DbSelectArea( Self:cTabelaAux )

If (Self:cTabelaAux)->(!EOF())
	If lUpdate
		aAdd(Self:aRecnoAnt,(Self:cTabelaAux)->(RecNo()))
	EndIf
EndIf
Self:nRecnoPos := 0   

IncProc(STR0040) // "Criando lista de chamados..."
While (Self:cTabelaAux)->(!EOF())//!Eof()
	#IFNDEF TOP
		If (Self:cTabelaAux)->ADE_STATUS <> "3"
	#ENDIF	
			If (Empty(Self:cFilter) .OR. &(Self:cFilter)) .AND. (Empty(Self:cBrwFilter) .OR. &(Self:cBrwFilter))	
				//RegToMemory("ADE",.F.,,.F.)
				Self:BuildAcols( Self:cTabelaAux )
				nI++
				If Self:nMaxRowsPerPage <= nI					   
					DbSelectArea( Self:cTabelaAux )
					DbSkip()		
					If (Self:cTabelaAux)->(!EOF())
						Self:nRecnoPos := (Self:cTabelaAux)->(RecNo())
					EndIf 
					Exit	
				EndIf   								
			EndIf                                      
	#IFNDEF TOP		
		EndIf	
	#ENDIF	
	DbSelectArea( Self:cTabelaAux )
	DbSkip()	
End 

If Len(Self:aColsADE) <= 0 
	Self:BuildAcols( Self:cTabelaAux )	
Else
	Self:cPagePos := AllTrim(Str(Len(Self:aRecnoAnt)))	+ "  "
EndIf      
         
IncProc(STR0041) // "Criando pแginas..."
DbSelectArea(Self:cTabelaAux)
DbCloseArea()

//Avalia chamados com FollowUp 
#IFDEF TOP  
	If MV_PAR15 == 1
		If lFiltra
			ADE->(DbSetOrder(1))
		EndIf
		While (Self:cTabelaFlw)->(!EOF())
			If lFiltra 
				If ADE->(DbSeek(cFilADE+(Self:cTabelaFlw)->ADE_CODIGO)) .AND. ADE->&(self:cFilter)
					AAdd(Self:aFollowUp,{(Self:cTabelaFlw)->ADE_CODIGO,(Self:cTabelaFlw)->ADE_FOLLOW } )
				EndIf
			Else
				AAdd(Self:aFollowUp,{(Self:cTabelaFlw)->ADE_CODIGO,(Self:cTabelaFlw)->ADE_FOLLOW } )
			EndIf
			(Self:cTabelaFlw)->(DbSkip())
		End
	EndIf

	If Select(Self:cTabelaFlw) > 0
		(Self:cTabelaFlw)->(DbCloseArea())
	EndIf
#ENDIF

RestArea(aArea)	

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk510Filtra บAutor  ณMicrosiga           บ Data ณ  21/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Tk510Filtra() Class HelpDeskListDialog

Local cAlias	:= ""  
Local cQuery	:= ""
Local cQryFollow:= ""
Local lTK510AQRY	:= FindFunction("P_TK510AQRY")
Local cQryAux	:= ""
Local cQryTot	:= "" 
Local nI 		:= 0
Local aGrupos	:= {}
Local cGrupos	:= ""
Local cSep		:= ""
Local lFollowUp	:= MV_PAR15 == 1

Self:cTabelaAux := "ADE"
Self:cTabelaFlw := GetNextAlias()

DbSelectArea("ADE") 	
DbCloseArea()

cAlias := Self:cTabelaAux 

DbSelectArea("ADE")	
DbSetOrder(Val(aIdxChave[Self:nOrder]))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPergunte - TMK510A                                                            ณ
//ณMV_PAR01 - Do Chamado                                                         ณ
//ณMV_PAR02 - Ate o chamado                                                      ณ
//ณMV_PAR03 - Do Cliente                                                         ณ
//ณMV_PAR04 - Da Loja                                                            ณ	
//ณMV_PAR05 - Ate o Cliente                                                      ณ
//ณMV_PAR06 - Ate a Loja                                                         ณ	
//ณMV_PAR07 - De                                                        		 ณ
//ณMV_PAR08 - Ate                                                                ณ
//ณMV_PAR09 - Do Analista                                               		 ณ
//ณMV_PAR10 - Ate o Analista                                                     ณ	
//ณMV_PAR11 - Qtd chamados p/ pagina ?                                           ณ		
//ณMV_PAR12 - Status de chamados a serem exibidos                                ณ		
//ณMV_PAR13 - Exibe a tela de parametros ao acessar o Service Desk ?             ณ		
//ณMV_PAR14 - Exibir todos os meus grupos?                                       ณ		
//ณMV_PAR15 - Utiliza Follow Up ?                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	

#IFDEF TOP		
	
	cQuery := " WHERE ADE.ADE_FILIAL = '" + xFilial("ADE") + "' AND"
	If !Self:lViewAll
		
		aGrupos := Tk510GetGroups(Self:cOperador)
		
		If MV_PAR14 == 1 .AND. Len(aGrupos) > 0			
			For nI := 1 to Len(aGrupos) 
				cGrupos += cSep + aGrupos[nI]
				cSep	:= ","
			Next nI
			cQuery += " ADE.ADE_GRUPO IN " + FormatIn(cGrupos,",") + " AND"
		Else
			cQuery += " ADE.ADE_GRUPO = '" + Self:cPosto + "' AND"
		EndIf
	EndIf
	cQuery += " ADE.ADE_CODIGO BETWEEN '" + Self:MV_PAR01 + "' AND '" + Self:MV_PAR02 + "' AND"                     
	If !Empty(Self:MV_PAR03) .OR. (!Empty(Self:MV_PAR04) .AND. Self:MV_PAR04 <> "ZZZZZZ")
		cQuery += " ADE.ADE_CHAVE BETWEEN '" + Self:MV_PAR03 + Self:MV_PAR04 + "' AND '" + Self:MV_PAR05 + Self:MV_PAR06 + "' AND"                
		cQuery += " ADE.ADE_ENTIDA 	= 'SA1' AND"                     	     
	EndIf		
	cQuery += " ADE.ADE_DATA BETWEEN '" + DToS(Self:MV_PAR07) + "' AND '" + DToS(Self:MV_PAR08) + "' AND"                     
	If !Self:lViewTeamTask .AND. !Self:lViewAll			
		cQuery += " ADE.ADE_OPERAD 	= '" + Self:cOperador + "' AND "		
	EndIf
	If (!Empty(Self:MV_PAR09) .OR. (!Empty(Self:MV_PAR10) .AND. Self:MV_PAR10 <> "ZZZZZZ")) .AND. Self:lSupervisor 		
		cQuery += " ADE.ADE_OPERAD BETWEEN '" + Self:MV_PAR09 + "' AND '" + Self:MV_PAR10 + "' AND "                     		    		
	EndIf       
	If MV_PAR12 == 1
		cQuery += " ADE.ADE_STATUS IN('1','2') AND"                     	     
	ElseIf MV_PAR12 == 2
		cQuery += " ADE.ADE_STATUS = '1' AND"                     	     
	ElseIf MV_PAR12 == 3
		cQuery += " ADE.ADE_STATUS = '2' AND"                     	     			
	Else
		cQuery += " ADE.ADE_STATUS <> '3' AND"                     	     
	EndIf		                                                             
	
	cQuery += " ADE.D_E_L_E_T_=' '"

	//Chamados com Follow Up
	If lFollowUp

		cQryFollow	:= "SELECT ADE_CODIGO, ADE_FOLLOW FROM " + RetSQLName("ADE") + " ADE WHERE "   
		cQryFollow	+= "ADE.ADE_FILIAL = '" + xFilial("ADE") + " ' AND "   
		If !Self:lViewAll
			If MV_PAR14 == 1 .AND. Len(aGrupos) > 0			
				cQryFollow += "ADE.ADE_GRUPO IN " + FormatIn(cGrupos,",") + " AND "
			Else
				cQryFollow += "ADE.ADE_GRUPO 	= '" + Self:cPosto + "' AND "
			EndIf
		EndIf 

		cQryFollow += "ADE.ADE_OPERAD = '" + Self:cOperador + "' AND "		

		cQryFollow	+= "ADE.ADE_STATUS <> '3' AND ADE.ADE_FOLLOW <= '" + DToS(dDataBase) + "' AND ADE.ADE_FOLLOW <> '' "
		cQryFollow	+= "ORDER BY ADE_FOLLOW,ADE_CODIGO"

		If Select(Self:cTabelaFlw) > 0
			(Self:cTabelaFlw)->(DbCloseArea())
		EndIf

		cQryFollow := ChangeQuery(cQryFollow)
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQryFollow), Self:cTabelaFlw, .F., .T.)		
		TCSetField(Self:cTabelaFlw, "ADE_FOLLOW", "D")

	EndIf
	
	cQryTot := " SELECT Count(*) COUNT FROM " + RetSQLName("ADE") + " ADE" + cQuery

	cQuery += " ORDER BY " + SqlOrder(ADE->(IndexKey()))	         
	cQuery := " SELECT " + Self:cSQLFields + " FROM " + RetSQLName("ADE") + " ADE" + cQuery
	
	If lTK510AQRY                                                       
		cQryAux := P_TK510AQRY(cQuery)//ExecBlock("TK510AQRY",.F.,.F., {cQuery})
		cQuery := cQryAux					
	EndIf
	
	cQuery := ChangeQuery(cQuery)
	DbSelectArea("ADE")
	DbCloseArea()		
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), Self:cTabelaAux, .F., .T.)		
	  
	For nI := 1 To Len(Self:aSetField)
	
	  	If AllTrim(Self:aSetField[nI, 2]) $ "D|L"
	   		TCSetField("ADE", Self:aSetField[nI, 1], Self:aSetField[nI, 2])
		ElseIf AllTrim(Self:aSetField[nI, 2]) == "N" .AND. Len(Self:aSetField[nI])>3
			TCSetField("ADE", Self:aSetField[nI, 1], Self:aSetField[nI, 2],Self:aSetField[nI, 3],Self:aSetField[nI, 4])
		EndIf
	
	Next nI		

#ELSE       
	DbSelectArea("ADE")
	DbSetOrder(3) //ADE_FILIAL+ ADE_GRUPO				
	MsSeek(xFilial("ADE")+Self:cPosto)		
#ENDIF                             

self:RefreshTotPage()
	
Return( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBuildAcolsบAutor  ณMicrosiga           บ Data ณ  01/22/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Adiciona informacoes na aCols                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method BuildAcols() Class HelpDeskListDialog

	Local nI 			:= 0									// Variavel do FOR
	Local cCampo		:= ""									// Campo que devera alimentar o aCols
	Local nLin			:= 0									// Posicao da array
	Local lEof			:= (Self:cTabelaAux)->( Eof() )		// Retorna se e fim de arquivo
	Local nCor			:= 0
	Local aTmpFields	:= {}                     
	Local nPosCpo		:= 0 
	Local nLenAHeader 	:= 0   
	Local cMacro 		:= ""
	Local aCombo		:= {}   
	Local nInitCBox		:= 0
	Local nPosProfile	:= 0
	Local nStatus		:= 0
	Local lOkSLA		:= .F.
	Local nHrUtilSLA	:= 0
	Local lFlChan		:= .F.									//Informa a existencia do campo ADE_FLCHAN

	lFlChan := .T.
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPonto de Entrada: TK510CHCOL                     ณ
	//ณPermite alterar as colunas que serใo exibidas na ณ
	//ณtela de Pend๊ncias Help-Desk.                    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ExistBlock("TK510CHCOL")
		aTmpFields := ExecBlock("TK510CHCOL",.F.,.F., { Self:aHeaderADE } )
		If ValType(aTmpFields) == "A" .and. Len(aTmpFields) >= 1
			Self:aHeaderADE := aClone(aTmpFields)
		EndIf
	EndIf
	
	AADD( Self:aColsADE, Array( Len( Self:aHeaderADE ) + 1 ) )
	
	nLin := Len( Self:aColsADE )
	
	//CheckBox
	Self:aColsADE[nLin][1] := "LBNO"
	
	//Legenda do chamado
	If !lEof      
		nCor := 0
		nCor := aScan(Self:aCores, {|x|Eval(&("{||" + x[1] + "}"))})		
		If nCor > 0                                   
			Self:aColsADE[nLin][2] := Self:aCores[nCor][2]	
		Else		
			Self:aColsADE[nLin][2] := Self:cRed
		EndIf
	Else
		Self:aColsADE[nLin][2] := Self:cWhite
	EndIf
	     
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณLegenda do SLA                 ณ
	//ณCaso o chamado estaja associadoณ
	//ณConsiderar SLA do chamado Pai  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   	If Empty((Self:cTabelaAux)->ADE_CHANEX)	     
		lOkSLA := RetSlaStatus((Self:cTabelaAux)->ADE_REGSLA,@nHrUtilSLA,@nStatus)
	Else
       
        If lFlChan
        	aRegSLA := REGSLAPAI((Self:cTabelaAux)->ADE_CODIGO,(Self:cTabelaAux)->ADE_CHANEX,(Self:cTabelaAux)->ADE_FLCHAN)
        Else
        	aRegSLA := REGSLAPAI((Self:cTabelaAux)->ADE_CODIGO,(Self:cTabelaAux)->ADE_CHANEX)
 		EndIf
 		
 		lOkSLA := RetSlaStatus(aRegSLA[2],@nHrUtilSLA,@nStatus,aRegSLA[1])	
        
	EndIf
	
	If !lOkSLA
		Self:aColsADE[nLin][3] := Self:cWhite
		Self:aColsADE[nLin][4] := Transform(0,"@E 99999.99")
		Self:aColsADE[nLin][5] := "0000000:00"
	Else

		nCor := aScan(Self:aPercSLA,{|x| x >= nStatus})

		//Se o valor for maior que o limite superior, assume o ultimo status
		If nCor == 0 .AND. nStatus > aTail(Self:aPercSLA)
			nCor := Len(Self:aPercSLA)
		EndIf
		
		If nCor <> 0
			Self:aColsADE[nLin][3] := Self:aStatusSLA[nCor]
		Else
			Self:aColsADE[nLin][3] := Self:cWhite
		EndIf
		
		Self:aColsADE[nLin][4] := Transform(nStatus,"@E 99999.99")
		Self:aColsADE[nLin][5] := IntToHoraTmk(nHrUtilSLA,7)
		
	EndIf
	
	nI := 5
	
	IF Empty((Self:cTabelaAux)->ADE_WFASTA)
		Self:aColsADE[nLin][6] := Self:cWhite
	ElseIf (Self:cTabelaAux)->ADE_WFASTA == "1"
		Self:aColsADE[nLin][6] := Self:cWhite
	ElseIf (Self:cTabelaAux)->ADE_WFASTA == "2"
		Self:aColsADE[nLin][6] := Self:cYellow	
	ElseIf (Self:cTabelaAux)->ADE_WFASTA == "3"
		Self:aColsADE[nLin][6] := Self:cGreen
	ElseIf (Self:cTabelaAux)->ADE_WFASTA == "4"
		Self:aColsADE[nLin][6] := Self:cRed
	ElseIf (Self:cTabelaAux)->ADE_WFASTA == "5"
		Self:aColsADE[nLin][6] := Self:cBlue		
	EndIf
	nI++
	
	nLenAHeader := Len( Self:aHeaderADE )     		

	For nI := nI To nLenAHeader
		cCampo := Self:aHeaderADE[nI, 2]
		If IsHeadRec(cCampo)	//Recno
  			Self:aColsADE[nLin][nI] := (Self:cTabelaAux)->( Recno() )
	 	ElseIf IsHeadAlias(cCampo)	//Alias
			Self:aColsADE[nLin][nI] := Self:cTabelaAux
		ElseIf Self:aHeaderADE[nI,10] <> "V" .AND. !lEof
			cMacro := Self:cTabelaAux + "->" + cCampo //(Self:cTabelaAux)->(cCampo) 
			Self:aColsADE[nLin][nI] := &cMacro//FieldGet( FieldPos( cCampo ) ) 
		ElseIf cCampo <> "SEMAFORO" .AND. cCampo <> "CHECKBOX"
			nPosCpo := aScan(Self:aIniBrwFields, {|x|x[1]==cCampo})			
			If nPosCpo > 0                                          
				cMacro := Self:aIniBrwFields[nPosCpo, 2]
				Self:aColsADE[nLin][nI] := &cMacro //Eval(&("{||" + Self:aIniBrwFields[nPosCpo, 2] + "}"))//CriaVar( cCampo, !lEof )
			EndIf
		EndIf                                               
		If !Empty(Self:aHeaderADE[nI, 11]) .AND. Self:aHeaderADE[nI, 8] == "C"
			aCombo:=RetSx3Box(Self:aHeaderADE[nI, 11],@nInitCBox,,Self:aHeaderADE[nI, 4])
			nInitCBox := Ascan( aCombo, { |e| e[2] = Self:aColsADE[nLin][nI] } )
			If nInitCBox > 0
				Self:aColsADE[nLin][nI]  := AllTrim( aCombo[nInitCBox][3] )	// Descricao da situacao.
			Endif				
		EndIf		
	Next nI
	Self:aColsADE[nLin][nI] := .F.   
	
	Self:GetFieldPos("ADE_TIPPRF", @nPosProfile, Self:aHeaderADE)
	If nPosProfile > 0 .AND. !Empty(Self:aColsADE[nLin][nPosProfile])
		Self:aColsADE[nLin][nI] := .T.   
	EndIf
	
	If lEof     
		Self:aColsADE[nLin][nI] := .T.             
		Aviso(	"Help Desk",;
				STR0042 + CRLF + STR0043,; // "Nใo hแ chamados para serem visualizados." # "Verifique os parโmetros informados."
				{"OK"})				
	EndIF

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDistribute  บAutor  ณMicrosiga           บ Data ณ  01/28/08   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a disribuicao de atividades para os analistas.       บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Distribute() Class HelpDeskListDialog 

Local aArea		:= GetArea()
Local aAreaADE	:= ADE->(GetArea())    
Local oDlg
Local oCombo       
Local cAgent 	:= ""
Local aItems 	:= {} 
Local lSelItem 	:= .F.
Local iCols 	:= 0
Local lRet 		:= .T.
Local lOpenMsg	:= .F.
Local nCodPos 	:= 0
Local nCount 	:= 0
Local nPos		:= 0
Local nPosCh	:= 0
Local cMsg 		:= ""
Local cChNaoGrav:= ""
Local lMultGroup:= .F.
Local aAcaoOcorrencia := {}
Local aAssuntCh	:= {} 
Local cAssErro	:= ""
Local oPesq     := Nil         //Objeto utilizado na pesquisa
Local cPesq     := Space(50)   //Variavel que recebe a string de pesquisa

Self:GetFieldPos("ADE_CODIGO", @nCodPos, Self:aHeaderADE)

ADE->(DbSetOrder(1))

For iCols := 1 To Len(Self:OGETDADOS:ACOLS)
	If Self:OGETDADOS:ACOLS[iCols][1] == "LBOK"
		
		//Monta lista de assuntos a serem transferidos
		ADE->(MsSeek(xFilial("ADE")+Self:OGETDADOS:ACOLS[iCols][nCodPos]))
		If aScan(aAssuntCh,ADE->ADE_ASSUNT) == 0
			AAdd(aAssuntCh,ADE->ADE_ASSUNT)
		EndIf  
				
		lSelItem := .T. 
		nCount++  
		
	EndIf
Next iCols

//Verifica se a funcionalidade de m๚ltiplos grupos de atendimento estแ ativa


lMultGroup := .T.

             
If lSelItem
	If !lMultGroup
		#IFDEF TOP		
			cQuery := "SELECT U7_COD, U7_POSTO, U7_NOME, U7_FILIAL  FROM " + RetSQLName("SU7") + " SU7"
			cQuery += 		" WHERE SU7.U7_FILIAL = '" + xFilial("SU7") + "' AND"
			cQuery += 				" SU7.U7_POSTO 	= '" + Self:cPosto + "' AND"                     
			cQuery += 				" SU7.U7_VALIDO <> '2' AND"
			cQuery += 				" SU7.D_E_L_E_T_ = ' '"
		
			cQuery := ChangeQuery(cQuery)
			DbSelectArea("SU7")
			DbCloseArea()		
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "SU7", .F., .T.)		
		#ELSE       		
			DbSelectArea("SU7")
			DbSetOrder(1)
			DbGoTop()    
		#ENDIF  
	
		While 	SU7->(!EOF()) .AND.; 
				SU7->U7_FILIAL == xFilial("SU7")  
				
			If SU7->U7_POSTO == Self:cPosto
			    aAdd(aItems, SU7->U7_COD + "=" + SU7->U7_NOME)
			EndIf
			DbSkip()
		End    
	
		DbSelectArea("SU7")
		DbCloseArea()	 
		DbSelectArea("SU7")
		DbSetOrder(1)
	Else
		#IFDEF TOP		
			cQuery := "SELECT AG9_FILIAL,AG9_CODSU7,AG9_CODSU0 "
			cQuery += "FROM " + RetSQLName("AG9") + " AG9, " + RetSQLName("SU7") + " SU7"
			cQuery += 		" WHERE SU7.U7_FILIAL  = '" + xFilial("SU7") + "' AND"		
			cQuery += 				" AG9.AG9_FILIAL = '" + xFilial("AG9") + "' AND"
			cQuery += 				" AG9.AG9_CODSU0 = '" + Self:cPosto    + "' AND"
			cQuery += 				" SU7.U7_COD = AG9.AG9_CODSU7 AND"
			cQuery += 				" SU7.U7_VALIDO <> '2' AND"
			cQuery += 				" AG9.D_E_L_E_T_ = ' ' AND"
			cQuery += 				" SU7.D_E_L_E_T_ = ' '"
		
			cQuery := ChangeQuery(cQuery)
			dbSelectArea("AG9")
			dbCloseArea()		
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"AG9",.F.,.T.)		
		#ELSE       		
			dbSelectArea("AG9")
			dbSetOrder(1)
			dbGoTop()    
		#ENDIF  
	
		While AG9->(!Eof()) .And. AG9->AG9_FILIAL == xFilial("AG9") 
			If AG9->AG9_CODSU0 == Self:cPosto
			    aAdd(aItems, AG9->AG9_CODSU7 + "=" + POSICIONE("SU7",1,xFilial("SU7")+AG9->AG9_CODSU7,"U7_NOME"))
			EndIf
			AG9->(dbSkip())
		EndDo
	
		dbSelectArea("AG9")
		dbCloseArea()	 
		dbSelectArea("AG9")
		dbSetOrder(1)
	EndIf	
	
	lRet := .F.
	
	DEFINE MSDIALOG oDlg FROM 50,003 TO 220,400 TITLE STR0044 PIXEL // "Distribui็ใo de Chamados"
		
		@ 05,04  SAY STR0184 PIXEL SIZE 130,09 OF oDlg //Pesquisa :
		@ 05,30  MSGET oPesq VAR cPesq SIZE 130,09  OF oDlg PIXEL  VALID TK510SelOp(cPesq,oCombo,aItems)
		@ 22,04  SAY STR0045 PIXEL SIZE 230,09 OF oDlg	 // "Selecione um analista para receber os chamados selecionados" 
		@ 45,04  SAY STR0046 PIXEL SIZE 55,9 OF oDlg	// "Analista :"

		oCombo := TComboBox():New(42,30,{|u|if(PCount()>0,cAgent:=u,cAgent)},aItems,100,20,oDlg,,,,,,.T.,,,,,,,,,'cAgent')
		If FATPDActive() .And. FTPDUse(.T.)
	    	oCombo:lObfuscate := FATPDIsObfuscate("U7_NOME", /*cSource*/, .T.)
		Endif

	    DEFINE SBUTTON FROM 64,120/*300*/ TYPE 1 ENABLE OF oDlg ACTION (lRet:= .T.,oDlg:End())
	    DEFINE SBUTTON FROM 64,150/*335*/ TYPE 2 ENABLE OF oDlg ACTION (lRet:= .F.,oDlg:End())
	
	ACTIVATE MSDIALOG oDlg CENTERED   
Else
	Aviso(STR0025, STR0047, {"OK"}) //"Aviso" # "Nใo foi selecionado nenhum chamado para distribui็ใo"
	lRet := .F.
EndIf	
     
//Valida os assuntos com o operador selecionado
If lRet
	lRet := Tk510CmpAss(aAssuntCh,cAgent,@cAssErro) 
	If !lRet
		MsgInfo(STR0157 + cAssErro) //"O(s) grupo(s) do operador selecionado nใo possui acesso ao assunto:"
	EndIf
EndIf

If lRet     

	cMsg := STR0048 // "Confirma a distribui็ใo de #001# chamados para o analista #002#?"   
	cMsg := StrTran(cMsg, "#001#", AllTrim(Str(nCount)))
	cMsg := StrTran(cMsg, "#002#", FATPDObfuscate(AllTrim(POSICIONE("SU7", 1, xFilial("SU7")+cAgent, "U7_NOME")),"U7_NOME",/*cSource*/,.T.))

	If TmkOK(cMsg)

		//Chama a funcao para manutencao nos campos do chamado quando processamento em lote
		aAcaoOcorrencia := Acoes_Lote(1,Self:OGETDADOS:ACOLS,nCodPos,/*cAssunto*/,@cAgent,"TMK008",Self:OGETDADOS:nAT,Self:aHeaderADE)		

		If Len(aAcaoOcorrencia) == 0
			Return .F.
		EndIf

		For iCols := 1 To Len(Self:OGETDADOS:ACOLS)
			If Self:OGETDADOS:ACOLS[iCols][1] == "LBOK"
				nPos := aScan(aAcaoOcorrencia[6],{|x| x[1] == Self:OGETDADOS:ACOLS[iCols][nCodPos]})
				If nPos > 0
					Self:AlterOp(Self:OGETDADOS:ACOLS[iCols][nCodPos], cAgent, Self:cPosto)
	
					//Gera a linha na tabela ADF para indicar a distribuicao do chamado				
					TkUpdCall(	"",;
								IIf(!Empty(aAcaoOcorrencia[2]),aAcaoOcorrencia[2],""),;
								"",;
								(STR0154 + DToC(If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )) + CRLF + aAcaoOcorrencia[3]),; //"Chamado distribuido em "
								"",;
								TkOperador(),;	
								Posicione("SU7", 1, xFilial("SU7")+TkOperador(), "U7_POSTO"),;
								"",;
								,;		
								If(!IsInCallStack("GenRecurrence"), Date(), dDatabase ),;		
								Self:OGETDADOS:ACOLS[iCols][nCodPos],;
								"TMK008",;
								,,,,,,"1")	
				   			
					//Desbloqueia o chamado
					TK510UsrLock("U", Self:OGETDADOS:ACOLS[iCols][nCodPos], TkOperador())
				Else
		            nPosCh := aScan(aAcaoOcorrencia[7],{|x| x[1] == Self:OGETDADOS:ACOLS[iCols][nCodPos]})
		            If nPosCh > 0        
			 			cChNaoGrav += STR0172 + ": " + aAcaoOcorrencia[7][nPosCh][1] + " - " + STR0015 + ": " + aAcaoOcorrencia[7][nPosCh][2] + CRLF
		            	lOpenMsg := .T.
		            EndIf
				EndIf				
			EndIf
		Next iCols             	

		If lOpenMsg
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Lista os chamados que nใo foram processados. ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Tk510WindLog(cChNaoGrav)
		EndIf

	EndIf
EndIf

RestArea(aAreaADE)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAlterOp     บAutor  ณMicrosiga           บ Data ณ  01/28/08   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Transfere o responsavel do chamado.                          บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method AlterOp(cCodCall, cAgent, cPosto) Class HelpDeskListDialog 
Local lRet := .F. 
Local aArea := GetArea()

DbSelectArea("ADE")
DbSetOrder(1)
If MsSeek(xFilial("ADE")+cCodCall)
	BEGIN TRANSACTION
		RecLock("ADE", .F.)
		REPLACE ADE->ADE_OPERAD	WITH cAgent
		REPLACE ADE->ADE_GRUPO	WITH cPosto
		MsUnlock()
	END TRANSACTION						
	lRet := .T.
EndIf
             
RestArea(aArea)
Return lRet    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTransfer    บAutor  ณMicrosiga           บ Data ณ  01/28/08   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Transfere a lista de chamados de um operador para outro.     บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Transfer() Class HelpDeskListDialog 
Local oDlg     
Local oComboFrom
Local cAgentFrom := ""
Local oComboTo 
Local cAgentTo := ""  
Local aitems := {}
Local cMsg := "" 
Local cAlias := GetNextAlias() 
Local lRet := .F.
Local lAlterou := .F.
Local lTk510atg := ExistBlock("TK510ATG")
Local lMultGroup := .F.
Local lOpenMsg	 := .F.
Local lVldTrf	 := .T.
Local cChNaoGrav := ""
Local lTk510ATrf	:= ExistBlock( "TK510ATRF" )
Local lNomeOpPD	:= FATPDIsObfuscate("U7_NOME", /*cSource*/, .T.)
Local cNomeOpPD		:= ""
//Verifica se a funcionalidade de m๚ltiplos grupos de atendimento estแ ativa

	lMultGroup := .T.

If !lMultGroup
	#IFDEF TOP		
		cQuery := "SELECT U7_COD, U7_POSTO, U7_NOME, U7_FILIAL FROM " + RetSQLName("SU7") + " SU7"
		cQuery += 		" WHERE SU7.U7_FILIAL = '" + xFilial("SU7") + "' AND"
		cQuery += 				" SU7.U7_POSTO = '" + Self:cPosto + "' AND"                     
		cQuery += 				" SU7.U7_VALIDO <> '2' AND"
		cQuery += 				" SU7.D_E_L_E_T_ = ' '"
	
		cQuery := ChangeQuery(cQuery)
		DbSelectArea("SU7")
		DbCloseArea()		
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "SU7", .F., .T.)		
	#ELSE       		
		DbSelectArea("SU7")
		DbSetOrder(1)
		DbGoTop()    
	#ENDIF  
	                   
	While 	SU7->(!EOF()) .AND.; 
			SU7->U7_FILIAL == xFilial("SU7") 
	
		If SU7->U7_POSTO == Self:cPosto
		    aAdd(aItems, SU7->U7_COD + "=" + SU7->U7_NOME)
		EndIf
		DbSkip()
	End
	
	DbSelectArea("SU7")
	DbCloseArea()	 
	DbSelectArea("SU7")
	DbSetOrder(1) 
Else
	#IFDEF TOP		
		cQuery := "SELECT AG9_FILIAL,AG9_CODSU7,AG9_CODSU0 "
		cQuery += " FROM " + RetSQLName("AG9") + " AG9, " + RetSQLName("SU7") + " SU7"
		cQuery += 		" WHERE SU7.U7_FILIAL  = '" + xFilial("SU7") + "' AND"		
		cQuery += 				" AG9.AG9_FILIAL = '" + xFilial("AG9") + "' AND"
		cQuery += 				" AG9.AG9_CODSU0 = '" + Self:cPosto    + "' AND"
		cQuery += 				" SU7.U7_COD = AG9.AG9_CODSU7 AND"
		cQuery += 				" SU7.U7_VALIDO <> '2' AND"
		cQuery += 				" AG9.D_E_L_E_T_ = ' ' AND"
		cQuery += 				" SU7.D_E_L_E_T_ = ' '"
				
		cQuery := ChangeQuery(cQuery)
		dbSelectArea("AG9")
		dbCloseArea()		
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"AG9",.F.,.T.)		
	#ELSE       		
		dbSelectArea("AG9")
		dbSetOrder(1)
		dbGoTop()    
	#ENDIF  

	While AG9->(!Eof()) .And. AG9->AG9_FILIAL == xFilial("AG9") 
		If AG9->AG9_CODSU0 == Self:cPosto
		    aAdd(aItems, AG9->AG9_CODSU7 + "=" + POSICIONE("SU7",1,xFilial("SU7")+AG9->AG9_CODSU7,"U7_NOME"))
		EndIf
		AG9->(dbSkip())
	EndDo

	dbSelectArea("AG9")
	dbCloseArea()	 
	dbSelectArea("AG9")
	dbSetOrder(1)
EndIf

DEFINE MSDIALOG oDlg FROM 50,003 TO 300,320 TITLE STR0049 PIXEL // "Transfer๊ncia de lista de Chamados"
	@ 08,04  SAY STR0050 PIXEL SIZE 150,09 OF oDlg	// "Selecione de qual analista serใo transferidos os chamados."
	@ 18,04  SAY STR0051 PIXEL SIZE 55,9 OF oDlg // "Analista :"
	oComboFrom := TComboBox():New(18,34,{|u|if(PCount()>0,cAgentFrom:=u,cAgentFrom)},aItems,100,20,oDlg,,,,,,.T.,,,,,,,,,'cAgentFrom')
	If FATPDActive() .And. FTPDUse(.T.)
		oComboFrom:lObfuscate := lNomeOpPD
	Endif
	@ 34,04  SAY STR0052 PIXEL SIZE 150,09 OF oDlg	// "Selecione para qual analista serใo enviados os chamados."
	@ 44,04  SAY STR0053 PIXEL SIZE 55,9 OF oDlg	// "Analista :"
	oComboTo := TComboBox():New(48,34,{|u|if(PCount()>0,cAgentTo:=u,cAgentTo)},aItems,100,20,oDlg,,,,,,.T.,,,,,,,,,'cAgentTo')    	
	If FATPDActive() .And. FTPDUse(.T.)
		oComboTo:lObfuscate :=lNomeOpPD
	Endif
	
    DEFINE SBUTTON FROM 69,34/*300*/ TYPE 1 ENABLE OF oDlg ACTION (lRet:= .T.,oDlg:End())
    DEFINE SBUTTON FROM 69,69/*335*/ TYPE 2 ENABLE OF oDlg ACTION (lRet:= .F.,oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED   

If lRet	
	cNomeOpPD := IIF(lNomeOpPD,FATPDObfuscate("OPERADOR"),"")
	cMsg := STR0054 // "Confirme a transfer๊ncia de todos os chamados do Analista '#001#' para o Analista '#002#'?"
	cMsg := StrTran(cMsg, "#001#" , IIF(lNomeOpPD,cNomeOpPD, AllTrim(POSICIONE("SU7", 1, xFilial("SU7")+cAgentFrom, "U7_NOME"))))
	cMsg := StrTran(cMsg, "#002#" , IIF(lNomeOpPD,cNomeOpPD, AllTrim(POSICIONE("SU7", 1, xFilial("SU7")+cAgentTo	, "U7_NOME"))))
	If TmkOk(cMsg)
	
		DbSelectArea("ADE")
		DbSetOrder(2) //ADE_FILIAL+ADE_OPERAD+ADE_GRUPO
		
		#IFDEF TOP		
			cQuery := "SELECT ADE_CODIGO, ADE_GRUPO, ADE_OPERAD, ADE_OPEUSO FROM " + RetSQLName("ADE") + " ADE"
			cQuery += " WHERE ADE.ADE_FILIAL = '" + xFilial("ADE") + "' AND"
			cQuery += 			" ADE.ADE_GRUPO = '" + Self:cPosto + "' AND"
			cQuery += 			" ADE.ADE_OPERAD 	= '" + cAgentFrom + "'  AND"		
			cQuery += 			" ADE.D_E_L_E_T_ = ' '"
			cQuery += 		" ORDER BY " + SqlOrder(IndexKey())
			
			cQuery := ChangeQuery(cQuery)
			DbSelectArea("ADE")
			DbCloseArea()
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)		
		#ELSE
			MsSeek(xFilial("ADE")+cAgentFrom+Self:cPosto)
		#ENDIF	                                        
		
 		While 	(cAlias)->(!EOF()) .AND.; 
				(cAlias)->ADE_GRUPO == Self:cPosto .AND.;
				(cAlias)->ADE_OPERAD == cAgentFrom
								
				If lTk510ATrf
					If !(ValType(lVldTrf := ExecBlock("TK510ATRF", .F., .F., { (cAlias)->ADE_CODIGO, cAgentFrom, cAgentTo } )) == "L")
						lVldTrf := .T.
					EndIf
				EndIf
				If lVldTrf
				
					dbSelectArea("ADE")
					ADE->(dbSetOrder(1))
					ADE->(dbSeek(xFilial("ADE")+(cAlias)->ADE_CODIGO))
					
					//Verifica se o chamado estแ bloqueado, caso contrแrio faz o bloqueio.
					If TK510UsrLock("L", ADE->ADE_CODIGO, TkOperador(), .F.)		
						lAlterou := Self:AlterOp((cAlias)->ADE_CODIGO, cAgentTo, Self:cPosto)
						//Desbloqueia o chamado
						TK510UsrLock("U", ADE->ADE_CODIGO, TkOperador())										
					Else
			 			cChNaoGrav += STR0172 + ": " + ADE->ADE_CODIGO + " - " + STR0015 + ": " + ADE->ADE_OPEUSO + " - ";
						  + IIF(lNomeOpPD, cNomeOpPD,AllTrim(Posicione("SU7",1,xFilial("SU7")+ADE->ADE_OPEUSO,"U7_NOME"))) + CRLF
		            	lOpenMsg := .T.
					EndIf
				
				EndIf
				If lTk510atg
			  		ExecBlock("TK510ATG",.F.,.F.,{lAlterou,(cAlias)->ADE_CODIGO,cAgentFrom,cAgentTo})
				EndIf
				
				DbSelectArea(cAlias)
				(cAlias)->(DbSkip())
		End
		(cAlias)->(DbCloseArea())

		If lOpenMsg
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Lista os chamados que nใo foram processados. ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Tk510WindLog(cChNaoGrav)
		EndIf
	Else
		lFlagAtu :=.F.
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK510FuncoesบAutor  ณMicrosiga           บ Data ณ  01/28/08   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcoes de tela: Incluir, Alterar, Excluir                   บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method TK510Funcoes( nAuxOpc, aIdxEval, cCodLinha ) Class HelpDeskListDialog
Local nCodPos 	:= 0		//Armazena a posi็ใo do campo ADE_CODIGO
Local lSeek	  	:= .F.   //Indica se o atendimento foi encontrado
Local nAt		:= 0		//Variavael de controle do loop 
Local lRet		:= .F.		//Retorno da funcao
Local lGAtualiza:= .F.	//Indica se deverแ atualizar o grid  
Local oMenu 	:= Nil //Menu suspenso das opcoes do botao DISTRIBUIR
Local nMenu    	:= 0
Local nPosItem 	:= 0
Local nLinADF 	:= 0   
Local nCposADF 	:= 0
Local nRecADE 	:= 0      
Local nMaxItem 	:= 0
Local lTipoLock := .F.
Local aRotTmp	:= {}
Local cGrpAnt	:= ""
Local lNoRefresh:= .F.
Local lVisualiza := .T. // controla a visualizacao do chamado ja esta em atendimento por outro usuario
Local aRegsWF	:= {}
Local aParam	:= {}
Local nX		:= 0

Private aCols	:= {}
Private aHeader	:= {} 
Private INCLUI 	:= .F.
Private ALTERA 	:= .T.
Private lFlagAtu:= .T.


Default cCodLinha	:= ""	//Armazena o c๓digo do atendimento manipulado

If Self:oTimer <> Nil
	Self:oTimer:DeActivate()
EndIf
Self:RestAtalho()
    
Self:GetFieldPos("ADE_CODIGO", @nCodPos, Self:aHeaderADE)        

If Empty(cCodLinha)    	
	If Len(Self:OGETDADOS:aCols)>=Self:OGETDADOS:NAT .AND. Len(Self:OGETDADOS:aCols[Self:OGETDADOS:NAT])>=nCodPos
		cCodLinha := Self:OGETDADOS:aCols[Self:OGETDADOS:NAT,nCodPos]
	EndIf
Else
	lNoRefresh := .T.
EndIf
//Desativa botoes
FOR nX := 1 to 18
	Setkey(Self:ShortCut(nX)[1],{||.T.})
Next

If nAuxOpc == 2 .OR. nAuxOpc == 3 .OR. nAuxOpc == 4 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPosiciona a tabela do teleatendimento no registro do atendimento pendente |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู                                                                                     
	DbSelectArea("ADE")
	DbSetOrder(1)
	If ValType(cCodLinha)=="C" .AND. !Empty(cCodLinha)
		lSeek := dbSeek(xFilial("ADE")+cCodLinha)
	Else
		lSeek := .F.	
	EndIf 

	//Se for altera็ใo verifica se o chamado estแ bloqueado, caso contrแrio faz o bloqueio.
	If nAuxOpc == 4 .And. lSeek .And. !TK510UsrLock("L", ADE->ADE_CODIGO, TkOperador(), Nil, @lVisualiza)
		If lVisualiza
			nAuxOpc := 2	//Abre o chamado no modo de visualiza็ใo, pois estแ bloqueado para outro operador.
		Else
			nAuxOpc := 0
			lGAtualiza := .F.
		EndIf
	EndIf	
	
	Self:oObj:service := TeleServicing():New() 
	
	If nAuxOpc <> 3 .AND. lSeek
		Tk510SetGr(cCodLinha,@cGrpAnt)
	EndIf
	
	Self:oObj:service:load( Self:oObj:GetModel() ) 	
		
EndIf

If nAuxOpc == 2 .AND. lSeek      
	Self:oObj:lReadOnly := .T.
	INCLUI := .F.
	ALTERA := .T.
 	Self:oObj:showDialog( STR0004, nAuxOpc )          //"Visualizar" //"Visualizar"
	
	If !Empty(cGrpAnt)
		Tk510RstGr(cGrpAnt)
	EndIf
	
ElseIf nAuxOpc == 3 
	Self:oObj:lReadOnly := .F.
	INCLUI := .T.
	ALTERA := .F.
 	If Self:oObj:showDialog( STR0002, nAuxOpc ) //"Incluir" //"Incluir"
 		BEGIN TRANSACTION
			BEGIN SEQUENCE
		 		Self:oObj:service:tableStructureInfo:master:getValue("ADE_CODIGO", 1, @cCodLinha)
				Self:oObj:service:tableStructureInfo:save()
		  		aParam := {aHeader,aCols,nAuxOpc,aRegsWF}
		  		Self:oObj:service:whenRecorded:execute(@aParam)
		  		lRet := .T.  
		  		lGAtualiza	:= .T.
		  		Self:lWereIncluded := Self:oObj:lWereIncluded
			RECOVER
				DisarmTransaction()
				Final()
			END SEQUENCE
		END TRANSACTION
	Else
		Setkey(K_CTRL_S,{||.T. } )//remove atribui็ใo da tecla CTRL+S que foi atribuida na abertura da janela 
		Setkey(Self:Shortcut(10)[1],{||Self:Find() } )//redefine o botใo 10-Pesquisa	 		
	EndIf

ElseIf nAuxOpc == 4 .AND. lSeek
	
	Self:oObj:lReadOnly := .F.                                                          
	INCLUI := .F.
	ALTERA := .T.
 	If Self:oObj:showDialog( STR0003, nAuxOpc )       //"Alterar" //"Alterar"
		BEGIN TRANSACTION
			BEGIN SEQUENCE
		  		Self:oObj:service:tableStructureInfo:save()
	  			aParam := {aHeader,aCols,nAuxOpc,aRegsWF}
				Self:oObj:service:whenRecorded:execute(@aParam)
				lRet := .T.   
				lGAtualiza	:= .T.
			RECOVER
				DisarmTransaction()
				Final()
			END SEQUENCE
		END TRANSACTION
		//Zera a referencia do chamado caso exista apenas uma linha
		If Len(Self:OGETDADOS:aCols) == 1
			cCodLinha := ""
		EndIf
		
	EndIf          

	If !Empty(cGrpAnt)
		Tk510RstGr(cGrpAnt)
	EndIf
	
ElseIf nAuxOpc == 5
	If FATPDUserAcc() .And. Self:Distribute()
		lGAtualiza:=.T.
	EndIf
	If lFlagAtu == .F.
		lNoRefresh :=.T.
	EndiF
ElseIf nAuxOpc == 6
	//TMKA503A()
	TMKA510G()
	
ElseIf nAuxOpc == 7
	If FATPDUserAcc() .And. Self:Transfer()
		lGAtualiza	:= .T.
	EndIf
	
ElseIf nAuxOpc == 8	
	Self:SelectCall(.T.)		//Desmarca e desbloqueia os chamados.
	Self:SetFilter()
	lGAtualiza	:= .T.  
	Self:lSelectAll := .F.
	Self:oCheckBox:CtrlRefresh()
	
ElseIf nAuxOpc == 9	
	If !Pergunte("TMK510A")	
		Return(.F.)		
	EndIF	      
	Self:setParameters()
	lGAtualiza	:= .T.          
	Self:nMaxRowsPerPage := Self:getMaxRowsPP()	
	
ElseIf nAuxOpc == 10
	Self:ConfigCols()
	
ElseIf nAuxOpc == 11
	Self:SaveConfig() 
	
ElseIf nAuxOpc == 12
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณExibe Menu POP-UP com as opcoes Distribuir e Associarณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nMenu := 1 To Len(Self:oDlg:aControls)
		If Self:oDlg:aControls[nMenu]:cCaption == STR0086 //"A็๕es"
			Exit
		EndIf
	Next nMenu

	oMenu := TMenu():New(0,0,0,0,.T.)

	If Self:lSupervisor 
		oMenu:Add(TMenuItem():New(Self:oDlg,STR0012,,,,{||Self:Tk510Funcoes( 5, aIdxEval )},,,,,,,,,.T.)) //"Distribuir"
	EndIf

	oMenu:Add(TMenuItem():New(Self:oDlg,STR0081,,,,{|| Self:Tk510Funcoes( 13, aIdxEval )},,,,,,,,,.T.)) //"Associar"
	oMenu:Add(TMenuItem():New(Self:oDlg,STR0151,,,,{|| Self:Tk510Funcoes( 14, aIdxEval )},,,,,,,,,.T.)) //"Transferir Chamados entre Grupos" 
	oMenu:Add(TMenuItem():New(Self:oDlg,STR0152,,,,{|| Self:Tk510Funcoes( 15, aIdxEval )},,,,,,,,,.T.)) //"Encerrar Chamados"
	oMenu:Add(TMenuItem():New(Self:oDlg,STR0153,,,,{|| Self:Tk510Funcoes( 16, aIdxEval )},,,,,,,,,.T.)) //"Assumir Chamados"

	Self:oDlg:aControls[nMenu]:SetPopupMenu( oMenu )
	Self:oDlg:Refresh()	

ElseIf nAuxOpc == 13 
	If Self:Associar()	
		lGAtualiza:=.T.
	EndIf
                    
//Transferir em Lote para outro Grupo
ElseIf nAuxOpc == 14
	If Self:TransfLote()
		lGAtualiza:=.T.
	EndIf

//Encerramento de Chamados em LOTE
ElseIf nAuxOpc == 15
	If Self:EncerraLote()
		lGAtualiza := .T.
	EndIf

//Assumir Chamados em LOTE
ElseIf nAuxOpc == 16
	//Verifica se o operador esta configurado para assumir chamados.
	If Posicione("SU7",1,xFilial("SU7")+TkOperador(),"U7_PENDCHA") <> "2"
		If Self:AssumeLote()
			lGAtualiza := .T.	
		EndIf
	Else
		Help(" ",1,"TK510ASSU")	//"Operador configurado para nใo assumir chamados."##"Verificar o perfil do operador no Cadastro de Operadores."
		lGAtualiza := .F.
	EndIf
ElseIf nAuxOpc == 17
	If Self:Duplicate()
		lGAtualiza := .T.
	EndIf 

ElseIf nAuxOpc == 18
	aRotTmp		:= {	{ STR0001,"AxPesqui"  ,0,1 },;	//"Pesquisar"
					 	{ STR0004,"TK503AOpc" ,0,2 },;	//"Visualizar"
					 	{ STR0003,"TK503AOpc" ,0,4 }}	//"Alterar"
					 	
	TMKA510G(Nil,Nil,Nil,"ADE->ADE_RECORR == '1'",aRotTmp) 
	lGAtualiza	:= .T. 
		
// Projeto TDI TFEHFH - Geracao de planilha em Excel
ElseIf nAuxOpc == 19 
	If Self:oTimer <> Nil
		Self:oTimer:DeActivate()
	EndIf
	TK510EXCEL(Self:aHeaderADE, Self:aColsADE, Self) 
	Self:pgFirst()
	If Self:oTimer <> Nil
		Self:oTimer:Activate()
	EndIf
	lGAtualiza	:= .T. 
EndIf          
Self:RestAtalho(aIdxEval)
If lRet .And. (nAuxOpc == 3 .Or. (nAuxOpc == 4 .And. lSeek))
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Executa rotina de envio de workflow         |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nX := 1 To Len(aParam[4])
		Tk510WF(aParam[4][nX][1],aParam[4][nX][2],aParam[4][nX][3])
	Next nX
EndIf

If lGAtualiza .AND. !lNoRefresh
	If !Empty(cCodLinha) .AND. (nAuxOpc == 2 .OR. nAuxOpc == 3 .OR. nAuxOpc == 4 .OR. nAuxOpc == 5 .OR. nAuxOpc == 6 .OR. nAuxOpc == 7 .OR. nAuxOpc == 13 .OR. nAuxOpc == 14 .OR. nAuxOpc == 15 .OR. nAuxOpc == 16)
		Self:posPage("ADE_CODIGO", cCodLinha)
		If Len(Self:aColsADE) > 0
			For nAt := 1 To Len(Self:aColsADE)
				If Len(Self:aColsADE[nAt])>=nCodPos .AND. cCodLinha == Self:aColsADE[nAt,nCodPos]
					Self:OGETDADOS:NAT := nAt
					Self:oGetDados:GoTo(nAt)
					Self:oGetDados:ForceRefresh()
			   		Exit		
				EndIf
			Next nAt	   
		Else
			//Se nใo existir nenhum chamado pra ser apresentado, faz o refreh da tela do Service Desk.
			Self:oGetDados:SetArray(Self:aColsADE,.F.) 
			Self:oGetDados:ForceRefresh()
			Self:Refresh()
		EndIf		
	ElseIf nAuxOpc <> 2                  
		Self:aColsADE 	:= {}
		aCols	:= {}
		Self:TkOrder(Self:nOrder, aIdxEval)  
	EndIf 
EndIf  

Self:LoadProfile()
Self:LoadIncident()

Self:SetAtalho(aIdxEval)
If Self:oTimer <> Nil
	Self:oTimer:Activate()
EndIf

TMKFree( Self:oObj:service)


Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetFieldPos   บAutorณVendas Clientes   บ Data ณ  18/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a posicao do campo no aHeader/aCols.            	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   
Method GetFieldPos(cField, nPos, aAuxHeader) Class HelpDeskListDialog
Local nItem := 0 //Posicao no aheader
Local lRet:=.F. //Retorno da funcao      

Default aAuxHeader := ParamIXB[1]

For nItem:=1 To Len(aAuxHeader)
	If AllTrim(aAuxHeader[nItem][2]) == cField
		nPos := nItem
		lRet := .T.
		Exit
	EndIf  
Next nItem

Return lRet                    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDialogLabelบAutor ณVendas Clientes     บ Data ณ  18/01/08   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibe as legendas de chamados na tela de gerencia.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method DialogLabel(lModo) Class HelpDeskListDialog

Local aLegendas	:= {}
Local aCores	:= {}
Local lTK510Leg	:= ExistBlock("TK510Leg")
Local aTK510Leg	:= {}

Default lModo := .T.  // TFEHFH Exportacao Excel - controla se exibe ou nao a legenda

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณStatus do chamadoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCores := {	{Self:cGreen	, STR0055},;	// "Em aberto"
			{Self:cBlue		, STR0056},;	// "Pendente"
			{Self:cGray		, STR0057},;	// "Nใo distribuido"
			{Self:cRed		, STR0058}}		// "Prazo de SLA ultrapassado"

AAdd(aCores,{Self:cWhite, STR0158})	// "Modelo recorrente"
				
If lTK510Leg
	aTK510Leg := ExecBlock("TK510Leg",.F.,.F., {aCores})
	If ValType(aTK510Leg) == "A" .AND. Len(aTK510Leg) > 0
		aCores := aClone(FWChkColor(aTK510Leg))
	EndIf
EndIf
     
AAdd(aLegendas,{STR0107	,aCores})   // "Status do chamado"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณStatus do SLAณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCores := {	{Self:cGreen	, STR0108},;	// "Iniciado/ Dentro do Prazo"
			{Self:cYellow	, STR0109},;	// "Dentro do Prazo/ Aten็ใo"
			{Self:cOrange	, STR0110},;	// "Dentro do Prazo/ Risco de Atraso"
			{Self:cRed		, STR0111},;	// "Atrasado"
			{Self:cWhite	, STR0112}}		// "Nใo iniciado/ Em Pausa"
				
AAdd(aLegendas,{STR0113	,aCores}) // "Status do SLA"
     
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณStatus do workflowณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู			

aCores := {	{ Self:cYellow	, "Aprovado/Reprovado" },;
			{ Self:cGreen	, "Aprovado" },;
			{ Self:cRed		, "Reprovado" },;
			{ Self:cBlue	, "Aguardando resposta" },;
			{ Self:cWhite	, "Sem workflow" } }

AAdd(aLegendas,{STR0178	,aCores}) // "Status do workflow"	

if lModo
	BrwLegenda(STR0033,aLegendas) //"Legendas"
Endif	

Return(aLegendas)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFind       บAutor ณVendas Clientes     บ Data ณ  12/08/08   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pesquisa na lista de chamados.                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Find() Class HelpDeskListDialog
Local oDlg
Local oCombo       
Local aItems := {} 
Local cField	:= "" 
Local lRet 	:= .F.
Local nI	:= 0       
Local oSearch  
Local cSearch	:= Space(200)
Local cCampo 	:= ""
Local nCampoPos	:= 0
Local nAt	:= 0
Local lFind	:= .F.   
Local xActualValue      
Local nPosField             
Local cblSearch := ""
             
If Self:oTimer <> Nil
	Self:oTimer:DeActivate()
EndIf
For nI := 3 To Len(Self:aHeaderADE)                   
	cCampo := Self:aHeaderADE[nI, 2]
	If !(IsHeadRec(cCampo) .OR.;
		IsHeadAlias(cCampo)	 .OR.; 
		Self:aHeaderADE[nI, 8] == "M" .OR.; 
		Self:aHeaderADE[nI, 10] == "V")
		
		If Len(aItems)==0
			cField := AllTrim(Str(nI))
		EndIf				
		aAdd(aItems, AllTrim(Str(nI)) + "=" + Self:aHeaderADE[nI,1])	
	EndIf
Next nI


DEFINE MSDIALOG oDlg FROM 50,003 TO 180,285 TITLE STR0059 PIXEL // "Pesquisar"
	
	@ 08,04 SAY STR0060               PIXEL SIZE 130,09 OF oDlg	 // "Campo:"
	oCombo := TComboBox():New(08,44,{|u| If(PCount() > 0, cField := u, cField)}, aItems, 80, 11, oDlg,,,,,, .T.,,,,,,,,, 'cField')
	@ 22,04 SAY STR0061               PIXEL SIZE 130,09 OF oDlg	 // "Procura por:"
	@ 22,44 MSGET oSearch VAR cSearch OF oDlg PIXEL SIZE 080,09 

    DEFINE SBUTTON FROM 50,34 TYPE 1 ENABLE OF oDlg ACTION (lRet := .T.,oDlg:End())
    DEFINE SBUTTON FROM 50,69 TYPE 2 ENABLE OF oDlg ACTION (lRet := .F.,oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

If lRet 	
	nCampoPos := Val(cField)
	lFind := Self:posPage(Self:aHeaderADE[nCampoPos,2], RTrim(cSearch))
	If nCampoPos > 0 .AND. lFind                 
 
		nPosField := aScan(Self:aSetField, &("{|x|AllTrim(x[1])=='" + AllTrim(Self:aHeaderADE[nCampoPos,2]) + "'}"))
		If nPosField <= 0 .OR. (nPosField > 0 .AND. Self:aSetField[nPosField, 2] == "C")
			xActualValue := RTrim(cSearch)
			cblSearch := "{||ValType(Self:aColsADE[nAt,nCampoPos])=='C' .AND. AllTrim(Upper(xActualValue)) == AllTrim(Upper(Self:aColsADE[nAt,nCampoPos]))}"
		ElseIf Self:aSetField[nPosField, 2] == "D" 
		    xActualValue := CtoD(cSearch)
		    cblSearch := "{||ValType(Self:aColsADE[nAt,nCampoPos])=='D' .AND. xActualValue == Self:aColsADE[nAt,nCampoPos]}"
		ElseIf Self:aSetField[nPosField, 2] == "N" 
			xActualValue := Val(cSearch)
			cblSearch := "{||ValType(Self:aColsADE[nAt,nCampoPos])=='N' .AND. xActualValue == Self:aColsADE[nAt,nCampoPos]}"
		ElseIf Self:aSetField[nPosField, 2] == "L"
			xActualValue := RTrim(cSearch)
			If Len( xActualValue ) == 1
				xActualValue := "." + xActualValue + "."
			EndIf
			cblSearch := "{||ValType(Self:aColsADE[nAt,nCampoPos])=='L' .AND. &(xActualValue) == Self:aColsADE[nAt,nCampoPos]}"
		EndIf

		For nAt := 1 To Len(Self:aColsADE)                           
			If Len(Self:aColsADE[nAt])>=nCampoPos
				If Eval(&(cblSearch))
			   		Self:OGETDADOS:NAT := nAt
			   		Self:oGetDados:GoTo(nAt)				
			   		Exit		
				EndIf
			EndIf
		Next nAt	   		
	EndIf
	
	If !lFind
		Aviso(STR0062, STR0063, {"OK"})		// "Pesquisa" # "A pesquisa nใo encontrou nenhum registro."
	EndIf
EndIf
If Self:oTimer <> Nil
	Self:oTimer:Activate()
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณpgNext     บAutor ณVendas Clientes     บ Data ณ  12/08/08   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Move para proxima pagina                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                
Method pgNext(aIdxEval) Class HelpDeskListDialog
Local iCols := 0
                 
If Self:oTimer <> Nil
	Self:oTimer:DeActivate()
EndIf
For iCols := 1 To Len(Self:OGETDADOS:ACOLS)
	If Self:OGETDADOS:ACOLS[iCols][1] == "LBOK"
		If !TmkOK(STR0064) // "A sele็ใo de chamados serแ perdida. Confirma a mudan็a de pแgina?"
			Return .T. 	
		Else
			Self:SelectCall(.T.)	//Desmarca e desbloqueia os chamados.
			Exit
		EndIf
	EndIf
Next iCols             

If Self:nRecnoPos > 0	
	Self:aColsADE 	:= {}	
	aCols	:= {}	
                                                                         
	Self:Tk510Filtra()                                              
	While (Self:cTabelaAux)->(!EOF()) .AND.;
		(Self:cTabelaAux)->(RecNo()) <> Self:nRecnoPos
		DbSelectArea(Self:cTabelaAux)
		DbSkip()	
	End
	If 	(Self:cTabelaAux)->(!EOF()) 	.AND.;
		((Len(Self:aRecnoAnt)<=1) 		.OR.; 
		(Len(Self:aRecnoAnt)>1 .AND. (Self:cTabelaAux)->(RecNo()) <> Self:aRecnoAnt[Len(Self:aRecnoAnt)]))
		
		aAdd(Self:aRecnoAnt,(Self:cTabelaAux)->(RecNo()))		
		Self:Tk510ACols(.F.)
		Self:TkOrder(Self:nOrder, , .F.)  //oTk510Tela:oGetDados:Refresh()
	EndIf
EndIf 

DbSelectArea(Self:cTabelaAux)
DbCloseArea()		
If Self:oTimer <> Nil
	Self:oTimer:Activate()
EndIf
Self:lSelectAll := .F.
Self:oCheckBox:CtrlRefresh()
Return .T.     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณpgPrevious บAutor ณVendas Clientes     บ Data ณ  12/08/08   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Move para pagina anterior                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                
Method pgPrevious() Class HelpDeskListDialog
Local nRecnoAnt := 0
Local iCols := 0

If Self:oTimer <> Nil
	Self:oTimer:DeActivate()
EndIf
For iCols := 1 To Len(Self:OGETDADOS:ACOLS)
	If Self:OGETDADOS:ACOLS[iCols][1] == "LBOK"
		If !TmkOK(STR0064) // "A sele็ใo de chamados serแ perdida. Confirma a mudan็a de pแgina?"
			Return .T. 	 
		Else
			Self:SelectCall(.T.)	//Desmarca e desbloqueia os chamados.
			Exit				
		EndIf
	EndIf
Next iCols             

Self:aColsADE 	:= {}	
aCols	:= {}
    
    If Len(Self:aRecnoAnt)>1
    	nRecnoAnt := Self:aRecnoAnt[Len(Self:aRecnoAnt)-1]
    	aSize(Self:aRecnoAnt, Len(Self:aRecnoAnt)-1)
    ElseIf Len(Self:aRecnoAnt)>0
    	nRecnoAnt := Self:aRecnoAnt[Len(Self:aRecnoAnt)]
    EndIf          
    
Self:Tk510Filtra()
If nRecnoAnt > 0
	While (Self:cTabelaAux)->(!EOF()) .AND. (Self:cTabelaAux)->(RecNo()) <> nRecnoAnt
		DbSelectArea(Self:cTabelaAux)
		DbSkip()
	End
EndIf	
Self:Tk510ACols(.F.)
Self:TkOrder(Self:nOrder,, .F.) 

DbSelectArea(Self:cTabelaAux)
DbCloseArea()			
If Self:oTimer <> Nil
	Self:oTimer:Activate()
EndIf
Return .T.     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณpgFirst    บAutor ณVendas Clientes     บ Data ณ  12/08/08   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Move para primeira pagina                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                
Method pgFirst(aIdxEval) Class HelpDeskListDialog
Local iCols := 0

If Self:oTimer <> Nil
	Self:oTimer:DeActivate()
EndIf
For iCols := 1 To Len(Self:OGETDADOS:ACOLS)
	If Self:OGETDADOS:ACOLS[iCols][1] == "LBOK"
		If !TmkOK(STR0064) // "A sele็ใo de chamados serแ perdida. Confirma a mudan็a de pแgina?"
			Return .T. 	 
		Else
			Self:SelectCall(.T.)	//Desmarca e desbloqueia os chamados.
			Exit				
		EndIf
	EndIf
Next iCols             

Self:aColsADE 	:= {}
aCols	:= {}
Self:aRecnoAnt := {}


Self:Tk510Filtra()                                              
Self:Tk510ACols()
Self:TkOrder(Self:nOrder,, .F.)  

DbSelectArea(Self:cTabelaAux)
DbCloseArea()			
If Self:oTimer <> Nil
	Self:oTimer:Activate()
EndIf
Return .T.     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณpglast     บAutor ณVendas Clientes     บ Data ณ  12/08/08   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Move para ultima pagina                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                
Method pgLast(aIdxEval) Class HelpDeskListDialog
Local nI 		:= 0
Local lFirst 	:= .T.
Local iPage		:= 0
Local lRet 		:= .F.                                  
Local iCols := 0

If Self:oTimer <> Nil
	Self:oTimer:DeActivate()
EndIf
For iCols := 1 To Len(Self:OGETDADOS:ACOLS)
	If Self:OGETDADOS:ACOLS[iCols][1] == "LBOK"
		If !TmkOK(STR0064) // "A sele็ใo de chamados serแ perdida. Confirma a mudan็a de pแgina?"
			Return .T. 
		Else
			Self:SelectCall(.T.)	//Desmarca e desbloqueia os chamados.
			Exit					
		EndIf
	EndIf
Next iCols             

Self:aColsADE 	:= {}
aCols	:= {}
Self:aRecnoAnt := {}
    
    Self:Tk510Filtra()      
While (Self:cTabelaAux)->(!EOF())		
	If (Empty(Self:cFilter) .OR. &(Self:cFilter)) .AND. (Empty(Self:cBrwFilter) .OR. &(Self:cBrwFilter))				                       
		If lFirst
			aAdd(Self:aRecnoAnt,(Self:cTabelaAux)->(RecNo()))					
			lFirst := .F.					
		EndIf
		If Self:nMaxRowsPerPage <= nI				
			nI := 0		
			aAdd(Self:aRecnoAnt,(Self:cTabelaAux)->(RecNo()))							
		EndIf 		 
		nI++
	EndIf                                      
	
	DbSelectArea(Self:cTabelaAux)
	DbSkip()	
End                                
iPage	:= Len(Self:aRecnoAnt)
lRet 		:= .T.     
If lRet 	    
	DbSelectArea(Self:cTabelaAux)
	DbGoTop()		
	While 	(Self:cTabelaAux)->(!EOF()) .AND.; 
			Self:aRecnoAnt[iPage] <> (Self:cTabelaAux)->(RecNo()) 				
			
		DbSelectArea(Self:cTabelaAux)
		DbSkip()	
	End                                 
	If (Self:cTabelaAux)->(!EOF())                                           
		Self:Tk510ACols(.F.)
		Self:TkOrder(Self:nOrder,, .F.)  		
	EndIf		            
EndIf	   
DbSelectArea(Self:cTabelaAux)
DbCloseArea()			
If Self:oTimer <> Nil
	Self:oTimer:Activate()
EndIf
Return .T.     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณposPage    บAutor ณVendas Clientes     บ Data ณ  12/08/08   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Procura um chamado e posiciona na pแgina do mesmo.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                
Method posPage(cFieldName, cValue, lPage, nPage) Class HelpDeskListDialog
Local nI 		:= 0
Local lFirst 	:= .T.
Local lFind		:= .F.
Local iPage		:= 0
Local lRet 		:= .F.        
Local nActualPg := Len(Self:aRecnoAnt)
Local aActualPg := Self:aRecnoAnt 
Local nPosField := 0
Local xActualValue     
Local cBlockEval := ""

Default lPage := .F.
Default nPage := 0
                                 
If Self:oTimer <> Nil
	Self:oTimer:DeActivate()
EndIf
Self:aColsADE 	:= {}
aCols	:= {}
Self:aRecnoAnt := {}

If !lPage 
	nPosField := aScan(Self:aSetField, &("{|x|AllTrim(x[1])=='" + AllTrim(cFieldName) + "'}"))
	If nPosField <= 0 .OR. (nPosField > 0 .AND. Self:aSetField[nPosField, 2] == "C")
		xActualValue := RTrim(cValue)
		cBlockEval := "{||RTrim(" + Self:cTabelaAux + "->" + cFieldName + ")=='" + xActualValue + "'}"
	ElseIf Self:aSetField[nPosField, 2] == "D" 
	    xActualValue := cValue
	    cBlockEval := "{||DtoC(" + Self:cTabelaAux + "->" + cFieldName + ")=='" + xActualValue + "'}"
	ElseIf Self:aSetField[nPosField, 2] == "N"
		xActualValue := Val(cValue)
		cBlockEval := "{||" + Self:cTabelaAux + "->" + cFieldName + "==" + xActualValue + "}"
	ElseIf Self:aSetField[nPosField, 2] == "L"
		xActualValue := cValue
		If Len( xActualValue ) == 1
			xActualValue := "." + xActualValue + "."
		EndIf
		cBlockEval := "{||" + Self:cTabelaAux + "->" + cFieldName + "==" + xActualValue + "}"
	EndIf	
EndIf
    
Self:Tk510Filtra()      
While (Self:cTabelaAux)->(!EOF())		
	If (Empty(Self:cFilter) .OR. &(Self:cFilter)) .AND. (Empty(Self:cBrwFilter) .OR. &(Self:cBrwFilter))				
		If lFirst
			aAdd(Self:aRecnoAnt,(Self:cTabelaAux)->(RecNo()))					
			lFirst := .F.					
		EndIf
		If Self:nMaxRowsPerPage <= nI				
			nI := 0		
			aAdd(Self:aRecnoAnt,(Self:cTabelaAux)->(RecNo()))							
		EndIf
		nI++
		If lPage
			iPage	:= Len(Self:aRecnoAnt)
			If iPage >= nPage					
				lRet 		:= .T.     
				Exit				
			EndIf                           
			iPage	:= 0
		Else 		 
			//Verifica se ้ o item que se procura	
			If Eval(&(cBlockEval)) 
				iPage	:= Len(Self:aRecnoAnt)
				lRet 		:= .T.     
				Exit
			EndIf		 
		EndIf
		                       		
	EndIf                                      
	
	DbSelectArea(Self:cTabelaAux)
	DbSkip()	
End     
If lPage
	If !lRet 	  	
		iPage := nActualPg
		Self:aRecnoAnt := aActualPg
	EndIf
	Self:cPagePosBkp 	:= AllTrim(Str(iPage))
	Self:cPagePos 		:= Self:cPagePosBkp + "   "		
Else
	If !lRet
		iPage := nActualPg
		Self:aRecnoAnt := aActualPg		
		Self:cPagePosBkp 	:= AllTrim(Str(iPage))
		Self:cPagePos 		:= Self:cPagePosBkp + "   "	 				
		//chamados recursiva para posicionar a pagina
		Self:posPage(cFieldName, cValue, .T., iPage)
	EndIf
EndIf
 
//Posiciona na pagina correta        
If lRet 	    
	DbSelectArea(Self:cTabelaAux)
	DbGoTop()		      
	If Len(Self:aRecnoAnt) >= iPage
		While 	(Self:cTabelaAux)->(!EOF()) .AND.; 
				Self:aRecnoAnt[iPage] <> (Self:cTabelaAux)->(RecNo()) 				
				
			DbSelectArea(Self:cTabelaAux)
			DbSkip()	
		End                                 
	EndIf
	If (Self:cTabelaAux)->(!EOF())                                           
		Self:Tk510ACols(.F.)
		Self:TkOrder(Self:nOrder,, .F.)  		
	EndIf		            
EndIf
DbSelectArea(Self:cTabelaAux)
DbCloseArea()			
If Self:oTimer <> Nil
	Self:oTimer:Activate()
EndIf
Return lRet
   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณgetMaxRows บAutor ณVendas Clientes     บ Data ณ  12/08/08   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtem o numero de chamados por pagina.                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                
Method getMaxRowsPP() Class HelpDeskListDialog
Local nRet := 10
             
	If Self:MV_PAR11 == 1
		nRet := 10
	ElseIf Self:MV_PAR11 == 2
		nRet := 20
	ElseIf Self:MV_PAR11 == 3
		nRet := 40
	EndIf
Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณsetParameteบAutor ณVendas Clientes     บ Data ณ  12/08/08   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega os parametros em propriedades do Objeto.           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                
Method setParameters() Class HelpDeskListDialog

	Self:MV_PAR01 := MV_PAR01
	Self:MV_PAR02 := MV_PAR02
	Self:MV_PAR03 := MV_PAR03
	Self:MV_PAR04 := MV_PAR04
	Self:MV_PAR05 := MV_PAR05
	Self:MV_PAR06 := MV_PAR06
	Self:MV_PAR07 := MV_PAR07
	Self:MV_PAR08 := MV_PAR08
	Self:MV_PAR09 := MV_PAR09
	Self:MV_PAR10 := MV_PAR10
	Self:MV_PAR11 := MV_PAR11
	Self:MV_PAR12 := MV_PAR12
	

Return Nil                                     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRefresh    บAutor ณVendas Clientes     บ Data ณ  12/08/08   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza a lista de pendencias                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                
Method Refresh() Class HelpDeskListDialog
Local nCodPos 	:= 0   // Indica a posicao do campo ADE_CODIGO
Local cCodLinha := ""  // Indica o numero do chamado que esta posicionado
Local nAt		:= 0   // Variavel utilizada em Loop

If Self:oTimer <> Nil
	Self:oTimer:DeActivate()
EndIf

Self:SelectCall(.T.)	//Desmarca e desbloqueia os chamados.

Self:GetFieldPos("ADE_CODIGO", @nCodPos, Self:aHeaderADE)

If Len(Self:OGETDADOS:aCols)>=Self:OGETDADOS:NAT .AND. Len(Self:OGETDADOS:aCols[Self:OGETDADOS:NAT])>=nCodPos
	cCodLinha := Self:OGETDADOS:aCols[Self:OGETDADOS:NAT,nCodPos]
EndIf

If !Empty(cCodLinha)
	Self:posPage("ADE_CODIGO", cCodLinha)
	For nAt := 1 To Len(Self:aColsADE)
		If Len(Self:aColsADE[nAt])>=nCodPos .AND. cCodLinha == Self:aColsADE[nAt,nCodPos]
	   		Self:OGETDADOS:NAT := nAt
			Self:oGetDados:GoTo(nAt)		   		
	   		Exit		
		EndIf
	Next nAt
Else
	Self:aColsADE 	:= {}
	aCols	:= {}
	Self:TkOrder(Self:nOrder)  		   		
EndIf      
Self:LoadProfile()
Self:LoadIncident()

If Self:oTimer <> Nil
	Self:oTimer:Activate()
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบM้todo    ณ ConfigCols บ Autor ณ Vendas CRM       บ Data ณ  23/04/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Manuten็ใo da ordem das colunas e sua exibi็ใo.            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ConfigCols( nOpc, aParOrder, uPar1 ) Class HelpDeskListDialog
	Local aTempOrder	:= {}		// Ordem dos campos utilizado internamente
	Local nCount		:= 0		// Contador temporแrio
	Local nPos			:= 0		// Posicionador temporแrio
	Local lFirst		:= .F.		// Se ้ a primeira execu็ใo da configura็ใo de colunas
	Local nSpace		:= 0		// Espa็amento entre os componentes exibidos na tela
	Local uRet			:= Nil		// Retorno da fun็ใo (Como ้ utilizada recursivamente, o retorno pode ser variแvel)
	Local oDlg			:= Nil		// Diแlogo principal da configura็ใo de colunas
	Local oPanelALL		:= Nil		// Painel com as colunas	
	Local oPanelBot		:= Nil		// Painel com os bot๕es
	Local oScroll		:= Nil		// Scroll para quando sobrecarregar a tela
	Local uTemp			:= Nil		// Temporแrio diverso 1
	Local uTemp2		:= Nil		// Temporแrio diverso 2
	Local uTemp3		:= Nil		// Temporแrio diverso 3

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se ้ chamada recursiva, pega as colunas do parโmetro,ณ
	//ณse nใo pega as configura็๕es de coluna da classe.             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ValType(aParOrder) == "U"
		For nCount := 1 To Len( Self:aColsOrder )
			aAdd(aTempOrder, {"", Self:aColsOrder[nCount], .T.} )
		Next
		
		If Len(aTempOrder) == 0
			lFirst := .T.
		EndIf
	Else
		aTempOrder := aParOrder
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCada nOpc trata de um comportamento da tela.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ValType(nOpc) == "U" .Or. nOpc == 1
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCompleta com todas as colunas existentes.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea("SX3")
		DbSetOrder( 1 )
		DbSeek( Self:cAliasUser )
		While !Eof() .And. Upper( SX3->X3_ARQUIVO ) == Upper( Self:cAliasUser )
			If cNivel >= SX3->X3_Nivel .And. Upper( SX3->X3_BROWSE ) == "S"		
				If (nPos:=aScan( aTempOrder, {|x| x[2] == X3_CAMPO } )) > 0
					aTempOrder[nPos][1] := X3Titulo()
				Else
					aAdd( aTempOrder, { X3Titulo(), X3_CAMPO, lFirst } )
				EndIf
			EndIf
			SX3->(DbSkip())
		End

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMonta a tela.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DEFINE MSDIALOG oDlg TITLE STR0072 FROM 00,00 TO 300,305 PIXEL	// "Adicionar/Remover Colunas"

		oPanelBot:= tPanel():New(0,0,"",oDlg,,,,,,0,20)
		oPanelBot:Align := CONTROL_ALIGN_BOTTOM
		
		oPanelAll:= tPanel():New(0,0,"",oDlg,,,,,,0,0)
		oPanelAll:Align := CONTROL_ALIGN_ALLCLIENT		
		
		oScroll := TScrollBox():New(oPanelALL,0,0,0,0,.T.,.T.,.T.)
		oScroll:Align := CONTROL_ALIGN_ALLCLIENT		
		
		nSpace := 0
		For nCount := 1 To Len( aTempOrder )
			If nCount != Len( aTempOrder )
				TBtnBmp2():New( 5+nSpace, 5, 26, 26, 'DOWN',,,, &("{||aTempOrder:=Self:ConfigCols(3, @aTempOrder, " + AllTrim(Str(nCount)) + ")}"), oScroll,,, .T. )
			EndIf
			If nCount != 1
				TBtnBmp2():New( 5+nSpace, 36, 26, 26, 'UP',,,, &("{||aTempOrder:=Self:ConfigCols(2, @aTempOrder, " + AllTrim(Str(nCount)) + ")}"), oScroll,,, .T. )
			EndIf			
			TCheckBox():New( 5+(nSpace/2) ,35,"",&("{|x| If(PCount()>0, aTempOrder[" + AllTrim(Str(nCount)) + "][3]:= x,aTempOrder[" + AllTrim(Str(nCount)) + "][3])}"),oScroll,09,09,,,,,,,.F.,.T.,,.F.,)
			TSay():New(6+(nSpace/2),48,&("{|| aTempOrder[" + AllTrim(Str(nCount)) + "][1]}"),oScroll,,,,,,.T.,,,80,20)			
			nSpace += 30			
		Next
		TButton():New(5	,5	,STR0073, oPanelBot, {||aTempOrder:=Self:ConfigCols(4, @aTempOrder)}, 45	, 11,,, .F., .T., .F.,, .F.,,, .F.)	// "Selecionar Todas"
		TButton():New(5	,53	,STR0074, oPanelBot, {||aTempOrder:=Self:ConfigCols(5, @aTempOrder)}, 30	, 11,,, .F., .T., .F.,, .F.,,, .F.)	// "Restaurar"
		TButton():New(5	,86	,STR0075, oPanelBot, {||Self:ConfigCols(6, @aTempOrder), oDlg:End()}, 30, 11,,, .F., .T., .F.,, .F.,,, .F.)	// "Salvar"
		TButton():New(5	,120,STR0076, oPanelBot, {||oDlg:End()}, 30	, 11,,, .F., .T., .F.,, .F.,,, .F.)									// "Cancelar"
		ACTIVATE DIALOG oDlg CENTERED
	ElseIf nOpc == 2 // Swap para cima
		uTemp := aTempOrder[uPar1-1]
		aTempOrder[uPar1-1] := aTempOrder[uPar1]
		aTempOrder[uPar1] := uTemp
		uRet := aTempOrder
	ElseIf nOpc == 3 // Swap para baixo
		uTemp := aTempOrder[uPar1+1]
		aTempOrder[uPar1+1] := aTempOrder[uPar1]
		aTempOrder[uPar1] := uTemp
		uRet := aTempOrder		
	ElseIf nOpc == 4 // Selecionar Todas	
		For nCount := 1 To Len( aTempOrder )
			aTempOrder[nCount, 3] := .T.
		Next
		uRet := aTempOrder
	ElseIf nOpc == 5 // Restaurar
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณPega as colunas por ordem que aparecem no SX3.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aTempOrder := {}
		DbSelectArea("SX3")
		DbSetOrder( 1 )
		DbSeek( Self:cAliasUser )
		While !Eof() .And. Upper( SX3->X3_ARQUIVO ) == Upper( Self:cAliasUser )
			If cNivel >= SX3->X3_Nivel .And. Upper( SX3->X3_BROWSE ) == "S"		
				aAdd( aTempOrder, { X3Titulo(), X3_CAMPO, .T. } )
			EndIf
			SX3->(DbSkip())
		End		
		uRet := aTempOrder
	ElseIf nOpc == 6 // Salvar
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCria a ordem padrใo encontrada no SX3.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		uTemp2 := {}
		DbSelectArea("SX3")
		DbSetOrder( 1 )
		DbSeek( Self:cAliasUser )
		While !Eof() .And. Upper( SX3->X3_ARQUIVO ) == Upper( Self:cAliasUser )
			If cNivel >= SX3->X3_Nivel .And. Upper( SX3->X3_BROWSE ) == "S"		
				aAdd( uTemp2, { X3Titulo(), X3_CAMPO, .T. } )
			EndIf
			SX3->(DbSkip())
		End		

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCompara com a ordem que o usuแrio estแ salvando.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		uTemp3 := .T.
		For nCount := 1 To Len ( aTempOrder )
			If nCount <= Len( uTemp2 ) 
				If	!(	AllTrim(aTempOrder[nCount][1]) == AllTrim(uTemp2[nCount][1]) .And.;
						AllTrim(aTempOrder[nCount][2]) == AllTrim(uTemp2[nCount][2]) .And.;
						aTempOrder[nCount][3] == uTemp2[nCount][3])
					uTemp3 := .F.
					Exit
				EndIf
			EndIf
		End

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se a ordem de exibi็ใo restaurada ้ igual a ordemณ
		//ณselecionada.                                              ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !uTemp3
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณCria a ordem nova.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			uTemp := {}
			If aScan( aTempOrder, {|x| x[2] == "ADE_CODIGO" } ) == 0
				aAdd( uTemp, "ADE_CODIGO" )
			EndIf	
			For nCount := 1 To Len( aTempOrder )
				If aTempOrder[nCount, 3]
					aAdd( uTemp, aTempOrder[nCount,2] )
				EndIf
			Next
			Self:aColsOrder := uTemp
		Else
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณLimpa a ordem, jแ que deve ser utilizada a ordem padrใo.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Self:aColsOrder := {}
		EndIf
		Self:SaveConfig(1)
		Aviso(STR0077, STR0078, {STR0079})	// "Configura็ใo das colunas" "As configura็๕es s๓ entrarใo em vigor ap๓s reiniciar o service desk." "Continuar"
	EndIf		
Return uRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบM้todo    ณ ChangeColsOrder บ Autor ณ Vendas CRM  บ Data ณ  23/04/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ordena o aHeader para a exibi็ใo das colunas de acordo com บฑฑ
ฑฑบ          ณ o configurado.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ChangeColsOrder() Class HelpDeskListDialog
	Local nCount		:= 0	// Contador temporแrio 1
	Local nCount2		:= 0	// Contador temporแrio 2
	Local aNewHeader	:= {}	// aHeader temporแrio ordenado
	Local nPos			:= 0	// Posicionador temporแrio
	
	If ValType(Self:aColsOrder) == "A" .And. Len(Self:aColsOrder) > 0

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณObrigatoriamente o campo ADE_CODIGO deve existir comoณ
		//ณcoluna.                                              ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If aScan( Self:aColsOrder, {|x| x == "ADE_CODIGO" } ) == 0	
			aAdd( Self:aColsOrder, "ADE_CODIGO" )
		EndIf	

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAdiciona os dois primeiros itens padr๕es, que indicam:ณ
		//ณ1 - A sele็ใo da linha;                               ณ
		//ณ2 - A figura com status do item;                      ณ
		//ณ3 - Bitmap de legenda do SLA;                         ณ
		//ณ4 - Percentual transcorrido do SLA;                   ณ
		//ณ5 - Horas restantes para termino do SLA.              ณ
		//ณ6 - A figura com status do Workflow.                  ณ		
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aAdd( aNewHeader, Self:aHeaderADE[1] )
		aAdd( aNewHeader, Self:aHeaderADE[2] )
		aAdd( aNewHeader, Self:aHeaderADE[3] )
		aAdd( aNewHeader, Self:aHeaderADE[4] )
		aAdd( aNewHeader, Self:aHeaderADE[5] )
		aAdd( aNewHeader, Self:aHeaderADE[6] )		

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณPara cada coluna ordenada, adiciona a mesma no aHeader.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For nCount := 1 To Len( Self:aColsOrder )
			nPos := aScan( Self:aHeaderADE, {|x| Upper(AllTrim(x[2])) == Upper(AllTrim(Self:aColsOrder[nCount]))})
			If nPos > 0
				aAdd( aNewHeader, Self:aHeaderADE[nPos] )
			EndIf
		Next
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualiza o aHeader utilizado no service desk para que o ณ
		//ณaCols seja construido baseado nele.                     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Self:aHeaderADE := aClone(aNewHeader)
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบM้todo    ณ SaveConfig บ Autor ณ Vendas CRM       บ Data ณ  23/04/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Salva as configura็๕es de exibi็ใo do service desk.        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method SaveConfig(nOpc) Class HelpDeskListDialog
    Local cCampos	:= ""	// String formatada para a grava็ใo da ordem e exibi็ใo dos campos
    Local nCount	:= 0	// Contador temporแrio

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณQuando a configura็ใo a ser salva for igual a 1 (Configura็ใo das colunas)ณ
	//ณou nใo for especificado.                                                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    If ValType(nOpc) == "U" .Or. nOpc == 1
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCria a string formatada com a ordena็ใo e exibi็ใo dos campos.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	    For nCount := 1 To Len( Self:aColsOrder )
	    	cCampos += Self:aColsOrder[nCount] + If( nCount == Len( Self:aColsOrder ), "", "," )
	    Next
	    	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSalva a configura็ใo no profile do usuแrio.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If FindProfDef(__cUserID + cEmpAnt + cFilAnt, Upper(FunName()), "COLSORDER", Self:cAliasUser)
			WriteProfDef(__cUserID + cEmpAnt + cFilAnt, Upper(FunName()), "COLSORDER", Self:cAliasUser, __cUserID + cEmpAnt + cFilAnt, Upper(FunName()), "COLSORDER", Self:cAliasUser, cCampos)
		Else
			WriteNewProf(__cUserID + cEmpAnt + cFilAnt, Upper(FunName()), "COLSORDER", Self:cAliasUser, cCampos)	
		EndIf
	EndIf
Return
                                                      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบM้todo    ณ LoadConfig บ Autor ณ Vendas CRM       บ Data ณ  23/04/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega as configura็๕es de exibi็ใo do service desk.      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LoadConfig(nOpc) Class HelpDeskListDialog
	Local cCampos	:= ""	// String formatada para a grava็ใo da ordem e exibi็ใo dos campos
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณQuando a configura็ใo a ser carregada for igual a 1 (Configura็ใo das colunas)ณ
	//ณou nใo for especificado.                                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
    If ValType(nOpc) == "U" .Or. nOpc == 1	
    	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCarrega a configura็ใo no profile do usuแrio.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู    	
		If FindProfDef(__cUserID + cEmpAnt + cFilAnt, Upper(FunName()), "COLSORDER", Self:cAliasUser)
			cCampos := RetProfDef(__cUserID + cEmpAnt + cFilAnt, Upper(FunName()), "COLSORDER", Self:cAliasUser)
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza a configura็ใo local.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Self:aColsOrder := StrToKArr( cCampos, "," )
		Else
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza a configura็ใo local.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
			Self:aColsOrder := {}	
		EndIf
	EndIf
Return          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบM้todo    ณ LoadProfileบ Autor ณ Vendas CRM       บ Data ณ  27/05/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega as informacoes do perfil do entidade.              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LoadProfile() Class HelpDeskListDialog  
Local aAreaADE := ADE->(GetArea())
Local nCodPos := 0		// Armazena a posicao do campos ADE_CODIGO
Local cCodLinha := ""	// Armazena o valor do campo ADE_CODIGO
Local cEntidade	:= ""       
Local cCodEnt	:= ""    
Local lSeek		:= .F.	// Indica se encontrou o registro

Self:GetFieldPos("ADE_CODIGO", @nCodPos, Self:aHeaderADE)        
If Len(Self:OGETDADOS:aCols)>=Self:OGETDADOS:NAT .AND. Len(Self:OGETDADOS:aCols[Self:OGETDADOS:NAT])>=nCodPos
	cCodLinha := Self:OGETDADOS:aCols[Self:OGETDADOS:NAT,nCodPos]		
EndIf                                    
DbSelectArea("ADE")
If !Empty(ADE->(IndexKey()))
	ADE->(DbSetOrder(1))
	lSeek := !Empty(cCodLinha) .AND. MsSeek( xFilial("ADE")+cCodLinha )
	If lSeek
		cEntidade 	:= ADE->ADE_ENTIDA
		cCodEnt		:= ADE->ADE_CHAVE		
		Self:setProfile(Tk510PrfDesc(cEntidade, cCodEnt, 2))	 				
	EndIf 
EndIf
RestArea(aAreaADE)
Return Nil      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบM้todo    ณ SetProfile บ Autor ณ Vendas CRM       บ Data ณ  27/05/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibe a informacao de profile da entidade.                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method setProfile(cTexto) Class HelpDeskListDialog              
Self:cCustomProfile := cTexto	
If ValType(Self:oCustomProfile) == "O"
	Self:oCustomProfile:Refresh()
EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบM้todo    ณLoadIncidentบ Autor ณ Vendas CRM       บ Data ณ  23/10/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega as informacoes do incidente                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LoadIncident() Class HelpDeskListDialog  

Local aAreaADE := ADE->(GetArea())
Local nCodPos 	:= 0	// Armazena a posicao do campos ADE_CODIGO
Local cCodLinha := ""	// Armazena o valor do campo ADE_CODIGO

If Self:oTFolder:nOption == 2
	Self:oTFolder:SetOption(1)
EndIf

Self:GetFieldPos("ADE_CODIGO", @nCodPos, Self:aHeaderADE)        
If Len(Self:OGETDADOS:aCols)>=Self:OGETDADOS:NAT .AND. Len(Self:OGETDADOS:aCols[Self:OGETDADOS:NAT])>=nCodPos
	cCodLinha := Self:OGETDADOS:aCols[Self:OGETDADOS:NAT,nCodPos]		
EndIf                                    
DbSelectArea("ADE")
If !Empty(ADE->(IndexKey()))
	ADE->(DbSetOrder(1))
	If !Empty(cCodLinha) .AND. MsSeek( xFilial("ADE")+cCodLinha )
		Self:SetIncident( MSMM( ADE->ADE_CODINC, TamSx3("ADE_INCIDE")[1] ) )
	EndIf 
EndIf
RestArea(aAreaADE)
Return Nil      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบM้todo    ณSetIncident บ Autor ณ Vendas CRM       บ Data ณ  23/10/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibe a informacao de profile da entidade.                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method SetIncident(cTexto) Class HelpDeskListDialog              
Self:cIncident := cTexto	
If ValType(Self:oIncident) == "O"
	Self:oIncident:Refresh()
EndIf
Return Nil 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบM้todo    ณLoadDetalhesบ Autor ณ Vendas CRM       บ Data ณ  20/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega as informacoes do detalhe do chamado               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LoadDetalhes() Class HelpDeskListDialog

Local aAreaADE  := ADE->(GetArea())
Local nCodPos 	:= 0   				// Armazena a posicao do campos ADE_CODIGO
Local cCodLinha := ""				// Armazena o valor do campo ADE_CODIGO
Local cString	:= ""				// Codigo HTML
Local cMemo		:= ""				// Informacoes do MEMO
Local nCount  	:= 1				// Contador 
Local cNomeOper	:= ""
Local nCodAn    := 0

Local nCntMemo   := 0
Local nLinhas    := 0
Local cMemoAux	 := ""

Self:GetFieldPos("ADE_CODIGO", @nCodPos, Self:aHeaderADE)
If Len(Self:OGETDADOS:aCols)>=Self:OGETDADOS:NAT .AND. Len(Self:OGETDADOS:aCols[Self:OGETDADOS:NAT])>=nCodPos
	cCodLinha := Self:OGETDADOS:aCols[Self:OGETDADOS:NAT,nCodPos]
EndIf

Self:GetFieldPos("ADE_NMOPER", @nCodAn, Self:aHeaderADE)
If Len(Self:OGETDADOS:aCols)>=Self:OGETDADOS:NAT .AND. Len(Self:OGETDADOS:aCols[Self:OGETDADOS:NAT])>=nCodAn
	cNomeOper := Self:OGETDADOS:aCols[Self:OGETDADOS:NAT,nCodAn]
EndIf

DbSelectArea("ADF")
If !Empty(ADF->(IndexKey()))
	ADF->(DbSetOrder(1))
	If !Empty(cCodLinha) .AND. MsSeek( xFilial("ADF")+cCodLinha )
		cString += '<table width="100%" border="0" cellpadding="2" cellspacing="2">'
		While ADF->(!EOF() .AND. ADF_FILIAL+ADF_CODIGO == xFilial("ADF")+cCodLinha)

			cMemoAux := ""

			cMemo := Alltrim(MSMM( ADF->ADF_CODOBS, TamSx3("ADF_OBS")[1] ))

			nLinhas := MlCount(cMemo,30) 
			
			For nCntMemo := 1 To nLinhas 
				cMemoAux += MemoLine(cMemo,30,nCntMemo)+Chr(13)+Chr(10)  		
			Next nCntMemo 			

			If (nCount % 2) <> 0
				cString += "<tr>"
			EndIf
				
			cString += '<td width="50%">'
			cString += "<h3> <b> <font color=red>"+STR0188+ADF->ADF_ITEM+"</font></b></h3>"
			cString += "<b> <font color=black size=3>"+STR0189+"</b></font>"+ADF->ADF_CODSU9+" - "+Upper(POSICIONE("SU9",2,xFilial("SU9")+ADF->ADF_CODSU9,"U9_DESC"))+"<br>"
			cString += "<b> <font color=black size=3>"+STR0190+"</b></font>"+ADF->ADF_CODSUQ+" - "+Upper(POSICIONE("SUQ",1,xFilial("SUQ")+ADF->ADF_CODSUQ,"UQ_DESC"))+"<br>"
			cString += "<b> <font color=black size=3>"+STR0191+"</b></font>"+ADF->ADF_CODSU7+" - " +FATPDObfuscate(cNomeOper, "ADE_NMOPER", /*cSource*/, .T.)+"<br>"
			cString += "<b> <font color=black size=3>"+STR0192+"</b></font>"+ADF->ADF_CODSU0+" - "+POSICIONE("SU0",1,xFilial("SU0")+ADF->ADF_CODSU0,"U0_NOME")+"<br>"
			cString += "<b> <font color=black size=3>"+STR0193+"</b></font>"+DTOC(ADF->ADF_DATA)+" | "+"<b> <font color=black size=3>"+STR0194+"</b></font>"+ADF->ADF_HORA+" | "
			cString += "<b> <font color=black size=3>"+STR0195+"</b></font>"+ADF->ADF_HORAF+"<br>"
			cString += "<b> <font color=black size=3>"+STR0196+"</b></font>"+If(!Empty(cMemoAux),cMemoAux,STR0197)+"<br>"	
			cString += '</td>'
			
			If (nCount % 2) == 0
				cString += "</tr>"
			EndIf
			
			nCount++
			
			ADF->(DbSkip())
		End
		cString += "</table>"
		Self:SetDetalhes(cString)
	EndIf
	
EndIf
RestArea(aAreaADE)

Return Nil   
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบM้todo    ณSetDetalhes บ Autor ณ Vendas CRM       บ Data ณ  20/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibe as interacoes do chamado no objeto TSimpleEditor	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/             

Method SetDetalhes(cTexto) Class HelpDeskListDialog

If ValType(Self:oTEdit) == "O"
	Self:oTEdit:Load(cTexto)
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบM้todo    ณ   Associar   บ Autor ณ Vendas CRM       บ Data ณ  01/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de associacao de N chamados ao chamado POSICIONADO      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Associar() Class HelpDeskListDialog      

Local aArea			:= GetArea()
Local aAreaADE	 	:= ADE->(GetArea())
Local iCols      	:= 0
Local lSelItem   	:= .F. 
Local lOpenMsg  	:= .F.
Local nPosCodigo 	:= AScan(Self:oGetDados:aHeader,{|x| AllTrim(x[2]) == "ADE_CODIGO" })  
Local nPosAssoc  	:= AScan(Self:oGetDados:aHeader,{|x| AllTrim(x[2]) == "ADE_CHANEX" })  
Local cCodLinha  	:= Self:oGetDados:aCols[Self:oGetDados:nAt][nPosCodigo]
Local aClicados  	:= {}
Local oDlgObs    	:= Nil   
Local oObsMemo   	:= Nil  
Local cObsMemo   	:= ""
Local cChNaoGrav 	:= ""
Local aCoordenadas	:= MsAdvSize(.T.) 
Local lTKACALOTE	:= ExistBlock("TKACLOTE")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida se houve marcacao de outras linhas (chamados)ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For iCols := 1 To Len(Self:oGetDados:aCols)
	If Self:oGetDados:aCols[iCols][1] == "LBOK"
		If Self:oGetDados:aCols[iCols][nPosCodigo] <> cCodLinha
			lSelItem := .T. 
			AAdd(aClicados,Self:oGetDados:aCols[iCols][nPosCodigo])
		Else
			Self:oGetDados:aCols[iCols][1] := "LBNO"
			TK510UsrLock("U", Self:oGetDados:aCols[iCols][nPosCodigo], TkOperador())
		EndIf
	EndIf
Next iCols 

If lSelItem 
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPonto de entrada para validar a acao em loteณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lTKACALOTE  
		lRet := ExecBlock("TKACLOTE",.F.,.F.,{aClicados,cCodLinha,5})
		If ValType(lRet) == "L" .AND. !lRet
			Return lRet
		EndIf
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณValida se o chamado posicionado nao esta associado a nenhum outroณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Tk510VldAss(cCodLinha)
		                      
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณValida se algum chamado associado possui data inferior a um chamado com FNCณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		ADE->(dbSetOrder(1))
		ADE->(MsSeek(xFilial("ADE")+cCodLinha))
		
		Self:oObj:lAssociating := .T.
		
		If MsgYesNo(STR0082 + AllTrim(cCodLinha),STR0083)

			//Abre a tela para digitacao das Observacoes na linha de historico da associacao nos chamados filho
			oDlgObs := TDialog():New(aCoordenadas[7],000,aCoordenadas[6]/2,aCoordenadas[5]/2,STR0148,,,,,,,,oMainWnd,.T.)//"Observa็๕es aos Chamados"
				TGroup():New( 005,005,oDlgObs:nClientHeight/2-35,oDlgObs:nClientWidth/2-7,STR0149,oDlgObs,,,.T.,.F. ) //"Informe a observa็ใo a ser gravada nos chamados filho desse chamado"
				oObsMemo:= TMultiGet():New(015,007,{|u|if(Pcount()>0,cObsMemo:=u,cObsMemo)},oDlgObs,oDlgObs:nClientWidth/2-20,oDlgObs:nClientHeight/2-55,,,,,,.T.)
				oObsMemo:lWordWrap := .T.
	
			    DEFINE SBUTTON FROM oDlgObs:nClientHeight/2-30,005 TYPE 1 ENABLE OF oDlgObs ACTION (oDlgObs:End())
			    DEFINE SBUTTON FROM oDlgObs:nClientHeight/2-30,040 TYPE 2 ENABLE OF oDlgObs ACTION (oDlgObs:End())
			oDlgObs:Activate(,,,.T.)
			
			For iCols := 1 To Len(aClicados)
				If cCodLinha <> aClicados[iCols]
					dbSelectArea("ADE")
					ADE->(dbSetOrder(1))
					If ADE->(MsSeek(xFilial("ADE")+aClicados[iCols]))

						//Verifica se o chamado estแ bloqueado, caso contrแrio faz o bloqueio.
						If TK510UsrLock("L", aClicados[iCols], TkOperador(), .F.)

							ADE->(RecLock("ADE",.F.))
							REPLACE ADE->ADE_CHANEX	WITH cCodLinha
							REPLACE ADE->ADE_STATUS WITH "2"
							REPLACE ADE->ADE_FLCHAN	WITH cFilAnt
							
							ADE->(MsUnlock())				
							
							TkUpdCall(	/*cFil */,;
										""/*cCodAction */,;
										/*cCodReview */,;	
										STR0087 + cCodLinha  + CRLF +  STR0088 + Iif(!Empty(cObsMemo), CRLF + STR0150 + Chr(13) + Chr(10) + AllTrim(cObsMemo) ,"") ,; // "Associado ao chamado :" # "Status do chamado alterado para 2=Pendente." ###"Observa็๕es: "
										/*cTPACAO */,;	
										TkOperador(),;	
										Posicione("SU7", 1, xFilial("SU7")+TkOperador(), "U7_POSTO"),;		
										"",;
										/*dPrazo */,;		
										If(!IsInCallStack("GenRecurrence"), Date(), dDatabase ),;		
										aClicados[iCols],;
										"TMK002")				
							If nPosAssoc > 0 .AND. nPosCodigo > 0						
								Self:oGetDados:aCols[AScan(Self:oGetDados:aCols,{|x| x[nPosCodigo] == aClicados[iCols] })][nPosAssoc] := cCodLinha
							EndIf
						
							//Desbloqueia o chamado
							TK510UsrLock("U", aClicados[iCols], TkOperador())
													
						Else
				 			cChNaoGrav += STR0172 + ": " + ADE->ADE_CODIGO + " - " + STR0015 + ": " + ADE->ADE_OPEUSO + " - " + AllTrim(Posicione("SU7",1,xFilial("SU7")+ADE->ADE_OPEUSO,"U7_NOME")) + CRLF
			            	lOpenMsg := .T.												
						EndIf						
					EndIf
				EndIf				
			Next iCols 

			If lOpenMsg
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Lista os chamados que nใo foram processados. ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				Tk510WindLog(cChNaoGrav)
			EndIf			

		EndIf
	
	Else
		Self:oObj:lAssociating := .F.
		
	EndIf
	
Else
	MsgAlert(STR0084 + AllTrim(cCodLinha) + STR0085)
EndIf

RestArea(aAreaADE)
RestArea(aArea)

Return (Self:oObj:lAssociating)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMKA510A  บAutor  ณVendas Clientes     บ Data ณ  18/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que cria o objeto da tela                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TMKA510A()

Private oTk510Tela
Private aRecList   := {}	// vetor de recursos adicionais utilizada na funcao QAlocPMS no fonte QNCXFUN

oTk510Tela 	:= HelpDeskListDialog():New()

oTk510Tela:Tk510Tela()
	
TMKFree( oTk510Tela )
	
Return( Nil )	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณLoadFilterบAutor  ณVendas CRM          บ Data ณ  29/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega filtros salvos para o usuario na tabela ADP         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LoadFilter() Class HelpDeskListDialog

Local aFiltros	:= {{},{},{}}
Local cFilADP	:= xFilial("ADP")

AAdd(aFiltros[1],STR0101) //"Visualizar todos os registros"
AAdd(aFiltros[2],"")
AAdd(aFiltros[3],0)
	
DbSelectArea("ADP")
DbSetOrder(1) //ADP_FILIAL+ADP_CODUSR+ADP_ROTINA+ADP_NOMFIL
MsSeek(cFilADP+__cUserId+"TMKA510A")

While !ADP->(Eof()) 				.AND.;
	ADP->ADP_FILIAL == cFilADP 		.AND.;
	ADP->ADP_CODUSR == __cUserId	.AND.;
	AllTrim(ADP->ADP_ROTINA) == "TMKA510A"

	AAdd(aFiltros[1],ADP->ADP_NOMFIL)
	AAdd(aFiltros[2],ADP->ADP_EXPR)	
	AAdd(aFiltros[3],ADP->(Recno()))	
	ADP->(DbSkip())

End


Return aFiltros

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณAddFilter บAutor  ณVendas CRM          บ Data ณ  29/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAdiciona um filtro ao combo de filtros do usuario           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method AddFilter(oComboFil,aFiltros) Class HelpDeskListDialog

Local cFiltro	:= ""
Local cDescFil	:= ""
Local lRet		:= .F.

cFiltro := BuildExpr("ADE")

If !Empty(cFiltro)
	
	lRet 	:= .T.

	While Empty(cDescFil) .AND. lRet
		cDescFil:= Tk510Prompt(STR0094,STR0028)//"Informe uma descri็ใo para o filtro criado"###"Filtro"
		If Empty(cDescFil)
			lRet := !MsgNoYes(STR0095) //"Aborta a edi็ใo do filtro?"
		EndIf
		If !lRet
			Return lRet
		EndIf
	End
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAdiciona a descri็ใo do filtro e o filtro na comboณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	AAdd(aFiltros[1],cDescFil)
	AAdd(aFiltros[2],cFiltro)
	AAdd(aFiltros[3],0)
	
	If MsgYesNo(STR0096) //"Deseja salvar este filtro para uso posterior?"
	   	If Len(cFiltro) <= 250
			RecLock("ADP",.T.)
			ADP->ADP_FILIAL	:= xFilial("ADP")
			ADP->ADP_CODUSR	:= __cUserID
			ADP->ADP_ROTINA	:= "TMKA510A"
			ADP->ADP_EXPR	:= cFiltro
			ADP->ADP_NOMFIL	:= cDescFil
			MsUnLock()

			aFiltros[3][Len(aFiltros[3])] := ADP->(Recno())// Como vai salvar, pego o Recno para o registro na tabela.	
		
        Else
        	MsgAlert(STR0182) //"A expressใo do filtro nใo pode ter mais de 250 caracteres."   
		End If

	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSeleciona o filtro recem incluidoณ 
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oComboFil:SetItems(aFiltros[1])
	oComboFil:Select(Len(aFiltros[1]))
	Self:cFilter := aFiltros[2][oComboFil:nAt]
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณEditFilterบAutor  ณVendas CRM          บ Data ณ  29/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEdita o filtro selecionado no combo de filtros do usuario   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method EditFilter(oComboFil,aFiltros) Class HelpDeskListDialog

Local nFiltro	:= oComboFil:nAt  //Posi็ใo do filtro na combo
Local cDescFil	:= AllTrim(aFiltros[1][nFiltro])
Local cFiltro	:= AllTrim(aFiltros[2][nFiltro])
Local nRecFil	:= aFiltros[3][nFiltro]
Local lRet		:= .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณO usuario nao pode alterar o filtro 1 (todos os registros)ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nFiltro == 1
	MsgInfo(STR0097) //"Nใo ้ permitido alterar este filtro"
	lRet := .F. 
Else
	While lRet
		cFiltro := BuildExpr("ADE",,cFiltro)
		If Len( cFiltro ) > 250
			MsgAlert(STR0182) //"A expressใo do filtro nใo pode ter mais de 250 caracteres."	
			lRet := !MsgNoYes(STR0095) //"Aborta a edi็ใo do filtro?"
		Else
			Exit
		Endif
	Enddo	
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso o filtro tenha sido alterado, salva alteracao no banco de dadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet .and. !Empty(cFiltro) .and. !(cFiltro == aFiltros[2][nFiltro])

	While lRet
		cDescFil:= Tk510Prompt(STR0098,STR0028,cDescFil) //"Informe uma descri็ใo para o filtro alterado"###"Filtro"
		If Empty(cDescFil) .and. MsgNoYes(STR0095) //"Aborta a edi็ใo do filtro?"
			lRet := .F.
		Else
			Exit
		EndIf   
	End	

	If lRet
		If nRecFil > 0
			ADP->(DbGoTo(nRecFil))
			RecLock("ADP",.F.)
			ADP->ADP_EXPR	:= cFiltro
			ADP->ADP_NOMFIL	:= cDescFil
			MsUnLock()
		ElseIf MsgYesNo(STR0096) //"Deseja salvar este filtro para uso posterior?"
			RecLock("ADP",.T.)
			ADP->ADP_FILIAL	:= xFilial("ADP")
			ADP->ADP_CODUSR	:= __cUserID
			ADP->ADP_ROTINA	:= "TMKA510A"
			ADP->ADP_EXPR	:= cFiltro
			ADP->ADP_NOMFIL	:= cDescFil
			MsUnLock()
			nRecFil := ADP->(Recno())
			aFiltros[3][nFiltro] := nRecFil
		EndIf

		aFiltros[1][nFiltro] := cDescFil
		aFiltros[2][nFiltro] := cFiltro


		oComboFil:Select(Len(aFiltros[1]))
		oComboFil:SetItems(aFiltros[1])
		oComboFil:nAt := 1	// Forca a alteracao de valor. (Ocorreria falha de posicionamento no ultimo elemento).
		oComboFil:nAt := nFiltro
		Self:cFilter := aFiltros[2][nFiltro]
			
		
	End If    
	
ElseIf lRet .and. Empty(cFiltro)
	
	lRet := Self:DelFilter(@oComboFil,@aFiltros)

EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณEditFilterบAutor  ณVendas CRM          บ Data ณ  30/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRemove o filtro selecionado no combo de filtros do usuario  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method DelFilter(oComboFil,aFiltros) Class HelpDeskListDialog

Local lExecuta	:= .F.
Local nFiltro	:= oComboFil:nAt
Local nRecFil	:= aFiltros[3][nFiltro]

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณO usuario nao pode alterar o filtro 1 (todos os registros)ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nFiltro == 1
	MsgInfo(STR0099) //"Nใo ้ permitido excluir este filtro"
	Return lExecuta
EndIf

If MsgNoYes(STR0100) //"Confirma a exclusใo deste filtro?"
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe o filtro foi salvo anteriormente, exclui o registroณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nRecFil > 0
		ADP->(DbGoTo(nRecFil))
		RecLock("ADP",.F.)
		DbDelete()
		MsUnLock()
	EndIf

	aDel(aFiltros[1],nFiltro)
	aSize(aFiltros[1],Len(aFiltros[1])-1)

	aDel(aFiltros[2],nFiltro)
	aSize(aFiltros[2],Len(aFiltros[2])-1)

	aDel(aFiltros[3],nFiltro)
	aSize(aFiltros[3],Len(aFiltros[3])-1)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSeleciona a primeira opcao do filtro (todos os registros)ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oComboFil:SetItems(aFiltros[1])
	oComboFil:Select(1) 
	
	Self:cFilter := aFiltros[2][1]
	lExecuta := .T.
	
EndIf

Return lExecuta

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณSelectCallบAutor  ณVendas CRM          บ Data ณ  05/10/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca/Desmarca todos os chamados da tela de help desk       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method SelectCall(lUnLock) Class HelpDeskListDialog

Local nX		:= 0
Local nPosSel	:= aScan(Self:oGetDados:aHeader,{|x|AllTrim(x[2])=="CHECKBOX"})
Local nPosCod	:= aScan(Self:oGetDados:aHeader,{|x|AllTrim(x[2])=="ADE_CODIGO"})

DEFAULT lUnLock := .F.		//Destravar os registros marcados

ADE->(dbSetOrder(1))

For nX := 1 to Len(Self:oGetDados:aCols)
	If !lUnLock
		ADE->(dbSeek(xFilial("ADE")+Self:oGetDados:aCols[nX][nPosCod]))
		If Self:lSelectAll 
			If TK510UsrLock("L", ADE->ADE_CODIGO, TkOperador(), .F.)
				Self:oGetDados:aCols[nX][nPosSel] := "LBOK"
			EndIf
		Else
			TK510UsrLock("U", ADE->ADE_CODIGO, TkOperador(), .F.)
			Self:oGetDados:aCols[nX][nPosSel] := "LBNO"
		EndIf    
	Else
	    //Se estiver marcado, destrava o registro.
	    If Self:oGetDados:aCols[nX][nPosSel] == "LBOK"
			If ADE->(dbSeek(xFilial("ADE")+Self:oGetDados:aCols[nX][nPosCod]))	    
        		TK510UsrLock("U", ADE->ADE_CODIGO, TkOperador(), .F.)
   			EndIf
        EndIf
	EndIf
Next nX

Self:oGetDados:Refresh()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณShortcut  บAutor  ณVendas CRM          บ Data ณ  08/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta a lista de atalhos para cada botao do service desk    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpN1 - Numero do botao para consulta do atalho             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Shortcut(nBotao) Class HelpDeskListDialog

Local aRet	:= Array(2)
Local aAtUsr:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณObtem a definicao do usuario, caso a tecla padrao tenha sido modificadaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If TkAtalUsr(nBotao,@aAtUsr,"TMKA510A")
	Return aAtUsr
EndIf

Do Case

	//Incluir
	Case nBotao == 1
		aRet[1] := K_CTRL_I
		aRet[2] := "CTRL+I"

	//Alterar
	Case nBotao == 2
		aRet[1] := K_CTRL_A
		aRet[2] := "CTRL+A"

	//Visualizar
	Case nBotao == 3
		aRet[1] := K_CTRL_U
		aRet[2] := "CTRL+U"

	//Parametros
	Case nBotao == 4
		aRet[1] := K_CTRL_P
		aRet[2] := "CTRL+P"

	//Chamados
	Case nBotao == 5
		aRet[1] := K_CTRL_M
		aRet[2] := "CTRL+M"

	//Distribuir
	Case nBotao == 6
		aRet[1] := K_CTRL_D
		aRet[2] := "CTRL+D"
		
	//Associar
	Case nBotao == 7
		aRet[1] := K_CTRL_O
		aRet[2] := "CTRL+O"

	//Transferir
	Case nBotao == 8
		aRet[1] := K_CTRL_T
		aRet[2] := "CTRL+T"

	//Legendas
	Case nBotao == 9
		aRet[1] := K_CTRL_L
		aRet[2] := "CTRL+L"

	//Pesquisa
	Case nBotao == 10
		aRet[1] := K_CTRL_S
		aRet[2] := "CTRL+S"
		
	//Historico
	Case nBotao == 11
		aRet[1] := K_CTRL_H
		aRet[2] := "CTRL+H"

	//Atualiza
	Case nBotao == 12
		aRet[1] := VK_F5
		aRet[2] := "F5"
	
	//Configuracoes
	Case nBotao == 13
		aRet[1] := K_CTRL_G
		aRet[2] := "CTRL+G"
	
	//Transferir
	Case nBotao == 14
		aRet[1] := K_CTRL_R
		aRet[2] := "CTRL+R"

	//Encerrar
	Case nBotao == 15
		aRet[1] := K_CTRL_E
		aRet[2] := "CTRL+E"

	//Assumir
	Case nBotao == 16
		aRet[1] := K_CTRL_Q
		aRet[2] := "CTRL+Q" 
	
	//Duplicar
	Case nBotao == 17
		aRet[1] := 0
		aRet[2] := ""

   	//Recorrencia
	Case nBotao == 18
		aRet[1] := 0
		aRet[2] := ""
		
EndCase

aRet[2] := "("+aRet[2]+")"

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณDuplicate บAutor  ณVendas CRM          บ Data ณ  16/06/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDuplica o chamado selecionado na tela do service desk       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Duplicate() Class HelpDeskListDialog

Local nX		:= 0
Local nPosSel	:= aScan(Self:oGetDados:aHeader,{|x|AllTrim(x[2])=="CHECKBOX"})
Local nPosCodigo:= aScan(Self:oGetDados:aHeader,{|x|AllTrim(x[2])=="ADE_CODIGO"})  
Local nSelected	:= 0
Local lRet		:= .T.
Local aCab		:= {}
Local aItens	:= {}

If FATPDUserAcc()

	For nX := 1 to Len(Self:oGetDados:aCols)
		If Self:oGetDados:aCols[nX][nPosSel] == "LBOK"
			If nSelected == 0
				nSelected	:= nX
			Else    
				MsgInfo(STR0159) //"Selecione apenas um chamado para realizar a c๓pia"
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next nX  

	If lRet .AND. nSelected == 0
		lRet := .F.
		MsgInfo(STR0160) //"Selecione um chamado para realizar a c๓pia"
	EndIf

	If lRet
		If Tk510Copia(Self:oGetDados:aCols[nSelected][nPosCodigo],@aCab,@aItens) 
			lRet := TK503AOpc("ADE", 0, 3,, {aCab,aItens})
		Else
			lRet := .F.
		EndIf	
	EndIf
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk510PromptบAutor  ณVendas CRM         บ Data ณ  29/09/09   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela para apresentar uma pergunta ao usuario, retornando o  บฑฑ
ฑฑบ          ณtexto respondido.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Pergunta exibida ao usuario                         บฑฑ
ฑฑบ          ณExpC2 - Titulo da tela                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk510Prompt(cQuestion,cTitle,cNome)
 
Local cGet  
Local oGet
Local oDlg
Local oFont
 
Default cTitle 		:= "TOTVS"
Default cGet		:= ""

cGet  := ALLTRIM(cNome) + REPLICATE(' ',256 - LEN(ALLTRIM(cNome)))

oFont := TFont():New("Tahoma",0,16)
 
DEFINE MSDIALOG oDlg TITLE cTitle FROM 0,0 TO 113,370 PIXEL

@ 002,002 TO 028,184 PIXEL OF oDlg
@ 005,005 SAY cQuestion SIZE 267,027 PIXEL OF oDlg COLOR CLR_RED FONT oFont
@ 030,003 MSGET oGet VAR cGet SIZE 181,009 PIXEL OF oDlg
 
DEFINE SBUTTON FROM 045,155 TYPE 1 ENABLE OF oDlg Action(oDlg:End())
 
ACTIVATE MSDIALOG oDlg CENTERED 
 
Return cGet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัอออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณTk510LegendRedบAutor  ณVendas CRM       บ Data ณ  19/10/09  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯอออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para retornar se o SLA estแ ultrapassado (legenda   บฑฑ
ฑฑบ          ณ vermelha), considerando as pausas do SLA.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ										                      บฑฑ
ฑฑบ          ณ						                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk510LegendRed()

Local cQuery   	:= ""	
Local cAliasSK5 := GetNextAlias()
Local cSLAList 	:= ""
Local dDtEncer 	:= STOD("  /  /  ")
Local cHrEncer 	:= "" 
Local dDataSLA	:= ADE->ADE_DTEXPI
Local cHoraSLA	:= ADE->ADE_HREXPI
Local lRet		:= .F.

dbSelectArea("SK5") 
dbSetOrder(1)
If !Empty(ADE->ADE_REGSLA) .AND. dbSeek(xFilial("SK5")+ADE->ADE_REGSLA)						
	cSLAList := "'" + ADE->ADE_REGSLA + "'"						
	While !Empty(SK5->K5_CODANT)                                                        
		If dbSeek(xFilial("SK5")+SK5->K5_CODANT)															
			cSLAList += ",'" + SK5->K5_CODIGO + "'"
		Else
			Exit
		EndIf					   						
	EndDo					
EndIf   

If !Empty(cSLAList)
	cQuery := "SELECT * " 
	cQuery += "FROM " + RetSQLName("SK5") + " SK5 "		
	cQuery += "WHERE SK5.K5_FILIAL = '" + xFilial("SK5") + "' AND "
	cQuery += "SK5.K5_CODIGO IN(" + cSLAList + ") " 
	cQuery += " AND SK5.D_E_L_E_T_ = ' ' "

	cQuery += "ORDER BY K5_CODIGO, K5_ITEM "
	
	cQuery	:= ChangeQuery(cQuery) 
						
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSK5, .F., .T.)			
	TCSetField(cAliasSK5, "K5_DTENCER"	, "D") 
	TCSetField(cAliasSK5, "K5_DTATUA"	, "D")
	TCSetField(cAliasSK5, "K5_PAUSED"	, "L")

	While (cAliasSK5)->(!Eof()) 	
		If (!(cAliasSK5)->K5_PAUSED) .And. ((cAliasSK5)->K5_STATUS == '2')							                         	                         	 
			dDtEncer := (cAliasSK5)->K5_DTENCER   
			cHrEncer := (cAliasSK5)->K5_HRENCER 
		ElseIf ((cAliasSK5)->K5_STATUS <> '2')
			dDtEncer := STOD("  /  /  ")
			cHrEncer := ""
		EndIf
		(cAliasSK5)->(dbSkip()) 
	EndDo                            
	If ( Select(cAliasSK5) > 0 )
		(cAliasSK5)->(dbCloseArea())
	EndIf
	If Empty(dDtEncer)               
		If !Empty(dDataSLA)
			If (SK5->K5_STATUS <> "2") .Or. (!SK5->K5_PAUSED)
				If dDataSLA > If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
					lRet := .F.
				ElseIf dDataSLA < If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
					lRet := .T.	
				ElseIf dDataSLA == If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
					If cHoraSLA != Nil
						If cHoraSLA >= Time()
							lRet := .F.
						Else
							lRet := .T.
						EndIf
					EndIf
				EndIf         
			Else
	            If !Empty(SK5->K5_DTATUA)
					If dDataSLA > SK5->K5_DTATUA
						lRet := .F.
					ElseIf dDataSLA < SK5->K5_DTATUA
						lRet := .T.  	
					ElseIf dDataSLA == SK5->K5_DTATUA
						If cHoraSLA != Nil
							If cHoraSLA >= SK5->K5_HRATUA
								lRet := .F.
							Else
								lRet := .T.
							EndIf
						EndIf
					EndIf
	            Else
	            	lRet := .F.
	            EndIf
			EndIf
	    Else 
	    	lRet := .F.
	    EndIf
	Else 
		If dDataSLA > dDtEncer		
			lRet := .F.
		ElseIf  dDataSLA > dDtEncer		
			lRet := .T.			  			
		ElseIf dDataSLA == dDtEncer
			If cHoraSLA != Nil
				If cHoraSLA >= cHrEncer
					lRet := .F.
				Else
					lRet := .T.
				EndIf
			EndIf
		EndIf
	EndIf  
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetSlaStatusบAutor  ณVendas CRM        บ Data ณ  07/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o Status do SLA para o contrato passado             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function RetSlaStatus(cSLANumber,nHrUtilSLA,nFatorProp,cFilPai)

Local aArea		:= GetArea()
Local aAreaSK5	:= SK5->(GetArea())
Local nSlaTot	:= 0
Local nSlaHoje	:= 0
Local nTotPausa	:= 0
Local oIniSla	:= Nil
Local oFimSla	:= Nil
Local oSlaHoje	:= Nil
Local lOk		:= .F.
Local cFilBKP   := cFilAnt

Local lLegSla	:= SuperGetMV("MV_TKLGSLA",,.F.) //Se serแ considerado as horas do turno de trabalho nos cแlculos dos status do SLA
Local oSLARegist:= Nil
Local cTimeShift:= ""
Local lTurno	:= .F.

Default cFilPai	   := ""

If !Empty(cFilPai)
	cFilAnt := cFilPai
EndIf

DbSelectArea("SK5")
DbSetOrder(1)

If MsSeek(xFilial("SK5")+cSLANumber) .AND. (!SK5->K5_PAUSED)

	oIniSla := TMKDateTime():This(SK5->K5_DATA,SK5->K5_HORA)
	oFimSla := TMKDateTime():This(SK5->K5_DTEXPIR,SK5->K5_HREXPIR)
	oSlaHoje:= TMKDateTime():This(dDataBase,Time())

	If lLegSla
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Busca o turno de trabalho no grupo de atendimento. ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !Empty(ADE->ADE_GRUPO)
			DbSelectArea("SU0")
			DbSetOrder(1) 
			If DbSeek(xFilial("SU0")+ADE->ADE_GRUPO)
				If !Empty(SU0->U0_TURNO)
					cTimeShift 	:= SU0->U0_TURNO
				EndIf		
			EndIf
		EndIf         
		
		oSLARegist := SLARegister():New()
		
		If oSLARegist:load(ADE->ADE_REGSLA)
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Busca o turno de trabalho no contrato de SLA.      ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If cTimeShift == Nil .Or. Empty(cTimeShift)
			 	cTimeShift := oSLARegist:getTimeShift(oSLARegist:SlaFound)	
			EndIf		
			If !Empty(cTimeShift)
				nTotPausa	:= SK5->K5_PAUSEDT
				DbSelectArea("SK9")
				DbSetOrder(1)	//K9_SEVE + K9_CODSLA
				DbSeek(xFilial("SK9")+Padr(oSLARegist:severityCode,TamSX3("K9_SEVE")[1])+oSLARegist:SlaFound)
				nSlaTot		:= SK9->K9_HREXPIR
				nSlaHoje	:= (oSLARegist:getTimeElapsed(oIniSla,oSlaHoje,cTimeShift) - nTotPausa)
				nHrUtilSLA	:= (nSlaTot - nSlaHoje)
				nFatorProp	:= (nSlaHoje/nSlaTot) * 100
				lOk			:= .T.
				lTurno		:= .T.
			EndIf
		EndIf 
		If !lTurno
			nSlaTot		:= oFimSla:diffInHours(oIniSla)
			nSlaHoje	:= oSlaHoje:diffInHours(oIniSla,.F.)
			nHrUtilSLA	:= oFimSla:diffInHours(oSlaHoje,.F.)
			nFatorProp	:= (nSlaHoje/nSlaTot) * 100
			lOk			:= .T.
		EndIf
	Else
		nSlaTot		:= oFimSla:diffInHours(oIniSla)
		nSlaHoje	:= oSlaHoje:diffInHours(oIniSla,.F.)
		nHrUtilSLA	:= oFimSla:diffInHours(oSlaHoje,.F.)
		nFatorProp	:= (nSlaHoje/nSlaTot) * 100
		lOk			:= .T.
	EndIf
EndIf

If !Empty(cFilPai)
	cFilAnt := cFilBKP
EndIf

RestArea(aAreaSK5)
RestArea(aArea)

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBrwLegendaบAutor  ณVendas CRM          บ Data ณ  09/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibicao de legendas especifica, para exibir 2 tipos de     บฑฑ
ฑฑบ          ณlegendas na mesma tela                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BrwLegenda(cTitulo,aLegendas)

Local nY       				:= 0
Local nX       				:= 0
Local nZ       				:= 0
Local nGrupo				:= 0
Local nSizeAdic				:= 5
Local nQtdLegs				:= 0
Local nLinha				:= 0
Local aBmp
Local oDlgLeg               

For nX := 1 to Len(aLegendas)
	nQtdLegs := Len(aLegendas[nX][2])
	nSizeAdic += 50 + (nQtdLegs * 20)
Next nX

DEFINE MSDIALOG oDlgLeg FROM 0,0 TO nSizeAdic + 10,320 TITLE cTitulo OF oMainWnd PIXEL

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณNo onclick do usuario a tela sera fechadaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oDlgLeg:bLClicked:= {||oDlgLeg:End()}
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFonte especifico para a descricao das legendasณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDesenho de fundoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	@ 0, 0 BITMAP RESNAME "PROJETOAP" OF oDlgLeg SIZE 35,155 NOBORDER WHEN .F. PIXEL
	
	nLinha := 3

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTitulo da legendaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nGrupo := 1 to Len(aLegendas)
		
		aBmp  := Array(Len(aLegendas[nGrupo][2]))

		@nLinha,37 SAY If((nZ+=1)==nZ,aLegendas[nZ][1]+If(nY==Len(aLegendas),If((nZ:=0)==nZ,"",""),""),"") SIZE 100,9 FONT oBold OF oDlgLeg PIXEL		
		nLinha += 8
		@nLinha,35 TO nLinha+2,400 LABEL '' OF oDlgLeg PIXEL
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณItens da legendaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	   	For nX := 1 to Len(aLegendas[nGrupo][2])   
		                         
			nLinha += 10

			@ nLinha,43 BITMAP aBmp[nX] RESNAME aLegendas[nGrupo][2][nX][1] OF oDlgLeg SIZE 20,10 PIXEL NOBORDER 
			@ nLinha,53 SAY If((nY+=1)==nY,aLegendas[nZ][2][nY][2]+If(nY==Len(aLegendas[nZ][2]),If((nY:=0)==nY,"",""),""),"") SIZE 100,9 OF oDlgLeg PIXEL

		Next nX

		nY := 0		
		nLinha += 15
		
	Next nGrupo
	nZ := 0

ACTIVATE MSDIALOG oDlgLeg CENTERED

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk510VldAssบAutor  ณVendas CRM         บ Data ณ  17/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida o chamado selecionado para associacao. O mesmo nao   บฑฑ
ฑฑบ          ณdeve estar associado a nenhum outro.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk510VldAss(cChamado)

Local aArea			:= GetArea()
Local aAreaADE		:= ADE->(GetArea())
Local lRet			:= .T.    

DbSelectArea("ADE")
DbSetOrder(1)
MsSeek(xFilial("ADE")+cChamado)

If !Empty(ADE->ADE_CHANEX)
	lRet := .F.
	MsgStop(STR0114 + ADE->ADE_CHANEX+STR0115+ADE->ADE_CHANEX+STR0116) //"O chamado selecionado para associa็ใo jแ estแ associado a outro chamado (" ### "). Favor utilizar o chamado " ###" na associa็ใo"
EndIf

RestArea(aAreaADE)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณRefreshTotPage บAutor  ณVendas CRM          บ Data ณ  11/03/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza o total de pแginas quando um filtro ้ executado         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method RefreshTotPage() Class HelpDeskListDialog
self:nTotal	:= 0 
#IFDEF TOP	       
	(Self:cTabelaAux)->(DbGoTop())
	While (Self:cTabelaAux)->(!EOF()) 
		If Empty(self:cFilter) .OR. &(Self:cFilter)
			self:nTotal++
		EndIf
		(Self:cTabelaAux)->(DbSkip())
	End
	(Self:cTabelaAux)->(DbGoTop())
#ELSE
	self:nTotal := (Self:cTabelaAux)->(RecCount())
#ENDIF
	Self:cPageTot	:= AllTrim(Str(Int(self:nTotal/Self:getMaxRowsPP()+1)))
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAcoes_LoteบAutor  ณBruno Daniel Borges บ Data ณ  28/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que carrega a tela para informacoes adicionais nas   บฑฑ
ฑฑบ          ณrotinas em LOTE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Acoes_Lote(nTipoAcao,aColsChamados,nPosChamado,cAssuntoEnc,cOperAssum,cOcorrDef,nPosBrw,aHeaderADE)
Local oDlg
Local oGroup
Local oGrpName	
Local cGrpName 			:= Space(TamSx3("U0_NOME")[1]) 
Local oMemo
Local cMemo				:= ""
Local aCoordenadas 		:= MsAdvSize(.T.) 
Local oAssunto 			:= Nil
Local cDescAssunto 		:= ""
Local oDescAssunto 		:= NIl
Local oProduto 			:= Nil
Local oDescProduto 		:= Nil
Local cDescProduto 		:= ""  
Local cDescCateg        := ""  
Local cDescOrig         := "" 
Local cDescCausa        := "" 
Local cDescEfeito       := "" 
Local cDescCampan       := ""
Local cDescAcao			:= ""
Local oCategoria   		:= Nil
Local oDescCateg   		:= Nil
Local oOrigem      		:= Nil
Local oDescOrig    		:= Nil
Local oCausa       		:= Nil
Local oDescCausa   		:= Nil
Local oEfeito      		:= Nil
Local oDescEfeito  		:= Nil
Local oCampanha    		:= Nil
Local oDescCampan  		:= Nil
Local oOperador 		:= Nil
Local cNomeOperador 	:= ""
Local cDescOcorre       := ""  
Local cOperAnterior     := ""
Local oNomeOperador 	:= Nil 
Local lRet				:= .F. 
Local oOcorrencia       := Nil
Local oAcao             := Nil
Local oDescOcorre       := Nil 
Local oDescAcao         := Nil
Local aRetAcao			:= {}
Local i
Local cFilAntBkp		:= cFilAnt 
Local aChamados			:= {}
Local cFilRef	  		:= ""
Local aOperador			:= {} 
Local cGrpAnt			:= "" 
Local lTKACALOTE		:= ExistBlock("TKACLOTE")
Local lRetPE			:= .T. 
Local lF3Grpo			:= .F. 
Local cOperAutomatico   := ""  
Local cOpcDefault       := ""
Local lOperAuto			:= .F.  
Local aOperXChamado		:= {}
Local aChNaoProc		:= {}
Local nCount := 0
Local cGroupAux 		:= ""
Local nPosGrupo      := Iif(aHeaderADE==Nil, 0, aScan(aHeaderADE,{|x| AllTrim(x[2]) == "ADE_GRUPO" } ))
Local cGrupoAtu      := ""  // grupo localizado antes da exibicao da tela

Private cProduto 	:= Space(TamSX3("ADE_CODSB1")[1])
Private cAssunto 	:= Space(TamSX3("ADE_ASSUNT")[1])
Private cGroup 		:= Space(TamSX3("U0_CODIGO")[1])
Private cOperador   := Space(TamSX3("U7_COD")[1])
Private cCategoria  := Space(TamSX3("ADE_CODCAT")[1])
Private cOrigem     := Space(TamSX3("ADE_CODORI")[1])
Private cCausa      := Space(TamSX3("ADE_CODCAU")[1])
Private cEfeito     := Space(TamSX3("ADE_CODEFE")[1])
Private cCampanha   := Space(TamSX3("ADE_CODCAM")[1])  
Private cOcorrencia := Space(TamSX3("ADF_CODSU9")[1])
Private cAcao       := Space(TamSX3("ADF_CODSUQ")[1])

M->ADE_ASSUNT := ""     
M->ADE_CODSB1 := ""
M->ADF_CODSU9 := ""
M->ADF_CODSUQ := ""

Default nTipoAcao 		:= 1 //1=Distribuir Chamados, 2=Transferir entre Grupos
Default cAssuntoEnc     := ""  
Default cOperAssum      := ""

If !Empty(cOcorrDef)
	cOcorrencia		:= cOcorrDef 
	M->ADF_CODSU9 	:= cOcorrencia
	cDescOcorre		:= Posicione("SU9",2,xFilial("SU9")+cOcorrencia,"SU9->U9_DESC" )	
EndIf

If !Empty(cAssuntoEnc)
	cAssunto		:= cAssuntoEnc
	M->ADE_ASSUNT	:= cAssuntoEnc
	cDescAssunto	:= Posicione("SX5",1,xFilial("SX5")+"T1"+cAssuntoEnc,"SX5->X5_DESCRI")
EndIf

If !Empty(cOperAssum)
	cOperador		:= cOperAssum
	aOperador		:= GetAdvFVal("SU7",{"U7_NOME","U7_POSTO"},xFilial("SU7")+cOperAssum,1,{"",""})
	cNomeOperador	:= aOperador[1]
	cGroup			:= aOperador[2]
	cGrpName 		:= Posicione("SU0",1,xFilial("SU0")+cGroup,"U0_NOME")
EndIf

If !Empty(cOcorrencia) .AND. !Empty(cAssunto)
	aRetAcao := FindAcao(cOcorrencia)
	If Len(aRetAcao) == 1   
		cAcao 			:= aRetAcao[1,1]
		M->ADF_CODSUQ	:= aRetAcao[1,1]
		cDescAcao 		:= aRetAcao[1,2]
	EndIf
EndIf

//Monta lista de chamados para validacao de transferencia entre filiais
For i := 1 To Len(aColsChamados)
	If aColsChamados[i][1] == "LBOK"
    	AAdd(aChamados,aColsChamados[i][nPosChamado])
    	If nTipoAcao = 1 .And. Empty(cGroupAux) .And. nPosGrupo > 0
        	cGroupAux:= aColsChamados[i][nPosGrupo]
        EndIf
	EndIf
Next i
cGroup:= cGrupoAtu := IIf(!Empty(cGroupAux),cGroupAux,cGroup)


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPonto de entrada para validar a acao em loteณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lTKACALOTE  
	lRetPE := ExecBlock("TKACLOTE",.F.,.F.,{aChamados,aColsChamados[nPosBrw][nPosChamado],nTipoAcao})
	If ValType(lRetPE) == "L" .AND. !lRetPE
		Return {}
	EndIf
EndIf

//Verifica se existe a nova consulta do grupo
dbSelectArea("SXB")
dbSetOrder(1)
If SXB->(dbSeek("TMKSU0"))
	lF3Grpo := .T.
EndIf

//Tela padrao apos os processamentos em LOTE dos chamados do Service Desk
While .T.
	oDlg := TDialog():New(aCoordenadas[7],000,aCoordenadas[6]-20,aCoordenadas[5]/2.2,STR0134,,,,,,,,oMainWnd,.T.) //"A็ใo em Lote nos Chamados"
		@ 001,005 SAY STR0133 PIXEL SIZE 55,9 OF oDlg  //"Assunto"
		@ 010,005 MSGET oAssunto Var cAssunto SIZE 030,9 PICTURE "@!" OF oDlg Pixel F3 "T1" VALID Iif(!Empty(cAssunto) .And. ExistCpo("SX5","T1"+cAssunto),(M->ADE_ASSUNT := cAssunto,Iif(!Empty(cAssunto),cDescAssunto := Posicione("SX5",1,xFilial("SX5")+"T1"+cAssunto,"SX5->X5_DESCRI"),Nil),.T.),.F.) When (nTipoAcao == 2)
		@ 010,040 MSGET oDescAssunto Var cDescAssunto SIZE oDlg:nClientWidth/2-45,9 PICTURE "@!" OF oDlg Pixel When .F.
	
		@ 025,005 SAY STR0141 PIXEL SIZE 55,9 OF oDlg //"Grupo:"
		@ 035,005 MSGET oGroup Var cGroup SIZE 015,9 PICTURE PesqPict("SU0", "U0_CODIGO") OF oDlg Pixel F3 IIf(!lF3Grpo,"TMK014","TMKSU0") VALID Tk510AVlGr(cGroup,cAssunto,aChamados,@cGrpName,@cOperador,@cNomeOperador,@cGrpAnt, @cGrupoAtu) When !Empty(cAssunto) .And. nTipoAcao == 2
		@ 035,030 MSGET oGrpName Var cGrpName SIZE oDlg:nClientWidth/2-035,9 PICTURE PesqPict("SU0", "U0_NOME") OF oDlg Pixel When .F.
	
		@ 050,005 SAY STR0142 PIXEL SIZE 55,9 OF oDlg //"Usuแrio:"
		@ 060,005 MSGET oOperador Var cOperador SIZE 030,9 PICTURE PesqPict("SU7", "U7_COD") OF oDlg Pixel F3 "TMK018" VALID Iif(!Empty(cOperador),TK510VldUser(cGroup,cOperador,@cNomeOperador),.T.) When !Empty(cAssunto) .And. TK510VldGrupo(cGroup,,2) .And. nTipoAcao == 2
		@ 060,040 MSGET oNomeOperador Var cNomeOperador SIZE oDlg:nClientWidth/2-045,9 PICTURE "@!" OF oDlg Pixel When .F.

		If FATPDActive() .And. FTPDUse(.T.)
	    	oNomeOperador:lObfuscate := FATPDIsObfuscate("U7_NOME", /*cSource*/, .T.)
		Endif

		@ 080,005 SAY STR0135 PIXEL SIZE 55,9 OF oDlg //"Produto"
		@ 080,040 MSGET oProduto Var cProduto SIZE 60,9 PICTURE PesqPict("SB1", "B1_COD") OF oDlg Pixel F3 "TMK019" VALID Iif(Tk510VldCpTr(1,cProduto,@cFilRef),(M->ADE_CODSB1 := cProduto ,cDescProduto := Posicione("SB1",1,cFilRef+cProduto,"SB1->B1_DESC")),.F.) When nTipoAcao == 2
		@ 080,105 MSGET oDescProduto Var cDescProduto SIZE oDlg:nClientWidth/2-110,9 OF oDlg Pixel When .F.
	
		@ 095,005 SAY STR0136 PIXEL SIZE 55,9 OF oDlg //"Categoria"
		@ 095,040 MSGET oCategoria Var cCategoria SIZE 60,9 PICTURE PesqPict("ADE", "ADE_CODCAT") OF oDlg Pixel F3 Posicione("SX3", 2, "ADE_CODCAT","X3_F3") VALID(cDescCateg := "", Iif(!Empty(cCategoria),Iif(Tk510JValid(3),(cDescCateg := FQNCNTAB('4',cCategoria),.T.),.F.),.T.) ) When nTipoAcao == 2
		@ 095,105 MSGET oDescCateg Var cDescCateg SIZE oDlg:nClientWidth/2-110,9 OF oDlg Pixel When .F.
	
		@ 110,005 SAY STR0137 PIXEL SIZE 55,9 OF oDlg //"Origem"
		@ 110,040 MSGET oOrigem Var cOrigem SIZE 60,9 PICTURE PesqPict("ADE", "ADE_CODORI") OF oDlg Pixel F3 Posicione("SX3", 2, "ADE_CODORI","X3_F3") VALID (cDescOrig := "", Iif(!Empty(cOrigem),Iif(Tk510JValid(4),(cDescOrig := FQNCNTAB('3',cOrigem) ,.T.),.F.),.T.) ) When nTipoAcao == 2
		@ 110,105 MSGET oDescOrig Var cDescOrig SIZE oDlg:nClientWidth/2-110,9 OF oDlg Pixel When .F.
	
		@ 125,005 SAY STR0138 PIXEL SIZE 55,9 OF oDlg //"Causa"
		@ 125,040 MSGET oCausa Var cCausa SIZE 60,9 PICTURE PesqPict("ADE", "ADE_CODCAU") OF oDlg Pixel F3 Posicione("SX3", 2, "ADE_CODCAU","X3_F3") VALID (cDescCausa := "", Iif(!Empty(cCausa),IIf(Tk510JValid(5),(cDescCausa := FQNCNTAB('1',cCausa),.T.),.F.),.T.) ) When nTipoAcao == 2
		@ 125,105 MSGET oDescCausa Var cDescCausa SIZE oDlg:nClientWidth/2-110,9 OF oDlg Pixel When .F.
	
		@ 140,005 SAY STR0139 PIXEL SIZE 55,9 OF oDlg //"Efeito"
		@ 140,040 MSGET oEfeito Var cEfeito SIZE 60,9 PICTURE PesqPict("ADE", "ADE_CODEFE") OF oDlg Pixel F3 Posicione("SX3", 2, "ADE_CODEFE","X3_F3") VALID (cDescEfeito := "", Iif(!Empty(cEfeito),Iif(Tk510JValid(6),(cDescEfeito := FQNCNTAB('2',cEfeito) ,.T.),.F.),.T.)) When nTipoAcao == 2
		@ 140,105 MSGET oDescEfeito Var cDescEfeito SIZE oDlg:nClientWidth/2-110,9 OF oDlg Pixel When .F.
	
		@ 155,005 SAY STR0140 PIXEL SIZE 55,9 OF oDlg //"Campanha"
		@ 155,040 MSGET oCampanha Var cCampanha SIZE 60,9 PICTURE PesqPict("ADE", "ADE_CODCAM") OF oDlg Pixel F3 "TMK006" VALID (cDescCampan := "", Iif(!Empty(cCampanha),Iif(Tk510JValid(1),(cDescCampan := POSICIONE('SUO',1,XFILIAL('SUO') + cCampanha, 'UO_DESC'),.T.),.F.),.T.)) When nTipoAcao == 2
		@ 155,105 MSGET oDescCampan Var cDescCampan SIZE oDlg:nClientWidth/2-110,9 OF oDlg Pixel When .F.

		@ 170,005 SAY STR0143 PIXEL SIZE 55,9 OF oDlg //"Ocorr๊ncia:"
		@ 170,040 MSGET oOcorrencia Var cOcorrencia SIZE 030,9 PICTURE PesqPict("ADF", "ADF_CODSU9") OF oDlg Pixel F3 "OCO" VALID Tk510AVlOco(@cDescOcorre) WHEN (nTipoAcao <> 1 .AND. nTipoAcao <> 4)
		@ 170,105 MSGET oDescOcorre Var cDescOcorre SIZE oDlg:nClientWidth/2-110,9 OF oDlg Pixel When .F.

		@ 185,005 SAY STR0144 PIXEL SIZE 55,9 OF oDlg //"A็ใo:"
		@ 185,040 MSGET oAcao Var cAcao SIZE 030,9 PICTURE PesqPict("ADF", "ADF_CODSUQ") OF oDlg Pixel F3 "SURTMK" VALID(cDescAcao := "",M->ADF_CODSUQ := SUR->UR_CODSOL,Iif( !Empty(cAcao),Iif(TK510AcaTmk(.T.),(cDescAcao := Posicione("SUQ",1,xFilial("SUQ")+cAcao,"SUQ->UQ_DESC") ,.T.),.F.),.T.)) When (!Empty(cOcorrencia) .AND. nTipoAcao <> 1)
		@ 185,105 MSGET oDescAcao Var cDescAcao SIZE oDlg:nClientWidth/2-110,9 OF oDlg Pixel When .F.	                                                          
		
		@ 200,005 SAY STR0145 PIXEL SIZE 55,9 OF oDlg //"Motivo"
		oMemo:= TMultiGet():New(210,005,{|u|if(Pcount()>0,cMemo:=u,cMemo)},oDlg,oDlg:nClientWidth/2-10,oDlg:nClientHeight/2-250,,,,,,.T.)
		oMemo:lWordWrap := .T.
	
	    DEFINE SBUTTON FROM oDlg:nClientHeight/2-30,005 TYPE 1 ENABLE OF oDlg ACTION (lRet:= .T.,oDlg:End())
	    DEFINE SBUTTON FROM oDlg:nClientHeight/2-30,040 TYPE 2 ENABLE OF oDlg ACTION (lRet:= .F.,oDlg:End())
	oDlg:Activate(,,,.T.)    
	
	//Valida se a combinacao de assunto/produto/categoria/origem/causa/efeito e campanha eh valida
	If lRet .And. nTipoAcao == 3 .And. (Empty(cOcorrencia) .Or. Empty(cAcao))
		MsgAlert(STR0146) //"No encerramento de chamados em lote, ้ obrigat๓rio informar a a็ใo e a ocorr๊ncia."
		Loop	
	ElseIf lRet .And. nTipoAcao == 3 .And. !Empty(cAcao) .And. Posicione("SUQ",1,xFilial("SUQ")+cAcao,"SUQ->UQ_STATCH") <> "3"
		MsgAlert(STR0147) //"A a็ใo informada nใo ้ do tipo ENCERRAMENTO DE CHAMADO. Verifique o conte๚do digitado."
		Loop	
	ElseIf lRet .And. !TK510CombVld(cAssunto,cGroup,nTipoAcao)
		Loop
	ElseIf lRet
 		
 		#IFDEF TOP
			lOperAuto := Empty(cOperador)
		#ENDIF
    
		//Faz a gravacao dos dados alterados para todos os chamados marcados
		For i := 1 To Len(aColsChamados)
			If aColsChamados[i][1] == "LBOK"
				dbSelectArea("ADE")
				ADE->(dbSetOrder(1))
				If ADE->(dbSeek(xFilial("ADE")+aColsChamados[i][nPosChamado]))
				
					//Verifica se o chamado estแ bloqueado, caso contrแrio faz o bloqueio.
					If TK510UsrLock("L", ADE->ADE_CODIGO, TkOperador(), .F.)

						cOperAnterior	:= ADE->ADE_OPERAD
						Begin Transaction     
						
							ADE->(RecLock("ADE", .F.))   
							
							    //Seleciona o operador automaticamente
							    #IFDEF TOP
									If lOperAuto
										cOperador := Tk510OpAuto(cGroup,@cOpcDefault)
									EndIf
								#ENDIF
	
								//Assunto 
								If !Empty(cAssunto)
									ADE->ADE_ASSANT := ADE->ADE_ASSUNT
									ADE->ADE_ASSUNT := cAssunto       
								EndIf
								
								//Produto
								If !Empty(cProduto)
									ADE->ADE_PRDANT	:= ADE->ADE_CODSB1
									ADE->ADE_CODSB1	:= cProduto
								EndIf
								
								//Operador - Na transferencia de grupo, o campo operador pode vir em branco
								If (!Empty(cOperador) .And. ADE->ADE_OPERAD <> cOperador) .Or. nTipoAcao == 2
								
									//Considera o grupo de origem na transferencia entre filiais
									DbSelectArea("SU0")
									DbSetOrder(1)
									dbSeek(xFilial("SU0")+cGroup)
									
								  	If !Empty(SU0->U0_FILORI) .AND. !Empty(SU0->U0_GRPORI) .AND. xFilial("SU0") <> SU0->U0_FILORI
					  					
					  					cFilAnt 	:= SU0->U0_FILORI
					  					
					  				EndIf                                
					  				
					  				cOperador := TK510StatOper(cOperador)
					  				
									ADE->ADE_OPERAD	:= cOperador                       
									lTransAtend 	:= .T.
									cFilAnt			:= cFilAntBkp 
									cOperAssum		:= cOperador
									
								EndIf 
	
							    //Atualiza a data/hora de execucao do rodizio
								If lOperAuto .AND. cOpcDefault == "4"
									SU7->(dbSetOrder(1))
									If SU7->(dbSeek(xFilial("SU7")+cOperador))
										Sleep(1000)
										If SoftLock("SU7")
									    	SU7->U7_DTRODZ  := If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
									    	SU7->U7_HRRODZ	:= StrTran(Time(),":","")
										    SU7->(MsUnlock())				
										EndIf																		
									EndIf
								EndIf
								
								AAdd(aOperXChamado,{aColsChamados[i][nPosChamado],cOperador,ADE->ADE_GRUPO})
								
								If !Empty(cGroup) .And. ADE->ADE_GRUPO <> cGroup
									ADE->ADE_GRUPO	:= cGroup
									lTransAtend 	:= .T.
								EndIf
								
								//Codigo da Categoria
								If !Empty(cCategoria)                                                    
									ADE->ADE_CODCAT := cCategoria
								EndIf
	                                 
								//Origem
								If !Empty(cOrigem)                                                 
									ADE->ADE_CODORI := cOrigem
								EndIf
	
								//Causa							
								If !Empty(cCausa)                        
									ADE->ADE_CODCAU := cCausa
								EndIf
	
								//Efeito							
								If !Empty(cEfeito)                        
									ADE->ADE_CODEFE := cEfeito
								EndIf
	
								//Campanha							
								If !Empty(cCampanha)                        
									ADE->ADE_CODCAM := cCampanha
								EndIf
							ADE->(MsUnlock())
						End Transaction
						nCount++
				    Else
						//Adiciona no array os chamados que nใo foram processados, pois estแ sendo utilizado por outro operador.
						aAdd(aChNaoProc,{ADE->ADE_CODIGO,ADE->ADE_OPEUSO+" - "+AllTrim(Posicione("SU7",1,xFilial("SU7")+ADE->ADE_OPEUSO,"U7_NOME"))})
				    EndIf		
				EndIf
			EndIf
		Next i
		
		//Fecha a tela de alteracao dos dados
		Exit 
	        
	//Fecha a tela
	Else
		Return {}
	EndIf  
EndDo

Return({cOcorrencia,cAcao,cMemo,cGroup,cOperAnterior,aOperXChamado,aChNaoProc})


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTransfLote  บAutor  ณBruno Daniel Borges บ Data ณ  28/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a transferencia dos chamados marcaodos               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method TransfLote() Class HelpDeskListDialog     

Local lSelItem 			:= .F.
Local lOpenMsg			:= .F.
Local nCount 			:= 0 
Local iCols				:= 0    
Local nCodPos			:= 0 
Local nPosOp			:= 0
Local nPosCh			:= 0
Local aAcaoOcorrencia	:= {}
Local cAssunto			:= ""
Local cOperAssum		:= ""
Local cChNaoGrav		:= ""
Local cFilDest			:= ""
Local cFilOri			:= cFilAnt
Local cSU7 				:= TkOperador()

Self:GetFieldPos("ADE_CODIGO", @nCodPos, Self:aHeaderADE)

ADE->(DbSetOrder(1))

For iCols := 1 To Len(Self:OGETDADOS:ACOLS)
	If Self:OGETDADOS:ACOLS[iCols][1] == "LBOK"
		ADE->(MsSeek(xFilial("ADE")+Self:OGETDADOS:ACOLS[iCols][nCodPos]))
		If Empty(cAssunto)
			cAssunto	:= AllTrim(ADE->ADE_ASSUNT)
		ElseIf cAssunto <> AllTrim(ADE->ADE_ASSUNT)
			MsgInfo(STR0155) //"Por favor, selecione apenas chamados com o mesmo assunto."
			Return .F.
		EndIf
		lSelItem := .T. 
		nCount++
	EndIf
Next iCols

If nCount <= 0
	Aviso(STR0025, STR0127, {"OK"}) //"Aviso" //"Nใo foi selecionado nenhum chamado para transfer๊ncia entre grupos"
	Return .F.
EndIf

If !MsgYesNo(STR0131) //"Confirma a transfer๊ncia para outro grupo de atendimento ?"
	Return .F.
EndIf

//Chama a funcao para manutencao nos campos do chamado quando processamento em lote
aAcaoOcorrencia := Acoes_Lote(2,Self:OGETDADOS:ACOLS,nCodPos,cAssunto,@cOperAssum,,Self:OGETDADOS:nAT)

If Len(aAcaoOcorrencia) == 0
	Return .F.
EndIf

//Gera a linha na tabela ADF para indicar a distribuicao do chamado				
For iCols := 1 To Len(Self:OGETDADOS:ACOLS)
	If Self:OGETDADOS:ACOLS[iCols][1] == "LBOK"
		nPosOp := aScan(aAcaoOcorrencia[6],{|x| x[1] == Self:OGETDADOS:ACOLS[iCols][nCodPos]})
		If nPosOp > 0
			cOperAssum := aAcaoOcorrencia[6][nPosOp][2]
			Tk510ClrGrp()
			Tk510TGrp(aAcaoOcorrencia[4],cOperAssum)
			TkUpdCall(	"",;
						IIf(!Empty(aAcaoOcorrencia[2]),aAcaoOcorrencia[2],""),;
						"",;
						(STR0132 + aAcaoOcorrencia[4] + CRLF + aAcaoOcorrencia[3]),; //"Transfer๊ncia entre equipes do chamado. Equipe transferida: "
						""/*cTpAcao */,;
						TkOperador(),;	
						aAcaoOcorrencia[6][nPosOp][3],;	//Grupo que pertencia o chamado, antes da transfer๊ncia.
						"",;
						,;		
						If(!IsInCallStack("GenRecurrence"), Date(), dDatabase ),;		
						Self:OGETDADOS:ACOLS[iCols][nCodPos],;
						"TMK001",;
						,,,,,,"2")	

			//Desbloqueia o chamado
			Iif(!Empty(cFilDest),cFilAnt:=cFilDest,)
			TK510UsrLock("U", Self:OGETDADOS:ACOLS[iCols][nCodPos], cSU7)
			Iif(!Empty(cFilDest),cFilAnt:=cFilOri,)
		Else
            nPosCh := aScan(aAcaoOcorrencia[7],{|x| x[1] == Self:OGETDADOS:ACOLS[iCols][nCodPos]})
            If nPosCh > 0        
	 			cChNaoGrav += STR0172 + ": " + aAcaoOcorrencia[7][nPosCh][1] + " - " + STR0015 + ": " + aAcaoOcorrencia[7][nPosCh][2] + CRLF
            	lOpenMsg := .T.
            EndIf
		EndIf

	EndIf
Next iCols

If lOpenMsg
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Lista os chamados que nใo foram processados. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Tk510WindLog(cChNaoGrav)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEncerraLote บAutor  ณBruno Daniel Borges บ Data ณ  28/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza o encerramento dos chamados marcaodos                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method EncerraLote() Class HelpDeskListDialog     

Local lSelItem 			:= .F.
Local lOpenMsg			:= .F.
Local nCount 			:= 0 
Local iCols				:= 0    
Local nCodPos			:= 0
Local nPos				:= 0
Local nPosCh			:= 0 
Local aAcaoOcorrencia	:= {}
Local aAssuntos         := {}
Local cChNaoGrav		:= ""

Self:GetFieldPos("ADE_CODIGO", @nCodPos, Self:aHeaderADE)

dbSelectArea("ADE")
ADE->(dbSetOrder(1))

For iCols := 1 To Len(Self:OGETDADOS:ACOLS)
	If Self:OGETDADOS:ACOLS[iCols][1] == "LBOK"
		lSelItem := .T. 
		nCount++
		//Avalia o assunto do chamado
		ADE->(MsSeek(xFilial("ADE")+Self:OGETDADOS:ACOLS[iCols][nCodPos] ))
		If AScan(aAssuntos,{|x| x == ADE->ADE_ASSUNT }) <= 0
			AAdd(aAssuntos,ADE->ADE_ASSUNT)
		EndIf		
	EndIf
Next iCols 

If nCount <= 0
	Aviso(STR0025, STR0224, {STR0122}) //"Aviso" ### "OK" //"Nใo foi selecionado nenhum chamado para encerrar "
	Return .F.
EndIf

If Len(aAssuntos) > 1
	Aviso(STR0025, STR0128, {STR0122}) //"Aviso" ###"Foram selecionados chamados de assuntos diferentes. Para encerramento em lote, marque apenas chamados do mesmo assunto."###"OK"
	Return .F.
EndIf

If !MsgYesNo(STR0129) //"Confirma o encerramento dos chamados marcados ?"
	Return .F.
EndIf

//Chama a funcao para manutencao nos campos do chamado quando processamento em lote
aAcaoOcorrencia := Acoes_Lote(3,Self:OGETDADOS:ACOLS,nCodPos,aAssuntos[1],,,Self:OGETDADOS:nAT)

If Len(aAcaoOcorrencia) == 0
	Return .F.
EndIf

//Gera a linha na tabela ADF para indicar a distribuicao do chamado				
For iCols := 1 To Len(Self:OGETDADOS:ACOLS)
	If Self:OGETDADOS:ACOLS[iCols][1] == "LBOK"
		nPos := aScan(aAcaoOcorrencia[6],{|x| x[1] == Self:OGETDADOS:ACOLS[iCols][nCodPos]})
		If nPos > 0
			dbSelectArea("ADE")
			ADE->(dbSetOrder(1))
			ADE->(MsSeek(xFilial("ADE")+Self:OGETDADOS:ACOLS[iCols][nCodPos] ))
			TkUpdCall(	"",;
						aAcaoOcorrencia[2],;
						"",;
						STR0130 + CRLF + aAcaoOcorrencia[3],;
						"",;
						TkOperador(),;
						ADE->ADE_GRUPO,;
						"",;
						,;
						If(!IsInCallStack("GenRecurrence"), Date(), dDatabase ),;
						Self:OGETDADOS:ACOLS[iCols][nCodPos],;
						aAcaoOcorrencia[1],;
						,,,,,,"3")
				
			//Desbloqueia o chamado
			TK510UsrLock("U", Self:OGETDADOS:ACOLS[iCols][nCodPos], TkOperador())
		Else
            nPosCh := aScan(aAcaoOcorrencia[7],{|x| x[1] == Self:OGETDADOS:ACOLS[iCols][nCodPos]})
            If nPosCh > 0        
	 			cChNaoGrav += STR0172 + ": " + aAcaoOcorrencia[7][nPosCh][1] + " - " + STR0015 + ": " + aAcaoOcorrencia[7][nPosCh][2] + CRLF
            	lOpenMsg := .T.
            EndIf
		EndIf
	EndIf
Next iCols

If lOpenMsg
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Lista os chamados que nใo foram processados. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Tk510WindLog(cChNaoGrav)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AssumeLote บAutor  ณBruno Daniel Borges บ Data ณ  28/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Assume os chamados sem analista da area do operador          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method AssumeLote() Class HelpDeskListDialog     

Local lSelItem 			:= .F.
Local lOpenMsg			:= .F.
Local nCount 			:= 0 
Local iCols				:= 0    
Local nCodPos			:= 0  
Local nPos				:= 0
Local nPosCh			:= 0 
Local cObsChamado       := ""
Local cChNaoGrav		:= ""

Self:GetFieldPos("ADE_CODIGO", @nCodPos, Self:aHeaderADE)

For iCols := 1 To Len(Self:OGETDADOS:ACOLS)
	If Self:OGETDADOS:ACOLS[iCols][1] == "LBOK"
		lSelItem := .T. 
		nCount++
	EndIf
Next iCols 

If nCount <= 0
	Aviso(STR0025, STR0121, {STR0122}) //"Aviso" ###"Nenhum chamado foi selecionado para que seja assumido por voc๊." ###"OK"
	Return .F.
EndIf

//Chama a funcao para manutencao nos campos do chamado quando processamento em lote
aAcaoOcorrencia := Acoes_Lote(4,Self:OGETDADOS:ACOLS,nCodPos,,TkOperador(),,Self:OGETDADOS:nAT) 

If Len(aAcaoOcorrencia) == 0
	Return .F.
EndIf

//Gera a linha na tabela ADF para indicar a distribuicao do chamado				
For iCols := 1 To Len(Self:OGETDADOS:ACOLS)
	If Self:OGETDADOS:ACOLS[iCols][1] == "LBOK"
		nPos := aScan(aAcaoOcorrencia[6],{|x| x[1] == Self:OGETDADOS:ACOLS[iCols][nCodPos]})
		If nPos > 0
			dbSelectArea("ADE")
			ADE->(dbSetOrder(1))
			ADE->(MsSeek(xFilial("ADE")+Self:OGETDADOS:ACOLS[iCols][nCodPos] ))

			//Gera a ocorrencia do tipo ASSUMIR O CHAMADO automatica  
			cObsChamado := STR0123 + CRLF //"CHAMADO ASSUMIDO PELO OPERADOR"
			cObsChamado += STR0124 + AllTrim(aAcaoOcorrencia[5]) + " - " + AllTrim(Posicione("SU7",1,xFilial("SU7")+aAcaoOcorrencia[5],"SU7->U7_NOME")) + CRLF //"Operador Anterior: "
			cObsChamado += STR0125 + AllTrim(TkOperador()) + " - " + AllTrim(Posicione("SU7",1,xFilial("SU7")+TkOperador(),"SU7->U7_NOME")) + CRLF //"Operador Atual: "
			cObsChamado += STR0126 + DToC(If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )) + " - " + SubStr(Time(),1,5) //"Data/Hora que o chamado foi assumido: "

			//Ocorrencia automatica do tipo ASSUMIR		
			TkUpdCall(	"",;
						"",;
						"",;
						cObsChamado + CRLF + aAcaoOcorrencia[3],;
						"",;
						TkOperador(),;	
						Posicione("SU7", 1, xFilial("SU7")+TkOperador(), "U7_POSTO"),;
						"",;
						,;		
						If(!IsInCallStack("GenRecurrence"), Date(), dDatabase ),;		
						Self:OGETDADOS:ACOLS[iCols][nCodPos],;
						"TMK009",;
						,,,,,,"4")				
		
			//Caso usuario tenha informado opcionalmente uma nova ocorrencia e acao, gera a informacao nos chamados
			If !Empty(aAcaoOcorrencia[2]) .And. !Empty(aAcaoOcorrencia[1])
				TkUpdCall(	"",aAcaoOcorrencia[2],"",aAcaoOcorrencia[3],;
							"",TkOperador(),ADE->ADE_GRUPO,"",;
							Nil,If(!IsInCallStack("GenRecurrence"), Date(), dDatabase ),Self:OGETDADOS:ACOLS[iCols][nCodPos],aAcaoOcorrencia[1])
			EndIf

			//Desbloqueia o chamado
			TK510UsrLock("U", Self:OGETDADOS:ACOLS[iCols][nCodPos], TkOperador())
		Else
            nPosCh := aScan(aAcaoOcorrencia[7],{|x| x[1] == Self:OGETDADOS:ACOLS[iCols][nCodPos]})
            If nPosCh > 0        
	 			cChNaoGrav += STR0172 + ": " + aAcaoOcorrencia[7][nPosCh][1] + " - " + STR0015 + ": " + aAcaoOcorrencia[7][nPosCh][2] + CRLF
            	lOpenMsg := .T.
            EndIf
		EndIf
	EndIf
Next iCols

If lOpenMsg
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Lista os chamados que nใo foram processados. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Tk510WindLog(cChNaoGrav)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณfree       	บAutor  ณVendas Clientes บ Data ณ  30/06/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Libera a mem๓ria dos objetos utilizados.    			 	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Free() Class HelpDeskListDialog
TMKFree( Self:oObj )
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFindAcao  บAutor  ณMicrosiga           บ Data ณ  05/17/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FindAcao(cOcorrencia)

Local aArea	:= GetArea()
Local aRet	:= {}

DbSelectarea("SUR")
DbSetorder(1)
MsSeek(xFilial("SUR")+cOcorrencia)
While !Eof() .AND. (xFilial("SUR") == SUR->UR_FILIAL) .AND. (SUR->UR_CODREC == cOcorrencia)
	If !Empty(SUR->UR_CODSOL)
		Aadd(aRet,{SUR->UR_CODSOL,SUR->UR_DESC}) 
	Endif	
	DbSkip()
End  

RestArea(aArea)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk510GetGroupsบ Autor ณ Vendas CRM     บ Data ณ  08/05/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPega os grupos do operador.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1: C๓digo do usuแrio                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk510GetGroups(cUserCode)

Local aArea			:= GetArea()	// Salva a area
Local aAreaAG9		:= {}
Local aGroups		:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPega os grupos que o operador atende.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

aAreaAG9 := AG9->(GetArea())
DbSelectArea("AG9")
DbSetOrder(1)	
If MsSeek( xFilial("AG9") + cUserCode )
	While 	!AG9->(EOF()) .And.;
			AG9->AG9_FILIAL == xFilial("AG9") .And.;
			AllTrim(AG9->AG9_CODSU7) == AllTrim(cUserCode)
		aAdd(aGroups, AG9->AG9_CODSU0)
		AG9->(DbSkip())
	End
EndIf	
RestArea( aAreaAG9 )

aSort(aGroups)

RestArea( aArea )

Return aGroups

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk510CmpAssบAutor  ณVendas CRM         บ Data ณ  29/06/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida uma lista de assuntos para um operador especifico    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPA1 - Array de assuntos a serem validados                 บฑฑ
ฑฑบ          ณEXPC2 - Codigo do operador a ser validado                   บฑฑ
ฑฑบ          ณEXPC3 - (opcional) Codigo do assunto nao encontrado         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk510CmpAss(aAssuntos,cOperador,cAssErro)

Local aArea		:= GetArea() 
Local aGrupos	:= Tk510GetGroups(cOperador)
Local aAssuntOp	:= {}
Local lRet		:= .T.
Local nX		:= 0 
Local cFilSKK	:= xFilial("SKK")

Default cAssErro:= ""

DbSelectArea("SKK")
DbSetOrder(1) //KK_FILIAL+KK_CODSU0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria a lista de assuntos que o operador pode acessarณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nX := 1 to Len(aGrupos)
	SKK->(MsSeek(cFilSKK+aGrupos[nX]))
	While !SKK->(Eof()) .AND. SKK->KK_FILIAL == cFilSKK .AND. SKK->KK_CODSU0 == aGrupos[nX]
		If aScan(aAssuntOp,SKK->KK_CODSKQ) == 0
			AAdd(aAssuntOp,SKK->KK_CODSKQ)
		EndIf
		SKK->(DbSkip())
	End	
Next nX

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCompara os assuntosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nX := 1 to Len(aAssuntos)
	If aScan(aAssuntOp,aAssuntos[nX]) == 0
		lRet 	:= .F.
		cAssErro:= aAssuntos[nX]
		Exit
	EndIf
Next nX

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk510AVlOcoบAutor  ณVendas CRM         บ Data ณ  07/07/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a ocorrencia digitada                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk510AVlOco(cDescOcorre)
           
Local lRet := .T.

If !(M->ADF_CODSU9 == cOcorrencia)

	M->ADF_CODSU9 := cOcorrencia
	cAcao := Space(TamSX3("ADF_CODSUQ")[1])

	If !Empty(cOcorrencia)
		If TK510OcoTmk(,.T.)
			cDescOcorre := Posicione("SU9",1,xFilial("SU9")+cAssunto+cOcorrencia,"SU9->U9_DESC" )
		Else 
			lRet := .F.
		EndIf
	Else
		cDescOcorre := ""
	EndIf  
EndIf

Return lRet
           
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk510AVlGrบAutor  ณVendas CRM          บ Data ณ  07/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida o grupo selecionado pelo operador                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk510AVlGr(cGroup		, cAssunto		, aChamados	, cGrpName			,;
					cOperador	, cNomeOperador	, cGrpAnt   )

Local lRet 		:= .T.
Local nTamOp	:= TamSX3("U7_COD")[1]

// TFEGRP Distribuicao de Chamados por Condicao
// refaz a validacao apenas se nao esta em branco e houve alteracao do campo
If !Empty(cGroup) .and. cGrpAnt <> cGroup

	If  ExistCpo("SU0",cGroup) .And. TK510VldGrupo(cGroup,cAssunto,,aChamados)
		cGrpAnt 		:= cGroup
		cGrpName 		:= Posicione("SU0",1,xFilial("SU0")+cGroup,"SU0->U0_NOME")
		cOperador 		:= Space(nTamOp)
		cNomeOperador	:= ""
	Else
		lRet 	:= .F.
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk510CopiaบAutor  ณVendas CRM          บ Data ณ  16/06/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInterface de copia de chamados                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 - Codigo do chamado a ser copiado                     บฑฑ
ฑฑบ          ณEXPA2 - Campos do cabecalho a serem copiados                บฑฑ
ฑฑบ          ณEXPA3 - Campos do tem a ser copiado                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk510Copia(cChamado,aCabCopia,aItCopia,lJob,;
					cTexto	)

Local aArea		:= GetArea()				// Armazena o posicionamento atual
Local aAreaADE	:= ADE->(GetArea())		// Armazena o posicionamento atual da tabela ADE
Local aAreaADF	:= ADF->(GetArea())		// Armazena o posicionamento atual da tabela ADF
Local aAreaSX3	:= SX3->(GetArea())		// Armazena o posicionamento atual da tabela SX3
Local aCabec	:= {}						// Array com campos do cabecalho
Local aItens	:= {}						// Array com itens do cabecalho

Local lRet		:= .T.						// Retorna se a copia foi feita ou nao

Local nX		:= 0						// Auxiliar de loop
Local nPosIncide:= 0						// Posicao do Incidente no array

Local oDlg		:= Nil						// Dialog principal
Local oBtnOk	:= Nil						// Botao incluir
Local oBtnCanc	:= Nil						// Botao cancelar
Local oCabec	:= Nil						// Listbox com cabecalho do chamado
Local oItens	:= Nil						// Listbox com itens do chamado

Local bDblClick	:= Nil

Local oOk		:= LoaDbitmap(GetResources(),"LBOK")	// [X] Marcado
Local oNo		:= LoaDbitmap(GetResources(),"LBNO")	// [ ] Desmarcado

Default lJob	:= .F.
Default cTexto	:= STR0161 //"C๓pia do chamado"

aCabec := LoadInfo("ADE",cChamado)
aItens := LoadInfo("ADF",cChamado)

If !lJob

	bDblClick	:= {|oLB,aArr| Iif(!Empty(aArr[oLB:nAt,3]),(aArr[oLB:nAt,1] := !aArr[oLB:nAt,1], oLB:Refresh()),;
					MsgInfo(STR0162)) } //"Este campo nใo possui conte๚do para ser copiado"

	DEFINE MSDIALOG oDlg TITLE STR0161 FROM 0,0 TO 390, 840 PIXEL //"C๓pia do chamado"
	
	@ 004, 004 TO 188, 207 PROMPT STR0163 OF oDlg PIXEL //"Dados do chamado"
	@ 004, 209 TO 160, 413 PROMPT STR0164 OF oDlg PIXEL //"Item principal"
	
	@ 012, 007 LISTBOX oCabec  FIELDS HEADER " ",STR0165,STR0166	SIZE 199, 172 OF oDlg PIXEL; //"Campo"###"Valor"
		ON dblClick(Eval(bDblClick,oCabec,aCabec))
	
	@ 012, 212 LISTBOX oItens  FIELDS HEADER " ",STR0165,STR0166	SIZE 199, 145 OF oDlg PIXEL; //"Campo"###"Valor"
		ON dblClick(Eval(bDblClick,oItens,aItens))
	
	@ 169, 248 BUTTON oBtnOk	PROMPT STR0018	SIZE 066, 015 OF oDlg PIXEL Action(oDlg:End()) //"Confirmar"
	@ 169, 316 BUTTON oBtnCanc	PROMPT STR0076	SIZE 066, 015 OF oDlg PIXEL Action(lRet := .F.,oDlg:End()) //"Cancelar"
	
	oCabec:SetArray(aCabec)
	oCabec:bLine 	:= {|| {Iif(aCabec[oCabec:nAt,1],oOk,oNo),	aCabec[oCabec:nAt,2],aCabec[oCabec:nAt,3]}}
	oCabec:Refresh()
	
	oItens:SetArray(aItens)
	oItens:bLine 	:= {|| {Iif(aItens[oItens:nAt,1],oOk,oNo),	aItens[oItens:nAt,2],aItens[oItens:nAt,3]}}
	oItens:Refresh()
	
	ACTIVATE MSDIALOG oDlg CENTERED  

EndIf

If lRet
	//Adiciona o numero do item
	AAdd(aItCopia,{"ADF_ITEM",StrZero(1,TamSx3("ADF_ITEM")[1]),Nil}) 
	
	//Forca a copia da observacao, inserindo o texto da copia
	If (nPosIncide := aScan(aCabec,{|x| AllTrim(x[4]) == "ADE_INCIDE"})) > 0
		aCabec[nPosIncide,3] := "[" + cTexto +" "+ cChamado + "]" + IIf(aCabec[nPosIncide,1],CRLF + aCabec[nPosIncide,3],"")
		aCabec[nPosIncide,1] := .T.
	EndIf 
	
	//Cria o array do cabecalho
	For nX := 1 to Len(aCabec)
		If aCabec[nX,1]
			AAdd(aCabCopia,{aCabec[nX,4],aCabec[nX,3],aCabec[nX,6]})
		EndIf
	Next nX
	
	//Cria o array dos itens
	For nX := 1 to Len(aItens)
		If aItens[nX,1]
			AAdd(aItCopia,{aItens[nX,4],aItens[nX,3],aItens[nX,6]})
		EndIf
	Next nX
EndIf

RestArea(aAreaADE)
RestArea(aAreaADF)
RestArea(aAreaSX3)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLoadInfo  บAutor  ณVendas CRM          บ Data ณ  16/06/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega os dados do chamado a ser copiado                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบParametrosณEXPC1 - Nome da tabela a ser copiada                        บฑฑ
ฑฑบ          ณEXPC2 - Codigo do chamado a ser copiado                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LoadInfo(cTabela,cChamado)
                     
Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->(GetArea())
Local aRet 		:= {}
Local cCampo	:= ""
Local cMemo		:= ""
Local aCposNao	:= {"ADE_CODIGO","ADE_REGSLA","ADE_DTEXPI","ADE_SEVSLA","ADE_FNCFIL","ADE_FNC",;
					"ADE_FNCREV","ADE_CHANEX","ADE_DATA","ADE_HORA","ADF_CODIGO","ADF_DATA",;
					"ADF_HORA","ADF_FNC","ADF_FNCREV","ADF_ITEM","ADF_CODSU7","ADF_CODSU0",;
					"ADF_HORAF"}

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek(cTabela)

DbSelectArea(cTabela)
DbSetOrder(1)
MsSeek(xFilial(cTabela)+cChamado)

While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == cTabela
	
	cCampo := AllTrim(SX3->X3_CAMPO)
	
	If 	X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .AND. SX3->X3_CONTEXT <> "V" .AND.;
		aScan(aCposNao,cCampo) == 0
		
		AAdd(aRet,{	!Empty((cTabela)->&(cCampo))	,;	//Marcado/desmarcado
					 X3Titulo()						,;	//Titulo
					 (cTabela)->&(cCampo)			,;	//Valor
					 cCampo			   				,;	//Nome do campo
					 SX3->X3_ORDEM					,;	//Ordem do campo	
					 SX3->X3_VALID					})	//Validacao
		
	EndIf

	SX3->(DbSkip())

End

//Acrescenta o memo 'manualmente'
If cTabela == "ADE"
	SX3->(DbSetOrder(2))
	If SX3->(DbSeek("ADE_INCIDE"))
		cMemo := MSMM( ADE->ADE_CODINC, TamSx3("ADE_INCIDE")[1] )
		AAdd(aRet,{	!Empty(cMemo),;
					X3Titulo(),;
					cMemo,;
					"ADE_INCIDE",;
					SX3->X3_ORDEM,;
					SX3->X3_VALID})
	EndIf
ElseIf cTabela == "ADF"
	SX3->(DbSetOrder(2))
	If SX3->(DbSeek("ADF_OBS"))
		cMemo := MSMM( ADF->ADF_CODOBS, TamSx3("ADF_OBS")[1] )
		AAdd(aRet,{	!Empty(cMemo),;
					X3Titulo(),;
					cMemo,;
					"ADF_OBS",;
					SX3->X3_ORDEM,;
					SX3->X3_VALID})
	EndIf
EndIf

//Ordena os campos
aSort(aRet,,,{|x,y|x[5] < y[5]})

RestArea(aAreaSX3)
RestArea(aArea)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk510SetGrบAutor  ณVendas CRM          บ Data ณ  28/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAjusta o grupo do operador para o grupo do chamado atual    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk510SetGr(cCodLinha,cGrpAnt)

Local aArea		:= GetArea()
Local aAreaADE	:= ADE->(GetArea())
Local aAreaSU0	:= SU0->(GetArea())
Local cOperador	:= TkOperador()

DEFAULT cCodLinha := ""

DbSelectArea("ADE")
DbSetOrder(1)

If MsSeek(xFilial("ADE") + cCodLinha)

	DbSelectArea("SU7")
	DbSetOrder(1)
	
	If MsSeek(xFilial("SU7")+cOperador) .AND. SU7->U7_POSTO <> ADE->ADE_GRUPO

		cGrpAnt	:= SU7->U7_POSTO

		RecLock("SU7",.F.)
		SU7->U7_POSTO := ADE->ADE_GRUPO
		MsUnLock()

	EndIf

EndIf

RestArea(aAreaSU0)
RestArea(aAreaADE)
RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMKA510A  บAutor  ณMicrosiga           บ Data ณ  28/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRestaura o codigo do grupo anterior do operador             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk510RstGr(cGrpAnt)

Local aArea		:= GetArea()
Local aAreaSU7	:= SU7->(GetArea())
Local cOperador	:= TkOperador()

DbSelectArea("SU7")
DbSetOrder(1)

If MsSeek(xFilial("SU7")+cOperador)
	RecLock("SU7",.F.)
	SU7->U7_POSTO := cGrpAnt
	MsUnLock()
EndIf

RestArea(aAreaSU7)
RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณTk510WindLogบAutor  ณ Vendas CRM        บ Data ณ  22/09/10  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Lista os chamados que nใo foram processados.               บฑฑ
ฑฑบ		     ณ   								                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk510WindLog(cMsg)

Local cFile   := ""
Local cMask   := STR0173	//"Arquivos Texto (*.TXT) |*.txt|" 
Local cTexto  := ""
Local oFont
Local oDlg
Local oMemo
Local lHtml	  := IsHtml() //Indica se e remote HTML	


DEFAULT cMsg := ""

cTexto := STR0174 + CRLF + CRLF + cMsg		//"Os chamados listados abaixo nใo foram processados, pois encontram-se em atendimento."

DEFINE FONT oFont NAME "Mono AS" SIZE 6,15
DEFINE MSDIALOG oDlg TITLE "Help Desk" From 3,0 to 340,465 PIXEL
@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 225,145 OF oDlg PIXEL
oMemo:bRClicked := {||AllwaysTrue()}
oMemo:oFont:=oFont
DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL

If !lHtml // quando utilizado o remote html nao e possivel acessar os diretorios locais
	//Salva o arquivo somente em diret๓rios locais da esta็ใo, ignorando os diret๓rios do servidor (ROOTPATCH)
	DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,"",,,.F.,GETF_LOCALHARD,.F.),If(cFile="",.T.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL
EndIf

ACTIVATE MSDIALOG oDlg CENTER

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณTk510WindLogบAutor  ณ Vendas CRM        บ Data ณ  22/09/10  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Lista os chamados que nใo foram processados.               บฑฑ
ฑฑบ		     ณ   								                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TK510OPERA()

Local cCodOp := ""

If ( Type("lTk503Auto") <> "U" .AND. lTk503Auto )
	cCodOp := Space(TamSX3("U7_COD")[1])
Else
	cCodOp := TKOPERADOR()
EndIf

Return cCodOp

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัอออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณTk510VerButtonบAutor  ณ Vendas CRM      บ Data ณ  23/03/11  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯอออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se determonada fun็ใo, existe no cadastro de      บฑฑ
ฑฑบ		     ณ bot๕es do modelo de atendimento.	                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk510VerButton(cButton,cModAtend)

Local lRet 		:= .F.
Local cCodBlock := ""

If !Empty(cModAtend)
	If cButton == "Associar"
		cCodBlock := "TK510FNDCAL"
	ElseIf cButton == "Transf.Grupo"
		cCodBlock := "TK510TRANSFAT"
	EndIf
	dbSelectArea("SKJ")
	dbSetOrder(2)
	If SKJ->(dbSeek(xFilial("SKJ")+cModAtend))
		While SKJ->(!Eof()) .And. cModAtend == SKJ->KJ_CODTELE
			If cCodBlock $ SKJ->KJ_CDBLOCK
				lRet := .T.
				Exit
			EndIf
			SKJ->(dbSkip())
		EndDo
	EndIf   
Else
	lRet := .T.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัอออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณTK510SelOp    บAutor  ณ Vendas CRM      บ Data ณ  21/10/11  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯอออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a busca no array com os peradores e seleciona      บฑฑ
ฑฑบ		     ณ na combobox o operador encontrado                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบExp	     ณ Exp1 : Chave digitada no campo      						  บฑฑ
ฑฑบ		     ณ Exp2 : Objeto do comboBox                                  บฑฑ
ฑฑบ		     ณ Exp3 : Array com os operadores                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION TK510SelOp(cChavPes,oCombo,aItems)

Local nPos 		:= 0 
Local nTam 		:= 0

If !Empty(cChavPes)   
	nPos := aScanx(aItems,{|x| Upper(Alltrim(cChavPes)) == Substr(Upper(x),TamSX3("AG9_CODSU7")[1]+2,Len(Upper(Alltrim(cChavPes))))})
	
	If nPos > 0
		oCombo:Select(nPos)
	Else
		Alert(STR0185)	//"Operador nใo encontrado. Digite novamente"
	EndIf 
EndIf                                                                               

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัอออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณREGSLAPAI     บAutor  ณ Vendas CRM      บ Data ณ  16/04/12  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯอออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a busca pelo registro de SLA do chamado principal  บฑฑ
ฑฑบ		     ณ para a montagem da legenda.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ Par1 : Codigo do chamado principal 						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function REGSLAPAI(cChamado,cChamadoPai,cFilPai)

Local aRegSLA		:= {}
Local cQuery		:= ""
Local cAlias		:= GetNextAlias()
Local lVectoPai		:= .F.
Local lVectoAvo		:= .F.
Local lFlChan 		:= .T.

Default cFilPai		:= cFilAnt

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBusca dados do registro paiณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery:= "SELECT "
cQuery+= " ADE_FILIAL FILIAL, ADE_REGSLA NEWREG, ADE_CHANEX CHANEX	"
If lFlChan
	cQuery+= ", ADE_FLCHAN FLCHAN "	
EndIf	
cQuery+= "FROM " + RetSQLName("ADE") + " ADE "
cQuery+= "WHERE ADE.ADE_FILIAL = '" + cFilPai + "' "
cQuery+=		" AND ADE.ADE_CODIGO = '" + cChamadoPai +"' "
cQuery+=		" AND ADE.D_E_L_E_T_ = ' ' "

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

If !Empty((cAlias)->CHANEX)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCaso o pai esteja associado, verifica vencimento com o outro chamadoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู			
	If lFlChan .AND. !Empty((cAlias)->FLCHAN)
		lVectoAvo := TK510CPSK5(cChamadoPai,(cAlias)->CHANEX,(cAlias)->FLCHAN)		
	Else	
		lVectoAvo := TK510CPSK5(cChamadoPai,(cAlias)->CHANEX,cFilPai)
	EndIf	
	
	If lVectoAvo
	
		If lFlChan .AND. !Empty((cAlias)->FLCHAN)
			lVectoAvo := TK510CPSK5(cChamado,(cAlias)->CHANEX,(cAlias)->FLCHAN)		
		Else	
			lVectoAvo := TK510CPSK5(cChamado,(cAlias)->CHANEX,cFilPai)
		EndIf	
	
	Else
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica vencimento com o chamado pai ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		lVectoPai := TK510CPSK5(cChamado,cChamadoPai,cFilPai,,.T.)
	EndIf				

Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica vencimento com o chamado pai ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	lVectoPai := TK510CPSK5(cChamado,cChamadoPai,cFilPai)
EndIf

If !lVectoPai .AND. !lVectoAvo
	aAdd(aRegSLA,xFilial("ADE"))
	aAdd(aRegSLA,ADE->ADE_REGSLA)		

ElseIf lVectoPai
	aAdd(aRegSLA,(cAlias)->FILIAL)
	aAdd(aRegSLA,(cAlias)->NEWREG)	 

ElseIf lVectoAvo
	
	If lFlChan .AND. !Empty((cAlias)->FLCHAN)
		aRegSLA := REGSLAPAI(cChamado,(cAlias)->CHANEX,(cAlias)->FLCHAN)		
	Else	
		aRegSLA := REGSLAPAI(cChamado,(cAlias)->CHANEX,cFilPai)
	EndIf		

EndIf 	

(cAlias)->(dbCloseArea())

Return(aRegSLA)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัอออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณTK510ATURP    บAutor  ณ Totvs		 บ Data ณ  11/03/13  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯอออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta tela de atualizacaoo rapida do chamado.				  บฑฑ
ฑฑบ		     ณ 									                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ 															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/       
Function TK510ATURP()
Local lRet 		:= .F. //Variavel de Retorno da pergunta 
Local lCampos 	:= .F. //Variavel que libera os campos para editar
Local lGrav 	:= .F. //Retorno da fun็ใo de grava็ใo
Local oDlgAtu          
Local cCodCham 	:= ADE->ADE_CODIGO					 //Codigo do Chamado
Local cCodOcor	:= SPACE(tamsx3("ADF_CODSU9")[1]) 	//Codigo da Ocorrencia
Local cDescOcor := SPACE(tamsx3("UQ_DESC")[1]) 		//Descricao da Ocorrencia
Local cCodAcao 	:= SPACE(tamsx3("ADF_CODSUQ")[1]) 	//Codigo da Acao
Local cDescAcao := SPACE(tamsx3("UQ_DESC")[1]) 		//Descricao da Acao     
Local cIndident	:= SPACE(tamsx3("ADF_OBS")[1]) 		//Codigo do Chamado  
Local oMemo

INCLUI := .F.
ALTERA := .T.

RegToMemory ( "ADF" , .F.,.T. ) 

SU9->(dbSetorder(2))                  
	lRet := MsgNoYes (STR0213 , STR0214  ) // "Deseja fazer uma Atualiza็ใo Rแpida no Chamado?", "Aualiza็ใo Rแpida"  
  	If lRet
		DEFINE MSDIALOG oDlgAtu FROM 0,0 TO 250,310 PIXEL TITLE STR0214  
				
	   	@ 05,10 SAY STR0222 SIZE 90,15 OF oDlgAtu PIXEL //"Chamado"
	   	@ 05,40 MSGET cCodCham   SIZE  40, 8 PIXEL  OF oDlgAtu 
	   	@ 20,10 SAY STR0143  SIZE 90,15 OF oDlgAtu PIXEL //"Ocorr๊ncia:"
	   	@ 20,40 MSGET cCodOcor   F3 "SU9" SIZE  40, 8 PIXEL VALID cDescOcor:= Posicione("SU9",2,xFilial("SU9")+cCodOcor,"U9_DESC") OF oDlgAtu When lCampos
	   	@ 20,85 MSGET cDescOcor  SIZE  65, 8 PIXEL OF oDlgAtu When .F. 
	   	@ 35,10 SAY STR0215 SIZE 90,15 OF oDlgAtu PIXEL //"A็ใo:"
	   	@ 35,40 MSGET cCodAcao   F3 "SUQ" SIZE  40, 8 PIXEL VALID cDescAcao:= fDesc("SUQ",cCodAcao,"UQ_DESC") OF oDlgAtu When lCampos
	   	@ 35,85 MSGET cDescAcao  SIZE  65, 8 PIXEL OF oDlgAtu When .F.   
	   	@ 50,09 SAY STR0216 SIZE 85,15 OF oDlgAtu PIXEL //"Observa็ใo:"
	   	@ 50,41 GET  oMemo VAR cIndident  MEMO SIZE  110, 50  PIXEL  OF oDlgAtu When lCampos  

		@ 05,85 BUTTON STR0217 SIZE 40,12 OF oDlgAtu PIXEL ACTION lCampos:=TK510VLCHAM (cCodCham) //"Consultar"
		@ 110,55 BUTTON STR0218 SIZE 40,12 OF oDlgAtu PIXEL ACTION (lGrav:=TK510ATUCHAM(cCodCham,cIndident,cCodOcor,cDescOcor,cCodAcao,cDescAcao,oDlgAtu),Iif (lGrav, oDlgAtu:End(),MsgAlert("O chamado nใo foi atualizado","Aualiza็ใo Rแpida"))) //"Atualizar" 
		@ 110,110 BUTTON STR0076 SIZE 40,12 OF oDlgAtu PIXEL ACTION oDlgAtu:End() //"Cancelar"	 
					
		ACTIVATE MSDIALOG oDlgAtu CENTER 

	EndIf
	
Return (lRet)                                                        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัอออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  TK510VLCHAM    บAutor  ณ Totvs		 บ Data ณ  11/03/13  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯอออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo do codigo do chamado.							  บฑฑ
ฑฑบ		     ณ 									                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ Par1 : Codigo do chamado principal 						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TK510VLCHAM (cCodCham)

Local lRet := .F.  // Variavel de retorno

If Len(cCodCham)>0
	dbSelectArea("ADE")
	dbSetOrder(1)
	If dbSeek(xFilial("ADE")+cCodCham)
		lRet:=.T.
	Else
		lRet:= .F.
		MsgAlert(STR0219 ,STR0214)//"Chamado nใo existe.","Atualiza็ใo Rแpida"
	EndIf 
EndIf   
   
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัอออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  TK510ATUCHAM   บAutor  ณ Totvs		 บ Data ณ  11/03/13  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯอออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Salva a atualiza็ใo										  บฑฑ
ฑฑบ		     ณ 									                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ Par1 : Codigo do chamado principal 						  บฑฑ
ฑฑบ 		 ณ Par2 : Observacao				 						  บฑฑ
ฑฑบ 		 ณ Par3 : Codigo da ocorrencia								  บฑฑ
ฑฑบ 		 ณ Par4 : Descricao da ocorrencia							  บฑฑ 
ฑฑบ 		 ณ Par5 : Codigo da acao									  บฑฑ
ฑฑบ 		 ณ Par6 : Descricao da acao									  บฑฑ
ฑฑบ 		 ณ Par7 : Obejeto de tela									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TK510ATUCHAM(cCodCham,cIndident,cCodOcor,cDescOcor,cCodAcao,cDescAcao,oDlgAtu) 

Local nUsado := 0  
Local lRet	 := .F.	// Variavel de retorno 

Local oObj		:= TeleServiceUserDialog():New()  
Local aRotina	:= {}  
Local cTeleServID := ""  
  
Local aAlterADF	:={}  
Local aKeyInfo := {}  
Local nI := 0   
local laCols := .F.  
lAcao := .F.
   
Private	ParamIXB := {} 
Private oGetd 

Public cIncMemo :=	""
Public cIncOBS  :=	""

aHeader:={}
aCols:={}




DbSelectArea("ADE")
DbSetOrder(1)

If dbSeek(xFilial("ADE")+cCodCham) 	


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCarrega dados da tabela ADE  ณ
   	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	RegToMemory ( "ADE" , .F.,.T. ) 
	
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("ADE")
		
	While !Eof() .AND. (X3_ARQUIVO == "ADE")

   			If x3Uso(X3_USADO) .And.  X3_CONTEXT == "R"
				M->&(AllTrim(SX3->X3_CAMPO)):= ADE->&(AllTrim(SX3->X3_CAMPO))
			EndIf
		DbSkip()
	End
	
	M->ADE_INCIDE := MSMM(ADE->ADE_CODINC)

	If !Empty(cCodOcor)  

		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCarrega aHeader ณ
	   	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("ADF")

		While !Eof() .AND. (X3_ARQUIVO == "ADF")

   			If x3Uso(X3_USADO) 
				nUsado++
		
				Aadd(aHeader,{	X3TITULO(),;			// 01
								X3_CAMPO,;				// 02
								X3_PICTURE,;			// 03
								X3_TAMANHO,;			// 04
								X3_DECIMAL,;			// 05
								X3_VALID,;				// 06
								X3_USADO,;				// 07
								X3_TIPO,;				// 08
						   		X3_ARQUIVO,;			// 09
								X3_CONTEXT,;			// 10
								X3_PROPRI 	} )			// 11
   			Endif 
   			If SX3->X3_VISUAL <> "V"
				Aadd(aAlterADF, AllTrim(SX3->X3_CAMPO) )
			EndIf
			DbSkip()
		End
		        
		// Inclui coluna de registro atraves de funcao generica
		ADHeadRec("ADF", aHeader) 
		nUsado += 2 
		
		dbSelectArea("ADF")
		dbSetOrder(1)
		

         
   		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCarrega campos MEMO para a grava็ใo ณ
	   	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       	 cIncMemo := MSMM(ADE->ADE_CODINC)
       	 cIncOBS 	:= MSMM(ADF->ADF_CODOBS )


		oObj:service := TeleServicing():New() 
		 
		
		cTeleServID := oObj:GetModel() 
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณFaz load nos dados ณ
	   	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   		oObj:service:load(cTeleServID) 
   		
   		For nI := 1 To Len(oObj:service:tableStructureInfo:master:PkFields)
			aAdd(aKeyInfo, oObj:service:tableStructureInfo:master:PkFields[nI]:name )
		Next nI 
		
		oObj:LoadInformation(4, aKeyInfo)  
   		
   		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCarrega o aCols ณ
	   	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   		laCols:= oObj:Tk503ACols()
	 

        ParamIXB := { aHeader, aCols, 4 } 
       
				 
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAdiciona linha no aCols ณ
	   	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Tk510IncAcols(cCodOcor, cIndident, cCodAcao, M->ADE_OPERAD,/*ADE->ADE_ASSUNT*/,/*ADE->ADE_CODSB1*/, ADE->ADE_GRUPO, ADE->ADE_CODCAT,ADE->ADE_CODORI1, ADE->ADE_CODCAU, ADE->ADE_CODEFE, ADE->ADE_CODCAM,.T.	)   	
               
       
       If Len(ParamIXB) <> 0
         	 
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza a hora final do chamado ณ
	   		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       		TK510GRVIT()    
       	

       		oGetd := 	MsNewGetDados():New(1,1,1,1,IIf(!INCLUI.And.!ALTERA,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
				"Tk503ALinOk",;
				"Tk503ATudOk",;
				IIf(!Empty(oObj:service:tableStructureInfo:initGDField:name),"+"+oObj:service:tableStructureInfo:initGDField:name,""),;
				aAlterADF,/*nFreeze*/,999,/*cFieldOk*/,/*uSuperDel*/,/*uDelOk*/,oDlgAtu,aHeader,aCols) 
			   
	   		aGets:={}
			aTela:={} 
			oGetD:TudoOk()
		    

		   	dbSelectArea("SUR")
			SUR->(dbSetOrder(1))
			If dbSeek (xFilial("SUR")+cCodOcor)
				While SUR->(!EOF()) .AND. SUR->UR_CODREC == cCodOcor
   			   		If SUR->UR_CODSOL == cCodAcao
		   				lAcao:=.T. 
		   				Exit
   					EndIf 
   			   		SUR->(DbSkip())
   		   		End
   			EndIf 
			
		   	If lAcao
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	   			//ณCarrega dados para a gravacao ณ
	   			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู						
				If oObj:bOk(oGetd, 4, .F., ADE->ADE_DATA)
		        		
					oObj:service:tableStructureInfo:save()

	   		   		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณAtualiza a hora final do chamado ณ
	   				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	   	   			ADF->(dbSetOrder(1))
	   	   			If dbSeek(xFilial("ADF")+cCodCham+aCols[len(aCols)][1])
						If Empty(ADF->ADF_HORAF)
							RecLock("ADF", .F.)
							REPLACE ADF->ADF_HORAF WITH Time()
							MsUnlock() 									
						EndIf
   					EndIf 
   					lRet:= .T.
       	       	EndIf
       	   	Else
       	   		Aviso(STR0214, STR0220 , {STR0122}) //"Aten็ใo" # "Essa a็ใo nใo pertence a essa ocorr๊ncia","Ok"
		   	EndIf
		EndIf
	EndIf 
Else 
	MsgAlert(STR0221 ,STR0214 )//"Chamado nใo cadastrado.","Atualiza็ใo Rแpida"
EndIf 
 	
Return (lRet)       


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัอออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณTK510EXCEL    บAutor  ณ Vendas CRM      บ Data ณ  30/12/12  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯอออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Geracao de Excel dos dados do service desk                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aHeader  > aHeader do Service desk                         บฑฑ
ฑฑบ          ณ aCols    > aCols   do Service desk                         บฑฑ
ฑฑบ          ณ oObjDesk > Objero do Service desk                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function TK510EXCEL(aHeader, aCols, oObjDesk) 
Local cDirLocal := GETTEMPPATH() //Diretorio temporario de trabalho na maquina local do usuแrio.
Local cArquivo := "Planinha_ServiceDesk_"+Alltrim(Substr(cUsuario,7,15))+".CSV" 
Local	lProcessa := .T.
Local nHandle   := 0

if MsgYesNo(STR0200) // "Deseja gerar a planilha Excel dos dados do Service Desk ?"
	if File(cDirLocal+cArquivo)
		if ! MsgYesNo(STR0201+cDirLocal+cArquivo+" ?") // "Deseja sobrescrever o arquivo "
			lProcessa := .F.
		Endif
			
		if lProcessa 
			Ferase(cDirLocal+cArquivo)
			if File(cDirLocal+cArquivo)
				MsgAlert(STR0202+cDirLocal+cArquivo+". "+STR0203) // "Nao foi possivel apagar o arquivo "###"Verifique se o mesmo nao esta em uso."
				lProcessa := .F.
			Endif
		Endif		
	Endif
	
	if lProcessa 	
		nHandle   := FCreate(cDirLocal + "\" + cArquivo)
		if nHandle <= 0
			MsgAlert(STR0204+cDirLocal+cArquivo+". "+STR0205) // "Nao foi possivel criar o arquivo "###"Verifique se voce tem permissao para criacao do arquivo."
	   Else
			Processa( {|| TK510GERXLS(aHeader, aCols, cDirLocal, cArquivo, nHandle, oObjDesk) }, STR0206, STR0207) // "Gerando Excel"###"Aguarde..." 
		Endif	
	Endif	
Endif

Return



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณTK510GERXLS    บAutor  ณ Vendas CRM      บ Data ณ  06/12/12 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Processa os dados do Service Desk e gera uma planilha      บฑฑ
ฑฑบ		    ณ contendo todas as informacoes apresentadas.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aHeader  : aHeader do Service Desk                         บฑฑ
ฑฑบ          ณ aCols    : aCols do Service Desk                           บฑฑ
ฑฑบ          ณ cDirLocal: Diretorio para criacao da planilha              บฑฑ
ฑฑบ          ณ cArquivo : Nome do arquivo a ser gerado                    บฑฑ
ฑฑบ          ณ nHandle  : numero do arquivo fisico                        บฑฑ
ฑฑบ          ณ oObjDesk : objeto do service desk                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function TK510GERXLS(aHeader, aCols, cDirLocal, cArquivo, nHandle, oObjDesk)
Local cLinha		:= ""
Local aXls			:= {}
Local nPosCod   	:= Ascan(aHeader,{|x| AllTrim(x[2]) == "ADE_CODIGO" })  
Local nPosSemaforo:= Ascan(aHeader,{|x| AllTrim(x[2]) == "SEMAFORO" })
Local nPosSLA 		:= Ascan(aHeader,{|x| AllTrim(x[2]) == "SLA" })
Local nPosWF 		:= Ascan(aHeader,{|x| AllTrim(x[2]) == "WF" })
Local aCores		:= oObjDesk:DialogLabel(.F.)
Local nA
Local nB
Local nElem
Local nMaxRows := oObjDesk:nMaxRowsPerPage // guarda o numero de registros por pagina
Local cPage 	:= oObjDesk:cPagePos        // pagina posicionada no momento
Local nRecno	:= oObjDesk:nRecnoPos       // registro posicionada no momento
Local aColsAnt := aClone(oObjDesk:aColsADE)

Private cSeparador := Chr(10)+Chr(13) // " | "  // separador de linha

Default cDirLocal := GETTEMPPATH() //Diretorio temporario de trabalho na maquina local do usuแrio.
Default cArquivo  := "Planinha_ServiceDesk_"+Alltrim(Substr(cUsuario,7,15))+".CSV" 
Default nHandle   := FCreate(cDirLocal + "\" + cArquivo)

nPosSemaforo:= Ascan(aHeader,{|x| AllTrim(x[2]) == "SEMAFORO" })
nPosSLA		:= Ascan(aHeader,{|x| AllTrim(x[2]) == "SLA" })
nPosWF		:= Ascan(aHeader,{|x| AllTrim(x[2]) == "WF" })

// executa a atualizacao do acols com o maximo possivel de linhas
IncProc(STR0206)  // "Gerando Excel"
oObjDesk:nMaxRowsPerPage := 9999 // seta o maximo por pagina para 9999
oObjDesk:cPagePos := "1  "       // pagina posicionada no momento
oObjDesk:aColsADE := {}
oObjDesk:Tk510ProACols(.T.)

// aHeader
cLinha := ""
For nA := 1 to Len(aHeader)
	if ! Empty(aHeader[nA,1])  // nao inclui colunas que tem o aheader em branco
		cLinha += aHeader[nA,1] + ";"
	Endif	
Next
cLinha+="Incidentes;Interacoes;"  

Fwrite(nHandle, cLinha+Chr(13)+Chr(10))

//oObjDesk:Tk510Filtra()                                              
//While (oObjDesk:cTabelaAux)->(!EOF()) 
//
//	(oObjDesk:cTabelaAux)->( Dbskip())
//Enddo

For nA := 1 to Len(aCols)
	cLinha := ""
	For nB := 1 to Len(aCols[nA])-1
		if Empty(aHeader[nB,1]) // nao inclui colunas que tem o aheader em branco
			Loop
		Endif
		if nB == nPosSemaforo .and. Len(aCores) >= 1
			nElem := Ascan(aCores[1,2] ,{|e| e[1] == aCols[nA,nB] })
			if nElem > 0
				aCols[nA,nB] := aCores[1,2,nElem,2]
			Endif	
		Elseif nB == nPosSLA .and. Len(aCores) >= 2
			nElem := Ascan(aCores[2,2] ,{|e| e[1] == aCols[nA,nB] })
			if nElem > 0
				aCols[nA,nB] := aCores[2,2,nElem,2]
			Endif	
		Elseif nB == nPosWF .and. Len(aCores) >= 3
			nElem := Ascan(aCores[3,2] ,{|e| e[1] == aCols[nA,nB] })
			if nElem > 0
				aCols[nA,nB] := aCores[3,2,nElem,2]
			Endif	
      Endif

		cCelula := ToXlsFormat(aCols[nA,nB])
//		cCelula := StrTran(cCelula,'"',"")  // elimina as aspas pois estava dando gerando referencia circular quando tinha o sinal de menos
//		cLinha += if(ValType(aCols[nA,nB]) == "C","'","")+cCelula + ";"  // coloco um apostrofe para que o excel entenda que e texto
      
		if Len(aHeader) > nB .and. Upper(Alltrim(aHeader[nB,2])) == "HSLA" 
			cCelula := Strtran(StrTran(cCelula,'"',''),":",",")
//			if Substr(cCelula,1,1) == '-'
//				cCelula := Substr(cCelula,2,Len(cCelula)-1)+"-"
//			Else
//				cCelula := Substr(cCelula,2,Len(cCelula)-1)+"+"
//			Endif	
		Endif	
		cLinha += cCelula + ";"
	Next

	CarregaDetalhes(aHeader, aCols[nA,nPosCod], @cLinha)

//	cLinha := Strtran(cLinha, Chr(13), "")
////	cLinha := Strtran(cLinha, Alltrim(cSeparador), "\")
//	cLinha := Strtran(cLinha, Chr(10), cSeparador)

	Fwrite(nHandle, cLinha+Chr(13)+Chr(10))
Next	

Fclose(nHandle)

// Carrega o arquivo .CSV via linha de comando.
ShellExecute("Open",cDirLocal + cArquivo,"",cDirLocal, 5 ) //SW_SHOW
//Ferase(cDirLocal + "\" + cArquivo)

// executa a atualizacao do acols com o limite de linhas atual
oObjDesk:nMaxRowsPerPage	:= nMaxRows		// restaura o limite de linhas por pagina

Return Nil



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณCarregaDetalhesบAutor  ณ Vendas CRM      บ Data ณ  06/12/12 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega as informacoes de incidente e interacao para a     บฑฑ
ฑฑบ		    ณ linha do arquivo CSV                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aHeader  : aHeader do Service Desk                         บฑฑ
ฑฑบ          ณ cCodLinha: Codigo do chamado                               บฑฑ
ฑฑบ          ณ cLinha   : Linha a ser gravada                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function CarregaDetalhes(aHeader, cCodLinha, cLinha)
Local aArea := {ADE->( GetArea("ADE")), ADF->( GetArea("ADF")), GetArea()}
Local cMemo		:= "" // Informacoes do MEMO
Local cInteracao := ""
Local nA

Local nTamInt := SuperGetMv("MV_TMKGXLS",,32000)

Default cLinha   := ""

//Tamanho nใo pode passar de 32000, iremos garantir o tamanho da intera็ใo
If nTamInt > 32000
	nTamInt := 32000
EndIf

// carrega o incidente
ADE->(DbSetOrder(1))
If ADE->( MsSeek( xFilial("ADE")+cCodLinha ))
	cInteracao := MSMM( ADE->ADE_CODINC, TamSx3("ADE_INCIDE")[1] )
	cInteracao := Strtran(cInteracao,Chr(10),Chr(10)+Chr(13))
	cInteracao := Strtran(cInteracao,'"',"'")
	If Len(cInteracao) > nTamInt
		cInteracao := SUBSTR(cInteracao,1,nTamInt)+Chr(10)+Chr(13)+STR0223
	EndIf
	cLinha += '"'+cInteracao + '";'
Else
	cLinha += " ;"	
Endif

// Method LoadDetalhes() Class HelpDeskListDialog
DbSelectArea("ADF")
If !Empty(ADF->(IndexKey()))
	ADF->(DbSetOrder(1))
	If !Empty(cCodLinha) .AND. MsSeek( xFilial("ADF")+cCodLinha )
		cInteracao := ""
		While ADF->(!EOF() .AND. ADF_FILIAL+ADF_CODIGO == xFilial("ADF")+cCodLinha)
			cMemo := Alltrim(MSMM( ADF->ADF_CODOBS, TamSx3("ADF_OBS")[1] ))
			If Len(cMemo) > nTamInt
				cMemo := SUBSTR(cMemo,1,nTamInt)+Chr(10)+Chr(13)+STR0223
   			EndIf
			cInteracao += '['+STR0188+ADF->ADF_ITEM+"]"+cSeparador
			cInteracao += STR0189+" "+ADF->ADF_CODSU9+" - "+Alltrim(Upper(POSICIONE("SU9",2,xFilial("SU9")+ADF->ADF_CODSU9,"U9_DESC")))+cSeparador
			cInteracao += STR0190+" "+ADF->ADF_CODSUQ+" - "+Upper(POSICIONE("SUQ",1,xFilial("SUQ")+ADF->ADF_CODSUQ,"UQ_DESC"))+cSeparador
			cInteracao += STR0191+" "+ADF->ADF_CODSU7+" - "+Capital(POSICIONE("SU7",1,xFilial("SU7")+ADF->ADF_CODSU7,"U7_NOME"))+cSeparador
			cInteracao += STR0192+" "+ADF->ADF_CODSU0+" - "+POSICIONE("SU0",1,xFilial("SU0")+ADF->ADF_CODSU0,"U0_NOME")+cSeparador
			cInteracao += STR0193+" "+DTOC(ADF->ADF_DATA)+"  "+STR0194+" "+ADF->ADF_HORA+" | "+STR0195+" "+ADF->ADF_HORAF+cSeparador
			cInteracao += STR0196+" "+If(!Empty(cMemo),cMemo,STR0197)+' '+cSeparador
			cInteracao := Strtran(cInteracao,'"',"'")
			
			ADF->(DbSkip())
		Enddo
		cLinha += '"'+Strtran(cInteracao,";","/")+'"'
		
	EndIf
EndIf

For nA := 1 to Len(aArea)
	RestArea(aArea[nA])
Next

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณIntToHoraTmk ณ Autor ณ Vendas CRM		    ณ Data ณ 08.05.14 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Converte Inteiro em Horas                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ ExpC1: String no Formato "HH:MM"                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpN1: Numero de Horas                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function IntToHoraTmk(nHora,nDigitos)

Local nHoras    := 0 
Local nMinutos  := 0 
Local cHora     := ""             
Local lNegativo := .F.

lNegativo := ( nHora < 0 ) 
nHora     := ABS( nHora ) 
nHoras    := Int(nHora)
nMinutos  := (nHora-nHoras)*60										
nDigitos := If( ValType( nDigitos )=="N", nDigitos, 2 ) - If( lNegativo, 1, 0 ) 
cHora := If( lNegativo, "-", "" ) + StrZero( nHoras, nDigitos )+":"+StrZero( nMinutos, 2 )

Return(cHora)

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta fun็ใo deve utilizada somente ap๓s 
    a inicializa็ใo das variaveis atravez da fun็ใo FATPDLoad.
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, L๓gico, Retorna se o campo serแ ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Fun็ใo que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUserAcc
    @description
    Verifica se o usuario logado possui acesso a dados sensiveis e pessoais
    Exibindo mensagem de Help caso usuario nใo possua acesso.
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

    @type  Function
    @sample FATPDUserAcc()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Retorna se Usuario possui acesso a dados protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDUserAcc()

    Local lRet := .T.  

    If FATPDActive()
        lRet := FTPDUserAcc()
    Endif

Return lRet
