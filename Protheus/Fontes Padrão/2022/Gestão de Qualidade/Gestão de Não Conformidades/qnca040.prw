
#Include "TOTVS.CH"
#Include "PROTHEUS.CH"
#INCLUDE "QNCA040.CH"
#include "AP5MAIL.CH"
#include "DBTREE.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QNCA040  ³ Autor ³ Aldo Marini Junior    ³ Data ³ 27.12.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastramento de Ocorrencias/Nao-conformidades             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aldo        ³19/02/02³ ---- ³ Inclusao do ponto de entrada "QNCFNCBT"  ³±±
±±³Eduardo S.  ³01/10/02³ ---- ³ Alterado para permitir a modificacao das ³±±
±±³            ³        ³      ³ descricoes das etapas do plano de acao.  ³±±
±±³            ³        ³      ³ Alterado para enviar email para o usuario³±±
±±³            ³        ³      ³ originador quando (Nao Procede/Cancelada)³±±
±±³Eduardo S.  ³03/10/02³015621³ Alterado para enviar email para o respon-³±±
±±³            ³        ³      ³ savel da FNC na exclusao.                ³±±
±±³Eduardo S.  ³10/10/02³016412³ Alterado para baixar as etapas sugerindo ³±±
±±³            ³        ³      ³ Nao Procede para o Plano de Acao quando  ³±±
±±³            ³        ³      ³ a FNC for Nao Procede ou Cancelada.      ³±±
±±³Eduardo S.  ³01/11/02³059257³ Alteracao na opcao "Muda Selecao" para   ³±±
±±³            ³        ³      ³ apresentar 6 opcoes de filtro.           ³±±
±±³Eduardo S.  ³01/11/02³ Melh ³ Alterado para permitir anexar mais de um ³±±
±±³            ³        ³      ³ documento por FNC.                       ³±±
±±³Eduardo S.  ³10/01/03³ xxxx ³ Alterado para permitir pesquisar usuarios³±±
±±³            ³        ³      ³ entre filiais na consulta padrao.        ³±±
±±³Eduardo S.  ³03/02/03³Ficha ³ Alterado para verificar a existencia do  ³±±
±±³            ³        ³      ³ diretorio de documentos anexos.          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function MenuDef(lRotina)
Local cFilPend := GETMV("MV_QNCPFNC")
Local aRotAdic := {}
Default lRotina := .F.
        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametro para definir se havera o retorno para um novo cadastro quando a opcao   ³
//³ for de inclusao. 1-Abrira novamente tela de Inclusao 2-Retorno para mbrowse       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nOpcInclui := If(lRotina,If(GETMV("MV_QNCIOPC",.F.,1)==1 .Or. !QI2->(DbSeek(xFilial("QI2"))),3,4),3) 

Private aRotina := {}


aAdd(aRotina, { STR0001 , "AxPesqui"  , 0 , 1,,.F.} )  //"Pesquisar"
aAdd(aRotina, { STR0002 , "QNC040Alt" , 0 , 2} )  //"Visualizar" 
aAdd(aRotina, { STR0003 , "QNC040Alt", 0 , nOpcInclui} )  //"Incluir"
aAdd(aRotina, { STR0004 , "QNC040Alt" , 0 , 4} )  //"Alterar"
aAdd(aRotina, { STR0005 , "QNC040Alt" , 0 , 5} )  //"Excluir"
aAdd(aRotina, { STR0045 , "QNC040Rev" , 0 , 6} )  //"Gera Revisao"
If cFilPend == "N"
	aAdd(aRotina, { STR0036 , "QNC040Sel" , 0 , 3,,.F.} )  //"Muda Selecao"
Endif                                                    
aAdd(aRotina, { STR0039 , "QNC040Foll" , 0 , 6} )  // "Follow-UP"
aAdd(aRotina, { STR0041 , "QNCA040IMP" , 0 , 6,,.F.} )  // "Imprime"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada - Adiciona rotinas ao aRotina       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QNC040BUT")
	aRotAdic := ExecBlock("QNC040BUT", .F., .F.)
	If ValType(aRotAdic) == "A" .and. Len(aRotAdic) > 0  
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	Else
		aAdd(aRotina, { STR0040 , "QNC040Legen" ,0, 6,,.F.} )  // "Legenda"
	EndIf
Else
	aAdd(aRotina, { STR0040 , "QNC040Legen" ,0, 6,,.F.} )  // "Legenda"
EndIf


Return aRotina
 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNCA040   ºAutor  ³Microsiga           º Data ³  10/16/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QNCA040

Local cFilPend := GETMV("MV_QNCPFNC")
Local aRotAdic     
Local aCorAdd := {}
Local x       := 0 
Local aCoresNew :={}
Local aUsrMat    := QNCUSUARIO()
Local nCor	  := 0

Private cExpFilt := ""
Private lFunFNC := .F.
Private nMudaSel:= If(cFilPend=="S",5,1)
Private aUsuarios	:= {}
Private cFilDest := cFilAnt
Private cFilMat  := cFilAnt


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada - Exibir MSGs ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ExistBlock( "QNCABFNC" )
	ExecBlock( "QNCABFNC", .f., .f.)
Endif
cCadastro := OemToAnsi(STR0006)  //"Cadastro de Ocorrencias/Nao-conformidades"

aCores := { { 'QI2->QI2_OBSOL=="S"'    , 'BR_PRETO'},;
			{ '!Empty(QI2->QI2_CONREA)', 'ENABLE' },;
            { 'Empty(QI2->QI2_CONREA) .And. !Empty(QI2->QI2_CODACA) .And. !Empty(QI2->QI2_REVACA)', 'BR_AMARELO' },;
			{ 'Empty(QI2->QI2_CONREA)', 'DISABLE' } }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para adicionar novos lads ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QNC40FLG")
	aCorAdd := ExecBlock("QNC40FLG", .F., .F.)
	If !Empty(aCorAdd)
		For x := 1 to len(aCorAdd)
	   		Aadd(aCores,{aCorAdd[X][1],aCorAdd[X][2]})
	   	Next	
	Endif   	
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para alterar cores do Browse do Cadastro    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QNC40COR")
	aCoresNew := ExecBlock("QNC40COR",.F.,.F.,{aCores})
	If ValType(aCoresNew) == "A"
		aCores := aCoresNew
	EndIf
EndIf 
            
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
Private aRotina := MenuDef(.T.)

//Variaveis para armazenar o aHeader e Acols dos anexos
Private aHeadAne := {} 
Private aColAnx  := {}
Private cFilOrig := cMatFil := aUsrMat[2]

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'QI2' )
oBrowse:SetDescription( cCadastro )

If cFilPend == "S"
	MsgRun( OemToAnsi( STR0037 ), OemToAnsi( STR0038 ), { || QNC040FIL() } ) //"Selecionando Ficha de Ocorrencias/Nao-Conformidades" ### "Aguarde..."
Endif

DbselectArea("QI2")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada criado para mudar o Filtro ou realizar alguma tarefa especifica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QNCAP01")
	cExpFilt:= ExecBlock("QNCAP01", .f., .f.)
	IF !Empty(cExpFilt)
		oBrowse:SetFilterDefault(cExpFilt)
	Endif	
EndIf  
for nCor := 1 to len(aCores)
	oBrowse:AddLegend( aCores[nCor,1],aCores[ncor,2]) 
Next nCor

//mBrowse( 6, 1,22,75,"QI2",,,,,,aCores)

DbselectArea("QI2")
Set Filter To
dbSetOrder(1)
dbGoTop()
oBrowse:Activate()

If Select("QNSXE") > 0
	QNSXE->(dbCloseArea())
Endif

If Select("QNSXF") > 0
	QNSXF->(dbCloseArea())
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QNC040Sel ³ Autor ³Aldo Marini Junior       ³ Data ³ 11/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Filtra os Lancamtos Pendentes/Baixados de FNC                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QNC040Sel                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QNCA040                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNC040Sel

Local oDlg
Local oMudaSel
Local nMudaAux:= nMudaSel
Local nOpc1   := 0
Local lFecha  := .F.

dbSelectArea("QI2")

DEFINE MSDIALOG oDlg FROM 201,101 TO 380,360 TITLE OemToAnsi(STR0036) PIXEL // "Muda Selecao"

@ 003,003 TO 070,126 LABEL OemToAnsi(STR0087) OF oDlg PIXEL // "Situacao"

@ 011,008 RADIO oMudaSel VAR nMudaSel ITEMS;
					OemToAnsi(STR0085),; //"Todas"
					OemToAnsi(STR0033),; //"Ficha Baixada"
					OemToAnsi(STR0034),; //"Ficha pendente com Plano Acao"
					OemToAnsi(STR0035),; //"Ficha pendente sem Plano Acao"
					OemToAnsi(STR0086),; //"Ambas Pendencias"
					OemToAnsi(STR0079) ; //"Ficha com Revisao Obsoleta"
			  3D SIZE 110,008 OF oDlg PIXEL

DEFINE SBUTTON FROM 074,070 TYPE 1 ENABLE OF oDlg ;
			ACTION (nOpc1 := 1,lFecha:= .T.,oDlg:End())

DEFINE SBUTTON FROM 074,100 TYPE 2 ENABLE OF oDlg ;
			ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED VALID lFecha

If nOpc1 == 1
	MsgRun( OemToAnsi( STR0037 ), OemToAnsi( STR0038 ), { || QNC040FIL() } ) //"Selecionando Ficha de Ocorrencias/Nao-Conformidades" ### "Aguarde..."
Else
	nMudaSel:= nMudaAux
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QNC040FIL  ³ Autor ³Aldo Marini Junior      ³ Data ³ 11/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Filtra os Lactos Pendentes                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QNC040FIL                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QNCA040                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNC040FIL

Local cFiltro:= ' '

If Type("nMudaSel") = "U"
	Return .T.
Endif

If nMudaSel == 1
	cFiltro := ' '
	If Empty( cExpFilt )
		oBrowse:SetFilterDefault('.T.')
	Else
		oBrowse:SetFilterDefault(cExpFilt )
	Endif
ElseIf nMudaSel == 2 // Baixada
	cFiltro:= '!Empty(QI2->QI2_CONREA)'
	If Empty( cExpFilt )
		oBrowse:SetFilterDefault('!Empty(QI2->QI2_CONREA)')
	Else
		oBrowse:SetFilterDefault('!Empty(QI2->QI2_CONREA) .and. '+ cExpFilt )
	EndiF
ElseIf nMudaSel == 3 // Pendente com Plano
	cFiltro:= 'Empty(QI2->QI2_CONREA) .And. !Empty(QI2->QI2_CODACA) .And. !Empty(QI2->QI2_REVACA)'
	If Empty( cExpFilt )
		oBrowse:SetFilterDefault('Empty(QI2->QI2_CONREA) .And. !Empty(QI2->QI2_CODACA) .And. !Empty(QI2->QI2_REVACA)')
	Else
		oBrowse:SetFilterDefault('Empty(QI2->QI2_CONREA) .And. !Empty(QI2->QI2_CODACA) .And. !Empty(QI2->QI2_REVACA) .and. '+ cExpFilt )
	EndiF
ElseIf nMudaSel == 4 // Pendente sem Plano
	cFiltro:= 'Empty(QI2->QI2_CONREA) .And. Empty(QI2->QI2_CODACA) .And. Empty(QI2->QI2_REVACA)'
	If Empty( cExpFilt )
		oBrowse:SetFilterDefault('Empty(QI2->QI2_CONREA) .And. Empty(QI2->QI2_CODACA) .And. Empty(QI2->QI2_REVACA)')
	Else
		oBrowse:SetFilterDefault('Empty(QI2->QI2_CONREA) .And. Empty(QI2->QI2_CODACA) .And. Empty(QI2->QI2_REVACA)  .and. '+ cExpFilt )
	EndiF
ElseIf nMudaSel == 5 // Ambas Pendencias
	cFiltro:= 'Empty(QI2->QI2_CONREA)' 
	If Empty( cExpFilt )
		oBrowse:SetFilterDefault('Empty(QI2->QI2_CONREA)')		
	Else
		oBrowse:SetFilterDefault('Empty(QI2->QI2_CONREA)  .and. '+ cExpFilt )
	EndiF
ElseIf nMudaSel == 6 // Obsoleto
	cFiltro:= 'QI2->QI2_OBSOL == "S"'
	If Empty( cExpFilt )
		oBrowse:SetFilterDefault('QI2->QI2_OBSOL == "S"')		
	Else
		oBrowse:SetFilterDefault('QI2->QI2_OBSOL == "S"  .and. '+ cExpFilt )
	EndIf
EndIf

dbSelectArea("QI2")
dbClearFil()
If Empty(cFiltro)
	If Type("cExpFilt") == "C" .And. !Empty( cExpFilt )
		Set Filter To &(cExpFilt)
	Endif
Else
	If Type("cExpFilt") == "C" .And. !Empty( cExpFilt )
		cFiltro += " .And. " + cExpFilt
	Endif
	Set Filter to &(cFiltro)
Endif

Return Nil

Function QNC040Top()
Return xFilial("QI2")+Str(Year(dDataBase),4)

Function QNC040Bot()
Return xFilial("QI2")+Str(Year(dDataBase),4)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC040Alt ³ Autor ³ Aldo Marini Junior    ³ Data ³ 27/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa generico para alteracao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC040Alt(ExpC1,ExpN2,ExpN3)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao devolvida pela funcao                        ³±±
±±³          ³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN2 = Numero do registro                                 ³±±
±±³          ³ ExpL1 = Logico definindo se ira apagar os arquivos temp.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNC040Alt(cAlias,nReg,nOpcF,lPreenche,aCampos)

Local nOpcao	 := 0
Local aPosEnch	 := {}
Local aArqFNC    := {}
Local aUsrMat    := QNCUSUARIO()
Local lErase     := .T.
Local cChaveQI2  := QI2->QI2_FILIAL+QI2->QI2_FNC
Local nOrdQI2    := 0
Local nRegQI2    := 0
Local lAutorizado:= .T.
Local aButtons   := {}
Local lMvQncAEta := If(GetMv("MV_QNCAETA",.F.,"2") == "1",.T.,.F.) // Define se usuario pode alterar a etapa
Local cDelAnexo  := GetMv("MV_QDELFNC",.F.,"1") // "Apagar Documentos Anexos no Diretorio Temporario"
Local cStatus    := " "
Local aMemos     := {{"QI2_DDETA"  ,"QI2_MEMO1"},;	// Descricao Detalhada
					 {"QI2_COMEN"  ,"QI2_MEMO2"},;	// Comentarios
					 {"QI2_DISPOS" ,"QI2_MEMO3"},;	// Acao Imediata/Disposicao
				 	 {"QI2_MOTREV" ,"QI2_MEMO4"},;	// Motivo da Revisao  
				 	 {"QI2_JUSTIF" ,"QI2_MEMO5"}}	// Justificativa Não Procede 

Local lQN040MEM := Existblock ("QN040MEM")
Local cChaveRev	:=	QI2->QI2_FILIAL+QI2->QI2_FNC+QI2->QI2_REV
Local lUsrAlter := If(GetMv("MV_QALTFNC",.F.,"2")=="1",.T.,.F.)	// 1=SIM 2=NAO
Local i
Local nI
Local iT              
Local nT
Local aColAnx  :={}     
Local lExclui  := .T.
Local aEtapa   := {OemtoAnsi(STR0107),OemToAnsi(STR0108),OemToAnsi(STR0109),OemToAnsi(STR0110),OemToAnsi(STR0111)}	// "Registrada" ### "Em Analise" ### "Procede" ### "Nao Procede" ### "Cancelada"
Local lTMKPMS  := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
Local lSigilo  := .T.
Local nSpacACA := TamSX3("QI2_CODACA")[1]
Local nSpaREVA := TamSX3("QI2_REVACA")[1]

