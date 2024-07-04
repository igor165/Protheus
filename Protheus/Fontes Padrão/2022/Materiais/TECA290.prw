#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA290.CH"

#DEFINE VT_CODVIS  1
#DEFINE VT_VISTOR	2
#DEFINE VT_VNOME	3
#DEFINE VT_DTINI	4
#DEFINE VT_HRINI	5
#DEFINE VT_DTFIM	6
#DEFINE VT_HRFIM	7                

#DEFINE P_MARCA		1
#DEFINE P_PROPOS	2
#DEFINE P_PREVIS	3
#DEFINE P_OPORTU	4
#DEFINE P_ENTIDA	5                 
#DEFINE P_CODENT	6 
#DEFINE P_NOMENT	7
#DEFINE P_LOJENT	8
#DEFINE P_EMISSA	9
#DEFINE P_VISTEC	10
#DEFINE P_SITVIS	11

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas na funcao At290Busca. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Static nStartLine		// Controle de proxima procura
Static nStartCol		// Coluna inicial
   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTECA290	บAutor  ณVendas CRM          บ Data ณ  20/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณWizard solicitacao de vistoria tecnica.                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro / Falso 		                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum								                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA290                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/            
Function TECA290()

Local lRetorno  := .T.   							// Retorno da Validacao
Local lMultVist := SuperGetMv("MV_MULVIST",,.F.)   // Multipla Vistorias

	
If AD1->AD1_STATUS == "1"	
	If !lMultVist
		
		If AD1->AD1_VISTEC == "1"
			If AD1->AD1_SITVIS = "1"
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ	 Problema: Existe uma vistoria t้cnica em aberto para essa oportunidade de venda. 	   			                ณ
				//ณ	 Solucao: Verifique com vistoriador responsแvel por esta vistoria t้cnica a conclusใo ou cancelamento da mesma. ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				lRetorno := .F.
				Help("",1,"AT290OPOAB")
			ElseIf AD1->AD1_SITVIS = "2"
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ	 Problema: Existe uma vistoria t้cnica agendada para essa oportunidade de venda. 	   			                ณ
				//ณ	 Solucao: Verifique com vistoriador responsแvel por esta vistoria t้cnica a conclusใo ou cancelamento da mesma. ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				lRetorno := .F.
				Help("",1,"AT290OPOAG")
			EndIf
		EndIf
	EndIf
	
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ	 Problema: Solicita็ใo de vistoria t้cnica somente para oportunidade de venda em aberto. ณ
	//ณ	 Solucao: Selecione uma oportunidade em aberto ou inclua uma nova oportunidade.			 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	lRetorno := .F.
	Help("",1,"AT290OPABR")
EndIf

If lRetorno .AND. !At290VerVt()       
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ	 Problema: Nใo hแ atendente com perfil de vistoriador. 					 									 ณ
	//ณ	 Solucao: No cadastro de atendente defina pelo menos um atendente como vistoriador para acessar esta rotina. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	lRetorno := .F.
	Help("",1,"AT290PVIST")
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ	Wizard solicitacao de vistoria tecnica.	ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRetorno
	At290Wrd()
EndIf

Return( lRetorno )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt290Wrd  บAutor  ณVendas CRM          บ Data ณ  20/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณWizard solicitacao de vistoria tecnica.                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro / Falso 		                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum								                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA290                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/             
Static Function At290Wrd()

Local cPVist		:= Space(50)											// Pesquisar vistoria.
Local cPProp		:= Space(50)          				   					// Pesquisar proposta.
Local cCbxPer		:= ""         						   					// Combo do periodo.
Local lFinalizar	:= .F.            					   					// Finaliza o wizard.
Local lRetorno		:= .F. 													// Retorno da validacao
Local lPanel		:= .T.    												// Define que sera criado um panel.
Local lNoFirst		:= .F.											   		// Exibe o painel de apresentacao.
Local lImpProp		:= .F.													// Importa proposta comercial?
Local lChkVTA		:= .T.  												// Orderna por Data Inicial + Hora Inicial (Default).
Local lChkVTB 		:= .F.													// Orderna por Vistoriador + Data Inicial + Hora Inicial.
Local oTFont17		:= TFont():New("Arial",,17,.T.,.T.)      				// Objeto TFont.
Local oTFont14		:= TFont():New("Arial",,14,.T.,.F.)     				// Objeto TFont.
Local cTitle 		:= STR0001 												// Assistente.  		 						   
Local cWizTitle		:= STR0002 												// Assistente para solicita็ใo de Vistoria Tecnica.    
Local cHMsg			:= STR0003 												// Solicitacao de Vistoria Tecnica.
Local cText 		:= STR0004 												// Este assistente ira auxiliar na solicitacao de vistoria tecnica para oportunidade de venda ou proposta comercial.
Local aBrwVis		:= {}													// Array com as vistorias agendadas
Local aCoord		:= {0,0,480,600} 										// Array contendo as coordenadas da tela.
Local aCbxIt 		:= {"",STR0005,STR0006,STR0007,STR0008,STR0009}      	// {"","5 dias","10 dias","15 dias","20 dias","30 dias"}
Local aPeriodo 		:= {0,5,10,15,20,30} 									// Periodo para filtro.	
Local aItens 		:= {STR0019,STR0020}         							// Solicitacao Manual / Solicitacao Automatica.      					 
Local aProposta		:= {} 													// Array com as propostas.
Local nRdSol   		:= 1 													// Solicitacao Manual (Default).
Local oRdSol		:= Nil 													// Objeto Say.
Local oSayS1		:= Nil                                                 	// Objeto Say. 
Local oSayS2		:= Nil													// Objeto Say. 
Local oSayA1    	:= Nil													// Objeto Say. 
Local oSayF1 		:= Nil                                           		// Objeto Say. 
Local oSayF2		:= Nil													// Objeto Say. 
Local oCbxPer		:= Nil 													// Objeto Combobox
Local oPanel		:= Nil													// Objeto Panel.
Local oWizard 		:= Nil													// Objeto ApWizard.
Local oOk			:= Nil													// Check Marcado.
Local oNo			:= Nil													// Check Desmarcado.
Local bVldBack		:= Nil													// Bloco de codigo a ser executado para validar o botao "Voltar".
Local bVldNext		:= Nil													// Bloco de codigo a ser executado para validar o botao "Avancar".
Local bFinish 		:= Nil													// Bloco de codigo a ser executado para validar o botao "Finalizar".
Local oModel		:= Nil   												// Modelo de dados.
Local oView			:= Nil      											// Interface.
Local oTGVis   		:= Nil  												// Objeto TGet.
Local oTGProp		:= Nil													// Objeto TGet.
Local oChkProp  	:= Nil   												// Objeto CheckBox.	
Local oBrwVis   	:= Nil													// Objeto TWBrowse.
Local oBrwProp		:= Nil  												// Objeto TWBrowse.
Local oChkVTA		:= Nil      											// Objeto CheckBox.	
Local oChkVTB		:= Nil    												// Objeto CheckBox.	
Local oBtAPesq  	:= Nil  												// Objeto TButton.
Local oBtAProx  	:= Nil													// Objeto TButton.
Local oBtPPesq  	:= Nil													// Objeto TButton.
Local oBtPProx  	:= Nil													// Objeto TButton.
Local bAgend		:= Nil
Local lMultVist 	:= SuperGetMv("MV_MULVIST",,.F.)   					// Multipla Vistorias 
Local lAgendAbb		:= SuperGetMv("MV_ATVTABB",,.F.)   					// Controla agenda pela ABB
Local oBtAgVist		:= Nil  				

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Busca todas as vistorias e adiciona no Browse. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aBrwVis := At290VTAge(aPeriodo[1])

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa os objetos que exibirao as imagens. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oOk := LoadBitMap(GetResources(), "LBOK")
oNo := LoadBitMap(GetResources(), "LBNO")   

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAcoes Avanca, Voltar e Finalizar. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
bVldNext := {|| At290VdNxt(oModel,oWizard,oBrwVis,oBrwProp,oCbxPer,oChkProp,nRdSol,lImpProp)}
bVldBack := {|| At290VdBck(oWizard,oBrwVis,oBrwProp,oCbxPer,oChkProp,nRdSol) }
bFinish  := {|| lFinalizar := .T. }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa o Wizard. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oWizard := ApWizard():New (cWizTitle,cHMsg,cTitle,cText,{||.T.},{||.T.},lPanel,/*cResHead*/,/*bExecute*/,lNoFirst,aCoord)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPanel Tipo de solicitacao. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oWizard:newPanel(cWizTitle,STR0010,{||.T.},bVldNext,{||.T.},lPanel,{||.T.})		// "Selecione o tipo de solicita็ใo."

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPanel vistorias agendadas por vistoriador. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oWizard:newPanel(cWizTitle,STR0011,bVldBack,bVldNext,{||.T.},lPanel,{||.T.})		// "Vistorias agendadas por vistoriador."

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPanel Selecao de Proposta Comercial. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oWizard:newPanel(cWizTitle,STR0012,bVldBack,bVldNext,{||.T.},lPanel,{||.T.})		// "Selecione uma Proposta Comercial (Opcional)."

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPanel Informacoes para Vistoria Tecnica. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lAgendAbb
	oWizard:newPanel(cWizTitle,STR0013,bVldBack,{|| At290VdMan(oModel)},{||.T.},lPanel,{||.T.})   // "Informa็๕es para Vistoria T้cnica."
