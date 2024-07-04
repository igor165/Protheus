#INCLUDE "plsa980.ch"
#include "PLSMGER.CH"
#include "PROTHEUS.CH"
#include "COLORS.CH"
#include "TCBROWSE.CH"
#include "JPEG.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA980 ³ Autor ³ Tulio Cesar          ³ Data ³ 03.05.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Relacao Operador X Operadora                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA980

PRIVATE aRotina   := MenuDef()
PRIVATE cCadastro := Fundesc()
PRIVATE cAlias    := "BX4"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama funcao de Browse...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BX4->(DbSetOrder(1))
BX4->(mBrowse(ndLinIni,ndColIni,ndLinFin,ndColFin,cAlias))
PLSCLSOP()
PLSINICIA()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA980MOV ³ Autor ³ Tulio Cesar       ³ Data ³ 13.07.1999 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Movimentacao Operador X Operadora                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PLSA980()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Padrao do mBrowse                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                   
Function PLSA980MOV(cAlias,nReg,nOpc)
LOCAL I__f := 0
LOCAL aChave
LOCAL nI
LOCAL cCodInt                            
LOCAL cCodOpe
LOCAL oDlg                    
LOCAL oFolder                          
LOCAL oEnchoice                    
LOCAL cCadastro
LOCAL aHeader                                             
LOCAL aCols
LOCAL aHeaderR := {}	//aHeader das regioes
LOCAL aColsR	:= {}//aCols das regioes
LOCAL aVetTrabR:= {} //vetor de trabalho para regioes
LOCAL aVetTrab
LOCAL aCabBXR
LOCAL aColsBXR            
LOCAL aVetBXR := {}
LOCAL nOpca 	 := 0
LOCAL aMatBX5 	 := {}
LOCAL aMatBY8	 := {}
LOCAL aMatBY8D	 := {}
LOCAL lMarkB	 := .T.
Local oGetBXR
Local nCnt
LOCAL aPosObj   := {}
LOCAL aObjects  := {}
LOCAL aSize     := {}
LOCAL aInfo     := {}
LOCAL cDeci	  := .F.
LOCAL nPosCodReg:= 0
LOCAL aCabB6P
LOCAL aColsB6P            
LOCAL aVetB6P := {}

local nx := 0
Local nUsado    := 0

PRIVATE bOK      := {|| nOpca := 1,Iif(Obrigatorio(aGets,aTela) .AND. PLSA980VLC(nOpca), oDlg:End(),nOpca:=2),Iif(nOpca==1,oDlg:End(),.F.) }
PRIVATE bCancel  := {||oDlg:End()}
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE aButtons := {}
PRIVATE lMarkReg  := .T.

PRIVATE oLista
PRIVATE oCheck
PRIVATE lCheck  := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega tabela de Operadores X Instituicoes								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Incluir
	Copy "BX4" TO Memory Blank
Else
	Copy "BX4" TO Memory
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a exclusao do operador e das criticas (bx5)							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Excluir
	nOpca := BX4->(AxDeleta(cAlias,nReg,nOpc))
	If nOpca == 2
		DeletaBX5(M->BX4_CODOPE,M->BX4_CODINT)
		DeletaBY8(M->BX4_CODOPE,M->BX4_CODINT)
	EndIf
	Return
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega tabela de Motivos de Glosas										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BCT" TO aHeader For SX3->X3_CAMPO $ "BCT_PROPRI,BCT_CODGLO,BCT_DESCRI"
BCT->( DbGoTop() )
BCT->( DbSetOrder(1) )
BCT->( DbSeek(xFilial("BCT")+M->(BX4_CODINT)) )
Store COLS "BCT" TO aCols From aHeader VETTRAB aVetTrab While BCT->(BCT_FILIAL+BCT_CODOPE) == M->(BX4_FILIAL+BX4_CODINT) .And. BCT->BCT_PROPRI $ "0,5"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se a operadora tiver motivos de critica (bct)							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aCols) == 0 
   lMarkB := .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrena na matriz os dados do operador e operadora gravados no BX5		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMarkB
	If nOpc <> K_Incluir
		BX5->( DbSetOrder(1) )	//BX5_FILIAL + BX5_CODOPE + BX5_CODINT + BX5_PROPRO + BX5_CODGLO
		If BX5->( MsSeek( xFilial("BX5")+M->BX4_CODOPE+M->BX4_CODINT ) )
		   While !BX5->( Eof() ) .and. BX5->(BX5_FILIAL+BX5_CODOPE+BX5_CODINT) == xFilial("BX5")+M->BX4_CODOPE+M->BX4_CODINT
		       AaDd( aMatBX5,{BX5->BX5_PROPRI,BX5->BX5_CODGLO} )
			   nPos := Ascan( aCols, {|x| x[1] == BX5->BX5_PROPRI .and. x[2] == BX5->BX5_CODGLO} )
			   If nPos <> 0 
			      aCols[nPos,Len( aCols[nPos] )] := .T.
			   EndIf
		       BX5->( DbSkip() ) 
		   EndDo
		EndIf             
	EndIf           
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Trocar o conteudo do campo de acordo com o cbox do sx3					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 To Len(aCols)
		aCols[nI,1] := alltrim(X3COMBO("BCT_PROPRI",aCols[nI,1]))
	Next	
	For nI := 1 To Len(aMatBX5)
		aMatBX5[nI,1] := alltrim(X3COMBO("BCT_PROPRI",aMatBX5[nI,1]))
	Next	               
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a GetDados do Folder Usuarios                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BXR" TO aCabBXR For .t.