Local aStruQI2
Local nX
Local aCamposQI2 := {}
Local cModeQAD := FWModeAccess("QAD")
Local cModeQAA := FWModeAccess("QAA")
Local cBarRmt  := IIF(IsSrvUnix(), "/", "\")

Default lPreenche := .F. // Indica que e uma integracao e que alguns campos serao preenchidos de  forma  automatica
Default aCampos   := {}				 		  
               
Private aMemUsr  := {}
Private __lQNSX8 := .F.
Private aQNQI2   := {}
Private aQNQI3   := {}
Private aAliasQN := {}
Private lSX3Seq  := .F.
				 	  
Private cQPathFNC:= QA_TRABAR(Alltrim(GetMv("MV_QNCPDOC")))
Private aQPath   := QDOPATH()
Private cQPathTrm:= aQPath[3]

Private nQaConPad:= 1
Private lApelido := aUsrMat[1]
Private cMatFil  := aUsrMat[2]
Private cMatCod  := aUsrMat[3]
Private cMatDep  := aUsrMat[4]

Private cFileTrm := Space(1)
Private nOpc     := nOpcF

Private bCampo   := { |nCPO| Field( nCPO ) }
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aTELA[0][0]
Private aGETS[0]
Private aHeader[0]
Private Continua:=.F.
Private cFilOrig := cMatFil
Private cArqDele := ""

Private oDlg
Private lAcaoNova := .F.
Private cQI2_Cod  := Space(10)
Private cQI2_Rev  := Space(2)
Private nTamMotR  := TamSX3("QI2_MEMO4")[1]
Private cTitMotR  := TitSX3("QI2_MEMO4")[2]
Private cOldFnc   := " "
Private cOldRev   := " "
Private lRevisao  := .F.
Private cQI3_Cod  := " "
Private cQI3_Rev  := " "
Private lAltEta   := .F.
Private cMail	  := ""
Private lMvFNCPLN := If(GetMv("MV_QFNCPLN",.F.,"2")=="1",.T.,.F.)	// 1=SIM 2=NAO Define se e obrigatorio a criacao do Plano de Acao na criacao da FNC com Status Procede. 
Private lVisPlano := .T.
Private aMsSize	  := MsAdvSize()
Private aObjects  := {{ 100, 100, .T., .T., .T. }}
Private aInfo     := { aMsSize[ 1 ], aMsSize[ 2 ], aMsSize[ 3 ], aMsSize[ 4 ], 4, 4 } 
Private aPosObj   := MsObjSize( aInfo, aObjects, .T. , .T. )     
Private lWhenTp   :=.T.
Private cMotivo   := ""
Private cFilDest  := cFilAnt
Private cFilMat   := IIF(Empty(cMatFil), cFilAnt, cMatFil) //cMatFil: filial do usuario logado obtido através do Login Usr.(QAA_LOGIN) logado +- linha 172

If Valtype(lPreenche) <> "L"  // Forco os dados para default garantindo a consistencia deles
	lPreenche := .F.
	aCampos := {}
EndIf                       

If nOpc == 3
	INCLUI := .T.
	If GetMv("MV_QTMKPMS",.F.,1) == 2 .Or. GetMv("MV_QTMKPMS",.F.,1) == 4
		Alert(STR0117) // "Integracao MV_QTMKPMS ativada, deve ser utilizado o modulo Call Center para inclusão de Chamado/Atendimento".
		Return
	Endif 
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para adicao de campos memo do usuario       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lQN040MEM
	If ValType (aMemUser := ExecBlock( "QN040MEM", .F., .F. ) ) =="A" 
		AEval( aMemUser, { |x| AAdd( aMemos, x ) } ) 	
	EndIf 	
EndIf 
 
If ExistBlock ("QN040ALT")
	Execblock("QN040ALT",.F.,.F.,{nOpc})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Procura a funcao de numeracao sequencial parecido com SXE/SXF                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(GetSX3Cache("QI2_FNC","X3_CAMPO"))
	If "GETQNCNUM" $ GetSX3Cache("QI2_FNC","X3_RELACAO")
		lSX3Seq  := .T.
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quando este cadastro for acessado via opcoes "Pendencias" nao sera apagado os     ³
//³ anexo temporarios.                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cAlias == "PEN"
	cAlias := "QI2"
	lErase := .F.
Endif
	
If !Right( cQPathFNC,1 ) == cBarRmt
	cQPathFNC := cQPathFNC + cBarRmt
Endif

If !Right( cQPathTrm,1 ) == cBarRmt
	cQPathTrm := cQPathTrm + cBarRmt
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi passado o parametro de Geracao de Revisao.               ³
//³ O nOpc = 6 do aRotina esta sendo utilizada para Geracao de Revisao       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 8
	lRevisao := .T.
	INCLUI   := .F.
	nOpc     := 3
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi passado o parametro de Visualizacao Geracao de Revisao.  ³
//³ O nOpc = 6 do aRotina esta sendo utilizada para Geracao de Revisao       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 9
	lVisPlano := .F.
	INCLUI   := .F.
	nOpc     := 2
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Usuario Logado esta cadastrado no Cad.Usuarios/Responsaveis atraves   ³
//³ do Apelido cadastro no Configurador                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lApelido
	Help( " ", 1, "QD_LOGIN") // "O usuario atual nao possui um Login" ### "cadastrado igual do configurador."
	Return 1
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o diretorio para gravacao do Docto Anexo Existe. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 6
	nHandle := fCreate(cQPathFNC+"SIGATST.CEL")
	If nHandle <> -1  // Consegui criar e vou fechar e apagar novamente...
		fClose(nHandle)
		fErase(cQPathFNC+"SIGATST.CEL")
	Else
	  Help("",1,"QNCDIRDCNE") // "O Diretorio definido no parametro MV_QNCPDOC" ### "para o Documento Anexo nao existe."
	  Return 3
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa campos MEMO                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For i:=1 to Len(aMemos)
	cMemo := aMemos[i][2]
	If Type(cMemo) <> "M"
		cMemo := "QI2->"+cMemo
	EndIf
	If GetSx3Cache(cMemo, "X3_CONTEXT") == "V"
		If ExistIni(cMemo)
			&cMemo := InitPad(GetSx3Cache(cMemo,"X3_RELACAO"))
		Else
			&cMemo := ""
		EndIf
	Else
		If ExistIni(cMemo) .And. Empty(&cMemo) .And. nOpc <> 3
			Reclock("QI2", .F.)
			&cMemo := InitPad(GetSx3Cache(cMemo,"X3_RELACAO"))
			QI2->(MsUnlock())
		EndIf
	EndIf
Next i

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona na Ordem 2 para Ocorrencias/Nao-conform. A ordem 1(um)   ³
//³ sera usada paro o Plano de Acao                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QI9")
dbSetOrder(2)

dbSelectArea("QI2")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos campos de Bancos de Dados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3 	//-- Inclusao

	If lRevisao
		For nI := 1 To FCount()
			M->&(Eval(bCampo,nI)) := FieldGet(nI)
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega os registros dos sub-Cadastros               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		M->QI2_FILMAT := cMatFil
		M->QI2_MAT    := cMatCod
		M->QI2_MATDEP := cMatDep
		M->QI2_REV    := StrZero(Val(M->QI2_REV)+1,2)
		M->QI2_REGIST := dDataBase
		M->QI2_OCORRE := dDataBase
		M->QI2_CONPRE := dDatabase+30
		M->QI2_CONREA := Ctod("  /  /  ")
		M->QI2_OBSOL  := "N"
		M->QI2_STATUS := "1"	// "1"-Registrada
		M->QI2_CODACA := Space(nSpacACA)
		M->QI2_REVACA := Space(nSpaREVA)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa as descricoes dos campos memos            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		INCLUI := .F.	// Seta .F. para inicializar os campos memos com a revisao anterior
		aStruQI2 := FWFormStruct(3, "QI2",, .F.)[3]
		For nX := 1 To Len(aStruQI2)
			If GetSx3Cache(aStruQI2[nX,1], "X3_TIPO") == "M"
				&("M->"+AllTrim(aStruQI2[nX,1])) := InitPad(GetSx3Cache(aStruQI2[nX,1], "X3_RELACAO"))
			ElseIf aScan(aMemos,{|X| X[1] == AllTrim(aStruQI2[nX,1]) }) > 0 .And. ;
				ALLTRIM(UPPER(aStruQI2[nX,1])) <> "QI2_MEMO4"
				&("M->"+AllTrim(aStruQI2[nX,1])) := Space(6)
			Endif
			If ALLTRIM(UPPER(aStruQI2[nX,1])) == "QI2_MEMO4"
				dbSelectArea("SX3")
					dbSetOrder(2)
					If dbSeek(aStruQI2[nX,1])
						cTitMotR := X3DescriC(aStruQI2[nX,1])
					EndIf
				nTamMotR := GetSx3Cache(aStruQI2[nX,1], "X3_TAMANHO")
			Endif
		Next nX
		
		dbSelectArea("QI2")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta tela de edicao do Motivo da Revisao            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !QNCEDMOTREV(nOpc,@M->QI2_MEMO4,cTitMotR,nTamMotR)
			Return 3
		Endif
		
	Else

		For nI := 1 To FCount()
			M->&(Eval(bCampo,nI)) := FieldGet(nI)
			lInit := .F.

			If ( ExistIni(Eval(bCampo,nI)) )
				lInit := .T.
				M->&(Eval(bCampo,nI)) := InitPad(GetSx3Cache(Eval(bCampo,nI),"X3_RELACAO"))
				If ( ValType(M->&(Eval(bCampo,nI))) == "C" )
					M->&(Eval(bCampo,nI)) := Padr(M->&(Eval(bCampo,nI)), GetSx3Cache(Eval(bCampo,nI),"X3_TAMANHO"))
				Endif
				If ( M->&(Eval(bCampo,nI)) == NIL )
					lInit := .F.
				EndIf
			EndIf
			If ( ! lInit )
				If ( ValType(M->&(Eval(bCampo,nI))) == "C" )
					M->&(Eval(bCampo,nI)) := Space(Len(M->&(Eval(bCampo,nI))))
				ElseIf ( ValType(M->&(Eval(bCampo,nI))) == "N" )
					M->&(Eval(bCampo,nI)) := 0
				ElseIf ( ValType(M->&(Eval(bCampo,nI))) == "D" )
					M->&(Eval(bCampo,nI)) := Ctod("  /  /  ","DDMMYY")
				ElseIf ( ValType(M->&(Eval(bCampo,nI))) == "L" )
					M->&(Eval(bCampo,nI)) := .F.
				EndIf
			EndIf
		Next
	Endif
	
	M->QI2_FILIAL := xFilial("QI2")
	M->QI2_ORIGEM := "QNC"
	If len(M->QI2_FNC) == 15
		M->QI2_ANO	  := SubStr(M->QI2_FNC,12,4)
	Else
		M->QI2_ANO	  := SubStr(M->QI2_FNC,7,4) 
	Endif

	M->QI2_OBSOL  := "N"
	
	// Indica se serao preenchidos alguns campos previamente
	// ATENCAO ULTILIZAR SOMENTE EM INTEGRACOES
	If lPreenche
		Q040Preenche(aCampos)
	EndIf

Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se FNC eh Sigilosa. Somente Responsavel e Digitador podem Manipular  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If QI2->QI2_SIGILO == "1"
		If Existblock("QNC40SIG") //Ponto de Entrada para deixar que uma FNC sigilosa seja visualizada por alguns usuarios
			lSigilo := Execblock("QNC40SIG",.F.,.F.,{cMatFil,cMatCod})
		Endif	
		If ! (cMatFil+cMatCod == QI2->QI2_FILMAT+QI2->QI2_MAT .or. ;
		   	  cMatFil+cMatCod == QI2->QI2_FILRES+QI2->QI2_MATRES) .And. lSigilo
			MsgAlert(OemToAnsi(STR0107)+Chr(13)+;		// "Ficha de Ocorrencias / Nao-conformidades sigilosa"
			OemToAnsi(STR0108 + ;		//"Somente o usuario digitador ("
			AllTrim(Posicione("QAA",1, QI2->QI2_FILMAT+QI2->QI2_MAT,"QAA_NOME")) + ;
			STR0109 + ; // ") e/ou responsavel ("
			AllTrim(Posicione("QAA",1, QI2->QI2_FILRES+QI2->QI2_MATRES,"QAA_NOME"))+ STR0110 ))	// ") terão acesso aos dados."

			Return 3
		Endif
	Endif

	cQI3_Cod := QI2->QI2_CODACA
	cQI3_Rev := QI2->QI2_REVACA

	cOldFnc  := QI2->QI2_FNC
	cOldRev  := QI2->QI2_REV
	
	nOrdQI2 := QI2->(IndexOrd())
	nRegQI2 := QI2->(Recno())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe revisoes novas entao forca virar Visualizacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	QI2->(dbSetOrder(2))
    If dbSeek(cChaveQI2+QI2->QI2_REV)
    	QI2->(dbSkip())
		While !Eof() .And. QI2->QI2_FILIAL+QI2->QI2_FNC == cChaveQI2
			lAutorizado := .F.
			nOpc := 2
			QI2->(dbSkip())
		Enddo		
    Endif    

	dbGoTo(nRegQI2)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso seja Exclusao verifica se existe revisoes anteriores ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 5 .And. QI2->QI2_OBSOL <> "S"
        M->QI2_REV := QI2->QI2_REV
	    If dbSeek(cChaveQI2)
			While !Eof() .And. QI2->QI2_FILIAL+QI2->QI2_FNC == cChaveQI2
                If QI2->QI2_REV <> M->QI2_REV
                	lRevisao := .T.
                	Exit
				Endif
				dbSkip()
			Enddo
		Endif
	Endif
	
	dbSetOrder(nOrdQI2)
	dbGoTo(nRegQI2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o usuario corrente podera fazer manutencoes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc <> 2 .And. nOpc <> 5		// Visualizar ou Excluir
		// Ponto de entrada para liberar alteracao e inclusao de Plano de Acao na FNC por usuarios que nao sejam o Responsavel pela FNC
		If ExistBlock('QN040AUT')
			lAutorizado := ExecBlock('QN040AUT',.F., .F.,{cMatFil,cMatCod})
		Else
			If (( QI2->QI2_STATUS == "1" .And. cMatFil+cMatCod <> QI2->QI2_FILMAT+QI2->QI2_MAT .And. cMatFil+cMatCod <> QI2->QI2_FILRES+QI2->QI2_MATRES) .Or. ;
				( QI2->QI2_STATUS <> "1" .And. cMatFil+cMatCod <> QI2->QI2_FILRES+QI2->QI2_MATRES )) .AND. !lUsrAlter
				lAutorizado := .F.
				nOpc := 2
			Endif
			If nOpc == 4 .And. !Empty(QI2->QI2_CONREA)  //
				lAutorizado := .F.
				nOpc := 2
			Endif
		Endif		
	ElseIf nOpc == 5		// Excluir
		If ExistBlock("QNCDELFNC")
			lAutorizado := ExecBlock("QNCDELFNC", .F., .F.)
			If ValType(lAutorizado) <> "L"
				lAutorizado := cMatFil+cMatCod = QI2->QI2_FILMAT+QI2->QI2_MAT .OR. cMatFil+cMatCod = QI2->QI2_FILRES+QI2->QI2_MATRES
			Endif
		Else
			lAutorizado := cMatFil+cMatCod = QI2->QI2_FILMAT+QI2->QI2_MAT .OR. cMatFil+cMatCod = QI2->QI2_FILRES+QI2->QI2_MATRES
		Endif
		If ! lAutorizado .Or. QI2->QI2_STATUS <> "1"
			lAutorizado := .F.
			nOpc := 2
		Endif
    Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o usuario corrente podera alterar descricoes das etapas do Plano de Acao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcF == 4 .And. QI2->QI2_OBSOL <> "S" .And. lMvQncAEta
		If !lAutorizado
			If QN030VdAlt(QI2->QI2_FILIAL,QI2->QI2_CODACA,QI2->QI2_REVACA)
				lAltEta:= .T.
			EndIf
		EndIf
    EndIf

	If !lAutorizado
		If nOpc == 4 .And. !Empty(QI2->QI2_CONREA)
			MsgAlert(OemToAnsi(STR0030)+Chr(13)+;	// "Ficha de Nao-Conformidade ja baixada, impossivel alterar os Dados,"
						OemToAnsi(STR0022))				// "a Ficha de Nao-Conformidades sera apenas visualizada."
			nOpc := 2
		Else
			MsgAlert(OemToAnsi(STR0021)+Chr(13)+;	// "Usuario nao autorizado a fazer Manutencao nesta Ficha de Ocorrencias/Nao-conformidades,"
			OemToAnsi(STR0022))				// "a Ficha de Ocorrencias/Nao-conformidades sera apenas visualizada."
		   nOpc := 2
		Endif
	Endif
    
	FOR iT := 1 TO FCount()
	    M->&(EVAL(bCampo,iT)) := FieldGet(iT)
	NEXT i

	cFilDest := M->QI2_FILDEP
	cFilMat  := M->QI2_FILRES
	cFilOrig := M->QI2_FILORI	
	
	IF nOpc <> 2
		IF !SoftLock("QI2")
			Return 0
		Endif
	Endif
EndIf    

IF QIF->(MsSeek(M->QI2_FILIAL+M->QI2_FNC+M->QI2_REV)) 
	cAliasAnex 	:= "QIF"   	// Variaveis utilizadas em QncACols, QncAHead e 
	aCols 		:= {}		// QncGAnexo
	aHeader		:= {}
	nAColsAtu 	:= 0   
	nUsado		:= 0
Endif	

cStatus:= M->QI2_STATUS

cCadastro := OemToAnsi(STR0006)  //"Cadastro de Ocorrencias/Nao-conformidades"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia para processamento dos Gets                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aMsSize[7],000 TO aMsSize[6],aMsSize[5] OF oMainWnd Pixel

aPosEnch := {aPosObj[1,1],aPosObj[1,2],aPosObj[1,4],aPosObj[1,3]}  // ocupa todo o  espaço da janela

aStruQI2 := FWFormStruct(3, "QI2")[3]
For nX := 1 To Len(aStruQI2)
	If cNivel >= GetSx3Cache(aStruQI2[nX,1], "X3_NIVEL") .and. !(GetSx3Cache(aStruQI2[nX,1], "X3_BROWSE")  == "N" .and. aStruQI2[nX,1] $ "QI2_ANO|QI2_MEMO5|QI2_MEMO4") 
		Do Case
			Case !(aStruQI2[nX,1] $ "QI2_FILORI|QI2_FILDEP|QI2_DISPOS|QI2_DDETA|QI2_COMEN|QI2_ORIGEM|QI2_ANEXO|QI2_OBSOL|QI2_MOTREV|QI2_JUSTIF")
				aAdd(aCamposQI2, aStruQI2[nX,1])
			 Case aStruQI2[nX,1] $ "QI2_FILORI|QI2_FILDEP" .And. cModeQAD != "C"
				aAdd(aCamposQI2, aStruQI2[nX,1])
		EndCase
	EndIf
Next nX
FreeObj(aStruQI2)

nReg :=IIf(nReg==NIL,RecNo(),nReg)
nOpcao := EnChoice( cAlias, nReg, nOpc,,"CA",OemToAnsi(STR0007),aCamposQI2,aPosEnch )	//"Quanto …s altera‡”es?"
FreeObj(aCamposQI2)

If lVisPlano
	aAdd(aButtons,{"OBJETIVO"  , {|| QNC040ACAO()} , OemToAnsi( STR0015 ), OemToAnsi(STR0094) } )  //"Plano de Acao" //"Pl.Acao"
Endif

aAdd(aButtons,{"SDUPROP", {|| FQNCANEXO("QIF",nOpc,M->QI2_STATUS,@aColAnx) }, OemToAnsi( STR0016 ),OemToAnsi(STR0095) } )  //"Documento Anexo"  //"Doc.Anexo"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Visualizacao da Ordem de Servico caso esteja integrado com o MNT ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetMV("MV_NGMNTQN",.F.,"N") == "S"
	aAdd(aButtons,{"FORM", {|| MNTC040(M->QI2_NUMOS)}, OemToAnsi( STR0031 ),OemToAnsi("O.S.") } )  // "Ordem de Servico" 
Endif

If !INCLUI
	aAdd(aButtons,{"RELATORIO" , {|| QNCR030(QI2->(Recno()))} , OemToAnsi(STR0098), OemToAnsi(STR0099) } )  //"Imprime Follow-Up" //"Follow-Up"
EndIf

//Seta o dado do banco caso esteja vazio - DMANQUALI-1323
If Empty(M->QI2_MEMO4)
	M->QI2_MEMO4 := MSMM(QI2->QI2_MOTREV,80)
EndIf

If !Empty(M->QI2_MEMO4)
	aAdd(aButtons,{"NOTE", {|| QNCEDMOTREV(nOpc,@M->QI2_MEMO4,cTitMotR,nTamMotR)}, OemToAnsi( STR0057 ), OemToAnsi(STR0096) } )  // "Motivo da Revisao" //"Mot.Rev"
Endif

If (GetMv("MV_QTMKPMS",.F.,1) == 4)
	aAdd(aButtons,{"DISCAGEM"   , {|| QNC040TMK() }, OemToAnsi(STR0116), OemtoAnsi(STR0116) } ) 
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada criado para mudar os botoes da enchoicebar                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ExistBlock( "QNCFNCBT" )
	aButtons := ExecBlock( "QNCFNCBT", .f., .f., {nOpc,M->QI2_FNC,M->QI2_REV,aButtons} )
Endif

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
					{||If(Qnc040VldFNC(aGets,aTela,nOpc) .And. QNCAUTUSR(M->QI2_FILRESP,M->QI2_MATRES),(nOpcao := 1,oDlg:End()),) },;
					{||nOpcao := 3,lRet := Q040VTPMS(nOpcao,nOpc), If(lRet,oDlg:End(),) },,;
					aButtons )
//ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela) .And. QX10VldEmp(lIntGPE) .And. QA010VrCfg(.T.) .And. QAX010VLTP(nOpc) .and. Q070VUso(),(nOpcao:= 1,oDlg:End()),)},{|| oDlg:End()}) CENTERED	
If nOpcao == 1 //-- OK
	If nOpc == 3 .Or. nOpc == 4	// Inclusao ou Alteracao

		// Ponto de entrada chamado na geracao de uma nova revisao ou na alteracao do status da FNC para cancelada
		If (nOpc == 4 .And. M->QI2_STATUS == "5") .or.  (nOpc ==3 .And. lRevisao)
			nArQI2 := QI2->(Recno())
			IF ExistBlock( "QNCFNCOB" )
				ExecBlock( "QNCFNCOB", .f., .f.)
				dbSelectArea("QI2")
				QI2->(dbGoTo(nArQI2))
			Endif
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o arquivo de Acao Corretiva X FNC          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QNC040AAC(nOpcao,lAcaoNova,nOpc)	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava os dados										³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Qnc040Grava(bCampo,nOpc)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso o haja  integracao com o TMK atualiza a revisao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRevisao
			If QI2->QI2_ORIGEM == "TMK"
				QNCatuTMK(M->QI2_FNC,StrZero(Val(M->QI2_REV),2),StrZero(Val(M->QI2_REV)-1,2))
			EndIF
		EndIf

		If __lQNSX8 .and. aQNQI2[1][1] <> nil
			ConfirmeQE(aQNQI2)
		EndIf  
		
        IF Len(aColAnx) >= 1
			cAliasAnex 	:= "QIF"   	// Variaveis utilizadas em QncACols, QncAHead e 
			aCols 		:= aClone(aColAnx)  // FQNCANEXO
			aHeader		:= {}
			nAColsAtu 	:= 0        
			nUsado		:= 0
  			QNCGAnexo(nOpc,,aCols)
  		ENDIF	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se FNC nao procede ou Cancelado, Finaliza o Plano.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If M->QI2_STATUS $ "4,5" .And. !Empty(M->QI2_CONREA)         
			QNC040FinPl()
		EndIf
		
		aCampos := {} // Zero aCampos
		
		AAdd(aCampos,{QI2->QI2_FILIAL, QI2->QI2_FNC, QI2->QI2_REV})   // Retorno o aCampos com os dados  da FNC

	ElseIf nOpc == 5 // Exclusao
		
		If !(QI2->QI2_ORIGEM $ "QNC|QAD") .and. cModulo == "QNC"
			MsgAlert(STR0100+Alltrim(QI2->QI2_ORIGEM))//Nao e possivel a delecao da Nao-Conformidade, porque a origem da mesma pertence ao ambiente "			
			lExclui := .F.			
		Else
			lExclui := .T.
		Endif
		
		If lExclui
			QNC040Del(lRevisao,@aQNQI2)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o arquivo de Acao Corretiva X FNC          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QNC040AAC(nOpcao,lAcaoNova,nOpc)
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Envia e-mail para o Responsavel                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If QAA->(dbSeek(M->QI2_FILRES + M->QI2_MATRES )) .And. QAA->QAA_RECMAI == "1"
				If QAA->QAA_FILIAL+QAA->QAA_MAT <> cMatFil+cMatCod
					cMail := AllTrim(QAA->QAA_EMAIL)
					cMensag:= OemToAnsi(STR0082) // "Ficha de Ocorrencia/Nao-Conformidade excluida."
				Endif
			Endif
			
			// Ponto de Entrada para incluir novos destinatarios nos e-mails de inclusao/alteracao de FNC
			If Existblock("QN40ADMAIL")
				If !Empty(cMail)
					cMail += ';' + Execblock("QN40ADMAIL",.F.,.F.,{M->QI2_FILRES,M->QI2_MATRES})
					cMensag:= OemToAnsi(STR0082) // "Ficha de Ocorrencia/Nao-Conformidade excluida."
				Else
					cMail := Execblock("QN40ADMAIL",.F.,.F.,{M->QI2_FILRES,M->QI2_MATRES})
					cMensag:= OemToAnsi(STR0082) // "Ficha de Ocorrencia/Nao-Conformidade excluida."
				Endif
			Endif
	
			If !Empty(cMail)
	
				cTpMail:= QAA->QAA_TPMAIL
	
				// FNC
				If cTpMail == "1"
					cMsg := QNCSENDMAIL(1,cMensag)
				Else
					cMsg := cMensag+CHR(13)+CHR(10)+CHR(13)+CHR(10)
					cMsg += OemToAnsi(STR0024)+DtoC(M->QI2_OCORRE)+OemToAnsi(STR0025)+DtoC(M->QI2_CONPRE)+CHR(13)+CHR(10)	 // "Ocorrencia/Nao-conformidade em " ### " Data Prevista p/ Conclusao: "
					cMsg += CHR(13)+CHR(10)
					cMsg += OemToAnsi(STR0026)+CHR(13)+CHR(10)	// "Descricao Detalhada:"
					cMsg += M->QI2_MEMO1+CHR(13)+CHR(10)
					cMsg += CHR(13)+CHR(10)
					cMsg += OemToAnsi(STR0027)+CHR(13)+CHR(10)	// "Atenciosamente "
					cMsg += PADR(QA_NUSR(cMatFil,cMatCod),40)+CHR(13)+CHR(10)
					cMsg += QA_NDEPT(cMatDep,.T.,cMatFil)+CHR(13)+CHR(10)
					cMsg += CHR(13)+CHR(10)
					cMsg += OemToAnsi(STR0028) + CRLF	// "Mensagem gerada automaticamente pelo Sistema SIGAQNC - Controle de Nao-conformidades"
				Endif
			
				cAttach := ""
				aMsg:={{OemToAnsi(STR0023)+" "+TransForm(M->QI2_FNC,PesqPict("QI2","QI2_FNC"))+"-"+M->QI2_REV+Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5) , cMsg, cAttach } }	// "Ocorrencia/Nao-conformidade No. "
		
				// Geracao de Mensagem
				IF ExistBlock( "QNCFICHA" )
					aMsg := ExecBlock( "QNCFICHA", .f., .f. )
				Endif
	
				aUsuarios := {{QAA->QAA_LOGIN, cMail, aMsg} }
				QaEnvMail(aUsuarios,,,,aUsrMat[5],"2")
		  	Endif	
		EndIf
	Endif