Else
	oWizard:newPanel(cWizTitle,STR0013,bVldBack,bVldNext,{||.T.},lPanel,{||.T.})   // "Informa็๕es para Vistoria T้cnica."
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPanel Solicitacao de Vistoria Tecnica. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oWizard:newPanel(cWizTitle,STR0014,bVldBack,{||.T.},bFinish,lPanel,{||.T.} )        			// "Solicita็ใo da Vistoria T้cnica."

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAdiciona os objetos nos paneis. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oPanel := oWizard:GetPanel(2)

oSayS1:= TSay():New(oPanel:nTop-80,oPanel:nLeft+3,{||STR0015},oPanel,,oTFont17,,,,.T.,CLR_HRED,CLR_WHITE,290,032)      // "Importante:"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ"* Para solicita็ใo de vistoria t้cnica manual o vendedor poderแ consultar a agenda dos vistoriadores e definir    ณ
//ณuma data para realiza็ใo da vistoria t้cnica."                                                                     ณ  
//ณ"* Para solicita็ใo de vistoria t้cnica automแtica, o assistente irแ solicitar a vistoria t้cnica sem data para    ณ  
//ณrealizar a mesma,ficando a cargo do vistoriador agendar com o cliente ou prospect. "Esta vistoria ficarแ em aberto ณ  
//ณe serแ alocada para o vistoriador com menor n๚mero de vistorias para atendimento."  								  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSayS2:= TSay():New(oPanel:nTop-65,oPanel:nLeft+6,{||STR0016+Chr(10)+Chr(10)+STR0017+" "+STR0018},oPanel,,oTFont14,;
					 ,,,.T.,CLR_BLACK,CLR_WHITE ,290,070)

oRdSol   := TRadMenu():New (oPanel:nTop-10,oPanel:nLeft+3,aItens,,oPanel,,,,,,,,100,12,,,,.T.)
oRdSol:bSetGet := {|u|Iif (PCount()==0,nRdSol,nRdSol:=u)}
        
oPanel   := oWizard:GetPanel(3)

oTGVis 	 := TGet():New(oPanel:nTop-80,oPanel:nLeft+3,{|u| If(PCount()>0,cPVist :=u,cPVist)},oPanel,105,010,"@!",,0,,,.F.,;
                      ,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cPVist,,,,)

oBtAPesq := TButton():New(oPanel:nTop-80,oPanel:nLeft+115,STR0021,oPanel,{||At290Busca(@oBrwVis,cPVist,@oTGVis,.T.)},30,12;
						   ,,,.F.,.T.,.F.,,.F.,,,.F. )  // "Pesquisar"
oBtAProx := TButton():New(oPanel:nTop-80,oPanel:nLeft+152,STR0022,oPanel,{||At290Busca(@oBrwVis,cPVist,@oTGVis,.F.)},30,12;
                           ,,,.F.,.T.,.F.,,.F.,,,.F. )  // "Pr๓ximo"
                           
oSayA1	 := TSay():New(oPanel:nTop-78,oPanel:nLeft+188,{||STR0023},oPanel,,oTFont14,,,,.T.,CLR_BLACK,CLR_WHITE,80,10) // "Agendamentos nos pr๓ximos"

oCbxPer  := TComboBox():New(oPanel:nTop-80,oPanel:nLeft+263,{|u| If(PCount()>0,cCbxPer:=u,cCbxPer)},aCbxIt,35,10,oPanel,,;
                           {||At290AtVis(oBrwVis,oCbxPer,aPeriodo)},,,,.T.,,,,,,,,,"cCbxPer")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ"Vistoria"##"Vistoriador"##"Nome"##"Data Inicial"##"Hora Inicial"##"Data Final"##"Hora Final"   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oBrwVis := TWBrowse():New(oPanel:nTop-62,oPanel:nLeft+3,(oPanel:nClientWidth/2)-10,(oPanel:nClientHeight/2)-62,,;
						  {STR0024,STR0025,STR0026,STR0027,STR0028,STR0029,STR0030},{30,40,75,35,35,35,35},oPanel,;
						  ,,,,,,,,,,,.F.,,.T.,,.F.,,, ) 


oChkVTA 			:= TCheckBox():New(oPanel:nTop+70,oPanel:nLeft+3,STR0031,,oPanel,250,100,,,,,CLR_BLACK,,,.T.,,,) // "Orderna por Data Inicial + Hora Inicial"
oChkVTA:bSetGet		:= {|u| If(PCount()>0,lChkVTA:=u,lChkVTA) }
oChkVTA:bLClicked 	:= {|| lChkVTB := .F.,IIF(lChkVTA,At290Order(1,oBrwVis),Nil) }

oChkVTB 			:= TCheckBox():New(oPanel:nTop+81,oPanel:nLeft+3,STR0032,,oPanel,250,100,,,,,CLR_BLACK,,,.T.,,,) // "Orderna por Vistoriador + Data Inicial + Hora Inicial"
oChkVTB:bSetGet		:= {|u| If(PCount()>0,lChkVTB:=u,lChkVTB) }
oChkVTB:bLClicked 	:= {|| lChkVTA := .F.,IIF(lChkVTB,At290Order(2,oBrwVis),Nil)}

oBrwVis:SetArray(aBrwVis)
oBrwVis:bLine := {||{	aBrwVis[oBrwVis:nAt,VT_CODVIS]	,; 		// Vistoria
						aBrwVis[oBrwVis:nAt,VT_VISTOR]	,; 		// Vistoriador
						aBrwVis[oBrwVis:nAt,VT_VNOME]	,;   	// Nome do Vistoriador
						aBrwVis[oBrwVis:nAt,VT_DTINI]	,; 		// Data Inicial
						aBrwVis[oBrwVis:nAt,VT_HRINI]	,; 		// Hora Inicial
						aBrwVis[oBrwVis:nAt,VT_DTFIM]	,;  	// Data Final
						aBrwVis[oBrwVis:nAt,VT_HRFIM] 	}}  	// Hora Final

oBrwVis:Refresh()

oPanel 	 := oWizard:GetPanel(4)

oTGProp	 := TGet():New(oPanel:nTop-80,oPanel:nLeft+3,{|u| If(PCount()>0,cPProp :=u,cPProp)},oPanel,105,010,"@!",,0,,,.F.;
					   ,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cPProp,,,, )

