#INCLUDE "plsa980.ch"
#include "PLSMGER.CH"
#include "PROTHEUS.CH"
#include "COLORS.CH"
#include "TCBROWSE.CH"
#include "JPEG.CH"
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLSA980 � Autor � Tulio Cesar          � Data � 03.05.2001 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Relacao Operador X Operadora                               潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function PLSA980

PRIVATE aRotina   := MenuDef()
PRIVATE cCadastro := Fundesc()
PRIVATE cAlias    := "BX4"
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Chama funcao de Browse...                                           �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
BX4->(DbSetOrder(1))
BX4->(mBrowse(ndLinIni,ndColIni,ndLinFin,ndColFin,cAlias))
PLSCLSOP()
PLSINICIA()
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Fim da Rotina Principal...                                               �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Return

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLSA980MOV � Autor � Tulio Cesar       � Data � 13.07.1999 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Movimentacao Operador X Operadora                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � PLSA980()                                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Padrao do mBrowse                                          潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
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
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Carrega tabela de Operadores X Instituicoes								 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If nOpc == K_Incluir
	Copy "BX4" TO Memory Blank
Else
	Copy "BX4" TO Memory
EndIf
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Faz a exclusao do operador e das criticas (bx5)							 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If nOpc == K_Excluir
	nOpca := BX4->(AxDeleta(cAlias,nReg,nOpc))
	If nOpca == 2
		DeletaBX5(M->BX4_CODOPE,M->BX4_CODINT)
		DeletaBY8(M->BX4_CODOPE,M->BX4_CODINT)
	EndIf
	Return
EndIf
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Carrega tabela de Motivos de Glosas										 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Store Header "BCT" TO aHeader For SX3->X3_CAMPO $ "BCT_PROPRI,BCT_CODGLO,BCT_DESCRI"
BCT->( DbGoTop() )
BCT->( DbSetOrder(1) )
BCT->( DbSeek(xFilial("BCT")+M->(BX4_CODINT)) )
Store COLS "BCT" TO aCols From aHeader VETTRAB aVetTrab While BCT->(BCT_FILIAL+BCT_CODOPE) == M->(BX4_FILIAL+BX4_CODINT) .And. BCT->BCT_PROPRI $ "0,5"
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Se a operadora tiver motivos de critica (bct)							 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If Len(aCols) == 0 
   lMarkB := .F.
EndIf
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Carrena na matriz os dados do operador e operadora gravados no BX5		 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Trocar o conteudo do campo de acordo com o cbox do sx3					 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	For nI := 1 To Len(aCols)
		aCols[nI,1] := alltrim(X3COMBO("BCT_PROPRI",aCols[nI,1]))
	Next	
	For nI := 1 To Len(aMatBX5)
		aMatBX5[nI,1] := alltrim(X3COMBO("BCT_PROPRI",aMatBX5[nI,1]))
	Next	               
EndIf	
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Monta a GetDados do Folder Usuarios                                 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
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
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Monta a GetDados do Folder Departamentos                            �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
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

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Define tela com os folders												 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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

aadd(aButtons,{"S4WB009N",{ || MontaBIB(aMatBY8,aColsR,aHeaderR,aMatBY8D) },"Cadastro de Regi鮡s","Regi鮡s"})

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() PIXEL
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Folders																	 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If lMarkB
	@ aPosObj[2][1],aPosObj[2][2] FOLDER oFolder SIZE aPosObj[2][3],aPosObj[2][4] OF oDlg PIXEL	PROMPTS STR0007,STR0010,STR0012,STR0008		//"Operador X Institui玢o","Grupo/Empresa/Contrato","Departamentos","Operador X Institui玢o X Criticas"
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� MarkBrowse do BCT														 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	MarkB(aCols,aHeader,2,02,oFolder:aDialogs[4],010,003,aPosObj[2][3]-8,aPosObj[2][4]-26)
Else
	@ aPosObj[2][1],aPosObj[2][2] FOLDER oFolder SIZE aPosObj[2][3],aPosObj[2][4] OF oDlg PIXEL	PROMPTS STR0007,STR0010,STR0012		//"Operador X Institui玢o","Grupo/Empresa/Contrato","Departamentos"
