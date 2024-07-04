#INCLUDE "MNTR400.ch"
#include "Protheus.ch"

#DEFINE _nVERSAO 3 //Versao do fonte
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MNTR400  � Autor � Rafael Diogo Richter  � Data �14/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Relatorio de Multas por Responsabilidade                    ���
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
Function MNTR400()

	//�����������������������������������������������������������������������Ŀ
	//� Armazena variaveis p/ devolucao (NGRIGHTCLICK) 				  		  �
	//�������������������������������������������������������������������������
	Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)

	Local WNREL      := "MNTR400"
	Local LIMITE     := 220
	Local cDESC1     := STR0001 //"O relat�rio apresentar� as Multas por Responsabilidade"
	Local cDESC2     := ""
	Local cDESC3     := ""
	Local cSTRING    := "TRX"
	Private cCadastro := OemtoAnsi(STR0002) //"Multas por Responsabilidade"
	Private cPerg     := "MNR400"
	Private aPerg     := {}
	Private NOMEPROG := "MNTR400"
	Private TAMANHO  := "G"
	Private aRETURN  := {STR0003,1,STR0004,1,2,1,"",1} //"Zebrado"###"Administracao"
	Private TITULO   := STR0002 //"Multas por Responsabilidade"
	Private nTIPO    := 0
	Private nLASTKEY := 0
	Private CABEC1,CABEC2
	Private aVETINR := {}
	Private lFilial, lHub
	Private lGera := .t.

	Private lEditResp := If(NGCADICBASE("TRX_REPON","A","TRX",.F.),.T.,.F.)
	Private nSizeFil  := If(FindFunction("FWSizeFilial"),FwSizeFilial(),Len(SM0->M0_CODFIL))

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
	Processa({|lEND| MNTR400IMP(@lEND,WNREL,TITULO,TAMANHO)},STR0011) //"Processando Registros..."
	Dbselectarea("TRX")

	//� Devolve variaveis armazenadas (NGRIGHTCLICK)    
	NGRETURNPRM(aNGBEGINPRM)

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MNT400IMP | Autor � Rafael Diogo Richter  � Data �14/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Chamada do Relat�rio                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTR400                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTR400IMP(lEND,WNREL,TITULO,TAMANHO)

	Local i
	Local cHub := " "
	Local cFil := " " 
	Local oTempTable  //Tabela Temporaria
	
	Private li := 80 ,m_pag := 1
	Private cRODATXT := ""
	Private nCNTIMPR := 0
	Private nQtd1:= 0,nQtd2:= 0,nQtd3:= 0,nQtd4:= 0,nQtd5:= 0,nQtd6:= 0,nQtd7:= 0
	Private nVal1:= 0,nVal2:= 0,nVal3:= 0,nVal4:= 0,nVal5:= 0,nVal6:= 0,nVal7:= 0, nQtdTot := 0
	Private cTRB	 := GetNextAlias() //Tabela Temporaria

	aDBF :=	{{"MULTA" , "C", 10,0},;
			 {"CODHUB", "C", 02,0},;
			 {"CODFIL", "C", nSizeFil,0},;
			 {"CODINF", "C", 06,0},;
			 {"QTD1",   "N", 03,0},;
			 {"VAL1",   "N", 10,2},;        	 
			 {"QTD2",   "N", 03,0},;
			 {"VAL2",   "N", 10,2},;
			 {"QTD3",   "N", 03,0},;
			 {"VAL3",   "N", 10,2},;        	 
			 {"QTD4",   "N", 03,0},;
			 {"VAL4",   "N", 10,2},;        	 
			 {"QTD5",   "N", 03,0},;
			 {"VAL5",   "N", 10,2},;        	 
			 {"QTD6",   "N", 03,0},;
			 {"VAL6",   "N", 10,2},;        	 
			 {"QTD7",   "N", 03,0},;
			 {"VAL7",   "N", 10,2},;        	         	 
			 {"RESP",   "C", 35,0}}

	//Intancia classe FWTemporaryTable
	oTempTable  := FWTemporaryTable():New( cTRB, aDBF )
    //Cria indices
	oTempTable:AddIndex( "Ind01" , {"CODFIL","CODINF"})
	oTempTable:AddIndex( "Ind02" , {"CODFIL","MULTA"} )
	//Cria a tabela temporaria
	oTempTable:Create()



	MsgRun(OemToAnsi(STR0013),OemToAnsi(STR0014),{|| MNTR400TMP()}) //"Processando Arquivo..."###"Aguarde"

	If !lGera 
		oTempTable:Delete()//Deleta Arquivo temporario
		Return .F.
	Endif

	/* 
	0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	*****************************************************************************************************************************************************************************************************************************
	Responsabilidade                    |   Motorista             |   Empresa               |   Pessoa Fisica         |   P.Juridica e fisica   |   Seguradora            |   Transportador         |   Expedidor
	Tipos de Infra��es de Tr�nsito      |Qtd.  Val.Infra��o     % |Qtd.  Val.Infra��o     % |Qtd.  Val.Infra��o     % |Qtd.  Val.Infra��o     % |Qtd.  Val.Infra��o     % |Qtd.  Val.Infra��o     % |Qtd.  Val.Infra��o     %
	*****************************************************************************************************************************************************************************************************************************
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   999  9,999,999.99  999%   999  9,999,999.99  999%   999  9,999,999.99  999%   999  9,999,999.99  999%   999  9,999,999.99  999%   999  9,999,999.99  999%   999  9,999,999.99  999% 
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   999  9,999,999.99  999%   999  9,999,999.99  999%   999  9,999,999.99  999%   999  9,999,999.99  999%   999  9,999,999.99  999%   999  9,999,999.99  999%   999  9,999,999.99  999% 
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   999  9,999,999.99  999%   999  9,999,999.99  999%   999  9,999,999.99  999%   999  9,999,999.99  999%   999  9,999,999.99  999%   999  9,999,999.99  999%   999  9,999,999.99  999% 
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   999  9,999,999.99  999%   999  9,999,999.99  999%   999  9,999,999.99  999%   999  9,999,999.99  999%   999  9,999,999.99  999%   999  9,999,999.99  999%   999  9,999,999.99  999% 
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   999  9,999,999.99  999%   999  9,999,999.99  999%   999  9,999,999.99  999%   999  9,999,999.99  999%   999  9,999,999.99  999%   999  9,999,999.99  999%   999  9,999,999.99  999% 

	Total   999  9,999,999.99  999%    999  9,999,999.99 999%	 
	/*/

	Cabec1 := STR0019  //"Responsabilidade                    |   Motorista             |   Empresa               |   Pessoa Fisica         |   P.Juridica e fisica   |   Seguradora            |   Transportador         |   Expedidor"
	Cabec2 := STR0020 //"Tipos de Infra��es de Tr�nsito      |Qtd.  Val.Infra��o     % |Qtd.  Val.Infra��o     % |Qtd.  Val.Infra��o     % |Qtd.  Val.Infra��o     % |Qtd.  Val.Infra��o     % |Qtd.  Val.Infra��o     % |Qtd.  Val.Infra��o     %"

	nQtdTot := nQtd1+nQtd2+nQtd3+nQtd4+nQtd5+nQtd6+nQtd7

	dbSelectArea(cTRB)
	dbSetOrder(1)
	dbGoTop()
	ProcRegua(Reccount())
	While !Eof()
		IncProc()

		NgSomaLi(58)
		If lHub
			If cHub <> (cTRB)->CODHUB
				cHub := (cTRB)->CODHUB
				@ Li,000		Psay STR0021+(cTRB)->CODHUB+" - "+NGSEEK('TRW',(cTRB)->CODHUB,1,'TRW_DESHUB')    Picture "@!" //"Grupo de Filiais : "
				NgSomaLi(58)
			EndIf
		EndIf
		If cFil <> (cTRB)->CODFIL    
			DbSelectArea("SM0")
			SM0->(DbSetOrder(1))
			MsSeek(cEMPANT+(cTRB)->CODFIL)
			cFIL := (cTRB)->CODFIL
			@ Li,000		Psay STR0022+(cTRB)->CODFIL+" - "+SM0->M0_FILIAL Picture "@!" //"Filial.: "
			NgSomaLi(58)
		EndIf		
		nQ := 38
		nV := 43
		nT := 57
		@ Li,000		Psay (cTRB)->RESP       Picture "@!"
		For i:= 1 to 7
			@ Li,nQ		Psay &('(cTRB)->QTD'+AllTrim(Str(i)))		Picture "@R 999"
			@ Li,nV		Psay &('(cTRB)->VAL'+AllTrim(Str(i)))		Picture "@E 9,999,999.99"
			@ Li,nT		Psay PADL(Transform((&('(cTRB)->QTD'+AllTrim(Str(i)))*100)/&('nQTD'+AllTrim(Str(i))),"@R 999"),3)+"%"
			nQ += 26
			nV += 26
			nT += 26
		Next i 
		nVal1 += (cTRB)->VAL1
		nVal2 += (cTRB)->VAL2
		nVal3 += (cTRB)->VAL3
		nVal4 += (cTRB)->VAL4
		nVal5 += (cTRB)->VAL5
		nVal6 += (cTRB)->VAL6
		nVal7 += (cTRB)->VAL7 
		dbSelectArea(cTRB)
		dbSkip() 
		If !Eof() .AND. cFil <> (cTRB)->CODFIL
			NgSomaLi(58)
		EndIf

		If lHub
			If !Eof() .AND. cHub <> (cTRB)->CODHUB
				NgSomaLi(58)
			EndIf
		EndIf
	End
	nQ := 38
	nV := 43
	nT := 57
	NgSomaLi(58)
	NgSomaLi(58)
	@ Li,030		Psay STR0016 //"Total"          
	For i:= 1 to 7
		@ Li,nQ	Psay &('nQTD'+AllTrim(Str(i)))	 		Picture "@R 999"
		@ Li,nV	Psay &('nVal'+AllTrim(Str(i))) 			Picture "@E 9,999,999.99"
		@ Li,nT	Psay PADL(Transform((&('nQTD'+AllTrim(Str(i)))*100)/&('nQTD'+AllTrim(Str(i))),"@R 999"),3)+"%"
		nQ += 26
		nV += 26
		nT += 26
	Next i

	nT := 38
	NgSomaLi(58)
	@ Li,032		Psay "%"        
	For i:= 1 to 7
		@ Li,nT		Psay PADL(Transform((&('nQTD'+AllTrim(Str(i)))*100)/nQtdTot,"@R 999"),3)+"%"
		nT += 26
	Next i     

	oTempTable:Delete()//Deleta arquivo temporaria

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
���Fun��o    |MNTR400TMP| Autor � Rafael Diogo Richter  � Data �14/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Geracao do arquivo temporario                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTR400                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTR400TMP()
	Local cAliasQry := "" 
	//Local _cGetDB := TcGetDb()
	Local cCompara  := ""

	nQtd1 := 0
	nQtd2 := 0
	nQtd3 := 0
	nQtd4 := 0
	nQtd5 := 0
	nQtd6 := 0
	nQtd7 := 0

	If Empty(Mv_Par05) .And. !Empty(Mv_Par06)
		lFilial := .F.
		lHub := .T.
	ElseIf Empty(Mv_Par06) .And. !Empty(Mv_Par05)
		lFilial := .T.
		lHub := .F.
	ElseIf Empty(Mv_Par05) .And. Empty(Mv_Par06)
		lFilial := .F.
		lHub := .F.
	EndIf

	cAliasQry := "TETRX"

	cQuery := "	SELECT TRX.TRX_FILIAL,TRX.TRX_MULTA,TRX.TRX_CODINF,TRX.TRX_MULTA,TRX.TRX_INFRAC,TRX.TRX_VALPAG,TSH.TSH_RESPON,TSH.TSH_DESART "
	If lHub
		cQuery += "	,TSL.TSL_HUB "
	EndIf
	If lEditResp
		cQuery += "	, TRX.TRX_REPON "
	EndIf
	cQuery += "	FROM " + RetSQLName("TRX") + " TRX,"+RetSQLName("TSH") + " TSH"
	If lHub
		cQuery += "	,"+RetSQLName("TSL") + " TSL "
	EndIf
	If (!lFilial .And. lHub) 
		cQuery += "	WHERE TSL.TSL_HUB = '"+MV_PAR06+"' AND "
	ElseIf (lFilial .And. !lHub)
		cQuery += "	WHERE "  
		cQuery += NGMODCOMP("TRX","TRX",,MV_PAR05)  + " AND "    
	ElseIf (!lFilial .And. !lHub)
		cQuery += "	WHERE "	
	EndIf
	cQuery += "	TRX.TRX_DTINFR BETWEEN '"+AllTrim(Str(mv_par01))+"0101' AND '"+AllTrim(Str(mv_par02))+"1231'"
	cQuery += "	AND TRX.TRX_CODINF BETWEEN '"+Mv_Par03+"' AND '"+Mv_Par04+"'"   
	cQuery += " AND TSH.TSH_CODINF = TRX.TRX_CODINF AND "   
	If lHub
		cQuery += NGMODCOMP("TSL","TRX") + " AND "
	EndIf
	cQuery += "	TRX.D_E_L_E_T_ <> '*' AND TSH.D_E_L_E_T_ <> '*' "
	cQuery += "	ORDER BY "
	If lHub
		cQuery += "	TSL.TSL_HUB,"
	EndIf
	cQuery += "	TRX.TRX_FILIAL, TRX.TRX_MULTA, TRX.TRX_CODINF "

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
			If lHub
				(cTRB)->CODHUB	:= (cAliasQry)->TSL_HUB
			EndIf
			(cTRB)->MULTA	:= (cAliasQry)->TRX_MULTA
			(cTRB)->CODFIL	:= (cAliasQry)->TRX_FILIAL
			(cTRB)->CODINF	:= (cAliasQry)->TRX_CODINF
		Else
			RecLock((cTRB), .F.)
		EndIf
		(cTRB)->RESP := SubStr((cAliasQry)->TSH_DESART,1,35) //MNT395RESP((cAliasQry)->TSH_CODINF)
		cCompara := (cAliasQry)->TSH_RESPON
		If lEditResp
			If cCompara <> (cAliasQry)->TRX_REPON
				cCompara := (cAliasQry)->TRX_REPON
			EndIf
		EndIf

		If cCompara == "1"
			(cTRB)->QTD1 += 1
			(cTRB)->VAL1 += (cAliasQry)->TRX_VALPAG			
			nQtd1++			
		ElseIf cCompara == "2"
			(cTRB)->QTD2 += 1
			(cTRB)->VAL2 += (cAliasQry)->TRX_VALPAG			
			nQtd2++	
		ElseIf cCompara == "3"
			(cTRB)->QTD3 += 1
			(cTRB)->VAL3 += (cAliasQry)->TRX_VALPAG			
			nQtd3++
		ElseIf cCompara == "4"
			(cTRB)->QTD4 += 1
			(cTRB)->VAL4 += (cAliasQry)->TRX_VALPAG			
			nQtd4++
		ElseIf cCompara == "5"
			(cTRB)->QTD5 += 1
			(cTRB)->VAL5 += (cAliasQry)->TRX_VALPAG			
			nQtd5++
		ElseIf cCompara == "6"
			(cTRB)->QTD6 += 1
			(cTRB)->VAL6 += (cAliasQry)->TRX_VALPAG			
			nQtd6++
		ElseIf cCompara == "7"
			(cTRB)->QTD7 += 1
			(cTRB)->VAL7 += (cAliasQry)->TRX_VALPAG			
			nQtd7++					
		EndIf
		MsUnLock(cTRB)
		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())

