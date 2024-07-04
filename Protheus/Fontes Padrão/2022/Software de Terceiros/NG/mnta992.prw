#INCLUDE "MNTA992.ch"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � MNTA992   � Autor �Vitor Emanuel Batista � Data �05/08/2009���
�������������������������������������������������������������������������Ĵ��
���Descricao �Reporte de Horas da Mao de Obra                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAMNT                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTA992()

	//��������������������������������������������Ŀ
	//�Guarda conteudo e declara variaveis padroes �
	//����������������������������������������������
	Local aNGBEGINPRM := NGBEGINPRM()

	Private aRotina := MenuDef()

	//��������������������������������������������������������������Ŀ
	//� Define o cabecalho da tela de atualizacoes                   �
	//����������������������������������������������������������������
	Private cCadastro := OemtoAnsi(STR0001) //"Reporte de Horas da Mao de Obra"
	Private bNGGrava  :=	{|| MNT992TUDOK() }

	//��������������������������������������������������������������Ŀ
	//� Endereca a funcao de BROWSE                                  �
	//����������������������������������������������������������������

	dbSelectArea("TTL")
	dbSetOrder(1)
	mBrowse( 6, 1,22,75,"TTL")

	//��������������������������������������������Ŀ
	//�Retorna conteudo de variaveis padroes       �
	//����������������������������������������������
	NGRETURNPRM(aNGBEGINPRM)

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT992TUDOK
Valida inclusao do reporte de horas

@author	Vitor Emanuel Batista
@since	31/08/2009

Return lRet, L�gico, Valor que confere se registro � valido.

