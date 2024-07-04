#INCLUDE "MSOBJECT.CH"
#INCLUDE "LOJA1305.CH"
#INCLUDE "DEFTOTAPI.CH"
#INCLUDE "AUTODEF.CH"    

#DEFINE DELIMIT		"<@#DELIMIT#@>"
#DEFINE FIMSTR		"<@#FIMSTR#@>"

Static lIsRmt64		:= If( ExistFunc("IsRmt64") ,IsRmt64(), .F. )
Static cDLLTOTVSAPI	:= IIf(lIsRmt64,"TOTVSAPI64.DLL","TOTVSAPI.DLL")

Function LOJA1305 ; Return  // "dummy" function - Internal Use 

/*����������������������������������������������������������������������������������
���Classe    �LJCTotvsAPI      �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em se comunicar com dll exte	rnas (API)               ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
����������������������������������������������������������������������������������*/
Class LJCTotvsAPI
		
    Data nHandle											//Handle da DLL
	Data oEcf												//Objeto do tipo LJCPerifericos
	Data oEcNf												//Objeto do tipo LJCPerifericos	
	Data oPinPad											//Objeto do tipo LJCPerifericos
	Data oCmc7												//Objeto do tipo LJCPerifericos
	Data oGaveta											//Objeto do tipo LJCPerifericos
	Data oImpCup											//Objeto do tipo LJCPerifericos
	Data oLeitor											//Objeto do tipo LJCPerifericos
	Data oBalanca											//Objeto do tipo LJCPerifericos
	Data oDisplay											//Objeto do tipo LJCPerifericos
	Data oImpCheque											//Objeto do tipo LJCPerifericos
	Data lAtivo												//Identifica se a comunicao com a totvsapi foi estabelecida com sucesso
	
	Method New()											//Metodo construtor
	Method EnviarCom(oDados)                               	//Envia o comando para a dll
	Method AbrirCom()                                     	//Abri comunicacao com a dll
	Method ComAberta()										//Verifica se a comunicacao ja foi aberta
	Method FecharCom()	
	
	Method ListarEcf()										//Retorna as impressoras
	Method ListarEcNf()										//Retorna as impressoras n FISCAL
	Method ListPinPad()										//Retorna os pinpad's
	Method ListarCMC7()										//Retorna os cmc7's
	Method ListGaveta()										//Retorna as gavetas
	Method ListImpCup()										//Retorna ????		
	Method ListLeitor()										//Retorna os leitores		
	Method ListBalanc()										//Retorna as balancas		
	Method LstDisplay()										//Retorna os display's
	Method ListImpChq()										//Retorna as impressoras de cheque
	
	//Metodos internos
	Method TrataRet(cBuffer, oParams)                   	//Trata o retorno da dll
	Method CarregPeri()										//Carrega os perifericos diponiveis
	Method VerVersao()										//Verificar se a versao da Totvsapi eh compativel com o repositorio
EndClass

/*����������������������������������������������������������������������������������
���Metodo    �New   	       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJCProtheusAPI. 			    	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
����������������������������������������������������������������������������������*/
Method New() Class LJCTotvsAPI

	::nHandle 		:= -1
 	::oEcf			:= Nil
	::oEcNf			:= Nil 
	::oPinPad		:= Nil
	::oCmc7			:= Nil
	::oGaveta		:= Nil
	::oImpCup		:= Nil
	::oLeitor		:= Nil
	::oBalanca		:= Nil
	::oDisplay		:= Nil
	::oImpCheque	:= Nil
    ::lAtivo		:= .F.
    
	//Carrega os perifericos
	::CarregPeri()
	
Return Self

/*����������������������������������������������������������������������������������
���Metodo    �AbrirCom	       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em abrir comunicao com a TotvsApi.dll/so.	    	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Numerico														     ���
����������������������������������������������������������������������������������*/
Method AbrirCom() Class LJCTotvsAPI
Local cNome := ""						//Caminho da totvsapi
Local lAutomato := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)
Local cPath := ""

If lAutomato
	cNome := "C:\smartclient\" + cDLLTOTVSAPI