Return .T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNT400FL  � Autor �Rafael Diogo Richter   � Data �14/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida o parametro filial                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTR400                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MNT400FL()
	Local lRet

	lRet := IIf(Empty(Mv_Par05),.T.,ExistCpo('SM0',SM0->M0_CODIGO+Mv_Par05))
	If !lRet
		Return .F.
	EndIf
	If !Empty(Mv_Par05)
		Mv_Par06 := "  "
	EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNT400Gr  � Autor �Rafael Diogo Richter   � Data �14/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida o parametro Grupo                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTR400                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MNT400Gr()
	Local lRet

	If Empty(Mv_Par06) .And. Empty(Mv_Par05)
		lRet := .T.
	ElseIf Empty(Mv_Par06) .And. !Empty(Mv_Par05)
		lRet := .T.
	Else
		lRet := ExistCpo('TRW',Mv_Par06)
	EndIf
	If !lRet
		Return .F.
	EndIf
	If !Empty(Mv_Par06)
		Mv_Par05 := "  "
	EndIf

Return .T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MNR400ANO | Autor �Evaldo Cevinscki Jr.   � Data � 23/10/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o |Valida o ano digitado no grupo de perguntas                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTR400                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MNR400ANO(nPar)

	cAno := AllTrim(Str(IF(nPar==1,MV_PAR01,MV_PAR02)))
	If Len(cAno) != 4
		MsgStop(STR0025,STR0018) //"O Ano informado dever� conter 4 d�gitos!"###"ATEN��O"
		Return .F.
	Endif
	If (nPar = 1 .AND. MV_PAR01 > Year(dDATABASE)) .OR. (nPar = 2 .AND. MV_PAR02 > Year(dDATABASE))
		MsgStop(STR0023+AllTrim(Str(Year(dDATABASE)))+'!',STR0018)  //"Ano informado n�o poder� ser maior que "###"ATEN��O"
		Return .F.
	Endif   
	If nPar = 2 .And. MV_PAR02 < MV_PAR01
		MsgStop(STR0024,STR0018)  //"Par�metro At� Ano n�o pode ser menor que De Ano!"###"ATEN��O"
		Return .F.
	Endif   

Return .T.