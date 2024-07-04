#INCLUDE "PROTHEUS.CH"        
#INCLUDE "MSOBJECT.CH"
#INCLUDE "LOJA1906.CH"

Static lUsePayHub := Nil //Vari�vel que controla se o ambiente est� atualizado para poder utilizar o Payment Hub.

Function LOJA1906 ; Return  // "dummy" function - Internal Use

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJCConfiguradorTef�Autor  �VENDAS CRM  � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Carrega as configuracoes de TEF disponiveis para a aplica- ��� 
���          � -cao.                                                      ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/
Class LJCConfiguradorTef

	Data oCCCD
	Data oCheque
	Data oCB
	Data oRecCel                   
	Data oPBM 
	Data oCfgTef
	Data oCupom
	Data lAtivo
	Data lInfAdm  
	Data aFormas    
	Data aAdmin
	Data oComSitef
	Data oComPaymentHub
	Data oPgDig
	
	Method New()
	Method GetCCCD()
	Method GetCheque()
	Method GetCB()
	Method GetRecCel()
	Method GetPBM()  
	Method GetCupom()
	Method ISCCCD()
	Method ISCheque()
	Method ISCB()
	Method ISRecCel()
	Method ISPBM()
	Method ISAtivo()
	Method Carregar()
	Method AtivaSitef()
	Method AtivaDisc()
	Method AtivaPayGo()
	Method AtivaDirecao()
	Method AtivaCupom() 
	Method AtivaFormas()
	Method AtivaAdm()
	Method Fechar() 
	Method GetAdm()			//Indica se o configurador necessita de administradora Financeira 
	Method GetAdmin()		//Retorna as administradoras
	Method GetFormas()
	Method AtivaPaymentHub()
	Method ISPgtoDig()
	Method ISPayHub()
	Method GetPgtoDigital()

EndClass  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �New          �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New() Class LJCConfiguradorTef

	Self:oCfgTef := LJCCfgTef():New() 
    
	Self:oCCCD		:= Nil
	Self:oCheque	:= Nil
	Self:oCB		:= Nil
	Self:oRecCel	:= Nil                   
	Self:oPBM		:= Nil 
	Self:oCupom		:= Nil
	Self:lAtivo		:= .F.
	Self:lInfAdm	:= .T.
	Self:aFormas	:= {}       
	Self:aAdmin     := {}	//Classe respons�vel por armazenar as administradoras
	Self:oPgDig		:= Nil

Return Self           

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IsCCCD       �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se o cart�o est� habilitado.                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ISCCCD() Class LJCConfiguradorTef
Local lRet := .F.

lRet := Self:oCfgTef:lAtivo .And. ;
		(	Self:oCfgTef:oSitef:lCCCD 							.OR. ; //Sitef
			Self:oCfgTef:oDiscado:lGPCCCD 						.OR. ; //Gerenciador Padrao Discado
		 	Self:oCfgTef:oDiscado:lHiperCDCCCD 					.OR. ; //HiperCard
			Self:oCfgTef:oDiscado:lTecBanCCCD 					.OR. ; //TecBan
			Self:oCfgTef:oPayGo:lCCCD 							.OR. ; //PayGo
			Self:oCfgTef:oDirecao:lCCCD 						.OR. ; //TEF Direcao
			If(LjUsePayHub(),Self:oCfgTef:oPaymentHub:lCCCD,.F.) 	 ; //Payment Hub
		)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IsCheque     �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se o cheque est� habilitado.                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ISCheque() Class LJCConfiguradorTef 
