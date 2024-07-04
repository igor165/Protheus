#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#DEFINE pMoeda "@E 999,999,999,999.99"
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �POSREG    � Autor � Totvs					� Data � 05/02/12 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Gatilho do Usuario										  ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function POSREG(cAlias,nIdx,cChave,nTam,cCmpVig,cDatVig)
LOCAL aArea := GetArea()
LOCAL cMsg 	:= ""
LOCAL cChvPesq := ""

Default cCmpVig := ""
Default cDatVig := ""


//��������������������������������������������������������������������������
//� Ajusta chave
//��������������������������������������������������������������������������
cChave := AllTrim(cChave) + Space( nTam-Len( AllTrim( cChave ) ) )
//��������������������������������������������������������������������������
//� Verifica se registro existe
//��������������������������������������������������������������������������
(cAlias)->( DbSetOrder(nIdx) )

If !(cAlias)->( DBSeek( xFilial( cAlias ) + cChave ,.F. ))	
	If !Empty(cChave)
		cMsg := "Conteudo n�o encontrado"
	EndIf
ElseIf !Empty(cCmpVig) .And. !Empty(cDatVig)//Encontrei o registro e vou verificar a vigencia	
	
	if(!cAlias == "BTQ")
		If !Empty(DTOS(&((cAlias)+"->"+(cCmpVig)))) .And. DTOS(&((cAlias)+"->"+(cCmpVig))) < cDatVig
		     cMsg := "Conteudo encontrado com vig�ncia vencida"
	    EndIf
	else
		While !(cAlias)->(Eof()) .AND. xFilial("BTQ")+cChave == BTQ->(BTQ_FILIAL+BTQ_CODTAB+BTQ_CDTERM)	
			
			If !Empty(cCmpVig) .And. !Empty(cDatVig)//Encontrei o registro e vou verificar a vigencia
				If !Empty(DTOS(&((cAlias)+"->"+(cCmpVig)))) .And. DTOS(&((cAlias)+"->"+(cCmpVig))) < cDatVig
					cMsg := "Conteudo encontrado com vig�ncia vencida"
				else
				    cMsg := ""
					Exit	
				EndIf
			EndIf
			(cAlias)->(DbSkip())
		EndDo

	EndIf
	
EndIf

RestArea(aArea)
//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
Return(cMsg)
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLGATBI3  � Autor � Totvs					� Data � 05/02/12 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Gatilho do produto										  ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
User Function PLGATBI3()
LOCAL aArea  := GetArea()
LOCAL cChave := paramixb[1]
LOCAL cMsg 	 := ""
LOCAL nTam	 := BI3->(TamSx3("BI3_CODINT")[1]+TamSx3("BI3_CODIGO")[1])
LOCAL aRet	 := {}
//��������������������������������������������������������������������������
//� Verifica se o registro existe
//��������������������������������������������������������������������������
cMsg := POSREG("BI3",1,cChave,nTam)//BI3_FILIAL + BI3_CODINT + BI3_CODIGO + BI3_VERSAO
//��������������������������������������������������������������������������
//� Estrutura de retorno
//��������������������������������������������������������������������������
AaDd(aRet, {"Field_DESPLA",BI3->BI3_DESCRI } )
//��������������������������������������������������������������������������
//� Restaura area corrente
//��������������������������������������������������������������������������
RestArea(aArea)
//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
Return( {cMsg,aRet} )
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLGATBCX  � Autor � Totvs					� Data � 05/02/12 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Gatilho do Funcao/Profissao								  ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
User Function PLGATBCX()
LOCAL aArea  := GetArea()
LOCAL cChave := paramixb[1]
LOCAL cMsg 	 := ""
LOCAL nTam	 := BCX->(TamSx3("BCX_CODIGO")[1])
LOCAL aRet	 := {}
//��������������������������������������������������������������������������
//� Verifica se o registro existe
//��������������������������������������������������������������������������
cMsg := POSREG("BCX",1,cChave,nTam)//BCX_FILIAL + BCX_CODIGO
//��������������������������������������������������������������������������
//� Estrutura de retorno
//��������������������������������������������������������������������������
AaDd(aRet, {"Field_DESPRF",BCX->BCX_DESCRI } )

