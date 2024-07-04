#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM090.CH"
/*
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������Ŀ��
���Fun��o	 � GPEM090	� Autor    � Recursos Humanos        � Data � 09/12/09      ���
�����������������������������������������������������������������������������������Ĵ��
���Descri��o �      Gera arquivo magnetico de seguro desemprego                     ���
�����������������������������������������������������������������������������������Ĵ��
���	   		    ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.	  	 	        ���
�����������������������������������������������������������������������������������Ĵ��
���Programador � Data	� FNC            �  Motivo da Alteracao                     ���
�����������������������������������������������������������������������������������Ĵ��
���Carlos E. O.�22/01/14�M12RH01 197403  �Inclusao do fonte na P12.   				���
���            �        �                �Criacao da funcao SegDesTpr().            ���
���            �24/01/14�M12RH01 197404  �Retiradas funcoes de ajuste de dicionario.���
���            �        �                �Substituicao da chamada da funcao         ���
���            �        �                �fPHist82() por SegDesTpr().               ���
���            �        �                �Alterada checagem de MV_FOLMES pela funcao���
���            �        �                �fGetPerAtual().                           ���
���            �        �                �Alteracoes no retorno da funcao REG_TIPO01���
���Renan Borges�18/08/14|TQEVKU  		 |Ajuste para gerar o arquivo de requerimen-���
���            �        |        		 |to do seguro desemprego via web com as in-���
���            �        |        		 |forma��es de DDD e telefone e para gerar  ���
���            �        |        		 |o arquivo com o nome fiel ao que � passado���
���            �        |        		 |nos parametros do relat�rio.              ���
���M. Silveira �28/10/14|TQUCWD  		 |Retirado o retorno da linha no Trailler   ���
���            �        |        		 |porque estava gerando erro no validador.  ���
���Henrique V. �19/01/15|TRIXGR  		 |Corrido o fonte, inclu�do tratamento para ���
���            �        |        		 |campo DDD e TELEFONE, para que o arquivo  ���
���            �        |        		 |seja validado corretamenteo pelo Validador���
���            �        |        		 |do MTE, ajustado tamb�m campo Carteira Pro���
���            �        |        		 |fissional para que seja escrito com o     ���
���            �        |        		 |tamanho correto. Criado sess�o de Log para���
���            �        |        		 |avisar sobre inconsist�ncias nos campos   ���
���            �        |        		 |DDD e TELEFONE                            ���
���Renan Borges�06/05/15|TSCXL7  		 |Ajuste para gerar o arquivo de requerimen-���
���            �        |        		 |to do seguro desemprego via web quando fun���
���            �        |        		 |cion�rio foi demitido em m�s posterior ao ���
���            �        |        		 |m�s da folha aberta.                      ���
���Raquel Hager�29/06/15|TSLRV0          |Criacao de ponto de entrada GPM090VERB.   ���
���Gustavo M   �13/07/15|TSVZUT          |Ajuste na gera��o dos salarios.			���
���Allyson M   �29/10/15|TTKIIZ    		 |Ajuste para demonstrar na sele��o dos Fun-���
���            �        |        		 |cionarios,o Codigo da Rescis�o e descri��o���
���            �        |        		 |(Replica Trombini).                       ���
���Claudinei S.�17/12/15|TU2248  		 |Ajuste na REG_TIPO01() para considerar    ���
���            �        |        		 |corretamente o numero do logradouro.      ���
���Marcia Moura�17/02/16|TUMRFM 		 |Alterar a grava��o do camp Telefone para  ���
���            �        |        		 |9 digitos                                 ���
���Flavio Corr �26/02/16|TUGXKC 		 |Permitir gerar seguro para demissao futura���
���C�cero Alves�28/04/17|DRHPAG-242      |Usar FWTemporaryTable para a cria��o de   ���
���            �        |		   	     |tabelas tempor�rias					    ���
������������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
*/
Function GPEM090()

Local oDlg
Local nOpca 	:=	0
Local aSays 	:=	{}
Local aButtons	:= 	{} //<== arrays locais de preferencia
Local aFilterExp:=	{} //Expressao de filtro

Local oAltera
Local cAltera
Local nOpcao		:= 0
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Local aFldRel		:= {"RA_CIC","RA_PIS","RA_NOMECMP","RA_NOME","RA_NATURAL","RA_DDDFONE","RA_TELEFON","RA_GRINRAI","RA_COMPLEM",;
						"RA_ENDEREC","RA_NUMENDE","RA_CEP","RA_ESTADO","RA_MAE","RA_NUMCP","RA_SERCP","RA_UFCP","RA_SEXO"}
Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )

Private aRetFiltro
Private cSraFilter
Private cSrgFilter
Private nTamCC		:= TamSX3("RA_CC     ")[1]
private oTmpTable	:= Nil
Private lInformix	:= (TcGetDb()=="INFORMIX")

Private lAbortPrint	:= .F.
Private cCadastro	:= OemtoAnsi(STR0001)		//"Requerimento de seguro desemprego"

	If lBlqAcesso	//Tratamento de acesso a dados pessoais
		Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)	//"Dados Protegidos- Acesso Restrito: Este usu�rio n�o possui permiss�o de acesso aos dados dessa rotina. Saiba mais em {link documenta��o centralizadora}"
	Else
		Pergunte("GPM090",.F.)

		/* Retorne os Filtros que contenham os Alias Abaixo */
		aAdd( aFilterExp , { "FILTRO_ALS" , "SRA"     	, .T. , ".or." } )
		aAdd( aFilterExp , { "FILTRO_ALS" , "SRG"     	, NIL , NIL    } )
		/* Que Estejam Definidos para a Fun��o */
		aAdd( aFilterExp , { "FILTRO_PRG" , FunName() 	, NIL , NIL    } )

		AADD(aSays,STR0002 )//"Este programa gera arquivo de Requerimento de Seguro Desemprego
		AADD(aSays,STR0003)	//"via WEB"

		AADD(aButtons, { 17,.T.,{|| aRetFiltro := FilterBuildExpr( aFilterExp ) } } )
		AADD(aButtons, { 5,.T.,{|| Pergunte("GPM090",.T. ) } } )
		AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(gpm090OK(),FechaBatch(),nOpca:=0) }} )
		AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

		FormBatch( cCadastro, aSays, aButtons )

		If nOpca == 1
			ProcGpe({|lEnd| GPM090Processa()},,,.T.)	// Chamada do Processamento
		EndIf
	EndIf
