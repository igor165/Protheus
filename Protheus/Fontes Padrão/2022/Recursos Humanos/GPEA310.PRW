#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA1310.CH"
#INCLUDE "HEADERGD.CH"

#DEFINE Confirma 1
#DEFINE Redigita 2
#DEFINE Abandona 3

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEA310  ³ Autor ³ R.H. - Natie                    ³ Data ³ 19/06/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Tabelas                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEA310()                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico ( DOS e Windows )                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Chamado/FNC    ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Leandro Dr. ³27/09/12³M12RH01         ³Requisito RHU210 - Unificação das folhas   ³±±
±±³Mohanad Odeh³17/01/13³M12RH01         ³PARAMETROS PARA MANUTENCAO DE TABELAS      ³±±
±±³            ³        ³          RQ3008³Alteracoes no filtro de tabelas e geracao  ³±±
±±³            ³        ³                ³do fonte padrao                            ³±±
±±³Raquel Hager³02/09/14³TQM075			 ³Correcao tela Gp310Sxb.    				 ³±±
±±³Luis Artuso ³31/10/14³          TQSPGW³Ajuste para corrigir errorlog ao cadastrar ³±±
±±³			   ³	    ³          	     ³ uma tabela de usuario.                    ³±±
±±³Marcos Perei³03/09/15³PCREQ-5342      ³Produtizacao projeto Gestão Pública na 12. ³±±
±±³Marcos Perei³11/11/15³PCREQ-5342      ³Tratamento provisorio ColumnPos que devera ³±±
±±³            ³        ³                ³ser retirado qdo liberar dicionario 12.1.8 ³±±
±±³Marcos Perei³07/12/15³PCDEF-86857     ³Ajuste na Gp310aCols para nao gerar erro   ³±±
±±³            ³        ³                ³quando o RCB_MODULO estiver em branco      ³±±
±±ºP. Pompeu...³28/03/2016 ³TUORZT       ³Alterações na Cons. Espec. usando a RCC	 º±±
±±³Gabriel A.  ³26/07/16³TVRLKW          ³Ajuste para preencher as perguntas Agência ³±±
±±³            ³        ³                ³e Conta do pergunte GPEM080.               ³±±
±±³M. Silveira/³16/05/17³DRHPONTP-24     ³Ajuste na GP310SXB para uso especifico na  ³±±
±±³            ³        ³                ³rotina GPEM671.                            ³±±
±±³LuisEnriquez³01/06/17³    MMI-5054    ³Se agrega llamado a funcion GpTABCRG().-MEX³±±
±±³Cecília C.  ³26/07/17³DRHPAG-3640     ³Ajuste para exibir registros da tabela S052³±±
±±³            ³        ³                ³cadastradas sem filial.                    ³±±
±±³Joao Balbino³26/10/17³MPRIMESP-11921  ³Ajuste na consulta padrão das tabelas Snnn ³±±
±±³Isabel N.   ³26/10/17³DRHPAG-7424     ³Ajuste p/consulta da geração do CNAB trazer³±±
±±³            ³        ³                ³registros da S052 pelas filiais informadas.³±±
±±³Moskovkina E³30/10/17³DMA3-23         ³In function GPEA310 cPaisLoc condition was ³±±
±±³            ³        ³                ³extended with "RUS" for Russia localization³±±
±±³Oswaldo L   ³01/12/17³DRHPAG-8855     ³Acerto para permitir selecionar bancos da  ³±±
±±³            ³        ³                ³filial conectada, vide gpem080             ³±±
±±³Nancy G     ³28/12/17³TSSERMI01-237   ³Se agrega localización para permitir que se³±±
±±³            ³        ³                ³muestre la tabla "S033"                    ³±±
±±³Jaqueline L.³231/01/18³DRHPAG-12018   ³Ajuste para trazer os registros da S052    ³±±
±±³            ³        ³                ³quando não estiver filial vinculada na S052³±±
±±³            ³        ³                ³ou nos perguntes.                          ³±±
±±³Julio Silva ³15/02/18³MPRIMESP-13728  ³Ajuste para trazer os registros da S052    ³±±
±±³            ³        ³                ³que não possuem filial informada, quando   ³±±
±±³            ³        ³                ³for informado filial nos perguntes		 ³±±
±±³            ³        ³                ³Filial de/ate, e não possuir S052 para esta³±±
±±³            ³        ³                ³filial que foi informada.					 ³±±
±±³A Rodriguez ³15/02/18³DMINA-446       ³En Gpea310Ger() se agregó validación para  ³±±
±±³            ³        ³                ³gravado si la versión de PRX es mayor a la ³±±
±±³            ³        ³                ³de RCB o si no exitiste registro. Pais:COL ³±±
±±³Eduardo Prz ³13/10/20³DMINA-9807      ³En GP310SXB() se agregó validación para    ³±±
±±³            ³        ³                ³busqueda en consulta estandar de tabla RCC ³±±
±±³            ³        ³                ³cuando no se tenga campos habilitados para ³±±
±±³            ³        ³                ³busqueda en la tabla RCB (oCombo ==NIL)    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function GPEA310()
Local aArea		:= GetArea()
Local aAreaRCB	:= RCB->(GetArea())
Local cVersEnvio	:= ""
Local cVersGPE		:= ""

Private lGestPubl 	:= if(ExistFunc("fUsaGFP"),fUsaGFP(),.f.)	//Verifica se utiliza o modulo de Gestao de Folha Publica - SIGAGFP
Private	cFiltraRCB					//Variavel para filtro
Private	aIndexRCB	:= {}			//Variavel Para Filtro
Private bFiltraBrw 	:= {|| Nil}		//Variavel para Filtro

Private lGpea310Cpy	:= .F.

Private lManutence
Private lAudesp := SuperGetMv('MV_AUDESP',, .F.)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³So Executa se o Modo de Acesso do Cadastro de Mnemonicoa   for³
³Compartilhado												   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

If Gp310ModComp("RCB")

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

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Opcao para gerar o programa com as Tabelas Padroes. Uso Siga ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	lManutence := ( FunName() == "GPEA310M" )

	If lManutence
		aAdd(aRotina, { STR0041 , "Gpe310Alt" , 0 , 8 } ) // "Gerar Tabela"
	Else
		Private lImpTabela	:= .T.
	EndIf

	Private cCadastro := OemToAnsi(STR0001) //"DEFINICAO DE TABELAS"

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Analisar a carga da Definicao de Tabelas                               ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	// Inicializar somente para os paises que utilizam a nova folha - As tabelas do Brasil e do Uruguai serão carregadas de forma diferenciadas
	If cPaisloc $ "ANG/ARG/BOL/COL/MEX/PTG/VEN/HAI/BRA/PER/EQU/URU/DOM/COS/CHI/PAR/RUS"
		If lImpTabela
			GpIniTab()
		EndIf
		GpTABCRG()
	EndIf

	dbSelectArea("RCB")
	dbGotop()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o filtro utilizando a funcao FilBrowse            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFiltraRCB	:=	'RCB_ORDEM == "01"'
	If cPaisLoc == 'BRA' .and. !lManutence

		If FindFunction("fVersEsoc")
			fVersEsoc( "S2200", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, @cVersGPE)
		EndIf
		If Empty(cVersGPE)
			cVersGPE := cVersEnvio
		EndIf
		If cVersGPE < '2.6' 
			cFiltraRCB += ' .and. !(RCB_CODIGO $ "S134")'
		ENDIF
		If cVersGPE < '9.0'
			cFiltraRCB += ' .and. !(RCB_CODIGO $ "S138*S144*S145*S146")'
		EndIf					
		If cVersGPE >= '9.0'
			cFiltraRCB += ' .and. !(RCB_CODIGO $ "S134*S135")'
		EndIf

		//***** Filtro provisorio com ColumnPos -> posteriormente devera retirar este bloco e habilitar o bloco seguinte
		If RCB->( ColumnPos( "RCB_MODULO" ) ) > 0
			If lGestPubl
				cFiltraRCB += ' .and. RCB_MODULO $ "2/3"'
			Else
				cFiltraRCB += ' .and. RCB_MODULO $ " /1/3"'
			EndIf
		Else
			If lGestPubl
				cFiltraRCB += ' .and. !(RCB_CODIGO$"S015/S019/S020/S021/S022/S023/S025/S027/S032/S033/S039/S040/S042/S045/S071/S080") '
			Else
				cFiltraRCB += ' .and. (RCB_CODIGO < "S100" .or. RCB_CODIGO >= "U000") '
			EndIf
		EndIf
		//***** Fim do filtro provisorio

		// Tabela de Integração GUPY
		If GetRPORelease() < "12.1.025"
			cFiltraRCB += ' .and. !(RCB_CODIGO $ "S131/S132/S133")'
		EndIf

		// Tabelas Middleware somente para releases superiores a 12.1.23
		If GetRPORelease() < "12.1.023"
			cFiltraRCB += ' .and. !(RCB_CODIGO $ "S135/S136/")'
		EndIf


		If !lAudesp
			cFiltraRCB += ' .and. !(RCB_CODIGO$"S066/S067/S068/S069'
			If !lGestPubl
				cFiltraRCB += '/S100/S101'
			EndIf
			cFiltraRCB += '/S121/S122/S123/S125")'
		Endif

	EndIf
	cFiltraRh 	:= CHKRH(FunName(),"RCB","1")
	If !Empty(cFiltraRh)
		cFiltraRCB := cFiltraRCB + " .And. " + cFiltraRh
	EndIf


    // Adequação para ignorar a tabela S150 - DRHROTPROT-7119
    // Tabela criada indevidamente
    cFiltraRCB += " .And. " + "RCB_CODIGO <> 'S150'"


	bFiltraBrw 	:= {|| FilBrowse("RCB",@aIndexRCB,@cFiltraRCB) }
	Eval(bFiltraBrw)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	mBrowse(06,01,22,75,'RCB',, , , , , fUseCor() )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta o filtro utilizando a funcao FilBrowse            	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	EndFilBrw("RCB",aIndexRCB)
EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Restaura Area e Ordem de Entrada                              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
RestArea( aArea )
RestArea( aAreaRCB)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ gpe310alt³ Autor ³ R.H - Natie           ³ Data ³ 13/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Alteracao da Estrutura do Parametro                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpN1 := AxAltera(ExpC1,ExpN2,ExpN3,ExpA1,ExpA2)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao devolvida pela funcao                        ³±±
±±³          ³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN2 = Numero do registro                                 ³±±
±±³          ³ ExpN3 = Numero da opcao selecionada                        ³±±
±±³          ³ ExpA1 = Array contendo campos a serem mostrados            ³±±
±±³          ³ ExpA2 = Array limitando campos a serem aceitos com Get     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function gpe310Alt(cAlias, nReg, nOpcx, aAcho, aCpos, nColMens, cMensagem, cTudoOk, lEnable)

//-- Variaveis dimensoes do objeto tela
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aArea			:= GetArea()
Local aAreaRCB		:= RCB->( GetArea() )
Local a310nField	:= {}
Local aColsRec		:= {}  		    		//--Array que contem o Recno() dos registros da aCols
Local aSvCols		:= {}
Local aKeys			:= GetKeys()

Local cProxNum	:= GetMV('MV_PROXNUM')
Local cCond		:= "", cChave:= ""
Local cCodCpy	:= ""					// Codigo a Ser copiado
Local lGpDel	:= If(nOpcx=1,.F.,.T.)
Local nOpca		:= 0

Local oFont
Local oDlgMain
Local bSet15	:= { || NIL }
Local bSet24	:= { || NIL }
Local aCopyTab	:= {}
Local aButtons	:= {}
Local oCbx
Local aSN 		:= {OemToAnsi(STR0064), OemToAnsi(STR0065)}	// "S=SIM" ###  "N=NAO"
Local nCbx 		:= 0

Private cFilRCB		:= CriaVar("RCB_FILIAL")
Private cCodigo		:= CriaVar("RCB_CODIGO")
Private cDescRCB		:= CriaVar("RCB_DESC")
Private cSHOWMA		:= CriaVar("RCB_SHOWMA")
Private cVSHOWMA		:= ""
Private cProces		:= CriaVar("RCB_PROCES")
Private nOpcao 		:= nOpcx
Private nCnt			:= 0
Private lCancel		:= .F.
Private oGeT
Private oCodigo, oDescri
Private oGroup1, oGroup2, oGroup3, oGroup4
Private aColsBkp 	:= {}
Private nBkp

DEFAULT lEnable		:= .T.

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Carrega conteudo das variaveis p/executar EndFilBrw      	   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cFilRCB		:= RCB->RCB_FILIAL
cCodigo		:= If( nOpcx = 3, cCodigo , RCB->RCB_CODIGO )		//-- se Inclusao,  variavel inicia vazia
cDescRCB	:= If( nOpcx = 3, cDescRCB, RCB->RCB_DESC   )
cSHOWMA		:= RCB->RCB_SHOWMA
cVSHOWMA	:= If(RCB->RCB_SHOWMA == "S", OemToAnsi(STR0066),OemToAnsi(STR0067))
cProces		:= If( nOpcx = 3, cProces , RCB->RCB_PROCES )
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Deleta o filtro utilizando a funcao FilBrowse            	   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
EndFilBrw("RCB",aIndexRCB,.T.)
aIndexRCB	:= {}			//Variavel Para Filtro

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 026 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

