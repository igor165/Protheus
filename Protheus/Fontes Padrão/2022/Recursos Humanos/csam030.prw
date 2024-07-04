#include "Protheus.ch"
#include "font.ch"
#include "colors.ch"
#include "CSAM030.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o       ³ CSAM030  ³ Autor ³ Cristina Ogura       ³ Data ³19.10.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o    ³ Adequacao da Tabela Salarial para o funcionario          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso          ³ CSAM030                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ BOPS       ³  Motivo da Alteracao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Mohanad Odeh ³21/06/13³Requisito:  ³Padronização dos fontes. Alterada   ³±±
±±³             ³        ³RHU210_03_11³chamada da rotina de Histor Salarial³±±
±±³Cecilia Car. ³18/07/14³TPZVUR      ³Efetuada a limpeza do fonte.        ³±±
±±³Gabriel A.   ³09/08/16³TVMP76      ³Ajuste para não apresentar os       ³±±
±±³             ³        ³            ³salários menores que o atual.       ³±±
±±³Gabriel A.   ³18/08/16³TVMP76      ³Ajuste para apresentar os salários  ³±±
±±³             ³        ³            ³de acordo com o nível da faixa.     ³±±
±±³Gabriel A.   ³04/10/16³TVMP76      ³Ajuste para filtrar apenas os       ³±±
±±³             ³        ³            ³funcionários que possuem tabela     ³±±
±±³             ³        ³            ³salarial configurada.               ³±±
±±³Marcelo F.   ³10/03/17³MRH-8227    ³Ajuste no layout e carregamento das ³±±
±±³             ³        ³tkt 596725  ³faixas para a adequação salarial.   ³±±
±±³Oswaldo L    ³08-05-17³DRHPONTP11  ³Projeto SOYUZ ajuste Ctree          ³±±
±±³M. Silveira  ³24/05/17³DRHPONTP-230³Ajuste na Cs030VerTab para localizar³±±
±±³             ³        ³            ³o nivel da tabela da forma correta. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CSAM030

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
Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemtoAnsi(STR0004)		//"Adequacao do funcionario a Tabela Salarial"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis do Pergunte ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oOk, oNo, o1Ok
Private cTabela		:= ""
Private cFilDe		:= ""
Private cFilAte		:= ""
Private cGrupoDe	:= ""
Private cGrupoAte	:= ""
Private cCCDe		:= ""
Private cCCAte		:= ""
Private cFuncaoDe	:= ""
Private cFuncaoAte	:= ""
Private cCargoDe	:= ""
Private cCargoAte	:= ""
Private cMatDe		:= ""
Private cMatAte		:= ""
Private cTpAlt		:= ""
Private dDtAlt		:= Ctod("")
Private dDtRefDe		:= Ctod("")
Private dDtRefAte		:= Ctod("")
Private nOrdem		:= 0
Private cEstou		:= ""
Private nTipo		:= 0

Private cNtxAlias := GetNextAlias()
Private oArq1Tmp
Private oArqNtxTmp

Private a2Lbx		:= {}
Private a3Lbx		:= {}
Private aGuarda		:= {}
Private aTabela		:= {}
Private aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Private o1Lbx, o2Lbx, o3Lbx, oGet1, oGet2
Private cGet1		:= ""
Private cGet2		:= ""

	//Tratamento de acesso a Dados Sensíveis
	If aOfusca[2] .AND. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_SALARIO"} ) )
		//"Dados Protegidos-Acesso Restrito"
		Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
		Break
	EndIf

dbSelectArea("SRA")
dbSetOrder(1)

mBrowse(6, 1, 22, 75, "SRA",,,,"SRA->RA_SITFOLH#'S'")

dbSelectArea("SRA")
dbSetOrder(1)

dbSelectArea("RB6")
dbSetOrder(1)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CS030Adeq ³ Autor ³ Cristina Ogura       ³ Data ³ 19.10.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina Principal para adequacao salarial                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM030       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CS030Adeq(cAlias,nReg,nOpcx)
Local oDlgMain	, oGroup, oGroup1, oGroup2
Local oBtn1		, oBtn2
Local oVerde	, oVermelho, oAzul
Local aSaveArea	:= GetArea()
Local c1Lbx		:= ""
Local cDescTab	:= ""
Local cAcessaRB6:= &("{ || " + ChkRH(FunName(),"RB6","2") + "}")
Local lSair 	:= .F.
Local aButtons	:= {}
Local aAvFields := {}
Local aPDFields := {}
Local aOfuscaCpo:= { .F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F. ,.F. ,.F. ,.F. ,.F. }
Local nX		:= 0
Local nPos		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Dimensionar Tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aCoord		:= {}
Local aLbxCoord1	:= {}
Local aLbxCoord2	:= {}
Local aLbxCoord3	:= {}
Local aGdCoord		:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas na Trajetoria Laboral ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "MEX"

	Private aSraHeader 	:= {}
	Private aSraVirtual	:= {}
	Private aSraVisual 	:= {}
	Private aSraCols	:= {}
	Private aSraFields	:= {}
	Private aHeaderRCP	:= {}			// vetor com o cabecalho da GetDados RCP. (variavel para getdados da tabela RCP)
	Private nPosRCP		:= 0
	Private aModTraj	:= {}
	Private aRCPCols	:= {}			// vetor com as colunas da GetDados RCP. (variavel para getdados da tabela RCP)
	Private aRCPColsAnt	:= {}			// vetor com as colunas da GetDados RCP. (variavel para getdados da tabela RCP)
	Private aSvSraCols	:= {}

EndIf

Cs030LePerg(.F.)

If Empty(dDtRefAte)
	Help(,,".RHDTTABSAL.",,STR0057,3,1)	//Preencha o campo 'Data de Referência Até:'.
	Return Nil
EndIf

dbSelectArea("RB6")
dbSetOrder(1)
If !dbSeek(xFilial("RB6")+cTabela)
	Help("",1,"CS030NOTAB")	//Defina a tabela salarial nos parametros.
	RestArea(aSaveArea)
	Return Nil
EndIf

If !Eval(cAcessaRB6)
	RestArea(aSaveArea)
	Return Nil
EndIf

cDescTab:= RB6->RB6_DESCTA
nTipo	:= RB6->RB6_TIPOVL
aTabela := {}
// Monta os dados da Tabela Salarial
Cs030MontTab()

If 	Len(aTabela) == 0
	Help("",1,"CS030VLTAB")	//Defina os valores da faixa salarial
	RestArea(aSaveArea)
	Return Nil
EndIf

oOk 	:= LoadBitmap( GetResources(), "Enable" )
oNo 	:= LoadBitmap( GetResources(), "LBNO" )
o1Ok 	:= LoadBitmap( GetResources(), "LBOK" )

oVerde  	:= LoadBitmap( GetResources(), "BR_VERDE" )
oVermelho  	:= LoadBitmap( GetResources(), "BR_VERMELHO" )
oAzul	  	:= LoadBitmap( GetResources(), "BR_AZUL" )

// Cria arquivos temporarios para o Listbox
CS030Cria()

// Monta os dados do ListBox
Processa({||Cs030Mont()},OemToAnsi(STR0024))

If 	Len(aGuarda) == 0
	Help("",1,"Cs030NOFUN")
	lSair := .T.
EndIf

