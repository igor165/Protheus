#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TRMA200.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o       ³ TRMA200  ³ Autor ³ Emerson Grassi Rocha    ³ Data ³ 05/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o    ³ Agenda de Funcionarios para Realizacao de Testes.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso          ³ TRMA200                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data     ³ BOPS ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car. ³21.07.2014³TPZSOX³Incluido o fonte da 11 para a 12 e efetuada ³±±
±±³             ³          ³      ³a limpeza.                                  ³±±
±±³Renan Borges ³05.01.2015³TREMH6³Ajuste para montagem de avaliações de acordo³±±
±±³             ³          ³      ³com a quantidade de questões, pré-determina-³±±
±±³             ³          ³      ³da pelo tamanho do campo QQ_ITEM.           ³±±
±±³Thiago Y.M.N ³02/02/2015³TRJHV0³Ajuste para agendar as avaliações correta-  ³±±
±±³             ³          ³	  ³mente, tanto quando houver a inclusão de um ³±±
±±³             ³          ³	  ³registro quanto na alteração.               ³±±
±±³Flavio Correa³15/01/2016³PCREQ-9275³Envio de email agenda de avaliação      ³±±
±±³Raquel Hager ³13/06/2016³TUMZE9³Ajuste nas funções RAJQuemWhen/RAJMatAvaWhen³±±
±±³Oswaldo L   ³01/03/17³DRHPONTP-9³Nova funcionalidade de tabelas temporarias ³±±
±±³Eduardo K.   ³04/04/2017³MPRIMESP-9562³ Ajuste na montagem da legenda       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemtoAnsi(STR0004)		//"Agenda de Funcionarios para Testes"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Consiste o Modo de Acesso dos Arquivos                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nErro := 0
nErro += Iif(xRetModo("SRA","RAI",.T.),0,1)
nErro += Iif(xRetModo("SRA","RAJ",.T.),0,1)
If nErro > 0
	Return
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RA2")
dbSetOrder(1)

cFiltra 	:= CHKRH(FunName(),"RA2","1")
bFiltraBrw 	:= {|| FilBrowse("RA2",@aIndFil,@cFiltra) }
Eval(bFiltraBrw)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RA2")
dbGoTop()

aCores  := { 	{ "RA2->RA2_REALIZ != 'S'",'BR_VERDE' 	},;
				{ "(RA2->RA2_REALIZA == 'S' .And. RA2->RA2_EFICAC =='A') .or. (RA2->RA2_REALIZA == 'S' .And. empty(RA2->RA2_EFICAC))",'DISABLE' 	},;
				{ "RA2->RA2_REALIZ == 'S' .And. RA2->RA2_EFICAC =='S'",'BR_AZUL'	} }

mBrowse( 6, 1, 22, 75, "RA2" ,,,,,, aCores)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr200Rot  ³ Autor ³ Emerson Grassi Rocha ³ Data ³ 05/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta a Reserva de treinamentos                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA200       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr200Rot(cAlias,nReg,nOpcx)