If nOpc == K_Incluir
	Store COLS Blank "BXR" TO aColsBXR FROM aCabBXR
Else
	BXR->(DbSetOrder(1))
	If ! BXR->(MsSeek(xFilial("BXR")+BX4->BX4_CODOPE+BX4->BX4_CODINT))
		Store COLS Blank "BXR" TO aColsBXR FROM aCabBXR
	Else
		Store COLS "BXR" TO aColsBXR FROM aCabBXR VETTRAB aVetBXR While xFilial("BXR")+BX4->BX4_CODOPE+BX4->BX4_CODINT == BXR->(BXR_FILIAL+BXR_CODOPE+BXR_CODINT)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a GetDados do Folder Departamentos                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if PlsAliasExi("B6P")
	Store Header "B6P" TO aCabB6P For .t.

	If nOpc == K_Incluir
		Store COLS Blank "B6P" TO aColsB6P FROM aCabB6P
	Else	
		B6P->(DbSetOrder(1))
		If ! B6P->(MsSeek(xFilial("B6P")+BX4->BX4_CODOPE+BX4->BX4_CODINT))
			Store COLS Blank "B6P" TO aColsB6P FROM aCabB6P
		Else
			Store COLS "B6P" TO aColsB6P FROM aCabB6P VETTRAB aVetB6P While xFilial("B6P")+BX4->BX4_CODOPE+BX4->BX4_CODINT == B6P->(B6P_FILIAL+B6P_CODOPE+B6P_CODINT)
		Endif
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define tela com os folders												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
aObjects := {}
AAdd( aObjects, { 100, 0, .t., .f. } )
AAdd( aObjects, { 100, 100, .t., .t., .t. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

If nOpc <> K_Incluir
	BY8->( DbSetOrder(1) )	//BY8_FILIAL+BY8_CODINT+BY8_CODOPE+BY8_CODREG
	If BY8->( MsSeek( xFilial("BY8")+BX4->BX4_CODINT+BX4->BX4_CODOPE) )
		While !BY8->( Eof() ) .and. BY8->(BY8_FILIAL+BY8_CODINT+BY8_CODOPE) == xFilial("BY8")+BX4->(BX4_CODINT+BX4_CODOPE)
			AADD(aMatBY8,{xFilial("BY8"), BX4->BX4_CODINT, BX4->BX4_CODOPE, BY8->BY8_CODREG})
			BY8->( DbSkip() )
		End
	EndIf
EndIf

aadd(aButtons,{"S4WB009N",{ || MontaBIB(aMatBY8,aColsR,aHeaderR,aMatBY8D) },"Cadastro de Regiões","Regiões"})

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() PIXEL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folders																	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMarkB
	@ aPosObj[2][1],aPosObj[2][2] FOLDER oFolder SIZE aPosObj[2][3],aPosObj[2][4] OF oDlg PIXEL	PROMPTS STR0007,STR0010,STR0012,STR0008		//"Operador X Instituição","Grupo/Empresa/Contrato","Departamentos","Operador X Instituição X Criticas"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ MarkBrowse do BCT														 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MarkB(aCols,aHeader,2,02,oFolder:aDialogs[4],010,003,aPosObj[2][3]-8,aPosObj[2][4]-26)
Else
	@ aPosObj[2][1],aPosObj[2][2] FOLDER oFolder SIZE aPosObj[2][3],aPosObj[2][4] OF oDlg PIXEL	PROMPTS STR0007,STR0010,STR0012		//"Operador X Instituição","Grupo/Empresa/Contrato","Departamentos"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Enchoice do BX4															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnchoice := BX4->(MsMGet():New(cAlias,nReg,nOpc,,,,,{003,005,aPosObj[2][4]-15,aPosObj[2][3]-5},,,,,,oFolder:aDialogs[1],,,.F.))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Browse dos Opcionais da Familia                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwBXR  := TPLSBrw():New(003,005,aPosObj[2][3]-5,aPosObj[2][4]-15,NIL  ,oFolder:aDialogs[2],nil   , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBXR   ,aColsBXR ,.F.      ,"BXR" ,nOpc,"Grupo/Empresa/Contrato",nil,nil,nil,aVetBXR,,)
if PlsAliasExi("B6P")
	oBrwB6P  := TPLSBrw():New(003,005,aPosObj[2][3]-5,aPosObj[2][4]-15,NIL  ,oFolder:aDialogs[3],nil   , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabB6P   ,aColsB6P ,.F.      ,"B6P" ,nOpc,STR0012,nil,nil,nil,aVetB6P,,)
EndIf

ACTIVATE MSDIALOG oDlg ON INIT Eval( { || EnChoiceBar(oDlg,bOK,bCancel,.F.,aButtons) })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso confirme a operacao...                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == K_OK
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a Gravacao,alteracao ou exclusao									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BX4->( DbGoTo(nReg) )
	BX4->( PLUPTENC("BX4",nOpc) )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravacao do arquivo operadors x inst x criticas							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMarkB
		GravaBX5(aMatBX5,aCols,BX4->BX4_CODOPE,BX4->BX4_CODINT)
	EndIf
	
	aChave := {}
	aadd(aChave,{"BXR_CODOPE",M->BX4_CODOPE})
	aadd(aChave,{"BXR_CODINT",M->BX4_CODINT})
	oBrwBXR:Grava(aChave,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava relacao Operador x Departamentos na tabela B6P                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if PlsAliasExi("B6P")
		aChaveB6P := {}
		aadd(aChaveB6P,{"B6P_CODOPE",M->BX4_CODOPE})
		aadd(aChaveB6P,{"B6P_CODINT",M->BX4_CODINT})
		oBrwB6P:Grava(aChaveB6P,.F.)
	EndIf

	If Altera
		GravaBY8(aMatBY8,aColsR,BX4->BX4_CODOPE,BX4->BX4_CODINT,aMatBY8D)
	ElseIf Inclui
		GravaBY8({},aColsR,BX4->BX4_CODOPE,BX4->BX4_CODINT)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alteracao ou inclusao...                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == K_Incluir .Or. nOpc == K_Alterar
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se foi confirmada como Operadora   padrao...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If BX4->BX4_PADRAO == "1"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se tiver alguma outra como padrao atualizo...                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCodInt := BX4->BX4_CODINT
			cCodOpe := BX4->BX4_CODOPE
			BX4->(DbSetOrder(2))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ RETCODUSR() esta funcao foi retirada pq retorna o codope do usuario corrente³
			//³ caso seja alterado algum registro de usuario diferente do que esta logado a ³
			//³ alteracao vai ser feita no usuario logado tb. 								 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If BX4->(MsSeek(xFilial("BX4")+cCodOpe+"1"))
				While ! BX4->(Eof()) .And. BX4->(BX4_FILIAL+BX4_CODOPE+BX4_PADRAO) == xFilial("BX4")+cCodOpe+"1"
					If BX4->BX4_CODINT <> cCodInt
						BX4->(RecLock("BX4",.F.))
						BX4->BX4_PADRAO := "0"
						BX4->(MsUnLock())
					Endif
					BX4->(DbSkip())
				Enddo
				BX4->( DbGoTo(nReg) )
			Endif
		Endif
		
	Endif
	
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DeletaBX5 ºAutor  ³Alexander           º Data ³  29/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta todos os registros do BX5 se o operador for excluido º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DeletaBX5(cCodOpe,cCodInt)

BX5->( DbSetOrder(1) )
If BX5->( MsSeek( xFilial("BX5")+cCodOpe+cCodInt ) )
	While !BX5->( Eof() ) .and. BX5->(BX5_FILIAL+BX5_CODOPE+BX5_CODINT) == xFilial("BX5")+cCodOpe+cCodInt
		BX5->( RecLock("BX5",.F.) )
		BX5->( DbDelete() )
		BX5->( MsUnlock() )
		BX5->( DbSkip() )
	EndDo
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DeletaBX5 ºAutor  ³Alexander           º Data ³  29/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta todos os registros do BX5 se o operador for excluido º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DeletaBY8(cCodOpe,cCodInt)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclusao do arquivo operador x regioes									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BY8->( DbSetOrder(1) )	//BY8_FILIAL+BY8_CODINT+BY8_CODOPE+BY8_CODREG
If BY8->( MsSeek( xFilial("BY8")+cCodInt+cCodOpe) )
	While !BY8->( Eof() ) .and. BY8->(BY8_FILIAL+BY8_CODINT+BY8_CODOPE) == xFilial("BY8")+cCodInt+cCodOpe
		BY8->( RecLock("BY8",.F.) )
		BY8->( DbDelete() )
		BY8->( MsUnlock() )
		BY8->( DbSkip() )
	EndDo
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GravaBX5  ºAutor  ³Alexander           º Data ³  29/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava todos os registros da matriz acols na tabela BX5	  º±±
±±º		     ³o identificador se gravar ou nao e o ultimo campo	de cada   º±±
±±º		     ³linha da matriz .T. grava .F. exclui						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GravaBX5(aMatBX5,aMatBCL,cCodOpe,cCodInt)
LOCAL nI
LOCAL aGrava  := {}
LOCAL aCbox   := RetSx3Box(X3CBox(Posicione('SX3' , 2 ,"BCT_PROPRI",'X3_CBOX')	),,,1)

If Len(aMatBX5) > 0
	BX5->( DbSetOrder(1) )
	For nI := 1 To Len(aMatBCL)
		nPos := Ascan( aMatBX5, {|x| x[1] == aMatBCL[nI,1] .and. x[2] == aMatBCL[nI,2]} )
		If nPos <> 0 .and. !aMatBCL[nI,Len(aMatBCL[nI])]
			AaDd( aGrava,{cCodOpe,cCodInt,aMatBX5[nPos,1],aMatBX5[nPos,2],"D"} ) //Deleta o registro no BX5
		EndIf
		If nPos == 0 .and. aMatBCL[nI,Len(aMatBCL[nI])]
			AaDd( aGrava,{cCodOpe,cCodInt,aMatBCL[nI,1],aMatBCL[nI,2],"G"} ) //Grava o registro no BX5
		EndIf
	Next
Else
	For nI := 1 To Len(aMatBCL)
		If aMatBCL[nI,Len(aMatBCL[nI])]
			AaDd( aGrava,{cCodOpe,cCodInt,aMatBCL[nI,1],aMatBCL[nI,2],"G"} ) //Grava o registro no BX5
		EndIf
	Next
EndIf
For nI := 1 To Len(aGrava)
	aGrava[nI,3] := aCBox[Ascan( aCBox, {|x| x[3] = aGrava[nI,3]} ),2]
	If aGrava[nI,Len( aGrava[nI] )] == "G"
		BX5->( RecLock( "BX5",.T. ) )
		BX5->BX5_FILIAL := xFilial("BX5")
		BX5->BX5_CODOPE := aGrava[nI,1]
		BX5->BX5_CODINT := aGrava[nI,2]
		BX5->BX5_PROPRI := aGrava[nI,3]
		BX5->BX5_CODGLO := aGrava[nI,4]
	Else
		BX5->( MsSeek(xFilial("BX5")+aGrava[nI,1]+aGrava[nI,2]+aGrava[nI,3]+aGrava[nI,4] ) )
		BX5->( RecLock("BX5",.F.) )
		BX5->( DbDelete() )
	EndIf
	BX5->( MsUnlock() )
Next
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MarkB     ºAutor  ³Alexander           º Data ³  29/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria um markbrowse dinamicamente							  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MarkB(aLinha,aCabecalho,nCheLi,nCheCo,oDlg,nPosLI,nPosCI,nPosCF,nPosLF,lMarkReg)

	Static objCENFUNLGP := CENFUNLGP():New()

LOCAL nFor		:=	0
LOCAL nI		:=	0
LOCAL cQuery 	:= ""
LOCAL aRegioes 	:= {}
LOCAL aArea 	:= GetArea()
Local oLista	:= Nil
Local oCheck	:= Nil
LOCAL bBlock	:= Nil
LOCAL aCampos	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Checkbox para marcar e desmarcar todos														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ nCheLi,nCheCo CHECKBOX oCheck VAR lCheck PROMPT STR0009 OF oDlg SIZE 100,8 //"Marca e Desmarca todos"
oCheck:bChange := {|| MsAguarde( {|| MarcaLinha('',aLinha,lCheck),oLista:Refresh() } ) }
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o TcBrowse																			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oLista := TcBrowse():New( nPosLI,nPosCI,nPosCF,nPosLF,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
aadd(aCampos , .F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona o BitMap de marcado e desmarcado													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
add COLUMN To oLista BitMap Data { || LoadBitMap( GetResources(), Iif(!aLinha[oLista:nAt,Len(aLinha[oLista:nAt])] ,EVal({|| lCheck := .F.,"LBNO"}),"LBOK" ) )} Title "" WIDTH 015 NOHILITE
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega o cabecalho																			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nFor := 1 to Len(aCabecalho)
	bBlock := "{ || aLinha[oLista:nAt, "+Str(nFor,4)+"] }"
	bBlock := &bBlock
	aadd(aCampos , aCabecalho[nFor,2])
	oLista:AddColumn(TcColumn():New(aCabecalho[nFor,1],bBlock,aCabecalho[nFor,3],Nil,Nil,Nil,IiF(Len(aCabecalho[nFor,1]) > aCabecalho[nFor,4],Len(aCabecalho[nFor,1])*3.6,aCabecalho[nFor,4]*3.6),.F.,.F.,Nil,Nil,Nil,.F.,Nil))
Next

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aBls := objCENFUNLGP:getTcBrw(aCampos)

		oLista:aObfuscatedCols := aBls
	endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os dados																			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oLista:SetArray(aLinha)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Duploclick na linha																			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oLista:BLDBLCLICK := { || MarcaLinha(oLista:nAt,aLinha,lCheck) , oLista:Refresh() }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona o BitMap de marcado nas regioes selecionadas para o operador (alterar)	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Inclui
	cQuery := "SELECT BY8.BY8_CODREG CODREG"
	cQuery += " FROM "
	cQuery += RetSqlName("BY8")+ " BY8 "
	cQuery += " WHERE "
	cQuery += "BY8_FILIAL = '"+xFilial("BY8")+"' AND "
	cQuery += "BY8_CODINT = '"+M->BX4_CODINT+"' AND "
	cQuery += "BY8_CODOPE = '"+M->BX4_CODOPE+"' AND "
	cQuery += "BY8.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY BY8_CODREG"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBBY8",.F.,.T.)
	
	dbSelectArea( 'TRBBY8' )
	dbGoTop()
	
	While TRBBY8->( !Eof() )
		Aadd(aRegioes,TRBBY8->CODREG)
		TRBBY8->( dbSkip() )
	EndDo
	
	TRBBY8->( dbCloseArea() )
ElseIf Len(aLinha) > 0
	For nFor:= 1 to Len(aLinha)
		Aadd(aRegioes,aLinha[nFor][1])
	Next nFor
	lMarkReg:= .F.
EndIf

If lMarkReg 
	If Len( aRegioes ) > 0
		For nFor := 1 to Len(aRegioes)
			nPos := Ascan( aLinha, {|x| x[1] == aRegioes[nFor]} )
			If nPos <> 0
				MarcaLinha(nPos,aLinha,lCheck)
			EndIf
		Next
	EndIf
EndIf
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MarcaLinhaºAutor  ³Alexander           º Data ³  29/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Marca ou desmarca todas ou uma linha(s)				  	  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MarcaLinha(nLinha,aLinha,lCheck)

LOCAL nI
LOCAL nTamanho
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Checa se uma linha ou todas																	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(nLinha)
	nTamanho := Len(aLinha)
	nJ	 		:= 1
Else
	lCheck   := !aLinha[nLinha,Len( aLinha[nLinha] ) ]
	nJ			:= nLinha
	nTamanho := nJ
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Marca linha	uma ou todas																	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := nJ To nTamanho
	aLinha[nI,Len(aLinha[nI])] := lCheck
Next

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ChecaAcao ºAutor  ³Alexander           º Data ³  29/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Checa se pode glosar valid no campo BDX_ACAO				  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ChecaAcao()
LOCAL lRet := .F.

lRet := If( Posicione( "BX4",1,xFilial("BX4")+PLSRtCdUsr()+PlsIntPad(),"BX4_ANAGLO" ) == '0',.F.,.T. )

Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLS980Vld  ³ Autor ³ Eduardo Motta       ³ Data ³ 30.03.06 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Efetua validacao dos campos chaves do detalhe de cobranca  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS980Vld()

Local lRet 		:= .T.
Local cCodInt   := M->BX4_CODINT

// Validacao do preenchimento dos campos que chamam a funcao

If ReadVar() = "M->BXR_CODEMP" .And. ! Empty(M->BXR_CODEMP)
	lRet := BG9->(MsSeek(xFilial("BG9") + cCodInt+M->BXR_CODEMP))// .And.;
   			//BT5->(MsSeek(xFilial("BT5") + cCodInt+M->BXR_CODEMP))  
	M->BXR_CONEMP := Space(Len(M->BXR_CONEMP))
	M->BXR_VERCON := Space(Len(M->BXR_VERCON))
	M->BXR_SUBCON := Space(Len(M->BXR_SUBCON))
	M->BXR_VERSUB := Space(Len(M->BXR_VERCON))
	M->BXR_DESCRI := BG9->BG9_DESCRI
ElseIf ReadVar() = "M->BXR_CONEMP" .And. ! Empty(M->BXR_CONEMP)
	lRet := ExistCpo("BT5",cCodInt+M->BXR_CODEMP+M->BXR_CONEMP)
	If lRet		// Gatilho o campo
		M->BXR_VERCON := BT5->BT5_VERSAO
		M->BXR_SUBCON := Space(Len(M->BXR_SUBCON))
		M->BXR_VERSUB := Space(Len(M->BXR_VERCON))
	Endif
ElseIf ReadVar() = "M->BXR_VERCON" .And. ! Empty(M->BXR_VERCON)
	lRet := ExistCpo("BT5",cCODINT+M->BXR_CODEMP+M->BXR_CONEMP+M->BXR_VERCON)
ElseIf ReadVar() = "M->BXR_SUBCON" .And. ! Empty(M->BXR_SUBCON)
	lRet := ExistCpo("BQC",cCODINT+M->BXR_CODEMP+M->BXR_CONEMP+M->BXR_VERCON+M->BXR_SUBCON)
	If lRet		// Gatilho o campo
		M->BXR_VERSUB := BQC->BQC_VERSUB
	Endif
ElseIf ReadVar() = "M->BXR_VERSUB" .And. ! Empty(M->BXR_VERSUB)
	lRet := ExistCpo("BQC",cCODINT+M->BXR_CODEMP+M->BXR_CONEMP+M->BXR_VERCON+M->BXR_SUBCON+M->BXR_VERSUB)
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ VldBrwB6P  ³ Autor ³ Thiago Paris        ³ Data ³ 23.07.20 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Validacao do Browse de Inclusao de Operador x Departamento ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function VldBrwB6P()
Local lRet    := .T.
Local nI      := 1
Local cCodDep := ""
For nI := 1 To Len(oBrwB6P:aCols)
	cCodDep := oBrwB6P:FieldGet("B6P_CODDEP",nI)
	If cCodDep == M->B6P_CODDEP
		//Help( cRotina , nLinha , cCampo , cNome , cMensagem , nLinha1 , nColuna , lPop , hWnd , nHeight , nWidth , lGravaLog , aSoluc )
		Help( nil, nil , STR0013 , nil, STR0014 , 1, 0, nil, nil, nil, nil, nil, {STR0015})
		Return .F.
	EndIf
Next
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ montaBIB   ³ Autor ³ Otacilio A. Junior  ³ Data ³ 22.01.07 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Efetua a montagem do Arquivo BIB para efetuar a amarração. ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function montaBIB(aMatBY8,aColsR,aHeaderR,aMatBY8D)

Local oDlg
Local oFolder
Local nOpcA
Local cComFil
Local lInverte  := .F.
Local aSize     := MsAdvSize()
Local aObjects  := {}
LOCAL aVetTrabR //vetor de trabalho para regioes
LOCAL nPosCodReg:= 0
LOCAL aRegioes  := {}
LOCAL	aLinha1	 := {}
LOCAL nFor, nI


AAdd( aObjects, { 100,	0,		.T., .F. } )
AAdd( aObjects, { 100,	100,	.T., .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

If !Empty(M->BX4_CODINT)
	DbSelectArea("BIB")
	
	If (Len(aColsR) == 0 .Or. Len(aMatBY8) == 0)
		lMarkReg  := .T.
		Store Header "BIB" TO aHeaderR For .T. .AND. SX3->X3_CAMPO $ "BIB_CODREG,BIB_DESCRI"
		BIB->(DbSetOrder(1))
		BIB->(DbSeek(M->(BX4_FILIAL+BX4_CODINT)))
		Store COLS "BIB" TO aColsR FROM aHeaderR VETTRAB aVetTrabR  while  BIB->(BIB_FILIAL+BIB_CODINT) == M->BX4_FILIAL+M->BX4_CODINT
	Else
		If aMatBY8[1,2] <> M->BX4_CODINT
			lMarkReg:= .T.
			If len(aMatBY8D) == 0
				aMatBY8D:= aMatBY8
			EndIf
			aMatBY8 := {}
			BY8->( DbSetOrder(1) )	//BY8_FILIAL+BY8_CODINT+BY8_CODOPE+BY8_CODREG
			If BY8->( MsSeek( xFilial("BY8")+M->BX4_CODINT+M->BX4_CODOPE) )
				While !BY8->( Eof() ) .and. BY8->(BY8_FILIAL+BY8_CODINT+BY8_CODOPE) == xFilial("BY8")+M->(BX4_CODINT+BX4_CODOPE)
					AADD(aMatBY8,{xFilial("BY8"), M->BX4_CODINT, M->BX4_CODOPE, BY8->BY8_CODREG})
					BY8->( DbSkip() )
				End
			EndIf
			Store Header "BIB" TO aHeaderR For .T. .AND. SX3->X3_CAMPO $ "BIB_CODREG,BIB_DESCRI"
			BIB->(DbSetOrder(1))
			BIB->(DbSeek(M->(BX4_FILIAL+BX4_CODINT)))
			Store COLS "BIB" TO aColsR FROM aHeaderR VETTRAB aVetTrabR  while  BIB->(BIB_FILIAL+BIB_CODINT) == M->BX4_FILIAL+M->BX4_CODINT
		ElseIf aMatBY8[1,2] == M->BX4_CODINT .and. lMarkReg .and. !inclui
			lMarkReg := .T.
			Store Header "BIB" TO aHeaderR For .T. .AND. SX3->X3_CAMPO $ "BIB_CODREG,BIB_DESCRI"
			BIB->(DbSetOrder(1))
			BIB->(DbSeek(M->(BX4_FILIAL+BX4_CODINT)))
			Store COLS "BIB" TO aColsR FROM aHeaderR VETTRAB aVetTrabR  while  BIB->(BIB_FILIAL+BIB_CODINT) == M->BX4_FILIAL+M->BX4_CODINT
		EndIf
	EndIf
	
	aLinha1:=aClone(aColsR)
	DEFINE MSDIALOG oDlg TITLE "Cadastro de Regiôes" FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() PIXEL
//DEFINE MSDIALOG oDlg TITLE "Cadastro de Regiôes" From 30,20 To 50,100 OF GetWndDefault()
	
	@ aPosObj[2][1],aPosObj[2][2] FOLDER oFolder SIZE aPosObj[2][3],aPosObj[2][4] OF oDlg PIXEL	PROMPTS	STR0011			//"Regioes"
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ MarkBrowse do BIB - Regioes												 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MarkB(aColsR,aHeaderR,2,02,oFolder:aDialogs[1],010,003,aPosObj[2][3]-8,aPosObj[2][4]-26,lMarkReg)
	//MarkB(aColsR,aHeaderR,20,20,oDlg,040,020,280,100,lMarkReg)
	lMarkReg:= .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria tela para selecao das Regioes...			                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg ,{|| nOpca := 1 , oDlg:End()},{||aColsR:=aClone(alinha1), nOpca := 0,ODlg:End()})
	
	If  nOpca == 1
		nPosCodReg := PLRETPOS("BIB_CODREG",aHeaderR)
		For nI := 1 To Len(aColsR)
			If aColsR[nI,Len(aColsR[nI])]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gravacao do arquivo operador x regioes									 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				BY8->( DbSetOrder(1) )	//BY8_FILIAL+BY8_CODINT+BY8_CODOPE+BY8_CODREG
				
				If ! BY8->( MsSeek( xFilial("BY8")+M->BX4_CODINT+M->BX4_CODOPE+aColsR[nI,nPosCodReg] ) )
					If Len(aMatBY8) > 0
						If aMatBY8[1,2] <> M->BX4_CODINT
							aMatBY8:= {}
						EndIf
					EndIf
					AADD(aMatBY8,{xFilial("BY8"), M->BX4_CODINT, M->BX4_CODOPE, aColsR[nI,nPosCodReg]})
				EndIf
			EndIf
		Next nI
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpa o filtro...								                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BIB->( dbClearFilter() )
	
Else
	MsgAlert("Preencha o Código da Operadora","Atenção")
EndIf

Return(aMatBY8,aColsR,aHeaderR,aMatBY8D)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GravaBY8  ºAutor  ³ Otacilio A. Junior º Data ³ 23/01/2007  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava todos os registros da matriz acols na tabela BY8		  º±±
±±º		    ³o identificador se gravar ou nao e o ultimo campo	de cada º±±
±±º		    ³linha da matriz .T. grava .F. exclui							     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GravaBY8(aMatBY8,aMatBIB,cCodOpe,cCodInt,aMatBY8D)

LOCAL nI
LOCAL aGrava  := {}

If Len(aMatBY8) > 0
	BY8->( DbSetOrder(1) )
	For nI := 1 To Len(aMatBIB)
		nPos := Ascan( aMatBY8, {|x| x[4] == aMatBIB[nI,1]} )
		If nPos <> 0 .and. !aMatBIB[nI,Len(aMatBIB[nI])]
			AaDd( aGrava,{aMatBY8[nPos,1],aMatBY8[nPos,2],aMatBY8[nPos,3],aMatBY8[nPos,4],"D"} ) //Deleta o registro no BY8
		ElseIf nPos >= 1 .and. aMatBIB[nI,Len(aMatBIB[nI])]
			AaDd( aGrava,{xFilial("BY8"),cCodInt,cCodOpe,aMatBIB[nI,1],"G"} ) //Grava o registro no BY8
		ElseIf nPos >= 1 .and. !aMatBIB[nI,Len(aMatBIB[nI])]
			AaDd( aGrava,{aMatBY8[nPos,1],aMatBY8[nPos,2],aMatBY8[nPos,3],aMatBY8[nPos,4],"D"} ) //Deleta o registro no BY8
		EndIf
		
		If nPos == 0 .and. aMatBIB[nI,Len(aMatBIB[nI])]
			AaDd( aGrava,{xFilial("BY8"),cCodInt,cCodOpe,aMatBIB[nI,1],"G"} ) //Grava o registro no BY8
		EndIf
	Next
	For nI := 1 to Len(aMatBY8D)
		If aMatBY8D[nI,2] <> cCodInt
			AaDd( aGrava,{aMatBY8D[nI,1],aMatBY8D[nI,2],aMatBY8D[nI,3],aMatBY8D[nI,4],"D"} ) //Deleta o registro no BY8
		EndIf
	Next
Else
	For nI := 1 To Len(aMatBIB)
		If aMatBIB[nI,Len(aMatBIB[nI])]
			AaDd( aGrava,{xFilial("BY8"),cCodInt,cCodOpe,aMatBIB[nI,1],"G"} ) //Grava o registro no BY8
		EndIf
	Next
EndIf

For nI := 1 To Len(aGrava)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravacao do arquivo operador x regioes									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BY8->( DbSetOrder(1) )	//BY8_FILIAL+BY8_CODINT+BY8_CODOPE+BY8_CODREG
	
	If aGrava[nI,Len( aGrava[nI] )] == "G"
		If BY8->( !MsSeek( aGrava[nI,1]+aGrava[nI,2]+aGrava[nI,3]+aGrava[nI,4] ) )
			BY8->( RecLock("BY8",.T.) )
			BY8->BY8_FILIAL := aGrava[nI,1]
			BY8->BY8_CODINT := aGrava[nI,2]
			BY8->BY8_CODOPE := aGrava[nI,3]
			BY8->BY8_CODREG := aGrava[nI,4]
			BY8->( MsUnlock() )
		EndIf
	Else
		If BY8->( MsSeek( aGrava[nI,1]+aGrava[nI,2]+aGrava[nI,3]+aGrava[nI,4] ) )
			BY8->( RecLock("BY8",.F.) )
			BY8->( DbDelete() )
			BY8->( MsUnlock() )
		EndIf
	EndIf
Next nI
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Darcio R. Sporl       ³ Data ³08/01/2007³±±
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
Private aRotina := { 	{ STR0001 ,'AxPesqui'    , 0, K_Pesquisar  , 0, .F.},;//"Pesquisar"
						{ STR0002 ,'AxVisual'    , 0, K_Visualizar , 0, Nil},;  //"Visualizar"
						{ STR0003 ,'PLSA980MOV'  , 0, K_Incluir    , 0, Nil},;  //"Incluir"
						{ STR0004 ,'PLSA980MOV'  , 0, K_Alterar    , 0, Nil},;  //"Alterar"
						{ STR0005 ,'PLSA980MOV'  , 0, K_Excluir    , 0, Nil} }  //"Excluir"
Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA980VLC ºAutor  ³ Thiago Guilherme º Data ³ 05/04/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Altera a possibilidade de alteracao ou vizualizacao		   º±±
±±º		    ³ do campo BX4_DIRDOC de acordo com a selecao do campo BX4_MOTDOCº±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA980VLC(nOpca)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se opcao monitor DOC estiver habilitado, é obrigatório preencher o diretório de Documentos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == K_OK
  If FieldPos("BX4_MOTDOC") > 0	.AND. FieldPos("BX4_DIRDOC") > 0
     If M->BX4_MOTDOC == "1" .AND. EMPTY(M->BX4_DIRDOC)
			Help("",1,"PL501V")
			Return .F.
	 EndIf
  EndIf
EndIf
Return .T.
