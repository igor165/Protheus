#include "QIEA230.CH"
#include "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QIEA230	³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 14/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa Geracao do Indice de Qualidade Individual (Filial)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQIE													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³STR 	     ³ Ultimo utilizado -> 00019                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Paulo Emidio³24/03/03³XXXXXX³Otimizacao da Rotina para melhoria de per-³±±
±±³			   ³		³      ³formance.								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MenuDef()

Local aRotina := {{OemToAnsi(STR0006), "AxPesqui", 0, 1,,.F.},; //"Pesquisa"
					{OemToAnsi(STR0007), "AxVisual", 0, 2},; //"Visualiza"
					{OemToAnsi(STR0008), "Q230MIQF", 0, 3},; //"Inclui"   
					{OemToAnsi(STR0009), "Q230MIQF", 0, 4},; //"Altera"   
					{OemToAnsi(STR0010), "Q230DIQF", 0, 5}}  //"Exclui"

Return aRotina

Function QIEA230
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define as variaveis 										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemtoAnsi(STR0011)  //"Indice de Qualidade"    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa 	 ³
//³ ----------- Elementos contidos por dimensao ------------	 ³
//³ 1. Nome a aparecer no cabecalho 							 ³
//³ 2. Nome da Rotina associada									 ³
//³ 3. Usado pela rotina										 ³
//³ 4. Tipo de Transa‡„o a ser efetuada							 ³
//³	 1 - Pesquisa e Posiciona em um Banco de Dados				 ³
//³	 2 - Simplesmente Mostra os Campos							 ³
//³	 3 - Inclui registros no Bancos de Dados					 ³
//³	 4 - Altera o registro corrente								 ³
//³	 5 - Remove o registro corrente do Banco de Dados			 ³
//³	 6 - Nao permite inclusao na getdados						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse(06,01,22,75,"QEV")

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Q230MIQF ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 14/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera Indice Qualidade - Inclusao/Alteracao 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q230MIQF(cAlias,nReg,nOpc)      							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias do arquivo									  ³±±
±±³			 ³ EXPN1 = Numero do registro 								  ³±±
±±³			 ³ EXPN2 = Opcao selecionada no menu						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q230MIQF(cAlias,nReg,nOpc)       
Local oDlg 
Local bOk        := {||nOpcA := 1,oDlg:End()}
Local bCancel    := {||nOpcA := 0,oDlg:End()}
Local aAreaAnt   := GetArea()
Local lFatIQP
Local nOpcA      := 0
Local cDiaAnt    := ''
Local oAno 
Local oMes 
Local oFornece 
Local oData
Local lQEA231    := ExistBlock("QIEA231")             
Local nSavRot    := aRotina[3,4]
Local lDate      := .F.
Local cMesPos    := ''
Local oSize      
Local lButt		 := .T.
Local oSize

Private aButtons := {}
Private c230Mes  := StrZero(Month(MsDate()),2)
Private c230Ano  := Str(Year(MsDate()),4)
Private c230For  := CriaVar("QEV_FORNEC")
Private c230Dia  := StrZero(Val(GetMv("MV_QDIAMIQ")),2) //Dia de Fechamento no Mes para Calculo dos Indices
Private lDispMsg := .T.
Private cInvisivel := ""

If nOpc <> 3
	dbSelectArea(cAlias)
	c230Ano := QEV_ANO
	c230Mes := QEV_MES
	c230For := QEV_FORNEC
Else
	//Define o tipo para que a Inclusao nao retorne 
	aRotina[3,4] := 6
	Inclui       := .F.	
EndIf

cDiaAnt := c230Dia  //Armazena o Dia Anterior, para Calculo dos Indices            

//Verifica se todos os fatores do IQP estao cadastrados
lFatIQP := If(GetMV("MV_QFATIQP",.F.,.T.),QA_FatIQP(),.T.)       

If nOpc == 3 //Inclusao 
	if existblock ("QIE230BDIA") 
		lButt := ExecBlock("QIE230BDIA",.F.,.F.)
	EndIf
	if lButt 
		Aadd(aButtons,{"S4SB014N",{||Q230Dife(@oData,@lDate)},STR0014,STR0037}) //"Altera o dia do Fechamento..."###"Alt.Dia"
	EndiF
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New()

oSize:AddObject( "TELA"    ,  100, 20, .T., .F. ) // Nao dimensiona Y

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos         
                                     
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0012);  // "Gera‡„o do Indice Qualidade"
									FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
@ oSize:GetDimension("TELA","LININI"),010 	Say TitSX3("QEV_ANO")[1]    Size 033,007 Of oDlg Pixel
@ oSize:GetDimension("TELA","LININI")+15,010	Say TitSX3("QEV_MES")[1]    Size 053,007 Of oDlg Pixel
@ oSize:GetDimension("TELA","LININI")+30,010	Say TitSX3("QEV_FORNEC")[1] Size 035,007 Of oDlg Pixel
@ oSize:GetDimension("TELA","LININI")+45,010	Say OemToAnsi(STR0013)      Size 050,007 Of oDlg Pixel //"Dia Fechamento"

@ oSize:GetDimension("TELA","LININI")		,90	MsGet oAno Var c230Ano Picture PesqPict("QEV","QEV_ANO") F3 "QEV";
	Valid Q230VlAn(nOpc) Of oDlg Pixel Size 036,010 HASBUTTON
oAno:cSX1Hlp := "QEV_ANO"

@ oSize:GetDimension("TELA","LININI")+15	,90 MsGet oMes Var c230Mes Picture PesqPict("QEV","QEV_MES");
	Valid Val(c230Mes) >= 1 .And. Val(c230Mes) <= 12 Of oDlg Pixel Size 036,010
oMes:cSX1Hlp := "QEV_MES"

@ oSize:GetDimension("TELA","LININI")+30	,90 MsGet oFornece Var c230For Picture PesqPict("QEV","QEV_FORNEC") F3 "SA2QIE";
	Valid If(!Empty(c230For),ExistCpo("SA2",c230For,1),.T.);
		Of oDlg Pixel Size 036,010 HASBUTTON
oFornece:cSX1Hlp := "QEV_FORNEC"
	
@ oSize:GetDimension("TELA","LININI")+32,130 Say Posicione("SA2",1,xFilial('SA2')+c230For,"A2_NOME") Of oDlg Pixel Size 120,007

@ oSize:GetDimension("TELA","LININI")+45	,80 MsGet oInvisivel Var cInvisivel Of oDlg Pixel Size 0,0
   
@ oSize:GetDimension("TELA","LININI")+45	,90 MsGet oData Var c230Dia When lDate .And. Q230WhDi();
	Valid Val(c230Dia) >= 1 .And. Val(c230Dia) <= 31 .And. Q230Dife(@oData,@lDate);
		Of oDlg Pixel Size 036,010
oData:cSX1Hlp := "QEV_MES"

If (nOpc == 3)             
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons) VALID .T.
Else
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOk,bCancel,,) 
EndIf	  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a atualizacao dos dados referentes ao Resultados	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If nOpcA == 1 .And. lFatIQP

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se o Dia de Fechamento Mensal foi alterado, exclui todos os  ³
	//³ Indices Mensais,											 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cDiaAnt <> c230Dia
	
		If !lDispMsg //Se a mensagem ja foi exibida ao usuario                      
		
			//Exclui o Historico dos Indices
			MsgRun(STR0001,STR0002,{||Q230DIQF('QEV',QEV->(Recno()),nOpc,,.T.)}) //"Excluindo o Historico dos Indices Mensais..." ### "Aguarde..."
		
			//Grava o novo dia no MV_QDIAIQ
			WriteMv("MV_QDIAMIQ",c230Dia,"C",2)                                      
		EndIf
	Else
		//Exclui o Historico dos Indices gerados no Mes+Ano
		MsgRun(STR0003,STR0002,{||Q230DIQF('QEV',QEV->(Recno()),nOpc,,.T.,c230Ano,c230Mes,c230For)}) //"Excluindo os Indices no Mes/Ano..." ### "Aguarde..."
		
	EndIf

	If lQEA231                
		//Compatibiza as variaveis utilizadas no RDMAKE QIEA231.PRW 	
		Private cIE230For := c230For
		Private cIE230Dia := c230Dia
		Private cIE230Mes := c230Mes
		Private cIE230Ano := c230Ano
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa o calculo do IQF via RDMAKE							 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ProcQDO({||ExecBlock("QIEA231",.F.,.F.)},,,.T.,)
	Else		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa o calculo do IQF pela Rotina padrao					 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		Processa({||Q230AtuInd(c230For,c230Dia,c230Mes,c230Ano)},;
			STR0015,STR0016,.F.) //"Gerando o IQF..."###"Gravando Registros..."		
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se j  havia gerado para o mes/ano posterior 		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	// Se gerou indice para o mes/ano
	QEV->(dbSetOrder(1))
	If QEV->(MsSeek(xFilial("QEV")+c230Ano+c230Mes))
		cMesPos := StrZero(Val(c230Mes)+1,2)
		cAnoPos := c230Ano
		If cMesPos == "13"
			cMesPos := "01"
			cAnoPos := Str(Val(c230Ano)+1,4)
		EndIf
		If QEV->(MsSeek(xFilial("QEV")+cAnoPos+cMesPos))
			MsgInfo(OemToAnsi(STR0017)+cMesPos+"/"+cAnoPos,OemToAnsi(STR0018))   // "Dever  ser gerado novamente o Indice Qualidade do mˆs/ano "###"Aten‡„o"
		EndIf
	EndIf
EndIf
                
//Restaura o valor original do aRotina
aRotina[3,4] := nSavRot

RestArea(aAreaAnt)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Q230DiFe ³ Autor ³ Paulo Emidio de Barros³ Data ³ 24/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Habilita a digitacao do Dia do Fechamento      			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q230DiFe(oData,lDate)    								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPO1 = Objeto do campo Data								  ³±±
±±³			 ³ EXPL1 = Indica a Edicao do Campo Data					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q230DiFe(oData,lDate)
If !lDate
	lDate := .T.
	oData:Enable()
	oData:SetFocus(.T.)
Else
	lDate := .F.
	oData:Disable()
EndIf
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Q230VlAn ³ Autor ³ Paulo Emidio de Barros³ Data ³ 24/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se Existe Indices para Exclusao dos Indices       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q230VlAn()			    								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q230VlAn(nOpc)
Local aAreaAnt := GetArea()
Local cAnoDel  := Str(Val(c230Ano)-5,4) //Mantem 5 anos para Historico 
Local lDeleta  := .F.

//Verifica se existe Historico a ser excluido
QEV->(dbSetOrder(1))
If !QEV->(MsSeek(xFilial("QEV")+c230Ano))
	If QEV->(MsSeek(xFilial("QEV")+cAnoDel))
		If (lDeleta := MsgYesNo(OemToAnsi(STR0020)+cAnoDel+" ?",OemToAnsi(STR0019))) //"Poder„o ser exclu¡dos os Indices Qualidade de " ### "Exclus„o do Hist¢rico" 
			MsgRun(STR0001,STR0002,{||Q230DIQF('QEV',QEV->(Recno()),nOpc,,.T.,cAnoDel)}) //"Excluindo o Historico dos Indices Mensais..." ### "Aguarde..."
		EndIf
	EndIf
EndIf 
               
RestArea(aAreaAnt)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Q230WHDI ³ Autor ³ Paulo Emidio de Barros³ Data ³ 24/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Define a clausula WHEN para o Dia do Fechamento no Mes     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q230WhDI()			    								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. ou .F.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q230WhDi()
Local lRetorno := .T.
Local cSeek    := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe Indice Qualidade gerado para as filiais   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
If !Empty(c230For) 
	cSeek := (c230Ano+c230Mes+c230For)
Else                            
	cSeek := (c230Ano+c230Mes)
EndIf

