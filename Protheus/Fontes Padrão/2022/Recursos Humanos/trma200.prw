#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TRMA200.CH"

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun��o       � TRMA200  � Autor � Emerson Grassi Rocha    � Data � 05/08/01 ���
������������������������������������������������������������������������������Ĵ��
���Descri��o    � Agenda de Funcionarios para Realizacao de Testes.            ���
������������������������������������������������������������������������������Ĵ��
���Uso          � TRMA200                                                      ���
������������������������������������������������������������������������������Ĵ��
���Programador  � Data     � BOPS �  Motivo da Alteracao                       ���
������������������������������������������������������������������������������Ĵ��
���Cecilia Car. �21.07.2014�TPZSOX�Incluido o fonte da 11 para a 12 e efetuada ���
���             �          �      �a limpeza.                                  ���
���Renan Borges �05.01.2015�TREMH6�Ajuste para montagem de avalia��es de acordo���
���             �          �      �com a quantidade de quest�es, pr�-determina-���
���             �          �      �da pelo tamanho do campo QQ_ITEM.           ���
���Thiago Y.M.N �02/02/2015�TRJHV0�Ajuste para agendar as avalia��es correta-  ���
���             �          �	  �mente, tanto quando houver a inclus�o de um ���
���             �          �	  �registro quanto na altera��o.               ���
���Flavio Correa�15/01/2016�PCREQ-9275�Envio de email agenda de avalia��o      ���
���Raquel Hager �13/06/2016�TUMZE9�Ajuste nas fun��es RAJQuemWhen/RAJMatAvaWhen���
���Oswaldo L   �01/03/17�DRHPONTP-9�Nova funcionalidade de tabelas temporarias ���
���Eduardo K.   �04/04/2017�MPRIMESP-9562� Ajuste na montagem da legenda       ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/
Function TRMA200

LOCAL cFiltra	:= ""		//Variavel para filtro
LOCAL aIndFil	:= {}		//Variavel Para Filtro
LOCAL nErro	:= 0
LOCAL aCores	:= {}

Private aAvFields	:= {} //campos exibidos em tela a serem avaliados pelo gerenciamento de dados sensiveis
Private aPDFields	:= {} //campos que estao classificados como dados sensiveis

Private nX			:= 0
Private nPos		:= 0

Private bFiltraBrw := {|| Nil}		//Variavel para Filtro
Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemtoAnsi(STR0004)		//"Agenda de Funcionarios para Testes"
//��������������������������������������������������������������Ŀ
//� Consiste o Modo de Acesso dos Arquivos                       �
//����������������������������������������������������������������
nErro := 0
nErro += Iif(xRetModo("SRA","RAI",.T.),0,1)
nErro += Iif(xRetModo("SRA","RAJ",.T.),0,1)
If nErro > 0
	Return
EndIF

//������������������������������������������������������������������������Ŀ
//� Inicializa o filtro utilizando a funcao FilBrowse                      �
//��������������������������������������������������������������������������
dbSelectArea("RA2")
dbSetOrder(1)

cFiltra 	:= CHKRH(FunName(),"RA2","1")
bFiltraBrw 	:= {|| FilBrowse("RA2",@aIndFil,@cFiltra) }
Eval(bFiltraBrw)

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
dbSelectArea("RA2")
dbGoTop()

aCores  := { 	{ "RA2->RA2_REALIZ != 'S'",'BR_VERDE' 	},;
				{ "(RA2->RA2_REALIZA == 'S' .And. RA2->RA2_EFICAC =='A') .or. (RA2->RA2_REALIZA == 'S' .And. empty(RA2->RA2_EFICAC))",'DISABLE' 	},;
				{ "RA2->RA2_REALIZ == 'S' .And. RA2->RA2_EFICAC =='S'",'BR_AZUL'	} }

mBrowse( 6, 1, 22, 75, "RA2" ,,,,,, aCores)

//������������������������������������������������������������������������Ŀ
//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
//��������������������������������������������������������������������������
EndFilBrw("RA2",aIndFil)

dbSelectArea("RA3")
dbSetOrder(1)

dbSelectArea("RAK")
dbSetOrder(1)

dbSelectArea("RA2")
dbSetOrder(1)

dbSelectArea("SRA")
dbSetOrder(1)

dbSelectArea("RAJ")
dbSetOrder(1)

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Tr200Rot  � Autor � Emerson Grassi Rocha � Data � 05/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta a Reserva de treinamentos                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
���          � ExpN1 : Registro                                           ���
���          � ExpN2 : Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TRMA200       �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tr200Rot(cAlias,nReg,nOpcx)

Local oDlgMain, oGroup, oBtn1, oBtn2, oBtn3, oBmp1, oBmp2, oBmp3
Local cCurso		:= RA2->RA2_CURSO
Local cTurma		:= RA2->RA2_TURMA
Local cCalend 		:= RA2->RA2_CALEND
Local cDescCalend	:= RA2->RA2_DESC
Local cDescCurso	:= CriaVar("RA1_CURSO")
Local c1Lbx			:= ""
Local lTrDel		:= If(nOpcx=2.Or.nOpcx=5,.F.,.T.)

//��������������������������������������������������������������Ŀ
//� Variaveis para Dimensionar Tela		                         �
//����������������������������������������������������������������
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aLbxCoord		:= {}
Local aGDCoord		:= {}

//��������������������������������������������������������������Ŀ
//� Variaveis para criacao da GetDados WalkThru                  �
//����������������������������������������������������������������
Local aNoFields 	:= {"RAJ_FILIAL","RAJ_MAT","RAJ_NOME","RAJ_CALEND","RAJ_CURSO ","RAJ_TURMA"}
Local cCond		:= "RAJ_FILIAL + RAJ_CALEND + RAJ_CURSO + RAJ_TURMA + RAJ_MAT"
Local nRajOrd	:=	RetOrdem("RAJ",cCond)

Local bSeekWhile	:= {|| RAJ->RAJ_FILIAL+RAJ->RAJ_CALEND+RAJ->RAJ_CURSO+RAJ->RAJ_TURMA+RAJ->RAJ_MAT }
Local cSeekKey		:= ""
Local aHeaderAux	:= {}
Local aColsAux		:= {}
Local lGrava		:=	.F.
Local nX, nPos		:= 0

Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T. , .F.}) //[1] Acesso; [2]Ofusca
Local aOfuscaCpo	:= {}

// Private da Getdados
Private aCols  	:= {}
Private aHeader	:= {}
Private Continua:=.F.
Private oGet, oSay1

