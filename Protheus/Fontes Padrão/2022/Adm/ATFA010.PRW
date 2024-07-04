#INCLUDE "Protheus.ch"
#INCLUDE "ATFA010.CH" 
#Include "ApWizard.ch"   

#DEFINE OPC_CONVERSAO 5 
//AMARRACAO PARA ATUALIZAR DATA DO RPO D-1
Static lA010Brow
Static lA010Brwt
Static aParamAuto := {}
// ******************************
// Controle de multiplas moedas  *
// ******************************
Static lMultMoed := FindFunction("AtfMoedas")
                                           
//Controle de AVP de Ativo
STATIC lAvpAtf := .F.
STATIC lAvpAtf2 := NIL

//Variaveis para importação da Classificação Contábil
Static __aEtapa   := {}     
Static __lExcImp  := .F.
Static __cProcPrinc := "ATFA010"

STATIC lIsRussia	:= If(cPaisLoc$"RUS",.T.,.F.)// CAZARINI - Flag to indicate if is Russia location

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ATFA010    ³ Autor ³ Claudinei M. Benzi    ³ Data ³ 01/08/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de atualiza‡„o de Ativos Imobilizados               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  DATA  ³ BOPS ³Program.³               ALTERACAO                      ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³03.06.98³      ³Eduardo ³ Desenvolvimento do CIAP                      ³±±
±±³22.06.98³      ³Alice   ³ Incluir os STRs                              ³±±
±±³20.08.98³      ³Alice   ³ Nao gravar se os campos obrigatorios nao esti³±±
±±³        ³      ³        ³ res preenchidos.BOPS 17237 A                 ³±±
±±³02.09.98³      ³Alice   ³ Tratar o tipo N5_TIPO="O"                    ³±±
±±³09.09.98³12479A³Alice   ³Nao gerar lacto na Alteracao                  ³±±
±±³02.12.98³      ³Alice   ³Tratar as opcoes de repetir ou nao a chapa    ³±±
±±³29.12.98³18099a³Alice   ³Emitir help ("AF010CTVAZ") qdo as contas nao  ³±±
±±³        ³      ³        ³estiverem cadastradas e confirmar a aquisicao.³±±
±±³07.04.99³      ³Alice   ³Alteracao na funcao af010Comp.                ³±±
±±³12.04.99³      ³Alice   ³Alteracao de macro para PROTHEUS.             ³±±
±±³28.10.99³      ³Alice   ³Tratar GetSX8Num                              ³±±
±±³03.11.99³      ³Alice   ³Tratar GetSX8Num na copia                     ³±±
±±³17.01.00³      ³Alice   ³Verificar se fim de arquivo                   ³±±
±±³01.09.09³      ³William ³Alteracao da Funcao ATFMOD3() para permitir a ³±±
±±³        ³      ³        ³edicao dos campos das abas 'Saude' e 'Imoveis'³±±
±±³        ³      ³        ³ao alterar um bem.							  ³±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function ATFA010(xAutoCab,xAutoItens,nOpcAuto,xParamAuto)
//Fonte descontinuado na versão 12
HELP(" ",1,"CTRDES12")
Return

Function ATFA010CAD(xAutoCab,xAutoItens,nOpcAuto,xParamAuto)

Local lCond		:= !Empty(Alltrim(SuperGetMv("MV_N3TPNEG",.F.,"")))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restringe acesso somente  ³
//³ ao SIGAATF                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(AMIIn(1,19,39,42))
	Return
Endif

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Variaveis para rotina automatica    ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private lAtfAuto  := ( ValType(xAutoCab) == "A"  .And. ValType(xAutoItens) == "A" )
Private aAutoCab  := {}
Private aAutoItens := {}    

aParamAuto := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variáveis utilizadas pela inclusao ³
//³ de bem pelo F3 do campo "Bem MNT"  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lFrota    := .F.
Private lDestMS   := .F.
Private lDestMS2  := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Vari veis          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCodigo := ""
Private aPos    := {  8,  4, 11, 74 }
Private lCab    := .T.
Private nCampos	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Estas vari veis informar„o se o processo de abertura e fechamento do   ³
//³  cprova ser„o feitos pelo atfa010 ou pelo programa externo que          ³
//³  chamou o atfa010. No programa chamador, lHeader e lTrailler ser„o      ³
//³  sinalizados com .F., informando que o programa chamador far  a         ³
//³  abertura e o fechamento do cprova.                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lContabiliza    := .T.
lHeader         := .T.
lTrailler       := .T.
cLoteAtf        := ""
cPadrao         := ""
lPadrao         := .F.
nTotal          := 0
cArquivo        := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Esta vari vel serve como sem foro para copia ou repeti‡„o de bens. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lCopia  := .F.

Private lCprova := .F.     	// Controla a contabiliza‡„o
Private lClassifica := .F.		// Para compatibilizar com a Classificacao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Esta variavel armazena o valor original de nCnt para         ³
//³ permitir altera‡„o do campo tipo apenas em linhas novas.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nOriginal := 0
Private lCriaAuto := .F.     //Se .t. permitir a copia de varios bens

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa                   ³
//³ ----------- Elementos contidos por dimensao ------------                  ³
//³ 1. Nome a aparecer no cabecalho                                           ³
//³ 2. Nome da Rotina associada                                               ³
//³ 3. Usado pela rotina                                                      ³
//³ 4. Tipo de Transa‡„o a ser efetuada                                       ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados                          ³
//³    2 - Simplesmente Mostra os Campos                                      ³
//³    3 -Inclui registros no Bancos de Dados                                 ³
//³    4 - Altera o registro corrente                                         ³
//³    5 - Remove o registro corrente do Banco de Dados                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef(.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Vari veis para filtro do browse ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aIndexFil		:= {}	
Private bFiltraBrw
Private cFilPad		:= ".T."
Private cFilEsp		:= ""
Private cFilter    := Nil

//-------------------------------------------------------------------------------------------------------------
//Inclusão de mesagem de alerta notificando quanto a descontinuação da rotina ATFA010
//Deve-se utilizar a rotina ATFA012
Help(" ",1,"ATFA010_END",,STR0175,1,0) //"A rotina ATFA010 foi descontinuada e substituída pela rotina ATFA012. Deve-se ajustar o menu para que a rotina apropriada seja acionada."
Return .F.
//-------------------------------------------------------------------------------------------------------------

//AVP
//Verifica se o AVP do ATF esta ativo
lAvpAtf := If(FindFunction("AFAvpAtf"),AFAvpAtf(),.f.)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa tecla F12 para ativar parametros de lan‡amentos contab.             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey( VK_F12, { || Pergunte("AFA010",.T.) } )
		  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as perguntas selecionadas                                         ³
//³ mv_par01 - Se mostra ou n„o os lan‡amentos cont beis                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("AFA010",.F.)

Private cMoedaAtf := GetMV("MV_ATFMOED")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := STR0007  //"Atualiza‡„o de Ativos Imobilizados"
Default lA010Brow := ExistBlock("A010BROW")
Default lA010Brwt := ExistBlock("A010BRWT")
cChave := IndexKey()

//PONTO DE ENTRADA - FILBROWSE
If lA010Brow
	cFilEsp := ExecBlock( "A010BROW", .F., .F. )
	cFilPad := IIF(ValType(cFilEsp) == "C", cFilEsp, cFilPad )
EndIf

//PONTO DE ENTRADA - MBROWSE
If lA010Brwt
	cFilter := ExecBlock( "A010BRWT", .F., .F. )
	cFilter := IIF(ValType(cFilter) == "C", cFilter, Nil )
Endif

//PONTO DE ENTRADA - ALTERAÇÃO INDICE
If ExistBlock("AF010BRO") 
	cChave := ExecBlock("AF010BRO",.F.,.F.,{cChave})
Endif  

//Verifica se o Ativo está atualizado
If FindFunction('ATFXKERNEL')
	ATFXKERNEL()
Else
	Help(" ",1,"ATFNOKER",,STR0036,1,0)//"Modulo SIGAATF desatualizado, por favor atualizar o ultimo update"
	cHelp := STR0036 //"Modulo SIGAATF desatualizado, por favor atualizar o ultimo update"
	cHelp := replace(cHelp,CRLF,' ')
	Final(cHelp)	
EndIf 

If lAtfAuto
	aAutoCab := xAutoCab
	aAutoItens := xAutoItens
	aParamAuto := IIf(xParamAuto<>NIL,xParamAuto,{})
	//Carrega os paremetros passados pela execauto
	AF010PerAut()
	MBrowseAuto(nOpcAuto,Aclone(aAutoCab),"SN1")
Else
		mBrowse( 6, 1,22,75,"SN1",,"N1_BAIXA",22,,, AtfLegenda("SN1"),,,,,,,,cFilter,)
EndIf

Set Key VK_F12 To

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AF010Comp ³ Autor ³ Wagner Xavier         ³ Data ³ 10.01.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Trata o complemento de um determinado ativo.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ATFA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Af010Comp( nOpc, cChave, lCriAuto, cTxtCriAuto )

Local cDescricao
Local cTexto
Local nLinhas 	:= 0
Local nPasso 	:= 0
Local nLinTotal := 0
Local lAppenda  := .T.
Local nPosTxt	:= 0
Local lProc		:= .T.

DEFAULT cChave	:= SN3->N3_FILIAL+SN3->N3_CBASE+SN3->N3_ITEM+SN3->N3_TIPO
Default lCriAuto := .F.
Default cTxtCriAuto := ""

cTexto := cTxtCriAuto
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  No caso de ser exclusao, nao apresenta a descri‡ao estendida       ³
//³  conforme solicitado pelo Wagner Xavier em 11/01/96                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 5
    Return .T.
Endif

If SN3->N3_FILIAL+SN3->N3_CBASE+SN3->N3_ITEM+SN3->N3_TIPO <> cChave
	SN3->(DbSeek(cChave))
Endif

SN3->(DbSeek(N3_FILIAL+N3_CBASE+N3_ITEM)) // Posiciona no primeiro registro da SN3 do ativo cadastrado.

If nOpc = 4 .And. SN2->(DbSeek(cChave))
	Afa160Alt("SN2", SN3->(Recno()), nOpc)
	Return .T.
Endif

nUltac      := 1
nInitCount  := 1
nAnterior   := 0
lGrava      := .F.
lDejaVu     := .F.
lResume     := .F.
lAlterado   := .F.
lUpdate     := .T.
lUseFunc    := .T.
lInsOn      := .F.
lScrolOn    := .F.
lWordWrap   := .F.
If lCopia  .Or. lCriAuto              // Se for copia busca a chave do item anterior
	cChave := cChaveSn2
Endif
IF Altera .or. nOpc == 2 .Or. lCopia .Or. lCriAuto
	If ! lCriAuto .Or. ;
		(lCriAuto .And. Empty(cTxtCriAuto))
		cTexto := Af010Texto(cChave)
	Endif	
End

If INCLUI
	If ExistBlock("AF10DESC")
		cTexto := ExecBlock("AF10DESC",.F.,.F.)
	Endif
Endif

If Empty( cTexto )
	cTexto := Spac(40) + Chr(13) + Chr(10) + Spac(40) + Chr(13) + Chr(10)
Endif

If Type('lAtfAuto') == "U" .Or. !lAtfAuto
	If ! lCriAuto .Or. ;
		(lCriAuto .And. Empty(cTxtCriAuto))
		lProc:= Af160Estendida(@cTexto) 
	Endif	