Else
	If nOpc == 3 .And. !lRevisao 	// Inclusao
		If __lQNSX8 .and. aQNQI2[1][1] <> nil
			RollBackQE(aQNQI2)
		EndIf
		If !lSX3Seq
			GETQNCSEQ("QI2","QI2_FNC",M->QI2_FNC,.T.,nOpc)
		Endif	
	Endif

	If nOpc == 3
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui Documento anexo             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QIF->(DbSeek(M->QI2_FILIAL+M->QI2_FNC+M->QI2_REV))
			While QIF->(!Eof()) .And. QIF->QIF_FILIAL+QIF->QIF_FNC+QIF->QIF_REV == M->QI2_FILIAL+M->QI2_FNC+M->QI2_REV
				cFileTrm:= AllTrim(QIF->QIF_ANEXO)
				If File(cQPathFNC+cFileTrm)
					FErase(cQPathFNC+cFileTrm)	
				Endif
				RecLock("QIF",.F.)
				QIF->(DbDelete())
				QIF->(MsUnlock())
				QIF->(DbSkip())
			EndDo
		EndIf
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o arquivo de Acao Corretiva X FNC caso cancele Inclusao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea(cAlias)
	DbGoTo(nReg)
	QNC040AAC(nOpcao,lAcaoNova,nOpc)
	
	aCampos := {} // Zero aCampos

EndIf

dbSelectArea("QI9")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava ou Exclui o Documento anexo                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcao == 1 //-- OK
	If nOpc == 3 .Or. nOpc == 4	// Inclusao ou Alteracao

		If QIF->(DbSeek(M->QI2_FILIAL+M->QI2_FNC+M->QI2_REV))
			While QIF->(!Eof()) .And. QIF->QIF_FILIAL+QIF->QIF_FNC+QIF->QIF_REV == M->QI2_FILIAL+M->QI2_FNC+M->QI2_REV
				cFileTrm:= AllTrim(QIF->QIF_ANEXO)
				If !File(cQPathFNC+cFileTrm)
					If File(cQPathTrm+cFileTrm)
				    	If !CpyT2S(cQPathTrm+cFileTrm,cQPathFNC,.T.)
							Help(" ",1,"QNAOCOPIOU")
				      	Endif
					Else
						If File(cQPathFNC+cFileTrm)
							FErase(cQPathFNC+cFileTrm)
						Endif
					Endif
				EndIf
				QIF->(DbSkip())
			EndDo
		EndIf

	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variavel de flag para identificar se pode apagar os anexos da FNC ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lErase
	If cDelAnexo == "1"	
		aArqFNC := DIRECTORY(cQPathTrm+"*.*")
		For nT:= 1 to Len(aArqFNC)
			If 	M->QI2_FNC + "_" + M->QI2_REV + "_" =;
				Left(aArqFNC[nT,1], Len(M->QI2_FNC + "_" + M->QI2_REV + "_")) .And.;
				File(cQPathTrm+AllTrim(aArqFNC[nT,1]))
				FErase(cQPathTrm+AllTrim(aArqFNC[nT,1]))
		   Endif
		Next
	EndIf
Endif

//QNC040FIL()  // Comentado por estar aplicando o filtro sempre e o fwmbrowse não trazia no registro selecionado iniciando no inicio do arquivo.

DbSelectArea("QI2")
MsUnlock()


IF ExistBlock( "QNCNCFIM" )
   nOpcao:= ExecBlock( "QNCNCFIM", .f., .f., {nOpc,M->QI2_FNC,M->QI2_REV,nOpcao})
Endif

QNCATULEG(QI2_FILRES,QI2_MATRES)
Return nOpcao

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Qnc040Grava³ Autor ³ Aldo Marini Junior   ³ Data ³28/12/99  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os campos do arquivo de ocorrencias/nao-conformidades³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Qnc040Grava( bCampo, nOpc )
Local nC
Local aUsuarios	:= {}
Local cMsg      := ""
Local cMensag	:= ""
Local aUsrMat   := QNCUSUARIO()
Local cTpMail   := "1"     
Local lQN040MEM := ExistBlock("QN040MEM")
Local nI        :=0
Local cMailAdd  := GetMv("MV_QQUAEMA")
Local lVQuaEma  :=iif(SuperGetMv( "MV_QQUAEMA" , .F. ,'') <> '',.T.,.F.)
Local lenvcpy   
Local nAtConta  := 0
Local cEncAutPla := AllTrim(GetMv("MV_QNEAPLA",.F.,"1"))       // Encerramento Automatico de Plano
Private	cAttach := ""
Private cMail	:= ""

If ExistBlock("QN040AGV")
	ExecBlock("QN040AGV",.F.,.F.,{nOpc, M->QI2_FILRESP, M->QI2_MATRES, M->QI2_FNC,M->QI2_REV})
Endif

Begin Transaction
	DbSelectArea("QI2")    
	If nOpc == 3
		RecLock( "QI2", .T. )
	Else
		RecLock( "QI2", .F. )
	EndIf
	For nC := 1 TO FCount()
		FieldPut( nC, M->&( Eval( bCampo, nC ) ) )
      	If EVAL(bCampo,nC) == "QI2_CONREA"
      		IF QI2->QI2_ORIGEM == "TMK" .and. !EMPTY(QI2->QI2_CONREA)
      			QNCbxTMK(QI2->QI2_FNC,QI2->QI2_REV) //SE ESTA  BAIXADA BAIXO O ATENDIMENTO
      		EndIf
      	EndIf
	Next
	MsUnlock()
	FKCOMMIT()
	
	If nOpc == 3 .or. nOpc == 4
		//Gravacao das chaves dos Campos Memo na Inclusao/Alteracao
		//Desta forma gera apenas as chaves se o conteudo for preenchido evitando
		//registros em branco e tambem nao gera buracos na numeracao do SYP.
		If (nOpc == 3 .And. !Empty(M->QI2_MEMO1)) .Or. ;
			(nOpc == 4 .And. !Empty(QI2->QI2_DDETA)) .Or. ;
			(nOpc == 4 .And. !Empty(M->QI2_MEMO1) .And. Empty(QI2->QI2_DDETA)) 
			MSMM(QI2_DDETA ,,,M->QI2_MEMO1,1,,,"QI2","QI2_DDETA" )
		Endif
		If (nOpc == 3 .And. !Empty(M->QI2_MEMO2)) .Or. ;
			(nOpc == 4 .And. !Empty(QI2->QI2_COMEN)) .Or. ;
			(nOpc == 4 .And. !Empty(M->QI2_MEMO2) .And. Empty(QI2->QI2_COMEN)) 
			MSMM(QI2_COMEN ,,,M->QI2_MEMO2,1,,,"QI2","QI2_COMEN" )
		Endif
		If (nOpc == 3 .And. !Empty(M->QI2_MEMO3)) .Or. ;
			(nOpc == 4 .And. !Empty(QI2->QI2_DISPOS)) .Or. ;
			(nOpc == 4 .And. !Empty(M->QI2_MEMO3) .And. Empty(QI2->QI2_DISPOS)) 
			MSMM(QI2_DISPOS ,,,M->QI2_MEMO3,1,,,"QI2","QI2_DISPOS" )
		Endif
		If (nOpc == 3 .And. !Empty(M->QI2_MEMO4)) .Or. ;
			(nOpc == 4 .And. !Empty(QI2->QI2_MOTREV)) .Or. ;
			(nOpc == 4 .And. !Empty(M->QI2_MEMO4) .And. Empty(QI2->QI2_MOTREV)) 
			MSMM(QI2_MOTREV ,,,M->QI2_MEMO4,1,,,"QI2","QI2_MOTREV" )
		Endif
		If (nOpc == 3 .And. (!Empty(M->QI2_MEMO5)    .Or. !Empty(cMotivo))) .Or. ;
		   (nOpc == 4 .And. (!Empty(QI2->QI2_JUSTIF) .Or. !Empty(cMotivo))) .Or. ;
		   (nOpc == 4 .And. (!Empty(M->QI2_MEMO5)    .Or. !Empty(cMotivo))  .And. Empty(QI2->QI2_JUSTIF)) 

			M->QI2_MEMO5 := IIF(!EMPTY(cMotivo),cMotivo,M->QI2_MEMO5)

			MSMM(QI2_JUSTIF ,,,M->QI2_MEMO5,1,,,"QI2","QI2_JUSTIF")
		Endif
		If lQN040MEM
			For nI := 1 to Len(aMemUser)
				If  (nOpc == 3 .And. !Empty(&("M->"+aMemUser[nI,2]))) .Or. ;
					(nOpc == 4 .And. !Empty(aMemUser[nI,1])) .Or. ;
					(nOpc == 4 .And. !Empty(&("M->"+aMemUser[nI,2])) .And. Empty(aMemUser[nI,1])) 
					MSMM(&(aMemUser[nI,1]),,,&("M->"+aMemUser[nI,2]),1,,,"QI2",aMemUser[nI,1] )
				Endif           
			Next
		Endif
   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se foram baixadas todas etapas para baixar o Plano ³
		//³ Function chamada novamente pela falta do registro no QI9    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cEncAutPla == "1" .And. M->QI2_STATUS == "3" .And. ;
		   !Empty( M->QI2_CODACA ) .And. !Empty( M->QI2_REVACA ) .And. Empty( M->QI2_CONREA ) 
			QN030BxPla( , M->QI2_CODACA , M->QI2_REVACA )
		EndIf
	Endif