If !lSair
	dbSelectArea("TR1")
	dbGotop()

	// Monta os listbox conforme o funcionario posicionado
	Cs030Troca(TR1->TR1_FILIAL,TR1->TR1_MAT,.T.)

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

	aCoord 		:= { (aObjSize[1,1]), (aObjSize[1,2]),	(aObjSize[1,3]), (aObjSize[1,4]) }
	aLbxCoord1	:= { (aObjSize[1,1]+20), (aObjSize[1,2]+5), 			(aObjSize[1,3]-70),(aObjSize[1,4]*0.33-10) }
	aLbxCoord2	:= { (aObjSize[1,1]+50), (aObjSize[1,4]*0.33 + 5), 	(aObjSize[1,3]-70),(aObjSize[1,4]*0.33-10) }
	aLbxCoord3	:= { (aObjSize[1,1]+50), (aObjSize[1,4]*0.66 + 5), 	(aObjSize[1,3]-70),(aObjSize[1,4]*0.33-10) }
	aGdCoord	:= { (aObjSize[1,1]+20), (aObjSize[1,4]*0.2 + 2 + 5)	, (aObjSize[1,3] - 10), (aObjSize[1,4]-5) }

	DEFINE MSDIALOG oDlgMain FROM	aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cCadastro OF oMainWnd  PIXEL

		@ aCoord[1]+5,aCoord[2]+5 SAY OemToAnsi(STR0005)	PIXEL			//"Tabela Salarial: "
		@ aCoord[1]+5,aCoord[2]+55 SAY cTabela	+ " - " + cDescTab PIXEL

		//Primeiro quadro
		@ aCoord[1]+20,aCoord[2]+5 GROUP oGroup  TO aCoord[3],(aObjSize[1,4]*0.33) LABEL STR0021 OF oDlgMain PIXEL //"Nome: "

		@ aLbxCoord1[1]+10,aLbxCoord1[2]+5 LISTBOX o1Lbx VAR c1Lbx FIELDS;
			 	 HEADER 	"",;
							OemtoAnsi(STR0006),;		//"Fil."
							OemtoAnsi(STR0007),;		//"Nome"
							OemtoAnsi(STR0008),;		//"Matricula"
							OemtoAnsi(STR0009),;		//"Salario"
							OemtoAnsi(STR0010),;		//"Ptos Func"
							OemtoAnsi(STR0011),;		//"Ptos Cargo"
							OemtoAnsi(STR0012),;		//"Cargo"
							OemtoAnsi(STR0013),;		//"Descr. Cargo"
							OemtoAnsi(STR0014),;		//"Centro Custo"
							OemtoAnsi(STR0015),;		//"Descr. Centro Custo"
							OemtoAnsi(STR0016),;		//"Fun‡„o "
							OemtoAnsi(STR0017);			//"Descr. Fun‡„o"
					COLSIZES 	GetTextWidth(0,"W"),;
								GetTextWidth(0,Replicate("B",FWGETTAMFILIAL)),;
								GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"),;
								GetTextWidth(0,"BBBBBB"),;
								GetTextWidth(0,"BBBBBBBBBBBB"),;
								GetTextWidth(0,"BBBBBBBBBB"),;
								GetTextWidth(0,"BBBBBBBBBB"),;
								GetTextWidth(0,"BBBBB"),;
								GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"),;
								GetTextWidth(0,"BBBBBBBBB"),;
								GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"),;
								GetTextWidth(0,"BBBBB"),;
								GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB") SIZE aLbxCoord1[4]-5,aLbxCoord1[3]-15 OF oDlgMain PIXEL;
		ON CHANGE (Cs030Troca(TR1->TR1_FILIAL,TR1->TR1_MAT,.F.))

		o1Lbx:nFreeze := 1
		o1Lbx:bLine:= {||{If(	TR1->TR1_MARCA == 2, oVermelho, (Iif(TR1->TR1_MARCA == 1, oVerde, oAzul)) ),;
								TR1->TR1_FILIAL,;
								TR1->TR1_NOME,;
								TR1->TR1_MAT,;
								Transform(TR1->TR1_SALARI,"@R 999,999,999.99"),;
								Transform(TR1->TR1_PTFUNC,"@R 9,999,999.99"),;
								Transform(TR1->TR1_PTCARG,"@R 9,999,999.99"),;
								TR1->TR1_CARGO,;
								TR1->TR1_DESCCA,;
								TR1->TR1_CC,;
								TR1->TR1_DESCCC,;
								TR1->TR1_FUNCAO,;
								TR1->TR1_DESCFUN}}
		//Tratamento de dados sensíveis
		If aOfusca[2]
			aAvFields := {"RA_NOME","RA_MAT","RA_SALARIO","RA_CARGO","RA_DESCCA","RA_CC","RA_DESCCC","RA_CODFUNC","RA_DESCFUN"}
			aPDFields := FwProtectedDataUtil():UsrNoAccessFieldsInList( aAvFields )
			o1Lbx:lObfuscate := .T.

			For nX := 1 to Len(aPDFields)
				nPos := aScan(aAvFields, {|x| x == aPDFields[nX]:cField})
				If nPos == 1 //RA_NOME
					aOfuscaCpo[3] := .T.
				ElseIf nPos == 2 //RA_MAT
					aOfuscaCpo[4] := .T.
				ElseIf nPos == 3 //RA_SALARIO
					aOfuscaCpo[05] := .T.
				ElseIf nPos == 4 //RA_CARGO
					aOfuscaCpo[08] := .T.
				ElseIf nPos == 5 //RA_DESCCA
					aOfuscaCpo[09] := .T.
				ElseIf nPos == 6 //RA_CC
					aOfuscaCpo[10] := .T.
				ElseIf nPos == 7 //RA_DESCCC
					aOfuscaCpo[11] := .T.
				ElseIf nPos == 8 //RA_CODFUNC
					aOfuscaCpo[12] := .T.
				ElseIf nPos == 9 //RA_DESCFUN
					aOfuscaCpo[13] := .T.
				EndIf
			Next nX
			o1Lbx:aObfuscatedCols := aOfuscaCpo
		EndIf

		@  aCoord[3]-20,10	BITMAP NAME "BR_VERDE"		SIZE 8,8 OF oDlgMain PIXEL
		@  aCoord[3]-20,20	SAY STR0043		SIZE 45,7 OF oDlgMain PIXEL 	//"Adeq.Pontos/Valor"
		@  aCoord[3]-20,70	BITMAP NAME "BR_VERMELHO"	SIZE 8,8 OF oDlgMain PIXEL
		@  aCoord[3]-20,80	SAY STR0044		SIZE 50,7 OF oDlgMain PIXEL 	//"Nao Adequado"
		@  aCoord[3]-10,10	BITMAP NAME "BR_AZUL"		SIZE 8,8 OF oDlgMain PIXEL
		@  aCoord[3]-10,20	SAY STR0045		SIZE 90,7 OF oDlgMain PIXEL 	//"Adeq. Valor"

		// Segundo Quadro
		@	aCoord[1]+20,aLbxCoord2[2] GROUP oGroup  TO aCoord[3],aCoord[4] LABEL STR0020	OF oDlgMain PIXEL //"Adequacao Salarial por:"
		@	aCoord[1]+30,aLbxCoord2[2]+5 SAY OemtoAnsi(STR0021)	PIXEL	//"Nome: "
		@ 	aCoord[1]+30,aLbxCoord2[2]+35 SAY oGet1 VAR If(aOfuscaCpo[3],Replicate('*',15),cGet1) SIZE 120,8	OF oDlgMain PIXEL

		@	aCoord[1]+40,aLbxCoord2[2]+5 SAY OemtoAnsi(STR0026)	PIXEL	//"Salario: "
		@ 	aCoord[1]+40,aLbxCoord2[2]+35 MSGET oGet2 	VAR cGet2 ;
								PICTURE "@R 999,999,999.99";
								VALID Cs030Salario(cGet2);
								SIZE 70,8	OF oDlgMain PIXEL WHEN (nTipo==2 .Or. nTipo==4)


		If Len(a3Lbx) > 0
			@  	aLbxCoord2[1]+5,aLbxCoord2[2]+5 LISTBOX o2Lbx FIELDS;
						HEADER		"",;
									OemtoAnsi(STR0022),;	// "Valor Salarial"
									OemToAnsi(STR0046),;	// "Ptos.Min."
									OemToAnsi(STR0047);		// "Ptos.Max."
						SIZE aLbxCoord2[4],aLbxCoord2[3] PIXEL
			o2Lbx:bldblclick :={|nRow, nCol| Cs030Clic(2,o2Lbx:nAt)}
			o2Lbx:SetArray(a2Lbx)
			o2Lbx:bLine:= {||{ If(a2Lbx[o2Lbx:nAt,1],o1Ok,oNo),;
								If(nTipo != 2 .And. nTipo != 4,Transform(a2Lbx[o2Lbx:nAt,2],"@R 999,999,999.99"),a2Lbx[o2Lbx:nAt,2]),;
								If(nTipo == 2 .Or.  nTipo == 4,Transform(a2Lbx[o2Lbx:nAt,7],"@R 999,999.99"), Transform(a2Lbx[o2Lbx:nAt,5],"@R 999,999.99") ) ,;
								If(nTipo == 2 .Or.  nTipo == 4,Transform(a2Lbx[o2Lbx:nAt,8],"@R 999,999.99"), Transform(a2Lbx[o2Lbx:nAt,6],"@R 999,999.99") ) }}
			o2Lbx:nFreeze := 1

			@  	aLbxCoord3[1]+5,	aLbxCoord3[2]+5 LISTBOX o3Lbx FIELDS;
						HEADER 		"",;
									OemtoAnsi(STR0023),;	// "Pontos do Cargo"
									OemToAnsi(STR0046),;	// "Ptos.Min."
									OemToAnsi(STR0047);		// "Ptos.Max."
					 	SIZE 	aLbxCoord3[4],	aLbxCoord3[3] PIXEL
			o3Lbx:bldblclick :={|nRow, nCol| Cs030Clic(3,o3Lbx:nAt)}
			o3Lbx:SetArray(a3Lbx)
			o3Lbx:bLine:= {||{ If(a3Lbx[o3Lbx:nAt,1],o1Ok,oNo),;
								If(nTipo != 2 .And. nTipo != 4,Transform(a3Lbx[o3Lbx:nAt,2],"@R 9,999,999.99"),a3Lbx[o3Lbx:nAt,2]),;
								If(nTipo == 2 .Or.  nTipo == 4,Transform(a3Lbx[o3Lbx:nAt,7],"@R 999,999.99"), Transform(a3Lbx[o3Lbx:nAt,5],"@R 999,999.99") ) ,;
								If(nTipo == 2 .Or.  nTipo == 4,Transform(a3Lbx[o3Lbx:nAt,8],"@R 999,999.99"), Transform(a3Lbx[o3Lbx:nAt,6],"@R 999,999.99") ) }}
			o3Lbx:nFreeze := 1
		Else
			@  	(aLbxCoord2[1]+5),(aLbxCoord2[2]+5) LISTBOX o2Lbx FIELDS;
						HEADER		"",;
									OemtoAnsi(STR0022),;	// "Valor Salarial"
									OemToAnsi(STR0046),;	// "Ptos.Min."
									OemToAnsi(STR0047);		// "Ptos.Max."
						SIZE (2 * aLbxCoord2[4]),(2 * aLbxCoord2[3]) PIXEL
			o2Lbx:bldblclick :={|nRow, nCol| Cs030Clic(2,o2Lbx:nAt)}
			o2Lbx:SetArray(a2Lbx)
			o2Lbx:bLine:= {||{ If(a2Lbx[o2Lbx:nAt,1],o1Ok,oNo),;
								If(nTipo != 2 .And. nTipo != 4,Transform(a2Lbx[o2Lbx:nAt,2],"@R 999,999,999.99"),a2Lbx[o2Lbx:nAt,2]),;
								If(nTipo == 2 .Or.  nTipo == 4,Transform(a2Lbx[o2Lbx:nAt,7],"@R 999,999.99"), Transform(a2Lbx[o2Lbx:nAt,5],"@R 999,999.99") ) ,;
								If(nTipo == 2 .Or.  nTipo == 4,Transform(a2Lbx[o2Lbx:nAt,8],"@R 999,999.99"), Transform(a2Lbx[o2Lbx:nAt,6],"@R 999,999.99") ) }}
			o2Lbx:nFreeze := 1
		EndIf

		Aadd( aButtons, { "LJPRECO"   , { || CS030Sal(nReg,aGdCoord,oDlgMain) }, OemToAnsi(STR0053), OemtoAnsi(STR0054) } )  //"Histórico Salarial do Funcionário"#"Histórico"

	ACTIVATE MSDIALOG oDlgMain ON INIT EnchoiceBar(oDlgMain,{||(If(CS030Grava(cAlias,nReg,nOpcx),oDlgMain:End(),Nil))},;
															{|| oDlgMain:End()},,aButtons )
EndIf

dbSelectArea("TR1")
dbCloseArea()

If oArq1Tmp <> Nil
	oArq1Tmp:Delete()
	Freeobj(oArq1Tmp)
EndIf

dbSelectArea("SRA")
Set Filter To
RetIndex("SRA")
dbSetOrder(1)