Else
	If (nPosTxt	:=	Ascan(aAutoCab,{|x| Upper(x[1]) == 'CTEXTO' })) > 0
		cTexto	:=	aAutocab[nPosTxt][2]
	Endif
	nOpc := 1
EndIf

If nOpc # 2 .And. lProc
	lGrava  := .T.
	nLinhas := 0
	nPasso  := 0
	nLinTotal := MlCount( cTexto , 40)
	dbSelectArea("SN2")
	While nPasso <= nLinTotal
		lAppenda  := .F.
		cDescricao := MemoLine( cTexto, 40, nPasso )
		nPasso ++
		If Empty(cDescricao)
			 Loop
		Endif
		nLinhas ++
		cChave := xFilial("SN2")+SN3->N3_CBASE+SN3->N3_ITEM+SN3->N3_TIPO+StrZero(nLinhas,TamSX3("N2_SEQUENC")[1])
		If !(dbSeek(cChave))
			lAppenda := .T.
		Else
			While !Eof() .And. cChave = xFilial("SN2")+SN3->N3_CBASE+SN3->N3_ITEM+SN3->N3_TIPO+StrZero(nLinhas,2)
				If SN2->N2_SEQ != SN3->N3_SEQ
					dbSkip()
					Loop
				EndIf
				dbSelectArea("SN2")
				dbSkip()
				Loop
			EndDo
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Na inclusao estara no fim de arquivo                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	 
		If SN2->(EOF())
		  lAppenda := .T.
		EndIf
		Reclock( "SN2", lAppenda)
		SN2->N2_FILIAL  := SN3->N3_FILIAL
		SN2->N2_CBASE   := SN3->N3_CBASE  
		SN2->N2_ITEM    := SN3->N3_ITEM
		SN2->N2_SEQUENC := StrZero( nLinhas, TamSX3("N2_SEQUENC")[1] )
		SN2->N2_TIPO    := SN3->N3_TIPO
		SN2->N2_HISTOR  := cDescricao
		SN2->N2_SEQ     := SN3->N3_SEQ
		MsUnlock()	 
		dbSkip()
	EndDo
Else
	lGrava := .T.
EndIf

// Atualza texto que veio por referencia.
cTxtCriAuto := cTexto
Return lGrava


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Af010Bar  ³ Autor ³ Alice                 ³ Data ³ 18.05.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ EnchoiceBar especifica do Atfa010                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oDlg: 	Objeto Dialog                                     ³±±
±±³          ³ bOk:  	Code Block para o Evento Ok                       ³±±
±±³          ³ bCancel: Code Block para o Evento Cancel                   ³±±
±±³          ³ nOpc:	nOpc transmitido pela mbrowse                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Af010Bar(oDlg,bOk,bCancel,bCria,nOpc,aRateio)

Local aButtons		:= {}
Local aUsButtons	:= {}
Local lCopia		:= IsIncallStack("AF010Copia")
Local lN1TPCTRAT	:= SN1->(FieldPos("N1_TPCTRAT")) > 0 .And. FindFunction("ATFA320") .And. AliasInDic("SNO")

//MRG
//Verifica implementacao da Margem Gerencial
Local lMargem := If(FindFunction("AFMrgAtf"),AFMrgAtf(),.F.)

If lN1TPCTRAT .AND. (nOpc == 2 .Or. nOpc == 3 .Or. nOpc == 4)
	Aadd(aButtons,{"CONTAINR",{||AF010CDTER(nOpc)},STR0075,STR0075})// "Contr. Terceiros"
EndIf

If lN1TPCTRAT .AND. (nOpc == 2 .Or. nOpc == 3 .Or. nOpc == 4)
	Aadd(aButtons,{"PMSCOLOR",{||AF010CETER(nOpc)},STR0113,STR0113})// "Cont. em Terceiros"
EndIf

//Exibe o botão de Multiplos somente na Inclusao/Copia.
If nOpc == 3 .And. FunName() # "ATFA240"
	Aadd(aButtons,{"SALARIOS",bCria,STR0018,STR0023})	// "Cria Automatico"#"Multiplos"
EndIf

If nOpc # 3 .And. Ascan(aHeader, {|x| Alltrim(x[2]) == "N3_TIPO"}) > 0
	If nOpc = 4                            
		Aadd(aButtons, {"NOTE", { ||	Af010Comp( 4, xFilial("SN3") + M->N1_CBASE + M->N1_ITEM + aCols[n][Ascan(aHeader, {|x| Alltrim(x[2]) == "N3_TIPO"})] ) }, ;
												STR0021 , STR0024 } )	//"Descricao Estendida"#"Extenso"
	Else
		Aadd(aButtons, {"NOTE", { ||	Afa160Vis( 2, xFilial("SN3") + M->N1_CBASE + M->N1_ITEM + aCols[n][Ascan(aHeader, {|x| Alltrim(x[2]) == "N3_TIPO"})] ) }, ;
												STR0021, STR0024 })	//"Descricao Estendida"#"Extenso"
	Endif
Endif
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Manutenção dos responsaveis pelo Bem		                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aButtons,{"BMPUSER",{|| Af190N1xR0(nOpc,M->N1_CBASE,M->N1_ITEM) }, STR0022+" - <F4>", STR0025 })	//"Responsaveis"#"Resp."

//AVP
//Botao para editar dados do AVP - Inclusao apenas
If lAvpAtf .and. nOpc == 3 .and. !lCopia
	Aadd(aButtons,{"FORM",{|| Af010Avp() }, STR0143, STR0144 }) //"AVP"###"Cálculo AVP"
Endif

//MRG
//Botao para editar dados do MRG
If lMargem .and. (nOpc == 3 .or. nOpc == 4)  .and. !lCopia
	Aadd(aButtons,{"TABPRICE",{|| Af010Margem(nOpc) }, STR0163, STR0164})		//"Margem"###"Margem Gerencial"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao para rateio dos itens da ficha de ativo                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FindFunction("AFXVerRat") .And. AFXVerRat()
	aAdd(aButtons,{"S4WB013N",{|| AF010RATEIO(aRateio,nOpc) },STR0131, STR0132}) //"Rateio Ficha de Ativo"###"Rateio"
