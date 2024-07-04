#INCLUDE "pcor310.ch"
#INCLUDE "PROTHEUS.CH"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���FUNCAO    � PCOR310  � AUTOR � Edson Maricate        � DATA � 18/02/2005 ���
���������������������������������������������������������������������������Ĵ��
���DESCRICAO � Programa de impressao do demonstrativo de saldos             ���
���������������������������������������������������������������������������Ĵ��
��� USO      � SIGAPCO                                                      ���
���������������������������������������������������������������������������Ĵ��
���_DOCUMEN_ � PCOR310                                                      ���
���_DESCRI_  � Programa de impressao do demonstrativo de saldos             ���
���_FUNC_    � Esta funcao devera ser utilizada com a sua chamada normal a  ���
���          � partir do Menu do sistema.                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PCOR310(aPerg)
	Local aArea	  	:= GetArea()
	Local lPrint	:=	.T.
	Local cCubo		:=	""

	Private COD_CUBO

	Default aPerg := {}

	// Adiciona pergunta padrao de configuracao de cubo
	If Len(aPerg) == 0
		If Pergunte("PCR310",.T.)
			cCubo		:=	MV_PAR01
			COD_CUBO 	:= cCubo

			oReport	:= PCOR310Def( "PCR310", cCubo)
		Else
			lPrint	:=	.F.
		Endif
	Else
		aEval(aPerg, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})

		cCubo := MV_PAR01

		If !(Pco_ValidaCubo(cCubo))
			lPrint	:=	.F.
		Else
			oReport	:= PCOR310Def( "PCR310", cCubo)
		EndIf
	EndIf

	If lPrint
		oReport:PrintDialog()
	Endif

	RestArea(aArea)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � PCOR310Def� Autor � Gustavo Henrique   � Data �  25/05/06  ���
�������������������������������������������������������������������������͹��
���Descricao � Definicao do objeto do relatorio personalizavel e das      ���
���          � secoes que serao utilizadas                                ���
�������������������������������������������������������������������������͹��
���Parametros� EXPC1 - Grupo de perguntas do relatorio                    ���
���          � EXPC2 - Codigo do cubo em que o relatorio deve ser impresso���
�������������������������������������������������������������������������͹��
���Uso       � Planejamento e Controle Orcamentario                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PCOR310Def( cPerg, cCubo )

Local cReport	:= "PCOR310" 	// Nome do relatorio
Local cTitulo	:= STR0001		// Titulo do relatorio
Local cDescri	:= STR0006 		// Descricao do relatorio

Local aNiveis	:= {}
Local aSections := {}

Local nTotSec	:= 0
Local nSection	:= 0

Local oReport

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
oReport := TReport():New( cReport, cTitulo, cPerg, { |oReport| PrintReport( oReport, aNiveis, aSections ) }, cDescri ) // "Este relatorio ira imprimir o Demonstrativo de Saldos de acordo com os par�metros solicitados pelo usu�rio. Para mais informa��es sobre este relatorio consulte o Help do Programa ( F1 )."

//������������������������������������������������������������������������Ŀ
//� Define as secoes do relatorio a partir dos niveis do cubo selecionado  �
//��������������������������������������������������������������������������
aRet := PCOTRCubo( @oReport, cCubo, @aNiveis, @aSections )

//������������������������������������������������������������������������Ŀ
//� Define as secoes especificas do relatorio                              �
//��������������������������������������������������������������������������
nTotSec := Len( aSections )

For nSection := 1 To nTotSec
	TRCell():New( aSections[nSection], "SALDO",/*Alias*/,,"@E 999,999,999,999.99",18,/*lPixel*/,)
Next nSection

Return oReport


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � PrintReport �Autor� Bruno / Gustavo    � Data �  08/06/06  ���
�������������������������������������������������������������������������͹��
���Descricao � Impressao das secoes do relatorio definida em cima da      ���
���          � configuracao do cubo no array aSections.                   ���
�������������������������������������������������������������������������͹��
���Parametros� EXPO1 - Objeto TReport do relatorio                        ���
�������������������������������������������������������������������������͹��
���Uso       � Planejamento e Controle Orcamentario                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PrintReport( oReport, aNiveis, aSections )

