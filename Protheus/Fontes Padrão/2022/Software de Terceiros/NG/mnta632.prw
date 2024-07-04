#INCLUDE "MNTA632.ch"
#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA632
Contador da bomba

@author Vitor Emanuel Batista
@since 08/09/2009
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTA632()

	Local aNGBEGINPRM := {}

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 19, 95 )

		aNGBEGINPRM := NGBEGINPRM()

		Private aRotina   := MenuDef()
		Private cCadastro := OemtoAnsi(STR0001) //"Contador da Bomba"
		Private bNgGrava  := {|| MNT632VGRAV() }

		dbSelectarea("TQJ")
		dbSetOrder(01)
		mBrowse(6,1,22,75,"TQJ")

		NGRETURNPRM(aNGBEGINPRM)

	EndIf

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �MNTA632QUE � Autor �Vitor Emanuel Batista � Data �08/09/2009���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao para a Quebra do Contador                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAMNT                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTA632QUE()
	Local aNAO := {}

	aRELAC := {	{"TTV_MOTIVO","'3'"},;
					{"TTV_POSTO","TQJ->TQJ_CODPOS"},;
					{"TTV_DESCPO","NGSEEK('TQF',TQJ->TQJ_CODPOS+TQJ->TQJ_LOJA,1,'TQF->TQF_NREDUZ')"},;
					{"TTV_LOJA","TQJ->TQJ_LOJA"},;
					{"TTV_TANQUE","TQJ->TQJ_TANQUE"},;
					{"TTV_BOMBA","TQJ->TQJ_BOMBA"},;
					{"TTV_TIPOLA","'3'"},;
					{"TTV_USUARI","RetCodUsr()"},;
					{"TTV_DTINCL","dDataBase"},;
					{"TTV_HRINCL","Time()"}}

	bNGGRAVA := {|| MntVerQue()}

	aAdd(aNAO,"TTV_POSFIM")
	aAdd(aNAO,"TTV_CONSUM")
	aAdd(aNAO,"TTV_NABAST")
	aAdd(aNAO,"TTV_TIPOLA")
	aAdd(aNAO,"TTV_MOTIVO")
	aCHOICE := NGCAMPNSX3("TTV",aNAO)

	NGCAD01("TTV",TTV->(Recno()),3)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA632HIS
Abre historico do contador da bomba selecionada