Return (Self:oCfgTef:lAtivo .AND. (Self:oCfgTef:oSitef:lCheque .OR. Self:oCfgTef:oDiscado:lGPCheque .OR. Self:oCfgTef:oDiscado:lTecBanCheque .OR. Self:oCfgTef:oPayGo:lCheque .OR. Self:oCfgTef:oDirecao:lCheque))

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IsCB         �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se o correspondente bancario est� habilitado.      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ISCB() Class LJCConfiguradorTef 
Return (Self:oCfgTef:lAtivo .AND. Self:oCfgTef:oSitef:lCB)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IsRecCel     �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se a recarga celular est� habilitada.              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ISRecCel() Class LJCConfiguradorTef
Return (Self:oCfgTef:lAtivo .AND. Self:oCfgTef:oSitef:lRC)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IsPBM        �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se a PBM est� habilitado.	                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ISPBM() Class LJCConfiguradorTef 
Return (Self:oCfgTef:lAtivo .AND. Self:oCfgTef:oSitef:lPBM)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IsAtivo      �Autor  �Vendas CRM       � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna se conseguiu carregar as configuracoes do TEF e se  ���
���          �o mesmo esta habilitado/ativo                               ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ISAtivo() Class LJCConfiguradorTef 
Return Self:lAtivo

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetCCCD      �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetCCCD() Class LJCConfiguradorTef 
Return Self:oCCCD

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetCheque    �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetCheque() Class LJCConfiguradorTef 
Return Self:oCheque

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetCB        �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetCB() Class LJCConfiguradorTef 
Return Self:oCB 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetRecCel    �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetRecCel() Class LJCConfiguradorTef 
Return Self:oRecCel 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetPBM       �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetPBM() Class LJCConfiguradorTef 
Return Self:oPBM 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetCupom     �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetCupom() Class LJCConfiguradorTef 
Return Self:oCupom 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Carregar     �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Carrega as configuracoes de TEF disponiveis.                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Carregar(cCodigo, lMensagem) Class LJCConfiguradorTef 
	
	Local lRet := .F.               //Retorno da Classe
	Local cTipo := "0"
	
	DEFAULT lMensagem := .T.   
	
	//Carrega as configuracoes do TEF

	lRet := Self:oCfgTef:Carregar(cCodigo,lMensagem)
	
	//Verifica se conseguiu carregar as configuracoes do TEF ou se o TEF esta habilitado/ativo
	Self:lAtivo := (lRet .AND. Self:oCfgTef:lAtivo)
	
	If !Self:lAtivo
		lRet := .F.
	Else 
		
		//Verifica se existe alguma configuracao do SITEF habilitada
		If Self:oCfgTef:oSitef:lCCCD .OR. ;
			Self:oCfgTef:oSitef:lCheque .OR. ;
			Self:oCfgTef:oSitef:lCB .OR. ;
			Self:oCfgTef:oSitef:lRC .OR. ;
			Self:oCfgTef:oSitef:lPBM
			
			Self:lInfAdm := Self:oCfgTef:oSitef:lInfAdm
			lRet := Self:AtivaSitef()
					
		//Verifica se existe alguma configuracao do TEF Discado(GP) habilitada
		ElseIf Self:oCfgTef:oDiscado:lGPCCCD .OR. ;
				Self:oCfgTef:oDiscado:lGPCheque .OR. ;
				Self:oCfgTef:oDiscado:lTECBANCCCD .OR. ;
				Self:oCfgTef:oDiscado:lTECBANCheque .OR. ;
				Self:oCfgTef:oDiscado:lHIPERCDCCCD .OR. ;
				Self:oCfgTef:oDiscado:lHIPERCDCheque
		        
		        Self:lInfAdm := Self:oCfgTef:oDiscado:lInfAdm
				lRet	:= Self:AtivaDisc()
				cTipo 	:= "2"
		
		//Verifica se existe alguma configuracao do TEF Discado(PayGo) habilitada
		ElseIf Self:oCfgTef:oPayGo:lCCCD .OR. ;
				Self:oCfgTef:oPayGo:lCheque
				
				Self:lInfAdm := Self:oCfgTef:oPayGo:lInfAdm
				lRet 	:= Self:AtivaPayGo() 
				cTipo 	:= "2"

		//Verifica se existe alguma configuracao do TEF Direcao habilitada
		ElseIf Self:oCfgTef:oDirecao:lCCCD .OR. ;
				Self:oCfgTef:oDirecao:lCheque  
				
				Self:lInfAdm := Self:oCfgTef:oDirecao:lInfAdm
				lRet 	:= Self:AtivaDirecao()
				cTipo 	:= "2"
		EndIf

		//Verifica se existe alguma configuracao do Payment Hub habilitada		
		If LjUsePayHub()
			lRet := Self:AtivaPaymentHub()
		EndIf 

		If ExistFunc("STTMTT") .AND. cTipo <> "0"
			STTMTT(cTipo)
		EndIf 

		If lRet
			
			Self:AtivaCupom()  
			Self:AtivaFormas()   
			Self:AtivaAdm()
		
		EndIf
	EndIf
	
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AtivaSitef   �Autor  �Vendas CRM       � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cria comunicacao com a TOTVSAPI.DLL, inicializa comunicacao ���
���          �com o sitef e cria os objetos para cada tipo de servico     ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AtivaSitef() Class LJCConfiguradorTef 
	
	Local lRetorno 		:= .F.				//Retorno do metodo
	Local oComCliSitef 	:= Nil				//Objeto do tipo LJCComCLisitef
	Local oTotvsApi 	:= NIL				//Objeto do tipo LJCTotvsAPI    
    Local oImpBWECF 	:= Nil  //STFECFCONTROL      
	Local lHomTEF		:= FindFunction("STHOMTEF") .AND. STWIsTotvs(SM0->M0_CGC)
	
	//Cria o objeto TOTVSAPI (Comunicacao com a TOTVSAPI.DLL)                               
	
	// Verifico se existe a funcao antes de instaciar a classe
	If oTotvsApi == Nil 
		If FindFunction("LOJA1326")
		
			oImpBWECF          := STFECFCONTROL():STFECFCONTROL(lHomTEF)  //Objeto do tipo STBCCECFCONTROL
    		oImpBWECF:CreateTotvsApi()
    		oTotvsApi := oImpBWECF:GetTotvsApi()
			If !oTotvsApi:ComAberta()
				//Abre comunicacao com TOTVSAPI.DLL
				If oTotvsApi:AbrirCom() <> -1
					//Cria o objeto de comunicacao com o SITEF
					oComCliSitef := LJCComCliSitef():New(oTotvsApi)
					//Abre comunicacao com o SITEF
					If oComCliSitef:ConfSitef(Self:oCfgTef:oSitef:cIpAddress, Self:oCfgTef:oSitef:cEmpresa, Self:oCfgTef:oSitef:cTerminal) == 0
						//Guardo a comunica��o com Sitef
						::oComSitef := oComCliSitef
						lRetorno := .T.
					Else
						lRetorno := .F.
						STFMessage("SITEF", "ALERT", STR0004) //"ATEN��O! N�o foi poss�vel abrir comunica��o com o SITEF, n�o ser� possivel realizar transa��es com o TEF! Verifique com o superior imediato!"
						STFShowMessage( "SITEF")
					EndIf
				Else
					lRetorno := .F.
					STFMessage("SITEF", "ALERT", STR0001) //"N�o foi poss�vel abrir comunica��o com a TOTVSAPI.DLL"
					STFShowMessage( "SITEF")
				EndIf
			EndIf 
			

		EndIf	
	Else
		lRetorno := .T.			
	EndIf 
	    
	If lRetorno
	
		//Instancia a classe para transacoes de cartao
		If Self:oCfgTef:oSitef:lCCCD 
			Self:oCCCD := LJCClisitefCCCD():New(oComCliSitef)
		EndIf
		
		//Instancia a classe para transacoes de cheque
		If Self:oCfgTef:oSitef:lCheque 
			Self:oCheque := LJCClisitefCheque():New(oComCliSitef)
		EndIf
		
		//Instancia a classe para transacoes de recarga de celular
		If Self:oCfgTef:oSitef:lRC 
			Self:oRecCel := LJCClisitefRC():New(oComCliSitef)
		EndIf
		
		//Instancia a classe para transacoes de correspondente bancario
		If Self:oCfgTef:oSitef:lCB 
			Self:oCB := LJCClisitefCB():New(oComCliSitef)
		EndIf
		
		//Instancia a classe para transacoes de PBM
		If Self:oCfgTef:oSitef:lPBM 
			Self:oPBM := LJCClisitefPBM():New(oComCliSitef, Self:oCfgTef:oSitef:oPbms)
		EndIf
	
	EndIf  
		
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AtivaDisc    �Autor  �Vendas CRM       � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Inicializa comunicacao com o TEF Discado e cria os objetos  ���
���          �para cada tipo de servico     							  ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AtivaDisc() Class LJCConfiguradorTef 
	
	Local oComDiscado  	:= Nil              //Objeto do tipo LJAComDiscado
	Local lRetorno 		:= .F.				//Retorno do metodo    
	Local oTransDiscado := NIL				//Objeto transa��o discado
		
	//Criar objeto de comunicacao com o TEF Discado(GP)
	oComDiscado := LJCComGP():New(Self:oCfgTef:oDiscado:oConfig)		
	
	//Abri comunicacao com o TEF Discado(GP)
	lRetorno := oComDiscado:InicializaConf()
		
	If lRetorno
	
		//Instancia a classe para transacoes de cartao
		If Self:oCfgTef:oDiscado:lGPCCCD .OR. Self:oCfgTef:oDiscado:lTECBANCCCD .OR. Self:oCfgTef:oDiscado:lHIPERCDCCCD  
			Self:oCCCD := LJCDiscadoCCCD():Create(oComDiscado)   
			oTransDiscado := 	Self:oCCCD:oTransDiscado
		EndIf
		
		//Instancia a classe para transacoes de cheque
		If Self:oCfgTef:oDiscado:lGPCheque .OR.  Self:oCfgTef:oDiscado:lHIPERCDCheque
			Self:oCheque := LJCDiscadoCheque():Create(oComDiscado)
			oTransDiscado := 	Self:oCheque:oTransDiscado
		EndIf 
		
		If oTransDiscado <> NIL   
			oTransDiscado:Desfazer()
		EndIf
		
	EndIf
	
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AtivaPayGo   �Autor  �Vendas CRM       � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Inicializa comunicacao com o TEF Discado (PayGo) e          ���
���          �cria os objetos para cada tipo de servico     			  ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AtivaPayGo() Class LJCConfiguradorTef 
	
	Local oComDiscado  	:= Nil              //Objeto do tipo LJAComDiscado
	Local lRetorno 		:= .F.				//Retorno do metodo     
	Local oTransDiscado := NIL				//Objeto transa��es discado
	

	//Criar objeto de comunicacao com o TEF Discado(GP)
	oComDiscado := LJCComPayGo():New(Self:oCfgTef:oPayGo:oConfig)		

	//Abri comunicacao com o TEF Discado(Pay Go)
	lRetorno := oComDiscado:InicializaConf()
	
	If lRetorno
	
		//Instancia a classe para transacoes de cartao
		If Self:oCfgTef:oPayGo:lCCCD
			Self:oCCCD := LJCDiscPayGoCCCD():Create(oComDiscado) 
			oTransDiscado := 	Self:oCCCD:oTransDiscado
		EndIf
		
		//Instancia a classe para transacoes de cheque
		If Self:oCfgTef:oPayGo:lCheque
			Self:oCheque := LJCDiscPayGoCheque():Create(oComDiscado) 
			oTransDiscado := 	Self:oCheque:oTransDiscado
		EndIf
		

		If oTransDiscado <> NIL   
			oTransDiscado:Desfazer()
		EndIf

	EndIf


