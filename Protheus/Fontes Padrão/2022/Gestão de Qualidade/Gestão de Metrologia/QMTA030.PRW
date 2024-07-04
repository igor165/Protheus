#INCLUDE "QMTA030.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QMTA030	³ Autor ³ Wanderley Goncalves Jr³ Data ³ 12/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Familia de Instrumentos 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³	MOTIVO DA ALTERACAO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Denis Martins ³04/12/00³Verif.³Consistir inclusao de escalas ao instru-³±±
±±³              ³        ³      ³mento. Qdo existir escala calibrador so-³±±
±±³              ³        ³      ³mente aceitar escala calibrador e cali- ³±±
±±³              ³        ³      ³brador completo. E qdo existir escala de³±±
±±³              ³        ³      ³tipo diferente de calibrador/completo   ³±±
±±³              ³        ³      ³nao permitir inclusao de escalas calibra³±±
±±³              ³        ³      ³dor/completo.                           ³±±
±±³Denis Martins ³14/12/00³006054³Nao permitir delecao de escalas que es- ³±±
±±³              ³        ³      ³tejam associadas a familia e que conte- ³±±
±±³              ³        ³      ³nham medicoes.                          ³±± 
±±³Denis Martins ³19/01/01³Melhor³Acerto de uso da funcao MsUnlock() nas  ³±±
±±³              ³        ³      ³funcoes Inclusao e Delecao.             ³±±
±±³Denis Martins ³06/02/01³Melhor³Acerto de uso do Begin Transaction nas  ³±±
±±³              ³        ³      ³funcoes Inclusao e Alteracao(Lock;Unlock³±± 
±±³              ³        ³      ³quando o parametro MV_TTS esta ativo.   ³±±
±±³Denis Martins ³30/01/02³12891 ³Permitir inclusao de mais de 99 itens na³±±
±±³              ³        ³      ³associacao de escalas no cadastro de fa-³±± 
±±³              ³        ³      ³milias.                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()

Local aRotina := {{OemToAnsi(STR0001),"AxPesqui"  , 0 , 1,,.F.},;   // "Pesquisar"
					{OemToAnsi(STR0002),"AxVisual"  , 0 , 2},;   // "Visualizar"
					{OemToAnsi(STR0003),"A030ITpo"  , 0 , 3},;   // "Incluir"
					{OemToAnsi(STR0004),"A030ITpo"  , 0 , 4},;   // "Alterar"
					{OemToAnsi(STR0005),"A030DTpo"  , 0 , 5, 3}} // "Excluir"

If nModulo == 22 .or. nModulo == 99 // Metrologi
	AAdd(aRotina,{STR0014,"A030Radio"  , 0 , 4})    // "associa‡”es"
EndIf

Return aRotina

Function QMTA030

Local aRotAdic   := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis 											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private  aCRA := { OemToAnsi(STR0007), OemToAnsi(STR0008), OemToAnsi(STR0009) }  //"Confirma" ### "Redigita" ### "Abandona"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes				  	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private  cCadastro := OemtoAnsi(STR0006)  //"Fam¡lia de Instrumento"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa 	  ³
//³ ----------- Elementos contidos por dimensao ------------	  ³
//³ 1. Nome a aparecer no cabecalho 							  ³
//³ 2. Nome da Rotina associada									  ³
//³ 3. Usado pela rotina										  ³
//³ 4. Tipo de Transa‡„o a ser efetuada							  ³
//³	 1 - Pesquisa e Posiciona em um Banco de Dados				  ³
//³	 2 - Simplesmente Mostra os Campos							  ³
//³	 3 - Inclui registros no Bancos de Dados					  ³
//³	 4 - Altera o registro corrente								  ³
//³	 5 - Remove o registro corrente do Banco de Dados			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private  aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
//³ Ponto de entrada - Adiciona rotinas ao aRotina       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QM030ROT")
	aRotAdic := ExecBlock("QM030ROT", .F., .F.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE									 		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"QM1")

Set Key VK_F12 To


Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A030ITpo ³ Autor ³ Wanderley Gonalves Jr ³ Data ³ 18/12/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Familias - Inc/Alt              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A070ITpo(ExpC1,ExpN1,ExpN2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA030                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³	MOTIVO DA ALTERACAO			  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Iuri Seto     ³31/08/00³ 5095 ³Gerar nova revisao ao alterar uma escala³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

FUNCTION A030ITpo(cAlias,nReg,nOpc)
Local  nOpcA:=0
Local  bCampo := {|nCPO| Field(nCPO) }
Local  i
Private  cProUti := ""
Private  cProCal := ""	
Private  cPrLocal := ""
Private  cPrValid:= ""
Private  cPrDist := ""	
Private  cPrRDist:= ""  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private  aTELA[0][0],aGETS[0]
Private cURQM1 := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia para processamento dos Gets          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nOpcA:=0

if nOpc == 3  // Inclusao
	nOpcA:=AxInclui( cAlias, nReg, nOpc, , , ,"Qmt030TdOk()",,"Qmt030Grv()")
elseif nOpc == 4  // Alteracao
	cURQM1 := QMA030UltR(QM1->QM1_TIPO)
    If QM1->QM1_REVTIP <> cURQM1
		HELP(" ",1,"QMTALTREV") // Nao e possivel alterar esta revisao. Somente a ultima revisao pode ser alterada.
    Else
		If !QMA030Cal(QM1->QM1_TIPO,QM1->QM1_REVTIP)
			nOpcA:=AxAltera( cAlias, nReg, nOpc, , , , ,"Qmt030TdOk()","Qmt030Grv()")
		Else		
			For i := 1 TO FCount()
				dbSelectArea("QM1")
				If Alltrim(M->(EVAL(bCampo,i))) == "QM1_PROUTI"
					cProUti := FieldGet(i)
				ElseIF Alltrim(M->(EVAL(bCampo,i))) == "QM1_PROCAL" 
					cProCal := FieldGet(i)
				ElseIF Alltrim(M->(EVAL(bCampo,i))) == "QM1_LOCAL"
					cPrLocal  := FieldGet(i)
				ElseIF Alltrim(M->(EVAL(bCampo,i))) == "QM1_VALID"			
					cPrValid := FieldGet(i)
				ElseIF Alltrim(M->(EVAL(bCampo,i))) == "QM1_DISTR"
					cPrDist := FieldGet(i)
				ElseIF Alltrim(M->(EVAL(bCampo,i))) == "QM1_RDISTR"
					cPrRDist := FieldGet(i)
				Endif
			Next i
			nOpcA:=AltRevisao( cAlias, nReg, nOpc, , , , ,"Qmt030TdOk()","Qmt030Rev()","QM1_DESCR")
		EndIf
	EndIf
Endif

Return(Nil)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A030DTpo ³ Autor ³ Wanderley Goncalves Jr³ Data ³ 14/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de exclusao de Familia de Instrumentos - Delecao  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A120DTpo(ExpC1,ExpN1,ExpN2)						  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo							  		  ³±±
±±³			 ³ ExpN1 = Numero do registro 						  		  ³±±
±±³			 ³ ExpN2 = Opcao selecionada					  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA030									  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION A030DTpo(cAlias,nReg,nOpc)
Local  nOpcA //,nCntDele := 0 ,cCod ,aAC := { OemToAnsi(STR0009),OemToAnsi(STR0007) }	//"Abandona"###"Confirma"
Local  oDlg
Local cIndice	:= ""
Local cChvQPT	:= ""
Local cQuery	:= ""
Local lApgQPT	:= .T.	
Local nIndice
Local lDelQIEP	:= GetMv("MV_QAPQIEP") == "1"
Local lRet		:= .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo					 	  	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private  aTELA[0][0],aGETS[0]

While .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para processamento dos Gets		   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	nOpcA:=0
	dbSelectArea(cAlias)

	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
		nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0010))  //"Quanto a exclus„o?"
		nOpca := 1
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})
//	dbSelectArea(cAlias)

	IF nOpcA == 2
		If QM1->QM1_REVTIP <> QMA030UltR(QM1->QM1_TIPO)
			HELP(" ",1,"QMTDELREV") // Nao e possivel excluir esta revisao. Somente a ultima revisao pode ser excluida.
		ElseIf QMA030Cal(QM1->QM1_TIPO,QM1->QM1_REVTIP)
			HELP(" ",1,"QMTADELREM") // Nao e possivel excluir esta revisao, pois existem medicoes cadastradas.
		Else
			//Verificar se existe familia cadastrada com padroes secundarios...
						
			cIndice := CriaTrab(NIL,.F.)
			cChvQPT := "QMH_FILIAL+QMH_PADSEC"
			cQuery  := "QMH_FILIAL=='"+xFilial("QMH")+"'.And."
			cQuery  += "QMH_PADSEC =='"+QM1->QM1_TIPO+"'"
                		
			IndRegua("QMH",cIndice,cChvQPT,,cQuery,OemToAnsi(STR0023)) // Selecionando Registros. . .
			nIndice := RetIndex("QMH")
			dbSetOrder(nIndice+1)
			dbGoTop()  						
			
			If QMH->(!Eof())
				HELP(" ",1,"A030FAMPAD")                                                                                          
				lRet := .F.				
			Endif
			
			Ferase(cIndice + OrdBagExt())											
			
			If lRet
				dbSelectArea("QMK")
				dbSetOrder(1)
				If dbSeek(xFilial()+QM1->QM1_TIPO+Inverte(QM1->QM1_REVTIP) )
					HELP(" ",1,"A030DTPO") // Nao ‚ possivel excluir esta Fam¡lia, pois
											 // existem escalas associadas a ela.
					Loop
				Else    
					dbSelectArea("QM2")
					QM2->(dbSetOrder(2))
					IF QM2->(dbSeek(xFilial("QM2")+QM1->QM1_TIPO))
						HELP(" ",1,"A030DTPI") // Nao e possivel excluir esta Familia, pois esta associada a um instrumento.
						Loop
					Else	  	
						//Verifica se tem incerteza do tipo B associado...
						dbSelectArea("QMW") 
						dbSetOrder(1)
						If dbSeek(xFilial()+QM1->QM1_TIPO+Inverte(QM1->QM1_REVTIP))
							HELP(" ",1,"A030DTQW")   // Nao ‚ possivel excluir esta Fam¡lia, pois
													 // existe(m) incerteza(s) do tipo B associada(s) a ela.
							Loop				
						Endif
						
						If lDelQIEP 
							cQuery := "SELECT QPT_FILIAL,QPT_TIPO,QPT_REVTIP"
							cQuery += " FROM " + RetSqlName("QPT")
							cQuery += " QPT WHERE QPT.QPT_FILIAL = '" + xFilial("QPT") + "' AND "
							cQuery += " QPT.QPT_TIPO = '"  + QM1->QM1_TIPO + "' AND " 
							cQuery += " QPT.QPT_REVTIP = '"  + QM1->QM1_REVTIP + "' AND " 
							cQuery += " QPT.D_E_L_E_T_<>'*' "					
	            	
							cQuery += " ORDER BY " + SqlOrder(QPT->(IndexKey()))			
					
							dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"QPTTRB", .F., .T.)
							dbSelectArea("QPTTRB")
				   	    
						   	If QPTTRB->(!Eof())
								lApgQPT := .F.	
						   	Endif           
						   	dbCloseArea()																							 	
						Endif
						If lApgQPT
							dbSelectArea("QM1")
							RecLock("QM1")
							dbDelete()
						  	MsUnlock()
						Else
							HELP(" ",1,"A030NEIRE") //Nao eh possivel a delecao desta familia pois existem amarracoes
							//com os ambientes inspecao de processo e/ou inspecao de entradas. 						 
							Loop
						Endif					  	
					Endif
				Endif
			Endif
		Endif
	Endif
	Exit