QEV->(dbSetOrder(1))
If QEV->(MsSeek(xFilial("QEV")+cSeek,.T.))    
	//Exibe a Mensagem ao usuario somente uma vez
	If lDispMsg 
		MsgAlert(OemToAnsi(STR0021),OemToAnsi(STR0022)) //"J  foram gerados Indices de Qualidade. Se o dia de fechamento do mˆs for alterado, os ¡ndices ser„o cancelados."###"Aten‡„o"
		lDispMsg := .F.
	EndIf
EndIf

Return(lRetorno) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Q230AtuInd³ Autor ³ Paulo Emidio de Barros³ Data ³ 24/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza o Calculo do IQF									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q230AtuInd(cFornece,cDia,cMes,cAno)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Fornecedor										  ³±±
±±³			 ³ EXPC2 = Dia para Geracao dos Indices						  ³±±
±±³			 ³ EXPC3 = Mes para Geracao dos Indices						  ³±±
±±³          ³ EXPC4 = Ano para Geracao dos Indices						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q230AtuInd(cFornece,cDia,cMes,cAno)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                   Formulas para o Calculo dos Indices                   ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ IQP por Tabela Completa:                                                ³
//³   IA = ((Fator A*Qtd. A + Fator B*Qtd. B + ...)/(Qtd. A+Qtd. B)) * 100  ³
//³   Se IQI por Tabela:                                                    ³
//³     IQP = (100 - K) - Total Demerito   (K é obtido em funcao do IA)     ³
//³   Se IQI por Soma:                                                      ³
//³     IQP = IA                                                            ³
//³ IQP por Tabela Simplificada:                                            ³
//³   IQP = 101-((Qt.A+(Fat. B*100)*Qt.B+(Fat. C*100)*Qt.C)/(Qt.A+Qt.B+...))³
//³                                                                         ³
//³ IQI por Tabela:                                                         ³
//³   IQI = IQP * FC   (FC é obtido em funcao do IQS)                       ³
//³ IQI por Soma:                                                           ³
//³   IQI = 0.80 * IQP + 0.20 * IQS                                         ³
//³                                                                         ³
//³ IES (IPO):                                                              ³
//³   IPO = (1- (Somat.(Tam.Lote*Dias Atraso)/(MV_QDIAATR*Qtd.Total))) * 100³
//³                                                                         ³
//³ ICT = IPR = 0                                                           ³
//³                                                                         ³
//³ IQF:                                                                    ³
//³   IQF = Fat.IQI * IQI + Fat.IPR * IPR + Fat.IES * IES + Fat.ICT * ICT   ³
//³                                                                         ³
//³ Calculo do Acumulado:                                                   ³
//³ Flexivel:                                                               ³
//³   Pelo menos 1 Entrada nos n meses                       -> Calcula     ³
//³ Rigido:                                                                 ³
//³   Menos de n/2 meses com Entradas                        -> Nao Calcula ³
//³   De n/2 a n-1 meses c/ Entrada: menos de 6 Entradas     -> Nao Calcula ³
//³                              6 ou mais Entradas          -> Calcula     ³
//³   n meses com Entradas                                   -> Calcula     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAreaAnt    := GetArea()
Local lContinua   := .T.
Local nFatIQI     := 0
Local nFatIPR     := 0
Local nFatIES     := 0
Local aFatIQP     := {}
Local aFatInf     := {}
Local cFatApr     := ""
Local cFatRep     := ""
Local cFatLU      := ""
Local lQtdRej   
Local nDiaAtr     := 0
Local lQtdRep 
Local cLabor      := CriaVar("QEL_LABOR")
Local cQuery      := ''
Local lQuery      := .F.
Local cAliasQEK   := ''
Local cIndexQEK   := ''
Local nIndexQEK   := 0 
Local cAliasSA5   := ''
Local cAliasQEV   := ''
Local cCondicao   := '' 
Local cIndexSA5   := ''
Local nIndexSA5   := 0
Local cChave      := ''
Local cFornAtu    := ''
Local cProdAtu    := ''
Local cChvMed     := ''
Local aDados      := {}
Local nMesAcu     := 0
Local dInicio     := Ctod("")
Local dFinal      := Ctod("")
Local cLaudo      := ''
Local aAnoMes     := {}
Local cAnoIni     := ""
Local cAnoFim     := ""
Local cMesIni     := ""
Local cMesFim     := ""
Local nTotEnt	  := 0 
Local nEntDem	  := 0 
Local nQtdEnt	  := 0 
Local nNidi	      := 0 
Local nTotDem	  := 0 
Local nQtdRej	  := 0 
Local cQtdRej     := '' 
Local nLotIns	  := 0 
Local nLotSkp	  := 0 
Local nQtdIns	  := 0 
Local nQtdSkp	  := 0 
Local nSoma       := 0
Local nAux        := 0
Local nIA         := 0
Local nIQP 	      := 0
Local nIQS        := 0
Local nFC 		  := 0
Local nIQI 		  := 0
Local nIPR 		  := 0
Local nIPO 		  := 0
Local nITR 		  := 0
Local nIES 		  := 0
Local nIQF 		  := 0
Local nRecnoQEV   := 0
Local aFatAcum    := {}
Local aLotEnt     := {}
Local aLotDem     := {}
Local aIQD  	  := {}
Local aIPO 		  := {}
Local nCtMes 	  := 0
Local lAcumula    := .T.
Local nIQPa  	  := 0
Local nIQIa   	  := 0
Local nIPOa   	  := 0
Local nIQFa 	  := 0
Local nI          := 0
Local nK  	      := 0
Local nX          := 0
Local nY 		  := 0
Local nZ		  := 0
Local lMensal     := .F. //Indica se existe dados para Geracao dos Indices Mensais
Local lAcumulado  := .F. //Indica se existe dados para Geracao dos Indices Acumulados
Local cSeek       := '' 
Local cChvQER     := ""
Local cSeekQER    := ""
Local nSetQER     := 0
Local lQReinsp	  := GetNewPar("MV_QREINSP",.F.)
Local cQEntQEK    := GetMv("MV_QENTQEK")
Local cAliasQEK2  := ""		
//Indica se as Entradas Certificadas em Regime de Skip-Lote serao utilizadas no Calculo dos Indices
Local lNaoCer     :=  GetMV("MV_QNAOCER",.T.,.F.)
Local aRetorno    := {}
Local aStruQEK    := {}
Local aStruQEV    := {}
Local aStruSA5    := {}
Local cAliasQER   := ''
Local nPosCpo     := 0   
Local lPrForFab	  := GETNEWPAR('MV_PRFOFAB',.F.)
Local cChaveLoop  := ""

                        
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se as tabelas do IA e do IQS estao cadastradas      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
QEJ->(dbSetOrder(1))
If QEJ->(!MsSeek(xFilial("QEJ")+"1"))
	MsgAlert(STR0023,STR0024) //"Favor cadastrar a Tabela do Indice Aceitacao (IA)"###"Atencao"
	Return(.F.)
EndIf           

If QEJ->(!MsSeek(xFilial("QEJ")+"2"))
	MsgAlert(STR0025,STR0026) //"Favor cadastrar a Tabela do Indice Qualidade Sistema (IQS)"###"Atencao"
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se cadastrou os Indices do IQF                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
QF1->(dbSetOrder(1))
If QF1->(!MsSeek(xFilial("QF1")))
	MsgAlert(STR0027,STR0028) //"Favor cadastrar os Indices do IQF"###"Atencao"
	Return(.F.)
EndIf
                            
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem o fator do IQI										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
If !(lContinua := Q230IdeIQF("IQI",.T.,@nFatIQI))
	Return(.F.)
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem o fator do IPR										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
If !(lContinua := Q230IdeIQF("IPR",.F.,@nFatIPR))
	Return(.F.)
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem o fator do IES									     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
If !(lContinua := Q230IdeIQF("IES",.T.,@nFatIES))
	Return(.F.)
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos Fatores do IQP (padrao)						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
aFatIQP := Q230DefIQP(@cFatApr,@cFatRep,@cFatLU)

If Len(aFatIQP) == 0
	//Incluir Help
	Return(NIL)
Else
	aFatIQP := aSort(aFatIQP,,,{|x,y|x[3]+x[1]<y[3]+y[1]}) //Ordena por Categoria+Laudo
EndIf	
                          
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o periodo a ser considerado para a geracao IQF mensal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
cMes     := StrZero(Val(cMes),2)                                  
aRetorno := Q230RetData(cDia,cMes,cAno)                              
dInicio  := aRetorno[1]
dFinal   := aRetorno[2]                                  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o periodo a ser considerado para a geracao IQF Acumu- ³
//³ lado,retorna n meses a partir do Mes/Ano selecionado.		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  

//Obtem o numero de meses para o calculo do acumulado
nMesAcu := GetMv("MV_QMESACU")
aAnoMes := {}
cAnoIni := cAno
cAnoFim := cAno
cMesIni := cMes
cMesFim := cMes

For nI := 1 to nMesAcu
	Aadd(aAnoMes,{cAnoIni,cMesIni})
	cMesIni := StrZero(Val(cMesIni)-1,2)
	If cMesIni == '00'
		cAnoIni := StrZero(Val(cAnoIni)-1,4)
		cMesIni := '12'
	EndIf
Next nI

