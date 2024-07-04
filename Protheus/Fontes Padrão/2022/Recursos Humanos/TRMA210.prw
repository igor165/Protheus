#include "Protheus.ch"
#include "dbtree.ch"
#include "font.ch"
#include "colors.ch"
#include "TRMA210.CH"

//Recuperar vers�o de envio
Static cVersEnvio 	:= ""
Static cVersGPE   	:= ""
Static lIntTAF    	:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 0 )
Static lCargSQ3	  	:= SuperGetMv("MV_CARGSQ3",,.F.) //Define se o envio do evento S-1030 ser�o feito pela tabela SQ3 e n�o pela SRJ (Padr�o .F. -> SRJ).
Static lMsbql

/*/
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���ProgramA  � TRMA210  � Autor � Emerson Grassi Rocha         � Data � 02/09/02 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Controle dos programas de Funcoes                                 ���
��������������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                            ���
��������������������������������������������������������������������������������Ĵ��
���Program.  � Data     � BOPS  �Manutencao Efetuada                             ���
��������������������������������������������������������������������������������Ĵ��
���Cecilia C.�21.07.2014�TPZSOX �Incluido o fonte da 11 para a 12 e efetuada a   ���
���          �          �       �limpeza.                                        ���
���Renan B.  �05/08/2015�TRZVKM �Ajuste para  verificar compartilhamento entre   ���
���          �          �       �tabelas SQS, SRJ e SQ3.                         ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������������ٱ�
���Julio S.  �13/12/2017�MPRIMESP-12721�Ajuste nos parametros da fun��o MSMM para excluir ���
���          �          �              �o campo memo RJ_DESCREQ              			  ���
������������������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������*/
Function TRMA210()

LOCAL cFiltra	:= ""	//Variavel para filtro
LOCAL aIndFil	:= {}	//Variavel Para Filtro
Local cSQ3		:= ""
Local cSRJ		:= ""

Private bFiltraBrw	:= {|| Nil}			//Variavel para Filtro
Private cCadastro	:= OemToAnsi(STR0001)	//"Funcao"

Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

/*/
��������������������������������������������������������������Ŀ
�So Executa se o Modo de Acesso dos Arquivos do Modulo TRM esti�
�verem OK													   �
����������������������������������������������������������������/*/
IF ( cModulo == "TRM" )
	IF !( TrmRelationFile() )
		Break
	EndIF
EndIf

cSRJ := FWModeAccess( "SRJ", 1) + FWModeAccess( "SRJ", 2) + FWModeAccess( "SRJ", 3)
cSQ3 := FWModeAccess( "SQ3", 1) + FWModeAccess( "SQ3", 2) + FWModeAccess( "SQ3", 3)

If cSQ3 > cSRJ
	//"O Modo de Acesso do relacionamento para a tabela de Fun��es deve possuir um compartilhamento igual ou maior ao cadastro de Cargos!"
	//"Altere o modo de acesso atraves do Configurador. Arquivos SRJ e SQ3."
	MsgInfo( oEmToAnsi( STR0017 ) + CRLF + CRLF + oEmToAnsi( STR0018 ) )
	Return (.F.)
EndIf

If lIntTAF .And. FindFunction("fVersEsoc")
	fVersEsoc("S1030", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, @cVersGPE)
	If FindFunction("ESocMsgVer") .And. cVersGPE <> cVersEnvio .And. (cVersGPE >= "9.0" .Or. cVersEnvio >= "9.0")
		//"Aten��o! A vers�o do leiaute GPE � xxx e a do TAF � xxx, sendo assim, est�o divergentes. O Evento n�o ser� integrado com o TAF, e consequentemente, n�o ser� enviado ao RET.
		//Caso prossiga a informa��o ser� atualizada somente na base do GPE. Deseja continuar?"
		If ESocMsgVer(.F.,If(lCargSQ3,"S-1040","S-1030"), cVersGPE, cVersEnvio)
			lIntTaf := .F.
		Else
			Return
		EndIf
	EndIf
EndIf
//������������������������������������������������������������������������Ŀ
//� Inicializa o filtro utilizando a funcao FilBrowse                      �
//��������������������������������������������������������������������������
dbSelectArea("SRJ")
dbSetOrder(1)

cFiltra 	:= CHKRH(FunName(),"SRJ","1")
bFiltraBrw 	:= {|| FilBrowse("SRJ",@aIndFil,@cFiltra) }
Eval(bFiltraBrw)

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
dbSelectArea("SRJ")
dbGoTop()

mBrowse( 6, 1,22,75,"SRJ")

//������������������������������������������������������������������������Ŀ
//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
//��������������������������������������������������������������������������
EndFilBrw("SRJ",aIndFil)

dbSelectArea("SRJ")
dbSetOrder(1)

dbSelectArea("SRJ")
dbSetOrder(1)

If cModulo == "TRM"
	dbSelectArea("RAL")
	dbSetOrder(1)
EndIf

