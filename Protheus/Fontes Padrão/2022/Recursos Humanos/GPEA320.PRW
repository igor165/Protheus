#define Confirma 1
#define Redigita 2
#define Abandona 3

#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'GPEA320.CH'
#INCLUDE 'HEADERGD.CH'

Static lIncluir := .F.
Static aEfd     := If( cPaisLoc == 'BRA', If(Findfunction("fEFDSocial"), fEFDSocial(), {.F.,.F.,.F.,.F.,.F.}), {.F.,.F.,.F.,.F.,.F.} )  //Statics com carga devido ao acesso via outros modulos destas variaveis
Static lIntTAF  := Iif( aEfd[4], ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 0 ), ( .F. ) )  //Integracao com TAF
Static cVersEnvio := ""
Static cVersGPE := ""
Static cFilRet  := ""
Static lMiddleware := Iif(cPaisLoc == 'BRA' .And. findfunction("fVerMW") , fVerMW(),SuperGetMv("MV_MID",, .F.))
Static cVerTaf     := StrTran(StrTran(SuperGetMv("MV_TAFVLES",, "2.4"), "_", "."), "0", "", 1, 2)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao      ³GPEA320 ³ Autor         ³ RH - Natie    ³ Data ³ 19/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao   ³Manutencao de Parametros                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe     ³GPEA320()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³Generico ( DOS e Windows )                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ FNC           ³  Motivo da Alteracao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Leandro Dr. ³27/09/12|M12RH01        |Req.RHU210- Unificacao das folhas³±±
±±³Raquel Hager³01/11/12|M12RH01 RQ002  |Unificacao das folhas.           ³±±
±±³Raquel Hager³18/01/12³M12RH01 RQ003  ³Remocao de filtro para Gestao    ³±±
±±³            ³        ³               ³Publica e inclusao da funcao     ³±±
±±³            ³        ³               ³AjustaSxb.                       ³±±
±±³Raquel Hager³25/09/13³M12RH01 RQ003  ³Compatibilizavao Ver. 11.80 =>   ³±±
±±³            ³        ³               ³Tratamento no gp320LinOk p/ BRA. ³±±
±±³Christiane V³08/05/14³ TPMJR2        ³Alteração da função Gp320aCols p/³±±
±±³            ³        ³               ³tratamento especifico de data em ³±±
±±³            ³        ³               ³branco só na ultima coluna.      ³±±
±±³Cecilia Car.³12/05/14³M_RH003 002974 ³Retirada da funcao fFiltrAsMed.  ³±±
±±³M. Silveira ³23/07/14³TPYGOZ         ³Ajuste para impedir a gravacao de³±±
±±³            ³        ³               ³codigo de Filial invalido.       ³±±
±±³Gustavo M.  ³18/09/14³TQPJB9         ³Ajuste na tela da importacao de  ³±±
±±³            ³        ³               ³tabelas.					      ³±±
±±³Luis Artuso ³19/01/15³		  TRHZRV³Alteracao p/ nao remontar todas  ³±±
±±³            ³        ³		   	    ³sequencias ao realizar o tudOk() ³±±
±±³            ³        ³				³pois esse processo e' desnecessa-³±±
±±³            ³        ³				³rio uma vez que ja e' realizado  ³±±
±±³            ³        ³				³no linOk() da alteracao da linha.³±±
±±³Allyson M.  ³20/01/15³TRJOUU         ³Ajuste p/ montagem correta das   ³±±
±±³            ³        ³               ³sequencias.				      ³±±
±±³Cícero Alves³04/03/15³		        ³ Retirada da função AjustaSXB    ³±±
±±³            ³        ³               ³				  				  ³±±
±±³Henrique V. ³09/03/15³TRSYNL         ³Correção para sistema validar as ³±±
±±³            ³        ³               ³Filiais de todos os grupos de emp³±±
±±³            ³        ³               ³resas cadastrados, quando usuário³±±
±±³            ³        ³               ³inclui registros de grupos de emp³±±
±±³            ³        ³               ³resas diferentes do grupo logado.³±±
±±³Henrique V. ³10/03/15³TRTGQH         ³Correção para sistema não mudar a³±±
±±³            ³        ³               ³ordem dos registros de tabelas   ³±±
±±³            ³        ³               ³auxiliares quando o usuário entra³±±
±±³            ³        ³               ³Alterando a tabela.              ³±±
±±³L.Trombini  ³30/03/15³TRVEDP         ³ajustado para o sistema acertar a³±±
±±³            ³        ³               ³sequencia das tabelas Auxliares  ³±±
±±³            ³        ³               ³quando a tabela não utiliza chave³±±
±±³            ³        ³               ³ano mes fixo (retornado Sort)    ³±±
±±³Marcos Perei³03/09/2015³PCREQ-5342   ³Produtiz. Gestão Pública na 12.  ³±±
±±³Mariana M   ³08/10/15³TTIOCY         ³Alteracao na ordenacao da SX3 na ³±±
±±³            ³        ³		   	    ³montagem do aCols da inclusao    ³±±
±±³Marcos Perei³11/11/2015³PCREQ-5342   ³Tratamento provisorio ColumnPos  ³±±
±±³            ³        ³               ³que devera ser retirado quando   ³±±
±±³            ³        ³               ³liberar o dicionario da 12.1.8   ³±±
±±³Allyson M   ³08/12/15³TTXAW6         ³Validacao especifica p/ tabela   ³±±
±±³            ³        ³		   	    ³S043.    						  ³±±
±±³Claudinei S.³26/02/16³TUCD45         ³Alterada a S043 para permitir    ³±±
±±³            ³        ³		   	    ³Aviso Trab. e Saldo de Salario.  ³±±
±±³Leandro Dr. ³29/02/16³TULL47         ³Retirado validacao anterior.     ³±±
±±³Esther V.   ³29/06/16³   TVMNZA      ³Ajuste na variavel lGestPubl.    ³±±
±±³Victor A.   ³28/07/16³TVLQOD         ³Ajuste para verificar se período ³±±
±±³            ³        ³		   	    ³informado é menor que 201001,    ³±±
±±³            ³        ³		   	    ³pois anterior a essa data não era³±±
±±³            ³        ³		   	    ³obrigat. mais de 3 faixas IR-S002³±±
±±³Gustavo M.  ³27/12/16³MRH-3404       ³Ajuste declaração da variavel.   ³±±
±±³Allyson M   ³28/12/16³MRH-1357       ³Ajuste p/ validar preenchimento  ³±±
±±³            ³        ³		   	    ³de filial e período da S033.	  ³±±
±±³Marcos Cout ³06/04/17³DRHESOCP-78    ³Realizar ajustes para que não    ³±±
±±³            ³        ³		   	    ³seja gerado Error.Log quando se é³±±
±±³            ³        ³		   	    ³apagado todos os registros da ta_³±±
±±³            ³        ³		   	    ³bela S119.                       ³±±
±±³Oswaldo L   ³27/06/17³DRHESOCP-516   ³Remover coluna CTRDEF            ³±±
±±³Oswaldo L   ³28/06/17³DRHESOCP-516   ³Tratar contrato aprendiz zerado  ³±±
±±³Oswaldo L   ³03/07/17³DRHESOCP-516   ³Deixar não editavel -coluna Cod. ³±±
±±³Oswaldo L   ³04/07/17³DRHESOCP-516   ³Alteracao efetuada para S119 120 ³±±
±±³Oswaldo L   ³13/07/17³DRHESOCP-588   ³Acerto Verificação linha não     ³±±
±±³            ³        ³               ³deletada antes de exibir msg     ³±±
±±³Marcos Cout ³10/08/17³DRHESOCP-847   ³Subir fonte somente para atuali- ³±±
±±³            ³        ³               ³zar RPO 12.1.16                  ³±±
±±³Marcos Cout ³11/08/17³DRHESOCP-766   ³Realizada a criação do botão de  ³±±
±±³            ³        ³               ³atualização das tabelas d eSocial³±±
±±³            ³        ³               ³função fAttTab()                 ³±±
±±³Marcos Cout ³31/08/17³DRHESOCP-628   ³Realizada ajustes necessários par³±±
±±³            ³        ³               ³a carga dos dados criados        ³±±
±±|Claudinei S.|14/09/17| DRHESOCP-1018 |Consistência do leiaute 2.3 para |±±
±±|            |        |               |as tabelas S048 e S049 e S119.   |±±
±±|Oswaldo L   |24/11/17|DRHPAG-9000    |Carga GPS a partir do Financeiro |±±
±±³Eduardo Vice³02/02/18³DRHESOCP-2852  ³Inclusão de funcionalidade para  ³±±
±±³            ³        ³               ³integração do evento S-1020      ³±±
±±³Marcos Cout ³16/02/18³DRHESOCP-126   ³Realizando ajustes para geração  ³±±
±±³            ³        ³               ³da integração com evento S-1005 a³±±
±±³            ³        ³               ³partir da manutenção de tabelas. ³±±
±±|Eduardo vic ³02/03/18³DRHESOCP-3167  ³inclusão de validação de tab     ³±±
±±³            ³        ³               ³compartilhada.					  ³±±
±±³Eduardo K.  ³02/03/18³MPRIMESP-14098 ³Ajuste p/ função fDtIR34 validar ³±±
±±³            ³        ³               ³somente a tabela S002            ³±±
±±³WinstonCosta³02/01/19³DRHPAG-22991   ³Retirada do trecho que trata o AS/400³±±
±±³Wesley Alves³02/10/20³DRHGCH-21323   ³Bloqueio de tabelas GUPY         ³±±
±±³Pereira     ³        ³               ³para acesso por permissao (CNPJ) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */

Function GPEA320
	Local   aArea		 := GetArea()
	Local   aAreaRCB	 := RCB->(GetArea())
	Local   aAreaRCC	 := RCC->(GetArea())
	Local 	lManutence 	 := .F.
	Local 	lGPERM		 := GetNewPar("MV_CLASSIS", .F.) //Verifica se a integracao entre os sistemas Protheus x RM Classis Net (RM) esta ativa

	Local aRetGPE 	:= {.F., ""}
	Local aRetTAF	:= {.F., ""}
	Local cVersEnvio, cVersGPE := ""
	Local lIntegra	:= .T.

	Private cGSPubl		 := SuperGetMv("MV_SIGAGFP", NIL, "1")
	Private cCodigo 	 := CriaVar("RCB_CODIGO")
	Private cDescri		 := CriaVar("RCB_DESC")
	Private cHelp		 := STR0175
	Private cFiltraRCC					// Variavel para filtro
	Private aIndexRCB	 := {}			// Variavel para filtro
	Private nP := 0
	Private aButtons     := {}
	Private lGpea320Inc  := .F.
	Private lAnoMes		 := .T.
	Public  Desabilitado := .F.
	Public 	lGestPubl 	 := if(ExistFunc("fUsaGFP"),fUsaGFP(),.f.)	//Verifica se utiliza o modulo de Gestao de Folha Publica - SIGAGFP
	Private oTmpTable	 := Nil
	Private aColsRec     := {}                   //--Array que contem o Recno() dos registros da aCols
	Private aColsAnt     := {}
	Private aEsocTpAlt	 := {}
	Private lFimTdOk 	 := .F.
	Private lAudesp := SuperGetMv('MV_AUDESP',, .F.)

	If  FindFunction("fVersEsoc")
		lIntegra := fVersEsoc("S2200", .F., @aRetGPE, @aRetTAF, @cVersEnvio, @cVersGPE)
	EndIf

	If lMiddleware .And. !ChkFile("RJ9") .And. !ChkFile("RJE")
		Help( " ", 1, OemToAnsi(STR0007),, OemToAnsi(STR0191), 1, 0 )//"Tabela RJE não encontrada. Execute o UPDDISTR - atualizador de dicionário e base de dados."
		Return
	EndIf

	Iif (Empty(cVersGPE), cVersGPE := cVersEnvio,)

	//Executa um pack na RCC
	Chk_Pack("RCC",10)

	lManutence := ( FunName() == "GPEA320M" )

	If Gp310ModComp("RCB")
		Private bFiltraBrw 	:= {|| Nil}		     // Variavel para Filtro
		Private aRotina := MenuDef()            // Ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina
		Private cCadastro := OemToAnsi(STR0001) //"Cadastro de Tabelas"

		GpIniTab()
		GpIniCRG()

		If lManutence
			aAdd(aRotina, { STR0095 , "GPE320GER" , 0 , 8 } ) // "Gerar Fonte Tabelas"
		EndIf

		aAdd(aRotina, { STR0103 , "GPE320IMP" , 0 , 8 } ) // "Importacao"

		dbSelectArea("RCB")
		dbSeek(xFilial("RCB"))
		// Inicializa o filtro utilizando a funcao FilBrowse
		cFiltraRCB	:=	'RCB_ORDEM == "01"'

		If cPaisLoc == 'BRA'

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
				If cGSPubl == "2"
					cFiltraRCB += ' .and. !(RCB_CODIGO$"S015/S019/S020/S021/S022/S023/S025/S027/S032/S033/S039/S040/S042/S045/S071/S080") '
				ElseIf cGSPubl == "3"
					cFiltraRCB += ' .and. !(RCB_CODIGO$"S015/S019/S020/S021/S022/S023/S025/S027/S032/S033/S039/S040/S045/S071/S080") '
				Else
					cFiltraRCB += ' .and. (RCB_CODIGO < "S100" .or. RCB_CODIGO >= "U000") '
				EndIf
			EndIf
			//***** Fim do filtro provisorio

			/*   Habilitar quando retirar o provisório acima
			If lGestPubl
				cFiltraRCB += ' .and. RCB_MODULO $ "2/3"'
			Else
				cFiltraRCB += ' .and. RCB_MODULO $ " /1/3"'
			EndIf
			*/

			// Tabela de Integração GUPY
			/*If GetRPORelease() < "12.1.025"
				cFiltraRCB += ' .and. !(RCB_CODIGO$"S131/S132/S133")'
			EndIf*/

			// Tabelas Middleware somente para releases superiores a 12.1.23
			If GetRPORelease() < "12.1.023"
				cFiltraRCB += ' .and. !(RCB_CODIGO $ "S135/S136/")'
			EndIf

			If !lAudesp
				cFiltraRCB += ' .and. !(RCB_CODIGO$"S066/S067/S068/S069'
				If !lGestPubl
					cFiltraRCB += '/S100/S101'
				Endif
				cFiltraRCB += '/S121/S122/S123/S125")'
			Endif
		EndIf

		If RCB->( ColumnPos( "RCB_MODULO" ) ) > 0 .And. cGSPubl == "2"
			cFiltraRCB := cFiltraRCB + " .And. " + "RCB_CODIGO <> 'S042'"
		Endif

		If !lGPERM
			cFiltraRCB := cFiltraRCB + " .And. " + "RCB_CODIGO <> 'S071'"
		EndIf
		cFiltraRh	:= CHKRH("GPEA320","RCB","1")
		If !Empty(cFiltraRh)
			cFiltraRCB := cFiltraRCB + " .And. " + cFiltraRh
		EndIf

        // Adequação para ignorar a tabela S150 - DRHROTPROT-7119
        // Tabela criada indevidamente
		cFiltraRCB += " .And. " + "RCB_CODIGO <> 'S150'"


		bFiltraBrw 	:= {|| FilBrowse("RCB",@aIndexRCB,@cFiltraRCB) }
		Eval(bFiltraBrw)

		SetBrwCHGAll( .T. ) //Nao apresentar a tela para selecionar a Filial

		// Endereca a funcao de BROWSE
		mBrowse(06,01,22,75,'RCB',, , , , , fUseCor(), , , ,)

		// Deleta o filtro utilizando a funcao FilBrowse
		EndFilBrw("RCB",aIndexRCB)
	Endif

	// Restaura Area e Ordem de Entrada
	RestArea( aArea )
	RestArea( aAreaRCC)
	RestArea( aAreaRCB)

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Gpe320Alt ³ Autor ³ R.H - Natie          ³ Data ³ 13/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Alteracao de Estrutura do Parametro.                       ³±±
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
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Gpe320Alt(cAlias,nReg,nOpcx)
	Local	nOpca		:= 0
	Local 	nCnt		:= 0
	Local	aKeys		:= Getkeys()
	Local   aArea		:= GetArea()
	Local   aAreaRCC	:= RCC->( GetArea() )
	Local   aAreaRCB	:= RCB->( GetArea() )
	// Private da Getdados
	Local   a320nField	:= {}
	Local 	aColsRec	:= {}
	Local 	cCond		:= "", cChave:= ""
	Local   cPict		:= "99"
	Local 	oFont
	Local 	oDlgMain
	// Variaveis dimensoes do objeto tela
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjSize		:= {}
	Local aObjCoords	:= {}
	Local aAdv1Size		:= {}
	Local aInfo1AdvSize	:= {}
	Local aObj1Size		:= {}
	Local aObj1Coords	:= {}
	Local bSet15        := { || }
	Local bSet24        := { || }
	Local cLink		  	:= ""
	Local lTypeN		:= Type("n") != "U"
	Local aButUser		:= {}
	Local lNewVerEsoc   := .F.
	Local lContinua     := .F.

	Private cCodigo 	:= CriaVar("RCB_CODIGO")
	Private cDescri		:= CriaVar("RCB_DESC")
	Private cFilTab 	:= CriaVar("RCC_FIL")
	Private cChavRCC	:= CriaVar("RCC_CHAVE")
	Private nOpcao 		:= nOpcx
	Private oGeT
	Private oCodigo, oDescri, oFil, oChave
	Private oGroup1, oGroup2, oGroup3
	Private oFont1, oFont2
	Private aVisual     := {}
	Private aAntes      := {}
	Private aColsBkp    := {}
	Private aCargFil := FwLoadSm0()
	Private nBkp        := 0
	Private lMsg   := .F.
	Private aAlter119 := {}

	//Bloqueio de utilização de tabelas exclusivas da integração GUPY
	If (nOpcx <> 2)
		If (RCB->RCB_CODIGO $ ("S131|S132|S133"))
			If ( Findfunction( "RhGUPYExt" ) )
				If ( ! RhGUPYExt( SM0->M0_CGC ) )
					Return (.F.)
				EndIf
			EndIf
		EndIf
	EndIf

	If !(lIncluir) .And. (nOpcx <> 2) .And. (RCB->RCB_CODIGO $ ("S120")) .And. FindFunction("ESocMsgVer")
		If lIntTaf .And. FindFunction("fVersEsoc")
			fVersEsoc("S1030", .F.,,, @cVersEnvio, @cVersGPE)
			If !lMiddleware .And. cVersGPE <> cVersEnvio .And. (cVersGPE >= "9.0" .Or. cVersEnvio >= "9.0")
				//"Atenção! A versão do leiaute GPE é xxx e a do TAF é xxx, sendo assim, estão divergentes. O Evento xxx não será integrado com o TAF, e consequentemente, não será enviado ao RET.
				//Caso prossiga a informação será atualizada somente na base do GPE. Deseja continuar?"
				If !ESocMsgVer(.F.,/*cEvento*/, cVersGPE, cVersEnvio)
					Return ()
				Else
					lIntTaf := .F.
				Endif
			EndIf
		EndIf
	Endif

	//Limpando as variaveis de apoio ao eSocial, somente se existir integração
	If lIntTaf .Or. lMiddleware
		cFilRet     := ""
		aEsocTpAlt := {}
	EndIf

	//Limpando variaveis para evitar sujeiras de registros antigos
	aColsAnt    := {}

	cCodigo		        := RCB->RCB_CODIGO
	cDescri		        := RCB->RCB_DESC

	lAnoMes := If(RCB->RCB_SHOWMA == "S", .T., .F.) // O CAMPO RCB_SHOWMA INDICA SE A COLUNA MES/ANO SERA EXIBIDA OU NAO

	// Verifica a existencia da estrutura do parametro
	dbSelectArea(cAlias)
	dbSeek( xFilial(cAlias) )
	If (Eof() .And. Bof())
		Help(" ",1,"A320SPAR") // "Nao existe tabela."-"Para cadastramento de tabelas, acesse 'Definicoes de Tabela'"
		Return
	EndIf

	// Deleta o filtro utilizando a funcao FilBrowse
	EndFilBrw("RCB",aIndexRCB)
	aIndexRCB := {}

	cAlias		:= "RCC"
	dbSetOrder(1)
	dbSeek( xFilial(cAlias)+ cCodigo )
	Do While .T.
		// Campos Nao editaveis no aCols
		a320nField	:= {"RCC_FILIAL","RCC_CODIGO","RCC_CONTEU"}
		cFilRCC		:= xFilial(cAlias)

		// Verifica existencia de registro
		dbSelectArea(cAlias)
		dbSetOrder(1)
		dbSeek( cFilRCC + cCodigo )
		While !Eof() .and. cFilRCC + cCodigo = RCC->RCC_FILIAL+RCC->RCC_CODIGO
			nCnt++
			dbSkip()
		Enddo

		If nCnt > 0  .And. nOpcx == 3      // Quando Inclusao e existir Registro
			If lGpea320Inc
				lGpea320Inc := .F.
				Exit
			EndIf
			Help(" ",1,"A310REG")         // "Ja existe registro para esta tabela", "Utilize a opcao Alterar."
			Exit
		ElseIf nCnt == 0 .And. nOpcx # 3   // Quando nao for Inclusao e nao existir Registro
			Aviso(STR0014,STR0026,{'OK'}) // "Atencao"###"Nao existem registros cadastrados para esta tabela. Utilize a opcao 'Incluir'."
			Exit
		Endif

		// Monta a entrada de dados do arquivo
		cCond	:= "RCC_FILIAL + RCC_CODIGO"
		cChave	:= xFilial("RCC")+ cCodigo
		cFilTab	:= RCC->RCC_FIL
		cChavRCC:= RCC->RCC_CHAVE
		aHeader	:= gp320aHead(a320nField,cAlias)
		aCols	:= gp320aCols(a320nField,cAlias,cCond,cChave,nOpcx,@aColsRec,@aColsAnt)

		If nOpcx==3 .And. lTypeN
			n := 1
		EndIf

		// Monta as Dimensoes dos Objetos
		aAdvSize		:= MsAdvSize()
		aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
		aAdd( aObjCoords , { 000 , 028 , .T. , .F. } )
		If cCodigo == "S119" .or. cCodigo == "S120" .or. cCodigo == "S037" .or. cCodigo == "S038"
			aAdd( aObjCoords , { 000 , 000 , .T. , .F. } )
		EndIf
		aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
		aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

		aAdv1Size		:= aClone(aObjSize[1])
		aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 1 , 1 }
		aAdd( aObj1Coords , { 070 , 000 , .F. , .T. } )
		If cCodigo == "S119" .or. cCodigo == "S120" .or. cCodigo == "S037" .or. cCodigo == "S038"
			aAdd( aObj1Coords , { 510 , 000 , .F. , .T. } )
		EndIf
		aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )
		aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords,,.T. )

		DEFINE FONT oFont  NAME "Arial" SIZE 0,-11 BOLD

		SetaPilha()

		Help := .T.

		DEFINE MSDIALOG oDlgMain TITLE OemToAnsi( cCadastro ) FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

			@ aObj1Size[1,1] , aObj1Size[1,2] GROUP oGroup1 TO aObj1Size[1,3] ,aObj1Size[1,4] LABEL OemToAnsi(STR0011) OF oDlgMain PIXEL // "Codigo da Tabela:"
			oGroup1:oFont:= oFont
			@ aObj1Size[2,1] , aObj1Size[2,2] GROUP oGroup2 TO aObj1Size[2,3] ,aObj1Size[2,4] LABEL OemToAnsi(STR0012) OF oDlgMain PIXEL // "Descricao"
			oGroup2:oFont:= oFont
			If cCodigo == "S119" .or. cCodigo == "S120"
				cLink	:= "http://tdn.totvs.com/display/PROT/ESO0013_P12_Tabelas_do_+eSocial_S119_S120"
				@ aObj1Size[3,1] , aObj1Size[3,2] GROUP oGroup3 TO aObj1Size[3,3] ,aObj1Size[3,4] LABEL OemToAnsi(STR0032) OF oDlgMain PIXEL // "Help"
				oGroup3:oFont:= oFont
			EndIf

			If cCodigo == "S037" .or. cCodigo == "S038"
				cLink	:= "http://tdn.totvs.com/x/jTS9Gw"
				@ aObj1Size[3,1] , aObj1Size[3,2] GROUP oGroup3 TO aObj1Size[3,3] ,aObj1Size[3,4] LABEL OemToAnsi(STR0032) OF oDlgMain PIXEL // "Help"
				oGroup3:oFont:= oFont
			EndIf

			@ aObj1Size[1,1]+12 , aObj1Size[1,2]+10 SAY cCodigo SIZE 050,10 OF oDlgMain PIXEL FONT oFont
			@ aObj1Size[2,1]+12 , aObj1Size[2,2]+10 SAY cDescri SIZE 120,10 OF oDlgMain PIXEL FONT oFont

			If cCodigo == "S119" .or. cCodigo == "S120"
				oButton := TButton():New( aObj1Size[3,1]+12, aObj1Size[3,2]+10, OemToAnsi(cHelp),oDlgMain,{||ShellExecute("open",cLink,"","",1)}, 60,10,,,.F.,.T.,.F.,,.F.,,,.F. )
				oGet := MSGetDados():New(aObjSize[3,1],aObjSize[3,2],aObjSize[3,3],aObjSize[3,4], nOpcx,"gp320LinOk","gp320TudOk",,If(nOpcx=2 .Or. nOpcx=5,Nil,.T.),aAlter119,,,999999)
			ElseIf cCodigo == "S037" .or. cCodigo == "S038"
				oButton := TButton():New( aObj1Size[3,1]+12, aObj1Size[3,2]+10, OemToAnsi(cHelp),oDlgMain,{||ShellExecute("open",cLink,"","",1)}, 60,10,,,.F.,.T.,.F.,,.F.,,,.F. )
				oGet := MSGetDados():New(aObjSize[3,1],aObjSize[3,2],aObjSize[3,3],aObjSize[3,4], nOpcx,"gp320LinOk","gp320TudOk",,If(nOpcx=2 .Or. nOpcx=5,Nil,.T.),,,,999999)
			else
				oGet := MSGetDados():New(aObjSize[2,1],aObjSize[2,2],aObjSize[2,3],aObjSize[2,4], nOpcx,"gp320LinOk","gp320TudOk",,If(nOpcx=2 .Or. nOpcx=5,Nil,.T.),,,,999999)
			EndIf

			oGet:lf3Header := .T.   //Habilita o uso da Consulta F3 na GetDados

			bSet15 := { ||  nOpca := 1, If(gp320TudOk(oGet),oDlgMain:End(),nOpca:=0)}
			bSet24 := { || 	RestKeys(aKeys,.T.), oDlgMain:End()}
			fChoBar320(oDlgMain,,,nOpcx) 	// Carrega opcoes em Acoes Relacionadas

			If ExistBlock("GP320BUT")
				aButUser := ExecBlock("GP320BUT",.f.,.f., {aButtons} )
				If ValType(aButUser) == "A" .and. len(aButUser) > 0
					aButtons := aButUser
				Endif
			Endif

		ACTIVATE MSDIALOG oDlgMain ON INIT EnchoiceBar(oDlgMain, bSet15, bSet24, NIL, aButtons) CENTERED
		SetaPilha()

		Help := .F.

		If nOpcA == Redigita
			Exit
		ElseIf nOpcA == Confirma .And. nOpcx # 2

			Begin Transaction

				// Gravacao
				gp320Grava(cAlias,nOpcx,If(nOpcx = 4,aColsRec,""),If(nOpcx = 4,aColsAnt,""),aCols)
				If nOpcx = 3
					lGpea320Inc	:= .T.
				EndIf
				//--Processa Gatilhos
				EvalTrigger()
			End Transaction
		EndIf
		Exit
	EndDo

	lIncluir := .F.

	//-- Restaura o filtro RCB utilizando a funcao FilBrowse
	Eval(bFiltraBrw)

	//-- Restaura Area e Ordem de Entrada
	RestArea( aArea )
	RestArea( aAreaRCC)
	RestArea( aAreaRCB)