EndIf
SetKey( VK_F4, {|| Af190N1xR0(nOpc,M->N1_CBASE,M->N1_ITEM)} )
             
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Avalia botoes do usuario                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "AF010BUT" ) 
	If ValType( aUsButtons := ExecBlock( "AF010BUT", .F., .F. ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf 	               
EndIf 	

Return (EnchoiceBar(oDlg,bOk,bCancel,,aButtons))

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºProgram   ³Atf010X3  ºAuthor ³Alexandre Silva     º Date ³  07-08-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta o a Header especifico para a rotina automatica.       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUse       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Atf010X3(cAlias,aHeader)

Local nPosItem := 0
Local nOrdSx3	:= SX3->(IndexOrd())

aHeader := {}
aCols	:= {}

//FillGetDados(nOpc,cAlias1,1,xFilial("SN3"),,,,,,,{||.T.})

dbSelectArea("SX3")
dbSetOrder(1)
SX3->(dbSeek(cAlias))              

While ! SX3->(Eof()) .And. (SX3->X3_arquivo == cAlias)
	nPosItem := Ascan(aAutoItens[1],{|aValorItem | Alltrim(aValorItem[1]) == AllTrim(SX3->X3_CAMPO)})
    If (nPosItem <> 0 .And. X3USO(SX3->X3_usado) .And. cNivel >= SX3->X3_NIVEL) .Or.;
	    Alltrim(SX3->X3_CAMPO) == "N3_SEQ" .Or. Rtrim(X3_CAMPO) == "N3_CBASE" .Or. Rtrim(X3_CAMPO) == "N3_ITEM"
        nUsado++
        AADD(aHeader,{ TRIM(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID ,SX3->X3_USADO ,SX3->X3_TIPO ,SX3->X3_ARQUIVO ,SX3->X3_CONTEXT})
    End
    Sx3->(dbSkip())
EndDo

SX3->(dbSetOrder(2))
SX3->(DbSeek("N3_FILIAL"))
AADD( aHeader, { "Alias WT","N3_ALI_WT", "", 09, 0,, SX3->X3_USADO, "C", "SN3", "V"} )
AADD( aHeader, { "Recno WT","N3_REC_WT", "", 09, 0,, SX3->X3_USADO, "N", "SN3", "V"} )
      
SX3->(dbSetOrder(nOrdSx3))

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A010MN2ARR³ Autor ³ARNALDO R. JUNIOR      ³ Data ³ 06.08.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ SALVA O ALIAS "M->" REFERENTE AOS CAMPOS DO SN1 EM ARRAY   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ATFA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION A010MN2ARR(aSaveaSN1)

Local aArea 	:= GetArea()
Local aAreaSX3 	:= SX3->(GetArea())

DbSelectArea("SX3")
DbSetOrder(1)
SX3->(dbSeek("SN1"))
While ! SX3->(Eof()) .And. (SX3->X3_arquivo == "SN1")
    IF X3USO(SX3->X3_usado) .and. cNivel >= SX3->X3_NIVEL
        AADD(aSaveaSN1,{AllTrim(SX3->X3_CAMPO), SX3->X3_TIPO , &("M->"+AllTrim(SX3->X3_CAMPO))})
    ENDIF
    Sx3->(dbSkip())
End

RestArea(aAreaSX3)
RestArea(aArea)
RETURN
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A010ARR2MN³ Autor ³ ARNALDO R. JUNIOR     ³ Data ³ 06.08.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ RESTAURA O CONTEUDO DO ALIAS "M->" PARA OS CAMPOS DO SN1   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ATFA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION A010ARR2MN(aSaveaSN1)
Local nX := 0

For nX := 1 TO Len(aSaveaSN1)
	&("M->"+aSaveaSN1[nX][1]):= aSaveaSN1[nX][3]
Next nX

RETURN
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AF010VLDIN³ Autor ³ ARNALDO R. JUNIOR     ³ Data ³ 06.08.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ VALIDA AS ALTERACOES DE CONTEUDO DOS CAMPOS DE CABECALHO   ³±±
±±³          ³ DA TELA DE CADASTRO - SN1 E DO ACOLS - SN3 CONFORME        ³±±
±±³          ³ PROCESSAMENTO DO PONTO DE ENTRADA AF010AIN()               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ATFA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION AF010VLDIN(aSaveaSN1)

LOCAL nX,nY := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VALIDACAO DOS CAMPOS DE CABEÇALHO - SN1                          ³
//³ 1. O ARRAY DE RETORNO DEVE TER MANTIDO AS POSICOES DOS CAMPOS    ³
//³ 2. O CONTEUDO DO ARRAY DE RETORNO DEVE TER O MESMO TIPO DO CAMPO ³
//³ 3. O CONTEUDO DO ARRAY DE RETORNO DEVE SER DIFERENTE DO INCIAL   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FOR nX := 1 TO LEN(_aCabSN1)
	IF 	_aCabSN1[nX][1] ==  aSaveaSN1[nX][1] .AND.;
		ValType(_aCabSN1[nX][3]) == aSaveaSN1[nX][2] .AND.;
		_aCabSN1[nX][3] !=  aSaveaSN1[nX][3] 

		&("M->"+_aCabSN1[nX][1]) := _aCabSN1[nX][3]

	ENDIF
NEXT nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VALIDACAO DOS CAMPOS DO ACOLS - SN3                              ³
//³ 1. O CONTEUDO DO ARRAY DE RETORNO DEVE TER O MESMO TIPO DO CAMPO ³
//³ 2. O CONTEUDO DO ARRAY DE RETORNO DEVE SER DIFERENTE DO INCIAL   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FOR nX := 1 TO LEN(aCols)
	FOR nY := 1 TO LEN(aCols[nX])
		IF 	ValType(_aColsAF010[nX][nY]) ==  ValType(aCols[nX][nY]) .AND.;
			_aColsAF010[nX][nY] !=  aCols[nX][nY] 
	
	   		aCols[nX][nY] := _aColsAF010[nX][nY]
	
		ENDIF
	NEXT ny
NEXT nX

RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A010TxRAltºAutor  ³ Marcelo Akama      º Data ³  21/07/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se pode alterar a taxa regulamentada              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±³Parametros³ExpC1 : Codigo do grupo                                     ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A010TxRAlt(cGrupo)

Local aArea		:= GetArea()
Local aAreaSNG	:= SNG->(GetArea())
Local lRet		:= INCLUI

If lRet .and. !empty(cGrupo) .And. SNG->(FieldPos("NG_TAXAPAD")) > 0 
	dbSelectArea("SNG")
	SNG->(dbSetOrder(1))
	If SNG->(dbSeek(xFilial("SNG")+cGrupo))
		lRet := Empty(SNG->NG_TAXAPAD)
	EndIf
EndIf

RestArea(aAreaSNG)
RestArea(aArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A010VLZERO Autor  ³ Adilson Soeiro     º Data ³  08/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Não permite alteração no campo apos a inclusão dif de vazioº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±³Parametros³ExpC1 : Nome do campo existindo no aHeader                  ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010VLZERO(cNomeField)
// Local aArea		:= GetArea()
Local lRet := .T.
Local nPos := 0
Default cNomeField := " "

if ALTERA .and. !Empty(cNomeField)
	nPos:=Ascan( aHeader, {|e| Trim(e[2]) == cNomeField } )
	if nPos > 0 
   		lRet := Empty(aCols[n,nPos] )
	Endif
Endif
// RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF010LAUDOºAutor  ³ Marcos Hirakawa    º Data ³  05/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Laudo / Conhecimento                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±³Parametros³ExpC1 : Codigo do grupo                                     ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010LAUDO(cAlias,nReg,nOpc)

Local nI := 1
Local cCaption  
Local oDlgC
Local aSN3:= {"N3_CBASE", "N3_ITEM", "N3_TIPO" , "N3_SEQ" , "N3_HISTOR"}
Local nSN3:= 0
Local aSize := MsAdvSize(,.F.,430) // MsAdvSize()
Local aObjects := {} 
Local aInfo := {} 
Local aPosObj := {} 
Local nSavRegSN3 := 0
Local nANT := 0
Local aSavSN3 := {}
          
Private nUsado:=0
Private cAlias1 := "SN3"
Private aCOLS := {}
Private aHeader[0]
Private xSN1
Private xSN3

Aadd( aObjects, { 100, 100, .T., .T. } )
Aadd( aObjects, { 315,  70, .T., .T. } )
aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
aPosObj := MsObjSize( aInfo, aObjects, .F. ) 
nSN3    := LEN(aSN3)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos campos de Bancos de Dados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
xSN1 := cFilial
IF Reccount() == 0
	Return (.T.)
End  

If SN1->N1_FILIAL != cFilial
	HELP(" ",1,"A000FI")
	Return (.T.)
End  

RegToMemory("SN1", .F.)

cAlias1 := "SN3"

dbSelectArea(cAlias1)
dbSetOrder( 1 )
xSN3 := cFilial
dbSeek( cFilial + SN1->N1_CBASE + SN1->N1_ITEM )

cCaption := "[ "+ SN1->N1_DESCRIC + " ]" 

DbSelectArea("SX3")
DbSetOrder(2)
FOR nI := 1 TO nSN3
	IF DbSeek( aSN3[nI] )
      nUsado++
      AADD(aHeader,{Trim(X3Titulo()),;
                    SX3->X3_CAMPO,;
                    SX3->X3_PICTURE,;
                    SX3->X3_TAMANHO,;
                    SX3->X3_DECIMAL,;
                    SX3->X3_VALID,;
                    "",;
                    SX3->X3_TIPO,;
                    "",;
                    "";
                   };
      )
	EndIf
NEXT

dbSelectArea(cAlias1)
dbSetOrder( 1 )
nI := 1
DO WHILE (xSN1 + SN1->(N1_CBASE + N1_ITEM )) == (xSN3 + SN3->(N3_CBASE + N3_ITEM )) .AND. (! SN3->(EOF()))
       // aCols=>{ 1-> N3_CBASE,  2-> N3_ITEM,    3-> N3_TIPO,  4-> N3_SEQ,  5-> N3_HISTOR, [nUsado+1]= .F.
   aadd( aCols , {SN3->N3_CBASE, SN3->N3_ITEM , SN3->N3_TIPO , SN3->N3_SEQ, SN3->N3_HISTOR, .F. })
   aadd( aSavSN3 ,SN3->(Recno()) )
   nI++
	dbSelectArea(cAlias1)
	DBSKIP()
Enddo
DEFINE MSDIALOG oDlgC TITLE cCaption FROM aSize[7]/2,aSize[1]/2 TO aSize[6]/2, (aSize[5]/2+30) OF oMainWnd PIXEL
oGetDB := MsGetDados():New( 5,;                    // 01 nTop
     	                     aPosObj[2,2]/2,;	      // 02 nLeft
        	                  aPosObj[2,3]/2 - 20 ,;	// 03 nBottom, 
           	               aPosObj[2,4]/2 + 10 ,;	// 04 nRight
            	            2,;				         // 05 nOpc 4
               	         ".T.",;                 // 06 cLinhaOk
                  	      ".T.",;	               // 07 cTudoOk
                     	   "+ITEM", ;	         	// 08 cIniCpos
                        	 .F.;                   // 09 lDelete , .T.
                           ) 
                          
@ (aPosObj[2,3]/2 - 10), (aPosObj[2,2]/2) BUTTON STR0035 PIXEL OF oDlgC ACTION (nANT := n,  MsDocument("SN3", aSavSN3[nANT], 4 ) , n := nANT , oGetDB:oBROWSE:SETFOCUS())
ACTIVATE MSDIALOG oDlgC CENTER
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Af010BlqDesbºAutor  ³ Marcos Hirakawa    º Data ³  30/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Bloqueia/Desbloqueia bens, atualizando campo N1_STATUS       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Atfa010                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Af010BlqDesb
Local cAliasTrb := GetNextAlias()
Local aParam	 := {}
Local cBemDe	 := Space(Len(SN1->N1_CBASE))
Local cBemAte   := cBemDe
Local cItemDe	 := Space(Len(SN1->N1_ITEM))
Local cItemAte	 := cItemDe
Local cGrupoDe	 := Space(Len(SN1->N1_GRUPO))
Local cGrupoAte := cGrupoDe
Local dAquisDe	 := Ctod("")
Local dAquisAte := Ctod("")
Local aTipos 	 := {"1-" + STR0148 , "2-" +STR0149 } //"Desbloqueia"##"Bloqueia"
Local cWhere	 := ""
Local cMsg		 := ""
Local lRet		 := .T.

//AVP2
//Verifica implementacao do AVP e AVP parcela
If lAvpAtf2 == NIL
	lAvpAtf2 := If(FindFunction("AFAvpAtf2"),AFAvpAtf2(),.F.)
Endif

//AVP2 
//Verifica se o bem foi gerado por AVP Parcela
If lAvpAtf2 .AND. SN1->N1_PATRIM = 'V' .and. Alltrim(SN1->N1_ORIGEM) == 'ATFA460'
	Help(" ",1,"AF010460BQ",,STR0145 ,1,0)  //'Este ativo foi gerado a partir do processo de constituição de provisão. Este tipo de ativo não poderá ser alterado'
	lRet  := .F.
Endif		

If lRet	

	SaveInter()
	cCadastro := STR0150 //"Parâmetros"
	
	
	
	If ParamBox( {		{ 1, STR0080, 		cBemDe  	,"@!",".T." ,"SN1",".T.",55,.F.	},; //"Do Código do Bem"
					 	{ 1, STR0081, 	cBemAte		,"@!",".T.","SN1",".T.",55,.T.	},; //"Até o Código do Bem"
					 	{ 1, STR0082, 				cItemDe		,"",".T.","",".T.",20,.F.		},; //"Do Item"
					 	{ 1, STR0083, 				cItemAte	,"",".T.","",".T.",20,.T.		},; //"Até o Item"
					 	{ 1, STR0084,				cGrupoDe	,"@!",".T.","SNG",".T.",25,.F.	},; //"Do Grupo"
					 	{ 1, STR0085,				cGrupoAte	,"@!",".T.","SNG",".T.",25,.T.	},; //"Até o Grupo"
					 	{ 1, STR0086,	dAquisDe	,"",".T.","",".T.",55,.F.		},; //"Da Data de Aquisição"
					 	{ 1, STR0087,	dAquisAte	,"",".T.","",".T.",55,.T.		},; //"Até a Data de Aquisição"
					 	{ 2, STR0088,		1			,aTipos,60,,.T.					}},STR0089,aParam,,,,,,,,.F.,.T.) //"Bloqueia/Desbloq"###"Bloqueio/Desbloqueio"
		
		// Ajusta parametro 09 (Bloqueia/Desbloq), pois a ParamBox hora retorna Caracter, hora retorna numerico, 
		// por ser um parametro tipo Combo
		mv_par09:= If(Type("mv_par09")=="N", mv_par09,Val(Left(mv_par09,1)))
		
		If mv_par09 == 1
			cWhere := "%N1_STATUS = '2'%"
			cMsg := STR0090 //"Desbloqueando"
		Else			
			cWhere := "%(N1_STATUS = '1' OR N1_STATUS = ' ')%"
			cMsg := STR0091 //"Bloqueando"
		Endif
		
		BeginSql Alias cAliasTrb
			SELECT R_E_C_N_O_ RECNOSN1
			  FROM %table:SN1%
		    WHERE N1_FILIAL = %xFilial:SN1%
		    		 AND N1_CBASE >= %exp:mv_par01%
		    		 AND N1_CBASE <= %exp:mv_par02%
		    		 AND N1_ITEM  >= %exp:mv_par03%
		    		 AND N1_ITEM  <= %exp:mv_par04%
		    		 AND N1_GRUPO >= %exp:mv_par05%
		     		 AND N1_GRUPO <= %exp:mv_par06%
		     		 AND N1_AQUISIC >= %exp:mv_par07%
		     		 AND N1_AQUISIC <= %exp:mv_par08%
		     		 AND %exp:cWhere%
		     		 AND %notDel%
		EndSql
	
		MsgRun( STR0092 + cMsg + STR0109 ,, { || ProcBlqDesb(cAliasTrb) } ) //"Aguarde " ## " ativos"
		
		(cAliasTrb)->(DbCloseArea())
	Endif
	
	RestInter()
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ProcBlqDesb ºAutor  ³ Claudio Donizete   º Data ³  02/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Bloqueia/Desbloqueia bens, atualizando campo N1_STATUS       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Atfa010                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ProcBlqDesb(cAliasTrb)

Local aArea     := GetArea()
Local nTam := Len(SN1->N1_STATUS)
Local cAtivo	:= ""
Local cBloq     := ""
Local cCabec	:= ""
Local cTexto	:= ""                   
Local lExitSNL  := AliasInDic("SNL")
Local cStatusLoc:= ""
Local cLocBloq  := ""
	
While (cAliasTrb)->(!Eof())
	SN1->(MsGoto((cAliasTrb)->RECNOSN1))
	
	If lExitSNL
    	cStatusLoc := GetAdvFval("SNL","NL_BLOQ",xFilial("SNL") + SN1->N1_LOCAL ,1,"")
    	If Alltrim(cStatusLoc) == '1'
    		cLocBloq += SN1->N1_FILIAL + " / " + SN1->N1_CBASE + " / " + SN1->N1_ITEM + " / " + SN1->N1_DESCRIC + " / " + STR0110 + SN1->N1_LOCAL + CRLF
    		(cAliasTrb)->(DbSkip())
    		Loop
    	EndIf
	EndIf
	
	RecLock("SN1",.F.)
	SN1->N1_STATUS := Str(If(mv_par09==1,1,2),nTam)
	SN1->N1_DTBLOQ := If(mv_par09==1,CTOD(""),dDataBase)
	cAtivo += SN1->N1_FILIAL + " / " + SN1->N1_CBASE + " / " + SN1->N1_ITEM + " / " + SN1->N1_DESCRIC + CRLF
	MsUnlock()
	(cAliasTrb)->(DbSkip())
End

//Monta o cabeçalho com os nomes dos campos chave da tabela SN1
dbSelectArea("SX3")
SX3->(dbSetOrder(2))		//X3_CAMPO
SX3->(dbSeek("N1_FILIAL"))
cCabec += AllTrim(X3Titulo())
SX3->(dbSeek("N1_CBASE"))
cCabec += " / " + AllTrim(X3Titulo())
SX3->(dbSeek("N1_ITEM"))
cCabec += " / " + AllTrim(X3Titulo())
SX3->(dbSeek("N1_DESCRIC"))
cCabec += " / " + AllTrim(X3Titulo())

//Resumo do bloqueio/desbloqueio de bens
DEFINE FONT oFont NAME "Mono AS" SIZE 005,012
DEFINE MSDIALOG oDlg TITLE STR0067 From 003,000 TO 340,417 PIXEL		//"Bloqueio / desbloqueio de bens"

If Empty(cAtivo)
	cAtivo += STR0066 + " " + IIF(MV_PAR09 == 1, STR0073, STR0072) + CRLF		//"Não foram encontrados bens de acordo com os parâmetros informados"##"ou os bens já encontram-se bloqueados/desbloqueados."
	cAtivo += CRLF + IIF(MV_PAR09 == 1, STR0069, STR0068)		//"Nenhum bem foi bloqueado/desbloqueado."
Else
	cTexto += IIF(MV_PAR09 == 1, STR0071, STR0070) + CRLF		//"Os seguintes bens foram bloqueados/desbloqueados:"
	cTexto += CRLF
	cTexto += cCabec + CRLF
EndIf 

cTexto += cAtivo + CRLF

If !Empty(cLocBloq)
	cTexto += STR0111 + CRLF //" Os seguintes ativos não foram efetivados porque os locais cadastrados estão bloqueados "
	cTexto += cLocBloq + CRLF   		
EndIf

@ 005,005 GET oMemo VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL
oMemo:bRClicked := {||AllwaysTrue()}
oMemo:oFont := oFont
DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
ACTIVATE MSDIALOG oDlg CENTER
	
RestArea(aArea)
	
Return Nil	


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF010RATEIOºAutor  ³Jair Ribeiro		   º Data ³  04/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Prepara array para chamada da tela de rateio via getdados   	º±±
±±º          ³                                                            	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAATF                                                    	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010RATEIO(aRateio,nOpc)	
Local bFuncPanel	:= {|oWnd| FA010GetPn(oWnd)}
Local aArea			:= GetArea() 
Local aAxRat		:= {}

Local cCodRat		:= ""
Local cRev			:= ""
Local cStatus		:= ""

Local nLin	   		:= __oGet:obrowse:nAt
Local lCont			:= .F.

If FindFunction("AFXVerRat") .And. AFXVerRat() .AND. FindFunction("AF011FRAT")

	If nOpc == 3
		AF011FRAT(aRateio,nLin,nOpc,bFuncPanel)
	ElseIf (GdFieldGet("N3_RATEIO",nLin) == "1")
		cCodRat := GdFieldGet("N3_CODRAT",nLin)
		
		If AsCan(aRateio,{|aX| aX[1] == cCodRat}) == 0
			lCont:= .T.
		EndIf 				
		If lCont
			AF010LoadR(aRateio,cCodRat,nLin)
			AF011FRAT(aRateio,nLin,nOpc,bFuncPanel)
		Else
			AF011FRAT(aRateio,nLin,nOpc,bFuncPanel)	
		EndIf
	Else
		AF011FRAT(aRateio,nLin,nOpc,bFuncPanel)		
	EndIf
Endif

Return   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF010CDTERº Autor ³ Arnaldo Raymundo Jrº Data ³  05/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tratamento da chamada do cadastro de bens de terceiros     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF010CDTER(nOpc)

Local aAutoCab		:= {}
Local nOpcx			:= IIF(nOpc == 2, 2, 3)
Local nOpcA			:= 0
Local aArea			:= GetArea()   
Local lContinua		:= .T.
Local lFound		:= .F.

// Valida a utilizacao do controle de terceiros para o bem
IF M->N1_TPCTRAT != "2"
	lContinua := .F.
	Help(" ",1,"AF010CDTER",,STR0093+CRLF+STR0094,1,0)	 //"Controle de terceiros nao disponivel para este bem."###"Avaliar as configuracao do campo Tipo de Controle."
ENDIF

IF Empty(M->N1_CBASE) .OR. Empty(M->N1_ITEM)
	lContinua := .F.
	Help(" ",1,"AF010CDBAS",,STR0105,1,0) //"Campo de código base ou Item não preenchido, por favor verifique."
ENDIF

IF lContinua 
	// Valida a existencia do controle de terceiros
	DbSelectArea("SNO")
	DbSetOrder(2)
	IF DbSeek(M->N1_FILIAL+M->N1_CBASE+M->N1_ITEM)
		While SNO->(!EOF()) .AND. 	SNO->NO_FILIAL 	== SN1->N1_FILIAL .AND.;
									SNO->NO_CBASE 	== SN1->N1_CBASE .AND.;
									SNO->NO_ITEM	== SN1->N1_ITEM
									
			IF SNO->NO_STATUS == "1" // Controle Ativo
				lFound := .T.
				Exit
			ENDIF	
			SNO->(DbSkip())	
		End
	ENDIF
	
	IF lFound .AND. nOpcx == 3
		
		nOpcA := Aviso(STR0095,	STR0096+CRLF+; //"Controle de bens de terceiros"###"Ja existe um controle de terceiros ativo para este bem."
												STR0097+CRLF+; //"Manutencoes devem ser realizadas pelo cadastro de controle de terceiros."
												STR0098,{STR0002,STR0099}) //"Opcoes disponiveis pelo cadastro do bem: Visualizar."###"Visualizar"###"Sair"

		IF nOpcA == 1
			nOpcx := 2 // Visualizar
		ELSE
			lContinua := .F.
		ENDIF
		
	ELSEIF !lFound .AND. nOpcx == 2
		Help(" ",1,"AF010NOTER",,STR0100+CRLF+STR0101,1,0) //"Nao existe controle de terceiros para este bem."###"Efetuar manutencao pelo cadastro de controle de terceiros."
		lContinua := .F.
	ENDIF
	
	IF lContinua
		
		IF nOpcx == 3
			AADD(aAutoCab,{"NO_CBASE"	,M->N1_CBASE	,NIL})
			AADD(aAutoCab,{"NO_ITEM"	,M->N1_ITEM		,NIL})
			AADD(aAutoCab,{"NO_FORNEC"	,M->N1_FORNEC	,NIL})
			AADD(aAutoCab,{"NO_LOJA"	,M->N1_LOJA		,NIL})
		ENDIF
	
		SaveInter()
		ATF320Cad("SNO",IIF(nOpcx==2,SNO->(RECNO()),0),nOpcx,aAutoCab,,.T.)
		RestInter()
	ENDIF
ENDIF

RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF010CETERº Autor ³ Microsiga  º Data ³  05/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tratamento da chamada do cadastro de bens em terceiros     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF010CETER(nOpc)

Local aAutoCab		:= {}
Local nOpcx			:= IIF(nOpc == 2, 2, 3)
Local nOpcA			:= 0
Local aArea			:= GetArea()   
Local lContinua		:= .T.
Local lFound		:= .F.

// Valida a utilizacao do controle de terceiros para o bem
IF M->N1_TPCTRAT != "3"
	lContinua := .F.
	Help(" ",1,"AF010CETER",,STR0114+CRLF+STR0115,1,0)	 
ENDIF

IF Empty(M->N1_CBASE) .OR. Empty(M->N1_ITEM)
	lContinua := .F.
	Help(" ",1,"AF010CEBAS",,STR0116,1,0) 
ENDIF

IF lContinua 
	// Valida a existencia do controle em terceiros
	DbSelectArea("SNP")
	DbSetOrder(2)
	IF DbSeek(xFilial("SN1")+M->N1_CBASE+M->N1_ITEM)
		While SNP->(!EOF()) .AND. 	SNP->NP_FILIAL 	== xFilial("SN1") .AND.;
									SNP->NP_CBASE 	== M->N1_CBASE .AND.;
									SNP->NP_ITEM	== M->N1_ITEM
									
			IF SNP->NP_STATUS == "1" // Controle Ativo
				lFound := .T.
				Exit
			ENDIF	
			SNP->(DbSkip())	
		End
	ENDIF
	
	IF lFound .AND. nOpcx == 3
		
		nOpcA := Aviso(STR0117,	STR0118+CRLF+; 
		               STR0119+CRLF+; 
		               STR0120,{STR0002,STR0099}) 

		IF nOpcA == 1
			nOpcx := 2 // Visualizar
		ELSE
			lContinua := .F.
		ENDIF
		
	ELSEIF !lFound .AND. nOpcx == 2
		Help(" ",1,"AF010NOTER",,STR0121+CRLF+STR0122,1,0) 
		lContinua := .F.
	ENDIF
	
	IF lContinua
		
		IF nOpcx == 3
			AADD(aAutoCab,{"NP_CBASE"	,M->N1_CBASE	,NIL})
			AADD(aAutoCab,{"NP_ITEM"	,M->N1_ITEM		,NIL})
			AADD(aAutoCab,{"NP_FORNEC"	,M->N1_FORNEC	,NIL})
			AADD(aAutoCab,{"NP_LOJA"	,M->N1_LOJA		,NIL})
		ENDIF
	
		SaveInter()
		ATF321Cad("SNP",IIF(nOpcx==2,SNP->(RECNO()),0),nOpcx,aAutoCab,,.T.)
		RestInter()
	ENDIF
ENDIF

RestArea(aArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA010GetPnºAutor  ³Jair Ribeiro        º Data ³  04/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria objeto panel com say para tela de rateio              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAATF                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA010GetPn(oWnd) 
Local oTPanel	:= Nil
Local oSay1		:= Nil
Local oSay2		:= Nil
Local oSay3		:= Nil
Local oSay4		:= Nil
Local oSay5		:= Nil
Local oSay6		:= Nil
Local oSay7		:= Nil
Local oSay8		:= Nil
Local oAriaN	:= tFont():New("Arial",,-12,,.T.)
Local oAriaI	:= tFont():New("Arial",,-12,,.F.,,,,.T.)
Local nLin		:= __oGet:obrowse:nAt
Local cTpS		:= ""


If (FwRetIdiom() == "es")
	cTpS:= GetAdvFVal("SX5","X5_DESCSPA",xFilial("SX5")+"SL"+GdFieldGet('N3_TPSALDO',nLin)) 
Else
	If (FwRetIdiom()=="en")
	   cTpS:= GetAdvFVal("SX5","X5_DESCENG",xFilial("SX5")+"SL"+GdFieldGet('N3_TPSALDO',nLin)) 
	Else
		cTpS:= GetAdvFVal("SX5","X5_DESCRI",xFilial("SX5")+"SL"+GdFieldGet('N3_TPSALDO',nLin)) 
	Endif
Endif  

oTPanel:= TPanel():New(10,10,"",oWnd,,,,,,20,20)
oTPanel:Align := CONTROL_ALIGN_TOP	       

oSay1 := TSay():New(05,005,{|| Iif(FindFunction("ATF010X3TITULO"),Atf010x3titulo("N1_CBASE"),"") + ": "},oTPanel,,oAriaN,,,,.T.) 
oSay2 := TSay():New(05,050,{|| M->N1_CBASE}  	  		,oTPanel,,oAriaI,,,,.T.)

oSay3 := TSay():New(05,105,{|| Iif(FindFunction("ATF010X3TITULO"),Atf010x3titulo("N1_ITEM"),"") + ": "},oTPanel,,oAriaN,,,,.T.)
oSay4 := TSay():New(05,135,{|| M->N1_ITEM}	 			,oTPanel,,oAriaI,,,,.T.)

oSay5 := TSay():New(05,160,{|| Iif(FindFunction("ATF010X3TITULO"),Atf010x3titulo("N3_TIPO"),"") + ": "},oTPanel,,oAriaN,,,,.T.)
oSay6 := TSay():New(05,195,{|| GdFieldGet('N3_TIPO',nLin)}	,oTPanel,,oAriaI,,,,.T.)

oSay7 := TSay():New(05,215,{|| Iif(FindFunction("ATF010X3TITULO"),Atf010x3titulo("N3_TPSALDO"),"") + ": "},oTPanel,,oAriaN,,,,.T.) 
oSay8 := TSay():New(05,260,{|| cTpS},oTPanel,,oAriaI,,,,.T.)

Return oTPanel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF010PerAutºAutor  ³Alvaro Camillo Neto º Data ³  07/22/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega as variaveis com os parametros da execauto          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010PerAut()
Local nX 		:= 0
Local cVarParam := ""

If ValType(aParamAuto) != "U"
	For nX := 1 to Len(aParamAuto)
		cVarParam := Alltrim(Upper(aParamAuto[nX][1]))
		If "MV_PAR" $ cVarParam
			&(cVarParam) := aParamAuto[nX][2]
		EndIf
	Next nX
EndIf

Return

/*

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF10CanTerºAutor  ³Microsiga           º Data ³  07/18/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exclui o Bem de terceiro caso o usuário cancele a operação º±±
±±º          ³ ou altere o controle de terceiros antes de confirmar       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF10CanTer(nOpc,lCancela)
Local aArea := GetArea()
Local lN1TPCTRAT	:= SN1->(FieldPos("N1_TPCTRAT")) > 0

Default nOpc 		:= 3
Default lCancela 	:= .F.

If lN1TPCTRAT
	
	// Inserido por Carlos Queiroz em 04/08/11
	If M->N1_TPCTRAT $ "2"
		
		SNO->(dbSetOrder(2))//NO_FILIAL+NO_CBASE+NO_ITEM+NO_CODIGO+NO_SEQ
		If SNO->(dbSeek(xFilial("SNO") + M->(N1_CBASE + N1_ITEM ) ) )
			While SNO->(!Eof()) .And. Alltrim(SNO->(NO_FILIAL+NO_CBASE+NO_ITEM)) == Alltrim(xFilial("SNO") + M->(N1_CBASE + N1_ITEM ))
				RecLock("SNO",.F.)
				If ((nOpc == 3 .AND. lCancela) .Or. nOpc == 5) .Or. (nOpc == 4 .And. lCancela)
					SNO->(DbDelete())
				EndIf
				MsUnLock()
				SNO->(dbSkip())
			EndDo
		EndIf
		
		// Inserido por Carlos Queiroz em 04/08/11
	ElseIf M->N1_TPCTRAT $ "3"
		
		SNP->(dbSetOrder(2))//NP_FILIAL+NP_CBASE+NP_ITEM+NP_CODIGO+NP_SEQ
		If SNP->(dbSeek(xFilial("SNP") + M->(N1_CBASE + N1_ITEM ) ) )
			While SNP->(!Eof()) .And. Alltrim(SNP->(NP_FILIAL+NP_CBASE+NP_ITEM)) == Alltrim(xFilial("SNP") + M->(N1_CBASE + N1_ITEM ))
				RecLock("SNP",.F.)
				If ((nOpc == 3 .AND. lCancela) .Or. nOpc == 5) .Or. (nOpc == 4 .And. lCancela /*.And. SN1->N1_TPCTRAT != '3'*/)
					SNP->(DbDelete())
//				ElseIF SN1->N1_TPCTRAT != '3'
//					SNP->NP_STATUS := '2'
				EndIf
				MsUnLock()
				SNP->(dbSkip())
			EndDo
		EndIf
		
	EndIf
	
EndIf

RestArea(aArea)
Return .T.



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFA010   ºAutor  ³Microsiga           º Data ³  08/28/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATF010WHEN()
Local lRet := .T.

If SN1->(FieldPos("N1_TPCTRAT")) > 0
	If !Inclui
		If !empty(SN1->N1_TPCTRAT) .and. SN1->N1_TPCTRAT <> "1"
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³AF010CV14	 ³ Autor ³ Mauricio Pequim Jr      ³ Data ³01/12/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Inclui o Tipo 14 referente ao Tipo 10 para a conversao         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF010CV14()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array dos bens a sofrerem conversao                   ³±±
±±³          ³ ExpA2 - Array dos recnos bens a sofrerem conversao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFIN                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010CV14(aCols,aHeader,aRecNo)

Local nX 		:= 0
Local nY 		:= 0
Local aCols14	:= {}		//Acols dos Tipos 14
Local aTip14	:= {}		//Auxiliar do Acols
Local aRecno14	:= {}		//ARecno dos Tipos 14
Local aArea		:= GetArea()
Local cCampos	:= "N3_TIPO/N3_HISTOR/N3_ITEM/N3_SEQ/N3_CCONTAB/N3_CUSTBEM/N3_SUBCCON/N3_CLVLCON/N3_VMXDEPR/N3_VLSALV1"
local aCampos	:= STRTOKARR(cCampos,"/")
Local aPosCpos	:= {}
Local nPosVlr01:= aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_VORIG1" } )
Local nPosVMax := aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_VMXDEPR" } )
Local nPosVSav := aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_VLSALV1" } )
Local nPosTipo := aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_TIPO" } )
Local nPosTpDp := aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_TPDEPR" } )
Local nPropM 	:= 0
Local nPropS 	:= 0


// *******************************
// Controle de multiplas moedas  *
// *******************************
Local __nQuantas := If(lMultMoed,AtfMoedas(),5)
Local aPosVOrigX:= If(lMultMoed,AtfMultPos(aHeader,"N3_VORIG"),;
{ 	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG1" } ),;
Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG2" } ),;
Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG3" } ),;
Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG4" } ),;
Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG5" } ) })

Local cTypes10		:= "" // CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models

If lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cTypes10 := "|" + AtfNValMod({1}, "|")
Endif

//Monto array com posicao dos campos a serem atualizados no Tipo14
For nX := 1 to Len(aCampos)
	aadd(aPosCpos,Ascan(aHeader	, {|e| Alltrim(e[2]) == Alltrim(aCampos[nX]) } ))
Next

//Gero a linha de Tipo 14
For nY := 1 to Len(aCols)
	
	//Caso seja um bem do tipo 10 esteja selecionado para conversao
	If aCols[nY][nPosTipo] $ ('10' + cTypes10)
		
		//Posiciono no SN3 - Tipo 10
		SN3->(dbGoto(aRecno[nY]))
		
		//Esse proporcao sera aplicada ao valor maximo de depreciacao e de salvamento
		nPropM 	:= aCols[nY][nPosVMax] / aCols[nY][nPosVlr01]
		nPropS 	:= aCols[nY][nPosVSav] / aCols[nY][nPosVlr01]
		
		SN3->(dbSetOrder(11)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO+N3_SEQ+N3_SEQREAV
		//Acho o TIPO 14 referente ao tipo 10
		If SN3->(MsSeek( xFilial("SN3")+SN3->(N3_CBASE+N3_ITEM)+'14'+"0"+SN3->N3_TPSALDO))
			
			//Copio os dados do Tipo 10
			aTip14 := aClone(aCols[nY])
			
			//Atualizo os dados do tipo 14
			For nX := 1 to Len(aCampos)
				If aPosCpos[nX] > 0
					aTip14[aPosCpos[nX]] := &(allTrim(aCampos[nX]))
				Endif
			Next
			
			//Atualizo os dados de valores do tipo 14
			For nX := 1 to __nQuantas
				If aPosVOrigX[nX] > 0
					aTip14[aPosVOrigX[nX]] := &("N3_VORIG"+AllTrim(Str(nX)))
				Endif
			Next
			
			//Atualizo os valores de valor maximo de depreciacao e valor de salvamento
			//Mas apenas se os mesmos foram alterados
			If aTip14[nPosVMax] > 0
				aTip14[nPosVMax] := aTip14[nPosVlr01] * If(nPropM > 0, nPropM, 1)
			Endif
			If aTip14[nPosVSav] > 0
				aTip14[nPosVSav] := aTip14[nPosVlr01] * If(nPropS > 0, nPropS, 1)
			Endif
			
			//Guardo os dados para repassar ao array de bens
			aadd(aCols14, aTip14)
			aadd(aRecno14, SN3->(RECNO()))
			
		Endif
	Endif
	
Next

//Adiciono os Bens do tipo 14 no aCols
If Len(aCols14) > 0
	For nY := 1 to Len(aCols14)
		aadd(aCols , aCols14[nY])
		aadd(aRecno, aRecno14[nY])
	Next
Endif

RestArea(aArea)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ AF010AVPCV³ Autor ³ Mauricio Pequim Jr	  ³ Data ³ 05.12.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera a constituicao de AVP para conversao de metodo de 	  ³±±
±±³          ³ depreciacao					                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aRec14Bxd = Array contendo recno dos bens baixados         ³±±
±±³          ³ aRec14Bxd = Array contendo recno dos bens gerados          ³±±
±±³          ³ cIdMov = Id do movimento do bem (SN4->N4_IDMOV)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ ATFA010																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF010AVPCV(aRec14Bxd,aRec14New,cIdMov)

Local nX			:= 0
Local nValAvp		:= 0
Local nValVp		:= 0
Local aRecFNF		:= {}
Local aRecCtb		:= {}
Local aArea			:= GetArea()
Local cIdProcAVP	:= GetSxeNum('FNF','FNF_IDPROC','FNF_IDPROC'+cEmpAnt,3)

//AVP
//Gero baixas de AVP - Conversao de metodo de depreciacao
For nX := 1 to Len(aRec14Bxd)
	
	SN3->(dbGoto(aRec14Bxd[nX]))
	
	//Posiciono no SN1
	If SN1->(MsSeek( xFilial("SN1") + SN3->( N3_CBASE + N3_ITEM ) ))
		
		//Posiciono tabela FNF no registro de constituicao ativo
		dbSelectArea("FNF")
		FNF->(dbSetOrder(4)) //FNF_FILIAL+FNF_CBASE+FNF_ITEM+FNF_TPMOV+FNF_STATUS
		If MsSeek(xFilial("FNF")+SN3->(N3_CBASE+N3_ITEM)+"1"+"1")
			
			//Obtenho os valores
			nValAvp	:= FNF->(FNF_VALOR - FNF_ACMAVP)
			nValVP	:= FNF->FNF_AVPVLP
			aadd(aRecFNF,{FNF->FNF_TPSALD,FNF->(RECNO()),nValVP})
			
			//Gravo a realizacao por transferencia
			AfGrvAvp(cFilAnt,"9",dDataBase,FNF->FNF_CBASE,FNF->FNF_ITEM,FNF->FNF_TIPO,FNF->FNF_TPSALD,SN3->N3_BAIXA,FNF->FNF_SEQ,,nValAvp,.F.,,,,SN3->(RECNO()),cIdProcAVP,aRecCTB,,cIdMov,nValVP)
			
		Endif
	Endif
Next


//AVP
//Gero constituicao de AVP
//Novos registros gerados pela Conversao de metodo de depreciacao
For nX := 1 to Len(aRec14New)
	
	//Posiciono no novo SN3 Tipo 14
	SN3->(dbGoto(aRec14New[nX]))
	
	//Posiciono no SN1
	If SN1->(MsSeek( xFilial("SN1") + SN3->( N3_CBASE + N3_ITEM ) ))
		
		nPos := Ascan(aRecFNF	, {|e| Alltrim(e[1]) == SN3->N3_TPSALDO } )
		
		If nPos > 0
			//Gravo o movimento de constituicao do AVP pela inclusao do bem na filial destino
			AfGrvAvp(cFilAnt,"1",dDatabase,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_TPSALDO,;
			SN3->N3_BAIXA,SN3->N3_SEQ,SN3->N3_SEQREAV,SN3->N3_VORIG1,.F.,,,,SN3->(RECNO()),;
			cIdProcAVP,aRecCtb,/*lBxTotal*/,@cIdMov,aRecFNF[nX,3],/*cRotina*/,/*cArquivo*/,;
			aRecFNF[nX,2],.T.)
		Endif
		
	Endif
	
Next

//Confirmo o ID do processo nas tabelas de controle
ConfirmSX8()

RestArea(aArea)

Return aRecCtb


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Af010AVPMul³ Autor ³ Mauricio Pequim Jr	  ³ Data ³ 05.12.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera a constituicao de AVP para inclusão de multiplos bens ³±±
±±³          ³ (botao multiplos da inclusao)		                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ ATFA010																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Af010AVPMul()

Local nInc		:= 0
Local aCols14	:= {}
Local nPosTipo := aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_TIPO" } )

//AVP
//Gera as linhas do tipo 14 a partir do tipo 10 na Inclusao
If lAvpAtf
	
	//Verifico se o tipo 14 ja esta presente na aCols (multiplos na copia de bens)
	nPos := aScan( aCols, { |x| AllTrim( x[nPosTipo] ) == "14" } )
	
	//Caso nao exista nenhum Tipo 14 (multiplos na inclusao manual)
	//Gero o Tipo 14 de acordo com os dados da pasta AVP
	If nPos == 0
		AF010Grv14(aCols14)
		
		//Incluir os registros tipo 14 + tipo saldo no aCols (SN3)
		//APENAS NA INCLUSAO
		For nInc := 1 to Len(aCols14)
			aadd(aCols, aCols14[nInc])
		Next
	Endif
Endif

Return

// ----------
// Importação da classificação do ativo
//-----------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF010ImpClºAutor  ³Ramon Prado         º Data ³  19/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Importa um arquivo para classificação gerencial do ativo   º±±
±±º          ³ fixo                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAATF                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010ImpCl(cAlias,nReg,nOpc)
Local aArea		:= GetArea()
Local aRet		:= {}			//Conteudo de retorno da ParamBox
Local aPerg		:= {}			//Array de parametros a serem passados para a ParamBox
Local nX		:= 0
Local nY		:= 0
Local aLogAux	:= {}
Local lRet		:= .T.
Local cIdCV8	:= ""

If lRet
	lRet := CtbInTran( 1, .F. )
EndIf

If lRet

	__aEtapa := {}

	ProcLogIni( {},__cProcPrinc+"Imp",,@cIdCV8)
	ProcLogAtu( "INICIO", STR0125,,,.T.) //"Log de processamento de Imp. CSV"

	aCfgImp  := {	{"SN3", , {||MSExecAuto({|x| AF010IClas(x)},xAutoCab )}} }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Array a ser passado para ParamBox³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aPerg,{6,STR0123,PadR("",150),"","","",90,.T.,STR0146,"",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}) //"Nome do arquivo para importação"###"Arquivos .CSV |*.CSV"
	aAdd(aPerg,{2,STR0135,STR0136,{STR0137, STR0136 },60,"",.T.})//"Exclui classificação anterior"##"Não"##"Sim"##"Não"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso confirme a tela de parametros processa a rotina de exportacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ParamBox(aPerg,STR0124,@aRet) //"Importar Classificação Ativo"
		aRet := AjRetParam(aRet,aPerg)
		__lExcImp := aRet[2] == 1
		oProcess:= MsNewProcess():New( {|lEnd| CTBImpCSV( lEnd, oProcess, aRet[1], aCfgImp)} )
		oProcess:Activate()
	EndIf

	If Len(aRet) > 0
		For nX := 1 to Len(__aEtapa)
			cDetalhe := ""
			aLogAux  := __aEtapa[nX][3]
			For nY := 1 to Len(aLogAux)
				cDetalhe += aLogAux[nY]
			Next nY

			If Len(cDetalhe) > 0
				ProcLogAtu( "ERRO", STR0138+ Alltrim(__aEtapa[nX][1]) + STR0139 + Alltrim(__aEtapa[nX][2]) ,cDetalhe,,.T.)//"Classificacao do Codigo "##" Item:"
			Else
				ProcLogAtu( "MENSAGEM", STR0138 + Alltrim(__aEtapa[nX][1]) + STR0139 + Alltrim(__aEtapa[nX][2]) ,cDetalhe,,.T.)//"Classificacao do Codigo "##" Item:"
			Endif

		Next nX

		ProcLogAtu( "FIM",,,,.T. )
		ProcLogView(cFilAnt,'AF010Imp',,cIdCV8 )

	Endif
EndIf

__aEtapa := {}

RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF010IClasºAutor  ³Ramon Neves         º Data ³  18/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz a  classificação contábil gerencial de ativos por meio º±±
±±º          ³ da MsExecAuto                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATF010Imp                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF010IClas(xAutoCab) //recebe o array já montado pela CTBIMPCSV
Local aArea				:= GetArea()
Local aAreaSN3	   		:= SN3->(GetArea())
Local aAreaSN1	   		:= SN1->(GetArea())
Local lRet		   		:= .T.
Local aAtfCab	   		:= {}
Local aAtfItens	   		:= {}
Local aStruSN1	   		:= CarregStru("SN1")
Local aStruSN3	   		:= CarregStru("SN3")
Local nPosBem			:= aScan(xAutoCab, {|x| AllTrim(x[1]) == "N3_CBASE"} )
Local nPosItem			:= aScan(xAutoCab, {|x| AllTrim(x[1]) == "N3_ITEM"} )
Local nPosSeq			:= aScan(xAutoCab, {|x| AllTrim(x[1]) == "N3_SEQ"} )
Local nPosTipo			:= aScan(xAutoCab, {|x| AllTrim(x[1]) == "N3_TIPO"} )
Local nPosTpSld			:= aScan(xAutoCab, {|x| AllTrim(x[1]) == "N3_TPSALDO"} )
Local nZ				:= 0
Local nX				:= 0
Local ncontItens		:= 1
Local nAchou			:= 0
Local nSeq				:= 0
Local aLog				:= {}
Local aParam			:= {}
Local lExcImp			:= __lExcImp  // Variavel static
Local cCodAtv			:= ""
Local cItemAtv			:= ""
Local cTipoAtv			:= ""
Local cTpSldAtv			:= ""

Private lMsErroAuto		:= .F.
Private lMsHelpAuto		:= .T.
Private lAutoErrNoFile	:= .T.

dbSelectArea("SN1")
dbSetOrder(1) //FILIAL+CBASE+ITEM

//--------------------------------------------------------
// Trata as informações que serão utilizadas em pesquisas
//--------------------------------------------------------
cCodAtv		:= If(nPosBem > 0 .And. ValType(xAutoCab[nPosBem][2]) <> "U",PadR(xAutoCab[nPosBem][2],TamSX3("N3_CBASE")[1]),CriaVar("N3_CBASE",.F.))
cItemAtv	:= If(nPosItem > 0 .And. ValType(xAutoCab[nPosItem][2]) <> "U",PadR(xAutoCab[nPosItem][2],TamSX3("N3_ITEM")[1]),CriaVar("N3_ITEM",.F.))
cTipoAtv	:= If(nPosTipo > 0 .And. ValType(xAutoCab[nPosTipo][2]) <> "U",PadR(xAutoCab[nPosTipo][2],TamSX3("N3_TIPO")[1]),CriaVar("N3_TIPO",.F.))
cTpSldAtv	:= If(nPosTpSld > 0 .And. ValType(xAutoCab[nPosTpSld][2]) <> "U",PadR(xAutoCab[nPosTpSld][2],TamSX3("N3_TPSALDO")[1]),CriaVar("N3_TPSALDO",.F.))

Begin Transaction

If !Empty(cCodAtv) .And. !Empty(cItemAtv) .And. !Empty(cTipoAtv) .And. !Empty(cTpSldAtv)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Preparacao do array dos itens que ja EXISTAM.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SN1->(DbSeek(XFilial("SN1")+cCodAtv+cItemAtv))   //FILIAL+CBASE+ITEM
		
		If lRet
			lRet := AF10VLClas(cCodAtv,cItemAtv,cTipoAtv,cTpSldAtv,lExcImp)
		EndIf
		
		If lRet
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Preparacao do cabecalho SN1.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nZ := 1 To Len(aStruSN1)
				AADD(aAtfCab,{aStruSN1[nZ,2],&(aStruSN1[nZ,2]),NIL})
			Next nZ
			dbSelectArea("SN3")
			dbSetOrder(1) //FILIAL+CBASE+ITEM+TIPO+BAIXA+SEQ
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Preparacao dos itens SN3.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AADD(aAtfItens,{})
	
			For nX := 1 to Len(aStruSN3)
				For nZ := 1 to Len(xAutoCab)
					If AllTrim(aStruSN3[nX,2]) == AllTrim(xAutoCab[nZ][1])
						nAchou := nZ
						Exit
					Endif
				Next nZ
				
				If nAchou != 0
					AADD(aAtfItens[ncontItens],{xAutoCab[nAchou,1],xAutoCab[nAchou,2],NIL})
					nAchou := 0
				Endif
			Next nX
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Para utilizacao da rotina automatica e necessario a inclusao do campo N3_SEQ.  ³
			//³O Campo N3_SEQ serve para enumerar o tanto de linhas da grid(aCols)            ³
			//³Grava a sequencia de aquisição do bem.Cada vez que um novo tipo é gerado no SN3³
			//³a sequencia e acresida de um. Este nro e gerado qdo um tipo e incluido no SN3. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SN3")
			dbSetOrder(1) //FILIAL+CBASE+ITEM+TIPO+BAIXA+SEQ
			
			If SN3->(DbSeek(xFilial("SN3")+cCodAtv+cItemAtv))
				While SN3->(!EOF()) .AND. SN3->N3_FILIAL+SN3->N3_CBASE+SN3->N3_ITEM == xFilial("SN3")+cCodAtv+cItemAtv
					nSeq += 1         //incrementa de acordo com o total de linhas encontradas na "SN3"
					dbSkip()
				Enddo
			Endif
			
			nPosSeq := Ascan(aAtfItens[Len(aAtfItens)],{|aItens| Alltrim(aItens[1]) == "N3_SEQ" })
			If nPosSeq > 0
				aAtfItens[Len(aAtfItens),nPosSeq,2]	:= STRZERO(nSeq+1,3)
			Else
				AADD(aAtfItens[ncontItens],{"N3_SEQ",STRZERO(nSeq+1,3),NIL})
			EndIf
			
			nPosDIn := Ascan(aAtfItens[Len(aAtfItens)],{|aItens| Alltrim(aItens[1]) == "N3_DINDEPR" })
			If nPosDIn <= 0
				AADD(aAtfItens[ncontItens],{"N3_DINDEPR",dDataBase,NIL})
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Este item foi adicionado para compatibilizacao da rotina automatica. MsGetDAuto.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AADD(aAtfItens,{})
			AADD(aAtfItens[Len(aAtfItens)],{"LINPOS","N3_TIPO",xAutoCab[nPosTipo][2]})
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Regras de importacao                     ³
			//³Execucao da rotina automatica 4 Alteracao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd( aParam, {"MV_PAR01", 2} )
			aAdd( aParam, {"MV_PAR02", 1} )
			aAdd( aParam, {"MV_PAR03", 2} )
			MSExecAuto({|a,b,c,d| Atfa010(a,b,c,d)},aAtfCab,aAtfItens,4,aParam)
			aAtfCab 	:= 	{}
			aAtfItens	:= 	{}
		EndIf
	Else
		Help( " ", 1, "AF010NOREG",, STR0129, 1, 0 ) //'Não encontrou registros'
	Endif
Else
	Help( " ", 1, "AF010ICLAS",, STR0167, 1, 0 ) //"Há campos obrigatórios utilizados para identificação do ativo não preenchidos."
EndIf

If lMsErroAuto
	aLog := GETAUTOGRLOG()
	lMsErroAuto := .F.
	lRet := .F.
Endif

aAdd(__aEtapa, {cCodAtv,cItemAtv,aLog} )

If !lRet
	DisarmTransaction()
EndIf

End Transaction

RestArea(aAreaSN1)
RestArea(aAreaSN3)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CarregStruºAutor  ³Ramon Neves         º Data ³  18/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta o a Header especifico para a rotina automatica.      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AF010Exec                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CarregStru(cAlias,aStru)
Local aAreaAnt		:= GetArea()
Local cCampoZero	:= "Zero"

Default aStru		:= {}

dbSelectArea("SX3")
dbSetOrder(1)
SX3->(dbSeek(cAlias))

While ! SX3->(Eof()) .And. (SX3->X3_ARQUIVO == cAlias)
	If  X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .Or.;
		Rtrim(X3_CAMPO) == "N3_SEQ" .Or. Rtrim(X3_CAMPO) == "N3_CBASE" .Or. Rtrim(X3_CAMPO) == "N3_ITEM".Or. Rtrim(X3_CAMPO) == "N3_TIPREAV" .Or. Rtrim(X3_CAMPO) == "N3_SEQREAV"
		If cAlias == "SN1"
			If Alltrim(X3_CAMPO) == "N1_CBASE" .Or. Alltrim(X3_CAMPO) == "N1_ITEM"
				AADD(aStru,{TRIM(X3TITULO()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID ,SX3->X3_USADO ,SX3->X3_TIPO ,SX3->X3_ARQUIVO ,SX3->X3_CONTEXT})
			EndIF
		Else
			// Alterado para conter parte do nome do campo "N3_VORIG" ou nome do arquivo "SN3" .Procura se o nome finaliza com numeros
			If !( SX3->X3_CAMPO $ "N3_CRIDEPR/N3_CALDEPR")
				cCampoZero := SX3->X3_ARQUIVO
				if Subs(X3_CAMPO, Len(Trim(X3_CAMPO)),1) $ "0123456789"
					cCampoZero := "Zero"
				Endif
				AADD(aStru,{TRIM(X3TITULO()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID ,SX3->X3_USADO ,SX3->X3_TIPO ,cCampoZero ,SX3->X3_CONTEXT})
			EndIf
		EndIf
	EndIf
	SX3->(dbSkip())
EndDo

RestArea(aAreaAnt)

Return aStru

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjRetParamºAutor  ³Alvaro Camillo Neto º Data ³  17/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ajusta as repostas do aParambox                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 		                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjRetParam(aRet,aParamBox)
Local nX := 0

If ValType(aRet) == "A" .And. Len(aRet) == Len(aParamBox)
	For nX := 1 To Len(aParamBox)
		If aParamBox[nX][1] == 2 .AND. ValType(aRet[nX]) == "C"
			aRet[nX] := aScan(aParamBox[nX][4],{|x| Alltrim(x) == aRet[nX]})
		Endif
	Next nX
EndIf

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF10VLClas ºAutor  ³Alvaro Camillo Netoº Data ³  19/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função que verifica se a classificação já existe no bem     º±±
±±º          ³Caso exista rotina irá realizar a baixa/exclusao do tipo    º±±
±±º          ³se o usuário optar por baixar classificação anterior        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AF010Imp                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF10VLClas(cCodBase,cItem,cTipo,cTpSld,lExcImp)
Local lRet 		:= .T.
Local aArea		:= GetArea()
Local aAreaSN3  := SN3->(GetArea())

SN3->(dbSetOrder(11)) // N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO

// Busca se a classificacao a ser importada já existe na ficha do bem
If SN3->(MsSeek( xFilial("SN3") + cCodBase + cItem + cTipo + "0" + cTpSld ))
	
	If lExcImp
		If !ATFVDEPRAC(cCodBase,cItem,cTipo,cTpSld) //Se o bem já possui movimentação faz a baixa do tipo
			lRet := AF010ExClas(cCodBase,cItem,cTipo,cTpSld)
		Else
			Help(" ",1, "AF010DEL")
			lRet := .F.
		EndIf
	Else
		Help( " ", 1, "AF010CLASIMP",, STR0140, 1, 0 )//"Já existe essa classificação para o bem. Verifique o tipo do bem e o tipo de saldo"
		lRet := .F.
	EndIf
	
EndIf

RestArea(aAreaSN3)
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF010ExClas ºAutor  ³Alvaro Camillo Neto º Data ³19/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza a exclusao da ficha do ativo para a importacao      º±±
±±º          ³de classificacao de ativo                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF010ExClas(cCodBase,cItem,cTipo,cTpSld)
Local aArea				:= GetArea()
Local aAreaSN3			:= SN3->(GetArea())
Local aAreaSN1			:= SN1->(GetArea())
Local lRet				:= .T.
Local aAtfCab			:= {}
Local aAtfItens			:= {}
Local aStruSN1			:= CarregStru("SN1")
Local aStruSN3			:= CarregStru("SN3")
Local nZ				:= 0
Local nA				:= 0
Local aLog				:= {}
Local aParam			:= {}

Private lMsErroAuto		:= .F.
Private lMsHelpAuto		:= .T.
Private lAutoErrNoFile	:= .T.

dbSelectArea("SN1")
dbSelectArea("SN3")

SN1->(dbSetOrder(1)) //N1_FILIAL+N1_CBASE+N1_ITEM
SN3->(dbSetOrder(11)) // N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Preparacao do array dos itens que ja EXISTAM.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If SN1->(dbSeek(xFilial("SN1")+cCodBase+cItem ))   //FILIAL+CBASE+ITEM
	
	If SN3->(MsSeek(xFilial("SN3") + cCodBase + cItem + cTipo +"0"+cTpSld ))

		/*/ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Preparacao do cabecalho SN1                            ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		For nZ := 1 To Len(aStruSN1)
			AADD(aAtfCab,{aStruSN1[nZ,2],SN1->(&(aStruSN1[nZ,2])),NIL})
		Next nZ
		
		SN3->(dbSeek(SN1->N1_FILIAL+SN1->N1_CBASE+SN1->N1_ITEM+ "01"))
		
		Do While SN3->(!Eof()) .And. SN1->(N1_FILIAL+N1_CBASE+N1_ITEM) == SN3->(N3_FILIAL+N3_CBASE+N3_ITEM)
			/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Preparacao dos itens  SN3                                ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			AADD(aAtfItens,{})
			For nZ := 1 To Len(aStruSN3)
				AADD(aAtfItens[Len(aAtfItens)],{aStruSN3[nZ,2], SN3->(&(aStruSN3[nZ,2])) ,NIL})
			Next nZ
			SN3->(dbSkip())
		EndDo
		
		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Localizar a ultima reavalicao para exclusao.             |
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		nPosTipo := Ascan(aAtfItens[Len(aAtfItens)],{|aItens| Alltrim(aItens[1]) == "N3_TIPO" })
		nPosTpSLD:= Ascan(aAtfItens[Len(aAtfItens)],{|aItens| Alltrim(aItens[1]) == "N3_TPSALDO" })
		
		For nA := 1 To Len(aAtfItens)
			If Alltrim(aAtfItens[nA,nPosTipo,2]) == cTipo .And. Alltrim(aAtfItens[nA,nPosTpSLD,2]) ==  cTpSld
				AADD(aAtfItens[nA] ,{"AUTDELETA","S",NIL})
				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Este item foi adicionado para compatibilizacao da rotina automatica. MsGetDAuto.³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				nPosSeq := Ascan(aAtfItens[nA] ,{|aItens| Alltrim(aItens[1]) == "N3_SEQ" })
				cSequen := aAtfItens[nA ,nPosSeq,2]
				AADD(aAtfItens[nA] ,{"LINPOS","N3_SEQ",cSequen})
				aAtfItens	:= {aAtfItens[nA]}
				Exit
			EndIf
		Next nA
		
		aAdd( aParam, {"MV_PAR01", 2} )
		aAdd( aParam, {"MV_PAR02", 1} )
		aAdd( aParam, {"MV_PAR03", 2} )
		MSExecAuto({|a,b,c,d| Atfa010(a,b,c,d)},aAtfCab,aAtfItens,4,aParam)
		aAtfCab 	:= 	{}
		aAtfItens	:= 	{}
	EndIf
Else
	Help( " ", 1, "AF010NOREG",, STR0129, 1, 0 ) //'Não encontrou registros'
Endif

If lMsErroAuto
	aLog := GETAUTOGRLOG()
	lMsErroAuto := .F.
	lRet := .F.
	aAdd(__aEtapa, {cCodBase,cItem,aLog} )
Endif

RestArea(aAreaSN1)
RestArea(aAreaSN3)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AFA430LOGºAutor  ³Alvaro Camillo Neto º Data ³  10/27/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Mostra o Log de processamento da rotina                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFA010LOG()

ProcLogView(,__cProcPrinc)

Return

//----------------------------------------------------------------
//MRG - Margem Gerencial
//----------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³AF010CV15	 ³ Autor ³ Mauricio Pequim Jr      ³ Data ³01/12/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Inclui o Tipo 15 referente ao Tipo 10 para a conversao         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF010CV15()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array dos bens a sofrerem conversao                   ³±±
±±³          ³ ExpA2 - Array dos recnos bens a sofrerem conversao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFIN                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010CV15(aCols,aHeader,aRecNo)

Local nX 		:= 0
Local nY 		:= 0
Local aCols15	:= {}		//Acols dos Tipos 15
Local aTip15	:= {}		//Auxiliar do Acols
Local aRecno15	:= {}		//ARecno dos Tipos 15
Local aArea		:= GetArea()
Local cCampos	:= "N3_TIPO/N3_HISTOR/N3_ITEM/N3_SEQ/N3_CCONTAB/N3_CUSTBEM/N3_SUBCCON/N3_CLVLCON/N3_VMXDEPR/N3_VLSALV1"
local aCampos	:= STRTOKARR(cCampos,"/")
Local aPosCpos	:= {}
Local nPosVlr01:= aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_VORIG1" } )
Local nPosVMax := aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_VMXDEPR" } )
Local nPosVSav := aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_VLSALV1" } )
Local nPosTipo := aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_TIPO" } )
Local nPosTpDp := aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_TPDEPR" } )
Local nPropM 	:= 0
Local nPropS 	:= 0


// *******************************
// Controle de multiplas moedas  *
// *******************************
Local __nQuantas := If(lMultMoed,AtfMoedas(),5)
Local aPosVOrigX:= If(lMultMoed,AtfMultPos(aHeader,"N3_VORIG"),;
{ 	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG1" } ),;
Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG2" } ),;
Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG3" } ),;
Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG4" } ),;
Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG5" } ) })

Local cTypes10		:= "" // CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models

If lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cTypes10 := "|" + AtfNValMod({1}, "|")
Endif

//Monto array com posicao dos campos a serem atualizados no Tipo14
For nX := 1 to Len(aCampos)
	aadd(aPosCpos,Ascan(aHeader	, {|e| Alltrim(e[2]) == Alltrim(aCampos[nX]) } ))
Next

//Gero a linha de Tipo 15
For nY := 1 to Len(aCols)
	
	//Caso seja um bem do tipo 10 esteja selecionado para conversao
	If aCols[nY][nPosTipo] $ ('10' + cTypes10)
		
		//Posiciono no SN3 - Tipo 10
		SN3->(dbGoto(aRecno[nY]))
		
		//Esse proporcao sera aplicada ao valor maximo de depreciacao e de salvamento
		nPropM 	:= aCols[nY][nPosVMax] / aCols[nY][nPosVlr01]
		nPropS 	:= aCols[nY][nPosVSav] / aCols[nY][nPosVlr01]
		
		SN3->(dbSetOrder(11)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO+N3_SEQ+N3_SEQREAV
		//Acho o TIPO 14 referente ao tipo 10
		If SN3->(MsSeek( xFilial("SN3")+SN3->(N3_CBASE+N3_ITEM)+'15'+"0"+SN3->N3_TPSALDO))
			
			//Copio os dados do Tipo 10
			aTip15 := aClone(aCols[nY])
			
			//Atualizo os dados do tipo 15
			For nX := 1 to Len(aCampos)
				If aPosCpos[nX] > 0
					aTip15[aPosCpos[nX]] := &(allTrim(aCampos[nX]))
				Endif
			Next
			
			//Atualizo os dados de valores do tipo 15
			For nX := 1 to __nQuantas
				If aPosVOrigX[nX] > 0
					aTip15[aPosVOrigX[nX]] := &("N3_VORIG"+AllTrim(Str(nX)))
				Endif
			Next
			
			//Atualizo os valores de valor maximo de depreciacao e valor de salvamento
			//Mas apenas se os mesmos foram alterados
			If aTip15[nPosVMax] > 0
				aTip15[nPosVMax] := aTip15[nPosVlr01] * If(nPropM > 0, nPropM, 1)
			Endif
			If aTip15[nPosVSav] > 0
				aTip15[nPosVSav] := aTip15[nPosVlr01] * If(nPropS > 0, nPropS, 1)
			Endif
			
			//Guardo os dados para repassar ao array de bens
			aadd(aCols15, aTip15)
			aadd(aRecno15, SN3->(RECNO()))
			
		Endif
	Endif
	
Next

//Adiciono os Bens do tipo 15 no aCols
If Len(aCols15) > 0
	For nY := 1 to Len(aCols15)
		aadd(aCols , aCols15[nY])
		aadd(aRecno, aRecno15[nY])
	Next
Endif

RestArea(aArea)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Af010MRGMul³ Autor ³ Mauricio Pequim Jr	³ Data ³ 10.09.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera as informacoes de margem gerencial na inclusao  de    ³±±
±±³          ³ multiplos bens (botao multiplos da inclusao)	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ ATFA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Af010MRGMul()

Local nInc		:= 0
Local aCols15	:= {}
Local nPosTipo := aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_TIPO" } )
//MRG
//Verifica implementacao da Margem Gerencial
Local lMargem := If(FindFunction("AFMrgAtf"),AFMrgAtf(),.F.)

//MRG
//Gera as linhas do tipo 15 a partir do tipo 10 na Inclusao
If lMargem
	
	//Verifico se o tipo 15 ja esta presente na aCols (multiplos na copia de bens)
	nPos := aScan( aCols, { |x| AllTrim( x[nPosTipo] ) == "15" } )
	
	//Caso nao exista nenhum Tipo 15 (multiplos na inclusao manual)
	//Gero o Tipo 15 de acordo com as informacoes de margem
	If nPos == 0
		AF010Grv15(aCols15)
		
		//Incluir os registros tipo 14 + tipo saldo no aCols (SN3)
		//APENAS NA INCLUSAO
		For nInc := 1 to Len(aCols15)
			aadd(aCols, aCols15[nInc])
		Next
	Endif
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³AF010CV11  ³ Autor ³                         ³ Data ³28/06/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Inclui o Tipo 11 para conversao                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF010CV11()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array dos bens a sofrerem conversao                   ³±±
±±³          ³ ExpA2 - Array dos recnos bens a sofrerem conversao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFIN                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010CV11(aCols,aHeader,aRecNo)

Local nX		:= 0
Local nY		:= 0
Local aCols11	:= {}		//Acols dos Tipos 11
Local aTip11	:= {}		//Auxiliar do Acols
Local aRecno11	:= {}		//ARecno dos Tipos 11
Local aArea		:= GetArea()
Local cCampos	:= "N3_TIPO/N3_HISTOR/N3_ITEM/N3_SEQ/N3_CCONTAB/N3_CUSTBEM/N3_SUBCCON/N3_CLVLCON/N3_VMXDEPR/N3_VLSALV1"
local aCampos	:= STRTOKARR(cCampos,"/")
Local aPosCpos	:= {}
Local nPosVlr01	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_VORIG1" } ) 
Local nPosVMax	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_VMXDEPR" } )
Local nPosVSav	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_VLSALV1" } )
Local nPosTipo	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_TIPO" } )
Local nPosTpDp	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_TPDEPR" } )
Local nPropM	:= 0
Local nPropS	:= 0
Local cFilSN3	:= ""
Local cBase		:= ""
Local cItem		:= ""
Local cTpSaldo	:= ""


// *******************************
// Controle de multiplas moedas  *
// *******************************
Local __nQuantas	:= If(lMultMoed,AtfMoedas(),5)
Local aPosVOrigX	:= If(lMultMoed,AtfMultPos(aHeader,"N3_VORIG"),;
{ 	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG1" } ),;
Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG2" } ),;
Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG3" } ),;
Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG4" } ),;
Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG5" } ) })

//Monto array com posicao dos campos a serem atualizados no Tipo11
For nX := 1 to Len(aCampos)
	aadd(aPosCpos,Ascan(aHeader	, {|e| Alltrim(e[2]) == Alltrim(aCampos[nX]) } ))
Next

//Gero a linha de Tipo 11
cFilSN3 := xFilial("SN3")
For nY := 1 to Len(aCols)
	
	//Caso seja um bem do tipo 01 esteja selecionado para conversao
	If aCols[nY][nPosTipo] == '01'
		
		//Posiciono no SN3 - Tipo 11
		SN3->(dbGoto(aRecno[nY]))
		
		//Esse proporcao sera aplicada ao valor maximo de depreciacao e de salvamento
		nPropM 	:= aCols[nY][nPosVMax] / aCols[nY][nPosVlr01]
		nPropS 	:= aCols[nY][nPosVSav] / aCols[nY][nPosVlr01]
		
		SN3->(dbSetOrder(11)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO+N3_SEQ+N3_SEQREAV
		//Acho o TIPO 11 referente ao tipo 01
		cBase := SN3->N3_CBASE
		cItem := SN3->N3_ITEM
		cTpSaldo := SN3->N3_TPSALDO
		If SN3->(DbSeek( cFilSN3 + cBase + cItem + '11' + "0" + cTpSaldo))
			While SN3->N3_FILIAL == cFilSN3 .And. SN3->N3_CBASE == cBase .And. SN3->N3_ITEM == cItem .And. SN3->N3_TIPO == "11" .And. SN3->N3_BAIXA == "0"
				//Copio os dados do Tipo 01
				aTip11 := aClone(aCols[nY])
			
				//Atualizo os dados do tipo 11
				For nX := 1 to Len(aCampos)
					If aPosCpos[nX] > 0
						aTip11[aPosCpos[nX]] := &(allTrim(aCampos[nX]))
					Endif
				Next
			
				//Atualizo os dados de valores do tipo 11
				For nX := 1 to __nQuantas
					If aPosVOrigX[nX] > 0
						aTip11[aPosVOrigX[nX]] := &("N3_VORIG"+AllTrim(Str(nX)))
					Endif
				Next
			
				//Atualizo os valores de valor maximo de depreciacao e valor de salvamento
				aTip11[nPosVMax] := aTip11[nPosVlr01] * nPropM
				aTip11[nPosVSav] := aTip11[nPosVlr01] * nPropS
			
				//Guardo os dados para repassar ao array de bens
				aadd(aCols11, aTip11)
				aadd(aRecno11, SN3->(RECNO()))
				SN3->(DbSkip())
			Enddo
		Endif
	Endif
	
Next

//Adiciono os Bens do tipo 11 no aCols
If Len(aCols11) > 0
	For nY := 1 to Len(aCols11)
		aadd(aCols , aCols11[nY])
		aadd(aRecno, aRecno11[nY])
	Next
Endif

RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Function  ³ IntegDef º Autor ³ Rodrigo M. Pontes    º Data ³  20/02/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao ³ Funcao de tratamento para o recebimento/envio de mensagem    º±±
±±º           ³ unica de Ativos                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso       ³ ATFA010                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function IntegDef( cXML, nTypeTrans, cTypeMessage, cVersion)

Local aRet := {}

	aRet := ATFI010(cXml, nTypeTrans, cTypeMessage, cVersion)

Return aRet
