#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TRMA070.CH"
#INCLUDE "HEADERGD.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TRMA070  ³ Autor ³ Cristina Ogura        ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Baixa dos cursos                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TRMA070                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Program.  ³ Data   ³ BOPS ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia C.³21.07.14³TPZSOX³Incluido o fonte da 11 para a 12 e efetuada ³±±
±±³          ³        ³      ³a limpeza.                                  ³±±
±±³Renan B.  ³17.10.14³TQSOVA³Criação do ponto de entrada TRM070RD que per³±±
±±³          ³        ³      ³mite ordenar os funcionários inscritos no   ³±±
±±³          ³        ³      ³curso.                                      ³±±
±±³Gabriel A.³05.03.15³TRSOE4³Replica do chamado THOTQP (Visualização de  ³±±
±±³          ³        ³      ³treinamento já baixado)                     ³±±
±±³Cícero A  ³23.08.16³TVMDWJ³Ajuste em AlterHeader para não repetir os   ³±±
±±³          ³        ³      ³campos campos da RA4 quando visualiza trei- ³±±
±±³          ³        ³      ³namentos já baixados.						  ³±±
±±³Matheus M.³07.10.16³TWDZV5³Ajuste na exibição dos campos memo.		  ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³Marcelo F.³02.01.17³MRH-3583		³Acerto no ajuste do campo memo e na baixa 	 ³±±
±±³          ³        ³        		³de treinamentos. 							 ³±±
±±³Eduardo K.³14.03.17³MPRIMESP-9330³Realizado ajuste para considerar o conteúdo ³±±
±±³          ³        ³ 		    ³dos campos memo virtual no momento da baixa.³±±
±±³Oswaldo L ³25.05.17³DRHPONTP³Ajuste permitir editar campos em grid e          ³±±
±±³          ³        ³-750    ³ainda visualizar os campos memo                  ³±±
±±³Willian U.³14.06.17³DRHPONTP³Fonte alterado para gerar compilação com arquivo ³±±
±±³          ³        ³-437    ³.ch atualizado                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±±±±±±ÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TRMA070

// Define Variaveis
LOCAL cFiltra	:= ""					//Variavel para filtro
LOCAL aIndFil	:= {}					//Variavel Para Filtro
Local aCores    := {}
Local aAuxCor   := {}
Local _nX       := 0
Private bFiltraBrw 	:= {|| Nil}		//Variavel para Filtro
Private aLegenda	:={}
Private	aAC 		:= { STR0047, STR0048 }	//'Abandona'#'Confirma'
Private aCRA		:= { STR0048, STR0049, STR0047 }//'Confirma'#"Redigita"#'Abandona'#

Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

// Define o cabecalho da tela de atualizacoes
Private cCadastro := OemtoAnsi(STR0004)		//"Baixa dos Cursos"

// Inicializa o filtro utilizando a funcao FilBrowse
dbSelectArea("RA2")
dbSetOrder(1)

cFiltra 	:= CHKRH(FunName(),"RA2","1")
bFiltraBrw 	:= {|| FilBrowse("RA2",@aIndFil,@cFiltra) }
Eval(bFiltraBrw)

aAdd(aCores, {'RA2->RA2_REALIZ != "S"', "ENABLE"	  , ""}) //"Em Aberto"
aAdd(aCores, {'RA2->RA2_REALIZ == "S"' , "BR_VERMELHO", ""}) //"Encerrado"

// Definiao de cores por usuarios
If ExistBlock("TRM070LEG")
	aAuxCor := ExecBlock("TRM070LEG",.F.,.F.,{aCores} )
	If ValType(aAuxCor) == "A" .AnD. Len(aAuxCor) > 0
		aCores    := {}
		aLegenda  := {}
		For _nX := 1 To Len(aAuxCor)
			aAdd(aCores,   {aAuxCor[_nX,1], aAuxCor[_nX,2]})
			aAdd(aLegenda, {aAuxCor[_nX,2], If(Empty(aAuxCor[_nX,3]), "-", aAuxCor[_nX,3])})
		Next _nX
	Endif
Endif

// Endereca a funcao de BROWSE
dbSelectArea("RA2")
dbGoTop()

mBrowse(NIL, NIL, NIL, NIL, "RA2", NIL, NIL, NIL,,, aCores)

// Deleta o filtro utilizando a funcao FilBrowse
EndFilBrw("RA2",aIndFil)

dbSelectArea("RA2")
dbSetOrder(1)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr070Rot  ³ Autor ³ Cristina Ogura       ³ Data ³ 12.11.98 ³±±
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
Function Tr070Rot(cAlias,nReg,nOpcx)

Local oDlgMain, oGet
Local oGroup, oFont
Local nOpca		:= 0
Local cDescCurso:= ""
Local cDescEnt	:= ""
Local nCurso	:= 0
Local lTrDel	:= If(nOpcx=2, .F., .T.)
Local aAlter	:= {}
Local aRA3RA4HD := {}
Local aChave	:= {}
Local lEficacia	:= .F.
Local lQGint	:= FlQGint() //Integracao Quality
Local aButtons  := {}
Local nMat
Local nTurma
local cTab := ""
// Variaveis para Dimensionar Tela
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aEnchCoords	:= {}
Local aTopBar		:= {}
Local aGetDCoords	:= {}
// Variaveis para Walk Trhu
Local cSeekKey 		:= RA2->RA2_CALEND
Local bSeekWhile	:= {}
Local uSeekFor 		:= {}
Local aNoFields 	:= {}
Local bAfterHeader	:= {|aHeader| AlterHeader(aHeader, aRA3RA4HD,cTab) }
Local bCriaVar 		:= {|cField | CriaVar070(cField, .T., aHeader) }
Local nPosRec		:= 0
Local cArqRA3 		:= ""
Local cIndCond		:= ""
Local nIndex		:= 0
Local lTrmOrdCur		:= ExistBlock( "TRM070ORD" )
Local aCursoOrd
Local nOpcBkp

// Private da Getdados
Private aCols	:= {}
Private aHeader	:= {}

If RA2->RA2_REALIZ == "S" .AND. lTrDel
	Help("",1,"TRA070BAIX")			// Este curso ja foi baixado
	Return
EndIf

If (RA2->RA2_REALIZ == "S") .AND. !lTrDel
	cTab :="RA4"
Else
	cTab :="RA3"
EndIf

bSeekWhile	:= {||&(cTab+"->"+cTab+"_CALEND")}
uSeekFor 		:= {||&(cTab+"->"+cTab+"_CURSO") == RA2->RA2_CURSO .and. &(cTab+"->"+cTab+"_TURMA") == RA2->RA2_TURMA}
aNoFields 	:= {cTab+"_FILIAL",cTab+"_CURSO",cTab+"_DESC",cTab+"_DATA",;
					cTab+"_NVEZAD",cTab+"_SEQ",cTab+"_EMAIL",cTab+"_DTAVIS"}
If cTab == "RA4"
	Aadd(aNoFields, "RA4_DESCCU")
	Aadd(aNoFields, "RA4_ENTIDA")
	Aadd(aNoFields, "RA4_DESCEN")
	Aadd(aNoFields, "RA4_CODCOM")
EndIf

// Chave do RA2
aChave := {RA2->RA2_FILIAL,RA2->RA2_CALEND,RA2->RA2_CURSO,RA2->RA2_TURMA,RA2->RA2_ENTIDA}

//Este ajuste visa corrigir duas situações: permitir visualizar o conteudo dos campos do tipo Memo e permitir a edição de algumas colunas, tal como %
//deixar que as funcoes FillGetdados a seguir sejam executadas com nOpcx=4, caso contrário elas não carregam o conteúdo do campo Memo na memória
//após passar por estas funções, dentro do DIALOG, antes de criar o browse mudamos o nOpcx para 3 (desta forma o browse habilita a edicao dae algumas colunas,tais como %Presenca
nOpcBkp := nOpcx
nOpcx := Iif(nOpcx == 3, 4, nOpcx)