Do while .T.

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Campos Nao editaveis                                              	 ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	a310nField	:= {"RCB_CODIGO","RCB_DESC", "RCB_SHOWMA","RCB_PROCES"}

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Verifica existencia de registro qdo for alteracao                     ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	dbSelectArea("RCB")
	dbSetOrder(1)
	dbSeek( cFilRCB+cCodigo )
	If !eof()
		cCodCpy := RCB->RCB_CODIGO
	EndIf
	While !eof() .and. cFilRCB + cCodigo = RCB->RCB_FILIAL+RCB->RCB_CODIGO
		nCnt++
		dbSkip()
	Enddo
    If nCnt > 0  .And. nOpcx = 3    		//--Quando Inclusao e existir Registro
		Help(" ",1,"A310REG")
		Exit
	ElseIf nCnt = 0 .And. nOpcx # 3  		//--Quando Nao for Inclusao e nao existir Registro
		Help(" ",1,"A310NREG")
		Exit
	EndIf

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Verifica origem Parametro. Nao permite alt. origem Sistema   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	if ( nOpcx == 8 )
		MsAguarde( { || Gpea310Ger( cAlias , nReg ) } )
		Exit
	ElseIf ( nOpcx = 4 .or. nOpcx = 5 ) .and. !fChkUser() .and. ( !lManutence ) .and. ( !lGpea310Cpy )
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Se for uma Parametro Definido Pela Microsiga Altera a Opcao  ³
		³ para Visualizacao											   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		MsgInfo( oEmToAnsi(STR0015) , oEmToAnsi(STR0014) )
		nOpcx	:= 2
	ElseIf lGpea310Cpy
		nOpcx := 3
	EndIf

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Verifica se as variavel esta sendo utilizada no RCC                    ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If !fUsePar(@nOpcx)
		Exit
	EndIf

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Proximo Numero sequencial do Codigo qdo inclusao                  	 ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If nOpcx == 3
		//-- Pegar e gravar o pr¢ximo numero
		If cProxNum  # Nil
			cProxNum1 := Soma1(cProxNum)
		Else
			Break
		EndIf
		If !( lManutence )
			cCodigo	:=  cProxNum1
		EndIf
	EndIf

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta a entrada de dados do arquivo                          ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	cCond	:= "RCB_FILIAL+RCB_CODIGO"
	If lGpea310Cpy
		nOpcX := 4
		cChave := xFilial("RCB") + cCodCpy
	Else
		cChave	:= xFilial("RCB") + cCodigo
	EndIf
	aHeader	:= gp310aHead(a310nField,cAlias)  								 	// Array contendo header
	aCols	:= gp310aCols(a310nField, cAlias, cCond, cChave, nOpcx, @aColsRec)  // Array contendo aCols
	aSvCols := aClone( aCols )

	If lGpea310Cpy
		nOpcX := 3
	EndIf

	DEFINE FONT oFont  NAME "Arial" SIZE 0,-11 BOLD

	SetaPilha()
	DEFINE MSDIALOG oDlgMain TITLE OemToAnsi( cCadastro ) FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

		@ aObjSize[1,1], aObjSize[1,2] GROUP oGroup1 TO aObjSize[1,3], (aObjSize[1,4]*0,69) LABEL OemToAnsi(STR0011) OF oDlgMain PIXEL	//-"Cod.Tabela"
		oGroup1:oFont:= oFont
		@ aObjSize[1,1], ((aObjSize[1,2])*0,70) GROUP oGroup2 TO aObjSize[1,3], (aObjSize[1,4]*0,487) LABEL OemToAnsi(STR0012) OF oDlgMain PIXEL	//-"Descriçäo"
		oGroup2:oFont:= oFont
		@ aObjSize[1,1], ((aObjSize[1,2])*0,490) GROUP oGroup3 TO aObjSize[1,3], (aObjSize[1,4]*0,560) LABEL OemToAnsi(STR0063) OF oDlgMain PIXEL	//-"Exibe coluna Mes/Ano"
		oGroup3:oFont:= oFont
		@ aObjSize[1,1], ((aObjSize[1,2]*0,570)) GROUP oGroup4 TO aObjSize[1,3], aObjSize[1,4] LABEL OemToAnsi("Processo") OF oDlgMain PIXEL	//-"Processo"
		oGroup4:oFont:= oFont

		If ( lManutence ) .and. nOpcx == 3
			@ aObjSize[1,1]+10, aObjSize[1,2]+10 MSGET cCodigo SIZE 050,10 OF oDlgMain PIXEL FONT oFont PICTURE "@! S999" VALID If( !lCancel, Gpe310Codigo( cCodigo ), .T. )
		Else
			@ aObjSize[1,1]+12, aObjSize[1,2]+10 SAY cCodigo SIZE 050,10 OF oDlgMain PIXEL FONT oFont
		EndIf

		If nOpcx == 3 .OR. nOpcx == 4						 			//Se inclusao ou alteração
			@ aObjSize[1,1]+10, aObjSize[1,2]+76	MSGET cDescRCB SIZE 150,11 OF oDlgMain PIXEL FONT oFont PICT "@!"
		Else
		 	@ aObjSize[1,1]+12, aObjSize[1,2]+76 SAY cDescRCB  SIZE 150,10 OF oDlgMain PIXEL FONT oFont
		EndIf

		If nOpcx == 3 .OR. nOpcx == 4						 			//Se inclusao ou alteracao
			@ aObjSize[1,1]+10, aObjSize[1,2]+497 MSCOMBOBOX oCbx VAR cSHOWMA ITEMS aSN SIZE 030,09 OF oDlgMain PIXEL ON CHANGE nCbx:= GPEA310CBX(oCbx:nAt)
		Else
		 	@ aObjSize[1,1]+12, aObjSize[1,2]+497 SAY cVSHOWMA  SIZE 030,10 OF oDlgMain PIXEL FONT oFont
		EndIf

		If ( lManutence )
			If( nOpcx == 3 .OR. nOpcx == 4 )
				@ aObjSize[1,1]+10, aObjSize[1,2]+570 MSGET cProces SIZE 080,10 OF oDlgMain PIXEL FONT oFont F3 "LOGFOL"
			Else
				@ aObjSize[1,1]+12, aObjSize[1,2]+570 SAY cProces SIZE 080,10 OF oDlgMain PIXEL FONT oFont
			EndIf
		Else
			@ aObjSize[1,1]+12, aObjSize[1,2]+570 SAY cProces SIZE 080,10 OF oDlgMain PIXEL FONT oFont
		EndIf
	   oGet := MSGetDados():New(aObjSize[2,1],aObjSize[2,2],aObjSize[2,3],aObjSize[2,4],nOpcX,"Gp310LinOk","gp310TudOk","+RCB_ORDEM",If(nOpcx=2.Or.nOpcx=5,Nil,.T.),,,,,"Gp310CpoOk")

		bSet15 := { || nOpca := 1, If(oGet:TudoOk() .and. fVLdDesc(cDescRCB), oDlgMain:End(),nOpca:=0)}
		bSet24 := { || oDlgMain:End() }

	ACTIVATE MSDIALOG oDlgMain ON INIT EnchoiceBar(oDlgMain, bSet15 , bSet24 , Nil , aButtons ) CENTERED
	SetaPilha()

	If nOpcA == Redigita
		Exit
	ElseIf nOpcA == Confirma
		If ( nOpcx == 3 .or. nOpcx == 4)
			Begin Transaction
				//--Gravacao
				gp310Grava(cAlias, nOpcx, aColsRec, aSvCols)
				//--Processa Gatilhos
				EvalTrigger()
			End Transaction
			//-- Armazena ultimo numero  no SX6
			If nopcx == 3 .and. !( lManutence )
				PutMV('MV_PROXNUM',"U"+Substr(cCodigo,2))
			EndIf
		ElseIf nOpcx =5
			Begin Transaction
				dbSelectArea( cAlias )
				dbGoto(nReg)
				While !Eof() .And. &cCond == cChave
					RecLock(cAlias,.F.,.T.)
					dbDelete()
					MsUnlock()
					WRITESX2(cAlias,1)
					DbSkip()
				EndDo
			End Transaction
		EndIf
	EndIf
	Exit
Enddo

//--Restaura o Filtro de Browse
Eval(bFiltraBrw)
dbGoTo(nReg)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Restaura Area e Ordem de Entrada                              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
lGpea310Cpy	:= .F.

RestArea( aArea )
RestArea( aAreaRCB )

RestKeys( aKeys,.T. )

Return(Nil)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gpe310Codigo³ Autor ³ Mauricio T. Takakura³ Data ³ 31/01/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do campo Codigo                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gpe310Codigo                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function Gpe310Codigo( cCodigo )

Local lRet := .T.

lRet := NaoVazio() .and. ExistChav("RCB", cCodigo, 1) .and. FreeForUse( "RCB", cCodigo )

Return( lRet )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp310Grava³ Autor ³ Natie                 ³ Data ³ 27/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava no arquivo de Parametros                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gp310Grava                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function gp310Grava(cAlias,nOpcx,aColsRec, aSvCols)

Local ny		:= 0
Local nX		:= 0
Local nMaxArray	:=Len(aHeader)
Local nLin		:= 0
Local aCampo	:= {"RCB_CAMPOS"}
Local nOrdem  	:= 0
Local nTamVersao:= TamSx3("RCB_VERSAO")[1]

nUsado 		:= Len(aHeader)

dbselectArea(cAlias)

// Se alteração atualiza a descrição da tabela
If nOpcx == 4
	For nX:=1 TO Len(aColsRec)
		RCB->( dbGoto(aColsRec[nX]) )
		RCB->( RecLock(cAlias,.F.,.T.) )
		RCB->RCB_DESC		:= Upper(Alltrim(cDescRCB))
		RCB->RCB_SHOWMA	:= cSHOWMA
		RCB->RCB_PROCES := cProces
		RCB->( MsUnlock() )
	Next nX
EndIf

// Verifica se há necessidade de gravar os itens
If fCompArray(aCols, aSvCols) .AND. !lGpea310Cpy
	Return
EndIf

For nX:=1 TO Len(aCols)
	If nX <= Len(aColsRec) .and. nOpcx # 3
		//--Verifica se esta acols esta deletado
		RCB->( dbGoto(aColsRec[nX]) )
		RCB->( RecLock(cAlias,.F.,.T.) )
		If aCols[nX,nUsado+1]  # .F.
	        RCB->( DbDelete() )
	        Loop
		EndIf
	Else
		If aCols[nX,nUsado+1]  = .F.
			RCB->( RecLock(cAlias,.T.,.T.) )
			RCB->RCB_FILIAL := xFilial(cAlias)
			RCB->RCB_CODIGO := cCodigo
			RCB->RCB_DESC   := Upper(Alltrim(cDescRCB))
			RCB->RCB_SHOWMA	:= cSHOWMA
			RCB->RCB_PROCES := cProces
		Else
			Loop
		EndIf
	EndIf
	nOrdem  ++
	For ny := 1 To nMaxArray
		cCampo    := Trim(aHeader[ny][2])
		If cCampo == "RCB_ORDEM"
			xConteudo	:= Strzero(nOrdem ,2)					//-- Faz o Reordenacao da ordem  dos campos nos casos em  que haja delecao de algum  regitro na GetDados
		Else
			xConteudo := aCols[nX,ny]
		EndIf
		If ( ASCAN(aCampo,{|x| x == cCampo }) ) > 0
			xConteudo := StrTran( aCols[nX,ny]," ","" )			//-- Nao permite gravar nome  campo com  espacos
		EndIf

		If ( (ValType(&cCampo) == 'N') .AND. (ValType(aCols[nX,ny]) == 'C') )
			xConteudo	:= Val( aCols[nX,ny] )
		ElseIf ( (ValType(&cCampo) == 'C') .AND. (ValType(aCols[nX,ny]) == 'N') )
			xConteudo	:= AllTrim(Str(aCols[nX,ny]))
		EndIf

		&cCampo 	:= xConteudo
	Next ny

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Alterar a Versao da Tabela - Apenas em Manutencao Gpea300M    ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If ( lManutence )
		RCB->RCB_VERSAO := StrZero(Val(RCB->RCB_VERSAO)+1, nTamVersao)
	EndIf
	RCB->( MsUnlock() )
Next nx

Return

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³Gpea310Cpy³ Autor ³Mauricio T. Takakura   ³ Data ³03/12/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³ Menu para copiar uma Tabela                                ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³Gpea310Cpy( cAlias , nReg , nOpc )							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³cAlias = Alias do arquivo                                   ³
³          ³nReg   = Numero do registro                                 ³
³          ³nOpc   = Numero da opcao selecionada                        ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA310()	                                                ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function Gpea310Cpy( cAlias , nReg , nOpc )

lGpea310Cpy := .T.

Return( Gpe310Alt( cAlias , nReg , 4 ) )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³gp310aHeadºAutor  ³Natie               º Data ³  17/05/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao gp310aHead() - Monta o array de header - SRB        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function gp310aHead(aFields,cAlias)

//Local aExclui  := { 'RCB_CODIGO','RCB_DESC', } 	// Array de exclusao de campos

Private aTELA[0][0],aGETS[0],aHeader[0],nUsado:=0

aHeader := GdMontaHeader( 	NIL			,;	//01 -> Por Referencia contera o numero de campos em Uso
						  	NIL			,;	//02 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Virtuais
						  	NIL			,;	//03 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Visuais
							"RCB"		,;	//04 -> Opcional, Alias do Arquivo Para Montagem do aHeader
							aFields		,;	//05 -> Opcional, Campos que nao Deverao constar no aHeader
							NIL			,;	//06 -> Opcional, Carregar Todos os Campos
							.T.			,;	//07 -> Nao Carrega os Campos Virtuais
							NIL			,;	//08 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
							NIL			,;	//09 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
							.T.			,;	//10 -> Verifica se Deve Checar se o campo eh usado
							.T. 		,;	//11 -> Verifica se Deve Checar o nivel do usuario
							NIL			,;	//12 -> Utiliza Numeracao na GhostCol
							.T.			 ;	//13 -> Carrega os Campos de Usuario
					   )

DbSelectArea( cAlias )
Return aHeader

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp310aCols³ Autor ³ Natie                 ³ Data ³ 21/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Criar os Arrays do aCols dos arquivos                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Gpea310                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Gp310aCols(aFields, cAlias, cCond, cChave, nOpcx, aColsRec)

Local nCntFor := 0
Local nAcols  := 0

nUsado  := Len(aHeader)

//--Quando for Inclusao criar com 1 elemento
Private aCols
If nOpcx = 3                      	//Inclusao
	nCnt := 1
	aCols := Array( nCnt , nUsado+1 )
Else 								//Visualiza Altera
	aCols := {}
EndIf

dbSelectArea(cAlias)

//Se encontrou e  nOpcx # 3  e  (Se Brasil e nao for GPEA310M, verifica o RCB_MODULO de acordo com o tipo de folha em uso)

//*** Voltar este IF quando retirar o provisório ColumnPos
//If dbSeek(cCHAVE) .and. nOpcx # 3 .and. if( cPaisLoc=='BRA' .and. !lManutence, RCB_MODULO $ (if(lGestPubl,"2/3"," /1/3")) , .t. )

