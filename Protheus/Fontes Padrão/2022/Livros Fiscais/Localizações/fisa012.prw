#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISA012.CH"  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FISA012  ³ Autor ³ Ivan Haponczuk         ³ Data ³ 04.11.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Tipos Comprovante Governo.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FATURAMENTO                                                 ³±±
±±³          ³ LOCALIZACAO PERU                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FISA012()

	Local nlX      := 0
	Local alCodGov := {}
	
	// Funcao de validacao de exclusao
	Private cDelFunc  := "u_ValDel()"
	
	Private cCadastro := STR0001 //"Códigos Tipo Comprovantes Pago" 
	Private aRotina   := { {STR0002 ,"AxPesqui",0,1} ,;
	                       {STR0003 ,"AxVisual",0,2} ,;
                           {STR0004 ,"AxInclui",0,3} ,;
                           {STR0005 ,"AxAltera",0,4} ,; 
                           {STR0006 ,"AxDeleta",0,5} }  
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alimentacao do array com o conteudo padrao da tabela   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	aAdd(alCodGov,{"00","Otros (especificar)"})
	aAdd(alCodGov,{"01","Factura"})
	aAdd(alCodGov,{"02","Recibo por Honorarios"})
	aAdd(alCodGov,{"03","Boleta de Venta"})
	aAdd(alCodGov,{"04","Liquidación de compra"})
	aAdd(alCodGov,{"05","Boleto de compañía de aviación comercial por el servicio de transporte aéreo de pasajeros"})
	aAdd(alCodGov,{"06","Carta de porte aéreo por el servicio de transporte de carga aérea"})
	aAdd(alCodGov,{"07","Nota de crédito"})
	aAdd(alCodGov,{"08","Nota de débito"})
	aAdd(alCodGov,{"09","Guía de remisión - Remitente"})
	aAdd(alCodGov,{"10","Recibo por Arrendamiento"})
	aAdd(alCodGov,{"11","Póliza emitida por las Bolsas de Valores, Bolsas de Productos o Agentes de Intermediación por operaciones realizadas en las Bolsas de Valores o Productos o fuera de las mismas, autorizadas por CONASEV"})
	aAdd(alCodGov,{"12","Ticket o cinta emitido por máquina registradora"})
	aAdd(alCodGov,{"13","Documento emitido por bancos, instituciones financieras, crediticias y de seguros que se encuentren bajo el control de la Superintendencia de Banca y Seguros"})
	aAdd(alCodGov,{"14","Recibo por servicios públicos de suministro de energía eléctrica, agua, teléfono, telex y telegráficos y otros servicios complementarios que se incluyan en el recibo de servicio público "})
	aAdd(alCodGov,{"15","Boleto emitido por las empresas de transporte público urbano de pasajeros"})
	aAdd(alCodGov,{"16","Boleto de viaje emitido por las empresas de transporte público interprovincial de pasajeros dentro del país"})
	aAdd(alCodGov,{"17","Documento emitido por la Iglesia Católica por el arrendamiento de bienes inmuebles"})
	aAdd(alCodGov,{"18","Documento emitido por las Administradoras Privadas de Fondo de Pensiones que se encuentran bajo la supervisión de la Superintendencia de Administradoras Privadas de Fondos de Pensiones"})
	aAdd(alCodGov,{"19","Boleto o entrada por atracciones y espectáculos públicos"})
	aAdd(alCodGov,{"20","Comprobante de Retención"})
	aAdd(alCodGov,{"21","Conocimiento de embarque por el servicio de transporte de carga marítima"})
	aAdd(alCodGov,{"22","Comprobante por Operaciones No Habituales"})
	aAdd(alCodGov,{"23","Pólizas de Adjudicación emitidas con ocasión del remate o adjudicación de bienes por venta forzada, por los martilleros o las entidades que rematen o subasten bienes por cuenta de terceros"})
	aAdd(alCodGov,{"24","Certificado de pago de regalías emitidas por PERUPETRO S.A"})
	aAdd(alCodGov,{"25","Documento de Atribución (Ley del Impuesto General a las Ventas e Impuesto Selectivo al Consumo, Art. 19º, último párrafo, R.S. N° 022-98-SUNAT)."})
	aAdd(alCodGov,{"26","Recibo por el Pago de la Tarifa por Uso de Agua Superficial con fines agrarios y por el pago de la Cuota para la ejecución de una determinada obra o actividad acordada por la Asamblea General de la Comisión de Regantes o Resolución expedida por el Jefe de la Unidad de Aguas y de Riego (Decreto Supremo N° 003-90-AG, Arts. 28 y 48)"})
	aAdd(alCodGov,{"27","Seguro Complementario de Trabajo de Riesgo"})
	aAdd(alCodGov,{"28","Tarifa Unificada de Uso de Aeropuerto"})
	aAdd(alCodGov,{"29","Documentos emitidos por la COFOPRI en calidad de oferta de venta de terrenos, los correspondientes a las subastas públicas y a la retribución de los servicios que presta"})
	aAdd(alCodGov,{"30","Documentos emitidos por las empresas que desempeñan el rol adquirente en los sistemas de pago mediante tarjetas de crédito y débito"})
	aAdd(alCodGov,{"31","Guía de Remisión - Transportista"})
	aAdd(alCodGov,{"32","Documentos emitidos por las empresas recaudadoras de la denominada Garantía de Red Principal a la que hace referencia el numeral 7.6 del artículo 7° de la Ley N° 27133 - Ley de Promoción del Desarrollo de la Industria del Gas Natural"})
	aAdd(alCodGov,{"34","Documento del Operador"})
	aAdd(alCodGov,{"35","Documento del Partícipe"})
	aAdd(alCodGov,{"36","Recibo de Distribución de Gas Natural"})
	aAdd(alCodGov,{"37","Documentos que emitan los concesionarios del servicio de revisiones técnicas vehiculares, por la prestación de dicho servicio"})
	aAdd(alCodGov,{"50","Declaración Única de Aduanas - Importación definitiva"})
	aAdd(alCodGov,{"52","Despacho Simplificado - Importación Simplificada"})
	aAdd(alCodGov,{"53","Declaración de Mensajería o Courier"})
	aAdd(alCodGov,{"54","Liquidación de Cobranza"})
	aAdd(alCodGov,{"87","Nota de Crédito Especial"})
	aAdd(alCodGov,{"88","Nota de Débito Especial"})
	aAdd(alCodGov,{"91","Comprobante de No Domiciliado"})
	aAdd(alCodGov,{"96","Exceso de crédito fiscal por retiro de bienes"})
	aAdd(alCodGov,{"97","Nota de Crédito - No Domiciliado"})
	aAdd(alCodGov,{"98","Nota de Débito - No Domiciliado"})
	aAdd(alCodGov,{"99","Otros -Consolidado de Boletas de Venta"})
	
	dbSelectArea("CCL")
	dbSetOrder(2)  

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alimentacao automatica da tabela   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  	
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ValDel   ºAutor  ³ Ivan Haponczuk     º Data ³  05.11.09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para validar a exclusão de um registro.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FISA012                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

User Function ValDel()

	Local llRet := .F.
          
	dbSelectArea("CCM")
	dbSetOrder(2)
	
	If dbSeek(xFilial()+CCL->CCL_CODIGO)
		Aviso(STR0007,STR0008,{STR0009}) //"ATENCAO"###"Este registro não pode ser exlcluído pois existe um registro dele na tabela de Amarrações tipos comprovante."###"OK"
		llRet := .F. 
	Else 
		llRet := .T.
	EndIf

Return llRet