#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA510.CH"
 
#DEFINE ID         		1 // Id do Celula
#DEFINE OBJETO     		2 // Objeto de Tela
#DEFINE DATADIA    		3 // Data Completa da Celula
#DEFINE DIA        		4 // Dia Ref. Data da Celula
#DEFINE MES        		5 // Mes Ref. Data da Celula
#DEFINE ANO        		6 // Ano Ref. Data da Celula
#DEFINE NSEMANO    		7 // Semana do Ano Ref. Data da Celula
#DEFINE NSEMMES    		8 // Semana do Mes Ref. Data da Celula
#DEFINE ATIVO      		9 // É celula referente a um dia ativo
#DEFINE FOOTER    		10 // É celula referente ao rodape
#DEFINE HEADER    		11 // É celula referente ao Header
#DEFINE SEMANA    		12 // É celula referente a semana
#DEFINE BGDefault 		13 // Cod de BackGround da Celula
#DEFINE LISTBX       	14 // Referente a List Box
#DEFINE WEEKEND      	15 // Indica se é Sabado ou Domingo

// Posições do array de filtro
#DEFINE nPosAteDe		1
#DEFINE nPosAteAte		2
#DEFINE nPosCliDe		3
#DEFINE nPosCliAte		4
#DEFINE nPosConDe		5
#DEFINE nPosConAte		6
#DEFINE nPosProDe		7
#DEFINE nPosProAte		8
#DEFINE nPosSerDe		9
#DEFINE nPosSerAte 		10
#DEFINE nPosEqpDe		11
#DEFINE nPosEqpAte		12
#DEFINE nPosNOsDe		13
#DEFINE nPosNOsAte 		14
#DEFINE nPosVisDe		15
#DEFINE nPosVisAte		16
#DEFINE nPosTipo		17
#DEFINE nPosLocDe		18
#DEFINE nPosLocAte		19

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³  TECA510    ³ Autor ³ Vendas CRM         ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ 	Grade de Alocação(Agenda do Técnico)					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function TECA510(cNumOs,cCodAtd,cCodCont,lExecPerg)
Local cMes    				:= ""										//Variavel do mes corrente
Local cAno    				:= ""										//Variavel do ano corrente
Local cMesAno 				:= ""										//Variavel com o anoemes
Local aSize	 				:= {}										//Array com o tamnho da tela
Local cRet					:= ""										//Variavel de Retorno
Local nColor 				:= 16777215                      			//Fundo Branco
Local aCombo 				:= {STR0001,STR0002,STR0003,STR0063, STR0058}  		//Array com os Itens do ComboBox {'Técnico','Contrato','Cliente','Base Atendimento'}
Local cCombo1				:= aCombo[1]                    			//RedVar do ComBox
Local aFilter 				:= {}										//Array do filtro 
Local oData																//Objeto Data
Local nI 					:= 0                
Local lPercTec   			:= SuperGetMv('MV_TECPCON',,.F.)  

Default cNumOs				:= ""										//Numero da O.S.
Default cCodAtd				:= ""   
Default cCodCont			:= ""
Default lExecPerg			:= .F.
Static oFWLayer                                 						//Layer
Static oPanSup                                  						//Layer Superior
Static oPanCen                                  						//Layer Central
Static oPanInf                                  						//Layer Inferior
Static oPanCal                                  						//Layer do Botão do Calendario
Static oPanEnd                                  						//Layer do Botão de Sair 
Static oPanPY		 							 						//Layer do Botão de Ano Anterior 
Static oPanPM									 						//Layer do Botão de Mes Anterior
Static oPanNM									 						//Layer do Botão de Proximo Mes
Static oPanNY									 						//Layer do Botão de Proximo Ano
Static oPanCom     								 						//Layer do combobox
Static oCombo1															//Objeto do ComboBox

Static oPanBox															//Nova tela a esquerda
Static oCalBox															//Nova tela a esquerda
Static oTWBrowse														//TWBrowse para a tela a esquerda
Static bLine 				:= {|aBrowse| AT510bline(aBrowse)}			//Bloco de codigo para o Duplo-Click da TWBrowse

Static oTButton															//Objto do Botão("Limpar Filtros")	
Static oListBox															//ListBox

Static oMBrwWA				:= Nil										// Objeto do browse
Static bFilter 				:= {|aFwFilter|AT510Filter( aFwFilter,cAlias,oCalend,oCombo1:nAt)} 	 			//Bloco de codigo chamado pelo valide da MBrowse
Static cTitulo 				:= ""																			//Variavel com o Titulo da Dialog
Static cNumeroOs			:= ""
Static lAcesso				:= .F.
Static aPerm				:= {}
Static aFiltro				:= {}

Private cCadastro 			:= STR0004									//"Alocação de Técnicos"											
Private aRotina 			:= MenuDef()
Private oDlgCall
Private cCodAtend			:= IIF(ValType(cCodAtd)=="C",cCodAtd,"")
Private cCodContr			:= IIF(ValType(cCodCont)=="C",cCodCont,"")

aPerm	:= At201Perm()

cNumeroOs := cNumOs

cMes    := StrZero( Month( dDataBase ) , 2 )
cAno    := StrZero( Year( dDataBase )  , 4 )
cMesAno := AllTrim( cMes ) + '/' + AllTrim( cAno )

aSize := FWGetDialogSize( oMainWnd )

lAcesso := (Len(aPerm) > 0 .Or. !lPercTec) 

If ! lAcesso
	Help("",1,"TECA510",,STR0059,2,0) //"Usuario sem permissão"
	Return(.F.)
Else 
	If FunName() == "TECA510" .OR. lExecPerg
		If ! At510FilAg(@aFiltro)
			Return(.F.)
		EndIf
		If lExecPerg
			cNumOs := ""
			cCodAtd := ""
			cCodCont := ""
			cCodContr := ""
		EndIF
	EndIf
EndIf 	 
If !isBlind()
	DEFINE MSDIALOG oDlgCall TITLE STR0049 FROM aSize[1], aSize[2] TO aSize[3], aSize[4] PIXEL  //"Grade de Alocação"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Inicializa o FWLayer		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFwLayer := FwLayer():New()
	oFwLayer:init(oDlgCall,.F.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Cria o Layer Superior	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFWLayer:addLine("ENTIDADES", 5, .F.)
	
	oFWLayer:addCollumn( "COLENT3",33, .T. , "ENTIDADES") 	//Linha do ComboBox	
	oFWLayer:addCollumn( "COLENT1",5, .T. , "ENTIDADES") 		//Linha do ano anterior
	oFWLayer:addCollumn( "COLENT2",5, .T. , "ENTIDADES") 		//Linha do mes anterior
	
	oFWLayer:addCollumn( "COL",37, .T. , "ENTIDADES") 		//Linha do Mes
	oFWLayer:addCollumn( "COL1",5, .T. , "ENTIDADES") 		//Linha do proximo mes
	oFWLayer:addCollumn( "COL2",5, .T. , "ENTIDADES") 		//Linha do proximo ano
	oFWLayer:addCollumn( "COLENT",5, .T. , "ENTIDADES") 		//Linha do Calendario
	oFWLayer:addCollumn( "COL3",5, .T. , "ENTIDADES") 		//Linha do sair
	
	oPanSup := oFWLayer:GetColPanel("COL","ENTIDADES")
	oPanCal := oFWLayer:GetColPanel("COLENT","ENTIDADES")
	oPanEnd := oFWLayer:GetColPanel("COL3","ENTIDADES")
	oPanPY	 := oFWLayer:GetColPanel("COLENT1","ENTIDADES")
	oPanPM	 := oFWLayer:GetColPanel("COLENT2","ENTIDADES")
	oPanNM	 := oFWLayer:GetColPanel("COL1","ENTIDADES")
	oPanNY	 := oFWLayer:GetColPanel("COL2","ENTIDADES")
	oPanCom := oFWLayer:GetColPanel("COLENT3","ENTIDADES")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Cria o Layer Central		³ 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFWLayer:addLine("CALEND", 60, .F.)
	
	oFWLayer:addCollumn( "COLENT2",23, .T. , "CALEND") //linha a esquerda
	oFWLayer:addCollumn( "COLENT1",77, .T. , "CALEND")
		
	oPanBox := oFWLayer:GetColPanel("COLENT2","CALEND")//linha a esquerda
	
	oPanCen := oFWLayer:GetColPanel("COLENT1","CALEND")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Cria o Layer Inferior	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFWLayer:addLine("Browse", 35, .F.)
	oFWLayer:addCollumn( "COLENT2",100, .F. , "Browse")
	
	oPanInf := oFWLayer:GetColPanel("COLENT2","Browse")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Inicializa o calendario	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oCalend := FWCalendar():New( cMes, cAno )
	oCalend:blDblClick  	:= { | aInfo | AT510DPClick( oDlgCall, oPanCen, oCalend, aInfo, cNumOs ) }
	oCalend:bRClicked   	:= { | aInfo, oObj, nRow, nCol | AT510BtDireita(oObj, nRow, nCol, oCalend, cNumOs  ) }
	
	oCalend:lWeekColumn 	:= .F.  // Exibe ou nao a coluna de semana
	oCalend:lFooterLine 	:= .F.  // Exibe ou nao o rodape
	
	oCalend:Activate( oPanCen )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Inicializa o TWBrowse	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	oTWBrowse := TWBrowse():New( 00 , 00, Iif(aSize[4]<1218,110,140),Iif(aSize[3]<820,168,245),,{STR0051,STR0052},{30,60},;
		                             oPanBox,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )  //'Codigo'#'Nome'
	oTWBrowse:bLDblClick := bLine	
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Cria o icone para a troca do mes no calendario		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 0, 0 BTNBMP oButCal Resource "BTCALEND" Size 24, 24 Of oPanCal  Pixel
	oButCal:cToolTip 	:= STR0006										//"Alterar calendário..."
	oButCal:bAction 	:= { || dDiaSel := AT510TROCA( oDlgCall, CTod( '01/' + oCalend:cRef ) ) , oCalend:SetCalendar( oPanCen, Month( dDiaSel ) , Year( dDiaSel ) ), AT510Title( oCalend ), AT510TEXTO( oCalend ) } //Calendário  
	oButCal:Align 	:= CONTROL_ALIGN_ALLCLIENT
	
	oCalend:SetInfo( oCalend:IdDay( 20 ), '<td>10</td><td>30</td><td>20</td>', .T.)
	oCalend:SetInfo( oCalend:IdDay( 21 ), '<td><tr><td>10</td><td>30</td><td>20</td></tr><tr><td>30</td><td>30</td><td>30</td></tr></td>', .T.)
	oCalend:SetInfo( oCalend:IdDay( 22 ), '<td>10</td><td>30</td><td>20</td>', .T.)
	
	oDlgCall:lMaximized := .T.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Cria o ComboBox da Perspectiva 	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE FONT oFonte NAME "Arial" BOLD 
	@ 02,02 SAY OemToAnsi( STR0007 ) SIZE 50, 08 OF oPanCom PIXEL FONT oFonte  //"Perspectiva:"
		
	oCombo1 := TComboBox():New(02,40,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},;
		                      aCombo,65,10,oPanCom,,{||AT510TEXTO(oCalend)};
		                       ,,,,.T.,,,,,,,,,'cCombo1')
	
	                         
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Cria TSay para aparecer o mes no centro da tela		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oMesAtual := TSay():New( 0, 0, {||}, oPanSup,,,,,,.T.,20,20,,,,,,,, .T. )
	oMesAtual:Align := CONTROL_ALIGN_ALLCLIENT
	oMesAtual:nClrPane     := nColor 
	
	cTitulo := oCalend:cNOMEMES + " / " + cAno
	cRet := AT510HtmlWeek(cTitulo)
	oMesAtual:SetText( cRet )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Cria os botões de mudança de Mês	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 0, 0 BTNBMP oNextMonth Resource "PMSSETADIR" Size 90, 90 Of oPanNM Pixel
	oNextMonth:cToolTip := STR0008    //"Proximo Mes"
	oNextMonth:bAction  := { || AT510NextMonth( oDlgCall, oPanCen, oCalend ) }
	oNextMonth:Align    := CONTROL_ALIGN_ALLCLIENT
	
	@ 0, 0 BTNBMP oPrevMonth Resource "PMSSETAESQ" Size 80, 90 Of oPanPM Pixel
	oPrevMontht:cToolTip := STR0010		//"Mes Anterior"
	oPrevMonth:bAction  := { || AT510PrevMonth(oDlgCall, oPanCen, oCalend ) }
	oPrevMonth:Align    := CONTROL_ALIGN_ALLCLIENT
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Cria os botões de mudança de Ano		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 0, 0 BTNBMP oNextYear Resource "PGNEXT" Size 90, 90 Of oPanNY Pixel
	oNextYear:cToolTip := STR0009     	//"Proximo Ano"
	oNextYear:bAction  := { || AT510NextYear( oDlgCall, oPanCen, oCalend ) }
	oNextYear:Align    := CONTROL_ALIGN_ALLCLIENT
	
	@ 0, 0 BTNBMP oPrevYear Resource "PGPREV" Size 80, 90 Of oPanPY Pixel
	oPrevYear:cToolTip := STR0011		//"Ano Anterior"	
	oPrevYear:bAction  := { || AT510PrevYear( oDlgCall, oPanCen, oCalend ) }
	oPrevYear:Align    := CONTROL_ALIGN_ALLCLIENT
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Cria o botão de sair		  				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 0, 0 BTNBMP oButEnd Resource "FINAL" Size 24, 24 Of oPanEnd Pixel
	oButEnd:cToolTip := STR0012			//"Sair"
	oButEnd:bAction  := {||oDlgCall:End()}
	oButEnd:Align    := CONTROL_ALIGN_ALLCLIENT
	                               
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	MBrowse da tela de detalhes		  		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	DbSelectArea("ABB")
	
	cAlias := "ABB"
	
	oMBrwWA:= FWMBrowse():New()
	oMBrwWA:SetAlias(cAlias)
	oMBrwWA:SetMenuDef("TECA510")
	oMBrwWA:SetOwner(oPanInf)
	oMBrwWA:DisableDetails()
	oMBrwWA:SetLocate()
	oMBrwWA:SetVldExecFilter(bFilter)
	oMBrwWA:Activate()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Coloca o texto no calendario				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Eval(bFilter)
	Eval(bLine)

	Activate MsDialog oDlgCall Centered

	If FindFunction("t510Save")
		t510Save({oDlgCall,oCalend})
	EndIf
EndIf

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AT510TROCA    Autor ³ Vendas CRM         ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ 	Realiza a Troca de mes no calendario				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ dRet(Dia de Referencia)				                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1: Area de Trabalho(oDlg)                               ³±±
±±³          ³ Exp2: Dia de Referencia                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function AT510TROCA( oWnd, dRef )

Local oDlgTroc												//Dialog 
Local oPanel 												//Objeto Panel
Local oCalend												//Objeto Calendario
Local oFooter												//Rodapé
Local oOk													//Objeto OK
Local oCancel												//Objeto Cancel
Local dRet := IIf( Empty( dRef ) , Date() , dRef )		//Data de referencia

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	Cria a tela para o calendario(MsCalend) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(isBlind())
	Define MsDialog oDlgTroc FROM 000, 000 To 200, 300 Pixel Of oWnd
	
	@ 000, 000 MsPanel oPanel Of oDlgTroc Size 100, 100
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	
	oCalend := MsCalend():New( 01, 01, oPanel, .T. )
	oCalend:Align   := CONTROL_ALIGN_ALLCLIENT
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Define o dia a ser exibido no calendário ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oCalend:dDiaAtu := dRet
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Code-Block para mudança de Dia			  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oCalend:bChange := { || dRet :=  oCalend:dDiaAtu }
	
	oCalend:CanMultSel := .F.
	
	@ 000, 000 MsPanel oFooter Of oDlgTroc Size 000, 010
	oFooter:Align   := CONTROL_ALIGN_BOTTOM
	
	@ 000, 000 Button oCancel Prompt STR0013  Of oFooter Size 030, 000 Pixel //Cancelar
	oCancel:bAction := { || oDlgTroc:End() }
	oCancel:Align   := CONTROL_ALIGN_RIGHT
	
	@ 000, 000 Button oOk     Prompt STR0014 Of oFooter Size 030, 000 Pixel //Confirmar
	oOk:bAction     := { || dRet := oCalend:dDiaAtu, oDlgTroc:End() }
	oOk:Align       := CONTROL_ALIGN_RIGHT

	Activate MsDialog oDlgTroc Centered
EndIf
Return  dRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AT510TEXTO  ³ Autor ³ Vendas CRM         ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Limpa e joga os dados no Calendario			              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1:OCalend :Objeto do Calendario(FWCALENDAR)             ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AT510TEXTO( oCalend )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	Limpa as celulas   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AT510Clear(oCalend)

If !isBlind() .OR. !FindFunction("t510Save") .OR. EMPTY(t510Save())
	If Len( oMBrwWA:oFwFilter:GetFilter() ) > 1
		oMBrwWA:oFwFilter:CleanFilter()
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Coloca o texto no calendario				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Eval(bFilter)
	Eval(bLine)
EndIf

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510DPClick ³ Autor ³ Vendas CRM         ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ 	Função de Duplo clik na celula do Calendario(FWCALENDAR)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1:oDlg(Dialog do Calendario)                            ³±±
±±³          ³ Exp2:oPanel(Panel do Calendario)                           ³±±
±±³          ³ Exp3:oCalend(Objeto do FwCalendar)                         ³±±
±±³          ³ Exp4:aInfo(Array das Informações)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AT510DPClick( oDlgCall, oPanCen, oCalend, aInfo, cNumOs )

