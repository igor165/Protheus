#Include 'Protheus.ch'
#Include "ApWizard.ch"
#Include 'FWMVCDef.ch'
#INCLUDE "FWBROWSE.CH"
#INCLUDE "ATFA310.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ATFA310  ³ Autor ³ Andre Lago            ³ Data ³30.07.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Manutencao de Planejamento de Aquisicoes                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ATFA310()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ATFA310()

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

PRIVATE aRotina 	:= MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0001) //"Planejamento de Aquisições"	
PRIVATE cMarca   := GetMark( )

mBrowse( 6, 1,22,75,"SNN",,,,,, Af310Legenda("SNN"))

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF310Man  ³ Autor ³ Andre Lago            ³ Data ³ 30/07/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de Manutencao Planejamento Aquisicoes               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do cabecalho do Tipo documento                 ³±±
±±³          ³ExpN2: Recno do cabecalho do Tipo documento                 ³±±
±±³          ³ExpN3: Opcao do arotina                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ AF310Man()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATFA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF310Man(cAlias,nReg,nOpc)

Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := MsAdvSize() 

Local cSeek     := ""
Local cWhile    := ""
Local lSeek     := .F.

Local oDlg

Local lContinua := .T.
Local lInclui   := (nOpc == 3)
Local lAltera   := (nOpc == 4)
Local lCopia    := (nOpc == 6)

Local nX        := 0
Local nOpca     := 0
Local nSaveSx8  := GetSx8Len()
Local aCpoGDa   := {	'NN_CCONTAB',;
							'NN_CUSTBEM',;
							'NN_CDEPREC',;
							'NN_CCDEPR' ,;
							'NN_CCDESP' ,;
							'NN_VORIG1' ,;
							'NN_TXDEPR1',;
							'NN_VORIG2' ,;
							'NN_TXDEPR2',;
							'NN_VORIG3' ,;
							'NN_TXDEPR3',;
							'NN_VORIG4' ,;
							'NN_TXDEPR4',;
							'NN_VORIG5' ,;
							'NN_TXDEPR5',;
							'NN_CCCDEP' ,;
							'NN_SUBCCON',;
							'NN_SUBCDEP',;
							'NN_SUBCCDE',;
							'NN_CLVLCON',;
							'NN_CLVLDEP',;
							'NN_CLVLCDE' } // Vetor responsavel pela montagem da aHeader

Local cCpoGDa   := ""
Local ni

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oGetd := Nil
Private aCols     	:= {}
Private aHeader   	:= {}
Private aTELA[0][0],aGETS[0]
Private aYesFields 	:= {}
Private aCampos		:= {}
Private aButtons   	:= {}

If nOpc == 3 .or. nOpc == 6
	Aadd(aButtons,{"SALARIOS",{ || Af310CrAut(oDlg,nOpc,nSaveSx8) },STR0002,STR0003}) //"Cria Automatico","Multiplos"
EndIf

For ni := 1 to len(aCpoGDa)
	cCpoGDa += aCpoGDa[ni]+"/"
Next

If nOpc > Len(aRotina)
	nOpc := 1
Endif

If nOpc == 4
	lContinua := AF310ALT(SNN->NN_CODIGO)
Endif

If nOpc == 5
	lContinua := AF310DEL(SNN->NN_CODIGO)
Endif	

If lCopia
	INCLUI := .T.
EndIf

If lContinua
	dbSelectArea("SNN")

	If lInclui
		RegToMemory( "SNN", .T., .F. )
	Else
		SNN->(dbSetOrder(1))//NN_FILIAL+NN_CODIGO+NN_ITEM
		lSeek:= SNN->(dbSeek(xFilial("SNN")+SNN->(NN_CODIGO+NN_ITEM),.F.))

		If lSeek
			If SoftLock("SNN")
				RegToMemory( "SNN", .F., .F. )
			Else
				lContinua := .F.
			EndIf
		Else
			Help(" ",1,"RECNO")
			lContinua := .F.
		EndIf
	EndIf

	dbSelectArea("SNN")
	SNN->(dbSetOrder(1))
	
	If lContinua

		// Carrega aHeader                                                                                                                
		DbSelectArea("SX3")                                                                                                             
		SX3->(DbSetOrder(2)) // Campo                                                                                                   
		Aadd(aHeader,{ "Tipo Ativo","TIPO"	,"@!",2,0,	,,"C",,"V",,"01"})
		For nX := 1 to Len(aCpoGDa)                                                                                                     
			If SX3->(DbSeek(aCpoGDa[nX]))                                                                                                 
				Aadd(aHeader,{ AllTrim(X3Titulo()),;                                                                                         
							SX3->X3_CAMPO	,;                                                                                                       
							SX3->X3_PICTURE,;                                                                                                       
							SX3->X3_TAMANHO,;                                                                                                       
							SX3->X3_DECIMAL,;
							SX3->X3_VALID	,;                                                                                                       
							SX3->X3_USADO	,;                                                                                                       
							SX3->X3_TIPO	,;                                                                                                       
							SX3->X3_F3 		,;                                                                                                       
							SX3->X3_CONTEXT,;                                                                                                       
							SX3->X3_CBOX	,;                                                                                                       
							SX3->X3_RELACAO})                                                                                                       
			Endif                                                                                                                         
		Next nX                                                                                                                         

		If !lInclui
			cSeek  := xFilial("SNN")+M->NN_CODIGO+M->NN_ITEM
			cWhile := "SNN->NN_FILIAL+SNN->NN_CODIGO+SNN->NN_ITEM"
         	nRecno := SNN->(Recno())                                                                                                                       
			// Carregue aqui a Montagem da sua aCol                                                                                         
			aAux := {}                          
			dbSelectArea("SNN")
			SNN->(dbSetOrder(1)	)
			SNN->(dbSeek(cSeek,.F.))
			While !SNN->(eof()) .and. cSeek == &cWhile
				aAux := {}                          
				Aadd(aAux,"01")					
				For nX := 1 to Len(aCpoGDa)         	
					dbSelectArea("SX3")
					SX3->(DbSetOrder(2)) // Campo                                                                                                   
					If DbSeek(aCpoGDa[nX])             
						Aadd(aAux,SNN->&(SX3->X3_CAMPO))
					EndIf
				Next nX
				Aadd(aAux,.F.)                      
				Aadd(aCols,aAux)                     
				dbSelectArea("SNN")
		   	SNN->(dbSkip())
			Enddo                             
         	SNN->(dbGoTo(nRecno))
		Endif
		
		If Empty(aCols)
			aAux := {}                          
			Aadd(aAux,"01")					
			For nX := 1 to Len(aCpoGDa)         
				dbSelectArea("SX3")
				SX3->(DbSetOrder(2)) // Campo                                                                                                   
				If SX3->(DbSeek(aCpoGDa[nX]))             
					Aadd(aAux,CriaVar(AllTrim(SX3->X3_CAMPO)))
				Endif                              
			Next nX
			Aadd(aAux,.F.)                      
			Aadd(aCols,aAux)                     
		Endif	

		aObjects := {} 
		AAdd( aObjects, { 100, 100, .t., .t. } )
		AAdd( aObjects, { 100, 100, .t., .t. } )
		
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
		aPosObj := MsObjSize( aInfo, aObjects ) 
		
		dbSelectArea("SX3")
		SX3->(dbSetOrder(1))
		SX3->(dbSeek("SNN"))            
		
		While ( !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "SNN")
			If ! (ALLTRIM(SX3->X3_CAMPO) $ "NN_FILIAL/"+cCpoGDa) .And. ! (ALLTRIM(SX3->X3_CAMPO) $ "NN_OK")
   	   			aAdd(aCampos,AllTrim(SX3->X3_CAMPO))
			Endif
	
			dbSelectArea("SX3")
			SX3->(dbSkip())
		EndDo                  

		If nOpc == 1
			M->NN_AQUISIC	:= "" 
		EndIf		
	 	If nOpc == 6
	 		ALTERA := .F.
	 		INCLUI := .T.
	 		M->NN_CODIGO 	:= GetSXENum("SNN")
	 		M->NN_CODEFTV	:= ""
	 		M->NN_ITMEFTV  := ""
	 	EndIf
	 	
		IF  !lInclui .And. !lAltera .And. !lCopia
			nOpcX := 0
		Else
			nOpcX := GD_UPDATE
		EndIf                 
		
	 	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
		
		EnChoice( "SNN", nReg, nOpc,,,,aCampos,aPosObj[1], , 3, , , , , ,.F. )
		
		oGetD := MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcX,"AF310LinOk()","AF310TudOk()","",aCpoGda,/*freeze*/,4096,/*fieldok*/,/*superdel*/,/*delok*/,,aHeader,aCols)
			
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,aCols:=oGetD:aCols,If(Obrigatorio(aGets,aTela) .And. oGetD:TudoOk(),oDlg:End(), nOpca :=  0 )},{|| nOpca := 2,oDlg:End()},,aButtons)
		
		If nOpca == 1
			Begin Transaction
				lGravou := AF310Grava(nOpc,aCols,aHeader)
				
				If ( lGravou )
					EvalTrigger()
					While (GetSx8Len() > nSaveSx8)
						ConfirmSx8()
					EndDo
				EndIf
				
			End Transaction
		
			While (GetSx8Len() > nSaveSx8)
				RollBackSx8()
			EndDo
		
			MsUnlockAll()    	
		Else
			While (GetSx8Len() > nSaveSx8)
				RollBackSx8()
			EndDo			
		Endif	
	Endif	