// Verifica os campos que podem ser alterados
Tr070Alter(@aAlter, aRA3RA4HD,nOpcx)
// Ordenacao dos Registros por Indice Temporario: Matricula
dbSelectArea(cTab)
dbSetOrder(2)
dbGoTop()
cIndCond	:= cTab + "_CALEND+" + cTab + "_FILIAL+" + cTab + "_MAT"

cArqRA3  := CriaTrab(NIL,.F.)
IndRegua(cTab,cArqRA3,cIndCond)
nIndex := RetIndex(cTab)

// Monta as getdados dos arquivos
FillGetDados(nOpcx					,; //1-nOpcx - número correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
			 cTab					,; //2-cAlias - area a ser utilizada;
			 nIndex+1	   			,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
			 cSeekKey  				,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
		 	 bSeekWhile				,; //5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
			 uSeekFor 				,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-código, condição a ser utilizado para executar o Loop no While;2º - array bi-dimensional contendo N.. condições, em que o 1º elemento é o bloco condicional, o 2º é bloco a ser executado se verdadeiro e o 3º é bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
			 aNoFields				,; //7-aNoFields - array contendo os campos que não estarão no aHeader;
			 NIL					,; //8-aYesFields - array contendo somente os campos que estarão no aHeader;
			 NIL					,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usuário;
			 NIL					,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
			 NIL	 				,; //11-bMontCols - bloco contendo função especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}
			 Nil 			  		,; //12-lEmpty       - Caso True ( default é false ), inicializa o aCols com somente uma linha em branco ( como exemplo na inclusão).
			 NIL					,; //13-aHeaderAux   - Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )
			 NIL					,; //14-aColsAux     - Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )
			 NIL					,; //15-bAfterAcols  - Bloco de código a ser executado após a inclusão de uma linha no Acols
			 NIL					,; //16-bBeforeCols  - bloco de código contendo expressão para sair do While, é executado antes de inserir nova linha no aCols
			 bAfterHeader			,; //17-bAfterHeader - bloco de código a ser executado após o preenchimento do aheader com os campos padrão e antes de incluir os campos reservados para o WalkThru. Ex: {|aHeader| AlterHeader(aHeader) }
			 NIL					,; //18-cAliasQry    - Informe o nome do alias a ser usado na área aberta por cQuery, opcionalmente.
			 bCriaVar				)  //19-bCriaVar     - Bloco que será utilizado na hora de recuperar o valor do campo no loop de preenchimento do aCols. Formato: {| cField | CriaVarRh( cField ) }

// Verificacao se Acols esta real// vazio
nPosRec := GdFieldPos(cTab + "_REC_WT")

If Len(aCols) <= 1 .And. acols[1][nPosRec] = 0
	Help("",1,"TRA070VAZI")
	Return Nil
EndIf

// Encontra a Descricao do Curso
cDescCurso	:=	TrmDesc("RA1",RA2->RA2_CURSO,"RA1->RA1_DESC")

// Encontra a Descricao da Entidade
cDescEnt	:= TrmDesc("RA0",RA2->RA2_ENTIDA,"RA0->RA0_DESC")

// Calcula o valor por matricula
nCurso := If(RA2->RA2_RESERV!=0,Round(RA2->RA2_CUSTO/RA2->RA2_RESERV,2),0)

If lTrmOrdCur
	If(Valtype(aCursoOrd := ExecBlock( "TRM070ORD", .F.,.F.,{aClone(aCols)} )) == "A")
		aCols := aClone(aCursoOrd)
	EndIf
EndIf

// Monta as Dimensoes dos Objetos
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= {aAdvSize[1], aAdvSize[2], aAdvSize[3], aAdvSize[4], 5, 5}
aAdd(aObjCoords , {0, 0, .T., .T.} )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

//aEnchCoords	:= { (aObjSize[1,1]), (aObjSize[1,2])	, (aObjSize[1,1]+45), (aObjSize[1,4]-5) }

aTopBar		:= {	{ (aObjSize[1,1]),		(aObjSize[1,2]), 		(aObjSize[1,1]+25),		(aObjSize[1,4]*0.5)		,	},;
					{ (aObjSize[1,1]),		(aObjSize[1,4]*0.5+5), (aObjSize[1,1]+25),	(aObjSize[1,4])			,	},;
					{ (aObjSize[1,1]+30),	(aObjSize[1,2]),		(aObjSize[1,1]+55),		(aObjSize[1,4]*0.5)		,	},;
					{ (aObjSize[1,1]+30),	(aObjSize[1,4]*0.5+5),	(aObjSize[1,1]+55),		(aObjSize[1,4]*0.75)	,	},;
					{ (aObjSize[1,1]+30),	(aObjSize[1,4]*0.75+5),(aObjSize[1,1]+55),	(aObjSize[1,4])			,	}	}

aGdCoord	:= { (aObjSize[1,1]+60), (aObjSize[1,2]), (aObjSize[1,3]), (aObjSize[1,4]) }

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
nOpcx := nOpcBkp
DEFINE MSDIALOG oDlgMain FROM	aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cCadastro OF oMainWnd  PIXEL
	@ (aTopBar[1,1]), 		aTopBar[1,2] GROUP oGroup TO aTopBar[1,3], aTopBar[1,4] PROMPT OemToAnsi(STR0005) OF oDlgMain PIXEL
	@ (aTopBar[1,1]+10),	aTopBar[1,2]+10 SAY (RA2->RA2_CALEND + " - " + RA2->RA2_DESC) SIZE (aTopBar[1,4]-aTopBar[1,2]-20), 8 PIXEL		//"Calendario: "
	oGroup:oFont:= oFont

	@ (aTopBar[2,1]), 		(aTopBar[2,2]) GROUP oGroup TO (aTopBar[2,3]), (aTopBar[2,4]) PROMPT OemToAnsi(STR0009) OF oDlgMain PIXEL
	@ (aTopBar[2,1]+10),	(aTopBar[2,2]+10) SAY (RA2->RA2_ENTIDA + " - " + cDescEnt) SIZE (aTopBar[2,4]-aTopBar[2,2]-20), 8 PIXEL		//"Calendario: "
	oGroup:oFont:= oFont

	@ (aTopBar[3,1]), 		(aTopBar[3,2]) GROUP oGroup TO (aTopBar[3,3]), (aTopBar[3,4]) PROMPT OemToAnsi(STR0006) OF oDlgMain PIXEL
	@ (aTopBar[3,1]+10),	(aTopBar[3,2]+10) SAY (RA2->RA2_CURSO   + " - " + cDescCurso) SIZE (aTopBar[3,4]-aTopBar[3,2]-20), 8 PIXEL		//"Calendario: "
	oGroup:oFont:= oFont

	@ (aTopBar[4,1]),		(aTopBar[4,2]) GROUP oGroup TO (aTopBar[4,3]), (aTopBar[4,4]) PROMPT OemToAnsi(STR0007) OF oDlgMain PIXEL
	@ (aTopBar[4,1]+10),	(aTopBar[4,2]+10) SAY (RA2->RA2_TURMA) SIZE (aTopBar[4,4]-aTopBar[4,2]-20), 8 PIXEL		//"Calendario: "
	oGroup:oFont:= oFont

	@ (aTopBar[5,1]), (aTopBar[5,2]) GROUP oGroup TO (aTopBar[5,3]), (aTopBar[5,4]) PROMPT OemToAnsi(STR0008) OF oDlgMain PIXEL
	@ (aTopBar[5,1]+10),	(aTopBar[5,2]+10) SAY AllTrim(Str(RA2->RA2_VAGAS)) SIZE (aTopBar[5,4]-aTopBar[5,2]-20), 8 PIXEL		//"Calendario: "
	oGroup:oFont:= oFont

	oGet:= MSGetDados():New(aGdCoord[1],aGdCoord[2],aGdCoord[3],aGdCoord[4],nOpcx,"AllwaysTrue()","AllwaysTrue()","",lTrDel,aAlter, , ,900 ,,,,,oDlgMain)
	oGet:nMax := Len(aCols)	//Nao permite inclusao de novas linhas na oGet

	// Integracao como o SIGAQDO - Quality
	If lQGint
        nTurma  := GdFieldPos("RA3_TURMA" ,aHeader) //RA3_TURMA
        nMat    := GdFieldPos("RA3_MAT"   ,aHeader) //RA3_MAT
       	nData   := GdFieldPos("RA3_DATAIN",aHeader) //RA3_DATAIN

		aAdd(aButtons,{"RELATORIO" , {|| Tr070VzDc( RA2->RA2_CALEND,RA2->RA2_CURSO,ACols[n][nTurma],ACols[n][nMat],aCols[n][nData] ) }, OemToAnsi(STR0022 ),OemToAnsi(STR0023) } ) //"Documentos"###"Doc."
	Endif