Return Nil

/*
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Fun��o    � SegDesTpr     � Autor � Carlos E. Olivieri � Data � 22/01/2014   ���
�������������������������������������������������������������������������������Ĵ��
���Descri��o � Carrega o array aTab com conteudo da tabela S043 (Tipos Rescisao)���
�������������������������������������������������������������������������������Ĵ��
���Sintaxe   � SegDesTpr(@<array>)                                              ���
�������������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                         ���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/
Function SegDesTpr(aTab)

	fCarrTab(@aTab,"S043")	//Tabela de tipos de rescisao

Return !Empty(aTab)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GPM090Processa� Autor � Andreia Santos   � Data � 10/12/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de processamento                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPM090Processa()                                           ���
�������������������������������������������������������������������������Ĵ��
���Uso       � GPEM090                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function GPM090Processa()

Local aArea			:= getArea()
Local nPos 			:= 0
Local aCampos		:={}

Private cFile
Private nHandle
Private cRecol		:= ""
Private dAuxPar01
Private cCGC		:= Space(15)
Private nTotal		:= 0
Private cVerbas		:= ""
Private oTempTable	:= Nil

//Campos para sele��o dos funcionarios.
AADD(aCampos,{"TSGD_FLAG" ,"C",2,0})
AADD(aCampos,{"TSGD_FIL"  ,"C",TAMSX3("RA_FILIAL")[1],TAMSX3("RA_FILIAL")[2]} )
AADD(aCampos,{"TSGD_MAT"  ,"C",TAMSX3("RA_MAT")[1]   ,TAMSX3("RA_MAT")[2]} )
AADD(aCampos,{"TSGD_NOME" ,"C",TAMSX3("RA_NOME")[1]   ,TAMSX3("RA_NOME")[2]} )
AADD(aCampos,{"TSGD_TIPO" ,"C",3 ,0 } )
AADD(aCampos,{"TSGD_DESC" ,"C",30 ,0 } )
AADD(aCampos,{"TSGD_RSRA" ,"N",10 ,0 } )
AADD(aCampos,{"TSGD_RSRG" ,"N",10 ,0 } )

oTempTable := FWTemporaryTable():New("TSEGDES")
oTempTable:SetFields( aCampos )
oTempTable:AddIndex( "IND1", {"TSGD_FIL", "TSGD_MAT"} )
oTempTable:Create()

DbSelectarea("TSEGDES")

//--Paramentros Selecionados
dAuxPar01	:= mv_par01				 	// Data base
cFile		:= mv_par02 				//  Arquivo Destino
cFilDe		:= mv_par03					//	Filial De
cFilAte		:= mv_par04					// 	Filial Ate
cCcDe		:= mv_par05					//	Centro de Custo De
cCcAte		:= mv_par06					//	Centro de Custo Ate
cMatDe		:= mv_par07					//	Matricula De
cMatAte		:= mv_par08					//  Matricula Ate

dDemisDe	:= mv_par09					// 	Data de Demissao De
dDemisAte	:= mv_par10					// 	Data de Demissao Ate
dGeraDe		:= mv_par11					//	Data de Geracao De
dGeraAte	:= mv_par12					//	Data de Geracao Ate
dHomolDe	:= mv_par13					//	Data de homologacao De
dHomolAte	:= mv_par14					//	Data de homologacao Ate

cFilResp	:= mv_par15					//	Empresa/Filial Responsavel e Centralizadora

// Ponto de entrada para inclusao de um numero
// maior de verbas atraves da variavel cVerbas
If ExistBlock("GPM090VERB")
	ExecBlock( "GPM090VERB",.F.,.F., {cVerbas} )
EndIf

cVerbas 	+= ALLTRIM(mv_par16)
cVerbas 	+= ALLTRIM(mv_par17)

fTransVerba()

//-- O nome do arquivo tera a valida��o somente da extens�o .SD
cFile :=Upper(cFile)

If "." $ cFile
	nPos := at(".", cFile)
	if Substr(cFile, nPos, nPos + 2) <> ".SD"
		Aviso(STR0005, STR0018, {"OK"}, , STR0019)//"Atencao "##"A extens�o do nome do arquivo destino devera ser '.SD'"##"Extens�o do Nome do arquivo invalida"
		Return Nil
	Endif
else
	cFile := alltrim(cFile) + ".SD"
endif

Gp090Cria()

//--Funcao de Processamento Selecionado pelos Parametros
fProcFunc()

// Apaga arquivo tempor�rio
SEG->(dbCloseArea())
oTempTable:Delete()

RestArea(aArea)

Return Nil

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � fProcFunc     � Autor � Andreia Santos   � Data � 17/10/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de processamento por filial                         ���
�������������������������������������������������������������������������Ĵ��
���Uso       � GPEM680                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������/*/

Static Function fProcFunc()

Local aArea 	    := GetArea()
Local cFilAnterior	:= 	Replicate("!", FWGETTAMFILIAL)
Local cTipo			:=	""

Local cInfo			:= ""
Local aInfo			:= {}

Local nPosTab 		:= 0
Local cCodR			:= ""
Local aPerAtual		:= {}
Local cAnoMes		:= ""

Private aLog		:= {}
Private aTitle		:= {}
Private aTotRegs	:= array(05)
Private aCodfol		:= {}

fGetPerAtual( @aPerAtual, xFilial("RCH"), SRA->RA_PROCES, fGetRotOrdinar() )
If Empty(aPerAtual)
	fGetPerAtual( @aPerAtual, xFilial("RCH"), SRA->RA_PROCES, fGetCalcRot('9') )
EndIf


If !Empty(aPerAtual)
	cAnoMes := AnoMes(aPerAtual[1,6])
EndIf

aFill(aTotRegs,0)

dbSelectArea("SRA")
dbSeek( cFilDe , .T. )

If SRA->RA_FILIAL > cFilAte
	Help(" ",1,"GPM600SFIL")
	RestArea( aArea )
	Return Nil
EndIf

GPProcRegua(SRA->(RecCount()))

If len( cCCDe)# nTamCC
	cCCde := alltrim( cCCDe )+ space(nTamCC-len(alltrim( cCCDe )))
EndIf

If len( cCCAte)# nTamCC
	cCCAte := alltrim( cCCAte )+ space(nTamCC-len(alltrim( cCCAte )))
EndIf