Else
	cPath := GetClientdir()
	If GetRemoteType() == REMOTE_LINUX
		cNome	:= cPath + "totvsapi.so"
	Else
		cNome	:= cPath + cDLLTOTVSAPI
	EndIf
	
	//Abre comunicacao
	::nHandle := ExecInDLLOpen(cNome)
	::lAtivo := (::nHandle <> -1)
	
	//Verifica a versao 
	If ::lAtivo//Quando for execu��o via robo de testes deixa de verificar
		::VerVersao()
	EndIf
Endif

Return ::nHandle

/*����������������������������������������������������������������������������������
���Metodo    �EnviarCom	       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em enviar o comando para TotvsApi.dll/so.	    	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPO1 (1 - oParams) - Objeto do tipo LJCParamsApi.				 ���
��������������������������������������������������������������������������������͹��
���Retorno   �String														     ���
����������������������������������������������������������������������������������*/
Method EnviarCom(oParams) Class LJCTotvsAPI
	
    Local nCount 	:= 0							//Variavel de contador
	Local cBuffer 	:= ""    						//Buffer que sera enviado a totvsapi
	Local cRetorno  := ""                        	//Retorno do metodo
    
	//Coloca os parametros em cBuffer
	For nCount := 1 To oParams:Count()
		cBuffer += oParams:Elements(nCount):cParametro + DELIMIT
	Next

	cBuffer += FIMSTR
		
	cBuffer := PadR(cBuffer, 13000)	 

	cBuffer := Encode64(cBuffer)

	//Envia os dados para a dll
	If ExeDLLRun2(::nHandle, 1, @cBuffer) == 1
		
		cBuffer := Decode64(cBuffer)

		//Pega a posicao do delimitador que separa os parametros da funcao
		nPos := At(DELIMIT, cBuffer)
	    
		//Nao existe parametro retornado
		If nPos == 0
			nPos := At(FIMSTR, cBuffer)
		EndIf
	
		//Pega o delimitador que determina o final de string
		nFinal := At(FIMSTR, cBuffer)
	
		//Retorno da funcao
		cRetorno := Substr(cBuffer, 1, nPos - 1)
	
		//Coloca os parametros de retorno da funcao no cBuffer
		If nPos <> nFinal
			cBuffer := Substr(cBuffer, nPos + Len(DELIMIT), nFinal - (nPos + Len(DELIMIT)))
		Else
			cBuffer := ""
		EndIf
		
		//Alimenta o objeto oParams com os parametros retornados
		::TrataRet(cBuffer, oParams) 
	Else
		//Problemas de comunicacao com a dll/so
		cRetorno := "-999"
	EndIf         
	
Return cRetorno

/*����������������������������������������������������������������������������������
���Metodo    �TratarRet	       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em tratar o retorno da TotvsApi.dll/so				 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cBuffer) - Retorno do comando enviado.   				 ���
���			 �EXPO1 (1 - oParams) - Objeto do tipo LJCParamsApi.				 ���
��������������������������������������������������������������������������������͹��
���Retorno   �																     ���
����������������������������������������������������������������������������������*/
Method TrataRet(cBuffer, oParams) Class LJCTotvsAPI
	
	Local nCount 	:= 3							//Variavel auxiliar contador
	Local cAux		:= ""							//Variavel auxiliar para guardar o retorno do parametro
	Local nPos		:= 0							//Controla a posicao do delimitador na string
	
	//Separa parametro por parametro e atribui ao objeto oParams 
	While !Empty(AllTrim(cBuffer))
	
		nPos := At(DELIMIT, cBuffer)
		
		If nPos == 0
			cAux := cBuffer
		Else
			cAux := Substr(cBuffer, 1, nPos - 1)
		EndIf
		
		oParams:Elements(nCount):cParametro := cAux
		
		nCount++
		
		If nPos == 0
			cBuffer := ""			 
		Else
		    cBuffer := Substr(cBuffer, nPos + Len(DELIMIT))
		EndIF
	
	End Do
	
Return Nil

/*����������������������������������������������������������������������������������
���Metodo    �ComAberta	       �Autor  �Vendas Clientes     � Data �  05/11/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel verificar se a comunicacao ja foi aberta				 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Logico														     ���
����������������������������������������������������������������������������������*/
Method ComAberta() Class LJCTotvsAPI
Local lRetorno := .F.					//Retorno do metodo