Private o1Lbx
Private nAtAnt	:= 1
Private cArq1	:= ""
Private cArqNtx	:= ""
Private aGuarda	:= {}
Private cSay	:= ""
Private nPosAnt	:= 1
Private cTr1Alias := GetNextAlias()
Private oTmpTabFO1
// MV_PAR01    	- Ordem 1-Nome 2-Matricula 3-Centro Custo 4-Funcao
// MV_PAR02		- Filial De
// MV_PAR03		- Filial Ate
// MV_PAR04		- Matricula de
// MV_PAR05		- Matricula ate
// MV_PAR06		- Centro Custo de
// MV_PAR07		- Centro Custo ate
// MV_PAR08		- Funcao de
// MV_PAR09		- Funcao ate
// MV_PAR10    	- Status Funcionario
// MV_PAR11   	- Ferias Programadas

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
Pergunte("TRM200",.F.)

// Curso
dbSelectArea("RA1")
dbSetOrder(1)
If dbSeek(xFilial("RA1")+cCurso)
	cDescCurso := RA1->RA1_DESC
EndIf

// Monta os dados dos ListBox
If RA2->RA2_REALIZ != "S"  		// Treinamento em Aberto
	If !Tr200Monta()
		Help("",1,"TR200NOFUN")		// Nao existem funcionarios reservados para este curso
		Return Nil
	EndIf
Else                                // Treinamento baixado
	If !Tr200Mont2()
		Help("",1,"TR200NOFUN")		// Nao existem funcionarios reservados para este curso
		Return Nil
	EndIf
EndIf

dbSelectArea(cTr1Alias)
dbGotop()
While !Eof()
	cSeekKey 	:= (cTr1Alias)->(TR1_FILIAL)+cCalend+cCurso+cTurma+(cTr1Alias)->(TR1_MAT)
	aHeaderAux	:={}
	aColsAux	:={}

	//==> Cria aHeader e aCols para WalkThru
	FillGetDados(4						,; //1-nOpcx - n�mero correspondente � opera��o a ser executada, exemplo: 3 - inclus�o, 4 altera��o e etc;
				 "RAJ"					,; //2-cAlias - area a ser utilizada;
				 nRajOrd				,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
				 cSeekKey				,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
				 bSeekWhile				,; //5-bSeekWhile - bloco contendo a express�o a ser comparada com cSeekKey na condi��o  do While.
				 NIL					,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-c�digo, condi��o a ser utilizado para executar o Loop no While;2� - array bi-dimensional contendo N.. condi��es, em que o 1� elemento � o bloco condicional, o 2� � bloco a ser executado se verdadeiro e o 3� � bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
				 aNoFields				,; //7-aNoFields - array contendo os campos que n�o estar�o no aHeader;
				 NIL					,; //8-aYesFields - array contendo somente os campos que estar�o no aHeader;
				 NIL					,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usu�rio;
				 NIL					,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
				 NIL					,; //11-bMontCols - bloco contendo fun��o especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}
				 NIL					,; //12-lEmpty � Caso True ( default � false ), inicializa o aCols com somente uma linha em branco ( como exemplo na inclus�o).
				 aHeaderAux				,; //13-aHeaderAux, eh Caso necessite tratar o aheader e acols como vari�veis locais ( v�rias getdados por exemplo; uso da MSNewgetdados )
				 aColsAux				)  //14-aColsAux eh Caso necessite tratar o aheader e acols como vari�veis locais ( v�rias getdados por exemplo; uso da MSNewgetdados )

	If Len(aHeader)=0
		aHeader	:= aClone(aHeaderAux)
	EndIf

	dbSelectArea(cTr1Alias)
	aAdd(aGuarda,{(cTr1Alias)->(TR1_FILIAL),(cTr1Alias)->(TR1_MAT),aClone(aColsAux)})

	dbSkip()
EndDo

dbSelectArea(cTr1Alias)
dbGotop()

// Monta o acols conforme o funcionario posicionado
Tr200Troca((cTr1Alias)->(TR1_FILIAL),(cTr1Alias)->(TR1_MAT),.T.)

