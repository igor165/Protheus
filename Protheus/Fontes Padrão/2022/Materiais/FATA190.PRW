#INCLUDE "FATA190.ch"
#INCLUDE "Protheus.ch"
#DEFINE MAXSAVERESULT 99999

Static aUltResult

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FATA190  ³ Autor ³ Henry Fila            ³ Data ³ 03.02.02   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualizacao de Verbas de Vendas                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Materiais - OMS/FATURAMENTO                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FATA190()

Local aCores := {	{ 'Dtos(ACK->ACK_DATFIM) >= Dtos(dDataBase)' , 'ENABLE' },; 	//Em Aberto
					{ 'Dtos(ACK->ACK_DATFIM) < Dtos(dDataBase)' , 'DISABLE'}}						//Encerrado

Private cCadastro	:= STR0001 //"Verbas de Vendas"
Private aRotina	:= MenuDef()

aUltResult := {}				
DbSelectArea("ACK")
DbSetOrder(1)

mBrowse(06,01,22,75,"ACK",,,,,,aCores)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Oms130Mnt ³ Autor ³Henry Fila             ³ Data ³02.03.2001  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Manutencao da administracao de entregas                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do Arquivo                                       ³±±
±±³          ³ExpN2: Numero do Registro                                     ³±±
±±³          ³ExpN3: Opcao do aRotina                                       ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Fernando     ³14/02/07³119222³Alteração feita para usar a FilgetDados   ³±±
±±³              ³        ³      ³na montagem do Aheader e Acols            ³±±
±±³ Conrado Q.   ³03/04/07³122662³Passa para o Tec190Item o aRecno para     ³±±
±±³              ³        ³      ³serem adicionados os recnos visual./alter.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Fat190Mnt(cAlias, nReg, nOpc)

Local aArea     := GetArea()
Local aGet      := {}
Local aPosObj   := {} 
Local aObjects  := {}                        
Local aSize     := MsAdvSize( .T. )             
Local aTravas	:= {}
Local aRecno    := {}
Local aVisual   := {}

Local lTrava	:= .T.
Local lProcessa := .T.

Local nUsado	:= 0
Local nOpca	 	:= 0
Local nPosCod   := 0              
Local nSaveSx8  := 0
Local nCntFor   := 0 
Local cSeek  	:= Nil
Local cWhile 	:= Nil               
Local oDlg

Private aHeader := {}
Private aCols	:= {} 
PRIVATE aTELA[0][0],aGETS[0]

If nOpc == 5
	lProcessa := Ft190CanDel(ACK->ACK_CODVER)
Endif	

If lProcessa

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa a Variaveis da Enchoice.                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("ACK")
	While ( !Eof() .And. (SX3->X3_ARQUIVO == "ACK") )
		cCampo := SX3->X3_CAMPO
		If SX3->(X3USO(X3_USADO) .And. cNivel >= X3_NIVEL)
			Aadd(aVisual,SX3->X3_CAMPO)
			If	( SX3->X3_CONTEXT == "V"  .Or. Inclui )
				M->&(cCampo) := CriaVar(SX3->X3_CAMPO)
			Else
				M->&(cCampo) := ACK->(FieldGet(FieldPos(SX3->X3_CAMPO)))
			EndIf
		EndIf
		DbSelectArea("SX3")
		DbSkip()
	End
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Array aHeader.                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	cSeek  := 	xFilial("ACL")+ACK->ACK_CODVER
 	cWhile :=	("ACL->ACL_FILIAL+ACL->ACL_CODVER") 
 

	FillGetDados(	nOpc 		 	,"ACL"						,1								,cSeek					,;
					{||&(cWhile)}	,/*{|| bCond,bAct1,bAct2}*/	,/*aNoFields*/					,/*aYesFields*/			,;
					/*lOnlyYes*/	,/* cQuery*/				,/*bMontAcols*/					,IIf(nOpc<>3,.F.,.T.)	,;
					/*aHeaderAux*/	,/*aColsAux*/				,{||Fat190Item( nOpc, aRecno )}	,/*bBeforeCols*/		,;
					/*bAfterHeader*/,/*cAliasQry*/				)
	
	AAdd( aObjects, { 100, 065, .t., .t. } )
	AAdd( aObjects, { 100, 100, .t., .t. } )
			
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )
	
	If ( lTrava )
	
		DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],00 to aSize[6],aSize[5] Of oMainWnd PIXEL
	
			EnChoice( "ACK", nReg, nOpc, , , , , aPosObj[1],,3,,,.T.)
	
			DbSelectArea("ACL")		
			oGetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"Fat190LOk()","AllWaysTrue()","+ACL_ITEM",.T.,,,,999)
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1, If(Fat190TOk().And.oGetd:TudoOk(),If(!obrigatorio(aGets,aTela),nOpcA := 0,oDlg:End()),nOpcA := 0)},{||oDlg:End()})			
		
		If ( nOpcA == 1 ) .And. (nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 5 )
			Begin Transaction
				lGravou := Fat190Grv(nOpc-2,aRecno)
				If ( lGravou )
					EvalTrigger()
					While (GetSx8Len() > nSaveSx8)
						ConfirmSx8()
					End
				EndIf
			End Transaction
		EndIf
		While (GetSx8Len() > nSaveSx8)
			RollBackSx8()
		End
	
	Endif
	
	MsUnlockAll()    
	
Endif	
		
DbSelectArea("ACK")
DbSetOrder(1)               

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    |Fat190ITem  ºAutor ³Fernando Amorim      º Data ³ 15/02/07  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Inclui na primeira linha do acols o numero do item 		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³nPar1: Opção escolhida pelo usuário			              º±±
±±º          ³aPar2: Lista de registros (recnos) consultados/alterados    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Regras de descontos                                   	  º±±
±±ºÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±º Atualizacoes sofridas desde a Construcao Inicial.                     º±±
±±ºÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±º Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                   º±±
±±ºÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±º Conrado Q.   ³03/04/07³122662³ Adiciona ao array aRecnos os registros º±±
±±º              ³        ³      ³ (recnos) consultados/alterados.        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Fat190Item(nOpc, aRecno)
	Local nX := 0

	If (nOpc == 3)
		If Len(aCols) == 1
			For nX := 1 To Len(aHeader)
					If AllTrim(aHeader[nX,2]) == "ACL_ITEM"
							aCOLS[Len(aCols)][nX] := StrZero(1,Len(ACL->ACL_ITEM))
					
					EndIf    
			Next nX
		EndIf  
	Else
		aAdd(aRecno, ACL->(Recno()) )
	EndIf
Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fat190Grv ³ Autor ³Henry Fila             ³ Data ³02.03.2001  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gravacao   da administracao de entregas                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: nOpcao                                                 ³±±
±±³          ³ExpC2: Codigo do Cliente                                      ³±±
±±³          ³ExpC3: Codigo da Loja                                         ³±±
±±³          ³ExpA4: Array com registros para utilizar na gravacao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Fat190Grv(nOpcao,aRecno)

Local bCampo 	:= {|nCPO| Field(nCPO) }

