#INCLUDE "PROTHEUS.CH"  
#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFTEF.CH"          

Function LOJA1960 ; Return  // "dummy" function - Internal Use  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJCTransClisitef �Autor�VENDAS CRM     � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em processar as informacoes comuns das          ��� 
���          �transacoes de tef.                                          ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/
Class LJCTransClisitef

	Data oClisitef					//Objeto do tipo LJCComClisitef
	Data cSimbMoeda                 //Simbolo da moeda corrente
	
	Method New()
	Method TratarRet()
    Method Confirmar()
    Method Desfazer()
	Method CarregCup()
	Method TratPad()
	Method TratPadCh()    

EndClass         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �New          �Autor  �Vendas CRM       � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJCTransClisitef.               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(oClisitef) Class LJCTransClisitef

	Self:oClisitef := oClisitef
    
	Self:cSimbMoeda := SuperGetMV("MV_SIMB1") + " "

Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �New          �Autor  �Vendas CRM       � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trata e cria os objetos de retorno para cada tipo de        ���
���          �operacao sitef                                              ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TratarRet(oDadosTran) Class LJCTransClisitef
	
Local oRetSitef := Nil				//Objeto do tipo LJCRetornoSitef
Local lCodBand	:= STILJTEF()
	
Do Case

	Case oDadosTran:nTipoTrans == _CREDITO .OR. ;
		 oDadosTran:nTipoTrans == _DEBITO .OR. ;
		 oDadosTran:nTipoTrans == _CREDITOPARCELADO .OR. ;
		 oDadosTran:nTipoTrans == _DEBITOPARCELADO .OR. ;
		 oDadosTran:nTipoTrans == _DEBITOPREDATADO
		 
		 //Cria o objeto de retorno para cartao
		 oDadosTran:oRetorno := LJCRetTransacaoCCCD():New()
		 
		 //Alimenta os dados padrao do retorno
		 Self:TratPad(@oDadosTran, @oRetSitef)
		 
		oDadosTran:oRetorno:cAdmFin		:= oRetSitef:cAdmFin 
		oDadosTran:oRetorno:lJurosLoja	:= oRetSitef:lJurosLoja			        
		oDadosTran:oRetorno:cParcTEF	:= IIF( oRetSitef:lJurosLoja, "0","1")+StrZero(oRetSitef:nParcelas,2)
		oDadosTran:oRetorno:cTipCart    := oRetSitef:cInstit
		oDadosTran:oRetorno:aAdmin		:= aClone( oRetSitef:aAdmin ) 
		oDadosTran:oRetorno:nParcs		:= oRetSitef:nParcelas
		
		If lCodBand  //Verifica se o atributo cCodBand existe no objeto
			oDadosTran:oRetorno:cCodBand := oRetSitef:cTpCartao
		EndIf 
		
	Case oDadosTran:nTipoTrans == _CHEQUE
	
		 //Cria o objeto de retorno para cheque
		 oDadosTran:oRetorno := LJCRetTransacaoCH():New()
		 
		 //Alimenta os dados padrao do retorno
		 Self:TratPad(@oDadosTran, @oRetSitef)
		 
		 //Alimenta os dados padrao do retorno com cheque
		 Self:TratPadCh(@oDadosTran, @oRetSitef)
		 				 			
	Case oDadosTran:nTipoTrans == _RECARGACELULAR
		
		//Cria o objeto de retorno para cheque
		 oDadosTran:oRetorno := LJCRetTransacaoRC():New()
		 
		 //Alimenta os dados padrao do retorno
		 Self:TratPad(@oDadosTran, @oRetSitef)
		 
		 //Alimenta os dados especificos
		 oDadosTran:oRetorno:cForma := oRetSitef:cFormaCel
		 oDadosTran:oRetorno:nValor := oRetSitef:nValorPgto
		 oDadosTran:oRetorno:aAdmin	:= aClone( oRetSitef:aAdmin )
		
	Case oDadosTran:nTipoTrans == _CORRESPONDENTEBANCARIO
	    
	    //Cria o objeto de retorno para CB
		 oDadosTran:oRetorno := LJCRetTransacaoCB():New()
		 
	    //Alimenta os dados padrao do retorno
		Self:TratPad(@oDadosTran, @oRetSitef)
	    
	    //Alimenta os dados padrao do retorno com CB pago em cheque
		 Self:TratPadCh(@oDadosTran, @oRetSitef)
	    
		//Alimenta os dados especificos
		oDadosTran:oRetorno:oDataVenc 	:= oRetSitef:oDataVenc
		oDadosTran:oRetorno:oVlrOrig 	:= oRetSitef:oVlrOrig
		oDadosTran:oRetorno:oVlrAcre 	:= oRetSitef:oVlrAcre
		oDadosTran:oRetorno:oVlrAbat 	:= oRetSitef:oVlrAbat
	   	oDadosTran:oRetorno:oVlrPgto 	:= oRetSitef:oVlrPgto
	   	oDadosTran:oRetorno:dDataPgto 	:= oRetSitef:dDataPgto
		oDadosTran:oRetorno:cCedente 	:= oRetSitef:cCedente
		oDadosTran:oRetorno:nVlrTotCB 	:= oRetSitef:nVlrTotCB
		oDadosTran:oRetorno:nTipoDocCB 	:= oRetSitef:nTipoDocCB 
		oDadosTran:oRetorno:cCodMod		:= oRetSitef:cCodMod
	
	Case oDadosTran:nTipoTrans == _PBM
	
	Case oDadosTran:nTipoTrans == _ADMINISTRATIVA
    	
    	//Cria o objeto de retorno para funcoes administrativa
		 oDadosTran:oRetorno := LJCRetTransacaoADM():New()
		 
		 //Alimenta os dados padrao do retorno
		 Self:TratPad(@oDadosTran, @oRetSitef)
    	