Return lRetorno        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AtivaDirecao �Autor  �Vendas CRM       � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Inicializa comunicacao com o TEF Discado (PayGo) e          ���
���          �cria os objetos para cada tipo de servico     			  ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AtivaDirecao() Class LJCConfiguradorTef 
	
	Local oComDiscado  	:= Nil              //Objeto do tipo LJAComDiscado
	Local lRetorno 		:= .F.				//Retorno do metodo
	Local oTransDiscado	:= NIL				//Objeto transa��o discado
	

	//Criar objeto de comunicacao com o TEF Discado(GP)
	oComDiscado := LJCComDirecao():New(Self:oCfgTef:oDirecao:oConfig)		

	//Abri comunicacao com o TEF Discado(Pay Go)
	lRetorno := oComDiscado:InicializaConf()
	
	If lRetorno
	
		//Instancia a classe para transacoes de cartao
		If Self:oCfgTef:oDirecao:lCCCD
			Self:oCCCD := LJCDiscDirecaoCCCD():Create(oComDiscado)     //alterado por causa da heran�a 
			oTransDiscado := 	Self:oCCCD:oTransDiscado
		EndIf
		
		//to do Instancia a classe para transacoes de cheque
	   	If Self:oCfgTef:oDirecao:lCheque
	   		//Self:oCheque := LJCDiscPayGoCheque():New(oComDiscado) 
	   		oTransDiscado := 	Self:oCheque:oTransDiscado
	   	EndIf
	   
		If oTransDiscado <> NIL   
			oTransDiscado:Desfazer()
		EndIf
		
	EndIf