Local nCntFor  := 0
Local nCntFor2 := 0           
Local nUsado   := Len(aHeader)
Local lGravou  := .F.        
Local nY       := 0 

aUltResult := Nil

Do Case
	Case ( nOpcao <> 3 )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³De acordo com a normalizacao inclui cabecalho depois os itens³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("ACK",INCLUI)
		For nY := 1 TO FCount()
			If "FILIAL"$Field(nY)						
				ACK->ACK_FILIAL := xFilial("ACK")					
			Else						
				FieldPut(nY,M->&(EVAL(bCampo,nY)))
			Endif						
		Next nY

		ACK->(FkCommit())
		
		DbSelectArea("ACL")	
		For nCntFor := 1 To Len(aCols)
		
			If ( !aCols[nCntFor][nUsado+1] )

				If nCntFor > Len(aRecno)
					RecLock("ACL",.T.)					
				Else 
					dbGoto(aRecno[nCntFor])            
					RecLock("ACL",.F.)											
				Endif						
			
				For nCntFor2 := 1 To nUsado
					If ( aHeader[nCntFor2][10] <> "V" )
						ACL->(FieldPut(FieldPos(aHeader[nCntFor2][2]),aCols[nCntFor][nCntFor2]))
					EndIf
				Next nCntFor2

				ACL->ACL_FILIAL := xFilial("ACL")
				ACL->ACL_CODVER := M->ACK_CODVER
				
				MsUnlock()					
				
				lGravou := .T.
				
			Else
			
				If nCntFor <= Len(aRecno)
					dbGoto(aRecno[nCntFor])
					RecLock("ACL")
						dbDelete() 
					MsUnlock()
				Endif						
			EndIf
		Next nCntFor
		
	OtherWise
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³De acordo com a normalizacao exclui itens depois o cabecalho ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nCntFor := 1 To Len(aCols)
			If nCntFor <= Len(aRecno)
				dbGoto(aRecno[nCntFor])
				RecLock("ACL")
					dbDelete() 
				MsUnlock()
			Endif						
		Next
		
		RecLock("ACK",.F.)
			dbDelete()
		MsUnlock()			
		
EndCase
Return(lGravou)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fat190LOk ³ Autor ³ Henry Fila            ³ Data ³26.04.02    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava a janela de entrega                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico (DISTRIBUIDORES)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fat190LOk()

Local lRet     := .T.
Local nPosProd := aScan(aHeader,{|x| Alltrim(x[2]) == "ACL_CODPRO"})
Local nX       := 0
Local nUsado   := Len(aHeader)

If !aCols[n][nUsado+1]
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe chaves iguais no acols digitado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len(aCols)            
		If !aCols[nX][nUsado+1]	 .And. nX <> n
			If aCols[nX][nPosProd] == aCols[n][nPosProd]
	    		Help(" ",1,"FAT190CHV") //O produto informado ja existe nesta verba de vendas PARA ATUSX X.11
				lRet := .F.
			Endif		
		Endif		
	Next
	
Endif
	
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fat190TOk ³ Autor ³ Henry Fila            ³ Data ³26.04.02    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a verba de venda                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico (DISTRIBUIDORES)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Fat190TOk()

Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaACK := ACK->(GetArea())

Local cGrpCli  := M->ACK_GRPCLI
Local cCodCli  := M->ACK_CODCLI
Local cLoja    := M->ACK_LOJA
Local cGrpVen  := M->ACK_GRPVEN
Local cCodVen  := M->ACK_CODVEN          

#IFDEF TOP 
	Local cAliasACK:= "" 
	Local cQuery   := ""	
#ELSE
	Local nRecno   := 0	
#ENDIF 	


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se todos estão em branco               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If INCLUI .Or. ALTERA

	If Empty(cGrpVen) .And. Empty(cCodVen) .And. Empty(cCodCli) .And. Empty(cLoja) .And. Empty(cGrpCli)
		lRet := .F.
		Help(" ",1,"FAT190001")  //
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se grupo de clientes e clientes estão preenchidos e     ³
	//³e grupo de vendedores e vendedor estao preenchidos             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		If (!Empty(cGrpVen) .And. !Empty(cCodVen)) .Or. (!Empty(cCodCli) .And. !Empty(cGrpCli))
			lRet := .F.
			Help(" ",1,"FAT190002")  
		Endif	
	Endif

	If lRet
		If (!Empty(cCodCli) .And. Empty(cLoja)) .Or. (Empty(cCodCli) .And. !Empty(cLoja))
			lRet := .F.
			Help(" ",1,"FAT190004")  
		Endif
	Endif
		
	If lRet
	
		#IFDEF TOP
		
			cAliasACK := "QRYACK"
			
			cQuery    := "SELECT * FROM "
			cQuery    += RetSqlName("ACK") +" ACK "
			cQuery    += " WHERE "
			cQuery    += "ACK_FILIAL = '"+xFilial("ACK")+ "' AND "	  
			cQuery    += "ACK_GRPVEN = '"+M->ACK_GRPVEN+ "' AND "
			cQuery    += "ACK_CODVEN = '"+M->ACK_CODVEN+ "' AND "			
			cQuery    += "ACK_GRPCLI = '"+M->ACK_GRPCLI+ "' AND "						
			cQuery    += "ACK_CODCLI = '"+M->ACK_CODCLI+ "' AND "						
			cQuery    += "ACK_LOJA   = '"+M->ACK_LOJA+ "' AND "						
			cQuery    += "(ACK_DATFIM >= '"+Dtos(M->ACK_DATINI)+"' AND " 
			cQuery    += " ACK_DATINI <= '"+Dtos(M->ACK_DATFIM)+"')AND " 
			If ALTERA
				cQuery += "ACK.R_E_C_N_O_ <> "+Alltrim(Str(ACK->(Recno())))+" AND "
			Endif			
			cQuery    += "ACK.D_E_L_E_T_ = ' '"
				
			cQuery := ChangeQuery(cQuery)        
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasACK,.T.,.T.)
				
			If (cAliasACK)->(!Eof())
				Help(" ",1,"FAT190003")	
				lRet := .F.                 
			Endif	

			(cAliasACK)->(dbCloseArea())
			DbSelectArea("ACK")
        #ELSE

			nRecno := ACK->(Recno())
	
			ACK->(DbSetOrder(2))
			If ACK->(DbSeek(xFilial("ACK")+M->ACK_GRPVEN+M->ACK_CODVEN+M->ACK_GRPCLI+M->ACK_CODCLI+M->ACK_LOJA))
			
				While ACK->(!Eof()) .And. ACK->ACK_FILIAL == xFilial("ACK") .And. ;
											ACK->ACK_GRPVEN == M->ACK_GRPVEN .And. ;
											ACK->ACK_CODVEN == M->ACK_CODVEN .And. ;
											ACK->ACK_GRPCLI == M->ACK_GRPCLI .And. ;
											ACK->ACK_LOJA   == M->ACK_LOJA .And. lRet
	                	
					If (ACK->ACK_DATFIM >= M->ACK_DATINI .And. ACK->ACK_DATINI <= M->ACK_DATFIM .And. nRecno <> ACK->(Recno()))
						Help(" ",1,"FAT190003")
						lRet := .F.                 
					Endif	
	
					ACK->(DbSkip())				
				End
		
			Endif                                                             
			
		#ENDIF	
		
	Endif
	