Return(Nil)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � TRM210Rot � Autor � Emerson Grassi Rocha � Data � 02/02/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Mostra o Tree das Funcoes                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
���          � ExpN1 : Registro                                           ���
���          � ExpN2 : Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TRMA210       �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function TRM210Rot(cAlias,nReg,nOpcx)
Local oDlgMain
Local oTree
Local nOpca 	:= 0
Local aAC		:= { STR0007,STR0008 }		//"Abandona"###"Confirma"
Local i			:= 0

//��������������������������������������������������������������Ŀ
//� Variaveis para Dimensionar Tela		                         �
//����������������������������������������������������������������
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aTreeCoords	:= {}
Local aEnchCoords	:= {}
Local aGetDCoords	:= {}

Private lIntegTAF := .T.
//-- Private da Getdados
Private aCols  	:= {}
Private aHeader	:= {}

//-- Variaveis para Ponto de Entrada
Private lVisual := (nOpcx == 2)
Private lExclui := (nOpcx == 5)
Private lCopy 	:= (nOpcx == 6)

//-- Controle do Treinamento
Private cChave	:= ""
Private cFuncao1:= ""
Private cCodFunc:= ""
Private cDesc	:= ""
Private cEstou	:= "1"
Private cIndo	:= ""
Private oObjAtu, oSay1, oGet1
Private oEnchoice

// Private dos objetos do Cursos da Funcao
Private o3Get

// Private dos objetos da Enchoice
Private aTELA[0][0],aGETS[0]
bCampo := {|nCPO| Field(nCPO) }
M->RAL_CURSO:=space(4)
M->RAL_DCURSO:=space(30)

If nOpcx # 3	// Diferente de Inclusao
	cChave 	:= SRJ->RJ_FILIAL+SRJ->RJ_FUNCAO
	cFuncao1:= SRJ->RJ_FUNCAO
Else
	cFuncao1	:= CriaVar("RJ_FUNCAO")
	RollBackSX8()	//Retornar Numero anterior devido InitPad abaixo.
	cChave 	:= xFilial("SRJ")+cFuncao1
EndIf

//-- 1- Especificacao das Funcoes - SRJ
If nOpcx == 3
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("SRJ")
	While ( !Eof() .And. (SX3->X3_ARQUIVO == "SRJ") )
		cCampo := SX3->X3_CAMPO
		M->&(cCampo) := CriaVar(SX3->X3_CAMPO)
		dbSelectArea("SX3")
		dbSkip()
	EndDo
Else
	cCampo := {|nCPO| Field(nCPO) }
	For i := 1 TO FCount()
		If Field(i) == "RJ_FUNCAO" .AND. nOpcx == 6
			cCodFunc := FieldGet(i)
			M->&("RJ_FUNCAO") := Space(5)
		Else
			M->&(EVAL(cCampo,i)) := FieldGet(i)
		EndIf
	Next i
EndIf

//-- 2- Cursos da Funcao - RAL
If cModulo == "TRM"

	//==> Monta FilGetDados para Walk Thru
	FillGetDados(nOpcx			  				  			,; //1-nOpcx - n�mero correspondente � opera��o a ser executada, exemplo: 3 - inclus�o, 4 altera��o e etc;
				 "RAL"							 			,; //2-cAlias - area a ser utilizada;
				 RetOrdem("RAL","RAL_FILIAL+RAL_FUNCAO")	,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
				 cChave				 						,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
				 {|| RAL->RAL_FILIAL + RAL->RAL_FUNCAO }	,; //5-bSeekWhile - bloco contendo a express�o a ser comparada com cSeekKey na condi��o  do While.
				 NIL										,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-c�digo, condi��o a ser utilizado para executar o Loop no While;2� - array bi-dimensional contendo N.. condi��es, em que o 1� elemento � o bloco condicional, o 2� � bloco a ser executado se verdadeiro e o 3� � bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
				 {"RAL_FILIAL","RAL_FUNCAO"}				,; //7-aNoFields - array contendo os campos que n�o estar�o no aHeader;
				 NIL				  						,; //8-aYesFields - array contendo somente os campos que estar�o no aHeader;
				 NIL				 						,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usu�rio;
				 NIL				 						,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
				 NIL				 						,; //11-bMontCols - bloco contendo fun��o especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}
				 nOpcx==3			 						,;	//nOpcx==3 12-lEmpty � Caso True ( default � false ), inicializa o aCols com somente uma linha em branco ( como exemplo na inclus�o).
				 NIL				 						,; //13-aHeaderAux, eh Caso necessite tratar o aheader e acols como vari�veis locais ( v�rias getdados por exemplo; uso da MSNewgetdados )
				 NIL										)  //14-aColsAux eh Caso necessite tratar o aheader e acols como vari�veis locais ( v�rias getdados por exemplo; uso da MSNewgetdados )

EndIf

cDesc := SRJ->RJ_FUNCAO+" - "+SRJ->RJ_DESC

