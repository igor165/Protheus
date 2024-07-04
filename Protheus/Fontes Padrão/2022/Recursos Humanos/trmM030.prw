#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TRMM030.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o       ³ Trmm030  ³ Autor ³ Emerson Grassi Rocha    ³ Data ³ 30/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o    ³ Solicitacao Coletiva de Treinamento.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso          ³ Trmm030                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ BOPS   ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car. ³28/07/14³TPZWA0  ³Incluido o fonte da 11 para a 12 e efetuada ³±±
±±³             ³        ³        ³a limpeza.                                  ³±±
±±³Flavio Correa³22/08/14³TQJQPC  ³Incluido o inicialização de campo memo	     ³±±
±±³Raquel Hager ³01/09/14³TQIBLJ  ³Remocao de ajuste na funcao Tr030Ex()       ³±±
±±³Oswaldo L   ³01/03/17³DRHPONTP-9³Nova funcionalidade de tabelas temporarias  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Trmm030

LOCAL cFiltra	:= ""				//Variavel para filtro
LOCAL aIndFil	:= {}				//Variavel Para Filtro

Private bFiltraBrw := {|| Nil}		//Variavel para Filtro

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
Private aRotina		:= MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina
Private aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[2]Ofuscamento
Private lOfuscaNom	:= Len( If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {}) ) > 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro	:= OemtoAnsi(STR0004)		//"Solicitacao coletiva de Treinamento"
Private aVetor := {}
Private oTmpTabFO1
Private cTr1Alias	:= GetNextAlias()
Private o1Ok,oNo

oNo 	:= LoadBitmap( GetResources(), "LBNO" )
o1Ok 	:= LoadBitmap( GetResources(), "LBOK" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RA1")
dbSetOrder(1)

cFiltra 	:= CHKRH(FunName(),"RA1","1")
bFiltraBrw 	:= {|| FilBrowse("RA1",@aIndFil,@cFiltra) }
Eval(bFiltraBrw)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RA1")
dbGoTop()

mBrowse(6, 1, 22, 75, "RA1")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("RA1",aIndFil)

DeleteObject(oNo)
DeleteObject(o1Ok)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr030Sol      ³ Autor ³  Emerson Grassi  ³ Data ³ 30/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa Solicitacao de Treinamento Coletivo 	  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr030Sol()	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Trmm030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr030Sol(cAlias,nReg,nOpc)

Local aSaveArea	:= GetArea()
Local aSays   	:= {}
Local aButtons	:= {}
Local nOpca		:= 0

Local cPerg			:= "TRM030"
Local cFunction		:= "TRMM030"
Local bProcess	  	:= {|oSelf| Tr030Rot(cAlias,nReg,nOpc,oSelf)} //{|oSelf|lRetorna:=Tr030Monta(cAlias,cCurso,oSelf)}
Local cDescription	:= OemToAnsi(STR0036) +" "+ OemToAnsi(STR0037)   //"Esta rotina permite a solicitacao coletiva de treinamento correspondente" "ao curso escolhido."

Private lAbortPrint := .F.

tNewProcess():New(cFunction,cCadastro,bProcess,cDescription,cPerg)

RestArea(aSaveArea)
Return( NIL )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr030Rot  ³ Autor ³ Emerson Grassi Rocha ³ Data ³ 30/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta o Registro de Treinamentos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Trmm030       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr030Rot(cAlias,nReg,nOpc,oSelf)

Local aSaveArea:= GetArea()
Local lRetorna	:= .T.
Local aFields	:= {}
Local cChave	:= ""
Local cCond		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Tratar Enchoice                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aCampos		:= {}
Local aNaoAlterar	:= {}
Local aAlteraveis   := {}
Local cCurso		:= RA1->RA1_CURSO
Local cDescCurso 	:= RA1->RA1_DESC
Local cTitCurso		:= ""
Local cTitEntidade	:= ""
Local cTitData		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Tratar Design da Tela                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oDlgMain
Local oOk, n
Local oSubstitui
Local c1Lbx   		:= ""
Local oDlg
Local aMostrar		:= {}

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
Local aObj1Coords	:= {}

Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}
Local aObj2Coords	:= {}

Local aAvFields		:= {} //campos exibidos em tela a serem avaliados pelo gerenciamento de dados sensiveis
Local aPDFields		:= {} //campos que estao classificados como dados sensiveis
Local aOfuscaCpo	:= {}

Local nX			:= 0
Local nPos			:= 0

Local nOpca			:= 0

Private o1Lbx,oGet
Private oBtn1, oBtn2, oBtn3, oBtn4

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis de Perguntas				                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private FilialDe	:= ""
Private FilialAte 	:= ""
Private CcDe      	:= ""
Private CcAte     	:= ""
Private MatDe     	:= ""
Private MatAte    	:= ""
Private FuncDe    	:= ""
Private FuncAte   	:= ""
Private Ordem     	:= 1
Private GrupoDe   	:= ""
Private GrupoAte  	:= ""
Private DeptoDe   	:= ""
Private DeptoAte  	:= ""
Private SindDe    	:= ""
Private SindAte   	:= ""

//-- Alias para Referencia a Arquivo Temporario

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Tratar a GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aTELA[0][0],aGETS[0]
Private aHeader	:= {}
Private aCols	:= {}
Private aTr1Rec	:= {}
Private Continua:= .F.
Private nUsado  := 0
Private lMostra	:= .F.
Private aVirtual:= {}

Private nOpcx	:= nOpc //Opcao para somente poder alterar os campos
Private nOpcGet	:= nOpc

Private aColsVazio  := {}
Private nPosFilial	:= 0
Private nPosMat		:= 0
Private nPosNome	:= 0


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados: Monta aHeader e aCols para receber funcionarios selecionados         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFields	:= Tr030NMostra()

Tr030Header(aFields)
Aadd(aHeader,{OemtoAnsi(STR0007),"RA3_XNOME","@!",30,0,"","û","C"," ","V" } )	//"Nome"
nUsado 	:= Len(aHeader)

aCols	:= Array(1,nUsado+1)
Tr030Cols(aFields)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados: Inicializa Vetor aCols                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aColsVazio  := aClone(aCols[1]) //Copia do Acols Vazio para inicializar
nPosFilial	:= GdFieldPos( "RA3_FILIAL")
nPosMat		:= GdFieldPos( "RA3_MAT")
nPosNome	:= GdFieldPos( "RA3_XNOME")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Tratar Enchoice                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCampos		:= {}
aMostrar	:= {"RA3_CURSO","RA3_DESC","RA3_DATA"}
aNaoAlterar := {"RA3_CURSO","RA3_DESC"}
aAlteraveis := {}
cTitCurso	:= ""
cTitEntidade:= ""
cTitData	:= ""

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("RA3")

