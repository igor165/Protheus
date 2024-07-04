#include "plsr266.ch"
#include "protheus.ch"

Static objCENFUNLGP := CENFUNLGP():New()
Static lAutoSt := .F.

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSR266 � Autor � Sandro Hoffman Lopes   � Data � 26.06.06 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Lista relatorio das Empresas/Familias que nao foram        ����
���          � faturadas em determinada competencia (Mes/Ano)             ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSR266()                                                  ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial                               ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function PLSR266(lAuto)

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local cDesc1        := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := STR0002 //"de Empresas/Familias que nao foram faturadas em"
Local cDesc3        := STR0003 //"determinada competencia (Mes/Ano)."
Local cPict         := ""
Local titulo        := FunDesc() //"Empresa / Fam�lia N�o Faturada"
Local nLin          := 80
Local Cabec1        := STR0005 //"               MATRICULA                NOME DO USUARIO                                                       VENCTO  GRP COBR"
Local Cabec2        := ""
Local imprime       := .T.
Local aOrd          := {}

Default lAuto := .F.

Private lEnd        := .F.
Private lAbortPrint := .F.
Private CbTxt       := ""
Private limite      := 132
Private tamanho     := "M"
Private nomeprog    := "PLSR266"
Private nTipo       := 15
Private aReturn     := { STR0010, 1, STR0011, 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey    := 0
Private cPerg       := "PLR266"
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "PLSR266"
Private lCompres    := .T.
Private lDicion     := .F.
Private lFiltro     := .F.
Private lCrystal    := .F.
Private cString     := "BA3"
Private nTotVid     := 0

Pergunte(cPerg,.F.)

lAutoSt := lAuto

//���������������������������������������������������������������������Ŀ
//� Monta a interface padrao com o usuario...                           �
//�����������������������������������������������������������������������
if !lAuto
	wnrel:=  SetPrint(cString,NomeProg,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,lDicion,aOrd,lCompres,Tamanho,{},lFiltro,lCrystal)
endif
	aAlias := {"BG9","BT5","BQC","BA3","BA1"}
	objCENFUNLGP:setAlias(aAlias)

If !lAuto .AND. nLastKey == 27
	Return
Endif

if !lAuto
	SetDefault(aReturn,cString)
endif

If !lAuto .AND. nLastKey == 27
   Return
Endif

Titulo := AllTrim(Titulo) + STR0009 + mv_par03 + "/" + mv_par02

nTipo := If(aReturn[4]==1,15,18)

//��������������������������������������������������������������������������Ŀ
//� Emite relat�rio                                                          �
//����������������������������������������������������������������������������
if !lAuto
	MsAguarde({|| R266Imp(Cabec1,Cabec2,Titulo,nLin) }, Titulo, "", .T.)
	Roda(0,"","M")
else
	R266Imp(Cabec1,Cabec2,Titulo,nLin)
endif
//���������������������������������������������������������������������Ŀ
//� Finaliza a execucao do relatorio...                                 �
//�����������������������������������������������������������������������
if !lAuto
	SET DEVICE TO SCREEN
endif
//���������������������������������������������������������������������Ŀ
//� Se impressao em disco, chama o gerenciador de impressao...          �
//�����������������������������������������������������������������������
 
If !lAuto .AND. aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

If !lAuto
	MS_FLUSH()
endif

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �R266Imp    � Autor � Sandro Hoffman Lopes  � Data � 26/06/06���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime relatorio para conferencia dos valores gerados no   ���
���          �arquivo de pagamento da RDA.                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R266Imp(Cabec1,Cabec2,Titulo,nLin)

	Local cSql
	Local cTipo
	Local cAno
	Local cMes
	Local lListUsu
	Local cCodIntDe
	Local cCodIntAte
	Local cCodEmpDe
	Local cCodEmpAte
	Local cConEmpDe
	Local cConEmpAte
	Local cVerConDe
	Local cVerConAte
	Local cSubConDe
	Local cSubConAte
	Local cVerSubDe
	Local cVerSubAte
	Local cMatricDe
	Local cMatricAte
	Local cGrpCobDe
	Local cGrpCobAte
	Local cCodEmp
	Local cConEmp
	Local cVerCon
	Local cSubCon
	Local cVerSub
	Local i
	Local lImpBG9
	Local lImpBT5
	Local lImpBQC
	Local aUsuarios

	cTipo      := Str(mv_par01, 1)
	cAno       := mv_par02
	cMes       := mv_par03
	lListUsu   := (mv_par04 == 1)
	cCodIntDe  := mv_par05
	cCodIntAte := mv_par06
	cCodEmpDe  := mv_par07
	cCodEmpAte := mv_par08
	cConEmpDe  := mv_par09
	cConEmpAte := mv_par10
	cVerConDe  := mv_par11
	cVerConAte := mv_par12
	cSubConDe  := mv_par13
	cSubConAte := mv_par14
	cVerSubDe  := mv_par15
	cVerSubAte := mv_par16
	cMatricDe  := mv_par17
	cMatricAte := mv_par18
	cGrpCobDe  := mv_par19
	cGrpCobAte := mv_par20
	lBenefBlo  := (mv_par21 == 2)

	Default lBenefBlo := .F.

	//���������������������������������������������������������������������Ŀ
	//� Inicia a montagem da query principal para selecionar as familias... �
	//�����������������������������������������������������������������������	
	cSql := "SELECT BA3_MODPAG, BA3_CODINT, BA3_COBNIV, BA3_VENCTO, BA3_CODEMP, BA3_CONEMP, BA3_VERCON,"
	cSql += "       BA3_SUBCON, BA3_VERSUB, BA3_MATRIC, BA3_GRPCOB, BA3_TIPOUS, " + RetSqlName("BA3")+".R_E_C_N_O_ BA3REC,"
	cSql += "       BG9_VENCTO, " + RetSqlName("BG9")+".R_E_C_N_O_ BG9REC "

	//��������������������������������������������������������������������������Ŀ
	//� Campos utilizados quando eh pessoa juridica...                           �
	//����������������������������������������������������������������������������
	If cTipo == "2"
		cSql += ", BT5_COBNIV, BT5_VENCTO, " + RetSqlName("BT5")+".R_E_C_N_O_ BT5REC, "
		cSql += "  BQC_COBNIV, BQC_VENCTO, BQC_GRPCOB, " + RetSqlName("BQC")+".R_E_C_N_O_ BQCREC "
	EndIf

	//��������������������������������������������������������������������������Ŀ
	//� Tabelas de uso geral... pessoa fisica/juridica                           �
	//����������������������������������������������������������������������������		                                             
	cSql += "FROM " + RetSqlName("BA3") + ", " + RetSqlName("BG9")

	//��������������������������������������������������������������������������Ŀ
	//� Tabelas de uso exclusivo para pessoa juridica...                         �
	//����������������������������������������������������������������������������	     
	If cTipo == "2"
		cSql += ", " + RetSqlName("BT5") + ", " + RetSqlName("BQC")
	EndIf

	//��������������������������������������������������������������������������Ŀ
	//� Inicializa montagem do filtro...                                         �
	//����������������������������������������������������������������������������			
    cSql += " WHERE BA3_FILIAL = '" + xFilial("BA3") + "' "
	cSql += "   AND BG9_FILIAL = '" + xFilial("BG9") + "' "

	If cTipo == "2"
		cSql += "AND BT5_FILIAL = '" + xFilial("BT5") + "' "	
		cSql += "AND BQC_FILIAL = '" + xFilial("BQC") + "' "		
	EndIf

	cSql += "   AND BA3_CODEMP = BG9_CODIGO "
	cSql += "   AND BA3_CODINT = BG9_CODINT "

	//��������������������������������������������������������������������������Ŀ
	//� Filtro para pessoa juridica...                                           �
	//����������������������������������������������������������������������������					
	If cTipo == "2"	
		cSql += "AND BA3_CODINT = BT5_CODINT "
		cSql += "AND BA3_CODEMP = BT5_CODIGO "
		cSql += "AND BA3_CONEMP = BT5_NUMCON "
		cSql += "AND BA3_VERCON = BT5_VERSAO "
		
		cSql += "AND BA3_CODINT+BA3_CODEMP = BQC_CODIGO  "
		cSql += "AND BA3_CONEMP = BQC_NUMCON "
		cSql += "AND BA3_VERCON = BQC_VERCON "
		cSql += "AND BA3_SUBCON = BQC_SUBCON "
		cSql += "AND BA3_VERSUB = BQC_VERSUB "
		cSql += "AND " + RetSqlName("BT5") + ".D_E_L_E_T_ = ' ' "
		cSql += "AND " + RetSqlName("BQC") + ".D_E_L_E_T_ = ' ' "
	EndIf	

	//��������������������������������������������������������������������������Ŀ
	//� Uso geral                                                                �
	//����������������������������������������������������������������������������			
	cSql += "   AND " + RetSqlName("BA3") + ".D_E_L_E_T_ = ' ' "
	cSql += "   AND " + RetSqlName("BG9") + ".D_E_L_E_T_ = ' ' "

	//���������������������������������������������������������������������Ŀ
	//� Se for informado empresa...    			                            �
	//�����������������������������������������������������������������������	
	If ! Empty(cCodEmpAte)
		cSql += "AND BA3_CODEMP >= '" + cCodEmpDe + "' AND BA3_CODEMP <= '" + cCodEmpAte + "' "
	Endif

	//��������������������������������������������������������������������������Ŀ
	//� Filtro para pessoa juridica...                                           �
	//����������������������������������������������������������������������������					
	If cTipo == "2"
		cSql += "AND BA3_TIPOUS = '2' "                                          
		
		//���������������������������������������������������������������������Ŀ
		//� Se for informado contrato...   			                            �
		//�����������������������������������������������������������������������		
		If ! Empty(cConEmpAte + cVerConAte)
			cSql += "AND (BA3_CONEMP >= '" + cConEmpDe  + "' AND BA3_VERCON >= '" + cVerConDe  + "') AND "
			cSql += "    (BA3_CONEMP <= '" + cConEmpAte + "' AND BA3_VERCON <= '" + cVerConAte + "') "
		Endif
			                                 
		//���������������������������������������������������������������������Ŀ
		//� Se for informado sub contrato...    	                            �
		//�����������������������������������������������������������������������		
		If ! Empty(cSubConAte+cVerSubAte)
			cSql += "AND (BA3_SUBCON >= '" + cSubConDe  + "' AND BA3_VERSUB >= '" + cVerSubDe  + "') AND "
			cSql += "    (BA3_SUBCON <= '" + cSubConAte + "' AND BA3_VERSUB <= '" + cVerSubAte + "') "
		Endif                          
		
		//���������������������������������������������������������������������Ŀ
		//� Filtra por grupo de cobranca...			                            �
		//�����������������������������������������������������������������������
		If !Empty(cGrpCobAte)
			cSql += "AND (((BQC_GRPCOB >= '" + cGrpCobDe + "' AND BQC_GRPCOB <= '" + cGrpCobAte + "') AND BA3_COBNIV <> '1' ) OR "
			cSql += "     ((BA3_GRPCOB >= '" + cGrpCobDe + "' AND BA3_GRPCOB <= '" + cGrpCobAte + "') AND BA3_COBNIV =  '1' ))"
		EndIf
	ElseIf cTipo == "1"
		//���������������������������������������������������������������������Ŀ
		//� Filtra exclusivo para pessoa fisica...                              �
		//�����������������������������������������������������������������������	
		cSql += " AND BA3_TIPOUS = '1' "

		//���������������������������������������������������������������������Ŀ
		//� Filtra por grupo de cobranca...			                            �
		//�����������������������������������������������������������������������
		If !Empty(cGrpCobAte)
			cSql += " AND (BA3_GRPCOB >= '" + cGrpCobDe + "' AND BA3_GRPCOB <= '" + cGrpCobAte + "') "
		EndIf
	EndIf
	
	//���������������������������������������������������������������������Ŀ
	//� Se for informado matricula... 			                            �
	//�����������������������������������������������������������������������		
	If ! Empty(cMatricAte)
		cSql += "AND BA3_MATRIC >= '" + cMatricDe + "' AND BA3_MATRIC <= '" + cMatricAte + "' "
	EndIf

	//���������������������������������������������������������������������Ŀ
	//� Ordena o resultado da query...  	                                �
	//�����������������������������������������������������������������������
	If cTipo == '2'
		cSql += "ORDER BY BA3_FILIAL, BA3_CODINT, BA3_CODEMP, BA3_CONEMP, BA3_VERCON, BA3_SUBCON, BA3_VERSUB, BA3_MATRIC"
	Else
		cSql += "ORDER BY BA3_FILIAL, BA3_CODINT, BA3_CODEMP, BA3_MATRIC"
	Endif

	PLSQuery(cSql,"SELEFAM")

	SELEFAM->(DbGoTop())
 	Do While ! SELEFAM->(Eof())
	
		If !lAutoSt .AND. Interrupcao(lAbortPrint)
			Exit
		EndIf   

		BA3->(DbGoTo(SELEFAM->BA3REC))
		BG9->(DbGoTo(SELEFAM->BG9REC))

 		cCodEmp := SELEFAM->BA3_CODEMP
		lImpBG9 := .T.
					
 		Do While ! SELEFAM->(Eof()) .And. SELEFAM->BA3_CODEMP == cCodEmp
 		
			If !lAutoSt .AND. Interrupcao(lAbortPrint)
				Exit
			EndIf   
			
 			If cTipo == "2"
				BT5->(DbGoTo(SELEFAM->BT5REC))
				lImpBT5 := .T.
			Else
				lImpBT5 := .F.
			EndIf

 		    cConEmp := SELEFAM->BA3_CONEMP
 		    cVerCon := SELEFAM->BA3_VERCON
 			
 			Do While ! SELEFAM->(Eof()) .And. SELEFAM->(BA3_CODEMP+BA3_CONEMP+BA3_VERCON) == cCodEmp+cConEmp+cVerCon
 			
				If !lAutoSt .AND. Interrupcao(lAbortPrint)
					Exit
				EndIf   

	 			If cTipo == "2"
					BQC->(DbGoTo(SELEFAM->BQCREC))
					lImpBQC := .T.
				Else
					lImpBQC := .F.
				EndIf

 		    	cSubCon := SELEFAM->BA3_SUBCON
 		    	cVerSub := SELEFAM->BA3_VERSUB

 				Do While ! SELEFAM->(Eof()) .And. SELEFAM->(BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB) == cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub
 				
					if !lAutoSt
						If Interrupcao(lAbortPrint)
							Exit
						EndIf   
						
						MsProcTxt(STR0012 +;
								objCENFUNLGP:verCamNPR("BA3_CODEMP",SELEFAM->BA3_CODEMP) + " " +;
								STR0013 +;
								objCENFUNLGP:verCamNPR("BA3_MATRIC",SELEFAM->BA3_MATRIC))
						ProcessMessages()
					endif

					aUsuarios := PLSLOADUSR(SELEFAM->BA3_CODINT,SELEFAM->BA3_CODEMP,SELEFAM->BA3_MATRIC,cAno,cMes)
			
					If Len(aUsuarios) == 0
						SELEFAM->(DbSkip())
						Loop
					EndIf         
					
					For i := 1 to Len(aUsuarios)

						If !lBenefBlo
							If !Empty(aUsuarios[i][24])
								dDatBlo := DToS(aUsuarios[i][24])
								cDatBlo := Substr(dDatBlo, 1, 6)
								If !((cAno+cMes) < cDatBlo)
									Loop
								EndIf
							EndIf
						EndIf

							If AllTrim(SELEFAM->BA3_MODPAG) == "1" // Pre-Pagamento
								If ! fLe_BM1(SELEFAM->BA3_CODINT, SELEFAM->BA3_CODEMP, SELEFAM->BA3_MATRIC, cAno, cMes, aUsuarios[i, 1])
									Loop
								EndIf   
							Else
								If ! fLe_BDH(SELEFAM->BA3_CODINT, SELEFAM->BA3_CODEMP, SELEFAM->BA3_MATRIC, cAno, cMes, aUsuarios[i, 1])
									Loop
								EndIf   
							EndIf
						
							If lImpBG9
								lImpBG9 := .F.
								fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 2)
								@ nLin,  0 pSay Replicate("-", 136)
								fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 2)
								@ nLin,  0 pSay STR0006 + 	objCENFUNLGP:verCamNPR("BG9_CODIGO",BG9->BG9_CODIGO) + " - " +;
															objCENFUNLGP:verCamNPR("BG9_DESCRI",BG9->BG9_DESCRI) //"Empresa: "
							EndIf     
							
							If lImpBT5
								lImpBT5 := .F.
								fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1)
								@ nLin,  5 pSay STR0007 + 	objCENFUNLGP:verCamNPR("BT5_NUMCON",BT5->BT5_NUMCON) + "-" +;
															objCENFUNLGP:verCamNPR("BT5_VERSAO",BT5->BT5_VERSAO) //"Contrato: "
								If SELEFAM->BT5_COBNIV == "1"
									@ nLin, 112 pSay objCENFUNLGP:verCamNPR("BT5_VENCTO",Transform(SELEFAM->BT5_VENCTO, "99"))
								EndIf
							EndIf
							
							If lImpBQC
								lImpBQC := .F.
								fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1)
								@ nLin, 10 pSay STR0008 + 	objCENFUNLGP:verCamNPR("BQC_SUBCON",BQC->BQC_SUBCON) + "-" +;
															objCENFUNLGP:verCamNPR("BQC_VERSUB",BQC->BQC_VERSUB) + " - " +;
															objCENFUNLGP:verCamNPR("BQC_DESCRI",BQC->BQC_DESCRI) //"SubContrato: "
								If SELEFAM->BQC_COBNIV == "1"
									@ nLin, 112 pSay objCENFUNLGP:verCamNPR("BQC_VENCTO",Transform(SELEFAM->BQC_VENCTO, "99"))
								EndIf
								@ nLin, 120 pSay objCENFUNLGP:verCamNPR("BQC_GRPCOB",SELEFAM->BQC_GRPCOB)
							EndIf
							
							If lListUsu .Or. SELEFAM->BA3_TIPOUS == '1'
								fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1)
								@ nLin, 15 pSay Transform(	objCENFUNLGP:verCamNPR("BA3_CODINT",SELEFAM->BA3_CODINT)+;
															objCENFUNLGP:verCamNPR("BA3_CODEMP",SELEFAM->BA3_CODEMP)+;
															objCENFUNLGP:verCamNPR("BA3_MATRIC",SELEFAM->BA3_MATRIC)+;
															objCENFUNLGP:verCamNPR("BA1_TIPREG",aUsuarios[i, 1])+;
															objCENFUNLGP:verCamNPR("BA1_DIGITO",aUsuarios[i, 12]), "@R !.!!!.!!!!.!!!!!!-!!.!") + " - " + ;
															objCENFUNLGP:verCamNPR("BA1_NOMUSR",aUsuarios[i, 3])
								If SELEFAM->BA3_COBNIV == "1"
									@ nLin, 112 pSay objCENFUNLGP:verCamNPR("BA3_VENCTO",Transform(SELEFAM->BA3_VENCTO, "99"))
								EndIf
								@ nLin, 120 pSay objCENFUNLGP:verCamNPR("BA3_GRPCOB",SELEFAM->BA3_GRPCOB)
							EndIf
					Next i
					
					SELEFAM->(DbSkip())
				EndDo
			EndDo
    	EndDo
	EndDo
	
	SELEFAM->(DbCloseArea())

