#Include "DMESA.ch"
#Include "Protheus.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �DMESA     � Autor �  Luciana P. Munhoz    � Data � 22.03.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �DMES - Declara��o de Movimento Econ�mico de Servi�os do 	  ���
���          �Munic�pio de Americana - SP								  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpD -> Data inicial do periodo - mv_par01     			  ���
���          �ExpD -> Data final do periodo - mv_par02                    ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function DMESA(dDtInicial, dDtFinal)
	Local aTrbs		:= {}
	Private aCfp 	:= {}

	//�������������������������������������Ŀ
	//�Gera arquivos temporarios            �
	//���������������������������������������
	aTrbs := GeraTemp()
	
	//�������������������������������������Ŀ
	//�Rotina Cfp                           �
	//���������������������������������������
	If Cfp()
		//������������������������������������������������������������������������Ŀ
		//�Recupera dados do arquivo Cfp                                           �
		//��������������������������������������������������������������������������
		xMagLeWiz("DMESA",@aCfp,.T.)
	
		Processa({||ProcDMESA(dDtInicial, dDtFinal)})
	Endif

Return (aTrbs)

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �ProcDMESA  � Autor �Luciana P. Munhoz      � Data � 22.03.06 ���
��������������������������������������������������������������������������Ĵ��
���Descricao �Processa Registro da DMES de Americana - SP                  ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function ProcDMESA(dDtInicial, dDtFinal)
	
	//������������������������������������������������������������������������Ŀ
	//�Processa Regitros                                                       �
	//��������������������������������������������������������������������������

	ProcReg1(dDtInicial) 					//Registro Tipo 1 - Empresa Respons�vel pelos dados
	// Processo o resgistro 3 antes do 2, porque preciso saber se existe movimento.
	nReg := ProcReg3(dDtInicial, dDtFinal) 	//Registro Tipo 3 - Registro de Movimento
	ProcReg2(dDtInicial, dDtFinal ,nReg) 	//Registro Tipo 2 - Registro do Declarante
                                
Return Nil

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �ProcReg1   � Autor �Luciana P. Munhoz      � Data � 22.03.06 ���
��������������������������������������������������������������������������Ĵ��
���Descricao �Processa Registro Tipo 1 - Empresa Respons�vel pelos dados   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function ProcReg1(dDtInicial)

	dbSelectArea("RT1")
	RecLock("RT1",.T.)	
	
	RT1->EMPRESA 	:= AllTrim(SM0->M0_NOMECOM)
	RT1->ENDERECO  	:= AllTrim(SM0->M0_ENDENT)
	RT1->BAIRRO		:= Alltrim(SM0->M0_BAIRENT)
	RT1->MUNICIPIO	:= Alltrim(SM0->M0_CIDENT)
	RT1->UF			:= Alltrim(SM0->M0_ESTENT)
	RT1->CEP		:= aFisFill(SM0->M0_CEPENT,8)
	RT1->CNPJEMP	:= Val(aFisFill(SM0->M0_CGC,14))
	RT1->IMEMP		:= Iif(Alltrim(SM0->M0_CIDENT)=="AMERICANA" .And. Alltrim(SM0->M0_ESTENT)=="SP",Val(Alltrim(aCfp[1][02])),Val(Substr(Alltrim(SM0->M0_CGC),1,6)))
	RT1->IEEMP		:= Val(aFisFill(SM0->M0_INSC,15))
	RT1->NOMECONT	:= Alltrim(aCfp[1][03])
	RT1->CPFCONT	:= Val(Alltrim(aCfp[1][04]))
	RT1->FONECONT	:= Alltrim(aCfp[1][05])
	RT1->EMAILCONT	:= Alltrim(aCfp[1][06])
	RT1->DATAGERA	:= DataInt(dDataBase)
	RT1->MESAPU		:= StrZero(Month(dDtInicial),2)
	RT1->ANOAPU		:= StrZero(Year(dDtInicial),4)
	RT1->RETIFICA	:= Left(Alltrim(aCfp[1][01]),1)

	MsUnlock() 
	