ACTIVATE MSDIALOG oDlgMain ON INIT (EnchoiceBar(oDlgMain,{||nOpca:=1,If(Tr070TudOk(nOpcx),oDlgMain:End(),) },{|| nOpca := 2,oDlgMain:End()},,aButtons))

If nOpca == 1
	If nOpcx != 2	// Se nao for visualizacao

		If MsgYesNo(OemtoAnsi(STR0021),OemtoAnsi(STR0019))	//'Deseja Gerar dados para Avaliacao de Eficacia deste Treinamento?'###"Atencao"
			lEficacia := .T.
		EndIf

		Begin Transaction
			Tr070Grava(cAlias,nReg,nOpcx,aChave,lEficacia)

			IF lQGint
				Tr070GDoc(Aclone(aCols),Aclone(aHeader),aChave[3])
			Endif
			EvalTrigger()
		End Transaction
	EndIf
EndIf

dbSelectArea("RA2")
dbGoto(nReg)

dbSelectArea("RA3")
Set Filter To
RetIndex("RA3")
dbSetOrder(1)
FErase (cArqRA3+OrdBagExt())

Return(Nil)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr070Grava³ Autor ³ Cristina Ogura        ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os registros referente ao treinamentos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±³          ³ ExpA1 : Chave de busca                                     ³±±
±±³          ³ ExpL1 : Eficacia : .T. = Gera Eficacia                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA070                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr070Grava(cAlias, nReg, nOpcx, aChave, lEficacia)

	Local aSaveArea		:= GetArea()
	Local nPosData		:= 0
	Local nPosMat		:= 0
	Local nPosFil 		:= 0
	Local nPosCalend	:= 0
	Local nPosTurma		:= 0
	Local nPosSitu 		:= 0
	Local lRet			:= .T.
	Local nx			:= 0
	Local ny			:= 0
	Local lGrava		:= .T.
	Local nPosRec		:= GdFieldPos("RA3_REC_WT")
	Local lBaixa		:= .T.
	Local lQGint		:= FlQGint() //Integracao Quality
	Local lExistEfi		:= ExistBlock("TRM070EFI")
	Local lEmail		:= .F.
	Local lMvTrMmail	:= SuperGetMV("MV_TRMMAIL")
	Local aFuncAtu		:= {}
	Local leSocCur		:= .F.

	Private cObs1		:= ""
	Private cObs2		:= ""
	Private cObs3		:= ""
	Private cObs4		:= ""
	Private cObs5		:= ""
	Private cObs6		:= ""
	// Altera alias dos campos do aHeader para realizar gravacao na tabela RA4 e modifica campos virtuais
	For nx:= 1 to Len(aHeader)
		aHeader[nx][2] :=StrTran(aHeader[nx][2],"RA3", "RA4")
		If aHeader[nx][2]<> "RA4_NOME"  .and. aHeader[nx][2]<> "RA4_DESCSI" ;
		.and. aHeader[nx][2]<> "RA4_RESERV"  .and. aHeader[nx][2]<> "RA4_DESPES" ;
		.and. aHeader[nx][2]<> "RA4_XXAVAL" .and. aHeader[nx][2]<> "RA4_FILAUX"
			aHeader[nx][10]:= ""
		EndIf
	Next nx

	// Incluir no RA5 - Cursos do funcionario
	nPosMat		:= GdFieldPos("RA4_MAT")
	nPosData	:= GdFieldPos("RA4_DATAIN")
	nPosFil		:= GdFieldPos("RA4_FILAUX")
	nPosCalend	:= GdFieldPos("RA4_CALEND")
	nPosTurma	:= GdFieldPos("RA4_TURMA")
	nPosSitu 	:= GdFieldPos("RA4_RESERV")

	// Ponto de Entrada Antes da Gravacao da Baixa de Treinamento
	// Este ponto de Entrada sera executado antes da gravacao da baixa
	// de Treinamento na Pasta Cursos do Funcionario
	If ExistBlock("TRM070AG")
		lGrava := ExecBlock("TRM070AG", .F., .F.)
		lGrava := If (ValType(lGrava) == "L", lGrava, .T.)
	EndIF

	If lGrava
		dbSelectArea("RA4")
		dbSetOrder(3)

		dbSelectArea("RAO")
		dbSetOrder(1)

		IF !RAO->(DBSEEK(xFilial("RAO")+RA4->(RA4_CALEND+RA4_CURSO+RA4_TURMA+RA4_MAT+DTOS(RA4_VALIDA))+RAN->RAN_DOCTO))
			cDocRev:=QA_ULTRVDC(RAN->RAN_DOCTO,,.F.,.T.)
			If empty(cDocRev) .AND. lQGint == .T.
				lBaixa:= MsgYesNo( OemToAnsi( STR0050 )  , OemToAnsi( STR0019 ) )

				If !lBaixa
					Return .F.
				Endif
			Endif
		Endif

		If lMvTrMmail
			lEmail := MsgYesNo(OemtoAnsi(STR0054),OemtoAnsi(STR0019))	//'Deseja enviar e-mail informativo de conclusao do curso?'###"Atencao"
		Endif

		For nx:= 1 To Len(aCols)
					lRet := .T.
				//--Verifica se Nao esta Deletado no aCols
				If !aCols[nx][Len(aCols[nx])] .And. aCols[nx][nPosSitu] == "R"
					If lBaixa
						If RA4->(dbSeek(aCols[nx][nPosFil]+aCols[nx][nPosCalend]+aChave[3]+aCols[nx][nPosTurma]+aCols[nx][nPosMat]))
							While !Eof() .And. aCols[nx][nPosFil]+aCols[nx][nPosCalend]+aChave[3]+aCols[nx][nPosTurma]+aCols[nx][nPosMat]==;
												RA4->RA4_FILIAL + RA4->RA4_CALEND + RA4->RA4_CURSO + RA4->RA4_TURMA + RA4->RA4_MAT

								If 	RA4->RA4_DATAIN == aCols[nx][nPosData]
									RecLock("RA4",.F.,.F.)
										For ny := 1 To Len(aHeader)
											If aHeader[nY][10] <> "V"
												RA4->(FieldPut(FieldPos(aHeader[nY][2]),IIF(aHeader[nY][8] == "C" .and. Empty(aCols[nX][nY]), space(aHeader[nY][4]), aCols[nX][nY])))
											EndIf
										Next ny
									MsUnlock()
									lRet := .F.
									Exit
								EndIf
								dbSkip()
							EndDo
						EndIf

						If lRet
							RecLock("RA4",.T.,.T.)
								Replace RA4_FILIAL WITH aCols[nx][nPosFil]
								Replace RA4_CURSO  WITH aChave[3]
								Replace RA4_ENTIDA WITH aChave[5]
								Replace RA4_CATCUR WITH Posicione("RA1",1,xFilial("RA1")+aChave[3],"RA1_CATEG")
								For ny := 1 To Len(aHeader)
									If aHeader[ny][10] <> "V"
										RA4->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
									EndIf
								Next ny
							MsUnlock()

							//verifica se tem checklist ativado e o atualiza
							If lEmail
								Tr060Email(RA4->RA4_FILIAL,RA4->RA4_MAT,RA4->RA4_CALEND,RA4->RA4_CURSO,RA4->RA4_TURMA,"",STR0053,.F.,"3")//"Curso Concluido"
							EndIf
						EndIf
						aAdd(aFuncAtu,{aCols[nx][nPosFil],aCols[nx][nPosMat]})
						If lRet
							fSendDadosApi("RA4", RA4->RA4_FILIAL, RA4->RA4_MAT, RA4->RA4_CALEND, RA4->RA4_CURSO, RA4->RA4_TURMA, "I")
						Endif
					Endif

					// Ponto de Entrada Apos Gravacao do Curso de Cada funcionario
					// Este ponto de Entrada sera executado apos a gravacao do Curso
					// para cada Funcionario baixado.
					IF ExistBlock("TRM070DG")
						RecLock("RA4",.F.)
							ExecBlock("TRM070DG",.F.,.F.)
						RA4->( MsUnlock() )
					EndIF

					// Criar Avaliacao de Eficacia
					If lEficacia
						dbSelectArea("RAK")
						dbSetOrder(1)
						RecLock("RAK",.T.)
							Replace RAK_FILIAL	WITH aCols[nx][nPosFil]
							Replace RAK_MAT		WITH aCols[nx][nPosMat]
							Replace RAK_CURSO	WITH aChave[3]
							Replace RAK_TURMA	WITH aCols[nx][nPosTurma]
							Replace RAK_CALEND	WITH aCols[nx][nPosCalend]
						MsUnlock()

						If ( lExistEfi )
							RecLock("RAK" , .F.)
							ExecBlock("TRM070EFI" , .F. , .F.)
							RAK->(MsUnlock())
						Endif
					Endif
				EndIf

				// Deletar do RA3 os Funcionarios Baixados / Limpa Calend/Turma de "L" ou "S"
				dbSelectArea("RA3")
				dbSetOrder(1)
				dbGoTo(aCols[nx][nPosRec])
				RecLock("RA3",.F.)
					If aCols[nx][nPosSitu] == "R" .Or. aCols[nx][Len(aCols[nx])]
						dbDelete()
					Else
						Replace RA3->RA3_CALEND	WITH Space(4)
						Replace RA3->RA3_TURMA	WITH Space(3)
						Replace RA3->RA3_RESERV	WITH aCols[nx][nPosSitu]
					EndIf
				MsUnlock()
		Next nx

		dbSelectArea("RA4")
		dbSetOrder(1)

		dbSelectArea("RA2")
		dbSetOrder(2)
		If dbSeek(xFilial("RA2") + aChave[3] + aChave[4])
			While !Eof() .And. xFilial("RA2") + aChave[3] + aChave[4] == RA2->RA2_FILIAL + RA2->RA2_CURSO + RA2->RA2_TURMA

				If RA2->RA2_CALEND == aChave[2]
					RecLock("RA2", .F., .F.)
						Replace RA2->RA2_REALIZ WITH "S"		// Altera o Status para Realizado
						If lEficacia
							Replace RA2->RA2_EFICAC	WITH "S"	// Altera o Status para Avaliar Eficacia
						EndIf
					MsUnlock()
					leSocCur := !Empty(RA2->RA2_ESOC)
				EndIf
				dbSkip()
			EndDo
		EndIf

		If FindFunction("fIntBxTrm") .And. leSocCur .And. Len(aFuncAtu) > 0 //Integrar eSocial
			fIntBxTrm(aFuncAtu)
		EndIf

	EndIf

	RestArea(aSaveArea)