If aInfo[ATIVO]
	AT510EditDia( oCalend, aInfo[ID], aInfo[2]:nAt, cNumOs )
ElseIf aInfo[HEADER]
	Return Nil
Else
	oCalend:SetCalendar( oPanCen, aInfo[MES], aInfo[ANO] )
	AT510TEXTO( oCalend )
EndIf

AT510Title(oCalend)

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510EditDia ³ Autor ³ Vendas CRM         ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ 	Mostra Informações do dia escolhido			              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1:oCalend(Objeto do FWCalendar)                         ³±±
±±³          ³ Exp2:cId(Id da Celula no calendario)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AT510EditDia( oCalend, cId, nAcell, cNumOs )

Local cGetTit 				:= PadR( oCalend:GetInfo( cId ) , 254 )   		//Retorno informações do dia
Local cGetDia 				:= ""   											//Retorno informações do dia
Local oDlgDia    												  				//Dialog			
Local aList 				:= {}
Local nI					:= 0
Local nSelect				:= 0			

aList := AClone(oCalend:aCell[nAcell][OBJETO]:oListBoxContent:aItems)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria a tela para mostrar Informações do dia escolhido		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Define MsDialog oDlgDia Title STR0015 From 178, 181 To 456, 550 Pixel  //Edição de Dia

oListBox := TListBox():New(001,001,{|u|if(Pcount()>0,nSelect:=u,nSelect)},aList,186,125,,oDlgDia,,,,.T.)
oListBox:cargo := AClone(oCalend:aCell[nAcell][OBJETO]:oListBoxContent:Cargo )

oListBox:bRClicked   	:= { || AT510BtDireita(oListBox,oListBox:nTop,oListBox:nLeft, oCalend, cNumOs ) }

Define SButton From 128, 160 Type 1 Enable Of oDlgDia Action oDlgDia:End()

Activate MsDialog oDlgDia Center

aList := {}

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510BtDireita ³ Autor ³ Vendas CRM       ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ 	Ações do Botão Direito									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1:oObj(Objeto do ListBox)                               ³±±
±±³          ³ Exp2:nRow(Coordenadas da ListBox)                          ³±±
±±³          ³ Exp3:nCol(Coordenadas da ListBox)                          ³±±
±±³          ³ Exp4:oCalend(oBjeto do FWCalendar)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AT510BtDireita( oObj, nRow, nCol, oCalend, cNumOs )
Local oMenu
Local oMenuItem	 := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria o Menu Pop-Up para o calendario	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MENU oMenu POPUP Of oObj

//-------------------------------------------------------------------
//  Só exibe a opçõa de incluir quando é necessário realizar
// inclusão de vistoria.. Vindo do:
// Wizard para Vistoria e Área de Trabalho dos Contratos
If IsInCallStack("At270Cmt") .Or. IsInCallStack("At270Agend") .Or. IsInCallStack("At330CAloc")
	aAdd( oMenuItem, MenuAddItem( STR0016	,,, .T.,,,, oMenu, 	{ ||  Iif(!TxRelease(),AT510GDInc(oObj , oCalend, 3 ,cNumOs),At510Exec(oObj , oCalend, 3 ,cNumOs)) } ,,,,, { || .T. } ) ) 	//Incluir
EndIf

aAdd( oMenuItem, MenuAddItem( STR0019	,,, .T.,,,, oMenu, 	{ ||  Iif(!TxRelease(),AT510GDInc(oObj , oCalend, 6 ,cNumOs),At510Exec(oObj , oCalend, 6 ,cNumOs)) } ,,,,, { || .T. } ) )		//Mover Para
aAdd( oMenuItem, MenuAddItem( STR0048	,,, .T.,,,, oMenu, 	{ ||  Iif(!TxRelease(),AT510GDInc(oObj , oCalend, 7 ,cNumOs),At510Exec(oObj , oCalend, 7 ,cNumOs)) } ,,,,, { || .T. } ) )		//Visualizar O.S

AAdd( oMenuItem, MenuAddItem( STR0057,,, .T.,,,, oMenu, 	{ || At510Exec(oObj , oCalend, 8 ,cNumOs) } ,,,,, { || .T. } ) )		//"Manut. Agenda"

ENDMENU

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se é ListBox, se for faz o calculo das Coordenadas	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:ClassName() == "TLISTBOX"
	Activate POPUP oMenu AT 40, IIf( oObj:nAt <= 4,(oObj:nAt * 15),(oObj:nAt *10)) Of oObj
Else
	Activate POPUP oMenu AT nRow, nCol Of oObj
EndIf

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef     ³ Autor ³ Vendas CRM         ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ 											                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina:= {}

aRotina:=	{{ STR0021 			,"AxPesqui" 			, 0 , 1 , , .F.},;    		// "Pesquisar"
				{ STR0020 		,"AT510MnGrade"			, 0 , 2 ,0 , .T.},;    		// "Visualizar"
				{ STR0016 		,"AT510MnGrade"			, 0 , 3 , 0 , .T.},;    	// "Incluir"
				{ STR0017 		,"AT510MnGrade"			, 0 , 4, 0 , .T.},;  		// "Alterar"
				{ STR0018 		,"AT510MnGrade"			, 0 , 5, 0 , .T.},;			// "Excluir"
				{ STR0050 		,"AT510ClFilter"		, 0 , 2, 0 , .T.},;			// "Limpar Filtros"
				{ STR0033  		,"AT510Legenda"    		, 0 , 2 , , .T.}}			//"Legenda"   			   				   			 

Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510HtmlWeek ³ Autor ³ Vendas CRM        ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ 	Cria o Texto ao centro da Tela em HTML			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Expressão em HTML										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1:cMes(Mes de Referencia)                               ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AT510HtmlWeek(cMes)
Local cRet := ''

cRet += '<body>' 
cRet += '	<P ALIGN="Center">'
cRet += '        <FONT FACE="MS SANS SERIF" COLOR="#000000"> <B> ' + cMes + ' </B> </FONT>'
cRet += '</body>'
cRet := StrTran( cRet, '  ', ' ' )

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510NextMonth ³ Autor ³ Vendas CRM       ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ 	Ação do Botão do Proximo Mes							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1:oDlg(Dialog do Calendario)                            ³±±
±±³          ³ Exp2:oPan(Objeto Panel do Calendario)                      ³±±
±±³          ³ Exp3:oCalend(Objeto do FWCalendar)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AT510NextMonth( oDlgCall, oPanCen, oCalend)

Local cMonth    	:= SubStr(oCalend:cRef, 1, 2)
Local cYear 		:= SubStr(oCalend:cRef, 4, 7)

If cMonth == "12"
	cMonth := "01"
	cYear := Soma1(cYear)
Else
	cMonth := Soma1(cMonth)
EndIf

oCalend:SetCalendar( oPanCen, cMonth, cYear )
Eval(bFilter)

AT510Title(oCalend,cMonth,cYear)

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510PrevMonth ³ Autor ³ Vendas CRM       ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o   ³ Ação do Botão Mes Anterior								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1:oDlg(Dialog do Calendario)                            ³±±
±±³          ³ Exp2:oPan(Objeto Panel do Calendario)                      ³±±
±±³          ³ Exp3:oCalend(Objeto do FWCalendar)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AT510PrevMonth( oDlgCall, oPanCen, oCalend)

Local nMonth    	:= oCalend:NMES
Local nYear     	:= oCalend:NANO	

If nMonth == 01
	nMonth := 12
	nYear := (nYear -1)
Else
	nMonth := (nMonth - 1)
EndIf

oCalend:SetCalendar( oPanCen, cValToChar(nMonth), cValToChar(nYear) )
Eval(bFilter)

AT510Title(oCalend,oCalend:cNOMEMES,cValToChar(nYear))

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510PrevYear  ³ Autor ³ Vendas CRM       ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o   ³ Ação do Botão de Ano Anterior							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1:oDlg(Dialog do Calendario)                            ³±±
±±³          ³ Exp2:oPan(Objeto Panel do Calendario)                      ³±±
±±³          ³ Exp3:oCalend(Objeto do FWCalendar)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AT510PrevYear( oDlgCall, oPanCen, oCalend)

Local nMonth    := oCalend:NMES
Local nYear     := oCalend:NANO

nYear := (nYear - 1)

oCalend:SetCalendar( oPanCen, cValToChar(nMonth), cValToChar(nYear) )
Eval(bFilter)

AT510Title(oCalend,oCalend:cNOMEMES,cValToChar(nYear))

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510NextYear    ³ Autor ³ Vendas CRM     ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o   ³ Ação do Botão Proximo Ano 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1:oDlg(Dialog do Calendario)                            ³±±
±±³          ³ Exp2:oPan(Objeto Panel do Calendario)                      ³±±
±±³          ³ Exp3:oCalend(Objeto do FWCalendar)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AT510NextYear( oDlgCall, oPanCen, oCalend)

Local nMonth    := oCalend:NMES
Local nYear     := oCalend:NANO

nYear := (nYear + 1)

oCalend:SetCalendar( oPanCen, cValToChar(nMonth), cValToChar(nYear) )
Eval(bFilter)

AT510Title(oCalend,oCalend:cNOMEMES,cValToChar(nYear))

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510Filter  ³ Autor ³ Vendas CRM         ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ 	Função que realiza o filtro Default e retorno os		  ³±±
³±±				dados da MBrowse					                         	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1:aFWFilter(Array com os Filtros da MBrowse)            ³±±
±±³          ³ Exp2:cAlias(Alias da MBrowse)                              ³±±
±±³          ³ Exp3:oCalend(Objeto do FWCalendar)                         ³±±
±±³          ³ Exp4:nPos(Posição da Combo-Box)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AT510Filter(aFwFilter,cAlias,oCalend, nPos)

Local cFilter			:= ""         
Local aBrowse			:= {}
Local cAtend			:= ""
Local cCli				:= ""
Local cContM			:= ""
Local cContS			:= ""
Local cNumOs			:= ""
Local cVistT			:= "" 
Local cCodTec			:= ""
Local nX				:= 0

Default nPos := 1        
Default cAlias := "ABB"
                                           
If !Empty(cCodContr) .AND. Empty(cCodAtend)
		cFilter += "(Empty(ABB_NUMOS) .OR. ABB_NUMOS $ '" + At510POS(cCodContr) + "') .AND. "
Else  
    If Len(aFiltro) > 0
    	If aFiltro[1][nPosTipo] == 1
			If !(FindFunction("TecBisTir") .AND. TecBisTir()) 
				If Len(aPerm) > 0
					cFilter += "ABB_NUMOS $ '"+At510PCtr()+"' .AND. "		    
				EndIf 		  
			EndIf
		    cFilter += "ABB_NUMOS >= '" + aFiltro[1][nPosNOsDe] + "' .AND. "
		    cFilter += "ABB_NUMOS <= '" + aFiltro[1][nPosNOsAte] + "' .AND. "		     
       ElseIf aFiltro[1][nPosTipo] == 2
		    cFilter += "Empty(ABB_NUMOS) .AND. "
		    cFilter += "ABB_CHAVE >= '" + aFiltro[1][nPosVisDe] + "' .AND. "
		    cFilter += "ABB_CHAVE <= '" + aFiltro[1][nPosVisAte] + "' .AND. "		    
       Else
	   		If FindFunction("TecBisTir") .AND. TecBisTir()
				cFilter += "(Empty(ABB_NUMOS) "
				cFilter += ".OR. ABB_NUMOS $ '"+aFiltro[1][nPosNOsDe]+"'
				cFilter += ") .AND. "  
			Else
				If Len(aPerm) > 0
					cFilter += "(Empty(ABB_NUMOS) "
					cFilter += ".OR. ABB_NUMOS $ '"+At510PCtr()+"'
					cFilter += ") .AND. "  
				EndIf
			EndIf
       EndIf
    EndIf	
EndIf                                                                                  

If Empty(cCodAtend)
	cCodTec := At510PTec()
	If !Empty(cCodTec)
		cFilter += " ABB_CODTEC $ '"+cCodTec+"' .AND. "
	EndIf 
	If Len(aFiltro) > 0		
    	cFilter += "ABB_CODTEC >= '"+aFiltro[1][nPosAteDe]+"' .AND. "
    	cFilter += "ABB_CODTEC <= '"+aFiltro[1][nPosAteAte]+"' .AND. "    	
	EndIf
EndIf


If Len(aFiltro) > 0 .And. ABB->(FieldPos("ABB_LOCAL")) > 0
	cFilter += "ABB_LOCAL >= '" + aFiltro[1][nPosLocDe] + "' .AND. "
	cFilter += "ABB_LOCAL <= '" + aFiltro[1][nPosLocAte] + "' .AND. "		
EndIf
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica qual a posição da ComboBox para realizar a chamado de filtro especifico	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case nPos == 1
		cFilter +=	"((dTos(ABB_DTINI) >= '" + DToS(oCalend:DINIMES) + "' .AND. dTos(ABB_DTINI) <= '" + DToS(oCalend:DFIMMES) + "')" 
		cFilter +=	" .OR. ( dTos(ABB_DTFIM)>='" + DToS(oCalend:DINIMES) + "' .AND. dTos(ABB_DTFIM)<='" + DToS(oCalend:DFIMMES) + "')" 
		cFilter +=	" .OR. ( dTos(ABB_DTINI)<'" + DToS(oCalend:DINIMES) + "' .AND. dTos(ABB_DTFIM)>'" + DToS(oCalend:DFIMMES) + "'))" 
		If !Empty(cCodAtend)
			cFilter += " .AND. ABB_CODTEC == '" + cCodAtend + "' "
		EndIf
		   
		oMBrwWA:SetFilterDefault(cFilter)
		AT510FTABB(aFwFilter,"ABB",oCalend, nPos)
		
	Case nPos == 2 
		cFilter +=	"((dTos(ABB_DTINI) >= '" + DToS(oCalend:DINIMES) + "' .AND. dTos(ABB_DTINI) <= '" + DToS(oCalend:DFIMMES) + "')" 
		cFilter +=	" .OR. ( dTos(ABB_DTFIM)>='" + DToS(oCalend:DINIMES) + "' .AND. dTos(ABB_DTFIM)<='" + DToS(oCalend:DFIMMES) + "')" 
		cFilter +=	" .OR. ( dTos(ABB_DTINI)<'" + DToS(oCalend:DINIMES) + "' .AND. dTos(ABB_DTFIM)>'" + DToS(oCalend:DFIMMES) + "'))"
		If !Empty(cCodAtend)
			cFilter += " .AND. ABB_CODTEC == '" + cCodAtend + "' "
		EndIf
		     		
		oMBrwWA:SetFilterDefault(cFilter)
		AT510FTAB6(aFwFilter,"ABB",oCalend, nPos)
	Case nPos == 3
		cFilter +=	"((dTos(ABB_DTINI) >= '" + DToS(oCalend:DINIMES) + "' .AND. dTos(ABB_DTINI) <= '" + DToS(oCalend:DFIMMES) + "')" 
		cFilter +=	" .OR. ( dTos(ABB_DTFIM)>='" + DToS(oCalend:DINIMES) + "' .AND. dTos(ABB_DTFIM)<='" + DToS(oCalend:DFIMMES) + "')" 
		cFilter +=	" .OR. ( dTos(ABB_DTINI)<'" + DToS(oCalend:DINIMES) + "' .AND. dTos(ABB_DTFIM)>'" + DToS(oCalend:DFIMMES) + "'))"
		If !Empty(cCodAtend)
			cFilter += " .AND. ABB_CODTEC == '" + cCodAtend + "' "
		EndIf
		      	
		oMBrwWA:SetFilterDefault(cFilter)
		AT510FTSA1(aFwFilter,"ABB",oCalend, nPos)
	Case nPos == 4	
		cFilter +=	"((dTos(ABB_DTINI) >= '" + DToS(oCalend:DINIMES) + "' .AND. dTos(ABB_DTINI) <= '" + DToS(oCalend:DFIMMES) + "')" 
		cFilter +=	" .OR. ( dTos(ABB_DTFIM)>='" + DToS(oCalend:DINIMES) + "' .AND. dTos(ABB_DTFIM)<='" + DToS(oCalend:DFIMMES) + "')" 
		cFilter +=	" .OR. ( dTos(ABB_DTINI)<'" + DToS(oCalend:DINIMES) + "' .AND. dTos(ABB_DTFIM)>'" + DToS(oCalend:DFIMMES) + "'))"
		If !Empty(cCodAtend)
			cFilter += " .AND. ABB_CODTEC == '" + cCodAtend + "' "
		EndIf
		   
		oMBrwWA:SetFilterDefault(cFilter)                                               
		AT510FTAB6(aFwFilter,"ABB",oCalend, nPos)	
	Case nPos == 5
		cFilter +=	"((dTos(ABB_DTINI) >= '" + DToS(oCalend:DINIMES) + "' .AND. dTos(ABB_DTINI) <= '" + DToS(oCalend:DFIMMES) + "')" 
		cFilter +=	" .OR. ( dTos(ABB_DTFIM)>='" + DToS(oCalend:DINIMES) + "' .AND. dTos(ABB_DTFIM)<='" + DToS(oCalend:DFIMMES) + "')" 
		cFilter +=	" .OR. ( dTos(ABB_DTINI)<'" + DToS(oCalend:DINIMES) + "' .AND. dTos(ABB_DTFIM)>'" + DToS(oCalend:DFIMMES) + "'))"
		If !Empty(cCodAtend)
			cFilter += " .AND. ABB_CODTEC == '" + cCodAtend + "' "
		EndIf
		      		
		oMBrwWA:SetFilterDefault(cFilter)                                               
		AT510FTABB(aFwFilter,"ABB",oCalend, nPos)	
	Case nPos == 6		
		cFilter +=	"((dTos(ABB_DTINI) >= '" + DToS(oCalend:DINIMES) + "' .AND. dTos(ABB_DTINI) <= '" + DToS(oCalend:DFIMMES) + "')" 
		cFilter +=	" .OR. ( dTos(ABB_DTFIM)>='" + DToS(oCalend:DINIMES) + "' .AND. dTos(ABB_DTFIM)<='" + DToS(oCalend:DFIMMES) + "')"
		cFilter +=	" .OR. ( dTos(ABB_DTINI)<'" + DToS(oCalend:DINIMES) + "' .AND. dTos(ABB_DTFIM)>'" + DToS(oCalend:DFIMMES) + "'))"
		If !Empty(cCodAtend)
			cFilter += " .AND. ABB_CODTEC == '" + cCodAtend + "' ""
		EndIf
		   
		cFilter += " .AND. !Empty(ABB_LOCAL) "		 
		oMBrwWA:SetFilterDefault(cFilter)
		AT510FTABB(aFwFilter,"ABB",oCalend, nPos)	
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	Popula a TWBrowse conforme a nPos  	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ               
aBrowse := AT510aBrowse(nPos,cAtend,cContM)                    
If Empty(aBrowse)
	AAdd(aBrowse, { , })