aAnoMes := aSort(aAnoMes,,,{|x,y|x[1]+x[2]<y[1]+y[2]}) //Ano+Mes
cMesIni := aAnoMes[1,2]
cAnoIni := aAnoMes[1,1]
cMesFim := aAnoMes[Len(aAnoMes),2]
cAnoFim := aAnoMes[Len(aAnoMes),1]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indica se acumula a qtde. rejeitada no Laudo Reprovado		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
lQtdRej := If(GetMv("MV_QQTDREJ")=="S",.T.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indica o numero maximo de dias em atraso					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
nDiaAtr := GetMv("MV_QDIAIPO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indica se a quantidade rejeitada que foi transferida sera con³
//³ siderada para demerito no Calculo do Indice dos Fornecedores ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
lQtdRep  := If(GetMv("MV_QTRFREP")=="S",.T.,.F.)
       
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra as Entradas no Periodo para a Geracao dos Indices	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
dbSelectArea('QEK')     
dbSetorder(1) //Antes era 8, testar

 //Filtra as Entradas no Periodo
 cAliasQEK := "QRYQEK"           
 aStruQEK  := QEK->(dbStruct())
 lQuery    := .T.                            
 cQuery    := "SELECT "
 cQuery    += "QEK.QEK_FILIAL QEK_FILIAL, "
 cQuery    += "QEK.QEK_FORNEC QEK_FORNEC, "
 cQuery    += "QEK.QEK_LOJFOR QEK_LOJFOR, "
 cQuery    += "QEK.QEK_PRODUT QEK_PRODUT, "
 cQuery    += "QEK.QEK_REVI   QEK_REVI  , "
 cQuery    += "QEK.QEK_LOTE   QEK_LOTE  , "
 cQuery    += "QEK.QEK_TAMLOT QEK_TAMLOT, "
 cQuery    += "QEK.QEK_TIPONF QEK_TIPONF, "
 cQuery    += "QEK.QEK_TIPDOC QEK_TIPDOC, "
 cQuery    += "QEK.QEK_DTENTR QEK_DTENTR, "
 cQuery    += "QEK.QEK_VERIFI QEK_VERIFI, "
 cQuery    += "QEK.QEK_DIASAT QEK_DIASAT, "
 cQuery    += "QEK.QEK_SITENT QEK_SITENT, "
 cQuery    += "QEK.QEK_NTFISC QEK_NTFISC, "
 cQuery    += "QEK.QEK_SERINF QEK_SERINF, "
 cQuery    += "QEK.QEK_ITEMNF QEK_ITEMNF, "
 cQuery    += "QEK.QEK_TIPONF QEK_TIPONF, "
 cQuery    += "QEK.QEK_ENTINV QEK_ENTINV, "
 cQuery    += "QEK.QEK_LOTINV QEK_LOTINV, "

 cQuery    += "QEL.QEL_FILIAL QEL_FILIAL, "
 cQuery    += "QEL.QEL_FORNEC QEL_FORNEC, "
 cQuery    += "QEL.QEL_LOJFOR QEL_LOJFOR, "
 cQuery    += "QEL.QEL_PRODUT QEL_PRODUT, "
 cQuery    += "QEL.QEL_LOTE   QEL_LOTE  , "
 cQuery    += "QEL.QEL_DTENTR QEL_DTENTR, "
 cQuery    += "QEL.QEL_LABOR  QEL_LABOR , "
 cQuery    += "QEL.QEL_LAUDO  QEL_LAUDO , "
 cQuery    += "QEL.QEL_DTLAUD QEL_DTLAUD, "
 cQuery    += "QEL.QEL_QTREJ  QEL_QTREJ , "
 cQuery    += "QEL.QEL_NTFISC  QEL_NTFISC , "
 cQuery    += "QEL.QEL_SERINF  QEL_SERINF , "
 cQuery    += "QEL.QEL_ITEMNF  QEL_ITEMNFJ , "
 cQuery    += "QEL.QEL_TIPONF  QEL_TIPONF , "
 
 
 cQuery    += "SA5.A5_FILIAL  A5_FILIAL , "
 cQuery    += "SA5.A5_FORNECE A5_FORNECE, "
 cQuery    += "SA5.A5_LOJA    A5_LOJA   , "
 cQuery    += "SA5.A5_PRODUTO A5_PRODUTO, "
 cQuery    += "SA5.A5_FABREV  A5_FABREV "
 
 cQuery    += "FROM "+RetSqlName("QEK")+" QEK, "
 cQuery    += RetSqlName("QEL")+" QEL, "
 cQuery    += RetSqlName("SA5")+" SA5 "
 cQuery    += "WHERE QEK.QEK_FILIAL = '"+xFilial("QEK")+"' AND "
 cQuery    += "QEK.QEK_TIPONF <> 'B' AND "                      
 cQuery    += "QEK.QEK_TIPONF <> 'D' AND "
 cQuery    += If(!Empty(cFornece),"QEK.QEK_FORNEC = '"+cFornece+"' AND "," ")
 cQuery    += "QEK.QEK_SITENT <> '1' AND "
 cQuery    += "QEK.QEK_SITENT <> '7' AND " //somente 7.10  
 //Nao considera as Entradas Certificadas em Skip-Lote
 If lNaoCer  
	 cQuery   += "QEK.QEK_VERIFI <> 2 AND "
 EndIf	 	 
 cQuery    += "QEK.D_E_L_E_T_<> '*' AND " 
 cQuery    += "QEL.QEL_FILIAL = '"+xFilial("QEL")+"' AND "
 cQuery    += "QEL.QEL_FORNEC = QEK.QEK_FORNEC AND "
 cQuery    += "QEL.QEL_LOJFOR = QEK.QEK_LOJFOR AND "
 cQuery    += "QEL.QEL_PRODUT = QEK.QEK_PRODUT AND "
 cQuery    += "QEL.QEL_DTENTR = QEK.QEK_DTENTR AND "
 cQuery    += "QEL.QEL_LOTE = QEK.QEK_LOTE AND " 
 cQuery    += "QEL.QEL_LABOR = '"+cLabor+"'AND "
 cQuery    += "QEL.QEL_DTLAUD >= '"+Dtos(dInicio)+"' AND " 
 cQuery    += "QEL.QEL_DTLAUD <= '"+Dtos(dFinal)+"' AND "
 cQuery    += "QEL.QEL_LAUDO <> ' ' AND "
 cQuery	   += "QEL.QEL_NISERI = (QEK.QEK_NTFISC||QEK.QEK_SERINF||QEK.QEK_ITEMNF) AND "
 If lQReinsp
 	 cQuery	   += "QEL.QEL_NUMSEQ = QEK.QEK_NUMSEQ AND "
 Endif
 cQuery    += "QEL.D_E_L_E_T_ <> '*' AND "    
 cQuery    += "SA5.A5_FILIAL = '"+xFilial("SA5")+"' AND " 
 cQuery    += "SA5.A5_FORNECE = QEK.QEK_FORNEC AND "
 cQuery    += "SA5.A5_LOJA = QEK.QEK_LOJFOR AND "
 cQuery    += "SA5.A5_PRODUTO = QEK.QEK_PRODUT AND "
 cQuery    += "SA5.A5_FABREV <> 'P' AND "
 if !lPrForFab
	 cQuery    += "SA5.A5_FABR = '  ' AND "
 EndiF
 cQuery    += "SA5.D_E_L_E_T_ <> '*' "
 cQuery    += "ORDER BY "+SqlOrder(QEK->(IndexKey())) + ",SA5.A5_FABR,SA5.A5_FALOJA"
 
 cQuery    := ChangeQuery(cQuery)

 dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQEK,.T.,.T.)
 
 TcSetField((cAliasQEK),"QEK_DTENTR","D")
 TcSetField((cAliasQEK),"QEK_DIASAT","N",TamSX3("QEK_DIASAT")[1],TamSX3("QEK_DIASAT")[2])  
 TcSetField((cAliasQEK),"QEK_VERIFI","N",TamSX3("QEK_VERIFI")[1],TamSX3("QEK_VERIFI")[2])
 TcSetField((cAliasQEK),"QEL_DTENTR","D")
 TcSetField((cAliasQEK),"QEL_DTLAUD","D")  


dbSelectArea(cAliasQEK)    
dbGoTop()      
ProcRegua(LastRec())

While (cAliasQEK)->(!Eof())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Produto x Fornecedor se refere a Permuta		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	cFornAtu := (cAliasQEK)->QEK_FORNEC
	cProdAtu := (cAliasQEK)->QEK_PRODUT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculos dos Indices Mensais Informados                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	aFatInf := {}      
	If !(lContinua := Q230DefIME(cFornAtu,cProdAtu,cAno,cMes,@aFatInf))
		(cAliasQEK)->(dbSkip())
		IncProc()
		Loop
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Indices Mensais Calculados                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	nTotEnt	:= 0 //Numero Total de Entradas
	nEntDem	:= 0 //Quantidade de Entradas Demeritadas
	nQtdEnt	:= 0 //Quantidade Total Entregue (Tamanho do Lote)
	nNidi	:= 0 //Quantidade Entregue*Dias em Atraso
	nTotDem	:= 0 //Total de Demeritos das Entradas
	nQtdRej	:= 0 //Total de quantidae Rejeitada do Fornecedor/Item
	nLotIns	:= 0 //Total de Lotes Inspecionados
	nLotSkp	:= 0 //Total de Lotes em Skip-Lote
	nQtdIns	:= 0 //Quantidade Total Inspecionada (Tamanho do Lote) 
	nQtdSkp	:= 0 //Quantidade Total em Skip-Lote (Tamanho do Lote) 
	
	Aeval(aFatIQP,{|x|x[4]:=0}) //Zera a ocorrencia de cada Fator

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculo do total de entradas								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cQEntQEK == "1"
		nTotEnt := QE230TEn(cFornAtu,cProdAtu,dInicio,dFinal,lQtdRep)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona as Entradas do Fornecedor/Produto					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	While (cAliasQEK)->(!Eof()) .And. (cAliasQEK)->QEK_FILIAL+(cAliasQEK)->QEK_FORNEC+(cAliasQEK)->QEK_PRODUT == (xFilial("QEK")+cFornAtu+cProdAtu)

		If lPrForFab
			If cChaveLoop <> (cAliasQEK)->(QEK_FILIAL+QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT)
				cChaveLoop := (cAliasQEK)->(QEK_FILIAL+QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT)
			ElseIf cChaveLoop == (cAliasQEK)->(QEK_FILIAL+QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT)
				(cAliasQEK)->(dbSkip())
				Loop
			EndIf
		EndIf

    	cLaudo := '' //Laudo da Entrada Inspecionada
    	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona o Laudo da Entrada Inspecionada					 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ            
		cLaudo  := (cAliasQEK)->QEL_LAUDO
		cQtdRej := (cAliasQEK)->QEL_QTREJ
		If !(lQtdRep .And. AllTrim((cAliasQEK)->QEK_TIPDOC) == "TR")
			nQtdRej += SuperVal((cAliasQEK)->QEL_QTREJ) //Acumulado da Quantidade Rejeitada
		Endif

		
		lMensal := If(!lMensal,.T.,lMensal) //Flag para Geracao dos Indices Mensais
		If !(lQtdRep .And. AllTrim((cAliasQEK)->QEK_TIPDOC) == "TR") .And. cQentQEk =="2"
			//Contabiliza o numero de Entradas no Periodo
			nTotEnt ++
		EndIf
     
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Identifica o Laudo da Entrada. Se o Laudo da Entrada houver  ³
		//³ categoria Liberado Urgente, considera como Aprovado			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		nI := Ascan(aFatIQP,{|x|x[1]==If(cLaudo==cFatLU,cFatApr,cLaudo)})

		//Identifica o Laudo Reprovado
		nY := Ascan(aFatIQP,{|x|x[1]==cFatRep})

		//Identifica o Laudo Aprovado
		nZ := Ascan(aFatIQP,{|x|x[1]==cFatApr})

		//IQP por Tabela Completa
		If lQtdRej // Cons. qtde. rejeitada
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acumula a Quantidade Rejeitada no Laudo Reprovado			 ³
			//³ Acumula a diferenca do Tamanho do Lote e a quantidade rejei- ³
			//³ tada no Laudo Entrada.									     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
			If !Empty(cQtdRej)      
			
				//Subtrai as transferencias da quantidade aprovada					
				If (lQtdRep .And. AllTrim((cAliasQEK)->QEK_TIPDOC) == "TR") .And. nZ > 0
					aFatIQP[nZ,4] := aFatIQP[nZ,4]-SuperVal((cAliasQEK)->QEK_TAMLOT)
				EndIf
				
				//Calculo Normal                                                                          
				If nI > 0
					aFatIQP[nI,4] += (SuperVal((cAliasQEK)->QEK_TAMLOT)-SuperVal(cQtdRej))
				EndIf
				If nY > 0					
					aFatIQP[nY,4] += SuperVal(cQtdRej)
				EndIf					
			Else                                 
			
				//Nao considera as transferencias
				If !(lQtdRep .And. AllTrim((cAliasQEK)->QEK_TIPDOC) == "TR") .And. nI > 0
    				aFatIQP[nI,4] += SuperVal((cAliasQEK)->QEK_TAMLOT)
    			EndIf	
			EndIf
		Else
		        
			//Nao considera as transferencias
			If !(lQtdRep .And. AllTrim((cAliasQEK)->QEK_TIPDOC) == "TR") .And. nI > 0
				aFatIQP[nI,4] += SuperVal((cAliasQEK)->QEK_TAMLOT)
			EndIf	                         
		EndIf

		// Acumula Ocorrencias e Qtde. Lote - Inspec. e em Skip-Lote
		If (cAliasQEK)->QEK_VERIFI == 2	// Certificada
			//Nao considera as transferencias
			If !(lQtdRep .And. AllTrim((cAliasQEK)->QEK_TIPDOC) == "TR")
				nLotSkp ++
				nQtdSkp += SuperVal((cAliasQEK)->QEK_TAMLOT)
			EndIf	

		Else
			//Nao considera as transferencias
			If !(lQtdRep .And. AllTrim((cAliasQEK)->QEK_TIPDOC) == "TR")
				nLotIns ++  //Considera as Entradas Inspecionadas
				nQtdIns += SuperVal((cAliasQEK)->QEK_TAMLOT) 
			EndIf				

		EndIf

		//Verifica se a Entrada e demeritada                                  
		If nI > 0
			If aFatIQP[nI,3] # "1" .AND. !(lQtdRep .And. AllTrim((cAliasQEK)->QEK_TIPDOC) == "TR")
				nEntDem ++
			EndIf
		EndIf

		//Nao considera as transferencias
		If !(lQtdRep .And. AllTrim((cAliasQEK)->QEK_TIPDOC) == "TR")
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acumula valores para o calculo do IPO. 						 ³
			//³ Utiliza o Modulo do Dias em Atraso porque o mesmo pode ser   ³
			//³ negativo.    												 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
			nQtdEnt += SuperVal((cAliasQEK)->QEK_TAMLOT)                                   
			If (cAliasQEK)->QEK_DIASAT # 0
				nNiDi += (SuperVal((cAliasQEK)->QEK_TAMLOT)*;
					If(Abs((cAliasQEK)->QEK_DIASAT)>nDiaAtr,nDiaAtr,Abs((cAliasQEK)->QEK_DIASAT)))
			EndIf
		EndIf
		
        
		 
		//Filtra as Entradas no Periodo
		cAliasQER := "QRYQER"           
		cQuery    := "SELECT SUM(QEE.QEE_PONTOS) QEE_PONTOS "
		cQuery 	+= "FROM "+RetSqlName("QER")+" QER, "
		cQuery 	+= RetSqlName("QEU")+" QEU, "                   
		cQuery 	+= RetSqlName("QEE")+" QEE "
		cQuery 	+= "WHERE "
		cQuery 	+= "QER.QER_FILIAL = '"+xFilial("QER")+"' AND " 
		cQuery 	+= "QER.QER_PRODUT = '"+(cAliasQEK)->QEK_PRODUT+"' AND " 
		cQuery 	+= "QER.QER_REVI = '"+(cAliasQEK)->QEK_REVI+"' AND " 
		cQuery 	+= "QER.QER_FORNEC = '"+(cAliasQEK)->QEK_FORNEC+"' AND " 
		cQuery 	+= "QER.QER_LOJFOR = '"+(cAliasQEK)->QEK_LOJFOR+"' AND " 
		cQuery 	+= "QER.QER_DTENTR = '"+Dtos((cAliasQEK)->QEK_DTENTR)+"' AND " 
		cQuery 	+= "QER.QER_LOTE = '"+(cAliasQEK)->QEK_LOTE+"' AND " 			            
		cQuery 	+= "QER.QER_NTFISC = '"+(cAliasQEK)->QEK_NTFISC+"' AND " 			
		cQuery 	+= "QER.QER_SERINF = '"+(cAliasQEK)->QEK_SERINF+"' AND " 			
		cQuery 	+= "QER.QER_ITEMNF = '"+(cAliasQEK)->QEK_ITEMNF+"' AND " 			
		cQuery 	+= "QER.QER_TIPONF = '"+(cAliasQEK)->QEK_TIPONF+"' AND " 			            
		cQuery 	+= "QER.D_E_L_E_T_ <> '*' AND "
		cQuery    += "QEU.QEU_FILIAL = '"+xFilial("QEU")+"' AND " 
		cQuery    += "QEU.QEU_CODMED = QER.QER_CHAVE AND " 
		cQuery    += "QEU.QEU_DEMIQI = 'S' AND "
		cQuery    += "QEU.D_E_L_E_T_ <> '*' AND "              
		cQuery    += "QEE.QEE_FILIAL = '"+xFilial("QEE")+"' AND " 
		cQuery    += "QEE.QEE_CLASSE = QEU.QEU_CLASSE AND "
		cQuery    += "QEE.D_E_L_E_T_ <> '*' "                     
		cQuery    := ChangeQuery(cQuery)
		
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQER,.T.,.T.)
		
		TcSetField(cAliasQER,"QEE_PONTOS","N",TamSX3("QEE_PONTOS")[1],TamSX3("QEE_PONTOS")[2])    
		    
		nTotDem += QEE_PONTOS
		DbCloseArea()
		DbSelectArea("QER") 
		
		(cAliasQEK)->(dbSkip())
		IncProc()
		
	EndDo
                                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculo do IQI Mensal                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  

	// Calculo do IQP pela Tabela Completa
	nSoma := 0
	nAux  := 0

	For nX := 1 To Len(aFatIQP)
		nAux  += (aFatIQP[nX,2] * aFatIQP[nX,4]) //Fator * Ocorr. Laudo
		nSoma += aFatIQP[nX,4]
	Next nX

	nIA := If(nSoma#0,(nAux/nSoma)*100,0)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculo do IQI por Tabela									 ³
	//³ Obtem o Fator K, de acordo com o IA 						 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	QEJ->(dbSetOrder(1))
	QEJ->(MsSeek(xFilial("QEJ")+"1"+Str(nIA,6,2),.T.))
	
	nK   := SuperVal(QEJ->QEJ_FATOR)
	nIQP := (100-nK)-nTotDem
	nIQP := If(nIQP<0,0,nIQP)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculo do IQS                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	SA2->(dbSetOrder(1))
	SA2->(MsSeek(xFilial("SA2")+cFornAtu))
	If SA2->A2_FATAVA==0 .And. Empty(SA2->A2_DTAVA)
		nIQS := 999.99
	Else
		nIQS := SA2->A2_FATAVA
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculo do IQI por Tabela									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	QEJ->(dbSetOrder(1))
	If nIQS <> 999.99
		//Obtem o Fator FC, de acordo com o IQS
		QEJ->(MsSeek(xFilial("QEJ")+"2"+Str(nIQS,6,2),.T.))
		nFC := SuperVal(QEJ->QEJ_FATOR)

	Else
		//Obtem o Fator FC para quando nao tiver a nota do IQS (999.99)
		If QEJ->(MsSeek(xFilial("QEJ")+"2"+Str(nIQS,6,2)))
			nFC := SuperVal(QEJ->QEJ_FATOR)
		Else
			//IQP por tabela Completa, assume 1
			nFC := 1
		EndIf
		
	EndIf
	nIQI := (nIQP*nFC)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculo do IPR Mensal                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	nIPR := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculo do IES Mensal 										 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  

	//Calcula o IPO
	nIPO := If(nQtdEnt # 0,(1-(nNiDi/(nDiaAtr*nQtdEnt)))*100,0)
	nITR := 0
	nIES := nIPO

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculo do IQF Mensal 										 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

	nIQF := (nFatIQI*nIQI) + (nFatIPR*nIPR) + (nFatIES*nIES)

	For nI := 1 to Len(aFatInf)
		nIQF := nIQF + aFatInf[nI]
	Next nI

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravacao dos indices mensais calculados                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	QEW->(dbSetOrder(1))
	For nX := 1 to Len(aFatIQP)
		If aFatIQP[nX,4] <> 0
			If QEW->(!MsSeek(xFilial("QEW")+cFornAtu+cProdAtu+cAno+cMes+aFatIQP[nX,1]))
				RecLock("QEW",.T.)
				QEW->QEW_FILIAL := xFilial("QEW")
				QEW->QEW_ANO    := cAno
				QEW->QEW_MES    := cMes
				QEW->QEW_FORNEC := cFornAtu
				QEW->QEW_PRODUT := cProdAtu
				QEW->QEW_LAUDO  := aFatIQP[nX,1]
			Else
				RecLock("QEW",.F.)
			EndIf
			QEW->QEW_QTDLAU	:= Round(aFatIQP[nX,4],QEA230Dec("QEW_QTDLAU", 0))
			MsUnLock()
		EndIf
	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza os Indices Mensais (QEV)							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	aDados := {nTotEnt, nEntDem, nLotIns, nLotSkp, nQtdIns, nQtdSkp, nQtdRej, nIQP,;
		nTotDem, nIQS, nIQI, nIPO, nITR, nIES, nIPR, nIQF, 999.99, 999.99, 999.99, ;
		999.99, 999.99, dDataBase}

	Q230GrvInd(cAno,cMes,cFornAtu,cProdAtu,aDados)

	nRecnoQEV := QEV->(Recno())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ calculo do IQF Acumulado									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  

	// Vetor que guarda a qtde nos n meses de cada Fator Laudo
	aFatAcum := Array(Len(aFatIQP),nMesAcu+1)
	For nI := 1 to len(aFatIQP)
		aFatAcum[nI,1] := aFatIQP[nI,1]
		For nX := 1 to nMesAcu
			aFatAcum[nI,nX+1] := 0
		Next nX
	Next nI

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Acumula a soma dos respectivos (n) meses					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	aLotEnt := Afill(Array(nMesAcu),0) //Lotes Entregues
	aLotDem := Afill(Array(nMesAcu),0) //Lotes Demeritados
	aIQD    := Afill(Array(nMesAcu),0)	//IQDs
	aIPO    := Afill(Array(nMesAcu),0) 	//IPOs

	// Seleciona os indices dos meses a serem cons. p/ o acumulado
	dbSelectArea("QEV")
	dbSetOrder(2)
	
       
	 cAliasQEV := "QRYQEV"           
	 aStruQEV  := QEV->(dbStruct())
		
 	 //Verifica se o Produto x Fornecedor possui Entradas no Mes/Ano
	 cQuery := "SELECT " 
	 cQuery += "QEV.QEV_FILIAL QEV_FILIAL, "
	 cQuery += "QEV.QEV_FORNEC QEV_FORNEC, "
	 cQuery += "QEV.QEV_PRODUT QEV_PRODUT, "
	 cQuery += "QEV.QEV_ANO    QEV_ANO   , "
	 cQuery += "QEV.QEV_MES    QEV_MES   , "
	 cQuery += "QEV.QEV_LOTENT QEV_LOTENT, "
	 cQuery += "QEV.QEV_LOTDEM QEV_LOTDEM, "
	 cQuery += "QEV.QEV_IQD    QEV_IQD   , "
	 cQuery += "QEV.QEV_IPO    QEV_IPO "  
	 
	 cQuery += "FROM "+RetSqlName("QEV")+" QEV "                 
     cQuery += "WHERE QEV.QEV_FILIAL = '"+xFilial("QEV")+"' AND "                    
	 cQuery += "QEV.QEV_FORNEC = '"+cFornAtu+"' AND "
	 cQuery += "QEV.QEV_PRODUT = '"+cProdAtu+"' AND "
	 cQuery += "QEV.QEV_LOTENT <> 0 AND "
 	 If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX,DB2/400"
	 	 cQuery += "(QEV_ANO || QEV_MES) >= '"+(cAnoIni+cMesIni)+"' AND "
		 cQuery += "(QEV_ANO || QEV_MES) <= '"+(cAnoFim+cMesFim)+"' AND "
	 Else
		 cQuery += "(QEV_ANO+QEV_MES) >= '"+(cAnoIni+cMesIni)+"' AND "
		 cQuery += "(QEV_ANO+QEV_MES) <= '"+(cAnoFim+cMesFim)+"' AND "
	 EndIf
	 cQuery += "QEV.D_E_L_E_T_ <> '*' "                     
	 cQuery += "ORDER BY "+SqlOrder(QEV->(IndexKey(2)))
	 
	 cQuery := ChangeQuery(cQuery)
	 DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQEV,.T.,.T.)

	 TcSetField(cAliasQEV,"QEV_LOTENT","N",TamSX3("QEV_LOTENT")[1],TamSX3("QEV_LOTENT")[2]) 
	 TcSetField(cAliasQEV,"QEV_LOTDEM","N",TamSX3("QEV_LOTDEM")[1],TamSX3("QEV_LOTDEM")[2]) 
	 TcSetField(cAliasQEV,"QEV_IQD"	  ,"N",TamSX3("QEV_IQD")[1]   ,TamSX3("QEV_IQD")[2]   ) 
	 TcSetField(cAliasQEV,"QEV_IPO"	  ,"N",TamSX3("QEV_IPO")[1]   ,TamSX3("QEV_IPO")[2]   ) 
	     
	 cCondicao := ' .T.'		     
	 dbSelectArea(cAliasQEV)
	 dbGoTop()

	While !Eof() .And. &cCondicao

		nI := Ascan(aAnoMes,{|x|x[1]+x[2]==(cAliasQEV)->QEV_ANO+(cAliasQEV)->QEV_MES})

		//Acumula as quantidades por Laudo
		For nX := 1 to Len(aFatAcum)
			QEW->(dbSetOrder(1))
			If QEW->(MsSeek(xFilial("QEW")+(cAliasQEV)->QEV_FORNEC+(cAliasQEV)->QEV_PRODUT+(cAliasQEV)->QEV_ANO+(cAliasQEV)->QEV_MES+aFatAcum[nX,1]))
				aFatAcum[nX,nI+1] += QEW->QEW_QTDLAU
			EndIf
		Next nX

		//Acumula Lotes entregues, demeritados, IQDs e IPOs
		aLotEnt[nI] += (cAliasQEV)->QEV_LOTENT
		aLotDem[nI] += (cAliasQEV)->QEV_LOTDEM
		aIQD[nI] 	+= If((cAliasQEV)->QEV_IQD<>999.99,(cAliasQEV)->QEV_IQD,0)
		aIPO[nI] 	+= If((cAliasQEV)->QEV_IPO<>999.99,(cAliasQEV)->QEV_IPO,0)
		dbSkip()
		
	EndDo
           
          
	DbSelectArea(cAliasQEV)
	DbCloseArea()
	DbSelectArea("QEV")   

	//Verifica a possibilidade de geracao do acumulado
	nCtMes  := 0
	nTotEnt := 0
	For nX := 1 to nMesAcu
		If aLotEnt[nX] # 0
			nCtMes ++
			nTotEnt += aLotEnt[nX]
		EndIf
	Next nX

	//Criterio Flexivel
	lAcumula := If(nTotEnt>0,.T.,.F.)

	//Realiza o calculo do Acumulado
	nIQPa   := 999.99
	nIQIa   := 999.99
	nIPOa   := 999.99
	nIQFa   := 999.99
	nTotDem := 999.99
	
	If lAcumula   
		Q230CalAcu(cFornAtu, cProdAtu, nMesAcu, aAnoMes, aLotEnt, aFatIQP, aFatAcum, aIQD,;
			aIPO, nFatIQI, nFatIPR, nFatIES, @nIQPa, @nIQIa, @nIPOa, @nIQFa, @nTotDem)		
	
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza os Indices acumulados que foram gerados.			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	dbSelectArea("QEV")	 
	dbSetorder(1)
	dbGoto(nRecnoQEV)
	
	RecLock("QEV",.F.)
	QEV->QEV_IQPA := nIQPa
	QEV->QEV_IQDA := nTotDem	
	QEV->QEV_IQIA := nIQIa
	QEV->QEV_IPOA := nIPOa
	QEV->QEV_IQFA := nIQFa
	MsUnLock()
	dbSelectArea(cAliasQEK)    

EndDo         

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula o IQF Acumulado para Produtos x Fornecedorews que nao³
//³ possuem Entradas no Mes/Ano Selecionado.					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
If lContinua

	//Filtra as Amarracoes Produto x Fornecedores

	 DbSelectArea('SA5')     
	 DbSetorder(1) 
	 cAliasSA5 := "QRYSA5"           
	 aStruSA5  := SA5->(DbStruct())
	 cQuery    := "SELECT "
 	 cQuery    += "SA5.A5_FILIAL  A5_FILIAL , "
 	 cQuery    += "SA5.A5_FORNECE A5_FORNECE, "
 	 cQuery    += "SA5.A5_LOJA    A5_LOJA   , "
 	 cQuery    += "SA5.A5_PRODUTO A5_PRODUTO, "
 	 cQuery    += "SA5.A5_FABREV  A5_FABREV , "
 	 
	 cQuery    += "QEV.QEV_FILIAL QEV_FILIAL, "
	 cQuery    += "QEV.QEV_FORNEC QEV_FORNEC, "
	 cQuery    += "QEV.QEV_PRODUT QEV_PRODUT, "
	 cQuery    += "QEV.QEV_ANO    QEV_ANO   , "
	 cQuery    += "QEV.QEV_MES    QEV_MES   , "
	 cQuery    += "QEV.QEV_LOTENT QEV_LOTENT, "
	 cQuery    += "QEV.QEV_LOTDEM QEV_LOTDEM, "
	 cQuery    += "QEV.QEV_IQD    QEV_IQD   , "
	 cQuery    += "QEV.QEV_IPO    QEV_IPO " 
	  
	 cQuery    += "FROM "+RetSqlName("SA5")+" SA5, "                 
	 cQuery    += RetSqlName("QEV")+" QEV "                 
     cQuery    += "WHERE SA5.A5_FILIAL = '"+xFilial("SA5")+"' AND "                    
     cQuery    += If(!Empty(cFornece),"SA5.A5_FORNECE = '"+cFornece+"' AND "," ")
     cQuery    += "SA5.A5_FABREV <> 'P' AND "
	 cQuery    += "SA5.D_E_L_E_T_ <> '*' AND "                                        
	 cQuery    += "QEV.QEV_FILIAL = '"+xFilial("QEV")+"' AND "
	 cQuery    += "QEV.QEV_FORNEC = SA5.A5_FORNECE AND "
	 cQuery    += "QEV.QEV_PRODUT = SA5.A5_PRODUTO AND "
	 cQuery    += "QEV.QEV_ANO = '"+cAno+"' AND "
	 cQuery    += "QEV.QEV_MES = '"+cMes+"' AND "
	 cQuery    += "QEV.QEV_LOTENT = 0 AND "
 	 cQuery    += "QEV.D_E_L_E_T_ <> '*' " 

	 cQuery    += "ORDER BY "+SqlOrder(SA5->(IndexKey()))

	 dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSA5,.T.,.T.)

 	 TcSetField(cAliasSA5,"QEV_LOTENT","N",TamSX3("QEV_LOTENT")[1],TamSX3("QEV_LOTENT")[2]) 
 	 TcSetField(cAliasSA5,"QEV_LOTDEM","N",TamSX3("QEV_LOTDEM")[1],TamSX3("QEV_LOTDEM")[2]) 
	 TcSetField(cAliasSA5,"QEV_IQD"   ,"N",TamSX3("QEV_IQD")[1]   ,TamSX3("QEV_IQD")[2]   ) 
	 TcSetField(cAliasSA5,"QEV_IPO"	  ,"N",TamSX3("QEV_IPO")[1]   ,TamSX3("QEV_IPO")[2]   ) 
   

	DbSelectArea(cAliasSA5)
	DbGoTop()
	While (cAliasSA5)->(!Eof())
        
	    //Armazena o Produto x Fornecedor atual
		cFornAtu := (cAliasSA5)->A5_FORNECE
		cProdAtu := (cAliasSA5)->A5_PRODUTO

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calculos dos Indices Mensais Informados                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		aFatInf := {}
		Q230DefIME(cFornAtu,cProdAtu,cAno,cMes,@aFatInf,.F.)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Indices Mensais Calculados                              	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  

		//Armazena n Meses para cada Fator(Laudo) 
		aFatAcum := Array(Len(aFatIQP),nMesAcu+1)
		For nI := 1 to Len(aFatIQP)
			aFatAcum[nI,1] := aFatIQP[nI,1]
			For nX := 1 to nMesAcu
				aFatAcum[nI,nX+1] := 0
			Next nX
		Next nI

		aLotEnt := Afill(Array(nMesAcu),0) //Lotes Entregues
		aLotDem := Afill(Array(nMesAcu),0) //Lotes Demeritados
		aIQD    := Afill(Array(nMesAcu),0)	//IQDs
		aIPO    := Afill(Array(nMesAcu),0)	//IPOs
                      
	    //Verifica se existe pelo menos 1 Entrada nos ultimos n meses
	    dbSelectArea("QEV")
	    dbSetOrder(2)
        
		 cAliasQEV := "QRYQEV"           
		 aStruQEV  := QEV->(dbStruct())
		
 		 //Verifica se o Produto x Fornecedor possui Entradas no Mes/Ano
 		 cQuery := "SELECT " 
		 cQuery += "QEV.QEV_FILIAL QEV_FILIAL, "
		 cQuery += "QEV.QEV_FORNEC QEV_FORNEC, "
		 cQuery += "QEV.QEV_PRODUT QEV_PRODUT, "
		 cQuery += "QEV.QEV_ANO    QEV_ANO   , "
		 cQuery += "QEV.QEV_MES    QEV_MES   , "
		 cQuery += "QEV.QEV_LOTENT QEV_LOTENT, "
		 cQuery += "QEV.QEV_LOTDEM QEV_LOTDEM, "
		 cQuery += "QEV.QEV_IQD    QEV_IQD   , "
		 cQuery += "QEV.QEV_IPO    QEV_IPO "  
		 
		 cQuery += "FROM "+RetSqlName("QEV")+" QEV "                 
	     cQuery += "WHERE QEV.QEV_FILIAL = '"+xFilial("QEV")+"' AND "                    
		 cQuery += "QEV.QEV_FORNEC = '"+cFornAtu+"' AND "
		 cQuery += "QEV.QEV_PRODUT = '"+cProdAtu+"' AND "
		 cQuery += "QEV.QEV_LOTENT <> 0 AND "
 		 If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX,DB2/400"
		 	 cQuery += "(QEV_ANO || QEV_MES) >= '"+(cAnoIni+cMesIni)+"' AND "
			 cQuery += "(QEV_ANO || QEV_MES) <= '"+(cAnoFim+cMesFim)+"' AND "
		 Else
			 cQuery += "(QEV_ANO+QEV_MES) >= '"+(cAnoIni+cMesIni)+"' AND "
			 cQuery += "(QEV_ANO+QEV_MES) <= '"+(cAnoFim+cMesFim)+"' AND "
		 EndIf
		 cQuery += "QEV.D_E_L_E_T_ <> '*' "                     
		 cQuery += "ORDER BY "+SqlOrder(QEV->(IndexKey(2)))

		 cQuery := ChangeQuery(cQuery)

		 dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQEV,.T.,.T.)

		 TcSetField(cAliasQEV,"QEV_LOTENT","N",TamSX3("QEV_LOTENT")[1],TamSX3("QEV_LOTENT")[2]) 
		 TcSetField(cAliasQEV,"QEV_LOTDEM","N",TamSX3("QEV_LOTDEM")[1],TamSX3("QEV_LOTDEM")[2]) 
		 TcSetField(cAliasQEV,"QEV_IQD"   ,"N",TamSX3("QEV_IQD")[1]   ,TamSX3("QEV_IQD")[2]   ) 
		 TcSetField(cAliasQEV,"QEV_IPO"	  ,"N",TamSX3("QEV_IPO")[1]   ,TamSX3("QEV_IPO")[2]   ) 

 		cCondicao := ' .T.'		     
 		dbSelectArea(cAliasQEV)
 		dbGoTop()
 			   
		While !Eof() .And. &cCondicao

			nI := Ascan(aAnoMes,{|x|x[1]+x[2]==(cAliasQEV)->QEV_ANO+(cAliasQEV)->QEV_MES})
                
			//Acumula as quantidades para cada Laudo
			QEW->(dbSetOrder(1))
			For nX := 1 to Len(aFatAcum)                                 
				If QEW->(MsSeek(xFilial("QEW")+(cAliasQEV)->QEV_FORNEC+(cAliasQEV)->QEV_PRODUT+(cAliasQEV)->QEV_ANO+(cAliasQEV)->QEV_MES+aFatAcum[nX,1]))
					aFatAcum[nX,nI+1] += QEW->QEW_QTDLAU 
				EndIf
			Next nX

			aLotEnt[nI] += (cAliasQEV)->QEV_LOTENT //Lotes entregues
			aLotDem[nI] += (cAliasQEV)->QEV_LOTDEM //Lotes demeritados
			aIQD[nI]    += If((cAliasQEV)->QEV_IQD<>999.99,(cAliasQEV)->QEV_IQD,0) //IQDs
			aIPO[nI]    += (cAliasQEV)->QEV_IPO //IPOs
			dbSkip()                 
		EndDo         
       
		dbSelectArea(cAliasQEV)
		dbCloseArea()
		dbSelectArea("QEV")   
         

		// Verifica se nos ult. n meses houve algum mes com Entrada
		nCtMes := 0
		For nX := 1 to nMesAcu
			If aLotEnt[nX] # 0
				nCtMes ++
			EndIf
		Next nX

		If nCtMes == 0
			(cAliasSA5)->(dbSkip())
			Loop
		EndIf
	
		//Verifica a possibilidade para Geracao do Acumulado
		nCtMes  := 0
		nTotEnt := 0
		
		For nX := 1 to nMesAcu
			If aLotEnt[nX] # 0
				nCtMes ++
				nTotEnt += aLotEnt[nX]
			EndIf
		Next nX

		//Criterio Flexivel
		lAcumula := If(nTotEnt>0,.T.,.F.)

		// Define o IQS do Fornecedor
		SA2->(dbSetOrder(1))
		SA2->(MsSeek(xFilial("SA2")+cFornAtu))
		If SA2->A2_FATAVA == 0 .And. Empty(SA2->A2_DTAVA)
			nIQS := 999.99
		Else
			nIQS := SA2->A2_FATAVA
		EndIf

		//Realiza o calculo do Acumulado
		nIQPa   := 999.99
		nIQIa   := 999.99
		nIPOa   := 999.99
		nIQFa   := 999.99
		nTotDem := 999.99
		
		If lAcumula     
	  		Q230CalAcu(cFornAtu,cProdAtu,nMesAcu,aAnoMes,aLotEnt,aFatIQP,aFatAcum,;
	  			aIQD,aIPO,nFatIQI,nFatIPR,nFatIES,@nIQPa,@nIQIa,@nIPOa,@nIQFa,@nTotDem)		

		EndIf

		lAcumulado := If(!lAcumulado,.T.,lAcumulado) //Flag para geracao dos Indices Acumulados

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza os Indices Mensais Acumulados para Fornecdor x Pro- ³
		//³ duto sem Entradas no Mes/Ano (QEV),nao grava o QEW, pois nao ³
		//³ ha Acumulados.												 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		aDados := {0, 0, 0, 0, 0, 0, 0, 999.99, 999.99, nIQS, 999.99, 999.99, 999.99,;
			999.99, 999.99, 999.99, nIQPa, nTotDem, nIQIa, nIPOa, nIQFa, dDataBase}
                          
		Q230GrvInd(cAno,cMes,cFornAtu,cProdAtu,aDados)

		dbSelectArea(cAliasSA5)
		dbSkip()
		
	EndDo             
	
	dbSelectArea(cAliasSA5)
	If lQuery 
	 	dbCloseArea() 
	Else                
		RetIndex("SA5") 
		Set Filter To
		fErase(cIndexSA5+OrdBagExt())
	EndIf
	dbSelectArea("SA5")

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe o aviso se os Indices Mensais/Acumulados foram gerados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
If !lMensal
	If !lAcumulado
		MsgAlert(STR0031,STR0032) //"Nao h  dados para a geracao Ind. Qual. neste mes/ano"###"Atencao"
	Else
		MsgAlert(STR0033,STR0034) //"Somente foram gerados os Indices acumulados, para produtos sem Entrada no mes/ano"###"Atencao"
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a area original no Cadastro de Indices				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
dbSelectArea(cAliasQEK)
If lQuery 
 	dbCloseArea() 