Return lGrava

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr070Alter ³ Autor ³ Cristina Ogura      ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica os campos que podem ser alterados na getdados     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr070Alter                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aAlter : Array com os campos                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr070Alter(aAlter,aRA3RA4HD,nOpcx)
Local aSaveArea := GetArea()
Local aRA4Header:= {}
Local bSeekWhile:= {||Nil }
Local cChave	:= "!!"
Local nX		:= 0
Local aRA3HEader:= aClone(aHeader)
Local aRA3Cols	:= aClone(aCols)


aRA3RA4HD := {}

Aadd(aAlter,"RA3_VALIDA")
Aadd(aAlter,"RA3_NOTA  ")
Aadd(aAlter,"RA3_DURACA")
Aadd(aAlter,"RA3_UNDURA")
Aadd(aAlter,"RA3_PRESEN")
Aadd(aAlter,"RA3_DATAIN")
Aadd(aAlter,"RA3_DATAFI")
Aadd(aAlter,"RA3_VALOR ")
Aadd(aAlter,"RA3_HORAS ")
Aadd(aAlter,"RA3_RESERV")
Aadd(aAlter,"RA3_CONTEU")
Aadd(aAlter,"RA3_MEMINT")

dbSelectArea("SX3")

dbSeek("RA3")
While !Eof() .And. (X3_ARQUIVO == "RA3")
	If X3_PROPRI == "U"  .AND. ;
	   Empty( Ascan( aAlter,{|x| alltrim( Upper(X3_CAMPO) ) == Alltrim( Upper( x ) )  } ) )
	   Aadd(aAlter,X3_CAMPO)
	EndIf
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem campos de usuario da tabela RA4 que deverao estar disponiveis  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

bSeekWhile	:= {||RA4->RA4_FILIAL }
cChave	:= "!!"

//==> Cria aHeader e aCols para WalkThru
FillGetDados(nOpcx					,; //1-nOpcx - número correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
			 "RA4"					,; //2-cAlias - area a ser utilizada;
			 1						,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
			 cChave					,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
			 bSeekWhile				,; //5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
			 NIL					,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-código, condição a ser utilizado para executar o Loop no While;2º - array bi-dimensional contendo N.. condições, em que o 1º elemento é o bloco condicional, o 2º é bloco a ser executado se verdadeiro e o 3º é bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
			 {}						,; //7-aNoFields - array contendo os campos que não estarão no aHeader;
			 NIL					,; //8-aYesFields - array contendo somente os campos que estarão no aHeader;
			 .T.					,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usuário;
			 NIL					,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
			 NIL					,; //11-bMontCols - bloco contendo função especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}
			 NIL					,; //12-lEmpty – Caso True ( default é false ), inicializa o aCols com somente uma linha em branco ( como exemplo na inclusão).
			 aRA4Header				,; //13-aHeaderAux, eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )
			 NIL					)  //14-aColsAux eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )


For nX:= 1 To Len(aRA4Header)
	IF  Empty( Ascan( aAlter,{|x| alltrim( Upper(aRA4Header[nX, 2]) ) == Alltrim( Upper( x ) )  } ) ) .and.;
	    !(alltrim( Upper(aRA4Header[nX, 2]) ) $ "RA4_FILIAL/RA4_ALI_WT/RA4_REC_WT" )
	    If RA3->(Columnpos(StrTran(aRA4Header[nx][2],"RA4", "RA3"))) > 0
	        aRA4Header[nx][2] :=StrTran(aRA4Header[nx][2],"RA4", "RA3")
		    Aadd(aAlter,aRA4Header[nX,2])
		    Aadd(aRA3RA4HD,aRA4Header[nX])
		EndIf
	Endif

Next nX

RestArea(aSaveArea)

aHeader	:= aClone(aRA3Header)
aCols	:= aClone(aRA3Cols)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr070Leg      ³ Autor ³Emerson Grassi    ³ Data ³ 05.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Aciona Legenda de cores da Mbrowse.				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr070Leg()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr070Leg()

TrmLegenda(2,,, aLegenda)

