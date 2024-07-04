#include "Protheus.ch"
#include "font.ch"
#include "colors.ch"
#include "TRMA050.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o     ³ TRMA050  ³ Autor ³ Cristina Ogura          ³ Data ³ 12.11.98   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o  ³ Cadastro dos Treinamentos                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ TRMA050                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ Avoid                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Program.   ³ Data     ³ BOPS   ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia C. ³21.07.2014³TPZSOX  ³Incluido o fonte da 11 para a 12 e efetuada ³±±
±±³           ³          ³        ³a limpeza.                                  ³±±
±±³Oswaldo L. ³30-03-2017³RHRH001-522 Ajuste ERRLOG ao clicar no bot VISUALIZAR³±±
±±³           ³          ³        ³da lupa do campo calendário da tabela TY4   ³±±
±±|Eduardo vic³07/02/18	 ³DRHESOCP-2927   ³Inclusão de validação para Entidade ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TRMA050()
Local aCores  	:= {}
Local aAuxCor   := {}
Local _nX       := 0

Private cFiltra	:= ""				//Variavel para filtro
Private aIndFil	:= {}				//Variavel Para Filtro

Private bFiltraBrw := {|| Nil}		//Variavel para Filtro
Private aLegenda:= {}
Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemtoAnsi(STR0006)	//"Cadastro de Treinamentos"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RA2")
dbSetOrder(1)

cFiltra 	:= CHKRH(FunName(),"RA2","1")
bFiltraBrw 	:= {|| FilBrowse("RA2",@aIndFil,@cFiltra) }
Eval(bFiltraBrw)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis staticas da funcao RA2Acesso            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RA2Acesso(.T.)

aAdd(aCores, {'RA2->RA2_REALIZA != "S"' , "ENABLE"	  , ""}) //"Em Aberto"
aAdd(aCores, {'RA2->RA2_REALIZA == "S"', "BR_VERMELHO", ""}) //"Encerrado"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definiao de cores por usuarios      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("TRM050LEG")
	aAuxCor := ExecBlock("TRM050LEG",.F.,.F.,{aCores} )
	If ValType(aAuxCor) == "A" .AnD. Len(aAuxCor) > 0
		aCores    := {}
		aLegenda  := {}
		For _nX := 1 To Len(aAuxCor)
			aAdd(aCores,   {aAuxCor[_nX,1], aAuxCor[_nX,2]})
			aAdd(aLegenda, {aAuxCor[_nX,2], If(Empty(aAuxCor[_nX,3]), "-", aAuxCor[_nX,3])})
		Next _nX
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RA2")
dbGoTop()

mBrowse(6, 1, 22, 75, "RA2",,,,,,aCores)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("RA2",aIndFil)

dbSelectArea("RA2")
dbSetOrder(1)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr050Rot  ³ Autor ³ Cristina Ogura       ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta o calendario dos treinamentos                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr050Rot(cAlias,nReg,nOpcx)
Local oDlgMain

Local nOpca		:= 0
Local lTrDel	:= If(nOpcx = 2 .Or. nOpcx = 5, .F., .T.)
Local oDesc
Local oPlan
Local oCod
Local i			:= 0
Local nRecRa2:=RA2->(Recno())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Dimensionar Tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}


Local aNoFields	:= {"RA2_FILIAL","RA2_CALEND","RA2_DESC","RA2_PLANEJ"}

//Variaveis para WalkThru
Local nRa2Ord		:= 0
Local bSeekWhile	:= {|| RA2->RA2_FILIAL + RA2->RA2_CALEND }

Local nPosRec	:= 0
Local cIntePCO 	:= SuperGetMV("MV_PCOINTE",.T.,"2")
Local nX		:= 0
Local bSet15
Local bSet24

// Private da Getdados
Private aCols  	:= {}
Private aHeader	:= {}
Private cCod	:= CriaVar("RA2_CALEND",.f.)
Private cDesc	:= CriaVar("RA2_DESC",.f.)
Private cPlan	:= CriaVar("RA2_PLANEJ",.f.)
Private nOpcao 	:= nOpcx
Private oGet

If nOpcx # 3			// Diferente de Inclusao
	cCod	:= RA2->RA2_CALEND
	cDesc	:= RA2->RA2_DESC
	cPlan	:= RA2->RA2_PLANEJ
Else
	cCod  	:= GetSx8Num("RA2","RA2_CALEND")
EndIf

PcoIniLan("000377")

//==> Monta as getdados dos arquivos com recursos WalkThru

nRa2Ord	:=	RetOrdem("RA2","RA2->RA2_FILIAL + RA2->RA2_CALEND")

FillGetDados(	nOpcx					,; //1-nOpcx - número correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
				"RA2"					,; //2-cAlias - area a ser utilizada;
				nRa2Ord					,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
				xFilial(cAlias)+cCod	,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
				bSeekWhile				,; //5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
				NIL						,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-código, condição a ser utilizado para executar o Loop no While;2º - array bi-dimensional contendo N.. condições, em que o 1º elemento é o bloco condicional, o 2º é bloco a ser executado se verdadeiro e o 3º é bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
				aNoFields				,; //7-aNoFields - array contendo os campos que não estarão no aHeader;
				NIL						,; //8-aYesFields - array contendo somente os campos que estarão no aHeader;
				NIL						,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usuário;
				NIL						,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
				NIL						,; //11-bMontCols - bloco contendo função especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}
				nOpcx==3				,;	//nOpcx==3 12-lEmpty – Caso True ( default é false ), inicializa o aCols com somente uma linha em branco ( como exemplo na inclusão).
				NIL						,; //13-aHeaderAux, eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )
				NIL						,; //14-aColsAux eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )
				/*bAfterCols*/			,; //15-bAfterCols - Bloco de codigo a ser executado após a inclusão de uma linha no Acols
				NIL						,; //16-bBeforeCols - Bloco de codigo contendo expressão para sair do While, é executado antes de inserir nova linha no aCols
				/*bAfterHeader*/		,; //17-bAfterHeader - Bloco de codigo a ser executado após o preenchimento do aheader com os campos padrão e antes de incluir os campos reservados para o WalkThru. Ex: {|aHeader| AlterHeader(aHeader) }
				/*cAliasQuery*/			,; //18-cAliasQry
				/*bCriaVar	 */		 	; //19-bCriaVar
			)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Apaga os lancamentos do PCO antes da manutencao dos dados    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nPosRec	:= GdfieldPos("RA2_REC_WT")
If nOpcx # 5 .And. nOpcx # 2	// Se nao for Exclusao e visual
	If nPosRec > 0 .And. cIntePCO == '1'
		For nX := 1 to Len(aCols)
			If aCols[nx][nPosRec]>0
				RA2->(MsGoto(aCols[nX][nPosRec]))
				PcoDetLan("000377","01","TRMA050",.T.)
			EndIf
		Next
	Endif
Endif

M->RA2_CURSO:=space(4)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize	:= MsAdvSize()

aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 1 , 1 }
aAdd( aObjCoords , { 000 , 020 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 100 , .T. , .T. } )

aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

DEFINE MSDIALOG oDlgMain TITLE cCadastro FROM  aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] OF GetWndDefault() PIXEL