End Transaction

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Integracao com SIGASGA - NG Informatica                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(M->QI2_CONREA) .and. SuperGetMV("MV_NGSGAQN",.F.,"2") == "1"
	SG510RQNC(M->QI2_FNC)
Endif

IF ExistBlock( "QNCGRAVF" )
	ExecBlock( "QNCGRAVF", .f., .f. )
Endif

QAD->(dbSetOrder(1))
QAA->(dbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Geracao de mensagens via e-mail para o responsavel da FNC    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3 .Or. nOpc == 4

	aUsuarios := {}

	If M->QI2_STATUS == "4" .Or. M->QI2_STATUS == "5"// Nao Procede ### Cancelada
		If !Empty(M->QI2_CONREA)
			If QAA->(dbSeek(M->QI2_FILRES + M->QI2_MATRES)) .And. QAA->QAA_RECMAI == "1"
				If QAA->QAA_FILIAL+QAA->QAA_MAT <> cMatFil+cMatCod
					cMail  := AllTrim(QAA->QAA_EMAIL)
					If M->QI2_STATUS == "4"
						cMensag:= OemToAnsi(STR0080) // "Ficha de Ocorrencia/Nao-Conformidade Nao Procede."
					ElseIf M->QI2_STATUS == "5"
						cMensag:= OemToAnsi(STR0081) // "Ficha de Ocorrencia/Nao-Conformidade Cancelada."
					EndIf
				Endif		
			Endif
		EndIf
		If M->QI2_STATUS == "4" .And. ( lVquaEma .or. cMatFil+cMatCod <> M->QI2_FILMAT+M->QI2_MAT) // Aviso de nao-procede para digitador
			If QAA->(dbSeek(M->QI2_FILMAT + M->QI2_MAT)) .And. QAA->QAA_RECMAI == "1"
				cMail   := AllTrim(QAA->QAA_EMAIL)
				lenvcpy := GetMv("MV_QQUAEMA")
				if valtype(lenvcpy) == "C"
					lenvcpy := iif(getMv("MV_QQUAEMA")<>' ',.T.,.F.)
				Endif
				cMensag := Iif(M->QI2_TPFIC = '3',STR0118,STR0119) // "Oportunidade de Melhoria" ## "Ficha de Ocorrencia/Nao-Conformidade"
				cMensag += " " + STR0120 //"Finalizada - Motivo: Considerada NAO PROCEDE pelo destinatário."
				If nOpc <> 3 
					RecLock( "QI2", .F. )
					QI2->QI2_CONREA := dDataBase // Encerra a FNC quando o Status for Nao Procede
					QI2->(MsUnlock())
				Endif
			Endif
		Endif
    Else

		If QAA->(dbSeek(M->QI2_FILRES + M->QI2_MATRES )) .And. QAA->QAA_RECMAI == "1"
			If QAA->QAA_FILIAL+QAA->QAA_MAT <> cMatFil+cMatCod
				cMail := AllTrim(QAA->QAA_EMAIL)
				cMensag:= OemToAnsi(STR0042) // "Ficha de Ocorrencia/Nao-Conformidade iniciada."
			Endif
		Endif

	EndIf
	
	// Ponto de Entrada para incluir novos destinatarios nos e-mails de inclusao/alteracao de FNC
	If Existblock("QN40ADMAIL")
		If !Empty(cMail)
			cMail += ';' + Execblock("QN40ADMAIL",.F.,.F.,{M->QI2_FILRES,M->QI2_MATRES})
		Else
			cMail := Execblock("QN40ADMAIL",.F.,.F.,{M->QI2_FILRES,M->QI2_MATRES})
		Endif
	Endif

	If !Empty(cMail)

		cTpMail:= QAA->QAA_TPMAIL

		// FNC
		If cTpMail == "1"
			cMsg := QNCSENDMAIL(1,cMensag)
		Else
			cMsg += cMensag+CHR(13)+CHR(10)+CHR(13)+CHR(10)
			cMsg += OemToAnsi(STR0024)+DtoC(M->QI2_OCORRE)+OemToAnsi(STR0025)+DtoC(M->QI2_CONPRE)+CHR(13)+CHR(10)	 // "Ocorrencia/Nao-conformidade em " ### " Data Prevista p/ Conclusao: "
			cMsg += CHR(13)+CHR(10)
			cMsg += OemToAnsi(STR0026)+CHR(13)+CHR(10)	// "Descricao Detalhada:"
			cMsg += M->QI2_MEMO1+CHR(13)+CHR(10)
			cMsg += CHR(13)+CHR(10)
			cMsg += OemToAnsi(STR0027)+CHR(13)+CHR(10)	// "Atenciosamente "
			cMsg += PADR(QA_NUSR(cMatFil,cMatCod),40)+CHR(13)+CHR(10)
			cMsg += QA_NDEPT(cMatDep,.T.,cMatFil)+CHR(13)+CHR(10)
			cMsg += CHR(13)+CHR(10)
			cMsg += OemToAnsi(STR0028) + CRLF	// "Mensagem gerada automaticamente pelo Sistema SIGAQNC - Controle de Nao-conformidades"
		Endif
		
		cAttach := ""
		aMsg:= {{OemToAnsi(Iif(M->QI2_TPFIC = '3',STR0118,STR0023))+" "+;
		TransForm(M->QI2_FNC,PesqPict("QI2","QI2_FNC"))+"-"+M->QI2_REV+Space(10)+DTOC(Date())+"-"+;
		SubStr(TIME(),1,5)+Iif(M->QI2_STATUS = '4'," "+STR0121,'') , cMsg, cAttach } }	//"Oportunidade de Melhoria" ## "Ocorrencia/Nao-conformidade No. " ## "Finalizada"
	
		// Geracao de Mensagem
		IF ExistBlock( "QNCFICHA" )
			aMsg := ExecBlock( "QNCFICHA", .f., .f. )
		Endif

		aUsuarios := {{QAA->QAA_LOGIN, cMail, aMsg} }
		if lenvcpy
			If "@" $ cmailAdd
				If ";" $ cMailAdd 
				    if SubStr(cMailAdd,Len(cMailAdd)-1,1) <> ";"
				    	cmailAdd:= Alltrim(cMailAdd)+";"
				    Endif
					for nI := 1 to len(alltrim(cMailAdd))
						nAtConta  := AT(";",cMailAdd)
						if SubStr(cMailAdd,1,nAtConta-1) <> ' ' .and. "@" $ SubStr(cMailAdd,1,nAtConta-1)	
							aAdd (aUsuarios,{QAA->QAA_LOGIN, SubStr(cMailAdd,1,nAtConta-1), aMsg})	
						Endif
						cMailAdd  := Substr(cMailAdd,nAtConta+1,len(cMailAdd))
						if nAtConta < 2 	
							Exit
						Endif
						nI := len(alltrim(cMailAdd))
					Next nI
				else
					aAdd (aUsuarios,{QAA->QAA_LOGIN,alltrim(cMailAdd), aMsg})
				Endif
			Endif
		Endif		
			
		QaEnvMail(aUsuarios,,,,aUsrMat[5],"2")
     
	Endif
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄ-ÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC040MTGET³ Autor ³ Aldo Marini Junior   ³ Data ³ 24.01.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄ-ÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Montar o aCols e o aHeader Para Cadastros                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC040MTGET(cAliasB,nOpc,aArray)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do Cadastro a ser Atualizado                 ³±±
±±³          ³ ExpN1 = Opcao devolvida pela funcao                        ³±±
±±³          ³ ExpA1 = Array a ser adicionado os registros                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC040MTGET(cAliasB,nOpc,aArray)
Local  oDlg1, oGet
Local oCodAca, oRvAca
Local cFil 	 	:= cAliasB+"_FILIAL"
Local cCod 	 	:= cAliasB+"_FNC"
Local cRv    	:= cAliasB+"_REVFNC"
Local a040Field := {cFil,cCod,cRv,cAliasB+"_DESRES"}
Local cCodAca	:= M->QI2_FNC
Local cRvAca	:= M->QI2_REV

Local nCnt    	:= 0
Local nUsado  	:= 0
Local nT		:= 0

Local aStruAlias := FWFormStruct(3, cAliasB)[3]
Local nX

Private nOpca1  := 0
Private cFilMat	:= cMatFil
Private aCols

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Codigo Acao e RV estao em Branco	              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(M->QI2_FNC) .Or. Empty(M->QI2_REV) .Or. (!M->QI2_STATUS $ "1,2,5" .And. Len(aArray) == 0)
	Return( .F. )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VerIfica o cabecalho da MsGetDados                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader:={}
For nX := 1 To Len(aStruAlias)
	If cNivel >= GetSx3Cache(aStruAlias[nX,1], "X3_NIVEL") .and. ! aScan(a040Field,{|x| x == Trim(aStruAlias[nX,1])}) > 0
		nUsado++
		AADD(aHeader, Q040GetSX3(aStruAlias[nX,1], "", "") )
	EndIf
Next nX

nCnt := Len(aArray)

If nCnt > 0
	aCols := aClone(aArray)
Else
	aCols := array(1,nUsado+1)
	nUsado:=0
	
	For nX := 1 To Len(aStruAlias)
		If cNivel >= GetSx3Cache(aStruAlias[nX,1], "X3_NIVEL") .and. ! aScan(a040Field,{|x| x == Trim(aStruAlias[nX,1])}) > 0
			nUsado++
			lInit := .F.
			If ExistIni(aStruAlias[nX,1])
				lInit := .T.
				aCols[1,nUsado] := InitPad(GetSx3Cache(aStruAlias[nX,1], "X3_RELACAO"))
				If ValType(aCols[1,nUsado]) == "C" 
					aCols[1,nUsado] := Padr(aCols[1,nUsado],GetSx3Cache(aStruAlias[nX,1], "X3_TAMANHO"))
				Endif
				If aCols[1,nUsado] == NIL 
					lInit := .F.
				EndIf
			EndIf
			If !lInit
				If GetSx3Cache(aStruAlias[nX,1], "X3_TIPO") == "C"
					aCols[1,nUsado] := SPACE(GetSx3Cache(aStruAlias[nX,1], "X3_TAMANHO"))
				ELSEIf GetSx3Cache(aStruAlias[nX,1], "X3_TIPO") == "N"
					aCols[1,nUsado] := 0
				ELSEIf GetSx3Cache(aStruAlias[nX,1], "X3_TIPO") == "D"
					aCols[1,nUsado] := CTOD("  /  /  ","DDMMYY")
				ELSE
					aCols[1,nUsado] := .F.
				EndIf
			Endif
		EndIf
	Next nX
	
	aCols[1,nUsado+1] := .F.
Endif	


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Titulo da MSDIALOG conforme opcao escolhida          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cAliasB == "QI9"	; cCad1 := OemToAnsi( STR0015 )	//"Planos de Acao"
EndIf

DEFINE MSDIALOG oDlg1 TITLE cCad1 FROM 9,0 TO 28,80 OF oMainWnd

@ 013, 005 TO 35, 311 OF oDlg1 PIXEL

@20, 008 SAY OemToAnsi( STR0019 ) SIZE 35,7 PIXEL	//	"Ficha N.C.: "
@20, 100 SAY OemToAnsi( STR0020 ) SIZE 20,7 PIXEL	//	"Revisao: "

@20,045 MSGET oCodAca VAR cCodAca  PICTURE "@R 999999/9999" SIZE  38, 8 PIXEL OF oDlg1
@20,123 MSGET oRvAca  VAR cRvAca                            SIZE  03, 8 PIXEL OF oDlg1

oCodAca:lReadOnly:= .T.
oRvAca:lReadOnly:= .T.

If nOpc == 3 .or. nOpc == 4		// Inclusao ou Alteracao
	oGet := MSGetDados():New(38,1,136,315,4,"QNC040LiOk()","","",.T.,,)
	ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{||If(Obrigatorio(aGets,aTela),(nOpca1:= 1,If(QNC040LiOk(),oDlg1:End(),nOpca1:=0) ),.f.)},{|| nOpca1:= 2,oDlg1:End()})
Else								// Visualizar ou Exclusao
	oGet := MSGetDados():New(38,1,136,315,2)
	ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{||oDlg1:End()},{||oDlg1:End()})
EndIf

If nOpc <> 2 .And. nOpc <> 5 //-- Se nao for Visualizacao ou Exclusao
	If nOpca1 == 1	// Ok
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava os lactos dos cadastros de acordo com a opcao em ARRAY	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aArray:={}
		For nT := 1 to Len(aCols)
			If aCols[nT,Len(aHeader)+1] == .F.
				aAdd(aArray,aCols[nT])
			Endif
		Next

	EndIf
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC040LiOk ³ Autor ³ Aldo Marini Junior   ³ Data ³ 24.01.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Critica linha digitada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC040LiOk(o)
Local nx        := 0
Local nCont		:= 0
Local nPos1 := 0, nPos2 := 0
Local lRet := .T.
Local aAllCpo:={}

If aCols[n,Len(aHeader)+1] == .F.
	// VerIfica a Posicao dos Campos na Matriz de Cabecalho
	nPos1 := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI9_CODIGO" })
	nPos2 := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI9_REV"	})

	If	(nPos1 <> 0 .And. nPos2 <> 0)
		
		// Ocorrencias/Nao-conformidade por Planos de Acao
		If nPos1 <> 0 .And. nPos2 <> 0
			Aeval(aCols,{ |X| If( X[nPos1]==aCols[N,nPos1] .And. ;
								   X[nPos2]==aCols[N,nPos2], nCont ++ , nCont ) } )
		EndIf

		If nCont > 1 .And. Len(aCols) > 1
			Help(" ",1,"QALCTOJAEX")
			Return( .F. )
		EndIf
	EndIf		

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Campo a serem validados quanto ao seu conteudo					³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAllCpo:={"QI9_CODIGO","QI9_REV"}
	For nx := 1 To Len(aHeader)
		If Empty(aCols[n][nx])
			nItem := Ascan(aAllCpo,{ |X| UPPER(ALLTRIM(X)) == UPPER(ALLTRIM(aHeader[nx][2]))})
			If nItem > 0
				If Lastkey() # 27
					Help(" ",1,"QDA050BRA")
					lRet := .F.
				EndIf
				Exit
			EndIf
		EndIf
	Next
	
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC040Del ³ Autor ³ Aldo Marini Junior    ³ Data ³ 27/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Exclusao de Acoes                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC040Del()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
           
Function QNC040Del(lRevisao,aQNQI2)
Local nOrdQI2    := QI2->(IndexOrd())
Local nRegQI2    := QI2->(Recno())
Local cChaveQI2  := ""
Local cRevAnt    := ""
Local cRevQI2    := ""
Local lQN040MEM  := ExistBlock("QN040MEM")
Local nI         :=0

Local cQPathFNC:= QA_TRABAR(Alltrim(GetMv("MV_QNCPDOC")))

Default lRevisao := .F.
Default aQNQI2   := {}

If ExistBlock("Q040DQNC")
	ExecBlock("Q040DQNC",.f.,.f.,{M->QI2_FNC,M->QI2_REV})
Endif

