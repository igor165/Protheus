#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FATA520B.CH" 
   
#DEFINE NTAMCOD 2

Static cVendIgn		:= Nil
Static aVndProc		:= {}
Static cLastVnd		:= ""
Static cProcName	:= StrTran("REPADL" + cEmpAnt + cFilAnt," ")
Static aListSup		:= {}
Static lTodos		:= .F.
Static lLjADL 		:= FindFunction("LJADLSeek") .And. nModulo == 12 // Fun��o criada no fonte Lojxfune (automa��o comercial)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520Tota2�Autor  �Vendas CRM          � Data �  01/04/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Totaliza a quantidade de suspects, prospects, clientes e    ���
���          �contas para o vendedor informado                            ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Codigo do vendedor                                  ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft520Tota2(cVendedor)

Local aArea		:= GetArea()			   		// Armazena o posicionamento atual
Local cQuery	:= ""							// Query enviada ao banco de dados
Local aEnt		:= {"ACH","SUS","SA1"}			// Entidadas a serem consideradas para contagem - Manter ordem
Local aRet		:= {0,0,0}						// Total de suspects, prospects, clientes
Local nX		:= 0							// Auxiliar de loop
Local nTpConta	:= SuperGetMv("MV_FATTENT",,1)	// Tipo de contagem(somente suspects, somente prospects, etc...)
Local cChave	:= ""							// Campos buscados na query
Local cCond		:= ""							// Condicao da query

//���������������������������������������Ŀ
//�Utilizacao do MV_FATTENT:              �
//�1 - Soma Suspects, Prospects e clientes�
//�2 - Soma Suspects e Prospects          �
//�3 - Soma Prospects e Clientes          �
//�4 - Soma Clientes e Suspects           �
//�5 - Soma Suspects                      �
//�6 - Soma Prospects                     �
//�7 - Soma Clientes                      �
//�����������������������������������������

//������������������������������������������������������������Ŀ
//�Totaliza a quantidade de clientes, suspects e prospects para�
//�o vendedor                                                  �
//��������������������������������������������������������������

//������������������������������������������������������������Ŀ
//�Verifica se a area de trabalho temporaria encontra-se aberta�
//��������������������������������������������������������������
If Select("FT520TMP") > 0
	FT520TMP->(DbCloseArea())
EndIf

For nX := 1 to Len(aEnt)

	//��������������������������������������������������������Ŀ
	//�Verifica quais entidades devem ser somadas de acordo com�
	//�o parametro MV_FATTENT                                  �
	//����������������������������������������������������������
	If aEnt[nX] == "ACH" //Suspects

		If !((nTpConta == 1) .OR. (nTpConta == 2) .OR. (nTpConta == 4) .OR. (nTpConta == 5))
			Loop
		EndIf

	ElseIf aEnt[nX]	== "SUS" //Prospects

		If !((nTpConta == 1) .OR. (nTpConta == 2) .OR. (nTpConta == 3) .OR. (nTpConta == 6))
			Loop
		EndIf

	ElseIf aEnt[nX]	== "SA1"

		If !((nTpConta == 1) .OR. (nTpConta == 3) .OR. (nTpConta == 4) .OR. (nTpConta == 7))
			Loop
		EndIf

	EndIf
	
	//��������������������������Ŀ
	//�Query de selecao dos dados�
	//����������������������������
	If aEnt[nX] == "ACH"
		
		cQuery	:= " SELECT COUNT(*) AS TOTENT"
		cQuery	+= " FROM " + RetSqlName("ACH") 
		cQuery	+= " WHERE ACH_FILIAL = '" + xFilial("ACH") + "'"
		cQuery	+= " AND ACH_VEND = '" + cVendedor + "'"
		cQuery	+= " AND D_E_L_E_T_ = ' ' "
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"FT520TMP",.F.,.T.)
		FT520TMP->(DbGoTop())
		
		If !FT520TMP->(Eof())
			aRet[nX]	:= FT520TMP->TOTENT
		EndIf
		
		FT520TMP->(DbCloseArea())    
		
	Else

		If aEnt[nX] == "SUS"
			cChave	:= "AD1_PROSPE,AD1_LOJPRO" 
			cCond	:= "AD1_PROSPE <> '"+Space(TamSX3("AD1_PROSPE")[1])+"' "
		Else
			cChave	:= "AD1_CODCLI,AD1_LOJCLI"  
			cCond	:= "AD1_CODCLI <> '"+Space(TamSX3("AD1_CODCLI")[1])+"' "
		EndIf
		
		cQuery	:= "SELECT " + cChave + " FROM " + RetSqlName("AD1") + " AD1 "
		cQuery	+= 		"WHERE AD1_FILIAL = '" + xFilial("AD1") + "' AND AD1.AD1_VEND = '" + cVendedor + "' AND AD1.D_E_L_E_T_ = ' ' " 
		cQuery	+= 		"AND AD1_STATUS IN('1','3') AND " + cCond
		cQuery	+= "UNION "
		cQuery	+= "SELECT " + cChave + " FROM " + RetSqlName("AD1") + " AD1 "
		cQuery	+= 		"INNER JOIN " + RetSqlName("AD2") + " AD2 ON AD2_FILIAL = '" + xFilial("AD2") + "' AND AD2_NROPOR = AD1_NROPOR "
		cQuery	+= 		"AND AD2_REVISA = AD1_REVISA AND AD2_VEND = '" + cVendedor + "' AND AD2.D_E_L_E_T_ = ' ' "
		cQuery	+= 		"WHERE AD1_FILIAL = '" + xFilial("AD1") + "' AND AD1.D_E_L_E_T_ = ' '" 
		cQuery	+= 		"AND AD1_STATUS IN('1','3') AND " + cCond
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"FT520TMP",.F.,.T.)
		FT520TMP->(DbGoTop())
		
		While !FT520TMP->(Eof())
			aRet[nX]++
			FT520TMP->(DbSkip())
		End
		
		FT520TMP->(DbCloseArea()) 
	
	EndIf

Next nX

RestArea(aArea)

Return aRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520Limpa�Autor  �Vendas CRM          � Data �  01/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Remove registros deletados (somente em ambiente SQL).       ���
�������������������������������������������������������������������������͹��
���Parametros�ExpL1 - Indica se todos os registros devem ser apagados(ZAP)���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft520Limpa(lDelTodos)

Local cQuery	:= ""	// Query enviada ao banco de dados

Default lDelTodos	:= .F.

//�������������������������������������������������������������Ŀ
//�Apaga registros deletados quando for utilizado banco de dados�
//���������������������������������������������������������������
#IFDEF TOP

	If ( !lDelTodos .Or. !Empty(xFilial("ADL")) ) //--> Se o campo ADL_FILIAL nao for totalmente compartilhado executar a limpeza por Filial.
		cQuery	:= "DELETE FROM " + RetSqlName("ADL")
		cQuery	+= " WHERE "
	    cQuery	+=       " ADL_FILIAL = '" + xFilial("ADL") + "'" 
		If TcSrvType() != "AS/400"
			cQuery	+= "AND D_E_L_E_T_ = '*' "
		Else
			cQuery	+= "AND @DELETED@ = '*' "
		EndIf
	Else
		If Alltrim(TcGetDB()) == "DB2"
			cQuery	:= "ALTER TABLE " + RetSqlName("ADL") + " ACTIVATE NOT LOGGED INITIALLY WITH EMPTY TABLE"
		Else
			cQuery	:= "TRUNCATE TABLE " + RetSqlName("ADL")
		EndIf
	EndIf

	TcSqlExec(cQuery)

#ENDIF

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520Repro�Autor  �Vendas CRM          � Data �  07/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Reprocessamento da base de clientes dos vendedores          ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft520Repro()
                 
Local oDlg1	   		:= Nil							// Objeto da Dialog
Local nTamA3_COD	:= TamSX3("A3_COD")[1]   		// Tamanho do campo A3_COD
Local cVendDe  		:= Space(nTamA3_COD)   			// Codigo do vendedor inicial
Local cVendAte 		:= Replicate("z",nTamA3_COD)	// Codigo do vendedor final
Local lContinua		:= .T.							// Define se deve prosseguir com o reprocessamento
Local cHoraIn		:= ""							// Hora inicial do processamento
Local dDataIn		:= Nil							// Data inicial do processamento
Local cHoraFi		:= ""							// Hora final do processamento
Local dDataFi		:= Nil							// Data final do processamento
Local lEnd			:= .F.
Local lExtEstNeg	:= GetMv( "MV_CRMESTN", .F., .F. )

Static lProcRegua	:= .T.							// Indica se inicializa o procregua

DEFINE MSDIALOG oDlg1 TITLE STR0001 FROM 0,0 TO 140,450 PIXEL //"Reprocessamento de contas em aberto"
	                       
	@ 023,004 TO 065,170 LABEL STR0002 PIXEL OF oDlg1 //"Selecao do vendedor:"

	@ 002,003 Say STR0003 Size 226,008 COLOR CLR_BLACK PIXEL OF oDlg1 //"Recria v�nculos do vendedor com suspects, prospects e clientes, a partir das oportunidades"
	@ 010,003 Say STR0004 Size 125,008 COLOR CLR_BLACK PIXEL OF oDlg1 //"or�amentos ou propostas"
	@ 042,011 Say STR0005 Size 055,008 COLOR CLR_BLACK PIXEL OF oDlg1 //"C�digo do vendedor:"
	@ 035,080 Say STR0016 Size 055,008 COLOR CLR_BLACK PIXEL OF oDlg1 //"De :"
	@ 050,080 Say STR0017 Size 055,008 COLOR CLR_BLACK PIXEL OF oDlg1 //"At�:"
	@ 035,095 MsGet cVendDe		F3 "SA3" Size 065,009 COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg1
	@ 050,095 MsGet cVendAte	F3 "SA3" Size 065,009 COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg1	

	DEFINE SBUTTON FROM 035,190 TYPE 1 ENABLE OF oDlg1 Action(oDlg1:End())
	DEFINE SBUTTON FROM 050,190 TYPE 2 ENABLE OF oDlg1 Action(lContinua:=.F.,oDlg1:End())

ACTIVATE MSDIALOG oDlg1 CENTERED 

