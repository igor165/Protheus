#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "GPEA920.CH"
Static lIntTAF		:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 )
Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Static cVersEnvio	:= ""
Static cVersGPE		:= ""

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    	³ GPEA920    ³ Autor ³ Glaucia M./Mauricio M.  	                ³ Data ³ 13/06/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao 	³ Informacoes Exclusivas Estagio                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   	³ GPEA920()                                                    	  		            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       	³ GPEA010 - Ac Relacionadas - Info Estagiario - Aca Relacionada Ag. Int. Est.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               			            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista     ³ Data     ³ FNC/Requisito  ³ Chamado ³  Motivo da Alteracao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Raquel Hager ³08/07/2014³00000020445/2014³TPZTHB	  ³Inclusao de fonte na versao 12(datat fonte   ³±±
±±³             ³          ³         		³		  ³versao 11 - 01/06/2014)					    ³±±
±±³Christiane V ³02/07/2015³00000015644/2015³TSMUY2   ³Adaptações para versão 2.0 do eSocial        ³±±
±±³Raquel Hager ³24/08/2016³00000029392/2016³TVTOQD   ³Remoção do uso do parâmetro MV_INTTAF para   ³±±
±±³             ³          ³                ³         ³release 12.1.7.							    ³±±
±±³Marcos Cout  ³11/05/2017³DRHESOCP-237    ³         ³Realizar ajustes para geração do evento S2300³±±
±±³             ³          ³                ³         ³para o layout do eSocial 2.2.01       	    ³±±
±±³Marcos Cout  ³20/07/2017³DRHESOCP-403    ³         ³Realizado ajustes necessários para que o     ³±±
±±³             ³          ³                ³         ³evento S-2205 seja gerado corretamente p/    ³±±
±±³             ³          ³                ³         ³para registros de Trabalhador S Vinculos     ³±±
±±³             ³          ³                ³         ³Realizadas varias correções de processos     ³±±
±±|Marcos Cout  |27/10/2017|DRHESOCP-1728   |         |Realizado ajustes necessários para q seja    |±±
±±|             |          |                |         |gerado o XML contendo os dados do estagiario |±±
±±|             |          |                |         |corretamente.                                |±±
±±|Marcos Cout  |06/12/2017|DRHESOCP-2227   |         |Realizado ajustes necessários para q a rotina|±±
±±|             |          |                |         |de consistencia valide corretamente os dados |±±
±±|Cecília Carv |08/01/2018|DRHESOCP-2682   |         |Ajuste para geração de contrato intermitente |±±
±±|             |          |                |         | - evento S-2200.                            |±±
±±³Marcos Cout. |16/02/2017|DRHESOCP-3618   |         |Realizando ajuste na chave de pesquisa trab  |±±
±±³             |          |                |         |sem vinculo (TSV)                            |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEA920()

	Local oMBrowse
	Local cFiltraRh

	If lMiddleware .And. !ChkFile("RJE")
		Help( " ", 1, OemToAnsi(STR0015),, OemToAnsi(STR0041), 1, 0 )//"Tabela RJE não encontrada. Execute o UPDDISTR - atualizador de dicionário e base de dados."
		Return
	EndIf

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("SRA")
	oMBrowse:SetDescription(OemToAnsi(STR0001)) //"Informacoes Exclusivas Estagio"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFiltraRh := CHKRH("GPEA920","SRA","1")
	oMBrowse:SetFilterDefault( cFiltraRh )
	oMBrowse:SetLocate()
	GpLegMVC(@oMBrowse)

	oMBrowse:SetFilterDefault("RA_CATFUNC $ 'E*G'")
	oMBrowse:ExecuteFilter(.T.)

	oMBrowse:Activate()

