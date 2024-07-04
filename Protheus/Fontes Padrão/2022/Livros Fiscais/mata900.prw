#INCLUDE "Mata900.ch"
#INCLUDE "FIVEWIN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATA900  ³ Autor ³ Juan Jose Pereira     ³ Data ³13/02/93  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Acertos de Livros Fiscais                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Marcos Simidu³03/09/98³17554A³ Acertos no MV_DATAFIS.                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MATA900()
Local cFiltraSF3	:= " "
Local bFiltraBrw	:= " "
Local aIndexSF3		:= {}

PRIVATE aRotina := MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemToAnsi(STR0006) //"Livros Fiscais"
PRIVATE nInclui   := 0


If cPaisLoc=="BOL"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificacao de filtro na Mbrowse                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFDEF TOP
		cFiltraSF3 := 'F3_STATUS<>""'
	#ELSE
		cFiltraSF3 := '!Empty(F3_STATUS)'
	#ENDIF
	If Valtype(cFiltraSF3) == "C" .And. !Empty(cFiltraSF3)
		bFiltraBrw 	:= {|| FilBrowse("SF3",@aIndexSF3,@cFiltraSF3)}
		Eval(bFiltraBrw)
		If ( Eof() )
			HELP(" ",1,"RECNO")
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	mBrowse( 6, 1,22,75,"SF3")
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cFiltraSF3) .And. Len(aIndexSF3) > 0
		EndFilBrw("SF3",aIndexSF3)
	EndIf
Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	mBrowse( 6, 1,22,75,"SF3")

EndIf
Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A900Visual³ Autor ³   Henry Fila          ³ Data ³03/09/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Inclusaoo dos Livros Fiscais                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A900Visual(cAlias,nReg,nOpc)

Local aButtonUsr:= {}

If ExistBlock("MA900BTN")
	aButtonUsr := ExecBlock("MA900BTN",.F.,.F.)
	If ValType(aButtonUsr) <> "A"
		aButtonUsr := Nil
	EndIf
EndIf

AxVisual(cAlias,nReg,nOpc, , , , ,aButtonUsr )

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A900Inclui³ Autor ³   Henry Fila          ³ Data ³03/09/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Inclusao dos Livros Fiscais                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function A900Inclui(cAlias,nReg,nOpc)

Local aButtonUsr 	:={}  
Local nOpcA			:=1
Local lAviso		:=.T.

If cPaisLoc<>"BOL"
	lAviso	:=If(nInclui==1,.F.,.T.)

	If !FisChkDt(dDataBase)
		Return
	Endif
			                 
	If lAviso
		nOpcA	:= Aviso("Atencao",STR0010,{"Sim","Nao"},3)
		lAviso	:= .F.
	Endif	
	
	If nOpcA == 1
		If ExistBlock("MA900BTN")
			aButtonUsr := ExecBlock("MA900BTN",.F.,.F.)
			If ValType(aButtonUsr) <> "A"
				aButtonUsr := Nil
			EndIf                                                  
		EndIf                                       
		nInclui	:=AxInclui(cAlias,nReg,nOpc, , , ,"A900TudOK()", , ,aButtonUsr)
		
		//-- Executa integração do Datasul
		If FindFunction("TMSAE76")
			TMSAE76()
		EndIf	
	Endif
Else
	AxInclui(cAlias,nReg,nOpc, , , ,"A900TudOK()", , ,aButtonUsr)
EndIf
Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A900Altera³ Autor ³   Marcos Simidu       ³ Data ³05/06/97  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Alteracao dos Livros Fiscais                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A900Altera(cAlias,nReg,nOpc)
Local dData:=cTod(space(8))
Local aButtonUsr:= {}
Local cCfopAnt := Alltrim((cAlias)->F3_CFO)
Local cEntSai	:=	""
Local cCliefor	:=	""
Local cLoja		:=	""
Local cSerie	:=	""
Local cNota		:=	""