lRetorno := (::nHandle <> -1)
	
Return lRetorno  

/*����������������������������������������������������������������������������������
���Metodo    �TratarRet	       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em carregar os perifericos diponiveis   				 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �																     ���
����������������������������������������������������������������������������������*/
Method CarregPeri() Class LJCTotvsAPI
Local oPeriferico	:= Nil									//Objeto do tipo LJCPeriferico	
Local cPeriferico	:= ""									//Descricao do periferico
Local lPeriEcf  	:= ExistFunc("P_PERIFECF")				//Verifica se existe a project function para adicionar um novo ECF na lista de perifericos
Local oAuxPerifs    := Nil									//Objeto auxiliar do tipo LJCPerifericos para adicionar um novo periferico via project function 
Local nCount		:= 0									//Variavel auxiliar tipo contador

//Impressoras
::oEcf 			:= LJCPerifericos():New()
Self:oEcNf		:= LJCPerifericos():New()

cPeriferico := "BEMATECH MP-3000 TH FI V01.01.01"
oPeriferico := LJCPeriferico():New(cPeriferico, "BRA", "031903", "LJCBematechMP3000THFIV010101")	
::oEcf:Add(cPeriferico, oPeriferico)

cPeriferico := "EPSON TM-T88FB V01.06.00"
oPeriferico := LJCPeriferico():New(cPeriferico, "BRA", "150203", "LJCEpsonTMT88FB010600")	
::oEcf:Add(cPeriferico, oPeriferico)  

cPeriferico := "EPSON TM-T81FB V01.00.04"
oPeriferico := LJCPeriferico():New(cPeriferico, "BRA", "150402", "LJCEpsonTMT81FB010700")	
::oEcf:Add(cPeriferico, oPeriferico)

cPeriferico := "EPSON TM-T81FB V01.07.00"
oPeriferico := LJCPeriferico():New(cPeriferico, "BRA", "150406", "LJCEpsonTMT81FB010700")
::oEcf:Add(cPeriferico, oPeriferico)  	

cPeriferico := "EPSON TM-T81FB V01.10.00"
oPeriferico := LJCPeriferico():New(cPeriferico, "BRA", "150407", "LJCEpsonTMT81FB010700")
::oEcf:Add(cPeriferico, oPeriferico)   

cPeriferico := "EPSON TM-H6000 FBII V01.07.00"
oPeriferico := LJCPeriferico():New(cPeriferico, "BRA", "150504", "LJCEpsonTMTH6000FB010700")
::oEcf:Add(cPeriferico, oPeriferico)

cPeriferico := "EPSON TM-T800 F V01.00.00"
oPeriferico := LJCPeriferico():New(cPeriferico, "BRA", "151001", "LJCEpsonTMT800F")
::oEcf:Add(cPeriferico, oPeriferico)

cPeriferico := "EPSON TM-T800 F V01.01.00"
oPeriferico := LJCPeriferico():New(cPeriferico, "BRA", "151002", "LJCEpsonTMT800F")
::oEcf:Add(cPeriferico, oPeriferico)
	
cPeriferico := "EPSON TM-T900 F V01.00.00"
oPeriferico := LJCPeriferico():New(cPeriferico, "BRA", "151101", "LJCEpsonTMT800F")
::oEcf:Add(cPeriferico, oPeriferico)

cPeriferico := "EPSON TM-T900 F V01.01.00"
oPeriferico := LJCPeriferico():New(cPeriferico, "BRA", "151102", "LJCEpsonTMT800F")
::oEcf:Add(cPeriferico, oPeriferico)

If !lIsRmt64
	cPeriferico := "IBM 4610-KN4 V01.00.02"
	oPeriferico := LJCPeriferico():New(cPeriferico, "BRA", "181202", "LJCIBM4610KN4010002")
	::oEcf:Add(cPeriferico, oPeriferico)  
		
	cPeriferico := "IBM 4610-SJ6 V01.00.01"
	oPeriferico := LJCPeriferico():New(cPeriferico, "BRA", "181301", "LJCIBM4610SJ6010001")
	::oEcf:Add(cPeriferico, oPeriferico)

	cPeriferico := "ITAUTEC QW PRINTER 6000 MT2 V01.00.05"
	oPeriferico := LJCPeriferico():New(cPeriferico, "BRA", "222101", "LJCItautecQWPrinter6000MT2010005")
	::oEcf:Add(cPeriferico, oPeriferico)     
	
	cPeriferico := "ITAUTEC ZPM-300 256M PRT41 V01.03.00"
	oPeriferico := LJCPeriferico():New(cPeriferico, "BRA", "492702", "LJCItautecECFIFZPM300256MPRT41010300")
	::oEcf:Add(cPeriferico, oPeriferico)