Begin Transaction 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta Lancamentos dos arquivos associados         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QI9")
	If dbSeek(QI2->QI2_FILIAL+QI2->QI2_FNC+QI2->QI2_REV)
		While !Eof() .And. QI9->QI9_FILIAL+QI9->QI9_FNC+QI9->QI9_REVFNC == QI2->QI2_FILIAL+QI2->QI2_FNC+QI2->QI2_REV

			RecLock("QI9",.F.)
			dbDelete()
			MsUnlock()			
			dbSkip()
		Enddo
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta Documentos Anexos                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    dBSelectArea("QIF")
    If dbSeek(QI2->QI2_FILIAL+QI2->QI2_FNC+QI2->QI2_REV)
		While !Eof() .And. QIF->QIF_FILIAL+QIF->QIF_FNC+QIF->QIF_REV == QI2->QI2_FILIAL+QI2->QI2_FNC+QI2->QI2_REV
			cFileTrm:= AllTrim(QIF->QIF_ANEXO)
			If File(cQPathFNC+cFileTrm)
				FErase(cQPathFNC+cFileTrm)	
			Endif

			RecLock("QIF",.F.)
			dbDelete()
			MsUnlock()
			dbSkip()
		Enddo
	Endif	

	dbSelectArea("QI2")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta lancamentos do arquivo MEMO                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MSMM(QI2->QI2_DDETA ,,,,2)
	MSMM(QI2->QI2_COMEN ,,,,2)
	MSMM(QI2->QI2_DISPOS,,,,2)
	MSMM(QI2->QI2_MOTREV,,,,2)
	If lQN040MEM
		For nI := 1 To Len(aMemUser)
		    MSMM(&("QI2->"+aMemUser[nI,1]),,,,2)
		Next
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o codigo sequencial                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If !lRevisao
	// Voltar conforme parametro
		QNCDELSEQ("QI2", "QI2_FNC", ,QI2->QI2_FNC)
	Endif

	cChaveQI2 := QI2->QI2_FILIAL+QI2->QI2_FNC
	cRevQI2   := QI2->QI2_REV

	RecLock("QI2")
	dbDelete()
	MsUnlock()        
	FKCOMMIT()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Volta a penultima sequencia de Revisao para situacao normal (nao obsoleto) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QI2")
	dbSetOrder(2)

	If dbSeek(QI2->QI2_FILIAL+QI2->QI2_FNC)
		While !Eof() .And. QI2->QI2_FILIAL+QI2->QI2_FNC == cChaveQI2
			If QI2->QI2_REV == cRevQI2
				Exit
			Endif
			cRevAnt := QI2->QI2_REV
			dbSkip()
		Enddo
		If !Empty(cRevAnt)
			If dbSeek(cChaveQI2+cRevAnt)
				RecLock("QI2")
				QI2->QI2_OBSOL := "N"
				MsUnlock()				
			Endif
		Endif
	Else
		dbGoTo(nRegQI2)
	Endif
	dbSetOrder(nOrdQI2)

End Transaction

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FQNCCHKACA³ Autor ³ Aldo Marini Junior    ³ Data ³ 29/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para validacao dos codigo de Planos de Acao       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQNCCHKACA(cCodAca,cCodRev)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Plano de Acao                            ³±±
±±³          ³ ExpC2 = Codigo da Revisao do Plano de Acao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

 Function FQNCCHKACA(cCodAca,cCodRev)
Local lRet  := .F.
Local cChave := Right(cCodAca,4) + cCodAca 

If cCodRev<>NIL .and. !Empty(cCodRev)
	cChave := cChave + cCodRev
Endif		


If Empty(cChave)
	lRet := .T.
Else
	If QI3->(dbSeek(xFilial("QI3")+cChave))
		lRet := .T.                          
		IF cCodRev<>NIL
			IF QI3->QI3_OBSOL=="N"
				lRet := .T.
			ENDIF
		ENDIF
	Endif
Endif

// Ponto de entrada para liberar alteracao e inclusao de Plano de Acao na FNC por usuarios que nao sejam o Responsavel pela FNC
If ExistBlock('QN040AUT')
	lRet := ExecBlock('QN040AUT',.F., .F.,{cMatFil,cMatCod})
Endif

IF !lRet
	Help(" ",1,"QNC040NCAC")
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Qnc040VldFNC³ Autor ³ Aldo Marini Junior  ³ Data ³ 24/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para validacao da Ficha de Ocorrencias/Nao-conform³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Qnc040VldFNC(aGets,aTela,nOpc)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array de controle dos Gets                         ³±±
±±³          ³ ExpA2 = Array de controle dos campos da tela               ³±±
±±³          ³ ExpN1 = Numerico contendo opcao do cadastro.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Qnc040VldFNC(aGets,aTela,nOpc)
Local lRet 		:= .F.
Local oDlg			:= NIL
Local lVquaEma	:= iif(SuperGetMv( "MV_QQUAEMA" , .F. ,'') <> '',.T.,.F.)
Local oTexto		:= NIL
Local oFontMet		:= TFont():New("Courier New",6,0)
Local cCodFNC		:= ""
Local cTexto		:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada "QNCVLDNC" criado para ficar flexivel a validacao         ³
//³ Mantido o "QNCVALIF" por ja ter customizacoes/validacoes criadas           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ExistBlock( "QNCVLDNC" )
     lRet := ExecBlock( "QNCVLDNC", .f., .f. )
Else

	IF ExistBlock( "QNCVALIF" )
		lRet := ExecBlock( "QNCVALIF", .f., .f. )
	Else
		If nOpc <> 2 .And. nOpc <> 5
			lRet := Obrigatorio(aGets,aTela)
		Else
			lRet := .T.
		Endif
	Endif               
	
	DBSELECTAREA("SA2")
	DBSETORDER(1)
	IF !EMPTY(M->QI2_CODFOR) .AND.DBSEEK(XFILIAL("SA2")+M->QI2_CODFOR+M->QI2_LOJFOR)
		IF SA2->A2_MSBLQL == "1"
			lRet:=.F.
			MessageDlg(STR0103) //"Fornecedor selecionado está inativo" 
		ENDIF
	ENDIF
	
	DBSELECTAREA("SA1")
	DBSETORDER(1)
	IF !EMPTY(M->QI2_CODCLI) .AND.DBSEEK(XFILIAL("SA1")+M->QI2_CODCLI+M->QI2_LOJCLI)
		IF SA1->A1_MSBLQL == "1"
			lRet:=.F.          
			MessageDlg(STR0102)//"Cliente selecionado está inativo"
		ENDIF
	ENDIF  
	
	IF !EMPTY(M->QI2_CODDOC)
		DBSELECTAREA("QDH")
		DBSETORDER(1)
		if !DBSEEK(XFILIAL("QDH")+M->QI2_CODDOC)
			lRet:=.F.          
			MessageDlg("Documento inexistente no cadastro de documentos")
		ENDIF
	ENDIF  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida se filial/usuario do responsavel estao validos               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(M->QI2_FILRES) .And. !Empty(M->QI2_MATRES)
		If !QA_CHKMAT(M->QI2_FILRES,M->QI2_MATRES)
			lRet := .F.
		Endif
	Endif

	If nOpc <> 4 .And. !Empty(M->QI2_FILMAT) .And. !Empty(M->QI2_MAT)
		If !QA_CHKMAT(M->QI2_FILMAT,M->QI2_MAT)
			lRet := .F.
		Endif
	Endif

	If lRet .And. ! Empty(M->QI2_CONREA) .And. M->QI2_STATUS < "3"
		MsgAlert(STR0093) //"A FNC nao podera ser encerrada em status [Registrada/Em Analise]"
		lRet := .F.
	Endif
	
	If lRet .And. M->QI2_STATUS <> "5" .And. M->QI2_STATUS <> "4" .And. ! Empty(M->QI2_CONREA) 
		If ! Empty(M->QI2_CODACA+M->QI2_REVACA)
			QI3->(DbSetOrder(2))
			If 	QI3->(DbSeek(xFilial() + M->QI2_CODACA+M->QI2_REVACA)) .And.;
				Empty(QI3->QI3_ENCREA)
				ApMsgAlert(STR0092) //"Atencao e necessario finalizar o plano de acao para finalizacao da FNC !"
				lRet := .F.
			Endif
		Endif
	Endif
	
	IF lRet  .And. lMvFNCPLN .AND. M->QI2_STATUS == "3" .AND. Empty(M->QI2_CODACA+M->QI2_REVACA) //Procede
		MsgAlert(OemtoAnsi(STR0097))  //"A FNC não podera ser encerrada em status [Procede] sem a Criaçaõ do Plano de Açao, Conforme parametro MV_QFNCPLN"
		lRet := .F.
	Endif		
	
	IF lRet  .AND. !Empty(M->QI2_CONREA)
		If M->QI2_CONREA > dDataBase // Caso a data de conclusao seja maior que a data base bloqueio
			MsgAlert(STR0101) //"Data de encerramento da FNC nao pode ser maior que a data  base do sistema! "
			lRet := .F.
		EndIf
	Endif
	
	If M->QI2_STATUS == "5" .And. Empty(M->QI2_CONREA)
		MsgAlert(Left(OemToAnsi(STR0104),17)+'"'+RTrim(RetTitle("QI2_CONREA"))+'"'+Substr(OemToAnsi(STR0104),17),OemToAnsi(STR0105))
		lRet := .F.
	Endif

	IF !EMPTY(M->QI2_MEMO5)
		cTexto := M->QI2_MEMO5
	ELSE
		cTexto := MSMM(QI2->QI2_JUSTIF)
	ENDIF
	
	// Valida motivo quando o status for nao procede
	If M->QI2_STATUS == "4" .And. (lVquaEma .or. cMatFil+cMatCod <> M->QI2_FILMAT+M->QI2_MAT) // Aviso de nao-procede para digitador
		//Tela do Motivo de Nao Procede
		cCodFNC := M->QI2_FNC+"  "+STR0020+M->QI2_REV //"Revisao: "
		
		DEFINE MSDIALOG oDlg FROM 62,100 TO 320,610 TITLE STR0122 PIXEL //"Justificativa da classificação Não-Procede"
	
		@ 003, 004 TO 027, 250 LABEL STR0019 OF oDlg PIXEL //"Ficha N.C.: "
		@ 040, 004 TO 110, 250 OF oDlg PIXEL

		@ 013, 010 MSGET cCodFNC WHEN .F. SIZE 185, 010 OF oDlg PIXEL
	
		@ 050, 010 GET oTexto VAR cTexto MEMO NO VSCROLL SIZE 238, 051 OF oDlg PIXEL
			
		oTexto:SetFont(oFontMet)
	
		DEFINE SBUTTON FROM 115,190 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM 115,220 TYPE 2 ACTION (nOpca := 2,oDlg:End()) ENABLE OF oDlg
		
		ACTIVATE MSDIALOG oDlg CENTERED
		
		cMotivo := Iif(nOpca = 1,cTexto,"")
		
		If Empty(cMotivo) // Verifica se a justificativa foi preenchida
			Alert(STR0123) //"É necessário informar a justificativa para a classificação Não-Procede."
			lRet := .F.
		ELSE
			RecLock("QI2",.F.)
				M->QI2_MEMO5 := cMotivo
			MsUnlock()
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada "QN040VLD" criado para adicionar e nao alterar o fluxo de ³
	//³ validacao																   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. ExistBlock("QN040VLD")
		lRet := ExecBlock("QN040VLD", .F., .F.)
	EndIf
Endif
	
Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³  Qnc040ACAO    ³ Autor ³ Aldo Marini Junior³ Data ³02/02/01³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inclusao de Acao Corretiva atraves da Ficha Nao-Conformidade³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC040ACAO()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QNC040ACAO()
Local nOpcAcao := 7
Local nRegAcao := 0
Local nOpcQI3  := 0
Local nRegQI2  := QI2->(Recno())
Local nOrdQI2  := QI2->(IndexOrd())
Local INCLUI_OLD := INCLUI
Local cStatusPlano := AllTrim(GetMv("MV_QNCSFNC",.F.,"3")) 
Local lRet  := .T.
Local lAut	  := .F.

Private aRotina := { {"","",0,1}, {"","",0,2}, {"","",0,3},{"","",0,4} }

If Empty(M->QI2_CODACA+M->QI2_REVACA) .and. noPC <> 2
	
	// Ponto de entrada para liberar alteracao e inclusao de Plano de Acao na FNC por usuarios que nao sejam o Responsavel pela FNC
	If ExistBlock('QN040AUT')
		lAut := ExecBlock('QN040AUT',.F., .F.,{cMatFil,cMatCod})
	Endif	

	// Caso seja diferente de 3-Procede e diferente de responsavel nao deixa cadastrar Acao Corretiva
	If !(M->QI2_STATUS $ cStatusPlano .And. cMatFil+cMatCod == M->QI2_FILRES+M->QI2_MATRES) .And. !lAut

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ So podera gerar a Acao Corretiva se a Ficha Proceder ³
		//³ ou se o Usuario logado for diferente do responsavel  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Help(" ",1,"QNC040NCAC")
		Return
		
	Endif
Else
	nOpcAcao := 2
	dbSelectArea("QI3")
	dbSetOrder(2)
	If !dbSeek(xFilial("QI3")+M->QI2_CODACA+M->QI2_REVACA)
		Return
	Endif
	nRegAcao := QI3->(Recno())
	dbSetOrder(1)
Endif
If GetMv("MV_QTMKPMS",.F.,1) == 2
    nOpcAcao := 4
    lAltEta  :=.T.
Endif