EndDo

dbSelectArea(cAlias)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A030Esca ³ Autor ³ Wanderley Goncalves   ³ Data ³ 29/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastra Escalas para Familias							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A030ESCA(ExpC1,ExpN1,ExpN2)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo									  ³±±
±±³			 ³ ExpN1 = Numero do registro 								  ³±±
±±³			 ³ ExpN2 = Opcao selecionada no menu						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA030													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Iuri Seto ³ 14/08/00 ³Gera rev.instr. se escala da familia for alterada³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION A030Esca(cAlias,nReg,nOpcx)

Local  nCnt := 0
Local  lGravaOk := .T.

Local  oDlg
Local  oSay1
Local  oSay2
Local  oRad1
Local  nRad1
Local  lIncEs := .F.
Local  cAtREsc := GetMV("MV_QATUESC")
Private  oGet // GetDados
Private  nOpca:=0
Private  nPos := 0   
Private  lAltEs := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ha' escalas ja' existentes para a Familia de instrumento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QMK")
dbSetOrder(1) 
dbSeek( xFilial()+QM1->QM1_TIPO+Inverte(QM1->QM1_REVTIP) )

cSeek  := QMK->QMK_FILIAL+QMK->QMK_TIPO+Inverte(QMK->QMK_REVTIP)
cWhile := "QMK->QMK_FILIAL+QMK->QMK_TIPO+Inverte(QMK->QMK_REVTIP)"

While !EOF() .And.;
		QMK->QMK_FILIAL+QMK->QMK_TIPO+QMK->QMK_REVTIP ==;
		xFilial()+QM1->QM1_TIPO+QM1->QM1_REVTIP
	nCnt++
	dbSkip()
End

If nCnt > 0
	FillGetDados(nOpcX,"QMK",1     ,cSeek ,{|| &cWhile},         ,         ,          ,        ,      ,        ,       ,          ,        ,          ,           ,            ,)
  //FillGetDados(nOpcX,Alias ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
Else
	FillGetDados(nOpcX,"QMK",1     ,      ,             ,         ,         ,          ,        ,      ,        ,  .T.  ,          ,        ,          ,           ,            ,)
  //FillGetDados(nOpcX,Alias ,nOrdem,cSeek  ,bSeekWhile   ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica qual a posicao do campo ESCALA no Header 		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMK_ESCALA" })

nUsado := Len(aHeader)

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0013) From 9,0 To 28,80 OF oMainWnd	 // "Fam¡lia"

oDlg:lMaximized := .F.

@ 1.1 , .5	SAY OemToAnsi(STR0013)		//"Fam¡lia"
@ 1.1 , 4	SAY QM1->QM1_TIPO+QM1->QM1_REVTIP

oGet := MSGetDados():New(41,5,130,315,nOpcx,"Qmt030lOk","Qmt030TOk",,.T.,,,,999)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(oGet:TudoOk(),(nOpca:=1,qmt030esc(oDlg)),nOpca:=0)},{||nOpca := 0,oDlg:End()}) CENTERED

If nOpcA == 1      
	A030AltEs(@lIncEs,@lAltEs)		     
	If lAltEs	// Se alterou alguma escala
		DEFINE MSDIALOG oDlg FROM 58,1 TO 260,413 TITLE STR0014 PIXEL  //"Associacoes"
	  	@ 003, 005 GROUP oGrp1 TO 080, 202 LABEL "" OF oDlg  PIXEL
		@ 010, 015 SAY oSay1 PROMPT STR0016+OemToAnsi(Alltrim(QM1->QM1_TIPO))+"." OF oDlg PIXEL SIZE 180,35 //"Houve alteracao na associacao das escalas e os instrumentos da familia deverao ser atualizados, isto podera ser demorado. Caso confirme, a atualizacao sera processada, depois revise as escalas dos instrumentos da familia "
		If !ExistBlock("A030Nin")
			If lIncEs	// Se incluiu alguma escala
				@ 045, 015 SAY oSay2 PROMPT STR0017 OF oDlg PIXEL SIZE 180,10 //"Para as escalas incluidas, a calibracao e obrigatoria ?"
				If cAtREsc == "2" //Default - Define o Radio Box como "Calibracao Nao Obrigatoria..."
					nRad1 := 2
				Endif
				@ 055, 015 RADIO oRad1 VAR nRad1 ITEMS STR0018,STR0019 OF oDlg PIXEL SIZE 50,10 //"Sim" ### "Nao"
			EndIF			
		Endif	
		@ 085, 115 BUTTON oBtn1 PROMPT STR0009 SIZE 44, 11 OF oDlg PIXEL ACTION (lGravaOK := .F.,oDlg:End())	//"Abandona"
		@ 085, 159 BUTTON oBtn2 PROMPT STR0007 SIZE 44, 11 OF oDlg PIXEL ACTION (lGravaOk := .T.,oDlg:End())	//"Confirma"
		ACTIVATE MSDIALOG oDlg CENTER ON INIT (oBtn2:Enable(),oBtn2:SetFocus(),oBtn2:Refresh())
	EndIf		     
	If lGravaOK
		lGravaOK := A030grves(cAlias)
		If !lGravaOK
			Help(" ",1,"A030NAOGRV")
		Else
			//Processa Gatilhos
			EvalTrigger()    
			If lAltEs
				A030AtuIns(QM1->QM1_TIPO,QM1->QM1_REVINV,If(nRad1 == 1,"S","N"))
			EndIf
		EndIf                                                 
	EndIf
