#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISA012.CH"  

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � FISA012  � Autor � Ivan Haponczuk         � Data � 04.11.09 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Tipos Comprovante Governo.                      ���
��������������������������������������������������������������������������Ĵ��
���Uso       � FATURAMENTO                                                 ���
���          � LOCALIZACAO PERU                                            ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Function FISA012()

	Local nlX      := 0
	Local alCodGov := {}
	
	// Funcao de validacao de exclusao
	Private cDelFunc  := "u_ValDel()"
	
	Private cCadastro := STR0001 //"C�digos Tipo Comprovantes Pago" 
	Private aRotina   := { {STR0002 ,"AxPesqui",0,1} ,;
	                       {STR0003 ,"AxVisual",0,2} ,;
                           {STR0004 ,"AxInclui",0,3} ,;
                           {STR0005 ,"AxAltera",0,4} ,; 
                           {STR0006 ,"AxDeleta",0,5} }  
    
    //��������������������������������������������������������Ŀ
	//� Alimentacao do array com o conteudo padrao da tabela   �
	//����������������������������������������������������������  
	aAdd(alCodGov,{"00","Otros (especificar)"})
	aAdd(alCodGov,{"01","Factura"})
	aAdd(alCodGov,{"02","Recibo por Honorarios"})
	aAdd(alCodGov,{"03","Boleta de Venta"})
	aAdd(alCodGov,{"04","Liquidaci�n de compra"})
	aAdd(alCodGov,{"05","Boleto de compa��a de aviaci�n comercial por el servicio de transporte a�reo de pasajeros"})
	aAdd(alCodGov,{"06","Carta de porte a�reo por el servicio de transporte de carga a�rea"})
	aAdd(alCodGov,{"07","Nota de cr�dito"})
	aAdd(alCodGov,{"08","Nota de d�bito"})
	aAdd(alCodGov,{"09","Gu�a de remisi�n - Remitente"})
	aAdd(alCodGov,{"10","Recibo por Arrendamiento"})
	aAdd(alCodGov,{"11","P�liza emitida por las Bolsas de Valores, Bolsas de Productos o Agentes de Intermediaci�n por operaciones realizadas en las Bolsas de Valores o Productos o fuera de las mismas, autorizadas por CONASEV"})
	aAdd(alCodGov,{"12","Ticket o cinta emitido por m�quina registradora"})
	aAdd(alCodGov,{"13","Documento emitido por bancos, instituciones financieras, crediticias y de seguros que se encuentren bajo el control de la Superintendencia de Banca y Seguros"})
	aAdd(alCodGov,{"14","Recibo por servicios p�blicos de suministro de energ�a el�ctrica, agua, tel�fono, telex y telegr�ficos y otros servicios complementarios que se incluyan en el recibo de servicio p�blico "})
	aAdd(alCodGov,{"15","Boleto emitido por las empresas de transporte p�blico urbano de pasajeros"})
	aAdd(alCodGov,{"16","Boleto de viaje emitido por las empresas de transporte p�blico interprovincial de pasajeros dentro del pa�s"})
	aAdd(alCodGov,{"17","Documento emitido por la Iglesia Cat�lica por el arrendamiento de bienes inmuebles"})
	aAdd(alCodGov,{"18","Documento emitido por las Administradoras Privadas de Fondo de Pensiones que se encuentran bajo la supervisi�n de la Superintendencia de Administradoras Privadas de Fondos de Pensiones"})
	aAdd(alCodGov,{"19","Boleto o entrada por atracciones y espect�culos p�blicos"})
	aAdd(alCodGov,{"20","Comprobante de Retenci�n"})
	aAdd(alCodGov,{"21","Conocimiento de embarque por el servicio de transporte de carga mar�tima"})
	aAdd(alCodGov,{"22","Comprobante por Operaciones No Habituales"})
	aAdd(alCodGov,{"23","P�lizas de Adjudicaci�n emitidas con ocasi�n del remate o adjudicaci�n de bienes por venta forzada, por los martilleros o las entidades que rematen o subasten bienes por cuenta de terceros"})
	aAdd(alCodGov,{"24","Certificado de pago de regal�as emitidas por PERUPETRO S.A"})
	aAdd(alCodGov,{"25","Documento de Atribuci�n (Ley del Impuesto General a las Ventas e Impuesto Selectivo al Consumo, Art. 19�, �ltimo p�rrafo, R.S. N� 022-98-SUNAT)."})
	aAdd(alCodGov,{"26","Recibo por el Pago de la Tarifa por Uso de Agua Superficial con fines agrarios y por el pago de la Cuota para la ejecuci�n de una determinada obra o actividad acordada por la Asamblea General de la Comisi�n de Regantes o Resoluci�n expedida por el Jefe de la Unidad de Aguas y de Riego (Decreto Supremo N� 003-90-AG, Arts. 28 y 48)"})
	aAdd(alCodGov,{"27","Seguro Complementario de Trabajo de Riesgo"})
	aAdd(alCodGov,{"28","Tarifa Unificada de Uso de Aeropuerto"})
	aAdd(alCodGov,{"29","Documentos emitidos por la COFOPRI en calidad de oferta de venta de terrenos, los correspondientes a las subastas p�blicas y a la retribuci�n de los servicios que presta"})
	aAdd(alCodGov,{"30","Documentos emitidos por las empresas que desempe�an el rol adquirente en los sistemas de pago mediante tarjetas de cr�dito y d�bito"})
	aAdd(alCodGov,{"31","Gu�a de Remisi�n - Transportista"})
	aAdd(alCodGov,{"32","Documentos emitidos por las empresas recaudadoras de la denominada Garant�a de Red Principal a la que hace referencia el numeral 7.6 del art�culo 7� de la Ley N� 27133 - Ley de Promoci�n del Desarrollo de la Industria del Gas Natural"})
	aAdd(alCodGov,{"34","Documento del Operador"})
	aAdd(alCodGov,{"35","Documento del Part�cipe"})
	aAdd(alCodGov,{"36","Recibo de Distribuci�n de Gas Natural"})
	aAdd(alCodGov,{"37","Documentos que emitan los concesionarios del servicio de revisiones t�cnicas vehiculares, por la prestaci�n de dicho servicio"})
	aAdd(alCodGov,{"50","Declaraci�n �nica de Aduanas - Importaci�n definitiva"})
	aAdd(alCodGov,{"52","Despacho Simplificado - Importaci�n Simplificada"})
	aAdd(alCodGov,{"53","Declaraci�n de Mensajer�a o Courier"})
	aAdd(alCodGov,{"54","Liquidaci�n de Cobranza"})
	aAdd(alCodGov,{"87","Nota de Cr�dito Especial"})
	aAdd(alCodGov,{"88","Nota de D�bito Especial"})
	aAdd(alCodGov,{"91","Comprobante de No Domiciliado"})
	aAdd(alCodGov,{"96","Exceso de cr�dito fiscal por retiro de bienes"})
	aAdd(alCodGov,{"97","Nota de Cr�dito - No Domiciliado"})
	aAdd(alCodGov,{"98","Nota de D�bito - No Domiciliado"})
	aAdd(alCodGov,{"99","Otros -Consolidado de Boletas de Venta"})
	
	dbSelectArea("CCL")
	dbSetOrder(2)  

    //������������������������������������Ŀ
	//� Alimentacao automatica da tabela   �
	//��������������������������������������  	
	For nlX:=1 To Len(alCodGov)
		If !dbSeek(xFilial()+alCodGov[nlX,1])
			If Reclock("CCL",.T.)
				CCL->CCL_FILIAL := xFilial("CCL")
				CCL->CCL_CODIGO := GETSX8NUM("CCL","CCL_CODIGO")
				CCL->CCL_CODGOV := alCodGov[nlX,1]
				CCL->CCL_DESCRI := alCodGov[nlX,2]
				MsUnlock()
			EndIf
			ConfirmSX8()         
		EndIf
	Next nlX

	dbSetOrder(1)
	CCL->(dbGoTop())
    
	mBrowse(6,1,22,75,"CCL")

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ValDel   �Autor  � Ivan Haponczuk     � Data �  05.11.09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para validar a exclus�o de um registro.             ���
�������������������������������������������������������������������������͹��
���Uso       � FISA012                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 

User Function ValDel()

	Local llRet := .F.
          
	dbSelectArea("CCM")
	dbSetOrder(2)
	
	If dbSeek(xFilial()+CCL->CCL_CODIGO)
		Aviso(STR0007,STR0008,{STR0009}) //"ATENCAO"###"Este registro n�o pode ser exlclu�do pois existe um registro dele na tabela de Amarra��es tipos comprovante."###"OK"
		llRet := .F. 
	Else 
		llRet := .T.
	EndIf

Return llRet