While ! Eof() .and. (X3_ARQUIVO == "RA3")

    If Ascan(aMostrar,Upper(Trim(x3_campo))) > 0
		Aadd(aCampos,Upper(Trim(x3_campo)))
	Endif

    If Ascan(aNaoAlterar,Upper(Trim(x3_campo))) == 0
		Aadd(aAlteraveis,Upper(Trim(x3_campo)))
	Endif

	cCampo  	:= "M->"+X3_CAMPO
	cX3Campo 	:= "RA3->"+X3_CAMPO

	If x3_campo = "RA3_CURSO"  //Variaveis vindas do RA1
		&cCampo := cCurso
        //-- Carrega o Titulo do campo RA3_Curso na lingua nativa
        //-- para ser utilizado no help se necessario
		cTitCurso:=X3Titulo()
	ElseIf x3_campo = "RA3_DESC" //Variaveis vindas do RA1
		&cCampo := cDescCurso
    Else
    	IF x3_Tipo = "C"
			&cCampo := SPACE(x3_tamanho)
		ELSEIF  x3_Tipo  = "N"
			&cCampo := 0
		ELSEIF  x3_Tipo  = "D"
			&cCampo := CtoD("  /  /  ")
		ELSEIF  x3_Tipo  = "L"
			&cCampo := .F.
		ELSEIF  x3_Tipo  = "M"
			&cCampo := ""
		ENDIF
	Endif

	dbSkip()
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem Parametros para Selecao de Funcionarios                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// MV_PAR01		- Filial De
// MV_PAR02		- Filial Ate
// MV_PAR03		- Centro Custo de
// MV_PAR04		- Centro Custo ate
// MV_PAR05		- Matricula de
// MV_PAR06		- Matricula ate
// MV_PAR07		- Funcao de
// MV_PAR08		- Funcao ate
// MV_PAR09     - Ordem 1-Nome 2-Matricula 3-Centro Custo 4-Funcao
// MV_PAR10		- Grupo De
// MV_PAR11     - Grupo Ate
// MV_PAR12		- Depto De
// MV_PAR13		- Depto Ate
// MV_PAR14		- Sindicato De
// MV_PAR15		- Sindicato Ate
// MV_PAR16    - Status Funcionario
// MV_PAR17    - Ferias Programadas

Pergunte("TRM030",.F.)

FilialDe  	:= MV_PAR01
FilialAte 	:= MV_PAR02
CcDe      	:= MV_PAR03
CcAte     	:= MV_PAR04
MatDe     	:= MV_PAR05
MatAte    	:= MV_PAR06
FuncDe    	:= MV_PAR07
FuncAte   	:= MV_PAR08
Ordem     	:= MV_PAR09
GrupoDe   	:= MV_PAR10
GrupoAte  	:= MV_PAR11
DeptoDe   	:= MV_PAR12
DeptoAte  	:= MV_PAR13
SindDe    	:= MV_PAR14
SindAte   	:= MV_PAR15

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botoes de Selecao: Carrega Imagens                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oOk 	:= LoadBitmap( GetResources(), "Enable" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ListBox: Cria arquivo temporario                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Tr030CriaArq()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ListBox: Preenche com Funcionarios Filtrados conforme Parametros               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

lRetorna := Tr030Monta(cAlias,cCurso,oSelf)

//Verifica se foram encontrados funcionarios de acordo com os parametros
If !lRetorna

   Alert(OemtoAnsi(STR0005)) //## "ATENCAO: Nao Foram Encontrados Funcionarios de Acordo com os Parametros Especificados "  ##
   //-- Nao Foram Encontrados
   Fecha030(aSaveArea,oOK,oNo,o1OK)

   Return .F.
Endif

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 035 , .T. , .F. } )				//1-Dados Curso
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )				//2-ListBox - Botoes - MsGetDados
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

aAdv1Size		:= aClone(aObjSize[2])
aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 0 , 0 }
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. , .T. } )		//1-ListBox
aAdd( aObj1Coords , { 023 , 000 , .F. , .T. } )			//2-Botoes
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )			//3-MsGetDados
aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords,,.T. )

//Divisao da coluna 2-Botoes em 10 linhas
aAdv2Size		:= aClone(aObj1Size[2])
aInfo2AdvSize	:= { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 5 , 10 }
For n:=1 to 10
	aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )
Next n
aObj2Size		:= MsObjSize( aInfo2AdvSize , aObj2Coords)


Dbselectarea(cTr1Alias)
(cTr1Alias)->(DBGotop())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dialogo: Exibe Caixa para conter os objetos                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgMain Title cCadastro From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Enchoice: Exibe os gets de Entrada das Informacoes Compelementares             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Enchoice: Inicializa variaveis de memoria para Informacoes Complementares do Curso
dbSelectArea("RA3")
dbSetOrder(1)

nOpca := EnChoice( "RA3", nReg, nOpcx ,,,,aCampos,aObjSize[1],aAlteraveis )

M->RA3_DESC	:= cDescCurso

@ aObj1Size[1,1],aObj1Size[1,2] LISTBOX o1Lbx VAR c1Lbx FIELDS ;
		 HEADER    						    "",;			//Em Branco para Selecao
							OemtoAnsi(STR0006),;			//"Fil."
							OemtoAnsi(STR0008),;			//"Matricula"
							OemtoAnsi(STR0007),;			//"Nome"
							OemtoAnsi(STR0009),;			//"Centro Custo"
							OemtoAnsi(STR0010),;			//"Descr. Centro Custo"
							OemtoAnsi(STR0011),;			//"Fun‡„o "
							OemtoAnsi(STR0012)	;	   	    //"Descr. Fun‡„o"
		COLSIZES 			GetTextWidth(0,"W"),;
							GetTextWidth(0,Space(FWGETTAMFILIAL)),;
							GetTextWidth(0,"BBBBBB"),;
							GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"),;
							GetTextWidth(0,"BBBBBBBBB"),;
							GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"),;
							GetTextWidth(0,"BBBB"),;
							GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB");
					        SIZE aObj1Size[1,3],aObj1Size[1,4] OF oDlgMain PIXEL

	o1Lbx:nFreeze := 3
	o1Lbx:SetArray( aVetor )//<- Atencao: tabelas temporarias no banco nao podem ser vinculadas ao listBox. Utilizamos entao uma array
	o1Lbx:bLine:= {||{  		    aVetor[o1Lbx:nAt,1],;
									aVetor[o1Lbx:nAt,2],;
									aVetor[o1Lbx:nAt,3],;
									aVetor[o1Lbx:nAt,4],;
									aVetor[o1Lbx:nAt,5],;
									aVetor[o1Lbx:nAt,6],;
									aVetor[o1Lbx:nAt,7],;
									aVetor[o1Lbx:nAt,8]}   }

	//Proteção de Dados Sensíveis
	If aOfusca[2]
		aOfuscaCpo := {.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.}
		aAvFields  := {" ","RA_FILIAL","RA_MAT","RA_NOME","RA_CC","RA_DESCCC","RA_CODFUNC","RA_DESCFUN"}
		aPDFields := FwProtectedDataUtil():UsrNoAccessFieldsInList(  aAvFields )
		o1Lbx:lObfuscate := .T.
		For nX := 1 to Len(aPDFields)
			nPos := aScan(aAvFields, {|x| x == aPDFields[nX]:cField})
			aOfuscaCpo[nPos] := .T.
		Next nX
		o1Lbx:aObfuscatedCols := aOfuscaCpo
	EndIf

	o1Lbx:Hide()
	o1Lbx:Show()
	o1Lbx:Refresh()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados: Exibe aHeader e aCols para funcionarios selecionados                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGet  := MSGetDados():New(aObj1Size[3,1],aObj1Size[3,2],aObj1Size[3,3],aObj1Size[3,4],nOpc,"Tr030LinOK()","Tr030AllOK()"," ",.F.,{},1,.F.)

	//Proteção de Dados Sensíveis
	If aOfusca[2]
		aOfuscaCpo := {.F.,.F.,.F.}
		aAvFields  := {"RA_FILIAL","RA_MAT","RA_NOME"}
		aPDFields := FwProtectedDataUtil():UsrNoAccessFieldsInList(  aAvFields )
		oGet:oBrowse:lObfuscate := .T.
		For nX := 1 to Len(aPDFields)
			nPos := aScan(aAvFields, {|x| x == aPDFields[nX]:cField})
			aOfuscaCpo[nPos] := .T.
		Next nX
		oGet:oBrowse:aObfuscatedCols := aOfuscaCpo
	EndIf