EndIf
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Enchoice do BX4															 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
oEnchoice := BX4->(MsMGet():New(cAlias,nReg,nOpc,,,,,{003,005,aPosObj[2][4]-15,aPosObj[2][3]-5},,,,,,oFolder:aDialogs[1],,,.F.))

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Monta o Browse dos Opcionais da Familia                             �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
oBrwBXR  := TPLSBrw():New(003,005,aPosObj[2][3]-5,aPosObj[2][4]-15,NIL  ,oFolder:aDialogs[2],nil   , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBXR   ,aColsBXR ,.F.      ,"BXR" ,nOpc,"Grupo/Empresa/Contrato",nil,nil,nil,aVetBXR,,)
if PlsAliasExi("B6P")
	oBrwB6P  := TPLSBrw():New(003,005,aPosObj[2][3]-5,aPosObj[2][4]-15,NIL  ,oFolder:aDialogs[3],nil   , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabB6P   ,aColsB6P ,.F.      ,"B6P" ,nOpc,STR0012,nil,nil,nil,aVetB6P,,)
EndIf

ACTIVATE MSDIALOG oDlg ON INIT Eval( { || EnChoiceBar(oDlg,bOK,bCancel,.F.,aButtons) })

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Caso confirme a operacao...                                              �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If nOpca == K_OK
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Faz a Gravacao,alteracao ou exclusao									 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	BX4->( DbGoTo(nReg) )
	BX4->( PLUPTENC("BX4",nOpc) )
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Gravacao do arquivo operadors x inst x criticas							 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If lMarkB
		GravaBX5(aMatBX5,aCols,BX4->BX4_CODOPE,BX4->BX4_CODINT)
	EndIf
	
	aChave := {}
	aadd(aChave,{"BXR_CODOPE",M->BX4_CODOPE})
	aadd(aChave,{"BXR_CODINT",M->BX4_CODINT})
	oBrwBXR:Grava(aChave,.F.)

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Grava relacao Operador x Departamentos na tabela B6P                     �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Alteracao ou inclusao...                                                 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If nOpc == K_Incluir .Or. nOpc == K_Alterar
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� Se foi confirmada como Operadora   padrao...                             �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		If BX4->BX4_PADRAO == "1"
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//� Se tiver alguma outra como padrao atualizo...                            �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
			cCodInt := BX4->BX4_CODINT
			cCodOpe := BX4->BX4_CODOPE
			BX4->(DbSetOrder(2))
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� RETCODUSR() esta funcao foi retirada pq retorna o codope do usuario corrente�
			//� caso seja alterado algum registro de usuario diferente do que esta logado a �
			//� alteracao vai ser feita no usuario logado tb. 								 �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
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
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Fim da Rotina...                                                         �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Return
/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矰eletaBX5 篈utor  矨lexander           � Data �  29/06/05   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     矰eleta todos os registros do BX5 se o operador for excluido 罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
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
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矰eletaBX5 篈utor  矨lexander           � Data �  29/06/05   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     矰eleta todos os registros do BX5 se o operador for excluido 罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function DeletaBY8(cCodOpe,cCodInt)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Exclusao do arquivo operador x regioes									 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矴ravaBX5  篈utor  矨lexander           � Data �  29/06/05   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     矴rava todos os registros da matriz acols na tabela BX5	  罕�
北�		     硂 identificador se gravar ou nao e o ultimo campo	de cada   罕�
北�		     砽inha da matriz .T. grava .F. exclui						  罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
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
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矼arkB     篈utor  矨lexander           � Data �  29/06/05   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     矯ria um markbrowse dinamicamente							  罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
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

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Checkbox para marcar e desmarcar todos														�
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
@ nCheLi,nCheCo CHECKBOX oCheck VAR lCheck PROMPT STR0009 OF oDlg SIZE 100,8 //"Marca e Desmarca todos"
oCheck:bChange := {|| MsAguarde( {|| MarcaLinha('',aLinha,lCheck),oLista:Refresh() } ) }
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Monta o TcBrowse																			�
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
oLista := TcBrowse():New( nPosLI,nPosCI,nPosCF,nPosLF,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
aadd(aCampos , .F.)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Adiciona o BitMap de marcado e desmarcado													�
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
add COLUMN To oLista BitMap Data { || LoadBitMap( GetResources(), Iif(!aLinha[oLista:nAt,Len(aLinha[oLista:nAt])] ,EVal({|| lCheck := .F.,"LBNO"}),"LBOK" ) )} Title "" WIDTH 015 NOHILITE
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Carrega o cabecalho																			�
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
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

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Carrega os dados																			�
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
oLista:SetArray(aLinha)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Duploclick na linha																			�
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
oLista:BLDBLCLICK := { || MarcaLinha(oLista:nAt,aLinha,lCheck) , oLista:Refresh() }

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Adiciona o BitMap de marcado nas regioes selecionadas para o operador (alterar)	�
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
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
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矼arcaLinha篈utor  矨lexander           � Data �  29/06/05   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     矼arca ou desmarca todas ou uma linha(s)				  	  罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function MarcaLinha(nLinha,aLinha,lCheck)

LOCAL nI
LOCAL nTamanho
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Checa se uma linha ou todas																	�
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If Empty(nLinha)
	nTamanho := Len(aLinha)
	nJ	 		:= 1
Else
	lCheck   := !aLinha[nLinha,Len( aLinha[nLinha] ) ]
	nJ			:= nLinha
	nTamanho := nJ
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Marca linha	uma ou todas																	�
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
For nI := nJ To nTamanho
	aLinha[nI,Len(aLinha[nI])] := lCheck
Next

Return


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矯hecaAcao 篈utor  矨lexander           � Data �  29/06/05   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     矯heca se pode glosar valid no campo BDX_ACAO				  罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function ChecaAcao()
LOCAL lRet := .F.

lRet := If( Posicione( "BX4",1,xFilial("BX4")+PLSRtCdUsr()+PlsIntPad(),"BX4_ANAGLO" ) == '0',.F.,.T. )

Return( lRet )

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘北
北矲uncao    � PLS980Vld  � Autor � Eduardo Motta       � Data � 30.03.06 潮北
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢北
北矰escricao � Efetua validacao dos campos chaves do detalhe de cobranca  潮北
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
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
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘北
北矲uncao    � VldBrwB6P  � Autor � Thiago Paris        � Data � 23.07.20 潮北
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢北
北矰escricao � Validacao do Browse de Inclusao de Operador x Departamento 潮北
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
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
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘北
北矲uncao    � montaBIB   � Autor � Otacilio A. Junior  � Data � 22.01.07 潮北
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢北
北矰escricao � Efetua a montagem do Arquivo BIB para efetuar a amarra玢o. 潮北
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
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
	DEFINE MSDIALOG oDlg TITLE "Cadastro de Regi鬳s" FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() PIXEL
//DEFINE MSDIALOG oDlg TITLE "Cadastro de Regi鬳s" From 30,20 To 50,100 OF GetWndDefault()
	
	@ aPosObj[2][1],aPosObj[2][2] FOLDER oFolder SIZE aPosObj[2][3],aPosObj[2][4] OF oDlg PIXEL	PROMPTS	STR0011			//"Regioes"
	
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� MarkBrowse do BIB - Regioes												 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	MarkB(aColsR,aHeaderR,2,02,oFolder:aDialogs[1],010,003,aPosObj[2][3]-8,aPosObj[2][4]-26,lMarkReg)
	//MarkB(aColsR,aHeaderR,20,20,oDlg,040,020,280,100,lMarkReg)
	lMarkReg:= .F.
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Cria tela para selecao das Regioes...			                         �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg ,{|| nOpca := 1 , oDlg:End()},{||aColsR:=aClone(alinha1), nOpca := 0,ODlg:End()})
	
	If  nOpca == 1
		nPosCodReg := PLRETPOS("BIB_CODREG",aHeaderR)
		For nI := 1 To Len(aColsR)
			If aColsR[nI,Len(aColsR[nI])]
				//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
				//� Gravacao do arquivo operador x regioes									 �
				//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
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
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Limpa o filtro...								                         �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	BIB->( dbClearFilter() )
	
