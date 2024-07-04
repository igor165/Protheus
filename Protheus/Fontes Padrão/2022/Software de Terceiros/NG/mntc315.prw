#INCLUDE "MNTC315.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "COLORS.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTC315
Consulta de Multas de Transito.

@author  Rafael Diogo Richter
@since	 15/03/2007
@version P11/P12
/*/
//------------------------------------------------------------------------------
Function MNTC315()

	//+------------------------------------------------------------------------
	//| Armazena variaveis p/ devolucao (NGRIGHTCLICK) 				  		  |
	//+------------------------------------------------------------------------
	Local aNGBEGINPRM := {}
	Local oTmpTbl1 //Objeto Tabela Tempor�ria 1
	Local aPesq := {}

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 95 )

		aNGBEGINPRM := NGBEGINPRM()

		Private nSizeFil	:= If(FindFunction("FWSizeFilial"),FwSizeFilial(),Len(TRX->TRX_FILIAL))
		Private aRotina		:= MenuDef()
		Private cTRB		:= GetNextAlias()
		Private cCadastro	:= OemtoAnsi(STR0006) //"Consulta/Relat�rio de Multas de Tr�nsito"
		Private cPerg		:= PadR( "MNC315", Len(Posicione("SX1", 1, "MNC315", "X1_GRUPO")) )
		Private aDbf		:= {}
		Private cSim		:= "1", cNao := "2", cPen := "1", cDef := "2"
		Private lIntFin		:= ( SuperGetMV("MV_NGMNTFI", .F., "N") == "S" )
		Private nOpcaTRX
		Private nOldPAR05
		Private nOldPAR06

		MNTA765VAR() // Declara vari�veis de Multas

		nOldPAR06 := MV_PAR06
		nOldPAR07 := MV_PAR07

		aDBF :=	{{"FILIAL"	, "C", nSizeFil,0,"@!"},;
				{"MULTA"	, "C", 09,0,"@!"},;
				{"CODINF"	, "C", 06,0,"@!"},;
				{"CODMO"	, "C", 06,0,"@!"},;
				{"DTREC"	, "D", 08,0,"99/99/9999"},;
				{"DTINFR"	, "D", 08,0,"99/99/9999"},;
				{"RHINFR"	, "C", 05,0,"99:99"},;
				{"NUMAIT"	, "C", 14,0,"@!"},;
				{"ARTIGO"	, "C", 15,0,"@!"},;
				{"CODOR"	, "C", 25,0,"@!"},;
				{"PLACA"	, "C", 08,0,"@!"},;
				{"NOME"	, "C", 25,0,"@!"},;
				{"DTVENCI"	, "D", 08,0,"99/99/9999"},;
				{"VALOR"	, "N", TAMSX3("TRX_VALOR")[1],TAMSX3("TRX_VALOR")[2],PesqPict("TRX","TRX_VALOR")},;
				{"DTPGTO"	, "D", 08,0,"99/99/9999"},;
				{"VALPAG"	, "N", TAMSX3("TRX_VALPAG")[1],TAMSX3("TRX_VALPAG")[2],PesqPict("TRX","TRX_VALPAG")},;
				{"DTEMIS"	, "D", 08,0,"99/99/9999"},;
				{"STATU"	, "C", 15,0,"@!"},;
				{"TARA"	, "N", TAMSX3("DA3_TARA")[1],TAMSX3("DA3_TARA")[2],PesqPict("DA3","DA3_TARA")},;
				{"COD"		, "C", 06,0,"@!"},;
				{"PESO"	, "N", TAMSX3("DAK_PESO")[1],TAMSX3("DAK_PESO")[2],PesqPict("DAK","DAK_PESO")},;
				{"PAGTO"	, "C", 01,0,"@!"},;
				{"RECUR"	, "C", 01,0,"@!"},;
				{"SITREC"	, "C", 01,0,"@!"}}
		If lIntFin
			aAdd(aDBF, {"NUMTIT", "C", TAMSX3("TRX_NUMSE2")[1], 0})
		EndIf

		//Instancia classe FWTemporaryTable
		oTmpTbl1 := FWTemporaryTable():New( cTRB, aDBF )
		//Cria Indices
		oTmpTbl1:AddIndex( "Ind01" , {"FILIAL","MULTA"} )
		oTmpTbl1:AddIndex( "Ind02" , {"DTREC"}	)
		oTmpTbl1:AddIndex( "Ind03" , {"DTINFR"}	)
		oTmpTbl1:AddIndex( "Ind04" , {"NUMAIT"}	)
		oTmpTbl1:AddIndex( "Ind05" , {"DTVENCI"})
		oTmpTbl1:AddIndex( "Ind06" , {"CODINF"}	)
		oTmpTbl1:AddIndex( "Ind07" , {"CODMO"}	)
		//Cria a tabela temporaria
		oTmpTbl1:Create()

		aTRB :=	{{STR0021, "FILIAL"	, "C", nSizeFil,0,"@!"},;   //"Filial"
				{STR0022, "MULTA"	, "C", 10,0,"@!"},; 	    //"Multa"
				{STR0023, "DTREC"	, "D", 08,0,"99/99/9999"},; //"Dt.Rec."
				{STR0024, "DTINFR"	, "D", 08,0,"99/99/9999"},; //"Dt.Infr."
				{STR0025, "RHINFR"	, "C", 05,0,"99:99"},; 		//"Hr.Infr."
				{STR0026, "NUMAIT"	, "C", 14,0,"@!"},; 		//"AIT."
				{STR0027, "ARTIGO"	, "C", 15,0,"@!"},; 		//"Artigo"
				{STR0028, "CODOR"	, "C", 25,0,"@!"},; 		//"Org.Aut."
				{STR0029, "PLACA"	, "C", 08,0,"@!"},; 		//"Placa"
				{STR0030, "NOME"	, "C", 25,0,"@!"},; 		//"Motorista"
				{STR0031, "DTVENCI", "D", 08,0,"99/99/9999"},; //"Dt.Venc."
				{STR0032, "VALOR"	, "N", 12,2,"@E 999,999,999.99"},; //"Valor"
				{STR0033, "DTPGTO"	, "D", 08,0,"99/99/9999"},; //"Dt.Pag."
				{STR0034, "VALPAG"	, "N", 12,2,"@E 999,999,999.99"},; //"Val.Pgto."
				{STR0035, "DTEMIS"	, "D", 08,0,"99/99/9999"},; //"Dt.Emiss�o"
				{STR0036, "STATU"	, "C", 15,0,"@!"},; 		//"Status"
				{STR0037, "TARA"	, "N", 09,2,"@R 999,999.99"},; //"Tara"
				{STR0038, "COD"	, "C", 06,0,"@!"},; 		//"Carga"
				{STR0039, "PESO"	, "N", 12,3,"@E 9999,999.999"},; //"Peso"
				{STR0085, "CODINF"	, "N", 12,3,"@!"},; //"Cod. Infra��o"
				{STR0086, "CODMO"	, "C", 12,3,"@!"}} //"Cod. Motorista"

		If pergunte("MNC315",.T.)
			MsgRun(OemToAnsi(STR0040),OemToAnsi(STR0041),{|| MNTC315TMP()}) //"Processando Arquivo..."###"Aguarde"
			DbSelectarea(cTRB)
			DbGotop()

			aAdd(aPesq, {STR0021 + " + " + STR0022,{{"","C" , 255 , 0 ,"","@!"} }} )
			aAdd(aPesq, {STR0023, {{"","C" , 255 , 0 ,"","@!"} }} )
			aAdd(aPesq, {STR0024, {{"","C" , 255 , 0 ,"","@!"} }} )
			aAdd(aPesq, {STR0026, {{"","C" , 255 , 0 ,"","@!"} }} )
			aAdd(aPesq, {STR0031, {{"","C" , 255 , 0 ,"","@!"} }} )
			aAdd(aPesq, {STR0085, {{"","C" , 255 , 0 ,"","@!"} }} )
			aAdd(aPesq, {STR0086, {{"","C" , 255 , 0 ,"","@!"} }} )

			oBrowse:= FWMBrowse():New()
			oBrowse:SetDescription(cCadastro)
			oBrowse:SetTemporary(.T.)
			oBrowse:SetAlias(cTRB)
			oBrowse:SetFields(aTRB)
			oBrowse:AddLegend("(cTRB)->PAGTO == cSim .And. (cTRB)->RECUR != cSim", "BR_VERMELHO", STR0056)
			oBrowse:AddLegend("(cTRB)->PAGTO == cSim .And. (cTRB)->RECUR == cSim .And. (cTRB)->SITREC == cPen", "BR_LARANJA", STR0057)
			oBrowse:AddLegend("(cTRB)->PAGTO == cSim .And. (cTRB)->RECUR == cSim .And. (cTRB)->SITREC == cDef", "BR_BRANCO", STR0058)
			oBrowse:AddLegend("(cTRB)->PAGTO == cNao .And. (cTRB)->RECUR != cSim", "BR_VERDE", STR0059)
			oBrowse:AddLegend("(cTRB)->PAGTO == cNao .And. (cTRB)->RECUR == cSim .And. (cTRB)->SITREC == cPen", "BR_CINZA", STR0060)
			oBrowse:AddLegend("(cTRB)->PAGTO == cNao .And. (cTRB)->RECUR == cSim .And. (cTRB)->SITREC == cDef", "BR_AZUL", STR0061)
			oBrowse:SetSeek(.T.,aPesq)
			oBrowse:Activate()

		EndIf

		oTmpTbl1:Delete()//Deleta Tabela Tempor�ria 1

		DbSelectArea("TRX")
		DbSetOrder(1)
		Dbseek(xFilial("TRX"))

		//�����������������������������������������������������������������������Ŀ
		//� Devolve variaveis armazenadas (NGRIGHTCLICK)                          �
		//�������������������������������������������������������������������������
		NGRETURNPRM(aNGBEGINPRM)

	EndIf

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MNTR315TMP| Autor � Rafael Diogo Richter  � Data �15/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Geracao do arquivo temporario                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTR315                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTC315TMP()
	Local cAliasQry := ""

	cAliasQry := "TETRX"

	cQuery := " SELECT TRX.TRX_FILIAL, TRX.TRX_MULTA, TRX.TRX_DTREC, TRX.TRX_DTINFR, TRX.TRX_RHINFR, TRX.TRX_NUMAIT, "
	cQuery += " TRX.TRX_CODOR, TRX.TRX_PLACA, TRX.TRX_DTVECI, TRX.TRX_VALOR, "
	cQuery += " TRX.TRX_DTPGTO, TRX.TRX_VALPAG, TRX.TRX_DTEMIS, TRX.TRX_STATUS, "
	cQuery += "	TRX.TRX_CODINF, TRX.TRX_CODMO, TRX.TRX_PAGTO, TRX.TRX_RECURS, TRX.TRX_SITREC"
	If lIntFin
		cQuery += " , TRX.TRX_NUMSE2 "
	EndIf
	cQuery += "	FROM " + RetSQLName("TRX") + " TRX "

	If mv_par03 == 1
		cQuery += "	WHERE TRX.TRX_DTREC BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"
	ElseIf mv_par03 == 2
		cQuery += " WHERE   TRX.TRX_DTVECI BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
	ElseIf mv_par03 == 3
		cQuery += " WHERE   TRX.TRX_DTINFR BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
	Else
		cQuery += " WHERE   (TRX.TRX_DTINFR BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
		cQuery += " OR   TRX.TRX_DTREC BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
		cQuery += " OR   TRX.TRX_DTVECI BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "')"
	EndIf
	If NGSX2MODO("TRX") == "E"
		cQuery += "	AND TRX.TRX_FILIAL BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"'"
	Endif
	cQuery += "	AND TRX.TRX_MULTA  BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR09+"'"

	cQuery += "	AND TRX.D_E_L_E_T_ <> '*' "
	cQuery += "	ORDER BY TRX.TRX_FILIAL, TRX.TRX_MULTA "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	dbSelectArea(cAliasQry)
	dbGoTop()

	If Eof()
		MsgInfo(STR0042,STR0043) //"N�o existem dados para montar o relat�rio!"###"ATEN��O"
		(cAliasQry)->(dbCloseArea())
		Return
	Endif

	While (cAliasQry)->( !Eof() )
		dbSelectArea("TSH")
		dbSetOrder(01)
		dbSeek(xFilial("TSH")+(cAliasQry)->TRX_CODINF)
		If Mv_par04 == 2
			If TSH->TSH_FLGTPM <> "1"
				(cAliasQry)->(dbSkip())
				Loop
			EndIf
		ElseIf Mv_par04 == 3
			If TSH->TSH_FLGTPM <> "2"
				(cAliasQry)->(dbSkip())
				Loop
			EndIf
		EndIf

		If Mv_par05 == 2
			If (cAliasQry)->TRX_STATUS <> "1"
				(cAliasQry)->(dbSkip())
				Loop
			EndIf
		ElseIf Mv_par05 == 3
			If (cAliasQry)->TRX_STATUS <> "2"
				(cAliasQry)->(dbSkip())
				Loop
			EndIf
		ElseIf Mv_par05 == 4
			If (cAliasQry)->TRX_STATUS <> "3"
				(cAliasQry)->(dbSkip())
				Loop
			EndIf
		EndIf

		dbSelectArea(cTRB)
		dbSetOrder(1)
		If !dbSeek((cAliasQry)->TRX_FILIAL+(cAliasQry)->TRX_MULTA)
			RecLock((cTRB), .T.)
		Else
			RecLock((cTRB), .F.)
		EndIf

		(cTRB)->FILIAL 	:= (cAliasQry)->TRX_FILIAL
		(cTRB)->CODINF		:= (cAliasQry)->TRX_CODINF
		(cTRB)->CODMO		:= (cAliasQry)->TRX_CODMO
		(cTRB)->MULTA		:= (cAliasQry)->TRX_MULTA
		(cTRB)->DTREC		:= STOD((cAliasQry)->TRX_DTREC)
		(cTRB)->DTINFR		:= STOD((cAliasQry)->TRX_DTINFR)
		(cTRB)->RHINFR		:= (cAliasQry)->TRX_RHINFR
		(cTRB)->NUMAIT		:= (cAliasQry)->TRX_NUMAIT
		(cTRB)->ARTIGO		:= TSH->TSH_ARTIGO
		If lIntFin
			(cTRB)->NUMTIT    := (cAliasQry)->TRX_NUMSE2
		EndIf

		dbSelectArea("TRZ")
		dbSetOrder(1)
		If dbSeek(xFilial("TRZ")+(cAliasQry)->TRX_CODOR)
			(cTRB)->CODOR		:= SubStr(TRZ->TRZ_NOMOR,1,25)
		Endif

		(cTRB)->PLACA		:= (cAliasQry)->TRX_PLACA
		(cTRB)->NOME		:= NGSEEK("DA4",(cAliasQry)->TRX_CODMO,1,"SUBSTR(DA4_NOME,1,25)")
		(cTRB)->DTVENCI	:= STOD((cAliasQry)->TRX_DTVECI)
		(cTRB)->VALOR		:= (cAliasQry)->TRX_VALOR
		(cTRB)->DTPGTO		:= STOD((cAliasQry)->TRX_DTPGTO)
		(cTRB)->VALPAG		:= (cAliasQry)->TRX_VALPAG
		(cTRB)->DTEMIS		:= STOD((cAliasQry)->TRX_DTEMIS)

		If (cAliasQry)->TRX_STATUS == "1"
			(cTRB)->STATU := STR0015 //"Registrado"
		ElseIf (cAliasQry)->TRX_STATUS == "2"
			(cTRB)->STATU := STR0016 //"Em andamento"
		ElseIf (cAliasQry)->TRX_STATUS == "3"
			(cTRB)->STATU := STR0017 //"Conclu�do"
		EndIf

		cAliasQry2 :=	GetNextAlias()
		cQuery2 := " 	SELECT DA3.DA3_TARA, DAK.DAK_COD "
		cQuery2 += "	FROM " + RetSQLName("DA3") + " DA3 "
		cQuery2 += "	LEFT JOIN " + RetSQLName("DAK") + " DAK ON DAK.DAK_CAMINH = DA3.DA3_COD "
		cQuery2 += "	AND '"+(cAliasQry)->TRX_DTINFR+"' BETWEEN DAK.DAK_DATA AND DAK.DAK_DTACCA "
		cQuery2 += "	AND DAK.D_E_L_E_T_ <> '*' "
		cQuery2 += "	WHERE DA3.DA3_PLACA = '"+(cAliasQry)->TRX_PLACA+"'"
		cQuery2 += "	AND DA3.D_E_L_E_T_ <> '*' "
		cQuery2 := ChangeQuery(cQuery2)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery2),cAliasQry2, .F., .T.)
		dbGoTop()
		If !Eof()
			(cTRB)->TARA	:= (cAliasQry2)->DA3_TARA
			(cTRB)->COD		:= (cAliasQry2)->DAK_COD
		Endif

		dbSelectArea("DAK")
		dbSetOrder(1)
		dbSeek(xFilial("DAK")+(cAliasQry2)->DAK_COD)
		While !Eof() .And. DAK->DAK_FILIAL == xFilial("DAK") .And. DAK->DAK_COD == (cAliasQry2)->DAK_COD
			If Stod((cAliasQry)->TRX_DTINFR) >= DAK->DAK_DATA .And. Stod( (cAliasQry)->TRX_DTINFR ) <= DAK->DAK_DTACCA
				(cTRB)->PESO += DAK->DAK_PESO
			EndIf
			DAK->(DbSkip())
		End
		(cAliasQry2)->(dbCloseArea())
		(cTRB)->PAGTO := (cAliasQry)->TRX_PAGTO
		(cTRB)->RECUR := (cAliasQry)->TRX_RECURS
		(cTRB)->SITREC := (cAliasQry)->TRX_SITREC

		MsUnLock(cTRB)
		(cAliasQry)->(dbSkip())
	End

	(cAliasQry)->(dbCloseArea())

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MNC315Vi  | Autor � Rafael Diogo Richter  � Data �16/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Visualizacao a consulta                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTC315                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNC315VI()

	DbSelectArea("TRX")
	DbSetOrder(01)
	DbSeek((cTRB)->FILIAL+(cTRB)->MULTA)
	NGCAD01("TRX",Recno(),2)

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MNC315Pa  | Autor � Rafael Diogo Richter  � Data �16/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Reprocessa o browse de acordo com os parametros             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTR315                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNC315PA()

	If !Pergunte("MNC315",.T.)
		Return .T.
	Else
		DbSelectArea(cTRB)
		Zap

		MsgRun(OemToAnsi(STR0040),OemToAnsi(STR0041),{|| MNTC315TMP()}) //"Processando Arquivo..."###"Aguarde"
		DbSelectarea(cTRB)
		DbGotop()
	EndIf

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MNC315Pe  | Autor � Rafael Diogo Richter  � Data �16/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Pesquisa especifica por Multa                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTR315                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNC315PE()

	Local cMulta := Space(Len(TRX->TRX_MULTA))
	Local nInd := 0
	local oDlgPesq, oOrdem, oChave, oBtOk, oBtCan, oBtPar
	Local cOrdem
	Local cChave	:= Space(255)
	Local aOrdens	:= {}
	Local nOrdem := 1
	Local nOpcA := 0

	aAdd( aOrdens, STR0068 ) //"Filial + Multa"
	aAdd( aOrdens, STR0044 ) //"Data Recebimento"
	aAdd( aOrdens, STR0045 ) //"Data Infracao"
	aAdd( aOrdens, STR0046 ) //"Numero da Infracao"
	aAdd( aOrdens, STR0047 ) //"Data Vencimento"
	aAdd( aOrdens, STR0048 ) //"Infracao"
	aAdd( aOrdens, STR0030 ) //"Motorista"

	Define msDialog oDlgPesq Title STR0049 From 00,00 To 100,500 pixel //"Pesquisa"

	@ 005, 005 combobox oOrdem var cOrdem items aOrdens size 210,08 PIXEL OF oDlgPesq ON CHANGE nOrdem := oOrdem:nAt
	@ 020, 005 msget oChave var cChave size 210,08 of oDlgPesq pixel

	define sButton oBtOk  from 05,218 type 1 action (nOpcA := 1, oDlgPesq:End()) enable of oDlgPesq pixel
	define sButton oBtCan from 20,218 type 2 action (nOpcA := 0, oDlgPesq:End()) enable of oDlgPesq pixel
	define sButton oBtPar from 35,218 type 5 when .F. of oDlgPesq pixel

	Activate MsDialog oDlgPesq Center

	If nOpca == 1
		cChave := AllTrim(cChave)
		If nOrdem == 1
			DbSelectArea(cTRB)
			dbSetOrder(1)
			DbSeek(cChave)
		ElseIf nOrdem == 2
			DbSelectArea(cTRB)
			dbSetOrder(2)
			DbSeek(cChave)
		ElseIf nOrdem == 3
			DbSelectArea(cTRB)
			dbSetOrder(3)
			DbSeek(cChave)
		ElseIf nOrdem == 4
			DbSelectArea(cTRB)
			dbSetOrder(4)
			DbSeek(cChave)
		ElseIf nOrdem == 5
			DbSelectArea(cTRB)
			dbSetOrder(5)
			DbSeek(cChave)
		ElseIf nOrdem == 6
			DbSelectArea(cTRB)
			dbSetOrder(6)
			DbSeek(cChave)
		ElseIf nOrdem == 7
			DbSelectArea(cTRB)
			dbSetOrder(7)
			DbSeek(cChave)
		EndIf
	EndIf

	DbSelectArea(cTRB)
	DbSetOrder(01)

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MNC315Pos | Autor � Rafael Diogo Richter  � Data �16/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao do relatorio                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTR315                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNC315IM()

	Local WNREL      := "MNTR315"
	Local LIMITE     := 232
	Local cDESC1     := STR0050 //"O relat�rio apresentar� as multas de Tr�nsito com base nos par�metros escolhidos"
	Local cDESC2     := ""
	Local cDESC3     := ""
	Local cSTRING    := "TRX"
	Local nRecTRB	 := (cTRB)->(Recno())

	Private NOMEPROG := "MNTR315"
	Private TAMANHO  := "G"
	Private aRETURN  := {STR0051,1,STR0052,1,2,1,"",1} //"Zebrado"###"Administracao"
	Private TITULO   := STR0006 //"Consulta/Relat�rio de Multas de Tr�nsito"
	Private nTIPO    := 0
	Private nLASTKEY := 0
	Private Cabec1, Cabec2

	//��������������������������������������������������������������Ŀ
	//� Envia controle para a funcao SETPRINT                        �
	//����������������������������������������������������������������
	WNREL:=SetPrint(cSTRING,WNREL,,TITULO,cDESC1,cDESC2,cDESC3,.F.,"")
	If nLASTKEY = 27
		Set Filter To
		Return
	EndIf

	SetDefault(aReturn,cSTRING)

	Processa({|lEND| C315IMP(@lEND,WNREL,TITULO,TAMANHO)},STR0053) //"Processando Registros..."

	Dbselectarea(cTRB)
	dbGoto(nRecTRB)

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    | C315Imp  | Autor � Rafael Diogo Richter  � Data �16/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao do relatorio                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTR315                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function C315Imp(lEND,WNREL,TITULO,TAMANHO)

	Private li := 80 ,m_pag := 1
	Private cRODATXT := ""
	Private nCNTIMPR := 0

	/*
	0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7
	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
	********************************************************************************************************************************************************************************************************************************************************************************
	Filial        Multa       Dt.Rec.     Dt.Infr.    Hr.Inf.  AIT.            Artigo           Org.Aut.                   Placa     Motorista                  Dt.Venc.             Valor     Nr. T�tulo (somente se integrado com Financeiro)
	********************************************************************************************************************************************************************************************************************************************************************************
	Dt.Pag.          Val.Pgto.  Dt.Emissao  Status                 Tara  Carga           Peso
	********************************************************************************************************************************************************************************************************************************************************************************
	999999999999  xxxxxxxxxx  99/99/9999  99/99/9999  99:99    xxxxxxxxxxxxxx  xxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  99/99/9999  999,999,999.99     XXXXXXXXX
	99/99/9999  999,999,999.99  99/99/9999  xxxxxxxxxxxxxxx  999,999.99  xxxxxx  9999,999.999

	99      xxxxxxxxxx  99/99/9999  99/99/9999  99:99    xxxxxxxxxxxxxx  xxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  99/99/9999  999,999,999.99
	99/99/9999  999,999,999.99  99/99/9999  xxxxxxxxxxxxxxx  999,999.99  xxxxxx  9999,999.999

	99      xxxxxxxxxx  99/99/9999  99/99/9999  99:99    xxxxxxxxxxxxxx  xxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  99/99/9999  999,999,999.99
	99/99/9999  999,999,999.99  99/99/9999  xxxxxxxxxxxxxxx  999,999.99  xxxxxx  9999,999.999

	99      xxxxxxxxxx  99/99/9999  99/99/9999  99:99    xxxxxxxxxxxxxx  xxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  99/99/9999  999,999,999.99
	99/99/9999  999,999,999.99  99/99/9999  xxxxxxxxxxxxxxx  999,999.99  xxxxxx  9999,999.999
	/*/

	Cabec1 := STR0054 //"Filial        Multa       Dt.Rec.     Dt.Infr.    Hr.Inf.  AIT.            Artigo           Org.Aut.                   Placa     Motorista                  Dt.Venc.             Valor"
	Cabec2 := STR0055 //"     Dt.Pag.          Val.Pgto.  Dt.Emissao  Status                 Tara  Carga           Peso"

	// Se estiver integrado com o Financeiro, adiciona seus campos ao cabe�alho
	If lIntFin
		dbSelectArea("SX3")
		dbSetOrder(2)
		If dbSeek("TRX_NUMSE2") // N�mero do T�tulo
			Cabec1 += Space(5) + AllTrim( X3Titulo() )
		EndIf
	EndIf

	dbSelectArea(cTRB)
	dbSetOrder(1)
	dbGoTop()
	ProcRegua(Reccount())
	While !Eof()
		IncProc()

		NgSomaLi(58)
		@ Li,000		Psay (cTRB)->FILIAL
		@ Li,014		Psay (cTRB)->MULTA
		@ Li,026		Psay (cTRB)->DTREC
		@ Li,038		Psay (cTRB)->DTINFR
		@ Li,050		Psay (cTRB)->RHINFR
		@ Li,059		Psay (cTRB)->NUMAIT
		@ Li,075		Psay (cTRB)->ARTIGO
		@ Li,092		Psay (cTRB)->CODOR
		@ Li,119		Psay (cTRB)->PLACA
		@ Li,129		Psay (cTRB)->NOME
		@ Li,156		Psay (cTRB)->DTVENCI
		@ Li,168		Psay (cTRB)->VALOR Picture "@E 999,999,999.99"
		If lIntFin
			@ Li,187		Psay (cTRB)->NUMTIT
		EndIf
		NgSomaLi(58)
		@ Li,005		Psay (cTRB)->DTPGTO
		@ Li,017		Psay (cTRB)->VALPAG Picture "@E 999,999,999.99"
		@ Li,033		Psay (cTRB)->DTEMIS
		@ Li,045		Psay (cTRB)->STATU
		@ Li,062		Psay (cTRB)->TARA Picture "@R 999,999.99"
		@ Li,074		Psay (cTRB)->COD
		@ Li,082		Psay (cTRB)->PESO Picture "@E 9999,999.999"

		NgSomaLi(58)

		(cTRB)->(DbSkip())
	End

	RODA(nCNTIMPR,cRODATXT,TAMANHO)

	//��������������������������������������������������������������Ŀ
	//� Devolve a condicao original do arquivo principal             �
	//����������������������������������������������������������������
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
���Fun��o    � MenuDef  � Autor � Rafael Diogo Richter  � Data �02/02/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Utilizacao de Menu Funcional.                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaMNT                                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
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
Static Function MenuDef()
	Local aRotina :=	{{STR0001,"MNC315PE" ,0,1},;    //"Pesquisar"
						 {STR0002,"MNC315VI" ,0,2},;    //"Visualizar"
						 {STR0003,"MNC315PA" ,0,3,0},;  //"Parametros"
						 {STR0004,"MNC315IM" ,0,3,0}}  //"Imprimir"
						 //{STR0005,"MNC315LEG",0,6,,.F.}//"Legenda"