EndIf

oTWBrowse:SetArray(aBrowse)
oTWBrowse:bLine := {||{aBrowse[oTWBrowse:nAt,01],;
                      aBrowse[oTWBrowse:nAt,02] } }	
                      
oTWBrowse:Refresh()                      
                      
                      
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510TXTCalen ³ Autor ³ Vendas CRM        ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ 	Coloca as Informações nas celulas do calendario		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1:oCalend(Objeto do FwCalendar)                         ³±±
±±³          ³ Exp2:aItems(Array com as Informações que serão Jogadas)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AT510TXTCalen(oCalend, aItems)

Local nI						//Auxiliar do For
Local nY						//Auxiliar do For
Local nX						//Auxiliar do For
Local nZ						//Auxiliar do For
Local cTpCont		:= " "		//Variavel com o tipo de contrato
Local aList 		:= {}		//Array Auxiliar
Local cComp			:= ""		//Variavel com os complementos(( I ) e ( F ))
Local aCargo		:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preencha as celulas do calendario, conforme o Array	  	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !EMPTY(aItems)
	
	For nI := 1 To Len( aItems )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica em qual posição está no calendario o inicio e o fim da alocação    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nX := aScanX(oCalend:aCell,{|x,y| x[3] == aItems[nI][1][3]}) //Inicio do Periodo
		
		nY := aScanX(oCalend:aCell,{|x,y| x[3] == aItems[nI][1][5]}) //Fim do Periodo
		
		If nX == 0
			nX := aScanX(oCalend:aCell,{|x,y| x[3] == oCalend:DINIMES}) //Inicio do Periodo
		EndIf
		
		If nY == 0
			nY := aScanX(oCalend:aCell,{|x,y| x[3] == oCalend:DFIMMES}) //Fim do Periodo
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se a visualização é por contrato e qual o tipo 1= Manutenção, 2=Serviços  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If oCombo1:Nat == 2 .AND. (Len(aItems[nI][1]) > 6 .AND. aItems[nI][1][7] == "1")
			cTpCont := " (M) " 
		ElseIf oCombo1:Nat == 2 .AND. (Len(aItems[nI][1]) > 6 .AND. aItems[nI][1][7] == "2")
			cTpCont := " (S) "
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o atendimento iniciou e terminou no mesmo dia                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nX == nY
  
				aList := AClone(oCalend:aCell[nX][OBJETO]:oListBoxContent:aItems)
				If oCombo1:nAt == 2 .AND. !Empty(aItems[nI][2][3]) .OR. oCombo1:nAt == 4 //Contrato
					Aadd( aList, aItems[nI][2][1] + " " + aItems[nI][2][2] + " - "+ AllTrim(Posicione("AA1",1,XFILIAL("AA1") + aItems[nI][1][1],"AA1_NOMTEC" ))  + cTpCont ) //Horario Inicial,Horario Final,Nome do técnico e tipo do contrato
				ElseIf oCombo1:nAt == 3 .AND. Len(aItems[nI][1]) > 6 //Cliente
					Aadd( aList, aItems[nI][2][1] + " " + aItems[nI][2][2] + " - "+ Posicione("AA1",1,XFILIAL("AA1") + aItems[nI][1][1],"AA1_NOMTEC" )) //Horario Inicial,Horario Final,Nome do técnico
				ElseIf oCombo1:nAt == 1 .OR. oCombo1:nAt == 5 .OR. oCombo1:nAt == 6
					Aadd( aList, aItems[nI][2][1] + " " + aItems[nI][2][2] + " - " + (AllTrim(aItems[nI][2][3]))) //Horario Inicial,Horario Final,Nome do técnico
				EndIf
				oCalend:SetInfo( oCalend:aCell[nX][ID],aList)
				If TxRelease()
					If ValType(oCalend:aCell[nX][OBJETO]:oListBoxContent:Cargo) != "A"
						oCalend:aCell[nX][OBJETO]:oListBoxContent:Cargo := {}
					EndIf									
					AAdd(oCalend:aCell[nX][OBJETO]:oListBoxContent:Cargo,aItems[nI][3]) // Recno da ABB
				EndIf 		
				aList := {}
		
		ElseIf nY > nX
			
			For nZ := nX To nY

				If aItems[nI][1][3] == oCalend:aCell[nZ][DATADIA]		
					cComp := " (I) "
				ElseIf aItems[nI][1][5] == oCalend:aCell[nZ][DATADIA]
					cComp := " (F) "
				Else
					cComp := ""
				EndIf
											
				If nX == nZ .AND. cComp <> ""
						aList := AClone(oCalend:aCell[nZ][OBJETO]:oListBoxContent:aItems) 
						If oCombo1:nAt == 2 .AND. !Empty(aItems[nI][2][3]) .OR. oCombo1:nAt == 4 //Contrato
							Aadd( aList, cComp  + aItems[nI][2][1]  + " - "+ Alltrim(Posicione("AA1",1,XFILIAL("AA1") + aItems[nI][1][1],"AA1_NOMTEC" )) + cTpCont )//Horario Inicial,Numero do técnico e tipo do contrato
						ElseIf oCombo1:nAt == 3 .AND. Len(aItems[nI][1]) > 6 //Cliente
							Aadd( aList, cComp  + aItems[nI][2][1]  + " - "+ Posicione("AA1",1,XFILIAL("AA1") + aItems[nI][1][1],"AA1_NOMTEC" ) ) //Horario Inicial,Nome do técnico
						ElseIf oCombo1:nAt == 1 .OR. oCombo1:nAt == 5
							Aadd( aList, cComp  + aItems[nI][2][1] + " - " + (AllTrim(aItems[nI][2][3]))) //Horario Inicial e nome do técnico
						EndIf
						oCalend:SetInfo( oCalend:aCell[nZ][ID],aList)
						If TxRelease()
							If ValType(oCalend:aCell[nZ][OBJETO]:oListBoxContent:Cargo) != "A"
								oCalend:aCell[nZ][OBJETO]:oListBoxContent:Cargo := {}
							EndIf				
							AAdd(oCalend:aCell[nZ][OBJETO]:oListBoxContent:Cargo,aItems[nI][3]) // Recno da ABB
						EndIf 
						aList := {}
				ElseIf nZ == nY .AND. cComp <> ""
						aList := AClone(oCalend:aCell[nZ][OBJETO]:oListBoxContent:aItems) 
						If oCombo1:nAt == 2 .AND. !Empty(aItems[nI][2][3]) .OR. oCombo1:nAt == 4 //Contrato
							Aadd( aList, cComp + aItems[nI][2][2]  + " - "+ Alltrim(Posicione("AA1",1,XFILIAL("AA1") + aItems[nI][1][1],"AA1_NOMTEC" )) + cTpCont ) //Horario Inicial,Numero do técnico e tipo do contrato
						ElseIf oCombo1:nAt == 3 .AND. Len(aItems[nI][1]) > 6 //Cliente
							Aadd( aList, cComp + aItems[nI][2][2]  + " - "+ Posicione("AA1",1,XFILIAL("AA1") + aItems[nI][1][1],"AA1_NOMTEC" )) //Horario Final,Nome do técnico
						ElseIf oCombo1:nAt == 1 .OR. oCombo1:nAt == 5
							Aadd( aList, cComp + aItems[nI][2][2] + " - " + (AllTrim(aItems[nI][2][3])))
						EndIf
						oCalend:SetInfo( oCalend:aCell[nZ][ID],aList)
						If TxRelease()
							If ValType(oCalend:aCell[nZ][OBJETO]:oListBoxContent:Cargo) != "A"
								oCalend:aCell[nZ][OBJETO]:oListBoxContent:Cargo := {}
							EndIf				
							AAdd(oCalend:aCell[nZ][OBJETO]:oListBoxContent:Cargo,aItems[nI][3]) // Recno da ABB
						EndIf						
						aList := {}
				Else
						aList := AClone(oCalend:aCell[nZ][OBJETO]:oListBoxContent:aItems) 
						If oCombo1:nAt == 2 .AND. !Empty(aItems[nI][2][3]) .OR. oCombo1:nAt == 4 //Contrato
							Aadd( aList, "( " + AllTrim(aItems[nI][2][4]) + " ) " + " - " + Alltrim(Posicione("AA1",1,XFILIAL("AA1") + aItems[nI][1][1],"AA1_NOMTEC" )) + cTpCont ) //Horario Inicial,Numero do técnico e tipo do contrato
						ElseIf oCombo1:nAt == 3 .AND. Len(aItems[nI][1]) > 6 //Cliente
							Aadd( aList,  "( " + AllTrim(aItems[nI][1][2]) + " ) " + " - " + Posicione("AA1",1,XFILIAL("AA1") + aItems[nI][1][1],"AA1_NOMTEC" ) ) //Nome do técnico
						ElseIf oCombo1:nAt == 1.OR. oCombo1:nAt == 5
							Aadd( aList, "( " + AllTrim(aItems[nI][1][2]) + " ) " + (AllTrim(aItems[nI][2][3])))
						EndIf
						oCalend:SetInfo(oCalend:aCell[nZ][ID],aList)
						If TxRelease()						
							If ValType(oCalend:aCell[nZ][OBJETO]:oListBoxContent:Cargo) != "A"
								oCalend:aCell[nZ][OBJETO]:oListBoxContent:Cargo := {}
							EndIf				
							AAdd(oCalend:aCell[nZ][OBJETO]:oListBoxContent:Cargo,aItems[nI][3]) // Recno da ABB
						EndIf						
						aList := {}
					EndIf	
						
			Next nZ
			
		EndIf					
		
	Next nI
				
EndIf

If Valtype(oListBox) == "O" .AND. oListBox:ClassName() == "TLISTBOX"
	aList := {}
	aList := AClone(oCalend:aCell[aScanX(oCalend:aCell,{|x,y| x[3] == oCalend:Acell[oCalend:nAt][3]})][OBJETO]:oListBoxContent:aItems)
	oListBox:SetArray(aList)
	oListBox:Refresh()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Zera o Array aList    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aList:={}

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510Clear   ³ Autor ³ Vendas CRM         ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ 	Limpa as celulas do calendario		                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1:oCalend(Objeto do FWCALENDAR)                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AT510Clear(oCalend)

Local nI				//Auxiliar do For
Local aAux := {}		//Array Auxiliar

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa as celulas do calendario.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len( oCalend:aCell )
	If oCalend:aCell[nI][ATIVO]
		oCalend:SetInfo( oCalend:aCell[nI][ID], aAux )
		oCalend:aCell[nI][OBJETO]:oListBoxContent:Cargo := {}
	EndIf
Next

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510FTABB   ³ Autor ³ Vendas CRM         ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a recuperação dos dados quando é utilizado  		  ³±±
±±³        ³ a visão de técnico                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1:aFWFilter(Array com os Filtros da MBrowse)            ³±±
±±³          ³ Exp2:cAlias(Alias da MBrowse)                              ³±±
±±³          ³ Exp3:oCalend(Objeto do FWCalendar)                         ³±±
±±³          ³ Exp4:nPos(Posição da Combo-Box)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AT510FTABB(aFWFilter,cAlias,oCalend,nPos)

Local aItems 			:= {}											//Array com os items que serão mostrados no calendario
Local aAreaFil  		:= (cAlias)->(GetArea())						//Area de trabalho do Alias	
Local cAliasFilter		:= cAlias										//Alias da MBrowse

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Recupera os dados da MBrowse    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("ABB")
(cAliasFilter)->(DbGoTop())


While !( cAliasFilter )->( Eof() )
	aAdd( aItems , {{ ( cAliasFilter )->ABB_CODTEC, ( cAliasFilter )->ABB_NUMOS, ( cAliasFilter )->ABB_DTINI,;
		 ( cAliasFilter )->ABB_HRINI, ( cAliasFilter )->ABB_DTFIM, ( cAliasFilter )->ABB_HRFIM },;
		 {( cAliasFilter )->ABB_HRINI, ( cAliasFilter )->ABB_HRFIM, Posicione("AA1",1,XFILIAL("AA1") + ( cAliasFilter )->ABB_CODTEC,"AA1_NOMTEC" )},;
		 (cAliasFilter)->(Recno()) } ) 	

	( cAliasFilter )->( dbSkip() ) 
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa e Envia dados filtrados para o calendario   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AT510Clear(oCalend)
AT510TXTCalen(oCalend, aItems)

RestArea(aAreaFil)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510FTAB6   ³ Autor ³ Vendas CRM         ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a recuperação dos dados quando é utilizado  		  ³±±
±±³        ³ a visão de Contrato                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1:aFWFilter(Array com os Filtros da MBrowse)            ³±±
±±³          ³ Exp2:cAlias(Alias da MBrowse)                              ³±±
±±³          ³ Exp3:oCalend(Objeto do FWCalendar)                         ³±±
±±³          ³ Exp4:nPos(Posição da Combo-Box)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AT510FTAB6(aFwFilter,cAlias,oCalend, nPos)

Local nI																//Auxiliar do For	
Local aItems 			:= {}											//Array com os items que serão mostrados no calendario
Local aAreaABB  		:= (cAlias)->(GetArea())						//Area de trabalho do Alias	
Local cAliasFilter		:= cAlias										//Alias do Filtro
Local aAreaAB6			:= AB6->(GetArea())								//Alias AB6
Local aAreaSA1			:= SA1->(GetArea())								//Alias SA1
Local cAliasAB6			:= GetNextAlias()								//Alias Temporario 	
Local cArqTmp 			:= ""											//Arquivo temporario
Local cQuery			:= ""											//Variavel para realizar a Query
Local cNumOSStr			:= ""

If Select("cAliasAB6") > 0 
	(cAliasAB6)->(DbCloseArea()) 
Endif

DbSelectArea("SA1")
DbSetOrder(1)
SA1->(DBClearFilter())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Recupera os dados da MBrowse    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("ABB")
(cAliasFilter)->(DbGoTop())

While (cAliasFilter)->(! Eof())
	//Remove O que nao é referente a O.S. (Ex. Vistoria Tecnica)
	If ! Empty((cAliasFilter)->ABB_NUMOS)
		aAdd(aItems, {{(cAliasFilter)->ABB_CODTEC,;
		               (cAliasFilter)->ABB_NUMOS,;
		               (cAliasFilter)->ABB_DTINI,;
		               (cAliasFilter)->ABB_HRINI,;
		               (cAliasFilter)->ABB_DTFIM,;
		               (cAliasFilter)->ABB_HRFIM,;
		               " "},;
		              {(cAliasFilter)->ABB_HRINI,;
		               (cAliasFilter)->ABB_HRFIM,;
		               "",;
		               ""},;
		              (cAliasFilter)->(Recno())})
	EndIf
	(cAliasFilter)->(DbSkip())
EndDo

For nI := 1 to Len(aItems)
	If	! ( ( "'" + aItems[nI][1][2] + "'" ) $ cNumOSStr )
		cNumOSStr	+= If(! Empty(cNumOSStr), ",", "")
		cNumOSStr	+= "'" + aItems[nI][1][2] + "'"
	EndIf
Next nI
If	Empty(cNumOSStr)
	cNumOSStr	:= "% %"
Else
	cNumOSStr	:= "% AND AB6.AB6_NUMOS IN (" + cNumOSStr + ") %"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a Query e cria a area de trabalho da AB6   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BeginSql alias cAliasAB6
	SELECT AB6.AB6_FILIAL, AB6.AB6_NUMOS, AB6.AB6_TPCONT, AB6.AB6_CONTRT, AB6.AB6_CODCLI, AB6.AB6_LOJA
	  FROM %table:AB6% AB6
	 WHERE AB6.AB6_FILIAL = %xfilial:AB6%
	   AND AB6.%NotDel%
	   %Exp:cNumOSStr%
	 ORDER BY AB6.AB6_FILIAL,AB6.AB6_NUMOS
EndSql