Return lRetorno        


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AtivaCupom   �Autor  �Vendas CRM       � Data �  28/12/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Inicializa o componente cupom    							  ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Method AtivaCupom() Class LJCConfiguradorTef

	Self:oCupom := LJCCupom():New()

Return .T.  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AtivaFormas  �Autor  �Vendas CRM       � Data �  28/12/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Inicializa o componente formas  							  ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Method AtivaFormas() Class LJCConfiguradorTef
    Local oBPgtos := STBWCPayment():STBWCPayment()   //Model das formas de pagamento
    Local nI     := 0   							//Vari�vel contadora
    Local oPgtos := oBPgtos:oPayX5:GetAllData()     //Model das formas de pagamento
    Local oMdlPgtos  := oPgtos:GetModel("GridStr")   //Model das formas de pagamento


 	For nI := 1 To oMdlPgtos:Length()

		oMdlPgtos:GoLine(nI)

		aAdd( Self:aFormas, {AllTrim(oMdlPgtos:GetValue("X5_TYPE")), oMdlPgtos:GetValue("X5_DESC")})

   
	Next
	
	oMdlPgtos := FreeObj(oMdlPgtos)
	oPgtos	  := FreeObj(oPgtos)   
	oBPgtos	  := FreeObj(oBPgtos)

Return .T.  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Fechar    �Autor  �Vendas CRM       � Data �  18/01/2013���
�������������������������������������������������������������������������͹��
���Desc.     �Fecha a DLL                    							  ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Method Fechar() Class LJCConfiguradorTef
	//Verifica se existe alguma configuracao do SITEF habilitada
			


			