bSet15 := {|| nOpca := 1, If(oGet:TudoOk() .And. Tr050TudOk(nOpcx, cDesc), oDlgMain:End(), .F.)}
bSet24 := {|| nOpca := 0, oDlgMain:End()}

    @ aObjSize[1][1], aObjSize[1][4]*0.01	 SAY OemToAnsi(STR0007) of oDlgMain PIXEL		//"Calend rio: "
	@ aObjSize[1][1], aObjSize[1][4]*0.01+30 MSGET oCod Var cCod VALID Tr050CALEND(cCod) .And. oDesc:SetFocus(.T.) WHEN (nOpcx==3) of oDlgMain PIXEL
	@ aObjSize[1][1], aObjSize[1][4]*0.01+55 MSGET oDesc Var cDesc PICTURE "@!" VALID !Empty(cDesc) WHEN lTrDel of oDlgMain PIXEL
	@ aObjSize[1][1], aObjSize[1][4]*0.6	 SAY OemToAnsi(STR0014) of oDlgMain PIXEL		//"Planejamento: "
	@ aObjSize[1][1], aObjSize[1][4]*0.6+35	 MSGET oPlan Var cPlan PICTURE "9999" VALID Vazio() .Or. (ExistCpo("RA8") .And. Tr050Plan(oGet)) F3 "RA8" HASBUTTON WHEN nOpcx == 3 of oDlgMain PIXEL

	oGet := MSGetDados():New(	aObjSize[2][1]	, ;
								aObjSize[2][2]	, ;
								aObjSize[2][3]	, ;
								aObjSize[2][4]	, ;
								nOpcx			, ;
								"Tr050Ok"		, ;
								"AlwaysTrue"	, ;
								/*cIniCpos*/	, ;
								lTrDel			, ;
								/*aAlter*/		, ;
								/*nFreeze*/		, ;
								/*lEmpty*/		, ;
								10000			, ;
								"Ra2EditGet()"	, ;
								/*cSuperDel*/	, ;
								/*aTeclas*/		, ;
								"TR050LINDEL"	, ;
								oDlgMain		)

ACTIVATE MSDIALOG oDlgMain ON INIT EnchoiceBar(oDlgMain, bSet15, bSet24,,) CENTERED

If nOpca == 1
	If nOpcx # 5 .And. nOpcx # 2	// Se nao for Exclusao e visual
		Begin Transaction
			If nOpcx == 3			// Inclusao
				If __lSX8
					ConfirmSX8()
				EndIf
			EndIf
			Tr050Grava(cAlias, nReg, nOpcx)
			EvalTrigger()
		End Transaction
	ElseIf nOpcx = 5
		Begin Transaction
			Tr050Dele(cAlias,nReg,nOpcx)
		End Transaction
	EndIf
Else
	If __lSX8
		RollBackSX8()
	EndIf

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Retorna os lancamentos do PCO antes da manutencao dos dados    ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If nOpcx # 5 .And. nOpcx # 2	// Se nao for Exclusao e visual
		If nPosRec > 0 .And. cIntePCO == '1'
			For nX := 1 to Len(aCols)
				If aCols[nx][nPosRec]>0
					RA2->(MsGoto(aCols[nX][nPosRec]))
					PcoDetLan("000377","01","TRMA050")
				EndIf
			Next
		Endif
	Endif

EndIf

PcoFinLan("000377")
PcoFreeBlq("000377")

dbSelectArea("RA2")
dbGoto(nReg)

Return(Nil)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr050Ok   ³ Autor ³ Cristina Ogura        ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a linha da getdados                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr050Ok(n)
Local nPosCurso	:= GdFieldPos("RA2_CURSO")
Local nPosTurma	:= GdFieldPos("RA2_TURMA")
Local nPosDtIni	:= GdFieldPos("RA2_DATAIN")
Local nPosDtFin	:= GdFieldPos("RA2_DATAFI")
Local nPosNrVag	:= GdFieldPos("RA2_VAGAS")
Local nPosCC	:= GdFieldPos("RA2_CC")
Local nPosDtRef	:= GdFieldPos("RA2_DTREF")
Local nPosEnt	:= GdFieldPos("RA2_ENTIDA")
Local nx  		:= 0
Local n			:=If(VALTYPE(n)<> "O",n,n:nAt)
Local cInte 	:= SuperGetMV("MV_PCOINTE",.T.,"2")

If nOpcao # 5 .And. nOpcao # 2
	If !aCols[n,Len(aCols[n])]      /// Se nao esta Deletado
		If nPosCurso > 0 .And. Empty(aCols[n][nPosCurso])
			Help("",1,"TRA050CURS")
			Return .F.
		ElseIf nPosTurma > 0 .And. Empty(aCols[n][nPosTurma])
			Help("",1,"TRA050TURM")
			Return .F.
		ElseIf nPosEnt > 0 .And. Empty(aCols[n][nPosEnt])
			Help( ,, STR0029,, STR0030	, 1, 0,,,,,, {STR0031} )//##"Cod.Entidade"##"O Cod.Entidade está vazio!"##"Prencha o Código da Entidade [RA2_ENTIDA]"
			Return .F.
		ElseIf nPosDtIni > 0 .And. Empty(aCols[n][nPosDtIni])
			Help("",1,"TRA050DTIN")
			Return .F.
		ElseIf nPosNrVag > 0 .And. Empty(aCols[n][nPosNrVag])
			Help("",1,"TRA050NVAG")
			Return .F.
		ElseIf cInte == '1' .And. nPosCC > 0 .And. Empty(aCols[n][nPosCC])
			Help("",1,"TRA050NCC")
			Return .F.
		ElseIf cInte == '1' .And. nPosDtRef > 0 .And. Empty(aCols[n][nPosDtRef])
			Help("",1,"TRA050NDTREF")
			Return .F.
		EndIf
	    If aCols[n][nPosDtIni] > aCols[n][nPosDtFin]
	    	Aviso(OemToAnsi(STR0010), OemToAnsi(STR0011),{"OK"})
	    	Return .F.
	    EndIf
		For nx:=1 To Len(aCols)
			If aCols[n][nPosCurso] == aCols[nx][nPosCurso] .And.;
				aCols[n][nPosTurma] == aCols[nx][nPosTurma] .And.;
			    If(nPosCC > 0,aCols[n][nPosCC] == aCols[nx][nPosCC],.T.) .And.;
				!aCols[nx][Len(aCols[nx])] .And.;
				n # nx
				Help(" ",1,"TRA050EXIST")
				Return .F.
				Exit
			EndIf
		Next nx

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Validacao dos lancamentos no SIGAPCO		     			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpcao # 5 .And. cInte == '1' .And. !PcoBlqFim({{"000377","01"}})
			If ! ( lRet := 	PcoVldLan("000377", "01", "TRMA050",,, .T. ) )
				Return .F.
			Endif
		Endif
	EndIf
EndIf

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TR050LINDEL ³ Autor ³ Maurcio MR          ³ Data ³ 24.08.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a delecao da linha da getdados                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr050LinDel()
Local lRet		:= .T.

//-- Verifica se pode eliminar a linha da getdados
//-- Artificio para nao verificar duas vezes a mesma situacao (processo automatico da MSGETDADOS).
IF !IsInCallStack( "{|| SELF:DELOK()}")
	If !RA2Acesso(Nil,.T.)
		aCols[n,Len(aCols[n])] 		:= 	.F.
		oGet:oBrowse:Refresh(.T.)
	   	oGet:Refresh(.T.)
		lRet:=.F.
	EndIf
EndIf

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr050Grava³ Autor ³ Cristina Ogura        ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os registros referente ao treinamentos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr050Grava(cAlias,nReg,nOpcx)
Local cMsgErr	:= ''
Local lAddNew	:= .F.
Local nPosRec	:= GdfieldPos("RA2_REC_WT")
Local nx		:= 0
Local ny		:= 0

RA2->(dbGoTop())
For nx := 1 to Len(aCols)

    	lAddNew := Empty(aCols[nx][nPosRec])

		If aCols[nx][nPosRec]>0
			RA2->(MsGoto(aCols[nX][nPosRec]))
		EndIf

		//--Verifica se esta deletado
		If aCols[nX][Len(aCols[nX])]
			//-- Se Treinamento jah foi gravado
			If aCols[nx][nPosRec]>0
				If ( RA2->(RecLock(cAlias,.F.)) )
					//-- Elimina Treinamento
					IF !RA2->( FkDelete( @cMsgErr ) )
						RA2->(RollBackDelTran( cMsgErr ))
					EndIF
				RA2->(MsUnlock())
				EndIf
		    Endif
        Else
			If ( RA2->(RecLock(cAlias,lAddNew)) )
	            //-- Grava Treinamento
				Replace RA2->RA2_FILIAL 	WITH xFilial(cAlias)
				Replace RA2->RA2_CALEND	 	WITH cCod
				Replace RA2->RA2_DESC		WITH cDesc
				Replace RA2->RA2_PLANEJ		WITH cPlan
				For nY := 1 To Len(aHeader)
					If aHeader[nY][10] <> "V"
						RA2->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
					EndIf
				Next nY
				RA2->(MsUnlock())
				PcoDetLan("000377","01","TRMA050")
			EndIf
		EndIf