Local nNivAtu 	:= 0
Local nX		:= 1
Local nZ		:= 1
Local nTotRecs	:= 0
Local nSections	:= Len( aSections )		// Total de secoes desconsiderando a ultima referente ao grupo de perguntas
Local nMaxCod	:= 0
Local nMaxDescr	:= 0
Local nLinImp	:= 0
Local nTotLin	:= 0
Local lChangeNiv:= .T.					// Indica se houve troca de nivel durante a impressao do relatorio
Local nLoop		:=	1
Local dBase     := dDataBase
Local nUltCelula
Local aAcessoCfg

Local aProcCube := {}
Local aConfig 	:= {}
Local cCodCube
Local cCubeCfg
Local oStructCube
Local aWhere
Local aParametros
Local lZerado
Local lEditCfg
Local cWhereTpSld
Local aTmpSld
Local nMaxNiv
Local nNivClasse
Local nMoeda
Local lContinua := .T.

Private aSavPar	:= {}
Private aProcessa	:=	{}

//���������������������������������������������������������������������������������������������Ŀ
//� Salva parametros para nao conflitar com parambox                                            �
//�����������������������������������������������������������������������������������������������
aSavPar := { MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06 }

/* PARAMETROS DO RELATORIO (SX1)
MV_PAR01 - Codigo do Cubo Gerencial ?
MV_PAR02 - Data de Referencia Saldo ?
MV_PAR03 - Moeda ?
MV_PAR04 - Configuracao do Cubo ?
MV_PAR05 - Editar Configuracoes do Cubo ?
MV_PAR06 - Considerar Zerados ?
*/
cCodCube := MV_PAR01
dDataBase := MV_PAR02 //manipula data base do sistema (tem que voltar depois para conteudo variavel dBase)
If ValType(MV_PAR03) == "C"
	nMoeda := Val(MV_PAR03)
Else
	nMoeda := MV_PAR03
EndIf
cCubeCfg := MV_PAR04
lZerado := ( MV_PAR06 == 1 )
lEditCfg := ( MV_PAR05 == 1 )

If SuperGetMV("MV_PCOCNIV",.F., .F.)

	//modo utilizando querys para buscar os saldos nas datas em bloco
	//verificar se usuario tem acesso as configuracoes do cubo
	aAcessoCfg := PcoVer_Acesso( cCodCube, cCubeCfg )  	//retorna posicao 1 (logico) .T. se tem acesso
   													//							.F. se nao tem
   													//        posicao 2 - Nivel acesso (0-Bloqueado 1-Visualiza 2-altera
	lContinua := aAcessoCfg[1]

	If ! lContinua

		Aviso(STR0007, STR0009,{"Ok"}) //"Atencao"###"Usuario sem acesso ao relatorio. Verifique a configuracao."

	Else


		oStructCube := PcoStructCube( cCodCube, cCubeCfg )

		If Empty(oStructCube:aAlias)  //se estiver vazio eh pq a estrutura nao esta correta
			lContinua := .F.
		EndIf

		If lContinua .And. aWhere == NIL //logo na primeira configuracao do cubo define tamnho array aWhere
			aWhere := Array(oStructCube:nMaxNiveis)

			//monta array aParametros para ParamBox
			aParametros := PcoParametro( oStructCube, lZerado, aAcessoCfg[1]/*lAcesso*/, aAcessoCfg[2]/*nDirAcesso*/ )

	        //exibe parambox para edicao ou visualizacao
			Pco_aConfig(aConfig, aParametros, oStructCube, lEditCfg/*lViewCfg*/, @lContinua)

			If lContinua
				lZerado	:=	aConfig[Len(aConfig)-1]          //penultimo informacao da parambox (check-box)
				lSintetica	:=	aConfig[Len(aConfig)]        //ultimo informacao da parambox (check-box)
				//veja se tipo de saldo inicial e final eh o mesmo e se nao ha filtro definido neste nivel
				cWhereTpSld := ""
				If oStructCube:nNivTpSld > 0 .And. ;
					oStructCube:aIni[oStructCube:nNivTpSld] == oStructCube:aFim[oStructCube:nNivTpSld] .And. ;
					Empty(oStructCube:aFiltros[oStructCube:nNivTpSld])
						cWhereTpSld := " AKT.AKT_TPSALD = '" + oStructCube:aIni[oStructCube:nNivTpSld] + "' AND "
				EndIf

				aProcCube := { dDataBase, oStructCube, aAcessoCfg, lZerado, lSintetica, cWhereTpSld }

				nMaxNiv := oStructCube:nMaxNiveis
				nNivClasse := oStructCube:nNivClasse

				//processa o cubo e o array aTmpSld contera as tabelas temporarias com os saldos
				//cada elemento do array aTmpSld representa uma serie (configuracao de cubo)
					aProcessa := PcoProcCubo(aProcCube, nMoeda)

				EndIf

			EndIf

		EndIf