Endif   
	
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF310Grava³ Autor ³ Andre Lago            ³ Data ³ 15/07/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de Gravacao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do cabecalho do Tipo de Documento              ³±±
±±³          ³ExpN2: Recno do cabecalho do Tipo de Documento              ³±±
±±³          ³ExpN3: Opcao do arotina                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ AF310Grava()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ AFTA060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function AF310Grava(nOpcao,aCols,aHeader)

Local aArea     := GetArea()
Local bCampo 	:= {|nCPO| Field(nCPO) }
Local lGravou   := .F.
Local lOk		  := .T.
Local ni        := 0
Local nX        := 0
Local nY        := 0

If nOpcao == 3 .Or. nOpcao == 4 .Or. nOpcao == 6

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava o Cabecalho                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SNN")
	SNN->(dbSetOrder(1))
	If MsSeek(xFilial("SNN")+M->NN_CODIGO+M->NN_ITEM)
		RecLock("SNN",.F.)
	Else
		RecLock("SNN",.T.)
	EndIf
	For nX := 1 TO FCount()
		FieldPut(nX,M->&(EVAL(bCampo,nX)))
	Next nX
	SNN->NN_FILIAL := xFilial("SNN")
	
	SNN->(FkCommit())

	dbSelectArea("SNN")

	For nX := 1 To Len(aCols)
	
		If !aCols[nX,Len(aCols[nX])]
	
			
			If dbSeek(xFilial("SNN")+M->NN_CODIGO+M->NN_ITEM)
				RecLock("SNN",.F.)
			Else
				RecLock("SNN",.T.)
			EndIf
			

			For ni := 1 TO FCount()
				FieldPut(ni,M->&(EVAL(bCampo,ni)))
			Next ni

			For nY := 1 To Len(aHeader)
				If ( aHeader[nY][10] != "V" )
					SNN->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
				EndIf
			Next nY
			SNN->NN_FILIAL := xFilial("SNN")
			SNN->(MsUnLock())

		Else
			
			dbSelectArea("SNN")
			
			If dbSeek(xFilial("SNN")+M->NN_CODIGO+M->NN_ITEM)
				RecLock("SNN",.F.)
				SNN->(dbDelete())
				SNN->(MsUnlock())
			Endif
		Endif
    		
	Next nX
		     
	lGravou := .T.

ElseIf nOpcao == 5

	If lOk
		dbSelectArea("SNN")
		For nX := 1 To Len(aCols)
			If dbSeek(xFilial("SNN")+M->NN_CODIGO+M->NN_ITEM)
				RecLock("SNN")
				SNN->(dbDelete())
				SNN->(MsUnlock())
			EndIf
		Next nX
		lGravou := .T.
	EndIf
EndIf

If !lGravou
	RestArea(aArea)
EndIf




Return(lGravou)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AF310LinOk³ Autor ³Andre Lago             ³ Data ³15/07/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da Linha Ok da Getdados do desmembramento do      ³±±
±±³          ³Tipo de Documento                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica se a linha e valida                           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo efetuar a validacao da linhaOk³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF310LinOk()