If lContinua .And. lExtEstNeg

	If Empty(cVendDe) .AND. ("ZZZZZZ" $ AllTrim(Upper(cVendAte)))
		lTodos	:= .T.
	Else
		lTodos	:= .F.
	EndIf  
	
	If !TcGetdb() $ "POSTGRES/INFORMIX"
		cProcName	:= StrTran("REPADL" + cEmpAnt + cFilAnt," ")
		
		If !Ft520CrPro()
			Alert(STR0012) //"Falha ao criar a procedure"
			Return .F.
		EndIf
	EndIf
	
	aVndProc	:= {}
	cHoraIn		:= Time()
	dDataIn		:= Date()
	lProcRegua	:= .T.
	
	If !TcGetdb() $ "POSTGRES/INFORMIX"
		Processa({|lEnd| Ft520Proce(@lEnd,cVendDe,cVendAte)},STR0006,STR0007,.T.) //"Aguarde"##"Selecionando registros..."
		TcRefresh(RetSqlName("ADL"))
	Else
		Processa({|lEnd| Ft520Proc(@lEnd,cVendDe,cVendAte)},STR0006,STR0007,.T.) //"Aguarde"##"Selecionando registros..."
	EndIf  
	
	aVndProc	:= {}
	cHoraFi := Time()
	dDataFi := Date()
	
	cMensagem :=STR0013 + cHoraIn + STR0014 + cHoraFi + CRLF +; //"Processamento finalizado. Inicio: "###" Final: "
 				STR0015 +ATTotHora(dDataIn,cHoraIn,dDataFi,cHoraFi) //"Total (Dias HH:MM): "
 	MsgInfo(cMensagem)  
 	MemoWrite("FATA520.TXT", cMensagem)
 	lTodos := .F.
Else
	Return .F.
EndIf

Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520Inc  �Autor  �Vendas CRM          � Data �  16/06/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Insere entidades para o vendedor atual e para os superiores ���
���          �deste vendedor                                              ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Codigo do vendedor                                  ���
���          �ExpC2 - Sigla da entidade (SA1,SUS,ACH)                     ���
���          �ExpC3 - Codigo da entidade                                  ���
���          �ExpC4 - Loja da entidade                                    ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft520Inc(	cCodVend	, cEnt	, cCodigo	, cLoja	)

Local aArea		:= GetArea()
Local cFilADL	:= xFilial("ADL")
Local cFilEnt	:= xFilial(cEnt)
Local aDados	:= {}
Local nX		:= 0  

//�����������������������������������������������������������������Ŀ
//�Recupera a lista de superiores, se nao foi recebida via parametro�
//�������������������������������������������������������������������
If cLastVnd <> cCodVend
	If nModulo != 73
		DbSelectArea("SA3")
		DbSetOrder(1)
		DbSeek(xFilial("SA3")+cCodVend)
		aListSup := Ft520Sup(SA3->A3_NVLSTR)
	Else
		DbSelectArea("AO3")		// Usuarios do CRM
		DbSetOrder(2)				// AO3_FILIAL + AO3_VEND 
		If AO3->( DbSeek( xFilial( "AO3" ) + cCodVend ) )
			aListSup := Ft520Sup(AO3->AO3_IDESTN)
		EndIf
	EndIf
	cLastVnd := cLastVnd
EndIf

Ft520Valid(@cEnt,@cCodigo,@cLoja,{})

//��������������������������������������������������Ŀ
//�Verifica se ja foi feita a amarracao anteriormente�
//����������������������������������������������������
If lLjADL // executo essa fun��o para o moulo 12 sigloja com PafEcf
	If LjADLSeek(cFilADL,cCodVend,cFilEnt,cEnt,cCodigo,cLoja) > 0
		Return .F.
	EndIf
Else
	If ADLSeek(cFilADL,cCodVend,cFilEnt,cEnt,cCodigo,cLoja) > 0
		Return .F.
	EndIf
EndIf
//�������������������������������Ŀ
//�Recupera nome e CGC da entidade�
//���������������������������������
If cEnt == "SA1"
	aDados := GetAdvFVal(cEnt,{"A1_NOME","A1_CGC"},cFilEnt+cCodigo+cLoja,1,{"",""})
ElseIf cEnt == "SUS"
	aDados := GetAdvFVal(cEnt,{"US_NOME","US_CGC"},cFilEnt+cCodigo+cLoja,1,{"",""})
ElseIf cEnt == "ACH"
	aDados := GetAdvFVal(cEnt,{"ACH_RAZAO","ACH_CGC"},cFilEnt+cCodigo+cLoja,1,{"",""})
EndIf

//�����������������������������Ŀ
//�Insere o registro do vendedor�
//�������������������������������
DbSelectArea("ADL")

RecLock("ADL",.T.)
ADL->ADL_FILIAL	:= cFilADL
ADL->ADL_VEND	:= cCodVend
ADL->ADL_FILENT	:= cFilEnt
ADL->ADL_ENTIDA	:= cEnt
ADL->ADL_CODENT	:= cCodigo
ADL->ADL_LOJENT	:= cLoja
ADL->ADL_NOME	:= aDados[1]
ADL->ADL_CGC	:= aDados[2]
MsUnLock()

//�������������������������������Ŀ
//�Insere registro para superiores�
//���������������������������������
For nX := 1 to Len(aListSup)
	If ADLSeek(cFilADL,aListSup[nX][1],cFilEnt,cEnt,cCodigo,cLoja) == 0
		RecLock("ADL",.T.)
		ADL->ADL_FILIAL	:= cFilADL
		ADL->ADL_VEND	:= aListSup[nX][1]
		ADL->ADL_FILENT	:= cFilEnt
		ADL->ADL_ENTIDA	:= cEnt
		ADL->ADL_CODENT	:= cCodigo
		ADL->ADL_LOJENT	:= cLoja
		ADL->ADL_NOME	:= aDados[1]
		ADL->ADL_CGC	:= aDados[2]
		MsUnLock()
	EndIf
Next nX

RestArea(aArea)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520Alt  �Autor  �Vendas CRM          � Data �  01/07/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Altera a amarracao de uma entidade entre vendedores         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Codigo do vendedor antigo                           ���
���          �ExpC2 - Codigo do vendedor novo                             ���
���          �ExpC3 - Sigla da entidade (SA1,SUS,ACH)                     ���
���          �ExpC4 - Codigo da entidade                                  ���
���          �ExpC5 - Loja da entidade                                    ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft520Alt(	cVendAnt	,cVendAtu	, cEnt		, cCodigo	,;
					cLoja		,lProcSup	)

Local aArea	   		:= GetArea()       		// Guarda o posicionamento da tabela atual
Local aAreaADL		:= ADL->(GetArea())	// Guarda o posicionamento da tabela ADL
Local lTemRelac		:= .F.					// Indica se ha relacionamento com a entidade
Local lContinua		:= .T. 
Local nRecDel  		:= 0
Local nX			:= 0   

Default lProcSup	:= .T.    

If nModulo != 73  
	DbSelectArea("SA3")
	DbSetOrder(1)
	DbSeek(xFilial("SA3")+cVendAnt)

	//�������������������������������������������������Ŀ
	//�Recupera a lista de superiores do vendedor antigo�
	//���������������������������������������������������
	If lProcSup
		aListSup 	:= Ft520Sup(SA3->A3_NVLSTR,.T.)
	EndIf
Else
	DbSelectArea("AO3")	// Usuarios do CRM
	DbSetOrder(2)			// AO3_FILIAL + AO3_VEND
	If AO3-> ( DbSeek( xFilial( "AO3" ) + cVendAnt ) )

		//�������������������������������������������������Ŀ
		//�Recupera a lista de superiores do vendedor antigo�
		//���������������������������������������������������
		If lProcSup
			aListSup 	:= Ft520Sup(AO3->AO3_IDESTN,.T.)
		EndIf
	EndIf
EndIf

//�������������������������������������������������������������Ŀ
//�Verifica se o vendedor anterior pode ser desvinculado, quando�
//�nao houver mais relacionamento do vendedor com a entidade    �
//�em oportunidades, alem da amarracao direta no cadastro       �
//���������������������������������������������������������������
lTemRelac := Ft520Relac(cVendAnt,cEnt,cCodigo,cLoja)
lContinua := !lTemRelac

If !lTemRelac .AND. (nRecDel := ADLSeek(xFilial("ADL"),cVendAnt,xFilial(cEnt),cEnt,cCodigo,cLoja)) > 0
	ADL->(DbGoTo(nRecDel))
	RecLock("ADL",.F.)
	DbDelete()
	MsUnLock()
EndIf

nX := 1

//����������������������������������������������������������Ŀ
//�Verifica se os companheiros e os superiores possuem acesso�
//�a mesma entidade, eliminando as amarracoes desnecessarias �
//������������������������������������������������������������
While lProcSup .AND. lContinua .AND. nX <= Len(aListSup)
    
	//Pula o proprio vendedor
	If aListSup[nX][1] == cVendAnt
		nX++
		Loop
	EndIf   
	
	//Busca amarracoes para o vendedor com a entidade
	lTemRelac := Ft520Relac(aListSup[nX][1],cEnt,cCodigo,cLoja)
	lContinua := !lTemRelac
	
	If !lTemRelac .AND. (nRecDel := ADLSeek(xFilial("ADL"),aListSup[nX][1],xFilial(cEnt),cEnt,cCodigo,cLoja)) > 0
		ADL->(DbGoTo(nRecDel))
		RecLock("ADL",.F.)
		DbDelete()
		MsUnLock()
	EndIf

	nX++

End

//�����������������������������������������������������������������Ŀ
//�Seta a variavel cLastVnd como "" para pesquisar a lista novamente�
//�na proxima vez, pois nesta execucao foi solicitada a inclusao dos�
//�vendedores do mesmo time                                         �
//�������������������������������������������������������������������
cLastVnd := ""

//������������������������������������������Ŀ
//�Inclui relacionamento para o novo vendedor�
//��������������������������������������������
If !Empty(cVendAtu)
	Ft520Inc(cVendAtu,cEnt,cCodigo,cLoja)
EndIf

RestArea(aAreaADL)
RestArea(aArea)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520Del  �Autor  �Vendas CRM          � Data �  03/07/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Apaga amarracao com um vendedor                             ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Codigo do vendedor                                  ���
���          �ExpC2 - Sigla da entidade (SA1,SUS,ACH)                     ���
���          �ExpC3 - Codigo da entidade                                  ���
���          �ExpC4 - Loja da entidade                                    ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft520Del(	cVend	, cEnt	, cCodigo	, cLoja	,;
					lProcSup)