@author Vitor Emanuel Batista
@since 29/09/2009
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTA632HIS()

	Local aNGBEGINPRM := {}
	Local aInd        := {}
	Local aOldRotina  := {}
	Local cCond

	If FindFunction( 'MNTA632A' )

		//-----------------------------------------
		// Rotina com menu padr�o
		//-----------------------------------------
		MNTA632A()

	Else

		aNGBEGINPRM := NGBEGINPRM(,"MNTA632",Nil,.T.)
		aOldRotina  := aCLONE(aRotina)

		Private aRotina :=	{ { STR0002 ,"AxPesqui"   , 0 , 1},; //"Pesquisar"###
									{ STR0004 ,"NGCAD01"    , 0 , 2},; //"Visualizar"
								{ STR0013 ,"MNTA632CAN" , 0 , 5}} //"Canc. Quebra"

		cCadastro := OemtoAnsi(STR0005) //"Hist�rico do Contador da Bomba"

		dbSelectarea("TTV")
		dbSetOrder(1)
		cCond := "TTV->TTV_FILIAL == '"+xFilial("TTV")+"' .AND. "
		cCond += "TTV->TTV_POSTO  == '"+TQJ->TQJ_CODPOS+"' .AND. "
		cCond += "TTV->TTV_LOJA   == '"+TQJ->TQJ_LOJA+"' .AND. "
		cCond += "TTV->TTV_TANQUE == '"+TQJ->TQJ_TANQUE+"' .AND. "
		cCond += "TTV->TTV_BOMBA  == '"+TQJ->TQJ_BOMBA+"' "

		bFiltraBrw := {|| FilBrowse("TTV",@aInd,@cCond,.T.) }
		Eval(bFiltraBrw)

		mBrowse(6,1,22,75,"TTV")

		//��������������������������������������������Ŀ
		//�Retorna conteudo de variaveis padroes       �
		//����������������������������������������������
		aRotina := aCLONE(aOldRotina)
		aEval(aInd,{|x| Ferase(x[1]+OrdBagExt())})
		ENDFILBRW("TTV",aInd)
		NGRETURNPRM(aNGBEGINPRM)
	
	EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MntVerQue � Autor �Vitor Emanuel Batista  � Data �29/09/2009���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacoes ao Gravar a Quebra                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA632                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MntVerQue()
	Local aAreaTTV := TTV->(GetArea())

	If !INCLUI
		Return .T.
	EndIf
	//������������������������������������������������������������Ŀ
	//�Verifica os abastecimentos do mesmo Posto/Loja/Tanque/Bomba �
	//��������������������������������������������������������������
	If !NGVALABAST(M->TTV_POSTO,M->TTV_LOJA,M->TTV_TANQUE,M->TTV_BOMBA,M->TTV_DATA,M->TTV_HORA,.f.,.f.)
		Return .f.
	Endif

	dbSelectArea("TTV")
	dbSetOrder(1)
	dbSeek(xFilial("TTV")+M->TTV_POSTO+M->TTV_LOJA+M->TTV_TANQUE+M->TTV_BOMBA+DtoS(M->TTV_DATA),.t.)
	Do While !EoF() .And. xFilial("TTV") == TTV->TTV_FILIAL .And. M->TTV_DATA <= TTV->TTV_DATA .And. ;
							M->TTV_POSTO == TTV->TTV_POSTO .And.M->TTV_LOJA == TTV->TTV_LOJA .And. ;
							M->TTV_TANQUE == TTV->TTV_TANQUE .And. M->TTV_BOMBA == TTV->TTV_BOMBA
			If M->TTV_HORA <= TTV->TTV_HORA .Or. M->TTV_DATA < TTV->TTV_DATA
				ShowHelpDlg(STR0006,{STR0007},1,; //"ATEN��O"###"Hora Inicial n�o pode ser inferior ou igual � Hora Fim do �ltimo registro de aferi��o."
											{STR0008},1) //"Informe uma Data/Hora superior."
				Return .F.
			EndIf

		DbSelectArea("TTV")
		DbSkip()
	EndDo

	NGUltConBom(M->TTV_POSTO,M->TTV_LOJA,M->TTV_TANQUE,M->TTV_BOMBA,M->TTV_DATA,M->TTV_HORA)
	nAcumCo := TTV->TTV_ACUMCO
   RestArea(aAreaTTV)

   M->TTV_POSFIM := M->TTV_POSINI
   M->TTV_ACUMCO := nAcumCo
Return .T.


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �MNT632VGRAV� Autor �Vitor Emanuel Batista � Data �08/09/2009���
�������������������������������������������������������������������������Ĵ��
���Descricao � Faz validaoes para a gravacao do registro                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAMNT                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNT632VGRAV()
   Local aArea := GetArea()
	Local lRet  := .T.

	If !INCLUI
		Return .T.
	EndIf

	If !MNT632CON()
		Return .F.
	EndIf

	dbSelectArea("TTV")
	dbSetOrder(1)
	If dbSeek(xFilial("TTV")+M->TTV_POSTO+M->TTV_LOJA+M->TTV_TANQUE+M->TTV_BOMBA+DTOS(M->TTV_DATA)+M->TTV_HORA)
		Help(" ",1,"JAEXISTINF")
		lRet := .F.
	EndIf

	If lRet
		dbSelectArea("TQJ")
		dbSetOrder(1)
		If dbSeek(xFilial("TQJ")+M->TTV_POSTO+M->TTV_LOJA+M->TTV_TANQUE+M->TTV_BOMBA)
			If TQJ->TQJ_LIMCON < M->TTV_POSCON
				MsgInfo(STR0009) //"Quantidade atual n�o poder� superar o Limite de Contador da Bomba!"
				lRet := .F.
			Endif
		EndIf
	EndIf
	RestArea(aArea)

	NGIncTTV(M->TTV_POSTO,M->TTV_LOJA,M->TTV_TANQUE,M->TTV_BOMBA,M->TTV_DATA,M->TTV_HORA,"",M->TTV_POSCON)