Else                
	RetIndex("QEK")
	Set Filter To
	fErase(cIndexQEK+OrdBagExt())
EndIf
dbSelectArea("QEK")
                                 
RestArea(aAreaAnt)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Q230CalAcu³ Autor ³ Paulo Emidio de Barros³ Data ³ 24/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza o Calculo dos Fatores Acumulados 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q230CalAcu(cFornece,cProduto,nMesAcu,aAnoMes,aLotEnt,      ³±±   
±±³			 ³ 	   aFatIQP,aFatAcum,aIQD,aIPO,nFatIQI,nFatIPR,nFatIES,    ³±±
±±³			 ³ 	   nIQPa,nIQIa,nIPOa,nIQFa,nTotDem)	                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do Fornecedor                               ³±±
±±³			 ³ EXPC2 = Codigo do Produto 								  ³±±
±±³			 ³ EXPN1 = Numero de Meses Acumulados						  ³±±
±±³			 ³ EXPA1 = Vetor contendo o Ano para Geracao dos Indices      ³±±
±±³			 ³ EXPA2 = Vetor contendo o Numero de Lotes					  ³±±
±±³          ³ EXPA3 = Vetor contendo os Fatores do IQP				      ³±±
±±³			 ³ EXPA4 = Vetor contendo os Fatores Acumulados				  ³±±
±±³			 ³ EXPA5 = Vetor contendo o IQD								  ³±±
±±³			 ³ EXPA6 = Vetor contendo o IPO								  ³±±
±±³          ³ EXPN2 = Fator do IQI										  ³±±
±±³			 ³ EXPN3 = Fator do IPR 									  ³±±
±±³			 ³ EXPN4 = Fator do IES										  ³±±
±±³          ³ EXPN5 = Fatores Acumulados do IQP						  ³±±
±±³			 ³ EXPN6 = Fatores Acumulados do IQI              			  ³±±
±±³			 ³ EXPN7 = Fatores Acumulados do IPO						  ³±±
±±³          ³ EXPN8 = Fatores Acumulados do IQF  						  ³±±
±±³          ³ EXPN9 = Total de Entradas Demeritadas 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q230CalAcu(cFornece,cProduto,nMesAcu,aAnoMes,aLotEnt,aFatIQP,aFatAcum,aIQD,aIPO,nFatIQI,nFatIPR,nFatIES,nIQPa,nIQIa,nIPOa,nIQFa,nTotDem)		
Local aLauAc  := {}
Local nI      := 0
Local nX      := 0
Local nAux    := 0      
Local nIA     := 0
Local nK      := 0
Local nPos    := 0
Local nSoma   := 0          
Local nDiv    := 0
Local nFC     := 0            
Local aFatInf := {}
Local nIQS    := 0                  
Local nIPRa   := 0                                              
Local nIESa   := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calculo dos Acumulados para os Indices Calculados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula o IQI Acumulado										 ³
//³ Acumula a quantidade de cada Fator (Todos os meses) 		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
aLauAc := {}
For nI := 1 to Len(aFatAcum)
	nSoma := 0
	For nX := 1 to nMesAcu
		nSoma += aFatAcum[nI,nX+1]
	Next nX
	Aadd(aLauAc,{aFatAcum[nI,1],nSoma})