Else

	//modo atual utilizando a funcao pcoruncube()
	aProcessa := PcoRunCube( aSavPar[1], 1, "Pcor310Sld", aSavPar[4], aSavPar[5], (aSavPar[6]==1),,,,,,, .T.)

EndIf

Pergunte("PCR310",.F.)
If lContinua
	nTotRecs  := Len( aProcessa )

	If nTotRecs > 0
		oReport:SetMeter( nTotRecs )

		//���������������������������������������������������������������������������������������������Ŀ
		//� Atualiza conteudo das celulas com o valor que deve ser impresso a partir do array aProcessa �
		//�����������������������������������������������������������������������������������������������
		For nX := 1 To nSections

			//�������������������������������������������������������������������������������������������
			//� Desabilita a impressao do cabecalho das secoes a partir do 1o. nivel do cubo e configura�
			//� impressao do cabecalho da 1a. secao no inicio de cada pagina (SetHeaderPage)            �
			//�������������������������������������������������������������������������������������������
			If nX == 1
				aSections[nX]:SetHeaderSection(.T.)
				aSections[nX]:SetHeaderPage(.T.)
			Else
				aSections[nX]:SetHeaderSection(.T.)
				aSections[nX]:SetHeaderPage(.F.)
				For nZ := 1 TO Len(aSections[nX]:aCell)
					aSections[nX]:Cell(nZ):HideHeader()
				Next
			EndIf

			aSections[nX]:Cell(aNiveis[nX,2])	:SetBlock( { || aProcessa[nLoop,14] 	} )
			aSections[nX]:Cell(aNiveis[nX,3])	:SetBlock( { || aProcessa[nLoop,6]  	} )
			aSections[nX]:Cell("SALDO")			:SetBlock( { || aProcessa[nLoop,2,1] 	} )
			aSections[nX]:Cell("SALDO"):cTitle := STR0004+" (" + DtoC( aSavPar[2] ) + ")"

			aSections[nX]:SetRelation( { || xFilial( aNiveis[nLoop][1] ) + aProcessa[nLoop,14] }, aNiveis[nLoop][1], 3, .T. )

			TrPosition():New(aSections[nX],aNiveis[nX][1],1, { || xFilial(  aNiveis[aProcessa[nLoop,8],1] ) + aProcessa[nLoop,14] } )

		  	nMaxCod := Max( nMaxCod, Max(Len(Alltrim(aSections[nX]:Title())),Len(aProcessa[nLoop,14]) ) )

		Next

		nMaxDescr := 100 - (nMaxCod + 3)

		//���������������������������������������������������������������������������������������������Ŀ
		//� Atualiza tamanho das celulas a partir do valor calculado as variaveis nMaxCod e nMaxDescr   �
		//�����������������������������������������������������������������������������������������������
		For nX := 1 To nSections
			aSections[nX]:Cell( aNiveis[nX,2] ):SetSize( nMaxCod  ,.F. )
			aSections[nX]:Cell( aNiveis[nX,3] ):SetSize( nMaxDescr,.F. )
		Next

		Do While !oReport:Cancel() .And. nLoop <= nTotRecs

			nNivAtu := aProcessa[nLoop,8]
			If oReport:Cancel()
				Exit
			EndIf

			oReport:IncMeter()

			If aProcessa[nLoop,8] == 1  //se for nivel 1
				oReport:ThinLine()
			EndIf

			aSections[nNivAtu]:Init()

			While nLoop <= nTotRecs .And. aProcessa[nLoop,8] == nNivAtu

				//������������������������������������������������������������������������������������Ŀ
				//� Imprime o nome do nivel da chave do cubo na 1a. linha e o detalhe da chave na 2a.  �
				//��������������������������������������������������������������������������������������
				aSections[ nNivAtu ]:PrintLine()

				nLoop ++

				If ! ( nLoop <= nTotRecs .And. aProcessa[nLoop,8] < nNivAtu )
					nUltCelula := Len(aSections[ nNivAtu ]:aCell)
					oReport:Line( oReport:Row(), aSections[ nNivAtu ]:Cell(nUltCelula):ColPos(), oReport:Row(), oReport:PageWidth() )
				EndIf

			EndDo

			//��������������������������������������������������������������������������������������
			//� Finaliza impressao da secao atual, caso for maior que a proxima secao              �
			//��������������������������������������������������������������������������������������
			aSections[nNivAtu]:Finish()

		EndDo

		aSections[ nNivAtu ]:Finish()

	EndIf

