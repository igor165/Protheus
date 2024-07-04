#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TRMA090.CH"

#DEFINE POS_FILIAL	 1
#DEFINE POS_MATRIC	 2
#DEFINE POS_ACOLS	 3

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TRMA090  ³ Autor ³ Cristina Ogura        ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Controle das Despesas do Curso                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Avoid                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Program.  ³ Data   ³ BOPS  ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia C.³21.07.14³TPZSOX ³Incluido o fonte da 11 para a 12 e efetuada³±±
±±³          ³        ³       ³a limpeza.                                 ³±±
±±³Isabel N. ³08/02/17³MRH-3233³ Ajuste no nome do campo RA2_REALIZA para ³±±
±±³          ³        ³        ³RA2_REALIZ, conforme cadastrado no Atusx. ³±±
±±³Oswaldo L.  ³03/04/17³DRHPONTP-9  ³Projeto cTree                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TRMA090
Local cFiltra		:= ""				//Variavel para filtro
Local aIndFil		:= {}				//Variavel Para Filtro
Local aCores		:= {}
Local aAuxCor		:={}
Local _nX       	:= 0
Private bFiltraBrw 	:= {|| Nil}		//Variavel para Filtro
Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemtoAnsi(STR0004)	//"Controle das Despesas dos Cursos"
Private aLegenda  := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RA2")
dbSetOrder(1)

cFiltra 	:= CHKRH(FunName(), "RA2", "1")
bFiltraBrw 	:= {|| FilBrowse("RA2",@aIndFil,@cFiltra) }
Eval(bFiltraBrw)

aAdd(aCores, {'RA2->RA2_REALIZ != "S"', "ENABLE"	  , ""}) //"Em Aberto"
aAdd(aCores, {'RA2->RA2_REALIZ == "S"' , "BR_VERMELHO", ""}) //"Encerrado"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definiao de cores por usuarios      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("TRM090LEG")
	aAuxCor := ExecBlock("TRM090LEG",.F.,.F.,{aCores} )
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

mBrowse(NIL, NIL, NIL, NIL, "RA2", NIL, NIL, NIL,,,aCores)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("RA2", aIndFil)

dbSelectArea("RA3")
dbSetOrder(1)

dbSelectArea("RA2")
dbSetOrder(1)

dbSelectArea("RAA")
dbSetOrder(1)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr090Rot  ³ Autor ³ Cristina Ogura       ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta o Controle das Despesas dos Curso                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA090       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr090Rot(cAlias, nReg, nOpcx)
Local aSaveArea		:= GetArea()
Local cDescCalend	:= RA2->RA2_DESC
Local cDescCurso	:= CriaVar("RA1_CURSO")
Local oDlgMain, oLbx
Local cLbx			:= ""
Local lTrDel		:= If(nOpcx == 2 .Or. nOpcx == 5, .F., .T.)
Local nOpc 			:= 0

Local cIndCond		:= ""

Local aAvFields		:= {} //campos exibidos em tela a serem avaliados pelo gerenciamento de dados sensiveis
Local aPDFields		:= {} //campos que estao classificados como dados sensiveis
Local aOfuscaCpo	:= {}
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T. , .F.}) //[1] Acesso; [2]Ofusca
Local aFldRot 		:= {'RA_NOME'}
Local nX			:= 0
Local nPos			:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Dimensionar Tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords 	:= {}
Local __aStruRAA__ := {}
Local nLoop
Local nTotLoop
Local cTrTesAlias := GetNextAlias()
Local aFields     := {}
Local oTmpRAA
// Private da Getdados
Private aCols  		:= {}
Private aHeader		:= {}
Private Continua	:= .F.

Private oGet, oSay1

Private cSay		:= ""
Private aLstCols 	:= {}
Private cFil		:= RA2->RA2_FILIAL
Private cCalend 	:= RA2->RA2_CALEND
Private cCurso		:= RA2->RA2_CURSO
Private cTurma		:= RA2->RA2_TURMA
Private cUltFil     := ""
Private cUltMat     := ""

Private oTmpTR1
// MV_PAR01    - Ordem 1-Nome 2-Matricula 3-Centro Custo 4-Funcao
// MV_PAR02		- Filial De
// MV_PAR03		- Filial Ate
// MV_PAR04		- Matricula de
// MV_PAR05		- Matricula ate
// MV_PAR06		- Centro Custo de
// MV_PAR07		- Centro Custo ate
// MV_PAR08		- Funcao de
// MV_PAR09		- Funcao ate

Pergunte("TRM090",.F.)


dbSelectArea("RAA")
cIndCond	:= "RAA_CALEND+RAA_CURSO+RAA_TURMA"
__aStruRAA__ := RAA->(dbStruct())
nTotLoop	:= Len(__aStruRAA__)

For nLoop:=1 To nTotLoop
	AADD(aFields,{	__aStruRAA__[nLoop,1]   ,;
       		        __aStruRAA__[nLoop,2]  	,;
			        __aStruRAA__[nLoop,3]  	,;
			        __aStruRAA__[nLoop,4]    }    )
Next

oTmpRAA := RhCriaTrab(cTrTesAlias, aFields, Nil)

IndRegua("RAA",cTrTesAlias,cIndCond,,,STR0016)