//Instancia a classe para transacoes de cartao
If Self:oCfgTef:oSitef:lCCCD .AND. ValType(Self:oCCCD:oTransSitef:oCliSitef) == "O"  

	Self:oCCCD:oTransSitef:oCliSitef:Fechar()

ElseIf Self:oCfgTef:oSitef:lCheque .AND. ValType(Self:oCheque:oTransSitef:oCliSitef) == "O"

	Self:oCheque:oTransSitef:oCliSitef:Fechar()    
	
ElseIf Self:oCfgTef:oSitef:lRC .AND. ValType(Self:oRecCel:oTransSitef:oCliSitef) == "O"  

	Self:oRecCel:oTransSitef:oCliSitef:Fechar() 
		
ElseIf Self:oCfgTef:oSitef:lCB .AND. ValType(Self:oCB:oTransSitef:oCliSitef) == "O"  

	Self:oCB:oTransSitef:oCliSitef:Fechar() 

ElseIf Self:oCfgTef:oSitef:lPBM .AND. ValType(Self:oPBM:oTransSitef:oCliSitef) == "O"

	Self:oPBM:oTransSitef:oCliSitef:Fechar()

EndIf

  
	If Valtype(Self:oCCCD) == "O"
	//Libera os Objetos
		FreeObj(Self:oCCCD)  
   		Self:oCCCD := NIL 
    EndIf
	
	If Valtype(Self:oCheque) == "O"
		FreeObj(Self:oCheque)
		Self:oCheque := NIL  
	EndIf
	
	If Valtype(Self:oCB) == "O"
		FreeObj(Self:oCB)
		Self:oCB := NIL
	EndIf
	
	If ValType(Self:oRecCel) == "O"
		FreeObj(Self:oRecCel)    
		Self:oRecCel := NIL                  
	EndIf
	
	If ValType(Self:oPBM) == "O"
		FreeObj(Self:oPBM)
   		Self:oPBM := NIL
   	EndIf 
	
	FreeObj(Self:oCfgTef)
	Self:oCfgTef := NIL
	
	FreeObj(Self:oCupom)
	Self:oCupom := NIL   

Return .T. 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetAdm       �Autor  �Vendas CRM       � Data �  04/02/2013���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se o configurador necessita de administradora Finan  �
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Method GetAdm() Class LJCConfiguradorTef        