EndIf  	 

// Impressora nao fiscal
//ECNF nao deve mandar o n�mero do ECF para nao ter problema no fonte LOJXECF
cPeriferico := "DARUMA DR700 V02.10.01" 
oPeriferico := LJCPeriferico():New(cPeriferico, "BRA", "      ", "LJCNfDarumaDr700")
Self:oEcNf:Add(cPeriferico, oPeriferico)
cPeriferico := "BEMATECH MP4200 V01.00.00" 
oPeriferico := LJCPeriferico():New(cPeriferico, "BRA", "      ", "LJCNfBemaMP4200")
Self:oEcNf:Add(cPeriferico, oPeriferico)

cPeriferico := "EMULADOR NAO FISCAL HTML" 
oPeriferico := LJCPeriferico():New(cPeriferico, "BRA", "      ", "LJANfEmulador")
Self:oEcNf:Add(cPeriferico, oPeriferico)

If !lIsRmt64 .And. (INFLocaliz() .OR. (nModulo == 5))
	cPeriferico := "IBM 1NR V02.10.01" 
	oPeriferico := LJCPeriferico():New(cPeriferico, cPaisLoc, "492702", "LJCNfIBM1NR4610") 
	Self:oEcNf:Add(cPeriferico, oPeriferico)

	cPeriferico := "EPSON TM - T88V V02.10.01" 
	oPeriferico := LJCPeriferico():New(cPeriferico, cPaisLoc, "492702", "LJCNfEPONTMT88V") 
	Self:oEcNf:Add(cPeriferico, oPeriferico)
EndIf

//Verifica se existe project function
If lPeriEcf
	//Captura os ECF'S adicionais                                                              
	oAuxPerifs := P_PERIFECF()
                                                             
	//Verifica se existe ECF adicional
	If oAuxPerifs <> Nil .AND. oAuxPerifs:Count() > 0
		//Lista todos os ecf's adicionais
		For nCount := 1 To oAuxPerifs:Count()
			//Captura o ecf
			oPeriferico := oAuxPerifs:Elements(nCount)
			//Adiciona o novo ecf na colecao
			::oEcf:Add(oPeriferico:cDescricao, oPeriferico)			
		Next
	EndIf
EndIf

//----------------------------------------------------------------------------------------------

//PinPad
::oPinPad		:= LJCPerifericos():New()

cPeriferico := " "
oPeriferico := LJCPeriferico():New(cPeriferico, " ", " ", " ")
::oPinPad:Add(cPeriferico, oPeriferico)	
//----------------------------------------------------------------------------------------------	

//CMC7
::oCmc7			:= LJCPerifericos():New()   

If !lIsRmt64
	cPeriferico := "IBM 4610-KN4 V01.00.02"
	oPeriferico := LJCPeriferico():New(cPeriferico, "BRA", "181202", "LJCIBM4610KN4010002") 
	::oCmc7:Add(cPeriferico, oPeriferico)

	cPeriferico := "ITAUTEC QW PRINTER 6000 MT2 V01.00.05"
	oPeriferico := LJCPeriferico():New(cPeriferico, "BRA", "222101", "LJCItautecQWPrinter6000MT2010005") 
	::oCmc7:Add(cPeriferico, oPeriferico)      
	
	cPeriferico := "ITAUTEC ZPM-300 256M PRT41 V01.03.00"
	oPeriferico := LJCPeriferico():New(cPeriferico, "BRA", "492702", "LJCItautecECFIFZPM300256MPRT41010300")
	::oCmc7:Add(cPeriferico, oPeriferico)
EndIf

