#INCLUDE "MNTR395.ch"
#include "Protheus.ch"

#DEFINE _nVERSAO 2 //Versao do fonte
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MNTR395  � Autor � Rafael Diogo Richter  � Data �15/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Relatorio de Tipos de Infracoes de Transito                 ���
�������������������������������������������������������������������������Ĵ��
���Tabelas   �TSH - Infracoes de Transito                                 ���
���          �TRX - Multas                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaMNT                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � F.O  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTR395()
	//�����������������������������������������������������������������������Ŀ
	//� Armazena variaveis p/ devolucao (NGRIGHTCLICK) 				  		  �
	//�������������������������������������������������������������������������
	Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)

	Local WNREL      := "MNTR395"
	Local LIMITE     := 132
	Local cDESC1     :=	STR0001+; //"O relat�rio apresentar� a quantidade de infra��es no ano, e a percentagem da participa��o "
	STR0002 //"de cada tipo no total"
	Local cDESC2     := ""
	Local cDESC3     := ""
	Local cSTRING    := "TRX"
	Private cCadastro := OemtoAnsi(STR0003) //"Tipos de Infra��es de Tr�nsito"
	Private cPerg     := "MNR395"
	Private aPerg     := {}
	Private NOMEPROG := "MNTR395"
	Private TAMANHO  := "M"
	Private aRETURN  := {STR0004,1,STR0005,1,2,1,"",1} //"Zebrado"###"Administracao"
	Private TITULO   := STR0003 //"Tipos de Infra��es de Tr�nsito"
	Private nTIPO    := 0
	Private nLASTKEY := 0
	Private CABEC1,CABEC2
	Private aVETINR := {}
	Private lFilial, lHub
	Private lGera := .T.

	Private lEditResp := If(NGCADICBASE("TRX_REPON","A","TRX",.F.),.T.,.F.)
	Private nSizeFil  := If(FindFunction("FWSizeFilial"),FwSizeFilial(),Len(SM0->M0_CODFIL))

	DbSelectarea("SX1")
	DbSetorder(01)
	If !Dbseek(cPerg+"01")
		AAdd(aPerg, {"De Ano             ?","N",04,0,"NaoVazio() .AND. MNR395ANO(1)","","G","","","","","","","�De Ano             ?","From Year          ?"}) //"De Ano             ?"
		AAdd(aPerg, {"Ate Ano            ?","N",04,0,"NaoVazio() .AND. MNR395ANO(2) .And. mv_par02>=mv_par01","","G","","","","","","","�Hasta Ano            ?","To Year            ?"}) //"Ate Ano            ?"
		AAdd(aPerg, {"De Infra��o        ?","C",06,0,"If(Empty(Mv_Par03),.T., ExistCpo('TSH',Mv_Par03))","TSH","G","","","","","","","�De Infraccion        ?","From Violation     ?"}) //"De Infra��o        ?"
		AAdd(aPerg, {"At� Infra��o       ?","C",06,0,"If(atecodigo('TSH',Mv_Par03,Mv_Par04),.T.,.F.)","TSH","G","","","","","","","�Hasta Infraccion       ?","To Violation       ?"}) //"At� Infra��o       ?"
		AAdd(aPerg, {"De Motorista       ?","C",06,0,"MNR395CC(1,mv_par05,mv_par06,'DA4')","DA4","G","","","","","","","�De Conductor       ?","From Driver        ?"})//"De Motorista       ?"
		AAdd(aPerg, {"At� Motorista      ?","C",06,0,"MNR395CC(2,mv_par05,mv_par06,'DA4')","DA4","G","","","","","","","�Hasta Conductor      ?","To Driver          ?"})//"At� Motorista      ?"
		AAdd(aPerg, {"Filial             ?","C",nSizeFil,0,"MNT395FL()","DLB","G","","","","","","","�Sucursal             ?","Branch             ?"})
		AAdd(aPerg, {"Grupo de Filial    ?","C",02,0,"MNT395Gr()","TRW","G","","","","","","","�Grupo de Sucursal    ?","Branch Group       ?"}) //"Grupo de Filial    ?"
		NGchksx1(cperg,aperg)
	Endif                                     

	Pergunte(cPERG,.F.)


	//Envia controle para a funcao SETPRINT 
	WNREL:=SetPrint(cSTRING,WNREL,cPERG,TITULO,cDESC1,cDESC2,cDESC3,.F.,"")
	If nLASTKEY = 27
		Set Filter To
		DbSelectArea("TRX")
		//Devolve variaveis armazenadas (NGRIGHTCLICK)
		NGRETURNPRM(aNGBEGINPRM)
		Return
	EndIf
	SetDefault(aReturn,cSTRING)
	Processa({|lEND| MNTR395IMP(@lEND,WNREL,TITULO,TAMANHO)},STR0011) //"Processando Registros..."
	Dbselectarea("TRX")


	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	NGRETURNPRM(aNGBEGINPRM)

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MNT395IMP | Autor � Rafael Diogo Richter  � Data �15/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Chamada do Relat�rio                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTR395                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTR395IMP(lEND,WNREL,TITULO,TAMANHO)

	Local nAcu := 0, nTotalPago := 0, nTotalValor := 0
	Local oTmpTbl1		    //Tabela Temporaria
	Local oTmpTbl2			//Tabela Temporaria2
	Private li := 80 ,m_pag := 1
	Private cRODATXT := ""
	Private nCNTIMPR := 0
	Private nQtd := 0
	Private cFilAntiga := 'FILTESTE'
	Private nQtdeFil := 0
	Private nTotalPagFil := 0, nTotalValFil := 0
	Private lPrimeiro := .T.
	Private cTRB2	 := GetNextAlias()
	Private cTRB	 := GetNextAlias()

	aDBF :=	{{"MULTA" , "C", 10,0},;
				{"CODHUB", "C", 02,0},;
				{"CODFIL", "C", nSizeFil,0},;
				{"CODINF", "C", 06,0},;
				{"QTD"   , "N", 03,0},;
				{"REPON" , "C", 01,0},;
				{"VALPAG", "N", 12,2},;
				{"VALOR" , "N", 12,2}}	

	//Intancia classe FWTemporaryTable
	oTmpTbl1  := FWTemporaryTable():New( cTRB, aDBF )	
    //Cria indices
	oTmpTbl1:AddIndex( "Ind01" , {"CODFIL","CODINF"})
	oTmpTbl1:AddIndex( "Ind02" , {"CODFIL","MULTA"} )
	//Cria a tabela temporaria
	oTmpTbl1:Create()
				
	aDBF2 :=	{{"FILIAL", "C", nSizeFil,0},;
				 {"QTDFIL", "N", 03,0}}

	oTmpTbl2  := FWTemporaryTable():New( cTRB2, aDBF2 )
    //Cria indices
	oTmpTbl2:AddIndex( "Ind01" , {"FILIAL"} )
	//Cria a tabela temporaria
	oTmpTbl2:Create()

	MsgRun(OemToAnsi(STR0013),OemToAnsi(STR0014),{|| MNTR395TMP()}) //"Processando Arquivo..."###"Aguarde"

	If !lGera
		oTmpTbl1:Delete()
		oTmpTbl2:Delete()
		Return .F.
	Endif

	/* 
	0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7
	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
	****************************************************************************************************************************************************************************
	Tipos de Infra��es de Tr�nsito         Qtde.   Valor Infra��o  Valor Pago         %   %Ac.
	***************************************************************************************************************************************************************************
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx      999   999,999,999.99 	999,999,999.99  999%   999%
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx      999   999,999,999.99 	999,999,999.99  999%   999%
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx      999   999,999,999.99  999,999,999.99  999%   999%
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx      999   999,999,999.99  999,999,999.99  999%   999%
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx      999   999,999,999.99  999,999,999.99  999%   999%

	Total     9999   999,999,999.99	999,999,999.99  999%   999%
	/*/

	Cabec1 := STR0015 //"Tipos de Infra��es de Tr�nsito         Qtde.   Valor Infra��o       %   %Ac."
	Cabec2 := ""

	dbSelectArea(cTRB)
	dbSetOrder(1)
	dbGoTop()
	ProcRegua(Reccount())
	While !Eof()
		IncProc()
		NgSomaLi(58)
		If	lHub .OR. Empty(MV_PAR07)
			If (cTRB)->CODFIL != cFilAntiga
				If !lPrimeiro
					NgSomaLi(58)
					@ Li,044		Psay STR0029 //"Total da Filial"
					@ Li,065		Psay nQtdeFil  Picture "@R 999"
					@ Li,075		Psay nTotalValFil Picture "@E 999,999,999.99"
					@ Li,095		Psay nTotalPagFil Picture "@E 999,999,999.99"
					@ Li,115		Psay "100%"
					NgSomaLi(58)
					nQtdeFil := 0
					nTotalValFil := 0
					nTotalPagFil := 0
					nAcu := 0
				Endif
				lPrimeiro := .f.
				DbSelectArea("SM0")
				SM0->(DbSetOrder(1))	
				If MsSeek(SM0->M0_CODIGO+(cTRB)->CODFIL)
					NgSomaLi(58)
					@ Li,000		Psay  SM0->M0_CODFIL + ' - ' + SM0->M0_FILIAL
					NgSomaLi(58)
					NgSomaLi(58)			
				EndIf
				cFilAntiga := (cTRB)->CODFIL
			Endif
		Endif
		dbSelectArea("TSH")
		dbSetOrder(1)
		dbSeek(xFilial("TSH")+(cTRB)->CODINF)
		@ Li,000		Psay SubStr(TSH->TSH_DESART,1,60)
		@ Li,065		Psay (cTRB)->QTD		Picture "@R 999"
		@ Li,075		Psay (cTRB)->VALOR  	Picture "@E 999,999,999.99"
		@ Li,095		Psay (cTRB)->VALPAG	Picture "@E 999,999,999.99"
		If lHub .OR. Empty(MV_PAR07)
			dbSelectArea(cTRB2)
			dbSetOrder(01)
			dbSeek((cTRB)->CODFIL)
			@ Li,115		Psay PADL(Transform(((cTRB)->QTD*100)/(cTRB2)->QTDFIL,"@R 999"),3)+"%"
			nAcu += ((cTRB)->QTD*100)/(cTRB2)->QTDFIL
		Else
			nAcu += ((cTRB)->QTD*100)/nQtd
			@ Li,115		Psay PADL(Transform(((cTRB)->QTD*100)/nQtd,"@R 999"),3)+"%"	
		Endif
		nTotalValor += (cTRB)->VALOR
		nTotalPago += (cTRB)->VALPAG
		@ Li,125		Psay PADL(Transform(nAcu,"@R 999"),3)+"%"

		nQtdeFil += (cTRB)->QTD
		nTotalValFil += (cTRB)->VALOR
		nTotalPagFil += (cTRB)->VALPAG
		dbSelectArea(cTRB)
		dbSkip()
	End
	If lHub .OR. Empty(MV_PAR07)
		NgSomaLi(58)
		NgSomaLi(58)
		@ Li,044		Psay STR0029 //"Total da Filial"
		@ Li,065		Psay nQtdeFil  Picture "@R 999"
		@ Li,075		Psay nTotalValFil Picture "@E 999,999,999.99"
		@ Li,095		Psay nTotalPagFil Picture "@E 999,999,999.99"
		@ Li,115		Psay "100%"
	Endif
	NgSomaLi(58)
	NgSomaLi(58)
	@ Li,054		Psay STR0016 //"Total"
	@ Li,065		Psay nQtd		 Picture "@R 999"
	@ Li,075		Psay nTotalValor Picture "@E 999,999,999.99"
	@ Li,095		Psay nTotalPago Picture "@E 999,999,999.99"
	@ Li,115		Psay PADL(Transform((nQtd*100)/nQtd,"@R 999"),3)+"%"

	oTmpTbl1:Delete()
	oTmpTbl2:Delete()
	
	RODA(nCNTIMPR,cRODATXT,TAMANHO)


	//Devolve a condicao original do arquivo principal

	RetIndex("TRX")
	Set Filter To
	Set Device To Screen
	If aReturn[5] == 1
		Set Printer To
		dbCommitAll()
		OurSpool(WNREL)
	EndIf
	MS_FLUSH()

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MNTR395TMP| Autor � Rafael Diogo Richter  � Data �15/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Geracao do arquivo temporario                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTR395                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTR395TMP()
	Local cAliasQry := ""
	Local _cGetDB := TcGetDb()

	nQtd := 0
	If Empty(Mv_Par07) .And. !Empty(Mv_Par08)
		lFilial := .F.
		lHub := .T.
	ElseIf Empty(Mv_Par08) .And. !Empty(Mv_Par07)
		lFilial := .T.
		lHub := .F.
	ElseIf Empty(Mv_Par07) .And. Empty(Mv_Par08)
		lFilial := .F.
		lHub := .F.
	EndIf

	cAliasQry := "TETRX"

	If (lFilial == .T. .And. lHub == .F.) .Or. (lFilial == .F. .And. lHub == .F.)

		cQuery := "	SELECT TRX_FILIAL, TRX_MULTA, TRX_CODINF, TRX_MULTA, TRX_INFRAC, TRX_VALPAG, TRX_VALOR "
		If lEditResp
			cQuery += " , TRX_REPON "
		EndIf
		cQuery += " FROM " + RetSQLName("TRX") + " TRX "
		cQuery += "	WHERE TRX.D_E_L_E_T_ <> '*' "
		If !Empty(MV_PAR07)
			cQuery += "	AND TRX.TRX_FILIAL = '"+MV_PAR07+"'"
		Endif
		If Upper(_cGetDB) == "ORACLE"
			cQuery += "	AND SubStr(TRX.TRX_DTINFR,1,4) BETWEEN '"+AllTrim(Str(mv_par01))+"' AND '"+AllTrim(Str(mv_par02))+"'"
		Else 
			cQuery += "	AND SubString(TRX.TRX_DTINFR,1,4) BETWEEN '"+AllTrim(Str(mv_par01))+"' AND '"+AllTrim(Str(mv_par02))+"'"
		EndIf
		cQuery += "	AND TRX.TRX_CODMO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"
		cQuery += "	AND TRX.TRX_CODINF BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"
		cQuery += "	ORDER BY TRX.TRX_FILIAL, TRX.TRX_MULTA, TRX.TRX_CODINF "

		cQuery := ChangeQuery(cQuery)

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

		dbSelectArea(cAliasQry)
		dbGoTop()

		If Eof()
			MsgInfo(STR0017,STR0018) //"N�o existem dados para montar o relat�rio!"###"ATEN��O"
			(cAliasQry)->(dbCloseArea())
			lGera := .f.
			Return
		Endif

		While (cAliasQry)->( !Eof() )
			dbSelectArea(cTRB)
			dbSetOrder(1)
			If !dbSeek((cAliasQry)->TRX_FILIAL+(cAliasQry)->TRX_CODINF)
				RecLock((cTRB), .T.)
				(cTRB)->MULTA	:= (cAliasQry)->TRX_MULTA
				(cTRB)->CODFIL	:= (cAliasQry)->TRX_FILIAL
				(cTRB)->CODINF	:= (cAliasQry)->TRX_CODINF
			Else
				RecLock((cTRB), .F.)
			EndIf
			(cTRB)->VALPAG += (cAliasQry)->TRX_VALPAG
			(cTRB)->VALOR += (cAliasQry)->TRX_VALOR		
			If lEditResp
				(cTRB)->REPON := MNT395RESP((cAliasQry)->TRX_REPON)
			Else
				(cTRB)->REPON := MNT395RESP((cAliasQry)->TRX_CODINF)
			EndIf
			(cTRB)->QTD += 1
			nQtd++
			MsUnLock(cTRB)
			dbSelectArea(cTRB2)
			dbSetOrder(1)
			If !dbSeek((cAliasQry)->TRX_FILIAL)
				RecLock((cTRB2), .T.)
				(cTRB2)->FILIAL := (cAliasQry)->TRX_FILIAL
				(cTRB2)->QTDFIL := 1
			Else
				RecLock((cTRB2), .F.)
				(cTRB2)->QTDFIL += 1
			Endif
			MsUnLock(cTRB2)
			(cAliasQry)->(dbSkip())
		End
	ElseIf lFilial == .F. .And. lHub == .T.

		cQuery := "	SELECT TSL_HUB, TRX_FILIAL, TRX_MULTA, TRX_CODINF, TRX_MULTA, TRX_INFRAC, TRX_VALPAG, TRX_VALOR "
		If lEditResp
			cQuery += " , TRX_REPON "
		EndIf
		cQuery += "	FROM " + RetSQLName("TRX") + " TRX "
		cQuery += "	JOIN " + RetSQLName("TSL") + " TSL ON TSL.TSL_FILMS = TRX.TRX_FILIAL "
		cQuery += "	AND TSL.TSL_HUB = '"+MV_PAR08+"'"
		cQuery += "	AND TSL.D_E_L_E_T_ <> '*' "
		cQuery += "	WHERE TRX.TRX_FILIAL = TSL.TSL_FILMS "
		If Upper(_cGetDB) == "ORACLE"
			cQuery += "	AND SubStr(TRX.TRX_DTINFR,1,4) BETWEEN '"+AllTrim(Str(mv_par01))+"' AND '"+AllTrim(Str(mv_par02))+"'"
		Else 
			cQuery += "	AND SubString(TRX.TRX_DTINFR,1,4) BETWEEN '"+AllTrim(Str(mv_par01))+"' AND '"+AllTrim(Str(mv_par02))+"'"
		EndIf
		cQuery += "	AND TRX.TRX_CODMO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"	
		cQuery += "	AND TRX.TRX_CODINF BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"
		cQuery += "	AND TRX.D_E_L_E_T_ <> '*' "
		cQuery += "	ORDER BY TSL.TSL_HUB, TRX.TRX_FILIAL, TRX.TRX_MULTA, TRX.TRX_CODINF "

		cQuery := ChangeQuery(cQuery)

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

		dbSelectArea(cAliasQry)
		dbGoTop()

		If Eof()
			MsgInfo(STR0017,STR0018) //"N�o existem dados para montar o relat�rio!"###"ATEN��O"
			(cAliasQry)->(dbCloseArea())  
			lGera := .f.
			Return
		Endif

		While (cAliasQry)->( !Eof() )
			dbSelectArea(cTRB)
			dbSetOrder(1)
			If !dbSeek((cAliasQry)->TRX_FILIAL+(cAliasQry)->TRX_CODINF)
				RecLock((cTRB), .T.)
				(cTRB)->MULTA	:= (cAliasQry)->TRX_MULTA
				(cTRB)->CODHUB	:= (cAliasQry)->TSL_HUB
				(cTRB)->CODFIL	:= (cAliasQry)->TRX_FILIAL
				(cTRB)->CODINF	:= (cAliasQry)->TRX_CODINF
			Else
				RecLock((cTRB), .F.)
			EndIf
			(cTRB)->VALPAG += (cAliasQry)->TRX_VALPAG
			(cTRB)->VALOR += (cAliasQry)->TRX_VALOR
			If lEditResp
				(cTRB)->REPON := MNT395RESP((cAliasQry)->TRX_REPON)
			Else
				(cTRB)->REPON := MNT395RESP((cAliasQry)->TRX_CODINF)
			EndIf
			(cTRB)->QTD += 1
			nQtd++
			MsUnLock(cTRB)
			dbSelectArea(cTRB2)
			dbSetOrder(1)
			If !dbSeek((cAliasQry)->TRX_FILIAL)
				RecLock((cTRB2), .T.)
				(cTRB2)->FILIAL := (cAliasQry)->TRX_FILIAL
				(cTRB2)->QTDFIL := 1
			Else
				RecLock((cTRB2), .F.)
				(cTRB2)->QTDFIL += 1
			Endif
			MsUnLock(cTRB2)
			(cAliasQry)->(dbSkip())
		End
	EndIf

	(cAliasQry)->(dbCloseArea())

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNT395FL  � Autor �Rafael Diogo Richter   � Data �15/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida o parametro filial                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTR395                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MNT395FL()
	Local lRet

	lRet := IIf(Empty(Mv_Par07),.T.,ExistCpo('SM0',SM0->M0_CODIGO+Mv_Par07))
	If !lRet
		Return .F.
	EndIf
	If !Empty(Mv_Par07)
		Mv_Par08 := "  "
	EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNT395Gr  � Autor �Rafael Diogo Richter   � Data �15/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida o parametro Grupo                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTR395                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MNT395Gr()
	Local lRet := .t.

	If Empty(Mv_Par08) .And. !Empty(Mv_Par07)
		lRet := .T.
	Elseif !Empty(Mv_Par08)
		lRet := ExistCpo('TRW',Mv_Par08)
	EndIf
	If !lRet
		Return .F.
	EndIf
	If !Empty(Mv_Par08)
		Mv_Par07 := "  "
	EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNT395RESP� Autor �Marcos Wagner Junior   � Data �30/08/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida o parametro Grupo                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTR395                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MNT395RESP(cCodInfra)

	Local cRespon := NGSEEK('TSH',cCodInfra,1,'TSH_RESPON')
	Local cDescricao := ''

	If cRespon = '1'
		cDescricao := STR0020 //"Motorista"
	Elseif cRespon = '2'
		cDescricao := STR0021 //"Empresa"
	Elseif cRespon = '3'
		cDescricao := STR0022 //"Pessoa Fisica"
	Elseif cRespon = '4'
		cDescricao := STR0023 //"Pessoa Juridica e fisica"
	Elseif cRespon = '5'
		cDescricao := STR0024 //"Seguradora"
	Elseif cRespon = '6'
		cDescricao := STR0025 //"Transportador"
	Elseif cRespon = '7'
		cDescricao := STR0026 //"Expedidor"		
	Endif

