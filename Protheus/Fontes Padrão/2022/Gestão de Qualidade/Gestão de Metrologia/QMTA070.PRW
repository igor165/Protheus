#INCLUDE "QMTA070.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QMTA070  ³ Autor ³ Wanderley Goncalves Jr³ Data ³ 18/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Padr”es                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0001),"AxPesqui"  , 0 , 1,,.F.},;  // "Pesquisar" 
                     {OemToAnsi(STR0002),"AxVisual"  , 0 , 2},;  // "Visualizar"
                     {OemToAnsi(STR0003),"A070IPad"  , 0 , 3},;  // "Incluir"   
                     {OemToAnsi(STR0004),"A070IPad"  , 0 , 4},;  // "Alterar"   
                     {OemToAnsi(STR0005),"A070DPad"  , 0 , 5, 3},;
					 {OemToAnsi(STR0024),"QMT040AtPadr(.T.)"  , 0 , 3} }  // Gera Padroes Automaticos

Return aRotina

Function QMTA070  

Local lQM070Brow := ExistBlock("QM070BROW")
Local aRotAdic	 := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private  cCadastro := OemtoAnsi(STR0006)  //"Padr”es"
Private  aRotina := MenuDef() 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 


QM3->(DbSetOrder(1))
If lQM070Brow
	ExecBlock("QM070BROW",.F.,.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
//³ Ponto de entrada - Adiciona rotinas ao aRotina       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QM070ROT")
	aRotAdic := ExecBlock("QM070ROT", .F., .F.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"QM3")

Set Key VK_F12 To	

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A070IPad ³ Autor ³ Wanderley Gonalves Jr ³ Data ³ 17/03/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Padroes - Inc/Alt    		     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A070IPro(ExpC1,ExpN1,ExpN2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA070                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³	MOTIVO DA ALTERACAO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Iuri Seto     ³31/08/00³ 5095 ³Gerar nova revisao ao alterar uma escala³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

FUNCTION A070IPad(cAlias,nReg,nOpc)
Local  nOpcA:=0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private  aTELA[0][0],aGETS[0]


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia para processamento dos Gets          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOpcA:=0

if nOpc == 3  // Inclusao
	Begin Transaction
		nOpcA:=AxInclui( cAlias, nReg, nOpc, , , ,"A070TDOK()",,'QMT070grv()')
		If nOpcA == 1   // Confirmou a inclusao
			If Alltrim(QM3->QM3_TIPPAD) == "S" //Tratamento para Tipo de Padrao Subjetivo
			   If ExistBlock("QMA070S")
			      ExecBlock("QMA070S",.F.,.F.)
			   Endif
			Endif
		Endif	
	End Transaction	
Elseif nOpc == 4  // Alteracao
	If QM3->QM3_REVPAD <> QMA070UltR(QM3->QM3_PADRAO)
		HELP(" ",1,"QMTALTREV") // Nao e possivel alterar esta revisao. Somente a ultima revisao pode ser alterada.
	Else 
		If !QMA070Cal(QM3->QM3_PADRAO,QM3->QM3_REVPAD)
			Begin Transaction
		 		nOpcA:=AxAltera( cAlias, nReg, nOpc, , , , ,"A070TDOK()")
			End Transaction				
		Else
			Begin Transaction
				nOpcA:=AltRevisao( cAlias, nReg, nOpc, , , , ,"A070TDOK()",,"QM3_DESCRI")
				If nOpcA == 4  // Confirmou a Alteracao e gerou revisao
					RecLock("QM3",.F.)
					//QM3->QM3_REVPAD := StrZero(Val(QM3->QM3_REVPAD)+1,2)  // incremento ja esta sendo feito no QMTXFUN 
					QM3->QM3_INVRPD := Inverte(QM3->QM3_REVPAD,2)
					QM3->QM3_DATREV	 := dDataBase
					MsUnlock()
				EndIf
			End Transaction
		EndIf
	EndIf			
Endif
	
Return(Nil)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A070DPad ³ Autor ³ Wanderley Goncalves Jr³ Data ³ 18/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de exclusao de Padräes                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A070DPad(ExpC1,ExpN1,ExpN2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION A070DPad(cAlias,nReg,nOpc)
Local  nOpcA //,nCntDele := 0 ,aAC := { OemToAnsi(STR0007),OemToAnsi(STR0008) }  //"Abandona"###"Confirma" 
Local  lAchou := .f.
Local  oDlg 
Local  oSize
Local  oExclu
Local  aSize     := MsAdvSize()
Local  aInfo     := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
local  aPosObj   := MsObjSize(aInfo,{},.T.)
Local  aPosEnch   := {}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private  aTELA[0][0],aGETS[0]

While .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para processamento dos Gets          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpcA:=0
	dbSelectArea(cAlias)
	RecLock(cAlias,.F.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula as dimensoes dos objetos                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSize := FwDefSize():New( .T. ) // Com enchoicebar
	oSize:lLateral     := .F.  // Calculo vertical 
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Enchoice                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSize:AddObject( "ENCHOICE", 50, 50, .T., .T. ) // Adiciona enchoice

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Dispara o calculo                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSize:Process() 

	aPosEnch := {oSize:GetDimension("ENCHOICE","LININI"),;
					 oSize:GetDimension("ENCHOICE","COLINI"),;
					 oSize:GetDimension("ENCHOICE","LINEND"),;
					 oSize:GetDimension("ENCHOICE","COLEND")}

	DEFINE MSDIALOG oDlg TITLE cCadastro FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL OF oMainWnd  
		//nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0009),,aPosEnch)  //"Quanto … exclus„o?" 
			oExclu:=MsMGet():New( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0009),, aPosEnch,,,,,,oDlg,,,,,,,,,,)
			oExclu:oBox:align := CONTROL_ALIGN_ALLCLIENT
			nOpca := 1
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})

	dbSelectArea(cAlias)

	IF nOpcA == 2
		If QM3->QM3_REVPAD <> QMA070UltR(QM3->QM3_PADRAO)
			HELP(" ",1,"QMTDELREV") // Nao e possivel excluir esta revisao. Somente a ultima revisao pode ser excluida.
		Else           
			If QMA070Cal(QM3->QM3_PADRAO,QM3->QM3_REVPAD)
				HELP(" ",1,"QMTADELREM") // Nao e possivel excluir esta revisao, pois existem medicoes cadastradas.
			Else	
				dbSelectArea("QMC")
	    	  	dbSetOrder(2)
		      	dbSeek(xFilial("QMC")+QM3->QM3_PADRAO)
	    	  	If(Found(),lAchou := .t.,lAchou := .f.)
				dbselectArea("QMA")
				dbsetorder(2)
				dbSeek(xFilial("QMA")+QM3->QM3_PADRAO)
				If !lAchou
			      If(Found(),lAchou := .t.,lAchou := .f.)
				EndIf
			
				If lAchou 
	    	    	HELP(" ",1,"A070DPAD") // Padr„o n„o pode ser excluido,
										  // pois esta associado a escalas 
	        	 	Exit  
		      	Else  
	    	     	dbSelectArea("QM3")
	        	 	RecLock("QM3")
		         	dbDelete()
	    	  	Endif
    	  	Endif
	   Endif
   Endif
   Exit
EndDo

dbSelectArea(cAlias)

Return(Nil)

/*/
antigo a070Chave
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³qmt070Chv ³ Autor ³ Wanderley Goncalves   ³ Data ³ 21/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida‡Æo dos campos chave                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA070 - E' chamada no X3_VALID.                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function qmt070Chv()
Local  lRet := .T.

If ! Empty( M->QM3_PADRAO ) .and. ! Empty( M->QM3_REVPAD )
	lRet := FreeForUse("QM3",M->QM3_PADRAO+M->QM3_REVPAD)
	If lRet
		dbSelectArea("QM3")
		If dbSeek( xFilial() + M->QM3_PADRAO + Inverte(M->QM3_REVPAD) )
			Help( " ", 1, "JAGRAVADO" )
			lRet := .F.
		Endif
	Endif
EndIf

Return( lRet )

/*/
antigo A070Pc
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³q070Pc    ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 10/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chama a funcao que monta a picture de um campo.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ q070Pc(cCampo)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome do Campo que tera' a picture a ser definida   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function q070Pc(cCampo)
Local  cPict

If INCLUI .OR. ALTERA
	cPict := QA_PICT(cCampo,&("M->"+cCampo))  
Else
	cPict := ""
EndIf

Return cPict

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A070TdOK ³ Autor ³ Wanderley Goncalves   ³ Data ³ 15/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida TudoOk                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A070TdOk()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A070TdOK()
Local  lRet := .T.

If !FQMTA070()
	lRet := .F.
Endif

If Upper(M->QM3_TIPPAD) == "O" .and. empty(M->QM3_FREQAF)
	Help(" ",1,"A070OBFA") // Para padroes do Tipo Objetivo ‚ obrigatorio o
								  // preenchimento do campo Frequencia de Afericao.
	lRet := .F.
EndIf

If Upper(M->QM3_TIPPAD) == "O" .and. empty(M->QM3_CERTIF)
	Help(" ",1,"A070OBNC") // Para padroes do Tipo Objetivo ‚ obrigatorio o
								  // preenchimento do campo Numero do Certificado.
	lRet := .F.
EndIf

If Upper(M->QM3_TIPPAD) == "O" .and. empty(M->QM3_DATAF)
	Help(" ",1,"A070OBDC") // Para padroes do Tipo Objetivo ‚ obrigatorio o
								  // preenchimento do campo Data de Calibracao.
	lRet := .F.
EndIf

If Upper(M->QM3_TIPPAD) == "O" .and. empty(M->QM3_VALDAF)
	Help(" ",1,"A070OBVC") // Para padroes do Tipo Objetivo ‚ obrigatorio o
								  // preenchimento do campo Validade da Calibracao.
	lRet := .F.
EndIf

If Upper(M->QM3_TIPPAD) $ "O|S" .and. empty(M->QM3_ESPEC)
	Help(" ",1,"A070OBVN") // Para padroes do Tipo Objetivo ou subjetivo ‚ 
								  // obrigatorio o preenchimento do campo Valor Nominal.
	lRet := .F.
EndIf

If Upper(M->QM3_TIPPAD) $ "O|S" .and. empty(M->QM3_UNIMED)
	Help(" ",1,"A070OBUM") // Para padroes do Tipo Objetivo ou subjetivo ‚ 
								  // obrigatorio o preenchimento do campo Unidade de Medida
	lRet := .F.
EndIf

If !QMA070PAva(M->QM3_DATREV,M->QM3_PADRAO)
	lRet := .F.
EndIf    

If !QMTR060Val(M->QM3_PADRAO,M->QM3_REVPAD) // Existe  uma revisao maior que a atual?
	MsgAlert(STR0026) 
	lRet := .F.
EndIf


Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QMA070PAva³ Autor ³ Cicero Cruz           ³ Data ³ 13/05/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida data de inclusao da revisao,maior que a data da revi-³±±
±±³          ³ sao anterior.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QMA070PAva(ExpD1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data da Revisao                                     ³±±
±±³          ³ ExpC1 = Padrao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA070                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QMA070PAva(dData,cPad)
Local lRet :=.T.
Local aArea	:= GetArea()

dbSelectArea("QM3")
dbSetOrder(1)
If DBSeek(xFilial("QM3")+cPad)
	If QM3->QM3_DATREV > dData
		MsgAlert(STR0025) 
		lRet:=.F.
	Endif
EndIf 

RestArea( aArea )
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QMA070UltR³ Autora³ Iuri Seto             ³ Data ³ 28/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a ultima revisao do padrao enviando como parametro.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QMA070UltR(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do padrao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QMA070UltR(cPadrao)
Local  cRevisao 	:= ""            
Local  cAlias	:= Select()
Local  nOrdem	:= IndexOrd()
Local  nRegis 	:= RECNO()

DbSelectArea("QM3")
DbSetOrder(1)
If QM3->(DbSeek(xFilial("QM3")+cPadrao))
	cRevisao := QM3->QM3_REVPAD
EndIf

DbSelectArea(cAlias)
DbSetOrder(nOrdem)
DbGoto(nRegis)
Return(cRevisao)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QMA070Cal ³ Autora³ Iuri Seto             ³ Data ³ 13/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a rev. do padrao ja foi utilizada na calibracao³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA070													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMA070Cal(cPadrao,cRevPad)
Local  	lRet	:= .F.
Local 	cIndice := CriaTrab(NIL,.F.)
Local 	cChave 	:= "QM7_FILIAL+QM7_PONTO+QM7_REVPAD"   
Local 	cExpr	:= "QM7_FILIAL == '" + xFilial('QM7') + "' .And. QM7_PONTO == '" + cPadrao + "' .And. QM7->QM7_REVPAD == '" + cRevPad + "'"
Local    nIndice := 0
Local 	cIndiceQMT	:= ""
Local 	cChaveQMT	:= ""   
Local 	cExprQMT	:= ""
Local    nIndiceQMT	:= 0

IndRegua("QM7",cIndice,cChave,,cExpr,,.F.)
nIndice := RetIndex("QM7")
dbSetOrder(nIndice+1)
dbGoTop()  
If !Eof()
	lRet := .T.
Endif

dbSelectArea("QM7")
RetIndex("QM7")                      
Set Filter to
Ferase(cIndice + OrdBagExt())
QM7->(DbSetOrder(1))
QM7->(DbGoTop())

If !lRet
	cIndiceQMT = CriaTrab(NIL,.F.)
	cChaveQMT 	:= "QMT->QMT_FILIAL+QMT->QMT_PADRAO+QMT->QMT_REVPAD"   
	cExprQMT	:= "QMT->QMT_FILIAL == '" + xFilial('QMT') + "' .And. QMT->QMT_PADRAO == '" + cPadrao + "' .And. QMT->QMT_REVPAD == '" + cRevPad + "'"
	IndRegua("QMT",cIndiceQMT,cChaveQMT,,cExprQMT,,.F.)
	nIndiceQMT := RetIndex("QMT")
	dbSetOrder(nIndiceQMT+1)
	dbGoTop()  
	If !Eof()
		lRet := .T.
	Endif
	dbSelectArea("QMT")
	RetIndex("QMT")                      
	Set Filter to
	Ferase(cIndiceQMT + OrdBagExt())
	QMT->(DbSetOrder(1))
	QMT->(DbGoTop())
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT070grv ºAutor  ³Denis Martins       º Data ³  11/19/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza gravacao dos campos tolerancia maxima e minima quan-º±±
±±º          ³do os mesmos nao sao digitados.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA070                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT070grv()
Local  cVlrs := ""

RecLock("QM3",.F.)
			
If Empty(QM3->QM3_TOLER) .and. !Empty(QM3->QM3_ESPEC)
	cVlrs := StrTran(Str(0,Len(QM3->QM3_ESPEC),QA_NumDec(QM3->QM3_ESPEC)),".",",")
	Replace QM3->QM3_TOLER With cVlrs
Endif
			
If Empty(QM3->QM3_TOLMIN) .and. !Empty(QM3->QM3_ESPEC)
	cVlrs := StrTran(Str(0,Len(QM3->QM3_ESPEC),QA_NumDec(QM3->QM3_ESPEC)),".",",")
	Replace QM3->QM3_TOLMIN With cVlrs
Endif

QM3->QM3_INVRPD := Inverte(QM3->QM3_REVPAD,2)
MsUnLock()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT070EmailºAutor  ³Denis Martins       º Data ³  02/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Envia e-mail de padrao(oes) vencido(s)                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA070                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT070Email()
Local cHtml		:= " "
Local lFirst	:= .T.
Local aUsua		:= {}
Local aMsg		:= {}
Local cSubject	:= STR0023//"Importante - Aviso de Calibracao de Padroes"
Local cNomeArq	:= SubStr(DtoS(dDataBase),5,7)+".Q70"
Local nDias		:= GETMV("MV_QQTDIAS")
Local cArqInd	:= ""
Local cChave	:= ""
Local cFiltro	:= ""
Local lEncont	:= .F.
Local nOpca		:= 0
Local oMtEmail		
Local cEmails   := ""
Local oGrp
Local lFecha	:= .F.
Local oEmail 
Local cNomMail 	:= CriaVar("QAA_EMAIL",.F.)
Local ni		:= 0
Private nHdl	:= 0
Private TRB_PADRAO	:= ""
Private TRB_VALDAF	:= ""
Private TRB_REVPAD	:= ""
Private nBytesTxt	:= 0
Private nCurrent	:= 0
Private nTamTxt		:= 0 
Private nFilePosTxt	:= 0
Private cBufTxt		:= ""
Private lAchou		:= .F.
Private cTpMail		:= ""	
//Deleta arquivos anteriores - Vinte Arquivos anteriores
For ni := 1 to 20
	If File(SubStr(DtoS(dDataBase-ni),5,7)+".Q70")
		FErase(SubStr(DtoS(dDataBase-ni),5,7)+".Q70")
	Endif  
Next

//Cria arquivo com data
If File(cNomeArq)
	nHdl := FOpen( cNomeArq, FO_READWRITE+FO_SHARED ) 
Else	
	nHdl := FCreate( cNomeArq, FC_NORMAL ) 
Endif		


DbSelectArea("QM3")
DbSetOrder(1)            
//Lay-out do Cliente
//MV_QQTDIAS - Quantidade de dias a serem considerados no aviso do e-mail
//Ponto de Entrada para tratamento de lay-out de cliente...
If ExistBlock("QMT070Mai")
	ExecBlock("QMT070Mai",.F.,.F.,{QM3->QM3_PADRAO,QM3->QM3_REVPAD,QM3->QM3_VALDAF})
Else
	cQuery := "SELECT QM3.QM3_FILIAL,QM3.QM3_PADRAO,QM3.QM3_REVPAD,QM3.QM3_VALDAF"
	cQuery += " FROM " + RetSqlName("QM3") +" QM3 "
	cQuery += " WHERE QM3.QM3_FILIAL = '"	+ xFilial("QM3") + "' AND "
	cQuery += " QM3.QM3_VALDAF >= '" + DtoS(dDataBase-nDias) + "' AND " 
	cQuery += " QM3.QM3_VALDAF <= '" + DtoS(dDataBase) + "' AND " 
	cQuery += " QM3.D_E_L_E_T_<>'*' "
	cQuery += " ORDER BY QM3.QM3_FILIAL,QM3.QM3_PADRAO,QM3.QM3_REVPAD"			

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)

	TcSetField("TRB","QM3_VALDAF","D",8,0)

	dbSelectArea("TRB")

	dbGoTop()
	While !Eof()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validação do Padrão a ser enviado.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TRB_PADRAO	:= TRB->QM3_PADRAO
	TRB_REVPAD	:= TRB->QM3_REVPAD
	TRB_VALDAF	:= TRB->QM3_VALDAF

	If QMTR060Val(TRB_PADRAO,TRB_REVPAD)	
	        	
		If lFirst
			cEmails := CriaVar("QAA_MAT",.F.)
			DEFINE MSDIALOG oDlg TITLE STR0010 FROM 9,0 TO 25,50 OF oMainWnd //"Padrao(oes)"
			@ 6,53 SAY STR0011 SIZE 189,8 COLOR CLR_HRED OF oDlg PIXEL		
			@ 17,2	Group oGrp TO 49,197 LABEL STR0012 COLOR CLR_BLUE OF oDlg PIXEL	//Padroes Vencidos
			@ 24,12 SAY STR0013 SIZE 189,8 OF oDlg PIXEL //Existe padrao vencido que necessita ser aferido
			@ 31,12 SAY STR0014 SIZE 189,8 OF oDlg PIXEL //"Por favor, informe o responsavel para envio de e-mail contendo tal(is) "
			@ 37,12 SAY STR0015 SIZE 200,8 OF oDlg PIXEL // padrao(oes)	
			@ 51,2	Group oGrp TO 100,197 LABEL STR0016 COLOR CLR_BLUE OF oDlg PIXEL //"Responsavel"
			@ 70,7 SAY STR0016+": " SIZE 52,8 OF oDlg PIXEL
			@ 70,44 MSGET oMtEmail VAR cEmails SIZE 52,8 OF oDlg PIXEL F3 "QAA"
			@ 71,99 SAY oEmail PROMPT cNomMail SIZE 200,8 COLOR CLR_BLUE OF oDlg PIXEL
			
			oMtEmail:bLostFocus := {|| If(!Empty(cEmails),(cNomMail := QMT070PeMail(@cEmails),oEmail:SetText(cNomMail),oEmail:Refresh()),.T.)}
			
			DEFINE SBUTTON FROM 104,123	TYPE 1 ENABLE OF oDlg PIXEL ACTION (nOpca := 1,lFecha := .T.,cNomMail := QMT070PeMail(@cEmails),oEmail:SetText(cNomMail),oEmail:Refresh(),If(!Empty(cNomMail),oDlg:End(),.F.))
			DEFINE SBUTTON FROM 104,158	TYPE 2 ENABLE OF oDlg PIXEL ACTION (nOpca := 2,lFecha := .T.,oDlg:End())
			
			ACTIVATE MSDIALOG oDlg VALID lFecha CENTERED 
			
		Endif
	
		If nOpca == 2
	
			dbSelectArea("TRB")
			dbCloseArea()
			DbSelectArea("QM3")
			DbSetOrder(1)            			
			Return .F.	 
	    Endif         
	    
		If nHdl > 0
			nTamTxt := FSEEK( nHdl, 0, FS_END ) //Verifica o tamanho do arquivo
			FSEEK( nHdl, 0 ) //Seta o FSeek para inicio do arquivo 
       	
			nCurrent := 21 //Tamanho da Linha Instrumento + Responsavel 
        	
			While( nCurrent <= nTamTxt )
				nFilePosTxt := FSEEK( nHdl, 0, FS_RELATIVE )
				cBufTxt     := FREADSTR( nHdl, nCurrent )
				nBytesTxt   := AT( TRB_PADRAO+" "+TRB_REVPAD, cBufTxt )				
		    	
				If nBytesTxt > 0
					lAchou	:= .T.
					Exit
				Else
					lAchou	:= .F.	
				Endif  	
					nCurrent += 21
				Loop
			Enddo
		Endif

		//Realiza Gravacao
		If !lAchou
			FWrite( nHdl, TRB_PADRAO+" "+TRB_REVPAD) 
			FWrite( nHdl, Chr(13)+Chr(10))				
    	Endif
		If lFirst
			lEncont := .T.
			If Alltrim(cTpMail) == "1" //Se For HTML
				cHtml :='<html>'
				cHtml +='<head>' 
				cHtml +='<body>'
				cHtml +='<p></p>'					
				cHtml +='<table borderColor="#0099cc" height="29" cellSpacing="1" width="679" borderColorLight="#0099cc" border="1">'
				cHtml +='  <tr>'
				cHtml +='    <td borderColor="#0099cc" borderColorLight="#0099cc" align="left" width="640" bgColor="#0099cc" borderColorDark="#0099cc" height="1">'
				cHtml +='    <p align="center"><font face="Courier New" color="#ffffff" size="4"><b>'+STR0017+'</b></font></td>' //"* * * Relacao de Padroes a ser(em) calibrado(s) * * *"
				cHtml +='  </tr>'
				cHtml +='</table>' 
				cHtml +='<p align="center">&nbsp;</p>'
				
				cHtml +='<p align="justify"><font face="Arial">'+STR0018+QAA->QAA_NOME+","+'</font></p>' //"Sr. "
				cHtml +='<p align="justify"><font face="Arial">'+STR0019+'</font></p>' //"Segue relacao de padrao(oes) a ser(em) calibrado(s)."
				cHtml +='<p align="justify">&nbsp;</p>'
				cHtml +='<table borderColor="#0099cc" height="29" cellSpacing="1" width="679" borderColorLight="#0099cc" border="1">'
				cHtml +='  <tr>'
				cHtml +='    <td width="333">'
				cHtml +='	    <p align="center"><b><i>'+STR0010+'</i></b></td>' //"Padrao(oes)"
				cHtml +='    <td width="333">'
				cHtml +='	    <p align="center"><b><i>'+Alltrim(TitSx3("QM3_VALDAF")[1])+'</i></b></td>'
				cHtml +='  </tr>'
				cHtml +='</table>'
				cHtml +='	<p align="center">&nbsp;</p>'
				cHtml +='	<table borderColor="#0099cc" height="29" cellSpacing="1" width="679" borderColorLight="#0099cc" border="1">'
				cHtml +='	  <tr>'
				cHtml +='    	<td width="333" align="center">'+TRB_PADRAO+'</td>' 
				cHtml +='	    <td width="333" align="center">'+SubStr(DtoS(TRB_VALDAF),7,2) + "/" +SubStr(DtoS(TRB_VALDAF),5,2) + "/" + SubStr(DtoS(TRB_VALDAF),1,4)+'</td>'
				cHtml +='	  </tr>'
				cHtml +='	</table>'
				lFirst := .F.
			Else
				cHtml :=STR0017+Chr(13)+Chr(10)+Chr(13)+Chr(10)  //* * * Relacao de Padrao(oes) a ser(em) calibrado(s) * * *
				cHtml +=STR0018+QAA->QAA_NOME+","+Chr(13)+Chr(10) //"Sr." 
				cHtml +=STR0019+Chr(13)+Chr(10)  //"Segue relacao de padrao(oes) a ser(em) calibrado(s)."
				cHtml +=Chr(13)+Chr(10)
				cHtml +=Chr(13)+Chr(10)
				cHtml +=STR0010+" - "+STR0020+"..............."+Chr(13)+Chr(10) //"Padrao(oes) - Data de Calibracao"
				cHtml +=TRB_PADRAO+".........."+SubStr(DtoS(TRB_VALDAF),7,2) + "/" +SubStr(DtoS(TRB_VALDAF),5,2) + "/" + SubStr(DtoS(TRB_VALDAF),1,4)+Chr(13)+Chr(10)
				lFirst := .F.
			Endif
		Else
			If Alltrim(cTpMail) == "1" 
				cHtml +='<table borderColor="#0099cc" height="29" cellSpacing="1" width="679" borderColorLight="#0099cc" border="1">'
				cHtml +='	  <tr>'
				cHtml +='    	<td width="333" align="center">'+TRB_PADRAO+'</td>' 
				cHtml +='	    <td width="333" align="center">'+SubStr(DtoS(TRB_VALDAF),7,2) + "/" +SubStr(DtoS(TRB_VALDAF),5,2) + "/" + SubStr(DtoS(TRB_VALDAF),1,4)+'</td>'
				cHtml +='	  </tr>'
				cHtml +='	</table>'      
			Else
				cHtml +=TRB_PADRAO+".........."+SubStr(DtoS(TRB_VALDAF),7,2) + "/" +SubStr(DtoS(TRB_VALDAF),5,2) + "/" + SubStr(DtoS(TRB_VALDAF),1,4)+Chr(13)+Chr(10)			
			Endif
		Endif           
	EndIf
			
		dbSelectArea("TRB")			
		dbSkip()
	
	Enddo
	//Garante o ultimo registro...
	If Eof() .and. lEncont
		If Alltrim(cTpMail) == "1"
			cHtml +='</body>'
			cHtml +='</html>'
		Endif
		aMsg:= { { cSubject,cHtml, "" } }     		                                              
		aadd(aUsua,{ QAA->QAA_NOME,Trim(cNomMail),aMsg })
		QaEnvMail(aUsua,,,,)
		aUsua := {}
	Endif
		
	dbCloseArea()
	dbSelectArea("QM3")				
	dbSetOrder(1)
Endif  
Return                
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT070PeMailºAutor  ³Microsiga           º Data ³  07/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica/Retorna o e-mail do responsavel escolhido            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Codigo do Usuario                                           	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³QMTA070                                                   	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT070PeMail(cEmails)

Local cNomMail := CriaVar("QAA_EMAIL",.f.)

dbSelectArea("QAA")
dbSetOrder(1)
If dbSeek(xFilial("QAA")+cEmails)
	If !Empty(QAA->QAA_EMAIL) //Se nao existir e-mail avisar usuario
		cNomMail:= Alltrim(QAA->QAA_EMAIL)
		cTpMail := QAA->QAA_TPMAIL
	Else
	    MessageDlg(STR0021,,3)	 //"Nao existe e-mail cadastrado para esse usuario"
        cNomMail := CriaVar("QAA_MAT",.F.)	
        Return Nil
	Endif	
Else
    MessageDlg(STR0022,,3) //"Usuario nao cadastrado..."
    cNomMail := CriaVar("QAA_MAT",.F.)	
	Return Nil    
Endif
Return cNomMail	   

/*/{Protheus.doc} FQMTA070
Função que valida a existencia de aspas simples no campo Padrão 
@type function
@version  
@author thiago.rover
@since 15/04/2021
@return return_type, return_description
/*/
Static Function FQMTA070()
Local lRet := .T.
Local nI   := 0

	If At('??',M->QM3_PADRAO) != 0 // Foi identificado que com duas interrogações, ocorre erro na geração de querys
		lRet := .F.  
	Else
		For nI:= 1 to len(M->QM3_PADRAO)
			If cValTOChar(ASC(Substr(M->QM3_PADRAO,nI,1)) ) $ '37|39' // ASC(" ' ") Aspas simples
				lRet := .F.  
				exit
			EndIf
		Next nI
	EndIf
	
	If !lRet
		Help("", 1, STR0027, NIL, STR0028, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0029}) //#"ATENÇÃO" //#"Foi digitado algum caracter de controle" //#"Utilize outro caracter, evite aspas simples, caracteres especiais e operadores"
		Return .F. 
	EndIf

Return .T.
