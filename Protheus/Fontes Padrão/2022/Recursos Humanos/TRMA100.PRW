#INCLUDE "DBTREE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TRMA100.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "HEADERGD.CH"

//Integracao com o TAF
Static lIntTAF		:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 )
Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Static lGrvGPE		:= .F. //Variável que indica se usuário optou por gravar SÓ no GPE quando leiaute do TAF está divergente.
Static leSocGPE		:= .F. //Indica gravação apenas no GPE por campos sem acesso pelo módulo de origem/nivel do usuário
Static lGp010FimPe	:= ExistBlock("GP010FIMPE")
Static lGpe10Menu 	:= ExistBlock( "GPE10MENU" )
Static lPort1510 	:= Port1510() 	//Verifica se Portaria 1510/2009 esta em vigor.
Static aSocialNiv	:= If( (lIntTAF .Or. lMiddleware) .And. Findfunction("fGM17Nivel"), fGM17Nivel("TRMRSP"), {.F.,""})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa	    ³ TRMA100  ³ Autor ³ Cristina Ogura	   	               ³ Data ³ 12.11.98³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao    ³ Controle dos programas do funcionario					                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programador  ³ Data     ³ Chamado/Req.   ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±³Raquel Hager ³10/07/2014³TPZV24	        ³Inclusao do fonte na Versao 12 - incluindo ³±±
±±³             ³          ³                ³replicas eSocial.		                    ³±±
±±³Raquel Hager ³04/09/2014³TQMIX9          ³Remocao de Fatos Relevantes(922)/ eSocial. ³±±
±±³Renan Borges	³18/09/2014³TQJTST          ³Ajuste para obter pontos de graduação de fa³±±
±±³             ³          ³                ³tores corretamente.                    	³±±
±±³Wagner Mobile³31/10/2014³TQTZG8          ³Ajuste para obter pontos de graduação de fa³±±
±±³             ³          ³                ³tores corretamente quando é alterado para o³±±
±±³             ³          ³                ³grau atual do funcionário.                 ³±±
±±³Christiane V ³02/07/2015³ TSMUY2         ³Adaptações para versão 2.0 do eSocial      ³±±
±±³Raquel Hager ³24/08/2016³TVTOQD          ³Remoção do uso do parâmetro MV_INTTAF para ³±±
±±³             ³          ³                ³release 12.1.7.                            ³±±
±±³Isabel Noguti³08/02/2017³    MRH-3233    ³Ajuste nos nomes dos campos RAL_VALIDAD p/ ³±±
±±³             ³          ³                ³RAL_VALIDA, RAL_FREQUEN para RAL_FREQUE,   ³±±
±±³             ³          ³                ³RBL_DESCRIC para RBL_DESCRI, RA5_VALIDAD p/³±±
±±³             ³          ³                ³RA5_VALIDA, RA5_FREQUEN para RA5_FREQUE e  ³±±
±±³             ³          ³                ³RAI_RESULTA para RAI_RESULT, conforme      ³±±
±±³             ³          ³                ³cadastrados no Atusx.                      ³±±
±±³Esther V.    ³08/05/2017³DRHPONTP-330    ³Incluida validacao de compartilhamento para³±±
±±³             ³          ³                ³tabelas envolvendo campo MATRICULA.        ³±±
±±³Oswaldo L    ³11/09/2017³DRHPONTP-1057   ³Consistir o vinculo entidade e curso       ³±±
±±³Wesley Alves ³17/04/2020|DRHGCH-18695    ³Criação de pontos de chamada para envio    ³±±
±±³Pereira      ³          |                ³de dados por API nos processos de 			³±±
±±³             ³          |                ³inclusão/alteração/deleção de cursos.      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TRMA100()
Local cFiltra		:= ""						//Variavel para filtro
Local aIndFil		:= {}						//Variavel Para Filtro
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca

Default lGpe10Menu	:= ExistBlock( "GPE10MENU" )

Private lOfuscaNom	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ) )
Private bFiltraBrw	:= {|| Nil}				//Variavel para Filtro
Private cCadastro	:= OemToAnsi(STR0001) 	//"Funcionario"
Private aRotina		:= MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

// Adiciona opcoes ao menu
If lGpe10Menu
	ExecBlock("GPE10MENU",.F.,.F.)
EndIf

Private cAltSal := Getmv("MV_ALTSAL")

Private aContRA5  := {} //Variavel utilizada para armazenar os campos que podem ser preenchidos pelo ponto de entrada da tabela RA5
Private aContRA1  := {} //Variavel utilizada para armazenar os campos que podem ser preenchidos pelo ponto de entrada da tabela RA1
Private cContrMat := 	SuperGetMv("MV_MATRICU",NIL,"0")
Private aDep           	// Vetor para armazenar dados dos Dependentes , utilizado qdo nOpc = 7
Private aBenef      	// Vetor para armazenar dados dos Beneficiarios , utilizado qdo nOpc = 7
Private bCheckList	:= {||GenChkLst()}
Private cCodUnico := ""

	// Informa usuário sobre compartilhamento indevido na SRA
	If fR33SRA()
		Return
	EndIf

	If !(ValCompSRA()) //valida compartilhamento entre tabelas
		Return(.F.)
	EndIf

	// Se Portaria estiver ativada, verifica se base esta OK
	If lPort1510
		If !fVerBasePort()
			Break
		EndIf
	EndIf

	// Inicializa o filtro utilizando a funcao FilBrowse
	dbSelectArea("SRA")
	dbSetOrder(1)

	cFiltra 	:= CHKRH(FunName(),"SRA","1")
	bFiltraBrw 	:= {|| FilBrowse("SRA",@aIndFil,@cFiltra) }
	Eval(bFiltraBrw)

	// Endereca a funcao de BROWSE
	dbSelectArea("SRA")
	dbGoTop()

	mBrowse( 6, 1,22,75,"SRA",,,,"SRA->RA_SITFOLH #'D'",,FCriaCor())

	// Deleta o filtro utilizando a funcao FilBrowse
	EndFilBrw("SRA",aIndFil)

	dbSelectArea("SRA")
	dbSetOrder(1)
	SetKey( VK_F6 , { || NIL } )
	//Retorna o SET EPOCH padrao do framework
	If(FindFunction( "RetPadEpoch" ))
		RetPadEpoch()
	EndIf

Return( Nil )

/*/{Protheus.doc} TRM100Rot
Mostra o Tree dos funcionarios
@type  Function
@author Cristina Ogura
@since 12.11.98
@see TRMA100
/*/
Function TRM100Rot(cAlias,nReg,nOpcx)
Local aSaveArea	:= GetArea()
Local oDlgMain
Local oTree
Local cCodCargo	:= ""
Local cCodCC	:= ""
Local aRetGp250 := {}
Local nOpca		:= 0
Local lTrDel	:= If(nOpcx=2.Or.nOpcx=5,.F.,.T.)
Local lVerFat	:= .T.
Local aAC		:= { STR0007,STR0008 } //"Abandona"###"Confirma"
Local cF4 		:= STR0055 				//"<F4> Consulta Teste"
Local aVar		:= {}
Local bSet15	:= { || NIL }
Local bSet24	:= { || NIL }
Local bBotao01	:= {||ViewHist() }
Local nUsado	:= 0
Local nX		:= 0
Local nOrdAux   := 0
// Variaveis para Dimensionar Tela
Local aAdv3Size		:= {}
Local aInfo3AdvSize	:= {}
Local aObj3Size		:= {}
Local aObj3Coords	:= {}
Local lQGint		:= FlQGint() //Integracao Quality
// Variaveis para campos memo (RDY) de usuario
Local aMemoRA4  := {}
Local nLoop	    := 0
Local cQuery := ""

Local cVersGPE		:= ""
Local cVersEnvio	:= ""

Private aAdvSize		:= {}
Private aInfoAdvSize	:= {}
Private aObjSize		:= {}
Private aObjCoords		:= {}
Private aAdv2Size		:= {}
Private aInfo2AdvSize	:= {}
Private aObj2Size		:= {}
Private aObj2Coords		:= {}
Private aAdv4Size		:= {}
Private aInfo4AdvSize	:= {}
Private aObj4Size		:= {}
Private aObj4Coords		:= {}
Private aAdv5Size		:= {}
Private aInfo5AdvSize	:= {}
Private aObj5Size		:= {}
Private aObj5Coords		:= {}
Private aAdv6Size		:= {}
Private aInfo6AdvSize	:= {}
Private aObj6Size		:= {}
Private aObj6Coords		:= {}
Private lObj2	:=  .F.
Private lObj3	:=  .F.
Private lObj4	:=  .F.
Private lObj6	:=  .F.
Private lObj7	:=  .F.
Private lObj8	:=  .F.
Private lObj10	:=  .F.
Private lObj11	:=  .F.
Private a3Alter	:= {}
Private a7Alter	:= {}
Private a9Alter	:= {}
Private lExistRBN	:=.T.
Private nOpcao		:= nOpcx
Private	aListPast	:= array(11)
// Private da Getdados
Private aCols	:= {}
Private aHeader	:= {}
Private Continua:= .F.
// Private do ListBox
Private a1List 	:= {}
Private a2List 	:= {}
Private a9List 	:= {}
Private a10List := {}
Private aSvGetD	:= {}
//Acols original das Habilidades
Private aSaveHabil := {}
//Private para o SXB
Private cGrupo	:= Space(02)
Private oFont1, oFont2
// Controle do Treinamento
Private cAuxFil	:= ""
Private cMat	:= ""
Private cNome	:= ""
Private cEstou	:= "01"
Private cIndo	:= ""
// Private dos objetos da Graduacao
Private o2Get, o2Lbx, o2Group1, o2Group2
Private o2Group3, oSayPCargo, oSayPFunc //	SOMA PONTOS Rodape
// Private dos objetos da Graduacao
Private o3Get, o3Lbx, o3Group1, o3Group2
// Private dos objetos de Documentos
Private o3Bot1
Private	nCalend , nCurso, nData , nTurma
// Private dos objetos do Historico Carreira
Private o4Get, o4Group1
// Private dos objetos do Historico Funcionario
Private o5Group1
// Private dos objetos do Historico ExtraCurriculares
Private o6Get, o6Group1
// Private dos objetos da Solicitacao Treinamento
Private o7Get, o7Group1
// Private dos objetos da Referencia da Graduacao
Private o8Get, o8Group1
// Private dos objetos da Avaliacao
Private o9Get, o9Lbx, o9Group1, o9Group2, o9Bot1, o9Bot2, oF4
Private nPos9 := 1
// Private dos objetos de Habilidades
Private o10Get, o10Lbx, o10Group1, o10Group2
// Private dos objetos de Atividades Funcionais
Private o11Get, o11Group1
// Private para guardar os objetos
Private oAux, oSay12, oGet1
// Private da descricao
Private cGet	:= ""
// Private do Grau de Instrucao do Funcionario
Private cGraduac:= ""
// Private dos objetos da Enchoice
Private aTELA[0][0],aGETS[0]
bCampo := {|nCPO| Field(nCPO) }
//Private do Bloco de Validacao das Informacoes de Historico Salarial
Private bSR7SR3Ok

Private cOldAlias    := GetNextAlias()
Private aOldAliasRA4 := {}
Private aDelAliasRA4 := {}

If lIntTaf .And. FindFunction("fVersEsoc")
	fVersEsoc("S2200", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio,@cVersGPE)
EndIf

If lIntTaf .And. !lMiddleware .And. !lGrvGPE .And. nOpcx <> 2 .And. FindFunction("ESocMsgVer")
	If cVersGPE <> cVersEnvio .And. (cVersGPE >= "9.0" .Or. cVersEnvio >= "9.0")
		//"Atenção! A versão do leiaute GPE é xxx e a do TAF é xxx, sendo assim, estão divergentes. O Evento não será integrado com o TAF, e consequentemente, não será enviado ao RET.
		//Caso prossiga a informação será atualizada somente na base do GPE. Deseja continuar?"
		If ESocMsgVer(.F.,/*cEvento*/, cVersGPE, cVersEnvio)
			lIntTaf := .F.
			lGrvGPE	:= .T.
		Else
			Return
		EndIf
	Endif
EndIf

IF (lIntTaf .Or. lMiddleware) .And. !lGrvGPE .And. nOpcx <> 2 .And. !leSocGPE
	If !(aSocialNiv[1]) .And. aSocialNiv[2]<>""	//"Usuário ou módulo sem acesso aos campos necessários ao eSocial. A informação será atualizada somente na base do GPE, sem integração do evento."
		MsgAlert(aSocialNiv[2],OemToAnsi(STR0118))
		lMiddleware := .F.
		lIntTaf := .F.
		leSocGPE := .T.
	EndIf
Endif

//Private codigo do Posto do funcionario
_SetOwnerPrvt("cOrgCfg", GetMv("MV_ORGCFG", NIL, "0")	)

