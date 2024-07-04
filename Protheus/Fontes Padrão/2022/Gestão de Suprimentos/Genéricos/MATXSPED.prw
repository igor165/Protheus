#Include "MATXSPED.ch"
#Include "Protheus.ch"
#Include "TbIconn.ch"
#Include 'Fwlibversion.ch'

#Define 0210 1
#Define K001 2
#Define K100 3
#Define K200 4
#Define K210 5
#Define K215 6
#Define K220 7
#Define K230 8
#Define K235 9
#Define K250 10
#Define K255 11
#Define K260 12
#Define K265 13
#Define K270 14
#Define K275 15
#Define K280 16
#Define K300 17
#Define K301 18
#Define K302 19
#Define K990 20
#Define 0200 21
#Define K290 22
#Define K291 23
#Define K292 24

STATIC aTmpRegK
STATIC lPCPREVATU	:= FindFunction('PCPREVATU')
STATIC cVersSped

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � SPDBlocoK     � Autor � Materiais         � Data � 06/09/16 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Esta funcao tem o objetivo de recupaderar informacoes de    ���
���          � Estoque para geracao do Bloco K para o SPED                 ���
��������������������������������������������������������������������������Ĵ��
���Versao EFD�                    ***** 2.0.19 *****                       ���
��������������������������������������������������������������������������Ĵ��
���Parametros� dDataDe    = Data Inicial para geracao das informacoes      ���
���          � dDataAte   = Data Final para geracao das informacoes        ���
���          � aAlias     = Alias dos arquivos de trabalho                 ���
���          � lEstruMov  = Gera registro 0210 por movimento               ���
���          � lSum       = Aglutina produtos com lancamentos no mesmo dia ���
���          � lHistor    = Se deve gerar historico do registros ou n�o    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function SPDBlocoK(dDataDe,dDataAte,aAlias,aAliProc,lEstruMov,lSum,lGerLogPro,lRepross )

Local aDate 	:= {}
Local aTime 	:= {}
Local aResult	:= {}
Local nX
Local lContinua		:= .T.
Local aRegistr		:= {"0210","K001","K100","K200","K210","K215","K220","K230","K235","K250","K255","K260","K265","K270","K275","K280","K300","K301","K302","K990","0200","K290","K291","K292"}
Local cMensagem		:= ""
Local cIDCV8MOV		:= ""
Local dDataFunc		:= Ctod("  /  /  ")
Local cHoraFunc		:= " "
Local lAtuFunc 		:= .F.
Private cTipo00		:= If(SuperGetMv("MV_BLKTP00",.F.,"'ME'")== " ","'ME'", SuperGetMv("MV_BLKTP00",.F.,"'ME'")) // 00: Mercadoria Revenda
Private cTipo01		:= If(SuperGetMv("MV_BLKTP01",.F.,"'MP'")== " ","'MP'", SuperGetMv("MV_BLKTP01",.F.,"'MP'")) // 01: Materia-Prima
Private cTipo02		:= If(SuperGetMv("MV_BLKTP02",.F.,"'EM'")== " ","'EM'", SuperGetMv("MV_BLKTP02",.F.,"'EM'")) // 02: Embalagem
Private cTipo03		:= If(SuperGetMv("MV_BLKTP03",.F.,"'PP'")== " ","'PP'", SuperGetMv("MV_BLKTP03",.F.,"'PP'")) // 03: Produto em Processo
Private cTipo04		:= If(SuperGetMv("MV_BLKTP04",.F.,"'PA'")== " ","'PA'", SuperGetMv("MV_BLKTP04",.F.,"'PA'")) // 04: Produto Acabado
Private cTipo05		:= If(SuperGetMv("MV_BLKTP05",.F.,"'SP'")== " ","'SP'", SuperGetMv("MV_BLKTP05",.F.,"'SP'")) // 05: SubProduto
Private cTipo06		:= If(SuperGetMv("MV_BLKTP06",.F.,"'PI'")== " ","'PI'", SuperGetMv("MV_BLKTP06",.F.,"'PI'")) // 06: Produto Intermediario
Private cTipo10		:= If(SuperGetMv("MV_BLKTP10",.F.,"'OI'")== " ","'OI'", SuperGetMv("MV_BLKTP10",.F.,"'OI'")) // 10: Outros Insumos
Private lEstMov		:= If(lEstruMov == Nil,.F., lEstruMov)
Private lNegEst		:= SuperGetMv("MV_NEGESTR",.F.,.F.)
Private nRegsto		:= 0	// Quantidade de Registros Gerados
Private lCpoBZTP	:= SBZ->(ColumnPos("BZ_TIPO")) > 0 .AND. SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SBZ"
Private cAlmTerc	:= GetAlmTerc()

Default lSum		:= .T.
Default lGerLogPro	:= .T.
Default lRepross	:= .T.

cVersSped	:= VerBlocoK(dDataDe)

aResult := GetFuncArray('SPDBlocoK',,,, aDate, aTime)
If Len(aDate)>0 .And. Len(aTime) > 0
	dDataFunc:= aDate[1]
	cHoraFunc:= aTime[1]
	lAtuFunc := .T.
EndIf

If Valtype(aAlias) == "A" .And. Len(aAlias) == Len(aRegistr) .And. Len(aAliProc) == Len(aRegistr)
	ProcLogIni({},STR0023,,@cIDCV8MOV) //"MATXSPED"
	ProcLogAtu(STR0024,STR0025 + FunName() + " "+ Alltrim(DtoC(Date())) + " - " + Alltrim(Time())) //inicio /"Rotina Chamadora: "
	cMensagem := ""
	cMensagem += STR0026 + cVersSped+chr(10)//"Vers�o do Leiaute : "
	cMensagem += STR0027+chr(10)//"Parametros de Sistema "
	cMensagem += "MV_NEGESTR : " + iIf(lNegEst,".T.",".F.")+chr(10)
	cMensagem += "MV_PRNFBE : " + iIf(SuperGetMV("MV_PRNFBE"  , .T., .F.),".T.",".F.")+chr(10)
	cMensagem += "MV_BLKMTHR : " + cValToChar(SuperGetMV("MV_BLKMTHR"  , .T., 1))+chr(10)
	cMensagem += "MV_CADPROD : " + SuperGetMV("MV_CADPROD"  , .T., "|SBZ|SB5|SGI|")+chr(10)
	cMensagem += "MV_ARQPROD : " + SuperGetMV("MV_ARQPROD"  , .T., "SB1")+chr(10)
	cMensagem += "MV_BLKTP00 : " + cTipo00+chr(10)
	cMensagem += "MV_BLKTP01 : " + cTipo01+chr(10)
	cMensagem += "MV_BLKTP02 : " + cTipo02+chr(10)
	cMensagem += "MV_BLKTP03 : " + cTipo03+chr(10)
	cMensagem += "MV_BLKTP04 : " + cTipo04+chr(10)
	cMensagem += "MV_BLKTP05 : " + cTipo05+chr(10)
	cMensagem += "MV_BLKTP06 : " + cTipo06+chr(10)
	cMensagem += "MV_BLKTP10 : " + cTipo10+chr(10)
	cMensagem += "MV_TMPAD :   " + SuperGetMV("MV_TMPAD"  , .F., " ")+chr(10)
	cMensagem += STR0034 + iIf(lCpoBZTP,"Sim","N�o")+chr(10) //"Utilizacao da tabela SBZ com o campo BZ_TIPO : "
	If lAtuFunc
		cMensagem += STR0035 + " " + Alltrim(DtoC(dDataFunc)) + "_" + cHoraFunc +chr(10) //"Ultima aTualiza��o do MATXSPED: "
	EndIf

	ProcLogAtu('MENSAGEM',"Informa��es auxiliares "+ Alltrim(DtoC(Date())) + " - " + Alltrim(Time()),cMensagem)
	cMensagem := ""

	If cVersSped < "013"
		lGerLogPro := .F.
		lRepross := .F.
	EndIf

	If cVersSped >= "013"
		// checa se o UPDDISTR foi aplicado
		ChkUpd()
		dbSelectArea("D3E")
		dbSelectArea("D3K")
		dbSelectArea("D3H")
		dbSelectArea("D3I")
		dbSelectArea("D3J")
		dbSelectArea("D3L")
		dbSelectArea("D3M")
		dbSelectArea("D3N")
		dbSelectArea("D3O")
		dbSelectArea("D3P")
		dbSelectArea("D3R")
		dbSelectArea("D3S")
		dbSelectArea("D3T")
		dbSelectArea("D3U")
		dbSelectArea("SVK")
		dbSelectArea("SVS")
		dbSelectArea("SVT")
		dbSelectArea("SVU")
		dbSelectArea("SVV")
		dbSelectArea("SVW")
		dbSelectArea("T4E")
		dbSelectArea("T4F")
		dbSelectArea("T4G")
		dbSelectArea("T4H")
		dbSelectArea("SDH")
	Else
		//���������������������������������������������������������Ŀ
		//� Verifica se o campo Tipo de Producao existe no ambiente �
		//�����������������������������������������������������������
		dbSelectArea("SC2")
		If SC2->(FieldPos("C2_TPPR")) == 0
			Aviso("Aten��o","O campo de Tipo de Produ��o (C2_TPPR), n�o existe no ambiente. O processamento do Bloco K n�o ser� realizado.",{"Ok"})
			lContinua := .F.
		EndIf
	EndIf

	//����������������������������������������������������������Ŀ
	//� Chama o PE SPDFIS001 para realizar a troca dos Tipos     �
	//������������������������������������������������������������
	TrocaTipo()

	aTmpRegK := {}
	//����������������������������������������������������������Ŀ
	//� Limpa Log periodo ja apurado.							�
	//������������������������������������������������������������
	If lGerLogPro
		BlkPrLimp(dDataAte)
	EndIf

	//����������������������������������������������������������Ŀ
	//� Montagem dos Arquivos de Trabalho                        �
	//������������������������������������������������������������
	ProcLogAtu('MENSAGEM',STR0003+Alltrim(DtoC(Date())) + " - " + Alltrim(Time())) // "Bloco K - Preparando arquivos TEMP: "
	For nX := 1 To Len(aAlias)
		Aadd(aTmpRegK ,SPDCriaTRB(aRegistr[nX],@aAlias[nX]))
	Next nX

	If lContinua .and. (Empty(dDataDe) .OR. Empty(dDataAte))
		lContinua := .F.
	EndIf
	If lContinua

		//����������������������������������������������������������Ŀ
		//� Gravacao dos Arquivos de Trabalho - Nao alterar a ordem  �
		//������������������������������������������������������������
			REGANTG(dDataDe,dDataAte)
			REGESTOR(dDataDe,dDataAte)
		If aAliProc[K200]
			ProcLogAtu('MENSAGEM',STR0004+Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
			REGK200(aAlias[K200],dDataDe,dDataAte,lRepross,cIDCV8MOV)
		EndIf
		If aAliProc[K210]
			ProcLogAtu('MENSAGEM',STR0005+Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
			REGK21X(aAlias[K210],aAlias[K215],dDataDe,dDataAte,lGerLogPro,lRepross)
		Else
			REGK21X("","",dDataDe,dDataAte,lGerLogPro,lRepross)
		EndIf

		If aAliProc[K220]
			ProcLogAtu('MENSAGEM',STR0006+Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
			REGK220(aAlias[K220],dDataDe,dDataAte,lGerLogPro,lRepross)
		Else
			REGK220("",dDataDe,dDataAte,lGerLogPro,lRepross)
		EndIf

		If aAliProc[K230]
			ProcLogAtu('MENSAGEM',"### Bloco K - Inicio Valida��o de Movimentos Antigos : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
			If cVersSped < '013' //Valida��o de vers�o
				ProcLogAtu('MENSAGEM',"### Bloco K - Inicio Registro K235|012  : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
				REGK235V12(aAlias[K235],dDataDe,dDataAte,aAlias[K270],aAlias[K275])
				ProcLogAtu('MENSAGEM',"### Bloco K - Inicio Registro K230|012  : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
				REGK230V12(aAlias[K230],aAlias[K235],aAlias[0210],dDataDe,dDataAte,lRepross)
			Else
				ProcLogAtu('MENSAGEM',"### Bloco K - Inicio Registro K235    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
				REGK235(aAlias[K235],dDataDe,dDataAte,aAlias[K270],aAlias[K275],lRepross)
				ProcLogAtu('MENSAGEM',"### Bloco K - Inicio Registro K230    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
				REGK230(aAlias[K230],aAlias[K235],aAlias[0210],dDataDe,dDataAte,lRepross)
			EndIf
		EndIf
		If aAliProc[K250]
			ProcLogAtu('MENSAGEM',STR0009+Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
			REGK250(aAlias[K250],aAlias[K255],aAlias[0210],dDataDe,dDataAte,lSum,lGerLogPro,lRepross)
		EndIf
		If aAliProc[K260]
			If Existblock("REGK26X")
				REGK26X(aAlias[K260],aAlias[K265],dDataDe,dDataAte)
			Else
				If cVersSped >= '013' //Valida��o de vers�o
					ProcLogAtu('MENSAGEM',"### Bloco K - Inicio Registro K265    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
					REGK265(aAlias[K265],dDataDe,dDataAte,lRepross)
					ProcLogAtu('MENSAGEM',"### Bloco K - Inicio Registro K260    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
					REGK260(aAlias[K260],dDataDe,dDataAte,lRepross)
				EndIf
			EndIf
		EndIf
		If aAliProc[K270]
			ProcLogAtu('MENSAGEM',"### Bloco K - Inicio Registro K275|01    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
			REGK27X(aAlias[K270],aAlias[K275],dDataDe,dDataAte,,,lGerLogPro,lRepross,aAlias[K280])
			If cVersSped >= '013' //Valida��o de vers�o
				ProcLogAtu('MENSAGEM',"### Bloco K - Inicio Registro K275    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
				REGK275PRO(aAlias[K275],dDataDe,dDataAte,lRepross)
				ProcLogAtu('MENSAGEM',"### Bloco K - Inicio Registro K270    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
				REGK270PRO(aAlias[K270],dDataDe,dDataAte,lRepross)
			EndIf

		else
			REGK27X("","",dDataDe,dDataAte,,,lGerLogPro,lRepross,aAlias[K280])
		EndIf
		If aAliProc[K280]
			ProcLogAtu('MENSAGEM',STR0011+Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
			REGK280(aAlias[K280],dDataDe,dDataAte,lGerLogPro,lRepross)
		EndIf

		If aAliProc[K290]
			If cVersSped >= '013' //Valida��o de vers�o
				ProcLogAtu('MENSAGEM',"### Bloco K - Inicio Registro K292    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
				REGK292(aAlias[K292],dDataDe,dDataAte,lRepross)
				ProcLogAtu('MENSAGEM',"### Bloco K - Inicio Registro K290    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
				REGK290(aAlias[K290],dDataDe,dDataAte,lRepross)
				ProcLogAtu('MENSAGEM',"### Bloco K - Inicio Registro K291    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
				REGK291(aAlias[K291],dDataDe,dDataAte,lRepross)
			EndIf
		EndIf

		If aAliProc[K300]
			ProcLogAtu('MENSAGEM',STR0011+Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
			REGK300(aAlias[K300],aAlias[K301],aAlias[K302],dDataDe,dDataAte,lGerLogPro,lRepross)
		EndIf

		//����������������������������������������������������������Ŀ
		//� Gera o Registro 0210 pelas das movimentacoes do periodo  �
		//������������������������������������������������������������
		If aAliProc[K230] .And. lEstMov
			ProcLogAtu('MENSAGEM',STR0013+Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
			REG0210Mov(aAlias[K230],aAlias[K235],aAlias[0210],dDataDe,dDataAte)
		EndIf

		//����������������������������������������������������������Ŀ
		//� Tratamento para producoes com estrutura negativa         �
		//������������������������������������������������������������
		If aAliProc[K230] .And. lNegEst .And. !lEstMov
			ProcNegEst(aAlias[0210],aAlias[K230],aAlias[K235],dDataDe,dDataAte,lRepross)
		EndIf

		//����������������������������������������������������������Ŀ
		//� Finaliza a Gravacao dos Registros - Nao alterar a ordem  �
		//������������������������������������������������������������
		ProcLogAtu('MENSAGEM',STR0014+Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
		REGK001(aAlias[K001],dDataAte,lRepross)
		REGK100(aAlias[K100],dDataDe,dDataAte,lRepross)
		REGK990(aAlias[K990],dDataDe,lRepross)

		//����������������������������������������������������������Ŀ
		//� Grava os produtos utilizados nos Registros do Bloco K    �
		//������������������������������������������������������������
		ProcLogAtu('MENSAGEM',STR0015+Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
		REG0200(aAlias,aRegistr)

		//����������������������������������������������������������Ŀ
		//� Posiciona no Primeiro RECNO de cada Arquivo de Trabalho  �
		//������������������������������������������������������������
		For nX := 1 To Len(aAlias)
			(aAlias[nX])->(dbGoTop())
		Next nX
	EndIf

	GravMetric(aAliProc) // Gravacao da metrica de negocio

	ProcLogAtu('FIM',"Rotina Chamadora: "+ FunName() + " "+ Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
EndIf

Return aTmpRegK

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � SPDCriaTRB     � Autor � Materiais        � Data � 28/07/14 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Criacao do arquivo temporario para retorno de informacoes.  ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cBloco    = Nome do Bloco para geracao arquivo de trabalho  ���
���          � cAliasTRB = Nome do arquivo de trabalho                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function SPDCriaTRB(cBloco,cAliasTRB)

Local cIndice	:= ""
Local nX
Local aLayout	:= {}
Local aStrReg	:= {}

Default cAliasTRB	:= ""
Default cBloco		:= ""

//����������������������������������������������������������Ŀ
//� Posicoes: [1]Campos / [2]Indices                         �
//������������������������������������������������������������
aLayout := SPDLayout(cBloco)

//����������������������������������������������������������Ŀ
//� Criacao do Arquivo de Trabalho                           �
//������������������������������������������������������������
If !Empty(cBloco)

	cAliasTRB := UPPER(cBloco)+"_"+CriaTrab(,.F.)
	//
	// aStrReg
	//		[1] := Alias da tabela temporaria a ser criada
	//		[2] := Nome da tabela temporaria criada via dbcreate no driver sqlite
	//		[3,n] := Conjunto de nome de indices da tabela quando a tabela � cria
	//		[4] := Objeto criado via FWTemporaryTable
	//
	aStrReg := {cAliasTRB ,NIL ,{} ,NIL}
	// Tratamento diferenciado devido tabela ser lida em rotina MULTI-THREAD
	If cBloco == "K200"
		aStrReg[2] := "K_"+cAliasTRB
		fWDbCreate(aStrReg[2],aLayout[1],'TOPCONN',.T.)
		dbUseArea(.T.,'TOPCONN',aStrReg[2],aStrReg[1],.T.)
		For nX := 1 to Len(aLayout[2])
			If Substring(cAliasTRB,1,1) == "K"
				cIndice := aStrReg[1]+"_"+Alltrim(StrZero(nX,2))
				Aadd(aStrReg[3] ,cIndice)
				DBCreateIndex(cIndice ,aLayout[2][nX])
				DBSetIndex(cIndice)
			EndIf
		Next nX

	Else
		aStrReg[4] := FWTemporaryTable():New( aStrReg[1] )
		aStrReg[4]:SetFields( aClone(aLayout[1]) )
		For nX := 1 to len(aLayout[2])
			aStrReg[4]:AddIndex(StrZero(nX,2), aClone(aLayout[2,nX]) )
		Next nX
		aStrReg[4]:Create()

	EndIf
EndIf
Return aStrReg

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � SPDLayout      � Autor � Materiais		 � Data � 28/07/14 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Funcao responsavel pela montagem do layout do bloco         ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cBloco = Nome do bloco para geracao do Layout               ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function SPDLayout(cBloco)

Local aCampos		:= {}
Local aIndices		:= {}
Local nTamFil		:= TamSX3("D1_FILIAL" )[1]
Local nTamDt		:= TamSX3("D1_DTDIGIT")[1]
Local nTamOP		:= TamSX3("D3_OP"     )[1]
Local nTamCod		:= TamSX3("B1_COD"    )[1]
Local nTamNSeq		:= 30
Local nTamChave  	:= nTamCod + TamSX3("D1_SERIE")[1] + TamSX3("D1_FORNECE")[1] + TamSX3("D1_LOJA")[1]
// ------ Tamanhos conforme especificado no Guia EFD ------
Local nTamReg		:= 4
Local aTamQtd		:= {16,If(cVersSped < '013',3,6)}
Local aTamCmp		:= {16,6}
Local aTamPrd		:= {16,4}
Local aTamQtdOld	:= {16,3}
// --------------------------------------------------------
Default cBloco		:= ""

//������������������������������������������������������������Ŀ
//�                     *** ATENCAO!!! ***                     �
//� Antes de realizar alteracoes nos tamanhos dos campos para  �
//� montagem dos arquivos de trabalho, verificar especificacao �
//� deles no Guia Pratico EFD no site do SPED Fiscal(Receita)  �
//��������������������������������������������������������������

Do Case
	Case cBloco == "0200"
		//����������������������������������������������������������Ŀ
		//� Criacao do Arquivo de Trabalho - BLOCO 0200              �
		//������������������������������������������������������������
		aCampos := {}
		AADD(aCampos,{"COD_ITEM"	,"C",nTamCod			,0}) // Nao integra Bloco K
		// Indices
		AADD(aIndices,{"COD_ITEM"})
	Case cBloco == "0210"
		//����������������������������������������������������������Ŀ
		//� Criacao do Arquivo de Trabalho - BLOCO 0210              �
		//������������������������������������������������������������
		aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",nTamFil			,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"			,"C",nTamReg			,0})
		AADD(aCampos,{"COD_ITEM"	,"C",nTamCod			,0}) // Nao integra Bloco K
		AADD(aCampos,{"COD_I_COMP"	,"C",nTamCod			,0})
		AADD(aCampos,{"QTD_COMP"	,"N",aTamCmp[1],aTamCmp[2]})
		AADD(aCampos,{"QTD_PROD"	,"N",aTamCmp[1],aTamCmp[2]}) // Nao integra Bloco K
		AADD(aCampos,{"QTD_CONS"	,"N",aTamCmp[1],aTamCmp[2]}) // Nao integra Bloco K
		AADD(aCampos,{"PERDA"		,"N",aTamPrd[1],aTamPrd[2]})
		// Indices
		AADD(aIndices,{"FILIAL" ,"COD_ITEM" ,"COD_I_COMP"})
	Case cBloco == "K001"
		//����������������������������������������������������������Ŀ
		//� Criacao do Arquivo de Trabalho - BLOCO K001              �
		//������������������������������������������������������������
	 	aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",nTamFil			,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"			,"C",nTamReg			,0})
		AADD(aCampos,{"IND_MOV"		,"C",1					,0})
		// Indices
		AADD(aIndices,{"FILIAL"})
	Case cBloco == "K100"
		//����������������������������������������������������������Ŀ
		//� Criacao do Arquivo de Trabalho - BLOCO K100              �
		//������������������������������������������������������������
	 	aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",nTamFil			,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"			,"C",nTamReg			,0})
		AADD(aCampos,{"DT_INI"		,"D",nTamDt				,0})
		AADD(aCampos,{"DT_FIN"		,"D",nTamDt				,0})
		// Indices
		AADD(aIndices,{"FILIAL" ,"DT_INI"})
	Case cBloco == "K200"
		//����������������������������������������������������������Ŀ
		//� Criacao do Arquivo de Trabalho - BLOCO K200              �
		//������������������������������������������������������������
	 	aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",nTamFil			,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"			,"C",nTamReg			,0})
		AADD(aCampos,{"DT_EST"		,"D",nTamDt				,0})
		AADD(aCampos,{"COD_ITEM"	,"C",nTamCod			,0})
		AADD(aCampos,{"QTD"			,"N",aTamQtdOld[1],aTamQtdOld[2]})
		AADD(aCampos,{"IND_EST"		,"C",1					,0})
		AADD(aCampos,{"COD_PART"	,"C",60					,0})
		// Indices
		AADD(aIndices,"FILIAL+DTOS(DT_EST)+COD_ITEM+IND_EST+COD_PART") // Indice em formato diferente, por n�o utilizar FWTemporaryTable
	Case cBloco == "K210"
		//����������������������������������������������������������Ŀ
		//� Criacao do Arquivo de Trabalho - BLOCO K210              �
		//������������������������������������������������������������
		AADD(aCampos,{"FILIAL"		,"C",nTamFil			,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"			,"C",nTamReg			,0})
		AADD(aCampos,{"DT_INI_OS"	,"D",nTamDt				,0})
		AADD(aCampos,{"DT_FIN_OS"	,"D",nTamDt				,0})
		AADD(aCampos,{"COD_DOC_OS"	,"C",nTamNSeq			,0})
		AADD(aCampos,{"COD_ITEM_O"	,"C",nTamCod			,0})
		AADD(aCampos,{"QTD_ORI"		,"N",aTamQtd[1],aTamQtd[2]})
		// Indices
		AADD(aIndices,{"FILIAL" ,"COD_DOC_OS" ,"COD_ITEM_O"})
	Case cBloco == "K215"
		//����������������������������������������������������������Ŀ
		//� Criacao do Arquivo de Trabalho - BLOCO K215              �
		//������������������������������������������������������������
		AADD(aCampos,{"FILIAL"		,"C",nTamFil			,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"			,"C",nTamReg			,0})
		AADD(aCampos,{"COD_DOC_OS"	,"C",nTamNSeq			,0}) // Nao integra Bloco K
		AADD(aCampos,{"COD_ITEM_D"	,"C",nTamCod			,0})
		AADD(aCampos,{"QTD_DES"		,"N",aTamQtd[1],aTamQtd[2]})
		// Indices
		AADD(aIndices,{"FILIAL" ,"COD_DOC_OS" ,"COD_ITEM_D"})
	Case cBloco == "K220"
		//����������������������������������������������������������Ŀ
		//� Criacao do Arquivo de Trabalho - BLOCO K220              �
		//������������������������������������������������������������
		aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",nTamFil			,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"			,"C",nTamReg			,0})
		AADD(aCampos,{"DT_MOV"		,"D",nTamDt				,0})
		AADD(aCampos,{"COD_ITEM_O"	,"C",nTamCod			,0})
		AADD(aCampos,{"COD_ITEM_D"	,"C",nTamCod			,0})
		AADD(aCampos,{"QTD_ORI"		,"N",aTamQtd[1],aTamQtd[2]})
		AADD(aCampos,{"QTD_DEST"	,"N",aTamQtd[1],aTamQtd[2]})
		// Indices
		AADD(aIndices,{"FILIAL" ,"DT_MOV" ,"COD_ITEM_O" ,"COD_ITEM_D"})
	Case cBloco == "K230" .Or. cBloco == "K235" .Or. cBloco == "K290" .Or. cBloco == "K291" .Or. cBloco = "K292" .Or. cBloco = "K260" .Or. cBloco = "K265"
		PCPLayout(cBloco,@aCampos,@aIndices,cVersSped)

	Case cBloco == "K250"
		//����������������������������������������������������������Ŀ
		//� Criacao do Arquivo de Trabalho - BLOCO K250              �
		//������������������������������������������������������������
		aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",nTamFil			,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"			,"C",nTamReg			,0})
		AADD(aCampos,{"CHAVE"       ,"C",nTamChave   		,0}) // Nao integra Bloco K
		AADD(aCampos,{"DT_PROD"		,"D",nTamDt				,0})
		AADD(aCampos,{"COD_ITEM"	,"C",nTamCod			,0})
		AADD(aCampos,{"QTD"			,"N",aTamQtd[1],aTamQtd[2]})
		// Indices
		AADD(aIndices,{"FILIAL" ,"CHAVE" ,"COD_ITEM"})
		AADD(aIndices,{"FILIAL" ,"DT_PROD" ,"COD_ITEM"})
	Case cBloco == "K255"
		//����������������������������������������������������������Ŀ
		//� Criacao do Arquivo de Trabalho - BLOCO K255              �
		//������������������������������������������������������������
		aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",nTamFil			,0}) // Nao integra Bloco K
		AADD(aCampos,{"CHAVE"       ,"C",nTamChave   		,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"			,"C",nTamReg			,0})
		AADD(aCampos,{"DT_CONS"		,"D",nTamDt				,0})
		AADD(aCampos,{"COD_ITEM"	,"C",nTamCod			,0})
		AADD(aCampos,{"QTD"			,"N",aTamQtd[1],aTamQtd[2]})
		AADD(aCampos,{"COD_INS_SU"	,"C",nTamCod			,0})
		// Indices
		AADD(aIndices,{"FILIAL" ,"CHAVE" ,"COD_ITEM"})
		AADD(aIndices,{"FILIAL" ,"DT_CONS" ,"COD_ITEM"})
	Case cBloco == "K270"
		//����������������������������������������������������������Ŀ
		//� Criacao do Arquivo de Trabalho - BLOCO K270              �
		//������������������������������������������������������������
		AADD(aCampos,{"FILIAL"		,"C",nTamFil			,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"			,"C",nTamReg			,0})
		AADD(aCampos,{"CHAVE"       ,"C",nTamChave   		,0}) // Nao integra Bloco K
		AADD(aCampos,{"DT_INI_AP"	,"D",nTamDt				,0})
		AADD(aCampos,{"DT_FIN_AP"	,"D",nTamDt				,0})
		AADD(aCampos,{"COD_OP_OS"	,"C",nTamOP				,0})
		AADD(aCampos,{"COD_ITEM"	,"C",nTamCod			,0})
		AADD(aCampos,{"QTD_COR_P"	,"N",aTamQtd[1],aTamQtd[2]})
		AADD(aCampos,{"QTD_COR_N"	,"N",aTamQtd[1],aTamQtd[2]})
		AADD(aCampos,{"ORIGEM"		,"C",1					,0})
		// Indices
		AADD(aIndices,{"FILIAL" ,"CHAVE" ,"DT_INI_AP" ,"DT_FIN_AP" ,"COD_OP_OS" ,"COD_ITEM"})
		AADD(aIndices,{"FILIAL" ,"DT_INI_AP" ,"DT_FIN_AP" ,"COD_OP_OS" ,"COD_ITEM"})
	Case cBloco == "K275"
		//����������������������������������������������������������Ŀ
		//� Criacao do Arquivo de Trabalho - BLOCO K275              �
		//������������������������������������������������������������
		AADD(aCampos,{"FILIAL"		,"C",nTamFil			,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"			,"C",nTamReg			,0})
		AADD(aCampos,{"CHAVE"       ,"C",nTamChave   		,0}) // Nao integra Bloco K
		AADD(aCampos,{"COD_OP_OS"	,"C",nTamOP				,0}) // Nao integra Bloco K
		AADD(aCampos,{"COD_ITEM"	,"C",nTamCod			,0})
		AADD(aCampos,{"QTD_COR_P"	,"N",aTamQtd[1],aTamQtd[2]})
		AADD(aCampos,{"QTD_COR_N"	,"N",aTamQtd[1],aTamQtd[2]})
		AADD(aCampos,{"COD_INS_SU"	,"C",nTamCod			,0})
		// Indices
		AADD(aIndices,{"FILIAL" ,"CHAVE" ,"COD_OP_OS" ,"COD_ITEM"})
		AADD(aIndices,{"FILIAL" ,"COD_OP_OS" ,"COD_ITEM"})
	Case cBloco == "K280"
		//����������������������������������������������������������Ŀ
		//� Criacao do Arquivo de Trabalho - BLOCO K280              �
		//������������������������������������������������������������
		AADD(aCampos,{"FILIAL"		,"C",nTamFil			,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"			,"C",nTamReg			,0})
		AADD(aCampos,{"DT_EST"		,"D",nTamDt				,0})
		AADD(aCampos,{"COD_ITEM"	,"C",nTamCod			,0})
		AADD(aCampos,{"QTD_COR_P"	,"N",aTamQtdOld[1],aTamQtdOld[2]})
		AADD(aCampos,{"QTD_COR_N"	,"N",aTamQtdOld[1],aTamQtdOld[2]})
		AADD(aCampos,{"IND_EST"		,"C",1					,0})
		AADD(aCampos,{"COD_PART"	,"C",60					,0})
		// Indices
		AADD(aIndices,{"FILIAL" ,"DT_EST" ,"COD_ITEM" ,"IND_EST" ,"COD_PART"})
	Case cBloco == "K300"
		//����������������������������������������������������������Ŀ
		//?Criacao do Arquivo de Trabalho - BLOCO K300              ?
		//������������������������������������������������������������
		aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",nTamFil			,0}) // Nao integra Bloco K
		AADD(aCampos,{"CHAVE"       ,"C",nTamChave   		,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"			,"C",nTamReg			,0})
		AADD(aCampos,{"DT_PROD"		,"D",nTamDt				,0})
		// Indices
		AADD(aIndices,{"FILIAL","CHAVE"})
	Case cBloco == "K301"
		//����������������������������������������������������������Ŀ
		//?Criacao do Arquivo de Trabalho - BLOCO K301              ?
		//������������������������������������������������������������
		aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",nTamFil			,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"			,"C",nTamReg			,0})
		AADD(aCampos,{"CHAVE"       ,"C",nTamChave   		,0}) // Nao integra Bloco K
		AADD(aCampos,{"COD_ITEM"	,"C",nTamCod			,0})
		AADD(aCampos,{"QTD"			,"N",aTamQtd[1],aTamQtd[2]})
		// Indices
		AADD(aIndices,{"FILIAL","CHAVE"})
	Case cBloco == "K302"
		//����������������������������������������������������������Ŀ
		//?Criacao do Arquivo de Trabalho - BLOCO K302              ?
		//������������������������������������������������������������
		aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",nTamFil			,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"			,"C",nTamReg			,0})
		AADD(aCampos,{"CHAVE"       ,"C",nTamChave   		,0}) // Nao integra Bloco K
		AADD(aCampos,{"COD_ITEM"	,"C",nTamCod			,0})
		AADD(aCampos,{"QTD"			,"N",aTamQtd[1],aTamQtd[2]})
		// Indices
		AADD(aIndices,{"FILIAL","CHAVE"})
	Case cBloco == "K990"
		//����������������������������������������������������������Ŀ
		//� Criacao do Arquivo de Trabalho - BLOCO K990              �
		//������������������������������������������������������������
		aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",nTamFil			,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"			,"C",nTamReg			,0})
		AADD(aCampos,{"QTD_LIN_K"	,"N",14					,0})
		// Indices
		AADD(aIndices,{"FILIAL"})
EndCase

Return {aCampos,aIndices}

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � REGK001        � Autor � Materiais        � Data � 28/07/14 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Funcao responsavel pela gravacao do Registro K001           ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cAliasTRB   = Alias do arquivo de trabalho do Bloco         ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function REGK001(cAliK001,dDataAte,lRepross)

Default lRepross := .T.

Reclock(cAliK001,.T.)
(cAliK001)->FILIAL	:= cFilAnt
(cAliK001)->REG		:= "K001"
If nRegsto > 0
	(cAliK001)->IND_MOV := "0"	// Existem informacoes no Bloco K
Else
	(cAliK001)->IND_MOV := "1"	// Nao existem informacoes no Bloco K
EndIf
(cAliK001)->(MsUnLock())
nRegsto++

// grava na tabela de historico
BlkGrvTab(cAliK001,"D3G",aTmpRegK[K001][4],dDataAte,lRepross)

Return

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � REGK100        � Autor � Materiais        � Data � 28/07/14 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Funcao responsavel pela gravacao do Registro K100           ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cAliasTRB   = Alias do arquivo de trabalho do Bloco         ���
���          � dDataDe     = Data Inicial da Apuracao                      ���
���          � dDataAte    = Data Final da Apuracao                        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function REGK100(cAliK100,dDataDe,dDataAte,lRepross)

Default lRepross := .T.

Reclock(cAliK100,.T.)
(cAliK100)->FILIAL	:= cFilAnt
(cAliK100)->REG		:= "K100"
(cAliK100)->DT_INI	:= dDataDe
(cAliK100)->DT_FIN	:= dDataAte
(cAliK100)->(MsUnLock())
nRegsto++

// grava na tabela de historico
BlkGrvTab(cAliK100,"D3H",aTmpRegK[K100][4],dDataAte,lRepross)

Return

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � REGK200        � Autor � Materiais        � Data � 28/07/14 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Funcao responsavel pela gravacao do Registro K200           ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cAliasTRB   = Alias do arquivo de trabalho do Bloco         ���
���          � dDataDe     = Data Inicial da Apuracao                      ���
���          � dDataAte    = Data Final da Apuracao                        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function REGK200(cAliK200,dDataDe,dDataAte,lRepross,cIDCV8MOV)

Local cError		:= ""
Local aRecTHRs		:= {}
Local lRet			:= .T.
Local cAliProp		:= "K_"+CriaTrab(Nil,.F.)
Local nThread		:= SuperGetMV("MV_BLKMTHR",.F.,1)
Local nX
Local aK200			:= array(4)
Local cAliSumTer

Private cName		:= "JobK200"
Private oIpc

// limita o numero de threads
If nThread > 20
	nThread := 20
EndIf

aK200[1] := aTmpRegK[K200,1]
aK200[2] := aTmpRegK[K200,2]
aK200[3] := aTmpRegK[K200,3,1]
aK200[4] := 1

//�������������������������������������������������������Ŀ
//� Monta o arquivo com os produtos que serao processados no K200�
//���������������������������������������������������������
ProcLogAtu('MENSAGEM',STR0017+ Alltrim(DtoC(Date())) + " - " + Alltrim(Time())) // "Bloco K - K200|00: Lista Produtos : "
GetListPrd(@cAliProp,dDataAte,dDataDe)

cAliSumTer := CriaTrab(Nil,.F.)
CreaSumTerc(@cAliSumTer)

//�������������������������������������������������������Ŀ
//� Calcula os melhores RECNOs para cada Thread           �
//���������������������������������������������������������
ProcLogAtu('MENSAGEM',"Bloco K - K200|00: Calculo das Thread: "+ Alltrim(DtoC(Date())) + " - " + Alltrim(Time()),"Contagem dos produtos a serem processados: "+cvaltochar((cAliProp)->(lastrec())) )
aRecTHRs := CalcThread(cAliProp,@nThread)

If nThread <2
	JobK200(0,cName,aK200,cAliProp,cAliSumTer,dDataAte,aRecTHRs[1],lRepross,@cIDCV8MOV)
Else
	//�������������������������������������������������������Ŀ
	//� Prepara o Multi-Thread                                �
	//���������������������������������������������������������
	oIPC := FWIPCWait():New(cName,10000)
	oIPC:SetThreads(nThread)
	oIPC:SetEnvironment(cEmpAnt,cFilAnt)
	oIPC:Start("JobK200") 		// Funcao que vai rodar em Thread
	oIPC:SetNoErrorStop(.T.)	//Se der erro em alguma thread sai imadiatamente

	//�������������������������������������������������������Ŀ
	//� Abre as Threads                                       �
	//���������������������������������������������������������
	For nX := 1 To nThread
		lRet := oIpc:Go(nX,cName,aK200,cAliProp,cAliSumTer,dDataAte,aRecTHRs[nX],lRepross,@cIDCV8MOV)
		If !lRet
			Exit
		EndIf
	Next nX

	//�������������������������������������������������������Ŀ
	//� Finaliza o Multi-Thread                               �
	//���������������������������������������������������������
	oIPC:Stop()
	cError := oIPC:GetError()
	FreeObj(oIpc)
EndIf

// atualiza o saldo proprio descontando ou n�o o saldo de terceiro
ProcSumTerc(cAliK200,cAliSumTer)

//�������������������������������������������������������������������������Ŀ
//� Grava tabela de 		        �
//� ----------------------------------------------------------------------- �
//� Tratamento quando unico codigo de produto esteja contido o saldo de  	�
//� terceiros e,possa ter, saldo proprio e ou saldo de terceito				�
//� O processamento fica fora do loop principal pois depende da gravacao do �
//� IND_EST = 0, pois a CALCEST retorna a QTDE somando o saldo DE TERCEIROS �
//���������������������������������������������������������������������������
(cAliK200)->(DbGoTop())
BlkGrvTab(cAliK200,'D3I',,dDataAte,lRepross,.T.)

If !Empty(cError)
	Help(,,"ERROR",,cError,1,0)
EndIf

//�������������������������������������������������������Ŀ
//� Atualiza quantidade de registros na variavel nRegsto  �
//���������������������������������������������������������
(cAliK200)->(dbGoTop())
While !(cAliK200)->(Eof())
	nRegsto++
	(cAliK200)->(dbSkip())
EndDo

//----------------------------------------//
// Eliminar arquivos temporarios de banco//
//---------------------------------------//
(cAliSumTer)->(dbCloseArea())
// neste caso o nome da tabela � o mesmo que o alias
If TcCanOpen( cAliSumTer )
	TcDelFile( cAliSumTer )
EndIf

(cAliProp)->(dbCloseArea())
// neste caso o nome da tabela � o mesmo que o alias
If TcCanOpen( cAliProp )
	TcDelFile( cAliProp )
EndIf

Return

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � JobK200        � Autor � Materiais        � Data � 30/08/16 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Funcao responsavel pela gravacao do Registro K200           ���
��������������������������������������������������������������������������Ĵ��
���Parametros� nThread     = Numero da Thread em Execucao                  ���
���          � cName       = Controle interno                              ���
���          � aAliK200    = Alias do arquivo K200 / Indice do K200        ���
���          � cAliasTmp   = Alias TRB de produtos a processar (Proprio)   ���
���          � dDataAte    = Data Final da Apuracao                        ���
���          � nRecIni     = Recno inicial a processar                     ���
���          � nRecFin     = Recno final a processar                       ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function JobK200(nThread,cName,aK200,cAliasTmp,cAliSumTer,dDataAte,aFaixaRec,lRepross,cIDCV8MOV)

Local nSaldo		:= 0
Local cProdAtu		:= ""
Local cAliK200		:= ""
Local cSB9Filial	:= xFilial("SB9")
Local aProdDeAte	:= {}
Local cCOD_PART		:= ""
Local cIND_EST		:= ""
Local nRecIni
Local nRecFin
Local cLocProc      := GetMvNNR("MV_LOCPROC",'99')

DEFAULT lRepross	:= .T.

Private cTipo00		:= If(SuperGetMv("MV_BLKTP00",.F.,"'ME'")== " ","'ME'", SuperGetMv("MV_BLKTP00",.F.,"'ME'")) // 00: Mercadoria Revenda
Private cTipo01		:= If(SuperGetMv("MV_BLKTP01",.F.,"'MP'")== " ","'MP'", SuperGetMv("MV_BLKTP01",.F.,"'MP'")) // 01: Materia-Prima
Private cTipo02		:= If(SuperGetMv("MV_BLKTP02",.F.,"'EM'")== " ","'EM'", SuperGetMv("MV_BLKTP02",.F.,"'EM'")) // 02: Embalagem
Private cTipo03		:= If(SuperGetMv("MV_BLKTP03",.F.,"'PP'")== " ","'PP'", SuperGetMv("MV_BLKTP03",.F.,"'PP'")) // 03: Produto em Processo
Private cTipo04		:= If(SuperGetMv("MV_BLKTP04",.F.,"'PA'")== " ","'PA'", SuperGetMv("MV_BLKTP04",.F.,"'PA'")) // 04: Produto Acabado
Private cTipo05		:= If(SuperGetMv("MV_BLKTP05",.F.,"'SP'")== " ","'SP'", SuperGetMv("MV_BLKTP05",.F.,"'SP'")) // 05: SubProduto
Private cTipo06		:= If(SuperGetMv("MV_BLKTP06",.F.,"'PI'")== " ","'PI'", SuperGetMv("MV_BLKTP06",.F.,"'PI'")) // 06: Produto Intermediario
Private cTipo10		:= If(SuperGetMv("MV_BLKTP10",.F.,"'OI'")== " ","'OI'", SuperGetMv("MV_BLKTP10",.F.,"'OI'")) // 10: Outros Insumos
Private lCpoBZTP	:= SBZ->(ColumnPos("BZ_TIPO")) > 0 .AND. SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SBZ"
Private cAlmTerc	:= GetAlmTerc()

nRecIni := aFaixaRec[1]
nRecFin := aFaixaRec[2]
cAliK200 := aK200[1]

//����������������������������������������������������������Ŀ
//� Chama o PE SPDFIS001 para realizar a troca dos Tipos     �
//������������������������������������������������������������
TrocaTipo()

If nThread >0
	DbUseArea(.T.,'TOPCONN',cAliasTmp,cAliasTmp,.T.,.T.)
	dbUseArea(.T.,'TOPCONN',aK200[2],cAliK200,.T.)
	DbSetIndex(aK200[3])
	DBSetOrder(aK200[4])
	DbUseArea(.T.,'TOPCONN',cAliSumTer,cAliSumTer,.T.)
	DBSetIndex(cAliSumTer+'1')
	DBSetOrder(1)
EndIf

//����������������������������Ŀ
//� Posiciona no RECNO Inicial �
//������������������������������
(cAliasTmp)->(dbGoto(nRecIni))

// PROCLOGATU gravado "na m�o", pois em multi-thread n�o tem IDCV8 preenchido
GravaCV8("6", "MATXSPED", "Bloco K - Thread: "+StrZero(nThread,2)+" - K200|01: Inicio SLD Proprio "+ Alltrim(DtoC(Date())) + " - " + Alltrim(Time()), "", "", "", NIL, cIDCV8MOV)
//��������������������������������������������������������������������������Ŀ
//� Processa Saldo de Propriedade do Informante no Informante: IND_EST = 0   �
//����������������������������������������������������������������������������
cProdAtu := (cAliasTmp)->B9_COD
cClientAtu	:= (cAliasTmp)->(D3E_CLIENT+D3E_LOJA)
aAdd(aProdDeAte,cProdAtu)
While !(cAliasTmp)->(Eof()) .And. !(cAliasTmp)->(Recno()) > nRecFin
	If cProdAtu == (cAliasTmp)->B9_COD
		//������������������������������������������������������������������������Ŀ
		//� Roda a CALCEST apenas quando o produto foi movimentado entre o ultimo  �
		//� fechamento de estoque e a data final de processamento do Bloco K       �
		//��������������������������������������������������������������������������
		If (cAliasTmp)->STATS == "S" .Or. (cAliasTmp)->B9_LOCAL == cLocProc
			nSaldo += CalcEst((cAliasTmp)->B9_COD,(cAliasTmp)->B9_LOCAL,dDataAte+1,Nil,.F.)[1]
		ElseIf (cAliasTmp)->STATS == "N"
			nSaldo += (cAliasTmp)->B9_QINI
		EndIf

		(cAliasTmp)->(dbSkip())
		//������������������������������������������Ŀ
		//� Quando mudar o produto, grava o registro �
		//��������������������������������������������
		If cProdAtu <> (cAliasTmp)->B9_COD .OR. cClientAtu == (cAliasTmp)->(D3E_CLIENT+D3E_LOJA)
			If !nSaldo == 0
				If Empty(cClientAtu)
					cIND_EST := "0"
					cCOD_PART := space(len((cAliK200)->COD_PART))
				Else
					cIND_EST := "2"
					cCOD_PART := "SA1"+cClientAtu
				EndIf

				If (cAliK200)->(MSSeek(cSB9Filial+dtos(dDataAte)+cProdAtu+cIND_EST+cCOD_PART))
					Reclock(cAliK200,.F.)
					(cAliK200)->QTD += nSaldo
					(cAliK200)->(MsUnLock())
				Else
					Reclock(cAliK200,.T.)
					(cAliK200)->FILIAL		:= cSB9Filial
					(cAliK200)->REG			:= "K200"
					(cAliK200)->DT_EST		:= dDataAte
					(cAliK200)->COD_ITEM	:= cProdAtu
					(cAliK200)->QTD			:= nSaldo
					(cAliK200)->IND_EST		:= cIND_EST
					(cAliK200)->COD_PART	:= cCOD_PART
					(cAliK200)->(MsUnLock())
				EndIf
			EndIf
			cClientAtu := (cAliasTmp)->(D3E_CLIENT+D3E_LOJA)
			cProdAtu := (cAliasTmp)->B9_COD
			nSaldo := 0
		EndIf
	EndIf
EndDo

// PROCLOGATU gravado "na m�o", pois em multi-thread n�o tem IDCV8 preenchido
GravaCV8("6", "MATXSPED", "Bloco K - Thread: "+StrZero(nThread,2)+" - K200|02: Inicio SLD Terceiros "+ Alltrim(DtoC(Date())) + " - " + Alltrim(Time()), "", "", "", NIL, cIDCV8MOV)

(cAliasTmp)->(dbGoto(nRecFin))
cProdAtu := (cAliasTmp)->B9_COD

aAdd(aProdDeAte,cProdAtu)

//�������������������������������������������������������������������������Ŀ
//� Processa Saldo DE Terceiros para gravacao de IND_EST 2			        �
//� ----------------------------------------------------------------------- �
//� Tratamento quando unico codigo de produto esteja contido o saldo de  	�
//� terceiros e,possa ter, saldo proprio e ou saldo de terceito				�
//� O processamento fica fora do loop principal pois depende da gravacao do �
//� IND_EST = 0, pois a CALCEST retorna a QTDE somando o saldo DE TERCEIROS �
//���������������������������������������������������������������������������
GetSldTerc("D" ,dDataAte ,aProdDeAte[1] ,aProdDeAte[2] ,cAliK200, cAliSumTer)

//�������������������������������������������������������������������������Ŀ
//� Processa Saldo EM Terceiros para gravacao de IND_EST 2			        �
//� ----------------------------------------------------------------------- �
//� Tratamento quando unico codigo de produto esteja contido o saldo em  	�
//� terceiros e,possa ter, saldo proprio e ou saldo de terceito				�
//� O processamento fica fora do loop principal pois depende da gravacao do �
//� IND_EST = 0, pois a CALCEST retorna a QTDE somando o saldo EM TERCEIROS �
//���������������������������������������������������������������������������
GetSldTerc("E" ,dDataAte ,aProdDeAte[1] ,aProdDeAte[2] ,cAliK200, cAliSumTer)

GravaCV8("6", "MATXSPED", "Bloco K - Thread: "+StrZero(nThread,2)+" - K200|03: Inicio SLD Proprio "+ Alltrim(DtoC(Date())) + " - " + Alltrim(Time()), "", "", "", NIL, cIDCV8MOV)

If nThread >0
	(cAliasTmp)->(dbCloseArea())
	(cAliK200)->(dbCloseArea())
	(cAliSumTer)->(dbCloseArea())
EndIf

// PROCLOGATU gravado "na m�o", pois em multi-thread n�o tem IDCV8 preenchido
GravaCV8("6", "MATXSPED", "Bloco K - Thread: "+StrZero(nThread,2)+" - K200|04: Final Processamento  "+ Alltrim(DtoC(Date())) + " - " + Alltrim(Time()), "", "", "", NIL, cIDCV8MOV)

Return

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � REGK21X        � Autor � Materiais        � Data � 11/08/16 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Funcao responsavel pela gravacao dos Registros K210 e K215  ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cAliK210    = Alias do arquivo de trabalho do K210          ���
���          � cAliK215    = Alias do arquivo de trabalho do K215          ���
���          � dDataDe     = Data Inicial da Apuracao                      ���
���          � dDataAte    = Data Final da Apuracao                        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function REGK21X(cAliK210,cAliK215,dDataDe,dDataAte,lGerLogPro,lRepross)

Local cQuery    := ""
Local cNumSeq   := ""
Local aDesmont  := {}
Local cAliasTmp := ""
Local cNumSoma  := ""
Local nX

Default lGerLogPro := .T.
Default lRepross	 := .T.


//�����������������������������������������������������������������������Ŀ
//�                        OBSERVACAO IMPORTANTE!!!                       �
//� --------------------------------------------------------------------- �
//� A ordenacao dos registros nao pode ser alterada, pois ao processar o  �
//� Reg. K21X espera-se que para cada NUMSEQ de uma desmontagem, primeiro �
//� seja processado o RE7 e posteiormente seus RE7.                       �
//�������������������������������������������������������������������������

If !Empty(cAliK210) .and. !Empty(cAliK210)
	cAliasTmp := CriaTrab(Nil,.F.)
	cNumSoma	 := strzero(0,15)

	//�������������������������������������������Ŀ
	//� Temporario com as Desmontagens do Periodo �
	//���������������������������������������������
	cQuery := "SELECT SD3.D3_FILIAL, SD3.D3_COD, SD3.D3_EMISSAO, SD3.D3_NUMSEQ, SD3.D3_DOC, SD3.D3_CF, Sum(SD3.D3_QUANT) D3_QUANT "
	cQuery += "FROM "+RetSqlName("SD3")+" SD3 "
	cQuery += "JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' "
	cQuery += "		AND SB1.B1_COD = SD3.D3_COD AND SB1.B1_COD NOT LIKE 'MOD%' "
	cQuery += "		AND SB1.B1_CCCUSTO = ' ' "
	cQuery += "		AND SB1.D_E_L_E_T_ = ' ' "
	If lCpoBZTP
		cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += "WHERE SD3.D3_FILIAL = '"+xFilial('SD3')+"' "
	cQuery += "		AND SD3.D3_ESTORNO = ' ' AND SD3.D3_CF IN ('DE7','RE7') "
	cQuery += "		AND SD3.D3_EMISSAO BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"' AND	SD3.D_E_L_E_T_ = ' ' "
	If lCpoBZTP
		cQuery += "		AND "+MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
	Else
		cQuery += "		AND SB1.B1_TIPO "
	EndIf
	cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
	cQuery += "GROUP BY SD3.D3_FILIAL, SD3.D3_COD, SD3.D3_EMISSAO, SD3.D3_NUMSEQ, SD3.D3_DOC, SD3.D3_CF "
	cQuery += "ORDER BY 4,6 DESC"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

	While !(cAliasTmp)->(Eof())
		aDesmont	:= {}

		//�������������������������������������������Ŀ
		//� Armazena o RE7 na posicao 1 do aDesmont   �
		//���������������������������������������������
		If (cAliasTmp)->D3_CF == "RE7"
			aDesmont	:= {{},{}}
			aDesmont[1] := {	(cAliasTmp)->D3_FILIAL,;
								StoD((cAliasTmp)->D3_EMISSAO),;
								(cAliasTmp)->D3_NUMSEQ,;
								(cAliasTmp)->D3_DOC,;
								(cAliasTmp)->D3_COD,;
								(cAliasTmp)->D3_QUANT,;
								(cAliasTmp)->D3_CF}

			cNumSeq := (cAliasTmp)->D3_NUMSEQ
			(cAliasTmp)->(dbSkip())

			//�������������������������������������������Ŀ
			//� Armazena os DE7 na posicao 2 do aDesmont  �
			//���������������������������������������������
			While !(cAliasTmp)->(Eof()) .And. cNumSeq == (cAliasTmp)->D3_NUMSEQ .And. (cAliasTmp)->D3_CF == "DE7"
				Aadd(aDesmont[2],	{(cAliasTmp)->D3_FILIAL,;
									(cAliasTmp)->D3_NUMSEQ,;
									(cAliasTmp)->D3_DOC,;
									(cAliasTmp)->D3_COD,;
									(cAliasTmp)->D3_QUANT,;
									(cAliasTmp)->D3_CF})
				(cAliasTmp)->(dbSkip())
			EndDo
		Else
			(cAliasTmp)->(dbSkip())
		EndIf

		//����������������������������������������������Ŀ
		//� Grava apenas quando existe RE7 e seus DE7's  �
		//������������������������������������������������
		If Len(aDesmont) == 2 .And. Len(aDesmont[2]) > 0

			//�������������������������������������������Ŀ
			//� Grava o Registro K210                     �
			//���������������������������������������������
			Reclock(cAliK210,.T.)
			(cAliK210)->FILIAL			:= aDesmont[1][1]
			(cAliK210)->REG				:= "K210"
			(cAliK210)->DT_INI_OS		:= aDesmont[1][2]
			(cAliK210)->DT_FIN_OS		:= aDesmont[1][2]
			(cAliK210)->COD_DOC_OS		:= aDesmont[1][3]
			(cAliK210)->COD_ITEM_O		:= aDesmont[1][5]
			(cAliK210)->QTD_ORI			:= aDesmont[1][6]
			(cAliK210)->(MsUnLock())
			nRegsto++

			//�������������������������������������������Ŀ
			//� Grava o Registro K215                     �
			//���������������������������������������������
			For nX := 1 To Len(aDesmont[2])
				Reclock(cAliK215,.T.)
				(cAliK215)->FILIAL			:= aDesmont[2][nX][1]
				(cAliK215)->REG				:= "K215"
				(cAliK215)->COD_DOC_OS		:= aDesmont[1][3]
				(cAliK215)->COD_ITEM_D		:= aDesmont[2][nX][4]
				(cAliK215)->QTD_DES			:= aDesmont[2][nX][5]
				(cAliK215)->(MsUnLock())
				nRegsto++
			Next nX
		EndIf
	EndDo
	(cAliasTmp)->(dbCloseArea())
EndIF

// atualiza os registros SD3 que foram processados no periodo
If lGerLogPro
	BlkPRO21x(dDataDe,dDataAte)
EndIf

//----------------------//
// Grava Tabela de Hist //
//----------------------//
If !Empty(cAliK210) .and. !Empty(cAliK210)
	BlkGrvTab(cAliK210,"D3J",aTmpRegK[K210][4],dDataAte,lRepross)
	BlkGrvTab(cAliK215,"D3L",aTmpRegK[K215][4],dDataAte,lRepross)
ENDIF

Return

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � REGK220        � Autor � Materiais        � Data � 28/07/14 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Funcao responsavel pela gravacao do Registro K220           ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cAliasTRB   = Alias do arquivo de trabalho do Bloco         ���
���          � dDataDe     = Data Inicial da Apuracao                      ���
���          � dDataAte    = Data Final da Apuracao                        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function REGK220(cAliK220,dDataDe,dDataAte,lGerLogPro,lRepross)

Local cQuery	:= ""
Local cAliasTmp	:= ""

Default lGerLogPro	:= .T.
Default lRepross	:= .T.

If !Empty(cAliK220)

	cAliasTmp	:= CriaTrab(Nil,.F.)

	cQuery := "SELECT SUM(SD3ORI.D3_QUANT) QUANT, SD3ORI.D3_FILIAL, SD3ORI.D3_EMISSAO, "
	cQuery += "SD3ORI.D3_COD CODORI, SD3DES.D3_COD CODDES, SUM(SD3DES.D3_QUANT) QTDDEST FROM "+RetSqlName("SD3")+" SD3ORI "
	cQuery += "JOIN "+RetSqlName("SD3")+" SD3DES ON SD3ORI.D3_NUMSEQ = SD3DES.D3_NUMSEQ AND "
	cQuery += "SD3DES.D_E_L_E_T_ = ' ' AND SD3DES.D3_ESTORNO = ' ' AND "
	cQuery += "SD3ORI.D3_FILIAL = SD3DES.D3_FILIAL AND SD3DES.D3_CF = 'DE4' "
	cQuery += "JOIN "+RetSqlName("SB1")+" SB1ORI ON SB1ORI.B1_COD = SD3ORI.D3_COD AND "
	cQuery += "SB1ORI.B1_FILIAL = '"+xFilial('SB1')+"' AND SB1ORI.D_E_L_E_T_ = ' ' "
	If lCpoBZTP
		cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZORI ON SBZORI.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZORI.BZ_COD = SB1ORI.B1_COD AND SBZORI.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += "JOIN "+RetSqlName("SB1")+" SB1DES ON SB1DES.B1_COD = SD3DES.D3_COD AND "
	cQuery += "SB1DES.B1_FILIAL = '"+xFilial('SB1')+"' AND SB1DES.D_E_L_E_T_ = ' ' "
	If lCpoBZTP
		cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZDES ON SBZDES.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZDES.BZ_COD = SB1DES.B1_COD AND SBZDES.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += "WHERE SD3ORI.D3_FILIAL = '"+xFilial('SD3')+"' AND SD3ORI.D3_COD <> SD3DES.D3_COD AND "
	cQuery += "SD3ORI.D3_CF = 'RE4' AND SD3ORI.D3_EMISSAO BETWEEN '"+DtoS(dDataDe)+"' "
	cQuery += "AND '"+DtoS(dDataAte)+"' AND "
	cQuery += "SB1ORI.B1_CCCUSTO = ' ' AND SB1ORI.B1_COD NOT LIKE 'MOD%' AND "
	cQuery += "SB1DES.B1_CCCUSTO = ' ' AND SB1DES.B1_COD NOT LIKE 'MOD%' AND "
	If lCpoBZTP
		cQuery += MatIsNull()+"(SBZORI.BZ_TIPO,SB1ORI.B1_TIPO) "
	Else
		cQuery += "SB1ORI.B1_TIPO "
	EndIF
	cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") AND "
	If lCpoBZTP
		cQuery += MatIsNull()+"(SBZDES.BZ_TIPO,SB1DES.B1_TIPO) "
	Else
		cQuery += "SB1DES.B1_TIPO "
	EndIF
	cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") AND "
	cQuery += "SD3ORI.D3_ESTORNO = ' ' AND SD3ORI.D_E_L_E_T_ = ' ' "
	cQuery += "GROUP BY SD3ORI.D3_EMISSAO, SD3ORI.D3_COD, SD3DES.D3_COD, SD3ORI.D3_FILIAL "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

	While !(cAliasTmp)->(Eof())
		Reclock(cAliK220,.T.)
		(cAliK220)->FILIAL			:= (cAliasTmp)->D3_FILIAL
		(cAliK220)->REG				:= "K220"
		(cAliK220)->DT_MOV			:= StoD((cAliasTmp)->D3_EMISSAO)
		(cAliK220)->COD_ITEM_O		:= (cAliasTmp)->CODORI
		(cAliK220)->COD_ITEM_D		:= (cAliasTmp)->CODDES
		(cAliK220)->QTD_ORI			:= (cAliasTmp)->QUANT
		(cAliK220)->QTD_DEST		:= (cAliasTmp)->QTDDEST
		(cAliK220)->(MsUnLock())
		(cAliasTmp)->(dbSkip())
		nRegsto++
	EndDo

	(cAliasTmp)->(dbCloseArea())

ENDIF

// atualiza os registros SD3 que foram processados no periodo
If lGerLogPro
	BlkK220(dDataDe,dDataAte)
EndIf

//----------------------//
// Grava Tabela de Hist //
//----------------------//
If !Empty(cAliK220)
	BlkGrvTab(cAliK220,"D3M",aTmpRegK[K220][4],dDataAte,lRepross)
EndIf
Return



/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � REGK250        � Autor � Materiais        � Data � 28/07/14 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Funcao responsavel pela gravacao do Registro K250           ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cAliasTRB   = Alias do arquivo de trabalho do Bloco         ���
���          � cAliK255    = Alias do arquivo de trabalho do K255          ���
���          � cAli0210    = Alias do arquivo de trabalho do 0210          ���
���          � dDataDe     = Data Inicial da Apuracao                      ���
���          � dDataAte    = Data Final da Apuracao                        ���
���          � lSum        = Data Final da Apuracao                        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function REGK250(cAliK250,cAliK255,cAli0210,dDataDe,dDataAte,lSum,lGerLogPro,lRepross)

Local cAliasTmp	:= CriaTrab(Nil,.F.)
Local cQuery	:= ""

Default lGerLogPro	:= .T.
Default lRepross	:= .T.

If cVersSped <"013"
	cQuery := "SELECT SUM(SD3.D3_QUANT) QUANT, SD3.D3_OP, SD3.D3_COD, SD3.D3_FILIAL, SC2.C2_QUANT QTDORI, SD3.D3_EMISSAO DTDIGIT "
	cQuery += "FROM "+RetSqlName("SD3")+" SD3 "
	cQuery += "JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' AND SB1.B1_COD = SD3.D3_COD AND SB1.D_E_L_E_T_ = ' ' "
	If lCpoBZTP
		cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += "JOIN "+RetSqlName("SC2")+" SC2 ON SD3.D3_OP = SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD "
	cQuery += "AND SC2.C2_FILIAL = '"+xFilial('SC2')+"' AND SC2.D_E_L_E_T_ = ' ' AND SC2.C2_ITEM <> 'OS' "
	cQuery += "AND SC2.C2_PRODUTO = SD3.D3_COD AND SC2.C2_TPPR IN ('E') "
	cQuery += "WHERE SD3.D3_FILIAL = '"+xFilial('SD3')+"' "
	cQuery += "AND SD3.D3_ESTORNO = ' ' "
	cQuery += "AND SD3.D3_OP <> ' ' "
	cQuery += "AND SD3.D3_CF IN ('PR0','PR1') "
	cQuery += "AND SD3.D3_COD NOT LIKE 'MOD%' "
	cQuery += "AND SD3.D3_EMISSAO BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"' "
	cQuery += "AND SD3.D_E_L_E_T_ = ' ' "
	cQuery += "AND SB1.B1_CCCUSTO = ' ' "
	cQuery += "AND "
	If lCpoBZTP
		cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
	Else
		cQuery += "SB1.B1_TIPO "
	EndIf
	cQuery += "	IN ("+cTipo03+","+cTipo04+") "
	cQuery += "GROUP BY SD3.D3_FILIAL, SD3.D3_OP, SD3.D3_COD, SC2.C2_QUANT, SD3.D3_EMISSAO ORDER BY 4,2 "
Else
	cQuery := "SELECT SUM(SD3.D3_QUANT) QUANT,SD3.D3_OP,SD3.D3_COD,SD3.D3_FILIAL,SC2.C2_QUANT QTDORI, MAX(SD3.D3_EMISSAO) DTDIGIT "
	cQuery += "FROM "+RetSqlName("SD3")+" SD3 "
	cQuery += "JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' AND SB1.B1_COD = SD3.D3_COD AND SB1.D_E_L_E_T_ = ' ' "
	If lCpoBZTP
		cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += "JOIN "+RetSqlName("SC2")+" SC2 ON SD3.D3_OP = SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD "
	cQuery += "AND SC2.C2_FILIAL = '"+xFilial('SC2')+"' AND SC2.D_E_L_E_T_ = ' ' AND SC2.C2_ITEM <> 'OS' "
	cQuery += "AND SC2.C2_PRODUTO = SD3.D3_COD AND SC2.C2_TPPR IN ('E') "
	cQuery += "WHERE SD3.D3_FILIAL = '"+xFilial('SD3')+"' "
	cQuery += "AND SD3.D3_ESTORNO = ' ' "
	cQuery += "AND SD3.D3_OP <> ' ' "
	cQuery += "AND SD3.D3_CF IN ('PR0','PR1') "
	cQuery += "AND SD3.D3_COD NOT LIKE 'MOD%' "
	cQuery += "AND SD3.D3_EMISSAO BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"' "
	cQuery += "AND SD3.D_E_L_E_T_ = ' ' "
	cQuery += "AND SB1.B1_CCCUSTO = ' ' "
	cQuery += "AND "
	If lCpoBZTP
		cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
	Else
		cQuery += "SB1.B1_TIPO "
	EndIf
	cQuery += "	IN ("+cTipo03+","+cTipo04+") "
	cQuery += "AND NOT EXISTS( "
	cQuery += "		SELECT 1 FROM "+RetSqlName("SG1")+" SG1 "
	cQuery += "		WHERE SG1.G1_FILIAL = '"+xFilial("SG1")+"' "
	cQuery += "			AND SG1.G1_COD = SC2.C2_PRODUTO "
	cQuery += "			AND SG1.G1_REVINI <= CASE WHEN SC2.C2_REVISAO = ' ' THEN SB1.B1_REVATU ELSE SC2.C2_REVISAO END "
	cQuery += "			AND SG1.G1_REVFIM >= CASE WHEN SC2.C2_REVISAO = ' ' THEN SB1.B1_REVATU ELSE SC2.C2_REVISAO END "
	cQuery += "			AND SG1.G1_QUANT < 0 "
	cQuery += "			AND SG1.G1_INI <= '"+DTOS(dDataDe)+"' "
	cQuery += "			AND SG1.G1_FIM >= '"+DTOS(dDataAte)+"' "
	cQuery += "			AND SG1.D_E_L_E_T_ = ' ' "
	cQuery += "		) "
	cQuery += "GROUP BY SD3.D3_FILIAL, SD3.D3_OP, SD3.D3_COD, SC2.C2_QUANT ORDER BY 4,2 "
EndIf

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

While !(cAliasTmp)->(Eof())
	If REGK255(cAliK255,dDataDe,dDataAte,(cAliasTmp)->D3_OP)
		Reclock(cAliK250,.T.)
		(cAliK250)->FILIAL			:= (cAliasTmp)->D3_FILIAL
		(cAliK250)->REG				:= "K250"
		(cAliK250)->CHAVE          	:= (cAliasTmp)->D3_OP
		(cAliK250)->DT_PROD			:= StoD((cAliasTmp)->DTDIGIT)
		(cAliK250)->COD_ITEM		:= (cAliasTmp)->D3_COD
		(cAliK250)->QTD				:= (cAliasTmp)->QUANT
		(cAliK250)->(MsUnLock())
		nRegsto++
	EndIf
	(cAliasTmp)->(dbSkip())
EndDo

// atualiza os registros SD3 que foram processados no periodo
If lGerLogPro
	BlkPro250(dDataDe,dDataAte)
	BlkPro255(dDataDe,dDataAte)
EndIf

//����������������������������������������������������������Ŀ
//� Gravacao do Registro 0210 com base nas entradas das NF's �
//������������������������������������������������������������
If !(cAliK250)->(Eof())
	REG0210Ter(cAli0210,cAliK250,cAliK255)
EndIf

(cAliasTmp)->(dbCloseArea())

//�����������������������������������������������������������������Ŀ
//� Soma e aglutina produtos e insumos com lancamentos no mesmo dia �
//�������������������������������������������������������������������
If lSum
	SumK250(cAliK250,cAliK255)
EndIf

//----------------------//
// Grava Tabela de Hist //
//----------------------//
BlkGrvTab(cAliK250,"D3N",aTmpRegK[K250][4],dDataAte,lRepross)
BlkGrvTab(cAliK255,"D3O",aTmpRegK[K255][4],dDataAte,lRepross)

Return

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � REGK255        � Autor � Materiais        � Data � 28/07/14 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Funcao responsavel pela gravacao do Registro K255           ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cAliasTRB   = Alias do arquivo de trabalho do Bloco         ���
���          � dDataDe     = Data Inicial da Apuracao                      ���
���          � dDataAte    = Data Final da Apuracao                        ���
���          � cOP         = Numero da Ordem de Producao                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function REGK255(cAliK255,dDataDe,dDataAte,cOP,lGerLogPro,lRepross)

Local cAliasTmp	:= CriaTrab(Nil,.F.)
Local cQuery	:= ""
Local lRet		:= .F.

Default lGerLogPro	:= .T.
Default lRepross	:= .T.

If cVersSped <"013"
	cQuery := "SELECT SUM(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT*-1) "
	cQuery += "WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT) ELSE 0 END) QUANT, "
	cQuery += "SD3.D3_COD, SD3.D3_OP, SD3.D3_EMISSAO DTDIGIT, SD3.D3_FILIAL FROM "+RetSqlName("SD3")+" SD3 "
	cQuery += "JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' AND SB1.B1_COD = SD3.D3_COD AND SB1.D_E_L_E_T_ = ' ' "
	If lCpoBZTP
		cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += "JOIN "+RetSqlName("SC2")+" SC2 ON SD3.D3_OP = SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD "
	cQuery += "AND SC2.C2_FILIAL = '"+xFilial('SC2')+"' AND SC2.D_E_L_E_T_ = ' ' AND SC2.C2_ITEM <> 'OS' AND SC2.C2_TPPR IN ('E') "
	cQuery += "WHERE SD3.D3_FILIAL = '"+xFilial('SD3')+"' AND SD3.D_E_L_E_T_ = ' ' "
	cQuery += "AND SD3.D3_ESTORNO = ' ' AND SD3.D3_OP = '"+ cOP +"' "
	cQuery += "AND (SD3.D3_CF LIKE ('RE%') OR SD3.D3_CF LIKE ('DE%')) AND SB1.B1_CCCUSTO = ' ' "
	cQuery += "AND SB1.B1_COD NOT LIKE 'MOD%' AND D3_EMISSAO BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"' "
	cQuery += "AND SD3.D_E_L_E_T_ = ' ' AND D3_CF <> 'DE1' "
	cQuery += "AND "
	If lCpoBZTP
		cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
	Else
		cQuery += "SB1.B1_TIPO "
	EndIf
	cQuery += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
	cQuery += "GROUP BY SD3.D3_EMISSAO, SD3.D3_OP, SD3.D3_COD, SD3.D3_FILIAL "
	cQuery += "ORDER BY 4,3,2"
Else
	cQuery := "SELECT SUM(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT*-1) "
	cQuery += "WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT) ELSE 0 END) QUANT, "
	cQuery += "SD3.D3_COD, SD3.D3_OP, MAX(SD3.D3_EMISSAO) DTDIGIT, SD3.D3_FILIAL "
	cQuery += "FROM "+RetSqlName("SD3")+" SD3 "
	cQuery += "JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' AND SB1.B1_COD = SD3.D3_COD AND SB1.D_E_L_E_T_ = ' ' "
	If lCpoBZTP
		cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += "JOIN "+RetSqlName("SC2")+" SC2 ON SD3.D3_OP = SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD "
	cQuery += "AND SC2.C2_FILIAL = '"+xFilial('SC2')+"' AND SC2.D_E_L_E_T_ = ' ' AND SC2.C2_ITEM <> 'OS' AND SC2.C2_TPPR IN ('E') "
	cQuery += "WHERE SD3.D3_FILIAL = '"+xFilial('SD3')+"' "
	cQuery += "AND SD3.D3_ESTORNO = ' ' AND SD3.D3_OP = '"+ cOP +"' "
	cQuery += "AND (SD3.D3_CF LIKE ('RE%') OR SD3.D3_CF LIKE ('DE%')) AND SB1.B1_CCCUSTO = ' ' "
	cQuery += "AND SB1.B1_COD NOT LIKE 'MOD%' "
	cQuery += "AND D3_EMISSAO BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"' "
	cQuery += "AND SD3.D3_CF <> 'DE1' "
	cQuery += "AND SD3.D_E_L_E_T_ = ' ' "
	cQuery += "AND "
	If lCpoBZTP
		cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
	Else
		cQuery += "SB1.B1_TIPO "
	EndIf
	cQuery += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
	cQuery += "GROUP BY SD3.D3_OP, SD3.D3_COD, SD3.D3_FILIAL "
	cQuery += "ORDER BY 4,3,2"
Endif

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

If !(cAliasTmp)->(Eof())
	lRet := .T.
EndIf

While !(cAliasTmp)->(Eof())
	Reclock(cAliK255,.T.)
	(cAliK255)->FILIAL		:= (cAliasTmp)->D3_FILIAL
	(cAliK255)->REG			:= "K255"
	(cAliK255)->CHAVE		:= (cAliasTmp)->D3_OP
	(cAliK255)->DT_CONS		:= StoD((cAliasTmp)->DTDIGIT)
	(cAliK255)->COD_ITEM	:= (cAliasTmp)->D3_COD
	(cAliK255)->QTD			:= (cAliasTmp)->QUANT
	(cAliK255)->COD_INS_SU	:= GetSubst((cAliasTmp)->D3_COD,(cAliasTmp)->D3_OP,dDataDe,dDataAte)
	(cAliK255)->(MsUnLock())
	nRegsto++
	(cAliasTmp)->(dbSkip())
EndDo

(cAliasTmp)->(dbCloseArea())

Return lRet

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � REGK27X        � Autor � Materiais        � Data � 11/08/16 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Funcao responsavel pela gravacao dos Registros K270 e K275  ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cAliK270    = Alias do arquivo de trabalho do K270          ���
���          � cAliK275    = Alias do arquivo de trabalho do K275          ���
���          � dDataDe     = Data Inicial da Apuracao                      ���
���          � dDataAte    = Data Final da Apuracao                        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function REGK27X(cAliK270,cAliK275,dDataDe,dDataAte,aProdNeg,cBlKCor,lGerLogPro,lRePross,cAliK280)
Local nX
Local nY
Local lExistK27x := Existblock("REGK27X")
Default aProdNeg   := {}
Default cBlKCor    := " "
Default lGerLogPro := .T.
Default lRepross   := .T.

If cVersSped <"013"
	If !Empty(cAliK270) .and. !Empty(cAliK275)
		If lExistK27x
			Execblock("REGK27X",.F.,.F.,{cAliK270,cAliK275,dDataDe,dDataAte})
		Elseif Len(aProdNeg) > 0
			If cBlKCor == "K235"
				For nX := 1 to Len(aProdNeg)
					Reclock(cAliK275,.T.)
					(cAliK275)->FILIAL				:= aProdNeg[nX,1]
					(cAliK275)->REG					:= "K275"
					(cAliK275)->COD_OP_OS			:= aProdNeg[nX,6]
					(cAliK275)->COD_ITEM			:= aProdNeg[nX,4]
					(cAliK275)->QTD_COR_N			:= ABS(aProdNeg[nX,5])
					(cAliK275)->COD_INS_SU			:= aProdNeg[nX,7]
					(cAliK275)->(MsUnLock())
					nRegsto++
				Next nX
				For nY := 1 to Len(aProdNeg)
					dDataTrat:= GetIniProd(aProdNeg[nY,6])
					If (SC2->(MsSeek(aProdNeg[nY,1]+aProdNeg[nY,6])))
						Reclock(cAliK270,.T.)
						(cAliK270)->FILIAL				:= aProdNeg[nY,1]
						(cAliK270)->REG					:= "K270"
						(cAliK270)->DT_INI_AP			:= Stod(Substr(DtoS(dDataTrat),1,6)+"01")
						(cAliK270)->DT_FIN_AP			:= Stod(Substr(DtoS(dDataTrat),1,6)+SubStr(DtoS(Lastday(dDataTrat,0)),7,8))
						(cAliK270)->COD_OP_OS			:= aProdNeg[nY,6]
						(cAliK270)->COD_ITEM			:= SC2->C2_PRODUTO
						(cAliK270)->ORIGEM				:= "1"
						(cAliK270)->(MsUnLock())
						nRegsto++
					EndIf
				Next nY
			EndIf
		EndIf
	EndIf
Else
	// Busca o maior numseq do periodo para identificar os itens abaixo
	cSeqPer := SequePer (dDataDe,dDataAte)

	// tratamento K250/K255 - Industrializacao efetuada por terceiros
	CorrK25X(cAliK270,cAliK275,dDataDe,dDataAte,lGerLogPro,cAliK280,cSeqPer)

	// tratamento K210/K215 - Desmontagem
	CorrK21X(cAliK270,cAliK275,dDataDe,dDataAte,lGerLogPro,cAliK280,cSeqPer)

	// tratamento K220 - Outras movimentacoes internas entre mercadorias
	CorrK220(cAliK270,cAliK275,dDataDe,dDataAte,lGerLogPro,cAliK280,cSeqPer)

	// tratamento K260 - Reprocessamento/reparo de produto/insuumo
		// sem tratamento

	// tratamento K301 - produ��o conjunta por terceiros
	CorrK301(cAliK270,cAliK275,dDataDe,dDataAte,lGerLogPro,cAliK280,cSeqPer)

	// tratamento K302 - produ��o conjunta por terceiros
	CorrK302(cAliK270,cAliK275,dDataDe,dDataAte,lGerLogPro,cAliK280,cSeqPer)

	If lExistK27x
		Execblock("REGK27X",.F.,.F.,{cAliK270,cAliK275,dDataDe,dDataAte})
	EndIf

	// grava na tabela de historico
	//BlkGrvTab(cAliK270,"",aTmpRegK[K270][4],dDataAte,lRepross)
	//BlkGrvTab(cAliK275,"",aTmpRegK[K275][4],dDataAte,lRepross)
EndIf

Return

/*/{Protheus.doc} CorrK21X
Registros do K270 referente a corre��o do K210/K210.
Onde busca os movimentos internos de desmontagem estornados ou incluidos, apos a geracao do SPED FISCAL.
@author reynaldo
@since 25/10/2018
@version 1.0
@return ${return}, ${return_description}
@param cAliK270, characters, descricao
@param cAliK275, characters, descricao
@param dDataDe, date, descricao
@param dDataAte, date, descricao
@param lGerLogPro, logical, descricao
@param cAliK280, characters, descricao
@type function
/*/
Static Function CorrK21X(cAliK270,cAliK275,dDataDe,dDataAte,lGerLogPro,cAliK280,cSeqPer)

Local cQuery	:= ""
Local cAliasTmp	:= ""
Local cQryRegs	:= ""

Default lGerLogPro	:= .T.

cAliasTmp	:= CriaTrab(Nil,.F.)

cQryRegs += "FROM "+RetSqlName("SD3")+" SD3 "
cQryRegs += "LEFT JOIN "+RetSqlName("D3E")+" D3E ON "
cQryRegs += 		"D3E.D3E_FILIAL = '"+xFilial('D3E')+"' "
cQryRegs +=			"AND D3E_COD	= SD3.D3_COD "
cQryRegs +=			"AND D3E.D_E_L_E_T_ = ' ' "
cQryRegs += "WHERE SD3.D3_FILIAL = '"+xFilial('SD3')+"' "
cQryRegs += 		"AND SD3.D3_CF IN ('DE7','RE7') "
cQryRegs += 		"AND SD3.D3_EMISSAO < '"+DtoS(dDataDe)+"' AND SD3.D3_NUMSEQ > '"+cSeqPer+"' "
cQryRegs +=			"AND SD3.D3_PERBLK IN ('"+space(TamSx3("D3_PERBLK")[1])+"', '"+Left(dTos(dDataAte),6)+"') "
cQryRegs += 		"AND SD3.D_E_L_E_T_ = ' ' "
cQryRegs += 		"AND EXISTS( "
cQryRegs += 		"SELECT 1 FROM "+RetSqlName("SB1")+" SB1 "
If lCpoBZTP
	cQryRegs += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
cQryRegs += 		"WHERE SB1.B1_FILIAL = '"+xFilial('SB1')+"' "
cQryRegs += 			"AND SB1.B1_COD = SD3.D3_COD "
cQryRegs += 			"AND SB1.B1_COD NOT LIKE 'MOD%' "
cQryRegs += 			"AND SB1.B1_CCCUSTO = ' ' "
cQryRegs += 			"AND SB1.D_E_L_E_T_ = ' ' "
cQryRegs += 			"AND "
If lCpoBZTP
	cQryRegs += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
Else
	cQryRegs += "SB1.B1_TIPO "
EndIf
cQryRegs += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
cQryRegs += ") "

// agrupando os registros para gravacao do registro do k270/k275
cQuery := ""
cQuery += "SELECT SD3a.D3_FILIAL, REG, SD3a.D3_COD, MESANOAPUR, SD3a.D3_NUMSEQ, SD3a.D3_DOC, Sum(SD3a.D3_QUANT) D3_QUANT , D3E_CLIENT, D3E_LOJA "
cQuery += "FROM ("
cQuery += "SELECT SD3.D3_FILIAL, SD3.D3_COD, "+ MatiSubStr()+"(SD3.D3_EMISSAO,1,6) MESANOAPUR, SD3.D3_NUMSEQ, SD3.D3_DOC, Coalesce( D3E_CLIENT,'') D3E_CLIENT, Coalesce( D3E_LOJA,'') D3E_LOJA"
cQuery += ", CASE WHEN SD3.D3_FATHER ='F' THEN 'K270' ELSE 'K275' END REG "
cQuery += ", CASE WHEN SD3.D3_CF = 'RE7' THEN (SD3.D3_QUANT*-1) ELSE SD3.D3_QUANT END D3_QUANT "
cQuery += cQryRegs
cQuery += +") SD3a "
cQuery += "GROUP BY SD3a.D3_FILIAL, SD3a.D3_COD, MESANOAPUR, SD3a.D3_NUMSEQ, SD3a.D3_DOC, REG  ,D3E_CLIENT, D3E_LOJA "
cQuery += "ORDER BY 4,6 "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

While !(cAliasTmp)->(Eof())

	If LEFT((cAliasTMP)->REG,4) =="K270"

		if !Empty(cAliK270) .and. !Empty(cAliK275)
			//�������������������������������������������Ŀ
			//� Grava o Registro K270                     �
			//���������������������������������������������
			Reclock(cAliK270,.T.)
			(cAliK270)->FILIAL		 := (cAliasTMP)->D3_FILIAL
			(cAliK270)->REG			 := (cAliasTMP)->REG
			(cAliK270)->CHAVE	       := strzero((cAliK270)->(Recno()),len((cAliK270)->CHAVE))
			(cAliK270)->DT_INI_AP	 := STOD(LEFT((cAliasTMP)->MESANOAPUR,6)+"01")
			(cAliK270)->DT_FIN_AP	 := Lastday((cAliK270)->DT_INI_AP)
			(cAliK270)->COD_OP_OS	 := (cAliasTMP)->D3_NUMSEQ
			(cAliK270)->COD_ITEM		 := (cAliasTMP)->D3_COD
			If (cAliasTMP)->D3_QUANT >0
				(cAliK270)->QTD_COR_P := (cAliasTMP)->D3_QUANT
			Else
				(cAliK270)->QTD_COR_N := (cAliasTMP)->D3_QUANT*-1
			EndIf

			(cAliK270)->ORIGEM		 := "3"
			(cAliK270)->(MsUnLock())
			nRegsto++
		EndIf

		BlkReg280((cAliasTMP)->D3_FILIAL,"K210",LastDay(STOD(LEFT((cAliasTMP)->MESANOAPUR,6)+"01")),dDataDe,(cAliasTmp)->D3_COD,(cAliasTMP)->D3_QUANT,(cAliasTMP)->D3E_CLIENT,(cAliasTMP)->D3E_LOJA,cAliK280)

	Else
		If LEFT((cAliasTMP)->REG,4) =="K275"
			if !Empty(cAliK270) .and. !Empty(cAliK275)
				//�������������������������������������������Ŀ
				//� Grava o Registro K275                     �
				//���������������������������������������������
				Reclock(cAliK275,.T.)
				(cAliK275)->FILIAL		 := (cAliasTMP)->D3_FILIAL
				(cAliK275)->REG			 := (cAliasTMP)->REG
				(cAliK275)->CHAVE			 := strzero((cAliK270)->(Recno()),len((cAliK270)->CHAVE))
				(cAliK275)->COD_ITEM		 := (cAliasTMP)->D3_COD

				If (cAliasTMP)->D3_QUANT >0
					(cAliK275)->QTD_COR_P  := (cAliasTMP)->D3_QUANT
				Else
					(cAliK275)->QTD_COR_N  := (cAliasTMP)->D3_QUANT*-1
				EndIf

				(cAliK275)->COD_INS_SUBST := ""
				(cAliK275)->(MsUnLock())
				BlkReg280((cAliasTMP)->D3_FILIAL,"K215",LastDay(STOD(LEFT((cAliasTMP)->MESANOAPUR,6)+"01")),dDataDe,(cAliasTmp)->D3_COD,(cAliasTMP)->D3_QUANT,(cAliasTMP)->D3E_CLIENT,(cAliasTMP)->D3E_LOJA,cAliK280)

				nRegsto++
			EndIf
		EndIf
	EndIf
	(cAliasTMP)->(dbSkip())
EndDo

(cAliasTmp)->(dbCloseArea())

If lGerLogPro
	// atualiza o periodo de apuracao do bloco K nos registros que foram envolvidos
	cQuery := ""
	cQuery += "UPDATE "+RetSqlName("SD3")+" "
	cQuery += "SET D3_PERBLK = '"+Left(dTos(dDataAte),6)+"' "
	cQuery += "WHERE R_E_C_N_O_ IN ( "
	cQuery += "SELECT SD3.R_E_C_N_O_ "
	cQuery += cQryRegs
	cQuery += +") "
	MATExecQry(cQuery)
EndIf
Return

/*/{Protheus.doc} CorrK220
Registros do K270 referente a corre��o do K220.
Onde busca os movimentos internos de transferencia de produtos estornados ou incluidos, apos a geracao do SPED FISCAL.
@author reynaldo
@since 19/10/2018
@version 1.0
@return ${return}, ${return_description}
@param cAliK270, characters, descricao
@param cAliK275, characters, descricao
@param dDataDe, date, descricao
@param dDataAte, date, descricao
@param lGerLogPro, logical, descricao
@param cAliK280, characters, descricao
@type function
/*/
Static Function CorrK220(cAliK270,cAliK275,dDataDe,dDataAte,lGerLogPro,cAliK280,cSeqPer)
Local cQuery	:= ""
Local cAliasTmp	:= CriaTrab(Nil,.F.)

Default lGerLogPro	:= .T.

cQuery := "SELECT SD3ORI.D3_FILIAL, "+ MatiSubStr()+"(SD3ORI.D3_EMISSAO,1,6) MESANOAPUR, "
cQuery += "SD3ORI.D3_COD CODORI, SUM(SD3ORI.D3_QUANT) QTDORI, "
cQuery += "SD3DES.D3_COD CODDES, SUM(SD3DES.D3_QUANT) QTDDES, "
cQuery += "COALESCE(D3E.D3E_CLient,'')CLIENTE,COALESCE(D3E.D3E_lOJA,'')LOJA, Coalesce (DESTD3E.D3E_CLient,'')ClienteDes, "
cQuery += "COALESCE(DESTD3E.D3E_lOJA,'') LOJADES "
cQuery += "FROM "+RetSqlName("SD3")+" SD3ORI "
cQuery += "JOIN "+RetSqlName("SD3")+" SD3DES ON SD3DES.D3_FILIAL = SD3ORI.D3_FILIAL "
cQuery += "AND SD3DES.D3_NUMSEQ = SD3ORI.D3_NUMSEQ "
cQuery += "AND SD3DES.D3_CF = 'DE4' "
cQuery += "AND SD3DES.D3_PERBLK IN ('"+space(TamSx3("D3_PERBLK")[1])+"', '"+Left(dTos(dDataAte),6)+"') "
cQuery += "AND SD3DES.D_E_L_E_T_ = ' ' "
cQuery += "JOIN "+RetSqlName("SB1")+" SB1ORI ON SB1ORI.B1_FILIAL = '"+xFilial('SB1')+"' "
cQuery += "AND SB1ORI.B1_COD = SD3ORI.D3_COD "
cQuery += "AND SB1ORI.B1_CCCUSTO = ' ' "
cQuery += "AND SB1ORI.B1_COD NOT LIKE 'MOD%' "
cQuery += "AND SB1ORI.D_E_L_E_T_ = ' ' "
cQuery += "LEFT JOIN "+RetSqlName("D3E")+" D3E "
cQuery += "ON  D3E.D3E_FILIAL ='"+xfilial('D3E')+"' "
cQuery += "AND D3E.D3E_COD = SB1ORI.B1_COD "
cQuery += "AND D3E.D_E_L_E_T_= ' ' "
If lCpoBZTP
	cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZORI ON SBZORI.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZORI.BZ_COD = SB1ORI.B1_COD AND SBZORI.D_E_L_E_T_ = ' ' "
EndIf
cQuery += "JOIN "+RetSqlName("SB1")+" SB1DES ON SB1DES.B1_FILIAL = '"+xFilial('SB1')+"' "
cQuery += "AND SB1DES.B1_COD = SD3DES.D3_COD "
cQuery += "AND SB1DES.B1_CCCUSTO = ' ' "
cQuery += "AND SB1DES.B1_COD NOT LIKE 'MOD%' "
cQuery += "AND SB1DES.D_E_L_E_T_ = ' ' "
cQuery += "LEFT JOIN "+RetSQLName('D3E')+" DESTD3E ON  D3E.D3E_FILIAL ='"+xFilial('D3E')+"' "
cQuery += "AND DESTD3E.D3E_COD = SB1DES.B1_COD "
cQuery += "AND DESTD3E.D_E_L_E_T_= ' ' "
If lCpoBZTP
	cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZDES ON SBZDES.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZDES.BZ_COD = SB1DES.B1_COD AND SBZDES.D_E_L_E_T_ = ' ' "
EndIf
cQuery += "WHERE SD3ORI.D3_FILIAL = '"+xFilial('SD3')+"' "
cQuery += "AND SD3ORI.D3_COD <> SD3DES.D3_COD "
cQuery += "AND SD3ORI.D3_CF = 'RE4' "
cQuery += "AND SD3ORI.D3_EMISSAO < '"+DtoS(dDataDe)+"' AND SD3ORI.D3_NUMSEQ > '"+cSeqPer+"' "
cQuery += "AND SD3ORI.D3_PERBLK IN ('"+space(TamSx3("D3_PERBLK")[1])+"', '"+Left(dTos(dDataAte),6)+"') "
cQuery += "AND "
If lCpoBZTP
	cQuery += MatIsNull()+"(SBZORI.BZ_TIPO,SB1ORI.B1_TIPO) "
Else
	cQuery += "SB1ORI.B1_TIPO "
EndIF
cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
cQuery += "AND "
If lCpoBZTP
	cQuery += MatIsNull()+"(SBZDES.BZ_TIPO,SB1DES.B1_TIPO) "
Else
	cQuery += "SB1DES.B1_TIPO "
EndIF
cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
cQuery += "AND SD3ORI.D_E_L_E_T_ = ' ' "
cQuery += "GROUP BY "+ MatiSubStr()+"(SD3ORI.D3_EMISSAO,1,6) , SD3ORI.D3_COD, SD3DES.D3_COD, SD3ORI.D3_FILIAL ,D3E.D3E_CLIENT,D3E.D3E_LOJA,DESTD3E.D3E_CLIENT, "
cQuery += "DESTD3E.D3E_LOJA"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

While !(cAliasTmp)->(Eof())
	if !Empty(cAliK270) .and. !Empty(cAliK275)
		Reclock(cAliK270,.T.)
		(cAliK270)->FILIAL		:= (cAliasTmp)->D3_FILIAL
		(cAliK270)->REG			:= "K270"
		(cAliK270)->CHAVE		:= strzero((cAliK270)->(Recno()),len((cAliK270)->CHAVE))
		(cAliK270)->DT_INI_AP	:= STOD(LEFT((cAliasTMP)->MESANOAPUR,6)+"01")
		(cAliK270)->DT_FIN_AP	:= Lastday((cAliK270)->DT_INI_AP)
		(cAliK270)->COD_OP_OS	:= ""
		(cAliK270)->COD_ITEM	:= (cAliasTmp)->CODORI
		(cAliK270)->QTD_COR_N := (cAliasTmp)->QTDORI
		(cAliK270)->ORIGEM 		:= "5"
		(cAliK270)->(MsUnLock())

		Reclock(cAliK275,.T.)
		(cAliK275)->FILIAL			:= (cAliasTmp)->D3_FILIAL
		(cAliK275)->REG				:= "K275"
		(cAliK275)->CHAVE			:= strzero((cAliK270)->(Recno()),len((cAliK270)->CHAVE))
		(cAliK275)->COD_ITEM		:= (cAliasTmp)->CODDES
		(cAliK275)->QTD_COR_P		:= (cAliasTmp)->QTDDES
		(cAliK275)->COD_INS_SUBST	:= ""
		(cAliK275)->(MsUnLock())
	EndIf
	BlkReg280((cAliasTmp)->D3_FILIAL,"K220",LastDay(STOD(LEFT((cAliasTMP)->MESANOAPUR,6)+"01")),dDataAte,(cAliasTmp)->CODORI,(cAliasTMP)->QTDORI*-1,(cAliasTMP)->CLIENTE,(cAliasTMP)->LOJA,cAliK280)
	BlkReg280((cAliasTmp)->D3_FILIAL,"K220",LastDay(STOD(LEFT((cAliasTMP)->MESANOAPUR,6)+"01")),dDataAte,(cAliasTmp)->CODDES,(cAliasTMP)->QTDDES,(cAliasTMP)->CLIENTEDES,(cAliasTMP)->LOJADES,cAliK280)

	(cAliasTmp)->(dbSkip())
	if !Empty(cAliK270) .and. !Empty(cAliK275)
		nRegsto++
	EndIf
EndDo

(cAliasTmp)->(dbCloseArea())

If lGerLogPro
	// atualiza o periodo de apuracao do bloco K nos registros que foram envolvidos
	cQuery := ""
	cQuery += "UPDATE "+RetSqlName("SD3")+" "
	cQuery += "SET D3_PERBLK = '"+Left(dTos(dDataAte),6)+"' "
	cQuery += "WHERE R_E_C_N_O_ IN ( "
	cQuery += "SELECT SD3ORI.R_E_C_N_O_ "
	cQuery += "FROM "+RetSqlName("SD3")+" SD3ORI "

	cQuery += "JOIN "+RetSqlName("SD3")+" SD3DES ON SD3DES.D3_FILIAL = SD3ORI.D3_FILIAL "
	cQuery += "AND SD3DES.D3_NUMSEQ = SD3ORI.D3_NUMSEQ "
	cQuery += "AND ((SD3ORI.D3_CF = 'RE4' AND SD3DES.D3_CF = 'DE4') "
	cQuery += "OR (SD3ORI.D3_CF = 'DE4' AND SD3DES.D3_CF = 'RE4')) "
	cQuery += "AND SD3DES.D3_PERBLK IN ('"+space(TamSx3("D3_PERBLK")[1])+"', '"+Left(dTos(dDataAte),6)+"') "
	cQuery += "AND SD3DES.D_E_L_E_T_ = ' ' "
	cQuery += "AND EXISTS( "
	cQuery += "SELECT 1 "
	cQuery += "FROM "+RetSqlName("SB1")+" SB1DES "
	If lCpoBZTP
		cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZDES ON SBZDES.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZDES.BZ_COD = SB1DES.B1_COD AND SBZDES.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += "WHERE SB1DES.B1_FILIAL = '"+xFilial('SB1')+"' "
	cQuery += "AND SB1DES.B1_COD = SD3DES.D3_COD "
	cQuery += "AND SB1DES.B1_CCCUSTO = ' ' "
	cQuery += "AND SB1DES.B1_COD NOT LIKE 'MOD%' "
	cQuery += "AND SB1DES.D_E_L_E_T_ = ' ' "
	cQuery += "AND "
	If lCpoBZTP
		cQuery += MatIsNull()+"(SBZDES.BZ_TIPO,SB1DES.B1_TIPO) "
	Else
		cQuery += "SB1DES.B1_TIPO "
	EndIF
	cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
	cQuery += ") "

	cQuery += "WHERE SD3ORI.D3_FILIAL = '"+xFilial('SD3')+"' "
	cQuery += "AND SD3ORI.D3_COD <> SD3DES.D3_COD "
	cQuery += "AND SD3ORI.D3_CF IN ('DE4','RE4') "
	cQuery += "AND SD3ORI.D3_EMISSAO < '"+DtoS(dDataDe)+"' "
	cQuery += "AND SD3ORI.D3_PERBLK IN ('"+space(TamSx3("D3_PERBLK")[1])+"', '"+Left(dTos(dDataAte),6)+"') "
	cQuery += "AND EXISTS( "
	cQuery += "SELECT 1 "
	cQuery += "FROM "+RetSqlName("SB1")+" SB1ORI "
	If lCpoBZTP
		cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZORI ON SBZORI.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZORI.BZ_COD = SB1ORI.B1_COD AND SBZORI.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += "WHERE SB1ORI.B1_FILIAL = '"+xFilial('SB1')+"' "
	cQuery += "AND SB1ORI.B1_COD = SD3ORI.D3_COD "
	cQuery += "AND SB1ORI.B1_CCCUSTO = ' ' "
	cQuery += "AND SB1ORI.B1_COD NOT LIKE 'MOD%' "
	cQuery += "AND SB1ORI.D_E_L_E_T_ = ' ' "
	cQuery += "AND "
	If lCpoBZTP
		cQuery += MatIsNull()+"(SBZORI.BZ_TIPO,SB1ORI.B1_TIPO) "
	Else
		cQuery += "SB1ORI.B1_TIPO "
	EndIf
	cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
	cQuery += ") "
	cQuery += "AND SD3ORI.D_E_L_E_T_ = ' ' "
	cQuery += +") "
	MATExecQry(cQuery)
EndIf

Return

/*/{Protheus.doc} CorrK25X
Registros do K270 referente a corre��o do K250/K255.
Onde busca os movimentos internos de requisicao e produ��o, referente a uma ordem de produ��o
em terceiros, estornados ou incluidos,
apos a geracao do SPED FISCAL.
@author reynaldo
@since 25/10/2018
@version 1.0
@return ${return}, ${return_description}
@param cAliK270, characters, descricao
@param cAliK275, characters, descricao
@param dDataDe, date, descricao
@param dDataAte, date, descricao
@param lGerLogPro, logical, descricao
@param cAliK280, characters, descricao
@type function
/*/
Static Function CorrK25X(cAliK270,cAliK275,dDataDe,dDataAte,lGerLogPro,cAliK280,cSeqPer)

Local cAliasTmp	:= CriaTrab(Nil,.F.)
Local cQryK25X	:= ""
Local cQryK280	:= ""
Local cQryRegs	:= ""
Local nTamChave	:= TamSX3("D3_OP")[1]

Default lGerLogPro	:= .T.

cQryRegs := ""
cQryRegs += "FROM "+RetSqlName("SD3")+" SD3 "
cQryRegs += "JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' "
cQryRegs += "AND SB1.B1_COD = SD3.D3_COD "
cQryRegs += "AND SB1.B1_COD NOT LIKE 'MOD%' "
cQryRegs += "AND SB1.B1_CCCUSTO = ' ' "
cQryRegs += "AND SB1.D_E_L_E_T_ = ' ' "
If lCpoBZTP
	cQryRegs += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
cQryRegs += "JOIN "+RetSqlName("SC2")+" SC2 ON SD3.D3_OP = SC2.C2_NUM "+ MatiConcat()+" SC2.C2_ITEM "+ MatiConcat()+" SC2.C2_SEQUEN "+ MatiConcat()+" SC2.C2_ITEMGRD "
cQryRegs += "AND SC2.C2_FILIAL = '"+xFilial('SC2')+"' "
cQryRegs += "AND SC2.D_E_L_E_T_ = ' ' "
cQryRegs += "AND SC2.C2_ITEM <> 'OS' "
cQryRegs += "AND SC2.C2_TPPR IN ('E') "
cQryRegs += "WHERE SD3.D3_FILIAL = '"+xFilial('SD3')+"' "
cQryRegs += "AND SD3.D3_EMISSAO < '"+DtoS(dDataDe)+"' AND SD3.D3_NUMSEQ > '"+cSeqPer+"' "
cQryRegs += "AND SD3.D3_PERBLK IN ('"+space(TamSx3("D3_PERBLK")[1])+"', '"+Left(dTos(dDataAte),6)+"') "
cQryRegs += "AND SD3.D_E_L_E_T_ = ' ' "
cQryRegs += "AND ((SD3.D3_CF IN ('PR0','PR1','ER0','ER1')  "
cQryRegs += "AND "
If lCpoBZTP
	cQryRegs += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
Else
	cQryRegs += "SB1.B1_TIPO "
EndIf
cQryRegs += "IN ("+cTipo03+","+cTipo04+") ) "
cQryRegs += "OR ((SD3.D3_CF LIKE ('RE%') OR SD3.D3_CF LIKE ('DE%') ) "
cQryRegs += "AND "
If lCpoBZTP
	cQryRegs += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
Else
	cQryRegs += "SB1.B1_TIPO "
EndIf
cQryRegs += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "

cQryRegs += ") )"
cQryRegs += "AND NOT EXISTS( "
cQryRegs += "SELECT 1 FROM "+RetSqlName("SD4")+" SD4 "
cQryRegs += "WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"' "
cQryRegs += "AND SD4.D4_OP = SD3.D3_OP "
cQryRegs += "AND SD4.D4_PRODUTO = SC2.C2_PRODUTO "
cQryRegs += "AND SD4.D4_QTDEORI < 0 "
cQryRegs += "AND SD4.D_E_L_E_T_ = ' ' "
cQryRegs += ") "

//
// Selecao dos movimentos internos (requisicoes/producao) executados apos a apuracao do bloco k
//
cQryK280 := ""
cQryK280 += "SELECT (CASE WHEN SD3.D3_CF = 'PR1' THEN 'K270' "
cQryK280 += "WHEN SD3.D3_CF = 'PR0' THEN 'K270' "
cQryK280 += "WHEN SD3.D3_CF = 'ER0' THEN 'K270' "
cQryK280 += "WHEN SD3.D3_CF = 'ER1' THEN 'K270' "
cQryK280 += "ELSE 'K275' END "
cQryK280 += ")REG, SD3.D3_FILIAL, SD3.D3_OP, SD3.D3_COD, "+ MatiSubStr()+"(SD3.D3_EMISSAO,1,6) MESANOAPUR, D3_FORNDOC, D3_LOJADOC, "
cQryK280 += "(CASE WHEN SD3.D3_CF LIKE 'PR%' THEN SD3.D3_QUANT "
cQryK280 += "WHEN SD3.D3_CF LIKE 'DE%' THEN SD3.D3_QUANT "
cQryK280 += "ELSE (SD3.D3_QUANT*-1) END) D3_QUANT "
cQryK280 += cQryRegs + " "

if !Empty(cAliK270) .and. !Empty(cAliK275)
	//
	// Agrupamento dos movimentos internos (requisicoes/producao) executados apos a apuracao do bloco k para correcao do K250
	//
	cQryK25X := ""
	cQryK25X += "SELECT D3_FILIAL, REG, D3_OP, D3_COD, MESANOAPUR, SUM(D3_QUANT) D3_QUANT "
	cQryK25X += "FROM ("
	cQryK25X += cQryK280 + ") SD3MOV "
	cQryK25X += "GROUP BY D3_FILIAL, REG, D3_OP, D3_COD, MESANOAPUR "
	cQryK25X += "ORDER BY 4,2 "

	cQuery := ChangeQuery(cQryK25X)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

	While !(cAliasTmp)->(Eof())

		If Left((cAliasTMP)->REG,4) == 'K270'
			Reclock(cAliK270,.T.)
			(cAliK270)->FILIAL		:= (cAliasTmp)->D3_FILIAL
			(cAliK270)->REG			:= "K270"
			(cAliK270)->CHAVE		:= strzero((cAliK270)->(Recno()),nTamChave)
			(cAliK270)->DT_INI_AP	:= STOD(LEFT((cAliasTMP)->MESANOAPUR,6)+"01")
			(cAliK270)->DT_FIN_AP	:= Lastday((cAliK270)->DT_INI_AP)
			(cAliK270)->COD_OP_OS	:= (cAliasTmp)->D3_OP
			(cAliK270)->COD_ITEM	:= (cAliasTmp)->D3_COD
			If (cAliasTmp)->D3_QUANT >0
				(cAliK270)->QTD_COR_P := (cAliasTmp)->D3_QUANT
			Else
				(cAliK270)->QTD_COR_N := (cAliasTmp)->D3_QUANT*-1
			EndIf
			(cAliK270)->ORIGEM 		:= "2"

			(cAliK270)->(MsUnLock())
		Else
			If Left((cAliasTMP)->REG,4) == 'K275'
				Reclock(cAliK275,.T.)
				(cAliK275)->FILIAL			:= (cAliasTmp)->D3_FILIAL
				(cAliK275)->REG				:= "K275"
				(cAliK275)->CHAVE			:= strzero((cAliK270)->(Recno()),nTamChave)
				(cAliK275)->COD_ITEM		:= (cAliasTmp)->D3_COD
				If (cAliasTmp)->D3_QUANT >0
					(cAliK275)->QTD_COR_N := (cAliasTmp)->D3_QUANT
				Else
					(cAliK275)->QTD_COR_P := (cAliasTmp)->D3_QUANT*-1
				EndIf
				(cAliK275)->COD_INS_SUBST	:= ""
				(cAliK275)->(MsUnLock())
			EndIf
		EndIf
		(cAliasTmp)->(dbSkip())
		nRegsto++
	EndDo

	(cAliasTmp)->(dbCloseArea())
ENDIF

If lGerLogPro
	// atualiza o periodo de apuracao do bloco K nos registros que foram envolvidos
	cQuery := ""
	cQuery += "UPDATE "+RetSqlName("SD3")+" "
	cQuery += "SET D3_PERBLK = '"+Left(dTos(dDataAte),6)+"' "
	cQuery += "WHERE R_E_C_N_O_ IN ( "
	cQuery += "SELECT SD3.R_E_C_N_O_ "
	cQuery += cQryRegs
	cQuery += +") "
	MATExecQry(cQuery)
EndIf

//
// tratamento para geracao dos registros do K280
//
cQuery := ChangeQuery(cQryK280)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

While !(cAliasTmp)->(Eof())
	BlkReg280((cAliasTmp)->D3_FILIAL,"K250",LastDay(STOD(LEFT((cAliasTMP)->MESANOAPUR,6)+"01")),dDataAte,(cAliasTmp)->D3_COD,(cAliasTMP)->D3_QUANT,(cAliasTMP)->D3_FORNDOC,(cAliasTMP)->D3_LOJADOC,cAliK280)

	(cAliasTmp)->(dbSkip())
EndDo

(cAliasTmp)->(dbCloseArea())

Return

/*{Protheus.doc} CorrK301
Registros do K270 referente a corre��o do K301.
Onde busca os movimentos de produ��o, referente a uma ordem de produ��o com
 estrutura negativa em terceiros, estornados ou incluidos, apos a geracao
 do SPED FISCAL.
@author reynaldo
@since 25/10/2018
@version 1.0
@return ${return}, ${return_description}
@param cAliK270, characters, descricao
@param cAliK275, characters, descricao
@param dDataDe, date, descricao
@param dDataAte, date, descricao
@param lGerLogPro, logical, descricao
@param cAliK280, characters, descricao
@type function
/*/
Static Function CorrK301(cAliK270,cAliK275,dDataDe,dDataAte,lGerLogPro,cAliK280,cSeqPer)

Local cAliasTmp	:= CriaTrab(Nil,.F.)
Local cQryK301	:= ""
Local cQryK280	:= ""
Local cQuery	:= ""
Local cQryRegs	:= ""
Local nTamChave	:= TamSX3("D3_OP")[1]

Default lGerLogPro	:= .T.

cQryRegs := ""
cQryRegs += "FROM "+RetSqlName("SD3")+" SD3 "
cQryRegs += "JOIN "+RetSqlName("SC2")+" SC2 ON SD3.D3_OP = SC2.C2_NUM" + MatiConcat()+"SC2.C2_ITEM" + MatiConcat()+"SC2.C2_SEQUEN" + MatiConcat()+"SC2.C2_ITEMGRD "
cQryRegs += "AND SC2.C2_FILIAL = '"+xFilial('SC2')+"' "
cQryRegs += "AND SC2.C2_ITEM <> 'OS' "
cQryRegs += "AND SC2.C2_TPPR = 'E' "
cQryRegs += "AND SC2.D_E_L_E_T_ = ' ' "
cQryRegs += "WHERE SD3.D3_FILIAL = '"+xFilial('SD3')+"' "
cQryRegs += "AND SD3.D3_CF IN ('PR0','PR1','ER0','ER1','DE1','RE1')  "
cQryRegs += "AND SD3.D3_EMISSAO < '"+DtoS(dDataDe)+"' AND SD3.D3_NUMSEQ > '"+cSeqPer+"' "
cQryRegs += "AND SD3.D3_PERBLK IN ('"+space(TamSx3("D3_PERBLK")[1])+"', '"+Left(dTos(dDataAte),6)+"') "
cQryRegs += "AND SD3.D_E_L_E_T_ = ' ' "
cQryRegs += "AND EXISTS( "
cQryRegs += 		"SELECT 1 FROM "+RetSqlName("SB1")+" SB1 "
If lCpoBZTP
	cQryRegs += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
cQryRegs += 		"WHERE SB1.B1_FILIAL = '"+xFilial('SB1')+"' "
cQryRegs += 			"AND SB1.B1_COD = SD3.D3_COD "
cQryRegs += 			"AND SB1.B1_COD NOT LIKE 'MOD%' "
cQryRegs += 			"AND SB1.B1_CCCUSTO = ' ' "
cQryRegs += 			"AND SB1.D_E_L_E_T_ = ' ' "
cQryRegs += 			"AND "
If lCpoBZTP
	cQryRegs += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
Else
	cQryRegs += "SB1.B1_TIPO "
EndIf
cQryRegs += "IN ("+cTipo03+","+cTipo04+") "
cQryRegs += ") "
cQryRegs += "AND EXISTS( "
cQryRegs += "SELECT 1 FROM "+RetSqlName("SD4")+" SD4 "
cQryRegs += "WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"' "
cQryRegs += "AND SD4.D4_OP = SD3.D3_OP "
cQryRegs += "AND SD4.D4_PRODUTO = SC2.C2_PRODUTO "
cQryRegs += "AND SD4.D4_QTDEORI < 0 "
cQryRegs += "AND SD4.D_E_L_E_T_ = ' ' "
cQryRegs += ") "

//
// Selecao dos movimentos internos (producao) executados apos a apuracao do bloco k
//
cQryK280 := ""
cQryK280 += "SELECT SD3.D3_FILIAL, SD3.D3_OP, SD3.D3_COD, "+ MatiSubStr()+"(SD3.D3_EMISSAO,1,6) MESANOAPUR, D3_FORNDOC, D3_LOJADOC "
cQryK280 += ",CASE WHEN SD3.D3_CF = 'PR0' THEN SD3.D3_QUANT "
cQryK280 += 		"WHEN SD3.D3_CF = 'PR1' THEN SD3.D3_QUANT "
cQryK280 += 		"WHEN SD3.D3_CF = 'DE1' THEN SD3.D3_QUANT "
cQryK280 += 		"ELSE (SD3.D3_QUANT*-1) END D3_QUANT "
cQryK280 += cQryRegs

//
// Agrupamento dos movimentos internos (requisicoes/producao) executados apos a apuracao do bloco k para correcao do K301
//
cQryK301 := ""
cQryK301 += "SELECT D3_FILIAL, D3_OP, D3_COD, MESANOAPUR, SUM(D3_QUANT) D3_QUANT "
cQryK301 += "FROM ("
cQryK301 += cQryK280
cQryK301 += ") SD3MOV "
cQryK301 += "GROUP BY D3_FILIAL, D3_OP, D3_COD, MESANOAPUR "
cQryK301 += "ORDER BY 4,2 "

If !Empty(cAliK270)
	cQuery := ChangeQuery(cQryK301)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

	While !(cAliasTmp)->(Eof())

		Reclock(cAliK270,.T.)
		(cAliK270)->FILIAL		:= (cAliasTmp)->D3_FILIAL
		(cAliK270)->REG			:= "K270"
		(cAliK270)->CHAVE		:= strzero((cAliK270)->(Recno()),nTamChave)
		(cAliK270)->DT_INI_AP	:= STOD(LEFT((cAliasTMP)->MESANOAPUR,6)+"01")
		(cAliK270)->DT_FIN_AP	:= Lastday((cAliK270)->DT_INI_AP)
		(cAliK270)->COD_OP_OS	:= (cAliasTmp)->D3_OP
		(cAliK270)->COD_ITEM	:= (cAliasTmp)->D3_COD
		If (cAliasTmp)->D3_QUANT >0
			(cAliK270)->QTD_COR_P := (cAliasTmp)->D3_QUANT
		Else
			(cAliK270)->QTD_COR_N := (cAliasTmp)->D3_QUANT*-1
		EndIf
		(cAliK270)->ORIGEM 		:= "8"
		(cAliK270)->(MsUnLock())
		(cAliasTmp)->(dbSkip())
		nRegsto++
	EndDo

	(cAliasTmp)->(dbCloseArea())
EndIf


If lGerLogPro
	// atualiza o periodo de apuracao do bloco K nos registros que foram envolvidos
	cQuery := ""
	cQuery += "UPDATE "+RetSqlName("SD3")+" "
	cQuery += "SET D3_PERBLK = '"+Left(dTos(dDataAte),6)+"' "
	cQuery += "WHERE R_E_C_N_O_ IN ( "
	cQuery += "SELECT SD3.R_E_C_N_O_ "
	cQuery += cQryRegs
	cQuery += +") "
	MATExecQry(cQuery)
EndIf

//
// tratamento para geracao dos registros do K280
//
cQuery := ChangeQuery(cQryK280)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

While !(cAliasTmp)->(Eof())
	BlkReg280((cAliasTmp)->D3_FILIAL,"K301",LastDay(STOD(LEFT((cAliasTMP)->MESANOAPUR,6)+"01")),dDataAte,(cAliasTmp)->D3_COD,(cAliasTMP)->D3_QUANT,(cAliasTMP)->D3_FORNDOC,(cAliasTMP)->D3_LOJADOC,cAliK280)

	(cAliasTmp)->(dbSkip())
EndDo

(cAliasTmp)->(dbCloseArea())

Return

/*/{Protheus.doc} CorrK302
Registros do K270 referente a corre��o do K302.
Onde busca os movimentos de requsicao, referente a uma ordem de produ��o com
 estrutura negativa em terceiros, estornados ou incluidos, apos a geracao
 do SPED FISCAL.
@author reynaldo
@since 25/10/2018
@version 1.0
@return ${return}, ${return_description}
@param cAliK270, characters, descricao
@param cAliK275, characters, descricao
@param dDataDe, date, descricao
@param dDataAte, date, descricao
@param lGerLogPro, logical, descricao
@param cAliK280, characters, descricao
@type function
/*/
Static Function CorrK302(cAliK270,cAliK275,dDataDe,dDataAte,lGerLogPro,cAliK280,cSeqPer)

Local cAliasTmp	:= CriaTrab(Nil,.F.)
Local cQryK302	:= ""
Local cQryK280	:= ""
Local cQuery	:= ""
Local cQryRegs	:= ""
Local nTamChave	:= TamSX3("D3_OP")[1]

Default lGerLogPro	:= .T.

cQryRegs := ""
cQryRegs += "FROM "+RetSqlName("SD3")+" SD3 "
cQryRegs += "JOIN "+RetSqlName("SC2")+" SC2 ON SD3.D3_OP = SC2.C2_NUM" + MatiConcat()+"SC2.C2_ITEM" + MatiConcat()+"SC2.C2_SEQUEN" + MatiConcat()+"SC2.C2_ITEMGRD "
cQryRegs += "AND SC2.C2_FILIAL = '"+xFilial('SC2')+"' "
cQryRegs += "AND SC2.C2_ITEM <> 'OS' "
cQryRegs += "AND SC2.C2_TPPR = 'E' "
cQryRegs += "AND SC2.D_E_L_E_T_ = ' ' "
cQryRegs += "WHERE SD3.D3_FILIAL = '"+xFilial('SD3')+"' "
cQryRegs += "AND (SD3.D3_CF NOT LIKE 'PR%' AND SD3.D3_CF NOT LIKE 'ER%' ) "
cQryRegs += "AND SD3.D3_EMISSAO < '"+DtoS(dDataDe)+"' AND SD3.D3_NUMSEQ > '"+cSeqPer+"' "
cQryRegs += "AND SD3.D3_PERBLK IN ('"+space(TamSx3("D3_PERBLK")[1])+"', '"+Left(dTos(dDataAte),6)+"') "
cQryRegs += "AND SD3.D_E_L_E_T_ = ' ' "
cQryRegs += "AND EXISTS( "
cQryRegs += 		"SELECT 1 FROM "+RetSqlName("SB1")+" SB1 "
If lCpoBZTP
	cQryRegs += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
cQryRegs += 		"WHERE SB1.B1_FILIAL = '"+xFilial('SB1')+"' "
cQryRegs += 			"AND SB1.B1_COD = SD3.D3_COD "
cQryRegs += 			"AND SB1.B1_COD NOT LIKE 'MOD%' "
cQryRegs += 			"AND SB1.B1_CCCUSTO = ' ' "
cQryRegs += 			"AND SB1.D_E_L_E_T_ = ' ' "
cQryRegs += 			"AND "
If lCpoBZTP
	cQryRegs += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
Else
	cQryRegs += "SB1.B1_TIPO "
EndIf
cQryRegs += "IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
cQryRegs += ") "
cQryRegs += "AND EXISTS( "
cQryRegs += "SELECT 1 FROM "+RetSqlName("SD4")+" SD4 "
cQryRegs += "WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"' "
cQryRegs += "AND SD4.D4_OP = SD3.D3_OP "
cQryRegs += "AND SD4.D4_PRODUTO = SC2.C2_PRODUTO "
cQryRegs += "AND SD4.D4_QTDEORI < 0 "
cQryRegs += "AND SD4.D_E_L_E_T_ = ' ' "
cQryRegs += ") "
cQryRegs += "AND EXISTS( "
cQryRegs += "SELECT 1 FROM "+RetSqlName("SD4")+" SD4 "
cQryRegs += "WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"' "
cQryRegs += "AND SD4.D4_OP = SD3.D3_OP "
cQryRegs += "AND SD4.D4_PRODUTO = SC2.C2_PRODUTO "
cQryRegs += "AND SD4.D4_COD = SD3.D3_COD "
cQryRegs += "AND SD4.D4_QTDEORI > 0 "
cQryRegs += "AND SD4.D_E_L_E_T_ = ' ' "
cQryRegs += ") "

cQryK280 := ""
cQryK280 += "SELECT SD3.D3_FILIAL, SD3.D3_OP, SD3.D3_COD, "+ MatiSubStr()+"(SD3.D3_EMISSAO,1,6) MESANOAPUR, D3_FORNDOC, D3_LOJADOC  "
cQryK280 += ",CASE WHEN SD3.D3_CF = 'PR0' THEN SD3.D3_QUANT "
cQryK280 += 		"WHEN SD3.D3_CF = 'PR1' THEN SD3.D3_QUANT "
cQryK280 += 		"WHEN SD3.D3_CF = 'DE1' THEN SD3.D3_QUANT "
cQryK280 +=			"WHEN SD3.D3_CF = 'DE5' THEN SD3.D3_QUANT "
cQryK280 += 		"ELSE (SD3.D3_QUANT*-1) END D3_QUANT "
cQryK280 += cQryRegs

cQryK302 := ""
cQryK302 += "SELECT D3_FILIAL, D3_OP, D3_COD, MESANOAPUR, SUM(D3_QUANT) D3_QUANT "
cQryK302 += "FROM ("
cQryK302 += cQryK280
cQryK302 += ") SD3MOV "
cQryK302 += "GROUP BY D3_FILIAL, D3_OP, D3_COD, MESANOAPUR "
cQryK302 += "ORDER BY 4,2 "

If !Empty(cAliK270)
	cQuery := ChangeQuery(cQryK302)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

	While !(cAliasTmp)->(Eof())

		Reclock(cAliK270,.T.)
		(cAliK270)->FILIAL		:= (cAliasTmp)->D3_FILIAL
		(cAliK270)->REG			:= "K270"
		(cAliK270)->CHAVE		:= strzero((cAliK270)->(Recno()),nTamChave)
		(cAliK270)->DT_INI_AP	:= STOD(LEFT((cAliasTMP)->MESANOAPUR,6)+"01")
		(cAliK270)->DT_FIN_AP	:= Lastday((cAliK270)->DT_INI_AP)
		(cAliK270)->COD_OP_OS	:= (cAliasTmp)->D3_OP
		(cAliK270)->COD_ITEM	:= (cAliasTmp)->D3_COD
		If (cAliasTmp)->D3_QUANT >0
			(cAliK270)->QTD_COR_P := (cAliasTmp)->D3_QUANT
		Else
			(cAliK270)->QTD_COR_N := (cAliasTmp)->D3_QUANT*-1
		EndIf
		(cAliK270)->ORIGEM 		:= "9"
		(cAliK270)->(MsUnLock())
		(cAliasTmp)->(dbSkip())
		nRegsto++
	EndDo

	(cAliasTmp)->(dbCloseArea())
EndIf

If lGerLogPro
	// atualiza o periodo de apuracao do bloco K nos registros que foram envolvidos
	cQuery := ""
	cQuery += "UPDATE "+RetSqlName("SD3")+" "
	cQuery += "SET D3_PERBLK = '"+Left(dTos(dDataAte),6)+"' "
	cQuery += "WHERE R_E_C_N_O_ IN ( "
	cQuery += "SELECT SD3.R_E_C_N_O_ "
	cQuery += cQryRegs
	cQuery += +") "
	MATExecQry(cQuery)
EndIf

//
// tratamento para geracao dos registros do K280
//
cQuery := ChangeQuery(cQryK280)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

While !(cAliasTmp)->(Eof())
	BlkReg280((cAliasTmp)->D3_FILIAL,"K302",LastDay(STOD(LEFT((cAliasTMP)->MESANOAPUR,6)+"01")),dDataAte,(cAliasTmp)->D3_COD,(cAliasTMP)->D3_QUANT,(cAliasTMP)->D3_FORNDOC,(cAliasTMP)->D3_LOJADOC,cAliK280)

	(cAliasTmp)->(dbSkip())
EndDo

(cAliasTmp)->(dbCloseArea())

Return

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � REGK280        � Autor � Materiais        � Data � 11/08/16 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Funcao responsavel pela gravacao do Registro K280           ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cAliK280    = Alias do arquivo de trabalho do K280          ���
���          � dDataDe     = Data Inicial da Apuracao                      ���
���          � dDataAte    = Data Final da Apuracao                        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function REGK280(cAliK280,dDataDe,dDataAte,lGerLogPro,lRePross)

DEFAULT lGerLogPro := .T.
DEFAULT lRepross := .T.

(cAliK280)->(dbGoTop())
While !(cAliK280)->(Eof())
	If (cAliK280)->QTD_COR_P==0 .And. (cAliK280)->QTD_COR_N==0
		Reclock(cAliK280,.F.)
		dbDelete()
		(cAliK280)->(MsUnlock())
		nRegsto--
	EndIf
	(cAliK280)->(DbSkip())
End

If Existblock("REGK280")
	Execblock("REGK280",.F.,.F.,{cAliK280,dDataDe,dDataAte})
EndIf

Return
/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � SumK250        � Autor � Materiais        � Data � 23/12/15 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Funcao responsavel pela gravacao do Registro K255           ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cAliK250    = Alias do arquivo de trabalho do K250          ���
���          � cAliK255    = Alias do arquivo de trabalho do K255          ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function SumK250(cAliK250,cAliK255)

Local aK250		:= {}
Local aDocs		:= {}
Local cChave	:= "000000"
Local cSeek		:= ""
Local nFound	:= 0
Local nX

DbSelectArea(cAliK250)
DbSetOrder(2) // FILIAL+DT_PROD+COD_ITEM
dbGoTop()

While !(cAliK250)->(Eof())
	cSeek := (cAliK250)->(FILIAL+DtoS(DT_PROD)+COD_ITEM)
	While (cAliK250)->(FILIAL+DtoS(DT_PROD)+COD_ITEM) == cSeek

		//����������������������������������������������������������Ŀ
		//� Aglutina os registros                                    �
		//������������������������������������������������������������
		nFound := 0
		nFound := AScan(aK250,{|x| x[1] == (cAliK250)->FILIAL .And. x[3] ==(cAliK250)->DT_PROD .And. x[4] == (cAliK250)->COD_ITEM})
		If nFound == 0
			cChave := Soma1(cChave)
			Aadd(aK250,{(cAliK250)->FILIAL,cChave,(cAliK250)->DT_PROD,(cAliK250)->COD_ITEM,(cAliK250)->QTD})
		Else
			aK250[nFound,5] += (cAliK250)->QTD
		EndIf

		//����������������������������������������������������������Ŀ
		//� Guarda os documentos                                     �
		//������������������������������������������������������������
		nFound := 0
		nFound := AScan(aDocs,{|x| x[1] == (cAliK250)->CHAVE})
		If nFound == 0
			Aadd(aDocs,{(cAliK250)->CHAVE,cChave,(cAliK250)->COD_ITEM})
		EndIf

		//����������������������������������������������������������Ŀ
		//� Apaga o Registro                                         �
		//������������������������������������������������������������
		Reclock(cAliK250,.F.)
		dbDelete()
		nRegsto--
		(cAliK250)->(MsUnlock())
		(cAliK250)->(dbSkip())
	EndDo
EndDo

//����������������������������������������������������������Ŀ
//� Grava K250 aglutinado                                    �
//������������������������������������������������������������
For nX := 1 to Len(aK250)
	Reclock(cAliK250,.T.)
	(cAliK250)->FILIAL				:= aK250[nX,1]
	(cAliK250)->REG					:= "K250"
	(cAliK250)->CHAVE            	:= aK250[nX,2]
	(cAliK250)->DT_PROD				:= aK250[nX,3]
	(cAliK250)->COD_ITEM			:= aK250[nX,4]
	(cAliK250)->QTD					:= aK250[nX,5]
	(cAliK250)->(MsUnLock())
	nRegsto++
Next nX

//����������������������������������������������������������Ŀ
//� Aglutina K255                                            �
//������������������������������������������������������������
SumK255(aDocs,cAliK255)

(cAliK250)->(DbSetOrder(1))
(cAliK255)->(DbSetOrder(1))

Return

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � SumK255        � Autor � Materiais        � Data � 23/12/15 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Funcao responsavel pela gravacao do Registro K255           ���
��������������������������������������������������������������������������Ĵ��
���Parametros� aDocs       = Array com conversao da chave gerada           ���
���          � cAliK255    = Alias do arquivo de trabalho do K255          ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function SumK255(aDocs,cAliK255)

Local aK255		:= {}
Local cSeek		:= ""
Local cChave	:= ""
Local nFound	:= 0
Local nX
Local cPrdK250PA:= ""

DbSelectArea(cAliK255)
DbSetOrder(2) // FILIAL+DT_CONS+COD_ITEM
dbGoTop()

While !(cAliK255)->(Eof())
	cSeek := (cAliK255)->(FILIAL+DtoS(DT_CONS)+COD_ITEM)
	While (cAliK255)->(FILIAL+DtoS(DT_CONS)+COD_ITEM) == cSeek

		//����������������������������������������������������������Ŀ
		//� Converte a chave                                         �
		//������������������������������������������������������������
		nFound := 0
		nFound := AScan(aDocs, {|x| x[1] == (cAliK255)->CHAVE})
		cChave := aDocs[nFound,2]
		cPrdK250PA:= aDocs[nFound,3]

		//����������������������������������������������������������Ŀ
		//� Aglutina os registros                                    �
		//������������������������������������������������������������
		nFound := 0
		nFound := AScan(aK255,{|x| x[1] == (cAliK255)->FILIAL .And. x[3] ==(cAliK255)->DT_CONS .And. x[4] == COD_ITEM .And. x[6] == cPrdK250PA .And. x[7] == (cAliK255)->COD_INS_SU})
		If nFound == 0
			Aadd(aK255,{(cAliK255)->FILIAL,cChave,(cAliK255)->DT_CONS,(cAliK255)->COD_ITEM,(cAliK255)->QTD,cPrdK250PA,(cAliK255)->COD_INS_SU})
		Else
			aK255[nFound,5] += (cAliK255)->QTD
		EndIf

		//����������������������������������������������������������Ŀ
		//� Apaga o Registro                                         �
		//������������������������������������������������������������
		Reclock(cAliK255,.F.)
		dbDelete()
		nRegsto--
		(cAliK255)->(MsUnlock())
		(cAliK255)->(dbSkip())
	EndDo
EndDo

//����������������������������������������������������������Ŀ
//� Grava K250 aglutinado                                    �
//������������������������������������������������������������
For nX := 1 to Len(aK255)
	Reclock(cAliK255,.T.)
	(cAliK255)->FILIAL				:= aK255[nX,1]
	(cAliK255)->REG					:= "K255"
	(cAliK255)->CHAVE            	:= aK255[nX,2]
	(cAliK255)->DT_CONS				:= aK255[nX,3]
	(cAliK255)->COD_ITEM			:= aK255[nX,4]
	(cAliK255)->QTD					:= aK255[nX,5]
	(cAliK255)->COD_INS_SU			:= aK255[nX,7]
	(cAliK255)->(MsUnLock())
	nRegsto++
Next nX

Return

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � REGK990        � Autor � Materiais        � Data � 28/07/14 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Funcao responsavel pela gravacao do Registro K990           ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cAliasTRB   = Alias do arquivo de trabalho do Bloco         ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function REGK990(cAliK990,dDataAte,lRePross)

DEFAULT lRepross	:= .T.

Reclock(cAliK990,.T.)
(cAliK990)->FILIAL		:= cFilAnt
(cAliK990)->REG			:= "K990"
(cAliK990)->QTD_LIN_K	:= nRegsto+1
(cAliK990)->(MsUnLock())

//----------------------//
// Grava Tabela de Hist //
//----------------------//
BlkGrvTab(cAliK990,"D3U",aTmpRegK[K990][4],dDataAte,lRepross)

Return

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � REG0210        � Autor � Materiais        � Data � 28/07/14 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Funcao responsavel pela gravacao do Registro 0210           ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cAliasTRB   = Alias do arquivo de trabalho do Bloco         ���
���          � cProduto    = Codigo do Produto Produzido                   ���
���          � dDataDe     = Data Inicial da Apuracao                      ���
���          � dDataAte    = Data Final da Apuracao                        ���
���          � cOP         = Numero da OP                                  ���
���          � lNegEst     = Indica se trata estrutura negativa            ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function REG0210(cAli0210,cProduto,dDataDe,dDataAte,cOP,lNegEst,lRepross)

Local cQuery	:= ""
Local cUlRevisao:= ""
Local nQuantBase:= 0
Local cAliasTmp	:= CriaTrab(Nil,.F.)
Local aAreaSB1	:= SB1->(GetArea())
Local aComp		:= {}
Local aNegat	:= {}
Local aFantasma	:= {}
Local nCtrlRec	:= 0
Local nX
Local cSG1Local	:= ""

Default lNegEst		:= .F.
Default lRepross	:= .F.

dbSelectArea("SB1")
dbSetOrder(1)
If (SB1->(MsSeek(xFilial("SB1")+cProduto)))
	cUlRevisao	:= IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)
	nQuantBase	:= If(SB1->B1_QB == 0, 1, SB1->B1_QB)
EndIf

If !Empty(cOP)
	dbSelectArea("SC2")
	dbSetOrder(1)
	If (SC2->(MsSeek(xFilial("SC2")+cOP)))
		cUlRevisao	:= IIF(Empty(SC2->C2_REVISAO),cUlRevisao, SC2->C2_REVISAO)
	EndIf
EndIf

cQuery := "SELECT SG1.G1_FILIAL, SG1.G1_COD, SG1.G1_COMP, SG1.G1_QUANT, SG1.G1_PERDA, "
cQuery += "SB1C.B1_FANTASM FROM "+RetSqlName("SG1")+" SG1 JOIN "+RetSqlName("SB1")+" SB1 ON "
cQuery += "SB1.B1_FILIAL = '"+xFilial('SB1')+"' AND SB1.B1_COD = SG1.G1_COD AND "
cQuery += "SB1.D_E_L_E_T_ = ' ' "
cQuery += "JOIN "+RetSqlName("SB1")+" SB1C ON SB1C.B1_FILIAL = '"+xFilial('SB1')+"' AND "
cQuery += "SB1C.B1_COD = SG1.G1_COMP AND SB1C.D_E_L_E_T_ = ' ' "
If lCpoBZTP
	cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1C.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
cQuery += "WHERE SG1.G1_FILIAL = '"+xFilial('SG1')+"' AND "
cQuery += "SG1.G1_COD = '"+cProduto+"' AND SG1.G1_REVINI <= '"+cUlRevisao+"' AND "
cQuery += "SG1.G1_REVFIM >= '"+cUlRevisao+"' AND SG1.D_E_L_E_T_ = ' ' AND "
cQuery += "SB1.B1_CCCUSTO = ' ' AND SB1.B1_COD NOT LIKE 'MOD%' AND "
cQuery += "SB1C.B1_CCCUSTO = ' ' AND SB1C.B1_COD NOT LIKE 'MOD%' AND "
cQuery += "SG1.G1_INI <= '"+DtoS(dDataDe)+"' AND SG1.G1_FIM >= '"+DtoS(dDataAte)+"' AND "
If lCpoBZTP
	cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1C.B1_TIPO) "
Else
	cQuery += "SB1C.B1_TIPO "
EndIf
cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","
If !lNegEst
	cQuery += cTipo05+","
EndIf
cQuery += cTipo10+") "
If !lNegEst
	cQuery += "AND G1_QUANT > 0 "
EndIf
cQuery += "ORDER BY 1,2,3"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

If lNegEst
	//����������������������������������������������������������Ŀ
	//� Tratamento Estrutura Negativa                            �
	//������������������������������������������������������������
	While !(cAliasTmp)->(Eof())
		If (cAliasTmp)->B1_FANTASM <> "S"
			If (cAliasTmp)->G1_QUANT < 0
				Aadd(aNegat,{(cAliasTmp)->G1_FILIAL,(cAliasTmp)->G1_COMP,(cAliasTmp)->G1_QUANT / nQuantBase,(cAliasTmp)->G1_PERDA,cProduto})
			Else
				Aadd(aComp ,{(cAliasTmp)->G1_FILIAL,(cAliasTmp)->G1_COMP,(cAliasTmp)->G1_QUANT / nQuantBase,(cAliasTmp)->G1_PERDA,cProduto})
			EndIf
		EndIf
		(cAliasTmp)->(dbSkip())
	EndDo
Else
	If cVersSped < "016"
		cSG1Local := cFilAnt //xFilial("SG1")
		While !(cAliasTmp)->(Eof())
			//����������������������������������������������������������Ŀ
			//� Tratamento Produto Fantasma                              �
			//������������������������������������������������������������
			If (cAliasTmp)->B1_FANTASM == "S"
				aFantasma := REG0210Fan((cAliasTmp)->G1_COMP,dDataDe,dDataAte,@nCtrlRec)

				For nX := 1 to Len(aFantasma)
					If !((cAli0210)->(MsSeek(cSG1Local+(cAliasTmp)->G1_COD+aFantasma[nX,2])))
						Reclock(cAli0210,.T.)
						(cAli0210)->FILIAL     := cSG1Local
						(cAli0210)->REG        := "0210"
						(cAli0210)->COD_I_COMP := aFantasma[nX,2]
						(cAli0210)->QTD_COMP   := aFantasma[nX,3] * (cAliasTmp)->G1_QUANT
						(cAli0210)->PERDA      := aFantasma[nX,4]
						(cAli0210)->COD_ITEM   := (cAliasTmp)->G1_COD
						(cAli0210)->(MsUnLock())
					EndIf
				Next nX
				nCtrlRec := 0
			Else
				If !((cAli0210)->(MsSeek(cSG1Local+(cAliasTmp)->G1_COD+(cAliasTmp)->G1_COMP)))
					Reclock(cAli0210,.T.)
					(cAli0210)->FILIAL     := cSG1Local
					(cAli0210)->REG        := "0210"
					(cAli0210)->COD_I_COMP := (cAliasTmp)->G1_COMP
					(cAli0210)->QTD_COMP   := (((cAliasTmp)->G1_QUANT / nQuantBase)/(100 -(cAliasTmp)->G1_PERDA)) * 100
					(cAli0210)->PERDA      := (cAliasTmp)->G1_PERDA
					(cAli0210)->COD_ITEM   := (cAliasTmp)->G1_COD
					(cAli0210)->(MsUnLock())
				EndIf
			EndIf
			(cAliasTmp)->(dbSkip())
		EndDo
	EndIf
EndIf

//----------------------//
// Grava Tabela de Hist //
//----------------------//
If cVersSped < "016"
	BlkGrvTab(cAli0210,"D3F",aTmpRegK[0210][4],dDataAte,lRepross)
ENDIF

(cAliasTmp)->(dbCloseArea())
RestArea(aAreaSB1)

Return {aNegat,aComp}

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � REG0210Fan     � Autor � Materiais        � Data � 11/02/16 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Retorna os componentes de um produto fantasma               ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cProduto    = Codigo do Produto Produzido                   ���
���          � dDataDe     = Data Inicial da Apuracao                      ���
���          � dDataAte    = Data Final da Apuracao                        ���
���          � nCtrlRec    = Controle de recursividade                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function REG0210Fan(cProduto,dDataDe,dDataAte,nCtrlRec)

Local aAreaSB1	:= SB1->(GetArea())
Local aArea		:= GetArea()
Local cAliasFtm	:= CriaTrab(Nil,.F.)
Local cUlRevisao:= ""
Local aRet		:= {}
Local aFantasma	:= {}
Local nQuantBase:= 0
Local nX

// Controle de Recursividade
nCtrlRec++
If nCtrlRec > 99
	Return aRet
EndIf

dbSelectArea("SB1")
dbSetOrder(1)
If (SB1->(MsSeek(xFilial("SB1")+cProduto)))
	cUlRevisao 	:= IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)
	nQuantBase	:= If(SB1->B1_QB == 0, 1, SB1->B1_QB)
EndIf

cQuery := "SELECT SG1.G1_FILIAL, SG1.G1_COD, SG1.G1_COMP, SG1.G1_QUANT, SG1.G1_PERDA, "
cQuery += "SB1C.B1_FANTASM FROM "+RetSqlName("SG1")+" SG1 JOIN "+RetSqlName("SB1")+" SB1 ON "
cQuery += "SB1.B1_FILIAL = '"+xFilial('SB1')+"' AND SB1.B1_COD = SG1.G1_COD AND "
cQuery += "SB1.D_E_L_E_T_ = ' ' "
cQuery += "JOIN "+RetSqlName("SB1")+" SB1C ON SB1C.B1_FILIAL = '"+xFilial('SB1')+"' AND "
cQuery += "SB1C.B1_COD = SG1.G1_COMP AND SB1C.D_E_L_E_T_ = ' ' "
If lCpoBZTP
	cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1C.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
cQuery += "WHERE SG1.G1_FILIAL = '"+xFilial('SG1')+"' AND "
cQuery += "SG1.G1_COD = '"+cProduto+"' AND SG1.G1_REVINI <= '"+cUlRevisao+"' AND "
cQuery += "SG1.G1_REVFIM >= '"+cUlRevisao+"' AND SG1.D_E_L_E_T_ = ' ' AND "
cQuery += "SB1.B1_CCCUSTO = ' ' AND SB1.B1_COD NOT LIKE 'MOD%' AND "
cQuery += "SB1C.B1_CCCUSTO = ' ' AND SB1C.B1_COD NOT LIKE 'MOD%' AND "
cQuery += "SG1.G1_INI <= '"+DtoS(dDataDe)+"' AND SG1.G1_FIM >= '"+DtoS(dDataAte)+"' AND "
If lCpoBZTP
	cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1C.B1_TIPO) "
Else
	cQuery += "SB1C.B1_TIPO "
EndIf
cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
cQuery += "ORDER BY 1,2,3"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasFtm,.T.,.T.)

While !(cAliasFtm)->(Eof())
	//����������������������������������������������������������Ŀ
	//� Recursividade no Produto Fantasma                        �
	//������������������������������������������������������������
	If (cAliasFtm)->B1_FANTASM == "S"
		aFantasma := REG0210Fan((cAliasFtm)->G1_COMP,dDataDe,dDataAte,@nCtrlRec)
		For nX := 1 to Len(aFantasma)
			Aadd(aRet ,{aFantasma[nX,1],aFantasma[nX,2],aFantasma[nX,3],aFantasma[nX,4],aFantasma[nX,5]})
		Next nX
	Else
		Aadd(aRet ,{(cAliasFtm)->G1_FILIAL,(cAliasFtm)->G1_COMP,(cAliasFtm)->G1_QUANT / nQuantBase,(cAliasFtm)->G1_PERDA,cProduto})
	EndIf
	(cAliasFtm)->(dbSkip())
EndDo

(cAliasFtm)->(dbCloseArea())
RestArea(aAreaSB1)
RestArea(aArea)

Return aRet

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � GetSubst       � Autor � Materiais        � Data � 30/09/14 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Retorna o produto substituto (alternativo) utilizado no K235���
��������������������������������������������������������������������������Ĵ��
���Parametros� cBloco   = Codigo do Bloco                                  ���
���          � cProduto = Codigo do Produto Consumido                      ���
���          � cOP      = Numero da OP                                     ���
���          � dDataDe  = Data Inicial da Apuracao                         ���
���          � dDataAte = Data Final da Apuracao                           ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function GetSubst(cProduto,cOP,dDataDe,dDataAte)

Local cCodOri	:= Space(Len(SD3->D3_COD))
Local cAliasTmp	:= CriaTrab(Nil,.F.)
Local aArea		:= GetArea()
Local cProdPai	:= ""
Local cUlRev	:= ""
Local cQuery	:= ""

dbSelectArea("SC2")
dbSetOrder(1)
If (SC2->(MsSeek(xFilial("SC2")+cOP)))
	cProdPai := SC2->C2_PRODUTO
	cUlRev	 := SC2->C2_REVISAO

	cQuery := "SELECT SG1.G1_FILIAL, SG1.G1_COD, SG1.G1_COMP,SGI.GI_PRODALT "
	cQuery += "FROM "+RetSqlName("SG1")+" SG1 JOIN "+RetSqlName("SGI")+" SGI ON "
	cQuery += "SGI.GI_FILIAL = '"+xFilial('SGI')+"' AND SGI.D_E_L_E_T_ = ' ' AND "
	cQuery += "SGI.GI_PRODORI = SG1.G1_COMP "
	cQuery += "JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' AND "
	cQuery += "SB1.B1_COD = SG1.G1_COD AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "JOIN "+RetSqlName("SB1")+" SB1C ON SB1C.B1_FILIAL = '"+xFilial('SB1')+"' AND "
	cQuery += "SB1C.B1_COD = SGI.GI_PRODORI AND SB1C.D_E_L_E_T_ = ' ' "
	If lCpoBZTP
		cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1C.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += "WHERE SG1.G1_FILIAL = '"+xFilial('SG1')+"' AND "
	cQuery += "SG1.G1_COD = '"+cProdPai+"' AND SGI.GI_PRODALT = '"+cProduto+"' AND "
	cQuery += "SG1.G1_REVINI <= '"+cUlRev+"' AND SG1.G1_REVFIM >= '"+cUlRev+"' AND "
	cQuery += "SG1.G1_INI <= '"+DtoS(dDataDe)+"' AND SG1.G1_FIM >= '"+DtoS(dDataAte)+"' AND "
	cQuery += "SB1.B1_CCCUSTO = ' ' AND SB1.B1_COD NOT LIKE 'MOD%' AND "
	cQuery += "SB1C.B1_CCCUSTO = ' ' AND SB1C.B1_COD NOT LIKE 'MOD%' AND "
	If lCpoBZTP
		cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1C.B1_TIPO) "
	Else
		cQuery += "SB1C.B1_TIPO "
	EndIf
	cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	cQuery += " AND SG1.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

	If !(cAliasTmp)->(Eof())
		cCodOri := (cAliasTmp)->G1_COMP
	EndIf

	(cAliasTmp)->(dbCloseArea())
EndIf

RestArea(aArea)

Return cCodOri

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � REG0200        � Autor � Materiais        � Data � 29/12/16 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Grava os produtos utilizados no processamento do Bloco K    ���
��������������������������������������������������������������������������Ĵ��
���Parametros� aAlias   = Alias dos arquivos temporarios do Bloco K        ���
���          � aRegistr = Lista dos arquivos temporarios do Blooc K        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function REG0200(aAlias,aRegistr)

Local aArea		:= GetArea()
Local nX

dbSelectArea(aAlias[0200])
dbSetOrder(1)

For nX := 1 To Len(aRegistr)
	If !(aRegistr[nX] $ "K001|K100|K990|0200|K290|")
		(aAlias[nX])->(dbGoTop())

		While !(aAlias[nX])->(Eof())

			Do Case
				Case aRegistr[nX] == "K210"
					Grav0200((aAlias[nX])->COD_ITEM_O ,aAlias[0200] )
				Case aRegistr[nX] == "K215"
					Grav0200((aAlias[nX])->COD_ITEM_D ,aAlias[0200] )
				Case aRegistr[nX] == "K220"
					Grav0200((aAlias[nX])->COD_ITEM_O ,aAlias[0200] )
					Grav0200((aAlias[nX])->COD_ITEM_D ,aAlias[0200] )
				Case aRegistr[nX] == "0210"
					Grav0200((aAlias[nX])->COD_ITEM ,aAlias[0200] )
					Grav0200((aAlias[nX])->COD_I_COMP ,aAlias[0200] )
				Case aRegistr[nX] == "K300"
					//
				Otherwise
					Grav0200((aAlias[nX])->COD_ITEM ,aAlias[0200] )
			EndCase

			(aAlias[nX])->(dbSkip())
		EndDo
	EndIf
Next nX

RestArea(aArea)

Return

/*/{Protheus.doc} Grav0200
Faz a gravacao do produto para o registro 0200
@author reynaldo
@since 05/10/2018
@version 1.0
@return ${return}, ${return_description}
@param cCodItem, characters, descricao
@param cAli0200, characters, descricao
@type function
/*/
Static Function Grav0200(cCodItem ,cAli0200 )
	If !(cAli0200)->(MsSeek(cCodItem))
		Reclock(cAli0200,.T.)
		(cAli0200)->COD_ITEM	:= cCodItem
		(cAli0200)->(MsUnlock())
	EndIf
Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GetIniProd �Autor � TOTVS S/A            � Data �06/10/2015���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna a data do inicio real do processo produtivo.       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cOP    = Numero da OP                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function GetIniProd(cOP)

Local cQuery		:= ""
Local dRet 			:= StoD("")
Local aArea			:= GetArea()
Local cAliasTmp		:= CriaTrab(Nil,.F.)

cQuery := "SELECT MIN(D3_EMISSAO) DTINICIO "
cQuery += "FROM " + RetSqlName("SD3") + " SD3 JOIN " + RetSqlName("SB1") + " SB1 "
cQuery += "ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = SD3.D3_COD "
cQuery += "AND SB1.D_E_L_E_T_ = ' ' "
cQuery += "WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "' "
cQuery += "AND SD3.D3_OP = '" + cOP + "' "
cQuery += "AND SD3.D3_ESTORNO = ' ' "
cQuery += "AND SD3.D_E_L_E_T_ = ' ' "
cQuery += "GROUP BY D3_OP"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

If !(cAliasTmp)->(Eof())
	dRet := StoD((cAliasTmp)->DTINICIO)
EndIf

(cAliasTmp)->(dbCloseArea())
RestArea(aArea)

Return dRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ProcNegEst �Autor � TOTVS S/A            � Data �13/10/2015���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza a gravacao dos registros 0210, K230 e K235 quando  ���
���          � cliente trabalha com conceito de estrutura negativa        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cAli0210   = Alias do arquivo de trabalho O210             ���
���          � cAliK230   = Alias do arquivo de trabalho K230             ���
���          � cAliK235   = Alias do arquivo de trabalho K235             ���
���          � dDataDe     = Data Inicial da Apuracao                     ���
���          � dDataAte    = Data Final da Apuracao                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ProcNegEst(cAli0210,cAliK230,cAliK235,dDataDe,dDataAte,lRePross)

Local aEstrut	:= {}
Local nX
Local cFilAux	:= ""
Local cOP		:= ""
Local nQuant	:= 0
Local nQtdAux	:= 0
Local nRecno	:= 0
Local dDtIni, dDtFim

(cAliK230)->(dbGoTop())
While !(cAliK230)->(Eof())
	aEstrut := REG0210(cAli0210,(cAliK230)->COD_ITEM,dDataDe,dDataAte,(cAliK230)->COD_DOC_OP,.T.,lRePross)

	If Len(aEstrut[1]) > 0
		//����������������������������������������������������������Ŀ
		//� Grava K230 do Co-Produto                                 �
		//������������������������������������������������������������
		cFilAux := (cAliK230)->FILIAL
		cOP		:= (cAliK230)->COD_DOC_OP
		dDtIni	:= (cAliK230)->DT_INI_OP
		dDtFim	:= (cAliK230)->DT_FIN_OP
		nQuant	:= (cAliK230)->QTD_ENC

		nRecno	:= (cAliK230)->(Recno())

		For nX := 1 to Len(aEstrut[1])

			nQtdAux	:= GetCoProd(cOP,aEstrut[1][nX][2],dDataDe,dDataAte)
			If nQtdAux > 0 .And. !((cAliK230)->(MsSeek(cFilAux+cOP+aEstrut[1][nX][2])))
				Reclock(cAliK230,.T.)
				(cAliK230)->FILIAL			:= cFilAux
				(cAliK230)->REG				:= "K230"
				(cAliK230)->DT_INI_OP		:= dDtIni
				(cAliK230)->DT_FIN_OP		:= dDtFim
				(cAliK230)->COD_DOC_OP		:= cOP
				(cAliK230)->COD_ITEM		:= aEstrut[1][nX][2]
				(cAliK230)->QTD_ENC			:= nQtdAux
				(cAliK230)->(MsUnLock())
				nRegsto++
			EndIf

		Next nX

		(cAliK230)->(dbGoto(nRecno))

		//����������������������������������������������������������Ŀ
		//� Grava 0210 do Co-Produto                                 �
		//������������������������������������������������������������
		NegEst0210(aEstrut,cAli0210)

	EndIf

	(cAliK230)->(dbSkip())
EndDo

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GetCoProd  �Autor � TOTVS S/A            � Data �13/10/2015���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna a quantidade da Co-producao realizada para a OP    ���
���          � dentro do periodo                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cOP         = Numero da OP                                 ���
���          � cProduto    = Codigo do Produto Produzido                  ���
���          � dDataDe     = Data Inicial da Apuracao                     ���
���          � dDataAte    = Data Final da Apuracao                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function GetCoProd(cOP,cProduto,dDataDe,dDataAte)

Local nQuant		:= 0
Local cQuery		:= ""
Local aArea			:= GetArea()
Local cAliasTmp		:= CriaTrab(Nil,.F.)

cQuery := "SELECT SUM(D3_QUANT) QUANT, D3_COD, D3_OP "
cQuery += "FROM " + RetSqlName("SD3") + " SD3 JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery += "AND SB1.B1_COD = SD3.D3_COD AND SB1.D_E_L_E_T_ = ' ' "
cQuery += "WHERE SD3.D3_FILIAL = '"+xFilial("SD3")+"' AND SD3.D3_OP = '" + cOP + "' "
cQuery += "AND SD3.D3_CF = 'DE1' AND SD3.D3_COD = '" + cProduto + "' AND SD3.D3_ESTORNO = ' ' "
cQuery += "AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' "
cQuery += "AND SD3.D_E_L_E_T_ = ' ' "
cQuery += "GROUP BY D3_COD, D3_OP "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

If !(cAliasTmp)->(Eof())
	nQuant := (cAliasTmp)->QUANT
EndIf

(cAliasTmp)->(dbCloseArea())
RestArea(aArea)

Return nQuant

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � NegEst0210 �Autor � TOTVS S/A            � Data �13/10/2015���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava o Registro 0210 para os componentes que que sao      ���
���          � negativos na estrutura de um PA                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aEstrut    = Vetor com Comp. Negativos [1] e Comuns [2]    ���
���          � cAli0210   = Alias do arquivo de trabalho O210             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function NegEst0210(aEstrut,cAli0210)

Local aArea			:= GetArea()
Local aArea0210		:= (cAli0210)->(GetArea())
Local nFator		:= 0
Local nQtd			:= 1
Local cProduto		:= ""
Local cFilAux		:= ""
Local cChave		:= ""
Local nX, nY

//����������������������������������������������������������Ŀ
//� Soma as "Producoes" e "Co-Producoes"                     �
//������������������������������������������������������������
For nX := 1 to Len(aEstrut[1])
	nQtd += If(aEstrut[1][nX][3] < 0, aEstrut[1][nX][3] * -1, aEstrut[1][nX][3])
Next nX

//����������������������������������������������������������Ŀ
//� Grava o 0210 para "Co-Producoes"                         �
//������������������������������������������������������������
For nX := 1 to Len(aEstrut[1])
	cFilAux		:= aEstrut[1][nX][1]
	cProduto	:= aEstrut[1][nX][2]
	cChave		:= cFilAux+aEstrut[1][1][5]
	//����������������������������������������������������������Ŀ
	//� Calcula o Fator de Consumo Especifico                    �
	//������������������������������������������������������������
	nFator :=  (aEstrut[1][nX][3] * -1) / nQtd

	For nY := 1 to Len(aEstrut[2])
		If !((cAli0210)->(MsSeek(cFilAux+cProduto+aEstrut[2][nY][2])))
			Reclock(cAli0210,.T.)
			(cAli0210)->FILIAL			:= cFilAux
			(cAli0210)->REG				:= "0210"
			(cAli0210)->COD_I_COMP		:= aEstrut[2][nY][2]
			(cAli0210)->QTD_COMP		:= aEstrut[2][nY][3] * nFator
			(cAli0210)->PERDA			:= aEstrut[2][nY][4]
			(cAli0210)->COD_ITEM		:= cProduto
			(cAli0210)->(MsUnLock())
		EndIf
	Next nY
Next nX

//����������������������������������������������������������Ŀ
//� Ajusta os componentes da estrutura da "Producao"         �
//������������������������������������������������������������
For nY := 1 to Len(aEstrut[2])
	If ((cAli0210)->(MsSeek(aEstrut[2][nY][1]+aEstrut[2][nY][5]+aEstrut[2][nY][2])))
		Reclock(cAli0210,.F.)
		(cAli0210)->QTD_COMP := aEstrut[2][nY][3] * (1 / nQtd)
		(cAli0210)->(MsUnLock())
	EndIf
Next nY

RestArea(aArea0210)
RestArea(aArea)

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TrocaTipo  �Autor � TOTVS S/A            � Data �05/11/2015���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chama o ponto de entrada SPDFIS001 e realiza a troca dos   ���
���          � Tipos de Produto do Sistema X SPED.                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TrocaTipo()

Local aTipo			:= {}
Local cTipo			:= ""
Local nX

Local aTipos := {}
Local cTipos := ''
Local lVldBlkTp := FindFunction('VldBlkTp')

If ExistBlock("SPDFIS001")
	aTipo := ExecBlock("SPDFIS001", .F., .F., {aTipo})
EndIf

For nX := 1 to Len(aTipo)
	If !(aTipo[nX][2] $ "07|08|09")
		If "|" $ aTipo[nX][1]
			aTipo[nX][1] := StrTran(aTipo[nX][1],"|","','")
		EndIf
		cTipo		:= "cTipo" + aTipo[nX][2]
		&(cTipo)	:= "'" + aTipo[nX][1] + "'"
	EndIf
Next nX

If Len(aTipo) > 0
	cTipos := ''
	cTipos += cTipo00 + ','
	cTipos += cTipo01 + ','
	cTipos += cTipo02 + ','
	cTipos += cTipo03 + ','
	cTipos += cTipo04 + ','
	cTipos += cTipo05 + ','
	cTipos += cTipo06 + ','
	cTipos += cTipo10
	
	aTipos := STRTOKARR( cTipos, ',')

	If lVldBlkTp .And. !VldBlkTp(aTipos) 
		// Inconsistencia no Bloco K, mesmo tipo de produto em par�metro MV_BLKTP diferentes ap�s PE
		ProcLogAtu(STR0001,STR0045+Alltrim(DtoC(Date())) + " - " + Alltrim(Time())) //MENSAGEM | "N�o � permitido mesmo tipo de produto em par�metro MV_BLKTP(*) diferentes. "
	EndIf
EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � REG0210Mov �Autor � TOTVS S/A            � Data �09/11/2015���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza a gravacao do Registro 0210 com base nos movimentos���
���          � realizados no perido.                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cAliK230   = Alias do arquivo de trabalho K230             ���
���          � cAliK235   = Alias do arquivo de trabalho K235             ���
���          � cAli0210   = Alias do arquivo de trabalho O210             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function REG0210Mov(cAliK230,cAliK235,cAli0210,dDataDe,dDataAte)

Local aArea     as Array
Local aQuant     := {}
Local nPerda     := 0
Local lPerdPadr as Logical
Local cSD4Filial := ""

If cVersSped < "016"

	aArea     := GetArea()
	lPerdPadr := SuperGetMV("MV_BLKPERD",.F.,.F.)
	//����������������������������������������������������������Ŀ
	//� Posiciona no inicio das tabelas                          �
	//������������������������������������������������������������
	(cAliK230)->(dbGoTop())
	(cAliK235)->(dbGoTop())

	dbSelectArea("SD4")
	dbSetOrder(2) // D4_FILIAL+D4_OP+D4_COD+D4_LOCAL

	cSD4Filial := xFilial("SD4")
	//����������������������������������������������������������Ŀ
	//� Percorre todas as OP's do Registro K230                  �
	//������������������������������������������������������������
	While !(cAliK230)->(Eof())
		If (cAliK235)->(MsSeek((cAliK230)->(FILIAL+COD_DOC_OP))) // FILIAL+COD_DOC_OP+COD_ITEM

			//����������������������������������������������������������Ŀ
			//� Percorre o Registro K235 de cada OP do Registro K230     �
			//������������������������������������������������������������
			While (cAliK235)->(FILIAL+COD_DOC_OP) == (cAliK230)->(FILIAL+COD_DOC_OP)

				//����������������������������������������������������������Ŀ
				//� Verifica se ha empenho na SD4 para aumentar a precisao,  �
				//� caso contrario usa quantidade consumida no periodo.      �
				//������������������������������������������������������������
				If SD4->(MsSeek(cSD4Filial+(cAliK235)->(COD_DOC_OP+COD_ITEM)))
					aQuant := GetQtdComp(1,(cAliK235)->FILIAL,(cAliK235)->COD_DOC_OP,(cAliK235)->COD_ITEM,(cAliK230)->QTD_ENC)
				Else
					aQuant := GetQtdComp(2,(cAliK235)->FILIAL,(cAliK235)->COD_DOC_OP,(cAliK235)->COD_ITEM,(cAliK230)->QTD_ENC,(cAliK235)->QTD)
				EndIf
				nPerdMov:= GetPerdMov((cAliK235)->COD_DOC_OP,(cAliK235)->COD_ITEM,dDataDe,dDataAte)
				//����������������������������������������������������������Ŀ
				//� Realiza a gravacao do Registro 0210                      �
				//������������������������������������������������������������
				If !(cAli0210)->(MsSeek((cAliK230)->(FILIAL+COD_ITEM)+(cAliK235)->(COD_ITEM)))
					Reclock(cAli0210,.T.)
					(cAli0210)->FILIAL   := (cAliK230)->FILIAL
					(cAli0210)->REG      := "0210"
					(cAli0210)->COD_ITEM := (cAliK230)->COD_ITEM
					If (cAliK235)->COD_INS_SU == PADR(Nil,len((cAliK235)->COD_INS_SU))
						(cAli0210)->COD_I_COMP	:= (cAliK235)->COD_ITEM
					Else
						(cAli0210)->COD_I_COMP	:= (cAliK235)->COD_INS_SU
					EndIf
					(cAli0210)->QTD_CONS		:= aQuant[1]			// Campo Auxiliar
					(cAli0210)->QTD_PROD		:= aQuant[2]			// Campo Auxiliar
					If lPerdPadr
						(cAli0210)->QTD_COMP	:= ((cAli0210)->QTD_CONS - nPerdMov) / (cAli0210)->QTD_PROD
						(cAli0210)->PERDA		:= (nPerdMov/(cAli0210)->QTD_CONS) * 100
					Else
						(cAli0210)->QTD_COMP	:= (cAli0210)->QTD_CONS / (cAli0210)->QTD_PROD
						(cAli0210)->PERDA		:= 0
					EndIf
					(cAli0210)->(MsUnLock())
					nRegsto++
				Else
					If lPerdPadr
						nPerda := ((cAli0210)->PERDA/100)  * (cAli0210)->QTD_COMP //-- Recupera perda em quantidade para n�o misturar percentuais de OPs distintas
						nPerda += 	nPerdMov //-- Soma quantidade perdida
					EndIf

					Reclock(cAli0210,.F.)
					(cAli0210)->QTD_CONS		+= aQuant[1]			// Campo Auxiliar
					(cAli0210)->QTD_PROD		+= aQuant[2]			// Campo Auxiliar
					If lPerdPadr
						(cAli0210)->QTD_COMP	:= ((cAli0210)->QTD_CONS - nPerdMov) / (cAli0210)->QTD_PROD
						(cAli0210)->PERDA		:= (nPerda/(cAli0210)->QTD_CONS) * 100 //-- Converte novamente para percentual
					Else
						(cAli0210)->QTD_COMP := (cAli0210)->QTD_CONS / (cAli0210)->QTD_PROD
					endif
					(cAli0210)->(MsUnLock())
				EndIf

				(cAliK235)->(dbSkip())
			EndDo
		EndIf
		(cAliK230)->(dbSkip())
	EndDo

	RestArea(aArea)
ENDIF

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GetQtdComp �Autor � TOTVS S/A            � Data �09/11/2015���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula a quantidade do componente para a producao do Pai: ���
���          � nTipo = 1 : Baseado no empenho existente (SD4)             ���
���          � nTipo = 2 : Baseado nos movimentos do periodo              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function GetQtdComp(nTipo,cFilK235,cOP,cComp,nQtdProd,nQtdCons)

Local aArea			:= GetArea()
Local aQuant		:= {0,0} // {"Componente","Produzido"}
Local nQuantOP		:= 0
Local cSD4Filial	:= xFilial("SD4")

//����������������������������������������������������������Ŀ
//� Guarda informacoes da Ordem de Producao                  �
//������������������������������������������������������������
dbSelectArea("SC2")
dbSetOrder(1)
If (SC2->(MsSeek(xFilial("SC2")+cOP)))
	nQuantOP	:= SC2->C2_QUANT
EndIf

If nTipo == 1
	//����������������������������������������������������������Ŀ
	//� TIPO 1 - Calculo baseado no empenho existente (SD4)      �
	//������������������������������������������������������������
	While SD4->(cSD4Filial+D4_OP+D4_COD) == cFilK235+cOP+cComp
		//����������������������������������������������������������Ŀ
		//� Desconsidera empenho negativo de estruturas negativas    �
		//������������������������������������������������������������
		If SD4->D4_QTDEORI > 0
			aQuant[1] += SD4->D4_QTDEORI
		EndIf
		SD4->(dbSkip())
	EndDo
	aQuant[2] := nQuantOP
Else
	//����������������������������������������������������������Ŀ
	//� TIPO 2 - Calculo baseado nos movimentos do periodo       �
	//������������������������������������������������������������
	aQuant[1] := nQtdCons
	If nQtdProd > 0
		aQuant[2] := nQtdProd
	Else
		aQuant[2] := nQuantOP
	EndIf
EndIf

RestArea(aArea)

Return aQuant

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � REG0210Ter �Autor � TOTVS S/A            � Data �08/12/2015���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza a gravacao do Registro 0210 com base nos movimentos���
���          � das Notas de Entrada - Industrializacao em Terceiros.      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cAli0210   = Alias do arquivo de trabalho O210             ���
���          � cAliK250   = Alias do arquivo de trabalho K250             ���
���          � cAliK255   = Alias do arquivo de trabalho K255             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function REG0210Ter(cAli0210,cAliK250,cAliK255)

Local aArea As Array

If cVersSped < "016"

	aArea := GetArea()

	//����������������������������������������������������������Ŀ
	//� Posiciona no inicio das tabelas                          �
	//������������������������������������������������������������
	(cAliK250)->(dbGoTop())
	(cAliK255)->(dbGoTop())

	//����������������������������������������������������������Ŀ
	//� Percorre todas as OP's do Registro K250                  �
	//������������������������������������������������������������
	While !(cAliK250)->(Eof())
		If (cAliK255)->(MsSeek((cAliK250)->(FILIAL+CHAVE))) //"FILIAL+CHAVE+COD_ITEM"
			//����������������������������������������������������������Ŀ
			//� Percorre o Registro K255 de cada Chave do Registro K250  �
			//������������������������������������������������������������
			While (cAliK255)->(FILIAL+CHAVE) == (cAliK250)->(FILIAL+CHAVE)
				//����������������������������������������������������������Ŀ
				//� Realiza a gravacao do Registro 0210                      �
				//������������������������������������������������������������
				If !(cAli0210)->(MsSeek((cAliK250)->(FILIAL+COD_ITEM)+(cAliK255)->(COD_ITEM)))
					Reclock(cAli0210,.T.)
					(cAli0210)->FILIAL     := (cAliK250)->FILIAL
					(cAli0210)->REG        := "0210"
					(cAli0210)->COD_ITEM   := (cAliK250)->COD_ITEM
					(cAli0210)->COD_I_COMP := (cAliK255)->COD_ITEM
					(cAli0210)->QTD_CONS   := (cAliK255)->QTD // Campo Auxiliar
					(cAli0210)->QTD_PROD   := (cAliK250)->QTD // Campo Auxiliar
					(cAli0210)->QTD_COMP   := (cAli0210)->QTD_CONS / (cAli0210)->QTD_PROD
					(cAli0210)->PERDA      := 0
					(cAli0210)->(MsUnLock())
					nRegsto++
				Else
					Reclock(cAli0210,.F.)
					(cAli0210)->QTD_CONS := (cAliK255)->QTD // Campo Auxiliar
					(cAli0210)->QTD_PROD := (cAliK250)->QTD // Campo Auxiliar
					(cAli0210)->QTD_COMP := (cAli0210)->QTD_CONS / (cAli0210)->QTD_PROD
					(cAli0210)->(MsUnLock())
				EndIf
				(cAliK255)->(dbSkip())
			EndDo
		EndIf
		(cAliK250)->(dbSkip())
	EndDo

	RestArea(aArea)
ENDIF

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GetAlmTerc �Autor � TOTVS S/A            � Data �21/01/2015���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna os Armazens de Terceiros, caso o cliente utilize o ���
���          � conceito do parametro MV_CONTERC.                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function GetAlmTerc()

Local cRet			:= ""
Local lConTerc		:= SuperGetMv("MV_CONTERC",.F.,.F.)
Local cCusFil		:= SuperGetMv("MV_CUSFIL",.F.,"A")
Local lVldCus		:= cCusFil == 'F' .Or. cCusFil == 'E'

If lConTerc .And. lVldCus
	cRet := GetMvNNR('MV_ALMTERC','80')
EndIf

Return cRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GetListPrd �Autor � TOTVS S/A            � Data �29/08/2016���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna o arquivo de trabalho contendo a lista de produtos ���
���          � com saldo inicial e se houve movimentacao no periodo.      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cAliasTmp = Alias do arquivo de trabalho                   ���
���          � dDataAte  = Data do saldo                                  ���
���          � lTerc     = Monta o arquivo de trabalho para terceiros     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function GetListPrd(cAliasTmp,dDataAte,dDataDe,lTerc)
Local cQuery	:= ""
Local cArqTmp	:= ""
Local aTam		:= {}
Local aCampos	:= {}
Local cAliasTRB	:= CriaTrab(Nil,.F.)
Local lAliasD3E	:= AliasInDic("D3E")
Local cCoalesce	:= MatIsNull()

Default lTerc	:= .F.

//�����������������������������������������������������������������������Ŀ
//�                        OBSERVACAO IMPORTANTE!!!                       �
//� --------------------------------------------------------------------- �
//� A ordenacao dos registros nao pode ser alterada, pois ao processar o  �
//� Reg. K200 espera-se que Produtos com N Armazens estejam sequenciais.  �
//� Se a ordenacao for alterada o processamento do K200 ficara incorreto. �
//�������������������������������������������������������������������������

//�����������������������������������������������������������������������Ŀ
//� Query dos produtos que foram movimentados entre dUlmes e dDataAte     �
//�������������������������������������������������������������������������
cQuery := "SELECT 'A' QRY,SB9.B9_FILIAL, ('S') STATS, SB9.B9_COD, SB9.B9_LOCAL, SB9.B9_DATA, SB9.B9_QINI, SB9.B9_VINI1 "
If lAliasD3E
	cQuery += ", "+ cCoalesce +"( D3E.D3E_CLIENT, '"+ CriaVar( 'D3E_CLIENT', .F. ) +"' ) D3E_CLIENT, "+ cCoalesce +"( D3E.D3E_LOJA, '"+ CriaVar( 'D3E_LOJA', .F. ) +"' ) D3E_LOJA "
Else
	cQuery += ",' ' D3E_CLIENT ,' ' D3E_LOJA "
EndIf
cQuery += "FROM "+ RetSqlName("SB9") +" SB9 JOIN "+ RetSqlName("SB1") +" SB1 ON "
cQuery += "SB1.B1_FILIAL = '"+ xFilial("SB1") +"' AND SB1.B1_COD = SB9.B9_COD AND SB1.D_E_L_E_T_ = ' ' "
If lAliasD3E
	cQuery += "LEFT JOIN "+ RetSqlName("D3E") +" D3E "
	cQuery += "ON D3E.D3E_FILIAL = '"+ xFilial("D3E") +"' AND D3E.D3E_COD = SB1.B1_COD AND D3E.D_E_L_E_T_ = ' ' "
	cQuery += "LEFT JOIN "+ RetSqlName("SA1") +" SA1 "
	cQuery += "ON SA1.A1_FILIAL = '"+ xFilial("SA1") +"' AND SA1.A1_COD = D3E.D3E_CLIENT AND SA1.A1_LOJA = D3E.D3E_LOJA AND SA1.D_E_L_E_T_ = ' ' "
EndIf
If lCpoBZTP
	cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
cQuery += "JOIN "+ RetSqlName("SB2") +" SB2 ON SB2.B2_FILIAL = '"+ xFilial("SB2") +"' AND "
cQuery += "SB2.B2_COD = SB9.B9_COD AND SB2.B2_LOCAL = SB9.B9_LOCAL AND SB2.D_E_L_E_T_ = ' ' WHERE "
// --- Where
If lCpoBZTP
	cQuery += " "+ cCoalesce +"( SBZ.BZ_TIPO, SB1.B1_TIPO ) "
Else
	cQuery += "SB1.B1_TIPO "
EndIF
cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") AND "
cQuery += "SB9.D_E_L_E_T_ = ' ' AND SB1.B1_FANTASM <> 'S' AND SB1.B1_CCCUSTO = ' ' AND SB1.B1_COD NOT LIKE 'MOD%' AND "
cQuery += "SB9.B9_DATA = (SELECT MAX(SB9B.B9_DATA) B9_DATAMAX "
cQuery += "FROM "+ RetSqlName("SB9") +" SB9B "
cQuery += "WHERE SB9B.B9_FILIAL = '"+ xFilial("SB9") + "' AND SB9B.B9_DATA <> '"+SPACE(TamSX3("B9_DATA")[1])+"' AND SB9B.B9_DATA <= '"+ DtoS(dDataAte)+"' AND SB9B.B9_COD = SB1.B1_COD AND SB9B.B9_LOCAL = SB2.B2_LOCAL AND SB9B.D_E_L_E_T_ = ' ')"
cQuery	+= "AND SB9.B9_FILIAL = '"+ xFilial("SB9") +"' AND "
If lTerc
	// --- Exist SB6
	cQuery += "(EXISTS(SELECT 1 FROM "+ RetSqlName("SB6") +" SB6 , "+ RetSqlName("SF4") +" SF4 WHERE SB6.B6_FILIAL = '"+ xFilial("SB6") +"' AND "
	cQuery += "SB6.B6_PRODUTO = SB9.B9_COD AND SB6.B6_LOCAL = SB9.B9_LOCAL AND SB6.B6_PODER3 = 'R' AND "
	cQuery += "SB6.B6_EMISSAO <= '"+ DtoS(dDataAte)+"' AND SF4.F4_FILIAL = '"+ xFilial("SF4") +"' AND SF4.F4_CODIGO = SB6.B6_TES AND "
	cQuery += "SF4.F4_ESTOQUE = 'S' AND "
	cQuery += "SF4.D_E_L_E_T_ = ' ' AND SB6.D_E_L_E_T_ = ' ')) "
Else
	// --- Exist SD1
	cQuery += "(EXISTS (SELECT 1 FROM "+ RetSqlName("SD1") +" SD1, "+ RetSqlName("SF4") +" SF4 WHERE SD1.D1_FILIAL = '"+ xFilial("SD1") +"' AND "
	cQuery += "SD1.D1_COD = SB9.B9_COD AND SD1.D1_LOCAL = SB9.B9_LOCAL AND SD1.D1_DTDIGIT BETWEEN (SELECT MAX(SB9B.B9_DATA) B9_DATAMAX "
	cQuery += "FROM "+ RetSqlName("SB9") +" SB9B "
	cQuery += "WHERE SB9B.B9_FILIAL = '"+ xFilial("SB9") + "' AND SB9B.B9_DATA <> '"+SPACE(TamSX3("B9_DATA")[1])+"' AND SB9B.B9_DATA <= '"+ DtoS(dDataAte)+"' AND SB9B.B9_COD = SB1.B1_COD AND SB9B.B9_LOCAL = SB2.B2_LOCAL AND SB9B.D_E_L_E_T_ = ' ') AND '"+ DtoS(dDataAte) +"' AND "
	cQuery += "SD1.D1_ORIGLAN <> 'LF' AND SF4.F4_FILIAL = '"+ xFilial("SF4") +"' AND SF4.F4_CODIGO = SD1.D1_TES AND "
	cQuery += "(SF4.F4_ESTOQUE = 'S' "
	cQuery += ") AND "
	cQuery += "SF4.D_E_L_E_T_ = ' ' AND SD1.D_E_L_E_T_ = ' ' ) "
	// --- Exist SD2
	cQuery += "OR EXISTS (SELECT 1 FROM "+ RetSqlName("SD2") +" SD2, "+ RetSqlName("SF4") +" SF4 WHERE SD2.D2_FILIAL = '"+ xFilial("SD2") +"' AND "
	cQuery += "SD2.D2_COD = SB9.B9_COD AND SD2.D2_LOCAL = SB9.B9_LOCAL AND SD2.D2_EMISSAO BETWEEN (SELECT MAX(SB9B.B9_DATA) B9_DATAMAX "
	cQuery += "FROM "+ RetSqlName("SB9") +" SB9B "
	cQuery += "WHERE SB9B.B9_FILIAL = '"+ xFilial("SB9") + "' AND SB9B.B9_DATA <> '"+SPACE(TamSX3("B9_DATA")[1])+"' AND SB9B.B9_DATA <= '"+ DtoS(dDataAte)+"' AND SB9B.B9_COD = SB1.B1_COD AND SB9B.B9_LOCAL = SB2.B2_LOCAL AND SB9B.D_E_L_E_T_ = ' ')AND '"+ DtoS(dDataAte) +"' AND "
	cQuery += "SD2.D2_ORIGLAN <> 'LF' AND SF4.F4_FILIAL = '"+ xFilial("SF4") +"' AND SF4.F4_CODIGO = SD2.D2_TES AND "
	cQuery += "(SF4.F4_ESTOQUE = 'S' "
	cQuery += ") AND "
	cQuery += "SF4.D_E_L_E_T_ = ' ' AND SD2.D_E_L_E_T_ = ' ' ) "
	// --- Exist SD3
	cQuery += "OR EXISTS (SELECT 1 FROM "+ RetSqlName("SD3") +" SD3 WHERE SD3.D3_FILIAL = '"+ xFilial("SD3") +"' AND SD3.D3_COD = SB9.B9_COD AND "
	cQuery += "SD3.D3_LOCAL = SB9.B9_LOCAL AND SD3.D3_EMISSAO BETWEEN (SELECT MAX(SB9B.B9_DATA) B9_DATAMAX "
	cQuery += "FROM "+ RetSqlName("SB9") +" SB9B "
	cQuery += "WHERE SB9B.B9_FILIAL = '"+ xFilial("SB9") + "' AND SB9B.B9_DATA <> '"+SPACE(TamSX3("B9_DATA")[1])+"' AND SB9B.B9_DATA <= '"+ DtoS(dDataAte)+"' AND SB9B.B9_COD = SB1.B1_COD AND SB9B.B9_LOCAL = SB2.B2_LOCAL AND SB9B.D_E_L_E_T_ = ' ') AND '"+ DtoS(dDataAte) +"' "
	cQuery += "AND SD3.D3_ESTORNO = ' ' AND SD3.D_E_L_E_T_ = ' ' )) "
EndIf

//�����������������������������������������������������������������������Ŀ
//� Query dos produtos que NAO foram movimentados entre dUlmes e dDataAte �
//�������������������������������������������������������������������������
cQuery += "UNION ALL SELECT 'B' QRY, SB9.B9_FILIAL, ('N') STATS, SB9.B9_COD, SB9.B9_LOCAL, SB9.B9_DATA, SB9.B9_QINI, SB9.B9_VINI1 "
If lAliasD3E
	cQuery += ", "+ cCoalesce +"( D3E.D3E_CLIENT, '"+ CriaVar( 'D3E_CLIENT', .F. ) +"' ) D3E_CLIENT, "+ cCoalesce +"( D3E.D3E_LOJA, '"+ CriaVar( 'D3E_LOJA', .F. ) +"' ) D3E_LOJA "
Else
	cQuery += ",' ' D3E_CLIENT ,' ' D3E_LOJA "
EndIf
cQuery += "FROM "+ RetSqlName("SB9") +" SB9 "
cQuery += "JOIN "+ RetSqlName("SB1") +" SB1 "
cQuery += "ON SB1.B1_FILIAL = '"+ xFilial("SB1") +"' AND SB1.B1_COD = SB9.B9_COD AND SB1.D_E_L_E_T_ = ' ' "
If lAliasD3E
	cQuery += "LEFT JOIN "+ RetSqlName("D3E") +" D3E "
	cQuery += "ON D3E.D3E_FILIAL = '"+ xFilial("D3E") +"' AND D3E.D3E_COD = SB1.B1_COD AND D3E.D_E_L_E_T_ = ' ' "
	cQuery += "LEFT JOIN "+ RetSqlName("SA1") +" SA1 "
	cQuery += "ON SA1.A1_FILIAL = '"+ xFilial("SA1") +"' AND SA1.A1_COD = D3E.D3E_CLIENT AND SA1.A1_LOJA = D3E.D3E_LOJA AND SA1.D_E_L_E_T_ = ' ' "
EndIf
If lCpoBZTP
	cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
cQuery += "JOIN "+ RetSqlName("SB2") +" SB2 ON SB2.B2_FILIAL = '"+ xFilial("SB2") +"' AND "
cQuery += "SB2.B2_COD = SB9.B9_COD AND SB2.B2_LOCAL = SB9.B9_LOCAL AND SB2.D_E_L_E_T_ = ' ' WHERE "
// --- Where
If lCpoBZTP
	cQuery += " "+ cCoalesce +"( SBZ.BZ_TIPO, SB1.B1_TIPO ) "
Else
	cQuery += "SB1.B1_TIPO "
EndIF
cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") AND "
cQuery += "SB9.D_E_L_E_T_ = ' ' AND SB1.B1_FANTASM <> 'S' AND SB1.B1_CCCUSTO = ' ' AND SB1.B1_COD NOT LIKE 'MOD%' AND "
cQuery += "SB9.B9_DATA = (SELECT MAX(SB9B.B9_DATA) B9_DATAMAX "
cQuery += "FROM "+ RetSqlName("SB9") +" SB9B "
cQuery += "WHERE SB9B.B9_FILIAL = '"+ xFilial("SB9") + "' AND  SB9.B9_DATA <> '"+SPACE(TamSX3("B9_DATA")[1])+"' AND SB9B.B9_DATA <= '"+ DtoS(dDataAte)+"' AND SB9B.B9_COD = SB1.B1_COD AND SB9B.B9_LOCAL = SB2.B2_LOCAL AND SB9B.D_E_L_E_T_ = ' ')"
cQuery	+= "AND SB9.B9_FILIAL = '"+ xFilial("SB9") +"' AND "
If lTerc
	// --- Exist SB6
	cQuery += "(NOT EXISTS(SELECT 1 FROM "+ RetSqlName("SB6") +" SB6 , "+ RetSqlName("SF4") +" SF4 WHERE SB6.B6_FILIAL = '"+ xFilial("SB6") +"' AND "
	cQuery += "SB6.B6_PRODUTO = SB9.B9_COD AND SB6.B6_LOCAL = SB9.B9_LOCAL AND SB6.B6_PODER3 = 'R' AND "
	cQuery += "SB6.B6_EMISSAO <= '"+ DtoS(dDataAte) +"' AND SF4.F4_FILIAL = '"+ xFilial("SF4") +"' AND SF4.F4_CODIGO = SB6.B6_TES AND "
		cQuery += "SF4.F4_ESTOQUE = 'S' AND "
	cQuery += "SF4.D_E_L_E_T_ = ' ' AND SB6.D_E_L_E_T_ = ' ')) "
Else
	// --- Exist SD1
	cQuery += "(NOT EXISTS (SELECT 1 FROM "+ RetSqlName("SD1") +" SD1, "+ RetSqlName("SF4") +" SF4 WHERE SD1.D1_FILIAL = '"+ xFilial("SD1") +"' AND "
	cQuery += "SD1.D1_COD = SB9.B9_COD AND SD1.D1_LOCAL = SB9.B9_LOCAL AND SD1.D1_DTDIGIT BETWEEN (SELECT MAX(SB9B.B9_DATA) B9_DATAMAX "
	cQuery += "FROM "+ RetSqlName("SB9") +" SB9B "
	cQuery += "WHERE SB9B.B9_FILIAL = '"+ xFilial("SB9") + "' AND SB9B.B9_DATA <> '"+ Space(TamSX3("B9_DATA")[1]) +"' AND SB9B.B9_DATA <= '"+ DtoS(dDataAte)+"' AND SB9B.B9_COD = SB1.B1_COD AND SB9B.B9_LOCAL = SB2.B2_LOCAL AND SB9B.D_E_L_E_T_ = ' ') AND '"+ DtoS(dDataAte) +"' AND "
	cQuery += "SD1.D1_ORIGLAN <> 'LF' AND SF4.F4_FILIAL = '"+ xFilial("SF4") +"' AND SF4.F4_CODIGO = SD1.D1_TES AND "
	cQuery += "(SF4.F4_ESTOQUE = 'S' "
	cQuery += ") AND "
	cQuery += "SF4.D_E_L_E_T_ = ' ' AND SD1.D_E_L_E_T_ = ' ' ) "
	// --- Exist SD2
	cQuery += "AND NOT EXISTS (SELECT 1 FROM "+ RetSqlName("SD2") +" SD2, "+ RetSqlName("SF4") +" SF4 WHERE SD2.D2_FILIAL = '"+ xFilial("SD2") +"' AND "
	cQuery += "SD2.D2_COD = SB9.B9_COD AND SD2.D2_LOCAL = SB9.B9_LOCAL AND SD2.D2_EMISSAO BETWEEN (SELECT MAX(SB9B.B9_DATA) B9_DATAMAX "
	cQuery += "FROM "+ RetSqlName("SB9") +" SB9B "
	cQuery += "WHERE SB9B.B9_FILIAL = '"+ xFilial("SB9") + "' AND SB9B.B9_DATA <> '"+ Space(TamSX3("B9_DATA")[1]) +"' AND SB9B.B9_DATA <= '"+ DtoS(dDataAte)+"' AND SB9B.B9_COD = SB1.B1_COD AND SB9B.B9_LOCAL = SB2.B2_LOCAL AND SB9B.D_E_L_E_T_ = ' ') AND '"+ DtoS(dDataAte) +"' AND "
	cQuery += "SD2.D2_ORIGLAN <> 'LF' AND SF4.F4_FILIAL = '"+ xFilial("SF4") +"' AND SF4.F4_CODIGO = SD2.D2_TES AND "
	cQuery += "(SF4.F4_ESTOQUE = 'S' "
	cQuery += ") AND "
	cQuery += "SF4.D_E_L_E_T_ = ' ' AND SD2.D_E_L_E_T_ = ' ' ) "
	// --- Exist SD3
	cQuery += "AND NOT EXISTS (SELECT 1 FROM "+ RetSqlName("SD3") +" SD3 WHERE SD3.D3_FILIAL = '"+ xFilial("SD3") +"' AND SD3.D3_COD = SB9.B9_COD AND "
	cQuery += "SD3.D3_LOCAL = SB9.B9_LOCAL AND SD3.D3_EMISSAO BETWEEN (SELECT MAX(SB9B.B9_DATA) B9_DATAMAX "
	cQuery += "FROM "+ RetSqlName("SB9") +" SB9B "
	cQuery += "WHERE SB9B.B9_FILIAL = '"+ xFilial("SB9") + "'  AND SB9B.B9_DATA <= '"+ DtoS(dDataAte)+"' AND SB9B.B9_COD = SB1.B1_COD AND SB9B.B9_LOCAL = SB2.B2_LOCAL AND SB9B.D_E_L_E_T_ = ' ')AND '"+ DtoS(dDataAte) +"' "
	cQuery += "AND SD3.D3_ESTORNO = ' ' AND SD3.D_E_L_E_T_ = ' ' )) "
EndIf

//��������������������������������������������������������������������������������������������Ŀ
//� Query dos produtos incluidos via Saldo Inicial durante o periodo e n�o houve movimenta��o  �
//����������������������������������������������������������������������������������������������
cQuery += "UNION ALL "
cQuery += "SELECT 'C' QRY, SB9INI.B9_FILIAL,('S') STATS,SB9INI.B9_COD,SB9INI.B9_LOCAL,SB9INI.B9_DATA,SB9INI.B9_QINI,SB9INI.B9_VINI1 "
If lAliasD3E
	cQuery += ", "+ cCoalesce +"( D3E.D3E_CLIENT, '"+ CriaVar( 'D3E_CLIENT', .F. ) +"' ) D3E_CLIENT, "+ cCoalesce +"( D3E.D3E_LOJA, '"+ CriaVar( 'D3E_LOJA', .F. ) +"' ) D3E_LOJA "
Else
	cQuery += ",' ' D3E_CLIENT ,' ' D3E_LOJA "
EndIf
cQuery += "		FROM "+ RetSqlName("SB9") +" SB9INI "
cQuery += "JOIN "+ RetSqlName("SB1") +" SB1 ON SB1.B1_FILIAL = '"+ xFilial("SB1") +"' "
cQuery += "		AND SB1.B1_COD = SB9INI.B9_COD "
cQuery += "		AND SB1.D_E_L_E_T_ = ' ' "
If lAliasD3E
	cQuery += "LEFT JOIN "+ RetSqlName("D3E") +" D3E "
	cQuery += "ON D3E.D3E_FILIAL = '"+ xFilial("D3E") +"' AND D3E.D3E_COD = SB1.B1_COD AND D3E.D_E_L_E_T_ = ' ' "
	cQuery += "LEFT JOIN "+ RetSqlName("SA1") +" SA1 "
	cQuery += "ON SA1.A1_FILIAL = '"+ xFilial("SA1") +"' AND SA1.A1_COD = D3E.D3E_CLIENT AND SA1.A1_LOJA = D3E.D3E_LOJA AND SA1.D_E_L_E_T_ = ' ' "
EndIf
If lCpoBZTP
	cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
cQuery += "WHERE SB9INI.B9_FILIAL = '"+ xFilial("SB9") +"' "
cQuery +=		" AND SB9INI.B9_DATA <= '"+ DtoS(dDataAte) +"' "
cQuery +=		" AND SB9INI.D_E_L_E_T_ = ' ' "
cQuery +=		" AND SB1.B1_COD NOT LIKE 'MOD%' "
cQuery +=		" AND NOT EXISTS (SELECT 1 FROM "+ RetSqlName("SB9") +" SB9 WHERE  SB9.B9_FILIAL = '"+xFilial('SB9')+"' "
cQuery +=						" AND SB9.B9_COD = SB9INI.B9_COD "
cQuery +=						" AND SB9.B9_LOCAL = SB9INI.B9_LOCAL "
cQuery +=						" AND SB9.B9_DATA <> '"+ Space(TamSX3("B9_DATA")[1]) +"' AND SB9.B9_DATA <= '"+ DtoS(dDataAte) +"' "
cQuery +=						" AND SB9.D_E_L_E_T_ = ' ' ) "

If lCpoBZTP
	cQuery += " AND "+ cCoalesce +"( SBZ.BZ_TIPO, SB1.B1_TIPO ) "
Else
	cQuery += " AND SB1.B1_TIPO "
EndIF
cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
cQuery += "		AND SB1.B1_FANTASM <> 'S' "
cQuery += "		AND SB1.B1_CCCUSTO = ' ' "

//�����������������������������������������������������������������������Ŀ
//� Query de produtos com saldo gerado no MATA103, tem SB2 mas nao tem SB9�
//�������������������������������������������������������������������������
cQuery += "UNION ALL "
cQuery += "SELECT 'D' QRY, SB2.B2_FILIAL,('S') STATS,"
cQuery += " SB2.B2_COD B9_COD, "
cQuery += " SB2.B2_LOCAL B9_LOCAL, "
cQuery += " "+ cCoalesce +"( SB9.B9_DATA, '        ' ) B9_DATA, "
cQuery += " "+ cCoalesce +"( SB9.B9_QINI, 0 )  B9_QINI, "
cQuery += " "+ cCoalesce +"( SB9.B9_VINI1, 0 ) B9_VINI1 "
If lAliasD3E
	cQuery += ", "+ cCoalesce +"( D3E.D3E_CLIENT, '"+ CriaVar( 'D3E_CLIENT', .F. ) +"' ) D3E_CLIENT, "+ cCoalesce +"( D3E.D3E_LOJA, '"+ CriaVar( 'D3E_LOJA', .F. ) +"' ) D3E_LOJA "
Else
	cQuery += ",' ' D3E_CLIENT ,' ' D3E_LOJA "
EndIf
cQuery += "FROM "+ RetSqlName("SB2") +" SB2 "
cQuery += "JOIN "+ RetSqlName("SB1") +" SB1 ON SB1.B1_FILIAL = '"+ xFilial("SB1") +"' "
cQuery += "AND SB1.B1_COD = SB2.B2_COD "
cQuery += "AND SB1.D_E_L_E_T_ = ' ' "
If lAliasD3E
	cQuery += "LEFT JOIN "+ RetSqlName("D3E") +" D3E "
	cQuery += "ON D3E.D3E_FILIAL = '"+ xFilial("D3E") +"' AND D3E.D3E_COD = SB1.B1_COD AND D3E.D_E_L_E_T_ = ' ' "
	cQuery += "LEFT JOIN "+ RetSqlName("SA1") +" SA1 "
	cQuery += "ON SA1.A1_FILIAL = '"+ xFilial("SA1") +"' AND SA1.A1_COD = D3E.D3E_CLIENT AND SA1.A1_LOJA = D3E.D3E_LOJA AND SA1.D_E_L_E_T_ = ' ' "
EndIf
cQuery += "LEFT JOIN "+ RetSqlName("SB9") +" SB9 ON SB9.B9_FILIAL = '"+ xFilial("SB9") +"' AND SB9.B9_COD = SB2.B2_COD AND "
cQuery += "SB9.B9_LOCAL = SB2.B2_LOCAL AND  SB9.B9_DATA <= '"+ DtoS(dDataAte) +"'  AND SB9.D_E_L_E_T_ = ' ' "
If lCpoBZTP
	cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
cQuery += "WHERE SB2.B2_FILIAL = '"+ xFilial("SB2") +"' AND "
If lCpoBZTP
	cQuery += " "+ cCoalesce +"( SBZ.BZ_TIPO, SB1.B1_TIPO ) "
Else
	cQuery += "SB1.B1_TIPO "
EndIF
cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") AND "
cQuery += "SB2.D_E_L_E_T_ = ' ' AND SB1.B1_FANTASM <> 'S' AND SB1.B1_CCCUSTO = ' ' AND "
cQuery += "SB1.B1_COD NOT LIKE 'MOD%' "
cQuery += "AND SB9.B9_DATA IS NULL "

// --- Order
cQuery += "ORDER BY 2,4,5"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTRB,.T.,.T.)

//�����������������������������Ŀ
//� Monta o Arquivo de Trabalho �
//�������������������������������
aTam := TamSX3("B9_FILIAL")
Aadd(aCampos,{"B9_FILIAL",aTam[3],aTam[1],aTam[2]})

Aadd(aCampos,{"STATS","C",1,0})

aTam := TamSX3("B9_COD")
Aadd(aCampos,{"B9_COD",aTam[3],aTam[1],aTam[2]})

aTam := TamSX3("B9_LOCAL")
Aadd(aCampos,{"B9_LOCAL",aTam[3],aTam[1],aTam[2]})

aTam := TamSX3("B9_DATA")
Aadd(aCampos,{"B9_DATA",aTam[3],aTam[1],aTam[2]})

aTam := TamSX3("B9_QINI")
Aadd(aCampos,{"B9_QINI",aTam[3],aTam[1],aTam[2]})

If lAliasD3E
	aTam := TamSX3("D3E_CLIENT")
Else
	aTam := TamSX3("A1_COD")
EndIf
Aadd(aCampos,{"D3E_CLIENT",aTam[3],aTam[1],aTam[2]})

If lAliasD3E
	aTam := TamSX3("D3E_LOJA")
Else
	aTam := TamSX3("A1_LOJA")
EndIf
Aadd(aCampos,{"D3E_LOJA",aTam[3],aTam[1],aTam[2]})

cArqTmp := CriaTrab(Nil,.F.)

// Nome da tabela com o saldo de produtos
cAliasTmp := cArqTmp
If TcCanOpen(cArqTmp)
	TcDelFile(cArqTmp)
EndIf
FwDbCreate(cArqTmp,aCampos,"TOPCONN",.T.)
DbUseArea(.T.,"TOPCONN",cArqTmp,cAliasTmp,.T.)

//���������������������������������������������������Ŀ
//� Grava o Arquivo de Trabalho com os dados da Query �
//�����������������������������������������������������
While !(cAliasTRB)->(Eof())
	RecLock(cAliasTmp,.T.)
	(cAliasTmp)->B9_FILIAL	:= (cAliasTRB)->B9_FILIAL
	(cAliasTmp)->STATS		:= (cAliasTRB)->STATS
	(cAliasTmp)->B9_COD		:= (cAliasTRB)->B9_COD
	(cAliasTmp)->B9_LOCAL	:= (cAliasTRB)->B9_LOCAL
	(cAliasTmp)->B9_DATA	:= StoD((cAliasTRB)->B9_DATA)
	(cAliasTmp)->B9_QINI	:= (cAliasTRB)->B9_QINI
	(cAliasTmp)->D3E_CLIENT	:= (cAliasTRB)->D3E_CLIENT
	(cAliasTmp)->D3E_LOJA	:= (cAliasTRB)->D3E_LOJA
	(cAliasTmp)->(MsUnLock())
	(cAliasTRB)->(DbSkip())
EndDo
(cAliasTRB)->(dbCloseArea())
(cAliasTmp)->(dbGoTop())

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CalcThread �Autor � TOTVS S/A            � Data �30/08/2016���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula o Range de produtos de cada Thread que sera        ���
���          � processada.                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cAliasTmp = Alias do arquivo de trabalho                   ���
���          � nThreads  = Numero de Threads                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function CalcThread(cAliasTmp,nThreads)

Local nNumRec		:= 0
Local nTotRec		:= 0
Local nX			:= 0
Local nAuxIni		:= 1
Local nAuxFim		:= 0
Local cProd			:= ""
Local aRet			:= {}
Local nPosFim		:= 0

nTotRec := (cAliasTmp)->(LastRec())
nNumRec := Int(nTotRec / nThreads)

nAuxFim := nTotRec

If nThreads > 1
	//������������������������������������������������������������Ŀ
	//� Ajusta o RECNO de cada Thread, pois Produtos com saldo     �
	//� em mais de um Armazem devem ser processados dentro de uma  �
	//� uma mesma Thread, caso contrario o resultado ficara errado �
	//��������������������������������������������������������������
	For nX := 1 to nThreads
		// Recno inicial da Thread
		If nX == 1
			nAuxIni := 1
		Else
			nAuxIni := aRet[nX-1][2] + 1
		EndIf

		nPosFim	:= nAuxIni+nNumRec
		If nPosFim < nTotRec
			(cAliasTmp)->(dbGoto(nPosFim))
			While !(cAliasTmp)->(Eof())
				cProd := (cAliasTmp)->B9_COD
				// Recno final da Thread
				nAuxFim := (cAliasTmp)->(Recno())
				(cAliasTmp)->(dbSkip())
				If cProd <> (cAliasTmp)->B9_COD
					Exit
				EndIf
			EndDo
		Else
			nAuxFim := nTotRec
		EndIf

		// Adiciona aRet
		Aadd(aRet,{nAuxIni,nAuxFim})

		// Verifica se o ultimo Recno da Thread e igual ao total de recnos
		If nAuxFim == nTotRec
			Exit
		EndIf
	Next nX

	If Len(aRet)<> nThreads
		nThreads:= Len(aRet)
	EndIf
EndIf

If nThreads < 2 .And. Len(aRet) == 0
	Aadd(aRet,{nAuxIni,nAuxFim})
EndIf

(cAliasTmp)->(dbGoTop())

Return aRet


/*�����������������������������������������������������������������������������������������������������������
|	REGISTRO H010: INVENT�RIO.																							|
\	Tratamento destinado a gera��o de arquivo Bloco H010 															/
|	Este registro deve ser informado para discriminar os itens existentes no estoque.							|
������������������������������������������������������������������������������������������������������������*/


/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � REGH010        � Autor � Materiais        � Data � 28/07/14 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Funcao responsavel pela gravacao do Registro H010           ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cAliasTRB   = Alias do arquivo de trabalho do Bloco         ���
���          � dDataDe     = Data Inicial da Apuracao                      ���
���          � dDataAte    = Data Final da Apuracao                        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function SPDBlocH(cAliBLH,dDataDe,dDataAte)

BlocoH460(dDataAte,@cAliBLH)

Return

/*
*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � BLHCriaTRB     � Autor � Materiais        � Data � 28/07/14 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Criacao do arquivo temporario para retorno de informacoes.  ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cBloco    = Nome do Bloco para geracao arquivo de trabalho  ���
���          � cAliasTRB = Nome do arquivo de trabalho                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function BLHCriaTRB( nOpcx, xEmpAnt, xFilAnt, cBloco, cAliasTRB, lJob )
Local lRet			:= .T.
Local nX			:= 0
Local aRet			:= {}
Local aIndice		:= {}
Local aLayout		:= {}
Local cDirSPDK		:= GetSrvProfString("Startpath","")

Default nOpcx		:= 1
Default lJob		:= .F.
Default xEmpAnt		:= ''
Default xFilAnt		:= ''
Default cBloco		:= ""
Default cAliasTRB	:= ""

If lJob
	RpcSetType( 3 )
	RpcSetEnv( xEmpAnt, xFilAnt )
EndIf

Do Case
Case nOpcx == 1
	//����������������������������������������������������������Ŀ
	//� Posicoes: [1]Campos / [2]Indices                         �
	//������������������������������������������������������������
	aLayout := BLHLayout(cBloco)
	If !ExistDir(cDirSPDK)
		MakeDir(cDirSPDK)
	EndIf

	//����������������������������������������������������������Ŀ
	//� Criacao do Arquivo de Trabalho                           �
	//������������������������������������������������������������
	If !Empty(cBloco)
		FWdbCreate(cAliasTRB, aLayout[1], __cRdd, .T. )
		dbUseArea(.T., __cRdd, cAliasTRB, cAliasTRB, .T. )
		For nX := 1 to Len(aLayout[2])
			Aadd( aIndice, { ( cAliasTRB + Alltrim( STR( nX ) ) ), aLayout[ 2 ][ nX ] } )
			dbCreateIndex( ( cAliasTRB + Alltrim( STR( nX ) ) ), aLayout[ 2 ][ nX ] )
		Next nX
		dbSetOrder(1)
	EndIf
	aRet := { aIndice, cAliasTRB }

Case nOpcx == 2
	If TcCanOpen( cAliasTRB )
		lRet := TcDelFile( cAliasTRB )
	EndIf
	aRet := { lRet }

EndCase

If lJob
	RpcClearEnv()
EndIf

Return aRet


/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � BLHLayout      � Autor � Materiais		 � Data � 28/07/14 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Funcao responsavel pela montagem do layout do bloco         ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cBloco = Nome do bloco para geracao do Layout               ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function BLHLayout(cBloco)

Local aCampos		:= {}
Local aIndices		:= {}
Local nTamFil		:= TamSX3("D1_FILIAL" )[1]
Local nTamCod		:= TamSX3("B1_COD"    )[1]
Local nTamUNID 		:= TamSX3("B1_UM"     )[1]
Local nTamCC		:= TamSX3("B1_CONTA"  )[1]
Local aTamPic  		:= TamSX3("B1_PICM"   )
Local nTamOri  		:= TamSX3("B1_ORIGEM" )[1]
Local nTamClF  		:= TamSX3("B1_CLASFIS")[1]
Local nDecVal		:= TamSX3("B2_CM1"    )[2]
// ------ Tamanhos conforme especificado no Guia EFD ------
Local nTamReg		:= 4
Local aTamQtd		:= {16,3}
Local aTamVlr		:= {16,2}
Local aTmVlUn		:= {16,6}
// --------------------------------------------------------
Local aTamTot		:= {21,nDecVal}	// Utilizado no calculo do valor unitario para bater com o MATR460 ***Nao interfere no layout do EFD***
Default cBloco		:= ""

//������������������������������������������������������������Ŀ
//�                     *** ATENCAO!!! ***                     �
//� Antes de realizar alteracoes nos tamanhos dos campos para  �
//� montagem dos arquivos de trabalho, verificar especificacao �
//� deles no Guia Pratico EFD no site do SPED Fiscal(Receita)  �
//��������������������������������������������������������������

Do Case
	Case cBloco == "H010"
		//����������������������������������������������������������Ŀ
		//� Criacao do Arquivo de Trabalho - BLOCO H010              �
		//������������������������������������������������������������
	 	aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",nTamFil			,0	})
		AADD(aCampos,{"REG"			,"C",nTamReg			,0	})
		AADD(aCampos,{"COD_ITEM"	,"C",nTamCod			,0	})
		AADD(aCampos,{"UNID"		,"C",nTamUNID			,0	})
		AADD(aCampos,{"QTD"			,"N",aTamQtd[1],aTamQtd[2]	})
		AADD(aCampos,{"VL_UNIT"		,"N",aTmVlUn[1],aTmVlUn[2]	})
		AADD(aCampos,{"VL_ITEM"		,"N",aTamVlr[1],aTamVlr[2]	})
		AADD(aCampos,{"IND_PROP"	,"C",1					,0	})
		AADD(aCampos,{"COD_PART"	,"C",60					,0	})
		AADD(aCampos,{"COD_CTA"		,"C",nTamCC				,0	})
		AADD(aCampos,{"VL_ITEM_IR"	,"N",aTamVlr[1],aTamVlr[2]	})
		AADD(aCampos,{"ALQ_PICM"	,"N",aTamPic[1],aTamPic[2]	})
		AADD(aCampos,{"COD_ORIG"	,"C",nTamOri		        })
		AADD(aCampos,{"CL_CLASS"	,"C",nTamClF              	})
		AADD(aCampos,{"TOTALDC"		,"N",aTamTot[1],aTamTot[2]	})

		// Indices
		AADD(aIndices,"FILIAL+COD_ITEM+IND_PROP+COD_PART")
EndCase

Return {aCampos,aIndices}

//----------------------------------------------------------------------------------------------------------//
//	Ponto de entrada para geracao do Bloco H010     														//
//----------------------------------------------------------------------------------------------------------//
Static Function BlocoH460(dDataAte,cAliBLH)
Local nInd			:= 0
Local aArea			:= GetArea()
Local cCodPart		:= ""
Local aRetJob		:= {}
Local cMVARQPROD	:= SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local lExistArq		:= .F.
Local lClassFIs		:= .F.
Local cARQTMP		:= "ARQTMP"
Local cNameTable	:= ""
Local cBloco		:= "H010"
Local cAliasTRB 	:= Upper( cBloco )+"_"+CriaTrab(,.F.)

SaveInter()

If !Empty(dDataAte)
	cNameTable := "H_"+DTOS(dDataAte)+STRTRAN(FWGrpCompany() ," " ,"_")+"_"+STRTRAN(cFilant ," " ,"_")
	lExistArq  := TcCanOpen( cNameTable )
EndIf

If lExistArq
	aRetJob := StartJob( "BLHCriaTRB", GetEnvServer(), .T., 1, FwGrpCompany(), FwCodFil(), cBloco, cAliasTRB, .T. )
	cAliBLH	:= aRetJob[ 2 ]

	dbUseArea( .T., __cRdd, cAliasTRB, cAliBLH, .F., .F. )
	dbSelectArea( cAliBLH )
	For nInd := 1 To Len( aRetJob[ 1 ] )
		Set Index To ( aRetJob[ 1 ][ nInd ][ 1 ] )
	Next nInd
	( cAliBLH )->( dbSetOrder( 1 ) )

	dbUseArea(.T. , __cRdd ,cNameTable ,cARQTMP ,.T.)
	dbSelectArea( cARQTMP )

	SB1->(dbSetOrder(1))
	If cMVARQPROD == "SBZ"
		SBZ->(dbSetOrder(1))
	EndIf

	dbSelectArea( cArqTMP )
	( cArqTMP )->( dbGoTop() )
	While !(cArqTMP)->(EOF())
		If (cArqTMP)->SITUACAO $ "3|6 "
			(cArqTMP)->(dbSkip())
			Loop
		EndIf

		SB1->(MsSeek(xFilial("SB1")+(cArqTMP)->PRODUTO))
		If cMVARQPROD == "SBZ"
			SBZ->(MsSeek(xFilial("SBZ")+(cArqTMP)->PRODUTO))
			lClassFIs := A460ClasFis()
		EndIf

		If !Empty((cArqTMP)->TPCF)
			cCodPart := Iif((cArqTMP)->TPCF == "C","SA1","SA2")+(cArqTMP)->(CLIFOR+LOJA)
		EndIf

		If (cArqTMP)->SITUACAO $ "1|2|7" .And. (cAliBLH)->(MsSeek((cArqTMP)->(FILIAL+PRODUTO)+"0"))
			RecLock( cAliBLH, .F. )
		ElseIf ((cArqTMP)->SITUACAO == "4" .And. (cAliBLH)->(MsSeek((cArqTMP)->(FILIAL+PRODUTO)+"2"+cCodPart))) ;
			.Or. ((cArqTMP)->SITUACAO == "5" .And. (cAliBLH)->(MsSeek((cArqTMP)->(FILIAL+PRODUTO)+"1"+cCodPart)))
			RecLock( cAliBLH, .F. )
		Else
			RecLock( cAliBLH, .T. )
		EndIf
		REG         := "H010"
		CL_CLASS    := IIF (cMVARQPROD == "SBZ" .And. lClassFIs ,SBZ->BZ_CLASFIS,SB1->B1_CLASFIS)
		COD_CTA     := RetFldProd((cArqTMP)->PRODUTO,"B1_CONTA")
		COD_ITEM    := (cArqTMP)->PRODUTO
		If !Empty((cArqTMP)->TPCF)
			COD_PART := cCodPart
		EndIf
		(cAliBLH)->FILIAL     := (cArqTMP)->FILIAL
		IND_PROP   := Iif((cArqTMP)->SITUACAO $ "1|2|7","0",Iif((cArqTMP)->SITUACAO == "5","1","2"))
		COD_ORIG   := RetFldProd((cArqTMP)->PRODUTO,"B1_ORIGEM")
		ALQ_PICM   := RetFldProd((cArqTMP)->PRODUTO,"B1_PICM")
		QTD        += (cArqTMP)->QUANTIDADE
		UNID       := (cArqTMP)->UM
		VL_ITEM    += (cArqTMP)->TOTAL
		VL_ITEM_IR += (cArqTMP)->TOTAL
		TOTALDC    += (cArqTMP)->TOTAL
		VL_UNIT    := TOTALDC / QTD

	 	( cAliBLH )->( MsUnLock() )

		(cArqTMP)->(dbSkip())
	End

	(cArqTMP)->(dbCloseArea())
EndIf

RestInter()
RestArea(aArea)
Return .T.



/*/{Protheus.doc} A460ClasFis
(long_description)
@type  Function
@author TOTVS
@since 01/04/2020
@version version
@param
@return lret se o campo esta sendo usado.
@example
(examples)
@see (links_or_references)
/*/
Function A460ClasFis()
Local cX3_USADO := ' '
Local lRet		:= .F.
cX3_USADO := GetSx3Cache("BZ_CLASFIS","X3_USADO")

If x3USO(cX3_USADO)
	lRet := .T.
else
	lRet :=	.F.
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} BlkApgArq
Fun�ao de fecha os alias e dropa as tabelas temporarias criadas para o bloco K

@author Andre Maximo
@since 04/01/2018
@version 1.0
@Param arqTMP
/*/
//-------------------------------------------------------------------
Function BlkApgArq()
Local nX	:= 0

//����������������������������������Ŀ
//� Fecha os Arquivos Temporarios    �
//������������������������������������
For nX := 1 To Len(aTmpRegK)
	If Empty(aTmpRegK[nX,2]) // se n�o tiver o nome da tabela ent�o foi criada via FWTemporaryTable
		aTmpRegK[nX,4]:Delete()
		FreeObj(aTmpRegK[nX,4])

	Else
		If Select(aTmpRegK[nX,1])>0
			(aTmpRegK[nX,1])->(DbCloseArea())
		EndIf

		If TcCanOpen( aTmpRegK[nX,2] )
			TcDelFile( aTmpRegK[nX,2] )
		EndIf
		aSize(aTmpRegK[nX,3],0)
	EndIf
	aSize(aTmpRegK[nX],0)

Next nX

DelTblK200() // deleta as tabelas com inicio K_K200 que existiverem no banco de dados

aSize(aTmpRegK,0)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetPerdMov
Fun�ao que retornar a quantidade apontada de perda no MATA685
@author Andre Maximo
@since 04/01/2018
@version 1.0
@Param arqTMP
/*/
//-------------------------------------------------------------------
Function GetPerdMov(cOP,cCodComp,dDataDe,dDataAte)

Local nQuant
Local cFilialSBC := xFilial("SBC")
Local cAliasTRB := CriaTrab(Nil,.F.)

BeginSql Alias cAliasTRB
	SELECT ISNULL(SUM(BC_QUANT),0) BC_QUANT
		FROM %Table:SBC% SBC
			WHERE	SBC.BC_FILIAL = %Exp:cFilialSBC% AND
					SBC.BC_PRODUTO = %Exp:cCodComp% AND
					SBC.BC_CODDEST = ' ' AND
					SBC.BC_NUMSEQ <> ' ' AND
					SBC.BC_OP = %Exp:cOP % AND
					SBC.BC_DATA BETWEEN %Exp: DtoS(dDataDe) % AND %Exp: DtoS(dDataAte)% AND
					SBC.%NotDel%
EndSql
nQuant:= (cAliasTRB)->BC_QUANT

(cAliasTRB)->(dbCloseArea())

Return(nQuant)

//-------------------------------------------------------------------
/*/{Protheus.doc} Fun��o que retorna a vers�o do leiaute do bloco K
@author Flavio Lopes Rasta
@since 13/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function VerBlocoK(dDataDe)
Local cVerRet := ""

Do Case
	Case(Year(dDataDe)>2021)
		cVerRet := "016"
	Case(Year(dDataDe)>=2019)
		cVerRet := "013"
	Case(Year(dDataDe)==2018)
		cVerRet := "012"
EndCase

Return cVerRet

/*/{Protheus.doc} REGK300
Geracao dos registros do K300, K301 e K302 referentes ao movimentos internos de
requisicao e produ��o de ordem de producao em terceiros, a qual a estrutura do
prduto seja negativa ocorrido no periodo de apuracao do SPED FISCAL
@author reynaldo
@since 19/09/2018
@version 1.0
@return ${return}, ${return_description}
@param cAliK300, characters, descricao
@param cAliK301, characters, descricao
@param cAliK302, characters, descricao
@param dDataDe, date, descricao
@param dDataAte, date, descricao
@param lGerLogPro, logical, descricao
@param lRePross, logical, descricao
@type function
/*/
Static Function REGK300(cAliK300,cAliK301,cAliK302,dDataDe,dDataAte, lGerLogPro,lRePross)
	REGK302(cAliK302,cAliK301,cAliK300,dDataDe,dDataAte,lGerLogPro,lRePross)
Return

/*/{Protheus.doc} REGK301
Geracao dos registros do K301 referentes ao movimentos internos de produ��o de
ordem de producao em terceiros, a qual a estrutura do produto seja negativa
ocorrido no periodo de apuracao do SPED FISCAL
@author reynaldo
@since 19/09/2018
@version 1.0
@return ${return}, ${return_description}
@param cAliK301, characters, descricao
@param cAliK300, characters, descricao
@param dDataDe, date, descricao
@param dDataAte, date, descricao
@param cEmissao, characters, descricao
@param cProdPA, characters, descricao
@param lGerLogPro, logical, descricao
@param lRepross, logical, descricao
@type function
/*/
Static Function REGK301(cAliK301,cAliK300,dDataDe,dDataAte,cEmissao,cProdPA,lGerLogPro,lRepross)
Local cQuery	:= ""
Local cAliasTMP	:= CriaTrab(Nil,.F.)
Local lK301		:= .F.

Default lGerLogPro	:= .T.
Default lRepross	:= .T.

cQuery := ""
cQuery += "SELECT SUM(SD3.D3_QUANT) QUANT "
cQuery += "	,SD3.D3_COD "
cQuery += "	,SD3.D3_FILIAL "
cQuery += "	,SD3.D3_EMISSAO "
cQuery += "FROM "+RetSQLName("SD3")+" SD3 "
cQuery += "JOIN "+RetSQLName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery += "	AND SB1.B1_COD = SD3.D3_COD "
cQuery += "	AND SB1.B1_CCCUSTO = ' ' "
cQuery += "	AND SB1.D_E_L_E_T_ = ' ' "
If lCpoBZTP
	cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
cQuery += " INNER JOIN "+RetSQLName("SC2")+" SC2 ON  SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD = SD3.D3_OP "
cQuery += "	AND SC2.C2_FILIAL = '"+xFilial('SC2')+"' "
cQuery += "	AND SC2.C2_ITEM <> 'OS' "
cQuery += "	AND SC2.C2_TPPR IN ('E') "
cQuery += "	AND SC2.D_E_L_E_T_ = ' ' "
cQuery += "WHERE SD3.D3_FILIAL = '"+xFilial("SD3")+"' "
cQuery += "	AND SD3.D3_ESTORNO = ' ' "
cQuery += "	AND SD3.D3_CF IN ( "
cQuery += "		'PR0' "
cQuery += "		,'PR1' "
cQuery += "		) "
cQuery += "	AND SD3.D3_COD NOT LIKE 'MOD%' "
cQuery += "	AND SD3.D3_EMISSAO BETWEEN '"+DTOS(dDataDe)+"' "
cQuery += "		AND '"+DTOS(dDataAte)+"' "
cQuery += "	AND SD3.D3_EMISSAO = '"+cEmissao+"' "
cQuery += "	AND SD3.D3_COD = '"+cProdPA+"' "
cQuery += "	AND SD3.D_E_L_E_T_ = ' ' "
If lCpoBZTP
	cQuery += "		AND COALESCE(SBZ.BZ_TIPO,SB1.B1_TIPO) IN ( "
Else
	cQuery += "		AND SB1.B1_TIPO IN ( "
EndIf
cQuery += cTipo03+","+cTipo04
cQuery += "		) "
cQuery += "GROUP BY SD3.D3_FILIAL "
cQuery += "	,SD3.D3_EMISSAO "
cQuery += "	,SD3.D3_COD "
cQuery += "HAVING SUM(D3_QUANT) > 0 "
cQuery += "UNION ALL "
cQuery += "SELECT SUM(SD3.D3_QUANT) QUANT "
cQuery += "	,SD3.D3_COD "
cQuery += "	,SD3.D3_FILIAL "
cQuery += "	,SD3.D3_EMISSAO "
cQuery += "FROM "+RetSQLName("SD3")+" SD3 "
cQuery += "JOIN "+RetSQLName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery += "	AND SB1.B1_COD = SD3.D3_COD "
cQuery += "	AND SB1.B1_FANTASM != 'S' "
cQuery += "	AND SB1.B1_CCCUSTO = ' ' "
cQuery += "	AND SB1.D_E_L_E_T_ = ' ' "
If lCpoBZTP
	cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
cQuery += " INNER JOIN "+RetSQLName("SC2")+" SC2 ON  SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD = SD3.D3_OP "
cQuery += "	AND SC2.C2_FILIAL = '"+xFilial('SC2')+"' "
cQuery += " AND SC2.C2_PRODUTO = '"+cProdPA+"' "
cQuery += "AND SC2.C2_ITEM <> 'OS' "
cQuery += "AND SC2.C2_TPPR IN ('E') "
cQuery += "AND SC2.D_E_L_E_T_ = ' ' "
cQuery += "WHERE SD3.D3_FILIAL = '"+xFilial("SD3")+"' "
cQuery += "	AND SD3.D3_CF = 'DE1' "
cQuery += "	AND SD3.D3_ESTORNO = ' ' "
cQuery += "	AND SD3.D3_COD NOT LIKE 'MOD%' "
cQuery += "	AND SD3.D3_EMISSAO BETWEEN '"+DTOS(dDataDe)+"' "
cQuery += "	AND '"+DTOS(dDataAte)+"' "
cQuery += "	AND SD3.D3_EMISSAO = '"+cEmissao+"' "
cQuery += "	AND SD3.D_E_L_E_T_ = ' '"
If lCpoBZTP
	cQuery += "		AND COALESCE(SBZ.BZ_TIPO,SB1.B1_TIPO) IN ( "
Else
	cQuery += "		AND SB1.B1_TIPO IN ( "
EndIf
cQuery += "		"+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+" "
cQuery += "		) "
cQuery += "GROUP BY SD3.D3_FILIAL "
cQuery += "	,SD3.D3_EMISSAO "
cQuery += "	,SD3.D3_COD "
cQuery += "HAVING SUM(D3_QUANT) > 0 "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)


While !(cAliasTmp)->(Eof())
	 Reclock(cAliK301,.T.)
	 (cAliK301)->FILIAL		:= (cAliasTmp)->D3_FILIAL
	 (cAliK301)->CHAVE		:= cEmissao+cProdPA
	 (cAliK301)->REG			:= "K301"
	 (cAliK301)->COD_ITEM   := (cAliasTmp)->D3_COD
	 (cAliK301)->QTD        := (cAliasTmp)->QUANT
	 (cAliK301)->(MsUnLock())
	 nRegsto++
	 lK301 := .T.
	 If !((cAliK300)->(MsSeek((cAliasTmp)->D3_FILIAL+cEmissao)))
		  Reclock(cAliK300,.T.)
		  (cAliK300)->FILIAL		:= (cAliasTmp)->D3_FILIAL
		  (cAliK300)->REG			:= "K300"
		  (cAliK300)->DT_PROD   := STOD((cAliasTmp)->D3_EMISSAO)
		  (cAliK300)->CHAVE		:= cEmissao
		  (cAliK300)->(MsUnLock())
		  nRegsto++
	 EndIf
	 (cAliasTmp)->(dbSkip())
EndDo


Return lK301

/*/{Protheus.doc} REGK302
Geracao dos registros do K301 referentes ao movimentos internos de produ��o de
ordem de producao em terceiros, a qual a estrutura do produto seja negativa
ocorrido no periodo de apuracao do SPED FISCAL
@author reynaldo
@since 19/09/2018
@version 1.0
@return ${return}, ${return_description}
@param cAliK302, characters, descricao
@param cAliK301, characters, descricao
@param cAliK300, characters, descricao
@param dDataDe, date, descricao
@param dDataAte, date, descricao
@param lGerLogPro, logical, descricao
@param lRepross, logical, descricao
@type function
/*/
Static Function REGK302(cAliK302,cAliK301,cAliK300,dDataDe,dDataAte,lGerLogPro,lRepross)
Local cAliasTmp	:= CriaTrab(Nil,.F.)
Local cQuery	:= ""
Local lRet		:= .F.

Default lGerLogPro	:= .T.
Default lRepross	:= .T.

cQuery := ""
cQuery += "SELECT SUM(CASE "
cQuery += "			WHEN SD3.D3_CF LIKE ('DE%') "
cQuery += "				THEN (SD3.D3_QUANT * - 1) "
cQuery += "			WHEN SD3.D3_CF LIKE ('RE%') "
cQuery += "				THEN (SD3.D3_QUANT) "
cQuery += "			ELSE 0 "
cQuery += "			END) QUANT "
cQuery += "	,SD3.D3_COD "
cQuery += "	,SD3.D3_EMISSAO "
cQuery += "	,SC2.C2_PRODUTO "
cQuery += "	,SD3.D3_FILIAL "
cQuery += "FROM "+RetSqlName("SD3")+" SD3 "
cQuery += "JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' "
cQuery += " AND SB1.B1_COD = SD3.D3_COD "
cQuery += " AND SB1.B1_CCCUSTO = ' ' "
cQuery += " AND SB1.B1_COD NOT LIKE 'MOD%' "
cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
If lCpoBZTP
	cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' "
	cQuery += "AND SBZ.BZ_COD = SB1.B1_COD "
	cQuery += "AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
cQuery += "JOIN "+RetSqlName("SC2")+" SC2 ON SD3.D3_OP = SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD "
cQuery += "AND SC2.C2_FILIAL = '"+xFilial('SC2')+"' "
cQuery += "AND SC2.C2_ITEM <> 'OS' "
cQuery += "AND SC2.C2_TPPR IN ('E') "
cQuery += "AND SC2.D_E_L_E_T_ = ' ' "
cQuery += "WHERE SD3.D3_FILIAL = '"+xFilial('SD3')+"' "
cQuery += " AND SD3.D3_ESTORNO = ' ' "
cQuery += " AND (SD3.D3_CF LIKE ('RE%') OR SD3.D3_CF LIKE ('DE%')) "
cQuery += " AND SD3.D3_EMISSAO BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"' "
cQuery += " AND SD3.D3_CF <> 'DE1' "
cQuery += " AND SD3.D_E_L_E_T_ = ' ' "
cQuery += " AND "
If lCpoBZTP
	cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
Else
	cQuery += "SB1.B1_TIPO "
EndIf
cQuery += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
cQuery += "	AND EXISTS ( "
cQuery += "		SELECT 1 FROM "+RetSQLName("SG1")+" SG1 "
cQuery += "		JOIN "+RetSQLName("SB1")+" SB1COMP ON SB1COMP.B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery += "			AND SB1COMP.B1_COD = SG1.G1_COMP "
cQuery += "			AND SB1COMP.B1_CCCUSTO = ' ' "
cQuery += "			AND SB1COMP.B1_COD NOT LIKE 'MOD%' "
cQuery += "			AND SB1COMP.D_E_L_E_T_ = ' ' "
cQuery += "		WHERE SG1.G1_FILIAL = '"+xFilial("SG1")+"' "
cQuery += "			AND SG1.G1_COD = SC2.C2_PRODUTO "
cQuery += "			AND SG1.G1_REVINI <= CASE WHEN SC2.C2_REVISAO = ' ' THEN SB1COMP.B1_REVATU ELSE SC2.C2_REVISAO END "
cQuery += "			AND SG1.G1_REVFIM >= CASE WHEN SC2.C2_REVISAO = ' ' THEN SB1COMP.B1_REVATU ELSE SC2.C2_REVISAO END "
cQuery += "			AND SG1.G1_QUANT < 0 "
cQuery += "			AND SG1.G1_INI <= '"+DTOS(dDataDe)+"' "
cQuery += "			AND SG1.G1_FIM >= '"+DTOS(dDataAte)+"' "
cQuery += "			AND SG1.D_E_L_E_T_ = ' ' "
cQuery += "		) "
cQuery += "GROUP BY SD3.D3_EMISSAO,SC2.C2_PRODUTO, SD3.D3_COD, SD3.D3_FILIAL "
cQuery += "HAVING SUM(D3_QUANT) >0 "
cQuery += "ORDER BY 4,3,2"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

While !(cAliasTmp)->(Eof())
	If REGK301(cAliK301,cAliK300,dDataDe,dDataAte,(cAliasTmp)->D3_EMISSAO,(cAliasTmp)->C2_PRODUTO )
		Reclock(cAliK302,.T.)
		(cAliK302)->FILIAL		:= (cAliasTmp)->D3_FILIAL
		(cAliK302)->CHAVE		:= (cAliasTmp)->D3_EMISSAO+(cAliasTmp)->C2_PRODUTO
		(cAliK302)->REG			:= "K302"
		(cAliK302)->COD_ITEM	:= (cAliasTmp)->D3_COD
		(cAliK302)->QTD			:= (cAliasTmp)->QUANT
		(cAliK302)->(MsUnLock())
		nRegsto++
	EndIf
	(cAliasTmp)->(dbSkip())
EndDo

// atualiza os registros SD3 que foram processados no periodo
If lGerLogPro
	BlkPro302(dDataDe,dDataAte)
	BlkPro301(dDataDe,dDataAte)
EndIf
//----------------------//
// Grava Tabela de Hist //
//----------------------//
BlkGrvTab(cAliK300,"D3R",aTmpRegK[K300][4],dDataAte,lRepross)
BlkGrvTab(cAliK301,"D3S",aTmpRegK[K301][4],dDataAte,lRepross)
BlkGrvTab(cAliK302,"D3T",aTmpRegK[K302][4],dDataAte,lRepross)

(cAliasTmp)->(dbCloseArea())

Return lRet

/*/{Protheus.doc} GetSldTerc
Gera registros para o K200 referentes a produtos de terceiros ou em terceiros
@author reynaldo
@since 08/10/2018
@version 1.0
@return ${return}, ${return_description}
@param cTipoTerc, characters, descricao
@param dDataAte, date, descricao
@param cCodProdDe, characters, descricao
@param cCodProdAte, characters, descricao
@param cAliK200, characters, descricao
@param nSldTesN3, numeric, descricao
@type function
/*/
Static Function GetSldTerc(cTipoTerc ,dDataAte ,cCodProdDe ,cCodProdAte ,cAliK200, cAliSumTer)
Local cQuery     := ""
Local cSB9Filial := xFilial("SB9")
Local cAliTerc   := CriaTrab(Nil,.F.)
Local cIND_EST
Local lPropr
Local cKey
Local nSaldoFis
Local nSaldoVir

cQuery := QryTerc(cTipoTerc,dDataAte,cCodProdDe,cCodProdAte)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliTerc,.T.,.T.)
While !(cAliTerc)->(Eof())

	If !Empty((cAliTerc)->(B6_CLIFOR+B6_LOJA))
	 	// descontar do saldo proprio, o saldo DE Terceiro
		If cTipoTerc == "D"
			cIND_EST := "2"
		Else
			If cTipoTerc == "E"
				cIND_EST := "1"
			EndIf
		EndIf

		If (cAliSumTer)->(MsSeek(cSB9Filial+DTOS(dDataAte)+(cAliTerc)->(B6_PRODUTO)))

			nSaldoFis := 0
			nSaldoVir := 0
			If ((cAliSumTer)->QTDFIS + (cAliTerc)->SALDOFIS) <> 0
				nSaldoFis := Iif((cAliTerc)->SALDOFIS > 0, (cAliTerc)->SALDOFIS, 0)
				nSaldoFis += Iif((cAliSumTer)->QTDFIS > 0, (cAliSumTer)->QTDFIS, 0)
			EndIf

			nSaldoVir := (cAliSumTer)->QTDVIR + (cAliTerc)->SALDOVIR

			Reclock(cAliSumTer,.F.)
			(cAliSumTer)->QTDFIS := nSaldoFis
			(cAliSumTer)->QTDVIR := nSaldoVir
			(cAliSumTer)->(MsUnLock())
		Else
			Reclock(cAliSumTer,.T.)
			(cAliSumTer)->FILIAL   := cSB9Filial
			(cAliSumTer)->DT_EST   := dDataAte
			(cAliSumTer)->COD_ITEM := (cAliTerc)->B6_PRODUTO
			(cAliSumTer)->QTDFIS   := (cAliTerc)->SALDOFIS
			(cAliSumTer)->QTDVIR   := (cAliTerc)->SALDOVIR
			(cAliSumTer)->(MsUnLock())
		EndIf

		lPropr := (cAliTerc)->(columnpos('B6_CLIPROP')) > 0 .and. !Empty((cAliTerc)->B6_CLIPROP) .and.;
				  (cAliTerc)->(Columnpos('B6_LJCLIPR')) > 0 .and. !Empty((cAliTerc)->B6_LJCLIPR)
		If lPropr
			cKey := 'SA1'+(cAliTerc)->(B6_CLIPROP+B6_LJCLIPR)
		else
			cKey := (cAliTerc)->(LEFT(PESSOA,3)+B6_CLIFOR+B6_LOJA)
		Endif
		If (cAliK200)->(MsSeek(cSB9Filial+DTOS(dDataAte)+(cAliTerc)->(B6_PRODUTO+cIND_EST)+cKey))
			If ((cAliK200)->QTD + (cAliTerc)->SALDO) <= 0
				Reclock(cAliK200,.F.)
				DbDelete()
				(cAliK200)->(MsUnLock())
			Else
				Reclock(cAliK200,.F.)
				(cAliK200)->QTD	+= (cAliTerc)->SALDO
				(cAliK200)->(MsUnLock())
			EndIf
		Else
			if (cAliTerc)->SALDO>0
				Reclock(cAliK200,.T.)
				(cAliK200)->FILIAL		:= cSB9Filial
				(cAliK200)->REG			:= "K200"
				(cAliK200)->DT_EST		:= dDataAte
				(cAliK200)->COD_ITEM	:= (cAliTerc)->B6_PRODUTO
				(cAliK200)->QTD			:= (cAliTerc)->SALDO
				(cAliK200)->IND_EST		:= cIND_EST
				(cAliK200)->COD_PART	:= cKey
				(cAliK200)->(MsUnLock())
			EndIf
		EndIf
	EndIf
	(cAliTerc)->(dbSkip())
EndDo

(cAliTerc)->(dbCloseArea())
Return

/*/{Protheus.doc} QryTerc
Montagem de query para selecionar os produtos que tem saldo em terceiro ou de terceiro
@author reynaldo
@since 04/10/2018
@version 1.0
@return ${return}, ${return_description}
@param cTipoTerc, characters, descricao
@param dDataAte, date, descricao
@param nSldTesN3, numeric, descricao
@param cCodProdDe, characters, descricao
@param cCodProdAte, characters, descricao
@type function
/*/
Static Function QryTerc(cTipoTerc,dDataAte,cCodProdDe,cCodProdAte)
Local cQuery    := ""
Local lAliasD3E := AliasInDic("D3E")
Local lAliasD3K := AliasInDic("D3K")
Local lAlmTerc  := !Empty(cAlmTerc)
Local nTamDhCli := TamSX3("DH_CLIENTE")[1]
Local nTamDhLoj := TamSX3("DH_LOJACLI")[1]
Local lCliProp  := .F.

dbselectArea('SB6')
lCliProp:= SB6->(ColumnPos("B6_CLIPROP")) > 0 .and. SB6->(ColumnPos("B6_LJCLIPR")) > 0

cQuery := ""
cQuery += "SELECT B6_PRODUTO "
cQuery += "	,PESSOA "
cQuery += "	,B6_CLIFOR "
cQuery += "	,B6_LOJA "
If lCliProp
	cQuery += ",B6_CLIPROP, B6_LJCLIPR"
EndIf
cQuery += "	,CASE "
cQuery += 	" WHEN SUM(REQUISICAO)<=0 "
cQuery += 		"AND SUM(RETORNO)*-1>(SUM(REQUISICAO)*-1) THEN SUM(REMESSA)+ SUM(RETORNO) "
cQuery += 		"ELSE SUM(REMESSA)+ SUM(REQUISICAO) "
cQuery += 		"END SALDO "
cQuery += " ,SUM(SALDOFIS) SALDOFIS "
cQuery += " ,SUM(SALDOVIR) SALDOVIR "
cQuery += "FROM ( "
// Seleciona os registros da SB6 que s�o remessa DE e EM terceiros
cQuery += "SELECT "
cQuery += "	'A' QRY "
cQuery += "	,'" +cTipoTerc+ "' TERC "
cQuery += "	,B6_PRODUTO "
cQuery += "	,( "
cQuery += "		CASE "
cQuery += "			WHEN B6_TPCF = 'C' "
cQuery += "				THEN 'SA1' "
cQuery += "			WHEN B6_TPCF = 'F' "
cQuery += "				THEN 'SA2' "
cQuery += "			END "
cQuery += "		) PESSOA "
cQuery += ",B6_CLIFOR "
cQuery += ",B6_LOJA "
If lCliProp
	cQuery += ",B6_CLIPROP, B6_LJCLIPR"
EndIf
cQuery += ",F4_ESTOQUE "
cQuery += ",B6_QUANT REMESSA "
cQuery += ",0 RETORNO "
cQuery += ",0 REQUISICAO "

cQuery += ",(CASE "
cQuery += "  WHEN SF4.F4_CODIGO <'501' AND SF4.F4_ESTOQUE ='S' THEN SB6.B6_QUANT "
cQuery += "  WHEN SF4.F4_CODIGO >'500' AND SF4.F4_ESTOQUE ='S' THEN SB6.B6_QUANT *-1 "
cQuery += "  ELSE 0 "
cQuery += "  END "
cQuery += "	 ) SALDOFIS " // Se movimentou estoque, deve considerar para abater no saldo proprio. se n?o movimentou deve considerar somente a quantidade de saiu.

cQuery += ",(CASE "
cQuery += "	 WHEN SF4.F4_CODIGO <'501' AND SF4.F4_ESTOQUE ='N' THEN SB6.B6_QUANT "
cQuery += "	 WHEN SF4.F4_CODIGO >'500' AND SF4.F4_ESTOQUE ='N' THEN SB6.B6_QUANT *-1"
cQuery += "  ELSE 0 "
cQuery += "  END "
cQuery += "	 ) SALDOVIR " // Se movimentou estoque, deve considerar para abater no saldo proprio. se n?o movimentou deve considerar somente a quantidade de saiu.

cQuery += "FROM "+RetSqlName("SB6")+" SB6 "
cQuery += "INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery += "AND SB1.B1_COD = SB6.B6_PRODUTO "
cQuery += "AND SB1.B1_COD NOT LIKE 'MOD%' "
cQuery += "AND SB1.B1_CCCUSTO = ' ' "
cQuery += "AND SB1.D_E_L_E_T_ = ' ' "
If lCpoBZTP
	cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
cQuery += "INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '"+xFilial("SF4")+"' "
cQuery += "	AND SF4.F4_CODIGO = SB6.B6_TES "
cQuery += "	AND SF4.F4_PODER3 = 'R' "
If lAlmTerc
	cQuery += " AND (( SF4.F4_ESTOQUE = 'S') OR  (SF4.F4_ESTOQUE = 'N' AND SF4.F4_CONTERC <> '2')) "
EndIf
cQuery += "	AND SF4.D_E_L_E_T_ = ' ' "
cQuery += "WHERE SB6.B6_FILIAL = '"+xFilial("SB6")+"' "
cQuery += "	AND SB6.B6_PRODUTO BETWEEN '"+cCodProdDe+"' AND '"+cCodProdAte+"' "
cQuery += "	AND SB6.B6_TIPO = '"+cTipoTerc+"' "
cQuery += "	AND SB6.B6_DTDIGIT <= '"+dtos(dDataAte)+"' "
cQuery += "	AND SB6.D_E_L_E_T_ = ' ' AND "
If lCpoBZTP
	cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
Else
	cQuery += "SB1.B1_TIPO "
EndIF
cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
If lAliasD3E
	cQuery += "AND NOT EXISTS( "
	cQuery += "SELECT 1 FROM "+ RetSqlName("D3E") +" D3E "
	cQuery += "JOIN "+ RetSqlName("SA1") +" SA1 "
	cQuery += "ON SA1.A1_FILIAL = '"+ xFilial("SA1") +"' AND SA1.A1_COD = D3E.D3E_CLIENT AND SA1.A1_LOJA = D3E.D3E_LOJA AND SA1.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE D3E.D3E_FILIAL = '"+ xFilial("D3E") +"' AND D3E.D3E_COD = SB6.B6_PRODUTO AND D3E.D_E_L_E_T_ = ' ' "
	cQuery += ") "
EndIf

cQuery += "AND NOT EXISTS( "
cQuery += "SELECT 1 FROM "+ RetSqlName("SDH") +" SDH "
cQuery += "JOIN "+ RetSqlName("SD1") +" SD1 "
cQuery += "ON SD1.D1_FILIAL = '"+ xFilial("SD1") +"' AND SDH.DH_IDENTNF = SD1.D1_IDENTB6 AND SD1.D_E_L_E_T_ = ' ' "
cQuery += "WHERE SDH.DH_FILIAL = '"+ xFilial("SDH") +"' AND SB6.B6_DOC = SD1.D1_DOC AND SB6.B6_SERIE = SD1.D1_SERIE AND SD1.D1_FORNECE = SB6.B6_CLIFOR AND SD1.D1_LOJA = SB6.B6_LOJA AND SD1.D1_COD = SB6.B6_PRODUTO AND SD1.D1_QUANT = SB6.B6_QUANT AND SDH.D_E_L_E_T_ = ' ' "
cQuery += ") "

cQuery += "AND NOT EXISTS( "
cQuery += "SELECT 1 FROM "+ RetSqlName("SDH") +" SDH "
cQuery += "JOIN "+ RetSqlName("SD2") +" SD2 "
cQuery += "ON SD2.D2_FILIAL = '"+ xFilial("SD2") +"' AND SDH.DH_IDENTNF = SD2.D2_IDENTB6 AND SD2.D_E_L_E_T_ = ' ' "
cQuery += "WHERE SDH.DH_FILIAL = '"+ xFilial("SDH") +"' AND SD2.D2_COD = SB6.B6_PRODUTO AND SB6.B6_DOC = SD2.D2_DOC AND SB6.B6_SERIE = SD2.D2_SERIE AND SD2.D2_CLIENTE = SB6.B6_CLIFOR AND SD2.D2_LOJA = SB6.B6_LOJA AND SD2.D2_QUANT = SB6.B6_QUANT AND SDH.D_E_L_E_T_ = ' ' "
cQuery += ") "


cQuery += "UNION ALL "
// Seleciona os registros da SB6 que s�o retorno de remessa(devolucao) DE e EM terceiros, desde que encontre a remessa de terceiro respectivo
cQuery += "SELECT "
cQuery += "	'B' QRY "
cQuery += "	,'" +cTipoTerc+ "' TERC "
cQuery += "	,SB6.B6_PRODUTO "
cQuery += "	,( CASE "
cQuery += "			WHEN SB6REM.B6_TPCF = 'C' "
cQuery += "				THEN 'SA1' "
cQuery += "			WHEN SB6REM.B6_TPCF = 'F' "
cQuery += "				THEN 'SA2' "
cQuery += "			END "
cQuery += "		) PESSOA "
cQuery += "	,SB6REM.B6_CLIFOR "
cQuery += "	,SB6REM.B6_LOJA "
If lCliProp
	cQuery += ",SB6REM.B6_CLIPROP, SB6REM.B6_LJCLIPR"
EndIf
cQuery += "	,SF4.F4_ESTOQUE "
cQuery += "	,0 "
cQuery += "	,SB6.B6_QUANT * - 1 B6_QUANT "
cQuery += "	,0 "

cQuery += ",(CASE "
cQuery += "  WHEN SF4.F4_CODIGO <'501' AND SF4.F4_ESTOQUE ='S' THEN SB6.B6_QUANT "
cQuery += "  WHEN SF4.F4_CODIGO >'500' AND SF4.F4_ESTOQUE ='S' THEN SB6.B6_QUANT *-1 "
cQuery += "  ELSE 0 "
cQuery += "  END "
cQuery += "	 ) SALDOFIS " // Se movimentou estoque, deve considerar para abater no saldo proprio. se n?o movimentou deve considerar somente a quantidade de saiu.

cQuery += ",(CASE "
cQuery += "WHEN SF4.F4_CODIGO <'501' AND SF4.F4_ESTOQUE = 'N' THEN SB6.B6_QUANT "
cQuery += "WHEN SF4.F4_CODIGO >'500' AND SF4.F4_ESTOQUE = 'N' THEN SB6.B6_QUANT *-1 "
cQuery += "ELSE 0 "
cQuery += "END "
cQuery += "	 ) SALDOVIR " // Se movimentou estoque, deve considerar para abater no saldo proprio. se n?o movimentou deve considerar somente a quantidade de saiu.

cQuery += "FROM "+RetSqlName("SB6")+" SB6 "
cQuery += "INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery += "	AND SB1.B1_COD = SB6.B6_PRODUTO "
cQuery += "	AND SB1.B1_COD NOT LIKE 'MOD%' "
cQuery += "	AND SB1.B1_CCCUSTO = ' ' "
cQuery += "	AND SB1.D_E_L_E_T_ = ' ' "
If lCpoBZTP
	cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
cQuery += "LEFT JOIN "+RetSqlName("SB6")+" SB6REM ON SB6REM.B6_FILIAL = '"+xFilial("SB6")+"' "
cQuery += "	AND SB6REM.B6_IDENT = SB6.B6_IDENT "
cQuery += "	AND SB6REM.B6_TIPO = '"+cTipoTerc+"' "
cQuery += "	AND SB6REM.B6_PRODUTO = SB6.B6_PRODUTO "
cQuery += "	AND SB6REM.B6_DTDIGIT <= '"+dtos(dDataAte)+"' "
cQuery += "	AND SB6REM.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN "+RetSqlName("SF4")+" SF4REM ON SF4REM.F4_FILIAL = '"+xFilial("SF4")+"' "
cQuery += "	AND SF4REM.F4_CODIGO = SB6REM.B6_TES "
cQuery += "	AND SF4REM.F4_PODER3 = 'R' "
If lAlmTerc
	cQuery += " AND (( SF4REM.F4_ESTOQUE = 'S') OR  (SF4REM.F4_ESTOQUE = 'N' AND SF4REM.F4_CONTERC <> '2')) "
EndIf
cQuery += "	AND SF4REM.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '"+xFilial("SF4")+"' "
cQuery += "	AND SF4.F4_CODIGO = SB6.B6_TES "
cQuery += "	AND SF4.F4_PODER3 = 'D' "
If lAlmTerc
	cQuery += " AND (( SF4.F4_ESTOQUE = 'S') OR  (SF4.F4_ESTOQUE = 'N' AND SF4.F4_CONTERC <> '2')) "
EndIf
cQuery += "	AND SF4.D_E_L_E_T_ = ' ' "
cQuery += "WHERE SB6.B6_FILIAL = '"+xFilial("SB6")+"' "
cQuery += "	AND SB6.B6_PRODUTO BETWEEN '"+cCodProdDe+"' AND '"+cCodProdAte+"' "
cQuery += "	AND SB6.B6_TIPO = '"+cTipoTerc+"' "
cQuery += "	AND SB6.B6_DTDIGIT <= '"+dtos(dDataAte)+"' "
cQuery += "	AND SB6.D_E_L_E_T_ = ' ' AND "
If lCpoBZTP
	cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
Else
	cQuery += "SB1.B1_TIPO "
EndIF
cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
If lAliasD3E
	cQuery += "AND NOT EXISTS( "
	cQuery += "SELECT 1 FROM "+ RetSqlName("D3E") +" D3E "
	cQuery += "JOIN "+ RetSqlName("SA1") +" SA1 "
	cQuery += "ON SA1.A1_FILIAL = '"+ xFilial("SA1") +"' AND SA1.A1_COD = D3E.D3E_CLIENT AND SA1.A1_LOJA = D3E.D3E_LOJA AND SA1.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE D3E.D3E_FILIAL = '"+ xFilial("D3E") +"' AND D3E.D3E_COD = SB6.B6_PRODUTO AND D3E.D_E_L_E_T_ = ' ' "
	cQuery += ") "
EndIf

cQuery += "AND NOT EXISTS( "
cQuery += "SELECT 1 FROM "+ RetSqlName("SDH") +" SDH "
cQuery += "JOIN "+ RetSqlName("SD1") +" SD1 "
cQuery += "ON SD1.D1_FILIAL = '"+ xFilial("SD1") +"' AND SDH.DH_IDENTNF = SD1.D1_IDENTB6 AND SD1.D_E_L_E_T_ = ' ' "
cQuery += "WHERE SDH.DH_FILIAL = '"+ xFilial("SDH") +"' AND SB6.B6_DOC = SD1.D1_DOC AND SB6.B6_SERIE = SD1.D1_SERIE AND SD1.D1_FORNECE = SB6.B6_CLIFOR AND SD1.D1_LOJA = SB6.B6_LOJA AND SD1.D1_COD = SB6.B6_PRODUTO AND SD1.D1_QUANT = SB6.B6_QUANT AND SDH.D_E_L_E_T_ = ' ' "
cQuery += ") "

cQuery += "AND NOT EXISTS( "
cQuery += "SELECT 1 FROM "+ RetSqlName("SDH") +" SDH "
cQuery += "JOIN "+ RetSqlName("SD2") +" SD2 "
cQuery += "ON SD2.D2_FILIAL = '"+ xFilial("SD2") +"' AND SDH.DH_IDENTNF = SD2.D2_IDENTB6 AND SD2.D_E_L_E_T_ = ' ' "
cQuery += "WHERE SDH.DH_FILIAL = '"+ xFilial("SDH") +"' AND SB6.B6_DOC = SD2.D2_DOC AND SB6.B6_SERIE = SD2.D2_SERIE AND SD2.D2_CLIENTE = SB6.B6_CLIFOR AND SD2.D2_LOJA = SB6.B6_LOJA AND SD2.D2_COD = SB6.B6_PRODUTO AND SD2.D2_QUANT = SB6.B6_QUANT AND SDH.D_E_L_E_T_ = ' ' "
cQuery += ") "

If cTipoTerc == "D"

	cQuery += "UNION ALL "
	// Seleciona os registros da SB6 que s�o requisicao de insumos DE terceiros, quando apontado na rotina apontamento de terceiros
	cQuery += "SELECT "
	cQuery += "	'C' QRY "
	cQuery += ",'" +cTipoTerc+ "' TERC "
	cQuery += ",SD3.D3_COD ,'SA1' "
	If lAliasD3K
		cQuery += ",D3K.D3K_CLIENT ,D3K.D3K_LOJA"
		If lCliProp
			cQuery += ",' ',' '"
		EndIf
		cQuery += ",'S' "
		cQuery += ",0 "                 // remessa
		cQuery += ",0 "                 // retorno
		cQuery += ",(D3K.D3K_QTDE*-1) " // requisicao
		cQuery += ",(D3K.D3K_QTDE*-1) " // saldofis
		cQuery += ",0 "                 // saldovir
	Else
		cQuery += ",' ' D3K_CLIENT ,' ' D3K_LOJA"
		If lCliProp
			cQuery += ",' ',' '"
		EndIf
		cQuery += ",'S' "
		cQuery += ",0 "            // remessa
		cQuery += ",0 "            // retorno
		cQuery += ",0 "            // requisicao
		cQuery += ",0 "            // saldofis
		cQuery += ",0 "            // saldovir
	EndIf
	cQuery += "FROM "+RetSqlName("SD3")+" SD3 "
	If lAliasD3K
		cQuery += "JOIN "+RetSqlName("D3K")+" D3K ON D3K.D3K_FILIAL = '"+xFilial("D3K")+"' "
		cQuery += 	"AND D3K.D3K_NUMSEQ = SD3.D3_NUMSEQ "
		cQuery += 	"AND D3K.D3K_COD = SD3.D3_COD "
		cQuery += 	"AND D3K.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += "INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
	cQuery += "	AND SB1.B1_COD = SD3.D3_COD "
	cQuery += "	AND SB1.B1_COD NOT LIKE 'MOD%' "
	cQuery += "	AND SB1.B1_CCCUSTO = ' ' "
	cQuery += "	AND SB1.D_E_L_E_T_ = ' ' "
	If lCpoBZTP
		cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += "WHERE "
	cQuery += "SD3.D3_FILIAL = '"+xFilial("SD3")+"' "
	cQuery += "AND SD3.D3_EMISSAO <= '"+dtos(dDataAte)+"' "
	cQuery += "AND SD3.D3_CF LIKE 'RE%' "
	cQuery += "AND SD3.D3_COD BETWEEN '"+cCodProdDe+"' AND '"+cCodProdAte+"' "
	cQuery += "AND SD3.D3_OP <> '  ' "
	cQuery += "AND SD3.D_E_L_E_T_ = ' ' AND "
	If lCpoBZTP
		cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
	Else
		cQuery += "SB1.B1_TIPO "
	EndIF
	cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	If lAliasD3E
		cQuery += "AND NOT EXISTS( "
		cQuery += "SELECT 1 FROM "+ RetSqlName("D3E") +" D3E "
		cQuery += "JOIN "+ RetSqlName("SA1") +" SA1 "
		cQuery += "ON SA1.A1_FILIAL = '"+ xFilial("SA1") +"' AND SA1.A1_COD = D3E.D3E_CLIENT AND SA1.A1_LOJA = D3E.D3E_LOJA AND SA1.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE D3E.D3E_FILIAL = '"+ xFilial("D3E") +"' AND D3E.D3E_COD = SD3.D3_COD AND D3E.D_E_L_E_T_ = ' ' "
		cQuery += ") "
	EndIf

	cQuery += "UNION ALL "
	// Seleciona os registros da SD3 que s�o producao de produtos DE terceiros, quando apontado na rotina apontamento de terceiros
	cQuery += "SELECT "
	cQuery += "	'D' QRY "
	cQuery += "	,'" +cTipoTerc+ "' TERC "
	cQuery += " ,SD3.D3_COD ,'SA1' "
	If lAliasD3K
		cQuery += ",D3K.D3K_CLIENT ,D3K.D3K_LOJA"
		If lCliProp
			cQuery += ",' ',' '"
		EndIf
		cQuery += ",'S' "
		cQuery += ",0 "            // remessa
		cQuery += ",0 "            // retorno
		cQuery += ",D3K.D3K_QTDE " // requisicao
		cQuery += ",D3K.D3K_QTDE " // saldofis
		cQuery += ",0 "            // saldovir
	Else
		cQuery += ",' ' D3K_CLIENT ,' ' D3K_LOJA"
		If lCliProp
			cQuery += ",' ',' '"
		EndIf
		cQuery += ",'S' "
		cQuery += ",0 "            // remessa
		cQuery += ",0 "            // retorno
		cQuery += ",0 "            // requisicao
		cQuery += ",0 "            // saldofis
		cQuery += ",0 "            // saldovir
	EndIf
	cQuery += "FROM "+RetSqlName("SD3")+" SD3 "
	cQuery += "INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
	cQuery += "	AND SB1.B1_COD = SD3.D3_COD "
	cQuery += "	AND SB1.B1_COD NOT LIKE 'MOD%' "
	cQuery += "	AND SB1.B1_CCCUSTO = ' ' "
	cQuery += "	AND SB1.D_E_L_E_T_ = ' ' "
	If lCpoBZTP
		cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
	EndIf
	If lAliasD3K
		cQuery += "JOIN "+RetSqlName("D3K")+" D3K ON D3K.D3K_FILIAL = '"+xFilial("D3K")+"' "
		cQuery += 	"AND D3K.D3K_NUMSEQ = SD3.D3_NUMSEQ "
		cQuery += 	"AND D3K.D3K_COD = SD3.D3_COD "
		cQuery += 	"AND D3K.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += "WHERE "
	cQuery += "SD3.D3_FILIAL = '"+xFilial("SD3")+"' "
	cQuery += "AND SD3.D3_EMISSAO <= '"+dtos(dDataAte)+"' "
	cQuery += "AND (SD3.D3_CF LIKE 'PR%' OR SD3.D3_CF LIKE 'DE%' ) "
	cQuery += "AND SD3.D3_COD BETWEEN '"+cCodProdDe+"' AND '"+cCodProdAte+"' "
	cQuery += "AND SD3.D3_OP <> '  ' "
	cQuery += "AND SD3.D_E_L_E_T_ = ' ' AND "
	If lCpoBZTP
		cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
	Else
		cQuery += "SB1.B1_TIPO "
	EndIf
	cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	If lAliasD3E
		cQuery += "AND NOT EXISTS( "
		cQuery += "SELECT 1 FROM "+ RetSqlName("D3E") +" D3E "
		cQuery += "JOIN "+ RetSqlName("SA1") +" SA1 "
		cQuery += "ON SA1.A1_FILIAL = '"+ xFilial("SA1") +"' AND SA1.A1_COD = D3E.D3E_CLIENT AND SA1.A1_LOJA = D3E.D3E_LOJA AND SA1.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE D3E.D3E_FILIAL = '"+ xFilial("D3E") +"' AND D3E.D3E_COD = SD3.D3_COD AND D3E.D_E_L_E_T_ = ' ' "
		cQuery += ") "
	EndIf

	cQuery += "UNION ALL "
	// Seleciona os registros da SD2 que s�o produtos produzidos com insumos DE terceiros, quando apontado na rotina apontamento de terceiros
	cQuery += " SELECT "
	cQuery += "	'E' QRY "
	cQuery += "	,'" +cTipoTerc+ "' TERC "
	cQuery += "	,SD2.D2_COD ,'SA1' ,SD2.D2_CLIENTE ,SD2.D2_LOJA"
	If lCliProp
		cQuery += ",' ',' '"
	EndIf
	cQuery += ",'S' "
	cQuery += ",0 "                 // remessa
	cQuery += ",0 "                 // retorno
	cQuery += ",(SD2.D2_QUANT*-1) " // requisicao
	cQuery += ",(SD2.D2_QUANT*-1) " // saldofis
	cQuery += ",0 "                 // saldovir

	cQuery += " FROM " + RetSqlName("SD2") + " SD2 "
	cQuery += "		INNER JOIN " + RetSqlName("SB1") + " SB1 ON "
	cQuery += "			SB1.B1_FILIAL = '" + xFilial("SB1") +"' "
	cQuery += "			AND SB1.B1_COD = SD2.D2_COD "
	cQuery += "			AND SB1.B1_COD NOT LIKE 'MOD%' "
	cQuery += "			AND SB1.B1_CCCUSTO = ' ' "
	cQuery += "			AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "		LEFT JOIN " + RetSqlName("SBZ") + " SBZ ON "
	cQuery += "			SBZ.BZ_FILIAL = '" + xFilial("SBZ") +"' "
	cQuery += "			AND SBZ.BZ_COD = SB1.B1_COD "
	cQuery += "			AND SBZ.D_E_L_E_T_ = ' ' "
	cQuery += "	WHERE "
	cQuery += "		SD2.D2_FILIAL = '" + xFilial("SD2") +"' "
	cQuery += " 	AND SD2.D2_EMISSAO <= '" + DTOS(dDataAte) + "' "
	cQuery += "		AND SD2.D2_EMISSAO >= (  "
	cQuery += "			SELECT "
	cQuery += "				MIN( SD3.D3_EMISSAO ) "
	cQuery += "			FROM " + RetSqlName("SD3") + " SD3 "
	If lAliasD3K
		cQuery += "				JOIN " + RetSqlName("D3K") + " D3K ON "
		cQuery += "					D3K.D3K_FILIAL = '" + xFilial("D3K") +"' "
		cQuery += "					AND D3K.D3K_NUMSEQ = SD3.D3_NUMSEQ "
		cQuery += "					AND D3K.D3K_COD = SD3.D3_COD "
		cQuery += "					AND D3K.D_E_L_E_T_ = ' ' "
	Endif
	cQuery += "			WHERE "
	cQuery += "				SD3.D3_FILIAL = '" + xFilial("SD3") +"' "
	If lAliasD3K
		cQuery += "			AND D3K.D3K_CLIENT = SD2.D2_CLIENTE "
		cQuery += "			AND D3K.D3K_LOJA = SD2.D2_LOJA "
	Endif
	cQuery += "				AND SD3.D3_COD = SD2.D2_COD "
	cQuery += "				AND SD3.D3_CF LIKE 'PR%' "
	cQuery += "				AND SD3.D3_COD BETWEEN '"+cCodProdDe+"' AND '"+cCodProdAte+"' "
	cQuery += "				AND SD3.D_E_L_E_T_ = ' ' ) AND "

	If lCpoBZTP
		cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
	Else
		cQuery += "SB1.B1_TIPO "
	EndIf
	cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	If lAliasD3E
		cQuery += "AND NOT EXISTS( "
		cQuery += "SELECT 1 FROM "+ RetSqlName("D3E") +" D3E "
		cQuery += "JOIN "+ RetSqlName("SA1") +" SA1 "
		cQuery += "ON SA1.A1_FILIAL = '"+ xFilial("SA1") +"' AND SA1.A1_COD = D3E.D3E_CLIENT AND SA1.A1_LOJA = D3E.D3E_LOJA AND SA1.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE D3E.D3E_FILIAL = '"+ xFilial("D3E") +"' AND D3E.D3E_COD = SD2.D2_COD AND D3E.D_E_L_E_T_ = ' ' "
		cQuery += ") "
	EndIf

EndIf

	//-- Opera��o triangular (Recebimento)
	cQuery += "UNION ALL "
	cQuery += " SELECT "
	cQuery += "	'F' QRY "
	cQuery += "	,'" +cTipoTerc+ "' TERC "
	cQuery += "		,SD1.D1_COD B6_PRODUTO, "
	cQuery += "    (CASE "
	cQuery += "			WHEN SDH.DH_CLIENTE = '" + Space(nTamDhCli) + "' AND SDH.DH_LOJACLI = '" + Space(nTamDhLoj) + "' THEN 'SA2' "
	cQuery += "			ELSE 'SA1' "
  	cQuery += "		END) PESSOA, "
	cQuery += "     (CASE "
	cQuery += "      	WHEN SDH.DH_CLIENTE = '" + Space(nTamDhCli) + "' THEN SDH.DH_FORNECE "
	cQuery += "         ELSE SDH.DH_CLIENTE "
	cQuery += "      END) B6_CLIFOR, "
	cQuery += "     (CASE "
	cQuery += "      	WHEN SDH.DH_LOJACLI = '" + Space(nTamDhLoj) + "' THEN SDH.DH_LOJAFOR "
	cQuery += "         ELSE SDH.DH_LOJACLI"
	cQuery += "      END) B6_LOJA "
	If lCliProp
		cQuery += ",' ',' '"
	EndIf
	cQuery += "     ,F4_ESTOQUE "

	If cTipoTerc == "D"
		cQuery += " 	,SD1.D1_QUANT REMESSA "
		cQuery += " 	,0 RETORNO "
		cQuery += " 	,0 REQUISICAO "
	Else
		cQuery += " 	,0 REMESSA "
		cQuery += " 	,(SD1.D1_QUANT * -1) RETORNO "
		cQuery += " 	,0 REQUISICAO "
	EndIf

	cQuery += ",(CASE "
	cQuery += "  WHEN SF4.F4_CODIGO <'501' AND SF4.F4_ESTOQUE ='S' THEN SD1.D1_QUANT "
	cQuery += "  WHEN SF4.F4_CODIGO >'500' AND SF4.F4_ESTOQUE ='S' THEN SD1.D1_QUANT *-1 "
	cQuery += "  ELSE 0 "
	cQuery += "  END "
	cQuery += "	 ) SALDOFIS " // Se movimentou estoque, deve considerar para abater no saldo proprio. se n?o movimentou deve considerar somente a quantidade de saiu.

	cQuery += ",(CASE "
	cQuery += "	 WHEN SF4.F4_CODIGO <'501' AND SF4.F4_ESTOQUE ='N' THEN SD1.D1_QUANT *-1 "
	cQuery += "	 WHEN SF4.F4_CODIGO >'500' AND SF4.F4_ESTOQUE ='N' THEN SD1.D1_QUANT "
	cQuery += "  ELSE 0 "
	cQuery += "  END "
	cQuery += "	 ) SALDOVIR " // Se movimentou estoque, deve considerar para abater no saldo proprio. se n?o movimentou deve considerar somente a quantidade de saiu.

	cQuery += " FROM " + RetSqlName("SD1") + " SD1 "
	cQuery += "		INNER JOIN " + RetSqlName("SB1") + " SB1 ON "
	cQuery += "			SB1.B1_FILIAL = '" + xFilial("SB1") +"' "
	cQuery += "			AND SB1.B1_COD = SD1.D1_COD "
	cQuery += "			AND SB1.B1_COD NOT LIKE 'MOD%' "
	cQuery += "			AND SB1.B1_CCCUSTO = ' ' "
	cQuery += "			AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "		LEFT JOIN " + RetSqlName("SBZ") + " SBZ ON "
	cQuery += "			SBZ.BZ_FILIAL = '" + xFilial("SBZ") +"' "
	cQuery += "			AND SBZ.BZ_COD = SB1.B1_COD "
	cQuery += "			AND SBZ.D_E_L_E_T_ = ' ' "
	cQuery += "		INNER JOIN " + RetSqlName("SDH") + " SDH ON "
	cQuery += "			SDH.DH_FILIAL = '" + xFilial("SDH") +"' "
	cQuery += "			AND SDH.DH_IDENTNF = SD1.D1_IDENTB6 "
	cQuery += "			AND SDH.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '"+xFilial("SF4")+"' "
	cQuery += "	AND SF4.F4_CODIGO = SD1.D1_TES "
	If cTipoTerc == "D"
		cQuery += "	AND SF4.F4_PODER3 = 'R' "
	Else
		cQuery += "	AND SF4.F4_PODER3 = 'D' "
	EndIf
	cQuery += "		AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += "	WHERE "
	cQuery += "		SD1.D1_DTDIGIT <= '"+dtos(dDataAte)+"' "
	cQuery += "		AND SD1.D1_COD BETWEEN '"+cCodProdDe+"' AND '"+cCodProdAte+"' "
	cQuery += "		AND SD1.D_E_L_E_T_ = ' ' AND "

	If lCpoBZTP
		cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
	Else
		cQuery += "SB1.B1_TIPO "
	EndIF
	cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	If lAliasD3E
		cQuery += "AND NOT EXISTS( "
		cQuery += "SELECT 1 FROM "+ RetSqlName("D3E") +" D3E "
		cQuery += "JOIN "+ RetSqlName("SA1") +" SA1 "
		cQuery += "ON SA1.A1_FILIAL = '"+ xFilial("SA1") +"' AND SA1.A1_COD = D3E.D3E_CLIENT AND SA1.A1_LOJA = D3E.D3E_LOJA AND SA1.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE D3E.D3E_FILIAL = '"+ xFilial("D3E") +"' AND D3E.D3E_COD = SD1.D1_COD AND D3E.D_E_L_E_T_ = ' ' "
		cQuery += ") "
	EndIf

	//-- Opera��o triangular (Devolu��o)

	cQuery += "UNION ALL "
	cQuery += " SELECT "
	cQuery += "	'G' QRY "
	cQuery += "	,'" +cTipoTerc+ "' TERC "
	cQuery += "		,SD2.D2_COD B6_PRODUTO, "
	cQuery += "    (CASE "
	cQuery += "			WHEN SDH.DH_CLIENTE = '" + Space(nTamDhCli) + "' AND SDH.DH_LOJACLI = '" + Space(nTamDhLoj) + "' THEN 'SA2' "
	cQuery += "			ELSE 'SA1' "
	cQuery += "		END) PESSOA, "
	cQuery += "     (CASE "
	cQuery += "      	WHEN SDH.DH_CLIENTE = '" + Space(nTamDhCli) + "' THEN SDH.DH_FORNECE "
	cQuery += "         ELSE SDH.DH_CLIENTE "
	cQuery += "      END) B6_CLIFOR, "
	cQuery += "     (CASE "
	cQuery += "      	WHEN SDH.DH_LOJACLI = '" + Space(nTamDhLoj) + "' THEN SDH.DH_LOJAFOR "
	cQuery += "         ELSE SDH.DH_LOJACLI"
	cQuery += "      END) B6_LOJA "
	If lCliProp
		cQuery += ",' ',' '"
	EndIf
	cQuery += "     ,'S' F4_ESTOQUE,"

	If cTipoTerc == "D"
		cQuery += " 	0 REMESSA "
		cQuery += " 	,(SD2.D2_QUANT * -1) RETORNO "
		cQuery += " 	,0 REQUISICAO"
	Else
		cQuery += " 	SD2.D2_QUANT REMESSA "
		cQuery += " 	,0 RETORNO "
		cQuery += " 	,0 REQUISICAO"
	EndIf

	cQuery += ",(CASE "
	cQuery += "  WHEN SF4.F4_CODIGO <'501' AND SF4.F4_ESTOQUE ='S' THEN SD2.D2_QUANT "
	cQuery += "  WHEN SF4.F4_CODIGO >'500' AND SF4.F4_ESTOQUE ='S' THEN SD2.D2_QUANT *-1 "
	cQuery += "  ELSE 0 "
	cQuery += "  END "
	cQuery += "	 ) SALDOFIS " // Se movimentou estoque, deve considerar para abater no saldo proprio. se n?o movimentou deve considerar somente a quantidade de saiu.

	cQuery += ",(CASE "
	cQuery += "	 WHEN SF4.F4_CODIGO <'501' AND SF4.F4_ESTOQUE ='N' THEN 0 "
	cQuery += "	 WHEN SF4.F4_CODIGO >'500' AND SF4.F4_ESTOQUE ='N' THEN SD2.D2_QUANT "
	cQuery += "  ELSE 0 "
	cQuery += "  END "
	cQuery += "	 ) SALDOVIR " // Se movimentou estoque, deve considerar para abater no saldo proprio. se n?o movimentou deve considerar somente a quantidade de saiu.

	cQuery += " FROM " + RetSqlName("SD2") + " SD2 "
	cQuery += "		INNER JOIN " + RetSqlName("SB1") + " SB1 ON "
	cQuery += "			SB1.B1_FILIAL = '" + xFilial("SB1") +"' "
	cQuery += "			AND SB1.B1_COD = SD2.D2_COD "
	cQuery += "			AND SB1.B1_COD NOT LIKE 'MOD%' "
	cQuery += "			AND SB1.B1_CCCUSTO = ' ' "
	cQuery += "			AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "		LEFT JOIN " + RetSqlName("SBZ") + " SBZ ON "
	cQuery += "			SBZ.BZ_FILIAL = '" + xFilial("SBZ") +"' "
	cQuery += "			AND SBZ.BZ_COD = SB1.B1_COD "
	cQuery += "			AND SBZ.D_E_L_E_T_ = ' ' "
	cQuery += "		INNER JOIN " + RetSqlName("SDH") + " SDH ON "
	cQuery += "			SDH.DH_FILIAL = '" + xFilial("SDH") +"' "
	cQuery += "			AND SDH.DH_IDENTNF = SD2.D2_IDENTB6 "
	cQuery += "			AND SDH.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '"+xFilial("SF4")+"' "
	cQuery += "	AND SF4.F4_CODIGO = SD2.D2_TES "
	If cTipoTerc == "D"
		cQuery += "	AND SF4.F4_PODER3 = 'D' "
	Else
		cQuery += "	AND SF4.F4_PODER3 = 'R' "
	EndIf
	cQuery += "		AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += "	WHERE "
	cQuery += "		SD2.D2_EMISSAO <= '"+dtos(dDataAte)+"' "
	cQuery += "		AND SD2.D2_COD BETWEEN '"+cCodProdDe+"' AND '"+cCodProdAte+"' "
	cQuery += "		AND SD2.D_E_L_E_T_ = ' ' AND "

	If lCpoBZTP
		cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
	Else
		cQuery += "SB1.B1_TIPO "
	EndIF
	cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	If lAliasD3E
		cQuery += "AND NOT EXISTS( "
		cQuery += "SELECT 1 FROM "+ RetSqlName("D3E") +" D3E "
		cQuery += "JOIN "+ RetSqlName("SA1") +" SA1 "
		cQuery += "ON SA1.A1_FILIAL = '"+ xFilial("SA1") +"' AND SA1.A1_COD = D3E.D3E_CLIENT AND SA1.A1_LOJA = D3E.D3E_LOJA AND SA1.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE D3E.D3E_FILIAL = '"+ xFilial("D3E") +"' AND D3E.D3E_COD = SD2.D2_COD AND D3E.D_E_L_E_T_ = ' ' "
		cQuery += ") "
	EndIf

cQuery += ") SaldoTerceiro "
cQuery += " GROUP BY B6_PRODUTO, PESSOA ,B6_CLIFOR ,B6_LOJA "
If lCliProp
	cQuery += ",B6_CLIPROP,B6_LJCLIPR"
EndIf
cQuery += " ORDER BY 1 "

cQuery := ChangeQuery(cQuery)

Return cQuery

/*/{Protheus.doc} BlkPRO21x
Grava a data de apuracao do SPED FISCAL nos registros de movimentacoes internas
referente a desmontagem utilizados na geracao dos registros K210/K215
@Andr� Maximo
@since 08/10/2018
@version 1.0
@return ${return}, ${return_description}
@param dDataDe, date, descricao
@param dDataAte, date, descricao
@type function
/*/
Function BlkPRO21x(dDataDe,dDataAte)
Local cQuery		:= " "
Local cPeriodo		:= ""

cPeriodo := Left(dtos(dDataAte),6)

cQuery:= "UPDATE "+RetSQLName("SD3")+" "
cQuery+= " SET	D3_PERBLK = '"+cPeriodo+"'"
cQuery+= " WHERE R_E_C_N_O_ IN (SELECT SD3.R_E_C_N_O_ "
cQuery+= " FROM	"+RetSQLName("SD3")+" SD3"
cQuery+= 	" JOIN "+RetSQLName("SB1")+" SB1"
cQuery+= 	   " ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
cQuery+= 		" AND SB1.B1_COD = SD3.D3_COD"
cQuery+= 		" AND SB1.B1_COD NOT LIKE 'MOD%'"
cQuery+= 		" AND SB1.B1_CCCUSTO = ' '"
cQuery+= 		" AND SB1.D_E_L_E_T_ = ' '"
If lCpoBZTP
	cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ "
	cQuery += 	"ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' "
	cQuery += 	" AND SBZ.BZ_COD = SB1.B1_COD "
	cQuery += 	" AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
cQuery+= "WHERE  SD3.D3_FILIAL = '"+xFilial("SD3")+"'"
cQuery+= 		" AND SD3.D3_CF IN ( 'DE7', 'RE7' )"
cQuery+= 		" AND SD3.D3_EMISSAO BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"'"
cQuery+= 		" AND SD3.D_E_L_E_T_ = ' '"
If lCpoBZTP
	cQuery += " AND "+MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
Else
	cQuery += " AND SB1.B1_TIPO "
EndIf
cQuery += 	  " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+")"
cQuery += 	  " )"

MATExecQry(cQuery)
Return


/*/{Protheus.doc} BlkK220
Grava a data de apuracao do SPED FISCAL nos registros de movimentacoes internas
referente a transferencia de produtos utilizados na geracao dos registros K220
@Andr� Maximo
@since 08/10/2018
@version 1.0
@return ${return}, ${return_description}
@param dDataDe, date, descricao
@param dDataAte, date, descricao
@type function
/*/
Function BlkK220(dDataDe,dDataAte)
Local cQuery	:= " "
Local cPeriodo	:= ""

cPeriodo :=	Left(dtos(dDataAte),6)

cQuery := ""
cQuery += "UPDATE "+RetSQLName("SD3")+" "
cQuery += "SET D3_PERBLK = '"+cPeriodo+"' "
cQuery += "WHERE R_E_C_N_O_ IN(SELECT SD3ORI.R_E_C_N_O_ "
cQuery += "FROM "+RetSQLName("SD3")+" SD3ORI "
cQuery += "JOIN "+RetSqlName("SD3")+" SD3DES "
cQuery += "ON SD3DES.D3_FILIAL = SD3ORI.D3_FILIAL "
cQuery += 	"AND SD3DES.D3_NUMSEQ = SD3ORI.D3_NUMSEQ "
cQuery += 	"AND SD3DES.D_E_L_E_T_ = ' ' "
cQuery += 	"AND EXISTS( "
cQuery +=  		"SELECT 1 FROM "+RetSqlName("SB1")+" SB1DES "
If lCpoBZTP
	cQuery +=  "LEFT JOIN "+RetSqlName("SBZ")+" SBZDES ON SBZDES.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZDES.BZ_COD = SB1DES.B1_COD AND SBZDES.D_E_L_E_T_ = ' ' "
EndIf
cQuery +=  		"WHERE SB1DES.B1_FILIAL = '"+xFilial('SB1')+"' "
cQuery +=  			"AND SB1DES.B1_COD = SD3DES.D3_COD "
cQuery +=  			"AND SB1DES.B1_COD NOT LIKE 'MOD%' "
cQuery +=  			"AND SB1DES.B1_CCCUSTO = ' ' "
cQuery +=  			"AND SB1DES.D_E_L_E_T_ = ' ' "
cQuery +=  			"AND "
If lCpoBZTP
	cQuery +=  MatIsNull()+"(SBZDES.BZ_TIPO,SB1DES.B1_TIPO) "
Else
	cQuery +=  "SB1DES.B1_TIPO "
EndIf
cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+")"
cQuery += ") "
cQuery += "WHERE SD3ORI.D3_FILIAL = '"+xFilial('SD3')+"' "
cQuery += 	"AND SD3ORI.D3_COD <> SD3DES.D3_COD "
cQuery += 	"AND ( ( SD3ORI.D3_CF = 'RE4' "
cQuery += 		"AND SD3DES.D3_CF = 'DE4' ) "
cQuery += 		"OR ( SD3ORI.D3_CF = 'DE4' "
cQuery += 		"AND SD3DES.D3_CF = 'RE4' ) ) "
cQuery += 	"AND SD3ORI.D3_EMISSAO BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"' "
cQuery += 	"AND SD3ORI.D_E_L_E_T_ = ' ' "
cQuery += 	"AND EXISTS( "
cQuery +=  			"SELECT 1 FROM "+RetSqlName("SB1")+" SB1ORI "
If lCpoBZTP
	cQuery +=  "LEFT JOIN "+RetSqlName("SBZ")+" SBZORI ON SBZORI.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZORI.BZ_COD = SB1ORI.B1_COD AND SBZORI.D_E_L_E_T_ = ' ' "
EndIf
cQuery +=  			"WHERE SB1ORI.B1_FILIAL = '"+xFilial('SB1')+"' "
cQuery +=  				"AND SB1ORI.B1_COD = SD3ORI.D3_COD "
cQuery +=  				"AND SB1ORI.B1_COD NOT LIKE 'MOD%' "
cQuery +=  				"AND SB1ORI.B1_CCCUSTO = ' ' "
cQuery +=  				"AND SB1ORI.D_E_L_E_T_ = ' ' "
cQuery +=  				"AND "
If lCpoBZTP
	cQuery +=  MatIsNull()+"(SBZORI.BZ_TIPO,SB1ORI.B1_TIPO) "
Else
	cQuery +=  "SB1ORI.B1_TIPO "
EndIf
cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+")"
cQuery += ")) "
MATExecQry(cQuery)
Return


/*/{Protheus.doc} BlkPro250
Grava a data de apuracao do SPED FISCAL nos registros de movimentacoes internas
referente a producao de uma ordem de producao de terceiros utilizados na
geracao dos registros K250
@Andr� Maximo
@since 08/10/2018
@version 1.0
@return ${return}, ${return_description}
@param dDataDe, date, descricao
@param dDataAte, date, descricao
@type function
/*/
Function BlkPro250(dDataDe,dDataAte)
Local cQuery	:= " "
Local cPeriodo	:= ""

cPeriodo := cPeriodo :=	Left(dtos(dDataAte),6)

cQuery := "UPDATE "+RetSQLName("SD3")+" "
cQuery += "SET D3_PERBLK = '"+cPeriodo+"' "
cQuery += "WHERE R_E_C_N_O_ IN(SELECT SD3.R_E_C_N_O_ "
cQuery += "FROM "+RetSQLName("SD3")+" SD3 "
cQuery += "JOIN "+RetSqlName("SC2")+" SC2 ON SC2.C2_FILIAL = '"+xFilial('SC2')+"' "
cQuery += "AND SD3.D3_OP = SC2.C2_NUM " + MatiConcat()+" SC2.C2_ITEM " + MatiConcat()+" SC2.C2_SEQUEN " + MatiConcat()+" SC2.C2_ITEMGRD "
cQuery += "AND SC2.C2_PRODUTO = SD3.D3_COD "
cQuery += "AND SC2.C2_ITEM <> 'OS' "
cQuery += "AND SC2.C2_TPPR = 'E' "
cQuery += " AND SC2.D_E_L_E_T_ = ' ' "
cQuery += "WHERE SD3.D3_FILIAL = '"+xFilial('SD3')+"' "
cQuery += "AND SD3.D3_OP <> ' ' "
cQuery += "AND SD3.D3_CF IN ('PR0','PR1','ER0','ER1') "
cQuery += "AND SD3.D3_COD NOT LIKE 'MOD%' "
cQuery += "AND SD3.D3_EMISSAO BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"' "
cQuery += "AND SD3.D_E_L_E_T_ = ' ' "
cQuery += "AND EXISTS( "
cQuery += 		"SELECT 1 FROM "+RetSqlName("SB1")+" SB1 "
If lCpoBZTP
	cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
cQuery += 		"WHERE SB1.B1_FILIAL = '"+xFilial('SB1')+"' "
cQuery += 			"AND SB1.B1_COD = SD3.D3_COD "
cQuery += 			"AND SB1.B1_COD NOT LIKE 'MOD%' "
cQuery += 			"AND SB1.B1_CCCUSTO = ' ' "
cQuery += 			"AND SB1.D_E_L_E_T_ = ' ' "
cQuery += 			"AND "
If lCpoBZTP
	cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
Else
	cQuery += "SB1.B1_TIPO "
EndIf
cQuery += "IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
cQuery += ") "
cQuery += "AND NOT EXISTS( "
cQuery += 	"SELECT 1 FROM "+RetSqlName("SD4")+" SD4 "
cQuery +=  	"WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"' "
cQuery +=  		"AND SD4.D4_OP = SD3.D3_OP "
cQuery +=  		"AND SD4.D4_PRODUTO = SC2.C2_PRODUTO "
cQuery +=  		"AND SD4.D4_COD = SD3.D3_COD "
cQuery +=  		"AND SD4.D4_QTDEORI < 0 "
cQuery +=  		"AND SD4.D_E_L_E_T_ = ' ' "
cQuery += "))"
MATExecQry(cQuery)
Return

/*/{Protheus.doc} BlkPro255
Grava a data de apuracao do SPED FISCAL nos registros de movimentacoes internas
referente a requisicao de uma ordem de producao de terceiros utilizados na
geracao dos registros K255
@Andr� Maximo
@since 08/10/2018
@version 1.0
@return ${return}, ${return_description}
@param dDataDe, date, descricao
@param dDataAte, date, descricao
@type function
/*/
Function BlkPro255(dDataDe,dDataAte)
Local cQuery	:= " "
Local cPeriodo	:= ""

cPeriodo :=	Left(dtos(dDataAte),6)

cQuery := "UPDATE "+RetSQLName("SD3")+" "
cQuery += "SET D3_PERBLK = '"+cPeriodo+"' "
cQuery += "WHERE R_E_C_N_O_ IN(SELECT SD3.R_E_C_N_O_ "
cQuery += "FROM "+RetSQLName("SD3")+" SD3 "
cQuery += "JOIN "+RetSqlName("SC2")+" SC2 ON SC2.C2_FILIAL = '"+xFilial('SC2')+"' "
cQuery += "AND SD3.D3_OP = SC2.C2_NUM " + MatiConcat()+" SC2.C2_ITEM " + MatiConcat()+" SC2.C2_SEQUEN " + MatiConcat()+" SC2.C2_ITEMGRD "
cQuery += "AND SC2.C2_ITEM <> 'OS' "
cQuery += "AND SC2.C2_TPPR = 'E' "
cQuery += "AND SC2.D_E_L_E_T_ = ' ' "
cQuery += "WHERE SD3.D3_FILIAL = '"+xFilial('SD3')+"' "
cQuery += "AND (SD3.D3_CF LIKE ('RE%') OR SD3.D3_CF LIKE ('DE%')) "
cQuery += "AND SD3.D3_EMISSAO BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"' "
cQuery += "AND SD3.D_E_L_E_T_ = ' ' "
cQuery += "AND EXISTS( "
cQuery += 		"SELECT 1 FROM "+RetSqlName("SB1")+" SB1 "
If lCpoBZTP
	cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
cQuery += 		"WHERE SB1.B1_FILIAL = '"+xFilial('SB1')+"' "
cQuery += 			"AND SB1.B1_COD = SD3.D3_COD "
cQuery += 			"AND SB1.B1_COD NOT LIKE 'MOD%' "
cQuery += 			"AND SB1.B1_CCCUSTO = ' ' "
cQuery += 			"AND SB1.D_E_L_E_T_ = ' ' "
cQuery += 			"AND "
If lCpoBZTP
	cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
Else
	cQuery += "SB1.B1_TIPO "
EndIf
cQuery += "IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
cQuery += ") "
cQuery += "AND NOT EXISTS( "
cQuery += 	"SELECT 1 FROM "+RetSqlName("SD4")+" SD4 "
cQuery +=  	"WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"' "
cQuery +=  		"AND SD4.D4_OP = SD3.D3_OP "
cQuery +=  		"AND SD4.D4_PRODUTO = SC2.C2_PRODUTO "
cQuery +=  		"AND SD4.D4_COD = SD3.D3_COD "
cQuery +=  		"AND SD4.D4_QTDEORI < 0 "
cQuery +=  		"AND SD4.D_E_L_E_T_ = ' ' "
cQuery += "))"
MATExecQry(cQuery)
Return

/*/{Protheus.doc} BlkPro302
Grava a data de apuracao do SPED FISCAL nos registros de movimentacoes internas
referente a requisicao de uma ordem de producao de terceiros com estrutura
negativa utilizados na geracao dos registros K255
@Andr� Maximo
@since 08/10/2018
@version 1.0
@return ${return}, ${return_description}
@param dDataDe, date, descricao
@param dDataAte, date, descricao
@type function
/*/
Function BlkPro302(dDataDe,dDataAte,cOP)
Local cQuery		:= " "
Local cData

cData := Substr(dTOS(dDataAte),1,6)
cQuery:= "UPDATE "+RetSQLName("SD3")+" "
cQuery+= " SET	D3_PERBLK = '"+cData+"'"
cQuery+= " WHERE R_E_C_N_O_ IN(SELECT SD3.R_E_C_N_O_ "
cQuery += "FROM "+RetSqlName("SD3")+" SD3 "
cQuery += "JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' "
cQuery += " AND SB1.B1_COD = SD3.D3_COD "
cQuery += " AND SB1.B1_CCCUSTO = ' ' "
cQuery += " AND SB1.B1_COD NOT LIKE 'MOD%' "
cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
If lCpoBZTP
	cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' "
	cQuery += "AND SBZ.BZ_COD = SB1.B1_COD "
	cQuery += "AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
cQuery += "JOIN "+RetSqlName("SC2")+" SC2 ON SD3.D3_OP = SC2.C2_NUM " + MatiConcat()+" SC2.C2_ITEM " + MatiConcat()+" SC2.C2_SEQUEN " + MatiConcat()+" SC2.C2_ITEMGRD "
cQuery += "AND SC2.C2_FILIAL = '"+xFilial('SC2')+"' "
cQuery += "AND SC2.C2_ITEM <> 'OS' "
cQuery += "AND SC2.C2_TPPR IN ('E') "
cQuery += "AND SC2.D_E_L_E_T_ = ' ' "
cQuery += "WHERE SD3.D3_FILIAL = '"+xFilial('SD3')+"' "
cQuery += " AND (SD3.D3_CF LIKE ('RE%') OR SD3.D3_CF LIKE ('DE%')) "
cQuery += " AND SD3.D3_EMISSAO BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"' "
cQuery += " AND SD3.D_E_L_E_T_ = ' ' "
cQuery += " AND "
If lCpoBZTP
	cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
Else
	cQuery += "SB1.B1_TIPO "
EndIf
cQuery += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
cQuery += "AND EXISTS( "
cQuery += "SELECT 1 "
cQuery += "FROM "
cQuery += RetSqlName("SD4")+" SD4 "
cQuery += "WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"' "
cQuery += "AND SD4.D4_OP = SD3.D3_OP "
cQuery += "AND SD4.D4_PRODUTO = SC2.C2_PRODUTO "
cQuery += "AND SD4.D4_QTDEORI < 0 "
cQuery += "AND SD4.D_E_L_E_T_ = ' ' )"
cQuery += "AND EXISTS( "
cQuery += "SELECT 1 "
cQuery += "FROM "
cQuery += RetSqlName("SD4")+" SD4 "
cQuery += "WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"' "
cQuery += "AND SD4.D4_OP = SD3.D3_OP "
cQuery += "AND SD4.D4_COD = SD3.D3_COD "
cQuery += "AND SD4.D4_QTDEORI > 0 "
cQuery += "AND SD4.D_E_L_E_T_ = ' ' )"
cQuery += ") "

MATExecQry(cQuery)
Return

/*/{Protheus.doc} BlkPro301
Grava a data de apuracao do SPED FISCAL nos registros de movimentacoes internas
referente a producao de uma ordem de producao de terceiros com estrutura
negativa utilizados na geracao dos registros K255
@Andr� Maximo
@since 08/10/2018
@version 1.0
@return ${return}, ${return_description}
@param dDataDe, date, descricao
@param dDataAte, date, descricao
@type function
/*/
Function BlkPro301(dDataDe,dDataAte)
Local cQuery	:= " "
Local cPeriodo	:= ""

cPeriodo := Substr(dTOS(dDataAte),1,6)

cQuery := ""
cQuery += "UPDATE "+RetSQLName("SD3")+" "
cQuery += "SET D3_PERBLK = '"+cPeriodo+"' "
cQuery += "WHERE R_E_C_N_O_ IN(SELECT SD3.R_E_C_N_O_ "
cQuery += "FROM "+RetSQLName("SD3")+" SD3 "
cQuery += "JOIN "+RetSQLName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery += 	"AND SB1.B1_COD = SD3.D3_COD "
cQuery += 	"AND SB1.B1_CCCUSTO = ' ' "
cQuery += 	"AND SB1.D_E_L_E_T_ = ' ' "
If lCpoBZTP
	cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' "
	cQuery += "AND SBZ.BZ_COD = SB1.B1_COD "
	cQuery += "AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
cQuery += "INNER JOIN "+RetSQLName("SC2")+" SC2 ON  SC2.C2_NUM " + MatiConcat()+" SC2.C2_ITEM " + MatiConcat()+" SC2.C2_SEQUEN " + MatiConcat()+" SC2.C2_ITEMGRD = SD3.D3_OP "
cQuery += 	"AND SC2.C2_FILIAL = '"+xFilial('SC2')+"' "
cQuery += 	"AND SC2.C2_ITEM <> 'OS' "
cQuery += 	"AND SC2.C2_TPPR = 'E' "
cQuery +=	"AND SC2.D_E_L_E_T_ = ' ' "
cQuery += "WHERE SD3.D3_FILIAL = '"+xFilial("SD3")+"' "
cQuery += 	"AND SD3.D3_CF IN ( "
cQuery += 		"'PR0','PR1' "
cQuery += 		",'ER0','ER1' ) "
cQuery += 	"AND SD3.D3_COD NOT LIKE 'MOD%' "
cQuery += 	"AND SD3.D3_EMISSAO BETWEEN '"+DTOS(dDataDe)+"' "
cQuery += 	"AND '"+DTOS(dDataAte)+"' "
cQuery += 	"AND SD3.D_E_L_E_T_ = ' ' "
If lCpoBZTP
	cQuery += "AND COALESCE(SBZ.BZ_TIPO,SB1.B1_TIPO) "
Else
	cQuery += "AND SB1.B1_TIPO "
EndIf
cQuery += "IN ( "+cTipo03+","+cTipo04
cQuery += ") "
cQuery += "UNION ALL "
cQuery += "SELECT SD3.R_E_C_N_O_ "
cQuery += "FROM "+RetSQLName("SD3")+" SD3 "
cQuery += "JOIN "+RetSQLName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery += 	"AND SB1.B1_COD = SD3.D3_COD "
cQuery += 	"AND SB1.B1_FANTASM != 'S' "
cQuery += 	"AND SB1.B1_CCCUSTO = ' ' "
cQuery += 	"AND SB1.D_E_L_E_T_ = ' ' "
If lCpoBZTP
	cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' "
	cQuery += "AND SBZ.BZ_COD = SB1.B1_COD "
	cQuery += "AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
cQuery += "INNER JOIN "+RetSQLName("SC2")+" SC2 ON  SC2.C2_NUM " + MatiConcat()+" SC2.C2_ITEM " + MatiConcat()+" SC2.C2_SEQUEN " + MatiConcat()+" SC2.C2_ITEMGRD = SD3.D3_OP "
cQuery += 	"AND SC2.C2_FILIAL = '"+xFilial('SC2')+"' "
cQuery += 	"AND SC2.C2_ITEM <> 'OS' "
cQuery += 	"AND SC2.C2_TPPR = 'E' "
cQuery += 	"AND SC2.D_E_L_E_T_ = ' ' "
cQuery += "WHERE SD3.D3_FILIAL = '"+xFilial("SD3")+"' "
cQuery += 	"AND SD3.D3_CF IN ('RE1','DE1')  "
cQuery +=	"AND SD3.D3_COD NOT LIKE 'MOD%' "
cQuery += 	"AND SD3.D3_EMISSAO BETWEEN '"+DTOS(dDataDe)+"' "
cQuery += 	"AND '"+DTOS(dDataAte)+"' "
cQuery += 	"AND SD3.D_E_L_E_T_ = ' ' "
If lCpoBZTP
	cQuery += "AND COALESCE(SBZ.BZ_TIPO,SB1.B1_TIPO) IN ( "
Else
	cQuery += "AND SB1.B1_TIPO IN ( "
EndIf
cQuery += cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+" "
cQuery += ") "
cQuery += "AND EXISTS( "
cQuery += 	"SELECT 1 FROM "+RetSqlName("SD4")+" SD4 "
cQuery +=  	"WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"' "
cQuery +=  		"AND SD4.D4_OP = SD3.D3_OP "
cQuery +=  		"AND SD4.D4_PRODUTO = SC2.C2_PRODUTO "
cQuery +=  		"AND SD4.D4_COD = SD3.D3_COD "
cQuery +=  		"AND SD4.D4_QTDEORI < 0 "
cQuery +=  		"AND SD4.D_E_L_E_T_ = ' ' "
cQuery += "))"
MATExecQry(cQuery)
Return

/*/{Protheus.doc} BlkPrLimp
Limpa o campo D3_PERBLK para permitir re-processar os registros de movimentacao interna
@Andr� Maximo
@since 08/10/2018
@version 1.0
@return ${return}, ${return_description}
@param dDataDe, date, descricao
@param dDataAte, date, descricao
@type function
/*/
Function BlkPrLimp(dDataAte)
Local cQuery	:= " "
Local cPeriodo	:= ""

cPeriodo :=	Left(dtos(dDataAte),6)

cQuery:= "UPDATE "+RetSQLName("SD3")+" SET D3_PERBLK = '"+space(TamSX3("D3_PERBLK")[1])+"' WHERE D3_PERBLK = '"+cPeriodo+"' AND D3_FILIAL = '" +xFilial("SD3")+ "'"

MATExecQry(cQuery)
Return

/*/{Protheus.doc} MatiConcat
realizaajuste na concatena��o na string da query de UPDATE
@author andre.maximo
@since 09/10/2018
@version 1.0

@return ${cFunConcat}, ${C�digo para concatenar}
/*/
Function MatiConcat()

Local cFunConcat := " "
Local cDbType   := TCGetDB()

Do Case
	 Case cDbType $ "DB2|POSTGRES|ORACLE|INFORMIX"
		  cFunConcat    := "||"
	  Otherwise
		  cFunConcat    := "+"
EndCase

Return cFunConcat

/*/{Protheus.doc} MatLimpD3K
Limpa o campo D3_PERBLK, pois o registro que est� sendo estornado n�o pode ter
o campo PREENCHIDO. J� que o mesmo s� � preenchido quando � gerado o SPED Fiscal
@Andr� Maximo
@since 24/10/2018
@version 1.0
@return ${return}, ${return_description}
@param dDataDe, date, descricao
@param dDataAte, date, descricao
@type function
/*/
Function MatLimpD3K(cProduto,cNumSeq)
Local AreaAtiv	:= GetArea()

Default cProduto	:= ""
Default cNumSeq		:= ""

If SD3->(ColumnPos("D3_PERBLK")) >0
	RecLock("SD3",.F.)
	D3_PERBLK := space(TamSX3("D3_PERBLK")[1])
	msUnLock()
EndIf

/*If AliasInDic("D3K")
	DbSelectArea("D3K")
	DbSetOrder(1)
	cFilialD3K := xFilial("D3K")
	MsSeek(cFilialD3K+cNumSeq+cProduto)
	While D3K->(!Eof() .And. D3K->(D3K_FILIAL+D3K_NUMSEQ+D3K_COD) == cFilialD3K+cNumSeq+cProduto )
		RecLock("D3K",.F.)
		dbDelete()
		MsUnlock()
		D3K->(DbSkip())
	EndDo
EndIf*/
RestArea(AreaAtiv)
Return

/*/{Protheus.doc} MATExecQry
Funcao generica para executar uma query de INSERT ou DELETE e caso seja gerado
uma inconsistencia possa abortar o processo
@author reynaldo
@since 24/10/2018
@version 1.0
@return ${return}, ${return_description}
@param cQuery, characters, descricao
@type function
/*/
Function MATExecQry(cQuery)
Local cMensErro := ""

If (TcSqlExec(cQuery) < 0)
	cMensErro := TCSQLError() + " ocorrida fun��o " +ProcName(-1)+ " na linha " +cValtoChar(ProcLine(-1))+ ". "
	UserException(cMensErro)
EndIf

Return

// ---------------------------------------------------------------------------
/*/{Protheus.doc} EstProsSPE
realiza ajuste na concatena��o na string da query de UPDATE
@author andre.maximo
@since 09/10/2018
@version 1.0

@return ${cFunConcat}, ${C�digo para concatenar}
/*/
// ---------------------------------------------------------------------------
Function EstProsSPE(dDataDe,dDataAte)
Local aAreaAnt := GetArea()
Local cQuery	:= ""
Local lRet		:= .T.
Local cFilialSC2 := xfilial("SC2")
Local cFilialSD3 := xfilial("SD3")
Local cAliasTmp := CriaTrab(Nil,.F.)
Local lMVPROD   := ""
Local lD3kLote

DbSelectArea("D3K")
lD3kLote := FieldPos("D3K_LOTE") > 0

lMVPROD := SuperGetMV("MV_PRODMOD",.F.,.T.)

cQuery:="SELECT 1 "
cQuery+=	"FROM "+RetSQLName("SD3")+" SD3 "
cQuery+=	"LEFT JOIN "+RetSQLName("SC2")+" SC2 "
cQuery+=		"ON	SD3.D3_OP = SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN || SC2.C2_ITEMGRD "
cQuery+=		  	"AND SC2.C2_FILIAL ='"+cFilialSC2+"' "
cQuery+=		   	"AND SC2.D_E_L_E_T_ = ' ' "
cQuery+=	"LEFT JOIN "+RetSQLName("D3K")+" D3K "
cQuery+=		"ON D3K_FILIAL = '"+cFilialSD3+"' "
cQuery+=		"AND D3K.D3K_COD = SD3.D3_COD "
cQuery+=		"AND D3K.D3K_NUMSEQ = SD3.D3_NUMSEQ "
cQuery+=		"AND D3K.D3K_OP = SD3.D3_OP "
If lD3kLote
	cQuery+=	"AND D3K.D3K_LOTE = SD3.D3_LOTECTL "
Endif
cQuery+=		"AND D3K.D_E_L_E_T_ =' ' "
cQuery+="WHERE  SD3.D3_FILIAL = '"+cFilialSD3+"' "
cQuery+=	"AND SD3.D_E_L_E_T_ = ' ' "
cQuery+=	"AND SD3.D3_ESTORNO = ' ' "
cQuery+=	"AND SD3.D3_OP <> ' ' "
cQuery+=	"AND SD3.D3_CF IN ( 'RE5','RE9','RE6','RE3','RE2','RE0','RE1','PR0','PR1') "
cQuery+=	"AND SD3.D3_EMISSAO BETWEEN '"+DtoS(dDataDe)+"' "
cQuery+=	"AND '"+DtoS(dDataAte)+"' "
cQuery+=	"AND SD3.D_E_L_E_T_ = ' ' "
cQuery+=	"AND SC2.C2_OPTERCE = '1' "
cQuery+=	"AND SUBSTRING(SD3.D3_COD,1,3) <> 'MOD' "
If lMVPROD
	cQuery += " AND D3_COD in (select D3_COD  FROM "+ RetSqlName("SB1") + " WHERE B1_FILIAL = '"+FWxFilial('SB1')+"' AND B1_COD = D3_COD AND B1_CCCUSTO = ' ')"
EndIf
cQuery+=	"group by D3_COD, D3_OP,D3_NUMSEQ, D3_QUANT "
cQuery+=	"having "+MatIsNull()+"(SD3.D3_QUANT,-1) - SUM("+MatIsNull()+"(D3K.D3K_QTDE,-1))  > 0 "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

While !(cAliasTmp)->(Eof())
	lRet := .F.
	Exit
EndDo

(cAliasTmp)->(dbCloseArea())

RestArea(aAreaAnt)

Return(lRet)

/*/{Protheus.doc} BlkGrvTab
Funcao generica para gravar os registros do bloco k processados nas tabelas de historico.
@author andre.maximo
@since 09/10/2018
@version 1.0
@return ${return}, ${return_description}
@param cAliREG, characters, descricao
@param cBlk, characters, descricao
@param aTabBLK, array, descricao
@param dDataAte, date, descricao
@param lRepross, logical, descricao
@param lJbK200, logical, descricao
@type function
/*/
Function BlkGrvTab(cAliREG,cBlk,aTabBLK,dDataAte,lRepross,lJbK200)
Local nY
Local cQuery
Local cQuerDel
Local cTabConvert
Local aTabTemp	:= {}
Local aTabAlias	:= {}
Local cD3IFilial:= ""
Local cFilTab	:= xfilial(cBlk)

Default cAliREG	:= " "
Default cBlk	:= " "
Default aTabBLK	:= {}
Default lRepross:= .F.
Default dDataAte:= DTOS('')
Default lJbK200 := .F.

cData := Substr(dTOS(dDataAte),1,6)

If lRepross
	aTabTemp := (cBlk)->(dbStruct())
	aTabAlias:= (cAliREG)->(dbStruct())

	cQuerDel := "DELETE FROM "+RetSqlName(cBlk)+" "
	cQuerDel += "WHERE "+ cBlk+"_FILIAL = '"+ cFilTab+"' "
	cQuerDel += "AND  "+ cBlk+"_PERBLK = '"+cData+"' "
	MATExecQry(cQuerDel)

	If lJbK200
		cD3IFilial:= xFilial("D3I")
		DbSelectArea("D3I")
		While !(cAliREG)->(Eof())
			Reclock("D3I",.T.)
			D3I_FILIAL	:=  cD3IFilial
			D3I_REG		:=  "K200"
			D3I_DT_EST	:=  (cAliREG)->DT_EST
			D3I_COD_IT	:= 	(cAliREG)->COD_ITEM
			D3I_QTD		:=  (cAliREG)->QTD
			D3I_IND_ES	:= 	(cAliREG)->IND_EST
			D3I_COD_PA	:= 	(cAliREG)->COD_PART
			D3I_PERBLK	:= 	cData
			MsUnLock()
			(cAliREG)->(DbSkip())
		Enddo
	Else
		cQuery	:= " INSERT INTO " + RetSQLName(cBlk)+" ( "
		For nY 	:= 1 to Len(aTabAlias)
			If Len(aTabAlias[ny][1])>6
				cTabConvert := BlkConvTab(cBlk,aTabAlias[ny][1])
				cQuery    += cBlk +"_" +cTabConvert+","
			Else
				cQuery    += cBlk +"_" + LEFT(aTabAlias[ny][1],6)+","
			EndIf
		Next nY
		cQuery	+= cBlk +"_PERBLK"
		cQuery+=") "
		cQuery	+= "SELECT "
		For nY 	:= 1 to Len(aTabAlias)
			If Alltrim(aTabAlias[ny][1]) = 'FILIAL'
				cQuery    += "'"+cFilTab+"',"
			else
				cQuery	+= aTabAlias[ny][1]+","
			EndIf
		Next nY
		cQuery+= "'"+cData+"' "
		cQuery+="FROM " + aTabBLK:GetRealName()+ " "
		cQuery+="WHERE D_E_L_E_T_ = ' ' "

		MATExecQry(cQuery)
	EndIf
EndIf

Return

//---------------------------------------------------------------
/*/{Protheus.doc} BlkReg280
grava registros processados nos registro K270/K275
@author andre.maximo
@since 29/10/2018
@version 1.0

@return ${cFunConcat}, ${C�digo para concatenar}
/*/
Function BlkReg280(cFilK,cReg,dCorr,dApur,cProduto,nQuant,cCliente,cLoja,cAliK280)
Local nMes		:= 0
Local nX		:= 0
Local cIND_EST	:= ""
Local cCOD_PART	:= ""
Local cChave	:= ""
Local dCalc		:= ""

Default cCliente	:= " "
Default cLoja		:= " "

nMes := DateDiffMonth(dCorr,dApur)

For nX := 1 to nMes
	dCalc := MonthSum(dCorr,(nX-1))

	cChave	:= cFilK+DTOS(dCalc)+cProduto
	If Empty(cCliente+cLoja)
		cIND_EST := "0"
	Else
		Do CASE
		case cReg =="K210" .Or. cReg =="K215"
			cIND_EST := "2"
			cCOD_PART:= "C:"+cCliente+"-"+cLoja
		case cReg =="K220"
			cIND_EST := "2"
			cCOD_PART:= "C:"+cCliente+"-"+cLoja
		case cReg =="K250" .Or. cReg =="K255"
			cIND_EST := "1"
			cCOD_PART:= "F:"+cCliente+"-"+cLoja
		case cReg =="K301"  .Or. cReg =="K302"
			cIND_EST := "1"
			cCOD_PART:= "F:"+cCliente+"-"+cLoja
		endcase

	EndIf
	cChave	+= cIND_EST+cCOD_PART

	If (cAliK280)->(MsSeek(cChave))
		RecLock(cAliK280,.F.)
		If nQuant >0
			(cAliK280)->QTD_COR_P += nQuant
		Else
			(cAliK280)->QTD_COR_N += nQuant*-1
		EndIf

		If !Empty((cAliK280)->QTD_COR_P) .And. !Empty((cAliK280)->QTD_COR_N)
			If (cAliK280)->QTD_COR_P >= (cAliK280)->QTD_COR_N
				(cAliK280)->QTD_COR_P -= (cAliK280)->QTD_COR_N
				(cAliK280)->QTD_COR_N := 0
			Else
				(cAliK280)->QTD_COR_N -= (cAliK280)->QTD_COR_P
				(cAliK280)->QTD_COR_P := 0
			EndIf
		Endif
	Else
		Reclock(cAliK280,.T.)
		(cAliK280)->FILIAL		:= cFilK
		(cAliK280)->REG			:= "K280"
		(cAliK280)->DT_EST		:= dCalc
		(cAliK280)->COD_ITEM	:= cProduto
		If nQuant >0
			(cAliK280)->QTD_COR_P := nQuant
		Else
			(cAliK280)->QTD_COR_N := nQuant*-1
		EndIf
		(cAliK280)->IND_EST	:=	cIND_EST
		(cAliK280)->COD_PART	:=	cCOD_PART
	EndIf
	(cAliK280)->(MsUnLock())
	nRegsto++
Next nX

Return

/*/{Protheus.doc} MatiSubStr
Ajuste na concatena��o na string da query
@author andre.maximo
@since 09/10/2018
@version 1.0

@return ${cFunConcat}, ${C�digo para concatenar}
/*/
Function MatiSubStr()

Local cFunConcat := " "
Local cDbType   := TCGetDB()

Do Case
	 Case cDbType $ "DB2|POSTGRES|ORACLE|INFORMIX"
		  cFunConcat    := "SUBSTR"
	  Otherwise
	  	cFunConcat    := "SUBSTRING"
EndCase

Return cFunConcat
/*/{Protheus.doc} BlkConvTab
@author andre.maximo
@since 13/11/2018
@version 1.0

@return ${cFunConcat}, ${C�digo para concatenar}
/*/

Function BlkConvTab(cBlk,cCpoBlk)

Local cCampos:= ''

Do Case
	Case cBlk == 'D3F'
		If cCpoBlk == 'COD_ITEM'
			cCampos := 'COD_IT'
		Elseif cCpoBlk ==  'COD_I_COMP'
			cCampos := 'COD_CP'

		Elseif cCpoBlk == 'QTD_COMP'
			cCampos := 'QTD_CO'

		Elseif cCpoBlk == 'QTD_PROD'
			cCampos := 'QTD_PR'

		else 	//QTD_CON
			cCampos := 'QTD_CS'
		EndIf
	Case cBlk == 'D3G'
		If cCpoBlk == 'IND_MOV'
		  	cCampos := 'IND_MO'
		EndIf
	Case cBlk == 'D3H'
		If cCpoBlk == 'DT_INI'
			cCampos := 'DT_INI'
		else
			cCampos := 'DT_FIN'
		EndIf
	Case cBlk == 'D3I'
		If cCpoBlk == 'DT_EST'
			cCampos := 'DT_EST'
		elseIf cCpoBlk == 'COD_ITEM'
			cCampos := 'COD_IT'
		elseIf cCpoBlk == 'IND_EST'
			cCampos := 'IND_ES'
		else // 'COD_PART'
			cCampos := 'COD_PA'
		EndIf

	Case cBlk == 'D3J'
		If cCpoBlk == 'DT_INI_OS'
			cCampos := 'DT_INI'
		ElseIf cCpoBlk ==  'DT_FIN_OS'
			cCampos := 'DT_FIN'
		ElseIf cCpoBlk ==  'COD_DOC_OS'
			cCampos := 'COD_DO'
		ElseIf cCpoBlk ==  'COD_ITEM_O'
			cCampos := 'COD_IT'
		Else //QTD_ORI
			cCampos := 'QTD_OR'
		EndIf
	Case cBlk == 'D3L'
		If cCpoBlk == 'COD_DOC_OS'
			cCampos := 'COD_DO'
		ElseIf cCpoBlk == 'COD_ITEM_D'
			cCampos := 'COD_IT'
		Else //'QTD_DES'
			cCampos := 'QTD_DE'
		EndIf
	Case cBlk == 'D3M'
		If cCpoBlk == 'COD_ITEM_O'
				cCampos := 'COD_IO'
		ElseIf cCpoBlk == 'COD_ITEM_D'
				cCampos := 'COD_ID'
		ElseIf cCpoBlk == 'QTD_ORI'
				cCampos := 'QTD_OR'
		Else	//'QTD_DEST'
				cCampos := 'QTD_DE'
		EndIf
	Case cBlk == 'D3N'
		If cCpoBlk == 'DT_PROD'
			cCampos := 'DT_PRO'
		Else//'COD_ITEM'
			cCampos := 'COD_IT'
		EndIf

	Case cBlk == 'D3O'
		If cCpoBlk == 'DT_CONS'
			cCampos := 'DT_CON'
		elseif cCpoBlk == 'COD_ITEM'
			cCampos := 'COD_IT'
		Else	//COD_INS_SU
			cCampos := 'COD_IN'
		EndIf
	Case cBlk == 'D3P'
		If	cCpoBlk == 'DT_EST'
			cCampos := 'DT_EST'
		ElseIf cCpoBlk ==  'COD_ITEM'
			cCampos := 'COD_IT'
		ElseIf cCpoBlk == 'QTD_COR_P'
				cCampos := 'QTD_PO'
		ElseIf	cCpoBlk == 'QTD_COR_N'
				cCampos := 'QTD_NE'
		ElseIf cCpoBlk == 'IND_EST'
				cCampos := 'IND_ES'
		Else //COD_PART
				cCampos := 'COD_PA'
		EndIf
	Case cBlk == 'D3R'
		If cCpoBlk == 'DT_PROD'
			cCampos := 'DT_PRO'
		EndIf
	Case cBlk == 'D3S'
		If cCpoBlk == 'COD_ITEM'
			cCampos := 'COD_IT'
		EndIf
	Case cBlk == 'D3T'
		If cCpoBlk =='COD_ITEM'
			cCampos := 'COD_IT'
		EndIf
	Case cBlk == 'D3U'
		If cCpoBlk == 'QTD_LIN_K'
			cCampos := 'QTD_LI'
		EndIf
EndCase


return cCampos

/*/{Protheus.doc} ChkUpd
Fun��o de verifica��o do UPD
@author Reynaldo
@since 26/11/2018
@version 1.0

@return ${cFunConcat}, ${C�digo para concatenar}
/*/
Static Function ChkUpd()
Local cMensErro	:= ""
Local cLinSep	:= ""
Local lFalha	:= .F.

If EstChkDic("T4E", "T4E_SEMRET")
	If !EstChkTbl("T4E", "T4E_SEMRET")
		lFalha	:= .T.
	EndIf
Else
	lFalha	:= .T.
EndIf


If lFalha
	//linha de separa��o para mensagem
	cLinSep	:= REPLICATE( "=", 58 )

	cMensErro := ""
	cMensErro += Chr(10)
	cMensErro += cLinSep+chr(10)
	cMensErro += "ATEN��O!!! "+Chr(10)

	cMensErro += "Este ambiente est� com o dicion�rio de dados incompativel "+Chr(10)
	cMensErro += "com a vers�o dos fontes existentes no repositorio de dados, "+Chr(10)
	cMensErro += "este problema ocorre devido a n�o execu��o do compatibilizador"+Chr(10)
	cMensErro += "do produto."+Chr(10)
	cMensErro += Chr(10)
	cMensErro += "Sera necess�rio executar o UPDDISTR com o �ltimo arquivo "+Chr(10)
	cMensErro += "diferencial (SDFBRA) disponivel no portal do cliente."+Chr(10)
	cMensErro += Chr(10)
	cMensErro += "Consulte o o guia de referencia do bloco K no link abaixo:"+Chr(10)
	cMensErro += "http://tdn.totvs.com/pages/viewpage.action?pageId=235589625"+Chr(10)
	cMensErro += "Ap�s seguir os passos acima a gera��o do bloco K atrav�s do "+Chr(10)
	cMensErro += "MATR241 e/ou SPED FISCAL ser� liberado!!"+Chr(10)
	cMensErro +=cLinSep+chr(10)
	UserException(cMensErro)
EndIf

Return

/*/{Protheus.doc} EstChkDic
verifica se o campo e tabela existe no dicionario de dados(SX3)
@author reynaldo
@since 15/01/2019
@version 1.0
@return logico, Verdadeiro se o campo existe

@type function
/*/
Static Function EstChkDic(cTable, cField)
Local lExist := .F.
Local aFields:= {}

// Utilizada a classe ESTFWSX3Util que encapsula a classe FWSX3Util.
aFields := ESTFWSX3Util():xGetAllFields( cTable , .T. )
If aScan(aFields,{|x|x==cField})>0
	lExist := .T.
	aFields := {}
EndIf

Return lExist

/*/{Protheus.doc} EstChkTblT4E
verifica se o campo existe no alias informado
@author reynaldo
@since 15/01/2019
@version 1.0
@return logico, Verdadeiro se o campo existe

@type function
/*/
Static Function EstChkTbl(cAlias, cField)
Local lExist := .T.
Local aArea

 	aArea := GetArea()
	dbSelectArea(cAlias)
	If (cAlias)->(FieldPos(cField))==0
		lExist := .F.
	EndIf
 	RestArea(aArea)

Return lExist

/*/{Protheus.doc} SequePer
Fun��o que busca a maior sequencia no periodo
/*/
Static Function SequePer(dDataDe,dDataAte)
Local cQuery
Local cNumSeqD3 := ""
Local cNumSeqD1 := ""
Local cNumSeqD2 := ""
Local cAliasTmp := "SRCSEQ"
Local cDataant	:= ''
Local cMinSeq	:= " "

cDataAnt 	:= Substr(DtoS(MonthSub( dDataDe, 1 )),1,6)+'01'

cQuery:="SELECT MIN(D3_NUMSEQ) MINSEQ FROM "+RetSQLName("SD3")+" WHERE D3_PERBLK <> '      ' AND D3_EMISSAO >= '"+cDataAnt+"' AND D3_EMISSAO < '"+DtoS(dDataDe)+"' AND D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

While !(cAliasTmp)->(Eof())
	cNumSeqD3 := (cAliasTmp)->MINSEQ
	Exit
EndDo

(cAliasTmp)->(dbCloseArea())

cQuery:="SELECT Min(D1_NUMSEQ) MINSEQ FROM "+RetSQLName("SD1")+" WHERE D1_DTDIGIT >=  '"+cDataAnt+"' AND D1_DTDIGIT < '"+DtoS(dDataDe)+"' AND D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

While !(cAliasTmp)->(Eof())
	cNumSeqD1 := (cAliasTmp)->MINSEQ
	Exit
EndDo
(cAliasTmp)->(dbCloseArea())

cQuery:="SELECT Min(D2_NUMSEQ) MINSEQ FROM "+RetSQLName("SD2")+" WHERE D2_EMISSAO >= '"+cDataAnt+"' AND  D2_EMISSAO < '"+DtoS(dDataDe)+"' AND D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

While !(cAliasTmp)->(Eof())
	cNumSeqD2 := (cAliasTmp)->MINSEQ
	Exit
EndDo
(cAliasTmp)->(dbCloseArea())

cMinSeq := Iif (cNumSeqD1 < cNumSeqD2,cNumSeqD1,cNumSeqD2)
cMinSeq := Iif (cNumSeqD3 < cMinSeq,cNumSeqD3,cMinSeq)

Return cMinSeq

/*/{Protheus.doc} CreaSumTerc
Cria e abre tabela para guardar o saldo de terceiros dos produtos
@author reynaldo
@since 15/05/2019
@version 1.0
@return ${return}, ${return_description}
@param cAliSumTer, characters, descricao
@type function
/*/
Static Function CreaSumTerc(cAliSumTer)
Local aCampos
Local nTamCod := TamSX3("B1_COD" )[1]
Local aTamQtd := TamSX3("B2_QATU" )

aCampos := {}
AADD(aCampos,{"FILIAL"		,"C",TamSX3("D1_FILIAL" )[1],0})
AADD(aCampos,{"DT_EST"		,"D",TamSX3("D1_DTDIGIT")[1],0})
AADD(aCampos,{"COD_ITEM"	,"C",nTamCod				,0})
AADD(aCampos,{"QTDFIS"		,"N",aTamQtd[1]			,aTamQtd[2]})
AADD(aCampos,{"QTDVIR"		,"N",aTamQtd[1]			,aTamQtd[2]})

If TcCanOpen(cAliSumTer)
	TcDelFile(cAliSumTer)
EndIf

FwDbCreate(cAliSumTer,aCampos,"TOPCONN",.T.)
DbUseArea(.T.,"TOPCONN",cAliSumTer,cAliSumTer,.T.)
DBCreateIndex(cAliSumTer+'1', 'FILIAL+DT_EST+COD_ITEM', { || 'FILIAL+DT_EST+COD_ITEM' })

Return .T.

/*/{Protheus.doc} ProcSumTerc
Processa o saldo de terceiros para descontar ou n�o do saldo proprio
@author reynaldo
@since 15/05/2019
@version 1.0
@return ${return}, ${return_description}
@param cAliK200, characters, descricao
@param cAliSumTer, characters, descricao
@type function
/*/
Static Function ProcSumTerc(cAliK200,cAliSumTer)
Local cAliasQry
Local cTableTerc
Local cQuery
Local aArea
Local aAreaK200
Local nQtd

aArea := GetArea()
cTableTerc := cAliSumTer
cQuery := ""
cQuery += "SELECT FILIAL,DT_EST,COD_ITEM, QTDFIS ,QTDVIR "
cQuery += "FROM " + cTableTerc + " "
cQuery += "WHERE "
cQuery += " (QTDFIS >0
cQuery += " OR QTDVIR <0)
cQuery += "AND D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY COD_ITEM "
cQuery := ChangeQuery(cQuery)

cAliasQry := CriaTrab(,.F.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

If Select(cAliasQry) >0
	dbSelectArea(cAliK200)
	aAreaK200 := GetArea()
	dbSetOrder(1) // FILIAL+DTOS(DT_EST)+COD_ITEM+IND_EST+COD_PART

	While !(cAliasQry)->(Eof())

		If MsSeek((cAliasQry)->(FILIAL+DT_EST+COD_ITEM+"0"))

			nQtd := 0
			If (cAliasQry)->QTDFIS > 0
				nQtd += (cAliasQry)->QTDFIS
			EndIf
			If (cAliasQry)->QTDVIR < 0
				nQtd -= (cAliasQry)->QTDVIR
			EndIf
		
			If ((cAliK200)->QTD - nQtd) <= 0
				Reclock(cAliK200,.F.)
				DbDelete()
				(cAliK200)->(MsUnLock())
			Else
				Reclock(cAliK200,.F.)
				(cAliK200)->QTD -= nQtd
				(cAliK200)->(MsUnLock())
			EndIf
		EndIf

		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

	RestArea(aAreaK200)
EndIf
RestArea(aArea)

Return

/*/{Protheus.doc} DelTblK200
Deleta todas as tabelas com iniciais k_k200, pois se trata da criacao de uma tabela auxliar para
processamento do registro K200 e que por algum motivo a tabela n�o foi excluida na execucao da rotina
@author reynaldo
@since 10/09/2021
@version 1.0
@param nenhum
@return nenhum
@type function
/*/
Static Function DelTblK200()
Local cQuery     as character
Local cAliasQry  as character
Local cDataName  as character
Local aK200Stru  as array
Local nLoop      as numeric
Local cNameTable as character

cDataName := TCGetDB()
cQuery := ""

Do Case
	Case (cDataName $ "MSSQL/MSSQL7/SYBASE")
		cQuery := "select sysobjects.name name "
		cQuery += " from sysobjects "
		cQuery += " where sysobjects.type = 'U' "
		cQuery += " and (sysobjects.name like 'k_k200%' "
		cQuery += " OR sysobjects.name like 'K_K200%') "

	Case (cDataName == "ORACLE")
		cQuery := "select table_name name "
		cQuery += " from user_tables "
		cQuery += " where table_name like 'k_k200%' "
		cQuery += " OR table_name like 'K_K200%' "

	Case (cDataName == "POSTGRES")
		cQuery := "select table_name as name "
 		cQuery += " from information_schema.tables "
		cQuery += " where table_name like 'k_k200%' "
		cQuery += " OR table_name like 'K_K200%' "

EndCase

If !Empty(cQuery)

	cAliasQry := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), cAliasQry )
	If (cAliasQry)->(!Eof())

		aK200Stru := SPDLayout("K200")

		While (cAliasQry)->(!Eof())

			cNameTable := Alltrim((cAliasQry)->Name)

			If CheckStru(cNameTable,aK200Stru[1])
				TCDelIndex( cNameTable, "")
				TCDelFile( cNameTable )
			EndIf

			(cAliasQry)->(dbSkip())

		EndDo

		For nLoop := 1 To len(aK200Stru)
			aSize(aK200Stru[nLoop],0)
			aK200Stru[nLoop] := NIL
		Next nLoop
		aSize(aK200Stru,0)
		aK200Stru:=NIL

	EndIf

	(cAliasQry)->(dbCloseArea())

EndIf

RETURN


/*/{Protheus.doc} CheckStru
Verifica se a estrutura da tabela K_K200* encontrada � igual a do K200 Padrao, se retornando verdadeiro se ambas forem iguais.
@author reynaldo
@since 10/09/2021
@version 1.0
@param nenhum
@return nenhum
@type function
/*/
Static Function CheckStru(cTmpTable, aStruBase)
Local lIgual    as logical
Local aStruTMP  as array
Local nLoop     as numeric
Local cTmpAlias as character

	cTmpAlias := GetNextAlias()
	DBUseArea(.T., 'TOPCONN', cTmpTable, cTmpAlias, .F., .T.)
	If Select(cTmpAlias) > 0
		aStruTMP := (cTmpAlias)->(dbStruct())

		lIgual := .F.
		If len(aStruTMP)==len(aStruBase)
			lIgual := .T.
			For nLoop := 1 to len(aStruBase)
				If aStruBase[nLoop,1]<>aStruTMP[nLoop,1]
					lIgual := .F.
					Exit
				EndIf
			Next nLoop

		EndIf

		For nLoop := 1 To len(aStruTMP)
			aSize(aStruTMP[nLoop],0)
			aStruTMP[nLoop] := NIL
		Next nLoop
		aSize(aStruTMP,0)
		aStruTMP:=NIL

		(cTmpAlias)->(dbCloseArea())
	EndIf

Return lIgual

/*/{Protheus.doc} GravMetric
Verifica se a estrutura da tabela K_K200* encontrada � igual a do K200 Padrao, se retornando verdadeiro se ambas forem iguais.
@author reynaldo
@since 08/10/2021
@version 1.0
@param nenhum
@return nenhum
@type function
/*/
Static Function GravMetric(aAliProc)
Local lCompleto as logical
Local cSubRotina as character

//????????????????????????????????????????????????????????????????
// Telemetria - Uso da classe FwCustomMetrics                   //
// Metrica - setAverageMetric                                   //
//????????????????????????????????????????????????????????????????
If FWIsInCallStack("SPEDFISCAL") .and. FWLibVersion() >= "20210628"

	// se os elementos selecionados forem verdadeiro, ent�o � a gera��o do bloco K completo, caso contrario � do K200/K280
	lCompleto := .T.
	lCompleto := aAliProc[K210] .and. aAliProc[K220]
	lCompleto := lCompleto .and. aAliProc[K230] .and. aAliProc[K250]
	lCompleto := lCompleto .and. aAliProc[K260] .and. aAliProc[K270]
	lCompleto := lCompleto .and. aAliProc[K290] .and. aAliProc[K300]

	cSubRotina := IIf( lCompleto, "COMPLETA", "K200/K280")

	FWCustomMetrics():setAverageMetric(	cSubRotina /*cSubRoutine*/,;
									"estoque/custos-protheus_bloco-k-sped-fiscal_count" /*cIdMetric*/,;
									1/*nValue*/,;
									/*dDateSend*/,;
									/*nLapTime*/,;
									"MATXSPED"/*cRotina*/)

EndIf

Return

/*/{Protheus.doc} DelTblH010
Deleta todas as tabelas com iniciais h010_ criadas no processamento do bloco H
@author Squad Entradas
@since 16/03/2022
/*/
Function DelTblH010()
Local cQuery	 := ""
Local cAlias	 := ""
Local cDataName  := ""
Local cNameTable := ""

cDataName := TCGetDB()

Do Case
	Case (cDataName $ "MSSQL/MSSQL7/SYBASE")
		cQuery := "select sysobjects.name name "
		cQuery += " from sysobjects "
		cQuery += " where sysobjects.type = 'U' "
		cQuery += " and (sysobjects.name like 'h010_%' "
		cQuery += " OR sysobjects.name like 'H010_%') "

	Case (cDataName == "ORACLE")
		cQuery := "select table_name name "
		cQuery += " from user_tables "
		cQuery += " where table_name like 'h010_%' "
		cQuery += " OR table_name like 'H010_%' "

	Case (cDataName == "POSTGRES")
		cQuery := "select table_name as name "
 		cQuery += " from information_schema.tables "
		cQuery += " where table_name like 'h010_%' "
		cQuery += " OR table_name like 'H010_%' "
EndCase

If !Empty(cQuery)

	cAlias := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias)
	
	If (cAlias)->(!Eof())

		Do While (cAlias)->(!Eof())
			cNameTable := Alltrim((cAlias)->Name)

			If TcCanOpen( cNameTable )
				TCDelIndex( cNameTable,"")
				TCDelFile( cNameTable )
			EndIf

			(cAlias)->(dbSkip())
		EndDo

	EndIf

	(cAlias)->(dbCloseArea())

EndIf

Return