//����������������������������������������������������������������������������Ŀ
//�Executa a alteracao do vendedor antigo para nulo (nao insere nova amarracao)�
//������������������������������������������������������������������������������
Ft520Alt(	cVend	,""			, cEnt	, cCodigo	,;
			cLoja	, lProcSup	)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520UpdEn�Autor  �Vendas CRM          � Data �  03/07/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Atualiza a tabela ADL com o novo codigo da entidade, apos   ���
���          �conversao                                                   ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Alias da entidade anterior                          ���
���          �ExpC2 - Alias da entidade convertida                        ���
���          �ExpC3 - Codigo da entidade anterior                         ���
���          �ExpC4 - Codigo da entidade convertida                       ���
���          �ExpC5 - Loja da entidade anterior                           ���
���          �ExpC6 - Loja da entidade convertida                         ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft520UpdEn(cEntAnt	, cEntAtu	, cCodAnt	, cCodAtu	,;
					cLojAnt	, cLojAtu	)

Local aArea		:= GetArea()				// Guarda o posicionamento da tabela atual
Local aAreaADL	:= ADL->(GetArea())		// Guarda o posicionamento da tabela ADL
Local aRecnos	:= {}						// Lista de registros a serem atualizados
Local cFilAdl	:= xFilial("ADL")			// Filial da tabela ADL
Local cFilOld	:= xFilial(cEntAnt)			// Filial da entidade original
Local cFilNew	:= xFilial(cEntAtu)			// Filial da entidade nova
Local nX		:= 0 						// Auxiliar de loop
Local cQuery	:= ""						// Query a ser executada
Local cAliQry	:= "ADLTMP"					// Alias temporario

If Select(cAliQry) > 0
	(cAliQry)->(DbCloseArea())
EndIf

//������������������������������������Ŀ
//�Seleciona registros para modificacao�
//��������������������������������������
cQuery	:= "SELECT R_E_C_N_O_ AS NUMREC FROM " + RetSqlName("ADL")
cQuery	+= " WHERE ADL_FILIAL = '" + cFilADL + "' AND ADL_ENTIDA = '" + cEntAnt + "'"
cQuery	+= " AND ADL_FILENT = '" + cFilOld + "' AND ADL_CODENT = '" + cCodAnt + "'"
cQuery	+= " AND ADL_LOJENT = '" + cLojAnt + "' AND D_E_L_E_T_ = ' '"

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliQry,.F.,.T.)

DbSelectArea(cAliQry)
DbGoTop()

While !(cAliQry)->(Eof())
	AAdd(aRecnos,(cAliQry)->NUMREC )	
	(cAliQry)->(DbSkip())
End

(cAliQry)->(DbCloseArea())

//������������������Ŀ
//�Atualiza registros�
//��������������������
Begin Transaction

DbSelectArea("ADL")

For nX := 1 to Len(aRecnos)

	ADL->(DbGoTo(aRecnos[nX]))
	RecLock("ADL",.F.)       
	ADL->ADL_FILENT	:= cFilNew
	ADL->ADL_ENTIDA	:= cEntAtu
	ADL->ADL_CODENT	:= cCodAtu
	ADL->ADL_LOJENT	:= cLojAtu
	MsUnLock()

Next nX

End Transaction

RestArea(aAreaADL)
RestArea(aArea)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520Proc �Autor  �Vendas CRM          � Data �  15/07/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Chamada publica da funcao de reprocessamento Ft530Proce,    ���
���          �limpando a variavel static aVndProc                         ���
�������������������������������������������������������������������������͹��
���Parametros�ExpL1    - Flag para interromper o processamento            ���
���          �ExpC2    - Codigo do vendedor inicial para processamento    ���
���          �ExpC3    - Codigo do vendedor final para processamento      ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft520Proc2(lEnd, cVendDe, cVendAte)

cProcName := StrTran("REPADL" + cEmpAnt + cFilAnt," ")

If !Ft520CrPro()
	Alert(STR0012) //"Falha ao criar a procedure"
	Return .F.
EndIf

aVndProc := {}

Return Ft520Proce(lEnd, cVendDe, cVendAte)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520Proce�Autor  �Vendas CRM          � Data �  07/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Processa a base de clientes, suspects e prospects de cada   ���
���          �vendedor, dentro dos parametros.                            ���
�������������������������������������������������������������������������͹��
���Parametros�ExpL1    - Flag para interromper o processamento            ���
���          �ExpC2    - Codigo do vendedor inicial para processamento    ���
���          �ExpC3    - Codigo do vendedor final para processamento      ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft520Proce(	lEnd	,cVendDe, cVendAte	)

Local aArea			:= {}
Local cAlias 		:= ""
Local cFilSA3		:= "" 
Local cQuery		:= ""
Local cNivel		:= ""
Local nNivel		:= 0
Local nRecSA3		:= 0
Local nX			:= 0
Local aGrpSup		:= Array(15)
Local aPDFields	 	:= {"A3_NOME"}
Local lPDObfuscate	:= .F.
Local cNomeVend		:= ""





aArea 	:= GetArea()
cAlias	:= GetNextAlias()
cFilSA3	:= xFilial("SA3")			// Filial para a tabela SA3

//��������������������������������������Ŀ
//�Recupera lista de vendedores ignorados�
//����������������������������������������
If cVendIgn == NIL
	cVendIgn	:= SuperGetMv("MV_FATVIGN",,"")
EndIf

//������������������������������������������������������Ŀ
//�Se o reprocessamento for completo, limpa a ADL via SQL�
//�para agilizar o processo                              �
//��������������������������������������������������������
If Empty(cVendDe) .AND. ("ZZZZZZ" $ AllTrim(Upper(cVendAte)))
	Ft520Limpa(.T.)
	If lProcRegua
		ProcRegua(SA3->(RecCount()))
		lProcRegua := .F.
	EndIf
Else
	If lProcRegua
		ProcRegua(Ft520Count(cVendDe,cVendAte))
		lProcRegua := .F.
	EndIf
EndIf

DbSelectArea("SA3")
DbSetOrder(1) //A3_FILIAL+A3_COD
DbSeek(cFilSA3+cVendDe,.T.)

//Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
FATPDLoad(Nil,Nil,aPDFields)     
lPDObfuscate := FATPDIsObfuscate("A3_NOME")
If lPDObfuscate
	cNomeVend := FATPDObfuscate(SA3->A3_NOME)
EndIf

While !SA3->(Eof()) 			.AND.;
	SA3->A3_FILIAL	== cFilSA3	.AND.;
	SA3->A3_COD		<= cVendAte

	//�����������������Ŀ
	//�Descarta ignorado�
	//�������������������
	If (AllTrim(SA3->A3_COD) $ cVendIgn) .OR. Empty(SA3->A3_NVLSTR)
		SA3->(DbSkip())
		Loop
	EndIf
	
	//������������������������������������������������������������Ŀ
	//�Adiciona vendedor a lista de vendedores ja processados, para�
	//�otimizar performance devido a recursividade da rotina       �
	//��������������������������������������������������������������
	If aScan(aVndProc,SA3->A3_COD) > 0
		SA3->(DbSkip())
		Loop
	Else 
		aAdd(aVndProc,SA3->A3_COD)
	EndIf		
	
	If !lPDObfuscate
		cNomeVend := AllTrim(SA3->A3_NOME) 
	EndIf 
	IncProc(STR0011 + AllTrim(SA3->A3_COD) + " - " + cNomeVend) //"Processando vendedor "

	//�����������������������������������Ŀ
	//�Deleta amarracoes anteriores na ADL�
	//�������������������������������������
	If !lTodos
		Ft520DelDB(SA3->A3_COD)
	EndIf
	
	//�������������������������������Ŀ
	//�Tratamento para o botao cancela�
	//���������������������������������
	If (lEnd <> NIl) .AND. lEnd .And. (lEnd := ApMsgNoYes(STR0009,STR0010)) //"Deseja cancelar a execu��o do processo?"##"Interromper"
		Exit
	EndIf
	
	//��������������������������������Ŀ
	//�Monta lista de grupos superiores�
	//����������������������������������
	cCodInt	:= AllTrim(SA3->A3_NVLSTR)

	For nX := 1 to Len(aGrpSup)
		cCodInt := SubStr(cCodInt,1,Len(cCodInt)-NTAMCOD)
		aGrpSup[nX] := cCodInt
	Next nX
	
	//���������������������Ŀ
	//�Execucao da procedure�
	//�����������������������
	TCSPExec(	cProcName	, SA3->A3_COD	, PADR(aGrpSup[1],30), PADR(aGrpSup[2],30)	,;
				PADR(aGrpSup[3],30)		, PADR(aGrpSup[4],30)	, PADR(aGrpSup[5],30)	, PADR(aGrpSup[6],30)	,;
				PADR(aGrpSup[7],30)		, PADR(aGrpSup[8],30)	, PADR(aGrpSup[9],30)	, PADR(aGrpSup[10],30)	,;
				PADR(aGrpSup[11],30)	, PADR(aGrpSup[12],30)	, PADR(aGrpSup[13],30)	, PADR(aGrpSup[14],30)	,;
				PADR(aGrpSup[15],30) ) 


	//���������������������������������������������Ŀ
	//� Refresh executado no TopConnect             �
	//�����������������������������������������������
	TcRefresh(RetArq("TOPCONN",RetSqlName("ADL"),.T.))
	DbSelectArea("SA3")

	//��������������������������������Ŀ
	//�Processa subordinados, se houver�
	//����������������������������������
	cNivel	:= AllTrim(SA3->A3_NVLSTR)
	nNivel	:= (Len(cNivel) / NTAMCOD) + 1

	cQuery	:= "SELECT A3_COD FROM " + RetSqlName("SA3") + " SA3 "
	If Alltrim(TcGetDB()) == "ORACLE" .Or. Alltrim(TcGetDB()) == "POSTGRES"
		cQuery 	+= "WHERE A3_FILIAL = '" + xFilial("SA3") + "' AND LPAD(A3_NVLSTR,"+cValToChar(Len(cNivel))+") = '"+cNivel+"' "
	Else
		cQuery 	+= "WHERE A3_FILIAL = '" + xFilial("SA3") + "' AND LEFT(A3_NVLSTR,"+cValToChar(Len(cNivel))+") = '"+cNivel+"' "
	EndIf
	cQuery	+= "AND A3_NIVEL >= " + cValToChar(nNivel) + " AND SA3.D_E_L_E_T_ = ' '"
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)
	DbGoTop()
	
	nRecSA3	:= SA3->(Recno())
	
	//���������������������������������������Ŀ
	//�Recursao para processar os subordinados�
	//�����������������������������������������
	While !(cAlias)->(Eof())
		Ft520Proce(Nil,(cAlias)->A3_COD,(cAlias)->A3_COD)
		(cAlias)->(DbSkip())
	End
	(cAlias)->(DbCloseArea())	
	
    SA3->(DbGoTo(nRecSA3))	
	
	SA3->(DbSkip())