If (cAliasAB6)->(! Eof()) .AND. Len(aItems) > 0
	While (cAliasAB6)->(! Eof())
		For nI := 1 to Len(aItems)
			If	aItems[nI][01][02] == (cAliasAB6)->AB6_NUMOS
				aItems[nI][1][7] 	:= (cAliasAB6)->AB6_TPCONT
				aItems[nI][2][3]	:= (cAliasAB6)->AB6_CONTRT
				aItems[nI][2][4]	:= (cAliasAB6)->AB6_NUMOS
			EndIf
		Next nI
		(cAliasAB6)->(DbSkip())
	EndDo
Else
	aItems := {}
EndIf
(cAliasAB6)->(DbCloseArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa e Envia dados filtrados para o calendario   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AT510Clear(oCalend)
AT510TXTCalen(oCalend, aItems)

RestArea(aAreaABB)
RestArea(aAreaAB6)                    
RestArea(aAreaSA1)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510FTSA1   ³ Autor ³ Vendas CRM         ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a recuperação dos dados quando é utilizado  		  ³±±
±±³        ³ a visão de Cliente                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1:aFWFilter(Array com os Filtros da MBrowse)            ³±±
±±³          ³ Exp2:cAlias(Alias da MBrowse)                              ³±±
±±³          ³ Exp3:oCalend(Objeto do FWCalendar)                         ³±±
±±³          ³ Exp4:nPos(Posição da Combo-Box)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AT510FTSA1(aFwFilter,cAlias,oCalend, nPos)

Local nI																//Auxiliar do For	
Local aItems 			:= {}											//Array com os items que serão mostrados no calendario
Local aAreaABB  		:= (cAlias)->(GetArea())						//Area de trabalho do Alias	
Local aAreaAB6			:= AB6->(GetArea())								//Alias AB6
Local aAreaSA1			:= SA1->(GetArea())								//Alias SA1
Local cAliasFilter		:= cAlias										//Alias do Filtro
Local cAliasAB6			:= GetNextAlias()								//Alias Temporario
Local cFilterAB6		:= AB6->(DbFilter())

If Select("cAliasAB6") > 0 
	(cAliasAB6)->(DbCloseArea()) 
Endif

DbSelectArea("SA1")
DbSetOrder(1)
SA1->(DBClearFilter())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Recupera os dados da MBrowse    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("ABB")
(cAliasFilter)->(DbGoTop())

While !( cAliasFilter )->( Eof() )
	aAdd( aItems , {{ ( cAliasFilter )->ABB_CODTEC, ( cAliasFilter )->ABB_NUMOS, ( cAliasFilter )->ABB_DTINI,;
		 ( cAliasFilter )->ABB_HRINI, ( cAliasFilter )->ABB_DTFIM, ( cAliasFilter )->ABB_HRFIM, " " },;
		 {( cAliasFilter )->ABB_HRINI, ( cAliasFilter )->ABB_HRFIM," "},;
		 (cAliasFilter)->(Recno()) } ) 

		( cAliasFilter )->( dbSkip() ) 
End

AB6->(DbSelectArea("AB6"))
AB6->(DbClearFilter())
AB6->(DbSetOrder(1))
	
For nI := 1 to Len(aItems)
	(cAliasFilter)->(DbGoTo(aItems[nI][3]))
	If (cAliasFilter)->ABB_ENTIDA=="AAT"
		AAT->(DbSetOrder(1))
		If AAT->(DbSeek(XFilial("AAT")+(cAliasFilter)->ABB_CHAVE))
			aItems[nI][1][7] 	:= AAT->AAT_CODENT
			aItems[nI][2][3]	:= Posicione("AA1",1,XFILIAL("AA1") + aItems[nI][1][1],"AA1_NOMTEC" )
			If AAT->AAT_ENTIDA == "1"
				aItems[nI][2][3]	:= Posicione("SA1",1,XFILIAL("SA1") + AAT->AAT_CODENT+AAT->AAT_LOJENT ,"A1_NOME" )
			Else
				aItems[nI][2][3]	:= Posicione("SUS",1,XFILIAL("SUS") + AAT->AAT_CODENT+AAT->AAT_LOJENT ,"US_NOME" )
			EndIf
		EndIf
	ElseIf (cAliasFilter)->ABB_ENTIDA=="AB7"
		AB7->(DbSetOrder(1))
		If AB7->(DbSeek(XFilial("AB7")+(cAliasFilter)->ABB_CHAVE))
			aItems[nI][1][7] 	:= AB6->AB6_LOJA
			aItems[nI][2][3]	:= Posicione("SA1",1,XFILIAL("SA1") + AB6->AB6_CODCLI + AB6->AB6_LOJA ,"A1_NOME" )
		EndIf
	Else
		If 	AB6->(DbSeek(AB6->AB6_FILIAL + aItems[nI][1][2]))
			aItems[nI][1][7] 	:= AB6->AB6_LOJA
			aItems[nI][2][3]	:= Posicione("SA1",1,XFILIAL("SA1") + AB6->AB6_CODCLI + AB6->AB6_LOJA ,"A1_NOME" )
		EndIf
	EndIf
Next nI
	
If !Empty(cFilterAB6)
	AB6->(DbSetFilter({||&cFilterAB6},cFilterAB6))
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa e Envia dados filtrados para o calendario   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AT510Clear(oCalend)
AT510TXTCalen(oCalend, aItems)

RestArea(aAreaABB)
RestArea(aAreaAB6)
RestArea(aAreaSA1)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³At510Exec    ³ Autor ³ Vendas CRM         ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ 	Rotina de Inclusão,Exclusão,Alteração e Mover Para        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1:oObj(Objeto da ListBox)                               ³±±
±±³          ³ Exp2:oCalend(Objeto do FWCalendar)                         ³±±
±±³          ³ Exp3:nOpc                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function At510Exec( oObj, oCalend, nOpc, cNumOs )

Local nOpcx
Local aAreaABB
Local dDataMov
Local nRecnoAbb		:= 0
Local aFiltros		:= {}
Local nX 			:= 1

Private dData							//Utilizado no inicializador padrao.
PRIVATE ALTERA 		:= .F.
PRIVATE INCLUI 		:= .F.
PRIVATE N		 	:= 1

If ( ValType( oObj:Cargo ) == 'A' )
	If oObj:ClassName() == "TLISTBOX"	.AND. oObj:nAt > 0 .AND. Len(oObj:Cargo) >= oObj:nAt
		nRecnoAbb := oObj:Cargo[oObj:nAt]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Recupera a Data de referencia do calendario	  	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	EndIf
EndIf

Eval(oObj:BLCLICKED)

dDataIni := oCalend:Acell[oCalend:nAt][3]
dData := dDataIni

If nRecnoABB > 0
	ABB->(DbGoTo(nRecnoAbb))
Else //Posiciona em EOF para trazer todos do dia
	ABB->(DbGoBottom())
	ABB->(DbSkip())
EndIf

//Verifica se há técnico para ser realizado manipulação
If Empty(ABB->ABB_CODTEC)
	Help("",1,"At510Exec",,STR0073,1) // "Não há dados a serem manipulado. "
	Return .F.	
EndIf

AA1->(DbSetOrder(1))
AA1->(DbSeek(xFilial("AA1") + ABB->ABB_CODTEC))


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica, baseado no tipo de tecnico e disponibilidade, se permite     ³ 
//³ a alteracao                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOpcx := If( AA1->AA1_TIPO $ "13" .And. AA1->AA1_ALOCA == "1", 3, 2 ) 

If nOpcx == 2 
	Help( " ", 1, "AT500VISU" ) // 	Nao e permitida a alteracao deste tecnico
	Return .F.
EndIf 

aAreaABB := ABB->(GetArea())

TA521Dt(dData)

If nOpc == 5
	ALTERA := .T.
	INCLUI := .F.
	FWExecView(,'TECA521', MODEL_OPERATION_DELETE,, { || .T. },,25 )
ElseIf nOpc == 7
	ALTERA := .T.
	INCLUI := .F.
	If !ABB->(EOF())
		If Empty(ABB->ABB_NUMOS)
			DbSelectArea("AAT")
			DbSetOrder(1)
			If DbSeek(XFilial("AAT")+ABB->ABB_CHAVE)
				FWExecView(,'TECA270', MODEL_OPERATION_VIEW,, { || .T. })
			EndIf
		Else
			AT510VisOS(ABB->ABB_NUMOS)
		EndIf		
	EndIf
ElseIf nOpc == 6
	Ta521Mover()	

//-----------------------------------------------------------
// Manutenção da Agenda
//-----------------------------------------------------------
ElseIf ( nOpc == 8 )
		
	//  captura os filtros ativos no browse antes e remove para não ter problemas com seek no processo
	aFiltros := oMBrwWA:oFwFilter:GetFilter()
	oMBrwWA:oFwFilter:CleanFilter()
	oMBrwWA:oFwFilter:ExecuteFilter()
	
	ABB->(DbGoTo(nRecnoAbb))
	
	TECA540( dData, dData )
	
	// restaura os filtros que estavam ativos no browse de atendentes	
	If( Len(aFiltros) > 0 )
		For nX := 1 To Len(aFiltros)
			oMBrwWA:AddFilter(aFiltros[nX,1],aFiltros[nX,2],,.T.)
		Next nX
		oMBrwWA:oFwFilter:ExecuteFilter()
	EndIf
	 	
Else
	ALTERA := .T.
	INCLUI := .F.
	FWExecView(,'TECA521', MODEL_OPERATION_UPDATE,, { || .T. },,25 )
EndIf			

RestArea(aAreaABB)

AT510TEXTO(oCalend,oCombo1:nAt)
	
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510GDInc   ³ Autor ³ Vendas CRM         ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ 	Rotina de Inclusão,Exclusão,Alteração e Mover Para        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1:oObj(Objeto da ListBox)                               ³±±
±±³          ³ Exp2:oCalend(Objeto do FWCalendar)                         ³±±
±±³          ³ Exp3:nOpc                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AT510GDInc( oObj, oCalend, nOpc, cNumOs )

Local lGravou				:= .F.											// Se houve ou não a gravação do agendamento do técnico
Local nOpcA					:= 0											// Opção selecionada no diálogo
Local oDlgCallInclui 		:= Nil											// Objeto do diálogo principal
Local oGetD					:= Nil											// Getdados utilizada com os agendamentos
Local nOpcx					:= 2 											// Variável de verificação de disponibilidade de alocação
Local aNoFields				:= ""											// Campos que não serão adicionados ao aHeader
Local dDataIni        														// Data Referente ao dia selecionado no calendario
Local oPanGD																// Objeto para o Layer da GetDados
Local oTButton1																// Objeto para o Button
Local oTButton2																// Objeto para o Button
Local aTravas				:= {}											// Array com os dados travados
Local lTravas				:= .T.											// indica se foi travado com sucesso
Local lExclui				:= .F.											// Indica se irá excluir o registro da GetDados
Local lCopia				:= .F.											// Indica se o registro será Duplicado
Local lMove					:= .F.											// Indica se o registro será movido	
Local nOperation			:= 0
Local cVldDel				:= ""
Local cVldField				:= ""

Private aCols				:= {}
Private aHeader				:= {}
Private aRegistros			:= {}
Private dData																//Utilizado no inicializador padrao.

If oObj:ClassName() <> "TLISTBOX"
	Return Nil
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Recupera a Data de referencia do calendario	  	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Eval(oObj:BLCLICKED)

dDataIni := oCalend:Acell[oCalend:nAt][3]
dData := dDataIni

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica, baseado no tipo de tecnico e disponibilidade, se permite     ³ 
//³ a alteracao                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOpcx := If( AA1->AA1_TIPO $ "13" .And. AA1->AA1_ALOCA == "1", 3, 2 ) 

If nOpcx == 2 
	Help( " ", 1, "AT500VISU" ) // 	Nao e permitida a alteracao deste tecnico
	Return .F.
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem aHeader, aCols³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aNoFields := {	"ABB_NOMTEC"}

If Len(aHeader) == 0 .AND. Len(aCols) == 0
	FillGetDados(	nOpc				,"ABB"			,1													,/*cSeek*/			,;
		  				/*{|| &cWhile }*/	,{|| .T. }		,aNoFields											,/*aYesFields*/		,; 
						/*lOnlyYes*/		,/*cQuery*/		,{ || AT510MontCols(dDataIni, nOpc , oObj, oCalend, aTravas, @lTravas, cNumOs) }	,/*lEmpty*/			,;
						/*aHeaderAux*/		,/*aColsAux*/	,/*bAfterCols*/										,/*bBeforeCols*/	)
	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for Mover Para, faz Backup do nOpc e utiliza o ALTERA	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If 	nOpc == 6
	nOperation := nOpc
	nOpc := 4
	ALTERA := .T.
	lCopia := .F.
EndIf

If (lTravas) .AND. nOperation == 6
	Begin Transaction
		lGravou := AT510Grava(lExclui,lCopia)
		If ( lGravou )
			EvalTrigger()
			While ( __lSx8 )
				ConfirmSx8()
			EndDo
		EndIf
	End Transaction

ElseIf ( lTravas ) .AND. nOperation <> 6

	If !Empty(cNumOs) //Se validar por O.S.
		cVldField	:= "At510VldOs('"+cNumOs+"')"
		cVldDel	:= "At510VldOs('"+cNumOs+"')"
	EndIf 
	
	DEFINE MSDIALOG oDlgCallInclui TITLE STR0004 FROM 270,270 TO 550,900 PIXEL //Alocação de Técnico
	
	oFwLayer := FwLayer():New()
	oFwLayer:init(oDlgCallInclui,.F.)
		
	oFWLayer:addLine("GETDADOS", 90, .F.)
	oFWLayer:addLine("ENCHOICE", 10, .F.)
	
	oPanGD :=oFWLayer:GetLinePanel("GETDADOS")
	oPanEn :=oFWLayer:GetLinePanel("ENCHOICE")		
	
	oGetd := MsGetDados():New(015,005,138,314,nOpc,"AT510LINOK","AT510TUDOOK","",.T.,,,,,cVldField,,,cVldDel,oPanGD)	
	oGetD:oBrowse:ALIGN:= CONTROL_ALIGN_ALLCLIENT
	
	oTButton1 := TButton():New( 002, 220, STR0014 ,oPanEn,{||nOpcA:=1,If(oGetd:TudoOk(),oDlgCallInclui:End(),nOpcA:=0)},; //Confirmar
                  					40,10,,,.F.,.T.,.F.,,.F.,,,.F. )																			
	
	oTButton2 := TButton():New( 002, 270, STR0026 ,oPanEn,{||oDlgCallInclui:End()},;//Fechar
                  					40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	ACTIVATE MSDIALOG oDlgCallInclui 
		
	If ( nOpcA == 1 )	
		If nOpc == 5
			lExclui := MsgYesNo(STR0027) //"Deseja Realmente excluir esse registro"
		EndIf	
		Begin Transaction
			lGravou := AT510Grava(lExclui,lCopia)
			If ( lGravou )
				EvalTrigger()
				While ( __lSx8 )
					ConfirmSx8()
				EndDo
			EndIf
		End Transaction
	EndIf
EndIf	

While ( __lSx8 )
	RollBackSx8()
EndDo

AtDestravaReg( aTravas )

AT510TEXTO(oCalend,oCombo1:nAt)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510VldOs   ³ Autor ³ Vendas CRM         ³ Data ³ 27.08.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ 	Impede Alteração de Outra O.S. diferente da Informada     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: cNumOs (Numero da Os a Validar)                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function At510VldOs(cNumOs)
Local lRet := .T.

If Readvar() == "M->ABB_NUMOS" .AND. cNumOs != M->ABB_NUMOS
	Help("",1,"TECA510OS",,STR0056+cNumOs,1) // "Ordem de Serviço Inválida. É possível manipular apenas a O.S. "
	lRet := .F.
EndIf
	
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510MontCols³ Autor ³ Vendas CRM         ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ 	Realiza a Montagem do aCols e aHeader                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1:dDataIni(Data Inicial)                                ³±±
±±³          ³ Exp2:nOpc                                                  ³±±
±±³          ³ Exp3:oObj(Objeto da ListBox)                               ³±±
±±³          ³ Exp4:oCalend(Objeto da FWCalendar)                         ³±±
±±³          ³ Exp5:aTravas                                               ³±±
±±³          ³ Exp6:lTravas                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AT510MontCols(dDataIni, nOpc , oObj, oCalend, aTravas, lTravas, cNumOsFilt)

Local nLoop				:= 0						// Variável utilizada em loop  
Local nCntFor			:= 0						// Variável utilizada em loop
Local nUsado			:= Len(aHeader)				// Tamanho do aHeader
Local lIniFim			:= .T.						// Indica se a alocação começa e termina no mesmo dia
Local lMove				:= .T.							// Verifica se foi retornado corretamento da data no Mover Para
Local cAliasAlter		:= GetNextAlias()			// Alias
Local cInterval			:= ""							// Verifica se a alocação tem intervalos de dias
Local cHoraIni			:= ""						// Horario de inicio da alocação
Local cHoraFim			:= ""						// Horario de Fim da alocação
Local cTecnico			:= ""						// Codigo do tecnico
Local cNumOS			:= ""						// Codigo da OS
Local cContrato			:= ""							// Codigo do Contrato
Local cTpCont			:= ""						// Tipo do Contrato
Local cCliente			:= ""						// Codigo do Cliente
Local nRecnoABB  		:= 0 						// Recno da tabela ABB
Local bWhile			:= { || .T. } 				// While da query
Local nPos				:= oCombo1:nAt				// Verifica a posicão do ComboBox
Local dDataMov										// Data referente ao Mover Para
Local cDif				:= 0						// Variavel para armazenar os dias de diferença
Local aAreaABB			:= ABB->(GetArea())
Local aAreaAB6			:= AB6->(GetArea())
Local aAreaAA1			:= AA1->(GetArea())
Local aAreaAAH			:= AAH->(GetArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rotina de Mover Para  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lCopia      := (nOpc ==7)	
Local cNumCtr     := ""
Local cMay        := ""
Local nOpcOld     := nOpc

Default lTravas			:= .T.					// Se todos os campos foram travados com sucesso
Default cNumOsFilt		:= ""

If Select("cAliasAlter") > 0 
	(cAliasAlter)->(DbCloseArea())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a linha está vazia e é uma alteração ou exclusão    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc <> 3 .AND. oObj:nAt > 0

	If nOpc == 6
		dDataMov := AT510MvCalend( oDlgCall, oCalend:aCell[oCalend:nAt][3] ) 
		If dDataMov == oCalend:aCell[oCalend:nAt][3]
			lMove := .F.
		EndIf
	EndIf

	Do Case
	
	Case nPos == 1 //Técnico
		cInterval	:= SubStr(oObj:aItems[oObj:nAt], 1 , 4)
	
		If ("(I)"  $ cInterval) .OR. ("(F)" $ cInterval)
			If ("(I)"  $ cInterval)
				cHoraIni	:= SubStr(oObj:aItems[oObj:nAt], 5 , 6) 
				cTecnico	:= SubStr(oObj:aItems[oObj:nAt], 14 , Len(oObj:aItems[oObj:nAt]))
				cTecnico	:= Posicione("AA1",5,XFILIAL("AA1") + Padr(AllTrim(cTecnico),TamSX3("AA1_NOMTEC")[1]), "AA1_CODTEC")
				lIniFim 	:= .F.
			ElseIf ("(F)" $ cInterval)
				cHoraFim	:= SubStr(oObj:aItems[oObj:nAt], 5 , 6) 
				cTecnico	:= SubStr(oObj:aItems[oObj:nAt], 14 , Len(oObj:aItems[oObj:nAt]))
				cTecnico	:= Posicione("AA1",5,XFILIAL("AA1") + Padr(AllTrim(cTecnico),TamSX3("AA1_NOMTEC")[1]), "AA1_CODTEC")
				lIniFim 	:= .F.
			EndIf	
		ElseIf (":" $ cInterval)
			cHoraIni	:= SubStr(oObj:aItems[oObj:nAt], 1 , 5)	
			cHoraFim	:= SubStr(oObj:aItems[oObj:nAt], 6 , 7)
			cTecnico	:= SubStr(oObj:aItems[oObj:nAt], 14 , Len(oObj:aItems[oObj:nAt]))
			cTecnico	:= Posicione("AA1",5,XFILIAL("AA1") + Padr(AllTrim(cTecnico),TamSX3("AA1_NOMTEC")[1]), "AA1_CODTEC")
		Else
			cNumOs 		:= SubStr(oObj:aItems[oObj:nAt], 3  ,  TamSX3("ABB_NUMOS")[1])
			cTecnico	:= SubStr(oObj:aItems[oObj:nAt], (TamSX3("ABB_NUMOS")[1] * 2) , TamSX3("AA1_NOMTEC")[1])
			cTecnico	:= Posicione("AA1",5,XFILIAL("AA1") + Padr(AllTrim(cTecnico),TamSX3("AA1_NOMTEC")[1]), "AA1_CODTEC")
			lIniFim	:= .F.
		EndIf
 		
 		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta Query para posicionar na OS certa	   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		cQuery := ""
		
		cQuery += "SELECT ABB.*,R_E_C_N_O_ ABBRECNO FROM " + RetSqlName( "ABB" ) + " ABB "
		cQuery += "WHERE "
		cQuery += "ABB_FILIAL='" + xFilial( "ABB" ) + "' AND "
		cQuery += "ABB_CODTEC='" + cTecnico + "' AND "
		
		If lIniFim
			cQuery += "ABB_DTINI= '" + DToS( dDataIni ) + "' AND "
			cQuery += "ABB_HRINI='" + Alltrim(cHoraIni) + "' AND "
			cQuery += "ABB_DTFIM='" + DToS( dDataIni ) + "' AND "
			cQuery += "ABB_HRFIM='" + AllTrim(cHoraFim) + "' AND "
		ElseIf !lIniFim .AND. !Empty(cHoraIni)		
			cQuery += "ABB_DTINI= '" + DToS( dDataIni ) + "' AND "
			cQuery += "ABB_HRINI='" + Alltrim(cHoraIni) + "' AND "
			cQuery += "ABB_DTFIM>'" + DToS( dDataIni ) + "' AND "
		ElseIf !lIniFim .AND. !Empty(cHoraFim)	
			cQuery += "ABB_DTINI< '" + DToS( dDataIni ) + "' AND "
			cQuery += "ABB_HRFIM='" + Alltrim(cHoraFim) + "' AND "
			cQuery += "ABB_DTFIM='" + DToS( dDataIni ) + "' AND "
		Else
			cQuery += "ABB_NUMOS='" + cNumOs + "' AND "
			cQuery += "ABB_DTINI< '" + DToS( dDataIni ) + "' AND "
			cQuery += "ABB_DTFIM>'" + DToS( dDataIni ) + "' AND "
		EndIf	
		
		cQuery += "D_E_L_E_T_=' '"
		
		cQuery := ChangeQuery( cQuery )
		
	Case nPos == 2 //Contrato
		
		cInterval	:= SubStr(oObj:aItems[oObj:nAt], 1 , 4)
	
		If ("(I)"  $ cInterval) .OR. ("(F)" $ cInterval)
			If ("(I)"  $ cInterval)
				cHoraIni	:= SubStr(oObj:aItems[oObj:nAt], 5 , 6) 
				cContrato	:= SubStr(oObj:aItems[oObj:nAt], 12 , TamSX3("AAH_CONTRT")[1])
				cTpCont	:= SubStr(oObj:aItems[oObj:nAt], (13 + TamSX3("AAH_CONTRT")[1] + 1) , 1)
				lIniFim 	:= .F.
			ElseIf ("(F)" $ cInterval)
				cHoraFim	:= SubStr(oObj:aItems[oObj:nAt], 5 , 6) 
				cContrato	:= SubStr(oObj:aItems[oObj:nAt], 12 , TamSX3("AAH_CONTRT")[1])
				cTpCont	:= SubStr(oObj:aItems[oObj:nAt], (13 + TamSX3("AAH_CONTRT")[1] + 1) , 1)
				lIniFim 	:= .F.
			EndIf	
		ElseIf (":" $ cInterval)
			cHoraIni	:= SubStr(oObj:aItems[oObj:nAt], 1 , 5)	
			cHoraFim	:= SubStr(oObj:aItems[oObj:nAt], 6 , 7)
			cContrato	:= SubStr(oObj:aItems[oObj:nAt], 13 , TamSX3("AAH_CONTRT")[1])
			cTpCont	:= SubStr(oObj:aItems[oObj:nAt], (14 + TamSX3("AAH_CONTRT")[1] + 1) , 1)	
		Else
			cNumOs 		:= SubStr(oObj:aItems[oObj:nAt], 3  ,  TamSX3("ABB_NUMOS")[1])
			cContrato	:= SubStr(oObj:aItems[oObj:nAt], ((TamSX3("ABB_NUMOS")[1] * 2)+1) , TamSX3("AAH_CONTRT")[1])
			cTpCont	:= SubStr(oObj:aItems[oObj:nAt], (14 + TamSX3("AAH_CONTRT")[1] + 1) , 1)
			lIniFim	:= .F.
		EndIf
		
		If ("M" $ cTpCont)
			cTpCont := "1"
		ElseIf ("S" $ cTpCont)
			cTpCont := "2"
		EndIf
		
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta Query para posicionar na OS certa	   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		cQuery := ""
		
		cQuery += "SELECT DISTINCT AB6.*,ABB.*,ABB.R_E_C_N_O_ ABBRECNO FROM " + RetSqlName( "AB6" )+ " AB6 "
		cQuery += "INNER JOIN " + RetSqlName( "ABB" ) + " ABB ON ABB.ABB_FILIAL='D MG 01 ' AND ABB.ABB_NUMOS = AB6.AB6_NUMOS "
		cQuery += "WHERE "
		cQuery += "AB6_FILIAL='" + xFilial( "ABB" ) + "' AND "
		
		If lIniFim
			cQuery += "ABB_DTINI= '" + DToS( dDataIni ) + "' AND "
			cQuery += "ABB_HRINI='" + Alltrim(cHoraIni) + "' AND "
			cQuery += "ABB_DTFIM='" + DToS( dDataIni ) + "' AND "
			cQuery += "ABB_HRFIM='" + AllTrim(cHoraFim) + "' AND "
			cQuery += "AB6.AB6_CONTRT='" + cContrato + "' AND "
			cQuery += "AB6.AB6_TPCONT='" + cTpCont + "' AND "
		ElseIf !lIniFim .AND. !Empty(cHoraIni)		
			cQuery += "ABB_DTINI= '" + DToS( dDataIni ) + "' AND "
			cQuery += "ABB_HRINI='" + Alltrim(cHoraIni) + "' AND "
			cQuery += "ABB_DTFIM>'" + DToS( dDataIni ) + "' AND "
			cQuery += "AB6.AB6_CONTRT='" + cContrato + "' AND "
			cQuery += "AB6.AB6_TPCONT='" + cTpCont + "' AND "
		ElseIf !lIniFim .AND. !Empty(cHoraFim)	
			cQuery += "ABB_DTINI< '" + DToS( dDataIni ) + "' AND "
			cQuery += "ABB_HRFIM='" + Alltrim(cHoraFim) + "' AND "
			cQuery += "ABB_DTFIM='" + DToS( dDataIni ) + "' AND "
			cQuery += "AB6.AB6_CONTRT='" + cContrato + "' AND "
			cQuery += "AB6.AB6_TPCONT='" + cTpCont + "' AND "
		Else
			cQuery += "ABB_NUMOS='" + cNumOs + "' AND "
			cQuery += "ABB_DTINI< '" + DToS( dDataIni ) + "' AND "
			cQuery += "ABB_DTFIM>'" + DToS( dDataIni ) + "' AND "
			cQuery += "AB6.AB6_CONTRT='" + cContrato + "' AND "
			cQuery += "AB6.AB6_TPCONT='" + cTpCont + "' AND "
		EndIf	
		
		cQuery += "ABB.D_E_L_E_T_=' ' AND AB6.D_E_L_E_T_=' ' "
		
		cQuery := ChangeQuery( cQuery )
		
	Case nPos == 3 //Cliente
		
		cInterval	:= SubStr(oObj:aItems[oObj:nAt], 1 , 4)
	
		If ("(I)"  $ cInterval) .OR. ("(F)" $ cInterval)
			If ("(I)"  $ cInterval)
				cHoraIni	:= SubStr(oObj:aItems[oObj:nAt], 5 , 6) 
				cLoja		:= SubStr(oObj:aItems[oObj:nAt], 14 , TamSX3("A1_LOJA")[1])
				cCliente	:= SubStr(oObj:aItems[oObj:nAt], ((14 + TamSX3("A1_LOJA")[1])+3),TamSX3("A1_NOME")[1])	
				cCliente	:= Posicione("SA1",2,XFILIAL("SA1") + Padr(AllTrim(cCliente),TamSX3("A1_NOME")[1]) + Padr(AllTrim(cLoja),TamSX3("A1_LOJA")[1]), "A1_COD")
				lIniFim 	:= .F.
			ElseIf ("(F)" $ cInterval)
				cHoraFim	:= SubStr(oObj:aItems[oObj:nAt], 5 , 6) 
				cLoja		:= SubStr(oObj:aItems[oObj:nAt], 14 , TamSX3("A1_LOJA")[1])
				cCliente	:= SubStr(oObj:aItems[oObj:nAt], ((14 + TamSX3("A1_LOJA")[1])+3),TamSX3("A1_NOME")[1])	
				cCliente	:= Posicione("SA1",2,XFILIAL("SA1") + Padr(AllTrim(cCliente),TamSX3("A1_NOME")[1]) + Padr(AllTrim(cLoja),TamSX3("A1_LOJA")[1]), "A1_COD")
				lIniFim 	:= .F.
			EndIf	
		ElseIf (":" $ cInterval)
			cHoraIni	:= SubStr(oObj:aItems[oObj:nAt], 1 , 5)	
			cHoraFim	:= SubStr(oObj:aItems[oObj:nAt], 6 , 7)
			cLoja		:= SubStr(oObj:aItems[oObj:nAt], 15 , TamSX3("A1_LOJA")[1])
			cCliente	:= SubStr(oObj:aItems[oObj:nAt], ((15 + TamSX3("A1_LOJA")[1])+3), TamSX3("A1_NOME")[1])	
			cCliente	:= Posicione("SA1",2,XFILIAL("SA1") + Padr(AllTrim(cCliente),TamSX3("A1_NOME")[1]) + Padr(AllTrim(cLoja),TamSX3("A1_LOJA")[1]), "A1_COD")
		Else
			cNumOs 		:= SubStr(oObj:aItems[oObj:nAt], 3  ,  TamSX3("ABB_NUMOS")[1])
			cLoja		:= SubStr(oObj:aItems[oObj:nAt], 15 , TamSX3("A1_LOJA")[1])
			cCliente	:= SubStr(oObj:aItems[oObj:nAt], ((15 + TamSX3("A1_LOJA")[1])+3), TamSX3("A1_NOME")[1])
			cCliente	:= Posicione("SA1",2,XFILIAL("SA1") + Padr(AllTrim(cCliente),TamSX3("A1_NOME")[1]) + Padr(AllTrim(cLoja),TamSX3("A1_LOJA")[1]), "A1_COD")
			lIniFim	:= .F.
		EndIf
		
		
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta Query para posicionar na OS certa	   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		cQuery := ""
		
		cQuery += "SELECT DISTINCT AB6.*,ABB.*,ABB.R_E_C_N_O_ ABBRECNO FROM " + RetSqlName( "AB6" )+ " AB6 "
		cQuery += "INNER JOIN " + RetSqlName( "ABB" ) + " ABB ON ABB.ABB_FILIAL='D MG 01 ' AND ABB.ABB_NUMOS = AB6.AB6_NUMOS "
		cQuery += "INNER JOIN " + RetSqlName( "AAH" ) + " AAH ON AAH.AAH_CONTRT = AB6.AB6_CONTRT "	
		cQuery += "WHERE "
		cQuery += "AB6_FILIAL='" + xFilial( "ABB" ) + "' AND "
		
		If lIniFim
			cQuery += "ABB_DTINI= '" + DToS( dDataIni ) + "' AND "
			cQuery += "ABB_HRINI='" + Alltrim(cHoraIni) + "' AND "
			cQuery += "ABB_DTFIM='" + DToS( dDataIni ) + "' AND "
			cQuery += "ABB_HRFIM='" + AllTrim(cHoraFim) + "' AND "
			cQuery += "AAH.AAH_CODCLI='" + cCliente + "' AND "
			cQuery += "AAH.AAH_LOJA='" + cLoja + "' AND "
		ElseIf !lIniFim .AND. !Empty(cHoraIni)		
			cQuery += "ABB_DTINI= '" + DToS( dDataIni ) + "' AND "
			cQuery += "ABB_HRINI='" + Alltrim(cHoraIni) + "' AND "
			cQuery += "ABB_DTFIM>'" + DToS( dDataIni ) + "' AND "
			cQuery += "AAH.AAH_CODCLI='" + cCliente + "' AND "
			cQuery += "AAH.AAH_LOJA='" + cLoja + "' AND "
		ElseIf !lIniFim .AND. !Empty(cHoraFim)	
			cQuery += "ABB_DTINI< '" + DToS( dDataIni ) + "' AND "
			cQuery += "ABB_HRFIM='" + Alltrim(cHoraFim) + "' AND "
			cQuery += "ABB_DTFIM='" + DToS( dDataIni ) + "' AND "
			cQuery += "AAH.AAH_CODCLI='" + cCliente + "' AND "
			cQuery += "AAH.AAH_LOJA='" + cLoja + "' AND "
		Else
			cQuery += "ABB_NUMOS='" + cNumOs + "' AND "
			cQuery += "ABB_DTINI< '" + DToS( dDataIni ) + "' AND "
			cQuery += "ABB_DTFIM>'" + DToS( dDataIni ) + "' AND "
			cQuery += "AAH.AAH_CODCLI='" + cCliente + "' AND "
			cQuery += "AAH.AAH_LOJA='" + cLoja + "' AND "
		EndIf	
		
		cQuery += "ABB.D_E_L_E_T_=' ' AND AB6.D_E_L_E_T_=' ' AND AAH.D_E_L_E_T_=' ' "
		
		cQuery := ChangeQuery( cQuery )
		
	End Case
	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ),  cAliasAlter	, .T., .T. ) 
	
	TcSetField(  cAliasAlter	, "ABB_DTINI", "D", 8, 0 ) 
	TcSetField(  cAliasAlter	, "ABB_DTFIM", "D", 8, 0 ) 
	
	bWhile := { || !(  cAliasAlter	 )->( Eof() ) }
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o aCols    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	While Eval( bWhile ) 
		
		If !Empty(cNumOsFilt) .AND. cNumOsFilt != ( cAliasAlter )->ABB_NUMOS //Valida Filtro de O.S.
			lTravas := .F.
			Help("",1,"TECA510OS",,STR0056+cNumOsFilt,1) //"Ordem de Serviço Inválida. É possível manipular apenas a O.S. "
		EndIf
		
		ABB->( MsGoto( nRecnoABB := ( cAliasAlter )->ABBRECNO ) )				  
		
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se foi escolhido uma data para ser movido o registro	     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc == 6 .AND. lMove
			If ( cAliasAlter )->ABB_DTINI < ( cAliasAlter )->ABB_DTFIM
				cDif := (( cAliasAlter )->ABB_DTFIM - ( cAliasAlter )->ABB_DTINI)
			EndIf
		ElseIf !lMove
			lTravas := .F.
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se a opção escolhida é de Visualização da O.S	  	  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc == 7
			AT510VisOS(( cAliasAlter )->ABB_NUMOS)
			lTravas := .F.
		EndIf
		
		If AtTravaReg( "ABB" , aTravas)
			Aadd(aRegistros, ABB->(RecNo()) )
			Aadd(aCols,Array(nUsado+1))
			For nCntFor := 1 To nUsado
				If nOpc <> 7 .AND. nOpc <> 6
					If aHeader[nCntFor,2] == "ABB_ALI_WT"
						aCols[Len(aCols)][nCntFor] := "ABB"
					ElseIf aHeader[nCntFor,2] == "ABB_REC_WT"
						aCols[Len(aCols)][nCntFor] := ABB->( Recno() )
					ElseIf ( aHeader[nCntFor][10] <> "V")
						aCols[Len(aCols)][nCntFor] := ABB->(FieldGet(FieldPos(aHeader[nCntFor][2])))
					Else
						aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor,2])
					EndIf
				ElseIf nOpc == 7
					If aHeader[nCntFor,2] == "ABB_ALI_WT"
						aCols[Len(aCols)][nCntFor] := "ABB"
					ElseIf aHeader[nCntFor,2] == "ABB_REC_WT"
						aCols[Len(aCols)][nCntFor] := 0	
					ElseIf ( aHeader[nCntFor][10] <> "V" .AND. aHeader[nCntFor][2] <> "ABB_CODTEC")
						aCols[Len(aCols)][nCntFor] := ABB->(FieldGet(FieldPos(aHeader[nCntFor][2])))
					Else
						aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor,2])
					EndIf
				ElseIf nOpc == 6 .AND. lMove
					If aHeader[nCntFor,2] == "ABB_ALI_WT"
						aCols[Len(aCols)][nCntFor] := "ABB"
					ElseIf aHeader[nCntFor,2] == "ABB_REC_WT"
						aCols[Len(aCols)][nCntFor] := ABB->( Recno() )
					ElseIf ( aHeader[nCntFor][2] == "ABB_DTINI ") 
						aCols[Len(aCols)][nCntFor] := dDataMov
					ElseIf ( aHeader[nCntFor][2] == "ABB_DTFIM ")
						If cDif > 0
							aCols[Len(aCols)][nCntFor] := (dDataMov + cDif)
						Else
							aCols[Len(aCols)][nCntFor] := dDataMov
						EndIf	
					ElseIf ( aHeader[nCntFor][10] <> "V")
						aCols[Len(aCols)][nCntFor] := ABB->(FieldGet(FieldPos(aHeader[nCntFor][2])))	
					Else
						aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor,2])
					EndIf	
				EndIf					
			Next
			aCols[Len(aCols)][nUsado+1] := .F.
		Else
			lTravas := .F.
		EndIf
		( cAliasAlter )->( dbSkip() ) 	
	End	   
	(cAliasAlter)->(DbCloseArea()) 	   