dbSelectArea(cNtxAlias)
DbCloseArea()

If oArqNtxTmp <> Nil
	oArqNtxTmp:Delete()
	Freeobj(oArqNtxTmp)
EndIf



DeleteObject(oOk)
DeleteObject(oNo)
DeleteObject(o1Ok)

RestArea(aSaveArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CS030Mont ³ Autor ³ Cristina Ogura       ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta o listbox com os funcionarios para a adequacao       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CS030Mont (ExpC1,ExpC2,ExpC3)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM030       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CS030Mont()
Local cIndCond 	:= ""
Local cFor		:= ""
Local cDescCC	:= ""
Local cDescFunc	:= ""
Local cDescCargo:= ""
Local nMarca	:= 0
Local nIndex	:= 0
Local nPtosFunc	:= 0
Local nPtosCargo:= 0
Local cCargo	:= ""
Local cGrupo	:= ""
Local aFator 	:= {}
Local aSalarios	:= {}
Local aPontos	:= {}
Local cAcessaSRA:= &("{ || " + ChkRH(FunName(),"SRA","2") + "}")
Local nx		:= 0
Local aStruSRA := {}
Local nTotLoop
Local nLoop
Local aFields := {}

DbSelectArea("SQ3")
SQ3->( DbSetOrder(1) )

DbSelectArea("SRA")
SRA->( DbGoTop() )

If nOrdem == 1 .Or. nOrdem == 2		// Nome ou Matricula
	dbSetOrder(1)
	cIndCond 	:= "RA_FILIAL+RA_MAT+RA_CC+RA_CODFUNC+RA_CARGO"
	cFor		:= 'RA_FILIAL+RA_MAT+RA_CC+RA_CODFUNC+RA_CARGO >="'
	cFor		+=  cFilDe+cMatDe+cCCDe+cFuncaoDe+cCargoDe +'" .And.'
	cFor		+= 'RA_FILIAL+RA_MAT+RA_CC+RA_CODFUNC+RA_CARGO <="'
	cFor		+=  cFilAte+cMatAte+cCCAte+cFuncaoAte+cCargoAte +'"'
ElseIf nOrdem == 3		// Centro Custo
	dbSetOrder(2)
	cIndCond	:= "RA_FILIAL+RA_CC+RA_MAT+RA_CODFUNC+RA_CARGO"
	cFor		:= 'RA_FILIAL+RA_CC+RA_MAT+RA_CODFUNC+RA_CARGO >="'
	cFor		+=  cFilDe+cCCDe+cMatDe+cFuncaoDe+cCargoDe +'" .And.'
	cFor		+= 'RA_FILIAL+RA_CC+RA_MAT+RA_CODFUNC+RA_CARGO <="'
	cFor		+=  cFilAte+cCCAte+cMatAte+cFuncaoAte+cCargoAte +'"'
ElseIf nOrdem == 4		// Funcao
	dbSetOrder(7)
	cIndCond	:= "RA_FILIAL+RA_CODFUNC+RA_MAT+RA_CC+RA_CARGO"
	cFor		:= 'RA_FILIAL+RA_CODFUNC+RA_MAT+RA_CC+RA_CARGO >="'
	cFor		+=  cFilDe+cFuncaoDe+cMatDe+cCCDe+cCargoDe + '" .And.'
	cFor		+= 'RA_FILIAL+RA_CODFUNC+RA_MAT+RA_CC+RA_CARGO <="'
	cFor		+=  cFilAte+cFuncaoAte+cMatAte+cCCAte+cCargoAte + '"'
EndIf


aStruSRA := SRA->(dbStruct())
nTotLoop	:= Len(aStruSRA)

For nLoop:=1 To nTotLoop
	AADD(aFields,{	aStruSRA[nLoop,1]   ,;
       		        aStruSRA[nLoop,2]  	,;
			        aStruSRA[nLoop,3]  	,;
			        aStruSRA[nLoop,4]    }    )
Next

oArqNtxTmp := RhCriaTrab(cNtxAlias, aFields, Nil)

IndRegua("SRA",cNtxAlias,cIndCond,,cFor,OemtoAnsi(STR0024))		//"Selecionando Registros..."
nIndex := RetIndex("SRA")
aGuarda := {}

dbSetOrder(nIndex+1)
While !Eof()

	// Verifica o acesso desse usuario
	If !Eval(cAcessaSRA)
		dbSkip()
		Loop
	EndIf

	// Funcionario Demitido
	If SRA->RA_SITFOLH == "D"
		dbSkip()
		Loop
	EndIf

	// Funcionario nao pertence a tabela da adequacao
	If Empty(SRA->RA_TABELA).Or. SRA->RA_TABELA # cTabela
		If !( SQ3->( MsSeek( xFilial("SQ3",SRA->RA_FILIAL) + SRA->RA_CARGO + SRA->RA_CC ) ) .Or.;
		SQ3->( MsSeek( xFilial("SQ3",SRA->RA_FILIAL) + SRA->RA_CARGO + Space(Len(SRA->RA_CC)) ) ) ) .Or.;
		Empty(SQ3->Q3_TABELA).Or. SQ3->Q3_TABELA # cTabela
			SRA->( DbSkip() )
			Loop
		EndIf
	EndIf

	If nOrdem == 1	.Or. nOrdem == 2		// Matricula
		If 	SRA->RA_CC < cCCDe 	.Or. SRA->RA_CC > cCCAte .Or.;
			SRA->RA_MAT < cMatDe .Or. SRA->RA_MAT > cMatAte .Or.;
			SRA->RA_CODFUNC < cFuncaoDe	.Or. SRA->RA_CODFUNC > cFuncaoAte .Or. ;
			SRA->RA_CARGO < cCargoDe	.Or. SRA->RA_CARGO > cCargoAte
			dbSkip()
			Loop
		EndIf
	ElseIf nOrdem == 3		// Centro de Custo
		If 	SRA->RA_MAT < cMatDe .Or. SRA->RA_MAT > cMatAte .Or.;
			SRA->RA_CODFUNC < cFuncaoDe .Or. SRA->RA_CODFUNC > cFuncaoAte .OR.;
			SRA->RA_CARGO < cCargoDe	.Or. SRA->RA_CARGO > cCargoAte
			dbSkip()
			Loop
		EndIf
	ElseIf nOrdem == 4		// Funcao
		If 	SRA->RA_MAT < cMatDe .Or. SRA->RA_MAT > cMatAte .Or.;
			SRA->RA_CC < cCCDe .Or. SRA->RA_CC > cCCAte .Or.;
			SRA->RA_CARGO < cCargoDe	.Or. SRA->RA_CARGO > cCargoAte
			dbSkip()
			Loop
		EndIf
	EndIf

	nMarca:= 2
	cCargo:= fGetCargo(SRA->RA_MAT)
	cGrupo:= "  "
	aFator:= {}

	FMontaFator(SRA->RA_FILIAL,SRA->RA_CODFUNC,@cCargo,SRA->RA_MAT,@cGrupo,,aFator,SRA->RA_CC)

	If cGrupo < cGrupoDe .Or. cGrupo > cGrupoAte
		dbSelectArea("SRA")
		dbSkip()
		Loop
	EndIf

	nPtosFunc := 0
	nPtosCargo:= 0
	For nx:=1 To Len(aFator)
		nPtosFunc := nPtosFunc  + aFator[nx][8]
		nPtosCargo:= nPtosCargo + aFator[nx][5]
	Next nx

	cDescCargo	:= FDesc("SQ3",cCargo+SRA->RA_CC,"SQ3->Q3_DESCSUM",30)
	If Empty(cDescCargo)
		cDescCargo	:= FDesc("SQ3",cCargo,"SQ3->Q3_DESCSUM",30)
	EndIf

	cDescCC	 	:= FDesc("CTT",SRA->RA_CC,"CTT->CTT_DESC01",30)
	cDescFunc	:= FDesc("SRJ",SRA->RA_CODFUNC,"SRJ->RJ_DESC",30)

	Cs030VerTab(@aPontos,@aSalarios,SRA->RA_SALARIO,nPtosCargo,@nMarca,nPtosFunc)

	Aadd(aGuarda,{SRA->RA_FILIAL,SRA->RA_MAT,aSalarios,aPontos,SRA->RA_SALARIO})

	RecLock("TR1",.T.)
		TR1->TR1_MARCA		:= nMarca
		TR1->TR1_FILIAL		:= SRA->RA_FILIAL
		TR1->TR1_NOME		:= SRA->RA_NOME
		TR1->TR1_MAT		:= SRA->RA_MAT
		TR1->TR1_PTFUNC		:= nPtosFunc
		TR1->TR1_PTCARG		:= nPtosCargo
		TR1->TR1_SALARI		:= SRA->RA_SALARIO
		TR1->TR1_CARGO		:= cCargo
		TR1->TR1_DESCCA		:= cDescCargo
		TR1->TR1_CC			:= SRA->RA_CC
		TR1->TR1_DESCCC		:= cDescCC
		TR1->TR1_FUNCAO		:= SRA->RA_CODFUNC
		TR1->TR1_DESCFUN	:= cDescFunc
	MsUnlock()

	dbSelectArea("SRA")
	dbSkip()
EndDo

dbSelectArea("TR1")
dbGotop()

SQ3->( DbCloseArea() )

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CS030Grava³ Autor ³ Cristina Ogura        ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os registros referente ao treinamentos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAM030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CS030Grava(cAlias,nReg,nOpcx)
Local nx		:= 0
Local ny		:= 0
Local a1Array	:= {}
Local a2Array	:= {}
Local nNovoSal 	:= 0
Local cNivel	:= ""
Local cFaixa	:= ""
Local lRet		:= .T.
Local nPos		:= 0
Local cDescCar 	:= ""
Local nLoop    	:= 0
Local nLoops	:= 0

// Atualizo o array aGuarda no confirma
nPos:= Ascan(aGuarda,{|x| x[1]+x[2]== cEstou })
If nPos > 0
	aGuarda[nPos][3] := aClone(a2Lbx)
	aGuarda[nPos][4] := aClone(a3Lbx)
	aGuarda[nPos][5] := cGet2
EndIf

// Nao gravo os funcionarios que nao estao marcados na tabela
For nx:=1 To Len(aGuarda)

	dbSelectArea("SRA")
	dbSetOrder(1)
	If 	dbSeek(aGuarda[nx][1]+aGuarda[nx][2])

		nNovoSal:= 0
		cNivel	:= ""
		cFaixa 	:= ""
		a1Array := aClone(aGuarda[nx][3])
		a2Array := aClone(aGuarda[nx][4])
		lRet	:= .F.

		For ny:= 1 To Len(a1Array)
			If 	a1Array[ny][1]
				lRet := .T.
				Exit
			EndIf
		Next ny

		If !lRet
			For ny:= 1 To Len(a2Array)
				If 	a2Array[ny][1]
					lRet := .T.
					Exit
				EndIf
			Next ny
		EndIf

		If !lRet
			Loop
		EndIf

		For ny:=1 To Len(a1Array)
			If a1Array[ny][1]
				cNivel	:= a1Array[ny][4]
				If nTipo ==1 .Or. nTipo == 3
					cFaixa	:= a1Array[ny][3]
					nNovoSal:= a1Array[ny][2]
				ElseIf nTipo == 2 .Or. nTipo == 4
					cFaixa	:= a1Array[ny][3]
					nNovoSal:= aGuarda[nx][5]
				EndIf
				Exit
			EndIf
		Next ny
		If Empty(nNovoSal)
			For ny:=1 To Len(a2Array)
				If a2Array[ny][1]
					cNivel	:= a2Array[ny][4]
					If nTipo == 1 .Or. nTipo == 3
						cFaixa	:= a2Array[ny][3]
						nNovoSal:= a2Array[ny][2]
					ElseIf nTipo == 2 .Or. nTipo == 4
						cFaixa	:= a2Array[ny][3]
						nNovoSal:= aGuarda[nx][5]
					EndIf
					Exit
				EndIf
			Next ny
		EndIf

		// Busca descricao da funcao do funcionario
		cFun 	:= DescFun(SRA->RA_CODFUNC,SRA->RA_FILIAL)
		cDescCar:= ""
		If SQ3->( dbSeek(xFilial("SQ3")+SRA->RA_CARGO+SRA->RA_CC)) .or. SQ3->( dbSeek(xFilial("SQ3")+SRA->RA_CARGO))
			cDescCar := SQ3->Q3_DESCSUM
	   	EndIf

		// Verifica Ja Teve Alteracao Se Nao Grava Anterior Na Primeira
		dbSelectArea("SR7")
		If !dbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
			// Grava o Salario Anterior Quando Nao Existir Alteracao (SR7)
			RecLock("SR7",.T.,.T.)
			SR7->R7_FILIAL   := SRA->RA_FILIAL
			SR7->R7_MAT      := SRA->RA_MAT
			SR7->R7_DATA     := SRA->RA_ADMISSA
			SR7->R7_TIPO     := "001"
			SR7->R7_FUNCAO   := SRA->RA_CODFUNC
			SR7->R7_DESCFUN  := cFun
			SR7->R7_TIPOPGT  := SRA->RA_TIPOPGT
			SR7->R7_CATFUNC  := SRA->RA_CATFUNC
			SR7->R7_USUARIO  := STR0027		//"Sistema"
		   	If SR7->( Type("R7_CARGO") ) # "U"
			   	SR7->R7_CARGO   := SRA->RA_CARGO
		   	EndIf
			If SR7->( Type("R7_DESCCAR") ) # "U"
				SR7->R7_DESCCAR	:= cDescCar
			EndIf

			MsUnLock()

			// Grava o Salario Anterior Quando Nao Existir Alteracao (SR3)
			dbSelectArea("SR3")
			RecLock("SR3",.T.,.T.)
				SR3->R3_FILIAL   := SRA->RA_FILIAL
				SR3->R3_MAT      := SRA->RA_MAT
				SR3->R3_DATA     := SRA->RA_ADMISSA
				SR3->R3_PD       := "000"
				SR3->R3_DESCPD   := STR0028			//"SALARIO BASE"
				SR3->R3_VALOR    := SRA->RA_SALARIO
				SR3->R3_TIPO     := "001"
			MsUnLock()
	    EndIf

		// Atualizando SR7 - Alteracao Salarial
		dbSelectArea( "SR7" )
		If 	dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + Dtos(dDtAlt) + cTpAlt )
			RecLock("SR7",.F.,.T.)
		Else
			RecLock("SR7",.T.,.T.)
		EndIf

		SR7->R7_FILIAL   := SRA->RA_FILIAL
		SR7->R7_MAT      := SRA->RA_MAT
		SR7->R7_DATA     := dDtAlt
		SR7->R7_TIPO     := cTpAlt
		SR7->R7_FUNCAO   := SRA->RA_CODFUNC
		SR7->R7_DESCFUN  := cFun
		SR7->R7_TIPOPGT  := SRA->RA_TIPOPGT
		SR7->R7_CATFUNC  := SRA->RA_CATFUNC

		SR7->R7_USUARIO  := cUserName
	   	If SR7->( Type("R7_CARGO") ) # "U"
		   	SR7->R7_CARGO   := SRA->RA_CARGO
	   	EndIf
		If SR7->( Type("R7_DESCCAR") ) # "U"
			SR7->R7_DESCCAR	:= cDescCar
		EndIf
		MsUnLock()

		// Atualizando SR3 - Alteracao Salarial
		dbSelectArea( "SR3" )
		If 	dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + Dtos(dDtAlt) + cTpAlt )
			RecLock("SR3",.F.,.T.)
		Else
			RecLock("SR3",.T.,.T.)
		EndIf
			SR3->R3_FILIAL   := SRA->RA_FILIAL
			SR3->R3_MAT      := SRA->RA_MAT
			SR3->R3_DATA     := dDtAlt
			SR3->R3_PD       := "000"
			SR3->R3_DESCPD   := STR0028		//"SALARIO BASE"
			SR3->R3_VALOR 	  := nNovoSal
			SR3->R3_TIPO     := cTpAlt
		MsUnLock()

		// Atualizando SRA
		dbSelectArea( "SRA" )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravacao de Campos do SRA *particularidade Mexico            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If cPaisLoc == "MEX"

        	If nNovoSal <> 0

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta os Dados para a Enchoice							  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aSraCols	:= SRA->( GdBuildCols( @aSraHeader , @nLoops , @aSraVirtual , @aSraVisual ) )
				aSvSraCols	:= aClone( aSraCols )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Carrega variaveis de memoria ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nLoop := 1 To nLoops
					aAdd( aSraFields , aSraHeader[ nLoop , 02 ] )
					SetMemVar( aSraHeader[ nLoop , 02 ] , aSraCols[ 1 , nLoop ] , .T. , .T. )
				Next nLoop

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza variaveis de memoria com os Dados da Adequacao Salarial  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				M->RA_SALARIO   := nNovoSal
				M->RA_TIPOALT 	:= cTpAlt
				M->RA_DATAALT	:= dDtAlt

        		If Gp010ValSal() //Pre-requisito para Calculo do Salario

					//fFormula("327SDI",.F.) //Atualizacao dos campos na Pasta Cargos e Salarios (MEXICO)- Removido dia 28/06/12
					Gp010Adm() //Consistencia para modificacao dos campos

					If Len(aModTraj) > 0
				   		GravaRCP()	//Trajetoria Laboral
					Endif
				EndIf
			EndIf
		EndIf

		RecLock( "SRA" , .F. )
		Replace SRA->RA_TABELA	WITH cTabela
		Replace SRA->RA_TABFAIX	WITH cFaixa
		Replace SRA->RA_TABNIVE	WITH cNivel
		MsUnlock()

		If cPaisLoc <> "MEX"
			RecLock( "SRA" , .F. )
			Replace SRA->RA_SALARIO	WITH nNovoSal
			MsUnlock()
		Else
			RecLock( "SRA" , .F. )
			Replace SRA->RA_SALARIO	WITH M->RA_SALARIO
			Replace SRA->RA_SALDIA	WITH M->RA_SALDIA
			Replace SRA->RA_SALMES	WITH M->RA_SALMES
			Replace SRA->RA_SALHOR	WITH M->RA_SALHOR
			Replace SRA->RA_SALINT	WITH M->RA_SALINT
			Replace SRA->RA_SALIVC	WITH M->RA_SALIVC
			Replace SRA->RA_SALINS	WITH M->RA_SALINS
			Replace SRA->RA_PARVAR	WITH M->RA_PARVAR
			Replace SRA->RA_SALDIAA	WITH M->RA_SALDIAA
			Replace SRA->RA_SALMESA	WITH M->RA_SALMESA
			Replace SRA->RA_SALHORA	WITH M->RA_SALHORA
			Replace SRA->RA_SALINTA	WITH M->RA_SALINTA
			Replace SRA->RA_SALIVCA	WITH M->RA_SALIVCA
			Replace SRA->RA_SALINSA	WITH M->RA_SALINSA
			Replace SRA->RA_PARFIJ 	WITH M->RA_PARFIJ
			MsUnlock()
		EndIf
	EndIf