//��������������������������������������������������������������Ŀ
//� Carrega os Filtros                                 	 	     �
//����������������������������������������������������������������
cSraFilter	:= GpFltAlsGet( aRetFiltro , "SRA" )
cSrgFilter	:= GpFltAlsGet( aRetFiltro , "SRG" )

While SRA->(!Eof()) .And. SRA->RA_FILIAL <= cFilAte

	If cFilAnterior # SRA->RA_FILIAL

		If !fInfo(@aInfo,SRA->RA_FILIAL) .or. !( Fp_CodFol(@aCodFol,SRA->RA_FILIAL) )
			Exit
		EndIf

		If aInfo[15] == 1 .Or. ( Len(aInfo) >= 27 .And. !Empty( aInfo[27] ) )// CEI
			cInfo := "2"
		Else
			cInfo := "1"			// CGC/CNPJ
		EndIf

		cFilAnterior := SRA->RA_FILIAL

	EndIF

	//��������������������������������������������������������������Ŀ
	//� Aborta o Processamento                             	 	     �
	//����������������������������������������������������������������
	If lAbortPrint
		Exit
	Endif

	// Nao gerar conforme o parametro Funcionario De/Ate
	If SRA->RA_MAT < cMatDe .Or. SRA->RA_MAT > cMatAte
		SRA->( dbSkip())
		Loop
	EndIf

	If SRA->RA_CC < cCcDe .Or. SRA->RA_CC > cCcAte
		SRA->( dbSkip())
		Loop
	EndIf

 	If !Empty( cSraFilter )
 		If !( &( cSraFilter ) )
			SRA->( dbSkip())
			Loop
 		EndIf
 	EndIf

	GPIncProc(SRA->RA_FILIAL+" - "+SRA->RA_MAT+" - "+SRA->RA_NOME)

 	//��������������������������������������������������������������Ŀ
	//� Procura no Arquivo de Cabecalho da Rescisao "SRG"            �
	//����������������������������������������������������������������
	dbSelectArea("SRG")
	If SRG->( dbSeek( SRA->RA_FILIAL+SRA->RA_MAT ) .and. ( RG_FILIAL $ fValidFil()  ) ) //Consiste Filial


		If !(MesAno( SRG->RG_DATADEM )  > cAnoMes)
			If !( SRA->RA_RESCRAI $ "11*12" )
				SRA->( dbSkip())
				Loop
			EndIf
		Else
			nPosTab 	:= fPosTab("S043",cAnoMes,"==",2,SRG->RG_TIPORES,"==",4) // Tipo de Rescisao
			If nPosTab == 0   // Tenta sem data de referencia
			   nPosTab 	:= fPosTab("S043",SRG->RG_TIPORES,"==",4,,,) // Tipo de Rescisao
			EndIf

			If nPosTab > 0
				cCodR		:=	fTabela("S043",nPosTab,17) // Cod. Afastamento FGTS
			EndIf

			If !(cCodR $ "11*12")
				SRA->( dbSkip())
				Loop
			EndIf
		EndIf


		//��������������������������������������������������������������Ŀ
		//� Executa o filtro no cabecalho de rescisao.                   �
		//����������������������������������������������������������������
	 	If !Empty( cSrgFilter )
	 		If !( &( cSrgFilter ) )
				SRA->( dbSkip())
				Loop
	 		EndIf
	 	EndIf

		/*
		��������������������������������������������������������������Ŀ
		�Consiste Periodos do SRG                                      �
		����������������������������������������������������������������*/
		If  SRG->(;
					(RG_DATADEM < dDemisDe .or. RG_DATADEM > dDemisAte) .or.;
					(RG_DTGERAR < dGeraDe .or. RG_DTGERAR > dGeraAte) .or. ;
					(RG_DATAHOM < dHomolDe .or. RG_DATAHOM > dHomolAte) .or. ;
					RG_EFETIVA == "N"  ;
				 )

			SRA->( dbSkip())
			Loop
		Endif

		//-- Pis em branco
		If Empty(SRA->RA_PIS)
			If aTotRegs[1]== 0
				cLog := STR0014+STR0015        //"Nao Enviado(s) - "### "PIS INVALIDO"
				Aadd(aTitle,cLog)
				Aadd(aLog,{})
				aTotRegs[1] := len(aLog)
		    EndIf
			Aadd(aLog[aTotRegs[1]],SRA->RA_FILIAL+"-"+SRA->RA_MAT+" - "+SRA->RA_NOME)
			SRA->(dbSkip())
			Loop
		EndIf

		IF Empty(SRA->RA_DDDFONE) .Or. Empty(SRA->RA_TELEFON) .Or. Len(Alltrim(SRA->RA_TELEFON)) < 8
			If aTotRegs[2]== 0
				cLog := "Funcion�rio(s) Enviado(s) com Dado(s) Inconsistente(s) - N�o Impede a Opera��o"
				Aadd(aTitle,cLog)
				Aadd(aLog,{})
				aTotRegs[2] := len(aLog)
		    EndIf
		    IF Empty(SRA->RA_DDDFONE) .And. (Empty(SRA->RA_TELEFON) .Or. Len(Alltrim(SRA->RA_TELEFON)) < 8)
				Aadd(aLog[aTotRegs[2]],SRA->RA_FILIAL+"-"+SRA->RA_MAT+" - "+SRA->RA_NOME+" - "+;
					"DDD" + " / " + "Telefone")
			ElseIf Empty(SRA->RA_DDDFONE)
				Aadd(aLog[aTotRegs[2]],SRA->RA_FILIAL+"-"+SRA->RA_MAT+" - "+SRA->RA_NOME+" - "+;
					"DDD")
			Else
				Aadd(aLog[aTotRegs[2]],SRA->RA_FILIAL+"-"+SRA->RA_MAT+" - "+SRA->RA_NOME+" - "+;
					"Telefone")
			EndIf
		EndIf

		GRVMARK() //Fun��o para gravar na tabela temporaria para escolha

	Endif
	SRA->( dbSkip())
EndDo

If Len(aCodFol) == 0
    lAbortPrint:= .T.
Else
fMarkSegR() // Fun��o para a escolha dos funcionarios
EndIf

If ! lAbortPrint
	FGeraTxt()
Endif

//�������������������������������������Ŀ
//� Chama rotina de Log de Ocorrencias. �
//���������������������������������������

fMakeLog(aLog,aTitle,,,"SD"+DTOS(mv_par01),STR0016,"M","P",,.F.) //"Log de ocorrencias - Seguro Desemprego"