Return 	Self:lInfAdm  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AtivaAdm     �Autor  �Vendas CRM       � Data �  04/02/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     �Busca as administradoras Financeiras                        ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AtivaAdm() Class LJCConfiguradorTEF      
 
	Local aArea	:= GetArea()             //WorkArea Ativa
	Local aAreaSAE := SAE->(GetArea())	 //WorkArea Anteriror SAE
	Local aAreaMDE := MDE->(GetArea())   //WorkArea Anterior MDE
	Local nParcDe := 0                   //Parcela De
	Local nParcAte := 0                  //Parcela Ate
	Local lAEREDEAUT	:= SAE->(ColumnPos("AE_REDEAUT")) > 0
	Local cBandSITEF	:= ""
	Local cDesBandMDE 	:= ""
	Local cRedeSITEF	:= ""
	Local cDesRedeMDE 	:= ""
	
	
	DbSelectArea("MDE") 
	MDE->(DbSetOrder(1))  //MDE_FILIAL+MDE_CODIGO
	DbSelectArea("SAE")
	DbSetOrder(1) //AE_FILIAL+AE_COD
	DbSeek(xFilial("SAE"))    
	//To: Verificar a possibilidade de filtrar pela forma de pagamento CC/CD 
	
	While !SAE->(Eof()) .AND. SAE->AE_FILIAL == xFilial("SAE")
 		nParcDe := SAE->AE_PARCDE                 
		nParcAte := SAE->AE_PARCATE 
		
		//Se parcela De/Ate vier em branco configua 1 a 99
		If nParcDe = 0 .AND. nParcAte = 0    
			nParcDe := 1 
			nParcAte := Val(Replicate("9", SAE->(TamSx3("AE_PARCATE")[1])))
		EndIf
		
		If !Empty(SAE->AE_ADMCART) .And. MDE->(DbSeek(xFilial("MDE")+SAE->AE_ADMCART ))
			cBandSITEF	:= AllTrim(MDE->MDE_CODSIT) 	//Codigo da Bandeira (Retornado pelo SITEF)
			cDesBandMDE := MDE->MDE_DESC	//Descricao da Bandeira
		Else
			cBandSITEF	:= ""
			cDesBandMDE := SAE->AE_DESC
		EndIf
		
		If lAEREDEAUT //Controle pela Rede que autorizou a transacao TEF
			If !Empty(SAE->AE_REDEAUT) .And. MDE->(DbSeek(xFilial("MDE")+SAE->AE_REDEAUT ))
				cRedeSITEF	:= AllTrim(MDE->MDE_CODSIT) 	//Codigo da Rede autorizadora da transa��o TEF (Retornado pelo SITEF)
				cDesRedeMDE := MDE->MDE_DESC	//Descricao da Rede
			Else
				cRedeSITEF	:= ""
				cDesRedeMDE := ""
			EndIf
		Else
			cRedeSITEF	:= ""
		EndIf
		
		AAdd(Self:aAdmin, {	SAE->AE_COD											,; //01-Codifo da Adm. Financeira
							AllTrim(SAE->AE_TIPO)								,; //02-Tipo (CC,CD,...)
							SAE->AE_COD + " - " + AllTrim(Upper(SAE->AE_DESC))	,; //03-Codigo e Nome da Adm. Financeira. (Ex. 001 - VISA)
							nParcDe												,; //04-Parcela Inicial
							nParcAte											,; //05-Parcela Final
							SAE->AE_ADMCART										,; //06-Codigo Relacionado a tabela MDE para a Bandeira
							cDesBandMDE											,; //07-Descricao da Bandeira 
							cBandSITEF 											,; //08-Codigo da Bandeira(campo MDE_CODSIT)
							cRedeSITEF											,; //09-Codigo da Rede (Campo MDE_CODSIT)
							cDesRedeMDE 										}) //10-Descricao da Rede (campo MDE_DESC)
		
		SAE->(DbSkip())
	End

     RestArea(aAreaSAE)
     RestArea(aAreaMDE)
     RestArea(aArea) 

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetFormas    �Autor  �Vendas CRM       � Data �  04/02/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna as formas de pagamento                               �
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Method GetFormas() Class LJCConfiguradorTef        

Return 	Self:aFormas

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetAdmin     �Autor  �Vendas CRM       � Data �  04/02/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a Administradora Financeira                         ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Method GetAdmin() Class LJCConfiguradorTef

Return Self:aAdmin     

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} AtivaPaymentHub
Inicializa comunicacao com o Payment Hub.

@type       Method
@author     Alberto Deviciente
@since      14/07/2020
@version    12.1.27