/*
��������������������������������������������������������������Ŀ
� Monta as Dimensoes dos Objetos         					   �
����������������������������������������������������������������*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

aLbxCoord		:= { (aObjSize[1,1]+20), (aObjSize[1,2]+4)	, (aObjSize[1,3]-24)	, (aObjSize[1,4] /2 -4 ) }
aGDCoord		:= { (aObjSize[1,1]+20), (aObjSize[1,4]/2 + 2), (aObjSize[1,3]+7)		, (aObjSize[1,4]) }

DEFINE MSDIALOG oDlgMain FROM	aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cCadastro OF oMainWnd  PIXEL

	@ aObjSize[1,1]+5,aObjSize[1,2]+7 	SAY OemToAnsi(STR0005)	PIXEL			//"Calend�rio: "
	@ aObjSize[1,1]+5,aObjSize[1,2]+45 	SAY cCalend	+ " - " + cDescCalend PIXEL //
	@ aObjSize[1,1]+5,aObjSize[1,2]+140 SAY OemToAnsi(STR0006) PIXEL			//Curso: "
	@ aObjSize[1,1]+5,aObjSize[1,2]+160 SAY cCurso + " - " + cDescCurso PIXEL 	//
	@ aObjSize[1,1]+5,aObjSize[1,2]+280 SAY OemToAnsi(STR0007) PIXEL			//Turma: "
	@ aObjSize[1,1]+5,aObjSize[1,2]+300 SAY cTurma PIXEL // 18,300

	@ aLbxCoord[1], aLbxCoord[2] LISTBOX o1Lbx VAR c1Lbx FIELDS;
		 	 HEADER OemtoAnsi(STR0008),;			//"Fil."
					OemtoAnsi(STR0009),;			//"Nome"
					OemtoAnsi(STR0010),;			//"Matricula"
					OemtoAnsi(STR0011),;			//"Centro Custo"
					OemtoAnsi(STR0012),;			//"Descr. Centro Custo"
					OemtoAnsi(STR0013),;			//"Fun��o "
					OemtoAnsi(STR0014);				//"Descr. Fun��o"
				COLSIZES 	GetTextWidth(0, Replicate("B", FWGETTAMFILIAL)),;
							GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"),;
							GetTextWidth(0,"BBBBBB"),;
							GetTextWidth(0,"BBBBBBBBB"),;
							GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"),;
							GetTextWidth(0,"BBBB"),;
							GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB") SIZE aLbxCoord[4], aLbxCoord[3] OF oDlgMain PIXEL;
	ON CHANGE (Iif(Tr200Ok(), 	Tr200Troca((cTr1Alias)->(TR1_FILIAL),(cTr1Alias)->(TR1_MAT),.F.),;
								((cTr1Alias)->(dbGoTo(nAtAnt)), o1Lbx:Refresh()) ))

	o1Lbx:bLine:= {||{	(cTr1Alias)->(TR1_FILIAL),;
						(cTr1Alias)->(TR1_NOME),;
						(cTr1Alias)->(TR1_MAT),;
						(cTr1Alias)->(TR1_CC),;
						(cTr1Alias)->(TR1_DESCCC),;
						(cTr1Alias)->(TR1_FUNCAO),;
						(cTr1Alias)->(TR1_DESCFUN)}}


	//Prote��o de Dados Sens�veis
	If aOfusca[2]
		aOfuscaCpo := {.F.,.F.,.F.,.F.,.F.,.F.,.F.}
		aAvFields  := {"RA_FILIAL","RA_NOME","RA_MAT","RA_CC","RA_DESCCC","RA_CODFUNC","RA_DESCFUN"}
		aPDFields  := FwProtectedDataUtil():UsrNoAccessFieldsInList( aAvFields ) // CAMPOS SEM ACESSO
		o1Lbx:lObfuscate := .T.
		For nX := 1 to Len(aAvFields)
			IF aScan( aPDFields , { |x| x:CFIELD == aAvFields[nx] } ) > 0
				aOfuscaCpo[nx] := .T.
			ENDIF
		Next nX
		o1Lbx:aObfuscatedCols := aOfuscaCpo
	EndIf

	// Controle da Getdados
	@ aGdCoord[1]+10, aGdCoord[2]+5 	SAY  STR0009+": " OF oDlgMain PIXEL					//"Nome: "
	@ aGdCoord[1]+10, aGdCoord[2]+25 	SAY oSay1 PROMPT cSay OF oDlgMain PIXEL SIZE 100,7

	@ aGdCoord[1],aGdCoord[2] GROUP oGroup  TO aGdCoord[3],aGdCoord[4] OF oDlgMain PIXEL
	oGet := MSGetDados():New(aGdCoord[1]+20,aGdCoord[2]+5,aGdCoord[3]-5,aGdCoord[4]-5,nOpcx,"Tr200Ok","AlwaysTrue","",lTrDel,,1, ,900,,,,,oDlgMain)
	oGet:oBrowse:bAdd := {|| Tr200NewLin(.F.)}

ACTIVATE MSDIALOG oDlgMain ON INIT (EnchoiceBar(oDlgMain,{||(If(Tr200Ok(@lGrava),( (aGuarda[nPosAnt][3] := Aclone(aCols)),oDlgMain:End()),Nil)) },{|| oDlgMain:End()},,;
												 	{{"GROUP",{||Tr200Colet(aCols) },;
            						                OemToAnsi(STR0017),OemToAnsi(STR0019)}})) //"Agendamento Coletivo"#"Agendar"
If ( lGrava )
	Tr200Grava(cCalend,cCurso,cTurma)
EndIf

dbSelectArea(cTr1Alias)
dbCloseArea()


If oTmpTabFO1 <> Nil
    oTmpTabFO1:Delete()
    Freeobj(oTmpTabFO1)
EndIf

dbSelectArea("RA2")
dbSetOrder(1)
dbGoto(nReg)

Return(Nil)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Tr200Monta� Autor � Emerson Grassi Rocha � Data � 05/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta os listbox da reserva dos treinamentos               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tr200Monta(ExpC1,ExpC2,ExpC3)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
���          � ExpC2 : Codigo do Curso                                    ���
���          � ExpC3 : Codigo da Turma                                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TRMA200       �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tr200Monta()

Local cDescCC	:= ""
Local cDescFunc	:= ""
Local lOk 		:= .F.
Local cSituacao := MV_PAR10
Local nFerProg  := MV_PAR11
Local cSitFol   := ""
Local aAreaRA2	:= {}

// Cria arquivos temporarios para o Listbox
Tr200CriaArq()

dbSelectArea("RA3")
dbSetOrder(2)
dbSeek(MV_PAR02 + RA2->RA2_CALEND,.T.)
While !Eof() .And. RA3->RA3_FILIAL >= MV_PAR02 .And. 	RA3->RA3_FILIAL <= MV_PAR03

	If 	RA3->RA3_CURSO 	# RA2->RA2_CURSO	.Or.;
	    RA3->RA3_CALEND	# RA2->RA2_CALEND 	.Or.;
		RA3->RA3_TURMA 	# RA2->RA2_TURMA 	.Or.;
		RA3->RA3_MAT 	< MV_PAR04 			.Or.;
		RA3->RA3_MAT 	> MV_PAR05 			.Or.;
		RA3->RA3_RESERV != "R"
		dbSkip()
		Loop
	EndIf

	aAreaRA2	:= RA2->( GetArea() )
	RA2->(dbSetOrder(1))
	dbSelectArea("RA2")
	If( dbSeek(xFilial("RA2")+RA3->RA3_CALEND+RA3->RA3_CURSO+RA3->RA3_TURMA) )
		dbSelectArea("SRA")
		dbSetOrder(1)
		If ( dbSeek(RA3->RA3_FILIAL+RA3->RA3_MAT) )

			//��������������������������Ŀ
			//� Situacao do Funcionario  �
			//����������������������������
			cSitFol := TrmSitFol()

			If (!(cSitfol $ cSituacao) 	.And.	(cSitFol <> "P")) .Or.;
				(cSitfol == "P" .And. nFerProg == 2)   .Or.;
			    SRA->RA_CC 		< 	MV_PAR06	.Or.;
				SRA->RA_CC 		> 	MV_PAR07  	.Or.;
				SRA->RA_CODFUNC	< 	MV_PAR08 	.Or.;
				SRA->RA_CODFUNC	> 	MV_PAR09

				dbSelectArea("RA3")
				dbSkip()
				Loop
			EndIf

			// Montando o ListBox 1
			cDescCC		:= FDesc("CTT",SRA->RA_CC,"CTT->CTT_DESC01",30)
			cDescFunc	:= FDesc("SRJ",SRA->RA_CODFUNC,"SRJ->RJ_DESC",30)

			lOk := .T.

			RecLock(cTr1Alias,.T.)
			(cTr1Alias)->(TR1_FILIAL)		:= SRA->RA_FILIAL
			(cTr1Alias)->(TR1_NOME)			:= SRA->RA_NOME
			(cTr1Alias)->(TR1_MAT)			:= SRA->RA_MAT
			(cTr1Alias)->(TR1_CC)			:= SRA->RA_CC
			(cTr1Alias)->(TR1_DESCCC)		:= cDescCC
			(cTr1Alias)->(TR1_FUNCAO)		:= SRA->RA_CODFUNC
			(cTr1Alias)->(TR1_DESCFUN)		:= cDescFunc
			MsUnlock()
		EndIf
	EndIf
	RA2->(RestArea(aAreaRA2))
	dbSelectArea("RA3")
	dbSkip()
EndDo

If !lOK
	dbSelectArea(cTr1Alias)
	dbCloseArea()

	If oTmpTabFO1 <> Nil
	    oTmpTabFO1:Delete()
	    Freeobj(oTmpTabFO1)
	EndIf

	dbSelectArea("RA3")
	dbSetOrder(1)
EndIf
Return lOk


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Tr200Mont2� Autor � Emerson Grassi Rocha � Data � 12/08/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta os listbox para Eficacia dos treinamentos            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tr200Mont2(ExpC1,ExpC2,ExpC3)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
���          � ExpC2 : Codigo do Curso                                    ���
���          � ExpC3 : Codigo da Turma                                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TRMA200       �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tr200Mont2()

Local cDescCC	:= ""
Local cDescFunc	:= ""
Local lOk 		:= .F.
Local cSituacao	:= MV_PAR10
Local nFerProg 	:= MV_PAR11
Local cSitFol  	:= ""

// Cria arquivos temporarios para o Listbox
Tr200CriaArq()

dbSelectArea("RAK")
dbSetOrder(1)
dbSeek(MV_PAR02 + RA2->RA2_CALEND,.T.)
While !Eof() .And. RAK->RAK_FILIAL >= MV_PAR02 .And. 	RAK->RAK_FILIAL <= MV_PAR03

	If 	RAK->RAK_CURSO 	# RA2->RA2_CURSO 	.Or.;
	    RAK->RAK_CALEND	# RA2->RA2_CALEND 	.Or.;
		RAK->RAK_TURMA 	# RA2->RA2_TURMA 	.Or.;
		RAK->RAK_MAT 	< MV_PAR04 			.Or.;
		RAK->RAK_MAT 	> MV_PAR05

		dbSkip()
		Loop
	EndIf

	dbSelectArea("SRA")
	dbSetOrder(1)
	dbSeek(RAK->RAK_FILIAL+RAK->RAK_MAT)

	//��������������������������Ŀ
	//� Situacao do Funcionario  �
	//����������������������������
	cSitFol := TrmSitFol()

	If (!(cSitfol $ cSituacao) 	.And.	(cSitFol <> "P")) .Or.;
		(cSitfol == "P" .And. nFerProg == 2) .Or.;
	   	SRA->RA_CC 		< 	MV_PAR06  	.Or.;
		SRA->RA_CC 		> 	MV_PAR07  	.Or.;
		SRA->RA_CODFUNC	< 	MV_PAR08 	.Or.;
		SRA->RA_CODFUNC	> 	MV_PAR09

		dbSelectArea("RAK")
		dbSkip()
		Loop
	EndIf

	// Montando o ListBox 1
	cDescCC		:= FDesc("CTT",SRA->RA_CC,"CTT->CTT_DESC01",30)
	cDescFunc	:= FDesc("SRJ",SRA->RA_CODFUNC,"SRJ->RJ_DESC",30)

	lOk := .T.

	RecLock(cTr1Alias,.T.)
	(cTr1Alias)->(TR1_FILIAL)		:= SRA->RA_FILIAL
	(cTr1Alias)->(TR1_NOME)			:= SRA->RA_NOME
	(cTr1Alias)->(TR1_MAT)			:= SRA->RA_MAT
	(cTr1Alias)->(TR1_CC)			:= SRA->RA_CC
	(cTr1Alias)->(TR1_DESCCC)		:= cDescCC
	(cTr1Alias)->(TR1_FUNCAO)		:= SRA->RA_CODFUNC
	(cTr1Alias)->(TR1_DESCFUN)		:= cDescFunc
	MsUnlock()

	dbSelectArea("RAK")
	dbSkip()
EndDo

If !lOK
	dbSelectArea(cTr1Alias)
	dbCloseArea()

	If oTmpTabFO1 <> Nil
	    oTmpTabFO1:Delete()
	    Freeobj(oTmpTabFO1)
	EndIf


	dbSelectArea("RAK")
	dbSetOrder(1)
EndIf
Return lOk


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tr200Grava� Autor � Emerson Grassi Rocha  � Data � 06/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Grava os registros referente agenda de Testes.              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Calendario                                         ���
���          � ExpC2 : Curso                                              ���
���          � ExpC3 : Turma                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �TRMA200                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
�����������������������������������������������������������������������������*/
Static Function Tr200Grava(cCalend,cCurso,cTurma)