End

FATPDLogUser('FT520PROCE')

RestArea(aArea)

//Finaliza o gerenciamento dos campos com prote��o de dados.
FATPDUnLoad()

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520DelDB�Autor  �Vendas CRM          � Data �  19/06/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Remove as amarracoes anteriores para o codigo informado no  ���
���          �parametro                                                   ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Codigo do vendedor a ser removido da ADL            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft520DelDB(cVend)

TcSqlExec("DELETE FROM " + RetSqlName("ADL") + " WHERE ADL_FILIAL = '" + xFilial("ADL") + "' AND ADL_VEND = '" + cVend + "'")

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520Sup  �Autor  �Vendas CRM          � Data �  23/06/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a lista de superiores do vendedor atual             ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Codigo inteligente do vendedor                      ���
���          �ExpL2 - Tambem retorna os vendedores do mesmo time se .T.   ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft520Sup(cCodInt,lTime)

Local aArea	  	 := GetArea()
Local aRet		 := {}
Local cQuery	 := ""
Local cUnion	 := ""
Local cAliasQry  := GetNextAlias()
Local cCodSup	 := ""
Local nNivel	 := 0
Local aNlvEstFmt := {}

Default lTime	:= .F.

If nModulo != 73
	cCodInt := AllTrim(cCodInt)	
	If lTime
		cCodSup	:= SubStr(cCodInt,1,Len(cCodInt))
	Else
		cCodSup	:= SubStr(cCodInt,1,Len(cCodInt)-NTAMCOD)
	EndIf

	While !Empty(cCodSup)
		cQuery	+= cUnion + "SELECT A3_COD,A3_NVLSTR,A3_CODUSR FROM " + RetSqlName("SA3")
		cQuery	+= " WHERE A3_FILIAL = '"+xFilial("SA3")+"' AND A3_NVLSTR = '" + cCodSup + "' AND D_E_L_E_T_ = ' '"
		cUnion	:= " UNION "
		cCodSup	:= SubStr(cCodSup,1,Len(cCodSup)-NTAMCOD)
	End
	If !Empty(cQuery)
		cQuery += " ORDER BY A3_NVLSTR DESC"
	EndIf	
Else
	
	aNlvEstFmt	:= CRMXFmtNvl(cCodInt)
	
	If !Empty(cCodInt) .And. Len(aNlvEstFmt) > 0
		cQuery := "SELECT AO3_CODUSR, AO3_IDESTN, AO3_VEND FROM " + RetSqlName( "AO3" )
		cQuery += " WHERE AO3_FILIAL = '" + xFilial( "AO3" ) + "' AND ("
		For nNivel := 1 To Len(aNlvEstFmt)
			cQuery += "AO3_IDESTN LIKE '" + aNlvEstFmt[nNivel] + "%' "
			If nNivel < Len(aNlvEstFmt)
				cQuery += " OR "
			EndIf
		Next
		cQuery += ") AND D_E_L_E_T_ = ' '"
	EndIf
	
EndIf

If !Empty(cQuery)
	
	cQuery	:= ChangeQuery(cQuery)
	
	If Select(cAliasQry) > 0
		(cAliasQry)->(DbCloseArea())
	EndIf
	
	DbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. ) 
	
	While (cAliasQry)->(!Eof())
		If nModulo != 73
			AAdd(aRet,{(cAliasQry)->A3_COD,(cAliasQry)->A3_NVLSTR,(cAliasQry)->A3_CODUSR})
		Else
			AAdd( aRet, { (cAliasQry)->AO3_VEND, (cAliasQry)->AO3_IDESTN, (cAliasQry)->AO3_CODUSR } )
		EndIf
		(cAliasQry)->(DbSkip())
	End
	
	(cAliasQry)->(DbCloseArea())

EndIf

RestArea(aArea)

Return aRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520Sub  �Autor  �Vendas CRM          � Data �  29/07/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a lista de subordinados do vendedor atual           ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Codigo inteligente do vendedor                      ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft520Sub(cCodInt)

Local aArea		 := GetArea()
Local aRet		 := {}
Local cQuery	 := ""
Local cAliasQry	 := GetNextAlias()
Local nLenCod	 := 0
Local nNivel	 := 0
Local aNlvEstFmt := {}

aNlvEstFmt := CRMXFmtNvl( SubStr( cCodInt, 0, Len( cCodInt ) - NTAMCOD ) )
cCodInt    := AllTrim( cCodInt )
nLenCod    := Len( cCodInt )

If nModulo != 73
	cQuery	:= "SELECT A3_COD FROM " + RetSqlName("SA3")
	If Alltrim(TcGetDB()) == "ORACLE" .Or. Alltrim(TcGetDB()) == "POSTGRES"
		cQuery	+= " WHERE A3_FILIAL = '"+xFilial("SA3")+"' AND LPAD(A3_NVLSTR,"+cValToChar(nLenCod)+") >= '" + cCodInt + "' AND A3_NIVEL > "+cValToChar(nLenCod/NTAMCOD)+" AND D_E_L_E_T_ = ' '"
	ElseIf Alltrim(TcGetDB()) == "INFORMIX"
		cQuery	+= " WHERE A3_FILIAL = '"+xFilial("SA3")+"' AND SUBSTR(A3_NVLSTR,"+cValToChar(nLenCod)+") >= '" + cCodInt + "' AND A3_NIVEL > "+cValToChar(nLenCod/NTAMCOD)+" AND D_E_L_E_T_ = ' '"
	Else
		cQuery	+= " WHERE A3_FILIAL = '"+xFilial("SA3")+"' AND LEFT(A3_NVLSTR,"+cValToChar(nLenCod)+") >= '" + cCodInt + "' AND A3_NIVEL > "+cValToChar(nLenCod/NTAMCOD)+" AND D_E_L_E_T_ = ' '"
	EndIf
Else
	cQuery := "SELECT AO3_VEND FROM " + RetSqlName("AO3") "
	cQuery += " WHERE AO3_FILIAL = '" + xFilial( "AO3" ) + "' AND ("
	If Len(aNlvEstFmt) = 0
		Aadd(aNlvEstFmt, Replicate("X", Len(AO3->AO3_IDESTN)))
	EndIf
	For nNivel := 1 To Len(aNlvEstFmt)
		cQuery += "AO3_IDESTN LIKE '" + aNlvEstFmt[nNivel] + "%' "
		If nNivel < Len(aNlvEstFmt)
			cQuery += " OR "
		EndIf
	Next
	cQuery += ") AND D_E_L_E_T_ = ' ' "
EndIf
	
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

While !Eof()
	If nModulo != 73
		aAdd(aRet,(cAliasQry)->A3_COD)
	Else
		aAdd(aRet,(cAliasQry)->AO3_VEND)
	EndIf
	(cAliasQry)->(DbSkip())
End

DbCloseArea()

RestArea(aArea)

Return aRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520CrPro�Autor  �Vendas CRM          � Data �  25/06/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Criacao da procedure de processamento do vendedor           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Nome da procedure criada (referencia)               ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft520CrPro()

Local lRet		:= .T.
Local nRet		:= 0 
Local nX		:= 0
Local cProc		:= "" 
Local cSaida	:= ""
Local cErro		:= ""   
Local cProcVer	:= ""
Local cVerAtu	:= "0.7"
Local aResult	:= {}
Local nTamEnt	:= TamSX3("ADL_CODENT")[1] 
Local nTamLoj	:= TamSX3("ADL_LOJENT")[1]  
Local nTamNom	:= TamSX3("ADL_NOME")[1]    
Local nTamCGC	:= TamSX3("ADL_CGC")[1] 

cProcVer	:= StrTran("REPADLVER" + cEmpAnt + cFilAnt," ")

//������������������������������������������������������������Ŀ
//�Verifica se a procedure existente atualmente esta atualizada�
//��������������������������������������������������������������
If TCSPExist(cProcVer) .AND. TCSPExist(cProcName)
	aResult := TCSPExec(cProcVer)
	If AllTrim(aResult[1]) == 'N'
		Return .T.
	EndIf
EndIf

//��������������������������������������Ŀ
//�Apaga procedures anteriores, se houver�
//����������������������������������������
For nX := 1 to 2

	If nX == 1
		cProc := cProcName
	Else
		cProc := cProcVer
	EndIf

	If TCSPExist(cProc)
		nRet := TcSqlExec("DROP PROCEDURE "+cProc)
		If nRet <> 0 
			If !IsBlind()
				MsgAlert("ERRO EXCLUSAO DA PROCEDURE "+cProc)  //'Erro na exclusao da procedure'
			EndIf
			Return .F.
		EndIf
	EndIf 

Next nX

//��������������������������������������Ŀ
//�Cria a procedure de controle de versao�
//����������������������������������������
cProc := "CREATE PROC " +cProcVer + CRLF
cProc += "( @OUT_VERSAO Char(3) OUTPUT) as" + CRLF
cProc += "begin" + CRLF
cProc += "Select @OUT_VERSAO = '"+cVerAtu+"'" + CRLF
cProc += "end" + CRLF

cSaida 	:= MsParse(cProc,Alltrim(TcGetDB()))
cErro	:= MsParseError()

//�����������������������������Ŀ
//�Criacao da procedure no banco�
//�������������������������������
If Len(cErro) == 0
	If (nRet :=TcSqlExec(cSaida)) <> 0
		lRet := .F.
	EndIf 
Else
	lRet := .F.
EndIf

If !lRet
	If !IsBlind()
		MsgAlert(STR0008 + TCSQLError()) //"Erro na criacao da procedure:"
	EndIf
EndIf    