Next nx

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr050Dele ³ Autor ³ Cristina Ogura        ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Deleta todos os registros referentes aos treinamentos       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TRM050                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr050Dele( cAlias , nReg , nOpcx)
Local aSaveArea			:= GetArea()
Local cMsgErr			:= ''
Local lRet				:= .T.

// Verifica se existem Registros deste Calendario no RA4-Cursos funcionarios
IF RA2->RA2_REALIZ =='S'
	Aviso(STR0010,STR0017,{"Ok"}) //"Atencao"###"Treinamento em andamento ou baixado não pode ser eliminado."
	lRet	:= .F.
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza tratamento no caso do Treinamento/Calendario ser    ³
	//³ compartilhado.												³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !Trma050ChkDel( cAlias , nReg , nOpcx, cCod,/*/Curso/*/,/*/Turma/*/,.T. )
       lRet := .F.
	Endif

	If lRet
		// Treinamento
		dbSelectArea("RA2")
		dbSetOrder(1)
		If dbSeek(xFilial("RA2")+cCod)
			While !Eof() .And. RA2->RA2_FILIAL+RA2->RA2_CALEND == xFilial("RA2")+cCod
				PcoDetLan("000377","01","TRMA050",.T.)

				RecLock("RA2",.F.)
				IF !RA2->( FkDelete( @cMsgErr ) )
					RollBackDelTran( cMsgErr )
				EndIF
				MsUnlock()
				dbSkip()
			EndDo
		EndIf
	Endif
Endif
RestArea(aSaveArea)

Return lRet


/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³Trma050ChkDel	³Autor³Mauricio MR        ³ Data ³21/08/2009³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Verificar se o Treinamento/Calendario Pode ser Deletado     ³
³          ³dos Cursos do Funcionario (nao relacionado no SX9) e demais ³
³          ³tabelas declaradas explicitamente no nSX9.                  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Firmais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³TRMA050                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³NIL															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Firmais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function Trma050ChkDel( cAlias , nReg , nOpcx,  cCalend, cCurso, cTurma, lSX9, lShowlog, lSoft)

Local aArea		:= GetArea()
Local aAreas	:= {}
Local cFilRA2	:= xFilial( cAlias )
Local cChave	:= ''
Local lDelOk	:= .T.
Local nAreas	:= 0

Local lCurso    := (cCurso <> NIL )
Local lTurma    := (cTurma <> NIL )

DEFAULT lSX9	:= .T.
DEFAULT lShowlog:= .T.

//RA3  - Reserva
aAdd( aAreas , Array( 03 ) )
nAreas := Len( aAreas )
aAreas[nAreas,01] := RA3->( GetArea() )
aAreas[nAreas,02] := Array( 2 )
				aAreas[nAreas,02,01] := "RA3_FILIAL"
				aAreas[nAreas,02,02] := "RA3_CALEND"
				If lCurso
					aAdd(aAreas[nAreas,02], "RA3_CURSO")
				Endif
				If lTurma
					aAdd(aAreas[nAreas,02], "RA3_TURMA")
				Endif
//RA4  - Cursos do Funcionarios
aAdd( aAreas , Array( 03 ) )
nAreas := Len( aAreas )
aAreas[nAreas,01] := RA4->( GetArea() )
aAreas[nAreas,02] := Array( 2 )
				aAreas[nAreas,02,01] := "RA4_FILIAL"
				aAreas[nAreas,02,02] := "RA4_CALEND"
				If lCurso
					aAdd(aAreas[nAreas,02], "RA4_CURSO")
				Endif
				If lTurma
					aAdd(aAreas[nAreas,02], "RA4_TURMA")
				Endif

//-- Calendario a ser eliminado
cChave	:=  cCalend
If lCurso
	cChave += cCurso
Endif
If lTurma
	cChave += cTurma
Endif

lDelOk := ChkDelRegs(	cAlias			,;	//01 -> Alias do Arquivo Principal
						nReg			,;	//02 -> Registro do Arquivo Principal
						nOpcx			,;	//03 -> Opcao para a AxDeleta
						cFilRA2			,;	//04 -> Filial do Arquivo principal para Delecao
						cChave			,;	//05 -> Chave do Arquivo Principal para Delecao
						aAreas			,;	//06 -> Array contendo informacoes dos arquivos a serem pesquisados
						NIL		  		,;	//07 -> Mensagem para MsgYesNo
						NIL     		,;	//08 -> Titulo do Log de Delecao
						NIL				,;	//09 -> Mensagem para o corpo do Log
						.F.				,;	//10 -> Se executa AxDeleta
						lShowlog		,;	//11 -> Se deve Mostrar o Log
						NIL				,;	//12 -> Array com o Log de Exclusao
						NIL				,;	//13 -> Array com o Titulo do Log
						NIL				,;	//14 -> Bloco para Posicionamento no Arquivo
						NIL				,;	//15 -> Bloco para a Condicao While
						NIL				,;	//16 -> Bloco para Skip/Loop no While
						lSX9      		,;	//17 -> Verifica os Relacionamentos no SX9
						{"RA3","RA4"}  	,;	//18 -> Alias que nao deverao ser Verificados no SX9
						lSoft			,;	//19 -> Se faz uma checagem soft
						NIL             ;   //20 -> Se esta executando rotina automatica
					)


RestArea( aArea )

Return( lDelOk )