//-- Botoes de Movimentacao de Funcionario

oBtn1 := TBitmap():New(aObj2Size[1,1],aObj2Size[1,2],25,25,,"NEXT",.T.,oDlgMain ,;
                {||fMoveToGet(.F.,@aVetor)},,,,,,,,.T.,,)
oBtn1:CTOOLTIP := STR0015 //##"Mover Funcionario"

oBtn3 := TBitmap():New(aObj2Size[2,1],aObj2Size[2,2],25,25,,"PREV",.T.,oDlgMain ,;
               {||fMoveToList(.F.,@aVetor)},,,,,,,,.T.,,)
oBtn3:CTOOLTIP := STR0015 //##"Mover Funcionario"

oBtn2 := TBitmap():New(aObj2Size[3,1],aObj2Size[3,2],25,25,,"PGNEXT",.T.,oDlgMain ,;
            {||Processa({||fMoveToGet(.T.,@aVetor)},OemToAnsi(STR0022)+OemToAnsi(STR0025))},,,,,,,,.T.,,)	//"Aguarde..."##"Movendo Funcionarios"#
oBtn2:CTOOLTIP := STR0015 //##"Mover Funcionario"

oBtn4 := TBitmap():New(aObj2Size[4,1],aObj2Size[4,2],25,25,,"PGPREV",.T.,oDlgMain ,;
           {||Processa({||fMoveToList(.T.,@aVetor)},OemToAnsi(STR0022)+OemToAnsi(STR0025))},,,,,,,,.T.,,)	//"Aguarde..."##"Movendo Funcionarios"#
oBtn4:CTOOLTIP := STR0015 //##"Mover Funcionario"


nOpca := 0

ACTIVATE MSDIALOG oDlgMain  On INIT ( Tr030OnOff(.T.),Tr030OnOff(.F.),;
										EnchoiceBar	(oDlgMain,	{||If(Tr030Grava("RA5",cCurso),oDlgMain:End(),Nil )},;
																{|| If(Tr030Sai(),oDlgMain:End(),Nil)};
												 	);
									)

Fecha030(aSaveArea,oOK,oNo,o1OK)

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fecha030  ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 30/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Finaliza TRMA201                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Trmm030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function Fecha030(aSaveArea,oOK,oNo,o1OK)

dbSelectArea(cTr1Alias)
dbCloseArea()

dbSelectArea("SRA")
Set Filter To
RetIndex("SRA")
dbSetOrder(1)

If oTmpTabFO1 <> Nil
    oTmpTabFO1:Delete()
    Freeobj(oTmpTabFO1)
EndIf

DeleteObject(oOk)

RestArea(aSaveArea)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr030Exc      ³ Autor ³  Emerson Grassi  ³ Data ³ 30/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa Exclusao de Registro de Treinamento Coletivo 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr030Exc()	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Trmm030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr030Exc()

Local aSaveArea	:= GetArea()
Local aSays   	:= {}
Local aButtons	:= {}
Local nOpca		:= 0
Local cPerg		:= "TR030E"
Local aRegs		:= {} //Variavel Temporaria. Devera Ser Excluida Para a Proxima VersaoLocal aRegs:={}
Local nResultado:= 0

Local cFunction		:=	"TRMM030"
Local bProcess	  	:=	{|oSelf| nOpca:= 1, nResultado:=Tr030E(oSelf)}
Local cDescription	:=	OemToAnsi(STR0030) +" "+;	//"Esta rotina eliminara os registros de treinamento coletivo correspondentes"
						OemToAnsi(STR0031)			//"ao curso escolhido."

Private cCadastro   := OemToAnsi(STR0029) // "Eliminacao de Registros de Treinamento Coletivo"

tNewProcess():New(cFunction,cCadastro,bProcess,cDescription,cPerg)


IF nOpca == 1
	ApMSGInfo(STR0035+Trim(Str(nResultado)),STR0034)
EndIF

RestArea(aSaveArea)
Return( NIL )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr030E        ³ Autor ³Emerson Grassi    ³ Data ³ 30/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclui  Registro de Treinamento Coletivo   	          	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr030E  ()	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Trmm030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr030E(oSelf)
Local aSaveArea		:= GetArea()
Local aAreaSra  	:= SRA->(GetArea())
Local nEliminados	:= 0

//-- Variavel para Controle de Acesso as informacoes dos funcionarios
Local cAcessaSRA	:= &("{ || " + ChkRH(FunName(),"SRA","2") + "}")

//-- Variaveis para Tratar de Query para Selecao de Funcionarios Via Cadastro de Func.
Local cIndCond 	:= ""
Local cFor		:= ""
Local nIndex	:= 0
Local cGrupo	:= ""
Local cDepto    := ""

//-- Variaveis para  Obter Parametros
Local FilialDe  := MV_PAR01
Local FilialAte := MV_PAR02
Local CcDe      := MV_PAR03
Local CcAte     := MV_PAR04
Local MatDe     := MV_PAR05
Local MatAte    := MV_PAR06
Local FuncDe    := MV_PAR07
Local FuncAte   := MV_PAR08
Local GrupoDe   := MV_PAR09
Local GrupoAte  := MV_PAR10
Local DeptoDe   := MV_PAR11
Local DeptoAte  := MV_PAR12
Local SindDe    := MV_PAR13
Local SindAte   := MV_PAR14
Local DataDe    := MV_PAR15
Local DataAte   := MV_PAR16

Local cFil		:= ""
Local cInicio	:= ""
Local cFim		:= ""
Local cCurso	:= RA1->RA1_CURSO
Local cCargo 	:= ""

Local oTmpTesTabFO1
Local cTrTesAlias := GetNextAlias()
Local nTotLoop
Local nLoop
Local aFields := {}
Local __aStruSRA__