@return lRetorno, L�gico, Retorna se conseguiu fazer a comunica��o com a API do Payment Hub.
/*/
//-------------------------------------------------------------------------------------
Method AtivaPaymentHub() Class LJCConfiguradorTef 
	
	Local lRetorno 		:= .F.				//Retorno do metodo
	Local oComPaymentHub:= Nil				//Objeto do tipo LJCComPaymentHub

	LjGrvLog("TPD"," Inicio - Inicializa comunicacao com o Payment Hub.", )

	//Cria o objeto de comunicacao com o Payment Hub
	oComPaymentHub := LJCComPaymentHub():New(Self:oCfgTef:oPaymentHub)

	//Testa a comunicacao com o Payment Hub
	If oComPaymentHub:CommPaymentHub()
		::oComPaymentHub := oComPaymentHub
		lRetorno := .T.
		LjGrvLog("TPD"," Comunicacao com o Payment Hub efetuada.", )
	Else
		lRetorno := .F.
		STFMessage("PaymentHub", "ALERT", STR0005) // "N�o foi poss�vel se comunicar com o Payment Hub."
		STFShowMessage( "PaymentHub")
		LjGrvLog("TPD"," N�o foi poss�vel se comunicar com o Payment Hub.", )
	EndIf
	    
	If lRetorno
	
		//Instancia a classe para transacoes de cartao
		If Self:oCfgTef:oPaymentHub:lCCCD 
			Self:oCCCD := LJCPaymentHubCCCD():New(oComPaymentHub)
		EndIf

		If Self:oCfgTef:oPaymentHub:lPagDig
			Self:oPgDig := LJCPaymentHubDigitais():New(oComPaymentHub)
		EndIf
	
	EndIf

	LjGrvLog("TPD"," Fim - Inicializa comunicacao com o Payment Hub. lRetorno -> ", lRetorno)
		
Return lRetorno

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} AtivaPaymentHub
Funcao criada apenas para verificar se o ambiente est� atualizado para poder utilizar o Payment Hub.
*** Excluir esta fun��o quando os campos existirem por padrao na tabela MDG.

@type       Function
@author     Alberto Deviciente
@since      31/07/2020
@version    12.1.27

@return lRetorno, L�gico, Retorna se o ambiente est� atualizado para poder utilizar o Payment Hub. 
/*/
//-------------------------------------------------------------------------------------
Function LjUsePayHub()
Local aFontes	:= {}
Local aCampos 	:= {}
Local aInfoFonte:= {}
Local nCount 	:= 0
Local lOK 		:= .T.
Local dDataRef 	:= Nil
Local cAliasTab	:= ""
Local cCampoTab	:= ""
Local cMsg 		:= ""

LJGrvLog("TOTVS_PAGAMENTO_DIGITAL", " Inicio da Verifica��o " ,ProcName(1))

LJGrvLog("TOTVS_PAGAMENTO_DIGITAL", " lUsePayHub " ,lUsePayHub )