RestArea(aArea)
Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � REG_TIPO00� Autor � Andreia dos Santos   � Data � 09/12/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Registro das informacoes do responsavel                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � REG_TIPO00()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM090                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function REG_TIPO00()

Local c00Grava
Local aInfo		:=	{}
Local cCodigo	:=  ""
Local cInfo		:=	""

// Tipo de Inscricao
If !fInfo(@aInfo,substr(cFilResp,3,FWGETTAMFILIAL),Substr(cFilResp,1,2))
	Return .T.
EndIf

// Tipo de inscricao da Empresa
If aInfo[15] == 1 .Or. ( Len(aInfo) >= 27 .And. !Empty( aInfo[27] ) )	// CEI
	cInfo:= "2"
ElseIf aInfo[15] == 3		// CPF
	cInfo:= "3"
Else
	cInfo:= "1"				// CGC/INCRA
EndIf

cCodigo := If( Len(aInfo) >= 27 .And. !Empty( aInfo[27] ), aInfo[27], aInfo[8] )

//																			De 	Ate Tam	 Descricao
c00Grava	:= "00"														// 001	002	002	 Sempre "00"
c00Grava	+= Left(cInfo+Space(01),01)									// 003	003	001	 1- CGC/CNPJ 2-CEI
c00Grava	+= strzero(val(alltrim(cCodigo)),14)						// 004	017	014	 Inscricao
c00Grava	+= "001"													// 018	020	003	 Versao do layout
c00Grava	+= Space(280)												// 018	300	283	 Filler
c00Grava 	+= CHR(13) + CHR(10)										// Fim de linha

GravaSegDes(c00Grava,"00")

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � REG_TIPO01� Autor � Andreia dos Santos   � Data � 09/12/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Registro das informacoes da empresa                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � REG_TIPO01()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM090                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function REG_TIPO01(cAuxFil,aInfo,cInfo)

Local c01Grava		:= ""
Local cCbo	  		:= fCodCBO(SRA->RA_FILIAL,SRA->RA_CODFUNC,dAuxPar01,.T.)
Local cGrauInstr	:= fGrauInstr()
Local cIndeniz   	:= ""
Local cAnoMesAtu	:= ""
Local cCompl		:= SRA->RA_COMPLEM
Local cFil			:= ""
Local cNomeFun		:= ""

Local nVAlUlt 		:= 0
Local nValPen		:= 0
Local nValant		:= 0
Local nValUltSal	:= 0
Local nValPenSal	:= 0
Local nValAntSal	:= 0
Local nAux			:= 0
Local nX			:= 0
Local nAt			:= 0
Local nEnd			:= 0

Local dDTUltSal 	:= CToD("")	//-- Data do Ultimo Salario
Local dDTPenSal		:= CToD("") //-- Data do Penultimo Salario
Local dDTAntSal		:= CToD("") //-- Data do Antepenultimo Salario
Local cEnderec		:= SRA->RA_ENDEREC

Local aPerAtual		:= {}
Local aTab			:= {}

Local dDtBase		:= MV_PAR01

If (nAt	:= At(",",cEnderec)) >0
	nAux := 1
ElseIf (nAt	:= At("N�",cEnderec)) >0
	nAux := 2
ElseIf (nAt	:= At("N.",cEnderec)) > 0
	nAux := 2
ElseIf (nAt	:= At("N�",cEnderec)) > 0
	nAux := 2
ElseIf (nAt	:= At("N-",cEnderec)) > 0
	nAux := 2
EndIf

If nAt > 0
	nEnd	:= nAt+nAux
	cCompl  := Alltrim(Substr(cEnderec,nEnd,16 ))+" "+SRA->RA_COMPLEM
	cEnderec:= Substr(cEnderec,1,nAt-nAux)
Else
	cCompl  := Alltrim(SRA->RA_NUMENDE)+" "+SRA->RA_COMPLEM
EndIf

If cGrauInstr == "11"
	cGrauInstr := "10"

Elseif cGrauInstr == "12" .Or. cGrauInstr == "13"
	cGrauInstr := "11"

Endif

cGrauInstr := strzero( Val(cGrauInstr),2 )

//+--------------------------------------------------------------+
//� Pesquisando os Tres Ultimos Salarios ( Datas e Valores )     �
//+--------------------------------------------------------------+

nVAlUlt 	:= nValPen		:= nValant		:=0
NValUltSal	:= nValPenSal	:= nValAntSal	:=0

dAdmissao  := SRA->RA_Admissa
dDemissao  := SRG->RG_DATADEM

//-- Data do Ultimo Salario
dDTUltSal 	:= If(Month(dDemissao)-1 != 0, CtoD('01/' +StrZero(Month(dDemissao)-1,2)+'/'+Right(StrZero(Year(dDemissao),4),2)),CtoD('01/12/'+Right(StrZero(Year(dDemissao)-1,4),2)) )
If MesAno(dDTUltSal) < MesAno(dAdmissao)
	dDTUltSal	:= CTOD("  /  /  ")
 	NValUltSal	:= 0.00
Endif

//-- Data do Penultimo Salario.
dDTPenSal := If(Month(dDTUltSal)-1 != 0, CtoD('01/' +StrZero(Month(dDTUltSal)-1,2)+'/'+Right(StrZero(Year(dDTUltSal),4),2)),CtoD('01/12/'+Right(StrZero(Year(dDTUltSal)-1,4),2)) )
If MesAno(dDtPenSal) < MesAno(dAdmissao)
	dDTPenSal 	:= CTOD("  /  /  ")
 	nValPenSal 	:= 0.00
Endif

//-- Data do Antepenultimo Salario.
dDTAntSal := If(Month(dDtPenSal)-1 != 0,CtoD('01/'+StrZero(Month(dDtPenSal)-1,2)+'/'+Right(StrZero(Year(dDtPenSal),4),2)),CtoD('01/12/'+Right(StrZero(Year(dDtPenSal)-1,4),2)) )
If MesAno(dDtAntSal) < MesAno(dAdmissao)
	dDTAntSal 	:= CTOD("  /  /  ")
	nValAntSal 	:= 0.00
Endif