Next nI

// Acumula os demeritos
nTotDem := 0
For nI := 1 to nMesAcu
	nTotDem += aIQD[nI]
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Calculo do IQI Acumulado                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  

// Calculo do IQPa por Tabela Completa
nSoma := 0
nAux  := 0
For nX := 1 to Len(aLauAc)
	nAux  += (aFatIQP[nX,2]*aLauAc[nX,2]) //Fator * Ocorrencia Acumulada do Laudo
	nSoma += aLauAc[nX,2]
Next nX
nIA := If(nSoma#0,(nAux/nSoma)*100,0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calculo do IQIa por Tabela									 ³
//³ Obtem o Fator K, de acordo com o IA							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
QEJ->(dbSetOrder(1))
QEJ->(MsSeek(xFilial("QEJ")+"1"+Str(nIA,6,2),.T.))

nK    := SuperVal(QEJ->QEJ_FATOR)
nIQPa := (100-nK)-nTotDem
nIQPa := If(nIQPa<0,0,nIQPa)

// Calculo do IQS
SA2->(dbSetOrder(1))
SA2->(MsSeek(xFilial("SA2")+cFornece))
If SA2->A2_FATAVA == 0 .And. Empty(SA2->A2_DTAVA)
	nIQS := 999.99
Else
	nIQS := SA2->A2_FATAVA
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Calculo do IQIa por Tabela									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
QEJ->(dbSetOrder(1))
If nIQS <> 999.99
	// Obtem o Fator FC, de acordo com o IQS
	QEJ->(MsSeek(xFilial("QEJ")+"2"+Str(nIQS,6,2),.T.))
	nFC := SuperVal(QEJ->QEJ_FATOR)
Else
	// Obtem o Fator FC para quando nao tiver a nota do IQS (0)
	If QEJ->(MsSeek(xFilial("QEJ")+"2"+Str(nIQS,6,2)))
		nFC := SuperVal(QEJ->QEJ_FATOR)
	Else
		// IQP por Tabela Completa, assume 1
		nFC := 1
	EndIf
EndIf
nIQIa := (nIQPa*nFC)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calculo do IPR Acumulado                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
nIPRa := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calculo do IES Acumulado                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  

// Calcula o IPOa: Media dos IPOs dos n meses
nSoma := 0
nDiv  := 0
nIPOa := 0

For nX := 1 to nMesAcu
	If aLotEnt[nX] # 0
		nSoma += aIPO[nX]
		nDiv ++
	EndIf
Next nX               

If nDiv # 0
	nIPOa := (nSoma/nDiv)
EndIf

nIESa := nIPOa

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calculos dos Acumulados para os Indices Informados: media    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
aFatInf := {}
QF1->(dbSetOrder(1))
QF1->(MsSeek(xFilial("QF1")))
While QF1->(!Eof()) .And. QF1->QF1_FILIAL == xFilial("QF1")
                        
	//Indice informado mensalmente
	If QF1->QF1_CALC == "I"	
		QE0->(dbSetOrder(1))
		For nI := 1 to Len(aAnoMes)
			If	QE0->(MsSeek(xFilial("QE0")+aAnoMes[nI,1]+aAnoMes[nI,2]+cFornece+cProduto+QF1->QF1_INDICE))
				nPos := Ascan(aFatInf,{|x|x[1]==QF1->QF1_INDICE})
				If nPos == 0
					//Armazena o Indice, Somatoria de Valores Mensais, Meses, Fator Indice no calculo IQF
					Aadd(aFatInf,{QF1->QF1_INDICE,QE0->QE0_VALOR,1,QF1->QF1_FATIQF})
				Else
					aFatInf[nPos,2] += QE0->QE0_VALOR
					aFatInf[nPos,3] ++
				EndIf
			EndIf
		Next nI
	EndIf
	QF1->(dbSkip())

EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calculo do IQF Acumulado                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  

//Indices calculados
 nIQFa := (nFatIQI*nIQIa) + (nFatIPR*nIPRa) + (nFatIES*nIESa)

// Para evitar efetuar o demeritro do fornecedor em entradas sem laudo e somente
// com medições, mantem o  mesmo indice de qualidade não alterando.

if nIQIa = 0 .and. QEV->QEV_LOTDEM = 0 
	dbSelectArea("QEG")
	dbSetOrder(1)
	if (dbSeek(xFilial("QEG")+SA5->A5_SITU))
	   nIQFa := QEG->QEG_IQI_S
    EndIF
EndIf

//Indices informados: Media dos valores mensais
For nI := 1 to Len(aFatInf)
	nIQFa += ((aFatInf[nI,2]/aFatInf[nI,3])*aFatInf[nI,4])
Next nI

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q230IdeIQF³ Autor ³ Paulo Emidio de Barros³ data ³ 24/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Identifica o Fator do Indice no Calculo do IQF (QF1)		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q230IdeIQF(cIndInf,lConsiste,nFator)						  ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Indice Informado									  ³±±
±±³			 ³ EXPL1 = Identifica se a mensagem sera exibida			  ³±±
±±³			 ³ EXPN1 = Fator											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. ou .F.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q230IdeIQF(cIndInf,lConsiste,nFator)
Local lRetorno := .T.
Local aAreaAnt := GetArea()

QF1->(dbSetOrder(1))
If !(QF1->(MsSeek(xFilial("QF1")+cIndInf)))
	If lConsiste
		MsgAlert(STR0035+cIndInf,STR0036) //"Indice nao cadastrado: "###"Atencao" 
		lRetorno := .F.	
	EndIf
Else
	nFator := QF1->QF1_FATIQF
EndIf     
RestArea(aAreaAnt)

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q230DefIQP³ Autor ³ Paulo Emidio de Barros³ data ³ 24/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os fatores de IQP e seus respectivos valores       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q230DefIQP(cFatApr,cFatRep,cFatLU)						  ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Fator Aprovado									  ³±±
±±³			 ³ EXPC2 = Fator Reprovado									  ³±±
±±³			 ³ EXPC3 = Fator com Liberacao Urgente						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPA1 = Fatores do IQP									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q230DefIQP(cFatApr,cFatRep,cFatLU)
Local aAreaAnt := GetArea()
Local aFatIQP  := {}        
             
dbSelectArea("QED")
dbSetorder(1)
MsSeek(xFilial("QED"))
While !Eof() .And. QED_FILIAL == xFilial("QED")
	If QED_CATEG == "4"	//Liberacao Urgente
		cFatLU := QED_CODFAT
	Else 
		If QED_CATEG == "1"	//Aprovado sem Restricoes
			cFatApr := QED->QED_CODFAT
		ElseIf QED_CATEG == "3" //Reprovado Totalmente
			cFatRep := QED->QED_CODFAT
		EndIf
		Aadd(aFatIQP,{QED_CODFAT,SuperVal(QED_FATOR),QED_CATEG,0})
	EndIf
	dbSkip()
EndDo
RestArea(aAreaAnt)

Return(aFatIQP)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q230DefIME³ Autor ³ Paulo Emidio de Barros³ data ³24/02/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Define os Indices Mensais para calculo 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q230DefIME(cFornece,cProduto,cAno,cMes,aFatInf,lMessage)   ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do Fornecedor			  					  ³±±
±±³			 ³ EXPC2 = Codigo do Produto 						  		  ³±±
±±³			 ³ EXPC3 = Ano para Geracao dos Indices	  				      ³±±
±±³			 ³ EXPC2 = Mes para Geracao dos Indices 					  ³±±
±±³			 ³ EXPA1 = Vetor contendo os Fatores Informados 			  ³±±
±±³			 ³ EXPL1 = Indica se a Mensagem sera exibida				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. ou .F.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q230DefIME(cFornece,cProduto,cAno,cMes,aFatInf,lMessage)
Local lRetorno := .T.
Local aAreaAnt := GetArea()
Default lMessage := .T.
                
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calculos dos Indices Mensais Informados                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
QF1->(dbSetOrder(1))
QF1->(MsSeek(xFilial("QF1")))
While QF1->(!Eof()) .And. QF1->QF1_FILIAL == xFilial("QF1") .And. lRetorno

    //Verifica se o Indice foi informado mensalmente 
	If QF1->QF1_CALC=="I" .And. QF1->QF1_FATIQF>0	
		QE0->(dbSetOrder(1))
		If QE0->(!MsSeek(xFilial("QE0")+cAno+cMes+cFornece+cProduto+QF1->QF1_INDICE))
		 	If lMessage
				MsgAlert(STR0029+Chr(13)+Chr(10)+Alltrim(cProduto)+"/"+Alltrim(cFornece)+" ("+QF1->QF1_INDICE +")",STR0030)	//"Indice Mensal nao informado para o Produto/Fornecedor: " ### "Atencao"	 
				lRetorno := .F.
			EndIf	
		Else
			//Armazena o calculo do Indice Mensal*Fator do IQF
			Aadd(aFatInf,QF1->QF1_FATIQF*QE0->QE0_VALOR) 
		EndIf
	EndIf
	QF1->(dbSkip())
EndDo

RestArea(aAreaAnt)

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q230GrvInd³ Autor ³ Paulo Emidio de Barros³ data ³24/02/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Define os Indices Mensais para calculo 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q230GrvInd(cAno,cMes,cFornece,cProduto,aDados)			  ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Ano para Geracao dos Indices						  ³±±
±±³			 ³ EXPC2 = Mes para Geracao dos Indices						  ³±±
±±³			 ³ EXPC3 = Codigo do Fornecedor                  			  ³±±
±±³			 ³ EXPC2 = Codigo do Produto   								  ³±±
±±³			 ³ EXPA1 = Vetor contendo os dados dos Indices				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q230GrvInd(cAno,cMes,cFornece,cProduto,aDados)
Local aAreaAnt := GetArea()

//Atualiza os Indices Mensais
dbSelectArea('QEV')
dbSetOrder(1)
If !MsSeek(xFilial("QEV")+cAno+cMes+cFornece+cProduto)
	RecLock("QEV",.T.)
	QEV->QEV_FILIAL := xFilial("QEV")
	QEV->QEV_ANO    := cAno
	QEV->QEV_MES    := cMes
	QEV->QEV_FORNEC := cFornece
	QEV->QEV_PRODUT	:= cProduto
Else
	RecLock("QEV",.F.)
EndIf
QEV->QEV_LOTENT	:= aDados[1] 
QEV->QEV_LOTDEM	:= aDados[2]
QEV->QEV_LOTINS	:= aDados[3]
QEV->QEV_LOTSKP	:= aDados[4]
QEV->QEV_QTDINS	:= Round(aDados[5],QEA230Dec("QEV_QTDINS", 0))
QEV->QEV_QTDSKP	:= Round(aDados[6],QEA230Dec("QEV_QTDSKP", 0))
QEV->QEV_QTDREJ	:= Round(aDados[7],QEA230Dec("QEV_QTDREJ", 0))
QEV->QEV_IQP	:= aDados[8]
QEV->QEV_IQD	:= aDados[9]
QEV->QEV_IQS	:= aDados[10]
QEV->QEV_IQI	:= aDados[11]
QEV->QEV_IPO	:= aDados[12]
QEV->QEV_ITR	:= aDados[13]
QEV->QEV_IES	:= aDados[14]
QEV->QEV_IPR	:= aDados[15]
QEV->QEV_IQF	:= aDados[16]
QEV->QEV_IQPA	:= aDados[17]
QEV->QEV_IQDA	:= aDados[18]
QEV->QEV_IQIA	:= aDados[19]
QEV->QEV_IPOA	:= aDados[20]
QEV->QEV_IQFA	:= aDados[21]
QEV->QEV_DTGER	:= aDados[22]
MsUnLock()

RestArea(aAreaAnt)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Q230DIQF	³ Autor ³ Paulo Emidio de Barros³ Data ³24/02/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclui os Indices mensais								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q230DIQF(EXPC1,EXPN1,EXPN2,EXPA1,EXPL1,EXPC2,EXPC3)		  ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias Atual										  ³±±
±±³			 ³ EXPN1 = Numero do Registro Corrente						  ³±±
±±³			 ³ EXPN2 = Opcao do aRotina									  ³±±
±±³			 ³ EXPA1 = Campos a serem editados							  ³±±
±±³			 ³ EXPL1 = Indica se todos os Indices serao excluidos         ³±±
±±³			 ³ EXPC2 = Ano para exclusao do Historico   				  ³±±
±±³			 ³ EXPC3 = Mes para exclusao do Historico   				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q230DIQF(cAlias,nReg,nOpc,aCampos,lDelAll,cDelAno,cDelMes,cDelFor)
Local lExecDel 
Local cPerg     := "QEA230" 
Local lPerg     := .F.
Local aAreaAnt  := GetArea()
Local cAno      := ''
Local cMes      := ''
Local cFornece  := ''
Local cProduto  := ''          
Local cCondicao := ''                                
Local nMv_Par01 := 0
Local cQuery    := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ lExecDel - Parametro que define se ira utilizar TcSqlExec()  ³
//³ para exclusao dos Lancamentos otimizando a rotina.			 ³
//³ O Objetivo do parametro e auxiliar as empresas que fazem re- ³
//³ gistros das inclusoes/alteracoes/exclusoes em Logs de Transa ³
//³ cao para efeitos de auditoria e rastreabilidade.             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
lExecDel := If(GetMv("MV_QTOPDEL")=="1",.T.,.F.) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indica se todos os indices serao excluidos devido a alteracao³
//³ do dia de Fechamento Mensal.								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
lDelAll := If(lDelAll==NIL,.F.,lDelAll)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclui o ano selecionado mantendo o Historico de 5 anos Acu- ³
//³ mulados. 													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
cDelAno := If(cDelAno==NIL," ",cDelAno)
cDelMes := If(cDelMes==NIL," ",cDelMes)
cDelFor := If(cDelFor==NIL," ",cDelFor)

If !lDelAll
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ mv_par01 = 1) Todos Fornecedores 							 ³
	//³ 		   2) Um Fornecedor									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lPerg := Pergunte(cPerg,.T.)
	If !lPerg
		Return(NIL)
	EndIf	
	
	cAno     := QEV->QEV_ANO
	cMes     := QEV->QEV_MES
	cFornece := QEV->QEV_FORNEC 
	cProduto := QEV->QEV_PRODUT  
	nMv_Par01:= Alltrim(Str(Mv_Par01))	
	
	If ExistBlock("QIEGERIN")
		ExecBlock("QIEGERIN", .F., .F.,{cAno, cMes, cFornece, cProduto, nMv_Par01})
	EndIf	