Return aRotina
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �MNC315FIL � Autor � Marcos Wagner Junior  � Data �02.04.2009���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consistencias dos parametros De/Ate Filial   		        ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �MNTC315                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNC315FIL(nPar)

	If nPar == 1
		If !NGFILIAL(1,mv_Par06)
			Return .f.
		Endif
	Else
		If !NGFILIAL(2,mv_Par06,mv_Par07)
			Return .f.
		Endif
	Endif

	If nOldPAR06 != MV_PAR06 .OR. nOldPAR07 != MV_PAR07
		MV_PAR08  := '       '
		MV_PAR09  := "9999999"
		nOldPAR06 := MV_PAR06
		nOldPAR07 := MV_PAR07
	Endif

Return .t.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MNC315MU � Autor � Marcos Wagner Junior  � Data �02.04.2009���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consistencias do parametro Ate Multa		   		        ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �MNTC315                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNC315MU(nPar)

	If nPar == 1
		If Empty(Mv_Par08)
			Return .t.
		Endif
		Return MNTC315EXI(1)
	Else
		If MV_PAR09 = '9999999'
			Return .t.
		Else
			If MNTC315EXI(2)
				If Mv_Par08 > Mv_Par09
					MsgStop(STR0067,STR0043) //"'At� Multa' dever� ser maior/igual a 'De Multa'!"###"ATEN��O"
					Return .f.
				Endif
			Else
				Return .f.
			Endif
		Endif
	Endif