Local nx		:= 0
Local ny		:= 0
Local nz		:= 0
Local nPosRAJ	:= 0
Local nPosTeste	:= GdFieldPos("RAJ_TESTE")
Local nPosModel	:= GdFieldPos("RAJ_MODELO")
Local nPosRec	:= GdfieldPos("RAJ_REC_WT")
Local nPosData	:= GdFieldPos("RAJ_DATA")
Local lAchou	:= .F.
Local lTravou	:= .F.

dbSelectArea("RAJ")
dbSetOrder(1)

For nx := 1 To Len(aGuarda)
	aColsAux	:= aClone(aGuarda[nx][3])
	For ny := 1 To Len(aColsAux)

	    Begin Transaction
			If (nPosTeste > 0 .And. !Empty(aColsAux[ny][nPosTeste])) .Or. ;
				(nPosModel > 0 .And. !Empty(aColsAux[ny][nPosModel]))

				If lAchou := ( aColsAux[ny,nPosRec] <> 0 )	// Se RECNO for maior 0 significa que registro j� existia, se n�o, � um registro novo a ser incluido.
					RAJ->( dbGoTo(aColsAux[ny,nPosRec]) )
					RecLock("RAJ",.F.)
					lTravou:=.T.
				Else
				    If !(aColsAux[ny][Len(aColsAux[ny])])
						lTravou:=.T.
					EndIf
				EndIf
				If lTravou
					//--Verifica se esta deletado
					If aColsAux[ny][Len(aColsAux[ny])]
						RAJ->(dbDelete())
			        Else
			           If !lAchou
			            	RecLock("RAJ",.T.)
			            	RAJ->RAJ_FILIAL:= aGuarda[nx][1]
							RAJ->RAJ_MAT:= aGuarda[nx][2]
							RAJ->RAJ_CURSO:= cCurso
							RAJ->RAJ_TURMA := cTurma
							RAJ->RAJ_CALEND	:= cCalend

						Else
				  		 	RAJ->RAJ_FILIAL:= aGuarda[nx][1]
							RAJ->RAJ_MAT:= aGuarda[nx][2]
							RAJ->RAJ_CURSO:= cCurso
							RAJ->RAJ_TURMA := cTurma
							RAJ->RAJ_CALEND	:= cCalend
						Endif

					EndIf

					For nz := 1 To Len(aHeader)
						If aHeader[nz][10] <> "V"
							RAJ->(FieldPut(FieldPos(aHeader[nz][2]),aColsAux[ny][nz]))
						EndIf
					Next nz

					If RAJ->RAJ_OK <> "S"
			           If RAJ->(ColumnPos("RAJ_EMAIL")) > 0
                          If SendMail()
						     RAJ->RAJ_EMAIL := "1"
                          EndIf
                       EndIf
					EndIf

					lTravou := .F.
				EndIf

			EndIf
			MsUnlock()
		End Transaction
	Next ny
	If RAJ->(DbSeek(aGuarda[nx][1]+cCalend+cCurso+cTurma+aGuarda[nx][2]))
	   	cChave:= RAJ->RAJ_FILIAL + RAJ->RAJ_CALEND + RAJ->RAJ_CURSO + RAJ->RAJ_TURMA + RAJ->RAJ_MAT
	   	While RAJ->RAJ_FILIAL + RAJ->RAJ_CALEND + RAJ->RAJ_CURSO + RAJ->RAJ_TURMA + RAJ->RAJ_MAT == cChave .AND. !(RAJ->(EOF()))
	   		If (nPosRAJ:=aScan(aColsAux,{|x| x[nPosData] == RAJ->RAJ_DATA })) == 0
	   			RecLock("RAJ",.F.)
				RAJ->(dbDelete())
				RAJ->(MsUnlock())
			Endif
			RAJ->(dbSkip())
		EndDo
	EndIf