Next nx

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CS030Perg ³ Autor ³ Cristina Ogura        ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chamada dos parametros no arotina                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAM030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs030Perg()
	Cs030LePerg(.T.)
Return Nil

Function Cs030LePerg(lTipo)

// mv_par01		- Tabela Salarial
// mv_par02		- Filial De
// mv_par03		- Filial Ate
// mv_par04		- Grupo De
// mv_par05		- Grupo Ate
// mv_par06		- Centro de Custo De
// mv_par07		- Centro de Custo Ate
// mv_par08		- Funcao De
// mv_par09		- Funcao Ate
// mv_par10		- Matricula De
// mv_par11		- Matricula Ate
// mv_par12		- Tp Alteracao
// mv_par13		- Data Alteracao
// mv_par14     - Ordem 1-Nome 2-Matricula 3-Centro Custo 4-Funcao

pergunte("CSM030",.F.)


cTabela 	:= If(!Empty(mv_par01), mv_par01, "   ")
cFilDe		:= If(!Empty(mv_par02), mv_par02, Space(FWGETTAMFILIAL))
cFilAte		:= If(!Empty(mv_par03), mv_par03, Replicate("Z", FWGETTAMFILIAL))
cGrupoDe	:= If(!Empty(mv_par04), mv_par04, "  ")
cGrupoAte	:= If(!Empty(mv_par05), mv_par05, "ZZ")
cCCDe		:= If(!Empty(mv_par06), mv_par06, "         ")
cCCAte		:= If(!Empty(mv_par07), mv_par07, "ZZZZZZZZZ")
cFuncaoDe	:= If(!Empty(mv_par08), mv_par08, "     ")
cFuncaoAte	:= If(!Empty(mv_par09), mv_par09, "ZZZZZ")
cMatDe		:= If(!Empty(mv_par10), mv_par10, "      ")
cMatAte		:= If(!Empty(mv_par11), mv_par11, "ZZZZZZ")
cTpAlt		:= If(!Empty(mv_par12), mv_par12, "001")
dDtAlt		:= If(!Empty(mv_par13), mv_par13, dDataBase)
nOrdem		:= If(!Empty(mv_par14), mv_par14, 1)
cCargoDe	:= If(!Empty(mv_par15), mv_par15, "     ")
cCargoAte	:= If(!Empty(mv_par16), mv_par16, "ZZZZZ")
dDtRefDe	:= If(!Empty(mv_par13), mv_par17, Ctod(""))
dDtRefAte	:= If(!Empty(mv_par13), mv_par18, Ctod(""))