/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr050Calend³ Autor ³ Cristina Ogura       ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida o codigo do calendario                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tr050Calend(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ExpC1 - codigo do calendario                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr050Calend(cCod)
Local aSaveArea := GetArea()
Local lRet		:= .T.

If Empty(cCod)
	Help("",1,"TRA050VAZI")
	lRet := .F.
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro para verificar a existencia do calendario em todas as  ³
//³ filiais.															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("RA2",aIndFil)
If lRet .And. RA2->(dbSeek(xFilial("RA2")+cCod))
	Help("",1,"TRA050CALE")
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aplica o filtro novamente                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bFiltraBrw 	:= {|| FilBrowse("RA2",@aIndFil,@cFiltra) }
Eval(bFiltraBrw)


If lRet .And. !FreeForUse("RA2",cCod)
	lRet := .F.
EndIf

RestArea(aSaveArea)

Return lRet


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr050Curso³ Autor ³ Cristina Ogura        ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Traz a descricao do curso                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tr050Curso(Expl1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³Expl1 - se for do X3_RELACAO e' true                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TRMA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr050Curso(lSX3,nEscol)
Local aSaveArea := GetArea()
Local cRetorno 	:= ""
Local nPos	   	:= 0
Local nPosDesc 	:= 0
Local cVar		:= ""
Local lRet		:= .T.
Local nPosDur	:= 0
Local nPosUni	:= 0
Local nPosVal	:= 0
Local nPosEnt	:= 0
Local nPosCur	:= 0
Local nPosHor	:= 0


If ( Type("oGet") == "U" )
	n := 1
EndIf
nEscol := IIf(nEscol==Nil,1,nEscol)
If nEscol == 1			// Curso
	cRetorno := CriaVar("RA1_DESC",.f.)
	If Type("aHeader") != "U"   //Consulta Padrao
		nPos	 := GdFieldPos("RA2_CURSO")
		nPosDesc := GdFieldPos("RA2_DESCCU")
		If !lSX3 .And. nPos > 0 .AND. !ALTERA
			If !Empty(aCols[n][nPos]) .And. &(ReadVar()) != aCols[n][nPos] .And.;
				nOpcao == 4

				Aviso(OemToAnsi(STR0010), OemToAnsi(STR0013), {"Ok"})	//"Atencao"###"Codigo do Curso nao pode ser alterado."
				Return .F.
			EndIf
		EndIf
	EndIf
	cVar:=IF(lSX3,RA2->RA2_CURSO,&(ReadVar()))

	dbSelectArea("RA1")
	dbSetOrder(1)
	If dbSeek(xFilial("RA1")+cVar)
		cRetorno := RA1->RA1_DESC
	Else
		lRet := .F.
	EndIf
ElseIf nEscol == 2		// Entidade

	cRetorno := CriaVar("RA0_DESC",.f.)

	If Type("aHeader") != "U" //Consulta Padrao
		nPos	 := GdFieldPos("RA2_ENTIDA")
		nPosDesc := GdFieldPos("RA2_DESCEN")
		nPosCur	 := GdFieldPos("RA2_CURSO")
	EndIf

	cVar := IF(lSX3, RA2->RA2_ENTIDA, &(ReadVar()))

	dbSelectArea("RA6")
	dbSetOrder(1)

	If nModulo == 35

		If nPosCur > 0
			If dbSeek(xFilial("RA6") + cVar + aCols[n][nPosCur])
				cRetorno := Posicione("RA0", 1, xFilial("RA0")+cVar, "RA0_DESC")
			Else
				RA6->(dbSetOrder(2))
				If !dbSeek(xFilial("RA6") + aCols[n][nPosCur]) //Caso não haja entidades amarradas ao curso permite informar qualquer uma.
					cRetorno := Posicione("RA0", 1, xFilial("RA0")+cVar, "RA0_DESC")
					If Empty(cRetorno)
						lRet := .F.
					EndIf
				Else
					lRet := .F.
				EndIf
				RA6->(dbSetOrder(1))
			EndIf
		Else

			If dbSeek(xFilial("RA6") + cVar + RA2->RA2_CURSO)
				cRetorno := Posicione("RA0", 1, xFilial("RA0")+cVar, "RA0_DESC")
			Else
				RA6->(dbSetOrder(2))
				If !dbSeek(xFilial("RA6") + RA2->RA2_CURSO) //Caso não haja entidades amarradas ao curso permite informar qualquer uma.
					cRetorno := Posicione("RA0", 1, xFilial("RA0")+cVar, "RA0_DESC")
					If Empty(cRetorno)
						lRet := .F.
					EndIf
				Else
					lRet := .F.
				EndIf
				RA6->(dbSetOrder(1))
			EndIf
		EndIf
	Else
		If dbSeek(xFilial("RA6") + cVar + aCols[n][nPosCur])
			cRetorno := Posicione("RA0", 1, xFilial("RA0")+cVar, "RA0_DESC")
		Else
			RA6->(dbSetOrder(2))
			If !dbSeek(xFilial("RA6") + aCols[n][nPosCur]) //Caso não haja entidades amarradas ao curso permite informar qualquer uma.
				cRetorno := Posicione("RA0", 1, xFilial("RA0")+cVar, "RA0_DESC")
				If Empty(cRetorno)
					lRet := .F.
				EndIf
			Else
				lRet := .F.
			EndIf
			RA6->(dbSetOrder(1))
		EndIf
	EndIf

	// Preencher campos padrao atraves do RA1 / RA6
	If !lSx3

		nPosDur	:= GdFieldPos("RA2_DURACA")
		nPosUni	:= GdFieldPos("RA2_UNDURA")
		nPosVal	:= GdFieldPos("RA2_CUSTO")
		nPosEnt	:= GdFieldPos("RA2_ENTIDA")
		nPosCur	:= GdFieldPos("RA2_CURSO")
		nPosHor	:= GdFieldPos("RA2_HORAS")

		If nPosEnt > 0 .And. nPosCur > 0
			dbSelectArea("RA6")
			dbSetOrder(1)
			If dbSeek(xFilial("RA6") + cVar + aCols[n][nPosCur])

				IIf(nPosDur > 0 .And. Empty(aCols[n][nPosDur]), aCols[n][nPosDur] := RA6->RA6_DURACA, Nil)
				IIf(nPosUni > 0 .And. Empty(aCols[n][nPosUni]), aCols[n][nPosUni] := RA6->RA6_UNID, Nil)
				IIf(nPosVal > 0 .And. Empty(aCols[n][nPosVal]), aCols[n][nPosVal] := RA6->RA6_VALOR, Nil)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Independentemente da Duracao, Campo Horas = Carga Horaria do Curso (RA1)  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("RA1")
				dbSetOrder(1)
				If dbSeek(xFilial("RA1")+RA6->RA6_CURSO)
					IIf(nPosHor > 0 .And. Empty(aCols[n][nPosHor]), aCols[n][nPosHor] := RA1->RA1_HORAS, Nil)
				EndIf

			Else
				dbSelectArea("RA1")
				dbSetOrder(1)
				If dbSeek(xFilial("RA1")+aCols[n][nPosCur])

					IIf(nPosDur > 0 .And. Empty(aCols[n][nPosDur]), aCols[n][nPosDur] := RA1->RA1_DURACA, Nil)
					IIf(nPosUni > 0 .And. Empty(aCols[n][nPosUni]), aCols[n][nPosUni] := RA1->RA1_UNDURA, Nil)
					IIf(nPosVal > 0 .And. Empty(aCols[n][nPosVal]), aCols[n][nPosVal] := RA1->RA1_VALOR, Nil)
					IIf(nPosHor > 0 .And. Empty(aCols[n][nPosHor]), aCols[n][nPosHor] := RA1->RA1_HORAS, Nil)

				EndIf
			EndIf
	    EndIf
    EndIf



ElseIf nEscol == 3		// Avaliacao
	cRetorno := CriaVar("RAB_DESCR",.f.)
	If Type("aHeader") != "U" //Consulta Padrao
		nPos	 := GdFieldPos("RA2_AVAL")
		nPosDesc := GdFieldPos("RA2_DESCAV")
	EndIf
	cVar:=IF(lSX3,RA2->RA2_AVAL,&(ReadVar()))
	dbSelectArea("RAB")
	dbSetOrder(1)
	If dbSeek(xFilial("RAB")+cVar)
		cRetorno := RAB->RAB_DESCR
	Else
		lRet := .F.
	EndIf

ElseIf nEscol == 4		// Nome do Instrutor
	cRetorno := CriaVar("RA7_INSTRU",.f.)
	If Type("aHeader") != "U" //Consulta Padrao
		nPos	 := GdFieldPos("RA2_INSTRU")
		nPosDesc := GdFieldPos("RA2_NOMEIN")
	EndIf
	cVar:=IF(lSX3,RA2->RA2_INSTRU,&(ReadVar()))
	dbSelectArea("RA7")
	dbSetOrder(1)
	If dbSeek(xFilial("RA7")+cVar)
		cRetorno := RA7->RA7_NOME
	Else
		lRet := .F.
	EndIf

ElseIf nEscol == 5			// Sinonimo Curso
	cRetorno := CriaVar("RA9_DESCR",.f.)
	If Type("aHeader") != "U"   //Consulta Padrao
		nPos	 	:= GdFieldPos("RA2_SINON")
		nPosDesc 	:= GdFieldPos("RA2_DESCSI")
		nPosCur		:= GdFieldPos("RA2_CURSO")
	EndIf
	cVar:=IF(lSX3,RA2->RA2_SINON,&(ReadVar()))
	If nPosCur > 0 .And. !lSX3

		If !Empty(M->RA2_SINON)
			M->RA2_CURSO := aCols[n][nPosCur]

			lRet := .F.

			dbSelectArea("RA9")
			dbSetOrder(2)
			If dbSeek(xFilial("RA9")+M->RA2_CURSO)
				While !eof() .And. M->RA2_CURSO == RA9->RA9_CURSO
					If M->RA2_SINON == RA9->RA9_SINONI
						Iif(nPosDesc > 0, aCols[n][nPosDesc] := RA9->RA9_DESCR, Nil)
						cRetorno:= RA9->RA9_DESCR
						lRet 	:= .T.
					EndIf
					dbSkip()
				End
			EndIf

		Else //Empty(M->RA2_SINON)
			Iif(nPosDesc > 0, aCols[n][nPosDesc] := Space(20), Nil)
			lRet := .T.
		EndIf

	EndIf

	If lSx3

		dbSelectArea("RA9")
		dbSetOrder(1)
		If dbSeek(xFilial("RA9")+cVar)
			cRetorno := RA9->RA9_DESCR
		EndIf

	EndIf
EndIf

//Reinicializa as variavais na inclusão de linhas
If Type("aHeader")!="U".and. Len(aCols)>0.And.nPos > 0 .And. nPosDesc > 0 //Consulta Padrao
	If lSX3
		If Len(aCols)=0 .OR. Empty(aCols[Len(aCols)][nPos])
		    If nEscol == 1
				cRetorno := CriaVar("RA1_DESC",.f.)
			ElseIf nEscol == 2
				cRetorno := CriaVar("RA0_DESC",.f.)
			ElseIf nEscol == 3
				cRetorno := CriaVar("RAB_DESCR",.f.)
			ElseIf nEscol == 4
				cRetorno := CriaVar("RA7_INSTRU",.f.)
			ElseIf nEscol == 5
				cRetorno := CriaVar("RA9_DESCR",.f.)
			EndIf
		EndIf
	Else
		aCols[n][nPosDesc] := cRetorno
	EndIf
EndIf

RestArea(aSaveArea)

Return (IIF(lSX3,cRetorno,lRet))


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr050TudOk³ Autor ³ Cristina Ogura        ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a funcao de tudo Ok                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tr050TudOk(Expl1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³nOpcx - Opcao selecionada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TRMA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr050TudOk(nOpcx,cDesc)

Local lRet		:= .T.
Local nX		:= 0
Local nRA2_CC	:= aScan(aHeader,{|x| AllTrim(x[2])=="RA2_CC"})
Local nRA2_DTREF:= aScan(aHeader,{|x| AllTrim(x[2])=="RA2_DTREF"})
Local cInte 	:= SuperGetMV("MV_PCOINTE",.T.,"2")
Local n_SaveLin	:= 0

If nOpcx != 2

	If Empty(cDesc)
		Aviso(OemToAnsi(STR0010), OemToAnsi(STR0009), {"OK"},,OemToAnsi(STR0012)) //"Nao deixe a Descricao em Branco!"#"Atencao"#"Descricao"
		lRet := .F.
	EndIf

	For nX:=1 to len(aCols)
		If lRet
			lRet := Tr050Ok(nX)
		Else
			Exit
		Endif

		If nOpcx != 5 .And. cInte == '1' .And. ( Empty(aCols[nX,nRA2_CC]) .Or. Empty(aCols[nX,nRA2_DTREF]) )
			Aviso(OemToAnsi(STR0019), OemToAnsi(STR0009), {"OK"},,OemToAnsi(STR0012)) //"Quando a Integração com o Módulo SIGAPCO está ativada, os Centros de Custo e Data de Referencia são obrigatorio!"#"Atencao"#"Descricao"
		Endif
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada antes da gravacao do Calendario.		     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. ExistBlock("TRM050GR")
		lRet := ExecBlock("TRM050GR",.F.,.F.,{nOpcx})
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validacao dos lancamentos no SIGAPCO		     			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. nOpcx != 5

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se validacao do bloqueio do pco e no final, ³
		//³em caso positivo valida todas as linhas              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .And. PcoBlqFim({{"000377","01"}})
			PcoFreeBlq("000377",,,,,.T./*lCancela*/)
			n_SaveLin := n
			For nX := 1 To Len(aCols)
				If !aCols[nX][Len(aCols[nX])]
					n := nX
					lRet	:=	PcoVldLan('000377','01','TRMA050',/*lUsaLote*/,/*lDeleta*/, .F./*lVldLinGrade*/)
					If !lRet
						Exit
					EndIf
				EndIf
			Next
			n := n_SaveLin
		EndIf

	Endif

EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr050Leg      ³ Autor ³Emerson Grassi    ³ Data ³ 01.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Aciona Legenda de cores da Mbrowse.				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr050Leg()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr050Leg()

TrmLegenda(2, , , aLegenda)

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr050Sin      ³ Autor ³Emerson Grassi    ³ Data ³ 12/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Seta variavel de memoria M->RA2_CURSO p/ Cons. SXB (F3).	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr050Sin()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr050Sin()

Local nPosCurso	:= GdFieldPos("RA2_CURSO")

If nPosCurso > 0
	M->RA2_CURSO := aCols[n][nPosCurso]
EndIf

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr050Plan	  ³ Autor ³Emerson Grassi Rocha ³ Data ³ 27/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta acols conforme Planejamento de Treinamento.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 				                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr050Plan(oGet)

Local aSaveArea	:= GetArea()
Local aSaveRA8	:= RA8->( GetArea() )
Local aSaveSX3	:= SX3->( GetArea() )
Local aSaveSC1	:= SC1->( GetArea() )
Local aSaveSC7	:= SC7->( GetArea() )
Local nPos		:= 0
Local nUsado  	:= Len(aHeader)
Local nCntFor	:= 0
Local cEntid	:= Space(04)
Local cDEntid	:= ""
Local nValor	:= 0
Local cProd 	:= ""
Local cCotacao 	:= ""
Local cForn		:= ""
Local cNumPed	:= ""
Local aColsM	:= {}
Local lTr050Trm := ExistBlock( "TR050TRM" )

Local nPosCurso := GdFieldPos("RA2_CURSO")
Local nPosDCur  := GdFieldPos("RA2_DESCCU")
Local nPosEnt	:= GdFieldPos("RA2_ENTIDA")
Local nPosDEnt	:= GdFieldPos("RA2_DESCEN")
Local nPosDataDe:= GdFieldPos("RA2_DATAIN")
Local nPosDataAt:= GdFieldPos("RA2_DATAFI")
Local nPosNFunc := GdFieldPos("RA2_VAGAS")
Local nPosValor := GdFieldPos("RA2_CUSTO")
Local nPosNome	:= GdFieldPos("RA2_RESPON")
Local nPosHoras	:= GdFieldPos("RA2_HORAS")
Local nPosDurac := GdFieldPos("RA2_DURACA")
Local nPosUnDur	:= GdFieldPos("RA2_UNDURA")
Local nPosCC	:= GdFieldPos("RA2_CC")
Local nPosDCC	:= GdFieldPos("RA2_DESCCC")
Local nPosDtRef	:= GdFieldPos("RA2_DTREF")
Local nPosAli 	:= GdFieldPos("RA2_ALI_WT")
Local nPosRec	:= GdFieldPos("RA2_REC_WT")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Buscar dados no Planejamento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RA8")
dbSetOrder(1)
dbSeek(xFilial("RA8")+cPlan)
While !Eof() .And. RA8->RA8_FILIAL+RA8->RA8_PLANEJ == xFilial("RA8")+cPlan

	If nPosCurso > 0 .And. Empty(aCols[1][nPosCurso])
	 	nPos := 1
	Else
		dbSelectArea("SX3")
		dbSeek("RA2")
		aadd(aCols,Array(nUsado+1))
		nPos := Len(aCols)
		For nCntFor := 1 To Len(aHeader)
			If nCntFor <> nPosAli .and. nCntFor <> nPosRec
				aCols[nPos][nCntFor] := CriaVar(aHeader[nCntFor][2],.T.)
			EndIf
		Next nCntFor
		aCols[nPos][nUsado+1] := .F.
	EndIf

	If Empty(RA8->RA8_NUMSC)
		nValor	:= RA8->RA8_VALOR
	Else
		cProd := FDesc("RA1",RA8->RA8_CURSO,"RA1_PROD")
		If !Empty(cProd)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Buscar dados da Solicitacao  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SC1")
			dbSetOrder(2)
			If dbSeek(xFilial("SC1")+cProd+RA8->RA8_NUMSC)
				cForn	:= SC1->C1_FORNECE
				cEntid 	:= FDesc("RA0",cForn,"RA0_ENTIDA",,,3)
				cDEntid	:= FDesc("RA0",cEntid,"RA0_DESC")
				cNumPed	:= SC1->C1_PEDIDO
				cCotacao:= SC1->C1_COTACAO

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Buscar dados no Pedido Compra³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SC7")
				dbSetOrder(2)
				If dbSeek(xFilial("SC7")+cProd+cForn+"01"+cNumPed)
					nValor	:= SC7->C7_TOTAL
				EndIf
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alimenta aCols 				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Iif(nPosCurso 	> 0, aCols[nPos][nPosCurso]		:= RA8->RA8_CURSO							, Nil)
	Iif(nPosDCur 	> 0, aCols[nPos][nPosDCur]		:= FDesc("RA1",RA8->RA8_CURSO,"RA1_DESC")	, Nil)
	Iif(nPosEnt		> 0, aCols[nPos][nPosEnt]		:= cEntid									, Nil)
	Iif(nPosDEnt	> 0, aCols[nPos][nPosDEnt]		:= cDEntid									, Nil)
	Iif(nPosNFunc 	> 0, aCols[nPos][nPosNFunc] 	:= RA8->RA8_NFUNC							, Nil)
	Iif(nPosValor 	> 0, aCols[nPos][nPosValor] 	:= nValor									, Nil)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Independentemente da Duracao, Campo Horas = Carga Horaria do Curso (RA1)  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("RA1")
	dbSetOrder(1)
	If dbSeek(xFilial("RA1")+RA8->RA8_CURSO)
		Iif(nPosHoras 	> 0, aCols[nPos][nPosHoras] := RA1->RA1_HORAS							, Nil)
		Iif(nPosDurac 	> 0, aCols[nPos][nPosDurac] := RA1->RA1_DURACA							, Nil)
		Iif(nPosUnDur 	> 0, aCols[nPos][nPosUnDur] := RA1->RA1_UNDURA							, Nil)
	EndIf

	Iif(nPosDataDe	> 0, aCols[nPos][nPosDataDe]	:= RA8->RA8_DATADE							, Nil)
	Iif(nPosDataAt	> 0, aCols[nPos][nPosDataAt]	:= RA8->RA8_DATAAT							, Nil)
	Iif(nPosNome	> 0, aCols[nPos][nPosNome]		:= RA8->RA8_NOME  							, Nil)
    Iif(nPosRec		> 0, aCols[nPos][nPosRec]		:= 0  										, Nil)

	Iif(nPosCC		> 0, aCols[nPos][nPosCC]		:= RA8->RA8_CC								, Nil)
	Iif(nPosDCC		> 0, aCols[nPos][nPosDCC]		:= POSICIONE('CTT',1,xFilial('CTT')+RA8->RA8_CC,'CTT_DESC01')	, Nil)
	Iif(nPosDtRef	> 0, aCols[nPos][nPosDtRef]		:= RA8->RA8_DATA							, Nil)

	dbSelectArea("RA8")
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualizacao de Valores RA6 - Curso x Entidade ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RA8")
dbSetOrder(1)
If dbSeek(xFilial("RA8")+cPlan)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Buscar dados da Solicitacao  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC1")
	dbSetOrder(2)
	If dbSeek(xFilial("SC1")+cProd+RA8->RA8_NUMSC)

		If !Empty(SC1->C1_COTACAO)

			dbSelectArea("SC8")
			dbSetOrder(1)
			dbSeek(xFilial("SC8")+SC1->C1_COTACAO)
			While !Eof() .And. SC8->C8_NUM == SC1->C1_COTACAO

				If SC8->C8_PRECO > 0
					cEntid 	:= FDesc("RA0",SC8->C8_FORNECE,"RA0_ENTIDA",,,3)
					cCurso	:= FDesc("RA1",SC8->C8_PRODUTO,"RA1_CURSO",,,3)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava nova cotacao no RA6	 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("RA6")
					dbSetOrder(1)
					If dbSeek(xFilial("RA6")+cEntid+cCurso)
						RecLock("RA6",.F.)
							RA6->RA6_VALOR 	:= SC8->C8_PRECO
							RA6->RA6_DTCOTA	:= SC8->C8_EMISSAO
						MsUnlock()
					EndIf
				EndIf

				dbSelectArea("SC8")
				dbSkip()
			EndDo
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para filtrar aCols.						 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTr050Trm
	aColsM := ExecBlock( "TR050TRM", .F., .F., {aHeader, aCols} )
	If ( ( (ValType( aColsM ) == "A") .and. ( Len( aColsM ) > 0) ), aCols := aClone( aColsM ), )
Endif

oGet:oBrowse:Refresh(.T.)
oGet:Refresh(.T.)

RestArea(aSaveRA8)
RestArea(aSaveSX3)
RestArea(aSaveSC1)
RestArea(aSaveSC7)
RestArea(aSaveArea)

Return .t.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ra2EntidWhen³ Autor³ Emerson Grassi Rocha ³ Data ³ 06/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega variaveis de Memoria da Linha corrente do aCols.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³				                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ X3_WHEN do campo RA2_ENTIDA		                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Ra2EntidWhen()

Local nx 		:= 0
Local nUsaRA2	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria as Variaveis de Memoria - Habilidades (RBH)			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsaRA2 := Len(aHeader)
For nX := 1 To nUsaRA2
	&("M->"+aHeader[nx][2]) := aCols[n][nx]
Next nX

Return .T.



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ra2When()   ³ Autor³ Mauricio MR			³ Data ³ 24/08/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica a possibilidade de edicao dos campos do RA2		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³				                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ X3_WHEN dos campos da tabela RA2							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function RA2When()
Return(RA2Acesso())

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ra2Acesso() ³ Autor³ Mauricio MR			³ Data ³ 24/08/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica a possibilidade de edicao/eliminacao dos dados    ³±±
±±³          ³ do RA2													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³				                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ when e delok da da tabela RA2							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function RA2Acesso(lZera,lDeleta)
Local nPosCurso
Local nPosTurma
Local nPosRealiz
Local nPosRecno
Local lRet		:= .T.
Local nReg		:= 0

Local aRA2Area

Static aChave

DEFAULT lZera 	:= .F.
DEFAULT lDeleta	:= .F.

//-- Inicializa as variaveis staticas da funcao
IF lZera
   aChave	:= NIL

Else
	nPosCurso	:= GdFieldPos("RA2_CURSO")
 	nPosTurma	:= GdFieldPos("RA2_TURMA")
	nPosRealiz	:= GdFieldPos("RA2_REALIZ")
 	nPosRecno	:= GdFieldPos("RA2_REC_WT")

	IF aChave == NIL
	   //- [1] -> Chave de busca
	   //- [2] -> Se encontrou a chave
	   //- [3] -> Se busca
	   aChave:= {xFilial('RA2') + cCod + aCols[n][nPosCurso] + aCols[n][nPosTurma],.F.,.T.}
	Endif

	If nOpcao # 5 .And. nOpcao # 2
		If aCols[n,Len(aCols[n])]      /// Se esta Deletado
			//-- Nao permite delecao de treinamento baixado.
			If nPosRealiz > 0 .And. (aCols[n][nPosRealiz] =="S")
				Aviso(OemToAnsi(STR0010), OemToAnsi(STR0017),{"OK"}) //#Atencao#"Treinamento em andamento ou baixado não pode ser eliminado."
				aCols[n,Len(aCols[n])] := IF(aCols[n,Len(aCols[n])],.F.,.T.)
				oGet:oBrowse:Refresh(.T.)
				oGet:Refresh(.T.)
				lRet:=.F.
		    EndIf
		EndIf
	    If lRet
	       	//-- Se tem WalkThru
	       	If nPosRecno > 0
	       	   nReg		:= aCols[n, nPosRecno]
	       	Else
		     	aRA2Area	:= RA2->(GetArea())
		     	If RA2->(MSSeek(xFilial('RA2') + cCod + aCols[n][nPosCurso] + aCols[n][nPosTurma] ) )
		     	   nReg	:= RA2->(Recno())
		     	Endif
		       	RestArea(aRA2Area)
	       	Endif
	       	//-- Se a linha de dados ja foi gravada alguma vez (registro gerado anteriormente)
	       	If !Empty(nReg)
	       	    //-- Se houver quebra de chave de checagem ou se ainda nao foi feita a checagem de consistencia
	       	    //-- da edicao dos dados.
	       	    IF ( aChave[1] <> ( xFilial('RA2') + cCod + aCols[n][nPosCurso] + aCols[n][nPosTurma] ) ) .or.;
	       	       aChave[3]
	       	        //-- Verifica se existem dependencias  (processo de treinamento baixado ou em andamento)
			    	lRet := Trma050ChkDel( "RA2", nReg , nOpcao, cCod, aCols[n][nPosCurso],aCols[n][nPosTurma],.T.,.F., .T. )
					aChave[1] := (xFilial('RA2') + cCod + aCols[n][nPosCurso] + aCols[n][nPosTurma])
					aChave[2] := lRet
					aChave[3] := .F.
				Else
				    //-- Retorna a ultima posicao da chave de busca para demonstracao ou nao de mensagem
				    //-- de inconsistencia na operacao de edicao.
					lRet	:= aChave[2]
				Endif

		    	//-- Demonstracao mensagem de inconsistencia na edicao dos dados.
		    	IF !lRet
					Aviso(OemToAnsi(STR0010), IIf(lDeleta,OemToAnsi(STR0017),OemToAnsi(STR0018)),{"OK"}) //Atencao"###"Treinamento em andamento ou baixado não pode ser eliminado."###"Este campo não pode ser modificado para treinamento em andamento ou baixado."
					//-- "Este campo não pode ser modificado para treinamento em andamento ou baixado." ou
					//-- "Treinamento em andamento ou baixado não pode ser modificado ou eliminado."
		    	Endif

	    	Endif
	    Endif

	EndIf
endif
Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr050Custo³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 29/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula custo estimado.	                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tr050Custo()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TRMA050 - VALID do campo RA2_VAGAS (SX3).                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr050Custo()
Local aSaveArea := GetArea()
Local nPosVal	:= GdFieldPos("RA2_CUSTO")
Local nPosEnt	:= GdFieldPos("RA2_ENTIDA")
Local nPosCur	:= GdFieldPos("RA2_CURSO")

If nPosEnt > 0 .And. nPosCur > 0 .And. nPosVal > 0

	dbSelectArea("RA6")
	dbSetOrder(1)
	If dbSeek(xFilial("RA6") + aCols[n][nPosEnt] + aCols[n][nPosCur])
		aCols[n][nPosVal] := RA6->RA6_VALOR * M->RA2_VAGAS
	Else
		dbSelectArea("RA1")
		dbSetOrder(1)
		If dbSeek(xFilial("RA1")+aCols[n][nPosCur])
			aCols[n][nPosVal] := RA1->RA1_VALOR * M->RA2_VAGAS
		EndIf
	EndIf
EndIf

RestArea(aSaveArea)

Return .T.

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³15/01/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³TRMA050                                                     ³
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
Local aRotina := { 	{ STR0001, 'PesqBrw' , 0, 1,,.F.}, ;		//'Pesquisar'
						{ STR0002, 'Tr050Rot', 0, 2}, ;		//'Visualizar'
						{ STR0003, 'Tr050Rot', 0, 3}, ;		//'Incluir'
						{ STR0004, 'Tr050Rot', 0, 4}, ;		//'Alterar'
						{ STR0005, 'Tr050Rot', 0, 5,3},;	//'Excluir'
						{ STR0008, 'Tr050Leg', 0, 2, ,.F.} }		//'Legenda'
Local aRet

If SuperGetMv( "MV_INTTREI", ,.F.)
	aAdd(aRotina, {STR0020, 'Tr050Int', 0, 2, ,.F.})
EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Ponto de entrada para adicionar opcoes de menu.			   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If ExistBlock( "TRA050MN")
	IF ( ValType( aRet := ExecBlock( "TRA050MN" ,.F.,.F.,{aClone(aRotina)}, .F. ) ) == "A" )
   		aRotina := aClone(aRet)
	Endif
EndIf

Return aRotina


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ra2EditGet()³ Autor³ Mauricio MR			³ Data ³ 23/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Nao permite a edicao de campos nao chaves para treinamentos³±±
±±³          ³ ja baixados.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³				                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ cFieldOK.												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Ra2EditGet()
Local aRA2Area
Local lRet		:= .T.
Local cReadVar	:= ReadVar()
Local nPosCampo	:= GdFieldPos(SUBSTR(cReadVar,4))
Local nPosDesc	:= 0
Local nPosCurso	:= GdFieldPos("RA2_CURSO")
Local nPosTurma	:= GdFieldPos("RA2_TURMA")
Local nPosRecno	:= GdFieldPos("RA2_REC_WT")
Local nReg   	:= 0

//-- Se tem WalkThru
If nPosRecno > 0
   nReg		:= aCols[n, nPosRecno]
   RA2->(DbGoto(nReg))
Else
   	aRA2Area	:= RA2->(GetArea())
   	If RA2->(MSSeek(xFilial('RA2') + cCod + aCols[n][nPosCurso] + aCols[n][nPosTurma] ) )
   	   nReg	:= RA2->(Recno())
   	Endif
   	RestArea(aRA2Area)
Endif
//-- Se a linha de dados ja foi gravada alguma vez (registro gerado anteriormente)
If !Empty(nReg)
    //-- Verifica campos não chaves
	IF ( &cReadVar  <> aCols[n][nPosCampo] ) .and. ! (  SUBSTR(cReadVar,4) $ "RA2_CURSO.RA2_TURMA")

		IF ( RA2->RA2_REALIZ='S')
			Aviso(STR0010,STR0018,{"Ok"}) //"Atencao"###"Este campo não pode ser modificado para treinamento em andamento ou baixado."
			lRet	:= .F.
			IF SUBSTR(cReadVar,4) $ "RA2_ENTIDA"
			   	 aCols[n][GdFieldPos("RA2_DESCEN")] := Tr050Curso(.T.,2)
			ElSEIF SUBSTR(cReadVar,4) $ "RA2_INSTRU"
				   aCols[n][GdFieldPos("RA2_NOMEIN")] :=Tr050Curso(.T.,4)
			ELSEIF SUBSTR(cReadVar,4) $ "RA2_SINON"
					 aCols[n][GdFieldPos("RA2_DESCSI")] :=Tr050Curso(.T.,5)
			Endif
			&cReadVar	:= aCols[n][nPosCampo]
			oGet:oBrowse:Refresh(.T.)
		Endif
	Endif
Endif
return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr050EntCur³ Autor ³ Equipe RH - N3       ³ Data ³ 08/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Filtra Entidade de acordo com o Curso selecionado.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATRM - Consulta Padrao: RA0                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr050EntCur()

Local cEntid		:= ReadVar()
Local cCurso		:= StrTran(cEntid,"ENTIDA", "CURSO")
Local cCampo		:= Substr(cCurso,4)
Local cCodCurs		:= ""
Local cRel			:= "@# @#"
Local cCodEntd		:= ""
Local aAreaRA6		:= RA6->(GetArea())

If IsInCallStack("TRMA050") .or. IsInCallStack("TRMM100")// Treinamento

	If IsInGetDados( { cCampo } )               // Na GetDados
		cCodCurs	:= GDFieldGet(cCampo, n)
	Else
		cCodCurs := &(cCurso)					// Na Enchoice
	EndIf

	RA6->( DbSetOrder(2) ) //Filial + Curso + Entidade
	If RA6->( DbSeek( xFilial("RA6") + cCodCurs ) )
		While RA6->(!EoF()) .AnD. RA6->RA6_CURSO == cCodCurs
			cCodEntd += RA6->RA6_ENTIDA + "/"
			RA6->(DbSkip())
		EndDo
		cRel := "@#RA0->RA0_ENTIDA $ '"+ cCodEntd +"'@#"
	EndIf

EndIf
If FunName() == "GPEA320"
    cRel:= Strtran(cRel,"@#","")
    cRel:= "@#"+ IIF(Empty(cRel),"",cRel+" .And.")+ " !Empty(RA0->RA0_CGC)@#"
EndIf

Return cRel


//-------------------------------------------------------------------
/*/{Protheus.doc} Tr050Int()
Interesse em treinamento

@author Emerson Campos
@since 09/07/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function Tr050Int()
Local lRet	:= .T.
Local oDlg
Local oDlg1
Local oLbx
Local oLbx1
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjCoords		:= {}
Local aObjSize		:= {}
Local aList			:= {}
Local aList1			:= {}
Local cAliasQry		:= GetNextAlias()
Local cAliasQry1		:= GetNextAlias()
Local cRA1Branch		:= xFilial("RA1")
Local nPosLbx			:= 0
Local lOk				:= .F.
/**************************************************************
Monta as Dimensoes dos Objetos
**************************************************************/
aAdvSize		:= MsAdvSize(,.T.,380)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 020 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

BeginSql alias cAliasQry
	      SELECT RA3.RA3_CURSO
	           , RA1.RA1_DESC
	           , RA3.RA3_FILIAL
	           , COUNT(RA3.RA3_CURSO) QTDE
	        FROM %table:RA3% RA3
	  INNER JOIN %table:RA1% RA1
	          ON RA1.RA1_FILIAL = %Exp:cRA1Branch%
	         AND RA1.RA1_CURSO = RA3.RA3_CURSO
	         AND RA1.%NotDel%
	       WHERE RA3.RA3_TURMA = ''
	         AND RA3.RA3_CALEND = ''
	         AND RA3.RA3_RESERV = 'S'
	         AND RA3.%NotDel%
	    GROUP BY RA3.RA3_CURSO, RA1.RA1_DESC, RA3.RA3_FILIAL
EndSql

If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		Aadd(aList,{(cAliasQry)->RA3_CURSO,(cAliasQry)->RA1_DESC,(cAliasQry)->QTDE, (cAliasQry)->RA3_FILIAL})

		(cAliasQry)->(DBSkip())
	Enddo
Else
	Aadd(aList,{STR0028,"","",""})//Não há registros para esta consulta!
EndIf

DEFINE MSDIALOG oDlg FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE STR0020 PIXEL	// "Interesse em Treinamento"

	@ aObjSize[1,1], aObjSize[1,2]	SAY OemToAnsi(STR0027)	PIXEL //"Os cursos abaixo possuem funcionários interessados em participar quando houver nova turma disponível"
	@ aObjSize[2,1],aObjSize[2,2] LISTBOX oLbx FIELDS;
	 	HEADER OemtoAnsi(STR0021),;	//"Cod. Curso"
				OemtoAnsi(STR0022),;	//"Nome do Curso"
				OemtoAnsi(STR0023);	//"Qtde Interessados"
				SIZE aObjSize[2,3],aObjSize[2,4] OF oDlg PIXEL;
	ON DBLCLICK (If(Empty(aList[oLbx:nAt,2]), lOk := .F., lOk := .T.), nPosLbx:=oLbx:nAt, oDlg:End() )
	oLbx:SetArray(aList)
	oLbx:bLine := { || {aList[oLbx:nAt,1],aList[oLbx:nAt,2],aList[oLbx:nAt,3]}}

	bSet15 :=  {|| If(Empty(aList[oLbx:nAt,2]), lOk := .F., lOk := .T.), nPosLbx:=oLbx:nAt, oDlg:End()}
	bSet24 :=  {|| lOk := .F., oDlg:End()}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bSet15, bSet24) CENTERED

If ( lOk )
	lOk := .F.

	BeginSql alias cAliasQry1
		      SELECT SRA.RA_MAT
		           , SRA.RA_NOME
		        FROM %table:SRA% SRA
		  INNER JOIN %table:RA3% RA3
		          ON SRA.RA_FILIAL = RA3.RA3_FILIAL
		         AND SRA.RA_MAT = RA3.RA3_MAT
		         AND RA3.RA3_FILIAL = %Exp:aList[nPosLbx,4]%
		         AND RA3.RA3_CURSO = %Exp:aList[nPosLbx,1]%
		         AND RA3.RA3_TURMA = ''
				 AND RA3.RA3_CALEND = ''
		         AND RA3.%NotDel%
		       WHERE SRA.%NotDel%
	EndSql

	If !(cAliasQry1)->(Eof())
		While !(cAliasQry1)->(Eof())
			Aadd(aList1,{(cAliasQry1)->RA_MAT,(cAliasQry1)->RA_NOME})

			(cAliasQry1)->(DBSkip())
		Enddo
	Else
		Aadd(aList1,{STR0028,''})//Não há registros para esta consulta!
	EndIf

	DEFINE MSDIALOG oDlg1 FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE STR0024 PIXEL	// "Funcionários Interessados em Treinamento"

		@ aObjSize[1,1], aObjSize[1,2]		SAY OemToAnsi(STR0021)+":"	PIXEL 	//"Cod. Curso"
		@ aObjSize[1,1], aObjSize[1,2]+30	SAY aList[nPosLbx,1]			PIXEL
		@ aObjSize[1,1], aObjSize[1,2]+60	SAY OemToAnsi(STR0022)+":"	PIXEL 	//"Nome do Curso"
		@ aObjSize[1,1], aObjSize[1,2]+100	SAY aList[nPosLbx,2]			PIXEL

		@ aObjSize[2,1],aObjSize[2,2] LISTBOX oLbx1 FIELDS;
		 	HEADER OemtoAnsi(STR0025),;	//"Matrícula"
					OemtoAnsi(STR0026),;	//"Funcionário"
					SIZE aObjSize[2,3],aObjSize[2,4] OF oDlg1 PIXEL
		oLbx1:SetArray(aList1)
		oLbx1:bLine := { || {aList1[oLbx1:nAt,1],aList1[oLbx1:nAt,2]}}

		bSet15A :=  {|| lOk := .T., oDlg1:End()}
		bSet24A :=  {|| lOk := .F., oDlg1:End()}

	ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1, bSet15A, bSet24A) CENTERED

	If lOk
		Tr050Int()
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fConsTrei()
Função para definição de qual consulta padrão ativar para o campo RA2_ESOC
@type      	Function
@author   	Silvia Taguti
@since		11/02/2021
@version	1.0
@return		lRet
/*/
Function fConsTrei()
Local aArea			:= GetArea()
Local lRet			:= .T.
Local lIntegra      := .F.
Local cVersEnvio	:= ""
Local cVersGPE		:= ""

lIntegra := Iif(FindFunction("fVersEsoc"), fVersEsoc("S-2200", .F., /*@aRetGPE*/, /*@aRetTAF*/, @cVersEnvio,@cVersGPE), .F. )

If cVersGPE < "9.0"
	ConPad1(,,, "MDTV2M")
Else
	GP310SXB('S139','CODTREI')
Endif

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RA2TrVld()
Função para Validação do campo RA2_ESOC dependendo do Layout utilizado
@type      	Function
@author   	Silvia Taguti
@since		11/02/2021
@version	1.0
@return		lRet
/*/
Function RA2TrVld()
Local aArea			:= GetArea()
Local cVersEnvio	:= ""
Local cVersGPE		:= ""
Local lRet			:= .T.
Local lIntegra      := .F.

lIntegra := Iif(FindFunction("fVersEsoc"), fVersEsoc("S-2200", .F., /*@aRetGPE*/, /*@aRetTAF*/, @cVersEnvio,@cVersGPE), .F. )

If cVersGPE < "9.0"
	If !Empty(M->RA2_ESOC)
		lRet := EXISTCPO("V2M",M->RA2_ESOC,2)
	Endif
Else
	If !Empty(M->RA2_ESOC)
		lRet := ValidRCC('S139', M->RA2_ESOC,1,4)
	Endif
Endif

RestArea(aArea)

Return lRet
