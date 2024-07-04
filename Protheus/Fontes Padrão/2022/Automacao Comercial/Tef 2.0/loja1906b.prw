#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFTEF.CH"

Function LOJA1906B ; Return        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJCCfgTefSitef    �Autor  �VENDAS CRM  � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Carrega as configuracoes de SiTef disponiveis para aplicacao��� 
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/
Class LJCCfgTefSitef

	Data cIpAddress
	Data cTerminal
	Data cEmpresa   
	Data lCCCD
	Data lCheque
	Data lRC
	Data lCB
	Data cCB
	Data lPBM
	Data lEpharma
	Data lTrnCentre
	Data lInfAdm
	Data oPbms
	Data lCieloPrem		// Utiliza Cielo Premia
	
	Method New()
	Method Carregar()
	Method Salvar()

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
Method New() Class LJCCfgTefSitef

	Self:cIpAddress := Space(200)
	Self:cTerminal 	:= Space(200)
	Self:cEmpresa	:= Space(200)
	Self:lCCCD		:= .F.
	Self:lCheque	:= .F.
	Self:lRC		:= .F.
	Self:lCB		:= .F.
	Self:cCB		:= Space(200)
	Self:lPBM		:= .F.
	Self:lEpharma	:= .F.
	Self:lTrnCentre	:= .F.
	Self:oPbms		:= LJCList():New() 
	Self:lInfAdm	:= .F.
	Self:lCieloPrem	:= .F.

Return Self       

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
Method Carregar(cAlias) Class LJCCfgTefSitef

	Local lRet := .F.

	If Select(cAlias) > 0
		Self:cIpAddress := (cAlias)->MDG_IPSIT
		Self:cTerminal 	:= (cAlias)->MDG_TERSIT
		Self:cEmpresa	:= (cAlias)->MDG_EMPSIT
		Self:lCCCD		:= IIf((cAlias)->MDG_CARSIT=="1",.T.,.F.)
		Self:lCheque	:= IIf((cAlias)->MDG_CHQSIT=="1",.T.,.F.)
		Self:lRC		:= IIf((cAlias)->MDG_RCSIT=="1",.T.,.F.)
		Self:lCB		:= IIf((cAlias)->MDG_CBSIT=="1",.T.,.F.)
		Self:cCB		:= (cAlias)->MDG_TPCBSI
		Self:lPBM		:= IIf((cAlias)->MDG_PBMSIT=="1",.T.,.F.)
		Self:lEpharma	:= IIf((cAlias)->MDG_EPHARM=="1",.T.,.F.)
		Self:lTrnCentre	:= IIf((cAlias)->MDG_TRNCEN=="1",.T.,.F.)
		If FieldPos("MDG_CIELOP") > 0
			Self:lCieloPrem	:= IIf((cAlias)->MDG_CIELOP=="1",.T.,.F.)
		EndIf
		
		If Self:lPBM
			If Self:lEpharma
				Self:oPbms:Add(_EPHARMA)
			EndIf
			
			If Self:lTrnCentre
				Self:oPbms:Add(_TRNCENTRE)
			EndIf
		EndIf

		lRet := .T.

	EndIf

Return lRet   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Salvar       �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Salva as configuracoes de TEF disponiveis.                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Salvar(cAlias) Class LJCCfgTefSitef
	
	Local lRet := .F.

	If Select(cAlias) > 0
		REPLACE (cAlias)->MDG_IPSIT 	WITH Self:cIpAddress
		REPLACE (cAlias)->MDG_TERSIT 	WITH Self:cTerminal
		REPLACE (cAlias)->MDG_EMPSIT 	WITH Self:cEmpresa
		REPLACE (cAlias)->MDG_CARSIT  	WITH IIf(Self:lCCCD,"1","2")
		REPLACE (cAlias)->MDG_CHQSIT 	WITH IIf(Self:lCheque,"1","2")	
		REPLACE (cAlias)->MDG_RCSIT   	WITH IIf(Self:lRC,"1","2")	
		REPLACE (cAlias)->MDG_CBSIT		WITH IIf(Self:lCB,"1","2")	
		REPLACE (cAlias)->MDG_TPCBSI	WITH Self:cCB
		REPLACE (cAlias)->MDG_PBMSIT	WITH IIf(Self:lPBM,"1","2")
		REPLACE (cAlias)->MDG_EPHARM	WITH IIf(Self:lEpharma,"1","2")		
		REPLACE (cAlias)->MDG_TRNCEN	WITH IIf(Self:lTrnCentre,"1","2")
		If FieldPos("MDG_CIELOP") > 0
			REPLACE (cAlias)->MDG_CIELOP 	WITH IIf(Self:lCieloPrem,"1","2")
		EndIf	
		lRet := .T.
	EndIf

Return lRet
