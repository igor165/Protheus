#INCLUDE "PROTHEUS.CH"
#INCLUDE "APTA100.CH"
#INCLUDE "DBTREE.CH"

Static aEfd
Static cEFDAviso

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ APTA100  ³ Autor ³ Tania Bronzeri                    ³ Data ³17/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro dos Processos Trabalhistas                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ APTA100                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Modulo APT                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³12/08/2014³TQEQCC³Incluido o fonte da 11 para a 12 e efetuada a limpe-³±±
±±³            ³          ³      ³za.                                                 ³±±
±±³Renan Borges³29/10/2014³TQVDF8³Criação do ponto de entrada APT100VLD para que seja ³±±
±±³     	   ³		  ³      ³possivel realizar validações customizadas nos dados ³±±
±±³     	   ³		  ³      ³do cadastro.                                        ³±±
±±³Wag Mobile  ³08/12/2014³TR7336³Correção na aplicação do  filtro  e  posicionamento ³±±
±±³     	   ³		  ³      ³dos objetos                                         ³±±
±±³Christiane V³04/03/2015³TRUFNM³Inclusão de legenda								  ³±±
±±³Mariana M.  ³05/03/2015³TRSUD0³Ajuste para que possa incluir novo registro com a   ³±±
±±³     	   ³		  ³      ³mesma  data e tipos de recurso diferente.  		  ³±±
±±³Mariana M.  ³14/05/2015³TSEGQK³Alteração na função APT100TudOk, para que não seja  ³±±
±±³			   ³		  ³	     ³exigido, que o campo Indicativo de Decisão 		  ³±±
±±³			   ³		  ³      ³(RE0_INDDEC) ,seja obrigatório na inclusão, ou	  ³±±
±±³			   ³		  ³      ³alteração do processo.		  					  ³±±
±±³Christiane V³02/07/2015³TSMUY2³Adaptações para versão 2.0 do eSocial.			  ³±±
±±³Christiane V³14/07/2015³PCDEF-³Adaptações para versão 2.1 do eSocial.			  ³±±
±±³            ³          ³48206 ³                                      			  ³±±
±±³Renan Borges³05/04/2016³TUBFMI³Ajuste para ao incluir dois ativos com a mesma nume-³±±
±±³     	   ³		  ³      ³ração porém com itens diferentes no cadastro de pro-³±±
±±³     	   ³		  ³      ³cessos o sistema grave todos os itens.              ³±±
±±³Raquel Hager³27/05/2016³TUBFMI³Ajuste na chave de busca da tabela REP.             ³±±
±±³Gabriel A.  ³11/07/2016³TVKL10³Ajustada busca na tabela REP.                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function APTA100

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

LOCAL cFiltro		:= ""				//Variavel para filtro

Private aIndFil		:= {}				//Variavel Para Filtro
Private cFiltra		:= ""				//variavel para filtro complementar.
Private bFiltraBrw 	:= {|| Nil}			//Variavel para Filtro
Private bfiltProc   :={|cCodProc| AptSelReclam(GetObjBrow(), cCodProc )}
Private cExpFiltro	:= ""

Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemtoAnsi(STR0008)	//"Cadastro de Processos"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o botao para pesquisa do reclamante          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aConsReclam
Private bConsReclam
Private bSeleReclam

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define eSocial Processos Trabalhistas               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private  lESProc	:=  If(RE0->(ColumnPos("RE0_TPINSC")) > 0, .T., .F.)

Default aEfd 		:= If( cPaisLoc == 'BRA', If(Findfunction("fEFDSocial"), fEFDSocial(), {.F.,.F.,.F.}),{.F.,.F.,.F.} )
Default cEFDAviso	:= If(cPaisLoc == 'BRA' .AND. Findfunction("fEFDAviso"), fEFDAviso(), "0")			//Se nao encontrar este parametro apenas emitira alertas

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta o dicionario de dados                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Re8Testem()

bSeleReclam	:=	{||Eval(bfiltProc,  fGetREclamante() ) }

aConsReclam:=	{;
					"pesquisa" 							,;
			   		bSeleReclam						,;
			    	OemToAnsi( STR0075  + "...<F6>"  )	,;	//"Pesquisa Reclamante"
			    	OemToAnsi( STR0075 )				 ;	//"Pesquisa Reclamante"
		    	}
SetKey( VK_F6 , bSeleReclam )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RE0")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFiltra 	:= CHKRH(FunName(),"RE0","1")
bFiltraBrw 	:= {|cConsReclam| ;
				IIF( !Empty(cConsReclam), ;
					(cFiltro := cFiltra + IF( !Empty(cFiltra), ' .AND.', "") + cConsReclam), ;
					 cFiltro := cFiltra), FilBrowse("RE0",@aIndFil,@cFiltro,.F.) }
Eval(bFiltraBrw)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("RE0")
dbSetOrder(1)
dbGoTop()

dbSelectArea("REL")
dbSetOrder(1)

dbSelectArea("REH")
dbSetOrder(1)

dbSelectArea("RE4")
dbSetOrder(1)

dbSelectArea("REA")
dbSetOrder(1)

dbSelectArea("RE9")
dbSetOrder(1)

dbSelectArea("REO")
dbSetOrder(1)

dbSelectArea("RES")
dbSetOrder(1)

dbSelectArea("REP")
dbSetOrder(1)

dbSelectArea("REM")
dbSetOrder(1)

dbSelectArea("RC1")
dbSetOrder(3)

dbSelectArea("REG")
dbSetOrder(1)

mBrowse( 6, 1, 22, 75, "RE0" , , , , , , Apta100Marks() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("RE0",aIndFil)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Apt100Rot ³ Autor ³ Tania Bronzeri	 	³ Data ³19/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra a Tree dos Processos                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Apta100       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Apt100Rot(cAlias,nReg,nOpcx)
Local oDlgMain, oTree
Local aPleitos   	:= {}
Local aPericias		:= {}
Local aPericiAll	:= {}
Local aAdvogados	:= {}
Local aAudiencias	:= {}
Local aTestemunhas	:= {}
Local aTestemAll	:= {}
Local aOcorrencias	:= {}
Local aSentencas	:= {}
Local aRescCompl	:= {}
Local aRescAll		:= {}
Local aRecursos		:= {}
Local aDespesas		:= {}
Local aBens			:= {}
Local nOpca			:= 0
Local nOrder		:= 0
Local aFields		:= {}
Local aNoFields		:= {}
Local i				:= 0
Local bObjHide
Local aRC1KeySeek	:= {}
Local aRE0KeySeek	:= {}
Local aRE4KeySeek	:= {}
Local aREAKeySeek	:= {}
Local aREGKeySeek	:= {}
Local aRELKeySeek	:= {}
Local aREMKeySeek	:= {}
Local aREOKeySeek	:= {}
LOcal aRESKeySeek	:= {}
Local aButtons		:= {}
Local aButton100	:= {}	//Array para retorno do PE Apt100BT
Local bSet15		:= { || NIL }
Local bSet24		:= { || NIL }
Local nLenSX8		:= GetSX8Len()
Local nTamSe2		:= TamSx3("E2_PARCELA")[1]	//Encontra tamanho da Parcela no Financeiro

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Dimensionar Tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {}

Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}
Local aObj2Coords	:= {}

Local aInfo3AdvSize	:= {}
Local aObjS2Size	:= {}
Local aObj3Coords	:= {}

Local aInfo31AdvSize:= {}
Local aObjG1Size	:= {}
Local aObj31Coords	:= {}

Local aInfo32AdvSize:= {}
Local aObjG2Size	:= {}
Local aObj32Coords	:= {}

Local aInfo33AdvSize:= {}
Local aObjPFSize	:= {}
Local aObj33Coords	:= {}

Local aInfo34AdvSize:= {}
Local aObjFlSize	:= {}
Local aObj34Coords	:= {}

Local nLoop
Local nLoops
Local nOpcNewGd		:= IF( ( ( nOpcx == 2 ) .or. ( nOpcx == 5 ) ) , 0 , GD_INSERT + GD_UPDATE + GD_DELETE	)
Local x
Local nAt 			:= 0
Local cCCMemo		:= ""
Local cAuxMemo		:= ""
Local nCCMemo
Local aArea			:= GetArea()

Local nPosData := 0

Private nOpcao		:= nOpcx
Private cGet		:= ""

// Private da Getdados
Private aCols		:= {}
Private aHeader		:= {}
Private Continua	:= .F.
Private aObjects	:= {}

// Private dos objetos do Processo
Private oEnchoice
Private cNumProc	:= ""
Private cFilRE0		:= ""
Private cDesc		:= ""
Private cAno		:= ""
Private cEstou		:= "1"
Private cIndo		:= ""
Private aFase		:= {}
Private oSay1, oGetProcesso, oAux
Private aMemos1		:= { { "RE0_COBS" , "RE0_OBS" , "RE6" } }					//Variavel para tratamento dos memos Processo

// Private dos objetos do Pleito
Private oGetPleitos, oGroupPleitos
Private aMemosPleitos			:= { "REL_COBS" 	, "REL_OBS" , "RE6" }		//Variavel para tratamento dos memos Pleito
Private aMemosGravaPleitos		:= {}
Private cFilREL					:= ""

// Private dos objetos da Pericia
Private oGetPericias, oGroupPericias
Private aMemosPericias			:= { "REH_COBS"		, "REH_OBS" 	, "RE6" }	//Variavel para tratamento dos memos Pericias
Private aMemosGravaPericias		:= {}

// Private dos objetos do Advogado
Private oGetAdvogados, oGroupAdvogados
Private aMemosAdvogados			:= { "RE4_COBS" 	, "RE4_OBS" , "RE6" }		//Variavel para tratamento dos memos Advogado
Private aMemosGravaAdvogados	:= {}
Private cFilRE4					:= ""

// Private dos objetos da Audiencia
Private oGetAudiencias, oGroupAudiencias
Private aMemosAudiencias		:= { "REA_COBS"		, "REA_OBS" 	, "RE6" }	//Variavel para tratamento dos memos Audiencia
Private aMemosProvidencias		:= { "REA_CPROVI" 	, "REA_PROVID" 	, "RE6" } 	//Variavel para tratamento dos memos Providencias das Audiencias
Private aMemosConclusao			:= { "REA_CCONCL"	, "REA_CONCLS"	, "RE6" }	//Variavel para tratamento dos memos Conclusao das Audiencias
Private aMemosPauta				:= { "REA_CPAUTA"	, "REA_PAUTA"	, "RE6" }	//Variavel para tratamento dos memos Pautas das Audiencias
Private aMemosGravaAudiencia	:= {}
Private cFilREA					:= ""

// Private dos objetos da Testemunha
Private oGetTestemunhas, oGroupTestemunhas
Private aMemosTestemunhas		:= { "RE9_COBS"		, "RE9_OBS" 	, "RE6" }	//Variavel para tratamento dos memos Testemunha
Private aMemosGravaTestemunhas	:= {}
Private cFilRE9					:= ""

// Private dos objetos do Ocorrencia
Private oGetOcorrencias, oGroupOcorrencias
Private aMemosOcorrencias  		:= {}
Private aMemosGravaOcorrencias	:= {}
Private cFilREO					:= ""

dbSelectArea("SX3")
SX3->( dbSetOrder(1))

//-- Campo When estava incorreto no dicionario
If SX3->( dbSeek("REO"+"01") )
	While SX3->( !Eof() .And. SX3->X3_ARQUIVO == "REO" )
		If SX3->X3_TIPO == "M" .And. !(Empty(SX3->X3_RELACAO))
		  	nAt := At( 'REO->', SX3->X3_RELACAO )
		  	cAuxMemo:= At(',',Substr(SX3->X3_RELACAO,nAt+5))
		  	nCCMemo := ((cAuxMemo)-1)
			cCCMemo:= Substr(SX3->X3_RELACAO,nAt+5, nCCMemo)
       		Aadd(aMemosOcorrencias, {cCCMemo , SX3->X3_CAMPO , "RE6"})
  		Endif
	SX3-> (dbSkip())
	Enddo
	SX3-> (dbCloseArea())

	RestArea(aArea)
EndIf


// Private dos objetos da Sentenca
Private oGetSentencas, oGroupSentencas
Private aMemosSentencas			:= { "RES_CSENT" 	, "RES_SENT" , "RE6" }		//Variavel para tratamento dos memos Sentenca
Private aMemosGravaSentencas	:= {}
Private cFilRES					:= ""

// Private dos objetos do Pagamento da Rescisao Complementar
Private oGetRescCompl, oGroupRescCompl
Private aMemosGravaRescCompl	:= {}
Private aRescAnt				:= {}

// Private dos objetos do Recurso
Private oGetRecursos, oGroupRecursos
Private aMemosRecursos			:= { "REM_CRCRSO"	, "REM_RECURS" 	, "RE6" }	//Variavel para tratamento dos memos Recursos
Private aMemosCtraRazoes		:= { "REM_CCTRAZ" 	, "REM_CNTRAZ" 	, "RE6" } 	//Variavel para tratamento dos memos Contra-Razoes
Private aMemosGravaRecursos		:= {}
Private cFilREM					:= ""

// Private dos objetos da Despesa
Private oGetDespesas, oGroupDespesas
Private aMemosGravaDespesas		:= {}
Private cFilRC1					:= ""

// Private dos objetos dos Bens do Ativo Imobilizado
Private oGetBens, oGroupBens
Private aMemosBens	 			:= { "REG_COBS" 	, "REG_OBS" 	, "RE6" }	//Variavel para tratamento dos memos Bens Ativo Imobilizado
Private aMemosGravaBens			:= {}
Private cFilREG					:= ""

Private nPosCodRE9				:= 0
Private nPosNomRE9				:= 0
Private nPosRecRE9				:= 0 //Recno do RE9
Private nPosDelRE9				:= 0


Private aTELA[0][0],aGETS[0]
bCampo := {|nCPO| Field(nCPO) }

cFilRC1			:= xFilial("RC1")
cFilRE0			:= xFilial("RE0")
cFilRE4			:= xFilial("RE4")
cFilREA			:= xFilial("REA")
cFilREG			:= xFilial("REG")
cFilREL			:= xFilial("REL")
cFilREM			:= xFilial("REM")
cFilREO			:= xFilial("REO")
cFilRES			:= xFilial("RES")

If nOpcx # 3		// Diferente de Inclusao
	cNumProc 	:= RE0->RE0_NUM
	cDesc		:= RE0->RE0_DESCR
	aAdd( aFase, { If(!Empty(RE0->RE0_FASEDT),RE0->RE0_FASEDT,RE0->RE0_DTPROC), RE0->RE0_FASECD } )
Else
	cNumProc 	:= CriaVar("RE0_NUM")
	RollBackSX8()	// Retorna numeracao anterior.
	cDesc		:= CriaVar("RE0_DESCR")
EndIf

aRC1KeySeek		:= { cFilRC1 , cNumProc }
aRE0KeySeek		:= { cFilRE0 , cNumProc }
aRE4KeySeek		:= { cFilRE4 , cNumProc }
aREAKeySeek		:= { cFilREA , cNumProc }
aREGKeySeek		:= { cFilREG , cNumProc }
aRELKeySeek		:= { cFilREL , cNumProc }
aREMKeySeek		:= { cFilREM , cNumProc }
aREOKeySeek		:= { cFilREO , cNumProc }
aRESKeySeek		:= { cFilRES , cNumProc }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos campos de Bancos de Dados 			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == 3
	For i := 1 TO FCount()
		cCampo := EVAL(bCampo,i)
		lInit := .f.
		If ExistIni(cCampo)
			lInit := .t.
			M->&(cCampo) := InitPad(SX3->X3_RELACAO)
			If ValType(M->&(cCampo)) = "C"
				M->&(cCampo) := PADR(M->&(cCampo),SX3->X3_TAMANHO)
			EndIf
			If M->&(cCampo) == NIL
				lInit := .f.
			EndIf
		EndIf
		If !lInit
			M->&(cCampo) := FieldGet(i)
			If ValType(M->&(cCampo)) = "C"
				M->&(cCampo) := SPACE(LEN(M->&(cCampo)))
			ElseIf ValType(M->&(cCampo)) = "N"
				M->&(cCampo) := 0
			ElseIf ValType(M->&(cCampo)) = "D"
				M->&(cCampo) := CtoD("  /  /  ")
			ElseIf ValType(M->&(cCampo)) = "L"
				M->&(cCampo) := .F.
			EndIf
		EndIf
	Next i
Else
	For i := 1 TO FCount()
		 M->&(EVAL(bCampo,i)) := FieldGet(i)
	Next i
EndIf

// Montando os Arrays do Dbtree
// APT100Monta: retornos 1-aColsRec 2-Header 3-aCols
// 1- Processo 	- RE0

// 2- Pleitos - REL
nOrder 		:= 1
aFields 	:= {"REL_FILIAL","REL_PRONUM"}
aNoFields	:= {"REL_PRONUM","REL_FUNOME","REL_VERPGT","REL_VPGDES","REL_VALPGT"}
aPleitos	:= APT100Monta("REL", nReg, nOpcx, nOrder, aRELKeySeek , aFields, "RE0", .F. , aNoFields)
nLoops := Len( aPleitos[ 2 ] )
For nLoop := 1 To nLoops
	SetMemVar( aPleitos[ 2 , nLoop , 2 ] , NIL , .T. )
Next nLoop

// 2- Pericias do Pleito - REH
nOrder 		:= 1
aFields 	:= {"REH_FILIAL","REH_PRONUM"}
aPericiAll	:= APT100Monta("REH", nReg, nOpcx, nOrder, aRE0KeySeek , aFields, "RE0", .T.,aFields)
nLoops := Len( aPericiAll[ 2 ] )
For nLoop := 1 To nLoops
	SetMemVar( aPericiAll[ 2 , nLoop , 2 ] , NIL , .T. )
Next nLoop

// 3- Advogado - RE4
nOrder 		:= 1
aFields 	:= {"RE4_FILIAL","RE4_PRONUM"}
aAdvogados	:= APT100Monta("RE4", nReg, nOpcx, nOrder, aRE4KeySeek , aFields, "RE0", .F.,aFields)
nLoops := Len( aAdvogados[ 2 ] )
For nLoop := 1 To nLoops
	SetMemVar( aAdvogados[ 2 , nLoop , 2 ] , NIL , .T. )
Next nLoop

// 4- Audiencia - REA
nOrder 		:= 1
aFields 	:= {"REA_FILIAL","REA_PRONUM"}
aAudiencias	:= APT100Monta("REA", nReg, nOpcx, nOrder, aREAKeySeek , aFields, "RE0", .F.,aFields)
nLoops := Len( aAudiencias[ 2 ] )
For nLoop := 1 To nLoops
	SetMemVar( aAudiencias[ 2 , nLoop , 2 ] , NIL , .T. )
Next nLoop

// 4- Testemunhas da Audiencia - RE9
nOrder 		:= 1
aFields 	:= {"RE9_FILIAL","RE9_PRONUM"}
aTestemAll	:= APT100Monta("RE9", nReg, nOpcx, nOrder, aRE0KeySeek , aFields, "RE0", .T.,aFields)
nLoops := Len( aTestemAll[ 2 ] )
For nLoop := 1 To nLoops
	SetMemVar( aTestemAll[ 2 , nLoop , 2 ] , NIL , .T. )
Next nLoop

// 5- Ocorrencia - REO
nOrder 		:= 1
aFields 	:= {"REO_FILIAL","REO_PRONUM"}
aOcorrencias	:= APT100Monta("REO", nReg, nOpcx, nOrder, aREOKeySeek , aFields, "RE0", .F.,aFields)
nLoops := Len( aOcorrencias[ 2 ] )
For nLoop := 1 To nLoops
	SetMemVar( aOcorrencias[ 2 , nLoop , 2 ] , NIL , .T. )
Next nLoop

// 6- Sentenca - RES
nOrder 		:= 1
aFields 	:= {"RES_FILIAL","RES_PRONUM"}
aNoFields	:= {"RES_RESCOM","RES_INTEGR"}
aSentencas	:= APT100Monta("RES", nReg, nOpcx, nOrder, aRESKeySeek , aFields, "RE0", .F. , aNoFields)
nLoops := Len( aSentencas[ 2 ] )
For nLoop := 1 To nLoops
	SetMemVar( aSentencas[ 2 , nLoop , 2 ] , NIL , .T. )
Next nLoop

// 6- Rescisao Complementar - REP
nOrder 		:= 1
aFields 	:= {"REP_FILIAL","REP_PRONUM"}
aRescAll	:= APT100Monta("REP", nReg, nOpcx, nOrder, aRE0KeySeek , aFields, "RE0", .T.,aFields)
aRescAnt    := aClone(aRescAll)
nLoops := Len( aRescAll[ 2 ] )
For nLoop := 1 To nLoops
	SetMemVar( aRescAll[ 2 , nLoop , 2 ] , NIL , .T. )