dbSelectArea("SRA")
dbGoTop()
// Matricula
dbSetOrder(1)
cIndCond    := "RA_FILIAL+RA_MAT+RA_CC+RA_CODFUNC"
cFor		:= '(RA_FILIAL+RA_MAT+RA_CC+RA_CODFUNC >="'
cFor		+=  FilialDe+MatDe+CcDe+FuncDe +'") .And.'
cFor		+= '(RA_FILIAL+RA_MAT+RA_CC+RA_CODFUNC <="'
cFor		+=  FilialAte+MatAte+CcAte+FuncAte +'")'

__aStruSRA__ := SRA->(dbStruct())
nTotLoop	:= Len(__aStruSRA__)

For nLoop:=1 To nTotLoop
	AADD(aFields,{	__aStruSRA__[nLoop,1]   ,;
       		        __aStruSRA__[nLoop,2]  	,;
			        __aStruSRA__[nLoop,3]  	,;
			        __aStruSRA__[nLoop,4]    }    )
Next

oTmpTesTabFO1 := RhCriaTrab(cTrTesAlias, aFields, Nil)

IndRegua("SRA",cTrTesAlias/*cArq2Ntx*/,cIndCond,,cFor,,.F.)		//"Selecionando Registros..."
nIndex := RetIndex("SRA")

#IFNDEF TOP
	dbSetIndex(cTrTesAlias+OrdBagExt())
#ENDIF

dbSetOrder(nIndex+1)
dbGoTop()

oSelf:SetRegua1(SRA->(RecCount()))
oSelf:SaveLog(STR0004 + ": " + STR0023 + " - " + STR0038)	//"Inicio do Processamento"


While !Eof()

	oSelf:IncRegua1(OemToAnsi(STR0022)+OemToAnsi(STR0028)) //"Aguarde..."###" Excluindo Registros ...."
	oSelf:SetRegua2(1)
	oSelf:IncRegua2(STR0013+" / "+STR0008+": "+SRA->RA_FILIAL+" / "+ SRA->RA_MAT + If(lOfuscaNom, "", " - " + Left(SRA->RA_NOME,25)) )// Filial / Matricula

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste controle de acessos e filiais validas				 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If !(SRA->RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA)
       dbSkip()
       Loop
    EndIf

	If 	SRA->RA_CC 		< CcDe 		.Or. SRA->RA_CC 		> CcAte 	.Or.;
		SRA->RA_MAT 	< MatDe 	.Or. SRA->RA_MAT 		> MatAte 	.Or.;
		SRA->RA_CODFUNC < FuncDe 	.Or. SRA->RA_CODFUNC 	> FuncAte
		dbSkip()
		Loop
	EndIf

	cGrupo := Space(TamSx3("Q3_GRUPO")[1])
	cDepto := Space(TamSx3("Q3_DEPTO")[1])
	cCargo := fGetCargo(SRA->RA_MAT,SRA->RA_FILIAL)

	dbSelectArea("SQ3")
	dbSetOrder(1)
	If dbSeek(xFilial("SQ3")+cCargo+SRA->RA_CC) .Or. dbSeek(xFilial("SQ3")+cCargo)
		cGrupo := SQ3->Q3_GRUPO
		cDepto := SQ3->Q3_DEPTO
	EndIf

	dbSelectArea("SRA")
	If 	cGrupo 			< GrupoDe 	.Or. cGrupo 			> GrupoAte .Or.;
		cDepto 			< DeptoDe 	.Or. cDepto 			> DeptoAte .Or.;
		SRA->RA_SINDICA < SindDe 	.Or. SRA->RA_SINDICA 	> SindAte
		dbSkip()
		Loop
	EndIf

	// Posiciona e elimina o curso Gerado por este programa
	dbSelectArea("RA3")
	dbSetOrder(1)
	If dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cCurso)
		While SRA->RA_FILIAL  + SRA->RA_MAT  + cCurso == ;
	         RA3->RA3_FILIAL + RA3->RA3_MAT + RA3->RA3_CURSO  .AND. RA3->(!Eof())

	    	//-- Despreza Datas Fora do Periodo Selecionado
	   	  	If  RA3->RA3_DATA >= DataDe .And. RA3->RA3_DATA <= DataAte
			 	nEliminados++
		   	  	RecLock("RA3",.F.)
	       	  		RA3->(DbDelete())
		      	RA3->(MsUnlock())
		   	EndIf
	      	RA3->(DbSkip())
		Enddo
	Endif

	dbSelectArea("SRA")
	dbSkip()
EndDo

oSelf:SaveLog(STR0004 + ": " + STR0023 + " - " + STR0039)	//"Término do Processamento"


dbSelectArea("SRA")
Set Filter To
RetIndex("SRA")
dbSetOrder(1)

If oTmpTesTabFO1 <> Nil
    oTmpTesTabFO1:Delete()
    Freeobj(oTmpTesTabFO1)
EndIf


RestArea(aAreaSra)
RestArea(aSaveArea)