/*
��������������������������������������������������������������Ŀ
� Monta as Dimensoes dos Objetos         					   �
����������������������������������������������������������������*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

aTreeCoords		:= { (aObjSize[1,1]+2)	, (aObjSize[1,2])			, (aObjSize[1,3]), (aObjSize[1,4]*0.2) }
aEnchCoords		:= { (aObjSize[1,1]+2)	, (aObjSize[1,4]*0.2 + 5)	, (aObjSize[1,3]), (aObjSize[1,4]) }
aGetDCoords		:= { (aObjSize[1,1]+20), (aObjSize[1,4]*0.2 + 5)	, (aObjSize[1,3]), (aObjSize[1,4]) }

DEFINE MSDIALOG oDlgMain FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cCadastro OF oMainWnd PIXEL

	@ aGetDCoords[1]-18,aGetDCoords[2] Say oSay1 PROMPT OemToAnsi(STR0009) SIZE 20,7 PIXEL		//"Funcao : "
	@ aGetDCoords[1]-18,aGetDCoords[2]+30 Get oGet1 VAR cDesc SIZE 150,7 WHEN .F. PIXEL

	DEFINE DBTREE oTree FROM aTreeCoords[1],aTreeCoords[2] TO aTreeCoords[3],aTreeCoords[4] CARGO OF oDlgMain;
		ON CHANGE (Tr210Principal(cAlias,nReg,nOpcx,oTree,oDlgMain))

		//--Validacao da Saida do dbTree
		oTree:bValid 	:= {|| TreeVal210(nOpcx) }
		oTree:lValidLost:= .f.
		oTree:lActivated:= .T.

		DBADDTREE oTree PROMPT OemToAnsi(STR0010)+Space(30);	//"Descri��o Funcao"
						 RESOURCE "FOLDER5","FOLDER6";
						 CARGO "1"
		DBENDTREE oTree

		If cModulo == "TRM"
			DBADDTREE oTree PROMPT OemToAnsi(STR0012);	//"Cursos"
						 RESOURCE "FOLDER5","FOLDER6";
						 CARGO "2"
		 	DBENDTREE oTree
		EndIf

		// FUNCAO
		Zero()
		oEnchoice:= MsMGet():New(cAlias, nReg, nOpcx, aAC,"AC",STR0013,,aEnchCoords, , , , , , , , ,.T. )	//"Quanto a exclusao"

		If cModulo == "TRM"
			// CURSOS DA FUNCAO - RAL
			o3Get 	:= MSGetDados():New(aGetDCoords[1],aGetDCoords[2],aGetDCoords[3],aGetDCoords[4],nOpcx,"f210Linok()","TrR5LiOk()","",If(nOpcx==2 .Or. nOpcx==5 ,Nil,.T.),,1,,300, , , , ,oDlgMain)
			o3Get:oBrowse:Default()
		EndIf

ACTIVATE MSDIALOG oDlgMain ON INIT ;
					(If(cModulo == "TRM",(o3Get:Hide(),o3Get:oBrowse:Hide()),),;
					oSay1:Hide(),oGet1:Hide(),;
					oObjAtu:= oEnchoice,;
            EnchoiceBar(oDlgMain,	{|| If(TreeVal210(nOpcx),(nOpca:=1,oDlgMain:End()),)},;
            						{|| nOpca:=2,oDlgMain:End()} ))

If nOpca == 1
	//--Gravacao dos Arquvios
	If nOpcx # 5 .And. nOpcx # 2 .And. nOpcx # 6  // SE NAO FOR EXCLUSAO E VISUALIZACAO E COPIA
		Begin Transaction
			Tr210Grava(nOpcx)
			//��������������������������������������������������������Ŀ
			//�Realiza a gravacao do responsavel no arquivo utilizado  |
			//|pelos modulos do Quality Celerina, caso haja integracao.|
			//����������������������������������������������������������
			QC_QUALITY()
		End Transaction
		If __lSX8 .And. nOpcx == 3		// Inclusao
			ConfirmSX8()
		EndIf
	ElseIf nOpcx == 5		// Exclusao
		Begin Transaction
			Tr210Dele()
		End Transaction
	ElseIf nOpcx == 6  //SE FOR COPIA
		Begin Transaction
				TRMA210Copia(nOpcx)
				//��������������������������������������������������������Ŀ
				//�REALIZA A GRAVACAO DO RESPONSAVEL NO ARQUIVO UTILIZADO  |
				//|PELOS MODULOS DO QUALITY CELERINA, CASO HAJA INTEGRACAO.|
				//����������������������������������������������������������
				QC_QUALITY()
		End Transaction
	EndIf
Else
	If __lSX8 .And. nOpcx == 3
		RollBackSX8()
	EndIf
EndIf

Release Object oTree

dbSelectArea(cAlias)
dbGoto(nReg)

Return(Nil)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �TreeVal210� Autor � Emerson Grassi Rocha  � Data � 02/09/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida a Saida do dbTree                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nOpcx                                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TrmA210                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function TreeVal210(nOpcx)

Local lRet 		:= .T.

DEFAULT	lMsbql	:= SRJ->( ColumnPos( "RJ_MSBLQL" ) ) > 0

If nOpcx # 2 .And. nOpcx # 5
	If cEstou == "1"
		lRet := Obrigatorio(aGets,aTela)

		If lRet .And. lMsbql .And. nOpcx == 4 .And. M->RJ_MSBLQL == "1" .And. M->RJ_MSBLQL != SRJ->RJ_MSBLQL .And. fVldAtiv( M->RJ_FUNCAO )
			lRet := .F.	
			Aviso( OemToAnsi(STR0011), OemtoAnsi(STR0028), {"Ok"})//"Aten��o"N�o � possivel efetuar o bloqueio da fun��o pois h� funcion�rios ativos vinculados"
		EndIf

		IF lIntTAF .AND. lRet .AND. EMPTY(M->RJ_CODCBO)
			IF (MsgYesNo(STR0025, STR0011)) //O campo CBO 2002 � obrigat�rio para o esocial, sua altera��o n�o ser� integrada com o TAF. Deseja continuar?
				lIntegTAF := .F.
			ELSE
				lIntegTAF := .T.
				lRet := .F.
				Aviso(OemToAnsi(STR0011),OemtoAnsi(STR0026),{"Ok"}) //Campo CBO 2002 n�o preenchido, as altera��es n�o foram gravadas.

			ENDIF
		ENDIF
	Elseif cEstou = "2"
		lRet := TrR5LiOk("S")
	Endif
EndIf

Return lRet


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �Tr210Princ� Autor � Emerson Grassi Rocha  � Data � 02/09/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Controle dos programas da Funcao                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cAlias,nReg,nOpcx,oTree,oDlgMain,aCurCar           		  ���
�������������������������������������������������������������������������Ĵ��
���Uso       �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function Tr210Principal(cAlias,nReg,nOpcx,oTree,oDlgMain)
//	1- Descricao Funcao
//	2- Cursos do Funcao

cIndo:= oTree:GetCargo()

If cEstou == "1"
	oEnchoice:Hide()
	cDesc	:= M->RJ_FUNCAO + " - "+ M->RJ_DESC
	cFUNCAO1:= M->RJ_FUNCAO

ElseIf cEstou == "2"
	o3Get:Hide()
	o3Get:oBrowse:Hide()
EndIf

If cIndo == "1"
	oEnchoice:EnchRefreshAll()
	oEnchoice:Show()
	oSay1:Hide()
	oGet1:Hide()
	oObjAtu:= oEnchoice

ElseIf cIndo == "2"
	n		:= 1
	o3Get:Show()
	o3Get:oBrowse:Show()
	oSay1:Show()
	oGet1:Show()
	oGet1:cText(cDesc)
	oObjAtu  := o3Get
EndIf
cEstou := cIndo
Return Nil


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �TrR5LiOk  � Autor � Emerson Grassi Rocha  � Data � 02/09/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Linha Ok do arquivo RAL Cursos da Funcao                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lVldTree = Deve passar c/uma linha em branco               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TrmA210                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function TrR5LiOk(cVldTree)
Local lRet 		:= .T.
Local nPosCur 	:= GdFieldPos("RAL_CURSO")
Local nCont 	:= 0
Local nUsaRAL	:= Len(aCols[n])

cVldTree := If (cVldTree == Nil ,"N" , If (ValType(cVldTree) == "C",cVldTree, "N"))

If cVldTree== "S" .And. Len(aCols) = 1
	// Verifica se a primeira linha esta totalmente em branco
	If Tr210Linha()
		Return(.T.)
	EndIf
Endif

If aCols[n,nUsaRAL] == .F. .And. nPosCur > 0
	Aeval(aCols,{ |X| If( X[nPosCur]==aCols[N,nPosCur] .And. x[nUsaRAL] == .F. , nCont ++ , nCont ) } )
	If nCont > 1
		Aviso(STR0011,STR0014,{"Ok"})	//"Atencao"###"Codigo de Curso ja foi selecionado anteriormente."
		lRet := .F.
	Endif

	If Empty(aCols[n,nPosCur]) .And. lRet
		Aviso(STR0011,STR0015,{"Ok"})	//"Atencao"###"Codigo de Curso deve ser preenchido."
	   	lRet := .F.
	Endif
EndIf

Return lRet


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �Tr210Grava� Autor � Emerson Grassi Rocha  � Data � 02/09/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravacao dos Dados da Funcao                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aCurCar                                  		          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TrmA210                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function Tr210Grava(nOpcx)
Local ny 		:= 0
Local nx		:= 0
Local nt 		:= 0
Local nI		:= 0
Local lTravou	:= .F.
Local lContinua := .T.
Local aAlias	:= {"SRJ","RAL"}
Local bCampo    := { |nCPO| Field(nCPO) }
Local nPosRec	:= GdfieldPos("RAL_REC_WT")
Local nRALCurso := GdFieldPos("RAL_CURSO")
Local lTSREP	:= SuperGetMv( "MV_TSREP" , NIL , .F. )
Local lRet		:= .T.
Local lSemFilial := .F.
Local cData      := cValToChar( StrZero( Month(dDataBase), 2 ) ) + cValToChar( Year(dDataBase))
Local cAnoMes    := cValToChar( Year(dDataBase)) + "-" + cValToChar( StrZero( Month(dDataBase), 2 ) )
Local cFuncao    := ""
Local cDescr     := ""
Local cCBO       := ""
Local cCampos	 := ""
Local nOperation := nOpcx
Local cStatus    := ""
Local cFilEnv    := ""
Local aErros     := {}
Local aCposVal	 := {}
Local aFilInTaf  := {}
Local aArrayFil  := {}

Private oObjREP	:= Nil

//----------------------------------
//| E X T E M P O R � N E O  S-1030
//----------------------------------
//Se a integra��o estiver ativa e n�o for consist�ncia de tabela

IF (nOpcx == 4 .OR. nOpcx == 3) .AND. (M->RJ_DESC == SRJ->RJ_DESC .And. M->RJ_CODCBO == SRJ->RJ_CODCBO)
	lIntegTAF := .F.
EndIf

If lIntTAF .AND. lIntegTAF .And. ( IIF(FindFunction("fChkFMat"),lRet:=fChkFMat("S-1030"),.T.)) .And. cVersEnvio < "9.0"

	If M->(ColumnPos( 'RJ_ACUM' )) > 0 .And. !Empty( M->RJ_ACUM )
		aAdd(aCposVal, M->RJ_ACUM )
		aAdd(aCposVal, M->RJ_CTESP )
		aAdd(aCposVal, M->RJ_DEDEXC )
		aAdd(aCposVal, M->RJ_LEI )
		aAdd(aCposVal, M->RJ_DTLEI )
		aAdd(aCposVal, M->RJ_SIT )
	EndIf

	If aScan( aCposVal, { |x| !Empty(x) } ) > 0

		If aScan( aCposVal, { |x| Empty(x) } ) > 0

			lContinua := .F.
			lRet	  := .F.

			If Empty(M->RJ_ACUM)
				cCampos := cCampos + Iif(Len(cCampos)>0,", ","") + "RJ_ACUM"
			Endif
			If Empty(M->RJ_CTESP)
				cCampos := cCampos + Iif(Len(cCampos)>0,", ","") + "RJ_CTESP"
			Endif
			If Empty(M->RJ_DEDEXC)
				cCampos := cCampos + Iif(Len(cCampos)>0,", ","") + "RJ_DEDEXC"
			Endif
			If Empty(M->RJ_LEI)
				cCampos := cCampos + Iif(Len(cCampos)>0,", ","") + "RJ_LEI"
			Endif
			If Empty(M->RJ_DTLEI)
				cCampos := cCampos + Iif(Len(cCampos)>0,", ","") + "RJ_DTLEI"
			Endif
			If Empty(M->RJ_SIT)
				cCampos := cCampos + Iif(Len(cCampos)>0,", ","") + "RJ_SIT"
			Endif

			Aviso(OemToAnsi(STR0011), OemToAnsi(STR0027) + cCampos, {"Ok"})

		Endif

	Endif

	IF lContinua
		//Verificando vers�o do GPE
		lIntegra := Iif(FindFunction("fVersEsoc"), fVersEsoc("S-1030", .F., /*@aRetGPE*/, /*@aRetTAF*/, @cVersEnvio,@cVersGPE), .F. )

		//Identificando Filial de Envio
		fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)
		If Empty(cFilEnv)
			cFilEnv:= cFilAnt
		EndIf

		//Tratamento de compartilhamento da tabela SRJ
		If Empty( xFilial("SRJ") )
			lSemFilial := .T.
		EndIf

		//Montando as variaveis utilizadas na chave de pesquisa
		cFuncao := IIf(lSemFilial, AllTrim( M->RJ_FUNCAO ), AllTrim(xFilial("SRJ") + M->RJ_FUNCAO ) )
		cDescr  := AllTrim( M->RJ_DESC )
		cCBO    := M->RJ_CODCBO
		cChave  := cFuncao + ";" + cData

		//-------------------------------------------------
		//| Fun��o centralizadora para gerar Extempor�neos
		//| Extempor�neo S-1035: GY_CODIGO + MMAAAA
		//-------------------------------------------------
		nOperation := fVerExtemp( If(lCargSQ3,"S-1040","S-1030"), cChave, nOperation, @cStatus )

		//-------------------------------------------------
		//| Baseado no evento de retorno, geramos o nOpc
		//| nOpc ir� variar de 3 <inclusao>, 4 <alteracao> e 5 <exclusao>
		//----------------------------------------------------------------
		If ( nOperation > 0 )
			//Realizando integra��o do evento
			lRet := fCarrFun( cFuncao, cDescr, cCBO, nOperation, cAnoMes,@aErros,cFilEnv,aCposVal, lCargSQ3 )

			If( !lRet )
				MsgAlert(aErros[1],OemToAnsi(STR0011))//##"Aten��o"

			ElseIf FindFunction("fEFDMsg") .AND. lRet
				fEFDMsg()
			EndIf
		Else
			MsgAlert(OemToAnsi(STR0019),OemToAnsi(STR0011)) //##Aten��o##Problema na integra��o com TAF.
			lRet := .F.
		EndIf

		If(!lRet)
			Return .F.
		Endif
	ENDIF