Next nLoop

// 7- Recurso - REM
nOrder 		:= 1
aFields 	:= {"REM_FILIAL","REM_PRONUM"}
aRecursos	:= APT100Monta("REM", nReg, nOpcx, nOrder, aREMKeySeek , aFields, "RE0", .F.,aFields)
nLoops := Len( aRecursos[ 2 ] )
For nLoop := 1 To nLoops
	SetMemVar( aRecursos[ 2 , nLoop , 2 ] , NIL , .T. )
Next nLoop

// 8- Despesa - RC1
nOrder 		:= 3
aFields 	:= {"RC1_FILIAL","RC1_PRONUM"}
aNoFields	:= {"RC1_CODTIT","RC1_ORIGEM"}
aDespesas	:= APT100Monta("RC1", nReg, nOpcx, nOrder, aRC1KeySeek , aFields, "RE0", .F. , aNoFields)
nLoops := Len( aDespesas[ 2 ] )
For nLoop := 1 To nLoops
	SetMemVar( aDespesas[ 2 , nLoop , 2 ] , NIL , .T. )
Next nLoop

// 9- Bens - REG
nOrder 		:= 1
aFields 	:= {"REG_FILIAL","REG_PRONUM"}
aBens		:= APT100Monta("REG", nReg, nOpcx, nOrder, aREGKeySeek , aFields, "RE0", .F.,aFields)
nLoops := Len( aBens[ 2 ] )
For nLoop := 1 To nLoops
	SetMemVar( aBens[ 2 , nLoop , 2 ] , NIL , .T. )
Next nLoop

cGet := cNumProc + " - " + cDesc

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 100 , 000 , .F. , .T. } )		// Tree
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )		// Area Lateral
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords,, .T. )

aAdv1Size		:= aClone(aObjSize[2])
aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 1 , 1 }
aAdd( aObj1Coords , { 000 , 018 , .T. , .F. } )		//1-Cabec
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )		//2-Enchoice
aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords )

aAdv2Size		:= aClone(aObj1Size[1])
aInfo2AdvSize	:= { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 5 , 5 }
aAdd( aObj2Coords , { 040 , 000 , .F. , .T. } )		//1-Say - Numero do Processo
aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )		//2-Get - Numero do Processo
aObj2Size		:= MsObjSize( aInfo2AdvSize , aObj2Coords,,.T. )

aAdv3Size		:= aClone(aObj1Size[2])
aInfo3AdvSize	:= { aAdv3Size[2] , aAdv3Size[1] , aAdv3Size[4] , aAdv3Size[3] , 1 , 1 }
aAdd( aObj3Coords , { 000 , 000 , .T. , .T. } )		//1-Group
aAdd( aObj3Coords , { 000 , 000 , .T. , .T. } )		//2-Group
aObjS2Size		:= MsObjSize( aInfo3AdvSize , aObj3Coords)

aAdv31Size		:= aClone(aObjS2Size[1])
aInfo31AdvSize	:= { aAdv31Size[2] , aAdv31Size[1] , aAdv31Size[4] , aAdv31Size[3] , 5 , 7}
aAdd( aObj31Coords , { 000 , 000 , .T. , .T. } )	//1-Grid
aObjG1Size		:= MsObjSize( aInfo31AdvSize , aObj31Coords )

aAdv32Size		:= aClone(aObjS2Size[2])
aInfo32AdvSize	:= { aAdv32Size[2] , aAdv32Size[1] , aAdv32Size[4] , aAdv32Size[3] , 5 , 7}
aAdd( aObj32Coords , { 000 , 000 , .T. , .T. } )	//2-Grid
aObjG2Size		:= MsObjSize( aInfo32AdvSize , aObj31Coords )

aAdv33Size		:= aClone(aObj1Size[2])
aInfo33AdvSize	:= { aAdv33Size[2] , aAdv33Size[1] , aAdv33Size[4] , aAdv33Size[3] , 1 , 1 }
aAdd( aObj33Coords , { 000 , 000 , .T. , .T. } )		//Grid
aObjPFSize		:= MsObjSize( aInfo3AdvSize , aObj33Coords)

aAdv34Size		:= aClone(aObjPFSize[1])
aInfo34AdvSize	:= { aAdv34Size[2] , aAdv34Size[1] , aAdv34Size[4] , aAdv34Size[3] , 5 , 7}
aAdd( aObj34Coords , { 000 , 000 , .T. , .T. } )	//1-Grid
aObjFlSize		:= MsObjSize( aInfo34AdvSize , aObj34Coords )

DEFINE MSDIALOG oDlgMain FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE OemToAnsi(STR0008)	OF oMainWnd  PIXEL	//"Cadastro de Processos"

	DEFINE DBTREE oTree FROM aObjSize[1,1],aObjSize[1,2] TO aObjSize[1,3],aObjSize[1,4] CARGO OF oDlgMain

		oTree:bValid 	:= {|| APT100VlTree(nOpcx) }
		oTree:lValidLost:= .F.
		oTree:lActivated:= .T.

		DBADDTREE oTree PROMPT OemToAnsi(STR0011)+Space(30);	//"Processo"
							 RESOURCE "FOLDER5","FOLDER6";
							 CARGO "1"
		DBENDTREE oTree

		DBADDTREE oTree PROMPT OemToAnsi(STR0012);				//"Pleitos"
							 RESOURCE "FOLDER5","FOLDER6";
							 CARGO "2"
		DBENDTREE oTree

		DBADDTREE oTree PROMPT OemToAnsi(STR0023);				//"Advogados"
							 RESOURCE "FOLDER5","FOLDER6";
							 CARGO "3"
		DBENDTREE oTree

		DBADDTREE oTree PROMPT OemToAnsi(STR0014);				//"Audiencias"
							 RESOURCE "FOLDER5","FOLDER6";
							 CARGO "4"
		DBENDTREE oTree

		DBADDTREE oTree PROMPT OemToAnsi(STR0018);				//"Ocorrencias"
							 RESOURCE "FOLDER5","FOLDER6";
							 CARGO "5"
		DBENDTREE oTree

		DBADDTREE oTree PROMPT OemToAnsi(STR0002);				//"Sentencas"
							 RESOURCE "FOLDER5","FOLDER6";
							 CARGO "6"
		DBENDTREE oTree

		DBADDTREE oTree PROMPT OemToAnsi(STR0009);				//"Recursos"
							 RESOURCE "FOLDER5","FOLDER6";
							 CARGO "7"
		DBENDTREE oTree

		DBADDTREE oTree PROMPT OemToAnsi(STR0017);				//"Despesas/Pagamentos"
							 RESOURCE "FOLDER5","FOLDER6";
							 CARGO "8"
		DBENDTREE oTree

		DBADDTREE oTree PROMPT OemToAnsi(STR0026);				//"Bem Garantia/Penhora"
							 RESOURCE "FOLDER5","FOLDER6";
							 CARGO "9"
		DBENDTREE oTree

		// Processo
		Zero()
		aMemos		:=	aClone(aMemos1)
		oEnchoice	:= MsMGet():New(cAlias,nReg,nOpcx,NIL,NIL,NIL,NIL,aObjSize[2], , , , , , , , ,.T. )

		@ aObj2Size[1,1],aObj2Size[1,2] Say oSay1 PROMPT OemToAnsi(STR0010) SIZE 25,7 PIXEL		//"Processo: "
		@ aObj2Size[2,1],aObj2Size[2,2] Get oGetProcesso VAR cGet SIZE 150,7 WHEN .F. PIXEL

		// Pleitos
		aHeader				:= 	{}
		aCols				:= 	{}
		aMemosGravaPleitos	:= 	{}
		n					:= 1

		@ aObjS2Size[1,1],aObjS2Size[1,2] GROUP oGroupPleitos TO aObjS2Size[1,3],aObjS2Size[1,4] LABEL OemtoAnsi(STR0013)	OF oDlgMain PIXEL 	// " Pleitos "
		oGetPleitos 	:= MSNewGetDados():New(	aObjG1Size[1,1],	;	//nTop
												aObjG1Size[1,2],	;	//nLeft
												aObjG1Size[1,3],	;	//nBottom
												aObjG1Size[1,4],	;	//nRight
												nOpcNewGd,		;	//nStyle (nOpc)
												"AptPleitosOk",	;	//LinhaOk
												"AllwaysTrue",	;	//TudoOk
												"",				;	//cIniCpos
												NIL,			;	//aAlter
												NIL,			;	//nFreeze
												9999,			;	//nMax
												NIL,			;	//cFieldOk
												NIL,			;	//uSuperDel
												NIL,			;	//uDelOk
												@oDlgMain,	;	//oWnd
												aPleitos[2],	;	//aHeader
												aPleitos[3]		;	//aCols
												)
		oGetPleitos:oBrowse:Default()
		
		aAdd (aMemosGravaPleitos, { aMemosPleitos } )
		aAdd ( aObjects , { oGetPleitos , "REL" , aPleitos[1] , aMemosGravaPleitos } )
		
		// Pericias
		aHeader					:= 	{}
		aCols					:= 	{}
		aMemosGravaPericias		:=	{}
		n		:= 1
		aRELKeySeek	:= { cFilRE0 , cNumProc , oGetPLeitos:aCols[1][1] }
		aFields		:= {"REH_FILIAL","REH_PRONUM","REH_CODPLT"}
		aPericias	:= APT100Monta("REH", nReg, nOpcx, nOrder, aRELKeySeek , aFields, "REL", .F.)
		
		Apta100AllTrf(	"REH" 					,;	//01 -> Alias do Arquivo
						oGetPleitos				,;	//02 -> Objeto GetDados para o REL
						@aPericias[3]			,;	//03 -> aCols utilizado na GetDados
						aPericias[2] 			,;	//04 -> aHeader utilizado na GetDados
						@aPericiAll[3]			,;	//05 -> aCols com todas as informacoes
						aPericiAll[2]			,;	//06 -> aHeader com todos os campos
						.F.						,;	//07 -> Se carrega elemento de Deletado na remontagem do aCols
						.F.						,;	//08 -> Se transfere do aCols para o aColsAll
						.T.				 		;	//09 -> Se transfere do aColsAll para o aCols
  					)
		
		
		nLoops := Len( aPericias[ 2 ] )
		For nLoop := 1 To nLoops
			SetMemVar( aPericias[ 2 , nLoop , 2 ] , NIL , .T. )
		Next nLoop
		@ aObjS2Size[2,1],aObjS2Size[2,2] GROUP oGroupPericias TO aObjS2Size[2,3],aObjS2Size[2,4] LABEL OemtoAnsi(STR0016)	OF oDlgMain PIXEL	// " Pericias "
		oGetPericias := MsNewGetDados():New	(	aObjG2Size[1,1],	;	//nTop
												aObjG2Size[1,2],	;	//nLeft
												aObjG2Size[1,3],	;	//nBottom
												aObjG2Size[1,4],	;	//nRight
												nOpcNewGd		,;	//nStyle (nOpc)
												"AptPericiasOk"	,;	//LinhaOk
												"AllwaysTrue"	,;	//TudoOk
												""				,;	//cIniCpos
												NIL				,;	//aAlter
												NIL				,;	//nFreeze
												99999			,;	//nMax
												NIL				,;	//cFieldOk
												NIL				,;	//uSuperDel
												NIL	 			,;	//uDelOk
												@oDlgMain		,;	//oWnd
												aPericias[2]	,;	//aHeader
												aPericias[3]	 ;	//aCols
												)
		oGetPleitos:bChange := 	{	||;
									Apta100AllTrf	(	"REH" 					,;	//01 -> Alias do Arquivo
														oGetPleitos				,;	//02 -> Objeto GetDados para o REL
														@oGetPericias:aCols		,;	//03 -> aCols utilizado na GetDados
														oGetPericias:aHeader	,;	//04 -> aHeader utilizado na GetDados
														@aPericiAll[3]			,;	//05 -> aCols com todas as informacoes
														aPericiAll[2]			,;	//06 -> aHeader com todos os campos
														.F.						,;	//07 -> Se carrega elemento de Deletado na remontagem do aCols
														.F.						,;	//08 -> Se transfere do aCols para o aColsAll
														.T.				 		;	//09 -> Se transfere do aColsAll para o aCols
			  										),;
									Apta100Des		(	"REH"					,;	//01 -> Alias do Arquivo
														aPericiAll[2]			,;	//02 -> aCols com todas as informacoes
														@aPericiAll[3]         	;	//03 -> aHeader com todos os campos
													),;
									oGetPericias:Goto( 1 ),;
									oGetPericias:Refresh();
									}

		oGetPericias:oBrowse:bLostFocus := { |nAtRel,lLinOk|;
											nAtRel	:= oGetPleitos:oBrowse:nAt,;
											lLinOk	:= .F.,;
											IF( lLinOk := oGetPericias:LinhaOk(),;
												Apta100AllTrf(	"REH" 					,;	//01 -> Alias do Arquivo
																oGetPleitos				,;	//02 -> Objeto GetDados para o REL
																@oGetPericias:aCols		,;	//03 -> aCols utilizado na GetDados
																oGetPericias:aHeader 	,;	//04 -> aHeader utilizado na GetDados
																@aPericiAll[3]			,;	//05 -> aCols com todas as informacoes
																aPericiAll[2]			,;	//06 -> aHeader com todos os campos
																.F.						,;	//07 -> Se carrega elemento de Deletado na remontagem do aCols
																.T.						,;	//08 -> Se transfere do aCols para o aColsAll
																.T.				 		 ;	//09 -> Se transfere do aColsAll para o aCols
	 		  												 ),;
												(;
											   		oGetPleitos:Goto( nAtRel ),;
													oGetPericias:oBrowse:SetFocus(),;
													oGetPericias:Goto( oGetPericias:oBrowse:nAt ),;
													oGetPericias:Refresh();
												);
											  ),;
											lLinOk ;
										 }
		aAdd ( aMemosGravaPericias , { aMemosPericias 	} )

/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Transfere os Dados da Pericias do aCols para o aColsAll	   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		Apta100AllTrf(	"REH" 					,;	//01 -> Alias do Arquivo
						oGetPleitos				,;	//02 -> Objeto GetDados para o REL
						@oGetPericias:aCols		,;	//03 -> aCols utilizado na GetDados
						oGetPericias:aHeader 	,;	//04 -> aHeader utilizado na GetDados
						@aPericiAll[3]			,;	//05 -> aCols com todas as informacoes
						aPericiAll[2]			,;	//06 -> aHeader com todos os campos
						.T.						,;	//07 -> Se carrega elemento de Deletado na remontagem do aCols
						.T.						,;	//08 -> Se transfere do aCols para o aColsAll
						.F.				 		 ;	//09 -> Se transfere do aColsAll para o aCols
					 )
		aAdd ( aObjects , { oGetPericias , "REH", aPericiAll , aMemosGravaPericias } )


		// Advogado
		aHeader					:= 	{}
		aCols					:= 	{}
		aMemosGravaAdvogados	:=	{}
		n						:= 1

		@ aObjPFSize[1,1],aObjPFSize[1,2] GROUP oGroupAdvogados TO aObjPFSize[1,3],aObjPFSize[1,4] LABEL OemtoAnsi(STR0024)	OF oDlgMain PIXEL	// " Advogado
		oGetAdvogados 	:= MSNewGetDados():New(	aObjFlSize[1,1],	;	//nTop
												aObjFlSize[1,2],	;	//nLeft
												aObjFlSize[1,3],	;	//nBottom
												aObjFlSize[1,4],	;	//nRight
												nOpcNewGd,		;
												"AptAdvogadosOk",	;
												"AllwaysTrue",	;
												"",				;
												NIL,			;
												NIL,			;
												9999,			;
												NIL,			;
												NIL,			;
												NIL,			;
												@oDlgMain,		;
												aAdvogados[2],	;
												aAdvogados[3]	;
										)
		oGetAdvogados:oBrowse:Default()
		aAdd ( aMemosGravaAdvogados , { aMemosAdvogados } )
		aAdd ( aObjects , { oGetAdvogados , "RE4" , aAdvogados[1] , aMemosGravaAdvogados } )

		// Audiencia
		aHeader					:= 	{}
		aCols					:= 	{}
		aMemosGravaAudiencia	:=	{}
		n		:= 1

		@ aObjS2Size[1,1],aObjS2Size[1,2] GROUP oGroupAudiencias TO aObjS2Size[1,3],aObjS2Size[1,4] LABEL OemtoAnsi(STR0015)	OF oDlgMain PIXEL	// " Audiencia "
		oGetAudiencias 	:= MSNewGetDados():New(	aObjG1Size[1,1],	;	//nTop
												aObjG1Size[1,2],	;	//nLeft
												aObjG1Size[1,3],	;	//nBottom
												aObjG1Size[1,4],	;	//nRight
												nOpcNewGd	,		;
												"AptAudienciasOk",	;
												"AllwaysTrue"	,	;
												""		,			;
												NIL		,			;
												NIL		,			;
												9999	,			;
												NIL		,			;
												NIL		,			;
												NIL		,			;
												@oDlgMain	,		;
												aAudiencias[2]	,	;
												aAudiencias[3]		;
											)
		oGetAudiencias:oBrowse:Default()
		aAdd ( aMemosGravaAudiencia , { aMemosPauta		 	} )
		aAdd ( aMemosGravaAudiencia , { aMemosProvidencias 	} )
		aAdd ( aMemosGravaAudiencia , { aMemosConclusao		} )
		aAdd ( aMemosGravaAudiencia , { aMemosAudiencias 	} )
		aAdd ( aObjects , { oGetAudiencias , "REA", aAudiencias[1] , aMemosGravaAudiencia } )

		// Testemunhas
		aHeader					:= 	{}
		aCols					:= 	{}
		aMemosGravaTestemunhas	:=	{}
		n		:= 1

		nPosData := GdFieldPos("REA_DATA"	,oGetAudiencias:aHeader)


		aREAKeySeek	:= { cFilRE0 , cNumProc , DtoS( oGetAudiencias:aCols[1][nPosData] ) }
		aFields		:= {"RE9_FILIAL","RE9_PRONUM","RE9_DATA"}
		aTestemunhas:= APT100Monta("RE9", nReg, nOpcx, nOrder, aREAKeySeek , aFields, "REA", .F.)

		Apta100AllTrf(	"RE9" 					,;	//01 -> Alias do Arquivo
						oGetAudiencias			,;	//02 -> Objeto GetDados para o REA
						@aTestemunhas[3]		,;	//03 -> aCols utilizado na GetDados
						aTestemunhas[2]			,;	//04 -> aHeader utilizado na GetDados
						@aTestemAll[3]			,;	//05 -> aCols com todas as informacoes
						aTestemAll[2]			,;	//06 -> aHeader com todos os campos
						.F.						,;	//07 -> Se carrega elemento de Deletado na remontagem do aCols
						.F.						,;	//08 -> Se transfere do aCols para o aColsAll
						.T.)			 		;	//09 -> Se transfere do aColsAll para o aCols



		nLoops := Len( aTestemunhas[ 2 ] )
		For nLoop := 1 To nLoops
			SetMemVar( aTestemunhas[ 2 , nLoop , 2 ] , NIL , .T. )
		Next nLoop

		nPosCodRE9	:= GdFieldPos( "RE9_TESCOD", aTestemunhas[ 2 ] )
		nPosNomRE9	:= GdFieldPos( "RE9_TESNOM", aTestemunhas[ 2 ] )
		nPosRecRE9	:= GdFieldPos( "RE9_REC_WT", aTestemunhas[ 2 ] )
		nPosDelRE9	:= GdFieldPos( "GDDELETED", aTestemunhas[ 2 ] )

		For nLoop := 1 To Len(aTestemunhas[ 3 ])
			If (	(aTestemunhas[ 3, nLoop, nPosRecRE9 ] == 0)	.and.;
					!(aTestemunhas[ 3, nLoop, nPosDelRE9 ])			.and.;
					Empty(aTestemunhas[ 3, nLoop, nPosCodRE9 ])	)
				aTestemunhas[ 3, nLoop, nPosNomRE9 ] := Space( GetSX3Cache("RE9_TESNOM", "X3_TAMANHO") )
			EndIf
		Next

		@ aObjS2Size[2,1],aObjS2Size[2,2] GROUP oGroupTestemunhas TO aObjS2Size[2,3],aObjS2Size[2,4] LABEL OemtoAnsi(STR0028)	OF oDlgMain PIXEL	// " Testemunhas "
		oGetTestemunhas := MsNewGetDados():New	(	aObjG2Size[1,1],	;	//nTop
													aObjG2Size[1,2],	;	//nLeft
													aObjG2Size[1,3],	;	//nBottom
													aObjG2Size[1,4],	;	//nRight
													nOpcNewGd			,;	//nStyle (nOpc)
													"AptTestemunhasOk"	,;	//LinhaOk
													"AllwaysTrue"		,;	//TudoOk
													""					,;	//cIniCpos
													NIL					,;	//aAlter
													NIL					,;	//nFreeze
													99999				,;	//nMax
													NIL					,;	//cFieldOk
													NIL					,;	//uSuperDel
													NIL	 				,;	//uDelOk
													@oDlgMain			,;	//oWnd
													aTestemunhas[2]		,;	//aHeader
													aTestemunhas[3]		 ;	//aCols
												)
		oGetAudiencias:bChange := 	{	||;
										Apta100AllTrf(	"RE9" 					,;	//01 -> Alias do Arquivo
														oGetAudiencias			,;	//02 -> Objeto GetDados para o REA
														@oGetTestemunhas:aCols	,;	//03 -> aCols utilizado na GetDados
														oGetTestemunhas:aHeader	,;	//04 -> aHeader utilizado na GetDados
														@aTestemAll[3]			,;	//05 -> aCols com todas as informacoes
														aTestemAll[2]			,;	//06 -> aHeader com todos os campos
														.F.						,;	//07 -> Se carrega elemento de Deletado na remontagem do aCols
														.F.						,;	//08 -> Se transfere do aCols para o aColsAll
														.T.				 		;	//09 -> Se transfere do aColsAll para o aCols
			 		  										 ),;
										oGetTestemunhas:Goto( 1 ),;
										oGetTestemunhas:Refresh();
 									}
		oGetTestemunhas:oBrowse:bLostFocus := { |nAtRea,lLinOk|;
												nAtRea	:= oGetAudiencias:oBrowse:nAt,;
												lLinOk	:= .F.,;
												IF( lLinOk := oGetTestemunhas:LinhaOk(),;
													Apta100AllTrf(	"RE9" 					,;	//01 -> Alias do Arquivo
																	oGetAudiencias			,;	//02 -> Objeto GetDados para o REA
																	@oGetTestemunhas:aCols	,;	//03 -> aCols utilizado na GetDados
																	oGetTestemunhas:aHeader ,;	//04 -> aHeader utilizado na GetDados
																	@aTestemAll[3]			,;	//05 -> aCols com todas as informacoes
																	aTestemAll[2]			,;	//06 -> aHeader com todos os campos
																	.F.						,;	//07 -> Se carrega elemento de Deletado na remontagem do aCols
																	.T.						,;	//08 -> Se transfere do aCols para o aColsAll
																	.T.				 		 ;	//09 -> Se transfere do aColsAll para o aCols
		 		  												 ),;
													(;
														oGetAudiencias:Goto( nAtRea ),;
														oGetTestemunhas:oBrowse:SetFocus(),;
														oGetTestemunhas:Goto( oGetTestemunhas:oBrowse:nAt ),;
														oGetTestemunhas:Refresh();
													);
												  ),;
												lLinOk;
											 }
		aAdd ( aMemosGravaTestemunhas , { aMemosTestemunhas 	} )