Return( Nil )

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Gpe320Exc ³ Autor ³ RH -  Natie          ³ Data ³ 23/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exclusao.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Gpe300Excl(cAlias,nReg,nOpca)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias= Alias do arquivo                                   ³±±
±±³          ³ nREg  = Numero do registro                                 ³±±
±±³          ³ nOpca = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ GPEA320   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Gpe320Exc(cAlias,nReg,nOpcx,aAcho,aCpos,nColMens,cMensagem,cTudoOk)
Local nOpca			:= 0
Local nCnt			:= 0
Local aArea			:= GetArea()
Local aKeys			:=GetKeys()
Local aAreaRCC		:= RCC->( GetArea() )
Local aAreaRCB		:= RCB->( GetArea() )
Local a320nField 	:= {}
Local aColsRec		:= {}

Local cCond			:= ""
Local cChave        := ""
Local cPict		    := "99"
Local oFont
Local oDlgMain
// Variaveis dimensoes do objeto tela
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {}
Local lNewVerEsoc   := .F.
Local lContinua     := .F.

Private cCodigo 	:= CriaVar("RCB_CODIGO")
Private cDescri		:= CriaVar("RCB_DESC")
Private cFilTab    	:= CriaVar("RCC_FIL")
Private cChavRCC	:= CriaVar("RCC_CHAVE")
Private nOpcao 		:= nOpcx
Private oGet
Private oCodigo
Private oDescri
Private oFil
Private oChave
Private oGroup1
Private oGroup2

	//Bloqueio de utilização de tabelas exclusivas da integração GUPY
	If (RCB->RCB_CODIGO $ ("S131|S132|S133"))
		If ( Findfunction( "RhGUPYExt" ) )
			If ( ! RhGUPYExt( SM0->M0_CGC ) )
				Return (.F.)
			EndIf
		EndIf
	EndIf

	If (RCB->RCB_CODIGO $ ("S120")) .And. FindFunction("ESocMsgVer")
		If lIntTaf .And. FindFunction("fVersEsoc")
			fVersEsoc("S1030", .F.,,, @cVersEnvio, @cVersGPE)
			If !lMiddleware .And. cVersGPE <> cVersEnvio .And. (cVersGPE >= "9.0" .Or. cVersEnvio >= "9.0")
				//"Atenção! A versão do leiaute GPE é xxx e a do TAF é xxx, sendo assim, estão divergentes. O Evento xxx não será integrado com o TAF, e consequentemente, não será enviado ao RET.
				//Caso prossiga a informação será atualizada somente na base do GPE. Deseja continuar?"
				If !ESocMsgVer(.F.,/*cEvento*/, cVersGPE, cVersEnvio)
					Return ()
				Else
					lIntTaf := .F.
				Endif
			EndIf
		EndIf
	Endif

	//Limpando as variaveis de apoio ao eSocial, somente se existir integração
	If lIntTaf .Or. lMiddleware
		cFilRet     := ""
		aEsocTpAlt := {}
	EndIf

	//Limpando variaveis para evitar sujeiras de registros antigos
	aColsAnt    := {}

	// Monta as Dimensoes dos Objetos
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
	aAdd( aObjCoords , { 000 , 028 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

	aAdv1Size		:= aClone(aObjSize[1])
	aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 1 , 1 }
	aAdd( aObj1Coords , { 070 , 000 , .F. , .T. } )
	aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )
	aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords,,.T. )

	// Campos Nao editaveis
	a320nField	    := {"RCC_FILIAL","RCC_CODIGO","RCC_CONTEU"}

	cFilRCB		    := RCB->RCB_FILIAL
	cCodigo		    := RCB->RCB_CODIGO
	cDescri		    := RCB->RCB_DESC

	cAlias		:= "RCC"
	DbSelectArea(cAlias)
	dbSetOrder(1)
	dbSeek( xFilial(cAlias)+ cCodigo )
	If RCC->( Eof() )
		Help(" ",1,"A320NPAR")	// "Nao existem lancamentos para esta tabela."
		Return
	EndIf

	If cPaisLoc == "BRA" .and. cCodigo == "S046"
		MsgAlert(OemToAnsi(STR0117), OemToAnsi(STR0083))	// "Não é possível efetuar a exclusão da tabela de códigos de movimentação"###"Atencao"
		Return
	EndIf

	// Deleta o filtro utilizando a funcao FilBrowse
	EndFilBrw("RCB",aIndexRCB)
	aIndexRcb := {}

	// Monta a entrada de dados do arquivo
	cCond	:= "RCC_FILIAL+ RCC_CODIGO"
	cChave	:= xFilial("RCC")+ cCodigo
	aHeader	:= gp320aHead(a320nField,cAlias)
	aCols	:= gp320aCols(a320nField,cAlias,cCond,cChave,nOpcx,@aColsRec,@aColsAnt)

	DEFINE FONT oFont  NAME "Arial" SIZE 0,-11 BOLD

	SetaPilha()

		DEFINE MSDIALOG oDlgMain TITLE OemToAnsi( cCadastro ) FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

			@ aObj1Size[1,1] , aObj1Size[1,2] GROUP oGroup1 TO aObj1Size[1,3] ,aObj1Size[1,4]  LABEL OemToAnsi(STR0011) OF oDlgMain PIXEL  // "Codigo da Tabela"
			oGroup1:oFont:= oFont
			@ aObj1Size[2,1] , aObj1Size[2,2] GROUP oGroup2 TO aObj1Size[2,3] ,aObj1Size[2,4] LABEL OemToAnsi(STR0012) OF oDlgMain PIXEL   // "Descricao"
			oGroup2:oFont:= oFont

			@ aObj1Size[1,1]+12 , aObj1Size[1,2]+10      SAY cCodigo SIZE 050,10 OF oDlgMain PIXEL FONT oFont
		 	@ aObj1Size[2,1]+12 , aObj1Size[2,2]+10 SAY cDescri SIZE 120,10 OF oDlgMain PIXEL FONT oFont

			oGet := MSGetDados():New(aObjSize[2,1],aObjSize[2,2],aObjSize[2,3],aObjSize[2,4],nOpcx,"",,,,,,,999999 )

		ACTIVATE MSDIALOG oDlgMain ON INIT EnchoiceBar(oDlgMain,{|| nOpca := 1,oDlgMain:End(),.F. },{||oDlgMain:End()},,,nOpcx ) CENTERED

	SetaPilha()

	If nOpcA == Confirma  .and. nOpcx = 5  //-- Confirma Exclusao
		Begin Transaction
		// Exclusao na RCC
			dbSelectArea( "RCC" )
			dbSetOrder(1)
			If dbSeek( cFilRCB + cCodigo )
				While cFilRCB + cCodigo == RCC->RCC_FILIAL+RCC->RCC_CODIGO .And. !Eof()
					RecLock("RCC",.F.,.T.)
					dbDelete()
					MsUnlock()
					DbSkip()
				EndDo
			EndIf
		End Transaction
	Endif

	// Restaura o filtro RCB utilizando a funcao FilBrowse
	Eval(bFiltraBrw)

	// Restaura Area e Ordem de Entrada
	RestArea( aArea )
	RestArea( aAreaRCC)
	RestArea( aAreaRCB)

Return( Nil )


/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ gp320Grava ³ Autor ³ Natie               ³ Data ³ 27/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gravacao na tabela RCC.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function gp320Grava(cAlias,nOpcx,aColsRec,aColsAnt,aCols)
Local nPosCha		:= 	GdFieldPos("RCC_CHAVE")
Local nPosFil		:= 	IIf(GdFieldPos("RCC_FIL") > 0,GdFieldPos("RCC_FIL"), 1)
Local nPosSeq		:= 	GdFieldPos("RCC_SEQUEN")
Local nMaxArray		:=	Len(aHeader)
Local nX 			:= 	0
Local nY			:= 	0
Local nCntDel		:=  0
Local nRecno		:=  0.00
Local aChaves		:= {}
Local xConteudo		:= ""
Local cChave		:= ""
Local nSeq			:= 0
Local nTam			:= TAMSX3("RCC_SEQUEN")[1]
Local nCont			:= 0
Local nAux			:= 0
Local nPos1			:= 0
Local nPos2			:= 0
Local nPos3			:= 0
Local aLogProc		:= {}
Local aDados		:= {}
Local aFilInTaf		:= {}
Local aArrayFil		:= {}
Local aDdsC1E		:= {}
Local aDdsInt		:= {}
Local aTitle		:= {}
Local aAuxTAb		:= {}
Local lComFilial	:= .F.
Local lExbMsgAlt	:= .F.
Local lInteg		:= .F.
Local nI            := 0

Local dDataAux		:= dDataBase
Local cData			:= cValToChar( StrZero( Month(dDataAux), 2 ) ) + cValToChar( Year(dDataAux))
Local lValidado		:= .F.
Local aRegs			:= {}
Local lInconsist	:= .F. //.F. Não existe | .T. Existe
Local lParcial		:= .F.
Local lMsg			:= .F.
Local lCompleto		:= .F.
Local lRJ4			:= .F.
Local lContinua		:= .F.
Local aSM0			:= {}
Local cModoRCC		:= ""
Local nSizeEmp		:= 0
Local nSizeUn		:= 0
Local cGrvChav		:= ""
Local nY			:= 0
Local nPosHFil		:= 0
Local nPosFilTaf	:= 0
Local aFilTafAux	:= Array(1)

	If !lMiddleware
		If fIsCorpManage( cEmpAnt )
			cModoRCC 	:= FWModeAccess("RCC",1) + FWModeAccess("RCC",2) + FWModeAccess("RCC",3)
			nSizeEmp	:= Len(FWSM0Layout(cEmpAnt, 1))
			nSizeUn		:= Len(FWSM0Layout(cEmpAnt, 2))
		EndIf
	EndIf

	ValidCols()

	nUsado 	:= Len(aHeader)

	dbSelectArea(cAlias)

	If Len(aColsRec) <> 0 .Or. !Empty(aCols)

		If !fCompArray( aCols , aColsAnt )
			If ((lIntTAF .Or. lMiddleware) .AND. cCodigo $ "S037|S038|S119|S120" .And. ( IIF(FindFunction("fChkFMat"),lRet:=(fChkFMat("S-1020") .Or. fChkFMat("S-1005")),.T.)))

				If lMiddleware
					aSM0 := FWLoadSM0(.T.,,.T.)
				EndIf

				lRJ4 := FindFunction("fVldRJ4") .And. fVldRJ4(.F.)

				If lRJ4
					If (cCodigo == "S119" .and. aScan(acols, {|x| !empty(x[6]) } ) <= 0) .or. (cCodigo == "S120" .and. aScan(acols, {|x| !empty(x[4]) } ) <= 0)
						lContinua := .T.
					Else
						lContinua := .F.
					EndIf
				ElseIf cCodigo $ "S119|S120"
					lContinua := .T.
				EndIf

				lCompleto := FindFunction("fVldObraRJ") .And. fVldObraRJ(@lParcial, lMsg)

				If (cCodigo $ "S037|S038" .and. !lParcial .and. !lCompleto) .or. lContinua
					//Recebendo as filiais vindas lá do TAF
					fGp23MkBr(, ,,@aDdsC1E)

					If cCodigo $ "S119|S120"
						For nCont := 1 To Len(aDdsC1E)
							lInteg	:= .F.
							If (nPos1 := aScan( aCols, { |x| x[1] == aDdsC1E[nCont] .AND. IIF(nUsado + 1 == LEN(x), !x[nUsado + 1], .T.) } )) > 0 .And. ValType(aColsAnt) != "A"
								lInteg	:= .T.
							ElseIf (nPos1 := aScan( aCols, { |x| x[1] == aDdsC1E[nCont] .AND. IIF(nUsado + 1 == LEN(x), !x[nUsado + 1], .T.) } )) > 0 .And.;
							( (nPos2 := aScan( aColsAnt, { |x| x[1] == aDdsC1E[nCont] } )) == 0 .Or. !fCompArray( aCols[nPos1], aColsAnt[nPos2] ) )
								lInteg	:= .T.
							ElseIf (nPos3 := aScan( aCols, { |x| Empty(x[1]) .And. IIF(nUsado + 1 == LEN(x), !x[nUsado + 1], .T.) } )) > 0 .And.;
							( ValType(aColsAnt) != "A" .Or. (nPos2 := aScan( aColsAnt, { |x| Empty(x[1]) } )) == 0  .Or. !fCompArray( aCols[nPos3], aColsAnt[nPos2] ) .Or.;
							aScan( aCols, { |x| x[1] == aDdsC1E[nCont] .AND. IIF(nUsado + 1 == LEN(x), x[nUsado + 1], .T.) } ) > 0 )
								lInteg	:= .T.
							EndIf
							If lInteg
								aAdd( aDdsInt, aDdsC1E[nCont] )
							EndIf
						Next nCont
						aDdsC1E := aClone(aDdsInt)
						aDdsInt := {}

						//Busca grupos de filiais para envio

						IF LEN(aDdsC1E) > 0
							fGp23Cons(aFilInTaf, aDdsC1E)
						ENDIF
					ELSE
						//Busca grupos de filiais para envio
						If !lMiddleware
							 If cCodigo == "S037"
							 	fGp23Cons(aFilInTaf)
							 Else
								fGp23Cons(aFilInTaf, aDdsC1E)
							EndIf
						EndIf
					EndIf

					//Gera o cabeçalho para a carga dos eventos
					Aadd(aDados, PADR("Eventos", 25) + " " + PADR("ITEM/REGISTRO", 77) + " " + PADR("STATUS", 26)) //Cabeçalho de Colunas

					If cCodigo == "S038"
						fEvnAlt(@aAuxTAb)

						If Len(aAuxTAb) > 0
						//Looping para gerar eventos caso tenha tido alteração somente
							If Len(aAuxTAb) > 0
								If !lMiddleware
									ProcRegua( Len(aFilInTaf) )
								Else
									ProcRegua( Len(aSM0) )
								EndIf
								If cCodigo == "S038"
									For nAux:= 1 To Len(aAuxTAb)
										If !lMiddleware
											For nX := 1 To Len(aFilInTaf)             //nOpc   Alter    S119 S120
												If VldFil(aFilInTaf[nX][3],aAuxTAb[nAux][1])
													fCargLota(aAuxTAb[nAux][2], 1,@aLogProc, @aDados, aFilInTaf[nX],dDataBase, cVersGPE, .F.,aAuxTAb[nAux][Ascan(aHeader,{|x| AllTrim(x[2]) == "CodTerc"})],4,cCodigo,@lExbMsgAlt)
												Endif
												IncProc("Realizando a integração da(s) filial(ais) alterada(s)")
											Next
										Else
											For nX := 1 To Len(aSM0)             //nOpc   Alter    S119 S120
												If aSM0[nX][1] == cEmpAnt .And. VldFil({aSM0[nX][2]},aAuxTAb[nAux][1])
													fCargLota(aAuxTAb[nAux][2], 1,@aLogProc, @aDados, {"",aSM0[nX][2]},dDataBase, cVersGPE, .F.,aAuxTAb[nAux][Ascan(aHeader,{|x| AllTrim(x[2]) == "CodTerc"})],4,cCodigo,@lExbMsgAlt)
												Endif
												IncProc("Realizando a integração da(s) filial(ais) alterada(s)")
											Next
										EndIf
									Next
								EndIf
							EndIf
						EndIf
					Else

						For nX := 1 To Len(aEsocTpAlt)
							If !aEsocTpAlt[nX,2,Len(aEsocTpAlt[nX,2])]
								aAdd(aAuxTAb, aEsocTpAlt[nX,2])
							EndIf
							//aSize(aAuxTAb[nX], Len(aEsocTpAlt[nX,2])-1)
						Next

						//Limpa array de auxilio
						aEsocTpAlt := {}
						If Len(aAuxTAb) > 0
							aRegs := aClone(aCols)
							nX := 1

							While nX <= Len(aRegs)
								If aRegs[nX,Len(aRegs[nX])]
									aDel(aRegs,nX)
									aSize(aRegs,Len(aRegs) - 1)
									nX := nX -1
								EndIf
								nX++
							EndDo

							//Looping para gerar eventos caso tenha tido alteração somente
							If Len(aAuxTAb) > 0 .AND. iif(lMiddleware, Len(aSM0), LEN(aFilInTaf) ) > 0
								If !lMiddleware
									ProcRegua( Len(aFilInTaf) )
								Else
									ProcRegua( Len(aSM0) )
								Endif
								If cCodigo == "S119"
									if !lMiddleware
										For nX := 1 To Len(aFilInTaf)                                                        //nOpc  Alter    S119 S120   RCC Original,
											fObraX14(cData, 1, @aLogProc, @aDados, aFilInTaf[nX], dDataBase, cVersGPE,/*aX14*/,nOpcx, aAuxTAb, aRegs, Nil, xFilial("RCC"), lAnoMes, cCodigo)
											fObraCTT(cData, 1, @aLogProc, @aDados, aFilInTaf[nX], dDataBase, cVersGPE,/*aX14*/,nOpcx, aAuxTAb, aRegs, Nil, xFilial("RCC"), lAnoMes, cCodigo)
											IncProc("Realizando a integração da(s) filial(ais) alterada(s)")
										Next
									Endif
								ElseIf cCodigo == "S120"
									If !lMiddleware
										For nX := 1 To Len(aFilInTaf)                                                        //nOpc  Alter    S119 S120   RCC Original
											fObraX14(cData, 1, @aLogProc, @aDados, aFilInTaf[nX], dDataBase, cVersGPE,/*aX14*/,nOpcx, aAuxTAb, Nil, aRegs, xFilial("RCC"), lAnoMes, cCodigo)
											fObraCTT(cData, 1, @aLogProc, @aDados, aFilInTaf[nX], dDataBase, cVersGPE,/*aX14*/,nOpcx, aAuxTAb, Nil, aRegs, xFilial("RCC"), lAnoMes, cCodigo)
											IncProc("Realizando a integração da(s) filial(ais) alterada(s)")
										Next
									EndIf
								ElseIf cCodigo == "S037"
									If !lMiddleware
										For nY := 1 to Len(aCols)
											// Primeiro verifica posição de registros gravados no aCols
											// Processo apenas se for novo registro ou se houve alteração em registro já gravado
											// Se esse registro possuir a coluna 'Filial' preenchida, envia somente a filial
											// No caso de configuração 1x1, envia a Filial selecionada
											// No caso de configuração 1xN, envia a Filial centralizadora
											If Len(aColsAnt) > 0
												nPosAnt := aScan(aColsAnt,{|x| x[1] + x[2] + x[3] == aCols[nY][1] + aCols[nY][2] + aCols[nY][3]})
											EndIf

											// Tratativa para Linha Nova
											If If(nY <= Len(aColsAnt) .And. nPosAnt > 0, !fCompArray( aCols[nY] , aColsAnt[nPosAnt]), .T. )
												nPosHFil	:=  aScan(aHeader,{|x| AllTrim(x[2]) == "RCC_FIL"})
												If nPosHFil > 0 .And. !Empty(aCols[nY][nPosHFil])
													nPosFilTaf	:= aScan(aFilInTaf,{|x| AllTrim(x[2]) == aCols[nY][nPosHFil]})
													If nPosFilTaf > 0
														aFilTafAux[1] := aClone(aFilInTaf[nPosFilTaf])
													Else
														aFilTafAux	:= aFilInTaf
													EndIf
												Else
													aFilTafAux	:= aFilInTaf
												EndIf
												cData := If( !Empty(aCols[nY][nPosCha]), aCols[nY][nPosCha], cData )
												For nX := 1 To Len(aFilTafAux)
													//Verifica modo de acesso da tabela RCC, se for diferente de totalmente compartilhado valida as filiais no TAF que devem ser integradas
													//	Empresa 			 	Unidade de Negócio 			 Filial
													If cModoRCC $ "EEE*EEC*ECC"
														If cModoRCC == "EEE" .And. !(RCC->RCC_FILIAL == aFilTafAux[nX,2])
															Loop
														ElseIf cModoRCC == "EEC" .And. !(alltrim(RCC->RCC_FILIAL) == alltrim(substr(aFilTafAux[nX,2], 1, nSizeEmp + nSizeUn)))
															Loop
														ElseIf cModoRCC == "ECC" .And. !(alltrim(RCC->RCC_FILIAL) == alltrim(substr(aFilTafAux[nX,2], 1, nSizeEmp)))
															Loop
														EndIf
														fObraX14(cData, 1, @aLogProc, @aDados, aFilTafAux[nX], dDataBase, cVersGPE, aRegs,nOpcx, aAuxTAb, Nil, Nil, xFilial("RCC"), lAnoMes, cCodigo)
														fObraCTT(cData, 1, @aLogProc, @aDados, aFilTafAux[nX], dDataBase, cVersGPE, aRegs,nOpcx, aAuxTAb, Nil, Nil, xFilial("RCC"), lAnoMes, cCodigo)
														IncProc("Realizando a integração da(s) filial(ais) alterada(s)")
													Else
														//x14   nOpc   Alter    S119 S120 RCC Original
														fObraX14(cData, 1, @aLogProc, @aDados, aFilTafAux[nX], dDataBase, cVersGPE, aRegs,nOpcx, aAuxTAb, Nil, Nil, xFilial("RCC"), lAnoMes, cCodigo)
														fObraCTT(cData, 1, @aLogProc, @aDados, aFilTafAux[nX], dDataBase, cVersGPE, aRegs,nOpcx, aAuxTAb, Nil, Nil, xFilial("RCC"), lAnoMes, cCodigo)
														IncProc("Realizando a integração da(s) filial(ais) alterada(s)")
													EndIf
												Next nX
											EndIf
										Next nY
									Else
										For nX := 1 To Len(aSM0)
											for nAux := 1 To Len(aAuxTAb)
												cData := If( !Empty(aAuxTab[nAux][nPosCha+1]), aAuxTab[nAux][nPosCha+1], cData )
												if VldFil({aSM0[nX][2]},aAuxTAb[nAux][2])
													fObraX14(cData, 1, @aLogProc, @aDados, { .F.,aSM0[nX][2],{aSM0[nX][2]} }, dDataBase, cVersGPE, aRegs,nOpcx, aAuxTAb, Nil, Nil, xFilial("RCC"), lAnoMes, cCodigo)
													fObraCTT(cData, 1, @aLogProc, @aDados, { .F.,aSM0[nX][2],{aSM0[nX][2]} }, dDataBase, cVersGPE, aRegs,nOpcx, aAuxTAb, Nil, Nil, xFilial("RCC"), lAnoMes, cCodigo)
													IncProc("Realizando a integração da(s) filial(ais) alterada(s)")
												EndIf
											Next nAux
										Next nX
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			Endif
			// Apaga a tabela que esta na memoria - sempre trata como inclusao
			For nRecno := 1 To Len(	aColsAnt )
				RCC->( dbGoto( aColsRec[ nRecno ] ) )
				RecLock( "RCC" , .F. , .F. )
				RCC->( dbDelete() )
				RCC->( MsUnLock() )
			Next nRecno

			// Quantidade de Linhas Deletadas
			For nX := 1 to Len(aCols)
				If aCols[nX][Len(aCols[nX])]
					If lAnoMes
						cChave := aCols[ nX,nPosFil]+aCols[nX,nPosCha]
					Else
						cChave := aCols[ nX,nPosFil]
					EndIf
					If aScan(aChaves,{|x|x == cChave}) == 0
						nCntDel++
						Aadd(aChaves,cChave)
					End
				EndIf
			Next nX
			// Reordena sequencia da tabela quando houver linhas deletadas
			If nCntDel > 0
				For nX := 1 to Len(aChaves)
					nSeq := 0
					For nY := 1 to Len(aCols)
						If  aChaves[nX] == aCols[ nY,nPosFil]+ If(lAnoMes,aCols[nY,nPosCha],"")  .And.  !( aCols[nY][Len(aCols[nY])] )
							nSeq++
							aCols[nY,nPosSeq] := PADL(cValtoChar(nSeq), nTam, "0")
						EndIf
					Next nY
				Next nX
			EndIf

			// Efetua Gravacao
			For nX	:=	1 to Len(aCols)
				cGrvChav := IIf(lAnoMes,Substr(aCols[nX,nPosCha],3,4) + Substr(aCols[nX,nPosCha],1,2),Space(6))
				While RCC->(DbSeek(xFilial(cAlias) + cCodigo + aCols[nX,nPosFil] + cGrvChav + aCols[nX,nPosSeq]))
					aCols[nX,nPosSeq] := Soma1(aCols[nX,nPosSeq])
				EndDo
				If aCols[nX,nUsado+1]  == .F.
					RCC->( RecLock(cAlias,.T.,.T.) )			// Inclusao
					RCC->RCC_FILIAL 	:= xFilial(cAlias)
					RCC->RCC_CODIGO 	:= cCodigo
					RCC->RCC_CHAVE		:= cGrvChav
					RCC->RCC_FIL  		:= aCols[nX,nPosFil]
					RCC->RCC_SEQUEN		:= aCols[nX,nPosSeq]
					// Grava  os Campos definidos no RCB no campo RCC_CONTEU
						For nY := If(lAnoMes,4,3) To nMaxArray
							cCampo    := Trim(aHeader[nY][2])
							xConteudo += a320Transf(aCols[nX,nY],aHeader[nY][8],aHeader[nY][4],aHeader[nY][5])
						Next ny
					RCC->RCC_CONTEU := xConteudo
					// Reinicia variavel
					xConteudo	:= ""
					RCC->( MsUnlock() )
				EndIf
			Next nX
		EndIf

		//------------------------------------------
		//| Esta realizando a integração com O TAF
		//------------------------------------------
		If (cCodigo $ "S037|S038" .and. !lParcial .and. !lCompleto) .or. (cCodigo $ "S119|S120" .and. !lRJ4) .AND. (LEN(aFilInTaf) > 0 .Or. lMiddleware)
			If (lIntTAF .Or. lMiddleware) .AND. Len(aAuxTAb) > 0 .And. Len(aDados)> 1
				If lExbMsgAlt ==  .T.
					fAlert038()
				EndIf
				fMakeLog({aDados}, aTitle, Nil, Nil, "", OemToAnsi(STR0180), "M", "P",, .F.) //"Log de Ocorrencias - Manutenção de Tabelas"
			ElseIf lIntTAF .AND. Len(aAuxTAb) > 0  .And. Len(aDados)== 1 .And. !cCodigo $ "S037|S038"
				fEFDMsg()
			EndIf
		Endif
	EndIf

Return

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ a320Transf ³ Autor ³ Natie               ³ Data ³ 27/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna tipo de conteudo.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function a320Transf(xCampo,cTipo,nTam,nDecima)

	If cTipo = "C"
		cCampo := Upper(xCampo)
	ElseIf cTipo = "N"
		cCampo := Str(xCampo,nTam,nDecima)
	ElseIf cTipo = "D"
		cCampo := DTOS(xCampo)
	EndIf

Return ( cCampo )

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ gp320aHead ³ Autor ³ Ricardo             ³ Data ³ 17/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta o array de aHeader.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function gp320aHead(aFields,cAlias)
Local aRetorno 	:= {}
Local aExclRCB  := { 'RCB_FILIAL','RCB_CODIGO','RCB_DESC'}
Local aExclRCC	:= { 'RCC_FILIAL','RCC_CODIGO','RCC_CONTEU'}
Local aArea		:= GetArea()
Local aSX3Area	:= SX3->(GetArea())
Local cValid