Return

/*/  
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
��� Programa  � fLe_BM1       � Autor � Sandro Hoffman     � Data � 26.06.2006 ���
������������������������������������������������������������������������������Ĵ��
��� Descri��o � Le tabela BM1 para verificar se houve faturamento              ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
/*/
Static Function fLe_BM1(cCodInt, cCodEmp, cMatric, cAno, cMes, cTipreg)

    Local lRet

	BM1->(DbSetOrder(1))
	lRet := ! BM1->(MsSeek(xFilial("BM1")+cCodInt+cCodEmp+cMatric+cAno+cMes+cTipreg))

Return lRet

/*/  
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
��� Programa  � fLe_BDH       � Autor � Sandro Hoffman     � Data � 26.06.2006 ���
������������������������������������������������������������������������������Ĵ��
��� Descri��o � Le tabela BDH para verificar se ha participacao financeira e,  ���
���           � se houver, se houve faturamento da mesma.                      ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
/*/
Static Function fLe_BDH(cCodInt, cCodEmp, cMatric, cAno, cMes, cTipreg)

    Local lRet

	BDH->(DbSetOrder(1))
	If BDH->(MsSeek(xFilial("BDH")+cCodInt+cCodEmp+cMatric+cTipreg+cAno+cMes))
		If BDH->BDH_STATUS == "1" // A Faturar
			lRet := .T.
		Else
			lRet := fLe_BM1(cCodInt, cCodEmp, cMatric, cAno, cMes, cTipreg)
		EndIf
	Else
		lRet := .F.
	EndIf
	
Return lRet

/*/  
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
��� Programa  � fSomaLin      � Autor � Sandro Hoffman     � Data � 26.06.2006 ���
������������������������������������������������������������������������������Ĵ��
��� Descri��o � Soma "n" Linhas a variavel "nLin" e verifica limite da pagina  ���
���           � para impressao do cabecalho                                    ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
/*/
Static Function fSomaLin(nLin, Titulo, Cabec1, Cabec2, nLinSom)

	nLin += nLinSom
	If nLin > 58
		nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo) + 1
	EndIf

Return