Return nEliminados


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr030Monta³ Autor ³ Emerson Grassi Rocha ³ Data ³ 30/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta os listbox da reserva dos treinamentos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr030Monta(ExpC1,ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpC2 : Codigo do Curso                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Trmm030       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr030Monta(cAlias,cCurso,oSelf)

Local aSaveArea 	:= GetArea()
Local lRet			:= .T.
Local cIndCond 	:= ""
Local cFor		:= ""
Local cDescCC	:= ""
Local cDescFunc	:= ""
Local nBMarca	:= 0
Local nBConcl	:= 0
Local nIndex	:= 0
Local cGrupo	:= ""
Local cDepto	:= ""
Local cAcessaSRA:= &("{ || " + ChkRH(FunName(),"SRA","2") + "}")
Local cSituacao := MV_PAR16
Local nFerProg  := MV_PAR17
Local cSitFol   := ""
Local cCargo	:= ""
Local nTotLoop
Local nLoop
Local aFields := {}
Local __aStruSRA__
Local oTmpTesTabFO1
Local cTrTesAlias := GetNextAlias()

dbSelectArea("SRA")
dbGoTop()

If Ordem == 1	       // Nome
	dbSetOrder(3)
	cIndCond    := "RA_FILIAL+RA_NOME"
	cFor		:= '(RA_FILIAL+RA_MAT+RA_CC+RA_CODFUNC >="'
	cFor		+=  FilialDe+MatDe+CcDe+FuncDe +'") .And.'
	cFor		+= '(RA_FILIAL+RA_MAT+RA_CC+RA_CODFUNC <="'
	cFor		+=  FilialAte+MatAte+CcAte+FuncAte +'")'
ElseIf Ordem == 2		// Matricula
	dbSetOrder(1)
	cIndCond    := "RA_FILIAL+RA_MAT+RA_CC+RA_CODFUNC"
	cFor		:= '(RA_FILIAL+RA_MAT+RA_CC+RA_CODFUNC >="'
	cFor		+=  FilialDe+MatDe+CcDe+FuncDe +'") .And.'
	cFor		+= '(RA_FILIAL+RA_MAT+RA_CC+RA_CODFUNC <="'
	cFor		+=  FilialAte+MatAte+CcAte+FuncAte +'")'
ElseIf Ordem == 3		// Centro Custo
	dbSetOrder(2)
	cIndCond	:= "RA_FILIAL+RA_CC+RA_MAT+RA_CODFUNC"
	cFor		:= 'RA_FILIAL+RA_CC+RA_MAT+RA_CODFUNC >="'
	cFor		+=  FilialDe+CcDe+MatDe+FuncDe +'" .And.'
	cFor		+= 'RA_FILIAL+RA_CC+RA_MAT+RA_CODFUNC <="'
	cFor		+=  FilialAte+CcAte+MatAte+FuncAte +'"'
ElseIf Ordem == 4		// Funcao
	dbSetOrder(7)
	cIndCond	:= "RA_FILIAL+RA_CODFUNC+RA_MAT+RA_CC"
	cFor		:= 'RA_FILIAL+RA_CODFUNC+RA_MAT+RA_CC >="'
	cFor		+=  FilialDe+FuncDe+MatDe+CcDe + '" .And.'
	cFor		+= 'RA_FILIAL+RA_CODFUNC+RA_MAT+RA_CC <="'
	cFor		+=  FilialAte+FuncAte+MatAte+CcAte + '"'
EndIf




__aStruSRA__ := SRA->(dbStruct())
nTotLoop	:= Len(__aStruSRA__)

For nLoop:=1 To nTotLoop
	AADD(aFields,{	__aStruSRA__[nLoop,1]   ,;
       		        __aStruSRA__[nLoop,2]  	,;
			        __aStruSRA__[nLoop,3]  	,;
			        __aStruSRA__[nLoop,4]    }    )
Next

oTmpTesTabFO1 := RhCriaTrab(cTrTesAlias, aFields, Nil)


IndRegua("SRA",cTrTesAlias,cIndCond,,cFor,,.F.)		//"Selecionando Registros..."
nIndex := RetIndex("SRA")

#IFNDEF TOP
	dbSetIndex(cTrTesAlias+OrdBagExt())
#ENDIF

dbSetOrder(nIndex+1)
dbGoTop()

oSelf:SetRegua1(SRA->(RecCount()))
oSelf:SaveLog(STR0004 + ": " + STR0003 + " - " + STR0038)	//"Inicio do Processamento"

aVetor:= {}//usuario pode voltar ao grid inicial e clicar no botao de novo varias vezes. Portanto, sempre re-inicia

While !Eof()

	oSelf:IncRegua1(OemToAnsi(STR0022)+OemToAnsi(STR0021)) //"Aguarde..."###" Montando tela de Registro de Treinamentos"
	oSelf:SetRegua2(1)
	oSelf:IncRegua2(STR0013+" / "+STR0008+": "+SRA->RA_FILIAL+" / "+ SRA->RA_MAT + If(lOfuscaNom, "", " - " + Left(SRA->RA_NOME,25)) )// Filial / Matricula
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste controle de acessos e filiais validas				 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If !(SRA->RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA)
       dbSkip()
       Loop
    EndIf

	If Ordem == 1	.Or. Ordem == 2		// Matricula
		If SRA->RA_CC < CcDe .Or. SRA->RA_CC > CcAte .Or.;
			SRA->RA_MAT < MatDe .Or. SRA->RA_MAT > MatAte .Or.;
			SRA->RA_CODFUNC < FuncDe .Or. SRA->RA_CODFUNC > FuncAte
			dbSkip()
			Loop
		EndIf
	ElseIf Ordem == 3		// Centro de Custo
		If 	SRA->RA_MAT < MatDe .Or. SRA->RA_MAT > MatAte .Or.;
			SRA->RA_CODFUNC < FuncDe .Or. SRA->RA_CODFUNC > FuncAte
			dbSkip()
			Loop
		EndIf
	ElseIf Ordem == 4		// Funcao
		If 	SRA->RA_MAT	< MatDe	.Or. SRA->RA_MAT 	> MatAte .Or.;
		    SRA->RA_CC 	< CcDe 	.Or. SRA->RA_CC 	> CcAte
			dbSkip()
			Loop
		EndIf
	EndIf

	cGrupo := Space(02)
	cDepto := Space(03)
	cCargo := fGetCargo(SRA->RA_MAT,SRA->RA_FILIAL)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Situacao do Funcionario  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSitFol := TrmSitFol(dDataBase,"C")

	dbSelectArea("SRA")

	If (!(cSitfol $ cSituacao) 	.And.	(cSitFol <> "P")) .Or.;
		(cSitfol == "P" .And. nFerProg == 2)
		dbSkip()
		Loop
	EndIf

	dbSelectArea("SQ3")
	dbSetOrder(1)
	If dbSeek(xFilial("SQ3")+cCargo+SRA->RA_CC) .Or. dbSeek(xFilial("SQ3")+cCargo)
		cGrupo := SQ3->Q3_GRUPO
		cDepto := SQ3->Q3_DEPTO
	EndIf

	dbSelectArea("SRA")
	If cGrupo < GrupoDe .Or. cGrupo > GrupoAte .Or.;
		cDepto < DeptoDe .Or. cDepto > DeptoAte .Or.;
		SRA->RA_SINDICA < SindDe .Or. SRA->RA_SINDICA > SindAte
		dbSkip()
		Loop
	EndIf

	nBMarca 	:= 1
	nBConcl		:= 1

	// Verificando se ja tem Solicitacao
	dbSelectArea("RA3")
	dbSetOrder(1)
	If dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cCurso)

		nBConcl:= 2
	EndIf

	dbSelectArea("SRA")
	// Montando o ListBox 1
	cDescCC	 := FDesc("SI3",SRA->RA_CC,"SI3->I3_DESC",30)
	cDescFunc:= FDesc("SRJ",SRA->RA_CODFUNC,"SRJ->RJ_DESC",30)

	RecLock(cTr1Alias,.T.)

	(cTr1Alias)->(TR1_MARCA)		:= nBMarca
	(cTr1Alias)->(TR1_CONCL)		:= nBConcl
	(cTr1Alias)->(TR1_FILIAL)		:= SRA->RA_FILIAL
	(cTr1Alias)->(TR1_NOME)		:= SRA->RA_NOME
	(cTr1Alias)->(TR1_MAT)		:= SRA->RA_MAT
	(cTr1Alias)->(TR1_CC)			:= SRA->RA_CC
	(cTr1Alias)->(TR1_DESCCC)		:= cDescCC
	(cTr1Alias)->(TR1_FUNCAO)		:= SRA->RA_CODFUNC
	(cTr1Alias)->(TR1_DESCFUN)	:= cDescFunc
	(cTr1Alias)->(TR1_NOTA)		:= 0
	(cTr1Alias)->(TR1_PRESEN)		:= 0

	(cTr1Alias)->(MsUnlock()	)

	AADD(aVetor, {  iif((cTr1Alias)->(TR1_MARCA)==1,o1Ok,oNo),;
									(cTr1Alias)->(TR1_FILIAL),;
									(cTr1Alias)->(TR1_MAT),;
									(cTr1Alias)->(TR1_NOME),;
									(cTr1Alias)->(TR1_CC),;
									(cTr1Alias)->(TR1_DESCCC),;
									(cTr1Alias)->(TR1_FUNCAO),;
									(cTr1Alias)->(TR1_DESCFUN)} )

	dbSelectArea("SRA")
	dbSkip()