Pergunte("CSM030",lTipo)

Return .t.


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CS030Clic ³ Autor ³ Cristina Ogura        ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao executada no on click do listbox 2                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAM030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CS030Clic(nQual,nAux)
Local nx		:= 0
Local aAuxArray	:= {}
Local nElem		:= 0

If nQual == 2
	aAuxArray := aClone(a2Lbx)
ElseIf nQual == 3
	aAuxArray := aClone(a3Lbx)
EndIf

If Len(aAuxArray) == 1 .And. Empty(aAuxArray[1,2])
	Help("",1,"Cs030VAZI")			// Nao pode ser marcado pois esta com valor zero
	Return .T.
EndIf

nElem := Iif(nTipo != 2 .And. nTipo != 4, 2, 6)
If 	aAuxArray[nAux,nElem] < cGet2
	Help("",1,"Cs030MENOR")		// Salario do funcionario nao pode ser menor que o atual
	Return .T.
EndIf

// Marca ou demarca o valor da faixa salarial
aAuxArray[nAux][1] := !aAuxArray[nAux][1]

// Desmarca os outros valores
If aAuxArray[nAux][1]
	For nx:=1 To Len(aAuxArray)
		If nx # nAux
			aAuxArray[nx][1]:= .F.
		EndIf
	Next nx

	If 	nQual == 2
		For nx:=1 To Len(a3Lbx)
			a3Lbx[nx][1] := .F.
		Next nx
	ElseIf nQual == 3
		For nx:=1 To Len(a2Lbx)
			a2Lbx[nx][1] := .F.
		Next nx
	EndIf
EndIf

If nQual == 2
	a2Lbx:= aClone(aAuxArray)
ElseIf nQual == 3
	a3Lbx:= aClone(aAuxArray)
EndIf

o2Lbx:Refresh()
If Len(a3Lbx) > 0
	o3Lbx:Refresh()
EndIf

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CS030Cria   ³ Autor ³ Cristina Ogura      ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria arquivo para gravar os dados do listbox 1              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAM030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CS030Cria()
Local a1Stru	:= {}
Local cCond		:= ""
Local aLstIndices := {}
Aadd(a1Stru,{"TR1_MARCA"	,"N",01,0})
Aadd(a1Stru,{"TR1_FILIAL"	,"C",FWGETTAMFILIAL,0})
Aadd(a1Stru,{"TR1_NOME"		,"C",30,0})
Aadd(a1Stru,{"TR1_MAT"		,"C",06,0})
Aadd(a1Stru,{"TR1_PTFUNC"	,"N",10,2})
Aadd(a1Stru,{"TR1_PTCARG"	,"N",10,2})
Aadd(a1Stru,{"TR1_SALARI"	,"N",12,2})
Aadd(a1Stru,{"TR1_CARGO"	,"C",05,0})
Aadd(a1Stru,{"TR1_DESCCA"	,"C",30,0})
Aadd(a1Stru,{"TR1_CC"		,"C",09,0})
Aadd(a1Stru,{"TR1_DESCCC"	,"C",30,0})
Aadd(a1Stru,{"TR1_FUNCAO"	,"C",05,0})
Aadd(a1Stru,{"TR1_DESCFU"	,"C",30,0})

//Ordem 1-Nome 2-Matricula 3-Centro Custo 4-Funcao
If nOrdem == 1				// Nome
	Aadd(aLstIndices,{"TR1_FILIAL","TR1_NOME"})
ElseIf nOrdem == 2			// Matricula
	Aadd(aLstIndices,{"TR1_FILIAL","TR1_MAT"})
ElseIf nOrdem == 3			// Centro de Custo
	Aadd(aLstIndices,{"TR1_FILIAL","TR1_CC"})
ElseIf nOrdem == 4			// Funcao
	Aadd(aLstIndices,{"TR1_FILIAL","TR1_FUNCAO"})
EndIf

oArq1Tmp := RhCriaTrab('TR1', a1Stru, aLstIndices)

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Cs030Troca³ Autor ³ Cristina Ogura        ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que troca a faixa conforme a posicao do funcionario  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs030Troca(cAuxFil,cMat,l1Vez)
Local nPos	:= 0

If !l1Vez
	nPos:= Ascan(aGuarda,{|x| x[1]+x[2]== cEstou })
	If nPos > 0
		aGuarda[nPos][3] := aClone(a2Lbx)
		aGuarda[nPos][4] := aClone(a3Lbx)
		aGuarda[nPos][5] := cGet2
	EndIf
EndIf

cEstou 	:= TR1->TR1_FILIAL+TR1->TR1_MAT
cGet1 	:= TR1->TR1_NOME
nPos	:= Ascan(aGuarda,{|x| x[1]+x[2]== cAuxFil+cMat })

If nPos > 0
	cGet2 :=aGuarda[nPos][5]
	a2Lbx :=aClone(aGuarda[nPos][3])
	a3Lbx :=aClone(aGuarda[nPos][4])
	If !l1Vez
		o2Lbx:SetArray(a2Lbx)
		o2Lbx:bLine:= {||{ If(a2Lbx[o2Lbx:nAt,1],o1Ok,oNo),;
							If(nTipo != 2 .And. nTipo != 4,Transform(a2Lbx[o2Lbx:nAt,2],"@R 999,999,999.99"),a2Lbx[o2Lbx:nAt,2]),;
							If(nTipo == 2 .Or.  nTipo == 4,Transform(a2Lbx[o2Lbx:nAt,7],"@R 999,999.99"), Transform(a2Lbx[o2Lbx:nAt,5],"@R 999,999.99") ) ,;
							If(nTipo == 2 .Or.  nTipo == 4,Transform(a2Lbx[o2Lbx:nAt,8],"@R 999,999.99"), Transform(a2Lbx[o2Lbx:nAt,6],"@R 999,999.99") ) }}

		If Len(a3Lbx) > 0
			o3Lbx:SetArray(a3Lbx)
			o3Lbx:bLine:= {||{ If(a3Lbx[o3Lbx:nAt,1],o1Ok,oNo),;
								If(nTipo != 2 .And. nTipo != 4,Transform(a3Lbx[o3Lbx:nAt,2],"@R 9,999,999.99"),a3Lbx[o3Lbx:nAt,2]),;
								If(nTipo == 2 .Or.  nTipo == 4,Transform(a3Lbx[o3Lbx:nAt,7],"@R 999,999.99"), Transform(a3Lbx[o3Lbx:nAt,5],"@R 999,999.99") ) ,;
								If(nTipo == 2 .Or.  nTipo == 4,Transform(a3Lbx[o3Lbx:nAt,8],"@R 999,999.99"), Transform(a3Lbx[o3Lbx:nAt,6],"@R 999,999.99") ) }}
		EndIf
	EndIf
EndIf

If !l1Vez
	oGet1:Refresh()
	oGet2:Refresh()
	o2Lbx:Refresh(.T.)
	If Len(a3Lbx) > 0
		o3Lbx:Refresh(.T.)
	EndIf
EndIf

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Cs030VerTab ³ Autor ³ Cristina Ogura      ³ Data ³ 20.10.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica a tabela salarial                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Cs030VerTab(aPontos,aSalarios,nSalario,nPtosCargo,nMarca,nPtosFunc)
Local aSaveArea := GetArea()
Local cValor    := ""
Local nx		:= 0
Local lSalarios	:= .F.
Local lPontos	:= .F.
Local nValor	:= 0
Local nValorDe	:= 0
Local nValorAte	:= 0
Local ni		:= 0
Local nf		:= 0
Local nSal		:= 0

aPontos 	:= {}
aSalarios	:= {}

DbSelectArea("RBR")
RBR->( DbSetOrder(1) )
RBR->( MsSeek( xFilial("RBR",RB6->RB6_FILIAL) + RB6->RB6_TABELA + DToS(RB6->RB6_DTREF) ) )