Return(Nil)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr070TudOk³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 17/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao executada no Ok da enchoicebar                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tr070TudOk(nExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TRMA070                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr070TudOk(nOpcx)

Local nPosSitu 	:= GdFieldPos("RA4_XXXXXX")
Local nx		:= 0

If nOpcx != 2
	For nx := 1 to Len(Acols)
		If !aCols[nx,Len(aCols[nx])]  // Se nao esta Deletado
			If (nPosSitu > 0 .And. aCols[nx][nPosSitu] != "R")
				If !MsgYesNo(OemtoAnsi(STR0018),OemtoAnsi(STR0019))	//'Existem funcionarios com Situacao "L" ou "S". Deseja mante-los nesta situacao para proximos cursos?'###"Atencao"
					Aviso(STR0019, STR0020, {"Ok"})					//"Atencao"###'Altere a Situacao para "R" ou delete a linha caso nao tenha realizado o curso.'
				   	Return .F.
				 EndIf
			EndIf
		EndIf
	Next nx
EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr070VzDc     ³ Autor ³Telso Carneiro    ³ Data ³ 12/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela para Visualizacao dos Docs-Rv				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr070VzDc()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Tr070VzDc(cCalend,cCurso,cTurma,cMat,dData,lFuncio)

Local oDlgP
Local oGetPro
Local nUsado  := 0
Local lInit
Local cDocRev := Space( GetSX3Cache("RAO_DOCTO","X3_TAMANHO") )
Local aHeaPro := {}
Local aColPro := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Dimensionar Tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Default lFuncio := .F.
Default cCalend := CriaVar070("RA4_CALEND")

DbSelectArea("QDH")
DbSetOrder(RetOrdem( "QDH", "QDH_FILIAL+QDH_DOCTO+QDH_RV"))

DbSelectArea("RAO")
DbSetOrder(1)
IF Len(aHeaPro)==0
	aHeaPro :=aClone(APBuildHeader("RAO"))
ENDIF
RegToMemory("RAO")

IF RAO->(DBSEEK(xFilial("RAO")+cCalend+cCurso+cTurma+cMat+DTOS(dData)))
	While RAO->(!EOF()) .AND. RAO->(RAO_CALEND+RAO_CURSO+RAO_TURMA+RAO_MAT+DTOS(RAO_DATAIN))== cCalend+cCurso+cTurma+cMat+DtoS(dData)
		AADD(aColpro,ARRAY(Len(aHeaPro)+1))
		aColPro[Len(aColPro),Ascan(aHeaPro,{|x|AllTrim(x[2]) == "RAO_DOCTO"})] :=RAO->RAO_DOCTO
		aColPro[Len(aColPro),Ascan(aHeaPro,{|x|AllTrim(x[2]) == "RAO_RV"})]    :=RAO->RAO_RV

		//Retorna a revisao do documento liberado para leitura
		cDocRev := QA_UltRvDc(RAO->RAO_DOCTO,,.F.,.F.)

		//QDH->(DBSEEK(xFilial("QDH")+RAO->RAO_DOCTO+INVERTE(RAO->RAO_RV)))
		QDH->(DBSEEK(xFilial("QDH")+RAO->RAO_DOCTO+cDocRev))

		aColPro[Len(aColPro),Ascan(aHeaPro,{|x|AllTrim(x[2]) == "RAO_TITULO"})]:=QDH->QDH_TITULO
		aColPro[len(aColPro),Len(aHeaPro)+1]:=.F.
		RAO->(DbSkip())
	Enddo
ELSE
	IF lFuncio
	    msgAlert(STR0024+CHR(13)+STR0025+cCalend+STR0026+cCurso) //"Nao Ha Documentos Cadastrados neste"###" Calendario: "###" Curso: "
	    Return(NIL)
	Else
		IF RAN->(DBSEEK(xFilial("RAN")+cCurso))
			While RAN->(!EOF()) .AND. cCurso == RAN->RAN_CURSO
				AADD(aColpro,ARRAY(Len(aHeaPro)+1))
				aColPro[Len(aColPro),Ascan(aHeaPro,{|x|AllTrim(x[2]) == "RAO_DOCTO"})] :=RAN->RAN_DOCTO
				QDH->(DBSEEK(xFilial("QDH")+RAN->RAN_DOCTO))
				//Retorna a revisao do documento liberado para leitura
				cDocRev := QA_UltRvDc(RAN->RAN_DOCTO,,.F.,.F.)

				//QDH->(DBSEEK(xFilial("QDH")+RAN->RAN_DOCTO))
				QDH->(DBSEEK(xFilial("QDH")+RAN->RAN_DOCTO+cDocRev))

				aColPro[Len(aColPro),Ascan(aHeaPro,{|x|AllTrim(x[2]) == "RAO_RV"})]    :=QDH->QDH_RV
				aColPro[Len(aColPro),Ascan(aHeaPro,{|x|AllTrim(x[2]) == "RAO_TITULO"})]:=QDH->QDH_TITULO
				aColPro[len(aColPro),Len(aHeaPro)+1]:=.F.
				RAN->(DbSkip())
			Enddo
		ENDIF
	Endif
ENDIF

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize(,.T.,380)
aInfoAdvSize	:= {aAdvSize[1], aAdvSize[2], aAdvSize[3], aAdvSize[4], 5, 5}
aAdd(aObjCoords , { 000, 000 , .T., .T.} )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

If !Empty(cDocRev)
	DEFINE MSDIALOG oDlgP TITLE OemToAnsi(STR0022) FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] // 9,0 TO 25,85  //"Documentos"

	oGetPro := MsNewGetDados():New(aObjSize[1,1],aObjSize[1,2],aObjSize[1,3],aObjSize[1,4],,"AllwaysTrue()","AllwaysTrue()",,,,99,,,,oDlgP,aHeaPro,aColPro)

	ACTIVATE MSDIALOG oDlgP ON INIT EnchoiceBar(oDlgP,{|| oDlgP:End()},{|| oDlgP:End()}) CENTERED
Else
	MsgAlert( oemToAnsi(STR0051) )
Endif
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr070GDoc     ³ Autor ³Telso Carneiro    ³ Data ³ 12/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava os registros referentes a Documentos (Docs-Rv)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr070GDoc(arraydados,arraycabecalho)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Tr070GDoc(aColCr,aHedCr,cCurso)

Local aReaCur	:= GetArea()
Local nPosMat	:= GdFieldPos("RA4_MAT"   ,aHedCr)
Local nPosFil	:= GdFieldPos("RA4_FILAUX",aHedCr)
Local nPosCalend:= GdFieldPos("RA4_CALEND",aHedCr)
Local nPosTurma	:= GdFieldPos("RA4_TURMA" ,aHedCr)
Local nPosSitu 	:= GdFieldPos("RA4_RESERV",aHedCr)
Local nx
Local cDocRev




RAN->(DbSetOrder(1))

For nx:= 1 To Len(aColCr)

	//--Verifica se Nao esta Deletado no aCols
	If !aColCr[nx][Len(aColCr[nx])] .And. aColCr[nx][nPosSitu] == "R"

		dbSelectArea("RA4")
		dbSetOrder(3)

		If DBSEEK(aColCr[nx][nPosFil]+aColCr[nx][nPosCalend]+cCurso+aColCr[nx][nPosTurma]+aColCr[nx][nPosMat])
			While RA4->(!Eof()) .And. aColCr[nx][nPosFil]+aColCr[nx][nPosCalend]+cCurso+aColCr[nx][nPosTurma]+aColCr[nx][nPosMat]==;
				RA4->RA4_FILIAL + RA4->RA4_CALEND + RA4->RA4_CURSO + RA4->RA4_TURMA + RA4->RA4_MAT

				IF RAN->(DBSEEK(xFilial("RAN")+RA4->RA4_CURSO))
					DbSelectARea("RAO")
					DbSetOrder(1)
					While RAN->(!EOF()) .AND. RA4->RA4_CURSO == RAN->RAN_CURSO
						IF !RAO->(DBSEEK(xFilial("RAO")+RA4->(RA4_CALEND+RA4_CURSO+RA4_TURMA+RA4_MAT+DTOS(RA4_VALIDA))+RAN->RAN_DOCTO))
						    cDocRev:=QA_ULTRVDC(RAN->RAN_DOCTO,,,.T.)
							RecLock("RAO",.T.)
							RAO->RAO_FILIAL := xFilial("RAO")
							RAO->RAO_CALEND := RA4->RA4_CALEND
							RAO->RAO_CURSO  := RA4->RA4_CURSO
							RAO->RAO_TURMA	:= RA4->RA4_TURMA
							RAO->RAO_MAT	:= RA4->RA4_MAT
							RAO->RAO_VALIDA := RA4->RA4_VALIDA
							RAO->RAO_DOCTO	:= RAN->RAN_DOCTO
							RAO->RAO_RV		:= cDocRev
							MsUnlock()
						Endif
						RAN->(DbSkip())
					Enddo
				Endif
				dbSelectArea("RA4")
				RA4->(DbSkip())
			Enddo
		Endif
	Endif