EndDo

oSelf:SaveLog(STR0004 + ": " + STR0003 + " - " + STR0039)	//"Termino do Processamento"


//-- Se nao foram encontrados funcionarios de acordo com os parametros passados
//-- retorna .f. para abandonar rotina
If (cTr1Alias)->(LastRec())<1
	lRet:=.F.
Endif

dbSelectArea(cTr1Alias)
dbGotop()

If oTmpTesTabFO1 <> Nil
    oTmpTesTabFO1:Delete()
    Freeobj(oTmpTesTabFO1)
EndIf

RestArea(aSaveArea)

Return lRet


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr030CriaArq³ Autor ³Emerson Grassi Rocha ³ Data ³ 30/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria arquivo para gravar os dados do listbox 2              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Trmm030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr030CriaArq()
Local a1Stru	:= {}
Local aSaveArea	:= GetArea()
Local cCond		:= ""
Local aLstIndices := {}
Aadd(a1Stru,{"TR1_MARCA",    "N", 1,                       0                       } )
Aadd(a1Stru,{"TR1_CONCL"	,"N", 1,                       0                       } )
Aadd(a1Stru,{"TR1_FILIAL",   "C", FWGETTAMFILIAL,          0                       } )
Aadd(a1Stru,{"TR1_NOME",     "C", TamSx3("RA_NOME")[1],    TamSx3("RA_NOME")[2]    } )
Aadd(a1Stru,{"TR1_MAT",      "C", TamSx3("RA_MAT")[1],     TamSx3("RA_MAT")[2]     } )
Aadd(a1Stru,{"TR1_CC",       "C", TamSx3("RA_CC")[1],      TamSx3("RA_CC")[2]      } )
Aadd(a1Stru,{"TR1_DESCCC",   "C", TamSx3("CTT_DESC01")[1], TamSx3("CTT_DESC01")[2] } )
Aadd(a1Stru,{"TR1_FUNCAO",   "C", TamSx3("RA_CODFUNC")[1], TamSx3("RA_CODFUNC")[2] } )
Aadd(a1Stru,{"TR1_DESCFU",   "C", TamSx3("RJ_DESC")[1],    TamSx3("RJ_DESC")[2]    } )
Aadd(a1Stru,{"TR1_NOTA"		,"N", 6,                       2                       } )
Aadd(a1Stru,{"TR1_PRESEN"	,"N", 6,                       2                       } )

If Ordem == 1				// Nome
    Aadd ( aLstIndices, {"TR1_FILIAL","TR1_NOME"} )
ElseIf Ordem == 2			// Matricula
    Aadd ( aLstIndices, {"TR1_FILIAL","TR1_MAT"} )
ElseIf Ordem == 3			// Centro de Custo
    Aadd ( aLstIndices, {"TR1_FILIAL","TR1_CC"} )
ElseIf Ordem == 4			// Funcao
    Aadd ( aLstIndices, {"TR1_FILIAL","TR1_FUNCAO"} )
EndIf

oTmpTabFO1 := RhCriaTrab(cTr1Alias, a1Stru, aLstIndices)

RestArea(aSaveArea)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr030OnOff    ³ Autor ³ Emerson Grassi   ³ Data ³ 30/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ LigaDesliga Botoes	                 			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr030OnOff()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA0030                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr030OnOff(lPrev)

Default lPrev:=.T.
//-- Se o Botao NEXT chamou a funcao
If !lPrev
   //-- Se Todos os Funcionarios foram movidos para o GetDados
   If Len(aCols)==(cTr1Alias)->(Lastrec())
      //-- Habilita Botoes Next
      oBtn3:lReadOnly:=.F.
      oBtn4:lReadOnly:=.F.
      //-- Desabilita Botoes Prev
      oBtn1:lReadOnly:=.T.
      oBtn2:lReadOnly:=.T.
   Endif
   //-- Habilita Todos os Botoes somente se houver pelo menos 1 funcionario escolhido   //--
   If Len(aCols)>0 .AND. !Empty(aCols[1,nPosMat])

      //-- Habilita Botoes NEXT
      oBtn3:lReadOnly:=.F.
      oBtn4:lReadOnly:=.F.
      //-- Habilita Botoes Prev
      oBtn1:lReadOnly:=.F.
      oBtn2:lReadOnly:=.F.
   Endif
Else
//-- Se o Botao PREV chamou a funcao
   //-- Se o GetDados Possui Apenas uma linha em branco)
   If Len(aCols)==1 .AND. Empty(aCols[1,nPosMat])
      //-- Habilita Botoes Prev
      oBtn1:lReadOnly:=.F.
      oBtn2:lReadOnly:=.F.

      //-- Desabilita Botoes Next
      oBtn3:lReadOnly:=.T.
      oBtn4:lReadOnly:=.T.
   Endif
Endif

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr030Header³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 04/10/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria o Array Aheader                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Tr030Header                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr030Header(aNaoMostrar)
Local aSaveArea := GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define aHeader para GetDados                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSeek("RA3")
nUsado:=0
While !EOF() .And. (x3_arquivo == "RA3")
	lMostra:=ASCAN(aNaoMostrar,Trim(x3_campo)) == 0
	//-- Forca Mostrar campos
	IF  ( (x3Uso(x3_Usado) .AND. lMostra)   .OR. (!x3Uso(x3_Usado).AND. lMostra) );
		.AND.   cNivel >= x3_nivel
		nUsado++
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture, x3_tamanho, x3_decimal, x3_valid, x3_usado, x3_tipo, x3_arquivo } )
	Endif
	dbSkip()
EndDo
RestArea(aSaveArea)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr030Cols  ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 04/10/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inicializa o Array aCols                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Tr030Header                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr030Cols(aNaoMostrar)
Local aSaveArea	:= GetArea()
Local nElem		:= Len(aCols)

nUsado := 0
dbSelectArea("SX3")
dbSeek("RA3")
While !EOF() .And. (x3_arquivo == "RA3")
	lMostra:=ASCAN(aNaoMostrar,Trim(x3_campo)) == 0
	//-- Forca Mostrar campos
	IF  ( (x3Uso(x3_Usado) .AND. lMostra)   .OR. (!x3Uso(x3_Usado).AND. lMostra) );
		.AND.   cNivel >= x3_nivel
		nUsado++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta array de 1 elemento vazio. Se inclus†o.       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If x3_context == "V"
			aCOLS[nElem][nUsado] := CriaVar(AllTrim(x3_campo))
			Aadd ( aVirtual , AllTrim(x3_campo) )
		Endif
		IF x3_tipo == "C"
			aCOLS[nElem][nUsado] := SPACE(x3_tamanho)
		ELSEIF x3_tipo == "N"
			aCOLS[nElem][nUsado] := 0
		ELSEIF x3_tipo == "D"
			aCOLS[nElem][nUsado] := CTOD("")
		ELSE
			aCOLS[nElem][nUsado] := .F.
		Endif
	Endif
	dbSkip()
EndDo
nUsado++
aCols[nElem,nUsado] := Space(30)	// Nome (Virtual)

