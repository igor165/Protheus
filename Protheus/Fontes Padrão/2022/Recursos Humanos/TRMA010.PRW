#INCLUDE "Protheus.ch"
#INCLUDE "dbtree.ch"
#INCLUDE "TRMA010.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TRMA010  � Autor � Emerson Grassi Rocha  � Data � 11/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro das Entidades dos Cursos                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TRMA010                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Avoid                                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TRMA010                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS  �  Motivo da Alteracao                    ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�21.07.14�TPZSOX �Incluido o fonte da 11 para a 12 e efetu-���
���            �        �       �ada a limpeza.                           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TRMA010

LOCAL cFiltra 	:= ""				//Variavel para filtro
LOCAL aIndFil	:= {}				//Variavel Para Filtro

Private bFiltraBrw 	:= {|| Nil}		//Variavel para Filtro
Private cUtil 		:= ""
Private	aAC 		:= {STR0001,STR0002}	//"Abandona"###"Confirma"

Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemtoAnsi(STR0008)	//"Cadastro de Entidades"

//������������������������������������������������������������������������Ŀ
//� Inicializa o filtro utilizando a funcao FilBrowse                      �
//��������������������������������������������������������������������������
dbSelectArea("RA0")
dbSetOrder(1)

cUtil := IIf(cModulo == "TRM", "1", "2")
cFiltra 	:= CHKRH(FunName(),"RA0","1")
cFiltraRA0	:= "Val(RA0->RA0_UTIL)== 0 .Or. RA0->RA0_UTIL == cUtil"

If !Empty(cFiltra)
	cFiltraRA0 += ".And." + cFiltra
EndIf

bFiltraBrw 	:= {|| FilBrowse("RA0",@aIndFil,@cFiltraRA0) }
Eval(bFiltraBrw) 

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
dbSelectArea("RA0")
dbGoTop()

mBrowse(6, 1, 22, 75, "RA0")

//������������������������������������������������������������������������Ŀ
//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
//��������������������������������������������������������������������������
EndFilBrw("RA0",aIndFil)

dbSelectArea("RA0")
dbSetOrder(1)

dbSelectArea("RA6")
dbSetOrder(1)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � TR010Rot  � Autor � Emerson Grassi Rocha � Data � 11/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Mostra o Tree dos funcionario                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
���          � ExpN1 : Registro                                           ���
���          � ExpN2 : Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Trma010       �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TR010Rot(cAlias,nReg,nOpcx)
Local oDlgMain, oTree
Local nOpca		:= 0
Local lTrDel	:= If(nOpcx=2.Or.nOpcx=5,.F.,.T.)
Local aAC		:= { STR0001,STR0002 } 	//"Abandona"###"Confirma" 
Local i			:= 0
      
//��������������������������������������������������������������Ŀ
//� Variaveis para Dimensionar Tela		                         �
//����������������������������������������������������������������
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {}

Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}
Local aObj2Coords	:= {}

Local aEnchCoords	:= {}

Local aNoFields 	:= {"RA6_FILIAL","RA6_ENTIDA"}
Local bSeekWhile	:= {|| RA6->RA6_FILIAL + RA6->RA6_ENTIDA }
Local nRa6Ord		:= RetOrdem( "RA6" , "RA6_FILIAL+RA6_ENTIDA" )
Private nPosRec		:= 0

Private nOpcao	:= nOpcx
Private cGet    := ""

// Private da Getdados
Private aCols  	:= {}
Private aHeader	:= {}
Private Continua:= .F.

Private oEnchoice
Private cCod	:= ""
Private cDesc	:= ""
Private cEstou	:= "1"
Private cIndo	:= ""

// Private dos objetos do Curso
Private o2Get
Private o2Group1
Private oSay1, oGet1, oAux

Private aTELA[0][0],aGETS[0]
bCampo := {|nCPO| Field(nCPO) }

If nOpcx # 3			// Diferente de Inclusao
	cCod 	:= RA0->RA0_ENTIDA
	cDesc	:= RA0->RA0_DESC
Else
	cCod 	:= CriaVar("RA0_ENTIDA")
	RollBackSX8()	// Retorna numeracao anterior devido InitPad abaixo.
	
	cDesc	:= CriaVar("RA0_DESC") 