Return lRet


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MenuDef  � Autor � Vitor Emanuel Batista � Data �08/09/2009���
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
	Local aRotina :=	{ { STR0002 ,"AxPesqui"   , 0 , 1},; //"Pesquisar"
	        				  { STR0004 ,"NGCAD01"    , 0 , 2},; //"Visualizar"
				           { STR0010 ,"MNTA632QUE" , 0 , 3},; //"Quebra"
				           { STR0011 ,"MNTA632HIS" , 0 , 2}} //"Hist�rico"

Return aRotina

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MNT632CON � Autor �Vitor Emanuel Batista � Data �08/09/2009���
�������������������������������������������������������������������������Ĵ��
���Descricao �Valida campo de Contador, Data e Hora                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MNTA632                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNT632CON()
	Local cAliasQry, cQuery
	Local lRet := .T.

	If !Empty(M->TTV_POSINI) .And.Empty(M->TTV_DATA) .And. Empty(M->TTV_HORA)
		Help(" ",1,"OBRIGAT2")
		Return .F.
	EndIf

	cAliasQry := GetNextAlias()
	cQuery := " SELECT COUNT(*) AS TTV_COUNT FROM " + RetSqlName("TTV")
	cQuery += " 	WHERE TTV_POSTO = " + ValToSql(M->TTV_POSTO)
	cQuery += " 		AND TTV_LOJA = " + ValToSql(M->TTV_LOJA)
	cQuery += " 		AND TTV_TANQUE = " + ValToSql(M->TTV_TANQUE)
	cQuery += " 		AND TTV_BOMBA = " + ValToSql(M->TTV_BOMBA)
	cQuery += " 		AND TTV_DATA||TTV_HORA > " + ValToSql(DTOS(M->TTV_DATA)+M->TTV_HORA)
	cQuery += " 		AND TTV_FILIAL = '"+xFilial("TTV")+"' AND D_E_L_E_T_ = ''"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	If (cAliasQry)->TTV_COUNT > 0
		ShowHelpDlg(STR0006,{STR0012},1,; //"ATEN��O"##"J� existe reporte de contador para a Bomba com Data/Hora superior a informada."
						{STR0008},1) //"Informe uma Data/Hora superior."
		lRet := .F.
	EndIf
	(cAliasQry)->(dbCloseArea())
Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �MNT630NOME � Autor �Vitor Emanuel Batista � Data �29/09/2009���
�������������������������������������������������������������������������Ĵ��
���Descricao � Retorna o nome do Posto+Loja                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA630                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNT632NOMEF(cPosto,cLoja,cFil)
	Local aArea := GetArea()
	Local cNome := ""
	dbSelectArea("TQF")
	dbSetOrder(1)
	If dbSeek(xFilial("TQF",cFil)+cPosto+cLoja)
		cNome := TQF->TQF_NREDUZ
	EndIf
	RestArea(aArea)
Return cNome

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �MNTA632CAN � Autor � Marcos Wagner Junior � Data �08/12/2009���
�������������������������������������������������������������������������Ĵ��
���Descricao � Cancela a quebra da bomba, desde que nao tenham sido feitos���
���          � abastecimentos posteriores a quebra								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA632                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTA632CAN()
Local nCont := 0

If TTV->TTV_MOTIVO == '3'

	cPosto  := TTV->TTV_POSTO
	cLoja   := TTV->TTV_LOJA
	cTanque := TTV->TTV_TANQUE
	cBomba  := TTV->TTV_BOMBA
	nRecno  := Recno()
	dbSkip()

	While TTV->TTV_FILIAL == xFilial("TTV") .AND. TTV->TTV_POSTO == cPosto .AND. TTV->TTV_LOJA == cLoja .AND.;
			TTV->TTV_TANQUE == cTanque .AND. TTV->TTV_BOMBA == cBomba .AND. nCont == 0
		nCont++
		dbSkip()
	End
	dbGoTo(nRecno)
	If nCont == 1
		ShowHelpDlg(STR0014,{STR0015},3,; //"ATEN��O"###"J� existe uma aferi��o com data/hora superior a 'Quebra'."
										{STR0016},3) //"Exclua as Aferi��es cadastradas com data/hora superior a 'Quebra'."
	Else
		RecLock("TTV",.f.)
		dbDelete()
		TTV->(MsUnlock())
	Endif
Else
	MsgInfo(STR0017) //"Opera��o permitida apenas para 'Motivo' igual a 'Quebra'!"
Endif

Return .t.