cPeriferico := "EPSON TM-H6000 FBII V01.07.00"
oPeriferico := LJCPeriferico():New(cPeriferico, "BRA", "150504", "LJCEpsonTMTH6000FB010700") 
::oCmc7:Add(cPeriferico, oPeriferico) 

//----------------------------------------------------------------------------------------------	

//Gaveta
::oGaveta		:= LJCPerifericos():New()

cPeriferico := " "
oPeriferico := LJCPeriferico():New(cPeriferico, " ", " ", " ")

::oGaveta:Add(cPeriferico, oPeriferico)	
//----------------------------------------------------------------------------------------------	

//Impressora cupom
::oImpCup 		:= LJCPerifericos():New()

cPeriferico := " "
oPeriferico := LJCPeriferico():New(cPeriferico, " ", " ", " ")

::oImpCup:Add(cPeriferico, oPeriferico)	
//----------------------------------------------------------------------------------------------	

//Leitor
::oLeitor 		:= LJCPerifericos():New()

cPeriferico := " "
oPeriferico := LJCPeriferico():New(cPeriferico, " ", " ", " ")

::oLeitor:Add(cPeriferico, oPeriferico)	
//----------------------------------------------------------------------------------------------	

//Balanca
::oBalanca 		:= LJCPerifericos():New()

cPeriferico := " "
oPeriferico := LJCPeriferico():New(cPeriferico, " ", " ", " ")

::oBalanca:Add(cPeriferico, oPeriferico)	
//----------------------------------------------------------------------------------------------	

//Display
::oDisplay 		:= LJCPerifericos():New()

cPeriferico := " "
oPeriferico := LJCPeriferico():New(cPeriferico, " ", " ", " ")

::oDisplay:Add(cPeriferico, oPeriferico)	
//----------------------------------------------------------------------------------------------	

//Impressora de cheque
::oImpCheque 	:= LJCPerifericos():New()

If !lIsRmt64
	cPeriferico := "IBM 4610-KN4 V01.00.02"
	oPeriferico := LJCPeriferico():New(cPeriferico, "BRA", "181202", "LJCIBM4610KN4010002") 
	::oImpCheque:Add(cPeriferico, oPeriferico)

	cPeriferico := "ITAUTEC QW PRINTER 6000 MT2 V01.00.05"
	oPeriferico := LJCPeriferico():New(cPeriferico, "BRA", "222101", "LJCItautecQWPrinter6000MT2010005")
	::oImpCheque:Add(cPeriferico, oPeriferico)   
	
	cPeriferico := "ITAUTEC ZPM-300 256M PRT41 V01.03.00"
	oPeriferico := LJCPeriferico():New(cPeriferico, "BRA", "492702", "LJCItautecECFIFZPM300256MPRT41010300")
	::oImpCheque:Add(cPeriferico, oPeriferico)  
EndIf

cPeriferico := "EPSON TM-H6000 FBII V01.07.00"
oPeriferico := LJCPeriferico():New(cPeriferico, "BRA", "150504", "LJCEpsonTMTH6000FB010700")
::oImpCheque:Add(cPeriferico, oPeriferico)
//----------------------------------------------------------------------------------------------	

Return Nil

/*����������������������������������������������������������������������������������
���Metodo    �ListarEcf	       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar as impressoras             				 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
����������������������������������������������������������������������������������*/
Method ListarEcf() Class LJCTotvsAPI
Return ::oEcf

/*����������������������������������������������������������������������������������
���Metodo    �ListPinPad       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar os pinpad's             				     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
����������������������������������������������������������������������������������*/
Method ListPinPad() Class LJCTotvsAPI
Return ::oPinPad

/*����������������������������������������������������������������������������������
���Metodo    �ListarCMC7       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar os cmc7's             				     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
����������������������������������������������������������������������������������*/
Method ListarCMC7() Class LJCTotvsAPI
Return ::oCmc7

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �ListGaveta       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar as gavetas             				     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method ListGaveta() Class LJCTotvsAPI
Return ::oGaveta

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �ListImpCup       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar as impressora de cupom   				     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method ListImpCup() Class LJCTotvsAPI
Return ::oImpCup

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �ListLeitor       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar os leitores           				     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method ListLeitor() Class LJCTotvsAPI
Return ::oLeitor

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �ListBalanc       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar as balancas            				     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method ListBalanc() Class LJCTotvsAPI
Return ::oBalanca

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �LstDisplay       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar os display's            				     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method LstDisplay() Class LJCTotvsAPI
Return ::oDisplay

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �ListImpChq       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar as impressoras de cheque 				     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method ListImpChq() Class LJCTotvsAPI
Return ::oImpCheque