Local lRet     := .T.

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AF310TudOk³ Autor ³Andre Lago             ³ Data ³15/07/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da TudoOk da Getdados do desmembramento do tipo de³±±
±±³          ³documento                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica se todos os itens sao validos                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo efetuar a validacao da TudoOk ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF310TudOk()
Local lRet     := .T.
Local nX	   := 0    
Local aCols	   := oGetD:aCols
Local aHeader  := oGetD:aHeader
Local cMoedaAtf := GetMV("MV_ATFMOEDA") 
Local nPosVlrATF := aScan(aHeader,{|x| Alltrim(x[2])==Alltrim("NN_VORIG"+cMoedaAtf) } ) 
Local nPosValor  := aScan(aHeader,{|x| Alltrim(x[2])==Alltrim("NN_VORIG1") } ) 

For nX := 1 to Len(aCols)
	If Empty(aCols[nX][nPosVlrATF]) .Or. Empty(aCols[nX][nPosValor])  
		Help(" ",1,"ATFVALORUF",,STR0041+GetMV("MV_ATFMOEDA"),4,0) // "Moeda :" 
		lRet := .F. 
		Exit
	EndIf
Next nX

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ AF310DEL ³ Autor ³ Marcelo Custodio      ³ Data ³06.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao da exclusao do tipo de documento                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AF310DEL()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AF310DEL()
Local lRet 		:= .T.
Local aArea    := GetArea()

If !Empty(SNN->NN_CODEFTV)
	Help(" ", 1, "AFNOEFE",, STR0009 + CRLF + STR0010, 1, 0) // "Bem planejado ja foi efetivado em " + CRLF + "processamento anterior."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                	 	
	lRet:= .F.
Endif

RestArea(aArea)

return lRet            
          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ AF310ALT ³ Autor ³ Wilson Possani        ³ Data ³06.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao da alteração do tipo de documento                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AF310ALT()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AF310ALT()
Local lRet 		:= .T.
Local aArea    := GetArea()

If !Empty(SNN->NN_CODEFTV)
	Help(" ", 1, "AFNOEFE",, STR0009 + CRLF + STR0010, 1, 0) // "Bem planejado ja foi efetivado em " + CRLF + "processamento anterior."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                	 	
	lRet:= .F.
Endif

RestArea(aArea)

return lRet 

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³af310CrAut³ Autor ³ Andre Lago            ³ Data ³02/08/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Criar bens planejados automaticamente                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Af310CrAut(oDlg,nOpc,nSaveSx8Len)
Local aArea := { Alias(), IndexOrd() }
Local nOpca := 0 
Local oDlg1
Local nx       := 0
Local nBens    := 0
Local lUltReg  := .F.
Local lProva   := .T.
Local lGravaOk := .F.
Local lRet     := .T.
Local cTexto	:= ""
Local lResp := .F.
Local nTamCBase := TAMSX3("NN_CODIGO")[1]
Local nTamItem  := TAMSX3("NN_ITEM")[1] 
Local aCols 	:= oGetD:aCols
Local aHeader	:= oGetD:Aheader

DEFAULT nSaveSx8Len := GetSx8Len()
 
//Nao permitir criar bens em outras opcoes.
If nOpc==3 .or. nOpc==6
	lCriaAuto := .T.
Else
	lCriaAuto := .F.
Endif

If lCriaAuto
	If ! AF310TudOk()
		Return .F.
	Endif
	IF !Obrigatorio(aGets,aTela)     // Verificar
		Return .F.
	End
	DEFINE MSDIALOG oDlg1 TITLE STR0004 FROM 33,25 TO 110,349 PIXEL //"Cria Autom tico"
	@ 01,05 TO 032, 128 OF oDlg1 PIXEL
	@ 08,08 SAY STR0005 SIZE 55, 7 OF oDlg1 PIXEL  //"N£mero de bens "
	@ 18,08 MSGET nBens SIZE 37, 11 OF oDlg1 PIXEL Picture "@E 9999" VALID IIf(nBens > 0, .T., .F.)
		
	DEFINE SBUTTON FROM 05, 132 TYPE 1 ACTION (nOpca := 1,oDlg1:End(),oDlg:End()) ENABLE OF oDlg1
	DEFINE SBUTTON FROM 18, 132 TYPE 2 ACTION (nOpca := 0,oDlg1:End()) ENABLE OF oDlg1
	ACTIVATE MSDIALOG oDlg1 CENTERED
	
	If  nOpca == 1
		For nx := 1 to nBens
			If nx = nBens
				lUltReg := .T.
			End
			dbSelectArea("SNN")
			SNN->(dbSetOrder(1))
			If SNN->(dbSeek(xFilial("SNN")+M->NN_CODIGO+M->NN_ITEM))
			   If ! lResp
    			  m->nn_item  := PADR(Soma1(Alltrim(m->nn_item)),nTamItem)    			  
    		   Else    		       		      
    		     m->nn_cbase := PADR(Soma1(Alltrim(m->nn_codigo)),nTamCBase)
    		   Endif   
         EndIf   
			
			lGravaOk := AF310Grava(nOpc,aCols,aHeader)
			lProva := .F.
			While (GetSx8Len() > nSaveSx8Len)
				If lGravaOK
					ConfirmSX8()
				Else
					RollBackSX8()
				Endif
			End	
			If !lGravaOk
				lCriaAuto := .F.
				lRet := .F.
			EndIf
		Next
	Elseif nOpca == 0
		lRet := .F.
	Endif
Else
	lRet := .F.
EndIf

dbSelectArea( aArea[1] )
dbSetOrder( aArea[2] )	
Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF310Efe  ³ Autor ³ Andre Lago            ³ Data ³02/08/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetivar/Estorna os bens planejados automaticamente        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF310Efe(cAlias,nReg,nOpc)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis de memoria no programa                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nRadio0  := 1
Local cFilIni	:= cFilAnt
Local aSM0		:= AdmAbreSM0()
Local nInc		:= 1
Local lCancela  := .F.   
Local lInverte  := .F.   
Local aSize := MSADVSIZE()    
Local nQtde   := 0
Local aCampos := {}
Local cFiltroAtu := ""
Local cIndex := ""
Local cChave := ""
Local lEstorno := aRotina[nOpc][4] == 8 
Local nOpca	:= 0

DEFINE MSDIALOG oDlg2 TITLE IIf(lEstorno,STR0022,STR0006) FROM 33,25 TO 110,349 PIXEL  //"Efetivação"
@ 01,05 TO 032, 128 OF oDlg2 PIXEL
@ 08,08 Radio oRadio  VAR nRadio0;
ITEMS 	IIf(lEstorno,STR0023,OemToAnsi(STR0007)) ,;
IIf(lEstorno,STR0024,OemToAnsi(STR0008)) ;
	3D SIZE 100,10 OF oDlg2 PIXEL	