If Existblock ("QNC040PL")
	Execblock ("QNC040PL",.F.,.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada "QNC040VPL" criado para permitir ou não o uso do botão    ³
//³ Plano de ação.  QNC040VPL Ret = .T. abre plano de ação, .F. não abre       ³
// Default = .T.															   ³	
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Existblock ("QNC040VPL")
	Lret := Execblock ("QNC040VPL",.F.,.F.)
Endif

if Lret
	nOpcQI3 := QNC030Alt("QI3",nRegAcao,nOpcAcao,lAltEta)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se houve Inclusao de Acao Corretiva e atualiza flag ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcQI3 == 1 .And. nOpcAcao == 7
	lAcaoNova := .T.
	cQI3_Cod := QI3->QI3_CODIGO
	cQI3_Rev := QI3->QI3_REV
Endif

dbSelectArea("QI2")
dbSetOrder(nOrdQI2)
dbGoto(nRegQI2)

INCLUI := INCLUI_OLD

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Qnc040AAC  ³ Autor ³ Aldo Marini Junior  ³ Data ³ 21/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para verificacao e atualizacao das Acoes X FNC    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Qnc040AAC(lAcaoNova,nOpc)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Array de controle dos Gets                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC040AAC(nOpcao,lAcaoNova,nOpc)

Local cMsg      := ""
Local cAttach   := ""
Local aUsuarios := {}
Local aUsrMat   := QNCUSUARIO()
Local cTpMail   := "1"
Local nI
Local nSpacACA  := TamSx3("QI2_CODACA")[1]
Local nSpacREVA := TamSx3("QI2_REVACA")[1]

Local aArq := {"QI4",;	//"Equipes"
				"QI5",;	//"Acoes/Etapas"
				"QI6",;	//"Causas Potenciais"
				"QI7",;	//"Documentos a Revisar"  
				"QI8",;	//"Custos"
				"QI9"}	//"Nao-Conformidades"
Local lTMKPMS    := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³

Local lQNCEACAO := ExistBlock( "QNCEACAO" )

Private aMsg := {}

If nOpcao <> 1 
	If lAcaoNova	// Incluido Acao Corretiva
		QI9->(dbSetOrder(1))
		QI3->(dbSetOrder(2))
		If QI3->(dbSeek(xFilial("QI3")+cQI3_Cod+cQI3_Rev))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Envio de e-Mail para o responsavel do Plano de Acao e da Etapa vigente   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cMatFil+cMatCod <> QI3->QI3_FILMAT+QI3->QI3_MAT
				If QAA->(dbSeek(QI3->QI3_FILMAT + QI3->QI3_MAT )) .And. QAA->QAA_RECMAI == "1"
					cMail := AllTrim(QAA->QAA_EMAIL)
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Envio de e-Mail para o responsavel do Plano de Acao                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cMail)

				cTpMail:= QAA->QAA_TPMAIL

				// Plano de Acao
				If cTpMail == "1"
					cMsg := QNCSENDMAIL(2,OemToAnsi(STR0043),.T.)	// "*** Plano de Acao CANCELADO ***"
				Else
					cMsg := OemToAnsi(STR0043)+CHR(13)+CHR(10)	 // "*** Plano de Acao CANCELADO ***"
					cMsg += CHR(13)+CHR(10)
					cMsg += OemToAnsi(STR0027)+CHR(13)+CHR(10)	// "Atenciosamente "
					cMsg += M->QI2_NUSR+CHR(13)+CHR(10)
					cMsg += QA_NDEPT(M->QI2_MATDEP,.T.,M->QI2_FILMAT)+CHR(13)+CHR(10)
					cMsg += CHR(13)+CHR(10)
					cMsg += OemToAnsi(STR0028) + CRLF	// "Mensagem gerada automaticamente pelo Sistema SIGAQNC - Controle de Nao-conformidades"
				
				Endif
				
				cAttach := ""
				aMsg:={{OemToAnsi(STR0044)+" "+TransForm(QI3->QI3_CODIGO,PesqPict("QI3","QI3_CODIGO"))+"-"+QI3->QI3_REV+Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5), cMsg, cAttach} }	// "Plano de Acao No. "
	
				// Geracao de Mensagem para o Responsavel do Plano de Acao 
				IF ExistBlock( "QNCRACAO" )
					aMsg := ExecBlock( "QNCRACAO", .f., .f., { OemToAnsi(STR0043),.T. } ) // "*** Plano de Acao CANCELADO ***"
				Endif

				aAdd(aUsuarios,{QAA->QAA_LOGIN, cMail,aMsg} )

			Endif
            
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Envio de e-Mail para o responsavel da Etapa vigente                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cMail := ""
			dbSelectArea("QI5")
			dbSetOrder(1)
			If dbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV)
				While !Eof() .And. QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV == QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV
					If QI5->QI5_PEND == "S"
						If cMatFil+cMatCod <> QI5->QI5_FILMAT+QI5->QI5_MAT
							If QAA->(dbSeek(QI5->QI5_FILMAT + QI5->QI5_MAT )) .And. QAA->QAA_RECMAI == "1"
								cMail := AllTrim(QAA->QAA_EMAIL)
							Endif
						Endif

						If !Empty(cMail)

							cTpMail:= QAA->QAA_TPMAIL

							// Etapa do Plano de Acao
							If cTpMail == "1"
								cMsg := QNCSENDMAIL(3,OemToAnsi(STR0043),.T.)	// "*** Plano de Acao CANCELADO ***"
							Else
								cMsg := OemToAnsi(STR0043)+CHR(13)+CHR(10)	 // "*** Plano de Acao CANCELADO ***"
								cMsg += CHR(13)+CHR(10)
								cMsg += OemToAnsi(STR0027)+CHR(13)+CHR(10)	// "Atenciosamente "
								cMsg += M->QI2_NUSR+CHR(13)+CHR(10)
								cMsg += QA_NDEPT(M->QI2_MATDEP,.T.,M->QI2_FILMAT)+CHR(13)+CHR(10)
								cMsg += CHR(13)+CHR(10)
								cMsg += OemToAnsi(STR0028) + CRLF	// "Mensagem gerada automaticamente pelo Sistema SIGAQNC - Controle de Nao-conformidades"
							
							Endif
							cAttach := ""

							aMsg:={{OemToAnsi(STR0044)+" "+TransForm(QI3->QI3_CODIGO,PesqPict("QI3","QI3_CODIGO"))+"-"+QI3->QI3_REV+Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5), cMsg, cAttach} }	// "Plano de Acao No. "
	
							// Geracao de Mensagem para o Responsavel da Etapa do Plano de Acao 
							IF lQNCEACAO
								aMsg := ExecBlock( "QNCEACAO", .f., .f., { OemToAnsi(STR0043) } ) // "*** Plano de Acao CANCELADO ***"
							Endif

							aAdd(aUsuarios,{QAA->QAA_LOGIN, cMail, aMsg} )
			            Endif
					Endif						
					dbSkip()
     			Enddo
			Endif

			If Len(aUsuarios) > 0
				QaEnvMail(aUsuarios,,,,aUsrMat[5],"2")
			Endif

			dbSelectArea("QI3")
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deleta Lancamentos dos arquivos associados         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nI:=1 to Len(aArq)
				cChaveArq := aArq[nI]+"->"+aArq[nI]+"_FILIAL+"+aArq[nI]+"->"+aArq[nI]+"_CODIGO+"+aArq[nI]+"->"+aArq[nI]+"_REV"
				dbSelectArea(aArq[nI])
				If dbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV)
					While !Eof() .And. &cChaveArq == QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Deleta lancamentos do arquivo MEMO                 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If aArq[nI] == "QI5"
							MSMM(QI5->QI5_DESCCO,,,,2)
							MSMM(QI5->QI5_DESCOB,,,,2)
						ElseIf aArq[nI] == "QI6"
							MSMM(QI6->QI6_DESCR,,,,2)
						Endif

		        		RecLock(aArq[nI])
						dbDelete()
		        		MsUnlock()
						dbSkip()
					Enddo
				Endif
			Next

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deleta lancamentos do arquivo MEMO                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MSMM(QI3->QI3_PROBLE,,,,2)
			MSMM(QI3->QI3_LOCAL ,,,,2)
			MSMM(QI3->QI3_RESESP,,,,2)
			MSMM(QI3->QI3_RESATI,,,,2)
			MSMM(QI3->QI3_OBSERV,,,,2)
			MSMM(QI3->QI3_METODO,,,,2)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o codigo sequencial                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			GETQNCSEQ("QI3","QI3_CODIGO",QI3->QI3_CODIGO,.T.,3,@aQNQI3)

			RecLock("QI3")
			dbDelete()
			MsUnlock()         
			FKCOMMIT()

		Endif

		If !Empty(M->QI2_CODACA) .And. !Empty(M->QI2_REVACA)
			M->QI2_CODACA := Space(nSpacACA)
			M->QI2_REVACA := Space(nSpacREVA)
		Endif
   Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o arquivo de Plano de Acao X FNC            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcao == 1
	If nOpc == 3 .Or. nOpc == 4
		QI9->(dbSetOrder(2))
		If !Empty(M->QI2_CODACA) .And. !Empty(M->QI2_REVACA)
			If !QI9->(dbSeek(M->QI2_FILIAL + M->QI2_FNC + M->QI2_REV + M->QI2_CODACA + M->QI2_REVACA))
				RecLock("QI9",.T.)
				QI9->QI9_FILIAL := M->QI2_FILIAL
				QI9->QI9_CODIGO := M->QI2_CODACA
				QI9->QI9_REV    := M->QI2_REVACA
				QI9->QI9_FNC    := M->QI2_FNC
				QI9->QI9_REVFNC := M->QI2_REV
				MsUnLock()	  
				FKCOMMIT()		
			Endif
			
			If nOpc == 4 .And. !Empty(QI2->QI2_CODACA) .And. !Empty(QI2->QI2_REVACA) .And. ;
										QI2->QI2_CODACA <> M->QI2_CODACA .And. ;
										QI2->QI2_REVACA <> M->QI2_REVACA
				If QI9->(dbSeek(M->QI2_FILIAL + M->QI2_FNC + M->QI2_REV + QI2->QI2_CODACA + QI2->QI2_REVACA))

					RecLock("QI9",.F.)
					dbDelete()
					MsUnlock()
					FKCOMMIT()
				Endif
			Endif
		Else

			If QI9->(dbSeek(M->QI2_FILIAL + M->QI2_FNC + M->QI2_REV ))
				If !lTMKPMS 

					RecLock("QI9",.F.)
					dbDelete()
					MsUnLock()			
				Endif
					
				If lAcaoNova	// Incluido Acao Corretiva
					QI3->(dbSetOrder(2))
					If QI3->(dbSeek(xFilial("QI3")+QI9->QI9_CODIGO+QI9->QI9_REV))
					
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Deleta Lancamentos dos arquivos associados         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nI:=1 to Len(aArq)
							cChaveArq := aArq[nI]+"->"+aArq[nI]+"_FILIAL+"+aArq[nI]+"->"+aArq[nI]+"_CODIGO+"+aArq[nI]+"->"+aArq[nI]+"_REV"
							dbSelectArea(aArq[nI])
							If dbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV)
								While !Eof() .And. &cChaveArq == QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Deleta lancamentos do arquivo MEMO                 ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If aArq[nI] == "QI5"
										MSMM(QI5->QI5_DESCCO,,,,2)
										MSMM(QI5->QI5_DESCOB,,,,2)
									ElseIf aArq[nI] == "QI6"
										MSMM(QI6->QI6_DESCR,,,,2)
									Endif

					        		RecLock(aArq[nI])
									dbDelete()
					        		MsUnlock()            
					        		FKCOMMIT()
									dbSkip()
								Enddo
							Endif
						Next
		
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Deleta lancamentos do arquivo MEMO                 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						MSMM(QI3->QI3_PROBLE,,,,2)
						MSMM(QI3->QI3_LOCAL ,,,,2)
						MSMM(QI3->QI3_RESESP,,,,2)
						MSMM(QI3->QI3_RESATI,,,,2)
						MSMM(QI3->QI3_OBSERV,,,,2)
						MSMM(QI3->QI3_METODO,,,,2)
		
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza o codigo sequencial                       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

						GETQNCSEQ("QI3","QI3_CODIGO",QI3->QI3_CODIGO,.T.,nOpc,@aQNQI3)

						RecLock("QI3")
						dbDelete()
						MsUnlock()
						FKCOMMIT()
					Endif
				Endif
			Endif
		Endif
	Endif	

	If nOpc == 5
		If !Empty(M->QI2_CODACA) .And. !Empty(M->QI2_REVACA)
			QI9->(dbSetOrder(2))
			If QI9->(dbSeek(M->QI2_FILIAL + M->QI2_FNC + M->QI2_REV + M->QI2_CODACA + M->QI2_REVACA))

				RecLock("QI9",.F.)
				dbDelete()
				MsUnLock()			
				FKCOMMIT()
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura Plano de Acao em outra FNC, caso nao exista exclui ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QI9->(dbSetOrder(1))
			QI3->(dbSetOrder(2))
			If !QI9->(dbSeek(M->QI2_FILIAL + M->QI2_CODACA + M->QI2_REVACA))
				If QI3->(dbSeek(xFilial("QI3")+ M->QI2_CODACA + M->QI2_REVACA))
					QNC030Del(.F.,@aQNQI3)	// Exclui Plano de Acao - funcao encontrada no QNCA030
				Endif
			Endif

			QI3->(dbSetOrder(1))
		Endif
	Endif
Endif

dbSelectArea("QI2")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QN40VRES   ³ Autor ³ Aldo Marini Junior  ³ Data ³ 14/03/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida condicoes para habilitar/desabilitar outros campos  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QN40VRES()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QN40VRES
Local lRet := .T.

If !(cMatFil+cMatCod == M->QI2_FILRES + M->QI2_MATRES .And. M->QI2_STATUS == "3")
	lRet := .F.
Endif

// Ponto de entrada para liberar alteracao e inclusao de Plano de Acao na FNC por usuarios que nao sejam o Responsavel pela FNC
If ExistBlock('QN040AUT')
	lRet := ExecBlock('QN040AUT',.F., .F.,{cMatFil,cMatCod})
Endif

Return lRet


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC040Legen³ Autor ³ Aldo Marini Junior   ³ Data ³ 20.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC040Legen

Local aCores   := {{'ENABLE'    , OemtoAnsi(STR0033) },;	// "Ficha Baixada"
                   {'BR_AMARELO', OemtoAnsi(STR0034) },;   // "Ficha pendente com Plano Acao"
                   {'DISABLE'   , OemtoAnsi(STR0035) },;	// "Ficha pendente sem Plano Acao"
                   {'BR_PRETO'  , OemtoAnsi(STR0079) } }	// "Ficha com Revisao Obsoleta" 
                   
Local aCoresNew  := {}                      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para alterar cores do Browse do Cadastro    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QNC40LEG")
	aCoresNew := ExecBlock("QNC40LEG",.F.,.F.,{aCores})
	If ValType(aCoresNew) == "A"
		aCores := aCoresNew
	EndIf
EndIf     
     
                   
BrwLegenda(cCadastro,STR0032,aCores) 	// "Legenda"

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNCA040IMP ³ Autor ³ Aldo Marini Junior   ³ Data ³ 20.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime a Ficha de Ocorrencia/Nao-Conformidade em Grafico  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCA040IMP()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime a Ficha de Ocorrencia/Nao-Conformidade formato MsPrint ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QNCR051")
	ExecBlock( "QNCR051",.f.,.f.,{QI2->(Recno())})