EndIf

dbSelectArea("QEW")
dbSetOrder(2)

 If lExecDel
	 cQuery := ""               
	 cQuery += "DELETE FROM "+RetSqlName('QEW')+" "  
	 cQuery += "WHERE QEW_FILIAL = '"+xFilial("QEW")+If(lDelAll,"'","' AND ") 
	 
	 If !Empty(cDelAno) //Exclui o ano selecionado mantendo o historico de 5 anos
		cQuery += " AND QEW_ANO = '"+cDelAno+"'"	 
	 EndIf

	 If !Empty(cDelMes) //Exclui o Mes selecionado 
		cQuery += " AND QEW_MES = '"+cDelMes+"'"	 
	 EndIf

	 If !Empty(cDelFor) //Exclui o Fornecedor selecionado 
		cQuery += " AND QEW_FORNEC = '"+cDelFor+"'"	 
	 EndIf
	 
	 If !lDelAll	 
		 If mv_par01 == 2 //somente o Fornecedor+Produto selecionado
			 cQuery += "QEW_FORNEC = '"+cFornece+"' AND "  	 
			 cQuery += "QEW_PRODUT = '"+cProduto+"' AND "
		 EndIf	 
		 cQuery += "QEW_ANO = '"+cAno+ "' AND "
		 cQuery += "QEW_MES = '"+cMes+"'"
	 EndIf
	 TcSqlExec(cQuery)
	 
	 //Exclui o Fornecedor x Produto no Ano+Mes
	 dbSelectArea("QEV")
	 If lDelAll //Exclui todos os Indices caso o dia de fechamento seja alterado
		 cQuery := ""
		 cQuery += "DELETE FROM "+RetSqlName("QEV")+" "
		 cQuery += "WHERE QEV_FILIAL = '"+xFilial("QEV")+"'"
		 
	 	 If !Empty(cDelAno) //Exclui o ano selecionado mantendo o historico de 5 anos
			cQuery += " AND QEV_ANO = '"+cDelAno+"'"	 
		 EndIf

	 	 If !Empty(cDelMes) //Exclui o mes selecionado
			cQuery += " AND QEV_MES = '"+cDelMes+"'"	 
		 EndIf

	 	 If !Empty(cDelFor) //Exclui o mes selecionado
			cQuery += " AND QEV_FORNEC = '"+cDelFor+"'"	 
		 EndIf

		 TcSqlExec(cQuery)
	 Else

		IF ExistBlock( "QIEDEQEV" )
        	ExecBlock( "QIEDEQEV", .f., .f.)
		Endif                
		
		 If mv_par01 == 2
			 RecLock("QEV",.F.,.T.)
			 dbDelete()
			 MsUnLock()
		 Else
			 cQuery := ""
			 cQuery += "DELETE FROM "+RetSqlName("QEV")+" "
			 cQuery += "WHERE QEV_FILIAL = '"+xFilial("QEV")+"' AND "
			 cQuery += "QEV_ANO = '"+cAno+"' AND "
			 cQuery += "QEV_MES = '"+cMes+"'"
			 TcSqlExec(cQuery)
		 EndIf		 
	 EndIf
 Else	 
	 If lDelAll //Exclui todos os Indices caso o dia de fechamento seja alterado
	 	 cSeek     := xFilial("QEW")
	 	 cCondicao := "QEW_FILIAL == '"+xFilial("QEW")+"' "      
	 	 
 	 	 If !Empty(cDelAno) //Exclui o ano selecionado mantendo o historico de 5 anos
			cSeek     += cDelAno
			cCondicao += " .And. QEW_ANO == '"+cDelAno+"' "
		 EndIf

 	 	 If !Empty(cDelMes) //Exclui o Mes selecionado 
			cSeek     += cDelMes
			cCondicao += " .And. QEW_MES == '"+cDelMes+"' "
		 EndIf

 	 	 If !Empty(cDelFor) //Exclui o Mes selecionado 
			cSeek     += cDelFor
			cCondicao += " .And. QEW_FORNEC == '"+cDelFor+"' "
		 EndIf

	 Else
		 If mv_par01 == 2
		  	 cSeek := xFilial("QEW")+cAno+cMes+cFornece+cProduto
		  	 cCondicao := "QEW_FILIAL == '"+xFilial("QEW")+"' .And. "
			 cCondicao += "QEW_FORNEC == '"+cFornece+"' .And. "
			 cCondicao += "QEW_PRODUT == '"+cProduto+"' .And. "
			 cCondicao += "QEW_ANO == '"+cAno+"' .And. "
			 cCondicao += "QEW_MES == '"+cMes+ "' "
		 Else
		 	 cSeek  := xFilial("QEW")+cAno+cMes
		 	 cCondicao := "QEW_FILIAL == '"+xFilial("QEW")+"' .And. "
		 	 cCondicao += "QEW_ANO == '"+cAno+"' .And. "
 		 	 cCondicao += "QEW_MES == '"+cMes+"' "
		 EndIf
     EndIf
     	
	 MsSeek(cSeek)
	 While !Eof() .And. &cCondicao
		 RecLock("QEW",.F.,.T.)
		 dbDelete()
		 MsUnLock()
		 dbSkip()
	 EndDo
	
	 dbSelectArea("QEV")
	 If lDelAll //Exclui todos os Indices caso o dia de fechamento seja alterado
         
 	 	 cSeek     := xFilial("QEV")
	 	 cCondicao := "QEV_FILIAL == '"+xFilial("QEV")+"' "
	 	 
 	 	 If !Empty(cDelAno) //Exclui o ano selecionado mantendo o historico de 5 anos
			cSeek     += cDelAno
			cCondicao += ".And. QEV_ANO == '"+cDelAno+"' "
		 EndIf

 	 	 If !Empty(cDelMes) //Exclui o Mes selecionado
			cSeek     += cDelMes
			cCondicao += ".And. QEV_MES == '"+cDelMes+"' "
		 EndIf

 	 	 If !Empty(cDelFor) //Exclui o Mes selecionado
			cSeek     += cDelFor
			cCondicao += ".And. QEV_FORNEC == '"+cDelFor+"' "
		 EndIf

	 	 dbSetOrder(1)
		 MsSeek(cSeek)

 		 IF ExistBlock( "QIEDELQEV" )
         	ExecBlock( "QIEDELQEV", .f., .f.)
		 Endif		 
		 While !Eof() .And. &cCondicao
		  	 RecLock("QEV",.F.,.T.)
			 dbDelete()
			 MsUnLock()
			 dbSkip()  
		 EndDo
	 Else

		 IF ExistBlock( "QIEDELQEV" )
          	ExecBlock( "QIEDELQEV", .f., .f.)
		 Endif	 	
		 If mv_par01 == 2         
		 	 RecLock("QEV",.F.,.T.)
			 dbDelete()
			 MsUnLock()
		 Else
		 	 dbSetOrder(1)
			 MsSeek(xFilial("QEV")+cAno+cMes)
			 While (QEV_FILIAL+QEV_ANO+QEV_MES) == (xFilial("QEV")+cAno+cMes) .And. !Eof()
			  	 RecLock("QEV",.F.,.T.)
				 dbDelete()
				 MsUnLock()
				 dbSkip()  
			 EndDo
		 EndIf	 	 
	 EndIf
 EndIf