/*����������������������������������������������������������������������������������
���Metodo    �VerVersao        �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em verificar se a versao da Totvsapi eh compativel com ���
���			 �o repositorio									 				     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
����������������������������������������������������������������������������������*/
Method VerVersao() Class LJCTotvsAPI

	Local cVersaoApi 	:= "" 							//Versao da totvs api
	Local cVersaoRpo 	:= ""							//Versao do RPO
	Local oParams 		:= Nil							//Objeto do tipo LJCParamsAPI
	Local oParam 		:= Nil                         	//Objeto do tipo LJCParamAPI
	Local aRet			:= {}
	Local lPOS			:= STFIsPOS()
		
	//Instancia o objeto LJCParamsAPI
	oParams := LJCParamsAPI():New()
	
	//Prepara os parametros
	oParam := LJCParamAPI():New("999")
	oParams:ADD(1, oParam)
	
	oParam := LJCParamAPI():New("VERSAO")
	oParams:ADD(2, oParam)	
	
	oParam := LJCParamAPI():New(cVersaoApi)
	oParams:ADD(3, oParam)	
	
	//Envia o comando
	If ::EnviarCom(@oParams) == "1"
		//Guarda a versao da totvs api
		cVersaoApi := oParams:Elements(3):cParametro 	
	EndIf

	If ExistFunc("LjxVldVrDLL")
		LjxVldVrDLL(cVersaoApi,.F.,.T.)
	Else
		//Guarda a versao do rpo
		If !lPos
			cVersaoRpo := LJDLLVER(.F., .T.)
		Else
			aRet := STFFireEvent(	ProcName(0)																	,;		// Nome do processo
								"STDLLVersionControl"																,;		// Nome do evento
								{.F.																				,;
								 .T. } )  
			If Len(aRet) > 0 .AND. !Empty(aRet[1])
			    cVersaoRpo := aRet[1]
			EndIf   
		EndIf
		
		If (Empty(cVersaoApi)) .Or. (cVersaoApi < cVersaoRpo)
			//"Existe incompatibilidades entre a vers�o do Reposit�rio Protheus";"e a DLL TotvsApi"
			//"Por favor, atualize a DLL TotvsApi."
			//"Aten��o"
			MsgStop(STR0001 + " (" + cVersaoRpo + ") " + STR0006 + " (" + cVersaoApi + ") " + Chr(13) + STR0002 , STR0003)
			//"Termino Normal"
			Final(STR0005) 
		ElseIf cVersaoApi > cVersaoRpo
			//"Existe incompatibilidades entre a vers�o do Reposit�rio Protheus e a DLL TotvsApi"
			//"Por favor, atualize o Reposit�rio Protheus."
			//"Atencao"
			MsgStop(STR0001 + " (" + cVersaoRpo + ") " + STR0006 + " (" + cVersaoApi + ") " + Chr(13) + STR0004 , STR0003)
			//"Termino Normal"
			Final(STR0005) 
		EndIf
	EndIf
Return Nil

/*����������������������������������������������������������������������������������
���Metodo    �ListarEcNf       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar as impressoras Nao fiscal   				 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
����������������������������������������������������������������������������������*/
Method ListarEcNf() Class LJCTotvsAPI
Return ::oEcNf
 
/*����������������������������������������������������������������������������������
���Metodo    �FecharCom        �Autor  �Vendas Clientes     � Data �  18/01/2013 ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar as impressoras Nao fiscal   				 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
����������������������������������������������������������������������������������*/
Method FecharCom() Class LJCTotvsAPI
If Self:ComAberta() 
	ExecInDLLClose(::nHandle)
EndIf
Return Nil