Endif
	
RestArea(aAreaACK)
RestArea(aArea)

Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fat190Leg ³Autor  ³ Henry fila            ³ Data ³06.02.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Demonstra a legenda das cores da mbrowse                     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina monta uma dialog com a descricao das cores da    ³±±
±±³          ³Mbrowse.                                                     ³±±
±±³          ³                                                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fat190Leg()

BrwLegenda(cCadastro,STR0007,{{"ENABLE",STR0008},; //"Legenda"###"Verba ativa"
								{"DISABLE",STR0009}}) //"Verba vencida"
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FtVerbaVen³ Autor ³Henry Fila             ³ Data ³14.02.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de avaliacao da Verba de Vendas                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias SC5                                            ³±±
±±³          ³ExpC2: Alias SC6                                            ³±±
±±³          ³ExpC3: Codigo do Cliente                                    ³±±
±±³          ³ExpC4: Loja do Cliente                                      ³±±
±±³          ³ExpC5: Vendedor                                             ³±±
±±³          ³ExpC6: Produto                                              ³±±
±±³          ³ExpL7: Indica se a baixa sera feita ou somente analise      ³±±
±±³          ³       .T. - Analisa e baixa caso tenha saldo               ³±±
±±³          ³       .F. - Somente analisa                                ³±±
±±³          ³ExpL7: Indica se a a verba nao tem saldo zera a verba e libe³±±
±±³          ³       ra                                                   ³±±
±±³          ³ExpL9: verba de venda que bloqueou o lancamento             ³±±
±±³          ³ExpL10: item da verba de venda que bloqueou o lancamento    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: 1 - Possui Verba de Vendas com Item                  ³±±
±±³          ³       2 - Possui Verba de Vendas sem Item                  ³±±                                                     ³±±
±±³          ³       3 - Nao Possui Verba de Vendas                       ³±±                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo avaliar a verba de vendas     ³±±
±±³          ³conforme os parametros da rotina                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Michel W.     ³15/03/07³9.12  ³Bops 121063 - Retirada a variavel       ³±±
±±³              ³        ³      ³CGRPVEN que nao era usada e nao era     ³±±
±±³              ³        ³      ³declarada, que causava error log.       ³±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FtVerbaVen(cAliasSC5,	cAliasSC6,	cCliente,	cLoja,;
					cCodVen,	cProduto, 	aProdDesc , lBaixa, cVerbaBlq, cItemBlq)

Local aArea      := GetArea()			//Armazena a area
Local aAreaACK   := ACK->(GetArea())	//Armazena a area do ACK
Local aGruposCli := {}					//Armazena o grupo de clientes
Local aGruposVen := {}					//Armazena o grupo de vendas
Local bCondic    := { || .T. } 			//Bloco de codigo executado na avaliacao dos items
Local cAliasACK  := ""					//Armazena o alias de ACK
Local cQuery     := ""					//Armazena a query
Local cDataBase  := Dtos(dDataBase)    	//Armazena a database                
Local cResult    := ""					//Armazena o resultado de algumas funcoes
Local cRet       := "3" 				//-- Nao possui Verba de Vendas
Local lContinua  := .T.					//Indica se continua verificando as verbas de vendas
Local lQuery     := .F.					//Indica se executou uma query
Local lGrupoVen  := .F.					//Indica se ha um grupo de vendas
Local lGrupoCli  := .F.					//Indica se ha um grupo de clientes
Local lUltResult := .F.					//Indica se encontou a verba de vendas
Local nX         := 0					//Variavel utilizada em Loops
Local nLoop      := 0					//Variavel utilizada em Loops 
Local nLoop2     := 0 					//Variavel utilizada em Loops

DEFAULT cCliente  := Space( Len( SA1->A1_COD    ) )
DEFAULT cLoja     := Space( Len( SA1->A1_LOJA   ) )
DEFAULT cCodVen   := Space( Len( SA3->A3_COD    ) )
DEFAULT cAliasSC5 := "SC5"
DEFAULT cAliasSC6 := "SC6"
DEFAULT lBaixa    := .F. 
DEFAULT aUltResult:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquisa a se existe verba para o cliente e para o vendedor            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nScan := aScan(aUltResult,{|x| x[1] == cCliente .And.;
								x[2] == cLoja    .And.;
								x[3] == cCodVen})