Next

Restarea(aReaCur)

Return(NIL)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FlQGInt	 ³ Autor ³ Telso Carneiro		³ Data ³ 13/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Integracao TRM com todos os Modulos do Quality	  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function FlQGint()
Local lRet	:=.F.
Local aArea	:=GetARea()

IF GETMV("MV_QGINT")=="S" .AND. ChkFile('RAN') .AND. ChkFile('RAO')
	lRet:=.T.
Endif

RestArea(aArea)

Return( lRet )




/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AlterHeader³ Autor ³ Joeudo Santanta      ³ Data ³ 14.02.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Adiciona Campos ao Aheader                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AlterHeader(ExpA1)				  	 		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = aHeader											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TRMA070  											  	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AlterHeader(aHeaderAux, aRA3RA4HD, cTab)

	Local nX			:= 0
	Local aTempHeader	:= {}
	Local cCpo			:= ""

	aTempHeader := aClone(aHeaderAux)
	aHeaderAux  := {}

	// Adiciona parametro de inicializador padrao
	For nx:=1 to len(aTempHeader)
	    Aadd(aTempHeader[nx], "")
	    Aadd(aTempHeader[nx], "")
	Next nx

	// Adiciona parametro de inicializador padrao
	For nx:=1 to len(aRA3RA4HD)
	    Aadd(aRA3RA4HD[nx], "")
	    Aadd(aRA3RA4HD[nx], "")
	Next nx

	//Adiciona campos que nao existem no SX3 de acordo com a ordem da apresentacao na GetDados
	For nx:=1 to len(aTempHeader)

	    cCpo := AllTrim(aTempHeader[nx][2])

	    //Inverte a posicao dos campos Turma e Caledario
	    If Alltrim(aTempHeader[nx][2]) == (cTab + "_TURMA")
			Aadd(aHeaderAux, aTempHeader[nx+1])
			If cTab == "RA3"
			aHeaderAux[nx+12][1] := OemtoAnsi(STR0045)   // Calendario
			EndIF
		ElseIf Alltrim(aTempHeader[nx][2]) == (cTab + "_CALEND")
			Aadd(aHeaderAux, aTempHeader[nx-1])
		ElseIf Len(aHeaderAux) == 0 .OR. aScan(aHeaderAux, {|x| AllTrim(x[2]) == cCpo}) == 0
			Aadd(aHeaderAux, aTempHeader[nx])
		EndIf

		If Alltrim(aTempHeader[nx][2]) == (cTab + "_MAT")

			Aadd(aHeaderAux, {OemtoAnsi(STR0027), cTab + "_NOME"  , AllTrim(X3Picture("RA4_NOME"))  , TamSX3("RA4_NOME")[1]	 , TamSX3("RA4_NOME")[2]  , "", "û", "C", " ", "V", , 'Trm070NomIni("' + cTab + '")'}) 	//"Nome"
			Aadd(aHeaderAux, {OemtoAnsi(STR0028), cTab + "_SINONI", AllTrim(X3Picture("RA4_SINONI")), TamSX3("RA4_SINONI")[1], TamSX3("RA4_SINONI")[2], "", "û", "C", " ", "V", , 'Trm070SinIni()'}) 				//"Cod.Sinonimo"
			Aadd(aHeaderAux, {OemtoAnsi(STR0029), cTab + "_DESCSI", AllTrim(X3Picture("RA4_DESCSI")), TamSX3("RA4_DESCSI")[1], TamSX3("RA4_DESCSI")[2], "", "û", "C", " ", "V", , 'Trm070DscSIni()'}) 				//"Desc.Sinonim"

			If cTab == "RA3"
				Aadd(aHeaderAux, {OemtoAnsi(STR0030), cTab + "_VALIDA", AllTrim(X3Picture("RA4_VALIDA")), TamSX3("RA4_VALIDA")[1], TamSX3("RA4_VALIDA")[2], "", "û", "D", " ", "V", , GetSX3cache("RA4_VALIDA","X3_RELACAO") } ) //"Dt.Validade"
				Aadd(aHeaderAux, {OemtoAnsi(STR0031), cTab + "_NOTA"  , AllTrim(X3Picture("RA4_NOTA"))  , TamSX3("RA4_NOTA")[1]	 , TamSX3("RA4_NOTA")[2]  , 'Fra3Valid()', "û", "N", " ", "V", , 'Trm070NotIni("' + cTab + '")'})//"Nota"
			Else
				Aadd(aHeaderAux, aTempHeader[aScan(aTempHeader, {|x| AllTrim(x[2]) == "RA4_VALIDA"})])
				Aadd(aHeaderAux, aTempHeader[aScan(aTempHeader, {|x| AllTrim(x[2]) == "RA4_NOTA"})])
			EndIf

			Aadd(aHeaderAux, {OemtoAnsi(STR0032), cTab + "_DURACA", AllTrim(X3Picture("RA4_DURACA")), TamSX3("RA4_DURACA")[1], TamSX3("RA4_DURACA")[2], "", "û", "N", " ", "V", , 'RA2->RA2_DURACA'			  }) 	//"Duracao"
			Aadd(aHeaderAux, {OemtoAnsi(STR0033), cTab + "_UNDURA", AllTrim(X3Picture("RA4_UNDURA")), TamSX3("RA4_UNDURA")[1], TamSX3("RA4_UNDURA")[2], "", "û", "C", " ", "V", , 'RA2->RA2_UNDURA'			  }) 	//"Un.Duracao"

			If cTab == "RA3"
				Aadd(aHeaderAux, {OemtoAnsi(STR0034), cTab + "_PRESEN", AllTrim(X3Picture("RA4_PRESEN")), TamSX3("RA4_PRESEN")[1], TamSX3("RA4_PRESEN")[2], "", "û", "N", " ", "V", , 'criavar("RA4_PRESEN",.T.)'}) 	//"% Presenca"
			Else
				Aadd(aHeaderAux, aTempHeader[aScan(aTempHeader, {|x| AllTrim(x[2]) == "RA4_PRESEN"})])
			EndIf
			Aadd(aHeaderAux, {OemtoAnsi(STR0035), cTab + "_DATAIN", AllTrim(X3Picture("RA4_DATAIN")), TamSX3("RA4_DATAIN")[1], TamSX3("RA4_DATAIN")[2], "", "û", "D", " ", "V", , 'RA2->RA2_DATAIN'			  }) 	//"Data Inicio"
			Aadd(aHeaderAux, {OemtoAnsi(STR0036), cTab + "_DATAFI", AllTrim(X3Picture("RA4_DATAFI")), TamSX3("RA4_DATAFI")[1], TamSX3("RA4_DATAFI")[2], "", "û", "D", " ", "V", , 'RA2->RA2_DATAFI'			  }) 	//"Data Fim"
			Aadd(aHeaderAux, {OemtoAnsi(STR0037), cTab + "_VALOR" , AllTrim(X3Picture("RA4_VALOR")) , TamSX3("RA4_VALOR")[1] , TamSX3("RA4_VALOR")[2] , "", "û", "N", " ", "V", , 'Trm070ValIni("' + cTab + '")'}) 	//"Valor"
			Aadd(aHeaderAux, {OemtoAnsi(STR0038), cTab + "_HORAS" , AllTrim(X3Picture("RA4_HORAS")) , TamSX3("RA4_HORAS")[1] , TamSX3("RA4_HORAS")[2] , "", "û", "N", " ", "V", , 'RA2->RA2_HORAS'			  }) 	//"Horas"
		EndIf

		If Alltrim(aTempHeader[nx][2]) == (cTab + "_CALEND")
			Aadd(aHeaderAux, {OemtoAnsi(STR0040), cTab + "_NIVEL" , AllTrim(X3Picture("RA4_NIVEL")) , TamSX3("RA4_NIVEL")[1] , TamSX3("RA4_NIVEL")[2] , "", "û", "C", " ", "V", , GetSX3cache("RA4_NIVEL","X3_RELACAO") }) 	//"Nivel"
			Aadd(aHeaderAux, {OemtoAnsi(STR0041), cTab + "_STATUS", AllTrim(X3Picture("RA4_STATUS")), TamSX3("RA4_STATUS")[1], TamSX3("RA4_STATUS")[2], "", "û", "C", " ", "V", , GetSX3cache("RA4_STATUS","X3_RELACAO") }) 	//"Status"
			Aadd(aHeaderAux, {OemtoAnsi(STR0042), cTab + "_DTALT" , AllTrim(X3Picture("RA4_DTALT")) , TamSX3("RA4_DTALT")[1] , TamSX3("RA4_DTALT")[2] , "", "û", "D", " ", "V", , GetSX3cache("RA4_DTALT","X3_RELACAO") }) 	//"Dt ult alter"
			Aadd(aHeaderAux, {OemtoAnsi(STR0044), cTab + "_CONTEU", AllTrim(X3Picture("RA4_CONTEU")), TamSX3("RA4_CONTEU")[1], TamSX3("RA4_CONTEU")[2], "", "û", "M", " ", "V", , GetSX3cache("RA4_CONTEU","X3_RELACAO") }) 	//"Conteudo"
		EndIf

		If Alltrim(aTempHeader[nx][2]) == (cTab + "_RESERV")

			//aHeaderAux[nx+18][1]:=OemtoAnsi(STR0046)  	// Tp Reserva
   			//--Os campos abaixo sao auxiliares, por isso nao utiliza os dados do dicionario
			Aadd(aHeaderAux, {OemtoAnsi(STR0011), cTab + "_DESPES", "@!", 03, 0, "", "û", "C", " ", "V", , 'Trm070DspInic("' + cTab + '")'})		//"Despesa"
			Aadd(aHeaderAux, {OemtoAnsi(STR0014), cTab + "_XXAVAL", "@!", 03, 0, "", "û", "C", " ", "V", , 'Trm070AValIni("' + cTab + '")'})		//"Avaliacao"
   			Aadd(aHeaderAux, {OemtoAnsi(STR0016), cTab + "_FILAUX", "@!", FWGETTAMFILIAL, 0, "", "û", "C", " ", "V", , 'RA3->RA3_FILIAL'})			//"Filial"

		EndIf

	Next nx

	For nX:= 1 to Len(aRA3RA4HD)
		Aadd(aHeaderAux, aRA3RA4HD[nX])
	Next nX