/*����������������������������������������������������������������������������������
���Metodo    �RemoveTags        �Autor  �Vendas Clientes     � Data �  19/07/2013 ���
��������������������������������������������������������������������������������͹��
���Desc.     �Retorna Mensagem sem as Tags de formata��o   				 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�cMensagem															���
��������������������������������������������������������������������������������͹��
���Retorno   �cMensagem												     ���
����������������������������������������������������������������������������������*/
Function RemoveTags( cMensagem )
Local cMsg	:= ''
Local cTagI	:= ''
Local cTagF	:= ''
Local aTagsProtheus := Array( 34 )
Local nX := 0

DEFAULT cMensagem := ''

cMsg := cMensagem

//Segundo o padr�o daruma as tags devem estar em minusculo
aTagsProtheus[	1	] := 	'<B>'
aTagsProtheus[	2	] := 	'<I>'
aTagsProtheus[	3	] := 	'<CE>'
aTagsProtheus[	4	] := 	'<S>'
aTagsProtheus[	5	] := 	'<E>'
aTagsProtheus[	6	] := 	'<C>'
aTagsProtheus[	7	] := 	'<N>'
aTagsProtheus[	8	] := 	'<L>'
aTagsProtheus[	9	] := 	'<SL>'
aTagsProtheus[	10	] := 	'<TC>'
aTagsProtheus[	11	] := 	'<TB>'
aTagsProtheus[	12	] := 	'<AD>'
aTagsProtheus[	13	] := 	'<FE>'
aTagsProtheus[	14	] := 	'<XL>'
aTagsProtheus[	15	] := 	'<GUI>'
aTagsProtheus[	16	] := 	'<EAN13>'
aTagsProtheus[	17	] := 	'<EAN8>'
aTagsProtheus[	18	] := 	'<UPC-A>'
aTagsProtheus[	19	] := 	'<CODE39>'
aTagsProtheus[	20	] := 	'<CODE93>'
aTagsProtheus[	21	] := 	'<CODABAR>'
aTagsProtheus[	22	] := 	'<MSI>'
aTagsProtheus[	23	] := 	'<CODE11>'
aTagsProtheus[	24	] := 	'<PDF>'
aTagsProtheus[	25	] := 	'<CODE128>'
aTagsProtheus[	26	] := 	'<I2OF5>'
aTagsProtheus[	27	] := 	'<S2OF5>'
aTagsProtheus[	28	] := 	'<QRCODE>'
aTagsProtheus[	29	] := 	'<BMP>'
aTagsProtheus[	30	] := 	'<CORRECAO>'
aTagsProtheus[	31	] := 	"<itf>"
aTagsProtheus[	32	] := 	"<isbn>"
aTagsProtheus[	33	] := 	"<plessey>"
aTagsProtheus[  34  ] :=	"<lmodulo>"

For nX := 1 to 33
	cTagI	:= Lower(aTagsProtheus[nX])
	cTagF	:= Stuff(cTagI,2,0,"/")
	
	While At( cTagI , cMsg ) > 0			
	    cMsg	:= RemoveChar(cMsg,cTagI,"")
	EndDo
	
	While At( cTagF , cMsg ) > 0
		cMsg	:= RemoveChar(cMsg,cTagF,"")
	EndDo
		
Next nX

Return cMsg

/*����������������������������������������������������������������������������������
���Metodo    �RemoveChar       �Autor  �Vendas Clientes     � Data �  16/07/2013 ���
��������������������������������������������������������������������������������͹��
���Desc.     �remove os caracteres do texto    				                     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�cTexto,cPesq,cTroca : string										 ���
��������������������������������������������������������������������������������͹��
���Retorno   �cRet													             ���
����������������������������������������������������������������������������������*/
Function RemoveChar( cTexto , cPesq , cTroca )
Local cMsg1	 := ""
Local cMsg2	 := ""
Local cRet	 := ""
Local nPos   := 0
Local nLen	 := Len(cPesq)

DEFAULT cTexto := ""
DEFAULT cPesq  := ""
DEFAULT cTroca := ""

nPos := At(cPesq , cTexto)
If nPos == 0 .OR. nLen == 0
	cRet := cTexto
Else
	cMsg1:= Substr(cTexto,1,nPos-1)
	cMsg2:= Substr(cTexto,(nPos+nLen),Len(cTexto))
	cRet := cMsg1 + cTroca + cMsg2	
EndIf	

Return cRet