Else
	MsgAlert("Preencha o C骴igo da Operadora","Aten玢o")
EndIf

Return(aMatBY8,aColsR,aHeaderR,aMatBY8D)

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矴ravaBY8  篈utor  � Otacilio A. Junior � Data � 23/01/2007  罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     矴rava todos os registros da matriz acols na tabela BY8		  罕�
北�		    硂 identificador se gravar ou nao e o ultimo campo	de cada 罕�
北�		    砽inha da matriz .T. grava .F. exclui							     罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
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
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Gravacao do arquivo operador x regioes									 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
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
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  矼enuDef   � Autor � Darcio R. Sporl       � Data �08/01/2007潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Utilizacao de menu Funcional                               潮�
北�          �                                                            潮�
北�          �                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   矨rray com opcoes da rotina.                                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砅arametros do array a Rotina:                               潮�
北�          �1. Nome a aparecer no cabecalho                             潮�
北�          �2. Nome da Rotina associada                                 潮�
北�          �3. Reservado                                                潮�
北�          �4. Tipo de Transa噭o a ser efetuada:                        潮�
北�          �		1 - Pesquisa e Posiciona em um Banco de Dados           潮�
北�          �    2 - Simplesmente Mostra os Campos                       潮�
北�          �    3 - Inclui registros no Bancos de Dados                 潮�
北�          �    4 - Altera o registro corrente                          潮�
北�          �    5 - Remove o registro corrente do Banco de Dados        潮�
北�          �5. Nivel de acesso                                          潮�
北�          �6. Habilita Menu Funcional                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�   DATA   � Programador   矼anutencao efetuada                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�          �               �                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function MenuDef()
Private aRotina := { 	{ STR0001 ,'AxPesqui'    , 0, K_Pesquisar  , 0, .F.},;//"Pesquisar"
						{ STR0002 ,'AxVisual'    , 0, K_Visualizar , 0, Nil},;  //"Visualizar"
						{ STR0003 ,'PLSA980MOV'  , 0, K_Incluir    , 0, Nil},;  //"Incluir"
						{ STR0004 ,'PLSA980MOV'  , 0, K_Alterar    , 0, Nil},;  //"Alterar"
						{ STR0005 ,'PLSA980MOV'  , 0, K_Excluir    , 0, Nil} }  //"Excluir"
Return(aRotina)

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  砅LSA980VLC 篈utor  � Thiago Guilherme � Data � 05/04/2013  罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     矨ltera a possibilidade de alteracao ou vizualizacao		   罕�
北�		    � do campo BX4_DIRDOC de acordo com a selecao do campo BX4_MOTDOC罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PLSA980VLC(nOpca)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Se opcao monitor DOC estiver habilitado, � obrigat髍io preencher o diret髍io de Documentos�
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If nOpca == K_OK
  If FieldPos("BX4_MOTDOC") > 0	.AND. FieldPos("BX4_DIRDOC") > 0
     If M->BX4_MOTDOC == "1" .AND. EMPTY(M->BX4_DIRDOC)
			Help("",1,"PL501V")
			Return .F.
	 EndIf
  EndIf
EndIf
Return .T.