Local oDlgMain, oGroup, oBtn1, oBtn2, oBtn3, oBmp1, oBmp2, oBmp3
Local cCurso		:= RA2->RA2_CURSO
Local cTurma		:= RA2->RA2_TURMA
Local cCalend 		:= RA2->RA2_CALEND
Local cDescCalend	:= RA2->RA2_DESC
Local cDescCurso	:= CriaVar("RA1_CURSO")
Local c1Lbx			:= ""
Local lTrDel		:= If(nOpcx=2.Or.nOpcx=5,.F.,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Dimensionar Tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aLbxCoord		:= {}
Local aGDCoord		:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para criacao da GetDados WalkThru                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	FillGetDados(4						,; //1-nOpcx - número correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
				 "RAJ"					,; //2-cAlias - area a ser utilizada;
				 nRajOrd				,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
				 cSeekKey				,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
				 bSeekWhile				,; //5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
				 NIL					,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-código, condição a ser utilizado para executar o Loop no While;2º - array bi-dimensional contendo N.. condições, em que o 1º elemento é o bloco condicional, o 2º é bloco a ser executado se verdadeiro e o 3º é bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
				 aNoFields				,; //7-aNoFields - array contendo os campos que não estarão no aHeader;
				 NIL					,; //8-aYesFields - array contendo somente os campos que estarão no aHeader;
				 NIL					,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usuário;
				 NIL					,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
				 NIL					,; //11-bMontCols - bloco contendo função especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}
				 NIL					,; //12-lEmpty – Caso True ( default é false ), inicializa o aCols com somente uma linha em branco ( como exemplo na inclusão).
				 aHeaderAux				,; //13-aHeaderAux, eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )
				 aColsAux				)  //14-aColsAux eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )

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
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

aLbxCoord		:= { (aObjSize[1,1]+20), (aObjSize[1,2]+4)	, (aObjSize[1,3]-24)	, (aObjSize[1,4] /2 -4 ) }
aGDCoord		:= { (aObjSize[1,1]+20), (aObjSize[1,4]/2 + 2), (aObjSize[1,3]+7)		, (aObjSize[1,4]) }

DEFINE MSDIALOG oDlgMain FROM	aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cCadastro OF oMainWnd  PIXEL

	@ aObjSize[1,1]+5,aObjSize[1,2]+7 	SAY OemToAnsi(STR0005)	PIXEL			//"Calend rio: "
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
					OemtoAnsi(STR0013),;			//"Fun‡„o "
					OemtoAnsi(STR0014);				//"Descr. Fun‡„o"
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


	//Proteção de Dados Sensíveis
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr200Monta³ Autor ³ Emerson Grassi Rocha ³ Data ³ 05/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta os listbox da reserva dos treinamentos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr200Monta(ExpC1,ExpC2,ExpC3)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpC2 : Codigo do Curso                                    ³±±
±±³          ³ ExpC3 : Codigo da Turma                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA200       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Situacao do Funcionario  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr200Mont2³ Autor ³ Emerson Grassi Rocha ³ Data ³ 12/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta os listbox para Eficacia dos treinamentos            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr200Mont2(ExpC1,ExpC2,ExpC3)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpC2 : Codigo do Curso                                    ³±±
±±³          ³ ExpC3 : Codigo da Turma                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA200       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Situacao do Funcionario  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr200Grava³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 06/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os registros referente agenda de Testes.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Calendario                                         ³±±
±±³          ³ ExpC2 : Curso                                              ³±±
±±³          ³ ExpC3 : Turma                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA200                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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

				If lAchou := ( aColsAux[ny,nPosRec] <> 0 )	// Se RECNO for maior 0 significa que registro já existia, se não, é um registro novo a ser incluido.
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
			cMsg := STR0033 + " <br><br>" //Atenção
 			cMsg += STR0034 + cCurso + " <br><br>" + Chr(10)+Chr(13) //"Foi agendada uma avaliação referente ao Curso "

 			If RAJ->RAJ_QUEM == "2" //Eficacia
 				cMsg += STR0040 + " <br>" + Chr(10)+Chr(13)//"Avaliação de Eficácia "
 				cMsg += STR0039 + RAJ->RAJ_MAT + " - " + Alltrim(Posicione("SRA",1,RAJ->RAJ_FILIAL+RAJ->RAJ_MAT,"RA_NOME")) +" <br>" + Chr(10)+Chr(13)//"Avaliado :"
 			EndIf
 			If Empty(RAJ->RAJ_DATAF)
 				cMsg += STR0035 + Dtoc(RAJ->RAJ_DATA) + " <br>" + Chr(10)+Chr(13)//"Data : "
 				cMsg += STR0036 + RAJ->RAJ_HORA + "hs." + " <br>" + Chr(10)+Chr(13)//"Horário :  "
 			Else
 				cMsg += STR0035 + Dtoc(RAJ->RAJ_DATA) + " - " + Dtoc(RAJ->RAJ_DATAF)  + " <br>" + Chr(10)+Chr(13)//"Data : "
 				cMsg += STR0036 + RAJ->RAJ_HORA + "hs." + " - " + RAJ->RAJ_HORAF  + "hs <br>" + Chr(10)+Chr(13)//"Horário :  "
 			EndIf
 			cMsg += "<br> <br>" + Chr(10)+Chr(13)
 			cMsg += STR0037 + "<br>" + Chr(10)+Chr(13)//"Para realizar a prova favor acessar o Portal RH.
 			cMsg += "<br> <br>" + Chr(10)+Chr(13)
			cMsg += "Att."  + Chr(10)+Chr(13)
			lRet := gpeMail(STR0038,cMsg,cEmail)//"Aviso de avaliação"

		EndIf
	EndIf
EndIf

//RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr200Perg ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 05/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chamada dos parametros no arotina                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA200                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr200Perg()
Pergunte("TRM200",.T.)
Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr200Troca³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 06/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que troca o acols conforme a posicao do funcionario  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA200                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr200CriaArq³ Autor ³ Emerson Grassi Rocha³ Data ³ 06/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que controla a criacao do arquivo temporario         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 : Posicao nao marcada                                ³±±
±±³          ³ ExpN2 : Posicao nao marcada                                ³±±
±±³          ³ ExpN3 : Posicao marcada                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA200                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr200Ok    ³ Autor ³ Emerson Grassi Rocha³ Data ³ 06/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao executada na linha Ok da getdados                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr200Ok                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ *Avaliacao do Tipo EFI = vinculada a Outros e Avaliador      ³
			//³ *Outros Tipos de Avaliacao  = vinculada ao Funcionário       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPosTeste > 0
				cTipoTeste := TrmDesc("SQQ",aCols[n][nPosTeste],"SQQ->QQ_TIPO")

				If !Empty(cTipoTeste)
					If cTipoTeste == 'EFI' .And. aCols[n][nPosQuem] <> "2"
						Aviso(OemToAnsi(STR0024), OemToAnsi(STR0029), {"Ok"})	//"Para avaliação do tipo 'EFI' opte por 'Outros' na coluna 'Realiza. por' e vincule ao Avaliador"
						lRet:= .F.
						Exit
					EndIf

					If cTipoTeste <> 'EFI' .And. aCols[n][nPosQuem] <> "1"
						Aviso(OemToAnsi(STR0024), OemToAnsi(STR0030), {"Ok"})	//"Para esta avaliação opte por 'Funcionário' na coluna 'Realiza. por'"
						lRet:= .F.
						Exit
					EndIf
				EndIf
			EndIf

			If nPosModelo > 0
				cTipoteste := TrmDesc("SQW",aCols[n][nPosModelo],"SQW->QW_TIPO")
				If !Empty(cTipoTeste)
					If cTipoTeste == 'EFI' .And. aCols[n][nPosQuem] <> "2"
						Aviso(OemToAnsi(STR0024), OemToAnsi(STR0029), {"Ok"})	//"Para avaliação do tipo 'EFI' opte por 'Outros' na coluna 'Realiza. por' e vincule ao Avaliador"
						lRet:= .F.
						Exit
					EndIf

					If cTipoTeste <> 'EFI' .And. aCols[n][nPosQuem] <> "1"
						Aviso(OemToAnsi(STR0024), OemToAnsi(STR0030), {"Ok"})	//"Para esta avaliação opte por 'Funcionário' na coluna 'Realiza. por'"
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr200Leg      ³ Autor ³Emerson Grassi    ³ Data ³ 01.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Aciona Legenda de cores da Mbrowse.				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr200Leg()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr200Leg()

	BrwLegenda(cCadastro,STR0001, {{"ENABLE"		, OemToAnsi(STR0021)},; //"Em aberto"
									{"BR_VERMELHO"	, OemToAnsi(STR0022)},; //"Encerrado "
									{"BR_AZUL"		, OemToAnsi(STR0023)}}) //"Aguardando Aval. Eficacia"

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr200Desc     ³ Autor ³Emerson Grassi    ³ Data ³ 06/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Descricao do Teste ou Modelo.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr200Desc()			                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr200Colet    ³ Autor ³Emerson Grassi    ³ Data ³ 29/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Agendamento de Teste coletivo.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr200Colet()			                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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
				aGuarda[i][3][n] := {} // Necessário tipar o Sub-Nível para ser usado no aSize
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr200NomAval  ³ Autor ³Emerson Grassi    ³ Data ³ 16/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Nome do Avaliador.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr200NomAval()		                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SqqSxbFilt³ Autor ³ Eduardo Ju           ³ Data ³ 04/07/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtro de Consulta Padrao do SQQ                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³<Vide Parametros Formais>									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³<Vide Parametros Formais>									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Consulta Padrao (SXB)                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SqqSxbFilt()

Local cRet:= ""
Local nTamItem	:= (TamSx3("QQ_ITEM")[1])

If cModulo == "TRM"
	cRet := "@#SQQ->QQ_ITEM=='"+ STRZERO(1,nTamItem)+"'" + Iif(RA2->RA2_EFICAC == 'S', " .And. SQQ->QQ_TIPO=='EFI'@#"," .And. SQQ->QQ_TIPO<>'EFI'@#")
Else
	cRet := "@#SQQ->QQ_ITEM=='"+ STRZERO(1,nTamItem)+"'@#"
EndIf

Return( cRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SqwSxbFilt³ Autor ³ Eduardo Ju           ³ Data ³ 04/07/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtro de Consulta Padrao do SQW                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³<Vide Parametros Formais>									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³<Vide Parametros Formais>									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Consulta Padrao (SXB)                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SqwSxbFilt()

Local cRet:= ""

cRet := "@#SQW->QW_SEQ=='01'" + Iif(RA2->RA2_EFICAC == 'S', " .And. SQW->QW_TIPO=='EFI'@#"," .And. SQW->QW_TIPO<>'EFI'@#")

Return( cRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RAJSX3INIT ³ Autor ³ Eduardo Ju           ³ Data ³ 05.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao do campo RAJ_DESCRI no SX3 (X3_RELACAO).          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Trma200                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MatAvalInit³ Autor ³ Eduardo Ju           ³ Data ³ 05.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao do campo RAJ_NOMAVA no SX3 (X3_RELACAO).          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Trma200                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr200NewLin  ³ Autor ³ Eduardo Ju         ³ Data ³ 06/07/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Nova linha para getdados                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 					                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
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

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RAJCursoInit ³ Autor ³ Leandro Dr.        ³ Data ³ 30/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inicializa campo RAJ_CURSO                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 					                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function RAJCursoInit()
Local cRet := ""

If !Empty(RA2->RA2_CURSO)
	cRet := RA2->RA2_CURSO
EndIf

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RAJCursoVld  ³ Autor ³ Leandro Dr.        ³ Data ³ 30/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida campo RAJ_CURSO                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 					                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function RAJCursoVld()
Local lRet := .F.

If ( Empty(RA2->RA2_CURSO) .or. RA2->RA2_CURSO == RAJ->RAJ_CURSO )
	lRet := .T.
EndIf

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RAJMatAvaWhen³ Autor ³ Leandro Dr.        ³ Data ³ 29/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida when do campo RAJ_QUEM                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 					                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function RAJQuemWhen()
Local lRet := .F.

If 	!Empty(M->RAJ_QUEM)
	lRet := .T.
EndIf

Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RAJQuemWhen  ³ Autor ³ Leandro Dr.        ³ Data ³ 29/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida when do campo RAJ_MATAVA                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 					                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function RAJMatAvaWhen()
Local lRet := .F.

If RA2->RA2_EFICAC == "S"
		lRet := .T.
EndIf

Return lRet
/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³21/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³TRMA200                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function MenuDef()
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
Local aRotina :=   {	{ STR0001,'PesqBrw'		, 0,1,,.F.},;	//"Pesquisar"
						{ STR0002,'Tr200Perg'	, 0,3},;	//"Para&metros"
						{ STR0003,'Tr200Rot'	, 0,4},;	//"Agendar"
						{ STR0016,'Tr200Leg'	, 0,2, ,.F.}}	//"Legenda"

Return aRotina