//�����������������������������Ŀ
//�Criacao do texto da procedure�
//�������������������������������
//������������������������������������������������������������������������������������Ŀ
//�##################################### ATENCAO ######################################�
//�Ao modificar o corpo da procedure abaixo, atualizar a variavel cVerAtu com um codigo�
//�acima do atual, por exemplo 0.1 -> 0.2, para que ao executar o programa a procedure �
//�seja automaticamente atualizada                                                     �
//��������������������������������������������������������������������������������������
cProc := "CREATE PROC " + cProcName + " ("+CRLF
cProc += "@CVENDEDOR VARCHAR(6),"+CRLF
cProc += "@CCODINT01 VARCHAR(30),"+CRLF
cProc += "@CCODINT02 VARCHAR(30),"+CRLF
cProc += "@CCODINT03 VARCHAR(30),"+CRLF
cProc += "@CCODINT04 VARCHAR(30),"+CRLF
cProc += "@CCODINT05 VARCHAR(30),"+CRLF
cProc += "@CCODINT06 VARCHAR(30),"+CRLF
cProc += "@CCODINT07 VARCHAR(30),"+CRLF
cProc += "@CCODINT08 VARCHAR(30),"+CRLF
cProc += "@CCODINT09 VARCHAR(30),"+CRLF
cProc += "@CCODINT10 VARCHAR(30),"+CRLF
cProc += "@CCODINT11 VARCHAR(30),"+CRLF
cProc += "@CCODINT12 VARCHAR(30),"+CRLF
cProc += "@CCODINT13 VARCHAR(30),"+CRLF
cProc += "@CCODINT14 VARCHAR(30),"+CRLF
cProc += "@CCODINT15 VARCHAR(30)"+CRLF
cProc += ") AS"+CRLF

cProc += "Declare @iRecno	INTEGER"+CRLF
cProc += "DECLARE @CODVEN	VARCHAR(6)"+CRLF
cProc += "DECLARE @CODENT	VARCHAR("+Str(nTamEnt)+")"+CRLF
cProc += "DECLARE @LOJENT	VARCHAR("+Str(nTamLoj)+")"+CRLF
cProc += "DECLARE @NOME	VARCHAR("+Str(nTamNom)+")"+CRLF
cProc += "DECLARE @CGC	VARCHAR("+Str(nTamCGC)+")"+CRLF

//Seleciona os superiores do vendedor corrente
cProc += "DECLARE CUR_SA3 INSENSITIVE CURSOR FOR"+CRLF
cProc += "	SELECT A3_COD FROM "+RetSqlName("SA3")+" WHERE A3_FILIAL = '"+xFilial("SA3")+"' AND A3_NVLSTR <> '" + Space(TamSX3("A3_NVLSTR")[1]) + "' "+CRLF   
//Desativado pois o 'IN' nao eh suportado na MsParse
//cProc += "	AND A3_NVLSTR IN (@CCODINT01,@CCODINT02,@CCODINT03,@CCODINT04,@CCODINT05,@CCODINT06,@CCODINT07,@CCODINT08,@CCODINT09,@CCODINT10,@CCODINT11,@CCODINT12,@CCODINT13,@CCODINT14,@CCODINT15)"+CRLF
cProc += " AND (A3_NVLSTR = @CCODINT01 OR A3_NVLSTR = @CCODINT02 OR A3_NVLSTR = @CCODINT03 OR A3_NVLSTR = @CCODINT04 "
cProc += 		"OR A3_NVLSTR = @CCODINT05 OR A3_NVLSTR = @CCODINT06 OR A3_NVLSTR = @CCODINT07 OR A3_NVLSTR = @CCODINT08 "
cProc += 		"OR A3_NVLSTR = @CCODINT09 OR A3_NVLSTR = @CCODINT10 OR A3_NVLSTR = @CCODINT11 OR A3_NVLSTR = @CCODINT12 "
cProc += 		"OR A3_NVLSTR = @CCODINT13 OR A3_NVLSTR = @CCODINT14 OR A3_NVLSTR = @CCODINT15) "

cProc += "	AND D_E_L_E_T_ = ' '"+CRLF
cProc += "FOR READ ONLY"+CRLF

//Lista de clientes das oportunidades do vendedor atual
cProc += "DECLARE CUR_AD1SA1 INSENSITIVE CURSOR FOR"+CRLF
cProc += "	SELECT AD1_CODCLI, AD1_LOJCLI, SUBSTRING(A1_NOME,1,"+Str(nTamNom)+"),SUBSTRING(A1_CGC,1,"+Str(nTamCGC)+")"+CRLF
cProc += "	FROM "+RetSqlName("AD1")+" AD1"+CRLF
cProc += "	INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = AD1_CODCLI AND A1_LOJA = AD1_LOJCLI AND SA1.D_E_L_E_T_= ' '"+CRLF
cProc += "	WHERE AD1_FILIAL = '"+xFilial("AD1")+"' AND AD1_VEND = @CVENDEDOR AND AD1_CODCLI <> '"+Space(nTamEnt)+"' AND AD1_DTFIM = '' AND AD1.D_E_L_E_T_ = ' '"+CRLF
cProc += "  AND NOT EXISTS(SELECT 1 FROM "+RetSqlName("ADL")+" ADL WHERE ADL_FILIAL = '"+xFilial("ADL")+"' AND ADL_VEND = @CVENDEDOR AND ADL_FILENT = A1_FILIAL AND ADL_ENTIDA = 'SA1' AND ADL_CODENT = A1_COD AND ADL_LOJENT = A1_LOJA AND ADL.D_E_L_E_T_ = ' ')"+CRLF
cProc += "	UNION"+CRLF
cProc += "	SELECT AD1_CODCLI, AD1_LOJCLI, SUBSTRING(A1_NOME,1,"+Str(nTamNom)+"),SUBSTRING(A1_CGC,1,"+Str(nTamCGC)+")"+CRLF
cProc += "	FROM "+RetSqlName("AD1")+" AD1"+CRLF
cProc += "	INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = AD1_CODCLI AND A1_LOJA = AD1_LOJCLI AND SA1.D_E_L_E_T_= ' '"+CRLF
cProc += "	INNER JOIN "+RetSqlName("AD2")+" AD2 ON AD2_FILIAL = '"+xFilial("AD2")+"' AND AD1.AD1_NROPOR = AD2.AD2_NROPOR AND"+CRLF
cProc += "	AD1.AD1_REVISA = AD2.AD2_REVISA AND AD2_VEND = @CVENDEDOR AND AD2.D_E_L_E_T_ = ' '"+CRLF
cProc += "	WHERE AD1_FILIAL = '"+xFilial("AD1")+"' AND AD1_CODCLI <> '"+Space(nTamEnt)+"' AND AD1_DTFIM = '' AND AD1.D_E_L_E_T_ = ' '"+CRLF
cProc += "  AND NOT EXISTS(SELECT 1 FROM "+RetSqlName("ADL")+" ADL WHERE ADL_FILIAL = '"+xFilial("ADL")+"' AND ADL_VEND = @CVENDEDOR AND ADL_FILENT = A1_FILIAL AND ADL_ENTIDA = 'SA1' AND ADL_CODENT = A1_COD AND ADL_LOJENT = A1_LOJA AND ADL.D_E_L_E_T_ = ' ')"+CRLF
cProc += "FOR READ ONLY"+CRLF

//PROCESSA OS CLIENTES DAS OPORTUNIDADES
cProc += "Select @iRecno = IsNull( Max( R_E_C_N_O_ ), 0 ) From "+RetSqlName("ADL")+CRLF
cProc += "OPEN CUR_AD1SA1"+CRLF
cProc += "FETCH CUR_AD1SA1 INTO @CODENT,@LOJENT,@NOME,@CGC"+CRLF
cProc += "WHILE (@CODENT <> '"+Space(nTamEnt)+"') BEGIN"+CRLF
cProc += "	Select @iRecno = @iRecno + 1"+CRLF
cProc += "	INSERT INTO "+RetSqlName("ADL")+" (ADL_FILIAL,ADL_VEND,ADL_FILENT,ADL_ENTIDA,ADL_CODENT,ADL_LOJENT,ADL_NOME,ADL_CGC,R_E_C_N_O_)"+CRLF
cProc += "	VALUES('"+xFilial("ADL")+"',@CVENDEDOR,'"+xFilial("SA1")+"','SA1',@CODENT,@LOJENT,@NOME,@CGC,@iRecno)"+CRLF
cProc += "	OPEN CUR_SA3"+CRLF
cProc += "	FETCH CUR_SA3 INTO @CODVEN"+CRLF
cProc += "	WHILE (@CODVEN <> '"+Space(nTamEnt)+"') BEGIN"+CRLF
cProc += "		IF NOT EXISTS(Select 1 FROM "+RetSqlName("ADL")+" WHERE ADL_FILIAL = '"+xFilial("ADL")+"' AND ADL_VEND = @CODVEN AND ADL_FILENT = '"+xFilial("SA1")+"' AND ADL_ENTIDA = 'SA1' AND ADL_CODENT = @CODENT AND ADL_LOJENT = @LOJENT AND D_E_L_E_T_ = ' ') BEGIN"+CRLF
cProc += "			Select @iRecno = @iRecno + 1"+CRLF
cProc += "			INSERT INTO "+RetSqlName("ADL")+" (ADL_FILIAL,ADL_VEND,ADL_FILENT,ADL_ENTIDA,ADL_CODENT,ADL_LOJENT,ADL_NOME,ADL_CGC,R_E_C_N_O_)"+CRLF
cProc += "			VALUES('"+xFilial("ADL")+"',@CODVEN,'"+xFilial("SA1")+"','SA1',@CODENT,@LOJENT,@NOME,@CGC,@iRecno)"+CRLF
cProc += "		END"+CRLF
cProc += "		Select @CODVEN = '"+Space(nTamEnt)+"'"+CRLF
cProc += "		FETCH CUR_SA3 INTO @CODVEN"+CRLF
cProc += "	END"+CRLF                   
cProc += "	Select @CODENT = '"+Space(nTamEnt)+"'"+CRLF
cProc += "	CLOSE CUR_SA3"+CRLF
cProc += "	FETCH CUR_AD1SA1 INTO @CODENT,@LOJENT,@NOME,@CGC"+CRLF
cProc += "END"+CRLF
cProc += "CLOSE CUR_AD1SA1"+CRLF
cProc += "DEALLOCATE CUR_AD1SA1"+CRLF