Private aHeader := {}
Private nUsado	:= 0

	// Aadd(aFields, "RCC_CHAVE"
	// Monta array dos campos do arquivo de pesquisa.
	dbSelectArea( 'SX3' )
	SX3->( dbSetOrder(1) )
	dbSeek( 'RCC' )
	Do While !Eof() .and. ( x3_arquivo == 'RCC' )
		If x3uso(x3_usado) .AND. cNivel >= x3_nivel .and.;
			ASCAN(aExclRCC,{ |x| x == Trim(x3_campo) } ) == 0
			If !lAnoMes .AND. AllTrim(x3_campo) == "RCC_CHAVE"
				dbSkip()
			EndIf
			nUsado ++
			Aadd(aHeader,{ Trim(x3_titulo), x3_campo  , x3_picture,;
								x3_tamanho , x3_decimal, x3_valid  ,;
								x3_usado   , x3_tipo   , x3_F3,;
								x3_context } )
			If AllTrim(X3_Campo) == "RCC_CHAVE" .And. cPaisLoc == "BRA" .And. cCodigo == "S033"
				cValid := 'iIf( !Empty(Substr(M->RCC_CHAVE,1,2) ) , ENTRE( "01","13",Substr(M->RCC_CHAVE,1,2) ) ,.t.)'
				aHeader[len(aHeader),6] := if(!empty(cValid),cValid+" .and. ",cValid)+ "Gp320Mov( .T. )"
			ElseIf AllTrim(x3_campo) == "RCC_CHAVE"
				cValid := AllTrim(aHeader[Len(aHeader),6])
				aHeader[Len(aHeader),6] := If(!Empty(cValid),cValid+" .and. ",cValid)+ "Gp320Mov( .T. )"
			EndIf
		EndIf
		dbSkip()
	EndDo

	dbSelectArea("RCB")
	RCB->( dbSetOrder(1) )
	If !dbSeek( xFilial(cAlias) + cCodigo ,.F.)
		MsgAlert(OemToAnsi(STR0089), OemToAnsi(STR0083))	// "Nao existe esta tabela para a Empresa/Un.Negocio/Filial selecionada !"###"Atencao"
		aHeader := {}
	EndIf

	Do While !Eof() .and. xFilial("RCB")+ cCodigo  = ( RCB->RCB_FILIAL + RCB->RCB_CODIGO )
		IF !(cCodigo == "S042" .And. AllTrim(RCB_CAMPOS) == "Sequencia" .AND. cPaisLoc == "BRA")
			nUsado ++
			Aadd(aHeader,{  Trim(RCB_DESCPO),RCB_CAMPOS ,RCB_PICTUR,;
					RCB_TAMAN        ,RCB_DECIMA ,RCB_VALID ,;
					'X'              ,RCB_TIPO   ,RCB_PADRAO,;
					' '} )
		ENDIF
		dbSkip()
	EndDo

	// Restaura Area e Ordem de Entrada
	RestArea( aSX3Area )
	RestArea( aArea )