RestArea(aArea)
//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
Return( {cMsg,aRet} )
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLGATBC9  � Autor � Totvs					� Data � 05/02/12 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Gatilho do Cep											  ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
User Function PLGATBC9()
LOCAL aArea  := GetArea()
LOCAL cChave := paramixb[1]
LOCAL cMsg 	 := ""
LOCAL nTam	 := BC9->(TamSx3("BC9_CEP")[1])
LOCAL aRet	 := {}
//��������������������������������������������������������������������������
//� Verifica se o registro existe
//��������������������������������������������������������������������������
POSREG("BC9",1,cChave,nTam)//BC9_FILIAL + BC9_CEP
//��������������������������������������������������������������������������
//� Estrutura de retorno
//��������������������������������������������������������������������������
AaDd(aRet, {"Field_TIPLOG", BC9->BC9_TIPLOG	} )
AaDd(aRet, {"Field_ENDERE", BC9->BC9_END 	} )
AaDd(aRet, {"Field_ESTADO", BC9->BC9_EST	} )
AaDd(aRet, {"Field_CODMUN", BC9->BC9_CODMUN} )
AaDd(aRet, {"Field_BAIRRO", BC9->BC9_BAIRRO	} )

RestArea(aArea)
//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
Return( {cMsg,aRet} )
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLGATBA1  � Autor � Totvs					� Data � 05/02/12 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Gatilho do Usuario										  ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
User Function PLGATBA1()
LOCAL aArea  	:= GetArea()
LOCAL cChave 	:= paramixb[1]
LOCAL nTpRet 	:= paramixb[2]
LOCAL cCodLWeb	:= paramixb[3]
LOCAL nTpPor	:= paramixb[4]
LOCAL cVldGen	:= paramixb[5]
LOCAL cMsg 	 	:= ""
LOCAL nTam	 	:= BA1->(TamSx3("BA1_CODINT")[1]+TamSx3("BA1_CODEMP")[1]+TamSx3("BA1_MATRIC")[1]+TamSx3("BA1_TIPREG")[1]+TamSx3("BA1_DIGITO")[1] )
LOCAL aRet	 	:= {}
//��������������������������������������������������������������������������
//� Data com 4 digitos
//��������������������������������������������������������������������������
__SetCentury("on")
//��������������������������������������������������������������������������
//� Verifica se o registro existe
//��������������������������������������������������������������������������
cMsg := POSREG("BA1",2,cChave,nTam) //BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
//��������������������������������������������������������������������������
//� Verifica se e familia
//��������������������������������������������������������������������������
If Empty(cMsg) .And. !Empty(cVldGen)
	If BA1->BA1_TIPREG != GetNewPar("MV_PLTRTIT","00")
		cMsg := "Conteudo n�o encontrado"
	EndIf
EndIf
//��������������������������������������������������������������������������
//� Verifica se o usuario esta ligado ao login
//��������������������������������������������������������������������������
If Empty(cMsg)
	//��������������������������������������������������������������������������
	//� Empresa
	//��������������������������������������������������������������������������
	If nTpPor == 2
		cAlias	:= "B40"
		cChave 	:= cCodLWeb + BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)
		nTam	:= BA1->(TamSx3("BA1_CODINT")[1]+TamSx3("BA1_CODEMP")[1]+TamSx3("BA1_CONEMP")[1]+TamSx3("BA1_VERCON")[1]+TamSx3("BA1_SUBCON")[1]+TamSx3("BA1_VERSUB")[1])
		cMsg 	:= "Conteudo n�o encontrado"

		B40->( DbSetOrder(1) )
		If B40->( MsSeek( xFilial("B40") + cCodLWeb + BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON) ) )
			//��������������������������������������������������������������������������
			//� Se nao tem subcontrato informado permiti todos do contrato
			//��������������������������������������������������������������������������
			If Empty( B40->(B40_SUBCON+B40_VERSUB) )
				cMsg := ""
			EndIf
			//��������������������������������������������������������������������������
			//� Verifica o subcontrato do contrato
			//��������������������������������������������������������������������������
			If !Empty(cMsg)
				While !B40->( Eof() ) .And. B40->(B40_CODUSR+B40_CODINT+B40_CODEMP+B40_NUMCON+B40_VERCON) == cCodLWeb + BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON)
					If BA1->(BA1_SUBCON+BA1_VERSUB) == B40->(B40_SUBCON+B40_VERSUB)
						cMsg := ""
						Exit
					EndIf
				B40->( DbSkip() )
				EndDo
			EndIf
		EndIf
	//��������������������������������������������������������������������������
	//� Beneficiario
	//��������������������������������������������������������������������������
	ElseIf nTpPor == 3
		cChave 	:= cCodLWeb + cChave
		cMsg 	:= POSREG("B49",1,cChave,nTam)
	EndIf