//Lista de prospects das oportunidades do vendedor atual
cProc += "DECLARE CUR_AD1SUS INSENSITIVE CURSOR FOR"+CRLF
cProc += "	SELECT AD1_PROSPE, AD1_LOJPRO,  SUBSTRING(US_NOME,1,"+Str(nTamNom)+"),SUBSTRING(US_CGC,1,"+Str(nTamCGC)+")"+CRLF
cProc += "	FROM "+RetSqlName("AD1")+" AD1"+CRLF
cProc += "	INNER JOIN "+RetSqlName("SUS")+" SUS ON US_FILIAL = '"+xFilial("SUS")+"' AND US_COD = AD1_PROSPE AND US_LOJA = AD1_LOJPRO AND US_CODCLI = ' ' AND SUS.D_E_L_E_T_= ' '"+CRLF
cProc += "	WHERE AD1_FILIAL = '"+xFilial("AD1")+"' AND AD1_VEND = @CVENDEDOR AND AD1_PROSPE <> '"+Space(nTamEnt)+"' AND AD1.D_E_L_E_T_ = ' '"+CRLF
cProc += "  AND NOT EXISTS(SELECT 1 FROM "+RetSqlName("ADL")+" ADL WHERE ADL_FILIAL = '"+xFilial("ADL")+"' AND ADL_VEND = @CVENDEDOR AND ADL_FILENT = US_FILIAL AND ADL_ENTIDA = 'SUS' AND ADL_CODENT = US_COD AND ADL_LOJENT = US_LOJA AND ADL.D_E_L_E_T_ = ' ')"+CRLF
cProc += "	UNION"+CRLF
cProc += "	SELECT AD1_PROSPE, AD1_LOJPRO, SUBSTRING(US_NOME,1,"+Str(nTamNom)+"),SUBSTRING(US_CGC,1,"+Str(nTamCGC)+")"+CRLF
cProc += "	FROM "+RetSqlName("AD1")+" AD1"+CRLF
cProc += "	INNER JOIN "+RetSqlName("SUS")+" SUS ON US_FILIAL = '"+xFilial("SUS")+"' AND US_COD = AD1_PROSPE AND US_LOJA = AD1_LOJPRO AND US_CODCLI = '"+Space(nTamEnt)+"' AND SUS.D_E_L_E_T_= ' '"+CRLF
cProc += "	INNER JOIN "+RetSqlName("AD2")+" AD2 ON AD2.AD2_FILIAL = '"+xFilial("AD1")+"' AND AD1.AD1_NROPOR = AD2.AD2_NROPOR AND"+CRLF
cProc += "	AD1.AD1_FILIAL = '"+xFilial("AD1")+"' AND AD1.AD1_REVISA = AD2.AD2_REVISA AND AD2_VEND = @CVENDEDOR AND AD2.D_E_L_E_T_ = ' '"+CRLF
cProc += "	WHERE AD1_FILIAL = '"+xFilial("AD1")+"' AND AD1_PROSPE <> '"+Space(nTamEnt)+"' AND AD1.D_E_L_E_T_ = ' '"+CRLF
cProc += "  AND NOT EXISTS(SELECT 1 FROM "+RetSqlName("ADL")+" ADL WHERE ADL_FILIAL = '"+xFilial("ADL")+"' AND ADL_VEND = @CVENDEDOR AND ADL_FILENT = US_FILIAL AND ADL_ENTIDA = 'SUS' AND ADL_CODENT = US_COD AND ADL_LOJENT = US_LOJA AND ADL.D_E_L_E_T_ = ' ')"+CRLF
cProc += "FOR READ ONLY"+CRLF

//PROCESSA OS PROSPECTS DAS OPORTUNIDADES
cProc += "Select @iRecno = IsNull( Max( R_E_C_N_O_ ), 0 ) From "+RetSqlName("ADL")+CRLF
cProc += "OPEN CUR_AD1SUS"+CRLF
cProc += "FETCH CUR_AD1SUS INTO @CODENT,@LOJENT,@NOME,@CGC"+CRLF
cProc += "WHILE (@CODENT <> '"+Space(nTamEnt)+"') BEGIN"+CRLF
cProc += "	Select @iRecno = @iRecno + 1"+CRLF
cProc += "	INSERT INTO "+RetSqlName("ADL")+" (ADL_FILIAL,ADL_VEND,ADL_FILENT,ADL_ENTIDA,ADL_CODENT,ADL_LOJENT,ADL_NOME,ADL_CGC,R_E_C_N_O_)"+CRLF
cProc += "	VALUES('"+xFilial("ADL")+"',@CVENDEDOR,'"+xFilial("SUS")+"','SUS',@CODENT,@LOJENT,@NOME,@CGC,@iRecno)"+CRLF
cProc += "	OPEN CUR_SA3"+CRLF
cProc += "	FETCH CUR_SA3 INTO @CODVEN"+CRLF
cProc += "	WHILE (@CODVEN <> '"+Space(nTamEnt)+"') BEGIN"+CRLF
cProc += "		IF NOT EXISTS(Select 1 FROM "+RetSqlName("ADL")+" WHERE ADL_FILIAL = '"+xFilial("ADL")+"' AND ADL_VEND = @CODVEN AND ADL_FILENT = '"+xFilial("SUS")+"' AND ADL_ENTIDA = 'SUS' AND ADL_CODENT = @CODENT AND ADL_LOJENT = @LOJENT AND D_E_L_E_T_ = ' ' ) BEGIN"+CRLF
cProc += "			Select @iRecno = @iRecno + 1"+CRLF
cProc += "			INSERT INTO "+RetSqlName("ADL")+" (ADL_FILIAL,ADL_VEND,ADL_FILENT,ADL_ENTIDA,ADL_CODENT,ADL_LOJENT,ADL_NOME,ADL_CGC,R_E_C_N_O_)"+CRLF
cProc += "			VALUES('"+xFilial("ADL")+"',@CODVEN,'"+xFilial("SUS")+"','SUS',@CODENT,@LOJENT,@NOME,@CGC,@iRecno)"+CRLF
cProc += "		END"+CRLF      
cProc += "		Select @CODVEN = '"+Space(nTamEnt)+"'"+CRLF
cProc += "		FETCH CUR_SA3 INTO @CODVEN"+CRLF
cProc += "	END"+CRLF        
cProc += "  Select @CODENT = '"+Space(nTamEnt)+"'"+CRLF
cProc += "	CLOSE CUR_SA3"+CRLF
cProc += "	FETCH CUR_AD1SUS INTO @CODENT,@LOJENT,@NOME,@CGC"+CRLF
cProc += "END"+CRLF          
cProc += "CLOSE CUR_AD1SUS"+CRLF
cProc += "DEALLOCATE CUR_AD1SUS"+CRLF

//Lista de clientes do vendedor atual
cProc += "DECLARE CUR_A1 INSENSITIVE CURSOR FOR"+CRLF
cProc += "	SELECT A1_COD, A1_LOJA, SUBSTRING(A1_NOME,1,"+Str(nTamNom)+"),SUBSTRING(A1_CGC,1,"+Str(nTamCGC)+")"+CRLF
cProc += "	FROM "+RetSqlName("SA1")+CRLF
cProc += "	WHERE A1_FILIAL = '"+xFilial("SA1")+"' AND  A1_VEND = @CVENDEDOR AND D_E_L_E_T_ = ' '"+CRLF
cProc += "		AND NOT EXISTS (SELECT 1 FROM "+RetSqlName("ADL")+" WHERE ADL_FILIAL = '"+xFilial("ADL")+"' AND ADL_VEND = @CVENDEDOR "+CRLF
cProc += "						AND ADL_FILENT = '"+xFilial("SA1")+"' AND ADL_ENTIDA = 'SA1' AND ADL_CODENT = A1_COD "+CRLF
cProc += "						AND ADL_LOJENT = A1_LOJA AND D_E_L_E_T_ = ' ' )"+CRLF
cProc += "FOR READ ONLY"+CRLF

//PROCESSA OS CLIENTES
cProc += "Select @iRecno = IsNull( Max( R_E_C_N_O_ ), 0 ) From "+RetSqlName("ADL")+CRLF
cProc += "OPEN CUR_A1"+CRLF
cProc += "FETCH CUR_A1 INTO @CODENT,@LOJENT,@NOME,@CGC"+CRLF
cProc += "WHILE (@CODENT <> '"+Space(nTamEnt)+"') BEGIN"+CRLF
cProc += "	Select @iRecno = @iRecno + 1"+CRLF
cProc += "	INSERT INTO "+RetSqlName("ADL")+" (ADL_FILIAL,ADL_VEND,ADL_FILENT,ADL_ENTIDA,ADL_CODENT,ADL_LOJENT,ADL_NOME,ADL_CGC,R_E_C_N_O_)"+CRLF
cProc += "	VALUES('"+xFilial("ADL")+"',@CVENDEDOR,'"+xFilial("SA1")+"','SA1',@CODENT,@LOJENT,@NOME,@CGC,@iRecno)"+CRLF
cProc += "	OPEN CUR_SA3"+CRLF
cProc += "	FETCH CUR_SA3 INTO @CODVEN"+CRLF
cProc += "	WHILE (@CODVEN <> '"+Space(nTamEnt)+"') BEGIN"+CRLF
cProc += "		IF NOT EXISTS(Select 1 FROM "+RetSqlName("ADL")+" WHERE ADL_FILIAL = '"+xFilial("ADL")+"' AND ADL_VEND = @CODVEN AND ADL_FILENT = '"+xFilial("SA1")+"' AND ADL_ENTIDA = 'SA1' AND ADL_CODENT = @CODENT AND ADL_LOJENT = @LOJENT AND D_E_L_E_T_ = ' ') BEGIN"+CRLF
cProc += "			Select @iRecno = @iRecno + 1"+CRLF
cProc += "			INSERT INTO "+RetSqlName("ADL")+" (ADL_FILIAL,ADL_VEND,ADL_FILENT,ADL_ENTIDA,ADL_CODENT,ADL_LOJENT,ADL_NOME,ADL_CGC,R_E_C_N_O_)"+CRLF
cProc += "			VALUES('"+xFilial("ADL")+"',@CODVEN,'"+xFilial("SA1")+"','SA1',@CODENT,@LOJENT,@NOME,@CGC,@iRecno)"+CRLF
cProc += "		END"+CRLF      
cProc += "		Select @CODVEN = '"+Space(nTamEnt)+"'"+CRLF
cProc += "		FETCH CUR_SA3 INTO @CODVEN"+CRLF
cProc += "	END"+CRLF                   
cProc += "  Select @CODENT = '"+Space(nTamEnt)+"'"+CRLF
cProc += "	CLOSE CUR_SA3"+CRLF
cProc += "	FETCH CUR_A1 INTO @CODENT,@LOJENT,@NOME,@CGC"+CRLF
cProc += "END"+CRLF                     
cProc += "CLOSE CUR_A1"+CRLF
cProc += "DEALLOCATE CUR_A1"+CRLF

