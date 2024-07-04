#INCLUDE "Mata916.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOLE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Mata916   �Autor  �Mary C. Hergert     � Data �  05/07/2006 ���
�������������������������������������������������������������������������͹��
���Desc.     �Impressao do RPS - Recibo Provisorio de Servicos - referente���
���          �ao processo da Nota Fiscal Eletronica de Sao Paulo, atraves ���
���          �de arquivo .DOT com o modelo pre-definido pela Microsiga.   ���
�������������������������������������������������������������������������͹��
���Uso       �Sigafis                                                     ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
���Marcos Kato   �25/06/09�152132� Correcao valor do cofins - Registro 3  ���
���              �        �      � na Funcao RetImpost()                  ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Mata916()

Local aIndexSF3  := {}
Local cTitulo    := ""
Local cErro      := ""
Local cSolucao   := ""
Local cNfeServ   := SuperGetMv("MV_NFESERV",.F.,"")
Local cFiltraSF3 := ""
Local cCampos    := ""
Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)

If lVerpesssen
	If Empty(cNfeServ)
		cTitulo		:= STR0019 //"Par�metro inexistente"
		cErro		:= STR0020 //"O par�metro MV_NFESERV n�o est� definido no dicion�rio de dados. "
		cErro		+= STR0021 //"Este par�metro ir� indicar como dever� ser composta a descri��o "
		cErro		+= STR0022 //"do servi�o prestado no documento. Caso este par�metro n�o seja "
		cErro		+= STR0023 //"cadastrado, a descri��o sempre ser� composta pelo conte�do "
		cErro		+= STR0024 //"da tabela 60 do SX5. O programa tem a op��o de compor a descri��o "
		cErro		+= STR0025 //"do servi�o prestado observando tamb�m a mensagem da nota fiscal "
		cErro		+= STR0026 //"lan�ada no pedido de vendas. Para tanto, ser� necess�rio observar "
		cErro		+= STR0027 //"a solu��o proposta abaixo: "
		cSolucao	:= STR0028 //"Estrutura do par�metro MV_NFESERV: "
		cSolucao	+= STR0029 //"<indica se a descri��o do servi�o prestado na Nota Fiscal "
		cSolucao	+= STR0030 //"Eletr�nica dever� ser composta 1 = pelo pedido de vendas ou "
		cSolucao	+= STR0031 //"descri��o do SX5 ou 2 - somente pela descri��o do SX5>."
		cSolucao	+= STR0032 //" Para maiores refer�ncias, consultar a documenta��o que acompanha a rotina."
		xMagHelpFis(cTitulo,cErro,cSolucao)
		Return()
	Endif

	Private lJoinvile := Iif(GetNewPar("MV_ESTADO","xx") == "SP" .And. Alltrim(SM0->M0_CIDENT) == "JOINVILE",.T.,.F.)
	Private lRecife   := Iif(GetNewPar("MV_ESTADO","xx") == "PE" .And. Alltrim(SM0->M0_CIDENT) == "RECIFE",.T.,.F.)
	Private lCarioca  := Iif(GetNewPar("MV_ESTADO","xx") == "RJ" .And. Alltrim(SM0->M0_CIDENT) == "RIO DE JANEIRO",.T.,.F.)
	Private lPaulista := Iif(GetNewPar("MV_ESTADO","xx") == "SP" .And. Alltrim(SM0->M0_CIDENT) == "SAO PAULO",.T.,.F.)

	If !Pergunte("MTA916",.T.)
		Return
	Endif

	PRIVATE cWord    := OLE_CreateLink()
	PRIVATE cPath    := AllTrim(mv_par01)
	PRIVATE cArquivo := cPath+Alltrim(mv_par02)
	PRIVATE aRotina  := MenuDef()

	//���������������������������������������������Ŀ
	//� Define o cabecalho da tela de atualizacoes  �
	//�����������������������������������������������
	PRIVATE cCadastro := OemToAnsi(STR0017) //"Carta de Correcao"

	If !File(AllTrim(mv_par01)+AllTrim(mv_par02))
		cTitulo		:= STR0001				//"Arquivo modelo n�o encontrado"	
		cErro		:= STR0002 + Alltrim(mv_par02)	//"O arquivo modelo para impress�o dos RPS " 
		cErro		+= STR0003 + Alltrim(mv_par01)	//"n�o foi encontrado no diret�rio "
		cErro		+= STR0004				//", indicado nas perguntas da rotina."
		cSolucao	:= STR0005				//"Verifique se o arquivo de retorno informado nas "
		cSolucao	:= STR0006				//"Informe o diret�rio e o nome do arquivo "
		cSolucao	+= STR0007				//"corretamente e processe a rotina novamente."
		xMagHelpFis(cTitulo,cErro,cSolucao)
		Return
	Endif

	If (cWord < "0")
		cTitulo		:= STR0008				//"MS-Word n�o localizado"	
		cErro		:= STR0009				//"O programa MS-Word n�o est� instalado nesta m�quina. " 
		cErro		+= STR0010				//"Apenas com a exist�ncia deste programa, � poss�vel "
		cErro		+= STR0011				//"efetuar a impress�o do RPS."
		cSolucao	:= STR0012				//"Instale o MS-Word nesta m�quina ou efetue a impress�o "
		cSolucao	:= STR0013				//"em outra m�quina que possua o programa instalado."
		xMagHelpFis(cTitulo,cErro,cSolucao)
		Return
	Endif

	OLE_SetProperty(cWord, oleWdVisible  ,.F. )

	//������������������������������������������������������������������������Ŀ
	//� Inicializa o filtro de usuario utilizando a funcao FilBrowse           �
	//��������������������������������������������������������������������������
	dbSelectArea("SF3")
	dbSetOrder(6)
	cFiltraSF3 := "F3_FILIAL == '" + xFilial("SF3") + "' .And. "
	cFiltraSF3 += "Dtos(F3_ENTRADA) >= '" + Dtos(mv_par03) + "' .And. "
	cFiltraSF3 += "Dtos(F3_ENTRADA) <= '" + Dtos(mv_par04) + "' .And. "
	cFiltraSF3 += "F3_CLIEFOR >= '" + mv_par05 + "' .And. "
	cFiltraSF3 += "F3_CLIEFOR <= '" + mv_par06 + "' .And. "
	cFiltraSF3 += "F3_TIPO == 'S' .And. "
	cFiltraSF3 += "(!Empty(F3_CODISS) .Or. !Empty(F3_CNAE)) .And. "
	cFiltraSF3 += "F3_NFISCAL >= '" + mv_par09 + "' .And. "
	cFiltraSF3 += "F3_NFISCAL <= '" + mv_par10 + "' .And. "
	cFiltraSF3 += "Left(F3_CFO,1) >= '5'"
	//�����������������������������������������������������Ŀ
	//�Verifica se considera ou nao os documentos cancelados�
	//�������������������������������������������������������
	If mv_par11 == 2
		cFiltraSF3 += " .And. Empty(F3_DTCANC) .And. !('CANCELAD'$(F3_OBSERV))"
	Endif

	bFiltraBrw := {|| FilBrowse("SF3",@aIndexSF3,@cFiltraSF3) }
	Eval(bFiltraBrw)

	mBrowse(6, 1, 22, 75, "SF3")
	EndFilBrw("SF3", aIndexSF3)

	OLE_CloseLink(cWord) //fecha o Link com o Word