Return cDescricao

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MNR395CC  | Autor �Marcos Wagner Junior   � Data � 12/09/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o |Valida os codigos De/Ate Motorista		                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTR395                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MNR395CC(nOpc,cParDe,cParAte,cTabela)  

	If (Empty(cParDe) .AND. cParAte = 'ZZZZZZ')
		Return .t.
	Else
		If nOpc == 1
			If Empty(cParDe)
				Return .t.
			Else		
				lRet := IIf(Empty(cParDe),.t.,ExistCpo(cTabela,cParDe))
				If !lRet
					Return .f.
				EndIf 
			Endif 
		ElseIf nOpc == 2      
			If (cParAte == 'ZZZZZZ') 
				Return .t.
			Else
				lRet := IIF(ATECODIGO(cTabela,cParDe,cParAte,08),.T.,.F.)
				If !lRet 
					Return .f.
				EndIf  
			EndIf
		EndIf    
	Endif

Return .t.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MNR395ANO | Autor �Marcos Wagner Junior   � Data � 22/10/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o |Valida o ano digitado no grupo de perguntas                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTR395                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MNR395ANO(nPar)

	cAno := AllTrim(Str(IF(nPar==1,MV_PAR01,MV_PAR02)))
	If Len(cAno) != 4
		MsgStop(STR0031,STR0018) //"O Ano informado dever� conter 4 d�gitos!"###"ATEN��O"
		Return .f.
	Endif
	If (nPar = 1 .AND. MV_PAR01 > Year(dDATABASE)) .OR. (nPar = 2 .AND. MV_PAR02 > Year(dDATABASE))
		MsgStop(STR0030+AllTrim(Str(Year(dDATABASE)))+'!',STR0018) //"Ano informado n�o poder� ser maior que "###"ATEN��O"
		Return .f.
	Endif

Return .t.