Return .t.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �MNTC315CON� Autor �Marcos Wagner Junior   � Data � 02/04/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Consulta especifica na TRX, trazendo Multas de todas filiais���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MNTC315                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTC315CON()


	Local i,j
	Local nInd := 0
	local oOrdem, oChave
	Local cChave	:= Space(255)

	Local oTmpTbl2 //Objeto Tabela Tempor�ria 2

	Private oLbx,oDlg2
	Private cOrdIx
	Private nOrdem := 1
	Private aIndices := {}
	Private cTRBX := GetNextAlias()

	nOpcaTRX := 0

	aDbf := {{"FILIAL","C",nSizeFil,0},;
			 {"MULTA" ,"C",09,0},;
			 {"NUMAIT","C",14,0}}


	//Instancia classe FWTemporaryTable
	oTmpTbl2 := FWTemporaryTable():New( cTRBX, aDbf )
	//Cria Indices
	oTmpTbl2:AddIndex( "Ind01" , {"FILIAL","MULTA"}	)
	oTmpTbl2:AddIndex( "Ind02" , {"FILIAL","NUMAIT"})

	//Cria a tabela temporaria
	oTmpTbl2:Create()

	cAliasQry := GetNextAlias()
	cQuery := " SELECT TRX_FILIAL, TRX_MULTA, TRX_NUMAIT "
	cQuery += " FROM " + RetSqlName("TRX")
	cQuery += " WHERE "
	If NGSX2MODO("TRX") == "E"
		cQuery += " TRX_FILIAL BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "'AND"
	Endif
	cQuery += " D_E_L_E_T_<> '*' "
	cQuery += " ORDER BY TRX_FILIAL, TRX_MULTA "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	dbSelectArea((cAliasQry))
	dbGoTop()
	If !Eof()
		While !Eof()
			DbSelectArea(cTRBX)
			RecLock((cTRBX),.t.)
			(cTRBX)->FILIAL := (cAliasQry)->TRX_FILIAL
			(cTRBX)->MULTA  := (cAliasQry)->TRX_MULTA
			(cTRBX)->NUMAIT := (cAliasQry)->TRX_NUMAIT
			MsUnlock(cTRBX)
			DbSelectArea((cAliasQry))
			DbSkip()
		EndDo
	Else
		DbSelectArea(cTRBX)
		RecLock((cTRBX),.t.)
		(cTRBX)->FILIAL := ''
		(cTRBX)->MULTA  := ''
		(cTRBX)->NUMAIT := ''
		MsUnlock(cTRBX)
	Endif
	(cAliasQry)->(DbCloseArea())

	cLine := "{ || { "
	i     := 0
	aAux  := {}
	aLbx  := {}

	// Monta os dados do listbox
	dbSelectArea(cTRBX)
	aFields := DBSTRUCT()
	aCabec  := {STR0021,STR0022,STR0062} //"Filial"###"Multa"###"Nro Infracao"

	dbGotop()
	While !Eof()
		aAux := Array(Len(aFields))
		For j := 1 to Len(aFields)
			aAux[j] := &(aFields[j][1])
		Next j
		Aadd(aLbx,aAux)
		dbSkip()
	End

	nTAMB := Len(aLbx)

	// Define o numero de colunas do listbox
	For i:=1 To Len(aDbf)
		If aDbf[i][2] == "D"
			cLine+= "DtoC(aLbx[oLbx:nAt,"+Alltrim(str(i,2))+"])"
		ElseIf aDbf[i][2] == "N"
			cLine+= "Str(aLbx[oLbx:nAt,"+Alltrim(str(i,2))+"])"
		Else
			cLine+= "aLbx[oLbx:nAt,"+Alltrim(str(i,2))+"]"
		EndIf
		If i#Len(aDbf)
			cLine+=","
		Else
			cLine+="}"
		EndIf
	Next i

	cLine+= "}"
	nGuarda := 1
	nOrdem  := 1

	aAdd(aIndices,STR0063) //"Filial+Multa"
	aAdd(aIndices,STR0064) //"Filial+Nro Infracao"

	Define MsDialog oDlg2 Title STR0065 From 000,000 To 421,522 Pixel //"Cadastro de Multas"

	@ 005, 005 combobox oOrdem var cOrdIx items aIndices size 210,08 PIXEL OF oDlg2 ON CHANGE nOrdem := oOrdem:nAt
	@ 020, 005 msget oChave var cChave size 210,08 of oDlg2 pixel
	@ 005, 220 Button STR0066 of oDlg2 Size 40,10 Pixel Action MNTC315PES(cChave) //"&Pesquisar"

	oLbx:= TWBrowse():New(3,0,263,149,,aCabec,, oDlg2,,,,,,,,,,,, .F.,, .F.,, .F.,,, )

	oLbx:SetArray(aLbx)
	oLbx:bLine := &(cline)
	oLbx:nAt   := nGuarda
	oLbx:bLDblClick := {|| (nOpcaTRX := 1,nGuarda:=oLbx:nAt,oDlg2:End()) }

	Define sButton oBtOk  from 195, 05 type 1 action (nOpcaTRX := 1,nGuarda := oLbx:nAt, oDlg2:End()) enable of oDlg2 pixel
	Define sButton oBtCan from 195, 36 type 2 action (nOpcaTRX := 0, oDlg2:End()) enable of oDlg2 pixel
	Define sButton oBtPar from 195, 67 type 15 action MNTC315VIS() enable of oDlg2 pixel

	ACTIVATE MSDIALOG oDlg2 CENTERED

	If Empty(aLbx[nGuarda][1]) .AND. Empty(aLbx[nGuarda][2])
		nOpcaTRX := 0
	Endif

	If nOpcaTRX == 1
		dbSelectArea("TRX")
		dbSetOrder(01)
		dbSeek(aLbx[nGuarda][1]+aLbx[nGuarda][2])
	EndIf

	oTmpTbl2:Delete()//Deleta Tabela Tempor�ria 2

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNTC315PES � Autor �Marcos Wagner Junior  � Data � 02/04/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Monta a tela de pesquisa especifica.                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTC315                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTC315PES(cCHPesq)
	Local cSeek

	dbSelectArea(cTRBX)
	If cOrdIx == STR0063 //"Filial+Multa"
		dbSetOrder(01)
		cSeek := SubStr(cCHPesq,1,11)
	ElseIf cOrdIx == STR0064 //"Filial+Nro Infracao"
		dbSetOrder(02)
		cSeek := SubStr(cCHPesq,1,16)
	Endif
	dbSeek(cSeek,.t.)
	If !Eof()
		nOrdem := Recno()
	ElseIf Eof()
		nOrdem := Len(aLbx)
	Endif

	oLbx:SetFocus(aLbx[nOrdem])

	oLbx:nAt   := nOrdem
	oLbx:bLine := &(cline)