RestArea(aAreaAnt)
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Q230RetData³ Autor ³Paulo Emidio de Barros³ Data ³24/02/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclui os Indices mensais								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q230RetData(EXPC1,EXPC2,EXPC3)							  ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Dia												  ³±±
±±³			 ³ EXPC2 = Mes												  ³±±
±±³			 ³ EXPC3 = Ano									  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPA1[1] = Data Inicio									  ³±±
±±³			 ³ EXPA1[2] = Data Final									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q230RetData(cDia,cMes,cAno)
Local lBissexto := .F.                
Local nX        := 0
Local nY		:= 0
Local nW		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o periodo a ser considerado para a geracao IQF mensal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
If cMes == '02' .And. Val(cDia) >= 28
	dInicio   := Ctod('01/'+cMes+'/'+cAno,"DDMMYY")
	lBissexto := Int(Year(dInicio)/4)==(Year(dInicio)/4)
EndIf

If (cDia=='30' .Or. cDia=='31') 
	dInicio := Ctod('01/'+cMes+'/'+cAno,"DDMMYY")
	dFinal  := LastDay(dInicio)
Else  
	If cMes == '02' .And. (!lBissexto .And. Val(cDia) >= 28) 	.Or. (lBissexto .And. Val(cDia) >= 29) 
		dFinal  := LastDay(Ctod('01/'+cMes+'/'+cAno,'DDMMYY'))
		dInicio := LastDay(Ctod('01/'+cMes+'/'+cAno,"DDMMYY"))
	Else
		dFinal  := Ctod(cDia+'/'+cMes+'/'+cAno,'DDMMYY')
		dInicio := Ctod(cDia+'/'+cMes+'/'+cAno,"DDMMYY")
	EndIf	
	
	dInicio := FirstDay(dInicio)-1
	If !(Month(dInicio) == 2  .And. (cDia == '28' .Or. cDia == '29')) 
	    nX := Val(cDia)
		nY := Day(LastDay(dInicio))
		nW := nX - nY 
		dInicio := dInicio + nW
	EndIf		          
	
	If (Month(dInicio) == 2  .And. lBissexto)
		dInicio := dInicio - 2
	Else
		dInicio := dInicio + 1
	EndIf	
	