/*/
//---------------------------------------------------------------------
Static Function MNT992TUDOK()
	Local nRecno := Nil
	Local lRet	 := .T.
	Local aArea  := GetArea()

	If INCLUI .Or. ALTERA
		If Empty(StrTran(M->TTL_HRFIM,�":",�"",�1))
			lRet := .F.
			Help(1," ","OBRIGAT2",,NGRETTITULO("TTL_HRFIM"),3,0)
		EndIf
		If lRet .And. Empty(StrTran(M->TTL_HRINI,�":",�"",�1))
			lRet := .F.
			Help(1," ","OBRIGAT2",,NGRETTITULO("TTL_HRINI"),3,0)
		EndIf
		If lRet .And. !NGVALDATIN(M->TTL_CODFUN,,,M->TTL_DTINI,M->TTL_HRINI,M->TTL_DTFIM,M->TTL_HRFIM,"M",,"STL")[1]
			lRet := .F.
		EndIf
		If lRet .And. !NGVALDATIN(M->TTL_CODFUN,,,M->TTL_DTINI,M->TTL_HRINI,M->TTL_DTFIM,M->TTL_HRFIM,"M",,"STT ")[1]
			lRet := .F.
		EndIf
		If lRet .And. !NGFUNCRH(M->TTL_CODFUN,.T.,M->TTL_DTFIM)
			lRet := .F.
		EndIf

		If lRet .And. ALTERA
			nRecno := TTL->(Recno())
		EndIf

		//Verifica se funcionario ja nao esta alocado no intervalo de data/hora
		If lRet .And. (!NGVDTINS(M->TTL_CODFUN,M->TTL_DTINI,M->TTL_HRINI,M->TTL_DTFIM,M->TTL_HRFIM,"M") .Or. ;
			!NGVDTHRTTL(M->TTL_CODFUN,M->TTL_DTINI,M->TTL_HRINI,M->TTL_DTFIM,M->TTL_HRFIM,nRecno))
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. ExistBlock("MNTA9921")// Verifica se existe o ponto de entrada
		If ExecBlock("MNTA9921",.F.,.F.)
			lRet := .F.
		EndIf
	EndIf

	RestArea(aArea)
Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    NGVDTHRTTL Autor �Vitor Emanuel Batista � Data �31/08/2009���
�������������������������������������������������������������������������Ĵ��
���Descricao �Valida inclusao do reporte de horas                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA992                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function NGVDTHRTTL(cCodFun,dDataIni,cHoraIni,dDataFim,cHoraFim,nRecno)
	Local lRecno := nRecno!=Nil

	Local cHrIniTemp := cHoraIni
	Local cHrFimTemp := cHoraFim
	Local dDtIniTemp := dDataIni
	Local dDtFimTemp := cHoraFim

	//Validacao para permitir insumos no mesmo intervalo de data/hora inicio/fim
	If cHoraIni == '23:59'
		dDataIni += 1
	EndIf
	If cHoraFim == '00:00'
		dDataFim -= 1
	EndIf
	cHoraIni := MTOH(HTOM(cHoraIni)+1)
	cHoraFim := MTOH(HTOM(cHoraFim)-1)

	cAliasQry := GetNextAlias()
	cQuery := " SELECT TTL_TPHORA,TTL_QUANTI,TTL_DTINI,TTL_HRINI,TTL_DTFIM,TTL_HRFIM "
	cQuery += " FROM "+NGRETX2("TTL")+" TTL"
	cQuery += " WHERE TTL.TTL_CODFUN = "+ValToSql(cCodFun)+" AND "+RetSqlCond("TTL")
	cQuery += "     AND (("+ValToSql(DtoS(dDataIni)+cHoraIni)+" BETWEEN TTL.TTL_DTINI||TTL.TTL_HRINI AND TTL.TTL_DTFIM||TTL.TTL_HRFIM"
	cQuery += "      OR "+ValToSql(DtoS(dDataFim)+cHoraFim)+"  BETWEEN TTL.TTL_DTINI||TTL.TTL_HRINI  AND TTL.TTL_DTFIM||TTL.TTL_HRFIM)"
	cQuery += "      OR (TTL.TTL_DTINI||TTL.TTL_HRINI BETWEEN "+ValToSql(DtoS(dDataIni)+cHoraIni)+" AND "+ValToSql(DtoS(dDataFim)+cHoraFim)
	cQuery += "      OR TTL.TTL_DTFIM||TTL.TTL_HRFIM  BETWEEN "+ValToSql(DtoS(dDataIni)+cHoraIni)+" AND "+ValToSql(DtoS(dDataFim)+cHoraFim)+"))"
	If lRecno
		cQuery += " AND TTL.R_E_C_N_O_<> "+cValToChar(nRecno)
	EndIf
	cQuery += " ORDER BY "+TTL->(SqlOrder(IndexKey(1)))

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	//Retorna valores iniciais das variaveis
	cHoraIni := cHrIniTemp
	cHoraFim := cHrFimTemp
	dDataIni := dDtIniTemp
	dDataFim := dDtFimTemp

	dbSelectArea(cAliasQry)
	dbGoTop()
	If !Eof()
		MsgInfo(	STR0005+ CHR(13) + CHR(13)+; //"J� existe aplica��o de insumo no intervalo de Data/Hora informada."
					STR0006 + CHR(13) + CHR(13) + ; //"Aplica��o do insumo j� existente pelo Reporte de Horas:"
					STR0007 + AllTrim((cAliasQry)->TTL_TPHORA) + " - " + AllTrim(NGSEEK("TTJ",(cAliasQry)->TTL_TPHORA,1,"TTJ->TTJ_DESCRI")) + CHR(13) + ; //"Tipo de Hora.: "
					STR0008 + DTOC(STOD((cAliasQry)->TTL_DTINI)) + CHR(13) + ; //"Data In�cio.....: "
					STR0009 + (cAliasQry)->TTL_HRINI + CHR(13) + ; //"Hora In�cio.....: "
					STR0010 + DTOC(STOD((cAliasQry)->TTL_DTFIM)) + CHR(13) + ; //"Data Fim........: "
					STR0011 + (cAliasQry)->TTL_HRFIM,STR0012) //"Hora Fim........: "###"NAO CONFORMIDADE"
		Return .F.
	EndIf
Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor �Vitor Emanuel Batista  � Data �05/08/2009���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
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
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MenuDef()

	Local aRotina := {	{	STR0013	,	"AxPesqui"	,	0	,	1	},; //"Pesquisar" //"Pesquisar"
								{	STR0014,	"NGCAD01"	,	0	,	2	},; //"Visualizar" //"Visualizar"
								{	STR0015	,	"MNTA992CAD"	,	0	,	3	},; //"Incluir" //"Incluir"
								{	STR0016	,	"MNTA992CAD"	,	0	,	4	},; //"Alterar" //"Alterar"
								{	STR0017	,	"NGCAD01"	,	0	,	5,	3} } //"Excluir" //"Excluir"
Return(aRotina)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MNTA992  � Autor � Marcos Wagner Junior  � Data � 05/05/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao do botao "Incluir" e do botao "Alterar"             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MNTA035()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTA992CAD(cAlias,nReg,nOpcx)

Local cTipoHora := ''

Private cTpHoraAnt := ''
Private cFuncioAnt := ''
Private cDtHrAnt := ''

If nOpcx == 4
	cTpHoraAnt := TTL->TTL_TPHORA
	cFuncioAnt := TTL->TTL_CODFUN
	cDtHrAnt := DTOS(TTL->TTL_DTINI)+DTOS(TTL->TTL_DTFIM)+TTL->TTL_HRINI+TTL->TTL_HRFIM
Endif

nRet := NGCAD01(cAlias,nReg,nOpcx)

dbSelectArea("TTJ")
dbSetOrder(1)
If dbSeek( xFilial("TTJ")+TTL->TTL_TPHORA)
	If TTJ->TTJ_USACAL == "S"
		cTipoHora := "S"
	Else
		cTipoHora := GETMV("MV_NGUNIDT")
	EndIf
EndIf

If nRet == 1
	RecLock("TTL",.f.)
	TTL->TTL_TIPOHO := cTipoHora
	TTL->(MsUnlock())
Endif
cTpHoraAnt := ''
cFuncioAnt := ''

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNTA992CHK � Autor � Marcos Wagner Junior � Data � 05/05/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Pre-consistencia da quantidade do insumo                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA400                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTA992CHK()

If !NGVALQUANT('M','H',M->TTL_QUANTI,.t.,cCalend)
   Return .f.
Endif

Return .t.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �NGCALDTHO � Autor �Inacio Luiz Kolling    � Data �30/09/2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Calcula a data e hora inicio a partir de uma data e hora fim���
���          �e quantidade ou vise-versa. Dependendo utiliza calend�rio   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �GENERICA                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNT992DTHR()

	Local cUsaCale := ''
	Local cCALE := ''

	cREADVAR := Readvar()

	If (cREADVAR == "M->TTL_TPHORA" .AND. cTpHoraAnt <> M->TTL_TPHORA) .OR.;
		(cREADVAR == "M->TTL_CODFUN" .AND. cFuncioAnt <> M->TTL_CODFUN)
		M->TTL_DTINI := STOD('  /  /  ')
		M->TTL_HRINI := '  :  '
		M->TTL_DTFIM := STOD('  /  /  ')
		M->TTL_HRFIM :=  '  :  '
		M->TTL_QUANTI := 0
		cTpHoraAnt := M->TTL_TPHORA
		cFuncioAnt := M->TTL_CODFUN
		Return .T.
	EndIf

	If cREADVAR == "M->TTL_HRINI" .And. Empty(StrTran(M->TTL_HRINI,�":",�"",�1�)) .Or.;
		cREADVAR == "M->TTL_HRFIM" .And. Empty(StrTran(M->TTL_HRFIM,�":",�"",�1�))
		Return .T.
	EndIf

	dbSelectArea("TTJ")
	dbSetOrder(1)
	If dbSeek(xFilial("TTJ")+M->TTL_TPHORA)
		cUsaCale := TTJ->TTJ_USACAL
	EndIf

	If cREADVAR == "M->TTL_QUANTI" .AND. !Empty(cUsaCale)
		If !NGVALQUANT('M','H',M->TTL_QUANTI,.T.,cUsaCale)
			Return .F.
		EndIf
	EndIf

	dbSelectArea("ST1")
	dbSetOrder(01)
	If dbSeek(xFilial("ST1")+M->TTL_CODFUN)
		cCALE := ST1->T1_TURNO
	EndIf

	If cREADVAR == "M->TTL_DTINI" .And. cUsaCale == "S" .And. !Empty(M->TTL_DTINI) .And. !Empty(StrTran(M->TTL_HRINI,�":",�"",�1�))
		If !NGVALHRCALE(cCALE,M->TTL_DTINI,M->TTL_HRINI,"I")
			Return .F.
		EndIf
	ElseIf cREADVAR == "M->TTL_HRINI" .And. cUsaCale == "S" .And. !Empty(M->TTL_DTINI) .And. !Empty(StrTran(M->TTL_HRINI,�":",�"",�1�))
		If !NGVALHRCALE(cCALE,M->TTL_DTINI,M->TTL_HRINI,"I")
			Return .F.
		EndIf
	ElseIf cREADVAR == "M->TTL_DTFIM" .And. cUsaCale == "S" .And. !Empty(StrTran(M->TTL_HRFIM,�":",�"",�1�)) .And. !Empty(M->TTL_DTFIM)
		If !NGVALHRCALE(cCALE,M->TTL_DTFIM,M->TTL_HRFIM,"F")
			Return .F.
		EndIf
	ElseIf cREADVAR == "M->TTL_HRFIM" .And. cUsaCale == "S" .And. !Empty(M->TTL_DTFIM) .And. !Empty(StrTran(M->TTL_HRFIM,�":",�"",�1�))
		If !NGVALHRCALE(cCALE,M->TTL_DTFIM,M->TTL_HRFIM,"F")
			Return .F.
		EndIf
	EndIf

	If (M->TTL_DTINI <> STOD("")) .And. (M->TTL_DTFIM <> STOD("")) .And.;
		(Empty(M->TTL_HRINI) .Or. !Empty(StrTran(M->TTL_HRINI,�":",�"",�1))) .And.;
		(Empty(M->TTL_HRFIM) .Or. !Empty(StrTran(M->TTL_HRFIM,�":",�"",�1))) .And.;
		(M->TTL_DTINI == M->TTL_DTFIM) .And. (M->TTL_HRINI == M->TTL_HRFIM)
		MsgInfo(STR0022,STR0012) //"A diferen�a entre a Data/Hora inicio e Data/Hora fim dever� ser maior que 0"###"NAO CONFORMIDADE"
		Return .F.
	EndIf

	lGETACH  := .T.

	dDTI  := M->TTL_DTINI
	hHI   := M->TTL_HRINI
	dDTF  := M->TTL_DTFIM
	hHF   := M->TTL_HRFIM
	nQTD  := M->TTL_QUANTI
	cCODF := M->TTL_CODFUN
	cTIPR := 'M'

	If cREADVAR == "M->TTL_HRINI" .And. cTIPR <> "P" .And. !Empty(dDTI) .And. !Empty(dDTF) .And. !Empty(hHF)
		If dDTI = dDTF .And. M->TTL_HRINI > hHF
			Help(" ",1,"HORAINVALI",,STR0018,3,1) //"Hora inicio maior do que hora fim"
			Return .F.
		EndIf
	ElseIf cREADVAR == "M->TTL_HRFIM" .And. cTIPR <> "P" .And. !Empty(dDTI) .And. !Empty(dDTF) .And. !Empty(hHI)
		If dDTI = dDTF .And. M->TTL_HRFIM < hHI
			Help(" ",1,"HORAINVALI",,STR0019,3,1) //"Hora fim menor do que hora inicio"
			Return .F.
		EndIf
	ElseIf cREADVAR == "M->TTL_DTINI" .And. cTIPR <> "P" .And. !Empty(dDTF)
		If M->TTL_DTINI > dDTF
			MsgInfo(STR0020,STR0012) //"Data inicio maior do que data fim"###"NAO CONFORMIDADE"
			Return .F.
		EndIf
	ElseIf cREADVAR == "M->TTL_DTFIM" .And. cTIPR <> "P" .And. !Empty(dDTI)
		If M->TTL_DTFIM < dDTI
			MsgInfo(STR0021,STR0012) //"Data fim menor do que data inicio"###"NAO CONFORMIDADE"
			Return .F.
		ElseIf !Empty(dDTF) .And. !Empty(hHI) .And. !Empty(StrTran(hHF,�":",�"",�1))
			If (dDTI == dDTF .And. hHI > hHF)
				Help(" ",1,"HORAINVALI",,STR0018,3,1) //"Hora inicio maior do que hora fim"
				Return .F.
			EndIf
		EndIf
	EndIf

	hHIV  := If(Empty(StrTran(hHI,�":",�"",�1)),Space(5),hHI)
	hHFV  := If(Empty(StrTran(hHF,�":",�"",�1)),Space(5),hHF)
	nQTDF := 0.00
	lCALE := .F.

	If cUsaCale == "S"
		aMATCA := NGCALENDAH(cCALE)
		lCALE  := .T.
	EndIf

	// TROCOU O TIPO
	If cREADVAR == "M->TTL_TPHORA" //"M->TL_USACALE"
		If !Empty(dDTI) .And. !Empty(hHIV) .And. (Empty(dDTF) .Or. Empty(hHFV)) .And. !Empty(nQTD)
			NGCALEDTFIM(dDTI,hHIV,nQTD,cCALE)
		ElseIf !Empty(dDTI) .And. !Empty(hHIV) .And. !Empty(dDTF) .And. !Empty(hHFV)
			NGCALEINTD(dDTI,hHIV,dDTF,hHFV,cCALE)
		ElseIf (!Empty(dDTI) .Or. !Empty(hHIV)) .And. !Empty(dDTF) .And. !Empty(hHFV) .And. !Empty(nQTD)
			NGCALEDTINI(dDTF,hHFV,nQTD,cCALE)
		Endif
	// DATA E HORA INICIO
	ElseIf (cREADVAR == "M->TTL_DTINI" .Or. cREADVAR == "M->TTL_HRINI")
		If cREADVAR == "M->TTL_DTINI"
		// LENDO A DATA INICIO
			If !Empty(dDTI)
				If !Empty(hHIV)
					If !Empty(dDTF) .And. !Empty(hHFV)
						NGCALEINTD(dDTI,hHIV,dDTF,hHFV,cCALE)
					ElseIf !Empty(nQTD)
						NGCALEDTFIM(dDTI,hHIV,nQTD,cCALE)
					EndIf
				Else
					If !Empty(dDTF) .And. !Empty(hHFV) .And. !Empty(nQTD)
						NGCALEDTINI(dDTF,hHFV,nQTD,cCALE)
					EndIf
				EndIf
			Else
				If !Empty(dDTF) .And. !Empty(hHFV) .And. !Empty(nQTD)
					NGCALEDTINI(dDTF,hHFV,nQTD,cCALE)
				EndIf
			EndIf
		Else
			// LENDO A HORA INICIO
			If !Empty(hHIV)
				If !Empty(dDTI)
					If !Empty(dDTF) .And. !Empty(hHFV)
						NGCALEINTD(dDTI,hHIV,dDTF,hHFV,cCALE)
					ElseIf !Empty(nQTD)
						NGCALEDTFIM(dDTI,hHIV,nQTD,cCALE)
					EndIf
				ElseIf !Empty(dDTF) .And. !Empty(hHFV) .And. !Empty(nQTD)
					NGCALEDTINI(dDTF,hHFV,nQTD,cCALE)
				EndIf
			Else
				If !Empty(dDTF) .And. !Empty(hHFV) .And. !Empty(nQTD)
					NGCALEDTINI(dDTF,hHFV,nQTD,cCALE)
				EndIf
			EndIf
		EndIf
	// DATA E HORA FIM
	ElseIf cREADVAR == "M->TTL_DTFIM" .Or. cREADVAR == "M->TTL_HRFIM"
		// LENDO A DATA FIM
		If cREADVAR == "M->TTL_HRFIM"
			If !Empty(dDTF)
				If !Empty(hHFV)
					If !Empty(dDTI) .And. !Empty(hHIV)
						NGCALEINTD(dDTI,hHIV,dDTF,hHFV,cCALE)
					ElseIf !Empty(nQTD)
						NGCALEDTINI(dDTF,hHFV,nQTD,cCALE)
					EndIf
				Else
					If !Empty(dDTI) .And. !Empty(hHIV) .And. !Empty(nQTD)
						NGCALEDTFIM(dDTI,hHIV,nQTD,cCALE)
					EndIf
				EndIf
			Else
				If !Empty(dDTI) .And. !Empty(hHIV) .And. !Empty(nQTD)
					NGCALEDTFIM(dDTI,hHIV,nQTD,cCALE)
				EndIf
			EndIf
		Else
			// LENDO A HORA FIM
			If !Empty(hHFV)
				If !Empty(dDTF)
					If !Empty(dDTI) .And. !Empty(hHIV)
						NGCALEINTD(dDTI,hHIV,dDTF,hHFV,cCALE)
					ElseIf !Empty(nQTD)
						NGCALEDTINI(dDTF,hHFV,nQTD,cCALE)
					EndIf
				ElseIf !Empty(dDTI) .And. !Empty(hHIV) .And. !Empty(nQTD)
					NGCALEDTINI(dDTI,hHFV,nQTD,cCALE)
				EndIf
			Else
				If !Empty(dDTI) .And. !Empty(hHIV) .And. !Empty(nQTD)
					NGCALEDTFIM(dDTI,hHIV,nQTD,cCALE)
				EndIf
			EndIf
		EndIf
	ElseIf cREADVAR == "M->TTL_QUANTI"
		// OK
		If !Empty(nQTD)
			If !Empty(dDTI) .And. !Empty(hHIV)
				NGCALEDTFIM(dDTI,hHIV,nQTD,cCALE)
			Else
				If (Empty(dDTI) .Or. Empty(hHIV)) .And. (!Empty(dDTF) .And. !Empty(hHFV))
					NGCALEDTINI(dDTF,hHFV,nQTD,cCALE)
				EndIf
			EndIf
		Else
			If !Empty(dDTI) .And. !Empty(hHIV) .And. !Empty(dDTF) .And. !Empty(hHFV)
				NGCALEINTD(dDTI,hHIV,dDTF,hHFV,cCALE)
			EndIf
		EndIf
	EndIf

Return .T.