If dbSeek(cCalend+cCurso+cTurma)
	//-- Se existe e inclusao nao deixar
	If nOpcx == 3
		Help("",1,"TR090EXIS") // Avaliacao ja cadastrada

		RetIndex("RAA")

		dbcloseArea(cTrTesAlias)
		If oTmpRAA <> Nil
			oTmpRAA:Delete()
			Freeobj(oTmpRAA)
		EndIf

		Set Filter to

		RestArea(aSaveArea)
		Return
	Endif
Else
    //Se Nao Achou e nao for inclusao nao permitir
    If nOpcx != 3
		Help("",1,"Tr090NEXIS")	// Avaliacao nao cadastrada

		RetIndex("RAA")

		dbcloseArea(cTrTesAlias)
		If oTmpRAA <> Nil
			oTmpRAA:Delete()
			Freeobj(oTmpRAA)
		EndIf

		Set Filter to

		RestArea(aSaveArea)
		Return
	Endif
Endif

RetIndex("RAA")
dbcloseArea(cTrTesAlias)

If oTmpRAA <> Nil
	oTmpRAA:Delete()
	Freeobj(oTmpRAA)
EndIf

Set Filter to

If RA2->RA2_REALIZ == "S"
	If nOpcx != 2
		Help("",1,"TRA070BAIX")			// Este curso ja foi baixado
		RestArea(aSaveArea)
		Return Nil

	ElseIf !Tr090Mont2()	//Visualizacao
		Help("",1,"TR090NOFUNC")		// Nao existem funcionarios reservados para este curso
		RestArea(aSaveArea)
		Return Nil
	EndIf
Else
	// Monta os dados dos ListBox
	If !Tr090Monta()
		Help("",1,"TR090NOFUNC")		// Nao existem funcionarios reservados para este curso
		RestArea(aSaveArea)
		Return Nil
	EndIf
EndIf

// Curso
dbSelectArea("RA1")
dbSetOrder(1)

If dbSeek(xFilial("RA1")+cCurso)
	cDescCurso := RA1->RA1_DESC
EndIf

dbSelectArea("TR1")
dbGoTop()

// Monta o acols conforme o funcionario posicionado
Tr090Troca(TR1->TR1_FILIAL, TR1->TR1_MAT, TR1->TR1_NOME, nOpcx, .T.)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

aAdv1Size    := aClone(aObjSize[2])
aInfo1AdvSize    := { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 5 , 5 }
aAdd( aObj1Coords , { 000 , 000 , .T. , .T., .T. } )
aAdd( aObj1Coords , { 002 , 000 , .F. , .T. } )
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )
aObj1Size := MsObjSize( aInfo1AdvSize , aObj1Coords,,.T. )

DEFINE MSDIALOG oDlgMain FROM	aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cCadastro OF oMainWnd  PIXEL

	@aObjSize[1,1], (aObjSize[1,2]*2.5) 		SAY OemToAnsi(STR0005)	OF oDlgMain PIXEL		//"Calend rio: "
	@aObjSize[1,1], (aObjSize[1,2]*2.5)+30    	SAY cCalend	+ " - " + cDescCalend OF oDlgMain PIXEL
	@aObjSize[1,1], (aObjSize[1,4]*0.4)  		SAY OemToAnsi(STR0006) OF oDlgMain PIXEL		//"Curso: "
	@aObjSize[1,1], (aObjSize[1,4]*0.4)+30 	SAY cCurso + " - " + Subst(cDescCurso,1,20) OF oDlgMain PIXEL
	@aObjSize[1,1], (aObjSize[1,4]*0.7)		SAY OemToAnsi(STR0007) OF oDlgMain PIXEL		//"Turma: "
	@aObjSize[1,1], (aObjSize[1,4]*0.7)+30 	SAY cTurma OF oDlgMain PIXEL

	//Primeiro Quadro
	@ aObj1Size[1,1], aObj1Size[1,2] LISTBOX oLbx VAR cLbx FIELDS;
				HEADER	OemtoAnsi(STR0009),;			//"Nome"
							OemtoAnsi(STR0010),;		//"Fil."
							OemtoAnsi(STR0011),;		//"Matricula"
							OemtoAnsi(STR0012),;		//"Centro Custo"
							OemtoAnsi(STR0013),;		//"Descr. Centro Custo"
							OemtoAnsi(STR0014),;		//"Fun‡„o "
							OemtoAnsi(STR0015);			//"Descr. Fun‡„o"
				COLSIZES	GetTextWidth(0, Replicate("B", GetSx3Cache("RA_NOME", "X3_TAMANHO"))),;
							GetTextWidth(0, Replicate("B", FWGETTAMFILIAL)),;
							GetTextWidth(0, Replicate("B", GetSx3Cache("RA_MAT", "X3_TAMANHO"))),;
							GetTextWidth(0, Replicate("B", GetSx3Cache("RA_CC", "X3_TAMANHO"))),;
							GetTextWidth(0, Replicate("B", GetSx3Cache("CTT_DESC01", "X3_TAMANHO"))),;
							GetTextWidth(0, Replicate("B", GetSx3Cache("RA_CODFUNC", "X3_TAMANHO"))),;
							GetTextWidth(0, Replicate("B", GetSx3Cache("RJ_DESC", "X3_TAMANHO")));
				SIZE aObj1Size[1,3], aObj1Size[1,4]  OF oDlgMain PIXEL;
	ON CHANGE (Tr090Troca(TR1->TR1_FILIAL, TR1->TR1_MAT, TR1->TR1_NOME, nOpcx, .F.))
	oLbx:bLine:= {||{ TR1->TR1_NOME,;
						TR1->TR1_FILIAL,;
						TR1->TR1_MAT,;
						TR1->TR1_CC,;
						TR1->TR1_DESCCC,;
						TR1->TR1_FUNCAO,;
						TR1->TR1_DESCFUN}}

	//Proteção de Dados Sensíveis
	If aOfusca[2]
		aOfuscaCpo := {.F.,.F.,.F.,.F.,.F.,.F.,.F.}
		aAvFields  := {"RA_NOME","RA_FILIAL","RA_MAT","RA_CC","RA_DESCCC","RA_CODFUNC","RA_DESCFUN"}
		aPDFields := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot ) // CAMPOS SEM ACESSO
		oLbx:lObfuscate := .T.
		For nX := 1 to Len(aAvFields)
			IF aScan( aPDFields , { |x| x:CFIELD == aAvFields[nx] } ) > 0
				aOfuscaCpo[nx] := .T.
			ENDIF
		Next nX
		oLbx:aObfuscatedCols := aOfuscaCpo
	EndIf

	//Segundo Quadro
	@ aObj1Size[3,1], aObj1Size[3,2] 		SAY  STR0008 OF oDlgMain PIXEL					//"Nome: "
	@ aObj1Size[3,1], aObj1Size[3,2]+25 	SAY oSay1 PROMPT cSay OF oDlgMain PIXEL SIZE 100,7

	oGet := MSGetDados():New(	aObj1Size[3,1]+10,;
								aObj1Size[3,2],;
								aObj1Size[3,3],;
								aObj1Size[3,4],;
								nOpcx,;
								"Tr090Ok",;
								"AlwaysTrue",;
								"",;
								lTrDel,;
								,;
								1,;
								,;
								900,;
								,;
								,;
								,;
								,;
								oDlgMain)

	ACTIVATE MSDIALOG oDlgMain ON INIT (EnchoiceBar(oDlgMain, {||nOpc:=1, If(Tr090Grava(nOpcx),oDlgMain:End(),) },{|| nOpc := 2,oDlgMain:End()}))