// Estrutura do array aTabela
// Nivel, Menor salario, Maior Salario, Minimo Ptos, Maximo Ptos, aValores, tipo da tabela
For nx := 1 To Len(aTabela)

	If ( Empty(SRA->RA_TABNIVE) .And. Empty(SQ3->Q3_TABNIVE) ) .Or. ( SRA->RA_TABNIVE == aTabela[nx][1] .Or. SQ3->Q3_TABNIVE == aTabela[nx][1] )

		If 	nTipo == 1 .Or. nTipo == 3
			aSalarios := aClone(aTabela[nx][6])
		ElseIf nTipo == 2
			cValor := "De "+Alltrim(Transform(aTabela[nx][2],"999,999,999.99"))
			cValor += " Ate "+Alltrim(Transform(aTabela[nx][3],"999,999,999.99"))
			cFaixa := Cs030Faixa( nSalario, nx )
			Aadd(aSalarios,{.F.,cValor,cFaixa,aTabela[nx][1],aTabela[nx][2],aTabela[nx][3],aTabela[nx][4],aTabela[nx][5]})
		ElseIf nTipo == 4
			nf := 1
			For nI := 1 To Len(aTabela[nx][6])
				If nf == 1
					nValor := aTabela[nx][6][nI][2]
					cValor := "De "+Alltrim(Transform(nValor,"999,999,999.99"))
					nValorDe := nValor
					nf := 2
				Else
					nValor := aTabela[nx][6][nI][2]
					cValor += " Ate "+Alltrim(Transform(nValor,"999,999,999.99"))
					nValorAte := nValor

					cFaixa := Cs030Faixa( nSalario, nx )
					Aadd(aSalarios,{.F.,cValor,cFaixa,aTabela[nx][6][nI][4],nValorDe,nValorAte,aTabela[nx][6][nI][5],aTabela[nx][6][nI][6]})

					nf := 1
				EndIf
			Next ni
		EndIf
	EndIf

	If nPtosCargo >= aTabela[nx][4] .And. nPtosCargo <= aTabela[nx][5] .And. RBR->RBR_USAPTO == 1
		If 	nTipo == 1 .Or. nTipo == 3
			aPontos := aClone(aTabela[nx][6])
		ElseIf nTipo == 2
			cValor := "De "+Alltrim(Transform(aTabela[nx][2],"999,999,999.99"))
			cValor += " Ate "+Alltrim(Transform(aTabela[nx][3],"999,999,999.99"))
			cFaixa := Cs030Faixa( nSalario, nx )
			Aadd(aPontos,{.F.,cValor,cFaixa,aTabela[nx][1],aTabela[nx][2],aTabela[nx][3],aTabela[nx][4],aTabela[nx][5]})
		ElseIf nTipo == 4
			nf := 1
			For ni := 1 To Len(aTabela[nx][6])
				If nf == 1
					nValor := aTabela[nx][6][nI][2]
					cValor := "De "+Alltrim(Transform(nValor,"999,999,999.99"))
					nValorDe := nValor
					nf := 2
				Else
					nValor := aTabela[nx][6][nI][2]
					cValor += " Ate "+Alltrim(Transform(nValor,"999,999,999.99"))
					nValorAte := nValor

					cFaixa := Cs030Faixa( nSalario, nx )
					Aadd(aPontos,{.F.,cValor,cFaixa,aTabela[nx][6][nI][4],nValorDe,nValorAte,aTabela[nx][6][nI][5],aTabela[nx][6][nI][6]})

					nf := 1
				EndIf
			Next ni
		EndIf
	EndIf
Next nx

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pegar faixa mais proxima, caso funcionario estiver fora das faixas da Tabela. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nx := 1
If Len(aTabela) > 0 .And. Len(aSalarios) == 0		//Salario

	For nx := 1 To Len(aTabela)
		If aTabela[nx][2] > nSalario
			exit
		EndIf
	Next nx

	nx := Iif(nx > Len(aTabela), Len(aTabela), nx)

	If 	nTipo == 1 .Or. nTipo == 3
		aSalarios := aClone(aTabela[nx][6])
	ElseIf nTipo == 2
		cValor := "De "+Alltrim(Transform(aTabela[nx][2],"999,999,999.99"))
		cValor := cValor + " Ate "+Alltrim(Transform(aTabela[nx][3],"999,999,999.99"))
		cFaixa := Cs030Faixa( nSalario, nx )
		Aadd(aSalarios,{.F.,cValor,cFaixa,aTabela[nx][1],aTabela[nx][2],aTabela[nx][3],aTabela[nx][4],aTabela[nx][5]})
	ElseIf nTipo == 4
		nf := 1
		For ni := 1 To Len(aTabela[nx][6])
			If nf == 1
				nValor := aTabela[nx][6][nI][2]
				cValor := "De "+Alltrim(Transform(nValor,"999,999,999.99"))
				nValorDe := nValor
				nf := 2
			Else
				nValor := aTabela[nx][6][nI][2]
				cValor += " Ate "+Alltrim(Transform(nValor,"999,999,999.99"))
				nValorAte := nValor

				cFaixa := Cs030Faixa( nSalario, nx )
				Aadd(aSalarios,{.F.,cValor,cFaixa,aTabela[nx][6][nI][4],nValorDe,nValorAte,aTabela[nx][6][nI][5],aTabela[nx][6][nI][6]})

				nf := 1
			EndIf
		Next ni
	EndIf
EndIf

nx := 1
If Len(aTabela) > 0 .And. Len(aPontos) == 0 .And. RBR->RBR_USAPTO == 1  //Pontos

	For nx := 1 To Len(aTabela)
		If aTabela[nx][4] > nPtosCargo
			exit
		EndIf
	Next nx

	nx := Iif(nx > Len(aTabela), Len(aTabela), nx)

	If 	nTipo == 1 .Or. nTipo == 3
		aPontos := aClone(aTabela[nx][6])
	ElseIf nTipo == 2
		cValor := "De "+Alltrim(Transform(aTabela[nx][2],"999,999,999.99"))
		cValor := cValor + " Ate "+Alltrim(Transform(aTabela[nx][3],"999,999,999.99"))
		cFaixa := Cs030Faixa( nSalario, nx )
		Aadd(aPontos,{.F.,cValor,cFaixa,aTabela[nx][1],aTabela[nx][2],aTabela[nx][3],aTabela[nx][4],aTabela[nx][5]})
	ElseIf nTipo == 4
		nf := 1
		For ni := 1 To Len(aTabela[nx][6])
			If nf == 1
				nValor := aTabela[nx][6][nI][2]
				cValor := "De "+Alltrim(Transform(nValor,"999,999,999.99"))
				nValorDe := nValor
				nf := 2
			Else
				nValor := aTabela[nx][6][nI][2]
				cValor += " Ate "+Alltrim(Transform(nValor,"999,999,999.99"))

				cFaixa := Cs030Faixa( nSalario, nx )
				Aadd(aPontos,{.F.,cValor,cFaixa,aTabela[nx][6][nI][4],nValorDe,nValorAte,aTabela[nx][6][nI][5],aTabela[nx][6][nI][6]})

				nValorAte := nValor
				nf := 1
			EndIf
		Next ni
	EndIf
EndIf

// Nao adequado a Tabela salarial
If 	Len(aPontos) == 0 .And. Len(aSalarios) == 0
	nMarca := 2
EndIf

// Verifico se o array esta vazio
// Caso nao esteja marco a faixa salarial do valor do salario
lPontos := .F.
If Len(aPontos) == 0
	nMarca := 2	// Nao Adequado a Tabela
Else
	For nx := 1 To Len(aPontos)
		If 	( (nTipo != 2 .And. nTipo != 4) .And.	nSalario == aPontos[nx][2]) .Or.;
			( (nTipo == 2 .Or.  nTipo == 4) .And. 	nSalario >= aPontos[nx][5] .And.;
								nSalario <= aPontos[nx][6])

			// Dentro da Tabela mas Fora de Faixa
			nMarca := 3

			aPontos[nx][1] := .T.
			lPontos 		:= .T.

			Exit
		EndIf
	Next nx
EndIf

//Mostrar somente os salários maiores que o atual
nX := 1
While nX <= Len(aSalarios)
	If (nTipo != 2 .And. nTipo != 4)
		nSal := aSalarios[nX][2]
	Else
		nSal := aSalarios[nx][6]
	EndIf
	If nSalario > nSal
		ADel( aSalarios, nX )
		ASize( aSalarios,Len(aSalarios)-1 )
	Else
		nX++
	EndIf
EndDo

lSalarios := .F.
If Len(aSalarios) == 0
	Aadd(aSalarios,{.F.,"","",0.00,0.00,0.00,0.00,0.00})

	nMarca := 2 //Nao Adequado a Tabela

Else
	For nx := 1 To Len(aSalarios)
		If 	( (nTipo != 2 .And. nTipo != 4) .And. nSalario == aSalarios[nx][2]) .Or.;
			( (nTipo == 2 .Or.  nTipo == 4) .And. 	nSalario >= aSalarios[nx][5] .And.;
								nSalario <= aSalarios[nx][6])

			// Dentro da Tabela mas Fora de Faixa
			nMarca := 3

			aSalarios[nx][1] 	:= .T.
			lSalarios			:= .T.

			Exit
		EndIf
	Next nx
EndIf

// Adequado a Faixa salarial
If lPontos .And. lSalarios
	nMarca := 1
EndIf

RestArea(aSaveArea)

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Cs030MontTab ³ Autor ³ Cristina Ogura     ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta o array com os dados da tabela salarial selecionada.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs030MontTab()
Local aSaveArea := GetArea()
Local cNivel 	:= ""
Local nTipo		:= ""
Local nMenorSal	:= 0
Local nMaiorSal	:= 0
Local nMinPtos	:= 0
Local nMaxPtos	:= 0
Local aValores	:= {}

// Montagem do array aTabela
// Nivel, Menor salario, Maior Salario, Minimo Ptos, Maximo Ptos, aValores, tipo da tabela

dbSelectArea("RB6")
dbSetOrder(3)
If dbSeek(xFilial("RB6")+cTabela + If(Empty(dDtRefDe),"",DtoS(dDtRefDe)))
	cNivel 	  	:= RB6->RB6_NIVEL
	nMinPtos  	:= RB6->RB6_PTOMIN
	nMaxPtos  	:= RB6->RB6_PTOMAX
	nTipo	  	:= RB6->RB6_TIPOVL
	While !Eof() .And. (xFilial("RB6")+cTabela == RB6->RB6_FILIAL+RB6->RB6_TABELA .And. ((Empty(dDtRefDe) .Or. DtoS(dDtRefDe) <= DtoS(RB6->RB6_DTREF)) .And. DtoS(dDtRefAte) >= DtoS(RB6->RB6_DTREF))  )

  		If 	cNivel # RB6->RB6_NIVEL
			aValores:=aSort(aValores,,,{|x,y| x[2] < y[2] })
			Aadd(aTabela,{cNivel,aValores[1][2],aValores[Len(aValores)][2],nMinPtos,nMaxPtos,aValores,nTipo})

			cNivel 	:= RB6->RB6_NIVEL
			nMinPtos:= RB6->RB6_PTOMIN

			aValores:= {}
		EndIf

		Aadd(aValores,{.F.,RB6->RB6_VALOR,RB6->RB6_FAIXA,cNivel,RB6->RB6_PTOMIN,RB6->RB6_PTOMAX})

		nMaxPtos:= RB6->RB6_PTOMAX

		dbSkip()

	EndDo

	Aadd(aTabela,{cNivel,aValores[1][2],aValores[Len(aValores)][2],nMinPtos,nMaxPtos,aValores,nTipo})