Return .t.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNTC315VIS� Autor � Marcos Wagner Junior  � Data � 02/04/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Visualizacao da Multa                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTC315                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTC315VIS()
	cCadastro := STR0065 //"Cadastro de Multas"

	dbSelectArea("TRX")
	dbSetOrder(01)
	dbSeek(aLbx[oLbx:nAt][1]+aLbx[oLbx:nAt][2])
	NgCad01("TRX",Recno(),2)

Return .t.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �MNTC315RET� Autor �Marcos Wagner Junior   � Data � 02/04/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna codigo da Multa  	                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MNTC315                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTC315RET()

	If nOpcaTRX == 1
		Return TRX->TRX_MULTA
	Endif

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �MNTC315EXI� Autor �Marcos Wagner Junior   � Data � 03/04/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna se a Multa existe ou nao                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MNTC315                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTC315EXI(nPar)
	Local lRet := .t.
	Local aOldArea := GetArea()

	cAliasQry := GetNextAlias()
	cQuery := " SELECT 1 "
	cQuery += " FROM " + RetSqlName("TRX")
	cQuery += " WHERE TRX_MULTA = '" + IIF(nPar==1,MV_PAR08,MV_PAR09) + "'"
	If NGSX2MODO("TRX") == "E"
		cQuery += " AND   TRX_FILIAL BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "'"
	EndIf
	cQuery += " AND   D_E_L_E_T_<> '*' "
	cQuery += " ORDER BY TRX_FILIAL, TRX_MULTA "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	dbGotop()

	If Eof()
		HELP(" ",1,"REGNOIS")
		lRet := .f.
	Endif

	(cAliasQry)->(DbCloseArea())
	RestArea(aOldArea)

Return lRet