DEFINE SBUTTON FROM 05, 132 TYPE 1 ACTION (nOpca := 1,oDlg2:End()) ENABLE OF oDlg2
DEFINE SBUTTON FROM 18, 132 TYPE 2 ACTION (nOpca := 0,oDlg2:End()) ENABLE OF oDlg2
ACTIVATE MSDIALOG oDlg2 CENTERED
	
If  nOpca == 1
	If nRadio0 == 1
		If lEstorno
			If Empty(SNN->NN_CODEFTV)
				Help(" ", 1, "AFNOEEF",, STR0025, 1, 0)
			Else
				A310PrcAtf(2,SNN->NN_CODEFTV,SNN->NN_ITMEFTV)
			EndIf
		Else
		If !Empty(SNN->NN_CODEFTV)
			Help(" ", 1, "AFNOEFE",, STR0009 + CRLF + STR0010, 1, 0) // "Bem planejado ja foi efetivado em " + CRLF + "processamento anterior."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                	 	
   		Else
				A310PrcAtf(1,"",SNN->NN_ITEM)
			EndIf
		EndIf
	Else
		//		Selecao
		While .T.
			If Pergunte("AFA310",.T.)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Carrega as perguntas selecionadas:                            ³
				//³ mv_par01 - Filial De?                                         ³
				//³ mv_par02 - Filial At‚?                                        ³
				//³ mv_par03 - Grupo de?                                          ³
				//³ mv_par04 - Grupo Ate?                                         ³
				//³ mv_par05 - Aquisicao De?                                      ³
				//³ mv_par06 - Aquisicao Ate?                                     ³
				//³ mv_par07 - Data Prevista?                                     ³
				//³ mv_par08 - Descricao do Bem                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				If MV_PAR02 < MV_PAR01 
					Help(" ", 1, "AFNOFIL",, STR0011+CRLF+STR0012+CRLF+STR0013, 1, 0) //"Problemas com a seleção das Filiais no "+CRLF+"processamento. A Filial inicial deve ser "+CRLF+"menor que a filial final."
					Loop
				EndIf
				If MV_PAR04 < MV_PAR03
					Help(" ", 1, "AFNOGRP",, STR0014+CRLF+STR0015+CRLF+STR0016, 1, 0) //"Problemas com a seleção dos Grupos no "+CRLF+"processamento. O Grupo inicial deve ser "+CRLF+"menor que o grupo final."
					Loop
				EndIf
				If MV_PAR06 < MV_PAR05
					Help(" ", 1, "AFNOAQU",, STR0017+CRLF+STR0018+CRLF+STR0019, 1, 0) //"Problemas com as datas de Aquisição no " +CRLF+"processamento. A Data inicial deve ser "+CRLF+"menor que a data final."
					Loop
				EndIf
				aCampos := {}
				AADD(aCampos,{"NN_OK","","  ",""})
				dbSelectArea("SX3")
				SX3->(DbSetorder(1))
				SX3->(dbSeek ("SNN")) 
				AADD(aCampos,{X3_CAMPO,"",X3TITULO(),X3_PICTURE})  // Incluido para Mostrar a Filial na Tela
				Do While SX3->(!EOF()) .And. (SX3->X3_ARQUIVO == "SNN")
					IF (X3USO(X3_USADO)  .AND. cNivel >= X3_NIVEL .and. SX3->X3_CONTEXT # "V") .Or.;
						(X3_PROPRI == "U" .AND. X3_CONTEXT!="V" .AND. X3_TIPO<>'M') .Or.;
						Alltrim(X3_CAMPO) $ "NN_CODIGO#NN_ITEM"
						If Alltrim(X3_CAMPO) != "NN_OK" 
					   		AADD(aCampos,{X3_CAMPO,"",X3TITULO(),X3_PICTURE})
					 	EndIf
					Endif
					SX3->(dbSkip())
				Enddo 
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Filtra o arquivo                                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SNN")
				cIndex := CriaTrab(nil,.f.)
				cChave  := "NN_CODIGO+NN_ITEM"
				IndRegua("SNN",cIndex,cChave,,AF310Check(lEstorno),STR0020) // "Selecionando Registros..."
				nIndex := RetIndex("SNN")
				dbSelectArea("SNN")
				#IFNDEF TOP
				SNN->(dbSetIndex( cIndex +OrdBagExt()))
				#ENDIF
				dbSelectArea("SNN")
				SNN->(dbSetOrder(nIndex+1))
				SNN->(dbGoTop( ))
				If SNN->( BOF() ) .and. SNN->( EOF() )
					Help(" ",1,"RECNO")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Restaura os indices      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SNN->(RetIndex("SNN"))
					Set Filter To
					fErase (cIndex+OrdBagExt())
					Loop
				EndIf 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Faz o calculo automatico de dimensoes de objetos     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DEFINE MSDIALOG oDlg3 TITLE IIf(lEstorno,STR0026,STR0021)  From aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd  PIXEL //"Seleção de Bens Planejados para Efeitvação"
				oDlg3:lMaximized := .T.                                                                                                     
				oPanel := TPanel():New(0,0,'',oDlg3,, .T., .T.,, ,40,40,.T.,.T. )
				oPanel:Align := CONTROL_ALIGN_ALLCLIENT
				oMark := MsSelect():New("SNN","NN_OK",,aCampos,@lInverte,@cMarca,{12,1,250,800})
				oMark:oBrowse:bAllMark := {| | aF310Marca("SNN",cMarca,lInverte)}
				oMark:bAval	:= {| |  a310Display(cMarca,lInverte) } 
				oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
				oMark:bMark := { | | a310Display(cMarca,lInverte) }
				
				ACTIVATE MSDIALOG oDlg3	ON INIT EnchoiceBar(oDlg3,{|| nOpca := 1,oDlg3:End()},{|| nOpca := 2,oDlg3:End()})
				Pergunte("AFA310",.F.)
				IF nOpcA == 2     //Desmarca se Abandonar
					A310Desmar(nIndex)
					Exit
				ElseIF nOpcA == 3 .or. nOpca == 0    
					Exit
				EndIf         
				SNN->(DbGoTop())
				Do While SNN->(!EOF())
					If lEstorno
						If !Empty(SNN->NN_CODEFTV) .And. SNN->NN_OK == cMarca
							A310PrcAtf(2,SNN->NN_CODEFTV,SNN->NN_ITMEFTV)
						EndIf
					 Else
						If SNN->NN_OK == cMarca
							A310PrcAtf(1,"",SNN->NN_ITEM)
						EndIf
					EndIf
					SNN->(dbSkip())
				EndDo
				A310Desmar(nIndex)
				SET FILTER TO 
 				Exit
			Else
				Exit
			EndIf

		EndDo
	EndIf
EndIf

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A310PrcAtfºAutor  ³Microsiga           º Data ³  06/22/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Processo de gravação de bem planejado                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A310PrcAtf(nOpc,cBase,cItem)
Local lGravou := .F.

MsgRun( STR0040 ,, {|| lGravou := A310GrvAtf(nOpc,cBase,cItem) } ) //"Processando..."

Return(lGravou)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A310GrvAtf³ Autor ³ Andre Lago            ³ Data ³ 02/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gravacao do Ativo Fixo                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nOpc    : 1 - Inclusao / 2 - Exclusao                       ³±±
±±³          ³cBase   : Codigo Base do Ativo                              ³±±
±±³          ³cItem   : Item da Nota Fiscal                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Este Programa grava um ativo por planejamento aquisição,    ³±±
±±³          ³alterando-se o Item do ativo. Nem todos os dados do Ativo   ³±±
±±³          ³serao gravados pois nao ha todas as informacoes no planeja- ³±±
±±³          ³mento e o classidor nao tem condicoes de faze-lo.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A310GrvAtf(nOpc,cBase,cItem)

Local aArea	   := GetArea()
Local nUsado   := 0
Local nCntFor  := 0
Local lGravou  := .F.
Local lAtuSX6  := .F.
Local lIncAnt  := .F. 
Local nMoeda   := iif(cPaisLoc == "BRA",1,SF1->F1_MOEDA)
Local aCab 	 := {}
Local aItens	 := {}
Local aAux		 := {}
Local cCadastro := ''
Private	lMsErroAuto := .F.

If nOpc == 1
	PRIVATE uCampo	:= ""
	PRIVATE aHeader:= {}
	PRIVATE aCols	:= {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula o Codigo Base do Ativo                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( Empty(cBase) )
		GetMV("MV_CBASEAP")    //Novo parametro
		If ( RecLock("SX6") )
			cBase := &(GetMV("MV_CBASEAP"))
			If ( AllTrim(cBase) $ GetMV("MV_CBASEAP") )
				lAtuSX6 := .T.
			EndIf
		EndIf
		dbSelectArea("SN1")
		dbSetOrder(1)
		While MsSeek(xFilial("SN1")+cBase)
			cBase := Soma1(cBase,Len(SN1->N1_CBASE))
		EndDo
		If ( lAtuSX6 )                                                
		
			PutMV("MV_CBASEAP",'"'+Soma1(cBase,Len(SN1->N1_CBASE))+'"')
		EndIf
		SX6->(MsUnLock())
	EndIf
	If ( !Empty(cBase) ) 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Preenchimento das Variaveis referentes ao SN1                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd(aCab,{"N1_CBASE" 	, cBase		})
		AAdd(aCab,{"N1_ITEM" 	, cItem			})
		AAdd(aCab,{"N1_AQUISIC"  , dDataBase	})
		AAdd(aCab,{"N1_DESCRIC"  , SNN->NN_DESCRIC	})
		AAdd(aCab,{"N1_QUANTD"  	, SNN->NN_QUANTD	})
		AAdd(aCab,{"N1_GRUPO"  	, SNN->NN_GRUPO	})
		AAdd(aCab,{"N1_PATRIM"   , "N"			})
		AAdd(aCab,{"N1_STATUS"   , "0"			}) //Bem Pendente de classificação
		AAdd(aCab,{"N1_ORIGEM"   , "ATFA310"	}) //Indica que é um bem planejado
				

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Preenchimento das Variaveis referentes ao SN3                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		
		AAdd(aAux,{"N3_TIPO"		, "01"				})
		AAdd(aAux,{"N3_CCONTAB" 	, SNN->NN_CCONTAB	})
		AAdd(aAux,{"N3_CUSTBEM" 	, SNN->NN_CUSTBEM	})
		AAdd(aAux,{"N3_SUBCCON" 	, SNN->NN_SUBCCON	})
		AAdd(aAux,{"N3_CLVLCON" 	, SNN->NN_CLVLCON	})
		AAdd(aAux,{"N3_VORIG1" 	, xMoeda( SNN->NN_VORIG1,nMoeda,1,dDataBase)})
		AAdd(aAux,{"N3_VORIG2" 	, xMoeda( SNN->NN_VORIG2,nMoeda,1,dDataBase)})
		AAdd(aAux,{"N3_VORIG3" 	, xMoeda( SNN->NN_VORIG3,nMoeda,1,dDataBase)})
		AAdd(aAux,{"N3_VORIG4" 	, xMoeda( SNN->NN_VORIG4,nMoeda,1,dDataBase)})
		AAdd(aAux,{"N3_VORIG5" 	, xMoeda( SNN->NN_VORIG5,nMoeda,1,dDataBase)})
		AAdd(aAux,{"N3_TXDEPR1" 	, SNN->NN_TXDEPR1})
		AAdd(aAux,{"N3_TXDEPR2" 	, SNN->NN_TXDEPR2})
		AAdd(aAux,{"N3_TXDEPR3" 	, SNN->NN_TXDEPR3})
		AAdd(aAux,{"N3_TXDEPR4" 	, SNN->NN_TXDEPR4})
		AAdd(aAux,{"N3_TXDEPR5" 	, SNN->NN_TXDEPR5})
		AAdd(aAux,{"N3_CUSTBEM" 	, SNN->NN_CUSTBEM })
		AAdd(aAux,{"N3_CDEPREC" 	, SNN->NN_CDEPREC})
		AAdd(aAux,{"N3_CCDEPR" 	, SNN->NN_CCDEPR})
		AAdd(aAux,{"N3_CCDESP" 	, SNN->NN_CCDESP})
		AAdd(aAux,{"N3_CCCDEP" 	, SNN->NN_CCCDEP})
		AAdd(aAux,{"N3_SUBCDEP" 	, SNN->NN_SUBCDEP})
		AAdd(aAux,{"N3_SUBCCDE" 	, SNN->NN_SUBCCDE})
		AAdd(aAux,{"N3_CLVLDEP" 	, SNN->NN_CLVLDEP})
		AAdd(aAux,{"N3_CLVLCDE" 	, SNN->NN_CLVLCDE})
		aAdd(aAux,{"N3_HISTOR"	, STR0001 } ) //Planejamento de aquisição.

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa as Variaveis Privates utilizadas pela funcao af010Grava      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lCopia		:= .F.
		lContabiliza:= .F.
		lHeader	:= .F.
		lTrailler	:= .F.
		lCProva	:= .F.
		Inclui     := .T.
      	n			:= 1
		aAdd(aItens, aAux)
		dbSelectArea("SN1")
		Pergunte("AFA012",.F.)
		
		MSExecAuto({|x,y,z| ATFA012(x,y,z)},aCab,aItens,3)
		//lGravou := Af010Grava("SN1","SN3",.F.,.T.,.F.)
		If lMsErroAuto
			lMsErroAuto := .F.
			DisarmTransaction()
			lRet := .F.

			cFileLog := NomeAutoLog()
			cPath := ""
			If !Empty(cFileLog) .And. !lRet
				MostraErro(cPath,cFileLog)
			Endif
		Else
			dbSelectArea("SNN")
			RecLock("SNN")
				SNN->NN_CODEFTV := cBase
				SNN->NN_ITMEFTV := cItem  
				SNN->NN_AQUISIC := dDataBase
			MsUnLock()
		EndIf
	EndIf
Else
	If ( !Empty(cBase) )
		dbSelectArea("SN1")
		dbSetOrder(1)
		If ( MsSeek(xFilial("SN1")+AllTrim(cBase)))

			If Alltrim(SN1->N1_STATUS) == '0'	
				
				If FWExecView(cCadastro, 'ATFA012', MODEL_OPERATION_DELETE, /*oDLG*/, { || .T. }) == 0
					dbSelectArea("SNN")
					RecLock("SNN")
						SNN->NN_CODEFTV := ""
						SNN->NN_ITMEFTV := ""
						SNN->NN_AQUISIC := CTOD("")
					MsUnLock()
				EndIf	
			Else
				Help(" ", 1, "AFNOEXC",, STR0027, 1, 0) // "Ativos nao podem ser excluidos, pois já foram classificados "
			EndIf
		Else
			Help(" ", 1, "AFNOEXC",, STR0027, 1, 0) // "Ativos nao podem ser excluidos, pois já foram classificados "			
		EndIf
	EndIf
EndIf

aSize(aAux,0)
aAux := Nil
aSize(aItens,0)
aItens := Nil
RestArea(aArea)

Return(lGravou)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AdmAbreSM0³ Autor ³ Orizio                ³ Data ³ 22/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna um array com as informacoes das filias das empresas ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AdmAbreSM0()
	Local aArea			:= SM0->( GetArea() )
	Local aAux			:= {}
	Local aRetSM0		:= {}
	Local lFWLoadSM0	:= .T.
	Local lFWCodFilSM0 := .T.

	If lFWLoadSM0
		aRetSM0	:= FWLoadSM0()
	Else
		DbSelectArea( "SM0" )
		SM0->( DbGoTop() )
		While SM0->( !Eof() )
			aAux := { 	SM0->M0_CODIGO,;
						IIf( lFWCodFilSM0, FWGETCODFILIAL, SM0->M0_CODFIL ),;
						"",;
						"",;
						"",;
						SM0->M0_NOME,;
						SM0->M0_FILIAL }

			aAdd( aRetSM0, aClone( aAux ) )
			SM0->( DbSkip() )
		End
	EndIf

	RestArea( aArea )
Return aRetSM0


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Fabio Alves Silva     ³ Data ³05/10/2006³±±
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
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados    		  ³±±
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
Private aRotina	:= {} 
Aadd( aRotina, {STR0031			,"AxPesqui" 	 , 0 , 1,0,.F.   } ) //"Pesquisar"
Aadd( aRotina, {STR0032	   		,"AF310Man" 	 , 0 , 2,0,nil   } )//"Visualizar"
Aadd( aRotina, {STR0033			,"AF310Man" 	 , 0 , 3,0,nil   } )//"Incluir"
Aadd( aRotina, {STR0034			,"AF310Man" 	 , 0 , 4,0,nil   } )//"Alterar"
Aadd( aRotina, {STR0035			,"AF310Man" 	 , 0 , 5,3,nil		} )//"Excluir"
Aadd( aRotina, {STR0036			,"AF310Man" 	 , 0 , 6,0,nil		} )//"Copia"
Aadd( aRotina, {STR0037			,"AF310Efe"	 , 0 , 7,0,nil		} )//"Efetivar"
Aadd( aRotina, {STR0038			,"AF310Efe"  	 , 0 , 8,0,nil		} )//"Estorno Efet."
Aadd( aRotina, {STR0039			,"AF310Legenda", 0 , 9,0,nil		} )//"Legenda"
Return (aRotina)  

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Af310Legenda³ Autor ³ Rodrigo Gimenes     ³ Data ³ 11.11.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse ou retorna a ³±±
±±³          ³ para o BROWSE                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atfa310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Af310Legenda(cAlias, nReg)
                                     
Local aLegenda := 	{ 	{"BR_PRETO", STR0028 },; //"Bem nao Efetivado"
						{"BR_VERDE", STR0029 }} //"Bem Efetivado"
Local uRetorno := .T. 


If nReg == Nil	
	uRetorno := {}
	Aadd(uRetorno, { '!Empty(NN_CODEFTV)', aLegenda[2][1] } )
	Aadd(uRetorno, { 'Empty(NN_CODEFTV)', aLegenda[1][1] } )
Else
	BrwLegenda(cCadastro,STR0030, aLegenda) //"Legenda"
Endif

Return uRetorno             


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³a310Display ³ Autor ³ Rodrigo Gimenes       ³ Data ³ 15.12.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³Atualiza tela de sele‡ao de registros da efetivação de bens   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe  ³a310Display ( cMarca,lInverte)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ ATFA310                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function a310Display(cMarca,lInverte)

SNN->(RecLock("SNN",.f.))


If !IsMark("NN_OK",cMarca,lInverte)
	SNN->NN_OK := cMarca
Else
	SNN->NN_OK := " "
EndIf
SNN->(MsUnlock())

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A310Desmar  ³ Autor ³ Alice Yamamoto        ³ Data ³ 20.12.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Desmarca os bens se NAO confirmar a baixa                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A310Desmar()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATFA310                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A310Desmar(nIndex)
Local aArea := { Alias(), IndexOrd(), Recno()}    
//Local cFiltro := ""
                                

dbSelectArea("SNN")          
//cFiltro := SNN->(DbFilter())
SNN->(dbGoTop())
SET FILTER TO NN_OK == cMarca
While SNN->(!EOF())
	SNN->(RecLock("SNN",.f.))
	SNN->NN_OK := "  "
	SNN->(MsUnlock())
	SNN->(dbSkip())
	Loop
EndDo
SET FILTER TO 
dbSelectArea(aArea[1])
dbSetOrder(aArea[2])
dbGoto(aArea[3])
Return
   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AF310Check³ Autor ³ Rodrigo Gimenes       ³ Data ³ 15/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna expressao para Indice Condicional                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AF310Check                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEstorno                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATFA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF310Check(lEstorno)
Local cFiltro := ""
 
cFiltro := Iif(lEstorno,"!","") +  "Empty(NN_CODEFTV) "
If !Empty(MV_PAR01) .AND. !Empty(MV_PAR02) 			
	cFiltro += " .AND. (NN_FILIAL >= '" + MV_PAR01 + "' .AND. NN_FILIAL <= '" + MV_PAR02  + "') "        //- Filial De? //- Filial At‚?	  
EndIf
If !Empty(MV_PAR03) .AND. !Empty(MV_PAR04) 			
	cFiltro += " .AND. (NN_GRUPO >= '"  + AllTrim(MV_PAR03) + "' .AND. NN_GRUPO <= '" + Alltrim(MV_PAR04)  + "') "       //- Grupo de? //- Grupo Ate? //
EndIf

If lEstorno .AND. !Empty(MV_PAR05) .AND. !Empty(MV_PAR06) 			
	cFiltro += " .AND. (DTOS(NN_AQUISIC) >= '" +  DTOS(MV_PAR05) + "' .AND. DTOS(NN_AQUISIC) <= '" +  DTOS(MV_PAR06) + "')"     //- Aquisição de? //- Aquisição Ate? //
EndIf
If !Empty(MV_PAR07)
	cFiltro += " .AND.  (DTOS(NN_DTPREVI) == '" +  DTOS(MV_PAR07) + "')"           	//- Data Prevista?
EndIf	
If !Empty(MV_PAR08)
	cFiltro += " .AND. ('" + ALLTRIM(UPPER(MV_PAR08)) + "' $ NN_DESCRIC)"   //- Descricao do Bem
EndIf 

Return cFiltro

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AF310GRUPO ³ Autor ³ TOTVS                 ³ Data ³ 10.08.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preenche Informações do Grupo.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ATFA010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF310GRUPO(lGrupo)
Local nTaxa := 0, ny, aAreaSx3, uRet

Local nX        
Local nInc
Local nPosSNG := 0

Local lOk := .T.
Local lRet := .T.
Local lClass := IIF(type("lClassifica")=="U",.F.,lClassifica) 
Local aEntidade := {}
Local nLinhaBem := 0 
Local cConteudo := ""  




DEFAULT lGrupo := .F.

If lOk
	If lGrupo
		SNG->(DbSeek(xFilial("SNG") + M->NN_GRUPO))
	Endif

	 //Cria array com os nomes dos campos do SNG (Cadastro de grupos)
	IF Len(aEntidade) == 0
		SX3->(MsSeek("SNG"))
		SX3->(DbEval( { || Aadd(aEntidade, SX3->X3_CAMPO ) }, , { || SX3->X3_ARQUIVO == "SNG" } ) )
	ENDIF
	
	nLinhaBem := oGetD:nAt
	For ny:=1 To Len(oGetD:aHeader)                                                       

		If lGrupo  .And. "AF310AGRP" $ Upper(oGetD:aHeader[ny][11])
			If aAreaSx3 = Nil
				aAreaSx3 := SX3->(GetArea())
				SX3->(DbSetOrder(2))                     
			Endif
			SX3->(DbSeek(oGetD:aHeader[ny][2]))                      
			If ! SX3 ->(EOF())
				uRet := CriaVar(oGetD:aHeader[ny][2])                
				If uRet <> Nil
					oGetD:aCols[nLinhaBem][ny] := uRet
				Endif
			EndIf

		ElseIf Trim(oGetD:aHeader[nY][2]) != "NN_FILIAL" .AND.;
			(nPosSNG := aScan(aEntidade,{|cEntidade| ALLTRIM(SUBSTR(cEntidade,4,10)) == ALLTRIM(SUBSTR(oGetD:aHeader[nY][2],4,10))})) > 0
			If lGrupo .and. !EMPTY(&("SNG->"+ALLTRIM(aEntidade[nPosSNG]))) 
				oGetD:aCols[nLinhaBem][ny] := &("SNG->"+aEntidade[nPosSNG])
			Endif
		EndIf

	Next ny
	oGetD:Refresh()	
EndIf


Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AF310AGRP  ³ Autor ³ TOTVS SA              ³ Data ³ 10.08.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preenche entidades contabeis no bem de acordo com grupo [SNG]³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ATFA310                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/       
Function AF310AGRP(cEntidade)

Local cRetorno := "", lErr := .F.
Local lSemIndice, nOrdem

If Type("M->NN_GRUPO") <> "U" 
    lSemIndice := Upper( SubStr(SNN->(IndexKey()),1,26) ) <> "NN_FILIAL+NN_CODIGO+NN_ITEM"
	If lSemIndice       
		nOrdem := SN3->( IndexOrd() )
		SNN->( DbSetOrder(1) )
	EndIf
	SN3->(MsSeek(xFilial("SNN")+M->(NN_CODIGO+NN_ITEM)))
	If ! Empty(M->NN_GRUPO)
		If SNG->NG_GRUPO <> M->NN_GRUPO
			SNG->(DbSeek(xFilial("SNG") + M->NN_GRUPO))
		Endif
		If SNG->(FieldPos("NG_" + Subs(cEntidade, 4))) <> 0
			If Empty(&("SNN->NN_" + Subs(cEntidade, 4)))
				cRetorno := &("SNG->NG_" + Subs(cEntidade, 4))
			Else
				cRetorno := &("SNN->NN_" + Subs(cEntidade, 4))
			Endif	
		Else
			lErr := .T.
		Endif
	else
		If cEntidade <> nil .and. TamSX3(cEntidade)[3] == "N"
			cRetorno := 0
		EndIf	
	Endif	
	If lSemIndice       
		SNN->( DbSetOrder(nOrdem) )
	EndIf
Else
	If SNG->(FieldPos("NG_" + Subs(cEntidade, 4))) <> 0
		cRetorno := &("SNN->" + cEntidade)
	Else
		lErr := .T.
	Endif
Endif

If lErr
	Help(" ",1,"INITERR",, X3Titulo(),4,2)
Endif
	
Return cRetorno    



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AF010ACONV  ºAutor  ³TOTVS			    º Data ³  13/10/10   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Converte Valor de aquisi‡„o moeda 1 para moedas 2,3,4 e 5.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ATFA010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF310ACONV( )
Local nValor:=&(ReadVar())
Local cCampo:=  ReadVar()      
Local lMultMoed := .T.
Local cMoedaAtf := GetMV("MV_ATFMOEDA")
// Data de conversao das moedas para reavaliacao sera a data base.
Local dDtConv := dDataBase
Local nPosVOrigAtf := Ascan(aHeader	, {|e| Alltrim(e[2]) = "NN_VORIG"+cMoedaAtf} )

//********************************
// Controle de multiplas moedas  *
//********************************
Local __nQuantas := If(lMultMoed,AtfMoedas(),5)
Local aPosVOrigX:= If(lMultMoed,AtfMultPos(aHeader,"NN_VORIG"),;
					{ 	Ascan(aHeader	, {|e| Alltrim(e[2]) == "NN_VORIG2" } ),;
						Ascan(aHeader	, {|e| Alltrim(e[2]) == "NN_VORIG3" } ),;
						Ascan(aHeader	, {|e| Alltrim(e[2]) == "NN_VORIG4" } ),;
						Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG5" } ) })
Local nX

	//********************************
	// Controle de multiplas moedas  *
	//********************************
	//Converte apenas com base na moeda 1, pois o valor do ativo na outra moeda não necessita ter base na cotação do dia.
	If "NN_VORIG1" $ cCampo
		For nX := 2 to __nQuantas
			If aPosVOrigX[nX] > 0
				aCols[n][aPosVOrigX[nX]] := nValor / RecMoeda(dDtConv,nX)
				&("M->NN_VORIG"+AllTrim(Str(nX))) := aCols[n][aPosVOrigX[nX]]
			Endif	
		Next
	EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFA310   ºAutor  ³Microsiga           º Data ³  06/22/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function aF310Marca(cAlias,cMarca,lInverte)
Local aArea := GetArea()

(cAlias)->(DbGoTop())
While (cAlias)->(!Eof())
	RecLock("SNN",.F.)
	If SNN->NN_OK == cMarca
		SNN->NN_OK := " "
	Else
		SNN->NN_OK := cMarca
	EndIf
	MsUnLock()
	(cAlias)->(dbSkip())
EndDo

RestArea(aArea)
Return



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AF310ATAXA  ³ Autor ³ TOTVS                 ³ Data ³ 10.08.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preenche Taxa deprecia‡„o para todas das moedas.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ATFA010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF310ATAXA()

Static lZeraDepr

Local nTaxa := 0
Local nX	:= 0
Local ny	:= 0
Local aPosTaxa	:= {}
Local alMoeda	:= {}
Local lRet		:= .T.

// *******************************
// Controle de multiplas moedas  *
// *******************************
Local lMultMoed := .T.
Local __nQuantas := If(lMultMoed,AtfMoedas(),5)

// *******************************
// Controle de multiplas moedas  *
// *******************************
aAdd( alMoeda , nil )
For nX:= 2 to __nQuantas
	aAdd( alMoeda , Empty(GETMV("MV_MOEDA" + ALLTRIM(Str(nX)))) )
Next

If lZeraDepr == Nil
	lZeraDepr := GetNewPar("MV_ZRADEPR",.F.)
Endif
	
// *******************************
// Controle de multiplas moedas  *
// *******************************
aPosTaxa := If(lMultMoed,AtfMultPos(aHeader,"NN_TXDEPR"),;
					 	{Ascan(aHeader	, {|e| Alltrim(e[2]) == "NN_TXDEPR1" } ),;
					 	 Ascan(aHeader	, {|e| Alltrim(e[2]) == "NN_TXDEPR2" } ),;
						 Ascan(aHeader	, {|e| Alltrim(e[2]) == "NN_TXDEPR3" } ),;
						 Ascan(aHeader	, {|e| Alltrim(e[2]) == "NN_TXDEPR4" } ),;
						 Ascan(aHeader	, {|e| Alltrim(e[2]) == "NN_TXDEPR5" } ) })

aCols[n][aPosTaxa[1]] := &(ReadVar())
	
If lZeraDepr
	nTaxa := &(ReadVar())
EndIf
	
// *******************************
// Controle de multiplas moedas  *
// *******************************
For nX := 2 to __nQuantas
	If aPosTaxa[nX] <= 0
		Loop
	EndIf
	If !alMoeda[nX]	/// Se não tem a moeda informada no parâmetro (Moeda em branco)
		aCols[n][aPosTaxa[nX]] :=&(ReadVar())
	EndIf
Next
	
If lZeraDepr .And. aCols[n][01] $ "02#05"
	// Assume a ultima taxa para todos os itens
	For nY := 1 To Len( aCols )
		aEval( aPosTaxa, { |x| aCols[nY][x] := nTaxa } )
	Next
Endif
	
If (Type('lAtfAuto') == "U" .Or. ! lAtfAuto) .And. Type("__oGet") == "O"
	__oGet:Refresh()
EndIf
	
Return .T.


//------------------------------------------------------------------------------
/*/{Protheus.doc} ValClaSint
Validar entidade contábil SINTÉTICA trazendo um help informando que o usuário
deve utilizar uma entidade ANALÍTICA. 
Uso no X3_VALID da tabela SNN (Planejamento de aquisições). 
@author Thiago Meneses
@since 17/01/2019
@version P12

@return  logico, indica se a entidade contábil é valida e não pode ser sintética
/*/
//------------------------------------------------------------------------------
Function ValClaSint(cConta,cTabela,nIndice,cCampo)

Local lRet		:= .T.

DEFAULT cConta	:= ""
DEFAULT cTabela := ""
DEFAULT nIndice := ""
DEFAULT cCampo 	:= ""

DBSelectArea(cTabela)
DBSetOrder(nIndice)

If !Empty(cConta)

	If ExistCpo(cTabela,cConta)
		If dbSeek(xFilial(cTabela)+cConta)
			If (cTabela)->&(cCampo) == '1'
				Help(" ",1,".A310VLDCLASS.",,STR0042,1,0) //STR0042 "Entidade contábil SINTÉTICA não é permitida."
				lRet := .F.
			EndIf
		EndIf
	Else
		lRet := .F.
	EndIf
EndIf 
Return lRet