If nScan == 0

	#IFDEF TOP
		bCondic := { || .T. }
	#ELSE	
		bCondic := { ||  cDataBase >= DToS( ACK->ACK_DATINI ) .And. ;
					(  cDataBase <= DToS( ACK->ACK_DATFIM ) )  }  
	#ENDIF 					
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o vendedor e o cliente estao em estruturas                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SA1->( DbSetOrder( 1 ) ) 
	If SA1->( DbSeek( xFilial( "SA1" ) + cCliente + cLoja ) ) 	
		lGrupoCli := !Empty(SA1->A1_GRPVEN)
		If lGrupoCli 
			MaCliStrUp( SA1->A1_GRPVEN, @aGruposCli )  
		Endif
	Endif	
	
	If !Empty(cCodVen)
		SA3->( DbSetOrder( 1 ) ) 
		If SA3->( DbSeek( xFilial( "SA3" ) + cCodVen ) ) 	
			lGrupoVen := !Empty(SA3->A3_GRPREP)
			If lGrupoVen 
				MaVenStrUp( SA3->A3_GRPREP, @aGruposVen )  
			Endif
		Endif	
	Endif	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o existe verba para um vendedor e um cliente               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If !Empty(cCodVen)
	
		#IFDEF TOP 
	
			cAliasACK := "QUERYACK" 
		
			lQuery  := .T.
		
			cQuery := ""
			cQuery += "SELECT * FROM "  + RetSqlName( "ACK" ) + " ACK " 
			cQuery += "WHERE "	
			cQuery += "ACK_FILIAL='"    + xFilial( "ACK" )    + "' AND " 
			cQuery += "ACK_CODCLI='"    + cCliente            + "' AND " 
			cQuery += "ACK_LOJA='"      + cLoja               + "' AND "
			cQuery += "ACK_GRPCLI='"    + Space(Len(SA1->A1_GRPVEN)) + "' AND "	
			cQuery += "ACK_CODVEN='"    + cCodVen             + "' AND "
			cQuery += "ACK_GRPVEN='"    + Space(Len(SA3->A3_GRPREP)) + "' AND "
			cQuery += "ACK_DATINI <='"  + cDataBase           + "' AND "
			cQuery += "ACK_DATFIM >='"  + cDataBase           + "' AND "
			cQuery += "ACK.D_E_L_E_T_=' '"  
		
			cQuery := ChangeQuery( cQuery )        
		
			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasACK, .F., .T. ) 
	       
		#ELSE           
		
			cAliasACK := "ACK" 
	
			ACK->( DbSetOrder( 5 ) ) 
			ACK->( DbSeek( xFilial("ACK") + cCliente + cLoja + Space(Len(SA1->A1_GRPVEN)) + Space(Len(SA3->A3_GRPREP)) + cCodVen ) ) 
		
		#ENDIF 
	
		While !( cAliasACK )->( Eof() ) .And. xFilial("ACK")              == ( cAliasACK )->ACK_FILIAL  .And.;
											( cAliasACK )->ACK_CODCLI  == cCliente                    .And.;
											( cAliasACK )->ACK_LOJA    == cLoja                       .And.;
											( cAliasACK )->ACK_GRPCLI  == Space(Len(SA1->A1_GRPVEN)) .And. ;
											( cAliasACK )->ACK_GRPVEN  == Space(Len(SA3->A3_GRPREP)) .And. ;
											( cAliasACK )->ACK_CODVEN  == cCodVen
									
			If Eval( bCondic ) 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Avalia a regra para o item                                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                           
				lContinua  := .F.
				lUltResult := .T.
				cResult    := ( cAliasACK )->ACK_CODVER
				If FtVerbaIt( cAliasSC5,cAliasSC6,( cAliasACK )->ACK_CODVER, cProduto, aProdDesc,lBaixa, @cVerbaBlq, @cItemBlq)
					cRet := '1' //-- Possui Verba de Vendas com Itens 
				Else          
					cRet := '2' //-- Possui Verba de Vendas sem Itens 
				EndIf
			EndIf 	
			
			If !lContinua
				Exit 
			EndIf 								
						
			( cAliasACK )->( DbSkip() ) 			
		
		End
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Fecha a area de trabalho da query                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		#IFDEF TOP
			( cAliasACK )->( dbCloseArea() ) 
			DbSelectArea( "ACK" ) 
		#ENDIF 			
	
	Endif
		
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pesquisa a regra para o grupo de clientes para um vendedor             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContinua                                   
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o cliente esta inserido em um grupo de clientes e se o     ³
		//³ vendedor esta preenchido                                               ³	
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		If lGrupoCli .And. !Empty(cCodVen)
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Percorre os grupos para combinacao com os vendedores                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   		For nLoop := 1 To Len( aGruposCli )   
	
				#IFDEF TOP 
				
					cAliasACK := "QUERYACK" 
		
					lQuery  := .T.
		
					cQuery := ""
					cQuery += "SELECT * FROM "  + RetSqlName( "ACK" ) + " ACK " 
					cQuery += "WHERE "	
					cQuery += "ACK_FILIAL='"    + xFilial( "ACK" )    + "' AND " 
					cQuery += "ACK_CODCLI='"    + Space(Len(SA1->A1_COD))  + "' AND " 
					cQuery += "ACK_LOJA='"      + Space(Len(SA1->A1_LOJA)) + "' AND "
					cQuery += "ACK_GRPCLI='"    + aGruposCli[nLoop,1] + "' AND "	
					cQuery += "ACK_CODVEN='"    + cCodVen             + "' AND "
					cQuery += "ACK_GRPVEN='"    + Space(Len(SA3->A3_GRPREP)) + "' AND "
					cQuery += "ACK_DATINI <='"  + cDataBase           + "' AND "
					cQuery += "ACK_DATFIM >='"  + cDataBase           + "' AND "
					cQuery += "ACK.D_E_L_E_T_=' '"  
					
					cQuery := ChangeQuery( cQuery )        
					
					dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasACK, .F., .T. ) 
							       
				#ELSE           
								
					cAliasACK := "ACK" 
				
					ACK->( DbSetOrder( 5 ) ) 
					ACK->( DbSeek( xFilial("ACK") + Space(Len(SA1->A1_COD)) + Space(Len(SA1->A1_LOJA)) + aGruposCli[nLoop,1] + Space(Len(SA3->A3_GRPREP)) + cCodVen ) ) 
									
				#ENDIF 
	   	
				While !( cAliasACK )->( Eof() ) .And. xFilial("ACK") == ( cAliasACK )->ACK_FILIAL .And.;
							( cAliasACK )->ACK_CODCLI  == Space(Len(SA1->A1_COD))   .And.;
							( cAliasACK )->ACK_LOJA    == Space(Len(SA1->A1_LOJA))  .And.;
							( cAliasACK )->ACK_GRPCLI  == aGruposCli[nLoop,1]          .And. ;
							( cAliasACK )->ACK_GRPVEN  == Space(Len(SA3->A3_GRPREP))	.And. ;
							( cAliasACK )->ACK_CODVEN  == cCodVen
										
					If Eval( bCondic ) 							
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Avalia a Verba para o item                                             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lContinua  := .F.					
						lUltResult := .T.						
						cResult    := ( cAliasACK )->ACK_CODVER						
						If FtVerbaIt( cAliasSC5,cAliasSC6,( cAliasACK )->ACK_CODVER, cProduto, aProdDesc, lBaixa, @cVerbaBlq, @cItemBlq)
							cRet := '1' //-- Possui Itens da Verba
						Else          
							cRet := '2' //-- Nao Possui Itens da Verba				
						EndIf						
					EndIf
						
					If !lContinua
						Exit 
					EndIf 								
	
					( cAliasACK )->( DbSkip() )	
				  
				End	         
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Fecha a area de trabalho da query                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				#IFDEF TOP
					( cAliasACK )->( dbCloseArea() ) 
					DbSelectArea( "ACK" ) 
				#ENDIF 			
				
				If !lContinua 
					Exit
				EndIf 	
	
			Next nLoop 
	
		EndIf 
		
	EndIf 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pesquisa a verba para um cliente e um grupo de vendedores              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If lContinua                                   
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o cliente esta inserido em um grupo de clientes            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lGrupoVen
	
	   		For nLoop := 1 To Len( aGruposVen )   
	
				#IFDEF TOP 
				
					cAliasACK := "QUERYACK" 
		
					lQuery  := .T.
		
					cQuery := ""
					cQuery += "SELECT * FROM "  + RetSqlName( "ACK" ) + " ACK " 
					cQuery += "WHERE "	
					cQuery += "ACK_FILIAL='"    + xFilial( "ACK" )    + "' AND " 
					cQuery += "ACK_CODCLI='"    + cCliente  + "' AND " 
					cQuery += "ACK_LOJA='"      + cLoja     + "' AND "
					cQuery += "ACK_GRPCLI='"    + Space(Len(SA1->A1_GRPVEN)) + "' AND "	
					cQuery += "ACK_CODVEN='"    + Space(Len(SA3->A3_COD))    + "' AND "
					cQuery += "ACK_GRPVEN='"    + aGruposVen[nLoop,1]    + "' AND "
					cQuery += "ACK_DATINI <='"  + cDataBase           + "' AND "
					cQuery += "ACK_DATFIM >='"  + cDataBase           + "' AND "
					cQuery += "ACK.D_E_L_E_T_=' '"  
					
					cQuery := ChangeQuery( cQuery )        
					
					dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasACK, .F., .T. ) 
							       
				#ELSE           
								
					cAliasACK := "ACK" 
				
					ACK->( DbSetOrder( 5 ) ) 
					ACK->( DbSeek( xFilial("ACK") + cCliente + cLoja + Space(Len(SA1->A1_GRPVEN)) + aGruposVen[nLoop,1]  + cCodVen ) ) 
									
				#ENDIF 
	   	
				While !( cAliasACK )->( Eof() ) .And. xFilial("ACK") == ( cAliasACK )->ACK_FILIAL .And.;
							( cAliasACK )->ACK_CODCLI  == cCliente                   .And.;
							( cAliasACK )->ACK_LOJA    == cLoja                      .And.;
							( cAliasACK )->ACK_GRPCLI  == Space(Len(SA1->A1_GRPVEN)) .And. ;
							( cAliasACK )->ACK_GRPVEN  == aGruposVen[nLoop,1]           .And. ;
							( cAliasACK )->ACK_CODVEN  == Space(Len(SA3->A3_COD))
										
					If Eval( bCondic ) 							
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Avalia a Verba para o item                                             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lContinua  := .F.					
						lUltResult := .T.						
						cResult    := ( cAliasACK )->ACK_CODVER						
						If FtVerbaIt( cAliasSC5,cAliasSC6,( cAliasACK )->ACK_CODVER, cProduto, aProdDesc, lBaixa, @cVerbaBlq, @cItemBlq)
							cRet := '1' //-- Possui Itens da Verba
						Else          
							cRet := '2' //-- Nao Possui Itens da Verba				
			         EndIf
					EndIf
						
					If !lContinua
						Exit 
					EndIf 								
	
					( cAliasACK )->( DbSkip() )	
				  
				End	         
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Fecha a area de trabalho da query                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				#IFDEF TOP
					( cAliasACK )->( dbCloseArea() ) 
					DbSelectArea( "ACK" ) 
				#ENDIF 			
	
				If !lContinua 
					Exit
				EndIf 	
	
			Next nLoop 
	
		EndIf 
		
	EndIf 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o grupos de vendedores com grupos de clientes              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContinua                                   
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o cliente esta inserido em um grupo de clientes            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lGrupoVen .And. lGrupoCli
	
	   		For nLoop := 1 To Len( aGruposCli )   
	   		
	   			For nLoop2 := 1 to Len(aGruposVen)
	
					#IFDEF TOP 
				
						cAliasACK := "QUERYACK" 
		    	
						lQuery  := .T.
		
						cQuery := ""
						cQuery += "SELECT * FROM "  + RetSqlName( "ACK" ) + " ACK " 
						cQuery += "WHERE "	
						cQuery += "ACK_FILIAL='"    + xFilial( "ACK" )    + "' AND " 
						cQuery += "ACK_CODCLI='"    + Space(Len(SA1->A1_COD))+ "' AND " 
						cQuery += "ACK_LOJA='"      + Space(Len(SA1->A1_LOJA))  + "' AND "
						cQuery += "ACK_GRPCLI='"    + aGruposCli[nLoop,1]       + "' AND "	
						cQuery += "ACK_CODVEN='"    + Space(Len(SA3->A3_COD))    + "' AND "
						cQuery += "ACK_GRPVEN='"    + aGruposVen[nLoop2,1]    + "' AND "
						cQuery += "ACK_DATINI <='"  + cDataBase           + "' AND "
						cQuery += "ACK_DATFIM >='"  + cDataBase           + "' AND "
						cQuery += "ACK.D_E_L_E_T_=' '"  
					
						cQuery := ChangeQuery( cQuery )        
					
						dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasACK, .F., .T. ) 
								       
					#ELSE           
								
						cAliasACK := "ACK" 
				
						ACK->( DbSetOrder( 5 ) ) 
						ACK->( DbSeek( xFilial("ACK") + Space(Len(SA1->A1_COD)) + Space(Len(SA1->A1_LOJA)) + aGruposCli[nLoop,1] + aGruposVen[nLoop2,1]  + cCodVen ) ) 
									
					#ENDIF 
	   	
					While !( cAliasACK )->( Eof() ) .And. xFilial("ACK") == ( cAliasACK )->ACK_FILIAL .And.;
							( cAliasACK )->ACK_CODCLI  == Space(Len(SA1->A1_COD)) .And.;
							( cAliasACK )->ACK_LOJA    == Space(Len(SA1->A1_LOJA))   .And.;
							( cAliasACK )->ACK_GRPCLI  == aGruposCli[nLoop,1]         .And. ;
							( cAliasACK )->ACK_GRPVEN  == aGruposVen[nLoop2,1]        .And. ;
							( cAliasACK )->ACK_CODVEN  == Space(Len(SA3->A3_COD))
											
						If Eval( bCondic ) 							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Avalia a Verba para o item                                             ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							lContinua  := .F.						
							lUltResult := .T.							
							cResult    := ( cAliasACK )->ACK_CODVER							
							If FtVerbaIt( cAliasSC5,cAliasSC6,( cAliasACK )->ACK_CODVER, cProduto, aProdDesc, lBaixa, @cVerbaBlq, @cItemBlq)
								cRet := '1' //-- Possui Itens da Verba
							Else          
								cRet := '2' //-- Nao Possui Itens da Verba				
							EndIf											
						EndIf 
						
						If !lContinua
							Exit 
						EndIf 								
	
						( cAliasACK )->( DbSkip() )	
				  
					End	         
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Fecha a area de trabalho da query                                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					#IFDEF TOP
						( cAliasACK )->( dbCloseArea() ) 
						DbSelectArea( "ACK" ) 
					#ENDIF 			
	
					If !lContinua 
						Exit
					EndIf 	
		
	            
				Next nLoop2
	
			Next nLoop 
	
		EndIf 
		
	EndIf 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o existe verba para o cliente e todos os vendedores        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If lContinua
	
		#IFDEF TOP 
		
			cAliasACK := "QUERYACK" 
			
			lQuery  := .T.
			
			cQuery := ""
			cQuery += "SELECT * FROM "  + RetSqlName( "ACK" ) + " ACK " 
			cQuery += "WHERE "	
			cQuery += "ACK_FILIAL='"    + xFilial( "ACK" )    + "' AND " 
			cQuery += "ACK_CODCLI='"    + cCliente            + "' AND " 
			cQuery += "ACK_LOJA='"      + cLoja               + "' AND "
			cQuery += "ACK_GRPCLI='"    + Space(Len(SA1->A1_GRPVEN)) + "' AND "	
			cQuery += "ACK_CODVEN='"    + Space(Len(SA3->A3_COD))    + "' AND "
			cQuery += "ACK_GRPVEN='"    + Space(Len(SA3->A3_GRPREP)) + "' AND "
			cQuery += "ACK_DATINI <='"  + cDataBase           + "' AND "
			cQuery += "ACK_DATFIM >='"  + cDataBase           + "' AND "
			cQuery += "ACK.D_E_L_E_T_=' '"  
			
			cQuery := ChangeQuery( cQuery )        
			
			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasACK, .F., .T. ) 
		       
		#ELSE           
			
			cAliasACK := "ACK" 
		
			ACK->( DbSetOrder( 5 ) ) 
			ACK->( DbSeek( xFilial("ACK") + cCliente + cLoja + Space(Len(SA1->A1_GRPVEN)) + Space(Len(SA3->A3_GRPREP)) + Space(Len(SA3->A3_COD)) ) ) 
			
		#ENDIF 
		
		While !( cAliasACK )->( Eof() ) .And. xFilial("ACK") == ( cAliasACK )->ACK_FILIAL .And.;
					( cAliasACK )->ACK_CODCLI  == cCliente .And.;
					( cAliasACK )->ACK_LOJA    == cLoja    .And.;
					( cAliasACK )->ACK_GRPCLI  == Space(Len(SA1->A1_GRPVEN))  .And. ;
					( cAliasACK )->ACK_GRPVEN  == Space(Len(SA3->A3_GRPREP)) .And. ;
					( cAliasACK )->ACK_CODVEN  == Space(Len(SA3->A3_COD))
			
			If Eval( bCondic ) 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Avalia a regra para o item                                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                           
				lContinua  := .F.      
				lUltResult := .T.				
				cResult    := ( cAliasACK )->ACK_CODVER				
				If FtVerbaIt( cAliasSC5,cAliasSC6,( cAliasACK )->ACK_CODVER, cProduto, aProdDesc, lBaixa, @cVerbaBlq, @cItemBlq)
					cRet := '1' //-- Possui Itens da Verba
				Else          
					cRet := '2' //-- Nao Possui Itens da Verba				
				EndIf
			EndIf	
				
			If !lContinua
				Exit 
			EndIf 								
							
			( cAliasACK )->( DbSkip() ) 			
			
		End
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Fecha a area de trabalho da query                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		#IFDEF TOP
			( cAliasACK )->( dbCloseArea() ) 
			DbSelectArea( "ACK" ) 
		#ENDIF 			
		
	Endif
	                 	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o existe verba para o grupo do cliente e todos os vendedores  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If lContinua
	
		If lGrupoCli
	
			For nLoop := 1 to Len(aGruposCli)
		
				#IFDEF TOP 
		
					cAliasACK := "QUERYACK" 
				
					lQuery  := .T.
			
					cQuery := ""
					cQuery += "SELECT * FROM "  + RetSqlName( "ACK" ) + " ACK " 
					cQuery += "WHERE "	
					cQuery += "ACK_FILIAL='"    + xFilial( "ACK" )    + "' AND " 
					cQuery += "ACK_CODCLI='"    + Space(Len(SA1->A1_COD))    + "' AND " 
					cQuery += "ACK_LOJA='"      + Space(Len(SA1->A1_LOJA))   + "' AND "
					cQuery += "ACK_GRPCLI='"    + aGruposCli[nLoop,1]         + "' AND "	
					cQuery += "ACK_CODVEN='"    + Space(Len(SA3->A3_COD))    + "' AND "
					cQuery += "ACK_GRPVEN='"    + Space(Len(SA3->A3_GRPREP)) + "' AND "
					cQuery += "ACK_DATINI <='"  + cDataBase                   + "' AND "
					cQuery += "ACK_DATFIM >='"  + cDataBase                   + "' AND "
					cQuery += "ACK.D_E_L_E_T_=' '"  
			
					cQuery := ChangeQuery( cQuery )        
			
					dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasACK, .F., .T. ) 
		       
				#ELSE           
			
					cAliasACK := "ACK" 
		    	
					ACK->( DbSetOrder( 5 ) ) 
					ACK->( DbSeek( xFilial("ACK") + Space(Len(SA1->A1_COD)) + Space(Len(SA1->A1_LOJA)) + aGruposCli[nLoop,1] + Space(Len(SA3->A3_GRPREP)) + Space(Len(SA3->A3_COD)) ) ) 
			
				#ENDIF 
		
				While !( cAliasACK )->( Eof() ) .And. xFilial("ACK") == ( cAliasACK )->ACK_FILIAL .And.;
					( cAliasACK )->ACK_CODCLI  == Space(Len(SA1->A1_COD))    .And.;
					( cAliasACK )->ACK_LOJA    == Space(Len(SA1->A1_LOJA))   .And.;
					( cAliasACK )->ACK_GRPCLI  == aGruposCli[nLoop,1]        .And. ;
					( cAliasACK )->ACK_GRPVEN  == Space(Len(SA3->A3_GRPREP)) .And. ;
					( cAliasACK )->ACK_CODVEN  == Space(Len(SA3->A3_COD))
			
					If Eval( bCondic ) 
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Avalia a regra para o item                                             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                           
						lContinua  := .F.
						lUltResult := .T.			   
						cResult    := ( cAliasACK )->ACK_CODVER									
                  If FtVerbaIt( cAliasSC5,cAliasSC6,( cAliasACK )->ACK_CODVER, cProduto, aProdDesc, lBaixa, @cVerbaBlq, @cItemBlq)
        					cRet := '1' //-- Possui Itens da Verba
						Else          
							cRet := '2' //-- Nao Possui Itens da Verba				
						EndIf
				   EndIf   
				
					If !lContinua
						Exit 
					EndIf 								
							
					( cAliasACK )->( DbSkip() ) 			
			
				End
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Fecha a area de trabalho da query                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				#IFDEF TOP
					( cAliasACK )->( dbCloseArea() ) 
					DbSelectArea( "ACK" ) 
				#ENDIF 			
		    Next nLoop
		    
		Endif	    
		
	Endif
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o existe verba para o vendedor e todos os clientes         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If lContinua
	
		If !Empty(cCodVen)
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o existe verba para o vendedor e o cliente                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
			#IFDEF TOP 
		
				cAliasACK := "QUERYACK" 
			
				lQuery  := .T.
			
				cQuery := ""
				cQuery += "SELECT * FROM "  + RetSqlName( "ACK" ) + " ACK " 
				cQuery += "WHERE "	
				cQuery += "ACK_FILIAL='"    + xFilial( "ACK" )    + "' AND " 
				cQuery += "ACK_CODCLI='"    + Space(Len(SA1->A1_COD))    + "' AND " 
				cQuery += "ACK_LOJA='"      + Space(Len(SA1->A1_LOJA))   + "' AND "
				cQuery += "ACK_GRPCLI='"    + Space(Len(SA1->A1_GRPVEN)) + "' AND "	
				cQuery += "ACK_CODVEN='"    + cCodVen                     + "' AND "
				cQuery += "ACK_GRPVEN='"    + Space(Len(SA3->A3_GRPREP)) + "' AND "
				cQuery += "ACK_DATINI <='"  + cDataBase           + "' AND "
				cQuery += "ACK_DATFIM >='"  + cDataBase           + "' AND "
				cQuery += "ACK.D_E_L_E_T_=' '"  
			
				cQuery := ChangeQuery( cQuery )        
			
				dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasACK, .F., .T. ) 
		       
			#ELSE           
			
				cAliasACK := "ACK" 
		
				ACK->( DbSetOrder( 5 ) ) 
				ACK->( DbSeek( xFilial("ACK") + Space(Len(SA1->A1_COD)) + Space(Len(SA1->A1_LOJA)) + Space(Len(SA1->A1_GRPVEN)) + Space(Len(SA3->A3_GRPREP)) + cCodVen ) ) 
			
			#ENDIF 
		
			While !( cAliasACK )->( Eof() ) .And. xFilial("ACK") == ( cAliasACK )->ACK_FILIAL .And.;
						( cAliasACK )->ACK_CODCLI  == Space(Len(SA1->A1_COD)) .And.;
						( cAliasACK )->ACK_LOJA    == Space(Len(SA1->A1_LOJA))    .And.;
						( cAliasACK )->ACK_GRPCLI  == Space(Len(SA1->A1_GRPVEN))  .And. ;
						( cAliasACK )->ACK_GRPVEN  == Space(Len(SA3->A3_GRPREP)) .And. ;
						( cAliasACK )->ACK_CODVEN  == cCodVen
			
				If Eval( bCondic ) 
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Avalia a regra para o item                                             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                           
					lContinua  := .F.
					lUltResult := .T.
					cResult    := ( cAliasACK )->ACK_CODVER					
					If FtVerbaIt( cAliasSC5,cAliasSC6,( cAliasACK )->ACK_CODVER, cProduto, aProdDesc, lBaixa, @cVerbaBlq, @cItemBlq)
						cRet := '1' //-- Possui Itens da Verba
					Else          
						cRet := '2' //-- Nao Possui Itens da Verba				
					EndIf
				EndIf	
									
				If !lContinua
					Exit 
				EndIf 								
							
				( cAliasACK )->( DbSkip() ) 			
			
			End
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Fecha a area de trabalho da query                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			#IFDEF TOP
				( cAliasACK )->( dbCloseArea() ) 
				DbSelectArea( "ACK" ) 
			#ENDIF 			
			
		Endif	
		
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o existe verba somente para o grupo de vendedores          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If lContinua
	
		If lGrupoVen
	
			For nLoop := 1 to Len(aGruposVen)
		
				#IFDEF TOP 
		
					cAliasACK := "QUERYACK" 
				
					lQuery  := .T.
			
					cQuery := ""
					cQuery += "SELECT * FROM "  + RetSqlName( "ACK" ) + " ACK " 
					cQuery += "WHERE "	
					cQuery += "ACK_FILIAL='"    + xFilial( "ACK" )    + "' AND " 
					cQuery += "ACK_CODCLI='"    + Space(Len(SA1->A1_COD))    + "' AND " 
					cQuery += "ACK_LOJA='"      + Space(Len(SA1->A1_LOJA))   + "' AND "
					cQuery += "ACK_GRPCLI='"    + Space(Len(SA1->A1_GRPVEN))         + "' AND "	
					cQuery += "ACK_CODVEN='"    + Space(Len(SA3->A3_COD))    + "' AND "
					cQuery += "ACK_GRPVEN='"    + aGruposVen[nLoop,1] + "' AND "
					cQuery += "ACK_DATINI <='"  + cDataBase                   + "' AND "
					cQuery += "ACK_DATFIM >='"  + cDataBase                   + "' AND "
					cQuery += "ACK.D_E_L_E_T_=' '"  
			
					cQuery := ChangeQuery( cQuery )        
			
					dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasACK, .F., .T. ) 
		       
				#ELSE           
			
					cAliasACK := "ACK" 
		    	
					ACK->( DbSetOrder( 5 ) ) 
					ACK->( DbSeek( xFilial("ACK") + Space(Len(SA1->A1_COD)) + Space(Len(SA1->A1_LOJA)) + Space(Len(SA1->A1_GRPVEN)) + aGruposVen[nLoop,1] + Space(Len(SA3->A3_COD)) ) ) 
			
				#ENDIF 
		
				While !( cAliasACK )->( Eof() ) .And. xFilial("ACK") == ( cAliasACK )->ACK_FILIAL .And.;
					( cAliasACK )->ACK_CODCLI  == Space(Len(SA1->A1_COD))    .And.;
					( cAliasACK )->ACK_LOJA    == Space(Len(SA1->A1_LOJA))   .And.;
					( cAliasACK )->ACK_GRPCLI  == Space(Len(SA1->A1_GRPVEN)) .And. ;
					( cAliasACK )->ACK_GRPVEN  == aGruposVen[nLoop,1] .And. ;
					( cAliasACK )->ACK_CODVEN  == Space(Len(SA3->A3_COD))
			
					If Eval( bCondic ) 
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Avalia a regra para o item                                             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                           
						lContinua  := .F.
						lUltResult := .T.
						cResult    := ( cAliasACK )->ACK_CODVER						
						If FtVerbaIt( cAliasSC5,cAliasSC6,( cAliasACK )->ACK_CODVER, cProduto, aProdDesc, lBaixa, @cVerbaBlq, @cItemBlq)
							cRet := '1' //-- Possui Itens da Verba
						Else          
							cRet := '2' //-- Nao Possui Itens da Verba				
						EndIf
					EndIf	
									
					If !lContinua
						Exit 
					EndIf 								
							
					( cAliasACK )->( DbSkip() ) 			
			
				End
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Fecha a area de trabalho da query                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				#IFDEF TOP
					( cAliasACK )->( dbCloseArea() ) 
					DbSelectArea( "ACK" ) 
				#ENDIF 			
				
		    Next nLoop
		    
		Endif	    
		
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Guarda os ultimos resultados                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUltResult .And. cRet == "2"
		aadd(aUltResult,{cCliente,cLoja,cCodVen,cResult,cRet,cVerbaBlq,cItemBlq})
		If Len(aUltResult) > MAXSAVERESULT
			aUltResult := aDel(aUltResult,1)
			aUltResult := aSize(aUltResult,MAXSAVERESULT)
		EndIf
	EndIf
	