/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Transfere os Dados da Testemunha do aCols para o aColsAll	   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		Apta100AllTrf(	"RE9" 					,;	//01 -> Alias do Arquivo
						oGetAudiencias			,;	//02 -> Objeto GetDados para o REA
						@oGetTestemunhas:aCols	,;	//03 -> aCols utilizado na GetDados
						oGetTestemunhas:aHeader ,;	//04 -> aHeader utilizado na GetDados
						@aTestemAll[3]			,;	//05 -> aCols com todas as informacoes
						aTestemAll[2]			,;	//06 -> aHeader com todos os campos
						.T.						,;	//07 -> Se carrega elemento de Deletado na remontagem do aCols
						.T.						,;	//08 -> Se transfere do aCols para o aColsAll
						.F.				 		 ;	//09 -> Se transfere do aColsAll para o aCols
					 )
		aAdd ( aObjects , { oGetTestemunhas , "RE9", aTestemAll , aMemosGravaTestemunhas } )

		//Ocorrencia
		aHeader					:= 	{}
		aCols					:= 	{}
		aMemosGravaOcorrencias	:=	{}
		n						:= 1

		@ aObjPFSize[1,1],aObjPFSize[1,2] GROUP oGroupOcorrencias TO aObjPFSize[1,3],aObjPFSize[1,4] LABEL OemtoAnsi(STR0019)	OF oDlgMain PIXEL 	// " Ocorrencia "
		oGetOcorrencias 	:= MSNewGetDados():New(	aObjFlSize[1,1],	;	//nTop
													aObjFlSize[1,2],	;	//nLeft
													aObjFlSize[1,3],	;	//nBottom
													aObjFlSize[1,4],	;	//nRight
													nOpcNewGd,			;
													"AptOcorrenciasOk",	;
													"AllwaysTrue",		;
													"",					;
													NIL,				;
													NIL,				;
													9999,				;
													NIL,				;
													NIL,				;
													NIL,				;
													oDlgMain,			;
													aOcorrencias[2],	;
													aOcorrencias[3]		;
													)
		oGetOcorrencias:oBrowse:Default()

	    For x := 1 to Len(aMemosOcorrencias)
	    	aAdd ( aMemosGravaOcorrencias , { aMemosOcorrencias [x]} )
	    Next x

	    aAdd ( aObjects , { oGetOcorrencias , "REO", aOcorrencias[1] , aMemosGravaOcorrencias } )

		//Sentenca
		aHeader					:= 	{}
		aCols					:= 	{}
		aMemosGravaSentencas	:=	{}
		n						:= 1

		@ aObjS2Size[1,1],aObjS2Size[1,2] GROUP oGroupSentencas TO aObjS2Size[1,3],aObjS2Size[1,4] LABEL OemtoAnsi(STR0027)	OF oDlgMain PIXEL 	// " Sentenca "
		oGetSentencas 	:= MSNewGetDados():New(	aObjG1Size[1,1],	;	//nTop
												aObjG1Size[1,2],	;	//nLeft
												aObjG1Size[1,3],	;	//nBottom
												aObjG1Size[1,4],	;	//nRight
												nOpcNewGd,			;	//nStyle	(nOpc)
												"AptSentencasOk",	;	//LinhaOk
												"AllwaysTrue",		;	//TudoOk
												"",					;	//cIniCpos
												NIL,				;	//aAlter
												NIL,				;	//nFreeze
												9999,				;	//nMax
												NIL,				;	//cFieldOk
												NIL,				;	//uSperDel
												NIL,				;	//uDelOk
												@oDlgMain,			;	//oWnd
												aSentencas[2],		;	//aHeader
												aSentencas[3]		;	//aCols
												)
		oGetSentencas:oBrowse:Default()
		aAdd ( aMemosGravaSentencas , { aMemosSentencas } )
		aAdd ( aObjects , { oGetSentencas , "RES", aSentencas[1] , aMemosGravaSentencas } )

		// Rescisoes Complementares
		aHeader					:= 	{}
		aCols					:= 	{}
		aMemosGravaRescCompl	:=	{}
		n		:= 1
		aRESKeySeek		:= {cFilRe0, cNumProc, DtoS(oGetSentencas:aCols[1][1])}
		aFields			:= {"REP_FILIAL", "REP_PRONUM", "REP_DTSTCA"}
		aRescCompl		:= APT100Monta("REP", nReg, nOpcx, nOrder, aRESKeySeek, aFields, "RES", .F.)

		Apta100AllTrf(	"REP" 					,;	//01 -> Alias do Arquivo
						oGetSentencas			,;	//02 -> Objeto GetDados para o RES
						@aRescCompl[3]			,;	//03 -> aCols utilizado na GetDados
						aRescCompl[2]			,;	//04 -> aHeader utilizado na GetDados
						@aRescAll[3]			,;	//05 -> aCols com todas as informacoes
						aRescAll[2]				,;	//06 -> aHeader com todos os campos
						.F.						,;	//07 -> Se carrega elemento de Deletado na remontagem do aCols
						.F.						,;	//08 -> Se transfere do aCols para o aColsAll
						.T.)				 	;	//09 -> Se transfere do aColsAll para o aCols



		nLoops	:= Len( aRescCompl[2] )
		For nLoop := 1 To nLoops
			SetMemVar( aRescCompl[ 2 , nLoop , 2 ] , NIL , .T. )
		Next nLoop

		@ aObjS2Size[2,1],aObjS2Size[2,2] GROUP oGroupRescCompl TO aObjS2Size[2,3],aObjS2Size[2,4] LABEL OemtoAnsi(STR0055)	OF oDlgMain PIXEL	// " Rescisoes Complementares "
		oGetRescCompl 	:= MsNewGetDados():New(	aObjG2Size[1,1],	;	//nTop
												aObjG2Size[1,2],	;	//nLeft
												aObjG2Size[1,3],	;	//nBottom
												aObjG2Size[1,4],	;	//nRight
												nOpcNewGd		,;	//nStyle (nOpc)
												"AptRescComplOk",;	//LinhaOk
												"AllwaysTrue"	,;	//TudoOk
												""				,;	//cIniCpos
												NIL				,;	//aAlter
												NIL				,;	//nFreeze
												99999			,;	//nMax
												NIL				,;	//cFieldOk
												NIL				,;	//uSuperDel
												NIL	 			,;	//uDelOk
												@oDlgMain		,;	//oWnd
												aRescCompl[2]	,;	//aHeader
												aRescCompl[3]	 ;	//aCols
												)

		oGetSentencas:bChange := 	{	||;
										Apta100AllTrf(	"REP" 					,;	//01 -> Alias do Arquivo
														oGetSentencas			,;	//02 -> Objeto GetDados para o RES
														@oGetRescCompl:aCols	,;	//03 -> aCols utilizado na GetDados
														oGetRescCompl:aHeader	,;	//04 -> aHeader utilizado na GetDados
														@aRescAll[3]			,;	//05 -> aCols com todas as informacoes
														aRescAll[2]				,;	//06 -> aHeader com todos os campos
														.F.						,;	//07 -> Se carrega elemento de Deletado na remontagem do aCols
														.F.						,;	//08 -> Se transfere do aCols para o aColsAll
														.T.				 		;	//09 -> Se transfere do aColsAll para o aCols
			 		  										 ),;
										oGetRescCompl:Goto( 1 ),;
										oGetRescCompl:Refresh();
 									}
		oGetRescCompl:oBrowse:bLostFocus := { |nAtRes,lLinOk|;
												nAtRes	:= oGetSentencas:oBrowse:nAt,;
												lLinOk	:= .F.,;
												IF( lLinOk := oGetRescCompl:LinhaOk(),;
													Apta100AllTrf(	"REP" 					,;	//01 -> Alias do Arquivo
																	oGetSentencas			,;	//02 -> Objeto GetDados para o RES
																	@oGetRescCompl:aCols	,;	//03 -> aCols utilizado na GetDados
																	oGetRescCompl:aHeader	,;	//04 -> aHeader utilizado na GetDados
																	@aRescAll[3]			,;	//05 -> aCols com todas as informacoes
																	aRescAll[2]				,;	//06 -> aHeader com todos os campos
																	.F.						,;	//07 -> Se carrega elemento de Deletado na remontagem do aCols
																	.T.						,;	//08 -> Se transfere do aCols para o aColsAll
																	.T.				 		 ;	//09 -> Se transfere do aColsAll para o aCols
		 		  												 ),;
													(;
														oGetSentencas:Goto( nAtRes ),;
														oGetRescCompl:oBrowse:SetFocus(),;
														oGetRescCompl:Goto( oGetRescCompl:oBrowse:nAt ),;
														oGetRescCompl:Refresh();
													);
												  ),;
												lLinOk;
											 }

/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Transfere os Dados da Rescisao Complementar do aCols para o aColsAll	   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		Apta100AllTrf(	"REP" 					,;	//01 -> Alias do Arquivo
						oGetSentencas			,;	//02 -> Objeto GetDados para o RES
						@oGetRescCompl:aCols	,;	//03 -> aCols utilizado na GetDados
						oGetRescCompl:aHeader	,;	//04 -> aHeader utilizado na GetDados
						@aRescAll[3]			,;	//05 -> aCols com todas as informacoes
						aRescAll[2]				,;	//06 -> aHeader com todos os campos
						.T.						,;	//07 -> Se carrega elemento de Deletado na remontagem do aCols
						.T.						,;	//08 -> Se transfere do aCols para o aColsAll
						.F.				 		 ;	//09 -> Se transfere do aColsAll para o aCols
					 )

		aAdd ( aObjects , { oGetRescCompl , "REP", aRescAll , aMemosGravaRescCompl } )

		//Recurso
		aHeader					:= 	{}
		aCols					:= 	{}
		aMemosGravaRecursos		:=	{}
		n						:= 1

		@ aObjPFSize[1,1],aObjPFSize[1,2] GROUP oGroupRecursos TO aObjPFSize[1,3],aObjPFSize[1,4] LABEL OemtoAnsi(STR0029)	OF oDlgMain PIXEL 	// " Recursos "
		oGetRecursos 	:= MSNewGetDados():New(	aObjFlSize[1,1],	;	//nTop
												aObjFlSize[1,2],	;	//nLeft
												aObjFlSize[1,3],	;	//nBottom
												aObjFlSize[1,4],	;	//nRight
												nOpcNewGd,			;
												"AptRecursosOk",	;
												"AllwaysTrue",		;
												"",					;
												NIL,				;
												NIL,				;
												9999,				;
												NIL,				;
												NIL,				;
												NIL,				;
												oDlgMain,			;
												aRecursos[2],		;
												aRecursos[3]		;
												)
		oGetRecursos:oBrowse:Default()
		aAdd ( aMemosGravaRecursos , { aMemosRecursos 	} )
		aAdd ( aMemosGravaRecursos , { aMemosCtraRazoes	} )
		aAdd ( aObjects , { oGetRecursos , "REM", aRecursos[1] , aMemosGravaRecursos } )

		//Despesas / Pagamentos
		aHeader					:= 	{}
		aCols					:= 	{}
		aMemosGravaDespesas		:=	{}
		n						:= 	1
		nLoops := Len( aDespesas[ 2 ] )
		For nLoop := 1 To nLoops
			If (aDespesas[2][nLoop][2] == "RC1_PARC")
				aDespesas[2][nLoop][4] := nTamSe2
				Exit
			EndIf
		Next nLoop

		@ aObjPFSize[1,1],aObjPFSize[1,2] GROUP oGroupDespesas TO aObjPFSize[1,3],aObjPFSize[1,4] LABEL OemtoAnsi(STR0032)	OF oDlgMain PIXEL 	// " Despesas/Pagamentos "
		oGetDespesas 	:= MSNewGetDados():New(	aObjFlSize[1,1],	;	//nTop
												aObjFlSize[1,2],	;	//nLeft
												aObjFlSize[1,3],	;	//nBottom
												aObjFlSize[1,4],	;	//nRight
												nOpcNewGd,			;
												"AptDespesasOk",	;
												"AptDespTdOk",		;
												"",					;
												NIL,				;
												NIL,				;
												9999,				;
												NIL,				;
												NIL,				;
												{ |lDelOk| RC1DelOk() },				;
												oDlgMain,			;
												aDespesas[2],		;
												aDespesas[3]		;
												)
		oGetDespesas:oBrowse:Default()
		aAdd ( aObjects , { oGetDespesas , "RC1", aDespesas[1] , aMemosGravaDespesas } )

		//Bens em Garantia / Penhora
		aHeader					:= 	{}
		aCols					:= 	{}
		aMemosGravaBens			:=	{}
		n						:= 1

		@ aObjPFSize[1,1],aObjPFSize[1,2] GROUP oGroupBens TO aObjPFSize[1,3],aObjPFSize[1,4] LABEL OemtoAnsi(STR0052)	OF oDlgMain PIXEL 	// " Bem para Garantia e/ou Penhora "
		oGetBens 	:= MSNewGetDados():New(	aObjFlSize[1,1],	;	//nTop
											aObjFlSize[1,2],	;	//nLeft
											aObjFlSize[1,3],	;	//nBottom
											aObjFlSize[1,4],	;	//nRight
											nOpcNewGd,				;
											"AptBensOk",			;
											"AllwaysTrue",			;
											"",						;
											NIL,					;
											NIL,					;
											9999,					;
											NIL,					;
											NIL,					;
											NIL,					;
											oDlgMain,				;
											aBens[2],				;
											aBens[3]				;
											)
		oGetBens:oBrowse:Default()
		aAdd ( aMemosGravaBens , { aMemosBens } )
		aAdd ( aObjects , { oGetBens , "REG", aBens[1] , aMemosGravaBens } )


   		bObjHide := { ||;
   							oGroupPleitos:Hide(),;
   							oGetPleitos:Hide(),;
   							oGetPleitos:oBrowse:Hide(),;
							oGroupPericias:Hide(),;
							oGetPericias:Hide(),;
							oGetPericias:oBrowse:Hide(),;
   							oGroupAdvogados:Hide(),;
   							oGetAdvogados:Hide(),;
   							oGetAdvogados:oBrowse:Hide(),;
							oGroupAudiencias:Hide(),;
							oGetAudiencias:Hide(),;
							oGetAudiencias:oBrowse:Hide(),;
							oGroupTestemunhas:Hide(),;
							oGetTestemunhas:Hide(),;
							oGetTestemunhas:oBrowse:Hide(),;
							oGroupOcorrencias:Hide(),;
							oGetOcorrencias:Hide(),;
							oGetOcorrencias:oBrowse:Hide(),;
							oGroupSentencas:Hide(),;
							oGetSentencas:Hide(),;
							oGetSentencas:oBrowse:Hide(),;
							oGroupRescCompl:Hide(),;
							oGetRescCompl:Hide(),;
							oGetRescCompl:oBrowse:Hide(),;
							oGroupRecursos:Hide(),;
							oGetRecursos:Hide(),;
							oGetRecursos:oBrowse:Hide(),;
							oGroupDespesas:Hide(),;
							oGetDespesas:Hide(),;
							oGetDespesas:oBrowse:Hide(),;
							oGroupBens:Hide(),;
							oGetBens:Hide(),;
							oGetBens:oBrowse:Hide(),;
							oSay1:Hide(),;
							oGetProcesso:Hide(),;
   		            }
		Eval( bObjHide )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada para inclusao de botoes na TOOBAR.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("Apt100BT")
			aButton100:=ExecBlock("Apt100BT",.F.,.F.)
			If Valtype(aButton100) == "A"  //Garante que tenha o icone do botao e a função a ser executada
				aButtons := Aclone(aButton100)
			EndIf
		EndIf

ACTIVATE MSDIALOG oDlgMain ON INIT (	oAux := oEnchoice										,;
										EnchoiceBar (	oDlgMain																				,;
														{|| If( APT100TudOk(nOpcx) .AND. APT100Vld(nOpcx),	( nOpca := 1, oDlgMain:End() ),	) }	,;
														{|| nOpca := 2, oDlgMain:End() }														,;
														NIL 																					,;
														aButtons )								,;
										oTree:bChange := {|| APT100Principal( oTree, oDlgMain )},;
										Eval ( oGetSentencas:bChange	)						,;	// em testes, para ver se é necessária esta linha.
										Eval ( oGetAudiencias:bChange	)						,;
										Eval ( oGetPleitos:bChange		)						;	// ajuste provisorio
									)

If nOpca == 1
	If nOpcx # 5 .And. nOpcx # 2	// Se nao for Exclusao e visualiz.
		Begin Transaction
			If __lSX8 .And. nOpcx == 3
				While ( GetSX8Len() > nLenSX8 )
					ConfirmSx8()
				EndDo
			EndIf
			APT100Grava ( nOpcx , aObjects )
			EvalTrigger()
		End Transaction
	ElseIf nOpcx = 5
		Begin Transaction
			APT100Dele()
		End Transaction
	EndIf
Else
	If __lSX8
		While ( GetSX8Len() > nLenSX8 )
			RollBackSX8()
		EndDo
	EndIf
EndIf

Release Object oTree

dbSelectArea(cAlias)
dbGoto(nReg)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³APT100Monta³ Autor ³ Tania Bronzeri 		³ Data ³19/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta as getdados dos arquivos                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias 	: Alias                                           ³±±
±±³          ³ nReg 	: Registro                                        ³±±
±±³          ³ nOpcx 	: Opcao                                           ³±±
±±³          ³ nOrder 	: Ordem do Arquivo                                ³±±
±±³          ³ aCond 	: Condicao                                        ³±±
±±³          ³ aFields 	: Campos nao utilizados                           ³±±
±±³          ³ cAliasPai: Alias da Tabela Pai                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APTA100       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function APT100Monta(cAlias, nReg, nOpcx, nOrder, aCond, aFields, cAliasPai, lAllField, a100NotFields,cKey)