oBtPPesq := TButton():New(oPanel:nTop-80,oPanel:nLeft+115,STR0021,oPanel,{||At290Busca(@oBrwProp,cPProp,@oTGProp,.T.)},;
                          30,12,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Pesquisar"
oBtPProx := TButton():New(oPanel:nTop-80,oPanel:nLeft+152,STR0022,oPanel,{||At290Busca(@oBrwProp,cPProp,@oTGProp,.F.)},;
                          30,12,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Pr๓ximo"   

If !lMultVist  
                         
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ""##"Proposta"##"Revisใo"##"Oportunidade"##"Entidade"##"C๓digo"##"Nome da Entidade"##"Loja"##"Emissใo"##"Vistoria T้cnica?"##"Situa็ใo"  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู                                      
	oBrwProp := TWBrowse():New(oPanel:nTop-60,oPanel:nLeft+3,(oPanel:nClientWidth/2)-10,(oPanel:nClientHeight/2)-62,,;
	                           {"",STR0033,STR0034,STR0035,STR0036,STR0037,STR0038,STR0039,STR0040,STR0041,STR0042},;
	                           {5,45,45,45,45,45,60,40,40,50,55},oPanel,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, ) //
	
	oChkProp			:= TCheckBox():New(oPanel:nTop+75,oPanel:nLeft+3,STR0043,,oPanel,250,100,,,,,CLR_RED,,,.T.,,,)  // "Importar os insumos / servi็os da Proposta Comercial para Vistoria T้cnica."
	oChkProp:bSetGet	:= {|u| If(PCount()>0,lImpProp:=u,lImpProp) }
	oChkProp:bLClicked 	:= {|| lImpProp:= At290VdCkc(oBrwProp,lImpProp) }
	
	aProposta			:= At290Prop(AD1->AD1_NROPOR)
	oBrwProp:SetArray(aProposta)
	oBrwProp:bLDblClick := {|| aEval(aProposta,{|x|x[P_MARCA] := .F.}), aProposta[oBrwProp:nAt,P_MARCA] := !aProposta[oBrwProp:nAt,P_MARCA], oBrwProp:Refresh()}
	
	oBrwProp:bLine := {||{ If(aProposta[oBrwProp:nAt,P_MARCA],oOk,oNo)				,;	// Marca / Desmarca
							aProposta[oBrwProp:nAt,P_PROPOS]						,;	// Proposta
							aProposta[oBrwProp:nAt,P_PREVIS]						,;	// Revisao
							aProposta[oBrwProp:nAt,P_OPORTU]						,;	// Oportunidade
							X3Combo("ADY_ENTIDA",aProposta[oBrwProp:nAt,P_ENTIDA])	,;	// Entidade
							aProposta[oBrwProp:nAt,P_CODENT]						,;	// Codigo da Entidade   
							aProposta[oBrwProp:nAt,P_NOMENT]						,;	// Nome da Entidade
							aProposta[oBrwProp:nAt,P_LOJENT]						,;	// Loja da Entidade
							aProposta[oBrwProp:nAt,P_EMISSA]						,;	// Emissao
							X3Combo("ADY_VISTEC",aProposta[oBrwProp:nAt,P_VISTEC])	,;	// Vistoria Tecnica?
							X3Combo("ADY_SITVIS",aProposta[oBrwProp:nAt,P_SITVIS])	}}	// Situacao da Vistoria 
Else

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ""##"Proposta"##"Revisใo"##"Oportunidade"##"Entidade"##"C๓digo"##"Nome da Entidade"##"Loja"##"Emissใo" ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู                                      
	oBrwProp := TWBrowse():New(oPanel:nTop-60,oPanel:nLeft+3,(oPanel:nClientWidth/2)-10,(oPanel:nClientHeight/2)-62,,;
	                           {"",STR0033,STR0034,STR0035,STR0036,STR0037,STR0038,STR0039,STR0040},;
	                           {5,45,45,45,45,45,60,40,40,50,55},oPanel,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, ) //
	
	oChkProp			:= TCheckBox():New(oPanel:nTop+75,oPanel:nLeft+3,STR0043,,oPanel,250,100,,,,,CLR_RED,,,.T.,,,)  // "Importar os insumos / servi็os da Proposta Comercial para Vistoria T้cnica."
	oChkProp:bSetGet	:= {|u| If(PCount()>0,lImpProp:=u,lImpProp) }
	oChkProp:bLClicked 	:= {|| lImpProp:= At290VdCkc(oBrwProp,lImpProp) }
	
	aProposta			:= At290Prop(AD1->AD1_NROPOR)
	oBrwProp:SetArray(aProposta)
	oBrwProp:bLDblClick := {|| aEval(aProposta,{|x|x[P_MARCA] := .F.}), aProposta[oBrwProp:nAt,P_MARCA] := !aProposta[oBrwProp:nAt,P_MARCA], oBrwProp:Refresh()}
	
	oBrwProp:bLine := {||{ If(aProposta[oBrwProp:nAt,P_MARCA],oOk,oNo)				,;	// Marca / Desmarca
							aProposta[oBrwProp:nAt,P_PROPOS]						,;	// Proposta
							aProposta[oBrwProp:nAt,P_PREVIS]						,;	// Revisao
							aProposta[oBrwProp:nAt,P_OPORTU]						,;	// Oportunidade
							X3Combo("ADY_ENTIDA",aProposta[oBrwProp:nAt,P_ENTIDA])	,;	// Entidade
							aProposta[oBrwProp:nAt,P_CODENT]						,;	// Codigo da Entidade   
							aProposta[oBrwProp:nAt,P_NOMENT]						,;	// Nome da Entidade
							aProposta[oBrwProp:nAt,P_LOJENT]						,;	// Loja da Entidade
					   		aProposta[oBrwProp:nAt,P_EMISSA]						}}	// Emissao
EndIf


oPanel := oWizard:GetPanel(5)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAdiciona o cabecalho da vistoria tecnica em MVC no panel.  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

oModel := FWLoadModel("TECA290")
oModel:SetOperation(3)
oModel:Activate()

oView := FWLoadView("TECA290")
oView:SetModel(oModel)
oView:SetOperation(3)
oView:SetOwner(oPanel)
oView:EnableControlBar(.F.)
oView:SetUseCursor(.F.)
oView:Activate()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define a oportunidade e revisao no formulario. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oModel:SetValue("AATMASTER","AAT_OPORTU",AD1->AD1_NROPOR)
oModel:SetValue("AATMASTER","AAT_OREVIS",AD1->AD1_REVISA)

oView:Refresh()

oPanel := oWizard:GetPanel(6) 

oSayF1 := TSay():New(oPanel:nTop-80,oPanel:nLeft+3,{||STR0044},oPanel,,oTFont17,,,,.T.,CLR_BLACK,CLR_WHITE,290,032)  // "Pronto!"
oSayF2 := TSay():New(oPanel:nTop-65,oPanel:nLeft+6,{||STR0045},oPanel,,oTFont14,,,,.T.,CLR_BLACK,CLR_WHITE,290,032)  // "* Para concluir sua solicita็ใo de vistoria t้cnica clique em finalizar."

If lAgendAbb
	oBtAgVist := TButton():New(oPanel:nTop-10,oPanel:nLeft+115,STR0058,oPanel,{|| Teca510(,M->AAT_VISTOR) },30,12,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Agendar"
EndIf

oWizard:Activate( .T., {|| lFinalizar .OR. MsgYesNo(STR0046,STR0047)},/*xx*/, /*<bWhen>*/ )   // "Confirma a saida do assistente de solicita็ใo de vistoria t้cnica?"##"Aten็ใo"

If !lAgendAbb
	If lFinalizar
		If nRdSol == 1			
			lRetorno := At290GvMan(oModel,lImpProp)
		Else
			lRetorno := At290GvAut(oModel,lImpProp)
		EndIf
		If lImpProp
			// Gera o or็amento de servi็os para a vistoria tecnica			
			A600GeraOrc( 	oModel:GetValue("AATMASTER","AAT_PROPOS"),; 
							oModel:GetValue("AATMASTER","AAT_PREVIS"),; 
							oModel:GetValue("AATMASTER","AAT_CODVIS") )
		EndIf
	Else 
		oModel:CancelData()
		oView:DeActivate() 
		oModel:DeActivate()
	EndIf
Else
	If lFinalizar
    	lRetorno := .T.
	EndIf
EndIf

Return( lRetorno ) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt290VTAgeบAutor  ณVendas CRM          บ Data ณ  20/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca as vistorias agendadas.                    			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpA - Vistorias Agendadas. 		                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpN1 - Numero de dias.									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA290                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   
Static Function At290VTAge(nNrDias) 

Local cNome		:= ""			        								// Nome do Vistoriador.
Local aVistoria := {}  													// Array com as vistorias.    								
Local dCorte	:= dDataBase + nNrDias     								// Data de corte.
Local bCondicao := {|dDtIni| IIF(nNrDias==0,.T.,dDtIni <= dCorte) }	// Condicao do Filtro.

DbSelectArea("AAT")
DbSetOrder(1)

If DbSeek(xFilial("AAT"))	
	While ( AAT->(!Eof()) .AND. AAT->AAT_FILIAL == xFilial("AAT") )
		If ( AAT->AAT_STATUS == "2" .AND. Eval(bCondicao,AAT->AAT_DTINI) )	
			cNome := Alltrim( Posicione("AA1",1,xFilial("AA1")+AAT->AAT_VISTOR,"AA1_NOMTEC") )
			aAdd(aVistoria,{	AAT->AAT_CODVIS ,;
								AAT->AAT_VISTOR ,;
		   						cNome			,;
		   						AAT->AAT_DTINI  ,;
		   						AAT->AAT_HRINI  ,;
		   						AAT->AAT_DTFIM  ,;
								AAT->AAT_HRFIM  })
		EndIf
		AAT->(DbSkip())
	End	
EndIf   

If Len( aVistoria ) == 0
	aVistoria := {{"","","","","","",""}}
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Orderna por Data Inicial + Hora Inicial (Default).ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ASort(aVistoria,/*nInicio*/,/*nCont*/,{|a,b| ( DToS(a[VT_DTINI]) + a[VT_HRINI] ) <  (  DToS(b[VT_DTINI]) + b[VT_HRINI] )})

Return( aVistoria )  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณAt290AtVisบAutor  ณVendas CRM          บ Data ณ  20/03/12  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza no browse as vistorias agendadas de acordo com    บฑฑ
ฑฑบ			 ณperiodo informado no ComboBox.                   	   	     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro			 		                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Browse Vistoria Tecnica.							 บฑฑ
ฑฑบ          ณExpO2 - ComboBox Periodo.									 บฑฑ 
ฑฑบ          ณExpA3 - Array com os periodos disponiveis.				 บฑฑ   
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA290                                                    บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function At290AtVis(oBrwVis,oCbxPer,aPeriodo)  

Local aBrwVis := At290VTAge(aPeriodo[oCbxPer:nAt])    	// Array com as vistorias agendadas

oBrwVis:SetArray(aBrwVis)
oBrwVis:bLine := {||{	aBrwVis[oBrwVis:nAt,VT_CODVIS]	,; 		// Vistoria
						aBrwVis[oBrwVis:nAt,VT_VISTOR]	,; 		// Vistoriador
						aBrwVis[oBrwVis:nAt,VT_VNOME]	,;   	// Nome do Vistoriador
						aBrwVis[oBrwVis:nAt,VT_DTINI]	,; 		// Data Inicial
						aBrwVis[oBrwVis:nAt,VT_HRINI]	,; 		// Hora Inicial
						aBrwVis[oBrwVis:nAt,VT_DTFIM]	,;  	// Data Final
						aBrwVis[oBrwVis:nAt,VT_HRFIM] 	}}  	// Hora Final
oBrwVis:Refresh()
                    
Return( .T. ) 
                 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณModelDef  บAutor  ณVendas CRM          บ Data ณ  20/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณModelo de Dados Vistoria Tecnica.                   		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpO - Modelo de Dados                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum					                      			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA290                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ModelDef()
             	
Local oModel	:= Nil      													// Modelo de dados
Local oStruAAT 	:= FWFormStruct(1,"AAT",/*bAvalCampo*/,/*lViewUsado*/) 			// Objeto que contem a estrutura do cabecalho de vistoria.
Local bPosValid := {|oModel|At270VdAge(oModel)}											  	// Pos validacao do formulario.
Local bCommit	:= {|oModel| At290Cmt(oModel)}         							// Bloco de commit do formulario.
Local lAgendAbb	:= SuperGetMv("MV_ATVTABB",,.F.)   					// Controla agenda pela ABB

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Instancia o modelo de dados Vistoria Tecnica. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oModel := MPFormModel():New("TECA290",/*bPreValidacao*/,bPosValid,bCommit,/*bCancel*/)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Adiciona os campos no modelo de dados. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oModel:AddFields("AATMASTER",/*cOwner*/,oStruAAT,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define as propriedades do campo. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oStruAAT:SetProperty("AAT_OPORTU",MODEL_FIELD_WHEN,{|| IIF(oModel:GetOperation()==3,.T.,.F.) })
If lAgendAbb	        
	oStruAAT:SetProperty("AAT_DTINI",MODEL_FIELD_OBRIGAT,.F.) 
	oStruAAT:SetProperty("AAT_HRINI",MODEL_FIELD_OBRIGAT,.F.) 
	oStruAAT:SetProperty("AAT_DTFIM",MODEL_FIELD_OBRIGAT,.F.)
	oStruAAT:SetProperty("AAT_HRFIM",MODEL_FIELD_OBRIGAT,.F.)
EndIf
oStruAAT:SetProperty("AAT_VISTOR",MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID,"ExistCpo('AA1',FwFldGet('AAT_VISTOR'),1)"))

oModel:SetPrimaryKey({"AAT_FILIAL","AAT_CODVIS"})

Return( oModel )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณViewDef   บAutor  ณVendas CRM          บ Data ณ  20/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInterface Vistoria Tecnica.                       		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpO - Interface                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum					                      			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA290                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ViewDef()

Local oView    := Nil                 	 	// Objeto que contem interface vistoria tecnica.
Local oModel   := FWLoadModel("TECA290")	// Objeto que contem o modelo de dados.
Local oStruAAT := FWFormStruct(2,"AAT")		// Objeto que contem a estrutura do cabecalho de vistoria.
Local lAgendAbb	:= SuperGetMv("MV_ATVTABB",,.F.)   // Controla agenda pela ABB

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Remove os campos da View. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lAgendAbb
	oStruAAT:RemoveField("AAT_PROPOS")
	oStruAAT:RemoveField("AAT_PREVIS") 
	oStruAAT:RemoveField("AAT_TABELA")
	oStruAAT:RemoveField("AAT_STATUS")
	oStruAAT:RemoveField("AAT_OBSVIS")
	oStruAAT:RemoveField("AAT_REGIAO")
	oStruAAT:RemoveField("AAT_CODABT")
	oStruAAT:RemoveField("AAT_DSCABT")
Else 
	oStruAAT:RemoveField("AAT_PROPOS")
	oStruAAT:RemoveField("AAT_PREVIS") 
	oStruAAT:RemoveField("AAT_TABELA")
	oStruAAT:RemoveField("AAT_STATUS")
	oStruAAT:RemoveField("AAT_OBSVIS")
	oStruAAT:RemoveField("AAT_DTINI")
	oStruAAT:RemoveField("AAT_HRINI")
	oStruAAT:RemoveField("AAT_DTFIM")
	oStruAAT:RemoveField("AAT_HRFIM")
	oStruAAT:RemoveField("AAT_REGIAO")
	oStruAAT:RemoveField("AAT_CODABT")
	oStruAAT:RemoveField("AAT_DSCABT")
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Instancia a interface Vistoria Tecnica. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oView := FWFormView():New()
oView:SetModel(oModel)   

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Adiciona os campos na View. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oView:AddField("VIEW_AAT",oStruAAT,"AATMASTER")   

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Criacao da tela. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oView:CreateHorizontalBox("TELA",100)
oView:SetOwnerView("VIEW_AAT","TELA")

Return( oView )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt290Prop บAutor  ณVendas CRM          บ Data ณ  20/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca as propostas comerciais relacionada uma oportunidade  บฑฑ
ฑฑบ          ณde venda.                     		 				      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpA - Propostas Comerciais                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Oportunidade de Venda.					          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA290                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function At290Prop(cNrOport)

Local aProposta	:= {}   		// Array com as propostas.
Local cNome 	:= ""   		// Nome da entidade.

DbSelectArea("ADY")
DbSetOrder(2)

If DbSeek(xFilial("ADY")+cNrOport)
	
	While ( ADY->(!Eof()) .AND. ADY_FILIAL == xFilial("ADY") .AND. ADY_OPORTU == cNrOport)
		
		cNome := POSICIONE("SA1",1,xFilial("SA1")+ADY->ADY_CODIGO+ADY->ADY_LOJA,"A1_NOME")
			
		aAdd(aProposta,{ .F.				,;      // Marca / Desmarca
						  ADY->ADY_PROPOS	,;      // Proposta
						  ADY->ADY_PREVIS	,;      // Revisao da Proposta
						  ADY->ADY_OPORTU	,;   	// Oportunidade
		                  ADY->ADY_ENTIDA	,;      // Entidade
	       	              ADY->ADY_CODIGO	,;      // Codigo
						  cNome				,;      // Nome da Entidade
						  ADY->ADY_LOJA		,;   	// Loja
	   				      ADY->ADY_DATA 	,;   	// Emissao
		                  ADY->ADY_VISTEC	,;   	// Vistoria Tecnica?
		                  ADY->ADY_SITVIS  })      	// Situacao da Vistoria		
		ADY->(DbSkip())
	End
EndIf

If Len(aProposta) == 0
	aProposta := {{.F.,"","","","","","","","","",""}}
EndIf

Return( aProposta )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt290VdManบAutor  ณVendas CRM          บ Data ณ  20/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao da solicitacao manual.                     		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro  / Falso                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Modelo de Dados.					                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA290                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function At290VdMan(oModel)

Local aError	:= {} 		// Array para adicionar o erro de validacao.
Local lRetorno	:= .T.		// Retorno da validacao.  				

If !oModel:VldData()
	aError := oModel:GetErrorMessage()
	If !Empty(aError[4])
		Help(" ",1,"AT290OBRIGAT",,AllTrim(aError[6]),1,0)
	Else
		Help("",1,aError[5])
	EndIf
	lRetorno := .F.
EndIf

Return( lRetorno )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt290GvManบAutor  ณVendas CRM          บ Data ณ  20/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGravacao da solicitacao manual.                     		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro  / Falso                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Modelo de Dados.					                  บฑฑ  
ฑฑบ          ณExpL2 - Importacao de proposta comercial.					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA290                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function At290GvMan(oModel,lImpProp)

Local cCodPro  := oModel:GetValue("AATMASTER","AAT_PROPOS")		// Proposta comercial
Local cRevPro  := oModel:GetValue("AATMASTER","AAT_PREVIS")		// Revisao
Local cCodVis  := oModel:GetValue("AATMASTER","AAT_CODVIS")    // Codigo da Vistoria
Local lRetorno := .F.                                        	// Retorno da validacao

If ( !Empty(cCodPro) .AND. !Empty(cRevPro) )
	If lImpProp		
		If At290IProp(oModel)
			lRetorno := oModel:CommitData()
		EndIf		
	Else
		lRetorno := oModel:CommitData()
	EndIf
Else
	lRetorno := oModel:CommitData()
EndIf

If lRetorno                      	
	Aviso(STR0048,STR0049,{STR0050},2) // "Solicita็ใo de Vistoria T้cnica."##"Vistoria T้cnica solicitada com sucesso..."##"OK"
Else
	MsgStop(STR0051,STR0047)  			// "Problemas durante a solicita็ใo da Vistoria T้cnica."##"Aten็ใo"
EndIf

Return( lRetorno )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt290GvAutบAutor  ณVendas CRM          บ Data ณ  20/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGravacao da solicitacao automatica.                 		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro  / Falso                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Modelo de Dados.					                  บฑฑ  
ฑฑบ          ณExpL2 - Importacao de proposta comercial.					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA290                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function At290GvAut(oModel,lImpProp)

Local cCodPro 	:= oModel:GetValue("AATMASTER","AAT_PROPOS")   // Proposta comercial.
Local cRevPro 	:= oModel:GetValue("AATMASTER","AAT_PREVIS")   // Revisao.
Local oMldAAT	:= oModel:GetModel("AATMASTER")					// Modelo de dados AAT.
Local oStruct  	:= oMldAAT:GetStruct()		   					// Retorna a estrutura atual.
Local cAlias    := GetNextAlias() 								// Proximo alias.
Local cFilAA1	:= xFilial("AA1")								// Filial AA1.
Local cFilAAT	:= xFilial("AAT")								// Filial AAT.
Local cQuery	:= ""											// Query vistoriador com menor numero de vistoria.
Local lRetorno  := .F.											// Retorno da validacao.
Local cVtrAloc  := "" 											// Vistoriador alocado automaticamente.
Local aVistor	:= {}	                                        // Array com os vistoriadores x numero de vistorias.
Local nPos		:= 0  											// Posicao do codigo do vistoriador.
Local lAgendAbb	:= SuperGetMv("MV_ATVTABB",,.F.)				// Controla agenda pela ABB

If !lAgendAbb	
	oStruct:SetProperty("AAT_DTINI",MODEL_FIELD_OBRIGAT,.F.)
	oStruct:SetProperty("AAT_HRINI",MODEL_FIELD_OBRIGAT,.F.)
	oStruct:SetProperty("AAT_DTFIM",MODEL_FIELD_OBRIGAT,.F.)
	oStruct:SetProperty("AAT_HRFIM",MODEL_FIELD_OBRIGAT,.F.)
EndIf    

#IFDEF TOP  
          
	cQuery := "SELECT AA1_CODTEC, COUNT(AAT_CODVIS) AAT__NRVIS FROM "+RetSqlName("AA1")+" AA1 LEFT JOIN "+RetSqlName("AAT")+" AAT "
	cQuery += " ON  AA1.AA1_CODTEC=AAT.AAT_VISTOR AND AAT.AAT_FILIAL='"+cFilAAT+"' AND AAT.AAT_STATUS <= '2' AND AAT.D_E_L_E_T_ = ''
	cQuery += " WHERE AA1.AA1_FILIAL='"+cFilAA1+"' AND AA1.AA1_VISTOR = '1' AND AA1.D_E_L_E_T_ = '' "
	cQuery += " GROUP BY AA1.AA1_CODTEC"
	cQuery += " ORDER BY AAT__NRVIS,AA1.AA1_CODTEC ASC"
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	
	cVtrAloc := (cAlias)->AA1_CODTEC
 
#ELSE  
    
    DbSelectArea("AA1")
    DbSetOrder(1)
    
    If DbSeek(xFilial("AA1"))
        
    	While( AA1->(!Eof()) .AND. AA1->AA1_FILIAL == xFilial("AA1") )
    		If AA1->AA1_VISTOR == "1"
    			aAdd(aVistor,{AA1->AA1_CODTEC,0})
    		EndIf
    		AA1->(DbSkip())
    	End
    	
    	DbSelectArea("AAT")
   		DbSetOrder(1)
	
   		If Len(aVistor) > 0 
	   		If DbSeek(xFilial("AAT"))
		   		While ( AAT->(!Eof()) .AND. AAT_FILIAL == xFilial("AAT") )
			   		If AAT->AAT_STATUS $ "1|2"	
			   			nPos := aScan(aVistor,{|x| x[1] == AAT->AAT_VISTOR})			
			   			If nPos > 0
			   				aVistor[nPos][2] += 1
			   			EndIf
			   		EndIf
			   		AAT->(DbSkip())
		   		End
			EndIf
		EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Orderna por menor numero de vistorias + codigo do atendente.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		ASort(aVistor,/*nInicio*/,/*nCont*/,{|a,b| ( cValToChar(a[2])+a[1] ) <  ( cValToChar(b[2])+b[1] )})
		cVtrAloc := aVistor[1][1] 	        
		
    EndIf

#ENDIF

oModel:SetValue("AATMASTER","AAT_VISTOR",cVtrAloc)
oModel:SetValue("AATMASTER","AAT_STATUS","1")

If ( !Empty(cCodPro) .AND. !Empty(cRevPro) )
	If lImpProp
		If At290IProp(oModel)
			lRetorno := oModel:CommitData()
		EndIf
	Else
		If At290VdAut(oModel)
			lRetorno := oModel:CommitData()
		EndIf
	EndIf
Else
	If At290VdAut(oModel)
		lRetorno := oModel:CommitData()
	EndIf
EndIf

If lRetorno
	Aviso(STR0048,STR0049,{STR0050},2)  	//"Solicita็ใo de Vistoria T้cnica."##"Vistoria T้cnica solicitada com sucesso..."##"OK"
Else
	MsgStop(STR0051,STR0047)  				//"Problemas durante a solicita็ใo da Vistoria T้cnica."##"Aten็ใo"
EndIf

Return( lRetorno )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt290VdAutบAutor  ณVendas CRM          บ Data ณ  20/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao da solicitacao automatica.                 		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro  / Falso                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Modelo de Dados.					                  บฑฑ  
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA290                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function At290VdAut(oModel)

Local lRetorno := oModel:VldData()   // Validacao do formulario        

//Exibe o log com a mensagem de erro, quando ocorrer algum problema.
If !lRetorno	

	aErro   := oModel:GetErrorMessage()
	
	AutoGrLog( "Source Form ID:            " + ' [' + AllToChar( aErro[1]  ) + ']' )
	AutoGrLog( "Source Field ID:           " + ' [' + AllToChar( aErro[2]  ) + ']' )
	AutoGrLog( "Form Error ID:             " + ' [' + AllToChar( aErro[3]  ) + ']' )
	AutoGrLog( "Field Error ID:            " + ' [' + AllToChar( aErro[4]  ) + ']' )
	AutoGrLog( "Error ID:                  " + ' [' + AllToChar( aErro[5]  ) + ']' )
	AutoGrLog( "Error message:             " + ' [' + AllToChar( aErro[6]  ) + ']' )
	AutoGrLog( "Solution message:          " + ' [' + AllToChar( aErro[7]  ) + ']' )
	AutoGrLog( "Assigned value:            " + ' [' + AllToChar( aErro[8]  ) + ']' )
	AutoGrLog( "Previous value:            " + ' [' + AllToChar( aErro[9]  ) + ']' )
	
	MostraErro()
	
EndIf

Return( lRetorno )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt290IPropบAutor  ณVendas CRM          บ Data ณ  20/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImportacao da proposta comercial.                 		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro  / Falso                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Modelo de Dados.					                  บฑฑ  
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA290                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function At290IProp(oModel)

Local aAreaADY	 := ADY->(GetArea())                          		// Guarda area ADY.
Local aAreaADZ	 := ADZ->(GetArea())                          		// Guarda area ADZ.
Local cCodVis 	 := oModel:GetValue("AATMASTER","AAT_CODVIS") 		// Codigo da vistoria.
Local cCodPro 	 := oModel:GetValue("AATMASTER","AAT_PROPOS")   	// Proposta comercial.
Local cRevPro 	 := oModel:GetValue("AATMASTER","AAT_PREVIS")  		// Revisao. 										
Local aProduto   := {}												// Array com os Produto. 
Local aAcessorio := {}												// Array com os Produto. 																				
Local nX	  	 := 0 												// Incremento utilizado no For. 												   	
Local lRetorno	 := .T. 											// Retorno da validacao.

DbSelectArea("ADY")
DbSetOrder(1)

If DbSeek(xFilial("ADY")+cCodPro)
	oModel:SetValue("AATMASTER","AAT_TABELA",ADY->ADY_TABELA)
EndIf

DbSelectArea("ADZ")
DbSetOrder(3)

If DbSeek(xFilial("ADZ")+cCodPro+cRevPro)
	
	While ( ADZ->(!Eof()) .AND. ADZ->ADZ_FILIAL == xFilial("ADZ") .AND.;
		ADZ->ADZ_PROPOS == cCodPro  .AND. ADZ->ADZ_REVISA == cRevPro )
		
		If ADZ->ADZ_FOLDER == "1"
			
			aAdd(aProduto,{	ADZ->ADZ_ITEM	 ,;		// Item
		   					ADZ->ADZ_PRODUT	 ,;		// Cod. Produto
							ADZ->ADZ_UM		 ,;		// Unidade
		   					ADZ->ADZ_MOEDA	 ,;   	// Moeda
		  					ADZ->ADZ_QTDVEN	 ,;		// Quantidade
		  					ADZ->ADZ_PRCVEN	 ,;    	// Preco de Venda
							ADZ->ADZ_PRCTAB	 ,; 	// Preco de Tabela
							ADZ->ADZ_TOTAL	 ,;   	// Valor Total
		   					ADZ->ADZ_TPPROD	 ,;    	// Tipo de Produto
		   					ADZ->ADZ_ITPAI	 ,;    	// Item Pai
							ADZ->ADZ_FOLDER })    	// Pasta 
	   Else
	   		aAdd(aAcessorio,{ ADZ->ADZ_ITEM	 	 ,;		// Item
		   		              ADZ->ADZ_PRODUT	 ,;		// Cod. Produto
						      ADZ->ADZ_UM		 ,;		// Unidade
		   					  ADZ->ADZ_MOEDA	 ,;   	// Moeda
		  					  ADZ->ADZ_QTDVEN	 ,;		// Quantidade
		  				   	  ADZ->ADZ_PRCVEN	 ,;    	// Preco de Venda
							  ADZ->ADZ_PRCTAB	 ,; 	// Preco de Tabela
							  ADZ->ADZ_TOTAL	 ,;   	// Valor Total
		   					  ADZ->ADZ_TPPROD	 ,;    	// Tipo de Produto
		   					  ADZ->ADZ_ITPAI	 ,;    	// Item Pai
							  ADZ->ADZ_FOLDER })    	// Pasta 
	   
	   EndIf						
							
		ADZ->(DbSkip())
	End
	
	DbSelectArea("AAU")
	DbSetOrder(1)
	
	Begin Transaction
	
		For nX := 1 To Len(aProduto)
			
			If RecLock("AAU",.T.)  
				AAU->AAU_FILIAL	:= xFilial("AAU")	   					// Filial 
				AAU->AAU_ITEM	:= StrZero(nX,TamSX3("AAU_ITEM")[1])  	// Item
				AAU->AAU_CODVIS	:= cCodVis             					// Vistoria
				AAU->AAU_PRODUT	:= aProduto[nX][2]    					// Produto
				AAU->AAU_UM		:= aProduto[nX][3]     					// Unidade
				AAU->AAU_MOEDA	:= aProduto[nX][4]    					// Moeda
				AAU->AAU_QTDVEN	:= aProduto[nX][5]     					// Quantidade
				AAU->AAU_PRCVEN	:= aProduto[nX][6]    					// Preco de Venda
				AAU->AAU_PRCTAB	:= aProduto[nX][7]	   					// Preco de Tabela
				AAU->AAU_VLRTOT	:= aProduto[nX][8]  					// Valor Total
				AAU->AAU_TPPROD	:= aProduto[nX][9]   					// Tipo de Produto
				AAU->AAU_ITPAI	:= aProduto[nX][10]    					// Item Pai
				AAU->AAU_ITPROP	:= aProduto[nX][1] 			   			// Item da Proposta
				AAU->AAU_FOLDER	:= aProduto[nX][11]    					// Pasta
				MsUnLock()
			Else
				lRetorno := .F.
				DisarmTransaction()
				Exit
			EndIf
			
		Next nX 
		
		If lRetorno 
		
			For nX := 1 To Len(aAcessorio)
				
				If RecLock("AAU",.T.)  
					AAU->AAU_FILIAL	:= xFilial("AAU")	   					// Filial 
					AAU->AAU_ITEM	:= StrZero(nX,TamSX3("AAU_ITEM")[1])  	// Item
					AAU->AAU_CODVIS	:= cCodVis             					// Vistoria
					AAU->AAU_PRODUT	:= aAcessorio[nX][2]    				// Produto
					AAU->AAU_UM		:= aAcessorio[nX][3]     				// Unidade
					AAU->AAU_MOEDA	:= aAcessorio[nX][4]    				// Moeda
					AAU->AAU_QTDVEN	:= aAcessorio[nX][5]     				// Quantidade
					AAU->AAU_PRCVEN	:= aAcessorio[nX][6]    				// Preco de Venda
					AAU->AAU_PRCTAB	:= aAcessorio[nX][7]	   				// Preco de Tabela
					AAU->AAU_VLRTOT	:= aAcessorio[nX][8]  					// Valor Total
					AAU->AAU_TPPROD	:= aAcessorio[nX][9]   					// Tipo de Produto
					AAU->AAU_ITPAI	:= aAcessorio[nX][10]    				// Item Pai
					AAU->AAU_ITPROP	:= aAcessorio[nX][1] 			   		// Item da Proposta
					AAU->AAU_FOLDER	:= aAcessorio[nX][11]    				// Pasta
					MsUnLock()
				Else
					lRetorno := .F.
					DisarmTransaction()
					Exit
				EndIf
				
			Next nX
			
		EndIf
		
		If lRetorno
			If ! At290VdAut(oModel)
				lRetorno := .F.
				DisarmTransaction()
			EndIf
		EndIf
	
	End Transaction
	
EndIf  

RestArea( aAreaADY )
RestArea( aAreaADZ )

Return( lRetorno )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt290VdNxtบAutor  ณVendas CRM          บ Data ณ  20/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao do botao Avancar.                 		 		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro  / Falso                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Modelo de Dados.					                  บฑฑ  
ฑฑบ			 ณExpO2 - Objeto ApWizard.					                  บฑฑ  
ฑฑบ			 ณExpO3 - Objeto Browse Vistoria Agendada.					  บฑฑ  
ฑฑบ			 ณExpO4 - Objeto Browse Proposta Comercial.	                  บฑฑ  
ฑฑบ			 ณExpO5 - Objeto ComboBox Periodo.	                 		  บฑฑ 
ฑฑบ			 ณExpO6 - Objeto CheckBox Importar Proposta.	              บฑฑ
ฑฑบ			 ณExpN7 - Objeto Radio Solicitacao.					          บฑฑ     
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA290                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function At290VdNxt(oModel,oWizard,oBrwVis,oBrwProp,oCbxPer,oChkProp,nRdSol,lImpProp)

Local lNext := .T.
Local lAgendAbb	:= SuperGetMv("MV_ATVTABB",,.F.)   					// Controla agenda pela ABB

If nRdSol == 1
	Do Case
		Case oWizard:nPanel == 2
			oCbxPer:Select(1)
			If Empty(oBrwVis:aArray[1][2]) .AND. Empty(oBrwProp:aArray[1][2])
				oWizard:SetPanel(4)
			ElseIf Empty(oBrwVis:aArray[1][2])
				oWizard:SetPanel(3)
			EndIf
		Case oWizard:nPanel == 3
			If Empty(oBrwProp:aArray[1][2])
				oWizard:SetPanel(4)
			EndIf
		Case oWizard:nPanel == 4
			lNext := At290LdPro(oModel,oBrwProp)
		Case oWizard:nPanel == 5 
			If lAgendAbb
				If nRdSol == 1
					lNext := At290GvMan(oModel,lImpProp)
				Else            	
					lNext := At290GvAut(oModel,lImpProp)
				EndIf	 
			EndIf 	
	EndCase
Else
	Do Case
		Case oWizard:nPanel == 2
			oCbxPer:Select(1)
			If Empty(oBrwProp:aArray[1][2])
				oWizard:SetPanel(5)
			Else
				oWizard:SetPanel(3)
			EndIf
		Case oWizard:nPanel == 4
			lNext := At290LdPro(oModel,oBrwProp)
			If lNext
				oWizard:SetPanel(5)
			EndIf
	EndCase
EndIf

Return( lNext )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt290VdBckบAutor  ณVendas CRM          บ Data ณ  20/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao do botao Avancar.                 		 		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro  / Falso                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto ApWizard.					                  บฑฑ  
ฑฑบ			 ณExpO2 - Objeto Browse Vistoria Agendada.					  บฑฑ  
ฑฑบ			 ณExpO3 - Objeto Browse Proposta Comercial.	                  บฑฑ  
ฑฑบ			 ณExpO4 - Objeto ComboBox Periodo.	                 		  บฑฑ 
ฑฑบ			 ณExpO5 - Objeto CheckBox Importar Proposta.	              บฑฑ
ฑฑบ			 ณExpN6 - Objeto Radio Solicitacao.					          บฑฑ     
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA290                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function At290VdBck(oWizard,oBrwVis,oBrwProp,oCbxPer,oChkProp,nRdSol)

Local lBack 	:= .T.        	// Retorno da validacao
Local lAgendAbb	:= SuperGetMv("MV_ATVTABB",,.F.)   					// Controla agenda pela ABB

If nRdSol == 1
	Do Case
		Case oWizard:nPanel == 4
			If Empty(oBrwVis:aArray[1][2])
				oWizard:SetPanel(3)
			EndIf
		Case oWizard:nPanel == 5
			If Empty(oBrwVis:aArray[1][2]) .AND. Empty(oBrwProp:aArray[1][2])
				oWizard:SetPanel(3)
			ElseIf Empty(oBrwProp:aArray[1][2])
				oWizard:SetPanel(4)
			EndIf
		Case oWizard:nPanel == 6
			If lAgendAbb
				lBack := .F.
			EndIf
	EndCase
Else
	Do Case
		Case oWizard:nPanel == 4
			oWizard:SetPanel(3)
		Case oWizard:nPanel == 6
			If !Empty(oBrwProp:aArray[1][2])
				oWizard:SetPanel(5)
			Else
				oWizard:SetPanel(3)
			EndIf
	EndCase
EndIf

Return( lBack )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt290VdCkcบAutor  ณVendas CRM          บ Data ณ  20/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida o checkBox importacao de propostas.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro  / Falso                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto Browse de Proposta Comercial.				  บฑฑ  
ฑฑบ			 ณExpL2 - Importacao de proposta comercial.					  บฑฑ  
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA290                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function At290VdCkc(oBrwProp,lImpProp)

Local lRetorno := .F.
Local nX 	:= 0

If lImpProp
	For nX := 1 To Len(oBrwProp:aArray)
		If oBrwProp:aArray[nX][1]
			lRetorno := .T.
		EndIf
	Next nX
	
	If !lRetorno
		MsgStop(STR0054,STR0047)  //"Proposta Comercial nใo selecionada."##"Aten็ใo"
	EndIf
EndIf

Return( lRetorno )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt290Cmt  บAutor  ณVendas CRM          บ Data ณ  20/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBloco para gravacao gravacao do formulario.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro			                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Modelo de dados.  		    					  บฑฑ  
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA290                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function At290Cmt(oModel)

Local oMdlAAT	:= oModel:GetModel("AATMASTER")		// Obtem o modelo de dados AATMASTER.
Local cCodVis	:= oMdlAAT:GetValue("AAT_CODVIS")  	// Codigo da vistoria tecnica.
Local cCodOpo	:= oMdlAAT:GetValue("AAT_OPORTU") 	// Codigo da oportunidade.
Local cRevOpo	:= oMdlAAT:GetValue("AAT_OREVIS") 	// Revisao da oportunidade.
Local cCodPro	:= oMdlAAT:GetValue("AAT_PROPOS")	// Codigo da proposta comercial.
Local cRevPro	:= oMdlAAT:GetValue("AAT_PREVIS") 	// Revisao da proposta comercial.
Local cStatus	:= oMdlAAT:GetValue("AAT_STATUS") 	// Revisao da proposta comercial.
Local lMultVist := SuperGetMv("MV_MULVIST",,.F.)   // Multipla Vistorias
Local lAgendAbb	:= SuperGetMv("MV_ATVTABB",,.F.)   					// Controla agenda pela ABB                      
Local bAfterTTS := {|| .T.}

If !lAgendAbb
	bAfterTTS := {|oModel| At270GvAbb(oModel:GetOperation())}	
	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		oModel:LoadValue("AATMASTER","AAT_STATUS","2")
	EndIf
EndIf

If !lMultVist 
	// Faz Comit no MVC
	FWModelActive(oModel)
	FWFormCommit(oModel,Nil,{|oModel,cId,cAlias|At290After(oModel,cId,cAlias,cCodVis,cCodOpo,cCodPro,cRevPro,cStatus)},bAfterTTS)
Else
	// Faz Comit no MVC
	FWModelActive(oModel)
	FWFormCommit(oModel,NIL,NIL,bAfterTTS)
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt290AfterบAutor  ณVendas CRM          บ Data ณ  20/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza a oportunidade ou proposta.       		          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro			                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Modelo de dados.  		    					  บฑฑ  
ฑฑบ			 ณExpC2 - Id do Modelo.  		    	   					  บฑฑ 
ฑฑบ			 ณExpC3 - Alias.  		    		  						  บฑฑ 
ฑฑบ			 ณExpC4 - Vistoria.  		    	  						  บฑฑ 
ฑฑบ			 ณExpC5 - Oportunidade.  		    				   		  บฑฑ 
ฑฑบ			 ณExpC6 - Proposta.  		    							  บฑฑ  
ฑฑบ			 ณExpC7 - Revisao.     				    					  บฑฑ  
ฑฑบ			 ณExpC8 - Status.  		    								  บฑฑ    
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA290                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function At290After(oModel,cId,cAlias,cCodVis,cCodOpo,cCodPro,cRevPro,cStatus) 

Local aArea		:= GetArea()
Local aAreaAD1	:= AD1->(GetArea())            	// Guarda AD1 area atual.
Local aAreaADY	:= ADY->(GetArea())				// Guarda ADY area atual.

If !Empty(cCodPro) .AND. !Empty(cRevPro)
	DbSelectArea("ADY")
	DbSetOrder(1)
	If DbSeek(xFilial("ADY")+cCodPro)
		RecLock("ADY",.F.)
		ADY->ADY_VISTEC := "1"
		ADY->ADY_CODVIS := cCodVis
		ADY->ADY_SITVIS := cStatus
		MSUnlock()
	EndIf
Else
	DbSelectArea("AD1")
	DbSetorder(1)
	If DbSeek(xFilial("AD1")+cCodOpo)
		RecLock("AD1",.F.)
		AD1->AD1_VISTEC := "1" 
		AD1->AD1_CODVIS := cCodVis
		AD1->AD1_SITVIS := cStatus
		MSUnlock()
	EndIf
EndIf             

RestArea(aAreaAD1)
RestArea(aAreaADY)
RestArea(aArea)

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt290LdProบAutor  ณVendas CRM          บ Data ณ  20/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida e carrega a proposta comercial no formulario.        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro  / Falso                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Modelo de dados.  						    	  บฑฑ   
ฑฑบ			 ณExpO2 - Objeto Browse de Proposta Comercial. 			      บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA290                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function At290LdPro(oModel,oBrwProp)

Local lRetorno 	:= .T.         						// Retorno da validacao
Local nX 	   	:= 0  								// Incremento utilizado no For
Local lMultVist := SuperGetMv("MV_MULVIST",,.F.)   // Multiplas Vistorias

For nX := 1 To Len(oBrwProp:aArray)	
	
	If oBrwProp:aArray[nX][1]
	
		If !lMultVist 
		
			If oBrwProp:aArray[nX][10] == "2"
				oModel:LoadValue("AATMASTER","AAT_PROPOS",oBrwProp:aArray[nX][2])
				oModel:LoadValue("AATMASTER","AAT_PREVIS",oBrwProp:aArray[nX][3])
			Else
				
				If oBrwProp:aArray[nX][11] == "1"
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ	 Problema: Existe uma vistoria t้cnica em aberto para essa proposta comercial. 	   		               	        ณ
					//ณ	 Solucao: Verifique com vistoriador responsแvel por esta vistoria t้cnica a conclusใo ou cancelamento da mesma. ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					lRetorno := .F.
					Help("",1,"AT290PRPAB")
				ElseIf oBrwProp:aArray[nX][11] == "2"
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ	 Problema: Existe uma vistoria t้cnica agendada para essa proposta comercial. 	   			    				ณ
					//ณ	 Solucao: Verifique com vistoriador responsแvel por esta vistoria t้cnica a conclusใo ou cancelamento da mesma. ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					lRetorno := .F.
					Help("",1,"AT290PRPAG")
				ElseIf oBrwProp:aArray[nX][11] == "3"
					//"Vistoria t้cnica para esta proposta comercial foi concluida. "##"Deseja solicitar uma nova vistoria t้cnica?"##"Aten็ใo"
					If MsgYesNo(STR0055+CRLF+STR0056,STR0047)
						oModel:LoadValue("AATMASTER","AAT_PROPOS",oBrwProp:aArray[nX][2])
						oModel:LoadValue("AATMASTER","AAT_PREVIS",oBrwProp:aArray[nX][3])
					Else
						lRetorno := .F.
					Endif
				EndIf
			EndIf    
			
		Else
			oModel:LoadValue("AATMASTER","AAT_PROPOS",oBrwProp:aArray[nX][2])
			oModel:LoadValue("AATMASTER","AAT_PREVIS",oBrwProp:aArray[nX][3])
		EndIf
		
		If !lRetorno
			oBrwProp:aArray[nX][1] := .F.
			oBrwProp:Refresh()
		EndIf
		
		Exit
		
	EndIf
	
Next nX

Return( lRetorno )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt290BuscaบAutor  ณVendas CRM          บ Data ณ  20/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPesquisa no ListBox a informacao passada no MsGet.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro / Falso                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Listbox para pesquisa.                              บฑฑ
ฑฑบ          ณExpC2 - Texto pesquisado.                                   บฑฑ
ฑฑบ          ณExpO3 - Get da pesquisa.                                    บฑฑ
ฑฑบ          ณExpL4 - Indica se deve pesquisar do inicio(.T.) ou nao(.F.) บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA290                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function At290Busca(oBrowse,cString,oPesq,lInicio)

Local nCount 	:= 0	// Contador temporแrio
Local nCount2	:= 0	// Contador temporแrio
Local lAchou	:= .F.	// Se encontrou a informa็ใo desejada

Default oPesq := Nil
Default lInicio := .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa a variแvel da linha inicial de procura.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ValType(nStartLine) <> "N"
	nStartLine := 1
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa a variแvel da coluna inicial de procura.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ValType(nStartCol) <> "N"
	nStartCol := 1
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe ้ para procurar desde o inํcio.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lInicio
	nStartLine	:= 1
	nStartCol	:= 1
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณProcura em todas as linhas e colunas pelo conte๚do solicitado.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nCount := nStartLine To Len(oBrowse:aArray)
	
	For nCount2 := nStartCol To Len(oBrowse:aArray[nCount])
		If ValType(oBrowse:aArray[nCount][nCount2]) == "C"
			If Upper(AllTrim(cString)) $ Upper(AllTrim(oBrowse:aArray[nCount][nCount2]))
				oBrowse:nAt := nCount
				oBrowse:Refresh()
				nStartLine	:= nCount
				nStartCol	:= nCount2 + 1
				lAchou := .T.
				Exit
			EndIf
		ElseIf ValType(oBrowse:aArray[nCount][nCount2]) == "D"
			If cTod(AllTrim(cString)) == oBrowse:aArray[nCount][nCount2]
				oBrowse:nAt := nCount
				oBrowse:Refresh()
				nStartLine	:= nCount
				nStartCol	:= nCount2 + 1
				lAchou := .T.
				Exit
			EndIf
		EndIf
	Next nCount2
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe jแ encontrou um resultado, saia.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lAchou
		Exit
	Else
		nStartCol := 1
	EndIf
	
Next nCount

If oPesq <> Nil
	If lAchou
		oPesq:SetColor(CLR_BLACK,CLR_WHITE)
	Else
		oPesq:SetColor(CLR_WHITE,CLR_HRED)
	Endif
EndIf

Return( lAchou )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt290OrderบAutor  ณVendas CRM          บ Data ณ  20/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณOrdena as vistorias agendadas.      						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpN1 - Modelo de dados.  								  บฑฑ 
ฑฑบ          ณExpO2 - Objeto Browse Vistoria Agendada. 					  บฑฑ   
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA290                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function At290Order(nChkBox,oBrwVis)

Local lRetorno := .T.

If nChkBox == 1
	ASort(oBrwVis:aArray,/*nInicio*/,/*nCont*/,{|a,b| ( DToS(a[VT_DTINI]) + a[VT_HRINI] ) <  (  DToS(b[VT_DTINI]) + b[VT_HRINI] )})
Else
	ASort(oBrwVis:aArray,/*nInicio*/,/*nCont*/,{|a,b| (  a[VT_VISTOR] + DToS(a[VT_DTINI]) + a[VT_HRINI] ) <;
	                                                   (  b[VT_VISTOR] + DToS(b[VT_DTINI]) + b[VT_HRINI] )})
EndIf

oBrwVis:Refresh()

Return( lRetorno ) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt290OrderบAutor  ณVendas CRM          บ Data ณ  23/06/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se hแ atendente com perfil de vistoriador.      	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro / Falso                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA290                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function At290VerVt()

Local aArea		:= GetArea()          	// Area atual.
Local aAreaAA1	:= AA1->(GetArea())	// Area da tabela AA1.
Local lRetorno 	:= .F.					// Retorno da validacao.   

DbSelectArea("AA1")
DbSetOrder(1)

If DbSeek(xFilial("AA1")) 

	While AA1->(!Eof()) .AND. AA1->AA1_FILIAL == xFilial("AA1") 
		
		If AA1->AA1_VISTOR == "1"
			lRetorno := .T.
			Exit
		EndIf
	
		AA1->(DbSkip())
	End
                    
EndIf					

Return (lRetorno)