/*
�����������������������������������������������������������������������Ŀ
�Busca Salario ( + verba incorporada)do Movto Acumulado                 �
�Somar verbas informadas nos parametros                                 �
�������������������������������������������������������������������������
*/
cFil		:= xFilial('RCH', SRA->RA_FILIAL)
cVerbas		:= strTran(cVerbas, acodfol[54,1]+"/", "") //Desconsiderar verba com id de falta para n�o incorporar ao sal�rio 
//--Ultimo
If !Empty(dDTUltSal)
	dDtBase1 := dDataBase
	dDataBase := dDtBase
	nValUltSal := fBuscaAcm(cVerbas + acodfol[318,1]  ,,dDTUltSal,dDTUltSal,"V")	//-- Salario do mes + verbas que incorporaram  ao salario
	dDataBase := dDtBase1
	//--Pesquisa no movimento mensal quando o mes corrente estiver aberto
	//--e nao encontrar salario nos acumulados anuais.
	fGetPerAtual( @aPerAtual, cFil, SRA->RA_PROCES, fGetRotOrdinar() )

	If Len(aPerAtual) > 0
		cAnoMesAtu := AnoMes(aPerAtual[1,6])
	Endif

	If nValUltSal == 0 .And. AnoMes(dDTUltSal) == cAnoMesAtu
		If SRC->(Dbseek(SRA->(RA_FILIAL+RA_MAT)))
			While !SRC->(eof()) .And. SRA->(RA_FILIAL+RA_MAT) == SRC->(RC_FILIAL+RC_MAT)
				If SRC->RC_PD $cVerbas + acodfol[318,1]
					nValUltSal += SRC->RC_VALOR
				Endif
				SRC->(dbskip())
			Enddo
		Endif
	Endif

Endif

//--  Inclusao verbas que incorporam  ao salario
fSomaSrr(StrZero(Year(dDTUltSal),4), StrZero(Month(dDTUltSal),2), cVerbas, @nValUlt)

//--Penultimo
If !Empty(dDTPenSal)
	nValPen := fBuscaAcm(cVerbas + acodfol[318,1]  ,,dDTPenSal,dDTPenSal,"V")	//-- Salario do mes + verbas que incorporaram  ao salario
Endif

//--Antepenultimo
If !Empty(dDTAntSal)
	nValAnt := fBuscaAcm(cVerbas + acodfol[318,1], NIL, dDTAntSal, dDTAntSal, "V") 	//-- Salario do mes + verbas que incorporaram  ao salario
Endif

//--Somar verbas informardas aos salarios
nValUltSal += nValUlt
nValPenSal += nValPen
nValAntSal += nValAnt

If SegDesTpr(@aTab)
	nX := aScan (aTab, {|x| x[5] == SRG->(RG_TIPORES)})
	If nX > 0 //aTab[5] = Cod. tipo rescisao
		cIndeniz := aTab[nx,8] //aTab[8] = Tipo Aviso Pre/ Trabalhado, indenizado, etc
	Endif
Else
	Help(" ",1,"SEGDESTPR")  //##Tabela Tipos de Rescisao n�o cadastrada.
	Return(.F.)
Endif

If !Empty(SRA->RA_NOMECMP) .And. Len(AllTrim(SRA->RA_NOMECMP)) <= 40
	cNomeFun 	:= SRA->RA_NOMECMP
Else
	cNomeFun 	:= SRA->RA_NOME
EndIf
//											     			De	Ate	Tam			Descricao
c01Grava := "01"										//  001	002	002			Sempre 01
c01Grava += Left(SRA->RA_CIC+space(11),11 )				//  003	013	011			CPF
c01Grava +=	Left(cNomeFun+space(40),40 )		        //	014	053	040			NOME
c01Grava +=	Left(cEnderec+space(40),40)					//	054	093	040			Logradouro
c01Grava +=	Left(cCompl+space(16),16)		   			//	094	109	016			Complemento endereco
c01Grava +=	Left(SRA->RA_CEP+space(08),08 )				//	110	117	008			CEP
c01Grava += Left(SRA->RA_ESTADO+space(02),02 )			//	118	119	002			UF
c01Grava += Strzero(Val(Left(SRA->RA_DDDFONE+space(02),02)),02,0)				//	120	121	002			DDD
c01Grava += TrataTel(AllTrim(SRA->RA_TELEFON))			//	122	130	009			TELEFONE
c01Grava += Left(SRA->RA_MAE+Space(40),40)				//	131	170	040			Nome da mae
c01Grava += AllTrim(SRA->RA_PIS)						//	171	181	011			PIS-PASEP
c01Grava += IIF((val(SRA->RA_NUMCP)) > 0, Strzero(val(SRA->RA_NUMCP), 8), Left(SRA->RA_CIC, 8))			    		//	182	189	008			Nr. CTPS
c01Grava += IIF((val(SRA->RA_NUMCP)) > 0, Left(SRA->RA_SERCP+Space(05),05), Right(SRA->RA_CIC+space(2), 5))			//	190	194	005			SerIe CTPS
c01Grava += IIF((val(SRA->RA_NUMCP)) > 0, Left(SRA->RA_UFCP+Space(02),02), Left(SRA->RA_NATURAL+Space(02),02))		//	195	196	002			UF CTPS
c01Grava +=	Left(cCBO+Space(06),06)						//	197	202	006			CBO
c01Grava +=	Transforma(SRA->RA_ADMISSA)					//	203	210 008			Data Admissao
c01Grava +=	Transforma(dDemissao)						//	211	218	008			Data Demissao
c01Grava +=	If(SRA->RA_SEXO=="M","1","2")				//	282	219	001			Sexo
c01Grava +=	cGrauInstr									//	220	221	002			Grau Instrucao
c01Grava +=	Transforma(SRA->RA_NASC)					//	222	229	008			Data Nascimento
c01Grava +=	StrZero(Int(SRA->RA_HRSEMAN),2)				//	230	231	002			Horas Trabalhadas
c01Grava +=	StrZero(nValAntSal * 100,10)				//	232	241	010			AntePenultimo salario
c01Grava +=	StrZero(nValPenSal * 100,10)				//	242	251	010			Penultimo Salario
c01Grava +=	Strzero(nValUltSal * 100,10)				//	252	261	010			Ultimo salario
c01Grava +=	"00"      									//	262	263	002			Nr. meses trabalhados
c01Grava +=	"0"											//	264	264	001			Recebeu 6 ult
c01Grava +=	If( cIndeniz == "I","1","2" )				//	265	265	001			Aviso previo indenizado
c01Grava +=	"000"										//	266	268	003			codigo Banco
c01Grava +=	"0000"										//	269	272	004			Codigo Agencia
c01Grava +=	"0"											//	273	273	001			DV Agencia
c01Grava +=	space(027)									//	274	300	027			Filler