Local a100Header		:= {}
Local a100Cols			:= {}
Local a100VirtGd		:= {}
Local a100VisuGd		:= {}
Local a100Recnos		:= {} 	//--Array que contem o Recno() dos registros da aCols
Local a100Query			:= {}
Local a100Keys			:= {}
Local n100Usado 		:= 0
Local cKSeekFather		:= "" 	// Chave da tabela Processos / Audiencias / Pleitos / Sentencas
Local n100MaxLocks		:= 10
Local lLock 			:= .F.
Local lExclu			:= .F.
Local a100Retorno		:= {}
Local nCount			:= 0
Local nI                := 0
Default lAllField		:= .F.
Default a100NotFields	:= {}
Default cKey			:= ""	// Chave para o filho

If Len(aCond)>0
	For nCount := 1 to Len (aCond)
		cKSeekFather	:= cKSeekFather + aCond[nCount] 	// Chave da tabela Processos
	Next nCount
EndIf

// Monta o aCols
(cAlias)->(DbSetOrder(nOrder))
a100Cols := GDMontaCols(	@a100Header		,;	//01 -> Array com os Campos do Cabecalho da GetDados
							@n100Usado		,;	//02 -> Numero de Campos em Uso
							@a100VirtGd		,;	//03 -> [@]Array com os Campos Virtuais
							@a100VisuGd		,;	//04 -> [@]Array com os Campos Visuais
							cAlias			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
							@a100NotFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
							@a100Recnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
							cAliasPai	   	,;	//08 -> Alias do Arquivo Pai
							cKSeekFather	,;	//09 -> Chave para o Posicionamento no Alias Filho
							NIL				,;	//10 -> Bloco para condicao de Loop While
							NIL				,;	//11 -> Bloco para Skip no Loop While
							NIL				,;	//12 -> Se Havera o Elemento de Delecao no aCols
							NIL				,;	//13 -> Se cria variaveis Publicas
							NIL				,;	//14 -> Se Sera considerado o Inicializador Padrao
							NIL				,;	//15 -> Lado para o inicializador padrao
							lAllField		,;	//16 -> Opcional, Carregar Todos os Campos
							NIL				,;	//17 -> Opcional, Nao Carregar os Campos Virtuais
							a100Query		,;	//18 -> Opcional, Utilizacao de Query para Selecao de Dados
							.F.				,;	//19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
							.F.				,;	//20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
							.T.				,;	//21 -> Carregar Coluna Fantasma
							NIL				,;	//22 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
							NIL				,;	//23 -> Verifica se Deve verificar se o campo eh usado
							NIL				,;	//24 -> Verifica se Deve verificar o nivel do usuario
							NIL				,;	//25 -> Verifica se Deve Carregar o Elemento Vazio no aCols
							@a100Keys  		,;	//26 -> [@]Array que contera as chaves conforme recnos
							@lLock			,;	//27 -> [@]Se devera efetuar o Lock dos Registros
							@lExclu			,;	//28 -> [@]Se devera obter a Exclusividade nas chaves dos registros
							n100MaxLocks	,;	//29 -> Numero maximo de Locks a ser efetuado
							NIL				,;	//30
							NIL				,;	//31
							nOpcx			 ;	//32
                       )

//Tratamento para evitar erro de campo obrigatorio
For nI := 1 To Len(a100Header)
	a100Header[nI][17] := .F.
Next nI

a100Retorno := { a100Recnos , a100Header, a100Cols }

Return( aClone( a100Retorno ) )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AptPleitosOk ³ Autor ³ Tania Bronzeri  	   ³ Data ³19/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a linha da getdados Pleito                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³APTA100                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AptPleitosOk(nOP)
Local nPosCod 	:= GdFieldPos("REL_CODPLT"	,oGetPleitos:aHeader)
Local nPosRecl	:= GdFieldPos("REL_RECLAM"	,oGetPleitos:aHeader)
Local nPosRecNo	:= GdFieldPos("REL_RECNOM"	,oGetPleitos:aHeader)
Local nPosFunAs	:= GdFieldPos("REL_FUNASS"	,oGetPleitos:aHeader)
Local nPosDesli	:= GdFieldPos("REL_DESLIG"	,oGetPleitos:aHeader)
Local nPosCc	:= GdFieldPos("REL_CC"		,oGetPleitos:aHeader)
Local nPosTpPlt	:= GdFieldPos("REL_TPPLT"	,oGetPleitos:aHeader)
Local aExcecao	:=	{}
Local nx		:= 0
Local aColsPleitos := oGetPleitos:aCols
aAdd(aExcecao,nPosRecl)	//Monta array para as excecoes de linha vazia
aAdd(aExcecao,nPosCc)	//Monta array para as excecoes de linha vazia

DEFAULT nOp := 0

Eval(oGetPericias:oBrowse:bLostFocus)

IF nOpcao # 5 .And. nOpcao # 2
	IF Empty(aColsPleitos[n][nPosRecl]) .And. M->RE0_TPACAO == "1" .And. nOP == 1
		aColsPleitos[n][nPosRecl] 	:= M->RE0_RECLAM
		aColsPleitos[n][nPosRecNo]	:= RelRecNomRel()
		aColsPleitos[n][nPosFunas] 	:= RelFunAssRel()
		aColsPleitos[n][nPosDesli] 	:= RelDesligRel()
		aColsPleitos[n][nPosCC] 	:= RelCCRel()
		// oGetPleitos:refresh()
	EndIf



	If !aColsPleitos[n,Len(aColsPleitos[n])]      // Se nao esta Deletado
		IF APT100LinhaVazia ( oGetPleitos:aHeader , oGetPleitos:aCols , aExcecao )	//Se linha inteira esta em branco, exceto reclamante
			PutFileInEof("REL")
			Return .T.
		EndIf

		IF (nPosCod > 0 .And. Empty(aColsPleitos[n][nPosCod])) .And. ;
			!(APT100Linha(oGetPleitos:aHeader,aColsPleitos))
				IF !Empty(aColsPleitos[n][nPosRecl])
					aColsPleitos[n][nPosRecl] := ""
				EndIF

				IF (nPosCod > 0 .And. Empty(aColsPleitos[n][nPosCod])) .And. ;
					!(APTGetLinha(oGetPleitos:aHeader,aColsPleitos))
						Aviso( STR0033, STR0034, { "OK" } )	  // "Atencao!"###"Pleito deve ser preenchido."
						Return .F.
				EndIF
		EndIf
		IF (nPosCod > 0 .And. nPosTpPlt > 0 .And. Empty(aColsPleitos[n][nPosTpPlt])) .And. ;
			!(APTGetLinha(oGetPleitos:aHeader,aColsPleitos))
//				Aviso( STR0033, STR0076, { "OK" } )	  // "Atencao!"###"Tipo do Pleito Invalido. Informe Tipo valido."
				Return .F.
		EndIF

		For nx:=1 To Len(aColsPleitos)
			If !Empty(aColsPleitos[n][nPosCod]) .And. ;
				aColsPleitos[n][nPosCod] == aColsPLeitos[nx][nPosCod] .And.;
				!aColsPleitos[nx][Len(aColsPleitos[nx])] .And.	n # nx
					Aviso( STR0033, STR0034, { "OK" } )		// "Atencao!"###"Pleito ja cadastrado."
					Return .F.
					Exit
			EndIf
		Next nx
	EndIf
EndIf

PutFileInEof("REL")

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AptPericiasOK 	³ Autor ³ Tania Bronzeri  		³ Data ³20/09/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a linha da getdados Pericias	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³APTA100                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AptPericiasOK()
Local nPosPleito 	:= GdFieldPos("REL_CODPLT"	,oGetPleitos:aHeader)
Local nPosPericias	:= GdFieldPos("REH_DTPERI"	,oGetPericias:aHeader)
Local nPosTipo		:= GdFieldPos("REH_TIPO"	,oGetPericias:aHeader)
Local nPosNProce	:= GdFieldPos("REH_PRONUM"	,oGetPericias:aHeader)
Local nPosCodPl		:= GdFieldPos("REH_CODPLT"	,oGetPericias:aHeader)
Local nx			:= 0
Local aColsPericias	:=	oGetPericias:aCols
Local aArea			:=	GetArea()
Local aExcecao		:= {nPosNProce, nPosCodPl}

If nOpcao # 5 .And. nOpcao # 2
	If !aColsPericias[n,Len(aColsPericias[n])]      // Se nao esta Deletado
		If APT100LinhaVazia ( oGetPericias:aHeader , oGetPericias:aCols, aExcecao )	//Se linha inteira esta em branco
			PutFileInEof("REH")
			Return .T.
		EndIf
		If 	cEstou == "2" 			.AND. ;
			nPosPleito 	> 0 		.AND. ;
			(nPosPericias 	> 0 	.AND. Empty(aColsPericias[n][nPosPericias])	.OR. ;
			nPosTipo		> 0		.AND. Empty(aColsPericias[n][nPosTipo]) )	.AND. ;
			!(APTGetLinha(oGetPericias:aHeader,aColsPericias))
				Aviso( STR0033, STR0036, { "OK" } )		//	"Atencao"###"Verifique os campos Cod.Pleito, Data e Tipo da Pericia."
				Return .F.
		EndIf

		For nx:=1 To Len(aColsPericias)
			If 	(!Empty(aColsPericias[n][nPosPericias]) .And. ;
				aColsPericias[n][nPosPericias] == aColsPericias[nx][nPosPericias]) .And.;
				(!Empty(aColsPericias[n][nPosTipo]) .And. ;
				aColsPericias[n][nPosTipo] == aColsPericias[nx][nPosTipo] .And.;
				!aColsPericias[nx][Len(aColsPericias[nx])]) .And. n # nx
					Aviso( STR0033, STR0037, { "OK" } )		// "Atencao!"###"Pericia ja existe."
					Return .F.
					Exit
			EndIf
		Next nx
	Else
		dbSelectArea("REH")
		dbSetOrder(1)
		If dbSeek(xFilial("REH")+cNumProc)
			While !Eof() .And. REH->REH_FILIAL+REH->REH_PRONUM == ;
								 xFilial("REH")+cNumProc
				RecLock("REH",.F.)
				dbDelete()
				MsUnlock()
				dbSkip()
			EndDo
		EndIf
		RestArea(aArea)
	EndIf
EndIf
PutFileInEof("REH")
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AptAdvogadosOk   ³ Autor ³ Tania Bronzeri        ³ Data ³01/07/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a linha da getdados Advogado                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³APTA100                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AptAdvogadosOk()
Local nPosAdvogado 		:= GdFieldPos("RE4_CODADV",oGetAdvogados:aHeader)
Local nx				:= 0
Local aColsAdvogados	:=	oGetAdvogados:aCols

If nOpcao # 5 .And. nOpcao # 2
	If !aColsAdvogados[n,Len(aColsAdvogados[n])]      // Se nao esta Deletado
		If APT100LinhaVazia ( oGetAdvogados:aHeader , oGetAdvogados:aCols )	//Se linha inteira esta em branco
			PutFileInEof("RE4")
			Return .T.
		EndIf
		If ((nPosAdvogado > 0 .And. Empty(aColsAdvogados[n][nPosAdvogado])) )	.And. ;
			!(APTGetLinha(oGetAdvogados:aHeader,aColsAdvogados))
				Aviso(STR0033, STR0038, { "OK" } )	  // "Atencao!"###"Codigo do Advogado deve ser preenchido corretamente."
				Return .F.
		EndIf
		For nx:=1 To Len(aColsAdvogados)
			If !Empty(aColsAdvogados[n][nPosAdvogado]) .And. ;
				aColsAdvogados[n][nPosAdvogado] == aColsAdvogados[nx][nPosAdvogado] .And.;
				!aColsAdvogados[nx][Len(aColsAdvogados[nx])] .And. n # nx
					Aviso( STR0033, STR0039, { "OK" } )		// "Atencao!"###"Advogado ja cadastrado."
					Return .F.
					Exit
			EndIf
		Next nx
	EndIf
EndIf
PutFileInEof("RE4")
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AptAudienciasOK   ³ Autor ³ Tania Bronzeri  		³ Data ³20/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a linha da getdados Audiencia                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³APTA100                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AptAudienciasOK()
Local nPosAudiencia 	:= GdFieldPos("REA_DATA"  ,oGetAudiencias:aHeader)
Local nPosFaseAudi		:= GdFieldPos("REA_FASECD",oGetAudiencias:aHeader)
Local nPosTpAudi		:= GdFieldPos("REA_TIPO"  ,oGetAudiencias:aHeader)
Local nx				:= 0
Local aColsAudiencias	:=	oGetAudiencias:aCols

Eval(oGetTestemunhas:oBrowse:bLostFocus)

If nOpcao # 5 .And. nOpcao # 2
	If !aColsAudiencias[n,Len(aColsAudiencias[n])]      // Se nao esta Deletado
		If APT100LinhaVazia ( oGetAudiencias:aHeader , oGetAudiencias:aCols )	//Se linha inteira esta em branco
			PutFileInEof("REA")
			Return .T.
		EndIf
		If ((nPosAudiencia > 0 .And. nPosTpAudi > 0 .And. Empty(aColsAudiencias[n][nPosTpAudi]))) ;
			.And. !(APTGetLinha(oGetAudiencias:aHeader,aColsAudiencias))
				Aviso(STR0033, STR0040, {"OK"} )	  // "Atencao!"###"Verifique os campos Data e Tipo de Audiencia."
				Return .F.
		EndIf
		If ((nPosAudiencia > 0 .And. Empty(aColsAudiencias[n][nPosAudiencia]))) ;
			.And. !(APTGetLinha(oGetAudiencias:aHeader,aColsAudiencias))
				Aviso(STR0033, STR0040, {"OK"} )	  // "Atencao!"###"Verifique os campos Data e Tipo de Audiencia."
				Return .F.
		EndIf

		For nx:=1 To Len(aColsAudiencias)
			If !Empty(aColsAudiencias[n][nPosAudiencia]) .And. ;
				aColsAudiencias[n][nPosAudiencia] == aColsAudiencias[nx][nPosAudiencia] .And.;
				!aColsAudiencias[nx][Len(aColsAudiencias[nx])] .And. n # nx
					Aviso(STR0033, STR0041, {"OK"} )	// "Atencao!"###"Audiencia ja cadastrada."
					Return .F.
					Exit
			Else
				aAdd( aFase, { aColsAudiencias[nx][nPosAudiencia], aColsAudiencias[nx][nPosFaseAudi] } )
			EndIf
		Next nx
	EndIf
EndIf
PutFileInEof("REA")
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AptTestemunhasOK  ³ Autor ³ Tania Bronzeri  		³ Data ³31/08/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a linha da getdados Testemunhas                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³APTA100                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AptTestemunhasOK()
Local nPosAudiencia 	:= GdFieldPos("REA_DATA"	,oGetAudiencias:aHeader)
Local nPosTestemunhas	:= GdFieldPos("RE9_TESCOD"	,oGetTestemunhas:aHeader)
Local nx				:= 0
Local aColsTestemunhas	:=	oGetTestemunhas:aCols

If nOpcao # 5 .And. nOpcao # 2
	If !aColsTestemunhas[n,Len(aColsTestemunhas[n])]      // Se nao esta Deletado
		If APT100LinhaVazia ( oGetTestemunhas:aHeader , oGetTestemunhas:aCols )	//Se linha inteira esta em branco
			PutFileInEof("RE9")
			Return .T.
		EndIf
		If 	((nPosAudiencia 	> 0 ))	.AND. ;
			((nPosTestemunhas 	> 0 .And. Empty(aColsTestemunhas[n][nPosTestemunhas])))	.AND. ;
			!(APTGetLinha(oGetTestemunhas:aHeader,aColsTestemunhas))
				Aviso(STR0033, STR0042, { "OK" } ) // "Atencao!"###"Verifique os campos Data da Audiencia e Cod. Testemunha."
				Return .F.
		EndIf

		For nx:=1 To Len(aColsTestemunhas)
			If 	aColsTestemunhas[n][nPosTestemunhas	] == aColsTestemunhas[nx][nPosTestemunhas	] .And.;
				!aColsTestemunhas[nx][Len(aColsTestemunhas[nx])] .And. n # nx
					Aviso(STR0033, STR0043, {"OK"} )	// "Atencao!"###"Testemunha ja cadastrada."
					Return .F.
					Exit
			EndIf
		Next nx
	EndIf
EndIf
PutFileInEof("RE9")
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AptOcorrenciasOk ³ Autor ³ Tania Bronzeri        ³ Data ³20/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a linha da getdados Ocorrencia                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³APTA100                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AptOcorrenciasOk()
Local nPosDataOcor		:= 	GdFieldPos("REO_DATA"  ,oGetOcorrencias:aHeader)
Local nPosTipoOcor		:= 	GdFieldPos("REO_TIPO"  ,oGetOcorrencias:aHeader)
Local nPosFase			:= 	GdFieldPos("REO_FASECD",oGetOcorrencias:aHeader)
Local nx				:= 	0
Local aColsOcorrencias	:=	oGetOcorrencias:aCols
Local aExcecao			:=	{}
aAdd(aExcecao,nPosFase)	//Monta excecao para linhavazia

If nOpcao # 5 .And. nOpcao # 2
   	If !aColsOcorrencias[n,Len(aColsOcorrencias[n])]      // Se nao esta Deletado
		If APT100LinhaVazia ( oGetOcorrencias:aHeader , oGetOcorrencias:aCols , aExcecao)	//Se linha inteira esta em branco
			PutFileInEof("REO")
			Return .T.
		EndIf
		If ((nPosDataOcor > 0 .And. Empty(aColsOcorrencias[n][nPosDataOcor]))  .Or.  ;
			(nPosTipoOcor > 0 .And. Empty(aColsOcorrencias[n][nPosTipoOcor]))) .And. ;
			!(APTGetLinha(oGetOcorrencias:aHeader,aColsOcorrencias))
				Aviso(STR0033, STR0044, {"OK"} )	 // "Atencao!"###"Verifique os campos Data e Tipo da Ocorrencia."
			Return .F.
		EndIf

		For nx:=1 To Len(aColsOcorrencias)
			If !Empty(aColsOcorrencias[n][nPosDataOcor]) .And. !Empty(aColsOcorrencias[n][nPosTipoOcor]) .And.;
				aColsOcorrencias[n][nPosDataOcor] == aColsOcorrencias[nx][nPosDataOcor] .And.;
				aColsOcorrencias[n][nPosTipoOcor] == aColsOcorrencias[nx][nPosTipoOcor] .And.;
				!aColsOcorrencias[nx][Len(aColsOcorrencias[nx])] .And.;
				n # nx
				Aviso(STR0033, STR0045, {"OK"} )	// "Atencao!"##$#"Ocorrencia ja cadastrada."
				Return .F.
				Exit
			Else
				aAdd( aFase, { aColsOcorrencias[nx][nPosDataOcor], aColsOcorrencias[nx][nPosFase] } )
			EndIf
		Next nx
   	EndIf
EndIf
PutFileInEof("REO")
RE4->( dbSetOrder(1) )
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AptSentencasOK    ³ Autor ³ Tania Bronzeri  		³ Data ³20/08/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a linha da getdados Sentenca                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³APTA100                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AptSentencasOK()
Local nPosSentenca 		:= GdFieldPos("RES_JULGAM",oGetSentencas:aHeader)
Local nPosFaseSent		:= GdFieldPos("RES_FASECD",oGetSentencas:aHeader)
Local nPosTipoSent 	 	:= GdFieldPos("RES_TIPO"  ,oGetSentencas:aHeader)
Local nx				:= 0
Local aColsSentencas	:=	oGetSentencas:aCols

Eval(oGetRescCompl:oBrowse:bLostFocus)

If nOpcao # 5 .And. nOpcao # 2
	If !aColsSentencas[n,Len(aColsSentencas[n])]      // Se nao esta Deletado
		If APT100LinhaVazia ( oGetSentencas:aHeader , oGetSentencas:aCols )	//Se linha inteira esta em branco
			PutFileInEof("RES")
			Return .T.
		EndIf
		If ((nPosSentencas > 0 .And. Empty(aColsSentencas[n][nPosSentenca]))	.Or.  ;
			(nPosTipoSent  > 0 .And. Empty(aColsSentencas[n][nPosTipoSent])))	.And. ;
			!(APTGetLinha(oGetSentencas:aHeader,aColsSentencas))
 				Aviso(STR0033, STR0062, {"OK"} )	  // "Atencao!"###"Ha informacoes na Sentenca sem o preenchimento dos campos Data de Julgamento e/ou Tipo da Sentenca. Ambos sao de preenchimento obrigatorio."
				Return .F.
		EndIf

		For nx:=1 To Len(aColsSentencas)
			If !Empty(aColsSentencas[n][nPosSentenca]) .And. ;
				aColsSentencas[n][nPosSentenca] == aColsSentencas[nx][nPosSentenca] .And.;
				!aColsSentencas[nx][Len(aColsSentencas[nx])] .And. n # nx
					Aviso(STR0033, STR0047, {"OK"} )	// "Atencao!"###"Sentenca ja cadastrada."
					Return .F.
					Exit
			Else
				aAdd( aFase, { aColsSentencas[nx][nPosSentenca], aColsSentencas[nx][nPosFaseSent] } )
			EndIf
		Next nx
	EndIf