ElseIf nOpc == 4
	Aviso(STR0028,STR0030,{STR0029}, 2) //"Atenção","Não é possivel alterar uma linha vazia",{"OK"}
	lTravas := .F.
ElseIf nOpc == 6
	Aviso(STR0028,STR0031,{STR0029}, 2) //"Atenção","Não é possivel Mover uma linha vazia",{"OK"}
	lTravas := .F.
ElseIf nOpc == 5
	Aviso(STR0028,STR0032,{STR0029}, 2) //"Atenção","Não é possivel Excluir uma linha vazia",{"OK"}
	lTravas := .F.
ElseIf nOpc == 7
	Aviso(STR0028,STR0039,{STR0029}, 2) //"Atenção","Não é possivel Visualizar a O.S de uma linha vazia",{"OK"}
	lTravas := .F.	
EndIf 

RestArea(aAreaABB)
RestArea(aAreaAB6)
RestArea(aAreaAA1)
RestArea(aAreaAAH)

Return( lTravas )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510LINOK³ Autor ³ Vendas CRM         ³ Data ³ 10.01.12    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tratamento da Linha Ok da GetDados                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1: Indica se a Linha e valida                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AT510LINOK()

Local lRetorno		 := .T.													//Retorno da funcao
Local nPosTec		:= aScan(aHeader,{|x| AllTrim(x[2])=="ABB_CODTEC"})		//Posicao do campo ABB_CODTEC
Local nPosDtIni		:= aScan(aHeader,{|x| AllTrim(x[2])=="ABB_DTINI"})		//Posicao do campo ABB_DTINI
Local nPosDtFim		:= aScan(aHeader,{|x| AllTrim(x[2])=="ABB_DTFIM"})		//Posicao do campo ABB_DTFIM
Local nPosHrIni		:= aScan(aHeader,{|x| AllTrim(x[2])=="ABB_HRINI"})		//Posicao do campo ABB_HRINI
Local nPosHrFim		:= aScan(aHeader,{|x| AllTrim(x[2])=="ABB_HRFIM"})		//Posicao do campo ABB_HRFIM
Local nUsado   		:= Len(aHeader)											//Nr. de campo no aHeader
Local nCntFor  		:= 0													//Usado em lacos For...Next

