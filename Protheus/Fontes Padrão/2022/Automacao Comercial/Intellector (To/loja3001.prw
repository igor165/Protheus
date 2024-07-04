#INCLUDE "MSOBJECT.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA3001.CH"

#DEFINE APROVADO "APROVA"

Function LOJA3001() ;Return  // "dummy" function - Internal Use   

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCYMF			�Autor  �Vendas Clientes     � Data �  01/12/09   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Interface da classe LJCYMF, os metodos precisam ser implementados   ���
���			 �na classe LJCYMF.    	    										  ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCYMF
    
    Data cUrl												//Url de conexao com Server do YMF
    Data cPrograma                                          //Politica a ser executada
    Data cTipo                                              //Tipo da Politica
    Data cLayout                                            //Layout da Politica
    Data cUsuario                                           //Usuario do Server YMF
    Data cSenha                                             //Senha do Server do YMF
    Data oDadosEnv											//Objeto do Tipo LJCDadosEnvYMF	
                   
	Method New(cPolitica, cTipo, cLayout)                  //Construtor da Classe.
	Method GeraXml()                                       //Metodo que gera o XML que sera enviado.
	Method EnviaXml()                                      //Metodo que envia o XML ao Servico do YMF.
	Method Executar()		                               //Metodo que executa o Servico do YMF.
	Method TrataEnvio(oValor, cTipo)                       //Metodo responsavel em formatar os dados de envio.
	Method TrataRetorno()                                  //Metodo responsavel pelo retorno do Servico do YMF.

End Class

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �New		�Autor  �Microsiga           � Data �  01/12/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo Construtor da Classe                                 ���
�������������������������������������������������������������������������͹��
���			 �cPolitica - Nome da Politica a ser usada definida no YMF.	  ���
���Parametros�cTipo		- Tipo da Politica usada.						  ���
���			 �cLayout	- Layout da Politica.							  ���
�������������������������������������������������������������������������͹��
���Uso       � Sigaloja/Fronloja                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(cPolitica, cTipo, cLayout) Class LJCYMF 

    Self:cPrograma := ALLTRIM(cPolitica)                                       
    Self:cTipo     := ALLTRIM(cTipo)                                      
    Self:cLayout   := ALLTRIM(cLayout)                                      
    
    Self:cUrl	   := ALLTRIM(SuperGetMv("MV_TOLURL", .F.,""))
    Self:cUsuario  := ALLTRIM(SuperGetMv("MV_TOLUSUA", .F.,""))
    Self:cSenha    := ALLTRIM(SuperGetMv("MV_TOLSENH", .F.,""))                                        
    
    Self:oDadosEnv := LJCDadosEnvYMF():New()									

Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � GeraXml  �Autor  �Microsiga           � Data �  01/12/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo responsavel em gerar o XML que sera enviado ao YMF. ���
�������������������������������������������������������������������������͹��
���Retorno	 � cXML - String contendo o XML.							  ���
�������������������������������������������������������������������������͹��
���Uso       � Sigaloja/Fronloja                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GeraXml() Class LJCYMF   
                      
	Local cXML 	   := "" 
	Local cCampo   := "" 
	Local nCount   := 1 
	Local oCliente := Self:oDadosEnv:oCliente

	//������������������������������������������������������������Ŀ
	//�Cria a estrutura do XML que sera enviado para o intellector.�
	//��������������������������������������������������������������
	cXML 	:= "<?xml version='1.0' encoding='ISO-8859-1'?>"
	
	cXML 	+= "<ANALISE_CREDITO>"
	cXML 	+= "	<programa>" + Self:cPrograma + "</programa>" 	//Nome da politica do intellector
	cXML 	+= "	<tipo>"     + Self:cTipo     + "</tipo>"		//Tipo da politica utilizada no intellector
	cXML 	+= "	<layout>"   + Self:cLayout   + "</layout>"	  	//Layout da politica definida no intellector
	cXML 	+= "	<usuario>"  + Self:cUsuario  + "</usuario>" 	//Usuario do intellector
	cXML 	+= "	<senha>"    + Self:cSenha    + "</senha>"	   	//Senha do intellector 
	
	cXML 	+= "	<VALOR_LIMITE_DE_CREDITO>" + Self:oDadosEnv:cValorLimi + "</VALOR_LIMITE_DE_CREDITO>"
	cXML 	+= "	<DATA_VENDA>"              + Self:oDadosEnv:cDataVenda + "</DATA_VENDA>"
	cXML 	+= "	<DATA_VENCIMENTO_LIMITE>"  + Self:oDadosEnv:cDataVenc  + "</DATA_VENCIMENTO_LIMITE>"
	cXML 	+= "	<TITULOS_EM_ABERTO>"       + Self:oDadosEnv:cTitulosAb + "</TITULOS_EM_ABERTO>"	
	cXML 	+= "	<TOLERANCIA_LIMITE>"       + Self:oDadosEnv:cTolLimite + "</TOLERANCIA_LIMITE>"	
	cXML 	+= "	<VALOR_FINANCIADO>"        + Self:oDadosEnv:cValorFinc + "</VALOR_FINANCIADO>"	
	cXML 	+= "	<VALOR_TITULOS_EM_ATRASO>" + Self:oDadosEnv:cValorTitA + "</VALOR_TITULOS_EM_ATRASO>"	

	//����������������������������Ŀ
	//�Inseri Campos do SA1 no XML.�
	//������������������������������	
	For nCount := 1 To oCliente:Elements(1):Campos():Count()
		
		cCampo := oCliente:Elements(1):Campos():Elements(nCount):cNome     

		cXML 	+= "<" + cCampo + ">"
		
		cXML 	+= Self:TrataEnvio(oCliente:Elements(1):Campos():Elements(nCount):oValor, oCliente:Elements(1):Campos():Elements(nCount):cTipo)
		
		cXML 	+= "</" + cCampo + ">"

	Next
	
	cXML 	+= "</ANALISE_CREDITO>"

Return cXML

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � EnviaXml �Autor  �Microsiga           � Data �  01/12/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo que enviara o XML ao YMF.                           ���
�������������������������������������������������������������������������͹��
���Retorno	 � oRetorno - Objeto do tipo LJCDadosRetYMF.				  ���
�������������������������������������������������������������������������͹��
���Uso       � Sigaloja/Fronloja                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method EnviaXml(cXML) Class LJCYMF   

	Local oWSIntellector :=	Nil  
	Local oRetorno       := -1      

	//�������������������������Ŀ
	//�Chama o WS do intellector�
	//���������������������������
	oWSIntellector := WSPolicyExecutionService():New()
	
	oWSIntellector:_URL := Self:cUrl   
	
	If oWSIntellector:executePolicy(cXML)
	
   	    oRetorno := ::TrataRetorno(oWSIntellector)
	Else                                                                               
	
		MsgAlert(STR0001) //"N�o foi Poss�ve conectar no WebService."
	EndIf
                             
Return oRetorno  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � Executar �Autor  �Microsiga           � Data �  01/12/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo que executa o Servico do YMF.                       ���
�������������������������������������������������������������������������͹��
���Retorno	 � oRet - Objeto do tipo LJCDadosRetYMF.		        	  ���
�������������������������������������������������������������������������͹��
���Uso       � Sigaloja/Fronloja                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Executar() Class LJCYMF   
	Local oRet := Nil
	Local cXML := ""   
	
	cXml := Self:GeraXml()   

	oRet := Self:EnviaXml(cXml)   

Return oRet

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �TrataEnvio  �Autor  �Microsiga           � Data �  01/12/09   ���
���������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em formatar os dados para o envio ao YMF.  ���
���������������������������������������������������������������������������͹��
���Param.    � oValor - Conteudo a ser formatado                            ���
���			 � cTipo  - Tipo a ser tratado									���
���������������������������������������������������������������������������͹��
���Uso       �Sigaloja / Fronloja                                           ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Method TrataEnvio(oValor, cTipo) Class LJCYMF   

	Local oRetorno := Nil
	
	If Empty(oValor)
		oRetorno := ""	
	Else
		Do Case
			Case cTipo == "N"
				oRetorno := CVALTOCHAR(oValor)  
				oRetorno := STRTRAN(oRetorno, ",", ".")
				
			Case cTipo == "D"
				oRetorno := DTOS(oValor)
				
			Otherwise
		EndCase
		
		oRetorno := ALLTRIM(oValor)
	EndIf

Return oRetorno

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �TrataRetorno�Autor  �Microsiga           � Data �  01/12/09   ���
���������������������������������������������������������������������������͹��
���Desc.     � Metodo responsavel pelo retorno                              ���
���������������������������������������������������������������������������͹��
���Param.    � oWSIntellector - Retorno do WS do YMF.						���
���������������������������������������������������������������������������͹��
���Retorno   � oRetorno - Objeto LJCDadosRetYMF Formatado.                  ���
���������������������������������������������������������������������������͹��
���Uso       � Sigaloja/Fronloja                                            ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Method TrataRetorno(oWSIntellector) Class LJCYMF   

    Local cRetornoXML := ""
    Local oXml        := LJCXml():New()  
    Local oEstrutura  := Nil   
    Local cDelimit    := "_"
    Local oDadosRet   := LJCDadosRetYMF():New()

	cRetornoXML := oWSIntellector:cXmlOutputString
	
	oXml:Criar(cRetornoXML, cDelimit, Nil)
	
	oEstrutura := oXml:oXml  
	                  
	If !Empty(oEstrutura:_RAIZ:_LPT__SMSGERRO:TEXT)
		
	    oDadosRet:nCodErro := VAL(oEstrutura:_RAIZ:_LPT__IRETORNO:TEXT)
	    oDadosRet:cMsgErro := ALLTRIM(oEstrutura:_RAIZ:_LPT__IRETORNO:TEXT)
	    
   		MsgAlert(STR0002 + "-> " + CVALTOCHAR(oDadosRet:nCodErro) + " - " + oDadosRet:cMsgErro) //"Retorno da Consulta
	Else
		oDadosRet:lAprovado  := IIF( ALLTRIM(oEstrutura:_RAIZ:_LPT__sAcao:TEXT) == APROVADO, .T., .F.)
		oDadosRet:cMotBloq	 := ALLTRIM(oEstrutura:_RAIZ:_MOTIVO_BLOQUEIO:TEXT)
		oDadosRet:nValLimite := VAL(oEstrutura:_RAIZ:_LIMITE_CREDITO:TEXT)
		oDadosRet:dDtVctoLim := STOD(oEstrutura:_RAIZ:_DATA_VENCIMENTO_LIMITE:TEXT)
	EndIf

Return oDadosRet   