If nOpcx == 5 .And. nOpc == 1
	TR090Dele(TR1->TR1_FILIAL)
EndIf

dbSelectArea("TR1")
dbCloseArea()

If oTmpTR1 <> Nil
	oTmpTR1:Delete()
	Freeobj(oTmpTR1)
EndIf


RestArea(aSaveArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr090Rat  ³ Autor ³ Emerson Grassi Rocha ³ Data ³ 30/10/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Lancamento de Despesas para Rateio entre funcionarios.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA090       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr090Rat(cAlias, nReg, nOpcx)
Local cDescCalend	:= RA2->RA2_DESC
Local cDescCurso	:= CriaVar("RA1_CURSO")
Local oDlgMain, oLbx
Local cLbx		:= ""
Local aFields	:= {}
Local lTrDel	:= If(nOpcx == 2 .Or. nOpcx == 5,.F.,.T.)
Local aSaveArea	:= GetArea()

// Local objeto Radio
Local oRadio
Local oGroup
Local oFont
Local bBlock
Local aAltern	:= {}
Local nRadio	:= 1

Local aAdvSize				:= {}
Local aInfoAdvSize			:= {}
Local aObjSize				:= {}
Local aObjCoords			:= {}

// Private da Getdados
Private aCols  	:= {}
Private aHeader	:= {}
Private Continua:= .F.

Private oGet, oSay1
Private  cSay
Private aLstCols := {}
Private cFil	:= RA2->RA2_FILIAL
Private cCalend := RA2->RA2_CALEND
Private cCurso	:= RA2->RA2_CURSO
Private cTurma	:= RA2->RA2_TURMA
Private cUltFil     := ""
Private cUltMat     := ""
Private oTmpTR1

If RA2->RA2_REALIZ == "S"
	Help("",1,"TRA070BAIX")			// Este curso ja foi baixado
	RestArea(aSaveArea)
	Return
EndIf

aFields :={"RAA_FILIAL","RAA_MAT   ","RAA_CALEND","RAA_CURSO ","RAA_TURMA"}

// MV_PAR01    - Ordem 1-Nome 2-Matricula 3-Centro Custo 4-Funcao
// MV_PAR02		- Filial De
// MV_PAR03		- Filial Ate
// MV_PAR04		- Matricula de
// MV_PAR05		- Matricula ate
// MV_PAR06		- Centro Custo de
// MV_PAR07		- Centro Custo ate
// MV_PAR08		- Funcao de
// MV_PAR09		- Funcao ate

Pergunte("TRM090",.F.)


// Curso
dbSelectArea("RA1")
dbSetOrder(1)
If dbSeek(xFilial("RA1")+cCurso)
	cDescCurso := RA1->RA1_DESC
EndIf

// Monta os dados dos ListBox
If !Tr090Monta()
	Help("",1,"TR090NOFUNC")				// Nao existem funcionarios reservados para este curso
	RestArea(aSaveArea)
	Return Nil
EndIf


// Monta os aCols possiveis - 1 para cada funcionario
Tr090ColRat(nOpcx)

dbSelectArea("TR1")
dbGotop()

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize( , .T., 390)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aAdd( aObjCoords , { 000 , 035 , .T. , .F. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )


DEFINE FONT oFont   NAME "Arial" SIZE 0,-11 BOLD

DEFINE MSDIALOG oDlgMain FROM	aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cCadastro OF oMainWnd PIXEL

	@ aObjSize[1,1], (aObjSize[1,2]*2.5)  		SAY OemToAnsi(STR0005) OF oDlgMain PIXEL		//"Calend rio: "
	@ aObjSize[1,1], (aObjSize[1,2]*2.5)+30 	SAY cCalend	+ " - " + cDescCalend OF oDlgMain PIXEL
	@ aObjSize[1,1], (aObjSize[1,4]*0.4)		SAY OemToAnsi(STR0006) OF oDlgMain PIXEL		//"Curso: "
	@ aObjSize[1,1], (aObjSize[1,4]*0.4)+30  	SAY cCurso + " - " + Subst(cDescCurso,1,20) OF oDlgMain PIXEL
	@ aObjSize[1,1], (aObjSize[1,4]*0.7) 		SAY OemToAnsi(STR0007) OF oDlgMain PIXEL		//"Turma: "
	@ aObjSize[1,1], (aObjSize[1,4]*0.7)+30 	SAY cTurma OF oDlgMain PIXEL

	// Radio
   	@ aObjSize[3,1], aObjSize[3,2] GROUP oGroup  TO aObjSize[3,3], aObjSize[3,4] LABEL STR0022 OF oDlgMain PIXEL	//"Caso existir lancamento anterior com mesma data: "
   	oGroup:oFont:= oFont

	aAltern := {	STR0023,;	//"Substituir valores anteriores"
				 	STR0024}	//"Acumular valores"
                                  //115,11
	bBlock 	:= { |x| If(ValType(x)=='U', nRadio , nRadio := x ) }
 	oRadio 	:= TRadMenu():New( aObjSize[3,1]+10, aObjSize[3,2]+10, aAltern,bBlock,oDlgMain,,,,,,,,298,17)
	nRadio 	:= oRadio:nOption
	oRadio:oFont:= oFont
    oRadio:Show()

	// GetDados
	oGet := MSGetDados():New(aObjSize[2,1], aObjSize[2,2], aObjSize[2,3], aObjSize[2,4],nOpcx,"Tr090Ok","AlwaysTrue","",lTrDel,,1, ,900,,,,,oDlgMain)

ACTIVATE MSDIALOG oDlgMain  ON INIT EnchoiceBar(oDlgMain, {|| IIf(oGet:TudoOK(),(Tr090CalRat(nOpcx, nRadio),oDlgMain:End()),.F.)}, {|| oDlgMain:End()} ) CENTERED

dbSelectArea("TR1")
dbCloseArea()

If oTmpTR1 <> Nil
	oTmpTR1:Delete()
	Freeobj(oTmpTR1)
EndIf

RestArea(aSaveArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr090Monta³ Autor ³ Cristina Ogura       ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta os listbox da reserva dos treinamentos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr090Monta(ExpC1,ExpC2,ExpC3)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA090       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr090Monta()
Local aSaveArea	:= GetArea()
Local cDescCC	:= ""
Local cDescFunc	:= ""
Local lOk 		:= .F.
Local cFil 		:= ""


// Cria arquivos temporarios para o Listbox
Tr090CriaArq()

dbSelectArea("RA3")
dbSetOrder(2)

cFil := xFilial("RA3", MV_PAR02)

dbSeek(cFil + RA2->RA2_CALEND,.T.)

While !Eof() .AND.;
	  RA3->RA3_FILIAL >= MV_PAR02 .AND.;
	  RA3->RA3_FILIAL <= MV_PAR03
	If 	RA3->RA3_CURSO 	!= 	RA2->RA2_CURSO .Or.;
	    RA3->RA3_CALEND	!= 	RA2->RA2_CALEND .Or.;
		RA3->RA3_TURMA 	!= 	RA2->RA2_TURMA .Or.;
		RA3->RA3_MAT 	< 	MV_PAR04 .Or.;
		RA3->RA3_MAT 	> 	MV_PAR05 .Or.;
		RA3->RA3_RESERV != "R"
		dbSkip()
		Loop
	EndIf

	dbSelectArea("SRA")
	dbSetOrder(1)
	dbSeek(RA3->RA3_FILIAL+RA3->RA3_MAT)

	If 	SRA->RA_CC 		< MV_PAR06 .Or.;
		SRA->RA_CC 		> MV_PAR07 .Or.;
		SRA->RA_CODFUNC	< MV_PAR08 .Or.;
		SRA->RA_CODFUNC	> MV_PAR09

		dbSelectArea("RA3")
		dbSkip()
		Loop
	EndIf

	// Montando o ListBox 1
	cDescCC	 := FDesc("CTT",SRA->RA_CC,"CTT->CTT_DESC01",30)
	cDescFunc:= FDesc("SRJ",SRA->RA_CODFUNC,"SRJ->RJ_DESC",30)

	lOk := .T.

	RecLock("TR1",.T.)
		TR1->TR1_FILIAL		:=	SRA->RA_FILIAL
		TR1->TR1_NOME		:=	SRA->RA_NOME
		TR1->TR1_MAT		:=	SRA->RA_MAT
		TR1->TR1_CC			:=	SRA->RA_CC
		TR1->TR1_DESCCC		:=	cDescCC
		TR1->TR1_FUNCAO		:= 	SRA->RA_CODFUNC
		TR1->TR1_DESCFUN	:=	cDescFunc
	MsUnlock()

	dbSelectArea("RA3")
	dbSkip()
EndDo

If !lOK

	dbSelectArea("TR1")
	dbCloseArea()

	If oTmpTR1 <> Nil
		oTmpTR1:Delete()
		Freeobj(oTmpTR1)
	EndIf

	dbSelectArea("RA3")
	dbSetOrder(1)
EndIf

RestArea(aSaveArea)
Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr090Mont2³ Autor ³ Emerson Grassi Rocha ³ Data ³ 04/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta os listbox de cursos realizados dos treinamentos     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr090Mont2()					                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA090       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr090Mont2()
Local aSaveArea	:= GetArea()
Local cDescCC	:= ""
Local cDescFunc	:= ""
Local lOk 		:= .F.
Local cFil 		:= ""

// Cria arquivos temporarios para o Listbox
Tr090CriaArq()

dbSelectArea("RA4")
dbSetOrder(3)
cFil := xFilial("RA4", MV_PAR02)
dbSeek(cFil + RA2->RA2_CALEND + RA2->RA2_CURSO + RA2->RA2_TURMA, .T.)
While !Eof() .And. RA4->RA4_FILIAL >= MV_PAR02 .And. 	RA4->RA4_FILIAL <= MV_PAR03

	If 	RA4->RA4_CURSO 	!= 	RA2->RA2_CURSO .Or.;
	    RA4->RA4_CALEND	!= 	RA2->RA2_CALEND .Or.;
		RA4->RA4_TURMA 	!= 	RA2->RA2_TURMA .Or.;
		RA4->RA4_MAT 	< 	MV_PAR04 .Or.;
		RA4->RA4_MAT 	> 	MV_PAR05
		dbSkip()
		Loop
	EndIf

	dbSelectArea("SRA")
	dbSetOrder(1)
	dbSeek(RA4->RA4_FILIAL+RA4->RA4_MAT)

	If 	SRA->RA_CC 		< MV_PAR06 .Or.;
		SRA->RA_CC 		> MV_PAR07 .Or.;
		SRA->RA_CODFUNC	< MV_PAR08 .Or.;
		SRA->RA_CODFUNC	> MV_PAR09

		dbSelectArea("RA4")
		dbSkip()
		Loop
	EndIf

	// Montando o ListBox 1
	cDescCC	 := FDesc("CTT",SRA->RA_CC,"CTT->CTT_DESC01",30)
	cDescFunc:= FDesc("SRJ",SRA->RA_CODFUNC,"SRJ->RJ_DESC",30)

	lOk := .T.
	RecLock("TR1",.T.)
		TR1->TR1_FILIAL		:=	SRA->RA_FILIAL
		TR1->TR1_NOME		:=	SRA->RA_NOME
		TR1->TR1_MAT		:=	SRA->RA_MAT
		TR1->TR1_CC			:=	SRA->RA_CC
		TR1->TR1_DESCCC		:=	cDescCC
		TR1->TR1_FUNCAO		:= 	SRA->RA_CODFUNC
		TR1->TR1_DESCFUN	:=	cDescFunc
	MsUnlock()

	dbSelectArea("RA4")
	dbSkip()
EndDo

If !lOK

	dbSelectArea("TR1")
	dbCloseArea()

	If oTmpTR1 <> Nil
		oTmpTR1:Delete()
		Freeobj(oTmpTR1)
	EndIf

	dbSelectArea("RA4")
	dbSetOrder(1)
EndIf

RestArea(aSaveArea)
Return lOk

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr090Grava³ Autor ³ Rogerio Ribeiro       ³ Data ³ 04.01.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os registros referente ao treinamentos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³				                                 		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr090Grava(nOpcx)
Local nx		:= 0
Local ny		:= 0
Local nz		:= 0
Local aRowsFunc	:= {}
Local aRow		:= {}
Local nPosRecNo	:=	GDFieldPos("RAA_REC_WT")
Local lInclusao := .F.
Local lExclusao := .F.

Tr090Transf()

If !Tr090Ok()
	Return .F.
EndIf

If nOpcx == 2 .Or. nOpcx == 5
	Return .T.
EndIf

dbSelectArea("RAA")
dbSetOrder(1)

Begin Transaction
	For nx := 1 To Len(aLstCols)
		aRowsFunc:= aLstCols[nx][POS_ACOLS]

		For ny := 1 To Len(aRowsFunc)
			aRow:= aRowsFunc[ny]
			lInclusao := aRow[nPosRecNo] == 0
			lExclusao := aRow[Len(aRow)]

			If lInclusao .AND. !lExclusao			//Inclusao
				RecLock("RAA", .T.)

				RAA->(FieldPut(FieldPos("RAA_FILIAL"), aLstCols[nx][POS_FILIAL]))
				RAA->(FieldPut(FieldPos("RAA_MAT"), aLstCols[nx][POS_MATRIC]))
				RAA->(FieldPut(FieldPos("RAA_CURSO"), cCurso))
				RAA->(FieldPut(FieldPos("RAA_TURMA"), cTurma))
				RAA->(FieldPut(FieldPos("RAA_CALEND"), cCalend))

			ElseIf !lInclusao .AND. !lExclusao		//Alteracao
				RAA->(dbGoto(aRow[nPosRecNo]))
				RecLock("RAA", .F.)

			ElseIf lExclusao						//Exclusao
				If !lInclusao
					RAA->(dbGoto(aRow[nPosRecNo]))
					RecLock("RAA", .F.)
					RAA->(dbDelete())
				Endif

				Loop
			Endif

			For nz := 1 To Len(aHeader)
				If aHeader[nz][10] != "V"
					RAA->(FieldPut(FieldPos(aHeader[nz][2]), aRow[nz]))
				EndIf
			Next nz

			MsUnlock()
		Next ny
	Next nx
End Transaction

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr090CalRat³ Autor ³ Emerson Grassi Rocha ³ Data ³ 30/10/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rateia Valores entre os funcionarios.			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±³          ³ ExpC2 : Codigo calendario                                  ³±±
±±³          ³ ExpC3 : Codigo curso                                       ³±±
±±³          ³ ExpC4 : Codigo turma                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr090CalRat(nOpcx, nRadio)
Local nx		:= 0
Local nz		:= 0
Local nw		:= 0
Local nd		:= 0
Local nTam		:= 0
Local nPosDesp	:= GdFieldPos("RAA_DESPES")
Local nPosData	:= GdFieldPos("RAA_DATA")
Local nPosValor	:= GdFieldPos("RAA_VALOR")
Local aColsAux	:= {}
Local aColsTot	:= {}
Local aColsDif	:= {}
Local lRet 		:= .T.
Local nFunc		:= Len(aLstCols)
Local nTotVal	:= 0
Local nTot
Local nDif

// Nao cria rateio pro funcionario se ja tiver valor lancado na mesma Desp/Data
dbSelectArea("RAA")
dbSetOrder(1)

aColsTot	:= Aclone(aCols)
aColsDif	:= Aclone(aCols)

Aeval(aCols, {|x| x[nPosValor] := NoRound( x[nPosValor] / nFunc , 2 ) })

For nd := 1 To Len(aCols)
	nTot := nFunc * aCols[nd][nPosValor]
	nDif := AcolsTot[nd][nPosValor] - nTot
	aColsDif[nd][nPosValor] :=  nDif
Next nd

// aCols de todos funcionarios
For nx := 1 To nFunc
	aColsAux	:= aClone(aLstCols[nx][POS_ACOLS])
	nTotVal		:= 0

	// aCols para ratear
	For nz := 1 To Len(aCols)
		If aCols[nz][nPosValor] > 0
			nPos:= Ascan(aColsAux,{|x| x[nPosDesp]+Dtoc(x[nPosData]) == aCols[nz][nPosDesp]+Dtoc(aCols[nz][nPosData]) })
			If nPos == 0
				If Empty(aColsAux[1][nPosDesp])
					For nw := 1 To Len(aCols[nz])
						aColsAux[1][nw]		:= aCols[nz][nw]
						aLstCols[nx][POS_ACOLS][1][nw]	:= aCols[nz][nw]
					Next nw
				Else
					Aadd(aColsAux, Aclone(aCols[nz]))
			    	Aadd(aLstCols[nx][POS_ACOLS], Aclone(aCols[nz]))
			 	EndIf
			Else	//Existe Valores

				If nRadio == 1		//"Substituir valores anteriores"
					aColsAux[nPos][nPosValor]					:= aCols[nz][nPosValor]
					aLstCols[nx][POS_ACOLS][nPos][nPosValor]	:= aCols[nz][nPosValor]
				ElseIf nRadio == 2	//"Acumular valores"
					aColsAux[nPos][nPosValor]					+= aCols[nz][nPosValor]
					aLstCols[nx][POS_ACOLS][nPos][nPosValor]	+= aCols[nz][nPosValor]
			    EndIf
   			EndIf
		EndIf

	Next nz

Next nx

// Acertar diferenca de Valores
If nFunc > 1
	nTam := Len(aColsDif)

	For nz := 1 To nTam
		nPos:= Ascan(aLstCols[nFunc][POS_ACOLS],{|x| x[nPosDesp]+Dtoc(x[nPosData]) == aColsDif[nz][nPosDesp]+Dtoc(aColsDif[nz][nPosData]) })

		If nPos > 0
			aLstCols[nFunc][POS_ACOLS][nPos][nPosValor] += aColsDif[nz][nPosValor]
		EndIf
	Next
EndIf

// Gravar valores
Tr090Grava(nOpcx)
Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr090Perg ³ Autor ³ Cristina Ogura        ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chamada dos parametros no arotina                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr090Perg()
Pergunte("TRM090",.T.)

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr090Troca³ Autor ³ Cristina Ogura        ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que troca o acols conforme a posicao do funcionario  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr090Troca(cFilialF, cMatric, cNome, nOpcx, l1Vez)


Local lOfuscaNom := .F.
Local aOfuscaCpo := {}
Local aOfusca	 := If(FindFunction('ChkOfusca'), ChkOfusca(), {.T. , .F.}) //[1] Acesso; [2]Ofusca
Local aFldRot 	 := {'RA_NOME'}
Local aFldOfusca := {}

If aOfusca[2]
	aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot ) // CAMPOS SEM ACESSO
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0 
		lOfuscaNom	:= FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
	ENDIF
EndIf

cSay	:= If(lOfuscaNom,Replicate('*',15),cNome)

If cUltFil <> cFilialF .or. cUltMat <> cMatric
	If Empty(cUltFil)
		cUltFil  := cFilialF
		cUltMat  := cMatric
	EndIf
	If !Empty(aCols)
		Tr090Transf()
	EndIf
	cUltFil  := cFilialF
	cUltMat  := cMatric
EndIf

aCols 	:= Tr090Obter(cFilialF, cMatric, nOpcx)

If !l1Vez
	oGet:ForceRefresh()
	oSay1:Refresh()
EndIf
Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr090Transf³ Autor ³ Leandro Drumond      ³ Data ³ 19.03.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que forca a manutencao dos dados digitados pelo      ³±±
±±³			 ³usuario na acols principal.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr090Transf()
Local nPos := 0

nPos := AScan(aLstCols,	{|x| x[POS_FILIAL] == cUltFil .AND. x[POS_MATRIC] == cUltMat})

If nPos = 0
	AAdd(aLstCols, {cUltFil, cUltMat, aCols})
Else
	aLstCols[nPos][POS_ACOLS] := aCols
EndIf

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr090Obter³ Autor ³ Rogerio Ribeiro       ³ Data ³ 03.01.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que localiza e retorna o aCols do funcionario		  ³±±
±±³			 ³indicado pelo parametro cMatric. Caso o aCols nao tenha sido³±±
±±³			 ³carregado, e feita a chamada para a funcao Tr090Fill.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr090Obter(cFilialF,  cMatric, nOpcx)
Local nPos := 0

nPos := AScan(aLstCols,	{|x| x[POS_FILIAL] == cFilialF .AND. x[POS_MATRIC] == cMatric})

If nPos = 0
	AAdd(aLstCols, {cFilialF, cMatric, Tr090Fill(cFilialF, cMatric, nOpcx)})

	nPos:= Len(aLstCols)
EndIf

Return aLstCols[nPos][POS_ACOLS]

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr090Fill ³ Autor ³ Rogerio Ribeiro       ³ Data ³ 03.01.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que faz a chamada da FillGetDados para um funcionario³±±
±±³			 ³especifico e retorna seu aCols.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr090Fill(cFilialF,  cMatric, nOpcx)
Local aTempCol

aHeader	:={}
aCols	:={}
FillGetDados(nOpcx,;
			 "RAA",;
			 1,;
			 cFilialF + cCalend + cCurso + cTurma + cMatric,;
			 {|| RAA->RAA_FILIAL + RAA->RAA_CALEND + RAA->RAA_CURSO + RAA->RAA_TURMA + RAA->RAA_MAT },;
			 NIL,;
			 {"RAA_FILIAL","RAA_MAT","RAA_CALEND","RAA_CURSO","RAA_TURMA"},;
			 NIL,;
			 NIL,;
			 NIL,;
			 NIL)

If len(aCols) == 1 .and. aCols[1][GDFieldPos("RAA_REC_WT")]== 0
	aCols[1][Len(aHeader)+1] := .T.
EndIf

aTempCol:= AClone(aCols)
aCols:= {}

Return aTempCol

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr090CriaArq³ Autor ³ Cristina Ogura      ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que controla a criacao do arquivo temporario         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 : Posicao nao marcada                                ³±±
±±³          ³ ExpN2 : Posicao nao marcada                                ³±±
±±³          ³ ExpN3 : Posicao marcada                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr090CriaArq()
Local a1Stru      := {}
Local cCond	      := ""
Local aLstIndices := {}
Local aLista      := {}

Aadd(a1Stru,{"TR1_FILIAL",   "C", FWGETTAMFILIAL,          0                       } )
Aadd(a1Stru,{"TR1_NOME",     "C", TamSx3("RA_NOME")[1],    TamSx3("RA_NOME")[2]    } )
Aadd(a1Stru,{"TR1_MAT",      "C", TamSx3("RA_MAT")[1],     TamSx3("RA_MAT")[2]     } )
Aadd(a1Stru,{"TR1_CC",       "C", TamSx3("RA_CC")[1],      TamSx3("RA_CC")[2]      } )
Aadd(a1Stru,{"TR1_DESCCC",   "C", TamSx3("CTT_DESC01")[1], TamSx3("CTT_DESC01")[2] } )
Aadd(a1Stru,{"TR1_FUNCAO",   "C", TamSx3("RA_CODFUNC")[1], TamSx3("RA_CODFUNC")[2] } )
Aadd(a1Stru,{"TR1_DESCFU",   "C", TamSx3("RJ_DESC")[1],    TamSx3("RJ_DESC")[2]    } )


//Ordem 1-Nome 2-Matricula 3-Centro Custo 4-Funcao
If MV_PAR01 == 1				// Nome
	aLista := {"TR1_FILIAL","TR1_NOME"}
ElseIf MV_PAR01 == 2			// Matricula
	aLista := {"TR1_FILIAL","TR1_MAT"}
ElseIf MV_PAR01 == 3			// Centro de Custo
	aLista := {"TR1_FILIAL","TR1_CC"}
ElseIf MV_PAR01 == 4			// Funcao
	aLista := {"TR1_FILIAL","TR1_FUNCAO"}
EndIf

AAdd( aLstIndices, aLista)

oTmpTR1 := RhCriaTrab("TR1", a1Stru, aLstIndices)


Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr090ColRat ³ Autor ³ Rogerio Ribeiro    ³ Data ³ 04.01.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria array com a matr e o acols de cada funcionario        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr090ColRat                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr090ColRat(nOpcx)
dbSelectArea("TR1")
dbGotop()

While !Eof()
	AAdd(aLstCols, {TR1->TR1_FILIAL, TR1->TR1_MAT, Tr090Fill(TR1->TR1_FILIAL, TR1->TR1_MAT, nOpcx)})
	dbSkip()
EndDo
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr090Ok    ³ Autor ³ Cristina Ogura      ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao executada na linha Ok da getdados                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr090Ok                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr090Ok()
Local nPosDesp	:= 0
Local nPosData	:= 0
Local nPosValor	:= 0
Local lRet		:= .T.
Local nx		:= 0
Local nUltimo:= Len(aCols)

nPosDesp := GdFieldPos("RAA_DESPES")
nPosData := GdFieldPos("RAA_DATA")
nPosValor:= GdFieldPos("RAA_VALOR")

If !aCols[nUltimo, Len(aCols[nUltimo])]
	If nPosDesp > 0 .And. Empty(aCols[nUltimo][nPosDesp])
		Help(" ",1,"TR090VAZIO")	// Verifica o codigo da despesa, Data ou Valor nÆo podem estar vazio
		lRet:= .F.
	ElseIf nPosData > 0 .And. Empty(aCols[nUltimo][nPosData])
		Help(" ",1,"TR090VAZIO")
		lRet:= .F.
	ElseIf nPosValor > 0 .And. Empty(aCols[nUltimo][nPosValor])
		Help(" ",1,"TR090VAZIO")
		lRet:= .F.
 	EndIf

	If lRet
		For nx:=1 To Len(aCols)
			IF aCols[nUltimo][nPosDesp] == aCols[nx][nPosDesp] .And.;
			   aCols[nUltimo][nPosData] == aCols[nx][nPosData] .And.;
			   !aCols[nx][Len(aCols[nx])] .And.;
			   nUltimo != nx
				Help(" ", 1, "TR090EXIS")		// Esta despesa ja foi lancada anteriormente.
				lRet:= .F.
				Exit
			EndIf
		Next nx
	EndIf
EndIf

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Garanto que o Ponteiro Estara no Final do Arquivo para que nao³
³Carregue Conteudo Invalido nos Inicializadores Padroes        ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
PutFileInEof( "RAA" )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr090Desp  ³ Autor ³ Cristina Ogura      ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a descricao da despesa para a getdados             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr090Desp                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TR090Desp()
Local cVar		:= &(ReadVar())
Local cDesc		:= ""
Local nPosDesc 	:= GdFieldPos("RAA_DESC")

dbSelectArea("SX5")
If dbSeek(xFilial("SX5")+"R8"+cVar)
	cDesc := X5DESCRI()
EndIf

aCols[n][nPosDesc] := cDesc
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr090Leg      ³ Autor ³Emerson Grassi    ³ Data ³ 05.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Aciona Legenda de cores da Mbrowse.				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr090Leg()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr090Leg()
TrmLegenda(2,,, aLegenda)
Return (Nil)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr090Dele ³ Autor ³ Emerson Grassi Rocha 	³ Data ³ 01/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Deleta todos os registros referente Despesas			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TRMA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr090Dele(cFilialF)

dbSelectArea("RAA")
dbSetOrder(1)
If dbSeek(cFilialF + cCalend + cCurso + cTurma )

	lChkDelOk  := ChkDelRegs(	"RAA"	,;	//01 -> Alias do Arquivo Principal
 					NIL					,;	//02 -> Registro do Arquivo Principal
  					NIL					,;	//03 -> Opcao para a AxDeleta
					NIL					,;	//04 -> Filial do Arquivo principal para Delecao
					NIL					,;	//05 -> Chave do Arquivo Principal para Delecao
					NIL					,;	//06 -> Array contendo informacoes dos arquivos a serem pesquisados
					NIL					,;	//07 -> Mensagem para MsgYesNo
					NIL					,;	//08 -> Titulo do Log de Delecao
					NIL					,;	//09 -> Mensagem para o corpo do Log
					NIL				 	,;	//10 -> Se executa AxDeleta
					NIL					,;	//11 -> Se deve Mostrar o Log
					NIL					,;	//12 -> Array com o Log de Exclusao
					NIL		 			,;	//13 -> Array com o Titulo do Log
					NIL					,;	//14 -> Bloco para Posicionamento no Arquivo
					NIL					,;	//15 -> Bloco para a Condicao While
					NIL					,;	//16 -> Bloco para Skip/Loop no While
					.T.					,;	//17 -> Verifica os Relacionamentos no SX9
					Nil				 	;	//18 -> Alias que nao deverao ser Verificados no SX9
			    )

	If !lChkDelOk
		Return Nil
	Endif

	While (RAA->RAA_FILIAL	= cFilialF)					.And.;
		  (RAA->RAA_CALEND	= cCalend) 					.And.;
		  (RAA->RAA_CURSO	= cCurso)					.And.;
		  (RAA->RAA_TURMA	= cTurma)					.And.;
		  (!Eof())

		RecLock("RAA",.F.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo
EndIf

Return .T.

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³22/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³TRMA090                                                     ³
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

Local aRotina := { 	{ STR0001,'PesqBrw'		, 0, 1,,.F.}, ;	//"Pesquisar"
					{ STR0019,'Tr090Rot'	, 0, 2}, ;			//"Visualizar"
					{ STR0003,'Tr090Rot'	, 0, 4}, ;			//"Incluir"
					{ STR0020,'Tr090Rot'	, 0, 4}, ;			//"Alterar"
					{ STR0021,'Tr090Rot'	, 0, 5}, ;			//"Excluir"
					{ STR0018,'Tr090Rat'	, 0, 3}, ;			//"Ratear Desp."
					{ STR0002,'Tr090Perg'	, 0, 3}, ; 			//"Para&metros"
					{ STR0017,'Tr090Leg'	, 0, 3, ,.F.} }	//"Legenda"
Return aRotina