EndIf
//��������������������������������������������������������������������������
//� Estrutura de retorno
//��������������������������������������������������������������������������
Do Case
	Case nTpRet == 0
		AaDd(aRet, {"Field_NUMCON"	,BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON) } )
		AaDd(aRet, {"Field_SUBCON"	,BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB) } )
		AaDd(aRet, {"Field_NOMUSR"	,BA1->BA1_NOMUSR } )
		AaDd(aRet, {"Field_TIPUSU"	,BA1->BA1_TIPUSU } )
		AaDd(aRet, {"Field_DATNAS"	,Iif( Empty(BA1->BA1_DATNAS),'', DtoC( BA1->BA1_DATNAS ) ) } )
		AaDd(aRet, {"Field_SEXO"	,BA1->BA1_SEXO } )
		AaDd(aRet, {"Field_ESTCIV"	,BA1->BA1_ESTCIV } )
		AaDd(aRet, {"Field_CPFUSR"	,BA1->BA1_CPFUSR } )
		AaDd(aRet, {"Field_DRGUSR"	,BA1->BA1_DRGUSR } )
		AaDd(aRet, {"Field_DATEXP"	,Iif( Empty(BA1->BA1_DATEXP),'', DtoC( BA1->BA1_DATEXP ) ) } )
		AaDd(aRet, {"Field_ORGEM"	,BA1->BA1_ORGEM } )
		AaDd(aRet, {"Field_PISPAS"	,BA1->BA1_PISPAS } )
		AaDd(aRet, {"Field_MAE"		,BA1->BA1_MAE } )
		AaDd(aRet, {"Field_MATEMP"	,BA1->BA1_MATEMP } )
		AaDd(aRet, {"Field_CODPLA"	,BA1->BA1_CODPLA } )
		AaDd(aRet, {"Field_DESPLA"	,Posicione("BI3",1,xFilial("BI3")+BA1->(BA1_CODINT+BA1_CODPLA+BA1_VERSAO),"BI3_DESCRI") } )
		AaDd(aRet, {"Field_CODPRF"	,BA1->BA1_CODPRF } )
		AaDd(aRet, {"Field_DESPRF"	,Posicione("BCX",1,xFilial("BCX")+BA1->BA1_CODPRF,"BCX_DESCRI") } )
		AaDd(aRet, {"Field_SALARI"	,TransForm( ABS(BA1->BA1_SALARI) ,pMoeda) } )
		AaDd(aRet, {"Field_DATADM"	,Iif( Empty(BA1->BA1_DATADM),'', DtoC( BA1->BA1_DATADM ) ) } )
		AaDd(aRet, {"Field_TELEFO"	,PLSFTel( BA1->BA1_TELEFO ) } )
		AaDd(aRet, {"Field_TELEF2"	,PLSFTel( BA1->BA1_TELEF2 ) } )
		AaDd(aRet, {"Field_CEL"		,PLSFTel( BA1->BA1_CEL ) } )
		AaDd(aRet, {"Field_EMAIL"	,BA1->BA1_EMAIL } )
		AaDd(aRet, {"Field_CEPUSR"	,BA1->BA1_CEPUSR } )
		AaDd(aRet, {"Field_TIPLOG"	,BA1->BA1_TIPLOG } )
		AaDd(aRet, {"Field_ENDERE"	,BA1->BA1_ENDERE } )
		AaDd(aRet, {"Field_COMEND"	,BA1->BA1_COMEND } )
		AaDd(aRet, {"Field_NR_END"	,BA1->BA1_NR_END } )
		AaDd(aRet, {"Field_ESTADO"	,BA1->BA1_ESTADO } )
		AaDd(aRet, {"Field_CODMUN"	,BA1->BA1_CODMUN } )
		AaDd(aRet, {"Field_BAIRRO"	,BA1->BA1_BAIRRO } )
	Case nTpRet == 1
		AaDd(aRet, {"Field_NOMUSR"	,BA1->BA1_NOMUSR } )