aCOLS[nElem,nUsado+1] := .F.

RestArea(aSaveArea)
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr030EncOk³ Autor ³ Emerson Grassi        ³ Data ³ 30/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida Gets da Enchoice                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Trmm030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function Tr030EncOk()
Local lRet		:= .T.
Local aSaveArea	:= GetArea()

//Verifica se variavel Data da Solicitacao do Curso foi informada
If Empty(M->RA3_DATA).AND. lRet
	Help( ""  ,1  ,"RA3_DATA", , , 5 , 0 )
	lRet:= .F.
Endif

RestArea(aSaveArea)
Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr030AllOk³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 30/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida Gets de Todas as Linhas                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Trmm030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr030AllOk()
Local lRet	:= .T.

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr030LinOk³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 30/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida Gets da Linha                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Trmm030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr030LinOk()
Local lRet	:= .T.
//Nao permite Matricula em Branco (Linha Vazia)
If Empty(aCols[n,nPosMat])
   lRet	:= .F.
Endif
Return lRet


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr030Grava³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 30/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os registros referente ao treinamentos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpC1 : Codigo curso                                       ³±±
±±³          ³ ExpL2 : Sobrepoe Registro Gerado                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA201                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr030Grava(cAlias,cCurso)

Local aSaveArea	:= GetArea()
Local aTr1Area  := (cTr1Alias)->(GetArea())
Local ny        := 0
Local nZ        := 0
Local ni		:= 0
Local nMaxArray := Len(aHeader)
Local naCols    := Len(aCols)
Local xConteudo	:= ""
Local nCpos		:= 0
Local cCampo	:= ""
Local cVar		:= ""

If Len(aCols)=1 .AND. Empty(aCols[1,nPosMat])
   Alert(OemtoAnsi(STR0024)) //## "Funcionarios Nao Selecionados"
   Return(.F.)
Endif

If !Tr030EncOK()
   Return(.F.)
Endif
//-- Abre inicio da transacao de gravacao e eliminacao de itens
Begin Transaction

    dbSelectArea("RA3")
	dbSetOrder(1)

	For nZ := 1 TO naCols
	    //--Despreza marcados como deletados
		If aCols[nZ,nUsado+1]
			Loop
		Endif

		//-- Posiciona no Curso
		If !( RA3->(dbSeek(aCols[nz,nPosFilial]+aCols[nz,nPosMat]+cCurso)) )

			RecLock("RA3",.T.)

			// Grava informacoes genericas da Enchoice
			nCpos := FCount()
			For ni := 1 To nCpos
				cCampo 	:= "RA3->"+FieldName(ni)
				cVar	:=	"M->"+FieldName(ni)
				&cCampo	:= &cVar
			Next ni

			// Grava informacoes individuais da GetDados
			For ny := 1 To nMaxArray
				cCampo    := Trim(aHeader[ny][2])
				//-- Grava Campos Nao Virtuais
				If Ascan(aVirtual,cCampo) == 0
					xConteudo := aCols[nZ,ny]
					RA3->&cCampo := xConteudo
				Endif
			Next ny

		    //-- Grava Informacoes Complementares
			Replace RA3_RESERV	With	"S"

			If RA3->(ColumnPos("RA3_PORTAL")) > 0
				RA3_PORTAL := "N"
			EndIf

			RA3->( MsUnlock() )
		Endif
	Next nZ

End Transaction
RestArea(aTR1Area)
RestArea(aSaveArea)
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr030Sai  ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 30/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se abandona Rotina                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Trmm030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr030Sai()
Local lRet:=.T.
//-- Se existir pelo menos 1 funcionario selecionado
If Len(aCols)>0 .AND. !Empty(aCols[1,nPosMat])
	//-- Verifica Se NAO Abandona, entao, retorna a geracao de treinamentos coletivos
	If !MsgYesNo(OemtoAnsi(STR0027),OemtoAnsi(STR0014)) //#"Confirma Abandono da rotina?" #"Aten‡„o"
	   lRet:=.F.
	Endif
Endif
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fMoveToGet    ³ Autor ³Emerson Grassi    ³ Data ³ 30/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Move Funcionario para oGetDados                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fMoveToGet(lTodos)                                         ³±±
±±³          ³            lTodos         .T. move Todos os Funcionarios.  ³±±
±±³          ³                           .F. move Funcinario Atual.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Trmm030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static function fMoveToGet(lTodos,aVetor)
Local aSaveArea	:= GetArea()
Local nAnterior	:= 0
Local nInicio	:= 0
Local nFim		:= 0
Local nRec		:= 0
Local nRecno	:= 0
Local lRet		:= .T.
Local nLi		:= Len(aCols)
Local nRecTr1Alias      := 0
Default lTodos	:= .F.

dbSelectArea(cTr1Alias)
nRecno	:= nInicio	:= o1Lbx:nAt

//-- Determina a Abrangencia
If lTodos
   dbGoTop()
   nFim		:= Len(aVetor)
   nInicio	:= 1
    //-- Implementa Regua somente para movimentacao coletiva
   ProcRegua(nFim)
Else
   nFim:=o1Lbx:nAt
Endif

//--Marca Funcionarios de Acordo com a Abrangencia (Todos ou especifico)
For nRec:=nInicio To nFim
   //-- Incrementa Regua somente para movimentacao coletiva
   If lTodos
      IncProc()
   Endif
   If aVetor [nRec][1] == o1Ok
	  //-- Adiciona Funcionario
      //-- Altera Cor indicando que funcionario foi selecionado
      nRecTr1Alias := Tr030Marca(@aVetor, nRec, .T.)
      dbSelectArea(cTr1Alias)

      If !Empty(aCols[1,nPosMat]) //Na primeira vez, o campo estah em branco
          AADD(aCols,aClone(aColsVazio))
      Endif
      //-- Obtem o ultimo Elemento do aCols
      nLi:=Len(aCols)
      //-- Preenche-o com as informacoes
      aCols[nli,nPosFilial]	:= aVetor[nRec,2]
      aCols[nli,nPosNome]	:= aVetor[nRec,4]
      aCols[nli,nPosMat]	:= aVetor[nRec,3]

      //-- Armazena o Recno da origem das informacoes da linha da GetDados
      AADD(aTr1Rec, {aVetor[nRec,2],aVetor[nRec,3], nRecTr1Alias/*foi posicionado no tr020marca*/ } )

      lRet:=.T.
   Endif


Next nRec


RestArea(aSaveArea)

o1Lbx:Refresh(.T.)
o1Lbx:DrawSelect()
nAnterior	:= n
oGet:ForceRefresh()
n	:= nAnterior

//-- Liga/Desliga botoes
Tr030OnOff(.F.)

Return lREt


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fMoveToList   ³ Autor ³Emerson Grassi    ³ Data ³ 30/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Move Funcionario para  ListBox                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fMoveToList(lTodos)                                        ³±±
±±³          ³            lTodos         .T. move Todos os Funcionarios.  ³±±
±±³          ³                           .F. move Funcinario Atual.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Trmm030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static function fMoveToList(lTodos,aVetor)
Local aSaveArea	:= GetArea()
Local nPosicao	:= 0
Local nInicio	:= 0
Local nFim		:= 0
Local nRec		:= 0
Local nRecno	:= 0
Local lRet		:= .T.
Local nListN	:= o1Lbx:nAt