Else
	QNCR050(QI2->(Recno()))
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC040Rev ³ Autor ³ Aldo Marini Junior    ³ Data ³ 18/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para geracao de Revisao da FNC                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC040Rev(ExpC1,ExpN1,ExpN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao do Cadastro                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNC040Rev(cAlias,nReg,nOpcAcao)

Local nRegObs   := QI2->(Recno())
Local nOrdObs   := QI2->(IndexOrd())
Local aUsrMat   := QNCUSUARIO()
Local aArea		:= {}
Local cChaveQI2 := QI2->QI2_FILIAL+QI2->QI2_FNC
Local lRet		:= .T.

Private lApelido := aUsrMat[1]
Private cMatFil  := aUsrMat[2]
Private cMatCod  := aUsrMat[3]
Private cMatDep  := aUsrMat[4]

If ( cMatFil+cMatCod <> QI2->QI2_FILRES+QI2->QI2_MATRES ) .And. ( cMatFil+cMatCod <> QI2->QI2_FILMAT+QI2->QI2_MAT )
	
	aArea := GetArea()
	
	DbSelectArea("QAA")
	DbSetOrder(1)
	DbSelectArea ("QAD")
	DbSetOrder(1)

	If QAA->(DbSeek(xFilial("QAA")+QI2->QI2_MATRES)) .And. !QA_SitFolh() // Usuario inativo
		If QAD->(DbSeek(xFilial("QAD")+QAA->QAA_CC)) .And. !Empty(QAD->QAD_MAT) .And. QAD->QAD_MAT <> cMatCod
			MsgAlert(OemToAnsi(STR0115)) //"O usuário responsável pela Ficha de Ocorrência / Não Conformidade está inativo, somente o responsável pelo Departamento poderá efetuar a revisão."
			lRet := .F.
		EndIf
	Else
		MsgAlert(OemToAnsi(STR0046)) // "Usuario nao autorizado a gerar Revisao."
		lRet := .F.
	EndIf
	
	RestArea(aArea)
	
EndIf

If lRet
	dbSetOrder(2)
    If dbSeek(cChaveQI2+QI2->QI2_REV)
    	dbSkip()
		If QI2->QI2_FILIAL+QI2->QI2_FNC == cChaveQI2
			MsgAlert(OemToAnsi(STR0047)) // "Ja existe uma Revisao em andamento ou superior."
			dbSetOrder(nOrdObs)
			dbGoTo(nRegObs)
			Return Nil
		Endif
    Endif

	dbSetOrder(nOrdObs)
	dbGoTo(nRegObs)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Permite apenas a Geracao de Revisao se o Plano de Acao estiver BAIXADO e ³
	//³ se o numero da revisao for menor que "99"(limite de revisoes)            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(QI2->QI2_CONREA)
		If Val(QI2->QI2_REV) < 99
				If QNC040Alt(cAlias,nReg,8) == 1    //  Terceiro parametro "8" = Gera Revisao
				dbSelectArea("QI2")
				dbGoTo(nRegObs)
				RecLock("QI2",.F.)
			    QI2->QI2_OBSOL := "S"
				MsUnLock()				
				dbSkip()
			Endif
		Endif
	Else
		MsgAlert(OemToAnsi(STR0048)) // "Nao sera permitida a Geracao de Revisao para Lancamentos pendentes."
	Endif
Endif

dbSelectArea("QI2")
dbSetOrder(nOrdObs)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC040Foll³ Autor ³ Aldo Marini Junior    ³ Data ³ 27/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para visualizar o Follow-Up da FNC                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC040Foll(cAlias,nReg,nOpcAcao)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao do Cadastro                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC040Foll(cAlias,nReg,nOpcAcao)
Local oDlg
Local oTree
Local oBtn1, oBtn2, oBtn3, oBtn4, oBtn5
Local aTipQI6 := {}
Local aTipCau := {}
Local cMotRev := StrTran(AllTrim(MSMM(QI2->QI2_MOTREV)),chr(13)+chr(10),"")
Local lAnexo  := .F.
Local aUsrMat := QNCUSUARIO()
Local aStatus := {"  0%"," 25%"," 50%"," 75%","100%",STR0113}//"Reprovado"
Local lSigilo := .T.
Local cBarRmt := IIF(IsSrvUnix(),"/","\")

Private cQPathFNC:= QA_TRABAR(Alltrim(GetMv("MV_QNCPDOC")))
Private aQPath   := QDOPATH()
Private cQPathTrm:= aQPath[3]

Private cMatFil  := aUsrMat[2]
Private cMatCod  := aUsrMat[3]

// Variaveis utilizadas na pesqusa de texto
Private nSeqTree   := 0
Private cChaveTree := Space(100)
Private cChaveSeq  := "0000"
Private lEditPTree := .T.

If !Right( cQPathFNC,1 ) == cBarRmt
	cQPathFNC := cQPathFNC + cBarRmt
Endif

If !Right( cQPathTrm,1 ) == cBarRmt
	cQPathFNC := cQPathTrm + cBarRmt
Endif

QNCCBOX("QI6_TIPO",@aTipQI6)
QNCCBOX("QI6_RAIZ",@aTipCau)

dbSelectArea("QDH")
dbSetOrder(1)
Set Filter to

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se FNC eh Sigilosa. Somente Responsavel e Digitador podem Manipular  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If QI2->QI2_SIGILO == "1"	
	If Existblock("QNC40SIG") //Ponto de Entrada para deixar que uma FNC sigilosa seja visualizada por alguns usuarios
		lSigilo := Execblock("QNC40SIG",.F.,.F.,{cMatFil,cMatCod})
	Endif
	If ! (cMatFil+cMatCod == QI2->QI2_FILMAT+QI2->QI2_MAT .or. ;
	   	  cMatFil+cMatCod == QI2->QI2_FILRES+QI2->QI2_MATRES) .And. lSigilo
		MsgAlert(OemToAnsi(STR0107)+Chr(13)+;		// "Ficha de Ocorrencias / Nao-conformidades sigilosa"
		OemToAnsi(STR0108 + ;		//"Somente o usuario digitador ("
		AllTrim(Posicione("QAA",1, QI2->QI2_FILMAT+QI2->QI2_MAT,"QAA_NOME")) + ;
		STR0109 + ; // ") e/ou responsavel ("
		AllTrim(Posicione("QAA",1, QI2->QI2_FILRES+QI2->QI2_MATRES,"QAA_NOME"))+ STR0110 ))	// ") tem acesso"
		Return Nil
	Endif
Endif

dbSelectArea("QI2")
RegToMemory("QI2",.F.)

DEFINE MSDIALOG oDlg FROM 0,0 TO 394,634 PIXEL TITLE OemToAnsi(STR0039+" "+STR0019+TransForm(QI2->QI2_FNC,PesqPict("QI2","QI2_FNC"))+"-"+QI2->QI2_REV)	// "Follow-UP" ### "Ficha N.C.: "

oTree := DbTree():New(15, 3, 197, 315, oDlg,,,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe documento Anexo.  		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If QIF->(DbSeek(QI2->QI2_FILIAL+QI2->QI2_FNC+QI2->QI2_REV))
	lAnexo:= .T.
EndIf

@ 3,3 BUTTON oBtn1 PROMPT OemToAnsi(STR0016) SIZE 55,10 OF oDlg PIXEL ; // "Documento Anexo"
      ACTION FQNCANEXO("QIF",2,QI2->QI2_STATUS) ;
      WHEN lAnexo
          
@ 3,58 BUTTON oBtn2 PROMPT OemToAnsi(STR0015) SIZE 55,10 OF oDlg PIXEL ; // "Plano de Acao"
       ACTION QNC040CdAca();
       WHEN !Empty(QI2->QI2_CODACA+QI2->QI2_REVACA)

@ 3,113 BUTTON oBtn3 PROMPT OemToAnsi(STR0049) SIZE 55,10 OF oDlg PIXEL ; // "Pesquisa Texto"
       ACTION (lEditPTree := .T.,QNC040PTREE(@oTree,@oBtn3,@oBtn5),oBtn3:Refresh(),oBtn5:Refresh())

@ 3,168 BUTTON oBtn5 PROMPT OemToAnsi(STR0078) SIZE 55,10 OF oDlg PIXEL ; // "Proxima Pesquisa"
       ACTION (QNC040PTREE(@oTree,@oBtn3,@oBtn5),oBtn3:Refresh(),oBtn5:Refresh())

oBtn5:Disable()

@ 3,223 BUTTON oBtn4 PROMPT OemToAnsi(STR0050) SIZE 55,10 OF oDlg PIXEL ; // "Sair"
        ACTION oDlg:End()

DBADDITEM oTree PROMPT OemToAnsi(PADR(STR0053+QI2->QI2_FILMAT+"-"+QI2->QI2_MAT+" "+QA_NUSR(QI2->QI2_FILMAT,QI2->QI2_MAT),100)) RESOURCE "BMPUSER"  CARGO StrZero(nSeqTree++,4)	// "Usuario Originador: "
DBADDITEM oTree PROMPT OemToAnsi(PADR(STR0054+QI2->QI2_FILRES+"-"+QI2->QI2_MATRES+" "+QA_NUSR(QI2->QI2_FILRES,QI2->QI2_MATRES),100)) RESOURCE "BMPUSER"  CARGO StrZero(nSeqTree++,4) // "Usuario Responsavel: "

DBADDTREE oTree PROMPT OemToAnsi(PADR(STR0055,100)) RESOURCE "PESQUISA" CARGO StrZero(nSeqTree++,4)	//"Descricao Detalhada"
	QNC040ADDTRE(@oTree,AllTrim(MSMM(QI2->QI2_DDETA)),80)
DBENDTREE oTree

If !Empty(QI2->QI2_DISPOS)
	DBADDTREE oTree PROMPT OemToAnsi(PADR(STR0056,100)) RESOURCE "PESQUISA" CARGO StrZero(nSeqTree++,4)	// "Disposicao"
		QNC040ADDTRE(@oTree,AllTrim(MSMM(QI2->QI2_DISPOS)),80)
	DBENDTREE oTree
Endif

If !Empty(cMotRev)
	DBADDTREE oTree PROMPT OemToAnsi(PADR(STR0057,100)) RESOURCE "PESQUISA" CARGO StrZero(nSeqTree++,4)	// "Motivo da Revisao"
		QNC040ADDTRE(@oTree,cMotRev,80)
	DBENDTREE oTree
Endif

If !Empty(QI2->QI2_CODACA)
	DBADDTREE oTree PROMPT OemToAnsi(STR0044+PADR(TransForm(QI2->QI2_CODACA,PesqPict("QI2","QI2_CODACA"))+"-"+QI2->QI2_REVACA,100)) RESOURCE "NEXT" CARGO StrZero(nSeqTree++,4)	// "Plano de Acao No. "
	
	If !Empty(QI3->QI3_MOTREV)
		DBADDTREE oTree PROMPT OemToAnsi(PADR(STR0057,100)) RESOURCE "PESQUISA" CARGO StrZero(nSeqTree++,4)	// "Motivo da Revisao"
		QNC040ADDTRE(@oTree,AllTrim(MSMM(QI3->QI3_MOTREV)),80)
		DBENDTREE oTree
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Etapas do Plano de Acao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QI5")
	If dbSeek(xFilial("QI5")+QI2->QI2_CODACA+QI2->QI2_REVACA)
		DBADDTREE oTree PROMPT OemToAnsi(STR0058+PADR(TransForm(QI2->QI2_CODACA,PesqPict("QI2","QI2_CODACA"))+"-"+QI2->QI2_REVACA,100)) RESOURCE "BMPTABLE" CARGO StrZero(nSeqTree++,4)	// "Etapas do Plano de Acao No. "
		While !Eof() .And. xFilial("QI5")+QI5->QI5_CODIGO+QI5->QI5_REV == xFilial("QI2")+QI2->QI2_CODACA+QI2->QI2_REVACA
			cDescComp := AllTrim(MSMM(QI5->QI5_DESCCO))
			cDescObs  := AllTrim(MSMM(QI5->QI5_DESCOB))
			
			DBADDTREE oTree PROMPT PADR(QI5->QI5_TPACAO +"-"+Alltrim(FQNCDSX5("QD",QI5->QI5_TPACAO))+" "+aStatus[SuperVal(QI5->QI5_STATUS)+1],100) RESOURCE If(QI5->QI5_STATUS=="4","CHECKED","UNCHECKED") CARGO StrZero(nSeqTree++,4)
			DBADDITEM oTree PROMPT QI5->QI5_FILMAT+"-"+QI5->QI5_MAT+" "+AllTrim(QA_NUSR(QI5->QI5_FILMAT,QI5->QI5_MAT)) RESOURCE "BMPUSER" CARGO StrZero(nSeqTree++,4)
			DBADDITEM oTree PROMPT OemToAnsi(STR0059+DTOC(QI5->QI5_PRAZO)+" "+STR0060+DTOC(QI5->QI5_REALIZ)) RESOURCE "BTCALEND" CARGO StrZero(nSeqTree++,4)	// "Prazo Execucao: " ### "Data Realizacao: "
			DBADDITEM oTree PROMPT OemToAnsi(STR0061+AllTrim(QI5->QI5_DESCRE))  RESOURCE "PMSDOC" CARGO StrZero(nSeqTree++,4)	// "Descricao Resumida: "
			If !Empty(cDescComp)
				QNC040ADDTRE(@oTree,OemToAnsi(STR0062+AllTrim(cDescComp)),90)	//"Descricao Completa: "
			Endif
			If !Empty(cDescObs)
				QNC040ADDTRE(@oTree,OemToAnsi(STR0063+AllTrim(cDescObs)),90)	// "Observacao: "
			Endif
			DBENDTREE oTree
			dbSkip()
		EndDo
		DBENDTREE oTree
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Causas do Plano de Acao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QI6")
	If dbSeek(xFilial("QI6")+QI2->QI2_CODACA+QI2->QI2_REVACA)
		DBADDTREE oTree PROMPT PADR("Causas",100) RESOURCE "BMPCPO" CARGO StrZero(nSeqTree++,4)
		While !Eof() .And. xFilial("QI6")+QI6->QI6_CODIGO+QI6->QI6_REV == xFilial("QI2")+QI2->QI2_CODACA+QI2->QI2_REVACA
			cDescCausa := AllTrim(MSMM(QI6->QI6_DESCR))
			
			DBADDITEM oTree PROMPT OemToAnsi(STR0064+aTipQI6[Val(QI6->QI6_TIPO)]+Space(10)+STR0065+ aTipCau[Val(QI6->QI6_RAIZ)]) RESOURCE "NEXT" CARGO StrZero(nSeqTree++,4)	// "Tipo de Causa: " ### "Causa Raiz?"
			DBADDITEM oTree PROMPT OemToAnsi(STR0066+FQNCNTAB("1",QI6->QI6_CAUSA)) RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4)	// "Causa: "
			DBADDITEM oTree PROMPT OemToAnsi(STR0067+AllTrim(QI6->QI6_METODO)) RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4)	// "Metodo Utilizado: "
			If !Empty(cDescCausa)
				QNC040ADDTRE(@oTree,OemToAnsi(STR0068+AllTrim(cDescCausa)),100,.F.)	// "Descricao da Causa: "
			Endif
			dbSkip()
		EndDo
		DBENDTREE oTree
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Documentos do Plano de Acao                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QI7")
	If dbSeek(xFilial("QI7")+QI2->QI2_CODACA+QI2->QI2_REVACA)
		DBADDTREE oTree PROMPT PADR(STR0069,100) RESOURCE "COLINC" CARGO StrZero(nSeqTree++,4)	// "Documentos"
		While !Eof() .And. xFilial("QI7")+QI7->QI7_CODIGO+QI7->QI7_REV == xFilial("QI7")+QI2->QI2_CODACA+QI2->QI2_REVACA
			DBADDTREE oTree PROMPT PADR(QI7->QI7_DOC+"-"+QI7->QI7_RV,100)  RESOURCE "PMSDOC" CARGO StrZero(nSeqTree++,4)
			DBADDITEM oTree PROMPT PADR(OemToAnsi(STR0070+QI7->QI7_TPDOC+"-"+FQNCDSX5("QC",QI7->QI7_TPDOC)),100)  RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4)	// "Tipo de Documento: "
			If QDH->(dbSeek(If(FWModeAccess("QDH")=="C",xFilial("QDH"),QI7->QI7_FILIAL)+PADR(QI7->QI7_DOC,16)+QI7->QI7_RV))
				DBADDITEM oTree PROMPT OemToAnsi(STR0071+QDH->QDH_TITULO) RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4)	// "Titulo: "
			Else
				DBADDITEM oTree PROMPT OemToAnsi(STR0071+STR0072) RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4)	// "Titulo: " ### "Documento Externo"
			Endif
			DBENDTREE oTree
			dbSkip()
		EndDo
		DBENDTREE oTree
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Custos do Plano de Acao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QI8")
	If dbSeek(xFilial("QI8")+QI2->QI2_CODACA+QI2->QI2_REVACA)
		DBADDTREE oTree PROMPT PADR(STR0072,100) RESOURCE "BUDGET" CARGO StrZero(nSeqTree++,4)	// "Custos"
		While !Eof() .And. xFilial("QI8")+QI8->QI8_CODIGO+QI8->QI8_REV == xFilial("QI8")+QI2->QI2_CODACA+QI2->QI2_REVACA
			DBADDITEM oTree PROMPT OemToAnsi(STR0073+Padr(FQNCDSX5("QB",QI8->QI8_CUSTO),30)+STR0074+ AllTrim(Transform(QI8->QI8_VLCUST,"@E 999,999,999.99"))) RESOURCE "PMSDOC" CARGO StrZero(nSeqTree++,4)	// "Descricao: " ### " Valor Custo "
			dbSkip()
		EndDo
		DBENDTREE oTree
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Equipes                                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QI4")
	If dbSeek(xFilial("QI4")+QI2->QI2_CODACA+QI2->QI2_REVACA)
		DBADDTREE oTree PROMPT PADR(STR0075,100) RESOURCE "BMPGROUP" CARGO StrZero(nSeqTree++,4)	// "Equipes"
		While !Eof() .And. xFilial("QI4")+QI4->QI4_CODIGO+QI4->QI4_REV == xFilial("QI4")+QI2->QI2_CODACA+QI2->QI2_REVACA
			DBADDITEM oTree PROMPT QA_NUSR(QI4->QI4_FILMAT,QI4->QI4_MAT) RESOURCE "BMPUSER" CARGO StrZero(nSeqTree++,4)
			dbSkip()
		EndDo
		DBENDTREE oTree
	Endif
	
	DBENDTREE oTree
	
Endif

ACTIVATE MSDIALOG oDlg CENTER

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC040ADDTRE³ Autor ³ Aldo Marini Junior  ³ Data ³ 27/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para adicionar linha no Tree                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC040ADDTRE(oTree,cTexto,nTam,lResource)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto do Tree para ser atualizado                 ³±±
±±³          ³ ExpC1 = Caracter contendo a descricao a ser inserida       ³±±
±±³          ³ ExpN1 = Numerico definindo o tamanho da descricao do item  ³±±
±±³          ³ ExpL1 = Logico definindo se havera Resource no item        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC040ADDTRE(oTree,cTexto,nTam,lResource)
Local nT   := 0
Local nCont:= 1
Local nTot := Int(Len(cTexto)/nTam)+If(Len(cTexto)-Int(Len(cTexto)/nTam)>0,1,0)
Local aTextos := {}
Local aAuxTexto := {}
Default lResource := .T.

If At(CHR(13)+CHR(10),cTexto) > 0
	While (nPos:=At(CHR(13)+CHR(10),cTexto)) > 0
		aAdd(aTextos,SubStr(cTexto,1,nPos-1))	
		cTexto := SubStr(cTexto,nPos+2,Len(cTexto))
	Enddo
	If Len(AllTrim(cTexto)) > 0
		aAdd(aTextos,cTexto)	
	Endif
	For nT :=1 to Len(aTextos)
		If Len(aTextos[nT]) <= nTam
			aAdd(aAuxTexto,aTextos[nT])
		Else		
			While Len(AllTrim(aTextos[nT])) > 0
				aAdd(aAuxTexto,SubStr(aTextos[nT],1,nTam))
				nCont := If((1 + nTam)>Len(aTextos[nT]),(Len(aTextos[nT])+1),(1 + nTam))
				aTextos[nT] := SubStr(aTextos[nT],nCont,Len(aTextos[nT]))
			Enddo
		Endif
	Next
	aTextos := aClone(aAuxTexto)
Else
	For nT := 1 to nTot
		aAdd(aTextos,SubStr(cTexto,nCont,nTam))
		nCont := nCont + nTam
	Next
Endif

For nT :=1 to Len(aTextos)
	If nT == 1 .And. lResource
		DBADDITEM oTree PROMPT aTextos[nT] RESOURCE "PMSDOC" CARGO StrZero(nSeqTree++,4)
	Else
		DBADDITEM oTree PROMPT aTextos[nT] RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4)
	Endif
Next

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC040CdAca ³ Autor ³ Aldo Marini Junior  ³ Data ³ 27/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para visualizar o Plano de Acao(Cadastro)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC040CdAca()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC040CdAca()
  
QI3->(dbSetOrder(2))
If QI3->(dbSeek(xFilial("QI3")+QI2->QI2_CODACA+QI2->QI2_REVACA))
	QNC030Alt("QI3",QI3->(Recno()),2)
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNCA040TVS  ³ Autor ³ Aldo Marini Junior  ³ Data ³ 27/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para acessar opcoes qdo acionado click da direita ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCA040TVS(nTipo,oTree)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1-Numerico contendo a opcao do POPUP                   ³±±
±±³          ³ ExpO1-Objeto do Tree                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNCA040TVS(nTipo,oTree,oBtn3,oBtn5)
Local nOrdQI2 := QI2->(IndexOrd())
Local nRegQI2 := QI2->(Recno())
Local cAlias  := Alias()

RegToMemory("QI2",.F.)

If nTipo == 1	// Visualiza Documento Anexo
	FQNCANEXO("QIF",2,QI2->QI2_STATUS) 
ElseIf nTipo == 2	// "Pesquisa Texto"
	lEditPTree := .T.
	QNC040PTREE(@oTree,@oBtn3,@oBtn5)
ElseIf nTipo == 3	// "Cadastro FNC"
	QNC040Alt("QI2",QI2->(Recno()),2)
ElseIf nTipo == 4	// "Cadastro Plano"
	QNC040CdAca()
Endif

dbSelectArea(cAlias)
QI2->(dbSetOrder(nOrdQI2))
QI2->(dbGoTo(nRegQI2))

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC040PTREE ³ Autor ³ Aldo Marini Junior  ³ Data ³ 27/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para pesquisar texto no Tree                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC040PTREE(oTree,oBtn3,oBtn5)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1-Objeto do Tree                                       ³±±
±±³          ³ ExpO2-Objeto do botao "Pesquisa Texto"                     ³±±
±±³          ³ ExpO3-Objeto do botao "Proxima Pesquisa"                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNC040PTREE(oTree,oBtn3,oBtn5)