EndCase
//��������������������������������������������������������������������������
//� Data com 2 digitos
//��������������������������������������������������������������������������
__SetCentury("off")

RestArea(aArea)
//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
Return( {cMsg,aRet} )
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLGATXXX  � Autor � Totvs					� Data � 05/02/12 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Gatilho do Usuario na tabela espelho						  ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
User Function PLGATXXX()
LOCAL aArea  := GetArea()
LOCAL cChave := paramixb[1]
LOCAL cMsg 	 := ""
LOCAL nTam	 := XXX->(TamSx3("XXX_CODPRO")[1] )
LOCAL aRet	 := {}
//��������������������������������������������������������������������������
//� Verifica se o registro existe
//��������������������������������������������������������������������������
cMsg := POSREG("XXX",2,cChave,nTam) //BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
//��������������������������������������������������������������������������
//� Estrutura de retorno
//��������������������������������������������������������������������������
AaDd(aRet, {"Field_NUMCON"	,XXX->XXX_NUMCOM } )
AaDd(aRet, {"Field_SUBCON"	,XXX->XXX_SUBCON } )
AaDd(aRet, {"Field_NOMUSR"	,XXX->XXX_NOMUSR } )
AaDd(aRet, {"Field_TIPUSU"	,XXX->XXX_TIPUSU } )
AaDd(aRet, {"Field_DATNAS"	,Iif( Empty(XXX->XXX_DATNAS),'',DtoC( XXX->XXX_DATNAS ) ) } )
AaDd(aRet, {"Field_SEXO"	,XXX->XXX_SEXO } )
AaDd(aRet, {"Field_ESTCIV"	,XXX->XXX_ESTCIV } )
AaDd(aRet, {"Field_CPFUSR"	,XXX->XXX_CPFUSR } )
AaDd(aRet, {"Field_DRGUSR"	,XXX->XXX_DRGUSR } )
AaDd(aRet, {"Field_DATEXP"	,Iif( Empty(XXX->XXX_DATNAS),'',DtoC( XXX->XXX_DATEXP ) ) } )
AaDd(aRet, {"Field_ORGEM"	,XXX->XXX_ORGEM } )
AaDd(aRet, {"Field_PISPAS"	,XXX->XXX_PISPAS } )
AaDd(aRet, {"Field_MAE"		,XXX->XXX_MAE } )
AaDd(aRet, {"Field_MATEMP"	,XXX->XXX_MATEMP } )
AaDd(aRet, {"Field_CODPLA"	,XXX->XXX_CODPLA } )
AaDd(aRet, {"Field_DESPLA"	,Posicione("BI3",1,xFilial("BI3")+XXX->XXX_CODINT+XXX->XXX_CODPLA,"BI3_DESCRI") } )
AaDd(aRet, {"Field_CODPRF"	,XXX->XXX_CODPRF } )
AaDd(aRet, {"Field_DESPRF"	,Posicione("BCX",1,xFilial("BCX")+XXX->XXX_CODPRF,"BCX_DESCRI") } )
AaDd(aRet, {"Field_SALARI"	,XXX->XXX_SALARI } )
AaDd(aRet, {"Field_DATADM"	,Iif( Empty(XXX->XXX_DATADM),'',DtoC( XXX->XXX_DATADM ) ) } )
AaDd(aRet, {"Field_TELEFO"	,XXX->XXX_TELEFO } )
AaDd(aRet, {"Field_TELEF2"	,XXX->XXX_TELEF2 } )
AaDd(aRet, {"Field_CEL"		,XXX->XXX_CEL } )
AaDd(aRet, {"Field_EMAIL"	,XXX->XXX_EMAIL } )
AaDd(aRet, {"Field_CEPUSR"	,XXX->XXX_CEPUSR } )
AaDd(aRet, {"Field_TIPLOG"	,XXX->XXX_TIPLOG } )
AaDd(aRet, {"Field_ENDERE"	,XXX->XXX_ENDERE } )
AaDd(aRet, {"Field_COMEND"	,XXX->XXX_COMEND } )
AaDd(aRet, {"Field_NR_END"	,XXX->XXX_NR_END } )
AaDd(aRet, {"Field_ESTADO"	,XXX->XXX_ESTADO } )
AaDd(aRet, {"Field_CODMUN"	,XXX->XXX_CODMUN } )
AaDd(aRet, {"Field_BAIRRO"	,XXX->XXX_BAIRRO } )
AaDd(aRet, {"Field_STATUS"	,XXX->XXX_STATUS } )
AaDd(aRet, {"Field_OPERAC"	,XXX->XXX_OPERAC } )
AaDd(aRet, {"Field_DATMOV"	,XXX->XXX_DATMOV } )