Next nx

Return .T.

Static Function SendMail()
//Local aArea		:= GetArea()
Local cMat		:= ""
Local cMsg		:= ""
Local cCurso	:= ""
Local lRet 		:= .F.
Local cEmail	:= ""

If Empty(RAJ->RAJ_EMAIL) .Or. RAJ->RAJ_EMAIL == "2" //1=ja enviado;2=nao enviado
	dbSelectArea("SRA")
	SRA->(dbSetOrder(1))

	If RAJ->RAJ_QUEM =="1" //1=funcionario/2=avaliador
		cMat := RAJ->RAJ_MAT
	Else
		cMat := RAJ->RAJ_MATAVA
	EndIf
	If SRA->(dbSeek(RAJ->RAJ_FILIAL+cMat))
		cEMail := SRA->RA_EMAIL
		If !Empty(cEmail)
			If !Empty(RAJ->RAJ_TESTE)
				cCurso := Alltrim(FDESC("SQQ",RAJ->RAJ_TESTE,"QQ_DESCRIC"))
			Else
				cCurso := Alltrim(FDESC("SQW",RAJ->RAJ_TESTE,"QW_DESCRIC"))
			EndIf
			cMsg := STR0033 + " <br><br>" //Aten��o
 			cMsg += STR0034 + cCurso + " <br><br>" + Chr(10)+Chr(13) //"Foi agendada uma avalia��o referente ao Curso "

 			If RAJ->RAJ_QUEM == "2" //Eficacia
 				cMsg += STR0040 + " <br>" + Chr(10)+Chr(13)//"Avalia��o de Efic�cia "
 				cMsg += STR0039 + RAJ->RAJ_MAT + " - " + Alltrim(Posicione("SRA",1,RAJ->RAJ_FILIAL+RAJ->RAJ_MAT,"RA_NOME")) +" <br>" + Chr(10)+Chr(13)//"Avaliado :"
 			EndIf
 			If Empty(RAJ->RAJ_DATAF)
 				cMsg += STR0035 + Dtoc(RAJ->RAJ_DATA) + " <br>" + Chr(10)+Chr(13)//"Data : "
 				cMsg += STR0036 + RAJ->RAJ_HORA + "hs." + " <br>" + Chr(10)+Chr(13)//"Hor�rio :  "
 			Else
 				cMsg += STR0035 + Dtoc(RAJ->RAJ_DATA) + " - " + Dtoc(RAJ->RAJ_DATAF)  + " <br>" + Chr(10)+Chr(13)//"Data : "
 				cMsg += STR0036 + RAJ->RAJ_HORA + "hs." + " - " + RAJ->RAJ_HORAF  + "hs <br>" + Chr(10)+Chr(13)//"Hor�rio :  "
 			EndIf
 			cMsg += "<br> <br>" + Chr(10)+Chr(13)
 			cMsg += STR0037 + "<br>" + Chr(10)+Chr(13)//"Para realizar a prova favor acessar o Portal RH.
 			cMsg += "<br> <br>" + Chr(10)+Chr(13)
			cMsg += "Att."  + Chr(10)+Chr(13)
			lRet := gpeMail(STR0038,cMsg,cEmail)//"Aviso de avalia��o"

		EndIf
	EndIf
EndIf

//RestArea(aArea)
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tr200Perg � Autor � Emerson Grassi Rocha  � Data � 05/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Chamada dos parametros no arotina                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �TRMA200                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tr200Perg()
Pergunte("TRM200",.T.)
Return .t.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tr200Troca� Autor � Emerson Grassi Rocha  � Data � 06/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao que troca o acols conforme a posicao do funcionario  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �TRMA200                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tr200Troca(cAuxFil,cMat,l1Vez)
Local lOfuscaNom 	:= .F.
Local nPos			:=	Ascan(aGuarda,{|x| x[1]+x[2]== cAuxFil+cMat })
Local aFldRot 		:= {'RA_NOME'}
Local aFldOfusca 	:= {}
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T. , .F.}) //[1] Acesso; [2]Ofusca

If aOfusca[2]
	aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot ) // CAMPOS SEM ACESSO
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0 
		lOfuscaNom	:= FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
	ENDIF
EndIf

cSay := If(lOfuscaNom,Replicate('*',15),(cTr1Alias)->(TR1_NOME))

If nPos > 0
	If !l1Vez
		aGuarda[nPosAnt][3]	:= Aclone(aCols)
	Endif
	aCols				:= {}
	aCols 				:= Aclone(aGuarda[nPos][3])
	n					:= Len(aCols)
	nPosAnt				:= nPos
EndIf

If !l1Vez
	oGet:ForceRefresh()
	oSay1:Refresh()
EndIf

nAtAnt := (cTr1Alias)->(Recno())

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tr200CriaArq� Autor � Emerson Grassi Rocha� Data � 06/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao que controla a criacao do arquivo temporario         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 : Posicao nao marcada                                ���
���          � ExpN2 : Posicao nao marcada                                ���
���          � ExpN3 : Posicao marcada                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �TRMA200                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tr200CriaArq()
Local a1Stru	:= {}
Local cCond		:= ""
Local aLstIndices := {}

Aadd(a1Stru, {"TR1_FILIAL", "C", FWGETTAMFILIAL,          0                       } )
Aadd(a1Stru, {"TR1_NOME",   "C", TamSx3("RA_NOME")[1],    TamSx3("RA_NOME")[2]    } )
Aadd(a1Stru, {"TR1_MAT",    "C", TamSx3("RA_MAT")[1],     TamSx3("RA_MAT")[2]     } )
Aadd(a1Stru, {"TR1_CC",     "C", TamSx3("RA_CC")[1],      TamSx3("RA_CC")[2]      } )
Aadd(a1Stru, {"TR1_DESCCC", "C", TamSx3("CTT_DESC01")[1], TamSx3("CTT_DESC01")[2] } )
Aadd(a1Stru, {"TR1_FUNCAO", "C", TamSx3("RA_CODFUNC")[1], TamSx3("RA_CODFUNC")[2] } )
Aadd(a1Stru, {"TR1_DESCFU", "C", TamSx3("RJ_DESC")[1],    TamSx3("RJ_DESC")[2]    } )

//Ordem 1-Nome 2-Matricula 3-Centro Custo 4-Funcao


If MV_PAR01 == 1				// Nome
	Aadd( aLstIndices,{"TR1_FILIAL","TR1_NOME"} )