Return aHeaderAux


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Trm070NomIni³ Autor ³ Joeudo Santana	 	³ Data ³ 12/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inicializador do campo RA3_NOME					  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA070                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Trm070NomIni(cTab)
	Local cNome	:= ""

	If FindFunction("SPFilterOff")       // verifica se existe a função
		SPFilterOff( { "SRA" } )           //desabilita o filtro da tabela "SRA"
	EndIf

	// Nome Funcionario
	dbSelectArea("SRA")
	dbSetOrder(1)
	If SRA->(dbSeek((&(cTab+"->"+cTab+"_FILIAL"))+(&(cTab+"->"+cTab+"_MAT"))))
		cNome := SRA->RA_NOME
	EndIf

	If FindFunction("SPFilterOff")       // verifica se existe a função
		SPFilterOff(  { "SRA" } ,  .F.  )    //ativa o filtro
	EndIf
Return cNome


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Trm070SinIni³ Autor ³ Joeudo Santana	  	³ Data ³ 12/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inicializador do campo RA3_SINONI					  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA070                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Trm070SinIni()

Local	cSinoni:= ""
	// Sinonimo Curso
	dbSelectArea("RA9")
	dbSetOrder(1)
	If dbSeek(xFilial("RA9")+RA2->RA2_SINON)
		cSinoni 	:= RA9->RA9_SINONI
	EndIf
Return cSinoni

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Trm070DscSIni³ Autor ³ Joeudo Santana		³ Data ³ 12/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inicializador do campo RA3_DESCSI					  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA070                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Trm070DscSIni()
	Local cDescSinon:=""

	// Sinonimo Curso
	dbSelectArea("RA9")
	dbSetOrder(1)
	If dbSeek(xFilial("RA9")+RA2->RA2_SINON)
		cDescSinon	:= RA9->RA9_DESCR
	EndIf
Return cDescSinon


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Trm070NotIni³ Autor ³ Joeudo Santana		³ Data ³ 12/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inicializador do campo RA3_NOTA					  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA070                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Trm070NotIni(cTab)
Local nNota  := 0
Local cChave := RA3->RA3_FILIAL+RA3->RA3_CALEND+RA3->RA3_CURSO+RA3->RA3_TURMA+RA3->RA3_MAT

	dbSelectArea("RAI")
	dbSetOrder(1)
	If RAI->(dbSeek((&(cTab+"->"+cTab+"_FILIAL"))+(&(cTab+"->"+cTab+"_CALEND"))+;
					(&(cTab+"->"+cTab+"_CURSO"))+(&(cTab+"->"+cTab+"_TURMA"))+;
					(&(cTab+"->"+cTab+"_MAT"))))
		While !(RAI->(Eof())) .And. ((&(cTab+"->"+cTab+"_FILIAL"))+(&(cTab+"->"+cTab+"_CALEND"))+;
									(&(cTab+"->"+cTab+"_CURSO"))+(&(cTab+"->"+cTab+"_TURMA"))+;
									(&(cTab+"->"+cTab+"_MAT")));
									==;
									RAI->RAI_FILIAL+RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA+RAI->RAI_MAT

			// Nota da Avaliacao Aluno
			If RAI->RAI_QUEM == "1" .And. RAI->RAI_TIPO == "AVA"
				nNota 	:= 0
				cTeste	:= RAI->RAI_TESTE
			   	While 	!Eof() .And. 	RAI->RAI_TESTE == cTeste .And. RAI->RAI_QUEM == "1" .And. RAI->RAI_TIPO == "AVA" .and.;
			   			 (cChave == RAI->RAI_FILIAL+RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA+RAI->RAI_MAT)

					If RAI->RAI_RESULT > 0

					   	dbSelectArea("SQO")
						dbSetOrder(1)
						If dbSeek(xFilial("SQO")+RAI->RAI_QUESTA)
							nNota += ((SQO->QO_PONTOS * RAI->RAI_RESULT) / 100)
						EndIf
					EndIf

					dbSelectArea("RAI")
			   		dbSkip()
				EndDo
			Else
				dbSkip()
			EndIf
		EndDo
	EndIf

Return nNota



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Trm070ValIni³ Autor ³ Joeudo Santana		³ Data ³ 12/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inicializador da coluna Avaliacao					  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA070                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Trm070AValIni(cTab)

Local	cAval  	:= STR0012			//"NAO"

	dbSelectArea("RAI")
	dbSetOrder(1)
	If RAI->(dbSeek((&(cTab+"->"+cTab+"_FILIAL"))+(&(cTab+"->"+cTab+"_CALEND"))+;
					(&(cTab+"->"+cTab+"_CURSO"))+(&(cTab+"->"+cTab+"_TURMA"))+;
					(&(cTab+"->"+cTab+"_MAT"))))
		While !(RAI->(Eof())) .And. ((&(cTab+"->"+cTab+"_FILIAL"))+(&(cTab+"->"+cTab+"_CALEND"))+;
									(&(cTab+"->"+cTab+"_CURSO"))+(&(cTab+"->"+cTab+"_TURMA"))+;
									(&(cTab+"->"+cTab+"_MAT")));
									==;
									RAI->RAI_FILIAL+RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA+RAI->RAI_MAT

			// Avaliacao do Treinamento
			If RAI->RAI_TIPO == "AVA"
				cAval := STR0013	// "SIM"
			EndIf
			RAI->(dbSkip())
		EndDo
	EndIf

