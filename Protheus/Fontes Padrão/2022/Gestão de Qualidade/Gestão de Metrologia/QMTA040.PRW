#INCLUDE "QMTA040.CH"
#include "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QMTA040	³ Autor ³ Wanderley Goncalves Jr³ Data ³ 01/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Escalas				  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Void QMTA040												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQMT													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. 				  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³	MOTIVO DA ALTERACAO				  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Denis Martins ³19/03/02³      ³Trazer o tipo de tolerancia que esta ca-³±±
±±³              ³        ³      ³dastrado no arquivo de padroes.         ³±± 
±±³Denis Martins ³22/04/02³      ³Ajuste na delecao/gravacao de padroes ti³±±
±±³              ³        ³      ³po soma qdo existir mais de um ponto na ³±± 
±±³              ³        ³      ³escala.                                 ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/
Static Function MenuDef()

Local aRotina := { {STR0043  ,"AxPesqui"  , 0 , 1,,.F.},;    // "Pesq." 
					{STR0044  ,"AxVisual"  , 0 , 2},;    // "Visual."
					{STR0045  ,"A040Iesc"  , 0 , 3},;    // "Incl."   
					{STR0046  ,"A040Iesc"  , 0 , 4},;    // "Alt."   
					{STR0047  ,"A040Desc"  , 0 , 5, 3},; // "Excl."   
					{STR0048  ,"A040Jun"   , 0 , 4} }    // "Padr”es"

Return aRotina

Function QMTA040 

Local lQM040Brow := ExistBlock("QM040BROW")
Local aRotAdic   := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis 											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aTela[0][0]
Private oCbxTol
Private nTipTol := 1
Private cTipTol                                          
Private cTipGrav                                         
Private aCRA := { OemToAnsi(STR0008), OemToAnsi(STR0014), OemToAnsi(STR0007) }  //"Confirma" ### "Redigita" ### "Abandona"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemtoAnsi(STR0006)  //"Escalas"
Private nTamQM3   := TamSx3("QM3_PADRAO")[1]

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
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef()