ElseIf MV_PAR01 == 2			// Matricula
	Aadd( aLstIndices,{"TR1_FILIAL","TR1_MAT"} )
ElseIf MV_PAR01 == 3			// Centro de Custo
	Aadd( aLstIndices,{"TR1_FILIAL","TR1_CC"} )
ElseIf MV_PAR01 == 4			// Funcao
	Aadd( aLstIndices,{"TR1_FILIAL","TR1_FUNCAO"} )
EndIf

oTmpTabFO1 := RhCriaTrab(cTr1Alias, a1Stru, aLstIndices)

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Tr200Ok    � Autor � Emerson Grassi Rocha� Data � 06/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao executada na linha Ok da getdados                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tr200Ok                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TRMA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tr200Ok(lGrava)
Local nPosTeste	:= 0
Local nPosModelo:= 0
Local nPosData 	:= 0
Local nPosHora 	:= 0
Local nPosDataF	:= 0
Local nPosHoraF	:= 0
Local nPosQuem	:= 0
Local nPosMat	:= 0
Local lRet		:= .T.
Local nx		:= 0
Local cTipoTeste:= ""

nPosTeste	:= GdFieldPos("RAJ_TESTE")
nPosModelo	:= GdFieldPos("RAJ_MODELO")
nPosData 	:= GdFieldPos("RAJ_DATA")
nPosHora 	:= GdFieldPos("RAJ_HORA")
nPosQuem	:= GdFieldPos("RAJ_QUEM")
nPosMat		:= GdFieldPos("RAJ_MATAVA")
nPosDataF 	:= GdFieldPos("RAJ_DATAF")
nPosHoraF 	:= GdFieldPos("RAJ_HORAF")

If Len(aCols) == 1 .And. Empty(aCols[1][nPosTeste]) .And. Empty(aCols[1][nPosModelo])
	Return .T.
EndIf

If !aCols[n,Len(aCols[n])]
	If (	(nPosTeste 	> 0 .And. Empty(aCols[n][nPosTeste])) 	.And.;
			(nPosModelo	> 0 .And. Empty(aCols[n][nPosModelo]))) 	.Or. ;
			(nPosData 	> 0 .And. Empty(aCols[n][nPosData])) 		.Or. ;
			(nPosHora 	> 0 .And. Empty(aCols[n][nPosHora]))		.Or. ;
			(nPosDataF 	> 0 .And. Empty(aCols[n][nPosDataF])) 		.Or. ;
			(nPosHoraF	> 0 .And. Empty(aCols[n][nPosHoraF]))		.Or. ;
			(nPosQuem	> 0 .And. Empty(aCols[n][nPosQuem]))

		Help(" ",1,"TR200VAZIO")	// Verifica o codigo do Teste ou Modelo, Data e Hora nao podem estar vazio
		lRet:= .F.
	EndIf
	If lRet
		For nx := 1 To Len(aCols)
			If ((nPosTeste 	> 0 .And. aCols[n][nPosTeste]	== aCols[nx][nPosTeste]	.And. !Empty(aCols[n][nPosTeste])) 	.Or.;
				(nPosModelo	> 0 .And. aCols[n][nPosModelo]	== aCols[nx][nPosModelo]  	.And. !Empty(aCols[n][nPosModelo])))	.And.;
				(nPosData 	> 0 .And. aCols[n][nPosData]	== aCols[nx][nPosData]) 	.And.;
				!aCols[nx][Len(aCols[nx])] .And.	n # nx

				Help(" ",1,"TR200EXIS")	// Este Teste ja foi lancado anteriormente.
				lRet:= .F.
				Exit
			EndIf

			//Validacao do Campo RAJ_MATAVAR
			If	nPosQuem > 0 .And. aCols[n][nPosQuem] == "1" .And. nPosMat > 0 .And. !Empty(aCols[n][nPosMat])
				Aviso(OemToAnsi(STR0024), OemToAnsi(STR0025), {"Ok"})	//"Atencao"###'Quando o campo "Realizado Por" estiver preenchido com "1-Funcionario", o "Avaliador" nao deve ser Preenchido.'
				lRet:= .F.
				Exit
			EndIf

			If nPosQuem > 0 .And. aCols[n][nPosQuem] == "2" .And. nPosMat > 0 .And.  Empty(aCols[n][nPosMat])
				Aviso(OemToAnsi(STR0024), OemToAnsi(STR0028), {"Ok"})	//"Atencao"###'Quando o campo "Realizado Por" estiver preenchido com "2-Outros", o "Avaliador" deve ser Preenchido.'
				lRet:= .F.
				Exit
			EndIf

			If nPosData > 0 .And. nPosDataF > 0  .And.  !GpeChkData(aCols[n][nPosData] , aCols[n][nPosDataF] )
				lRet:= .F.
				Exit
			EndIf

			If nPosData > 0 .And. nPosDataF > 0  .ANd. nPosHora > 0 .And. nPosHoraF > 0 .And.  aCols[n][nPosData] == aCols[n][nPosDataF]  .And.  aCols[n][nPosHoraF] <= aCols[n][nPosHora]
				Aviso(OemToAnsi(STR0024), OemToAnsi(STR0041), {"Ok"})	//"Atencao"###'"Hora final deve ser maior que hora inicial"
				lRet:= .F.
				Exit
			EndIf

			//��������������������������������������������������������������Ŀ
			//� *Avaliacao do Tipo EFI = vinculada a Outros e Avaliador      �
			//� *Outros Tipos de Avaliacao  = vinculada ao Funcion�rio       �
			//����������������������������������������������������������������
			If nPosTeste > 0
				cTipoTeste := TrmDesc("SQQ",aCols[n][nPosTeste],"SQQ->QQ_TIPO")

				If !Empty(cTipoTeste)
					If cTipoTeste == 'EFI' .And. aCols[n][nPosQuem] <> "2"
						Aviso(OemToAnsi(STR0024), OemToAnsi(STR0029), {"Ok"})	//"Para avalia��o do tipo 'EFI' opte por 'Outros' na coluna 'Realiza. por' e vincule ao Avaliador"
						lRet:= .F.
						Exit
					EndIf

					If cTipoTeste <> 'EFI' .And. aCols[n][nPosQuem] <> "1"
						Aviso(OemToAnsi(STR0024), OemToAnsi(STR0030), {"Ok"})	//"Para esta avalia��o opte por 'Funcion�rio' na coluna 'Realiza. por'"
						lRet:= .F.
						Exit
					EndIf
				EndIf
			EndIf

			If nPosModelo > 0
				cTipoteste := TrmDesc("SQW",aCols[n][nPosModelo],"SQW->QW_TIPO")
				If !Empty(cTipoTeste)
					If cTipoTeste == 'EFI' .And. aCols[n][nPosQuem] <> "2"
						Aviso(OemToAnsi(STR0024), OemToAnsi(STR0029), {"Ok"})	//"Para avalia��o do tipo 'EFI' opte por 'Outros' na coluna 'Realiza. por' e vincule ao Avaliador"
						lRet:= .F.
						Exit
					EndIf

					If cTipoTeste <> 'EFI' .And. aCols[n][nPosQuem] <> "1"
						Aviso(OemToAnsi(STR0024), OemToAnsi(STR0030), {"Ok"})	//"Para esta avalia��o opte por 'Funcion�rio' na coluna 'Realiza. por'"
						lRet:= .F.
						Exit
					EndIf
				EndIf
			EndIf

		Next nx
	EndIf