Return Nil 

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �ProcReg2   � Autor �Luciana P. Munhoz      � Data � 22.03.06 ���
��������������������������������������������������������������������������Ĵ��
���Descricao �Processa Registro Tipo 2 - Registro Declarante               ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function ProcReg2(dDtInicial,dDtFinal,nReg)
	
	dbSelectArea("RT2")
	RecLock("RT2",.T.)	
	
	RT2->RSOCIAL	:= Alltrim(aCfp[2][02])
	RT2->ENDERECO	:= Alltrim(aCfp[2][03])
	RT2->BAIRRO		:= Alltrim(aCfp[2][04])
	RT2->MUNICIPIO	:= Alltrim(aCfp[2][07])
	RT2->UF			:= Alltrim(aCfp[2][05])
	RT2->CEP		:= Alltrim(aCfp[2][06])
	RT2->CPFCNPJ	:= Val(Alltrim(aCfp[3][01]))
	RT2->IMDECLAR  	:= Iif(Alltrim(aCfp[2][07])=="AMERICANA" .And. Alltrim(aCfp[2][05])=="SP",Val(Alltrim(aCfp[3][02])),Val(Substr(Alltrim(aCfp[3][01]),1,6)))
	RT2->IEDECLAR	:= Val(Alltrim(aCfp[3][03]))
	RT2->ATIVIDADE	:= Alltrim(aCfp[3][04])
	RT2->CNAE		:= Val(Alltrim(aCfp[3][05]))
	RT2->DATAGERA	:= DataInt(dDataBase)
	RT2->MESAPU		:= StrZero(Month(dDtInicial),2)
	RT2->ANOAPU    	:= StrZero(Year(dDtInicial),4)
	RT2->TOMAPREST	:= Left(Alltrim(aCfp[3][06]),1)
	RT2->REGIME		:= Left(Alltrim(aCfp[2][01]),1)
	RT2->MOVIMEN	:= Iif(nReg>0,"S","N")

	MsUnlock() 
	
Return Nil 