RestArea(aArea)
//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
Return( {cMsg,aRet} )

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLGATXXX  � Autor � Totvs					� Data � 05/02/12 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Gatilho do Usuario na tabela espelho						  ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
User Function PLGATPRE()
LOCAL aArea  := GetArea()
LOCAL cChave := paramixb[1]
LOCAL cMsg 	 := ""
LOCAL nTam	 := BAU->(TamSx3("BAU_CPFCGC")[1] )
LOCAL aRet	 := {}
//��������������������������������������������������������������������������
//� Verifica se o registro existe
//��������������������������������������������������������������������������
cMsg := POSREG("BAU",4,cChave,nTam) //BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
//��������������������������������������������������������������������������
//� Estrutura de retorno
//��������������������������������������������������������������������������
AaDd(aRet, {"Field_NOMEXE"	,BAU->BAU_NOME } )
//AaDd(aRet, {"Field_CPFEXE"	,XXX->XXX_SUBCON } )
//AaDd(aRet, {"Field_NOMEXE"	,XXX->XXX_NOMUSR } )
//AaDd(aRet, {"Field_CONEXE"	,XXX->XXX_TIPUSU } )

RestArea(aArea)
//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
Return( {cMsg,aRet} )

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLGATXXX  � Autor � Totvs					� Data � 05/02/12 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Gatilho do Usuario na tabela espelho						  ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
User Function PLGATPAD()
LOCAL aArea  := GetArea()
LOCAL cChave := paramixb[1]
LOCAL cMsg 	 := ""
LOCAL nTam	 := BR8->(TamSx3("BR8_CODPAD")[1]+TamSx3("BR8_CODPSA")[1] )
LOCAL aRet	 := {}
//��������������������������������������������������������������������������
//� Verifica se o registro existe
//��������������������������������������������������������������������������
cMsg := POSREG("BR8",1,cChave,nTam) //BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
//��������������������������������������������������������������������������
//� Estrutura de retorno
//��������������������������������������������������������������������������
AaDd(aRet, {"cDesProSSol"	,BR8->BR8_DESCRI } )
//AaDd(aRet, {"Field_CPFEXE"	,XXX->XXX_SUBCON } )
//AaDd(aRet, {"Field_NOMEXE"	,XXX->XXX_NOMUSR } )
//AaDd(aRet, {"Field_CONEXE"	,XXX->XXX_TIPUSU } )

RestArea(aArea)
//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
Return( {cMsg,aRet} )

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLGATBTQ  � Autor � Totvs					� Data � 17/07/14 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Gatilho do Procedimento na tabela tiss				        ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
User Function PLGATBTQ()
LOCAL aArea   := GetArea()
LOCAL cChave  := paramixb[1]
LOCAL cMsg 	  := ""
LOCAL nTam	  := BTQ->(TamSx3("BTQ_CODTAB")[1]+TamSx3("BTQ_CDTERM")[1] )
LOCAL aRet	  := {}
LOCAL cTipGui := paramixb[6]
LOCAL cDesPro := NIL 
LOCAL cString := NIL 
LOCAL cEncode := NIL 

