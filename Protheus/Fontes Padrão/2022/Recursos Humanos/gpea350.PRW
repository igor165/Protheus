#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA350.CH"
#INCLUDE "PROTHEUS.CH"

#define Confirma 1
#define Redigita 2
#define Abandona 3

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Gpea350  ³ Autor ³ Andreia dos Santos    ³ Data ³ 25/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Comunicado de Acidente do Trabalho             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³15/08/14³TQIBW3³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³        ³      ³ da a limpeza.                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Gpea350

LOCAL cFiltraSRA				//Variavel para filtro
LOCAL aIndexSRA		:= {}		//Variavel Para Filtro

Private bFiltraBrw	:= {|| Nil}//Variavel para Filtro
Private aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Private aFldRel		:= {"RC9_NUMERO", "RA_NOME", "RA_ADMISSA"}
Private aRotina		:= MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

cCadastro := OemToAnsi(STR0006)  //"Cadastro de Comunicado de Acidente do Trabalho"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Arquivo Esta Vazio                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ChkVazio("SRA")
	Return
Endif

//Tratamento de acesso a Dados Sensíveis
aFldRel := Iif( aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ), {} )
If aOfusca[2] .And. (aScan( aFldRel, {|x| x:cfield == "RC9_NUMERO"}) > 0)
	//"Dados Protegidos- Acesso Restrito: Este usuário não possui permissão de acesso aos dados dessa rotina. Saiba mais em {link documentação centralizadora}"
	Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFiltraRh 	:=	CHKRH("GPEA350","SRA","1")