Endif

dbSelectArea(cAlias)

Return nOpca


/*
antigo a030LinOk
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Qmt030lOk ³ Autor ³ Wanderley Goncalves   ³ Data ³ 29/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se a linha digitada esta' Ok para escalas          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado. 						  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Qmta030													  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Qmt030lOk(o)

Local  nx, lRet := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica qual a posicao do campo ESCALA no Header 		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMK_ESCALA" })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se deixar a ultima linha em branco, deleta a mesma ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(aCols[Len(aCols),1]) .And. n > 1
	Adel( aCols, Len(aCols) )
	ASize( aCols, Len( aCols) - 1)
	n := Len( aCols )
	oGet:oBrowse:Refresh()
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se campo escala esta' preenchido                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nx := 1 To Len(aHeader)

	If Empty(aCols[n][nx])
		If nOpca <> 1
			If Trim(aHeader[nx][2]) == "QMK_ESCALA"
				Help(" ",1,"QA_CPOOBR")
				lRet := .F.
				Exit
			Endif
		EndIf

		If !lRet
			Exit
		Endif
	Endif
Next nx

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Escala esta' cadastrada           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	If ! Empty(aCols[n][nPos])
		If ! ExistCpo("QM9",aCols[n][nPos])
			lRet := .f.
		EndIf
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A030GrvEs ³ Autor ³ Wanderley Goncalves   ³ Data ³ 29/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava as escalas por Familia de Instrumento				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA030													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A030GrvEs(cAlias)

Local  nx ,ny ,  nMaxArray := Len(aCols)   

nPos := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMK_ESCALA" })

dbSelectArea("QMK")
dbSetOrder(01)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o arquivo QMK 	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Begin Transaction
For nX := 1 to nMaxArray
	If ! Empty(aCols[nX][nPos]) // Cod. Escala nao vazio
		If !Acols[nX][nUsado+1] // Nao esta deletado
			If dbSeek(xFilial() + QM1->QM1_TIPO + Inverte(QM1->QM1_REVTIP) + aCols[nX][nPos])
				RecLock("QMK",.F.)   // Lock
			Else
				RecLock("QMK",.T.)   // Append
			Endif
			For ny := 1 to Len(aHeader)
				If aHeader[ny][10] # "V"
					cVar := Trim(aHeader[ny][2])
					Replace &cVar. With aCols[nx][ny]
				Endif
			Next ny
			QMK->QMK_TIPO	 := QM1->QM1_TIPO
			QMK->QMK_REVTIP := QM1->QM1_REVTIP
			QMK->QMK_FILIAL := xFilial("QMK")
			QMK->QMK_REVINV := Inverte(QM1->QM1_REVTIP)
         	MsUnlock()
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cancela o padrao no QMK				  	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If dbSeek(xFilial() + QM1->QM1_TIPO + Inverte(QM1->QM1_REVTIP) + aCols[nX][nPos])
				RecLock("QMK",.F.)
				dbDelete()  
				MsUnlock()
			EndIf
		EndIf
	EndIf
Next nx
End Transaction
Return .T. 

/*
antigo A030VlEs
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt030VlEs³ Autor ³ Wanderley Goncalves   ³ Data ³ 05/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo de Escala									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA030 - E' chamada no X3_VALID do cpo. QMK_ESCALA - SX3  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt030VlEs(lCadas)
Local  lCalib := .f.,lRetu := .t., nI,;
		cVar := &(readvar()) // Conteudo da variavel do campo Escala
Local  lCalibA := .f.,lCalibB := .f. //Verificar se alguma escala no Acols pertence a Calibrador
Local  lExtCal:= .F. 	  
Default lCadas := .F.				
                     
If lCadas                 
	nPos := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMR_ESCALA" })
Else
	nPos := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMK_ESCALA" })
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se mudou a Escala (Alterou o campo ja' digitado)      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aCols[n][nPos]) .and. !Empty(cVar) .and. aCols[n][nPos] <> cVar
	Help(" ",1,"NAOALTERA") // Campo nao pode ser alterado
	lRetu := .f.
EndIf

If lRetu
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a Escala esta' cadastrada           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCadas
		aCols[n][nPos] := M->QMR_ESCALA
	Else
		aCols[n][nPos] := M->QMK_ESCALA	
	Endif	                     
	
	If ! ExistCpo("QM9",aCols[n][nPos])
		aCols[n][nPos] := space(16)
		If lCadas
			M->QMR_ESCALA := CriaVar("QMR_ESCALA",.T.)	
		Else
			M->QMK_ESCALA := space(16)
		Endif
		lRetu := .f.
	EndIf
EndIf

If lRetu
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Verifica se a Escala ja' existe                 ³
  	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 to len(aCols)
		If cVar == acols[nI][nPos] .and. nI <> n .and. !(acols[nI][Len(acols[nPos])])// Se ja' existir esta escala
			Help(" ",1,"A030EXIESC") // "Escala relacionada a esta Familia"
			aCols[n][nPos] := space(16)
			If lCadas                 
				M->QMR_ESCALA := CriaVar("QMR_ESCALA",.T.)
			Else
				M->QMK_ESCALA := space(16)
			Endif	
			lRetu := .f.
		EndIf
	Next nI
EndIf

If lRetu
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a Escala ja' cadastrada ‚ do tipo   ³
	//³ calibrador ou calibrador completo				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 to len(aCols)
		lCalib   := .f. 
		lExtCal := .F.
		If !aCols[nI][Len(aCols[nI])] //Se estiver diferente de deletado
			QM9->(DbSeek(xFilial("QM9")+acols[nI][nPos]))
			If QM9->QM9_TIPAFE $ '4ù8ù '
				If QM9->QM9_TIPAFE $ '4ù8' 
					lCalibA := .t. //Setar .T., ja existia na ACOLS outros tipos de escala igual ao Calibrador
					lCalib  := .t.            
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o tipo de Calibracao for Vazio e o Tipo de Orgao aferidor igual a ³
				//³Externo, podera associar a familia que tenham calibrador / calibrador³
				//³completo.                                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Empty(QM9->QM9_TIPAFE) .and. QM9->QM9_ORGAFE == "E" 
					lExtCal := .T.
				Endif	
			Else	
				lCalibB := .t. //Setar .T., ja existia na ACOLS outros tipos de escala dif. de Calibrador
			EndIf
			If lCalibA .and. !lCalib .and. !lExtCal .and. nI > 1 //Se alguma escala pertence a Calibrador
				Help(" ",1,"A030ESCCAL") // "Quando instrumento possui escala de tipo
									  // calibrador associada a ele, nÆo pode asso-
									  // ciar escalas de outros tipos a ele.
				aCols[n][nPos] := space(16)
				If lCadas
					M->QMR_ESCALA := CriaVar("QMR_ESCALA",.t.)
				Else
					M->QMK_ESCALA := space(16)
				Endif
				lRetu := .f.  
			ElseIf lCalibA .and. lCalibB .and. lCalib .and. nI > 1
				Help(" ",1,"A030DIFCAL") //Quando instrumento possui escala de tipo
				                        //diferente de calibrador associada a ele, nao podera
				                        //associar escalas de tipo calibrador.
				aCols[n][nPos] := space(16)
				If lCadas
					M->QMR_ESCALA := CriaVar("QMR_ESCALA",.t.)
				Else
					M->QMK_ESCALA := space(16)
				Endif
				lRetu := .f.  
			EndIf
		Endif
	Next nI
EndIf

Return(lRetu)

/*
antiga a030Chav
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ qmt030Chv³ Autor ³ Wanderley Goncalves   ³ Data ³ 21/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida‡Æo dos campos chave 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QmtA030 - E' chamada no X3_VALID.                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt030Chv()
Local  lRet := .T.

If ! Empty( M->QM1_TIPO ) .and. ! Empty( M->QM1_REVTIP )

	dbSelectArea("QM1")
	dbSetOrder(01)
	If dbSeek( xFilial() + M->QM1_TIPO +  Inverte(M->QM1_REVTIP) )
		Help( " ", 1, "JAGRAVADO" )
		lRet := .F.
	Endif

EndIf

Return( lRet )

/*
antigo a030TudoOk
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Qmt030TOk ³ Autor ³ Wanderley Goncalves   ³ Data ³ 22/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se toda a getdados esta' Ok                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado. 						  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA030													  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qmt030TOk(o)
Local  nI, lRet := .t.
Local  cArqInd := CriaTrab(,.F.)
Local  cArqInd2 := CriaTrab(,.F.)
Local  cChave  := ""
Local  cFiltro := ""
Local  nIndex
Local  nOrdQMK := QMK->(IndexOrd())
Local  lGeraArq := .T.,lDelArq := .F.
Local  cTipoQM1

For nI := 1 to Len(aCols)
	If ! Qmt030lOk(o)
		lRet := .f.
		Exit
	EndIf
	If lRet 
		If !Empty(aCols[nI][nPos]) // Cod. Escala nao vazio
			If aCols[nI][nUsado+1]  //Se deletado
				If lGeraArq
					lDelArq := .T.
					cTipoQM1 := QM1->QM1_TIPO          
					cChave   := "QM2_FILIAL+QM2_TIPO"
					cFiltro  := "QM2_FILIAL=='"+xFilial("QM2")+"'.And."
					cFiltro  += "QM2->QM2_TIPO=='"+cTipoQM1+"'" 
					dbSelectArea("QM2")
					IndRegua("QM2",cArqInd,cChave,,cFiltro,"Verificando Instrumentos...") 
					nIndex := RetIndex("QM2")
					dbSetOrder(nIndex+1) 
					lGeraArq := .F.
				Endif 

				QM2->(dbGoTop())
			 
				cChave2  := "QM7_FILIAL+QM7_INSTR+QM7_REVINS+QM7_ESCALA+QM7_REVESC"
				cFiltro2 := "QM7_FILIAL=='"+xFilial("QM7")+"'.And."
				cFiltro2+=  "QM7->QM7_ESCALA=='"+aCols[nI][1]+"'"
    	     
				dbSelectArea("QM7")
	         IndRegua("QM7",cArqInd2,cChave2,,cFiltro2,"Verificando Medicoes...") 
	         nIndex2 := RetIndex("QM7")			 
			 
				dbSetOrder(nIndex2+1)
				QM7->(dbGotop())

				lAltEs := .T.
	
				dbSelectArea("QM2")
				dbSetOrder(2)
				QM2->(dbSeek(xFilial("QM2")+QM1->QM1_TIPO))
				If Found() 
					While !Eof() .and. cTipoQM1 == QM1->QM1_TIPO
						dbSelectArea("QM7")       
						dbSetOrder(1)
                	QM7->(dbSeek(xFilial("QM7")+QM2->QM2_INSTR+QM2->QM2_REVINS+aCols[nI][1]))
                	If Found()
	  		 	      	MsgStop(STR0021+'" '+Alltrim(aCols[nI][1])+' "'+STR0022) //Nao e possivel deletar escala.Existem Medicoes associadas a mesma. 
                  	lRet     := .F.
                  	lAltEs   := .F.
                   	Exit
                	Endif        
                	cTipoQM1 := QM2->QM2_TIPO 
                	dbSelectArea("QM2")   
                	dbSkip()
					Enddo
				Endif   
			Endif   
		Endif
	Endif   
Next nI

If lDelArq
   RetIndex("QM2")
   dbClearFilter()
   Ferase(cArqInd+OrdBagExt()) 
   RetIndex("QM7")
   dbClearFilter()
   Ferase(cArqInd2+OrdBagExt())  
Endif

dbSelectArea("QMK")
dbSetOrder(nOrdQMK)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Mta030GrvI³ Autor ³ Wanderley Goncalves   ³ Data ³ 22/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava a revis„o invertida para o QM1 - Cad. Familias		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA030													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Mta030GrvI()
Return( Inverte( QM1->QM1_REVTIP) )

/*
antigo A030TdOk
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Qmt030TdOk³ Autor ³ Wanderley Goncalves   ³ Data ³ 18/12/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Tudook                                          	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA030													  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qmt030TdOk()
Local  lRet := .t.

If M->QM1_LOCAL  == "S"
	If empty(M->QM1_VALID)
		Help(" ",1,"A030OBVA") // Preenchimento do campo controle de validade obrigatorio
		lRet := .F.
	EndIf
		If empty(M->QM1_DISTR)
			Help(" ",1,"A030OBDD") // Preenchimento do campo Departamento de Distribuicao obrigatorio
			lRet := .F.
	EndIf
		If empty(M->QM1_RDISTR)
			Help(" ",1,"A030OBRD") // Preenchimento do campo Responsavel pela Distribuicao obrigatorio
			lRet := .F.
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ A030Radio³ Autor ³ Wanderley Goncalves Jr³ Data ³ 25.03.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta RadioGroup com selecao para Escalas/Incerteza tipo B ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A040Radio(void)		 						  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA030									  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A030Radio(cAlias,nReg,nOpcx)

Local  oDlg
Local  oRad
Local  nItem   := 1
Local  nOpc		:= 0

DEFINE MSDIALOG oDlg FROM	35,37 TO 140,280 TITLE OemToAnsi(STR0014) PIXEL //"Associa‡”es"

@ 05,05 TO 40,80 OF oDlg PIXEL

@ 13, 11 RADIO oRad VAR nItem 3D SIZE 65, 11 ;
			PROMPT OemToAnsi(STR0011),;  // "Escalas"
					 STR0015 OF oDlg PIXEL  // "Incertezas do Tipo B"

//oRAD:aItems[1]:oFont:=oDlg:oFont // Definido fonte para cada um
//oRAD:aItems[2]:oFont:=oDlg:oFont // dos itens do radio
//msgstop("Cheguei")

DEFINE SBUTTON FROM 11, 90 TYPE 1 ENABLE OF oDlg Action (nOpc:=1,oDlg:End())
DEFINE SBUTTON FROM 24, 90 TYPE 2 ENABLE OF oDlg Action (nOpc:=0,oDlg:End())

ACTIVATE MSDIALOG oDlg Centered

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso confirmar verifica qual rotina vai chamar ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 1
	If nItem == 1
		A030Esca(cAlias,nReg,nOpcx)
	Else
  		A030ITPB(cAlias,nReg,nOpcx)
	EndIf
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A030ITpB ³ Autor ³ Wanderley Goncalves   ³ Data ³ 25/03/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastra Incertezas do Tipo "B" para fam¡lias   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A030ITPB(ExpC1,ExpN1,ExpN2)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo									  ³±±
±±³			 ³ ExpN1 = Numero do registro 								  ³±±
±±³			 ³ ExpN2 = Opcao selecionada no menu						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA030													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION A030ITPB(cAlias,nReg,nOpcx)
Local  nCnt := 0
Local  nRecQMV := 0
Local  oDlg
Local  lGravaOk := .T.

Private  oGet // GetDados
Private  nOpca:=0
Private  nPos := 0
Private  nUsado := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ha' incertezas ja' existentes para a Familia de instrumento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QMW")
dbSetOrder(1)
dbSeek( xFilial()+QM1->QM1_TIPO+Inverte(QM1->QM1_REVTIP))

Private cSeek  := QMW->QMW_FILIAL+QMW->QMW_TIPO+QMW->QMW_REVINV
Private cWhile := "QMW->QMW_FILIAL+QMW->QMW_TIPO+QMW->QMW_REVINV"

While !EOF() .And.;
		QMW->QMW_FILIAL+QMW->QMW_TIPO+QMW->QMW_REVTIP ==;
		xFilial()+QM1->QM1_TIPO+QM1->QM1_REVTIP
	nCnt++
	dbSkip()
End

If nCnt > 0
	FillGetDados(nOpcX,"QMW",1     ,cSeek ,{|| &cWhile},         ,         ,          ,        ,      ,        ,       ,          ,        ,          ,           ,            ,)
  //FillGetDados(nOpcX,Alias ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
Else
	FillGetDados(nOpcX,"QMW",1     ,      ,             ,         ,         ,          ,        ,      ,        ,  .T.  ,          ,        ,          ,           ,            ,)
  //FillGetDados(nOpcX,Alias ,nOrdem,cSeek  ,bSeekWhile   ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica qual a posicao do campo CODINC no Header 		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMW_CODINC" })

nUsado := Len(aHeader)

Continua 	:= .F.
nOpca 		:= 0

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0013) From 9,0 To 28,80 OF oMainWnd	 // "Fam¡lia"

oDlg:lMaximized := .F.

@ 1.1 , .5	SAY OemToAnsi(STR0013)		//"Fam¡lia"
@ 1.1 , 4	SAY QM1->QM1_TIPO+QM1->QM1_REVTIP

oGet := MSGetDados():New(41,5,130,315,nOpcx,"Qmt030lOkb","Qmt030tOkb",,.T.)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(oGet:TudoOk(),(nOpca:=1,oDlg:End()),nOpca:=0)},{||nOpca := 0,oDlg:End()})

If nOpcA == 1
	Begin Transaction
		lGravaOk := A030grvTB(cAlias)
		If !lGravaOK
			Help(" ",1,"A030NAOGRV")
		Else
			//Processa Gatilhos
			EvalTrigger()
		EndIf
	End Transaction
Endif


dbSelectArea(cAlias)

Return nOpca

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A030GrvTP ³ Autor ³ Wanderley Goncalves   ³ Data ³ 26/03/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava as incertezas do tipo "B" por Familia de Instrumento ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA030													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A030GrvTB(cAlias)

Local  nx ,ny ,  nMaxArray := Len(aCols)  
nPos := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMW_CODINC" })

dbSelectArea("QMW")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o arquivo QMW 	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to nMaxArray
	If ! Empty(aCols[nX][nPos]) // Cod. nao vazio
		If !Acols[nX][nUsado+1] // Nao esta deletado
			If dbSeek(xFilial() + QM1->QM1_TIPO + Inverte(QM1->QM1_REVTIP) + aCols[nX][nPos])
				RecLock("QMW",.F.)   // Lock
			Else
				RecLock("QMW",.T.)   // Append
			Endif
			For ny := 1 to Len(aHeader)
				If aHeader[ny][10] # "V"
					cVar := Trim(aHeader[ny][2])
					Replace &cVar. With aCols[nx][ny]
				Endif
			Next ny
			QMW->QMW_TIPO	 := QM1->QM1_TIPO
			QMW->QMW_REVTIP := QM1->QM1_REVTIP
			QMW->QMW_FILIAL := xFilial("QMW")
			QMW->QMW_REVINV := Inverte(QM1->QM1_REVTIP)
			MsUnlock()
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cancela o codigo no QMW				  	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If dbSeek(xFilial() + QM1->QM1_TIPO + Inverte(QM1->QM1_REVTIP) + aCols[nX][nPos])
				RecLock("QMW",.F.)
				dbDelete()
				MsUnlock()
			EndIf
		EndIf
	EndIf
Next nx

Return .T.

/*
antigo a030LnOkB
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Qmt030lOkb³ Autor ³ Wanderley Goncalves   ³ Data ³ 26/03/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se a linha digitada esta' Ok para incerteza        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado. 						  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Qmta030													  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Qmt030lOkb(o)

Local  nx, lRet := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica qual a posicao do campo CODINC no Header 		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMW_CODINC" })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se deixar a ultima linha em branco, deleta a mesma ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(aCols[Len(aCols),1]) .And. n > 1
	Adel( aCols, Len(aCols) )
	ASize( aCols, Len( aCols) - 1)
	n := Len( aCols )
	oGet:oBrowse:Refresh()
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se campo escala esta' preenchido                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nx := 1 To Len(aHeader)

	If Empty(aCols[n][nx]) 
		If nOpca <> 1
			If Trim(aHeader[nx][2]) == "QMW_CODINC"
				Help(" ",1,"QA_CPOOBR")
				lRet := .F.
				Exit
			Endif
		EndIf

		If !lRet
			Exit
		Endif
	Endif
Next nx

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Codigo esta' cadastrado           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lRet
	If ! Empty(aCols[n][nPos])
		If ! ExistCpo("QMV",aCols[n][nPos])
			lRet := .f.
		EndIf
	EndIf
EndIf

Return lRet

/*
antigo a030TdOkB
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Qmt030TOkB³ Autor ³ Wanderley Goncalves   ³ Data ³ 26/03/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se toda a getdados esta' Ok                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado. 						  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA030													  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qmt030tOkb(o)
Local  nI, lRet := .t.

For nI := 1 to Len(aCols)
	If ! Qmt030lOkb(o)
		lRet := .f.
		Exit
	EndIf
Next

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt030VlIB³ Autor ³ Wanderley Goncalves   ³ Data ³ 29/03/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida codigo de Incerteza do Tipo B						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA030 - E' chamada no X3_VALID do cpo. QMW_CODINC - SX3  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT030VlIB()

Local  lRetu := .t., nI,;
		cVar := &(readvar()) // Conteudo da variavel do campo Escala
Local  nPos := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMW_CODINC" })
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se mudou a Escala (Alterou o campo ja' digitado)      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aCols[n][nPos]) .and. !Empty(cVar) .and. aCols[n][nPos] <> cVar
	Help(" ",1,"NAOALTERA") // Campo nao pode ser alterado
	lRetu := .f.
EndIf

If lRetu
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a Incerteza esta' cadastrada        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols[n][nPos] := M->QMW_CODINC
	If ! ExistCpo("QMV",aCols[n][nPos])
		aCols[n][nPos] := space(16)
		M->QMW_CODINC := space(16)
		lRetu := .f.
	EndIf
EndIf

If lRetu
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a Escala ja' existe                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 to len(aCols)
		If cVar == acols[nI][nPos] .and. nI <> n // Se ja' existir esta escala
			Help(" ",1,"A030EXITPB") // "Incerteza do tipo B relacionada a esta Familia"
			aCols[n][nPos] := space(16)
			M->QMW_CODINC := space(16)
			lRetu := .f.
		EndIf
	Next nI
EndIf

Return(lRetu)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A030AltEs ³ Autora³ Iuri Seto             ³ Data ³ 06/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se houve alteracoes nas escalas associadas        ³±±
±±³          ³ (inclusoes ou exclusoes).                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A030AltEs(ExpL1,ExpL2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 : .T. nova escala incluida, .F. nao foi incluida     ³±±
±±³          ³         nenhuma escala.                                    ³±±
±±³          ³ ExpL2 : .T. escala alterada, .F. nao foi alterada          ³±±
±±³          ³         nenhuma escala.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A030AltEs(lIncEs,lAltEs,lCad)
Local  nx , nMaxArray := Len(aCols)
Local  aColsQ := {}
Default lCad := .F.                      

nPos := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMK_ESCALA" })

If lCad
	nMaxArray := Len(aColsQMR)
	aColsQ := aClone(aColsQMR)
Else
	nMaxArray := Len(aCols)   
	aColsQ := aClone(aCols)
Endif

dbSelectArea("QMK")
dbSetOrder(1)
For nX := 1 to nMaxArray
	If ! Empty(aCols[nX][nPos]) // Cod. Escala nao vazio
		If !Acols[nX][nUsado+1] // Nao esta deletado
			If !(dbSeek(xFilial() + QM1->QM1_TIPO + Inverte(QM1->QM1_REVTIP) + aCols[nX][nPos]))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Uma nova escala foi incluida ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lIncEs := .T.				
			   	lAltEs := .T.
			   	Exit
			EndIf			   
		EndIf
	EndIf
Next nx

Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³A030AtuIns³ Autora³ Iuri Seto             ³ Data ³ 07/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera uma nova revisao do instrumento e atualiza as escalas ³±±
±±³          ³ da familia enviada como parametro.Copia da funcao QMTA020, ³±±
±±³          ³ que duplica instrumentos com modificacoes para duplicar e  ³±±
±±³          ³ e gerar nova revisao para todos os instrumentos de uma     ³±±
±±³          ³ familia.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A030AtuIns(ExpC1,ExpC2,ExpC3)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Famila do instrumento                               ³±±
±±³          ³ ExpC2: Revisao invertida de Familia                        ³±±
±±³          ³ ExpC3: Calibracao obrigatoria                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A030AtuIns(pTipo, pRevInv, pCaObri,lVerDel)
Local  bCRepQM2,bCRepQA2H,bCRepQA2I,bCRepQMG	// Atribuicao no replace
Local  bCConQM2,bCConQA2H,bCConQA2I,bCConQMG	// Condicao para o replace
Local  aArq				// Array de arquivos para duplicacao
Local  lVolta			// 
Local  cEspecI, cEspecH // Especie	 
Local  cKeyNew
Local  nCntFor
Local  cNovaRev := ""
Local  nRegistro:= 0
Local  cInstr 	:= ""
Local  cRevIns	:= ""
Local  cMemo	:= STR0020	// "Atualizacao da familia."
Local  cTolPro	:= ""
Local  cRedut	:= ""
Local  cInperm	:= ""
Local  cPrec	:= ""
Local  cCaObri	:= ""
Local  cEspecJ	:= ""
Local  cKeyJ	:= ""
Local  lEscCal	:= .F.
Local  lTemRev 	:= .F.
Local  lPesq	:= .T.
Local  nPosPesq	:= 0 
Local  nx		:= 0
Local  cAceita	:= ""
Local  nOrdQM2
Local  nRecQM2
Local  lA030Nin  := ExistBlock("A030Nin")
Local  lCompInst := ExistBlock("CompInst")
Default lVerDel	 := .T.

If !lVerDel //Cadastro de instrumento - garante integridade de array
	aCols := aClone(aColsQMR)
	lVerDel := .T.
Endif

dbSelectArea("QM2")
nOrdQM2 := QM2->(IndexOrd())
nRecQM2 := QM2->(Recno())
QM2->(dbSetOrder(2))
If QM2->(DbSeek(xFilial('QM2')+pTipo))
	Do While QM2->(!Eof()) .and. xFilial('QM2')+pTipo == QM2->QM2_FILIAL+QM2->QM2_TIPO

		If A030ChkFam(pTipo)
			
			Begin Transaction
			nRegistro := QM2->(Recno())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de Entrada responsável pela NAO GERACAO DE REVISAO³
			//³DE INSTRUMENTO                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lA030Nin
	
				cInstr		:= QM2->QM2_INSTR
				cRevIns		:= QM2->QM2_REVINS
	
		  		ExecBlock("a030Nin",.F.,.F.,{cInstr,cRevIns})
	
				dbSelectArea("QMR") 
				dbSetOrder(1)
				If dbSeek(xFilial("QMR")+cInstr+cRevIns)
					While !Eof() .and. QMR->QMR_FILIAL+QMR->QMR_INSTR+QMR->QMR_REVINS ==;
						xFilial("QMR")+cInstr+cRevIns
						dbSelectArea("QM9")
						dbSetOrder(1)
						If dbSeek(xFilial("QM9")+QMR->QMR_ESCALA)	
							If Alltrim(QM9->QM9_TIPAFE) $ "4|8"
								If Alltrim(QMR->QMR_CAOBRI) == "S"
									lEscCal := .T.	// Ja existe uma ou mais escala(s) associada ao Instrumento(QMR)
									Exit			// sempre gravar escalas calibradores/calibradores completo igual "N".
								Else
									lEscCal := .F.							
								Endif	
							Else			   
								lEscCal := .F.
							Endif      
						Endif	
						dbSelectArea("QMR")
						dbSkip()	
					Enddo	
				Endif
				dbSelectArea("QMK")
				dbSetOrder(1)
				dbSelectArea("QMR")
				dbSetOrder(1) 
				If QMK->(dbSeek(xFilial("QMK")+pTipo+pRevInv))
					Do While QMK->(!Eof()) .and. xFilial("QMK")+pTipo+pRevInv == QMK->QMK_FILIAL+QMK->QMK_TIPO+QMK->QMK_REVINV
						If QMR->(dbSeek(xFilial("QMR")+cInstr+cRevIns+QMK->QMK_ESCALA))			
							cTolPro	:= QMR->QMR_TOLPRO
							cRedut	:= QMR->QMR_REDUT
							cInperm	:= QMR->QMR_INPERM
							cPrec	:= QMR->QMR_PREC
							cCaObri	:= QMR->QMR_CAOBRI
							cAceita	:= QMR->QMR_ACEITA
						Else
							cTolPro	:= ""
							cRedut	:= ""
							cInperm	:= ""
							cPrec	:= ""             
							cCaObri	:= "N"
							cAceita	:= "75"
							dbSelectArea("QM9")
							dbSetOrder(1)
							If dbSeek(xFilial("QM9")+QMK->QMK_ESCALA)
								If Alltrim(QM9->QM9_TIPAFE) $ "4|8"
									If lEscCal 
										cCaObri	:= "N"
									Else 
										cCaObri := pCaObri
										lEscCal := .T.
									Endif	
								Else
									cCaObri := pCaObri
								Endif						
							Else
								cCaObri	:= pCaObri
							Endif	
						EndIf
						
						If QMR->(dbSeek(xFilial("QMR")+cInstr+cRevIns+QMK->QMK_ESCALA))			
							RecLock("QMR",.F.)   // Lock
						Else
							RecLock("QMR",.T.)   // Append
						Endif                 
						QMR->QMR_FILIAL	:= xFilial("QMR")
						QMR->QMR_INSTR	:= cInstr
						QMR->QMR_REVINS	:= cRevIns
						QMR->QMR_ESCALA	:= QMK->QMK_ESCALA
						QMR->QMR_TOLPRO	:= cTolPro
						QMR->QMR_REDUT	:= cRedut 
						QMR->QMR_INPERM	:= cInperm
						QMR->QMR_PREC	:= cPrec
						QMR->QMR_CAOBRI	:= cCaObri
						QMR->QMR_ACEITA	:= cAceita
			            MsUnlock()
						QMK->(DbSkip())
					EndDo
		  		Endif
	
				QM2->(dbSetOrder(2))
				QM2->(DbGoto(nRegistro))
				Do While QM2->(!Eof()) .and. xFilial('QM2')+pTipo+cInstr == QM2->QM2_FILIAL+QM2->QM2_TIPO+QM2->QM2_INSTR
					QM2->(DbSkip())
				EndDo	
				dbCommitAll()
			Else
	            dbSelectArea("QM6")
	            dbSetOrder(1)
	            If dbSeek(xFilial()+QM2->QM2_INSTR+QM2->QM2_REVINS)
					lTemRev := .T.
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Modificar Flag de Instrumento - Utilizado no Programa Movimentacao³
					//³de Instrumentos                                            	 	 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					RecLock("QM2",.F.)
					Replace QM2->QM2_FLAG With "2" 
					MsUnlock()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Inicializa Array 	            						     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aArq	  	:= {}   
					cNovaRev	:= Soma1(QM2->QM2_REVINS)
	
					cInstr		:= QM2->QM2_INSTR
					cRevIns		:= QM2->QM2_REVINS
			
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Condicoes para QA2 - Historico								 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Cria chave   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cKeyNew := QM2->QM2_FILIAL + cInstr + cNovaRev  //+'HIST'
				
					//Gera uma nova chave
					cKeyNew := Qmt010VText(.T.,"",cInstr,cNovaRev)	
					cKeyH   := QM2->QM2_CHAVE   //QA_CvKey(cKeyH)
					cEspecH := 'QMTA010H'
					bCRepQA2H := { || QA2->QA2_CHAVE   := cKeyNew }
					bCConQA2H := { || ! eof() .and. xFilial('QA2') == QA2_FILIAL .and.;
													  QA2_CHAVE == cKeyh .and.;
													  QA2_ESPEC == cEspecH }
					aadd( aArq, { 'QA2', cEspecH+cKeyH, bCRepQA2H, bCConQA2H, 1 } )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Chave para QA2 - Informacoes Complementares			 	  	 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cKeyI 	:= QM2->QM2_CHAVE    //QA_CvKey(cKeyI)
					cEspecI := 'QMTA010I'
					bCRepQA2I := { || QA2->QA2_CHAVE   := cKeyNew }
					bCConQA2I := { || ! eof() .and. xFilial('QA2') == QA2_FILIAL .and.;
														  QA2_CHAVE == cKeyI .and.;
														  QA2_ESPEC == cEspecI }
					aadd( aArq, { 'QA2', cEspecI+cKeyI, bCRepQA2I, bCConQA2I, 1 } )
					cKeyJ 	:= QM2->QM2_CHAVE    //QA_CvKey(cKeyI)
					cEspecJ := 'QMTA010S'
					bCRepQA3J := { || QA3->QA3_CHAVE   := cKeyNew }
					bCConQA3J := { || ! eof() .and. xFilial('QA3') == QA3_FILIAL .and.;
														  QA3_CHAVE == cKeyJ .and.;
														  QA3_ESPEC == cEspecJ }
					aadd( aArq, { 'QA3', cEspecJ+cKeyJ, bCRepQA3J, bCConQA3J, 1 } )
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Condicoes para QM2											 			  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					bCrepQM2:= { || QM2->QM2_INSTR	:= cInstr ,;
									 QM2->QM2_REVINS	:= cNovaRev ,;
									 QM2->QM2_REVINV  := Inverte(cNovaRev),;
									 QM2->QM2_DATREV  := dDataBase,;
									 QM2->QM2_CHAVE   := cKeyNew,; // Nova chave criada para acesso aos textos
									 QM2->QM2_FLAG    := "1" } 
	
					bCconQM2 := { || ! eof() .and. xFilial('QM2') == QM2_FILIAL .and.;
												  QM2_INSTR == cInstr .and.;
												  QM2_REVINS == cRevIns }
					aadd( aArq, { 'QM2', cInstr+Inverte(cRevIns), bCRepQM2, bCConQM2, 1} ) 
			
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Condicoes para QMG											 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					bCrepQMG:= { || QMG->QMG_INSTR	:= cInstr ,;
										 QMG->QMG_REVINS	:= cNovaRev } 
					bCconQMG := { || ! eof() .and. xFilial('QMG') == QMG_FILIAL .and.;
													  QMG_INSTR == cInstr .and.;
													  QMG_REVINS == cRevIns }
					aadd( aArq, { 'QMG', cInstr+cRevIns, bCRepQMG, bCConQMG, 1 } ) 
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Efetiva gravacao   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nCntFor := 1 to len(aArq)
						DbSelectArea(aArq[nCntFor,1])
						DbSetOrder(aArq[nCntFor,5])
						If Dbseek(xFilial()+aArq[nCntFor,2])
							Do while eval(aArq[nCntFor,4])
								lVolta := .t.
								If QA_Dupl(lVolta, aArq[nCntFor,3], aArq[nCntFor,1])
									dbSkip()
								Else
									exit
								Endif
							Enddo
						Endif	
					Next nCntFor
			    Else
					lPesq		:= .T.
					nPosPesq	:= 0 
					lTemRev 	:= .F.
					aArq	  	:= {}   
					cInstr		:= QM2->QM2_INSTR
					cRevIns		:= QM2->QM2_REVINS
					cNovaRev	:= QM2->QM2_REVINS
	
			    	//Caso tenha deletado escala(s) que nao apresentam medicoes (QM6) instrumento/revisao(QM2) retirar da
			    	//QMR
					
					If lVerDel
						If Len(aCols) > 0
							If ValType(aCols[1][2]) == "L"
								nPosPesq := ASCAN(aCols,{|x| x[2] = lPesq })
							Else
								nPosPesq := ASCAN(aCols,{|x| x[Len(x)] = lPesq })														
							Endif
						Endif					
						//Caso exista uma ou mais escalas deletadas no Acols
						
						dbSelectArea("QMR") 
						dbSetOrder(1)
		
						If nPosPesq > 0
							For nX := nPosPesq To Len(aCols)
								If aCols[nX][Len(aCols[nX])] //Se estiver deletado...
									If dbSeek(xFilial("QMR")+cInstr+cRevIns+aCols[nX][1])
										RecLock("QMR",.F.)
										dbDelete()
										MsUnLock()
									Endif	
		            	    	Endif 
			                Next nx
						Endif	  
					Endif	                
			    Endif
				dbSelectArea("QMR") 
				dbSetOrder(1)
				If dbSeek(xFilial("QMR")+cInstr+cRevIns)
					While !Eof() .and. QMR->QMR_FILIAL+QMR->QMR_INSTR+QMR->QMR_REVINS ==;
						xFilial("QMR")+cInstr+cRevIns
						dbSelectArea("QM9")
						dbSetOrder(1)
						If dbSeek(xFilial("QM9")+QMR->QMR_ESCALA)	
							If Alltrim(QM9->QM9_TIPAFE) $ "4|8"
								If Alltrim(QMR->QMR_CAOBRI) == "S"
									lEscCal := .T.	// Ja existe uma ou mais escala(s) associada ao Instrumento(QMR)
									Exit			// sempre gravar escalas calibradores/calibradores completo igual "N".
								Else
									lEscCal := .F.							
								Endif	
							Else			   
								lEscCal := .F.
							Endif      
						Endif	
						dbSelectArea("QMR")
						dbSkip()	
					Enddo	
				Endif
				dbSelectArea("QMK")
				dbSetOrder(1)
				dbSelectArea("QMR")
				dbSetOrder(1) 
				If QMK->(dbSeek(xFilial("QMK")+pTipo+pRevInv))
					Do While QMK->(!Eof()) .and. xFilial("QMK")+pTipo+pRevInv ==;
										   QMK->QMK_FILIAL+QMK->QMK_TIPO+QMK->QMK_REVINV
						If QMR->(dbSeek(xFilial("QMR")+cInstr+cRevIns+QMK->QMK_ESCALA))			
							cTolPro	:= QMR->QMR_TOLPRO
							cRedut	:= QMR->QMR_REDUT
							cInperm	:= QMR->QMR_INPERM
							cPrec	:= QMR->QMR_PREC
							cCaObri	:= QMR->QMR_CAOBRI
							cAceita := QMR->QMR_ACEITA
						Else        
							cTolPro	:= ""
							cRedut	:= ""
							cInperm	:= ""
							cPrec	:= ""             
							cAceita := "75" //Porcentagem de aceitabilidade
							dbSelectArea("QM9")
							dbSetOrder(1)
							If dbSeek(xFilial("QM9")+QMK->QMK_ESCALA)
								If Alltrim(QM9->QM9_TIPAFE) $ "4|8"
									If lEscCal 
										cCaObri	:= "N"
									Else 
										cCaObri := pCaObri
										lEscCal := .T.
									Endif	
								Else
									cCaObri := pCaObri
								Endif						
							Else
								cCaObri	:= pCaObri
							Endif	
						EndIf
	
						If QMR->(dbSeek(xFilial("QMR")+cInstr+cNovaRev+QMK->QMK_ESCALA))			
							RecLock("QMR",.F.)   // Lock
						Else
							RecLock("QMR",.T.)   // Append
						Endif                 
						QMR->QMR_FILIAL	:= xFilial("QMR")
						QMR->QMR_INSTR	:= cInstr
						QMR->QMR_REVINS	:= cNovaRev
						QMR->QMR_ESCALA	:= QMK->QMK_ESCALA
						QMR->QMR_CAOBRI	:= cCaObri				
						QMR->QMR_TOLPRO	:= cTolPro
						QMR->QMR_REDUT	:= cRedut 
						QMR->QMR_INPERM	:= cInperm
						QMR->QMR_PREC	:= cPrec
						QMR->QMR_CAOBRI	:= cCaObri
		    	        MsUnlock()
						QMK->(DbSkip())
					EndDo
	  			Endif
	
				If lTemRev 	//Grava justificativa de atualizacao de familia somente quando gerar revisao de instrumentos
					A020GvJu(cMemo,cKeyNew)
				Endif	
				
				If lCompInst
					ExecBlock("CompInst",.F.,.F.,{cInstr, cNovaRev}) // instrumento+rev atual   	    
				EndIf
				
				QM2->(dbSetOrder(2))
				QM2->(DbGoto(nRegistro))

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Altera o status da revisao anterior para (I)nativo				³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If pCaObri == 'S' .Or. Posicione("QMP",1,xFilial("QMP")+QM2->QM2_STATUS,"QMP_ATUAL") == 'S'// Verifica se a calibracao das novas faixas e obrigatoria e se atualiza Status
					RecLock("QM2",.F.)
					QM2->QM2_STATUS := "I" 
					MsUnlock()
				Endif
	        
				Do While QM2->(!Eof()) .and. xFilial('QM2')+pTipo+cInstr == QM2->QM2_FILIAL+QM2->QM2_TIPO+QM2->QM2_INSTR
					QM2->(DbSkip())
				EndDo	
				dbCommitAll()
				
			Endif
			End Transaction
			
		Else
			
			QM2->(dbSkip())
	
		Endif
		
	EndDo
	QM2->(dbSetOrder(nOrdQM2))
	QM2->(DbGoto(nRecQM2))
EndIf
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QMA030UltR³ Autora³ Iuri Seto             ³ Data ³ 31/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a ultima revisao do tipo enviando como parametro.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QMA030UltR(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do tipo(familia)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QMA030UltR(cTipo)
Local  cRevisao 	:= ""            
Local  cAlias	:= Select()
Local  nOrdem	:= IndexOrd()
Local  nRegis 	:= RECNO()

DbSelectArea("QM1")
DbSetOrder(1)
If QM1->(DbSeek(xFilial("QM1")+cTipo))
	cRevisao := QM1->QM1_REVTIP
EndIf

DbSelectArea(cAlias)
DbSetOrder(nOrdem)
DbGoto(nRegis)
Return(cRevisao)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QMA030Cal ³ Autora³ Iuri Seto             ³ Data ³ 14/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a rev da familia ja foi utilizada na calibracao³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA030									  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMA030Cal(cTipo,cRevTip)
Local  	lRet	:= .F.
Local 	cIndice := CriaTrab(NIL,.F.)
Local 	cChave 	:= "QM6_FILIAL+QM6_TIPO+QM6_REVTIP"   
Local 	cExpr	:= "QM6_FILIAL == '" + xFilial('QM6') + "' .And. QM6_TIPO == '" + cTipo + "' .And. QM6_REVTIP == '" + cRevTip + "'"

IndRegua("QM6",cIndice,cChave,,cExpr,,.F.)
nIndice := RetIndex("QM6")
dbSetOrder(nIndice+1)
dbGoTop()  

If !Eof()
	lRet := .T.
EndIf

dbSelectArea("QM6")
RetIndex("QM6")                      
Set Filter to
Ferase(cIndice + OrdBagExt())
QM7->(DbSetOrder(1))
QM7->(DbGoTop())

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QMA030DpEs³ Autora³ Iuri Seto             ³ Data ³ 15/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Duplica as escalas da familia da revisao anterior.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA030													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMA030DpEs(cRevInv)
Local  	nRegis
Local 	bCampo := {|nCPO| Field(nCPO) }
Local	i := 0
	
DbSelectArea("QMK")
DbSetOrder(1)
IF QMK->(DbSeek(xFilial("QMK")+QM1->QM1_TIPO+cRevInv))
	While !EOF() .And. xFilial("QMK")+QM1->QM1_TIPO+cRevInv ==;
		QMK->QMK_FILIAL+QMK->QMK_TIPO+QMK->QMK_REVINV
	
		FOR i := 1 TO FCount()
			M->&(EVAL(bCampo,i)) := FieldGet(i)
		NEXT i
		M->QMK_REVTIP := QM1->QM1_REVTIP
		M->QMK_REVINV := QM1->QM1_REVINV
		nRegis := Recno()							
									
		RecLock("QMK",.T.)
		For i := 1 TO FCount()
			FieldPut(i,M->&(EVAL(bCampo,i)))
		Next i
  		MsUnlock()   
	                    	
		DbGoto(nRegis)
		DbSkip()
	EndDo							
EndIf
Return(Nil)
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QMA030DpIB³ Autora³ Iuri Seto             ³ Data ³ 15/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Duplica as incertezas do Tipo B da familia da rev.anterior.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA030													  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMA030DpIB(cRevInv)
Local  	nRegis
Local 	bCampo := {|nCPO| Field(nCPO) }
Local	i := 0

DbSelectArea("QMW")
DbSetOrder(1)
IF QMW->(DbSeek(xFilial("QMW")+QM1->QM1_TIPO+cRevInv))
	While !EOF() .And. xFilial("QMW")+QM1->QM1_TIPO+cRevInv ==;
		QMW->QMW_FILIAL+QMW->QMW_TIPO+QMW->QMW_REVINV
	
		FOR i := 1 TO FCount()
			M->&(EVAL(bCampo,i)) := FieldGet(i)
		NEXT i
		M->QMW_REVTIP := QM1->QM1_REVTIP
		M->QMW_REVINV := QM1->QM1_REVINV
		nRegis := Recno()							
									
		RecLock("QMW",.T.)
		For i := 1 TO FCount()
			FieldPut(i,M->&(EVAL(bCampo,i)))
		Next i
		MsUnlock()   
	                    	
		DbGoto(nRegis)
		DbSkip()
	EndDo							
EndIf                
Return(Nil)					

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMTA030GrvºAutor  ³Denis Martins       º Data ³  02/02/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realizar gravacao do campo Revisao Invertida apos inclusao  º±±
±±º          ³da escala.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA030()                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qmt030Grv()
RecLock("QM1",.F.)
QM1->QM1_REVINV := Inverte(QM1->QM1_REVTIP,2)
MsUnlock()
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMTA030RevºAutor  ³Denis Martins       º Data ³  02/05/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Apos a alteracao e geracao da revisao, devera ser gravado osº±±
±±º          ³campos de Rev. da Familia,Rev.Invertida e Data da Revisao.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA030()                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qmt030Rev()
Local  cRevInv
cRevInv := QM1->QM1_REVINV
If Alltrim(QM1->QM1_PROUTI)	 <>	Alltrim(cProUti)	.or.;
	Alltrim(QM1->QM1_PROCAL)<>	Alltrim(cProCal)	.or.;
	Alltrim(QM1->QM1_LOCAL)	 <>	Alltrim(cPrLocal )	.or.;
	Alltrim(QM1->QM1_VALID)	<>	Alltrim(cPrValid)	.or.;
	Alltrim(QM1->QM1_DISTR)	<>	Alltrim(cPrDist)	.or.;
	Alltrim(QM1->QM1_RDISTR)<>	Alltrim(cPrRDist)
	RecLock("QM1",.F.)
	QM1->QM1_REVTIP := StrZero(Val(cURQM1)+1,2)
	QM1->QM1_REVINV := Inverte(QM1->QM1_REVTIP,2)
	QM1->QM1_DATREV := dDataBase				
	MsUnlock()
	FKCOMMIT()
	
	QMA030DpEs(cRevInv)
	QMA030DpIB(cRevInv)
	
Endif	            
			
DbSelectArea("QM1")
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³qmt030esc ºAutor  ³Denis Martins       º Data ³  09/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Antes da gravacao das associacoes de escalas verifica-se os º±±
±±º          ³tipos de escalas(Nao gravar escalas calib/calib completo    º±±
±±º          ³com outras escalas.                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt030esc(oDlg)
Local nx	  := 1
Local cTpEsca := ""
Local cTpEsAr := ""
Local lFech	  := .T.	
Local nPosx   := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMK_ESCALA" })

//Procura a primeira escala que nao esteja deletada, e associa o tipo da mesma...

If Len(aCols) >= 1
	For nx := 1 To Len(aCols)
		If !aCols[nx][Len(aCols[nx])] 
			dbSelectArea("QM9")
			dbSetOrder(1)
			If dbSeek(xFilial()+aCols[nx][nPosx])	
				cTpEsca := QM9->QM9_TIPAFE 
				Exit
			Endif	
		Endif
	Next nx

	// Procura por tipos de escalas, e compara escalas calibradores/calibradores completos 
	// com as demais escalas e vice-versa.

	For nx := 1 To Len(aCols)
		If !aCols[nx][Len(aCols[nx])]
			dbSelectArea("QM9")
			dbSeek(xFilial()+aCols[nx][nPosx])
			cTpEsAr := QM9->QM9_TIPAFE
			If Alltrim(cTpEsca) $ "4|8" .and. Alltrim(cTpEsAr) $ "1|2|3|5|9"
				Help(" ",1,"A030ESCCAL")
				lFech := .F.
			ElseIf Alltrim(cTpEsca) $ "1|2|3|5|9" .And. Alltrim(cTpEsAr) $ "4|8"
				Help(" ",1,"A030ESCCAL")
				lFech := .F.				
			Endif
		Endif
	Next nx
Endif	

If lFech
	oDlg:End()
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMIncFnt  ºAutor  ³Rafael S. Bernardi  º Data ³  11/01/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inicialiazador padrao para o campo vitual QMW_FONTE         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA030                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMIncFnt()
Local nPos
Local nX
For nX := 1 To Len(aHeader)
	If ascan(aHeader[nX],"QMW_CODINC") != 0
		nPos := nX
	EndIf
Next nX
Posicione("QMV",1,xFilial("QMV")+aCols[Len(aCols)][nPos],"QMV_FONTE")
Return QMV->QMV_FONTE

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A030ChkFam ³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 10.12.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se eh a mesma familia de instrumento na QM2         ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³QMTA030                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A030ChkFam(cFamInstr)

Local lRet 		:= .F.
Local aArea		:= GetArea()
Local aAreaQM2	:= QM2->(GetArea())
Local cInstr	:= QM2->QM2_INSTR

dbSelectArea("QM2")
dbSetOrder(1)
If dbSeek(xFilial("QM2")+cInstr)
	If QM2->QM2_TIPO == cFamInstr
		lRet := .T.
	Endif
Endif

RestArea( aAreaQM2 )
RestArea( aArea )

Return( lRet )

Function A030ChkQA5()
Return(ExistCpo("QA5", "C"+M->QM1_PROCAL))