Return cAval



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Trm070ValIni ³ Autor ³ Joeudo Santana		³ Data ³ 12/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inicializador da coluna Valor						  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA070                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Trm070ValIni(cTab)

Local	nValor	:= 0.00

	dbSelectArea("RAA")
	dbSetOrder(1)
	If RAA->(dbSeek((&(cTab+"->"+cTab+"_FILIAL"))+(&(cTab+"->"+cTab+"_CALEND"))+;
					(&(cTab+"->"+cTab+"_CURSO"))+(&(cTab+"->"+cTab+"_TURMA"))+;
					(&(cTab+"->"+cTab+"_MAT"))))
		While !(RAA->(Eof())) .And. ((&(cTab+"->"+cTab+"_FILIAL"))+(&(cTab+"->"+cTab+"_CALEND"))+;
								(&(cTab+"->"+cTab+"_CURSO"))+(&(cTab+"->"+cTab+"_TURMA"))+;
								(&(cTab+"->"+cTab+"_MAT")));
								==;
								RAA->RAA_FILIAL+RAA->RAA_CALEND+RAA->RAA_CURSO+RAA->RAA_TURMA+RAA->RAA_MAT
			nValor += RAA->RAA_VALOR
			RAA->(dbSkip())
		EndDo
	EndIf

	If RA2->RA2_RESERV != 0
		nValor := nValor + Round(RA2->RA2_CUSTO / RA2->RA2_RESERV,2)
	EndIf

Return nValor


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Trm070DspInic³ Autor ³ Joeudo Santana		³ Data ³ 12/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inicializador da coluna Despesa					  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA070                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Trm070DspInic(cTab)

Local	nValor	:= 0.00
Local	cDesp	:= STR0012			//"NAO"

	// Verifica se existe despesa para este funcionario

	dbSelectArea("RAA")
	dbSetOrder(1)
	If RAA->(dbSeek((&(cTab+"->"+cTab+"_FILIAL"))+(&(cTab+"->"+cTab+"_CALEND"))+;
					(&(cTab+"->"+cTab+"_CURSO"))+(&(cTab+"->"+cTab+"_TURMA"))+;
					(&(cTab+"->"+cTab+"_MAT"))))
		While !(RAA->(Eof())) .And. (&(cTab+"->"+cTab+"_FILIAL"))+(&(cTab+"->"+cTab+"_CALEND"))+;
							(&(cTab+"->"+cTab+"_CURSO"))+(&(cTab+"->"+cTab+"_TURMA"))+;
							(&(cTab+"->"+cTab+"_MAT"));
							==;
							RAA->RAA_FILIAL+RAA->RAA_CALEND+RAA->RAA_CURSO+RAA->RAA_TURMA+RAA->RAA_MAT
			nValor += RAA->RAA_VALOR
			RAA->(dbSkip())
		EndDo
	EndIf
	If nValor <> 0
		cDesp := STR0013	//"SIM"
	EndIf


Return cDesp


/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³15/01/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³TRMA070                                                     ³
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
//³    6 - Altera o registro corrente sem permitir inclusao      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aRotina :=  { 	{ STR0001, 'PesqBrw',  0, 1,,.F.}, ;	//"Pesquisar"
						{ STR0002, 'Tr070Rot', 0, 2}, ;			//"Visualizar"
						{ STR0003, 'Tr070Rot', 0, 4}, ;	//"Baixar Curso"
						{ STR0017, 'Tr070Leg', 0, 2, ,.F.} }//"Legenda"

Return aRotina


/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Funcao    |CriaVar070	  ³Autor³Rogerio Ribeiro	  ³ Data ³05/01/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descricao ³Funcao utilizada no lugar da CriaVar, para tratar os campos	³
³		   ³GHOSTCOL e COLBMP 								        	³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³Conteudo do inicializador padrao, ou valor default do tipo. ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³Generico													³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Static Function CriaVar070(cField, lInitPad, aHeader)

Local xRetorno
Local bInitPad
Local nPos:= aScan(aHeader , { |aColumns| aColumns[__AHEADER_FIELD__] ==  cField} )

Local cInitPad:= aHeader[nPos, __AHEADER_INITPAD__]
Local cTipo:= aHeader[nPos, __AHEADER_TYPE__]
Local cTamanho:= aHeader[nPos, __AHEADER_WIDTH__]

If Alltrim(cField) =="RA3_MAT"
	xRetorno := RA3->RA3_MAT
ElseIf Alltrim(cField) =="RA3_CALEND"
	xRetorno := RA3->RA3_CALEND
ElseIf Alltrim(cField) =="RA3_TURMA"
	xRetorno := RA3->RA3_TURMA
ElseIf Alltrim(cField) =="RA3_RESERV"
	xRetorno := RA3->RA3_RESERV
ElseIf Alltrim(cField) =="RA3_MEMINT"
	xRetorno := RA3->RA3_MEMINT
ElseIf Alltrim(cField) =="RA4_NIVEL"
	xRetorno := RA4->RA4_NIVEL
ElseIf Alltrim(cField) =="RA4_STATUS"
	xRetorno := RA4->RA4_STATUS
ElseIf Alltrim(cField) =="RA4_DTALT"
	xRetorno := RA4->RA4_DTALT
ElseIf Alltrim(cField) =="RA4_CONTEU"
	xRetorno := RA4->RA4_CONTEU
Else
	IF lInitPad .AND. !Empty(cInitPad)
		bInitPad:= __ExecMacro( " { || xRetorno := " + cInitPad + " } " )

		If !CheckExecForm(bInitPad , .F. )
			xRetorno := GetValType(cTipo, cTamanho)
		EndIf
	Else
		xRetorno := GetValType(cTipo, cTamanho)
	EndIf
EndIf
Return xRetorno

/*/{Protheus.doc} fSendDadosApi
Processo para enviar os dados de inclusão integração via API REST.
@since	08/06/2020
@autor	Silvia Taguti
@version P12.1.XX
/*/

Static Function fSendDadosApi(cProces,cTmpFil, cTmpMat, cTmpCalen, cTmpCurso, cTmpTurma,cOperacao)

Local aArea		:= GetArea()
Local lIntegrac := SUPERGETMV('MV_RHNG', .F., .F.)
Local dDtBase   := dDataBase
Local cHoraAt   := Time()
Local cTmpEmp   := cEmpAnt
Local cUserId   := SubStr(cUsuario,7,15)
Local cChave    := ""

Default cTmpMat   	:= M->R4_MAT
Default cTmpFil   	:= xFilial ("RA4")
Default cProces		:= "RA4"
Default cTmpCalen	:= ""
Default cTmpCurso 	:= ""
Default cTmpTurma	:= ""
Default cOperacao 	:= 'I'

If !lIntegrac
	Return (.T.)
EndIf

If !ChkFile("RJP")
	Return
Endif

cChave    := cTmpEmp + "|" + cTmpFil + "|" + cTmpCalen + "|"+ cTmpCurso + "|"+ cTmpTurma + "|"+cTmpMat

fSetInforRJP(cTmpFil, cTmpMat, cProces, cChave, cOperacao,  dDtBase, cHoraAt, cUserId)

RestArea(aArea)

Return (.T.)

/*/{Protheus.doc} Fra3Valid
Função para validação do campo RA3_NOTA em tempo de execução.
@since	08/04/2021
@autor	Fernando Guilherme
@version P12.1.XX
/*/
Function Fra3Valid()

	Local lRet := .T.

	// Ponto de Entrada para validação de usuário
	If ExistBlock("TRM070R3N")
		lRet:= ExecBlock("TRM070R3N",.F.,.F.)
	EndIF

Return lRet