Endif


//-- Inicializa a integracao via WebServices TSA
If lTSREP
	oObjREP := PTSREPOBJ():New()
EndIF

For nt:=1 To Len(aAlias)
	If nt == 1
		//-- FUNCAO
		dbSelectArea("SRJ")
		RecLock("SRJ",IIf(nOpcx#3, .F., .T.))
			For nI := 1 To FCount()
				If "_FILIAL"$Field(ni)
					FieldPut(nI,cFilial)
				ElseIf "RJ_DESCREQ"$Field(ni)	// Grava campos Memo
					MSMM(RJ_DESCREQ	,,,M->RJ_MEMOREQ,1,,,"SRJ","RJ_DESCREQ")
				Else
					FieldPut(nI,M->&(EVAL(bCampo,nI)))
				EndIf
			Next nI
		MsUnlock()

		If lTSREP
			/*/
			��������������������������������������������������������������Ŀ
			� Executa o WebServices TSA - Funcoes                          �
			����������������������������������������������������������������*/
			If oObjREP:WSPositionLevel( If(nOpcx == 1,1,2) )

				/*/
				��������������������������������������������������������������Ŀ
				� Grava o Log do controle de exportacao WebServices TSA        �
				����������������������������������������������������������������*/
				oObjRep:WSUpdRHExp( "SRJ" )

			Endif
		Endif

		Loop
	ElseIf nt == 2 .And. cModulo <> "TRM"	//-- Cursos da FUNCAO
		Loop
	EndIf

	dbSelectArea("RAL")
	For nx := 1 to Len(aCols)
        //-- Questiona se existe conteudo de curso informado na GetDados (aCols)
	    IF Empty(aCols[nx][nRALCurso])
	       Loop
	    Endif

	    Begin Transaction
			If aCols[nx][nPosRec]>0
				MsGoto(aCols[nX][nPosRec])
				RecLock("RAL",.F.)
				lTravou:=.T.
			Else
			    If !(aCols[nX][Len(aCols[nX])])
					RecLock("RAL",.T.)
					lTravou:=.T.
				EndIf
			EndIf
			If lTravou
				//--Verifica se esta deletado
				If aCols[nX][Len(aCols[nX])]
					dbDelete()
		        Else
					Replace RAL->RAL_FILIAL 	WITH xFilial("RAL")
					Replace RAL->RAL_FUNCAO	 	WITH cFuncao1
				EndIf
				For nY := 1 To Len(aHeader)
					If aHeader[nY][10] <> "V"
						RAL->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
					EndIf
				Next nY
				MsUnlock()
				lTravou:= .F.
			EndIf
		End Transaction
	Next nx
Next nt

Return .T.


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �Tr210Dele � Autor � Emerson Grassi Rocha  � Data � 02/09/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravacao dos Dados da Funcao                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cChave			                                          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TrmA210                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function Tr210Dele()

Local lChkDelOk := .T.
Local lTSREP	:= SuperGetMv( "MV_TSREP" , NIL , .F. )
Private oObjREP	:= Nil

//-- Inicializa a integracao via WebServices TSA
If lTSREP
	oObjREP := PTSREPOBJ():New()
EndIF

dbSelectArea("SRJ")
If dbSeek(cChave)
	lChkDelOk  := ChkDelRegs(	"SRJ"	,;	//01 -> Alias do Arquivo Principal
								Nil		,;	//02 -> Registro do Arquivo Principal
								Nil		,;	//03 -> Opcao para a AxDeleta
								Nil		,;	//04 -> Filial do Arquivo principal para Delecao
								Nil		,;	//05 -> Chave do Arquivo Principal para Delecao
								Nil		,;	//06 -> Array contendo informacoes dos arquivos a serem pesquisados
								NIL		,;	//07 -> Mensagem para MsgYesNo
								NIL		,;	//08 -> Titulo do Log de Delecao
								NIL		,;	//09 -> Mensagem para o corpo do Log
								Nil		,;	//10 -> Se executa AxDeleta
								Nil		,;	//11 -> Se deve Mostrar o Log
								Nil		,;	//12 -> Array com o Log de Exclusao
								Nil		,;	//13 -> Array com o Titulo do Log
								NIL		,;	//14 -> Bloco para Posicionamento no Arquivo
								NIL		,;	//15 -> Bloco para a Condicao While
								NIL		,;	//16 -> Bloco para Skip/Loop no While
								.T.		,;	//17 -> Verifica os Relacionamentos no SX9
								{"RAL"}	;	//18 -> Alias que nao deverao ser Verificados no SX9
						    )

	If !lChkDelOk
		Return Nil
	Endif

    // Cursos da Funcao
	dbSelectArea("RAL")
	If dbSeek(cChave)
		While !Eof() .And. cChave == RAL->RAL_FILIAL+RAL->RAL_FUNCAO
			RecLock("RAL",.F.)
				dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	EndIf

    // Funcao
   	dbSelectArea("SRJ")
	While !Eof() .And. cChave == SRJ->RJ_FILIAL+SRJ->RJ_FUNCAO
		MSMM(SRJ->RJ_DESCREQ,,,,2)
		RecLock("SRJ",.F.)
			dbDelete()
		MsUnlock()

	   	If lTSREP
			/*/
			��������������������������������������������������������������Ŀ
			� Executa o WebServices TSA - Funcoes                          �
			����������������������������������������������������������������*/
			oObjREP:WSPositionLevel( 3 )

		Endif

		dbSkip()
	EndDo

EndIf
Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 � Tr210Linha	� Autor � Emerson Grassi 	� Data � 02/09/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se a primeira linha esta toda sem preencher		  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias											  ���
���			 � ExpN1 : Registro											  ���
���			 � ExpN2 : Opcao											  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � TRMA210		 �											  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tr210Linha()
Local lTree		:= .T.
Local nx		:= 0
Local nPosAlias	:= GdFieldPos("RAL_ALI_WT")
Local nPosRec  	:= GdFieldPos("RAL_REC_WT")

For nx := 1 To Len(aHeader)
	If !Empty(aCols[1][nx]) .and.  nx <> nPosAlias .and. nx <> nPosRec  //Exceto campos:  Alias WT  e Recno WT
		lTree := .F.
		Exit
	EndIf
Next nx
Return lTree


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �fTr210Desc� Autor � Emerson Grassi Rocha  � Data � 02/09/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Trazer as Descricoes dos campos Virtuais e Inic.Padrao     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� (cAlias,cCpoRet,cCodPesq,lRelac)							  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TRMA210                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function fTr210Desc(cAlias,cCpoRet,cCodPesq,lRelac)
Local aSaveArea := GetArea()
Local cPesq 	:= ""
Local nPosHead	:= 0
Local nPos		:= 0
Local cRet		:= ""
Local lRet		:= .F.

Private cConteudo := ""

cPesq := If (lRelac,cCodPesq,ReadVar())

nPosHead := GdFieldPos(cPesq)
If nPosHead > 0
	cConteudo := aCols[Len(aCols),nPosHead]
Elseif ! lRelac
	cConteudo := &(ReadVar())
Endif

If "CURSO"$ AllTrim(cPesq)
	cRet := TrmDesc(cAlias,cConteudo,"RA1->RA1_DESC")
EndIf

If ! lRelac
	//--Igualar no Acols o Descricao
	nPos := GdFieldPos(cCpoRet)
	If nPos > 0
		aCols[n,nPos] := cRet
		lRet := .T.
	EndIf
Else
	lRet := cRet
EndIf

RestArea(aSaveArea)

Return(lRet)

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �TrmSx3Curso�Autor  �Tania Bronzeri      � Data � 15/12/2006  ���
��������������������������������������������������������������������������͹��
���Desc.     �Busca descricao do Curso para Get Dados                      ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �SIGATRM                                                      ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function TrmSx3Curso()
Local nPos	:= GdFieldPos("RAL_CURSO")
Local cRet	:= ""

If Len(aCols)>0 .And. Empty(aCols[Len(aCols)][nPos])
	cRet	:= CriaVar("RA1_DESC",.f.)
Else
	cRet	:= TrmDesc("RA1",RAL->RAL_CURSO,"RA1->RA1_DESC")
EndIf

Return cRet


/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �15/01/2007�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �TRMA210                                                     �
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
//�    6 - Alteracao sem inclusao de registro                    �
//����������������������������������������������������������������
Local aRotina :=  { 	{ STR0002	,"PesqBrw",  0 , 1,,.F.},;	//"PESQUISAR"
						{ STR0003	,"TRM210Rot", 0 , 2},;	//"VISUALIZAR"
						{ STR0004	,"TRM210Rot", 0 , 3},;	//"INCLUIR"
						{ STR0005	,"TRM210Rot", 0 , 4},;	//"ALTERAR"
						{ STR0006	,"TRM210Rot", 0 , 5},;	//"EXCLUIR"
						{ STR0016	,"TRM210Rot", 0 , 6} }	//"COPIAR"
Return aRotina
/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � TRMA210COPIA   �Autor� MOHANAD ODEH      � Data �29/12/2011�
�����������������������������������������������������������������������Ĵ
�Descri��o �COPIA DADOS DO REGISTRO SELECIONADO                         �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �TRMA210COPIA(NOPCX)      									�
�����������������������������������������������������������������������Ĵ
� Uso      �TRMA210                                                     �
�����������������������������������������������������������������������Ĵ
�Parametros�  NOPCX = NUMERO DA OPCAO									�
�������������������������������������������������������������������������*/
Function TRMA210Copia(nOpcx)
Local ny 		:= 0
Local nx		:= 0
Local nt 		:= 0
Local nI		:= 0
Local lTravou	:= .F.
Local aAlias	:= {"SRJ","RAL"}
Local bCampo    := { |nCPO| Field(nCPO) }
Local nPosRec	:= GdfieldPos("RAL_REC_WT")
Local nRALCurso := GdFieldPos("RAL_CURSO")

If nOpcx == 5 .OR. nOpcx == 2 // SE EXCLUSAO OU VISUALIZACAO
	Return .T.
EndIf


For nt:=1 To Len(aAlias)
	If nt == 1
		//-- FUNCAO
		DBSELECTAREA("SRJ")
		RecLock("SRJ", .T.)
			For nI := 1 To FCount()
				If "_FILIAL"$Field(ni)
					FieldPut(nI,cFilial)
				ElseIf "RJ_DESCREQ"$Field(ni)	// GRAVA CAMPOS MEMO
					MSMM(RJ_DESCREQ	,,,M->RJ_MEMOREQ,1,,,"SRJ","RJ_DESCREQ")
				ElseIf "RJ_FUNCAO"$Field(ni)
					FieldPut(nI,M->RJ_FUNCAO)
				Else
					FieldPut(nI,M->&(EVAL(bCampo,nI)))
				EndIf
			Next nI
		MsUnlock()
		Loop
	ElseIf nt == 2 .And. cModulo <> "TRM"	// CURSOS DA FUNCAO
		Loop
	EndIf

	DBSELECTAREA("RAL")
	For nx := 1 to Len(aCols)
        // QUESTIONA SE EXISTE CONTEUDO DE CURSO INFORMADO NA GETDADOS (ACOLS)
	    IF Empty(aCols[nx][nRALCurso])
	       Loop
	    Endif

	    Begin Transaction
			If aCols[nx][nPosRec]>0
				MsGoto(aCols[nX][nPosRec])
				RecLock("RAL",.F.)
				lTravou:=.T.
			Else
			    If !(aCols[nX][Len(aCols[nX])])
					RecLock("RAL",.T.)
					lTravou:=.T.
				EndIf
			EndIf
			If lTravou
				// VERIFICA SE ESTA DELETADO
				If aCols[nX][Len(aCols[nX])]
					dbDelete()
		        Else
					Replace RAL->RAL_FILIAL 	WITH xFilial("RAL")
					Replace RAL->RAL_FUNCAO	 	WITH cFuncao1
				EndIf
				For nY := 1 To Len(aHeader)
					If aHeader[nY][10] <> "V"
						RAL->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
					EndIf
				Next nY
				MsUnlock()
				lTravou:= .F.
			EndIf
		End Transaction
	Next nx
Next nt

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TRMA210   �Autor  �Microsiga           � Data �  11/11/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function f210Linok()
Local lRet := .F.

lRet := TrR5LiOk()

Return( lRet )


/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � TRMA210Val   �Autor� MOHANAD ODEH      � Data �24/01/2012  �
�����������������������������������������������������������������������Ĵ
�Descri��o �Valida campo RJ_FUNCAO                                      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �TRMA210Val()      									�
�����������������������������������������������������������������������Ĵ
� Uso      �TRMA210                                                     �
�����������������������������������������������������������������������Ĵ
�Parametros�  M->RJ_FUNCAO Codigo da Funcao 							�
�������������������������������������������������������������������������*/
Function TRMA210Val(cFuncao)
Local lRet := .T.

If FunName() == "TRMA210" // S� verifica se fun��o que chamar for TRMA210
	If lCopy
		// Verifica se o c�digo digitado � o mesmo que o copiado para evitar erro de inser��o com a duplicidade
		If cFuncao == cCodFunc
			Help("", 1, "JAGRAVADO")
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � fAltVer   �Autor� Marco Nakazawa      � Data �17/12/2018   �
�����������������������������������������������������������������������Ĵ
���Descri��o � Fun��o para verificar se houve altera��es em campos 	   ��
�� utilizados pelo E-Social                                            ���
�����������������������������������������������������������������������Ĵ
�Sintaxe   fAltVer()      									   		    �
�����������������������������������������������������������������������Ĵ
� Uso      �TRMA210                                                     �
�������������������������������������������������������������������������*/
Function fAltVer(aArrCPO,cTab)
Local lRet	:= .F.
Local nX		:= 0

For nX:= 1 to Len(aArrCPO)
	If &(cTab+"->"+aArrCPO[nX]) != &("M->" + aArrCPO[nX]) .And. !lRet
		lRet	:= .T.
	EndIf
Next nX
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldAtiv()
Fun��o que efetua a verifica��o se h� funcion�rios ativos vinculados � fun��o
@author  Allyson Luiz Mesashi
@since   28/04/2022
/*/
//-------------------------------------------------------------------
Static Function fVldAtiv( cCodFunc )

Local cAliasQRY	:= "QRYSRA"
Local cQuery	:= ""
Local cTabSRA	:= RetSqlName("SRA")
Local cTabSRJ	:= RetSqlName("SRJ")
Local lTemAtiv	:= .F.

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + cTabSRJ + " SRJ "
cQuery 	+= "INNER JOIN " + cTabSRA + " SRA "
cQuery 	+= "ON " + FWJoinFilial( "SRJ", "SRA" ) + " AND SRA.RA_CODFUNC = SRJ.RJ_FUNCAO AND SRA.RA_SITFOLH != 'D' AND SRA.D_E_L_E_T_ = ' ' " 
cQuery 	+= "WHERE SRJ.RJ_FILIAL = '" + xFilial("SRJ") + "' "
cQuery 	+= "AND SRJ.RJ_FUNCAO = '" + cCodFunc + "' "
cQuery 	+= "AND SRJ.D_E_L_E_T_ = ' ' "

dbUseArea(.T., "TOPCONN", TcGenQry( Nil, Nil, cQuery), cAliasQRY, .T., .T.)

lTemAtiv := (cAliasQRY)->CONT > 0

(cAliasQRY)->( dbCloseArea() )

Return lTemAtiv