//Lista de prospects do vendedor atual
cProc += "DECLARE CUR_US INSENSITIVE CURSOR FOR"+CRLF
cProc += "	SELECT US_COD, US_LOJA, SUBSTRING(US_NOME,1,"+Str(nTamNom)+"),SUBSTRING(US_CGC,1,"+Str(nTamCGC)+")"+CRLF
cProc += "	FROM "+RetSqlName("SUS")+CRLF
cProc += "	WHERE US_FILIAL = '"+xFilial("SUS")+"' AND US_VEND = @CVENDEDOR AND US_CODCLI = '"+Space(nTamEnt)+"' AND D_E_L_E_T_ = ' '"+CRLF
cProc += "		AND NOT EXISTS (SELECT 1 FROM "+RetSqlName("ADL")+" WHERE ADL_FILIAL = '"+xFilial("ADL")+"' AND ADL_VEND = @CVENDEDOR "+CRLF
cProc += "						AND ADL_FILENT = '"+xFilial("SUS")+"' AND ADL_ENTIDA = 'SUS' AND ADL_CODENT = US_COD "+CRLF
cProc += "						AND ADL_LOJENT = US_LOJA AND D_E_L_E_T_ = ' ')"+CRLF
cProc += "FOR READ ONLY"+CRLF

//PROCESSA OS PROSPECTS
cProc += "Select @iRecno = IsNull( Max( R_E_C_N_O_ ), 0 ) From "+RetSqlName("ADL")+CRLF
cProc += "OPEN CUR_US"+CRLF
cProc += "FETCH CUR_US INTO @CODENT,@LOJENT,@NOME,@CGC"+CRLF
cProc += "WHILE (@CODENT <> '"+Space(nTamEnt)+"') BEGIN"+CRLF
cProc += "	Select @iRecno = @iRecno + 1"+CRLF
cProc += "	INSERT INTO "+RetSqlName("ADL")+" (ADL_FILIAL,ADL_VEND,ADL_FILENT,ADL_ENTIDA,ADL_CODENT,ADL_LOJENT,ADL_NOME,ADL_CGC,R_E_C_N_O_)"+CRLF
cProc += "	VALUES('"+xFilial("ADL")+"',@CVENDEDOR,'"+xFilial("SUS")+"','SUS',@CODENT,@LOJENT,@NOME,@CGC,@iRecno)"+CRLF
cProc += "	OPEN CUR_SA3"+CRLF
cProc += "	FETCH CUR_SA3 INTO @CODVEN"+CRLF
cProc += "	WHILE (@CODVEN <> '"+Space(nTamEnt)+"') BEGIN"+CRLF
cProc += "		IF NOT EXISTS(Select 1 FROM "+RetSqlName("ADL")+" WHERE ADL_FILIAL = '"+xFilial("ADL")+"' AND ADL_VEND = @CODVEN AND ADL_FILENT = '"+xFilial("SUS")+"' AND ADL_ENTIDA = 'SUS' AND ADL_CODENT = @CODENT AND ADL_LOJENT = @LOJENT AND D_E_L_E_T_ = ' ') BEGIN"+CRLF
cProc += "			Select @iRecno = @iRecno + 1"+CRLF
cProc += "			INSERT INTO "+RetSqlName("ADL")+" (ADL_FILIAL,ADL_VEND,ADL_FILENT,ADL_ENTIDA,ADL_CODENT,ADL_LOJENT,ADL_NOME,ADL_CGC,R_E_C_N_O_)"+CRLF
cProc += "			VALUES('"+xFilial("ADL")+"',@CODVEN,'"+xFilial("SUS")+"','SUS',@CODENT,@LOJENT,@NOME,@CGC,@iRecno)"+CRLF
cProc += "		END"+CRLF   
cProc += "		Select @CODVEN = '"+Space(nTamEnt)+"'"+CRLF
cProc += "		FETCH CUR_SA3 INTO @CODVEN"+CRLF
cProc += "	END"+CRLF                    
cProc += "	Select @CODENT = '"+Space(nTamEnt)+"'"+CRLF
cProc += "	CLOSE CUR_SA3"+CRLF
cProc += "	FETCH CUR_US INTO @CODENT,@LOJENT,@NOME,@CGC"+CRLF
cProc += "END"+CRLF
cProc += "CLOSE CUR_US"+CRLF
cProc += "DEALLOCATE CUR_US"+CRLF

//Lista de suspects do vendedor atual
cProc += "DECLARE CUR_ACH INSENSITIVE CURSOR FOR"+CRLF
cProc += "	SELECT ACH_CODIGO, ACH_LOJA, SUBSTRING(ACH_RAZAO,1,"+Str(nTamNom)+"),SUBSTRING(ACH_CGC,1,"+Str(nTamCGC)+")"+CRLF
cProc += "	FROM "+RetSqlName("ACH")+CRLF
cProc += "	WHERE ACH_FILIAL = '"+xFilial("ACH")+"' AND ACH_VEND = @CVENDEDOR AND ACH_CODPRO = '"+Space(nTamEnt)+"' AND D_E_L_E_T_ = ' '"+CRLF
cProc += "		AND NOT EXISTS (SELECT 1 FROM "+RetSqlName("ADL")+" WHERE ADL_FILIAL = '"+xFilial("ADL")+"' AND ADL_VEND = @CVENDEDOR "+CRLF
cProc += "						AND ADL_FILENT = '"+xFilial("ACH")+"' AND ADL_ENTIDA = 'ACH' AND ADL_CODENT = ACH_CODIGO "+CRLF
cProc += "						AND ADL_LOJENT = ACH_LOJA AND D_E_L_E_T_ = ' ')"+CRLF
cProc += "FOR READ ONLY"+CRLF

//Processa os suspects
cProc += "Select @iRecno = IsNull( Max( R_E_C_N_O_ ), 0 ) From "+RetSqlName("ADL")+CRLF
cProc += "OPEN CUR_ACH"+CRLF
cProc += "FETCH CUR_ACH INTO @CODENT,@LOJENT,@NOME,@CGC"+CRLF
cProc += "WHILE (@CODENT <> '"+Space(nTamEnt)+"') BEGIN"+CRLF
cProc += "	Select @iRecno = @iRecno + 1"+CRLF
cProc += "	INSERT INTO "+RetSqlName("ADL")+" (ADL_FILIAL,ADL_VEND,ADL_FILENT,ADL_ENTIDA,ADL_CODENT,ADL_LOJENT,ADL_NOME,ADL_CGC,R_E_C_N_O_)"+CRLF
cProc += "	VALUES('"+xFilial("ADL")+"',@CVENDEDOR,'"+xFilial("ACH")+"','ACH',@CODENT,@LOJENT,@NOME,@CGC,@iRecno)"+CRLF
cProc += "	OPEN CUR_SA3"+CRLF
cProc += "	FETCH CUR_SA3 INTO @CODVEN"+CRLF
cProc += "	WHILE (@CODVEN <> '"+Space(nTamEnt)+"') BEGIN"+CRLF
cProc += "		IF NOT EXISTS(Select 1 FROM "+RetSqlName("ADL")+" WHERE ADL_FILIAL = '"+xFilial("ADL")+"' AND ADL_VEND = @CODVEN AND ADL_FILENT = '"+xFilial("ACH")+"' AND ADL_ENTIDA = 'ACH' AND ADL_CODENT = @CODENT AND ADL_LOJENT = @LOJENT AND D_E_L_E_T_ = ' ' ) BEGIN"+CRLF
cProc += "			Select @iRecno = @iRecno + 1"+CRLF
cProc += "			INSERT INTO "+RetSqlName("ADL")+" (ADL_FILIAL,ADL_VEND,ADL_FILENT,ADL_ENTIDA,ADL_CODENT,ADL_LOJENT,ADL_NOME,ADL_CGC,R_E_C_N_O_)"+CRLF
cProc += "			VALUES('"+xFilial("ADL")+"',@CODVEN,'"+xFilial("ACH")+"','ACH',@CODENT,@LOJENT,@NOME,@CGC,@iRecno)"+CRLF
cProc += "		END"+CRLF
cProc += "		Select @CODVEN = '"+Space(nTamEnt)+"'"+CRLF
cProc += "		FETCH CUR_SA3 INTO @CODVEN"+CRLF
cProc += "	END"+CRLF          
cProc += "	Select @CODENT = '"+Space(nTamEnt)+"'"+CRLF
cProc += "	CLOSE CUR_SA3"+CRLF
cProc += "	FETCH CUR_ACH INTO @CODENT,@LOJENT,@NOME,@CGC"+CRLF
cProc += "END"+CRLF
cProc += "CLOSE CUR_ACH"+CRLF
cProc += "DEALLOCATE CUR_ACH"+CRLF
cProc += "DEALLOCATE CUR_SA3"

cSaida 	:= MsParse(cProc,Alltrim(TcGetDB()))
cErro	:= MsParseError()

//�����������������������������Ŀ
//�Criacao da procedure no banco�
//�������������������������������
If Len(cErro) == 0
	If (nRet :=TcSqlExec(cSaida)) <> 0
		lRet := .F.
	EndIf 
Else
	lRet := .F.
EndIf

If !lRet
	If !IsBlind()
		MsgAlert(STR0008 + TCSQLError()) //"Erro na criacao da procedure:"
	EndIf
EndIf     

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520Relac�Autor  �Microsiga           � Data �  01/07/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se existe relacionamento para o vendedor atual,    ���
���          �para a entidade fornecida                                   ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Vendedor a ser verificado                           ���
���          �ExpC2 - Alias da entidade a ser validada                    ���
���          �ExpC3 - Codigo da entidade a ser validada                   ���
���          �ExpC4 - Loja da entidade a ser validada                     ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft520Relac(cVend,cEnt,cCodigo,cLoja)

Local aArea		:= GetArea()
Local aAreaSA3	:= SA3->(GetArea())
Local cQuery	:= ""
Local cAliasTmp	:= "AD1AD2T" 
Local cCampo	:= ""
Local cCodInt	:= ""
Local nNivel	:= 0
Local lRet		:= .F.
 