QM9->(DbSetOrder(1))
If lQM040Brow
	ExecBlock("QM040BROW",.F.,.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
//³ Ponto de entrada - Adiciona rotinas ao aRotina       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QM040ROT")
	aRotAdic := ExecBlock("QM040ROT", .F., .F.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"QM9")

Return .T.

/*
antigo a040Chav
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt040Chv ³ Autor ³ Wanderley Goncalves   ³ Data ³ 03/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao dos campos chave 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Qmta040 - E' chamada no X3_VALID.                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt040Chv()
Local lRet := .T.
Local cVar := readvar() // Conteudo da variavel do campo Revisao de Faixa

If ! Empty( M->QM9_ESCALA ) .and. ! Empty( M->QM9_REVESC )
	If Alltrim(cVar) == "M->QM9_REVESC"
		lRet := FreeForUse("QM9",M->QM9_ESCALA+M->QM9_REVESC)
		If lRet 
			dbSelectArea("QM9")
			If dbSeek( xFilial() + M->QM9_ESCALA +  Inverte(M->QM9_REVESC) ) 
				Help( " ", 1, "JAGRAVADO" )
				lRet := .F.
			Endif
		Endif
	Endif
EndIf

Return( lRet )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A040Iesc ³ Autor ³ Wanderley Goncalves Jr³ Data ³ 16/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de manutencao de Escalas - Inclusao 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A040Iesc(ExpC1,ExpN1,ExpN2)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo									  ³±±
±±³			 ³ ExpN1 = Numero do registro 								  ³±±
±±³			 ³ ExpN2 = Opcao selecionada								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA040													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³	MOTIVO DA ALTERACAO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Iuri Seto     ³31/08/00³ 5095 ³Gerar nova revisao ao alterar uma escala³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION A040Iesc(cAlias,nReg,nOpc)
Local oDlg
Local nOpca		:= 0
Local cCadastro := STR0006 + " - " + iif(nOpc==3,UPPER(STR0045),UPPER(STR0046)) //Cadastro de Escalas
Local aPosEnch	:= {}
Local cRevInv   := ""
Local cRev      := "" 

Local aPosObj := {}  
Local aObjects:= {}   
Local aInfo   := {}  
Local aSize   := {}


Private cTipAnt	:= ""
Private lTamSom	:= GetMv("MV_QMTPCES") == "1" //Para escalas do tipo soma considerar decimais definida na escala
Private aTELA[0][0]
Private aGETS[0]
Private cUtRev  := ""                

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define tamanho da tela                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize(, .F., 400 )
aObjects := {}
AAdd( aObjects, { 100, 600, .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
aPosObj := MsObjSize( aInfo, aObjects )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

While .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para processamento dos Gets		   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpcA:=0

	if nOpc == 3  // Inclusao
		RegToMemory(cAlias,.T.)

		DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],000 to aSize[6],aSize[5] OF GetWndDefault() PIXEL 
		oDlg:lMaximized:=.T.	
		EnChoice( cAlias, nReg, nOpc,,,,,aPosObj[1],, , , ,,,) //"Quanto … inclus„o?"
		ACTIVATE MSDIALOG oDlg ON INIT (QMTA040EnBar(oDlg,{|| If(Obrigatorio(aGets,aTela),(lRet:=A040TDOK(cAlias,nOpc),If(lRet,oDlg:End(),.F.)),.F.)},{ ||nOpca := 2,oDlg:End()},nOpc)) CENTERED
	elseif nOpc == 4	// Alteracao
		cUtRev := QMA040UltR(QM9->QM9_ESCALA)
		If QM9->QM9_REVESC <> cUtRev
			HELP(" ",1,"QMTALTREV") // Nao e possivel alterar esta revisao. Somente a ultima revisao pode ser alterada.
		Else
			cTipAnt := QM9->QM9_TIPAFE
			If !QMA040Cal(QM9->QM9_ESCALA,QM9->QM9_REVESC)

				RegToMemory(cAlias,.F.)
		
				DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],000 to aSize[6],aSize[5] OF GetWndDefault() PIXEL 
				oDlg:lMaximized:=.T.
			
				
				EnChoice( cAlias, nReg, nOpc,,,,,aPosObj[1],, , , ,,,) //"Quanto … inclus„o?"
	
				ACTIVATE MSDIALOG oDlg ON INIT (QMTA040EnBar(oDlg,{|| If(Obrigatorio(aGets,aTela),(lRet:=A040TDOK(cAlias,nOpc),If(lRet,lRet := QMT040CvUn(),.F.),If(lRet,oDlg:End(),.F.)),.F.)},{ ||nOpca := 2,oDlg:End()},nOpc)) CENTERED
			Else		
				nOpcA:=AltRevisao( cAlias, nReg, nOpc, , , , ,'A040TDOK("QM9",,.f.)') //,"Qmt040Rev()"
				If nOpca == 4 // Se realmente houve alteracao no registro.
					cRevInv := QM9->QM9_REVINV 
					cRev    := QM9->QM9_REVESC 
					RecLock("QM9",.F.)
//					Replace QM9->QM9_REVESC with StrZero(Val(cUtRev)+1,2)
					Replace QM9->QM9_REVINV with Inverte(QM9->QM9_REVESC,2)
					Replace QM9->QM9_DATREV	 with dDataBase				
					MsUnlock()
					FkCommit()
					If QM9->QM9_TIPAFE $ "1,2,3,9"
						QMA040DpPa(cRevInv)
					ElseIf QM9->QM9_TIPAFE $ "5"
						QMA040DpPS(cUtRev)
					EndIf
				Endif
			EndIf
		Endif

	Endif
	Exit
EndDo
dbSelectArea(cAlias)
return


/*

±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A040TdOK ³ Autor ³ Wanderley Goncalves Jr³ Data ³ 05/02/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica informacoes antes da gravacao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A040TdOk(ExpC1,ExpN1,ExpN2)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

FUNCTION A040TdOk(cAlias,nOpc,lVerif)
Local	lRet	 := .t.
Local	aArea	 := GetArea()
Local	aStru	 := {}
Local	aTam	 := {}
Local	lExit	 := .F.
Local	i		 := 0
Local 	bCampo   := {|nCPO| Field(nCPO) }
Local  oTmpTable:= NIL
Default nOpc	 := 4          
Default lVerif   := .t.
If lRet
	If M->QM9_ORGAFE == "I" .and. empty(M->QM9_TIPAFE)
		Help( " ", 1, "A040TIPOOB" ) // Para calibracao interna, ‚ obrigatorio 
											  // o cadastramento do tipo de afericao.
		lRet := .F.
	EndIf 	
EndIf

If lRet
	If !empty(M->QM9_TIPAFE) .and. empty(M->QM9_LAUDO) .and. M->QM9_NROMED > 0
		Help( " ", 1, "A040LAUDO") 	// Campo LAUDO obrigatorio para o tipo de 
											  	// Calibracao determinado.
		lRet := .F.
	EndIf 	
EndIf

If lRet 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se for externo sem medicoes, nÆo preencher campo tipo de laudo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If M->QM9_ORGAFE == "E" .and. M->QM9_NROMED == 0 .and. !empty(M->QM9_TIPAFE)
		Help( " ", 1, "A040NLAUDO") 	// Campo TIPO DE CALIBRA€ÇO nÆo deve ser 
											  	// preenchido para origem externo e sem medi‡äes. 
		lRet := .F.
	EndIf 	
EndIf

If lRet 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se for externo sem medicoes, Laudo s¢ poder  ser 1 ou 2 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If M->QM9_ORGAFE == "E" .and. M->QM9_NROMED == 0 .and. !(M->QM9_LAUDO$"1$2$ ")
		Help( " ", 1, "A040ILAUDO") 	// Para origem externo sem medicoes, o campo
											  	// LAUDO s¢ poder  ser incerteza, com ou sem 
												// confirma‡Æo metrol¢gica ou branco.
		lRet := .F.
	EndIf 	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Altera de texto retornado pelo gatilho para							   ³
//³ valor determinado no combo para gravacao - Somente para Calibradores.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  
If M->QM9_TIPAFE == "4"
	If Alltrim(M->QM9_VALESP) == "Fixo" 
		M->QM9_VALESP := '1'
	EndIf
Endif

If M->QM9_PERRO == OemtoAnsi(STR0040) // "Em relacao a tabela"
	M->QM9_PERRO := '3'
EndIf

M->QM9_REVINV := Inverte( M->QM9_REVESC )

If lRet 
	lRet := qmt040VNM()
EndIf

If lRet
	lRet := qmt040VTL()
EndIf

If Altera
	If lRet
		If (M->QM9_TIPAFE $ "4|8" .and. !(cTipAnt $ "4|8")) .or.;
		   (!(M->QM9_TIPAFE $ "4|8") .and. (cTipAnt $ "4|8"))
			aStru := {}
			aTam := TamSX3("QMK_FILIAL")
			Aadd(aStru,{ "TMP_FILIAL","C",aTam[1],aTam[2] })
			aTam := TamSX3("QMK_ESCALA")
			Aadd(aStru,{ "TMP_ESCALA","C",aTam[1],aTam[2] })
			aTam := TamSX3("QMK_TIPO")
			Aadd(aStru,{ "TMP_TIPO","C",aTam[1],aTam[2] })
			aTam := TamSX3("QMK_REVTIP")
			Aadd(aStru,{ "TMP_REVTIP","C",aTam[1],aTam[2] })
			
			
			oTmpTable := FWTemporaryTable():New( "IMPTMP" )
			oTmpTable:SetFields( aStru )
			oTmpTable:AddIndex("indice1", {"TMP_FILIAL","TMP_ESCALA"} )
			oTmpTable:Create()

			Processa ({||G040Temp()})

			IMPTMP->(dbGoTop())
			While !IMPTMP->(Eof())
				dbSelectArea("QMK")
				dbSetOrder(1)
				If dbSeek(xFilial("QMK")+IMPTMP->TMP_TIPO+Inverte(IMPTMP->TMP_REVTIP))
					While !Eof() .and. xFilial("QMK")+QMK->QMK_TIPO+QMK->QMK_REVTIP==;
							IMPTMP->TMP_FILIAL+IMPTMP->TMP_TIPO+IMPTMP->TMP_REVTIP
						dbSelectArea("QM9")
						dbSetOrder(01)
						If dbSeek(xFilial("QM9")+IMPTMP->TMP_ESCALA)
							If (M->QM9_TIPAFE $ "4|8" .and. !(cTipAnt $ "4|8"))
								Help(" ",1,"A040DICAL")
								M->QM9_TIPAFE = cTipAnt
								lExit := .T.
								lRet  := .F.	
							ElseIf (!(M->QM9_TIPAFE $ "4|8") .and. (cTipAnt $ "4|8"))
								Help(" ",1,"A040IGCAL")
								M->QM9_TIPAFE = cTipAnt
								lExit := .T.
								lRet  := .F.	
							Endif
						Endif 
						If lExit
							Exit
						Endif
						dbSelectArea("QMK")
						dbSkip()
					Enddo					     
				Endif
				If lExit
					Exit
				Endif
				dbSelectArea("IMPTMP")
				dbSkip()
			Enddo
			oTmpTable:Delete()
			dbSelectArea("QMK")
			RetIndex("QMK")                      
			Set Filter to
			QMK->(DbSetOrder(1))
			RestArea(aArea)
		Endif
	Endif				
Endif	

If lRet .and. lVerif
	dbSelectArea("QM9")
	If nOpc == 3 //Se for inclusao
		RecLock(cAlias,.T.)
	Else
		RecLock(cAlias,.F.)	
	Endif	             
	
	For i := 1 TO FCount()
		FieldPut(i,M->&(EVAL(bCampo,i)))
	Next i
	Replace QM9->QM9_FILIAL With xFilial("QM9")
	Replace QM9->QM9_REVINV With Inverte(QM9->QM9_REVESC)
	MsUnlock()   
Endif

Return(lRet)

/*

±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A040Desc ³ Autor ³ Wanderley Goncalves Jr³ Data ³ 14/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de exclusao de Escalas - Delecao 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A040Desc(ExpC1,ExpN1,ExpN2)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo									  ³±±
±±³			 ³ ExpN1 = Numero do registro 								  ³±±
±±³			 ³ ExpN2 = Opcao selecionada								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

FUNCTION A040Desc(cAlias,nReg,nOpc)
Local nOpcA //,nCntDele := 0 ,cCod ,aAC := { OemToAnsi(STR0007),OemToAnsi(STR0008) }	//"Abandona"###"Confirma" 
Local oDlg
Local lDeleta := .f.
Local aArea   := GetArea()
Local cChave  := "" // chave para delecao do QMQ   

Local aPosObj := {}  
Local aObjects:= {}   
Local aInfo   := {}  
Local aSize   := {}     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo						     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aTELA[0][0]
Private aGETS[0]     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define tamanho da tela                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize(, .F., 400 )
aObjects := {}
AAdd( aObjects, { 100, 600, .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
aPosObj := MsObjSize( aInfo, aObjects )

While .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para processamento dos Gets		   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpcA:=0
	dbSelectArea(cAlias)
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],000 to aSize[6],aSize[5] OF GetWndDefault() PIXEL   
		nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0009),,aPosObj[1])  //"Quanto … exclus„o?" 
		nOpca := 1
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})

	dbSelectArea(cAlias)

	If nOpcA == 2
		If QM9->QM9_REVESC <> QMA040UltR(QM9->QM9_ESCALA)
			HELP(" ",1,"QMTDELREV") // Nao e possivel excluir esta revisao. Somente a ultima revisao pode ser excluida.
		ElseIf QMA040Cal(QM9->QM9_ESCALA,QM9->QM9_REVESC)
			HELP(" ",1,"A040MEES") // Existem  medi‡”es cadastradas para esta
								  // escala. N„o ser  poss¡vel sua exclus„o.
		Else	
			lDeleta := .T.
			if QM9->QM9_ORGAFE	== "E"
				DbSelectArea("QMK")
				DbSetOrder(2)
				If QMK->(dbSeek( xFilial("QMK")+QM9->QM9_ESCALA ))
					HELP(" ",1,"A040ESFA")	// Nao e possivel excluir escala, pois esta associada a uma familia.
					lDeleta := .F.           
				EndIf
			EndIf			
			If QM9->QM9_TIPAFE $ "1,2,3,9,4,8"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se esta associado a alguma familia.                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("QMK")
				DbSetOrder(2)
				If QMK->(dbSeek( xFilial("QMK")+QM9->QM9_ESCALA ))
					HELP(" ",1,"A040ESFA")	// Nao e possivel excluir escala, pois esta associada a uma familia.
					lDeleta := .F.           
				ElseIf QM9->QM9_TIPAFE $ "1,2,3,9"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se Tipo == 1,2,3 ou 9 verifica se existem padroes associados ³
					//³ no QMC. 													 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("QMC")
					dbSetOrder(1)
					IF QMC->(dbSeek(xFilial("QMC")+QM9->QM9_ESCALA+Inverte(QM9->QM9_REVESC)))
						HELP(" ",1,"A040PAES") // Nao ‚ poss¡vel excluir escalas, pois 
											  // existem padroes amarrados a mesma.
						lDeleta := .F.											  
					EndIf	
				EndIf
			ElseIf QM9->QM9_TIPAFE == "5"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
				//³ Se Tipo == 5 verifica de existem padroes associados no QMA   ³
				//³ (soma de padroes)										     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("QMA")
				dbSetOrder(1)
				If dbSeek(xFilial("QMA")+QM9->QM9_ESCALA+QM9->QM9_REVESC)
					HELP(" ",1,"A040PAES") // Nao ‚ poss¡vel excluir escala, pois 
												  // existem padroes amarrados a mesma.
					lDeleta := .F.											  	
				Endif            
			Endif
			If lDeleta
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se escala esta cad. em um instr. utilizado na cal.  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If QMA040VIU()
					HELP(" ",1,"A040ESIU") // Nao e possivel excluir escala, pois esta cadastrada em um Instrumento Utilizado na calibracao.
					lDeleta := .F.											  	
				Else					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se escala esta cad.em um padrao secundario na cal.  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If QMA040VPS()
						HELP(" ",1,"A040ESPS")	// Nao e possivel excluir escala, pois esta cadastrada como Padrao Secundario na calibracao.
						lDeleta := .F.											  	
					EndIf
				EndIf 
				//Verifica se existe padroes secundarios amarrados nesta faixa
				DbSelectArea("QMH")
				DbSetOrder(1)
				If dbSeek(xFilial('QMH') + QM9->QM9_ESCALA) 
			 		HELP(" ",1,"A040FXPAD")	// Nao e possivel excluir faixa, pois esta cadastrada com Padrao Secundario.
			 		lDeleta := .F.
				Endif
			EndIf
				
			If lDeleta
				BEGIN TRANSACTION
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Apaga a escala.                                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("QM9")
				dbSetOrder(1)
				cChave := QM9->QM9_ESCALA+QM9->QM9_REVESC
				RecLock("QM9",.F.)
				dbDelete()
				MsUnlock()
        	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Apaga a tabela de faixa de aceitacao.                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("QMQ")
				dbSetOrder(1)
				If QMQ->(dbSeek(xFilial()+cChave))
					RecLock("QMQ",.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Apaga as familias que podem ser usadas na calibracao da escala.	³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("QMH")
				DbSetOrder(1)
				If dbSeek(xFilial('QMH') + Subs(cChave,1,TamSx3("QM9_ESCALA")[1])) // S¢ escala
					Do while xFilial('QMH') + Subs(cChave,1,TamSx3("QM9_ESCALA")[1]) ==;
								QMH->QMH_FILIAL + QMH->QMH_ESCALA 
						RecLock("QMH",.F.,.T.)
						dbDelete()
						MsUnlock()
						DbSkip()
					EndDo
				EndIf
				END TRANSACTION
	        	Exit
			EndIf 	
		EndIf 	
	EndIf

	Exit

EndDo

dbSelectArea(cAlias)
dbGoTop()

RestArea( aArea )

Return(Nil)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A040Coin ³ Autor ³ Wanderley Goncalves Jr³ Data ³ 16/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consistencia para o numero de medicoes minimas de acordo   ³±±
±±³			 ³ com o Tipo de Laudo (Incerteza deve ter  mais de 1 medicao)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A040Coin()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

FUNCTION A040Coin()

If M->QM9_LAUDO == "1" .or. M->QM9_LAUDO == "2"
	If M->QM9_NROMED = 1
		HELP(" ",1,"A040NUMMED")   
		Return(.f.)
	EndIf
EndIf
Return(.T.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A040CoMe ³ Autor ³ Wanderley Goncalves Jr³ Data ³ 16/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consistencia para o numero de medicoes minimas de acordo   ³±±
±±³			 ³ com o Tipo de Laudo (Incerteza deve ter  mais de 1 medicao)³±±
±±³			 ³ prevendo alteracao do campo Tipo de Laudo depois do no.	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A040CoMe()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

FUNCTION A040Come()
Local nRet := m->qm9_nromed
If (empty(M->QM9_NROMED) .or. M->QM9_NROMED=1) .and. M->QM9_LAUDO $ "12";
	.and. (M->QM9_ORGAFE = "I" .and. M->QM9_NROMED > 0)        //M->QM9_COLETA = "S")
	help(" ",1,"a040tipo")
	nRet := 2
EndIf
Return nRet


/*
antigo A040DsTp
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt040DsTp³ Autor ³ Wanderley Goncalves Jr³ Data ³ 16/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para aparecer descricao do Tipo na Browse 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ qmt040DsTp()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA040 - X3_INIBRW do campo QM9_DESCTP					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

FUNCTION qmt040DsTp()
If ExistBlock("qm040NEs")                   
	Return(ExecBlock("qm040NEs",.F.,.F.,{QM9->QM9_TIPAFE}))
Else
	Do Case
		Case QM9->QM9_TIPAFE == "1"
			  Return(padr(OemToAnsi(STR0016),25)) // "Simples"
		Case QM9->QM9_TIPAFE == "2"
			  Return(padr(OemToAnsi(STR0017),25)) // "Completa"
		Case QM9->QM9_TIPAFE == "3"
			  Return(padr(OemToAnsi(STR0018),25)) // "Press„o"
		Case QM9->QM9_TIPAFE == "4"
			  Return(padr(OemToAnsi(STR0019),25)) // "Calibrador"
		Case QM9->QM9_TIPAFE == "5"
			  Return(padr(OemToAnsi(STR0020),25)) // "Soma"
		Case QM9->QM9_TIPAFE == "6"
			  Return(padr(OemToAnsi(STR0021),25)) // "Faixa"
		Case QM9->QM9_TIPAFE == "7"
			  Return(padr(OemToAnsi(STR0022),25)) // "Folga/Luz"
		Case QM9->QM9_TIPAFE == "8"
			  Return(padr(OemToAnsi(STR0023),25)) // "Calibrador Completa"
		Case QM9->QM9_TIPAFE == "9"
			  Return(padr(OemToAnsi(STR0049),25)) // "Relogio"
	EndCase 
Endif	

Return(Nil)


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³			 Funcoes para controle de Cadastro de Padroes				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A040PaEs ³ Autor ³ Wanderley Goncalves   ³ Data ³ 06/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastra Padroes para Escalas 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A040PaEs(ExpC1,ExpN1,ExpN2)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo									  ³±±
±±³			 ³ ExpN1 = Numero do registro 								  ³±±
±±³			 ³ ExpN2 = Opcao selecionada no menu						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION A040Paes(cAlias,nReg,nOpcx)

Local nCnt
Local nSavRec
Local nOpca   :=0
Local nRecNc
Local lInclui := .f.
Local oDlg
Local lGravaOk := .T.
Local cCampo := ""		// Auxiliar para macro
Local aCosAa := {}
Local cSeek
Local cWhile

Private oGetPon 			// Getdados
Private nPos	 := 0		// Posicao QMC_PADRAO
Private nPosTol := 0		// Posicao QMC_TOLER
Private nOldTol
Private nOldTMin
Private nPosTMin := 0		//Posicao QMC_TOLMIN
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ So poderao cadastrar padroes os tipos Simples (1), Com-  ³
//³ pleto(2), Pressao(3) e Relogio(9).						 ³
//³ - Os Tipos Calibrador(4) e Calibrador Completo(8) SOMENTE³
//³	padrao Secundario.										 ³
//³ - O tipo Soma(5) cadastra Pontos.						 ³
//³ - O tipo Faixa(6) - a ser definido. 					 ³
//³ - O tipo Folga e Luz (7) NUNCA cadastra padroes.		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !(QM9->QM9_TIPAFE $ "1,2,3,5,9") 
	If QM9->QM9_TIPAFE $ "4,8"
		Help(" ",1,"A040TIPO48")  // Os Pontos deste Tipo devem ser cadastrados
											// nos pr¢prios Instrumentos.
	Else	 
		Help(" ",1,"A040NCAPAD")  // Tipo nao permite cadastramento de pontos    
	EndIf
	Return(nOpca)
EndIf

If QM9->QM9_TIPAFE == "5"  // Se for tipo Soma
	A040SOMA()
	Return(nOPCa)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ha' padroes ja' existentes para a escala     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QMC")
dbSetOrder(1)
nSavRec := RecNo()
dbSeek( xFilial()+QM9->QM9_ESCALA+Inverte(QM9->QM9_REVESC ))

nRecNc := RecNo()
nCnt := 0
While !EOF() .And.;
		QMC->QMC_ESCALA == QM9->QM9_ESCALA .and.;
		QMC->QMC_REVESC == QM9->QM9_REVESC .and.;
		QMC->QMC_FILIAL == xFilial('QMC')
	nCnt++
	dbSkip()
EndDo
lInclui := Iif(nCnt==0,.t.,.f.)
dbGoto(nRecNc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aHeader  := {}
Private Continua := .F.
Private nOpc     := 4
Private nUsado   := 0


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos campos de Bancos de Dados 			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX2")  // Posiciona pq. rotinas internas utilizam inf. do SX2
dbSeek("QMC")

dbSelectArea("QMC")
dbGoto(nRecNc)

cSeek  := QMC_FILIAL+QMC_ESCALA+QMC_REVINV
cWhile := "QMC_FILIAL+QMC_ESCALA+QMC_REVINV"

If lInclui
	FillGetDados(nOpc,"QMC" ,1     ,       ,             ,         ,         ,          ,        ,      ,        ,lInclui,          ,        ,          ,           ,            ,)
  //FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile   ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
Else
	FillGetDados(nOpc,"QMC",1     ,cSeek   ,{|| &cWhile},         ,         ,          ,        ,      ,        ,       ,          ,        ,          ,           ,            ,)
  //FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
EndIf

nUsado := Len(aHeader)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica qual a posicao do campo PADRAO no Header 		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos	:=	ASCAN(aHeader,{|x| alltrim(x[2]) = "QMC_PADRAO"})
nPosTol	:=	ASCAN(aHeader,{|x| alltrim(x[2]) = "QMC_TOLER"})
nPosTMin:=	ASCAN(aHeader,{|x| alltrim(x[2]) = "QMC_TOLMIN"})
nPosPdr	:=	ASCAN(aHeader,{|x| alltrim(x[2]) = "QMC_PADRAO"})

dbSelectArea("QMC")
dbGoto(nRecNc)

Continua 	:= .F.
nOpca 		:= 0

aCosAa		:= aClone(aCols)

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0012) From 9,0 To 28,80 OF oMainWnd // "Escala" 
oDlg:lMaximized := .F.
	@ 1.1 , .5	SAY OemToAnsi(STR0012) // "Escala"
	@ 1.1 , 4	SAY QM9->QM9_ESCALA    

	oGetPon := MSGetDados():New(41,5,130,315,nOpcx,"A040PLinOk","A040PTudOk",,.T.,,,,999)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
	{||nopca:=1,Iif(oGetPon:TudoOk() .And. A040VldPxF(aCosAa),(nOpca:=1,oDlg:End()),;
	nOpca:=0)},{||nOpca:= 0,oDlg:End()})

If nOpcA == 1 
	Begin Transaction
		lGravaOk := A040Pgrves(cAlias)
		If !lGravaOK 
			Help(" ",1,"A040NAOGRV")
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
±±³Fun‡…o	 ³A040PLinOk³ Autor ³ Wanderley Goncalves   ³ Data ³ 06/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se a linha digitada esta' Ok                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado. 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Qmta040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A040PLinOk(o)
Local nPosI := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMC_PADRAO"})
Local nx, lRet := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se deixar a ultima linha em branco, deleta a mesma ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(aCols[Len(aCols),1]) .And. n > 1
	Adel( aCols, Len(aCols) )
	ASize( aCols, Len( aCols) - 1)
	n := Len( aCols )
	oGetPon:oBrowse:Refresh()
	oGetPon:Refresh()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se campo escala esta' preenchido                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nx := 1 To Len(aHeader)

	If Empty(aCols[n][nx])
		If Trim(aHeader[nx][2]) == "QMC_PADRAO" 
			Help(" ",1,"QA_CPOOBR")
			lRet := .F.
			Exit
		Endif

		If !lRet
			Exit
		Endif
	Endif
Next nx

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o padrao  esta' cadastrado          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	If nPosI > 0
		If ! Empty(aCols[n][nPosI])
			If ! ExistCpo("QM3",aCols[n][nPosI])
				lRet := .f.
			EndIf
		EndIf       
	Endif
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A040PGrvEs³ Autor ³ Wanderley Goncalves   ³ Data ³ 06/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os padroes por escalas								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A040PGrvEs(cAlias)

Local nx
Local ny
Local nMaxArray := Len(aCols)

dbSelectArea("QMC")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o arquivo QMC		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to nMaxArray
	If ! Empty(aCols[nX][nPosPdr]) // Cod. Escala nao vazio
		If !Acols[nX][Len(aCols[nX])] // Nao esta deletado
			If dbSeek(xFilial("QMC") + QM9->QM9_ESCALA + QM9->QM9_REVINV + aCols[nX][nPosPdr])
				RecLock("QMC",.F.)   // Lock
			Else
				RecLock("QMC",.T.)   // Append
			Endif
			For ny := 1 to Len(aHeader)
				If aHeader[ny][10] # "V"
					cVar := Trim(aHeader[ny][2])
					Replace &cVar. With aCols[nx][ny]
				Endif
			Next ny
			QMC->QMC_FILIAL := xFilial("QMC")      
			QMC->QMC_ESCALA := QM9->QM9_ESCALA
			QMC->QMC_REVESC := QM9->QM9_REVESC
			QMC->QMC_REVINV := Inverte(QMC->QMC_REVESC)
			MsUnlock()
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cancela o padrao no QMC				  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If dbSeek(xFilial("QMC") + QM9->QM9_ESCALA + QM9->QM9_REVINV + aCols[nX][nPosPdr])        
				dbSelectArea("QM7")
				dbSetOrder(2)
				If ! dbSeek(cFilial+QMC->QMC_ESCALA+QMC->QMC_REVESC+QMC->QMC_PADRAO)
					RecLock("QMC",.F.,.T.)
					dbDelete()
					MsUnLock()
				EndIf
				dbSelectArea("QMC")              
			EndIf
		EndIf
	EndIf
Next nx

Return .T.

/*
antigo A040PVlPs
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt040VlPs³ Autor ³ Wanderley Goncalves   ³ Data ³ 06/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo de Padrao									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA040 - E' chamada no X3_VALID do cpo. QMC_PADRAO - SX3  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt040VlPs()
Local lRetu := .t.
Local nI
Local cVar := &(readvar()) // Conteudo da variavel do campo Escala
Local cTolMin
Local nDTol := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMC_TIPTOL"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se mudou o Padrao (Alterou o campo ja' digitado)      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aCols[n][nPosPdr]) .and. !Empty(cVar) .and. aCols[n][nPosPdr] <> cVar
	Help(" ",1,"NAOALTERA") // Campo nao pode ser alterado   
	lRetu := .f.
EndIf

If lRetu
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Padrao cadastrado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cColAnt			:= aCols[n][nPosPdr] 
	cTolAnt			:= aCols[n][nPosTol]
	cTolMin			:= aCols[n][nPosTMin]	
	aCols[n][nPosPdr] := M->QMC_PADRAO
	If ! ExistCpo("QM3",aCols[n][nPosPdr])
		aCols[n][nPosPdr] := cColAnt
		lRetu := .f.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a unidade de medida ‚ a mesma da escala. ³
	//³ Se for, devolve a tolerancia.                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	QM3->(DbSetOrder(1))
	If QM3->(DbSeek(xFilial("QM3")+aCols[n][nPosPdr]))
		If lRetu
			If !Empty(QM3->QM3_VALDAF)
				If dDataBase > QM3->QM3_VALDAF
					MsgStop(STR0072,STR0073)
					aCols[n][nPosPdr] := CriaVar("QMC_PADRAO",.T.)
					lRetu := .F.
				Endif		
			Endif
		Endif
		If lRetu
			// Verifica se possuem a mesma unidade de medida e se padrao nao e do tipo atributo
			If QM9->QM9_UNIMED <> QM3->QM3_UNIMED .and. QM3->QM3_TIPPAD <> "A"
				DbSelectArea("SAP")
				dbSetOrder(01)
				If !(dbSeek(xFilial("SAP")+QM3->QM3_UNIMED+QM9->QM9_UNIMED))
					lRetu := .f.
					Help(" ",1,"A040UNIMED") // "Padrao nao pode ser associado a escala, pois possui unidade de medida diferente")
					                          // "Cadastre a conversao."
				Endif
			EndIf
		EndIf
	EndIf
EndIf

If lRetu
	If Empty(Alltrim(QM3->QM3_TOLER))
		aCols[n][nPosTol]	:= Space(10)	
	Else
		aCols[n][nPosTol]	:= Alltrim(QM3->QM3_TOLER)
	Endif
	If Empty(Alltrim(QM3->QM3_TOLMIN))
		aCols[n][nPosTMin]	:= Space(10)
	Else
		aCols[n][nPosTMin]	:= Alltrim(QM3->QM3_TOLMIN)	
	Endif
	aCols[n][nDTol]		:= QM3->QM3_TIPTOL
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Padrao ja' existe                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 to len(aCols)
		If cVar == acols[nI][nPosPdr] .and. nI != n .and.;
			aCOLS[nI][Len(aCols[nI])] == .F. // Se ja' existir este padrao sec.
			Help(" ",1,"A040EXIPAD") // "Padrao j  relacionado a esta Escala"
			aCols[n][nPosPdr] 	:= cColAnt
			aCols[n][nPosTol]	:= cTolAnt
			aCols[n][nPosTMin] := cTolMin			
			lRetu 				:= .f.
			Exit
		EndIf
	Next nI
EndIf

Return(lRetu)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³		Fun‡äes para controle de Cadastro de Padräes Secund rios 		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A040Pase ³ Autor ³ Wanderley Goncalves   ³ Data ³ 06/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastra Tipos Secundarios para Escalas					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A040Pase(ExpC1,ExpN1,ExpN2)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo									  ³±±
±±³			 ³ ExpN1 = Numero do registro 								  ³±±
±±³			 ³ ExpN2 = Opcao selecionada no menu						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

FUNCTION A040Pase(cAlias,nReg,nOpcx)

Local nCnt
Local nSavRec
Local nOpca    :=0
Local nRecNc
Local lInclui  := .f.
Local oDlg
Local lGravaOk := .T.
Local cCampo   := ""  // Auxiliar para geracao de macros
Local cSeek
Local cWhile

Private oGetSec  // Getdados Secundaria
Private nPos	 := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ So NÇO poderÆo cadastrar tipos secund rios as seguintes  ³
//³ situa‡äes: 												 ³
//³ - Campo QM9_INSUTI	  (Grava ou nÆo Instrumento			 ³
//³ Utilizado) est  "S"   para os Tipos Simples(1), Comple-  ³
//³ to(2), Pressao(3), Soma(5) e Relogio(9)					 ³
//³ - SEMPRE para os tipos calibrador(4) e calibrador com-	 ³
//³	pleto(8).												 ³
//³ - NUNCA para o tipo Folga e Luz(7).	 					 ³ 
//³ - Tipo Faixa(6) a ser definido. 						 ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


If QM9->QM9_TIPAFE $  "6,7" .or.;
	QM9->QM9_INSUTI = "S" .and.;
	QM9->QM9_TIPAFE $ "1,2,3,5,9"  
			Help(" ",1,"A040NCAPAS")  // Tipo nao permite cadastramento de padrÆo        
											  // secund rio ou campo Usa Inst.Ut. est  pre-
											  // enchido com "S".
	Return(nOpca)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ha' padroes sec ja' existentes para a escala ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QMH")
nSavRec := QMH->(RecNo())
dbSeek( xFilial()+QM9->QM9_ESCALA )

nRecNc := QMH->(RecNo())
nCnt := 0
While !EOF() .And.;
		QMH->QMH_ESCALA == QM9->QM9_ESCALA .and.;
		QMH->QMH_FILIAL == xFilial("QMH")
	nCnt++
	dbSkip()
End
lInclui := Iif(nCnt==0,.t.,.f.)
dbGoto(nRecNc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aHeader  := {}
Private Continua := .F.
Private nOpc     := 4
Private nUsado   := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos campos de Bancos de Dados 			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX2")  // Posiciona pq. rotinas internas utilizam inf. do SX2
dbSetOrder(1)
dbSeek("QMH")

dbSelectArea("QMH")
dbGoto(nRecNc)

cSeek  := QMH_FILIAL+QMH->QMH_ESCALA
cWhile := "QMH_FILIAL+QMH->QMH_ESCALA"

If lInclui
	FillGetDados(nOpc,"QMH" ,1     ,       ,             ,         ,         ,          ,        ,      ,        ,lInclui,          ,        ,          ,           ,            ,)
  //FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile   ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
Else
	FillGetDados(nOpc,"QMH",1     ,cSeek   ,{|| &cWhile},         ,         ,          ,        ,      ,        ,       ,          ,        ,          ,           ,            ,)
  //FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
EndIf

nUsado := Len(aHeader)

Continua 	:= .F.
nOpca 		:= 0

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0012) From 9,0 To 28,80 OF oMainWnd // "Escala" 
	oDlg:lMaximized := .F.	
	@ 1.1 , .5	SAY OemToAnsi(STR0012) //"Escala"
	@ 1.1 , 4  SAY QM9->QM9_ESCALA    

	oGetSec := MSGetDados():New(41,5,130,315,nOpcx,"Qmt040TOk","AllwaysTrue",,.T.,,,,999)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,;
	If(oGetSec:TudoOk(),(nOpca := 1,oDlg:End()),nOpca:=0)},;
	{||nOpca:=0,oDlg:End()})
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica qual a posicao do campo PADSEC no Header 		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos := ASCAN(aHeader,{|x|x[2] = "QMH_PADSEC"})

If nOpcA == 1 
	Begin Transaction
		lGravaOk := A040grves(cAlias)
		If !lGravaOK 
			Help(" ",1,"A040NAOGRV")
		Else	
			//Processa Gatilhos
			EvalTrigger()
		EndIf 
	End Transaction
Endif

dbSelectArea(cAlias)

Return nOpca

/*
antigo a040LinOk
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Qmt040lOk ³ Autor ³ Wanderley Goncalves   ³ Data ³ 06/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se a linha digitada esta' Ok                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado. 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Qmta040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Qmt040lOk(o)

Local nx, lRet := .T.

nPos := ASCAN(aHeader,{|x|x[2] = "QMH_PADSEC"})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se deixar a ultima linha em branco, deleta a mesma ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(aCols[Len(aCols),1]) .And. n > 1
	Adel( aCols, Len(aCols) )
	ASize( aCols, Len( aCols) - 1)
	n := Len( aCols )
	oGetSec:oBrowse:Refresh()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se campo escala esta' preenchido                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nx := 1 To Len(aHeader)

	If Empty(aCols[n][nx])
		If Trim(aHeader[nx][2]) == "QMH_PADSEC" 
			Help(" ",1,"QA_CPOOBR")
			lRet := .F.
			Exit
		Endif

		If !lRet
			Exit
		Endif
	Endif
Next nx

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o padrao secund rio esta' cadastrado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lRet
	If ! Empty(aCols[n][nPos])
		If ! ExistCpo("QM1",aCols[n][nPos])
			lRet := .f.
		EndIf
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A040GrvEs ³ Autor ³ Wanderley Goncalves   ³ Data ³ 06/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os padroes secundarios por escalas					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A040GrvEs(cAlias)

Local nx
Local ny
Local nMaxArray := Len(aCols)

dbSelectArea("QMH")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o arquivo QMH 	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to nMaxArray
	If ! Empty(aCols[nX][nPos]) // Cod. Escala nao vazio
		If !Acols[nX][nUsado+1] // Nao esta deletado
			If dbSeek(xFilial('QMH') + QM9->QM9_ESCALA + aCols[nX][nPos])
				RecLock("QMH",.F.)   // Lock
			Else
				RecLock("QMH",.T.)   // Append
			Endif
			For ny := 1 to Len(aHeader)
				If aHeader[ny][10] # "V"
					cVar := Trim(aHeader[ny][2])
					Replace &cVar. With aCols[nx][ny]
				Endif
			Next ny
			QMH->QMH_FILIAL := xFilial('QMH')      
			QMH->QMH_ESCALA := QM9->QM9_ESCALA
			MsUnlock()
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cancela o padrao no QMH				  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If dbSeek(xFilial('QMH') + QM9->QM9_ESCALA + aCols[nX][nPos])        
				RecLock("QMH",.F.,.T.)
				dbDelete()
				MsUnlock()
			EndIf
		EndIf
	EndIf
Next nx

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A040VlPs ³ Autor ³ Wanderley Goncalves   ³ Data ³ 06/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo de Padrao Secundario						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA040 - E' chamada no X3_VALID do cpo. QMH_PADSEC - SX3  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A040VlPs()
Local lRetu := .T.
Local nI
Local aColsAnt
Local cVar := &(readvar()) // Conteudo da variavel do campo Escala
		
npos:= ASCAN(aHeader,{|x|x[2] = "QMH_PADSEC"})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se mudou o Padrao Secundario (Alterou o campo ja' digitado) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aCols[n][nPos]) .and. !Empty(cVar) .and. aCols[n][nPos] <> cVar
	Help(" ",1,"NAOALTERA") // Campo nao pode ser alterado   
	lRetu := .F.
EndIf


If lRetu
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Padrao Secund rio esta' cadastrado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsAnt 		:= aCols[n][nPos]
	aCols[n][nPos] := M->QMH_PADSEC
	If ! ExistCpo("QM1",aCols[n][nPos])
		lRetu := .F.
	EndIf
EndIf

If lRetu
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Padrao Secund rio ja' existe      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 to len(aCols)
		If cVar == acols[nI][nPos] .and. nI <> n .and.;
		aCOLS[nI][nUsado+1] == .F.// Se ja' existir este padrao sec.
				Help(" ",1,"A040EXIPSE") // "Padrao Secundario j  relacionado a esta Escala"
		   		aCols[n][nPos] := aColsAnt
				lRetu := .F.
		
		EndIf
	Next nI
EndIf                             

Return(lRetu)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A040Soma ³ Autor ³ Wanderley Goncalves   ³ Data ³ 08/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Abre tela para cadastro de Pontos para Tipo Soma			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA040									  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A040Soma()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria array de trabalho 										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MontaArray()

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³MontaArray³ Autor ³ Wanderley Goncalves   ³ Data ³ 09.01.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta Array dos Pontos do Tipo Soma 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ MontaArray(void)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Gen‚rico 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³	MOTIVO DA ALTERACAO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Iuri Seto     ³25/09/00³  --	 ³Alteracao do Especificado e Tolerancia  ³±±
±±³              ³        ³    	 ³do oGetSoma de inteiro para decimal.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC Function MontaArray()

//Local cSavCor1 := SetColor("bg+/b,,,")
Local nDec := 0
Local cEspec
Local nI , nX	  := 0
Local aAlter	  := {}
Local lRet		  := .F.
Local oFnt
Local nCoef			:= 1
Local lUniGual		:= .T.
Local cTolMin	:=""
Local cTipQMA	:= ""
Local cIndex		:= ""
Local cKey			:= ""
Local cCond			:= ""
Local nIndex		:= 0
Local nDecMi		:= 0
Local nDecMa		:= 0
Local aRecQMA       := {} //Usado para armazenar o Alias e Recno do QMA para o Walk Thru
Local cTamEsc := GetNewPar("MV_QDECPAD","1") //Considerar o tamanho de casas decimais do padrao
Private oDlgEscala 
Private oGetSoma
Private cFaixa

Private aTabela := {} // Array dos Pontos
Private aTabPad := {} // Array contendo os padroes de todas os pontos
Private lAbandona := .t.

dbSelectArea("QMA")
dbSetOrder(1)
nSavRec := RecNo()
dbSeek( xFilial("QMA")+QM9->QM9_ESCALA+QM9->QM9_REVESC )

nRecNc := RecNo()

Do While !QMA->(EOF()) .And. xFilial("QMA")+QM9->QM9_ESCALA+QM9->QM9_REVESC ==;
	QMA->QMA_FILIAL+QMA->QMA_ESCALA+QMA->QMA_REVESC
	cFaixa := QMA->QMA_FAIXA
	cToler := ""
	cTolMin:= ""
	nEspec := 0
    If lTamSom
	    nDec   := 0	
	Endif

	Do While !QMA->(EOF()) .And. QMA->QMA_FILIAL+QMA->QMA_ESCALA+QMA->QMA_REVESC+QMA->QMA_FAIXA == ;
			xFilial('QMA')+QM9->QM9_ESCALA+QM9->QM9_REVESC+cFaixa
      lUniGual := .T.
		QM3->(DbSetOrder(1))

		If QM3->(DbSeek(xFilial('QM3') + QMA->QMA_PADRAO))
		   dbSelectArea("SAP")
		   dbSetOrder(1)
		   If QM3->QM3_UNIMED <> QM9->QM9_UNIMED
				If !dbSeek(xFilial("SAP")+QM3->QM3_UNIMED+QM9->QM9_UNIMED)
					Help(" ",1,"A140UNIDIF")
				Else
					nCoef := SAP->AP_COEF
					lUniGual := .F.
				Endif		   
		   Else
		   	nCoef := 1
		   Endif
		
			Aadd(aTabPad,{QM3->QM3_PADRAO,;
				  IIf(lUniGual,QM3->QM3_ESPEC ,Alltrim(StrTran(Str(SuperVal(QM3->QM3_ESPEC)*nCoef),".",","))),; 
				  IIf(lUniGual,QM3->QM3_TOLMIN,Alltrim(StrTran(Str(SuperVal(QM3->QM3_TOLMIN)*nCoef),".",","))),;
				  IIf(lUniGual,QM3->QM3_TOLER ,Alltrim(StrTran(Str(SuperVal(QM3->QM3_TOLER)*nCoef),".",","))),;
				  IIf(lUniGual,QM3->QM3_UNIMED,QM9->QM9_UNIMED),;
				  QMA->QMA_FAIXA,; 
				  QMTCbox("QMA_TIPTOL",QMA->QMA_TIPTOL),QM3->(Alias()),QM3->(Recno()),;
				  .F.})
			
			nEspec += SuperVal(QM3->QM3_ESPEC)*nCoef
			If !lUniGual
				If Alltrim(cTamEsc) == "1"
					If !Empty(QM9->QM9_ESCALI)
						nDec := QA_NUMDEC(QM9->QM9_ESCALI)
					Else
						nDec := QA_NUMDEC(QM3->QM3_ESPEC)+QA_NUMDEC(StrTran(Str(nCoef),".",","))
					Endif
				Else 
					nDec := QA_NUMDEC(QM3->QM3_ESPEC)				
				Endif
				cToler := Iif(SuperVal(QMA->QMA_TOLER)*nCoef > SuperVal(cToler)*nCoef,;
					QMA->QMA_TOLER,cToler) 
				cTolMin := Iif(SuperVal(QMA->QMA_TOLMIN)*nCoef > SuperVal(cTolMin)*nCoef,;
					QMA->QMA_TOLMIN,cTolMin)					
			Else
				nDec := If(nDec>QA_NUMDEC(QM3->QM3_ESPEC),nDec,;
								QA_NUMDEC(QM3->QM3_ESPEC))
				cToler := Iif(SuperVal(QMA->QMA_TOLER) > SuperVal(cToler),;
								QMA->QMA_TOLER,cToler)
				cTolMin := Iif(SuperVal(QMA->QMA_TOLMIN) > SuperVal(cTolMin),;
								QMA->QMA_TOLMIN,cTolMin)
			Endif	
		EndIf
		
		If lTamSom
			nDecMa	:= QA_NUMDEC(QMA->QMA_TOLER)
			nDecMi	:= QA_NUMDEC(QMA->QMA_TOLMIN)
			cToler := Str(SuperVal(cToler),TamSx3("QMA_TOLER")[1],nDecMa)
			cToler := StrTran(cToler,'.',',')		
			cTolMin := Str(SuperVal(cTolMin),TamSx3("QMA_TOLMIN")[1],nDecMi)
			cTolMin := StrTran(cTolMin,'.',',')		
		Else		
			cToler := Str(SuperVal(cToler),TamSx3("QMA_TOLER")[1],nDec)
			cToler := StrTran(cToler,'.',',')		
			cTolMin := Str(SuperVal(cTolMin),TamSx3("QMA_TOLMIN")[1],nDec)
			cTolMin := StrTran(cTolMin,'.',',')		
    	Endif
		cTipQMA := QMTCbox("QMA_TIPTOL",QMA->QMA_TIPTOL)
		
		aAdd(aRecQMA,{QMA->(Alias()),QMA->(Recno())})
		
		QMA->(DbSkip())
	EndDo

	cEspec := Str(nEspec,TamSx3("QM3_ESPEC")[1],nDec)
	cEspec := StrTran(cEspec,'.',',')
	
	If Alltrim(SubStr(cEspec,1,1)) == "*" 
		cEspec := Str(nEspec,TamSx3("QM3_ESPEC")[1],nDec-1)
		cEspec := StrTran(cEspec,'.',',')
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona no array aTabela para mostrar no browse ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aTabela,{cFaixa,cEspec,cTolMin,cToler,QM3->QM3_UNIMED,cTipQMA,;
	aRecQMA[Len(aRecQMA)][1],aRecQMA[Len(aRecQMA)][2]})
	
EndDo

nRecNc := RecNo()

dbSelectArea("QMA")
dbSetOrder(1)
If dbSeek(xFilial("QMA")+QM9->QM9_ESCALA)
	While QMA->(!Eof()) .and. QMA->QMA_ESCALA == QM9->QM9_ESCALA
		If QMA->QMA_REVESC >= QM9->QM9_REVESC
			lExRev := .T.
			Exit
		Endif
		dbSelectArea("QMA")
		dbSkip()
	Enddo
Endif
If lExRev  
	lExRev := .F.
	dbSelectArea("QM7")
	dbSetOrder(1)
	cKey   := "QM7_FILIAL+QM7_ESCALA+QM7_PONTO"
	cQuery := "SELECT QM7.QM7_FILIAL,QM7.QM7_ESCALA,QM7.QM7_PONTO,QM7.QM7_REVESC "
	cQuery += "FROM " + RetSqlName("QM7")+" QM7 "
	cQuery += "WHERE QM7.QM7_FILIAL='"+xFilial("QM7")+"' AND "
	cQuery += "QM7.QM7_ESCALA = '"+QM9->QM9_ESCALA+"'  AND "			
	cQuery += "QM7.QM7_REVESC = '"+QM9->QM9_REVESC+"'  AND "				
	cQuery += "QM7.D_E_L_E_T_<>'*' "
	cQuery += " ORDER BY " + SqlOrder(cKey)

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"QM7TRB", .F., .T.)

	While !QM7TRB->(Eof())
		lExRev  := .T.
		Exit
	Enddo	

	QM7TRB->(dbCloseArea())	
Endif
dbSelectArea("QMA")
dbGoTo(nRecNc)
If (Len( aTabela ) == 0)
	Aadd(aTabela,{ Space(TamSx3("QMA_FAIXA")[1]),0,;
		0,0, Space(TamSx3("QM3_UNIMED")[1]),Space(TamSx3("QMA_TIPTOL")[1]),;
		QMA->(Alias()),0})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aHeader para a Getdados sem se basear no SX3 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aHeader := {}
AADD(aHeader,{OemToAnsi(STR0010) ,"VAR01","@!",10,0,; //"Ponto"
	"PontosWin(aTabPad,oGetSoma,@cFaixa,'P')","û","C",;
	"TRB","V"})
	
AADD(aHeader,{OemToAnsi(STR0025) ,"VAR02","@!",;  //"@E 999,999,999.9999",; Especificado
	10,4,".t.","û","N","TRB","V"})
If !lTamSom	
	AADD(aHeader,{OemToAnsi(STR0064)  ,"VAR03","@!",;     //"@E 999,999,999.9999",; Toler.Minima
		10,4,"M->VAR03 >= aCols[n][3] .And. PontosWin(aTabPad,oGetSoma,@cFaixa,'T')",;
		"û","N","TRB","V"})
		
	AADD(aHeader,{OemToAnsi(STR0065)  ,"VAR04","@!",;     //"@E 999,999,999.9999",;  Toler.Maxima
		10,4,"M->VAR04 >= aCols[n][4] .And. PontosWin(aTabPad,oGetSoma,@cFaixa,'T')",;
		"û","N","TRB","V"})
Else
	AADD(aHeader,{OemToAnsi(STR0064)  ,"VAR03","@!",;     //"@E 999,999,999.9999",; Toler.Minima
		10,4,"PontosWin(aTabPad,oGetSoma,@cFaixa,'T')",;
		"û","N","TRB","V"})
		
	AADD(aHeader,{OemToAnsi(STR0065)  ,"VAR04","@!",;     //"@E 999,999,999.9999",;  Toler.Maxima
		10,4,"PontosWin(aTabPad,oGetSoma,@cFaixa,'T')",;
		"û","N","TRB","V"})
Endif
AADD(aHeader,{OemToAnsi(STR0066),"VAR05","@!",10,0,".t.","û",; //Unidade de Medida
	"C","TRB","V"})
 
AADD(aHeader,{OemToAnsi(STR0067),"VAR06","@!",10,0,".t.","û",; //Tipo Calc.Toler
	"C","TRB","V"})
	
// Inclui coluna de registro atraves de funcao generica
ADHeadRec("QMA",aHeader)

Private aCols	:= Array( Len(aTabela), Len(aHeader) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define quais colunas podem ser editadas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aAlter , "VAR03" )
Aadd( aAlter , "VAR04" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aCols com os dados pre-carregados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to Len(aTabela)
	For nX := 1 to Len(aHeader)
		aCols[nI][nX] := aTabela[nI][nX]
	Next nX
	aAdd(aCols[nI],.F.)
Next nI

DEFINE FONT oFnt NAME "Arial" BOLD

DEFINE MSDIALOG oDlgEscala FROM	80,112 TO 374,671 ;
	TITLE Oemtoansi(STR0015) PIXEL Of GetWndDefault() // "Padr”es por Escala"
oDlgEscala:lMaximized := .F.
@ 33, 5 TO 50, 120 OF oDlgEscala  PIXEL
@ 37, 14 SAY STR0012 SIZE 26, 7 OF oDlgEscala PIXEL FONT oFnt // "Escala"
@ 37, 68 SAY xPadL(alltrim(QM9->QM9_ESCALA),53) SIZE 53, 7 OF oDlgEscala PIXEL

oGetSoma := MsGetDados():New(52,5,150,275,3,"SomaLinOK","AllwaysTrue",,.T.,aAlter,,,999)
oGetSoma:oBrowse:bDrawSelect := { || VerLin() }

ACTIVATE MSDIALOG oDlgEscala ON INIT EnchoiceBar(oDlgEscala,;
	{|| IIf(lRet := SomaLinOk(),oDlgEscala:End(),.F.)},{|| oDlgEscala:End()})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso confirme grava os dados da Escala ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	a040Grava()
EndIf

oFnt:End()
	
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A040Pict ³ Autor ³ Wanderley Goncalves   ³ Data ³ 16/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Define a picture do campo de tolerancia a partir do numero ³±±
±±³			 ³ de casas decimais definidas no campo Especificado		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A040Pict("cCampo")                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome do Campo que tera' a picture a ser definida   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QmtA040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A040Pict(cCampo,cEspec)
Local cPict := ""
Local nTam := TamSx3("QMA_TOLER")[1]
Local nDec := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o numero de casas decimais do Nominal 	    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nDec := QA_NumDec(cEspec)	 // Valor Nominal 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a picture a partir do no. casas decimais do Nominal  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nDec == 0
	cPict := "@E "+Replicate('9',nTam)
Else
	cPict := "@E "+Replicate('9',nTam-(nDec+1)) + '.' + Replicate('9',nDec)
EndIf


Return (cPict)

/*
antigo a040TudoOk
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Qmt040TOk ³ Autor ³ Wanderley Goncalves   ³ Data ³ 22/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se toda a getdados esta' Ok                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado. 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qmt040TOk(o)
Local nI
Local lRet := .t.

For nI := 1 to Len(aCols)
	If ! Qmt040lOk(o)
		lRet := .f.
		Exit
	EndIf
Next

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A040PTudOk³ Autor ³ Wanderley Goncalves   ³ Data ³ 22/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se toda a getdados esta' Ok                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado. 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A040PTudOk(o)
Local nI
Local lRet := .t.                              

For nI := 1 to Len(aCols)
	If ! A040PLinOk(o)
		lRet := .f.
		Exit
	EndIf
Next

Return(lRet)

/*
antigo a040ValNM
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt040VNM ³ Autor ³ Wanderley Goncalves Jr³ Data ³ 30/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida numero de medicoes								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X3_VALID do QM9_NROMED									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt040VNM()
Local lRet := .t.

If M->QM9_ORGAFE=="I" .and. M->QM9_NROMED = 0
	HELP(" ",1,"A040NMEDOB") // Para orgÆo calibrador Interno, ‚ obrigatorio
									 // cadastrar medicoes	 
	lRet := .f.
  
ElseIf M->QM9_NROMED = 1 .and. M->QM9_LAUDO $ ('1$2')
	HELP(" ",1,"A040NMED01") // NÆo pode haver uma unica medicao quando 
									 // tipo de Laudo ‚ com Incerteza, pois exis-
									 // tem calculos de m‚dia.
	lRet := .f.

ElseIf M->QM9_NROMED = 0 .and. M->QM9_LAUDO $ ('1$2')

	HELP(" ",1,"A040OBCAMP") // Como n„o existir„o medi‡”es, ‚ obrigat¢rio 
									 // o preenchimento dos campos incerteza e laudo
									 // dos instrumentos no cadastro de instrumentos.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza aTela, porque o Help exibe na tela o valor anterior    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	M->QM9_NROMED := 0

EndIf

Return(lRet)


/*
antigo A040DigTab
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³qmt040DiTb³ Autor ³ Wanderley Goncalves Jr³ Data ³ 02/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria tabela de laudo 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt040DiTb()
/*
Local aLaudo  := {}
Local nOpcA
Local aArea := GetArea()
Local nRepIni, nRepFim, nResIni, nResFim, nAceIni, nAceFim
Local cEsRepr, cEsApRs, cEsAppr
If M->QM9_TABELA == "S"
	
	DbSelectArea("QMQ")
	DbSetOrder(1)

	do while .t.
		aLaudo := {}
		If QMQ->(DbSeek(xFilial('QMQ')+M->QM9_ESCALA+M->QM9_REVESC))
			aadd(aLaudo,{ OemToAnsi(Tabela("QA","REPROV")) ,QMQ->QMQ_REPINI,QMQ->QMQ_REPFIM } )  // Reprovado
			aadd(aLaudo,{ OemToAnsi(Tabela("QA","APREST")) ,QMQ->QMQ_RESINI,QMQ->QMQ_RESFIM } ) // Aprovado com restri‡Æo
			aadd(aLaudo,{ OemToAnsi(Tabela("QA","APROV" )) ,QMQ->QMQ_ACEINI,QMQ->QMQ_ACEFIM } ) // Aprovado
			nRepIni := QMQ->QMQ_REPINI
			nRepFim := QMQ->QMQ_REPFIM                    
			nResIni := QMQ->QMQ_RESINI
			nResFim := QMQ->QMQ_RESFIM
			nAceIni := QMQ->QMQ_ACEINI
			nAceFim := QMQ->QMQ_ACEFIM
		Else
			aadd(aLaudo,{ OemToAnsi(Tabela("QA","REPROV")), 0.101, 100.000 } ) // Reprovado
			aadd(aLaudo,{ OemToAnsi(Tabela("QA","APREST")), 0.011,   0.100 } ) // Aprovado com restri‡„o
			aadd(aLaudo,{ OemToAnsi(Tabela("QA","APROV")) , 0.000,   0.010 } ) // Aprovado
			nRepIni := 0.101          
			nRepFim := 100.000
			nResIni := 0.011
			nResFim := 0.100
			nAceIni := 0.000
			nAceFim := 0.010
		EndIf

		cEsRepr := OemToAnsi(Tabela("QA","REPROV"))
		cEsApRs := OemToAnsi(Tabela("QA","APREST"))
		cEsAppr := OemToAnsi(Tabela("QA","APROV"))

		DEFINE MSDIALOG oDlg FROM	21,49 TO 212,408 TITLE OemToAnsi( STR0038 ) PIXEL // "LAUDO"

		@ 0, 4 TO 69, 171 OF oDlg	PIXEL

		@ 8, 119  SAY OemToAnsi( STR0035 ) SIZE 25, 7 OF oDlg PIXEL // "Limite" 
		@ 15, 96  SAY OemToAnsi( STR0036 ) SIZE 25, 7 OF oDlg PIXEL // "Inferior"
		@ 15, 139 SAY OemToAnsi( STR0037 ) SIZE 25, 7 OF oDlg PIXEL // "Superior"
		
		@ 26, 8	 SAY cEsRepr SIZE 76, 7  OF oDlg PIXEL 		
		@ 24, 89  MSGET nRepIni PICTURE "999.999" ;
		VALID  Inferior(@aLaudo, oDlg ) .AND. (oDlg:Refresh(),.t.) ;
		SIZE 37, 10 OF oDlg PIXEL
		
		@ 24, 132 MSGET nRepFim PICTURE "999.999" ;
		VALID Inferior(@aLaudo ) .AND. ( oDlg:Refresh(),.t.);
		SIZE 37, 10 OF oDlg PIXEL

		@ 41, 8	 SAY  cEsApRs SIZE 76, 7  OF oDlg PIXEL
		@ 39, 89  MSGET nResIni PICTURE "999.999" ;
		VALID Inferior(@aLaudo ) .AND. (oDlg:Refresh(),.t.);
		SIZE 37, 10 OF oDlg PIXEL
		
		@ 39, 132 MSGET nResFim PICTURE "999.999" ;
		VALID Inferior(@aLaudo ) .AND. (oDlg:Refresh(),.t.);
		SIZE 37, 10 OF oDlg PIXEL

		@ 56, 8	 SAY cEsAppr SIZE 76, 7  OF oDlg PIXEL
		@ 55, 89  MSGET nAceIni PICTURE "999.999" ;
		VALID Inferior(@aLaudo ) .AND. (oDlg:Refresh(),.t.);
		SIZE 37, 10 OF oDlg PIXEL
		
		@ 55, 132 MSGET nAceFim PICTURE "999.999" ;
		VALID Inferior(@aLaudo ) .AND. (oDlg:Refresh(),.t.);
		SIZE 37, 10 OF oDlg PIXEL

		DEFINE SBUTTON FROM 79,103 TYPE 1 ENABLE OF oDlg Action (nOpca:=1,oDlg:End())
		DEFINE SBUTTON FROM 79,138 TYPE 2 ENABLE OF oDlg Action (nOpca:=0,oDlg:End())
		ACTIVATE MSDIALOG oDlg CENTERED
	
		If nOpcA == 2 // Redigita
			Loop
		ElseIf nOpcA == 1 // Confirma
			If QMQ->(Eof())
				Reclock("QMQ",.T.)  // Append
				QMQ->QMQ_FILIAL := xFilial('QMQ')
				QMQ->QMQ_ESCALA := M->QM9_ESCALA
			Else
				Reclock("QMQ",.F.)  // Lock
			EndIf 
			QMQ->QMQ_REPINI := aLaudo[1,2]
			QMQ->QMQ_REPFIM := aLaudo[1,3]
			QMQ->QMQ_RESINI := aLaudo[2,2]
			QMQ->QMQ_RESFIM := aLaudo[2,3]
			QMQ->QMQ_ACEINI := aLaudo[3,2]
			QMQ->QMQ_ACEFIM := aLaudo[3,3]
			MsUnlock()
		EndIf

		exit

	enddo

endif

RestArea(aArea)
*/
return(.T.)

Function Inferior( aLaudo, oDlg )

Local nI
Local lReturn	 := .T.
Local aLauCopy  := aClone( aLaudo )

For nI := 1 to Len( aLaudo )
	
	If nI > 1 
		aLaudo[nI,3] := aLaudo[nI-1,2] - 0.001
		If aLaudo[nI,3] < 0.000 
			lReturn := .F.
		EndIF
	EndIf
	
	If ( aLaudo[nI,2] >= aLaudo[nI,3] )
		aLaudo[nI,2] := aLaudo[nI,3] - 0.001
		If aLaudo[nI,2] < 0.000 
			lReturn := .F.
		EndIF
	EndIf

Next nI

// Se houver valores negativos, restaura o valor original do array
If ! lReturn
	aLaudo := {}
	aLaudo := aClone( aLauCopy )
EndIf

Return( lReturn )

/*
antigo a040WLaudo
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt040WLau³ Autor ³ Wanderley Goncalves Jr³ Data ³ 04/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ativa campo ou nao conforme campos anteriores			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X3_WHEN do QM9_TABELA									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt040WLau()

If M->QM9_LAUDO $ ('1,2') .or. M->QM9_TIPAFE == '7' 
	Return(.F.)
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A040WERRO ³ Autor ³ Wanderley Goncalves Jr³ Data ³ 04/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ativa campo ou nao conforme campos anteriores			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X3_WHEN do QM9_TABELA									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A040WERRO()

If M->QM9_TIPAFE <> '7' .or. M->QM9_LAUDO $ '3,4,9'
	If M->QM9_TABELA = 'S' 
		Return(OemtoAnsi(STR0040)) // "Em relacao a tabela"
	EndIf
EndIf

Return('')

/*
antigo a040ValErr
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt040VErr³ Autor ³ Wanderley Goncalves Jr³ Data ³ 05/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo de Percentual de Erro						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X3_VALID do QM9_PERRO									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt040VErr()

If (M->QM9_TIPAFE = '7' .or. M->QM9_LAUDO $ '1,2') 
	Return(.F.)
EndIf                   

If M->QM9_PERRO = '3'

	Msgalert(STR0121) // "Selecione uma das opções: 1 = Em relação ao especificado, 2 = Em relacao aos limites"
	Return(.F.)
Endif
/*
If M->QM9_TABELA = 'N' .and. M->QM9_PERRO = '3'
	HELP(" ",1,"A040PERRO") // 'Erro nao pode ser determinado em relacao a tabela'
	Return(.F.)
EndIf
*/

Return(.T.)

/*
antigo A040WTab
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt040WTab³ Autor ³ Wanderley Goncalves Jr³ Data ³ 05/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Permite ou nao a entrada de dados no campo QM9->QM9_PERRO  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X3_WHEN do QM9_PERRO 									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt040WTab()

If M->QM9_LAUDO $ '1ù2' .or. M->QM9_LAUDO = "7" .or. M->QM9_TABELA = 'S'
	Return(.F.)
EndIf   

Return(.T.)

/*
antigo a040WhTol
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt040WhTo³ Autor ³ Wanderley Goncalves Jr³ Data ³ 06/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Guarda valor real da tolerancia do padrao 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X3_WHEN do QMC_TOLER 									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt040WhTo()

Local nPos 		:= ASCAN(aHeader,{|x| alltrim(x[2]) = "QMC_TOLER" }) 
Local nPosMin	:= ASCAN(aHeader,{|x| alltrim(x[2]) = "QMC_TOLMIN" }) 

nOldTol := aCols[n,nPOS]  //M->QMC_TOLER                          
nOldTMin:= aCols[n,nPosMin]

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A040VTol	³ Autor ³ Wanderley Goncalves Jr³ Data ³ 06/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida valor da Tolerancia digitada 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X3_VALID do QMC_TOLER/QMC_TOLMIN							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A040VTol()
Local nPosPadd	:=	ASCAN(aHeader,{|x| alltrim(x[2]) = "QMC_PADRAO"})
Local cCampo	:= ReadVar() 
Local nVaTMa
Local nVaTMi

If Alltrim(cCampo) == "M->QMC_TOLER"
	If Valtype(M->QMC_TOLER) == "C"
		nVaTMa := SuperVal(M->QMC_TOLER)
	Else
		nVaTMa := M->QMC_TOLER
	Endif
	If Alltrim(nOldTol) == "" 
		nOldTol	:= "0"
	Endif
	If nVaTMa < SuperVal(nOldTol)
		Help( " ", 1, "A040VTOL" ) // Nova tolerancia nÆo pode ser menor que a anterior
		Return(.f.)
	EndIf
Else 
	If Valtype(M->QMC_TOLMIN) == "C"
		nVaTMi := SuperVal(M->QMC_TOLMIN)
	Else
		nVaTMi := M->QMC_TOLMIN
	Endif
	If Alltrim(nOldTMin) == ""
		nOldTMin := "0"
	Endif
	If nVaTMi < SuperVal(nOldTMin)
		Help( " ", 1, "A040VTOL" ) // Nova tolerancia nÆo pode ser menor que a anterior
		Return(.f.)
	EndIf
Endif	

dbSelectArea("QM3")
dbSetOrder(1)
If dbSeek(xFilial("QM3")+aCols[n][nPosPadd])
	dbSelectArea("QM7")
	dbSetOrder(2)
	If dbSeek(cFilial+QMC->QMC_ESCALA+QMC->QMC_REVESC+aCols[n][nPosPadd])
		MessageDlg(STR0118+Chr(13)+Chr(10)+STR0119,,3) //"Por favor realize a revisao da escala"
		Return .F.
	Endif		
Endif

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ A040Jun	³ Autor ³ Alessandro/Fernando G.³ Data ³ 06.05.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta RadioGroup com selecao para Padrao/Padrao secundario ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A040Jun(void)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A040Jun(cAlias,nReg,nOpcx)

Local oDlg
Local oRad
Local nItem   := 1
Local nOpc		:= 0
Local oFontDlg := TFont():New("Arial",6,15,.f.,.t.)
Private lTamSom	:= GetMv("MV_QMTPCES")=="1" //Para escalas do tipo soma considerar decimais definida na escala
Private lExRev		:= .F.

DEFINE MSDIALOG oDlg FROM	35,37 TO 140,300 TITLE OemToAnsi(STR0050) PIXEL //"Padr”es"

@ 05,05 TO 40,80 OF oDlg PIXEL

@ 13, 11 RADIO oRad VAR nItem 3D SIZE 50, 11 ;
			PROMPT OemToAnsi(STR0051),; //"&Ponto"
			OemToAnsi(STR0052) OF oDlg PIXEL //"&Secund rio"

DEFINE SBUTTON FROM 11, 90 TYPE 1 ENABLE OF oDlg Action (nOpc:=1,oDlg:End())
DEFINE SBUTTON FROM 24, 90 TYPE 2 ENABLE OF oDlg Action (nOpc:=0,oDlg:End())

ACTIVATE MSDIALOG oDlg Centered

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso confirmar verifica qual rotina vai chamar ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 1
	If nItem == 1
		A040Paes(cAlias,nReg,nOpcx)
	Else
		A040Pase(cAlias,nReg,nOpcx)
	EndIf
EndIf

oFontDlg:End()

Return NIL

/*
antigo a040ValTl
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt040VTl ³ Autor ³ Wanderley Goncalves   ³ Data ³ 17.04.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida tipo de laudo conforme selecoes anteriores		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ qmt0400VTL(void)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function qmt040VTL()
Local lRet := .t.

If M->QM9_ORGAFE == "E" .and. Empty(M->QM9_TIPAFE)
	If M->QM9_LAUDO $ "3$4"
	    If M->QM9_NROMED == 0
			Help( " ", 1, "A040TLINV" )  // Tipo de Laudo Inv lido para 
			lRet := .f. 				  // Calibra‡„o externa
		Else
			Help( " ", 1, "A040TCLINV" )//Tipo de Calibracao,Laudo e Nro. de Medicoes invalidos para calibracao externa.
			lRet := .f.
		Endif			
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³SomaLinOk ³ Autor ³ Fernando Godoy	    ³ Data ³ 06/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a linha da Getdados esta Ok					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto a ser verificado. 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Qmta040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SomaLinOk()
Local lRet := .T.

If Empty(aCols[n][1])
	If lExRev
		If Empty(aCols[Len(aCols),1]) .And. n > 1
			Adel( aCols, Len(aCols) )
			ASize( aCols, Len( aCols) - 1)
			n := Len( aCols )
			lRet := .T.
			oGetSoma:oBrowse:Refresh()
		Else
			Help( " ", 1, "JAGRAVADO" )
			MessageDlg(OemToAnsi(STR0070),,3) //"Nao e permitido alterar caracteristicas de pontos/padroes dessa escala. Existe revisao superior"
			lRet := .F.
		Endif
		Return lRet
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se deixar a ultima linha em branco, deleta a mesma ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(aCols[Len(aCols),1]) .And. n > 1
	Adel( aCols, Len(aCols) )
	ASize( aCols, Len( aCols) - 1)
	n := Len( aCols )
	lRet := .T.
ElseIf n == 1 .and. Empty(aCols[n][1])
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se campo ponto esta' preenchido                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	Help(" ",1,"QA_CPOOBR")
	lRet := .F.
EndIf

oGetSoma:oBrowse:Refresh()

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³PontosWin ³ Autor ³ Fernando Godoy	    ³ Data ³ 06/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Digita‡„o dos pontos.            						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Sem parametros.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Qmta040													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³	MOTIVO DA ALTERACAO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Iuri Seto     ³25/09/00³  --	 ³Alteracao do Especificado e Tolerancia  ³±±
±±³              ³        ³    	 ³do oGetSoma de inteiro para decimal.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PontosWin(aTabPad,oGetSoma,cFaixa,cTipo)

Local aColsSoma	:= Aclone( aCols	 )
Local aHeaderSoma := Aclone( aHeader )
Local nSoma 		:= n
Local nI 			:= 0
Local nE 			:= 0
Local cAux			:= "0"
Local aAlteracao	:= {}
Local lAlterou 	:= .T.
Local lRet			:= .F.
Local aTabShow 	:= {}
Local cMensag		:= ""
Local nTamPadrao	:= 10
Local oDlgPontos
Local oFnt
Local nPos			:= 0
Local nAux			:= 0
Local nDec			:= 0
Local cAuxMin	:= "0"
Local aTipTol :=QMTCombo("QMA_TIPTOL")
Local lAchou := .T.	
Local nLie
Local nLse
Local nLieAnt := -1
Local nLseAnt := -1
Local VAR03 := aCols[n][3]
Local VAR04 := aCols[n][4]
Local aArea 		:= GetArea()
Local lPergs		:= .T.
Local cIndex		:= ""
Local cKey			:= ""
Local cCond			:= ""
Local nIndex		:= 0
Local cToleraMa		:= ""	
Local cToleraMi		:= ""	
Local aAltera		:= {}
Local nX			:= 0
Local nd			:= 0
Private oGetPontos

oGetSoma:oBrowse:lDisablePaint := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a chamada vem da Tolerƒncia ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo == "T"
	If lExRev
		cMensag := Oemtoansi(STR0069) //"Confirma Visualiza‡„o ?"
	Else
		cMensag := Oemtoansi(STR0055) //"Confirma Altera‡„o ?"	
	Endif	
	cFaixa	:= aCols[n][1]
	cTipGrav:= aCols[n][6]
	cToleraMi:= aCols[n][3]
	cToleraMa:= aCols[n][4]	
Else
	For nI := 1 to Len( aCols )
		If Alltrim(M->VAR01) == Alltrim(aCols[nI][1]) .And. nI <> n
			Tone(3000,1)
			MsgStop(Oemtoansi(STR0056),Oemtoansi(STR0054)) //"Ponto j  cadastrado para esse tipo! Informe outro."
			lAlterou := .F.
			lRet		:= .F.
		EndIf
	Next nI
	If lExRev
		cMensag := Oemtoansi(STR0069) //"Confirma Visualiza‡„o ?"
	Else
		cMensag := Oemtoansi(STR0057)//"Confirma os dados ?"
	Endif	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define a faixa com o aCols atual ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFaixa := M->VAR01
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Alterou e se o campo faixa esta preenchido. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( cFaixa ) .And. lAlterou
	If lExRev
		MsgInfo(OemToAnsi(STR0070),OemToAnsi(STR0071)) //"Nao e permitido alterar caracteristicas de pontos/padroes dessa escala. Existe revisao superior" //"Pontos/Soma"
		aCols[n][3] := cToleraMi
		aCols[n][4] := cToleraMa		
	Endif
 
 	dbSelectArea("QM7")
	dbSetOrder(1)

	cKey   := "QM7_FILIAL+QM7_ESCALA+QM7_PONTO"
	cQuery := "SELECT QM7.QM7_FILIAL,QM7.QM7_ESCALA,QM7.QM7_PONTO,QM7.QM7_REVESC "
	cQuery += "FROM " + RetSqlName("QM7")+" QM7 "
	cQuery += "WHERE QM7.QM7_FILIAL='"+xFilial("QM7")+"' AND "
	cQuery += "QM7.QM7_ESCALA = '"+QM9->QM9_ESCALA+"'  AND "			
	cQuery += "QM7.QM7_REVESC = '"+QM9->QM9_REVESC+"'  AND "				
	cQuery += "QM7.D_E_L_E_T_<>'*' "
	cQuery += " ORDER BY " + SqlOrder(cKey)

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"QM7TRB", .F., .T.)

	While !QM7TRB->(Eof())
		lPergs := .F.
		Exit
	Enddo	

	QM7TRB->(dbCloseArea())	

	RestArea(aArea)
	
	If MsgYesNo(cMensag,Oemtoansi(STR0058)) //"Confirmacao"
		aCols   := {}
		aHeader := {}
		
		nTamPadrao := TamSx3("QMA_PADRAO")[1]
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta aHeader para a Getdados sem se basear no SX3 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lPergs
			AADD(aHeader,{OemToAnsi(STR0010) ,"QMA_PADRAO","@!",nTamPadrao,0,".f.","û",;
				"C","QM3"," "})
			AADD(aHeader,{OemToAnsi(STR0025) ,"PON02","@!",TamSX3("QM3_ESPEC")[1],0,".t.","û",;
				"C","QM3","V"})
			AADD(aHeader,{OemToAnsi(STR0064) ,"PON03","@!",TamSx3("QM3_TOLER")[1],0,".T.","û",;
				"C","QM3","V"})
			AADD(aHeader,{OemToAnsi(STR0065) ,"PON04","@!",TamSx3("QM3_UNIMED")[1],0,".t.","û",;
				"C","QM3","V"})
			AADD(aHeader,{OemToAnsi(STR0066) ,"PON05","@!",TamSx3("QM3_UNIMED")[1],0,".t.","û",;
				"C","QM3","V"})
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define quais colunas podem ser editadas ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Aadd( aAlteracao, "" )
	    Else
			AADD(aHeader,{OemToAnsi(STR0010) ,"QMA_PADRAO","@!",nTamPadrao,0,"a040Check()","û",;
				"C","QM3"," "})
			AADD(aHeader,{OemToAnsi(STR0025) ,"PON02","@!",TamSX3("QM3_ESPEC")[1],0,".t.","û",;
				"C","QM3","V"})
			AADD(aHeader,{OemToAnsi(STR0064) ,"PON03","@!",TamSx3("QM3_TOLMIN")[1],0,".T.","û",;
				"C","QM3","V"})
			AADD(aHeader,{OemToAnsi(STR0065) ,"PON04","@!",TamSx3("QM3_TOLER")[1],0,".T.","û",;
				"C","QM3","V"})
			AADD(aHeader,{OemToAnsi(STR0066) ,"PON05","@!",TamSx3("QM3_UNIMED")[1],0,".t.","û",;
				"C","QM3","V"})
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define quais colunas podem ser editadas ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Aadd( aAlteracao, "QMA_PADRAO" )
		Endif
		
		// Inclui coluna de registro atraves de funcao generica
		ADHeadRec("QM3",aHeader)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta array somente com os ponto da escala utilizada ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nI := 1 to len(aTabPad)
			If !Empty(aColsSoma[nSoma,1])
				If alltrim(aColsSoma[nSoma][1]) == alltrim(aTabPad[nI,6]) .and.;
					!aTabPad[nI,Len(aTabPad[nI])] // nao deletado
					Aadd( aTabShow, {aTabPad[nI,1],aTabPad[nI,2],;
						aTabPad[nI,3],aTabPad[nI,4],aTabPad[nI,5],;
						aTabPad[nI,8],aTabPad[nI,9]} ) //,aTabPad[nI,6]
				EndIf
			EndIf
		Next nI
		
		If !Empty( aTabShow )
			aCols  := Array( Len(aTabShow), Len(aHeader))
		Else
			aCols  := {{ Space(nTamPadrao),Space(TamSx3("QM3_ESPEC")[1]),;
				Space(TamSx3("QM3_TOLMIN")[1]),Space(TamSx3("QM3_TOLER")[1]),;
				Space(TamSx3("QM3_UNIMED")[1]),QM3->(Alias()),0,.F. }}
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta aCols com os dados pre-carregados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nI := 1 to Len(aTabShow)
			For nX := 1 to Len(aCols[nI])
				aCols[nI][nX] := aTabShow[nI][nX]
			Next nX
			aAdd(aCols[nI],.F.)
		Next nI
        
		DEFINE FONT oFnt NAME "Arial" BOLD
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Constroi a tela com a getDados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE MSDIALOG oDlgPontos FROM	110,62 TO 414,621 ;
			TITLE Oemtoansi(STR0029) PIXEL Of oDlgEscala // "Padr”es por ponto"
		
		@ 13, 3 TO 65, 150 OF oDlgPontos  PIXEL
		@ 39, 14 SAY STR0012 SIZE 26, 7 OF oDlgPontos PIXEL FONT oFnt // "Escala"
		@ 39, 44 SAY xPadR(alltrim(QM9->QM9_ESCALA),53) SIZE 56, 7 ;
			OF oDlgPontos PIXEL
		@ 39, 102 SAY STR0024 SIZE 26, 7 OF oDlgPontos PIXEL FONT oFnt // "Ponto"
		@ 39, 120 SAY xPadR(cFaixa,53) SIZE 53, 7 OF oDlgPontos PIXEL
		@ 39, 191 SAY OemToAnsi(STR0059) SIZE 38, 7 OF oDlgPontos PIXEL FONT oFnt // "Tp.Calc.Toler.:"
		@ 37, 235 COMBOBOX oCbxTol VAR cTipTol ITEMS aTipTol ON CHANGE (nTipTol:=oCbxTol:nAt) SIZE 45, 47 OF oDlgPontos PIXEL
        
		oCbxTol:bLostFocus := {||oCbxTol:Disable(),cTipGrav := oCbxTol:aItems[oCbxTol:nat]}
		
		If cTipo == "T" //Qdo da alteracao,nao deixar modificar o combo
			oCbxTol:SetText(cTipGrav)
			oCbxTol:Disable()
		Endif
			
		If lPergs
			oGetPontos := MsGetDados():New(55,3,140,275,3,"SomaLinPo",;
				"AllwaysTrue",,.T.,aAlteracao,,,999)
		Else
			oGetPontos := MsGetDados():New(52,5,140,275,2,".T.",;
				".T.",,.F.,aAlteracao)
		Endif        
			 
		ACTIVATE MSDIALOG oDlgPontos ON INIT EnchoiceBar(oDlgPontos,;
			IIF(!lExRev,{|| lRet:= .T.,SomaLinPo(),oDlgPontos:End()},{|| lRet:= .F.,oDlgPontos:End()}),{|| lRet := .F.,oDlgPontos:End()})
		For nd := 1 To Len(aCols)                              
		    If nd != 1 
		       If Empty(aCols[nd-1][1])
		          lRet := .F.
		       Endif 
		    Endif
			
			If aCols[nd][Len(aCols[nd])]
			    nPosTPad := Ascan( aTabPad, { |x| Alltrim(x[1])+Alltrim(x[2])+Alltrim(x[6]) ==;
			    								   Alltrim(aCols[nd][1])+Alltrim(aCols[nd][2])+Alltrim(aColsSoma[nSoma][1]) } ) 
				If nPosTPad > 0
					aTabPad[nPosTPad][Len(aTabPad[nPosTPad])] := .T.
				Endif	
				
		    Endif
		Next nd

		oFnt:End()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o aCols ficou em branco ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty( aCols[1][1] )                     
			lRet := .F.
		EndIf
		
		If lRet
			nAux := 0
			nDec := 0
			aColsSoma[nSoma][2] := "0"
			
			//Le os registros e procura se o tipo de calculo e numerico. Caso afirma-,
			//tivo, somente ira comparar qual a tolerancia e maior.
			//Caso contrario, devera converter para poder comparar a maior tolerancia

			For nI := 1 To Len(aCols)
				dbSelectArea("QM3")
				dbSetOrder(1)
				If !aCols[nI][Len(aCols[nI])]
					If dbSeek(xFilial("QM3")+aCols[nI][1])
						If nTipTol == 1 .and. nTipTol == Val(QM3->QM3_TIPTOL)
							lAchou := .F.
						Else
							lAchou := .T.
							Exit
						Endif
					Else 
						MessageDlg(STR0053,,3) //Padrao/Ponto nao encontrado
					Endif	
				Endif
			Next nI
			
			For nI := 1 to Len( aCols )
				If !aCols[nI][Len(aCols[nI])] // Soma se nao estiver deletado
					nAux := SuperVal(aColsSoma[nSoma][2]) + SuperVal(aCols[nI][2])
					nLieAnt := -1
					nLseAnt := -1
					For nE := 1 to Len(aCols)
						If !aCols[nE][Len(aCols[nE])] // Considera se nao estiver deletado
							If !lAchou						 
								If SuperVal(aCols[nE][3]) == 0
									cAuxMin := aCols[nE][3]								
								Endif
								If SuperVal(aCols[nE][3]) > SuperVal(cAuxMin)
									cAuxMin := aCols[nE][3]
								EndIf
								
								If SuperVal(aCols[nE][4]) == 0		
									cAux := aCols[nE][4]								
								Endif                   
		
								If SuperVal(aCols[nE][4]) > SuperVal(cAux)
									cAux := aCols[nE][4]
								EndIf
							Else   
								If nE <> 1
									nLieAnt := (SuperVal(aCols[nE-1][2])-(SuperVal(aCols[nE-1][2])*SuperVal(aCols[nE-1][3]))/100)
									nLseAnt := (SuperVal(aCols[nE-1][2])+(SuperVal(aCols[nE-1][2])*SuperVal(aCols[nE-1][3]))/100)														
								Endif
								nLie := (SuperVal(aCols[nE][2])-(SuperVal(aCols[nE][2])*SuperVal(aCols[nE][3]))/100)
								nLse := (SuperVal(aCols[nE][2])+(SuperVal(aCols[nE][2])*SuperVal(aCols[nE][3]))/100)							

        	                	If nLie == 0
	        	                	cAuxMin := aCols[nE][3]
        	                	Endif                      
        	                	If nLie > nLieAnt
            	            		cAuxMin := aCols[nE][3]
                	        	Endif                       
							    
								If nLse == 0
									cAux := aCols[nE][4]								
								Endif 							
							
								If nLse > nLseAnt
                        			cAux := aCols[nE][4]
                        		Endif                                               	
							Endif
					
							If QA_NumDec(aCols[nE][2]) > nDec
								nDec := QA_NumDec(aCols[nE][2])
							EndIf
						EndIf
					Next nE
					aColsSoma[nSoma][2] := StrTran(Str(nAux,TamSX3("QM3_ESPEC")[1],nDec),".",",")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Inclui os padroes dos pontos. ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nPoTab := 0
					If cTipo == "P"
						If QM9->QM9_TIPAFE == "5"
							Aadd(aTabPad,{aCols[ni][1],aCols[ni][2],aCols[ni][3],aCols[ni][4],aCols[ni][5],M->VAR01,cTipGrav,QM3->(Alias()),QM3->(Recno()),aCols[ni][Len(aCols[nI])]})
						Else
							Aadd(aTabPad,{aCols[ni][1],aCols[ni][2],aCols[ni][3],aCols[ni][4],aCols[ni][5],M->VAR01,cTipGrav,aCols[ni][Len(aCols[nI])] } )
						Endif
					Else
						nPoTab := Ascan( aTabPad, { |x| Alltrim(x[1]) == Alltrim(aCols[ni][1]) } )
						If nPoTab == 0
							If QM9->QM9_TIPAFE == "5"
								Aadd(aTabPad,{aCols[ni][1],aCols[ni][2],aCols[ni][3],aCols[ni][4],aCols[ni][5],aColsSoma[nSoma][1],cTipGrav,QM3->(Alias()),QM3->(Recno()),aCols[nI][Len(aCols[nI])] } )
							Else
								Aadd(aTabPad,{aCols[ni][1],aCols[ni][2],aCols[ni][3],aCols[ni][4],aCols[ni][5],aColsSoma[nSoma][1],cTipGrav,aCols[nI][Len(aCols[nI])] } )
							Endif
						EndIf
					EndIf			
					// Para deletar
					If !empty(aColsSoma[nSoma][1])
						nPos := Ascan( aTabPad, { |x| Alltrim(x[6])+AllTrim(x[1]) ==;
							  Alltrim(aColsSoma[nSoma][1])+ Alltrim(aCols[nI][1]) } )
					Else
						nPos := Ascan( aTabPad, { |x| Alltrim(x[6])+AllTrim(x[1]) ==;
								  Alltrim(M->VAR01)+ Alltrim(aCols[nI][1]) } )
					EndIf

					If nPos <> 0
						If empty(aColsSoma[nSoma][1])
							aTabPad[nPos,6] := SubStr(M->VAR01,1,nTamQM3)//aCols[nI,5] 
						Else
							aTabPad[nPos,6] := SubStr(aColsSoma[nSoma][1],1,nTamQM3)//aCols[nI,5] 					
						Endif										   
					Else
					   Aadd(aTabPad,{aCols[nI][1],aCols[nI][2],aCols[nI][3],aCols[nI][4],aCols[nI][5],aColsSoma[nSoma][1],cTipGrav,aCols[nI][6]} )
					Endif   
			    Endif
			Next nI
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a tolerancia digita ‚ maior que a cadastrada ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cTipo == "T"
				If !lExRev
					M->VAR03 := aCols[n][3]					

					If SuperVal(cAuxMin) > SuperVal(M->VAR03)
						M->VAR03 := cAuxMin
					EndIf                   

					M->VAR04 := aCols[n][4]
							
					If SuperVal(cAux) > SuperVal(M->VAR04)
						M->VAR04 := cAux
					EndIf                   				
				Else
					M->VAR03	:= cToleraMi
					M->VAR04	:= cToleraMa	
				Endif	
			Else
				aColsSoma[nSoma][3] := cAuxMin
				aColsSoma[nSoma][4] := cAux
			EndIf
			aColsSoma[nSoma][5] := aCols[1][5]
			aColsSoma[nSoma][6] := cTipGrav
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inclui a na tabela os novos pontos ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cTipo == "P"
				Aadd(aTabela,{M->VAR01,aColsSoma[nSoma][2],aColsSoma[nSoma][3],aColsSoma[nSoma][4],aColsSoma[nSoma][5]})
			EndIf 	  
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura as variaveis para a getdados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCols   := Aclone( aColsSoma )
		aHeader := Aclone( aHeaderSoma )
		n		:= nSoma
	Else
		lRet := .F.
	EndIf
EndIf

Aadd(aAltera,"VAR03")
Aadd(aAltera,"VAR04")
oGetSoma:aAlter := aAltera
oGetSoma:oBrowse:aAlter := aAltera
oGetSoma:oBrowse:lDisablePaint := .F.

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³VerLin 	³ Autor ³ Fernando Godoy 	    ³ Data ³ 06/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a linha digitada esta vazia para liberar apenas³±±
±±³			 ³ o primeiro get,  caso contr rio libera apena o Terceiro.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Sem parametros.								  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Qmta040									  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VerLin()
Local aAlter := {}
	If n == Len(aCols) .And. Empty(aCols[Len(acols),1])
		Aadd( aAlter , "VAR01" )
		oGetSoma:aAlter := aAlter
		oGetSoma:oBrowse:aAlter := aAlter
		oGetSoma:Refresh()
	Else
		Aadd( aAlter , "VAR03" )
		oGetSoma:oBrowse:aAlter := aAlter
		oGetSoma:Refresh()  		
		
		Aadd( aAlter , "VAR04" )
		oGetSoma:oBrowse:aAlter := aAlter
		oGetSoma:aAlter := aAlter
		oGetSoma:Refresh()  		

	EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³SomaLinPo ³ Autor ³ Fernando Godoy	    ³ Data ³ 06/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a linha da Getdados esta Ok					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto a ser verificado. 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Qmta040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SomaLinPo()
Local aArea := GetArea()
Local lRet := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se deixar a ultima linha em branco, deleta a mesma ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Empty(aCols[Len(aCols),1]) .And. n > 1
	Adel( aCols, Len(aCols) )
	ASize( aCols, Len( aCols) - 1 )
	n := Len( aCols )           
	lRet := .T.
ElseIf n == 1 .and. Empty(aCols[n][1])
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se campo ponto esta' preenchido                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	Help(" ",1,"QA_CPOOBR")
    lRet := .F.                 
EndIf

oGetPontos:oBrowse:Refresh()

RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³a040Check ³ Autor ³ Fernando Godoy  	    ³ Data ³ 21/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o padrao informado existe no cadastro. 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Sem parametros.								  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Qmta040									  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a040Check()

Local lRet	:= .T.
Local aArea := GetArea()
Local nI 	:= 1
Local nCoef := 1
Local nPosQMA		:= ASCAN(aHeader,{|x| alltrim(x[2]) = "QMA_PADRAO"})
dbSelectArea("QM3")
dbSetOrder(1)
If !dbSeek( xFilial("QM3") + M->QMA_PADRAO )
	Tone(3000,1)
	MsgStop(OemtoAnsi(STR0053),OemtoAnsi(STR0054))//Padrao nao encontrado / Atencao
	lRet := .F.
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se padr„o ja foi cadastrado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QM3->QM3_TIPPAD == "A"
		MessageDlg(STR0068,,3)//"Para escalas do tipo soma, nao e permitido cadastrar padroes tipo Atributo" 			 
		If nPosQMA <> 0
			aCols[n][nPosQMA] := CriaVar("QMA_PADRAO",.T.)
		Endif	
		lRet := .F.
	Else	
		For nI = 1 to len(aCols)	
			If Alltrim(M->QMA_PADRAO) == Alltrim(aCols[nI][1]) .And. nI <> n
				HELP(" ",1,"A040PACAD")  // "Padr„o j  cadastrado para este Ponto"
				lRet := .F.
				Exit
			EndIf
		Next nI
	Endif	

	If lRet
		If !Empty(QM3->QM3_VALDAF)
			If dDataBase > QM3->QM3_VALDAF
				MsgStop(STR0072,STR0073) //Aviso de padrao vencido
				aCols[n][nPosQMA] := CriaVar("QMA_PADRAO",.T.)
				lRet := .F.
			Endif		
		Endif	
	Endif
	If lRet
		If Len(aCols) > 0  
			For nI := 1 to Len(aCols)
				If Alltrim(QM3->QM3_UNIMED) <> Alltrim(QM9->QM9_UNIMED) 
					dbSelectArea("SAP")
					dbSetOrder(1)
					If !dbSeek(xFilial("SAP")+QM3->QM3_UNIMED+QM9->QM9_UNIMED)
						lRet := .F.
						HELP(" ",1,"A140UNIDIF")
						Exit
					Else 
						nCoef := SAP->AP_COEF
					Endif	
				EndIf
			Next nI
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se tudo estiver Ok inclui no Acols as especificacoes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		If nCoef <> 1 // Unidades Diferentes
			aCols[n][2] := StrTran(Str(SuperVal(QM3->QM3_ESPEC)*nCoef),".",",")
			aCols[n][3] := StrTran(Str(SuperVal(QM3->QM3_TOLMIN)*nCoef),".",",")
			aCols[n][4] := StrTran(Str(SuperVal(QM3->QM3_TOLER)*nCoef),".",",")			
			aCols[n][5] := QM9->QM9_UNIMED
		Else 
			aCols[n][2] := QM3->QM3_ESPEC
			aCols[n][3] := QM3->QM3_TOLMIN
			aCols[n][4] := QM3->QM3_TOLER
			aCols[n][5] := QM3->QM3_UNIMED					
		Endif	
	EndIf
	
EndIf

RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³a040Grava ³ Autor ³ Fernando Godoy		³ Data ³ 25/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava as informacoes sobre as escalas. 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Sem parametros.							 			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Qmta040													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³	MOTIVO DA ALTERACAO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Iuri Seto     ³25/09/00³  --	 ³Alteracao do Especificado e Tolerancia  ³±±
±±³              ³        ³    	 ³do oGetSoma de inteiro para decimal.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function a040Grava
Local nI 	:= 1
Local nPos := 0
Local nUsado  := IIF (Findfunction("A040Soma"),Len(aHeader),0)

IF Findfunction("A040Soma").And. nUsado <> 0 .And. aCols[n][nUsado+1]
	MSGAlert(STR0123)
EndIf

dbSelectArea("QMA")
dbSetOrder(1)
For nI := 1 to Len( aTabpad )
	If !dbSeek( xFilial("QMA") + QM9->QM9_ESCALA + QM9->QM9_REVESC +;
		aTabPad[nI][6] + aTabPad[nI][1] )
		If !aTabPad[nI][Len(aTabpad[nI])]
		   RecLock("QMA",.T.)
		   QMA->QMA_FILIAL := xFilial('QMA')
		   QMA->QMA_ESCALA := QM9->QM9_ESCALA
	 	   QMA->QMA_REVESC := QM9->QM9_REVESC
		   QMA->QMA_FAIXA  := aTabPad[nI][6]
		   QMA->QMA_PADRAO := aTabPad[nI][1]
		   If (nPos:=Ascan( aCols, { |x| Alltrim(x[1]) == Alltrim(aTabPad[nI][6]) } )) > 0
				QMA->QMA_TOLMIN := Alltrim(aCols[nPos][3])
				QMA->QMA_TOLER := Alltrim(aCols[nPos][4])
				QMA->QMA_TIPTOL := SubStr(aCols[nPos][6],1,1)
		   EndIf 
		   MsUnLock()
		Endif
	Else
		If !aTabPad[nI][Len(aTabPad[nI])]
			If (nPos:=Ascan( aCols, { |x| Alltrim(x[1]) == Alltrim(aTabPad[nI][6]) } )) > 0
				RecLock("QMA",.F.)
				QMA->QMA_TOLMIN := Alltrim(aCols[nPos][3]) 
				QMA->QMA_TOLER  := Alltrim(aCols[nPos][4]) 
				MsUnLock()
			EndIf
		Else
			RecLock("QMA",.F.)
			QMA->(DbDelete())
			MsUnlock()
		EndIf
	EndIf
Next nI

N := 1

Return Nil


/*
antigo a040VOrg
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³qmt040VOrg³ Autor ³ Wanderley Goncalves   ³ Data ³ 18/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se deve ser digitado Departamento ou Laboratorio  ³±±
±±³			 ³ como Orgao Calibrador, de acordo com o campo destino da	  ³±±
±±³			 ³ calibracao, limpando o campo oposto, se necessario.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Sem parametros.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Qmta040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt040VOrg()

If M->QM9_ORGAFE == 'I'
	M->QM9_LABOR := CriaVar("QM9_LABOR",.T.)
ElseIf M->QM9_ORGAFE == 'E'
	M->QM9_DEPTO := CriaVar("QM9_DEPTO",.T.)
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QMA040VIU³ Autora³ Iuri Seto             ³ Data ³ 18/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verif. se a escala esta cad. em um instr. utilizado na cal.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QMA040VIU()								  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T., e utilizado na cal.; .F., nao e utilizado na cal.	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QMTA040									  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/
Function QMA040VIU()
Local 	lRet	:= .F.
Local	cIndice := CriaTrab(NIL,.F.)
Local	cChave 	:= "QMI->QMI_FILIAL+QMI->QMI_ESCPAD"   
Local	cExpr	:= "QMI->QMI_FILIAL == '" + xFilial('QMI') + "' .And. QMI->QMI_ESCPAD == '" + QM9->QM9_ESCALA +"'"

IndRegua("QMI",cIndice,cChave,,cExpr,,.F.)
nIndice := RetIndex("QMI")
dbSetOrder(nIndice+1)
dbGoTop()  
If !Eof()
	lRet := .T.
EndIf

dbSelectArea("QMI")
RetIndex("QMI")                      
Set Filter to
Ferase(cIndice + OrdBagExt())
QMI->(DbSetOrder(1))
QMI->(DbGoTop())

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QMA040VPS³ Autora³ Iuri Seto             ³ Data ³ 18/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verif. se a escala esta cad. como padrao secundario na cal.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QMA040VPS()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T., e utilizado na cal.; .F., nao e utilizado na cal.	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QMTA040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/
Function QMA040VPS()
Local 	lRet	:= .F.
Local	cIndice := CriaTrab(NIL,.F.)
Local	cChave 	:= "QMS->QMS_FILIAL+QMS->QMS_ESCPAD"   
Local	cExpr	:= "QMS->QMS_FILIAL == '" + xFilial('QMS') + "' .And. QMS->QMS_ESCPAD == '" + QM9->QM9_ESCALA + "'"

IndRegua("QMS",cIndice,cChave,,cExpr,,.F.)
nIndice := RetIndex("QMS")
dbSetOrder(nIndice+1)
dbGoTop()  
If !Eof()
	lRet := .T.
EndIf

dbSelectArea("QMS")
RetIndex("QMS")                      
Set Filter to
Ferase(cIndice + OrdBagExt())
QMI->(DbSetOrder(1))
QMI->(DbGoTop())

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QMA040PRe³ Autora³ Iuri Seto             ³ Data ³ 24/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a proxima revisao disponivel.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QMA040PRe(ExpC1)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Escala											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Proxima Revisao da escala.								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QMTA040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/
Function QMA040PRe(cEscala)
Local	cAlias	:= Select()
Local	cOrdem	:= IndexOrd()
Local	nRegis	:= Recno()
Local	cProxRev:= ""

DbSelectArea("QM9")
QM9->(DbSetOrder(1))
If QM9->(DBSeek(xFilial("QM9")+cEscala))
EndIf

DbSelectArea(cAlias)
DbSetOrder(cOrdem)
DbGoto(nRegis)
Return(cProxRev)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QMA040UltR³ Autora³ Iuri Seto             ³ Data ³ 28/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a ultima revisao da escala enviando como parametro.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QMA040UltR(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da escala                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QMA040UltR(cEscala)
Local cRevisao 	:= ""            
Local cAlias	:= Select()
Local nOrdem	:= IndexOrd()
Local nRegis 	:= RECNO()

DbSelectArea("QM9")
DbSetOrder(1)
If QM9->(DbSeek(xFilial("QM9")+cEscala))
	cRevisao := QM9->QM9_REVESC
EndIf

DbSelectArea(cAlias)
DbSetOrder(nOrdem)
DbGoto(nRegis)
Return(cRevisao)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QMA040DpPa³ Autora³ Iuri Seto             ³ Data ³ 14/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Duplica a associacao de padroes.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QMA040DpPa(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Revisao do padrao origem                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QMA040DpPa(cRevInv)
Local nRegis
Local bCampo := {|nCPO| Field(nCPO) }
Local i := 0

DbSelectArea("QMC")
DbSetOrder(1)
IF QMC->(DbSeek(xFilial("QMC")+QM9->QM9_ESCALA+cRevInv))
	While !EOF() .And. xFilial("QMC")+QM9->QM9_ESCALA+cRevInv ==;
		QMC->QMC_FILIAL+QMC->QMC_ESCALA+QMC->QMC_REVINV
	
		FOR i := 1 TO FCount()
			M->&(EVAL(bCampo,i)) := FieldGet(i)
		NEXT i
		M->QMC_REVESC := QM9->QM9_REVESC
		M->QMC_REVINV := QM9->QM9_REVINV
		nRegis := Recno()							
									
		RecLock("QMC",.T.)
		For i := 1 TO FCount()
			FieldPut(i,M->&(EVAL(bCampo,i)))
		Next i
		MsUnlock()   
	                    	
		DbGoto(nRegis)
		DbSkip()
	EndDo							
EndIf
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QMA040DpPS³ Autora³ Iuri Seto             ³ Data ³ 14/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Duplica a associacao de padroes do tipo soma.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QMA040DpPS(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Revisao do padrao origem                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QMA040DpPS(cRev)
Local nRegis
Local bCampo := {|nCPO| Field(nCPO) }
Local i := 0

DbSelectArea("QMA")
DbSetOrder(1)
IF QMA->(DbSeek(xFilial("QMA")+QM9->QM9_ESCALA+cRev))
	While !EOF() .And. xFilial("QMA")+QM9->QM9_ESCALA+cRev ==;
		QMA->QMA_FILIAL+QMA->QMA_ESCALA+QMA->QMA_REVESC
         	
		FOR i := 1 TO FCount()
			M->&(EVAL(bCampo,i)) := FieldGet(i)
		NEXT i
		M->QMA_REVESC := QM9->QM9_REVESC
		nRegis := Recno()							
								
		RecLock("QMA",.T.)
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
±±³Fun‡…o	 ³QMA040Cal ³ Autora³ Iuri Seto             ³ Data ³ 14/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a rev. da escala ja foi utilizada na calibracao³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMA040Cal(cEscala,cRevEsc)
Local 	lRet	:= .F.
DbSelectArea("QM7")
QM7->(DbSetOrder(2))
If QM7->(DbSeek(xFilial("QM7")+cEscala+cRevEsc))
	lRet := .T.
EndIf
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³QMTCombo      ºAutor  ³Denis Martins   º Data ³  08/22/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que le o itens do combo no SX3 e retorna num array   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA040                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMTCombo(cCampo)
Local aArea    := GetArea()
Local cBox     := ""
Local aBox     := {}
Local nPosicao1:= 0
Local nPosicao2:= 0
Local cElem1 	:= cElem2:= ""

dbSelectArea("SX3")
dbSetOrder(2)
If ( MsSeek(cCampo) )
	cBox  := x3cbox(cCampo)
	While ( !Empty(cBox) )
		nPosicao1   := At(";",cBox)
		If ( nPosicao1 == 0 )
			nPosicao1 := Len(cBox)+1
		EndIf
		nPosicao2   := At("=",cBox)
		cElem1 := SubStr(cBox,1,nPosicao2-1)
		cElem2 := SubStr(cBox,nPosicao2+1,nPosicao1-nPosicao2-1)
		aadd(aBox,cElem1+' - '+cElem2)
		cBox := SubStr(cBox,nPosicao1+1)
	EndDo
EndIf
dbSelectArea("SX3")
dbSetOrder(1)

RestArea(aArea)
Return(aBox)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QMTCBox  ³ Autor ³ Denis Martins         ³ Data ³ 08/22/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna String com descricao do combo                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QMTCBox(ExpC1,ExpC2)                              		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Campo a ter o Combo pesquisado                     ³±±
±±³          ³ ExpC2 = Conteudo do campo                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Generico                               					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function QMTCBox(cCampo, cConteudo)
Local cBox := Posicione("SX3", 2, cCampo, "x3CBox()")
Local nPos := At(cConteudo + "=", cBox)
Local cSub := SubStr(cBox, nPos)
Local nFim := If(";" $ cSub, At(";", cSub) - 1, Len(cSub))
Local cRet := If(nPos=0,"",SubStr(cSub, 1, nFim))
cRet := StrTran(cRet,"="," - ")
Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³G040Temp()ºAutor  ³Denis Martins       º Data ³  10/01/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera arquivo temporario e grava arquivos auxiliar para veri-º±±
±±º          ³ficar se a escala corrente podera sofrer alteracao no Tipo  º±±
±±º          ³de Calibracao.                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA040                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function G040Temp()
Local cIndice	:= ""
Local cChave
Local cExpr
Local lRet := .T.
Local aArea := GetArea()
Local nIndice := 0

dbSelectArea("QMK")
dbSetOrder(01)
dbGoTop()

cChave := "SELECT QMK_FILIAL,QMK_ESCALA,QMK_TIPO,QMK_REVTIP"
cChave += " FROM " + RetSqlName("QMK") +" QMK "
cChave += " WHERE QMK.QMK_FILIAL = '"	+ xFilial("QMK") + "' AND "
cChave += " QMK.QMK_ESCALA = '" + M->QM9_ESCALA + "' AND " 
cChave += " QMK.D_E_L_E_T_<>'*' "

dbUseArea(.T., "TOPCONN", TCGenQry(,,cChave),"TRBMK", .F., .T.)
dbSelectArea("TRBMK")

dbGoTop()  
If Eof()
	lRet := .F.
EndIf

If lRet
	While !Eof()
		IMPTMP->(dbAppend())
		IMPTMP->TMP_FILIAL	:=	TRBMK->QMK_FILIAL 
		IMPTMP->TMP_ESCALA	:=	TRBMK->QMK_ESCALA 
		IMPTMP->TMP_TIPO	:=	TRBMK->QMK_TIPO
		IMPTMP->TMP_REVTIP	:=	TRBMK->QMK_REVTIP		
	dbSkip()
	Enddo
Endif

dbSelectArea("QMK")
RetIndex("QMK")                      
Set Filter to
Ferase(cIndice+OrdBagExt())

If ( Select("TRBMK") != 0 )
    DbSelectArea("TRBMK")
    DbCloseArea()
	FErase("TRBMK"+GetDBExtension()) 
	FErase("TRBMK"+OrdBagExt())
EndIf	

RestArea(aArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³qmt040Grv ºAutor  ³Denis Martins       º Data ³  22/04/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realizar gravacao do campo Revisao Invertida apos inclusao  º±±
±±º          ³da escalas.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA040()                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt040grv()

RecLock("QM9",.F.)
Replace QM9->QM9_REVINV with Inverte(QM9->QM9_REVESC,2)
MsUnLock()

Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QMTA040EnBar³ Autor ³ Denis Martins              ³ Data ³ 25/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Monta a Enchoice Bar                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QMTA040EnBar( oDlg, bOk, bCancel, nOpc )                       	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ oDlg       ³ Objeto da Tela que contera a enchoice                ³±±
±±³           ³ bOk        ³ Bloco executado quando da confirmacao(Botao Ok)      ³±±
±±³           ³ bCancel    ³ Bloco executado quando do cancelamento(Botao Cancela)³±±
±±³           ³ nOpc       ³ Opcao de selecao do aRotina                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QMTA140                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QMTA040EnBar( oDlg, bOk, bCancel,nOpc )
Local aButtons := {}
Default nOpc	:= 4
aAdd(aButtons,{"SDUPROP",{|| QMT040AtPadr(.F.,oDlg,nOpc)},OemToAnsi(STR0120),OemToAnsi(STR0074)}) //"Padroes Automaticos"
EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QMT040AtPadr ³ Autor ³ Denis Martins              ³ Data ³ 25/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Gera Padroes Automatico                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ A040AtPadr() 							                      	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ lCads      ³ Verifica se vem do cadastro de Padroes                ³±±
±±³           ³ oDlg       ³ Janela                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QMTA040                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QMT040AtPadr(lCads,oDlg,nOpc)
Local cCads := STR0074//"Gera Padroes"
Local oDlgPd
Local oGrpPd
Local oGrpIn                
Local oCbx
Local oCbxTT
Local lExEsc	:= .T.
Local nOpca     := 0
Local lRetu     := .T.
Default lCads	:= .F.
Default nOpc	:= 4
Private cDesPUt	:= GetMv("MV_QPDAUT",.F.,"PDAUTO") 
Private cPits
Private oGetFin         
Private oGetIni
Private oGetPas
Private oGetIncer
Private nVlrIni 
Private nVlrFin 
Private cPasso	:= Space(3)         
Private cCbx
Private nTipT	:= 1
Private nTipoTo := 1
Private cIncer	:= CriaVar("QM3_INCERT",.F.)
Private oGetTMa
Private oGetTMI
Private cTolMx	:= CriaVar("QM3_TOLER",.F.)
Private cTolMi	:= CriaVar("QM3_TOLMIN",.F.)
Private oGetUM
Private cUnMi	:= CriaVar("AH_UNIMED",.F.)
Private cCbxTT	:= CriaVar("QM3_TIPTOL",.F.)
Private oGetNCer 
Private cNumCer := CriaVar("QM3_CERTIF",.F.)
Private oGetFAfe
Private nFafe	:= CriaVar("QM3_FREQAF",.F.)
Private oGetDtCal 
Private dDtCals := dDataBase
Private oGetVAfe 
Private dDtAfer := dDataBase
Private oChkPto 
Private lChkPto := .T.
Private lObCad	
Private lPergta	:= .T.

If lCads
	nVlrIni := CriaVar("QM9_ESCALI",.F.)
	nVlrFin := CriaVar("QM9_ESCALF",.F.)
	lObCad	:= .T.
Else
	nVlrIni := M->QM9_ESCALI
	nVlrFin := M->QM9_ESCALF
	cUnMi	:= M->QM9_UNIMED	
	If !(M->QM9_TIPAFE $ "4|8| ")
		lObCad	:= Obrigatorio(aGets,aTela)
	Else
		Help( " ", 1, "A040NPAUT" ) //Nao eh permitido associar padroes para esse tipo de laudo
		lObCad	:= 	.F.
	Endif	
Endif	                                


If lObCad
	
	DEFINE MSDIALOG oDlgPd TITLE cCads FROM 9,0 TO 33,50 OF oMainWnd
	
	@ 2.2,.5 Group oGrpPd TO 5.2,24.3 LABEL STR0075 OF oDlgPd COLOR CLR_BLUE   //"Valores"
	@ 3,1.2	SAY STR0076	OF oDlgPd  //"Inicial"
	@ 3,3.3	MSGET oGetIni VAR nVlrIni	OF oDlgPd  PICTURE PesqPict("QM9","QM9_ESCALF") SIZE 35,7.5 VALID Eval({||QA_ENUM("nVlrIni"),cPits := QA_PICT(,,nVlrIni,nVlrIni,.F.)})  //cCampo,nDecim,nVlIn,nVlFin,lFzPt 
	@ 3,9.5	SAY STR0077	OF oDlgPd  //"Final"
	@ 3,11.6 MSGET oGetFin VAR nVlrFin	OF oDlgPd PICTURE PesqPict("QM9","QM9_ESCALF") SIZE 35,7.5 VALID Eval({||QA_ENUM("nVlrFin")}) 
	@ 3,18.1 SAY STR0078 OF oDlgPd  //"Passo"
	@ 3,20.2 MSGET oGetPas VAR cPasso	OF oDlgPd SIZE 20,7.5 
	@ 55,9 CHECKBOX oChkPto VAR lChkPto SIZE 053,006 OF oDlgPd PROMPT OemToAnsi(STR0116)//"Cria Ponto Inicial"	
	
	@ 5.6,.5 Group oGrpIn TO 12.1,24.3 LABEL STR0079 OF  oDlgPd COLOR CLR_BLUE   //"Informacoes"
	@ 6.5,1.1 SAY STR0080	OF oDlgPd SIZE 20,7.5 	//"Tipo Padrao"
	@ 6.4,5.3 COMBOBOX oCbx VAR cCbx ITEMS {STR0081,STR0082,STR0083} ON CHANGE (nTipT:=oCbx:nAt,qmt040VPadAOS()) SIZE 45, 47 OF oDlgPd //Objetivo # Subjetivo # Atributo
	@ 7.7,1.1 SAY STR0084	OF oDlgPd SIZE 20,7.5 	//6
	@ 7.7,5.3 MSGET oGetIncer VAR cIncer OF oDlgPd PICTURE PesqPict("QM3","QM3_INCERT") SIZE 35,7.5 VALID Eval({||QA_ENUM("cIncer")}) 
	@ 9,1.1 SAY STR0065	OF oDlgPd SIZE 20,7.5 	
	@ 9,5.3 MSGET oGetTMa VAR cTolMx OF oDlgPd PICTURE PesqPict("QM3","QM3_TOLER") SIZE 35,7.5 VALID Eval({||QA_ENUM("cTolMx")}) 
	@ 10.5,1.1 SAY STR0064	OF oDlgPd SIZE 20,7.5 	
	@ 10.5,5.3 MSGET oGetTMi VAR cTolMi OF oDlgPd PICTURE PesqPict("QM3","QM3_TOLMIN") SIZE 35,7.5  VALID Eval({||QA_ENUM("cTolMi")}) 
	@ 11.8,1.1 SAY STR0085	OF oDlgPd SIZE 20,7.5 	
	@ 11.8,5.3 MSGET oGetUM VAR cUnMi OF oDlgPd PICTURE PesqPict("SAH","AH_UNIMED") SIZE 18,7.5  F3 "SAH";	
		VALID Eval( {|| lExEsc := ExistCpo("SAH",cUnMi),If(!lCads,If(lExEsc,QMT040CoUn(cUnMi),.F.),lExEsc)})  
	@ 6.5,13 SAY STR0095	OF oDlgPd SIZE 18,7.5 //Tp.Tolerancia	
	@ 6.4,17.2 COMBOBOX oCbxTT VAR cCbxTT ITEMS {STR0093,STR0094} ON CHANGE (nTipoTo:=oCbxTT:nAt) SIZE 45, 47 OF oDlgPd //Numerico - Percentual

	@ 7.7,13 SAY STR0096 OF oDlgPd SIZE 20,7.5 	//Numero de Certificado
	@ 7.7,17.2 MSGET oGetNCer VAR cNumCer OF oDlgPd PICTURE PesqPict("QM3","QM3_CERTIF") SIZE 35,7.5   
	@ 9,13 SAY STR0097 OF oDlgPd SIZE 20,7.5 //Data de Calibracao
	@ 9,17.2 MSGET oGetDtCal VAR dDtCals OF oDlgPd PICTURE PesqPict("QM3","QM3_DATAF") SIZE 40,7.5  
	@ 10.5,13 SAY STR0098 OF oDlgPd SIZE 20,7.5 	//Frequencia de Afericao
	@ 10.5,17.2 MSGET oGetFAfe VAR nFafe OF oDlgPd PICTURE PesqPict("QM3","QM3_FREQAF") SIZE 35,7.5  
	@ 11.8,13 SAY STR0099 OF oDlgPd SIZE 20,7.5 	//Data de Afericao
	@ 11.7,17.2 MSGET oGetVAfe VAR dDtAfer OF oDlgPd PICTURE PesqPict("QM3","QM3_VALDAF") SIZE 40,7.5  
	oGetFAfe:bLostFocus := {|| dDtAfer := dDtCals+nFafe}
	oGetVAfe:Refresh()

	ACTIVATE MSDIALOG oDlgPd ON INIT QMTA040EnPd(oDlgPd,;
	{||(lRetu := QMT040VPdAut(oDlgPd,lCads,oDlg,nOpc),If(lRetu,(nOpca := 1,oDlgPd:End()),nOpca := 0))},{||lRetu := .t.,nOpca:= 0,oDlgPd:End()},lCads) CENTERED

	
	If nOpca == 1
		If oDlg <> Nil
			oDlg:End()
		Endif
	Endif
Endif

Return lRetu
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT040VPdAutºAutor  ³Denis Martins       º Data ³  25/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida gravacao de padroes e associa os padroes a escala cor- º±±
±±º          ³rente                                                       	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Exp1.:Dialog                                                 	º±±
±±º          ³Exp2.:Cadastro de Padroes / Escalas                         	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA040                                                   	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT040VPdAut(oDlgPd,lCads,oDlg,nOpc)
Local lRet	:= .T.
Local lVez	:= 1
Local nTot	:= 0
Local cCods	:= ""
Local lFirst	:= .T.
Local nTolMx	:= 0
Local nTolMi	:= 0
Local nIncers	:= 0
Local lGrvOk	:= .F.
Local aGrvQMC	:= {}
Local nx		:= 1
Local lMsYNo	:= .F.
Local lqm040NPa := ExistBlock("qm040NPa")
Default nOpc	:= 4

If Empty(nVlrIni)
	MessageDlg(STR0086,,3) //"Favor digitar o campo Valor Inicial"			
	lRet	:= .F.
Endif

If Empty(nVlrFin)
	MessageDlg(STR0087,,3) //"Favor digitar o campo Valor Final"				
	lRet	:= .F.	
Endif

If Empty(cPasso)
	MessageDlg(STR0088,,3) //"Favor digitar o campo Passo"					
	lRet	:= .F.	
Endif

If Empty(nTipT)
	MessageDlg(STR0089,,3) //"Favor digitar o campo Tipo Padrao"						
	lRet	:= .F.	
Endif

If nTipT == 1
/*	
	If Empty(cTolMx)
		MessageDlg(STR0091,,3) //"Favor digitar o campo Tolerancia Maxima"
		lRet	:= .F.		
	Endif
	
	If Empty(cTolMi)
		MessageDlg(STR0092,,3) //"Favor digitar o campo Tolerancia Minima"
		lRet	:= .F.		
	Endif
*/
	If Empty(cCbxTT)
		MessageDlg(STR0100,,3) //"Favor digitar o campo Tipo de Tolerancia"
		lRet	:= .F.		
	Endif
	
	If Empty(cNumCer)
		MessageDlg(STR0101,,3) //"Favor digitar o campo Numero do Certificado"
		lRet	:= .F.		
	Endif

	If Empty(nFafe)
		MessageDlg(STR0102,,3) //"Favor digitar o campo Frequencia de Afericao"
		lRet	:= .F.		
	Endif
Endif

If Empty(cUnMi)
	MessageDlg(STR0103,,3) //"Favor digitar o campo Unidade de Medida"
	lRet := .F.
Endif

If lRet
	lVez := .T.
	lFirst := .T.
	nTot := 0
	
    Do While lVez
		dbSelectArea("QM3")
		dbSetOrder(1)

		If lFirst
			nVlrIni := StrTran(nVlrIni,".",",")	  
			nTot := SuperVal(nVlrIni)
			nTolMx := SuperVal(cTolMx)
			nTolMi := SuperVal(cTolMi)
			nIncers := SuperVal(cIncer)
		Else
			nTot := nTot + SuperVal(cPasso)
		Endif      

		If nTot > SuperVal(nVlrFin)		
			lVez := .F.
		Endif
		
		If lChkPto
			If lqm040NPa //Cria nome de acordo com a necessidade do cliente                  
				cCods := ExecBlock("qm040NPa",.F.,.F.,{cDesPUt,nTot})
			Else // Parametro + Valor Inicial
				cCods := Alltrim(SubStr(cDesPUt,1,6))+Alltrim(Str(nTot))		
			Endif	
        Else
			If !lFirst
				If lqm040NPa //Cria nome de acordo com a necessidade do cliente                   
					cCods := ExecBlock("qm040NPa",.F.,.F.,{cDesPUt,nTot})
				Else // Parametro + Valor Inicial
					cCods := Alltrim(SubStr(cDesPUt,1,6))+Alltrim(Str(nTot))		
				Endif	  
			Else
				nTot := nTot + SuperVal(cPasso)
				If lqm040NPa //Cria nome de acordo com a necessidade do cliente                   
					cCods := ExecBlock("qm040NPa",.F.,.F.,{cDesPUt,nTot})
				Else
					If nTot > SuperVal(nVlrFin)		
						lVez := .F.
					Else
						cCods := Alltrim(SubStr(cDesPUt,1,6))+Alltrim(Str(nTot))			
					Endif	
				Endif	
			Endif
        Endif

		cCods := PadR(cCods,TamSX3("QM3_PADRAO")[1])
	
		lFirst := .F.

		If Empty(cCods)
			MessageDlg(STR0104,,2) //"Nenhum ponto padrao criado !!!"
			lVez := .F.		
			Exit
		Endif

		If lVez
			If !dbSeek(xFilial()+cCods) //Colocar dbSelectArea QM3
				RecLock("QM3",.T.)
				Replace QM3_FILIAL With xFilial()
				Replace QM3_PADRAO With cCods
				Replace QM3_REVPAD With "00"
				Replace QM3_DESCRI With cCods
				Replace QM3_INVRPD With Inverte(QM3->QM3_REVPAD)
				Replace QM3_INCERT With Transform(nIncers,QA_PICT(,,nVlrIni,nVlrIni,.F.)) 
				Replace QM3_ESPEC  With Transform(nTot,QA_PICT(,,nVlrIni,nVlrIni,.F.))
				Replace QM3_TOLER  With Transform(nTolMx,QA_PICT(,,nVlrIni,nVlrIni,.F.))
				Replace QM3_TOLMIN With Transform(nTolMi,QA_PICT(,,nVlrIni,nVlrIni,.F.))
				Replace QM3_UNIMED With cUnMi
				Replace QM3_DATREV With dDataBase
				Replace QM3_CERTIF With cNumCer
				
				If nFafe <> 0
					Replace QM3_DATAF  With dDtCals
					Replace QM3_FREQAF With nFafe
					Replace QM3_VALDAF With dDtAfer
				Endif
									
				If nTipoTo == 1
					Replace QM3_TIPTOL With "1"
				Else
					Replace QM3_TIPTOL With "2"
				Endif
				
				If nTipT == 1 //Padrao Objetivo
					Replace QM3_TIPPAD With "O"
				ElseIf nTipT == 2 //Padrao Subjetivo
					Replace QM3_TIPPAD With "S"
				Else
					Replace QM3_TIPPAD With "A" //Padrao Atributo
				Endif
				
				MsUnLock()
				
				If !lCads .and. lPergta
					If lMsYNo := MsgYesNo(STR0105,STR0106) //"Associacao"
						//Ver tipo Soma
						If !(Alltrim(M->QM9_TIPAFE) $ "4|8|5| ")
							
							lGrvOk := A040TdOk("QM9",nOpc)
							
							If lGrvOk
								dbSelectArea("QMC")
								dbSetOrder(1)
								RecLock("QMC",.T.)
								Replace QMC->QMC_FILIAL	With xFilial("QMC")
								Replace QMC->QMC_ESCALA	With M->QM9_ESCALA
								Replace QMC->QMC_PADRAO	With cCods
								Replace QMC->QMC_TOLER	With Transform(nTolMx,QA_PICT(,,nVlrIni,nVlrIni,.F.))
								Replace QMC->QMC_TOLMIN	With Transform(nTolMi,QA_PICT(,,nVlrIni,nVlrIni,.F.))
								Replace QMC->QMC_REVESC With M->QM9_REVESC
								Replace QMC->QMC_REVINV With Inverte(M->QM9_REVESC)
								If nTipoTo == 1
									Replace QMC->QMC_TIPTOL With "1"
								Else
									Replace QMC->QMC_TIPTOL With "2"							
								Endif	
								MsUnLock()
							Endif
						Endif
					Endif
					lPergta := .F.
				ElseIf !lPergta
					If !(Alltrim(M->QM9_TIPAFE) $ "4|8|5| ")
						
						If lGrvOk
							dbSelectArea("QMC")
							dbSetOrder(1)
							RecLock("QMC",.T.)
							Replace QMC->QMC_FILIAL	With xFilial("QMC")
							Replace QMC->QMC_ESCALA	With M->QM9_ESCALA
							Replace QMC->QMC_PADRAO	With cCods
							Replace QMC->QMC_TOLER	With Transform(nTolMx,QA_PICT(,,nVlrIni,nVlrIni,.F.))
							Replace QMC->QMC_TOLMIN	With Transform(nTolMi,QA_PICT(,,nVlrIni,nVlrIni,.F.))
							Replace QMC->QMC_REVESC With M->QM9_REVESC
							Replace QMC->QMC_REVINV With Inverte(M->QM9_REVESC)
							If nTipoTo == 1
								Replace QMC->QMC_TIPTOL With "1"
							Else
								Replace QMC->QMC_TIPTOL With "2"							
							Endif	
							MsUnLock()
						Endif
					Endif
				Endif
			Else       
				If !lCads
					Aadd(aGrvQMC,{xFilial("QMC"),M->QM9_ESCALA,QM3->QM3_PADRAO,QM3->QM3_TOLER,;	
					QM3->QM3_TOLMIN,M->QM9_REVESC,Inverte(M->QM9_REVESC),If(nTipoTo == 1,"1","2")})
				Endif	
			Endif
		Endif
	Enddo
//	oDlgPd:End()
Endif

//Associa todos os pontos na amarracao. . .
If Len(aGrvQMC) > 0                           
	If !lGrvOk
		lGrvOk := A040TdOk("QM9",nOpc)	
	Endif
	If lGrvOk
		If !lMsYNo
			If lMsYNo := MsgYesNo(STR0105,STR0106) //"Associacao"			
				lMsYNo := .T.
			Else
				lMsYNo := .F.				
			Endif
		Endif
		If lMsYNo			
			For nx := 1 To Len(aGrvQMC)
				dbSelectArea("QMC")
				dbSetOrder(1)  
				If !dbSeek(xFilial()+aGrvQMC[nx][2]+aGrvQMC[nx][7]+aGrvQMC[nx][3])
					RecLock("QMC",.T.)
					Replace QMC->QMC_FILIAL	With aGrvQMC[nx][1]
					Replace QMC->QMC_ESCALA	With aGrvQMC[nx][2]
					Replace QMC->QMC_PADRAO	With aGrvQMC[nx][3]
					Replace QMC->QMC_TOLER	With aGrvQMC[nx][4]
					Replace QMC->QMC_TOLMIN	With aGrvQMC[nx][5]
					Replace QMC->QMC_REVESC With aGrvQMC[nx][6]
					Replace QMC->QMC_REVINV With aGrvQMC[nx][7]
					Replace QMC->QMC_TIPTOL With aGrvQMC[nx][8]
					MsUnLock()
				Endif	
			Next nx  
		Endif
	Endif
Endif 

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³qmt040VPadAOSºAutor  ³Denis Martins       º Data ³  07/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Habilita /Desabilita campos a serem digitados               	 º±±
±±º          ³                                                            	 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA040                                                    	 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt040VPadAOS()
If nTipT == 3
	oGetIncer:Disable()
	oGetTMa:Disable()
	oGetTMi:Disable()
	oGetNCer:Disable() 
	oGetFAfe:Disable()
	oGetDtCal:Disable()
	oGetVAfe:Disable() 
Else
	oGetIncer:Enable()
	oGetTMa:Enable()
	oGetTMi:Enable()
	oGetNCer:Enable()
	oGetFAfe:Enable()
	oGetDtCal:Enable()
	oGetVAfe:Enable()
Endif    

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT040CoUnºAutor  ³Denis Martins       º Data ³  07/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se as unidades de medidas sao diferentes			  º±±
±±º          ³escala - padrao automatico                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA040                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT040CoUn(cUnMi)
Local lRet := .T. 
If cUnMi <> M->QM9_UNIMED
	dbSelectArea("SAP")
	dbSetOrder(1)
	If !dbSeek(xFilial("SAP")+cUnMi+M->QM9_UNIMED)
		Help(" ",1,"A040AUMED") //"As unidades de medida padrao automatico/escala sao diferentes, favor cadastrar a conversao."
		lRet := .F.
	Endif
Endif          
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMTA040EnPdºAutor  ³Denis Martins       º Data ³  07/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Enchoice Bar do Padrao Automatico                            º±±
±±º          ³Botao conversao de medidas                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA040                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMTA040EnPd( oDlgPd, bOk, bCancel, lCads )
Local aButtons := {}                             
If !lCads
	aAdd(aButtons,{"NOTE"  ,{|| QMT040ConMed()},STR0108,STR0112}) //"Conversao de Medidas"
Endif
EnchoiceBar(oDlgPd,bOk,bCancel,,aButtons)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT040ConMedºAutor  ³Denis Martins       º Data ³  07/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza conversao de unidade de medida padrao automatico      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA040                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT040ConMed()
Local oDlgC
Local nOpca := 0
Local cDescD	:= ""
Local cDescP	:= ""	                              
Local lGrvUn	:= .F.
Private cConDe	:= CriaVar("AH_UNIMED",.F.)
Private cConPara:= CriaVar("AH_UNIMED",.F.)
Private nConver	:= 0	
cConDe	 := cUnMi
cConPara := M->QM9_UNIMED

DEFINE MSDIALOG oDlgC TITLE STR0108 FROM 33,25 TO 180,349 PIXEL  //Conversao de Medidas

@ 012,005 To 69,155 OF oDlgC PIXEL
@ 006,008 SAY STR0109 SIZE 120, 7 OF oDlgC PIXEL  // Informe o Fator de Conversao
@ 020,008 SAY STR0110 SIZE 55, 7 OF oDlgC PIXEL  // De:
@ 020,038 MSGET cConde F3 "SAH" Valid (ExistCpo("SAH") .and. QMTA040ShwD(@cDescD,cConde)) OF oDlgC PIXEL
@ 020,062 SAY cDescD SIZE 90, 7 OF oDlgC PIXEL
@ 035,008 SAY STR0111 SIZE 18, 7 OF oDlgC PIXEL  //Para:
@ 035,038 MSGET cConPara F3 "SAH" Valid (ExistCpo("SAH") .and. QMTA040ShP(@cDescP,cConPara)) OF oDlgC PIXEL
@ 035,062 SAY cDescP OF oDlgC SIZE 90, 7 PIXEL
@ 049,008 SAY STR0112 SIZE 34, 7 OF oDlgC PIXEL	//Conversao
@ 049,038 MSGET nConver Picture PesqPict("SAP","AP_COEF") SIZE 45, 11 OF oDlgC PIXEL

DEFINE SBUTTON FROM 36, 120 TYPE 1 ACTION (nOpca := 1,lGrvUn := qmt040grsap(cConde,cConPara,nConver,oDlgC),If(lGrvUn,oDlgC:End(),.F.)) ENABLE OF oDlgC 
DEFINE SBUTTON FROM 52, 120 TYPE 2 ACTION (nOpca := 0, oDlgC:End()) ENABLE OF oDlgC

ACTIVATE MSDIALOg oDlgC CENTERED
Return 

Static Function QMTA040ShwD(cDescD,cConde)
dbSelectArea("SAH")
dbSetOrder(01)
dbSeek(xFilial("SAH")+cConde)
cDescD := SAH->AH_UMRES
Return .T.

Static Function QMTA040ShP(cDescP,cConPara)
dbSelectArea("SAH")
dbSetOrder(01)
dbSeek(xFilial("SAH")+cConPara)
cDescP := SAH->AH_UMRES
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³qmt040grsapºAutor  ³Denis Martins       º Data ³  10/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realizar gravacao de conversao de medidas                    º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA040 					                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt040grsap(cConde,cConPara,nConver,oDlgC)
Local aArea := GetArea()
Local lRet	:= .T.
If cConde == cConPara
	Help( " ", 1, "A040IGMED" )	//"Nao e permitido unidades de medidas iguais."
	lRet := .F.
Endif

If lRet
	If nConver == 0
		Help( " ", 1, "A040IGZER" )	//Nao eh permitido conversao de medidas com valores igual a zero		
		lRet := .F.
	Endif
Endif

If lRet
	dbSelectArea("SAP")
	dbSetOrder(1)
	If !dbSeek(xFilial("SAP")+cConde+cConPara)
		Reclock("SAP",.T.)
		Replace AP_DE	with cConde
		Replace AP_PARA	with cConPara
		Replace AP_COEF	with nConver
		MsUnlock()
	Endif
Endif	

RestArea(aArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT040CvUnºAutor  ³Denis Martins       º Data ³  01/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Caso o usuario deseje no momento da alteracao da faixa, tro-º±±
±±º          ³car a unidade de medida, verificar se existe conversao.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³QMTA040                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT040CvUn()
Local lRet := .T.
If Altera
	If !(M->QM9_TIPAFE $ "4|8| ")
		If M->QM9_TIPAFE <> "5"
			dbSelectArea("QMC")
			dbSetOrder(1)
			If dbSeek(xFilial()+M->QM9_ESCALA+Inverte(M->QM9_REVESC))
				While QMC->(!Eof()) .and. QMC->QMC_FILIAL+QMC->QMC_ESCALA+Inverte(QMC->QMC_REVESC)  == ;
					xFilial()+M->QM9_ESCALA+Inverte(M->QM9_REVESC)
					dbSelectArea("QM3")
					dbSetOrder(1)
					If dbSeek(xFilial()+QMC->QMC_PADRAO)
						If QM3->QM3_UNIMED <> M->QM9_UNIMED
							dbSelectArea("SAP")
							dbSetOrder(1)
							If !dbSeek(xFilial()+QM3->QM3_UNIMED+M->QM9_UNIMED)
								lRet := .f.
								Help(" ",1,"A040UNIMED") // "Padrao nao pode ser associado a escala, pois possui unidade de medida diferente")
								// "Cadastre a conversao."
								Exit
							Endif
						Endif
					Endif
					dbSelectArea("QMC")
					dbSetOrder(1)
					dbSkip()
				Enddo
			Else
				lRet := .T.
			Endif
		Else
			dbSelectArea("QMA")
			dbSetOrder(1)
			If dbSeek(xFilial()+M->QM9_ESCALA+Inverte(M->QM9_REVESC))
				While QMA->(!Eof()) .and. QMA->QMA_FILIAL+QMA->QMA_ESCALA+QMA->QMA_REVESC ==;
					xFilial("QMA")+M->QM9_ESCALA+M->QM9_REVESC
					dbSelectArea("QM3")
					dbSetOrder(1)
					If dbSeek(xFilial()+QMA->QMA_PADRAO)
						If QM3->QM3_UNIMED <> M->QM9_UNIMED
							dbSelectArea("SAP")
							dbSetOrder(1)
							If !dbSeek(xFilial()+QM3->QM3_UNIMED+M->QM9_UNIMED)
								lRet := .f.
								Help(" ",1,"A040UNIMED") // "Padrao nao pode ser associado a escala, pois possui unidade de medida diferente")
								// "Cadastre a conversao."
								Exit
							Endif
						Endif
					Endif
					dbSelectArea("QMA")
					dbSetOrder(1)
					dbSkip()
				Enddo
			Else
				lRet := .T.
			Endif
		Endif
	Endif
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QM040AcQM9ºAutor  ³Denis Martins       º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Incluir no menu SIGAQMT a funcao QM040AcQM9 (Acerta o QM9_  º±±
±±º          ³NROMED) para as faixas que foram criadas revisao.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MENU SIGAQMT                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM040AcQM9()
Local aQM9 := {}
Local nSom := 0
Local cEscca :="" 
Local cEsRev :="" 
dbSelectArea("QM6")
dbSetOrder(1)
dbGoTop()

While !QM6->(Eof())
	dbSelectArea("QM7")
	dbSetOrder(1)
	If dbSeek(xFilial()+QM6->QM6_INSTR+QM6->QM6_REVINS+DTOS(QM6->QM6_DATA)+QM6->QM6_CSEQ)
    	While !QM7->(Eof()) .and. QM7->QM7_FILIAL+QM7->QM7_INSTR+QM7->QM7_REVINS+DTOS(QM7->QM7_DATA)+QM7->QM7_CSEQ ==;
			QM6->QM6_FILIAL+QM6->QM6_INSTR+QM6->QM6_REVINS+DTOS(QM6->QM6_DATA)+QM6->QM6_CSEQ
			If Alltrim(cEscca) <> Alltrim(QM7->QM7_ESCALA) //.and. Val(cEsRev) <> Val(QM7->QM7_REVESC)  
				cEscca := Alltrim(QM7->QM7_ESCALA) 
				cEsRev := Alltrim(QM7->QM7_REVESC) 
				dbSelectArea("QM8")
				dbSetOrder(1)
				If dbSeek(xFilial()+QM7->QM7_INSTR+QM7->QM7_REVINS+DTOS(QM7->QM7_DATA)+QM7->QM7_CSEQ+QM7->QM7_ESCALA+QM7->QM7_REVESC)
					While !QM8->(Eof()) .and. QM8->QM8_FILIAL+QM8->QM8_INSTR+QM8->QM8_REVINS+DTOS(QM8->QM8_DATA)+QM8->QM8_CSEQ+QM8->QM8_ESCALA+QM8->QM8_REVESC+QM8->QM8_PADRAO ==;
					xFilial("QM7")+QM7->QM7_INSTR+QM7->QM7_REVINS+DTOS(QM7->QM7_DATA)+QM7->QM7_CSEQ+QM7->QM7_ESCALA+QM7->QM7_REVESC+QM7->QM7_PONTO										
					nSom++
					dbSelectArea("QM8")
					dbSetOrder(1)
					dbSkip()
					Enddo
					dbSelectArea("QM9")
					dbSetOrder(1)
					If dbSeek(xFilial()+QM7->QM7_ESCALA+Inverte(QM7->QM7_REVESC))
						If !Empty(QM7->QM7_LABOR)
							RecLock("QM9",.F.)
							Replace QM9->QM9_TIPAFE With nSom
							MsUnlock()
						Endif
						If QM9->QM9_NROMED > 0
							If QM9->QM9_NROMED <> nSom 
								RecLock("QM9",.F.)
								Replace QM9->QM9_NROMED With nSom
								MsUnlock()
								Aadd(aQM9,{QM9->QM9_ESCALA,QM9->QM9_REVESC})							
							Endif
						Endif					
						
					Endif
				Endif					
			Endif
			nSom := 0
			cEscca := Alltrim(QM7->QM7_ESCALA) 
			cEsRev := Alltrim(QM7->QM7_REVESC) 
	    	dbSelectArea("QM7")
	    	dbSkip()
    	Enddo
	Endif
	dbSelectArea("QM6")
	dbSkip()
Enddo

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q070PICTR ºAutor  ³Denis Martins       º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ajuste de apresentacao de picture campo QM9_ESCALF          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA040                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q070PICTR()
Local cPict := ""
Local lVisual	:= Iif(Inclui .Or. Altera,.F.,.T.)
	If !lVisual 	
		cPict := Q070PC("QM9_ESCALI")
	Endif	
Return cPict
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMTA040   ºAutor  ³Renata Cavalcante   º Data ³  05/05/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação do campo de Valor Final                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Validação do campo de Valor Final                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q040VldVal

Local lRet:=.T.

If Empty(M->QM9_ESCALI)
	MessageDlg(STR0122,,3)//"Para informar o valor final é necessário informar o valor inicial"
    lRet:=.F.
Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A040VldPxF³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 23.09.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida a amarracao Padroes x Faixas                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³QMTA040                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/         
Static Function A040VldPxF(aCosAa)

Local aArea		:= {}
Local aAreaQM3	:= {}
Local aAreaQM7	:= {}
Local lExistCal := .F.
Local lRet		:= .T.
Local nX		:= 0
Local nY		:= 0
Local nPosPad	:=	ASCAN(aHeader,{|x| Alltrim(x[2]) = "QMC_PADRAO"})

If Len( aCosAa ) > 0

	aArea	:= GetArea()
	aAreaQM3:= QM3->(GetArea())
	aAreaQM7:= QM7->(GetArea())
	
	For nX := 1 To Len(aCosAa)
		dbSelectArea("QM3")
		dbSetOrder(1)
		If dbSeek(xFilial("QM3")+aCosAa[nX][nPosPad])
			dbSelectArea("QM7")
			dbSetOrder(2)
			If dbSeek(cFilial+QMC->QMC_ESCALA+QMC->QMC_REVESC+aCosAa[nX][nPosPad])
				lExistCal := .T.
				Exit
			Endif		
		Endif
	Next nX
		
	If lExistCal
		If Len(aCosAa) == Len(aCols)
			For nX := 1 To Len(aCosAa)
				For nY := 1 To Len(aCosAa[nX])
					If aCosAa[nX,nY] <> aCols[nX,nY]
						lRet := .F.
						Exit
					Endif
				Next nY
			Next nX
		Else
			lRet := .F.
		Endif
		
		If !lRet 
			MessageDlg(STR0118+Chr(13)+Chr(10)+STR0119,,3) //"Por favor realize a revisao da escala"
		Endif
	Endif
	
	RestArea( aAreaQM7 )
	RestArea( aAreaQM3 )
	RestArea( aArea )

Endif

Return( lRet )


