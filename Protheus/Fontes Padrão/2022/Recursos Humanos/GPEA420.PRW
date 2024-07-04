#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA420.CH"

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   ЁGPEA420   Ё Autor ЁROMAN DIAZ                       Ё Data Ё21/06/2004Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCADASTRO DE PROCESSOS.                     					          Ё
цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё 		   ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.			          Ё
цддддддддддддбддддддддбддддддддддддддддбдддддддддддддддддддддддддддддддддддддддддд╢
ЁProgramador Ё Data	  Ё BOPS/FNC       Ё  Motivo da Alteracao			  		  Ё
цддддддддддддеддддддддеддддддддддддддддедддддддддддддддддддддддддддддддддддддддддд╢
ЁMohanad OdehЁ19/02/13ЁM12RH01   RQ0309ЁUnificacao dos fontes V12                 Ё
ЁTiago Malta Ё13/11/13ЁRQ2550          ЁCONVERSцO DE DADOS                        Ё
ЁSidney O.   Ё31/03/14ЁM_RH007   TPCCTWЁAlteracao da descricao dos processos      Ё
Ё            Ё        Ё                Ёpre-definidos                             Ё
ЁCarlos E. O.Ё10/06/14ЁVER12_TEST      Ё                                          Ё
Ё            Ё        Ё          TPVIYPЁValidacao pra nao deixar excluir processo Ё
Ё            Ё        Ё                Ёquando vinculado a algum periodo.         Ё
юддддддддддддаддддддддаддддддддддддддддадддддддддддддддддддддддддддддддддддддддддды
/*/
Function GPEA420
Local aIndexRCJ	:= {}		//Variavel Para Filtro
Private bFiltraBrw  := {|| Nil}		//Variavel para Filtro
Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina
Private cCadastro := OemToAnsi(STR0006)  //"Cadastro de Processos"

//Inicializa o filtro utilizando a funcao FilBrowse
cFiltraRh := ChkRh("GPEA420","RCJ","1")
bFiltraBrw := { || FilBrowse("RCJ",@aIndexRCJ,@cFiltraRH) }
Eval(bFiltraBrw)

//Inicializa codigos de Processo caso arquivo esteja vazio
If cPaisLoc $ "BRA/RUS"
	GpIniProc()
Endif

dbSelectArea("RCJ")
dbSetOrder(1)

mBrowse( 6,1,22,75, "RCJ", NIL , NIL , NIL , NIL , NIL , if(!(MV_MODFOL == "2"),Gpe420CriaCor(), NIL),,,,,,,,,,,MV_MODFOL )

EndFilBrw( "RCJ" , aIndexRCJ )

Return

/*
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    Ёgpea420MntЁ Autor ЁMauricio T. Takakura   Ё Data Ё30/12/2004Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁCadastro de Processos                                       Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ёgpea420Mnt( cAlias , nReg , nOpc )						    |
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁcAlias = Alias do arquivo                                   Ё
Ё          ЁnReg   = Numero do registro                                 Ё
Ё          ЁnOpc   = Numero da opcao selecionada                        Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      Ё    	                                                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function Gpea420Mnt(cAlias, nReg, nOpc)
Local aSvKeys				:= GetKeys()	// grava as teclas de atalhos
Local aArea				:= GetArea()	// grava a area da janela
Local aAdvSize			:= {}
Local aInfoAdvSize		:= {}
Local aObjSize			:= {}  			// tamanho do objeto
Local aObjCoords			:= {}			// coordenadas do objeto
Local aRCJNotFields		:= {} 			// campos que nao irao aparecer na enchoice
Local aRCJCols			:= {}			// colunas da enchoice
Local aRCJHeader			:= {}			// cabecalho da enchoice
Local aRCJVirtEn			:= {}  			// array com os campos virtuais que irao aparecer na enchoice
Local aRCJVisuEn			:= {}			// array com os campos apenas visuais
Local aRCJRecnos			:= {} 			// array que contem os recnos dos registros
Local aRCJFields			:= {}  			// campos
Local aRCJNaoAlt			:= {}			// campo apenas de consulta - nao editavel
Local aRCJAltera			:= {}			// campos editaveis
Local bSet15				:= { || NIL }		// botao OK
Local bSet24				:= { || NIL }		// botao Cancel
Local cFilRCJ				:= ""			// armazena a filial corrente
Local nLoop				:= 0			// variavel utilizado para for / next
Local nLoops				:= 0.00			// variavel auxiliar - auxiliar para o loop, passando um valor variavel
Local nOpcAlt    		:= 0.00 		// variavel que controla se todos os dados estao OK para serem gravados
Local nRCJUsado			:= 0.00	        // retorna pelo gdmontacols() o numero de campos em uso
Local oDlg				:= NIL			// objeto da Dialog
Local oEnchoice			:= NIL			// objeto da Enchoice

Begin Sequence

	If nOpc = 3 // SE INCLUSAO POSICIONA O REGISTRO NO FINAL DO ARQUIVO
		PutFileInEof( "RCJ" , @nReg )  		 // FUNCAO EM PONXFUN.PRX
	EndIf

	//Elaboracao dos parametros da Enchoice
	aAdd( aRCJNotFields, "RCJ_FILIAL" )
	aAdd( aRCJNotFields, "RCJ_ORIGEM" )
	If cPaisLoc == "PTG"
		aAdd( aRCJNotFields, "RCJ_TIVCV" )
	EndIf

    aRCJCols := RCJ->(GdMontaCols(	@aRCJHeader		,;
    								@nRCJUsado		,;
    								@aRCJVirtEn		,;
    								@aRCJVisuEn		,;
    								NIL				,;
    								aRCJNotFields	,;
    								@aRCJRecnos		,;
    								NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,;
    								.F.				 ;
    							)) // FUNCAO EM PONXFUN.PRX

	cFilRCJ	 := xFilial( "RCJ" )

	//CRIA AS VARIAVEIS DE MEMORIA E CARREGA OS DADOS CONFORME O ARQUIVO	PARA EDICAO NA ENCHOICE
	For nLoop := 1 To nRCJUsado // No. de campos
		aAdd(aRCJFields , aRCJHeader[nLoop, 02])
		Private &("M->"+aRCJHeader[nLoop, 02]) := aRCJCols[01, nLoop]
	Next nLoop

	//DEFINE OS CAMPOS EDITAVEIS NA ENCHOICE
	If (( nOpc == 3 ) .or. ( nOpc == 4 )) // OPCAO 3-INCLUIR E 4-ALTERAR
	   // CAMPOS DE CONSULTA
 		nLoops := Len( aRCJVisuEn ) // CAMPOS VISUAIS
		For nLoop := 1 To nLoops
			aAdd(aRCJNaoAlt, aRCJVisuEn[nLoop])
		Next nLoop

		If nOpc == 4
			aAdd(aRCJNaoAlt, "RCJ_CODIGO")
			If (RCJ->RCJ_ORIGEM == "1") .AND. MV_MODFOL == "1"
				aAdd(aRCJNaoAlt, "RCJ_DESCRI")
			EndIf
		EndIf

		// CAMPOS EDITAVEIS
		nLoops := Len(aRCJFields)
		For nLoop := 1 To nLoops
			If (aScan(aRCJNaoAlt, {|cNaoA| cNaoA == aRCJFields[nLoop]}) == 0.00)
				aAdd(aRCJAltera, aRCJFields[nLoop])
			EndIf
		Next nLoop
	EndIf

	//MONTA AS DIMENSOES DOS OBJETOS
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

	//DEFINE O BLOCO PARA A TECLA <CTRL-O> (BOTAO OK)
	bSet15		:= { || If (fValForm(),;// VERIFICA SE RCJ_DIACAL FOR IGUAL A 1 SE O CAMPO RCJ_DIAPRO ESTа VAZIO. PARA COLOMBIA E PERU
    						IF(;
								( ( nOpc == 3 ) .or. ( nOpc == 4 )) .and. ;   				// inclusao e alteracao
								Obrigatorio( oEnchoice:aGets , oEnchoice:aTela ) 	.and.;	//Verifica os Campos Obrigatoris na Enchoice
								EnchoTudOk( oEnchoice )				 				     ;	//Valida Todos os Campos da Enchoice
							    ,;
								(;															// situacao verdadeira
									nOpcAlt := 1.00 ,;										// OK para gravacao
									oDlg:End();
							 	),;
							 	IF(; 														// situacao falsa
							 		( ( nOpc == 3 ) .or. ( nOpc == 4 ) ) ,;					//Inclusao ou alteracao
							 			(;
							 				nOpcAlt := 0.00 ,; 								// nao serao permitido a gravacao
							 				.F.;											// permanecera na janela
							 			 ),;
									(;
										nOpcAlt := IF( nOpc == 2 , 0 , 1.00 ) ,;			//Visualizacao ou Exclusao
										oDlg:End();
							 		);
							 	  );
						   );
						,Help(" ",1,"GPEA420DIACAL"); //Se Dias do CalendАrio for selecionado como "Sim", o nЗmero de dias por perМodo deverА ser igual a "0"
						);
					 }

	//DEFINE O BLOCO PARA A TECLAS <CTRL-X> (BOTAO CANCELAR)
	bSet24		:= { || ( nOpcAlt := 0.00 , oDlg:End() ) }

	// Monta o Dialogo Principal para a Manutencao
	DEFINE MSDIALOG oDlg TITLE OemToAnsi( STR0006 ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL // 'Cadastro de Processos'


	//MONTA O OBJETO ENCHOICE PARA O RCJ
	oEnchoice	:= MsmGet():New(	"RCJ"		,;
									nReg		,;
									nOpc		,;
									NIL			,;
									NIL			,;
									NIL			,;
									aRCJFields	,;
									aObjSize[1] ,;
									aRCJAltera	,;
									NIL			,;
									NIL			,;
									NIL         ,;  // opcao para inserir funcao que valida a linha que esta sendo incluida
									oDlg		,;
									NIL			,;
									.T.			,;
									,,,,,,,,,Alltrim(MV_MODFOL))

	oEnchoice:oBox:Align := CONTROL_ALIGN_ALLCLIENT

    ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 ) CENTERED

	//QUANDO CONFIRMADA A OPCAO E NAO FOR VISUALIZACAO GRAVA OU EXCLUI AS INFORMACOES DO RCJ
	If( nOpcAlt == 1 )
 		If ( nOpc == 3 ) .OR. ( nOpc == 4 )

			//GRAVANDO/INCLUINDO
			MsAguarde(;
						{ ||;
					             gpea420Grava(	nOpc		,;	//Opcao de Acordo com aRotina
											 	nReg		,;	//Numero do Registro do Arquivo Pai ( RCJ )
												aRCJHeader	,;	//Campos do Arquivo Pai ( RCJ )
												aRCJVirtEn	;	//Campos Virtuais do Arquivo Pai ( RCJ )
										   );
						};
					 )
		EndIf
	EndIf
End Sequence

RestKeys(aSvKeys)
RestArea(aArea)

Return(Nil)

/*
зддддддддддбдддддддддддддбдддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    Ёgpea420Grava ЁAutorЁMauricio T. Takakura  Ё Data Ё30/12/2004Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o Ё Gravacao das informacoes do arquivo RCJ                    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGpea420                                                     Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function gpea420Grava(	nOpc		,;	//Opcao de Acordo com aRotina
							 	nReg		,;	//Numero do Registro do Arquivo Pai ( RCJ )
							 	aRCJHeader	,;	//Campos do Arquivo Pai ( RCJ )
							 	aRCJVirtEn	;	//Campos Virtuais do Arquivo Pai ( RCJ )
							  )
Local lLock		:= .F.						// variavel para controle de travar registros
Local nChoice		:= 0						// variavel utilizada para loop
Local nChoices	:= 0.00					// numero de columas
nChoices			:= Len(aRCJHeader)

//Se for Inclusao/Alteracao (nOpc == 3 .or. nOpc == 4)
If (nOpc == 3 .or. nOpc == 4)
	Begin Transaction
		If !Empty(nReg)
			RCJ->(MsGoto(nReg))
			lLock := RecLock("RCJ", .F., .F.)   // bloquear o registro  .F. - alterar; .F. nao forcar gravacao
		Else
			lLock := RecLock("RCJ", .T., .F.)	// .T. incluir um novo registro; .F. nao forcar gravacao
		EndIf

		If !(lLock)
			Break
		EndIf
        RCJ->RCJ_FILIAL := xFilial('RCJ')

        If nOpc == 3 .and. MV_MODFOL == "1"
        	RCJ->RCJ_ORIGEM := "2"
        EndIf

		// GRAVACAO DOS CAMPOS DE FORMA DINAMICA
		For nChoice := 1 To nChoices
			If (aScan(aRCJVirtEn , { |cCpo| (cCpo == aRCJHeader[nChoice, 02])}) == 0.00)
				RCJ->(&(aRCJHeader[nChoice, 02])) :=&("M->"+aRCJHeader[nChoice, 02])
            EndIf
		Next nChoice

		RCJ->(MsUnLock())

	End Transaction
EndIf

Return (Nil)

/*
зддддддддддбдддддддддддддбдддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁGpea420Dele  ЁAutorЁRoman Diaz            Ё Data Ё23/06/2004Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o | Excluir, o usuario nao podera excluir registros do sistema Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGpea420()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function Gpea420Dele( cAlias, nReg, nOpc)

Local aArea		:= GetArea()
Local aAreaRCJ	:= RCJ->(GetArea())
Local aAC    	:= {STR0007 , STR0008}  //'Abandona'###'Confirma'

Local cFil  	:= ""
Local cCodigo  	:= ""
Local cCve     	:= ""
Local cNivant

Local lRet   	:= .T.
Local lAchou 	:= .F.

Local nOpcA

// VARIAVEIS PARA DIMENSIONAR TELA
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

//MONTA A ENTRADA DE DADOS DO ARQUIVO
Private aTELA[0][0], aGETS[0]

Begin Sequence

	nOpcA := 0
	dbSelectArea(cAlias)
	dbSetOrder(1)

	//MONTA AS DIMENSOES DOS OBJETOS
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 2 , 2 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T.  } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

		nOpcA := EnChoice( cAlias, nReg, nOpc, aAC, 'AC', OemToAnsi(STR0009),,aObjSize[1],,,,,,,,,,,,,,,,,MV_MODFOL )  //'Quanto ┘ exclus└o?'
        nOpcA := 1
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()}) CENTERED

	If nOpcA == 2

		IF (RCJ->RCJ_ORIGEM) == "1"
			Aviso(cCadastro, OemToAnsi(STR0012), {'OK'})	//"Nao e possivel Excluir um Processo de Sistema"
			Break
		EndIF

		If lAchou == .F.
       		cFil := xFilial('RCJ')
			cCodigo := RCJ->RCJ_CODIGO

			// VERIFICA A INTEGRIDADE COM OUTRAS TABELAS
			lAchou := !Gpea420ChkDel( cAlias , nReg , nOpc , cCodigo)

			// VERIFICA SE O PROCESSO ESTA ASSOCIADO COM: SRA,SRC,RCF,SFG
			If lAchou
				Break
			Else

				RCH->(dbSetOrder(1)) //Ordena por Processo
				If RCH->(dbSeek(cFil + cCodigo)) //Verifica se o Processo existe no cadastro de Periodos
					Aviso(cCadastro, OemToAnsi(STR0025), {'OK'})	//"Nao e possivel Excluir um Processo de Sistema"
					Break
				Endif

				Begin Transaction
					dbSelectArea(cAlias)
					RecLock(cAlias, .F., .T.)
					dbDelete()
					MsUnlock()
					WRITESX2(cAlias,1)
					DbSkip ()
				End Transaction
			EndIf
		Else
			Aviso(OemToAnsi(STR0009), OemToAnsi(STR0010), {'OK'})//"Registro em Uso por outro Usuario"##"Este processo esta em uso e nao pode ser excluido"
		EndIf
	EndIf
End Sequence

RestArea(aAreaRCJ)
RestArea(aArea)

Return Nil

/*
зддддддддддбдддддддддддддбдддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁGpea420ChkDelЁAutorЁRoman Diaz            Ё Data Ё23/06/2004Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁVerifica se os Registros podem ser Deletados                Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGpea420()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function Gpea420ChkDel(	cAlias		,;	//Alias do Arquivo Principal
								nReg		,;	//Recno do Arquivo Principal
								nOpc		,;	//Opcao do Arquivo Principal
								cCodigo		 ;	//Chave para Exclusao (Sem a Filial)
							   )

Local cKeyDel		:= ""
Local lChkDelOk 	:= .T.

DEFAULT cAlias		:= Alias()
DEFAULT nReg		:= (cAlias)->(Recno())
DEFAULT nOpc		:= 5
DEFAULT cCodigo		:= ""

(cAlias)->(MsGoto(nReg))
cKeyDel	:= cCodigo

lChkDelOk  := ChkDelRegs(	cAlias			,;	//Alias do Arquivo Principal
							nReg				,;	//Registro do Arquivo Principal
							nOpc				,;	//Opcao para a AxDeleta
							xFilial(cAlias)	,;	//Filial do Arquivo principal para Delecao
							cKeyDel			,;	//Chave do Arquivo Principal para Delecao
							NIL				   ,;	//Array contendo informacoes dos arquivos a serem pesquisados
							NIL					,;	//Mensagem para MsgYesNo
							NIL					,;	//Titulo do Log de Delecao
							NIL					,;	//Mensagem para o corpo do Log
							.F.				 	,;	//Se executa AxDeleta
							.T.     			,;	//Se deve Mostrar o Log
							NIL					,;	//Array com o Log de Exclusao
							NIL				 	 ;	//Array com o Titulo do Log
						)

Return(lChkDelOk)

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁGpProLeg		ЁAutorЁNatie     		  Ё Data Ё21/09/2000Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCria uma janela contendo a legenda da mBrowse               Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Firmais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGpProLeg	                                                Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁNIL															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Firmais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function GpProLeg()

BrwLegenda(	OemToAnsi(cCadastro)						,;	// "Titulo do Cadastro"
			OemToAnsi( STR0013 )						,;	// "Legenda"
			{;
				{"BR_AZUL"		,OemToAnsi(STR0014)	}	,;	// "Processo Exclusivo do Sistema"
				{"BR_VERDE"		,OemToAnsi(STR0015)	}	 ;	// "Processo de Cliente"
			};
		 )

Return( .T. )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁGpe420CriaCor	ЁAutorЁROMAN DIAZ		  Ё Data Ё30/12/2004Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁLegenda                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Firmais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGpe420CriaCor                                               Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁNIL															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Firmais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function Gpe420CriaCor()
Local aCores := {}

aCores	:=	{;
				{ "RCJ->RCJ_ORIGEM=='2'" , 'BR_VERDE'		},;
				{ "RCJ->RCJ_ORIGEM=='1'" , 'BR_AZUL'		} ;
			 }

//PONTO DE ENTRADA PARA ALTERAR CORES DO BROWSE DO CADASTRO
If ExistBlock("GP420BWCORES")
	IF ValType( uRet := ExecBlock("GP420BWCORES",.F.,.F.,aCores) ) == "A"
		aCores := aClone(uRet)
		uRet	 := NIL
	Endif
EndIf

Return(aCores)

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   ЁfListProc Ё Autor ЁMauricio Takakura 	  Ё Data Ё 06/10/05 Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁSelecionar Cod. de Processos da Tabela RCJ           	  	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё fListProc()												Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   Ё Generico 													Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function fListProc( l1Elem , cPreSelect )
Local aNewSelect		:= {}
Local aPreSelect		:= {}
Local aProcesssos       := {}
Local cFilRCJ			:= xFilial("RCJ")
Local cTitulo			:= ""
Local cReadVar			:= ""
Local MvParDef			:= ""
Local MvRetor			:= ""
Local MvParam			:= ""
Local lRet				:= .T.
Local nFor				:= 0
Local nAuxFor			:= 1
Local MvPar     		:= NIL

DEFAULT cPreSelect		:= ""
DEFAULT l1Elem			:= .F.

Begin Sequence

	cAlias 	:= Alias()
	MvPar	:= &(Alltrim(ReadVar()))
	mvRet	:= Alltrim(ReadVar())

	If AllTrim( MvPar ) == "*"
		Break
	EndIf

	CursorWait()
		For nFor := 1 To Len( cPreSelect ) Step 5
			aAdd( aPreSelect , SubStr( cPreSelect , nFor , 5 ) )
		Next nFor

		If !( l1Elem )
			For nFor := 1 TO Len(alltrim(MvPar))
				Mvparam += PADR( (Subs(MvPar,nAuxFor,5)), 5 )
				MvParam += Replicate("*",5)
				nAuxFor := (nFor * 5) + 1
			Next
		Endif
		mvPar 	:= MvParam

		afProcessos	:= BldafProcesso( cFilRCJ )

	CursorArrow()

	IF !( lRet := !Empty( afProcessos ) )
		Help(" ",1,"GPENFILIAL")	//Cadastro de verbas nao existe para a filial
		Break
	EndIF

	CursorWait()
		For nFor := 1 To Len( afProcessos )
			IF ( aScan( aPreSelect , SubStr( afProcessos[ nFor ] , 1 , 5 ) ) == 0.00 )
				MvParDef+=Left(afProcessos[ nFor ],5)
				aAdd( aNewSelect , afProcessos[ nFor ] )
			EndIF
		Next nFor
	CursorArrow()

	IF f_Opcoes(@MvPar,cTitulo,aNewSelect,MvParDef,12,49,l1Elem,5,10)
		CursorWait()
			For nFor := 1 To Len( mVpar ) Step 5
				IF ( SubStr( mVpar , nFor , 5 ) # "*****" )
					mvRetor += SubStr( mVpar , nFor , 5 )
				Endif
			Next nFor
			&MvRet := Alltrim(Mvretor)
			If &MvRet == ""
				&MvRet := Space(30)
			EndIf
		CursorArrow()
	EndIF

End Sequence

dbSelectArea(cAlias)

Return( lRet )

/*
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁBldProcesso   Ё Autor ЁMauricio Takakura      Ё Data Ё06/10/2005Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCarregar os Processos do RCJ conforme Filial                 	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁcFilRCJ - Filial do RCJ											Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁaProcessos - Array com Stringo-Codigo + Descricao da Ausencia   Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function BldafProcesso( cFilRCJ )
Local aArea		:= GetArea()
Local aQuery		:= {}
Local aProcessos	:= {}
Local bSkip		:= { || aAdd( aProcessos , ( RCJ_CODIGO + " - " + RCJ_DESCRI ) ) , .F. }

#IFDEF TOP
	aQuery		:= Array( 03 )
	aQuery[01]	:= "RCJ_FILIAL='"+cFilRCJ+"'"
	aQuery[02]	:= " AND "
	aQuery[03]	:= "D_E_L_E_T_=' ' "
#ENDIF

RCJ->( GdMontaCols(	NIL				,;
					NIL				,;
					NIL				,;
					NIL				,;
					NIL				,;
					{				 ;
						"RCJ_FILIAL",;
						"RCJ_CODIGO",;
						"RCJ_DESCRI" ;
					}				,;
					NIL				,;
					"RCJ"			,;
					cFilRCJ			,;
					NIL				,;
					bSkip			,;
					.F.				,;
					.F.				,;
					.F.				,;
					NIL				,;
					.F.				,;
					.F.				,;
					aQuery			,;
					.F.				,;
					.T.				,;
					.F.				,;
					.T.				,;
					.F.				,;
					.F.				,;
					.F.				 ;
				   );
	  )

RestArea(aArea)
Return(aClone(aProcessos))

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁGPIniProc ╨Autor  ЁMicrosiga           ╨ Data Ё  04/06/06   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё                                                            ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                        ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

Function GpIniProc()

Local aArea   	:= GetArea()
Local lUsaGFP	:= if(ExistFunc("fUsaGFP"),fUsaGFP(),.F.) //Verifica se utiliza o modulo de Gestao de Folha Publica - SIGAGFP
Local lcria     := .F.
Local lRcjModulo:= .F.

	DBSELECTAREA("RCJ")

	//Verifica existencia do campo RCJ_MODULO
	lRcjModulo := RCJ->( ColumnPos( "RCJ_MODULO")) > 0

	RCJ->(DBSETORDER(1))
	RCJ->(DBGOTOP())

    If RCJ->(EOF()) .OR. !DbSeek(RCJ->(xFilial("RCJ")))
        lcria := .T.
    Endif

    If lCria
		If cPaisLoc $ "RUS"
			If !DBSEEK(xFilial("RCJ")+"00001")
				If Reclock("RCJ",.T.)
					RCJ->RCJ_FILIAL 	:= xFilial("RCJ")
					RCJ->RCJ_CODIGO		:= "00001"
					RCJ->RCJ_DESCRI 	:= OemToAnsi(STR0026)
		      		RCJ->RCJ_ORIGEM   	:= "1"
			 		RCJ->(MsUnlock())
				Endif
			EndIf
		Else
			If !DBSEEK(xFilial("RCJ")+"00001")
				If Reclock("RCJ",.T.)
					RCJ->RCJ_FILIAL 	:= xFilial("RCJ")
					RCJ->RCJ_CODIGO		:= "00001"
					RCJ->RCJ_DESCRI 	:= "CELETISTA/ESTAGIARIO MENSAL"
					RCJ->RCJ_ORIGEM		:= "1"
					If lRcjModulo
						RCJ->RCJ_MODULO		:= "GPE"
					EndIf
					RCJ->(MsUnlock())
				Endif
			EndIf

			If !DBSEEK(xFilial("RCJ")+"00002")
				If Reclock("RCJ",.T.)
					RCJ->RCJ_FILIAL 	:= xFilial("RCJ")
					RCJ->RCJ_CODIGO		:= "00002"
					RCJ->RCJ_DESCRI 	:= "CELETISTA/ESTAGIARIO SEMANAL"
					RCJ->RCJ_ORIGEM		:= "1"
					If lRcjModulo
						RCJ->RCJ_MODULO		:= "GPE"
					EndIf
					RCJ->(MsUnlock())
				Endif
			EndIf

			If !DBSEEK(xFilial("RCJ")+"00003")
				If Reclock("RCJ",.T.)
					RCJ->RCJ_FILIAL 	:= xFilial("RCJ")
					RCJ->RCJ_CODIGO		:= "00003"
					RCJ->RCJ_DESCRI 	:= "CONTRIBUINTE INDIVIDUAL MENSAL"
					RCJ->RCJ_ORIGEM		:= "1"
					If lRcjModulo
						RCJ->RCJ_MODULO		:= "GPE"
					EndIf
					RCJ->(MsUnlock())
				Endif
			Endif

			If !DBSEEK(xFilial("RCJ")+"00004")
				If Reclock("RCJ",.T.)
					RCJ->RCJ_FILIAL 	:= xFilial("RCJ")
					RCJ->RCJ_CODIGO		:= "00004"
					RCJ->RCJ_DESCRI 	:= "CONTRIBUINTE INDIVIDUAL SEMANAL"
					RCJ->RCJ_ORIGEM		:= "1"
					If lRcjModulo
						RCJ->RCJ_MODULO		:= "GPE"
					EndIf
					RCJ->(MsUnlock())
				Endif
			Endif

			If lUsaGFP
				If !DBSEEK(xFilial("RCJ")+"50000")
					If Reclock("RCJ",.T.)
						RCJ->RCJ_FILIAL 	:= xFilial("RCJ")
						RCJ->RCJ_CODIGO		:= "50000"
						RCJ->RCJ_DESCRI 	:= "MEMBROS/SERVIDORES"
						RCJ->RCJ_ORIGEM		:= "1"
						RCJ->RCJ_MODULO		:= "GFP"
						RCJ->(MsUnlock())
					ENDIF
				Endif
			ENDIF
		EndIf
	Endif

	Dbclosearea()

	RestArea(aArea)

Return

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё fKeyAsimOpc	ЁAutorЁ  Igor Franzoi     Ё Data Ё11/01/2010Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRetorna as opcoes para o campo RCJ_CLASIM					Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA420                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function fKeyAsimOpc()
Local cOpc := ""

cOpc += ( "A=" + OemToAnsi(STR0016)+ ";" ) //Membros Soc.coop.prod. - Miembros Soc.coop.prod.
cOpc += ( "B=" + OemToAnsi(STR0017)+ ";" )  //Int.Soc.e Assoc.Civ. - Int.Soc.y Asoc.Civ.
cOpc += ( "C=" + OemToAnsi(STR0018)+ ";" )  //Membros Cons.Dir.Vig.Con.Com. - Miembros Cons.Dir.Vig.Con.Com.
cOpc += ( "D=" + OemToAnsi(STR0019)+ ";" )  //Ativ.Emp. - Activ.Emp.
cOpc += ( "E=" + OemToAnsi(STR0020)+ ";" )  //Hon.Assim.Sal. - Hon.Asim.Suel.
cOpc += ( "F=" + OemToAnsi(STR0021) )       //Outros - Otros

Return cOpc

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef		ЁAutorЁ  Luiz Gustavo     Ё Data Ё05/01/2007Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁIsola opcoes de menu para que as opcoes da rotina possam    Ё
Ё          Ёser lidas pelas bibliotecas Framework da Versao 9.12 .      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA420                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function MenuDef()
Local aRotina :=	{}

		aAdd( aRotina , {STR0001, "PesqBrw"	    , 0, 1, ,.F.} )	// "Pesquisar"
		aAdd( aRotina , {STR0002, "Gpea420Mnt"  , 0, 2} 	  )	// "Visualizar"
		aAdd( aRotina , {STR0003, "Gpea420Mnt"  , 0, 3} 	  )	// "Incluir"
		aAdd( aRotina , {STR0004, "Gpea420Mnt"  , 0, 4} 	  )	// "Alterar"
		aAdd( aRotina , {STR0005, "Gpea420dele" , 0, 5} 	  )	// "Excluir"

 		If (MV_MODFOL == "1") .and. cPaisLoc <> "PTG"
			aAdd( aRotina , {STR0013, "GpProLeg"    , 0, 5, 7,.F.})  // "Legenda"
		EndIf

Return aRotina

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё fValForm 		ЁAutorЁ Emerson Campos    Ё Data Ё03/01/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o Ё Validacao dos campos RCJ_DIACAL e RCJ_DIAPRO               Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё < Vide Parametros Formais >							    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      Ё GPEA420                                                    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  Ё lRet														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ < Vide Parametros Formais >								Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function fValForm()
Local lRet := .T.
	If cPaisLoc == "COL" .OR. cPaisLoc == "PER"
		If M->RCJ_DIACAL == "1" .AND. M->RCJ_DIAPRO <> 0
			M->RCJ_DIAPRO := 0
			lRet := .F.
		EndIf
	EndIf
Return  lRet