EndIf

If ( lRet )
	lGrava	:=	.T.
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Tr200Leg      � Autor �Emerson Grassi    � Data � 01.03.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Aciona Legenda de cores da Mbrowse.				          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tr200Leg()		                                          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TRMA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tr200Leg()

	BrwLegenda(cCadastro,STR0001, {{"ENABLE"		, OemToAnsi(STR0021)},; //"Em aberto"
									{"BR_VERMELHO"	, OemToAnsi(STR0022)},; //"Encerrado "
									{"BR_AZUL"		, OemToAnsi(STR0023)}}) //"Aguardando Aval. Eficacia"

Return(Nil)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Tr200Desc     � Autor �Emerson Grassi    � Data � 06/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Descricao do Teste ou Modelo.							  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tr200Desc()			                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TRMA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tr200Desc()
Local aSaveArea := GetArea()
Local cRetorno  := ""
Local nPosTeste	:= GdFieldPos("RAJ_TESTE")
Local nPosModel := GdFieldPos("RAJ_MODELO")
Local nPosDesc	:= GdFieldPos("RAJ_DESCRI")
Local cVar		:= Alltrim((ReadVar()))
Local cTipoTeste:= ""

If nPosDesc > 0 .And. nPosTeste > 0 .And. nPosModel > 0
	If cVar == "M->RAJ_TESTE"
		cTipoTeste := TrmDesc("SQQ",M->RAJ_TESTE,"SQQ->QQ_TIPO")
		If RA2->RA2_EFICAC == 'S' .And.  cTipoTeste<>'EFI'
			Aviso(OemtoAnsi(STR0024),OemToAnsi(STR0026),{"OK"}) //"Atencao"#"Para esta avaliacao deve ser informado teste do tipo Eficacia 'EFI'.", )
			lRet := .F.
		ElseIf RA2->RA2_EFICAC <> 'S' .And.  cTipoTeste=='EFI'
			Aviso(OemtoAnsi(STR0024),OemToAnsi(STR0027),{"OK"}) //"Atencao"#"Para esta avaliacao nao sao considerados os testes do tipo Eficacia 'EFI'.)
			lRet := .F.
		Else
			If !Empty(&cVar)
				cRetorno 			:= TrmDesc("SQQ",M->RAJ_TESTE,"SQQ->QQ_DESCRIC")
				aCols[n][nPosDesc] := cRetorno
				aCols[n][nPosModel]:= Space(04)
			EndIf
			lRet := .T.
		Endif

	ElseIf cVar == "M->RAJ_MODELO"
		cTipoteste := ""
		cTipoteste := TrmDesc("SQW",M->RAJ_MODELO,"SQW->QW_TIPO")
		If RA2->RA2_EFICAC == 'S' .And.  cTipoTeste<>'EFI'
			Aviso(OemtoAnsi(STR0024),OemToAnsi(STR0026),{"OK"}) //"Atencao"#"Para esta avaliacao deve ser informado teste do tipo Eficacia 'EFI'.", )
			lRet := .F.
		ElseIf RA2->RA2_EFICAC <> 'S' .And.  cTipoTeste=='EFI'
			Aviso(OemtoAnsi(STR0024),OemToAnsi(STR0027),{"OK"}) //"Atencao"#"Para esta avaliacao nao sao considerados os testes do tipo Eficacia 'EFI'.)
			lRet := .F.
		Else
			If !Empty(&cVar)
				cRetorno 			:= TrmDesc("SQW",M->RAJ_MODELO,"SQW->QW_DESCRIC")
				aCols[n][nPosDesc] := cRetorno
				aCols[n][nPosTeste]:= Space(03)
			EndIf
			lRet := .T.
		EndIf
	EndIf
EndIf
RestArea(aSaveArea)

Return(lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Tr200Colet    � Autor �Emerson Grassi    � Data � 29/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Agendamento de Teste coletivo.							  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tr200Colet()			                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TRMA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Tr200Colet(aCols)

Local nRecTr1 	:= (cTr1Alias)->(RECCOUNT())
Local i			:= 0
Local n			:= 0
Local x			:= 0
Local nPosRec	:= GdfieldPos("RAJ_REC_WT")
Local aAltAge	:= {}

If msgYesNo(STR0018) //"Confirma a copia de Agenda do primeiro candidato para os demais ?"
	If ( aCols[1] == aGuarda[1,3] )
		aAltAge := aClone(aGuarda[1][3])
	Else
		aAltAge	:= aClone(aCols)
	EndIf

	For i := 2 To nRecTr1
	 	If Len(aGuarda[i][3]) == len(aGuarda[1][3])
			For n := 1 To len(aGuarda[1][3])
			   	For x:= 1 To len (aGuarda[1][3][n])
  					If aGuarda[i][3][n][x] <> aAltAge[1][x]
						aGuarda[i][3][n][x] := aAltAge[1][x]
		            Endif
		        Next x
		    Next n
		ElseIF Len(aGuarda[i][3]) < len(aGuarda[1][3])
			For n := 1 To len(aGuarda[i][3])
			   	For x:= 1 To len (aGuarda[1][3][n])
					If aGuarda[i][3][n][x] <> aAltAge[1][x]
						aGuarda[i][3][n][x] := aAltAge[1][x]
		            Endif
		        Next x
		    Next n

		   	For n := n To len(aGuarda[1][3])
				aSize(aGuarda[i][3],len(aGuarda[1][3]))
				aGuarda[i][3][n] := {} // Necess�rio tipar o Sub-N�vel para ser usado no aSize
				aSize(aGuarda[i][3][n],len(aGuarda[1][3][n]))
					For x := 1 To len (aGuarda[1][3][n])
						aGuarda[i][3][n][x] := aAltAge[n][x]
					Next x
			Next n
		Else
			For n := 1 To len(aGuarda[1][3])
			   	For x:= 1 To len (aGuarda[1][3][n])
					If aGuarda[i][3][n][x] <> aAltAge[1][x]
						aGuarda[i][3][n][x] := aAltAge[1][x]
		            Endif
		        Next x
		    Next n
		    aSize(aGuarda[i][3],len(aGuarda[1][3]))
	   	Endif
	Next i
EndIf
Return(.T.)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Tr200NomAval  � Autor �Emerson Grassi    � Data � 16/09/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Nome do Avaliador.										  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tr200NomAval()		                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TRMA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tr200NomAval()
Local aSaveArea := GetArea()
Local nPosMat	:= GdFieldPos("RAJ_MATAVA")
Local nPosNome 	:= GdFieldPos("RAJ_NOMAVA")
Local nPosQuem	:= GdFieldPos("RAJ_QUEM")

Local lOfuscaNom 	:= .F.
Local aFldRot 		:= {'RA_NOME'}
Local aFldOfusca 	:= {}
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T. , .F.}) //[1] Acesso; [2]Ofusca