Local nOpcao := 0
Local oDlg
Local oBtn1
Local oBtn2
Local lAchou := .F.

If lEditPTree
	DEFINE MSDIALOG oDlg FROM 0,0 TO 080,634 PIXEL TITLE OemToAnsi(STR0049)	// "Pesquisa Texto"

    cChaveTree := Padr(cChaveTree,100)
	@ 010,05 MSGET cChaveTree SIZE 310,08 OF oDlg PIXEL

	DEFINE SBUTTON oBtn1 FROM 25,005 TYPE 1 PIXEL ENABLE OF oDlg ACTION ( nOpcao:=1,oDlg:End() )
	DEFINE SBUTTON oBtn2 FROM 25,035 TYPE 2 PIXEL ENABLE OF oDlg ACTION ( nOpcao:=2,oDlg:End() )

	ACTIVATE MSDIALOG oDlg CENTERED
Endif

If (nOpcao == 1 .Or. nOpcao == 0) .And. !Empty(AllTrim(cChaveTree))
	cChaveTree := UPPER(AllTrim(cChaveTree))
	dbSelectArea(oTree:cArqTree)
	dbGoTop()
	While !Eof()
		If cChaveTree $ UPPER(T_PROMPT)
			If (nOpcao == 0 .And. T_CARGO > cChaveSeq) .Or. nOpcao == 1
				oTree:TreeSeek(T_CARGO)
				oTree:Refresh()
				// Colocado duas vezes para posicionar na linha onde esta o texto
				// porque se buscar uma vez posiciona no Item pai.                
				oTree:TreeSeek(T_CARGO)
				oTree:Refresh()
				cChaveSeq := T_CARGO
				lAchou := .T.
				lEditPTree := .F.
				Exit
			Endif
		Endif
		dbSkip()
	Enddo
	If !lAchou
		If cChaveSeq <> "0000"
			oBtn5:Disable()
			oBtn5:Refresh()
			lEditPTree := .T.
		Endif
		MsgAlert(OemToAnsi(STR0076+" '"+cChaveTree+"' "+STR0077))	// "Texto" ### "nao encontrado"
	Else
		oBtn5:Enable()
		oBtn5:Refresh()
		lEditPTree := .F.
	Endif
Endif

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC040FinPl ³ Autor ³ Eduardo de Souza    ³ Data ³ 08/10/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Finaliza Plano como Nao Procede quando FNC Nao Proc.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC040FinPl()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNC040FinPl()

Local nOrdQI2   := QI2->(IndexOrd())
Local nPosQI2   := QI2->(Recno())
Local nOrdQI3   := QI3->(IndexOrd())
Local nOrdQI5   := QI5->(IndexOrd())
Local nOrdQI9   := QI9->(IndexOrd())
Local lFimPlano := .T.
Local aUsuarios := {}
Local aUsrMat   := QA_USUARIO()
Local cTpMail   := "1"
Local cMsg      := ""
Local cLogin    := ""
Local lQNCEACAO := ExistBlock( "QNCEACAO" )
Private aMsg := {}

QI2->(DbSetOrder(2))
QI3->(DbSetOrder(2))
QI5->(DbSetOrder(1))
QI9->(DbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona no Plano de Acao correspondente a FNC. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (lFimPlano := QI3->(DbSeek(M->QI2_FILIAL+M->QI2_CODACA+M->QI2_REVACA)))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe outra FNC amarrada ao Plano.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QI9->(DbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV))
		While QI9->(!Eof()) .And. QI9->QI9_FILIAL+QI9->QI9_CODIGO+QI9->QI9_REV == QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV
			If QI9->QI9_FILIAL+QI9->QI9_FNC+QI9->QI9_REVFNC <> M->QI2_FILIAL+M->QI2_FNC+M->QI2_REV
				If QI2->(DbSeek(QI9->QI9_FILIAL+QI9->QI9_FNC+QI9->QI9_REVFNC))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Somente sera finalizado o Plano quando a FNC estiver encerrada.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Empty(QI2->QI2_CONREA)
						lFimPlano:= .F.
						Exit
					EndIf
  
				EndIf
			EndIf
			QI9->(DbSkip())
		EndDo
		QI2->(DbGoto(nPosQI2))
	EndIf

	If ! lFimPlano
		QI9->(DbSetOrder(2))
		If QI9->(DbSeek(M->QI2_FILIAL+M->QI2_FNC+M->QI2_REV))		// Removo a ficha do plano de acao
			RecLock( "QI2", .F. )
			QI2->QI2_CODACA := Space(Len(QI2->QI2_CODACA))
			QI2->QI2_REVACA := Space(Len(QI2->QI2_REVACA))
			QI2->(MsUnLock())

			RecLock( "QI9", .F. )
			QI9->(DbDelete())
			QI9->(MsUnLock())
		Endif
		QI9->(DbSetOrder(1))
	Endif	
EndIf

If lFimPlano
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Finaliza o Plano com Status da FNC Nao Procede      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock("QI3",.F.)
	QI3->QI3_STATUS:= M->QI2_STATUS
	QI3->QI3_ENCREA:= dDataBase
	QI3->(MsUnlock())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Finaliza as Etapas quando a FNC Nao Procede ou Cancelada. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QI5->(DbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV))
	
		While QI5->(!Eof()) .And. QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV == QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV
	
			If QI5->QI5_PEND # "N"
				RecLock("QI5",.F.)
	
				If Empty(QI5->QI5_PRAZO)
					QI5->QI5_PRAZO := dDataBase
				Endif
	
				If Empty(QI5->QI5_REALIZ)
					QI5->QI5_REALIZ := dDataBase
				Endif
	
				QI5->QI5_PEND  := "N"
				QI5->QI5_STATUS:= "4"
	
				If QI3->QI3_STATUS = "4"
					QI5->QI5_DESCRE	:= OemToAnsi(STR0084)	// "Plano de Acao nao procede"
				Else
					QI5->QI5_DESCRE	:= OemToAnsi(STR0043)	// "*** Plano de Acao CANCELADO ***"
				EndIf
				QI5->(MsUnlock())			
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Envio de e-Mail para o responsavel da Etapa            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cMatFil+cMatCod <> QI5->QI5_FILMAT+QI5->QI5_MAT
	
					If QAA->(dbSeek(QI5->QI5_FILMAT+QI5->QI5_MAT)) .And. QAA->QAA_RECMAI == "1"		
	
						cLogin:= QAA->QAA_LOGIN
	
						If Ascan(aUsuarios,{ |x| x[1] == cLogin }) == 0
	
							If !Empty(QAA->QAA_EMAIL)					
								cMail:= AllTrim(QAA->QAA_EMAIL)
								cTpMail:= QAA->QAA_TPMAIL
			
								If cTpMail == "1"								
									cMsg := QNCSENDMAIL(2,OemToAnsi(STR0084))	// "Plano de Acao nao procede"
								Else
									cMsg := OemToAnsi(STR0084)+CHR(13)+CHR(10)	// "Plano de Acao nao procede"
									cMsg += Replicate("-",80)+CHR(13)+CHR(10)
									cMsg += OemToAnsi(STR0055)+CHR(13)+CHR(10)	// "Descricao Detalhada:"
									cMsg += MSMM(QI3->QI3_PROBLE,80)+CHR(13)+CHR(10)
									cMsg += Replicate("-",80)+CHR(13)+CHR(10)
									cMsg += CHR(13)+CHR(10)
									cMsg += CHR(13)+CHR(10)
									cMsg += OemToAnsi(STR0027)+CHR(13)+CHR(10)	// "Atenciosamente "
									cMsg += QA_NUSR(cMatFil,cMatCod,.F.)+CHR(13)+CHR(10)
									cMsg += QA_NDEPT(cMatDep,.T.,cMatFil)+CHR(13)+CHR(10)
									cMsg += CHR(13)+CHR(10)
									cMsg += OemToAnsi(STR0028)	// "Mensagem gerada automaticamente pelo Sistema SIGAQNC - Controle de Nao-conformidades"
								Endif
								
								cAttach := ""
								aMsg:={{OemToAnsi(STR0044)+" "+TransForm(QI3->QI3_CODIGO,PesqPict("QI3","QI3_CODIGO"))+"-"+QI3->QI3_REV+Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5), cMsg, cAttach } }	// "Plano de Acao No. "
								
								// Geracao de Mensagem para o Responsavel do Plano de Acao
								If lQNCEACAO
									aMsg := ExecBlock( "QNCEACAO", .f., .f., { OemToAnsi(STR0083),.F. } ) // "Todas as Etapas foram Finalizadas, favor verificar Plano de Acao no Sistema."
								Endif
								
								aAdd(aUsuarios,{cLogin,cMail,aMsg} )
							Endif
						EndIf
					Endif
				Endif
				
			EndIf
			QI5->(DbSkip())
		EndDo
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envio de e-Mail para o responsavel do Plano de Acao    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cMatFil+cMatCod <> QI3->QI3_FILMAT+QI3->QI3_MAT
			If QAA->(dbSeek(QI3->QI3_FILMAT + QI3->QI3_MAT )) .And. QAA->QAA_RECMAI == "1"		
	
				If !Empty(QAA->QAA_EMAIL)					
	
					cTpMail:= QAA->QAA_TPMAIL					
	
					If cTpMail == "1"
						cMail:= AllTrim(QAA->QAA_EMAIL)
						cMsg := QNCSENDMAIL(2,OemToAnsi(STR0083)) // "Todas as Etapas foram Finalizadas, favor verificar Plano de Acao no Sistema."
					Else
						cMsg := OemToAnsi(STR0083)+CHR(13)+CHR(10)	// "Todas as Etapas foram Finalizadas, favor verificar Plano de Acao no Sistema."
						cMsg += Replicate("-",80)+CHR(13)+CHR(10)
						cMsg += OemToAnsi(STR0055)+CHR(13)+CHR(10)	// "Descricao Detalhada:"
						cMsg += MSMM(QI3->QI3_PROBLE,80)+CHR(13)+CHR(10)
						cMsg += Replicate("-",80)+CHR(13)+CHR(10)
						cMsg += CHR(13)+CHR(10)
						cMsg += CHR(13)+CHR(10)
						cMsg += OemToAnsi(STR0027)+CHR(13)+CHR(10)	// "Atenciosamente "
						cMsg += QA_NUSR(cMatFil,cMatCod,.F.)+CHR(13)+CHR(10)
						cMsg += QA_NDEPT(cMatDep,.T.,cMatFil)+CHR(13)+CHR(10)
						cMsg += CHR(13)+CHR(10)
						cMsg += OemToAnsi(STR0028)	// "Mensagem gerada automaticamente pelo Sistema SIGAQNC - Controle de Nao-conformidades"
					Endif
					
					cAttach := ""
					aMsg:={{OemToAnsi(STR0044)+" "+TransForm(QI3->QI3_CODIGO,PesqPict("QI3","QI3_CODIGO"))+"-"+QI3->QI3_REV+Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5), cMsg, cAttach } }	// "Plano de Acao No. "
					
					// Geracao de Mensagem para o Responsavel do Plano de Acao
					IF ExistBlock( "QNCRACAO" )
						aMsg := ExecBlock( "QNCRACAO", .f., .f., { OemToAnsi(STR0083),.F. } ) // "Todas as Etapas foram Finalizadas, favor verificar Plano de Acao no Sistema."
					Endif
					
					aAdd(aUsuarios,{QAA->QAA_LOGIN, cMail,aMsg} )
				Endif
			Endif
		Endif
	EndIf
	
	If Len(aUsuarios) > 0
		QaEnvMail(aUsuarios,,,,aUsrMat[5],"2")
	EndIf
Endif

	
QI2->(DbSetOrder(nOrdQI2))
QI3->(DbSetOrder(nOrdQI3))
QI5->(DbSetOrder(nOrdQI5))
QI9->(DbSetOrder(nOrdQI9))

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q040Preenche³ Autor ³ Cicero Cruz         ³ Data ³ 20/01/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preenche  alguns  campos  da Tela de FNC                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracoes                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q040Preenche(aCampos)
Local nPQNC 	:= 0
Local nI 		:= 0
Local bCampo	:= { |nCPO| Field( nCPO ) }
Local cOriFil	:= AllTrim(GetMV("MV_QNCFORI",.F.,cFilAnt))
Local cOriDep	:= AllTrim(GetMV("MV_QNCDORI",.F.,"1234567890123"))
Local cDesFil	:= AllTrim(GetMV("MV_QNCFDES",.F.,cFilAnt))
Local cDesDep	:= AllTrim(GetMV("MV_QNCDDES",.F.,"1234567890123"))
Local cResFil	:= AllTrim(GetMV("MV_QNCFRES",.F.,IIF(Empty(cMatFil), cFilAnt, cMatFil)))//cMatFil: filial do usuario logado obtido através do Login Usr.(QAA_LOGIN) logado +- linha 172
Local cResMat	:= AllTrim(GetMV("MV_QNCMRES",.F.,"1234567890"))
Local aUsrMat   := QNCUSUARIO()
Local aStruQI2 := FWFormStruct(3, "QI2",, .F.)[3]
Local nX

Default aCampos := {}

M->QI2_FILORI	:= cOriFil
M->QI2_ORIDEP	:= cOriDep

M->QI2_FILDEP	:= cDesFil
M->QI2_DESDEP	:= cDesDep

M->QI2_FILRES	:= cResFil
M->QI2_MATRES	:= cResMat

For nX := 1 To Len(aStruQI2)
	IF GetSx3Cache(aStruQI2[nX,1], "X3_TIPO") == "M"
		If (nPQNC := aScan(aCampos,{ |X| UPPER(ALLTRIM(X[1])) == UPPER(ALLTRIM(aStruQI2[nX,1]))})) > 0
			&("M->"+UPPER(ALLTRIM(aStruQI2[nX,1]))) := aCampos[nPQNC,2]
		Endif
	Endif
Next nX
            
dbSelectArea("QI2")
For nI:=1 to FCount()
	cCampo := EVAL(bCampo,nI)
	If (nPQNC := aScan(aCampos,{ |X| UPPER(ALLTRIM(X[1])) == UPPER(Field(nI))})) > 0
		M->&(cCampo) := aCampos[nPQNC,2]
	Endif
Next
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q040VTPMS ºAutor  ³Denis Martins       º Data ³  01/28/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se ja existe FNC no PMS. Em caso afirmativo, nao   º±±
±±º          ³permite a cancelar a FNC                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QNCA040                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q040VTPMS(nOpcao,nOpc)
Local lRet := .t.
Local lTmkPms := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)

If nOpc <> 2	
	If nOpcao == 3 .and. lTmkPms //Para opcao X da tela principal com existencia de tarefa no PMS
		If GetMv("MV_QTMKPMS",.F.,1) == 3 .or. GetMv("MV_QTMKPMS",.F.,1) == 4
			DbselectArea("AF9")
			AF9->(dbSetOrder(6))
			If AF9->(MsSeek(xFilial("AF9")+M->QI2_FNC+M->QI2_REV))
			   MessageDlg(STR0114) //"Esta FNC e/ou Plano ja esta/estao amarrado(s) na(s) tarefa(s) - Monitor PMS. Deve-se salvar a FNC, executar a tarefa rejeitando-a."
			   lRet := .f.			
			Endif                         
		Endif
	Endif
EndIf

Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QNC040TMK ³ Autor ³Adriano da Silva         ³ Data ³ 11/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Botão Para Visualizar Chamados do TMK					        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QNC040TMK()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QNCA040                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNC040TMK()

Local aArea 	:= GetArea()
Local nAuxMod   := nModulo

DbselectArea("ADE")		//Chamados de Help Desk
ADE->(DbSetOrder(1))	//ADE_FILIAL+ADE_CODIGO	
If ADE->(DbSeek(xFilial("ADE")+QI2->QI2_NCHAMA))	
    
    nModulo := 13
        	
   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Função Padrão Para Manutenção do Chamado - Visualização	-TMKA503A		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TK503AOpc("ADE", ADE->(Recno()),2,,)

EndIf

RestArea(aArea)

nModulo := nAuxMod

Return

//----------------------------------------------------------------------
/*/{Protheus.doc} Q040GetSX3 
Busca dados da SX3 
@author Brunno de Medeiros da Costa
@since 17/04/2018
@version 1.0
@return aHeaderTmp
/*/
//---------------------------------------------------------------------- 
Static Function Q040GetSX3(cCampo, cTitulo, cWhen)
Local aHeaderTmp := {}
aHeaderTmp:= {IIf(Empty(cTitulo), QAGetX3Tit(cCampo), cTitulo),;
              GetSx3Cache(cCampo,'X3_CAMPO'),;
              GetSx3Cache(cCampo,'X3_PICTURE'),;
              GetSx3Cache(cCampo,'X3_TAMANHO'),;
              GetSx3Cache(cCampo,'X3_DECIMAL'),;
              GetSx3Cache(cCampo,'X3_VALID'),;              
              GetSx3Cache(cCampo,'X3_USADO'),;
              GetSx3Cache(cCampo,'X3_TIPO'),;
              GetSx3Cache(cCampo,'X3_ARQUIVO') }
Return aHeaderTmp