c01Grava += CHR(13)+CHR(10)								//	Fim de linha

GravaSegDes(c01Grava,"01")

//-- Funcionario enviado
If aTotRegs[3]== 0
	cLog := "Funcionario(s) enviado(s)"
	Aadd(aTitle,cLog)
	Aadd(aLog,{})
	aTotRegs[3] := len(aLog)
EndIf
Aadd(aLog[aTotRegs[3]],SRA->RA_FILIAL+"-"+SRA->RA_MAT+" - "+SRA->RA_NOME)

nTotal++


Return .T.
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � REG_TIPO99� Autor � Andreia dos Santos   � Data � 09/12/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Registro Trailler                                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � REG_TIPO99(ExpA1,ExpC1,)                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEm090                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function REG_TIPO99(aInfo,cInfo)

Local c099Grava

//																		De  Ate	Tam		Descricao
c099Grava := "99"	 												//	001	002	002		Sempre "99"
c099Grava += StrZero(nTotal,5)                     					//	003	007	005		total de requerimentos informados
c099Grava += space(293)                                           	//	008	300	293		Filler
//c099Grava += CHR(13)+CHR(10)										//	Fim de linha (Retirado em 10/2014 por gerar erro no validador)

FWrite(nHandle,c099Grava)

Return( .T.)



/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GravaSegDes� Autor � Andreia dos Santos  � Data � 23/10/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava os dados no arquivo temporario                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GravaSegDes(ExpC1)                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Dados da string                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM090()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function GravaSegDes(cCampo,cTipo)

Local cSeek		:=	""
Local lFound
Local c00Campo	:=	""
Local c01Campo	:=	""

Local aArea 	:= GetArea()
// cTipo: 		00-Registro Header.
//        		01-Registro requerimento.
//				99-Registro Trailler.

dbSelectArea("SEG")
If cTipo $ "00"				// Tipo+Tipo Insc+Insc
	cSeek := cTipo+Substr(cCampo,3,15)
ElseIf cTipo $ "01"		// SEG_TIPO+SEG_CPF
	cSeek := cTipo+space(15)+Substr(cCampo,3,11)
EndIf

If Empty(cSeek)
	lFound := .T.
Else
	If dbSeek(cSeek)
		lFound 	:= .F.
		// Sempre grava os dados da 1a empresa gerada
		If cTipo == "00"
			If !lInformix
				c00Campo			:= SEG->SEG_TEXTO
			Else
				c00Campo			:= SEG->SEG_TEXTO + SEG->SEG_TEXTO2
			EndIf
		ElseIf cTipo $ "01"
			If !lInformix
				c01Campo			:= SEG->SEG_TEXTO
			Else
				c01Campo			:= SEG->SEG_TEXTO + SEG->SEG_TEXTO2
			EndIf
		EndIf
	Else
		lFound := .T.
	EndIf
EndIf

RecLock("SEG",lFound)
If lFound
	If cTipo == "01"
	 	SEG->SEG_TINSC 	:= Space(01)
		SEG->SEG_INSC	:= Space(14)
	Else
  		SEG->SEG_TINSC 	:= Substr(cCampo,3,1)
		SEG->SEG_INSC	:= Substr(cCampo,4,14)
	EndIf
	SEG->SEG_TIPO	:= cTipo
EndIf

If cTipo $ "01"
	SEG->SEG_CPF	:= Substr(cCampo,03,11)
	SEG->SEG_ADMISS	:= Substr(cCampo,167,4)+Substr(cCampo,165,2)+Substr(cCampo,163,2)
	SEG->SEG_EMFIMA	:= cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT
EndIf

If !lFound
	If cTipo == "00"
		If !lInformix
			SEG->SEG_TEXTO		:= c00Campo
		Else
			SEG->SEG_TEXTO		:= substr(c00Campo,1,255)
			SEG->SEG_TEXTO2		:= substr(c00Campo,256,302)
		EndIf
	ElseIf cTipo $ "01"
		If !lInformix
			SEG->SEG_TEXTO		:= c01Campo
		Else
			SEG->SEG_TEXTO		:= substr(c01Campo,1,255)
			SEG->SEG_TEXTO2		:= substr(c01Campo,256,302)
		EndIf
	EndIf
Else
	If !lInformix
		SEG->SEG_TEXTO		:= cCampo
	Else
		SEG->SEG_TEXTO		:= substr(cCampo,1,255)
		SEG->SEG_TEXTO2		:= substr(cCampo,256,302)
	EndIf
EndIf
MsUnlock()

RestArea(aArea)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Function  �GPM090Ok  �Autor  �Microsiga           � Data �  09/12/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GPM090Ok()
Return (MsgYesNo(OemToAnsi(STR0004),OemToAnsi(STR0005))) //"Confirma configura��o dos par�metros?"##"Aten��o"

