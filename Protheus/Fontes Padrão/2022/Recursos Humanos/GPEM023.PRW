#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM023.CH"

#DEFINE TAB Chr(09)

Static nOrdemMult	:= 0
Static lCargSQ3		:= SuperGetMv("MV_CARGSQ3",,.F.) //Define se o envio do evento S-1030 serão feito pela tabela SQ3 e não pela SRJ (Padrão .F. -> SRJ).
Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Static _aSM0		:= {}
Static cVersEnvio	:= ""
Static cVersGPE		:= ""
Static cVerTaf		:= StrTran(StrTran(SuperGetMv("MV_TAFVLES",, "2.4"), "_", "."), "0", "", 1, 2)
Static lAlerta		:= FindFunction("fVersEsoc") .And. cPaisLoc == "BRA" .And. fVersEsoc("S1010", .F.,,, @cVersEnvio, @cVersGPE)
Static lNewVerEsoc	:= cVersGPE >= '9.0'
Static lOpeSoc		:= SuperGetMv("MV_OPESOC", NIL, .F.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GPEM023  ³ Autor ³ Alessandro Santos                           ³ Data ³ 03/02/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de Envio de Eventos - TAF                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM023()                                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista     ³ Data     ³ FNC/Requisito  ³ Chamado ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Raquel Hager ³11/08/2014³00000026544/2014³TQHIID   ³Inclusao de fonte na Versao 12.			  ³±±
±±³Raquel Hager³24/08/2016³00000029392/2016T³VTOQD    ³Remoção do uso do parâmetro MV_INTTAF para ³±±
±±³            ³          ³                ³          ³release 12.1.7.						      ³±±
±±³Marcia Moura³01/09/2016³                ³TUWITW    ³Correcoes referentes aos campos Tp Processo³±±
±±³            ³          ³                ³          ³alem disso foi retirado a consit.de horario³±±
±±³Jônatas A.  ³12/04/2017³DRHPAG-242      ³          ³Substituição das funções de criação de     ³±±
±±³            ³          ³	               ³          ³tabelas temporárias pela classe            ³±±
±±³            ³          ³	               ³          ³FWTemporaryTable().                        ³±±
±±³Marcos Cout.³17/04/2017³DRHESOCP-93     ³          ³Compatibilização do eSocial para layout 2.2³±±
±±³Marcia Moura³27/04/2017³DRHESOCP-38     ³          ³Integracao do TAF - registro s2200         ³±±
±±³Marcia Moura³02/06/2017³DRHESOCP-316    ³          ³Pacote para Atendimento                    ³±±
±±³Marcos Cout ³12/06/2017³DRHESOCP-389    ³          ³War Room + Merge                           ³±±
±±³            ³          ³                ³          ³Ajustes realizados p WarRoom na Car.Inicial³±±
±±³Oswaldo L   ³12/06/2017³DRHESOCP-391    ³          ³Ajuste layout campos em tela               ³±±
±±³Oswaldo L   ³12/06/2017³DRHESOCP-394    ³          ³Retornar funcao fTabelas removeram indevida³±±
±±³            ³          ³                ³          ³mente. Mas é utilizada no GPEM035.         ³±±
±±³Oswaldo L   ³19/06/2017³DRHESOCP-444    ³          ³Ajuste de texto no parâmetro Tabelas tela  ³±±
±±³            ³          ³                ³          ³GPEM035                                    ³±±
±±³Marcia Moura³29/06/2017 ³DRHESOCP-516    ³         ³Erros encontrados durante os testes FILIPI ³±±
±±³Oswaldo L   ³27/06/2017³DRHESOCP-516    ³          ³Ajuste omissão indevida das filiais grid   ³±±
±±³Marcia Moura³04/07/2017³DRHESOCP-516    ³          ³Caso o MV_INTTAF estiver como N, as funcoes³±±
±±³            ³          ³                ³          ³do TAF nao estao sendo executadas          ³±±
±±³Marcia Moura³05/07/2017³DRHESOCP-569    ³          ³Apresentar a mensagem caso não tenha sido  ³±±
±±³            ³          ³                ³          ³preenchido o gripo de perguntas            ³±±
±±³Marcos Cout ³28/07/2017³DRHESOCP-703    ³          ³Realizar ajustes estéticos e padronizados  ³±±
±±³            ³          ³                ³          ³no relatório de Carga Inicial dos Eventos  ³±±
±±³Eduardo Vicente³02/08/2017³DRHESOCP-744            ³Ajustes na chamada da Função fGp23Cons     ³±±
±±³Eduardo V   ³11/08/2017³DRHESOCP-781    ³          ³Correções de erros apontadas a issue 592   ³±±
±±|Claudinei S.|28/08/2017|DRHESOCP-779    |          |Ajuste em fGp23MkBr() para só apresentar as|±±
±±|            |          |                |          |filiais centralizadoras para geração da    |±±
±±|            |          |                |          |carga inicial.                             |±±
±±|Marcos Cout.|08/09/2017|DRHESOCP-887    |          |Unificação das rotinas de integração dos   |±±
±±|            |          |                |          |trabalhadores. Ajustada rotina fintAdmiss  |±±
±±³Marcos Cout |14/09/2017|DRHESOCP-1018   |          |Realizando o ajuste necessário para que o  ³±±
±±³            |          |                |          |sistema realize a validação do layout dispo³±±
±±³            |          |                |          |nível no ambiente para fazer a integração  ³±±
±±³            |          |                |          |entre o SIGAGPE e o SIGATAF                ³±±
±±³Eduardo V.  ³13/12/2017³  DRHESOCP-2213 ³          ³Inclusão de carga inicial do evento 2300   ³±±
±±³Eduardo V.  ³18/12/2017³  DRHESOCP-2496 ³          ³Inclusão de link para acesso  doc do portal³±±
±±³Marcos Cout ³28/12/2017³  DRHESOCP-2631            ³Realizado criação da opção de carga inicial³±±
±±³            ³          ³                           ³do evento S-1040 - Cargos/Funções Comissio_³±±
±±³            ³          ³                           ³nados. Ajustes na função para gerar XML.   ³±±
±±³            ³          ³                           ³Ajuste no evento S-2200 qnd trabalhador    ³±±
±±³            ³          ³                           ³tiver cargo comissionado                   ³±±
±±³Eduardo V.  ³02/01/2018³  DRHESOCP-2646 ³         ³Inclusão de consistência de tabelas entre  ³±±
±±³            ³          ³                          ³TAF e GPE				                  ³±±
±±|Marcos Cout.|10/09/2017|DRHESOCP-2678   |          |Ajustes para detectar a filial matriz corre|±±
±±|            |          |                |          |tamente.                                   |±±
±±|João Balbino|28/01/2018|MPRIMESP-13403  |          |Ajustes na validação do pergunte do evento |±±
±±|            |          |                |          |S-2300 .                                   |±±
±±³Eduardo V.  ³02/02/2018³ DRHESOCP-2852  ³         ³Adaptaçao da função que carrega a C1E, para ³±±
±±³            ³          ³                          ³que a mesma possa ser chamada de outras func³±±
±±|Marcos Cout.³23/02/2018³DRHESOCP-3059              ³Adicionar na carga inicial a opção         ³±±
±±|            ³          ³                           ³"Exclusão em Lote" para remover do RET os  ³±±
±±|            ³          ³                           ³eventos já integrado (S1010 Rubricas)      ³±±
±±³Eduardo V.  ³28/02/2018³ DRHESOCP-3274  ³         ³Funcionalidade de bloqueio de envio de tab  ³±±
±±|            ³          ³                           ³compartilhada com filiais com mais de uma  ³±±
±±|            ³          ³                           ³matriz				                      ³±±
±±|Marcos Cout.³28/02/2018³DRHESOCP-3307              ³Geração da opção de Exclusão em Lote para  ³±±
±±|            ³          ³                           ³os demais eventos da carga inicial         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPEM023(aInfoAut)

	Local aArea		 	:= GetArea()
	Local aAreaCR9  	:= {}
	Local oProcesso	 	:= Nil
	Local oDlgEven		:= Nil
	Local cAliasTRB		:= GetNextAlias()
	Local cProcesso		:= ""
	Local nOpcX			:= 0
	Local dDataRef		:= SToD("  /  /    ")
	Local aSizeTel		:= MsAdvSize(.F.)
	Local aObjects		:= {}
	Local aInfo			:= {}
	Local aPosObj		:= {}
	Local aArrayFil		:= {}
	Local aCheck		:= { .F., .F., .F., .F., .F., .F., .F., .F., .F., .F. }
	Local aProcesso	    := {OemToAnsi(STR0114), OemToAnsi(STR0115), OemToAnsi(STR0150), OemToAnsi(STR0216) } //##"Cargas Inicias" ##"Rel. Inconsistencias" ##"Tab. Hr. eSocial" ##"Exclusão em Lote"
	Local bFecha		:= {||oDlgEven:End()}
	Local bOK			:= {||IIF(fGp23TdOk(dDataRef, aCheck, aArrayFil, cAliasTRB, cProcesso), (oDlgEven:End(), nOpcX := 1), Nil)}
	Local oFWLayer		:= FWLayer():New()
	Local aBotoes		:= {}
	Local oButton		:= NIL

	Private cVersEnvTr	:= "" //Utilizado para saber qual mensagem (STR) exibir
	private lVerTr		:= Iif( FindFunction("fVersEsoc"), fVersEsoc("S2100", .F.,/*aRetGPE*/,/*aRetTAF*/, @cVersEnvTr), .F. )

	Private oTmpTbl

	Private cSituacao	:= ""
	Private cFilDe		:= ""
	Private cFilAte		:= ""
	Private cMatDe		:= ""
	Private cMatAte		:= ""
	Private cNomeDe		:= ""
	Private cNomeAte	:= ""
	Private cCCDe		:= ""
	Private cCCAte		:= ""
	Private nRetifica	:= 0

	Private cSit2300		:= ""
	Private cFilDe2300		:= ""
	Private cFilAte2300		:= ""
	Private cMatDe2300		:= ""
	Private cMatAte2300		:= ""
	Private cNomeDe2300		:= ""
	Private cNomeAte2300	:= ""
	Private cCCDe2300		:= ""
	Private cCCAte2300		:= ""
	Private cCatEfd2300		:= ""
	Private nRetif2300		:= 0
	Private lExistMatriz    := .F.

	Private lWorkFlow		:= ! Empty(aInfoAut)

	Private cExp1005		:= ""
	Private cExp1010		:= ""
	Private cExp1020		:= ""
	Private cExp1030		:= ""
	Private cExp1035		:= ""
	Private cExp1040		:= ""
	Private cExp1050		:= ""
	Private lParcial		:= .F.
	Private lOrgPubSGY 		:= fGp23OrPub("SGY")
	Private lOrgPubRS9 		:= fGp23OrPub("RS9")
	Private lNovoCTT		:= FindFunction("fVldObraRJ") .And. fVldObraRJ(@lParcial, .T.)
	Private	lRJs 			:= (lNovoCTT .And. !lParcial)

	If !lMiddleware
		If ! Empty(xFilial("C1E"))
			//O compartilhamento da tabela C1E está incorreto, altere o modo de acesso atraves do Configurador. Para maiores informações consulte a página de Complemento Empresa no TAF
			Help( ,, 'HELP',, OemToAnsi(STR0213), 1, 0 )
			Return()
		EndIf
	Endif

	// RECEBE A VERSÃO DO TAF.
	cVerTaf:= StrTran(Iif(cVerTaf == "2.4.01", "2.4", cVerTaf), "S.1", "9")

	If FindFunction("fVersEsoc") .And. FindFunction("ESocMsgVer")
		fVersEsoc("S1030", .F.,,, @cVersEnvio, @cVersGPE)
		If !lMiddleware .And. cVersGPE <> cVersEnvio .And. (cVersGPE >= "9.0" .Or. cVersEnvio >= "9.0")
			//# "Atenção! # A versão do leiaute GPE é XXX e a do TAF é XXXX, sendo assim, estão divergentes. A rotina será encerrada"
			ESocMsgVer(.T.,/*cEvento*/, cVersGPE, cVersEnvio)
			Return ()
		EndIf
	EndIf

	//Faz o calculo automatico de dimensoes dos objetos visuais
	AAdd(aObjects, {100, 075, .T., .T.})
	AAdd(aObjects, {100, 125, .T., .T.})
	aInfo   := {aSizeTel[1], aSizeTel[2], aSizeTel[3], aSizeTel[4], 3, 3}
	aPosObj := MsObjSize(aInfo, aObjects, .T.)

	Pergunte("GPEM023", .F.)
	cFilDe		:= MV_PAR01
	cFilAte		:= MV_PAR02
	cCCDe		:= MV_PAR03
	cCCAte		:= MV_PAR04
	cMatDe		:= MV_PAR05
	cMatAte		:= MV_PAR06
	cNomeDe		:= MV_PAR07
	cNomeAte	:= MV_PAR08
	cSituacao 	:= MV_PAR09
	nRetifica	:= Iif( ValType(MV_PAR10) == "N", MV_PAR10, 2)

	Pergunte("GPM02300", .F.)
	cFilDe2300		:= MV_PAR01
	cFilAte2300		:= MV_PAR02
	cCCDe2300		:= MV_PAR03
	cCCAte2300		:= MV_PAR04
	cMatDe2300		:= MV_PAR05
	cMatAte2300		:= MV_PAR06
	cNomeDe2300		:= MV_PAR07
	cNomeAte2300	:= MV_PAR08
	cSit2300		:= MV_PAR09
	cCatEfd2300		:= MV_PAR10
	nRetif2300		:= Iif( ValType(MV_PAR11) == "N", MV_PAR11, 2)

	If !lMiddleware
		aAreaCR9 := CR9->(GetArea())
	Endif

	If ! lWorkFlow

		//Dialog eventos periodicos
		DEFINE MSDIALOG oDlgEven FROM aSizeTel[7], 0 TO aSizeTel[6], aSizeTel[5] TITLE If(lMiddleware,STR0272,STR0002) OF oMainWnd PIXEL //##"Monitoramento Envio de Eventos - TAF#Middleware"

		//Compatibilizando a posição para a V12 - Barra Superior
		aPosObj[1, 1] += 35

		//Get competencia
		TSay():New(aPosObj[1, 1], aPosObj[1, 2] + 5, {|| OemToAnsi(STR0116)}, oDlgEven,,, .F., .F., .F., .T., CLR_BLUE,, 60, 10, .F., .F., .F., .F., .F.) //#"Data de Referência"
		TGet():New(aPosObj[1, 1] + 12, aPosObj[1, 2] + 5, {|u| If(PCount() == 0, dDataRef, dDataRef := u)}, oDlgEven, 45, 10,,,,,,,, .T.,,,,,,, .F.,,, "dDataRef")

		//Combo processamento
		TSay():New(aPosObj[1, 1], aPosObj[1, 2] + 100, {|| OemToAnsi(STR0117)}, oDlgEven,,, .F., .F., .F., .T., CLR_BLUE,, 60, 10, .F., .F., .F., .F., .F.) //#"Processamento"
		oProcesso := TComboBox():New(aPosObj[1, 1] + 12, aPosObj[1, 2] + 100, {|u| If(Pcount() > 0, cProcesso := u, cProcesso)}, aProcesso, 60, 10, oDlgEven,,,, CLR_BLUE,, .T.,,,,,,,,,)

		If !lMiddleware
			//Botão Versão dos Eventos
			TSay():New(aPosObj[1, 1], aPosObj[1, 2] + 200, {|| OemToAnsi(STR0187)}, oDlgEven,,, .F., .F., .F., .T., CLR_BLUE,, 60, 10, .F., .F., .F., .F., .F.) //#"Versão dos Eventos"
			oButton := TButton():New( aPosObj[1, 1] + 12, aPosObj[1, 2] + 200, OemToAnsi(STR0004), oDlgEven, {||fVerifVersao()}, 60, 10,,, .F., .T., .F.,, .F.,,, .F. )
		Endif

		//Checkbox folha de pagamento
		If lNewVerEsoc
			fNewGp23ChBx(oDlgEven, aPosObj, aCheck, cVersEnvTr)
		Else
			fGp23ChBx(oDlgEven, aPosObj, aCheck, cVersEnvTr)
		EndIf

		//Criacao do markbrowse
		If !lMiddleware
			fGp23MkBr(oDlgEven, aPosObj, cAliasTRB)

			If ! lExistMatriz
				//"Sr(a) usuário(a), realizar a definição de filial Matriz dentro do fluxo de cadastro de filiais no módulo TAF."
				Help( ,, 'HELP',, OemToAnsi(STR0212) , 1, 0 )
				Return()
			EndIf
		Else
			fGp23MidMk(oDlgEven, aPosObj, cAliasTRB)
		Endif

		aAdd( aBotoes, { 'CPARAM', { || GpFltBldExp( Iif(!lRJs, "CTT", "RJ4") , NIL , @cExp1005 , NIL ) } , "Filtro S-1005", "Filtro S-1005" }) //"Filtro S-1005"
		aAdd( aBotoes, { 'CPARAM', { || GpFltBldExp( "SRV" , NIL , @cExp1010 , NIL ) } , "Filtro S-1010", "Filtro S-1010" }) //"Filtro S-1010"
		aAdd( aBotoes, { 'CPARAM', { || GpFltBldExp( Iif(!lRJs, "CTT", "RJ3") , NIL , @cExp1020 , NIL ) } , "Filtro S-1020", "Filtro S-1020" }) //"Filtro S-1020"

		If !lNewVerEsoc
			aAdd( aBotoes, { 'CPARAM', { || GpFltBldExp( Iif(lOrgPubRS9 .Or. lCargSq3, "SQ3", "SRJ") , NIL , @cExp1030 , NIL ) } , "Filtro S-1030", "Filtro S-1030" }) //"Filtro S-1030"

			If lOrgPubSGY
				aAdd( aBotoes, { 'CPARAM', { || GpFltBldExp( "SGY" , NIL , @cExp1035 , NIL ) } , "Filtro S-1035", "Filtro S-1035" }) //"Filtro S-1035"
			EndIf

			If lOrgPubRS9 .Or. lCargSq3
				aAdd( aBotoes, { 'CPARAM', { || GpFltBldExp( "SRJ" , NIL , @cExp1040 , NIL ) } , "Filtro S-1040", "Filtro S-1040" }) //"Filtro S-1040"
			EndIf

			aAdd( aBotoes, { 'CPARAM', { || GpFltBldExp( "SR6" , NIL , @cExp1050 , NIL ) } , "Filtro S-1050", "Filtro S-1050" }) //"Filtro S-1050"
		EndIf

		If( cVersEnvTr >= "2.3" )
			aAdd( aBotoes, { 'CPARAM',  { || fSisParam(aCheck) }, STR0169, STR0169 } ) // 'Parâmetros S-2200'
			aAdd( aBotoes, { 'CPARAM',  { || fSisParam(aCheck,cVersEnvTr, "S-2300") }, STR0185, STR0185 } ) // 'Parâmetros S-2300'
		Else
			aAdd( aBotoes, { 'CPARAM',  { || fSisParam(aCheck) }, STR0147, STR0147 } )// 'Parâmetros S-2100'
		EndIf

		aAdd( aBotoes, { 'CPARAM', { || Pergunte('GPM023XML') }, "Parâmetros grav. XML", "Parâmetros grav. XML" }) //"Parâmetros grav. XML"

		If lOpeSoc .And. lNewVerEsoc .And. !lMiddleware
			aAdd( aBotoes, { 'CPARAM',  { || fSisParam(aCheck,cVersEnvTr, "S-2400") }, STR0292, STR0292 } ) // 'Parâmetros S-2400'
			aAdd( aBotoes, { 'CPARAM',  { || fSisParam(aCheck,cVersEnvTr, "S-2410") }, STR0293, STR0293 } ) // 'Parâmetros S-2410'
		Endif

		ACTIVATE MSDIALOG oDlgEven CENTERED ON INIT EnchoiceBar(oDlgEven, bOK ,bFecha, , aBotoes )

	Else
		nOpcX := 1
		dDataRef := aInfoAut[1]
		cProcesso := aInfoAut[2]
		aCheck := aInfoAut[3]
		aArrayFil := aInfoAut[4]

	EndIf

	If !lMiddleware
		RestArea(aAreaCR9)
	Endif

	//Fecha arquivo temporario de trabalho
	If Select(cAliasTRB) > 0
		(cAliasTRB)->(dbCloseArea())
	EndIf

	If oTmpTbl <> Nil
		oTmpTbl:Delete()
		oTmpTbl := Nil
	Endif

	//Se opcao Confirma e validado efetua as integracoes com TAF
	If nOpcX == 1
		If aCheck[6]
			if Empty(cFilAte) .And. Empty(cMatAte)
				If( cVersEnvTr >= "2.3" )
					Aviso(OemToAnsi(STR0036), OemToAnsi(STR0175), {OemToAnsi(STR0059)}) //"Atencao"##""Necessário preencher os parametros  para Integração de Funcionários (S-2200). Disponível em Outras Ações/Ações Relacionadas."##"Ok"
					Return()
				Else
					Aviso(OemToAnsi(STR0036), OemToAnsi(STR0162), {OemToAnsi(STR0059)}) //"Atencao"##"Opção disponível apenas quando selecionada a carga inicial do evento S-2100."##"Ok"
					Return()
				EndIf
			Endif
		Endif
		If lNewVerEsoc .And. aCheck[8] .And. (Empty(cFilAte) .Or. Empty(cCCAte) .Or. Empty(cNomeAte) .Or. Empty(cMatAte))
			Aviso(OemToAnsi(STR0036), OemToAnsi(STR0300), {OemToAnsi(STR0059)}) //"Atencao"##"Necessário preencher os parametros para Integração de Beneficiários (S-2400). Disponível em Outras Ações/Ações Relacionadas."##"Ok"
			Return()
		EndIf

		If !lMiddleware
			Processa({|lEnd| fGp23Pro(aArrayFil, aCheck, dDataRef, cProcesso,,)}, OemToAnsi(STR0001) ) //##"Envio de Eventos - TAF"
		Else
			Processa({|lEnd| fGp23Pro(aArrayFil, aCheck, dDataRef, cProcesso,,,)}, OemToAnsi(STR0264) ) //##"Envio de Eventos - Middleware

		Endif
	EndIf

	RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fGp23ChBx³ Autor ³ Alessandro Santos     ³ Data ³ 22/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Realiza a criacao dos objetos TCheckBox                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oDlgEven - Tela onde serao criados os objetos              ³±±
±±³          ³ aPosObj  - Dimensoes da tela                               ³±±
±±³          ³ aCheck   - Array para controle de selecao dos eventos      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fGp23ChBx(oDlgEven, aPosObj, aCheck, cVersEnvTr)

Local oGroup, oCheck1, oCheck2, oCheck3, oCheck4, oCheck5, oCheck6, oCheck7, oCheck8, oCheck9, oCheck10, oCheckAll
Local lChkAll	:= .F.
Local oBLink1		:= Nil
Local oBLink2		:= Nil
Local oBLink3		:= Nil
Local oBLink4		:= Nil
Local oBLink5		:= Nil
Local oBLink6		:= Nil
Local oBLink7		:= Nil
Local oBLink8		:= Nil
Local oBLink9		:= Nil
Local oBLink10		:= Nil

//Grupo financeiro/faturamento
oGroup := TGROUP():New(aPosObj[1, 1] + 30, aPosObj[1, 2] + 5, aPosObj[1, 3]+17, aPosObj[1, 4], OemToAnsi(STR0124), oDlgEven, CLR_BLUE,, .T.) //#"Eventos"

//CheckBoxes
//Lado esquerdo da tela
oCheck1 := TCheckBox():New(aPosObj[1, 1] + 45, aPosObj[1, 2] + 10, OemtoAnsi(STR0017)+" "+OemtoAnsi(STR0025), {|| aCheck[1]}, oGroup, 250, 10,, {|| aCheck[1] := !aCheck[1]},,,,,, .T.,,,) 	//##"S-1005"##"Estabelecimentos/Obras"
oBLink1 := TButton():New( aPosObj[1, 1] + 45, aPosObj[1, 2] + 100, OemToAnsi("?"),oDlgEven,{|| ShellExecute("open","http://tdn.totvs.com/x/Agc4Fw","","",1) }, 7,7,,,.F.,.T.,.F.,,.F.,,,.F. )
oCheck2 := TCheckBox():New(aPosObj[1, 1] + 57, aPosObj[1, 2] + 10, OemtoAnsi(STR0012)+" "+OemtoAnsi(STR0020), {|| aCheck[2]}, oGroup, 250, 10,, {|| aCheck[2] := !aCheck[2]},,,,,, .T.,,,) 	//##"S-1010"##"Rubricas"
oBLink2 := TButton():New( aPosObj[1, 1] + 57, aPosObj[1, 2] + 100, OemToAnsi("?"),oDlgEven,{|| ShellExecute("open","http://tdn.totvs.com/x/cQk4Fw","","",1) }, 7,7,,,.F.,.T.,.F.,,.F.,,,.F. )
oCheck3 := TCheckBox():New(aPosObj[1, 1] + 69, aPosObj[1, 2] + 10, OemtoAnsi(STR0013)+" "+OemtoAnsi(STR0021), {|| aCheck[3]}, oGroup, 250, 10,, {|| aCheck[3] := !aCheck[3]},,,,,, .T.,,,) 	//##"S-1020"##"Lotações Tributárias"
oBLink3 := TButton():New( aPosObj[1, 1] + 69, aPosObj[1, 2] + 100, OemToAnsi("?"),oDlgEven,{|| ShellExecute("open","http://tdn.totvs.com/x/Two4Fw","","",1) }, 7,7,,,.F.,.T.,.F.,,.F.,,,.F. )

//Lado direito da tela
oCheck4 := TCheckBox():New(aPosObj[1, 1] + 45, aPosObj[1, 4] /4 + 10, OemtoAnsi(STR0014)+" "+OemtoAnsi(STR0022), {|| aCheck[4]}, oGroup, 250, 10,, {|| aCheck[4] := !aCheck[4]},,,,,, .T.,,,) 	//##"S-1030"##"Cargos"
oBLink4 := TButton():New( aPosObj[1, 1] + 45, aPosObj[1, 4] /4 + 210, OemToAnsi("?"),oDlgEven,{|| ShellExecute("open","http://tdn.totvs.com/x/FAs4Fw","","",1) }, 7,7,,,.F.,.T.,.F.,,.F.,,,.F. )
oCheck5 := TCheckBox():New(aPosObj[1, 1] + 57, aPosObj[1, 4] / 4 + 10, OemtoAnsi(STR0016)+" "+OemtoAnsi(STR0024), {|| aCheck[5]}, oGroup, 250, 10,,{|| aCheck[5] := !aCheck[5]},,,,,, .T.,,,) 	//##"S-1050"##"Horários/Turnos de Trabalho"
oBLink5 := TButton():New( aPosObj[1, 1] + 57, aPosObj[1, 4] /4 + 210, OemToAnsi("?"),oDlgEven,{|| ShellExecute("open","http://tdn.totvs.com/x/XAw4Fw","","",1) }, 7,7,,,.F.,.T.,.F.,,.F.,,,.F. )

If ( cVersEnvTr >= "2.3" )
	oCheck6 := TCheckBox():New(aPosObj[1, 1] + 69, aPosObj[1, 4] / 4 + 10, OemtoAnsi(STR0170)+" "+OemtoAnsi(STR0171), {|| aCheck[6]}, oGroup, 250, 10,,{|| aCheck[6] := !aCheck[6]},,,,,, .T.,,,) 	//##"S-2200"##"Cadastramento Inicial do Vínculo e Admissão/Ingresso do Trabalhador"
	oBLink6 := TButton():New( aPosObj[1, 1] + 69, aPosObj[1, 4] /4 + 210, OemToAnsi("?"),oDlgEven,{|| ShellExecute("open","http://tdn.totvs.com/x/kwRFFw","","",1) }, 7,7,,,.F.,.T.,.F.,,.F.,,,.F. )
Else
	oCheck6 := TCheckBox():New(aPosObj[1, 1] + 69, aPosObj[1, 4] / 4 + 10, OemtoAnsi(STR0118)+" "+OemtoAnsi(STR0066), {|| aCheck[6]}, oGroup, 250, 10,,{|| aCheck[6] := !aCheck[6]},,,,,, .T.,,,) 	//##"S-2100"##"Cadastramento Inicial do Vinculo"
	oBLink6 := TButton():New( aPosObj[1, 1] + 69, aPosObj[1, 4] /4 + 210, OemToAnsi("?"),oDlgEven,{|| ShellExecute("open","http://tdn.totvs.com/display/public/PROT/3.+Carga+Inicial#cagara_inicial-s2100","","",1) }, 7,7,,,.F.,.T.,.F.,,.F.,,,.F. )
EndIf

//Terceira Coluna
oCheck7 := TCheckBox():New(aPosObj[1, 1] + 45, aPosObj[1, 4] / 1.6 + 10, OemtoAnsi(STR0188)+" "+OemtoAnsi(STR0189), {|| aCheck[7]}, oGroup, 250, 10,, {|| aCheck[7] := !aCheck[7]},,,,,, .T.,,,) 	//##"S-2300"##"Ingresso de Trabalhador Sem Vinculo"
oBLink7 := TButton():New( aPosObj[1, 1] + 45, aPosObj[1, 4] /1.6 + 132, OemToAnsi("?"),oDlgEven,{|| ShellExecute("open","http://tdn.totvs.com/x/JhBFFw","","",1) }, 7,7,,,.F.,.T.,.F.,,.F.,,,.F. )

If lOrgPubSGY
	oCheck8 := TCheckBox():New(aPosObj[1, 1] + 57, aPosObj[1, 4] / 1.6 + 10, OemtoAnsi(STR0178)+" "+OemtoAnsi(STR0179), {|| aCheck[8]}, oGroup, 250, 10,, {|| aCheck[8] := !aCheck[8]},,,,,, .T.,,,) 	//##"S-1035"##"Carreiras Públicas"
	oBLink8 := TButton():New( aPosObj[1, 1] + 57, aPosObj[1, 4] /1.6 + 132, OemToAnsi("?"),oDlgEven,{|| ShellExecute("open","http://tdn.totvs.com/x/7ws4Fw","","",1) }, 7,7,,,.F.,.T.,.F.,,.F.,,,.F. )
EndIf

If lOrgPubRS9 .Or. lCargSQ3
	If !lOrgPubSGY //Caso exista Carreira, alinha abaixo dele, caso contrário, alinha no lugar dele
		oCheck9 := TCheckBox():New(aPosObj[1, 1] + 57, aPosObj[1, 4] / 1.6 + 10, OemToAnsi(STR0197)+" "+OemToAnsi(STR0198), {|| aCheck[9]}, oGroup, 250, 10,, {|| aCheck[9] := !aCheck[9]},,,,,, .T.,,,) 	//##"S-1040"##"Funções e Cargos em Comissão"
		oBLink9 := TButton():New( aPosObj[1, 1] + 57, aPosObj[1, 4] /1.6 + 132, OemToAnsi("?"),oDlgEven,{|| ShellExecute("open","http://tdn.totvs.com/x/3Aw4Fw","","",1) }, 7,7,,,.F.,.T.,.F.,,.F.,,,.F. )
	Else
		oCheck9 := TCheckBox():New(aPosObj[1, 1] + 69, aPosObj[1, 4] / 1.6 + 10, OemToAnsi(STR0197)+" "+OemToAnsi(STR0198), {|| aCheck[9]}, oGroup, 250, 10,, {|| aCheck[9] := !aCheck[9]},,,,,, .T.,,,) 	//##"S-1040"##"Funções e Cargos em Comissão"
		oBLink9 := TButton():New( aPosObj[1, 1] + 69, aPosObj[1, 4] /1.6 + 132, OemToAnsi("?"),oDlgEven,{|| ShellExecute("open","http://tdn.totvs.com/x/3Aw4Fw","","",1) }, 7,7,,,.F.,.T.,.F.,,.F.,,,.F. )
	EndIf
Endif

//Todos os eventos
oCheckAll := TCheckBox():New(aPosObj[1, 3] + 6, aPosObj[1, 2] + 10, OemtoAnsi(STR0127), {|| lChkAll}, oGroup, 150, 10,, {|| fGp23ChAll(@lChkAll, aCheck, oCheck1, oCheck2, oCheck3, oCheck4, oCheck5, oCheck6, oCheck7,oCheck8,oCheck9,oCheck10)},,,,,,,, .T.,,,) 	//##"Todos os eventos"

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fGp34MkBr³ Autor ³ Alessandro Santos     ³ Data ³ 17/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Realiza a criacao do MarkBrowse com informacoes das filiais³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oDlgEven  - Tela onde serao criados os objetos             ³±±
±±³          ³ aPosObj   - Dimensoes da tela                              ³±±
±±³          ³ cAliasTRB - Alias do arquivo temporario                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function fGp23MkBr(oDlgEven, aPosObj, cAliasTRB,aDdsC1E)

Local oMarkFil		:= Nil
Local oChkAll		:= Nil
Local cArq 			:= ""
Local cQryWhere 	:= ""
Local nPos			:= 0
Local aArea		 	:= GetArea()
Local aAreaSM0		:= SM0->(GetArea())
Local aAreaC1E    	:= C1E->(GetArea())
Local aCmpCR9		:= {}
Local cAliasC1E  	:= GetNextAlias()
Local oView 		:= FWViewActive()
Local aStru   		:= {}
Local aCpoBro 		:= {}
Local aSM0    		:= FWLoadSM0(.T.,,.T.)
Local lInverte  	:= .F.
Local lContinua		:= .T.
Local lCR9			:= .F.
Local lChkAll 		:= .F.
Local cMark   		:= GetMark()

Private cCadastro 	:= OemToAnsi(STR0120) //##"Filiais"
Private aRotina	:= {}

Default aDdsC1E := {}
DbSelectArea("CR9")
CR9->(dbSetOrder(3))
CR9->(dbGotop())
While CR9->(!EOF())
	If CR9->CR9_ATIVO == "1"
		Aadd(aCmpCR9, {CR9->CR9_FILIAL,	CR9->CR9_ID, CR9->CR9_CODFIL})
	EndIf
	CR9->(dbSkip())
EndDo

If Len(aCmpCR9) > 0
	lCR9 := .T.
Endif
If FunName() == "GPEM023"
    //Estrutura da tabela temporaria
    Aadd(aStru, {"OK"		, "C", 2						, 0})
    Aadd(aStru, {"FILTAF"	, "C", TamSx3("C1E_FILTAF")[1]	, 0})
    Aadd(aStru, {"NOME"  	, "C", 100						, 0})
    Aadd(aStru, {"CNPJ"  	, "C", TamSx3("CTT_CEI")[1]  	, 0})
    Aadd(aStru, {"DTINI" 	, "C", TamSx3("C1E_DTINI")[1]	, 0})
    Aadd(aStru, {"DTFIN" 	, "C", TamSx3("C1E_DTFIN")[1]	, 0})

    oTmpTbl := FWTemporaryTable():New(cAliasTRB)
    oTmpTbl:SetFields(aStru)
    oTmpTbl:AddIndex( "01", {"FILTAF"} )
    oTmpTbl:Create()
EndIf

//Busca informacoes C1E - Complemento empresas
#IFDEF TOP

	cQryWhere := "%C1E_ATIVO = '1'%"
	//Query para buscar informacoes de processos e varas
	BeginSql alias cAliasC1E
		SELECT
			C1E_FILTAF, C1E_NOME, C1E_DTINI, C1E_DTFIN, C1E_ID,C1E_MATRIZ
		FROM
			%table:C1E% C1E
		WHERE
			%exp:cQryWhere% AND C1E.%notDel%
	EndSql

#ELSE
	cAliasC1E := "C1E"
#ENDIF

//Posiciona no inicio do arquivo
dbSelectArea(cAliasC1E)
(cAliasC1E)->(dbGoTop())

While (cAliasC1E)->(!EOF())
	lContinua := .T.
	If (cAliasC1E)->C1E_MATRIZ == "T"
        lExistMatriz := .T.
    EndIf

	//Validacao DBF
	#IFNDEF TOP
		If (cAliasC1E)->C1E_ATIVO <> "1"
			lContinua := .F.
		EndIf
	#ENDIF

	//Busca CNPJ
	nPos := aScan(aSM0, {|x| x[1] == cEmpAnt .AND. AllTrim(x[2]) == AllTrim((cAliasC1E)->C1E_FILTAF)})
	If (lCR9 .And.  aScan(aCmpCR9, {|x| x[2] == AllTrim((cAliasC1E)->C1E_ID)}) > 0 ) .Or. !lCR9
	    If FunName()=="GPEM023"
                //Alimentando a tabela
                RecLock(cAliasTRB, .T.)
                    (cAliasTRB)->FILTAF := (cAliasC1E)->C1E_FILTAF
                    (cAliasTRB)->NOME   := (cAliasC1E)->C1E_NOME
                    (cAliasTRB)->CNPJ   := IIF(nPos > 0, aSM0[nPos, 18], "")
                    (cAliasTRB)->DTINI  := (cAliasC1E)->C1E_DTINI
                    (cAliasTRB)->DTFIN  := (cAliasC1E)->C1E_DTFIN
                (cAliasTRB)->(MsUnlock())
        Else
            If  aScan(aDdsC1E, Padr((cAliasC1E)->C1E_FILTAF, FWSIZEFILIAL())) == 0
                aAdd(aDdsC1E,Padr((cAliasC1E)->C1E_FILTAF, FWSIZEFILIAL()))
            Endif
        Endif
	Endif
	(cAliasC1E)->(dbSkip())
EndDo
If FunName()=="GPEM023"
    //Definindo a visualização das informacoes
    aCpoBro	:= {{"OK"		,, " "   				, "@!"},;
    			{"FILTAF"	,, "Filial"				, "@!"},;
    			{"NOME"		,, "Nome"				, "@!"},;
    			{"CNPJ"		,, "Cnpj"				, "@R 99.999.999/9999-99"},;
    			{"DTINI"	,, "Dt. Ini. Validade"	, "@!"},;
    			{"DTFIN"	,, "Dt. Fin. Validade"	, "@!"}}

    //Posicionando no inicio da tabela temporaria
    (cAliasTRB)->(dbGoTop())

    //Filiais
    TSay():New(aPosObj[2, 1] + 15, aPosObj[2, 2] + 5, {|| OemToAnsi(STR0120)}, oDlgEven,,, .F., .F., .F., .T., CLR_BLUE,, 45, 10, .F., .F., .F., .F., .F.) //#"Filiais"

    //Criacao do markbrowse
    oMarkFil := MsSelect():New(cAliasTRB, "OK", "", aCpoBro, @lInverte, @cMark, {aPosObj[2, 1] + 25, aPosObj[2, 2] + 8, aPosObj[2, 3] - 20, aPosObj[2, 4]},,,,,{})
    oMarkFil:bMark := {|| fGp23AlSe(cAliasTRB, cMark, oMarkFil, 1, .F.)}

    oCheckAll := TCheckBox():New(aPosObj[2, 3] - 20, aPosObj[2, 2] + 10, OemtoAnsi(STR0128), {|| lChkAll}, oDlgEven, 250, 10,,{|| (lChkAll := !lChkAll, fGp23AlSe(cAliasTRB, cMark, oMarkFil, 2, lChkAll))},,,,,, .T.,,,) 	//##"Todas as filiais"
Endif
#IFDEF TOP
	(cAliasC1E)->(DbCloseArea())
#ENDIF

RestArea(aAreaSM0)
RestArea(aAreaC1E)
RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fGp23AlSe³ Autor ³ Alessandro Santos     ³ Data ³ 17/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tratamento para mudanca de selecao do MsSelect das filiais ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAliasTRB - Alias Utilizado para montar o MsSelect         ³±±
±±³          ³ cMark     - Variavel de controle de selecao                ³±±
±±³          ³ oMarkFil  - Objeto do markbrowse                           ³±±
±±³          ³ nOpc  	 - Marcar 1 ou todas filiais no markbrowse        ³±±
±±³          ³ lChkAll   - Opcao marcar/desmarcar para todas as filiais   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

 Static Function fGp23AlSe(cAliasTRB, cMark, oMarkFil, nOpc, lChkAll)

Local aArea	 := GetArea()

//Seleciona 1 opcao no markbrowse
If nOpc == 1
	RecLock(cAliasTRB, .F.)

	If Marked("OK")
		(cAliasTRB)->OK := cMark
	Else
		(cAliasTRB)->OK := ""
	EndIf

	(cAliasTRB)->(MsUnlock())
Else //Seleciona todas opcoes no markbrowse
	//Posiciona no inicio do arquivo
	(cAliasTRB)->(dbGoTop())

	While (cAliasTRB)->(!EOF())
		RecLock(cAliasTRB, .F.)
			(cAliasTRB)->OK := IIF(lChkAll, cMark, "")
		(cAliasTRB)->(MsUnlock())

		(cAliasTRB)->(dbSkip())
	EndDo

	//Reposiciona no inicio do arquivo
	(cAliasTRB)->(dbGoTop())
EndIf

//Atualiza o MsSelect
oMarkFil:oBrowse:Refresh()

RestArea(aArea)

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fGp23ChAll ³ Autor ³ Alessandro Santos     ³ Data ³ 26/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca/Desmarca todos os eventos para integracao com TAF      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lChkAll - Controla se marca ou desmarca                      ³±±
±±³          ³ aCheck  - Array com os eventos                               ³±±
±±³          ³ oCheck1 - Objeto do evento 1 - S-1005                        ³±±
±±³          ³ oCheck2 - Objeto do evento 2 - S-1010                        ³±±
±±³          ³ oCheck3 - Objeto do evento 3 - S-1020                        ³±±
±±³          ³ oCheck4 - Objeto do evento 4 - S-1030 (Até 2.5)              ³±±
±±³          ³ oCheck5 - Objeto do evento 5 - S-1050 (Até 2.5)              ³±±
±±³          ³ oCheck6 - Objeto do evento 6 - S-2200                        ³±±
±±³          ³ oCheck7 - Objeto do evento 7 - S-2300                        ³±±
±±³          ³ oCheck8 - Objeto do evento 8 - S-1035(2.5)/S-2400(1.0)       ³±±
±±³          ³ oCheck9 - Objeto do evento 9 - S-1040(2.5)/S-2410(1.0)       ³±±
±±³          ³ oCheck10- Objeto do evento 10 - S-1060 (desc)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fGp23ChAll(lChkAll, aCheck, oCheck1, oCheck2, oCheck3, oCheck4, oCheck5,;
							oCheck6, oCheck7,oCheck8,oCheck9,oCheck10)

	//Atualiza check evento atual
	lChkAll := !lChkAll

	If lNewVerEsoc
		//Atualiza checks de todos os eventos
		aCheck[1] := lChkAll
		aCheck[2] := lChkAll
		aCheck[3] := lChkAll
		aCheck[6] := lChkAll
		aCheck[7] := lChkAll

		//Atualiza objetos
		oCheck1:Refresh()
		oCheck2:Refresh()
		oCheck3:Refresh()
		oCheck6:Refresh()
		oCheck7:Refresh()

		If lOpeSoc .And. !lMiddleware
			aCheck[8] := lChkAll
			aCheck[9] := lChkAll
			oCheck8:Refresh()
			oCheck9:Refresh()
		Endif
	Else
		//Atualiza checks de todos os eventos
		aCheck[1] := lChkAll
		aCheck[2] := lChkAll
		aCheck[3] := lChkAll
		aCheck[4] := lChkAll
		aCheck[5] := lChkAll
		aCheck[6] := lChkAll
		aCheck[7] := lChkAll

		//Atualiza objetos
		oCheck1:Refresh()
		oCheck2:Refresh()
		oCheck3:Refresh()
		oCheck4:Refresh()
		oCheck5:Refresh()
		oCheck6:Refresh()
		oCheck7:Refresh()

		If lOrgPubSGY
			aCheck[8] := lChkAll
			oCheck8:Refresh()
		EndIf

		If lOrgPubRS9
			aCheck[9] := lChkAll
			oCheck9:Refresh()
		Endif

	EndIf

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fGp23TdOk  ³ Autor ³ Alessandro Santos     ³ Data ³ 17/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pos-validacao do modelo relativo aos eventuais eSocial.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCompete  - Competencia para geracao dos eventos             ³±±
±±³          ³ cPerIni   - Periodo inicial                                  ³±±
±±³          ³ cPerFim   - Periodo final                                    ³±±
±±³          ³ aCheck    - Array para controle de selecao dos eventos       ³±±
±±³          ³ aArrayFil - Array para armazenar as filiais selecionadas     ³±±
±±³          ³ cAliasTRB - Alias do arquivo temporario                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet = .T. ou .F.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function fGp23TdOk(dDataRef, aCheck, aArrayFil, cAliasTRB, cProcesso)

Local aArea			:= GetArea()
Local nI			:= 0
Local lRet 			:= .T.
Local aCheckAux 	:= aClone(aCheck) //Salva itens selecionados

//Limpa array
aArrayFil := {}

//Validacoes da rotina
Do Case
	Case Empty(dDataRef)  //Vaida data inicial
		MsgStop(OemToAnsi(STR0121)) //##"Necessário preencher a data inicial"
		lRet := .F.
	Case aScan(aCheck, {|x| x}) == 0 //Valida eventos
		MsgStop(OemToAnsi(STR0122)) //##"Necessário selecionar um evento"
		lRet := .F.
	Case cProcesso == STR0074 .AND. !aCheck[5] //##"Tab. Hr. eSocial"
		MsgStop(OemToAnsi(STR0063)) //##"Para opção verificar horários deve-se selecionar o evento H-S-1050 Horários/Turnos de Trabalho"
		lRet := .F.
	OtherWise
		If lRet
			//Adiciona filiais selecionadas
			(cAliasTRB)->(dbGoTop())

			While (cAliasTRB)->(!EOF())
				If !Empty((cAliasTRB)->OK)
					aAdd(aArrayFil, Padr((cAliasTRB)->FILTAF, FWSIZEFILIAL()))
				EndIf

				(cAliasTRB)->(dbSkip())
			EndDo

			//Valida filiais
			If Len(aArrayFil) == 0
				(cAliasTRB)->(dbGoTop())
				MsgStop(OemToAnsi(STR0123)) //##"Necessário selecionar uma filial"
				lRet := .F.
			EndIf
		EndIf
EndCase

//Restaura itens selecionados
aCheck := aClone(aCheckAux)

RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fGp23GrLog ³ Autor ³ Alessandro Santos     ³ Data ³ 22/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua as gavacoes dos logs ocorridos nas cargas dos eventos ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFilEnv  - Filial de envio do evento                         ³±±
±±³          ³ cEvento  - Evento que gerou o log                            ³±±
±±³          ³ cMsgLog  - Mensagem de log                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function fGp23GrLog(cFilEnv, cEvento, cMsgLog, cTpLog)

Local aArea		:= GetArea()

//Efetua a gravacao do log
RecLock("RFU", .T.)
	RFU->RFU_FILIAL := cFilEnv
	RFU->RFU_FUNNAM := FunName()
	RFU->RFU_EVENTO := cEvento
	RFU->RFU_USERID := __cUserId
	RFU->RFU_DATA	:= dDataBase
	RFU->RFU_TIME	:= Time()
	RFU->RFU_LOG 	:= cMsgLog
	RFU->RFU_SOLUCA := ""
	RFU->RFU_TPLOG	:= cTpLog
RFU->(MsUnlock())

RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGp23Pro  ³ Autor ³ Alessandro Santos     ³ Data ³03/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Executas a integracao dos Processos de Integracao com TAF e ³±±
±±³          ³as geracoes de logs.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGp23Pro()                                           	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM023   					                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */

Function fGp23Pro(aArrayFil, aCheck, dDataRef, cProcesso, lImprime,nChamada )

Local aArea			:= GetArea()
Local cPerg1		:= If(Type("cPerg")=="C",cPerg,"GPEM023")
Local nI			:= 0
Local aEvent		:= {}
Local aDados		:= {}
Local aResumo 		:= {}
Local aIncons		:= {}
Local aTitle		:= {}
Local aFilInTaf		:= {}
Local nX			:= 1
Local nE			:= 1
Local nR			:= 1
Local nMatriz		:= 0
Local lMatrizes		:= .F.
Local aFilsAll		:= {}
Local lIntegra		:= .F.
Local lVer2_3		:= SR8->(ColumnPos("R8_TPPROC")) > 0
Local lAntesRJ		:= .F.
Local cVersEnvio	:= ""
Local cVersGPE		:= ""

Local dDataRef 		:= IF(cPerg1 == 'GPEM023',dDataRef,dDataBase) //Data de Referencia
Local nOpca     	:= 0 // Opção de Processamento
Local cMesAno 		:= STRZERO(MONTH(dDataRef), 2) + STRZERO(YEAR(dDataRef), 4)

//Variáveis utilizadas no novo controle de Obras/Lotações e-Social
Local lNovoCTT		:= .F.	//Identifica que está utilizando controle
Local lParcial 		:= .F.	//Variavel de retorno que indica se está utilizando parcialmente o controle
Local lRJs			:= .F.	//Só será considerado o novo controle se lNovoCTT verdadeiro e lParcial for falso
Local lNoFunc		:= .F.	//Se irá solicitar a atualização no log da carga

Local lS1000 		:= .F.
Local cStatus 		:= "-1"

Private aLogProc	:= {}
Private nQtdRJE		:= 0
Private aInfos		:= {}
Private cNrInsc		:= ""
Private cTpInsc		:= ""
Private lMsgRJE		:= .T.
Private lAdmPubl	:= .F.

Default lImprime:= .F.

//Definição do nOPc auxiliar e caso seja exclusão em lote
//remover o aCheck dos trabalhadores
If cPerg1 == 'GPEM023'
	If(cProcesso == STR0114) //"Cargas Iniciais"
		nOpca := 1
	ElseIf(cProcesso == STR0115) //"Rel. Inconsistencias"
		nOpca := 2
	ElseIf(cProcesso == STR0150) //"Limpar Dados"
		nOpca := 3
	ElseIf(cProcesso == STR0216) //"Exclusão em Lote"
		nOpca := 5
		If(aCheck[6] .or. aCheck[7] .Or. (lNewVerEsoc .And. aCheck[8]) )
			//#"A Exclusão em lote, é válido somente para as Tabelas Iniciais." #"Sendo assim, continuaremos o processo sem as opções de trabalhadores"
			Help( ,, 'HELP',,OemToAnsi(STR0217) + CRLF + OemToAnsi(STR0218), 1, 0 )
			aCheck[6] := .F. //TCV
			aCheck[7] := .F. //TSV
			If lNewVerEsoc
				aCheck[8] := .F. //Benef
			EndIf
		EndIf
	EndIf
Else
	nOpc := 2
EndIf

if cProcesso == STR0150 .and. cPerg1 == 'GPEM023'
	nOpca := 3 // exclusao
Endif

//Adiciona titulo para Log
Aadd(aTitle, If(lMiddleware,OemToAnsi(STR0272),OemToAnsi(STR0002))) //##"Monitoramento Envio de Eventos - TAF"#Middleware

If lMiddleware
	Aadd(aDados, PADR("Eventos", 20) + " " + PADR("ITEM/REGISTRO", 65) + " " + PADR("STATUS", 40)) //Cabeçalho de Colunas
Else
	Aadd(aDados, PADR("Eventos", 25) + " " + PADR("ITEM/REGISTRO", 77) + " " + PADR("STATUS", 40)) //Cabeçalho de Colunas
EndIf

//Busca grupos de filiais para envio
fGp23Cons(aFilInTaf, aArrayFil)
fGp23Cons(aFilsAll)

If VldRotTab(aCheck,@aDados,@aEvent)
	AEVAL( aFilsAll, { | aFils  |  IIF (LEN(aFils)>= 4 .And. aFils[4],nMatriz++,)})
	lMatrizes   := IIF(nMatriz > 1 .Or. lMiddleware,.T.,.F.)
	//Efetua cargas iniciais para todas as filiais

	For nI := 1 To Len(aFilInTaf)
		If lMiddleware
			fPosFil( cEmpAnt, aFilInTaf[nI,2] )
			lS1000 := fVld1000( AnoMes(dDataRef), @cStatus,aFilInTaf[nI,2]  )
			If !lS1000
				do Case
					case cStatus == "-1" // nao encontrado na base de dados
						MsgInfo( OemToAnsi(STR0270) + OemToAnsi(STR0249) )
					case cStatus == "1" // nao enviado para o governo
						MsgInfo( OemToAnsi(STR0270) + OemToAnsi(STR0250) )
					case cStatus == "2" // enviado e aguardando retorno do governo
						MsgInfo( OemToAnsi(STR0270) + OemToAnsi(STR0251) )
						Help( ,, 'HELP',, OemToAnsi(STR0251) , 1, 0 )
					case cStatus == "3" // enviado e retornado com erro
						MsgInfo( OemToAnsi(STR0270) + OemToAnsi(STR0252) )
				endcase
				Return()
			Else
				aInfos := fXMLInfos( AnoMes(dDataRef) )
				IF LEN(aInfos) >= 4
					cTpInsc  := aInfos[1]
					lAdmPubl := aInfos[4]
					cNrInsc  := aInfos[2]
				ELSE
					cTpInsc  := ""
					lAdmPubl := .F.
					cNrInsc  := "0"
				ENDIF
			EndIf
		Endif

		//Limpar Dados
		if nOpca == 3
			If FindFunction("fVersEsoc")
				fVersEsoc("S2100", .T.,/**/,/**/,@cVersEnvio)
			Else
				cVersEnvio := "2.2"
			EndIf
			fExclusao(aCheck,aFilInTaf[nI,2],cVersEnvio, aEvent)
		Else

			/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ S-1005 - Estabelecimentos/Obras ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If aScan(aEvent[1][5],{|x| x == xFilial(aEvent[1][2],aFilInTaf[nI][2]) }) == 0
				aAdd(aEvent[1][5], xFilial(aEvent[1][2],aFilInTaf[nI][2]))
				aEvent[1][6]:= .T.
			else
				aEvent[1][6]:= .F.
			EndIf
			If aCheck[1]
				If (lMatrizes .And. aEvent[1][3] == "CCC" )
					aAdd( aDados, "Tabela: "+ aEvent[1][2] +" Empresa\Filial:"  + aFilInTaf[nI][2]+ CRLF + OemToAnsi(STR0221))
					aAdd(aDados, "")
				Else
					lIntegra	:= Iif( FindFunction("fVersEsoc"), fVersEsoc("S1005", .T.,/**/,/**/,@cVersEnvio,@cVersGPE), .F. )
					If Empty(cVersGPE)
						cVersGPE := cVersEnvio
					EndIf
					If nOpca == 2
						cVersEnvio := cVersGPE
					EndIf
					//Se layouts de GPE x TAF forem compatíveis
					If( lIntegra )
						If !IsInCallStack('GPEM035')
							fObraX14(cMesAno,nOpcA,@aLogProc,@aDados, aFilInTaf[nI],dDataRef,cVersEnvio)
							If ((Len(aEvent[1][5])==1 .And. aEvent[1][3] == "CCC" .And. nI==1  ) .Or. aEvent[1][3] == "EEE".Or.;
							( aEvent[1][6] .And. !(aEvent[1][3] $ "CCC/EEE") ))

								lNovoCTT:= FindFunction("fVldObraRJ") .And. fVldObraRJ(@lParcial, .T.)
								lRJs := lNovoCTT .And. !lParcial

								If lRJs .And. FindFunction("fBusPerRJ3") .And. fBusPerRJ3(cMesAno, aFilInTaf[nI], "RJ4", @lAntesRJ)
									If FindFunction("fCarga1005")
										fCarga1005(cMesAno, nOpcA, @aLogProc, @aDados, aFilInTaf[nI], cVersEnvio, cExp1005)
									Else
										lNoFunc := .T.
									Endif
								ElseIf !lRJs .Or. lAntesRJ
									fObraCTT(cMesAno, nOpcA, @aLogProc, @aDados, aFilInTaf[nI], dDataRef, cVersEnvio, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, cExp1005)
								Else
									lNoFunc := .T.
								Endif
							EndIf
						Else
							fObraCTT(cMesAno,nOpcA,@aLogProc,@aDados, aFilInTaf[nI],dDataRef,cVersEnvio)
						Endif
					Else
						//Eventos S-1005             "Não possível realizar a integração do evento, pois os leiautes entre GPE x TAF são incompatíveis."
						aAdd( aDados, PADR(OemToAnsi(STR0124) + " " + OemToAnsi(STR0017), 25) + " " + PADR( OemToAnsi(STR0174), 104) )
						aAdd(aDados, "")
					EndIf

					If lNoFunc
						////Eventos S-1005             "Faltam atualizações necessárias para a carga, novo controle de Obras/Lotações.
						aAdd( aDados, PADR(OemToAnsi(STR0124) + " " + OemToAnsi(STR0017), 25) + " " + PADR( OemToAnsi(STR0229), 104) )
						aAdd(aDados, "")
					Endif

				EndIf
				aEvent[1][6]:= .F.
			EndIf

			/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ S-1010 - Rubricas ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If aScan(aEvent[2][5],{|x| x == xFilial(aEvent[2][2],aFilInTaf[nI][2]) }) == 0
				aAdd(aEvent[2][5], xFilial(aEvent[2][2],aFilInTaf[nI][2]))
				aEvent[2][6]:= .T.
			else
				aEvent[2][6]:= .F.
			EndIf
			If aCheck[2] .And. ((Len(aEvent[2][5])==1 .And. aEvent[2][3] == "CCC" .And. nI==1  ) .Or. aEvent[2][3] == "EEE" .Or.;
							(aEvent[2][6] .And. !(aEvent[2][3] $ "CCC/EEE")  ))
				If (lMatrizes .And. aEvent[2][3] == "CCC" )
					aAdd( aDados, "Tabela: "+ aEvent[2][2] +" Empresa\Filial:"  + aFilInTaf[nI][2]+ CRLF + OemToAnsi(STR0221))
					aAdd(aDados, "")
				Else
					lIntegra	:= Iif( FindFunction("fVersEsoc"), fVersEsoc("S1010", .T.,/**/,/**/,@cVersEnvio,@cVersGPE), .F. )
					If Empty(cVersGPE)
						cVersGPE := cVersEnvio
					EndIf
					If nOpca == 2
						cVersEnvio := cVersGPE
					EndIf

					If( lIntegra )
						fCargRubr(cMesAno, nOpcA, aLogProc, dDataRef, @aDados, aFilInTaf[nI], cVersEnvio, cExp1010)
					Else
						//Eventos S-1010             "Não possível realizar a integração do evento, pois os leiautes entre GPE x TAF são incompatíveis."
						aAdd( aDados, PADR(OemToAnsi(STR0124) + " " + OemToAnsi(STR0012), 25) + " " + PADR( OemToAnsi(STR0174), 104) )
						aAdd(aDados, "")
					EndIf
				EndIf
				aEvent[2][6]:= .F.
			EndIf

			/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ S-1020 - Lotacoes/Departamentos ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If aScan(aEvent[3][5],{|x| x == xFilial(aEvent[3][2],aFilInTaf[nI][2]) }) == 0
				aAdd(aEvent[3][5], xFilial(aEvent[3][2],aFilInTaf[nI][2]))
				aEvent[3][6]:= .T.
			else
				aEvent[3][6]:= .F.
			EndIf
			If aCheck[3] .And. ((Len(aEvent[3][5])==1 .And. aEvent[3][3] == "CCC" .And. nI==1 ) .Or. aEvent[3][3] == "EEE".Or.;
							(aEvent[3][6] .And. !(aEvent[3][3] $ "CCC/EEE")   ))
				If (lMatrizes .And. aEvent[3][3] == "CCC" )
					aAdd( aDados, "Tabela: "+ aEvent[3][2] +" Empresa\Filial:"  + aFilInTaf[nI][2]+ CRLF + OemToAnsi(STR0221))
					aAdd(aDados, "")
				Else
					lIntegra	:= Iif( FindFunction("fVersEsoc"), fVersEsoc("S1020", .T.,/**/,/**/,@cVersEnvio,@cVersGPE), .F. )
					If Empty(cVersGPE)
						cVersGPE := cVersEnvio
					EndIf
					If nOpca == 2
						cVersEnvio := cVersGPE
					EndIf
					//Se layouts de GPE x TAF forem compatíveis
					If( lIntegra )
						//Verificação do novo controle de Obras/Lotações eSocial
						lNovoCTT:= FindFunction("fVldObraRJ") .And. fVldObraRJ(@lParcial, .T.)
						lRJs := lNovoCTT .And. !lParcial

						If lRJs .And. FindFunction("fBusPerRJ3") .And. fBusPerRJ3(cMesAno, aFilInTaf[nI], "RJ3")
							If FindFunction("fCarga1020")
								fCarga1020(cMesAno, nOpcA, @aLogProc, @aDados, aFilInTaf[nI], cVersEnvio, cExp1020)
							Else
								lNoFunc := .T.
							Endif
						ElseIf !lRJs
							fCargLota(cMesAno, nOpcA, @aLogProc, @aDados, aFilInTaf[nI], Nil, cVersEnvio, Nil, Nil, Nil, Nil, Nil, cExp1020)
						Else
							lNoFunc := .T.
						Endif
					Else
						//Eventos S-1020             "Não possível realizar a integração do evento, pois os leiautes entre GPE x TAF são incompatíveis."
						aAdd( aDados, PADR(OemToAnsi(STR0124) + " " + OemToAnsi(STR0013), 25) + " " + PADR( OemToAnsi(STR0174), 104) )
						aAdd(aDados, "")
					EndIf
					If lNoFunc
						////Eventos S-1020             "Faltam atualizações necessárias para a carga, novo controle de Obras/Lotações.
						aAdd( aDados, PADR(OemToAnsi(STR0124) + " " + OemToAnsi(STR0013), 25) + " " + PADR( OemToAnsi(STR0229), 104) )
						aAdd(aDados, "")
					Endif
				EndIf
				aEvent[3][6]:= .F.
			EndIf

			If !lNewVerEsoc
				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ S-1030 - Cargos ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				If aScan(aEvent[4][5],{|x| x == xFilial(aEvent[4][2],aFilInTaf[nI][2]) }) == 0
					aAdd(aEvent[4][5], xFilial(aEvent[4][2],aFilInTaf[nI][2]))
					aEvent[4][6]:= .T.
				else
					aEvent[4][6]:= .F.
				EndIf
				If aCheck[4] .And. ((Len(aEvent[4][5])==1 .And. aEvent[4][3] == "CCC" .And. nI==1 ) .Or. aEvent[4][3] == "EEE".Or.;
								(aEvent[4][6] .And. !(aEvent[4][3] $ "CCC/EEE")   )	)

					If (lMatrizes .And. aEvent[4][3] == "CCC" )
						aAdd( aDados, "Tabela: "+ aEvent[4][2] +" Empresa\Filial:"  + aFilInTaf[nI][2]+ CRLF + OemToAnsi(STR0221))
						aAdd(aDados, "")
					Else
						lIntegra	:= Iif( FindFunction("fVersEsoc"), fVersEsoc("S1030", .T.,/**/,/**/,@cVersEnvio,@cVersGPE), .F. )
						If Empty(cVersGPE)
							cVersGPE := cVersEnvio
						EndIf
						If nOpca == 2
							cVersEnvio := cVersGPE
						EndIf
						//Se layouts de GPE x TAF forem compatíveis
						If (lIntegra)
							If lCargSQ3
								fCargSQ3(cMesAno, nOpcA, @aLogProc, @aDados, aFilInTaf[nI], cVersEnvio,, .T., cExp1030)
							Else
								fCargFunc(cMesAno, nOpcA, @aLogProc, @aDados, aFilInTaf[nI], cVersEnvio, lCargSQ3, cExp1030)
							Endif
						Else
							//Eventos S-1030             "Não possível realizar a integração do evento, pois os leiautes entre GPE x TAF são incompatíveis."
							aAdd( aDados, PADR(OemToAnsi(STR0124) + " " + OemToAnsi(STR0014), 25) + " " + PADR(Iif(lMiddleware, OemToAnsi(STR0273), OemToAnsi(STR0174)), 104) )
							aAdd( aDados, "" )
						EndIf
					EndIf
					aEvent[4][6]:= .F.
				EndIf

				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ S-1035 - Carreiras Públicas ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				If aCheck[8]
					lIntegra	:= Iif( FindFunction("fVersEsoc"), fVersEsoc("S1035", .T.,/**/,/**/,@cVersEnvio,@cVersGPE), .F. )
					If Empty(cVersGPE)
						cVersGPE := cVersEnvio
					EndIf
					If nOpca == 2
						cVersEnvio := cVersGPE
					EndIf

					//Se layouts de GPE x TAF forem compatíveis
					If( lIntegra )
						fCarga1035(cMesAno, nOpcA, aLogProc, dDataRef, @aDados, aFilInTaf[nI], cVersEnvio, cExp1035)
					Else
						//Eventos S-1035             "Não possível realizar a integração do evento, pois os leiautes entre GPE x TAF são incompatíveis."
						aAdd( aDados, PADR(OemToAnsi(STR0124) + " " + OemToAnsi(STR0178), 25) + " " + PADR( OemToAnsi(STR0174), 104) )
						aAdd(aDados, "")
					EndIf
				EndIf

				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ S-1040 - Funções e Cargos em Comissão ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				If aCheck[9]
					lIntegra	:= Iif( FindFunction("fVersEsoc"), fVersEsoc("S1040", .T.,/**/,/**/,@cVersEnvio,@cVersGPE), .F. )
					If Empty(cVersGPE)
						cVersGPE := cVersEnvio
					EndIf
					If nOpca == 2
						cVersEnvio := cVersGPE
					EndIf

					//Se layouts de GPE x TAF forem compatíveis
					If lIntegra
						fCargFunc( cMesAno, nOpcA, @aLogProc, @aDados, aFilInTaf[nI], cVersEnvio, .T., cExp1040 )
					Else
						//Eventos S-1040             "Não possível realizar a integração do evento, pois os leiautes entre GPE x TAF são incompatíveis."
						aAdd( aDados, PADR(OemToAnsi("Eventos S-1040") + " " + OemToAnsi(STR0178), 25) + " " + PADR( OemToAnsi(STR0174), 104) )
						aAdd(aDados, "")
					EndIf
				EndIf

				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ S-1050 - Horarios/Turnos de Trabalho ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				If aCheck[5]
					If (lMatrizes .And. aEvent[5][3] == "CCC" )
						aAdd( aDados, "Tabela: "+ aEvent[5][2] +" Empresa\Filial:"  + aFilInTaf[nI][2]+ CRLF + OemToAnsi(STR0221))
						aAdd(aDados, "")
					Else
						lIntegra	:= Iif( FindFunction("fVersEsoc"), fVersEsoc("S1050", .T.,/**/,/**/,@cVersEnvio,@cVersGPE), .F. )
						If Empty(cVersGPE)
							cVersGPE := cVersEnvio
						EndIf
						If nOpca == 2
							cVersEnvio := cVersGPE
						EndIf
						//Se layouts de GPE x TAF forem compatíveis
						If( lIntegra )
							fCargHorar(cMesAno, nOpcA, @aLogProc, @aDados, aFilInTaf[nI], aFilInTaf, nI, cVersEnvio, cExp1050)
						Else
							//Eventos S-1050             "Não possível realizar a integração do evento, pois os leiautes entre GPE x TAF são incompatíveis."
							aAdd( aDados, PADR(OemToAnsi(STR0124) + " " + OemToAnsi(STR0016), 25) + " " + PADR( OemToAnsi(STR0174), 104) )
							aAdd(aDados, "")
						EndIf
					EndIf
					aEvent[5][6]:= aEvent[5][5]
				EndIf
			EndIf

			/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ S-2100 - Cadastramento Inicial do Vinculo ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If aCheck[6]
				lIntegra	:= Iif( FindFunction("fVersEsoc"), fVersEsoc("S2100", .T.,/**/,/**/,@cVersEnvio,@cVersGPE), .F. )
				If Empty(cVersGPE)
					cVersGPE := cVersEnvio
				EndIf
				If nOpca == 2
					cVersEnvio := cVersGPE
				EndIf

				//Se layouts de GPE x TAF forem compatíveis
				If( lIntegra )
					fCargVI(nOpcA, @aLogProc, dDataRef, @aDados, aFilInTaf, nI, cVersEnvio, nRetifica)
				Else
					If cVersEnvio >= "2.3"
						//Eventos S-2200             "Não possível realizar a integração do evento, pois os leiautes entre GPE x TAF são incompatíveis."
						aAdd(aDados, PADR(OemToAnsi(STR0124) + " " + OemToAnsi(STR0170), 25) + " " + PADR( OemToAnsi(STR0174), 104) )
						aAdd(aDados, "")
					Else
						//Eventos S-2100            "Não possível realizar a integração do evento, pois os leiautes entre GPE x TAF são incompatíveis."
						aAdd(aDados, PADR(OemToAnsi(STR0124) + " " + OemToAnsi(STR0118), 25) + " " + PADR( OemToAnsi(STR0174), 104) )
						aAdd(aDados, "")
					EndIf
				EndIf
			Endif

			/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ S-2300 - Trabalhadores sem Vinculo ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If aCheck[7]
				lIntegra	:= Iif( FindFunction("fVersEsoc"), fVersEsoc("S2300", .T.,/**/,/**/,@cVersEnvio,@cVersGPE), .F. )
				If Empty(cVersGPE)
					cVersGPE := cVersEnvio
				EndIf
				If nOpca == 2
					cVersEnvio := cVersGPE
				EndIf

				//Se layouts de GPE x TAF forem compatíveis
				If( lIntegra )
					fCar2300New(nOpcA, @aLogProc, dDataRef, @aDados, aFilInTaf, nI, cVersEnvio, nRetif2300)
				Else
					//Eventos S-2300             "Não possível realizar a integração do evento, pois os leiautes entre GPE x TAF são incompatíveis."
					aAdd( aDados, PADR(OemToAnsi(STR0124) + " " + OemToAnsi(STR0178), 25) + " " + PADR( OemToAnsi(STR0174), 104) )
					aAdd(aDados, "")
				EndIf
			EndIf

			If lNewVerEsoc .And. lOpeSoc
				//S-2400 - Beneficiários OP
				If aCheck[8]
					lIntegra := Iif( FindFunction("fVersEsoc"), fVersEsoc("S2400", .T.,/**/,/**/,@cVersEnvio,@cVersGPE), .F. )
					If nOpca == 2
						cVersEnvio := cVersGPE
					EndIf

					If( lIntegra ) .And. FindFunction("fCarg2400")
						fCarg2400(nOpcA, @aLogProc, dDataRef, @aDados, aFilInTaf, nI, cVersEnvio)
					EndIf
				EndIf
			EndIf

		Endif

	Next nI
EndIf
If nOpcA == 1 .OR. nOpcA == 5 //Verifica se exibe mensagem sem carga a serem efetuadas
	If Len(aDados) > 1
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Apresenta com Log de carga ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

		For nE := 1 to Len(aDados)
			aResumo := FWTxt2Array( aDados[nE], 131)
			For nR := 1 to Len(aResumo)
				Aadd(aIncons, aResumo[nR])
			Next nR
		Next nE

		aDados := {}

		For nE := 1 To Len(aIncons)
			Aadd( aDados, aIncons[nE] )
		Next nE
		If !lWorkFlow
			fMakeLog({aDados}, aTitle, Nil, Nil, cPerg1, If(lMiddleware,OemToAnsi(STR0271),OemToAnsi(STR0047)), "M", "P",, .F.) //"Log de Ocorrencias - Cargas TAF" //Middleware
		EndIf
	Else
		MsgAlert(OemToAnsi(STR0071)) //##"Não existem informações para serem carregadas"
	EndIf
ElseIf nOpcA == 2  //Imprimir Inconsistencias
	If Len(aLogProc) > 0
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Apresenta com Log de erros ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		aResumo := {}
		aIncons := {}
		For nE := 1 to Len(aLogProc)
			aResumo := FWTxt2Array( aLogProc[nE], 131)
			For nR := 1 to Len(aResumo)
				Aadd(aIncons, aResumo[nR])
			Next nR
		Next nE

		aLogProc := {}

		For nE := 1 To Len(aIncons)
			Aadd( aLogProc, aIncons[nE] )
		Next nE

		If cPerg1 == 'GPEM023'
			fMakeLog({aLogProc}, aTitle, Nil, Nil, cPerg1, If(lMiddleware,OemToAnsi(STR0271),OemToAnsi(STR0047)), "M", "P",, .F.) //"Log de Ocorrencias - Cargas TAF"//Middleware
		Else
			If lImprime
				fMakeLog({aLogProc}, aTitle, Nil, Nil, cPerg1, If(lMiddleware,OemToAnsi(STR0271),OemToAnsi(STR0047)), "M", "P",, .F.)
			Else
				fTrataLog(aLogProc)
			Endif
		Endif
	Else
		MsgAlert(OemToAnsi(STR0070)) //##"Não existem informações para serem impressas"
	EndIf
ElseIf lMiddleware .And. nOpca == 3 .And. nQtdRJE > 0
	MsgInfo( OemToAnsi(STR0267) + AllTrim(Str(nQtdRJE)) + OemToAnsi(STR0268) )     //"Foram excluídos " //" registros."
EndIf

RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGp23Inco ³ Autor ³ Alessandro Santos     ³ Data ³14/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Adiciona informacoes no array para impressao de inconsisten ³±±
±±³          ³cias.                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGp23Inco()                                           	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nTpCarga: 1-Rubricas/2-Lotacao/3-Obras/4-Processo          ³±±
±±³          ³ 5-Portuario                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM023  					                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function fGp23Inco(aLogProc, nTpCarga, cAliasTmp, cMsgLog, lConsulta, aAuxErro)

Local nI      	:= 0
Local nX 		:= 0
Local aCposImp	:= {}
Local aArea		:= GetArea()
Local lRet		:= .T.

Default lConsulta	:= .F.
Default aAuxErro	:= {}

SX3->(dbSetOrder(2))

//Verificacao dos campos inconsistentes de Rubricas
Do Case
	Case nTpCarga == 1 //Rubricas
		//Inicia inconsistencias, SRV ja posicionada
		aAdd(aLogProc, OemToAnsi(STR0044) + OemToAnsi(SRV->RV_COD) + " -> " + OemToAnsi(SRV->RV_DESC)) //##"Verba: "

		aCposImp :=	{"RV_NATUREZ", "RV_DESC", "RV_TIPOCOD", "RV_INCCP", "RV_INCIRF", ;
					 "RV_INCFGTS", "RV_INCSIND", "RV_DSRHE", "RV_MED13", "RV_MEDFER", "RV_MEDAVI"}
	Case nTpCarga == 2 //Lotacoes
		//Inicia inconsistencias, CTT ja posicionada
		aAdd(aLogProc, OemToAnsi(STR0053) + " " + OemToAnsi(CTT->CTT_CUSTO) + " -> " + OemToAnsi(CTT->CTT_DESC01)) //##"Centro de Custo: "

		If CTT->CTT_TPLOT $ "03|04|05|06|07|08|09"
			aCposImp :=	{"CTT_TPLOT", "CTT_FPAS", "CTT_CODTER","CTT_CUSTO", "CTT_TIPO2", "CTT_CEI2"}
		ElseIf CTT->CTT_TPLOT == "02"
			aCposImp :=	{"CTT_TPLOT", "CTT_FPAS", "CTT_CODTER","CTT_CUSTO", "CTT_TIPO2", "CTT_CEI2", "CTT_TPINCT", "CTT_NRINCT", "CTT_TPINPR", "CTT_NRINPR"}
		Else
			aCposImp :=	{"CTT_TPLOT", "CTT_CUSTO"}
		EndIf

	Case nTpCarga == 3 //Estabelecimentos/Obras
		//Inicia inconsistencias, CTT ja posicionada
		aAdd(aLogProc, OemToAnsi(STR0053) + " " + OemToAnsi(CTT->CTT_CUSTO) + " -> " + OemToAnsi(CTT->CTT_DESC01)) //##"Centro de Custo: "

		aCposImp :=	{"CTT_TIPO2", "CTT_CEI2", "CTT_CNAE", "CTT_PERCAC"}

	Case nTpCarga == 5 //Portuarios
		//Inicia inconsistencias, CTT ja posicionada
		aAdd(aLogProc, OemToAnsi(STR0053) + " " + OemToAnsi(CTT->CTT_CUSTO) + " -> " + OemToAnsi(CTT->CTT_DESC01)) //##"Centro de Custo: "

		//Verifica tipo de lotacao
		If (cAliasTmp)->CTT_TPLOT == "08"
			aCposImp :=	{"CTT_NOME", "CTT_TIPO2", "CTT_CEI2", "CTT_PERRAT", "CTT_FAP", "CTT_PERCAC"}
		Else
			aCposImp :=	{"CTT_NOME", "CTT_TIPO", "CTT_CEI", "CTT_PERRAT", "CTT_FAP", "CTT_PERCAC"}
		EndIf

	Case nTpCarga == 6 //Lotações
		//Inicia inconsistencias, RJ3 ja posicionada
		aAdd(aLogProc, OemToAnsi(STR0052) + " " + OemToAnsi(RJ3->RJ3_FILIAL) + " - " + OemToAnsi(RJ3->RJ3_COD)) //##"Filial - Lotação: "

		If RJ3->RJ3_TPLOT $ "03|04|05|06|07|08|09"
			aCposImp :=	{"RJ3_TPLOT", "RJ3_FPAS", "RJ3_TERC","RJ3_COD", "RJ3_TPINSC", "RJ3_NINSCR"}
		ElseIf RJ3->RJ3_TPLOT == "02"
			aCposImp :=	{"RJ3_TPLOT", "RJ3_FPAS", "RJ3_TERC","RJ3_COD", "RJ3_TPINSC", "RJ3_NINSCR", "RJ3_TPINCO", "RJ3_NINSCO", "RJ3_TPINPR", "RJ3_NINSPR"}
		Else
			aCposImp :=	{"RJ3_TPLOT", "RJ3_COD"}
		EndIf
	Case nTpCarga == 7 //Lotacoes
		//Inicia inconsistencias, RJ4 ja posicionada
		aAdd(aLogProc, OemToAnsi(STR0232) + " " + OemToAnsi(RJ4->RJ4_NINSCR) ) //##"Obra Própria: "
		aCposImp :=	{"RJ4_TPINSC", "RJ4_NINSCR"}
EndCase

//Busca as informacoes para cada campo
For nI := 1 To Len(aCposImp)
	If (ValType((cAliasTmp)->(FieldGet(FieldPos(aCposImp[nI])))) $ "C|D" .And. Empty((cAliasTmp)->(FieldGet(FieldPos(aCposImp[nI]))))) .Or.;
		(ValType((cAliasTmp)->(FieldGet(FieldPos(aCposImp[nI])))) == "N" .And. (cAliasTmp)->(FieldGet(FieldPos(aCposImp[nI]))) == 0)

		If SX3->(MsSeek(aCposImp[nI]))
			lRet := .F.
			If !lConsulta
				aAdd(aLogProc, AllTrim(SX3->X3_CAMPO) + " - " + AllTrim(SX3->X3_DESCRIC))
				aAdd(aAuxErro, AllTrim(SX3->X3_CAMPO) + " - " + AllTrim(SX3->X3_DESCRIC) )
				cMsgLog	+= " - " + AllTrim(SX3->X3_CAMPO)
			Endif
		EndIf
	EndIf
Next nI

//Pula linha
aAdd(aLogProc, "")

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGp23InSM0³ Autor ³ Alessandro Santos     ³ Data ³27/05/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Adiciona informacoes no array para impressao de inconsisten ³±±
±±³          ³cias para Sigamat.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGp23InSM0()                                           	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM023  					                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */

Static Function fGp23InSM0(aLogProc, aEstObras, cMsgLog)

Local aArea	 := GetArea()

//Inicia inconsistencias
aAdd(aLogProc, OemToAnsi(STR0086) +  " -> " + aEstObras[8]) //##"Filial"

//Campo tipo vazio
If Empty(aEstObras[1])
	aAdd(aLogProc,  + OemToAnsi(STR0129) + " - " + OemToAnsi(STR0130)) //##"Sigamat" ##"Tipo de Inscrição"
	cMsgLog += " - " + OemToAnsi(STR0130) //##"Tipo de Inscrição"
EndIf

//Campo Cei2 vazio
If Empty(aEstObras[2])
	aAdd(aLogProc,  + OemToAnsi(STR0129) + " - " + OemToAnsi(STR0131)) //##"Sigamat" ##"CEI"
	cMsgLog += " - " + OemToAnsi(STR0131) //##"CEI"
EndIf

//Campo Cnae vazio
If Empty(aEstObras[5])
	aAdd(aLogProc,  + OemToAnsi(STR0129) + " - " + OemToAnsi(STR0135)) //##"Sigamat" ##"Código CNAE"
	cMsgLog += " - " + OemToAnsi(STR0135) //##"Código CNAE"
EndIf

//Campo percentual Rat zerado
If (aEstObras[6]< 1 .OR. aEstObras[6]>3)
	aAdd(aLogProc,  + OemToAnsi(STR0133) + " - " + OemToAnsi(STR0136)) //##"Parâmetro 14" ##"% RAT"
	cMsgLog += " - " + OemToAnsi(STR0136) //##"% RAT"
EndIf

//Campo percentual Acidente de trabalho
If aEstObras[7] == 0
	aAdd(aLogProc,  + OemToAnsi(STR0133) + " - " + OemToAnsi(STR0137)) //##"Parâmetro 14" ##"% Acid. Trab."
	cMsgLog += " - " + OemToAnsi(STR0137)	//##"% Acid. Trab."
EndIf

//Pula linha
aAdd(aLogProc, "")

RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGp23Cons ³ Autor ³ Alessandro Santos     ³ Data ³14/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verificacao se filial para envio ao TAF e consolidada ou    ³±±
±±³          ³descentralizada.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGp23Cons()                                           	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aFilSM0 - Array que recebera as informacoes das filiais.   ³±±
±±³          ³ aComplEmp = Array contendo os complementos de empresas que ³±±
±±³          ³ serao consideradas, se nao for passado serao consideradas  ³±±
±±³          ³ todas.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM023  					                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */

Function fGp23Cons(aFilSM0, aComplEmp,cFilPar, aFilInativ)

Local cFilSM0  		:= ""
Local cFilAntBkp	:= ""
Local aFilCon		:= {}
Local nI      		:= 0
Local nJ			:= 0
Local nPos    		:= 0
Local nPosF			:= 0
Local aIncons  		:= {}
Local aArea			:= GetArea()
Local aAreaSM0		:= SM0->(GetArea())
Local aSM0    		:= {}
Local cCNPJ			:= ""
Local cRaizCNPJ		:= ""
Local lVldCNPJ		:= .F.
Local nCont			:= 0
Local aMatriz		:= {}
Local aMatTaf		:= {}
Local lMatriz       := .F.
Local nPosMat		:= ""

Default aFilSM0 	:= {}
Default aComplEmp 	:= {}
Default cFilPar		:=	""
Default aFilInativ	:= {}

If Empty(_aSM0)
	aSM0 	:= FWLoadSM0(.T.,,.T.)
	_aSM0	:= aClone(aSM0)
Else
	aSM0 	:= aClone(_aSM0)
EndIf

//Caso seja carga inicial ou rotina de periódicos, valida todas as filiais da raiz de CNPJ
//caso contrário, validará apenas a filial passada no segundo parâmetro
If !Empty(aComplEmp) .And. (IsInCallStack("GPEM023") .Or. IsInCallStack("GPEM034"))
	lVldCNPJ := .T.
	For nCont := 1 To Len(aComplEmp)
		If SM0->(dbSeek( cEmpAnt + aComplEmp[nCont] ))
			cCNPJ += SubStr(SM0->M0_CGC, 1, 8)+"/"
		EndIf
	Next nCont
EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Posicoes do Array aFilSM0:	               	 	   	³
³                                              			³
³ 1 - .T. (Consolidado) - .F. (Descentralizado)			³
³ 2 - Filial centralizadora								³
³ 3 - Array contendo as filiais que compoem o grupo		³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	For nI := 1 To Len(aSM0)
		If aSM0[nI, 1] == cEmpAnt //Verifica filiais da empresa corrente
			SM0->(dbSeek( cEmpAnt + aSM0[nI, 2] ))
			If (!lVldCNPJ .And. (Empty(aComplEmp) .Or. aScan(aComplEmp, {|X| X == aSM0[nI, 2]}) > 0)) .Or.;
				(lVldCNPJ .And. SubStr(SM0->M0_CGC, 1, 8) $ cCNPJ)
				If lMiddleware
					cFilSM0 := aSM0[nI, 2]
				Else
					cFilSM0 := fTafGetFil(aSM0[nI,1]+aSM0[nI, 2], aIncons, , .T.)
				Endif
				cRaizCNPJ := SubStr(SM0->M0_CGC, 1, 8)

				//Valida complementos de empresas enviados ou todos se carga inicial
				If (!Empty(cFilSM0) .And. (aScan(aComplEmp,{|X| X == cFilSM0}) > 0 .OR. Len(aComplEmp) == 0)) .Or. (!Empty(cFilSM0) .And. !lVldCNPJ )
					//Adiciona filiais
					nPos := aScan(aFilSM0,{|X| X[2] == cFilSM0})
					if Empty(cFilPar) .And. aSM0[nI, 2] == cFilAnt
						cFilPar         := cFilSM0
					EndIf

					If nPos > 0
						Aadd(aFilSM0[nPos][3], aSM0[nI, 2])
					Else
						If !lMiddleware
							lMatriz := .F.
							If (nPosMat := aScan( aMatTaf, { |x| x[1] == cRaizCNPJ } )) == 0
								aMatriz := TAFGFilMatriz()
								aAdd( aMatTaf, { cRaizCNPJ, aClone(aMatriz) } )
							Else
								aMatriz := aClone(aMatTaf[nPosMat, 2])
							EndIf
							If Len(aMatriz) > 0 .And. (Alltrim(aMatriz[2]) == Alltrim(aSM0[nI,2] ))
								lMatriz := .T.
							Endif
						Else
							lMatriz := If(Findfunction("fVldRJ9"), fVldRJ9(aSM0[nI, 18]),  .T.)
						Endif
						aAdd(aFilSM0, {.T., cFilSM0, {aSM0[nI, 2]}, lMatriz})
					EndIf
				EndIf
			EndIf
		EndIf
	Next nI

	cFilAntBkp := cFilAnt
	//Verificacao Consolidada/Descentralizada
	For nI := 1 To Len(aFilSM0)
		//Se apenas 1 registro, descentralizada
		If Len(aFilSM0[nI, 3]) == 1
			aFilSM0[nI, 1] := .F.
		EndIf
		FOR nJ := 1 TO LEN(aFilSM0[nI, 3])
			cFilAnt := aFilSM0[nI, 3, nJ]
			IF !(SuperGetMv("MV_RHTAF",, .F.) == .T.)
				aAdd(aFilInativ, aFilSM0[nI, 3, nJ])
			ENDIF
		NEXT nJ
	Next nI
	cFilAnt := cFilAntBkp
	aSM0	:= {}

	RestArea(aAreaSM0)
	RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGp23Comp	³ Autor ³ Alessandro Santos     ³ Data ³05/03/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verificacao do compartilhamento das tabelas SPA e SR6 para  ³±±
±±³          ³cargas de horarios.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGp23Comp()                                           	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFilSPA: Filial da SPA - cFilSR6: Filial da SR6            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM023  					                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */

Static Function fGp23Comp(cFilSPA, cFilSR6)

Local lRet 			:= .T.
Local nTamLayEmp 	:= Len(FWCompany()) //Tamanho empresa
Local nTamLayUO	  	:= Len(FWUnitBusiness()) //Tamanho Unidade Organizacional
Local aArea 		:= GetArea()

//Tratamentos para compartilhamentos SPA e SR6
If FWModeAccess("SPA", 1) == "C" .AND. FWModeAccess("SPA", 2) == "C" .AND. FWModeAccess("SPA", 3) == "C" //SPA compartilhada nao trata
	lRet := .T.
ElseIf FWModeAccess("SR6", 1) == "C" .AND. FWModeAccess("SR6", 2) == "C" .AND. FWModeAccess("SR6", 3) == "C" //SR6 compartilhada nao trata
	lRet := .T.
Else
	Do Case
		Case FWModeAccess("SPA", 1) == "E" .AND. FWModeAccess("SPA", 2) == "C" .AND. FWModeAccess("SPA", 3) == "C" //SPA com Empresa exclusiva
			If FWModeAccess("SR6", 1) == "E" //Tratamento empresa
				If Substr(cFilSPA, 1, nTamLayEmp) <> Substr(cFilSR6, 1, nTamLayEmp)
					lRet := .F.
				EndIf
			EndIf
		Case FWModeAccess("SPA", 1) == "E" .AND. FWModeAccess("SPA", 2) == "E" .AND. FWModeAccess("SPA", 3) == "C" //SPA com UO exclusiva
			If FWModeAccess("SR6", 1) == "E" .And. FWModeAccess("SR6", 2) == "C" //Tratamento Empresa
				If Substr(cFilSPA, 1, nTamLayEmp) <> Substr(cFilSR6, 1, nTamLayEmp)
					lRet := .F.
				EndIf
			ElseIf FWModeAccess("SR6", 1) == "E" .And. FWModeAccess("SR6", 2) == "E" //Tratamento Empresa e UO
				If Substr(cFilSPA, 1, nTamLayEmp + nTamLayUO) <> Substr(cFilSR6, 1, nTamLayEmp + nTamLayUO)
					lRet := .F.
				EndIf
			EndIf
		Case FWModeAccess("SPA", 1) == "E" .AND. FWModeAccess("SPA", 2) == "E" .AND. FWModeAccess("SPA", 3) == "E" //SPA totalmente exclusiva
			If FWModeAccess("SR6", 1) == "E" .And. FWModeAccess("SR6", 2) == "C" .And. FWModeAccess("SR6", 3) == "C" //Tratamento Empresa
				If Substr(cFilSPA, 1, nTamLayEmp) <> Substr(cFilSR6, 1, nTamLayEmp)
					lRet := .F.
				EndIf
			ElseIf FWModeAccess("SR6", 1) == "E" .And. FWModeAccess("SR6", 2) == "E" .And. FWModeAccess("SR6", 3) == "C" //Tratamento Empresa e UO
				If Substr(cFilSPA, 1, nTamLayEmp + nTamLayUO) <> Substr(cFilSR6, 1, nTamLayEmp + nTamLayUO)
					lRet := .F.
				EndIf
			ElseIf FWModeAccess("SR6", 1) == "E" .And. FWModeAccess("SR6", 2) == "E" .And. FWModeAccess("SR6", 3) == "E" //Tratamento Empresa, UO e Filial
				If cFilSPA <> cFilSR6
					lRet := .F.
				EndIf
			EndIf
	EndCase
EndIf

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fSisParam   ºAutor  ³Christiane Vieira   º Data ³  11/09/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Habilita a seleção dos filtros de sistema para a carga do  º±±
±±º          ³ evento S-2100.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM023                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fSisParam(aCheck,cVersEnvTr,cEvent)
Local lPode := fAtendeOpc(aCheck,cEvent)

Default aCheck:= {}
Default cVersEnvTr := ""
Default cEvent		:="S-2200"
	If !lPode
		If( cVersEnvTr >= "2.3" )
			If cEvent=="S-2200"
			Aviso(OemToAnsi(STR0036), OemToAnsi(STR0176), {OemToAnsi(STR0059)}) //"Atencao"##"Opção disponível apenas quando selecionada a carga inicial do evento S-2200."##"Ok"
			ElseIf cEvent=="S-2300"
				Aviso(OemToAnsi(STR0036), OemToAnsi(STR0186), {OemToAnsi(STR0059)}) //"Atencao"##"Opção disponível apenas quando selecionada a carga inicial do evento S-2300."##"Ok"
			EndIf
			Return
		Else
			Aviso(OemToAnsi(STR0036), OemToAnsi(STR0149), {OemToAnsi(STR0059)}) //"Atencao"##"Opção disponível apenas quando selecionada a carga inicial do evento S-2100."##"Ok"
			Return
		EndIf
	Endif
	IF cEvent=="S-2200" .Or. cEvent=="S-2400"
		Pergunte("GPEM023",.T.)
		cFilDe		:= MV_PAR01
		cFilAte		:= MV_PAR02
		cCCDe		:= MV_PAR03
		cCCAte		:= MV_PAR04
		cMatDe		:= MV_PAR05
		cMatAte		:= MV_PAR06
		cNomeDe		:= MV_PAR07
		cNomeAte	:= MV_PAR08
		cSituacao 	:= MV_PAR09
		nRetifica	:= Iif( ValType(MV_PAR10) == "N", MV_PAR10, 2)
	ElseIf cEvent=="S-2300"
		Pergunte("GPM02300", .T.)
		cFilDe2300		:= MV_PAR01
		cFilAte2300		:= MV_PAR02
		cCCDe2300		:= MV_PAR03
		cCCAte2300		:= MV_PAR04
		cMatDe2300		:= MV_PAR05
		cMatAte2300		:= MV_PAR06
		cNomeDe2300		:= MV_PAR07
		cNomeAte2300	:= MV_PAR08
		cSit2300		:= MV_PAR09
		cCatEfd2300		:= MV_PAR10
		nRetif2300		:= Iif( ValType(MV_PAR11) == "N", MV_PAR11, 2)
	ElseIf cEvent=="S-2410"
		Pergunte("GPM02410", .T.)
		cFilDe2410		:= MV_PAR01
		cFilAte2410		:= MV_PAR02
		cMatDe2410		:= MV_PAR03
		cMatAte2410		:= MV_PAR04
		cSit2410		:= MV_PAR05
		cDataBen		:= MV_PAR06
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fFiltUsua   ºAutor  ³Christiane Vieira   º Data ³  11/09/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Disponibiliza a opção de criação de filtros de usuário.    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM023                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fFiltUsua(aCheck)
Local lPode := fAtendeOpc(aCheck)

Private cSraFilter	:= ""
Private aRetFiltro	:= {}
Private aFilterExp	:= {}

	If !lPode
		Aviso(OemToAnsi(STR0036), OemToAnsi(STR0149), {OemToAnsi(STR0059)}) //"Atencao"##"Opção disponível apenas quando selecionada a carga inicial do evento S-2100."##"Ok"
		Return
	Endif

	/* Retorne os Filtros que contenham os Alias Abaixo */
	aAdd( aFilterExp , { "FILTRO_ALS" , "SRA"     	, .T. , ".or." } )
	aAdd( aFilterExp , { "FILTRO_ALS" , "SRG"     	, NIL , NIL    } )
	/* Que Estejam Definidos para a Função */
	aAdd( aFilterExp , { "FILTRO_PRG" , FunName() 	, NIL , NIL    } )

	aRetFiltro := FilterBuildExpr( aFilterExp )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fAtendeOpc  ºAutor  ³Christiane Vieira   º Data ³  11/09/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se foi selecionada a opção de carga inicial e se oº±±
±±º          ³ evento S-2100 está selecionado.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM023- GPEM026                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fAtendeOpc(aCheck,cEvent)
Local lRet := .T.

If !aCheck[6] .And. cEvent=='S-2200'
	lRet := .F.
Endif

If !aCheck[7] .And. cEvent=='S-2300'
	lRet := .F.
Endif
Return (lRet)

/*/{Protheus.doc} GrvArqTxt
Grava arquivo XML
@Author	Anderson Costa
@Since 22/07/2015
@Version 1.0
/*/
Function GrvTxtArq(cTexto, cEvento, cCPF)

	Local nHandle		:= 0
	Local cFileTxt		:= ""
	Local cFile			:= ""
	Local cStartPath	:= GetSrvProfString( "StartPath", "" )
	Local lEFDXML		:= SuperGetMV("MV_XMLGPE", .F., .F.)
	Local cDiretorio	:= ""

	Static aFiles		:= {}	// Array com o nome dos arquivos gerados na System

	Default	cEvento		:= ""
	Default	cCPF		:= ""

	Pergunte('GPM023XML',.F.)
	cDiretorio := Alltrim(MV_PAR01)

	If lEFDXML
		//Tratamento para Linux onde a barra eh invertida
		If GetRemoteType() == 2
			If ! Empty( cStartPath ) .And. ( SubStr( cStartPath, Len( cStartPath ), 1 ) <> "/" )
				cStartPath +=	"/"
			EndIf
		Else
			If ! Empty(cStartPath) .And. ( SubStr( cStartPath, Len( cStartPath ), 1 ) <> "\" )
				cStartPath +=	"\"
			EndIf
		EndIf

		cFile    := AllTrim("GPE_XML_Diagnostico_" + DToS(dDataBase) + "_" + StrTran(Time(), ":", "") + Iif( !Empty(cEvento), "_" + cEvento, "") + Iif( ! Empty(cCPF), "_" + cCPF, "") ) + "_" + StrZero(Len(aFiles) + 1, 4) + ".xml"

		If IsBlind()
			cFileTxt := cStartPath+cFile
		Else
			cFileTxt := If(!Empty(cDiretorio),cDiretorio+cFile,cStartPath+cFile)
		EndIf

		nHandle := MsFCreate(cFileTxt)

		If nHandle < 0
			Aviso("Geração de Arquivo Texto", "Não foi possível criar o arquivo: " + cFile + "." + "Erro: " + cValToChar( FError() ), {"Ok"}, 3)
		Else
			Aadd(aFiles, cFile)
			WrtStrTxt(nHandle, XMLFormat(cTexto))
		//	Aviso("Geração de Arquivo Texto","Arquivo: " + cFile + " gerado com sucesso no Diretório: " + cStartPath + ".",{"Ok"},3)
		EndIf

		FClose(nHandle)
	EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fExclusao   ºAutor  ³Marcia Moura        º Data ³  11/09/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exclusao registros TAF                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM023                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fExclusao(aCheck,cFilExc,cVersao,aEvent)

	Local aParam := {}
	Local aRet      := {}
	Local aErros  := {}
	Local nP := 0
	Local aTit :={}
	Local aCheck2 := aCheck
	Local sTipos := ""
	Local aTipos  := {}
	Local cTabMid := ""

	Default aEvento := {}

	If lNewVerEsoc
		aTit:= {"S-1005;","S-1010;","S-1020;","S-2200;","S-2100;","S-2300;"}
	Else
		If cVersao >= "2.3"
			aTit:= {"S-1005;","S-1010;","S-1020;","S-1030;","S-1050;","S-2200;","S-2100;","S-2300;","S-1040;","S-1035;"}
		Else
			aTit:= {"S-1005;","S-1010;","S-1020;","S-1030;","S-1050;","S-2200;","S-2300;","S-1035;","S-1040;"}
		EndIf
	EndIf

	For nP := 1 To Len( aTit )
		If aCheck2[nP]
			sTipos := sTipos + " " + aTit[nP]
			If lMiddleware
				If Len(aEvent) > 0
					cTabMid := aEvent[nP][2]
					Aadd(aTipos,{aTit[nP],cTabMid })
				Endif
			Endif
		Endif
	Next nP

	sTipos := alltrim(substr(stipos,1,(len(sTipos)-1)))

	aParam := {"","","3",sTipos}

	If Len( aErros ) <= 0
		If !lMiddleware
			aRet := TAFAEXCPER( aParam, cFilExc, IsBlind() )
		Else
			aRet := MidEXCPER( aParam, cFilExc, IsBlind(),aTipos )
		Endif
	Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGM23Fil    ºAutor  ³Glaucia Messina     º Data ³  13/06/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carga de string para uso em Query por tabelas envolvidas,  º±±
±±º          ³ a partir das empresas centralizadoras escolhidas na carga  º±±
±±º          ³ TAF                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM023- fCargVI                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGM23Fil(aFilInTaf,nP)

Local aArea		:= GetArea()
Local x			:= 0
Local y			:= 0
Local cFilTOP	:= "%'"
Local cFilDBF	:= ""

For y:=1 to len(aFilInTaf[nP,3])
	cFilTOP += aFilInTaf[nP,3,y]
	cFilDBF += aFilInTaf[nP,3,y] + "|"
	cFilTOP += "','"
Next y

If cFilTOP	=="%'"
	cFilTOP += "'%"
Else
	cFilTOP := SUBSTR(cFilTOP,1,(LEN(cFilTOP)-3))
	cFilTOP += "'%"
EndIf

RestArea(aArea)
Return ({cFilTOP,cFilDBF})


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fTabelas  ³ Autor ³ Alessandro Santos     ³ Data ³03/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Selecionar as tabelas para integracao com o TAF.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fTabelas()  utilizada no GPEM035                       	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM023   					          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function fTabelas()

	Local aArea		:= GetArea()
	Local MvPar
	Local nOpca		:= If(Type('MV_PAR02')=='N',MV_PAR02,2)

	Local cTitulo  := OemtoAnsi(STR0011)
	Local MvParDef := If(IsInCallStack("GPEM035"),"RLEHSVIC","RLCFHEPTVSIC")

	Local lRet     := .T.
	Local lOpt     := .F.
	Local cAlias   := Alias()

	Private aTabelas := {}

	If lNewVerEsoc
		aTabelas := {	"R-" + OemtoAnsi(STR0012) + " " + OemtoAnsi(STR0020)	, ;	//##"S-1010"##"Rubricas"
						"L-" + OemtoAnsi(STR0013) + " " + OemtoAnsi(STR0021)	, ;	//##"S-1020"##"Lotações Tributárias"
						"E-" + OemtoAnsi(STR0017) + " " + OemtoAnsi(STR0025)	, ;	//##"S-1005"##"Estabelecimentos/Obras"
						"S-" + OemtoAnsi("S-2300") + " " + OemtoAnsi(STR0083)	, ;	//##""Trabalhador sem Vínculo de Emprego"
						"V-" + OemtoAnsi("S-2200") + " " + OemtoAnsi(STR0066)	, ;	//##Cadastramento Inicial do Vinculo"
						"I-" + OemtoAnsi(STR0177)								}	//##Sindicatos
	Else
		aTabelas := {	"R-"+OemtoAnsi(STR0012) +" "+OemtoAnsi(STR0020),;//##"S-1010"##"Rubricas"
						"L-"+OemtoAnsi(STR0013) +" "+OemtoAnsi(STR0021),; 	//##"S-1020"##"Lotações Tributárias"
						"E-"+OemtoAnsi(STR0017) +" "+OemtoAnsi(STR0025),; 	//##"S-1005"##"Estabelecimentos/Obras"
						"H-"+OemtoAnsi(STR0016) +" "+OemtoAnsi(STR0024),; 	//##"S-1050"##"Horários/Turnos de Trabalho"
						"S-"+OemtoAnsi("S-2300")+" "+OemtoAnsi(STR0083),; 	//##""Trabalhador sem Vínculo de Emprego"
						"V-"+OemtoAnsi("S-2200")+" "+OemtoAnsi(STR0066),; 	//##Cadastramento Inicial do Vinculo"
						"I-"+OemtoAnsi(STR0177),;						   	//##Sindicatos"
						"C-"+OemtoAnsi(STR0014) +" "+OemtoAnsi(STR0190)}	//##S-1030 ##Cargos
	EndIf

	MvPar:=&(Alltrim(ReadVar())) //Carrega Nome da Variavel do Get em Questao
	mvRet:=Alltrim(ReadVar())	 //Iguala Nome da Variavel ao Nome variavel de Retorno

	//Chama funcao f_Opcoes
	lOpt := f_Opcoes(@MvPar,cTitulo,aTabelas,MvParDef,12,49,.F.)

	If lOpt
		&MvRet :=  MvPar

	else
		lRet := .F.
	EndIf

	dbSelectArea(cAlias) // Retorna Alias
	RestArea(aArea)

Return(lRet)

/*--------------------------------------------------*//*--------------------------------------------------*/
/*/{Protheus.doc} fGp23OrPub
Verifica a existência da tabela SGY e se existem registros na tabela, identificando se o cliente é um órgão público
@author Claudinei Soares
@since 06/12/2017
@version P11
@return lRet, .T. se existirem dados na tabela SGY, .F. se não existem dados na tabela

@example fGp23OrPub()
/*/
Function fGp23OrPub(cTab)

Local aArea	:= GetArea()
Local lRet	:= .F.

Default cTab := "SGY"

If ( cTab == "SGY" )
	If ChkFile("SGY")
		dbSelectArea( "SGY" )
		dbGoTop()
		lRet := SGY->(!EOF())
		RestArea( aArea)
	Endif

Else
	If ChkFile("RS9")
		dbSelectArea( "RS9" )
		dbGoTop()
		lRet := RS9->(!EOF())
		RestArea( aArea)
	Endif
EndIf

Return lRet

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³fVerifVersao 		 ³ Autor ³Renan Borges ³ Data ³08/12/2017³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Exibe versão eSocial                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³                             								 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                         									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL                                                  	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEM023                                                      ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Static Function fVerifVersao()

Local nRecno		:= 0
Local nX			:= 0
Local cTabTemp		:= GetNextAlias()
Local oDlg			:= NIL
Local oTmpTbl		:= Nil
Local oBtBinario	:= NIL


Local aArea			:= GetArea()
Local aStru			:= {}
Local aFieldsBrowse	:= {}
Local aObjSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjCoords	:= {}
Local aAdvSize		:= {}
Local aButtons		:= {}
Local aRetTAF		:= {}
Local aRetGPE		:= {}

Local aLayDspGpe	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Botoes no final do dialogo...                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bSet15	:= {|| nOpcA := 1 , oDlg:End() , oDlg , .T. }
bSet24	:= {|| nOpcA := 2 , oDlg:End() , oDlg , .T. }


//Estrutura da tabela temporaria
Aadd(aStru, {"EVENTO"	, "C", 7	, 0})
Aadd(aStru, {"GPE"  	, "C", 6	, 0})
Aadd(aStru, {"TAF"  	, "C", 6  	, 0})
Aadd(aStru, {"ENVIO" 	, "C", 6	, 0})

oTmpTbl := FWTemporaryTable():New(cTabTemp)
oTmpTbl:SetFields(aStru)
oTmpTbl:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos da MarkBrowse                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFieldsBrowse := {{"EVENTO", 	"","Evento",	""},;
					{"GPE"    , 	"", "GPE" ,	""},;
					{"TAF"   ,	"", "TAF" ,	""},;
					{"ENVIO" , 	"", "Envio" , 	""}	}


If !lNewVerEsoc
	aLayDspGpe := {	"S1005", "S1010", "S1020", "S1030", "S1035", "S1040", "S1050",;
					"S1200", "S1202", "S1210", "S1280", "S1295", "S1298", "S1299",;
					"S1300", "S2100", "S2190", "S2200", "S2205", "S2206", "S2230",;
					"S2250", "S2298", "S2299", "S2300", "S2306", "S2399", "S3000"}
Else
	aLayDspGpe := {	"S1005", "S1010", "S1020", "S1200", "S1202", "S1210", "S1280", ;
					"S1295", "S1298", "S1299", "S1300", "S2100", "S2190", "S2200", ;
					"S2205", "S2206", "S2230", "S2250", "S2298", "S2299", "S2300", ;
					"S2306", "S2399", "S3000"}
EndIf

For nx := 1 to Len(aLayDspGpe)
	cVersEnvio := ""
	aRetGPE := {}
	aRetTAF := {}
	If fVersEsoc(aLayDspGpe[nX],.F.,@aRetGPE,@aRetTAF,@cVersEnvio)
	//Efetua a gravacao do log
		RecLock(cTabTemp, .T.)
			(cTabTemp)->EVENTO := aLayDspGpe[nX]
			(cTabTemp)->GPE := aRetGPE[2]
			(cTabTemp)->TAF := aRetTAF[2]
			(cTabTemp)->ENVIO := cVersEnvio
		(cTabTemp)->(MsUnlock())
	EndIf
Next
(cTabTemp)->(dbGoTop())


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdvSize		:= { 0 , 30 , 676 , 299, 1352, 598, 0, 5 }
aInfoAdvSize	:= { 0 , 30 , 676 , 299, 5, 5  }
aAdd( aObjCoords , { 000 , 010 , .F. , .F. } )
aAdd( aObjCoords , { 000 , 100 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

DEFINE FONT oFont  NAME "Arial" SIZE 0,-11 BOLD
DEFINE FONT oFont2 NAME "Arial" SIZE 0,-13 BOLD
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0187) FROM aAdvSize[7], 0 TO aAdvSize[6]-100, aAdvSize[5]-1050 OF GetWndDefault() PIXEL

oDlg:lEscClose := .F. //Nao permite sair ao se pressionar a tecla ESC.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta MarkBrowse...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMsSelect := MsSelect():New(;
								cTabTemp				,;	//Alias	do Arquivo de Filtro
								""		,;	//Campo para controle do mark
								NIL					,;	//Condicao para o Mark
								aFieldsBrowse		,;	//Array com os Campos para o Browse
								NIL					,;	//?
								""			,;	//Conteudo a Ser Gravado no campo de controle do Mark
								{aObjSize[2,1]-10,aObjSize[2,2],aObjSize[2,3]-90,aObjSize[2,4]-520}	,;	//Coordenadas do Objeto
								NIL					,;  //?
								NIL					,;	//?
								oDlg			 ;	//Objeto Dialog
							)
oMsSelect:oBrowse:lHasMark    	:= .F.
oMsSelect:oBrowse:lCanAllMark 	:= .F.
oMsSelect:oBrowse:lAllMark		:= .F.

@ aObjSize[2,3]-70 , aObjSize[2,1]-45 SAY oBtBinario PROMPT "<u>" + OemToAnsi(STR0191) + "</u>" SIZE 300,008 OF oDlg HTML PIXEL
oBtBinario:bLClicked := {|| ShellExecute("open","http://tdn.totvs.com/x/4JQYEw","","",1) }

ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,bSet15,bSet24, Nil , aButtons )  CENTERED

RestArea(aArea)

If oTmpTbl <> Nil
	oTmpTbl:Delete()
	oTmpTbl := Nil
Endif

Return (Nil)

/*/{Protheus.doc} XMLFormat
Formata uma string com tags XML acrescetando quebra de linha e tabulação
@author cicero.pereira
@since 28/06/2018
@return cTextoNovo, String formatada
@param cTextoOrig, characters, String que será formatada
/*/
Function XMLFormat(cTextoOrig)

	Local cTextoNovo := ""
	Local aLinhas    := {}
	Local cEspaco    := ""
	Local nAbriu     := 0
	Local nAtual     := 0

	If ! Empty(cTextoOrig)

		cTextoNovo := StrTran(cTextoOrig, ">" + TAB, ">" + CRLF + TAB)
		cTextoNovo := StrTran(cTextoNovo, "><", ">" + CRLF + "<")

		aLinhas := StrTokArr(cTextoNovo, CRLF)
		cTextoNovo := ""

		// Percorre as linhas adicionando tabulação
		For nAtual := 1 To Len(aLinhas)

			aLinhas[nAtual] := FwCutOff(AllTrim(aLinhas[nAtual])) // Retira TAB e CRLF

			If ! Empty(aLinhas[nAtual])

				// Se for fechamento de tag, diminui a tabulação
				If "</" $ aLinhas[nAtual] .And. At('<', SubStr(aLinhas[nAtual], 2, Len(aLinhas[nAtual]))) == 0
					nAbriu -= 1
				EndIf

				// Definindo a quantidade de espaços em branco, conforme número de tags abertas
				cEspaco := ""
				If nAbriu > 0
					cEspaco := Replicate( TAB, nAbriu)
				EndIf

				// Monta o texto com a tabulação
				cTextoNovo += cEspaco + aLinhas[nAtual] + CRLF

				// Se for abertura de tag, e não for fechamento na mesma linha, aumenta a tabulação
				If "<" $ aLinhas[nAtual] .And. ! "</" $ aLinhas[nAtual] .And. ! "/>" $ aLinhas[nAtual]
					nAbriu += 1
				EndIf
			EndIf
		Next
	EndIf

Return cTextoNovo

/*/{Protheus.doc} GetcFileXML
Retorna o aray aFiles com os nomes dos arquivos gerados na System e redefine essa variável
@author cicero.pereira
@since 28/06/2018
@return _aFiles, Array com o nome dos arquivos gravados na System
/*/
Function GetcFileXML()

	Local _aFiles := aFiles
	aFiles := {}

Return _aFiles


/*/{Protheus.doc} fGp23MidMk
Função:Realiza a criacao do MarkBrowse com informacoes das filiais
@author staguti
@since 21/10/2019
/*/

Function fGp23MidMk(oDlgEven, aPosObj, cAliasTRB )

Local oMarkFil		:= Nil
Local oChkAll		:= Nil
Local cArq 			:= ""
Local cQryWhere 	:= ""
Local aArea		 	:= GetArea()
Local aAreaSM0		:= SM0->(GetArea())
Local aAreaRJ9    	:= RJ9->(GetArea())
Local cAliasRJ9  	:= GetNextAlias()
//Local oView 		:= FWViewActive()
Local aStru   		:= {}
Local aCpoBro 		:= {}
Local aSM0    		:= FWLoadSM0(.T.,,.T.)
Local lInverte  	:= .F.
Local lContinua		:= .T.
Local lChkAll 		:= .F.
Local cMark   		:= GetMark()
Local lOk		 	:= .F.
Local nCont			:= 0

Private cCadastro 	:= OemToAnsi(STR0266) //##"Filiais"
Private aRotina	:= {}

Default cPeriodo := AnoMes(dDatabase)
Default cStatus := "-1"

DbSelectArea("RJ9")
RJ9->(dbSetOrder(5))

    //Estrutura da tabela temporaria
    Aadd(aStru, {"OK"		, "C", 2						, 0})
    Aadd(aStru, {"FILTAF"	, "C", TamSx3("RJ9_FILIAL")[1]	, 0})
    Aadd(aStru, {"NOME"  	, "C", 100						, 0})
    Aadd(aStru, {"CNPJ"  	, "C", TamSx3("RJ9_NRINSC")[1]  	, 0})
    Aadd(aStru, {"DTINI" 	, "C", TamSx3("RJ9_INI")[1]	, 0})

    oTmpTbl := FWTemporaryTable():New(cAliasTRB)
    oTmpTbl:SetFields(aStru)
    oTmpTbl:AddIndex( "01", {"FILTAF"} )
    oTmpTbl:Create()

	For nCont := 1 To Len(aSM0)
		If aSM0[nCont, 1] == cEmpAnt							//SM0_GRPEMP
			RJ9->(dbGoTop())
			If !Empty(aSM0[nCont, 18]) .And. RJ9->( dbSeek( AllTrim( aSM0[nCont, 18] ) ) ) .Or. ( RJ9->(dbSeek( SubStr(aSM0[nCont, 18], 1, 8 ) ) )  .And. RJ9->RJ9_TPINSC == "1" )
				RecLock(cAliasTRB, .T.)
					(cAliasTRB)->FILTAF	:= aSM0[nCont, 2]			//SM0_CODFIL
					(cAliasTRB)->NOME  	:= aSM0[nCont, 7]        	//SM0_NOMRED
					(cAliasTRB)->CNPJ 	:= aSM0[nCont, 18]			//SM0_CGC
					(cAliasTRB)->DTINI  := RJ9->RJ9_INI
				(cAliasTRB)->(MsUnlock())
			Endif
		EndIf
	Next nCont

    //Definindo a visualização das informacoes
    aCpoBro	:= {{"OK"		,, " "   				, "@!"},;
    			{"FILTAF"	,, "Filial"				, "@!"},;
    			{"NOME"		,, "Nome"				, "@!"},;
    			{"CNPJ"		,, "Cnpj"				, "@R 99.999.999/9999-99"},;
    			{"DTINI"	,, "Dt. Ini. Validade"	, "@!"}}

    //Posicionando no inicio da tabela temporaria
    (cAliasTRB)->(dbGoTop())

    //Filiais
    TSay():New(aPosObj[2, 1] + 15, aPosObj[2, 2] + 5, {|| OemToAnsi(STR0269)}, oDlgEven,,, .F., .F., .F., .T., CLR_BLUE,, 45, 10, .F., .F., .F., .F., .F.) //#"Filiais Middleware

    //Criacao do markbrowse
    oMarkFil := MsSelect():New(cAliasTRB, "OK", "", aCpoBro, @lInverte, @cMark, {aPosObj[2, 1] + 25, aPosObj[2, 2] + 8, aPosObj[2, 3] - 20, aPosObj[2, 4]},,,,,{})
    oMarkFil:bMark := {|| fGp23AlSe(cAliasTRB, cMark, oMarkFil, 1, .F.)}

    oCheckAll := TCheckBox():New(aPosObj[2, 3] - 20, aPosObj[2, 2] + 10, OemtoAnsi(STR0128), {|| lChkAll}, oDlgEven, 250, 10,,{|| (lChkAll := !lChkAll, fGp23AlSe(cAliasTRB, cMark, oMarkFil, 2, lChkAll))},,,,,, .T.,,,) 	//##"Todas as filiais"

	RestArea(aAreaSM0)
	RestArea(aAreaRJ9)
	RestArea(aArea)

Return()

//------------------------------------------------------------------
/*/{Protheus.doc} fNewGp23ChBx
Funcao responsavel por montar a tela da carga inicial seguindo o novo leiaute 1.0 do eSocial.

@author		Silvio C. Stecca
@since		20/01/2021
@version	1.0
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data         Programador          Motivo
/*/
//------------------------------------------------------------------
Static Function fNewGp23ChBx(oDlgEven, aPosObj, aCheck, cVersEnvTr)

	Local oGroup, oCheck1, oCheck2, oCheck3, oCheck6, oCheck7,oCheck8,oCheck9, oCheckAll
	Local lChkAll	:= .F.
	Local oBLink1		:= Nil
	Local oBLink2		:= Nil
	Local oBLink3		:= Nil
	Local oBLink6		:= Nil
	Local oBLink7		:= Nil
	Local oBLink8		:= Nil
	Local oBLink9		:= Nil

	//Grupo financeiro/faturamento
	oGroup := TGROUP():New(aPosObj[1, 1] + 30, aPosObj[1, 2] + 5, aPosObj[1, 3]+17, aPosObj[1, 4], OemToAnsi(STR0124), oDlgEven, CLR_BLUE,, .T.) //#"Eventos"

	//CheckBoxes
	//Lado esquerdo da tela
	oCheck1 := TCheckBox():New(aPosObj[1, 1] + 45, aPosObj[1, 2] + 10, OemtoAnsi(STR0017)+" "+OemtoAnsi(STR0025), {|| aCheck[1]}, oGroup, 250, 10,, {|| aCheck[1] := !aCheck[1]},,,,,, .T.,,,) 	//##"S-1005"##"Estabelecimentos/Obras"
	oBLink1 := TButton():New( aPosObj[1, 1] + 45, aPosObj[1, 2] + 100, OemToAnsi("?"),oDlgEven,{|| ShellExecute("open","http://tdn.totvs.com/x/Agc4Fw","","",1) }, 7,7,,,.F.,.T.,.F.,,.F.,,,.F. )
	oCheck2 := TCheckBox():New(aPosObj[1, 1] + 57, aPosObj[1, 2] + 10, OemtoAnsi(STR0012)+" "+OemtoAnsi(STR0020), {|| aCheck[2]}, oGroup, 250, 10,, {|| aCheck[2] := !aCheck[2]},,,,,, .T.,,,) 	//##"S-1010"##"Rubricas"
	oBLink2 := TButton():New( aPosObj[1, 1] + 57, aPosObj[1, 2] + 100, OemToAnsi("?"),oDlgEven,{|| ShellExecute("open","http://tdn.totvs.com/x/cQk4Fw","","",1) }, 7,7,,,.F.,.T.,.F.,,.F.,,,.F. )
	oCheck3 := TCheckBox():New(aPosObj[1, 1] + 69, aPosObj[1, 2] + 10, OemtoAnsi(STR0013)+" "+OemtoAnsi(STR0021), {|| aCheck[3]}, oGroup, 250, 10,, {|| aCheck[3] := !aCheck[3]},,,,,, .T.,,,) 	//##"S-1020"##"Lotações Tributárias"
	oBLink3 := TButton():New( aPosObj[1, 1] + 69, aPosObj[1, 2] + 100, OemToAnsi("?"),oDlgEven,{|| ShellExecute("open","http://tdn.totvs.com/x/Two4Fw","","",1) }, 7,7,,,.F.,.T.,.F.,,.F.,,,.F. )

	If (cVersEnvTr >= "2.3")
		oCheck6 := TCheckBox():New(aPosObj[1, 1] + 45, aPosObj[1, 4] / 4 + 10, OemtoAnsi(STR0170) + " " + OemtoAnsi(STR0171), {|| aCheck[6]}, oGroup, 250, 10,, {||aCheck[6] := !aCheck[6]},,,,,, .T.,,,) 	//##"S-2200"##"Cadastramento Inicial do Vínculo e Admissão/Ingresso do Trabalhador"
		oBLink6 := TButton():New(aPosObj[1, 1] + 45, aPosObj[1, 4] / 4 + 210, OemToAnsi("?"), oDlgEven, {|| ShellExecute("open","http://tdn.totvs.com/x/kwRFFw", "", "", 1)}, 7, 7,,, .F., .T., .F.,, .F.,,, .F.)
	Else
		oCheck6 := TCheckBox():New(aPosObj[1, 1] + 69, aPosObj[1, 4] / 4 + 10, OemtoAnsi(STR0118)+" "+OemtoAnsi(STR0066), {|| aCheck[6]}, oGroup, 250, 10,,{|| aCheck[6] := !aCheck[6]},,,,,, .T.,,,) 	//##"S-2100"##"Cadastramento Inicial do Vinculo"
		oBLink6 := TButton():New( aPosObj[1, 1] + 69, aPosObj[1, 4] /4 + 210, OemToAnsi("?"),oDlgEven,{|| ShellExecute("open","http://tdn.totvs.com/display/public/PROT/3.+Carga+Inicial#cagara_inicial-s2100","","",1) }, 7,7,,,.F.,.T.,.F.,,.F.,,,.F. )
	EndIf

	//Terceira Coluna
	oCheck7 := TCheckBox():New(aPosObj[1, 1] + 57, aPosObj[1, 4] / 4 + 10, OemtoAnsi(STR0188) + " " + OemtoAnsi(STR0189), {|| aCheck[7]}, oGroup, 250, 10,, {|| aCheck[7] := !aCheck[7]},,,,,, .T.,,,) 	//##"S-2300"##"Ingresso de Trabalhador Sem Vinculo"
	oBLink7 := TButton():New(aPosObj[1, 1] + 57, aPosObj[1, 4] /4 + 210, OemToAnsi("?"), oDlgEven, {|| ShellExecute("open", "http://tdn.totvs.com/x/JhBFFw", "", "", 1)}, 7, 7,,, .F., .T., .F.,, .F.,,, .F.)

	If lOpeSoc .And. !lMiddleware
		oCheck8 := TCheckBox():New(aPosObj[1, 1] + 45, aPosObj[1, 4] / 1.6 + 10, OemToAnsi(STR0294), {|| aCheck[8]}, oGroup, 250, 10,, {|| aCheck[8] := !aCheck[8]},,,,,, .T.,,,) 	//##"S-2400 - Cadastro de Beneficiário"
		oBLink8 := TButton():New( aPosObj[1, 1] + 45, aPosObj[1, 4] /1.6 + 132, OemToAnsi("?"),oDlgEven,{|| ShellExecute("open","http://tdn.totvs.com/x/h_GDK","","",1) }, 7,7,,,.F.,.T.,.F.,,.F.,,,.F. )

		oCheck9:= TCheckBox():New(aPosObj[1, 1] + 57, aPosObj[1, 4] / 1.6 + 10, OemToAnsi(STR0295), {|| aCheck[9]}, oGroup, 250, 10,, {|| aCheck[9] := !aCheck[9]},,,,,, .T.,,,) 	//##S-2410 - Cadastro de Benefício"
		//Incluir futuramente oBLink9:= TButton():New( aPosObj[1, 1] + 57, aPosObj[1, 4] /1.6 + 132, OemToAnsi("?"),oDlgEven,{|| ShellExecute("open","http://tdn.totvs.com/x/3Aw4Fw","","",1) }, 7,7,,,.F.,.T.,.F.,,.F.,,,.F. )
	Endif

	//Todos os eventos
	oCheckAll := TCheckBox():New(aPosObj[1, 3] + 6, aPosObj[1, 2] + 10, OemtoAnsi(STR0127), {|| lChkAll}, oGroup, 150, 10,, {|| fGp23ChAll(@lChkAll, aCheck, oCheck1, oCheck2, oCheck3,,, oCheck6, oCheck7,oCheck8,oCheck9,)},,,,,,,, .T.,,,) 	//##"Todos os eventos"

Return()

/*/{Protheus.doc} fSitBenef
Função:Situação do Beneficio
@author Silvia Taguti
@since 23/11/2021
/*/
Function fSitBenef()
	Local aArea		:= GetArea()
	Local cTitulo	:=""
	Local MvPar		:=""
	Local MvParDef	:=""
	Local nTam		:= 0

	Private aSit	:={}

	MvPar:=Rtrim(&(Alltrim(ReadVar())))			 // Carrega Nome da Variavel do Get em Questao
	mvRet:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno
	nTam := Len(&mvRet)

   cTitulo := OemToAnsi(STR0296)

	aSit := {;
				OemToAnsi(STR0297),;	//"1 - Benefício concedido pelo próprio órgão declarante"
				OemToAnsi(STR0298),;	//"2 - Benefício transferido de outro órgão"
				OemToAnsi(STR0299);	//"3 - Mudança de CPF do beneficiário"
			}
	MvParDef:="123"

	IF f_Opcoes(@MvPar,cTitulo,aSit,MvParDef,12,49,.F.)  // Chama funcao f_Opcoes
		&MvRet := mvpar                                                                          // Devolve Resultado
		If nTam > Len(aSit)
			&MvRet += Replicate("*",nTam-Len(aSit))
		EndIf
	EndIf

RestArea(aArea)

Return( .T.)