Else
	cVerbaBlq  := aUltResult[ nScan, 6 ]  //codigo da verba que fez o bloqueio
	cItemBlq   := aUltResult[ nScan, 7 ]  //item da verba que bloqueou o lancamento
	cRet       := aUltResult[ nScan, 5 ]
Endif	
	
RestArea(aAreaACK)
RestArea(aArea)

Return(cRet)                                                                   


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FtVerbaIt ³ Autor ³Henry Fila             ³ Data ³14.02.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de avaliacao dos itens da verba                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do SC5                                         ³±±
±±³          ³ExpC2: Alias do SC6                                         ³±±
±±³          ³ExpC3: Codigo da Verba                                      ³±±
±±³          ³ExpC4: Codigo do produto                                    ³±±
±±³          ³ExpA5: Array com os dados para a analise                    ³±±
±±³          ³ExpL6: Indice se a baixa sera realizada                     ³±±
±±³          ³ExpL7: Indice se zera caso saldo menor que desconto         ³±±
±±³          ³ExpL7: Verba que bloqueou o lancamento                      ³±±
±±³          ³ExpL8: Item que bloqueou o lancamento                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Verba de Vendas                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo avaliar a verba de vendas     ³±±
±±³          ³conforme os parametros da rotina                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FtVerbaIt(	cAliasSC5,	cAliasSC6,	cCodVer,	cProduto,;
							aProdDesc, 	lBaixa, cVerbaBlq, cItemBlq)