//��������������������������������������������������������������������������
//� Verifica se o registro existe
//��������������������������������������������������������������������������
cMsg := POSREG("BTQ",1,cChave,nTam,'BTQ_VIGATE',DTOS(dDataBase)) //BTQ_FILIAL+BTQ_CODTAB+BTQ_CDTERM
//��������������������������������������������������������������������������
//� Estrutura de retorno
//��������������������������������������������������������������������������
If Empty(cTipGui)
	cTipGui := B7B->B7B_TIPGUI
Endif

//a fun��o decodeUTF8 n�o est� convertendo determinados caracteres, desta forma � necess�rio utilizar a  
//fun��o LOWERACE para converter a string para minuscula e converter o caracter para ANSI e em seguida
//usar o encodeUTF8 para conveter a string para UTF-8 e depois usar a fun��o decodeUTF8 que converte a string
//para CP1252.
	
cDesPro := decodeUTF8(BTQ->BTQ_DESTER)
	
If cDesPro == NIL
	cString := LOWERACE(AllTrim(BTQ->BTQ_DESTER))
	cEncode := encodeUTF8(cString)
	cDesPro := UPPER(decodeUTF8(cEncode))
EndIf 

If (Alltrim(cTipGui) $ '01,02,03,11')
	AaDd(aRet, {"cDesProSSol", UPPER(cDesPro)} ) 
ElseIf (Alltrim(cTipGui) $ '05,06,12,05') //Guia de Honor�rios e Outras Despesas
	AaDd(aRet, {"cDesProSExe", UPPER(cDesPro)} )
ElseIf (Alltrim(cTipGui) $ '07,08,09')//OPME, Quimioterapia, Radioterapia
	AaDd(aRet, {"B4C_DESPRO", UPPER(cDesPro)} )
Else
	AaDd(aRet, {"cDesProSExe", UPPER(cDesPro)} )
Endif
//AaDd(aRet, {"Field_CPFEXE"	,XXX->XXX_SUBCON } )
//AaDd(aRet, {"Field_NOMEXE"	,XXX->XXX_NOMUSR } )
//AaDd(aRet, {"Field_CONEXE"	,XXX->XXX_TIPUSU } )

RestArea(aArea)
//��������������������������������������������������������������������������
//� Fim da Funcao
//������������������������������������������3��������������������������������
Return( {cMsg,aRet} )



/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLGATEXE  � Autor � Totvs					� Data � 30/11/14 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Gatilho do Procedimento na tabela tiss - Campos 40 e 41
��� da Guia SP/SADT
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
User Function PLGATEXE()
LOCAL aArea  := GetArea()
LOCAL cChave := paramixb[1]
LOCAL cMsg 	 := ""
LOCAL nTam	 := BTQ->(TamSx3("BTQ_CODTAB")[1]+TamSx3("BTQ_CDTERM")[1] )
LOCAL aRet	 := {}
LOCAL cTipGui:= paramixb[6]
LOCAL cCodPadTiss := substr(cChave,1,BTQ->(TamSx3("BTQ_CODTAB")[1]))
LOCAL cCodProTiss := substr(cChave,BTQ->(TamSx3("BTQ_CODTAB")[1])+1,BTQ->(TamSx3("BTQ_CDTERM")[1]))
LOCAL cCodPad := ""
LOCAL cCodPro := ""
LOCAL cDesPro := ""
PRIVATE aTabDup := PlsBusTerDup(SuperGetMv("MV_TISSCAB",.F.,"87"))

cCodPad := AllTrim(PLSVARVINC('87','BR4', cCodPadTiss))
cCodPro := AllTrim(PLSVARVINC(cCodPadTiss,'BR8',cCodProTiss, cCodPad+cCodProTiss,,aTabDup,@CCODPAD))