If lUsePayHub == Nil
	dDataRef 	:= CToD("28/08/2020") //Data de referencia dos fontes

	//Fontes a serem verificados se estao atualizados
	aAdd( aFontes, "LJCCfgTefPaymentHub.PRW")
	aAdd( aFontes, "LJCComPaymentHub.PRW")
	aAdd( aFontes, "LJCPaymentHubCCCD.prw")
	aAdd( aFontes, "LJCRetornoPayHub.prw")
	aAdd( aFontes, "RotinasGerenciais.prw")
	aAdd( aFontes, "Telaterminal.PRW")
	aAdd( aFontes, "PaymentHub.PRW")
	aAdd( aFontes, "LOJA1906.PRW")
	aAdd( aFontes, "LOJA1906A.PRW")
	aAdd( aFontes, "loja1934.prw")
	aAdd( aFontes, "STWInfoCNPJ.PRW")
	aAdd( aFontes, "STWCancelSale.PRW")
	aAdd( aFontes, "STIInfoCNPJ.prw")
	aAdd( aFontes, "STIPayment.PRW")
	aAdd( aFontes, "STBTEF.prw")
	aAdd( aFontes, "loja075.prw")
	aAdd( aFontes, "STWPayCard.prw")
	aAdd( aFontes, "STDCancelSale.prw")
	aAdd( aFontes, "STBPayCard.prw")
	aAdd( aFontes, "STWChkTef.prw")
	aAdd( aFontes, "LOJA121.PRW")
	aAdd( aFontes, "LOJA140.PRX")
	aAdd( aFontes, "LOJA701B.PRW")
	aAdd( aFontes, "LOJA701C.PRW")
	aAdd( aFontes, "LOJXFUNB.PRX")
	aAdd( aFontes, "LOJXFUNC.PRW")
	aAdd( aFontes, "LOJXFUNK.PRW")
	aAdd( aFontes, "LOJXPED.PRW")
	aAdd( aFontes, "LOJXTEF.PRW")
	aAdd( aFontes, "LOJXPAGDIG.PRW")
	
	//Verifica a data dos fontes no RPO
	For nCount := 1 To Len(aFontes)
		aInfoFonte := GetAPOInfo(aFontes[nCount])
		If Empty(aInfoFonte)
			cMsg := "Fonte " + aFontes[nCount] + " n�o encontrado no RPO."
		ElseIf aInfoFonte[4] < dDataRef
			cMsg := "Fonte " + aFontes[nCount] + " com data " + dtoc(aInfoFonte[4]) + ", inferior a " + dtoc(dDataRef)
		EndIf

		If !Empty(cMsg)
			LJGrvLog("TOTVS_PAGAMENTO_DIGITAL", cMsg)
			lOK := .F.
			Exit
		EndIf
	Next nCount

	If lOK
		//Campos a serem verificados se existem no ambiente

		aAdd( aCampos, "MDG_PHCOMP"	)
		aAdd( aCampos, "MDG_PHTENA"	)
		aAdd( aCampos, "MDG_PHUSER"	)
		aAdd( aCampos, "MDG_PHPSWD"	)
		aAdd( aCampos, "MDG_PHCLID"	)
		aAdd( aCampos, "MDG_PHCLSR"	)
		aAdd( aCampos, "MDG_PHPAGD"	)
		aAdd( aCampos, "L1_VLRPGDG"	)
		aAdd( aCampos, "L4_TRNID"	)
		aAdd( aCampos, "L4_TRNPCID"	)
		aAdd( aCampos, "L4_TRNEXID"	)

		//Verifica se os campos existem no ambiente
		For nCount := 1 To Len(aCampos)

			cCampoTab := aCampos[nCount]
			cAliasTab := PadL( Left( cCampoTab, AT("_",cCampoTab)-1 ), 3, "S")

			If AliasInDic(cAliasTab)
				If (cAliasTab)->(Columnpos(cCampoTab)) == 0
					LJGrvLog("TOTVS_PAGAMENTO_DIGITAL", "Campo " + cCampoTab + " n�o encontrado na tabela " + cAliasTab)
					lOK := .F.
					Exit
				EndIf
			Else
				LJGrvLog("TOTVS_PAGAMENTO_DIGITAL", "Tabela " + cAliasTab + " n�o encontrada no dicionario.")
				lOK := .F.
				Exit
			EndIf
		Next nCount
	EndIf

	lUsePayHub := lOK .And. cPaisLoc == "BRA" .And. ; 	//Dispon�vel apenas para o Brasil
				 ( nModulo == 12 .Or. ; 				//Verifica se � SIGALOJA
	 				STFIsPOS() .Or. ;  					//Verifica se � Totvs PDV
					LjFTVD() 	)						//Verifica se � Venda Direta (SIGAFAT)

EndIf

LJGrvLog("TOTVS_PAGAMENTO_DIGITAL", " Fim da Verifica��o. " , lUsePayHub)

Return lUsePayHub

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPgtoDigital
Metodo para retornar o objeto com as configura��es do pagamento digital

@type       Method
@author     Bruno Almeida
@since      26/10/2020
@version    12.1.27
@param 
@return 	oPgDig, Objeto, Retorna objeto com as configura��es do pgto digital

/*/
//-------------------------------------------------------------------------------------
Method GetPgtoDigital() Class LJCConfiguradorTef 
Return Self:oPgDig

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ISPgtoDig
Verifica se o pagamento digital esta ativo

@type       Method
@author     Bruno Almeida
@since      28/10/2020
@version    12.1.27
@param 
@return 	lRet, l�gico

/*/
//-------------------------------------------------------------------------------------
Method ISPgtoDig() Class LJCConfiguradorTef

Local lRet := .F. //Variavel de retorno

If LjUsePayHub()
	lRet := Self:oCfgTef:lAtivo .AND.  Self:oCfgTef:oPaymentHub:lPagDig
EndIf

LjGrvLog("ISPgtoDig", " lRet - TPD habilitado no cadastro de esta��o?",lRet )

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ISPayHub
Verifica se o payment hub esta ativo

@type       Method
@author     Bruno Almeida
@since      28/10/2020
@version    12.1.27
@param 
@return 	lRet, l�gico

/*/
//-------------------------------------------------------------------------------------
Method ISPayHub() Class LJCConfiguradorTef
Return Self:oCfgTef:oPaymentHub:lCCCD