If ( !aCols[n][nUsado+1] )
	If ( 	!Empty(aCols[n][nPosDtIni]) .And.;
			!Empty(aCols[n][nPosDtFim]) .And.;
			!Empty(aCols[n][nPosHrIni]) .And.;
			!Empty(aCols[n][nPosHrFim]) )
		If ( Empty(AtTotHora(aCols[n][nPosDtIni],aCols[n][nPosHrIni],aCols[n][nPosDtFim],aCols[n][nPosHrFim])) )
			Help(" ",1,"AT500DATA3")
			lRetorno := .F.
		EndIf
	Else
		Help(" ",1,"AT500DATA3")
		lRetorno := .F.
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o horario nao esta alocado na Base                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("ABB")
	dbSetOrder(2)
	dbSeek(xFilial("ABB")+AA1->AA1_CODTEC+DTOS(aCols[n][nPosDtFim])+aCols[n][nPosHrFim],.T.)
	If ( 	ABB->ABB_CODTEC == AA1->AA1_CODTEC .And. ;
			(	aCols[n][nPosDtFim] <= ABB->ABB_DTFIM .And.;
				aCols[n][nPosHrFim] <= ABB->ABB_HRFIM .And.;
				aCols[n][nPosDtFim] >= ABB->ABB_DTINI .And.;
				aCols[n][nPosHrFim] >= ABB->ABB_HRINI ) .Or.;
			(	aCols[n][nPosDtIni] <= ABB->ABB_DTFIM .And.;
				aCols[n][nPosHrIni] <= ABB->ABB_HRFIM .And.;
				aCols[n][nPosDtIni] >= ABB->ABB_DTINI .And.;
				aCols[n][nPosHrIni] >= ABB->ABB_HRINI ))
	    If ( aScan(aRegistros,ABB->(RecNo()))==0 )
			Help(" ",1,"AT500LIN01")
			lRetorno := .F.
        EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o horario nao esta alocado no Acols para o mesmo técnico    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCntFor := 1 To Len(aCols)
		If ( !aCols[nCntFor][nUsado+1] )
			If (aCols[n][nPosTec] == aCols[nCntFor][nPosTec])
				If (( aCols[n][nPosDtFim] <= aCols[nCntFor][nPosDtFim] .And.;
						aCols[n][nPosHrFim] <= aCols[nCntFor][nPosHrFim] .And.;
						aCols[n][nPosDtFim] >= aCols[nCntFor][nPosDtIni] .And.;
						aCols[n][nPosHrFim] > aCols[nCntFor][nPosHrIni] ) .Or.;
				 	(	aCols[n][nPosDtIni] <= aCols[nCntFor][nPosDtFim] .And.;
						aCols[n][nPosHrIni] < aCols[nCntFor][nPosHrFim] .And.;
						aCols[n][nPosDtIni] >= aCols[nCntFor][nPosDtIni] .And.;
						aCols[n][nPosHrIni] >= aCols[nCntFor][nPosHrIni]))
            		If ( nCntFor <> n )
						Help(" ",1,"AT500LIN02")
						lRetorno := .F.
					EndIf
				EndIf
			EndIf	
		EndIf
	Next nCntFor
EndIf
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510TUDOOK³ Autor ³ Vendas CRM         ³ Data ³ 10.01.12   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tratamento da TudoOk   da GetDados                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1: Indica se TudoOk e valida                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function AT510TUDOOK()

Local lRetorno := .T.

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510Grava³ Autor ³ Eduardo Riera         ³ Data ³ 27.10.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a Gravacao da Agenda do Tecnico                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 : Indica se efetuou a Gravacao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function AT510Grava(lExclui, lCopia)

Local nCntFor 	:= 0
Local nCntFor2	:= 0
Local nUsado  	:= Len(aHeader)
Local lGravou 	:= .F.
Local dDataIni	:= Ctod("")
Local dDataFim	:= Ctod("")
Local cHoraIni	:= ""
Local cHoraFim	:= ""                                      
Local cCrLf   	:= Chr(13) + Chr(10) 
Local cCorpo  	:= "" 
Local nPosDIni	:= aScan(aHeader,{|x| AllTrim(x[2])=="ABB_DTINI"})
Local nPosDFim	:= aScan(aHeader,{|x| AllTrim(x[2])=="ABB_DTFIM"})
Local nPosHIni	:= aScan(aHeader,{|x| AllTrim(x[2])=="ABB_HRINI"})
Local nPosHFim	:= aScan(aHeader,{|x| AllTrim(x[2])=="ABB_HRFIM"})
Local lAT500Alt	:= ExistBlock("AT500ALT")
Local lAT500Grv	:= ExistBlock("AT500GRV")
Local lAT500Del	:= ExistBlock("AT500DEL")

Default lExclui := .F.
Default lCopia	  := .F.	

For nCntFor := 1 To Len(aCols)

	dbSelectArea("ABB")
	dbSetOrder(1)
	
	If ( nCntFor > Len(aRegistros) ) .OR. lCopia
		If ( !aCols[nCntFor][nUsado+1] )
			RecLock("ABB",.T.) 
		EndIf
	Else
		dbGoto(aRegistros[nCntFor])
		RecLock("ABB")
	EndIf
	
	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui a Linha Selecionada              	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lExclui
		aCols[nCntFor][nUsado+1] := .T.	
	EndIf
	
	If ( !aCols[nCntFor][nUsado+1])		
				
		If lAT500Alt
			ExecBlock( "AT500ALT", .F., .F.) 
		EndIf			
			
		
		For nCntFor2 := 1 To nUsado
			ABB->(FieldPut(FieldPos(aHeader[nCntFor2][2]),aCols[nCntFor][nCntFor2]))
		Next nCntFor2
		ABB->ABB_FILIAL 	:= xFilial("ABB")
		lGravou := .T.          
		
		If lAT500Grv
			ExecBlock( "AT500GRV", .F., .F.) 
		EndIf
	Else
		If ( nCntFor <= Len(aRegistros) )
			If lAT500Del
				ExecBlock( "AT500DEL", .F., .F.) 
			EndIf		
		dbDelete()
		EndIf
	EndIf	
	
Next nCntFor

Return(lGravou) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510MvCalend³ Autor ³ Vendas CRM         ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ 	Cria a tela com o calendario, para seleção do dia a ser   ³±±
³±±				Movimentado										          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Dia Escolhido	    				                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1: Area de Trabalho(oDlg)                               ³±±
±±³          ³ Exp2: Dia de Referencia                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AT510MvCalend( oWnd, dRef )

Local oDlgMov 
Local oPanel
Local oCalend
Local oFooter
Local oOk
Local oCancel
Local dRet		:= dRef
If !isBlind()
	Define MsDialog oDlgMov TITLE STR0019 FROM 000, 000 To 200, 300 Pixel Of oWnd //Mover Para
	
	@ 000, 000 MsPanel oPanel Of oDlgMov Size 100, 100
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	
	oCalend := MsCalend():New( 01, 01, oPanel, .T. )
	oCalend:Align   := CONTROL_ALIGN_ALLCLIENT
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define o dia a ser exibido no calendário    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oCalend:dDiaAtu := dRet
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Code-Block para Duplo Clik              	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oCalend:bLDblClick := { || dRet :=  oCalend:dDiaAtu, oDlgMov:End() }
	
	oCalend:CanMultSel := .F.
	
	@ 000, 000 MsPanel oFooter Of oDlgMov Size 000, 010
	oFooter:Align   := CONTROL_ALIGN_BOTTOM
	
	@ 000, 000 Button oCancel Prompt STR0013  Of oFooter Size 030, 000 Pixel //Cancelar
	oCancel:bAction := { || oDlgMov:End() }
	oCancel:Align   := CONTROL_ALIGN_RIGHT
	
	@ 000, 000 Button oOk     Prompt STR0014 Of oFooter Size 030, 000 Pixel //Confirmar
	oOk:bAction     := { || dRet := oCalend:dDiaAtu, oDlgMov:End() }
	oOk:Align       := CONTROL_ALIGN_RIGHT
	Activate MsDialog oDlgMov Centered
EndIf
Return  dRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510Title   ³ Autor ³ Vendas CRM         ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ 	Cria o Titulo com Mes e Ano			                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1:oCalend(Objeto da FWCALENDAR)                         ³±±
±±³          ³ Exp2:cMonth(Mes Corrente)                                  ³±±
±±³          ³ Exp3:cYear(Ano Corrente)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AT510Title(oCalend,cMonth,cYear)

Local cRet			:= ""
Local cTitulo 		:= ""

Default cMonth 	:= ""
Default cYear		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria String com o Mes e Ano corrente    	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cMonth) .AND. !Empty(cYear)
	cTitulo := oCalend:cNOMEMES + " / " + cYear
	cRet := AT510HtmlWeek(cTitulo)
Else
	cMonth    	:= SubStr(oCalend:cRef, 1, 2)
	cYear 		:= SubStr(oCalend:cRef, 4, 7)
	cTitulo := oCalend:cNOMEMES + " / " + cYear
	cRet := AT510HtmlWeek(cTitulo)	
EndIf

oMesAtual:SetText( cRet )

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510MnGrade ³ Autor ³ Vendas CRM         ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do MenuDef  					                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1:Alias                                                 ³±±
±±³          ³ Exp2:nReg                                                  ³±±
±±³          ³ Exp3:Nopcx                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AT510MnGrade(cAlias,nReg,nOpcx)

Local nOpcA			:= 0
Local lRet			:= .T.
Local aParam 		:= {} 
Local aAcho			:= {}

Private dData		:= dDataBase							//Utilizado no inicializador padrao.
Private cCadastro 	:= STR0004								//"Alocação de Técnicos"											
Private aRotina 	:= MenuDef()

aAcho := {	"ABB_CODTEC", "ABB_NUMOS","ABB_DTINI","ABB_HRINI","ABB_DTFIM","ABB_HRFIM","ABB_HRTOT","ABB_OBSERV","ABB_SACRA","ABB_CHEGOU","ABB_DATA","ABB_ATENDE"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³adiciona codeblock a ser executado no inicio, meio e fim  	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aParam,  {|| .T.} )  					//antes da abertura
aAdd( aParam,  {|| IncTudoOK(nOpcx) } )  //ao clicar no botao ok
aAdd( aParam,  {|| .T. } ) 				 //durante a transacao
aAdd( aParam,  {|| .T. } )       			//termino da transacao

If nOpcx > 3 .AND. !Empty(cNumeroOs) .AND. cNumeroOs != ABB->ABB_NUMOS 
	Help("",1,"TECA510OS",,STR0056+cNumeroOs,1) //"Ordem de Serviço Inválida. É possível manipular apenas a O.S. "
	lRet := .F.
EndIf

If lRet
	Do Case
		Case nOpcx == 2						
			FWExecView(,'TECA521', MODEL_OPERATION_VIEW,, { || .T. },,25 )			 
		Case nOpcx == 3
			FWExecView(,'TECA520', MODEL_OPERATION_INSERT,, { || .T. },,25 )
		Case nOpcx == 4
			FWExecView(,'TECA521', MODEL_OPERATION_UPDATE,, { || .T. },,25 )
		Case nOpcx == 5	
			FWExecView(,'TECA521', MODEL_OPERATION_DELETE,, { || .T. },,25 ) 
	EndCase
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza os dados no calendario        	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Eval(bFilter)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510Leg ³ Autor ³ Vendas CRM         ³ Data ³ 10.01.12     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Legendas 			  					                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1:Alias                                                 ³±±
±±³          ³ Exp2:nReg                                                  ³±±
±±³          ³ Exp3:Nopcx                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AT510Legenda()

Local oDlgLeg
Local oGroup
If !isBlind()
	Define MsDialog oDlgLeg TITLE STR0033 FROM 000, 000 To 120, 220 Pixel Of oMainWnd //Legenda	
		oGroup:= TGroup():New(01,01,55,112,STR0033,oDlgLeg,,,.T.)//Legenda
		@ 10,15 SAY STR0034 PIXEL SIZE 100,10 OF oGroup  		//"( I ) - Inicio do Atendimento"
		@ 20,15 SAY STR0035 PIXEL SIZE 100,10 OF oGroup		//"( F ) - Fim do Atendimento"	
		@ 30,15 SAY STR0036 PIXEL SIZE 100,10 OF oGroup		//"( M ) - Contrato de Manutenção"	
		@ 40,15 SAY STR0037 PIXEL SIZE 100,10 OF oGroup		//"( S ) - Contrato de Serviços"
	Activate MsDialog oDlgLeg Centered