Local nSaldo     := 0           
Local nVlrDesc   := 0
Local nVlrRegra  := 0
Local nSaldoCon  := 0
Local nDescPed   := aProdDesc[5]   //Desconto do pedido
Local nDescReg   := aProdDesc[6]   //Desconto permitido pela regra

Local lRet       := .F.
Local lSomaVer   := (SuperGetMv("MV_SOMAVER",.F.,"S") =="S")   
Local nFatorSoma := SuperGetMv("MV_FTRSOMA",.F.,100)



ACL->(DbSetOrder(2))
If !ACL->(DbSeek(xFilial("ACL")+cProduto+cCodVer))         
	ACL->(DbSeek(xFilial("ACL")+Space(Len(SB1->B1_COD))+cCodVer))	
Endif

//busca o item do pedido 
DbSelectArea(cAliasSC6)
(cAliasSC6)->(DbSetOrder(1))
(cAliasSC6)->(DbSeek(xFilial(cAliasSC6)+ (cAliasSC5)->C5_NUM + aProdDesc[2] + aProdDesc[1] ))


If ACL->(Found())

	nSaldo   := ACL->ACL_SALDO

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o ocorrido foi desconto                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Do Case

	Case (aProdDesc[3] < aProdDesc[4]) .Or. !lSomaVer

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcula o valor total do desconto do item no pedido de venda³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nVlrDesc := ((cAliasSC6)->C6_QTDVEN * (cAliasSC6)->C6_PRUNIT) * (nDescPed /100)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcula o valor total do desconto do item no pedido de venda³
		//³com o % permitido pela regra                                ³	
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nDescReg > 0
			nVlrRegra := ((cAliasSC6)->C6_QTDVEN * (cAliasSC6)->C6_PRUNIT) * (nDescReg /100)
		Else
			nVlrRegra := nVlrDesc
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso tenha vendido com preco maior verifica parametro se o  ³
		//³valor ira somar na verba existente                          ³	
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nSaldoCon := nVlrDesc - nVlrRegra
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o desconto concedido e maior que o saldo da     ³
		//³verba de venda                                              ³	
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		lRet     := (ACL->ACL_SALDO >= nSaldoCon)
		If !lRet 
			nSaldoCon := ACL->ACL_SALDO
			cItemBlq  := ACL->ACL_ITEM //item que bloqueou o lancamento
		Endif	

		aProdDesc[8] := nSaldoCon		

		If lBaixa .And. ACL->ACL_SALDO > 0 .And. nSaldoCon	> 0
			RecLock("ACL",.F.)
				ACL->ACL_SALDO -= nSaldoCon
			MsUnlock()	                                                                                 
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava tabela de movimentacoes com os dados da baixa         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("ACM")
			RecLock("ACM",.T.)
				ACM->ACM_FILIAL := xFilial("ACM")
				ACM->ACM_CODVER := cCodVer
				ACM->ACM_NUMPED := (cAliasSC5)->C5_NUM
				ACM->ACM_ITEPED := (cAliasSC6)->C6_ITEM
				ACM->ACM_DATA   := dDataBase
				ACM->ACM_VALOR  := nSaldoCon
				ACM->ACM_OPERA  := "D"
			MsUnlock()			
			
		Endif	
		
	Case (aProdDesc[3] > aProdDesc[4]) .And. lSomaVer
		lRet      := .T.

		nSaldoCon := ((cAliasSC6)->C6_QTDVEN * (cAliasSC6)->C6_PRCVEN) - ((cAliasSC6)->C6_QTDVEN * (cAliasSC6)->C6_PRUNIT) 
		nSaldoCon := nSaldoCon * (nFatorSoma/100)

		aProdDesc[8] := nSaldoCon

		If lBaixa .And. nSaldoCon > 0 
			RecLock("ACL",.F.)
				ACL->ACL_SALDO += nSaldoCon
			MsUnlock()	

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava tabela de movimentacoes com os dados da baixa         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("ACM",.T.)
				ACM->ACM_FILIAL := xFilial("ACM")
				ACM->ACM_CODVER := cCodVer
				ACM->ACM_NUMPED := (cAliasSC5)->C5_NUM
				ACM->ACM_ITEPED := (cAliasSC6)->C6_ITEM
				ACM->ACM_DATA   := dDataBase
				ACM->ACM_VALOR  := nSaldoCon
				ACM->ACM_OPERA  := "C"
			MsUnlock()			
			
		Endif	
		
	Case (aProdDesc[3] == aProdDesc[4]) 
		lRet := .T.
	EndCase
	
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se bloquear por verba guarda qual verba foi                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lRet
	cVerbaBlq := cCodVer