EndIf
PutFileInEof("RES")
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AptRescComplOK    ³ Autor ³ Tania Bronzeri  		³ Data ³13/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a linha da getdados Rescisao Complementar                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³APTA100                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AptRescComplOK()
Local nPosRescCompl		:= GdFieldPos("REP_MAT"		,oGetRescCompl:aHeader)
Local nPosVerba			:= GdFieldPos("REP_PD"		,oGetRescCompl:aHeader)
Local nPosPeriod		:= GdFieldPos("REP_PERIOD"	,oGetRescCompl:aHeader)
Local nPosDtLcto		:= GdFieldPos("REP_DTLCTO"	,oGetRescCompl:aHeader)
Local nPosCc			:= GdFieldPos("REP_CC"		,oGetRescCompl:aHeader)
Local nx				:= 0
Local aColsRescCompl	:=	oGetRescCompl:aCols
Local aExcecao			:=	{}
aAdd(aExcecao,nPosDtLcto)		//Monta array para excecao de linhavazia
aAdd(aExcecao,nPosRescCompl)	//Monta array para excecao de linhavazia

If nOpcao # 5 .And. nOpcao # 2
	If !aColsRescCompl[n,Len(aColsRescCompl[n])]      // Se nao esta Deletado
		If APT100LinhaVazia ( oGetRescCompl:aHeader , oGetRescCompl:aCols , aExcecao)	//Se linha inteira esta em branco, exceto data do lancamento
			PutFileInEof("REP")
			Return .T.
		EndIf
		For nx:=1 To Len(aColsRescCompl)
			If 	aColsRescCompl[n][nPosRescCompl	] == aColsRescCompl[nx][nPosRescCompl	] 	.And.;
				aColsRescCompl[n][nPosPeriod] 	  == aColsRescCompl[nx][nPosPeriod] 		.And.	;
				aColsRescCompl[n][nPosVerba]	  == aColsRescCompl[nx][nPosVerba]			.And.	;
				aColsRescCompl[n][nPosCc]		  == aColsRescCompl[nx][nPosCc]				.And.	;
				!aColsRescCompl[nx][Len(aColsRescCompl[nx])] 								.And.  n # nx
					Aviso(STR0033, STR0057, {"OK"} )	// "Atencao!"###"Lancamento ja Cadastrado."
					Return .F.
					Exit
			EndIf
		Next nx
	EndIf
EndIf
PutFileInEof("REP")
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AptRecursosOk    ³ Autor ³ Tania Bronzeri        ³ Data ³13/09/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a linha da getdados Recursos                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³APTA100                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AptRecursosOk()
Local nPosDataRecurso	:= 	GdFieldPos("REM_DATA"  ,oGetRecursos:aHeader)
Local nPosTipoRecurso	:= 	GdFieldPos("REM_TIPO"  ,oGetRecursos:aHeader)
Local nPosFaseRecurso	:=	GdFieldPos("REM_FASECD",oGetRecursos:aHeader)
Local nx				:= 	0
Local aColsRecursos		:=	oGetRecursos:aCols

If nOpcao # 5 .And. nOpcao # 2
	If !aColsRecursos[n,Len(aColsRecursos[n])]      // Se nao esta Deletado
		If APT100LinhaVazia ( oGetRecursos:aHeader , oGetRecursos:aCols )	//Se linha inteira esta em branco
			PutFileInEof("REM")
			Return .T.
		EndIf
		If 	(nPosDataRecurso > 0 .And. Empty(aColsRecursos[n][nPosDataRecurso])) .And. ;
			(nPosTipoRecurso > 0 .And. Empty(aColsRecursos[n][nPosTipoRecurso])).And. ;
			!(APTGetLinha(oGetRecursos:aHeader,aColsRecursos))
				Aviso(STR0033, STR0048, {"OK"} ) // "Atencao!"###"Verifique os campos Data e Tipo do Recurso."
				Return .F.
		EndIf

		For nx:=1 To Len(aColsRecursos)
			If 	!Empty(aColsRecursos[n][nPosDataRecurso]) .And. !Empty(aColsRecursos[n][nPosTipoRecurso]) .And. ;
				aColsRecursos[n][nPosDataRecurso] == aColsRecursos[nx][nPosDataRecurso] .And.;
				aColsRecursos[n][nPosTipoRecurso] == aColsRecursos[nx][nPosTipoRecurso] .And.;
				!aColsRecursos[nx][Len(aColsRecursos[nx])] .And.;
				n # nx
					Aviso(STR0033, STR0049, {"OK"} )// "Atencao!"###"Recurso ja cadastrado."
					Return .F.
					Exit
			Else
				aAdd( aFase, { aColsRecursos[nx][nPosDataRecurso], aColsRecursos[nx][nPosFaseRecurso] } )
			EndIf
		Next nx
	EndIf
EndIf
PutFileInEof("REM")
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³AptDespTdOk      ³ Autor ³ Marcelo Silveira      ³ Data ³15/08/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Valida todas as linhas da getdados Despesas                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³APTA100                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AptDespTdOk()

Local lRet		:= .T.
Local nRegs 	:= 0
Local nX		:= 0
Local nSave		:= n
Local aColsDesp	:= oGetDespesas:aCols

nRegs := Len(aColsDesp)

If Len(aColsDesp) > 0

	For nX := 1 To nRegs
		If !aColsDesp[nX,Len(aColsDesp[nX])] // Se nao esta Deletado
			n := nX
			lRet := AptDespesasOk()
			If !lRet
				Exit
			EndIf
		EndIf
	Next nX

EndIf

n := nSave

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³AptDespesasOk    ³ Autor ³ Tania Bronzeri        ³ Data ³21/10/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Valida a linha da getdados Despesas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³APTA100                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AptDespesasOk()
Local nPosPrefixo		:= 	GdFieldPos("RC1_PREFIX"	,oGetDespesas:aHeader)
Local nPosNumTitulo		:=	GdFieldPos("RC1_NUMTIT"	,oGetDespesas:aHeader)
Local nPosParcDespesa	:= 	GdFieldPos("RC1_PARC"	,oGetDespesas:aHeader)
Local nPosValor			:= 	GdFieldPos("RC1_VALOR"	,oGetDespesas:aHeader)
Local nPosEmissao		:=	GdFieldPos("RC1_EMISSA" ,oGetDespesas:aHeader)
Local nPosVencimento	:=	GdFieldPos("RC1_VENCTO" ,oGetDespesas:aHeader)
Local nPosVencReal		:=	GdFieldPos("RC1_VENREA" ,oGetDespesas:aHeader)
Local nPosTipoTitulo	:=	GdFieldPos("RC1_TIPO"	,oGetDespesas:aHeader)
Local nPosNatureza		:=	GdFieldPos("RC1_NATURE" ,oGetDespesas:aHeader)
Local nPosTipoDesp		:=	GdFieldPos("RC1_TPDESP" ,oGetDespesas:aHeader)
Local nPosFornec		:=	GdFieldPos("RC1_FORNEC"	,oGetDespesas:aHeader)
Local nPosLoja			:=	GdFieldPos("RC1_LOJA"	,oGetDespesas:aHeader)
Local nPosIntegr        :=	GdFieldPos("RC1_INTEGR" ,oGetDespesas:aHeader)
Local nx				:= 	0
Local aColsDespesas		:=	oGetDespesas:aCols
Local aExcecao			:=	{}

aAdd(aExcecao,nPosNumTitulo)
aAdd(aExcecao,nPosIntegr)//Monta array para as excecoes de linha vazia

IF nOpcao # 5 .And. nOpcao # 2
	IF !aColsDespesas[n,Len(aColsDespesas[n])]      // Se nao esta Deletado
		IF APT100LinhaVazia ( oGetDespesas:aHeader , oGetDespesas:aCols , aExcecao )	//Se linha inteira esta em branco
			PutFileInEof("RC1")
			Return .T.
		EndIF
		IF 	(nPosPrefixo 	 > 0 .And. Empty(aColsDespesas[n][nPosPrefixo]))		.And. ;
			(nPosNumTitulo	 > 0 .And. Empty(aColsDespesas[n][nPosNumTitulo])) 	.And. ;
			(nPosParcDespesa > 0 .And. Empty(aColsDespesas[n][nPosParcDespesa])) 	.And. ;
			!(APTGetLinha(oGetDespesas:aHeader,aColsDespesas))
				Aviso(STR0033, STR0050, {"OK"} )	 // "Atencao!"###"Verifique os campos referentes a Despesa."
				Return .F.
		EndIF
		IF Empty(aColsDespesas[n][nPosPrefixo])
			Aviso(STR0033, STR0065, {"OK"} )	 // "Atencao!"###"Informe o Campo Prefixo do Titulo."
			Return .F.
		EndIF
		IF Empty(aColsDespesas[n][nPosNumTitulo])
			Aviso(STR0033, STR0066, {"OK"} )	 // "Atencao!"###"Informe o Campo Numero do Titulo."
			Return .F.
		EndIF
		IF !(aColsDespesas[n][nPosValor] > 0)
			Aviso(STR0033, STR0067, {"OK"} )	 // "Atencao!"###"Informe Valor valido para o Titulo."
			Return .F.
		EndIF
		IF Empty(aColsDespesas[n][nPosEmissao])
			Aviso(STR0033, STR0068, {"OK"} )	 // "Atencao!"###"Informe Data de Emissao valida para o Titulo."
			Return .F.
		EndIF
		IF Empty(aColsDespesas[n][nPosVencimento])
			Aviso(STR0033, STR0069, {"OK"} )	 // "Atencao!"###"Informe Data de Vencimento valida para o Titulo."
			Return .F.
		EndIF
		IF Empty(aColsDespesas[n][nPosVencReal])
			Aviso(STR0033, STR0070, {"OK"} )	 // "Atencao!"###"Informe Data de Vencimento Real valida para o Titulo."
			Return .F.
		EndIF
		IF Empty(aColsDespesas[n][nPosTipoTitulo])
			Aviso(STR0033, STR0071, {"OK"} )	 // "Atencao!"###"Informe Tipo do Titulo valido."
			Return .F.
		EndIF
		IF Empty(aColsDespesas[n][nPosNatureza])
			Aviso(STR0033, STR0072, {"OK"} )	 // "Atencao!"###"Informe Codigo de Natureza valida para o Titulo."
			Return .F.
		EndIF
		IF Empty(aColsDespesas[n][nPosTipoDesp])
			Aviso(STR0033, STR0073, {"OK"} )	 // "Atencao!"###"Informe Tipo de Despesa valida para o Titulo."
			Return .F.
		EndIF
		IF Empty(aColsDespesas[n][nPosFornec])
			Aviso(STR0033, STR0074, {"OK"} )	 // "Atencao!"###"Codigo do Fornecedor/Loja Invalido ou Nao Informado. Informe codigo valido."
			Return .F.
		ElseIF !(SA2->(DbSeek(xFilial("SA2")+aColsDespesas[n][nPosFornec])))
			Aviso( STR0033, STR0074, { "OK" } )		// "Atencao!"###"Codigo do Fornecedor/Loja Invalido ou Nao Informado. Informe codigo valido."
			Return .F.
		EndIF
		IF Empty(aColsDespesas[n][nPosLoja])
			Aviso(STR0033, STR0074, {"OK"} )	 // "Atencao!"###"Codigo do Fornecedor/Loja Invalido ou Nao Informado. Informe codigo valido."
			Return .F.
		ElseIF !(SA2->(DbSeek(xFilial("SA2")+aColsDespesas[n][nPosFornec]+aColsDespesas[n][nPosLoja])))
			Aviso( STR0033, STR0074, { "OK" } )		// "Atencao!"###"Codigo do Fornecedor/Loja Invalido ou Nao Informado. Informe codigo valido."
			Return .F.
		EndIF
		For nx:=1 To Len(aColsDespesas)
			If 	AllTrim(aColsDespesas[n][nPosPrefixo])		== AllTrim(aColsDespesas[nx][nPosPrefixo])		.And.;
				AllTrim(aColsDespesas[n][nPosNumTitulo]) 	== AllTrim(aColsDespesas[nx][nPosNumTitulo]) 	.And.;
				AllTrim(aColsDespesas[n][nPosParcDespesa]) 	== AllTrim(aColsDespesas[nx][nPosParcDespesa])	.And.;
				!aColsDespesas[nx][Len(aColsDespesas[nx])] .And.;
				n # nx
					Aviso(STR0033, STR0051, {"OK"} )	// "Atencao!"###"Despesa ja cadastrada."
					Return .F.
					Exit
			EndIf
		Next nx
	EndIf
EndIf
PutFileInEof("RC1")
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AptBensOk			³ Autor ³ Tania Bronzeri        ³ Data ³13/01/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a linha da getdados Bens para Garantia e/ou Penhora          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³APTA100                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AptBensOk()
Local nPosCodigoBem	:= 	GdFieldPos("REG_CODIGO"	,oGetBens:aHeader)
Local nPosItemBem	:= 	GdFieldPos("REG_ITEM"	,oGetBens:aHeader)
Local nx			:= 	0
Local aColsBens		:=	oGetBens:aCols

If nOpcao # 5 .And. nOpcao # 2
	If !aColsBens[n,Len(aColsBens[n])]      // Se nao esta Deletado
		If APT100LinhaVazia ( oGetBens:aHeader , oGetBens:aCols )	//Se linha inteira esta em branco
			PutFileInEof("REG")
			Return .T.
		EndIf
		If (nPosCodigoBem > 0 .And. Empty(aColsBens[n][nPosCodigoBem])) .And. ;
			(nPosItemBem  > 0 .And. Empty(aColsBens[n][nPosItemBem])).And. ;
			!(APTGetLinha(oGetBens:aHeader,aColsBens))
				Aviso(STR0033, STR0053, {"OK"} )	 // "Atencao!"###"Verifique os campos Codigo e Item do Bem."
			Return .F.
		EndIf

		For nx:=1 To Len(aColsBens)
			If  aColsBens[n][nPosCodigoBem]	== aColsBens[nx][nPosCodigoBem] .And.;
				aColsBens[n][nPosItemBem] 	== aColsBens[nx][nPosItemBem] .And.;
				!aColsBens[nx][Len(aColsBens[nx])] .And. n # nx
				Aviso(STR0033, STR0054, {"OK"} )	// "Atencao!"##$#"Bem ja cadastrado como Garantia/Penhora."
				Return .F.
				Exit
			EndIf
		Next nx
	EndIf
EndIf
PutFileInEof("REG")
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³APT100Grava³ Autor ³ Tania Bronzeri  		 ³ Data ³20/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os registros referentes ao Processo	 	               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : OPcao                                               ³±±
±±³          ³ ExpN1 : Array dos Objetos da Get                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³APTA100                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function APT100Grava ( nOpcx , aObjects )

Local aColsRec			:= {}
Local cCampo    		:= ""
Local xConteudo 		:= ""
Local nx 				:= 0
Local ny 				:= 0
Local nI				:= 0
Local nz				:= 0
Local nd				:= 0
Local nCount			:= 1
Local cCodMM			:= ""
Local lGrava			:= .F.
Local lExcluido			:= .F.
Local lPerg				:= .F.
Local aMemosGrava		:= {}
Local aCodMM			:= {}
Local nOpcMM			:= 0
Local cMsgNoYes			:= ""
Local aColsAnt			:= aClone(aRescAnt[3])
Local nk				:= 0
Local aColTab			:= {}