EndCase

Return oDadosTran

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TratPad      �Autor  �Vendas CRM       � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trata o retorno padrao das transacoes SITEF		          ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TratPad(oDadosTran, oRetSitef) Class LJCTransClisitef

	//Armazena o retorno do SITEF
	oRetSitef := Self:oClisitef:GetRetorno() 	
	
	oDadosTran:oRetorno:oViaCaixa	:= Self:CarregCup(oRetSitef:cViaCaixa)
	oDadosTran:oRetorno:oViaCliente	:= Self:CarregCup(oRetSitef:cViaCliente)
	oDadosTran:oRetorno:lTransOK	:= oRetSitef:lTransOK
	oDadosTran:oRetorno:dData		:= oRetSitef:dData
	oDadosTran:oRetorno:cHora		:= oRetSitef:cHora
    oDadosTran:oRetorno:cAutoriz	:= oRetSitef:cCodAuto
	oDadosTran:oRetorno:cViaCaixa	:= oRetSitef:cViaCaixa
	oDadosTran:oRetorno:cViaCliente	:= oRetSitef:cViaCliente  
   
    LjGrvLog( Nil, " TratPad - NSU do SiTEF (6 posicoes) - oRetSitef:cNsuSitef - Antes LjRmvAcent ",oRetSitef:cNsuSitef )
	oDadosTran:oRetorno:cNsu		:= AllTrim( LjRmvAcent(oRetSitef:cNsuSitef) )
	LjGrvLog( Nil, " TratPad - NSU do SiTEF (6 posicoes) - oRetSitef:cNsuSitef - Depois LjRmvAcent ", oDadosTran:oRetorno:cNsu )
	oDadosTran:oRetorno:cRede		:= oRetSitef:cRede 
	oDadosTran:oRetorno:cNsuAutor   := oRetSitef:cNsuAuto

	oDadosTran:oRetorno:cDocCanc    := oRetSitef:cDocCanRei
	oDadosTran:oRetorno:dDataCanc   := oRetSitef:dDataCanRei 

	oDadosTran:oRetorno:nVlrSaque		:= oRetSitef:nVlrSaque
	oDadosTran:oRetorno:nVlrVndcDesc	:= oRetSitef:nVlrVndcDesc
	oDadosTran:oRetorno:nVlrDescTEF		:= oRetSitef:nVlrDescTEF

	If GetAPOInfo("LOJA1934.PRW")[4] >= Ctod("01/12/2017")
		oDadosTran:oRetorno:cCelular	:= oRetSitef:cCelular
	EndIf
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TratPadCh    �Autor  �Vendas CRM       � Data �  19/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trata o retorno padrao das transacoes SITEF que utilizam    ���
���			 �cheque		          									  ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TratPadCh(oDadosTran, oRetSitef) Class LJCTransClisitef

	//Armazena o retorno do SITEF
	oRetSitef := Self:oClisitef:GetRetorno() 	
	
	oDadosTran:oRetorno:cAutentica := oRetSitef:cAutentica
	oDadosTran:oRetorno:nBanco		:= oRetSitef:nBanco
	oDadosTran:oRetorno:nAgencia	:= oRetSitef:nAgencia
   	oDadosTran:oRetorno:nConta		:= oRetSitef:nConta
   	oDadosTran:oRetorno:nCheque		:= oRetSitef:nCheque
   	oDadosTran:oRetorno:nC1 		:= oRetSitef:nC1
   	oDadosTran:oRetorno:nC2			:= oRetSitef:nC2
   	oDadosTran:oRetorno:nC3			:= oRetSitef:nC3
	oDadosTran:oRetorno:nCompensa	:= oRetSitef:nCompensa
	oDadosTran:oRetorno:nTipoDocCh	:= oRetSitef:nTipoDocCh
   	oDadosTran:oRetorno:cCPFCGC		:= oRetSitef:cCPFCGC
   	oDadosTran:oRetorno:cTelefone	:= oRetSitef:cTelefone
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CarregCup    �Autor  �Vendas CRM       � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Carrega o cupom do SITEF no objeto LJCList		          ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CarregCup(cRetCupom) Class LJCTransClisitef
	
	Local oCupom 	:= LJCList():New()							//Objeto do tipo LJCList para armazenar o espelho do cupom de TEF
	Local cDelimit 	:= CHR(10)									//Delimitador
	Local lLoop		:= .T.                 						//Variavel auxiliar utilizada no while
	Local nPos		:= 0				   						//Variavel auxiliar que guarda a posicao do delimitador na string
	Local cAux		:= ""										//Variavel auxiliar que guarda linha do cupom
			
	//Retira o delimitador do inicio da string
	If Substr(cRetCupom, 1, 1) == cDelimit
		cRetCupom := Substr(cRetCupom, 2)
	EndIf

	//Retira o delimitador do fim da string
	If Substr(cRetCupom, Len(cRetCupom), 1) == cDelimit
		cRetCupom := Substr(cRetCupom, 1, Len(cRetCupom) - 1)
	EndIf
    	
	While lLoop
	    //Procura o delimitador na string
		nPos := At(cDelimit, cRetCupom)
	    
	    //Verifica se encontrou o delimitador
		If nPos > 0 
			cAux := Substr(cRetCupom, 1, nPos-1)
			cRetCupom := Substr(cRetCupom, nPos + 1)
			
			If cAux != cDelimit .AND. cAux != CHR(13)
				oCupom:Add(cAux)
			Endif
		Else
			If !Empty(cRetCupom)
				oCupom:Add(cRetCupom)
			EndIf
			
			lLoop := .F.
		EndIf
	End    
	