Return ( aHeader )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Gp320aCols ³ Autor ³ Natie               ³ Data ³ 21/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Criar arrays do aCols.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Gp320aCols(aFields,cAlias,cCond,cChave,nOpcx,aColsRec,aColsAnt)
Local cAnoMes	:= ""
Local nCntFor 	:= 0
Local nAcols  	:= 0
Local nusar 	:= 0
Local nTamCpo	:= 0
Local nPosicao  := 0
Local aArea		:= GetArea()
Local aConteu	:= {"RCC_FILIAL","RCC_CODIGO","RCC_FIL","RCC_CHAVE","RCC_SEQUEN"}   // Array com  os campos que estao fora do conteudo
Local nPosDum   := 0
Local nCnt      := 0
Private nUsado	:= Len(aheader)
Private aCols   := {}

	// Quando for Inclusao criar com 1 elemento
	If nOpcx == 3
		nCnt  := 1
		aCols := Array( nCnt , nUsado+1 )
	EndIf
	If !lAnoMes // SE COLUNA MES/ANO NÃO FOR EXIBIDA ADICIONA RCC_CHAVE COMO CAMPO NAO EDITAVEL
		Aadd(aFields,"RCC_CHAVE")
	EndIf
	dbSelectArea(cAlias)
	If dbSeek(cChave) .and. nOpcx # 3
		While !Eof() .And. &cCond == cChave
			Aadd(aCols,Array(nUsado+If(nOpcx#1,1,0)))
			nAcols 		:= Len(aCols)
			nPosicao	:= 1
			cConteu	:= FieldGet(FieldPos( "RCC_CONTEU" ) )
			cAnoMes	:= FieldGet(FieldPos( "RCC_CHAVE" ) )
			For nCntFor := 1 To Len(aHeader)
				nTamCpo	:= aHeader[nCntFor][4]  		// Tamanho do Campo
				cCampo  := Trim(aHeader[nCntFor][2])

				If	ASCAN(aConteu,{ |x| x == cCampo } ) > 0
				   	If cCampo == "RCC_CHAVE"
				   		// Carrega como Mes/Ano
						aCols[nAcols][nCntFor] := Substr(cAnoMes,5,2) + substr(cAnoMes,1,4)
	 				Else
						aCols[nAcols][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
					EndIf
				Else
					If nCntFor == 9
						nCntFor := 9
					EndIf
					// Carrega o conteudo do RCC_CONTEU na aCols
					If aHeader[nCntFor,8] = "C"						// Tipo Caracter
						aCols[nAcols][nCntFor] := Substr(cConteu,nPosicao,nTamCpo)
					ElseIf  aHeader[nCntFor,8] = "N"				// Tipo Numerico
						aCols[nAcols][nCntFor] := VAL( Substr(cConteu,nPosicao,nTamCpo) )
					ElseIf aHeader[nCntFor,8] = "D"					// Tipo Data
						aCols[nAcols][nCntFor] := Stod(Substr(cConteu,nPosicao,nTamCpo) )
						If Empty(Stod(Substr(cConteu,nPosicao,nTamCpo) )) .And. nCntFor == Len(aHeader)
							nTamCpo := nTamCpo + 2 // CONSIDERA AS DUAS "/" CASO TENHA GRAVADO EM BRANCO
						EndIf
					EndIf
					nPosicao	+= nTamCpo
				EndIf
			Next nCntFor
			If nOpcx # 1
				aCols[nAcols][nUsado+1] := .F.
			EndIf
			dbSelectArea(cAlias)
			Aadd(aColsRec,Recno())
			dbSkip()
		EndDo
	ElseIf nOpcx == 3
		// Posiciona ponteiro do arquivo cabeca e inicializa variaveis
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek(cAlias) //-- RCC
		nUsado:= 0
		// aFields:= {"RCC_FILIAL","RCC_CODIGO","RCC_CONTEU"} campos nao editaveis no aCols
		While !Eof() .And. (x3_arquivo == cAlias)
			If x3uso(x3_usado) .AND. cNivel >= x3_nivel .and. AScan(aFields,{|x| x == Trim(x3_campo)}) == 0
				nUsado++
				// Monta Array do 1§ Elemento Vazio. Se Inclusao
				If x3_tipo == "C"
					aCols[1][nUsado] := Space(x3_tamanho)
				ElseIf x3_tipo == "N"
					aCols[1][nUsado] := 0
				ElseIf x3_tipo == "D"
					aCols[1][nUsado] := CTOD("  /  /  ")
				EndIf
			Endif
			dbSkip()
		EndDo
		dbSelectArea("RCB")
		dbSetOrder(1)
		dbSeek( cChave )

		While !EoF() .and.  cChave = xFilial("RCB") + RCB->RCB_CODIGO
			IF !(cCodigo == "S042" .And. AllTrim(RCB_CAMPOS) == "Sequencia" .AND. cPaisLoc == "BRA")
				nUsado ++
				//-- Monta Array do 1§ Elemento Vazio utilizando RCB
				If RCB_TIPO = "C"
					aCols[1][nUsado] := Space(RCB_TAMAN)
				ElseIf RCB_TIPO = "N"
					aCols[1][nUsado] := 0
				ElseIf RCB_TIPO = "D"
					aCols[1][nUsado] := CTOD("  /  /  ")
				Else
					aCols[1][nUsado] := .F.
				EndIf
			ENDIF
			RCB->( dbSkip() )
		Enddo
		aCols[1,nUsado+1] := .F.
	Endif

	If cCodigo == "S119"
	    //a remoção desta coluna so foi possivel por se tratar da "ultima" coluna do browse.
	    //caso contrario, devido ao sistema gravar todos os dados concatenados em um unico campo da RCC
	    //seria preciso rodar uma re-estruturação dos dados da S119 gravados na RCC!
		nPosDum	:=	Ascan(aHeader,{|x| AllTrim(x[2]) == "CTRDEF"})
		If nPosDum > 0 .And. Len(aHeader) == nPosDum //confirmo se é ultima coluna mesmo
			aDel(aHeader,nPosDum)
			aSize(aHeader,Len(aHeader)-1)

			For nCnt := 1 to Len(aCols)
				aDel(aCols[nCnt],nPosDum)
				aSize(aCols[nCnt],Len(aCols[nCnt])-1)
			Next
		Endif

		If IsInCallStack("Gpe320Alt")
			For nCnt := 1 to Len(aHeader)
				If Alltrim(aHeader[nCnt][2]) != "COD" .And. Alltrim(aHeader[nCnt][2]) != "RCC_SEQUEN"
					Aadd(aAlter119,aHeader[nCnt][2])
				EndIf
			Next
		EndIf
	EndIf

	If cCodigo == "S120"
		If IsInCallStack("Gpe320Alt")
			For nCnt := 1 to Len(aHeader)
				If Alltrim(aHeader[nCnt][2]) != "COD" .And. Alltrim(aHeader[nCnt][2]) != "RCC_SEQUEN"
					Aadd(aAlter119,aHeader[nCnt][2])
				EndIf
			Next
		EndIf
	EndIf

	aCols[1][GdFieldPos("RCC_SEQUEN")] := '001' // Inicia Ordem com 1

	// Quando for Alteracao copia o vetor aCols
	If nOpcx == 4
		aColsAnt := aClone(aCols)
	EndIf

	aColsBkp := aClone(aCols)
	nBkp     := Len(aColsBkp)
	RestArea( aArea )

Return ( aCols )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ gp320LinOk ³ Autor ³ Natie               ³ Data ³ 01/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Critica linha digitada                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Gp320LinOk(o, nPosSeq, nPosCha, nPosFil, nPosEnt)

	Local lTudoOk		:= .T.
	Local nX			:= 0
	Local nPosAux		:= 0
	Local nUsado		:= Len(aHeader)
	Local nUsaCols		:= 0
	Local cChaveGet		:= ""
	Local aCopyCols		:= aClone(aCols)
	Local lEmpty		:= .T.
	Local lCriticar		:= .F.
	Local nIndice		:=  0
	Local nY			:=  0
	Local aRetGPE		:= array(2)
	Local aRetTAF		:= array(2)
	Local lIntegra		:= .T.
	Local nLinha		:= n //o:nAt
	Local lLinAlter		:= .F.
	Local cSeqAux		:= ""
	Local cPreSeq		:= ""
	Local nPosEmp		:= 0
	Local lNT15			:= .F.
	Local nPosRegD		:= 0
	Local nPosFol		:= 0
	Local nPosRes		:= 0
	Local nPosDesc		:= 0
	Local nPoshmlnet	:= 0
	Local nPosCod		:= 0
	Local nPosCodFor	:= 0
	Local cChvCod		:= ""
	Local nZ			:=  0
	Local nPosCodS019	:= 0


	DEFAULT nPosSeq		:= GdFieldPos("RCC_SEQUEN")
	DEFAULT nPosCha		:= GdFieldPos("RCC_CHAVE")
	DEFAULT nPosFil		:= IIf(GdFieldPos("RCC_FIL") > 0,GdFieldPos("RCC_FIL"), 1) // Posicao Campo Filial da tabela no Acols
	DEFAULT nPosEnt		:= GdFieldPos("ENT")					// Posicao Campo Entidade da tabela no Acols

    If nPosEnt > 0 .AND.  lIntTAF .AND. cCodigo $ "S119|S120"
      If !VldEnt(aCols[n,nPosFil],aCols[n,nPosEnt])
          Aviso(STR0014,StrTran(OemToAnsi(STR0174),"(#)","("+aCols[n,nPosEnt]+")"))
          lTudoOk := .F.
      EndIf
    EndIf

	If( (lIntTAF .Or. lMiddleware) .And. FindFunction("fVersEsoc") )
		lIntegra := fVersEsoc("S2200", .F., @aRetGPE, @aRetTAF, @cVersEnvio, @cVersGPE)
	Else
		lIntegra    := .T.
		cVersEnvio  := "2.4"
		aRetGPE     := {.F., ""}
		aRetTAF     := {.F., ""}
	EndIf
	Iif (Empty(cVersGPE), cVersGPE := cVersEnvio,)

	nUsaCols  := Len(aCols)
	If lAnoMes
		cChaveGet := cFilRCC+ cCodigo + aCopyCols[ n,nPosFil]+ aCopyCols[n,nPosCha]+ aCopyCols[n,nPosSeq]
	Else
		cChaveGet := cFilRCC+ cCodigo + aCopyCols[ n,nPosFil]+ aCopyCols[n,nPosSeq]
	EndIf

	cPreSeq := aCopyCols[n,nPosSeq]

	//Realizando comparação do array anterior com o atual
	If (lIntTAF .Or. lMiddleware) .AND. cCodigo $ "S037|S119|S120" .AND. !Empty( cPreSeq )
		If Len(aCols) == Len(aColsAnt)
			If aCols[nLinha,Len(aCols[1])] == .F. //Se a linha estiver deletada, não entra no fluxo
				lLinAlter := !fCompArray( aCols[nLinha], aColsAnt[nLinha] )
			EndIf
		Else
			//Caso aCols seja maior que o existente
			If aCols[nLinha,Len(aCols[1])] == .F. //Se a linha estiver deletada, não entra no fluxo
				If (nPosAux := aScan(aColsAnt,{|x| x[1]+x[2]+x[3] == aCols[nLinha,1]+aCols[nLinha,2]+aCols[nLinha,3]})) > 0
					lLinAlter := !fCompArray( aCols[nLinha], aColsAnt[nPosAux] )
				Else
					lLinAlter := .T.
				EndIf
			EndIf
		EndIf
		If cCodigo == "S119" .And. Empty(aCols[n,nPosFil]) .And. !aCols[nLinha,Len(aCols[1])]
			lLinAlter := .T.
		EndIf

		If lLinAlter
			//Verifica se o registro já foi inserido no array para não ter duplicado
			nAchei := aScan(aEsocTpAlt, {|x| x[1] == cChaveGet } )
			If nAchei == 0
				If cVersEnvio < "9.0.00" .Or. !(cCodigo == "S119") .Or. (cCodigo == "S119" .And. fCpoAlt(Len(aColsAnt) < nlinha, nlinha))
					//Adiciona o aCols alterado dentro do Auxiliar
					aAdd( aEsocTpAlt, {cChaveGet, aClone(aCols[nLinha])})

					//Adiciona no mesmo array mais uma posição vazia la no final
					AAdd( aEsocTpAlt[Len(aEsocTpAlt),2],"" )

					//"Empurrra" todos para baixo e adiciona a STRING "S119" ou "S120" -> Compatibilidade
					AIns( aEsocTpAlt[Len(aEsocTpAlt),2], 1 )
					aEsocTpAlt[Len(aEsocTpAlt),2,1] := cCodigo
				EndIf
			Else
				If cVersEnvio < "9.0.00" .Or. !(cCodigo == "S119") .Or. (cCodigo == "S119" .And. fCpoAlt(.T., nlinha))
					aEsocTpAlt[nAchei,2] := aClone(aCols[nLinha])
					//Adiciona no mesmo array mais uma posição vazia la no final
					AAdd( aEsocTpAlt[nAchei,2],"" )

					//"Empurrra" todos para baixo e adiciona a STRING "S119" ou "S120" -> Compatibilidade
					AIns( aEsocTpAlt[nAchei,2], 1 )
					aEsocTpAlt[nAchei,2,1] := cCodigo
				EndIf
			EndIf
		EndIf
	EndIf

	// Verifica se tem alguma coluna preenchida alem da chave
	For nX := 1 to Len(aCopyCols[n])
	    If nX == nPosFil .or. nX == nPosCha .or. nX == nPosSeq .or.;
	      (nX ==(nUsado+1) .and. aCopyCols[n,nX]==.F.)
	    	Loop
	    EndIf

	    lEmpty := Empty(aCopyCols[n,nX])
	    If !lEmpty
	    	Exit
	    EndIf
	Next

	If cCodigo == "S043".And. cPaisLoc == "BRA"
		//Validação do campo "Cod. Homolognet
		If aCols[nLinha,Len(aCols[1])] == .F. //Se a linha não estiver deletada
			nPoshmlnet := GdFieldPos("CodHomolo")
			If nPoshmlnet > 0
				If !(NAOVAZIO(aCols[nLinha][nPoshmlnet]) .Or. fVldS043())
					Aviso(STR0014,STR0205+aCols[nLinha][nPosSeq],{'OK'}) // "Atencao" ##"O conteúdo do campo Cod. Homolognet é inválido para o tipo de Aviso Prévio escolhido. Sequência: XXX
					lTudoOk := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	If cCodigo == "S019".And. cPaisLoc == "BRA"
		If aCols[nLinha,Len(aCols[1])] == .F. //Se a linha não estiver deletada
			nPosCodS019 := GdFieldPos("COD")
			If nPosCodS019 > 0
				If !NAOVAZIO(aCols[nLinha][nPosCodS019])
					Aviso(STR0014,STR0212 + aCols[nLinha][nPosSeq],{'OK'}) // "Atencao" ##"OO conteúdo do campo Código é obrigatório. Sequência: XXX
					lTudoOk := .F.	
				EndIf		
			EndIf
		EndIf
	EndIf

	If lEmpty
		Aviso(STR0014,STR0027,{'OK'}) // "Atencao" ##"Preencha os dados da tabela."
		lTudoOk := .F.
	Else
		If cCodigo == "S033" .And. !aCopyCols[n,Len(aCopyCols[n])]
			If Empty(aCopyCols[n,1])
				Aviso(STR0014,STR0138,{"OK"}) //Atençäo ! ## "Campo 'Filial' não pode estar vazio"
				Return(.F.)
			EndIf
			If Empty(aCopyCols[n,2])
				Aviso(STR0014,STR0139,{"OK"}) //Atençäo ! ## "Campo 'Mês/Ano' não pode estar vazio"
				Return(.F.)
			EndIf
		EndIf

		If cCodigo == "S137" .And. !aCopyCols[n,Len(aCopyCols[n])] .AND. !fValidS137(aHeader, aCols)
			Return(.F.)
		EndIf

		If cCodigo == "S130" .And. !aCopyCols[n,Len(aCopyCols[n])]
			If Empty(aCopyCols[n,3])
				Aviso(STR0014,STR0186,{"OK"}) //Atençäo ! ## "Campo 'Documento' não pode estar vazio"
				Return(.F.)
			EndIf
			If Empty(aCopyCols[n,4])
				Aviso(STR0014,STR0187,{"OK"}) //Atençäo ! ## "Campo 'CBO' não pode estar vazio"
				Return(.F.)
			EndIf
		EndIf

		If Len(aCols) != Len(aColsAnt) .Or. !fCompArray( aCols[n], aColsAnt[n] )	// Linha Incluida/Alterada
			If aCopyCols[n,nUsado+1] == .F.	//linha não deletada

				//Realizando comparação do array anterior com o atual
				If lIntTAF .AND. cCodigo $ "S119|S120" .AND. Empty( cPreSeq )

					//Ajusta a chave baseado no que ele de fato vai monta
					If lAnoMes
						cChaveAux := cFilRCC + cCodigo + aCols[ n,nPosFil] + aCols[n,nPosCha] + cSeqAux
					Else
						cChaveAux := cFilRCC + cCodigo + aCols[ n,nPosFil] + Iif(Empty(aCols[n,nPosSeq]),"001",aCols[n,nPosSeq])
					EndIf

					If Len(aCols) == Len(aColsAnt)
						lLinAlter := !fCompArray( aCols[nLinha], aColsAnt[nLinha] )
					Else
						lLinAlter := .T.
					EndIf

					If lLinAlter
						//Verifica se o registro já foi inserido no array para não ter duplicado
						nAchei := aScan(aEsocTpAlt, {|x| x[1] == cChaveAux } )
						If nAchei == 0
							If cVersEnvio < "9.0.00" .Or. !(cCodigo == "S119") .Or. (cCodigo == "S119" .And. fCpoAlt(.T., nlinha))
								//Adiciona o aCols alterado dentro do Auxiliar
								aAdd( aEsocTpAlt, {cChaveAux, aClone(aCols[nLinha])})

								//Adiciona no mesmo array mais uma posição vazia la no final
								AAdd( aEsocTpAlt[Len(aEsocTpAlt),2],"" )

								//"Empurrra" todos para baixo e adiciona a STRING "S119" ou "S120" -> Compatibilidade
								AIns( aEsocTpAlt[Len(aEsocTpAlt),2], 1 )
								aEsocTpAlt[Len(aEsocTpAlt),2,1] := cCodigo

								//Caso o usuario adicione uma linha nova, mas ela vá sem o sequencial
								If Empty(aEsocTpAlt[1,2,3])
									aEsocTpAlt[Len(aEsocTpAlt),2,3] := "001"
								EndIf
							EndIf
						Else
							If cVersEnvio < "9.0.00" .Or. !(cCodigo == "S119") .Or. (cCodigo == "S119" .And. fCpoAlt(.T., nlinha))
								aEsocTpAlt[nAchei,2] := aClone(aCols[nLinha])

								//Adiciona no mesmo array mais uma posição vazia la no final
								AAdd( aEsocTpAlt[nAchei,2],"" )

								//"Empurrra" todos para baixo e adiciona a STRING "S119" ou "S120" -> Compatibilidade
								AIns( aEsocTpAlt[nAchei,2], 1 )
								aEsocTpAlt[nAchei,2,1] := cCodigo

								//Caso o usuario adicione uma linha nova, mas ela vá sem o sequencial
								If Empty(aEsocTpAlt[nAchei,2,3])
									aEsocTpAlt[nAchei,2,3] := "001"
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf

				If cPaisLoc == "BRA" .And. cCodigo $ "S016|S017" .And. Empty(aCopyCols[n,6])
					Aviso(STR0014,STR0087 + STR0123 + STR0088,{ "OK" }) // "O campo 'CNPJ Fornecedor' nao pode estar vazio."
					Return(.F.)
				EndIf

				//VALIDAÇÃO DE REGISTROS DUPLICADOS FILIAL+MESANO+SEQUENCIA
				If lTudoOk
					If cCodigo $ "S016|S017|S028|S029|S030|S031" .And. cPaisLoc == "BRA"
						nPosCod	:=  aScan(aHeader,{|x| AllTrim(x[2]) == "CODIGO"})
						If nPosCod > 0
							If Empty(aCopyCols[n,nPosCod])
								Aviso(STR0014,STR0209,{"OK"}) //Atençäo ! ## "Campo 'Código' não pode estar vazio!"
								Return(.F.)
							ElseIf cCodigo $ "S028|S029|S030|S031"
								nPosCodFor := aScan(aHeader,{|x| AllTrim(x[2]) == "CODFOR"})
								If nPosCodFor > 0
									If Empty(aCopyCols[n,nPosCodFor])
										Aviso(STR0014,STR0210,{"OK"}) //Atençäo ! ## "Campo 'Código Fornecedor' não pode estar vazio!"
										Return(.F.)
									Else
										cChvCod := aCopyCols[n,nPosFil] + aCopyCols[n,nPosCha] + aCopyCols[n,nPosCod] + aCopyCols[n,nPosCodFor]
										For nZ := 1 To Len(aCols)
											If nZ <> n .And. !aCols[nZ, Len(aCols[1])] .And. aCols[nZ][nPosFil] + aCols[nZ][nPosCha] + aCols[nZ][nPosCod] + aCols[nZ][nPosCodFor] == cChvCod
												Aviso(STR0014,OemToAnsi(STR0194 + Alltrim(Str(nZ))),{"OK"}) //"Atençäo ! Já existe este registro cadastrado, favor revisar os registros e alterar a linha: " ##
												Return(.F.)
											EndIf
										Next nZ
									EndIf
								EndIf
							Else
								cChvCod := aCopyCols[ n,nPosFil] + aCopyCols[n,nPosCha] + aCopyCols[n,nPosCod]
								For nZ := 1 To Len(aCols)
									If aCols[nZ][1] + aCols[nZ][2] + aCols[nZ][4] == cChvCod .And. nZ <> n .And. !aCols[nZ ,Len(aCols[1])]
										Aviso(STR0014,OemToAnsi(STR0208),{"OK"}) //Atençäo ! ## "Campo 'Código' com valor duplicado. Por favor, revisar os registros."
										Return(.F.)
									EndIf
								Next nZ
							EndIf
						EndIf
					Else
						nPosRegD := Ascan(aCols, {|x| (x[1]+x[2]+CVALTOCHAR(x[3])) == (aCopyCols[n,1]+aCopyCols[n,2]+CVALTOCHAR(aCopyCols[n,3]))})
						If nPosRegD > 0 .And. nPosRegD <> n .and. !aCols[n ,Len(aCols[1])] .and. !aCols[nPosRegD ,Len(aCols[1])]
							lTudoOk := .F.
							Aviso(OemToAnsi(STR0193), OemToAnsi(STR0194 + Alltrim(Str(n))) , {"OK"}) //"Registro duplicado"#"Já existe este registro cadastrado, favor revisar os registros e alterar a linha: "

						Endif
					EndIf

				EndIf
				fVersEsoc( "S1005", .F.,,,@cVersEnvio,@cVersGPE,,@lNT15)
				RCB->(dbSetOrder(1))
				RCB->(dbSeek(xFilial("RCB")+cCodigo))
				While RCB->RCB_CODIGO == cCodigo .and. lTudoOk
					If !aCopyCols[n,Len(aCopyCols[n])]

						If cPaisLoc == "BRA" .And. cCodigo == "S120"
							If lTudoOk .And. !empty(aCopyCols[n,04])
								If FindFunction("fVldRJ4") .And. fVldRJ4(.T.)
									lTudoOk := .F.
									exit
								Endif
							Endif
						Endif

						If cPaisLoc == "BRA"  .And. cCodigo == "S119"
							If Empty(aCopyCols[n,Val(RCB->RCB_ORDEM)+If(lAnoMes,3,2)])//coluna esta vazia

								lCriticar := .F.

								If Len(aHeader) >= ( Val(RCB->RCB_ORDEM)+If(lAnoMes,3,2) )

									If !lNT15 .And. AllTrim( aHeader[Val(RCB->RCB_ORDEM)+If(lAnoMes,3,2)][2] ) == "TPAPD"
										lCriticar := .T.
									EndIf

									If lCriticar == .F. .And. !lNT15 .And.AllTrim( aHeader[Val(RCB->RCB_ORDEM)+If(lAnoMes,3,2)][2] ) == "TPCTAPD"
										nIndice := Ascan(aHeader,{|x| AllTrim(x[2]) == "TPAPD"})
										If nIndice > 0
											If Alltrim(aCopyCols[n,nIndice]) != "0"
												lCriticar := .T.
											EndIf
										EndIf
									EndIf

								EndIf

								If lCriticar
									lTudoOk := .F.
									Aviso(STR0014,STR0087+ AllTrim(RCB->RCB_DESCPO) +STR0088,{ "OK" })// "Atencao"###"O campo "###""nao pode estar vazio."
								EndIf
							EndIf
						EndIf

						If "NAOVAZIO" $ UPPER(RCB->RCB_VALID) // Se o campo estiver vazio e tiver validacao NAOVAZIO, exibe mensagem com descricao do campo
							If Alltrim(RCB->RCB_CAMPOS) $ "REND3|ALIQ3|DED3|REND4|ALIQ4|DED4|CodHomolo|" .And. !fDtIR34(aCopyCols[n])
								If Empty(aCopyCols[n, Val(RCB->RCB_ORDEM) + If(lAnoMes, 3, 2)])
									lTudoOk := .F.
									Aviso(STR0014,STR0087+ AllTrim(RCB->RCB_DESCPO) +STR0088,{ "OK" })// "Atencao"###"O campo "###""nao pode estar vazio."
									Exit
								EndIf
							EndIf
						EndIf

						If "FMSGFORM" $ UPPER(RCB->RCB_VALID) .AND. "1=1" $ UPPER(RCB->RCB_VALID) //--HAVER
							If Empty(aCopyCols[n,Val(RCB->RCB_ORDEM)+If(lAnoMes,3,2)])
								lTudoOk := &(RCB->RCB_VALID)
							EndIf
						EndIf
						If !Empty( aCopyCols[n,nPosFil] )
							If aScan( aCargFil, {|aCargFil| (aCargFil[2] == aCopyCols[n,nPosFil] .And. aCargFil[1] == cEmpAnt ) .Or. aCargFil[2] == aCopyCols[n,nPosFil]} ) == 0
								lTudoOk := .F.
								Aviso(STR0014,STR0118,{"OK"}) //Atençäo ! ## "Filial inválida. Verifique o código informado."
								Exit
							EndIf
						EndIf
					EndIf

					//Caso seja Layout eSocial < 2.3, faz a validação do centro de custo para Tipo de Ponto
					Iif ( (lIntTAF .Or. lMiddleware) .And. ExistFunc( 'fVersEsoc' ), fVersEsoc( "S1005", .F.,,,@cVersEnvio,@cVersGPE),)
					If ( Empty(cVersGPE), cVersGPE := cVersEnvio,)
					If cVersGPE < '2.3'
						If cPaisLoc == "BRA"  .And. cCodigo == "S119"
							If empty(aCols[n,06]) .and. !empty(aCols[n,07])
								lTudoOk := .F.
								Aviso(STR0129, STR0127, {"OK"}) //Campo Tipo de Ponto //O Tipo de Registro de ponto deve ser informado apenas para os tomadores
								Exit
							EndIf
						EndIf
					EndIf

					If cPaisLoc == "BRA"  .And. cCodigo == "S119"

						//Se existir o campo EmpMatriz, ele estiver setado como "Sim" mas a filial esta vazia = Bloqueia processo
						nPosEmp := Ascan(aHeader,{|x| Alltrim(x[2]) == "EMPMATRIZ"})
						If nPosEmp > 0
							If Empty(aCopyCols[n, nPosFil]) .AND. (aCopyCols[n,11] == "1")
								lTudoOk := .F.
								Aviso(OemToAnsi(STR0172), OemToAnsi(STR0173), {"OK"}) //##"Empresa Matriz sem Filial informada" //##"Você deve informar uma Filial para poder definir o campo como Matriz"
								Exit
							EndIf
						Endif

						If nPosEmp > 0 .And. lTudoOk
							If !lNT15 .And. ((!empty(aCopyCols[n,04]) .And. (aCopyCols[n,11]) <> "1") .Or. ( empty(aCopyCols[n,04]) .And. aCopyCols[n,11] == "1"))
								lTudoOk := .F.
								Aviso(STR0157, STR0154, {"OK"}) //Campo Tipo de Ponto //"A informação Contrata PCD, deve ser prestada para a Matriz, conforme preenchimento do campo Empresa Matriz (1=Sim, 2=Não)."
								Exit
							EndIf

							If lTudoOk .And. !empty(aCopyCols[n,06]) .And. (aCopyCols[n,11]) == "1"
								lTudoOk := .F.
								Aviso(STR0156, STR0155, {"OK"}) //Campo Centro de Custo(Tomador) //"Para empresas informadas como Matriz(campo Empresa Matriz = 1) não deve ser preenchido o Centro de Custo(Tomador)."
								Exit
							ELSEIF lTudoOk .And. !empty(aCopyCols[n,06]) .And. (aCopyCols[n,11]) <> "1"
								if FindFunction("fVldRJ4") .And. fVldRJ4(.T.)
									lTudoOk := .F.
									exit
								Endif
							Endif
						Endif
					EndIf
					RCB->(DbSkip())
				EndDo

				If Empty(aCopyCols)
					aCols := {}
					Eval(oGet:oBrowse:badd)
				ElseIf lTudoOk
					If !lFimTdOk .Or. Empty(aCopyCols[n,nPosSeq])
						// Muda a Sequencia da Tabela de acordo com  a chave
						fPlusSeq(@aCopyCols,cChaveGet,nUsado,,@cSeqAux)
					EndIf
					aCols	:= aClone(aCopyCols)
				EndIf

			Else	// Linha deletada
				//Validacao especial pro Brasil (Beneficios) - Apenas para a Tabela S018
				If  aCopyCols[n,nUsado+1]  == .T. .And. cPaisLoc == "BRA"  .And. cCodigo == "S018" .And. aCopyCols[n,4] <= "004"
					Aviso(STR0014, STR0115, {"OK"}) // "Atencao"###""Nao e possivel eliminar os fornecedores padroes."
					Return(.F.)
				EndIf
				If cCodigo == "S046"
					//Nao permite que codigos gerados sejam excluidos
					nPosAux := GdFieldPos("BRA_S04601")
					If aCopyCols[n,nPosAux] $ "01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33"
						Alert(STR0116)  // ###"Não é possível efetuar a exclusão dos códigos de movimentação padrões"
						Return(.F.)
					EndIf
				EndIf

				If cPaisLoc == "BRA"  .And. cCodigo == "S018" .And. (Empty(aCopyCols[n,6]) .Or. Empty(aCopyCols[n,7]))
					If !lMsg
						Aviso(STR0014,STR0124,{ "OK" }) // "Os campos Código do Cliente e Empresa Resp. não podem ficar em branco!"
						lMsg := .T.
					EndIf
					Return(.F.)
				EndIf

				If Empty(AcopyCols)
					aCols := {}
					Eval(oGet:oBrowse:badd)
				Else
					aCols	:= aClone(aCopyCols)
				EndIf

				fAtualizaBkp2()

				SX3->( DbSelectArea("SX3") )
				SX3->( DbSetOrder(1) )
				If SX3->( DbSeek("RG1") )

					If !fExcluirOk2()
						aCols[n,nUsado+1] := .F.
						lTudoOk := .F.
						Alert(STR0076)  // ###"Exclusao negada. Existe um ou mais lancamentos fixos para esta Tabela, Linha e Coluna."
					EndIf
				EndIf
			EndIf
			If !lFimTdOk
				oGet:oBrowse:nAt 	:= n
				oGet:oBrowse:Refresh(.T.)
			EndIf
		EndIf
	EndIf

	If lTudoOk == .T.
		lGpea320Inc := .T.
	EndIf

Return ( lTudoOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ gp320TudoOk ³ Autor ³ Natie              ³ Data ³ 25/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta as getdados dos arquivos.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function gp320TudOk(o)
Local lTudoOk	:= .T.
local nPosSeq	:= GdFieldPos("RCC_SEQUEN")
local nPosCha	:= GdFieldPos("RCC_CHAVE")
local nPosFil	:= IIf(GdFieldPos("RCC_FIL") > 0,GdFieldPos("RCC_FIL"), 1)	// Posicao Campo Filial da tabela no Acols
local nPosEnt	:= GdFieldPos("ENT")			// Posicao Campo Entidade da tabela no Acols


	If nOpcao == 2
		Return .T.
	EndIf

	If cPaisLoc == 'BRA' .And. Len(aCols) > 1	//Validar Sxxx específicas
		If !fVal320Tab()
			Return .F.
		EndIf
	EndIf

	lFimTdOk := .T.
	lTudoOk := Gp320LinOk(,nPosSeq,nPosCha,nPosFil,nPosEnt)

	If lTudoOk
		ProcGpe( {|lEnd| lTudoOk := fAuxValid()}, STR0121, "", .F. )//"Atualização no TSA"
	Endif
	lFimTdOk := .F.//atribui nulo para a variavel evitando que o metodo de validação da linha seja chamado outras vezes, uma vez que o fAuxValid invoca novamente o Gp320LinOk

Return ( lTudoOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fAuxValid³ Autor ³ Allyson M              ³ Data ³ 23/12/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a validadao das linhas                            	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEA320                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fAuxValid()
Local lTudoOk	:= .T.
Local nRegs 	:= 0
Local nX		:= 0
Local aColsRCB	:= aClone(aCols)
Local nSavN		:= n
Local nPos		:= 0

nRegs := Len(aColsRCB)

If Len(aColsRCB) > 0
	If cCodigo == "S033" .And. ( nPos := aScan( aColsRCB, { |x| Empty(x[1]) .Or. Empty(x[2]) } ) ) > 0
		n := nPos
		Return(.F.)
	EndIf

	GPProcRegua( nRegs/25 )
	For nX := 1 To nRegs
		If !aColsRCB[nX,Len(aColsRCB[nX])] // Se nao esta Deletado
			If nX == 1 .Or. Mod( nX, 25 ) == 0
				GPIncProc(STR0119 + cValToChar(nX) + STR0120 + cValToChar(nRegs) + ".")//"Validação do registro "##
			EndIf
			n := nX
			lTudoOk := Gp320LinOk()
			If !lTudoOk
				Exit
			EndIf
		EndIf
	Next nX

EndIf

n := nSavN

Return(lTudoOk)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fUseCor  ³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cores para legenda.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function fUsecor()
Local lGestPubl := if(ExistFunc("fUsaGFP"),fUsaGFP(),.f.)	//Verifica se utiliza o modulo de Gestao de Folha Publica - SIGAGFP
Local aMarks :=	{;
				{ "Substr(RCB->RCB_CODIGO,1,1)=='U'" , "BR_VERDE"	},;
				{ "Substr(RCB->RCB_CODIGO,1,1)=='S'" , "BR_AZUL"	};
				}
	If cPaisLoc $ "CHI/PAR" .Or. ( cPaisLoc == "BRA" .And. !lGestPubl)
		Aadd(aMarks,{ "Substr(RCB->RCB_CODIGO,1,1)=='A'" , "BR_PRETO"	})
	EndIf

Return ( aMarks )

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Gpe320Leg | Autor ³                      ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda de Cores.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Gpe320Leg()
Local lGestPubl := if(ExistFunc("fUsaGFP"),fUsaGFP(),.f.)	//Verifica se utiliza o modulo de Gestao de Folha Publica - SIGAGFP
Local aLegenda := {;
				    { "BR_AZUL"  , OemToAnsi( STR0008 ) } ,; // "Tabela Definida Pela Microsiga"
			        { "BR_VERDE" , OemToAnsi( STR0009 ) };   // "Tabela Definida Pelo Usuario"
				   }

	If cPaisLoc $ "CHI/PAR" .Or. ( cPaisLoc == "BRA" .And. !lGestPubl)
		Aadd(aLegenda,{ "BR_PRETO" , OemToAnsi( STR0084 ) }) // "Tabela comum a todos os países"
	EndIf

	BrwLegenda(	cCadastro ,	oEmToAnsi(STR0010) , aLegenda )			 // Legenda do Cadastro de Paramentros

Return ( Nil )


/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FchoBar320 ³ Autor ³R.H. Natie           ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega abuttons para Enchoicebar.						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FchoBar320(oDlg,cGrupos,lEnable,nOpcx)
Local bCopy		:= { || NIL }			// Botao Copiar
Local bPaste	:= { || NIL }			// Botao Colar
Local bReOrder	:= { || NIL }			// Botao Reordenar
Local bAttTab	:= { || NIL }			// Botao Atualizar tabela
Local bGupyTab	:= { || NIL }			// Botao Carregar Tabela
Local bDuplicar	:= { || Duplicar() }   // Botao Duplicar
Local bReaj		:= { || Reajustar() }  // Botao Reajustar
Local bPesq		:= { || Pesq() }       // Botao Pesquisar
Local aCopyTab	:= {}
Local aTabEsoc	:= {"S047","S048","S049","S050","S051","S053","S054","S055","S056","S057","S135","S136","S138","S145","S139"}
Local aTabGupy	:= {"S132","S133"}
Local nPos		:= 0

	aButtons	    	:= {}

	DEFAULT lEnable		:= .T.

	If nOpcx == 4 .or. nOpcx == 3
		bReOrder := { || fReorder() }
		aAdd(aButtons, { NIL, { || Eval( bReOrder )  } ,  OemToAnsi(STR0142) } )  // "Reordenar Posições <F8>"
		SetKey( VK_F8 , bReOrder )

		//Verifica se a tabela selecionada é uma tabela do eSocial
		nPos := aScan(aTabEsoc,{ |x| x == AllTrim( cCodigo ) } )

		If( nPos > 0 )
			bAttTab := { || fAttTab( oDlg ) }
			aAdd(aButtons, { NIL, { || Eval( bAttTab )  } ,  OemToAnsi(STR0143) } )  // "Atualizar tabela <F7>"
			SetKey( VK_F7 , bAttTab )
		EndIf

		//Verifica se a tabela selecionada faz parte do grupo de tabelas que integram com Gupy
		If nOpcx == 3
			//Verifica se a tabela selecionada é uma tabela do eSocial
			nPos := aScan(aTabGupy,{ |x| x == AllTrim( cCodigo ) } )

			If nPos > 0
				bGupyTab := { || fGupyTab( cCodigo) }
				aAdd(aButtons, { NIL, { || Eval( bGupyTab )  } ,  OemToAnsi(STR0189) } )  // "Atualizar tabela <F7>"
				SetKey( VK_F6 , bGupyTab )
			EndIf
		EndIf
	EndIf

	If nOpcx == 4
		aAdd(aButtons, { NIL, { || Eval( bDuplicar )  } ,  OemToAnsi(STR0034)  } )// "Duplicar"
		aAdd(aButtons, { NIL, { || Eval( bReaj )  } ,  OemToAnsi(STR0041) } )     // "Reajustar"
	EndIf

	If nOpcx == 2 .or. nOpcx == 4
		aAdd(aButtons, { NIL, { || Eval( bPesq )  } ,  OemToAnsi(STR0064) } )     // "Pesquisar"
	EndIf

	If ( lEnable ) .And. ( nOpcx == 3 .Or. nOpcx == 4 )
		bCopy		:= { || aCopyTab := fCopia(oGet:oBrowse:nAt) }
		bPaste		:= { || fColar( aCopyTab , .T.,oGet:oBrowse:nAt,.f.) }

		aAdd(aButtons, { NIL, { || Eval( bCopy )  } ,  OemToAnsi(STR0016)} )     // "Copiar"
		SetKey( VK_F4 , bCopy )

		If Empty(aCopyTab)
			aAdd(aButtons, { NIL, { || Eval( bPaste )  } ,  OemToAnsi(STR0017) } )// "Colar"
			SetKey( VK_F5 , bPaste )
		EndIf
	EndIf

Return ( Nil )

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fCopia   | Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Efetua copia do registro atual.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320/GPEA550/GPEA600/GPEM070                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fCopia(nLin)
Local aCopyTab	:= {}

	// MsNewGetDados - A variavel n deixa de ser atualizada pelo objeto, o que nos obriga a recuperar o conteudo de oGet:nAT
	// MSGetDados    - A variavel n continua a ser atualizada
	If Empty(nLin)
	   nLin := n
	EndIf
	// O tratamento do MsNewGetDados e diferente do MSGetDados - Copia Linha inteira
	If AllTrim(Upper(oGet:cClassName)) == "MSGETDADOS"
	   aCopyTab := ( aClone ( aCols[nLin] ) )
	Else
	   aCopyTab := ( aClone ( oGet:aCols[ nLin ] ) )
	EndIf

Return ( aCopyTab )

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fColar   | Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cola registro na posicao atual.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320/GPEA550/GPEA600/GPEM070                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fColar(aCopyTab,lLinha,nLin, lMsNewGetDados)
Local aString	:= {}
Local aAux	    := aClone(aCols)
Local aCampos   := {"RCC_SEQUEN","RCC_CHAVE","RCC_FIL"}
Local cChaveGet	:= ""
Local cSeq	    := ""
Local nSeq
Local nPos1     := aScan(aHeader,{|x| AllTrim(x[2]) == aCampos[1]})
Local nPos2     := aScan(aHeader,{|x| AllTrim(x[2]) == aCampos[2]})
Local nPos3     := aScan(aHeader,{|x| AllTrim(x[2]) == aCampos[3]})
Local nTamSeq
Local nPosSeq
Local nPosCha
Local nPosFil
Local nTamAux
Local nTCpoFil
Local nTCpoCha
Local nX        := 0
Local lRCC      := .F.
Local lCola     := .T.

	If( nPos1 <> 0 .and. If(lAnoMes, (nPos2 <> 0), .T.) .and. nPos3 <> 0 , lRCC := .T., lRCC )

	DEFAULT lLinha 	:= .T.
	DEFAULT lMsNewGetDados := .F.

	// MsNewGetDados - A variavel n deixa de ser atualizada pelo objeto, o que nos obriga a recuperar o conteudo de oGet:nAT
	// MSGetDados    - A variavel n continua a ser atualizada

	If Empty(nLin)
		nLin := n
	EndIf

	If ( lRCC )
		nPosSeq	:= GdFieldPos("RCC_SEQUEN")
		nPosCha := GdFieldPos("RCC_CHAVE")
		nPosFil	:= IIf(GdFieldPos("RCC_FIL") > 0,GdFieldPos("RCC_FIL"), 1)   // Posicao Campo Filial da tabela no Acols
		nTamAux	:= Len(cFilRCC + cCodigo)
		nTCpoFil	:= aHeader[nPosFil][4]
		nTCpoCha	:= If(lAnoMes, aHeader[nPosCha][4], 0)
		If !Empty(aCopyTab)
			// Chave da sequência
			If lAnoMes
				cChaveGet	:= cFilRCC+ cCodigo + aCopyTab[nPosFil]+ aCopyTab[nPosCha]+ aCopyTab[nPosSeq]
			Else
				cChaveGet	:= cFilRCC+ cCodigo + aCopyTab[nPosFil]+ aCopyTab[nPosSeq]
			EndIf
			// Cria array(aString) com registros que tenham a mesma chave para obter a sequência
			For nX := 1 To Len(aAux)
				If lAnoMes
					cString := cFilRCC+ cCodigo+ aAux[nx,nPosFil]+ aAux[nx,nPosCha]
				Else
					cString := cFilRCC+ cCodigo+ aAux[nx,nPosFil]
				EndIf

				If Len(cString) > 0 .And. !Empty(aAux[nx,nPosSeq]) .And. ;
					Substr(cChaveGet,01,(nTamAux+nTCpoFil+nTCpoCha)) == cString
					Aadd(aString,{cString,aAux[nx,nPosSeq]})
				EndIf
			Next

		    // Verifica se linha onde sera colada ja esta preenchida atraves do campo Sequencia
			If lMsNewGetDados
				If Empty(oGet:aCols[nLin][nPosSeq])
					If !Empty(aString)
						cSeq:= GP320SeqAlfa(aString[Len(aString)][2])
					EndIf
				Else
					cSeq := oGet:aCols[nLin][nPosSeq]
				EndIf
			Else
				If Empty(aCols[nLin][nPosSeq])
				 	If !Empty(aString)
						cSeq:= GP320SeqAlfa(aString[Len(aString)][2])
					EndIf
				Else
					cSeq := aCols[nLin][nPosSeq]
				EndIf
			EndIf

			aCopyTab[nPosSeq] := cSeq
		EndIf
	EndIf

	If(Upper(FunName()) == "GPEA550") // Atualiza ordem alias RG1 - Lancamentos Fixos
		If Empty(oGet:aCols[Len(oGet:aCols)][2])
			nTamSeq     :=  TamSX3( "RG1_ORDEM")[1]
			fSequencia(aCopyTab[1], @nSeq)
			aCopyTab[2] := nSeq
		Else
			If oGet:aCols[oGet:nAt][1] <> "2"
				AVISO(OemToAnsi(STR0014),OemToAnsi(STR0094),{'OK'},,)  // "Atencao"###"Nao e possivel substituir lancamentos."###"."
		    	lCola := .F.
		    Else
		    	aCopyTab[2] := oGet:aCols[Len(oGet:aCols)][2]
		    EndIf
		EndIf
	EndIf

	If !Empty(aCopyTab) .And. lCola
		If  lLinha
			// O tratamento do MsNewGetDados e diferente do MSGetDados
			If lMsNewGetDados
				oGet:aCols[nLin] := aClone( aCopyTab )
			Else
				For nX := 1 To Len( aHeader )
					aCols[nLin, nX] := aCopyTab[nX]
				Next nX
			EndIf
		Else
			For nX := 1 To Len( aHeader )
				aCols[nLin, nX] := aCopyTab[nX]
			Next nX
		EndIf
		n := nLin
		oGet:lNewLine := .F.
		oGet:oBrowse:Refresh(.T.)
	EndIf

Return ( Nil )

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fPlusSeq | Autor ³Natie                  ³ Data ³ 30/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Controla a Sequencia de acordo com  a Chave digitada.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fPlusSeq(aAux,cChaveAux,nUsado, ltela,cSeq)

Local aString		:= {}
Local cSeqIni		:= "001"
Local nLin			:= 0
Local nPosCha		:= GdFieldPos("RCC_CHAVE")				// Posicao Campo chave no Acols
Local nPosFil		:= IIf(GdFieldPos("RCC_FIL") > 0,GdFieldPos("RCC_FIL"), 1) // Posicao Campo Filial da tabela no Acols
Local nPosSeq		:= GdFieldPos("RCC_SEQUEN")				// Posicao Campo Sequencia no aCols
Local nPosCod		:= GdFieldPos("CODIGO")					// Posicao Campo Codigo da tabela no Acols
Local nPosCodBra	:= GdFieldPos("BRA_" + cCodigo + "01")	// Posicao Campo Codigo em tabelas nomeadas p/Brasil
Local nPosIdad		:= GdFieldPos("IDADEATE")				// Posicao Campo Idade da tabela no Acols
Local nPosSal		:= GdFieldPos("SALATE")					// Posicao Campo Salario base da tabela no Acols
Local nPosSalC		:= GdFieldPos("SALCATE")				// Posicao Campo Salario Controle Até da tabela no Acols
Local nPosAnoI		:= IIf(GdFieldPos("ANOMESI") > 0,GdFieldPos("ANOMESI"), 2)	// Posicao Campo Ano/Mes Inicial da tabela no Acols
Local nIniChave		:= 0
Local nFimChave		:= 0
Local nTamChave		:= 0
Local nTamChv		:= GetSx3Cache("RCC_CHAVE", "X3_TAMANHO")
Local nTamCod		:= GetSx3Cache("RCC_CODIGO", "X3_TAMANHO")
Local nTamFil		:= GetSx3Cache("RCC_FIL", "X3_TAMANHO")
Local nTamFili		:= GetSx3Cache("RCC_FILIAL", "X3_TAMANHO")
Local nTamSeq		:= GetSx3Cache("RCC_SEQUEN", "X3_TAMANHO")
Local nX			:= 0
Local nPosRendAte	:= GdFieldPos("RENDATE")				// Posicao Campo A Valor da tabela no Acols
Local nPosSalMAte	:= GdFieldPos("SALMINATE")				// Posicao Campo A Sal.Min. da tabela no Acols
Local nPosCodFor	:= GdFieldPos("CODFOR")

Default lTela		:= .T.
Default cSeq		:= ""			//-- Variavel sequencia

If lAnoMes
	nTamChave 	:= nTamFili + nTamCod + nTamFil + nTamChv
Else
	nTamChave 	:= nTamFili + nTamCod + nTamFil
EndIf

For nLin := 1 To Len(aAux)
	If lAnoMes
		cString := cFilRCC + cCodigo + aAux[nLin, nPosFil] + aAux[nLin, nPosCha]
	Else
		cString := cFilRCC + cCodigo + aAux[nLin, nPosFil]
	EndIf

	If Len(cString) > 0 .and. SubStr(cChaveAux, 1, nTamChave) == cString .And.  aAux[nLin,nUsado+1] == .F.
		aAdd(aString, { cString, aAux[nLin, nPosSeq] })
	Else
		aAdd(aString, { cString, "000" })
	Endif
Next

nIniChave := nTamFili + nTamCod + 1

If lAnoMes
	nFimChave := nTamFil + nTamChv
Else
	nFimChave := nTamFil
EndIf

If Empty(aString)
	cSeq	:= "000"
Else
	cSeq 	:= Iif(Empty(aString[Len(aString),2]),aString[Len(aString)-1,2],aString[Len(aString),2])
EndIf

If lAnoMes
	nFimChave := nTamFil + nTamChv + nTamSeq
Else
	nFimChave := nTamFil + nTamSeq
EndIf

If ( nPos := (aScan ( aAux, {|x| x[1] + If(lAnoMes,x[2],"") + If(lAnoMes,x[3],x[2]) == SubStr( cChaveAux, nIniChave, nFimChave ) } ) ) ) > 0
	If Empty( aAux[nPos][nPosSeq] )
		aAux[nPos][nPosSeq]	:= Soma1(cSeq)
	EndIF
EndIF

Do Case	// Ordena para acertar a sequencia
	Case cPaisLoc == "BRA" .And. cCodigo $ "S016|S017"						// por código
		aSort( aAux,,,{ |x,y| x[nPosFil] + x[nPosCha] + x[nPosCod] < y[nPosFil] + y[nPosCha] + y[nPosCod] } )

	Case cPaisLoc == "BRA" .And. cCodigo $ "S028|S029|S030|S031"			// por Fornecedor e código
		aSort( aAux,,,{ |x,y| x[nPosCodFor] + x[nPosFil] + x[nPosCha] + x[nPosCod] < y[nPosCodFor] + y[nPosFil] + y[nPosCha] + y[nPosCod] } )

	Case cPaisLoc == "BRA" .And. cCodigo $ "S011|S012|S018"					// por código
		aSort( aAux,,,{ |x,y| x[nPosFil] + x[nPosCha] + x[nPosCodBra] < y[nPosFil] + y[nPosCha] + y[nPosCodBra] } )

	Case cPaisLoc == "BRA" .And. cCodigo $ "S009|S014"						// por idade
		aSort( aAux,,,{ |x,y| x[nPosFil] + x[nPosCha] + x[nPosCod] + Str(x[nPosIdad]) < y[nPosFil] + y[nPosCha] + y[nPosCod] + Str(y[nPosIdad]) } )

	Case cPaisLoc == "BRA" .And. cCodigo $ "S008|S013"						// por código e Salário base
		aSort( aAux,,,{ |x,y| x[nPosFil] + x[nPosCha] + x[nPosCod] + Str(x[nPosSal],14,2) < y[nPosFil] + y[nPosCha] + y[nPosCod] + Str(y[nPosSal],14,2) } )

	Case cPaisLoc == "BRA" .And. cCodigo $ "S001"							// por AnoMes Inicial e Salário Controle
		aSort( aAux,,,{ |x,y| x[nPosFil] + x[nPosAnoI] + Str(x[nPosSalC],14,2) < y[nPosFil] + y[nPosAnoI] + Str(y[nPosSalC],14,2) } )

	Case cPaisLoc == "COL" .And. cCodigo == "S001"
		If lAnoMes
			aSort(aAux,,, {|x, y| x[nPosFil] + x[nPosCha] + Str(x[nPosRendAte], 4) < y[nPosFil] + y[nPosCha] + Str(y[nPosRendAte], 4)})
		Else
			aSort(aAux,,, {|x, y| x[nPosFil] + Str(x[nPosRendAte], 4) < y[nPosFil] + Str(y[nPosRendAte], 4)})
		EndIf

	Case cPaisLoc == "COL" .And. cCodigo == "S005"
		If lAnoMes
			aSort(aAux,,, {|x, y| x[nPosFil] + x[nPosCha] + Str(x[nPosSalMAte], 4) < y[nPosFil] + y[nPosCha] + Str(y[nPosSalMAte], 4)})
		Else
			aSort(aAux,,, {|x, y| x[nPosFil] + Str(x[nPosSalMAte], 4) < y[nPosFil] + Str(y[nPosSalMAte], 4)})
		EndIf

	Case lAnoMes															// por período chave
		aSort( aAux,,,{ |x,y| x[nPosFil] + x[nPosCha] + x[nPosSeq] < y[nPosFil] + y[nPosCha] + y[nPosSeq] } )

	Otherwise
		aSort( aAux,,,{ |x,y| x[nPosFil] + x[nPosSeq] < y[nPosFil] + y[nPosSeq] } )
EndCase

cSeq := "000"

If lAnoMes
	nFimChave := nTamFil + nTamChv
Else
	nFimChave := nTamFil
EndIf

//-- Implementa 001 na sequencia, caso nao tenha Sequencia registrada
If (  nPos := (aScan( aAux,{ |x| x[1] + If(lAnoMes,x[2],"") == SubStr(cChaveAux, nIniChave, nFimChave) .And. x[nUsado+1] == .F. } ) ) ) > 0 			//procura o registro a ser sequenciada
	For nX := nPos To Len(aAux)
		If lAnoMes
			If aAux[nX, nPosFil] + aAux[nX, nPosCha] == SubStr(cChaveAux, nIniChave, nFimChave) .And. aAux[nX, nUsado+1] ==.F.
				cSeq				:= Soma1(cSeq)
				aAux[nX][nPosSeq]	:= cSeq
			EndIF
		Else
			If aAux[nX, nPosFil] == SubStr(cChaveAux, nIniChave, nFimChave) .And. aAux[nX, nUsado+1] == .F.
				cSeq				:= Soma1(cSeq)
				aAux[nX][nPosSeq]	:= cSeq
			EndIF
		EndIF
	Next
Endif

IF lTela
	oGet:oBrowse:nAt := n
	oGet:oBrowse:Refresh(.T.)
Else
	aCols := aAux
EndIf

Return

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GP320SeqAlfa ³ Autor ³Natie             ³Data  ³12/12/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera sequencia de valores alfanumericos.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GP320SeqAlfa(cSeq)
Local nConta := 3
Local cLetra := ""
Local cRet   := ""
Local nAux   := 0
Local blMuda := .F.

	If Val(cSeq) >= 000 .And. Val(cSeq) <= 998
		cRet := Soma1(cSeq)
	ElseIf Val(cSeq) == 999
		cRet := "AA1"
	Else
		For nConta:= 3 To 1 Step - 1
			cLetra := SubStr(cSeq, nConta, 1)
			If nConta == 3 .Or. blMuda
				If (Asc(cLetra) >= 48 .and. Asc(cLetra) <= 56)
					cLetra := AllTrim(Str(val(cLetra) + 1))
					blMuda := .F.
				ElseIf Asc(cLetra) == 57
					cLetra := "A"
					blMuda := .F.
				ElseIf (Asc(cLetra) >= 65 .and. Asc(cLetra) <= 89)
					nAux := Asc(cLetra) + 1
					cLetra := CHR(nAux)
					blMuda := .F.
				ElseIf Asc(cLetra) == 90
					cLetra := "1"
					blMuda := .T.
				EndIf
			EndIf
			cRet := cLetra + cRet
		Next
	EndIf

Return ( cRet )

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Gp320Mov | Autor ³Andreia dos Santos     ³ Data ³ 13/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Movimenta o cursor para nao parar na coluna sequencia.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Gp320Mov( lMov )
Local ni		:= 0.00
Local nPosicao	:= 0.00
Local nPosTip	:= 0.00
Local nStep		:= 0.00
Local nPulos	:= 0.00
Local cCampo	:= cCampo := &(ReadVar())

	DEFAULT lMov := .F.

	If !lMov
		Return( .T. )
	EndIf

	nPosTip		:= GdFieldPos( "RCC_CHAVE" )
	nPosicao	:= GdFieldPos( "RCC_SEQUEN" )
	nPosicao ++

	nStep  := If(nPosTip > nPosicao , -1 , 1)
	nPulos := Abs( nPosicao - nPosTip )

	If nStep > 0
		nPulos --
	Else
		If nPostip != Len(aHeader)
			nPulos ++
		EndIf
	EndIf

	If Alltrim(Substr(readvar(),4)) == "RCC_CHAVE"
	//-- Garante o Posicionamento na Coluna Chamadora da Funcao.
		While oGet:oBrowse:nColPos <> nPosTip
			If oGet:oBrowse:nColPos > nPosTip
				oGet:oBrowse:GoLeft()
			ElseIf oGet:oBrowse:nColPos < nPosTip
				oGet:oBrowse:GoRight()
			EndIf
		End While

	EndIf

	For nI := 1 to nPulos
		If nStep > 0
			oGet:oBrowse:GoRight()
		Else
			oGet:oBrowse:GoLeft()
		EndIf
	Next

	If nPulos <= 0
		oGet:oBrowse:bEditCol:= { || Alwaystrue() }
	EndIf

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FilterExpr | Autor ³Tiago Malta          ³ Data ³04/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Reordenar os Registros da Tabela.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function TabFilExpr(Alias,Campo)
	Local lValid := .T.

	If !FunName() == "GPEA310M"
		If MsgYesNo("Deseja Alterar o Filtro?", "Atencao")
			&(Campo) := ALLTRIM(&(Campo))
			&(Campo) := BUILDEXPR(Alias,,&(Campo),,,,,,,,,,)
		EndIf

		If Substr(Alias,1,1)='S'
			If   AT(Alias, &(Campo) ) >0
				&(Campo) := STRTRAN( &(Campo) , Alias + "->", "")
				&(Campo) := STRTRAN( &(Campo) , SUBSTR(Alias,2,2), ALIAS+"->"+SUBSTR(Alias,2,2) )
			Else
				&(Campo) :=	STRTRAN( &(Campo) , SUBSTR(Alias,2,2) , ALIAS+"->"+SUBSTR(Alias,2,2) )
			EndIf
		Else
			If   AT(Alias, &(Campo) ) >0
				&(Campo) := STRTRAN( &(Campo) , Alias + "->", "")
				&(Campo) := STRTRAN( &(Campo) , Alias, ALIAS+"->"+Alias )
			EndIf
		EndIf

	EndIf

Return ( lValid )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fReorder | Autor ³Mauricio Takakura      ³ Data ³29/08/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Reordenar os Registros da Tabela.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function fReorder()
	Local nPosCha		:= GdFieldPos("RCC_CHAVE")
	Local nPosFil		:= IIf(GdFieldPos("RCC_FIL") > 0,GdFieldPos("RCC_FIL"), 1)
	Local nPosSeq		:= GdFieldPos("RCC_SEQUEN")
	Local nPosCod		:= GdFieldPos("CODIGO")
	Local nPosCodBra	:= GdFieldPos("BRA_" + cCodigo + "01")	//Posicao campo Código em tabelas nomeadas p/Brasil
	Local nPosIdad		:= GdFieldPos("IDADEATE")
	Local nPosSal		:= GdFieldPos("SALATE")
	Local nPosSalC		:= GdFieldPos("SALCATE")
	Local nPosAnoI		:= IIf(GdFieldPos("ANOMESI") > 0,GdFieldPos("ANOMESI"), 2)
	Local nPosRendAte	:= GdFieldPos("RENDATE")				// Posicao Campo A Valor da tabela no Acols
	Local nPosSalMAte	:= GdFieldPos("SALMINATE")				// Posicao Campo A Sal.Min. da tabela no Acols
	Local nPosCodFor	:= GdFieldPos("CODFOR")

	// Se linha onde ele esta posicionado nao estiver Ok, nao realiza atualizacao
	If  Gp320LinOk()
		Do Case	// Ordena para acertar a sequencia
			Case cPaisLoc == "BRA" .And. cCodigo $ "S016|S017"						// por código
				aSort( aCols,,,{ |x,y| x[nPosFil] + x[nPosCha] + x[nPosCod] < y[nPosFil] + y[nPosCha] + y[nPosCod] } )

			Case cPaisLoc == "BRA" .And. cCodigo $ "S028|S029|S030|S031"			// por fornecedor e código
				aSort( aCols,,,{ |x,y| x[nPosCodFor] + x[nPosFil] + x[nPosCha] + x[nPosCod] < y[nPosCodFor] + y[nPosFil] + y[nPosCha] + y[nPosCod] } )

			Case cPaisLoc == "BRA" .And. cCodigo $ "S011|S012|S018"					// por código
				aSort( aCols,,,{ |x,y| x[nPosFil] + x[nPosCha] + x[nPosCodBra] < y[nPosFil] + y[nPosCha] + y[nPosCodBra] } )

			Case cPaisLoc == "BRA" .And. cCodigo $ "S009|S014"						// por idade
				aSort( aCols,,,{ |x,y| x[nPosFil] + x[nPosCha] + x[nPosCod] + Str(x[nPosIdad]) < y[nPosFil] + y[nPosCha] + y[nPosCod] + Str(y[nPosIdad]) } )

			Case cPaisLoc == "BRA" .And. cCodigo $ "S008|S013"						// por código e Salário base
				aSort( aCols,,,{ |x,y| x[nPosFil] + x[nPosCha] + x[nPosCod] + Str(x[nPosSal],14,2) < y[nPosFil] + y[nPosCha] + y[nPosCod] + Str(y[nPosSal],14,2) } )

			Case cPaisLoc == "BRA" .And. cCodigo $ "S001"							// por AnoMes Inicial e Salário Controle
				aSort( aCols,,,{ |x,y| x[nPosFil] + x[nPosAnoI] + Str(x[nPosSalC],14,2) < y[nPosFil] + y[nPosAnoI] + Str(y[nPosSalC],14,2) } )

			Case cPaisLoc == "COL" .And. cCodigo == "S001"
				If lAnoMes
					aSort(aCols,,, {|x, y| x[nPosFil] + x[nPosCha] + Str(x[nPosRendAte], 4) < y[nPosFil] + y[nPosCha] + Str(y[nPosRendAte], 4)})
				Else
					aSort(aCols,,, {|x, y| x[nPosFil] + Str(x[nPosRendAte], 4) < y[nPosFil] + Str(y[nPosRendAte], 4)})
				EndIf

			Case cPaisLoc == "COL" .And. cCodigo == "S005"
				If lAnoMes
					aSort(aCols,,, {|x, y| x[nPosFil] + x[nPosCha] + Str(x[nPosSalMAte], 4) < y[nPosFil] + y[nPosCha] + Str(y[nPosSalMAte], 4)})
				Else
					aSort(aCols,,, {|x, y| x[nPosFil] + Str(x[nPosSalMAte], 4) < y[nPosFil] + Str(y[nPosSalMAte], 4)})
				EndIf

			Case lAnoMes															// por período chave
				aSort( aCols,,,{ |x,y| x[nPosFil] + x[nPosCha] + x[nPosSeq] < y[nPosFil] + y[nPosCha] + y[nPosSeq] } )

			Otherwise
				aSort( aCols,,,{ |x,y| x[nPosFil] + x[nPosSeq] < y[nPosFil] + y[nPosSeq] } )
		EndCase

		oGet:oBrowse:nAt := n
		oGet:oBrowse:Refresh(.T.)
	EndIf

Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fAttTab | Autor ³Marcos Coutinho Araujo ³ Data ³11/08/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualizar os registros da tabela                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function fAttTab( oDlg )
Local nPosCha 	:= GdFieldPos("RCC_CHAVE")
Local nPosFil	:= IIf(GdFieldPos("RCC_FIL") > 0,GdFieldPos("RCC_FIL"), 1)
Local nPosSeq	:= GdFieldPos("RCC_SEQUEN")
Local aTabEsoc := {"S047","S048","S049","S050","S051","S053","S054","S055","S056","S119","S120", "S138"}
Local nPos		:= 0
Local lAtt		:= .F.

	//Verifica se a tabela selecionada é uma tabela do eSocial
	nPos := aScan(aTabEsoc,{ |x| x == AllTrim( cCodigo ) } )

	//Se for eSocial, inicia processo de atualização
	If( MSGYESNO( OemToAnsi(STR0144) + AllTrim( cCodigo ) + OemToAnsi(STR0145) )) //"A atualização irá limpar os registros da tabela corrente " ##". Prosseguir?"
		DbSelectArea("RCC")
		DbSetOrder(1)
		dbSeek(xFilial("RCC") + AllTrim( cCodigo ) )
		While RCC->(!EOF()) .AND. xFilial('RCC') + AllTrim( cCodigo ) == RCC->RCC_FILIAL + RCC->RCC_CODIGO
			If AllTrim(RCC->RCC_CODIGO) == AllTrim( cCodigo )
				RCC->(RecLock("RCC",.F.))
				RCC->( dbDelete() )
				RCC->( MsUnlock() )
			EndIf
			RCC->(dbSkip())
		Enddo

		//Chama a rotina de carga de dados novamente
		GpCrgBRA()

		If !lAtt
			MsgAlert(OemToAnsi(STR0146), OemToAnsi(STR0083)) // "Tabela Atualizada com Sucesso. Este painel será fechado para efetivar atualização"
			lAtt := .T.
		EndIf

		//Finaliza a tela
		oDlg:END()
	EndIf
Return ( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Duplicar ³ Autor ³ Kelly                 ³ Data ³ 24/10/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Duplicar uma tabela ja existente.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Duplicar()
Local aKeys	     	:= GetKeys()
Local nX, nY
Local oDlg
Local oFont1
// Variaveis para controle de coordenadas da janela
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local bSet15		:= { || NIL }		// Bloco com as validacoes do botao OK
Local bSet24		:= { || NIL }		// Bloco com as validacoes do botao Cancelar
Local cConsPad      := "XM0"            // Consulta padrao do campo RCC_FILIAL
Local nPosFil		:= IIf(GdFieldPos("RCC_FIL") > 0,GdFieldPos("RCC_FIL"), 1)
Local nPosAnoI		:= IIf(GdFieldPos("ANOMESI") > 0,GdFieldPos("ANOMESI"), 2)

Private lChkBox1    := .F.
Private oChkBox1, oNovaFilOrig, oNovoMesAnoOrig, oFilDest, oMesAnoDest
Private cNovaFilOrig
Private cNovoMesAnoOrig
Private cFilOrig	:= CriaVar("RCC_FILIAL")
Private cMesAnoOrig	:= CriaVar("RCC_CHAVE")
Private cFilDest 	:= CriaVar("RCC_FILIAL")
Private cMesAnoDest := CriaVar("RCC_CHAVE")

	cFilOrig 		    := aCols[n][nPosFil]
	cMesAnoOrig 	    := aCols[n][nPosAnoI]
	cNovaFilOrig    	:= cFilOrig
	cNovoMesAnoOrig     := cMesAnoOrig

	// Se linha onde ele esta posicionado nao estiver Ok, nao realiza duplicacao
	If  Gp320LinOk()

	// Observacao importante: Se existirem linhas deletadas no aCols elas serao filtradas e
	// a duplicao ocorrera com as linhas validas. Todavia, ao cancelar a duplicacao ou apos duplicar
	// a linha deletada permanecera no aCols, viabilizando a reativacao da linha ate que seja
	// selecionado 'Confirmar'.

		FiltraDados(cFilOrig,cMesAnoOrig)

		oGet:Goto(1)
		oGet:oBrowse:Refresh(.T.)

			DEFINE FONT oFont1  NAME "Arial" SIZE 0,-13
			DEFINE FONT oFont2  NAME "Arial" SIZE 0,-13 BOLD
			DEFINE FONT oFont3  NAME "Arial" SIZE 0,-11

			//-- Monta as Dimensoes dos Objetos
			aAdvSize		:= MsAdvSize()
			aAdvSize[5]		:=	460 //horizontal
			aAdvSize[3]		:=	230 // LARGURA
			aAdvSize[4]		:=	130  // ALTURA
			aAdvSize[6]		:=  330 //Vertical
			aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 3 , 3 }
			aAdd( aObjCoords , { 000 , 070 , .T. , .F. } )
			aAdd( aObjCoords , { 000 , 030 , .T. , .F. } )
			aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

		    DEFINE MSDIALOG oDlg FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE OemToAnsi(STR0035) OF GetWndDefault() STYLE DS_MODALFRAME PIXEL  //"Manutencao de Tabelas"

		   		@aObjSize[1,1],aObjSize[1,2] TO aObjSize[1,3],aObjSize[1,4] LABEL OemToAnsi(STR0039) OF oDlg PIXEL //"Origem"

				@aObjSize[1,1]+10,aObjSize[1,2]+5 SAY OemToAnsi(STR0037) SIZE 030,007 OF oDlg PIXEL FONT oFont1 COLOR CLR_BLUE	//"Filial:"
				@aObjSize[1,1]+10,aObjSize[1,2]+50 SAY cFilOrig SIZE 030,007 OF oDlg  PIXEL FONT oFont2 COLOR CLR_BLUE

				@aObjSize[1,1]+10,aObjSize[1,2]+100  SAY OemToAnsi(STR0192) SIZE 033,007 OF oDlg PIXEL FONT oFont1 COLOR CLR_BLUE	//"Ano/Mês:"
				@aObjSize[1,1]+10,aObjSize[1,2]+150  SAY SubStr(cMesAnoOrig,3,4) + "/" + SubStr(cMesAnoOrig,1,2);
											 			SIZE 030,007 OF oDlg PIXEL FONT oFont2 COLOR CLR_BLUE

				@aObjSize[1,1]+25,aObjSize[1,2]+5 TO aObjSize[1,3]-5,aObjSize[1,4]-5 OF oDlg PIXEL  //"Alterar Origem"

				@aObjSize[1,1]+30,aObjSize[1,2]+10 CHECKBOX oChkBox1 VAR lChkBox1 PROMPT STR0043 PIXEL SIZE 70,7 OF oDlg ON CHANGE ( fChkBox() )

				@aObjSize[1,1]+50,aObjSize[1,2]+10 SAY OemToAnsi(STR0037) SIZE 030,007	OF oDlg PIXEL FONT oFont1 	//"Filial:"
				@aObjSize[1,1]+50,aObjSize[1,2]+50 MSGET oNovaFilOrig VAR cNovaFilOrig SIZE 015,007 OF oDlg PIXEL FONT oFont3	F3 cConsPad

				@aObjSize[1,1]+50,aObjSize[1,2]+100 SAY OemToAnsi(STR0192) SIZE 033,007	OF oDlg PIXEL  FONT oFont1	//"Ano/Mês:"
				@aObjSize[1,1]+50,aObjSize[1,2]+150 MSGET oNovoMesAnoOrig VAR cNovoMesAnoOrig	SIZE 030,007	OF oDlg PIXEL  FONT oFont3

				@aObjSize[2,1], aObjSize[2,2] TO aObjSize[2,3],aObjSize[2,4] LABEL OemToAnsi(STR0040)						OF oDlg PIXEL //"Destino"

		        @aObjSize[2,1]+10, aObjSize[2,2]+10 SAY OemToAnsi(STR0037) SIZE 030,007 OF oDlg PIXEL  FONT oFont1	//"Filial:"
				@aObjSize[2,1]+10, aObjSize[2,2]+50 MSGET oFilDest VAR cFilDest SIZE 015,007 OF oDlg PIXEL  FONT oFont3  F3 cConsPad

				@aObjSize[2,1]+10, aObjSize[2,2]+100 SAY OemToAnsi(STR0192) SIZE 033,007 OF oDlg PIXEL FONT oFont1	//"Ano/Mês:"
				@aObjSize[2,1]+10, aObjSize[2,2]+150 MSGET oMesAnoDest VAR cMesAnoDest SIZE 030,007 OF oDlg PIXEL FONT oFont3

				If lChkbox1
					oNovaFilOrig:Enable()
					oNovoMesAnoOrig:Enable()
				Else
					oNovaFilOrig:Disable()
					oNovoMesAnoOrig:Disable()
				Endif

				bSet15 := { || nOpcA := 1 , If(!fJaExiste(cFilOrig,cMesAnoOrig,cNovaFilOrig,cNovoMesAnoOrig,cFilDest,cMesAnoDest,lChkBox1),   oDlg:End(),)}
				bSet24 := { || nOpcA := 2 , Aplicar(aVisual) , fReorder() , RestKeys(aKeys,.T.), oDlg:End()}

				oDlg:lEscClose := .F. //Nao permite sair ao se pressionar a tecla ESC.

			ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 )
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fChkBox  ³ Autor ³ Kelly                 ³ Data ³ 24/10/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Habilita/Desabilita os campos de origem, de acordo com a   ³±±
±±|          ³ marcacao do CheckBox.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fChkBox()

	If lChkBox1
		oNovaFilOrig:Enable()
		oNovoMesAnoOrig:Enable()
		oNovaFilOrig:SetFocus()
	Else
		oNovaFilOrig:Disable()
		oNovoMesAnoOrig:Disable()
	EndIf

	oNovaFilOrig:Refresh()
	oNovoMesAnoOrig:Refresh()

Return ( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GeraRegs ³ Autor ³ Kelly                 ³ Data ³ 20/10/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera os novos registros a partir da tabela origem indicada.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GeraRegs(cFil, cChav)
Local aTabela	:= {}
Local nReg		:= Len(aCols)
Local nCols		:= Len(aHeader)
Local nX		:= 0
Local nY        := 0
Local nCont     := 1
Local nPosFil	:= IIf(GdFieldPos("RCC_FIL") > 0,GdFieldPos("RCC_FIL"), 1)
Local nPosAnoI	:= IIf(GdFieldPos("ANOMESI") > 0,GdFieldPos("ANOMESI"), 2)
Local nPosSeq	:= GdFieldPos("RCC_SEQUEN")

	// Alimenta a array temporaria com os registros que deverao ser duplicados
	For nX := 1 to nReg
		If (aCols[nX][nPosFil] == cFil .and. aCols[nX][nPosAnoI] == cChav) .And. (aCols[nX,nCols+1] == .F.)
			aAdd(aTabela,Array(nCols+1))
			For nY := 1 to nCols+1
				If nY == nCols+1
					aTabela[nCont][nY] := .F.
				Else
					aTabela[nCont][nY] := aCols[nX][nY]
				EndIf
			Next nY
			nCont++
		EndIf
	Next nX

	// Atualiza aCols com os novos registros
	If (Len(aTabela)>0)
		nCont := nReg + 1

		For nX := 1 to Len(aTabela)
			aAdd(aCols,Array(nCols+1))
			aCols[nCont][nPosFil] := cFilDest
			If nPosSeq > 0
				aCols[nCont][nPosSeq] := "000"
			EndIf
			aCols[nCont][nPosAnoI] := cMesAnoDest
			For nY := nPosAnoI+1 to nCols+1
				aCols[nCont][nY] := aTabela[nX][nY]
			Next nY
			nCont++
		Next nX

	   // Atualiza os registros de origem caso o usuario tenha marcado a opcao ALTERAR ORIGEM
		If lChkBox1
			For nX := 1 to nReg
				If (aCols[nX][nPosFil] = cFil .and. aCols[nX][nPosAnoI] = cChav) .and. (aCols[nX,nCols+1] = .F.)
					aCols[nX][nPosFil] := cNovaFilOrig
					aCols[nX][nPosAnoI] := cNovoMesAnoOrig
				EndIf
			Next nX
		EndIf

		Aplicar(aCols)

	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Aplicar  ³ Autor ³ Kelly                 ³ Data ³ 25/10/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Aplicar as alteracoes efetuadas, atualizando o aCols .     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Aplicar(aArray)
Local nRegAntes	:= Len(aAntes)
Local nRegACols := Len(aArray)
Local nCont
Local nX, nY

	Private nCols := Len(aHeader)

	nCont := nRegAntes + 1

	// Adiciona os novos registros na matriz dos dados mantidos
	For nX := 1 to nRegACols
		aAdd(aAntes,Array(nCols+1))
		For nY := 1 to nCols+1
			aAntes[nCont][nY] := aArray[nX][nY]
		Next nY
		nCont++
		nRegAntes++
	Next nX

	// Limpa o aCols
	aCols := {}
	aCols := Array (0,0)

	// Atualiza o aCols de acordo com a matriz anterior
	For nX := 1 To nRegAntes
		aAdd(aCols,Array(nCols+1))
		For nY := 1 to nCols+1
			aCols[nX][nY] := aAntes[nX][nY]
		Next nY
	Next nX

	fReOrder()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Reajustar ³ Autor ³ Kelly                ³ Data  ³ 25/10/05³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Aplicar um percetual ou somar um valor nos dados da tabela.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Reajustar()
Local aArea		    := GetArea()
Local aKeys		    := GetKeys()
Local aAreaRCB	    := RCB->( GetArea() )
Local nX
Local oDlg
Local oFont1
Local oRadio
Local bBlock        := { || NIL }
Local nRegVis
Local nReg	        := Len(aCols)
Local nCont	        := 1
Local nCont2        := 1
Local cFilOrig	    := CriaVar("RCC_FILIAL")
Local cMesAnoOrig   := CriaVar("RCC_CHAVE")
// Variaveis para controle de coordenadas da janela
Local aAdvSize	    := {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObj2Size		:= {}
Local aObjCoords	:= {}
Local aObj2Coords   := {}
Local bSet15		:= { || NIL }
Local bSet24		:= { || NIL }
Local nPosFil	:= IIf(GdFieldPos("RCC_FIL") > 0,GdFieldPos("RCC_FIL"), 1)
Local nPosAnoI	:= IIf(GdFieldPos("ANOMESI") > 0,GdFieldPos("ANOMESI"), 2)

Private lChkPerc    := .F.
Private lChkSomar   := .F.
Private nPerc := 0
Private nSomar:= 0
Private oPerc, oSomar
Private nItem := 1
Private oLbx,cLbx
Private aLbx	    := {}
Private cFilial1    := aCols[n][nPosFil]
Private cChave1	    := aCols[n][nPosAnoI]
Private oOk         := LoadBitmap( GetResources(), "LBOK" )
Private oNo         := LoadBitmap( GetResources(), "LBNO" )
Private nCampos     := 0
Private nRadio	    := 0

	cFilOrig	        := aCols[n][nPosFil]
	cMesAnoOrig	        := aCols[n][nPosAnoI]

	// Se linha onde ele esta posicionado nao estiver Ok, nao realiza reajuste
	If Gp320LinOk()
		dbSelectArea( "RCB" )
		dbSetOrder(1)
		dbSeek(xFilial("RCB") + cCodigo)
		nX := 1
		While !Eof() .and. RCB->RCB_CODIGO == cCodigo
			If RCB->RCB_TIPO == "N"
				aAdd(aLbx, { .F. , RCB->RCB_DESCPO , nX })
			Endif
			nX++
			nCampos++
			dbSkip()
		Enddo

		// Se nao existir campo numerico nao apresenta a tela de reajuste nem realiza filtro
		If Len(aLbx) == 0
			AVISO(OemToAnsi(STR0014),OemToAnsi(STR0074),{'OK'},,)  //"Atencao" ### "Nao ha campos a serem reajustados."
		Else

			// Observacao importante: Se existirem linhas deletadas no aCols elas serao filtradas e
			// o reajuste ocorrera com as linhas validas. Todavia, ao cancelar o reajuste ou apos reajustar
			// a linha deletada permanecera no aCols, viabilizando a reativacao da linha ate que seja
			// selecionado 'Confirmar'.
			FiltraDados(cFilOrig,cMesAnoOrig)

			oGet:Goto(1)
			oGet:oBrowse:Refresh(.T.)
			//-- Monta as Dimensoes dos Objetos
			aAdvSize		:= MsAdvSize()
			aAdvSize[5]		:=	543 // Horizontal
			aAdvSize[3]		:=	270 // LARGURA
			aAdvSize[4]		:=	140 // ALTURA
			aAdvSize[6]		:=  450 // Vertical
			aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 3 , 3 }
			aAdd( aObjCoords , { 000 , 025 , .T. , .F. } )
			aAdd( aObjCoords , { 000 , 090 , .T. , .F. } )
			aAdd( aObjCoords , { 000 , 045 , .T. , .F. } )
			aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )


			aAdd( aObj2Coords , { 000 , 025 , .T. , .F. } )
			aAdd( aObj2Coords , { 000 , 090 , .T. , .F. , .T. } )
			aAdd( aObj2Coords , { 000 , 050 , .T. , .F. } )
			aObj2Size		:= MsObjSize( aInfoAdvSize , aObj2Coords )

		    DEFINE FONT oFont1  NAME "Arial" SIZE 0,-13
			DEFINE FONT oFont2  NAME "Arial" SIZE 0,-13 BOLD
			DEFINE FONT oFont3  NAME "Arial" SIZE 0,-11

			DEFINE MSDIALOG oDlg FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE OemToAnsi(STR0042) OF GetWndDefault() STYLE DS_MODALFRAME PIXEL  //"Manutencao de Tabelas"

				@aObjSize[1,1],aObjSize[1,2] TO aObjSize[1,3],aObjSize[1,4] LABEL "" OF oDlg PIXEL

				@aObjSize[1,1]+10,aObjSize[1,2]+5 SAY OemToAnsi(STR0037) SIZE 030,007 OF oDlg PIXEL FONT oFont1 COLOR CLR_BLUE //"Filial:"
				@aObjSize[1,1]+10,aObjSize[1,2]+50 SAY cFilial1			 SIZE 030,007 OF oDlg PIXEL FONT oFont2 COLOR CLR_BLUE

				@aObjSize[1,1]+10,aObjSize[1,2]+100 SAY OemToAnsi(STR0192)	SIZE 033,007 OF oDlg PIXEL FONT oFont1 COLOR CLR_BLUE	//"Ano/Mes:"
				@aObjSize[1,1]+10,aObjSize[1,2]+150 SAY SubStr(cChave1,1,4) + "/" + SubStr(cChave1,5,2) SIZE 030,007 OF oDlg PIXEL FONT oFont2 COLOR CLR_BLUE

				@aObjSize[2,1],aObjSize[2,2] TO aObjSize[2,3],aObjSize[2,4] LABEL "" OF oDlg PIXEL

				@aObjSize[2,1]+10,aObjSize[2,2]+10 TO aObjSize[2,3]*0.65,aObjSize[2,4]*0.50 LABEL "" OF oDlg PIXEL

			  	@aObjSize[2,1]+20,aObjSize[2,2]+20 CHECKBOX oChkPerc VAR lChkPerc PROMPT "" PIXEL SIZE 7,7 OF oDlg;  //"Aplicar Percentual:"
				ON CHANGE ( fChkPerc() )
		        @aObjSize[2,1]+20,aObjSize[2,2]+30 SAY OemToAnsi(STR0046) SIZE 030,009 OF oDlg FONT oFont1 PIXEL
		        @aObjSize[2,1]+20,aObjSize[2,2]+70 MSGET oPerc VAR nPerc SIZE 030,007 OF oDlg PICTURE "@E 999.99" FONT oFont3 PIXEL HASBUTTON

				@aObjSize[2,3]*0.66,aObjSize[2,2]+10 TO aObjSize[2,3]-10, aObjSize[2,4]*0.50 LABEL "" OF oDlg PIXEL

				@(aObjSize[2,3]*0.66)+10,aObjSize[2,2]+20 CHECKBOX oChkSomar VAR lChkSomar PROMPT "" PIXEL SIZE 7,7 OF oDlg;  //"Somar:"
			    ON CHANGE ( fChkSomar() )
		        @aObjSize[2,3]*0.66+10,aObjSize[2,2]+30 SAY OemToAnsi(STR0047) SIZE 030,007 OF oDlg  FONT oFont1 PIXEL
		        @aObjSize[2,3]*0.66+10,aObjSize[2,2]+70 MSGET oSomar VAR nSomar SIZE 030,007 OF oDlg PIXEL	PICTURE "@E 9,999.99" FONT oFont3 HASBUTTON

			   	If lChkPerc
					oPerc:Enable()
				Else
					oPerc:Disable()
				EndIf

				If lChkSomar
					oSomar:Enable()
				Else
					oSomar:Disable()
				EndIf

				@aObj2Size[2][1]+10, aObj2Size[2][2]+132 LISTBOX oLbx VAR cLbx FIELDS HEADER  "", OemtoAnsi(STR0048); //"Colunas"
				         SIZE aObj2Size[2][3]/2.2 ,aObj2Size[2][4]-20 ON DBLCLICK (aLbx:=fSelLbx(oLbx:nAt,aLbx),oLbx:Refresh()) PIXEL
				oLbx:SetArray(aLbx)
				oLbx:LHSCROLL := .F.
				oLbx:LVSCROLL := .T.
				oLbx:nFreeze  := 1
				oLbx:bLine    := { || {If(aLbx[oLbx:nAt,1],oOk,oNo),aLbx[oLbx:nAt,2]}}
				oLbx:nAt      := Max(nItem,1)
				oLbx:nRowPos  := 1

				@ aObjSize[3,1],aObjSize[3,2] GROUP oGroup TO aObjSize[3,3],aObjSize[3,4] PROMPT OemtoAnsi(STR0078) OF oDlg; //"Arredondamento"
								       PIXEL COLOR CLR_BLUE
				oGroup:SetFont(oFont1)

				bBlock	:= { |x| If(ValType(x)=='U', nRadio , nRadio := x ) }
				oRadio	:= TRadMenu():New( aObjSize[3,1]+10,aObjSize[3,2]+10, {oEmToAnsi(STR0079), oEmToAnsi(STR0080), oEmToAnsi(STR0081)},bBlock,oDlg,,,,,,,,80,10)	//"Nenhum"###"Padrao"###"Acima"
				nRadio	:= oRadio:nOption

				bSet15 := { || nOpcA := 1 , If(fValido(),  oDlg:End() , )}
				bSet24 := { || nOpcA := 2 , Aplicar(aVisual) , fReorder() , 	RestKeys(aKeys,.T.), oDlg:End() }

				oDlg:lEscClose := .F. //Nao permite sair ao se pressionar a tecla ESC.

			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 ) CENTERED

		EndIf
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fChkPerc ³ Autor ³ Kelly                 ³ Data ³ 26/10/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Habilita/Desabilita os campos de "Aplicar Percentual"      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fChkPerc()

	If lChkPerc
		oPerc:Enable()
		oPerc:Setfocus()
	Else
		oPerc:Disable()
	EndIf
	oPerc:Refresh()

Return ( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fChkSomar ³ Autor ³ Kelly                 ³ Data ³ 26/10/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Habilita/Desabilita os campos de "Somar"                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fChkSomar()

	If lChkSomar
		oSomar:Enable()
		oSomar:Setfocus()
	Else
		oSomar:Disable()
	EndIf
	oSomar:Refresh()

Return ( .T. )

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fSelLbx  ³ Autor ³ Kelly                 ³ Data ³ 26.10.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Marca e desmarca itens da ListBox 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fSelLbx(nAt,aArray)

	aArray[nAt,1]   := If(aArray[nAt,1], .F., .T.)

Return ( aArray )

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FiltraDados ³ Autor ³ Kelly                 ³ Data ³ 26.10.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra a grade apresentando apenas os dados da tabela         ³±±
±±³          | selecionada.						                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FiltraDados(cFilDe, cMesAnoDe)
Local nX, nY
Local nCont  := 1
Local nCont2 := 1
Local nCols  := Len(aHeader)
Local nReg	 := Len(aCols)
Local nRegVis
Local nPosFil	:= IIf(GdFieldPos("RCC_FIL") > 0,GdFieldPos("RCC_FIL"), 1)
Local nPosAnoI	:= IIf(GdFieldPos("ANOMESI") > 0,GdFieldPos("ANOMESI"), 2)

	aVisual      := {}
	aAntes       := {}

	// Alimenta a array de visualizacao apenas com os registros da tab. selecionada.
	For nX := 1 to nReg
		If Len(aCols[nX]) <> 0 .And. !Empty(aCols[nX])
			If (aCols[nX][nPosFil] == cFilDe .and. aCols[nX][nPosAnoI] == cMesAnoDe) .And. (aCols[nX][nCols+1] == .F.)
				aAdd(aVisual,Array(nCols+1))
				For nY := 1 to nCols+1
					aVisual[nCont][nY]	:= aCols[nX][nY]
				Next nY
				nCont++
			Else
				aAdd(aAntes,Array(nCols+1))
				For nY := 1 to nCols+1
					aAntes[nCont2][nY]	:= aCols[nX][nY]
				Next nY
				nCont2++
			EndIf
		EndIf
	Next nX

	nRegVis := Len(aVisual)

	// Limpa o aCols
	aCols := {}
	aCols := Array( 0 , 0 )

	// Alimenta o aCols com os dados da array de visualizacao.
	For nX := 1 to nRegVis
		aAdd(aCols,Array(nCols+1))
		For nY := 1 to nCols+1
			aCols[nX][nY] := aVisual[nX][nY]
		Next nY
	Next nX

Return

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fValido        ³ Autor ³ Kelly                 ³ Data ³ 26.10.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida as opcoes e os campos e faz o reajuste                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fValido()
Local lOk       := .T.
Local nP, nX, nY
Local nReg		:= Len(aCols)
Local nCols		:= Len(aHeader)
Local nRSoma, nRPerc
Local nAux
Local nEstouro := 0

	// Verifica se alguma opcao foi marcada e se o valor ou o % foi informado
	If !lChkPerc .and. !lChkSomar
		lOk := .F.
		AVISO(OemToAnsi(STR0014),OemToAnsi(STR0049),{'OK'},,STR0053)  //"Atencao" ### "Selecione pelo menos uma opcao de reajuste"
	ElseIf (lChkPerc .and. nPerc == 0)
		lOk := .F.
		AVISO(OemToAnsi(STR0014),OemToAnsi(STR0051),{'OK'},,STR0053)  //"Atencao" ### "Informe o percentual de reajuste."
	ElseIf (lChkSomar .and. nSomar == 0)
		lOk := .F.
		AVISO(OemToAnsi(STR0014),OemToAnsi(STR0052),{'OK'},,STR0053)  //"Atencao" ### "Informe o valor do reajuste"
	EndIf

	nP := Ascan( aLbx, { |x| x[1] == .T. } )
	If (nP = 0) .and. (lOk)
		lOk := .F.
		AVISO(OemToAnsi(STR0014),OemToAnsi(STR0050),{'OK'},,STR0053)  //"Atencao" ### "Selecione pelo menos uma coluna a ser reajustada"
	EndIf

	// Estando tudo ok, aplica o reajuste
	If lOk
		For nY := 1 to nCols
			If aScan(aLbx,{ |x| (Upper(AllTrim(x[2])) == Upper(AllTrim(aHeader[nY][1])) .and. (x[1] == .T.)) } ) > 0
				For nX := 1 to nReg
					nRSoma := aCols[nX][nY] + nSomar
					If nRadio == 1
						nRPerc := NoRound(aCols[nX][nY] * (nPerc/100))
					Elseif nRadio == 2
						nRPerc := Round(aCols[nX][nY] * (nPerc/100),MsDecimais(1))
					Else
						nAux := aCols[nX][nY] * (nPerc/100)
						If nAux - Round(nAux,MsDecimais(1)) > 0.00
							nAux := NoRound((nAux + .01),MsDecimais(1))
						Else
							nAux := Round(nAux,MsDecimais(1))
						EndIf
						nRPerc := nAux
					Endif
					If 	Len(AllTrim(Transform((nRSoma + nRPerc),aHeader[nY][3]))) > aHeader[nY][4]
						nEstouro := nEstouro + 1
						aCols[nX][nY] := Val(aHeader[nY][3])
					Else
						aCols[nX][nY] := nRSoma + nRPerc
					EndIf
				Next nX
			Endif
		Next nY
		If nEstouro > 0
			MsgAlert(OemToAnsi(STR0091) + AllTrim(STR(nEstouro)) + OemToAnsi(STR0092), OemToAnsi(STR0083)) // "O Valor do reajuste excedeu em " ### " campo(s)" ### "Atencao"
		EndIf
	EndIf

	oGet:oBrowse:Refresh(.T.)

	If lOk
		Aplicar(Acols)
	EndIf

Return ( lOk  )

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fJaExiste      ³ Autor ³ Kelly                 ³ Data ³ 28.10.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica no aCols e no aAntes a existencia de registros com      ³±±
±±³          ³ a filial e o mes/ano indicados.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFil01 = Filial Origem                                           ³±±
±±³          ³ cChave01 = Mes/Ano Origem                                        ³±±
±±³          ³ cFil02 = Nova Filial Origem                                      ³±±
±±³          ³ cChave02 = Novo Mes/Ano Origem                                   ³±±
±±³          ³ cFil03 = Filial Destino                                          ³±±
±±³          ³ cChave03 = Mes/Ano Destino                                       ³±±
±±³          ³ lAltOrig = CheckBox "ALTERA ORIGEM"                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fJaExiste(cFil01,cChave01,cFil02,cChave02,cFil03,cChave03,lAltOrig)
Local nA := 0
Local nB := 0
Local nC := 0
Local nD := 0
Local lExiste := .F.
Local cOk := fCamposOk(cFil02,cChave02,cFil03,cChave03,lAltOrig)
Local nPosFil	:= IIf(GdFieldPos("RCC_FIL") > 0,GdFieldPos("RCC_FIL"), 1)
Local nPosAnoI	:= IIf(GdFieldPos("ANOMESI") > 0,GdFieldPos("ANOMESI"), 2)

	If cOk <> ""
		lExiste := .T.
		AVISO(OemToAnsi(STR0014),OemToAnsi(cOk),{'OK'},,) //"Atencao"
	Else
		If lAltOrig
			nA := ( Ascan( aCols, { |x| x[nPosFil] == cFil02 .and. x[nPosAnoI] == cChave02 } ) )
			nB := ( Ascan( aAntes,{ |x| x[nPosFil] == cFil02 .and. x[nPosAnoI] == cChave02 } ) )
		Else
			nC := ( Ascan( aCols, { |x| x[nPosFil] == cFil03 .and. x[nPosAnoI] == cChave03 } ) )
			nD := ( Ascan( aAntes,{ |x| x[nPosFil] == cFil03 .and. x[nPosAnoI] == cChave03 } ) )
		EndIf

		If (nA > 0) .or. (nB > 0) .or. (nC > 0) .or. (nD > 0)
			lExiste := .T.
			AVISO(OemToAnsi(STR0014),OemToAnsi(STR0054),{'OK'},,)  //"Atencao" ### "Ja existe(m) registro(s) com Filial e Mes/Ano indicados."
		EndIf

		If !lExiste
			GeraRegs(cFil01,cChave01)
		EndIf
	EndIf

Return ( lExiste )

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fCamposOk      ³ Autor ³ Kelly                 ³ Data ³ 31.10.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida os campos digitados                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFilOk1   = Filial Origem                                        ³±±
±±³          ³ cChaveOk1 = Mes/Ano Orige                                        ³±±
±±³          ³ cFilOk2   = Nova Filial Origem                                   ³±±
±±³          ³ cChaveOk2 = Novo Mes/Ano Origem                                  ³±±
±±³          ³ lOrigem   = CheckBox "ALTERA ORIGEM"                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fCamposOk(cFilOk1,cChaveOk1,cFilOk2,cChaveOk2,lOrigem)
Local aArea		:= GetArea()
Local aAreaSM0	:= SM0->(GetArea())
Local cExibeAviso := ""

cChaveOk1 := substr(cChaveOk1,1,2)+substr(cChaveOk1,3,4)
cChaveOk2 := substr(cChaveOk2,1,2)+substr(cChaveOk2,3,4)


	dbSelectArea("SM0")
	dbSetOrder(1)

	If lOrigem
		If (AllTrim(cFilOk1) <> "") .and. (!dbSeek(cEmpAnt + AllTrim(cFilOk1)))
			cExibeAviso := STR0055	// Filial Origem Invalida
		ElseIf (AllTrim(cChaveOk1) <> "") .and. (Len(AllTrim(cChaveOk1)) < 6)
			cExibeAviso := STR0057	// Mes/Ano Origem Invalido
		ElseIf (AllTrim(cChaveOk1) <> "") .and. ((VAL(SubStr(cChaveOk1,1,2)) < 1) .or. (VAL(SubStr(cChaveOk1,1,2)) > 12))
			cExibeAviso := STR0059	// Mes Origem Invalido
		ElseIf (AllTrim(cChaveOk1) <> "") .and. (VAL(SubStr(cChaveOk1,3,4)) < 1900)
			cExibeAviso := STR0060	// Ano Origem Invalido
		EndIf
	EndIf

	If (AllTrim(cFilOk2) <> "") .and. (!dbSeek(cEmpAnt + AllTrim(cFilOk2)))
		cExibeAviso := STR0056	// Filial Destino Invalida
	ElseIf (AllTrim(cChaveOk2) <> "") .and. (Len(AllTrim(cChaveOk2)) < 6)
		cExibeAviso := STR0058	// Mes/Ano Destino Invalido
	ElseIf (AllTrim(cChaveOk2) <> "") .and. ((VAL(SubStr(cChaveOk2,1,2)) < 1) .Or. (VAL(SubStr(cChaveOk2,1,2)) > 12))
		cExibeAviso := STR0061	// Mes Destino Invalido
	ElseIf (AllTrim(cChaveOk2) <> "") .and. (VAL(SubStr(cChaveOk2,3,4)) < 1900)
		cExibeAviso := STR0062	// Ano Destino Invalido
	ElseIf AllTrim(cFilOk1) == AllTrim(cFilOk2)  .And. (cChaveOk1 == cChaveOk2)
		cExibeAviso := STR0093	// Filial/Mes/Ano de Origem e Destino sao iguais
	EndIf

	RestArea( aArea )
	RestArea( aAreaSM0 )

Return ( cExibeAviso )

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Pesq           ³ Autor ³ Kelly                 ³ Data ³ 31.10.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa um registro                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFilOk1 = Filial Origem                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Pesq()
Local aKeys			:= GetKeys()
Local oDlg
Local oFont1, oFont2
//-- Variaveis dimensoes do objeto tela
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local bSet15 := {|| NIL}
Local bSet24 := {|| NIL}

Private oPesqFilial, oPesqChave, oChkFilial, oChkChave
Private cPesqFilial	:= CriaVar("RCC_FIL")
Private cPesqChave	:= CriaVar("RCC_CHAVE")

		//-- Monta as Dimensoes dos Objetos
		aAdvSize		:= MsAdvSize()
		aAdvSize[5]		:=	460 //horizontal
		aAdvSize[3]		:=	230 // LARGURA
		aAdvSize[4]		:=	50  // ALTURA
		aAdvSize[6]		:=  180 //Vertical
		aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
		aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
		aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

		DEFINE FONT oFont1  NAME "Arial" SIZE 0,-13
		DEFINE FONT oFont2  NAME "Arial" SIZE 0,-11

		DEFINE MSDIALOG oDlg FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE OemToAnsi(STR0065) OF GetWndDefault() STYLE DS_MODALFRAME PIXEL  //"Pesquisar Registro"
		                                                                      //030
			@aObjSize[1,1]+10, aObjSize[1,2]+10 SAY OemToAnsi(STR0037) SIZE 040,007 OF oDlg PIXEL FONT oFont1 //"Filial:"
			@aObjSize[1,1]+10, aObjSize[1,2]+50 MSGET oPesqFilial VAR cPesqFilial	SIZE 050,007	OF oDlg PIXEL FONT oFont2
			                                                                 //033
			@aObjSize[1,1]+25, aObjSize[1,2]+10 SAY OemToAnsi(STR0192) SIZE 043,007 OF oDlg PIXEL FONT oFont1	//"Ano/Mes	:"
			@aObjSize[1,1]+25, aObjSize[1,2]+50 MSGET oPesqChave  VAR cPesqChave SIZE 050,007	OF oDlg PIXEL FONT oFont2

			bSet15 := { || nOpcA := 1 , fFind(cPesqFilial,cPesqChave) ,  oDlg:End()}
			bSet24 := { || nOpcA := 2 , RestKeys(aKeys,.T.), oDlg:End() }

			oDlg:lEscClose := .F. //Nao permite sair ao se pressionar a tecla ESC.

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bSet15 , bSet24 ) CENTERED

	Return

Return

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fFind          ³ Autor ³ Kelly                 ³ Data ³ 31.10.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa um registro com a filial e a chave indicadas.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPFil = Filial Origem                                            ³±±
±±³          ³ cPChave = Mes/Ano Orige                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA320                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fFind(cPFil,cPChave)

Local nPosFil	:= IIf(GdFieldPos("RCC_FIL") > 0,GdFieldPos("RCC_FIL"), 1)
Local nPosAnoI	:= IIf(GdFieldPos("ANOMESI") > 0,GdFieldPos("ANOMESI"), 2)

	nP := ( Ascan( aCols, { |x| x[nPosFil]+ x[nPosAnoI] == cPFil + cPChave } ) )

	If nP = 0
	   nP := 1
	EndIf

	oGet:Goto( nP )
	oGet:oBrowse:Refresh(.T.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fExcluirOk2 ³ Autor: Kelly Soares        ³ Data ³ 30.11.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica integridade dos dados da Tabela com o Lancto Fixo.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fExcluirOk2()
Local lOk  := .T.

	lOk := !fTemLanctoFixo(cCodigo , Val(aColsBkp[Len(aColsBkp),If(lAnoMes,3,2)]) , 0 , "2")

Return(lOk)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fAtualizaBkp2  ³ Autor: Kelly Soares     ³ Data ³ 30.11.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza a array de bkp dp aCols.						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fAtualizaBkp2()
Local nX

	If nBkp < Len(aCols)
		aAdd(aColsBkp , Array(Len(aCols[n])))
		For nX := 1 to Len(aCols[n])
			aColsBkp[Len(aColsBkp),nX] := aCols[n,nX]
		Next nX
		nBkp ++
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Gpe320Aux| Autor ³Gustavo M.             ³ Data ³17/08/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Utilizada para identificar quando e selecionado a opcao de ³±±
±±³          ³ incluir.												      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Gpe320Alt                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function Gpe320Aux(cAlias,nReg,nOpcX)

	lIncluir := .T.

Return( Gpe320Alt(cAlias,nReg,nOpcX) )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GPE320Ger| Autor ³ Leandro Drumond       ³ Data ³12/09/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera fonte com as informacoes das tabelas.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function GPE320Ger()
Local aArea			:= GetArea()
Local aRCCMemo		:= {}				// Campos memos da tabela RCC
Local aIniHdrRCC						// Cabecalho da tabela RCC com os campos
Local aRCCVirtual						// Campos virtuais de RCC
Local aLinesProg 	:= {}				// Array com as linhas dos programas
Local aLinesFunc 	:= {}			 	// Array com as linhas das funcoes dos itens RCC
Local aStruTrb		:= {}				// Array para montagem da estrutura da tabela temporaria utilizada no markbrow
Local aBrowse		:= {} 				// Campos utilizados no markbrow
Local aTabMigr		:= {} 				// Tabelas utilizadas no fonte
Local bOk           := {|| nOpcao:=1,lRetorno:=.T.,oDlg:End() }         //botao de ok
Local bCancel       := {|| nOpcao:=0,oDlg:End() }
Local cArquivo 		:= ""			 	// Nome do arquivo a ser gerado
Local cPath 		:= ""				// Path a gravar o arquivo
Local cChaveFunc	:= ""				// chave para criacao de uma nova funcao
Local cNameFunc							// Mome da funcao
Local cProg								// String a ser enviado ao arquivo PRX
Local cMsg								// Mensagem de erro na geracao do arquivo PRX
Local cTexto							// Valor do campo do Header
Local cValueCampo						// Montagem da string a ser enviado ao array
Local cArqTrb							// Arquivo da tabela temporaria
Local cQuery							// Query para montagem da tabela temporario
Local cAliasTrb							// Alias da tabela temporaria
Local cTabMigr
Local lSetCentury	:= __SetCentury("on")
Local lRetorno
Local nFuncao		:= 0				// Codigo das funcoes
Local nLineMemo							// Numero de linhas existentes no campo memo
Local nPosMemo							// Posicao do campo memo virtual
Local nUsado							// Campos utilizados
Local nArq								// Situacao do arquivo
Local nX
Local nY
Local nOpcao
Local nPos

Private lInverte    := .F.                                                     //Variaveis para o MsSelect
Private cMarca      := GetMark()                                               //Variaveis para o MsSelect
Private oBrwTrb                                                                 //objeto do msselect
Private oDlg

	// Define campos do TRB
	aadd(aStruTrb,{"CODIGO"	,"C",04,0})
	aadd(aStruTrb,{"DESCR" 	,"C",30,0})
	aadd(aStruTrb,{"OK"    	,"C",02,0})

	// Define campos do MsSelect
	aadd(aBrowse,{"OK"    	,,""        })
	aadd(aBrowse,{"CODIGO"	,,PosAlias( "SX3" , "RCB_CODIGO"	, "" , "X3Titulo()" , 2 , .F. ) })
	aadd(aBrowse,{"DESCR"	,,PosAlias( "SX3" , "RCB_DESC"		, "" , "X3Titulo()" , 2 , .F. ) })

	If Select("TRB") > 0
		oTmpTable:Delete()
		oTmpTable := Nil
	EndIf

	oTmpTable := FWTemporaryTable():New("TRB")
	oTmpTable:SetFields( aStruTrb )
	aOrdem := {"CODIGO", "DESCR"}
	oTmpTable:AddIndex("IN1", aOrdem)
	oTmpTable:Create()

	//Aqui voce monta sua query que serve para gravar os dados no arquivo temporario...
	cQuery := "SELECT DISTINCT(RCC_CODIGO), RCB_DESC FROM " + InitSqlName( "RCC" ) + " RCC "
	cQuery += "  LEFT JOIN " + InitSqlName( "RCB" ) + " RCB "
	cQuery += "    ON RCC_CODIGO = RCB_CODIGO "
	cQuery += " WHERE RCC.D_E_L_E_T_ = ' ' AND RCB.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY RCC_CODIGO "

	cAliasTrb := GetNextAlias()

	cQuery := ChangeQuery(cQuery)

	// ABRE A EXECUCAO DA QUERY ATRIBUIDA AO RCC
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTRB, .F., .T.)

	While (cAliasTrb)->(!Eof())

		If SubStr((cAliasTrb)->RCC_CODIGO,1,1) <> 'U'
			RecLock("TRB",.T.)
			TRB->OK     := cMarca
		 	TRB->CODIGO := (cAliasTrb)->RCC_CODIGO
		 	TRB->DESCR 	:= (cAliasTrb)->RCB_DESC
		 	MsUnlock()
		 EndIf

	 	(cAliasTrb)->(DbSkip())
	Enddo

	(cAliasTrb)->(DbCloseArea())

	Define MSDialog oDlg Title OemToAnsi(STR0096) From 000,000 To 400, 509 Pixel //Geração de fonte - Tabela Padrão

	oBrwTrb := MsSelect():New("TRB","OK","",aBrowse,@lInverte,@cMarca,{025,005,185,250})

	Eval(oBrwTrb:oBrowse:bGoTop)
	oBrwTrb:oBrowse:Refresh()

	Activate MsDialog oDlg On Init (EnchoiceBar(oDlg,bOk,bCancel,,)) CENTERED VALID lRetorno

	TRB->(DbGotop())

	If nOpcao == 1
		Do While TRB->(!Eof())
	 		If !Empty(TRB->OK)//se usuario marcou o registro
				If Empty(aTabMigr)
		 			cTabMigr := "'"+TRB->CODIGO+"'"
		 		Else
		 			cTabMigr += ",'"+TRB->CODIGO+"'"
		 		EndIf
	 			aAdd(aTabMigr,{TRB->CODIGO})

	 		EndIf
	 		TRB->(DbSkip())
	 	EndDo
	EndIf

	TRB->(DbCloseArea())

	If !(Len(aTabMigr) > 0)
		Return Nil
	EndIf

	cArquivo 	:= ( "GPCRG" + cPaisLoc + ".PRX" )

	aIniHdrRCC	:= RCC->( GdMontaHeader( @nUsado, @aRCCVirtual, NIL, NIL, NIL, .T. ) )

	Begin Sequence
		// mostra drives   mostra hard disk retorna diretorio
		cPath := cGetFile("",OemToAnsi(STR0097),0,,.F.,GETF_LOCALHARD + GETF_RETDIRECTORY,,) //"Selecione o Diretorio"

		If Empty(cPath)
			Break
		EndIf

		cArquivo := cPath + cArquivo

		If File(cArquivo)
			If !(MsgYesNo( OemToAnsi( STR0098 ),;	// "O Arquivo ja Existe !! Deseja Sobrescrer?"
	 		 			   OemToAnsi( STR0083 ) ;	//"Aten‡„o"
						))
				Break
			EndIf
		EndIf

		nArq := MSFCREATE(cArquivo, 0)

		If Ferror() # 0 .And. nArq = -1
			cMsg := STR0099 + STR(Ferror(),3) //-- "Erro de Gravacao do Arquivo - Codigo DOS: "
			MsgInfo( cMsg, STR0083 ) // Atencao
			Return(.F.)
		EndIf

		// Cabecalho da funcao
		aAdd(aLinesProg, '#INCLUDE "PROTHEUS.CH"' + CRLF + CRLF)
		aAdd(aLinesProg, "/*/" + CRLF)
		aAdd(aLinesProg, "ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿" + CRLF)
		aAdd(aLinesProg, "³Fun‡…o    ³GpCrg" + cPaisLoc + "      " + "³Autor³ Gerado pelo sistema ³ Data ³" + Substr(DtoS(date()),7,2)+"/"+Substr(DtoS(date()),5,2)+"/"+Substr(DtoS(date()),1,4) + "³" + CRLF)
		aAdd(aLinesProg, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
		aAdd(aLinesProg, "³Descri‡…o ³Definicao das Tabelas                                       ³" + CRLF)
		aAdd(aLinesProg, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
		aAdd(aLinesProg, "³Sintaxe   ³                                                            ³" + CRLF)
		aAdd(aLinesProg, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
		aAdd(aLinesProg, "³Parametros³<Vide Parametros Formais>                                   ³" + CRLF)
		aAdd(aLinesProg, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
		aAdd(aLinesProg, "³ Uso      ³Generico                                                    ³" + CRLF)
		aAdd(aLinesProg, "ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/" + CRLF)
		aAdd(aLinesProg, "Function GpCrg" + cPaisLoc + "()" + CRLF + CRLF)
		aAdd(aLinesProg, "Local aRCCHeader	:= {}" + CRLF + CRLF)
		aAdd(aLinesProg, "Local aTabMigr	:= {"+cTabMigr+"}" + CRLF + CRLF)
		aAdd(aLinesProg, "Local bExecFunc" + CRLF + CRLF)
		aAdd(aLinesProg, 'Local cNameFunc	:= ""' + CRLF)
		aAdd(aLinesProg, "Local lRet	  	:= .T." + CRLF)
		aAdd(aLinesProg, "Local nX 		:= 0" + CRLF)
		aAdd(aLinesProg, "Local cFil  	:= Alltrim(Str(FWGETTAMFILIAL)) " + CRLF + CRLF)

		aAdd(aLinesProg, "/*/" + CRLF)
		aAdd(aLinesProg, "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿" + CRLF)
		aAdd(aLinesProg, "³ Cabecalho de RCC                                             ³" + CRLF)
		aAdd(aLinesProg, "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/" + CRLF)

		For nX := 1 To Len(aIniHdrRCC)
			cProg := ""
			For nY := 1 To Len(aIniHdrRCC[nX])
				cTexto := If(ValType(aIniHdrRCC[nX,nY]) == "N", AllTrim(Str(aIniHdrRCC[nX,nY])),;
							   	If(ValType(aIniHdrRCC[nX,nY])=="L", Transform(aIniHdrRCC[nX, nY],"@!"),;
							   	   aIniHdrRCC[nX, nY]))
				IF "_FILIAL" $ aIniHdrRCC[nX][2] .AND. nY == __AHEADER_WIDTH__    // Tratamento para Gestão Corporativa.
					cTexto := "cFil"
					cProg  += cTexto
				ELSE
					cTexto := StrTran(cTexto, "'", '"')
					cProg  += "'" + cTexto + "'"
				Endif
				If nY < Len(aIniHdrRCC[nX])
					cProg += ","
				EndIf
			Next nY

			If !Empty(cProg)
				aAdd(aLinesProg, "aAdd(aRCCHeader, " + '{ ' + cProg + ' })' + CRLF)
			EndIf
		Next nX

		aAdd(aLinesProg, CRLF)
		aAdd(aLinesProg, "/*/" + CRLF)
		aAdd(aLinesProg, "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿" + CRLF)
		aAdd(aLinesProg, "³ Validar a Estrutura das Tabela RCC                            ³" + CRLF)
		aAdd(aLinesProg, "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/" + CRLF)
		aAdd(aLinesProg, 'lRet := fNewOldSx3(aRCCHeader, NIL, "RCC", NIL)' + CRLF + CRLF)

		aAdd(aLinesProg, 'If lRet' + CRLF)

		// Cadastro das Tabelas
		DbSelectArea("RCC")
		RCC->( dbSetOrder( 1 ) ) // "RCC_FILIAL+RCC_CODIGO+RCC_FIL+RCC_CHAVE+RCC_SEQUEN"
		RCC->(dbGoTop())

		While RCC->( !Eof() )

			nPos := aScan(aTabMigr,{ |x| x[1] == Trim(RCC->(RCC_CODIGO)) } )

			If Substr( RCC->( RCC_CODIGO ), 1, 1) == "U" .or. nPos == 0
				RCC->( DbSkip() )
				Loop
			EndIf

			If cChaveFunc != RCC->( RCC_FILIAL + RCC_CODIGO )

				// Gerar as chamadas para as funcoes //
				nFuncao := Val(SubStr(aTabMigr[nPos,01],2))
				cNameFunc := 'Tab' + StrZero( nFuncao,3 )

				aAdd(aLinesFunc, CRLF + CRLF)
				aAdd(aLinesFunc, "/*/" + CRLF)
				aAdd(aLinesFunc, "ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿" + CRLF)
				aAdd(aLinesFunc, "³Fun‡…o    ³"+cNameFunc + "      ³Autor³ Gerado pelo sistema ³ Data ³" + Substr(DtoS(date()),7,2)+"/"+Substr(DtoS(date()),5,2)+"/"+Substr(DtoS(date()),1,4) + "³" + CRLF)
				aAdd(aLinesFunc, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
				aAdd(aLinesFunc, "³Descri‡…o ³Definicao de Tabelas da tabela RCC                        ³" + CRLF)
				aAdd(aLinesFunc, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
				aAdd(aLinesFunc, "³Sintaxe   ³                                                          ³" + CRLF)
				aAdd(aLinesFunc, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
				aAdd(aLinesFunc, "³Parametros³<Vide Parametros Formais>                                 ³" + CRLF)
				aAdd(aLinesFunc, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
				aAdd(aLinesFunc, "³ Uso      ³Generico                                                  ³" + CRLF)
				aAdd(aLinesFunc, "ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/" + CRLF)

				cNameFunc += '( aRCCHeader )'
				aAdd(aLinesFunc, "Static Function " + cNameFunc + CRLF + CRLF)

				aAdd(aLinesFunc, "Local aRCCItens	:= {}" + CRLF + CRLF)
				aAdd(aLinesFunc, "DEFAULT aRCCHeader	:= {}" + CRLF + CRLF)

			EndIF

			cProg := "aAdd( aRCCItens, { "

			For nX := 1 To Len(aIniHdrRCC)
				cValueCampo := ""

				// Campo memo normal //
				If aIniHdrRCC[nX,8] == "M" .and. (aScan(aRCCVirtual, aIniHdrRCC[nX,2]) == 0)
					nLineMemo := MlCount(aIniHdrRCC[nX,2], 80)

					For nY := 1 To nLineMemo
						cValueCampo += AllTrim(MemoLine(aIniHdrRCC[nX,2], 80, nY))
						If nY < nLineMemo
							cValueCampo += ' '
						EndIf
					Next nY

				// Campo memo gravado em SYP - Virtual //
				ElseIf aIniHdrRCC[nX,8] == "M" .and. (aScan(aRCCVirtual, aIniHdrRCC[nX,2]) > 0)
					If ((nPosMemo := Ascan(aRCCMemo, { |x|  Upper(x[2]) == aIniHdrRCC[nX,2] })) > 0)
						cValueCampo += MSMM(&(RCC->(aRCCMemo[nPosMemo,1])),80)
						cValueCampo := StrTran(cValueCampo, CRLF, "\13\10")
					EndIf

				ElseIf ( aScan(aRCCVirtual, aIniHdrRCC[nX,2]) > 0 )
					Loop
				ElseIf aIniHdrRCC[nX,8] == "N"
					cValueCampo += AllTrim(Str(&(aIniHdrRCC[nX,2])))
				ElseIf aIniHdrRCC[nX,8] == "D"
					cValueCampo += 'Ctod("' + DtoC(&(aIniHdrRCC[nX,2])) + '")'
				ElseIf aIniHdrRCC[nX,8] == "L"
					If &(aIniHdrRCC[nX,2])
						cValueCampo += ".T."
					Else
						cValueCampo += ".F."
					EndIf
				ElseIf "FILIAL" $ aIniHdrRCC[nX,2]
					cValueCampo += ""
				Else
					cValueCampo += AllTrim(&(aIniHdrRCC[nX,2]))
				EndIf
				cValueCampo := StrTran(cValueCampo, "'", '"')

				If (aIniHdrRCC[nX,8] != "N") .and. (aIniHdrRCC[nX,8] != "D") .and. (aIniHdrRCC[nX,8] != "L")
					cValueCampo := "'" + cValueCampo
					cValueCampo += "'"
				EndIF

				cProg += cValueCampo
				If nX < Len(aIniHdrRCC)
					cProg += ","
				EndIf
			Next nX
			cProg += "} )"
			aAdd(aLinesFunc, cProg + CRLF)

			cChaveFunc := RCC->( RCC_FILIAL + RCC_CODIGO)

			RCC->(dbSkip())

			If cChaveFunc != RCC->( RCC_FILIAL + RCC_CODIGO ) .Or. RCC->( Eof() ) .Or. ( Substr(RCC->RCC_CODIGO,1,1) == "U" )

				aAdd(aLinesFunc, CRLF)
				aAdd(aLinesFunc, "fGravaCrg( aRCCHeader, aRCCItens )" + CRLF )

				aAdd(aLinesFunc, 'Return( NIL )')

			EndIf

			If ( Substr(RCC->RCC_CODIGO,1,1) == "U" )
				Exit
			EndIf
		EndDo

		aAdd(aLinesProg, "	For nX := 1 To "  + AllTrim(Str(Len(aTabMigr))) + CRLF)
		aAdd(aLinesProg, '		cNameFunc := "{ || Tab" + SubStr(aTabMigr[nX],2) + "( aRCCHeader )" + " }"' + CRLF)
		aAdd(aLinesProg, "		bExecFunc := &cNameFunc" + CRLF)
		aAdd(aLinesProg, "		Eval(bExecFunc)" + CRLF)
		aAdd(aLinesProg, "	Next nX" + CRLF)
		aAdd(aLinesProg, 'EndIf' + CRLF + CRLF )
		aAdd(aLinesProg, 'Return( NIL )' )

		// Transferir as linhas para dentro do programa
	    For nX := 1 To Len(aLinesProg)
		    Fwrite( nArq, aLinesProg[nX] )
		Next nX

	    For nX := 1 To Len(aLinesFunc)
		    Fwrite( nArq, aLinesFunc[nX] )
		Next nX

		FClose(nArq)
		MsgInfo( STR0100 + cArquivo + CRLF + STR0101 ) // "O Programa " #### "para Cadastro de informações das Tabelas Padroes foi Gerado com Sucesso"
	End Sequence

	If !( lSetCentury )
		__SetCentury("off")
	EndIf

	RestArea( aArea )

Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GPE320Imp  | Autor ³  Leandro Drumond    ³ Data ³14/09/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega dados de arquivo CSV para tabela.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function Gpe320Imp()
Local aArea			:= GetArea()
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aTabRCB		:= {}
Local bSet15		:= {|| ImportCsv(cGetImp),oDlg:End()}
Local bSet24   		:= {|| oDlg:End()}
Local oScroll
Local oDlg
Local oSay1
Local oSay2

Private cComboBox
Private oComboBox
Private cGetImp

//Bloqueio de utilização de tabelas exclusivas da integração GUPY
If RCB->RCB_CODIGO $ ("S131|S132|S133")
	If ( Findfunction( "RhGUPYExt" ) )
		If ( ! RhGUPYExt( SM0->M0_CGC ) )
			Return (.F.)
		EndIf
	EndIf
EndIf

If RCB->RCB_CODIGO == "S035"  .And. FindFunction("FGETINSS")
    bSet15		:= {|| Iif (cComboBox == STR0152,  (cGetImp := cGetFile(  STR0107 + " (*.CSV) |*.csv|" , STR0108 ),  ImportCsv(cGetImp),oDlg:End()  ) ,  (  FWMsgRun(,{|| ImpGpsFIN()  },STR0153, STR0083 )   , oDlg:End())  )       }

	aAdd(aTabRCB , STR0151)
	aAdd(aTabRCB , STR0152)

	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

	DEFINE MSDIALOG oDlg TITLE STR0149 FROM 0,0 TO aAdvSize[1]+150,aAdvSize[1]+570 COLORS 0, 16777215 PIXEL

	  	@ aObjSize[1][1] -10 , 001 SCROLLBOX oScroll HORIZONTAL VERTICAL SIZE aObjSize[1][1]+380, aObjSize[1][1] +400 PIXEL OF oDlg

		@ aObjSize[1][1] -7, aObjSize[1][1]-10 SAY oSay1 PROMPT STR0150 SIZE aObjSize[1][1] + 20, aObjSize[1][1] - 5 OF oScroll COLORS 0, 16777215 PIXEL
	    @ aObjSize[1][1] -10, aObjSize[1][1] + 45 MSCOMBOBOX oComboBox VAR cComboBox ITEMS aTabRCB SIZE aObjSize[1][1] + 90, aObjSize[1][1] - 2 OF oScroll COLORS 0, 16777215 PIXEL

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 ) CENTERED
Else

	DbSelectArea("RCB")
	DbSetOrder(1)
	DbGoTop()

	While RCB->( !EOF() )
		aAdd(aTabRCB , RCB->RCB_CODIGO + " - " + RCB->RCB_DESC )
		RCB->(DbSkip())
	EndDo

	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

	DEFINE MSDIALOG oDlg TITLE STR0104 FROM 0,0 TO aAdvSize[1]+300,aAdvSize[1]+700 COLORS 0, 16777215 PIXEL  //"Importação de Tabelas"

		@ aObjSize[1][1] + 003 , 001 SCROLLBOX oScroll HORIZONTAL VERTICAL SIZE aObjSize[1][1]+380, aObjSize[1][1] +400 PIXEL OF oDlg

		@ aObjSize[1][1] + 3, aObjSize[1][1] SAY oSay1 PROMPT STR0105 SIZE aObjSize[1][1] + 20, aObjSize[1][1] - 5 OF oScroll COLORS 0, 16777215 PIXEL  //"Tabela"
	    @ aObjSize[1][1] + 2, aObjSize[1][1] + 45 MSCOMBOBOX oComboBox VAR cComboBox ITEMS aTabRCB SIZE aObjSize[1][1] + 150, aObjSize[1][1] - 2 OF oScroll COLORS 0, 16777215 PIXEL

	    @ aObjSize[1][1] + 33, aObjSize[1][1]	SAY oSay2 PROMPT STR0106   	SIZE aObjSize[1][1] , aObjSize[1][1]+100 OF oScroll COLORS 0, 16777215 PIXEL //"Origem do Arquivo: "
	    @ aObjSize[1][1] + 31, aObjSize[1][1] + 45 MSGET oGetImp VAR cGetImp  When GetFile() 	SIZE aObjSize[1][1] + 73, aObjSize[1][1] - 2 OF oScroll COLORS 0, 16777215 PIXEL

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 ) CENTERED

	RestArea(aArea)
EndIf

Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GetFile    | Autor ³  Leandro Drumond    ³ Data ³14/09/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao de escolha do diretorio da importacao.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function GetFile()
Local cPathAux	:= ""

If !Empty(cGetimp)
	Return (.F.)
EndIf

cPathAux:=cGetFile(  STR0107 + " (*.CSV) |*.csv|" , STR0108 )
cGetImp := cPathAux
SetFocus(oComboBox:hwnd)

Return ( .T. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ImportCsv  | Autor ³  Leandro Drumond    ³ Data ³14/09/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega dados de arquivo CSV para tabela.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function ImportCsv(cArquivo)
Local aDados  := {}
Local aLog	  := {}
Local nHandle := 0
Local cLine   := ""
Local nlinha  := 1
Local nRet	  := 0

	DEFAULT cArquivo := ""

	If File(cArquivo)

		nHandle := FT_FUse(cArquivo)

		// Se houver erro de abertura abandona processamento
		If nHandle = -1
			Return
		EndIf

		FT_FGoTop()

		While !FT_FEOF()

			cLine  := FT_FReadLn() // Retorna a linha corrente

		    If Empty( Strtran( cLine , ";" ) )
		    	EXIT
		    EndIf

		    aAdd( aDados , ArqToArray(cLine,.T.,"%") )

			nlinha++
			FT_FSKIP()

		EndDo

		// Gravacao das tabelas auxiliares.
		If Len(aDados) > 0
			nRet := GravaRCC( If(cComboBox == STR0152,"S035", SubStr(cComboBox,1,4)) , aDados, .T. )

			If nRet == 0
				aAdd( aLog , { STR0105 + SPACE(1) + cComboBox + SPACE(1) + STR0110} )    //Tabela #### ja foi Importada anteriormente.
			ElseIf nRet == 1
				aAdd( aLog , { STR0105 + SPACE(1) + cComboBox + SPACE(1) + STR0109} )    //Tabela #### importada com êxito.
			Else
				aAdd( aLog , { STR0111 + SPACE(1) + cComboBox + SPACE(1) + STR0112} )    //Estrutura da tabela #### não corresponde ao arquivo importado. Verifique se o layout esta correto.
			EndIf
		Else
			aAdd( aLog , { STR0113 + SPACE(1) + cArquivo + SPACE(1) + STR0114} )    //Arquivo #### sem dados para importação.
		EndIf

		// Fecha o Arquivo
		FT_FUSE()

	EndIf

	fMakeLog(aLog,{STR0104},"GPEA320")
	aLog := {}

Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ArqToArray | Autor ³  Leandro Drumond    ³ Data ³14/09/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que converte string com ponto e virgula para array. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function ArqToArray(cVar,lRetira,cCont)
Local aDados := {}
Local cDados := cVar
Local cRes   := ""
Local nPos   := 0

	While !Empty(cDados)

		nPos := AT(";",cDados)

		If nPos == 0
			nPos := Len(cDados)+1
		EndIf

		If lRetira
			cRes := StrTran( SubStr(cDados,1,nPos-1) , cCont , "" )
		Else
			cRes := SubStr(cDados,1,nPos-1)
		EndIf

		aAdd( aDados , cRes )
		cDados := SubStr( cDados , nPos + 1 , Len(cDados) )

	EndDo

Return( aDados )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GravaRCC | Autor ³  Leandro Drumond      ³ Data ³14/09/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gravacao de dados do arquivo csv na tabela RCC.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function GravaRCC( cTabela , aDados, lImpCsv )
Local aEstrut 	  := {}
Local cAnomes 	  := AnoMes(dDatabase-30)
Local n       	  := 0
Local nY      	  := 0
Local nX      	  := 0
Local cCont   	  := ""
Local cSeq    	  := "001"
Local cQuery  	  := ""
Local cAliasTRB   := ""
Local aRecnos 	  := {}
Local nRet    	  := 0
Local lExiste 	  := .F.
Local aGrpCcust   := {}
Local nIndAgrp    := 0
Local nVlrReceita := 0
Local nVlrDeducao := 0
Local nPerc       := 0
Local cVrbRurPF   := ""
Local cVrbRurPJ   := ""
Local cVrbInssNF  := ""

cQuery := "SELECT RCB_CAMPOS, RCB_TIPO, RCB_TAMAN, RCB_DECIMA, 	RCB_PICTUR FROM " + RetSqlName("RCB")
cQuery += " WHERE RCB_CODIGO = '" + cTabela + "' AND RCB_FILIAL = '" + xFilial("RCC") + "' AND D_E_L_E_T_ = ' ' "

cAliasTRB := GetNextAlias()

cQuery := ChangeQuery(cQuery)

// ABRE A EXECUCAO DA QUERY ATRIBUIDA AO RCC
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTRB, .F., .T.)

While (cAliasTRB)->(!Eof())
    aAdd( aEstrut , { (cAliasTRB)->RCB_CAMPOS , (cAliasTRB)->RCB_TIPO , (cAliasTRB)->RCB_TAMAN , (cAliasTRB)->RCB_DECIMA , (cAliasTRB)->RCB_PICTUR } )

 	(cAliasTRB)->(DbSkip())
Enddo

(cAliasTRB)->(DbCloseArea())

If lImpCsv
	// Estrutura de arquivos incorreta
	For nX := 1 to Len(aDados)
		If !(Len(aEstrut) == Len(aDados[nX]))
			nRet := 2
			Return nRet
		EndIf
	Next nX

	// Atualiza os registro sem mes e ano para o mes anterior da importação
	DbSelectArea("RCC")
	RCC->( DbSetOrder(1) )
	RCC->( DbSeek( xFilial("RCC") + cTabela  ) )

	While RCC->( !EOF() ) .AND. RCC->RCC_CODIGO == cTabela

		If Empty(RCC->RCC_CHAVE)
			aAdd( aRecnos , RCC->( RECNO() ) )
		ElseIf RCC->RCC_CHAVE == cAnomes
			lExiste := .T.
			EXIT
		EndIf

		RCC->( DbSkip() )
	EndDo

	If !lExiste

		For nY:=1 To Len(aRecnos)
			RCC->( DbGoTo(aRecnos[nY]) )
			RecLock("RCC",.F.)
			RCC->RCC_CHAVE := cAnomes
			RCC->(Msunlock())
		Next nY

		// Gravacao dos dados do arquivo csv.
		For n := 1 to Len(aDados)

			cCont    := ""

			For nX := 1 to Len(aDados[n])
				If aEstrut[nX][2] == "N"
					If nX <= Len( aEstrut )
						cCont += Space( aEstrut[nX][3] - Len(StrTran( StrTran( aDados[n][nX] , ".", "") , ",",".")) ) +;
								 StrTran( StrTran( aDados[n][nX] , ".", "") , ",",".")
					EndIf
				Else
					cCont += aDados[n][nX] + Space( Max((aEstrut[nX][3] - Len(aDados[n][nX])),0) )
				EndIf
			Next nX

			RecLock("RCC",.T.)
			RCC->RCC_FILIAL := xFilial("RCC")
			RCC->RCC_CODIGO := cTabela
			RCC->RCC_SEQUEN := cSeq
			RCC->RCC_CONTEU := cCont
			RCC->( Msunlock() )

			cSeq  := Soma1(cSeq)
			cCont := ""

			nRet := 1

		Next n

	EndIf
Else


	aDados := FGetINSS ( cFilCarga, substr(cNovoMesAnoOrig,1,2), substr(cNovoMesAnoOrig,3,4))

	If Len(aDados) > 0

		cVrbInssNF  := FGetCodFol('0314',, xFilial("SRV"))
		cVrbRurPF   := FGetCodFol('0315',, xFilial("SRV"))
    	cVrbRurPJ   := FGetCodFol('0316',, xFilial("SRV"))

		If MsgYesNo(oEmToAnsi(STR0171))
			LimparRCC()
		EndIf

		cSeq := ProxSeq ()

		For nX := 1 to Len(aDados)//financeiro não retorna dados ordenados por c.custo
			nIndAgrp  := aScan( aGrpCcust , { |x| x[1] == aDados[nX][1] .And. x[2] == aDados[nX][10] .And. x[5] == aDados[nX][11] .And. x[6] == aDados[nX][12]     } )

			If nIndAgrp == 0
				Aadd ( aGrpCcust, { aDados[nX][1], aDados[nX][10], aDados[nX][7], aDados[nX][8], aDados[nX][11], aDados[nX][12] } )
			Else
				aGrpCcust[nIndAgrp][3] += aDados[nX][7]
				aGrpCcust[nIndAgrp][4] += aDados[nX][8]
			EndIf
		Next

		For nX := 1 to Len(aGrpCcust)

			If aGrpCcust[nX][5] == 'F' .AND. aGrpCcust[nX][6] == 'L' //PRODUTOR RURAL PESSOA FISICA
				cCodVerba := cVrbRurPF
			ElseIf aGrpCcust[nX][5] == 'J' .AND. aGrpCcust[nX][6] == 'L' //PRODUTOR RURAL PESSOA JURIDICA
				cCodVerba := cVrbRurPJ
			Else
				cCodVerba := cVrbInssNF
			EndIf



			If aGrpCcust[nX][4] != 0

				RecLock("RCC",.T.)
				RCC->RCC_FILIAL := FwxFilial('RCC')
				RCC->RCC_FIL    := aGrpCcust[nX][1]
				RCC->RCC_CHAVE  := substr(cNovoMesAnoOrig,3,4) + substr(cNovoMesAnoOrig,1,2)
				RCC->RCC_CODIGO := 'S035'
				RCC->RCC_SEQUEN := cSeq

				cCont := AllTrim(aGrpCcust[nX][2]) + Space( Max((aEstrut[1][3] - Len(AllTrim(  aGrpCcust[nX][2] ) )    )     ,0) )
				cCont += cCodVerba      + Space( Max((aEstrut[2][3] - Len(AllTrim(  cCodVerba      ) )    )         ,0) )

				cFrmt := Transform(aGrpCcust[nX][3],"@E 999,999,999.99")
				cFrmt := StrTran  (cFrmt,".","")
				cFrmt := StrTran  (cFrmt,",",".")

				cCont += Space( aEstrut[3][3] - Len( AllTrim(cFrmt)  )  ) + AllTrim(cFrmt) //Base

				nVlrDeducao := aGrpCcust[nX][4]
				nPerc       := (nVlrDeducao * 100)/aGrpCcust[nX][3]

				cFrmt := Transform(nPerc,"@E 9,999.99")
				cFrmt := StrTran  (cFrmt,".","")
				cFrmt := StrTran  (cFrmt,",",".")

				cCont += Space( aEstrut[4][3] - Len( AllTrim(cFrmt)  ) ) + AllTrim(cFrmt)

				cFrmt := Transform(aGrpCcust[nX][4],"@E 999,999,999.99")
				cFrmt := StrTran  (cFrmt,".","")
				cFrmt := StrTran  (cFrmt,",",".")

				cCont += Space( aEstrut[5][3] - Len( AllTrim( cFrmt )  ) ) + AllTrim(cFrmt)

				cCont += "D"     + Space( Max((aEstrut[ 6][3] - Len(AllTrim(  "D"  ) )    )                         ,0) )
				cCont += AllTrim(cTxtObs)      + Space( Max((aEstrut[ 7][3] - Len(AllTrim(  cTxtObs  ) )    )       ,0) )
				cCont += cCombTp + Space( Max((aEstrut[ 8][3] - Len(AllTrim(  cCombTp ) )    )                      ,0) )
				cCont += substr(cNovoMesAnoOrig,1,2) + Space( Max((aEstrut[ 9][3] - Len(AllTrim(  substr(cNovoMesAnoOrig,1,2) ) )    )    ,0) )
				cCont += substr(cNovoMesAnoOrig,3,4) + Space( Max((aEstrut[10][3] - Len(AllTrim(  substr(cNovoMesAnoOrig,3,4) ) )    )    ,0) )
				cCont += substr(cNovoMesAnoOrig,1,2) + Space( Max((aEstrut[11][3] - Len(AllTrim(  substr(cNovoMesAnoOrig,1,2) ) )    )    ,0) )
				cCont += substr(cNovoMesAnoOrig,3,4) + Space( Max((aEstrut[12][3] - Len(AllTrim(  substr(cNovoMesAnoOrig,3,4) ) )    )    ,0) )

				RCC->RCC_CONTEU := cCont
				RCC->( Msunlock() )

				cSeq  := Soma1(cSeq)
			EndIf

		Next

	EndIf

EndIf

Return( nRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Menudef  | Autor ³Luiz Gustavo           ³ Data ³07/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Isola opcoes de menu para que as opcoes da rotina possam   ³±±
±±³          ³ ser lidas pelas bibliotecas Framework da Versao 9.12 .     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function MenuDef()

	Local aRotina := {}
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

		aAdd( aRotina , { STR0002   , 'PesqBrw'    , 0 , 1})   		// 'Pesquisar'
		aAdd( aRotina , { STR0003   , 'Gpe320Alt'  , 0 , 2})  			// 'Visualizar'
		aAdd( aRotina , { STR0004   , 'Gpe320Aux'  , 0 , 4, , , .T.}) // 'Incluir'
		aAdd( aRotina , { STR0005   , 'Gpe320Alt'  , 0 , 4})   		// 'Alterar'
		aAdd( aRotina , { STR0006   , 'Gpe320Exc'  , 0 , 5})  	    	// 'Excluir'
		aAdd( aRotina , { STR0007   , 'Gpe320Leg'  , 0 , 6, ,.F.})		// 'Legenda'

Return aRotina

/*/{Protheus.doc} fDtIR34
Verifica data da tabela S002: obrigatoriedade de 3 ou mais faixas de imposto de renda entrou em vigor no ano calendário de 2009.
@author Victor Andrade
@since 28/07/2016
/*/
Static Function fDtIR34(aLine)

	Local lRet := .T.

	If cCodigo == "S002" .and. aLine[4] > "200812"
		lRet := .F.
	EndIf

Return (lRet)

/*/{Protheus.doc} fVldS043
Validação campo Cod. Homolognet: o sistema deve permitir deixar em branco o campo quando o tipo de aviso for A ou B,
pois de acordo com o texto da reforma trabalhista a informação deve ser apresentada em branco no campo 27 do TRCT
@author flavio.scorrea
@since 20/12/2017
/*/
Function fVldS043()
	Local lRet 		:= .T.
	Local nPos		:= 0
	Local cTipoA	:= ""

	If (nPos := GdFieldPos("AvisoPrev", aHeader)) > 0
		cTipoA := aCols[n, nPos]
	EndIf

	lRet := cTipoA $ "A|B"

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ImpGpsFIN | Autor ³  Oswaldo L           ³ Data ³14/09/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gravacao de dados INNS a partir do SIGAFIN   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static function ImpGpsFIN ()
Local oDlg
Local oScroll
Local oCombRecDed
Local oCombTp
Local aDados        	:= {}
Local aAdvSize			:= {}
Local aInfoAdvSize		:= {}
Local aObjSize			:= {}
Local aObjCoords		:= {}
Local aTabRCB			:= {}
Local lOk           	:= .F.
Local aTpContr          := { STR0160, STR0161}
Local bSet15		    := {||  lOk := .T., oDlg:End() }
Local bSet24   		    := {|| lOk := .F., oDlg:End()}
Private cCodVerba       := space(TamSx3("RV_COD")[1])
Private cTxtObs         := space(30)
Private cNovoMesAnoOrig	:= CriaVar("RCC_CHAVE")
Private cFilCarga       := CriaVar("RCC_FIL")
Private cCombRecDed     := " "
Private cCombTp         := " "
Private oNovoMesAnoOrig
Private oCodVerba
Private oFilCarga
Private oTxtObs

aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

While .T.
	DEFINE MSDIALOG oDlg TITLE STR0147 FROM 0,0 TO aAdvSize[1]+250,aAdvSize[1]+570 COLORS 0, 16777215 PIXEL

		@aObjSize[1][1] - 10, 001 SCROLLBOX oScroll HORIZONTAL VERTICAL SIZE aObjSize[1][1]+380, aObjSize[1][1] +400 PIXEL OF oDlg
		@aObjSize[1][1] -  7, aObjSize[1][1]       SAY   STR0038  SIZE aObjSize[1][1] + 20, aObjSize[1][1] - 5	           OF oScroll COLORS 0, 16777215 PIXEL
		@aObjSize[1][1] - 10, aObjSize[1][1] + 45  MSGET oNovoMesAnoOrig VAR cNovoMesAnoOrig	                           OF oScroll COLORS 0, 16777215 PIXEL
		@aObjSize[1][1] +  5, aObjSize[1][1]       SAY  STR0163   SIZE aObjSize[1][1] + 20, aObjSize[1][1] - 5	           OF oScroll COLORS 0, 16777215 PIXEL
		@aObjSize[1][1] +  5, aObjSize[1][1] + 45  MSCOMBOBOX oCombTp VAR cCombTp ITEMS aTpContr SIZE 70,8                 OF oScroll COLORS 0, 16777215 PIXEL
		@aObjSize[1][1] + 21, aObjSize[1][1]       SAY  STR0168   SIZE aObjSize[1][1] + 20, aObjSize[1][1] - 5	           OF oScroll COLORS 0, 16777215 PIXEL
		@aObjSize[1][1] + 21, aObjSize[1][1] + 45  MSGET oFilCarga VAR cFilCarga F3 "XM0"	                               OF oScroll COLORS 0, 16777215 PIXEL  HASBUTTON
		@aObjSize[1][1] + 35, aObjSize[1][1]       SAY  STR0169    SIZE aObjSize[1][1] + 20, aObjSize[1][1] - 5	           OF oScroll COLORS 0, 16777215 PIXEL
		@aObjSize[1][1] + 35, aObjSize[1][1] + 45  MSGET oTxtObs   VAR cTxtObs  	                                       OF oScroll COLORS 0, 16777215 PIXEL

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 ) CENTERED

	If !lOk
		Exit
	Else
		If Empty(cNovoMesAnoOrig) .or. Len(cNovoMesAnoOrig) <> 6 .or. Val(cNovoMesAnoOrig) == 0
			MsgInfo(STR0148)
			lOk := .F.
		Else
			If Val(substr(cNovoMesAnoOrig,1,2)) < 1 .or. Val(substr(cNovoMesAnoOrig,1,2)) > 12 .or. Val(substr(cNovoMesAnoOrig,3,4)) == 0
				MsgInfo(STR0148)
				lOk := .F.
			EndIf

			If lOk .And. cCombTp != "1"  .And. cCombTp != "2"
				MsgInfo(STR0166)
				lOk := .F.
			EndIf

			If lOk .And. Empty(cFilCarga)
				MsgInfo(STR0170)
				lOk := .F.
			EndIf
		EndIf

		If lOk
			exit
		EndIf
	EndIf
End

If lOk
	GravaRCC( "S035" , aDados, .F. )
EndIf

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LimparRCC | Autor ³  Oswaldo L           ³ Data ³14/12/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Limpar conteudo da tabela RCC                			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static function LimparRCC ()
Local cQuery := "DELETE FROM " + RetSqlName("RCC") + "  WHERE RCC_FILIAL = '" + FwxFilial('RCC') + "' AND RCC_CODIGO = 'S035' AND "
Local cError := ""
cQuery += " RCC_CHAVE = '" + substr(cNovoMesAnoOrig,3,4) + substr(cNovoMesAnoOrig,1,2) + "' AND RCC_FIL = '" + cFilCarga + "' AND D_E_L_E_T_ = ' ' "
TcSqlExec(cQuery)
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ProxSeq | Autor ³  Oswaldo L           ³ Data ³14/12/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Proxima sequencia da tabela RCC                			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function ProxSeq ()
Local cQryRCC := GetNextAlias()
Local cQuery  := "SELECT MAX(RCC.RCC_SEQUEN) ULTSEQ FROM " + RetSqlName("RCC") + " RCC WHERE RCC.RCC_FILIAL = '" + FwxFilial('RCC') + "' AND RCC.RCC_CODIGO = 'S035'  "
Local cSeq    := '001'

cQuery += " AND RCC.RCC_CHAVE = '" + substr(cNovoMesAnoOrig,3,4) + substr(cNovoMesAnoOrig,1,2) + "' AND RCC.RCC_FIL = '" + cFilCarga + "' AND RCC.D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQryRCC,.T.,.T.)

If (cQryRCC)->(!Eof())
	cSeq := (cQryRCC)->(ULTSEQ)
	cSeq := Soma1(cSeq)
EndIf

(cQryRCC)->(DbCloseArea())

return cSeq

/*/{Protheus.doc} ValidCols
Verificar e sequenciar itens alterados evitando chave duplicada
@type function
@author gisele.nuncherino
@since 24/01/2018
/*/
Static Function ValidCols()
Local nPosSeq		:= GdFieldPos("RCC_SEQUEN")
Local nPosCha		:= GdFieldPos("RCC_CHAVE")
Local nPosFil		:= IIf(GdFieldPos("RCC_FIL") > 0,GdFieldPos("RCC_FIL"), 1) // Posicao Campo Filial da tabela no Acols
Local nPosCod		:= GdFieldPos("CODIGO")					// Posicao Campo Codigo da tabela no Acols
Local nPosCodBra	:= GdFieldPos("BRA_" + cCodigo + "01")	// Posicao Campo Codigo em tabelas nomeadas p/Brasil
Local nPosIdad		:= GdFieldPos("IDADEATE")				// Posicao Campo Idade da tabela no Acols
Local nUsado		:= Len(aHeader)
Local nUsaCols		:= 0
Local cChaveGet		:= ""
Local aCopyCols		:= aClone(aCols)

	nUsaCols  := Len(aCols)

	for nUsaCols := 1 to len(aCols)

		If aCopyCols[n,nUsado+1] //linha deletada
			If lAnoMes
				cChaveGet := cFilRCC+ cCodigo + aCopyCols[ n,nPosFil]+ aCopyCols[n,nPosCha]+ aCopyCols[n,nPosSeq]
			Else
				cChaveGet := cFilRCC+ cCodigo + aCopyCols[ n,nPosFil]+ aCopyCols[n,nPosSeq]
			EndIf

			If lAnoMes
				aSort( aCopyCols,,,{ |x,y,z| x[nPosFil] + x[nPosCha ] + x[nPosSeq] < y[nPosFil] + y[nPosCha] + y[nPosSeq]} )		//-- Ordena para acertar a sequencia
			Else
				aSort( aCopyCols,,,{ |x,y| x[nPosFil] + x[nPosSeq] < y[nPosFil] + y[nPosSeq]} )		//-- Ordena para acertar a sequencia
			EndIf

			//Muda a Sequencia da Tabela de acordo com  a chave
			fPlusSeq(@aCopyCols,cChaveGet,nUsado, .F.)

			If Empty(AcopyCols)
				aCols := {}
			Else
				aCols	:= aClone(aCopyCols)
			EndIf
		EndIf

	next nUsaCols
Return

/*/{Protheus.doc} VldFil
Responsável pela checagem e validação das filiais que não foram alteradas
@type function
@author Eduardo
@since 24/01/2018
@version 1.0
@param aFils, array, Posição 3 do array de filiais
@return lFilAlt, Lógico, Checando se a filial posicionada está dentro das restrições ou livre para seguir o fluxo normal
/*/
Function VldFil(aFils,cValFil)
Local nI        := 0
Local nLen      := 0
Local lFilAlt   := .F.

default aFils   := {}
default cValFil := ""

cValFil:= Alltrim(cValFil)
cFilRet:= StrTran(cFilRet,cValFil,"")
For nI:= 1 to Len(aFils)
    aFils[nI]:= Alltrim(aFils[nI])
    If aFils[nI]!= NIL
        If ((!(aFils[nI] $ cFilRet) .Or. Empty(cValFil)) .And. !lFilAlt ) .And.  (aFils[nI] == cValFil .Or. Empty(cValFil))
            lFilAlt:= .T.
        ElseIf  aFils[nI] $ cFilRet
            aDel(aFils,nI)
            nLen++
        ElseIf  !Empty(cValFil) .And. aFils[nI] != cValFil .And. ( Len(aFils) - nLen) > 1
            aDel(aFils,nI)
            if nLen < Len(aFils)
                nLen++
                nI:= nI-1
            EndIf
        EndIf
    EndIf
Next

aSize( aFils,len(aFils)-nLen)

Return lFilAlt

/*/{Protheus.doc} fEvnAlt
Rotina de Checagem de alteração no acols.
@type function
@author Eduardo
@since 18/01/2018
@version 1.0
/*/
Static Function fEvnAlt(aAuxTAb)

	Local aCpos1020		:= {"CodTerc", "RCC_FIL", "RCC_SEQUEN", "RCC_CHAVE", "Terceiro"}
	Local lRet          := .F.//Retornno a função
	Local lAltN         := .F.//Checagem de filiais não alteradas
	Local nX            := 0//Contador
	Local cInfTerc		:= ""

	default aAuxTAb     := {}

	cFilRet := ""

	For nX:= 1 to Len(aCols)
		lAltN   := .F.

		If !aCols[nX, len(aCols[nX])]
			If nX <= Len(aColsAnt)
				If (aCols[nX, GDFieldPos(aCpos1020[2])] + aCols[nX, GDFieldPos(aCpos1020[1])] != aColsAnt[nX , GDFieldPos(aCpos1020[2])] + aColsAnt[nX , GDFieldPos(aCpos1020[1])])
					If aScan(aColsAnt, {|x| x[GDFieldPos(aCpos1020[2])] + x[GDFieldPos(aCpos1020[1])] == aCols[nX, GDFieldPos(aCpos1020[2])] + aCols[nX, GDFieldPos(aCpos1020[1])]}) == 0
						If aScan(aAuxTAb, {|x| x[GDFieldPos(aCpos1020[2])] + x[GDFieldPos(aCpos1020[4])] + x[GDFieldPos(aCpos1020[3])] == aCols[nx, GDFieldPos(aCpos1020[2])] + aCols[nX, GDFieldPos(aCpos1020[4])] + aCols[nX, GDFieldPos(aCpos1020[3])]}) == 0
							aAdd(aAuxTAb , aCols[nX])
						EndIf
						lAltN := .T.
					EndIf
				EndIf

				cInfTerc := aColsAnt[nX, GDFieldPos(aCpos1020[2])] + aColsAnt[nX , GDFieldPos(aCpos1020[1])]
			Else
				If aCols[nX, GDFieldPos(aCpos1020[2])] + aCols[nX, GDFieldPos(aCpos1020[1])] <> cInfTerc
					If aScan(aColsAnt, {|x| x[GDFieldPos(aCpos1020[2])] + x[GDFieldPos(aCpos1020[1])] == aCols[nX, GDFieldPos(aCpos1020[2])] + aCols[nX, GDFieldPos(aCpos1020[1])]}) == 0
						aAdd(aAuxTAb, aCols[nX])
						lAltN := .T.
					EndIf
				EndIf
			EndIf

			If !lAltN
				If !Empty(aCols[nX , GDFieldPos(aCpos1020[2])])
					cFilRet := cFilRet + "|" +  aCols[nX, GDFieldPos(aCpos1020[2])]
				EndIf
			EndIf
		EndIf

	Next nX

Return .T.

/*/{Protheus.doc} VldEnt
Validação de Entidade na RA0, com o CNPJ em branco
@type function
@author Eduardo
@since 07/02/2018
@version 1.0
@param cFil, character,Filial a ser analisada
@param cCodEnt, character, Código da entidade
/*/Function VldEnt(cFil,cCodEnt)
Local lRet      := .T.
Local aRA0Bkp   := RA0->(GetArea())
Local aRCCBkp   := RCC->(GetArea())

default cFil    := xFilial("RA0")
default cCodEnt := ""

if Empty(cFil)
    cFil    := xFilial("RA0")
EndIf
dbSelectArea("RA0")
RA0->(DbSetOrder(1))
If !Empty(cCodEnt)
    If RA0->(MsSeek(FwxFilial("RA0",cFil) + cCodEnt))
        if Empty(RA0->RA0_CGC)
            lRet:= .F.
        EndIf
    Else
        lRet:= .F.
    EndIf

EndIf
RestArea(aRA0Bkp)
RestArea(aRCCBkp)
Return lRet

/*/{Protheus.doc} fVal320Tab
Validação de tabelas específicas
@author  isabel.noguti
@since   10.09.2018
@version 1.0
/*/
Static Function fVal320Tab()
	Local lRet		:= .T.
	local nPosSeq	:= GdFieldPos("RCC_SEQUEN")
	local nPosCha	:= GdFieldPos("RCC_CHAVE")
	local nPosFil	:= IIf(GdFieldPos("RCC_FIL") > 0,GdFieldPos("RCC_FIL"), 1)	// Posicao Campo Filial da tabela no Acols
	local nPosEnt	:= GdFieldPos("ENT")		// Posicao Campo Entidade da tabela no Acols
	Local nPosCod	:= GdFIeldPos("CODIGO")		// Posicao Campo Código da tabela no Acols
	Local nPosForn	:= GdFIeldPos("CODFOR")		// Posicao Campo Cód.Fornecedor da tabela no Acols
	Local nPosCpo	:= 1
	Local nI		:= 1
	Local nProx		:= 2
	Local nPosDel	:= Len(aHeader) + 1

	If cCodigo == 'S008'
		nPosCpo	:= GdFIeldPos("SALATE")				// Posicao Campo Salário da tabela S009
	ElseIf cCodigo == 'S009'
		nPosCpo	:= GdFIeldPos("IDADEATE")			// Posicao Campo Idade da tabela S008
	EndIf

	If cCodigo $ 'S008|S009'

		While nI < Len(aCols)
			If aCols[nI, nPosDel]	//.T. linha deletada
				nI ++
			Else
				nProx := nI + 1
				While nProx <= Len(aCols) .And. aCols[nI, nPosFil] == aCols[nProx, nPosFil] .And. aCols[nI, nPosCod] == aCols[nProx, nPosCod]
					If !aCols[nProx, nPosDel] .And. aCols[nI, nPosForn] != aCols[nProx, nPosForn]
								//"Código do plano ## cadastrado para fornecedores diferentes! Verifique as linhas: ## - ##" "Atencao"
						MsgAlert( OemToAnsi(STR0176) + aCols[nI, nPosCod] + OemToAnsi(STR0177) + cValToChar(nI) + " - " + cValToChar(nProx), OemToAnsi(STR0083) )
						Return .F.
					EndIf
					nProx ++
				EndDo
				nI := nProx
			EndIf
		EndDo

		For nI := 1 to Len(aCols) - 1
			If !aCols[nI, nPosDel]
				nProx := nI + 1
				If !aCols[nProx, nPosDel] .And. aCols[nI, nPosFil] == aCols[nProx, nPosFil] .And. aCols[nI, nPosCod] == aCols[nProx, nPosCod] .And. aCols[nI, nPosCpo] == aCols[nProx, nPosCpo]
							//"Código do plano ## cadastrado com os mesmos valores no campo ###. Verifique as linhas : ## - ##" "Atencao"
					MsgAlert( OemToAnsi(STR0176) + aCols[nI, nPosCod] + OemToAnsi(STR0178) + aHeader[nPosCpo, 1] + OemToAnsi(STR0179) + cValToChar(nI) + " - " + cValToChar(nProx), OemToAnsi(STR0083) )
					Return .F.
				EndIf
			EndIf
		Next nI

	EndIf

Return lRet

/*/{Protheus.doc} fAlert038
Funcao para exibição de alerta ao alterar um registro da tabela S038 - Lotação
@author Marco Nakazawa
@since 05/02/2019
@version 1.0
@return Nil
/*/
Function fAlert038()

Local oDlg			:= NIL
Local oBtTDN		:= NIL
Local oGroup		:= NIL

DEFINE FONT oFont  NAME "Arial" SIZE 0,-11 BOLD
DEFINE FONT oFont1 NAME "Arial" SIZE 0,-11

DEFINE MSDIALOG oDlg FROM  094,001 TO 400,600 TITLE OemToAnsi(STR0083) PIXEL  //--"Atenção"

		@ 020,015	GROUP oGroup TO 120,285 LABEL OemToAnsi(STR0181)  OF oDlg PIXEL //"Alteração"
		oGroup:oFont:=oFont

		@ 040 , 030 SAY OemToAnsi(STR0182)	SIZE 300,15 OF oDlg PIXEL FONT oFont1	//"Importante, se for alterado o código de terceiros em uma data que já exista fechamento"
		@ 050 , 030 SAY OemToAnsi(STR0183)	SIZE 300,15 OF oDlg PIXEL FONT oFont1 	//"da folha, será necessário reabrir a folha de pagamento (evento S-1298) e retificar"
		@ 060 , 030 SAY OemToAnsi(STR0184) 	SIZE 300,15 OF oDlg PIXEL FONT oFont1 	//"os eventos periódicos (S-1200 e S-1210)."

		@ 130 , 015 SAY oBtTDN PROMPT "<u>" + OemToAnsi(STR0185) + "</u>" SIZE 090,008 OF oDlg HTML PIXEL FONT oFont  //Link para documentação no TDN

		oBtTDN:bLClicked := {|| ShellExecute("open","http://tdn.totvs.com/x/InsWGw","","",1) }

ACTIVATE DIALOG oDlg CENTERED

Return (Nil)

Function fGupyTab(cTab)
Local aAreaRCC		:= RCC->(GetArea())
Local aAreaRCB		:= RCB->(GetArea())
Local aCopyTab		:= {}
Local nTamCPO		:= 0
Local nLin			:= n //o:nAt
Local nX			:= 0
Local cAlias		:= IIF(cTab=="S132","SQB","SRJ")
Local cFilCamp		:= Right(cAlias,2)+"_FILIAL"

Default cTab			:= ""
Default lMsNewGetDados	:= .F.
If nTamCPO==0
	nTamCPO:= 20 - TamSX3("QB_DEPTO")[1]
EndIf

If MsgYesNo(OemToAnsi(STR0190) +cAlias+"' -" + FwSX2Util():GetX2Name(cAlias) , OemToAnsi(STR0083) )
	dbSelectArea(cAlias)
	dbSetOrder(1)
	dbseek(xFilial(cAlias))

	While !&(cAlias)->(EOF()) .And. xFilial(cAlias) ==  &(cFilCamp)
		If cAlias == "SQB"
			aAdd(aCopyTab	,{xFilial("SRA"),StrZero(nLin,3),SQB->QB_DEPTO+Space(nTamCPO),SQB->QB_DESCRIC,SPACE(8),SPACE(70),"F",.F.})
		ElseIf cAlias == "SRJ"
			aAdd(aCopyTab	, {xFilial("SRA"),StrZero(nLin,3),SRJ->RJ_FUNCAO,SRJ->RJ_DESC,SPACE(8),SPACE(70),"F",.F.})
		EndIf
		&(cAlias)->(dbSkip())
		nLin++
	EndDo
	If !Empty(aCopyTab)
		If AllTrim(Upper(oGet:cClassName)) == "MSGETDADOS"
			aCols :=  aClone ( aCopyTab )
		Else
			oGet:aCols:= aClone(aCopyTab)
		EndIf
	EndIf
EndIf
oGet:lNewLine := .F.
oGet:oBrowse:Refresh(.T.)
RestArea(aAreaRCC)
RestArea(aAreaRCB)
Return .T.

/*/{Protheus.doc}  GP320CALC()
Valida mês/ano inicial e gatilha campo do novo cálculo de INSS
@type function
@author Leandro Drumond
@since 24/01/2020
@version 1.0
/*/
Function  GP320CALC()
Local cAnoMes 	:= &(ReadVar())
Local nPosCalc	:= GdFIeldPos("NOVOCALC")

If !Empty(cAnoMes) .and. cAnoMes >= "202003"
    aCols[n,nPosCalc] := "S"
Else
	aCols[n,nPosCalc] := "N"
EndIf

Return .T.


/*/{Protheus.doc} fCpoAlt
Verifica se os campos de envio do evento na na versão S-1.0 foram alterados
@since	26/01/2020
@autor	lidio.oliveira
@version 12
/*/
Static Function fCpoAlt(lNew, nLinha)

Local lAlterou  := .F.
Local aArea		:= GetArea()
Local bCondNew  := {|x| !Empty(aCols[nlinha,GDFieldPos("NRPROC")]) .Or. !Empty(aCols[nlinha,GDFieldPos("NRPROCAP")]) .Or.; //Se o número do processo está preenchido
				    !Empty(aCols[nlinha,GDFieldPos("CNPJR")]) } 														// Se o CNPJ responsavel esta preenchido
Local bCondAlt  := {|x|(aCols[nlinha,GDFieldPos("NRPROC")] <> aColsAnt[nlinha,GDFieldPos("NRPROC")]) .Or.; 	// Se houve alteração no processo PCD
					(aCols[nlinha,GDFieldPos("NRPROCAP")] <> aColsAnt[nlinha,GDFieldPos("NRPROCAP")]) .Or.; 	//Se houve alteração no processo do aprediz
					((!Empty(aCols[nlinha,GDFieldPos("NRPROC")]) .Or. !Empty(aCols[nlinha,GDFieldPos("NRPROCAP")])) .And.; 		//Se o número do processo está preenchido e (Continua na linha de baixo)
					((aCols[nlinha,GDFieldPos("TOMADOR")] <> aColsAnt[nlinha,GDFieldPos("TOMADOR")]) .Or. (aCols[nlinha,GDFieldPos("RCC_FIL")] <> aColsAnt[nlinha,GDFieldPos("RCC_FIL")])) ) .Or.;//se alterou tomador ou filial
					(aCols[nlinha,GDFieldPos("CNPJR")] <> aColsAnt[nlinha,GDFieldPos("CNPJR")]) } ; // Se alterou o CNPJ responsavel e Filial é CEI

Default lNew 	:= .T.
Default nLinha	:= 0

	If nLinha > 0
		If lNew
			If Eval( bCondNew )
				lAlterou := .T.
			Endif
		Else
			If Eval( bCondAlt )
				lAlterou := .T.
			Endif
		EndIf
	EndIf

	RestArea(aArea)

Return lAlterou