If cPaisLoc<>"BOL"

	If Val(substr(SF3->F3_CFO,1,1))>=5
		dData:=SF3->F3_EMISSAO
	Else
		dData:=SF3->F3_ENTRADA
	Endif
	
	If FisChkDt(dData)
		If Aviso("Atencao",STR0011,{"Sim","Nao"},3) ==1
			If ExistBlock("MA900BTN")
				aButtonUsr := ExecBlock("MA900BTN",.F.,.F.)
				If ValType(aButtonUsr) <> "A"
					aButtonUsr := Nil
				EndIf
			EndIf
		
			If AxAltera(cAlias,nReg,nOpc,,,,,"A900TudOK()",,,aButtonUsr) == 1
			                                                
							
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Rodrigo Aguilar - 28/05/2012                                                             ³
				//³                                                                                         ³
				//³Quando o cliente altera a chave da NFe a mesma se aplica a todos os itens, sendo         ³
				//³assim deve-se atualizar a tabela SFT, campo FT_CHVNFE com o conteúdo gravado             ³
				//³na SF3, afinal, nao podem existir em um documento duas chaves diferentes.                ³
				//³                                                                                         ³
				//³O tratamento acima foi necessario para que astabelas SF3 e SFT fiquem igualmente gravadas³
				//³com a chave do documento fiscal                                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cEntSai		:=	Iif (Left((cAlias)->F3_CFO, 1)>="5", "S", "E")    
				cCliefor	:=	(cAlias)->F3_CLIEFOR       
				cLoja		:=	(cAlias)->F3_LOJA  
				cSerie		:=	(cAlias)->F3_SERIE    
				cNota		:=	(cAlias)->F3_NFISCAL        
															
				DbSelectArea("SFT")
				SFT->(DbSetOrder(3))
				If SFT->(DbSeek(xFilial("SFT")+cEntSai+cCliefor+cLoja+cSerie+cNota))
					Do While SFT->(!Eof()) .And. SFT->(xFilial("SFT")+FT_TIPOMOV+FT_CLIEFOR+FT_LOJA+FT_SERIE+FT_NFISCAL) == ;
													( xFilial("SFT")+cEntSai+cCliefor+cLoja+cSerie+cNota )
													
						RecLock("SFT",.F.)   						
							SFT->FT_CHVNFE := (cAlias)->F3_CHVNFE							
						SFT->(MsUnLock ())
						SFT->(FkCommit ())
						
						SFT->(DbSkip())
					EndDo
				EndIf
				
			EndIf
			If Val(cCfopAnt) <> Val((cAlias)->F3_CFO)
				A900AtuBas(cCfopAnt)
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se a data foi alterada para alterar os registros relacionados (SF1/SD1 ou SF2/SD2)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If dData <> (cAlias)->F3_ENTRADA
				A900AtuBas("")
			Endif
		Endif
	Endif
Else
		AxAltera(cAlias,nReg,nOpc,,,,,"A900TudOK()",,,aButtonUsr)