//��������������������������������������������������������������������������
//� Verifica se o registro existe
//��������������������������������������������������������������������������
cMsg := POSREG("BTQ",1,cChave,nTam) //BTQ_FILIAL+BTQ_CODTAB+BTQ_CDTERM

If Empty(cTipGui)
	cTipGui := B7B->B7B_TIPGUI
Endif

If (Alltrim(cTipGui) $ '02,12,05')
	cDesPro := decodeUTF8(BTQ->BTQ_DESTER)
	// decodeUTF8 retornou nil
	if cDesPro == nil .or. empty(cDesPro)
		cDesPro := FwNoAccent(BTQ->BTQ_DESTER)
	endIf
	
	AaDd(aRet, {"cDesProSExe"	,allTrim(cDesPro) } )
	
	BR8->(dbSetOrder(1))
	if (BR8->(msseek(xFilial("BR8")+cCodPad+cCodPro))) // BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN
		AaDd(aRet, {"cTpProc", iif(empty(BR8->BR8_TPPROC), "0", BR8->BR8_TPPROC)}) // uso para calcular os campos de total na guia
	endIf
	
Endif

RestArea(aArea)

Return( {cMsg,aRet} )


/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLGATBVV  � Autor � Totvs					� Data � 03/04/14 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Gatilho do Procedimento na tabela tiss				        ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
User Function PLGATBVV()

LOCAL aArea  := GetArea()
LOCAL cChave := paramixb[1]
LOCAL cMsg 	 := ""
LOCAL nTam	 := BTQ->(TamSx3("BTQ_CODTAB")[1]+TamSx3("BTQ_CDTERM")[1] )
LOCAL aRet	 := {}
//��������������������������������������������������������������������������
//� Verifica se o registro existe
//��������������������������������������������������������������������������
cMsg := POSREG("BTQ",1,cChave,nTam) //BTQ_FILIAL+BTQ_CODTAB+BTQ_CDTERM
//��������������������������������������������������������������������������
//� Estrutura de retorno
//��������������������������������������������������������������������������

AaDd(aRet, {"cDesProSE"	, DecodeUtf8(BTQ->BTQ_DESTER) } )

RestArea(aArea)
//��������������������������������������������������������������������������
//� Fim da Funcao
//������������������������������������������3��������������������������������
Return( {cMsg,aRet} )

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLGATSOLT  � Autor � Totvs					� Data � 17/07/14 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Gatilho do nome da rda solt							        ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
User Function PLGATSOLT() 
LOCAL aArea  := GetArea()
LOCAL cChave := paramixb[1]
LOCAL cMsg 	 := ""
LOCAL nTam	 := BAU->(TamSx3("BAU_CPFCGC")[1])
LOCAL aRet	 := {}
LOCAL cTipGui:= paramixb[6]
//��������������������������������������������������������������������������
//� Verifica se o registro existe
//��������������������������������������������������������������������������
cMsg := POSREG("BAU",4,cChave,nTam) 
//��������������������������������������������������������������������������
//� Estrutura de retorno
//��������������������������������������������������������������������������
If Empty(cTipGui)
	cTipGui := B7B->B7B_TIPGUI
Endif

If (Alltrim(cTipGui) == '03')
	AaDd(aRet, {"cNomeSolT"	,BAU->BAU_NOME } )
EndIf


RestArea(aArea)
//��������������������������������������������������������������������������
//� Fim da Funcao
//������������������������������������������3��������������������������������
Return( {cMsg,aRet} ) 

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLGATSOLT  � Autor � Totvs					� Data � 17/07/14 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Gatilho do nome da rda solt							        ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
User Function PLGATBAQ()
LOCAL aArea  := GetArea()
LOCAL cChave := paramixb[1]
LOCAL cMsg 	 := ""
LOCAL nTam	 := BAQ->(TamSx3("BAQ_CODESP")[1])
LOCAL aRet	 := {}

//��������������������������������������������������������������������������
//� Verifica se o registro existe
//��������������������������������������������������������������������������
cMsg := POSREG("BAQ",1,PLSINTPAD()+cChave,nTam) //BTQ_FILIAL+BTQ_CODTAB+BTQ_CDTERM