DbSelectArea("SA3")
DbSetOrder(1)
DbSeek(xFilial("SA3")+cVend) 

cCodInt := AllTrim(SA3->A3_NVLSTR)
nNivel	:= (Len(cCodInt) / NTAMCOD) + 1

//�������������������Ŀ
//�Varre oportunidades�
//���������������������
If cEnt <> "ACH"

   	cQuery := "SELECT 1 RETORNO "

	If Alltrim(TcGetDB()) == "DB2"
		cQuery += " FROM TABLE (VALUES 1) AS TBX "
	ElseIf Alltrim(TcGetDB()) == "ORACLE"
		cQuery += " FROM DUAL "  
	Else 		
		cQuery += " FROM "+ RetSqlName('AD1') +" TBX "  
  	EndIf
	
	//Procura no cabecalho
	cQuery += "WHERE (EXISTS(SELECT 1 FROM "+RetSqlName("AD1")
	cQuery += " WHERE AD1_FILIAL = '" + xFilial("AD1") + "' AND AD1_VEND = '"+cVend+"' AND AD1_DTFIM = '' AND D_E_L_E_T_=' ' "
	If cEnt == "SUS"
		cQuery	+= " AND AD1_PROSPE = '"+cCodigo+"' AND AD1_LOJPRO = '"+cLoja+"')"
	Else
		cQuery	+= " AND AD1_CODCLI = '"+cCodigo+"' AND AD1_LOJCLI = '"+cLoja+"')"
	EndIf
	
	//Procura nos itens
	cQuery	+= " OR EXISTS(SELECT 1 FROM "+RetSqlName("AD1")+" AD1"
	cQuery	+= " INNER JOIN "+RetSqlName("AD2")+" AD2 ON AD2_FILIAL = '" + xFilial("AD2") + "'"
	cQuery	+= " AND AD2_NROPOR = AD1_NROPOR AND AD2_REVISA = AD1_REVISA AND AD2_VEND = '"+cVend+"' AND AD1_DTFIM = '' AND AD2.D_E_L_E_T_ = ' ' "
	cQuery	+= " WHERE AD1_FILIAL = '" + xFilial("AD1") + "'"
	If cEnt == "SUS"
		cQuery	+= " AND AD1_PROSPE = '"+cCodigo+"' AND AD1_LOJPRO = '"+cLoja+"'"
	Else
		cQuery	+= " AND AD1_CODCLI = '"+cCodigo+"' AND AD1_LOJCLI = '"+cLoja+"'"
	EndIf
	cQuery	+= " AND AD1.D_E_L_E_T_ = ' '))"
	
	If Select(cAliasTmp) > 0
		(cAliasTmp)->(DbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)
	dbGoTop()
	
	If !Eof() .AND. (cAliasTmp)->RETORNO > 0
		lRet := .T.
	End
	
	(cAliasTmp)->(DbCloseArea())
EndIf

//�������������������������������������������������Ŀ
//�Se nao achou nas oportunidades, busca no cadastro�
//���������������������������������������������������
If !lRet
	cCampo := Iif(cEnt=="SA1","A1_VEND",Iif(cEnt=="SUS","US_VEND","ACH_VEND"))	
	DbSelectArea(cEnt)
	DbSetOrder(1)
	If DbSeek(xFilial(cEnt)+cCodigo+cLoja)
		lRet := (cEnt)->&(cCampo) == cVend
	EndIf
EndIf

//����������������������������������������������������������������Ŀ
//�Se nao achou nas oportunidades e nos cadastros diretos, verifica�
//�se algum subordinado do vendedor atual possui relacionamento com�
//�a entidade a ser desvinculada                                   �
//������������������������������������������������������������������
If !lRet

	cQuery := "SELECT 1 RETORNO "

	If Alltrim(TcGetDB()) == "DB2"
		cQuery += " FROM TABLE (VALUES 1) AS TBX "
	ElseIf Alltrim(TcGetDB()) == "ORACLE"
		cQuery += " FROM DUAL "
	Else 		
		cQuery += " FROM "+ RetSqlName('ADL') +" TBX "  
	EndIF

	cQuery += 	" WHERE EXISTS(SELECT 1 FROM "+RetSqlName("ADL")+" ADL WHERE ADL_FILIAL = '"+xFilial("ADL")+"' AND ADL_ENTIDA = '"+cEnt+"'"
	cQuery += 	" AND ADL_CODENT = '"+cCodigo+"' AND ADL_LOJENT = '"+cLoja+"' AND ADL.D_E_L_E_T_ = ' '"
	cQuery += 	" AND ADL_VEND IN (SELECT A3_COD FROM "+RetSqlName("SA3")+" SA3"
	cQuery +=		" WHERE A3_FILIAL = '" + xFilial("SA3") + "'"

	If Alltrim(TcGetDB()) == "ORACLE" .Or. Alltrim(TcGetDB()) == "POSTGRES"
		cQuery += " AND LPAD(A3_NVLSTR,"+cValToChar(Len(cCodInt))+") = '"+cCodInt+"'"
	ElseIf Alltrim(TcGetDB()) == "INFORMIX"
		cQuery += " AND SUBSTR(A3_NVLSTR,"+cValToChar(Len(cCodInt))+") = '"+cCodInt+"'"
	Else
		cQuery += " AND LEFT(A3_NVLSTR,"+cValToChar(Len(cCodInt))+") = '"+cCodInt+"'"
	EndIf
	cQuery += 		" AND A3_NIVEL >= " + cValToChar(nNivel) + " AND SA3.D_E_L_E_T_ = ' '))"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)
	dbGoTop()
	
	If !Eof() .AND. (cAliasTmp)->RETORNO > 0
		lRet := .T.
	End
	
	(cAliasTmp)->(DbCloseArea())	

EndIf

RestArea(aAreaSA3)
RestArea(aArea)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADLSeek   �Autor  �Vendas CRm          � Data �  06/07/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Realiza a busca na tabela ADL, utilizada durante a Workarea,���
���          �onde o filtro na tabela ADL impede a busca completa.        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Filial da ADL                                       ���
���          �ExpC2 - Codigo do vendedor                                  ���
���          �ExpC3 - Filial da entidade                                  ���
���          �ExpC4 - Alias da entidade                                   ���
���          �ExpC5 - Codigo da entidade                                  ���
���          �ExpC6 - Loja da entidade                                    ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ADLSeek(cFilADL	, cCodVend	, cFilEnt	, cEnt	,;
						cCodigo	, cLoja		)

Local aArea		:= GetArea()
Local cQuery	:= ""
Local cAliasTmp	:= "ADLSEE" 
Local nRec		:= 0

If Select(cAliasTmp) > 0
	(cAliasTmp)->(DbCloseArea())	
EndIf

cQuery	:= "SELECT R_E_C_N_O_ AS RECN FROM "+RetSqlName("ADL")
cQuery	+= " WHERE ADL_FILIAL ='"+cFilADL+"' AND ADL_VEND = '"+cCodVend+"' AND ADL_FILENT = '"+cFilEnt+"'"
cQuery	+= " AND ADL_ENTIDA = '"+cEnt+"' AND ADL_CODENT = '"+cCodigo+"' AND ADL_LOJENT = '"+cLoja+"' AND D_E_L_E_T_ = ' '"

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)
dbGoTop()	                 

If !Eof()
	nRec :=(cAliasTmp)->RECN
End	

(cAliasTmp)->(DbCloseArea())
	
RestArea(aArea)

Return nRec

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520Count�Autor  �Vendas CRM          � Data �  13/08/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Conta quantos vendedores serao processados                  ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft520Count(cVendDe,cVendAte)

Local aArea		:= GetArea()
Local nCount	:= 0
Local cQuery	:= ""
Local cAliasTmp	:= "SA3TMP"

cQuery	:= "SELECT COUNT(*) TOTAL FROM " + RetSqlName("SA3")
cQuery	+= " WHERE A3_FILIAL = '"+xFilial("SA3")+"' AND A3_NVLSTR <> ''"
cQuery	+= " AND A3_COD BETWEEN '" + cVendDe + "' AND '" + cVendAte + "' AND D_E_L_E_T_ = ' '"

If Select(cAliasTmp) > 0
	(cAliasTmp)->(DbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)
dbGoTop()

nCount := 	(cAliasTmp)->TOTAL

(cAliasTmp)->(DbCloseArea())

RestArea(aArea)

Return nCount

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520AtuEn�Autor  �Vendas CRM          � Data �  28/07/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Atualiza nome e cgc da entidade na tabela ADL, apos a alte- ���
���          �racao destes dados na entidade.                             ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Alias da entidade a ser atualizada                  ���
���          �ExpC2 - Codigo da entidade                                  ���
���          �ExpC3 - Loja da entidade                                    ���
���          �ExpC4 - Nome da entidade                                    ���
���          �ExpC5 - CGC da entidade                                     ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft520AtuEn(cEntidade,cCodigo,cLoja,cNome,cCGC)

Local aArea		:= GetArea()
Local cQuery	:= ""

cQuery	:= "UPDATE " + RetSqlName("ADL") + " SET ADL_CGC = '"+cCgc+"', ADL_NOME = '"+cNome+"' "
cQuery	+= "WHERE ADL_FILIAL = '"+xFilial("ADL")+"' AND ADL_FILENT = '"+xFilial(cEntidade)+"' "
cQuery	+= "AND ADL_ENTIDA = '"+cEntidade+"' AND ADL_CODENT = '"+cCodigo+"' AND ADL_LOJENT = '"+cLoja+"' "
cQuery	+= "AND D_E_L_E_T_ = ' '"
          
TcSqlExec(cQuery)

RestArea(aArea)

Return Nil




//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usu�rio utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que ser�o verificados.
    @param aFields, Array, Array com todos os Campos que ser�o verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource


//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com prote��o de dados.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta fun��o deve utilizada somente ap�s 
    a inicializa��o das variaveis atravez da fun��o FATPDLoad.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, L�gico, Retorna se o campo ser� ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   


//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informa��es enviadas, 
    quando a regra de auditoria de rotinas com campos sens�veis ou pessoais estiver habilitada
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que ser� utilizada no log das tabelas
    @param nOpc, Numerico, Op��o atribu�da a fun��o em execu��o - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria n�o esteja aplicada, tamb�m retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Fun��o que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