//*** Provisório -> deverá ser retirado posteriormente, e voltar o IF acima
If dbSeek(cCHAVE) .and. nOpcx # 3 .and. ;
 if( cPaisLoc=='BRA' .and. !lManutence, If( RCB->( ColumnPos( "RCB_MODULO" ) ) > 0, RCB_MODULO $ (if(lGestPubl,"2/3"," /1/3")), .t.) , .t. )

	While !Eof() .And. &cCond == cChave
		aadd(aCols,Array(nUsado+If(nOpcx#1,1,0)))
		nAcols := Len(aCols)
		For nCntFor := 1 To Len(aHeader)
			If ( aHeader[nCntFor][10] != "V")
				aCols[nAcols][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
			Else
				aCols[nAcols][nCntFor] := CriaVar(aHeader[nCntFor][2],.T.)
			EndIf
		Next nCntFor
		If nOpcx # 1
			aCols[nAcols][nUsado+1] := .F.
		EndIf
		dbSelectArea(cAlias)
		Aadd(aColsRec,Recno())
		dbSkip()
	EndDo
Else
	dbSelectArea("Sx3")
	DbSetOrder(1)
	dbseek(cAlias)
	nUsado:=0
	While !EOF() .And. (x3_arquivo == cAlias)
		If x3uso(x3_usado) .AND. cNivel >= x3_nivel .and. ASCAN(aFields,Trim(x3_campo)) == 0
			nUsado++
			/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  ³ Monta Array do 1§ Elemento Vazio. Se Inclusao                ³
			  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If x3_tipo == "C"
				aCOLS[1][nUsado] := SPACE(x3_tamanho)
			ElseIf x3_tipo == "N"
				aCOLS[1][nUsado] := 0
			ElseIf x3_tipo == "D"
				aCOLS[1][nUsado] := CTOD("  /  /  ")
			Else
				aCOLS[1][nUsado] := .F.
			EndIf
		EndIf
		dbSkip()
	EndDo
	aCOLS[1][nUsado+1] := .F.
EndIf
aCols[1][GdFieldPos("RCB_ORDEM")] := '01'					//-- Inicia Ordem com 1

aColsBkp := Aclone(aCols)
nBkp     := Len(aColsBkp)
Return aCols

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp310CpoOk³ Autor ³ Natie                 ³ Data ³ 21/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Critica cpo digitado                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Gp310CpoOk(o)

Local lCpoOk	:= .T.
Local cVar		:= Alltrim(ReadVar())
Local aNaoValido:={"<",">","%",",","(","/","$","."}			//Array caracteres nao validos para composicao do nome do campo
Local nY

If cVar ="M->RCB_CAMPOS"
	For  nY:= 1 to Len(aNaoValido)
		If 	aNaovalido[nY] $  &cVar
			MsgAlert( OemToAnsi( STR0033 ) , OemToAnsi( STR0014 ) ) 		// caracter invalido na composicao no nome  do campo
			lCpoOk	:= .F.
		EndIf
	Next
EndIf

Return lCpoOk

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp310LinOk³ Autor ³ Natie                 ³ Data ³ 01/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Critica linha digitada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Gp310LinOk(o)

Local nPosTam	:= GdFieldPos("RCB_TAMAN")
Local nPosCpo	:= GdFieldPos("RCB_CAMPOS")
Local nPosTip	:= GdFieldPos("RCB_TIPO")
Local nPosDesc	:= GdFieldPos("RCB_DESCPO")
Local nUsado 	:= Len(aHeader)
Local lLinOk  	:= .T.
Local nTeste	:= aScan(aCols,{|X| X[nPosDesc] == aCols[n][nPosDesc]})

If  !( aCols[n,nUsado+1] )

	If ValType( aCols[n][nPosCpo] ) == 'N'
		aCols[n][nPosCpo]	:=	AllTrim(Str(aCols[n][nPosCpo]))
	EndIf

	If ( (Empty(aCols[n][nPosCpo])) .or. (aCols[n][nPosTam] == 0) )
		If ( Empty(aCols[n][nPosCpo]) )
			MsgAlert( oEmtoAnsi(STR0031),oEmToAnsi(STR0014) )	//--"Nome,tipo e tamanho do campo devem ser informados"
			lLinOk	:= .F.
		Else
			MsgAlert( oEmtoAnsi(STR0016),oEmToAnsi(STR0014) )  //-- "O campo Tamanho deve ter valor maior que zero"
			lLinOk	:= .F.
		EndIf
	Else
		If nTeste <> n
			MsgAlert( oEmtoAnsi(STR0054),oEmToAnsi(STR0014) )	//--"A descrição do campo não pode ser repetida."
			lLinOk	:= .F.
		Endif
	EndIf

	If RCB->( ColumnPos( "RCB_MODULO" ) ) > 0  //Provisório ColumnPos -> retirar posteriormente somente esta linha de if e o seu end
		If cPaisLoc == 'BRA' .and. !lManutence  .and. !(aCols[n][GdFieldPos( "RCB_MODULO" )] $ if(lGestPubl,"2/3","1/3"))
			MsgAlert( oEmtoAnsi(STR0072),oEmToAnsi(STR0014) )	//--"O modulo selecionado não é compatível ao modulo de folha utilizado neste ambiente, conforme o parametro MV_SIGAGFP."
			lLinOk	:= .F.
		EndIf
	EndIf

	fAtualizaBkp1()

	SX3->( DbSelectArea("SX3") )
	SX3->( DbSetOrder(1) )
	If SX3->( DbSeek("RG1") )

		If !(cPaisLoc $ "BRA") .And. !fAlterarOk1()
			aCols[n,nUsado+1] := .F.
			lTudoOk := .F.
			Alert(STR0047)  // ###"Alteração negada. Existe um ou mais lançamentos fixos para esta Tabela, Linha e Coluna."
		EndIf

	EndIf

Else

	DbSelectArea("RCC")
	DbSetOrder(1)
	DbSeek( xFilial("RCB") + cCodigo, .F.)
	If ( RCC->( !Eof() ) ) .and. ( n <= nCnt)
		Help(" ",1,"A310DEL")	// "Existem Registros desta Tabela sendo utilizados." ## "Exclua todos os registros na Manutenção Tabela"
		If !lManutence
			lLinOK := .F.
		EndIf
	EndIf

	fAtualizaBkp1()

	SX3->( DbSelectArea("SX3") )
	SX3->( DbSetOrder(1) )
	If SX3->( DbSeek("RG1") )

		If !(cPaisLoc $ "BRA") .And. !fExcluirOk1()
			aCols[n,nUsado+1] := .F.
			lTudoOk := .F.
			Alert(STR0048)  // ###"Exclusao negada. Existe um ou mais lançamentos fixos para esta Tabela, Linha e Coluna."
		EndIf

	EndIf

EndIf
oGet:oBrowse:nAt := n
oGet:oBrowse:Refresh(.T.)
Return lLinOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³gp310TudoOk³ Autor ³ Natie                ³ Data ³ 25/06/02           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta as getdados dos arquivos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                                        ³±±
±±³          ³ ExpN1 : Registro                                                     ³±±
±±³          ³ ExpN2 : Opcao                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEA160                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Programador ³ Data   ³ BOPS 			 ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Rodrigo L.  ³21/10/10³ 000000236252010³  Inclusão de verificação para não deixar ³±±
±±³            ³        ³      			 ³  criar uma tabela auxiliar, sem ao menos ³±±
±±³            ³        ³                ³  um campo de busca.                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function gp310tudOk(o)

Local aString 	:= {}

Local bBlock:=ErrorBlock(),bErro := ErrorBlock( { |e| ChecErro(e) } )

Local cTipoVar
Local cString
Local cForm			// Conteudo original do Valid
Local cValFun			// Conteudo com funcao especifica. Isola uma funcao para validar a mesma
Local cValResto		// Conteudo que inicia com valor da variavel cForm e elimina as funcoes especificas validadas em cValFun

Local lTudoOk		:= .T.

Local nLin
Local nCol
Local nX			:= 0
Local nTam			:= 0
Local nRegistros	:= 0
Local nUsado		:= Len(AHEADER)
Local nPosCpo		:= GdFieldPos("RCB_CAMPOS")
Local nPosPesq		:= GdFieldPos("RCB_PESQ")
Local nPosValid
Local nPosTipo
Local nPosTam
Local nPosFun		:= 0
Local nPosIni		:= 0
Local uValor
Local lTpBusca      := .F.
Local cTipoMod      := 0

Begin  Sequence

	For nLin := 1 To Len(aCols)
		If aCols[nLin,nUsado+1]  = .T.
			Loop
		EndIf
		cString := ""
		cString += cCodigo+aCols[nLin,nPosCpo]
		If Len(cString) > 0
			Aadd( aString,cString )
		EndIf

		If aCols[nLin,nPosPesq] == "1"
			lTpBusca := .T.
		EndIf

		//Verifica se todos os registros estão com o mesmo modulo de folha
		If cPaisLoc == "BRA" .and. RCB->( ColumnPos( "RCB_MODULO" ) ) > 0  //Provisório ColumnPos -> retirar esta segunda validação
			If nLin == 1
				cTipoMod := aCols[nLin, GdFieldPos( "RCB_MODULO" )]
			EndIf
			If aCols[nLin, GdFieldPos( "RCB_MODULO" )] != cTipoMod
			    lTudoOk := .F.
			    Alert(STR0071)  //-"Todos os registros deverão estar com o mesmo conteúdo no campo Modulo."
			   	Break
			EndIf
		EndIf

	Next

    	If !lTpBusca
		    lTudoOk := .F.
		    Alert(STR0056)  //-"Deve existir pelo menos um campo 'Usado Pesq ?' preenchido como 'Sim' !!!"
		   	Break
		EndIf

	ASORT(aString)
	cString := ""
	//-- verifica se ha chave duplicada
	For nLin := 1 To Len(aString)
		If cString = aString[nLin]
			lTudoOk := .F.
			Help(" ",1,"A310CHADUP")			//-- Chave duplicada
			Break
		EndIf
		cString := aString[nLin]
	Next

	//-- Valida o conteudo do Campo RCB_VALIDA - Validacao

	nPosValid 	:= GdFieldPos( "RCB_VALID" )
	nPosTipo	:= GdFieldPos( "RCB_TIPO" )
	nPosTam		:= GdFieldPos( "RCB_TAMAN" )

	For nLin := 1 To Len(aCols)
		cForm		:= AllTrim(aCols[nLin, nPosValid])
		nPosForm	:= 0
		cValFun	:= ""
		cValResto	:= cForm

		//-- Verifica se existe fc valida no repositorio
		If  !Empty( cForm )

			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Declarar a variavel do campo, para validacoes do Campo Valid  ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			cTipoVar := AllTrim(aCols[nLin, nPosTipo])
			If cTipoVar == "C"
				uValor := "A"
			ElseIf cTipoVar == "N"
				uValor := 1
			ElseIf cTipoVar == "D"
				uValor := CTOD("01/01/2000")
			ElseIf cTipoVar == "L"
				uValor := .T.
			EndIf

			// Atribui o primeiro valor do conjunto para a função PERTENCE()
			If "PERTENCE(" $  UPPER(cForm)
				nPosFun :=	 At("PERTENCE(", UPPER(cForm)) + 10
				nPosIni := At("PERTENCE(", UPPER(cForm))
				uValor := Substr(cForm,nPosFun,1)
                // Inclui campo como segundo parâmetro
				For nX := nPosFun To Len(cForm)

					If Substr(cForm, nX,1) == ")"
						// Quantidade de caracteres a serem eliminados.
						nTam := Len(AllTrim(aCols[nLin, nPosCpo])) + 6 // Os 6 a mais são ", " , "M->" e ")"
						// Substitui conteúdo
						cValFun	:= STUFF(cForm, nX, nTam ,", " + "M->" + AllTrim(aCols[nLin, nPosCpo]) + ")"  )
						cValResto	:= STUFF(cValResto, nPosIni, nTam , Space(Len(cValFun)))
						Exit
					EndIf

				Next nX
				&("M->" + AllTrim(aCols[nLin, nPosCpo])) := uValor
				lTudoOk := CheckExecForm( cValFun, .T. ) // Valida somente a funcao Pertence
			EndIf

		   If "NAOVAZIO" $ UPPER(cValResto)
				nPosIni :=	At("NAOVAZIO", UPPER(cValResto))
				cValFun := STRTRAN(UPPER(cValResto), "NAOVAZIO()", "NAOVAZIO(" + "M->" + AllTrim(aCols[nLin, nPosCpo]) + ")"  )
				cValResto	:= STUFF(cValResto, nPosIni, 10 , Space(Len(cValFun)))
				&("M->" + AllTrim(aCols[nLin, nPosCpo])) := uValor
				lTudoOk := CheckExecForm( cValFun, .T. ) // Valida somente a funcao NAOVAZIO
		   EndIf

		   If "EXISTCPO" $ UPPER(cValResto)
		   EndIf

			&("M->" + AllTrim(aCols[nLin, nPosCpo])) := uValor

			If !Empty(Alltrim(cValResto))
				If SUBSTR(AllTrim(UPPER(cValresto)),1,5) == ".AND."
					cValresto := SUBSTR(cValresto,6,Len(AllTrim(cValResto))-5)
				EndIf
				If SUBSTR(AllTrim(UPPER(cValresto)),1,4) == ".OR."
					cValresto := SUBSTR(cValresto,5,Len(AllTrim(cValResto))-4)
				EndIf
				If SUBSTR(AllTrim(UPPER(cValresto)),Len(AllTrim(cValResto))-5,5) == ".AND."
					cValresto := SUBSTR(cValresto,1,Len(AllTrim(cValResto))-5)
				EndIf
				If SUBSTR(AllTrim(UPPER(cValresto)),Len(AllTrim(cValResto))-4,4) == ".OR."
					cValresto := SUBSTR(cValresto,1,Len(AllTrim(cValResto))-4)
				EndIf
				lTudoOk := CheckExecForm( cValResto, .T. )
			EndIf

			If !lTudoOk
				Break
			EndIf
		EndIf
    Next nLin

End Sequence

Return lTudoOk

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FchoBar310³ Autor ³R.H.-Natie             ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Poe a enchoicebar na tela                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FchoBar310(oDlg,bOk,bCancel,cGrupos,lEnable)

Local lVolta 	:=.f.
Local oBtnCop, oBtnPas,oBtnPrn,oBtnCalc, oBtnHlp
Local oBar, bSet15, bSet24, lOk, oBtOk, oBtCan
Local aCopyTab	:= {}

DEFAULT lEnable		:= .T.

DEFINE BUTTONBAR oBar SIZE 25,25 3D OF oDlg
DEFINE BUTTON oBtnCalc 	RESOURCE "S4WB008N"	OF oBar GROUP	ACTION Calculadora()					TOOLTIP OemToAnsi(STR0022)  //"Calculadora..."
oBtnCalc:cTitle := STR0037 //"Calc"
DEFINE BUTTON 			RESOURCE "S4WB009N"	OF oBar 		ACTION Agenda()							TOOLTIP OemToAnsi(STR0023)  //"Agenda..."
DEFINE BUTTON oBtnPrn	RESOURCE "S4WB010N"	OF oBar 		ACTION OurSpool()						TOOLTIP OemToAnsi(STR0024)  //"Gerenciador de Impressao..."
oBtnPrn:cTitle := STR0038 //"Spool"
DEFINE BUTTON oBtnHlp	RESOURCE "S4WB016N"	OF oBar GROUP	ACTION HelProg()						TOOLTIP OemToAnsi(STR0025)  //"Help de Programa..."
oBtnHlp:cTitle := STR0039 //"Ajuda"

DEFINE BUTTON oBtOk 	RESOURCE "Ok" 		OF oBar GROUP	ACTION ( lLoop:=lVolta,lOk:=Eval(bOk))	TOOLTIP OemToAnsi(STR0026)  //"Ok - <Ctrl-O>"
SetKEY(15,oBtOk:bAction)
oBtOk:cTitle := "Ok"
DEFINE BUTTON oBtCan 	RESOURCE "Cancel" 	OF oBar 		ACTION ( lCancel:=.T.,lLoop:=.f.,Eval(bCancel),ButtonOff(bSet15,bSet24,.T.)) TOOLTIP OemToAnsi(STR0027)  //"Cancelar - <Ctrl-X>"
SetKEY(24,oBtCan:bAction)
oBtCan:cTitle := STR0040 //"Cancelar"

oDlg:bSet15 := oBtOk:bAction
oDlg:bSet24 := oBtCan:bAction

If ( lEnable )
	oBtnCop:Enable()
	If(!Empty(aCopyTab),oBtnPas:Disable(),oBtnPas:Enable() )
Else
	oBtnCop:Disable()
	oBtnPas:Disable()
EndIf

oBar:bRClicked := {|| AllwaysTrue()}
Return nil


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ButtonOff| Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gpea310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ButtonOff(bSet15,bSet24,lOk)
DEFAULT lOk := .t.
If lOk
	SetKey(15,bSet15)
	SetKey(24,bSet24)
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fUseCor   ³ Autor ³ Natie                 ³ Data ³ 01/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Legenda de cores                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fUsecor()

Local aMarks := {}

aMarks	:=	{	                                    	 	 ;
				{ "Substr(RCB->RCB_CODIGO,1,1)=='U'" , "BR_VERDE"	}	,;
				{ "Substr(RCB->RCB_CODIGO,1,1)=='S'" , "BR_AZUL"	}	 ;
			 }

Return( aClone( aMarks ) )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gpe310Leg ³ Autor ³ Natie                 ³ Data ³ 01/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Legenda de Cores                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Gpe310Leg()

Local aLegenda	:= {}

aLegenda := {;
				{ "BR_AZUL"  , OemToAnsi( STR0008 ) } ,; //"Formula Definida Pela Microsiga"
				{ "BR_VERDE" , OemToAnsi( STR0009 ) }  ; //"Formula Definida Pelo Usuario"
			}

BrwLegenda(	cCadastro ,	oEmToAnsi(STR0010) , aLegenda )			 //Legenda do Cadastro de Paramentros

Return( NIL )


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fChkUser  ³ Autor ³ R.H. -  Natie         ³ Data ³ 23/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega as variaveis p/cadastro de Parametros              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fChkUser()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³                                                            ³±±
±±³			 ³                                                            ³±±
±±³			 ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Gen‚rico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fChkUser()

Local lUsuario := If(Substr(cCodigo,1,1) = "U",.T.,.F.)

Return lUsuario

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FchkTaman ³ Autor ³ Natie                 ³ Data ³ 01/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Nao permite que tamanho RCB_CONTEU ultrapase tamanho de 250 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function FChkTaman(nCampo)

Local	nx
Local 	nMaxField	:= 250
Local 	nTamField	:= 0
Local   nUsado 		:= Len(aHeader)
Local   nPosTam		:= GdFieldPos("RCB_TAMAN")
Local   nPosTipo	:= GdFieldPos("RCB_TIPO")
Local   nPosDec 	:= GdFieldPos("RCB_DECIMA")


//-- Valida tipo e tamanho do campo data
If !( ValType(nCampo) == 'N' )
	nCampo	:= Val(nCampo)
EndIf

If aCols[n][nPosTipo]="D" .and. ;
	nCampo  # 8
	MsgInfo( oEmToAnsi(STR0028) , oEmToAnsi(STR0014) )
	aCols[n][nPostam]	:= 8
	aCols[n][nPosdec]	:= 0
	Return .F.
EndIf

//-- Valida tamanho dos campos que serao armazenados no RCC_CONTEU
nAcols:= If( Len(Acols)= 1 ,1, len(aCols)-1 )
For nx:= 1 to naCols
	If aCols[nx][nUsado+1]=.F. .and. (aCols[nx] # aCols[n])
		nTamField 	+=  aCols[nx][nPosTam]
	EndIf
Next nx
nTamField	+= nCampo 			//-- Somatoria do tamanho dos campos
If  nTamField > nMaxField
	//--"Tamanho m ximo de 250 excedido"
	MsgAlert( oEmToAnsi(STR0018),oEmToAnsi(STR0014) )
	Return .F.
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fChkDecima³ Autor ³ Natie                 ³ Data ³ 01/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Critica Campo Decimal                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fChkDecima(nDecimal)

Local nPosTipo	:= GdFieldPos("RCB_TIPO")
Local lCpoOk	:= .T.

If	aCols[n][nPosTipo]	$"DC" .and.  nDecimal > 0 	        			//-- Tipo data e caracter nao devem possuir casa decimal
	MsgAlert( oEmToAnsi(STR0017),oEmToAnsi(STR0014) )
	lCpoOk	:= .F.
EndIf

Return lCpoOK

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fChkTipo  ³ Autor ³ Natie                 ³ Data ³ 01/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function  fChkTipo(cTipo)

Local nPosTam	:= GdFieldPos("RCB_TAMAN")
Local nPosDec 	:= GdFieldPos("RCB_DECIMA")

If 	cTipo == "D"
	aCols[n][nPostam]	:= 8
	aCols[n][nPosdec]	:= 0
ElseIf cTipo == "C"
	aCols[n][nPosdec]	:= 0
EndIf

RETURN .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fUsePar   ³ Autor ³ Natie                 ³ Data ³ 01/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica a existencia de tabela utilizando o parametro     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static function fUsePar(nOpcx)

Local aArea		:= GetArea()
Local aAreaRCB	:= RCB->( GetArea() )
Local lRet		:= .T.	//#Variavel de retorno

DbSelectArea("RCC")
dbSetOrder(1)
DbSeek(xFilial("RCC")+ cCodigo)
If !eof() .and. nOpcx = 5
	/*?
	//-- "Ja existe tabela cadastrada para este estrutura.Sera disponibilizada apenas para visualizacao
	MsgAlert(oEmToAnsi(STR0019),oEmToAnsi(STR0014) )
	nOpcx:= 2
	*/
	//# "Exclusão negada. existe um ou mais lançamentos fixos para esta tabela."
	MsgAlert(oEmToAnsi(STR0048),oEmToAnsi(STR0014))
	lRet := .F.
EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Restaura Area e Ordem de Entrada                              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
RestArea( aArea )
RestArea( aAreaRCB)

Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fVerChav  | Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validar campo chave                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gpea310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function  fVerChav(cAlias,cAuxChave)

Local nPosCpo 	:= GdFieldPos("RCB_CAMPOS")
Local aString	:= {}
Local nLin		:= 0
Local cString	:= ""
Local nUsado	:= Len(aheader)
Local lChaveOk	:= .T.

For nLin := 1 To Len(aCols)
	If aCols[nLin,nUsado+1]  = .T.
		Loop
	EndIf
	cString += cCodigo + aCols[nLin,nPosCpo]
	If Len(cString) > 0 			//-- compara o campo digitado com  o armazenado no aCols
		Aadd(aString,cString)
	EndIf
	cString := ""
Next

If Len(aString) > 0 .and.  ;
   ( Ascan(aString,{|x|cCodigo + cAuxChave == x } ) )  > 0
	Help(" ",1,"A310CHADUP")
	lChaveOk	:= .F.
EndIf

Return lChaveOk

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp310ModComp | Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validar campo chave                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gpea310                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function Gp310ModComp(cAlias)

Local lComp := (FWModeAccess(cAlias, 3) == "C")

If !lComp
	//"O Modo de Acesso ser COMPARTILHADO."
	//"Altere o Modo de Acesso Atraves do Configurador."
	MsgInfo( oEmToAnsi( STR0029 ) + CRLF + oEmToAnsi( STR0030 ) )
EndIf

Return( lComp )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fConsPadra³ Autor ³ Natie                 ³ Data ³ 21/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Seleciona alias na Consulta Padrao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fConsPadra( )

Local cVar		:= Alltrim(ReadVar())
Local cAliasVar	:= ""

//-- Somente para o campo de Consulta padrao
If cVar =="M->RCB_PADRAO"
	cAliasVar	:= M->RCB_PADRAO
	//# fSeleArq(@cAliasVar,.T.)				//-- Retorna Alias escolhido na listbox
	fSeleSxb(@cAliasVar,.T.)				//-- Retorna Alias escolhido na listbox
	M->RCB_PADRAO	:= cAliasVar
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fVLdDesc  ³ Autor ³ Natie                 ³ Data ³ 17/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida Campo Descricao da Tabela                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function  fVLdDesc(cDescRCB)

If Empty(cDescRCB)
	MsgAlert( oemToAnsi(STR0034) ) 						//"Digite o nome da tabela"
	Return(.F.)
EndIf

Return(.T.)

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³Gpea310Ger³ Autor ³Mauricio T. Takakura   ³ Data ³03/12/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³ Gerar o fonte com as tabelas padroes                       ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³Gpea310Ger													³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA310()	                                                ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Static Function Gpea310Ger( cAlias , nReg )

Local aArea			:= GetArea()
Local aRCBMemo		:= {}				// campos memos da tabela RCB
Local aIniHdrRCB						// cabecalho da tabela RCB com os campos
Local aRCBVirtual						// campos virtuais de RCB
Local aLinesProg 	:= {}				// array com as linhas dos programas
Local aLinesFunc 	:= {}			 	// array com as linhas das funcoes dos itens RCB
Local aSelecao		:=	{}				// array para contar registros da selecao da RCB

Local cArquivo 		:= ""			 	// nome do arquivo a ser gerado
Local cPath 		:= ""				// Path a gravar o arquivo
Local cChaveFunc	:= ""				// chave para criacao de uma nova funcao
Local cNameFunc							// nome da funcao
Local cProg								// string a ser enviado ao arquivo PRX
Local cMsg								// mensagem de erro na geracao do arquivo PRX
Local cTexto							// valor do campo do Header
Local cValueCampo						// montagem da string a ser enviado ao array

Local lSetCentury	:= __SetCentury("on")

Local nFuncao		:= 0				// codigo das funcoes
Local nLineMemo							// numero de linhas existentes no campo memo
Local nPosMemo							// posicao do campo memo virtual
Local nUsado							// campos utilizados
Local nArq								// situacao do arquivo
Local nX
Local nY

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Deleta o filtro utilizando a funcao FilBrowse            	   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
/*EndFilBrw("RCB",aIndexRCB,.T.)*/

cArquivo 	:= ( "GPTAB" + cPaisLoc + ".PRX" )

aIniHdrRCB	:= RCB->( GdMontaHeader( @nUsado, @aRCBVirtual, NIL, NIL, NIL, .T. ) )
Begin Sequence
			  								       // mostra drives   mostra hard disk retorna diretorio
	cPath := cGetFile("",OemToAnsi(STR0042),0,,.F.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY) //"Selecione o Diretorio"
	If Empty(cPath)
		Break
	EndIf
	cArquivo := cPath + cArquivo

	If File(cArquivo)
		If !(MsgYesNo( OemToAnsi( STR0043 ),;	// "O Arquivo ja Existe !! Deseja Sobrescrer?"
 		 			   OemToAnsi( STR0014 ) ;	//"Aten‡„o"
					))
			Break
		EndIf
	EndIf

	nArq := MSFCREATE(cArquivo, 0)
	If Ferror() # 0 .And. nArq = -1
		cMsg := STR0044 + STR(Ferror(),3) //-- "Erro de Gravacao do Arquivo - Codigo DOS: "
		MsgInfo( cMsg, STR0014 ) // Atencao
		Return(.F.)
	EndIf

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Cabecalho da funcao                                          ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	aAdd(aLinesProg, '#INCLUDE "PROTHEUS.CH"' + CRLF + CRLF)
	aAdd(aLinesProg, "/*/" + CRLF)
	aAdd(aLinesProg, "ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿" + CRLF)
	aAdd(aLinesProg, "³Fun‡…o    ³GpTab" + cPaisLoc + "      " + "³Autor³ Gerado pelo sistema ³ Data ³" + Substr(DtoS(date()),7,2)+"/"+Substr(DtoS(date()),5,2)+"/"+Substr(DtoS(date()),1,4) + "³" + CRLF)
	aAdd(aLinesProg, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinesProg, "³Descri‡…o ³Definicao das Tabelas                                       ³" + CRLF)
	aAdd(aLinesProg, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinesProg, "³Sintaxe   ³                                                            ³" + CRLF)
	aAdd(aLinesProg, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinesProg, "³Parametros³<Vide Parametros Formais>                                   ³" + CRLF)
	aAdd(aLinesProg, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinesProg, "³ Uso      ³Generico                                                    ³" + CRLF)
	aAdd(aLinesProg, "ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/" + CRLF)
	aAdd(aLinesProg, "Function GpTab" + cPaisLoc + "()" + CRLF + CRLF)
	aAdd(aLinesProg, "Local aRCBHeader	:= {}" + CRLF + CRLF)
	aAdd(aLinesProg, "Local bExecFunc" + CRLF + CRLF)
	aAdd(aLinesProg, 'Local cNameFunc	:= ""' + CRLF)
	aAdd(aLinesProg, "Local lRet	  	:= .T." + CRLF)
	aAdd(aLinesProg, "Local nX 		:= 0" + CRLF)
	aAdd(aLinesProg, "Local cFil  	:= Alltrim(Str(FWGETTAMFILIAL)) " + CRLF + CRLF)


	aAdd(aLinesProg, "/*/" + CRLF)
	aAdd(aLinesProg, "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿" + CRLF)
	aAdd(aLinesProg, "³ Cabecalho de RCB                                             ³" + CRLF)
	aAdd(aLinesProg, "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/" + CRLF)

	For nX := 1 To Len(aIniHdrRCB)
		cProg := ""
		For nY := 1 To Len(aIniHdrRCB[nX])
			cTexto := If(ValType(aIniHdrRCB[nX,nY]) == "N", AllTrim(Str(aIniHdrRCB[nX,nY])),;
						   	If(ValType(aIniHdrRCB[nX,nY])=="L", Transform(aIniHdrRCB[nX, nY],"@!"),;
						   	   aIniHdrRCB[nX, nY]))
			If "_FILIAL" $ aIniHdrRCB[nX][2] .AND. nY == __AHEADER_WIDTH__    // Tratamento para Gestão Corporativa.
				cTexto := "cFil"
				cProg  += cTexto
			Else
				cTexto := StrTran(cTexto, "'", '"')
				cProg  += "'" + cTexto + "'"
			EndIf
			If nY < Len(aIniHdrRCB[nX])
				cProg += ","
			EndIf
		Next nY

		If !Empty(cProg)

			//Quando retirar o ColumnPos para o RCB_MODULO deste fonte, retirar o IF abaixo e descomentar a linha aAdd(aLinesProg,...
			IF cPaisLoc == 'BRA'
				If "_MODULO" $ aIniHdrRCB[nX][2]
					aAdd(aLinesProg, "If RCB->( ColumnPos( 'RCB_MODULO' ) ) > 0" + CRLF)
					aAdd(aLinesProg, "    aAdd(aRCBHeader, " + '{ ' + cProg + ' })' + CRLF)
					aAdd(aLinesProg, "EndIf" + CRLF)
				ElseIf RCB->( ColumnPos( "RCB_MODULO" ) ) == 0 .and. "RCB_ALI_WT" $ aIniHdrRCB[nX][2]
					aAdd(aLinesProg, "If RCB->( ColumnPos( 'RCB_MODULO' ) ) > 0" + CRLF)
					cAux := "'Modulo','RCB_MODULO','@!','1','0','pertence('123')','€€€€€€€€€€€€€€ ','C','      ',' ','1=GPE;2=GFP;3=Ambos                                                                                                             ','','',' ','',' ','.F.'" + ' })'
					cAux := StrTran( cAux, "pertence('123')", 'pertence("123")' )
					aAdd(aLinesProg, "    aAdd(aRCBHeader, " + '{ ' + cAux + CRLF)
					aAdd(aLinesProg, "EndIf" + CRLF)
					aAdd(aLinesProg, "aAdd(aRCBHeader, " + '{ ' + cProg + ' })' + CRLF)
				Else
					aAdd(aLinesProg, "aAdd(aRCBHeader, " + '{ ' + cProg + ' })' + CRLF)
				EndIf
			Else
				aAdd(aLinesProg, "aAdd(aRCBHeader, " + '{ ' + cProg + ' })' + CRLF)
			EndIf
			//Fim do provisorio

//			aAdd(aLinesProg, "aAdd(aRCBHeader, " + '{ ' + cProg + ' })' + CRLF)
		EndIf
	Next nX
	aAdd(aLinesProg, CRLF)

	aAdd(aLinesProg, "/*/" + CRLF)
	aAdd(aLinesProg, "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿" + CRLF)
	aAdd(aLinesProg, "³ Validar a Estrutura das Tabela RCB                            ³" + CRLF)
	aAdd(aLinesProg, "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/" + CRLF)
	aAdd(aLinesProg, 'lRet := fNewOldSx3(aRCBHeader, NIL, "RCB", NIL)' + CRLF + CRLF)

	aAdd(aLinesProg, 'If lRet' + CRLF)

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Cadastro das Tabelas                                         ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	If SELECT("RCB") > 0
		("RCB")->(DBCLOSEAREA()) // -ENCERRA SELECAO ANTERIOR PARA INICIAR OUTRA LIVRE DE FILTROS "INDESEJADOS"
	EndIf
	DBSelectArea("RCB")
	RCB->(dbSetOrder(1)) // "RCB_FILIAL+RCB_CODIGO"
	RCB->(dbGoTop())
	While RCB->(!Eof())

		aAdd(aSelecao,RCB->RCB_CODIGO)

		If Substr( RCB->( RCB_CODIGO ), 1, 1) == "U"
			RCB->( DbSkip() )
			Loop
		EndIf

		If cChaveFunc != RCB->( RCB_FILIAL + RCB_CODIGO )

			// Gerar as chamadas para as funcoes //
			nFuncao++
			cNameFunc := 'Tab' + StrZero( nFuncao,3 )

			aAdd(aLinesFunc, CRLF + CRLF)
			aAdd(aLinesFunc, "/*/" + CRLF)
			aAdd(aLinesFunc, "ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿" + CRLF)
			aAdd(aLinesFunc, "³Fun‡…o    ³"+cNameFunc + "      ³Autor³ Gerado pelo sistema ³ Data ³" + Substr(DtoS(date()),7,2)+"/"+Substr(DtoS(date()),5,2)+"/"+Substr(DtoS(date()),1,4) + "³" + CRLF)
			aAdd(aLinesFunc, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
			aAdd(aLinesFunc, "³Descri‡…o ³Definicao de Tabelas da tabela RCB                        ³" + CRLF)
			aAdd(aLinesFunc, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
			aAdd(aLinesFunc, "³Sintaxe   ³                                                          ³" + CRLF)
			aAdd(aLinesFunc, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
			aAdd(aLinesFunc, "³Parametros³<Vide Parametros Formais>                                 ³" + CRLF)
			aAdd(aLinesFunc, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
			aAdd(aLinesFunc, "³ Uso      ³Generico                                                  ³" + CRLF)
			aAdd(aLinesFunc, "ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/" + CRLF)

			cNameFunc += '( aRCBHeader )'
			aAdd(aLinesFunc, "Static Function " + cNameFunc + CRLF + CRLF)

			aAdd(aLinesFunc, "Local aRCBItens	:= {}" + CRLF + CRLF)
			aAdd(aLinesFunc, "Local cFilRCB		:= xFilial('RCB')" + CRLF)
			aAdd(aLinesFunc, 'Local cVersao		:= ""'  + CRLF)
			aAdd(aLinesFunc, "Local cCliVersao" + CRLF + CRLF)
			aAdd(aLinesFunc, "Local lFound" + CRLF + CRLF)
			aAdd(aLinesFunc, "Local nPosCodigo	:= 0" + CRLF + CRLF)
			aAdd(aLinesFunc, "DEFAULT aRCBHeader	:= {}" + CRLF + CRLF)

		EndIf

		cProg := "aAdd( aRCBItens, { "

		For nX := 1 To Len(aIniHdrRCB)
			cValueCampo := ""

			// campo memo normal //
			If aIniHdrRCB[nX,8] == "M" .and. (aScan(aRCBVirtual, aIniHdrRCB[nX,2]) == 0)
				nLineMemo := MlCount(aIniHdrRCB[nX,2], 80)

				For nY := 1 To nLineMemo
					cValueCampo += AllTrim(MemoLine(aIniHdrRCB[nX,2], 80, nY))
					If nY < nLineMemo
						cValueCampo += ' '
					EndIf
				Next nY

			// campo memo gravado em SYP - Virtual //
			ElseIf aIniHdrRCB[nX,8] == "M" .and. (aScan(aRCBVirtual, aIniHdrRCB[nX,2]) > 0)
				If ((nPosMemo := Ascan(aRCBMemo, { |x|  Upper(x[2]) == aIniHdrRCB[nX,2] })) > 0)
					cValueCampo += MSMM(&(RCB->(aRCBMemo[nPosMemo,1])),80)
					cValueCampo := StrTran(cValueCampo, CRLF, "\13\10")
				EndIf

			ElseIf ( aScan(aRCBVirtual, aIniHdrRCB[nX,2]) > 0 )
				Loop
			ElseIf aIniHdrRCB[nX,8] == "N"
				cValueCampo += AllTrim(Str(&(aIniHdrRCB[nX,2])))
			ElseIf aIniHdrRCB[nX,8] == "D"
				cValueCampo += 'Ctod("' + DtoC(&(aIniHdrRCB[nX,2])) + '")'
			ElseIf aIniHdrRCB[nX,8] == "L"
				If &(aIniHdrRCB[nX,2])
					cValueCampo += ".T."
				Else
					cValueCampo += ".F."
				EndIf
			ElseIf "FILIAL" $ aIniHdrRCB[nX,2]
				cValueCampo += ""
			Else
				cValueCampo += AllTrim(&(aIniHdrRCB[nX,2]))
			EndIf
			cValueCampo := StrTran(cValueCampo, "'", '"')

			If (aIniHdrRCB[nX,8] != "N") .and. (aIniHdrRCB[nX,8] != "D") .and. (aIniHdrRCB[nX,8] != "L")
				cValueCampo := "'" + cValueCampo
				cValueCampo += "'"
			EndIf

			cProg += cValueCampo
			If nX < Len(aIniHdrRCB)
				cProg += ","
			EndIf

		Next nX

		//Quando retirar o ColumnPos para o RCB_MODULO deste fonte, retirar o IF abaixo para pemitir o campo normalmente
		//lembrando de popular novamente na base local o RCB_MODULO conforme o filtro constante ate entao na
		//variavel cFiltraRCB
		IF RCB->( ColumnPos( "RCB_MODULO" ) ) == 0 .and. cPaisLoc == 'BRA'
			If substr(cProg,24,4) $ "S015/S019/S020/S021/S022/S023/S025/S027/S032/S033/S039/S040/S042/S045/S071/S080"
				cProg += "'1',"
			ElseIf substr(cProg,24,4) >= "S100"
				cProg += "'2',"
			Else
				cProg += "'3',"
			EndIf
		EndIf

		cProg += "} )"
		aAdd(aLinesFunc, cProg + CRLF)

		cChaveFunc := RCB->( RCB_FILIAL + RCB_CODIGO)

		RCB->(dbSkip())

		If cChaveFunc != RCB->( RCB_FILIAL + RCB_CODIGO ) .Or. RCB->( Eof() ) .Or. ( Substr(RCB->RCB_CODIGO,1,1) == "U" )

			aAdd(aLinesFunc, CRLF)
			aAdd(aLinesFunc, "nPosCodigo	:= GdFieldPos( 'RCB_CODIGO' , aRCBHeader )" + CRLF)
			aAdd(aLinesFunc, "cVersao		:= aRCBItens[1, GdFieldPos( 'RCB_VERSAO' , aRCBHeader )]" + CRLF + CRLF)
			aAdd(aLinesFunc, 'DbSelectArea("RCB")' + CRLF)
			aAdd(aLinesFunc, "DbSetOrder(1)    // RCB_FILIAL + RCB_CODIGO" + CRLF)
			aAdd(aLinesFunc, "lFound := DbSeek( cFilRCB + aRCBItens[1, nPosCodigo])" + CRLF)
			aAdd(aLinesFunc, "If lFound" + CRLF)
			aAdd(aLinesFunc, "	cCliVersao := RCB->(RCB_VERSAO)" + CRLF)
			aAdd(aLinesFunc, "Else" + CRLF)
			aAdd(aLinesFunc, '	cCliVersao := "__New_Version__"' + CRLF)
			aAdd(aLinesFunc, "EndIf" + CRLF + CRLF)

			aAdd(aLinesFunc, "If cCliVersao != cVersao" + CRLF)
			aAdd(aLinesFunc, "	fGravaTab( aRCBHeader, aRCBItens )" + CRLF )
			aAdd(aLinesFunc, "EndIf" + CRLF + CRLF)

			aAdd(aLinesFunc, 'Return( NIL )')

		EndIf

		If ( Substr(RCB->RCB_CODIGO,1,1) == "U" )
			Exit
		EndIf
	Enddo

	aAdd(aLinesProg, "	For nX := 1 To "  + AllTrim(Str(nFuncao)) + CRLF)
	aAdd(aLinesProg, '		cNameFunc := "{ || Tab" + StrZero(nX, 3) + "( aRCBHeader )" + " }"' + CRLF)
	aAdd(aLinesProg, "		bExecFunc := &cNameFunc" + CRLF)
	aAdd(aLinesProg, "		Eval(bExecFunc)" + CRLF)
	aAdd(aLinesProg, "	Next nX" + CRLF)
	aAdd(aLinesProg, 'EndIf' + CRLF + CRLF )
	aAdd(aLinesProg, 'Return( NIL )' )

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Transferir as linhas para dentro do programa                 ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
    For nX := 1 To Len(aLinesProg)
	    Fwrite( nArq, aLinesProg[nX] )
	Next nX

    For nX := 1 To Len(aLinesFunc)
	    Fwrite( nArq, aLinesFunc[nX] )
	Next nX

	FClose(nArq)
	MsgInfo( STR0045 + cArquivo + CRLF + STR0046 + CRLF + AllTrim(STR(Len(aSelecao))) + " registros gravados" ) // "O Programa " #### "para Cadastro de Definicao Tabelas Padroes foi Gerado com Sucesso"
End Sequence

//--Restaura o Filtro de Browse
Eval(bFiltraBrw)
dbGoTo(nReg)

If !( lSetCentury )
	__SetCentury("off")
EndIf

RestArea( aArea )

Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
			F U N C O E S    U T I L I Z A D A S    P O R    S X 3
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function Gpea310Valid()

Local cCampo 	:= Substr(ReadVar(),4)
Local lRet		:= .T.

If (cCampo == "RCB_TIPO") .Or. (cCampo == "RCB_TAMAN") .Or. (cCampo == "RCB_DECIMA")

	DbSelectArea("RCC")
	DbSetOrder(1)
	DbSeek( xFilial("RCB") + cCodigo, .F.)
	If ( RCC->( !Eof() ) ) .and. ( n <= nCnt)
		Help(" ",1,"A310DEL")	// "Existem Registros desta Tabela sendo utilizados." ## "Exclua todos os registros na Manutenção Tabela"
		If lManutence
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	EndIf
EndIf

Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fAlterarOk1 ³ Autor: Kelly Soares        ³ Data ³ 30.11.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica integridade dos dados da Tabela com o Lancto Fixo.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function fAlterarOk1()

Local nX
Local lOk  := .T.

For nX := 1 to Len(aCols[n])
	If (fTemLanctoFixo( cCodigo , 0 , n+3 , "1" )) .and. (aCols[n,nX] != aColsBkp[n,nX])
		aCols[n,nX] := aColsBkp[n,nX]
		lOk := .F.
	EndIf
Next nX

Return lOk


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fExcluirOk1 ³ Autor: Kelly Soares        ³ Data ³ 30.11.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica integridade dos dados da Tabela com o Lancto Fixo.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function fExcluirOk1()

Local lOk

lOk := !fTemLanctoFixo( cCodigo , 0 , n+3 , "1" )

Return lOk


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fAtualizaBkp1  ³ Autor: Kelly Soares     ³ Data ³ 30.11.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza a array de bkp dp aCols.						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function fAtualizaBkp1()

Local nX

If nBkp < Len(aCols)
	aAdd(aColsBkp , Array(len(aCols[n])))
	For nX := 1 to len(aCols[n])
		aColsBkp[n,nX] := aCols[n,nX]
	Next nX
	nBkp ++
EndIf

Return

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³07/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA310                                                     ³
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
 Local aRotina := { { STR0002   , 'PesqBrw'    , 0 , 1,,.F.},;   	//'Pesquisar'
	  				  { STR0003   , 'Gpe310Alt'    , 0 , 2},;  		//'Visualizar'
					  { STR0004   , 'Gpe310Alt'    , 0 , 3},;  		//'Incluir'
					  { STR0005   , 'Gpe310Alt'    , 0 , 4},;   	//'Alterar'
     				  { STR0006   , 'Gpe310Alt'    , 0 , 5},;  		//'Excluir'
     				  { STR0035   , 'Gpea310Cpy' , 0 , 6},;   		//'Copiar'
     				  { STR0007   , 'Gpe310Leg'   , 0 , 7, ,.F.} }	//'Legenda'

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GP310SXB º Autor ³ Ademar Fernandes   º Data ³  29/10/08             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Exibe Tela de Pesquisa de tabelas do RCC                             º±±
±±º          ³                                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Consulta Padrao Especifica - SXB                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±³Programador ³ Data   ³ BOPS 			 ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Rodrigo L.  ³21/10/10³ 000000236252010³  Verificação para tratar a função        ³±±
±±³            ³        ³      			 ³  GP3100rd() para que não ocorra um erro  ³±±
±±³            ³        ³                ³  quando uma tabela auxiliar não possuir  ³±±
±±³            ³        ³                ³  pelo menos um campo de busca.           ³±±
±±³Cícero Alves³08/09/16³ 				 ³ Incluido o parametro lFilial para determi³±±
±±³            ³        ³      			 ³nar se irá mostrar os registros de todas  ³±±
±±³            ³        ³      			 ³as filiais ou apenas da logada. 			³±±
±±³            ³        ³      			 ³.T. Apenas logada; .F. Todas ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GP310SXB( cTabela, cCpoRet, cFiltro, cCpo2, lFilial )
Local aArea		:= GetArea()
Local nOpca:=0, i,lAllOk
Local oDlg, cCampo, nX, nY, cCaption, cPict, cValid, cF3, cWhen, nLargSay, nLargGet, uConteudo, oSay, oGet
Local cBlkGet,cBlkWhen,cBlkVld, oSaveGetdad := Nil, aSvRot := Nil
Local oTop
Local oBottom
Local oSX1
Local aObject := {}
Local aSize := {}
Local nObject
Local nAuxWidth := 0
Local aCordW := {125,0,450,635}
Local cSvField	:= Iif( !IsInCallStack("GPFLTBLDEXP"), &(ReadVar()), "" )
Local nCount := 0
Local cMyCpo := ""
Local lDelGetD := .F.
Local cLineOk := "AllwaysTrue()"
Local cAllOk  := "AllwaysTrue()"
Local nOpcx	:= 7
Local aCGD	:= {}
Local lExist 	 	:= .F.
Local lGPEM080 		:= IsInCallStack("GPEM080")
Local lGPEM080R2 	:= .T.
Local nCpoRet := 0
Local cPesq := Space(30)
Local nCntCmb := 0
Local nMaxCmb := 5	//# Nr.Maximo de opcoes no Combo
Local nPos 		:= At("+", cCpoRet )
Local cBkpPar04	:= ""
Local cBkpPar05	:= ""
Local cBkpPar06	:= ""
Local cBkpPar07	:= ""
Local cBkpPar08	:= ""
Local cBkpPar09	:= ""
Local cCpoAux	:= ""
Local cRcbCampo	:= ""
Local cRcbDescr	:= ""
Local cRetFiltro:= ""
Local cDescr	:= ""
Private cCombo  := ""
Private aCombo  := {}
Private aMyCombo:= {}
Private aSXBCols   := {}
Private aSXBHeader := {}
Private nUsado  := 0

Private cFilRCB  := ""
Private cFilRCC  := ""
Private cDescRCC := ""
Private lPesqComp := .F. //Variavel que indica se a pesquisa esta sendo feita com mais de um campo

Default cFiltro := ""
Default cCpo2	:= ""
Default lFilial	:= .T.

If cTabela == NIL .Or. cCpoRet == NIL
	MsgAlert(OemToAnsi(STR0049),OemToAnsi(STR0014))	// "Não é possível continuar pois faltam parametros nesta função !!!"##"Atenção !"
	Return(.F.)
EndIf

If nPos > 0
	lPesqComp := .T.
EndIf

//# Posiciona no RCB
dbSelectArea("RCB")
dbSetOrder(1)

If !dbSeek(xFilial("RCB")+cTabela,.F.)
	MsgAlert(OemToAnsi(STR0050),OemToAnsi(STR0014))	// "A Tabela informada não existe !!!"##"Atenção !"
	Return(.F.)
EndIf

cFilRCB  := xFilial("RCB")
cDescRCC := Alltrim(RCB_DESC)

//# Posiciona no RCC
dbSelectArea("RCC")
dbSetOrder(1)

If !ExistRTab(cTabela)//!dbSeek(xFilial("RCC")+cTabela,.F.)
	MsgAlert(OemToAnsi(STR0051) + cTabela,OemToAnsi(STR0014) )	// "Não existe informações cadastradas na tabela "##"Atenção !"
	Return(.F.)
EndIf

//-- Verifica se foi chamado pela função GPEM080 e filtra os resultados pelos parametros informados na rotina
If lGPEM080
	oSX1 := FWSX1Util():New()
	oSX1:AddGroup("GPEM080R2")
	oSX1:SearchGroup()
	If (Len(oSX1:aGrupo) >= 1 .And. Len(oSX1:aGrupo[1][2]) >= 1)
		lGPEM080R2 	:= .T.
		cBkpPar04	:= MV_PAR04
		cBkpPar05	:= MV_PAR05
		cBkpPar06	:= MV_PAR06
		cBkpPar07	:= MV_PAR07
		cBkpPar08	:= MV_PAR08
		cBkpPar09	:= MV_PAR09
		MakeAdvplExpr("GPEM080R2")
		MV_PAR04 	:= StrTran( MV_PAR04, "RA_FILIAL", "RCC_FIL" )
	EndIf

	dbSelectArea("RCC")
	dbSetOrder(1)
	RCC->(dbSeek(xFilial( "RCC" ) + cTabela))

	While !RCC->(Eof()) .And. (RCC->RCC_FILIAL + RCC->RCC_CODIGO == xFilial( "RCC" ) + cTabela)

		If !Empty(RCC->RCC_FIL) .And. ( (!lGPEM080R2 .And. RCC->RCC_FIL >= MV_PAR04 .AND. RCC->RCC_FIL <= MV_PAR05) .Or. ( lGPEM080R2 .And. (Empty(MV_PAR04) .Or. &(MV_PAR04)) ) )
			If !lGPEM080R2
				cFiltro := {|| (RCC->RCC_FIL >= MV_PAR04 .AND. RCC->RCC_FIL <= MV_PAR05)  }
			Else
				If Empty(MV_PAR04)
					cFiltro := { || !Empty(RCC->RCC_FIL) }
				Else
					cFiltro := { || &(MV_PAR04) }				
				EndIf
			EndIf
			Exit
		Else
			cFiltro := {|| (Empty(RCC->RCC_FIL))  }
		EndIf
		RCC->(DbSkip())
	EndDo
	lFilial	:= .F.
EndIf

cFilRCC := xFilial("RCC")

fMontaHeaderRCC( cTabela, cCpoRet )
MontaColsRCC( cTabela, cCpoRet, Nil, cFiltro, lFilial, lGPEM080, lGPEM080R2 )

//# Variaveis inicializadas no teste
Private cTitulo := cTabela+" - "+cDescRCC //#"U014 - Teste"
Private nMax := Len(aSXBCols)
Private aC := {}
Private aColsBkp := aClone(aSXBCols)

//# Variaveis inicializadas no teste
aAdd(aC,{"cMyCpo", {15,001},"",,,,.F.,})

nCount++
__cLineOk := cLineOK
__nOpcx	 := nOpcx
If nCount > 1
	oSaveGetdad := oGetDados
	oSaveGetdad:oBrowse:lDisablePaint := .t.
EndIf

oGets := {}
If Type("aRotina") == "A"
	aSvRot := aClone(aRotina)
EndIf

aRotina := {}
For nX := 1 to nOpcX
	AADD(aRotina,{"","",0,nOpcx})
Next

aCGD:=Iif(Len(aCGD)==0,{34,5,128,315},aCGD)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitulo) FROM aCordW[1],aCordW[2] TO aCordW[3],aCordW[4] PIXEL OF oMainWnd

If Len(aC) > 0

	//# Monta o Combo a partir do Titulo do RCB
	dbSelectArea("RCB")
	dbSeek(xFilial("RCB")+cTabela,.F.)

	While !Eof() .And. RCB->(RCB_FILIAL+RCB_CODIGO) == (cFilRCB+cTabela)

		//# Verifica se o campo ja existe
		If !lExist .And. ValType("RCB->RCB_PESQ")<>"U"
			lExist := .T.
		EndIf

		//# Monta o aCombo e aMyCombo
		If !lExist .Or. (lExist .And. RCB->RCB_PESQ=="1")
			nCntCmb += 1
			aAdd( aCombo	, Alltrim(Capital(RCB_DESCPO)) )
			aAdd( aMyCombo, {Alltrim(Capital(RCB_DESCPO)),Alltrim(RCB_CAMPOS)} )
			If lPesqComp .And. At(Alltrim(RCB_CAMPOS), cCpoRet) > 0
				cRcbDescr += Alltrim(Substr(Capital(RCB_DESCPO),1,9)) + '+'
				cRcbCampo += Alltrim(RCB_CAMPOS) + '+'
			EndIf
			If nCntCmb >= nMaxCmb
				Exit
			EndIf
		EndIf
		dbSkip()
	EndDo
	If lPesqComp
		cRcbDescr := Substr(cRcbDescr, 1, Len(cRcbDescr)-1)
		cRcbCampo := Substr(cRcbCampo, 1, Len(cRcbCampo)-1)
		nCntCmb += 1
		aAdd( aCombo, Alltrim(cRcbDescr) )
		aAdd( aMyCombo, {Alltrim(cRcbDescr),Alltrim(cRcbCampo)} )
	EndIf

	dbSelectArea("RCC")

	oTop:= TPanel():Create(oDlg,01,102,"",,.F.,,,,100,100)

	Aadd(aSize,aCGD[1]+16)
	Aadd(aObject,oTop)
	nObject := 2

	Private oCombo, oPesq, oBtn1, oCheckBox, lCheck

	@ 003,005 SAY OemToAnsi(STR0052) SIZE 35,10 OF oTop PIXEL	// "Pesquisar por: "
	@ 010,005 MSCOMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 125,12 OF oTop PIXEL
	@ 010,140 CHECKBOX oCheckBox VAR lCheck PROMPT OemToAnsi(STR0053) VALID Iif(!Empty(cCombo),GP310Ord(),fValPesq()) SIZE 55,10 OF oTop PIXEL	// "Ordenar"
	@ 010,180 MSGET oPesq VAR cPesq PICTURE "@!" VALID Iif(!Empty(cCombo),PesqDados(cPesq),fValPesq()) SIZE 115,10 OF oTop PIXEL
	@ 021,585 BTNBMP oBtn1 RESOURCE "FWSKIN_ICON_LOOKUP" SIZE 025,025 OF oTop PIXEL ACTION ( iif(Empty(aCombo),MsgAlert(OemToAnsi(STR0073)),PesqDados(cPesq)))

	For i:=1 to Len(aC)
		cCampo:=aC[i,1]
		nX:=aC[i,2,1]-13
		nY:=aC[i,2,2]
		cCaption:=Iif(Empty(aC[i,3])," ",aC[i,3])
		cPict:=Iif(Empty(aC[i,4]),Nil,aC[i,4])
		cValid:=Iif(Empty(aC[i,5]),".t.",aC[i,5])
		cF3:=Iif(Empty(aC[i,6]),NIL,aC[i,6])
		cWhen    := Iif(aC[i,7]==NIL,".t.",Iif(aC[i,7],".t.",".f."))
		cWhen    := Iif(!(Str(nOpcx,1,0)$"346"),".f.",cWhen)
		cBlKSay  := "{|| OemToAnsi('"+cCaption+"')}"

		oSay     := TSay():New( nX+1, nY, &cBlkSay,oTop,,, .F., .F., .F., .T.,,,,, .F., .F., .F., .F., .F. )
		nLargSay := GetTextWidth(0,cCaption) / 1.8  // estava 2.2
		cCaption := oSay:cCaption

		cBlkGet  := "{ | u | If( PCount() == 0, "+cCampo+","+cCampo+":= u ) }"
		cBlKVld  := "{|| "+cValid+"}"
		cBlKWhen := "{|| "+cWhen+"}"

		oGet := TGet():New( nX, nY+nLargSay,&cBlKGet,oTop,,,cPict, &(cBlkVld),,,, .F.,, .T.,, .F., &(cBlkWhen), .F., .F.,, .F., .F. ,cF3,(cCampo))
		AADD(oGets,oGet)
	Next
EndIf

oGetDados := MsNewGetDados():New(aCGD[1],;// nTop
								 aCGD[2],;   	// nLelft
								 aCGD[3],;	// nBottom
	                             aCGD[4],;	// nRright
								 nOPCX,;	    	// controle do que podera ser realizado na GetDado - nstyle
								 "SXBMod2LOk()",;	// funcao para validar a edicao da linha - ulinhaOK
								 "AllwaysTrue()",;	// funcao para validar todas os registros da GetDados - uTudoOK
  								 NIL,;				// cIniCPOS
								 NIL,;		        // aAlter
								 0,; 				// nfreeze
								 nMax,;  			// nMax
								 NIL,;		 		// cFieldOK
								 NIL,;				// usuperdel
								 .F.,;	        	// udelOK
								 @oDlg,;        	// objeto de dialogo - oWnd
								 @aSXBHeader,;		// Vetor com Colunas - AparHeader
								 @aSXBCols;			// Vetor com Header - AparCols
					)

Aadd(aObject,oGetDados:oBrowse)
Aadd(aSize,NIL)

ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,lAllOk:=__Mod2OK(cAllOk),;
											 IIF(lAllOk,oDlg:End(),nOpca:=0)},{||oDlg:End()},,),;
											 AlignObject(oDlg,aObject,1,nObject,aSize),oGetDados:oBrowse:Refresh())

nCount--
If nCount > 0
	oGetDados := oSaveGetDad
	oGetDados:oBrowse:lDisablePaint := .f.
EndIf
If ValType(aSvRot) == "A"
	aRotina := aClone(aSvRot)
EndIf

If lGPEM080 .And. lGPEM080R2
	MV_PAR04 := cBkpPar04
	MV_PAR05 := cBkpPar05
	MV_PAR06 := cBkpPar06
	MV_PAR07 := cBkpPar07
	MV_PAR08 := cBkpPar08
	MV_PAR09 := cBkpPar09
EndIf

If nOpca == 1 .and. Len(aSXBCols)>0
	If !lPesqComp
		nCpoRet := GdFieldPos(cCpoRet, aSXBHeader)
		VAR_IXB  := aSXBCols[oGetDados:nAt,nCpoRet]

		If !Empty(cCpo2)
			Var_IXB := {}
			aadd(VAR_IXB,aSXBCols[oGetDados:nAt,nCpoRet])
			nCpoRet := GdFieldPos(cCpo2, aSXBHeader)
			cDescr := aSXBCols[oGetDados:nAt,nCpoRet]
			aadd(VAR_IXB,cDescr)
		EndIf
		If Funname() == 'GPEA320' .OR. Funname() == 'GPEM671'
			&(ReadVar()) := VAR_IXB
		EndIf

		If lGPEM080
			If !lGPEM080R2
				MV_PAR31 := aSXBCols[oGetDados:nAt, nCpoRet + 1 ]
				MV_PAR32 := aSXBCols[oGetDados:nAt, nCpoRet + 3 ]
			Else
				MV_PAR25 := aSXBCols[oGetDados:nAt, nCpoRet + 1 ]
				MV_PAR26 := aSXBCols[oGetDados:nAt, nCpoRet + 3 ]
			EndIf
		EndIf
	Else
		VAR_IXB := ""
		While lPesqComp
			cCpoAux := Substr(cCpoRet, 1, nPos - 1)
			cCpoRet := Substr(cCpoRet, nPos +1)

			nCpoRet := GdFieldPos(cCpoAux, aSXBHeader)
			VAR_IXB += aSXBCols[oGetDados:nAt,nCpoRet]

			nPos := At("+", cCpoRet )
			lPesqComp := If (nPos > 0, .T., .F.)

			If nPos == 0
				nCpoRet := GdFieldPos(cCpoRet, aSXBHeader)
				VAR_IXB += aSXBCols[oGetDados:nAt,nCpoRet]
			EndIf
		EndDo

		If Funname() == 'GPEA320' .OR. Funname() == 'GPEM671'
			&(ReadVar()) := VAR_IXB
		EndIf

		If !Empty(cCpo2)
			cDescr := VAR_IXB
			Var_IXB := {}
			aadd(VAR_IXB,cDescr)
			nCpoRet := GdFieldPos(cCpo2, aSXBHeader)
			cDescr := aSXBCols[oGetDados:nAt,nCpoRet]
			aadd(VAR_IXB,cDescr)
		EndIf
	EndIf
Else
	If !Empty(cCpo2)
		Var_IXB := {}
		aadd(VAR_IXB,cSvField)
		aadd(VAR_IXB,"")
	Else
		VAR_IXB := cSvField
	EndIf
	RestArea(aArea)
	Return .T.
EndIf

RestArea( aArea )

Return(nOpca == 1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          º Autor ³ Ademar Fernandes   º Data ³  31/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ordena o aCols de acordo com o ComboBox escolhido pelo usu-º±±
±±º          ³ ario, isso se o CheckBos for marcado                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GP310SXB                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GP310Ord()
Local nCmbLin := aScan( aMyCombo, { |x| Alltrim(x[01]) == Alltrim(cCombo)} )
Local nPosCpo := 0
nPosCpo := GdFieldPos(aMyCombo[nCmbLin,02],aSXBHEADER)

If lCheck
	ASort(@aSXBCols,,,{|x,y| x[nPosCpo] < y[nPosCpo]})
	oGetDados:aCols := aClone(aSXBCols)
Else
	aSXBCols := aClone(aColsBkp)
EndIf
oGetDados:oBrowse:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SXBMod2LOkº Autor ³Equipe RH           º Data ³  18/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³										                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SXBMod2LOk()
Local lRet:=.t. , ni
If Str(__nOpcx,1,0)$"346"
	lRet := &__cLineOK
	For ni:= 1 to Len(oGets)
		oGets[ni]:Refresh()
	Next
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³__Mod2Ok  º Autor ³Equipe RH           º Data ³  18/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³										                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function __Mod2Ok(cAllOK)
Local lRet
lRet := SXBMod2LOk()
If lRet
	lRet := &cAllOk
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MontaRCCHeaderº Autor ³ Emerson Campos     º Data ³ 01/12/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Encapsulamento da funcao MontaHeader da Tela de Pesquisa       º±±
±±º          ³ de tabelas do RCC para utilizacao geral                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Geral                                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cTabela                                                        º±±
±±º          ³ cPesqComp                                                      º±±
±±º          ³ lPsqComp - Variavel que indica se a pesq esta sendo feita      º±±
±±º          ³            com mais de um campo                                º±±
±±º          ³                                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MontaRCCHeader(cTabela, cPesqComp, lPsqComp)
Private cFilRCB  := xFilial("RCB")

	_SetOwnerPrvt(	"aSXBHeader" 	, {} )
	_SetOwnerPrvt(	"lPesqComp" 	, lPsqComp )
	_SetOwnerPrvt(	"nUsado" 	, 0 )
	RCB->( dbSeek(cFilRCB+cTabela) )
	fMontaHeaderRCC(cTabela, cPesqComp)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          º Autor ³ Ademar Fernandes   º Data ³  30/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Monta o aHeader da Tela de Pesquisa de tabelas do RCC      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GP310SXB                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fMontaHeaderRCC(cTabela, cPesqComp)
Local aArea			:= GetArea()
Local nQtdCol		:= 99
Local nTamAux		:= 0
Local cTitSeq		:= ""
Default cPesqComp	:= ""

dbSelectArea("RCB")

nUsado:=0
aSXBHeader:={}

cTitSeq	:= fDesSeq()

//# Cria campo RCC_SEQUEN
nUsado += 1
aAdd(aSXBHeader,{ 	cTitSeq, ;		//# 01
				"RCC_SEQUEN", ;	//# 02
				"@!", ;			//# 03
				3, ;			//# 04
				0, ;			//# 05
				NIL, ;			//# 06
				NIL, ;			//# 07
				"C", ;			//# 08
				NIL,  ;	     	//# 09
				"R" } )			//# 10 Real ou Virtual

While !Eof() .And. RCB->(RCB_FILIAL+RCB_CODIGO) == (cFilRCB+cTabela)
						//Alltrim(RCB_VALID), ;			//# 06
	If nUsado > nQtdCol
		Exit
	Else
		nUsado += 1
		aAdd(aSXBHeader,{Alltrim(Capital(RCB_DESCPO)), ;	//# 01
						Alltrim(RCB_CAMPOS), ;			//# 02
						Alltrim(RCB_PICTUR), ;			//# 03
						RCB_TAMAN, ;					//# 04
						RCB_DECIMA, ;					//# 05
						NIL, ;							//# 06
						NIL, ;							//# 07
						RCB_TIPO, ;						//# 08
						NIL, ;		    				//# 09
						"R", ;							//# 10 Real ou Virtual
 						NIL, ;							//# 11 cbox
						NIL, ;							//# 12 relacao
						NIL, ;							//# 13 when
						"V" ;							//# 14 visual ou altera
						} )
		If lPesqComp .And. At(Alltrim(RCB_CAMPOS), cPesqComp) > 0
			nTamAux += RCB_TAMAN
		EndIf
	EndIf
	dbSkip()
EndDo
If lPesqComp
	nUsado += 1
	aAdd(aSXBHeader,{Alltrim(Capital(RCB_DESCPO)), ;	//# 01
					Alltrim(cPesqComp), ;			//# 02
					"!@", 				;			//# 03
					nTamAux, ;						//# 04
					NIL, ;							//# 05
					NIL, ;							//# 06
					NIL, ;							//# 07
					NIL, ;							//# 08
					NIL, ;		    				//# 09
					"V", ;							//# 10 Real ou Virtual
					NIL, ;							//# 11 cbox
					NIL, ;							//# 12 relacao
					NIL, ;							//# 13 when
					"V" ;							//# 14 visual ou altera
					} )
EndIf

RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MontaRCCColsº Autor ³ Emerson Campos     º Data ³ 01/12/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Encapsulamento da função MontaCols da Tela de Pesquisa       º±±
±±º          ³ de tabelas do RCC para utilização geral                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Geral                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MontaRCCCols( cTabela, cCpoPesq )
Private aSXBCols := {}
Private cFilRCC  := xFilial("RCC")

	RCC->( dbSeek(cFilRCC+cTabela) )
	MontaColsRCC(cTabela, cCpoPesq, Nil, Nil)
	aCloSXBCols := aClone( aSXBCols )

Return aCloSXBCols

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          º Autor ³ Ademar Fernandes   º Data ³  30/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Monta o aCols da Tela de Pesquisa de tabelas do RCC        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GP310SXB                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MontaColsRCC( cTabela, cCpoPesq, cCpoFiltro, cFiltro, lFilial, lGPEM080, lGPEM080R2 )

	Local aArea			:= GetArea()
	Local nCnt			:= 0
	Local nQtdLin		:= 7000
	Local uValor
	Local cFOrigem		:= ""
	Local cRCCAlias		:= GetNextAlias()
	Local nPos			:= 0
	Local lAdd			:= .T.
	Local nCpoKey		:= 1
	Local nCpoKey2		:= 0
	Local nPosKey		:= 0

	Default cCpoPesq	:= ""
	Default cFiltro		:= ""
	Default cCpoFiltro	:= ""
	Default lFilial		:= .T.
	Default lGPEM080	:= .F.
	Default lGPEM080R2	:= .F.

	aSXBCols := {}

	If __READVAR == "M->CODFOR"			//CONSULTA F3 A PARTIR DE UMA TABELA SNNN
		cFOrigem := aCols[n][1]
	ElseIf cPaisloc == "MEX"
		cFOrigem := xFilial( "RCC" )
	Else
		cFOrigem := cFilAnt
	EndIf

	nCont := 0
	nCpo1 := 1
	nCpo2 := 0

	If cTabela == "S043" .And. !Empty(cCpoPesq)
		For nCnt := 1 to Len(aSXBHeader)
			If Alltrim(aSXBHeader[nCnt,02]) != "RCC_SEQUEN"
				nCpoKey2 := (aSXBHeader[nCnt,04] )
				If Upper(Alltrim(aSXBHeader[nCnt,02])) == Upper(cCpoPesq)
					nPosKey := nCnt
					Exit
				Else
					nCpoKey += nCpoKey2
				EndIf
			EndIf
	    Next nCnt
	EndIf

	dbSelectArea( "RCC" )
	RCC->(dbSetOrder(1))	// RCC_FILIAL + RCC_CODIGO + RCC_FIL + RCC_CHAVE  + RCC_SEQUEN

	// Posiciona pela tabela, tratamento de filial já é feito dentro do laço
	RCC->( dbSeek( xFilial( "RCC" ) + cTabela  ) )

	BeginSql Alias cRCCAlias
		SELECT RCC.* FROM %table:RCC% RCC
		WHERE RCC.RCC_CODIGO = %Exp:(cTabela)% AND RCC.%NotDel% AND RCC.RCC_FILIAL = %Exp:(xFilial("RCC"))%
		AND RCC.RCC_FIL <> %exp:Space(Tamsx3("RCC_FILIAL")[1])%
		UNION
		SELECT RCC.* FROM %table:RCC% RCC
		WHERE RCC.RCC_CODIGO = %Exp:(cTabela)% AND RCC.%NotDel% AND RCC.RCC_FILIAL = %Exp:(xFilial("RCC"))%
		AND RCC.RCC_FIL = %exp:Space(Tamsx3("RCC_FILIAL")[1])%
	EndSql

	While ! Eof() .And. (cRCCAlias)->(RCC_CODIGO) == cTabela

		If (cRCCAlias)->(RCC_FIL) == cFOrigem .or. Empty((cRCCAlias)->(RCC_FIL)) .Or.;
		(lGPEM080 .And. ( ( !lGPEM080R2 .And. (cRCCAlias)->(RCC_FIL) >= MV_PAR04 .AND. (cRCCAlias)->(RCC_FIL) <= MV_PAR05) .Or. (lGPEM080R2 .And. (Empty(MV_PAR04) .Or. &(MV_PAR04)) ) ) )
			RCC->(DbGoto( (cRCCAlias)->(R_E_C_N_O_) ))

			If Empty( cFiltro ) .Or. Eval( cFiltro )
				lAdd := .T.
				If cTabela == "S043" .And. !Empty(cCpoPesq)
					If Ascan(aSXBCols,{|x| x[nPosKey] == SubStr( RCC_CONTEU, nCpoKey, nCpoKey2 )}) > 0
						lAdd := .F.
					EndIf
				EndIf

				If lAdd
					AADD(aSXBCols,Array(Len(aSXBHeader)+1))

					For nCnt := 1 To Len(aSXBHeader)

						cCampo := Alltrim(aSXBHeader[nCnt,02])

						If aSXBHeader[nCnt,10] == "R" .And. cCampo == "RCC_SEQUEN"
							aSXBCols[Len(aSXBCols)][nCnt] := FieldGet(FieldPos(cCampo))
						ElseIf lPesqComp .And. At("+", cCampo) > 0
							aSXBCols[Len(aSXBCols)][nCnt] := cCpoPesq //cCpoAux
						Else
								//#aSXBCols[Len(aSXBCols)][nCnt] := CriaVar(cCampo)
							nCpo2 := (aSXBHeader[nCnt,04] )//+ aSXBHeader[nCnt,05])
							If aSXBHeader[nCnt,08] == "N"
								uValor := Val( SubStr(RCC_CONTEU,nCpo1,nCpo2) )
							ElseIf aSXBHeader[nCnt,08] == "D"
								uValor := If(Len(SubStr(RCC_CONTEU,nCpo1,nCpo2)) == 8, STOD(SubStr(RCC_CONTEU,nCpo1,nCpo2)), CTOD(SubStr(RCC_CONTEU,nCpo1,nCpo2)))
							Else
								uValor := SubStr(RCC_CONTEU,nCpo1,nCpo2)
							EndIf

							aSXBCols[Len(aSXBCols)][nCnt] := uValor
							nCpo1 += nCpo2
				  		EndIf
					Next nCnt

					aSXBCols[Len(aSXBCols)][nUsado+1] := .F.

					nCont += 1
					If nCont > nQtdLin
						Exit
					EndIf
					nCpo1 := 1
				EndIf
			EndIf
		EndIf

		(cRCCAlias)->(dbSkip())
	EndDo

	(cRCCAlias)->(DBCloseArea())

	If IsInCallStack("GPCRGTPBEN")
		AADD(aSXBCols,Array(Len(aSXBHeader)+1))
		nSeq := Len(aSXBCols)
		aSXBCols[nSeq][1] := strzero(nSeq,3)
		aSXBCols[nSeq][2] := "VA"
		aSXBCols[nSeq][3] := STR0068//"Vale Alimentação"
		aSXBCols[nSeq][4] := ""
		aSXBCols[nSeq][5] := .F.

		AADD(aSXBCols,Array(Len(aSXBHeader)+1))
		nSeq := Len(aSXBCols)
		aSXBCols[nSeq][1] := strzero(nSeq,3)
		aSXBCols[nSeq][2] := "VR"
		aSXBCols[nSeq][3] := STR0069//"Vale Refeição"
		aSXBCols[nSeq][4] := ""
		aSXBCols[nSeq][5] := .F.

		AADD(aSXBCols,Array(Len(aSXBHeader)+1))
		nSeq := Len(aSXBCols)
		aSXBCols[nSeq][1] := strzero(nSeq,3)
		aSXBCols[nSeq][2] := "PS"
		aSXBCols[nSeq][3] := STR0070//"Plano de Saúde"
		aSXBCols[nSeq][4] := ""
		aSXBCols[nSeq][5] := .F.
	EndIf

	RestArea( aArea )

Return lfilial

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          º Autor ³ Ademar Fernandes   º Data ³  31/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Localiza a informacao digitada pelo usuario na Tela de Pes-º±±
±±º          ³ quisa de tabelas do RCC                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GP310SXB                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PesqDados(cPesq)
Local nPosLin := 0
Local nPosCpo := 0
Local nLenCmb := Len(Alltrim(cPesq))
Local nCmbLin := aScan( aMyCombo, { |x| Alltrim(x[01]) == Alltrim(cCombo)} )
nPosCpo := GdFieldPos(aMyCombo[nCmbLin,02],aSXBHeader) //GdFieldPos(aMyCombo[nCmbLin,02])

If nPosCpo > 0
	nPosLin := aScan( aSXBCols, { |x| Alltrim(cPesq) $ SubStr(Alltrim(UPPER(x[nPosCpo])),1,nLenCmb)} )
EndIf

If nPosLin >= 1
	oGetDados:oBrowse:nAt := nPosLin
	n:= nPosLin
EndIf
oGetDados:oBrowse:Refresh()
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          º Autor ³ Ademar Fernandes   º Data ³  07/11/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Monta uma ListBox com as Consultas Padroes disponiveis.    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fSeleSxb( cNomeAlias , lBranco , aLbxA , lShowDialog )
Local aArea		:= GetArea()
Local aAreaSXB	:= SXB->( GetArea() )
Local cAlias  	:= Alias()
Local cPesq   	:= Iif( !Empty( cNomeAlias ) , Padr( cNomeAlias , 20 ) , Space( 20 ) )
Local lOK     	:= .F.
Local nPosLbxA	:= 0.00
Local oPesq		:= NIL
Local oDlg		:= NIL
Local oLbxA		:= NIL
Local nOpca		:= 0

Local bSet15 := {|| NIL}
Local bSet24 := {|| NIL}

// Variaveis para Dimensionar Tela
Local aRetcoords 	:= {}

DEFAULT lBranco		:= .F.
DEFAULT aLbxA		:= {}
DEFAULT lShowDialog	:= .T.

aLbxA := {}

If ( lBranco )
	aAdd( aLbxA , { Space( 06 ) , Space( 30 ) } )
EndIf

dbSelectArea( "SXB" )
SET FILTER TO XB_TIPO == "1"
SXB->( dbGoTop() )
While SXB->( !Eof() )
	SXB->( AADD( aLbxA, { SXB->XB_ALIAS, SXB->(XBDESCRI()) } ) )
	SXB->( dbSkip() )
EndDo

SET FILTER TO
RestArea( aAreaSXB )

If ( lShowDialog )

	aRetcoords := RetCoords(2,2,35,105,1)

	//Abaixo utilizamos o tamanho da janela como na versão 10, pois cada objeto tem seu posicionamento específico,
	//o cada qual eh realocado conforme a resolução da tela do usuário
	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlg FROM 150,005 TO 460,390 TITLE OemToAnsi(STR0060) PIXEL		// "Selecione o Arquivo"

		@ aRetcoords[1][1], aRetcoords[1][2] LISTBOX oLbxA FIELDS HEADER "" , OemToAnsi(STR0061) SIZE 175,093;	// "Bases de Dados"
		OF oDlg PIXEL ON DBLCLICK ( lOk := .T., nPosLbxA:=oLbxA:nAt,oDlg:End() )

		oLbxA:SetArray(aLbxA)
		oLbxA:bLine := { || {aLbxA[oLbxA:nAt,1],aLbxA[oLbxA:nAt,2]}}

		@ aRetcoords[3][1], aRetcoords[3][2] SAY OemToAnsi(STR0002)+":" SIZE 25, 7 OF oDlg PIXEL 						// "Pesquisar:"
		@ aRetcoords[4][1], aRetcoords[4][2] MSGET oPesq VAR cPesq  SIZE 80,10 OF oDlg PIXEL PICTURE "@!" VALID VldPosArq( oLbxA , aLbxA , cPesq )

		bSet15 := { || nOpca := 1, lOk := .T., nPosLbxA:=oLbxA:nAt,oDlg:End()}
		bSet24 := { || nOpca := 0, lOk := .F., oDlg:End() }

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg, bSet15, bSet24),;
											 VldPosArq( oLbxA , aLbxA , cNomeAlias ))

	If ( lOk )
		cNomeAlias := aLbxA[nPosLbxA,1]
	EndIf

EndIf

RestArea( aArea )
RestArea( aAreaSXB )

dbSelectArea( cAlias )
Return( lOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VldPosArq º Autor ³Equipe RH           º Data ³  18/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³										                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldPosArq( oListBox , aListBox , cAliasPesq  )
Local bAscan	:= { || NIL }
Local lValidArq := .T.
Local nPosArq	:= 0.00

DEFAULT aListBox	:= {}
DEFAULT cAliasPesq	:= ""

If ( ValType( oListBox ) == "O" )
	If !Empty( cAliasPesq )
		bAscan := { |z| Substr(z[1], 1, Len(cAliasPesq)) = AllTrim( cAliasPesq ) }
		If ( lValidArq := ( nPosArq := aScan( aListBox , bAscan ) ) > 0.00 )
			oListBox:nAt := nPosArq
		Else
			MsgStop( OemtoAnsi( "Arquivo não encontrado" ) ) // "Arquivo nao encontrado"
		EndIf
		oListBox:Refresh()
	EndIf
EndIf

Return( lValidArq )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          º Autor ³ Ademar Fernandes   º Data ³  24/11/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Apresentar uma tela com as opcoes da Taxa de ARP e depois  º±±
±±º          ³ atualiza o campo TAXAARP da Tabela S021                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fTaxaARP()

Local lRet    := .F.
Local nPos    := 0
Local cMyOpc  := ""
Local aOpcoes := {}
Local cOpcoes := ""

Aadd(aOpcoes, "Minimo ")
Aadd(aOpcoes, "Inicial")
Aadd(aOpcoes, "Maximo ")
cOpcoes := "010203"

If f_Opcoes(@cMyOpc,/*cTitulo*/,aOpcoes,cOpcoes,/*nLin1*/,/*nLin1*/,.T.,2)
	lRet := .T.
	nPos := GdFieldPos("TAXAARP")
	aCols[n,nPos] := cMyOpc
EndIf

Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          º Autor ³ Abel Ribeiro       º Data ³  26/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Apresentar uma tela com as opcoes de Tipos de Aportantes   º±±
±±º          ³ atualizar o campo TIPOAPORT da Tabela S021.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fNatJur()

Local lRet    := .F.
Local nPos    := 0
Local cMyOpc  := ""
Local aOpcoes := {}
Local cOpcoes := ""

Aadd(aOpcoes, "1-Publica")
Aadd(aOpcoes, "2-Privada")
Aadd(aOpcoes, "3-Mista")
Aadd(aOpcoes, "4-Organismos multilaterais")
Aadd(aOpcoes, "5-Entidade del derecho público no submetidos a legislacion colombiana")

cOpcoes := "12345"

If f_Opcoes(@cMyOpc,/*cTitulo*/,aOpcoes,cOpcoes,/*nLin1*/,/*nLin1*/,.T.,1)
	lRet := .T.
	nPos := GdFieldPos("NATJUR")
	aCols[n,nPos] := cMyOpc
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          º Autor ³ Abel Ribeiro       º Data ³  26/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Apresentar uma tela com as opcoes de Tipos de Aportantes   º±±
±±º          ³ atualizar o campo TIPOAPORT da Tabela S021.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fTpApor()

Local lRet    := .F.
Local nPos    := 0
Local cMyOpc  := ""
Local aOpcoes := {}
Local cOpcoes := ""

Aadd(aOpcoes, "1-Empleador")
Aadd(aOpcoes, "2-Independiente")
Aadd(aOpcoes, "3-Entidades o Universidades publicas con regimen especial en Salud")
Aadd(aOpcoes, "4-Agremiações o Asociaciones")
Aadd(aOpcoes, "5-Coopertivas y Precooperativas de trabajo asociado")
Aadd(aOpcoes, "6-Misiones diplomaticas, consulares o de org.multilaterales no sometidos por la leg.Colombiana")
Aadd(aOpcoes, "7-Organizaciones administradoras del Programa de bienestar familiar   ")
Aadd(aOpcoes, "8-Pagador de aportes de los concejales municipales ")

cOpcoes := "12345678"

If f_Opcoes(@cMyOpc,/*cTitulo*/,aOpcoes,cOpcoes,/*nLin1*/,/*nLin1*/,.T.,1)
	lRet := .T.
	nPos := GdFieldPos("TIPOAPOR")
	aCols[n,nPos] := cMyOpc
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fValPesq ºAutor  ³ IP-RH Inovacao     º Data ³  21/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Apresenta mensagem de alerta quando nao existir campo pra  º±±
±±º          ³ pesquisa na tabela auxiliar.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fValPesq()

Alert(STR0055)	//-"O campo de pesquisa 'Busca por:' não pode ser vazio !!!"

Return(.F.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ExistReg ºAutor  ³ Adrianne Furtado   º Data ³ 17/11/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se existem registros validos na consulta para essaº±±
±±º          ³ filial                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P10                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ExistRTab(cCodTab)

	Local lRet		:= .F.
	Local cFOrigem	:= ""
	Local cRCCAlias := GetNextAlias()

	If __READVAR == "M->CODFOR"           //CONSULTA F3 A PARTIR DE UMA TABELA SNNN
		cFOrigem := aCols[n][1]
	Else
		If cPaisloc == "MEX"
		         cFOrigem := xFilial( "RCC" )
		Else
		cFOrigem := cFilAnt
		Endif
	EndIf

	RCC->(dbSetOrder(1))	// RCC_FILIAL + RCC_CODIGO + RCC_FIL + RCC_CHAVE  + RCC_SEQUEN
	RCC->(dbSeek(xFilial("RCC")+cCodTab))

	BeginSql Alias cRCCAlias
		SELECT  RCC.*   FROM 	%table:RCC% RCC
		        WHERE RCC.RCC_CODIGO   = %Exp:(cCodTab)%  AND RCC.%NotDel%
	EndSql

	While (cRCCAlias)->(!Eof()) .and. !lRet

		If Empty((cRCCAlias)->(RCC_FIL)) .or. (cRCCAlias)->(RCC_FIL) == cFOrigem
			lRet := .T.
			RCC->(DbGoto( (cRCCAlias)->(R_E_C_N_O_) ))
		EndIf

		(cRCCAlias)->(DBSkip())
	End

	(cRCCAlias)->(DBCloseArea())


Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          º Autor ³ Equipe RH Inovacao º Data ³  22/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Apresenta mensagem de alerta                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fOpcAviso()
Local lRet    := .F.
Local cMyOpc  := ""
Local aOpcoes := {}
Local cOpcoes := ""

Aadd(aOpcoes, STR0057)
Aadd(aOpcoes, STR0058)
Aadd(aOpcoes, STR0059)
cOpcoes := "PDT"

cMyOpc := TIPOPRE

If f_Opcoes(@cMyOpc,/*cTitulo*/,aOpcoes,cOpcoes,/*nLin1*/,/*nLin1*/,.F.,1)
	lRet := .T.
	cMyOpc := StrTran(cMyOpc,"*"," ")
	TIPOPRE := cMyOpc
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPEA310CBXº Autor ³Mohanad Odeh        º Data ³  18/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atribui conforme selecão do combobox                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION GPEA310CBX(nCbx)
Local nRet := 0

If nCbx == 1
	nRet := 1	//"S=SIM"
ElseIf nCbx == 2
	nRet := 2 //"N=NÃO"
End

Return nRet


/*/{Protheus.doc} RccAsF3
	Utilizar a RCC(Manutenção de Tabelas) como F3(LookUp)
@author PHILIPE.POMPEU
@since 28/03/2016
@version P12
@param cTabela, caractere, tabela da RCC(ex.: "S059")
@param cRetCampo, caractere, campo da RCC que deve ser retornado(Ex.: "CODIGO")
@return xRet, lógico, .T. se consulta foi executada
/*/
Function RccAsF3(cTabela,cRetCampo)
Local cRet		:= .F.
Local nTamOrdem:= TamSx3('RCB_ORDEM')[1]
Default cRetCampo	:=  Nil
Default cTabela := RCC->RCC_CODIGO /*Por padrão pega o posicionamento*/

if(cRetCampo == Nil) /*Caso não seja especificado o campo à ser retornado, busca o primeiro da tabela em questão!*/
	RCB->(dbSetOrder(1))
	if(RCB->(dbSeek(xFilial("RCB")+ cTabela + StrZero(1,nTamOrdem))))
		cRetCampo := AllTrim(RCB->RCB_CAMPOS)
	endIf
endIf

xRet := Gp310SXB(cTabela, cRetCampo, {|| .T. } )

If ValType(xRet)<> "L" .or. (ValType(xRet)== "L"  .and. !xRet)
	VAR_IXB := &__READVAR
EndIf

If ValType(xRet) != "L"
	xRet := .F.
EndIf

Return( xRet )

/*/{Protheus.doc} fDesSeq
Retorna título do campo RCC_SEQUEN.
@author raquel.andrade
@since 23/04/2018
@version P12
@return cTitSeq, character
/*/
function fDesSeq()
Local aArea:= GetArea()
Local aAreaSX3 := SX3->(GetArea())
Local cTitSeq	:= ""

SX3->(dbSelectArea("SX3"))
SX3->(dbSetOrder(2))
If ( SX3->(DbSeek("RCC_SEQUEN")))
	cTitSeq := Alltrim(X3Titulo())
EndIf
RestArea(aAreaSX3)
RestArea(aArea)

Return(cTitSeq)