EndIf	
Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A900Deleta³ Autor ³ Gilson do Nascimento  ³ Data ³16/02/93  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de exclusao dos   Livros Fiscais                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A900Deleta(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION A900Deleta(cAlias,nReg,nOpc)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nOpcA:=0, oDlg, cCod, aAC:= {STR0007,STR0008} //"Abandona"###"Confirma"
Local dData:=cTod(space(8))
Local aButtonUsr:= {}
Local cTipMov   := Iif (Left (SF3->F3_CFO, 1)>="5", "S", "E")
Local aInfo     := {}
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := MsAdvSize() 
Local nGd1      := 2
Local nGd2 		:= 2
Local nGd3 		:= 0
Local nGd4 		:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aTELA[0][0],aGETS[0]

aObjects := {} 
AAdd( aObjects, {100, 100, .t., .t. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
aPosObj := MsObjSize( aInfo, aObjects )

nGd1 := 2
nGd2 := 2
nGd3 := aPosObj[1,3]-aPosObj[1,1]
nGd4 := aPosObj[1,4]-aPosObj[1,2]

If cPaisLoc<>"BOL"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica ultima data para operacoes fiscais                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Val(substr(SF3->F3_CFO,1,1))>=5
		dData:=SF3->F3_EMISSAO
	Else
		dData:=SF3->F3_ENTRADA
	Endif
	
	If !FisChkDt(dData)
		Return
	Endif
	
	If Aviso("Atencao",STR0012,{"Sim","Nao"},3) ==1
		If ExistBlock("MA900BTN")
			aButtonUsr := ExecBlock("MA900BTN",.F.,.F.)
			If ValType(aButtonUsr) <> "A"
				aButtonUsr := Nil
			EndIf
		EndIf
		
		dbSelectArea(cAlias)
		
		DEFINE MSDIALOG oDlg TITLE cCadastro FROM nGd1,nGd2 TO nGd3,nGd4 OF oMainWnd PIXEL
		nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",STR0009, , aPosObj[1], , 3) //"Quanto … exclus„o?"
		nOpca:=1
		oDlg:lMaximized := .T.
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()},,aButtonUsr)
		
		dbSelectArea(cAlias)
		
		IF nOpcA == 2
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se ainda existe NF no SF1 ou SF2, devera' ser APAGADA³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cAliasArq := iif(val(substr(SF3->F3_CFO,1,1))>=5,"SD2","SD1")
			cBusca    := SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA
			dbSelectArea(cAliasArq)
			dbSetOrder(1)
			dbSeek(F3Filial(cAliasArq)+cBusca) //cFilial
			
			Begin Transaction
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Deleta o registro SF3³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea(cAlias)
				If ExistBlock("MA900DEL")
					ExecBlock("MA900DEL",.F.,.F.)
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Tratamento de exclusao do SFT quando esta tabela estiver habilitada.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					
						DbSelectArea ("SFT")
						SFT->(DbSetOrder(3))
						If (SFT->(DbSeek (xFilial ("SFT")+cTipMov+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_IDENTFT)))
							Do While !SFT->(Eof ()) .And.;
								xFilial ("SFT")+cTipMov+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_IDENTFT==;
								xFilial ("SFT")+SFT->FT_TIPOMOV+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_IDENTF3
								M926DlSped(2,SFT->FT_NFISCAL,SFT->FT_SERIE,SFT->FT_CLIEFOR,SFT->FT_LOJA,SFT->FT_TIPOMOV,SFT->FT_ITEM,SFT->FT_PRODUTO)
								RecLock ("SFT", .F., .T.)
								SFT->(DbDelete ())
								MsUnlock ()
							
								SFT->(DbSkip ())
							EndDo
						EndIf
							
					dbSelectArea(cAlias)
					If cAlias == "SF3"
						M926DlSped(1,SF3->F3_NFISCAL,SF3->F3_SERIE,SF3->F3_CLIEFOR,SF3->F3_LOJA,SF3->F3_CFO)
					Endif
					RecLock(cAlias,.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
				
			End Transaction
		Else
			MsUnLock()
		Endif	
		
		dbSelectArea(cAlias)
	Endif
Else
   
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM nGd1,nGd2 TO nGd3,nGd4 OF oMainWnd PIXEL
	nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",STR0009, , aPosObj[1], , 3 ) //"Quanto … exclus„o?"
	nOpca:=1
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()},,aButtonUsr)
	
	dbSelectArea(cAlias)
	
	IF nOpcA == 2
		Begin Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Deleta o registro SF3³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock(cAlias,.F.,.T.)
		dbDelete()
		MsUnlock()
		End Transaction
	Else
		MsUnLock()
	Endif	
	
	dbSelectArea(cAlias)

EndIf	
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A900AtuBas³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 09/08/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Atualiza as Tabelas SD1 ou SD2, quando o Cfop for alterado  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A900AtuBas(cCfop)