EndIf
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³IncTudoOK    ³ Autor ³ Vendas CRM         ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o chamado já existe na Base,					  ³±±
±±³         para não haver duplicação                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1:Nopcx                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function IncTudoOK()

Local lRet := .T.
Local nRec		:= 0

nRec := M->(Recno())
		
If ( !Empty(M->ABB_DTINI) .And.;
		!Empty(M->ABB_DTFIM) .And.;
		!Empty(M->ABB_HRINI) .And.;
		!Empty(M->ABB_HRFIM) )
	If ( Empty(AtTotHora(M->ABB_DTINI,M->ABB_HRINI,M->ABB_DTFIM,M->ABB_HRFIM)) )
		Help(" ",1,"AT500DATA3")
				lRet := .F.
	EndIf
Else
	Help(" ",1,"AT500DATA3")
	lRet := .F.
EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o horario nao esta alocado na Base                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("ABB")
	DbSetOrder(2)
	DbSeek(xFilial("ABB")+PADR(AA1->AA1_CODTEC,TAMSX3("ABB_CODTEC")[1])+DTOS(M->ABB_DTFIM)+M->ABB_HRFIM,.T.)
	If ( 	M->ABB_CODTEC == AA1->AA1_CODTEC .And. ;
			(	M->ABB_DTFIM <= ABB->ABB_DTFIM .And.;
				M->ABB_HRFIM <= ABB->ABB_HRFIM .And.;
				M->ABB_DTFIM >= ABB->ABB_DTINI .And.;
				M->ABB_HRFIM >= ABB->ABB_HRINI ) .Or.;
			(	M->ABB_DTINI <= ABB->ABB_DTFIM .And.;
				M->ABB_HRINI <= ABB->ABB_HRFIM .And.;
				M->ABB_DTINI >= ABB->ABB_DTINI .And.;
				M->ABB_HRINI >= ABB->ABB_HRINI ))
	    If INCLUI .OR. nRec != ABB->(Recno())
				Help(" ",1,"AT500LIN01")
				lRet := .F.
	EndIf

EndIf

If lRet .AND. cNumeroOs != "" .AND. cNumeroOs != M->ABB_NUMOS 
	Help("",1,"TECA510OS",,STR0056+cNumeroOs,1) //"Ordem de Serviço Inválida. É possível manipular apenas a O.S. "
	lRet := .F.
EndIf

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510VisOS   ³ Autor ³ Vendas CRM         ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualizar a O.S          			                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1:Numero da O.S                                         ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AT510VisOS(cNumOS)

Local nReg 				:= 0
Local cAlias 			:= "AB6"

Private cCadastro 		:= STR0038  //"Ordem de Serviço"
Private aRotina 		:= {}
Private Inclui 			:= .F.
Private Altera 			:= .F.

Default cNumOS 			:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Visualizar a O.S ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
DbSelectArea("AB6")
DbSetOrder(1)

If DbSeek(xFilial( "AB6" ) + cNumOS)
	nReg := AB6->(Recno())
	aRotina := {{ STR0020 ,"AT450Visua" ,0 ,2}}
	AT450Visua(cAlias,nReg,1)
EndIf	 

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510aBrowse   ³ Autor ³ Vendas CRM       ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Popula o TWBrowse a esquerda da tela, conforme a perspectiva ³±±
±±³        ³ escolhida                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1:nPos(Posição da comboBox)                             ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AT510aBrowse(nPos,cAtendP,cContMP)

Local aRet 					:= {}
Local cAliasBrowse			:= GetNextAlias()			// Alias
Local cQuery				:= ""						//Query
Local aAreaAA1				:= AA1->(GetArea())			//Area AA1
Local aAreaAB6				:= AB6->(GetArea())			//Area AB6
Local aAreaSA1				:= SA1->(GetArea())			//Area SA1
Local cCli					:= ""						//Variavel para receber o nome do cliente
Local cNomEq				:= ""   					//Varialvel para receber o nome da equipe
Local nI 					:= 0
Local cCodCli				:= ""  
Local cContr				:= ""
Local cAtend				:= ""  
Local cAtPert				:= "" 
Local cCliLj				:= ""

Default cAtendP 			:= ""
Default cContMP				:= ""

If Select("cAliasBrowse") > 0 
	(cAliasBrowse)->(DbCloseArea())
Endif

If TYPE("cCodAtend") == "U"
	cCodAtend := ""
EndIF

If TYPE("cCodContr") == "U"
	cCodContr := ""
EndIf

DbSelectArea("AA1")
DbSetorder(4)

If DbSeek(xFilial("AA1")+__cUserId)
	cAtend := AA1->AA1_CODTEC
EndIf	

Do Case 
	Case nPos == 1 //Tecnico 
	    cAtPert := At510PTec(.T.)
	    	
		cQuery += "SELECT AA1.*,R_E_C_N_O_ AA1RECNO FROM " + RetSqlName( "AA1" ) + " AA1 "
		cQuery += "WHERE "
		cQuery += "AA1_FILIAL='" + xFilial( "AA1" ) + "' AND "   
		If Empty(cCodAtend) 
				cQuery += IIF(!Empty(cAtPert)," AA1_CODTEC IN ("+cAtPert+") AND ","")
			If Len(aFiltro) > 0
				cQuery += " AA1_CODTEC >= '"+ aFiltro[1][nPosAteDe] +"' AND "
				cQuery += " AA1_CODTEC <= '"+ aFiltro[1][nPosAteAte] +"' AND "				 		
			EndIf
		Else  
			cQuery += IIF(!Empty(cCodAtend)," AA1_CODTEC = '"+cCodAtend+"' AND ","")  
		EndIf
		cQuery += "D_E_L_E_T_=' '"

		
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ),  cAliasBrowse	, .T., .T. ) 
		
		While !(  cAliasBrowse	 )->( Eof() )
			AAdd(aRet, {( cAliasBrowse ) ->AA1_CODTEC , ( cAliasBrowse ) ->AA1_NOMTEC  })
			( cAliasBrowse )->(DbSkip())
		End
		
	Case nPos == 2 //Contrato
		If Empty(cCodAtend)
		
			If Len(aPerm) > 0
				For nI := 1 To Len(aPerm[1][2])         
					If nI >= 2
				    		cContr += ",'"+aPerm[1][2][nI][1]+"'"
				    	Else
			    			cContr += "'"+aPerm[1][2][nI][1]+"'"
				    	EndIf
		    	Next nI 
		    EndIf
		    
			cQuery += "SELECT AAH.*,R_E_C_N_O_ AAHRECNO FROM " + RetSqlName( "AAH" ) + " AAH "
			cQuery += "WHERE "
			cQuery += "AAH_FILIAL='" + xFilial( "AAH" ) + "' AND ""
			If (!Empty(cCodContr))
			    cQuery += "AAH_CONTRT = '"+cCodContr+"' AND "
			Else
				If Len(aPerm) > 0
					cQuery += "AAH_CONTRT IN ("+cContr+") AND "
				EndIf 			
			EndIf	
			If Len(aFiltro) > 0
			   cQuery += "AAH_CONTRT >= '"+aFiltro[1][nPosConDe]+"' AND AAH_CONTRT <= '"+aFiltro[1][nPosConAte]+"' AND "
			EndIf
			cQuery += "D_E_L_E_T_=' '"

			cQuery := ChangeQuery( cQuery )
			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ),  cAliasBrowse	, .T., .T. ) 

			While !(  cAliasBrowse	 )->( Eof() )
				cCli := Posicione("SA1",1,XFILIAL("SA1") + ( cAliasBrowse )->AAH_CODCLI + ( cAliasBrowse )->AAH_LOJA ,"A1_NOME" )
				AAdd(aRet, {( cAliasBrowse ) ->AAH_CONTRT , cCli  })
				( cAliasBrowse )->(DbSkip())
			End 
		Else
		
			cQuery += "SELECT AAH.*,R_E_C_N_O_ AAHRECNO FROM " + RetSqlName( "AAH" ) + " AAH "
			cQuery += "WHERE "
			cQuery += "AAH_FILIAL='" + xFilial( "AAH" ) + "' AND "
			If (!Empty(cCodContr))
			    cQuery += "AAH_CONTRT = '"+cCodContr+"' AND "
			Else
				cQuery += "AAH_CONTRT<> '' AND "
			EndIf	
			cQuery += "D_E_L_E_T_=' '"
		
			cQuery := ChangeQuery( cQuery )

			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ),  cAliasBrowse	, .T., .T. ) 
		
			While !(  cAliasBrowse	 )->( Eof() )
				cCli := Posicione("SA1",1,XFILIAL("SA1") + ( cAliasBrowse )->AAH_CODCLI + ( cAliasBrowse )->AAH_LOJA ,"A1_NOME" )
				AAdd(aRet, {( cAliasBrowse ) ->AAH_CONTRT , cCli  })
				( cAliasBrowse )->(DbSkip())
			End 
		EndIf 
	Case nPos == 3 //Cliente
	
		If Empty(cCodAtend)

			If Len(aPerm) > 0
			
				For nI := 1 To Len(aPerm[1][1])
					If nI >= 2
						cCodCli += ",'"+aPerm[1][1][nI][1]+"'"
						
					Else
						cCodCli += "'"+aPerm[1][1][nI][1]+"'"
					EndIf
				Next nI
	
		    	For nI := 1 To Len(aPerm[1][2])         
					If nI >= 2
				    	cContr += ",'"+aPerm[1][2][nI][1]+"'"
					Else
						cContr += "'"+aPerm[1][2][nI][1]+"'"
					EndIf
				Next nI
				
			Endif 

			cQuery += "SELECT AB6.*,R_E_C_N_O_ AB6RECNO FROM " + RetSqlName( "AB6" ) + " AB6 "
			cQuery += "WHERE "
			cQuery += "AB6_FILIAL='" + xFilial( "AB6" ) + "' AND "
			
			If Len(aPerm) > 0
				cQuery += "AB6_CODClI IN ("+cCodCli+") AND "
			EndIf
			 
			If (!Empty(cCodContr))
			    cQuery += "AB6_CONTRT = '"+cCodContr+"' AND "
			ElseIf Len(aPerm) > 0
				cQuery += "AB6_CONTRT IN ("+cContr+") AND "
			EndIf
			If !Empty(aFiltro)
				cQuery += "AB6_CODCLI >= '"+aFiltro[1][nPosCliDe]+"' AND AB6_CODCLI <= '"+aFiltro[1][nPosCliAte]+"' AND "
				cQuery += "AB6_CONTRT >= '"+aFiltro[1][nPosConDe]+"' AND AB6_CONTRT <= '"+aFiltro[1][nPosConAte]+"' AND "			   
			EndIf
			cQuery += "D_E_L_E_T_=' '"
			cQuery += "ORDER BY AB6_CODCLI, AB6_LOJA"
			cQuery := ChangeQuery( cQuery ) 

			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ),  cAliasBrowse	, .T., .T. ) 

			While !(  cAliasBrowse	 )->( Eof() )
				If (cAliasBrowse)->(AB6_CODCLI+AB6_LOJA) <> cCliLj
					cCli := Posicione("SA1",1,XFILIAL("SA1") + ( cAliasBrowse )->AB6_CODCLI + ( cAliasBrowse )->AB6_LOJA ,"A1_NOME" )
					AAdd(aRet, {Alltrim(( cAliasBrowse ) ->AB6_CODCLI )+ "/" +  Alltrim(( cAliasBrowse ) ->AB6_LOJA ) , cCli }) 
				EndIf
				cCliLj := (cAliasBrowse)->(AB6_CODCLI+AB6_LOJA)					
				( cAliasBrowse )->(DbSkip())
			End
		Else
			cQuery += "SELECT AB6.*,R_E_C_N_O_ AB6RECNO FROM " + RetSqlName( "AB6" ) + " AB6 "
			cQuery += "WHERE "
			cQuery += "AB6_FILIAL='" + xFilial( "AB6" ) + "' AND ""
			If (!Empty(cCodContr))
			    cQuery += "AB6_CONTRT = '"+cCodContr+"' AND "
			Else 
				cQuery += "AB6_CONTRT<> '' AND "
			EndIf	
			cQuery += "D_E_L_E_T_=' '"
			cQuery += "ORDER BY AB6_CODCLI, AB6_LOJA"
			cQuery := ChangeQuery( cQuery )
		
			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ),  cAliasBrowse	, .T., .T. ) 
		
			While !(  cAliasBrowse	 )->( Eof() )
				If (cAliasBrowse)->(AB6_CODCLI+AB6_LOJA) <> cCliLj
					cCli := Posicione("SA1",1,XFILIAL("SA1") + ( cAliasBrowse )->AB6_CODCLI + ( cAliasBrowse )->AB6_LOJA ,"A1_NOME" )
					AAdd(aRet, {Alltrim(( cAliasBrowse ) ->AB6_CODCLI )+ "/" +  Alltrim(( cAliasBrowse ) ->AB6_LOJA ) , cCli }) 
				EndIf
				cCliLj := (cAliasBrowse)->(AB6_CODCLI+AB6_LOJA)					
				( cAliasBrowse )->(DbSkip())
			End
		EndIf
	Case nPos == 4 // Base de atendimento

		If Empty(cCodAtend)			
			If Len(aPerm) > 0
				For nI := 1 To Len(aPerm[1][2])         
					If nI >= 2
			    		cContr += ",'"+aPerm[1][2][nI][1]+"'"
			    	Else
			   			cContr += "'"+aPerm[1][2][nI][1]+"'"
			    	EndIf
			   	Next             
		   	EndIf 

		    cQuery += "SELECT AA3.*,R_E_C_N_O_ AA3RECNO FROM " + RetSqlName( "AA3" ) + " AA3 "
			cQuery += "WHERE "
			cQuery += "AA3_FILIAL='" + xFilial( "AA3" ) + "' AND "   
		   	IF !Empty(cCodContr)
		   		cQuery += " AA3_CONTRT = '"+cCodContr+"' AND " 
		   	ElseIf Len(aPerm) > 0
		   		cQuery += " AA3_CONTRT IN ("+cContr+") AND "		   	
		   	EndIf
		   	If !Empty(aFiltro)
				cQuery += "AA3_CONTRT >= '"+aFiltro[1][nPosConDe]+"' AND AA3_CONTRT <= '"+aFiltro[1][nPosConAte]+"' AND "
				cQuery += "AA3_CODPRO >= '"+aFiltro[1][nPosProDe]+"' AND AA3_CODPRO <= '"+aFiltro[1][nPosProAte]+"' AND "
			EndIf		   		
			cQuery += "D_E_L_E_T_=' '"
 			cQuery := ChangeQuery( cQuery ) 
	
			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ),  cAliasBrowse	, .T., .T. ) 
	
			While !(  cAliasBrowse	 )->( Eof() )
				AAdd(aRet, {( cAliasBrowse )->AA3_CODPRO, ( cAliasBrowse )->AA3_NUMSER })
				( cAliasBrowse )->(DbSkip())
			End	
	
		Else	
			cQuery += "SELECT AA3.*,R_E_C_N_O_ AA3RECNO FROM " + RetSqlName( "AA3" ) + " AA3 "
			cQuery += "WHERE "
			cQuery += "AA3_FILIAL='" + xFilial( "AA3" ) + "' AND "   
		   	cQuery += IIF(!Empty(cCodContr)," AA3_CONTRT = '"+cCodContr+"' AND ","") 
			cQuery += "D_E_L_E_T_=' '"
			cQuery := ChangeQuery( cQuery ) 

			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ),  cAliasBrowse	, .T., .T. ) 

			While !(  cAliasBrowse	 )->( Eof() )
				AAdd(aRet, {( cAliasBrowse )->AA3_CODPRO, ( cAliasBrowse )->AA3_NUMSER })
				( cAliasBrowse )->(DbSkip())
			End	
        EndIf          
        
	Case nPos == 5 //Equipes 

        If Aliasindic("AAY") .AND. Aliasindic("AAX") 
			cQuery += "SELECT AAY.*,R_E_C_N_O_ AAYRECNO FROM " + RetSqlName( "AAY" ) + " AAY "
			cQuery += "WHERE "
			cQuery += "AAY_FILIAL='" + xFilial( "AAY" ) + "' AND "   
			If Empty(cCodAtend)
		   		cQuery += IIF(!Empty(cAtend)," AAY_CODTEC = '"+cAtend+"' AND ","") 
		   	Else
				cQuery += " AAY_CODTEC = " + cCodAtend + " AND "  			   	
		   	EndIf	
			If Len(aFiltro) > 0
				cQuery += "AAY_CODEQU >= '"+aFiltro[1][nPosEqpDe]+"' AND AAY_CODEQU <= '"+aFiltro[1][nPosEqpAte]+"' AND "
			EndIf
			cQuery += "D_E_L_E_T_=' '"
			cQuery := ChangeQuery( cQuery ) 
			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ),  cAliasBrowse	, .T., .T. ) 
	
			While !(  cAliasBrowse	 )->( Eof() )
				cNomEq := Posicione("AAX",1,XFILIAL("AAX") + ( cAliasBrowse )->AAY_CODEQU ,"AAX_NOME" )
				AAdd(aRet, {( cAliasBrowse ) ->AAY_CODEQU, cNomEq })
				( cAliasBrowse )->(DbSkip())
			End	
		EndIf
		
	Case nPos == 6 //Local de atendimento
		
	 		If Len(aPerm) > 0
				For nI := 1 To Len(aPerm[1][2])         
					If nI >= 2
			    		cContr += ",'"+aPerm[1][2][nI][1]+"'"
			    	Else
			   			cContr += "'"+aPerm[1][2][nI][1]+"'"
			    	EndIf
			   	Next             
		   	EndIf
	 		
	 		cQuery += "SELECT DISTINCT TFL.TFL_LOCAL, ABS.ABS_DESCRI"	 		
	 		cQuery += " FROM " + RetSqlName( "TFL" ) + " TFL "
	 		cQuery += " LEFT JOIN " + RetSqlName( "ABS" ) + " ABS " 
	 		cQuery += " ON ABS.ABS_FILIAL = '" + xFilial( "ABS" ) + "'"
	 		cQuery += " AND ABS.ABS_LOCAL = TFL.TFL_LOCAL "
	 		cQuery += " AND ABS.D_E_L_E_T_ <> '*' "	 		
	 		cQuery += " LEFT JOIN " + RetSqlName( "AAH" ) + " AAH " 
	 		cQuery += " ON AAH.AAH_FILIAL = '" + xFilial( "AAH" ) + "'"
	 		cQuery += " AND AAH.AAH_CONTRT = TFL.TFL_CONTRT "
	 		cQuery += " AND AAH.D_E_L_E_T_ <> '*' "	 		  
			cQuery += " LEFT JOIN " + RetSqlName( "CN9" ) + " CN9 " 
	 		cQuery += " ON CN9.CN9_FILIAL = '" + xFilial( "CN9" ) + "'"
	 		cQuery += " AND CN9.CN9_NUMERO = TFL.TFL_CONTRT "
	 		cQuery += " AND CN9.CN9_REVISA = TFL.TFL_CONREV "
	 		cQuery += " AND CN9.D_E_L_E_T_ <> '*' "	 		  
			cQuery += " WHERE "
			cQuery += " TFL_FILIAL='" + xFilial( "TFL" ) + "'"
			cQuery += " AND (AAH.AAH_CONTRT IS NULL OR AAH.AAH_STATUS = '1') "   
			cQuery += " AND (CN9.CN9_NUMERO IS NULL OR CN9.CN9_SITUAC = '05') "
			
			If !Empty(cCodContr)
		   		cQuery += " AND TFL.TFL_CONTRT = '" + cCodContr + "'"
		   	ElseIf Len(aPerm) > 0 
		   		cQuery += " AND TFL.TFL_CONTRT IN (" + cContr + ") "	
		   	EndIf
		   	
		   	If Len(aFiltro) > 0
		   	   cQuery += " AND TFL.TFL_LOCAL >= '"+aFiltro[1][nPosLocDe]+"' AND TFL.TFL_LOCAL <= '"+aFiltro[1][nPosLocAte]+ "'"
		   	EndIf  
		   	 
			cQuery += " AND TFL.D_E_L_E_T_ <> '*' "
			cQuery := ChangeQuery( cQuery )			
									
			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ),  cAliasBrowse	, .T., .T. ) 

			While !(  cAliasBrowse	 )->( Eof() )
				AAdd(aRet, {( cAliasBrowse )->TFL_LOCAL, ( cAliasBrowse )->ABS_DESCRI })
				( cAliasBrowse )->(DbSkip())
			End	
		
