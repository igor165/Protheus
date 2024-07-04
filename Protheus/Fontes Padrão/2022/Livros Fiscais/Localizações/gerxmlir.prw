#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "GERXMLIR.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GERXMLIR  ºAutor  ³Renato Nagib        º Data ³  09/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera xml das retencoes de IR para formulario modelo 3       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Equador                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±³LuisEnríquez³10/01/17³SERINN001-946³-Se realiza merge para agregar mo- ³±±
±±³            ³        ³             ³ dificacion en creacion de table   ³±±
±±³            ³        ³             ³ temporal CTREE.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GerXmlIR(dDataIni,dDataFim,_aTotal)
	
	Local cQryINT
	Local cQryEXT
	Local cQryCRED
	LocaL cLivro:=GETLIVRO()	
    Local aStruct:={}
	Local nBaseInt:=nValInt:=nBaseEx:=nValEx:=0
    Local cBase:='-'
    Local cValImp:='-'
	Local nImpPG  :=Val(_aTotal[1][5]) 
	Local nMoraInt:=Val(_aTotal[1][7]) 
	Local nMultaJu:=val(_aTotal[1][9])
	Local nValNfCred:=0
    Private aInfDec:=_aTotal
    Private oTmpTable := Nil
    Private aOrdem := {}
	
   	Aadd(aStruct,{"CPO303"  ,"C",16,0}) //Honorarios profissionais
	Aadd(aStruct,{"CPO353"  ,"C",16,0}) //Honorarios profissionais
	Aadd(aStruct,{"CPO304"  ,"C",16,0}) //Predomina o intelecto
	Aadd(aStruct,{"CPO354"  ,"C",16,0}) //Predomina o intelecto
	Aadd(aStruct,{"CPO307"  ,"C",16,0}) //Predomina a mao de obra
	Aadd(aStruct,{"CPO357"  ,"C",16,0}) //Predomina a mao de obra
	Aadd(aStruct,{"CPO308"  ,"C",16,0}) //Entre Sociedade
	Aadd(aStruct,{"CPO358"  ,"C",16,0}) //Entre Sociedade
	Aadd(aStruct,{"CPO309"  ,"C",16,0}) //Publicidade e comunicacao
	Aadd(aStruct,{"CPO359"  ,"C",16,0}) //Publicidade e comunicacao
	Aadd(aStruct,{"CPO310"  ,"C",16,0}) //Transporte privado de passageiros
	Aadd(aStruct,{"CPO360"  ,"C",16,0}) //Transporte privado de passageiros
	Aadd(aStruct,{"CPO312"  ,"C",16,0}) //Transferencia de bens moveis de natureza corporal
	Aadd(aStruct,{"CPO362"  ,"C",16,0}) //Transferencia de bens moveis de natureza corporal
	Aadd(aStruct,{"CPO319"  ,"C",16,0}) //Arredontamento mercantil
	Aadd(aStruct,{"CPO369"  ,"C",16,0}) //Arredontamento mercantil
	Aadd(aStruct,{"CPO320"  ,"C",16,0}) //Arredondamento bens imoveis
	Aadd(aStruct,{"CPO370"  ,"C",16,0}) //Arredondamento bens imoveis
	Aadd(aStruct,{"CPO322"  ,"C",16,0}) //Seguros
	Aadd(aStruct,{"CPO372"  ,"C",16,0}) //Seguros
	Aadd(aStruct,{"CPO323"  ,"C",16,0}) //Rendimentos financeiros
	Aadd(aStruct,{"CPO373"  ,"C",16,0}) //Rendimentos financeiros
	Aadd(aStruct,{"CPO325"  ,"C",16,0}) //Loterias,rifas,apostas e similares 
	Aadd(aStruct,{"CPO375"  ,"C",16,0}) //Loterias,rifas,apostas e similares 
	Aadd(aStruct,{"CPO327"  ,"C",16,0}) //Venda de combustiveis a comercializadores
	Aadd(aStruct,{"CPO377"  ,"C",16,0}) //Venda de combustiveis a comercializadores
	Aadd(aStruct,{"CPO328"  ,"C",16,0}) //Venda de combustiveis a distribuidores
	Aadd(aStruct,{"CPO378"  ,"C",16,0}) //Venda de combustiveis a distribuidores
	Aadd(aStruct,{"CPO332"  ,"C",16,0}) //Pagamento de bens ou servicos nao sujeitos a retencao
	Aadd(aStruct,{"CPO340"  ,"C",16,0}) //Outras retencoes 1%
	Aadd(aStruct,{"CPO390"  ,"C",16,0}) //Outras retencoes 1%
	Aadd(aStruct,{"CPO341"  ,"C",16,0}) //Outras retencoes 2%
	Aadd(aStruct,{"CPO391"  ,"C",16,0}) //Outras retencoes 2%
	Aadd(aStruct,{"CPO342"  ,"C",16,0}) //Outras retencoes 8%
	Aadd(aStruct,{"CPO392"  ,"C",16,0}) //Outras retencoes 8% 
	Aadd(aStruct,{"CPO343"  ,"C",16,0}) //Outras retencoes 25%
	Aadd(aStruct,{"CPO393"  ,"C",16,0}) //Outras retencoes 25%
	Aadd(aStruct,{"CPO349"  ,"C",16,0}) //Subtotal de operacoes efetuadas no pais
	Aadd(aStruct,{"CPO399"  ,"C",16,0}) //Subtotal de operacoes efetuadas no pais
	Aadd(aStruct,{"CPO401"  ,"C",16,0}) //Com convenio de dupla tributacao 
	Aadd(aStruct,{"CPO451"  ,"C",16,0}) //Com convenio de dupla tributacao 
	Aadd(aStruct,{"CPO403"  ,"C",16,0}) //Sem convenio de dupla tributacao -interesses por financiamento
	Aadd(aStruct,{"CPO453"  ,"C",16,0}) //Sem convenio de dupla tributacao -interesses por financiamento
	Aadd(aStruct,{"CPO405"  ,"C",16,0}) //interesses por creditos externos
	Aadd(aStruct,{"CPO455"  ,"C",16,0}) //interesses por creditos externos 
	Aadd(aStruct,{"CPO421"  ,"C",16,0}) //outros conceptos
	Aadd(aStruct,{"CPO471"  ,"C",16,0}) //outros conceptos
	Aadd(aStruct,{"CPO427"  ,"C",16,0}) //pagamentos ao exterior nao sujeito a retencao 
	Aadd(aStruct,{"CPO429"  ,"C",16,0}) //soma das bases
	Aadd(aStruct,{"CPO498"  ,"C",16,0}) //valor retido
	Aadd(aStruct,{"CPO499"  ,"C",16,0}) //Valor da retencao do imposto de renda
	
	Aadd(aStruct,{"CPO890"  ,"C",16,0}) //Pagamento previo
	Aadd(aStruct,{"CPO897"  ,"C",16,0}) //Imposto pago
	Aadd(aStruct,{"CPO898"  ,"C",16,0}) //Interes
	Aadd(aStruct,{"CPO899"  ,"C",16,0}) //Multa
	
	Aadd(aStruct,{"CPO902"  ,"C",16,0}) //Total de imposto
	Aadd(aStruct,{"CPO903"  ,"C",16,0}) //Interes
	Aadd(aStruct,{"CPO904"  ,"C",16,0}) //Multa
	Aadd(aStruct,{"CPO999"  ,"C",16,0}) //Total pago
	Aadd(aStruct,{"CPO905"  ,"C",16,0}) //Pagamento mediante a cheque
	Aadd(aStruct,{"CPO907"  ,"C",16,0}) //Mediante notas de credito
	
	Aadd(aStruct,{"CPO908"  ,"C",16,0}) //Numero nota de credito
	Aadd(aStruct,{"CPO910"  ,"C",16,0}) //Numero nota de credito
	Aadd(aStruct,{"CPO912"  ,"C",16,0}) //Numero nota de credito
	Aadd(aStruct,{"CPO914"  ,"C",16,0}) //Numero nota de credito
	Aadd(aStruct,{"CPO909"  ,"C",16,0}) //Valor da nota de credito
	Aadd(aStruct,{"CPO911"  ,"C",16,0}) //Valor da nota de credito
	Aadd(aStruct,{"CPO913"  ,"C",16,0}) //Valor da nota de credito
	Aadd(aStruct,{"CPO915"  ,"C",16,0}) //Valor da nota de credito
	
	oTmpTable := FWTemporaryTable():New('TRBSF3') 
	oTmpTable:SetFields( aStruct ) 
	aOrdem	:=	{"CPO303"} 
	oTmpTable:AddIndex("IN1", aOrdem) 
	oTmpTable:Create() 
	
	//PAGAMENTOS DE RETENCAO  EFETUADAS DENTRO DO PAIS
	cQryINT:=" SELECT F3_CONCEPT CONCEPT,"+CRLF
	cQryINT+=" SUM(F3_BASIMP"+cLivro+") BASIMP,"+CRLF
	cQryINT+=" SUM(F3_VALIMP"+cLivro+") VALIMP"+CRLF
	cQryINT+=" FROM "+RetSqlName('SF3')+" F3"+CRLF
	cQryINT+=" INNER JOIN "+RetSqlName('SA2')+" A2"+CRLF 
	cQryINT+=" ON A2_COD=F3_CLIEFOR AND A2_LOJA=F3_LOJA"+CRLF 
	cQryINT+=" WHERE F3_TIPOMOV='C'"+CRLF 
	cQryINT+=" AND F3_ESPECIE NOT IN ('NCP','NCI','NDP','NDI')
	cQryINT+=" AND F3_CONCEPT IN('303','304','307','308','309','310','312','319','320','322','323','325','327','328','332','340','341','342','343')"	
	cQryINT+=" AND A2_PAIS IN ('239','')"+CRLF
	cQryINT+=" AND F3_BASIMP"+cLivro+" > 0 "+CRLF 
	cQryINT+=" AND F3_FILIAL='"+xFilial('SF3')+"'"+CRLF 
	cQryINT+=" AND A2_FILIAL='"+xFilial('SA2')+"'"+CRLF 
	cQryINT+=" AND A2.D_E_L_E_T_=''"+CRLF 
	cQryINT+=" AND F3.D_E_L_E_T_=''"+CRLF 
	cQryINT+=" AND F3_ENTRADA BETWEEN '"+dDataIni+"' AND '"+dDataFim+"'"+CRLF
	cQryINT+=" GROUP BY F3_CONCEPT"
	cQryINT+=" ORDER BY F3_CONCEPT"+CRLF
	ChangeQuery(cQryINT)
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,Alltrim(cQryINT)),'TRBINT',.F.,.T.)	
	
	//PAGAMENTOS DE RETENCAO DE IR EFETUADAS AO EXTERIOR
	cQryEXT:=" SELECT F3_CONCEPT CONCEPT,"+CRLF
	cQryEXT+=" SUM(F3_BASIMP"+cLivro+") BASIMP,"+CRLF
	cQryEXT+=" SUM(F3_VALIMP"+cLivro+") VALIMP"+CRLF
	cQryEXT+=" FROM "+RetSqlName('SF3')+" F3"+CRLF
	cQryEXT+=" INNER JOIN "+RetSqlName('SA2')+" A2"+CRLF 
	cQryEXT+=" ON A2_COD=F3_CLIEFOR AND A2_LOJA=F3_LOJA"+CRLF 
	cQryEXT+=" WHERE F3_TIPOMOV='C'"+CRLF 
	cQryEXT+=" AND F3_ESPECIE NOT IN ('NCP','NCI','NDP','NDI')
	cQryEXT+=" AND F3_CONCEPT IN ('401','403','405','421','427')	
	cQryEXT+=" AND A2_PAIS = 'EX'"+CRLF
	cQryEXT+=" AND F3_BASIMP"+cLivro+" > 0 "+CRLF 
	cQryEXT+=" AND F3_FILIAL='"+xFilial('SF3')+"'"+CRLF 
	cQryEXT+=" AND A2_FILIAL='"+xFilial('SA2')+"'"+CRLF 
	cQryEXT+=" AND A2.D_E_L_E_T_=''"+CRLF 
	cQryEXT+=" AND F3.D_E_L_E_T_=''"+CRLF 
	cQryEXT+=" AND F3_ENTRADA BETWEEN '"+dDataIni+"' AND '"+dDataFim+"'"+CRLF
	cQryEXT+=" GROUP BY F3_CONCEPT"+CRLF
	cQryEXT+=" ORDER BY F3_CONCEPT"+CRLF	
	ChangeQuery(cQryEXT)
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,Alltrim(cQryEXT)),'TRBEXT',.F.,.T.)	
	
	//NOTAS DE CREDITO
	cQryCRED:=" SELECT F3_NFISCAL NFISCAL,"+CRLF
	cQryCRED+=" SUM(F3_VALIMP"+cLivro+") VALIMP"+CRLF
	cQryCRED+=" FROM "+RetSqlName('SF3')+" F3"+CRLF
	cQryCRED+=" WHERE F3_TIPOMOV='C'"+CRLF 
	cQryCRED+=" AND F3_BASIMP"+cLivro+" > 0 "+CRLF 
	cQryCRED+=" AND F3_VALIMP"+cLivro+" > 0 "+CRLF 
	cQryCRED+=" AND F3_ESPECIE IN('NCP','NDI')"+CRLF
	cQryCRED+=" AND F3_FILIAL='"+xFilial('SF3')+"'"+CRLF 
	cQryCRED+=" AND F3.D_E_L_E_T_=''"+CRLF 
	cQryCRED+=" AND F3_ENTRADA BETWEEN '"+dDataIni+"' AND '"+dDataFim+"'"+CRLF
	cQryCRED+=" GROUP BY F3_NFISCAL"+CRLF
	cQryCRED+=" ORDER BY F3_NFISCAL"+CRLF	
	ChangeQuery(cQryCRED)
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,Alltrim(cQryCRED)),'TRBCRED',.F.,.T.)		

	If RecLock('TRBSF3',.T.)
		While TRBINT->(!Eof())
		
			cBase  :=If(TRBINT->BASIMP <> 0,Transform(TRBINT->BASIMP,"@E 999999999.99"),'-')
			cValImp:=If(TRBINT->VALIMP <> 0,Transform(TRBINT->VALIMP,"@E 999999999.99"),'-')				
			
			Do Case
				
				Case TRBINT->CONCEPT==Padr('303',5)
					TRBSF3->CPO303:=cBase
					TRBSF3->CPO353:=cValImp
				Case TRBINT->CONCEPT==Padr('304',5)
					TRBSF3->CPO304:=cBase
					TRBSF3->CPO354:=cValImp
				Case TRBINT->CONCEPT==Padr('307',5)
					TRBSF3->CPO307:=cBase
					TRBSF3->CPO357:=cValImp 
				Case TRBINT->CONCEPT==Padr('308',5)
					TRBSF3->CPO308:=cBase 
					TRBSF3->CPO358:=cValImp 
				Case TRBINT->CONCEPT==Padr('309',5)
					TRBSF3->CPO309:=cBase 
					TRBSF3->CPO359:=cValImp
				Case TRBINT->CONCEPT==Padr('310',5)
					TRBSF3->CPO310:=cBase 
					TRBSF3->CPO360:=cValImp
				Case TRBINT->CONCEPT==Padr('312',5)
					TRBSF3->CPO312:=cBase 
					TRBSF3->CPO362:=cValImp
				Case TRBINT->CONCEPT==Padr('319',5)
					TRBSF3->CPO319:=cBase 
					TRBSF3->CPO369:=cValImp
				Case TRBINT->CONCEPT==Padr('320',5)
					TRBSF3->CPO320:=cBase 
					TRBSF3->CPO370:=cValImp
				Case TRBINT->CONCEPT==Padr('322',5)
					TRBSF3->CPO322:=cBase 
					TRBSF3->CPO372:=cValImp
				Case TRBINT->CONCEPT==Padr('323',5)
					TRBSF3->CPO323:=cBase 
					TRBSF3->CPO373:=cValImp
				Case TRBINT->CONCEPT==Padr('325',5)
					TRBSF3->CPO325:=cBase 
					TRBSF3->CPO375:=cValImp
				Case TRBINT->CONCEPT==Padr('327',5)
					TRBSF3->CPO327:=cBase 
					TRBSF3->CPO377:=cValImp
				Case TRBINT->CONCEPT==Padr('328',5)
					TRBSF3->CPO328:=cBase 
					TRBSF3->CPO378:=cValImp
				Case TRBINT->CONCEPT==Padr('332',5)
					TRBSF3->CPO332:=cBase
				Case TRBINT->CONCEPT==Padr('340',5)
					TRBSF3->CPO340:=cBase 
					TRBSF3->CPO390:=cValImp
				Case TRBINT->CONCEPT==Padr('341',5)
					TRBSF3->CPO341:=cBase 
					TRBSF3->CPO391:=cValImp
				Case TRBINT->CONCEPT==Padr('342',5)
					TRBSF3->CPO342:=cBase 
					TRBSF3->CPO392:=cValImp
				Case TRBINT->CONCEPT==Padr('343',5)
					TRBSF3->CPO343:=cBase 
					TRBSF3->CPO393:=cValImp
	    	EndCase
			nBaseInt+=TRBINT->BASIMP
			nValInt +=TRBINT->VALIMP
			TRBINT->(dbSkip())
		End
			
		TRBSF3->CPO349:=If(nBaseInt <> 0,Transform(nBaseInt,"@E 999999999.99"),'-')		
		TRBSF3->CPO399:=If(nValInt  <> 0,Transform(nValInt ,"@E 999999999.99"),'-')
		
		While TRBEXT->(!Eof())
		
			cBase  :=If(TRBEXT->BASIMP <> 0,Transform(TRBEXT->BASIMP,"@E 999999999.99"),'-')
			cValImp:=If(TRBEXT->VALIMP <> 0,Transform(TRBEXT->VALIMP,"@E 999999999.99"),'-')

			Do Case
				Case TRBEXT->CONCEPT==Padr('401',5)
					TRBSF3->CPO401:=cBase
					TRBSF3->CPO451:=cValImp
				Case TRBEXT->CONCEPT==Padr('403',5)
					TRBSF3->CPO403:=cBase
					TRBSF3->CPO453:=cValImp
				Case TRBEXT->CONCEPT==Padr('405',5)
					TRBSF3->CPO405:=cBase
					TRBSF3->CPO455:=cValImp
				Case TRBEXT->CONCEPT==Padr('421',5)
					TRBSF3->CPO421:=cBase
					TRBSF3->CPO471:=cValImp
				Case TRBEXT->CONCEPT==Padr('427',5)
					TRBSF3->CPO427:=cBase
			EndCase
						
			nBaseEx+=TRBEXT->BASIMP
			nValEx +=TRBEXT->VALIMP 				
			TRBEXT->(dbSkip())
		End
			
		TRBSF3->CPO429:=If(nBaseEx <> 0,Transform(nBaseEx,"@E 999999999.99"),'-') 				 
		TRBSF3->CPO498:=If(nValEx  <> 0,Transform(nValEx ,"@E 999999999.99"),'-') 				 
		TRBSF3->CPO499:=If(nValInt+nValEx <> 0,Transform(nValInt+nValEx,"@E 999999999.99"),'-') 				 
			
		//Notas de Credito 
		If TRBCRED->(!Eof()) 
			TRBSF3->CPO908:=TRBCRED->NFISCAL						
			nValNfCred+=TRBCRED->VALIMP
			TRBSF3->CPO909:=If(TRBCRED->VALIMP <> 0,Transform(TRBCRED->VALIMP,"@E 999999999.99"),'-')
			TRBCRED->(dbSkip())
	    EndIf
	    If TRBCRED->(!Eof())
	  		TRBSF3->CPO910:=TRBCRED->NFISCAL						
			nValNfCred+=TRBCRED->VALIMP
			TRBSF3->CPO911:=If(TRBCRED->VALIMP <> 0,Transform(TRBCRED->VALIMP,"@E 999999999.99"),'-')
			TRBCRED->(dbSkip())  
	    EndIf  
		If TRBCRED->(!Eof())
	  		TRBSF3->CPO912:=TRBCRED->NFISCAL						
			nValNfCred+=TRBCRED->VALIMP
			TRBSF3->CPO913:=If(TRBCRED->VALIMP <> 0,Transform(TRBCRED->VALIMP,"@E 999999999.99"),'-')
			TRBCRED->(dbSkip())  
	    EndIf  		
		If TRBCRED->(!Eof())
	  		TRBSF3->CPO914:=TRBCRED->NFISCAL						
			nValNfCred+=TRBCRED->VALIMP
			TRBSF3->CPO915:=If(TRBCRED->VALIMP <> 0,Transform(TRBCRED->VALIMP,"@E 999999999.99"),'-')
			TRBCRED->(dbSkip())  
	    EndIf  		

		TRBINT ->(DBCLOSEAREA())
		TRBEXT ->(DBCLOSEAREA())
		TRBCRED->(DBCLOSEAREA())
	
		//Detalhes do pagamento previo se Substitutiva
		If Substr(_aTotal[1][1],1,1)=='2' 
			TRBSF3->CPO890:=If( nImpPG + nMoraInt + nMultaJu <> 0,Transform(nImpPG + nMoraInt + nMultaJu,"@E 999999999.99"),'-')
			TRBSF3->CPO897:=If( nImpPG  <> 0,Transform(nImpPG  ,"@E 999999999.99"),'-')
			TRBSF3->CPO898:=If(nMoraInt <> 0,Transform(nMoraInt,"@E 999999999.99"),'-')
			TRBSF3->CPO899:=If(nMultaJu <> 0,Transform(nMultaJu,"@E 999999999.99"),'-')
		Else
			TRBSF3->CPO890:='-'
			TRBSF3->CPO897:='-'
			TRBSF3->CPO898:='-'
			TRBSF3->CPO899:='-'
		EndIf		
		
		//Valores a pagar e forma de pagamento
		TRBSF3->CPO902:=If(nValInt+nValEx-nImpPG <> 0,Transform(nValInt+nValEx-nImpPG,"@E 999999999.99"),'-')
		TRBSF3->CPO903:=If(nMoraInt <> 0,Transform(nMoraInt,"@E 999999999.99"),'-')
		TRBSF3->CPO904:=If(nMultaJu <> 0,Transform(nMoraInt,"@E 999999999.99"),'-')
		TRBSF3->CPO999:=iF((nValInt+nValEx-nImpPG)+nMoraInt+nMultaJu <> 0,;
		                   Transform((nValInt+nValEx-nImpPG)+nMoraInt+nMultaJu,"@E 999999999.99"),'-')
		TRBSF3->CPO907:=If(nValNfCred <> 0,Transform(nValNfCred,"@E 999999999.99"),'-')
		TRBSF3->CPO905:=If((nValInt+nValEx-nImpPG)+nMoraInt+nMultaJu-nValNfCred <> 0,;
		                    Transform((nValInt+nValEx-nImpPG)+nMoraInt+nMultaJu-nValNfCred,"@E 999999999.99"),'-')
		                 
		TRBSF3->(MsUnLock())
	
		TRelIR()		
	EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TRelIR    ºAutor  ³Renato Nagib        º Data ³  07/23/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatorio para conferencia dos dados para declaracao do IR  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                 Equador                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TRelIR()

	Local oReport

	If TRepInUse()
		oReport := ReportDef()
		oReport:PrintDialog()	
	EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |ReportDef ºAutor  ³Renato Nagib        º Data ³  26/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³               DEFINE O RELATORIO                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³              Livro fiscal de entrada                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()

	Local oReport
	Local oSection1
	Local oSection2
	Local oSection3
	Local oSection4
	Local oSection5
	Local oSection6
	
	oReport := TReport():New("TRelIR",STR0001,,{|oReport| PrintReport(oReport)},STR0002)

	oReport:SetLandScape(.T.)
	
	// SECAO1 - IDENTIFICACAO DA DECLARACAO 
	oSection1 := TRSection():New(oReport,STR0003,{"TRBSF3"})
	TRCell():New(oSection1,"Tipo de Declaracao" ,,STR0004,,20,.F.)
	TRCell():New(oSection1,"Mes"                ,,STR0005,,15,.F.)
	TRCell():New(oSection1,"Ano"                ,,STR0006,,15,.F.)
	TRCell():New(oSection1,"Numero Formulario"  ,,STR0007,,25,.F.)
	TRCell():New(oSection1,"ID Representante"   ,,STR0008,,20,.F.)
	TRCell():New(oSection1,"Ruc Contador"       ,,STR0009,,20,.F.)
	TRCell():New(oSection1,"Ruc Agente"         ,,STR0010,,20,.F.)
	TRCell():New(oSection1,"Razao Social"       ,,STR0011,,40,.F.)

	//SECAO2 - Detalhe dos Pagamentos e retencao de Ir dentro do pais
	oSection2 := TRSection():New(oReport,STR0012,{"TRBSF3"})	
	TRCell():New(oSection2,"Base das Operacoes" ,,STR0013,,25,.F.)
	TRCell():New(oSection2,"Valor das Operacoes",,STR0014,,25,.F.)
	TRCell():New(oSection2,"Isentas"            ,,STR0015,,25,.F.)
	
	//SECAO3 - Detalhe dos Pagamentos e retencao de Ir fora do pais
	oSection3 := TRSection():New(oReport,STR0016,{"TRBSF3"})	
	TRCell():New(oSection3,"Base das Operacoes" ,,STR0013,,25,.F.)
	TRCell():New(oSection3,"Valor das Operacoes",,STR0014,,25,.F.)
	TRCell():New(oSection3,"Isentas"            ,,STR0015,,25,.F.)

	//SECAO4 - Detalhe dos Pagamentos Previos - Se Substitutiva
	oSection4 := TRSection():New(oReport,STR0017,{"TRBSF3"})	
	TRCell():New(oSection4,"Pagamento previo",,STR0018,,25,.F.)
	TRCell():New(oSection4,"Imposto pago"    ,,STR0019,,25,.F.)
	TRCell():New(oSection4,"Interes"         ,,STR0020,,25,.F.)
	TRCell():New(oSection4,"Multa"           ,,STR0021,,25,.F.)	

	//SECAO5 - Valores a pagar e formas de Pagamentos
	oSection5 := TRSection():New(oReport,STR0022,{"TRBSF3"})	
	TRCell():New(oSection5,"Total de impostos a pagar",,STR0023,,25,.F.)
	TRCell():New(oSection5,"Interes"                  ,,STR0020,,25,.F.)
	TRCell():New(oSection5,"Multa"                    ,,STR0021,,25,.F.)
	TRCell():New(oSection5,"Total Pago"               ,,STR0024,,25,.F.)	
	TRCell():New(oSection5,"Pagamento mediante cheque",,STR0025,,25,.F.)		

	//SECAO6 - Detalhes das NF de credito
	oSection6 := TRSection():New(oReport,STR0026,{"TRBSF3"})	
	TRCell():New(oSection6,"Nota Fiscal 1",,STR0027+" 1",,20,.F.)
	TRCell():New(oSection6,"Valor 1"      ,,STR0028+" 1",,20,.F.)
	TRCell():New(oSection6,"Nota Fiscal 2",,STR0027+" 2",,20,.F.)
	TRCell():New(oSection6,"Valor 2"      ,,STR0028+" 2",,20,.F.)	
	TRCell():New(oSection6,"Nota Fiscal 3",,STR0027+" 3",,20,.F.)		
	TRCell():New(oSection6,"Valor 3"      ,,STR0028+" 3",,20,.F.)		
	TRCell():New(oSection6,"Nota Fiscal 4",,STR0027+" 4",,20,.F.)		
	TRCell():New(oSection6,"Valor 4"      ,,STR0028+" 4",,20,.F.)		

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrintReportºAutor ³Renato Nagib        º Data ³  26/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao auxiliar do TReport para impressao dos dados         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funcao oReport                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrintReport(oReport)
	
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local oSection3 := oReport:Section(3)
	Local oSection4 := oReport:Section(4)
	Local oSection5 := oReport:Section(5)
	Local oSection6 := oReport:Section(6)

	TRBSF3->(dbGoTop())

	oReport:SetMeter(RecCount())	

	//IMPRESSAO DA SECAO 1
	oSection1:Init() 
	oReport:PrintText(STR0029,(oReport:Row()),700,CLR_RED)
    oReport:IncRow(100)
   	oReport:Section(1):Cell("Tipo de Declaracao"):SetBlock({|| Substr(aInfDec[1][1],3)   })	
	oReport:Section(1):Cell("Mes")               :SetBlock({|| Substr(dTOc(MV_PAR01),4,2)})	
	oReport:Section(1):Cell("Ano")               :SetBlock({|| Substr(dTOc(MV_PAR01),7,4)})	
	oReport:Section(1):Cell("Numero formulario") :SetBlock({|| aInfDec[1][3]             })	
	oReport:Section(1):Cell("ID Representante")  :SetBlock({|| aInfDec[1][3]             })	
	oReport:Section(1):Cell("Ruc Contador")      :SetBlock({|| aInfDec[1][8]             })	
	oReport:Section(1):Cell("Ruc Agente")        :SetBlock({|| SM0->M0_CGC               })	
	oReport:Section(1):Cell("Razao Social")      :SetBlock({|| SM0->M0_NOMECOM           })	
	oSection1:Printline()				
    oReport:IncRow(100)
   	oSection1:Finish()
   	
	//IMPRESSAO DA SECAO 2
	TRBSF3->(dbGoTop())
	oSection2:Init() 
	oReport:PrintText(STR0030,(oReport:Row()),700,CLR_RED)
    oReport:IncRow(100)
	oReport:Section(2):Cell("Base das Operacoes") :SetBlock({|| TRBSF3->CPO349})	
	oReport:Section(2):Cell("Valor das Operacoes"):SetBlock({|| TRBSF3->CPO399})	
	oReport:Section(2):Cell("Isentas")            :SetBlock({|| TRBSF3->CPO332})		
	oSection2:Printline()				
    oReport:IncRow(100)
	oSection2:Finish()

	//IMPRESSAO DA SECAO 3
	TRBSF3->(dbGoTop())
	oSection3:Init() 

	oReport:PrintText(STR0031,(oReport:Row()),700,CLR_RED)
    oReport:IncRow(100)
	oReport:Section(3):Cell("Base das Operacoes") :SetBlock({|| TRBSF3->CPO429})	
	oReport:Section(3):Cell("Valor das Operacoes"):SetBlock({|| TRBSF3->CPO498})	
	oReport:Section(3):Cell("Isentas")            :SetBlock({|| TRBSF3->CPO499})		
	oSection3:Printline()				
    oReport:IncRow(200)
	oSection3:Finish()

	//IMPRESSAO DA SECAO 4
	TRBSF3->(dbGoTop())
	oSection4:Init() 
	oReport:PrintText(STR0032,(oReport:Row()),700,CLR_RED)
    oReport:IncRow(100)
	oReport:Section(4):Cell("Pagamento previo"):SetBlock({|| TRBSF3->CPO890})	
	oReport:Section(4):Cell("Imposto pago")    :SetBlock({|| TRBSF3->CPO897})	
	oReport:Section(4):Cell("Interes")         :SetBlock({|| TRBSF3->CPO898})		
	oReport:Section(4):Cell("Multa")           :SetBlock({|| TRBSF3->CPO899})		
	oSection4:Printline()				
    oReport:IncRow(100)
	oSection4:Finish()

	//IMPRESSAO DA SECAO 5
	TRBSF3->(dbGoTop())
	oSection5:Init() 
	oReport:PrintText(STR0033,(oReport:Row()),700,CLR_RED)
    oReport:IncRow(100)
	oReport:Section(5):Cell("Total de impostos a pagar"):SetBlock({|| TRBSF3->CPO902})	
	oReport:Section(5):Cell("Interes")                  :SetBlock({|| TRBSF3->CPO903})	
	oReport:Section(5):Cell("Multa")                    :SetBlock({|| TRBSF3->CPO904})		
	oReport:Section(5):Cell("Total Pago")               :SetBlock({|| TRBSF3->CPO999})		
	oReport:Section(5):Cell("Pagamento mediante cheque"):SetBlock({|| TRBSF3->CPO905})		
	oSection5:Printline()				
    oReport:IncRow(100)
	oSection5:Finish()

	//IMPRESSAO DA SECAO 6
	TRBSF3->(dbGoTop())
	oSection6:Init() 
    oReport:PrintText(STR0034,(oReport:Row()),700,CLR_RED)
	oReport:IncRow(100)
	oReport:Section(6):Cell("Nota Fiscal 1"):SetBlock({|| TRBSF3->CPO908})	
	oReport:Section(6):Cell("Valor 1")      :SetBlock({|| TRBSF3->CPO909})	
	oReport:Section(6):Cell("Nota Fiscal 2"):SetBlock({|| TRBSF3->CPO910})		
	oReport:Section(6):Cell("Valor 2")      :SetBlock({|| TRBSF3->CPO911})		
	oReport:Section(6):Cell("Nota Fiscal 3"):SetBlock({|| TRBSF3->CPO912})		
	oReport:Section(6):Cell("Valor 3")      :SetBlock({|| TRBSF3->CPO913})		
	oReport:Section(6):Cell("Nota Fiscal 4"):SetBlock({|| TRBSF3->CPO914})		
	oReport:Section(6):Cell("Valor 4")      :SetBlock({|| TRBSF3->CPO915})		
	oSection6:Printline()				
	oReport:IncRow(100)
	oSection6:Finish()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GETLIVRO  ºAutor  ³RENATO NAGIB        º Data ³  16/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ BUSCA NUMERO DO LIVRO PARA GRAVACAO DO IR                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                     EQUADOR                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GETLIVRO()

	Local cQuery
	
	cQuery:=" SELECT FB_CPOLVRO AS LIVRO"
	cQuery+=" FROM "+RetSqlName('SFB')+" SFB"
	cQuery+=" WHERE FB_CODIGO='RIR'" 
	cQuery+=" AND FB_FILIAL= '"+xFilial('SFB')+"'"
	cQuery+=" AND D_E_L_E_T_=''"
	ChangeQuery(cQuery)    
    dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),'TRSFB',.F.,.T.)
    
    cLivro:=TRSFB->LIVRO
Return (cLivro)