EndIf

dDataBase := dBase

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Pcor310Sld� Autor � Edson Maricate        � Data �18/02/2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de processamento para impressao do dem. de saldos.   ���
���          �Esta funcao e chama pela pcocube nos niveis de processamento���
���          �parametrizados / ou pre configurados                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Pcor310Sld                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Pcor310Sld(cConfig,cChave)
Local aRetFim
Local nCrdFim
Local nDebFim

aRetFim := PcoRetSld(cConfig,cChave,aSavPar[2])
nCrdFim := aRetFim[1, aSavPar[3]]
nDebFim := aRetFim[2, aSavPar[3]]

nSldFim := nCrdFim-nDebFim

Return {nSldFim}

//------------------------------------------------------------------------------------------------------------------//
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PcoProcCubo �Autor  �Paulo Carnelossi    � Data � 13/07/08  ���
�������������������������������������������������������������������������͹��
���Desc.     �Monta as querys baseados nos parametros e configuracoes de  ���
���          �cubo e executa essas querys para gerar os arquivos tempora- ���
���          �rios cujos nomes sao devolvidos no array aTabResult         ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PcoProcCubo(aProcCube, nMoeda)
Local cCodCube
Local cArquivo := ""
Local aQueryDim, cArqTmp
Local nZ
Local cWhereTpSld := ""
Local cWhere := ""
Local dData, oStructCube, lZerado, lSintetica, lTotaliza
Local nNivel := 1 //sempre processar a partir do primeiro nivel
Local aCposNiv := {}
Local aFilesErased := {}
Local aProcCub := {}
Local cArqAS400 := ""
Local cSrvType := Alltrim(Upper(TCSrvType()))

dData		:= aProcCube[1]
oStructCube := aProcCube[2]
lZerado 	:= aProcCube[4]
lSintetica 	:= aProcCube[5]
lTotaliza 	:= .F.
cWhereTpSld := aProcCube[6]
cCodCube 	:= oStructCube:cCodeCube
If cSrvType == "ISERIES" //outros bancos de dados que nao DB2 com ambiente AS/400
	//cria arquivo para popular
	PcoCriaTemp(oStructCube, @cArqAS400, 1/*nQtdVal*/)
	aAdd(aFilesErased, cArqAS400)
EndIf

//cria arquivo para popular
PcoCriaTemp(oStructCube, @cArquivo, 1/*nQtdVal*/)
aAdd(aFilesErased, cArquivo)

aQryDim 	:= {}
For nZ := 1 TO oStructCube:nMaxNiveis
	If lSintetica .And. nZ > nNivel
		aQueryDim := PcoCriaQueryDim(oStructCube, nZ, lSintetica, .T./*lForceNoSint*/)
	Else
		aQueryDim := PcoCriaQueryDim(oStructCube, nZ, lSintetica)
	EndIf
	//aqui fazer tratamento quando expressao de filtro e expressao sintetica nao for resolvida
	If (aQueryDim[2] .And. aQueryDim[3])  //neste caso foi resolvida

		If ! aQueryDim[4]
			aAdd( aQryDim, { aQueryDim[1], ""} )
		Else
			aAdd( aQryDim, { aQueryDim[1], aQueryDim[5]} )
		EndIf

	Else  //se filtro ou condicao de sintetica nao foi resolvida pela query

		aQueryDim := PcoQueryDim(oStructCube, nZ, @cArqTmp, aQueryDim[1] )
		aAdd(aFilesErased, cArqTmp)

		If ! aQueryDim[4]
			aAdd( aQryDim, { aQueryDim[1], ""} )
		Else
			aAdd( aQryDim, { aQueryDim[1], aQueryDim[5]} )
		EndIf

	EndIf
Next

For nZ := nNivel+1 TO oStructCube:nMaxNiveis
	If nZ == oStructCube:nNivTpSld
		aAdd(aCposNiv, "AKT_TPSALD")
	Else
		aAdd(aCposNiv, "AKT_NIV"+StrZero(nZ, 2) )
	EndIf