End Case

cCli := ""
cNomEq := ""

( cAliasBrowse )->(DbCloseArea()) 
RestArea(aAreaAA1)
RestArea(aAreaAB6)
RestArea(aAreaSA1)

Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510bline   ³ Autor ³ Vendas CRM         ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ação ao dar o Duplo click no TWBROWSE                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AT510bline(aBrowse)

Local aRetBrw	  	:= {}
Local cFilter	  	:= ""
Local cExpADVPL 	:= ""
Local cCli		  	:= ""
Local cLoja	  		:= ""
Local cLocal	  	:= ""
Local nCli		  	:= 0   
Local nPosCombo 	:= 0            
Local cEquipe	  	:= ""
Local cContNS	  	:= ""
Local aAreaABB  	:= ABB->(GetArea())
Local aAreaAB6  	:= AB6->(GetArea())
Local aAreaSA1  	:= SA1->(GetArea())		           

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Recupera o Array com as Informações do TWBrowse		    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
aRetBrw := oTWBrowse:aArray

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa os filtros criados anteriormente					    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oMBrwWA:oFwFilter:CleanFilter()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não permite executar a ação com o array vazio			    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(aRetBrw)
	Return .F.
EndIf

nPosCombo := oCombo1:nAt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria e executa os filtros conforme a seleção			    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
Do Case
	Case nPosCombo == 1
		If !Empty(aRetBrw[oTWBrowse:nAt][1])
			cFIlter	:= STR0065 + aRetBrw[oTWBrowse:nAt][1] + "'" //"Atendente Igual a '"
			cExpADVPL 	:= "ABB_CODTEC='" + aRetBrw[oTWBrowse:nAt][1] + "'"
			oMBrwWA:AddFilter(cFilter,cExpADVPL,,.T.)	
			oMBrwWA:oFwFilter:ExecuteFilter()
			AT510FTABB(,"ABB",oCalend, oCombo1:nAt)
		EndIf	
	Case nPosCombo == 2
		If !Empty(aRetBrw[oTWBrowse:nAt][1])
			cFIlter	:= STR0066 + aRetBrw[oTWBrowse:nAt][1] + "'" //"Contrato Igual a '"
			cExpADVPL 	:= "AB6_CONTRT='" + aRetBrw[oTWBrowse:nAt][1] + "'"
			oMBrwWA:AddFilter(cFilter,cExpADVPL,,.T.,"AB6")	
			oMBrwWA:oFwFilter:ExecuteFilter()
			AT510FTAB6(,"ABB",oCalend, oCombo1:nAt)
		EndIf
	Case nPosCombo == 3
		If !Empty(aRetBrw[oTWBrowse:nAt][1])
			nCli	:= AT("/" , aRetBrw[oTWBrowse:nAt][1] )		
			cCli	:= SubStr(aRetBrw[oTWBrowse:nAt][1], 1 , (nCli - 1))
			cLoja := SubStr(aRetBrw[oTWBrowse:nAt][1], (nCli +1) , Len(aRetBrw[oTWBrowse:nAt][1]))
			cFIlter	:= STR0067 + aRetBrw[oTWBrowse:nAt][1] + "'" //"Cliente Igual a '"
			cExpADVPL 	:= "AB6_CODCLI='" + cCli + "' AND AB6_LOJA='" + cLoja + "'"
			oMBrwWA:AddFilter(cFilter,cExpADVPL,,.T.,"AB6")	
			oMBrwWA:oFwFilter:ExecuteFilter()
			AT510FTSA1(,"ABB",oCalend, oCombo1:nAt)
		EndIf	
	Case nPosCombo == 4
		If !Empty(aRetBrw[oTWBrowse:nAt][2])
			cFilter := STR0068 + aRetBrw[oTWBrowse:nAt][2] +  "'"	 //"Base de Atendimento igual a '" 
	
	        AA3->(DbSetOrder(6)) //AA3_FILIAL+AA3_NUMSER
	        If AA3->(DbSeek(xFilial("AA3")+aRetBrw[oTWBrowse:nAt][2]))
	        	cContNS := AA3->AA3_CONTRT
			EndIf
			
			cExpADVPL := "AB6_CONTRT = '"+ cContNS + "'"
			oMBrwWA:AddFilter(cFilter,cExpADVPL,,.T.,"AB6")	
			oMBrwWA:oFwFilter:ExecuteFilter()
			AT510FTAB6(,"ABB",oCalend, oCombo1:nAt)
		EndIf	
EndCase

aRetBrw:= {}

RestArea(aAreaABB)
RestArea(aAreaAB6)
RestArea(aAreaSA1)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AT510ClFilter ³ Autor ³ Vendas CRM        ³ Data ³ 10.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ação da opção Limpar Filtros 		                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 										                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AT510ClFilter()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza a limpeza dos filtros criados na FWMBrowse 	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMBrwWA:oFwFilter:CleanFilter()
oTWBrowse:setFocus() 

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³At510GrAAtºAutor  ³Microsiga           º Data ³  12/03/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava as entidades de vistoria tecnica na tabela AAT        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TECA510                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function At510GrAAt(cCodTec,dDtIni, cHrIni, dDtFim , cHrFim)

Local aAreaAAt 		:= AAT->(GetArea())
Local cChave		:= TxGetVar( "ABB_CHAVE" ) 
Local cAtend		:= TxGetVar( "ABB_ATENDE" )
Local lRetorno		:= .F.

DbSelectArea("AAT")
DbSetOrder(1)

If AAT->(DbSeek(XFilial("AAT")+cChave))
	If cAtend == "1"
		RecLock("AAT",.F.)
 		AAT->AAT_STATUS	:= "3"
	Else	 		
		RecLock("AAT",.F.)
 		AAT->AAT_DTINI 	:= dDtIni
 		AAT->AAT_HRINI	:= cHrIni
 		AAT->AAT_DTFIM	:= dDtFim
 		AAT->AAT_HRFIM	:= cHrFim
 		AAT->AAT_STATUS	:= "2"
	EndIf 	
	MsUnLock()  
 	lRetorno := .T.
EndIf  

RestArea(aAreaAAT) 

Return (lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³At510FPGrlºAutor  ³Microsiga           º Data ³  12/04/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se tem permissão para incluir,alterar e excluir    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TECA510                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/   
Function At510FPGrl(oModel)
      
Local aPermissao 		:= At201Perm() 
Local nOperation		:= IIf(oModel!=Nil,oModel:GetOperation(),0)
Local lRet				:= .T.   
Local nI				:= 0   
Local cContrato			:= "" 
Local cTpPer			:= "" 
Local lAcessoRot		:= .T. 
Local lObgPerm			:= SuperGetMv("MV_TECPCON",,.F.)

If lObgPerm

	If Empty(aPermissao)	
		lAcessoRot := .F.
		aPermissao := {}	
	Else
	    DbSelectArea("AB6")
		DbSetOrder(1)
		DbSeek(xFilial("AB6")+ABB->ABB_NUMOS)
	    
		For nI := 1 To Len(aPermissao[1][2])  
		    If AB6->AB6_CONTRT == aPermissao[1][2][nI][1]
		       cTpPer := aPermissao[1][2][nI][2]
		    EndIf
			cContrato += aPermissao[1][2][nI][1]+"/"
		Next	
	EndIf
	    
	DbSelectArea("AB6")
	DbSetOrder(1)
	If DbSeek(xFilial("AB6")+ABB->ABB_NUMOS)
		If AB6->AB6_CONTRT $ cContrato
		   lAcessoRot := .T. 	        
	    Else
	       lAcessoRot := .F.
	    EndIf   
	EndIf
		           
	If nOperation == MODEL_OPERATION_INSERT 
		If !lAcessoRot 
	 	 	lRet := .F.  
	 	 	Help("",1,"At510FPGrl",,STR0060,2,0) //"O Técnico não possui permissão para Inclusão"
	 	Else
	 		If cTpPer == '2'
	 			lRet := .F.
	 		EndIf	 	
		EndIf
	ElseIf nOperation == MODEL_OPERATION_UPDATE
		If !lAcessoRot 
	 	 	lRet := .F.  
	 	 	Help("",1,"At510FPGrl",,STR0061,2,0) //"O Técnico não possui permissão para Alteração"
		Else
	 		If cTpPer == '2'
	 			lRet := .F.
	 		EndIf
		EndIf
	ElseIf nOperation == MODEL_OPERATION_DELETE  
		If !lAcessoRot 
	 	 	lRet := .F.  
	 	 	Help("",1,"At510FPGrl",,STR0062,2,0) //"O Técnico não possui permissão para Deleção"
	 	Else
	 		If cTpPer == '2'
	 			lRet := .F.
	 		EndIf	
		EndIf 
	ElseIf nOperation == 0
		If !lAcessoRot
		   lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³At510PTec ºAutor  ³Microsiga           º Data ³  04/23/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna os atendentes com permissões                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function At510PTec(lSql)
Local cVerifAt 	:= ""             
Local nY     	:= 0
Local nPrReg 	:= 0
Local aEq 		:= {}
Local cAtPert	:= ""                                         
Local aArea		:= GetArea()
Local aAreaAA1	:= AA1->(GetArea())		//Area AA1
Local cAtend	:= ""          
Local cAtPer	:= ""

Default lSql 	:= .F.

DbSelectArea("AA1")
DbSetorder(4)
If DbSeek(xFilial("AA1")+__cUserId)
	cAtend := AA1->AA1_CODTEC
EndIf	

DbSelectArea("AAY")
AAY->(DbSetOrder(2)) //AAY_FILIAL+AAY_CODTEC
If AAY->(DBSeek(xFilial("AAY")+cAtend))
	cVerifAt := xFilial("AAY")+cAtend
	While AAY->(!EOF()) .AND. cVerifAt == xFilial("AAY")+AAY->AAY_CODTEC
		aAdd(aEq,{AAY_CODEQU})
		AAY->(DbSkip())
	End
Else
	If !Empty(cAtend)
		cAtPert += "'"+cAtend+"'"
		cAtPer += cAtend+"|"
	EndIf
EndIf
	
For nY := 1 To Len(aEq)
	AAY->(DbSetOrder(1))  //AAY_FILIAL+AAY_CODEQU
	AAY->(DbSeek(xFilial("AAY")+aEq[nY][1]))
		
	While AAY->(!EOF()) .And. xFilial("AAY") == AAY->AAY_FILIAL .AND. aEq[nY][1] == AAY->AAY_CODEQU
		cAtPer	+= AAY->AAY_CODTEC +"|"
		If nPrReg == 0
			cAtPert += "'"+AAY->AAY_CODTEC+"'"
		Else
			cAtPert += ",'"+AAY->AAY_CODTEC+"'"
		EndIf
		AAY->(DbSkip())
		nPrReg++
	End
Next      

RestArea(aAreaAA1)
RestArea(aArea)
      
Return Iif(lSql,cAtPert,cAtPer)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³At510POS  ºAutor  ³Microsiga           º Data ³  04/23/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna as Ordens de Serviços que estão vínculadas ao       º±±
±±º          ³contrato referente                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function At510POS(cContrato)
Local cOs 		:= ""
Local aArea 	:= GetArea()
Local aAreaAB6 	:= AB6->(GetArea())

AB6->(DbSelectArea("AB6"))

AB6->(DbSetOrder(6))

If AB6->(MsSeek(XFilial("AB6")+"1"+cContrato))
	While !AB6->(EOF()) .AND. xFilial("AB6")+"1"+cContrato == AB6->AB6_FILIAL+AB6->AB6_TPCONT+AB6->AB6_CONTRT			 	
		cOs += AB6->AB6_NUMOS+"|"
		AB6->(DbSkip())
	End
EndIf

RestArea(aAreaAB6)
RestArea(aArea)

Return cOs

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³At510PCtr ºAutor  ³Microsiga           º Data ³  04/23/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function At510PCtr()
Local cOs 		:= ""
Local cContrato := cCodContr
Local nI 		:= 0

For nI := 1 To Len(aPerm[1][2])
   	cOs += At510POS(aPerm[1][2][nI][1])
Next  nI      

cCodContr := cContrato

Return cOs

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TECA510   ºAutor  ³Microsiga           º Data ³  04/26/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o array com os dados do pergunte                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function At510FilAg(aFiltro)

Local aArea 	:= GetArea()
Local lRet 		:= .F.
  
Default aFiltro := {}  

lRet := Pergunte("TECA510",.T.)

aFiltro := {}

/*-----------------------------------
MV_PAR01 - Atendente de
MV_PAR02 - Atendente ate
MV_PAR03 - Cliente de 
MV_PAR04 - Cliente ate
MV_PAR05 -	Contrato de Manut. de
MV_PAR06 -	Contrato de Manut. ate
MV_PAR07 -	Produto/Eqto de
MV_PAR08 -	Num. serie de 
MV_PAR09 -	Produto/Eqto ate
MV_PAR10 -	Num. serie ate
MV_PAR11 -	Equipe de 
MV_PAR12 -	Equipe ate
MV_PAR13 -	Num. Os de
MV_PAR14 -	Num. Os ate
MV_PAR15 -	Vistoria Tec de
MV_PAR16 -	Vistoria Tec ate
MV_PAR17 -	Tipo
MV_PAR18 - Local de
MV_PAR19 - Local ate
-----------------------------------*/
If lRet

	aAdd(aFiltro, { 	MV_PAR01, MV_PAR02,; // Atendente De e Ate
						MV_PAR03, MV_PAR04,; // Cliente De e Ate						
						MV_PAR05, MV_PAR06,; // Contrato De e Ate
						MV_PAR07, MV_PAR09,; // Produto/Eqto De e Ate
						MV_PAR08, MV_PAR10,; // Num. Serie De e Ate	
						MV_PAR11, MV_PAR12,; // Equipe De e Ate						
						MV_PAR13, MV_PAR14,; // Num. OS De e Ate
						MV_PAR15, MV_PAR16,; // Vistoria Tec De e Ate
						MV_PAR17,; 			// Tipo
						MV_PAR18, MV_PAR19 ; // Local De e Ate
					} )

EndIf     

RestArea(aArea)
                   
Return(lRet)