_SetOwnerPrvt(	"nGetSX8Len"	, GetSX8Len() )

	nX:= GetSx3Cache("RCL_POSTO", "X3_TAMANHO")
	Private cPosto:= IIF(ValType(nX) == "N", Space(nX), Space(9) )
	nX:= 0
	// Verificar se todos os Fatores de Avaliacao (SQ8 e RAF) estao no SQV.
	// Apenas quando for alteracao
	If 	nOpcx == 4
		Processa({||Tr100VerF(@lVerFat,SRA->RA_FILIAL,SRA->RA_MAT)},OemToAnsi(STR0052)) // "Aguarde... Verificando se existem todas as Avaliacoes no Cad. Geral de Avaliacao"
		If !lVerFat
			Help("",1,"Tr100Q8RAF")	// Verifique os fatores de avaliacao no cadastro geral.
		EndIf
	EndIf

	// Obtem Parametros para Selecao de Funcionarios
	aMemoRA4  := If( ExistBlock( "RA4MEM" ), ExecBlock( "RA4MEM", .F.,.F. ), {} )
	// Identifica os campos memos de usuario da tabela RA4
	If !( ValType( aMemoRA4 ) == "A" )
		aMemoRA4	:= {}
	Else
		aMemoRA4	:= 	Aeval(aMemoRA4,{|x| x[1]:= Alltrim(Upper(x[1])), x[2]:= Alltrim(Upper(x[2]))})
	EndIf

	// Salva a integridade dos campos de Bancos de Dados
	If nOpcx == 3
		For nx := 1 TO FCount()
			cCampo := EVAL(bCampo,nx)
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
				M->&(cCampo) := FieldGet(nx)
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
		Next nx

		//Retorna numeracao devido Utilizacao do CriaVar novamente
		If __lSX8
			RollBackSX8()
		EndIf

	Else
		For nx := 1 TO FCount()
			M->&(EVAL(bCampo,nx)) := FieldGet(nx)
		Next nx
	EndIf

	If nOpcx # 3			// Diferente de Inclusao
		cAuxFil		:= SRA->RA_FILIAL
		cMat		:= SRA->RA_MAT
		cNome 		:= SRA->RA_NOME
		cCodCargo	:= fGetCargo(SRA->RA_MAT)
		cCodCC		:= SRA->RA_CC

		// Procura o Grupo a que o funcionario pertence
		dbSelectArea("SQ3")
		dbSetOrder(1)
		If dbSeek(xFilial("SQ3")+cCodCargo+cCodCC) .Or. dbSeek(xFilial("SQ3")+cCodCargo)
			cGrupo := SQ3->Q3_GRUPO
		EndIf
	Else
		cAuxFil		:= CriaVar("RA_FILIAL")
		cMat		:= CriaVar("RA_MAT")
		cNome 		:= CriaVar("RA_NOME")
		cCodCargo	:= CriaVar("RA_CARGO")
		cCodCC		:= CriaVar("RA_CC")
		cGrupo		:= CriaVar("Q3_GRUPO")
	EndIf

	cGet := cMat + " - " + If(lOfuscaNom,Replicate('*',15),cNome)

	//Recupera as solicitacoes de treinamento.
	Tr100obter(7, {}, {},nOpcx,nReg,{})

	If ( nOpcx == 4)  //Alteracao

		cQuery := " SELECT * FROM " + RetSqlName("RA4")
		cQuery += " WHERE RA4_FILIAL = '" +xFilial("RA4")+ "'"
		cQuery += " AND   RA4_MAT    = '" +SRA->RA_MAT+ "'"
		cQuery += " AND " + RetSqlName("RA4") + ".D_E_L_E_T_ = '' "

		cQuery := ChangeQuery(cQuery)

		DBUseArea( .T., "TOPCONN", TcGenQry( , ,cQuery), cOldAlias, .F., .T. )

		DbSelectArea(cOldAlias)
		DbGoTop()

		While (cOldAlias)->(!Eof())

			Aadd(aOldAliasRA4,{(cOldAlias)->R_E_C_N_O_ ,;
							   (cOldAlias)->RA4_CURSO  ,;
							   (cOldAlias)->RA4_SINONI ,;
							   (cOldAlias)->RA4_ENTIDA ,;
							   (cOldAlias)->RA4_DATAIN ,;
							   (cOldAlias)->RA4_DATAFI ,;
							   (cOldAlias)->RA4_NOTA   ,;
							   (cOldAlias)->RA4_VALIDA})

			DbSelectArea(cOldAlias)
			(cOldAlias)->(dbSkip())

		EndDo

		(cOldAlias)->(DbCloseArea())

	EndIf

	// Monta as Dimensoes dos Objetos
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 2 , 2 }
	aAdd( aObjCoords , { 100 , 000 , .T. , .T. } )
	aAdd( aObjCoords , { 300 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords , .T. , .T. )

	aAdv2Size := aClone(aObjSize[2])
	aInfo2AdvSize	:= { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 2 , 2 }
	aAdd( aObj2Coords , { 000 , 20 , .T. , .F. } )
	aAdd( aObj2Coords , { 000 , 50 , .T. , .T. } )
	aAdd( aObj2Coords , { 000 , 50 , .T. , .T. } )
	aAdd( aObj2Coords , { 000 , 20 , .T. , .F. } )
	aObj2Size		:= MsObjSize( aInfo2AdvSize , aObj2Coords )

	aAdv3Size := aClone(aObjSize[2])
	aInfo3AdvSize	:= { aAdv3Size[2] , aAdv3Size[1] , aAdv3Size[4] , aAdv3Size[3] , 2 , 2 }
	aAdd( aObj3Coords , { 000 , 20 , .T. , .F. } )
	aAdd( aObj3Coords , { 000 , 50 , .T. , .T. } )
	aAdd( aObj3Coords , { 000 , 50 , .T. , .T. , .T. } )
	aAdd( aObj2Coords , { 000 , 20 , .T. , .F. } )
	aObj3Size		:= MsObjSize( aInfo3AdvSize , aObj3Coords )

	aAdv4Size := aClone(aObjSize[2])
	aInfo4AdvSize	:= { aAdv4Size[2] , aAdv4Size[1] , aAdv4Size[4] , aAdv4Size[3] , 2 , 2 }
	aAdd( aObj4Coords , { 000 , 20 , .T. , .F. } )
	aAdd( aObj4Coords , { 000 , 000 , .T. , .T. } )
	aAdd( aObj4Coords , { 000 , 000 , .T. , .T. } )
	aObj4Size		:= MsObjSize( aInfo4AdvSize , aObj4Coords )

	aAdv5Size := aClone(aObjSize[2])
	aInfo5AdvSize	:= { aAdv5Size[2] , aAdv5Size[1] , aAdv5Size[4] , aAdv5Size[3] , 2 , 2 }
	aAdd( aObj5Coords , { 000 , 20 , .T. , .F. } )
	aAdd( aObj5Coords , { 000 , 000 , .T. , .T. } )
	aAdd( aObj5Coords , { 000 , 000 , .T. , .T. , .T. } )
	aObj5Size		:= MsObjSize( aInfo5AdvSize , aObj5Coords )

	aAdv6Size := aClone(aObjSize[2])
	aInfo6AdvSize	:= { aAdv6Size[2] , aAdv6Size[1] , aAdv6Size[4] , aAdv6Size[3] , 2 , 2 }
	aAdd( aObj6Coords , { 000 , 20 , .T. , .F. } )
	aAdd( aObj6Coords , { 000 , 000 , .T. , .T. } )
	aObj6Size		:= MsObjSize( aInfo6AdvSize , aObj6Coords )

	DEFINE MSDIALOG oDlgMain FROM	aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cCadastro OF oMainWnd  PIXEL

	@ aObjSize[2][1]+5,aObjSize[2][2]+10 SAY	oSay12 PROMPT	OemToAnsi(STR0009) 	SIZE 20,7 PIXEL		//"Nome: "
	@ aObjSize[2][1]+5,aObjSize[2][2]+60 MSGET oGet1 VAR cGet SIZE 150,8	WHEN .F. PIXEL

	//Cadastro Funcionario - 01
	If nOpcx == 5
		oEnchSRA:= MsMGet():New(cAlias, nReg, nOpcx, aAC,"AC",STR0017,,aObjSize[2], , , , , , , , ,.T. ) //"Quanto a exclusao"
		aGpea010Btn := {}
	Else
		While ( GetSX8Len() > nGetSx8Len )
			RollBackSX8()
		End While

		//Altera o indice da tabela para correta montagem do acols na gdbuilcols quando for visualizacao
		If ( nOpcx == 2 .and. ( nOrdAux := SRA->(RetOrder("SRA", IndexKey()))) != 1  )
			SRA->(dbSetOrder(1))
		EndIf

		Gpea010Mnt( cAlias , nReg , nOpcx , SRA->RA_MAT ,  , oDlgMain, {aObjSize[2]}, lGrvGPE, leSocGPE )

		//Retorna indice antigo caso tenha sido alterado
		If nOpcx == 2 .and. nOrdAux != 1
			SRA->(dbSetOrder(nOrdAux))
		EndIf
	EndIf

   	Tr100List(@a1List,2)

   	////// Graduacao dos Fatores de Avaliacao - 02

 	@ aObj2Size[3][1],aObj2Size[3][2] GROUP o2Group2	TO aObj2Size[3][3],aObj2Size[3][4] LABEL OemtoAnsi(STR0019) OF oDlgMain PIXEL	//" Cargo "
 	@ aObj3Size[3][1],aObj3Size[3][2]+5 LISTBOX o2Lbx FIELDS HEADER	OemtoAnsi(STR0020),;					//"Fator"
												OemtoAnsi(STR0021),;					//"Descricao Fator"
												OemtoAnsi(STR0022),;					//"Grau"
												OemtoAnsi(STR0023),; 					//"Descricao Grau"
												OemtoAnsi(STR0076) SIZE aObj3Size[3][3]-10,aObj3Size[3][4]-30 OF oDlgMain PIXEL		//"Pontos"
	o2Lbx:SetArray(a1List)
	o2Lbx:bLine:= {||{a1List[o2Lbx:nAt,1],a1List[o2Lbx:nAt,2],a1List[o2Lbx:nAt,3],a1List[o2Lbx:nAt,4],Str(a1List[o2Lbx:nAt,5],7,3)}}

	@ aObj2Size[4][1],aObj2Size[4][2] GROUP o2Group3	TO aObj2Size[4][3],aObj2Size[4][4] LABEL OemToAnsi(STR0108) OF oDlgMain PIXEL	//"Totais de Pontos dos Fatores"

	oFont2:= TFont():New(,,,,.T.)

	oSayRodFator	:= TSay():New( aObj2Size[4][1]+10,aObj2Size[4][2]+5,	  {|| OemToAnsi(STR0109)},o2Group3,,oFont2,, ,,.T.,CLR_BLACK,CLR_WHITE,35,7 ) //"Funcionario:"
	oSayPFunc 		:= TSay():New( aObj2Size[4][1]+10,aObj2Size[4][2]+45, {|| " "},o2Group3,,oFont2,, ,,.T.,CLR_BLACK,CLR_WHITE,28,7 )   //Local de Exibicao dos Pontos Funcionario

 	oSayRodCargo	:= TSay():New( aObj2Size[4][1]+10,aObj2Size[4][2]+125, {|| OemToAnsi(STR0110)},o2Group3,, oFont2,,,, .T., CLR_BLACK,CLR_WHITE ) //"Cargo:"
 	oSayPCargo	 	:= TSay():New( aObj2Size[4][1]+10,aObj2Size[4][2]+150, {|| " "},o2Group3,,oFont2,, ,,.T.,CLR_BLACK,CLR_WHITE,28,7 )  //Local de Exibicao dos Pontos Cargo

	///////////////////////////////////////////////////////

	If cModulo == "TRM" .OR. cModulo == "MDT" .OR. lQGint //03

	   	CriaList()

    EndIf

    If cModulo == "CSA" .OR. cModulo == "ORG"  //05
		// Historico Funcionario - SR7
		DEFINE FONT oFont1 NAME "Arial Negrito" SIZE 0, -11

		@ aObj6Size[2][1],aObj6Size[2][2] GROUP o5Group1	TO aObj6Size[2][3],aObj6Size[2][4] LABEL OemtoAnsi(STR0033)    OF oDlgMain  PIXEL 	//" Historico Salarial "

	    // Funcao do GPE
		aRetGp250	:= GPEA250ATU(cAlias , @nReg , 2, {{},{aObj6Size[2][1]+10,aObj6Size[2][2]+5,(aObj6Size[2][3]-5)*0.5,aObj6Size[2][4]-5},{(aObj6Size[2][3]-5)*0.51,aObj6Size[2][2]+5,aObj6Size[2][3]-5,aObj6Size[2][4]-5}}, oDlgMain)
		oGetSR7		:= aRetGp250[1]
		bSR7SR3Ok	:= aRetGp250[2]
		oGetSr3		:= aRetGp250[3]
	EndIf

	If cModulo == "TRM" .OR. cModulo == "MDT" .OR. lQGint //09
		Tr100obter(9, @aHeader, @aCols,nOpcx,nReg,@a9List)
		Tr100RAI(nOpcx)

		// Avaliacao - RAI
		@ aObj4Size[2][1],aObj4Size[2][2] GROUP o9Group1	TO aObj4Size[2][3],aObj4Size[2][4] LABEL OemtoAnsi(STR0054)  OF oDlgMain PIXEL 	//" Avaliacao"
		aHeader := {}
		aCols   := {}

		aHeader := aClone(aSvGetD[1][1])
		If Len(aSvGetD) > 0
			aCols	:= aClone(aSvGetD[1][2])
		EndIf
		n		:= 1
		a9List	:= aClone(aListPast[9][3])
		o9Get   := MSGetDados():New(aObj4Size[2][1]+10,aObj4Size[2][2]+5,aObj4Size[2][3]-5,aObj4Size[2][4]-5,nOpcx,"tr100Ok9","AlwaysTrue","RAI_CALEND,RAI_CURSO,RAI_TURMA,RAI_TESTE,RAI_DURACA,RAI_TIPO,RAI_DTIPO,RAI_MATAVA,RAI_NOMAVA",lTrDel,a9Alter,1,,300,,,,,oDlgMain)
		o9Get:oBrowse:Default()

		DEFINE FONT oFont1 NAME "Arial Negrito" SIZE 0, -11

		@ aObj4Size[3][1],aObj4Size[3][2] SAY oF4 PROMPT cF4 SIZE 70,7 OF oDlgMain FONT oFont1 COLOR CLR_HRED PIXEL 	// F4
		oF4:LVISIBLECONTROL:=.F.
		@ aObj4Size[3][1]+10,aObj4Size[3][2] GROUP o9Group2	TO aObj4Size[3][3],aObj4Size[3][4] LABEL OemtoAnsi(STR0056) OF oDlgMain PIXEL		//"Teste"

        o9Lbx := TWBrowse():New( aObj5Size[3][1]+20,aObj5Size[3][2]+5,aObj5Size[3][3]-10,aObj5Size[3][4]-40 ,,;
        											{	OemtoAnsi(STR0069),;	//"Calendario"
														OemtoAnsi(STR0070),;	//"Desc. Calendario"
														OemtoAnsi(STR0026),;	//"Curso"
														OemtoAnsi(STR0027),;	//"Desc. Curso"
														OemtoAnsi(STR0071),;	//"Turma"
												        OemtoAnsi(STR0056),;	//"Teste"
        												OemtoAnsi(STR0057),;	//"Descricao Teste"
        												OemtoAnsi(STR0058),;	//"Resultado"
        												OemtoAnsi(STR0059),;	//"Situacao"
        												OemtoAnsi(STR0073),;	//"Duracao"
        												OemtoAnsi(STR0074),;	//"Tp.Avaliac."
        												OemtoAnsi(STR0075),;	//"Desc.Tipo Avaliac."
														OemtoAnsi(STR0080),;	//"Avaliador"
        												OemtoAnsi(STR0081)},,;	//"Nome Avaliador"
        												oDlgMain,,,,{|| (nPos9:=o9lbx:nAt,;
        												Tr100AtuGD(nPos9,1))},,,,,,,, .F.,, .T.,, .F.,,, )

		o9Lbx:SetArray(a9List)
		o9Lbx:bLine := { ||  { a9List[o9Lbx:nAt,1],a9List[o9Lbx:nAt,2],a9List[o9Lbx:nAt,3],;
								a9List[o9Lbx:nAt,4],a9List[o9Lbx:nAt,5],a9List[o9Lbx:nAt,6],;
								a9List[o9Lbx:nAt,7],a9List[o9Lbx:nAt,8],a9List[o9Lbx:nAt,9],;
								a9List[o9Lbx:nAt,10],a9List[o9Lbx:nAt,11],a9List[o9Lbx:nAt,12],;
								a9List[o9Lbx:nAt,13],a9List[o9Lbx:nAt,14],;
								}}

        If nOpcx == 3 .OR. nOpcx == 4
            o9Bot1 := SButton():New( aObj4Size[3][3]-15, aObj4Size[3][2]+5, 4, {|| (aVar:=Tr100Listbox(o9lbx:nAt,1),IIF(!Empty(aVar),Tr100Acres(o9lbx:nAt,aVar),))}, oDlgMain, .T.,,)
            o9Bot2 := SButton():New( aObj4Size[3][3]-15, aObj4Size[3][2]+40, 3, {|| (aVar:=Tr100Listbox(o9lbx:nAt,2),IIF(!Empty(aVar),Tr100Acres(o9lbx:nAt,aVar),))}, oDlgMain, .T.,,)
        Else
			o9Bot1 := SButton():New( aObj4Size[3][3]-15, aObj4Size[3][2]+5, 4,, oDlgMain, .F.,,)
            o9Bot2 := SButton():New( aObj4Size[3][3]-15, aObj4Size[3][2]+40, 3,, oDlgMain, .F.,,)
        EndIf
    EndIf

	Tr100List(@a10List,10)

    //10
	@ aObj4Size[3][1],aObj4Size[3][2] GROUP o10Group2	TO aObj4Size[3][3],aObj4Size[3][4] LABEL OemtoAnsi(STR0019) OF oDlgMain PIXEL	//" Cargo "
	@ aObj5Size[3][1]+10,aObj5Size[3][2]+5 LISTBOX o10Lbx FIELDS HEADER	OemtoAnsi(STR0088),;	//"Habilidade"
										OemtoAnsi(STR0100),;		//"Desc. Habil"
										OemtoAnsi(STR0101),;		//"Escala"
										OemtoAnsi(STR0102),;		//"Desc. Escala"
										OemtoAnsi(STR0103),;   		//"Item Escala"
										OemtoAnsi(STR0104) SIZE aObj5Size[3][3]-10,aObj5Size[3][4]-15 OF oDlgMain PIXEL

	o10Lbx:SetArray(a10List)
	o10Lbx:bLine:= {||{a10List[o10Lbx:nAt,1],a10List[o10Lbx:nAt,2],a10List[o10Lbx:nAt,3],a10List[o10Lbx:nAt,4],a10List[o10Lbx:nAt,5],a10List[o10Lbx:nAt,6]}}

	// Monta os Botoes para a EnchoiceBar
	bSet15		:= { ||nOpca := 1,Tr100Principal(cAlias,nReg,nOpcx,oTree,oDlgMain,lTrDel,cF4),If(Tr100TudOk(nOpcx).AND. Gpea010ValPE(nOpcx),oDlgMain:End(),Nil) }
	bSet24		:= { ||nOpca := 0,oDlgMain:End()}

	aadd(aGpea010Btn,{"RELATORIO",bBotao01,	OemtoAnsi(STR0105),	OemtoAnsi(STR0105)}) //"Historico"
	aadd(aGpea010Btn,{"RELATORIO",bCheckList,	"CheckList",	"CheckList"}) //"CheckList"

	DEFINE DBTREE oTree FROM aObjSize[1][1],aObjSize[1][2] TO aObjSize[1][3],aObjSize[1][4] CARGO OF oDlgMain;
		ON CHANGE (Tr100Principal(cAlias,nReg,nOpcx,oTree,oDlgMain,lTrDel,cF4))

	oTree:bValid 		:= {|| Tr100VlTree(nOpcx,1) }
	oTree:lValidLost 	:= .f.
	oTree:lActivated	:= .T.

	DBADDTREE oTree PROMPT OemToAnsi(STR0010)+Space(20);			//"Funcionario"
	RESOURCE "FOLDER5","FOLDER6";
	CARGO "01"
	DBENDTREE oTree

	DBADDTREE oTree PROMPT OemToAnsi(STR0011);						//"Fatores Avaliacao"
	RESOURCE "FOLDER5","FOLDER6";
	CARGO "02"
	DBENDTREE oTree

	If cModulo == "TRM" .OR. cModulo == "MDT" .OR. lQGint
		DBADDTREE oTree PROMPT OemToAnsi(STR0012);					//"Cursos"
		RESOURCE "FOLDER5","FOLDER6";
		CARGO "03"
		DBENDTREE oTree
	EndIf

	DBADDTREE oTree PROMPT OemToAnsi(STR0013);						//"Hist. Carreira"
	RESOURCE "FOLDER5","FOLDER6";
	CARGO "04"
	DBENDTREE oTree

	If cModulo == "CSA" .Or. cModulo == "ORG"
		DBADDTREE oTree PROMPT OemToAnsi(STR0014);						//"Hist. Salarial"
		RESOURCE "FOLDER5","FOLDER6";
		CARGO "05"
		DBENDTREE oTree
    EndIf

	DBADDTREE oTree PROMPT OemToAnsi(STR0015);						//"Hist. Extra Curriculares"
	RESOURCE "FOLDER5","FOLDER6";
	CARGO "06"
	DBENDTREE oTree

	If cModulo == "TRM" .OR. cModulo == "MDT" .OR. lQGint
		DBADDTREE oTree PROMPT OemToAnsi(STR0016);					//"Solicitacao Treinamento"
		RESOURCE "FOLDER5","FOLDER6";
		CARGO "07"
		DBENDTREE oTree
	EndIf

	DBADDTREE oTree PROMPT OemToAnsi(STR0042);							//"Referencia Graduacao"
	RESOURCE "FOLDER5","FOLDER6";
	CARGO "08"
	DBENDTREE oTree

	If cModulo == "TRM" .OR. cModulo == "MDT" .OR. lQGint
		DBADDTREE oTree PROMPT OemToAnsi(STR0053);							//"Avaliacao"
		RESOURCE "FOLDER5","FOLDER6";
		CARGO "09"
		DBENDTREE oTree
	EndIf

	DBADDTREE oTree PROMPT OemToAnsi(STR0087);							//"Habilidades"
	RESOURCE "FOLDER5","FOLDER6";
  	CARGO "10"
	DBENDTREE oTree

	If lExistRBN
		DBADDTREE oTree PROMPT Alltrim(OemToAnsi(STR0093));							//" Atividades Funcionais "
		RESOURCE "FOLDER5","FOLDER6";
	  	CARGO "11"
		DBENDTREE oTree
	EndIf

	cIndo := oTree:GetCargo()

	If cIndo == "01"
		If (cModulo == "CSA" .Or. cModulo == "ORG")
			oGetSR7:oBrowse:lDisablePaint := .T.
		EndIf

		If (cModulo == "CSA" .Or. cModulo == "ORG")
			oGetSr3:oBrowse:lDisablePaint := .T.
		EndIf

		If (cModulo == "TRM" .OR. cModulo == "MDT" .OR. lQGint)
			o9Get:oBrowse:lDisablePaint := .T.
		EndIf
	EndIf

	ACTIVATE MSDIALOG oDlgMain ON INIT  (o2Group2:Hide(),o2Lbx:Hide(),o10Group2:Hide(),o10Lbx:Hide(),;
									TR100FAhide(),;
									If(cModulo=="TRM" .OR. cModulo == "MDT" .OR. lQGint, (o3Group2:Hide(),o3Lbx:Hide()),.T.),;
									If(cModulo=="CSA" .OR. cModulo == "ORG", (o5Group1:Hide(), oGetSR7:Hide(), oGetSR7:oBrowse:Hide(),oGetSr3:Hide(),oGetSr3:oBrowse:Hide()),.T.),;
									If(cModulo=="TRM" .OR. cModulo == "MDT" .OR. lQGint,(o9Group1:Hide(),o9Group2:Hide(), oF4:LVISIBLECONTROL:=.F.,o9Get:Hide(),o9Get:oBrowse:Hide(),o9Lbx:Hide(),o9Bot1:Hide(),o9Bot2:Hide()),.T.),;
  									oSay12:Hide(), oGet1:Hide(),;
  									oAux	:= oEnchSRA,;
									EnchoiceBar(oDlgMain, bSet15, bSet24, NIL , aGpea010Btn),;
									IF(Empty(cPosto), ORGXPosto(oEnchSra), NIL);
									)
	dbSelectArea("SRA")
	dbSetOrder(1)
	dbGoTo(nReg)

	If nOpca == 1

		If nOpcx # 5 .And. nOpcx # 2	// Se nao for Exclusao e visual

			// Rotina de Gravacao do GPE
			Gpea010Put( "SRA" , nOpcx , If(nOpcx==3,Nil,nReg) , nOpcA )

			//Efetuando Gravacao
			MsAguarde( { || Tr100AuxG(),;
			Tr100Grava(nOpcx,aMemoRA4) },;
			OemToAnsi( STR0085 ),;	//"Aguarde!"
			OemToAnsi( IF( nOpcX == 5 , STR0082 , STR0083 ) ),;//"Deletando..."###"Gravando..."
			)

			EvalTrigger()

			If __lSX8
				ConfirmSX8()
			EndIf

			If lGp010FimPe
				ExecBlock("GP010FIMPE",.F.,.F.)
			Endif

		ElseIf nOpcx == 5
			Begin Transaction
				Tr100Dele()
			End Transaction
		EndIf

		If ( nOpcx == 3 .OR. nOpcx == 4 .OR. nOpcx == 5)
			fPrepDadosApi(nOpcx)
		EndIf

	Else
		If __lSX8
			RollBackSX8()
		EndIf
	EndIf

	Release Objects oTree

	RestArea(aSaveArea)

Return( Nil  )

/*/{Protheus.doc} Trm100Principal
Rotina que controla a mudanca nos trees
@type  Static Function
@author Cristina Ogura
@since 12.11.98
@see TRMA100
/*/
Static Function Tr100Principal(cAlias,nReg,nOpcx,oTree,oDlgMain,lTrDel,cF4)
Local lQGint	:= FlQGInt() //Integracao Quality
Local nX		:= 0

	cIndo := oTree:GetCargo()

	// 1- Funcionario
	// 2- Graduacao
	// 3- Cursos
	// 4- Historico Carreira
	// 5- Historico Funcionario
	// 6- Historico Extracurriculares
	// 7- Solicitacao Treinamento
	// 8- Referencia Graduacao
	// 9- Avaliacao
	//10- Habilidades

	Tr100Guarda()
	SetKey( VK_F6 , { || NIL } )
	SetKey( VK_F4 , { || NIL } )
	 aHeader	:={}
	 aCols	 	:={}

	If cIndo == "01"

	 	Iif(cModulo == "CSA" .Or. cModulo == "ORG", oGetSR7:oBrowse:lDisablePaint := .T.,)
		Iif(cModulo == "CSA" .Or. cModulo == "ORG", oGetSr3:oBrowse:lDisablePaint := .T.,)
		Iif(cModulo == "TRM" .OR. cModulo == "MDT" .OR. lQGint, o9Get:oBrowse:lDisablePaint := .T.,)
		oEnchSRA:Show()
		oSay12:Hide()
		oGet1:Hide()
		oAux	:= oEnchSRA

	ElseIf cIndo == "02"
		aHeader	:={}
		aCols 	:={}
		a1List 	:={}
		n	 := 1
		Tr100obter(val(cIndo), @aHeader, @aCols,nOpcx,nReg,@a1List)

	    If !lObj2  // Controle para apenas uma vez a getdados
	       	@ aObj2Size[2][1],aObj2Size[2][2] GROUP o2Group1	TO aObj2Size[2][3],aObj2Size[2][4] LABEL OemtoAnsi(STR0018) OF oDlgMain PIXEL 		//" Funcionario "
	   		n		:= 1
			o2Get   := MSGetDados():New(aObj2Size[2][1]+10,aObj2Size[2][2]+5,aObj2Size[2][3]-5,aObj2Size[2][4]-5,nOpcx,"Tr100Ok2","AlwaysTrue","",lTrDel,,1,,300,,,,	"TR100FASpt",oDlgMain)
			o2Get:oBrowse:Default()
			lObj2:=.T.
		EndIf

		// Monta a getdados novamente qdo altero a funcao
		If SRA->RA_CODFUNC # M->RA_CODFUNC
			aListPast[2]:=Nil
		   	Tr100obter(val(cIndo), @aHeader, @aCols,nOpcx,nReg)
		EndIf

		o2Lbx:SetArray(a1List)
	  	o2Lbx:bLine:= {||{a1List[o2Lbx:nAt,1],a1List[o2Lbx:nAt,2],a1List[o2Lbx:nAt,3],a1List[o2Lbx:nAt,4],Str(a1List[o2Lbx:nAt,5],7,3)}}
		o2Get:oBrowse:lDisablePaint := .F.
		o2Get:Show()
		o2Get:oBrowse:Show()
		o2Get:oBrowse:Refresh(.T.)
		o2Lbx:Show()
		o2Lbx:Refresh(.T.)
		o2Group1:Show()
		o2Group2:Show()
		oSay12:Show()
		oGet1:Show()
		oGet1:cText(cGet)
		oAux	:= o2Get
		TR100FAShow()
		TR100FASpt()	 // Funcao que calcula Pontos Funcionarios

	ElseIf cIndo == "03"
		If cModulo == "TRM" .OR. cModulo == "MDT" .OR. lQGint
			SetKey( VK_F6 , bCheckList )
		 	aHeader	:={}
		 	aCols 	:={}
			a2List 	:={}
			n		:= 1
			Tr100obter(val(cIndo), @aHeader, @aCols,nOpcx,nReg,@a2List)

		    If !lObj3  // Controle para apenas uma vez a getdados

		    	@ aObj4Size[2][1],aObj4Size[2][2] GROUP o3Group1	TO aObj4Size[2][3],aObj4Size[2][4] LABEL OemtoAnsi(STR0024) OF oDlgMain PIXEL	//" Funcionario "

				nCalend := GdFieldPos("RA4_CALEND",aListPast[3][1])
				nCurso  := GdFieldPos("RA4_CURSO" ,aListPast[3][1])
				nData   := GdFieldPos("RA4_DATAIN",aListPast[3][1])
				nTurma  := GdFieldPos("RA4_TURMA" ,aListPast[3][1])

			    If  lQGint
					o3Get 	:= MSGetDados():New(aObj4Size[2][1]+10,aObj4Size[2][2]+5,aObj4Size[2][3]-5,aObj4Size[2][4]-5,nOpcx,"Tr100Ok3","AlwaysTrue","",lTrDel,a3Alter,,,999,,,,,oDlgMain)
		            o3Bot1 := SButton():New( aObjSize[2][1]+5,aObjSize[2][2]+220, 15, {|| Tr070VzDc(aCols[n][nCalend],aCols[n][nCurso],aCols[n][nTurma],M->RA_MAT,aCols[n][nData],.T.)}, oDlgMain, .T.,,)
		            o3Bot1 :CTOOLTIP:=STR0092                                              //"Visualiza Documentos"
			   	Else
					o3Get 	:= MSGetDados():New(aObj4Size[2][1]+10,aObj4Size[2][2]+5,aObj4Size[2][3]-5,aObj4Size[2][4]-5,nOpcx,"Tr100Ok3","AlwaysTrue","",lTrDel,a3Alter,,,999,,,,,oDlgMain)
				EndIf
				o3Get:oBrowse:Default()
		   		lObj3:=.T.
		   	EndIf

		 	Montalinha(@o3Lbx)

			o3Lbx:Show()
			o3Lbx:Refresh(.T.)
			o3Get:oBrowse:lDisablePaint := .F.
			o3Get:Show()
			o3Get:oBrowse:Show()
			o3Get:oBrowse:Refresh(.T.)
			o3Group1:Show()
			o3Group2:Show()
			If lQGint
				o3Bot1:Show()
			EndIf
			oSay12:Show()
			oGet1:Show()
			oGet1:cText(cGet)
			oAux	:= o3Get
		EndIf

	ElseIf cIndo == "04"
		aHeader	:= {}
		aCols 	:= {}
		n		:= 1
		Tr100obter(val(cIndo), @aHeader, @aCols,nOpcx,nReg)

		If	!lObj4 	 // Controle para apenas uma vez a getdados
			// Historico Carreira - SQC
			@ aObj6Size[2][1],aObj6Size[2][2] GROUP o4Group1	TO aObj6Size[2][3],aObj6Size[2][4] LABEL OemtoAnsi(STR0032)   OF oDlgMain PIXEL 	//" Historico Carreira "
			o4Get   := MSGetDados():New(aObj6Size[2][1]+10,aObj6Size[2][2]+5,aObj6Size[2][3]-5,aObj6Size[2][4]-5,nOpcx,"Tr100Ok4","AlwaysTrue","",lTrDel,,1,,300,,,,,oDlgMain)
			o4Get:oBrowse:Default()
			lObj4:= .T.
	    EndIf

		o4Get:oBrowse:lDisablePaint := .F.
		o4Get:Show()
		o4Get:oBrowse:Show()
		o4Get:oBrowse:Refresh(.T.)
		o4Group1:Show()
		oSay12:Show()
		oGet1:Show()
		oGet1:cText(cGet)
		oAux	:= o4Get


	ElseIf cIndo == "05"

		If cModulo == "CSA" .Or. cModulo == "ORG"
			// Transfere os Dados do aColsAll para o aCols
			Gpea250AllTrf(	"SR7" 			,;	//01 -> Alias do Arquivo
							Nil				,;	//02 -> Objeto GetDados para o SR7
							oGetSR7:aCols	,;	//03 -> aCols utilizado na GetDados
							oGetSR7:aHeader	,;	//04 -> aHeader utilizado na GetDados
							@aColsR7All		,;	//05 -> aCols com todas as informacoes
							aHeaderR7All	,;	//06 -> aHeader com todos os campos
							.T.				,;	//07 -> Se carrega elemento de Deletado na remontagem do aCols
							.F.				,;	//08 -> Se transfere do aCols para o aColsAll
							.T.				 ;	//09 -> Se transfere do aColsAll para o aCols
						  )

			aColsR7	:= aClone(oGetSR7:aCols)
			o5Group1:Show()
			oGetSR7:oBrowse:lDisablePaint := .F.
			oGetSR7:Show()
			oGetSR7:oBrowse:Show()
			oGetSR7:oBrowse:Refresh(.T.)
			oGetSr3:oBrowse:lDisablePaint := .F.
			oGetSr3:Show()
			oGetSr3:oBrowse:Show()
			oGetSr3:oBrowse:Refresh(.T.)
			Eval(oGetSR7:bChange,.T.)
			oSay12:Show()
			oGet1:Show()
			oGet1:cText(cGet)
			oAux	:= oGetSR7
		EndIf

	ElseIf cIndo == "06"
		aHeader	:= {}
		aCols 	:= {}
		n		:= 1

		Tr100obter(val(cIndo), @aHeader, @aCols,nOpcx,nReg)

		If	!lObj6   // Controle para apenas uma vez a getdados
			// Historico ExtraCurriculares - SQ9
			@ aObj6Size[2][1],aObj6Size[2][2] GROUP o6Group1	TO aObj6Size[2][3],aObj6Size[2][4] LABEL OemtoAnsi(STR0034)  OF oDlgMain PIXEL 	//" Historico Extra Curriculares "
			o6Get   := MSGetDados():New(aObj6Size[2][1]+10,aObj6Size[2][2]+5,aObj6Size[2][3]-5,aObj6Size[2][4]-5,nOpcx,"tr100Ok6","AlwaysTrue","",lTrDel,,1,,300,,,,,oDlgMain)
			o6Get:oBrowse:Default()

	  		lObj6:=.T.
		EndIf

		o6Group1:Show()
		o6Get:oBrowse:lDisablePaint := .F.
		o6Get:Show()
		o6Get:oBrowse:Show()
		o6Get:oBrowse:Refresh(.T.)
		oSay12:Show()
		oGet1:Show()
		oGet1:cText(cGet)
		oAux	:= o6Get

	ElseIf cIndo == "07"
		If cModulo == "TRM" .OR. cModulo == "MDT" .OR. lQGint
			aHeader	:= {}
			aCols 	:= {}
			n		:= 1
			Tr100obter(val(cIndo), @aHeader, @aCols,nOpcx,nReg)
			If	!lObj7   // Controle para apenas uma vez a getdados
				// Solicitacao Treinamento - RA3
				@ aObj6Size[2][1],aObj6Size[2][2] GROUP o7Group1	TO aObj6Size[2][3],aObj6Size[2][4] LABEL OemtoAnsi(STR0035)    OF oDlgMain PIXEL 		//" Solicitacao Treinamento "
				o7Get 	:= MSGetDados():New(aObj6Size[2][1]+10,aObj6Size[2][2]+5,aObj6Size[2][3]-5,aObj6Size[2][4]-5,nOpcx,"tr100Ok7","AlwaysTrue","",lTrDel,a7Alter,1,,300,,,,,oDlgMain)
				o7Get:oBrowse:Default()
		  		lObj7:=.T.
			EndIf

			o7Group1:Show()
			o7Get:oBrowse:lDisablePaint := .F.
			o7Get:Show()
			o7Get:oBrowse:Show()
			o7Get:oBrowse:Refresh(.T.)
			oSay12:Show()
			oGet1:Show()
			oGet1:cText(cGet)
			oAux	:= o7Get
		EndIf

	ElseIf cIndo == "08"
		aHeader	:= {}
		aCols 	:= {}
		n		:= 1
		Tr100obter(val(cIndo), @aHeader, @aCols,nOpcx,nReg)

		If !lObj8  // Controle para apenas uma vez a getdados
			// Referencia Graduacao - RAF
			@ aObj6Size[2][1],aObj6Size[2][2] GROUP o8Group1	TO aObj6Size[2][3],aObj6Size[2][4] LABEL OemtoAnsi(STR0043)  OF oDlgMain PIXEL 	//" Referencia das Graduacoes"
			o8Get := MSGetDados():New(aObj6Size[2][1]+10,aObj6Size[2][2]+5,aObj6Size[2][3]-5,aObj6Size[2][4]-5,nOpcx,"tr100Ok8","AlwaysTrue","",lTrDel,,1,,300,,,,,oDlgMain)
			o8Get:oBrowse:Default()
			lObj8:=.T.
		EndIf
		o8Group1:Show()
		o8Get:oBrowse:lDisablePaint := .F.
		o8Get:Show()
		o8Get:oBrowse:Show()
		o8Get:oBrowse:Refresh(.T.)
		oSay12:Show()
		oGet1:Show()
		oGet1:cText(cGet)
		oAux := o8Get

	ElseIf cIndo == "09"
		If cModulo == "TRM" .OR. cModulo == "MDT" .OR. lQGint
			aHeader	:= {}
			aCols 	:= {}
			n		:= 1

			SetKey( VK_F4 , { || TR100F4() } )
			aHeader := aClone(aSvGetD[1][1])
			If Len(aSvGetD) > 0
				aCols	:= aClone(aSvGetD[1][2])
			EndIf
			o9Lbx:SetArray(a9List)
			o9Lbx:bLine := { || { 	a9List[o9Lbx:nAt,1],a9List[o9Lbx:nAt,2],a9List[o9Lbx:nAt,3],;
									a9List[o9Lbx:nAt,4],a9List[o9Lbx:nAt,5],a9List[o9Lbx:nAt,6],;
									a9List[o9Lbx:nAt,7],a9List[o9Lbx:nAt,8],a9List[o9Lbx:nAt,9],;
									a9List[o9Lbx:nAt,10],a9List[o9Lbx:nAt,11],a9List[o9Lbx:nAt,12],;
									a9List[o9Lbx:nAt,13],a9List[o9Lbx:nAt,14],;
									}}
			o9Lbx:nAt 	:= 1
			nPos9		:= 1
			o9Lbx:Show()
			o9Lbx:Refresh(.T.)
			o9Group1:Show()
			o9Group2:Show()
			oF4:LVISIBLECONTROL:=.T.
			o9Get:oBrowse:lDisablePaint := .F.
			o9Get:oBrowse:bValid := {|| Tr100AtuGD(o9Lbx:nAt,2) }	// funcao a ser executada qdo. o browse perder o foco.
			o9Get:Show()
			o9Get:oBrowse:Show()
			o9Get:oBrowse:Refresh(.T.)
			oSay12:Show()
			oGet1:Show()
			oGet1:cText(cGet)
			o9Bot1:Show()
			o9Bot2:Show()
			oAux := o9Get


		EndIf

	ElseIf cIndo == "10"

	   	aHeader	:= {}
		aCols 	:= {}
		n		:= 1
		a10List 	:={}

		Tr100obter(val(cIndo), @aHeader, @aCols,nOpcx,nReg,@a10List)


		If	!lObj10    // Controle para apenas uma vez a getdados
			//Habilidades do Funcionario - RBI
			aSaveHabil := aClone(aCols)
			@ aObj4Size[2][1],aObj4Size[2][2] GROUP o10Group1	TO aObj4Size[2][3],aObj4Size[2][4] LABEL OemtoAnsi(STR0018)  OF oDlgMain PIXEL 	//" Funcionario"
			o10Get  := MSGetDados():New(aObj4Size[2][1]+10,aObj4Size[2][2]+5,aObj4Size[2][3]-5,aObj4Size[2][4]-5,nOpcx,"tr100Ok10","AlwaysTrue","",lTrDel,,1,,999,,,,,oDlgMain)
			o10Get:oBrowse:Default()
			lObj10:=.T.
		EndIf

		o10Lbx:SetArray(a10List)
		o10Lbx:bLine:= {||{a10List[o10Lbx:nAt,1],a10List[o10Lbx:nAt,2],a10List[o10Lbx:nAt,3],a10List[o10Lbx:nAt,4],a10List[o10Lbx:nAt,5],a10List[o10Lbx:nAt,6]}}
		o10Get:oBrowse:lDisablePaint := .F.
		o10Get:Show()
		o10Get:oBrowse:Show()
		o10Get:oBrowse:Refresh(.T.)
		o10Lbx:Show()
		o10Lbx:Refresh(.T.)
		o10Group1:Show()
		o10Group2:Show()
		oSay12:Show()
		oGet1:Show()
		oGet1:cText(cGet)
		oAux := o10Get

	ElseIf cIndo == "11"
		aHeader	:= {}
		aCols 	:= {}
		n		:= 1

		If lExistRBN
			Tr100obter(val(cIndo), @aHeader, @aCols,nOpcx,nReg)

			If	!lObj11 // Controle para apenas uma vez a getdados
				// Atividades Funcionais - RBN
				@ aObj6Size[2][1],aObj6Size[2][2] GROUP o11Group1	TO aObj6Size[2][3],aObj6Size[2][4] LABEL OemtoAnsi(STR0093)  OF oDlgMain PIXEL 	//" Atividades Funcionais "
				o11Get  := MSGetDados():New(aObj6Size[2][1]+10,aObj6Size[2][2]+5,aObj6Size[2][3]-5,aObj6Size[2][4]-5,nOpcx,"tr100Ok11","AlwaysTrue","",lTrDel,,1,,300,,,,,oDlgMain)
				o11Get:oBrowse:Default()
				lObj11:=.T.
			EndIf
			o11Group1:Show()
			o11Get:oBrowse:lDisablePaint := .F.
			o11Get:Show()
			o11Get:oBrowse:Show()
			o11Get:oBrowse:Refresh(.T.)
			oSay12:Show()
			oGet1:Show()
			oGet1:cText(cGet)
			oAux := o11Get
		EndIf
	EndIf

	cEstou := cIndo

Return( Nil )

/*/{Protheus.doc} Tr100Desc
Tras a descricao
@type  Function
@author Cristina Ogura
@since 12.11.98
@see TRMA100
/*/
Function Tr100Desc(nTipo)
Local aSaveArea	:= GetArea()
Local cRetorno 	:= CriaVar("Q1_DESCSUM",.F.)
Local nPosFator	:= 0
Local nPosGrau 	:= 0
Local nPosFatRAF:= 0

	If 	nTipo == 1
		nPosFator:= GdFieldPos("Q8_FATOR")
		If ( !Empty(aCols[Len(aCols)][nPosFator]) )
			cRetorno :=TrmDesc("SQV",SQ8->Q8_FATOR,"SQV->QV_DESCFAT")
		EndIf


	ElseIf nTipo == 2
		nPosGrau := GdFieldPos("Q8_GRAU")
		If ( !Empty(aCols[Len(aCols)][nPosGrau]) )
			cRetorno := TrmDesc("SQV",SQ8->Q8_FATOR+SQ8->Q8_GRAU,"SQV->QV_DESCGRA")
		EndIf


	ElseIf nTipo == 3
		nPosFatRAF := GdFieldPos("RAF_FATOR")
		If ( !Empty(aCols[Len(aCols)][nPosFatRAF]) )
			cRetorno :=TrmDesc("SQV",RAF->RAF_FATOR,"SQV->QV_DESCFAT")
		EndIf

	ElseIf nTipo == 4
		nPosTipo := GdFieldPos("RAI_TIPO")
		If ( !Empty(aCols[Len(aCols)][nPosTipo]) )
			cRetorno :=TrmDesc("SX5","RJ"+RAI->RAI_TIPO,"X5DESCRI()")
		EndIf
	EndIf

	RestArea(aSaveArea)

Return( cRetorno )

/*/{Protheus.doc} Tr100Ok2
Graduacao x Funcionario
@type  Function
@author Cristina Ogura
@since 12.11.98
@see TRMA100
/*/
Function Tr100Ok2(cVldTree)
Local lRet 		:= .T.
Local nPosFator	:= 0
Local nPosGrau	:= 0
Local nx        := 0

	cVldTree := If (cVldTree == Nil ,"N" , If (ValType(cVldTree) == "C",cVldTree, "N"))

	If cVldTree == "S" .And. Len(aCols) == 1
		If Tr100Linha("SQ8")
			Return(.T.)
		EndIf
	EndIf

	nPosFator:= GdFieldPos("Q8_FATOR")
	nPosGrau := GdFieldPos("Q8_GRAU")


	If !aCols[n,Len(aCols[n])]
		If nPosGrau >0 .And. Empty(aCols[n][nPosGrau])
			Help("",1,"TRA100GRAU")
			lRet := .F.
		ElseIf nPosFator >0 .And. Empty(aCols[n][nPosFator])
			Help("",1,"TRA100FATO")
			lRet := .F.
		EndIf

		If lRet
			For nx:=1 To Len(aCols)
				If aCols[n][nPosFator] == aCols[nx][nPosFator] .And.;
					!aCols[nx][Len(aCols[nx])] .And.;
					n # nx
					Help(" ",1,"TRA100EXFA")

					lRet:= .F.
					Exit
				EndIf
			Next nx
		EndIf
	EndIf

	TR100FASpt()

Return( lRet )

/*/{Protheus.doc} Tr100Ok3
Cursos x Cargos
@type  Function
@author Cristina Ogura
@since 12.11.98
@see TRMA100
/*/
Function Tr100Ok3(cVldTree)
Local lRet		:= .T.
Local nPosCal	:= 0
Local nPosCur	:= 0
Local nPosTur	:= 0
Local nPosEnt	:= 0
Local nPosDtIni := 0
Local nPosDtFim := 0
Local nx		:= 0

	cVldTree := If (cVldTree == Nil ,"N" , If (ValType(cVldTree) == "C",cVldTree, "N"))

	If cVldTree == "S" .And. Len(aCols) == 1
		If Tr100Linha("RA4")
			Return(.T.)
		EndIf
	EndIf

	nPosCal		:= GdFieldPos("RA4_CALEND")
	nPosCur 	:= GdFieldPos("RA4_CURSO")
	nPosTur		:= GdFieldPos("RA4_TURMA")
	nPosEnt 	:= GdFieldPos("RA4_ENTIDA")
	nPosDtIni	:= GdFieldPos("RA4_DATAIN")
	nPosDtFim	:= GdFieldPos("RA4_DATAFI")
	nPosSin 	:= GdFieldPos("RA4_SINONI")


	If !aCols[n,Len(aCols[n])]
		If nPosCur > 0 .And. Empty(aCols[n][nPosCur])
			Help(" ",1,"TRA100CURS")
			lRet := .F.
		ElseIf nPosEnt > 0 .And. Empty(aCols[n][nPosEnt])
			Help(" ",1,"TRA100ENTI")
			lRet := .F.
		EndIf

		If nPosCur > 0 .And. nPosEnt > 0 .And. !Empty(aCols[n][nPosCur]) .And. !Empty(aCols[n][nPosEnt])
			If !VrfRA6(aCols[n][nPosCur],aCols[n][nPosEnt])
				Help("",1,"TRA100VIN")
				lRet:= .F.
			EndIf
		EndIf

		// Verifica se a data inicial menor que dt final
		If 	(nPosDtIni > 0) .And. (nPosDtFim > 0) .And.;
			aCols[n][nPosDtIni] > aCols[n][nPosDtFim]
			Help(" ",1,"TRA100DATA")
			lRet := .F.
		EndIf

		If lRet
			For nx:=1 To Len(aCols)
				If aCols[n][nPosCal] == aCols[nx][nPosCal] .And.;
					aCols[n][nPosCur] == aCols[nx][nPosCur] .And.;
					aCols[n][nPosSin] == aCols[nx][nPosSin] .And.;
					aCols[n][nPosTur] == aCols[nx][nPosTur] .And.;
					aCols[n][nPosDtIni] == aCols[nx][nPosDtIni] .And.;
					!aCols[nx][Len(aCols[nx])] .And.;
					n # nx
					Aviso(OemToAnsi(STR0097),OemToAnsi(STR0098), {"Ok"})	//"Estes dados ja foram cadastrados","Verifique o Curso, o Sinonimo do Curso, a Entidade e a Data Inicio."
					lRet:= .F.
					Exit
				EndIf
			Next nx
		EndIf
	EndIf

	// Ponto de Entrada para validar os campos da aba Cursos.
	If lRet .And. ExistBlock("TRM100K3")
		lRet := ExecBlock("TRM100K3",.F.,.F.)
	EndIf

Return( lRet )

/*/{Protheus.doc} Tr100Ok4
Historico de Carreira
@type  Function
@author Cristina Ogura
@since 12.11.98
@see TRMA100
/*/
Function Tr100Ok4(cVldTree)
Local lRet 		:= .T.
Local nPosAdmiss:= 0
Local nPosDemiss:= 0
Local nPosEmpres:= 0

	cVldTree := If (cVldTree == Nil ,"N" , If (ValType(cVldTree) == "C",cVldTree, "N"))

	If cVldTree == "S" .And. Len(aCols) == 1
		If Tr100Linha("SQC")
			Return(.T.)
		EndIf
	EndIf

	nPosAdmiss := GdFieldPos("QC_ADMISSA")
	nPosDemiss := GdFieldPos("QC_DEMISSA")
	nPosEmpres := GdFieldPos("QC_EMPRESA")
	nPosAltera := GdFieldPos("QC_DTALTER")

	If !aCols[n,Len(aCols[n])]
		If nPosAdmiss > 0 .And. Empty(aCols[n][nPosAdmiss])
			Help(" ",1,"TRA100ADM")
			lRet := .F.
		ElseIf nPosDemiss > 0 .And. Empty(aCols[n][nPosDemiss])
			Help(" ",1,"TRA100DEM")
			lRet := .F.
		ElseIf nPosEmpres > 0 .And. Empty(aCols[n][nPosEmpres])
			Help(" ",1,"TRA100EMP")
			lRet := .F.
		EndIf

		// Verifica se a data inicial menor que dt final
		If 	(nPosAdmiss > 0) .And. (nPosDemiss > 0) .And.;
			aCols[n][nPosAdmiss] > aCols[n][nPosDemiss]
			Help(" ",1,"TRA100DATA")
			lRet := .F.
		EndIf
		If 	(nPosAdmiss > 0) .And. (nPosAltera > 0) .And.;
			aCols[n][nPosAdmiss] > aCols[n][nPosAltera]
				Help(" ",1,"TRA100ALAD")
				lRet := .F.
		EndIf
	EndIf

Return( lRet )

/*/{Protheus.doc} Tr100Ok6
ExtraCurriculares
@type  Function
@author Cristina Ogura
@since 12.11.98
@see TRMA100
/*/
Function Tr100Ok6(cVldTree)
Local lRet		:= .T.
Local nPosDtIni	:= 0
Local nPosData	:= 0
Local nPosDesc	:= 0

	cVldTree := If (cVldTree == Nil ,"N" , If (ValType(cVldTree) == "C",cVldTree, "N"))

	If cVldTree == "S" .And. Len(aCols) == 1
		If Tr100Linha("SQ9")
			Return(.T.)
		EndIf
	EndIf

	nPosDtIni	:= GdFieldPos("Q9_DTINI")
	nPosData 	:= GdFieldPos("Q9_DATA")
	nPosDesc 	:= GdFieldPos("Q9_DESCRIC")

	If !aCols[n,Len(aCols[n])] 		// Verifico deletado a linha
		If nPosData > 0 .And. Empty( aCols[n][nPosData] )
			Help(" ",1,"TRA100DTEX")
			lRet := .F.
		ElseIf nPosData > 0 .AND. nPosDtIni > 0 .AND. aCols[n][nPosDtIni] > aCols[n][nPosData]
			Help(" ",1,"TRA100DATA")
			lRet := .F.
		ElseIf nPosDesc > 0 .And. Empty( aCols[n][nPosDesc] )
			Help(" ",1,"TRA100DSUM")
			lRet := .F.
		EndIf
	EndIf

	//Ponto de Entrada para validar os campos da aba ExtraCurriculares.
	If lRet .And. ExistBlock("TRM100K6")
		lRet := ExecBlock("TRM100K6",.F.,.F.)
	EndIf

Return( lRet )

/*/{Protheus.doc} Tr100Ok7
Solicitacao Treinamento
@type  Function
@author Cristina Ogura
@since 12.11.98
@see TRMA100
/*/
Function Tr100Ok7(cVldTree)
Local lRet		:= .T.
Local nx		:= 0
Local nPosCurso	:= 0
Local nPosCalend:= 0
Local nPosTurma	:= 0
Local nPosTipo	:= 0

	cVldTree := If (cVldTree == Nil ,"N" , If (ValType(cVldTree) == "C",cVldTree, "N"))

	If cVldTree == "S" .And. Len(aCols) == 1
		If Tr100Linha("RA3")
			Return(.T.)
		EndIf
	EndIf

	nPosCurso	:= GdFieldPos("RA3_CURSO")
	nPosCalend	:= GdFieldPos("RA3_CALEND")
	nPosTurma	:= GdFieldPos("RA3_TURMA")
	nPosTipo 	:= GdFieldPos("RA3_RESERV")

	If !aCols[n,Len(aCols[n])] 		// Verifico deletado a linha
		If nPosCurso > 0 .And. Empty(aCols[n][nPosCurso])
			Help("",1,"TRA100CURS")
			lRet := .F.
		EndIf

		If nPosTipo > 0 .And. Empty(aCols[n][nPosTipo])
			Help("",1,"TRA100RESERV")
			lRet := .F.
		EndIf

		If lRet
			For nx:=1 To Len(aCols)
				If aCols[n][nPosCurso] == aCols[nx][nPosCurso] .And.;
					aCols[n][nPosCalend] == aCols[nx][nPosCalend] .And.;
					aCols[n][nPosTurma] == aCols[nx][nPosTurma] .And.;
					!aCols[nx][Len(aCols[nx])] .And.;
					n # nx
					Help(" ",1,"TRA100EXCA")
					lRet:= .F.
					Exit
				EndIf
			Next nx
		EndIf
	EndIf

Return( lRet )

/*/{Protheus.doc} Tr100Ok8
Referencia das Graduacoes
@type  Function
@author Cristina Ogura
@since 06.10.2000
@see TRMA100
/*/
Function Tr100Ok8(cVldTree)
Local aSaveArea	:= GetArea()
Local lRet		:= .T.
Local nPosFator	:= 0
Local nPosValor	:= 0
Local nPosDtIni	:= 0
Local nPosDtFim	:= 0
Local nx		:= 0

	cVldTree := If (cVldTree == Nil ,"N" , If (ValType(cVldTree) == "C",cVldTree, "N"))

	If cVldTree == "S" .And. Len(aCols) == 1
		If Tr100Linha("RAF")
			Return(.T.)
		EndIf
	EndIf

	nPosFator := GdFieldPos("RAF_FATOR")
	nPosValor := GdFieldPos("RAF_REFER")
	nPosDtIni := GdFieldPos("RAF_DTINI")
	nPosDtFim := GdFieldPos("RAF_DTFIM")

	If !aCols[n,Len(aCols[n])] 		// Verifico deletado a linha
		If nPosFator > 0 .And. Empty( aCols[n][nPosFator] )
			Help(" ",1,"TRA100FATOR")
			lRet := .F.
		ElseIf nPosValor > 0 .And. Empty( aCols[n][nPosValor] )
			Help(" ",1,"TRA100REFER")
			lRet := .F.
		ElseIf nPosDtIni > 0 .And. Empty( aCols[n][nPosDtIni] )
			Help(" ",1,"TRA100DTINI")
			lRet := .F.
		ElseIf nPosDtFim > 0 .And. Empty( aCols[n][nPosDtFim] )
			Help(" ",1,"TRA100DTFIM")
			lRet := .F.
		EndIf

		// Verifica se a data inicial menor que dt final
		If 	(nPosDtIni > 0) .And. (nPosDtFim > 0) .And.;
			aCols[n][nPosDtIni] > aCols[n][nPosDtFim]
			Help(" ",1,"TRA100DATA")
			lRet := .F.
		EndIf


	EndIf

	If lRet
		For nx := 1 To Len(aCols)
			If 	aCols[n][nPosFator] == aCols[nx][nPosFator] .And.;
				aCols[n][nPosDtIni] == aCols[nx][nPosDtIni] .And.;
				!aCols[nx][Len(aCols[nx])] .And.;
				n # nx .And. !aCols[n,Len(aCols[n])]
				Help(" ",1,"TRA100VERRE")
				lRet:= .F.
				Exit
			EndIf


		Next nx
	EndIf

	If lRet
  
        DbSelectArea("RAF")
        DbSetOrder(1)
        If DbSeek(xFilial("RAF")+M->RA_MAT+aCols[n][nPosFator]+DtoS(aCols[n][nPosDtIni]))
            If (RAF->RAF_REFER<>aCols[n][nPosValor])
                MsgAlert( OemToAnsi(STR0119), OemToAnsi(STR0120) )  
                //"O Valor de Referência de Graduação informado, deverá estar com a mesma quantidade de caracteres aceitos conforme cadastrado na referência dos Fatores de Avaliação do Grupo!" # "Referência de Graduação!"
            Endif
        Endif
    Endif

RestArea(aSaveArea)
Return( lRet )

/*/{Protheus.doc} Tr100Ok9
Avaliacao de Treinamento
@type  Function
@author Emerson Grassi Rocha
@since 30/11/01
@see TRMA100
/*/
Function Tr100Ok9(cVldTree)
Local nPosTeste	:= GdFieldPos("RAI_TESTE")
Local nPosQuest := GdFieldPos("RAI_QUESTA")
Local nPosAlter := GdFieldPos("RAI_ALTERN")

	If	a9List[o9lbx:nAt][9] == STR0067 //"Ativo"

		If nPosTeste > 0 .And. !Empty(aCols[n][nPosTeste]) .And. !aCols[n][Len(aCols[n])]
			//-- Verifica se Campos obrigatorioos estao preenchidos.
			If 	( nPosQuest > 0 .And. Empty(aCols[n][nPosQuest]) ) .Or.;
		 		( nPosAlter > 0 .And. Empty(aCols[n][nPosAlter]) )
				Help(" ",1,"A010VZ5")
				Return .F.
			EndIf
			Tr100CalcP(o9lbx:nAt)
			o9lbx:Refresh()
		EndIf
	EndIf

Return( .T. )

/*/{Protheus.doc} Tr100Ok10
Validacao das Habilidades
@type  Function
@author Emerson Grassi Rocha
@since 17/12/03
@see TRMA100
/*/
Function Tr100Ok10(cVldTree)
Local lRet		:= .T.
Local nx		:= 0

	cVldTree := If (cVldTree == Nil ,"N" , If (ValType(cVldTree) == "C",cVldTree, "N"))

	If cVldTree == "S" .And. Len(aCols) == 1
		If Tr100Linha("RBI")
			Return(.T.)
		EndIf
	EndIf

	If !aCols[n,Len(aCols[n])] 		// Verifico deletado a linha
		If ( Empty(GDFieldGet("RBI_DATA" , n)) )
			If ( Empty( GDFieldGet("RBI_HABIL", n)) )
				Aviso(STR0036, STR0090, {"Ok"})	//"Codigo da Habilidade deve ser informado."
				lRet := .F.
			ElseIf Empty( GDFieldGet("RBI_ITESCA", n) )
				Aviso(STR0036, STR0091, {"Ok"})	//"Item de Escala deve ser informado."
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If lRet
		For nx := 1 To Len(aCols)
			If 	GDFieldGet("RBI_HABIL", n) == GDFieldGet("RBI_HABIL", nx) .And.;
				!aCols[nx][Len(aCols[nx])] .And.;
				n # nx .And. !aCols[n,Len(aCols[n])]
				Aviso(STR0036, STR0089, {"Ok"})	// "Item ja cadastrado"
				lRet:= .F.
				Exit
			EndIf
		Next nx
	EndIf

Return( lRet )

/*/{Protheus.doc} Tr100Ok11
Validacao das Atividades Funcionais
@type  Function
@author Emerson Grassi Rocha
@since 18/05/05
@see TRMA100
/*/
Function Tr100Ok11(cVldTree)
Local lRet		:= .T.

	cVldTree := If (cVldTree == Nil ,"N" , If (ValType(cVldTree) == "C",cVldTree, "N"))

	If cVldTree == "S" .And. Len(aCols) == 1
		If Tr100Linha("RBN")
			Return(.T.)
		EndIf
	EndIf

	If !aCols[n,Len(aCols[n])] 		// Verifico deletado a linha
		If Empty( GDFieldGet("RBN_DEPTO", n) )
			Aviso(STR0036, STR0094, {"Ok"})	//"A Area/Departamento que foi executada esta atividade deve ser informada."
			lRet := .F.
		ElseIf Empty( GDFieldGet("RBN_FUNCAO", n) )
			Aviso(STR0036, STR0095, {"Ok"})	//"A Funcao que o Funcionario ocupava nesta atividade deve ser informada."
			lRet := .F.
		ElseIf Empty( GDFieldGet("RBN_DTINI", n) )
			Aviso(STR0036, STR0096, {"Ok"})	//"A data de Inicio desta atividade deve ser informada."
			lRet := .F.
		EndIf
	EndIf

Return( lRet )

/*/{Protheus.doc} Tr100Grava
Grava nos arquivos de funcionarios
@type  Function
@author Cristina Ogura
@since 20.11.98
@see TRMA100
/*/
Function Tr100Grava(nOpcx,aMemoRA4)
Local aSaveArea	:= GetArea()
Local lSair		:= .F.
Local ny 		:= 0
Local nx 		:= 0
Local nt 		:= 0
Local ni 		:= 0
Local cAlias	:= 0
Local cCampo	:= ""
Local xConteudo	:= ""
Local aAlias	:= {"SRA","SQ8","RA4","SQC","SR7","SQ9","RA3","RAF","RAI","RBI"}
Local cAux1		:= cAux2 := cAux3 := ""
Local bCampo	:= { |nCPO| Field(nCPO) }
Local nPosCalend:= nPosCurso := nPosTurma := nPosReser := 0
Local lQGint	:= FlQGInt() //Integracao Quality
Local lTravou	:= .F.
Local nLoop		:= 0
Local nPos		:= 0

	If lExistRBN
		Aadd(aAlias,"RBN")
	EndIf

	If cModulo == "TRM" .OR. cModulo == "MDT"
		// Exclui todas as solicitacoes Treinamento - RA3 e inclui novamente
		// para controlar vagas reservadas do calendario

		dbSelectArea("RA3")
		dbSetOrder(1)
		If dbSeek(xFilial("RA3")+cMat)
			While !Eof() .And. RA3->RA3_FILIAL+RA3->RA3_MAT ==;
				xFilial("RA3")+cMat

				// Libera uma vaga reservada
				dbSelectArea("RA2")
				dbSetOrder(2)
				If dbSeek(xFilial("RA2")+RA3->RA3_CURSO+RA3->RA3_TURMA)
					While !Eof() .And. xFilial("RA2")+RA3->RA3_CURSO+RA3->RA3_TURMA ==;
						RA2->RA2_FILIAL+RA2->RA2_CURSO+RA2->RA2_TURMA
						If RA2->RA2_CALEND == RA3->RA3_CALEND .And.;
							RA3->RA3_RESERV == "R"
							RecLock("RA2",.F.)
								Replace RA2_RESERV With RA2->RA2_RESERV -1
							MsUnlock()
						EndIf
						dbSkip()
					EndDo
				EndIf

				dbSelectArea("RA3")
				RecLock("RA3",.F.)
				dbDelete()
				MsUnlock()
				dbSkip()
			EndDo
		EndIf
	EndIf

	// Gravacao de Arquivos
	For nt:=1 To Len(aAlias)

	    If  aListPast[nt] == Nil
	    	Loop
	    EndIf

		If nt == 1

		 	// Funcionario
			dbSelectArea("SRA")
	 		RecLock("SRA",.F.)

			// Atualizar Grau de Instrucao
			If !Empty(cGraduac)
				If ExistCpo("SX5","26"+cGraduac)
					SRA->RA_GRINRAI	:= cGraduac
				EndIf
			EndIf

			MsUnlock()
			Loop

		ElseIf nt == 2
			// Graduacao
		  	aHeader	:= aClone(aListPast[nt][1])
			aCols 	:= aClone(aListPast[nt][2])

		ElseIf nt == 3
			// Cursos
			If cModulo == "TRM" .OR. cModulo == "MDT"
		  	aHeader	:= aClone(aListPast[nt][1])
			aCols 	:= aClone(aListPast[nt][2])
			Else
				Loop
			EndIf

		ElseIf nt == 4
			// Historico carreira

		  	aHeader	:= aClone(aListPast[nt][1])
			aCols 	:= aClone(aListPast[nt][2])

		ElseIf nt == 5
			// Historico Funcionario
			// Controle do GPEA250
			Loop

		ElseIf nt == 6
			// ExtraCurriculares
		  	aHeader	:= aClone(aListPast[nt][1])
			aCols 	:= aClone(aListPast[nt][2])

		ElseIf nt == 7	.And. cModulo == "TRM" .OR. cModulo == "MDT"
		// Controla as vagas reservadas no calendario

		  	aHeader	:= aClone(aListPast[nt][1])
			aCols 	:= aClone(aListPast[nt][2])

			nPosReser	:= GdFieldPos("RA3_RESERV")
			nPosCurso  	:= GdFieldPos("RA3_CURSO")
			nPosTurma  	:= GdFieldPos("RA3_TURMA")
			nPosCalend 	:= GdFieldPos("RA3_CALEND")

		ElseIf nt == 8
			// Referencia da Graduacao
		  	aHeader	:= aClone(aListPast[nt][1])
			aCols 	:= aClone(aListPast[nt][2])

		ElseIf nt == 9
			// Avaliacao
			If cModulo == "TRM" .OR. cModulo == "MDT"
			  	aHeader	:= aClone(aListPast[nt][1])
				aCols 	:= aClone(aListPast[nt][2])
			EndIf

		ElseIf nt == 10
			// Habilidades
			  	aHeader	:= aClone(aListPast[nt][1])
				aCols 	:= aClone(aListPast[nt][2])

		ElseIf nt == 11 .And. lExistRBN
			// Atividades Funcionais
		  	aHeader	:= aClone(aListPast[nt][1])
			aCols 	:= aClone(aListPast[nt][2])

		EndIf
		cAlias:= IIf(Substr(aAlias[nt],1,1)=="S",Substr(aAlias[nt],2,2),aAlias[nt])
		nPosRec  := GdFieldPos(cAlias+"_REC_WT")

		If Len(aCols) == 1
			Tr100Zera(cAlias)
		EndIf

		If nt == 9	// Avaliacao
			If cModulo == "TRM" .OR. cModulo == "MDT"
				Tr100AtRAI()	//Atualiza RAI
			EndIf
		Else
			dbSelectArea(aAlias[nt])
			For nx:=1 to Len(aCols)
				Begin Transaction
					If  aAlias[nt] <> "RA3"  .and. aCols[nx][nPosRec] > 0    // Ignora Alias RA3 pois todos registros do RA3 foram deletados.
						dbGoto(aCols[nx][nPosRec])

						If nt == 10	// Habilidade
							If !fCompArray( aCols[nx] , aSaveHabil[nx] )
								//grava historico da habilidade
								Tr100RAS(cMat,aHeader,aSaveHabil[nx])
							EndIf
						EndIf

						RecLock(aAlias[nt],.F.)
						lTravou:= .T.
					Else
					// Verifica se Nao esta Deletado no aCols
						If !aCols[nx][Len(aCols[nx])]
							RecLock(aAlias[nt],.T.)
							lTravou:= .T.
						EndIf
					EndIf
					If lTravou
						//--Verifica se esta deletado
						If aCols[nx][Len(aCols[nx])]
							If aAlias[nt] == "RA4"
								// Trata os campos memo de usuario
								For nLoop := 1 To Len( aMemoRA4 )
									APDMSMM( &(aMemoRA4[nLoop,1]) ,,,,2)
								Next nLoop
							EndIf
							IF aAlias[nt] == "RA4" .AND. lQGint  //Deleta os Filhos
								Tr100GDoc(aCols[nx][Len(aCols[nx])])
						    Endif
							dbDelete()
							If aAlias[nt] == "SQ8"
								MSMM(Q8_OBS,,,,2)
							EndIf
							If aAlias[nt] == "RAF"
								MSMM(RAF_OBSERV,,,,2)
							EndIf
							If aAlias[nt] == "SQC"
								IF FieldPos("QC_ATIVIDA") > 0
									MSMM(QC_ATIVIDA,,,,2)
								EndIf
							EndIf
							If aAlias[nt] == "SQ9"
								APDMSMM(Q9_CODCONT,,,,2)
								APDMSMM(Q9_CODCOM ,,,,2)
								APDMSMM(Q9_CODQUA ,,,,2)
							EndIf

							If aAlias[nt] == "RBN"
								IF lExistRBN
									APDMSMM(RBN_ATIVID,,,,2)
								EndIf
							EndIf


							dbSelectArea(aAlias[nt])
							MsUnlock()
						Else
							cAux3:= IIf(Substr(aAlias[nt],1,1)=="S",Substr(aAlias[nt],2,2),aAlias[nt])
							cAux1:= aAlias[nt]+"->"+cAux3+"_FILIAL"
							cAux2:= aAlias[nt]+"->"+cAux3+"_MAT"
							Replace &cAux1 	WITH xFilial(aAlias[nt])
							Replace &cAux2 	WITH cMat
						EndIf
						// Ajusta numero de Reservas
						If aAlias[nt] == "RA3"
							If cModulo == "TRM" .OR. cModulo == "MDT"
								dbSelectArea("RA2")
								dbSetOrder(1)
								If dbSeek(xFilial("RA2")+aCols[nx][nPosCalend])
									While !Eof() .And. xFilial("RA2")+aCols[nx][nPosCalend] ==;
														RA2->RA2_FILIAL+RA2->RA2_CALEND
										If aCols[nx][nPosCurso] == RA2->RA2_CURSO .And.;
											aCols[nx][nPosTurma] == RA2->RA2_TURMA .And.;
											aCols[nx][nPosReser] == "R"
											RecLock("RA2",.F.)
												Replace RA2_RESERV With RA2_RESERV + 1
											MsUnlock()
										EndIf
										dbSkip()
									EndDo
								EndIf
								dbSelectArea(aAlias[nt])
							Else
								lSair:= .T.
							EndIf
						EndIf

						If !lSair
							For ny := 1 To Len(aHeader)
								If aHeader[ny][10] <> "V"
									(aAlias[nt])->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
								EndIf

								If aHeader[ny][8] == "M"   // Campo Memo
									MsUnlock()
									If aAlias[nt] == "SQ8"
										MSMM(Q8_OBS,,,aCols[nx][ny],1,,,"SQ8","Q8_OBS")
									EndIf
									If aAlias[nt] == "RAF"
										MSMM(RAF_OBSERV,,,aCols[nx][ny],1,,,"RAF","RAF_OBSERV")
									EndIf
									If aAlias[nt] == "SQC"
										IF FieldPos("QC_ATIVIDA") > 0
											MSMM(QC_ATIVIDA,,,aCols[nx][ny],1,,,"SQC","QC_ATIVIDA")
										EndIf
									EndIf

									If aAlias[nt] == "SQ9"
										If aheader[ny][2] == "Q9_CONTEUD"
											APDMSMM(Q9_CODCONT,,,aCols[nx][ny],1,,,"SQ9","Q9_CODCONT")
										EndIf
										If aheader[ny][2] == "Q9_COMENT "
											APDMSMM(Q9_CODCOM,,,aCols[nx][ny],1,,,"SQ9","Q9_CODCOM")
										EndIf
										If aheader[ny][2] == "Q9_QUADESC"
											APDMSMM(Q9_CODQUA,,,aCols[nx][ny],1,,,"SQ9","Q9_CODQUA")
										EndIf
									EndIf

									If aAlias[nt] == "RA4"  .AND.  !(aCols[nx][Len(aCols[nx])])
										// Grava os campos memo de usuario
										If !Empty(aMemoRA4) .and. ( (nPos:=Ascan(aMemoRA4,{|x| x[2] == Alltrim(Upper(aheader[ny][2])) } ) ))> 0
											APDMSMM( &(aMemoRA4[nPos][1]),,, aCols[nx][ny],1,,,"RA4",(aMemoRA4[nPos][1]))
										EndIf
									EndIf

									If aAlias[nt] == "RBN"
										IF lExistRBN
											APDMSMM(RBN_ATIVID,,,aCols[nx][ny],1,,,"RBN","RBN_ATIVID")
										EndIf
									EndIf

									RecLock(aAlias[nt],.F.)

								EndIf
							Next ny
							MsUnlock()
							IF aAlias[nt] == "RA4" .AND. lQGint
								Tr100GDoc(aCols[nx][Len(aCols[nx])])
							Endif
						Endif
						lSair:=.F.
						lTravou:= .F.
					EndIF
				End Transaction
			Next nx
		EndIf
	Next nt


// Realiza a gravacao do responsavel no arquivo utilizado
// pelos modulos do Quality Celerina, caso haja integracao.
QA_QUALITY()

RestArea(aSaveArea)

Return

/*/{Protheus.doc} Tr100Dele
Deleta todos os registros referentes as funcionarios
@type  Static Function
@author Cristina Ogura
@since 20.11.98
@see TRMA100
/*/
Static Function Tr100Dele()
Local aSaveArea	:= GetArea()
Local lChkDelOk	:= .F.
Local aNoChk	:= {"SQ8","RA4","SQC","SR3","SR7","SQ9","RA3","SR9","RAF","RAI","RBI","SRF","RBN","RFS","RFX","RFY","RFZ","RBW"}
Local lQGint	:= FlQGInt() //Integracao Quality
Local cCPF		:= ""
Local cCatEFD	:= ""
Local cMatric	:= ""

	// Verificar se pode ser deletado o funcionario
	dbSelectArea("SRD")
	dbSetOrder(1)
	If dbSeek(xFilial("SRD")+cMat)
		Help("",1,"TRA100NPOD")
		RestArea(aSaveArea)
		Return .F.
	EndIf

	dbSelectArea("SRA")
	dbSetOrder(1)
	dbSeek(xFilial("SRA")+cMat)

	lChkDelOk  := ChkDelRegs(	"SRA"				,;	//01 -> Alias do Arquivo Principal
								NIL					,;	//02 -> Registro do Arquivo Principal
								NIL					,;	//03 -> Opcao para a AxDeleta
								NIL					,;	//04 -> Filial do Arquivo principal para Delecao
								NIL					,;	//05 -> Chave do Arquivo Principal para Delecao
								NIL					,;	//06 -> Array contendo informacoes dos arquivos a serem pesquisados
								Nil					,;	//07 -> Mensagem para MsgYesNo
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

//Verifica Integracao TAF
If (cPaisLoc == 'BRA')  .AND. lIntTaf .AND. (Findfunction("fGP26SRA"))
	cCPF	:= GetMemVar( "RA_CIC" )
	cCatEFD	:= GetMemVar( "RA_CATEFD" )
	cMatric	:= GetMemVar( "RA_MAT" )

	If !(fGP26SRA(cCPF, cCatEFD, cMatric, 5, "GPEA010",NIL,NIL,NIL ))
		MsgAlert(OemToAnsi(STR0113)) //"Operacao de exclusao nao podera ser concluida, pois o registro deste trabalhador foi enviado RET."
		Return Nil
	EndIf
EndIf

	// Deleta arquivos Filhos
	// Graduacao
	dbSelectArea("SQ8")
	dbSetOrder(1)
	If dbSeek(xFilial("SQ8")+cMat)
		While !Eof() .And. SQ8->Q8_FILIAL+SQ8->Q8_MAT == ;
			xFilial("SQ8")+cMat
			RecLock("SQ8",.F.)
			dbDelete()
			MsUnlock()
			MSMM(Q8_OBS,,,,2)
			dbSkip()
		EndDo
	EndIf

	// Cursos
	dbSelectArea("RA4")
	dbSetOrder(1)
	If dbSeek(xFilial("RA4")+cMat)
		While !Eof() .And. RA4->RA4_FILIAL+RA4->RA4_MAT ==;
			xFilial("RA4")+cMat

			If lQGint
				dbSelectArea("RAO")
				dbSetOrder(1)
				IF RAO->(MSSEEK(xFilial("RAO")+RA4->(RA4_CALEND+RA4_CURSO+RA4_TURMA+RA4_MAT+DTOS(RA4_DATAIN))))
					While RAO->(!Eof()) .And. RA4->(RA4_FILIAL+RA4_CALEND+RA4_CURSO+RA4_TURMA+RA4_MAT+DTOS(RA4_DATAIN)) ==;
						xFilial("RAO")+RAO->(RAO_CALEND+RAO_CURSO+RAO_TURMA+RAO_MAT+DTOS(RAO_DATAIN))
						RecLock("RAO",.F.)
							dbDelete()
						MsUnlock()
						RAO->(dbSkip())
					Enddo
				ENDIF
				dbSelectArea("RA4")
			EndIf

			Aadd(aDelAliasRA4,{RA4->RA4_MAT,RA4->RA4_CURSO , RA4->RA4_SINONI , RA4->RA4_ENTIDA , DTOS(RA4->RA4_DATAIN)})

			RecLock("RA4",.F.)
				dbDelete()
			MsUnlock()


			dbSkip()
		EndDo
	EndIf

	// Historico Carreira
	dbSelectArea("SQC")
	dbSetOrder(1)
	If dbSeek(xFilial("SQC")+cMat)
		While !Eof() .And. SQC->QC_FILIAL+SQC->QC_MAT ==;
			xFilial("SQC")+cMat
			RecLock("SQC",.F.)
			dbDelete()
			MsUnlock()
			If FieldPos("QC_ATIVIDA") > 0
				MSMM(QC_ATIVIDA,,,,2)
			EndIf
			dbSkip()
		EndDo
	EndIf

	// Historico Valores Salarias
	dbSelectArea("SR3")
	dbSetOrder(1)
	If dbSeek(xFilial("SR3")+cMat)
		While !Eof() .And. SR3->R3_FILIAL+SR3->R3_MAT ==;
								 xFilial("SR3")+cMat
			RecLock("SR3",.F.)
				dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	EndIf

	// Historico Funcionario
	dbSelectArea("SR7")
	dbSetOrder(1)
	If dbSeek(xFilial("SR7")+cMat)
		While !Eof() .And. SR7->R7_FILIAL+SR7->R7_MAT ==;
			xFilial("SR7")+cMat
			RecLock("SR7",.F.)
			dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	EndIf

	// Historico ExtraCurriculares
	dbSelectArea("SQ9")
	dbSetOrder(1)
	If dbSeek(xFilial("SQ9")+cMat)
		While !Eof() .And. SQ9->Q9_FILIAL+SQ9->Q9_MAT ==;
			xFilial("SQ9")+cMat
			RecLock("SQ9",.F.)
			dbDelete()
			MsUnlock()
			APDMSMM(Q9_CODCONT,,,,2)
			APDMSMM(Q9_CODCOM ,,,,2)
			APDMSMM(Q9_CODQUA ,,,,2)
			dbSkip()
		EndDo
	EndIf

	// Solicitacao treinamento
	dbSelectArea("RA3")
	dbSetOrder(1)
	If dbSeek(xFilial("RA3")+cMat)
		While !Eof() .And. RA3->RA3_FILIAL+RA3->RA3_MAT ==;
			xFilial("RA3")+cMat

			// Libera uma vaga reservada
			dbSelectArea("RA2")
			dbSetOrder(2)
			If dbSeek(xFilial("RA2")+RA3->RA3_CURSO+RA3->RA3_TURMA)
				While !Eof() .And. xFilial("RA2")+RA3->RA3_CURSO+RA3->RA3_TURMA ==;
					RA2->RA2_FILIAL+RA2->RA2_CURSO+RA2->RA2_TURMA
					If RA2->RA2_CALEND == RA3->RA3_CALEND .And.;
						RA3->RA3_RESERV == "R"

						RecLock("RA2",.F.)
							Replace RA2_RESERV With RA2->RA2_RESERV -1
						MsUnlock()
					EndIf
					dbSkip()
				EndDo
			EndIf
			dbSelectArea("RA3")
			dbSetOrder(1)
			RecLock("RA3",.F.)
				dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	EndIf


	// Historico das Alteracoes Salariais
	dbSelectArea("SR9")
	dbSetOrder(1)
	If dbSeek(xFilial("SR9")+cMat)
		While !Eof() .And. SR9->R9_FILIAL+SR9->R9_MAT ==;
								 xFilial("SR9")+cMat
			RecLock("SR9",.F.)
				dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	EndIf

	// Referencia das Graduacoes
	dbSelectArea("RAF")
	dbSetOrder(1)
	If dbSeek(xFilial("RAF")+cMat)
		While !Eof() .And. RAF->RAF_FILIAL+RAF->RAF_MAT ==;
								 xFilial("RAF")+cMat
			RecLock("RAF",.F.)
				dbDelete()
			MsUnlock()
			MSMM(RAF_OBSERV,,,,2)
			dbSkip()
		EndDo
	EndIf

	// Testes
	dbSelectArea("RAI")
	dbSetOrder(2)
	If dbSeek(xFilial("RAI")+cMat)
		While !Eof() .And. RAI->RAI_FILIAL+RAI->RAI_MAT ==;
								 xFilial("RAI")+cMat
			RecLock("RAI",.F.)
				dbDelete()
			MsUnlock()
			MSMM(RAI_MRESPO,,,,2,,,,,"RDY")
			dbSkip()
		EndDo
	EndIf

	// Habilidades
	dbSelectArea("RBI")
	dbSetOrder(1)
	If dbSeek(xFilial("RBI")+cMat)
		While !Eof() .And. RBI->RBI_FILIAL+RBI->RBI_MAT ==;
								 xFilial("RBI")+cMat
			RecLock("RBI",.F.)
				dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	EndIf

	// Historico das Habilidades
	dbSelectArea("RAS")
	dbSetOrder(1)
	If dbSeek(xFilial("RAS")+cMat)
		While !Eof() .And. RAS->RAS_FILIAL+RAS->RAS_MAT ==;
								 xFilial("RAS")+cMat
			RecLock("RAS",.F.)
				dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	EndIf


	// Programacao de Ferias
	dbSelectArea("SRF")
	dbSetOrder(1)
	If dbSeek(xFilial("SRF")+cMat)
		While !Eof() .And. SRF->RF_FILIAL+SRF->RF_MAT ==;
								 xFilial("SRF")+cMat
			RecLock("SRF",.F.)
				dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	EndIf

	If (cPaisLoc == 'BRA')
		dbSelectArea("SX2")
		dbSetOrder(1)

		// Informacoes Exclusivas Estagiarios
		If SX2->(MSSeek("RFS"))
			dbSelectArea("RFS")
			dbSetOrder(1)
			If dbSeek(xFilial("RFS")+cMat)
				While !Eof() .And. RFS->RFS_FILIAL+RFS->RFS_MAT ==;
									 xFilial("RFS")+cMat
					RecLock("RFS",.F.)
						dbDelete()
					MsUnlock()
					dbSkip()
				EndDo
			EndIf
		EndIf

		// Fatos Relevantes
		If SX2->(MSSeek("RAE"))
			dbSelectArea("RAE")
			dbSetOrder(1)
			If dbSeek(xFilial("RAE")+cMat)
				While !Eof() .And. RAE->RAE_FILIAL+RAE->RAE_MAT ==;
									 xFilial("RAE")+cMat
					RecLock("RAE",.F.)
						dbDelete()
					MsUnlock()
					dbSkip()
				EndDo
			EndIf
		EndIf

		// Periodos de estabilidade
		If SX2->(MSSeek("RFX"))
			dbSelectArea("RFX")
			dbSetOrder(1)
			If dbSeek(xFilial("RFX")+cMat)
				While !Eof() .And. RFX->RFX_FILIAL+RFX->RFX_MAT ==;
									 xFilial("RFX")+cMat
					RecLock("RFX",.F.)
						dbDelete()
					MsUnlock()
					dbSkip()
				EndDo
			EndIf
		EndIf

		// Aviso Previo
		If SX2->(MSSeek("RFY"))
			dbSelectArea("RFY")
			dbSetOrder(1)
			If dbSeek(xFilial("RFY")+cMat)
				While !Eof() .And. RFY->RFY_FILIAL+RFY->RFY_MAT ==;
									 xFilial("RFY")+cMat
					RecLock("RFY",.F.)
						dbDelete()
					MsUnlock()
					dbSkip()
				EndDo
			EndIf
		EndIf

		// Sucessao de Vinculos
		If SX2->(MSSeek("RFZ"))
			dbSelectArea("RFZ")
			dbSetOrder(1)
			If dbSeek(xFilial("RFZ")+cMat)
				While !Eof() .And. RFZ->RFZ_FILIAL+RFZ->RFZ_MAT ==;
									 xFilial("RFZ")+cMat
					RecLock("RFZ",.F.)
						dbDelete()
					MsUnlock()
					dbSkip()
				EndDo
			EndIf
		EndIf

		// Cabecalho Funcionarios Temporarios
		If SX2->(MSSeek("RBW"))
			dbSelectArea("RBW")
			dbSetOrder(1)
			If dbSeek(xFilial("RBW")+cMat)
				While !Eof() .And. RBW->RBW_FILIAL+RBW->RBW_MAT ==;
									 xFilial("RBW")+cMat
					RecLock("RBW",.F.)
						dbDelete()
					MsUnlock()
					dbSkip()
				EndDo
			EndIf
		EndIf

	EndIf

	If lExistRBN
		// Atividades Funcionais
		dbSelectArea("RBN")
		dbSetOrder(1)
		If dbSeek(xFilial("RBN")+cMat)
			While !Eof() .And. RBN->RBN_FILIAL+RBN->RBN_MAT ==;
				xFilial("RBN")+cMat
				RecLock("RBN",.F.)
				dbDelete()
				MsUnlock()
				APDMSMM(RBN_ATIVID,,,,2)
				dbSkip()
			EndDo
		EndIf
	EndIf


	// Deleta arquivo Pai
	// Verifica integracao Datasul EPM
	GPEA010EPMInt(5)

	// Funcionario
	dbSelectArea("SRA")
	dbSetOrder(1)
	If dbSeek(xFilial("SRA")+cMat)
		RecLock("SRA",.F.)
			dbDelete()
		MsUnlock()
	EndIf

	RestArea(aSaveArea)

Return( Nil )

/*/{Protheus.doc} Tr100TudOk
Valida todas as getdados
@type  Function
@author J. Ricardo
@since 15.02/95
@see TRMA100
/*/
Function Tr100TudOk(nOpcx)
Local lRetorna 	:= .T.
Local nOpc		:= 0

	Continua := .F.


	/* 				Configuracao do parametro MV_ORGCFG:
	0	Não utiliza o módulo Arquitetura Organizacional (Padrão).
	1	Utiliza o módulo Arquitetura Organizacional completo.
	2	Utiliza o módulo Arquitetura Organizacional sem controle de postos.
	*/
	If ( cOrgCfg == "1" .And. ( INCLUI .Or. ( ALTERA .And. SRA->RA_SITFOLH <> "D" ) ) )
		If Empty(M->RA_POSTO)
			Aviso( "Atencao","Sistema parametrizado com controle de posto, necessário informar.",{"Ok"},,"Posto não Informado")
			lRetorna:= ORGXPosto(oEnchSra)  //Validacao do posto

		    If !lRetorna
				Return lRetorna
    		EndIf
		EndIf
		//Return .T. // ?? Retirar linha apos validacao da funcao
	EndIf

	If nOpcx == 4 			// Alteracao
		If cEstou == "09"
			SRA->(dbSeek(xFilial("SRA")+M->RA_MAT) )
		EndIf
		If !Gp010AltSal()
			Return .F.
		EndIf

		If 	SRA->RA_CODFUNC # M->RA_CODFUNC
			nOpc := AVISO(STR0036,STR0039,{STR0040,STR0041})  //"Aviso"###"Foi Alterado a Funcao.O Grupo do Cargo atual esta diferente do anterior."###"Confirma"###"Redigita"
			If nOpc == 2
				Return .F.
			EndIf
		EndIf
	EndIf

	lRetorna := Tr100VlTree(nOpcx,2)
	// P.E.-Validar o cadastro e nao permitir sair se retornar .F.
 	If lRetorna .And. ExistBlock("TRMA100OK")
		lRetorna := ExecBlock("TRMA100OK",.F.,.F.)
	EndIf

Return( lRetorna )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Tr100List ³ Autor ³ Cristina Ogura		³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta o listbox											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias											  ³±±
±±³			 ³ ExpN1 : Registro											  ³±±
±±³			 ³ ExpN2 : Opcao											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TRMA100		 											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr100List(aListBox,nTipo)
Local aSaveArea	:= GetArea()
Local cCodCargo	:= CriaVar("RA_CARGO")
Local cCodCC	:= CriaVar("RA_CC")
Local cCodFuncao:= CriaVar("RA_CODFUNC")
Local lQGint	:= FlQGInt() //Integracao Quality
Local nx        := 0
Local nCont		:= 0

	If nTipo == 2				// Graduacao
		cCodCargo	:= Iif(Empty(M->RA_CARGO), fGetCargo(SRA->RA_MAT), M->RA_CARGO)
		cCodCC		:= M->RA_CC

		dbSelectArea("SQ3")
		dbSetOrder(1)
		If dbSeek(xFilial("SQ3")+cCodCargo+cCodCC) .Or. dbSeek(xFilial("SQ3")+cCodCargo)

			dbSelectArea("SQ4")
			dbSetOrder(2)
			If dbSeek(xFilial("SQ4")+cCodCargo+SQ3->Q3_CC)
				While !Eof() .And. xFilial("SQ4")+cCodCargo+SQ3->Q3_CC == ;
					SQ4->Q4_FILIAL+SQ4->Q4_CARGO+SQ4->Q4_CC

					dbSelectArea("SQ1")
					dbSetOrder(1)
					If dbSeek(xFilial("SQ1")+SQ3->Q3_GRUPO+SQ4->Q4_FATOR)
						dbSelectArea("SQ2")
						dbSetOrder(1)
						If dbSeek(xFilial("SQ2")+SQ3->Q3_GRUPO+SQ4->Q4_FATOR+SQ4->Q4_GRAU)
							Aadd(aListBox,{SQ4->Q4_FATOR,SQ1->Q1_DESCSUM,SQ4->Q4_GRAU,SQ2->Q2_DESC, SQ4->Q4_PONTOS})
						EndIf
					EndIf

					dbSelectArea("SQ4")
					dbSkip()
				EndDo
		 	EndIf
		EndIf

		If Len(aListBox) == 0
			aAdd(aListBox,{Space(2), Space(30), Space(2), Space(30), 0.000})
		EndIf
	ElseIf nTipo == 3 		// Cursos
		If cModulo == "TRM" .OR. cModulo == "MDT" .OR. lQGint
			cCodCargo	:= Iif(Empty(M->RA_CARGO), fGetCargo(SRA->RA_MAT), M->RA_CARGO)
			cCodFuncao	:= M->RA_CODFUNC
			cCodCC		:= M->RA_CC

			dbSelectArea("SQ3")
			dbSetOrder(1)
			If dbSeek(xFilial("SQ3")+cCodCargo+cCodCC) .Or. dbSeek(xFilial("SQ3")+cCodCargo)

				// Cursos do Cargo
				dbSelectArea("RA5")
				dbSetOrder(2)
				If dbSeek(xFilial("RA5")+cCodCargo+SQ3->Q3_CC)
					While !Eof() .And. xFilial("RA5")+cCodCargo+SQ3->Q3_CC ==;
						RA5_FILIAL+RA5_CARGO+RA5_CC

						dbSelectArea("RA1")
						dbSetOrder(1)
						If dbSeek(xFilial("RA1")+RA5->RA5_CURSO)

							Aadd(aListBox,{RA5->RA5_CURSO,RA1->RA1_DESC,RA5->RA5_VALIDA,RA5->RA5_HORAS,RA5->RA5_NOTA,RA5->RA5_FREQUE,RA5->RA5_EFICAC,STR0077})//"Cargo"

							If (Len(aContRA5) > 0) .OR.  (Len(aContRA1) > 0)

								For	nx:= 1 to Len(aContRA5)
							  		Aadd(aListBox[Len(aListBox)], RA5->&(aContRA5[nx]))
								Next

								For	nx:= 1 to Len(aContRA1)
									//Aadd(aListBox[], &("RA1->"+aContRA1[nx][1]))
									Aadd(aListBox[Len(aListBox)], RA1->&(aContRA1[nx][1]))
								Next

							Endif
						EndIf

						dbSelectArea("RA5")
						dbSkip()
					EndDo
				EndIf
			EndIf

			// Cursos da Funcao
			dbSelectArea("RAL")
			dbSetOrder(1)
			If dbSeek(xFilial("RAL")+cCodFuncao)
				While !Eof() .And. xFilial("RAL")+cCodFuncao ==;
					RAL_FILIAL+RAL_FUNCAO

					dbSelectArea("RA1")
					dbSetOrder(1)
					If dbSeek(xFilial("RA1")+RAL->RAL_CURSO)
						Aadd(aListBox,{RAL->RAL_CURSO,RA1->RA1_DESC,RAL->RAL_VALIDA,RAL->RAL_HORAS,RAL->RAL_NOTA,RAL->RAL_FREQUE,RAL->RAL_EFICAC,STR0078})//"Funcao"
					EndIf

					dbSelectArea("RAL")
					dbSkip()
				EndDo
			EndIf

			If Len(aListBox) == 0
				aAdd(aListBox,{Space(5),Space(30),Space(10),Space(10),Space(10),Space(10),Space(6),Space(10)})
			EndIf
		EndIf

	ElseIf nTipo == 10

		cCodCargo	:= Iif(Empty(M->RA_CARGO), fGetCargo(SRA->RA_MAT,SRA->RA_FILIAL), M->RA_CARGO)
		cCodCC		:= M->RA_CC

	    dbSelectArea("SQ3")
		dbSetOrder(1)

		If dbSeek(xFilial("SQ3")+cCodCargo+cCodCC) .Or. dbSeek(xFilial("SQ3")+cCodCargo)

	    	dbSelectArea("RBH")
	   		dbSetOrder(2)
			If dbSeek(xFilial("RBH")+SQ3->Q3_GRUPO+cCodCargo+cCodCC)
				While !Eof() .And. xFilial("RBH")+SQ3->Q3_GRUPO+cCodCargo+cCodCC == ;
					RBH->RBH_FILIAL+RBH->RBH_GRUPO+RBH->RBH_CARGO+RBH->RBH_CC

					Aadd(aListBox,{RBH->RBH_HABIL,FDesc("RBG",RBH->RBH_HABIL,"RBG_DESC"),RBH->RBH_ESCALA,FDesc("RBK",RBH->RBH_ESCALA,"RBK_DESCRI"),RBH->RBH_ITESCA,FDesc("RBL",RBH->RBH_ESCALA+RBH->RBH_ITESCA,"RBL_DESCRI")})

		        	dbSelectArea("RBH")
		        	dbSkip()
		    	EndDo
		    Else
		    cCodCC := Space(TamSx3("RBH_CC")[1])

		     	If dbSeek(xFilial("RBH")+SQ3->Q3_GRUPO+cCodCargo+cCodCC)
		     		While !Eof() .And. xFilial("RBH")+SQ3->Q3_GRUPO+cCodCargo+cCodCC == ;
		     		RBH->RBH_FILIAL+RBH->RBH_GRUPO+RBH->RBH_CARGO+RBH->RBH_CC

				   		Aadd(aListBox,{RBH->RBH_HABIL,FDesc("RBG",RBH->RBH_HABIL,"RBG_DESC"),RBH->RBH_ESCALA,FDesc("RBK",RBH->RBH_ESCALA,"RBK_DESCRI"),RBH->RBH_ITESCA,FDesc("RBL",RBH->RBH_ESCALA+RBH->RBH_ITESCA,"RBL_DESCRI")})

				   		dbSelectArea("RBH")
		           		dbSkip()

		        	EndDo
		       	Endif
		    cCodCC := SRA->RA_CC
		    EndIf
	    EndIf

		If Len(aListBox) == 0
			aAdd(aListBox,{Space(6),Space(60),Space(2),Space(20),Space(2),Space(20)})
		EndIf

	EndIf

	RestArea(aSaveArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Tr100Vltree ³ Autor ³ Cristina Ogura	 	³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra o Tree dos funcionario 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias											  ³±±
±±³			 ³ ExpN1 : Registro											  ³±±
±±³			 ³ ExpN2 : Opcao											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TRMA100		 											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr100VlTree(nOpcx,nOnde)
Local lRet	    := .T.
//Variaveis utilizadas no P.E. GPE10HIST
Local nTipoOper := 3
Local bCond     := {|x| ( (	 SRA->RA_SALARIO # M->RA_SALARIO .OR. SRA->RA_CODFUNC # M->RA_CODFUNC .OR. ;
							 SRA->RA_CATFUNC # M->RA_CATFUNC .or. SRA->RA_CARGO # M->RA_CARGO ) .And. nOpcx == 4 ;
			                )}
Local bCondAux
Local cCond     :=  ""

	cCond := '( SRA->RA_SALARIO # M->RA_SALARIO .OR. SRA->RA_CODFUNC # M->RA_CODFUNC .OR. '
	cCond += '  SRA->RA_CATFUNC # M->RA_CATFUNC .or. SRA->RA_CARGO # M->RA_CARGO ) .And. nOpcx == 4 '

	If nOpcx # 2 .And. nOpcx # 5			// Diferente de visual e delecao
		If cEstou == "01"

			// Checa campos obrigatorios
			lRet:= Obrigatorio(aGets,aTela)

			//Verifica alteracao salarial somente quando for alteracao do registro
			If nOpcx # 3
				Iif(lRet, lRet := Gp010AltSal(), Nil)
			EndIf

			// Verifica preenchimento de Tabela Salarial
			If lRet
				If 	!Empty( AllTrim(M->RA_TABELA)+Alltrim(M->RA_TABNIVE)+Alltrim(M->RA_TABFAIX) ) .And.; 	// Se tiver algum campo preenchido e
					( Empty(M->RA_TABELA) .Or. Empty(M->RA_TABNIVE) .Or. Empty(M->RA_TABFAIX) )   		// Algum campo estiver em branco
						Aviso(STR0036,STR0044,{"Ok"})	//"Aviso"###"Tabela, Nivel e Faixa devem estar todos preenchidos ou todos em branco."
					lRet := .F.
				EndIf

			EndIf

			// Alimenta aCols de Historico Salarial
			If lRet
				If cModulo == "CSA" .Or. cModulo == "ORG"
					//P.E. para alterar a condicao (bCond) padrao do sistema para gravacao do historico de alteracao de salarios
					If ExistBlock("GPE10HIST")
						bCondAux := ExecBlock("GPE10HIST",.F.,.F.,{nTipoOper,bCond,cCond})
						bCond    := If( ValType(bCondAux) = "B" , bCondAux , bCond )   //--Somente altera condicao padrao do sistema se o retorno do P.E. for um bloco de codigo
					EndIf
					// Verifica se Houve alteracao Salarial ou Afastamento e for alteracao
					If Eval( bCond )
						//--Funcao Para alimentar aCols Historico Salarial
						Tr100Sr7()
					EndIf
				EndIf
			EndIf

		ElseIf cEstou == "02"
			lRet:= Tr100Ok2("S")

		ElseIf cEstou == "03"
			If cModulo == "TRM" .OR. cModulo == "MDT" .OR. lQGint
				lRet:= Tr100Ok3("S")
			EndIf

		ElseIf cEstou == "04"
			lRet:= Tr100Ok4("S")

		ElseIf cEstou == "05"
			If cModulo == "CSA" .Or. cModulo == "ORG"
				lRet := Eval( bSR7SR3Ok , NIL , NIL , .F. )
			EndIf

		ElseIf cEstou == "06"
			lRet:= Tr100Ok6("S")

		ElseIf cEstou == "07"
			If cModulo == "TRM" .OR. cModulo == "MDT" .OR. lQGint
				lRet:= Tr100Ok7("S")
			EndIf

		ElseIf cEstou == "08"

			lRet:= Tr100Ok8("S")

		ElseIf cEstou == "09"
			If cModulo == "TRM" .OR. cModulo == "MDT" .OR. lQGint
				lRet:= Tr100Ok9("S")
			EndIf

		ElseIf cEstou == "10"
			lRet:= Tr100Ok10("S")

		ElseIf cEstou == "11"
			lRet:= Tr100Ok11("S")
		EndIf

	EndIf

Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Tr100Zera ³ Autor ³ Cristina Ogura		³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Zera o acols												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TRMA100		 											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr100Zera(cAlias)
Local nx	:= 0
Local lRet	:= .T.

	nPosAlias:= GdFieldPos(cAlias+"_ALI_WT")
	nPosRec  := GdFieldPos(cAlias+"_REC_WT")

	For nx := 1 To Len(aHeader)
		// Desprezar tamanho = 1
		If aHeader[nx][4] != 1   .and.  nx <> nPosAlias .and. nx <> nPosRec  //Exceto campos:  Alias WT  e Recno WT
			If !Empty(aCols[1][nx])
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next nx

	If lRet
		aCols:={}
	EndIf

Return( Nil )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Tr100Guarda ³ Autor ³ Cristina Ogura	    ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Guarda o aCols e aHeaders								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TRMA100		 											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr100Guarda()
Local aSaveArea	:= GetArea()
Local cCodCargo	:= ""
Local cCodCC	:= Space(9)
Local lQGint	:= FlQGInt() //Integracao Quality

	If cEstou == "01"
		oEnchSRA:Hide()
		cMat		:= M->RA_MAT
		cNome		:= M->RA_NOME
		cGet		:= cMat + " - " + If(lOfuscaNom,Replicate('*',15),cNome)
		cCodCargo	:= Iif(Empty(M->RA_CARGO), fGetCargo(SRA->RA_MAT), M->RA_CARGO)
		cCodCC		:= M->RA_CC

		dbSelectArea("SQ3")
		dbSetOrder(1)
		If dbSeek(xFilial("SQ3")+cCodCargo+cCodCC) .Or. dbSeek(xFilial("SQ3")+cCodCargo)
			cGrupo := SQ3->Q3_GRUPO
		EndIf

	ElseIf cEstou == "02"

		o2Get:oBrowse:lDisablePaint := .T.
		o2Get:Hide()
		o2Get:oBrowse:Hide()
		o2Lbx:Hide()
		o2Group1:Hide()
		o2Group2:Hide()
		TR100FAHide()

	   aListPast[Val(cEstou)][2]:=	 aClone(aCols)

	ElseIf cEstou == "03"

		Iif(cModulo == "TRM" .OR. cModulo == "MDT" .OR. lQGint, o3Get:oBrowse:lDisablePaint := .T.,)

		If cModulo == "TRM" .OR. cModulo == "MDT" .OR. lQGint
			o3Get:Hide()
			o3Get:oBrowse:Hide()
			o3Lbx:Hide()
			o3Group1:Hide()
			o3Group2:Hide()
			If lQGint
				o3Bot1:Hide()
			EndIf
		EndIf

	    aListPast[Val(cEstou)][2]:=	 aClone(aCols)

	ElseIf cEstou == "04"
		o4Get:oBrowse:lDisablePaint := .T.

		o4Get:Hide()
		o4Get:oBrowse:Hide()
		o4Group1:Hide()

	   aListPast[Val(cEstou)][2]:=	 aClone(aCols)

	ElseIf cEstou == "05"

		If cModulo == "CSA" .Or. cModulo == "ORG"
			// Transfere os Dados do aCols para o aColsAll
			Gpea250AllTrf(	"SR7" 			,;	//01 -> Alias do Arquivo
							Nil				,;	//02 -> Objeto GetDados para o SR7
							oGetSR7:aCols	,;	//03 -> aCols utilizado na GetDados
							oGetSR7:aHeader	,;	//04 -> aHeader utilizado na GetDados
							@aColsR7All		,;	//05 -> aCols com todas as informacoes
							aHeaderR7All	,;	//06 -> aHeader com todos os campos
							.T.				,;	//07 -> Se carrega elemento de Deletado na remontagem do aCols
							.T.				,;	//08 -> Se transfere do aCols para o aColsAll
							.T.				 ;	//09 -> Se transfere do aColsAll para o aCols
						  )

			aColsR7	:= aClone(oGetSR7:aCols)

			oGetSR7:Hide()
			oGetSR7:oBrowse:Hide()
			oGetSr3:Hide()
			oGetSr3:oBrowse:Hide()
			o5Group1:Hide()
		EndIf

	ElseIf cEstou == "06"

		o6Get:oBrowse:lDisablePaint := .T.
		o6Get:Hide()
		o6Get:oBrowse:Hide()
		o6Group1:Hide()
	    aListPast[Val(cEstou)][2]:=	 aClone(aCols)
	ElseIf cEstou == "07"
	 	Iif(cModulo == "CSA" .Or. cModulo == "ORG", oGetSR7:oBrowse:lDisablePaint := .T.,)
	 	Iif(cModulo == "TRM" .OR. cModulo == "MDT" .OR. lQGint, o7Get:oBrowse:lDisablePaint := .T.,)

		If cModulo == "TRM" .OR. cModulo == "MDT" .OR. lQGint
			o7Get:Hide()
			o7Get:oBrowse:Hide()
			o7Group1:Hide()
	 	    aListPast[Val(cEstou)][2]:=	 aClone(aCols)
		EndIf

	ElseIf cEstou == "08"

		o8Get:oBrowse:lDisablePaint := .T.
		o8Get:Hide()
		o8Get:oBrowse:Hide()
		o8Group1:Hide()
	    aListPast[Val(cEstou)][2]:=	 aClone(aCols)
	ElseIf cEstou == "09"

		If cModulo == "TRM" .OR. cModulo == "MDT" .OR. lQGint
			o9Get:Hide()
			o9Get:oBrowse:Hide()
			o9Lbx:Hide()
			o9Group1:Hide()
			o9Group2:Hide()
			oF4:LVISIBLECONTROL:=.F.
			o9Bot1:Hide()
			o9Bot2:Hide()

			aSvGetD[o9Lbx:nat][1] 	:=	aClone(aHeader)
			aSvGetD[o9Lbx:nat][2]	:=	aClone(aCols)

			SetKey( VK_F4 , { || NIL } )
		EndIf

	ElseIf cEstou == "10"

		o10Get:oBrowse:lDisablePaint := .T.
		o10Get:Hide()
		o10Get:oBrowse:Hide()
		o10Lbx:Hide()
		o10Group1:Hide()
		o10Group2:Hide()

	   aListPast[Val(cEstou)][2]:=	 aClone(aCols)

	ElseIf cEstou == "11"

		Iif(lExistRBN, o11Get:oBrowse:lDisablePaint := .T.,)
		o11Get:Hide()
		o11Get:oBrowse:Hide()
		o11Group1:Hide()

	   aListPast[Val(cEstou)][2]:=	 aClone(aCols)

	EndIf

	RestArea(aSaveArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Tr100Exist³ Autor ³ Cristina Ogura		³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se existe o registro 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias											  ³±±
±±³			 ³ ExpN1 : Registro											  ³±±
±±³			 ³ ExpN2 : Opcao											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TRMA100		 											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr100Exist(nTipo)
Local aSaveArea	:= GetArea()
Local lRet		:= .T.
Local cVar 		:= &(ReadVar())
Local nPosCur   := 0

	If nTipo == 1				// Curso
		dbSelectArea("RA1")
		dbSetOrder(1)
		If !dbSeek(xFilial("RA1")+cVar)
			Help("",1,"REGNOIS")
			lRet:= .F.
		EndIf
	ElseIf nTipo == 2 		// Entidade
		dbSelectArea("RA0")
		dbSetOrder(1)
		If !dbSeek(xFilial("RA0")+cVar)
			Help("",1,"REGNOIS")
			lRet:= .F.
		Else
			If IsInCallStack('TRMA100')
				nPosCur 	:= GdFieldPos("RA4_CURSO")

				If !aCols[n,Len(aCols[n])] .And. !Empty(aCols[n][nPosCur]) .And. !Empty(cVar)
					If !VrfRA6(aCols[n][nPosCur],cVar)
						Help("",1,"TRA100VIN")
						lRet:= .F.
					EndIf
				EndIf
			EndIf
		EndIf
	ElseIf nTipo == 3 		// Sinonimo
		dbSelectArea("RA9")
		dbSetOrder(1)
		If !dbSeek(xFilial("RA9")+cVar)
			Help("",1,"REGNOIS")
			lRet:= .F.
		EndIf
	EndIf

	RestArea(aSaveArea)

Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Tr100RetDesc ³ Autor ³ Cristina Ogura	³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Traz o retorno da descricao dos campos 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias											  ³±±
±±³			 ³ ExpN1 : Registro											  ³±±
±±³			 ³ ExpN2 : Opcao											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TRMA100		 											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr100RetDesc()
Local aSaveArea	:= GetArea()
Local cVar		:= Alltrim((ReadVar()))
Local cRetorno  := ""
Local nPos		:= nPos1 := nPos2 := 0

	If cVar == "M->RA4_CURSO"
		cRetorno:= CriaVar("RA4_CURSO")
		nPos	:= 0
		nPos	:= GdFieldPos("RA4_DESCCU")
		cRetorno:= TrmDesc("RA1",M->RA4_CURSO,"RA1->RA1_DESC")
	    If nPos>0
			aCols[n][nPos] := cRetorno
		Else
		    M->RA4_DESCCU:=cRetorno
		Endif
	ElseIf cVar == "M->RA4_SINONI"
		cRetorno:= CriaVar("RA4_SINONI")
		nPos	:= 0
		nPos1 	:= 0
		nPos2 	:= 0
		nPos	:= GdFieldPos("RA4_DESCSI")
		nPos1 	:= GdFieldPos("RA4_CURSO")
		nPos2 	:= GdFieldPos("RA4_DESCCU")
		dbSelectArea("RA9")
		dbSetOrder(1)
		If dbSeek(xFilial("RA9")+M->RA4_SINONI)
			If nPos>0
				aCols[n][nPos] := RA9->RA9_DESCR
				aCols[n][nPos1]:= RA9->RA9_CURSO
				aCols[n][nPos2]:= TrmDesc("RA1",aCols[n][nPos1],"RA1->RA1_DESC",RA4->RA4_FILIAL)
		    Else
		    	M->RA4_DESCSI:=TrmDesc("RA1",M->RA4_CURSO,"RA1->RA1_DESC",RA4->RA4_FILIAL)
		    Endif
		EndIf
	ElseIf cVar == "M->RA3_CURSO"
		cRetorno:= CriaVar("RA3_CURSO")
		nPos	:= 0
		nPos	:= GdFieldPos("RA3_DESC")
		cRetorno:= TrmDesc("RA1",M->RA3_CURSO,"RA1->RA1_DESC")
		aCols[n][nPos] := cRetorno

	ElseIf cVar == "M->RA4_ENTIDA"
		cRetorno:= CriaVar("RA4_ENTIDA")
		nPos	:= 0
		nPos	:= GdFieldPos("RA4_DESCEN")
		cRetorno:= TrmDesc("RA0",M->RA4_ENTIDA,"RA0->RA0_DESC")
		If nPos>0
			aCols[n][nPos]:= cRetorno
		Else
		    M->RA4_DESCEN:=cRetorno
		Endif
	ElseIf cVar == "M->Q8_FATOR"
		cRetorno:= CriaVar("Q8_FATOR")
		nPos	:= 0
		nPos	:= GdFieldPos("Q8_DESCFAT")
		cRetorno:= TrmDesc("SQV",M->Q8_FATOR,"SQV->QV_DESCFAT")
		aCols[n][nPos]:= cRetorno

	ElseIf cVar == "M->RAF_FATOR"
		cRetorno:= CriaVar("RAF_FATOR")
		nPos	:= 0
		nPos	:= GdFieldPos("RAF_DESCFA")
		cRetorno:= TrmDesc("SQV",M->RAF_FATOR,"SQV->QV_DESCFAT")
		aCols[n][nPos]:= cRetorno

	ElseIf cVar == "M->Q8_GRAU"
		cRetorno:= CriaVar("Q8_GRAU")
		nPos	:= 0
		nPos1 	:= 0
		nPos	:= GdFieldPos("Q8_DESCGRA")
		nPos1 	:= GdFieldPos("Q8_FATOR")
		cRetorno:= TrmDesc("SQV",aCols[n][nPos1]+M->Q8_GRAU,"SQV->QV_DESCGRA")
		aCols[n][nPos]:= cRetorno

	EndIf

	RestArea(aSaveArea)

Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Tr100Calend  ³ Autor ³ Cristina Ogura	³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se existe o curso no calendario					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TRMA100		 											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr100Calend()
Local aSaveArea	:= GetArea()
Local nPosCurso	:= GdFieldPos("RA3_CURSO")
Local nPosTurma	:= GdFieldPos("RA3_TURMA")
Local cVar		:= &(ReadVar())
Local lRet		:= .F.

	dbSelectArea("RA2")
	dbSetOrder(1)
	If dbSeek(xFilial("RA2")+cVar)
		While !Eof() .And. xFilial("RA2")+cVar ==;
			RA2->RA2_FILIAL+RA2->RA2_CALEND
			If aCols[n][nPosCurso] == RA2->RA2_CURSO .And.;
				aCols[n][nPosTurma] == RA2->RA2_TURMA
				lRet := .T.
				Exit
			EndIf
			dbSkip()
		EndDo
	EndIf

	If !lRet
		Help("",1,"TRA100CALE")
	EndIf

	RestArea(aSaveArea)

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Tr100Linha	³ Autor ³ Cristina Ogura	³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a primeira linha esta toda sem preencher		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TRMA100		 											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr100Linha(cAlias)
Local lTree := .T.
Local nx	:= 0
Local nPosAlias
Local nPosRec

	cAlias:= IIf(Substr(cAlias,1,1)=="S",Substr(cAlias,2,2),cAlias)
	nPosAlias:= GdFieldPos(cAlias+"_ALI_WT")
	nPosRec  := GdFieldPos(cAlias+"_REC_WT")

	For nx:=1 To Len(aHeader)
		// Desprezar tamanho = 1
		If aHeader[nx][4] != 1 	.and.  nx <> nPosAlias .and. nx <> nPosRec  //Exceto campos:  Alias WT  e Recno WT
			If !Empty(aCols[1][nx])
				lTree := .F.
				Exit
			EndIf
		EndIf
	Next nx

Return( lTree )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Tr100Turma	³ Autor ³ Cristina Ogura	³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se existe a turma para o curso				  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TRMA100		 											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr100Turma()
Local aSaveArea	:= GetArea()
Local cVar 		:= &(ReadVar())
Local nPosCurso := GdFieldPos("RA3_CURSO")
Local lRet		:= .T.

	dbSelectArea("RA2")
	dbSetOrder(2)
	If !dbSeek(xFilial("RA2")+aCols[n][nPosCurso]+cVar)
		Help("",1,"TRA100TURM")             // Turma para o curso nao existente verifique
		lRet := .F.
	EndIf

	dbSetOrder(1)

	RestArea(aSaveArea)

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr100Grau	³ Autor ³ Cristina Ogura    ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica o grau	                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso	     ³ TRMA100	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr100Grau()
Local aSaveArea	:= GetArea()
Local cVar		:= &(ReadVar())
Local nPosFator	:= GdFieldPos("Q8_FATOR")
Local nPosPtos	:= GdFieldPos("Q8_PONTOS")
Local nPosGrau	:= GdFieldPos("Q8_GRAU")
Local cGrau		:= aCols[n][nPosGrau]
Local cFator	:= aCols[n][nPosFator]

	dbSelectArea("SQV")
	dbSetOrder(1)
	If !dbSeek(xFilial("SQV")+cFator+cVar)
		Help(" ",1,"TRA100NGRA")
		RestArea(aSaveArea)
		Return .F.
	EndIf

	dbSelectArea("SQ8")
	dbSetOrder(1)
	dbSeek(xFilial("SQ8")+cMat+cFator)
	If nPosPtos > 0
		If SQ8->Q8_PONTOS == 0 .Or.;
		 ( SQ8->Q8_FATOR != cFator .Or. cGrau != cVar )
			dbSelectArea("SQ2")
			dbsetorder(1)
			If dbseek(xFilial("SQ2")+cGrupo+cFator+cVar) // Se houver fator no grupo da pessoa, mostra a pontuação
				aCols[n][nPosPtos] := SQ2->Q2_PONTOSI
			Else // Se não houver fator no grupo da pessoa apenas zera a pontuação
				aCols[n][nPosPtos] := 0
			EndIf
		EndIf
	EndIf

	// Atualizar SRA
	dbSelectArea("SQ1")
	dbSetOrder(3)
	cGraduac := ""
	If dbSeek(xFilial("SQ1")+cFator) .And. SQ1->Q1_IDENT == "002"
		dbSelectArea("SQN")
		dbSetOrder(1)
		If dbSeek(xFilial("SQN")+cGrupo+cFator+cVar)
			cGraduac := Left(SQN->QN_DE , 2)
		EndIf
	EndIf

	RestArea(aSaveArea)

Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Tr100AuxG   ³ Autor ³ Cristina Ogura	    ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Guarda o aCols e aHeaders quando sair da Tela			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TRMA100		 ³											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr100AuxG()
Local aSaveArea	:= GetArea()
Local cCodCargo	:= ""
Local cCodCC	:= Space(9)

	If cEstou == "01"
		cMat		:= M->RA_MAT
		cNome 		:= M->RA_NOME
		cGet		:= cMat + " - " + If(lOfuscaNom,Replicate('*',15),cNome)
		cCodCargo	:= Iif(Empty(M->RA_CARGO), fGetCargo(SRA->RA_MAT), M->RA_CARGO)
		cCodCC		:= M->RA_CC

		dbSelectArea("SQ3")
		dbSetOrder(1)
		If dbSeek(xFilial("SQ3")+cCodCargo+cCodCC) .Or. dbSeek(xFilial("SQ3")+cCodCargo)
			cGrupo := SQ3->Q3_GRUPO
		EndIf

	ElseIf cEstou == "05"

		If cModulo == "CSA" .Or. cModulo == "ORG"
			// Transfere os Dados do aCols para o aColsAll
			Gpea250AllTrf(	"SR7" 			,;	//01 -> Alias do Arquivo
							Nil				,;	//02 -> Objeto GetDados para o SR7
							oGetSR7:aCols		,;	//03 -> aCols utilizado na GetDados
							oGetSR7:aHeader	,;	//04 -> aHeader utilizado na GetDados
							@aColsR7All		,;	//05 -> aCols com todas as informacoes
							@aHeaderR7All	,;	//06 -> aHeader com todos os campos
							.T.				,;	//07 -> Se carrega elemento de Deletado na remontagem do aCols
							.T.				,;	//08 -> Se transfere do aCols para o aColsAll
							.F.				 ;	//09 -> Se transfere do aColsAll para o aCols
						  )

			aColsR7	:= Aclone(oGetSR7:aCols)
		EndIf


	ElseIf cEstou == "09"
		If cModulo == "TRM" .OR. cModulo == "MDT" .OR. lQGint
			aSvGetD[nPos9][1]	:=	aClone(aHeader)
			aSvGetD[nPos9][2]	:=	aClone(aCols)
		EndIf

	EndIf

	If cModulo == "CSA" .Or. cModulo == "ORG"
		// Transfere os Dados do aColsAll para o aCols
		Gpea250AllTrf(	"SR7" 			,;	//01 -> Alias do Arquivo
						oGetSR7			,;	//02 -> Objeto GetDados para o SR7
						@oGetSR7:aCols	,;	//03 -> aCols utilizado na GetDados
						@oGetSR7:aHeader	,;	//04 -> aHeader utilizado na GetDados
						aColsR7All		,;	//05 -> aCols com todas as informacoes
						aHeaderR7All	,;	//06 -> aHeader com todos os campos
						.T.				,;	//07 -> Se carrega elemento de Deletado na remontagem do aCols
						.F.				,;	//08 -> Se transfere do aCols para o aColsAll
						.T.				 ;	//09 -> Se transfere do aColsAll para o aCols
					  )

		aColsR7 	:= Aclone(oGetSR7:aCols)
	EndIf

	RestArea(aSaveArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Tr100Relac  ³ Autor ³ Cristina Ogura	    ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao executada no X3_RELACAO para atualizar as descricoes³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TRMA100		 ³											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr100Relac(cAlias, cCpoRet, cCodPesq)
Local aSaveArea	:= GetArea()
Local nPos		:= 0
Local cConteudo := ""
Local cRet      := ""

	nPos := GdFieldPos(cCodPesq)
	If nPos > 0
		cConteudo := aCols[Len(aCols),nPos]
	Endif

	If "CURSO" $ AllTrim(cCodPesq)
		cRet := TrmDesc(cAlias,cConteudo,"RA1->RA1_DESC")
	ElseIf "SINONI" $	Alltrim(cCodPesq)
		cRet := TrmDesc(cAlias,cConteudo,"RA9->RA9_DESCR")
	ElseIf "ENTIDA" $ Alltrim(cCodPesq)
		cRet := TrmDesc(cAlias,cConteudo,"RA0->RA0_DESC")
	EndIf

	RestArea(aSaveArea)

Return( cRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Tr100Seq    ³ Autor ³ Cristina Ogura	  	³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que permite ser informado a sequencia da lista      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TRMA100		 ³											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr100Seq()
Local nPos	:= GdFieldPos("RA3_RESERV")

	// So posso informar sequencia se for uma lista de espera
	If aCols[n][nPos] # "L"
		Help("",1,"Tr100NList")   	// Só pode ser informado sequencia para lista de espera
		Return .F.
	EndIf

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr100Alter ³ Autor ³ Cristina Ogura      ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica os campos que podem ser alterados na getdados     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr100Alter(aAlter,nQual)
Local aSaveArea	:= GetArea()
Local cAuxAlias	:= ""

	If nQual == 1				// RA4 - Cursos do funcionario
		Aadd(aAlter,"RA4_CURSO ")
		Aadd(aAlter,"RA4_SINONI")
		Aadd(aAlter,"RA4_ENTIDA")
		Aadd(aAlter,"RA4_VALIDA")
		Aadd(aAlter,"RA4_NOTA  ")
		Aadd(aAlter,"RA4_UNDURA")
		Aadd(aAlter,"RA4_DURACA")
		Aadd(aAlter,"RA4_PRESEN")
		Aadd(aAlter,"RA4_DATAIN")
		Aadd(aAlter,"RA4_DATAFI")
		Aadd(aAlter,"RA4_VALOR ")
		Aadd(aAlter,"RA4_HORAS ")
		Aadd(aAlter,"RA4_EFICAC")
		Aadd(aAlter,"RA4_EFICSN")
		If RA4->(ColumnPos("RA4_CATCUR")) > 0
			Aadd(aAlter,"RA4_CATCUR")
		EndIf

		cAuxAlias := "RA4"

	ElseIf nQual == 2			// RA3 - Solicitacao de Treinamento
		Aadd(aAlter,"RA3_CURSO ")
		Aadd(aAlter,"RA3_DATA  ")
		cAuxAlias:= "RA3"

	ElseIf nQual == 3			// RAI - Avaliacoes
		Aadd(aAlter,"RAI_QUESTA")
		Aadd(aAlter,"RAI_ALTERN")
		Aadd(aAlter,"RAI_MRESPO")
		Aadd(aAlter,"RAI_RESULT")
		Aadd(aAlter,"RAI_MEMO1 ")
		cAuxAlias:= "RAI"
	EndIf

	// Verifica se o usuario criou algum campo no arquivo relacionado
	dbSelectArea("SX3")
	dbSeek(cAuxAlias)
	While !Eof() .And. (X3_ARQUIVO == cAuxAlias)
		If X3_PROPRI == "U"
			Aadd(aAlter,X3_CAMPO)
		EndIf
		dbSkip()
	EndDo

	RestArea(aSaveArea)

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr100RA3	  ³ Autor ³ Cristina Ogura      ³ Data ³ 10.01.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza os campos RA3_DATA e RA3_RESERV                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr100RA3()
Local nPosData	:= GdFieldPos("RA3_DATA")
Local nPosReser	:= GdFieldPos("RA3_RESERV")

	If nPosData > 0 .And. nPosReser > 0
		aCols[n][nPosData] := dDataBase
		aCols[n][nPosReser]:= "S"
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Trm100Leg     ³ Autor ³Emerson Grassi    ³ Data ³ 01.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Aciona Legenda de cores da Mbrowse.				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Trm100Leg()

TrmLegenda(1)

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr100VerF     ³ Autor ³Cristina Ogura    ³ Data ³ 16.01.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verificar se todos Fatores de Avaliacao (SQ8 e RAF) no SQV ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr100VerF(lRet,cAuxFil,cAuxMat)
Local aSaveArea	:= GetArea()
Local aSQ8 		:= {}
Local aRAF 		:= {}

	dbSelectArea("SQ8")
	dbSetOrder(1)
	If 	dbSeek(cAuxFil+cAuxMat)
		ProcRegua(SQ8->(Reccount()))
		While !Eof() .And. SQ8->Q8_FILIAL+SQ8->Q8_MAT == cAuxFil+cAuxMat
			IncProc()
			Aadd(aSQ8,{SQ8->Q8_FILIAL,SQ8->Q8_FATOR,SQ8->Q8_GRAU})
			dbSkip()
		EndDo
	EndIf

	If 	!FVerFatG(aSQ8)
		lRet := .F.
	EndIf

	dbSelectArea("RAF")
	dbSetOrder(1)
	If 	dbSeek(cAuxFil+cAuxMat)
		ProcRegua(RAF->(Reccount()))
		While !Eof() .And. RAF->RAF_FILIAL+RAF->RAF_MAT == cAuxFil+cAuxMat
			IncProc()
			Aadd(aRAF,{RAF->RAF_FILIAL,RAF->RAF_FATOR,"01"})
			dbSkip()
		EndDo
	EndIf

	If 	!FVerFatG(aRAF)
		lRet := .F.
	EndIf

	RestArea(aSaveArea)

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Tr100Acres³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza os arrays do listbox em qual operacao efetuada    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr100Acres(ExpN1,ExpO1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nPos = posicao no listbox                                  ³±±
±±³          ³ aVar = Array				                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr100Acres(nPos,aVar)
Local nPosAtu	:= 0

	aVar := IIF(aVar == Nil, {"","","",""}, aVar)

	If Len(a9List) # 0
		nPosAtu	:= Ascan(a9List,{|x| x[1]+x[3]+x[5]+x[6] == aVar[1]+aVar[2]+aVar[3]+aVar[4]}) //Teste
		nPosAtu := IIF(nPosAtu == 0, 1, nPosAtu)
		o9lbx:SetArray(a9List)
		o9lbx:bLine	:= { ||  { a9List[o9lbx:nAt,1],a9List[o9lbx:nAt,2],a9List[o9lbx:nAt,3],;
								a9List[o9lbx:nAt,4],a9List[o9lbx:nAt,5],a9List[o9lbx:nAt,6],;
								a9List[o9lbx:nAt,7],a9List[o9lbx:nAt,8],a9List[o9lbx:nAt,9],;
								a9List[o9Lbx:nAt,10],a9List[o9Lbx:nAt,11],a9List[o9Lbx:nAt,12],;
								a9List[o9Lbx:nAt,13],a9List[o9Lbx:nAt,14],;
								}}
		o9lbx:nAt 	:= nPosAtu
		EVal(o9lbx:bChange)
	EndIf

	o9Lbx:Refresh(.T.)

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Tr100AtuGD³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 12/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta os arrays da getdados qdo selecionar outro teste     ³±±
±±³          ³ no folder 9                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr100AtuGD(ExpN1,ExpN2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ nPos = Posicao no listbox                                  ³±±
±±³          ³ nVar = Indica quem chamou a funcao                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr100AtuGD(nPos,nVar,cEstou)
Local ny		:= 0
Local nPosCalend:= GdFieldPos("RAI_CALEND")
Local nPosCurso	:= GdFieldPos("RAI_CURSO")
Local nPosTurma	:= GdFieldPos("RAI_TURMA")
Local nPosTeste	:= GdFieldPos("RAI_TESTE")

	cEstou := IIF(cEstou == Nil, "01", cEstou)

	If (Len(a9List) == 0 .And. nVar == 1)
		Return .T.
	EndIf
	If nPosCalend > 0 .And. nPosCurso > 0 .And. nPosTurma > 0 .And. nPosTeste > 0
		For ny := 1 To Len(aSvGetD)
			If 	a9List[nPos][1] == aSvGetD[ny][2][1][nPosCalend] .And.;
				a9List[nPos][3] == aSvGetD[ny][2][1][nPosCurso] .And.;
				a9List[nPos][5] == aSvGetD[ny][2][1][nPosTurma] .And.;
				a9List[nPos][6] == aSvGetD[ny][2][1][nPosTeste]

				If nVar == 1
					aHeader	:= aClone(aSvGetD[ny][1])
					aCols  	:= aClone(aSvGetD[ny][2])

				ElseIf nVar == 2
					aSvGetD[ny][1] := aClone(aHeader)
					aSvGetD[ny][2] := aClone(aCols)
				EndIf
			EndIf
		Next ny
	EndIf

	o9Get:oBrowse:Refresh(.T.)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Tr100Listbox³ Autor ³ Cristina Ogura      ³ Data ³ 03.12.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Controle dos dados do ListBox                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr100Listbox(nPos,nList)	                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nPos    = Posicao no ListBox                               ³±±
±±³          ³ nList   = Opcao escolhida atraves dos botoes               ³±±
±±³          ³           1 - inclusao                                     ³±±
±±³          ³           2 - exclusao                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr100Listbox(nPos,nList)
Local aSaveArea	:= GetArea()
Local aSaveSRA	:= SRA->(GetArea())
Local oDlg, oTeste, oDTeste,oCalend, oDCalend, oCurso, oDCurso
Local oTurma, oMatAval, oNomAval
Local cTeste	:= ""
Local cDTeste	:= ""
Local cCalend	:= ""
Local cDCalend	:= ""
Local cCurso	:= ""
Local cDCurso	:= ""
Local cTurma	:= ""
Local nResulta	:= 0
Local cDuraca	:= ""
Local cTipo		:= ""
Local cDTipo	:= ""
Local cMatAval	:= ""
Local cNomAval	:= ""
Local aAuxHeader:= aClone(aListPast[9][1])
Local nOpc1		:= 0
Local nPosCalend := GdFieldPos("RAI_CALEND"	,aAuxHeader)
Local nPosCurso  := GdFieldPos("RAI_CURSO"	,aAuxHeader)
Local nPosTurma	 := GdFieldPos("RAI_TURMA"	,aAuxHeader)
Local nPosTeste	 := GdFieldPos("RAI_TESTE"	,aAuxHeader)
Local nPosDuraca := GdFieldPos("RAI_DURACA"	,aAuxHeader)
Local nPosTipo	 := GdFieldPos("RAI_TIPO"	,aAuxHeader)
Local nPosDTipo	 := GdFieldPos("RAI_DTIPO"	,aAuxHeader)
Local nPosMatAva := GdFieldPos("RAI_MATAVA"	,aAuxHeader)
Local nPosNomAva := GdFieldPos("RAI_NOMAVA"	,aAuxHeader)
// Variaveis para Dimensionar Tela
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local bSet15		:= { || NIL }
Local bSet24		:= { || NIL }

	If Len(a9List) # 0 .And. Empty(a9List[1][1]) .And. nList # 1
		HELP("",1,"A010VERIF")
		Return
	EndIf

	If nList == 2
		cCalend		:= a9List[nPos][1]
		cDCalend	:= a9List[nPos][2]
		cCurso		:= a9List[nPos][3]
		cDCurso		:= a9List[nPos][4]
		cTurma		:= a9List[nPos][5]
		cTeste		:= a9List[nPos][6]
		cDTeste		:= a9List[nPos][7]
		nResulta	:= Val(a9List[nPos][8])
		cDescTit 	:= OemToAnsi(STR0006) //"Exclusao"
		cDuraca		:= a9List[nPos][10]
		cTipo		:= a9List[nPos][11]
		cDTipo		:= a9List[nPos][12]
		cMatAval	:= a9List[nPos][13]
		cNomAval	:= a9List[nPos][14]
	Else
		cCalend		:= CriaVar("RAI_CALEND")
		cDCalend	:= CriaVar("RA2_DESC")
		cCurso		:= CriaVar("RAI_CURSO")
		cDCurso		:= CriaVar("RA1_DESC")
		cTurma		:= CriaVar("RAI_TURMA")
		cTeste 		:= CriaVar("RAI_TESTE")
		cDTeste		:= CriaVar("QQ_DESCRIC")
		nResulta	:= 0.00
		cDescTit 	:= OemToAnsi(STR0004) //"Inclusao"
		cDuraca		:= "00:00:00"
		cTipo		:= CriaVar("RAI_TIPO")
		cDTipo		:= CriaVar("RAI_DTIPO")
		cMatAval	:= CriaVar("RAI_MATAVA")
		cNomAval	:= CriaVar("RA_NOME")
	EndIf

	// Monta as Dimensoes dos Objetos
	aAdvSize			:= MsAdvSize()
	aAdvSize[5]		:=	610 //horizontal
	aAdvSize[3]		:=	307 // LARGURA
	aAdvSize[4]		:=	150  // ALTURA
	aAdvSize[6]		:=  323 //Vertical
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 2 , 2 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize			:= MsObjSize( aInfoAdvSize , aObjCoords )

	DEFINE MSDIALOG oDlg FROM  aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cDescTit PIXEL

	@ aObjSize[1][1]+10, aObjSize[1][2]+10 SAY OemtoAnsi(STR0069) SIZE 25,10 OF oDlg PIXEL //"Calendario"
	@ aObjSize[1][1]+10, aObjSize[1][2]+50 MSGET oCalend 	VAR cCalend F3 "RA2";
											PICTURE "9999";
											WHEN nList == 1;
											VALID Tr100ChkTest(cCalend,@cDCalend,1,@cCurso,@cTurma);
											SIZE 25,10 OF oDlg PIXEL HASBUTTON
	@ aObjSize[1][1]+10, aObjSize[1][2]+90 MSGET oDCalend		VAR cDCalend;
											WHEN .F.;
											SIZE 100, 10 OF oDlg PIXEL

	@ aObjSize[1][1]+30, aObjSize[1][2]+10 SAY OemtoAnsi(STR0026) SIZE 25,10 OF oDlg PIXEL //"Curso"
	@ aObjSize[1][1]+30, aObjSize[1][2]+50 MSGET oCurso 	VAR cCurso F3 "RA1";
											PICTURE "9999";
											WHEN nList == 1;
											VALID Tr100ChkTest(cCurso,@cDCurso,2) .And.;
											Tr100Chk(nList,cCurso);
											SIZE 25,10 OF oDlg PIXEL HASBUTTON
	@ aObjSize[1][1]+30, aObjSize[1][2]+90  MSGET oDCurso		VAR cDCurso;
											WHEN .F.;
							   				SIZE 100, 10 OF oDlg PIXEL

	@ aObjSize[1][1]+50, aObjSize[1][2]+10 SAY OemtoAnsi(STR0071) SIZE 25,10 OF oDlg PIXEL //"Turma"
	@ aObjSize[1][1]+50, aObjSize[1][2]+50 MSGET oTurma 	VAR cTurma;
							  				PICTURE "999";
											WHEN nList == 1;
											SIZE 25,10 OF oDlg PIXEL HASBUTTON

	@ aObjSize[1][1]+70, aObjSize[1][2]+10 SAY OemtoAnsi(STR0056) SIZE 25,10 OF oDlg PIXEL //"Teste"
	@ aObjSize[1][1]+70, aObjSize[1][2]+50 MSGET oTeste 		VAR cTeste F3 "SQQ";
							 				PICTURE "9999";
						   					WHEN nList == 1;
						  					VALID Tr100ChkTest(cTeste,@cDTeste,3,,,@cTipo,@cDTipo) .And.;
						  					Tr100Chk(nList,cTeste);
						  					SIZE 25,10 OF oDlg PIXEL HASBUTTON
	@ aObjSize[1][1]+70, aObjSize[1][2]+90 MSGET oDTeste  	VAR cDTeste;
							   				WHEN .F.;
							  				SIZE 100, 10 OF oDlg PIXEL

	@ aObjSize[1][1]+90, aObjSize[1][2]+10 SAY OemtoAnsi(STR0080) SIZE 25,10 OF oDlg PIXEL //"Avaliador"
	@ aObjSize[1][1]+90, aObjSize[1][2]+50 MSGET oMatAval		VAR cMatAval F3 "SRA";
							  				PICTURE "999999";
							 				WHEN nList == 1;
							 				VALID Tr100ChkTest(cMatAval,@cNomAval,4);
							 				SIZE 25,10 OF oDlg PIXEL HASBUTTON
	@ aObjSize[1][1]+90, aObjSize[1][2]+90 MSGET oNomAval  	VAR cNomAval;
							 				WHEN .F.;
						   					SIZE 100, 10 OF oDlg PIXEL

	// Monta os Botoes para a EnchoiceBar
	bSet15		:= { ||nOpc1 := 1,oDlg:End() }
	bSet24		:= { ||nOpc1 := 0,oDlg:End() }

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 , Nil , Nil ) CENTERED

	If nOpc1 == 1
		If Len(a9List) # 0
			If	Empty(a9List[1][6]) .And. nList # 1
				HELP("",1,"A010LISTVAZIO")
				Return
			EndIf
		EndIf

		If nList == 1    		// Inclusao no ListBox
			If Len(a9List) == 1 .And. Empty(a9List[1][6]) // Verifica quando esta vazio
				a9List[1][1]	:= cCalend
				a9List[1][2]	:= cDCalend
				a9List[1][3]	:= cCurso
				a9List[1][4]	:= cDCurso
				a9List[1][5]	:= cTurma
				a9List[1][6] 	:= cTeste
				a9List[1][7] 	:= cDTeste
				a9List[1][8] 	:= Str(nResulta,6,2)
				a9List[1][9] 	:= STR0067	//"Ativo"
				a9List[1][10] 	:= cDuraca
				a9List[1][11] 	:= cTipo
				a9List[1][12] 	:= cDTipo
				a9List[1][13]	:= cMatAval
				a9List[1][14]	:= cNomAval

				aSvGetD[1][2][1][nPosCalend]	:= cCalend
				aSvGetD[1][2][1][nPosCurso]	:= cCurso
				aSvGetD[1][2][1][nPosTurma]	:= cTurma
				aSvGetD[1][2][1][nPosTeste]	:= cTeste
				aSvGetD[1][2][1][nPosDuraca]	:= cDuraca
				aSvGetD[1][2][1][nPosTipo]	:= cTipo
				aSvGetD[1][2][1][nPosDTipo]	:= cDTipo
				aSvGetD[1][2][1][nPosMatAva]	:= cMatAval
				aSvGetD[1][2][1][nPosNomAva]	:= cNomAval
			Else
				Aadd(a9List,{cCalend,cDCalend,cCurso,cDCurso,cTurma,cTeste,cDTeste,Str(nResulta,6,2),STR0067,cDuraca,cTipo,cDTipo,cMatAval,cNomAval})	//"Ativo"

				Aadd(aSvGetD,{{},{},1,{}})
				aSvGetD[Len(aSvGetD)][1] 	:= aClone(aAuxHeader)
				aSvGetD[Len(aSvGetD)][2] 	:= Tr100Mont2(aAuxHeader)
				aSvGetD[Len(aSvGetD)][3] 	:= Len(aSvGetD)
				aSvGetD[Len(aSvGetD)][4]	:= aClone(a9List[Len(a9List)])

				aSvGetD[Len(aSvGetD)][2][1][nPosCalend]	:= cCalend
				aSvGetD[Len(aSvGetD)][2][1][nPosCurso]	:= cCurso
				aSvGetD[Len(aSvGetD)][2][1][nPosTurma]	:= cTurma
				aSvGetD[Len(aSvGetD)][2][1][nPosTeste]	:= cTeste
				aSvGetD[Len(aSvGetD)][2][1][nPosDuraca]	:= cDuraca
				aSvGetD[Len(aSvGetD)][2][1][nPosTipo]		:= cTipo
				aSvGetD[Len(aSvGetD)][2][1][nPosDTipo]	:= cDTipo
				aSvGetD[Len(aSvGetD)][2][1][nPosMatAva]	:= cMatAval
				aSvGetD[Len(aSvGetD)][2][1][nPosNomAva]	:= cNomAval
			EndIf

		ElseIf nList == 2  	// Exclusao no ListBox
			If a9List[nPos][9] == STR0068	//"Excluido"
				a9List[nPos][9] := STR0067	//"Ativo"
			Else
				a9List[nPos][9] := STR0068	//"Excluido"
			EndIf

			If Len(a9List) == 1 .And. Empty(a9List[1][6])
				a9List[1][1] 	:= ""
				a9List[1][2] 	:= ""
				a9List[1][3] 	:= ""
				a9List[1][4] 	:= ""
				a9List[1][5] 	:= ""
				a9List[1][6] 	:= ""
				a9List[1][7] 	:= ""
				a9List[1][8] 	:= ""
				a9List[1][9] 	:= ""
				a9List[1][10] 	:= ""
				a9List[1][11] 	:= ""
				a9List[1][12] 	:= ""
				a9List[1][13] 	:= ""
				a9List[1][14] 	:= ""
			EndIf
		EndIf
	EndIf

	o9Lbx:SetArray(a9List)
	o9Lbx:Show()
	o9Lbx:Refresh(.T.)

	RestArea(aSaveSRA)
	RestArea(aSaveArea)

Return {cCalend,cCurso,cTurma,cTeste}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr100RAI ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 06/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta o listbox e a getdados do Tree de Avaliacao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TRMA100  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr100RAI(nOpcx)
Local aSaveArea		:= GetArea()
Local aAuxHeader	:= {}
Local aAuxCols 		:= {}
Local cCalend		:= ""
Local cCurso		:= ""
Local cTurma		:= ""
Local cTeste		:= ""
Local nControl		:= 0
Local nx			:= 0
Local ny			:= 0
Local nPosCalend	:= 0
Local nPosCurso		:= 0
Local nPosTurma		:= 0
Local nPosTeste 	:= 0
Local nPosQuest 	:= 0
Local nPosAltern	:= 0
Local nPosResult	:= 0
Local nPosDurac		:= 0
Local nPosTipo		:= 0
Local nPosDTipo		:= 0
Local nPosResp		:= 0
Local nPosMatAva 	:= 0
Local nPosNomAva 	:= 0
Local cCmpDesc		:= ""
Local nUsado		:= 0
Local nCntFor		:= 0
Local cDesCalend	:= ""
Local cDesCurso		:= ""
Local cDTipo		:= ""
Local cNomAval		:= ""

	// Montar o ListBox
	aAuxHeader	:= aClone(aListPast[9][1])
	aAuxCols  	:= aClone(aListPast[9][2])

	nPosCalend	:= GdFieldPos("RAI_CALEND"	,aAuxHeader)
	nPosCurso	:= GdFieldPos("RAI_CURSO"	,aAuxHeader)
	nPosTurma	:= GdFieldPos("RAI_TURMA"	,aAuxHeader)
	nPosTeste 	:= GdFieldPos("RAI_TESTE"	,aAuxHeader)
	nPosQuest	:= GdFieldPos("RAI_QUESTA"	,aAuxHeader)
	nPosAltern 	:= GdFieldPos("RAI_ALTERN"	,aAuxHeader)
	nPosResult 	:= GdFieldPos("RAI_RESULT"	,aAuxHeader)
	nPosResp 	:= GdFieldPos("RAI_MRESPO"	,aAuxHeader)
	nPosDurac 	:= GdFieldPos("RAI_DURACA"	,aAuxHeader)
	nPosTipo 	:= GdFieldPos("RAI_TIPO"	,aAuxHeader)
	nPosDTipo 	:= GdFieldPos("RAI_DTIPO"	,aAuxHeader)
	nPosMatAva 	:= GdFieldPos("RAI_MATAVA"	,aAuxHeader)
	nPosNomAva 	:= GdFieldPos("RAI_NOMAVA"	,aAuxHeader)

	aAuxCols := ASort(aAuxCols,,,{ |x, y| x[nPosCalend]+x[nPosCurso]+x[nPosTurma]+x[nPosTeste]+x[nPosQuest]+x[nPosAltern] < ;
											y[nPosCalend]+y[nPosCurso]+y[nPosTurma]+y[nPosTeste]+y[nPosQuest]+y[nPosAltern]})

	a9List :={}
	If Empty(aAuxCols[1][2])
		Aadd(a9List,{"","","","","","","","","","","","","",""})

		aSvGetD := {}
		Aadd(aSvGetD,{ {},{},1,{} })
		aSvGetD[1][1] := aClone(aAuxHeader)
		aSvGetD[1][2] := aClone(aAuxCols)
	Else
		aCols		:= {}
	  	aHeader 	:= aClone(aListPast[9][1])
		nUsado 		:= Len(aHeader)
		aSvGetD  	:= {}

		For nx := 1 To Len(aAuxCols)
			If 	cCalend+cCurso+cTurma+cTeste  #;
				 aAuxCols[nx][nPosCalend]+aAuxCols[nx][nPosCurso]+aAuxCols[nx][nPosTurma]+aAuxCols[nx][nPosTeste]

				// Descricao do Calendario
				dbSelectArea("RA2")
				dbSetOrder(1)
				dbSeek(xFilial("RA2")+aAuxCols[nx][nPosCalend])
				cDesCalend 	:= RA2->RA2_DESC

				// Descricao do Curso
				dbSelectArea("RA1")
				dbSetOrder(1)
				dbSeek(xFilial("RA1")+aAuxCols[nx][nPosCurso])
				cDesCurso	:= RA1->RA1_DESC

				// Descricao do Teste
				If Len(Alltrim(aAuxCols[nx][nPosTeste])) == 4
					dbSelectArea("SQW")
					dbSetOrder(1)
					cCmpDesc := "SQW->QW_DESCRIC"
				Else
					dbSelectArea("SQQ")
					dbSetOrder(1)
					cCmpDesc := "SQQ->QQ_DESCRIC"
				EndIf
				dbSeek(cFilial+Alltrim(aAuxCols[nx][nPosTeste]))

				// Descricao do Tipo de Avaliacao
				cDTipo	:= FDESC("SX5","RJ"+aAuxCols[nx][nPosTipo],"X5DESCRI()")

				// Nome do Avaliador
				cNomAval := FDESC("SRA",aAuxCols[nx][nPosMatAva],"RA_NOME")

				Aadd(a9List,{aAuxCols[nx][nPosCalend],;	// Calendario
				cDesCalend,;								// Desc. Calend.
				aAuxCols[nx][nPosCurso],;					// Curso
				cDesCurso,;									// Desc. Curso
				aAuxCols[nx][nPosTurma],;					// Turma
				aAuxCols[nx][nPosTeste],;					// Cod.Teste
				UPPER(&cCmpDesc),;   						// Desc. Teste
				Str(aAuxCols[nx][nPosResult]),;			// Result.
				STR0067,;	//"Ativo"						// Situacao
				aAuxCols[nx][nPosDurac],;					// Duracao
				aAuxCols[nx][nPosTipo],;	 				// Tipo Avaliac.
				cDTipo,;									// Desc. Tipo Avaliac.
				aAuxCols[nx][nPosMatAva],;	 				// Matricula Avaliador
				cNomAval})				   					// Nome do Avaliador

				If nControl # 0		// Verifica a 1a vez

					Aadd(aSvGetD,{{},{},1,{}})

					// Atualiza os pontos do teste no listbox
					If !Empty(aAuxCols[nx-1][nPosQuest])
						Tr100CalcP(Len(a9List)-1)
					EndIf

					aSvGetD[nControl][1] 	:= aClone(aHeader)
					aSvGetD[nControl][2] 	:= aClone(aCols)
					aSvGetD[nControl][3] 	:= 1
					aSvGetD[nControl][4]	:= aClone(a9List[nControl])
					aCols					:= {}

				EndIf
				aadd(aCols,Array(nUsado+1))
				For nCntFor := 1 To Len(aHeader)
				    aCols[Len(aCols)][nCntFor]	:= aAuxCols[nx][nCntFor]
				Next nCntFor
				aCols[Len(aCols)][nUsado+1] := .F.

				cCalend	:= aAuxCols[nx][nPosCalend]
				cCurso	:= aAuxCols[nx][nPosCurso]
				cTurma	:= aAuxCols[nx][nPosTurma]
				cTeste	:= aAuxCols[nx][nPosTeste]

				nControl++

			Else

				aadd(aCols,Array(nUsado+1))
				For nCntFor := 1 To Len(aHeader)
				    aCols[Len(aCols)][nCntFor]	:= aAuxCols[nx][nCntFor]
				Next nCntFor
				aCols[Len(aCols)][nUsado+1] := .F.

			EndIf
		Next nx

		IIF(nControl >= 1, nControl, nControl++)

		Aadd(aSvGetD,{{},{},1,{}})
		aSvGetD[nControl][1] := aClone(aHeader)
		If Len(aCols) == 0
			aCols := Tr100Mont2(aHeader)
		EndIf

		// Atualiza os pontos do teste no listbox
		If !Empty(aAuxCols[Len(aAuxCols)][nPosQuest])
			Tr100CalcP(Len(a9List))
		EndIf

		aSvGetD[nControl][2]	:= aClone(aCols)
		aSvGetD[nControl][3] 	:= Len(aCols)
		aSvGetD[nControl][4]	:= aClone(a9List[nControl])
	EndIf

	For ny := 1 To Len(aSvGetD)
		If aSvGetD[ny][3] > 1 .And. Empty(aSvGetD[ny][2][1][1])
			ADEL(aSvGetD[ny][2],1)
			ASIZE(aSvGetD[ny][2], Len(aSvGetD[ny][2])-1)
			aSvGetD[ny][3]--
		EndIf
	Next ny

	aListPast[9][3] 	:= a9List

	aCols := aClone(aSvGetD[1][2])

	RestArea(aSaveArea)

Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Tr100CalcP³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 07/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Calcula os pontos dos questoes e grava no total do teste    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tr100CalcP(ExpC2)					                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nPos = posicao a ser atualizado do listbox       			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function Tr100CalcP(nPos)
Local aSaveArea		:= GetArea()
Local ny			:= 0
Local nPontos		:= 0
Local nPercent		:= 0
Local nPosQuestao	:= 0
Local nPosAlterna 	:= 0
Local nPosResulta 	:= 0
Local cAux          := ""
Local aAuxCols		:= {}

	aAuxCols := Aclone(aCols)

	nPosQuestao := GdFieldPos("RAI_QUESTA")
	nPosAlterna := GdFieldPos("RAI_ALTERN")
	nPosResulta := GdFieldPos("RAI_RESULT")

	ASort(aAuxCols,,,{ |x,y| 	x[nPosQuestao]+x[nPosAlterna] < ;
								y[nPosQuestao]+y[nPosAlterna]})

	cAux := aAuxCols[1][nPosQuestao]
	For ny := 1 To Len(aAuxCols)
		If !aAuxCols[ny][Len(aAuxCols[ny])]				// Deletado
			If cAux # aAuxCols[ny][nPosQuestao]
				If nPercent > 0

					dbSelectArea("SQO")
					dbSetOrder(1)
					If dbSeek(cFilial+cAux)
						nPontos += ((SQO->QO_PONTOS * nPercent) / 100)
					EndIf
				EndIf

				nPercent := 0
				cAux:= aAuxCols[ny][nPosQuestao]
			EndIf

			If nPercent == 100
				nPercent := 99
			Else
				nPercent += aAuxCols[ny][nPosResulta]
			EndIf
		EndIf

	Next ny

	If nPercent > 0
		dbSelectArea("SQO")
		dbSetOrder(1)
		If dbSeek(cFilial+cAux)
			nPontos+= ((SQO->QO_PONTOS * nPercent) / 100)
		EndIf
	EndIf

	a9List[nPos][8]   := Str(nPontos,6,2)

	RestArea(aSaveArea)

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr100Quest ³ Autor ³ Emerson Grassi Rocha³ Data ³ 15/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica o dado das questoes e critica caso esteja vazio   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TRMA100													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr100Quest()
Local aSaveArea	:= GetArea()
Local lRet		:= .T.
Local lTeste	:= .F.
Local cVar		:= &(ReadVar())
Local cTeste	:= Alltrim(a9List[o9Lbx:nAt][6])

	If Len(cTeste) == 3	//Teste
		dbSelectArea("SQQ")
		dbSetOrder(1)
		dbSeek(cFilial+cTeste)
		While !Eof() .And. cFilial+cTeste == ;
			QQ_FILIAL+QQ_TESTE
			If QQ_QUESTAO == cVar
				lTeste:= .T.
				Exit
			EndIf
			dbSkip()
		EndDo

	Else 	//Modelo
		lTeste:= .T.
	EndIf

	If !lTeste
		Help("",1,"A010NTESTE")		// Nao existe a questao para o teste selecionado
		RestArea(aSaveArea)
		Return .F.
	EndIf

	dbSelectArea("SQO")
	dbSetOrder(1)
	If dbSeek(cFilial+cVar)
		If Len(a9List) == 1 .And. Empty(a9List[1][6])
			Help("",1,"A010FALTA")
			lRet := .F.
		Else
			If a9List[o9Lbx:nAt][9] == STR0068	//"Excluido"
				Help(" ",1,"A010EXCLUI")
				lRet := .F.
			EndIf
		EndIf
	Else
		Help("",1,"A010NEXISTE")
		lRet:= .F.
	EndIf

	RestArea(aSaveArea)

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr100Alt	  ³ Autor ³ Emerson Grassi Rocha³ Data ³ 15/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Critica o campo alternativa                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TRMA100													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr100Alt()
Local aSaveArea		:= GetArea()
Local cVar			:= &(ReadVar())
Local nPosQuestao 	:= GdFieldPos("RAI_QUESTA")
Local nPosAlterna 	:= GdFieldPos("RAI_ALTERN")
Local nPosResulta 	:= GdFieldPos("RAI_RESULT")
Local nPosTeste 	:= GdFieldPos("RAI_TESTE")
Local ny			:= 0
Local nResulta		:= 0
Local lTeste		:= .F.
Local lAlterna    	:= .F.
Local cTeste		:= Alltrim(a9List[o9Lbx:nAt][6])

	For ny := 1 To Len(aCols)
		If aCols[n][nPosQuestao] == aCols[ny][nPosQuestao] .And.;
			cVar == aCols[ny][nPosAlterna] .And.	n # ny .And.;
			!aCols[ny][Len(aCols[ny])] .And. aCols[n][nPosTeste] == aCols[ny][nPosTeste]
			Help("",1,"A010JAEXISTE")
			RestArea(aSaveArea)
			Return .F.
		EndIf
	Next ny

	If Len(cTeste) == 3
		dbSelectArea("SQQ")
		dbSetOrder(1)
		dbSeek(cFilial+cTeste)
		While !Eof() .And. cFilial+cTeste == ;
			QQ_FILIAL+QQ_TESTE
			If QQ_QUESTAO == aCols[n][nPosQuestao]
				lTeste:= .T.
				Exit
			EndIf
			dbSkip()
		EndDo

	Else
		lTeste:= .T.
	EndIf

	If !lTeste
		Help("",1,"A010NTESTE")		// Nao existe a questao para o teste selecionado
		RestArea(aSaveArea)
		Return .F.
	EndIf

	// Questoes
	dbSelectArea("SQO")
	dbSetOrder(1)
	If !dbSeek(cFilial+aCols[n][nPosQuestao])
		Help("",1,"A010NEXISTE")
		RestArea(aSaveArea)
		Return .F.
	EndIf

	If Empty(SQO->QO_ESCALA)

		dbSelectArea("SQP") 	// Alternativas (SQP)
		dbSetOrder(1)
		If dbSeek(cFilial+aCols[n][nPosQuestao])
			While !Eof() .And. cFilial+aCols[n][nPosQuestao] ==;
				SQP->QP_FILIAL+SQP->QP_QUESTAO
				If cVar == SQP->QP_ALTERNA
					lAlterna := .T.
					nResulta := SQP->QP_PERCENT
					Exit
				EndIf
				dbSkip()
			EndDo
		Else
			If (Empty(cVar) .Or. cVar == "00") .And. SQO->QO_TIPOOBJ == "3"	//Dissertativa
				lAlterna := .T.
			EndIf
		EndIf

	Else

		dbSelectArea("RBL")  	// Alternativas (RBL)
		dbSetOrder(1)
		If dbSeek(xFilial("RBL")+SQO->QO_ESCALA)
			While !Eof() .And. xFilial("RBL")+SQO->QO_ESCALA ==;
				RBL->RBL_FILIAL+RBL->RBL_ESCALA
				If cVar == RBL->RBL_ITEM
					lAlterna := .T.
					nResulta := RBL->RBL_VALOR
					Exit
				EndIf
				dbSkip()
			EndDo
		Else
			If (Empty(cVar) .Or. cVar == "00") .And. SQO->QO_TIPOOBJ == "3"	//Dissertativa
				lAlterna := .T.
			EndIf
		EndIf
	EndIf

	If !lAlterna
		Help("",1,"A010NALTERN")	// "Nao existe a alternativa selecionada. Verifique se a questao nao e descritiva."
		RestArea(aSaveArea)
		Return .F.
	EndIf

	aCols[n][nPosResulta] := nResulta
	o9Get:Refresh()

	// Atualiza o resultado com os pontos do teste
	Tr100CalcP(o9lbx:nAt)
	o9Lbx:Refresh()

	RestArea(aSaveArea)

Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TR100F4  ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 12.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descriaco ³ Faz a consulta das questoes e alternativas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ A120F4(a,b,c,ExpC1,ExpC2,ExpC3)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ a,b,c = parametros padroes quando utiliza-se o Set Key     ³±±
±±³          ³ ExpC1 = Arquivo a pesquisar no SX3                         ³±±
±±³          ³ ExpC2 = Variavel que sera usada para o Seek                ³±±
±±³          ³ ExpC3 = Nome do campo em o cursor deve estar posicionado   ³±±
±±³          ³         para ativar esta rotina.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function TR100F4()
Local aSaveArea		:= GetArea()
Local oQual, oDlg
Local aArrayF4		:= {}
Local cVar 			:= ReadVar()
Local cCadastro		:= OemToAnsi(STR0066) //"Consulta Questoes e Alternativas do Teste"
Local cQuestao		:= ""
Local nOpca			:= 0
Local nPosQual		:= 1
Local cTeste		:= Alltrim(a9List[o9Lbx:nAt,6])
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

	SetKey( VK_F4 , { || NIL } )

	If Len(a9List) == 0

		SetKey( VK_F4 , { || TR100F4() } )

		RestArea(aSaveArea)
		Return .T.
	EndIf

	If Len(cTeste) == 4
		Aviso(STR0036,STR0060,{STR0046})	//"Aviso"###"Este Codigo nao pertence ao Cadastro de Testes e sim ao Cadastro de Modelos."###"Sair"

		SetKey( VK_F4 , { || TR100F4() } )

		RestArea(aSaveArea)
		Return .T.
	EndIf


	dbSelectArea("SQQ")
	dbSetOrder(1)
	If	dbSeek(cFilial+cTeste)
		While !Eof() .And. cFilial+cTeste ==;
			QQ_FILIAL+QQ_TESTE

			dbSelectArea("SQO")
			dbSetOrder(1)
			dbSeek(cFilial+SQQ->QQ_QUESTAO)
			cQuestao := Substr(SQO->QO_QUEST,1,100)

			If Empty(SQO->QO_ESCALA)

				dbSelectArea("SQP")	// Alternativas (SQP)
				dbSetOrder(1)
				If dbSeek(xFilial("SQP")+SQQ->QQ_QUESTAO)
					While !Eof() .And. 	xFilial("SQP")+SQQ->QQ_QUESTAO ==;
						QP_FILIAL+QP_QUESTAO

						AADD(aArrayF4,{SQQ->QQ_ITEM, SQO->QO_QUESTAO, cQuestao, SQP->QP_ALTERNA, Left(SQP->QP_DESCRIC,60), STR(SQP->QP_PERCENT,6,2)})
						cQuestao:=Replicate("=",100)
						dbSkip()
					EndDo
				Else
					// Questoes descritivas
					AADD(aArrayF4,{SQQ->QQ_ITEM,SQO->QO_QUESTAO,cQuestao,Space(2),Space(60),Space(8)})
				EndIf

			Else

				dbSelectArea("RBL")  	// Alternativas - Escala (RBL)
				dbSetOrder(1)
				If dbSeek(xFilial("RBL")+SQO->QO_ESCALA)
					While !Eof() .And. xFilial("RBL")+SQO->QO_ESCALA ==;
						RBL->RBL_FILIAL+RBL->RBL_ESCALA

						AADD(aArrayF4,{SQQ->QQ_ITEM, SQO->QO_QUESTAO, cQuestao, RBL->RBL_ITEM, Left(RBL->RBL_DESCRI,60), STR(RBL->RBL_VALOR,6,2)})
						cQuestao:=Replicate("=",100)
						dbSkip()
					EndDo
				Else
					// Questoes descritivas
					AADD(aArrayF4,{SQQ->QQ_ITEM,SQO->QO_QUESTAO,cQuestao,Space(2),Space(60),Space(8)})
				EndIf

			EndIf
			dbSelectArea("SQQ")
			dbSetOrder(1)
			dbSkip()
		EndDo
	EndIf

	If Len(aArrayF4) == 0
		Help("",1,"A010NAOHA")

		SetKey( VK_F4 , { || TR100F4() } )

		RestArea(aSaveArea)
		Return .T.
	EndIf

	nOpca:= 0

	// Monta as Dimensoes dos Objetos
	aAdvSize			:= MsAdvSize()
	aAdvSize[5]		:=	610 //horizontal
	aAdvSize[3]		:=	307 // LARGURA
	aAdvSize[4]		:=	150  // ALTURA
	aAdvSize[6]		:=  323 //Vertical
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 2 , 2 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. , .T.} )
	aObjSize			:= MsObjSize( aInfoAdvSize , aObjCoords )

	DEFINE MSDIALOG oDlg FROM  aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] TITLE cCadastro PIXEL
	@ aObjSize[1][1],aObjSize[1][2] LISTBOX oQual VAR cVar FIELDS HEADER	OemToAnsi(STR0061),; 			//"Item "
												OemToAnsi(STR0062),;           //"Cod.Questao"
												OemToAnsi(STR0063),;           //"Descricao Questao"
												OemToAnsi(STR0064),;           //"Alternativa"
												OemToAnsi(STR0065),;           //"Descricao Alternativa"
												OemToAnsi(STR0058) SIZE aObjSize[1][3],aObjSize[1][4];//"Resultado"
			ON DBLCLICK (nOpca := 1,oDlg:End()) PIXEL
	oQual:SetArray(aArrayF4)
	oQual:bLine := { || {aArrayF4[oQual:nAT][1],aArrayF4[oQual:nAT][2],aArrayF4[oQual:nAT][3],aArrayF4[oQual:nAT][4],aArrayF4[oQual:nAT][5],aArrayF4[oQual:nAT][6]}}

	// Monta os Botoes para a EnchoiceBar
	bSet15		:= { ||nOpca := 1,nPosQual:=oQual:nAt,oDlg:End() }
	bSet24		:= { ||oDlg:End() }

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 , Nil , Nil ) CENTERED

	SetKey( VK_F4 , { || TR100F4() } )

	RestArea(aSaveArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Tr100Mont2 ³ Autor ³ Emerson Grassi Rocha ³ Data ³ 20.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta array aSvGetD com o aCols zerado qdo inclusao listbox³±±
±±³          ³ do folder 9                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr100Monta(ExpA1)                                    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ aAuxHeader = aHeader da getdados							  ³±±
±±³			 ³ cTeste     = codigo do teste     						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr100Mont2(aAuxHeader)
Local aAuxCols	:= {}
Local ny		:= 0

	aAuxCols 	:= Array(1, Len(aAuxHeader) + 1)

	For ny := 1 To Len(aAuxHeader)- 2
		aAuxCols[1][ny]:= CriaVar(aAuxHeader[ny][2])
	Next ny

	aAuxCols[1][Len(aAuxHeader)+1] := .F.

Return aAuxCols

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funaco    ³ Tr100AtRAI³ Autor ³ Emerson Grassi Rocha ³ Data ³ 06/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza dados do arquivo de avaliacao (RAI)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr100AtRAI(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr100AtRAI()
Local aSaveArea		:= GetArea()
Local nPosCalend	:= 0
Local nPosCurso		:= 0
Local nPosTurma		:= 0
Local nPosTeste		:= 0
Local nPosQuestao	:= 0
Local nPosAlterna	:= 0
Local nPosResulta	:= 0
Local nPosMatAva	:= 0
Local lFound		:= .T.
Local cVar			:= ""
Local aRecnos 		:= {}
Local nRecno  		:= 0
Local nx			:= 0
Local ny			:= 0
Local nt			:= 0

	aHeader		:= {}
	aHeader		:= aClone(aSvGetD[1][1])

	nPosCalend	:= GdFieldPos("RAI_CALEND")
	nPosCurso	:= GdFieldPos("RAI_CURSO")
	nPosTurma	:= GdFieldPos("RAI_TURMA")
	nPosTeste	:= GdFieldPos("RAI_TESTE")
	nPosQuestao := GdFieldPos("RAI_QUESTA")
	nPosAlterna := GdFieldPos("RAI_ALTERN")
	nPosResulta := GdFieldPos("RAI_RESULT")
	nPosMatAva	:= GdFieldPos("RAI_MATAVA")

	dbSelectArea("RAI")
	dbSetOrder(2)
	dbSeek(cFilial+cMat)
	If nOpcao == 5				// exclusao
		While !Eof() .And. cFilial+cMat == RAI->RAI_FILIAL+RAI->RAI_MAT
			MSMM(RAI_MRESPO,,,,2,,,,,"RDY")
			RecLock("RAI",.F.)
				dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	Else

		If	!Found()	// Inclusao
			If !Empty(a9List[1][6])
				For ny := 1 To Len(a9List)
					aCols	:= {}
					aCols	:= aClone(aSvGetD[ny][2])
					For nx := 1 To Len(aCols)
						//Verifica se Nao e Deletado
						If !aCols[nx][Len(aCols[nx])] .And. !Empty(aCols[nx][nPosTeste])
							RecLock("RAI",.T.)
							Replace RAI_FILIAL	With xFilial("RAI")
							Replace RAI_MAT 	With cMat
							Replace RAI_CALEND	With aCols[nx][nPosCalend]
							Replace RAI_CURSO	With aCols[nx][nPosCurso]
							Replace RAI_TURMA	With aCols[nx][nPosTurma]
							Replace RAI_TESTE	With aCols[nx][nPosTeste]
							Replace RAI_MATAVA	With aCols[nx][nPosMatAva]

							For nt := 1 to Len(aHeader)
								If aHeader[nt][10] # "V"
									cVar := Trim(aHeader[nt][2])
									Replace &cVar. With aCols[nx][nt]
								EndIf
								If aHeader[nt][8] == "M"	// Campo Memo
									MsUnlock()
									MSMM(RAI_MRESPO,,,aCols[nx][nt],1,,,"RAI","RAI_MRESPO","RDY")
									RecLock("RAI",.F.)
								EndIf
							Next nt
						EndIf
					Next nx
				Next ny
			EndIf
		Else // Alteracao
			// Grava os Testes do Candidato - Para cada teste um acols
			For ny := 1 To Len(a9List)
				aCols	:= {}
				aCols	:= aClone(aSvGetD[ny][2])

				// Verifica se Teste+Topico esta ativo - Grava
				If a9List[ny][9] == "Ativo"
					// Se existir o recno entao nao adciona registro, alterando conteudo do registro.
	                aRecnos := {}
					dbSelectArea("RAI")
	                dbSetOrder(1)
					If dbSeek(cFilial+a9List[ny][1]+a9List[ny][3]+a9List[ny][5]+cMat+a9List[ny][6])
						Do While !Eof() .And. (cFilial+a9List[ny][1]+a9List[ny][3]+a9List[ny][5]+cMat+a9List[ny][6]) == (RAI_FILIAL+RAI_CALEND+RAI_CURSO+RAI_TURMA+RAI_MAT+RAI_TESTE)
							aAdd(aRecnos, Recno())
							dbSkip()
						End Do
					EndIf

					For nx := 1 To Len(aCols)
						lFound := .T.
						// Verifica se a linha não esta deletada
						If !aCols[nx][Len(aCols[nx])] .And. !Empty(aCols[nx][nPosTeste])
							dbSelectArea("RAI")
							dbSetOrder(1)
							// Se encontrar o registro entao edita o mesmo.
	  						nRecno := 0
	  						If Len(aRecnos) >= nx
	  							nRecno := aRecnos[nx]
	  						EndIf
	  						If nRecno > 0
	                  			dbGoto(nRecno)
			                  	lFound := .F.

	  						ElseIf dbSeek(cFilial+	aCols[nx][nPosCalend]+aCols[nx][nPosCurso]+;
	  												aCols[nx][nPosTurma]+cMat+aCols[nx][nPosTeste]+;
													aCols[nx][nPosQuestao]+aCols[nx][nPosAlterna])
								lFound := .F.
							EndIf
							RecLock("RAI",lFound)

								Replace RAI_FILIAL	With xFilial("RAI")
								Replace RAI_MAT 	With cMat
								Replace RAI_CALEND	With aCols[nx][nPosCalend]
								Replace RAI_CURSO	With aCols[nx][nPosCurso]
								Replace RAI_TURMA	With aCols[nx][nPosTurma]
								Replace RAI_TESTE	With aCols[nx][nPosTeste]
								Replace RAI_RESULT	With aCols[nx][nPosResulta]
								Replace RAI_MATAVA	With aCols[nx][nPosMatAva]

								For nt := 1 to Len(aHeader)
									If aHeader[nt][10] # "V"
										cVar := Trim(aHeader[nt][2])
										Replace &cVar. With aCols[nx][nt]
									EndIf
									If aHeader[nt][8] == "M"	// Campo Memo
										MsUnlock()
										MSMM(RAI_MRESPO,,,aCols[nx][nt],1,,,"RAI","RAI_MRESPO","RDY")
										RecLock("RAI",.F.)
									EndIf
								Next nt

							MsUnlock()
						Else // Quando a Linha esta deletada
							dbSelectArea("RAI")
							dbSetOrder(1)
							If dbSeek(cFilial+	aCols[nx][nPosCalend]+aCols[nx][nPosCurso]+;
	  											aCols[nx][nPosTurma]+cMat+aCols[nx][nPosTeste]+;
												aCols[nx][nPosQuestao]+aCols[nx][nPosAlterna])

								MSMM(RAI_MRESPO,,,,2,,,,,"RDY")
								RecLock("RAI",.F.)
									dbDelete()
								MsUnlock()
							EndIf
						EndIf
					Next nx
				Else // Se Teste deletado apaga do RAI
					For nx := 1 to Len(aCols)
						dbSelectArea("RAI")
						dbSetOrder(1)
						dbSeek(cFilial+	aCols[nx][nPosCalend]+aCols[nx][nPosCurso]+;
	 									aCols[nx][nPosTurma]+cMat+aCols[nx][nPosTeste])

						While !Eof() .And.(cFilial+;
										aCols[nx][nPosCalend]+aCols[nx][nPosCurso]+;
										aCols[nx][nPosTurma]+cMat+aCols[nx][nPosTeste])==;
								RAI_FILIAL+RAI_CALEND+RAI_CURSO+RAI_TURMA+RAI_MAT+RAI_TESTE

							MSMM(RAI_MRESPO,,,,2,,,,,"RDY")
							RecLock("RAI",.F.)
								dbDelete()
							MsUnlock()
							dbSkip()
						EndDo
					Next nx
				EndIf
			Next ny
		EndIf
	EndIf

	RestArea(aSaveArea)

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr100Chk ³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se o teste ja foi incluido no listbox             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr100Chk(ExpN1,ExpC1,ExpC2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nList   = Opcao escolhida atraves dos botoes               ³±±
±±³          ³           1 - inclusao                                     ³±±
±±³          ³           2 - exclusao                                     ³±±
±±³          ³ cTeste  = Codigo do Teste                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr100Chk(nList,cTeste)
Local lRet 	:= .T.
Local ny	:= 0

	If nList # 3
		For ny := 1 To Len(a9List)
			If cTeste == a9List[ny][6]
				Help(" ",1,"A010NPODE")
				If nList == 1
					lRet := .F.
				EndIf
				Exit
			EndIf
		Next ny
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr100ChkTest ³ Autor ³ Emerson G. Rocha  ³ Data ³ 13/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se o teste selecionado existe.			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TRMA100   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr100ChkTest(cCod,cDesc,nTipo,cCurso,cTurma,cTipo,cDTipo)
Local aSaveArea	:= GetArea()
Local lRet 		:= .T.

	If nTipo == 1		//Calendario
		dbSelectArea("RA2")
		dbSetOrder(1)
		If dbSeek(cFilial+cCod)
			cDesc := Upper(RA2->RA2_DESC)
			cCurso 	:= RA2->RA2_CURSO
			cTurma	:= RA2->RA2_TURMA
		Else
			lRet := .F.
		EndIf

	ElseIf nTipo == 2	//Curso
		dbSelectArea("RA1")
		dbSetOrder(1)
		If dbSeek(cFilial+cCod)
			cDesc := Upper(RA1->RA1_DESC)
		Else
			lRet := .F.
		EndIf

	ElseIf nTipo == 3	//Teste
		cCod := Alltrim(cCod)
		If Len(cCod) == 3
			dbSelectArea("SQQ")
			dbSetOrder(1)
			If dbSeek(cFilial+cCod)
				cDesc	:= UPPER(SQQ->QQ_DESCRIC)
				cTipo	:= SQQ->QQ_TIPO
				cDTipo	:= FDESC("SX5","RJ"+cTipo,"X5DESCRI()")
			Else
				lRet := .F.
			EndIf
		Else
			dbSelectArea("SQW")
			dbSetOrder(1)
			If dbSeek(cFilial+cCod)
				cDesc 	:= UPPER(SQW->QW_DESCRIC)
				cTipo	:= SQW->QW_TIPO
				cDTipo	:= FDESC("SX5","RJ"+cTipo,"X5DESCRI()")
			Else
				lRet := .F.
			EndIf
		EndIf
		If !lRet
			Help(" ",1,"A010NEXISTE")
		EndIf

	ElseIf nTipo == 4	// Avaliador
		cDesc	:= FDESC("SRA",cCod,"RA_NOME")
	EndIf

	RestArea(aSaveArea)

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Tr100EntCur³ Autor ³ Emerson Grassi Rocha ³ Data ³ 25/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra Entidade de acordo com o Curso selecionado.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATRM - Consulta Padrao: RA6                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr100EntCur()
Local cEntid		:= ReadVar()
Local cCurso		:= StrTran(cEntid,"ENTIDA", "CURSO")
Local cCampo		:= Substr(cCurso,4)
Local cCodCurs		:= ""
Local cRel			:= ""

	If IsInGetDados( { cCampo } )               // Na GetDados
		cCodCurs	:= GDFieldGet(cCampo, n)
	Else
		cCodCurs := &(cCurso)					// Na Enchoice
	EndIf

	cRel	:= "@#RA6->RA6_CURSO=='"+cCodCurs+"'@#"

Return( cRel )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Tr100Sr7	 ³ Autor ³ Emerson Grassi Rocha ³ Data ³ 11/11/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Alimenta acols do Historico Salarial na Alteracao salarial. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGATRM                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr100Sr7()
Local aColsAux	:= {}
Local cDescTip 	:= fDesc( "SX5" , "41"+M->RA_TIPOALT , "X5Descri()" )
Local nPosData	:= GdFieldPos("R7_DATA",oGetSR7:aHeader)
Local nPos 		:= 0
Local cDescCar 	:= ""

	// SR7
	aColsAux := GdRmkaCols(	oGetSR7:aHeader 	,;	//Array com a Estrutura para criacao do aCols
							.F.					,;	//Estado do Elemento de Delecao no aCols
							.T.					,;	//Se existe o Elemento de Delecao
							.T.					,;	//Se deve carregas os inicializadores padroes
							NIL					,;	//Lado para o Inicializador padrao
							.F.					 ;	//Se deve criar as variaveis publicas
			 			  )

	If SQ3->( dbSeek(xFilial("SQ3")+M->RA_CARGO+SRA->RA_CC)) .or. SQ3->( dbSeek(xFilial("SQ3")+M->RA_CARGO))
		cDescCar := SQ3->Q3_DESCSUM
	EndIf

	GdFieldPut( "R7_DATA" 		, M->RA_DATAALT			, 1 , oGetSR7:aHeader , aColsAux , .F. )
	GdFieldPut( "R7_TIPO" 		, M->RA_TIPOALT			, 1 , oGetSR7:aHeader , aColsAux , .F. )
	GdFieldPut( "R7_DESCTIP"	, cDescTip				, 1 , oGetSR7:aHeader , aColsAux , .F. )
	GdFieldPut( "R7_FUNCAO"		, M->RA_CODFUNC			, 1 , oGetSR7:aHeader , aColsAux , .F. )
	GdFieldPut( "R7_DESCFUN"	, M->RA_DESCFUN			, 1 , oGetSR7:aHeader , aColsAux , .F. )
	GdFieldPut( "R7_TIPOPGT"	, M->RA_TIPOPGT			, 1 , oGetSR7:aHeader , aColsAux , .F. )
	GdFieldPut( "R7_CATFUNC"	, M->RA_CATFUNC			, 1 , oGetSR7:aHeader , aColsAux , .F. )

	GdFieldPut( "R7_USUARIO"	, cUserName	, 1 , oGetSR7:aHeader , aColsAux , .F. )
	If SR7->( Type("R7_CARGO") ) # "U"
		GdFieldPut( "R7_CARGO"	, M->RA_CARGO	, 1 , oGetSR7:aHeader , aColsAux , .F. )
	EndIf

	If SR7->( Type("R7_DESCCAR") ) # "U"
		GdFieldPut( "R7_DESCCAR"	, cDescCar	, 1 , oGetSR7:aHeader , aColsAux , .F. )
	EndIf


	// Transfere os Dados do aColsAll para o aCols
	Gpea250AllTrf(	"SR7" 			,;	//01 -> Alias do Arquivo
					Nil				,;	//02 -> Objeto GetDados para o SR7
					@oGetSR7:aCols	,;	//03 -> aCols utilizado na GetDados
					oGetSR7:aHeader	,;	//04 -> aHeader utilizado na GetDados
					aColsR7All		,;	//05 -> aCols com todas as informacoes
					aHeaderR7All	,;	//06 -> aHeader com todos os campos
					.T.				,;	//07 -> Se carrega elemento de Deletado na remontagem do aCols
					.F.				,;	//08 -> Se transfere do aCols para o aColsAll
					.T.				 ;	//09 -> Se transfere do aColsAll para o aCols
				  )

	aColsR7	:= aClone(oGetSR7:aCols)

	If ( nPos := Ascan(oGetSR7:aCols, {|x| x[nPosData] == aColsAux[1][nPosData]}) ) > 0
		oGetSR7:aCols[nPos] := aClone( aColsAux[1] )
	Else
		aAdd( oGetSR7:aCols , aClone( aColsAux[1] ) )

		// SR3
		aColsAux :=	GdRmkaCols(	aHeaderR3All		,;	//Array com a Estrutura para criacao do aCols
								.F.					,;	//Estado do Elemento de Delecao no aCols
								.T.					,;	//Se existe o Elemento de Delecao
								.T.					,;	//Se deve carregas os inicializadores padroes
								NIL					,;	//Lado para o Inicializador padrao
								.F.					 ;	//Se deve criar as variaveis publicas
				  			  )

		GdFieldPut( "R3_FILIAL" 	, SRA->RA_FILIAL		, 1 , aHeaderR3All , aColsAux , .F. )
		GdFieldPut( "R3_MAT" 		, SRA->RA_MAT			, 1 , aHeaderR3All , aColsAux , .F. )
		GdFieldPut( "R3_DATA" 		, M->RA_DATAALT			, 1 , aHeaderR3All , aColsAux , .F. )
		GdFieldPut( "R3_PD"		 	, "000"					, 1 , aHeaderR3All , aColsAux , .F. )
		GdFieldPut( "R3_DESCPD"		, oEmToAnsi(STR0086)	, 1 , aHeaderR3All , aColsAux , .F. )//"SALARIO BASE"
		GdFieldPut( "R3_VALOR"		, M->RA_SALARIO			, 1 , aHeaderR3All , aColsAux , .F. )
		GdFieldPut( "R3_TIPO"		, M->RA_TIPOALT			, 1 , aHeaderR3All , aColsAux , .F. )

		aAdd( aColsR3All , aClone( aColsAux[1] ) )

		aColsAux := {}
	EndIf

	// Transfere os Dados do aCols para o aColsAll
	Gpea250AllTrf(	"SR7" 			,;	//01 -> Alias do Arquivo
					Nil				,;	//02 -> Objeto GetDados para o SR7
					oGetSR7:aCols	,;	//03 -> aCols utilizado na GetDados
					oGetSR7:aHeader	,;	//04 -> aHeader utilizado na GetDados
					@aColsR7All		,;	//05 -> aCols com todas as informacoes
					aHeaderR7All	,;	//06 -> aHeader com todos os campos
					.T.				,;	//07 -> Se carrega elemento de Deletado na remontagem do aCols
					.T.				,;	//08 -> Se transfere do aCols para o aColsAll
					.F.				 ;	//09 -> Se transfere do aColsAll para o aCols
				  )

	aColsR7	:= aClone(oGetSR7:aCols)

	oGetSR7:Refresh(.T.)

Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RbiItEscWhen³ Autor³ Emerson Grassi Rocha ³ Data ³ 05/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega variaveis de Memoria da Linha corrente do aCols.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ X3_WHEN do campo RBI_ITESCA.                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function RbiItEscWhen()
Local nx 		:= 0
Local nUsaHab	:= 0

	// Cria as Variaveis de Memoria - Habilidades (RBI)
	nUsaHab := Len(aHeader)
	For nX := 1 To nUsaHab
		&("M->"+aHeader[nx][2]) := aCols[n][nx]
	Next nX

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr100GDoc     ³ Autor ³Telso Carneiro    ³ Data ³ 19/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava os registros referentes a Documentos (Docs-Rv)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr100GDoc(lDele)
Local aReaCur	:= GetArea()
Local cDocRev

	RAN->(DbSetOrder(1))

	//--Verifica se Nao esta Deletado no aCols
	If !lDele
		IF RAN->(MSSEEK(xFilial("RAN")+RA4->RA4_CURSO))
			DbSelectARea("RAO")
			DbSetOrder(1)
			IF !RAO->(MSSEEK(xFilial("RAO")+RA4->(RA4_CALEND+RA4_CURSO+RA4_TURMA+RA4_MAT+DTOS(RA4_DATAIN))))
				While RAN->(!EOF()) .AND. RA4->RA4_CURSO == RAN->RAN_CURSO
				    cDocRev:=QA_ULTRVDC(RAN->RAN_DOCTO,,.F.,.T.)
					RecLock("RAO",.T.)
					RAO->RAO_FILIAL := xFilial("RAO")
					RAO->RAO_CALEND := RA4->RA4_CALEND
					RAO->RAO_CURSO  := RA4->RA4_CURSO
					RAO->RAO_TURMA	:= RA4->RA4_TURMA
					RAO->RAO_MAT	:= RA4->RA4_MAT
					RAO->RAO_DATAIN := RA4->RA4_DATAIN
					RAO->RAO_DOCTO	:= RAN->RAN_DOCTO
					RAO->RAO_RV		:= cDocRev
					MsUnlock()
					RAN->(DbSkip())
				Enddo
			Endif
		Endif
	Else
		dbSelectArea("RAO")
		dbSetOrder(1)
		IF RAO->(MSSEEK(xFilial("RAO")+RA4->(RA4_CALEND+RA4_CURSO+RA4_TURMA+RA4_MAT+DTOS(RA4_DATAIN))))
			While RAO->(!Eof()) .And. RA4->(RA4_FILIAL+RA4_CALEND+RA4_CURSO+RA4_TURMA+RA4_MAT+DTOS(RA4_DATAIN)) ==;
				xFilial("RAO")+RAO->(RAO_CALEND+RAO_CURSO+RAO_TURMA+RAO_MAT+DTOS(RAO_DATAIN))
				RecLock("RAO",.F.)
				RAO->(dbDelete())
				MsUnlock()
				RAO->(dbSkip())
			Enddo
		Endif
	Endif

	Restarea(aReaCur)

Return( Nil )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ra4EntidWhen³ Autor³ Emerson Grassi Rocha ³ Data ³ 16/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega variaveis de Memoria da Linha corrente do aCols.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³				                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ X3_WHEN do campo RA4_ENTIDA		                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Ra4EntidWhen()
Local nx 		:= 0
Local nUsaRA4	:= 0
Local cCampo	:= ReadVar()

	If ( "RA4_ENTIDA" $ cCampo )
		// Cria as Variaveis de Memoria - Cursos Funcionario (RA4)
		nUsaRA4 := Len(aHeader)
		For nX := 1 To nUsaRA4
			&("M->"+aHeader[nx][2]) := aCols[n][nx]
		Next nX
	EndIf

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FlQGInt	 ³ Autor ³ Telso Carneiro		³ Data ³ 13/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Integracao TRM com todos os Modulos do Quality	  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FlQGint()
Local lRet	:=.F.
Local aArea	:=GetARea()

	If GETMV("MV_QGINT")=="S" .AND. ChkFile('RAN') .AND. ChkFile('RAO')
		lRet:=.T.
	EndIf

	//nModulo - TRM QDO QIE QMT QIP QNC QAD PPAP ICE  SGA
	If lRet
		lRet:= (nModulo== 26 .OR. nModulo== 24 .OR. nModulo== 21 .OR. nModulo== 22 .OR.;
		   	 	nModulo== 25 .OR. nModulo== 36 .OR. nModulo== 37 .OR. nModulo== 47 .OR.;
		   		nModulo== 66 .OR. nModulo== 56)
	EndIf

	RestArea(aArea)

Return( lRet )



/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FunCAo    ³Tr100obter³ Autor ³ Joeudo Santana	    ³ Data ³ 12.01.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³DescriCAo ³Funcao que localiza e retorna o aCols e a Header	da pasta  ³±±
±±³			 ³indicada pelo parametro nPasta. Caso o aCols nao tenha sido ³±±
±±³			 ³carregado, e feita a chamada para a funcao Tr100Fill.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TRMA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr100obter(nPasta, aHeadAux, aColAux,nOpcx,nReg, aListAux)

	If (aListPast[nPasta] == Nil)
	   	aListPast[nPasta]:= TR100FillG(nPasta, nOpcx,nReg)
	EndIf

	aHeadAux:= aListPast[nPasta][1]
	aColAux	:= aListPast[nPasta][2]
	aListAux:= aListPast[nPasta][3]

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TR100FillG³ Autor ³ Joeudo Santana	    ³ Data ³ 12/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montagem das Getdados aHeader,aCols com adequaçã à		  ³±±
±±³		     ³ funcionalidade do Walk Trhu                     			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function TR100FillG(nPasta,nOpcx,nReg)
Local aListBox	:= {}
Local aAlter	:= {a3Alter, a7Alter, a9Alter}
Local nQual		:= 0

	aCols	:={}
	aHeader	:={}

		Do Case

	   	//	1- Funcionario
			Case nPasta = 2
		//	2- Graduacao Funcionario x Cargos - SQ8
				cAlias		:= "SQ8"						 			//2-cAlias - area a ser utilizada;
				nOrder		:= 1										//3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
				bSeekWhile	:={|| SQ8->Q8_FILIAL + SQ8->Q8_MAT}  		//5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
				aNoFields	:= {"Q8_FILIAL","Q8_MAT"}				  	//7-aNoFields - array contendo os campos que não estarão no aHeader;


		    Case  nPasta = 3
		//	3- Cursos Funcionario x Cargos - RA4
		      	cAlias		:="RA4"						 				//2-cAlias - area a ser utilizada;
				nOrder		:=1											//3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
				bSeekWhile	:={|| RA4->RA4_FILIAL+ RA4->RA4_MAT}  		//5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   			//³ Campos Pertences APENAS ao Portal Gestão do Capital Humano:  ³
				//³ RA4_NIVEL, RA4_STATUS, RA4_DTALT, RA4_CODCOM, RA4_CONTEU.    ³
	   			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aNoFields	:={"RA4_FILIAL","RA4_MAT","RA4_NOME","RA4_NIVEL","RA4_STATUS",;
								"RA4_DTALT","RA4_CODCOM","RA4_CONTEU"}	//7-aNoFields - array contendo os campos que não estarão no aHeader;	//aHeader	:= {}
	            nQual		:= 1

	        Case  nPasta = 4
	    //	4- Historico Carreira - SQC
	         	cAlias		:= "SQC"						 			//2-cAlias - area a ser utilizada;
				nOrder		:= 1										//3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
				bSeekWhile	:= {|| SQC->QC_FILIAL+ SQC->QC_MAT}   		//5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
				aNoFields	:= {"QC_FILIAL","QC_MAT"}		  			//7-aNoFields - array contendo os campos que não estarão no aHeader;	//aHeader	:= {}

	 		Case  nPasta = 5

		//	5- Historico Funcionario - SR7
		// Controle do GPEA250

			Case  nPasta = 6
		//	6- Historico ExtraCurriculares - SQ9
	         	cAlias		:= "SQ9"									//2-cAlias - area a ser utilizada;
				nOrder		:= 1										//3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
				bSeekWhile	:= {|| SQ9->Q9_FILIAL + SQ9->Q9_MAT}		//5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
				aNoFields	:= {"Q9_FILIAL","Q9_MAT"}					//7-aNoFields - array contendo os campos que não estarão no aHeader;	//aHeader	:= {}

	 		Case  nPasta = 7
		 // 7- Solicitacao Treinamento - RA3
	         	cAlias		:= "RA3"									//2-cAlias - area a ser utilizada;
				nOrder		:= 1										//3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
				bSeekWhile	:= {|| RA3->RA3_FILIAL + RA3->RA3_MAT}		//5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
				aNoFields	:= {"RA3_FILIAL","RA3_MAT"}					//7-aNoFields - array contendo os campos que não estarão no aHeader;	//aHeader	:= {}
			 	nQual		:= 2

	 		Case  nPasta = 8
	 	//	8- Referencia da Graduacao - RAF
	         	cAlias		:= "RAF"									//2-cAlias - area a ser utilizada;
				nOrder		:= 1										//3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
				bSeekWhile	:= {|| RAF->RAF_FILIAL + RAF->RAF_MAT}		//5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
				aNoFields	:= {"RAF_FILIAL","RAF_MAT"}					//7-aNoFields - array contendo os campos que não estarão no aHeader;	//aHeader	:= {}

	 		Case  nPasta = 9
	 	//	9- Avaliacao - RAI
	         	cAlias		:= "RAI"									//2-cAlias - area a ser utilizada;
				nOrder		:= 2										//3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
				bSeekWhile	:= {|| RAI->RAI_FILIAL + RAI->RAI_MAT}		//5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
				aNoFields	:= {"RAI_FILIAL","RAI_MAT"}					//7-aNoFields - array contendo os campos que não estarão no aHeader;	//aHeader	:= {}
	 			nQual		:= 3
	 		Case  nPasta = 10
		//	10- Habilidades - RBI
	         	cAlias		:= "RBI"									//2-cAlias - area a ser utilizada;
				nOrder		:= 1										//3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
				bSeekWhile	:= {|| RBI->RBI_FILIAL + RBI->RBI_MAT}		//5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
				aNoFields	:= {"RBI_FILIAL","RBI_MAT"}					//7-aNoFields - array contendo os campos que não estarão no aHeader;	//aHeader	:= {}

	 		Case  nPasta = 11
		//	11- Atividades Funcionais - RBN
	         	cAlias		:= "RBN"									//2-cAlias - area a ser utilizada;
				nOrder		:= 1										//3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
				bSeekWhile	:= {|| RBN->RBN_FILIAL + RBN->RBN_MAT}		//5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
				aNoFields	:= {"RBN_FILIAL","RBN_MAT", "RBN_ATIVID"}	//7-aNoFields - array contendo os campos que não estarão no aHeader;	//aHeader	:= {}


	    EndCase

	   	cSeekKey	:= xFilial(cAlias)+ cMat							//4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;

		FillGetDados(nOpcx					,; //1-nOpcx - número correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
					 cAlias					,; //2-cAlias - area a ser utilizada;
					 nOrder					,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
					 cSeekKey				,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
				 	 bSeekWhile				,; //5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
					 NIL					,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-código, condição a ser utilizado para executar o Loop no While;2º - array bi-dimensional contendo N.. condições, em que o 1º elemento é o bloco condicional, o 2º é bloco a ser executado se verdadeiro e o 3º é bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
					 aNoFields				,; //7-aNoFields - array contendo os campos que não estarão no aHeader;
					 NIL					,; //8-aYesFields - array contendo somente os campos que estarão no aHeader;
					 NIL					,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usuário;
					 NIL					,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
					 NIL			 		,; //11-bMontCols - bloco contendo função especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}
					 NIL					,; //12-lEmpty
					 NIL					,; //13-aHeaderAux
					 NIL					,; //14-aColAux
					 NIL				,; //15-bAfterCols - Bloco de codigo a ser executado após a inclusão de uma linha no Acols
					 nil					,; //16-bBeforeCols - Bloco de codigo contendo expressão para sair do While, é executado antes de inserir nova linha no aCols
					 NIL					) //17-bAfterHeader - Bloco de codigo a ser executado após o preenchimento do aheader com os campos padrão e antes de incluir os campos reservados para o WalkThru. Ex: {|aHeader| AlterHeader(aHeader) }


	(cAlias)->( dbGoBottom() )	// Para nao trazer novas linhas da getdados preenchidas.
	(cAlias)->( dbSkip() )

	If nQual > 0
		Tr100Alter(@aAlter[nQual],nQual)
	Endif

	dbSelectArea("SRA")
	dbSetOrder(1)
	dbGoTo(nReg)

	// Monta o ListBox
	// 2- Graduacao
	// 3- Cursos
	// 10-Habilidades
	If nPasta == 2 .Or. nPasta == 3 .Or. nPasta == 10
		Tr100List(@aListBox,nPasta)
		If nPasta ==2
			TR100FASpt(aListBox,2) //Soma Pontos cargos
		EndIf
	EndIf

Return ( {aHeader, aCols, aListBox} )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RBICamposVld³ Autor ³ Joeudo Santana	      ³ Data ³18/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao dos campos RBI_ITESCA 							   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ X3_VALID dos campos RBI_ITESCA 							   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RBICamposVld(cAlias, cPrincCampo, cRelacCampo)
Local aSaveArea 	:= GetArea()
Local lRet			:= .T.
Local cCampoPrinc	:=""
Local cCampoRelac	:=""

	If IsInGetDados( { cPrincCampo } )
		cCampoRelac 	:= GDFieldGet(cRelacCampo, n)
		cCampoPrinc 	:= &("M->" + cPrincCampo)
	Else
		cCampoRelac 	:= &("M->" + cRelacCampo)
		cCampoPrinc 	:= &("M->" + cPrincCampo)
	EndIf

	If !(NaoVazio().and.ExistCpo(cAlias,cCampoRelac+cCampoPrinc))
		lRet := .F.
	EndIf

	RestArea(aSaveArea)

Return( lRet )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Tr100SinCur ³ Autor ³ Joeudo Santana	      ³ Data ³05/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Filtra sinonimo de acordo com o Curso selecionado.  		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Consulta Padrao: RA9			                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr100SinCur()
Local cSinon		:= ReadVar()
Local cCurso		:= StrTran(cSinon,"SINONI", "CURSO")
Local cCampo		:= Substr(cCurso,4)
Local cCodCurs		:= ""
Local cRel 			:= ""

	If IsInGetDados( { cCampo} )
		cCodCurs	:= GDFieldGet(cCampo, n)	// Na GetDados
	Else
		cCodCurs := &(cCurso)					// Na Enchoice
	EndIf

	cRel	:= ("@#RA9->RA9_CURSO=='"+cCodCurs+"'@#")

Return( cRel )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr100RAS	 ³ Autor ³ Flavio S. Correa 	³ Data ³ 23/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava historico da tabela de habilidades RBI/RAS			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATRM                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr100RAS(cMatricula,aHeaderRAS,aColsRAS)
Local aArea := GetArea()
Local nI	:= 1

	dbSelectArea("RAS")
	Reclock("RAS",.T.)

	RAS_FILIAL  := xFilial("RAS")
	RAS_MAT		:= cMatricula
	For nI := 1 To Len(aHeaderRAS)
		If aHeaderRAS[nI][10] # "V"
			cCampo		:= "RAS"+ Substr(AllTrim(aHeaderRAS[nI][2]),4)
			xConteudo 	:= aColsRAS[nI]
			&cCampo := xConteudo
		EndIf
	Next nI

	RAS->(msUnlock())

	RestArea(aArea)

Return( .T. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ViewHist	 ³ Autor ³ Flavio S. Correa 	³ Data ³ 26/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualiza historico das habilidades						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATRM                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ViewHist()
Local oView
Local oStructSRA := Nil
Local oStructRAS := Nil
Local oModel     := Nil

	If !INCLUI

		DBSelectArea("SRA")
		DBSeek(xFilial("SRA")+M->RA_MAT)

		//	Le o dicionorio de dados
		oStructSRA := FWFormStruct(1, "SRA", {|cCampo| AllTrim(cCampo) + "/" $ "RA_FILIAL/RA_MAT/RA_NOME/"}) //Cabecalho
		oStructRAS := FWFormStruct(1, "RAS") //Item

		//	Monta o modelo do formulario
		oModel:= MPFormModel():New("TRMA100")

		oModel:AddFields(	"TRMA100_SRA",;		//cId - Identificador do modelo
							NIL,; 				//cOwner - Identificador superior do modelo
							oStructSRA,; 		//oModelStruct - Objeto com a estrutura de dados
							NIL,; 				//bPre - Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
							NIL,; 				//bPost - Code-Block de validação do formulário de edição
							NIL;				//bLoad - Code-Block de carga dos dados do formulário de edição
						)

		oModel:AddGrid(	"TRMA100_RAS",;			//cId - Identificador do modelo
						"TRMA100_SRA",;			//cOwner - Identificador superior do modelo
						oStructRAS,;			//oModelStruct - Objeto com a estrutura de dados
						NIL,;					//bLinePre - Code-Block de pre-edição da linha do grid de edição. Indica se a edição esta liberada
						NIL,;					//bLinePost - Code-Block de validação da linha do grid de edição
						NIL,;					//bPre - Code-Block de pre-edição do grid de edição. Indica se a edição esta liberada
						NIL,;					//bPost - Code-Block de validação do grid de edição
						NIL;					//bLoad - Code-Block de carga dos dados do formulário de edição
						)

		oModel:SetPrimaryKey({"RA_MAT"})

		oModel:SetRelation(	"TRMA100_RAS",;
							{	{"RAS_FILIAL", "RA_FILIAL"}	,;
								{"RAS_MAT", "RA_MAT"}		},;
							"RAS_FILIAL+RAS_MAT")
		oModel:SetOperation(1)		// View


		oView := FWFormView():New()

		oStructRAS := FWFormStruct(2,"RAS") 	//Item

		oView:SetModel(oModel)
	   	oView:AddGrid("TRMA100_RAS", oStructRAS)
		oView:CreateHorizontalBox("ITEM", 100)
	   	oView:SetOwnerView("TRMA100_RAS", "ITEM")
		oView:EnableControlBar(.T.)
		oView:SetOperation(1)
		oView:SetUseCursor(.F.)

	   	oFWMVCWindow := FWMVCWindow():New()
	   	oFWMVCWindow:SetUseControlBar(.T.)
		oFWMVCWindow:SetView(oView)
		oFWMVCWindow:SetCentered(.T.)
		oFWMVCWindow:SetPos(0,0)
		oFWMVCWindow:SetSize(380,700)
		oFWMVCWindow:SetTitle(STR0106)//Historico de Habilidades do funcionário
		oFWMVCWindow:Activate()
	Else
		Aviso(STR0036,STR0107,{"OK"})//"Aviso"#"Opção não disponível na inclusão"
	EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CriaList	 ³ Autor ³ Alceu Pereira        ³ Data ³ 19.10.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Campos Usados para criacao da list                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CriaList()
Local aSaveArea		:= GetArea()
Local nx          	:= 0
Local aCabec      	:= {}
Local oDlgMain

	//Ponto de Entrada permitindo que sejam carregados
	//outros campos na lista de cargos x funcao
	//Conforme FNC 00000014993/2010
	If ExistBlock("RA5CRIACP")
		Execblock("RA5CRIACP",.F.,.F.,{})
		//testar o retorno
	Endif

	Tr100List(@a2List,3)

	@ aObj4Size[3][1],aObj4Size[3][2] GROUP o3Group2	TO aObj4Size[3][3],aObj4Size[3][4]	LABEL OemtoAnsi(STR0025)    OF oDlgMain PIXEL		//" Cargo / Funcao "
	@ aObj5Size[3][1]+10,aObj5Size[3][2]+5 LISTBOX o3Lbx FIELDS HEADER "" SIZE aObj5Size[3][3]-10,aObj5Size[3][4]-15 OF oDlgMain PIXEL		//"Pontos"

	aCabec:={OemtoAnsi(STR0026),OemtoAnsi(STR0027),OemtoAnsi(STR0028),OemtoAnsi(STR0029),OemtoAnsi(STR0030),OemtoAnsi(STR0031),OemtoAnsi(STR0072),OemtoAnsi(STR0079)}
				//"Curso"          //"Descri‡„o Curso"//"Validade"       //"Horas Minima"    //"Nota Minima"   //"Freq. Minima"	   //"Eficac. Min." //Necesidade

	If Len(aContRA5) > 0
		dbSelectArea("SX3")
		dbSetOrder(2)

		For nx:= 0 to Len(aContRA5)
		    If nx < Len(aContRA5)
				If SX3->(dbSeek(aContRA5[nx+1]))
		   	 		If X3_ARQUIVO == "RA5"
						aAdd(aCabec,SX3->(AllTrim(X3Titulo())))
					EndIf
				EndIf
			EndIf
		Next
	EndIf

	If Len(aContRA1) > 0
		dbSelectArea("SX3")
		dbSetOrder(2)

		For nx:= 0 to Len(aContRA1)
			If nx > Len(aContRA1)
				If SX3->(dbSeek(aContRA1[nx+1][1]))
		   	 		If X3_ARQUIVO == "RA1"
						aAdd(aCabec,SX3->(AllTrim(X3Titulo())))
					EndIf
				EndIf
			EndIf
		Next

	EndIf

	o3Lbx:aHeaders := {}
	o3Lbx:aHeaders := aCabec

	MontaLinha(@o3Lbx,a2List)

	RestArea(aSaveArea)

Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Montalinha³ Autor ³ Alceu Pereira        ³ Data ³ 19.10.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta a linha do list Box da aba curso                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Montalinha(o3Lbx)
Local aSaveArea		:= GetArea()
Local nx			:= 0
Local nCont			:= 0
Local cComand		:= ""
Local bLine			:= {||}

	cComand := "a2List[o3Lbx:nAt,1],a2List[o3Lbx:nAt,2],a2List[o3Lbx:nAt,3],Transform(a2List[o3Lbx:nAt,4],PesqPict('RA5','RA5_HORAS')),Transform(a2List[o3Lbx:nAt,5],PesqPict('RA5','RA5_NOTA')),Transform(a2List[o3Lbx:nAt,6],PesqPict('RA5','RA5_FREQUE')),Transform(a2List[o3Lbx:nAt,7],PesqPict('RA5','RA5_EFICAC')),a2List[o3Lbx:nAt,8]"

	For nx := 0 To Len(aContRA5)
		If nx < Len(aContRA5)
			nCont := ( 9 + nx )
			 cComand += ",+a2List[o3Lbx:nAt,"+AllTrim(Str(nCont))+"]"
		EndIf
	Next

	bLine := &("{|| {"+cComand+"}}")

	o3Lbx:SetArray(a2List)
	o3Lbx:bLine:= bLine

	RestArea(aSaveArea)

Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TR100FASpt ³ Autor ³ Glaucia C. Messina   ³ Data ³ 16.02.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Soma de Pontos na Aba Fatores de Avaliação (Func. e Cargo). ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TRMA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TR100FASpt(aColsM,nTipo)  // nTipo - 1- Soma Fatores Avaliação Funcionario  //	nTipo - 2- Soma Fatores Avaliação Cargo
Local nPosPtos		:= GdFieldPos("Q8_PONTOS")
Local nSomaPto		:=0
Local nx:=0

DEFAULT nTipo	:= 1
DEFAULT aColsM	:= aCols

If ValType( aColsM ) == "A"
	For nx:=1 To Len(aColsM) 								//Varre o2Group1 ou o2Group2
		If nTipo == 1 .and. !(aColsM[nx][len(aHeader)+1]) 	//verifica se tb se a linha não foi apagada
			nSomaPto := nSomaPto + aColsM[nx][nPosPtos]
		EndIf

		If nTipo == 2
			nSomaPto := nSomaPto + aColsM[nx][5]
		EndIf
	Next nx

	nSomaPto:=Transform(nSomaPto,"@E 99,999.999")

	If nTipo == 1											//atualiza a somatória na Tela
		oSayPFunc:SetText(nSomaPto)
	ElseIf nTipo == 2
		oSayPCargo:SetText(nSomaPto)
	EndIf
EndIf

Return( .T. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TR100FAshow³ Autor ³ Glaucia C. Messina   ³ Data ³ 16.02.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Apresentar itens do Rodape Totais de Pontos Funcionários   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TR100FAshow()

	o2Group3:Show()
	oSayRodFator:Show()
	oSayRodCargo:Show()
	oSayPFunc:Show()
	oSayPCargo:Show()

return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TR100FAhide³ Autor ³ Glaucia C. Messina   ³ Data ³ 16.02.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Tornar invisivel os itens do  Rodape Totais de Pontos 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TRMA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TR100FAhide()

	o2Group3:Hide()
	oSayRodFator:Hide()
	oSayRodCargo:Hide()
	oSayPFunc:Hide()
	oSayPCargo:Hide()

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ TRMA100  ºAutor  ³Gustavo M.		     º Data ³  20/12/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Acerto de SXB	                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TRMA100                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fCkhFator()
Local nPosFator := 0
Local cFator	:= ""

	nPosFator:= GdFieldPos("Q8_FATOR")

	If nPosFator > 0
		cFator:= aCols[n][nPosFator]
	EndIf

Return( cFator )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ TRMA100  ºAutor  ³ Luiz Gustavo 	     º Data ³  15/01/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Opcoes de menu.	                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TRMA100                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa 	 ³
//³ ----------- Elementos contidos por dimensao ------------	 ³
//³ 1. Nome a aparecer no cabecalho 							 ³
//³ 2. Nome da Rotina associada									 ³
//³ 3. Usado pela rotina										 ³
//³ 4. Tipo de Transa‡„o a ser efetuada							 ³
//³	 1 - Pesquisa e Posiciona em um Banco de Dados				 ³
//³	 2 - Simplesmente Mostra os Campos							 ³
//³	 3 - Inclui registros no Bancos de Dados					 ³
//³	 4 - Altera o registro corrente								 ³
//³	 5 - Remove o registro corrente do Banco de Dados			 ³
//³	 6 - Alteracao sem inclusao de registro						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aRotina	:= {}
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem

aAdd( aRotina, { STR0002,"PesqBrw",	0 , 1 , ,.F.} )		// "Pesquisar"
aAdd( aRotina, { STR0003,"TRM100Rot",	0 , 2} )		// "Visualizar"

If nModulo != 70	//Se Modulo nao for SIGAORG
	aAdd( aRotina, { STR0004,"TRM100Rot",	0 , 3} )	// "Incluir"
	aAdd( aRotina, { STR0005,"TRM100Rot",	0 , 4} )	// "Alterar"
	aAdd( aRotina, { STR0006,"TRM100Rot",	0 , 5} )	// "Excluir"
EndIf
aAdd( aRotina, { STR0048,"TRM100Leg",	0 , 2,,.F.} )	// "Legenda"

If aOfusca[2] .And. FindFunction("fRhBanConh")
	aAdd( aRotina, { STR0099,"fRhBanConh", 0, 4, ,.F.} )	// "Conhecimento"
Else
	aAdd( aRotina, { STR0099,"MsDocument", 0, 4 } )	// "Conhecimento"
EndIf

Return( aRotina )

/*/{Protheus.doc} GenChkLst
	Gerar CheckList
@author PHILIPE.POMPEU
@since 11/09/2015
@version P12
@return ${return}, ${return_description}
/*/
Static Function GenChkLst()
	Local aArea	:= GetArea()
	Local aCurso	:= {}
	Local aCampos	:= {}
	Local uTemp
	Local lIncl		:= INCLUI
	if(cIndo == "03") /*Se for a aba de Cursos(03)*/
		If !INCLUI
			uTemp := aCols[n,GdFieldPos('RA4_REC_WT')]
			if!(Empty(uTemp)) /*Nesse caso apesar de não estar incluindo um funcionário, o curso não foi salvo ainda.*/
				aCampos := StrToKarr("RA4_CURSO|RA4_SINONI|RA4_ENTIDA|RA4_VALIDA|RA4_DATAIN|RA4_DATAFI|RA4_REC_WT","|")

				aAdd(aCurso,{'RA4_FILIAL',FwxFilial('RA4')})
				aAdd(aCurso,{'RA4_MAT',SRA->RA_MAT})

				aEval(aCampos,{|x|IIF((uTemp := GdFieldPos(x)) > 0,aAdd(aCurso,{x,aCols[n,uTemp]}),)})

				TRMA260(aCurso)

				INCLUI := lIncl

				aSize(aCampos,0)
				aCampos:= Nil
				aSize(aCurso,0)
				aCurso := Nil
			Else
				Aviso(STR0036,STR0107,{"OK"})//"Aviso"#"Opção não disponível na inclusão"
			endIf
		Else
			Aviso(STR0036,STR0107,{"OK"})//"Aviso"#"Opção não disponível na inclusão"
		EndIf
	endIf

	RestArea(aArea)
Return(Nil)




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ VrfRA6³ Autor ³ Oswaldo L        		³ Data ³ 12.09.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se existe o registro de vinculo curso X entidade  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TRMA100		 											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function VrfRA6(cCurso, cEntidade)

	Local lRet      := .F.
	Local cRa6Alias := GetNextALias()
	Local aArea     := GetArea()

	BeginSql Alias cRa6Alias
		SELECT RA6_FILIAL, RA6_ENTIDA, RA6_CURSO
		FROM %table:RA6% RA6
		WHERE RA6_FILIAL = %Exp:(Fwxfilial('RA6'))%
		AND RA6.RA6_ENTIDA = %Exp:(cEntidade)%
		AND RA6.RA6_CURSO = %Exp:(cCurso)%
		AND RA6.%NotDel%
	EndSql

	If (cRa6Alias)->(!Eof())
		lRet := .T.
	EndIf

	(cRa6Alias)->(DBCloseArea())
	restArea(aArea)

Return lRet


/*/{Protheus.doc} fPrepDadosApi
Processo para preparar os dados de inclusão/alteração/deleção para
integração via API REST.

@since	08/04/2020
@autor	Wesley Alves Pereira
@version P12.1.XX

/*/
Static Function fPrepDadosApi(nOpcModel)

Local aArea		:= GetArea()

Local cOperacao := ""
Local lIntegrac := SUPERGETMV('MV_RHNG', .F., .F.)

If ( ! ( lIntegrac) )
	Return (.T.)
EndIf

If nOpcModel == 5
	cOperacao := "E"
	fSendDadosApi(cOperacao)
	fSendSRAApi(cOperacao)
ElseIf nOpcModel == 4
	cOperacao := "A"
	fSendDadosApi(cOperacao)
ElseIf nOpcModel == 3
	cOperacao := "I"
	fSendDadosApi(cOperacao)
EndIf

RestArea(aArea)

Return (.T.)

/*/{Protheus.doc} fSendDadosApi
Processo para enviar os dados de inclusão/alteração/deleção para
integração via API REST.

@since	08/04/2020
@autor	Wesley Alves Pereira
@version P12.1.XX

/*/
Static Function fSendDadosApi(cOperacao)

Local dDtBase   := DDATABASE
Local cHoraAt   := time()
Local cTmpEmp   := cEmpAnt
Local cProces   := "RA4"
Local cUserId   := SubStr(cUsuario,7,15)
Local cTmpCod   := cMat
Local cTmpFil   := xFilial("RA4")
Local cChave    := ""
Local cNewAlias  := GetNextAlias()
Local cQuery    := ""
Local lAchou    := .F.
Local nXi       := 0

// Montagem da consulta
cQuery := " SELECT * FROM " + RetSqlName("RA4")
cQuery += " WHERE RA4_FILIAL = '" +cTmpFil+ "'"
cQuery += " AND   RA4_MAT    = '" +cTmpCod+ "'"
cQuery += " AND " + RetSqlName("RA4") + ".D_E_L_E_T_ = '' "

cQuery := ChangeQuery(cQuery)

DBUseArea( .T., "TOPCONN", TcGenQry( , ,cQuery), cNewAlias, .F., .T. )

DbSelectArea(cNewAlias)
DbGoTop()

If ( cOperacao == 'I')

	While (cNewAlias)->(!Eof())

		cChave := cTmpEmp + "|" + cTmpFil + "|" + cTmpCod + "|" + (cNewAlias)->RA4_CURSO + "|" + (cNewAlias)->RA4_SINONI + "|" + (cNewAlias)->RA4_ENTIDA + "|" + (cNewAlias)->RA4_DATAIN

		fSetInforRJP(cTmpFil, cTmpCod, cProces, cChave, cOperacao,  dDtBase, cHoraAt,cUserId)

		(cNewAlias)->(dbSkip())

	EndDo

ElseIf ( cOperacao == 'E')

	For nXi := 1 To Len (aDelAliasRA4)
		cChave := cTmpEmp + "|" + cTmpFil + "|" + aDelAliasRA4[nXi][1] + "|" + aDelAliasRA4[nXi][2] + "|" + aDelAliasRA4[nXi][3] + "|" + aDelAliasRA4[nXi][4] + "|" + aDelAliasRA4[nXi][5]
		fSetInforRJP(cTmpFil, aDelAliasRA4[nXi][1], cProces, cChave, "E",  dDtBase, cHoraAt,cUserId)
	Next nXi

ElseIf ( cOperacao == "A")

	DbSelectArea(cNewAlias)
	DbGoTop()

	While (cNewAlias)->(!Eof())

		lAchou := .F.

		For nXi := 1 To Len (aOldAliasRA4)

			If (cNewAlias)->R_E_C_N_O_ == aOldAliasRA4[nXi][1]

				lAchou := .T.

				//Trocou chave
				If 		(cNewAlias)->RA4_CURSO  <> aOldAliasRA4[nXi][2] .OR. ;
						(cNewAlias)->RA4_SINONI <> aOldAliasRA4[nXi][3] .OR. ;
						(cNewAlias)->RA4_ENTIDA <> aOldAliasRA4[nXi][4] .OR. ;
						(cNewAlias)->RA4_DATAIN <> aOldAliasRA4[nXi][5]


						cChave := cTmpEmp + "|" + cTmpFil + "|" + cTmpCod + "|" + aOldAliasRA4[nXi][2] + "|" + aOldAliasRA4[nXi][3] + "|" + aOldAliasRA4[nXi][4] + "|" + aOldAliasRA4[nXi][5]
						fSetInforRJP(cTmpFil, cTmpCod, cProces, cChave, "E",  dDtBase, cHoraAt,cUserId)

						cChave := cTmpEmp + "|" + cTmpFil + "|" + cTmpCod + "|" + (cNewAlias)->RA4_CURSO + "|" + (cNewAlias)->RA4_SINONI + "|" + (cNewAlias)->RA4_ENTIDA + "|" + (cNewAlias)->RA4_DATAIN
						fSetInforRJP(cTmpFil, cTmpCod, cProces, cChave, "I",  dDtBase, cHoraAt,cUserId)


				//Não trocou chave
				ElseIf  (cNewAlias)->RA4_DATAFI <> aOldAliasRA4[nXi][6] .OR. ;
						(cNewAlias)->RA4_NOTA   <> aOldAliasRA4[nXi][7] .OR. ;
						(cNewAlias)->RA4_VALIDA <> aOldAliasRA4[nXi][8]

						cChave := cTmpEmp + "|" + cTmpFil + "|" + cTmpCod + "|" + (cNewAlias)->RA4_CURSO + "|" + (cNewAlias)->RA4_SINONI + "|" + (cNewAlias)->RA4_ENTIDA + "|" + (cNewAlias)->RA4_DATAIN
						fSetInforRJP(cTmpFil, cTmpCod, cProces, cChave, "A",  dDtBase, cHoraAt,cUserId)

				EndIf

				Exit

			EndIf

		Next nXi

		If ( ! lAchou )
			cChave := cTmpEmp + "|" + cTmpFil + "|" + cTmpCod + "|" + (cNewAlias)->RA4_CURSO + "|" + (cNewAlias)->RA4_SINONI + "|" + (cNewAlias)->RA4_ENTIDA + "|" + (cNewAlias)->RA4_DATAIN
			fSetInforRJP(cTmpFil, cTmpCod, cProces, cChave, "I",  dDtBase, cHoraAt,cUserId)
		EndIf

		DbSelectArea(cNewAlias)
		(cNewAlias)->(dbSkip())

	EndDo

	For nXi := 1 To Len (aOldAliasRA4)

		DbSelectArea(cNewAlias)
		DbGoTop()

		lAchou := .F.

		While (cNewAlias)->(!Eof()) .AND. ( ! lAchou )

			If (cNewAlias)->R_E_C_N_O_ == aOldAliasRA4[nXi][1]

				lAchou := .T.

			EndIf

			DbSelectArea(cNewAlias)
			(cNewAlias)->(dbSkip())

		EndDo

		If ( ! lAchou )
			cChave := cTmpEmp + "|" + cTmpFil + "|" + cTmpCod + "|" + aOldAliasRA4[nXi][2] + "|" + aOldAliasRA4[nXi][3] + "|" + aOldAliasRA4[nXi][4] + "|" + aOldAliasRA4[nXi][5]
			fSetInforRJP(cTmpFil, cTmpCod, cProces, cChave, "E",  dDtBase, cHoraAt,cUserId)
		EndIf


	Next nXi

EndIf

(cNewAlias)->(DbCloseArea())

Return (.T.)

Static Function fSendSRAApi(cOperacao)

Local dDtBase   := dDataBase
Local cHoraAt   := Time()
Local cTmpEmp   := cEmpAnt
Local cProces   := "SRA"
Local cUserId   := SubStr(cUsuario,7,15)
Local cTmpMat   := M->RA_MAT
Local cTmpFil   := xFilial ("SRA")
Local cChave    := cTmpEmp + "|" + cTmpFil + "|" + cTmpMat
Default cOperacao := 'E'

fSetInforRJP(cTmpFil, cTmpMat, cProces, cChave, cOperacao,  dDtBase, cHoraAt, cUserId)

Return (.T.)