Next

aQuery := PcoCriaQry( cCodCube, nNivel, nMoeda, cArqAS400, 1/*nQtdVal*/, { dData }/*aDtSld*/, aQryDim, cWhere/*cWhere*/, cWhereTpSld, oStructCube:nNivTpSld, .F., NIL, .T./*lAllNiveis*/, aCposNiv )

PcoPopulaTemp(oStructCube, cArquivo, aQuery, 1/*nQtdVal*/, lZerado, cArqAS400)

dbSelectArea(cArquivo)
dbCloseArea()

CarregaProcessa(aProcCub, oStructCube, cArquivo)

If ! Empty(aFilesErased)
	//apaga os arquivos temporarios criado no banco de dados
	For nZ := 1 TO Len(aFilesErased)
		If Select(Alltrim(aFilesErased[nZ])) > 0
			dbSelectArea(Alltrim(aFilesErased[nZ]))
			dbCloseArea()
		EndIf
		MsErase(Alltrim(aFilesErased[nZ]))
	Next
EndIf

Return aProcCub


Static Function CarregaProcessa(aProcCub, oStructCube, cArquivo)
Local cChave, nTamNiv, nPai, cChavOri, cDescrAux, lAuxSint
Local nNivel
Local nX, nZ
Local cQuery

For nX := 1 TO oStructCube:nMaxNiveis

	nNivel := nX
	nTamNiv := oStructCube:aTam[nNivel]

	cQuery := " SELECT "

	For nZ := 1 TO nNivel
		cQuery += If(nZ>1, ", ", "") + "AKT_NIV"+StrZero(nZ,2)
	Next //nZ

	cQuery += " , SUM(AKT_SLD001) SOMA_VALOR "

	cQuery +=" FROM "+cArquivo

	cQuery += " GROUP BY "
	For nZ := 1 TO nNivel
		cQuery += If(nZ>1, ", ", "") + "AKT_NIV"+StrZero(nZ,2)
	Next //nZ
	cQuery += " ORDER BY "
	For nZ := 1 TO nNivel
		cQuery += If(nZ>1, ", ", "") + "AKT_NIV"+StrZero(nZ,2)
	Next //nZ

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cArquivo, .T., .T. )

	dbSelectArea(cArquivo)
	dbGoTop()

	While (cArquivo)->( ! Eof() )
		cChave := ""
		For nZ := 1 TO nX
			cChave += PadR( (cArquivo)->(FieldGet(FieldPos("AKT_NIV"+StrZero(nZ,2)))) , nTamNiv)
		Next //nZ
		nPai := 0
		cChavOri := ""
		//descricao tem q macro executar a expressao contida em oStrucCube:aDescRel
		dbSelectArea(oStructCube:aAlias[nNivel])
		If dbSeek(xFilial()+PadR( (cArquivo)->(FieldGet(FieldPos("AKT_NIV"+StrZero(nNivel,2)))) , nTamNiv) )
			cDescrAux := &(oStructCube:aDescRel[nNivel])
			If ! Empty(oStructCube:aCondSint[nNivel])
				lAuxSint := &(oStructCube:aCondSint[nNivel])
			Else
				lAuxSint := .F.
			EndIf
		Else
			cDescrAux := ""
			lAuxSint := .F.
		EndIf

	  	aAdd(aProcCub, {	cChave, ;
	  						{ (cArquivo)->(FieldGet(FieldPos("SOMA_VALOR")))}, ;
		  					oStructCube:aConcat[nNivel], ;
		  					oStructCube:aAlias[nNivel], ;
	  						oStructCube:aDescri[nNivel], ;
	  						cDescrAux,;
		  					0,;
		  					nNivel,;
	  						cChavOri,;
	  						lAuxSint/*oStructCube:aCondSint[nNivel]*/,;
	  						nPai,;
		  					.T.,;
		  					oStructCube:aDescCfg[nNivel],;
							PadR(cChave, nTamNiv),;
							( nNivel  == oStructCube:nMaxNiveis ) })

		dbSelectArea(cArquivo)
		(cArquivo)->(dbSkip())

	EndDo

	dbSelectArea(cArquivo)
	dbCloseArea()

Next

ASORT(aProcCub,,,{|x,y|x[1]<y[1]})

Return