Return

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Glaucia M.       ³ Data ³04/06/2013³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Criacao do Menu do Browse.                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA920                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function MenuDef()

	Local aRotina := {}

	aAdd( aRotina, { OemToAnsi(STR0009)	, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
	aAdd( aRotina, { OemToAnsi(STR0010)	, "VIEWDEF.GPEA920", 0, 2, 0, NIL } ) // "Visualizar"
	aAdd( aRotina, { OemToAnsi(STR0011)	, "VIEWDEF.GPEA920", 0, 4, 0, NIL } ) // "Alterar"
	aAdd( aRotina, { OemToAnsi(STR0012)	, "VIEWDEF.GPEA920", 0, 5, 0, NIL } ) // "Excluir"

Return aRotina

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ ModelDef		³Autor³  Glaucia M.       ³ Data ³05/06/2013³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Regras de Modelagem da gravacao.                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA920                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³Model em uso.												³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function ModelDef()

	Local oModel		:= Nil
	Local oStruSRA 		:= FWFormStruct( 1, 'SRA')
	Local oStruRFS 		:= FWFormStruct( 1, 'RFS')
	Local bMdPreVal		:= {|oModel| fG920PrVAL(oStruRFS)}
	Local bRFSposVal	:= {|oModel| fG920RFSpo()}
	Local bCommit		:= {|oModel| fG920Com(oModel)}

	oModel     	:= MPFormModel():New('GPEA920', bMdPreVal, ,bCommit )
	oStruSRA	:= FWFormStruct(1,"SRA",{|cCampo|  AllTrim(cCampo) $ "|RA_MAT|RA_NOME|RA_ADMISSA|"})
	oModel:AddFields( 'SRATITLE',				, oStruSRA )
	oModel:AddFields( 'RFSMASTER', 'SRATITLE'	, oStruRFS,,bRFSposVal )

	oModel:GetModel( 'RFSMASTER' ):SetDescription(OemToAnsi(STR0001)) //Informacoes Exclusivas Estagio
	oModel:SetRelation( "RFSMASTER", { { "'RFS_FILIAL", "xFilial( 'RFS' )" },  { 'RFS_MAT', 'RA_MAT' }} , RFS->(IndexKey(1)) )

	oModel:GetModel( "SRATITLE" ):SetOnlyQuery(.T.)

	oModel:SetActivate( { |oModel| fGP920RFS( oModel ) } )

Return( oModel )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ ViewDef		³Autor³  Glaucia M.       ³ Data ³05/06/2013³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Regras de Interface com o Usuario                           ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA920                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³View em uso.    											³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function ViewDef()
	Static cEFDAviso	:= If(cPaisLoc == 'BRA' .AND. Findfunction("fEFDAviso"), fEFDAviso(), "0")			//Se nao encontrar este parametro apenas emitira alertas
	Local oView		:= NIL
	Local oModel	:= FWLoadModel( 'GPEA920' )
	Local oStruSRA	:= FWFormStruct(2, 'SRA')
	Local oStruRFR	:= FWFormStruct(2, 'RFS')

	oStruSRA	:= FWFormStruct(2,"SRA",{|cCampo|  AllTrim(cCampo) $ "|RA_MAT|RA_NOME|RA_ADMISSA|"})

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_SRA",oStruSRA,"SRATITLE")
	oView:AddField("VIEW_RFS",oStruRFR,"RFSMASTER")

	oStruRFR:RemoveField("RFS_FILIAL")
	oStruRFR:RemoveField("RFS_MAT")
	oStruSRA:RemoveField("RA_FILIAL")

	oStruSRA:SetNoFolder()

	oView:SetOnlyView('VIEW_SRA')

	oView:CreateHorizontalBox( 'SUPERIOR', 12 )
	oView:CreateHorizontalBox( 'INFERIOR', 88 )

	oView:SetOwnerView( 'VIEW_SRA', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_RFS', 'INFERIOR' )

	oView:EnableTitleView('VIEW_SRA')
	oView:EnableTitleView('VIEW_RFS')

Return oView


/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ fGP920RFS()	³Autor³  Glaucia M.       ³ Data ³17/06/2013³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Inicializa campos RFS na alteracao.                         ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA920                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³Nenhum														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³oModel = ModelDef em uso na rotina.	     					³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fGP920RFS( oModel )

	Local aArea      := GetArea()
	Local aAreaRFS   := RFS->( GetArea() )
	Local aCampos    := {}
	Local nI         := 0
	Local nOperation := oModel:GetOperation()
	Local oModelRFS
	Local xInit      := ""

	If nOperation == MODEL_OPERATION_UPDATE
		oModelRFS := oModel:GetModel( 'RFSMASTER')

		RFS->( dbSetOrder( 1 ) )
		If !RFS->( dbSeek( xFilial( 'RFS' ) + oModel:GetValue( 'SRATITLE', 'RA_MAT' )  ) )
			aCampos := oModelRFS:GetStruct():GetFields()

			For nI :=  1 to Len( aCampos )
				If aCampos[nI][MODEL_FIELD_INIT] <> NIL
					xInit := oModelRFS:InitValue( aCampos[nI][MODEL_FIELD_IDFIELD] )
					If !Empty( xInit )
						oModelRFS:LoadValue( aCampos[nI][MODEL_FIELD_IDFIELD], xInit )
					EndIf
				EndIf
			Next
		EndIf
	EndIf

	RestArea( aAreaRFS )
	RestArea( aArea )

Return NIL

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ fGP920Ent()	³Autor³  Glaucia M.       ³ Data ³01/07/2013³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Complemento da validação do campo RFS_ENTIDA                ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³fGP920Ent()                 								³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA920 - Campo RFS_ENTIDA                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³Boolean														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³Nenhum 								    					³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function fGP920Ent()

	Local lRet:=	.T.
	Local cMsg	:= ""

	//Posiciono na tabela para garantir abertura quando MVC e ExecAuto
	dbSelectArea("RA0")
	dbSetOrder(1) // RA0_FILIAL+RA0_ENTIDA
	If RA0->(dbSeek(xFilial("RA0")+&(ReadVar())))
		Iif( cPaisLoc == "BRA" .And. FindFunction("fVersEsoc"), fVersEsoc( "S2300", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, @cVersGPE ), .T.)

		cMsg:= OemtoAnsi(STR0014)+" "+ OemtoAnsi(STR0008)+", "  //"A Entidade escolhida"  ## não possui todos os campos necessários preenchidos
		cMsg:= cMsg+OemtoAnsi(STR0016)+" "+ OemtoAnsi(STR0001)+"."+CRLF // para contemplar o cadastro ## Informações Excluvisas Estágio

		If (cVersEnvio < "9.0")
			cMsg:= cMsg+OemtoAnsi(STR0036)+", "		//"CNPJ Válido e diferente de '00000000000000'"
			cMsg:= cMsg+OemtoAnsi(STR0019)+", "		//"Descrição"
			cMsg:= cMsg+OemtoAnsi(STR0020)+", "		//"Endereço"
			cMsg:= cMsg+OemtoAnsi(STR0021)+", "		//"Estado"
			cMsg:= cMsg+OemtoAnsi(STR0023)+"."			//"CEP"
		Else
			cMsg:= cMsg+OemtoAnsi(STR0036)+" "+OemtoAnsi(STR0042)+" "		//"CNPJ Válido e diferente de '00000000000000' ou "
			cMsg:= cMsg+OemtoAnsi(STR0020)+", "		//"Endereço"
			cMsg:= cMsg+OemtoAnsi(STR0021)+", "		//"Estado"
			cMsg:= cMsg+OemtoAnsi(STR0023)+"."			//"CEP"
		Endif

		If ((cVersEnvio < "9.0") .Or. (cVersEnvio >= "9.0" .And. !Empty(RA0->RA0_CGC)))
			If (RA0->RA0_CGC=='00000000000000')
				Help( ,, 'HELP',, cMsg, 1, 0 )
				Return .F.
			EndIf
		Endif

		If cEFDAviso <> "2"

			If (  (cVersEnvio < "9.0" .And. (empty(RA0->RA0_CGC) .OR. empty(RA0->RA0_ENDERE) .OR. empty(RA0->RA0_CEP) .OR. empty(RA0->RA0_ESTADO) .OR. empty(RA0->RA0_DESC))) .Or. ;
				(cVersEnvio >= "9.0" .And. (empty(RA0->RA0_CGC) .And. (empty(RA0->RA0_ENDERE) .OR. empty(RA0->RA0_CEP) .OR. empty(RA0->RA0_ESTADO)) )) )

				If cEFDAviso == "1"
					Help( ,, 'HELP',, cMsg, 1, 0 )
					lRet:= .F.
				Else
					Aviso(OemtoAnsi(STR0015),OemtoAnsi(cMsg),{OemtoAnsi(STR0017)}) //"Atencao" ## Como a categoria do Funcionario eh estagiario, apresentaremos o cadastro ## Informacoes Exclusivas do Estagio ## "OK" ##
				EndIf

			EndIf
		EndIf
	EndIf

Return lRet

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ fGP920Coor()	³Autor³  Glaucia M.       ³ Data ³01/07/2013³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Complemento da validação do campo RFS_COORD                 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³fGP920Coor()             									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA920 - Campo RFS_COORD                                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³Boolean														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³Nenhum                            	     					³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function fGP920Coor( )

	Local lRet	:=	.T.
	Local cMsg

	//Posiciono na tabela para garantir abertura quando MVC e ExecAuto
	dbSelectArea("RD0")
	dbSetOrder(1) //RD0_FILIAL+RD0_CODIGO
	If RD0->(dbSeek(xFilial("RD0",SRA->RA_FILIAL)+&(ReadVar())))
		Iif( cPaisLoc == "BRA" .And. FindFunction("fVersEsoc"), fVersEsoc( "S2300", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, @cVersGPE ), .T.)

		If (cVersEnvio < "9.0")
			If cEFDAviso <> "2"
				cMsg:= OemtoAnsi(STR0026)+" "+ OemtoAnsi(STR0008)+", "  //"O Coordenador de Estagio escolhido"   ## não possui todos os campos necessários preenchidos
				cMsg:= cMsg+OemtoAnsi(STR0016)+" "+ OemtoAnsi(STR0001)+"."+CRLF // para contemplar o cadastro ## Informações Excluvisas Estágio

				cMsg:= cMsg+OemtoAnsi(STR0025)+CRLF	//"Os campos necessarios para Entidade, são:"
				cMsg:= cMsg+OemtoAnsi(STR0027)+" e "			//"Nome"
				cMsg:= cMsg+OemtoAnsi(STR0024)+"."			//"CPF"

				If empty(RD0->RD0_NOME) .OR. empty(RD0->RD0_CIC)
					If cEFDAviso == "1"
						lRet:= .F.
						Help( ,, 'Help',, cMsg, 1, 0 )
					Else
						Aviso(OemtoAnsi(STR0015),OemtoAnsi(cMsg),{OemtoAnsi(STR0017)}) //"Atencao" ## Como a categoria do Funcionario eh estagiario, apresentaremos o cadastro ## Informacoes Exclusivas do Estagio ## "OK" ##
					EndIF

				EndIf
			EndIf
		Endif
	EndIf

Return lRet

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ fGP920DtFm()	³Autor³  Glaucia M.       ³ Data ³03/07/2013³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Complemento da validação do campo RFS_DTFIM                 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³fGP920DtFm()             									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA920 - Campo RFS_DTFIM                                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³Boolean														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³Nenhum                            	     					³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function fGP920DtFm()

	Local lRet	:=	.T.

	If (SRA->RA_ADMISSA >= FwfldGet("RFS_DTFIM")  )
		lRet:= .F.
		Help( ,, 'Help',, OemtoAnsi(STR0029), 1, 0 ) //"A data prevista para o termino do estagio devera ser maior que a Data de Admissao."
	EndIf

Return lRet

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ fG920PrVAL()	³Autor³  Glaucia M.       ³ Data ³11/07/2013³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Pre validação RFS                                           ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³fG920PrVAL(Struct)           								³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA920 - Verifica o parametro MV_EFDAVIS, e se necessario  ³
³          ³tornara os campos do cadastro RFS-Estagio obrigatorio       ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³Boolean														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³Nenhum                            	     					³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fG920PrVAL(oStruRFS)
If ((SRA->RA_CATFUNC $ 'E*G') .OR. fGP010FoiE())
	If SRA->RA_CATEFD == "906"
		oStruRFS:SetProperty('RFS_NIVEL',	MODEL_FIELD_OBRIGAT, .F. )
		oStruRFS:SetProperty('RFS_COORD',	MODEL_FIELD_OBRIGAT, .F. )
		oStruRFS:SetProperty('RFS_COORD',	MODEL_FIELD_WHEN, {||.F.})
		oStruRFS:SetProperty('RFS_AGENTE',	MODEL_FIELD_WHEN, {||.F.})
	ElseIf SRA->RA_CATEFD == "901"
		oStruRFS:SetProperty('RFS_NIVEL',	MODEL_FIELD_OBRIGAT, .T. )
	EndIf
Endif
Return .T.

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ fG920RFSpo()	³Autor³  Glaucia M.       ³ Data ³11/07/2013³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Pos validacao                                               ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³fG920RFSpo()           							         	³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA920 - Verifica o parametro MV_EFDAVIS, e se necessario  ³
³          ³emitira apenas um alerta que os campos necessarios nao      ³
³          ³foram preenchidos.                                          ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³Boolean														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³Nenhum                            	     					³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function fG920RFSpo()
	Local	oModel		:=	FWModelActive()
	Local	oModelRFS	:=	oModel:GetModel('RFSMASTER')
	Local 	cMsg		:=""
	Local	lRet		:= .T.

	cMsg	:=OemToAnsi(STR0034)		//"Um ou mais dos campos da Pasta ESTAGIO: Natureza, Nivel, Entidade, Agente,"
	cMsg	:= cMsg+OemToAnsi(STR0035)	//" Coordenador ou Data Prevista Final Estágio, está(o) vazio(s), mas a gravação da informação será realizada normalmente."

	If SRA->RA_CATEFD == "906"
		If oModelRFS:GetValue('RFS_NATUR') <> "2"
			Help( " ", 1, OemToAnsi(STR0015),, OemToAnsi(STR0046), 1, 0 )	//ATENCAO"###"O campo Natureza do Estágio deve ser preenchido com: 2-Não obrigatório."
			lRet := .F.
		ElseIf oModelRFS:GetValue('RFS_NIVEL') == "9"
			Help( " ", 1, OemToAnsi(STR0015),, OemToAnsi(STR0047), 1, 0 )	//ATENCAO"###"O campo Nível de estágio não pode ser preenchido com 9 para a categoria 906."
			lRet := .F.
		EndIf
	ElseIf cEFDAviso == '0' .AND. ((SRA->RA_CATFUNC $ 'E*G') .OR. fGP010FoiE())
		If (empty(oModelRFS:GetValue('RFS_NATUR')) .OR. empty(oModelRFS:GetValue('RFS_NIVEL'))) .OR. (empty(oModelRFS:GetValue('RFS_ENTIDA')) .OR. empty(oModelRFS:GetValue('RFS_AGENTE')) .OR. empty(oModelRFS:GetValue('RFS_COORD')) .OR. empty(oModelRFS:GetValue('RFS_DTFIM')))
			Aviso(OemtoAnsi(STR0015),OemtoAnsi(cMsg),{OemtoAnsi(STR0017)}) //"Atencao" ## "OK" ##
		EndIf
	EndIf
Return lRet

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ f927Comm   	³Autor³  Glaucia M.       ³ Data ³23/07/2014³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Commit do Model para integracao com o TAF                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³f927Comm(oModel)           						         	³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA920 - Verifica o parametro MV_INTTAF, e se necessario   ³
³          ³integrara com o modulo TAF.                                 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³Boolean														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³O Model para "commit" dos dados    	     					³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fG920Com(oModel)
Local aArea			:= GetArea()
Local lRet			:= .T.
Local cCPF			:= ""
Local cCateg 		:= ""
Local cMatTemp 		:= ""
Local cTrabVincu	:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|306|307|309"
Local cTrabSemVincu	:= fCatTrabEFD("TSV") //"201|202|305|308|401|410|701|711|712|721|722|723|731|734|738|741|751|761|771|781|901|902|903"
Local aTpAlt		:= {.F., .F., .F., .F.}
Local lTpEst		:= .F.
Local oMdlRFS		:= oModel:GetModel("RFSMASTER")
Local cVersEnvio	:= ""
Local cChave 		:= ""
Local lGeraMat		:= SRA->(ColumnPos("RA_DESCEP")) > 0 .And. SRA->RA_DESCEP == "1"

cCPF	   := SRA->RA_CIC
cCateg	:= Iif(SRA->RA_CATEFD $ "901|906",SRA->RA_CATEFD,"")

cMatTemp:= SRA->RA_MAT

//--------------------------------
//| Verifica se existe integração
//--------------------------------
If (lIntTAF .Or. lMiddleware) .AND. FunName() != "GPEM035"

	If FindFunction("fVersEsoc")
		fVersEsoc( "S2300", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio )
	Else
		cVersEnvio := '2.2'
	EndIf

	//Montando chave do trabalhador

	If !lMiddleware
		If cVersEnvio >= "9.0"
			cChave := AllTrim( SRA->RA_CIC ) + ";" + Iif(lGeraMat, SRA->RA_CODUNIC, "") + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
		Else
			cChave := AllTrim( SRA->RA_CIC ) + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
		EndIf
	Else
		If cVersEnvio >= "9.0" .And. lGeraMat
			cChave := AllTrim( SRA->RA_CODUNIC)
		Else
			cChave := AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + DTOS( SRA->RA_ADMISSA )
		EndIf
	Endif

	If !(EMPTY(cCPF)) .and. cCateg $ "103*901*906"
		If !lMiddleware
			cStatus := TAFGetStat( "S-2300", cChave )
		Else
			cStatus := "-1"
			fPosFil( cEmpAnt, SRA->RA_FILIAL )
			aInfoC   := fXMLInfos()
			If LEN(aInfoC) >= 4
				cTpInsc  := aInfoC[1]
				lAdmPubl := aInfoC[4]
				cNrInsc  := aInfoC[2]
			Else
				cTpInsc  := ""
				lAdmPubl := .F.
				cNrInsc  := "0"
			EndIf
			cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2300" + Padr(cChave,fTamRJEKey(), " ")
			cStatus 	:= "-1"
			//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
			GetInfRJE( 2, cChaveMid, @cStatus )
		EndIf
		cStat1 := "-1"

		//Verificação de qual o tipo de alteração foi realizada - RFS
		fVerAltEst(@lTpEst, oMdlRFS)

		//Verificação de qual o tipo de alteração foi realizada - SRA
		lRet := fVerTpAlt(@aTpAlt,lRet,lTpEst, cVersEnvio)

		If cCateg $ cTrabSemVincu .AND. lRet
			//---------------------------------------
			//| Verifica existencia ou Status <> "4"
			//| Se status <> "4" ou não existir, cria reg
			//--------------------------------------------
			If ( aTpAlt[1] .OR. aTpAlt[2] )
				lRet := fInt2300New("SRA", /*lAltCad*/, 3,"S2300",/*cTFilial*/,/*aDadosXml*/,cVersEnvio,.T., oMdlRFS)
			Else
				//-----------------------------------------
				//| Registro Status == "4" e tem alteração
				//| Verifica se foi alteração cadastral ou contratual
				//| Faz uma analise dentro da SRA (Cad/Con) e RFS (Con)
				//------------------------------------------------------
				If aTpAlt[3] .And. M->RA_SITFOLH <> "D"
					lRet := fIntAdmiss("SRA",,4,"S2205",,,)
				EndIf

				If aTpAlt[4]
					lRet := fInt2306New("SRA",/*lAltCad*/, 4,"S2306",/*cTFilial*/,/*dtEf*/,cVersEnvio ,.T.,oMdlRFS)

				EndIf
			Endif

			If lRet
				If FindFunction("fEFDMsg")
					fEFDMsg()
				EndIf

				FWFormCommit(oModel)
			EndIf
		Endif
	EndIf

Else
	FWFormCommit(oModel)
EndIf

If (lIntTaf .Or. lMiddleware) .AND. (Findfunction("fGP26SRA")) .AND. !(EMPTY(cCPF)) .AND. !(EMPTY(cCateg) )
	fGP26SRA(cCPF,cCateg,cMatTemp,3,"GPEA920")
EndIf

RestArea(aArea)
Return lRet

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Funcao    ³ fVerAltEst   	³Autor³  Marcos Coutinho   ³ Data ³20/07/2017³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ³
³Descricao ³Realizar a verificacao das alteracoes do estagiario         ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
³Sintaxe   ³fVerAltEst( lTpEst )          						         	³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
³ Uso      ³GPEA920 - Verifica se houve alguma alteração no registro    ³
³          ³corrente do estagiário                                      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
³ Retorno  ³Boolean													            	³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
³Parametros³ Uma variavel lógica base para retorno             			³
ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function fVerAltEst( lTpEst, oMdl )
Local aCpos := {}
Local nI := 0
Local cTrabSemVinc:= fCatTrabEFD("TSV") //"201|202|305|308|401|410|701|711|712|721|722|723|731|734|738|741|751|761|771|781|901|902|903" //Trabalhador sem vinculo
Default lTpEst := .F.
aCpos := {"RFS_NATUR", "RFS_NIVEL", "RFS_ATUA", "RFS_APOLIC", "RFS_DTFIM", "RFS_ENTIDA", "RFS_AGENTE", "RFS_COORD"}

If cPaisLoc == "BRA"
	If SRA->RA_CATEFD $ cTrabSemVinc
		For nI := 1 To Len(aCpos)
			if &('RFS->' + aCpos[nI]) <> oMdl:GetValue(aCpos[nI])
				lTpEst := .T.
			Endif
		neXT nI
	EndIf
EndIf
Return

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ fGP920Coor()	³Autor³  Glaucia M.       ³ Data ³01/07/2013³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Complemento da validação do campo RFS_COORD                 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³fGP920Coor()             									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA920 - Campo RFS_COORD                                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³Boolean														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³Nenhum                            	     					³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function fGP920Age( )

	Local lRet	:=	.T.
	Local cMsg

	//Posiciono na tabela para garantir abertura quando MVC e ExecAuto
	dbSelectArea("RFR")
	dbSetOrder(1) //RFR_FILIAL+RFR_AGENTE
	If RFR->(dbSeek(xFilial("RFR")+&(ReadVar())))
		If (ExistFunc( 'fVersEsoc' ), fVersEsoc( "S2300", .F.,,,@cVersEnvio, @cVersGPE),)

		If Empty(cVersGPE)
			cVersGPE := cVersEnvio
		EndIf

		If (cVersEnvio <= "2.5")
			If cEFDAviso <> "2"
				cMsg:= OemtoAnsi(STR0043)+" "+ OemtoAnsi(STR0008)+", "  //"O Agente de Estágio escolhido"   ## não possui todos os campos necessários preenchidos
				cMsg:= cMsg+OemtoAnsi(STR0016)+" "+ OemtoAnsi(STR0001)+"."+CRLF // para contemplar o cadastro ## Informações Excluvisas Estágio

				cMsg:= cMsg+OemtoAnsi(STR0044)+CRLF	//"Os campos necessários para Agente de Estágio são:"
				cMsg:= cMsg+OemtoAnsi(STR0027)+", "								//"Nome"
				cMsg:= cMsg+OemtoAnsi(STR0020)+", "								//"Endereço"
				cMsg:= cMsg+OemtoAnsi(STR0028)+", "								//"Bairro"
				cMsg:= cMsg+OemtoAnsi(STR0023)+", "								//"CEP"
				cMsg:= cMsg+OemtoAnsi(STR0022)+" " + OemToAnsi(STR0045) + " "	//"Código Município" ## "e"
				cMsg:= cMsg+OemtoAnsi(STR0021)+"."								//"Estado"

				If empty(RFR->RFR_NOME) .OR. empty(RFR->RFR_END) .OR. empty(RFR->RFR_BAIRRO) .OR. empty(RFR->RFR_CEP) .OR. empty(RFR->RFR_CODMUN) .OR. empty(RFR->RFR_UF)
					If cEFDAviso == "1"
						lRet:= .F.
						Help( ,, 'Help',, cMsg, 1, 0 )
					Else
						Aviso(OemtoAnsi(STR0015),OemtoAnsi(cMsg),{OemtoAnsi(STR0017)}) //"Atencao" ## Como a categoria do Funcionario eh estagiario, apresentaremos o cadastro ## Informacoes Exclusivas do Estagio ## "OK" ##
					EndIF

				EndIf
			EndIf
		Endif
	EndIf

Return lRet