//-- Se Nao Existirem elementos no GetDados nao Move Nada
If Len(aTr1Rec)==0
   Return lRet
Endif

Default lTodos:=.F.

//-- Determina a Abrangencia
If lTodos
   //-- Exibe Mensagem de Aviso
   If !ApMsgYesNo( OemtoAnsi(STR0020),OemtoAnsi(STR0016) ) // ##" Desfazer Escolha de Funcionarios e Digitacao de Notas e Presencas? " ##
      Return lRet
   Endif
   nFim		:= Len(aCols)
   nInicio	:= 1
    //-- Implementa Regua somente para movimentacao coletiva
   ProcRegua(nFim)
Else
   nPosicao:=nInicio:=nFim:=n
Endif

dbSelectArea(cTr1Alias)

//--Marca Funcionarios de Acordo com a Abrangencia (Todos ou especifico)

For nRec:=nInicio To nFim
	(cTr1Alias)->(dbGoto(aTr1Rec[nRec,3]))
    //-- Incrementa Regua somente para movimentacao coletiva
    If lTodos
       IncProc()
    Endif
    Tr030Marca(@aVetor, nRec, .F.)
    dbSelectArea(cTr1Alias)
Next nRec

// Elimina os Elementos Escolhidos do array aCols do GetDados
If lTodos
    //-- Cria 1 Elemento vazio no GetDados
  	aCols:={Aclone(aColsVazio)}
	//-- Elimina o array de posicionamento dos registros no ListBox(TR1)
	aTr1Rec:={}

Else
	//-- Retira da GetDados
	If (Len(aCols)-1)>0
		Adel(aCols,nPosicao)
		ASize(aCols,Len(aCols)-1)
	Else
	    //-- Cria 1 Elemento vazio no GetDados
  	    aCols:={Aclone(aColsVazio)}
	Endif
	//-- Elimina Elemento do array de posicao dos registros no ListBox(TR1)
	Adel(aTr1Rec,nPosicao)
	ASize(aTr1Rec,Len(aTr1Rec)-1)
Endif

o1Lbx:nAt:=nListN
o1Lbx:Refresh(.T.)

n:=1
OGET:OBROWSE:NLEN:=Len(aCols)
oGet:oBrowse:Refresh()

RestArea(aSaveArea)

//-- Liga/Desliga botoes
Tr030OnOff(.T.)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr030Marca    ³ Autor ³Emerson Grassi    ³ Data ³ 30/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca/Desmarca Funcionario                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr030Marca()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Trmm030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr030Marca(aVetor,nRec,lAdiciona)
Local aArea	  := GetArea()
Local cAliasQry := GetNextAlias()
Local ctesteTableName := oTmpTabFO1:GetRealName()
Local cSql
Local nIndice

Local nRecTr1Alias := 0

If lAdiciona
	If aVetor[nRec][1] == o1Ok
		aVetor[nRec][1] := oNo
	Else
		aVetor[nRec][1] := o1Ok
	EndIf

	cSQL := " SELECT * FROM " + ctesteTableName
	cSql += " 		WHERE  "
	cSql += " 		TR1_FILIAL  = '" + aVetor[nRec,2] + "' and "
	cSql += " 		TR1_MAT     = '" + aVetor[nRec,3] + "' and "
	cSql += " 		TR1_NOME    = '" + aVetor[nRec,4] + "' and "
	cSql += " 		TR1_CC      = '" + aVetor[nRec,5] + "' and "
	cSql += " 		TR1_DESCCC  = '" + aVetor[nRec,6] + "' and "
	cSql += " 		TR1_FUNCAO  = '" + aVetor[nRec,7] + "' and D_E_L_E_T_ = '' "

	//COM EMBEDED  NAO FUNCIONA A CONSULTA NA TABELA TEMPORARIA ...POR ISTO USAMOS DBUSEAREA
	DbUseArea( .T.,"TOPCONN",TCGenQry(,,ChangeQuery(cSQL)),cAliasQry,.F.,.T. )

	If (cAliasQry)->(!Eof())
		(cTr1Alias)->( DbGoTo(   (cAliasQry)->(R_E_C_N_O_)     ) )

		RecLock(cTr1Alias,.F.,.T.)

		If aVetor[nRec][1] == o1Ok
			(cTr1Alias)->(TR1_MARCA) := 1//IIF((cTr1Alias)->(TR1_MARCA)==1,2,1)
		Else
			(cTr1Alias)->(TR1_MARCA) := 2
		EndIf

		(cTr1Alias)->(MsUnlock())
		nRecTr1Alias := (cTr1Alias)->(Recno())//somente para este caso o retorno sera utilizado

	EndIf

	(cAliasQry)->(DbCloseArea())

Else
    //remove da lista do grid da direita(de selecionados)
	nIndice := Ascan(aVetor,{|x| (cTr1Alias)->(TR1_FILIAL) = x[2]  .and.  (cTr1Alias)->(TR1_MAT) = x[3] .and.   ;
	                             (cTr1Alias)->(TR1_NOME)   = x[4]  .and.  (cTr1Alias)->(TR1_CC)  = x[5] .and.  (cTr1Alias)->(TR1_DESCCC)= x[6] })

	If nIndice > 0
		If aVetor[nIndice][1] == o1Ok
			aVetor[nIndice][1] := oNo
		Else
			aVetor[nIndice][1] := o1Ok
		EndIf

		RecLock(cTr1Alias,.F.,.T.)

		If aVetor[nIndice][1] == o1Ok
			(cTr1Alias)->(TR1_MARCA) := 1
		Else
			(cTr1Alias)->(TR1_MARCA) := 2
		EndIf

		(cTr1Alias)->(MsUnlock())

	EndIf
EndIf

RestArea(aArea)

Return nRecTr1Alias

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr030NMostra  ³ Autor ³Emerson Grassi    ³ Data ³ 30/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna array c/campos que nao serao mostrados na Getdados.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr030NMostra()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Trmm030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr030NMostra()
Local aSaveArea	:= GetArea()
Local aMostrar 	:= {"RA3_FILIAL","RA3_MAT","RA3_XNOME"}
Local aNMostrar	:= {}

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("RA3")
While ! Eof() .and. (SX3->X3_ARQUIVO == "RA3")
    If Ascan(aMostrar,Upper(Trim(x3_campo))) == 0
		Aadd(aNMostrar,Upper(Trim(x3_campo)))
	Endif
	dbSkip()
EndDo

RestArea(aSaveArea)

Return aNMostrar

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³26/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³TRMM030                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function MenuDef()

 Local aRotina := {	{ STR0001,'PesqBrw'		, 0,1,,.F.},;	//"Pesquisar"
						{ STR0003,'Tr030Sol'	, 0,6},;	//"Solicitar"
						{ STR0023,'Tr030Exc'	, 0,5}}	//"Excluir"


Return aRotina