If aOfusca[2]
	aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot ) // CAMPOS SEM ACESSO
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0 
		lOfuscaNom	:= FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
	ENDIF
EndIf

If nPosQuem > 0 .And. aCols[n][nPosQuem] == "1" .And. !Empty(M->RAJ_MATAVA)
	Aviso(STR0024, STR0025, {"Ok"})	//"Atencao"###'Quando o campo "Realizado Por" estiver preenchido com "1-Funcionario", o "Avaliador" nao deve ser Preenchido.'
	Return .F.
EndIf

If nPosMat > 0 .And. nPosNome > 0

	If !Empty(M->RAJ_MATAVA)
		aCols[n][nPosNome] := TrmDesc("SRA",M->RAJ_MATAVA,"SRA->RA_NOME")
		aCols[n][nPosNome] := If(lOfuscaNom,Replicate('*',15),aCols[n][nPosNome])
	Else
		aCols[n][nPosNome]	:= Space(30)
	EndIf

EndIf
RestArea(aSaveArea)

Return .T.


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � SqqSxbFilt� Autor � Eduardo Ju           � Data � 04/07/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Filtro de Consulta Padrao do SQQ                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �<Vide Parametros Formais>									  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�<Vide Parametros Formais>									  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Consulta Padrao (SXB)                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function SqqSxbFilt()

Local cRet:= ""
Local nTamItem	:= (TamSx3("QQ_ITEM")[1])

If cModulo == "TRM"
	cRet := "@#SQQ->QQ_ITEM=='"+ STRZERO(1,nTamItem)+"'" + Iif(RA2->RA2_EFICAC == 'S', " .And. SQQ->QQ_TIPO=='EFI'@#"," .And. SQQ->QQ_TIPO<>'EFI'@#")
Else
	cRet := "@#SQQ->QQ_ITEM=='"+ STRZERO(1,nTamItem)+"'@#"
EndIf

Return( cRet )

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � SqwSxbFilt� Autor � Eduardo Ju           � Data � 04/07/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Filtro de Consulta Padrao do SQW                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �<Vide Parametros Formais>									  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�<Vide Parametros Formais>									  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Consulta Padrao (SXB)                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function SqwSxbFilt()

Local cRet:= ""

cRet := "@#SQW->QW_SEQ=='01'" + Iif(RA2->RA2_EFICAC == 'S', " .And. SQW->QW_TIPO=='EFI'@#"," .And. SQW->QW_TIPO<>'EFI'@#")

Return( cRet )

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RAJSX3INIT � Autor � Eduardo Ju           � Data � 05.07.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao do campo RAJ_DESCRI no SX3 (X3_RELACAO).          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Trma200                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function RAJSX3INIT()

Local aSaveArea := GetArea()
Local cRetorno  := ""

If !Empty(RAJ->RAJ_TESTE)
	cRetorno := FDESC("SQQ",RAJ->RAJ_TESTE,"QQ_DESCRIC")
ElseIf !Empty(RAJ->RAJ_MODELO)
	cRetorno := FDESC("SQW",RAJ->RAJ_MODELO,"QW_DESCRIC")
Else
	cRetorno := ""
EndIf

RestArea(aSaveArea)

Return cRetorno


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MatAvalInit� Autor � Eduardo Ju           � Data � 05.07.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao do campo RAJ_NOMAVA no SX3 (X3_RELACAO).          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Trma200                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function MatAvalInit()

Local aSaveArea := GetArea()
Local cRetorno  := ""

Local lOfuscaNom 	:= .F.
Local aFldRot 		:= {'RA_NOME'}
Local aFldOfusca 	:= {}
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T. , .F.}) //[1] Acesso; [2]Ofusca

If aOfusca[2]
	aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot ) // CAMPOS SEM ACESSO
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0 
		lOfuscaNom	:= FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
	ENDIF
EndIf

If !Empty(RAJ->RAJ_MATAVA)
	cRetorno := TrmDesc("SRA",RAJ->RAJ_MATAVA,"SRA->RA_NOME")
	cRetorno := If(lOfuscaNom,Replicate('*',15),cRetorno)
Else
	cRetorno := ""
EndIf

RestArea(aSaveArea)

Return cRetorno


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tr200NewLin  � Autor � Eduardo Ju         � Data � 06/07/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Nova linha para getdados                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 					                                          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TRMA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function Tr200NewLin(lFirst)

Local nPosDesc := GdFieldPos("RAJ_DESCRI")
Local nPosNome 	:= GdFieldPos("RAJ_NOMAVA")

If !lFirst
	Eval( {|| oGet:LCHGFIELD := .F., oGet:ADDLINE() } )
EndIf

If nPosDesc > 0
	aCols[n][nPosDesc] := ""
	aCols[n][nPosNome] := ""
EndIf

Return .T.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RAJCursoInit � Autor � Leandro Dr.        � Data � 30/12/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Inicializa campo RAJ_CURSO                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 					                                          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TRMA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function RAJCursoInit()
Local cRet := ""

If !Empty(RA2->RA2_CURSO)
	cRet := RA2->RA2_CURSO
EndIf

Return cRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RAJCursoVld  � Autor � Leandro Dr.        � Data � 30/12/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida campo RAJ_CURSO                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 					                                          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TRMA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function RAJCursoVld()
Local lRet := .F.

If ( Empty(RA2->RA2_CURSO) .or. RA2->RA2_CURSO == RAJ->RAJ_CURSO )
	lRet := .T.
EndIf

Return lRet


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RAJMatAvaWhen� Autor � Leandro Dr.        � Data � 29/12/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida when do campo RAJ_QUEM                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 					                                          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TRMA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function RAJQuemWhen()
Local lRet := .F.

If 	!Empty(M->RAJ_QUEM)
	lRet := .T.
EndIf

Return lRet
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RAJQuemWhen  � Autor � Leandro Dr.        � Data � 29/12/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida when do campo RAJ_MATAVA                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 					                                          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TRMA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function RAJMatAvaWhen()
Local lRet := .F.

If RA2->RA2_EFICAC == "S"
		lRet := .T.
EndIf

Return lRet
/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �21/12/2006�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �TRMA200                                                     �
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
Local aRotina :=   {	{ STR0001,'PesqBrw'		, 0,1,,.F.},;	//"Pesquisar"
						{ STR0002,'Tr200Perg'	, 0,3},;	//"Para&metros"
						{ STR0003,'Tr200Rot'	, 0,4},;	//"Agendar"
						{ STR0016,'Tr200Leg'	, 0,2, ,.F.}}	//"Legenda"

Return aRotina