bFiltraBrw 	:= 	{|| FilBrowse("SRA",@aIndexSRA,@cFiltraRH) }
Eval(bFiltraBrw)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SRA")
mBrowse( 6, 1,22,75,"SRA",,,,,,fCriaCor() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("SRA",aIndexSra)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp350Atu  ³ Autor ³ Andreia dos Santos    ³ Data ³ 25/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de (Vis.,Inc.,Alt. e Exc. de  CAT                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ gp350Atu(ExpC1,ExpN1,ExpN2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function gp350Atu(cAlias,nReg,nOpcx)

Local cSaveMenuh
Local nCnt
Local GetList	:=	{}
Local a350Field :=	{"RC9_FILIAL","RC9_MAT"}
Local nStt      :=	2
Local nLenght	:=	Len(a350Field)-1
Local cMat      := 	SRA->RA_MAT
Local cNome     := 	SRA->RA_NOME
Local nSavRec   := 	RecNo()
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local lOfuscaNom	:= .F.
Local lOfuscaAdm	:= .F.
Local oFont
Local oGroup

Local aNoFields 	:= 	{"RC9_FILIAL","RC9_MAT"}
Local bSeekWhile	:= {|| RC9->RC9_FILIAL + RC9->RC9_MAT }
Local nRC9Ord		:= RetOrdem( "RC9" , "RC9_FILIAL+RC9_MAT+DTOS(RC9_DATA)" )
Private nPosRec		:= 0

Private aColsRec := {}   //--Array que contem o Recno() dos registros da aCols

cCod 	:= SRA->RA_MAT
cDesc	:= SRA->RA_NOME

//Tratamento dados sensíveis
If aOfusca[2] .And. Len(aFldRel) > 0
	lOfuscaNom := aScan( aFldRel, {|x| x:cfield == "RA_NOME"}) > 0
	lOfuscaAdm := aScan( aFldRel, {|x| x:cfield == "RA_ADMISSA"}) > 0
	cNome := If(lOfuscaNom,Replicate('*',15),OemToAnsi(SRA->RA_NOME))
	cDesc := cNome
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Array de Campos Alteraveis                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias := "RC9"

While .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe algum dado no arquivo                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( cAlias )
	dbSeek( cFilial + cMat )
   	nCnt := 0
	(cAlias)->(dbEval({||nCnt++},,{||RC9_FILIAL + RC9_MAT == cFilial + cMat}))

   	If nCnt > 0  .And. nOpcx = 3    //--Quando Inclusao e existir Registro
		Aviso(STR0010,STR0011,{'OK'}) //"Atencao"###"Ja existe C.A.T. para este funcionario. Utilize a opcao 'Alterar'"
		Exit
    Elseif nCnt = 0 .And. nOpcx # 3  //--Quando Nao for Inclusao e nao existir Registro
      Aviso(STR0010,STR0012,{'OK'}) //"Atencao"###"Nao existem Comunicado de Acidente de Trabalho cadastrados para este funcionario. Utilize a opcao 'Incluir'"
		Exit
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a entrada de dados do arquivo                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aTELA[0][0],aGETS[0],aHeader[0],Continua:=.F.

	nOpcA := 0
	nCnt   :=0

	dbSelectArea(cAlias)
	FillGetDados(nOpcX							,; //1-nOpcX - número correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
				 cAlias							,; //2-cAlias - area a ser utilizada;
				 nRC9Ord						,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
				 xFilial(cAlias)+cCod			,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
				 bSeekWhile						,; //5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
				 NIL							,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-código, condição a ser utilizado para executar o Loop no While;2º - array bi-dimensional contendo N.. condições, em que o 1º elemento é o bloco condicional, o 2º é bloco a ser executado se verdadeiro e o 3º é bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
				 aNoFields		   	    		,; //7-aNoFields - array contendo os campos que não estarão no aHeader;
				 NIL							,; //8-aYesFields - array contendo somente os campos que estarão no aHeader;
				 NIL							,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usuário;
				 NIL							,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
				 NIL							)  //11-bMontCols - bloco contendo função especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}

	nPosRec	:=GdfieldPos("RC9_REC_WT")
	nPosData:=GdfieldPos("RC9_DATA")
	If nOpcX == 3
		aCols[1][nPosData]:= dDataBase
	EndIf
	cGet := cCod + " - " + cDesc

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	aAdd( aObjCoords , { 015 , 020 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0007) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF GetWndDefault() PIXEL	//"Comunicado de acidentes de trabalho
	@ aObjSize[1,1] , aObjSize[1,2] GROUP oGroup TO ( aObjSize[1,3] - 3 ),( ( aObjSize[1,4]/100*10 - 2 ) )				LABEL OemToAnsi(STR0008) OF oDlg PIXEL	// "Matricula:"
	oGroup:oFont:= oFont
	@ aObjSize[1,1] , ( ( aObjSize[1,4]/100*10 ) ) GROUP oGroup TO ( aObjSize[1,3] - 3 ),( aObjSize[1,4]/100*80 - 2 )	LABEL OemToAnsi(STR0009) OF oDlg PIXEL	// "Nome:"
	oGroup:oFont:= oFont
	@ aObjSize[1,1] , ( aObjSize[1,4]/100*80 ) GROUP oGroup TO ( aObjSize[1,3] - 3 ),aObjSize[1,4]						LABEL OemToAnsi(STR0017) OF oDlg PIXEL	// "Admiss„o:"
	oGroup:oFont:= oFont
	@ ( ( aObjSize[1,1] ) + 8 ) , ( aObjSize[1,2] + 5 )				SAY StrZero(Val(SRA->RA_MAT),Len(SRA->RA_MAT))					SIZE 050,10 OF oDlg PIXEL FONT oFont
	@ ( ( aObjSize[1,1] ) + 8 ) , ( ( aObjSize[1,4]/100*10 ) + 5 )	SAY If(lOfuscaNom,Replicate('*',15),OemToAnsi(SRA->RA_NOME)) 	SIZE 146,10 OF oDlg PIXEL FONT oFont
	@ ( ( aObjSize[1,1] ) + 8 ) , ( ( aObjSize[1,4]/100*80 ) + 5 )	SAY If(lOfuscaAdm,Replicate('*',10),Dtoc(SRA->RA_ADMISSA))		SIZE 050,10 OF oDlg PIXEL FONT oFont

	oGet := MSGetDados():New(aObjSize[2,1],aObjSize[2,2],aObjSize[2,3],aObjSize[2,4],nOpcx,"gp350LinOk","gp350TudOk","",If(nOpcx=2.Or.nOpcx=5,Nil,.T.),,1)
   	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca:=If(nOpcx=5,2,1),If(oGet:TudoOk(),oDlg:End(),nOpca:=0)},{||oDlg:End()})

    //--Se nao for Exclusao
    If nOpcx # 5
        IF nOpcA == Redigita
            LOOP
        ELSEIF nOpcA == Confirma .And. nOpcx # 2
            Begin Transaction
                //--Gravacao
                gp350Grava(cAlias,nOpcx)
                //--Processa Gatilhos
                EvalTrigger()
            End Transaction

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de Entrada executado apos a gravacao da tabela ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock( "Gp350Grv" )
				ExecBlock( "Gp350Grv", .F., .F. )
			Endif

        Endif
    //--Se for Exclusao
    Elseif nOpca = 2 .And. nOpcx = 5
        Begin Transaction
            gp350Dele()
        End Transaction
    Endif

	Exit
EndDo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade da janela                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias := "SRA"
dbSelectArea(cAlias)
Go nSavRec

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp350Dele ³ Autor ³ Andreia dos Santos    ³ Data ³ 25/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Deleta os Registro de Comunicado de Acidente de Trabalho   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gp350Dele                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function gp350Dele()

Local cAlias := "RC9"
Local nX

nCnt := 0
For nx = 1 to Len(aCols)
    dbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
    RecLock(cAlias,.F.,.T.)
    dbDelete( )
    MsUnlock()
    nCnt++
Next nx
WRITESX2(cAlias,nCnt)
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³                   ROTINAS DE CRITICA DE CAMPOS                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp350Grava³ Autor ³ Andreia dos Santos    ³ Data ³ 25/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava no arquivo de Comunicado de Acidente de Trabalho     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gp350Grava                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function gp350Grava(cAlias)

Local n
Local ny		:=	0
Local nMaxArray	:=	Len(aHeader)
Local nDepIr 	:= 0
Local nDepSf 	:= 0

dbSelectArea(cAlias)
For n:=1 TO Len(aCols)
	Begin Transaction

    If aCols[n][nPosRec] > 0
        MSGoto(aCols[n][nPosRec])
        RecLock(cAlias,.F.,.T.)
		lTravou:=.T.
	Else
	    If !(aCols[n][Len(aCols[n])])
			RecLock(cAlias,.T.)
			lTravou:=.T.
		EndIf
    Endif
	If lTravou
        //--Verifica se esta deletado
        If aCols[n][Len(aCols[n])]
            dbDelete()
        Else
	        Replace RC9->RC9_FILIAL WITH SRA->RA_FILIAL
	        Replace RC9->RC9_MAT    WITH SRA->RA_MAT
        Endif
	    For ny := 1 To nMaxArray
	        cCampo    := Trim(aHeader[ny][2])
	        xConteudo := aCols[n,ny]
	        Replace &cCampo With xConteudo
	    Next ny
	Endif
	MsUnlock()
    End Transaction
Next n

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp350LinOk³ Autor ³ Andreia dos Santos    ³ Data ³ 25/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Critica linha digitada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function gp350LinOk(o)

Local lRet		:= .T.
Local nX

If aCols[n,len(aHeader)+1]  = .F.

	For nx = 1 To Len(aHeader)
		If Empty(aCols[n,nx])
			If Trim(aHeader[nx,2]) == "RC9_DATA" .and. lRet
				AVISO(STR0010,STR0013,{'OK'}) //"Atencao"###"Informe a data da CAT"
				lRet := .F.
				Exit
			Endif
			If Trim(aHeader[nx,2]) == "RC9_NUMERO" .and. lRet
				Aviso(STR0010,STR0014,{'OK'}) //"Atencao"###"Informe o tipo do Numero da CAT"
				lRet := .F.
				Exit
			Endif
		Endif
	Next nx
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp350TudOk³ Autor ³ Andreia dos Santos    ³ Data ³ 26/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function gp350TudOk(o)
Local lRetorna	:= .T.

Return lRetorna

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³07/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA350                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define array contendo as Rotinas a executar do programa      ³
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
 Local aRotina :=  {	{ STR0001 , "PesqBrw", 0 , 1,,.F.},;  //"Pesquisar"
						{ STR0002 , "gp350atu", 0 , 2},;  //"Visualizar"
                     	{ STR0003 , "gp350Atu", 0 , 4},;  //"Incluir"
                     	{ STR0004 , "gp350Atu", 0 , 4},;  //"Alterar"
                     	{ STR0005 , "gp350Atu", 0 , 5},;  //"Excluir"
 						{ STR0018 , "gpLegend"  , 0 , 5 , ,.F.} }  //"Legenda"

Return aRotina