EndIf

Return Nil

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Mta916Imp � Autor � Mary C. Hergert       � Data �05/07/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de Geracao e Impressao do RPS                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1 = Alias do arquivo                                    ���
���          �ExpN1 = Numero do registro                                  ���
���          �ExpN2 = Numero da opcao selecionada                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Mata916                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Mta916Imp(cAlias,nReg,nOpcao)

Local aAreaRPS		:= {}
Local aTMS			:= {}
Local aMTCliNfe		:= {}
Local cCli			:= ""
Local cCNPJCli		:= ""
Local cIMCli		:= ""
Local cEndCli		:= ""
Local cBairrCli		:= ""
Local cCepCli		:= ""
Local cMunCli		:= ""
Local cCodMun		:= ""
Local cUFCli		:= ""
Local cEmailCli		:= ""
Local cNfeServ		:= SuperGetMv("MV_NFESERV",.F.,"2")
Local cFieldMsg		:= SuperGetMv("MV_CMPUSR",.F.,"")
Local cCodServ		:= ""
Local cCodAtiv		:= ""
Local cServ			:= ""
Local cDescrServ	:= ""
Local cChave		:= ""
Local cServPonto	:= ""
Local cObsPonto		:= ""
Local cArqRPS		:= ""
Local cDescrBar     := SuperGetMv("MV_DESCBAR",.F.,"")
Local lCampBar      := !Empty(cDescrBar)
Local cObsRio       := ""
Local cTotImp		:= ""
Local cFontImp		:= ""
Local lDescrNFE		:= ExistBlock("MTDESCRNFE")
Local lObsNFE		:= ExistBlock("MTOBSNFE")
Local lGravaNFE		:= ExistBlock("MTGRAVNFE")
Local lCliNFE		:= ExistBlock("MTCLINFE")
Local lPEImpRPS		:= ExistBlock("MTIMPRPS")
Local lDescrBar		:= GetNewPar("MV_DESCSRV",.F.)
Local lImpRPS		:= .T.
Local nValDed		:= 0
Local nValINSS		:= 0
Local nValIRPJ		:= 0
Local nValCSLL		:= 0
Local nValCOF		:= 0
Local nValPIS		:= 0
Local nValBase		:= 0
Local nAliquota		:= 0
Local nValISS		:= 0
Local nValServ		:= 0
Local nDesIncond	:= 0
Local nValCre		:= 0
Local dDtEmissao    := ""
Local lCodIss       := .F.
Local lCnae         := .F.
Local lCfop         := .F.
Local nQtde         := 0
Local nRegEmp       := SM0->(RecNo())
Local lCancel       := .F.
Local lCliente      := .F.
Local cNumPed       :=  ""
Local lFirst        := .T.
Local cCNPJInt		:= ""
Local cNomInt		:= ""
Local cMunPreSer	:= ""
Local cNroInsObr	:= ""
Local cVlrAprTri	:= ""
Local cLeiTransp	:= ""

If (cWord >= "0")
	OLE_CloseLink(cWord) //fecha o Link com o Word
	cWord:= OLE_CreateLink()
	OLE_NewFile(cWord,cArquivo)
	//������������������������������������������������������������������������Ŀ
	//�Funcao que faz o Word aparecer na Area de Transferencia do Windows,     �
	//�sendo que para habilitar/desabilitar e so colocar .T. ou .F.            �
	//��������������������������������������������������������������������������
	If nOpcao == 3 //Manual
		OLE_SetProperty(cWord, oleWdVisible  ,.T. )
		OLE_SetProperty(cWord, oleWdPrintBack,.T. )
	Else  //automatico
		OLE_SetProperty(cWord, oleWdVisible  ,.F. )
		OLE_SetProperty(cWord, oleWdPrintBack,.F. )
	Endif
Endif

if nOpcao == 4    //automatico
	SF3->(dbGoTop())
Endif

cChave := xFilial("SF3") + SF3->F3_CLIEFOR + SF3->F3_LOJA + SF3->F3_NFISCAL + SF3->F3_SERIE          

SM0->(dbGoTo(nRegEmp))
cfilial := xFilial("SF3")