EndIf	

//��������������������������������������������������������������Ŀ
//� Salva a integridade dos campos de Bancos de Dados 			 �
//����������������������������������������������������������������
If nOpcx == 3
	For i := 1 TO FCount()
		cCampo := EVAL(bCampo,i)
		lInit := .f.
		If ExistIni(cCampo)
			lInit := .t.
			M->&(cCampo) := InitPad(SX3->X3_RELACAO)
			If ValType(M->&(cCampo)) = "C"
				M->&(cCampo) := PADR(M->&(cCampo),SX3->X3_TAMANHO)
			EndIf
			If M->&(cCampo) == NIL
				lInit := .f.
			EndIf
		EndIf
		If !lInit
			M->&(cCampo) := FieldGet(i)
			If ValType(M->&(cCampo)) = "C"
				M->&(cCampo) := SPACE(LEN(M->&(cCampo)))
			ElseIf ValType(M->&(cCampo)) = "N"
				M->&(cCampo) := 0
			ElseIf ValType(M->&(cCampo)) = "D"
				M->&(cCampo) := CtoD("  /  /  ")
			ElseIf ValType(M->&(cCampo)) = "L"
				M->&(cCampo) := .F.
			EndIf
		EndIf
	Next i
Else
	For i := 1 TO FCount()
		 M->&(EVAL(bCampo,i)) := FieldGet(i)
	Next i
EndIf

FillGetDados(nOpcx					,; //1-nOpcx - n�mero correspondente � opera��o a ser executada, exemplo: 3 - inclus�o, 4 altera��o e etc;
			 "RA6"					,; //2-cAlias - area a ser utilizada;
			 nRa6Ord				,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
			 xFilial("RA6")+cCod	,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
			 bSeekWhile				,; //5-bSeekWhile - bloco contendo a express�o a ser comparada com cSeekKey na condi��o  do While.
			 NIL					,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-c�digo, condi��o a ser utilizado para executar o Loop no While;2� - array bi-dimensional contendo N.. condi��es, em que o 1� elemento � o bloco condicional, o 2� � bloco a ser executado se verdadeiro e o 3� � bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
			 aNoFields				,; //7-aNoFields - array contendo os campos que n�o estar�o no aHeader;
			 NIL					,; //8-aYesFields - array contendo somente os campos que estar�o no aHeader;
			 NIL					,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usu�rio;
			 NIL					,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
			 NIL					)  //11-bMontCols - bloco contendo fun��o especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}

nPosRec:=GdfieldPos("RA6_REC_WT")

If nOpcx == 3
	aCols[1][nPosRec]:=0
EndIf

cGet := cCod + " - " + cDesc