AaDd(aRet, {"cB9Q_DESESP"	,BAQ->BAQ_DESCRI } )


RestArea(aArea)
//��������������������������������������������������������������������������
//� Fim da Funcao
//������������������������������������������3��������������������������������
Return( {cMsg,aRet} )
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PLGATBA0
Gatilho operadoras

@author		PLS TEAM
@since		15/10/2015
@version	P11 
@Return	L
/*/
//---------------------------------------------------------------------------------------
User Function PLGATBA0()
LOCAL aArea  := GetArea()
LOCAL cChave := paramixb[1]
LOCAL cMsg 	 := ""
LOCAL nTam	 := BA0->(TamSx3("BA0_CODIDE")[1] )+BA0->(TamSx3("BA0_CODINT")[1] )
LOCAL aRet	 := {}

//Verifica se o registro existe
cMsg := POSREG("BA0",1,cChave,nTam) //BA0_FILIAL+BA0_CODIDE+BA0_CODINT

//Estrutura de retorno
aaDd(aRet, {"Field_NOMINT"	,BA0->BA0_NOMINT } )

RestArea(aArea)

//Fim da Funcao
return( {cMsg,aRet} )

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PGATBAUF
Gatilho para BAU

@author		PLS TEAM
@since		15/10/2015
@version	P11 
@Return	L
/*/
//---------------------------------------------------------------------------------------
User Function PGATBAU()
LOCAL aArea  := GetArea()
LOCAL cChave := paramixb[1]
LOCAL nTpRet := paramixb[2] //1=fisica,2=juridica
LOCAL cMsg 	 := ""
LOCAL nTam	 := BAU->(TamSx3("BAU_CODIGO")[1])
LOCAL aRet	 := {}

//Verifica se o registro existe
cMsg := POSREG("BAU",1,cChave,nTam) //BAU_FILIAL+BAU_CODIGO

if empty(cMsg)
	//fisica
	if nTpRet == 1
		cMsg :=  iIf(BAU->BAU_TIPPE != 'F',"Conteudo n�o encontrado","")
	else
		cMsg :=  iIf(BAU->BAU_TIPPE != 'J',"Conteudo n�o encontrado","")
	endIf	
endIf

//Estrutura de retorno
if nTpRet == 1
	aaDd(aRet, {"Field_NOMMED"	,BAU->BAU_NOME } )
else
	aaDd(aRet, {"Field_NOMHOS"	,BAU->BAU_NOME } )
endIf	

RestArea(aArea)
//��������������������������������������������������������������������������
//� Fim da Funcao
//������������������������������������������3��������������������������������
Return( {cMsg,aRet} )

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PLGATDESP
Gatilho para tabela 25 de despesas

@author	Karine Riquena Limp
@since		30/06/2016
@version	P12
@Return	A

/*/
//---------------------------------------------------------------------------------------
User Function PLGATDESP()

LOCAL aArea  := GetArea()
LOCAL cChave := "25"+paramixb[1]
LOCAL cMsg 	 := ""
LOCAL cCodPad := ""
LOCAL nTam	 := BTQ->(TamSx3("BTQ_CODTAB")[1]+TamSx3("BTQ_CDTERM")[1] )
LOCAL aRet	 := {}
//---------------------------------------------------------------------------------------
//� Verifica se o registro existe
//---------------------------------------------------------------------------------------
cMsg := POSREG("BTQ",1,cChave,nTam) //BTQ_FILIAL+BTQ_CODTAB+BTQ_CDTERM
//---------------------------------------------------------------------------------------
//� Estrutura de retorno
//---------------------------------------------------------------------------------------
do case
  case paramixb[1] $ "01,05,07"
     cCodPad := "18"
  case paramixb[1] $ "03,08"
     cCodPad := "19"
  case paramixb[1] $ "02"
  	  cCodPad := "20"
endCase

AaDd(aRet, {"cCodPadSExe"	, cCodPad } )

RestArea(aArea)

Return( {cMsg,aRet} )