// Processo
dbSelectArea("RE0")
RecLock("RE0",IIf(nOpcx#3, .F., .T.))
aFase	:=	aSort(aFase,,,{ |x, y| x[1] > y[1] })

For nI := 1 To FCount()
	If (FieldName(nI) == "RE0_FILIAL")
		FieldPut(nI, xFilial("RE0"))
	ElseIf (FieldName(nI) == "RE0_FASECD")
		If Len(aFase) > 0 .And. !(Empty(aFase[1][2]))
			FieldPut(nI, aFase[1][2])
		Else
			FieldPut(nI, "0")
		EndIf
	ElseIf (FieldName(nI) == "RE0_FASEDT")
		If Len(aFase) > 0 .And. !(Empty(aFase[1][1]))
			FieldPut(nI, aFase[1][1])
		Else
			FieldPut(nI, M->RE0_DTPROC)
		EndIf
	ElseIf ! (FieldName(nI)$"RE0_COBS")
		FieldPut(nI, M->&(FieldName(nI)))
	Else
		cCodMM :=  FieldGet( nI )
	EndIf
Next nI

//MSMM sera executado depois da gravacao de todos os campos pois quando
//controle de transacoes nao esta ativo o lock da RE0 e retirado dentro da funcao
MsMm(	cCodMM						,; //Codigo do Memo
		NIL							,;
		NIL							,;
		M->RE0_OBS					,; //Conteudo do Memo
		1							,;
		NIL							,;
		NIL							,;
		"RE0"						,; //Alias da Tabela que contem o memo
		"RE0_COBS"					,; //Nome do campo codigo do memo
		"RE6"						 ; //Tabela de Memos
	 )

MsUnlock()
FkCommit()

For nCount := 1 to Len(aObjects)
	aColsRec	:= aClone(aObjects[nCount][3])
	aHeader		:= aClone(aObjects[nCount][1]:aHeader)
	aCols 		:= aClone(aObjects[nCount][1]:aCols)
	aMemosGrava	:= aClone(aObjects[nCount][4])
	cAliasObj	:= aObjects[nCount][2]
	lGrava		:= .F.
	aCodMM		:= {}
	nOpcMM		:= 0
	nz			:= 0

	IF cAliasObj == "RE9" .OR. cAliasObj == "REH" .OR. cAliasObj == "REP"
		aColsRec	:= aClone(aObjects[nCount][3][1])
		aHeader		:= aClone(aObjects[nCount][3][2])
		aCols 		:= aClone(aObjects[nCount][3][3])
	EndIF

	dbSelectArea(cAliasObj)
	For nx :=1 to Len(aCols)
		lGrava	:=	.F.
		//--Verifica se Nao esta Deletado no aCols
		If !aCols[nx][Len(aCols[nx])]
			IF cAliasObj == "REL" .And. !Empty(aCols[nx][GdFieldPos("REL_CODPLT")]) .And. ;
				!Empty(aCols[nx][GdFieldPos("REL_TPPLT")])
				REL->( dbSetOrder(1) )
				If REL->( dbSeek(xFilial("REL")+cNumProc+aCols[nx][GdFieldPos("REL_CODPLT")]))
					RecLock(cAliasObj,.F.)
				Else
					RecLock(cAliasObj,.T.)
				EndIf
				Replace REL->REL_FILIAL 	WITH xFilial("REL")
				Replace REL->REL_PRONUM	 	WITH cNumProc
				lGrava := .T.
			ElseIf cAliasObj == "REH" .And. !Empty(aCols[nx][GdFieldPos("REH_DTPERI")])
				REH->( dbSetOrder(1) )
				If REH->( dbSeek(xFilial("RE0")+cNumProc+aCols[nx][GdFieldPos("REH_CODPLT")]+;
						DtoS(aCols[nx][GdFieldPos("REH_DTPERI")])+aCols[nx][GdFieldPos("REH_TIPO")]))
					RecLock(cAliasObj,.F.)
				Else
					RecLock(cAliasObj,.T.)
				EndIf
				lGrava := .T.
			ElseIf cAliasObj == "RE4" .And. !Empty(aCols[nx][GdFieldPos("RE4_CODADV")])
				RE4->( dbSetOrder(1) )
				If RE4->( dbSeek(xFilial("RE4")+cNumProc+aCols[nx][GdFieldPos("RE4_CODADV")]))
					RecLock(cAliasObj,.F.)
				Else
					RecLock(cAliasObj,.T.)
				EndIf
				Replace RE4->RE4_FILIAL 	WITH xFilial("RE4")
				Replace RE4->RE4_PRONUM	 	WITH cNumProc
				lGrava := .T.
			ElseIf cAliasObj == "REA" .And. !Empty(aCols[nx][GdFieldPos("REA_DATA")])
				REA->( dbSetOrder(1) )
				If REA->( dbSeek(xFilial("REA")+cNumProc+DtoS(aCols[nx][GdFieldPos("REA_DATA")])))
					RecLock(cAliasObj,.F.)
				Else
					RecLock(cAliasObj,.T.)
				EndIf
				Replace REA->REA_FILIAL 	WITH xFilial("REA")
				Replace REA->REA_PRONUM	 	WITH cNumProc
				lGrava := .T.
			ElseIf cAliasObj == "RE9" .And. !Empty(aCols[nx][GdFieldPos("RE9_TESCOD")])
				RE9->( dbSetOrder(1) )
				If RE9->( dbSeek(xFilial("RE0")+cNumProc+DtoS(aCols[nx][GdFieldPos("RE9_DATA")])+;
						aCols[nx][GdFieldPos("RE9_TESCOD")]))
					RecLock(cAliasObj,.F.)
				Else
					RecLock(cAliasObj,.T.)
				EndIf
				lGrava := .T.
			ElseIf cAliasObj == "REO" .And. !Empty(aCols[nx][GdFieldPos("REO_DATA")])
				REO->( dbSetOrder(1) )
				If REO->( dbSeek(xFilial("REO")+cNumProc+DtoS(aCols[nx][GdFieldPos("REO_DATA")])+;
							aCols[nx][GdFieldPos("REO_TIPO")]))
					RecLock(cAliasObj,.F.)
				Else
					RecLock(cAliasObj,.T.)
				EndIf
				Replace REO->REO_FILIAL 	WITH xFilial("REO")
				Replace REO->REO_PRONUM	 	WITH cNumProc
				lGrava := .T.
			ElseIf cAliasObj == "RES" .And. !Empty(aCols[nx][GdFieldPos("RES_JULGAM")])
				RES->( dbSetOrder(1) )
				If RES->( dbSeek(xFilial("RES")+cNumProc+DtoS(aCols[nx][GdFieldPos("RES_JULGAM")])))
					RecLock(cAliasObj,.F.)
				Else
					RecLock(cAliasObj,.T.)
				EndIf
				Replace RES->RES_FILIAL 	WITH xFilial("RES")
				Replace RES->RES_PRONUM	 	WITH cNumProc
				lGrava := .T.
			ElseIf cAliasObj == "REP" .And. !Empty(aCols[nx][GdFieldPos("REP_MAT")]) .And.	;
			!Empty(aCols[nx][GdFieldPos("REP_PERIOD")])	.And.	;
			!Empty(aCols[nx][GdFieldPos("REP_PD")])		.And.	;
			(aCols[nx][GdFieldPos("REP_VALOR")])	>	0
				REP->( dbSetOrder(1) ) // REP_FILIAL+REP_PRONUM+DTOS(REP_DTSTCA)+REP_MAT+REP_PERIOD+REP_CC
				If !fCompArray(aCols,aColsAnt) .And. !lExcluido
					For nd := 1 to Len(aColsAnt)
						If  !Empty(aColsAnt[nd][GdFieldPos("REP_MAT")]) .And.	;
							!Empty(aColsAnt[nd][GdFieldPos("REP_PERIOD")])	.And.	;
							!Empty(aColsAnt[nd][GdFieldPos("REP_PD")])
							If REP->(	dbSeek(xFilial("RE0")+;
										cNumProc+DtoS(aColsAnt[nd][GdFieldPos("REP_DTSTCA")])+;
										aColsAnt[nd][GdFieldPos("REP_MAT")]+aColsAnt[nd][GdFieldPos("REP_PERIOD")]+aColsAnt[nd][GdFieldPos("REP_CC")]) )
								While !("REP")->( Eof() ) .And. ;
								( REP->REP_FILIAL + REP->REP_PRONUM + DtoS(REP->REP_DTSTCA) + REP->REP_MAT + REP->REP_PERIOD + REP->REP_CC ) == ;
								( xFilial("RE0")+cNumProc+DtoS(aColsAnt[nd][GdFieldPos("REP_DTSTCA")])+aColsAnt[nd][GdFieldPos("REP_MAT")]+aColsAnt[nd][GdFieldPos("REP_PERIOD")]+aColsAnt[nd][GdFieldPos("REP_CC")] )
									If REP->REP_PD == aColsAnt[nd][GdFieldPos("REP_PD" )]
										RecLock(cAliasObj,.F.)
										dbDelete()
										MsUnlock()
										FkCommit()
									EndIf
									("REP")->( dbSkip() )
								EndDo
							EndIf
						EndIf
					Next nd
					lExcluido := .T.
				EndIf
				REP->( dbSetOrder(2) )
				If REP->(	dbSeek( xFilial("RE0")+;
							aCols[nx][GdFieldPos("REP_PERIOD")]+;
							aCols[nx][GdFieldPos("REP_MAT")]+;
							aCols[nx][GdFieldPos("REP_PD")]+;
							aCols[nx][GdFieldPos("REP_CC")] )	)
					RecLock(cAliasObj,.F.)
				Else
					RecLock(cAliasObj,.T.)
				EndIf
				lGrava := .T.
			ElseIf cAliasObj == "REM" .And. !Empty(aCols[nx][GdFieldPos("REM_DATA")])
				REM-> ( dbSetOrder(1) )
				If REM->( dbSeek(xFilial("REM")+cNumProc+DtoS(aCols[nx][GdFieldPos("REM_DATA")])+aCols[nx][GdFieldPos("REM_TIPO")]))
					RecLock(cAliasObj,.F.)
				Else
					RecLock(cAliasObj,.T.)
				EndIf
				Replace REM->REM_FILIAL 	WITH xFilial("REM")
				Replace REM->REM_PRONUM	 	WITH cNumProc
				lGrava := .T.
			ElseIf cAliasObj == "RC1" .And. !Empty(aCols[nx][GdFieldPos("RC1_NUMTIT")]) .And. aCols[nx][GdFieldPos("RC1_VALOR")] > 0
				RC1->( dbSetOrder(3) )
				If RC1->( dbSeek(xFilial("RC1")+cNumProc+aCols[nx][GdFieldPos("RC1_PREFIX")]+	;
					aCols[nx][GdFieldPos("RC1_NUMTIT")]+aCols[nx][GdFieldPos("RC1_PARC")]))
					RecLock(cAliasObj,.F.)
				Else
					RecLock(cAliasObj,.T.)
				EndIf
				Replace RC1->RC1_FILIAL 	WITH xFilial("RC1")
				Replace RC1->RC1_PRONUM	 	WITH cNumProc
				Replace RC1->RC1_CODTIT		WITH "APT"
				Replace RC1->RC1_ORIGEM		WITH "APTA100"
				lGrava := .T.
			ElseIf cAliasObj == "REG" .And. !Empty(aCols[nx][GdFieldPos("REG_CODIGO")])
				REG->( dbSetOrder(1) )
			If REG->( dbSeek(xFilial("REG")+cNumProc+aCols[nx][GdFieldPos("REG_CODIGO")]+aCols[nx][GdFieldPos("REG_ITEM")]))
					RecLock(cAliasObj,.F.)
				Else
					RecLock(cAliasObj,.T.)
				EndIf
				Replace REG->REG_FILIAL 	WITH xFilial("REG")
				Replace REG->REG_PRONUM	 	WITH cNumProc
				lGrava := .T.
			EndIf
		EndIf

		For ny := 1 To Len(aHeader)
			IF !Empty(xFilial(cAliasObj)+cNumProc)
				If lGrava
					If aHeader[ny][8] # "M"
						cCampo    := Trim(aHeader[ny][2])
						xConteudo := aCols[nx][ny]
						Replace &cCampo With xConteudo
					EndIf

					If aHeader[ny][8] == "M"
						IF Len(aMemosGrava) > 0
							nz += 1
							aAdd	( aCodMM , { FieldGet ( FieldPos ( aMemosGrava[nz][1][1] ) ) , ;
												aCols[nx][ny]	  		,;
												cAliasObj				,;
												aMemosGrava[nz][1][1]	,;
												aMemosGrava[nz][1][3]	};
									)
						EndIF
					EndIF
				EndIf
			EndIF
		Next ny

		If lGrava
			MsUnlock()
			FkCommit()
		EndIf

		//--Verifica se esta deletado
		If aCols[nx][Len(aCols[nx])]
			nOpcMM := 2
		Else
			nOpcMM := 1
		EndIF

		// Providencia a Gravacao e/ou Exclusao do Memo.
		IF Len(aCodMM) > 0
			For ny := 1 to Len(aCodMM)
				MsMm(	aCodMM[ny][1]		,; //Codigo do memo
						NIL					,;
						NIL					,;
						aCodMM[ny][2]		,; //Conteudo do Memo
						nOpcMM				,; //Opcao de Gravacao ou Delecao do Memo
						NIL					,;
						NIL					,;
						aCodMM[ny][3]		,; //Alias da Tabela que contem o memo
						aCodMM[ny][4]		,; //Nome do campo codigo do memo
						aCodMM[ny][5]		 ; //Tabela de Memos
						)
			Next ny
			aCodMM	:=	{}
		EndIF

		//--Verifica se esta deletado e se ja existia na base
		If Len(aColsRec) >= nx .And. aCols[nx][Len(aCols[nx])]
			IF ValType(aColsRec[nx]) # "A"
				dbGoto(aColsRec[nx])
			Else
				dbGoto(aColsRec[nx][1])
			EndIF
			RecLock(cAliasObj,.F.)
			dbDelete()
			MsUnlock()
			FkCommit()
		EndIf
		nz := 0
	Next nx

Next nCount

// Tratamento da situação que se altera o codigo da testemunha já
// cadastrada e gravada na tabela Fisica, assim a rotina ira em um registro já existente
For nCount := 1 to Len(aObjects)
	cAliasObj	:= aObjects[nCount][2]
	If cAliasObj == "RE9"
		aHeader		:= aClone(aObjects[nCount][3][2])
		aCols 		:= aClone(aObjects[nCount][3][3])
		aMemosGrava	:= aClone(aObjects[nCount][4])

		dbSelectArea("RE9")
		dbSetOrder(1)
		dbSeek(xFilial("RE0")+aCols[1][GdFieldPos("RE9_PRONUM")]+DTOS(aCols[1][GdFieldPos("RE9_DATA")]))
		cProNum := aCols[1][GdFieldPos("RE9_PRONUM")]
		dDataPr := aCols[1][GdFieldPos("RE9_DATA")]
		aColTab := {}
		// Processo que carrega os dados os arquivo RE9, gravado para verificação se não
		// necessita excluir nenhum registro.
		While !EOf() .and. RE9->RE9_PRONUM = cProNum .and. DTOS(RE9->RE9_DATA) = DTOS(dDataPr)
			aAdd( aColTab, { RE9->RE9_PRONUM,RE9->RE9_DATA,RE9->RE9_TESCOD,.F.,RE9->(Recno()),})
			dbSelectArea("RE9")
			dbSkip()
		Enddo

		// Processo que verifica se o registro existe na tabela e no aCols.
		For nk:=1 to Len(ACols)
			nPos := aScan( aColTab , { |x| x[3] == aCols[nk][4]} )
			If nPos > 0
				aColTab[nPos][4] := .T.
			Endif
		Next
	Endif
Next

// Processo que exclui o registro da tabela quando não existe
// na Acols de testemunhas.
For nk := 1 to Len(aColTab)
	If !aColTab[nk][4]
		// Exclui o registro da Tabela de Testemunhas
		dbSelectArea("RE9")
		dbGoto(aColTab[nk][5])
		RecLock("RE9",.F.)
		dbDelete()
		MsUnlock()
		FkCommit()

		// Tratamento para a exclusão do campo Memo referente ao registro deletado acima
		// Deveremos nos atentar que as informações do campo memo para o modulo de
		// Processos Trabalhistas são gravados na Tabela RE6 e não na SYP.
		aCodMM	:=	{}
		aAdd	( aCodMM , { FieldGet ( FieldPos ( aMemosGrava[1][1][1] ) ) , ;
							 		  	aCols[nk][8]	  		,;
										"RE9"				,;
										aMemosGrava[1][1][1]	,;
										aMemosGrava[1][1][3]	})


		// Providencia a Gravacao e/ou Exclusao do Memo.
		IF Len(aCodMM) > 0
			For ny := 1 to Len(aCodMM)
				MsMm(	aCodMM[ny][1]		,; //Codigo do memo
						NIL					,;
						NIL					,;
						aCodMM[ny][2]		,; //Conteudo do Memo
						2					,; //Opcao de Gravacao (1) ou Delecao (2) do Memo
						NIL					,;
						NIL					,;
						aCodMM[ny][3]		,; //Alias da Tabela que contem o memo
						aCodMM[ny][4]		,; //Nome do campo codigo do memo
						aCodMM[ny][5]		 ; //Tabela de Memos
					 )
			Next ny
		Endif
	Endif
Next


Return .T.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³APT100Dele³ Autor ³ Tania Bronzeri  	 	³ Data ³20/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Deleta todos os registros referentes ao Processo            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³APTA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function APT100Dele()

Local aNoChk	:= {}
Local lChkDelOk	:= .F.

dbSelectArea("RE0")
If Empty(RE0->RE0_PROJUD)
	aadd(aNoChk,"SRG")
EndIf

lChkDelOk  := ChkDelRegs(	"RE0"				,;	//01 -> Alias do Arquivo Principal
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
							aNoChk				 ;	//18 -> Alias que nao deverao ser Verificados no SX9
					    )

If !lChkDelOk
	Return Nil
Endif

// Bens do Ativo Imobilizado
dbSelectArea("REG")
dbSetOrder(1)
If dbSeek(xFilial("REG")+cNumProc)
	While !Eof() .And. REG->REG_FILIAL+REG->REG_PRONUM == ;
						 xFilial("REG")+cNumProc
		RecLock("REG",.F.)
			dbDelete()
		MsUnlock()
		dbSkip()
	EndDo
EndIf

// Despesa
dbSelectArea("RC1")
dbSetOrder(3)
If dbSeek(xFilial("RC1")+cNumProc)
	While !Eof() .And. RC1->RC1_FILIAL+RC1->RC1_PRONUM == ;
						 xFilial("RC1")+cNumProc
		RecLock("RC1",.F.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo
EndIf

// Recurso
dbSelectArea("REM")
dbSetOrder(1)
If dbSeek(xFilial("REM")+cNumProc)
	While !Eof() .And. REM->REM_FILIAL+REM->REM_PRONUM == ;
						 xFilial("REM")+cNumProc
		RecLock("REM",.F.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo
EndIf

// Lista de Sentenca
dbSelectArea("RES")
dbSetOrder(1)
If dbSeek(xFilial("RES")+cNumProc)
	While !Eof() .And. RES->RES_FILIAL+RES->RES_PRONUM == ;
						 xFilial("RES")+cNumProc
		RecLock("RES",.F.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo
EndIf

// Ocorrencia
dbSelectArea("REO")
dbSetOrder(1)
If dbSeek(xFilial("REO")+cNumProc)
	While !Eof() .And. REO->REO_FILIAL+REO->REO_PRONUM == ;
						 xFilial("REO")+cNumProc
		RecLock("REO",.F.)
			dbDelete()
		MsUnlock()
		dbSkip()
	EndDo
EndIf

// Lista de Audiencia
dbSelectArea("REA")
dbSetOrder(1)
If dbSeek(xFilial("REA")+cNumProc)
	While !Eof() .And. REA->REA_FILIAL+REA->REA_PRONUM == ;
						 xFilial("REA")+cNumProc
		RecLock("REA",.F.)
			dbDelete()
		MsUnlock()
		dbSkip()
	EndDo
EndIf

// Lista de Advogado
dbSelectArea("RE4")
dbSetOrder(1)
If dbSeek(xFilial("RE4")+cNumProc)
	While !Eof() .And. RE4->RE4_FILIAL+RE4->RE4_PRONUM == ;
						 xFilial("RE4")+cNumProc
		RecLock("RE4",.F.)
			dbDelete()
		MsUnlock()
		dbSkip()
	EndDo
EndIf

// Pleito
dbSelectArea("REL")
dbSetOrder(2)
If dbSeek(xFilial("REL")+cNumProc)
	While !Eof() .And. REL->REL_FILIAL+REL->REL_PRONUM == ;
						 xFilial("REL")+cNumProc
		RecLock("REL",.F.)
			dbDelete()
		MsUnlock()
		dbSkip()
	EndDo
EndIf

// Processo
dbSelectArea("RE0")
RecLock("RE0",.F.)
	dbDelete()
MsUnlock()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³APT100TudOk³ Autor ³ Tania Bronzeri 	 	 ³ Data ³20/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao executada no Ok da enchoicebar                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³APT100TudOk(nExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³APTA100                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function APT100TudOk(nOpcx)
Local aArea			:= GetArea()
Local aCampos		:= {}
Local aCamposTit	:= {}
Local cCampos		:= ""
Local leSocAtivo	:= .F.
Local x	:= 0
Local y	:= 0

Default aEfd 		:= If( cPaisLoc == 'BRA', If(Findfunction("fEFDSocial"), fEFDSocial(), {.F.,.F.,.F.}),{.F.,.F.,.F.} )
Default cEFDAviso	:= If(cPaisLoc == 'BRA' .AND. Findfunction("fEFDAviso"), fEFDAviso(), "0")

If nOpcx == 2
	Return .T.
EndIf

If ((nOpcx == 3 .OR. nOpcx== 4) .AND. aEfd[1] .AND. cEFDAviso <> '2' .And. !Empty(M->RE0_DTDECI) )

	aCampos		:= {M->RE0_TPPROC	,M->RE0_PROJUD	, M->RE0_INDSUS	,M->RE0_DTDECI	,M->RE0_IDDEP}
	aCamposTit	:= {"RE0_TPPROC"	,"RE0_PROJUD"	, "RE0_INDSUS"	,"RE0_DTDECI"	,"RE0_IDDEP"}

	//Iremos avaliar se algum campo do eSocial foi preenchido
	For y:=1 to len(aCampos)
		If !EMPTY(aCampos[y])
			leSocAtivo	:= .T.
			Exit
		EndIf
	Next y

	//Caso algum campo eSocial preenchido, todos deverão ser preenchidos
	//Pois segundo o leiaute Registro S-1070 - Grupo: dadosProcesso
	If leSocAtivo
		dbSelectArea("SX3")
		dbSetOrder(2)
		dbGoTop("SX3")

		For x:=1 to len(aCampos)
			If EMPTY(aCampos[x])
				SX3->(msSeek( aCamposTit[x] ))
				cCampos += X3Titulo(aCamposTit[x]) + CRLF
			EndIf
		Next x

		//Se eh processo judicial, validacao segundo leiaute Registro S-1070 - Grupo: dadosProcJud
		If (ALLTRIM(M->RE0_TPPROC) == "J")
			If Empty(M->RE0_VARA)
				cCampos += OemToAnsi(STR0092)+ CRLF			//"Vara"
			Elseif cPaisLoc == "BRA"
				dbSelectArea("RE1")
				dbSetOrder(1)
				dbGoTop("RE1")
				If RE1->(msSeek( FwxFilial("RE1")+M->RE0_COMAR+M->RE0_VARA )) .AND. (Empty(RE1->RE1_IDVARA) .AND. Empty(RE1->RE1_CODMUN))
					cCampos += OemToAnsi(STR0091)+ CRLF		//"Vara escolhida não possui Id Vara ou Código Município Vazio(s)."
				EndIf
			EndIf

		EndIf

		If lESProc .And. M->RE0_ORIGEM == "2"
			If Empty(M->RE0_DTCCP) .Or. Empty(M->RE0_TPCCP) .Or. Empty(M->RE0_CNPJCC)		
				cCampos += OemToAnsi(STR0131)+ CRLF		//"Para Origem igual a 2 - Demanda submetida à CCP os campo Dt. Concil., Âmbito CCP  e CNPJ CCP deverão ser preenchidos obrigatoriamente."
			EndIf
		EndIf

		If !Empty(cCampos)
			cMsg:= OemtoAnsi(STR0093)+ CRLF									//"O(s)  seguinte(s) campo(s)  é(são) obrigatório(s) na eSocial,"

			If cEFDAviso=="0"
				cMsg+= OemtoAnsi(STR0095) + CRLF + CRLF + cCampos		//"mas nao sera impeditivo para a gravacao dos dados deste processo."
			Else
				cMsg+= OemtoAnsi(STR0094)+ CRLF + CRLF + cCampos		//"e sera necessario o preenchimento dos mesmos para efetivar a gravacao dos dados deste processo."
			EndIf

			Help("",1,OemtoAnsi(STR0097),,cMsg,1,0)				//"Campo nao preenchido"

			If cEFDAviso == "1"
				Return(.F.)
			Endif
		Endif
	EndIf
EndIf







RestArea(aArea)
Return (APT100VlTree(nOpcx))


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ProgREO   ³ APT100Principal  ³ Autor ³ Tania Bronzeri³ Data ³20/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao principal que controla mudanca de arquivo           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ APT100Principal(oExpO1,oExpO2)	 	 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APTA100       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function APT100Principal(oTree,oDlgMain)
cIndo:= oTree:GetCargo()

If cEstou == "1"
	oEnchoice:Hide()
	cNumProc	:= M->RE0_NUM
	cDesc		:= M->RE0_DESCR
	cGet 		:= M->RE0_NUM + " - " + M->RE0_DESCR
	if(M->RE0_TPACAO=="1",RelGetPltRel(),Nil)
ElseIf cEstou == "2"
	oGetPleitos:Hide()
	oGetPleitos:oBrowse:Hide()
	oGroupPleitos:Hide()
	oGetPericias:Hide()
	oGetPericias:oBrowse:Hide()
	oGroupPericias:Hide()
ElseIf cEstou == "3"
	oGetAdvogados:Hide()
	oGetAdvogados:oBrowse:Hide()
	oGroupAdvogados:Hide()
ElseIf cEstou == "4"
	oGetAudiencias:Hide()
	oGetAudiencias:oBrowse:Hide()
	oGroupAudiencias:Hide()
	oGetTestemunhas:Hide()
	oGetTestemunhas:oBrowse:Hide()
	oGroupTestemunhas:Hide()
ElseIf cEstou == "5"
	oGetOcorrencias:Hide()
	oGetOcorrencias:oBrowse:Hide()
	oGroupOcorrencias:Hide()
ElseIf cEstou == "6"
	oGetSentencas:Hide()
	oGetSentencas:oBrowse:Hide()
	oGroupSentencas:Hide()
	oGetRescCompl:Hide()
	oGetRescCompl:oBrowse:Hide()
	oGroupRescCompl:Hide()
ElseIf cEstou == "7"
	oGetRecursos:Hide()
	oGetRecursos:oBrowse:Hide()
	oGroupRecursos:Hide()
ElseIf cEstou == "8"
	oGetDespesas:Hide()
	oGetDespesas:oBrowse:Hide()
	oGroupDespesas:Hide()
ElseIf cEstou == "9"
	oGetBens:Hide()
	oGetBens:oBrowse:Hide()
	oGroupBens:Hide()
EndIf

If cIndo == "1"
	oEnchoice:Show()
	oEnchoice:Refresh()
	oSay1:Hide()
	oGetProcesso:Hide()
	oAux	:= oEnchoice
ElseIf cIndo == "2"
	oGetPleitos:Show()
	oGetPleitos:oBrowse:Show()
	oGroupPleitos:Show()
	oGetPericias:Show()
	oGetPericias:oBrowse:Show()
	oGroupPericias:Show()
	oSay1:Show()
	oGetProcesso:Show()
	oGetProcesso:cText(cGet)
	oGetPleitos:refresh()
	n		:= 1
	oAux	:= oGetPleitos
ElseIf cIndo == "3"
	oGetAdvogados:Show()
	oGetAdvogados:oBrowse:Show()
	oGroupAdvogados:Show()
	oSay1:Show()
	oGetProcesso:Show()
	oGetProcesso:cText(cGet)
	n		:= 1
	oAux	:= oGetAdvogados
ElseIf cIndo == "4"
	oGetAudiencias:Show()
	oGetAudiencias:oBrowse:Show()
	oGroupAudiencias:Show()
	oGetTestemunhas:Show()
	oGetTestemunhas:oBrowse:Show()
	oGroupTestemunhas:Show()
	oSay1:Show()
	oGetProcesso:Show()
	oGetProcesso:cText(cGet)
	n		:= 1
	oAux	:= oGetAudiencias
ElseIf cIndo == "5"
	oGetOcorrencias:Show()
	oGetOcorrencias:oBrowse:Show()
	oGroupOcorrencias:Show()
	oSay1:Show()
	oGetProcesso:Show()
	oGetProcesso:cText(cGet)
	n		:= 1
	oAux	:= oGetOcorrencias
ElseIf cIndo == "6"
	oGetSentencas:Show()
	oGetSentencas:oBrowse:Show()
	oGroupSentencas:Show()
	oGetRescCompl:Show()
	oGetRescCompl:oBrowse:Show()
	oGroupRescCompl:Show()
	oSay1:Show()
	oGetProcesso:Show()
	oGetProcesso:cText(cGet)
	n		:= 1
	oAux	:= oGetSentencas
ElseIf cIndo == "7"
	oGetRecursos:Show()
	oGetRecursos:oBrowse:Show()
	oGroupRecursos:Show()
	oSay1:Show()
	oGetProcesso:Show()
	oGetProcesso:cText(cGet)
	n		:= 1
	oAux	:= oGetRecursos
ElseIf cIndo == "8"
	oGetDespesas:Show()
	oGetDespesas:oBrowse:Show()
	oGroupDespesas:Show()
	oSay1:Show()
	oGetProcesso:Show()
	oGetProcesso:cText(cGet)
	n		:= 1
	oAux	:= oGetDespesas
ElseIf cIndo == "9"
	oGetBens:Show()
	oGetBens:oBrowse:Show()
	oGroupBens:Show()
	oSay1:Show()
	oGetProcesso:Show()
	oGetProcesso:cText(cGet)
	n		:= 1
	oAux	:= oGetBens
EndIf

cEstou := cIndo

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³APT100VlTree³ Autor ³ Tania Bronzeri       ³ Data ³20/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao do Tree                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³APTA100                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function APT100VlTree(nOpcx)

Local lRet     	:=.T.

If nOpcx # 2 .And. nOpcx # 5			// Diferente de visual e delecao
	If cEstou == "1"
		lRet:= Obrigatorio(aGets,aTela)
		if lRet
		    AptPleitosOk(1)
		EndIf
	ElseIf cEstou == "2"
		lRet:= AptPleitosOk()
		If lRet
			lRet := AptPericiasOk()
		EndIf
	ElseIf cEstou == "3"
		lRet:= AptAdvogadosOk()
	ElseIf cEstou == "4"
		lRet:= AptAudienciasOK()
		If lRet
			lRet := AptTestemunhasOk()
		EndIf
	ElseIf cEstou == "5"
		lRet:= AptOcorrenciasOk()
	ElseIf cEstou == "6"
		lRet:= AptSentencasOk()
		If lRet .And. !(APT100LinhaVazia ( oGetSentencas:aHeader , oGetSentencas:aCols ))
			lRet := AptRescComplOk()
		EndIf
	ElseIf cEstou == "7"
		lRet:= AptRecursosOk()
	ElseIf cEstou == "8"
		lRet:= AptDespTdOk()
	ElseIf cEstou == "9"
		lRet:= AptBensOk()
	EndIf
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ APTGetLinha	³ Autor ³ Tania Bronzeri 	³ Data ³20/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a primeira linha esta toda sem preencher		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias											  ³±±
±±³			 ³ ExpN1 : Registro											  ³±±
±±³			 ³ ExpN2 : Opcao											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ APTA100		 ³											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function APTGetLinha(aHeaderLinha,aColsLinha)
Local lTree := .T.
Local nx	:= 0
Local nTam	:= Len(aHeaderLinha)

For nx:=1 To nTam
	If 	aHeaderLinha[nx][4] != 1 ;  	// Desprezar tamanho = 1
		.And. aHeaderLinha[nx][14] != "V"	// Desprezar campos visuais
		If !Empty(aColsLinha[1][nx])
			lTree := .F.
			Exit
		EndIf
	EndIf
Next nx

Return lTree

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ APT100LinhaVazia	³ Autor ³ Tania Bronzeri    ³ Data ³ 09/09/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a primeira linha esta toda sem preenchimento         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  	 	 	 	 								     		    ³±±
±±³			 ³                       			 		 		 	 		 	³±±
±±³			 ³                          	 		 		 		 		 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ APTA100       ³	         	 		 		 		 		 	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function APT100LinhaVazia ( aHeadVerif , aColsVerif , aExcecao )
Local lVazio := .T.
Local nx	 := 0
Local ne	 := 0

Default	aExcecao	:=	{}

For nx := 1 To (Len(aHeadVerif) - 1)
	IF (!(Empty(aColsVerif[n][nx])) .And. (aHeadVerif[nx][14] != "V") .AND. !IsHeadRec(aHeadVerif[nx, 2]) .AND. !IsHeadAlias(aHeadVerif[nx, 2]) )
		IF Len(aExcecao) # 0
			For ne	:=	1 to Len(aExcecao)
				If nx == aExcecao[ne]
					IF !Empty(aColsVerif[n][aExcecao[ne]])
						lVazio	:=	.T.
						Exit
					Else
						lVazio	:=	.F.
					EndIf
			   	Else
					lVazio	:= .F.
				EndIF
			Next ne
			IF !(lVazio)
		   		Exit
	        Endif
		Else
			lVazio	:= .F.
			Exit
		EndIF
	EndIF
Next nx

Return lVazio


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Apta100BoxOpc³ Autor ³ Tania Bronzeri 	³ Data ³20/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preenche	combobox do Tipo da Acao						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SX3_CBOX  	 ³											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Apta100BoxOpc()

Local cOpcBox := ""

cOpcBox += ( "1=" + STR0020 + ";"	)	//"Individual Singular"
cOpcBox += ( "2=" + STR0021 + ";"	)	//"Individual Plurima"
cOpcBox += ( "3=" + STR0022			)	//"Coletiva"

Return ( cOpcBox )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Apt100Desc ³ Autor ³ Tania Bronzeri	   ³ Data ³ 28/06/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Traz a descricao											   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                       							           ³±±
±±³			 ³                        	  								   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ APTA100        ³			        					       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Apt100Desc( cAlias, cCampo, cDescr )

Local aSaveArea := GetArea()
Local nPosCod 	:= 0
Local nPosDesc	:= 0
Local cChave  	:= " "
Local cRetorno	:= ""

cRetorno := .T.

nPosCod		:= GdFieldPos(cCampo)
nPosDesc	:= GdFieldPos(cDescr)

cChave 		:= aCols[Len(aCols)][nPosCod]
cRetorno	:= Iif(Inclui, "", Fdesc(cAlias, cChave, cCampo))

RestArea(aSaveArea)

Return cRetorno


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Apta100AllTrf     ³ Autor ³ Tania Bronzeri	  ³ Data ³ 04/08/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Transfere Informacoes do aCols para o aColsAll	 	 	 	 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³   	  		           	 	 	  	 	 	 	 	 	 	      ³±±
±±³			 ³    	 	 	 	 	 	 	 	 	 	 	 	 			 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ APTA100        ³			        	 	 		 	 	 		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Apta100AllTrf(	cAlias			,;	//01 -> Alias do Arquivo
						oGetFather 		,;	//02 -> Objeto GetDados para o REA ou REL ou RES
						aCols			,;	//03 -> aCols utilizado na GetDados
						aHeader 		,;	//04 -> aHeader utilizado na GetDados
						aColsAll		,;	//05 -> aCols com todas as informacoes
						aHeaderAll		,;	//06 -> aHeader com todos os campos
						lDeleted		,;	//07 -> Se carrega elemento de Deletado na remontagem do aCols
						lTransf2All		,;	//08 -> Se transfere do aCols para o aColsAll
						lTransf2Cols     ;	//09 -> Se transfere do aColsAll para o aCols
					  )

Local aPosSortAll		:= {}
Local aPosKeyAll		:= {}
Local cChave			:= ""
Local nPosFilial		:= 0
Local nPosProc			:= 0
//Variaveis para tratamento Pleito x Pericia
Local cCodPlt			:= ""
Local nPosPleito		:= 0
Local nPosPericia		:= 0
Local nPosTipo			:= 0
//Variaveis para tratamento Audiencia x Testemunha
Local dDataRea			:= Ctod("  /  /  ")
Local nPosData			:= 0
Local nPosTest			:= 0
//Variaveis para tratamento Sentenca x Rescisao Complementar
Local dDataRes			:= Ctod("  /  /  ")
Local nPosDtStca		:= 0
Local nPosMat			:= 0
Local nPosPeriod		:= 0
Local nPosVerba			:= 0

DEFAULT lTransf2All		:= .T.
DEFAULT lTransf2Cols	:= .T.

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Obtem o Posicionamento dos Campos    						  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
IF ( cAlias == "REA" )
	nPosFilial	:= GdFieldPos( "REA_FILIAL"	, aHeaderAll )
	nPosProc  	:= GdFieldPos( "REA_PRONUM"	, aHeaderAll )
	nPosData	:= GdFieldPos( "REA_DATA"	, aHeaderAll )
ElseIF ( cAlias == "RE9" )
	nPosFilial	:= GdFieldPos( "RE9_FILIAL"	, aHeaderAll )
	nPosProc  	:= GdFieldPos( "RE9_PRONUM"	, aHeaderAll )
	nPosData	:= GdFieldPos( "RE9_DATA"	, aHeaderAll )
	nPosTest	:= GdFieldPos( "RE9_TESCOD"	, aHeaderAll )
ElseIF ( cAlias == "REL" )
	nPosFilial	:= GdFieldPos( "REL_FILIAL"	, aHeaderAll )
	nPosProc  	:= GdFieldPos( "REL_PRONUM"	, aHeaderAll )
	nPosPleito	:= GdFieldPos( "REL_CODPLT"	, aHeaderAll )
ElseIF ( cAlias == "REH" )
	nPosFilial	:= GdFieldPos( "REH_FILIAL"	, aHeaderAll )
	nPosProc  	:= GdFieldPos( "REH_PRONUM"	, aHeaderAll )
	nPosPleito	:= GdFieldPos( "REH_CODPLT"	, aHeaderAll )
	nPosPericia	:= GdFieldPos( "REH_DTPERI"	, aHeaderAll )
	nPosTipo	:= GdFieldPos( "REH_TIPO"	, aHeaderAll )
ElseIF ( cAlias == "RES" )
	nPosFilial	:= GdFieldPos( "RES_FILIAL"	, aHeaderAll )
	nPosProc  	:= GdFieldPos( "RES_PRONUM"	, aHeaderAll )
	nPosDtStca	:= GdFieldPos( "RES_JULGAM"	, aHeaderAll )
ElseIF ( cAlias == "REP" )
	nPosFilial	:= GdFieldPos( "REP_FILIAL"	, aHeaderAll )
	nPosProc  	:= GdFieldPos( "REP_PRONUM"	, aHeaderAll )
	nPosDtStca	:= GdFieldPos( "REP_DTSTCA"	, aHeaderAll )
	nPosMat		:= GdFieldPos( "REP_MAT"	, aHeaderAll )
	nPosPeriod	:= GdFieldPos( "REP_PERIOD"	, aHeaderAll )
	nPosVerba	:= GdFieldPos( "REP_PD"		, aHeaderAll )
EndIF

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Carrega Array a Posicao dos Campos para o "Sort"			  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
IF ( cAlias == "REA" ) .OR. ( cAlias == "RE9")
	aAdd( aPosSortAll	, nPosFilial)
	aAdd( aPosSortAll	, nPosProc	)
	aAdd( aPosSortAll	, nPosData  )
ElseIF ( cAlias == "REL" ) .OR. ( cAlias == "REH")
	aAdd( aPosSortAll	, nPosFilial)
	aAdd( aPosSortAll	, nPosProc	)
	aAdd( aPosSortAll	, nPosPleito)
Else
	aAdd( aPosSortAll	, nPosFilial)
	aAdd( aPosSortAll	, nPosProc	)
	aAdd( aPosSortAll	, nPosDtStca)
EndIF

IF ( cAlias == "RE9" )
	aAdd( aPosSortAll	, nPosTest   )
ElseIF ( cAlias == "REH" )
	aAdd( aPosSortAll	, nPosPericia)
	aAdd( aPosSortAll	, nPosTipo	 )
ElseIF ( cAlias == "REP" )
	aAdd( aPosSortAll	, nPosMat	 )
	aAdd( aPosSortAll	, nPosPeriod )
	aAdd( aPosSortAll	, nPosVerba	 )
EndIF

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Carrega Array com a Posicao dos Campos e as Chaves  Correspondentes³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
aAdd( aPosKeyAll  	, { nPosFilial	, cFilRE0 	} )
aAdd( aPosKeyAll  	, { nPosProc	, cNumProc	} )
IF ( cAlias == "RE9" )
	dDataRea := GdFieldGet( "REA_DATA" , oGetFather:nAt , .F. , oGetFather:aHeader , oGetFather:aCols )
	aAdd( aPosKeyAll , { nPosData , dDataRea } )
ElseIF ( cAlias == "REH" )
	cCodPlt := GdFieldGet( "REL_CODPLT" , oGetFather:nAt , .F. , oGetFather:aHeader , oGetFather:aCols )
	aAdd( aPosKeyAll , { nPosPleito , cCodPlt } )
ElseIF ( cAlias == "REP" )
	dDataRes := GdFieldGet( "RES_JULGAM", oGetFather:nAt , .F. , oGetFather:aHeader , oGetFather:aCols )
	aAdd( aPosKeyAll , { nPosDtStca , dDataRes } )
EndIF

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Monta a chave para busca no aColsAll e Transferencia para o Respectivo aCols ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
IF ( cAlias == "REA" ) .OR. ( cAlias == "REL" ) .OR. ( cAlias == "RES" )
	cChave := ( cFilRE0 + cNumProc )
ElseIF ( cAlias == "RE9" )
	cChave := ( cFilRE0 + cNumProc + Dtos( dDataRea ) )
ElseIF ( cAlias == "REH" )
	cChave := ( cFilRE0 + cNumProc + cCodPlt )
ElseIF ( cAlias == "REP" )
	cChave := ( cFilRE0 + cNumProc + Dtos( dDataRES ) )
EndIF

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Transfere os Dados Entre aCols        					  	  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
GdTransfaCols(	@aColsAll   	,;	//01 -> Array com a Estrutura do aCols Contendo todos os Dados
				@aCols			,;	//02 -> Array com a Estrutura do aCols Contendo Dados Especificos
				aHeader			,;	//03 -> Array com a Estrutura do aHeader Contendo Informacoes dos Campos
				NIL				,;	//04 -> Array com as Posicoes dos Campos para Pesquisa
				cChave			,;	//05 -> Chave para Busca
				aPosSortAll		,;	//06 -> Array com as Posicoes dos Campos para Ordenacao
				aPosKeyAll		,;	//07 -> Array com as Posicoes dos Campos e Chaves para Pesquisa
				aHeaderAll		,;	//08 -> Array com a Estrutura do aHeaderAll Contendo Informacoes dos Campos
				lDeleted		,;	//09 -> Se Carrega o Elemento como Deletado na Remontagem do aCols
				lTransf2All		,;	//10 -> Se deve Transferir do aCols para o aColsAll
				lTransf2Cols    ,;	//11 -> Se deve Transferir do aColsAll para o aCols
				.T.				,;	//12 -> Se Existe o Elemento de Delecao no aCols
				.T.				,;	//13 -> Se deve Carregar os Inicializadores padroes
				NIL				,;	//14 -> Lado para o Inicializador padrao
				.F.				 ;	//15 -> Se deve criar variais Publicas
			   )

Return( NIL )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Ap100F3Re5		 ³ Autor ³ Tania Bronzeri	  ³ Data ³ 08/10/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Tipos (Manutencao) - Fases				   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³   	  		           	 	 	  	 	 	 	 	 	 	      ³±±
±±³			 ³    	 	 	 	 	 	 	 	 	 	 	 	 			 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ APTA100        ³			        	 	 		 	 	 		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Ap100F3Re5()

Local cTipo		:= PADR("REF" , TamSx3("RE5_TABELA")[1])
Local cRet		:= ""

cRet := "@#RE5->RE5_TABELA=='"+cTipo+"'@#"

//Garanto o Posicionamento na Tabela REK
REK->( MsSeek( xFilial( "REK" ) + cTipo , .F. ) )

Return (cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Ap100BoxRecl ³ Autor ³ Tania Bronzeri 	³ Data ³18/10/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preenche	combobox do Tipo da Reclamada					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SX3_CBOX  	 ³											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Ap100BoxRecl()

Local cOpcBox := ""

cOpcBox += ( "1=" + STR0030 + ";"	)	//"Principal"
cOpcBox += ( "2=" + STR0031			)	//"Co-Reclamada"

Return ( cOpcBox )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³AP100FilReuºAutor  ³Microsiga          º Data ³  10/27/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Filtra a sigla do perito no cadastro de pericias e no       º±±
±±º          ³cadastro de sentenca                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAAPT                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ap100FilREU()
Local cPerito	:= ""
Local nPosPer 	:= 1

If cEstou =="2"
	//oGetPericias:aHeader
	nPosPer	:= GdFieldPos("REH_PERITO",aHeader)
Else
	nPosPer	:= GdFieldPos("RES_PERITO",aHeader)
EndIf

cPerito := aCols[n,nPosPer]

Return(cPerito)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AptSelReclam ³ Autor ³ Tania Bronzeri        ³ Data ³ 21/09/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de atualizacao do mbrowse                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cMBrowse -> objeto mbrowse a dar refresh                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static Function AptSelReclam( oObjBrow, cConsReclam )

//--Executa Filtro do RH mais o Filtro Adicional da Rotina
Eval(bFiltraBrw, cConsReclam)

oObjBrow:ResetLen()
oObjBrow:Default()
oObjBrow:Refresh(.T.)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fGetReclamante ³ Autor ³ Tania Bronzeri        ³ Data ³ 23/09/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de busca do Reclamante na SXB                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  	 	 	 	 	 	 	 	 	 	                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Codigo do Processo                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGetReclamante()
Local cCodReclamante	:=	"!!!!!!"
Local lRet				:=	.F.
Local cCodProcessos		:=	""
Local cExpReclam

EndFilBrw("RE0",aIndFil)

lRet	:=	Conpad1(,,,"RD0REL",,,.F.)
IF lRet
	cCodReclamante	:=	RD0->RD0_CODIGO
	cCodProcessos	:=	AptSeekProcs(cCodReclamante)
	cExpReclam 		:=	'RE0->RE0_NUM $ "' + cCodProcessos + '"'
EndIf

Return(cExpReclam)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AptSeekProcs   ³ Autor ³ Tania Bronzeri        ³ Data ³ 23/09/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de buscas do Processos do Reclamante                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  	 	 	 	 	 	 	 	 	 	                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AptSeekProcs(cCodReclamante)
Local aPleitos	:= {}
Local cProcessos:= ""
Local nx		:= 0

Begin Sequence

	dbSelectArea("REL")
	dbSetOrder(2)
	REL->(DbGoTop())

	IF (REL->(DbSeek((xFilial("REL"))+(cCodReclamante))))
		While !Eof() .And. (REL->REL_RECLAM == cCodReclamante)
			aAdd ( aPleitos , { REL->REL_PRONUM, REL-> REL_CODPLT, REL->REL_RECLAM } )
			dbSkip()
		EndDo
	EndIf

	For nx := 1 to Len(aPleitos)
		IF !(aPleitos[nx][1] $ cProcessos)
			cProcessos += "*" + aPleitos[nx][1]
		EndIf
	Next nx

End Sequence

Return (cProcessos)


/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³19/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³APTA100                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function MenuDef()

	Local aRotina := {	{ STR0003, "PesqBrw"	, 0, 1,,.F.}, 	;	//'Pesquisar'
						{ STR0004, "Apt100Rot"	, 0, 2},		;	//'Visualizar'
						{ STR0005, "Apt100Rot"	, 0, 3},		;	//'Incluir'
						{ STR0006, "Apt100Rot"	, 0, 4},		;	//'Alterar'
						{ STR0007, "Apt100Rot"	, 0, 5,3}		}	//'Excluir'

	Local aOfusca := If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1]Acesso; [2]Ofusca

	If FindFunction("fRhBanConh") .And. aOfusca[2]
		aAdd( aRotina, { STR0098, "fRhBanConh", 0, 4, , .F.})
	Else
		aAdd( aRotina, { STR0098, "MsDocument", 0, 4} )		// "Conhecimento"
	EndIf

	aAdd( aRotina, 	{ STR0114 ,"Apta100Leg" , 0 ,7 ,,.F.} )		// "Legenda"

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Apta100Des     ³ Autor ³ Claudinei Soares      ³ Data ³ 13/05/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao do inicializador padrao dos campos da pericia, se utilizar o³±±
±±³          ³ inicializador no X3 em alguns campos gera inconsistencia.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  	 	 	 	 	 	 	 	 	 	                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Pleitos x Pericias                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Apta100Des	(	cAlias			,;	//01 -> Alias do Arquivo
								aHeader 		,;	//04 -> aHeader utilizado na GetDados
								aCols			;	//05 -> aCols com as informacoes
							)

Local nY:= 0

nPosCpo1 	:= aScan( aHeader , { |x| x[2] == "REH_TIPO"  } )
nPosCpo2 	:= aScan( aHeader , { |x| x[2] == "REH_ASSTEC"} )
nPosCpo3 	:= aScan( aHeader , { |x| x[2] == "REH_RESULT"} )
nPosCpo4 	:= aScan( aHeader , { |x| x[2] == "REH_PERITO"} )
nPosCpo5 	:= aScan( aHeader , { |x| x[2] == "REH_COBS"  } )

nPosDesc1 	:= aScan( aHeader , { |x| x[2] == "REH_TPDESC"} )
nPosDesc2 	:= aScan( aHeader , { |x| x[2] == "REH_ASSNOM"} )
nPosDesc3 	:= aScan( aHeader , { |x| x[2] == "REH_RESDES"} )
nPosDesc4 	:= aScan( aHeader , { |x| x[2] == "REH_PERINO"} )
nPosDesc5 	:= aScan( aHeader , { |x| x[2] == "REH_OBS"   } )

If nPosCpo1 > 0 .OR. nPosCpo2 > 0 .OR. nPosCpo3 > 0 .OR. nPosCpo4 > 0 .OR. nPosCpo5 > 0
	nReg	:= Len(aCols)
  	For nY  := 1 To nReg
		aCols[nY,nPosDesc1] := fDesc("RE5", cAlias + " " + aCols[nY, nPosCpo1], "RE5_DESCR" ) 	//REH_TPDESC
		aCols[nY,nPosDesc2] := fDesc("RD0", aCols[nY, nPosCpo2],"RD0_NOME") 					//REH_ASSNOM
		aCols[nY,nPosDesc3] := fDesc("RE5", "RST"  + " " + aCols[nY, nPosCpo3], "RE5_DESCR" ) 	//REH_RESDES
		aCols[nY,nPosDesc4] := fDesc("RD0", aCols[nY, nPosCpo4],"RD0_NOME") 					//REH_PERINO
		aCols[nY,nPosDesc5] := MSMM(REH->REH_COBS,80,,,,,,,,"RE6")				            //REH_OBS
	Next
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ProcJud_VLD    ³ Autor ³ Emerson Campos        ³ Data ³ 27/08/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de vaidacao conforme definição do Poder Judiciário,         ³±±
±±³          ³ especificado na "Norma ISO 7064:2003", baseado no algoritmo "Modulo³±±
±±³          ³ 97 Base 10" utilizando a FinMod9710(cNum) do programa  FINXFUN.PRX ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  	 	 	 	 	 	 	 	 	 	                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³O padrao unico e:													  ³±±
±±³          ³NNNNNNN-DD.AAAA.J.TR.OOOO											  ³±±
±±³          ³No sistema a entrada nao utiliza pontos ou hifens, ficando assim:   ³±±
±±³          ³NNNNNNNDDAAAAJTROOOO												  ³±±
±±³          ³Sendo:															  ³±±
±±³          ³NNNNNNN - Nro sequencial do processo, a ser reiniciado a cada ano   ³±±
±±³          ³DD	  - digito verificador    									  ³±±
±±³          ³AAAA    - Ano do ajuizamento do processo							  ³±±
±±³          ³J       - Código do orgao ou segmento do poder judiciario           ³±±
±±³          ³TR      - Código do tribunal do respectivo segmento do Poder		  ³±±
±±³          ³          Judiciário. No caso de justica estadual os nros vão de	  ³±±
±±³          ³          1 a 27, correspomdendo a cada estado mais o distrito	  ³±±
±±³          ³          federal, em ordem alfabetica.							  ³±±
±±³          ³OOOO    - Codigo da unidade (foro) de origem dentro do tribunal.	  ³±±
±±³          ³          no caso da Justica estadual, correspondente ao codigo	  ³±±
±±³          ³          do foro de tramitacao do processo. 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet     - Booleano .T. ou .F.								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APTA100                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ProcJud_VLD(cNumProc)
Local lRet		:= .T.
//NAO TEMOS REGRA DEFINITIVA DO LEIAUTE ESOCIAL
//	lRet	:= fValMod97(substr(cNumProc, 1, 7), substr(cNumProc, 8, 2), substr(cNumProc, 10, 4), substr(cNumProc, 14, 3), substr(cNumProc, 17, 4))
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fCalcMod97 ³ Autor ³ Emerson Campos / Mohanad Odeh  ³ Data ³ 28/08/2013  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para calcular e gerar o dígito verificador				       	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cNroSeq  - Nro sequencial do processo  	 	 	 	 	 	 	  		³±±
±±³          ³ cAno     - Ano do ajuizamento do processo					  			³±±
±±³          ³ cCod     - Código do orgao e tribunal do respectivo segmento	  			³±±
±±³          ³ cForo	- Codigo da unidade (foro) de origem 				    		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet     - numero verificador								  			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Pleitos x Pericias                                              			³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fCalcMod97(cNroSeq, cAno, cCod, cForo)
Local cValor1
Local cResto1
Local cValor2
Local cResto2
Local cValor3
Local cRet
cValor1 := fPreenZeros(cNroSeq, 7)
cResto1 := Mod(val(cValor1), 97)
cValor2 := fPreenZeros(cResto1, 2) + fPreenZeros(cAno, 4) + fPreenZeros(cCod, 3)
cResto2 := Mod(Val(cValor2), 97)
cValor3 := fPreenZeros(cResto2, 2) + fPreenZeros(cForo, 4) + "00"

cRet := fPreenZeros(98 - Mod(Val(cValor3), 97), 2)

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fValMod97  ³ Autor ³ Emerson Campos / Mohanad Odeh  ³ Data ³ 28/08/2013  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para Validar o dígito verificador	   						       	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cNroSeq  - Nro sequencial do processo  	 	 	 	 	 	 	  		³±±
±±³          ³ cDigVerif- Código verificador  			 	 	 	 	 	 	  		³±±
±±³          ³ cAno     - Ano do ajuizamento do processo					  			³±±
±±³          ³ cCod     - Código do orgao e tribunal do respectivo segmento	  			³±±
±±³          ³ cForo	- Codigo da unidade (foro) de origem 				    		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet     - Booleano .T. ou .F.								  			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Pleitos x Pericias                                              			³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fValMod97(cNroSeq, cDigVerif, cAno, cCod, cForo)
Local cValor1
Local cResto1
Local cValor2
Local cResto2
Local cValor3
Local lRet
cValor1 := fPreenZeros(cNroSeq, 7)
cResto1 :=  Mod(val(cValor1), 97)
cValor2 := fPreenZeros(cResto1, 2) + fPreenZeros(cAno, 4) + fPreenZeros(cCod, 3)
cResto2 := Mod(val(cValor2), 97)
cValor3 := fPreenZeros(cResto2, 2) + fPreenZeros(cForo, 4) + fPreenZeros(cDigVerif, 2)
lRet :=  Mod(val(cValor3), 97) == 1
If !lRet
	//"Atencao" ## ""A data de nascimento do beneficiario nao foi informada." ## "Esse númewro de processo é essencial no eSocial."      ## "OK"
	Aviso (OemToAnsi(STR0033), OemToAnsi(STR0084)+ CRLF + OemToAnsi(STR0085),{OemToAnsi(STR0086)})
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fValMod97  ³ Autor ³ Emerson Campos / Mohanad Odeh  ³ Data ³ 28/08/2013  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para Validar o dígito verificador	   						       	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nNro  	- Nro a ser testado o seu tamanho 	 	 	 	 	 	  		³±±
±±³          ³ nQuant	- Quantidade de caracteres padrão do nNro 	 	 	 	  		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet     - Nro padrão acrescido de zero até o tamanho padrão	  			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Pleitos x Pericias                                              			³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fPreenZeros(nNro, nQuant)
Local cTemp
Local cRet
If valType(nNro) <> 'N'
	cTemp := AllTrim(nNro)
else
	cTemp := Alltrim(str(nNro))
EndIf

If (nQuant < Len(cTemp))
	cRet := cTemp
Else
	cRet = replicate("0", nQuant - Len(cTemp)) + cTemp
End If
Return cRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fOpcIndDecis³ Autor ³ Emerson Campos        ³ Data ³ 27/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tipo de dependente                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fTpDepBox()		                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/

Function fOpcIndDecis()

Local cOpcBox 	:= ""

If TamSx3("RE0_INDDEC")[1] == 2 //Versao 1.2 eSocial
	cOpcBox += (OemToAnsi(STR0099) + ";") 	//##"01=Liminar em Mandado de Segurança"
	cOpcBox += (OemToAnsi(STR0100) + ";") 	//##"02=Depósito Judicial do Montante Integral"
	cOpcBox += (OemToAnsi(STR0101) + ";") 	//##"03=Depósito Administrativo do Montante Integral"
	cOpcBox += (OemToAnsi(STR0102) + ";") 	//##"04=Antecipação de Tutela"
	cOpcBox += (OemToAnsi(STR0103) + ";") 	//##"05=Liminar em Medida Cautelar"
	cOpcBox += (OemToAnsi(STR0104) + ";") 	//##"08=Decisão Não Transitada em Julgado com Efeito Suspensivo"
	cOpcBox += (OemToAnsi(STR0105) + ";") 	//##"09=Contestação Administrativa FAP"
	cOpcBox += (OemToAnsi(STR0106)		)	//##"10=Definitiva (Transitada em Julgado)"
Else //Versao 1.0 ou 1.1 eSocial
	cOpcBox += ( OemToAnsi(STR0078) + ";"  ) //"1=Definitiva (Transitada em Julgado);"
   	cOpcBox += ( OemToAnsi(STR0079) + ";"  ) //"2=Decisão não Transitada em Julgado com Efeito Suspensivo;"
   	cOpcBox += ( OemToAnsi(STR0080) + ";"  ) //"3=Liminar em Mandado de Segurança;"
   	cOpcBox += ( OemToAnsi(STR0081) + ";"  )	//"4=Lim@inar ou tutela antecipada, em outras espécies de ação judicial;"
   	cOpcBox += ( OemToAnsi(STR0082) + ";"  ) //"5=Contestação Administrativa;"
   	cOpcBox += ( OemToAnsi(STR0083) + ";"  ) //"9=Outros"
EndIf

Return cOpcBox

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fAPT100Dt ³ Autor ³ Glaucia M.		    ³ Data ³ 04/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Validar Datas Processo (RE0)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fAPT100Dt(dData2, nCampo)							 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ dData2 - Data de comparacao com a data do processo         ³±±
±±³          ³ nCampo - Id do documento de verificacao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ APTA100  - Validacao tabela RE0         					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fAPT100Dt(dData2, nCampo)
	Local lRet			:=	.T.
	Local cTitCmp2 	:= ""


	Do Case
		Case nCampo == 1
			cTitCmp2	:= OemToAnsi(STR0089) // "Data de Decisão"
	EndCase


	If (empty(dData2) .OR. dData2 == Ctod("  /  /  ")  .OR. M->RE0_DTPROC >= dData2)
		lRet:= .F.
		Help( ,, 'Help',, cTitCmp2 +" "+OemToAnsi(STR0090), 1, 0 )//" eh invalida, pois eh menor ou igual a Data Processo."
	EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fOpcIndSusp ³ Autor ³ Marcia Moura          ³ Data ³20/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tipo de SUSPENSAO                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fTpDepBox()		                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/

Function fOpcIndSusp()

Local cOpcBox 	:= ""
Local aArea 	:= GetArea()

	cOpcBox += (OemToAnsi(STR0099) + ";") 	//##"01=Liminar em Mandado de Segurança"
	cOpcBox += (OemToAnsi(STR0101) + ";") 	//##"04=Antecipação de Tutela"
	cOpcBox += (OemToAnsi(STR0102) + ";") 	//##"05=Liminar em Medida Cautelar"
	cOpcBox += (OemToAnsi(STR0104) + ";") 	//##"08=Sentença em Mandado de Segurança Favorável ao Contribuinte"
	cOpcBox += (OemToAnsi(STR0105) + ";") 	//##"09=Sentença em Ação Ordinária Favorável ao Contribuinte e Confirmada pelo TRF"
	cOpcBox += (OemToAnsi(STR0106) + ";") 	//##"10=Acordão do TRF Favorável ao Contribuinte"
	cOpcBox += (OemToAnsi(STR0117) + ";") 	//##"11=Acordão do STJ em Recurso Especial Favorável ao Contribuinte"
	cOpcBox += (OemToAnsi(STR0118) + ";") 	//##"12=Acordão do STF em Recurso Extraordinário Favorável ao Contribuinte"
	cOpcBox += (OemToAnsi(STR0119) + ";") 	//##"13=Sentença 1º instância não transitada em julgado com efeito suspensivo"
	cOpcBox += (OemToAnsi(STR0120) + ";") 	//##"14=Contestação Administrativa FAP"
	cOpcBox += (OemToAnsi(STR0121) + ";") 	//##"90=Decisão Definitiva a favor do contribuinte (Transitada em julgado)"
	cOpcBox += (OemToAnsi(STR0123) + ";")	//##"92=Sem suspensão da exigibilidade"

RestArea(aArea)

Return cOpcBox


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³Apt100Vld ³ Autor ³ Renan Borges		    ³ Data ³ 15/10/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ponto de Entrada para Validar os Dados do Cad. Processo    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ APTA100  - Validacao do cadastro de processos              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Apt100Vld(nOpcx)
Local lRet			:=	.T.
Local lAptVld		:= ExistBlock( "APTA100VLD" )
Local lVldRet		:= .F.
Local aProcess	:= {}
Local aDados		:= {}
Local nx

If nOpcx # 5 .And. nOpcx # 2
	If lAptVld
		For nx := 1 to Len(oEnchoice:aGets)
			Aadd(aProcess,{ SubStr(oEnchoice:aGets[nx],9,10) , M->&(SubStr(oEnchoice:aGets[nx],9,10)) })
		Next

		Aadd(aDados,oGetPleitos:aCols)
		Aadd(aDados,oGetPericia:aCols)
		Aadd(aDados,oGetAdvogados:aCols)
		Aadd(aDados,oGetAudiencias:aCols)
		Aadd(aDados,oGetTestemunhas:aCols)
		Aadd(aDados,oGetOcorrencias:aCols)
		Aadd(aDados,oGetSentencas:aCols)
		Aadd(aDados,oGetRescCompl:aCols)
		Aadd(aDados,oGetRecursos:aCols)
		Aadd(aDados,oGetDespesas:aCols)
		Aadd(aDados,oGetBens:aCols)

		If(Valtype(lVldRet := ExecBlock( "APTA100VLD", .F.,.F.,{aClone(aProcess),aClone(aDados)} )) == "L")
			lRet	:= lVldRet
		EndIf
	EndIf
EndIf

Return lRet

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³Apta100Leg   ³Autor³Christiane Vieira     ³ Data ³04/03/2015³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³Apta100Leg()												³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³ 															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³APTA100()	                                                ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function Apta100Leg()

Local aLegenda	:= {}
Local aSvKeys	:= GetKeys()

aLegenda := {;
				{ "BR_VERDE"  , OemToAnsi( STR0115 ) } ,; //"Aberto"
				{ "BR_VERMELHO" , OemToAnsi( STR0116 ) }  ; //"Encerrado"
			}

BrwLegenda(	cCadastro ,	STR0114 , aLegenda )			 //"Legenda do Cadastro de Formulas"

RestKeys( aSvKeys )

Return( NIL )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³Apta100Marks³Autor³Christiane Vieira      ³ Data ³04/03/2015³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³Gpea290Marks()											    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³ 															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³APTA100()	                                                ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Static Function Apta100Marks()

Local aMarks := {}

aMarks	:=	{	                                    	 	 ;
				{ "RE0->RE0_ENCERR=='2'" , "BR_VERDE"	}	,;
				{ "RE0->RE0_ENCERR=='1'" , "BR_VERMELHO"	}	 ;
			 }

Return( aClone( aMarks ) )

Static Function RC1DelOk(  )
Local cIntegra		:= GdFieldGet("RC1_INTEGR")
Local lDelOk 		:= .T.

If cIntegra == "1"
	lDelOk := .F.
	Aviso(STR0033,STR0130, {"OK"})//"Atenção"#"Registro já integrado com financeiro não pode ser excluido"
EndIf

Return( lDelOk )


//-------------------------------------------------------------------
/*/{Protheus.doc} VALIDRE5
VALIDACAO DO CAMPO RC1_TPDESC
@author  GISELE NUNCHERINO
@since   09/06/2020
/*/
//-------------------------------------------------------------------
FUNCTION VALIDRE5(cVal)
LOCAL LRET := .t.

LRET := ExistCpo("RE5","RC1 " + cVal)

RETURN lRet