Local aArea := GetArea()
Local cSeek := SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA
Local cChave := "E"+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_CLIEFOR+SF3->F3_LOJA
If !Empty(cCfop)
	// Alteracao do CFOP nos itens
	If Left(cCfop,1) >= "5" .And. Left(Alltrim(SF3->F3_CFO),1) >= "5"		//Saida
		dbSelectArea("SD2")
		dbSetOrder(3)
		If dbSeek(xFilial("SD2")+cSeek)
			While !Eof() .And. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == xFilial("SD2")+cSeek
				If Val(SD2->D2_CF) == Val(cCfop)
					RecLock("SD2",.F.)
					SD2->D2_CF := SF3->F3_CFO
					MsUnlock()
				Endif
				dbSkip()
			Enddo
		Endif
		dbSelectArea("SFT")
		dbSetOrder(6)
		If dbSeek(xFilial("SFT")+"S"+cSeek)
			While !Eof() .And. SFT->FT_FILIAL+SFT->FT_TIPOMOV+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA == xFilial("SFT")+"S"+cSeek
				If Val(SFT->FT_CFOP) == Val(cCfop)
					RecLock("SFT",.F.)
					SFT->FT_CFOP := SF3->F3_CFO
					MsUnlock()
				Endif
				dbSkip()
			Enddo
		EndIf
	ElseIf Left(cCfop,1) < "5" .And. Left(Alltrim(SF3->F3_CFO),1) < "5"	//Entrada
		dbSelectArea("SD1")
		dbSetOrder(1)
		If dbSeek(xFilial("SD1")+cSeek)
			While !Eof() .And. SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == xFilial("SD1")+cSeek
				If Val(SD1->D1_CF) == Val(cCfop)
					RecLock("SD1",.F.)
					SD1->D1_CF := SF3->F3_CFO
					MsUnlock()
				Endif
				dbSkip()
			Enddo
		Endif
		dbSelectArea("SFT")
		dbSetOrder(6)
		If dbSeek(xFilial("SFT")+"E"+cSeek)
			While !Eof() .And. SFT->FT_FILIAL+SFT->FT_TIPOMOV+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA == xFilial("SFT")+"E"+cSeek
				If Val(SFT->FT_CFOP) == Val(cCfop)
					RecLock("SFT",.F.)
					SFT->FT_CFOP := SF3->F3_CFO
					MsUnlock()
				Endif
				dbSkip()
			Enddo
		EndIf
	Endif
Else                              
	// Alteracao da data de entrada nos itens e cabecalho
	If Left(SF3->F3_CFO,1) < "5"
		dbSelectArea("SF1")
		dbSetOrder(1)
		If dbSeek(xFilial("SF1")+cSeek)
			While !Eof() .And. SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == xFilial("SF1")+cSeek
				RecLock("SF1",.F.)
				SF1->F1_DTDIGIT := SF3->F3_ENTRADA
				MsUnlock()
				dbSkip()
			Enddo
		Endif     
						
	
		dbSelectArea("SD1")
		dbSetOrder(1)
		If dbSeek(xFilial("SD1")+cSeek)
			While !Eof() .And. SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == xFilial("SD1")+cSeek
				RecLock("SD1",.F.)
				SD1->D1_DTDIGIT := SF3->F3_ENTRADA
				MsUnlock()
				dbSkip()
			Enddo
		Endif
		
		dbSelectArea("SFT")
		dbSetOrder(1)
		If dbSeek(xFilial("SFT")+cChave)
			While !Eof() .And. SFT->FT_FILIAL+SFT->FT_TIPOMOV+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA == xFilial("SFT")+cChave
				RecLock("SFT",.F.)
		   		SFT->FT_ENTRADA := SF3->F3_ENTRADA
				MsUnlock()
				dbSkip()
			Enddo
		Endif     
	Endif
Endif

RestArea(aArea)

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()
Private	aRotina :={}
If cPaisLoc=="BOL"
	aRotina := {	{ STR0001,"AxPesqui"	, 0 , 1,0,.F.},; // "Pesquisar"
						{ STR0002,"A900Visual"	, 0 , 2,0,NIL},; // "Visualizar"
						{ STR0003,"A900Inclui"	, 0 , 3,0,NIL},; // "Incluir"
						{ STR0004,"A900Altera"	, 0 , 4,0,NIL},; // "Alterar"
						{ STR0005,"A900Deleta"	, 0 , 5,0,NIL} } // "Excluir"

Else

	aRotina := {	{ STR0001,"AxPesqui"	, 0 , 1,0,.F.},; // "Pesquisar"
						{ STR0002,"A900Visual"	, 0 , 2,0,NIL},; // "Visualizar"
						{ STR0003,"A900Inclui"	, 0 , 3,0,NIL},; // "Incluir"
						{ STR0004,"A900Altera"	, 0 , 4,0,NIL},; // "Alterar"
						{ STR0013,"MATA917"		, 0 , 6,0,NIL},;	// "Por Item"
						{ STR0014,"MATA968"		, 0 , 6,0,NIL},;	// "Ger. Lanc. Fiscais"
						{ STR0005,"A900Deleta"	, 0 , 5,0,NIL} } // "Excluir"
EndIf



If ExistBlock("MA900MNU")
	ExecBlock("MA900MNU",.F.,.F.)
EndIf

Return(aRotina)