/*/
����������������������������������������������������������������������������
������������������������������������������������������������������������Ŀ��
���Fun��o    � FGeraTXT     � Autor � Andreia Santos   � Data � 09/12/09 ���
������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao que gera arquivo                                   ���
������������������������������������������������������������������������Ĵ��
���Sintaxe   � FGeraTxt()                                                ���
������������������������������������������������������������������������Ĵ��
���Uso       � GPEM090                                                   ���
�������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function FGeraTxt()

Local aGetArea	:= GetArea()
Local aFile		:= {}
Local cFuncCpy	:= "CpyS2TW"
Local lHtml		:= (GetRemoteType() == 5)//SmartClient HTML
Local lLinux	:= IsSrvUnix()

// Gera arquivo
cFile	:=	Alltrim(cFile)
If lHtml
	aFile := StrTokArr( cFile, If( lLinux, "/", "\" ) )
	cFile := If( lLinux, "/", "\" ) + aFile[Len(aFile)]
EndIf
nHandle := 	FCREATE(cFile,,,.F.) //Quarto parametro define que o arquivo sera criado com o nome id�ntico ao que est� sendo passado.
If FERROR() # 0 .Or. nHandle < 0
	Help("",1,"GPM600HAND")
	FClose(nHandle)
	Return Nil
EndIf

// Grava no arquivo SEGDES o Header
REG_TIPO00()

// Arquivo com todos os tipo da GRRF
dbSelectArea("SEG")
dbGoTop()

While SEG->(!Eof())

	If !lInformix
		FWrite(nHandle,SEG->SEG_TEXTO)
	Else
		FWrite(nHandle,SEG->SEG_TEXTO+SEG->SEG_TEXTO2)
	EndIf

	SEG->( dbSkip() )
EndDo

// Registro Trailler
REG_TIPO99()

FClose(nHandle)
If lHtml
	If FindFunction("CpyS2TW")
		&cFuncCpy.(cFile, .T.)
	Else
		CpyS2T(cFile, cFile)
	EndIf
	fErase(cFile)
EndIf

RestArea(aGetArea)

dbSelectArea("SRA")
dbSetOrder(1)

Return Nil


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Transforma� Autor � Cristina Ogura       � Data � 17/09/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Transforma as datas no formato DDMMAAAA                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Transforma(ExpD1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpD1 = Data a ser convertido                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � GPEM610                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function Transforma(dData)
Return(StrZero(Day(dData),2) + StrZero(Month(dData),2) + Right(Str(Year(dData)),4))


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � FGETGRRF � Autor � J. Ricardo 			� Data � 08/02/96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Permite que o usuario decida onde sera criado o arquivo    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � GPEM610													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function FGetSegDes()
Local mvRet := Alltrim(ReadVar())
Local l1Vez := .T.

oWnd := GetWndDefault()

While .T.

	If l1Vez
	 	cFile := mv_par02
	 	l1Vez := .F.
	Else
		cFile := ""
	EndIf

	If Empty(cFile)
		cFile := cGetFile("SEGURO DESEMPREGO | SEGDES.SD", OemToAnsi(STR0017),,,,GETF_LOCALHARD+GETF_NETWORKDRIVE,,)//"Selecione Diretorio"
	EndIf

	If Empty(cFile)
		Return .F.
	EndIf

	If "." $ cFile
		nPos := at(".",cFile)
		if UPPER(Substr(cFile,nPos,nPos+2)) <> ".SD"
			Aviso(STR0005,STR0018,{"OK"},,STR0019)//"Atencao "##"A extens�o do nome do arquivo destino devera ser '.SD'"##"Extens�o do Nome do arquivo invalida"
			Return Nil
		Endif
	else
		cFile := alltrim(cFile)+".SD"
	endif
	&mvRet := Upper(cFile)
	Exit
EndDo

If oWnd != Nil
	GetdRefresh()
EndIf

Return .T.

/*/{Protheus.doc} Gp090Cria
Cria arquivo tempor�rio
@author Andreia dos Santos
@since 09/12/2009
@version 2.0
@see FWTemporaryTable: http://tdn.totvs.com/x/AwgyCw
@history 19/04/2017, C�cero Alves, Alterada a fun��o para utilizar FWTemporaryTable, criando o arquivo tempor�rio no banco de dados
/*/
Static Function Gp090Cria()

	Local aStru		:= {}
	Local aOrdem	:= {"SEG_TIPO", "SEG_TINSC", "SEG_INSC", "SEG_CPF", "SEG_ADMISS"}

	aStru	:=	{{"SEG_TIPO"	, "C", 002, 0}, ;
				 {"SEG_TINSC"	, "C", 001, 0}, ;
				 {"SEG_INSC"	, "C", 014, 0}, ;
				 {"SEG_CPF"		, "C", 011, 0}, ;
				 {"SEG_ADMISS"	, "C", 008, 0}, ;
				 {"SEG_TEXTO"	, "C", 302, 0}, ;
				 {"SEG_EMFIMA"	, "C", 010, 0} }

	If lInformix
		aStru[6,3] := 255
		Aadd(aStru,{"SEG_TEXTO2"	, "C", 47, 0 })
	EndIf

	oTmpTable := FWTemporaryTable():New("SEG")
	oTmpTable:SetFields( aStru )
	oTmpTable:AddIndex("IN1", aOrdem)
	oTmpTable:Create()

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GPEM090   �Autor  �Microsiga           � Data �  09/12/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica a filial responsavel se existe                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function FVerSM0()

Local aArea	:= 	GetArea()
Local nRegSM0	:= 	0
Local lRet	 	:= .F.

dbSelectArea("SM0")
nRegSM0 := RecNo()

If dbSeek(cFilResp)
	lRet := .T.
	cCGC := SM0->M0_CGC
EndIf

dbGoto(nRegSM0)

RestArea(aArea)
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GPEM090   �Autor  �Microsiga           � Data �  12/11/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function  fTransVerba()
Local cPD	:= ""
Local nX	:= 0

For nX := 1 to Len(cVerbas) step 3
	cPD += Subs(cVerbas,nX,3)
	cPD += "/"
Next nX

cVerbas:= cPD

Return( )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GPEM090   �Autor  �Microsiga           � Data �  12/18/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � acumula as verbas da rescis�o para compor o ultimo salariov���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
static Function fSomaSrr(cAno, cMes, cVerbas, nValor)

Local lRet    := .T.
Local cPesq   := ''
Local cFilSRR := If(Empty(xFilial('SRR')),xFilial('SRR'),SRA->RA_FILIAL)
Local dDtGerar:= ctod('  /  /  ')

//-- Reinicializa Variaveis
cAno    := If(Empty(cAno),StrZero(Year(dDTUltSal),4),cAno)
cMes    := If(Empty(cMes),StrZero(Month(dDTUltSal),2),cMes)
cVerbas := If(Empty(cVerbas),'',AllTrim(cVerbas))
nValor  := If(Empty(nValor).Or.ValType(nValor)#'N',0,nValor)

Begin Sequence

	If Empty(cVerbas) .Or. Len(cVerbas) < 3 .Or. ;
		!SRR->(dbSeek((cPesq := cFilSRR + SRA->RA_MAT +'R'+ cAno + cMes), .T.))
		lRet := .F.
		Break
	EndIf


	dbSelectarea('SRG')
	If SRG->( dbSeek(SRA->RA_FILIAL+SRA->RA_MAT,.F.) )
		dDtGerar := SRG->RG_DTGERAR
		dbSelectArea("SRR")
		SRR->( dbSeek(SRA->RA_FILIAL+SRA->RA_MAT,.F.))
		While SRR->( !EOF() ) .And. SRR->RR_FILIAL+SRR->RR_MAT == SRA->RA_FILIAL+SRA->RA_MAT
			If dDtGerar == SRR->RR_DATA
				If SRR->RR_PD $ cVerbas
					If PosSrv(SRR->RR_PD,SRR->RR_FILIAL,"RV_TIPOCOD") $ "1*3"
				  		nValor += SRR->RR_VALOR
					Else
						nValor -= SRR->RR_VALOR
					EndIf
				Endif
			EndIf
			SRR->(DbSkip())
		Enddo
	EndIf

	If nValor == 0
		lRet := .F.
		Break
	EndIf

End Sequence
dbSelectArea('SRA')
Return lRet

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TrataTel� Autor � Henrique Vita Velloso  � Data � 14/01/15 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Trata o n�mero do Telefone deixando somente numeros para   ���
���          � ser escrito no arquivo .SD 								  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TrataTel(cTelFone)                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEm090                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function TrataTel(cTelFone)


Local cRetTel := ""
Local nX := 1
Local cConteu := ""
Local cNum :=  "0123456789"

for nX := 1 to len(cTelFone)
	cConteu :=substr(cTelFone,nx,1)
	if cConteu  $ cNum
		cRetTel+= cConteu
	endif
Next nX
cRetTel := Strzero(VAL(cRetTel),9)

Return(cRetTel)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � fMarkSegR� Autor � Equipe RH �             Data � 25/04/15 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tela para a escolha dos funcionario que ser�o exportados.  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fMarkSegR()                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEm090                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/

Static Function fMarkSegR()

Local oDlgSel
Local oFWLayer
Local oPanel
Local aCoors  	:= FWGetDialogSize( oMainWnd )
Local lGrava 	:= .F.
Local bSet15	:= {|| lGrava := .T., oDlgSel:End()}
Local bSet24	:= {|| oDlgSel:End()}
Local aColumns 	:= {}

Private oBrowseRes

Aadd( aColumns, { TitSX3("RA_FILIAL")[1]	,"TSGD_FIL"	,"C",TAMSX3("RA_FILIAL")[1],TAMSX3("RA_FILIAL")[2]	,GetSx3Cache( "RA_FILIAL" , "X3_PICTURE" ) })
Aadd( aColumns, { TitSX3("RA_MAT")[1]	    ,"TSGD_MAT"	,"C",TAMSX3("RA_MAT")[1]   ,TAMSX3("RA_MAT")[2]		,GetSx3Cache( "RA_MAT"    , "X3_PICTURE" )})
Aadd( aColumns, { TitSX3("RA_NOME")[1]	    ,"TSGD_NOME","C",TAMSX3("RA_NOME")[1]   ,TAMSX3("RA_NOME")[2]	,GetSx3Cache( "RA_NOME"   , "X3_PICTURE" )})
Aadd( aColumns, { "Tipo Rescis�o" 	        ,"TSGD_TIPO","C",3   ,0	,"@!"})
Aadd( aColumns, { "Descri��o" 	            ,"TSGD_DESC","C",30  ,0	,"@!"})

Define MsDialog oDlgSel Title "Selecionar Funcionarios" From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

oFWLayer := FWLayer():New()
oFWLayer:Init( oDlgSel, .F., .T. )

oFWLayer:AddLine( 'ALL', 100, .F. )
oFWLayer:AddCollumn( 'ALL', 100, .T., 'ALL' )
oPanel := oFWLayer:GetColPanel( 'ALL', 'ALL' )

oBrowseRes:= FWMarkBrowse():New()
oBrowseRes:SetOwner( oDlgSel )
oBrowseRes:SetDescription( "Rescis�es" )
oBrowseRes:SetAlias( "TSEGDES" )
oBrowseRes:SetTemporary(.T.)
oBrowseRes:SetFieldMark( 'TSGD_FLAG' )
oBrowseRes:SetFields(aColumns)
oBrowseRes:SetMenuDef( 'GPEM090' )
oBrowseRes:SetAllMark( {|| GPM90MALL() } )
oBrowseRes:DisableReport()
oBrowseRes:DisableSaveConfig()
oBrowseRes:DisableConfig()
oBrowseRes:Activate()

ACTIVATE MSDIALOG oDlgSel Center ON INIT EnchoiceBar( oDlgSel , bSet15 , bSet24 )

IF lGrava
	dbselectarea("TSEGDES")
	TSEGDES->(dbgotop())
	While TSEGDES->( !eof() )
	    IF !Empty(TSEGDES->TSGD_FLAG)

	    	dbselectarea("SRA")
	    	SRA->( dbgoto(TSEGDES->TSGD_RSRA) )

	    	dbselectarea("SRG")
	    	SRG->( dbgoto(TSEGDES->TSGD_RSRG) )

			REG_TIPO01()
		ENDIF
		TSEGDES->( dbskip() )
	ENDDO
ENDIF

Return


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GRVMARK� Autor � Equipe RH �               Data � 25/04/15 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tela para a escolha dos funcionario que ser�o exportados.  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GRVMARK()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEm090                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/

Static Function GRVMARK()

	Local nPos	:= fPosTab("S043", SRG->RG_TIPORES, "==", 04)
	Local cDesc	:= fTabela("S043", nPos, 5)

	Reclock("TSEGDES",.T.)
	TSGD_FLAG 	:= "  "
	TSGD_FIL 	:= SRA->RA_FILIAL
	TSGD_MAT	:= SRA->RA_MAT
	TSGD_NOME	:= SRA->RA_NOME
	TSGD_TIPO	:= SRG->RG_TIPORES
	TSGD_DESC	:= cDesc
	TSGD_RSRA	:= SRA->( recno() )
	TSGD_RSRG	:= SRG->( recno() )
	TSEGDES->( MsUnlock() )

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GPM90MALL� Autor � Equipe RH �             Data � 25/04/15 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina para marcar todas as op��es.                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GRVMARK()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEm090                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/

Static Function GPM90MALL()

Local aArea := GetArea()

	dbSelectArea("TSEGDES")
	TSEGDES->( dbGoTop() )

	While TSEGDES->( !Eof() )

		If (TSEGDES->TSGD_FLAG <> oBrowseRes:Mark())
			RecLock("TSEGDES", .F.)
			TSEGDES->TSGD_FLAG := oBrowseRes:Mark()
			MSUnlock()
		ElseIf (TSEGDES->TSGD_FLAG == oBrowseRes:Mark())
			RecLock("TSEGDES", .F.)
			TSEGDES->TSGD_FLAG := "  "
			MSUnlock()
		EndIf

		TSEGDES->( dbSkip() )
	EndDo

	RestArea(aArea)

	oBrowseRes:Refresh()
	oBrowseRes:GoTop()

Return Nil