Do While !(SF3->(Eof())) .And. cChave == cfilial + SF3->F3_CLIEFOR + SF3->F3_LOJA + SF3->F3_NFISCAL + SF3->F3_SERIE 
	//�����������������������������������������������������������������Ŀ
	//�Busca na SF3  para  validar quais registro devem ser selecionados�
	//�de acordo com os parametros definidos na pesquisa para Impress�o �
	//�������������������������������������������������������������������
	dDtEmissao :=  SF3->F3_EMISSAO
	lCodIss    := !Empty(SF3->F3_CODISS)
	lCnae      := !Empty(SF3->F3_CNAE)
	lCfop      := Left(SF3->F3_CFO,1) >= "5"
	lRPS       := iif(((F3_NFISCAL >= mv_par09 .And. F3_NFISCAL <= mv_par10) .Or. len(mv_par09)==0),.T.,.F.)
	lCancel    := iif(!Empty(SF3->F3_DTCANC) .And. ('CANCELAD'$(SF3->F3_OBSERV)) .And. mv_par11==2,.F.,.T.)
	lCliente   := Iif(!Empty(mv_par05), Iif(SF3->F3_CLIEFOR == mv_par05 .Or. SF3->F3_CLIEFOR == mv_par06 .Or. (SF3->F3_CLIEFOR >= mv_par05 .And. SF3->F3_CLIEFOR <= mv_par06), .T. ,.F.), .T.)

	If dDtEmissao >=  mv_par03 .And. dDtEmissao <=  mv_par04 .And.lCfop .And. cfilial == SF3->F3_FILIAL .And. lRPS .And.  lCancel .And. (lCodIss .Or. lCnae) .And. lCliente
		//�������������������������Ŀ
		//�Variaves para a impressao�
		//���������������������������
		cIMCli		:= Space(TamSX3("A2_INSCR")[1])
		cEndCli		:= Space(TamSX3("A2_END")[1])
		cBairrCli	:= Space(TamSX3("A2_BAIRRO")[1])
		cCepCli		:= Space(TamSX3("A2_CEP")[1])
		cMunCli		:= Space(TamSX3("A2_MUN")[1])
		cCodMun		:= Space(TamSX3("A2_COD_MUN")[1])
		cUFCli		:= Space(TamSX3("A2_EST")[1])
		cEmailCli	:= Space(TamSX3("A2_EMAIL")[1])
		nValDed		:= 0
		nValINSS	:= 0
		nValIRPJ	:= 0
		nValCSLL	:= 0
		nValCOF		:= 0
		nValPIS		:= 0
		nValBase	:= 0
		nAliquota	:= 0
		nValISS		:= 0
		cCodServ	:= Space(TamSX3("F3_CODISS")[1])
		cCodAtiv	:= Space(TamSX3("F3_CNAE")[1])
		nValServ	:= 0
		cDescrServ	:= Space(TamSX3("X5_DESCRI")[1])
		cServ		:= cDescrServ
		//�����������������������������������������������������������������Ŀ
		//�Busca o SF2 a data da emissao para validar com o parametro       �
		//�de pesquisa os parametros de data e hora em que a NF foi emitida �
		//�e Lei da Transparencia - 12.741                                  �                          
		//�������������������������������������������������������������������	
		cTime     := ""
		cTotImp   := ""
		cFontImp  := ""
		cLeiTransp:= ""
		SF2->(dbSetOrder(1))
		If SF2->(dbSeek(xFilial("SF2")+SF3->F3_NFISCAL+SF3->F3_SERIE))
			cTime := SF2->F2_HORA
			//Lei Transpar�ncia - 12.741
			cTotImp := Iif(SF2->F2_TOTIMP > 0,"Valor Aproximado dos Tributos: R$ "+Alltrim(Transform(SF2->F2_TOTIMP,"@E 999,999,999,999.99")+"."),"")			
			//Busca a fonte da Carga Tribut�ria - Lei Transpar�ncia - 12.741
			SB1->(dbSetOrder(1))
			SD2->(dbSetOrder(3))
			If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
				If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
					cFontImp:= Iif(!Empty(cTotImp) .And. "IBPT" $ AlqLeiTran("SB1","SBZ")[2],"Fonte: "+AlqLeiTran("SB1","SBZ")[2],"")
				EndIf
			EndIf
			cLeiTransp := Iif(SF2->F2_TOTIMP > 0, Alltrim(Transform(SF2->F2_TOTIMP,"@E 999,999,999,999.99"))+"/"+AlqLeiTran("SB1","SBZ")[2],"")
		Endif
		//���������������������������������������Ŀ
		//�Verificando dados do cliente/fornecedor�
		//�����������������������������������������
		If SF3->F3_TIPO $ "DB"
			dbSelectArea("SA2")
			dbSetOrder(1)
			MsSeek(xFilial("SA2")+SF3->F3_CLIEFOR+SF3->F3_LOJA)
			cCli := SA2->A2_NOME
			If RetPessoa(SA2->A2_CGC) == "F"
				cCNPJCli := Transform(SA2->A2_CGC,"@R 999.999.999-99")
			Else
				cCNPJCli := Transform(SA2->A2_CGC,"@R 99.999.999/9999-99")
			Endif
			cIMCli		:= SA2->A2_INSCR
			cEndCli		:= SA2->A2_END
			cBairrCli	:= SA2->A2_BAIRRO
			cCepCli		:= SA2->A2_CEP
			cMunCli		:= SA2->A2_MUN
			cCodMun		:= SA2->A2_COD_MUN
			cUFCli		:= SA2->A2_EST
			cEmailCli	:= SA2->A2_EMAIL
		Else
			dbSelectArea("SA1")
			dbSetOrder(1)
			MsSeek(xFilial("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA)
			cCli		:= SA1->A1_NOME
			If RetPessoa(SA1->A1_CGC) == "F"
				cCNPJCli := Transform(SA1->A1_CGC,"@R 999.999.999-99")
			Else
				cCNPJCli := Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
			Endif
			cIMCli		:= SA1->A1_INSCRM
			cEndCli		:= SA1->A1_END
			cBairrCli	:= SA1->A1_BAIRRO
			cCepCli		:= SA1->A1_CEP
			cMunCli		:= SA1->A1_MUN
			cCodMun		:= SA1->A1_COD_MUN
			cUFCli		:= SA1->A1_EST
			cEmailCli	:= SA1->A1_EMAIL
		Endif
		//�����������������������������������������������������������������������������Ŀ
		//�Funcao que retorna o endereco do solicitante quando houver integracao com TMS�
		//�������������������������������������������������������������������������������
		If IntTms()
			aTMS := TMSInfSol(SF3->F3_FILIAL,SF3->F3_NFISCAL,SF3->F3_SERIE)
			If Len(aTMS) > 0
				cCli		:= aTMS[04]
				If RetPessoa(Alltrim(aTMS[01])) == "F"
					cCNPJCli := Transform(Alltrim(aTMS[01]),"@R 999.999.999-99")
				Else
					cCNPJCli := Transform(Alltrim(aTMS[01]),"@R 99.999.999/9999-99")
				Endif
				cIMCli		:= aTMS[02]
				cEndCli		:= aTMS[05]
				cBairrCli	:= aTMS[06]
				cCepCli		:= aTMS[09]
				cMunCli		:= aTMS[07]
				cUFCli		:= aTMS[08]
				cEmailCli	:= aTMS[10]
			Endif
		Endif
		//������������������������������������������������������Ŀ
		//�Ponto de entrada para trocar o cliente a ser impresso.�
		//��������������������������������������������������������
		If lCliNFE
			aMTCliNfe := Execblock("MTCLINFE",.F.,.F.,{SF3->F3_NFISCAL,SF3->F3_SERIE,SF3->F3_CLIEFOR,SF3->F3_LOJA}) 
			// O ponto de entrada somente e utilizado caso retorne todas as informacoes necessarias
			If Len(aMTCliNfe) >= 12
				cCli		:= aMTCliNfe[01]
				cCNPJCli	:= aMTCliNfe[02]
				If RetPessoa(cCNPJCli) == "F"
					cCNPJCli := Transform(cCNPJCli,"@R 999.999.999-99")
				Else
					cCNPJCli := Transform(cCNPJCli,"@R 99.999.999/9999-99")
				Endif
				cIMCli		:= aMTCliNfe[03]
				cEndCli		:= aMTCliNfe[04]
				cBairrCli	:= aMTCliNfe[05]
				cCepCli		:= aMTCliNfe[06]
				cMunCli		:= aMTCliNfe[07]
				cUFCli		:= aMTCliNfe[08]
				cEmailCli	:= aMTCliNfe[09]
			Endif
		Endif

		If lJoinvile
			SF2->(dbSetOrder(1))
			SB1->(dbSetOrder(1))
			SD2->(dbSetOrder(3))
			If SF2->(dbSeek(xFilial("SF2")+SF3->F3_NFISCAL+SF3->F3_SERIE))
				If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
					If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
						nValDed		:= (SF3->F3_ISSSUB)+(SF3->F3_ISSMAT)
						nValBase	:= Iif (Empty(SF3->F3_BASEICM),SF3->F3_ISENICM,SF3->F3_BASEICM)
						nAliquota	:= SB1->B1_ALIQISS
						nValISS		:= SF3->F3_VALICM
						cCodServ	:= SF3->F3_CODISS
						cCodAtiv	:= SF3->F3_CNAE
						nValServ	:= SF3->F3_VALCONT
					Endif
				EndIf
			EndIf
		EndIf

		If !(lJoinvile)
			nValDed		:= (SF3->F3_ISSSUB)+(SF3->F3_ISSMAT)
			nValBase	:= SF3->F3_BASEICM
			nAliquota	:= SF3->F3_ALIQICM
			nValISS		:= SF3->F3_VALICM
			cCodServ	:= SF3->F3_CODISS
			cCodAtiv	:= SF3->F3_CNAE
			nValServ	:= SF3->F3_VALCONT
		EndIf

		SF2->(dbSetOrder(1))
		If SF2->(dbSeek(xFilial("SF2")+SF3->F3_NFISCAL+SF3->F3_SERIE))
			nValINSS	:= SF2->F2_VALINSS
			nValIRPJ	:= SF2->F2_VALIRRF
			nValCSLL	:= SF2->F2_VALCSLL
			nValPIS		:= SF2->F2_VALPIS
			nValCOF		:= SF2->F2_VALCOFI
		Endif

		//���������������������������������������Ŀ
		//�Busca a descricao do codigo de servicos�
		//�����������������������������������������
		SX5->(dbSetOrder(1))
		If SX5->(dbSeek(xFilial("SX5")+"60"+SF3->F3_CODISS))
			cDescrServ := X5Descri()
		Endif
		If lDescrBar
			SF2->(dbSetOrder(1))
			SB1->(dbSetOrder(1))
			SD2->(dbSetOrder(3))
			If SF2->(dbSeek(xFilial("SF2")+SF3->F3_NFISCAL+SF3->F3_SERIE))
				If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
					If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
						cDescrServ := If (lCampBar,SB1->(AllTrim(&cDescrBar)),cDescrServ)
					Endif
				Endif
			Endif
		Endif

		//������������������������������������������������������������������Ŀ
		//�Busca o pedido para discriminar os servicos prestados no documento�
		//��������������������������������������������������������������������
		If cNfeServ == "1"
			SC6->(dbSetOrder(4))
			SC5->(dbSetOrder(1))

			If SC6->(dbSeek(xFilial("SC6")+SF3->F3_NFISCAL+SF3->F3_SERIE))

				cServ   := Alltrim(cServ)
				cNumPed := SC6->C6_NUM
				lFirst  := .T.

				Do While xFilial("SC6")+SF3->F3_NFISCAL+SF3->F3_SERIE  == xFilial("SC6")+SC6->C6_NOTA+SC6->C6_SERIE
					If SC6->C6_NUM == cNumPed
						If lFirst
							If SC5->(dbSeek(xFilial("SC5") + SC6->C6_NUM))
								If !Empty(cFieldMsg) .And. SC5->(FieldPos(cFieldMsg)) > 0 .And. !Empty(&("SC5->"+cFieldMsg))
									cServ  := cServ + AllTrim(&("SC5->"+cFieldMsg))
								Else
									cServ  := cServ + AllTrim(SC5->C5_MENNOTA)
								EndIf
								cNroInsObr := SC5->C5_OBRA
								lFirst := .F.
							Endif
						EndIf
					Else
						cNumPed := SC6->C6_NUM
						cServ   := cServ + ", "
						lFirst  := .T.
					EndIf

					SC6->(DbSkip())

				Enddo

			Endif

			cServ := cServ+" | "+AllTrim(SubStr(X5Descri(),1,55))

		Endif

		If Empty(cServ)
			cServ := cDescrServ
		Endif

		//Lei Transpar�ncia
		If !Empty(cTotImp) .And. !lPaulista
			cServ+= +CHR(13)+CHR(10)+cTotImp+cFontImp
		EndIf

		//��������������������������������������������������������������Ŀ
		//�Ponto de entrada para verificar se esse RPS deve ser impresso �
		//����������������������������������������������������������������
		aAreaRPS := SF3->(GetArea())
		lImpRPS	 := .T.
		If lPEImpRPS
			lImpRPS := Execblock("MTIMPRPS",.F.,.F.,{SF3->F3_NFISCAL,SF3->F3_SERIE,SF3->F3_CLIEFOR,SF3->F3_LOJA}) 
		Endif
		RestArea(aAreaRPS)

		If !lImpRPS
			SF3->(dbSKip())
			If nOpcao == 4  //automatico
				cChave := xFilial("SF3") + SF3->F3_CLIEFOR + SF3->F3_LOJA + SF3->F3_NFISCAL + SF3->F3_SERIE
			Else //manual
				cChave := ""
			Endif
			Loop
		EndIf

		//����������������������������������������������������������Ŀ
		//�Ponto de entrada para compor a descricao a ser apresentada�
		//������������������������������������������������������������
		aAreaRPS	:= SF3->(GetArea())
		cServPonto	:= ""
		If lDescrNFE
			cServPonto := Execblock("MTDESCRNFE",.F.,.F.,{SF3->F3_NFISCAL,SF3->F3_SERIE,SF3->F3_CLIEFOR,SF3->F3_LOJA})
		Endif
		RestArea(aAreaRPS)
		If !(Empty(cServPonto))
			cServ := cServPonto
		else
			cServ := NfeQuebra(cServ)
		Endif

		//����������������������������������������������������������������������Ŀ
		//�Ponto de entrada para complementar as observacoes a serem apresentadas�
		//������������������������������������������������������������������������
		If lCarioca
			cObsRio := "'Obrigat�ria a convers�o em Nota Fiscal de Servi�os Eletr�nica � NFS-e � NOTA CARIOCA em at� vinte dias.'" + " | "
			nDesIncond := 0
			SF2->(dbSetOrder(1))
			SD2->(dbSetOrder(3))
			If SF2->(dbSeek(xFilial("SF2")+SF3->F3_NFISCAL+SF3->F3_SERIE))
				If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
					SF4->(DbSetOrder(1))
					If SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
						If SF2->F2_DESCONT > 0
							If SF4->F4_DESCOND == "1"
								cObsRio += " Deconto Condic. de (R$) "
								cObsRio += Alltrim(Transform(SF2->F2_DESCONT,"@ze 9,999,999,999,999.99"))
							Else
								nDesIncond := SF2->F2_DESCONT
							EndIf
						EndIf
					EndIf
				Endif
			Endif
		Endif

		cObserv  := Alltrim(SF3->F3_OBSERV) + Iif(!Empty(SF3->F3_OBSERV)," | ","") 
		cObserv  += Iif(!Empty(SF3->F3_PDV) .And. Alltrim(SF3->F3_ESPECIE) == "CF",STR0083 + " | ","")
		aAreaRPS := SF3->(GetArea())
		cObsPonto:= ""
		If lObsNFE
			cObsPonto := Execblock("MTOBSNFE",.F.,.F.,{SF3->F3_NFISCAL,SF3->F3_SERIE,SF3->F3_CLIEFOR,SF3->F3_LOJA}) 
		Endif
		RestArea(aAreaRPS)
		cObserv  := cObserv + cObsPonto
		cObserv  := cObserv + cObsRio
		cObserv  := NfeQuebra(cObserv)

		If (cWord >= "0")
			//���������������������������������������������������Ŀ
			//�Informacoes sobre a empresa que esta emitindo o RPS�
			//�����������������������������������������������������
			OLE_SetDocumentVar(cWord, "c_Empresa"	, SM0->M0_NOMECOM )
			OLE_SetDocumentVar(cWord, "c_EndEmp"	, SM0->M0_ENDENT  )
			OLE_SetDocumentVar(cWord, "c_BairrEmp"	, SM0->M0_BAIRENT )
			OLE_SetDocumentVar(cWord, "c_CidEmp"	, SM0->M0_CIDENT  )
			OLE_SetDocumentVar(cWord, "c_UFEmp"		, SM0->M0_ESTENT  )
			OLE_SetDocumentVar(cWord, "c_CepEmp"	, SM0->M0_CEPENT  )
			OLE_SetDocumentVar(cWord, "c_TelEmp"	, SM0->M0_TEL     )
			OLE_SetDocumentVar(cWord, "c_CNPJEmp"	, Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"))
			OLE_SetDocumentVar(cWord, "c_IEEmp"		, SM0->M0_INSCM   )
			//����������������������������������Ŀ
			//�Informacoes sobre a emissao do RPS�
			//������������������������������������
			OLE_SetDocumentVar(cWord, "c_NumRps"	, Alltrim(SF3->F3_NFISCAL) + Iif(!Empty(SerieNfId("SF3",2,"F3_SERIE"))," / " + Alltrim(SerieNfId("SF3",2,"F3_SERIE")),"") )
			OLE_SetDocumentVar(cWord, "d_EmiRPS"	, SF3->F3_ENTRADA )
			OLE_SetDocumentVar(cWord, "c_HorRPS"	, Transform(cTime,"@R 99:99" ))
			//����������������������������������������Ŀ
			//�Informacoes sobre o cliente do movimento�
			//������������������������������������������
			OLE_SetDocumentVar(cWord, "c_Cli"		, cCli            )
			OLE_SetDocumentVar(cWord, "c_CNPJCli"	, cCNPJCli        )
			OLE_SetDocumentVar(cWord, "c_IMCli"		, cIMCli          )
			OLE_SetDocumentVar(cWord, "c_EndCli"	, cEndCli         )
			OLE_SetDocumentVar(cWord, "c_BairrCli"	, cBairrCli       )
			OLE_SetDocumentVar(cWord, "c_CepCli"	, cCepCli         )
			OLE_SetDocumentVar(cWord, "c_MunCli"	, cMunCli         )
			OLE_SetDocumentVar(cWord, "c_UFCli"		, cUFCli          )
			OLE_SetDocumentVar(cWord, "c_EmailCli"	, cEmailCli       )
			//�����������������������������������������Ŀ
			//�Intermediario de Servi�o                 �
			//�������������������������������������������
			OLE_SetDocumentVar(cWord, "c_CNPJInt", cCNPJInt)
			OLE_SetDocumentVar(cWord, "c_NomInt", cNomInt)
			//�����������������������������������������Ŀ
			//�Informacoes sobre impostos               �
			//�������������������������������������������
			OLE_SetDocumentVar(cWord, "n_ValINSS"	, Transform(nValINSS,"@E 999,999,999.99") )
			OLE_SetDocumentVar(cWord, "n_ValIRPJ"	, Transform(nValIRPJ,"@E 999,999,999.99") )
			OLE_SetDocumentVar(cWord, "n_ValCSLL"	, Transform(nValCSLL,"@E 999,999,999.99") )
			OLE_SetDocumentVar(cWord, "n_ValCOF"	, Transform(nValCOF,"@E 999,999,999.99")  )
			OLE_SetDocumentVar(cWord, "n_ValPIS"	, Transform(nValPIS,"@E 999,999,999.99")  )
			//�����������������������������������������Ŀ
			//�Informacoes sobre a prestacao de servicos�
			//�������������������������������������������
			If lRecife
				OLE_SetDocumentVar(cWord, "c_CodAtiv"	, cCodAtiv        )
			EndIf
			If lCarioca
				OLE_SetDocumentVar(cWord, "n_DescIncond"	, Transform(nDesIncond,"@E 999,999,999.99") )
			EndIf
			If lPaulista
				cMunPreSer := UfCodIBGE(cUFCli)+cCodMun
			EndIf
			OLE_SetDocumentVar(cWord, "c_CodServ"	, cCodServ)
			OLE_SetDocumentVar(cWord, "c_DescrServ"	, cDescrServ)
			OLE_SetDocumentVar(cWord, "c_Serv"		, cServ)
			OLE_SetDocumentVar(cWord, "n_ValServ"	, AllTrim(Transform(nValServ,"@E 999,999,999.99")))
			OLE_SetDocumentVar(cWord, "n_ValDed"	, Transform(nValDed,"@E 999,999,999.99"))
			OLE_SetDocumentVar(cWord, "n_ValBase"	, Transform(nValBase,"@E 999,999,999.99"))
			OLE_SetDocumentVar(cWord, "n_Aliquota"	, Transform(nAliquota,"@E 999.99"))
			OLE_SetDocumentVar(cWord, "n_ValISS"	, Transform(nValISS,"@E 999,999,999.99"))
			OLE_SetDocumentVar(cWord, "n_ValCre"	, Transform(nValCre,"@E 999,999,999.99"))

			OLE_SetDocumentVar(cWord, "c_MunPreSer"	, cMunPreSer)
			OLE_SetDocumentVar(cWord, "c_NroInsObr"	, cNroInsObr)
			OLE_SetDocumentVar(cWord, "c_VlrAprTri"	, cLeiTransp)

			//������������������������������������������Ŀ
			//�Informacoes sobre a Nota Fiscal Eletronica�
			//��������������������������������������������
			If !Empty(SF3->F3_NFELETR)
				OLE_SetDocumentVar(cWord, "c_NumNfe"	, StrZero(Year(SF3->F3_EMISSAO),4)+"/"+SF3->F3_NFELETR)	
				OLE_SetDocumentVar(cWord, "d_EmiNfe"	, SF3->F3_EMINFE  )
				OLE_SetDocumentVar(cWord, "c_CodNfe"	, SF3->F3_CODNFE  )
				OLE_SetDocumentVar(cWord, "n_ValCred"	, Transform(SF3->F3_CREDNFE,"@E 999,999,999.99") )
			Else
				OLE_SetDocumentVar(cWord, "c_NumNfe"	, Space(TamSX3("F3_NFELETR")[1]) )
				OLE_SetDocumentVar(cWord, "d_EmiNfe"	, Space(TamSX3("F3_EMINFE")[1]) )
				OLE_SetDocumentVar(cWord, "c_CodNfe"	, Space(TamSX3("F3_CODNFE")[1]) )
				OLE_SetDocumentVar(cWord, "n_ValCred"	, Space(TamSX3("F3_CREDNFE")[1]) )
			Endif

			//������������������Ŀ
			//�Outras Informacoes�
			//��������������������
			OLE_SetDocumentVar(cWord, "c_Obs"			, cObserv )

			//�����������������������������������������������������������������������������������Ŀ
			//�Funcao que atualiza os campos da memoria para o Documento, utilizada logo apos a   �
			//�funcao OLE_SetDocumentVar().														  �
			//�������������������������������������������������������������������������������������
			OLE_UpdateFields(cWord)

			//�������������������������������������������Ŀ
			//�Verifica se imprime ou salva os RPS gerados�
			//���������������������������������������������
			If nOpcao == 4 //automatico

				If mv_par07 == 1   //imprimir
						OLE_PrintFile(cWord,"ALL",,,)
				else //gravar no diretorio parametrizado no wizard

					cArqRPS := StrZero(Val(SF3->F3_NFISCAL),(TamSX3("F3_NFISCAL")[1])) + "_" + AllTrim(SF3->F3_SERIE) + ".DOC"
					OLE_SaveAsFile(cWord,AllTrim(mv_par08) + cArqRPS)

					//������������������������������������������������������������������������������������������Ŀ
					//�Ponto de entrada para gravar os RPS gerados pela rotina em outro local (exemplo: servidor)�
					//��������������������������������������������������������������������������������������������
					If lGravaNFE
						ExecBlock("MTGRAVNFE",.F.,.F.,{Alltrim(mv_par08),Alltrim(cArqRPS)})     
					Endif

				Endif

			EndIf

		Endif

	Endif

	SF3->(DbSkip())
	If nOpcao == 4
		cChave := xFilial("SF3") + SF3->F3_CLIEFOR + SF3->F3_LOJA + SF3->F3_NFISCAL + SF3->F3_SERIE
	Else
		cChave := ""
	Endif
Enddo
Return(.T.)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �NfeQuebra � Autor � Mary C. Hergert       � Data �15/08/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Efetua a quebra de acordo com os caracteres totais a serem  ���
���          �impressos em determinado campo.                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Mata916                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function NfeQuebra(cString)

cString := SubStr(cString,1,999)
cString := StrTran(cString," | ","|")
cString := StrTran(cString,"|",chr(13))

Return cString

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data �01/09/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MenuDef()
     
Private aRotina := {	{ STR0014, "PesqBrw"		, 0 , 1 , 0 , .F.},;	    //"Pesquisar"
							{ STR0015, "AxVisual" 	, 0 , 2 , 0 , NIL},;		//"Visualizar"
							{ STR0016, "Mta916Imp"	, 0 , 3 , 0 , NIL},;		//"Manual"
							{ STR0017, "Mta916Imp"	, 0 , 4 , 0 , NIL}}		    //"Automatica"

If ExistBlock("MT916MNU")
	ExecBlock("MT916MNU",.F.,.F.)
EndIf

Return(aRotina)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �NFePstServ� Autor � Mary C. Hergert       � Data �26/02/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna a forma/local da prestacao do servico.              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1 = local onde esta estabelecido o cliente              ���
���          �ExpC2 = estado onde o cliente esta estabelecido             ���
���          �ExpC3 = local onde a empresa esta estabelecida              ���
���          �ExpC4 = estado onde a empresa esta estabelecida             ���
���          �ExpD5 = data do cancelamento do documento                   ���
���          �ExpC6 = local de pagamento do imposto                       ���
���          �ExpN7 = valor do ISS isento / outras                        ���
�������������������������������������������������������������������������Ĵ��
���Retornos  �RetC1 = situacao do RPS, podendo ser:                       ���
���          �  T = Tributado no municipio                                ���
���          �  I = Isento ou nao tributado, executado no municipio       ���
���          �  F = Executado fora de SP                                  ���
���          �  J = Suspensao por Decisao Judicial                        ���
���          �  C = Cancelado                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Mata916                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function NFePstServ(cMunic,cEst,cMunExec,cEstExec,dDtCanc,cIssST,nIsenOutr)
Local cPrestac	:= "T"
Local lDentro 	:= .F.
Default cIssST	:= ""

//�������������������������������������������������������������������Ŀ
//�Verifica se o municipio do cliente e o mesmo da empresa prestadora.�
//���������������������������������������������������������������������
If (Alltrim(cMunic)$Alltrim(cMunExec) .And. Alltrim(cEst)==Alltrim(cEstExec)) .Or. (!(Alltrim(cMunic)$Alltrim(cMunExec) .And. Alltrim(cEst)==Alltrim(cEstExec)) .And. SB1->B1_MEPLES == "1" )
	lDentro := .T.
Endif

//���������������������������������������������������������������������������������������Ŀ
//�Verifica se o documento e cancelado. Caso seja, nao e necessario informar a tributacao.�
//�����������������������������������������������������������������������������������������
If !Empty(dDtCanc)
	Return "C" //Cancelado
Endif

//������������������������������������������������������������������������������������Ŀ
//�Caso o campo de indicacao do pagamento do imposto nao exista ou esteja em branco,   �
//�sera analisado o municipio do cliente e a tributacao do documento. (OtherWise)      �
//��������������������������������������������������������������������������������������
//	1=Dentro Municipio
//	2=Fora Municipio
//	3=Isencao
//	4=Imune
//	5=Exigibilidade Susp. Judicial
//	6=Exigibilidade Susp. Proc. Adm.

//Conforme Layout V. 002 - NFE SAO PAULO 
If cMunExec=="SAO PAULO/S�O PAULO"
	If cEst == "EX"
		If cIssST == "1"
			Return "T"
		Else
			Return "P" //Exporta��o de Servi�os
		Endif
	Endif
	Do Case
		Case cIssST == "1"
			cPrestac := "T"	//Tributado em S�o Paulo
		Case cIssST == "2"
			cPrestac := "F" //Tributado fora de S�o Paulo
		Case cIssST == "3"
			If lDentro
				cPrestac := "A" //Tributado em S�o Paulo, por�m Isento
			Else
				cPrestac := "B" //Tributado Fora de S�o Paulo, por�m Isento
			Endif
		Case cIssST == "4"
			If lDentro
				cPrestac := "M" //Tributado em S�o Paulo, por�m Imune
			Else
				cPrestac := "N" //Tributado Fora de S�o Paulo, por�m Imune
			Endif
		Case cIssST == "5"
			If lDentro
				cPrestac := "X" //Tributado em S�o Paulo, por�m Exigibilidade Suspensa
			Else
				cPrestac := "V" //Tributado Fora de S�o Paulo, por�m Exigibilidade Suspensa
			Endif
		OtherWise
			If lDentro
				cPrestac := "T"
				If nIsenOutr > 0
					cPrestac := "A"
				Endif
			Else
				cPrestac := "F"
				If nIsenOutr > 0
					cPrestac := "B"
				Endif
			Endif
	Endcase
ElseIf cMunExec$"RECIFE/RECIFE" .Or. ;
	   (cMunExec$"RESENDE/RESENDE" .AND. !Alltrim(MV_PAR03) $ "NFERJ") .Or. ;
	   cMunExec == "DUQUE DE CAXIAS"
	   
	Do Case
		Case cIssST == "1" .AND. cMunExec$"RECIFE/RECIFE"
			cPrestac := "01"	//Tributado Dentro Municipio
		Case cIssST == "3"
			cPrestac := "03"	//Opera��o Isenta
		Case cIssST == "2"
			cPrestac := "02"	//Tributado Fora Municipio
		Case cIssST == "4"
			cPrestac := "04"	//Opera��o Imune
		Case cIssST == "5"
			cPrestac := "05"	//Opera��o Suspensa por Decis�o Judicial
		Case cIssST == "6"
			cPrestac := "06"	//Exigibilidade Suspensa por Processo Administrativo
		OtherWise
			If lDentro
				cPrestac := "01"	//Tributado Dentro Municipio
			Else
				cPrestac := "02"	//Tributado Fora Municipio
			Endif
	EndCase
ElseIf cMunExec=="ARACOIABA/ARACOIABA" .Or. cMunExec=="SAO JOSE DOS CAMPOS/S�O JOS� DOS CAMPOS"
	If cEst == "EX"
		Return "4" //Exporta��o
	Endif
	Do Case
		Case cIssST $ "1#2" 
			cPrestac := "1"	//Exigivel
		Case cIssST == "3" 
			cPrestac := "3"  //Isen��o
		Case cIssST == "4"
			cPrestac := "5"  //Imunidade
		Case cIssST == "5"
			 cPrestac := "6" 	//Exigibilidade Suspensa por Decis�o Judicial
		Case cIssST == "6"
			 cPrestac := "7"	//Exigibilidade Suspensa por Processo Administrativo		
		OtherWise
			 cPrestac := "2"  //N�o Incidencia
	Endcase
Else
	Do Case
		Case cIssST == "2"
			cPrestac := "F"
		Case cIssST == "5"
			cPrestac := "J"
		Case cIssST == "1"
			If nIsenOutr > 0
				cPrestac := "I"
			Endif
		OtherWise
			If lDentro
				If nIsenOutr > 0
					cPrestac := "I"
				Endif
			Else 
				cPrestac := "F"
			Endif
	Endcase
Endif
Return cPrestac
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATA916   �Autor  �Mary C. Hergert     � Data �  01/04/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a quantidade de servicos de um registro na tabela   ���
���          �SF3                                                         ���
�������������������������������������������������������������������������͹��
���Uso       �SigaFis                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function NfQtdServ(cFilF3,cNF,cSerie,cCliFor,cLoja,nAliq,cCodISS,lSFT)

Local cChave 	:= cFilF3+"S"+cSerie+cNF+cCliFor+cLoja
Local nQtde		:= 0
Local aAreaSFT	:= {}

aAreaSFT := SFT->(GetArea())

If lSFT
	SFT->(dbSetOrder(1))
	SFT->(dbSeek(xFilial("SFT")+"S"+cSerie+cNF+cCliFor+cLoja))
	Do While cChave == (xFilial("SFT")+"S"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA) .And. !(SFT->(Eof()))
		If SFT->FT_ALIQICM == nAliq .And. SFT->FT_CODISS == cCodISS
			nQtde += SFT->FT_QUANT
		Endif
		SFT->(dbSkip())
	Enddo
Else
	nQtde := 1
Endif

RestArea(aAreaSFT)

Return (nQtde)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATA916   �Autor  �Marcelo Alexandre   � Data �  13/04/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o codigo do imposto e o valor                       ���
���          �Impostsos: IRRF, PIS, COFINS e CSLL retencao.               ���
�������������������������������������������������������������������������͹��
���Uso       �SigaFis                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function RetImpost(cFilF3,cNF,cSerie,cCliFor,cLoja,nValTot,lLimpa,cIdentFT)

Local nX      := 0
Local cNFE	  := ""
Local aCampos := {}
Local aArqRet := {}
Local aIndice := {}
Local nValPis := 0
Local nValCsl := 0
Local nValCof := 0
Local nValIrf := 0
Local aVn     := {}
Local cParcela  := " "
Local cChaveSE1 := " "
Local cPrefixo := Padr(cSerie , TamSx3("E1_SERIE")[1])
Local cRetencao := SuperGetMv("MV_BR10925")
Local lMV_NFSEPCC := SuperGetMv("MV_NFSEPCC", .F., .F.)
Local lMV_NFSEIR := SuperGetMv("MV_NFSEIR", .F., .F.)
Local nValPisNF := 0
Local nValCslNF := 0
Local nValCofNF := 0
Local nValIrfNF := 0
Local cChaveSFT := ""
Local aAreaSFT := SFT->(getArea())

Default lLimpa := .F.
Default nValTot:= 0
Default cIdentFT := ""

If lLimpa
	aArqRet := {}
EndIf

AADD(aCampos,{"TIPOIMP","C",002,0})
AADD(aCampos,{"VALIMP" ,"N",015,2})

cNFE :=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cNFE,"NFE")
IndRegua("NFE",cNFE,"TIPOIMP")
DbClearIndex()

//������������������������������������������������Ŀ
//�Ponto de entrada para utilizar indice de usuario�
//��������������������������������������������������
If ExistBlock("MT916IND")
	aIndice := ExecBlock("MT916IND", .F., .F.,{SF3->F3_NFISCAL,SF3->F3_SERIE,SF3->F3_CLIEFOR,SF3->F3_LOJA})
Else
	AADD(aIndice,2)
	AADD(aIndice,(xFilial("SE1")+cCliFor+cLoja+cPrefixo+cNF))
EndIf

DbSelectArea ("SE1")
SE1->(dbSetOrder(aIndice[1]))
SE1->(dbSeek(aIndice[2]))

DbSelectArea("SFT")
SFT->(dbSetOrder(3))
SFT->(dbGoTop())

If ExistBlock("MT916IND")
	SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"V",SE1->E1_BAIXA,,@nValIrf,@nValCsl,@nValPis,@nValCof,@nValINSS)
Else
	//���������������������Ŀ
	//�Titulos Parcelados   �
	//�����������������������
	cChaveSE1 := xFilial("SE1")+cCliFor+cLoja+cPrefixo+cNF
	While SE1->(!Eof()) .And. cChaveSE1 == xFilial("SE1")+cCliFor+cLoja+cPrefixo+cNF
		If Alltrim(cRetencao) == '1' //Reten��o na Baixa do Titulo
			If SE1->E1_TIPO = 'IR-'
				nValIrf += SE1->E1_VALOR
			ElseIf SE1->E1_TIPO = 'COF'
				nValCof += SE1->E1_VALOR
			ElseIf SE1->E1_TIPO = 'CSL'
				nValCsl += SE1->E1_VALOR
			ElseIf SE1->E1_TIPO = 'PIS'
				nValPis += SE1->E1_VALOR
			EndIF
		Else
			If AT("-",SE1->E1_TIPO)==0
				SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"V",SE1->E1_BAIXA,,@nValIrf,@nValCsl,@nValPis,@nValCof,0)//,@nValINSS)
			EndIf
		EndIf
		cParcela :=SE1->E1_PARCELA
		cChaveSE1 := xFilial("SE1")+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM
		SE1->(dbSkip())
	EndDo
	
	//���������������������Ŀ
	//�Dados da NF          �
	//�����������������������
	If (!Empty(cIdentFT) .And. (lMV_NFSEPCC .Or. lMV_NFSEIR))
		
		cChaveSFT := xFilial("SFT")+"S"+cCliFor+cLoja+cSerie+cNF+cIdentFT
		 
		If SFT->(MsSeek(cChaveSFT))
		
			While SFT->(!Eof()) .And. xFilial("SFT")+"S"+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_IDENTF3 == cChaveSFT
			
				If Empty(SFT->FT_DTCANC)
					nValIrfNF += SFT->FT_VALIRR
					nValPisNF += SFT->FT_VRETPIS
					nValCofNF += SFT->FT_VRETCOF
					nValCslNF += SFT->FT_VRETCSL
				EndIf
				
				SFT->(dbSkip())
				
			EndDo
		
		EndIf
		
		// Substituo os valores obtidos da SE1 pelos valores da NF.
		
		If lMV_NFSEIR
			nValIrf := nValIrfNF 	
		EndIf
		
		If lMV_NFSEPCC
			nValPis := nValPisNF 
			nValCof := nValCofNF
			nValCsl := nValCslNF
		EndIf
		
	EndIf
	
Endif

RestArea(aAreaSFT)	

If nValIrf > 0
	aadd(aArqRet,{nValIrf,"01"})
EndIf
If nValPis > 0
	aadd(aArqRet,{nValPis,"02"})
EndIf
If nValCof > 0
	aadd(aArqRet,{nValCof,"03"})
EndIf
If nValCsl > 0
	aadd(aArqRet,{nValCsl,"04"})
EndIf

aVn := RetNotConj(cNF, cSerie, cCliFor, cLoja, "S")

If Len(aVn)>0
	For nX :=1 to Len (aVn)
		aadd(aArqRet,{aVn[nX][2],"VN"})
	Next nX
EndIf

nValTot := nValIrf+nValPis+nValCof+nValCsl

If len(aArqRet)>0
	For nX :=1 to Len(aArqRet)
		RECLOCK("NFE",.T.)
		NFE->TIPOIMP := aArqRet[nX][2]
		NFE->VALIMP  := aArqRet[nX][1]
		MsUnlock()
	Next nX
EndIf

Return(cNFE)