EndIf

RestArea(aSaveArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Cs030Salario ³ Autor ³ Cristina Ogura    ³ Data ³ 19.10.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se o salario digitado esta na faixa selecionada    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM030       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Cs030Salario(nSal)
Local lRet	:= .F.
Local nx	:= 0

//Verifico se o salario digitado esta na faixa selecionada
For nx:=1 To Len(a2Lbx)

	If 	a2Lbx[nx][1] .And. nSal >= a2Lbx[nx][5] .And. nSal <= a2Lbx[nx][6]

		// Atualiza Faixa Salarial ao Confirmar
		If 	nTipo == 2 .Or. nTipo == 4
			a2Lbx[nx][3] := Cs030Faixa( nSal, nx )	// Atualiza Faixa
		EndIf

		lRet := .T.
		Exit
	EndIf
Next nx
If !lRet
	For nx:=1 To Len(a3Lbx)
		If 	a3Lbx[nx][1] .And.	nSal >= a3Lbx[nx][5] .And. nSal <= a3Lbx[nx][6]

			// Atualiza Faixa Salarial ao Confirmar
			If 	nTipo == 2 .Or. nTipo == 4
				a3Lbx[nx][3] := Cs030Faixa( nSal, nx )	// Atualiza Faixa
			EndIf

			lRet := .T.
			Exit
		EndIf
	Next nx
EndIf

If !lRet
	Help("",1,"CS030VERSAL")
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CS030Relat³ Autor ³ Cristina Ogura       ³ Data ³ 19.10.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina Principal do relatorio para adequacao salarial      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM030       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs030Relat(lEnd,WnRel,cString)

Local cDescTab	:= ""
Local nPos		:= 0
Local aSalarios	:= {}
Local aPontos	:= {}
Local nQuantos	:= 0
Local cDet		:= ""

Private nTipo	:= 0

Cs030LePerg(.F.)

If Empty(dDtRefAte)
	Help(,,".RHDTTABSAL.",,STR0057,3,1)	//Preencha o campo 'Data de Referência Até:'.
	Return Nil
EndIf

dbSelectArea("RB6")
dbSetOrder(1)
If !dbSeek(xFilial("RB6")+cTabela)
	Help("",1,"CS030NOTAB")	//Defina a tabela salarial nos parametros.
	Return Nil
EndIf

cDescTab:= RB6->RB6_DESCTA
nTipo	:= RB6->RB6_TIPOVL

wCabec1 += cTabela+" - "+cDescTab		//"Tabela Salarial:"

// Monta os dados da Tabela Salarial
Cs030MontTab()

If 	Len(aTabela) == 0
	Help("",1,"CS030VLTAB")	//Defina os valores da faixa salarial
	Return Nil
EndIf

// Cria arquivos temporarios
CS030Cria()

// Monta os dados do Relatorio
CS030Mont()

dbSelectArea("TR1")

SetRegua(TR1->(RecCount()))

dbGotop()

While !Eof()

	IncRegua()

	//"Fil Matric Nome do Funcionario            Salario Atual  Ptos Func. Ptos Cargo Cargo Desc Cargo                     Centro Custo Descricao Centro Custo         Funcao Descricao Funcao  "
	//" 99 999999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 999,999,999,99 9999999999 9999999999 99999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    999999999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   9999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	cDet:= Space(01)+TR1->TR1_FILIAL+Space(01)+TR1->TR1_MAT+Space(01)
	cDet+= TR1->TR1_NOME+Space(01)+Transform(TR1->TR1_SALARI,"999,999,999.99")+Space(01)
	cDet+= Transform(TR1->TR1_PTFUNC,"9999,999.99")+Space(01)
	cDet+= Transform(TR1->TR1_PTCARG,"9999,999.99")+Space(01)
	cDet+= TR1->TR1_CARGO+Space(01)
	cDet+= TR1->TR1_DESCCA+Space(04)
	cDet+= TR1->TR1_CC+Space(01)
	cDet+= TR1->TR1_DESCCC+Space(02)
	cDet+= TR1->TR1_FUNCAO+Space(01)
	cDet+= TR1->TR1_DESCFUN
	IMPR(cDet,"C")
	IMPR("","C")

	nPos 	:=0
	nPos	:= Ascan(aGuarda,{|x| x[1]+x[2]== TR1->TR1_FILIAL+TR1->TR1_MAT })
	If nPos > 0
		aSalarios 	:= aGuarda[nPos][3]
		aPontos		:= aGuarda[nPos][4]
	EndIf

	IMPR(Space(05)+STR0048,"C")			//"Adequacao pelo Valor"

	Cs030Qtos(Len(aSalarios),aSalarios,Nil)

	If Len(aPontos) > 0
		IMPR(Space(05)+STR0049,"C")			//"Adequacao pelos Pontos do Cargo"
		Cs030Qtos(Len(aPontos),aPontos,Nil)
	EndIf

	dbSelectArea("TR1")
	dbSkip()

EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Termino do relatorio                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Impr("","F")

dbSelectArea("TR1")
dbCloseArea()


If oArq1Tmp <> Nil
	oArq1Tmp:Delete()
	Freeobj(oArq1Tmp)
EndIf


dbSelectArea("SRA")
Set Filter To
RetIndex("SRA")
dbSetOrder(1)


dbSelectArea(cNtxAlias)
DbCloseArea()

If oArqNtxTmp <> Nil
	oArqNtxTmp:Delete()
	Freeobj(oArqNtxTmp)
EndIf

dbSelectArea("RB6")
Set Filter To
dbSetOrder(1)

dbSelectArea("SRA")
Set Filter To
dbSetOrder(1)

Set Device To Screen
If aReturn[5] = 1
	Set Printer To
	Commit
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Spool caso Opcao seja de Relatorio, senao sai apresenta-lo.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ourspool(wnrel)
Endif

MS_FLUSH()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Cs030Qtos ³ Autor ³ Cristina Ogura       ³ Data ³ 19.10.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime quantos valores de faixa salarial existir na tabela³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM030       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Cs030Qtos(nTam,aArray,oSection)

Local nQuantos 	:= 0
Local cDet		:= ""
Local nx		:= 0
Local ny      	:= 0
Local nInic 	:= 0
Local nSpace	:= 0
Local cPontos	:= ""

If 	nTam <= 6
	nQuantos := 1
Else
	nQuantos :=	INT(nTam/6)
	If (nTam - (nQuantos * 6)) > 0
		nQuantos := nQuantos + 1
	EndIf
EndIf

For nx:=1 To nQuantos

	// Valores
	cDet := ""
	cImpr:= ""

	If nx == 1
		nInic := 1
	Else
		nInic := ((6 * nx)+ 1) - 6
	EndIf

	For ny:= nInic To (nx * 6)
		If 	ny > Len(aArray)
			Exit
		EndIf
		If nTipo == 1 .Or. nTipo == 3
			cDet := Transform(aArray[ny][2],"99,999,999,999.99") + Space(02) + "[ ]"
		ElseIf nTipo == 2 .Or. nTipo == 4
			cDet := aArray[ny][2] + Space(02) + "[ ]"
		EndIf
		cImpr += cDet
	Next ny

	oSection:Cell("VALOR"):SetValue(cImpr)

	// Pontos
	cImpr:= ""
	cDet := ""
	For ny:= nInic To (nx * 6)
		If 	ny > Len(aArray)
			Exit
		EndIf
		If nTipo == 1 .Or. nTipo == 3
			If aArray[ny][5] == aArray[ny][6]
				cDet := Space(04)+Transform(aArray[ny][5],"999,999,999.99") + Space(02)
			Else
				cDet := Space(04)+Transform(aArray[ny][5],"9999.99") +" - "+ Transform(aArray[ny][6],"9999.99") + Space(01)
			EndIf

		ElseIf nTipo == 2 .Or. nTipo == 4
			nSpace := Len(aArray[ny][2])
			If aArray[ny][7] == aArray[ny][8]
				cPontos := Space(04)+AllTrim(Transform(aArray[ny][7],"999,999,999.99"))
				nSpace 	:= nSpace - Len(cPontos) + 6
				cDet 	:=  cPontos + Space(nSpace)
			Else
				cPontos := Space(04)+AllTrim(Transform(aArray[ny][7],"9999.99")) +" - "+ AllTrim(Transform(aArray[ny][8],"9999.99"))
				nSpace 	:= nSpace - Len(cPontos) + 5
				cDet 	:=  cPontos+ Space(nSpace)
			EndIf
		EndIf

		cImpr += cDet

		If nTipo == 1 .Or. nTipo == 2	//Ptos. p/ Nivel mostra apenas uma vez.
			cImpr := AllTrim(cImpr)
			Exit
		EndIf

	Next ny

	oSection:Cell("PONTOS"):SetValue(cImpr)
   oSection:PrintLine()	//Imprime os Valores da Secao passada por parametro

	IMPR("","C")

Next nx

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Cs030Faixa³ Autor ³ Emerson Grassi Rocha ³ Data ³ 03/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a Faixa da Tabela para Tipo 2 e 4 (Intervalo).	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM030       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Cs030Faixa(nSalario, nx)

Local nPosFx	:= 0
Local cFaixa	:= ""
Local nFaixa1	:= 0
Local nFaixa2	:= 0
Local ny		:= 0
Local nW		:= 0

If nTipo != 4
	nPosFx := Ascan(aTabela[nx][6], { |nFx| nFx[2] >= nSalario .And. nFx[2] <= nSalario } )
	If nPosFx > 0
		nFaixa1 := Val( aTabela[nx][6][nPosFx][3] ) / 2
		nFaixa2 := Int( nFaixa1 )
		If nFaixa1 != nFaixa2
			nFaixa2++
		EndIf
		cFaixa := StrZero( nFaixa2, 2 )
	EndIf
Else
	For ny := 1 To Len(aTabela)
		nPosFx := Ascan(aTabela[ny][6], { |nFx| nFx[2] <= nSalario } )
		If nPosFx > 0 .And. !CsmIsPar(nPosFx)
			For nw := 1 To Len(aTabela[ny][6])
			    If nPosFx < Len(aTabela[ny][6]) .And. aTabela[ny][6][nPosFx+1][2] >= nSalario
					nFaixa1 := Val( aTabela[ny][6][nPosFx][3] ) //  / 2
					cFaixa := StrZero( nFaixa1, 2 )
					Exit
				EndIf
				nPosFx++
			Next nw
			If !Empty(cFaixa)
				Exit
			EndIf
		EndIf
	Next ny
EndIf
Return cFaixa

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CsmIsPar	 ³ Autor ³ Emerson Grassi Rocha ³ Data ³ 07/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se um Valor eh Par (.T.) / Impar (.F.)			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CsmIsPar(nValor)

Local nValor2 := nValor / 2
Local nValor3 := Int(nValor2)

Return (nValor2 == nValor3)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CS030Sal  ³ Autor ³ Eduardo Ju           ³ Data ³ 13.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Historico Salarial do Funcionario na posicao corrente.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM030       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CS030Sal(nReg,aGdCoord,oDlgMain)

Local nRegSRA	:= nReg

dbSelectArea("SRA")
dbSetOrder(1)
dbSeek(xFilial("SRA")+TR1->TR1_MAT)
nRegSRA:= SRA->(RECNO())

Gpea250(2) // CHAMADA DIRETA MODO VISUALIZAÇÃO
Return Nil

/*
DESENVOLVIMENTO DO RELATORIO PERSONALIZAVEL ABAIXO
*/
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Cs030Impr³ Autor ³ Eduardo Ju            ³ Data ³ 21/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de impressao para fazer a adequacao salarial        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CSAM030                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			   ³		³	   ³										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs030Impr()

Local oReport

Local aArea := GetArea()
Private cImpr

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("CSM030",.F.)

oReport := ReportDef()
oReport:PrintDialog()

RestArea( aArea )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ReportDef() ³ Autor ³ Eduardo Ju          ³ Data ³ 21/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Definicao do Componente de Impressao do Relatorio           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()

Local oReport
Local oSection1
Local oSection2
Local oSection3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:=TReport():New("CSAM030",STR0036,"CSM030",{|oReport| PrintReport(oReport)},STR0029+" "+STR0030+" "+STR0031)	//"Emiss„o do Relatorio para Adequacao Salarial."#"Será impresso de acordo com os parametros solicitados pelo usuario"
oReport:SetLandscape()	//Imprimir Somente Paisagem
Pergunte("CSM030",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Primeira Secao: "Funcionario" ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New(oReport,STR0055,{"SRA","SQ8","SQ3","SQ4","CTT","SRJ"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//Funcionario
oSection1:SetTotalInLine(.F.)
oSection1:SetHeaderBreak(.T.)

TRCell():New(oSection1,"RA_FILIAL","SRA",,,,,{|| TR1->TR1_FILIAL })				//Filial do Funcionario
TRCell():New(oSection1,"RA_MAT","SRA",STR0055,,,,{|| TR1->TR1_MAT })				//Matricula do Funcionario
TRCell():New(oSection1,"RA_NOME","SRA","",,,,{|| TR1->TR1_NOME })					//Nome do Funcionario
TRCell():New(oSection1,"RA_SALARIO","SRA",,,,,{|| TR1->TR1_SALARI  })				//Salario do Funcionario
TRCell():New(oSection1,"Q8_PONTOS","SQ8",STR0010,"9999,999.99",,,{|| TR1->TR1_PTFUNC })//Pontos do Funcionario
TRCell():New(oSection1,"Q4_PONTOS","SQ4",STR0011,"9999,999.99",,,{|| TR1->TR1_PTCARG })//Pontos do Cargo
TRCell():New(oSection1,"RA_CARGO","SRA",,,,,{|| TR1->TR1_CARGO })					//Cargo do Funcionario
TRCell():New(oSection1,"Q3_DESCSUM","SQ3","")										//Descricao do Cargo
TRCell():New(oSection1,"RA_CC","SRA",,,,,{|| TR1->TR1_CC })  						//Centro De Custo do Funcionario
TRCell():New(oSection1,"CTT_DESC01","CTT","") 		   								//Descricao do CC
TRCell():New(oSection1,"RA_CODFUNC","SRA","Função",,,,{|| TR1->TR1_FUNCAO }) 		//Funcao do Funcionario
TRCell():New(oSection1,"RJ_DESC","SRJ","")											//Descricao da Funcao do Funcionario

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Segunda Secao: Adequacao pelo Valor ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection2 := TRSection():New(oSection1,STR0048,{"RB6"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)		//"Adequacao pelo Valor"
oSection2:SetTotalInLine(.T.)
oSection2:SetHeaderBreak()
oSection2:ShowHeader(.T.) 	//Imprime Cabecalho da Secao
oSection2:SetLeftMargin(3)	//Identacao da Secao
oSection2:SetLineStyle()	//Imprime Celula em Linha
oCell := TRCell():New(oSection2,"VALOR"	,"   ",STR0050,,200,,{|| cImpr })	//Valores
oCell:SetCellBreak()
TRCell():New(oSection2,"PONTOS","   ",STR0052,,200,,{|| cImpr})	//"Pontos do Nivel"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Terceira Secao: Adequacao pelos Pontos do Cargo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection3 := TRSection():New(oSection1,STR0049,{"RB6"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)		//"Adequacao pelos Pontos do Cargo"
oSection3:SetTotalInLine(.T.)
oSection3:SetHeaderBreak()
oSection3:ShowHeader(.T.)	//Imprime Cabecalho da Secao
oSection3:SetLeftMargin(3)	//Identacao da Secao
oSection3:SetLineStyle()
oCell := TRCell():New(oSection3,"VALOR","   ",STR0050,,200,,{|| cImpr })	//Valores
oCell:SetCellBreak()
TRCell():New(oSection3,"PONTOS","   ",STR0052,,200,,{|| cImpr }) 	//"Pontos do Nivel"

Return oReport

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ReportDef() ³ Autor ³ Eduardo Ju          ³ Data ³ 22.08.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do Relatorio                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PrintReport(oReport)

Local oSection1 := oReport:Section(1)				//Secao Funcionario
Local oSection2 := oReport:Section(1):Section(1)	//Secao Adequacao pelo Valor
Local oSection3 := oReport:Section(1):Section(2)	//Secao Adequacao pelos Pontos
Local nPos		:= 0
Local aSalarios	:= {}
Local aPontos	:= {}
Local nQuantos	:= 0
Local cTitle 	:= ""

aTabela := {}
aGuarda := {}

Cs030LePerg(.F.)

If Empty(dDtRefAte)
	Help(,,".RHDTTABSAL.",,STR0057,3,1)	//Preencha o campo 'Data de Referência Até:'.
	Return Nil
EndIf

dbSelectArea("RB6")
dbSetOrder(1)
dbGoTop()
If !dbSeek(xFilial("RB6")+ cTabela)
	Help("",1,"CS030NOTAB")	//Defina a tabela salarial nos parametros.
	Return Nil
EndIf

nTipo	:= RB6->RB6_TIPOVL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Troca do Titulo do Relatorio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDescTab:= RB6->RB6_DESCTA
cTitle :=If(AllTrim(oReport:Title())==AllTrim(cTitle),STR0036 + " - "  + UPPER(STR0034) + " " + cTabela+" - "+cDescTab,oReport:Title())

oReport:SetTitle(cTitle)

// Monta os dados da Tabela Salarial
Cs030MontTab()

If 	Len(aTabela) == 0
	Help("",1,"CS030VLTAB")	//Defina os valores da faixa salarial
	Return Nil
EndIf

// Cria arquivos temporarios
CS030Cria()

// Monta os dados do Relatorio
CS030Mont()

dbSelectArea("TR1")
dbGotop()

TRPosition():New(oSection1,"SQ3",1,{|| xFilial("SQ3") + TR1->TR1_CARGO})
TRPosition():New(oSection1,"CTT",1,{|| xFilial("CTT") + TR1->TR1_CC})
TRPosition():New(oSection1,"SQ4",2,{|| xFilial("SQ4") + TR1->TR1_CARGO + TR1->TR1_CC})
TRPosition():New(oSection1,"SQ8",1,{|| xFilial("SQ8") + TR1->TR1_MAT})
TRPosition():New(oSection1,"SRJ",1,{|| xFilial("SRJ") + TR1->TR1_FUNCAO})

While TR1->( !Eof() )

	oReport:IncMeter()

	If oReport:Cancel()
		Exit
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao da Secao 1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1:Init()
	oSection1:PrintLine()

	nPos 	:=0
	nPos	:= Ascan(aGuarda,{|x| x[1]+x[2]== TR1->TR1_FILIAL+TR1->TR1_MAT })

	If nPos > 0
		aSalarios 	:= aGuarda[nPos][3]
		aPontos		:= aGuarda[nPos][4]
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao da Secao 2 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    oSection2:Init()
	Cs030Qtos(Len(aSalarios),aSalarios,oSection2)
	oSection2:Finish()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao da Secao 3 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aPontos) > 0
		oSection3:Init()
		Cs030Qtos(Len(aPontos),aPontos,oSection3)
		oSection3:Finish()
	EndIf

	oreport:Thinline()
	oSection1:Finish()
	dbSelectArea("TR1")
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Termino do relatorio                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TR1")
dbCloseArea()

If oArq1Tmp <> Nil
	oArq1Tmp:Delete()
	Freeobj(oArq1Tmp)
EndIf

dbSelectArea("SRA")
Set Filter To
RetIndex("SRA")
dbSetOrder(1)


dbSelectArea(cNtxAlias)
DbCloseArea()

If oArqNtxTmp <> Nil
	oArqNtxTmp:Delete()
	Freeobj(oArqNtxTmp)
EndIf

dbSelectArea("RB6")
Set Filter To
dbSetOrder(1)

dbSelectArea("SRA")
Set Filter To
dbSetOrder(1)

Return Nil

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³28/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³CSAM030                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function MenuDef()

 Local aRotina :=  {	{ STR0001,'Cs030Perg',0,7,,.F.},;	//"Parametros"
						{ STR0002,'Cs030Adeq',0,7,,.F.},;	//"Adequar Salario"
			 			{ STR0056,'GpLegend' ,0,5,,.F.},;	//"Legenda"
						{ STR0003,'Cs030Impr',0,7,,.F.};   //"Imprimir"
					  }

Return aRotina
