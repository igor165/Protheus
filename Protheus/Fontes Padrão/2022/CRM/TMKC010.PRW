#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "TMKC010.CH"
#INCLUDE "TMKDEF.CH"
#INCLUDE "FWMVCDEF.CH"
 

/*

	 Modelo da Arvore de Consultas - TREE
	 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 ³	  01 - Consulta Perfil do Contato		  ³
	 ³		  02 - Contato              		  ³
	 ³			  03 - Telemarketing      		  ³
	 ³				  04 - Encerramentos          ³
	 ³				  05 - Ativos                 ³
	 ³				  06 - Receptivos             ³
	 ³				  07 - Follow Up              ³
	 ³				  08 - Pendencias             ³
	 ³				  09 - Chamado Tecnico        ³
	 ³				  10 - Atendimentos           ³
	 ³			  11 - Conhecimento               ³
	 ³				  12 - Analise Banco          ³
	 ³			  13 - Campanha                   ³
	 ³				  14 - Detalhado              ³
	 ³				  15 - Analise Scripts        ³
	 ³		  16 - Empresa                   	  ³
	 ³			  17 - Televendas           	  ³
	 ³				  18 - Orcamentos         	  ³
	 ³				  19 - Fatuamento             ³
	 ³				  20 - Cancelamento           ³
	 ³				  21 - Vendas Sigaloja        ³
	 ³				  22 - Bonus                  ³
	 ³				  23 - Mais Comprados         ³
	 ³			  24 - Conhecimento               ³
	 ³				  25 - Analista Banco         ³
	 ³			  26 - Telecobranca       		  ³
	 ³				  27 - Cobrancas              ³ 
	 ³				  28 - Negociacao             ³
	 ³				  29 - Ocorrencias            ³
	 ³				  30 - Cobr. Vencida          ³
	 ³				  31 - Cobr. a Realizar       ³
	 ³			  32 - Analise Financeira 		  ³
	 ³				  33 - Vencidos               ³
	 ³				  34 - A vencer               ³
	 ³				  35 - Pagto c/ Atraso        ³
	 ³				  36 - Pagto Cartorio         ³
	 ³				  37 - Protestados            ³
	 ³				  38 - Posicao Financeira     ³ 
	 ³				  39 - NCC's em aberto        ³ 
	 ³			  40 - Vendas                     ³
	 ³				  41 - Loja                   ³
	 ³				  42 - Faturamento            ³
	 ³				  43 - Entregas agendadas     ³
	 ³		  44 - Marketing            		  ³
	 ³			  45 - Contato            		  ³
	 ³				  46 - Lista                  ³
	 ³				  47 - Resultado              ³
	 ³		  48 - Field Service        		  ³
	 ³			  49 - Atendimento        		  ³
	 ³				  50 - Chamado tecnico        ³
	 ³				  51 - Ordem Servico          ³
	 ³				  52 - Agendamentos           ³
	 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ TMKC010        	  ³ Autor ³ Armando M. Tessaroli  ³ Data ³ 11/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta gerencial baseada na movimentacao criada pelo call center e ³±±
±±³			 ³ apoio a decisoes estrategicas administrativas, a partir de um contato³±±
±±³			 ³ e uma entidade (empresa) previamente selecionada para que a consulta ³±±
±±³			 ³ seja referenciada e também a partir de uma determinada data, ate a   ³±±
±±³			 ³ database do sistema.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Pefil do Contato										  		     	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         	        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K.³16/11/04³8.11  ³-Revisao do fonte:Sintaxe,Documentacao e Logica       ³±±
±±³Fernando  ³12/12/06³9.12  ³Bops 115442 Alterado a array aRotina  para criação	³±±
±±³          ³        |      ³ do menu funcional              						³±±
±±³          ³        ³      ³                                            	        ³±±
±±³          ³        ³      ³                                            	        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TmkC010( cFiltro, cFiltroEnt )

Local oMBrowse := Nil

Private aRotina    := MenuDef()
Private cCadastro  := STR0003 // "Informacoes gerencias das entidades"
Private aDados     := Array(7)
Private lFiltroCRM := IIF( !Empty( cFiltro ), .T., .F. ) 

Default cFiltro    := ""
Default cFiltroEnt := ""

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias("SU5")
oMBrowse:SetDescription(STR0003)  // "Informacoes gerencias das entidades"

If !( Empty( cFiltro ) )
	oMBrowse:DeleteFilter( "AO4_FILENT" )
	oMBrowse:AddFilter( STR0131, cFiltro, .T., .T., "AO4", , , "AO4_FILENT" )		// "Filtro do CRM" 
	oMBrowse:ExecuteFilter()	
EndIf

If !Empty(cFiltroEnt)
	oMBrowse:DeleteFilter( "FIL_ETNREC" )
	oMBrowse:AddFilter( STR0133, cFiltroEnt, .T., .T.,, , , "FIL_ETNREC" )//"Filtro de Entidade" 
	oMBrowse:ExecuteFilter()	
EndIf	
	
oMBrowse:Activate()

Return(Nil) 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef	³ Autor ³ Fernando Amorim       ³ Data ³11/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de definição do aRotina                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina   retorna a array com lista de aRotina             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMK                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef() 

Local aRotina:= {		{STR0001,"AxPesqui", 0 , 1 , , .F.},;		//"Pesquisar"
						{STR0002,"TK010Con", 0 , 2 , , .T.} }	 	//"Consulta"
					
							
Return(ARotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKC010   ºAutor  ³Microsiga               º Data ³  06/12/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consulta de todo o historico das movimentacoes do contato      º±±
±±º          ³ e da entidade, no call center.                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Pefil do Contato                                           	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMarcelo K.³16/11/04³8.11  ³--Revisao do fonte:Sintaxe,Documentacao,e Logicaº±±
±±ºHenry Fila³14/06/05³8.11  ³--Tratamento do retorno da tela da consulta     º±±
±±º          ³        ³      ³ref Bops                                        º±±
±±ºHenry Fila³14/06/05³8.11  ³--Tratamento do retorno da tela PRINCPAL onde   º±±
±±º          ³        ³      ³caso nao exista contato gerava error.log (lRet) º±±
±±ºConrado Q.³21/02/07³9.12  ³- Bops 119542: Retirado ajuste de dicionário.   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK010Con(cAlias,nReg,nOpc,aDummy,cCodCont,cEnt,cCodLoj) 

Local aArea     	:= GetArea()		// Salva a area atual
Local aResource 	:= {}				// Contem todos os botoes que farao parte do tool bar
Local bValid 		:= {|| .T.}			// Funcao de validacao no ACTIVATE do MsExplorer - nesse caso sempre .T.
Local cContato  	:= ""				// Dados do contato mostrados na TOOL BAR
Local cEmpresa  	:= ""				// Dados da entidade mostrados na TOOL BAR
Local aFuncPanels 	:= {}				// Array com as funcoes para a criacao de cada painel on demand

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis referentes a dialog de selecao da entidade e o periodo de pesquisa da base de dados   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aCont     	:= {}				// Dados do contato e da sua entidade
Local oLbx          					// Listbox com os dados da entidade
Local oDlg                              // Tela inicial - configuracoes			
Local oRadio							// Radio com as datas de corte:"15 Dias","30 Dias","45 Dias","A partir de"
Local oCmbFil		:= Nil				// Objeto da ComboBox
Local nCmbFil		:= 1				// Numero do elemento selecionado (combo)
Local nRadio							// Contador 	
Local oCorte							// Get Objeto com a data de corte
Local dCorte    	:= dDataBase - 15	// Data Default 
Local lCorte    	:= .F.				// Flag para indicar que a data foi informada
Local nI 			:= 0 				// Contador auxiliar	
Local oEmpCont							// Painel principal
Local nLenAux		:= 0				// Contador auxiliar para o FOR
Local nOpca       	:= 0				// Consistencia de opcao da tela
Local cPerg		:= "TMKC10"			// Pergunte (chamado ao clicar em parametros)
Local cFilSel		:= ""				// Filial selecionada
Local aAreaSM0		:= {}				// Area do SM0
Local lSU5Exc		:= .F.
Local aCbxItens	:= {}				// Opcoes do combobox localizar.
Local aDpItens   	:= {}				// De-Para das colunas do array aCont com as colunas do ListBox.
Local oCbxLoc		:= Nil				// ComboBox Localizar.
Local cOpcSel 		:= ""				// Opcao selecionada.
Local oTxtLoc		:= Nil				// MSGET para localizar a informacao no ListBox
Local cTxtLoc 	:= Space(150)		// Informacao a ser localizada no ListBox.
Local lCRMFIL     := .F.
Local lButUser		:= ExistBlock("TK10BTCL")
Local aBtnUser		:= {}
Local aRotinaBkp	:= {}
Local aPDFields		:= {"U5_CONTAT","US_EMAIL","A1_NOME","A1_END","A1_TEL","A1_CGC","A1_CHQDEVO","A1_TITPROT","U5_MUN","U5_EST"}

Private oExplorer						// Objeto que contem o tree e os panels
Private oPanels	:= {}				
Private aEmpCont	:= {}
Private aFils		:= {}
Private lTodasFil	:= .F.				// Indica se todas filiais serao lidas

Private aAllHeader  	:= {}			// Guarda na memoria todos os aHeaders
Private aHeader    	:= {}          // aheader  - para a getdados que for selecionada pelo usuario durante a navegacao
Private aCols      	:= {}			// aCols 

Private aSelFil	:= {} // Variavel requerida pela rotina Fc010Brow
Private aTmpFil	:= {} // Variavel requerida pela rotina Fc010Brow


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega os contatos e se existe relacionamento para o CONTATO mostra as Entidades³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
/*
  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ CONTATO   -  01 Codigo   ³
  ³ CONTATO   -  02 Nome     ³
  ³ CONTATO   -  03 Funcao   ³
  ³ CONTATO   -  04 DDD      ³
  ³ CONTATO   -  05 Telefone ³
  ³ CONTATO   -  06 E-mail   ³
  ³ CONTATO   -  07 Municipio³
  ³ CONTATO   -  08 Estado   ³
  ³ ENTIDADE  -  09 Entidade ³
  ³ ENTIDADE  -  10 Chave    ³  
  ³ ENTIDADE  -  11 Nome     ³
  ³ ENTIDADE  -  12 Endereco ³
  ³ ENTIDADE  -  13 Telefone ³
  ³ ENTIDADE  -  14 Municipio³
  ³ ENTIDADE  -  15 Estado   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

If Type("lFiltroCRM") == "L"
	lCRMFIL := lFiltroCRM
EndIf

If !Empty(cCodCont)
	DbSelectArea("SU5")
	DbSetOrder(1)
	DbSeek(xFilial("SU5")+cCodCont)
	aCont	:= TkCEmpCont( aCont, , , , , lCRMFIL )
Else
	DbSelectArea("SA1")
	DbSetOrder(1)
	aCont	:= TkCEmpCont( aCont, , cEnt, cCodLoj, , lCRMFIL )
EndIf


lSU5Exc := SX2MODO("SU5") == "E"

//Release 1.7 em diante possibilita acessar pela entidade
If Len(aCont) == 0 .AND. (Empty(cEnt) .OR. Empty(cCodLoj))
	Help(" ", 1, "NRELCONT")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o usuario cancelou no momento da excolha da entidade, o sistema retorna ao menu³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestArea(aArea)
	Return(.T.)
Endif

If FunName() == "TMKA070"
	aRotinaBkp	:= aRotina
	aRotina	:= MenuDef()
EndIf 

//Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
FATPDLoad(Nil,Nil,aPDFields)    

If !Empty(cCodCont)
	
	If (nI := aScan(aCont,{|x| AllTrim(x[1])==AllTrim(cEnt) .AND. AllTrim(x[2])== AllTrim(cCodLoj)})) > 0
		aEmpCont := TkCEmpCont( aCont, nI, , , , lCRMFIL )
	Else
		Return Nil
	EndIf
	
	DEFINE MSDIALOG oDlg FROM  0,0 TO 260,200 TITLE STR0079  PIXEL //"Dados para consulta"
	
		@ 01,01 TO 110,101 LABEL "" OF oDlg PIXEL

		@ 08,05 SAY STR0011 OF oDlg PIXEL COLOR CLR_RED //"Consulta dos ultimos"
	
		@ 17,06 TO 75,55 LABEL "" OF oDlg PIXEL 
		
		@ 20,07 RADIO oRadio VAR nRadio 3D SIZE 43,16;
					ITEMS	STR0012,;	// "15 Dias"
							STR0013,;	// "30 Dias"
							STR0014,;	// "45 Dias"
							STR0015; 	// "A partir de"	
					OF oDlg;
					ON CLICK (	lCorte := IIF(nRadio == 4,.T.,.F.),;
								dCorte := dDatabase-IF(nRadio==1,15,IF(nRadio==2,30,45)),;
								oCorte:Refresh(),;
								oCorte:SetFocus(),;
								oRadio:SetFocus() );
					WHEN .T. PIXEL
			
		@ 60,08 MSGET oCorte VAR dCorte SIZE 43,10 WHEN lCorte OF oDlg PIXEL
	    
		@ 80,07 SAY STR0090 OF oDlg PIXEL COLOR CLR_RED //"Filial"
	
		@ 90,10 COMBOBOX oCmbFil Var cFilSel ITEMS {STR0091,STR0092} SIZE 43,10 OF oDlg PIXEL ON CHANGE (nCmbFil := oCmbFil:nAt) WHEN !lSU5Exc //"Atual"###"Todas"


		DEFINE SBUTTON FROM 018,071 TYPE 18 ENABLE ONSTOP STR0016 OF oDlg ACTION (Pergunte("FIC010",.T.) ) //"Parametros Financeiro"
		
		DEFINE SBUTTON FROM 033,071 TYPE 05 ENABLE ONSTOP STR0017 OF oDlg ACTION (Pergunte(cPerg,.T.) ) //"Parametros Call Center"
		
		DEFINE SBUTTON FROM 115,041 TYPE 01 ENABLE ONSTOP STR0018 OF oDlg ACTION (nOpca := 1, oDlg:End()) //"Monta a Consulta"
			                   
		DEFINE SBUTTON FROM 115,071 TYPE 02 ENABLE ONSTOP STR0019 OF oDlg ACTION (oDlg:End()) //"Retorna ao Contato"

	ACTIVATE MSDIALOG oDlg CENTERED  
	
Else

	If Len(aCont) >= 1 .AND. (Empty(cEnt) .OR. Empty(cCodLoj) .OR. 1==Aviso(STR0095,STR0096,{STR0027,STR0097})) //"Atenção"#"Este cliente possui contatos. Deseja escolher um contato ou visualizar o perfil do cliente ?"#"Contato"#"Cliente"

		DEFINE MSDIALOG oDlg FROM  0,0 TO 290,745 TITLE STR0004  PIXEL //"Relacionamento Contatos X Entidades"
			
		
			@01,03 TO 125,310 LABEL "" OF oDlg  PIXEL
			
			aCbxItens := {STR0093,STR0027,STR0094,STR0118,STR0113,STR0114,STR0115,STR0116,STR0117}
			aDpItens  := {{1,9},{2,10},{3,11},{4,3},{5,4},{6,5},{7,6},{8,7},{9,8}}		
			
			@07,005 SAY STR0109 OF oDlg PIXEL // "Localizar:" 
			@05,035 COMBOBOX oCbxLoc Var cOpcSel ITEMS aCbxItens SIZE 100,11 OF oDlg PIXEL
			oCbxLoc:Cargo := aDpItens
			@05,140 MSGET oTxtLoc VAR cTxtLoc Picture "@!"  SIZE 100,9  OF oDlg PIXEL
			@05,245 BUTTON STR0110 SIZE 30,11 OF oDlg PIXEL ACTION (Tkc10Locza(oCbxLoc,oLbx,cTxtLoc)) // "Localizar"
			


			@20,05	LISTBOX oLbx FIELDS;
					HEADER	STR0093,; //"Cod. Contato"
							STR0027,; //"Contato"
							STR0094,; //"E-mail"							
							STR0005,; //"Entidades"
							STR0006,; //"Nome das entidades relacionadas"
							STR0007,; //"Endereço das entidades"
							STR0008,; //"Cidade das entidades"
							STR0009,; //"Estado"
							STR0010;  //"Telefone"
					SIZE 302,103  NOSCROLL OF oDlg PIXEL;
					ON DBLCLICK(aEmpCont:=TkCEmpCont(aCont,oLbx:nAt), oDlg:End()) 

			
			

			oLbx:SetArray(aCont)	
			oLbx:bLine:={||{	aCont[oLbx:nAt,9],;
								aCont[oLbx:nAt,10],;
								aCont[oLbx:nAt,11],;
								aCont[oLbx:nAt,3],;
								aCont[oLbx:nAt,4],;
								aCont[oLbx:nAt,5],;
								aCont[oLbx:nAt,6],;
								aCont[oLbx:nAt,7],;
								aCont[oLbx:nAt,8] }}										

			
			oLbx:nAt := 1
			
			aPDCols := {"","U5_CONTAT","US_EMAIL","","A1_NOME","A1_END","U5_MUN","U5_EST","A1_TEL"}
			
			If FATPDActive() .And. FTPDUse(.T.)
				oLbx:aObfuscatedCols := FATPDColObfuscate(aPDCols)
			EndIf
		
			@ 01,312 TO 125,372 LABEL "" OF oDlg PIXEL
		
			@ 08,317 SAY STR0011 OF oDlg PIXEL COLOR CLR_RED //"Consulta dos ultimos"
		
			@ 17,318 TO 75,364 LABEL "" OF oDlg PIXEL
			@ 20,319 RADIO oRadio VAR nRadio 3D SIZE 43,16;
						ITEMS	STR0012,;	// "15 Dias"
								STR0013,;	// "30 Dias"
								STR0014,;	// "45 Dias"
								STR0015; 	// "A partir de"	
						OF oDlg;
						ON CLICK (	lCorte := IIF(nRadio == 4,.T.,.F.),;
									dCorte := dDatabase-IF(nRadio==1,15,IF(nRadio==2,30,45)),;
									oCorte:Refresh(),;
									oCorte:SetFocus(),;
									oRadio:SetFocus() );
						WHEN .T. PIXEL
		
			@ 60,320 MSGET oCorte VAR dCorte SIZE 43,10 WHEN lCorte OF oDlg PIXEL
		
			@ 80,317 SAY STR0090 OF oDlg PIXEL COLOR CLR_RED //"Filial"
		
			@ 90,320 COMBOBOX oCmbFil Var cFilSel ITEMS {STR0091,STR0092} SIZE 43,10 OF oDlg PIXEL ON CHANGE (nCmbFil := oCmbFil:nAt) WHEN !lSU5Exc //"Atual"###"Todas"
	
			 
			DEFINE SBUTTON FROM 130,255 TYPE 18 ENABLE ONSTOP STR0016 OF oDlg ACTION (Pergunte("FIC010",.T.) ) //"Parametros Financeiro"
			
			DEFINE SBUTTON FROM 130,285 TYPE 05 ENABLE ONSTOP STR0017 OF oDlg ACTION (Pergunte(cPerg,.T.) ) //"Parametros Call Center"
				
			DEFINE SBUTTON FROM 130,315 TYPE 01 ENABLE ONSTOP STR0018 OF oDlg ACTION (nOpca := 1, aEmpCont:=TkCEmpCont( aCont, oLbx:nAt, , , , lCRMFIL ), oDlg:End()) //"Monta a Consulta"
				
			DEFINE SBUTTON FROM 130,345 TYPE 02 ENABLE ONSTOP STR0019 OF oDlg ACTION (oDlg:End()) //"Retorna ao Contato"
				
		ACTIVATE MSDIALOG oDlg CENTERED
		
	Else 
		aEmpCont	:= TkCEmpCont( {} , , cEnt , cCodLoj, .T., lCRMFIL )
		DbSelectArea(cEnt)

		DEFINE MSDIALOG oDlg FROM  0,0 TO 260,200 TITLE STR0079  PIXEL //"Dados para consulta"
		
			@ 01,01 TO 110,101 LABEL "" OF oDlg PIXEL
	
			@ 08,05 SAY STR0011 OF oDlg PIXEL COLOR CLR_RED //"Consulta dos ultimos"
		
			@ 17,06 TO 75,55 LABEL "" OF oDlg PIXEL 
			
			@ 20,07 RADIO oRadio VAR nRadio 3D SIZE 43,16;
						ITEMS	STR0012,;	// "15 Dias"
								STR0013,;	// "30 Dias"
								STR0014,;	// "45 Dias"
								STR0015; 	// "A partir de"	
						OF oDlg;
						ON CLICK (	lCorte := IIF(nRadio == 4,.T.,.F.),;
									dCorte := dDatabase-IF(nRadio==1,15,IF(nRadio==2,30,45)),;
									oCorte:Refresh(),;
									oCorte:SetFocus(),;
									oRadio:SetFocus() );
						WHEN .T. PIXEL
				
			@ 60,08 MSGET oCorte VAR dCorte SIZE 43,10 WHEN lCorte OF oDlg PIXEL
		    
			@ 80,07 SAY STR0090 OF oDlg PIXEL COLOR CLR_RED //"Filial"
		
			@ 90,10 COMBOBOX oCmbFil Var cFilSel ITEMS {STR0091,STR0092} SIZE 43,10 OF oDlg PIXEL ON CHANGE (nCmbFil := oCmbFil:nAt) WHEN !lSU5Exc //"Atual"###"Todas"
	
	
			DEFINE SBUTTON FROM 018,071 TYPE 18 ENABLE ONSTOP STR0016 OF oDlg ACTION (Pergunte("FIC010",.T.) ) //"Parametros Financeiro"
			
			DEFINE SBUTTON FROM 033,071 TYPE 05 ENABLE ONSTOP STR0017 OF oDlg ACTION (Pergunte(cPerg,.T.) ) //"Parametros Call Center"
			
			DEFINE SBUTTON FROM 115,041 TYPE 01 ENABLE ONSTOP STR0018 OF oDlg ACTION (nOpca := 1, oDlg:End()) //"Monta a Consulta"
				                   
			DEFINE SBUTTON FROM 115,071 TYPE 02 ENABLE ONSTOP STR0019 OF oDlg ACTION (oDlg:End()) //"Retorna ao Contato"
	
		ACTIVATE MSDIALOG oDlg CENTERED  
		
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Consistencia das opcoes da tela da consulta³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nOpca == 1
	
	SetKey(VK_F10,{|| IIF(oExplorer <> Nil, oExplorer:Deactivate(), Nil)})
	
	If nCmbFil == 2 //Todas as filiais
		lTodasFil := .T.  
		aAreaSM0 := SM0->(GetArea())
		DbSelectArea("SM0")
		DbSelectArea(1)
		DbSeek(cEmpAnt)
		While !SM0->(Eof()) .AND. SM0->M0_CODIGO == cEmpAnt
			AAdd(aFils,SM0->M0_CODFIL)
			SM0->(DbSkip())
		End
		RestArea(aAreaSM0)
	Else
		aFils := {cFilAnt}
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Acrescenta no Array          ³
	//³ENTIDADE  -  16 Data de Corte³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	AAdd(aEmpCont, {"CORTE", "CORTE", DtoS(dCorte)} )
	
	oExplorer := MSExplorer():New( STR0022 ) 	//"Consulta Gerencial"
	oExplorer:DefaultBar()						//	Define a barra de botoes padrao
	oExplorer:oTree:bValid:= {|cPromAtu,cCargAtu,cPromFut,cCargFut| &(aFuncPanels[val(cCargFut)]) ,;
															Iif(ValType(oPanels[val(cCargFut)])=="O",oPanels[val(cCargFut)]:Show(),Nil),;
															IIf(ValType(oPanels[Val(cCargAtu)])=="O",oPanels[Val(cCargAtu)]:FreeChildren(),Nil),;
															.T.}
															
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o conjunto de botoes da tool bar do objeto Explorer e as respectivas chamadas das funcoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd( aResource, {"IMPRESSAO", STR0078, {|| TMKR044(oExplorer,aEmpCont)}})		// "Impressao" //"Impressão"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada para inclusã de botões de usuário ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lButUser
		aBtnUser := ExecBlock("TK10BTCL",.F.,.F.)
		If ValType(aBtnUser) == "A"
			For nI := 1 to Len(aBtnUser)
				Aadd(aResource,{aBtnUser[nI,1],aBtnUser[nI,2],aBtnUser[nI,3]})
			Next nI
		EndIf
	EndIf

	Aadd( aResource, {"CANCEL"	 , STR0023, {|| oExplorer:Deactivate()} })			// "Cancela"
	
	For nI := 1 To Len(aResource)
		oExplorer:AddDefButton( aResource[nI,1], aResource[nI,2], aResource[nI,3] ) 
	Next nI
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o painel statico com dados do contato e da empresa como uma tool bar³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oEmpCont := TPanel():New( 35,125,"",,,,,CLR_BLACK,CLR_WHITE,397,16,.T.,.T.)
	
	@ 34,113 TO 52,510 LABEL "" OF oEmpCont PIXEL
	
	@ 03,02 BitMap oBmp1 ResName "BMPSEP1" OF oEmpCont Size 10,10 NoBorder When .F. Pixel
	
	nLenAux := LEN(aEmpCont)
	For nI := 1 TO nLenAux
	    If aEmpCont[nI,1] == "CONTATO"
			If aEmpCont[nI][2] <> "CODIGO"
				cContato := cContato + Trim(aEmpCont[nI][3]) + If(aEmpCont[nI+1][1] == "CONTATO" .and. .not. Empty(aEmpCont[nI][3]),"  -  ","")
			Endif      
			
	    ElseIf aEmpCont[nI,1] == "ENTIDADE"
			If aEmpCont[nI][2] <> "ENTIDADE" .and. aEmpCont[nI][2] <> "CHAVE"
				cEmpresa := cEmpresa + Trim(aEmpCont[nI][3]) + If(nI < len(aEmpCont) .and. .not. Empty(aEmpCont[nI][3]),"  -  ","")
			Endif
		Endif
	Next nI
	
	@ 01,08 BitMap oBmp1 ResName "BMPUSER" OF oEmpCont Size 10,10 NoBorder When .F. Pixel
	TSay():New(02,18,{|| cContato },oEmpCont,,,,,,.T.,CLR_HBLUE,CLR_WHITE)
	
	@ 08,08 BitMap oBmp2 ResName "BMPCPO" OF oEmpCont Size 10,10 NoBorder When .F. Pixel
	TSay():New(09,18,{|| cEmpresa },oEmpCont,,,,,,.T.,CLR_HRED,CLR_WHITE)
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega todas as variaveis de memoria tipo private que serao utilizadas nos paineis³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RegToMemory("SU5",.F.)
	RegToMemory(aEmpCont[9][3],.F.)
	RegToMemory("SUA",.F.)
	RegToMemory("SB1",.F.)
	RegToMemory("SE1",.F.)
	RegToMemory("SUO",.F.)
	RegToMemory("ACD",.F.)
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Função que monta todos os paineis³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Processa( {|| TK010MontaPanel(oExplorer, aEmpCont ,aFuncPanels)}, STR0024, STR0025) //"Criacao dos Paineis","Pesquisando dados..."
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria as informacoes do primeiro painel ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	&(aFuncPanels[1])
	
	oExplorer:Activate(.T.,bValid)      

	SetKey(VK_F10,Nil)
Endif	
		
If FunName() == "TMKA070"
	aRotina	:= aRotinaBkp
EndIf

//Finaliza o gerenciamento dos campos com proteção de dados.
FATPDUnLoad()

RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK010MontaPanelºAutor ³Armando TessaroliºData ³  02/07/02       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Comandos para criacao do Tree com o respectivo painel para      º±±
±±º          ³cada item da arvore, com funcao para instancia dos objetos      º±±
±±º          ³que cada painel ira conter.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Pefil do Contato                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMarcelo K.³16/11/04³8.11  ³--Revisao do fonte:Sintaxe,Documentacao,e Logicaº±±
±±ºHanna C.  ³23/03/07³9.12  ³BOPS 121961 - Substituido o botao bmpparam para º±±
±±º          ³        ³      ³"SDUPROP"                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK010MontaPanel(oExplorer ,aEmpCont ,aFuncPanels)

Local aArea     := GetArea()				// Salva a area atual
Local aBtnEnt	  := {}						// Array de botoes para entregas agendadas
Local aPanUsr	  := {}						// Paineis do usuario
Local nPanel	  := 0 						// Numero do painel atual
Local nCont	  := 0						// Contador auxiliar
Local lButEnt	  := ExistBlock("TK10CBTE")	// Indicador de presenta de Ponto de entrada
Local lPanUsr	  := ExistBlock("TK10PNUS")	// Indicador de presenta de Ponto de entrada
Local cDescPerf := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para criacao de botoes no painel de entregas agendadas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lButEnt
	aBtnEnt := ExecBlock("TK10CBTE",.F.,.F.)
	If ValType(aBtnEnt) <> "A"
		aBtnEnt := {}
	EndIf
EndIF

ProcRegua(50)

If Trim(aEmpCont[9][3]) == "SUS"
	cDescPerf := STR0129    //"Perfil do Prospect"
ElseIf Trim(aEmpCont[9][3]) == "SA1"
	cDescPerf := STR0127   //"Perfil do Cliente"
ElseIf Trim(aEmpCont[9][3]) == "ACH"
	cDescPerf := STR0130   //"Perfil do Suspect"
ElseIf Trim(aEmpCont[9][3]) == "SU5"
	cDescPerf := STR0126 //"Perfil do Contato"
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da Arvore          - Nivel 0 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                          
	oExplorer:AddTree(Padr(cDescPerf,150),"SDUPROP",,Padr(StrZero(++nPanel,7),20))
Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Perfil do Cliente"
Aadd(aFuncPanels,"TKC010Pn01(oExplorer,"+Str(nPanel)+", aEmpCont)")
IncProc()

If Trim(aEmpCont[1][3]) <> "" // Se contato for vazio, quando perfil da entidade não mostra informações de contato
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do 1. Grupo        - Nivel 1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oExplorer:AddTree(Padr(STR0027,150),"BMPUSER",,Padr(StrZero(++nPanel,7),20))
	Aadd( oPanels, 	oExplorer:GetPanel(nPanel) ) //"Contato"
	Aadd(aFuncPanels,"TKC010Pn02(oExplorer,"+Str(nPanel)+", aEmpCont)")
	IncProc()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao do 1. Sub-Grupo    - Nivel 2 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oExplorer:AddTree(Padr(STR0028,150),"FOLDER12",,Padr(StrZero(++nPanel,7),20)) 
		Aadd( oPanels,oExplorer:GetPanel(nPanel) ) //"Telemarketing"
		Aadd(aFuncPanels,"TKC010Pn03(oExplorer,"+Str(nPanel)+", aEmpCont)")
 		IncProc()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Criacao dos Itens          - Nivel 3 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 			oExplorer:AddItem(Padr(STR0029,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
 			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Encerramentos"
			Aadd(aFuncPanels,"TKC010PnTMK(oExplorer,"+Str(nPanel)+", aEmpCont,'"+P_TMK_ENCERRADOS+"')")
			IncProc()
		   
			oExplorer:AddItem(Padr(STR0030,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Ativos"
			Aadd(aFuncPanels,"TKC010PnTMK(oExplorer,"+Str(nPanel)+", aEmpCont,'"+P_TMK_ATIVOS+"')")
			IncProc()
			
			oExplorer:AddItem(Padr(STR0031,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Receptivos"
			Aadd(aFuncPanels,"TKC010PnTMK(oExplorer,"+Str(nPanel)+", aEmpCont,'"+P_TMK_RECEPTIVOS+"')")
			IncProc()

			oExplorer:AddItem(Padr(STR0032,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Follow Up"
			Aadd(aFuncPanels,"TKC010PnTMK(oExplorer,"+Str(nPanel)+", aEmpCont,'"+P_TMK_FOLLOW+"')")
			IncProc()
			
			oExplorer:AddItem(Padr(STR0033,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Pendências"
			Aadd(aFuncPanels,"TKC010PnTMK(oExplorer,"+Str(nPanel)+", aEmpCont,'"+P_TMK_PENDENCIAS+"')")
			IncProc()                          

			oExplorer:AddItem(Padr(STR0034,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
 			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Chamado Técnico"
			Aadd(aFuncPanels,"TKC010PnTMK(oExplorer,"+Str(nPanel)+", aEmpCont,'"+P_TMK_CHAMADO+"')")
			IncProc()
			
			oExplorer:AddItem(Padr(STR0035,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Atendimentos"
			Aadd(aFuncPanels,"TKC010PnTMK(oExplorer,"+Str(nPanel)+", aEmpCont,'"+P_TMK_ATEND+"')")
			IncProc()
			
		oExplorer:EndTree()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao do 3. Sub-Grupo    - Nivel 2 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oExplorer:AddTree(Padr(STR0038,150),"FOLDER12",,Padr(StrZero(++nPanel,7),20))
		Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Campanha"
		Aadd(aFuncPanels,"TKC01CAMP(oExplorer,"+Str(nPanel)+", aEmpCont,'"+P_CAMP+"')")
		IncProc()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Criacao dos Itens          - Nivel 3 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oExplorer:AddItem(Padr(STR0039,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) )//"Detalhado"
			Aadd(aFuncPanels,"TKC01CAMP(oExplorer,"+Str(nPanel)+", aEmpCont)")
			IncProc()
			               
			oExplorer:AddItem(Padr(STR0040,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Análise Scripts"
			Aadd(aFuncPanels,"TKC01CAMP(oExplorer,"+Str(nPanel)+", aEmpCont,'"+P_CAMP_ANSCRIPT+"')")
			IncProc()
			
			oExplorer:AddItem(Padr(STR0111,150),"FOLDER13", Padr(StrZero(++nPanel,7),20)) //"Script Resp."
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Scripts"
			Aadd(aFuncPanels,"Tkc10ScrDm(oExplorer:aPanel["+Str(nPanel)+"],'"+aEmpCont[9][3]+"','"+aEmpCont[10][3]+"','"+aEmpCont[1][3]+"')")
			IncProc()
			
		oExplorer:EndTree()
	oExplorer:EndTree()

EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do 2. Grupo        - Nivel 1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oExplorer:AddTree(Padr(STR0041,150),"BMPCPO",,Padr(StrZero(++nPanel,7),20))
	Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Empresa"
	Aadd(aFuncPanels,"TKC010Pn14(oExplorer,"+Str(nPanel)+", aEmpCont)")
	IncProc()                                                          
	
	If Trim(aEmpCont[1][3]) == "" //Desconsidera Folders quando a opção selecionada for perfil do contato
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao do 2. Sub-Grupo    - Nivel 2 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oExplorer:AddTree(Padr(STR0119,150),"FOLDER12",,Padr(StrZero(++nPanel,7),20))			//"Oportunidades"
		Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Oportunidades"
		Aadd(aFuncPanels,"Tkc010Opt(oExplorer,"+Str(nPanel)+", aEmpCont, '1,2,3,9')")
		IncProc()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Criacao dos Itens          - Nivel 3 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oExplorer:AddItem(Padr(STR0120,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))		//"Abertas" 
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Abertas"
			Aadd(aFuncPanels,"Tkc010Opt(oExplorer,"+Str(nPanel)+", aEmpCont, '1')")
			IncProc()                
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Criacao dos Itens          - Nivel 3 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oExplorer:AddItem(Padr(STR0121,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))		//"Suspensas" 	
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Suspensas"
			Aadd(aFuncPanels,"Tkc010Opt(oExplorer,"+Str(nPanel)+", aEmpCont, '3')")
			IncProc()                                                                               
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Criacao dos Itens          - Nivel 3 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oExplorer:AddItem(Padr(STR0122,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))		//"Perdidas" 
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Perdida"
			Aadd(aFuncPanels,"Tkc010Opt(oExplorer,"+Str(nPanel)+", aEmpCont, '2')")
			IncProc()                
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Criacao dos Itens          - Nivel 3 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oExplorer:AddItem(Padr(STR0123,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))		//"Ganhas"		 
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Ganha"
			Aadd(aFuncPanels,"Tkc010Opt(oExplorer,"+Str(nPanel)+", aEmpCont, '9')")
			IncProc()                
			
			oExplorer:EndTree()
   	EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao do 1. Sub-Grupo    - Nivel 2 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oExplorer:AddTree(Padr(STR0042,150),"FOLDER12",,Padr(StrZero(++nPanel,7),20))
		Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Televendas"
		Aadd(aFuncPanels,"TKC010Pn15(oExplorer,"+Str(nPanel)+", aEmpCont)")
		IncProc()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Criacao dos Itens          - Nivel 3 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oExplorer:AddItem(Padr(STR0043,150),"FOLDER13", Padr(StrZero(++nPanel,7),20)) 
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Orçamentos"
			Aadd(aFuncPanels,"TKC010TLV(oExplorer,"+Str(nPanel)+", aEmpCont,'"+P_TLV_ORCAMENTO+"')")
			IncProc()                
			
			oExplorer:AddItem(Padr(STR0044,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Faturamento"
			Aadd(aFuncPanels,"TKC010TLV(oExplorer,"+Str(nPanel)+", aEmpCont,'"+P_TLV_FATURAMENTO+"')")
			IncProc()                          
			
			oExplorer:AddItem(Padr(STR0045,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Cancelamentos"
			Aadd(aFuncPanels,"TKC010TLV(oExplorer,"+Str(nPanel)+", aEmpCont,'"+P_TLV_CANCELADO+"')")
			IncProc()        
			
			oExplorer:AddItem(Padr(STR0046,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Vendas SigaLoja"
			Aadd(aFuncPanels,"TKC010TLV(oExplorer,"+Str(nPanel)+", aEmpCont,'"+P_TLV_SIGALOJA+"')")
			IncProc()                                                         
			
			oExplorer:AddItem(Padr(STR0047,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Bônus"
			Aadd(aFuncPanels,"TKC010TLV(oExplorer,"+Str(nPanel)+", aEmpCont,'"+P_TLV_BONUS+"')")
			IncProc()                           
			
			oExplorer:AddItem(Padr(STR0048,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Mais Comprados"
			Aadd(aFuncPanels,"TKC010Pn21(oExplorer,"+Str(nPanel)+", aEmpCont)")
			IncProc()                          
			
		oExplorer:EndTree()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao do 2. Sub-Grupo    - Nivel 2 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oExplorer:AddTree(Padr(STR0036,150),"FOLDER12",,Padr(StrZero(++nPanel,7),20))
		Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Conhecimento"
		Aadd(aFuncPanels,"TKC010Pn22(oExplorer,"+Str(nPanel)+", aEmpCont)")
		IncProc()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Criacao dos Itens          - Nivel 3 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oExplorer:AddItem(Padr(STR0037,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Análise Banco"
			Aadd(aFuncPanels,"TKC010Pn23(oExplorer,"+Str(nPanel)+", aEmpCont)")
			IncProc()
		oExplorer:EndTree()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao do 3. Sub-Grupo    - Nivel 2 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oExplorer:AddTree(Padr(STR0049,150),"FOLDER12",,Padr(StrZero(++nPanel,7),20))
		Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Telecobrança"
		Aadd(aFuncPanels,"TKC010Pn24(oExplorer,"+Str(nPanel)+", aEmpCont)")
		IncProc()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Criacao dos Itens          - Nivel 3 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oExplorer:AddItem(Padr(STR0050,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Cobranças"
			Aadd(aFuncPanels,"TKC010Pn25(oExplorer,"+Str(nPanel)+", aEmpCont)")
			IncProc()   

			oExplorer:AddItem(Padr(STR0051,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))			
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Negociação"
			Aadd(aFuncPanels,"TKC010Pn26(oExplorer,"+Str(nPanel)+", aEmpCont)")
			IncProc()      
			
			oExplorer:AddItem(Padr(STR0052,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Ocorrências"
			Aadd(aFuncPanels,"TKC010Pn27(oExplorer,"+Str(nPanel)+", aEmpCont)")
			IncProc()               
			
			oExplorer:AddItem(Padr(STR0053,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Cobr. Vencida"
			Aadd(aFuncPanels,"TKC010Pn28(oExplorer,"+Str(nPanel)+", aEmpCont)")
			IncProc()
			
			oExplorer:AddItem(Padr(STR0054,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Cobr. a Realizar"
			Aadd(aFuncPanels,"TKC010Pn29(oExplorer,"+Str(nPanel)+", aEmpCont)")
			IncProc()                         
			
		oExplorer:EndTree()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao do 4. Sub-Grupo    - Nivel 2 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oExplorer:AddTree(Padr(STR0055,150),"FOLDER12",,Padr(StrZero(++nPanel,7),20))
		Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Análise Financeira"
		Aadd(aFuncPanels,"TKC010Pn30(oExplorer,"+Str(nPanel)+", aEmpCont)")
		IncProc()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Criacao dos Itens          - Nivel 3 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oExplorer:AddItem(Padr(STR0056,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Vencidos"
			Aadd(aFuncPanels,"TKC010Pn31(oExplorer,"+Str(nPanel)+", aEmpCont)")
			IncProc()                          
			
			oExplorer:AddItem(Padr(STR0057,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"A vencer"
			Aadd(aFuncPanels,"TKC010Pn32(oExplorer,"+Str(nPanel)+", aEmpCont)")
			IncProc()                                                         
			
			oExplorer:AddItem(Padr(STR0058,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Pagto c/ Atrazo"
			Aadd(aFuncPanels,"TKC010Pn33(oExplorer,"+Str(nPanel)+", aEmpCont)")
			IncProc()                                                                 
			
			oExplorer:AddItem(Padr(STR0059,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Pagto Cartório"
			Aadd(aFuncPanels,"TKC010Pn34(oExplorer,"+Str(nPanel)+", aEmpCont)")
			IncProc()                         
			
			oExplorer:AddItem(Padr(STR0060,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Protestados"
			Aadd(aFuncPanels,"TKC010Pn35(oExplorer,"+Str(nPanel)+", aEmpCont)")
			IncProc()
			
			oExplorer:AddItem(Padr(STR0061,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Posição Financ."
			Aadd(aFuncPanels,"TKC010Pn36(oExplorer,"+Str(nPanel)+", aEmpCont)")
			IncProc()   
			
			oExplorer:AddItem(Padr(STR0080,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"NCC's em aberto"
			Aadd(aFuncPanels,"TKC010Pn48(oExplorer,"+Str(nPanel)+", aEmpCont)")
			IncProc()                             
			
		oExplorer:EndTree()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao do 4. Sub-Grupo    - Nivel 2 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oExplorer:AddTree(Padr(STR0081,150),"FOLDER12",,Padr(StrZero(++nPanel,7),20))
		Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Vendas"
		Aadd(aFuncPanels,"TKC010Pn43(oExplorer,"+Str(nPanel)+", aEmpCont)")
		IncProc()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Criacao dos Itens          - Nivel 3 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oExplorer:AddItem(Padr(STR0082,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Loja"
			Aadd(aFuncPanels,"TKC010Pn44(oExplorer,"+Str(nPanel)+", aEmpCont)")
			IncProc()                          
			
			oExplorer:AddItem(Padr(STR0044,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Faturamento"
			Aadd(aFuncPanels,"TKC010Pn45(oExplorer,"+Str(nPanel)+", aEmpCont)")
			IncProc() 
			
			oExplorer:AddItem(Padr(STR0083,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Entregas agendadas"
			Aadd(aFuncPanels,"TKC010Pn46(oExplorer,"+Str(nPanel)+", aEmpCont)")				
            
			//Botoes adicionais para entregas agendadas
			If lButEnt
				For nCont := 1 to Len(aBtnEnt)
					oExplorer:AddButton(nPanel,aBtnEnt[nCont][1],If(Len(aBtnEnt[nCont])>=4,aBtnEnt[nCont][4],aBtnEnt[nCont][3]),aBtnEnt[nCont][2],/*cDefaultAct*/,/*bWhen*/,aBtnEnt[nCont][3])
				Next nCont
			EndIf
			IncProc()                                                           

			//Devolucoes
			oExplorer:AddItem(Padr(STR0084,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Faturamento"
			Aadd(aFuncPanels,"TKC010Pn49(oExplorer,"+Str(nPanel)+", aEmpCont)")
			IncProc() 
			
			If ALLTRIM(aEmpCont[9][3]) == "SA1" 		
				oExplorer:AddItem(Padr(STR0103,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
				Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Ticket Médio"
				Aadd(aFuncPanels,"TKC010Pn51(oExplorer,"+Str(nPanel)+", aEmpCont)")
				
				oExplorer:AddItem(Padr(STR0104,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
				Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Categoria de Produto"
				Aadd(aFuncPanels,"TKC010Pn52(oExplorer,"+Str(nPanel)+", aEmpCont)")				
				
			EndIf								
			
		oExplorer:EndTree()
		
	oExplorer:EndTree()
      
	If Trim(aEmpCont[1][3]) == "" //Desconsidera Folders quando a opção selecionada for perfil do contato
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao do 3. Grupo        - Nivel 1 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oExplorer:AddTree(Padr(STR0124,150),"NG_ICO_MULTAS1",,Padr(StrZero(++nPanel,7),20))//Contatos
		Aadd( oPanels, 	oExplorer:GetPanel(nPanel) ) //"Contato"
		Aadd(aFuncPanels,"Tkc010PnCT(oExplorer,"+Str(nPanel)+", aEmpCont)")				
		IncProc()
	EndIf
                                                                     
	oExplorer:EndTree()
	                                      
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do 4. Grupo        - Nivel 1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oExplorer:AddTree(Padr(STR0062,150),"CRITICA",,Padr(StrZero(++nPanel,7),20))
	Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Marketing"
	Aadd(aFuncPanels,"TKC010Pn37(oExplorer,"+Str(nPanel)+", aEmpCont)")
	IncProc()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao do 1. Sub-Grupo    - Nivel 2 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oExplorer:AddTree(Padr(STR0128,150),"FOLDER12",,Padr(StrZero(++nPanel,7),20))
		Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Lista de Contatos"
		Aadd(aFuncPanels,"TKC010Pn38(oExplorer,"+Str(nPanel)+", aEmpCont)")
		IncProc()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Criacao dos Itens          - Nivel 3 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oExplorer:AddItem(Padr(STR0063,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Lista"
			Aadd(aFuncPanels,"TKC010Pn39(oExplorer,"+Str(nPanel)+", aEmpCont)")
			IncProc()                          
			
			oExplorer:AddItem(Padr(STR0064,150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Resultado"
			Aadd(aFuncPanels,"TKC010Pn40(oExplorer,"+Str(nPanel)+", aEmpCont)")
			IncProc()                           
			
		oExplorer:EndTree()
	oExplorer:EndTree()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do 5. Grupo        - Nivel 1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	oExplorer:AddTree(Padr(STR0125,150),"CHECKED",,Padr(StrZero(++nPanel,7),20) )
	Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Serviço"
	Aadd(aFuncPanels,"TKC010Pn41(oExplorer,"+Str(nPanel)+", aEmpCont)")
	IncProc()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao do 1. Sub-Grupo    - Nivel 2 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oExplorer:AddTree(Padr(STR0034,150),"FOLDER13",,Padr(StrZero(++nPanel,7),20))
		Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Chamado Técnico"
		Aadd(aFuncPanels,"TKC010Pn42(oExplorer,"+Str(nPanel)+", aEmpCont)")
		IncProc()
   		oExplorer:EndTree()
		
		oExplorer:AddTree(Padr(STR0085,150),"FOLDER13",,Padr(StrZero(++nPanel,7),20))
		Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Ordem Serviço"
		Aadd(aFuncPanels,"TKC010Pn47(oExplorer,"+Str(nPanel)+", aEmpCont)")
		IncProc()
		oExplorer:EndTree()
		
		oExplorer:AddTree(Padr(STR0089,150),"FOLDER13",,Padr(StrZero(++nPanel,7),20))
		Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Agendamentos"
		Aadd(aFuncPanels,"TKC010Pn50(oExplorer,"+Str(nPanel)+", aEmpCont)")
		IncProc()			
		
	oExplorer:EndTree()
oExplorer:EndTree()   	
If ALLTRIM(aEmpCont[9][3]) == "SA1" 			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao do 6. Grupo        - Nivel 1 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		oExplorer:AddTree(Padr(STR0105,150),"PRECO",,Padr(StrZero(++nPanel,7),20) )
		Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Varejo"
		Aadd(aFuncPanels,"TKC010Pn53(oExplorer,"+Str(nPanel)+", aEmpCont)")
		IncProc()
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Criacao do 1. Sub-Grupo    - Nivel 2 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oExplorer:AddTree(Padr(STR0106,150),"FOLDER13",,Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Regra Desconto"
			Aadd(aFuncPanels,"TKC010Pn54(oExplorer,"+Str(nPanel)+", aEmpCont,'"+P_VAR_REGDES+"')")
			IncProc()
	   		oExplorer:EndTree()
	   		
			oExplorer:AddTree(Padr(STR0107,150),"FOLDER13",,Padr(StrZero(++nPanel,7),20))//"Venda Perdida"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Venda Perdida"
			Aadd(aFuncPanels,"TKC010Pn55(oExplorer,"+Str(nPanel)+", aEmpCont,'"+P_VAR_VPERDIDA+"')")
			IncProc()
	   		oExplorer:EndTree()	  
	   		
			oExplorer:AddTree(Padr(STR0108,150),"FOLDER13",,Padr(StrZero(++nPanel,7),20))//"Cartão Fidelidade"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Cartão Fidelidade"
			Aadd(aFuncPanels,"TKC010Pn56(oExplorer,"+Str(nPanel)+", aEmpCont,'"+P_VAR_CARTAO+"')")
			IncProc()
	   		oExplorer:EndTree()		   				
			
		oExplorer:EndTree()	
	oExplorer:EndTree()
EndIf    

If lPanUsr

		aPanUsr := Execblock("TK10PNUS",.F.,.F.)

		If ValType(aPanUsr) == "A" .AND. Len(aPanUsr) > 0

			oExplorer:AddTree(Padr(STR0086,150),"OBJETIVO",,Padr(StrZero(++nPanel,7),20))
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) //"Específico"
			Aadd(aFuncPanels,"TKC010Pn38(oExplorer,"+Str(nPanel)+", aEmpCont)")
			IncProc()
			
			For nCont := 1 to Len(aPanUsr)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Criacao dos Itens          - Nivel 3 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oExplorer:AddItem(Padr(aPanUsr[nCont][1],150),"FOLDER13", Padr(StrZero(++nPanel,7),20))
				Aadd( oPanels, oExplorer:GetPanel(nPanel) )
				Aadd(aFuncPanels, AllTrim(aPanUsr[nCont][2]) + "(oExplorer,"+Str(nPanel)+", aEmpCont)")
				IncProc()    
	
			Next nCont                     
	                       
		EndIf
EndIf

RestArea(aArea)

Return(Nil) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010SD    ºAutor  ³Armando M. Tessaroli  º Data ³  12/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta o panel com informacoes para o caso de nao haver dados    º±±
±±º          ³para serem pesquisados na base.                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Pefil do Contato                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMarcelo K.³16/11/04³8.11  ³--Revisao do fonte:Sintaxe,Documentacao,e Logicaº±±
±±º          ³        ³      ³                                                º±±
±±º          ³        ³      ³                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TKC010SD(oExplorer, nPanel, aTexto)

Local nTop       := 0		// Posicao no TOPO
Local nLeft      := 0		// Posicao na ESQUERDA
Local nBottom    := 0		// Posicao ABAIXO
Local nRight     := 0		// Posicao na DIREITA
Local oBmp1					// Bitmap
Local nI         := 0		// Contador
Local cTextSay				// Texto

nRight := oExplorer:GetPanel(nPanel):nRight/2
nBottom := oExplorer:GetPanel(nPanel):nBottom/2

//"Atencao, nao existe movimento de Call Center para este contato ou empresa, neste assunto"
TSay():New(nTop+10,nLeft+10,{|| STR0076 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_HRED,CLR_WHITE) 

@ nTop+20, nLeft+10 TO nBottom, nRight Label "" Of oExplorer:GetPanel(nPanel) Pixel

If Len(aTexto) > 0
	
	For nI := 1 TO Len(aTexto)
		If aTexto[nI] <> Nil
			cTextSay := "{||'"+aTexto[nI]+"'}"
			TSay():New(nTop+20+(nI*10),nLeft+20,MontaBlock(cTextSay),oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_HBLUE,CLR_WHITE)
		EndIf
	Next nI
	
Else
	TSay():New(nTop+30,nLeft+20,{|| STR0077 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_HBLUE,CLR_WHITE) //"Nao ha informaçoes adicionais"
Endif

@ nTop, nLeft BitMap oBmp1 ResName "PROJETOAP" Of oExplorer:GetPanel(nPanel) /*Size nRight/6, nBottom+10 NoBorder*/ When .F. Pixel Adjust
oBmp1:lAutoSize := .T.

Return(Nil)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TKC010GRAP

Desenha o painel do gráfico com componente factory responsável por gerar os gráficos.

@param oGraphic Objeto com Instancia do Grafico que será criado pela FwChartFactory. Pode ser passado por referencia 
@param nTop Posição Top do Painel
@param nLeft Posição Esquerda do Painel
@param nRight Posição Direita do Painel
@param nBottom Posição Inferior do Painel
@param oPai Objeto em que será criado o painel do gráfico. Ex: dialog ou outro panel.
@param aSerie Serie de valores do gráfico conforme FwChartFactory
@param nAlign Alinhamento das Legendas conforme FwChartFactory 
@param cTitle Titulo do Gráfico conforme FwChartFactory
@param cPict Picture dos Valores da Série conforme FwChartFactory
@param cMask Máscara dos Valores conforme FwChartFactory
@param lCores modificar cores do grafico

/*/
//--------------------------------------------------------------------------------------------------------------------
Function TKC010GRAP(oGraphic,nTop,nLeft,nRight,nBottom,oPai,aSerie,nAlign,cTitle,cPict,cMask,lCores)
Local nLenAux			:= 0
Local nI				:= 0
Local cCbxResA		:= ""
Local aCbxResA		:= {}
Local aGraficos		:= {{STR0098,BARCHART},{STR0099,LINECHART},{STR0100,PIECHART},{STR0101,BARCOMPCHART}}//"Barra"#"Linhas"#"Pizza"#"Barras"
Local nTpChart		:= 0
Local oPanGra			:= NIL
Local oPanelCombo		:= NIL
Static oFwChart		:= NIL

Default nAlign		:= CONTROL_ALIGN_BOTTOM
Default cTitle		:= ""	
Default cPict			:= "@E 999,999,999.99%"
Default cMask			:= ""

Default lCores      := .F.

oPanelCombo	:= tPanel():New(nTop,nLeft,"",oPai,,,,CLR_WHITE,CLR_WHITE,nRight,15)
oPanGra		:= tPanel():New(nTop+15,nLeft,"",oPai,,,,CLR_WHITE,CLR_WHITE,nRight,nBottom-15)

If Len(aSerie) > 0 .AND. ValType(aSerie[1][2]) == "A"
	aCbxResA := {STR0101,STR0099} //Barras#Linhas
Else
	aCbxResA := {STR0098,STR0100} //Barra#Pizza
EndIf
cCbxResA := aCbxResA[1]

If ValType(oFwChart) <> "O"
	oFwChart := FwChartFactory():New()
EndIf 

//Seta Grafico Default do Combo conforme parâmetro do pergunte
If Len(aSerie) == 0 .OR. aSerie[1][1] == 4
	cCbxResA := aCbxResA[1] 
ElseIf Len(aSerie) >= 0 .AND. aSerie[1][1] == 10
	cCbxResA := aCbxResA[2] 
EndIf
*/
@ 04, 05 Say STR0102 Size 050, 008 Pixel Of oPanelCombo //"Tipo de Gráfico"
@ 02, 55 ComboBox cCbxResA Items aCbxResA Size 055, 010 Pixel Of oPanelCombo;	
	On Change (	nTpChart := aScan( aGraficos, {|xVar| xVar[1] == cCbxResA}),;												
				TKC010Chart(@oFwChart,@oGraphic,oPanGra,aGraficos[nTpChart][2],aSerie,nAlign,cTitle,cPict,cMask,lCores))

TKC010Chart(@oFwChart,@oGraphic,oPanGra,aGraficos[aScan(aGraficos,{|xVar| xVar[1] == cCbxResA})][2],aSerie,nAlign,cTitle,cPict,cMask,lCores)

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TKC010Chart

Configura a Instancia de FwChartFactory conforme opções do painel de TKC010GRAP.

@param oFwChart Objeto FwChartFactory. 
@param oGraphic Objeto com Instancia do Grafico que será criado pela FwChartFactory. Pode ser passado por referencia
@param oPanGra Painel em que será criado o gráfico
@param nTpChart Tipo de Gráfico a instanciar conforme FwChartFactory
@param aSerie Serie de valores do gráfico conforme FwChartFactory
@param nAlign Alinhamento das Legendas conforme FwChartFactory 
@param cTitle Titulo do Gráfico conforme FwChartFactory
@param cPict Picture dos Valores da Série conforme FwChartFactory
@param cMask Máscara dos Valores conforme FwChartFactory
@param lCores modificar cores do grafico
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TKC010Chart(oFwChart,oGraphic,oPanGra,nTpChart,aSerie,nAlign,cTitle,cPict,cMask,lCores)
									
Local nLenAux := 0
Local nI		:= 0
Local nSoma	:= 0

If Valtype(oGraphic) == "O"
	FreeObj(oGraphic) 
EndIf
										
oGraphic := oFwChart:getInstance( nTpChart ) 	

If cTitle <> ""
	oGraphic:setTitle( cTitle, CONTROL_ALIGN_CENTER )
EndIf

oGraphic:setLegend( nAlign )

If cMask <> ""
	oGraphic:setMask( cMask )
EndIf
If cPict <> ""
	oGraphic:setPicture( cPict )
EndIf

oGraphic:init(oPanGra, .T., .T. )

nLenAux := LEN(aSerie)

For nI := 1 To nLenAux
	oGraphic:addSerie(aSerie[nI][3], aSerie[nI][2])
Next nI

If lCores
	oGraphic:setColor("Random") 
EndIf

oGraphic:Build()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tkc10Locza

Localiza a informacao digitada pelo usuario conforme a coluna selecionada o combobox.

@sample		Tkc10Locza(oCbxLoc,oLbx,cTexto)

@param			ExpO1 ComboBox com as colulas do ListBox.	
				ExpO2 ListBox.			
				ExpC3 Texto a ser localizado.
				
@return		Verdadeiro / Falso

@author		Anderson Silva	
@since			05/07/2013
@version		P12
/*/
//------------------------------------------------------------------------------
Static Function Tkc10Locza(oCbxLoc,oLbx,cTexto)

Local lRetorno		:= .F.								// Retorno da validacao
Local nX 			:= 0 								// Incremento utilizado no For
Local nPosLin		:= 0								// Linha do array depara.
Local nColuna		:= 0								// Coluna do array do listbox.
Local cTxtLbx		:= ""								// Texto do listbox.
Local cTxtLoc		:= AllTrim(cTexto)				// Texto a ser localizado.
Local nOpCbxSel	:= oCbxLoc:nAt						// Opcao selecionada no combobox.

nPosLin := aScan(oCbxLoc:Cargo,{|x| x[1] == nOpCbxSel }) 
nColuna := oCbxLoc:Cargo[nPosLin][2]

For nX := 1 To Len(oLbx:aArray)
	cTxtLbx := SubStr(Upper(oLbx:aArray[nX][nColuna]),1,Len(cTxtLoc))
	If cTxtLbx $ cTxtLoc	
		lRetorno := .T.
		oLbx:GoPosition(nX)
		oLbx:GoColumn(nOpCbxSel)
		oLbx:SetFocus()
		Exit
	EndIf
Next

Return(lRetorno)

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usuário utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que serão verificados.
    @param aFields, Array, Array com todos os Campos que serão verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com proteção de dados.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDColObfuscate
    @description
    Verifica se a coluna de um grid deve ser ofuscado, tendo como base uma lista de
    campos, esta função deve utilizada somente após a inicialização das variaveis 
    atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.

    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate({"A1_COD","A1_NOME","A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDColObfuscate(aFields, cSource)  
    
	Local aPDColObf	:= {}

    If FATPDActive()
		aPDColObf := FTPDColObfuscate(aFields, cSource)  
    EndIf 

Return aPDColObf  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

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