EndIf
Return({dInicio,dFinal})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QEA230Dec  ³ Autor ³Cicero Odilio Cruz    ³ Data ³05/10/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Recupera o numero de decimais de um Campo 			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QEA230Dec(cCampo, nDefault)
Local nDecimais := 0

If !Empty(GetSX3Cache(cCampo,"X3_CAMPO"))
	nDecimais := GetSX3Cache(cCampo,"X3_DECIMAL")
Else
	nDecimais := nDefault
EndIf      

Return nDecimais

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QE230TEn ³ Autor ³ Paulo Fco. Cruz Neto  ³ Data ³17/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula o total de entradas com base na entrada da inspecao³±±
±±³          ³ quando utilizado o parametro MV_QENTQEK					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QE230TEn(EXPC1,EXPD1,EXPD2,EXPL1)					  	  ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do fornecedor								  ³±±
±±³			 ³ EXPC2 = Codigo do produto								  ³±±
±±³			 ³ EXPD1 = Data inicial										  ³±±
±±³			 ³ EXPD2 = Data final										  ³±±
±±³			 ³ EXPL1 = Valor conforme parametro "MV_QTRFREP"			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPN1 = Numero total de entradas							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QE230TEn(cForn,cProd,dInicio,dFinal,lQtdRep)
Local cAlias	:= "QEK"
Local cQuery	:= ""
Local nTotEnt	:= 0
Local aArea		:= GetArea()

Default cForn	:= ""
Default cProd	:= ""
Default dInicio	:= CtoD("")
Default dFinal	:= CtoD("")
Default lQtdRep	:= If(GetMv("MV_QTRFREP")=="S",.T.,.F.)
    
cAlias := 'QRYQEK2'
cQuery := "SELECT "
cQuery += "QEK.QEK_FILIAL QEK_FILIAL, "
cQuery += "QEK.QEK_FORNEC QEK_FORNEC, "
cQuery += "QEK.QEK_LOJFOR QEK_LOJFOR, "
cQuery += "QEK.QEK_PRODUT QEK_PRODUT, "
cQuery += "QEK.QEK_REVI   QEK_REVI  , "
cQuery += "QEK.QEK_LOTE   QEK_LOTE  , "
cQuery += "QEK.QEK_TAMLOT QEK_TAMLOT, "
cQuery += "QEK.QEK_TIPONF QEK_TIPONF, "
cQuery += "QEK.QEK_TIPDOC QEK_TIPDOC, "
cQuery += "QEK.QEK_DTENTR QEK_DTENTR, "
cQuery += "QEK.QEK_VERIFI QEK_VERIFI, "
cQuery += "QEK.QEK_DIASAT QEK_DIASAT, "
cQuery += "QEK.QEK_SITENT QEK_SITENT, "
cQuery += "QEK.QEK_NTFISC QEK_NTFISC, "
cQuery += "QEK.QEK_SERINF QEK_SERINF, "
cQuery += "QEK.QEK_ITEMNF QEK_ITEMNF, "
cQuery += "QEK.QEK_TIPONF QEK_TIPONF "
cQuery += "FROM "+RetSqlName("QEK")+" QEK "
cQuery += "WHERE QEK.QEK_FILIAL = '"+xFilial("QEK")+"' AND "
cQuery += "QEK.QEK_TIPONF <> 'B' AND "                      
cQuery += "QEK.QEK_TIPONF <> 'D' AND "
cQuery += "QEK.QEK_FORNEC = '"+cForn+"' AND "
cQuery += "QEK.QEK_PRODUT = '"+cProd+"' AND "
cQuery += "QEK.QEK_SITENT <> '1' AND "
cQuery += "QEK.QEK_SITENT <> '7' AND "       	
cQuery += "QEK.QEK_DTENTR >= '"+DtoS(dInicio)+"' AND " 
cQuery += "QEK.QEK_DTENTR <= '"+DtoS(dFinal)+"' AND " 	  
cQuery += "QEK.D_E_L_E_T_<> '*' " 
cQuery += "ORDER BY QEK.QEK_FORNEC,QEK.QEK_PRODUT "
 
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

TcSetField((cAlias),"QEK_DTENTR","D")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula o total de entradas									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
(cAlias)->(dbGoTop())
ProcRegua(LastRec())

While (cAlias)->(!Eof())		
	If !(lQtdRep .And. AllTrim((cAlias)->QEK_TIPDOC) == "TR") //Nao considera as Transferencias
		nTotEnt ++
	EndIf

	(cAlias)->(dbSkip())		
EndDo

(cAlias)->(dbCloseArea())

Set Filter To

RestArea(aArea)

Return nTotEnt