EndIf
	


Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ft190Candel³ Autor ³Henry Fila            ³ Data ³14.02.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se ja existe moviemtacao paraa a verba             ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo da verba                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: .T. ou .F.                                           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo verificar se ja houve movimen ³±±
±±³          ³tacao para a verba caso seja exclusao                       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ft190CanDel(cCodVerba)

Local lRet := .T.

DbSelectArea("ACM")
ACM->(DbSetOrder(1))
If ACM->(DbSeek(xFilial("ACM")+cCodVerba))
	Help(" ",1,"NODELETA")
	lRet := .F.
Endif		
     
Return(lRet)

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
     
aRotina		:= {	{ STR0002,"AxPesqui"	,0	,1	,0	,.F.	}	,;	//"Pesquisar" 
					{ STR0003,"Fat190Mnt"	,0	,2	,0	,NIL	}	,;	//"Visualizar"
					{ STR0004,"Fat190Mnt"	,0	,3	,0	,NIL	}	,;	//"Incluir" 
					{ STR0005,"Fat190Mnt"	,0	,4	,0	,NIL	}	,;	//"Alterar" 
					{ STR0006,"Fat190Mnt"	,0	,5	,0	,NIL	}	,;	//"Excluir"
					{ STR0007,"Fat190Leg"	,0	,4	,0	,.F.	}	}		//"Legenda"

If ExistBlock("FT190MNU")
	ExecBlock("FT190MNU",.F.,.F.)
EndIf

Return(aRotina)

/*/{Protheus.doc} FAT190DVerb

limpa o conteudo da variavel static aUltResult

@author Reynaldo Tetsu Miyashita

@since 28/04/2014

@version P11

@param nenhum 

@return Logico, Verdadeiro

/*/
Function FAT190DVerb()
	aUltResult := Nil
Return .T.