Return oCupom

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |Confirmar    �Autor  �Vendas CRM       � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Confirmar as operacoes pendentes.                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Confirmar(oTransacao) Class LJCTransClisitef 
	
	Local nCount := 0				//Variavel auxiliar contador
		
	For nCount := 1 To oTransacao:Count()
	    //Seta a transacao
		Self:oClisitef:SetTrans(oTransacao:Elements(nCount))
	    //Confirma a transacao
		Self:oClisitef:FinTrans(1)
	Next
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |Desfazer     �Autor  �Vendas CRM       � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Desfaz as operacoes pendentes.                    		  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Desfazer(oTransacao) Class LJCTransClisitef 
   	
	Local nCount := 0				//Variavel auxiliar contador
		
	For nCount := 1 To oTransacao:Count()
	    //Seta a transacao
		Self:oClisitef:SetTrans(oTransacao:Elements(nCount))
	    //Desfaz a transacao
		Self:oClisitef:FinTrans(0)
	Next
   	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STILJTEF
Retorna data para verificar o novo campo no m�todo

@author  	Varejo
@version 	P11.8
@since   	22/11/2016
@return  	Nil
/*/
//-------------------------------------------------------------------
Function STILJTEF()
Local lRet 			:= .F.
Local aFonteInfo	:= GetAPOInfo("LOJA1935.PRW")

If Len(aFonteInfo) > 0
	lRet := aFonteInfo[4] >= CTOD("22/11/2016")
EndIf

Return lRet