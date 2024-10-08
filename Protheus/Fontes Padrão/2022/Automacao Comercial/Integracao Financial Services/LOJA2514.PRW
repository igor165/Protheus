#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �LJWValConf�Autor  �Vendas Clientes     � Data �  02/04/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Gera configuracoes da integracao 							  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �											   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LJWValConf()

	Local oLJCFinSer	 			:= Nil     //Classe LJCFinSer


    //Cria Objeto de Configura��o do Financial
    oLJCFinSer := LJCFinSer():New()
	   
  
	oLJCCargaIntegracaoForm := LJCCargaIntegracaoForm():New()
	oLJCCargaIntegracaoForm:lLoadData := .F. //Nao exibe o painel de carga
	
	// Adiciona a integra��o da criterium na wizard de carga inicial
	oLJCCargaIntegracaoForm:AddIntegration( oLJCFinSer )


	oLJCCargaIntegracaoForm:Show()

	//Destrutor(oLJCBestSales) //copiar esta classe 
	Destrutor(oLJCFinSer, .T.)


Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �Destrutor �Autor  �Vendas Clientes     � Data �  27/05/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Destroi o objeto criado liberando recurso de memoria		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �											   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Destrutor(oObj, lClean)
    
	Default lClean := .F.

	If oObj <> Nil
		//Libera o objeto
		FreeObj(oObj)
		//Inicializa o objeto
		oObj := Nil
		
		If lClean
			//Libera recurso de memoria
			//Obs: este comando so precisa ser executado uma unica vez apos a execucao do processo
			DelClassIntf()
		EndIf
	EndIf

Return Nil