/*
��������������������������������������������������������������Ŀ
� Monta as Dimensoes dos Objetos         					   �
����������������������������������������������������������������*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
aAdd( aObjCoords , { 110 , 000 , .F. , .T. } )			//1-Tree
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )			//2-Dados
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords,, .T. )


aAdv1Size		:= aClone(aObjSize[2])
aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 1 , 1 }					 
aAdd( aObj1Coords , { 000 , 018 , .T. , .F. } )		//1-Cabec
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )		//2-Enchoice	
aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords )

aAdv2Size		:= aClone(aObj1Size[1])
aInfo2AdvSize	:= { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 5 , 5 }					 
aAdd( aObj2Coords , { 040 , 000 , .F. , .T. } )		//1-Cabec
aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )		//2-Enchoice	
aObj2Size		:= MsObjSize( aInfo2AdvSize , aObj2Coords,,.T. )


If cModulo = "TRM"
	aEnchCoords		:= aClone(aObjSize[2]) 
Else
	aEnchCoords		:= { aObjSize[1,1], aObjSize[1,2],aObjSize[2,3],aObjSize[2,4] }	
EndIf

DEFINE MSDIALOG oDlgMain FROM	aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cCadastro OF oMainWnd  PIXEL

	@ aObj2Size[1,1],aObj2Size[1,2] Say oSay1 PROMPT OemToAnsi(STR0010) SIZE 30,7 PIXEL		//"Entidade: "
	@ aObj2Size[2,1],aObj2Size[2,2] Get oGet1 VAR cGet SIZE 150,7 WHEN .F. PIXEL
	
	If cModulo == "TRM"
		DEFINE DBTREE oTree FROM aObjSize[1,1],aObjSize[1,2] TO aObjSize[1,3],aObjSize[1,4] CARGO OF oDlgMain;
				 ON CHANGE (Tr010Principal(cAlias,nReg,nOpcx,oTree,oDlgMain))
				
		oTree:bValid 	:= {|| Tr010VlTree(nOpcx) }
		oTree:lValidLost:= .f.
		oTree:lActivated:= .T.
				 
		DBADDTREE oTree PROMPT OemToAnsi(STR0012)+Space(30);		//"Entidade"
								 RESOURCE "FOLDER5","FOLDER6";
								 CARGO "1"
		DBENDTREE oTree					 							 
			
		DBADDTREE oTree PROMPT OemToAnsi(STR0011);		//"Cursos da Entidade"
								 RESOURCE "FOLDER5","FOLDER6";
								 CARGO "2"
		DBENDTREE oTree					 							 
	EndIf
			
	// Entidade
	Zero()
	oEnchoice:= MsMGet():New(cAlias, nReg, nOpcx, aAC,"AC",STR0009,,aEnchCoords,,,,,,,,,.T.) 	//"Quanto a exclusao"

	If cModulo == "TRM"							 
		// Cursos da Entidade
		@ aObj1Size[2,1],aObj1Size[2,2]GROUP o2Group1 TO aObj1Size[2,3],aObj1Size[2,4] LABEL OemtoAnsi(STR0013)	OF oDlgMain PIXEL 	// " Cursos "
		o2Get 	:= MSGetDados():New(aObj1Size[2,1]+8,aObj1Size[2,2]+5,aObj1Size[2,3]-4,aObj1Size[2,4]-4,nOpcx,"Tr010Ok","AllwaysTrue",,lTrDel,,1,,5000,,,,,oDlgMain)
	EndIf
				
ACTIVATE MSDIALOG oDlgMain ON INIT (If(cModulo == "TRM", (o2Group1:Hide(),o2Get:Hide(),o2Get:oBrowse:Hide()), Nil) ,;
												oSay1:Hide(), oGet1:Hide(),oAux:= oEnchoice,;
												EnchoiceBar(oDlgMain,{||nOpca:=1,If(Tr010TudOk(nOpcx),oDlgMain:End(),) },{|| nOpca := 2,oDlgMain:End()}))

If nOpca == 1
	If nOpcx # 5 .And. nOpcx # 2	// Se nao for Exclusao e visual
		Begin Transaction
			If __lSX8
				ConfirmSX8()
			EndIf
			Tr010Grava(nOpcx)
			EvalTrigger()
		End Transaction
	ElseIf nOpcx = 5
		Begin Transaction
			Tr010Dele()
		End Transaction
	EndIf
Else
	If __lSX8
		RollBackSX8()
	EndIf			
EndIf

Release Object oTree

dbSelectArea(cAlias)
dbGoto(nReg)

Return(Nil)


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tr010Ok   � Autor � Emerson Grassi Rocha  � Data � 11/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida a linha da getdados                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �TRMA010                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function Tr010Ok()
Local nPosCod 	:= GdFieldPos("RA6_CURSO")
Local nx		:= 0

If nOpcao # 5 .And. nOpcao # 2

	If !aCols[n,Len(aCols[n])]      // Se nao esta Deletado
		If (nPosCod > 0 .And. Empty(aCols[n][nPosCod]))
			If Len(aCols) != 1
				Help("",1,"TR010VAZI")	  // Entidade ou Curso deve ser preenchido. 
				Return .F.
			EndIf
		EndIf
		
		For nx:=1 To Len(aCols)
			If aCols[n][nPosCod] == aCols[nx][nPosCod] .And.;
				!aCols[nx][Len(aCols[nx])] .And.	n # nx 
				Help(" ",1,"TR010COD")		// Entidade ou Curso ja cadastrado.
				Return .F.
				Exit
			EndIf	
		Next nx		
	EndIf
EndIf

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tr010Grava� Autor � Emerson Grassi Rocha  � Data � 11/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Grava os registros referente ao treinamentos                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
���          � ExpN1 : Registro                                           ���
���          � ExpN2 : Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �TRMA010                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Tr010Grava(nOpcx)

Local cCampo    := ""
Local xConteudo := ""
Local nx 		:= 0
Local ny 		:= 0
Local nI		:= 0
Local nPosCurso	:= GdFieldPos("RA6_CURSO")
Local lTravou	:=.F.

//�������������������������Ŀ
//� Gravacao de Arquivo Pai �
//���������������������������
dbSelectArea("RA0")
RecLock("RA0",IIf(nOpcx#3, .F., .T.))
For nI := 1 To RA0->( FCount() )
	If ( FieldName(nI) == "RA0_FILIAL" )
		FieldPut(nI, cFilial)
	Else
		FieldPut(nI, M->&(FieldName(nI)))
	EndIf
Next nI
MsUnlock()

//��������������������������������������������������������������Ŀ
//� Gravacao de Arquivo Filho (Relacionamento Curso x Entidade)  �
//����������������������������������������������������������������
If cModulo == "TRM"
	dbSelectArea("RA6") 
	For nX :=1 to Len(aCols)
	    Begin Transaction 
			lTravou:= .F.
			If aCols[nx][nPosRec]>0
				MsGoto(aCols[nX][nPosRec])
				RecLock("RA6",.F.)
				lTravou:=.T.
			Else
			    If !(aCols[nX][Len(aCols[nX])]) .And. !Empty(aCols[nx][nPosCurso])
					RecLock("RA6",.T.)
					lTravou:=.T.
				EndIf
			EndIf
			If lTravou
				//--Verifica se esta deletado
				If aCols[nX][Len(aCols[nX])] 
					dbDelete()
		        Else
					Replace RA6->RA6_FILIAL 	WITH xFilial("RA6")
					Replace RA6->RA6_ENTIDA	 	WITH cCod			
				EndIf
				For nY := 1 To Len(aHeader)
					If aHeader[nY][10] <> "V"
						RA6->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
					EndIf	
				Next nY
				MsUnlock()
			EndIf	
		End Transaction	
	Next nx
EndIf

Return .t.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tr010Dele � Autor � Emerson Grassi Rocha  � Data � 07/05/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Deleta todos os registros referentes aos treinamentos       ���
�������������������������������������������������������������������������Ĵ��
���Uso       �TRMA010                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Tr010Dele()
Local cCampo 	:= "RA6->RA6_ENTIDA"
      
dbSelectArea("RA2")
dbSetOrder(1)
dbGoTop()
While !Eof()
	If RA2->RA2_ENTIDA == RA0->RA0_ENTIDA
		Help("",1,"TrA010NAO")   
		Return .F.
	EndIf
	dbSkip()
EndDo

dbSelectArea("RA6")
dbSetOrder(1)
If dbSeek(xFilial("RA6")+cCod)
	While !Eof() .And. RA6->RA6_FILIAL+&cCampo == ;
						 xFilial("RA6")+cCod
		RecLock("RA6",.F.)
			dbDelete()
		MsUnlock()
		dbSkip()
	EndDo
EndIf	               

dbSelectArea("RA0")
RecLock("RA0",.F.)
	dbDelete()
MsUnlock()

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tr010TudOk� Autor � Emerson Grassi Rocha  � Data � 11/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao executada no Ok da enchoicebar                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Tr010TudOk(nExpN1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Uso       �TRMA010                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function Tr010TudOk(nOpcx)
If nOpcx == 2 
	Return .T.
EndIf	
Return (Tr010VlTree(nOpcx))

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   � Tr010Principal   � Autor � Emerson Grassi� Data � 11/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao principal que controla mudanca de arquivo           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Trm010Principal(cExpC1,nExpN1,nExpN2,oExpO1,oExpO2,aExpA1) ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Trma010       �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Tr010Principal(cAlias,nReg,nOpcx,oTree,oDlgMain,aConsult)
cIndo:= oTree:GetCargo()

If cEstou == "1"			
	oEnchoice:Hide()
	cCod	:= M->RA0_ENTIDA
	cDesc	:= M->RA0_DESC
	cGet 	:= M->RA0_ENTIDA + " - " + M->RA0_DESC
ElseIf cEstou == "2"
	o2Get:Hide()
	o2Get:oBrowse:Hide()
	o2Group1:Hide()
EndIf	

If cIndo == "1"			
	oEnchoice:Show()
	oSay1:Hide()
	oGet1:Hide()
	oAux	:= oEnchoice
ElseIf cIndo == "2"		
	o2Get:Show()
	o2Get:oBrowse:Show()
	o2Group1:Show()
	oSay1:Show()
	oGet1:Show()	
	oGet1:cText(cGet)
	oAux	:= o2Get
EndIf

cEstou := cIndo
		
Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 � Tr010Desc � Autor � Emerson Grassi Rocha � Data � 11/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Traz a descricao											  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lSx3 = .T.-Valid 	.F.-Relacao							  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �TRMA010/TRMA040�											  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function TR010Desc(lSx3)

Local aSaveRA0	:= RA0->(GetArea())
Local aSaveRA1	:= RA1->(GetArea())
Local aSaveRA6	:= RA6->(GetArea())
Local nProg 	:= If(FunName() == "TRMA010",1,( If(FunName() == "TRMA040", 2, 3 )))
Local nPosCod 	:= GdFieldPos(Iif(nProg == 1, "RA6_CURSO", ( Iif(nProg == 2, "RA6_ENTIDA", "RA4_ENTIDA"))))
Local nPosDes 	:= GdFieldPos("RA6_DESC")
Local cCodx   	:= " "
Local cRetorno	:= ""
Local nPosDur	:= GdFieldPos("RA6_DURACA")
Local nPosUni	:= GdFieldPos("RA6_UNID")
Local nPosVal	:= GdFieldPos("RA6_VALOR")

If lSx3
	cRetorno := " "
Else 
	cRetorno := .T.
EndIf        

If lSx3
	If nPosCod > 0  
	    cCodx := aCols[Len(aCols)][nPosCod]	
		If nProg == 1
			cRetorno := Iif(Inclui, "", Fdesc("RA1",cCodx,"RA1_DESC"))
		Else
			cRetorno := Iif(Inclui, "", Fdesc("RA0",cCodx,"RA0_DESC"))		
		EndIf	
	EndIf	
Else
	cCodx := &(ReadVar())
	If nProg == 1
		aCols[n][nPosDes] := Fdesc("RA1",cCodx,"RA1_DESC")
	Else 
		aCols[n][nPosDes] := Fdesc("RA0",cCodx,"RA0_DESC")
	EndIf    
	
	// Cadastro de Entidade ou Cad.Curso c/ opcao <> Inclusao
	If nProg == 1 .Or. nOpcao != 3
		
		// Preencher campos padrao atraves do RA1		
		IIf(nPosDur > 0 , aCols[n][nPosDur] := RA1->RA1_DURACA, Nil)
		IIf(nPosUni > 0 , aCols[n][nPosUni] := RA1->RA1_UNDURA, Nil)
		IIf(nPosVal > 0 , aCols[n][nPosVal] := RA1->RA1_VALOR, Nil) 
		
	// Inclusao no Cad. Curso			
	Else
		IIf(nPosDur > 0 , aCols[n][nPosDur] := M->RA1_DURACA, Nil)
		IIf(nPosUni > 0 , aCols[n][nPosUni] := M->RA1_UNDURA, Nil)
		IIf(nPosVal > 0 , aCols[n][nPosVal] := M->RA1_VALOR, Nil) 			
    EndIf
EndIf
     
RestArea(aSaveRA0)
RestArea(aSaveRA1)
RestArea(aSaveRA6)

Return cRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tr010Vltree� Autor � Emerson Grassi Rocha � Data � 11/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao do Tree                                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Trma010                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tr010VlTree(nOpcx)
Local lRet := .T.

If nOpcx # 2 .And. nOpcx # 5			// Diferente de visual e delecao
	If cEstou == "1"
		lRet:= Obrigatorio(aGets,aTela)
	ElseIf cEstou == "2"
		lRet:= Tr010Ok()
	EndIf
EndIf	

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 � Ra0UtilVld � Autor � Emerson Grassi Rocha � Data �19/10/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valid do Campo RA0_UTIL									  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� <Vide Parametros Formais>								  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �TRMA010		 �											  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function Ra0UtilVld()

Local lRa0Util := .T.

Begin Sequence

	IF !( lRa0Util := Pertence( Ra0UtilBox( .T. ) ) )
		Break
	EndIF

End Sequence

Return( lRa0Util )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 � Ra0UtilBox � Autor � Emerson Grassi Rocha � Data �19/10/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para Retornar as Opcoes do Campo RA0_UTIL			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� <Vide Parametros Formais>								  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �TRMA010		 �X3_CBOX para o campo RA0_UTIL				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function Ra0UtilBox( lValid , lRetDesc , cOpcDesc )

Local cOpcBox

DEFAULT lValid		:= .F.
DEFAULT lRetDesc	:= .F.

IF !( lValid )

	IF !( lRetDesc )

		cOpcBox := ( "0=" + OemToAnsi(STR0014) + ";" )	//"Todos m�dulos"
		cOpcBox += ( "1=" + OemToAnsi(STR0015) + ";" )	//"Treinamento"
		cOpcBox += ( "2=" + OemToAnsi(STR0016)       )	//"Recrutamento"

	Else

		Do Case
			Case ( cOpcDesc == "0" ) ; ( cOpcBox := OemToAnsi(STR0014) )	//"Todos m�dulos"
			Case ( cOpcDesc == "1" ) ; ( cOpcBox := OemToAnsi(STR0015) )	//"Treinamento"
			Case ( cOpcDesc == "2" ) ; ( cOpcBox := OemToAnsi(STR0016) )	//"Recrutamento"
		End Case

	EndIF
Else

	cOpcBox := "012"

EndIF
	
Return( cOpcBox )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 � Ra0UtilIni � Autor � Emerson Grassi Rocha � Data �19/10/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para Retornar as Opcoes do Campo RA0_UTIL			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� <Vide Parametros Formais>								  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �TRMA010		 �X3_RELACAO para o campo RA0_UTIL			  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function Ra0UtilIni()
Return( Iif(cModulo=="TRM", "1", Iif(cModulo == "RSP", "2", "0" ) ) )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 � Ra0TipoVld � Autor � Emerson Grassi Rocha � Data �19/10/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valid do Campo RA0_TIPO									  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� <Vide Parametros Formais>								  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �TRMA010		 �											  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function Ra0TipoVld()

Local lRa0Tipo := .T.

Begin Sequence

	IF !( lRa0Tipo := Vazio() .Or. ExistCpo("SQX") )
		Break
	EndIF
	
	M->RA0_DESTIP := Fdesc("SQX", M->RA0_TIPO, "QX_DESC")

End Sequence

Return( lRa0Tipo )         

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �21/12/2006�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �TRMA010                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/   

Static Function MenuDef()
//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������

 Local aRotina := { 	{ STR0003, 'PesqBrw' , 0, 1,,.F.}, ;	//'Pesquisar'
						{ STR0004, 'Tr010Rot', 0, 2}, ;	//'Visualizar'
						{ STR0005, 'Tr010Rot', 0, 3}, ;	//'Incluir'
						{ STR0006, 'Tr010Rot', 0, 4}, ;	//'Alterar'
						{ STR0007, 'Tr010Rot', 0, 5,3} }	//'Excluir'

Return aRotina

/*/{Protheus.doc} fValidCGC0
Valida CGC zerado
@author gabriel.almeida
@since 21/06/2019
@version 1.0
/*/
Function fValidCGC0(cCGC)
	Local lCGCZerado := .T.

	If Val(cCGC) == 0
		lCGCZerado := .F.
		MsgAlert(OemToAnsi(STR0019)) //CNPJ/CPF inv�lido
	EndIf
Return lCGCZerado