/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �ProcReg3   � Autor �Luciana P. Munhoz      � Data � 22.03.06 ���
��������������������������������������������������������������������������Ĵ��
���Descricao �Processa Registro Tipo 3 - Registro de Movimento             ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function ProcReg3(dDtInicial, dDtFinal)
	Local cAliasSF3		:= "SF3"
	Local cRSocial		:= ""
	Local cCNPJ			:= ""
	Local cInscrM		:= ""	
	Local cInscrE		:= ""		
	Local cCidade		:= ""		
	Local cEstado		:= ""		
	
	Local nContador		:= 0  
	
	Local lVazio		:= .T.
	
	#IFDEF TOP
		Local nX			:= 0     
		Local aStruSF3	:= {}                                       
		Local lQuery	:= .F.
	#ELSE
		Local cChave	:= ""
	#ENDIF
     
	//��������������������������������������������������������������������������������������������Ŀ
	//�Seleciona a Movimenta��o de Entradas e Saidas                  							   �
	//����������������������������������������������������������������������������������������������
	
	dbSelectArea("SF3")
	dbSetOrder(1)               
	ProcRegua(LastRec())
	
	#IFDEF TOP    
	    If TcSrvType()<>"AS/400"
			lQuery		:= .T.
			cAliasSF3	:= "SF3_DMESA"
			aStruSF3	:= SF3->(dbStruct())
			cQuery		:= "SELECT F3_DTCANC, F3_NFISCAL, F3_EMISSAO, F3_CLIEFOR, F3_CFO, "
			cQuery    	+= "F3_ALIQICM, F3_VALCONT, F3_VALICM, F3_RECISS, F3_BASEICM, F3_LOJA "
			cQuery    	+= "FROM " + RetSqlName("SF3") + " "
			cQuery    	+= "WHERE F3_FILIAL = '" + xFilial("SF3") + "' AND "
			cQuery 		+= "F3_ENTRADA >= '" + Dtos(dDtInicial) + "' AND "
			cQuery 		+= "F3_ENTRADA <= '" + Dtos(dDtFinal) + "' AND "  
			cQuery 		+= "F3_TIPO = 'S' AND "  			
			cQuery 		+= "D_E_L_E_T_ = ' ' "
			cQuery 		+= "ORDER BY "+SqlOrder(SF3->(IndexKey()))
			cQuery 		:= ChangeQuery(cQuery)                       			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3)   
				
			For nX := 1 To len(aStruSF3)
				If aStruSF3[nX][2] <> "C" .And. FieldPos(aStruSF3[nX][1])<>0
					TcSetField(cAliasSF3,aStruSF3[nX][1],aStruSF3[nX][2],aStruSF3[nX][3],aStruSF3[nX][4])
				EndIf
			Next nX
			dbSelectArea(cAliasSF3)	
		Else
	#ENDIF
		    cIndex    := CriaTrab(NIL,.F.)
		    cCondicao := 'F3_FILIAL == "' + xFilial("SF3") + '" .And. '
		   	cCondicao += 'DTOS(F3_ENTRADA) >= "' + DTOS(dDtInicial) + '" '
		   	cCondicao += '.And. DTOS(F3_ENTRADA) <= "' + DTOS(dDtFinal) + '" '
		   	cCondicao += '.And. F3_TIPO $ "S" '
		    IndRegua(cAliasSF3,cIndex,SF3->(IndexKey()),,cCondicao)
		    nIndex := RetIndex("SF3")
				
			#IFNDEF TOP
				dbSetIndex(cIndex+OrdBagExt())
			#ENDIF    
			dbSelectArea("SF3")
		    dbSetOrder(nIndex+1)
		    dbSelectArea(cAliasSF3)
		    ProcRegua(LastRec())
	    	dbGoTop()
	#IFDEF TOP
		Endif                                           
	#ENDIF

	Do While !(cAliasSF3)->(Eof())

		//������������������Ŀ
		//�Cliente/Fornecedor�
		//��������������������

		If SubStr((cAliasSF3)->F3_CFO,1,1) >= "5"
			If ! SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
				(cAliasSF3)->(dbSkip())
				Loop				
			Else
				cRSocial	:= SA1->A1_NOME
				cCNPJ		:= SA1->A1_CGC 
				cInscrM		:= SA1->A1_INSCRM 	
				cInscrE		:= SA1->A1_INSCR	
				cCidade		:= SA1->A1_MUN		
				cEstado		:= SA1->A1_EST		
			Endif
		Else
			If ! SA2->(dbSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
				(cAliasSF3)->(dbSkip())
				Loop
			Else
				cRSocial	:= SA2->A2_NOME
				cCNPJ		:= SA2->A2_CGC 
				cInscrM		:= SA2->A2_INSCRM 	
				cInscrE		:= SA2->A2_INSCR	
				cCidade		:= SA2->A2_MUN		
				cEstado		:= SA2->A2_EST		
			Endif 		
		Endif	                                       
		
		//�������������������������������������������Ŀ
		//�Incluindo dados na Tabela RT3              �
		//���������������������������������������������
  		
  		dbSelectArea("RT3")
		RecLock("RT3",.T.)	
		
		RT3->IMDECLAR	:= Val(Alltrim(aCfp[3][02]))
		RT3->NUMDOC    	:= (cAliasSF3)->F3_NFISCAL
		RT3->DATADOC  	:= DataInt(SF3->F3_EMISSAO)
		RT3->RSOCIALD  	:= cRSocial
		RT3->CPFCNPJ  	:= Val(cCNPJ)
		RT3->IMDEST  	:= Val(cInscrM)
		RT3->IEDEST  	:= Val(cInscrE)
		RT3->CIDADE  	:= cCidade
		RT3->UF  		:= cEstado
		RT3->VALDOC  	:= (cAliasSF3)->F3_VALCONT
		RT3->DEDUCOES	:= (cAliasSF3)->F3_BASEICM
		RT3->VALSERV	:= ((cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM)  
		RT3->VALALIQ	:= (cAliasSF3)->F3_ALIQICM
		RT3->VALICMS	:= (cAliasSF3)->F3_VALICM
		RT3->ISSRET		:= Iif ((cAliasSF3)->F3_RECISS=="1","S","N")
		RT3->DOCCANC	:= Iif (! Empty((cAliasSF3)->F3_DTCANC),"S","N") 
	
		MsUnlock() 
		
		nContador++
		lVazio	:= .F.
		
		(cAliasSF3)->(dbSkip())		           
	Enddo 
	
	If lVazio
  		dbSelectArea("RT3")
		RecLock("RT3",.T.)	
		
		RT3->IMDECLAR	:= 000000000000000
		RT3->NUMDOC    	:= "000000000000000"
		RT3->DATADOC  	:= "00000000"
		RT3->RSOCIALD  	:= Replicate(" ",50)
		RT3->CPFCNPJ  	:= 00000000000000
		RT3->IMDEST  	:= 000000000000000
		RT3->IEDEST  	:= 000000000000000
		RT3->CIDADE  	:= Replicate(" ",30)
		RT3->UF  		:= "  "
		RT3->VALDOC  	:= 00000000000000
		RT3->DEDUCOES	:= 00000000000000
		RT3->VALSERV	:= 00000000000000
		RT3->VALALIQ	:= 0
		RT3->VALICMS	:= 00000000000000
		RT3->ISSRET		:= " "
		RT3->DOCCANC	:= " "
	Endif 

	//���������������������������������������Ŀ
	//�Exclui area de trabalho utilizada - SF3�
	//�����������������������������������������
	If !lQuery
		RetIndex("SF3")	
		dbClearFilter()	
		Ferase(cIndex+OrdBagExt())
	Else
		dbSelectArea(cAliasSF3)
		dbCloseArea()
	Endif
Return (nContador) 

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �GeraTemp   � Autor �Luciana P. Munhoz      � Data � 22.03.06 ���
��������������������������������������������������������������������������Ĵ��
���Descricao �Gera arquivos temporarios                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function GeraTemp()
	Local aStru		:= {}
	Local aTrbs		:= {}
	Local cArq		:= ""
	
	//���������������������������������������������������������������������������������������������������������������Ŀ
	//�Registro Tipo 1 - Empresa Respons�vel pelos dados															  �
	//�����������������������������������������������������������������������������������������������������������������
	aStru	:= {}
	cArq	:= ""
	AADD(aStru,{"EMPRESA"	    ,"C",050,0})	//Empresa
	AADD(aStru,{"ENDERECO"		,"C",050,0})	//Endere�o
	AADD(aStru,{"BAIRRO"		,"C",030,0})   	//Bairro
	AADD(aStru,{"MUNICIPIO"  	,"C",030,0})   	//Municipio
	AADD(aStru,{"UF"       		,"C",002,0}) 	//UF
	AADD(aStru,{"CEP"	    	,"C",008,0}) 	//CEP
	AADD(aStru,{"CNPJEMP"    	,"N",014,0})	//CNPJ da empresa
	AADD(aStru,{"IMEMP"     	,"N",015,0})	//Inscri��o Municipal
	AADD(aStru,{"IEEMP"  		,"N",015,0})	//Inscri��o Estadual
	AADD(aStru,{"NOMECONT"  	,"C",050,0})	//Nome do Contador
	AADD(aStru,{"CPFCONT"  		,"N",014,0})	//CPF do Contador
	AADD(aStru,{"FONECONT"  	,"C",015,0})	//Fone do Contador
	AADD(aStru,{"EMAILCONT"  	,"C",080,0})	//E-mail do Contador	
	AADD(aStru,{"DATAGERA"  	,"C",008,0})	//Data da gera��o - DDMMAAAA
	AADD(aStru,{"MESAPU"  		,"C",002,0})	//M�s da Apura��o - MM
	AADD(aStru,{"ANOAPU"	  	,"C",004,0})	//Ano da Apura��o - AAAA
	AADD(aStru,{"RETIFICA"  	,"C",001,0})	//Arquivo Retificador - S/N
	
	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RT1")                      	
	IndRegua("RT1",cArq,"CNPJEMP")
	AADD(aTrbs,{cArq,"RT1"})
	
	//���������������������������������������������������������������������������������������������������������������Ŀ
	//�Registro Tipo 2 - Registro do Declarante																		  �
	//�����������������������������������������������������������������������������������������������������������������
	aStru	:= {}
	cArq	:= ""	
	AADD(aStru,{"RSOCIAL"	    ,"C",050,0})	//Raz�o Social do Declarante
	AADD(aStru,{"ENDERECO"		,"C",050,0})	//Endere�o
	AADD(aStru,{"BAIRRO"		,"C",030,0})   	//Bairro
	AADD(aStru,{"MUNICIPIO"   	,"C",030,0})	//Municipio
	AADD(aStru,{"UF"  			,"C",002,0})	//UF
	AADD(aStru,{"CEP"  			,"C",008,0})	//CEP
	AADD(aStru,{"CPFCNPJ"  		,"N",014,0})	//CPF/CNPJ do Declarante
	AADD(aStru,{"IMDECLAR" 		,"N",015,0})	//Inscri��o Municipal do Declarante
	AADD(aStru,{"IEDECLAR"   	,"N",015,0})	//Inscri��o Estadual do Declarante
	AADD(aStru,{"ATIVIDADE"  	,"C",050,0})   	//Atividade
	AADD(aStru,{"CNAE"  		,"N",015,0})	//CNAE
	AADD(aStru,{"DATAGERA"  	,"C",008,0})	//Data da Gera��o - DDMMAAAA
	AADD(aStru,{"MESAPU"  		,"C",002,0})	//M�s da Apura��o - MM
	AADD(aStru,{"ANOAPU"	  	,"C",004,0})	//Ano da Apura��o - AAAA
	AADD(aStru,{"TOMAPREST"  	,"C",001,0})	//Tomador / Prestador - T/P
	AADD(aStru,{"REGIME"	  	,"C",001,0})	//Regime do Declarante - E/V/O
	AADD(aStru,{"MOVIMEN"  		,"C",001,0})	//Movimento / Sem Movimento - S/N
	
	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RT2")
	IndRegua("RT2",cArq,"IMDECLAR")
	AADD(aTrbs,{cArq,"RT2"})
	
	//���������������������������������������������������������������������������������������������������������������Ŀ                           
	//�Registro Tipo 3 - Registro de Movimento																		  �
	//�����������������������������������������������������������������������������������������������������������������
	aStru	:= {}
	cArq	:= ""
	AADD(aStru,{"IMDECLAR" 		,"N",015,0})	//Inscri��o Municipal do Declarante
	AADD(aStru,{"NUMDOC"	    ,"C",015,0})	//Numero do Documento Fiscal
	AADD(aStru,{"DATADOC"		,"C",008,0})	//Data do Documento Fiscal - DDMMAAAA
	AADD(aStru,{"RSOCIALD"		,"C",050,0})   	//Nome / Raz�o Social do Destinat�rio
	AADD(aStru,{"CPFCNPJ"  		,"N",014,0})	//CPF/CNPJ do Destinat�rio
	AADD(aStru,{"IMDEST" 		,"N",015,0})	//Inscri��o Municipal do Destinat�rio
	AADD(aStru,{"IEDEST"  	 	,"N",015,0})	//Inscri��o Estadual do Destinat�rio
	AADD(aStru,{"CIDADE" 		,"C",030,0})	//Cidade do Destinat�rio
	AADD(aStru,{"UF"      		,"C",002,0})	//UF do Destinat�rio
	AADD(aStru,{"VALDOC"  		,"N",014,2})	//Valor do Documento Fiscal
	AADD(aStru,{"DEDUCOES" 		,"N",014,2})	//Valor das Dedu��es Legais
	AADD(aStru,{"VALSERV"     	,"N",014,2})	//Valor dos Servi�os
	AADD(aStru,{"VALALIQ" 		,"N",001,0})	//Valor da Al�quota
	AADD(aStru,{"VALICMS" 		,"N",014,2})	//Valor do Imposto
	AADD(aStru,{"ISSRET" 		,"C",001,0})	//ISS Retido na Fonte - S/N
	AADD(aStru,{"DOCCANC" 		,"C",001,0})	//Documento Fiscal cancelado - S/N
	
	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RT3")
	IndRegua("RT3",cArq,"NUMDOC")
	AADD(aTrbs,{cArq,"RT3"})

Return (aTrbs)

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �CFP        � Autor �Luciana P. Munhoz		 � Data � 22.03.06 ���
��������������������������������������������������������������������������Ĵ��
���Descricao �Rotina CFP                                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function CFP()
	Local aTxtPre 		:= {}
	Local aPaineis 		:= {}
	
	Local cTitObj1		:= ""
	Local cTitObj2		:= ""       
	Local cMask1		:= Replicate("!",80)	//Mascara de e-MAIL
	Local cMask2		:= Replicate("!",30)	//Mascara de Bairro / Municipio
	Local cMask3		:= Replicate("!",50)	//Mascara do Nome / Endere�o   

	Local nPos			:= 0

	//�����������������������������������������Ŀ
	//�Monta wizard com as perguntas necessarias�
	//�������������������������������������������
	AADD(aTxtPre,STR0001)			//"Assistente de parametriza��o da DMES"
	AADD(aTxtPre,STR0002)			//"Aten��o"
	AADD(aTxtPre,STR0003)			//"Preencha as informa��es solicitadas para a gera��o do arquivo magn�tico: "
	AADD(aTxtPre,STR0004)	   		//"DMES - Declara��o de Movimento Econ�mico de Servi�os do Munic�pio         de Americana - SP"
		
	//���������������������������������������������������������������������������������������Ŀ
	//�Painel 1 - Empresa Respons�vel pelos dados 											  �
	//�����������������������������������������������������������������������������������������
	
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],STR0005)	//"Assistente de parametriza��o"
	aAdd(aPaineis[nPos],STR0006)	//"Informa��es sobre a Empresa Respons�vel pelos Dados: "
	aAdd(aPaineis[nPos],{})
	
	cTitObj1 :=	STR0007				//"Arquivo Retificador?" 				//Cfp[1][01]
	cTitObj2 :=	STR0008				//"Inscri��o Municipal?"       			//Cfp[1][02]
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{3,,,,,{STR0009,STR0010},,})  					//"Sim","N�o"
	aAdd(aPaineis[nPos][3],{2,,"999999999999999",1,,,,15})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	
	cTitObj1 :=	STR0011				//"Nome do Contador?"					//Cfp[1][03]
	cTitObj2 :=	STR0012				//"CPF do Contador?"					//Cfp[1][04]
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask3,1,,,,50})
	aAdd(aPaineis[nPos][3],{2,,"99999999999999",1,,,,14})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})     
	
	cTitObj1 :=	STR0013				//"Fone do Contador?"					//Cfp[1][05]
	cTitObj2 :=	STR0014				//"E-mail do Contador?"					//Cfp[1][06]
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"999999999999999",1,,,,15})
	aAdd(aPaineis[nPos][3],{2,,cMask1,1,,,,80})          			
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})     
	
	//���������������������������������������������������������������������������������������Ŀ
	//�Painel 2 - Registro do Declarante					  								  �
	//�����������������������������������������������������������������������������������������
	
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],STR0005)	//"Assistente de parametriza��o"
	aAdd(aPaineis[nPos],STR0015)	//"Informa��es sobre o Registro do Declarante: "
	aAdd(aPaineis[nPos],{})
	
	cTitObj1 :=	STR0016				//"Regime do Declarante?" 				//Cfp[2][01]
	cTitObj2 :=	STR0017				//"Raz�o Social do Declarante?"       	//Cfp[2][02]
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{3,,,,,{STR0018,STR0019,STR0020},,})  			//"E - Valor Estimado","V - Regime Vari�vel (Aliq. Percentual)","O - Tomador de Servi�o"
	aAdd(aPaineis[nPos][3],{2,,cMask3,1,,,,50})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})

	cTitObj1 :=	STR0021				//"Endere�o do Declarante?"				//Cfp[2][03]
	cTitObj2 :=	STR0022				//"Bairro do Declarante?"				//Cfp[2][04]
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask3,1,,,,50})
	aAdd(aPaineis[nPos][3],{2,,cMask2,1,,,,30})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})     
	
	cTitObj1 :=	STR0023				//"UF do Declarante?"					//Cfp[2][05]
	cTitObj2 :=	STR0024				//"CEP do Declarante?"					//Cfp[2][06]
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"!!",1,,,,2})
	aAdd(aPaineis[nPos][3],{2,,"99999999",1,,,,8})          			
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})     
	
	cTitObj1 :=	STR0025				//"Munic�pio do Declarante?"			//Cfp[2][07]
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask2,1,,,,30})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})     	
	
	//�����������������������������������������������������������������������������������������������������Ŀ
	//�Painel 3 - Continua��o - Registro do Declarante														�
	//�������������������������������������������������������������������������������������������������������
	
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],STR0026) 	//"Assistente de parametriza��o - Continua��o" 
	aAdd(aPaineis[nPos],STR0015)	//"Informa��es sobre Registro do Declarante: "
	aAdd(aPaineis[nPos],{})

	cTitObj1 :=	STR0027				//"CPF/CNPJ do Declarante?"				//Cfp[3][01]
	cTitObj2 :=	STR0028				//"Inscri��o Municipal do Declarante?"  //Cfp[3][02]
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"99999999999999",1,,,,14})	
	aAdd(aPaineis[nPos][3],{2,,"999999999999999",1,,,,15})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	
	cTitObj1 := STR0029				//"Inscri��o Estadual do Declarante?"	//Cfp[3][03]
	cTitObj2 :=	STR0030				//"Descri��o do Ramo de Atividade?"		//Cfp[3][04]
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"999999999999999",1,,,,15})
	aAdd(aPaineis[nPos][3],{2,,cMask3,1,,,,50})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	
	cTitObj1 := STR0031				//"N�mero do CNAE?"						//Cfp[3][05]
	cTitObj2 :=	STR0032				//"Tomador/Prestador?"					//Cfp[3][06]
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"999999999999999",1,,,,15})
	aAdd(aPaineis[nPos][3],{3,,,,,{STR0033,STR0034},,})  					//"Tomador","Prestador"
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	                                                              
Return(xMagWizard(aTxtPre,aPaineis,"DMESA")) 

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �DMESADel    �Autor  �Luciana P. Munhoz   � Data � 22.03.2006  ���
���������������������������������������������������������������������������͹��
���Desc.     �Deleta os arquivos temporarios processados                    ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       �DMESA                                                         ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/         
Function DMESADel(aDelArqs)
	Local aAreaDel := GetArea()
	Local nI := 0
	
	For nI:= 1 To Len(aDelArqs)
		If File(aDelArqs[nI,1]+GetDBExtension())
			dbSelectArea(aDelArqs[ni,2])
			dbCloseArea()
			Ferase(aDelArqs[nI,1]+GetDBExtension())
			Ferase(aDelArqs[nI,1]+OrdBagExt())
		Endif	
	Next
	
	RestArea(aAreaDel)
	
Return
	
