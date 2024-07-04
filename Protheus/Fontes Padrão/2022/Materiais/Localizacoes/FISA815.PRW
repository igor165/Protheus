#include "Protheus.ch"
#include "topconn.ch"
#include "FISA815.ch"
#include "XMLXFUN.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FONT.CH"
#Include "RPTDEF.CH"

#DEFINE _FILIAL  01
#DEFINE _RECIBO  02
#DEFINE _NUMERO  03
#DEFINE _FREFIXO 04
#DEFINE _PARCELA 05
#DEFINE _TIPO    06
#DEFINE _TIPODOC 07
#DEFINE _EMISSAO 08
#DEFINE _CLIENTE 09
#DEFINE _LOJA    10
#DEFINE _MOEDA   11
#DEFINE _VALOR   12
#DEFINE _MOEDAS  13
#DEFINE _BANCO   17
#DEFINE _AGENCIA 18
#DEFINE _CONTA   19
#DEFINE _BCOCHQ  20
#DEFINE _AGECHQ  21
#DEFINE _CTACHQ  22
#DEFINE _HRAPAGO 33

 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FISA815   ºAutor  ³Raul Ortiz Medina   º Data ³  18/05/17     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Complemento de Recepción de Pagos, generación del xml        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIN                                                      º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS     ³  Motivo da Alteracao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Roberto Glez³30/08/17³DMICNS-60 ³Se aniade funcionalidad para timbrado e ³±±
±±³            ³        ³          ³impresion de comprobante.               ³±±
±±³Roberto Glez³17/10/17³DMICNS-483³Se aniade addTimbre para cuando el pac  ³±±
±±³            ³        ³          ³regresa solamente el timbre.            ³±±
±±³LuisEnriquez³27/10/17³DMINA-890 ³Se modifica función GetInfo para conca- ³±±
±±³            ³        ³          ³tenar la serie para sea tomada en cuenta³±±
±±³            ³        ³          ³en obtención de UUID. (MEX)             ³±±
±±³  Marco A.  ³14/11/17³DMINA-908 ³Replica de DMINA-602/V11.8 y DMINA-814/ ³±±
±±³            ³        ³          ³V12.1.07, que aseguran el correcto fun- ³±±
±±³            ³        ³          ³cionamiento de la generacion de Cobros  ³±±
±±³            ³        ³          ³Diversos. (MEX)                         ³±±
±±³Alf. Medrano³15/11/17³DMINA-390 ³Se valida cuando la fuc. FISA815 se lla-³±±
±±³            ³        ³          ³desde la rutina FINA088 para asignar los³±±
±±³            ³        ³          ³docts Timbrados y no Timbrados a aRegTim³±±
±±³  Marco A.  ³19/02/18³DMINA-556 ³Se replican para V12.1.17, los issues:  ³±±
±±³            ³        ³          ³ DMINA-385, DMINA-602,  DMINA-723,      ³±±
±±³            ³        ³          ³ DMINA-814, DMINA-1171, DMINA-1223,     ³±±
±±³            ³        ³          ³ DMINA-1255, DMINA-1166 y DMINA-1093;   ³±±
±±³            ³        ³          ³ para Complemento de Pago - CFDI 3.3    ³±±
±±³Diego Rivera³05/06/18³DMINA-2202³Replica DMINA-1557: Se MODIFICA funcion ³±±
±±³            ³        ³          ³FISA815(), para que reciba parámetro    ³±±
±±³            ³        ³          ³nOpc para cuando es detonada desde otra ³±±
±±³            ³        ³          ³rutina, se pueda indicar si 0= Timbrado ³±±
±±³            ³        ³          ³1= Impresión de PDF.                    ³±±
±±³M.Camargo   ³06/04/18³DMINA-3465³En func CreaXML se asignan valores Tags ³±±
±±³            ³        ³          ³para CEP. RfcEmisorCtaOrd, CtaOrdenante,³±±
±±³            ³        ³          ³TipoCadPago,CadPago,CertPago y SelloPago³±±
±±³            ³        ³          ³En Func DistSal se obtiene el Valor de  ³±±
±±³            ³        ³          ³campos EL_RFCEMI, EL_CTAORD, EL_FORPGO, ³±±
±±³            ³        ³          ³EL_CEPTIP,EL_CEPCER,EL_CEPCAD, EL_CEPSEL³±±
±±³            ³        ³          ³Se agrega el uso del parametro MV_HRAREC³±±
±±³            ³        ³          ³en la funcion CreaXML() para definir la ³±±
±±³            ³        ³          ³hora del atributo FechaPago.            ³±±
±±³Oscar Garcia³06/07/18³DMINA-3510³Se modifica función CreaXML para que en ³±±
±±³            ³        ³          ³base al campo informado en el parámetro ³±±
±±³            ³        ³          ³MV_CFDICP sea tomado el valor para el   ³±±
±±³            ³        ³          ³atributo LugarExpedición.(MEX)DMINA-3220³±±
±±³Oscar Garcia³16/08/18³DMINA-3811³En Fun. CreaXML() y AddNodo() se realiza³±±
±±³            ³        ³          ³el reemplazo de "|" por "&#124;" para   ³±±
±±³            ³        ³          ³Cad. Pago con la función CodHTML().     ³±±
±±³Oscar Garcia³28/08/18³DMINA-3765³Se añade Func. FIS815PatCta() para vali-³±±
±±³            ³        ³          ³dar que los campo EL_CTAORD y EL_CTABEN ³±±
±±³            ³        ³          ³cumplan con la estructura indicada en el³±±
±±³            ³        ³          ³catalogo de Formas de Pago.             ³±±
±±³Oscar Garcia³03/09/18³DMINA-3912³Se modifica la impresion de XML para que³±±
±±³            ³        ³          ³RFC de Cta. Ordenante/Beneficiario sea  ³±±
±±³            ³        ³          ³opcinal, se muestra la descripcion de la³±±
±±³            ³        ³          ³Forma de Pago.                          ³±±
±±³  Marco A.  ³07/09/18³DMINA-3961³En func CreaXML se elimina Validación   ³±±
±±³            ³        ³          ³para EL_TIPODOC y se asignan las Formas ³±±
±±³            ³        ³          ³Pago Bancarizadas. Se modifica GetBanco ³±±
±±³            ³        ³          ³para obtener RFC, Cuenta y Nom Banco    ³±±
±±³            ³        ³          ³cuando es Extranjero. En Func DistSal se³±±
±±³            ³        ³          ³se quita condicion de EL_TIPODOC para la³±±
±±³            ³        ³          ³generación del Pago y Docto Relacionado ³±±
±±³Alf. Medrano³20/09/18³DMINA-4273³Fun CreaXML al asignar array aAuxNodo   ³±±
±±³            ³        ³          ³los elementos “Emisor” y “Receptor” en  ³±±
±±³            ³        ³          ³RFC se asigna el valor Booleano .T. en  ³±±
±±³            ³        ³          ³la última posición que indica que debe  ³±±
±±³            ³        ³          ³acceder al tratamiento de caracteres en ³±±
±±³            ³        ³          ³fun CodHTML. Se crea fun fRmpCarac que  ³±±
±±³            ³        ³          ³reemplaza los caracteres especiales por ³±±
±±³            ³        ³          ³carácter simple dentro de PDF.          ³±±
±±³Oscar Garcia³21/09/18³DMINA-3950³Se modifica func FISA815 para no solici-³±±
±±³            ³        ³          ³tar confirmacion al imprimir complemento³±±
±±³            ³        ³          ³si parametro MV_CFDREC == 1             ³±±
±±³Oscar Garcia³27/09/18³DMINA-4214³Replica DMINA-4160                      ³±±
±±³            ³        ³          ³En la Fun CreaXML se obtiene el RFC y   ³±±
±±³            ³        ³          ³cuenta Beneficiario solo para formas de ³±±
±±³            ³        ³          ³pago bancarizadas.Se crea fun fGetFilOri³±±
±±³            ³        ³          ³para obtener la Fil Origen del Documento³±±
±±³            ³        ³          ³y posteriormente el UUID correcto.      ³±±
±±³            ³        ³          ³Dentro del Func DistSal se agrega la fun³±±
±±³            ³        ³          ³fGetFilOri que obtiene la Filial Origen ³±±
±±³            ³        ³          ³de los doctos seleccionados para consul-³±±
±±³            ³        ³          ³tar las tablas SF1(NCC) y SF2 (NF,NDC)  ³±±
±±³            ³        ³          ³Se crea la fun fObtFilSE4 que obtiene la³±±
±±³            ³        ³          ³condicion Pago respetando la Filial uti-³±±
±±³            ³        ³          ³lizada en el registro del Docuemento    ³±±
±±³  Marco A.  ³01/10/18³DMINA-4322³Se replica a V12.1.17, la solucion rea- ³±±
±±³            ³        ³          ³lizada en DMINA-4354 de V11.8. (MEX)    ³±±
±±³Oscar Garcia³09/10/18³DMINA-4351³-Se actualiza func. GetSaldo() para que ³±±
±±³            ³        ³          ³tome saldo correcto del documento.      ³±±
±±³            ³        ³          ³-En Fun. DistSal() se obtiene la tasa de³±±
±±³            ³        ³          ³Doc. Relacionado p/atributo TipoCambioDR³±±
±±³            ³        ³          ³-Se realiza replica de DMINA-4174       ³±±
±±³LuisEnriquez³23/10/18³DMINA-4615³Se modifican funciones DistSal y GetInfo³±±
±±³            ³        ³          ³para tomar en cuenta documentos de tipo ³±±
±±³            ³        ³          ³por PE A087TIPTI para baja de titulos   ³±±
±±³            ³        ³          ³creados de SIGALOJA. (MEX)              ³±±
±±³Oscar Garcia³23/10/18³DMINA-4660³-En atributo TipoCambioDR se registra el³±±
±±³            ³        ³          ³ # de unidades de la moneda señalada en ³±±
±±³            ³        ³          ³ doc. rel. que equivale a una unidad de ³±±
±±³            ³        ³          ³ la moneda de pago. (MEX)               ³±±
±±³Oscar Garcia³05/11/18³DMINA-4487³Se mueven namespace e instancias que son³±±
±±³            ³        ³          ³genrados a nivel complento en lugar de  ³±±
±±³            ³        ³          ³ser a nivel comprobante Fun CreaXML(MEX)³±±
±±³Oscar Garcia³07/11/18³DMINA-4461³Se agrega funcionalidad para la correcta³±±
±±³            ³        ³          ³impresion del Codigo QR, cuando se rea- ³±±
±±³            ³        ³          ³liza la impresion del PDF correspondien-³±±
±±³            ³        ³          ³te a un Cobro Diverso.                  ³±±
±±³LuisEnriquez³08/11/18³DMINA-5004³Se agrega función F815OriSE1 para que   ³±±
±±³            ³        ³          ³en función DistSal se de funcionalidad a³±±
±±³            ³        ³          ³docs generados desde SIGALOJA. (MEX)    ³±±
±±³ARodriguez  ³14/11/18³DMINA-4694³En la fun GetSaldo se obtiene el Saldo  ³±±
±±³            ³        ³Rep  -4136³sumando los cobros(SEL) de documentos   ³±±
±±³            ³        ³          ³timbrados y restando el Valor bruto del ³±±
±±³            ³        ³          ³docto. generando de forma correcta tags ³±±
±±³            ³        ³          ³ImpSaldoAnt,ImpPagado e ImpSaldoInsoluto³±±
±±³            ³        ³DMINA-5185³El receptor del CFDI debe ser el cliente³±±
±±³            ³        ³          ³del encabezado del recibo. DistSal() y  ³±±
±±³            ³        ³          ³CreaXML()                               ³±±
±±³Oscar Garcia³21/11/18³DMINA-5058³Para atributo TipoCambioP, se informa la³±±
±±³            ³        ³          ³tasa del recibo segun la moneda indicada³±±
±±³            ³        ³          ³en atributo MonedaP, cuando MonedaP es  ³±±
±±³            ³        ³          ³diferente de MXN.                       ³±±
±±³ARodriguez  ³22/11/18³DMINA-4711³fUpdSEL() proceso por Serie+Recibo para ³±±
±±³            ³        ³          ³actualizar todos los doctos si cliente  ³±±
±±³            ³        ³          ³encabezado es diferente al de documentos³±±
±±³            ³        ³          ³Homologación con v11.8, queda pendiente:³±±
±±³            ³        ³          ³- Comentarios fuente                    ³±±
±±³            ³        ³          ³- Parámetros para timbrado              ³±±
±±³LuisEnríquez³27/11/18³DMINA-4711³Se agrega impresión de encabezado en la ³±±
±±³            ³        ³          ³función NewPage y  se realiza conversión³±±
±±³            ³        ³          ³de imp. pagado p/ dif. monedas.   (MEX) ³±±
±±³LuisEnríquez³03/12/18³DMINA-4830³Se agrega funcionalidad para generación ³±±
±±³            ³        ³          ³de nodo CfdiRelacionados (MEX)          ³±±
±±³M.Camargo   ³06/12/18³DMINA-5205³Se habilitan las formas de pago bancari-³±±
±±³            ³        ³          ³zadas para obtencion de banco extranjero³±±
±±³M.Camargo   ³07/12/18³DMINA-5205³Se agrega condición EL_CANCEL en funcion³±±
±±³            ³        ³          ³getSaldo para que no considere saldos   ³±±
±±³            ³        ³          ³de recibos cancelados.                  ³±±
±±³ARodriguez  ³10/12/18³DMINA-4838³Cambia Id de cancelación de "C" a "S"   ³±±
±±³            ³        ³          ³para WS de nuevo esquema de cancel. CFDI³±±
±±³Alf. Medrano³19/12/18³DMINA-5589³fun fLanca asigna descrip Régimen fiscal³±±
±±³            ³        ³          ³versión y Num. Cert. Emisor. Se crea fun³±±
±±³            ³        ³          ³F815LinCar y se aplica a Forma pago para³±±
±±³            ³        ³          ³recorta y dividir en líneas la descrip. ³±±
±±³Alf. Medrano³27/12/18³DMINA-1644³fun F815LinCar asignan dos parámetros:  ³±±
±±³            ³        ³          ³Fuente texto y número lineas(referencia)³±±
±±³Oscar G.    ³04/01/19³DMINA-5606³Se define variable _MOEDAS              ³±±
±±³Oscar G.    ³23/04/19³DMINA-6362³Se realiza ajuste de centavos a atributo³±±
±±³            ³        ³          ³TipoCambioDR en Func. AddNodo(). (MEX)  ³±±
±±³Alf. Medrano³09/05/19³DMINA-6613³En fun AjustSal se obtiene el num de    ³±±
±±³            ³        ³          ³decimal de los campos moneda de SEL para³±±
±±³            ³        ³          ³para especificar los decimales en el    ³±±
±±³            ³        ³          ³redondeo del valor ImpPagado.           ³±±
±±³ARodriguez  ³14/05/19³DMINA-6586³DistSal() Genera nodo adicional de cobro³±±
±±³            ³        ³          ³por valor de compensación entre carteras³±±
±±³            ³        ³          ³=> pago mediante factoraje financiero.  ³±±
±±³Oscar G.    ³22/05/19³DMINA-6609³Se crean los PE FIS815LOG y FIS815PRG   ³±±
±±³            ³        ³          ³para omitir mensajes al generar/timbrar ³±±
±±³            ³        ³          ³Recibos de Cobro.                       ³±±
±±³Veronica F. ³29/05/19³DMINA-6726³Se realiza modificacion en el cálculo   ³±±
±±³            ³        ³          ³de conversión en la funcion AjustSal    ³±±
±±³Veronica F. ³31/05/19³DMINA-6726³Se realizan ajuste de centavos en el    ³±±
±±³            ³        ³          ³saldo en la funcion AjustSal            ³±±
±±³  Marco A.  ³06/06/19³TSMI01-139³Se realiza actualizacion de la funcion  ³±±
±±³            ³        ³          ³GetSaldo, para obtener el saldo de todos³±±
±±³            ³        ³          ³los cobros realizados a un documento en ³±±
±±³            ³        ³          ³diferentes filiales.                    ³±±
±±³LuisEnríquez³18/06/19³DMINA-6840³Se modifica funcion getsaldo() para to- ³±±
±±³            ³        ³          ³mar en cuenta los movimientos de compen-³±±
±±³            ³        ³          ³saciones. (MEX)                         ³±±
±±³Oscar G.    ³09/07/19³DMINA-6961³Actualización en tablas CT2 y CTK cuando³±±
±±³            ³        ³          ³el timbrado es correcto. MEX            ³±±
±±³Alf. Medrano³08/08/19³DMINA-7210³En fun. GetSaldo se agrega validación   ³±±
±±³            ³        ³          ³para que solo se calculen los saldos    ³±±
±±³            ³        ³          ³pertenecientes a las sucursales relacio-³±±
±±³            ³        ³          ³-nadas al grupo de empresas relacionada ³±±
±±³            ³        ³          ³a la secion activa. En la func ImpPDF se³±±
±±³            ³        ³          ³actualiza la forma de generar PDF, se   ³±±
±±³            ³        ³          ³crea de forma local para después pasarlo³±±
±±³            ³        ³          ³al servidor                             ³±±
±±³  Marco A.  ³02/09/19³DMINA-7245³En funcion LeeXMLOut() se agrega vali-  ³±±
±±³            ³        ³          ³dacion para procesar la respuesta de    ³±±
±±³            ³        ³          ³error, cuando se utiliza el pac tralix. ³±±
±±³Veronica Flo³25/10/19³DMINA-7526³En funcion FISA815()se agrega validacion³±±
±±³            ³        ³          ³en caso de que mande error al timbrar no³±±
±±³            ³        ³          ³realiza la impresion del PDF            ³±±
±±³Eduardo P.  ³18/12/19³DMINA-7857³En funcion CreaXML()se agrega validacion³±±
±±³            ³        ³          ³para usar Punto de entrada F087ANUMOP   ³±±
±±³  Marco A.  ³03/01/20³DMINA-7751³Se agrega tratamiento para ejecucion de ³±±
±±³            ³        ³          ³PAC en SmartCliente Web. Tambien se     ³±±
±±³            ³        ³          ³se agregan descuentos, multas o intere- ³±±
±±³            ³        ³          ³ses a los nos de Saldos en el XML. (MEX)³±±
±±³Veronica Flo³08/01/20³DMINA-7872³Se modifica función FA815Comp en las    ³±±
±±³            ³        ³          ³compensaciones en el XML y la función   ³±±
±±³            ³        ³          ³fLanca para la correcta impresión del   ³±±
±±³            ³        ³          ³PDF. (MEX)                              ³±±
±±³Eduardo P.  ³22/01/20³DMINA-8126³En funcion CreaXML()se modifica el punto³±±
±±³            ³        ³          ³de entrada F087ANUMOP recibe parametros ³±±
±±³Eduardo P.  ³31/01/20³DMINA-8287³En funcion AddNodo()se agrega una valida³±±
±±³            ³        ³          ³cion para el tratamiento de atributo    ³±±
±±³            ³        ³          ³TipoCambioDR con atributo MV_CFDI_AJ    ³±±
±±³Diego Rivera³12/03/20³DMINA-8350³Se ajusta función LeeXMLOut para cuando ³±±
±±³            ³        ³          ³exista error al intentar timbrar el XML.³±±
±±³LuisEnríquez³27/03/20³DMINA-8115³Se modifican funcion CreaXML y DistSal  ³±±
±±³            ³        ³          ³para acumular en nodo pago10:Pago p/form³±±
±±³            ³        ³          ³de pago 17 las compensaciones entre car-³±±
±±³            ³        ³          ³teras (MEX)                             ³±±
±±³LuisEnríquez³14/04/20³DMINA-8479³Se modifica función getSaldo para tomar ³±±
±±³            ³        ³          ³en cuenta suc. origen del doc. de tabla ³±±
±±³            ³        ³          ³SE5 y en la funcion AjustSal se realiza ³±±
±±³            ³        ³          ³correción de conversión de importes. MEX³±±
±±³ARodriguez  ³14/05/20³DMINA-8496³Ajustes por operaciones de factoraje fin³±±
±±³            ³        ³          ³DistSal(),FA815Comp()   MEX             ³±±
±±³LuisEnríquez³08/06/20³DMINA-9241³Se realiza ajuste para que elemento Fe- ³±±
±±³            ³        ³          ³cha tome el valor de GetRmtDate, se crea³±±
±±³            ³        ³          ³funcs F815VldTim,F815GetDos y F815MsgObs³±±
±±³            ³        ³          ³para validar timbrado de recibos previos³±±
±±³            ³        ³          ³sin timbrar. (MEX)                      ³±±
±±³Marco A. Glz³23/06/20³DMINA-9365³Se realiza modificacion en la funcion   ³±±
±±³            ³        ³          ³fGetDocs, para obtener el valor por ti- ³±±
±±³            ³        ³          ³tulo y no por parcialidad. (MEX)        ³±±
±±³José Glez   ³10/08/20³DMINA-9386³Se realiza modificación en la funcion   ³±±
±±³            ³        ³          ³fUpdSEL,para Ejecutar  funcion AtuCTBFF ³±±
±±³            ³        ³          ³cuando este activa la contabilidad (MEX)³±±
±±³Vero Flores ³18/08/20³DMINA-8126³En funcion CreaXML()se modifica para que³±±
±±³            ³        ³          ³no se imprima el nodo cuando Impagado<0 ³±±
±±³ José Glez  ³05/10/20³DMINA-    ³En funcion fRodape se incrementa el     ³±±
±±³            ³        ³     10168³tamaño a 150 para el QRCode             ³±±
±±³Vero Flores ³10/11/20³DMINA-    ³En funcion CreaXML()se valida existencia³±±
±±³            ³        ³     10071³del campo EL_HRPAGO y se crea función   ³±±
±±³            ³        ³          ³FIS815ValHr()                           ³±±
±±³Oscar G.    ³18/10/20³DMINA-    ³Actuazlia FISA815() para retornar doctos³±±
±±³            ³        ³     10169³procesados a FINA088.                   ³±±
±±³Alf Medrano ³29/12/20³DMINA-    ³En fun GetSaldo se obtiene propiedad de ³±±
±±³            ³        ³     10604³tabla SE5 para verificar si la sucursal ³±±
±±³            ³        ³          ³es compartida y obtner Fil con Xfilial()³±±
±±³Marco A. Glz³05/02/21³DMINA-    ³En la funcion CreaXML, se realiza trata-³±±
±±³            ³        ³     10945³miento para determinar el sado al restar³±±
±±³            ³        ³          ³valor cobrado redondeado con el truncado³±±
±±³            ³        ³          ³Tambien se realiza la impresion del     ³±±
±±³            ³        ³          ³atributo Serie en el XML.               ³±±
±±³Marco A. Glz³24/02/21³DMINA-    ³En la funcion CreaXML, se realiza trata-³±±
±±³            ³        ³     11394³miento para determinar el atributo      ³±±
±±³            ³        ³          ³ImpSaldoInsoluto con la resta del valor ³±±
±±³            ³        ³          ³del Importe pagado al Saldo anterior.   ³±±
±±³Luis Aboytes³21/05/21³DMINA-    ³En la funcion CreaXML, se realiza trata-³±±
±±³            ³        ³     	   ³miento para determinar el atributo      ³±±
±±³            ³        ³          ³ImpSaldoInsoluto con la resta del valor ³±±
±±³            ³        ³          ³y se incorporan como parametros dos arra³±±
±±³            ³        ³          ³aResponse en donde se guardaran los men ³±±
±±³            ³        ³          ³sajes de error a mostrar en el Json del ³±±
±±³            ³        ³          ³servicio de recibos	y jData para mandar ³±±
±±³            ³        ³          ³informacion de los servicios RESt a esta³±±
±±³            ³        ³          ³funcion 								³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FISA815(cNumero, cSerie, nOpc, aDoctos, aResponse,jData,cSerSus,cRecSus)
	Local cXMLRet	:= ""
	Local cExtXML	:= ".xml"
	Local cNomXML	:= OemToAnsi(STR0009) + Alltrim(cSerie) + Alltrim(cNumero)  + ".xml"
	Local cNomTmp	:= OemToAnsi(STR0009) + Alltrim(cSerie) + Alltrim(cNumero)
	Local aPagos	:= {}
	Local aImp		:= {0,0}
	Local aAreaSEL	:= SEL->(GetArea())
	Local aRecibos	:= {}
	Local nPdf		:= 0
	Local nArchXML	:= 0
	Local lImpCDFi	:= ExistBlock("FISA815I")
	Local lImpReci	:= ExistBLock("F998IMPREC")
	Local cNomFile	:= ""
	Local cPath		:= GETMV("MV_CFDRECP")
	Local cDirLocal	:= ""
	Local cPathFile	:= ""
	Local nImpAuto	:= SuperGetMv("MV_CFDREC",.T.,0) //Generacion automatica complemneto de pago
	Local lResp		:= .T.
	Local cFunName	:= Upper(FunName())
	Local lCFDiRPag	:= .T.
	Local lPEF815Log:= ExistBlock("FIS815LOG")
	Local lPEF815Prg:= ExistBlock("FIS815PRG")
	Local lLogTim	:= .F.
	Local lLogImp	:= .F.
	Local cEmailCli := ""
	Local aFilesEnv := {}
	Local aInfoCli  := {}
	Local lEnvMail	:= .T.
	Local cMsjError := ""
	Local cMsjCli   := ""
	Local lExistXML := .T.
	Local lExistPDF := .T.
	Local limpPdf	:= .F.
	Local cUUIDSus  := ""
	Local cXMLAnul  := ""
	Local aRecCan   := {}
	Local cMotC     := "" 
	Local cMsgAnula := ""
	Local cPACDec		:= SuperGetMV("MV_PACDEC", .F., "")
	Local nDecPag       := IIf(Alltrim(cPACDec)=="S",6,2) 
	Local cCanAut  := SuperGetmv(	"MV_CANAUT"  , .F. , "" ) // Funcion de cancelacion automatica 
	
	Private lRutAuto    := isBlind() //Bandera que indica si es ejecución por automatización
	Private cXml		:= '<?xml version="1.0" encoding="UTF-8"?>' + CRLF
	Private cDir		:= &(SuperGetmv( "MV_CFDRECP" , .F. , "GetSrvProfString('startpath','')+'\cfd\recPagos\'" ))
	Private cVersion	:= ""
	Private cNodoSup	:= '<#cNomNodo# #cValNodo#>' + CRLF
	Private cNodoInf	:= '<#cNomNodo# #cValNodo#/>' + CRLF
	Private cIniNodo	:= '<#cNomNodo#>' + CRLF
	Private cFinNodo	:= '</#cNomNodo#>' + CRLF
	Private lReq		:= .T. // Atributo requerido
	Private lOpc		:= .F. // Atributo opcional
	Private lCadOrig	:= .T. // Cadena Original
	Private cNoCert		:= SuperGetMv("MV_CFDI_CS",,"")
	Private cTimeZone	:= Alltrim(SuperGetMv("MV_RETZONE",,"-06:00"))
	Private cPictVer	:= "@E 99.9"
	Private cPictNum	:= "@E 99999999999999.99"
	Private cCadOrig	:= ""
	Private cCertif		:= LeeCert()
	Private cLugarEmi	:= Alltrim(SuperGetmv( "MV_CFDI_ES" , .F. , "" ))//Lugar de Emisión
	Private lQrCode		:= GetMV("MV_CFDIQR",,.T.)
	Private cCuota		:= Alltrim(SuperGetmv( "MV_1DUP" , .F. , "" )) //Definición de cuota del titulo A=Alfanumerica 1=Numerica
	Private aPos		:= {}
	Private cTipDocPE   := ""
	Private cSerLoja    := SuperGetMV("MV_LOJANF", .F., "")
	Private cURLValCFD	:= AllTrim(SuperGetMV("MV_VERICFD", .F., "")) //Url de Verificación de Comprobantes Fiscales Digitales por Internet.
	Private nValRecibo	:= {}
	Private lVCFDi40	:= SuperGetMV("MV_CFDI40", .F., .F.) //Version CFDi 4.0
	Private nTotBase0   := 0
	Private nTotBase8   := 0
	Private nTotBase16  := 0
	Private nTotImp8    := 0
	Private nTotImp16   := 0
	Private nTotRetIVA  := 0
	Private nTotBExe    := 0

	Default nOpc		:= 	0 // 0 = Timbrar 1 = PDF
	Default aDoctos		:= 	{}
	Default	aDocuments	:= 	{}
	Default aResponse 	:= 	{} //Variable para recibos totvs (FINA998)
	Default jData		:= 	JsonObject():New()
	Default cCliente	:= 	""
	Default cSerSus     :=  ""
	Default cRecSus     :=  ""
	Default nRegC 		:= 0

	cVersion := IIf(lVCFDi40, "4.0", "3.3")
	If !lRutAuto
		cDirLocal	:= GetTempPath()
	EndIf

	IF jData['origin']=="FINA998"
		IF(ExistBLock('F998FLOTIT'))
			ExecBlock('F998FLOTIT')
		EndIF
	Else
		IF(ExistBLock('A087TIPTI'))
			ExecBlock('A087TIPTI')
		EndIF
	ENDIF

	If lPEF815Log
		lLogTim := ExecBlock("FIS815LOG",.F.,.F.,{})
	EndIf

	If lPEF815Prg
		lLogImp := ExecBlock("FIS815PRG",.F.,.F.,{})
	EndIf

	If Type("aRegTim") == "U"
		aRegTim := {}
	EndIf

	fArrParce()
	DistSal(cNumero, cSerie, @aPagos, @aImp, nDecPag)

	Aadd(aRecibos, {cNomXML, "", "", aPagos, cNumero, cSerie})

	If nOpc == 0
		If jData['origin'] ==  "FINA998"
			cXMLRet  := CreaXML(cNumero, cSerie, aPagos)
			nArchXML := CreaArch(cNomXML, cExtXML,@aResponse,jData)
			GrabaTexto(cXMLRet, nArchXML, .T.)
		else
			cXMLRet  := CreaXML(cNumero, cSerie, aPagos, nDecPag)
			nArchXML := CreaArch(cNomXML, cExtXML,@aResponse,jData)
			GrabaTexto(cXMLRet, nArchXML, .T.)
		ENDIF
	ElseIf nOpc == 1 .AND. jData['origin'] ==  "FINA998" 
		If !File( &(cPath) +cNomXML)
			cXMLRet  := CreaXML(cNumero, cSerie, aPagos, nDecPag)
			nArchXML := CreaArch(cNomXML, cExtXML,@aResponse,jData)
			GrabaTexto(cXMLRet, nArchXML, .T.)
			lCFDiRPag:=	CFDiRecPag(aRecibos,,@aResponse,jData,@cUUIDSus)
		EndIF
	EndIF

	If jData['origin'] == "FINA998"
		jData['path'] := cPath
		jData['nomXML'] := cNomXML
	EndIF

	If cFunName == "FINA088" .Or. jData['origin'] ==  "FINA998"
		aInfoCli  := ObtClient(cNumero,cSerie)
		If nOpc <> 0 .Or. CFDiRecPag(aRecibos,,@aResponse,jData,@cUUIDSus)
			If File( &(cPath) +cNomXML)
				If jData['joindocuments'] == .T.
					Aadd(aDocuments, &(cPath) +cNomXML)
				Else
					Aadd(aFilesEnv, &(cPath) +cNomXML)//Se agrega xml para el envío.
					//Timbrado de Recibo anulado previamente y que se sustituye
					If !Empty(cSerSus) .Or. !Empty(cRecSus) .And. !Empty(cUUIDSus)
						lSCan := .T.
						cXMLAnul	+= "ReciboPago" + Alltrim(cSerSus) + Alltrim(cRecSus)  + ".xml"
						cMotC := F815MOTCAN(cSerSus,cRecSus)
						aRecCan	:= {{cXMLAnul, "", "", {},cMotC,cUUIDSus}}
						If !Empty(cMotC) .And. !Empty(cUUIDSus)
							If CFDiRecPag(aRecCan, .F.,@aResponse)
								F815UPDCAN(cSerSus,cRecSus)
								If jData['origin'] ==  "FINA998"
									AADD(aResponse,{.T.,200, STR0145 +cSerSus+ " - "+cRecSus+" "+ STR0146})	
								EndIf
								nRegC += 1
							Else
								AADD(aResponse,{.T.,200, STR0145 +cSerSus+ " - "+cRecSus+" "+ STR0012})	
							EndIf

						EndIf
					EndIf
				EndIf
			Else
				lExistXML := .F.
				cMsjError += STR0131 + space(1)+ cNomXML + space(1)
			Endif
			If lImpCDFi
				//PE para impresión personalizada de recibos.
				Execblock("FISA815I",.f.,.f.,aRecibos)
			ElseIf lImpReci
				//PE para impresión personalizada de totvs recibos
				Execblock("F998IMPREC",.f.,.f.,aRecibos)
			Else
				//Se realizo esta comparacion para el control de totvs recibos para México se realiza la separacion de la
				//generacion del XML asi como de la impresion del PDF
				IF (jData['origin'] ==  "FINA998" .AND. jData['imppdf'] ==  .T. .AND. lCFDiRPag) .Or. (!jData['origin'] ==  "FINA998") .Or. (jData['origin'] ==  "FINA998" .AND. jData['sendemail'] ==  .T. .AND. lCFDiRPag )
					limpPdf := .T.
					For nPdf := 1 to Len(aRecibos)
						nValRecibo := aRecibos[nPdf][4][1][12]
						ImpPDF(aRecibos[nPdf, 1], Replace(aRecibos[nPdf, 1], ".xml", ".pdf"), cNomTmp, @jData, aResponse)
						cNomFile := cNomTmp + ".pdf"
						cPathFile	:= &(cPath) + cNomFile
						Aadd(aDoctos, {cPathFile, cNomFile,.F.}) //Documentos procesados desde FINA088
						If File(cPathFile)
							If jData['joindocuments'] == .T.
								Aadd(aDocuments, cPathFile)
							Else
								aAdd(aFilesEnv,cPathFile) //Se agrega PDF para envío de correo
							EndIf
						Else
							lExistPDF := .F.
							cMsjError += STR0131 + space(1)+ cNomXML + space(1)
						EndIf

						If jData['sendemail'] == .T.
							cEmailCli := jData['email']
							If jData['joindocuments'] == .T.
								IF jData['latest'] == .T.
									If EnvRecMail(cEmailCli,aDocuments,jData,@aResponse)
										If jData['origin'] ==  "FINA998"
											AADD(aResponse,{.T.,200,STR0125 + " - cliente: "+jData['client'],""})
										Else
											MsgInfo(STR0125,STR0124) // Envío de complemento de recepción de pago exitoso.
										EndIf 
									Else
										If jData['origin'] ==  "FINA998"
											AADD(aResponse,{.F.,400,STR0126 + " - cliente: "+IIF(VAZIO(jData['client']),"",jData['client']) ,""})
										Else
											MsgAlert(STR0126,STR0124) // El Complemento de recepción de pago no fue enviado.
										EndIf
									Endif
								EndIf
							Else 
								If EnvRecMail(cEmailCli,aFilesEnv,jData,@aResponse)
									If jData['origin'] ==  "FINA998"
										AADD(aResponse,{.T.,200,STR0125,""})
									Else
										MsgInfo(STR0125,STR0124) // Envío de complemento de recepción de pago exitoso.
									EndIf
								Else
									If jData['origin'] ==  "FINA998"
										AADD(aResponse,{.F.,400,STR0126,""})
									Else
										MsgAlert(STR0126,STR0124) // El Complemento de recepción de pago no fue enviado.
									EndIf
								Endif
							EndIf
						EndIf
					Next
				Else				
					If jData['origin'] ==  "FINA998" .and. !lCFDiRPag
						AADD(aResponse,{.T.,200,STR0010 +"PDF No"+STR0011}) 
					EndIf 
				Endif
			EndIf
			if nOpc <> 1
				If (nImpAuto == 3 .Or. nImpAuto == 4)
					cEmailCli := ObtEmail(aInfoCli[1],aInfoCli[2])
					If Empty(cEmailCli)
						cMsjCli := STR0130
					EndIf
				EndIf
				If !Empty(cMsjError)
					cMsjError := STR0132 +&(cPath)+ space(1)+cMsjError
				Endif
				If !Empty(cMsjCli)
					cMsjError := cMsjCli + space(1)+cMsjError
				Endif
				If jData['origin'] ==  "FINA998"  .And. !EMPTY(cMsjError)
					AADD(aResponse,{.F.,400,cMsjError , ""})
				ENDIF
				AADD(aRegTim, {cNumero,cSerie, .T.,.F.,cMsjError,aInfoCli[1],aInfoCli[2],cEmailCli,aFilesEnv})
			Else
				AADD(aRegTim, {cNumero,cSerie, .T.})
			Endif
		Else
			If jData['origin'] ==  "FINA998"
				AADD(aResponse,{.F.,400,OemToAnsi(STR0012) , aInfoCli[1] + " : " + aInfoCli[2]})
			Else
				AADD(aRegTim, {cNumero,cSerie, .F.,.F.,STR0012,aInfoCli[1],aInfoCli[2]})
			EndIF
		EndIf
	Else
		//Timbrado
		lCFDiRPag := CFDiRecPag(aRecibos,,@aResponse, jData, @cUUIDSus)
		If cFunName $ "FINA087A" //Validación de timbrado antes de ingresar a rutina de genracion de poliza
			lTimbraOk	:= lCFDiRPag
		EndIf
		If File( &(cPath) +cNomXML)
			Aadd(aFilesEnv, &(cPath) +cNomXML)//Se agrega xml para el envío.
		EndIf
		//Timbrado de Recibo anulado previamente y que se sustituye
		If !Empty(cSerSus) .Or. !Empty(cRecSus) .And. !Empty(cUUIDSus) .And. cCanAut !="N"
			cMotC := F815MOTCAN(cSerSus,cRecSus)
			cXMLAnul	+= "ReciboPago" + Alltrim(cSerSus) + Alltrim(cRecSus)  + ".xml"
			aRecCan	:= {{cXMLAnul, "", "", {},cMotC,cUUIDSus}}
			cMsgAnula := OemToAnsi(STR0010) + cXMLAnul //"Archivo "
			If CFDiRecPag(aRecCan, .F.)
				cMsgAnula += STR0142 //" Cancelado ante el SAT"
				F815UPDCAN(cSerSus,cRecSus)
			Else
				cMsgAnula += STR0143 //" NO Cancelado ante el SAT, intentarsolicitar la Canelación nuevamente desde la acción Anular de la rutina Anular/Timbrar/Imprimir Cobros Diversos (FINA088)."
			EndIf
		ElseIf !Empty(cSerSus) .Or. !Empty(cRecSus) .And. cCanAut == "N"
			cXMLAnul	+= "ReciboPago" + Alltrim(cSerSus) + Alltrim(cRecSus)  + ".xml"
			cMsgAnula := OemToAnsi(Strtran(STR0156, "#ReciboPago#", cXMLAnul)) // El complemento de pago #ReciboPago# quedó pendiente de cancelación ante el SAT, no olvide realizar dicha cancelación.
		EndIf
		If !lLogTim
			If lCFDiRPag
				MsgInfo(OemToAnsi(STR0010) + cNomXML + OemToAnsi(STR0011) + IIf(!Empty(cMsgAnula), CRLF + cMsgAnula,"")) //"Archivo " //" generado"
			Else
				MSGALERT(OemToAnsi(STR0012)) //"Error al timbrar el documento."
			EndIf
		EndIf

		//Pregunta de impresion en pdf
		If (nImpAuto == 0 .Or. nImpAuto == 3) .And. lCFDiRPag .And. !lRutAuto
			If MsgYesNo(OemToAnsi(STR0013)+Iif(nImpAuto == 3,CRLF+CRLF+OemToAnsi(STR0129),""), OemToAnsi(STR0014)) //Desea imprimir el recibo de pago? - MV_CFDREC ==3 Para realizar el envío del Complemento de recepción de pagos es necesario realizar la impresión."  //Impresión
				lResp := .F.
			EndIf
		EndIf

		If lRutAuto //Proceso de Teste Automatizado
			F015CARCHI(aRecibos)
		EndIf

		If !lResp .Or. (nImpAuto == 1 .Or. nImpAuto == 4)  .And. lCFDiRPag
			If lImpCDFi
				//PE para impresión personalizada de recibos.
				Execblock("FISA815I",.f.,.f.,aRecibos)
			Else
				If Empty(cURLValCFD)
					MsgInfo(STR0092) //"El parámetro MV_VERICFD se encuentra vacío, es necesario informar la url de Verificación de Comprobantes Fiscales Digitales por Internet, la cual es necesario para generar correctamente el Código QR. Informe el parámetro e intente imprimir desde la rutina FINA088."
					Return
				EndIf
				For nPdf := 1 to Len(aRecibos)
					nValRecibo := aRecibos[nPdf][4][1][12]
					ImpPDF(aRecibos[nPdf, 1], Replace(aRecibos[nPdf, 1], ".xml", ".pdf"), cNomTmp)
					If !lLogImp
						MsgInfo(OemToAnsi(STR0010) + Replace(aRecibos[nPdf, 1], ".xml", ".pdf") + OemToAnsi(STR0011)) //Archivo  // generado
					EndIf
					cNomFile := cNomTmp + ".pdf"
					cPathFile	:= &(cPath) + cNomFile
					If File(cPathFile)
						aAdd(aFilesEnv,cPathFile) //Se agrega PDF para envío de correo
					Endif
					// Copiar archivo al cliente a carpeta temporales.
					If CpyS2T( cPathFile , cDirLocal)
						// Se abre la aplicación para visualizar archivo PDF
						nRet:= ShellExecute("Open",cNomFile,"",cDirLocal,1)
						If nRet <= 32 .And. !lLogImp
							MsgInfo(STR0006,STR0078) // "Error al abrir el archivo especificado"
						EndIf
					Else
						If !lLogImp
							MsgInfo(STR0006,STR0078) // "Error al abrir el archivo especificado"
						EndIf
					EndIf
				Next nPdf
				If Len(aFilesEnv) == 2 .and. (nImpAuto == 3 .Or. nImpAuto == 4)
					If nImpAuto == 3
						lEnvMail := MSGYESNO( STR0128, STR0127 ) // "¿Desea realizar el envío por correo del Complemento de recepción de pago?" - "Envío del Complemento de recepción de pagos"
					EndIf
					If lEnvMail
						cEmailCli := ObtEmail(cCliente,cLoja)
						If EnvRecMail(cEmailCli,aFilesEnv)
							MsgInfo(STR0125,STR0124) // Envío de complemento de recepción de pago exitoso.
						Else
							MsgAlert(STR0126,STR0124) // El Complemento de recepción de pago no fue enviado.
						Endif
					EndIf
				EndIf
			Endif
		EndIf

	Endif
	RestArea(aAreaSEL)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³CreaXML     ³ Autor ³ Raul Ortiz Medina   ³ Fecha ³18/05/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Forma archivo XML de retenciones                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CreaXML(cNumero, cSerie, aPagos, nDecPag)
	Local aAuxNodo		:= {}
	Local aAuxPago		:= {}
	Local cAuxXml		:= cXml
	Local cXmlnsCfd		:= ""
	Local cXmlnsXsi		:= " http://www.w3.org/2001/XMLSchema-instance"
	Local cXsiSLocR		:= ""
	Local cXsiSLocP		:= ""
	Local cXmlPagos		:= ""
	Local cXsiSLoPa		:= ""
	Local cVersionP		:= ""
	Local cMoneda		:= "XXX"
	Local cTipCom		:= "P"
	Local cUsoCFDi		:= ""
	Local cClvPrdS		:= "84111506"
	Local cUnidad		:= "ACT"
	Local cDesc			:= "Pago"
	Local cUUID			:= ""
	Local cMoedaSatE	:= ""
	Local cMoedaSat		:= ""
	Local nI			:= 0
	Local nSaldo		:= 0
	Local nTpCambioE	:= 0
	Local nTpCambio		:= 0
	Local nSalAnt		:= 0
	Local nImpPag		:= 0
	Local cRFC			:= ""
	Local cCuenta		:= ""
	Local cRFCO			:= ""
	Local cCuentaO		:= ""
	Local cCuentaB		:= ""
	Local cNomBanO		:= ""
	Local nX			:= 0
	Local nY			:= 0
	Local cMetPag		:= ""
	Local cFormPag		:= ""
	Local cSello		:= ""
	Local aTitulos		:= {}
	Local nPos			:= 0
	Local cHraPago		:= ALLTRIM( SUPERGETMV( "MV_HRAREC" , .F. , "" ) )
	Local cTipCadPag	:= ""
	Local cCertPago		:= ""
	Local cCadPago		:= ""
	Local cSelloPago	:= ""
	Local cLugExp		:= ALLTRIM( SUPERGETMV( "MV_CFDICP" , .F. , "M0_CEPCOB" ) )
	Local cLugExpCont	:= ""
	Local cFilCTO		:= xFilial("CTO")
	Local cFilOri		:= ""
	Local nTasaRec		:= 1
	Local nTasaDoc		:= 1
	Local cCli          := ""
	Local cLoja         := ""
	Local cSerDoc       := ""
	Local cDoc          := ""
	Local cNumOp        := ""
	Local lPEF087AN0    := ExistBlock("F087ANUMOP")
	Local cCPGenera		:= SuperGetMV("MV_CFDICPG", .F., "")
	Local cVPago		:= ""
	Local nTotPago		:= 0
	Local cRegFisRec	:= ""
	Local cResFis       := ""
	Local cIdFis        := ""
	Local lImpDoc       := .F.
	Local nImp          := 0
	Local aImpDoc       := {}
	Local aImpDocR      := {}
	Local aDocRel       := {}
	Local aTotDocT      := {}
	Local aTotDocR      := {}
	Local aRetAuto      := {}
	Local cFechaRec     := "" 
	Local cHoraRec      := ""
	Local cFilSYA       := xFilial("SYA")

	Default nDecPag     := 2 
	If lVCFDi40
		cVersionP	:= "2.0"
		cXmlnsCfd	:= " http://www.sat.gob.mx/cfd/4"
		cXsiSLocR	:= " http://www.sat.gob.mx/cfd/4"
		cXsiSLocP	:= " http://www.sat.gob.mx/sitio_internet/cfd/4/cfdv40.xsd"
		cXmlPagos	:= " http://www.sat.gob.mx/Pagos20"
		cXsiSLoPa	:= " http://www.sat.gob.mx/sitio_internet/cfd/Pagos/Pagos20.xsd"
		cVPago		:= "pago20"
		cUsoCFDi	:= "CP01"
	Else
		cVersionP	:= "1.0"
		cXmlnsCfd	:= " http://www.sat.gob.mx/cfd/3"
		cXsiSLocR	:= " http://www.sat.gob.mx/cfd/3"
		cXsiSLocP	:= " http://www.sat.gob.mx/sitio_internet/cfd/3/cfdv33.xsd"
		cXmlPagos	:= " http://www.sat.gob.mx/Pagos"
		cXsiSLoPa	:= " http://www.sat.gob.mx/sitio_internet/cfd/Pagos/Pagos10.xsd"
		cVPago		:= "pago10"
		cUsoCFDi	:= "P01"
	EndIf

	If lRutAuto
		//Se obtienen parametros definidos en caso de prueba CT001
		aRetAuto := GetParAuto("FISA815TestCase")  
		cFechaRec := IIf(Len(aRetAuto) >= 1,aRetAuto[1],GetRmtDate())
		cHoraRec  := IIf(Len(aRetAuto) >= 2,aRetAuto[2],GetRmtTime())
	Else
		cFechaRec := GetRmtDate()
		cHoraRec  := GetRmtTime()
	EndIf
	DbSelectArea("SEL")
	SEL->(DbSetOrder(8))//EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
	If SEL->(DbSeek(xFilial("SEL") + cSerie + cNumero))

		cCadOrig   := "||"

		If !Empty(cLugExp) // se valida si está vacio el parámetro
			If cLugExp == "M0_CEPENT" //se valida si el campo es M0_CEPENT
				If !Empty(SM0->M0_CEPENT)
					cLugExpCont:= SM0->M0_CEPENT
				Else
					cLugExpCont:= SM0->M0_CEPCOB
				EndIf
			Else
				cLugExpCont:= SM0->M0_CEPCOB
			EndIf
		Else
			cLugExpCont:= SM0->M0_CEPCOB
		EndIf

		// CP de la sucursal que genera CFDI
		If Empty(cCPGenera)
			cCPGenera := cLugExpCont
		EndIf

		//Nodo Cfdi Comprobante
		aAuxNodo := {{'xmlns:cfdi="#cVal#"', cXmlnsCfd, lReq, .F., .F. },;
			{'xmlns:xsi="#cVal#"', cXmlnsXsi, lReq, .F., .F.},;
			{'xmlns:'+cVPago+'="#cVal#"', cXmlPagos, lReq, .F., .F.},;
			{'xsi:schemaLocation="#cVal#"', cXsiSLocR + cXsiSLocP + cXmlPagos + cXsiSLoPa, lReq, .F., .F.},;
			{'Version="#cVal#"', cVersion, lReq, lCadOrig, .F.},;
			IIf(!Empty(cSerie), {'Serie="#cVal#"', cSerie, lReq, lCadOrig, .F.}, {}),;
			{'Folio="#cVal#"', cNumero, lReq, lCadOrig, .F.},;
			{'Fecha="#cVal#"', zh_FechaHoraUTC(cCPGenera, cLugExpCont, cFechaRec, cHoraRec), lReq, lCadOrig, .F.},;
			{'NoCertificado="#cVal#"', cNoCert, lReq, lCadOrig, .F.},;
			{'SubTotal="#cVal#"', "0", lReq, lCadOrig, .F.},;
			{'Moneda="#cVal#"', cMoneda, lReq, lCadOrig, .F.},;
			{'Total="#cVal#"', "0", lReq, lCadOrig, .F.},;
			{'TipoDeComprobante="#cVal#"', cTipCom, lReq, lCadOrig, .F.},;
			IIf(lVCFDi40, {'Exportacion="#cVal#"', "01", lReq, lCadOrig, .F.}, {}),;
			{'LugarExpedicion="#cVal#"', AllTrim(cLugExpCont), lReq, lCadOrig, .F.},;
			{'Confirmacion="#cVal#"', "", lReq, .F., .F.},;
			{'Certificado="#cVal#"', cCertif, lReq, .F., .F.},;
			{'Sello="#cVal#"', "#cSello#", lReq, .F., .F.}}

		cAuxXml += ObtNodo(aAuxNodo, cNodoSup, 'cfdi:Comprobante')

		//Elemento: CfdiRelacionados
		If cPaisLoc == "MEX" .And. SEL->(ColumnPos("EL_SERSUS")) > 0 .And.  SEL->(ColumnPos("EL_RECSUS"))
			If !Empty(SEL->EL_SERSUS) .Or. !Empty(SEL->EL_RECSUS)
				aAuxNodo := {{'TipoRelacion="#cVal#"', '04', lOpc, lCadOrig, .F.}}
				cAuxXml += ObtNodo(aAuxNodo, cNodoSup, 'cfdi:CfdiRelacionados')
				aAuxNodo := {{'UUID="#cVal#"', F815UUIDRe(SEL->EL_SERSUS, SEL->EL_RECSUS), lOpc, lCadOrig, .F.}}
				cAuxXml += ObtNodo(aAuxNodo, cNodoInf, 'cfdi:CfdiRelacionado')
				cAuxXml += Strtran(cFinNodo, '#cNomNodo#', 'cfdi:CfdiRelacionados')
			EndIf
		EndIf

		// Elemento: Emisor
		aAuxNodo := {{'Rfc="#cVal#"', SM0->M0_CGC, lReq, lCadOrig, .T.},;
			{'Nombre="#cVal#"', SM0->M0_NOMECOM, lOpc, lCadOrig, .T.},;
			{'RegimenFiscal="#cVal#"', AllTrim(SM0->M0_DSCCNA), lReq, lCadOrig, .F.}}

		cAuxXml += ObtNodo(aAuxNodo, cNodoInf, 'cfdi:Emisor')

		DbSelectArea("SA1")
		SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
		If Len(aPagos) > 0 .And. Len(aPagos[1][14]) > 0	// Por si acaso para que no genere error
			// Generar CFDI al cliente definido en el encabezado del recibo, EL_CLIENTE+EL_LOJA
			// Buscar código en sub arreglo de documentos
			SA1->(DbSeek(xFilial("SA1") + aPagos[1][14][1][18] + aPagos[1][14][1][19]))
		Else
			SA1->(DbSeek(xFilial("SA1") + SEL->EL_CLIORIG + SEL->EL_LOJORIG))
		Endif

		If lVCFDi40
			DbSelectArea("AI0")
			AI0->(DbSetOrder(1))//AI0_FILIAL+AI0_CODCLI+AI0_LOJA
			If AI0->(ColumnPos("AI0_REGFIS")) > 0 .And. AI0->(MsSeek(xFilial("AI0")+SA1->(A1_COD+A1_LOJA)))
				cRegFisRec := AI0->AI0_REGFIS
				If AI0->(ColumnPos("AI0_IDFIS")) > 0
					cIdFis := AI0->AI0_IDFIS
				EndIf
			EndIf
			If Alltrim(SA1->A1_CGC) == "XEXX010101000" //RFC Genérico Extranjeros
				DbSelectArea("SYA")
				SYA->(DbSetOrder(1)) //YA_FILIAL+YA_CODGI
				If SYA->(dbSeek(cFilSYA + SA1->A1_PAIS))
					cResFis := SYA->YA_CCESAT
				EndIf
			EndIf
		EndIf

		// Elemento: Receptor
		aAuxNodo := {{'Rfc="#cVal#"', SA1->A1_CGC, lReq, lCadOrig, .T.},;
			{'Nombre="#cVal#"', SA1->A1_NOME, lOpc, lCadOrig, .T.},;
			IIf(lVCFDi40, {'DomicilioFiscalReceptor="#cVal#"', SA1->A1_CEP, lOpc, lCadOrig, .T.},{}),;
			IIf(lVCFDi40 .And. !Empty(cResFis), {'ResidenciaFiscal="#cVal#"', cResFis, lOpc, lCadOrig, .T.},{}),;
			IIf(lVCFDi40 .And. !Empty(cResFis) .And. !Empty(cIdFis), {'NumRegIdTrib="#cVal#"', cIdFis, lOpc, lCadOrig, .T.},{}),;
			IIf(lVCFDi40 , {'RegimenFiscalReceptor="#cVal#"', cRegFisRec, lOpc, lCadOrig, .T.},{}),;
			{'UsoCFDI="#cVal#"', cUsoCFDi, lReq, lCadOrig, .F.}}

		cAuxXml += ObtNodo(aAuxNodo, cNodoInf, 'cfdi:Receptor')

		cAuxXml += Strtran(cIniNodo, '#cNomNodo#', 'cfdi:Conceptos') //Inicio del nodo de conceptos

		//Elemento: Conceptos
		aAuxNodo := {{'ClaveProdServ="#cVal#"',cClvPrdS,lReq, lCadOrig,.F.},;
			{'Cantidad="#cVal#"',"1",lReq, lCadOrig,.F.},;
			{'ClaveUnidad="#cVal#"',cUnidad,lReq, lCadOrig,.F.},;
			{'Descripcion="#cVal#"',cDesc,lReq, lCadOrig,.F.},;
			{'ValorUnitario="#cVal#"',"0",lReq, lCadOrig,.F.},;
			{'Importe="#cVal#"',"0",lReq, lCadOrig,.F.},;
			IIf(lVCFDi40, {'ObjetoImp="#cVal#"',"01",lReq, lCadOrig,.F.},{})}

		cAuxXml += ObtNodo(aAuxNodo, cNodoInf, 'cfdi:Concepto')

		cAuxXml += Strtran(cFinNodo, '#cNomNodo#', 'cfdi:Conceptos')	 //Fin del nodo de Conceptos

		cAuxXml += Strtran(cIniNodo, '#cNomNodo#', 'cfdi:Complemento') //Inicio del nodo de Complemento

		//Nodo Pagos
		aAuxNodo := {{'Version="#cVal#"', cVersionP, lReq, lCadOrig, .F.}}

		cAuxXml += ObtNodo(aAuxNodo, cNodoSup, cVPago+':Pagos') //Fin del Nodo Pagos

		If lVCFDi40
			aAuxNodo := {IIf(nTotRetIVA > 0,{'TotalRetencionesIVA="#cVal#"',Str(nTotRetIVA,20,2),lReq, lCadOrig,.F.},{}),;
			IIf(nTotBase16 > 0,{'TotalTrasladosBaseIVA16="#cVal#"',Str(nTotBase16,20,2),lReq, lCadOrig,.F.},{}),;
			IIf(nTotImp16 > 0,{'TotalTrasladosImpuestoIVA16="#cVal#"',Str(nTotImp16,20,2),lReq, lCadOrig,.F.},{}),;
			IIf(nTotBase8  > 0,{'TotalTrasladosBaseIVA8="#cVal#"',Str(nTotBase8,20,2),lReq, lCadOrig,.F.},{}),;
			IIf(nTotImp8   > 0,{'TotalTrasladosImpuestoIVA8="#cVal#"',Str(nTotImp8,20,2),lReq, lCadOrig,.F.},{}),;
			IIf(nTotBase0  > 0,{'TotalTrasladosBaseIVA0="#cVal#"',Str(nTotBase0,20,2),lReq, lCadOrig,.F.},{}),;
			IIf(nTotBase0  > 0,{'TotalTrasladosImpuestoIVA0="#cVal#"',"0.00",lReq, lCadOrig,.F.},{}),;
			IIf(nTotBExe   > 0,{'TotalTrasladosBaseIVAExento="#cVal#"',Str(nTotBExe,20,2),lReq, lCadOrig,.F.},{}),;
			{'MontoTotalPagos="#cVal#"','#MontoTotalPagar#',lReq, lCadOrig,.F.}}
			cAuxXml += ObtNodo(aAuxNodo, cNodoInf, 'pago20:Totales')
		EndIf

		aTitulos := fGetDocs(aPagos)//Obtiene titulos pagados e importe.

		For nX := 1 To Len(aPagos)
			cCuentaB	:= ""
			cRFCO		:= ""
			cCuentaO	:= ""
			cNomBanO	:= ""
			nTpCambioE	:= 0
			cMoedaSatE	:= Posicione("CTO", 1, cFilCTO + StrZero(IIf(ValType(aPagos[nX][_MOEDA]) == "C", Val(aPagos[nX][_MOEDA]),aPagos[nX][_MOEDA]),2),"CTO_MOESAT")

			If AllTrim(cMoedaSatE) != "MXN"
				nTpCambioE := aPagos[nX][_MOEDAS][Val(aPagos[nX][_MOEDA])]
			ElseIf lVCFDi40
				nTpCambioE := 1
			EndIf

			If aPagos[nX][25] $ "02|03|04|05|06|28|29|99"  //Formas de Pago Bancarizadas
				//Datos Para banco Beneficiario
				GetBanco(aPagos[nX][_BANCO], aPagos[nX][_AGENCIA],aPagos[nX][_CONTA], @cRFC, @cCuenta)
				//Obtiene cNomBanO cuando Banco Es Extranjero para Formas de Pago Bancarizadas
				If Empty(aPagos[nX][_BCOCHQ]) .OR. Empty(aPagos[nX][_AGECHQ]) .OR. Empty(aPagos[nX][_CTACHQ])
					GetBanco(aPagos[nX][_BANCO], aPagos[nX][_AGENCIA], aPagos[nX][_CONTA],  @cRFCO, @cCuentaO, @cNomBanO, .F.)
				Else
					GetBanco(aPagos[nX][_BCOCHQ], aPagos[nX][_AGECHQ], aPagos[nX][_CTACHQ], @cRFCO, @cCuentaO, @cNomBanO,.T.)
				Endif
			EndIf

			cTipCadPag 	:= ""
			cCertPago 	:= ""
			cCadPago 	:= ""
			cSelloPago	:= ""

			cFormPag	:= aPagos[nX][25]
			cRFCO		:= aPagos[nX][26]
			cCuentaO	:= aPagos[nX][27]
			cTipCadPag 	:= aPagos[nX][28]
			cCertPago 	:= aPagos[nX][29]
			cCadPago    := CFDCarEsp(F815ElmEsp(aPagos[nX][30])) 
			cSelloPago	:= F815ElmEsp(aPagos[nX][31])
			cCuentaB	:= aPagos[nX][32]

			If lPEF087AN0
				cNumOp:=ExecBlock("F087ANUMOP",.F.,.F.,{aPagos,nX})
			Else
				cNumOp:=AllTrim(aPagos[nX][_FREFIXO]) + AllTrim(aPagos[nX][_NUMERO])
			EndIf

			If SEL->(ColumnPos("EL_HRPAGO")) > 0
				cHraPago := aPagos[nX][_HRAPAGO]
			EndIf

			//Nodo Pago
			aAuxNodo := {{'FechaPago="#cVal#"',FWTimeStamp(3, aPagos[nX][_EMISSAO], IIF(!EMPTY(cHraPago),cHraPago,GetRmtTime())),lReq,lCadOrig,.F.},;
				{'FormaDePagoP="#cVal#"',cFormPag,lReq,lCadOrig,.F.},;
				{'MonedaP="#cVal#"',cMoedaSatE,lReq,lCadOrig,.F.},;
				{'TipoCambioP="#cVal#"',nTpCambioE,lOpc,Iif(nTpCambioE == 0, .F.,lCadOrig),.F.},;
				{'Monto="#cVal#"',aPagos[nX][_VALOR],lReq,lCadOrig,.F.},;
				{'NumOperacion="#cVal#"',cNumOp,lReq,lCadOrig,.F.},;
				{'RfcEmisorCtaOrd="#cVal#"',cRFCO,lOpc,lCadOrig,.F.},;//*
			{'NomBancoOrdExt="#cVal#"',cNomBanO,lOpc,lCadOrig,.F.},; //*
			{'CtaOrdenante="#cVal#"',cCuentaO,lOpc,lCadOrig,.F.},; //*
			{'RfcEmisorCtaBen="#cVal#"',IiF( AllTrim(cCuentaB) <> "", cRFC, ""),lReq,lCadOrig,.F.},; //*
			{'CtaBeneficiario="#cVal#"',cCuentaB,lReq,lCadOrig,.F.},; //*
			{'TipoCadPago="#cVal#"',cTipCadPag,lOpc,lCadOrig,.F.},; //*
			{'CertPago="#cVal#"',cCertPago,lOpc,lCadOrig,.F.},; //*
			{'CadPago="#cVal#"',CodHTML(cCadPago, .T.),lOpc,lCadOrig,.F.},; //*
			{'SelloPago="#cVal#"',cSelloPago,lOpc,lCadOrig,.F.}} //*

			If lVCFDi40
				nTotPago += (nTpCambioE * aPagos[nX][_VALOR])
			EndIf

			aDocRel  := {}

			For nY := 1 To Len(aPagos[nX][14])
				cCli  := aPagos[nX][14][nY][_CLIENTE]
				cLoja := aPagos[nX][14][nY][_LOJA]
				cDoc  := aPagos[nX][14][nY][_NUMERO]
				cSerDoc := aPagos[nX][14][nY][_FREFIXO]
				aImpDoc := {}
				aImpDocR:= {}
				aAuxPago:= {}
				//Obtiene Filial Origen del Documento
				fGetFilOri(aPagos[nX][2],aPagos[nX][14][nY][3],aPagos[nX][14][nY][4],aPagos[nX][14][nY][5] ,aPagos[nX][14][nY][6],aPagos[nX][24],@cFilOri,AllTrim(aPagos[nX][_TIPO])$"CO")
				GetInfo(cCli, cLoja, cDoc, AllTrim(aPagos[nX][14][nY][_TIPO]), @cUUID, aPagos[nX][14][nY][_FREFIXO],cFilOri)

				//Obtiene Saldos
				nPos := aScan(aTitulos, {|x| x[1] == aPagos[nX][14][nY][3]})
				If !(aTitulos[nPos][4])
					nSaldo := GetSaldo(aPagos[nX][14][nY][4], aPagos[nX][14][nY][3], aPagos[nX][14][nY][5], aPagos[nX][14][nY][6], cCli, cLoja, aPagos[nX][14][nY][17], aPagos[nX][14][nY][2],cFilOri)
				ElseIf Empty(aPagos[nX][3]) .And. aPagos[nX][25] == "17"	// nodo Pago de compensación, traer saldo determinado previamente
					nSaldo := aTitulos[nPos][3]
				EndIf

				If nSaldo == 0
					nSalAnt := aPagos[nX][14][nY][15]
				Else
					aPagos[nX][14][nY][15] += aPagos[nX][14][nY][21]
					If aTitulos[nPos][4]
						nSaldo := nSaldo - Round(aPagos[nX][14][nY][15],2)
						nSalAnt := round(aTitulos[nPos][3],2)
						aTitulos[nPos][3] -= round(aPagos[nX][14][nY][15],2)
					Else
						nSalAnt := nSaldo
						nSaldo := nSalAnt - Round(aPagos[nX][14][nY][15],2)
						aTitulos[nPos][3] := nSalAnt - aPagos[nX][14][nY][15]
						aTitulos[nPos][4] := .T.
					EndIf

				EndIf

				nImpPag := aPagos[nX][14][nY][15]
				cMoedaSat := Posicione("CTO",1,cFilCTO+Strzero(Iif(ValType(aPagos[nX][14][nY][_MOEDA]) == "C", Val(aPagos[nX][14][nY][_MOEDA]),aPagos[nX][14][nY][_MOEDA]),2),"CTO_MOESAT")

				If cMoedaSatE != cMoedaSat
					nTasaRec := aPagos[nX][13][Val(aPagos[nX][11])]			//Tasa del recibo correspondiente a la moneda del recibo
					nTasaDoc := aPagos[nX][13][Val(aPagos[nX][14][nY][11])] //Tasa del recibo correspondiente a la moneda del documento relacionado
					If Alltrim(cMoedaSat) != "MXN" .And. Alltrim(cMoedaSatE) != "MXN"
						nTpCambio := nTasaRec/nTasaDoc
					ElseIf Alltrim(cMoedaSat) != "MXN"
						nTpCambio := 1/nTasaDoc
					Else
						nTpCambio := nTasaRec
					EndIf
				Else
					nTpCambio := 1
				EndIf

				cMetPag := aPagos[nX][14][nY][16]

				If lVCFDi40
					nMoedaP :=  Val(SubStr(Alltrim(aPagos[nX][_MOEDA]),-1,1))
					nMoedaD :=  Val(SubStr(Alltrim(aPagos[nX][14][nY][_MOEDA]),-1,1))

					If Len(aPagos[nX][14][nY][23]) > 0 //Retenciones 
						For nImp := 1 To Len(aPagos[nX][14][nY][23])
							aAdd(aImpDocR,{{'BaseDR="#cVal#"',Str(aPagos[nX][14][nY][23][nImp][1],18,6),lReq,lCadOrig,.F.},;
							{'ImpuestoDR="#cVal#"',aPagos[nX][14][nY][23][nImp][2],lReq,lCadOrig,.F.},;
							{'TipoFactorDR="#cVal#"',aPagos[nX][14][nY][23][nImp][3],lReq,lCadOrig,.F.},;
							{'TasaOCuotaDR="#cVal#"',Str(aPagos[nX][14][nY][23][nImp][4],10,6),lReq,lCadOrig,.F.},;
							{'ImporteDR="#cVal#"',Str(aPagos[nX][14][nY][23][nImp][5],18,2),lReq,lCadOrig,.F.}})
						Next nImp
					EndIf

					If Len(aPagos[nX][14][nY][22]) > 0 //Traslados 
						For nImp := 1 To Len(aPagos[nX][14][nY][22])
							aAdd(aImpDoc,{{'BaseDR="#cVal#"',Str(aPagos[nX][14][nY][22][nImp][1],18,6),lReq,lCadOrig,.F.},;
							{'ImpuestoDR="#cVal#"',aPagos[nX][14][nY][22][nImp][2],lReq,lCadOrig,.F.},;
							{'TipoFactorDR="#cVal#"',aPagos[nX][14][nY][22][nImp][3],lReq,lCadOrig,.F.},;
							IIf(Alltrim(aPagos[nX][14][nY][22][nImp][3])=="Exento",{},{'TasaOCuotaDR="#cVal#"',Str(aPagos[nX][14][nY][22][nImp][4],0,6),lReq,lCadOrig,.F.}),;
							IIf(Alltrim(aPagos[nX][14][nY][22][nImp][3])=="Exento",{},{'ImporteDR="#cVal#"',Str(aPagos[nX][14][nY][22][nImp][5],18,2),lReq,lCadOrig,.F.})})
						Next nImp
					EndIf

					lImpDoc := Len(aPagos[nX][14][nY][22]) > 0 .Or. Len(aPagos[nX][14][nY][23]) > 0
				EndIf

				//Nodo Documento Relacionado
				If Round(nImpPag,2) > 0
					aAdd(aAuxPago,{{'IdDocumento="#cVal#"',cUUID,lReq,lCadOrig,.F.},;
						{'Serie="#cVal#"',aPagos[nX][14][nY][_FREFIXO],lReq,lCadOrig,.F.},;
						{'Folio="#cVal#"',aPagos[nX][14][nY][_NUMERO],lReq,lCadOrig,.F.},;
						{'MonedaDR="#cVal#"',cMoedaSat,lReq,lCadOrig,.F.},;
						IIf(lVCFDi40, {}, {Iif(cMoedaSat != cMoedaSatE, 'TipoCambioDR="#cVal#"', ""),Iif(cMoedaSat != cMoedaSatE, nTpCambio, ""),lOpc, Iif(cMoedaSat != cMoedaSatE, lCadOrig, .F.), .F.}),; //Si la moneda del pago es la misma que el doc relacionado, el atributo TipoCambioDR no debe de ir.
						IIf(lVCFDi40, {'EquivalenciaDR="#cVal#"', nTpCambio,lOpc,lCadOrig, .F.},{}),;
						IIf(lVCFDi40, {}, {'MetodoDePagoDR="#cVal#"',cMetPag,lOpc,lCadOrig,.F.}),; //Atributo se elimina en CRP version 2.0
						{'NumParcialidad="#cVal#"',Iif(cMetPag != "PUE",GetParcela(AllTrim(aPagos[nX][14][nY][_NUMERO]),aPagos[nX][14][nY][_FREFIXO],aPagos[nX][14][nY][_TIPO],cFilOri),""),lOpc, Iif(cMetPag != "PUE", lCadOrig, .F.), .F.},; //Si cMetPag es diferente de PUE, debe de mostrar las parcialidades.
						{'ImpSaldoAnt="#cVal#"',nSalAnt,lReq,lCadOrig,.F.},;
						{'ImpPagado="#cVal#"',nImpPag,lReq,lCadOrig,.F.},;
						{'ImpSaldoInsoluto="#cVal#"', nSalAnt - nImpPag, lReq, lCadOrig, .F.},;
						IIf(lVCFDi40, {'ObjetoImpDR="#cVal#"', IIf(lImpDoc,"02","01"), lReq, lCadOrig, .F.},{})})
						aAdd(aDocRel,{aAuxPago,aImpDoc,aImpDocR})
				EndIf
			Next nY

			cAuxXml += ObtNodo(aAuxNodo, cNodoSup, cVPago+':Pago')

			For nI := 1 To Len(aDocRel)
				cAuxXml += ObtNodo(aDocRel[nI][1][1], cNodoSup, cVPago +':DoctoRelacionado')
				If lImpDoc
					cAuxXml += Strtran(cIniNodo, '#cNomNodo#', cVPago + ':ImpuestosDR') //Inicio del nodo de ImpuestosDR
					If Len(aDocRel[nI][3]) > 0 
						cAuxXml += Strtran(cIniNodo, '#cNomNodo#', cVPago + ':RetencionesDR') //Inicio del nodo de TrasladosDR
						For nImp := 1 To Len(aDocRel[nI][3])
							cAuxXml += ObtNodo(aDocRel[nI][3][nImp], cNodoInf, cVPago + ':RetencionDR')
						Next nImp
						cAuxXml += Strtran(cFinNodo, '#cNomNodo#', cVPago + ':RetencionesDR') //Fin del nodo de TrasladosDR
					EndIf
					If Len(aDocRel[nI][2]) > 0 
						cAuxXml += Strtran(cIniNodo, '#cNomNodo#', cVPago + ':TrasladosDR') //Inicio del nodo de TrasladosDR
						For nImp := 1 To Len(aDocRel[nI][2])
							cAuxXml += ObtNodo(aDocRel[nI][2][nImp], cNodoInf, cVPago + ':TrasladoDR')
						Next nImp
						cAuxXml += Strtran(cFinNodo, '#cNomNodo#', cVPago + ':TrasladosDR') //Fin del nodo de TrasladosDR
					EndIf
					cAuxXml += Strtran(cFinNodo, '#cNomNodo#', cVPago + ':ImpuestosDR') //Fin del nodo de ImpuestosDR
					cAuxXml += Strtran(cFinNodo, '#cNomNodo#', cVPago + ':DoctoRelacionado') //Fin del nodo de DoctoRelacionado
				Else
					cAuxXml := Substr(cAuxXml, 1, Rat(">", cAuxXml) - 1) + "/>" + CRLF	// CFDI v3.3
				EndIf
			Next nI

			If lVCFDi40
				aTotDocT := {} //Traslados Pago
				For nImp := 1 To Len(aPagos[nX][34])
					aAdd(aTotDocT,{{'BaseP="#cVal#"',Alltrim(Str(aPagos[nX][34][nImp][1],18,nDecPag)),lReq,lCadOrig,.F.},;
					{'ImpuestoP="#cVal#"',aPagos[nX][34][nImp][2],lReq,lCadOrig,.F.},;
					{'TipoFactorP="#cVal#"',aPagos[nX][34][nImp][3],lReq,lCadOrig,.F.},;
					IIf(Alltrim(aPagos[nX][34][nImp][3])=="Exento",{},{'TasaOCuotaP="#cVal#"',Str(aPagos[nX][34][nImp][4],10,6),lReq,lCadOrig,.F.}),;
					IIf(Alltrim(aPagos[nX][34][nImp][3])=="Exento",{},{'ImporteP="#cVal#"',Str(aPagos[nX][34][nImp][5],18,nDecPag),lReq,lCadOrig,.F.})})
				Next nImp

				aTotDocR := {} //Retenciones Pago
				For nImp := 1 To Len(aPagos[nX][35])
					aAdd(aTotDocR,{{'ImpuestoP="#cVal#"',aPagos[nX][35][nImp][2],lReq,lCadOrig,.F.},;
					{'ImporteP="#cVal#"',Str(aPagos[nX][35][nImp][5],18,nDecPag),lReq,lCadOrig,.F.}})
				Next nImp

				If Len(aTotDocR) > 0 .Or. Len(aTotDocT) > 0
					cAuxXml += Strtran(cIniNodo, '#cNomNodo#', cVPago + ':ImpuestosP') //Inicio del nodo de ImpuestosP

					If Len(aTotDocR) > 0 //Traslados
						cAuxXml += Strtran(cIniNodo, '#cNomNodo#', cVPago + ':RetencionesP') //Inicio del nodo de RetencionesP
						For nImp := 1 To Len(aTotDocR)
							cAuxXml += ObtNodo(aTotDocR[nImp], cNodoInf, cVPago + ':RetencionP')
						Next nImp	
						cAuxXml += Strtran(cFinNodo, '#cNomNodo#', cVPago + ':RetencionesP') //Fin del nodo de RetencionesP		
					EndIf	
					If Len(aTotDocT) > 0 //Traslados
						cAuxXml += Strtran(cIniNodo, '#cNomNodo#', cVPago + ':TrasladosP') //Inicio del nodo de TrasladosP
						For nImp := 1 To Len(aTotDocT)
							cAuxXml += ObtNodo(aTotDocT[nImp], cNodoInf, cVPago + ':TrasladoP')
						Next nImp	
						cAuxXml += Strtran(cFinNodo, '#cNomNodo#', cVPago + ':TrasladosP') //Fin del nodo de TrasladosP		
					EndIf	

					cAuxXml += Strtran(cFinNodo, '#cNomNodo#', cVPago + ':ImpuestosP') //Fin del nodo de ImpuestosP
				EndIf
			EndIf

			cAuxXml += Strtran(cFinNodo, '#cNomNodo#', cVPago + ':Pago')	 //Fin del nodo de Pago
		Next nX

		If lVCFDi40
			nTotPago := Round(nTotPago, 2)
			cCadOrig := Replace(cCadOrig, '#MontoTotalPagar#', Alltrim(Str(nTotPago)))
			cAuxXml := Replace(cAuxXml, '#MontoTotalPagar#', Alltrim(Str(nTotPago)))
			nTotPago := 0
		EndIf

		cAuxXml += Strtran(cFinNodo, '#cNomNodo#', cVPago+':Pagos')	 //Fin del nodo de Pagos

		cAuxXml += Strtran(cFinNodo, '#cNomNodo#', 'cfdi:Complemento')	 //Fin del nodo de Complemento

		cAuxXml += Strtran(cFinNodo, '#cNomNodo#', 'cfdi:Comprobante')	 //Fin del nodo de CFDI

		cCadOrig += "|"

		cSello := SellaCadena(cCadOrig)

		cAuxXml := Replace(cAuxXml, '#cSello#', cSello)
	EndIf

Return cAuxXml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³ObtNodo   ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Forma estructura del nodo                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ObtNodo(aAuxNodo, cTipoNodo, cNomNodo)
	Local cAuxNodo   := ""

	cAuxNodo := AddXML(aAuxNodo)
	cAuxNodo := Strtran(cTipoNodo, '#cValNodo#', cAuxNodo)
	cAuxNodo := Strtran(cAuxNodo, '#cNomNodo#', cNomNodo)
Return cAuxNodo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³AddXML      ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Procesa atributos para formar nodo                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AddXML(aDatos)
	Local cCadena := ""
	Local nLoop   := 0

	/*------------------------------------------
	|	1.- Nombre Atributo                     |
	|	2.- Valor                               |
	|	3.- Requerido/Opcional (.T. / .F.)      |
	|	4.- Forma Cadena original (.T. / .F.)   |
	|	5.- Usa CodHTML()                       |
	-------------------------------------------*/

	For nLoop := 1 To Len(aDatos)
		If Len(aDatos[nLoop]) > 0
	  		cCadena += AddNodo(aDatos[nLoop][1], aDatos[nLoop][2], aDatos[nLoop][3], aDatos[nLoop][4], aDatos[nLoop][5], '#cVal#' )
		EndIf
	Next
Return cCadena

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³AddNodo     ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Formatea atributos                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AddNodo(cNomAtrib, xValAtrib, lUso, lCadOr, lCodHTML, cValRep)
	Local cAtributo := ""
	Local cAuxAtrib := Replace(cNomAtrib, '="#cVal#"', '')
	Local cPictMoe	:= ""
	Local nDecimal	:= 0
	Local lAjuste := GetMv("MV_CFDI_AJ",,.T.)

	// Procesa valores tipo numerico
	If Valtype(xValAtrib) == "N"
		If cAuxAtrib $ 'Version'
			cAtributo := Transform(xValAtrib, cPictVer)
		ElseIf cAuxAtrib $ 'Monto|ImpSaldoAnt|ImpPagado|ImpSaldoInsoluto|montoTotRet'
			If !Empty(xValAtrib)
				cAtributo := Transform(xValAtrib, cPictNum)
			Else
				cAtributo := Transform(0, cPictNum)
			EndIf
		ElseIf cAuxAtrib $ 'MesIni|MesFin|Ejerc|ConceptoPago'
			If !Empty(xValAtrib)
				cAtributo := Transform(xValAtrib, cPictInt)
			ElseIf Empty(xValAtrib) .And. lUso
				//aAdd(aLogErr, {/*ORD Pago; Proveedor; Tienda; Atributo; Valor*/})
			EndIf
		ElseIf cAuxAtrib == "TipoCambioDR" .Or. cAuxAtrib == "TipoCambioP" .Or. cAuxAtrib == "EquivalenciaDR"
			If xValAtrib != 0
				If ((lVCFDi40 .And. cAuxAtrib == "TipoCambioP") .Or. cAuxAtrib == "TipoCambioDR" .Or. cAuxAtrib == "EquivalenciaDR") .And. xValAtrib == 1
					cAtributo := "1"
				Else
					cPictMoe := "@E 99,999.999999"
					nDecimal := Len( cPictMoe ) - At( ".", cPictMoe )
					If (cAuxAtrib == "TipoCambioDR" .Or. cAuxAtrib == "EquivalenciaDR") .And. Round(xValAtrib, nDecimal) < xValAtrib .And. lAjuste
						xValAtrib += Val( "0." + StrZero( 1,nDecimal, 0 ) )
					EndIf
					cAtributo := Transform(xValAtrib, STRTRAN(cPictMoe, "," ,""))
				EndIf
			EndIf
		EndIf

		IIf(lCadOr, cCadOrig += (CodHTML(cAtributo) + "|"), "") // Forma Cadena Original

		If cAuxAtrib == "TipoCambioDR" .Or. cAuxAtrib == "TipoCambioP" .Or. cAuxAtrib == "EquivalenciaDR"
			If xValAtrib != 0
				cAtributo := Strtran(cNomAtrib, cValRep, AllTrim(cAtributo)) + Space(1)
			EndIf
		Else
			cAtributo := Strtran(cNomAtrib, cValRep, AllTrim(cAtributo)) + Space(1)
		EndIf

		// Procesa valores tipo caracter
	ElseIf Valtype(xValAtrib) == "C"
		If !Empty(xValAtrib)
			If cAuxAtrib == "NumParcialidad"
				// Si parcialidad está vacío GetParcela() devuelve "0" ==> no generar atributo y tampoco cadena original
				If AllTrim(xValAtrib) != "0"
					cAtributo := Strtran(cNomAtrib, cValRep, CodHTML(xValAtrib, lCodHTML)) + Space(1)
				Else
					lCadOr := .F.
				EndIf
			ElseIf cAuxAtrib == "RfcEmisorCtaBen" .Or. cAuxAtrib == "CtaBeneficiario"
				If !Empty(xValAtrib)
					cAtributo := Strtran(cNomAtrib, cValRep, CodHTML(xValAtrib, lCodHTML)) + Space(1)
				EndIf
			ElseIf cAuxAtrib == "Nombre"
				cAtributo := StrTran(cNomAtrib, cValRep, CodHTML(xValAtrib, lCodHTML)) + Space(1)
			ElseIf cAuxAtrib == "CadPago"
				cAtributo := StrTran(cNomAtrib, cValRep, CodHTML(xValAtrib, .T.)) + Space(1)
			Else
				cAtributo := Strtran(cNomAtrib, cValRep, CodHTML(xValAtrib, lCodHTML)) + Space(1)
			EndIf
			IIf(lCadOr, cCadOrig += (CodHTML(xValAtrib) + "|"), "") // Forma Cadena Original
		EndIf
	EndIf

Return cAtributo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³LeeCert     ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Lee archivo de certificado                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LeeCert()
	Local cBuffer	:= ""
	Local nHandle
	Local cLinea    := ""
	Local cFile := &(SuperGetMv("MV_CFDDIRS",,""))+SuperGetMv("MV_CFDI_CP",,"")

	nHandle := FT_FUse(cFile)
	// Se hay error al abrir el archivo
	If  nHandle = -1
		MsgAlert(STR0005 + cFile)  //"El archivo" padron "no puede abrirse."
		return ""
	Endif
	// Se posiciona en la primera línea
	FT_FGoTop()

	While !FT_FEOF()
		cLinea := FT_FReadLn() // lee cada línea del archivo
		If Alltrim(cLinea) <> "-----BEGIN CERTIFICATE-----" .And. Alltrim(cLinea) <> "-----END CERTIFICATE-----"
			cBuffer += Alltrim(cLinea)
		EndIf
		FT_FSKIP() // Salta a siguiente línea
	End

	// Fecha o Arquivo
	FT_FUSE()

Return cBuffer

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³CreaArch    ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Crea archivo                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CreaArch(cNomArch, cExt, aResponse,jData)
	Local nHdle     := 0
	Local cDrive    := ""
	Local cNewFile  := cDir + cNomArch

	SplitPath(cNewFile,@cDrive,@cDir,@cNomArch,@cExt)
	cDir := cDrive + cDir
	Makedir(cDir)
	cNomArc := cDir + cNomArch + cExt

	nHdle := FCreate (cNomArc,0)
	If nHdle == -1
		If jData['origin'] ==  "FINA998"
			AADD(aResponse,{.F.,400,OemToAnsi(STR0007) , OemToAnsi(STR0007 + cNomArc)})
		Else
			Aviso( OemToAnsi(STR0006), OemToAnsi(STR0007 + cNomArc), {STR0008} )
		EndIf
	ElseIf jData['origin'] ==  "FINA998"
		AADD(aResponse,{.T.,200,"Archivo XML Generado"})
	EndIf
Return nHdle

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³GrabaTexto  ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion |Graba datos en archivo                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GrabaTexto(cArcXml, nHdle, lClose, lEncode)
	Default lClose := .F.
	Default lEncode := .F.

	If lEncode
		cArcXml := ENCODEUTF8(cArcXml)
	EndIf
	FWrite(nHdle, cArcXml)
	If lClose
		FClose (nHdle)
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³CodHTML     ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Caracteres HTML                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros  ³cTexto : Texto del atributo a remplazar caracteres especiales³±±
±±³            ³lCodHtml : Bandera para saber si debe realizar el remplazo.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function CodHTML(cTexto, lCodHtml)
	Local cRet := ""
	Local nChar := 0
	Default lCodHtml := .F.

	If !Empty(cTexto)
		// SUPRIMO DOBLES ESPACIOS EN BLANCO CONTENIDOS EN LA CADENA DE TEXTO
		For nChar=1 to Len(cTexto)
			If nChar<Len(cTexto)
				If Substr(cTexto,nChar,1)==" " .and. Substr(cTexto,nChar,1)==Substr(cTexto,nChar+1,1)
					Loop
				Else
					cRet:=cRet+Substr(cTexto,nChar,1)
				Endif
			Else
				cRet:=cRet+Substr(cTexto,nChar,1)
			Endif
		Next
		cRet := Alltrim(cRet)
	Endif

	If lCodHtml
		cRet := Replace(cRet, '&', '&amp;')
		cRet := Replace(cRet, "‘", '&apos;')
		cRet := Replace(cRet, '"', '&quot;')
		cRet := Replace(cRet, '<', '&lt;')
		cRet := Replace(cRet, '>', '&gt;')
		cRet := Replace(cRet, '|', '&#124;')
	EndIf

	cRet := EncodeUtf8(cRet)

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³GetInfo     ³ Autor ³ Raul Ortiz  Medina  ³ Fecha ³25/05/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Obtiene el Timbre Fiscal                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetInfo(cpCli, cpLoja, cpDoc, cTipo, cUUID, cPrefixo, cFilOri)
	Local cTipDoc       := "NF|NDC"
	Local cSeek         := ""
	Local nIndSF2       := 0
	Default cpCli		:= ""
	Default cpLoja		:= ""
	Default cpDoc		:= ""
	Default cTipo		:= ""
	Default cUUID		:= ""
	Default cPrefixo	:= ""
	Default cFilOri		:= ""

	If Alltrim(cPrefixo) == Alltrim(cSerLoja)
		cSeek   := cpDoc + cPrefixo
		nIndSF2 := 1 //F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO
	Else
		cSeek   := cpCli + cpLoja + cpDoc + cPrefixo
		nIndSF2 := 2 //F2_FILIAL + F2_CLIENTE + F2_LOJA + F2_DOC + F2_SERIE
	EndIf

	If !Empty(cTipDocPE)
		cTipDoc += cTipDocPE
	EndIf

	If cTipo $ cTipDoc
		If Empty(cFilOri)
			cFilOri := xFilial("SF2")
		EndIf
		DbSelectArea("SF2")
		SF2->(DbSetOrder(nIndSF2))
		If SF2->(DbSeek( cFilOri + cSeek))
			cUUID := SF2->F2_UUID
		EndIf
	Else
		If Empty(cFilOri)
			cFilOri := xFilial("SF1")
		EndIf
		DbSelectArea("SF1")
		SF1->(DbSetOrder(2))//F1_FILIAL+F1_FORNECE+F1_LOJA+F1_DOC
		If SF1->(DbSeek(cFilOri + cSeek + cPrefixo))
			cUUID := SF1->F1_UUID
		EndIf
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³GetSaldo    ³ Autor ³ Raul Ortiz  Medina  ³ Fecha ³25/05/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³ obtiene los saldos de la suma del campo E1_valor            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetSaldo(cPrefixo, cNum, cParcela, cTipo, cCli, cLoja, nValBru, cRecibo, cFilOri)
	Local aArea			:= GetArea()
	Local nSaldo		:= 0
	Local aFilAct		:= FWLoadSM0()
	Local aFilEmp       := {}
	Local nI        	:= 0
	Local nValRec		:= 0
	Local cFlactD		:= ""


	dbSelectArea("SEL")
	SEL->(DbSetOrder(8)) //EL_FILIAL + EL_SERIE + EL_RECIBO + EL_TIPODOC + EL_PREFIXO + EL_NUMERO + EL_PARCELA + EL_TIPO

	dbSelectArea("SE5")
	SE5->(dbSetOrder(18)) //E5_FILIAL + E5_PREFIXO + E5_NUMERO + E5_BANCO + E5_MOEDA

	If FWModeAccess("SE5",3) == "C" //sucursal Compartida
		cFlactD := XFILIAL("SE5")// sucursal
		Aadd(aFilEmp , cFlactD)
	Else
		For nI := 1 To Len(aFilAct)
			If aFilAct[nI][1] == cEmpAnt //Código de Grupo de Empresas
				Aadd(aFilEmp , aFilAct[nI][2])
			EndIf
		Next nI
	EndIf

	For nI := 1 To Len(aFilEmp)
		If SE5->(dbSeek(aFilEmp[nI] + cPrefixo + cNum))
			Do While SE5->(!EOF()) .And. E5_FILIAL + SE5->E5_PREFIXO + SE5->E5_NUMERO == aFilEmp[nI] + cPrefixo + cNum
				If SE5->E5_FILORIG == cFilOri .And. !(SE5->E5_SITUACA == "C") .And. SE5->E5_TIPO == cTipo .And. !(SE5->E5_MOTBX == "CEC" .And. Trim(SE5->E5_ORIGEM) == "FINA450")
					If SEL->(DbSeek(SE5->E5_FILIAL + SE5->E5_SERREC + SE5->E5_ORDREC))
						If !EMPTY(SEL->EL_FECTIMB) .And. !EMPTY(SEL->EL_UUID) .And. !(E5_TIPODOC $ "DC|MT|JR") .And. !SEL->EL_CANCEL .Or. (SEL->EL_GENCFD == 'N')
							nValRec := SE5->E5_VALOR + SE5->E5_VLDESCO - SE5->E5_VLJUROS - SE5->E5_VLMULTA
							nSaldo += nValRec
						EndIf
					EndIf
				ElseIf SE5->E5_FILORIG == cFilOri .And. !(SE5->E5_SITUACA == "C") .And. SE5->E5_TIPO == cTipo .And. SE5->E5_RECPAG == "R" .And. SE5->E5_MOTBX == "CEC" .And. Trim(SE5->E5_ORIGEM) == "FINA450"
					If SEL->(DbSeek(SE5->E5_FILIAL + SE5->E5_SERCMP + SE5->E5_RECCMP))
						If !EMPTY(SEL->EL_FECTIMB) .And. !EMPTY(SEL->EL_UUID) .And. !(E5_TIPODOC $ "DC|MT|JR") .And. !SEL->EL_CANCEL .Or. (SEL->EL_GENCFD == 'N')
							nValRec := SE5->E5_VALOR + SE5->E5_VLDESCO - SE5->E5_VLJUROS - SE5->E5_VLMULTA
							nSaldo += nValRec
						EndIf
					ElseIf !(SE5->E5_TIPODOC $ "DC|MT|JR|CM") .And. !(SE5->E5_SITUACA == "X") .And. F087AValCo(SE5->E5_IDENTEE, SE5->E5_DATA, .T.)
						nValRec := SE5->E5_VALOR + SE5->E5_VLDESCO - SE5->E5_VLJUROS - SE5->E5_VLMULTA
						nSaldo += nValRec
					EndIf
				EndIf
				SE5->(DbSkip())
			EndDo
		EndIf
	Next nI

	nSaldo := nValBru - nSaldo

	RestArea(aArea)

Return nSaldo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³GetBanco    ³ Autor ³ Raul Ortiz  Medina  ³ Fecha ³25/05/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Obtiene los datos del banco y los regresa por referencia     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetBanco(cBanco, cAgencia, cNumCta, cRFC, cCuenta, cNome, lOrd)

	Local cRFCExt := "XEXX010101000"

	Default cBanco		:= ""
	Default cAgencia	:= ""
	Default cRFC		:= ""
	Default cCuenta		:= ""
	Default cNome		:= ""
	Default lOrd		:= .F. // Banco Ordenante

	cRFC    := ""
	cCuenta := ""

	DBSelectArea("SA6")
	SA6->(DBSetOrder(1))//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
	If SA6->(DBSeek(xFilial("SA6") + cBanco + cAgencia + cNumCta))
		If AllTrim(SA6->A6_EST) == "EX"
			If lOrd
				cNome := SA6->A6_NOME
				cRFC  := cRFCExt
			EndIf
		Else
			cCuenta := SA6->A6_NUMCON
			cRFC := SA6->A6_CGC
		EndIf
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³DistSal     ³ Autor ³ Raul Ortiz  Medina  ³ Fecha ³25/05/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Realiza la separación de pagos y documentos pagados          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DistSal(cNumero, cSerie, aPagos, aImp, nDecPag)
	Local aDocs		:= {}
	Local cPagSat	:= ""
	Local cFilSEL	:= xFilial("SEL")
	Local cFilSF2	:= xFilial("SF2")
	Local cFilSF1	:= xFilial("SF1")
	Local cFilOri	:= ""
	Local nTasaD	:= 1
	Local cTipos    := "NF|NDC"
	Local lNFOri    := .F.
	Local cDocSel   := ""
	Local cSerSel   := ""
	Local nValBru   := 0
	Local aCompensa	:= {}
	Local lCompen	:= .F.
	Local nLenPagos	:= 0
	Local lFactor	:= (cPaisLoc == "MEX" .And. SuperGetMv("MV_CFDI33",.F.,.F.) .And. SEL->(FieldPos("EL_FACTOR")) > 0)
	Local nValRec	:= 0
	Local aDocsAux  := {}
	Local nX        := 0
	Local aCompAux  := {}
	Local lHraPag	:= SEL->(ColumnPos("EL_HRPAGO")) > 0

	Default cNumero	:= ""
	Default cSerie	:= ""
	Default aPagos	:= {}
	Default aImp	:= {}
	Default nDecPag := 2

	If !Empty(cTipDocPE)
		cTipos += cTipDocPE
	EndIf

	DbSelectArea("SEL")
	SEL->(DbSetOrder(8))//EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
	If SEL->(DbSeek(cFilSEL + cSerie + cNumero))
		While !(SEL->(EOF())) .And. SEL->(EL_FILIAL + EL_SERIE + EL_RECIBO  ) == cFilSEL + cSerie + cNumero
			nValBru := 0
			nValRec := 0
			If !Empty(AllTrim(SEL->EL_FORPGO))
				aAdd(aPagos,{SEL->EL_FILIAL,SEL->EL_RECIBO,SEL->EL_NUMERO,SEL->EL_PREFIXO,SEL->EL_PARCELA,SEL->EL_TIPO,SEL->EL_TIPODOC,SEL->EL_EMISSAO,SEL->EL_CLIORIG,SEL->EL_LOJORIG,SEL->EL_MOEDA,SEL->EL_VALOR,{Iif(SEL->EL_TXMOEDA == 0, 1, SEL->EL_TXMOEDA),SEL->EL_TXMOE02,SEL->EL_TXMOE03,SEL->EL_TXMOE04,SEL->EL_TXMOE05},{},SEL->EL_VALOR,0,SEL->EL_BANCO,SEL->EL_AGENCIA,SEL->EL_CONTA,SEL->EL_BCOCHQ,SEL->EL_AGECHQ,SEL->EL_CTACHQ,SEL->(RECNO()),SEL->EL_SERIE,SEL->EL_FORPGO,SEL->EL_RFCEMI,SEL->EL_CTAORD,SEL->EL_CEPTIP,SEL->EL_CEPCER,SEL->EL_CEPCAD,SEL->EL_CEPSEL,SEL->EL_CTABEN,Iif(lHraPag,SEL->EL_HRPAGO,""),Nil,Nil})

				If AllTrim(SEL->EL_TIPO) == "CO" .And. FindFunction("F087InfCom") .And. SEL->(ColumnPos("EL_IDENTEE")) > 0 .And. SEL->(ColumnPos("EL_FCHIDEN")) > 0
					If !Empty(SEL->EL_IDENTEE) .And. !Empty(SEL->EL_FCHIDEN)
						aCompensa := {}
						F087InfCom(SEL->EL_IDENTEE, SEL->EL_FCHIDEN,.T.,@aCompensa)
						for nX := 1 to Len(aCompensa)
							DocsComp(aCompensa[nX], aDocs)
						next
					EndIf
				EndIf

			Else
				fGetFilOri(SEL->EL_RECIBO,SEL->EL_NUMERO,SEL->EL_PREFIXO,SEL->EL_PARCELA,SEL->EL_TIPO,SEL->EL_SERIE,@cFilOri)
				If AllTrim(SEL->EL_TIPO) $ cTipos
					If Empty(cFilOri)
						cFilOri := cFilSF2
					EndIf
					If Alltrim(F815OriSE1(SEL->EL_PREFIXO, SEL->EL_NUMERO)) == "LOJA701"
						dbSelectArea("SF2")
						SF2->(DbSetOrder(6)) //F2_FILIAL + F2_SERIORI + F2_NFORI
						If SF2->(DbSeek(xFilial("SF2") + SEL->EL_PREFIXO + SEL->EL_NUMERO))
							lNFOri := .T.
							nTasaD := SF2->F2_TXMOEDA
							nValBru := SF2->F2_VALBRUT
							fObtFilSE4(cFilOri, @cPagSat)
							cDocSel := SF2->F2_DOC
							cSerSel := SF2->F2_SERIE
						EndIf
						If !lNFOri
							DbSelectArea("SF2")
							SF2->(DbSetOrder(1)) //F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO
							If SF2->(DbSeek((cFilOri + SEL->EL_NUMERO + SEL->EL_PREFIXO)))
								nTasaD := SF2->F2_TXMOEDA
								nValBru := SF2->F2_VALBRUT
								fObtFilSE4(cFilOri, @cPagSat)
							EndIf
							cDocSel := SEL->EL_NUMERO
							cSerSel := SEL->EL_PREFIXO
						EndIf
					Else
						DbSelectArea("SF2")
						SF2->(DbSetOrder(2)) //F2_FILIAL + F2_CLIENTE + F2_LOJA + F2_DOC + F2_SERIE
						If SF2->(DbSeek((cFilOri + SEL->EL_CLIORIG + SEL->EL_LOJORIG + SEL->EL_NUMERO + SEL->EL_PREFIXO)))
							nTasaD := SF2->F2_TXMOEDA
							nValBru := SF2->F2_VALBRUT
							fObtFilSE4(cFilOri, @cPagSat)
						EndIf
						cDocSel := SEL->EL_NUMERO
						cSerSel := SEL->EL_PREFIXO
					EndIf

					nValRec := SEL->EL_DESCONT - SEL->EL_JUROS - SEL->EL_MULTA
					aAdd(aDocs,{SEL->EL_FILIAL,SEL->EL_RECIBO,cDocSel,cSerSel,SEL->EL_PARCELA,SEL->EL_TIPO,SEL->EL_TIPODOC,SEL->EL_EMISSAO,SEL->EL_CLIORIG,SEL->EL_LOJORIG,SEL->EL_MOEDA,SEL->EL_VALOR,{Iif(SEL->EL_TXMOEDA == 0, 1, SEL->EL_TXMOEDA),SEL->EL_TXMOE02,SEL->EL_TXMOE03,SEL->EL_TXMOE04,SEL->EL_TXMOE05},SEL->EL_VALOR,0,cPagSat,nValBru,SEL->EL_CLIENTE,SEL->EL_LOJA,nTasaD,nValRec, Nil, Nil,cFilOri})

					If lFactor
						If SEL->(EL_FACTOR == "1" .And. EL_COMPEN > 0)
							// Leer datos para nodo de cobro por compensación entre carteras ==> Factoraje Financiero
							aCompensa := FA815Comp(cFilOri, SEL->EL_CLIORIG, SEL->EL_LOJORIG, SEL->EL_PREFIXO, SEL->EL_NUMERO, SEL->EL_PARCELA, SEL->EL_TIPO, cNumero, cSerie)
							aAdd(aDocsAux,{SEL->EL_FILIAL,SEL->EL_RECIBO,cDocSel,cSerSel,SEL->EL_PARCELA,SEL->EL_TIPO,SEL->EL_TIPODOC,SEL->EL_EMISSAO,SEL->EL_CLIORIG,SEL->EL_LOJORIG,aCompensa[6],aCompensa[5],{Iif(aCompensa[3] == 0, 1, aCompensa[3]),SEL->EL_TXMOE02,SEL->EL_TXMOE03,SEL->EL_TXMOE04,SEL->EL_TXMOE05},aCompensa[5],0,cPagSat,nValBru,SEL->EL_CLIENTE,SEL->EL_LOJA,nTasaD,0})
							lCompen := .T.
						EndIf
					EndIf

				ElseIf AllTrim(SEL->EL_TIPO) $ "NCC"
					If Empty(cFilOri)
						cFilOri := cFilSF1
					EndIf
					DbSelectArea("SF1")
					SF1->(DbSetOrder(2)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
					If SF1->(DbSeek((cFilOri + SEL->EL_NUMERO + SEL->EL_PREFIXO + SEL->EL_CLIORIG + SEL->EL_LOJORIG  )))
						nTasaD := SF1->F1_TXMOEDA
						nValBru := SF1->F1_VALBRUT
						fObtFilSE4(cFilOri, @cPagSat)
					EndIf
					nValRec := SEL->EL_DESCONT - SEL->EL_JUROS - SEL->EL_MULTA
					aAdd(aDocs,{SEL->EL_FILIAL,SEL->EL_RECIBO,SEL->EL_NUMERO,SEL->EL_PREFIXO,SEL->EL_PARCELA,SEL->EL_TIPO,SEL->EL_TIPODOC,SEL->EL_EMISSAO,SEL->EL_CLIORIG,SEL->EL_LOJORIG,SEL->EL_MOEDA,SEL->EL_VALOR,{Iif(SEL->EL_TXMOEDA == 0, 1, SEL->EL_TXMOEDA),SEL->EL_TXMOE02,SEL->EL_TXMOE03,SEL->EL_TXMOE04,SEL->EL_TXMOE05},SEL->EL_VALOR,0,cPagSat,nValBru,SEL->EL_CLIENTE,SEL->EL_LOJA,nTasaD,nValRec})
				EndIf
				If lCompen
					aAdd(aCompAux, aClone(aCompensa))
					aCompensa := { CtoD(""), "", 0, 0, 0 }
					lCompen := .F.
				EndIf
			EndIf

			SEL->(DbSkip())
		EndDo
	EndIf

	For nX := 1 To Len(aCompAux)
		nPos := aScan(aPagos,{|x| Alltrim(x[25]) == "17" .And. Alltrim(x[11]) == aCompAux[nX][2]})
		If nPos == 0
			nLenPagos := Len(aPagos)
			aAdd(aPagos,aClone(aPagos[nLenPagos])) // {SEL->EL_FILIAL,SEL->EL_RECIBO,SEL->EL_NUMERO,SEL->EL_PREFIXO,SEL->EL_PARCELA,SEL->EL_TIPO,SEL->EL_TIPODOC,SEL->EL_EMISSAO,SEL->EL_CLIORIG,SEL->EL_LOJORIG,aCompensa[2],aCompensa[4],{Iif(aCompensa[3] == 0, 1, aCompensa[3]),SEL->EL_TXMOE02,SEL->EL_TXMOE03,SEL->EL_TXMOE04,SEL->EL_TXMOE05},{},aCompensa[4],0,"","","","","","",SEL->(RECNO()),SEL->EL_SERIE,"17",SEL->EL_RFCEMI,"","","","","",""})
			++nLenPagos
			aPagos[nLenPagos,03]	:= ""			// Numero
			aPagos[nLenPagos,04]	:= ""			// Serie
			aPagos[nLenPagos,05]	:= ""			// Parcialidad
			aPagos[nLenPagos,11]	:= aCompAux[nX][2] // Moneda
			aPagos[nLenPagos,12]	:= aCompAux[nX][4] // Valor
			aPagos[nLenPagos,13,1]	:= Iif(aCompAux[nX][2] == "01", 1, aCompAux[nX][3])	// Tasa moneda
			aPagos[nLenPagos,15]	:= aCompAux[nX][4] // Valor
			aPagos[nLenPagos,17]	:= ""			// Banco
			aPagos[nLenPagos,18]	:= ""			// Agencia
			aPagos[nLenPagos,19]	:= ""			// Cuenta
			aPagos[nLenPagos,20]	:= ""			// Banco Ch
			aPagos[nLenPagos,21]	:= ""			// Agencia Ch
			aPagos[nLenPagos,22]	:= ""			// Cuenta Ch
			aPagos[nLenPagos,25]	:= "17"			// Forma de Pago SAT = Compensación
			aPagos[nLenPagos,27]	:= ""			// Cta Ord
			aPagos[nLenPagos,28]	:= ""			// Tipo CEP
			aPagos[nLenPagos,29]	:= ""			// Certificado CEP
			aPagos[nLenPagos,30]	:= ""			// Cadena CEP
			aPagos[nLenPagos,31]	:= ""			// Sello CEP
			aPagos[nLenPagos,32]	:= ""			// Cta Ben
		Else
			aPagos[nPos,12]	+= IIf(aCompAux[nX][5] <> aCompAux[nX][4], aCompAux[nX][5], aCompAux[nX][4])	// Valor //xMoeda(aCompAux[nX][4],1,Val(aCompAux[nX][2]),,nDecimal,aCompAux[nX][2],xMoeda(aCompAux[nX][3]))	// Valor
			aPagos[nPos,15]	+= IIf(aCompAux[nX][5] <> aCompAux[nX][4], aCompAux[nX][5], aCompAux[nX][4])	// Valor //xMoeda(aCompAux[nX][4],1,Val(aCompAux[nX][2]),,nDecimal,aCompAux[nX][2],xMoeda(aCompAux[nX][3]))	// Valor
		EndIf
	Next nX

	For nX := 1 To Len(aDocsAux)
		aAdd(aDocs,{aDocsAux[nX][1],aDocsAux[nX][2],aDocsAux[nX][3],aDocsAux[nX][4],aDocsAux[nX][5],aDocsAux[nX][6],aDocsAux[nX][7],aDocsAux[nX][8],aDocsAux[nX][9],aDocsAux[nX][10],aDocsAux[nX][11],aDocsAux[nX][12],aDocsAux[nX][13],aDocsAux[nX][14],aDocsAux[nX][15],aDocsAux[nX][16],aDocsAux[nX][17],aDocsAux[nX][18],aDocsAux[nX][19],aDocsAux[nX][20],aDocsAux[nX][21],Nil,Nil,cFilOri})
	Next nX

	AjustSal(@aPagos,aDocs,nDecPag)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³AjustSal    ³ Autor ³ Raul Ortiz  Medina  ³ Fecha ³25/05/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Realiza la distribución de saldo entre los pagos             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustSal(aPagos,aDocs,nDecPag)
	Local nI := 0
	Local nJ := 0
	Local nMoedaP := 0
	Local nMoedaD := 0
	Local nValMoeP := 0
	Local nValMoeD := 0
	Local cPictMoe := ""
	Local nDecimal := 0
	Local aNodoTras := {}
	Local aNodoRet  := {}
	Local nImp       := 0
	Local cMoedaSATP := ""
	Local nTpCamP    := 0

	Private aTotImpT := {} 
	Private aTotImpR := {}
	Private nPosDoc  := 0
	Private cFilCTO  := xFilial("CTO")

	For nI := 1 To Len(aPagos)
		aTotImpT := {}
		aTotImpR := {}
		nMoedaP :=  Val(SubStr(Alltrim(aPagos[nI][11]),-1,1))
		//Mondeda SAT Pago
		cMoedaSATP := F815MOEDA(cFilCTO,StrZero(nMoedaP,2))				

		If AllTrim(cMoedaSATP) != "MXN"
			nTpCamP := aPagos[nI][_MOEDAS][Val(aPagos[nI][_MOEDA])]
		Else
			nTpCamP := 1
		EndIf
		For nJ := 1 To Len(aDocs)
			If aPagos[nI][15] == 0
				Exit
			EndIf
			
			nMoedaD :=  Val(SubStr(Alltrim(aDocs[nJ][11]),-1,1))

			If nMoedaP == nMoedaD
				If aDocs[nJ][14] > 0
					If aDocs[nJ][14] >= aPagos[nI][15]
						aDocs[nJ][14] -= aPagos[nI][15]
						aDocs[nJ][15] := aPagos[nI][15]
						aPagos[nI][15] -= aPagos[nI][15]
						If lVCFDi40
							F815IMPDOC(aDocs[nJ][3], aDocs[nJ][4], aDocs[nJ][9], aDocs[nJ][10], aDocs[nJ][15], @aNodoTras, @aNodoRet,nMoedaP,nMoedaD,aPagos, nI, aDocs[nJ][24], cMoedaSATP, nTpCamP, nDecPag)
							aDocs[nJ][22] := aNodoTras
							aDocs[nJ][23] := aNodoRet
							aPagos[nI][34] := aTotImpT
							aPagos[nI][35] := aTotImpR
						EndIf
						Aadd(aPagos[nI][14],AClone(aDocs[nJ]))
						aDocs[nJ][21] := 0
						Exit
					ElseIf aPagos[nI][15] > aDocs[nJ][14]
						aPagos[nI][15] -= aDocs[nJ][14]
						aDocs[nJ][15] := aDocs[nJ][14]
						If lVCFDi40
							F815IMPDOC(aDocs[nJ][3], aDocs[nJ][4], aDocs[nJ][9], aDocs[nJ][10], aDocs[nJ][15], @aNodoTras, @aNodoRet, nMoedaP, nMoedaD, aPagos, nI, aDocs[nJ][24], cMoedaSATP, nTpCamP, nDecPag)
							aDocs[nJ][22] := aNodoTras
							aDocs[nJ][23] := aNodoRet
							aPagos[nI][34] := aTotImpT
							aPagos[nI][35] := aTotImpR
						EndIf
						aDocs[nJ][14] -= aDocs[nJ][14]
						Aadd(aPagos[nI][14],AClone(aDocs[nJ]))
					EndIf
				EndIf
			Else
				If aDocs[nJ][14] > 0
					nValMoeP := aPagos[nI][15]
					If nMoedaD == 1
						cPictMoe := PESQPICT("SEL","EL_TXMOEDA")
					Else
						cPictMoe := PESQPICT("SEL","EL_TXMOE0" + ALLTRIM(str(nMoedaD)))
					EndIf
					nDecimal := Len( cPictMoe ) - At( ".", cPictMoe )
					nValMoeD := ROUND( ( aDocs[nJ][13][nMoedaD] /  aPagos[nI][13][nMoedaP] ) * aDocs[nJ][14] ,nDecimal)
					If nValMoeD >= nValMoeP
						aDocs[nJ][14] -= xMoeda(nValMoeP,nMoedaP,nMoedaD,,nDecimal,aPagos[nI][13][nMoedaP], aDocs[nJ][13][val(aDocs[nJ][11])])
						aDocs[nJ][15] := xMoeda(nValMoeP,nMoedaP,nMoedaD,,nDecimal,aPagos[nI][13][nMoedaP], aDocs[nJ][13][val(aDocs[nJ][11])])
						aPagos[nI][15] -= nValMoeP
						If lVCFDi40
							F815IMPDOC(aDocs[nJ][3], aDocs[nJ][4], aDocs[nJ][9], aDocs[nJ][10], aDocs[nJ][15], @aNodoTras, @aNodoRet, nMoedaP, nMoedaD, aPagos, nI, aDocs[nJ][24], cMoedaSATP, nTpCamP, nDecPag)
							aDocs[nJ][22] := aNodoTras
							aDocs[nJ][23] := aNodoRet
							aPagos[nI][34] := aTotImpT
							aPagos[nI][35] := aTotImpR
						EndIf
						Aadd(aPagos[nI][14],AClone(aDocs[nJ]))
						aDocs[nJ][21] := 0
						Exit
					ElseIf nValMoeP > nValMoeD
						aPagos[nI][15] -= ROund(nValMoeD,2)
						aDocs[nJ][15] := xMoeda(nValMoeD,nMoedaP,nMoedaD,,nDecimal,aPagos[nI][13][nMoedaP], aDocs[nJ][13][val(aDocs[nJ][11])])
						aDocs[nJ][14] := nValMoeD
						aDocs[nJ][14] -= aDocs[nJ][14]
						If lVCFDi40
							F815IMPDOC(aDocs[nJ][3], aDocs[nJ][4], aDocs[nJ][9], aDocs[nJ][10], aDocs[nJ][15], @aNodoTras, @aNodoRet, nMoedaP, nMoedaD, aPagos, nI, aDocs[nJ][24], cMoedaSATP, nTpCamP, nDecPag)
							aDocs[nJ][22] := aNodoTras
							aDocs[nJ][23] := aNodoRet
							aPagos[nI][34] := aTotImpT
							aPagos[nI][35] := aTotImpR
						EndIf
						Aadd(aPagos[nI][14],AClone(aDocs[nJ]))
						aDocs[nJ][14] := (aDocs[nJ][14] * aPagos[nI][13][nMoedaP]) / aDocs[nJ][13][nMoedaD]
					EndIf
				EndIf
			EndIf
			aDocs[nJ][21] := 0
		Next nJ
		//Total Traslados para el Pago
		If lVCFDi40
		For nImp := 1 To Len(aPagos[nI][34])
			If aPagos[nI][34][nImp][3] == "Exento"
				nTotBExe += Round(xMoeda(Round(aPagos[nI][34][nImp][1],IIf(nMoedaP<>1,2,6)),nMoedaP,1,,6,nTpCamP),2)
			Else
				If aPagos[nI][34][nImp][4] == 0.00
					nTotBase0 += Round(xMoeda(Round(aPagos[nI][34][nImp][1],IIf(nMoedaP<>1,nDecPag,6)),nMoedaP,1,,6,nTpCamP),2)
				ElseIf aPagos[nI][34][nImp][4] == 0.08
					nTotBase8 += Round(xMoeda(Round(aPagos[nI][34][nImp][1],IIf(nMoedaP<>1,nDecPag,6)),nMoedaP,1,,6,nTpCamP),2)
					nTotImp8 += Round(xMoeda(Round(aPagos[nI][34][nImp][5],IIf(nMoedaP<>1,nDecPag,6)),nMoedaP,1,,6,nTpCamP),2)
				ElseIf aPagos[nI][34][nImp][4] == 0.16
					nTotBase16 += Round(xMoeda(Round(aPagos[nI][34][nImp][1],IIf(nMoedaP<>1,nDecPag,6)),nMoedaP,1,,6,nTpCamP),2)
					nTotImp16 += Round(xMoeda(Round(aPagos[nI][34][nImp][5],IIf(nMoedaP<>1,nDecPag,6)),nMoedaP,1,,6,nTpCamP),2)
				EndIf
			EndIf
		Next nImp
		//Total Retenciones para el Pago
		For nImp := 1 To Len(aPagos[nI][35])
			nTotRetIVA += Round(xMoeda(Round(aPagos[nI][35][nImp][5],IIf(nMoedaP<>1,nDecPag,6)),nMoedaP,1,,6,nTpCamP),2)
		Next nImp
		ENDIF
	Next nI
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³GetParcela  ³ Autor ³ Raul Ortiz  Medina  ³ Fecha ³25/05/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Conversión de parcela a numero                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetParcela(cNumero,cPrefijo,cTipo,cFilOri)
	Local aArea			:= GetArea()
	Local nCantRec		:= 0
	Local aFilAct		:= FWLoadSM0()
	Local aFilEmp       := {}
	Local nI        	:= 0
	Local cFlactD		:= ""
	Local cOutParc  	:= ""
	Default cNumero 	:= ""
	Default cPrefijo	:= ""
	Default cTipo		:= ""
	Default cFilOri     := ""

	dbSelectArea("SEL")
	SEL->(DbSetOrder(8)) //EL_FILIAL + EL_SERIE + EL_RECIBO + EL_TIPODOC + EL_PREFIXO + EL_NUMERO + EL_PARCELA + EL_TIPO

	dbSelectArea("SE5")
	SE5->(dbSetOrder(18)) //E5_FILIAL + E5_PREFIXO + E5_NUMERO + E5_BANCO + E5_MOEDA

	If FWModeAccess("SE5",3) == "C" //sucursal Compartida
		cFlactD := XFILIAL("SE5")// sucursal
		Aadd(aFilEmp , cFlactD)
	Else
		For nI := 1 To Len(aFilAct)
			If aFilAct[nI][1] == cEmpAnt //Código de Grupo de Empresas
				Aadd(aFilEmp , aFilAct[nI][2])
			EndIf
		Next nI
	EndIf

	For nI := 1 To Len(aFilEmp)
		If SE5->(MsSeek(aFilEmp[nI] + cPrefijo + cNumero))
			Do While SE5->(!EOF()) .And. E5_FILIAL + SE5->E5_PREFIXO + SE5->E5_NUMERO == aFilEmp[nI] + cPrefijo + cNumero
				If SE5->E5_FILORIG == cFilOri .And. SE5->E5_TIPO == cTipo .And. !(SE5->E5_MOTBX == "CEC" .And. Trim(SE5->E5_ORIGEM) == "FINA450")
					If SEL->(MsSeek(SE5->E5_FILIAL + SE5->E5_SERREC + SE5->E5_ORDREC))
						If !EMPTY(SEL->EL_FECTIMB) .And. !EMPTY(SEL->EL_UUID) .And. !(E5_TIPODOC $ "DC|MT|JR") .And. !(SEL->EL_GENCFD == 'N')
							nCantRec += 1
						EndIf
					EndIf
				EndIf
				SE5->(DbSkip())
			EndDo
		EndIf
	Next nI

	cOutParc := Alltrim(STR(nCantRec + 1))

	RestArea(aArea)

Return cOutParc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³SellaCadena ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Crea sello con la cadena original                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SellaCadena(cCadena)
	Local cSello := ""

	cSello := EVPDigest(cCadena, 5)
	cSello := PrivSignRSA(&(SuperGetMv("MV_CFDDIRS", , "")) + SuperGetMv("MV_CFDARQS", , ""), cSello, 6, "assinatura")
	cSello := ENCODE64(cSello)
Return cSello

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función    ³CFDiRecPag³ Autor ³Roberto Gonzalez Rivas³ Fecha³ 28/07/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Timbrado de CFDi con complemento de recepcion de pagos.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ CfdiRecPag( aRecibos , lTimbrar )                         ³±±
±±³           ³ aRecibos : Matriz de recibos a timbrar/cancelar           ³±±
±±³           ³ lTimbrar : .T. = Timbrar, .F. = Cancelar CFDI             ³±±
±±³Retorno    ³ lRet : .T. = ok, .F. = Error                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ FISA815                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CFDiRecPag(aRecibos, lTimbrar, aResponse,jData,cUUIDSus)
	Local cRutaSmr := &(SuperGetmv( "MV_CFDSMAR" , .F. , "GetClientDir()" ))	// Ruta local en donde se procesarán los archivos
	Local cCFDiUsr := SuperGetmv( "MV_CFDI_US" , .F. , "" )						// Usuario del servicio web
	Local cCFDiCon := SuperGetmv( "MV_CFDI_CO" , .F. , "" )						// Contraseña del servicio web
	Local cCFDiPAC := SuperGetmv( "MV_CFDI_PA" , .F. , "" )						// Rutina a ejecutar (PAC)
	Local cCFDiAmb := SuperGetmv( "MV_CFDI_AM" , .F. , "T" )					// Ambiente (Teste o Produccion)
	Local cCFDiPub := SuperGetmv( "MV_CFDI_CE" , .F. , "" )						// Archivo de llave pública (.cer)
	Local cCFDiPri := SuperGetmv( "MV_CFDI_PX" , .F. , "" )						// Archivo de llave privada (.key)
	Local cCFDiCve := SuperGetmv( "MV_CFDI_CL" , .F. , "" )						// Clave de llave privada para autenticar WS
	Local nCFDiCmd := SuperGetmv( "MV_CFDICMD" , .F. , 0 )						// Mostrar ventana de comando del Shell: 0=no, 1=si
	Local lProxySr := SuperGetmv( "MV_PROXYSR" , .F. , .F. )					// Emplear Proxy Server?
	Local cProxyIP := SuperGetmv( "MV_PROXYIP" , .F. , "" )						// IP del Proxy Server
	Local nProxyPt := SuperGetmv( "MV_PROXYPT" , .F. , 0 )						// Puerto del Proxy Server
	Local lProxyAW := SuperGetmv( "MV_PROXYAW" , .F. , .F. )					// Autenticación en Proxy Server con credenciales de Windows?
	Local cProxyUr := SuperGetmv( "MV_PROXYUR" , .F. , "" )						// Usuario para autenticar Proxy Server
	Local cProxyPw := SuperGetmv( "MV_PROXYPW" , .F. , "" )						// Clave para autenticar Proxy Server
	Local cProxyDm := SuperGetmv( "MV_PROXYDM" , .F. , "" )						// Dominio para autenticar Proxy Server
	Local lCancCFDI:= SuperGetmv( "MV_CFDICAN" , .F. , .F. )					// Nuevo esquema de cancelación en uso?
	Local cCancela := IIf(lCancCFDI, "S", "C")
	Local cNameCFDI:= ""
	Local cRutina  := "Timbrado" + Trim(cCFDiPAC) + ".exe "
	Local cParametros := ""
	Local cProxy   := "[PROXY]"
	Local cIniFile := "TimbradoCFDi.ini" //"TimbradoCFDi.ini"
	Local cBatch   := "Timbrado.bat" //"Timbrado.bat"
	Local nHandle  := 0
	Local nLoop    := 0
	Local nOpc     := 0
	Local lRet     := .F.
	Local cRutaCFDI	:= cRutaSmr + "Recibos\"
	Local nCanc		:= 0
	Local lHTML		:= GetRemoteType() == 5
	Local lTimbWeb	:= .F.
	Local cRutaExe	:= ""
	Local tUUID		:= ""
	Local cTexto    := ""

	Private cError		:= ""  //Contiene el numero de error
	Private cDetalle	:= ""  //Contiene el detalle del error, cuando el timbre no es generado
	Private cUUID		:= ""
	Private cFechaTim	:= ""

	Default lTimbrar	:= .T.
	Default jData		:= JsonObject():New()

	If jData['origin'] == "FINA998" .and. lTimbrar
		tUUID := F815UUIDRe( jData['serie'], jData['recibo'])
		IF !VAZIO(tUUID)
			Return .T.
		EndIF
	ENDIF

	If Empty(cRutaSmr) .Or. Empty(cCFDiUsr) .Or. Empty(cCFDiCon) .Or. Empty(cCFDiPAC)
		If jData['origin'] ==  "FINA998"
			AADD(aResponse,{.F.,400,OemToAnsi(STR0015) , OemToAnsi(STR0016)})
		Else
			Aviso(OemToAnsi(STR0015), OemToAnsi(STR0016), {OemToAnsi(STR0008)})  // Faltan parámetros por definir para este proceso
			Return lRet
		EndIf
	Endif

	// Valida ruta de alojamiento del ejecutable de timbrado
	If !(cRutaSmr == Strtran(cRutaSmr, " " ))
		If jData['origin'] ==  "FINA998"
			AADD(aResponse,{.F.,400,OemToAnsi(STR0015) , OemToAnsi(STR0017)})
		Else
			Aviso(OemToAnsi(STR0015), OemToAnsi(STR0017), {OemToAnsi(STR0008)})  // La ruta del ejecutable de timbrado no es válida
			Return lRet
		EndIf
	Endif

	// Verifica la existencia del EXE de WS para timbrado
	If !File(cRutaSmr + Trim(cRutina))
		If jData['origin'] ==  "FINA998"
			AADD(aResponse,{.F.,400,OemToAnsi(STR0015) , OemToAnsi(STR0018) +  Replace( cRutaSmr, "\", "\\" ) + cRutina})
		Else
			Aviso(OemToAnsi(STR0015), OemToAnsi(STR0018) + cRutaSmr + cRutina , {OemToAnsi(STR0008)})  // No existe el cliente de servicio web: ...exe
			Return lRet
		EndIf
	Endif

	// Parámetros para el Proxy Server
	cProxy += "[" + If( lProxySr , "1" , "0" ) + "]"
	cProxy += "[" + cProxyIP + "]"
	cProxy += "[" + lTrim( Str( nProxyPt ) ) + "]"
	cProxy += "[" + If( lProxyAW , "1" , "0" ) + "]"
	cProxy += "[" + If( lProxyAW , "" , cProxyUr ) + "]"
	cProxy += "[" + If( lProxyAW , "" , cProxyPw ) + "]"
	cProxy += "[" + If( lProxyAW , "" , cProxyDm ) + "]"

	// Parametros obligatorios: (1)Usuario, (2)Password, (3)Factura.xml, (4)Ambiente,
	cParametros := cCFDiUsr + " " + cCFDiCon + " " + cIniFile + " " +cCFDiAmb +  " "
	// otros parametros segun el PAC: (5)Archivo.cer, (6)Archivo.key, (7)ClaveAutenticacion, (8)., (9)Timbrar/Cancelar, (10)Parametros del Proxy
	cParametros += cCFDiPub + " " + cCFDiPri + " " + cCFDiCve + " . " + IIf(lTimbrar, "T", cCancela) + " " + cProxy

	// Visualización de ventana de comando
	If nCFDiCmd < 0 .Or. nCFDiCmd > 10
		nCFDiCmd := 1
	Endif

	// Archivo .ini con la lista de CFDi a timbrar
	nHandle := FCreate(cRutaSmr + cIniFile)

	If nHandle == -1
		If jData['origin'] ==  "FINA998"
			AADD(aResponse,{.F.,400,OemToAnsi(STR0015) , OemToAnsi(STR0019) + cRutaSmr})
		Else
			Aviso(OemToAnsi(STR0015), OemToAnsi(STR0019) + cRutaSmr, {OemToAnsi(STR0008)})  // No es posible crear archivo temporal en la ruta ...
			Return lRet
		EndIf
	Endif

	FWrite( nHandle, "[RECIBOS]" + CRLF )

	//Copiar archivos .xml del servidor a la ruta del smartclient o la establecida (StartPath...\CFD\RECIBOS\xxx...xxx.XML a x:\totvs\protheusroot\bin\smartclient)
	MakeDir( cRutaCFDI )

	For nLoop := 1 to Len( aRecibos )
		cNameCFDI := aRecibos[nLoop, 1]

		If File( cRutaCFDI + cNameCFDI )
			FErase( cRutaCFDI + cNameCFDI )
		Endif

		If File( cRutaCFDI + cNameCFDI + ".out" )
			FErase( cRutaCFDI + cNameCFDI )
		Endif

		__CopyFile( cDir + cNameCFDI , cRutaCFDI + cNameCFDI )

		cTexto := cNameCFDI

		If !lTimbrar 
			If Len(aRecibos[nLoop]) >= 6 
				If !Empty(aRecibos[nLoop][5]) //Motivo de Cancelación
					cTexto += " " + Alltrim(aRecibos[nLoop][5])
				EndIf 
				If !Empty(aRecibos[nLoop][6]) //UUID que Sustituye
					cTexto += " " + Alltrim(aRecibos[nLoop][6])
				Else
					cTexto += " "
				EndIf 
			EndIf
		EndIf
		FWrite( nHandle, cTexto + CRLF )
	Next nLoop

	fClose( nHandle )

	If nCFDiCmd == 3 .Or. nCFDiCmd == 10
		nHandle	:= FCreate( cRutaSmr + cBatch )
		If nHandle == -1
			If jData['origin'] ==  "FINA998"
				AADD(aResponse,{.F.,400,OemToAnsi(STR0015) , OemToAnsi(STR0020) + cRutaSmr})
			Else
				Aviso(OemToAnsi(STR0015), OemToAnsi(STR0020) + cRutaSmr, {OemToAnsi(STR0008)} )  // No es posible crear archivo de comandos en la ruta ...
				Return lRet
			EndIf
		Endif

		FWrite(nHandle, cRutaSmr + cRutina + Trim(cParametros) + CRLF)
		FWrite(nHandle, "Pause" + CRLF)
		fClose(nHandle)

		nOpc := WAITRUN(cRutaSmr + cBatch, nCFDiCmd)
	Else
		// Ejecuta cliente de servicio web
		If lHTML
			cRutaExe := GetSrvProfString('RootPath', '') + GetSrvProfString('StartPath', '')
			lTimbWeb := WaitRunSrv(cRutaExe + cRutina + Trim(cParametros), .T., cRutaExe)
			If !lTimbWeb
				nOpc := 1
			EndIf
		Else
			nOpc := WAITRUN(cRutaSmr + cRutina + Trim(cParametros), nCFDiCmd)	// SW_HIDE
		EndIf

	Endif

	ProcRegua(Len(aRecibos))
	For nLoop := 1 To Len( aRecibos )
		If !jData['origin'] ==  "FINA998"
			IncProc(OemToAnsi(STR0021) + Alltrim(Str(nLoop)) + "/" + Alltrim(Str(Len(aRecibos)))) //"Actualizando recibos con el timbre fiscal "
		EndIf
		cNameCFDI := aRecibos[nLoop , 1 ]

		If nOpc > 0 .Or. !File(cRutaCFDI + cNameCFDI + ".out")
			If jData['origin'] ==  "FINA998"
				AADD(aResponse,{.F.,400,OemToAnsi(STR0022), OemToAnsi(STR0022) + cNameCFDI })
			Else
				Conout(ProcName(0) + ": " + OemToAnsi(STR0022) + cNameCFDI ) //No se obtuvo respuesta para el comprobante
				aRecibos[ nLoop , 2] := "*" + OemToAnsi(STR0022) //No se obtuvo respuesta para el comprobante
			EndIf
		Else
			If lTimbrar	// Timbrado de CFDI
				//Copia respuesta del WS a la carpeta original
				__CopyFile( cRutaCFDI + cNameCFDI + ".out" , cDir + cNameCFDI + ".out" )

				//Validar si se genero el timbre y si es asi se debe actualizar el campo F2_TIMBRE
				If  LeeXMLOut( cDir, cRutaCFDI, cNameCFDI, @cError, @cDetalle )
					fUpdSEL(aRecibos[nLoop][4])
					cUUIDSus := cUUID
					// Nuevo CFDi en el Remote
					Ferase( cRutaCFDI + cNameCFDI )
					Frename( cRutaCFDI + cNameCFDI + ".timbre" , cRutaCFDI + cNameCFDI )

					__CopyFile( cRutaCFDI + cNameCFDI , cDir + cNameCFDI )
					Ferase( cDir + cNameCFDI + ".out" )
					// Flag de proceso correcto
					aRecibos[nLoop , 2] := "Timbrado"
					lRet := .T.
					IF jData['origin'] ==  "FINA998" .AND. nOpc == 0			
			 			AADD(aResponse,{.T.,200,"Archivo XML Timbrado Correctamente"})
					ENDIF
				Else
					If jData['origin'] ==  "FINA998"
						AADD(aResponse,{.F.,400,OemToAnsi(STR0023) , OemToAnsi(STR0023) + cNameCFDI + CRLF + cError + If( Empty(cDetalle), "", " - " ) + cDetalle})
					Else
						Conout(ProcName(0) + ": " + OemToAnsi(STR0023) + cNameCFDI + CRLF + cError + If( Empty(cDetalle), "", " - " ) + cDetalle) //"No fue posible recuperar la firma del comprobante."
						aRecibos[nLoop , 2] := "*" + If(!Empty(cError), cError + If(Empty(cDetalle), "", " - ") + cDetalle, OemToAnsi(STR0023))
					EndIf
				Endif
			Else	// Cancelación de CFDI
				//Copiar respuesta del WS al servidor
				__CopyFile( cRutaCFDI + cNameCFDI + ".out" , cDir + cNameCFDI + ".canc" )
				If F815ResCan( cDir + cNameCFDI + ".canc" , @cError, cCFDiPAC)
					++nCanc
				Else
					If jData['origin'] ==  "FINA998"
						AADD(aResponse,{.F.,400,OemToAnsi(STR0079) , OemToAnsi(STR0079) + cNameCFDI + CRLF + cError})
					Else
						Conout(ProcName(0) + ": " + OemToAnsi(STR0079) + cNameCFDI + CRLF + cError) //"No fue posible cancelar el comprobante."
						aRecibos[nLoop , 2] := "*" + If(!Empty(cError), cError, OemToAnsi(STR0079))
					EndIf
				Endif
			Endif
		Endif

		// Eliminar temporales
		Ferase( cRutaCFDI + cNameCFDI )
		Ferase( cRutaCFDI + cNameCFDI + ".out" )
	Next nLoop

	GrabaLog(cRutaSmr + "Errores\", aRecibos)
	If File(cRutaSmr + cIniFile)
		FErase( cRutaSmr + cIniFile )
	EndIf

	If !lTimbrar
		lRet := (nCanc == Len( aRecibos ))
	Endif

Return lRet

//Actualiza campos de timbrado en el recibo de pago
Static Function fUpdSEL(aSEL)
	Local aSelArea	:= SEL->(GetArea())
	Local aKey		:= {}
	Local aRegQry	:= {}
	Local lCtbOnLine := .F.

	IF FUNNAME() == "FINA087A"
		Pergunte("FIN87A", .F.)
		lCtbOnLine := MV_PAR03 == 1
	EndIF

	DbSelectArea("SEL")
	SEL->(DbSetOrder(8))//EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
	SEL->(DbSeek(xFilial("SEL") + aSEL[1][24] + aSEL[1][2]))
	aKey := PesqKeyCTB("575")
	While !(SEL->(EOF())) .And. SEL->(EL_FILIAL + EL_SERIE + EL_RECIBO) == (xFilial("SEL") + aSEL[1][24] + aSEL[1][2])
		If !Empty(aKey)
			aAdd(aRegQry,ArmaKeyCTB(aKey))
		EndIf
		RecLock("SEL",.F.)
		Replace SEL->EL_UUID With cUUID
		Replace SEL->EL_FECTIMB With STOD(cFechaTim)
		MsUnLock()
		SEL->(DbSkip())
	Enddo
	If  ( !Empty(aRegQry) .AND. FUNNAME() == "FINA088" ) .OR. ( !Empty(aRegQry) .AND. FUNNAME() == "FINA087A" .AND. lCtbOnLine)// EL_LA == 'S'  otra dond si vienes fina87a validan validar la contabilidad mas contablida activo---- AQUI
		AtuCTBFF(aRegQry, cUUID)
	EndIf
	RestArea(aSelArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función    ³ LeeXMLOut³ Autor ³ Raul Ortiz Medina    ³ Data ³ 18/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Valida si el archivo .OUT obtenido del WS contiene TFD    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ LeeXMLOut( ruta , archivo , @error , @detalle )           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ CFDiRecNom                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LeeXMLOut(cRutaSrv, cRuta, cNombre, cError, cDetalle)
	Local oXML		:= Nil
	Local cXML		:= ""
	Local cArchiOUT	:= cRutaSrv + cNombre + ".out"   //Archivo recibido del servicio web
	Local cTimbre	:= ""
	Local lRet		:= .F.

	cUUID 		:= ""
	cFechaTim 	:= ""

	If Substr(cArchiOUT, 1, 1) == IIf(IsSrvUnix(), "/", "\")
		cArchiOUT := Substr(cArchiOUT, 2)
	Endif

	oXml := XmlParserFile(cArchiOUT, "", @cError, @cDetalle )

	//Es un objeto
	If valType(oXml) == "O"
		SAVE oXml XMLSTRING cXML

		If AT( "ERROR" , Upper(cXML) ) > 0 .And. AT ("UUID=" , Upper(cXML)) = 0 // El archivo tiene errores
			If AT( "CFDI:ERROR" , Upper(cXML) ) > 0
				If ValType(oXml:_CFDI_ERROR) == "O"
					cError := oXml:_CFDI_ERROR:_CODIGO:TEXT
					cDetalle := oXml:_CFDI_ERROR:_CFDI_DESCRIPCIONERROR:TEXT
				ElseIf AT( "CFDI:ERROR:COMPROBANTE:ERROR" , Upper(cXML) ) > 0
					If ValType(oXml:_CFDI_COMPROBANTE_ERROR) == "O"
						cError := oXml:_CFDI_COMPROBANTE_ERROR:_CODIGO:TEXT
						cDetalle := oXml:_CFDI_COMPROBANTE_ERROR:oXml:_CFDI_COMPROBANTE_DESCRIPCIONERROR:TEXT
					EndIf
				EndIf
			ElseIf AT( "<ERROR" , Upper(cXML) ) > 0
				If ValType(oXml:_ERROR) == "O"
					cError := oXml:_ERROR:_CODIGO:TEXT
					cDetalle := oXml:_ERROR:_DESCRIPCIONERROR:TEXT
				Endif
			Endif
			If Empty(cError)
				cError := cXML
			Endif
		// Obtener timbre
		Else
			If At("CFDI:COMPLEMENTO", Upper(cXml)) > 0
				// Se recibe todo el CFDi con el certificado del SAT (TFD)
				If At("TFD:TIMBREFISCALDIGITAL ", Upper(cXml)) > 0
					cTimbre 	:= oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_NOCERTIFICADOSAT:TEXT
					cUUID 		:= oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT
			 		cFechaTim 	:= REPLACE(SUBSTR(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT, 1, 10), "-", "")
				ElseIf At("TIMBREFISCALDIGITAL:TIMBREFISCALDIGITAL ", Upper(cXml) ) > 0
					cTimbre 	:= oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TIMBREFISCALDIGITAL_TIMBREFISCALDIGITAL:_NOCERTIFICADOSAT:TEXT
					cUUID 		:= oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TIMBREFISCALDIGITAL_TIMBREFISCALDIGITAL:_UUID:TEXT
			 		cFechaTim 	:= REPLACE(SUBSTR(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TIMBREFISCALDIGITAL_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT, 1, 10), "-", "")
				Endif

				If !Empty( cTimbre )
					lRet := AddTimbre2(cRuta, cNombre, cXml)
				Endif
			// Se recibe solo el certificado
			ElseIf At("TFD:TIMBREFISCALDIGITAL ", Upper(cXml)) > 0
				lRet := AddTimbre(cRuta, cNombre, cXml)
				cUUID := oXml:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT
			 	cFechaTim := REPLACE(SUBSTR(oXml:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT,1,10),"-","")
			Endif
		Endif
	// Regresar contenido del archivo como texto del error (sefactura no regresa formato xml)
	Else
		cError := If(Empty(cError), "", cError + CRLF) + MemoRead( cRuta + cNombre + ".out")
	Endif

	oXml := Nil
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función    ³AddTimbre2³ Autor ³ Alberto Rodriguez    ³ Data ³ 18/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Integra timbre fiscal en CFDi (temporales)                ³±±
±±³           ³ El WS devuelve TFD integrado en CFDi                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ AddTimbre2( ruta , archivo , oXML )                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ LeeXMLOut                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AddTimbre2(cRutaXML, cArchivo, cXML)
	Local cFile := cRutaXML + cArchivo + ".out"
	Local nIni := 0
	Local lRet := .F.

	// Leer xml recibido como string
	Begin Sequence
		nIni := At(":TimbreFiscalDigital ", cXML)

		If nIni == 0
			Conout( ProcName(0) + ": " + OemToAnsi(STR0024) + " " + cArchivo + ".out" )
			Break
		EndIf

		// Graba copia del xml recibido
		lRet := __CopyFile( cFile , cRutaXML + cArchivo + ".timbre" )
	End Sequence
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función    ³ AddTimbre³ Autor ³ Alberto Rodriguez    ³ Data ³ 18/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Integra timbre fiscal en CFDi (temporales)                ³±±
±±³           ³ El WS devuelve solo TFD                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ AddTimbre( ruta , archivo , oXML )                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ LeeXMLOut                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AddTimbre(cRutaXML, cArchivo, cTimbre)
	Local cFile := cRutaXML + cArchivo
	Local nHandle	:= 0
	Local aInfoFile := {}
	Local nSize := 0
	Local cXML := ""
	Local nIni := 0
	Local cUTF8 := Chr(239) + Chr(187) + Chr(191)
	Local lRet := .F.

	// Leer xml's como string
	Begin Sequence
		// xml enviado a timbrar
		If !(File(cFile))
			Break
		EndIf

		nHandle := fOpen(cFile)

		If nHandle <= 0
			Break
		EndIf

		aInfoFile := Directory(cFile)
		nSize := aInfoFile[1, 2]
		cXML := fReadStr(nHandle, nSize)
		fClose(nHandle)

		nIni := At("</cfdi:Complemento>", cXML)

		If nIni == 0
			Conout( ProcName(0) + ": " + STR0024 + " " + cArchivo + ".out" ) //"Archivo XML no válido."
			Break
		EndIf

		// Inserta nodo del timbre fiscal
		cXML := Substr(cXML, 1, nIni-1) + ;
				Space(8) + cTimbre + CRLF + ;
				Substr(cXML, nIni)

		// Codificacion UTF-8
		If Substr(cXML,1,1) == "<"
			cXML := Strtran( cXML , cUTF8 )
			cXML := cUTF8 + cXML // EncodeUTF8( cXML )
		Endif

		// Graba el xml actualizado
		If ( nHandle := fCreate( cFile + ".timbre" ) ) <> -1
			If fWrite( nHandle , cXML ) == Len(cXML)
				lRet := .T.
			Endif
			fClose( nHandle )
		Endif
	End Sequence
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función    ³ValidaCanc³ Autor ³ A. Rodriguez         ³ Data ³ 20/02/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Lee archivo .out para validar cancelación de CFDI.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ ValidaCanc( cFile , cResultado )                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ CFDiRecPag                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ValidaCanc( cFile , cResultado )
Local nHandle	:= 0
Local aInfoFile	:= {}
Local nSize		:= 0
Local nRegs		:= 0
Local nFor		:= 0
Local cBuffer	:= ""
Local cLine		:= ""
Local cString	:= ""
Local lRet		:= .F.

	Begin Sequence
   	nHandle := fOpen(cFile)

		If  nHandle <= 0
		cResultado := STR0014  //"No fue posible abrir el archivo .out"
		Break
		EndIf

	aInfoFile := Directory(cFile)
	nSize := aInfoFile[ 1 , 2 ]
	nRegs := Int(nSize/2048)

		For nFor := 1 to nRegs
		fRead( nHandle , @cBuffer , 2048 )
		cLine += cBuffer
		Next

		If nSize > nRegs * 2048
		fRead( nHandle , @cBuffer , (nSize - nRegs * 2048) )
		cLine += cBuffer
		Endif

	fClose(nHandle)
	End Sequence

	If Substr(cLine,1,1) == "("
	cLine := Substr(cLine,2)
	cLine := Strtran( cLine , ")" , " " , 1 , 1 )
	EndIF

cBuffer := Upper(cLine)

	If ( "UUID CANCELADO" $ cBuffer ) .Or. ( "STATUSUUID>201" $ cBuffer ) .Or. ( "SE REPORTARA" $ cBuffer .And. "CANCELADO" $ cBuffer) .Or. ;
	( "PREVIAMENTE" $ cBuffer .And. "CANCELADO" $ cBuffer)
	lRet := .T.
		Else
	cString	:= Substr( cLine , 1 , 4 )
		If Empty(cLine) .Or. ( "ERROR" $ cBuffer ) .Or. ( "FAILED" $ cBuffer ) .Or. ( "FAIL " $ cBuffer ) .Or. ( "EXCEPTION" $ cBuffer ) .Or. ;
	( "EXCEPCION" $ cBuffer ) .Or. ( "EXCEPCIóN" $ cBuffer ) .Or. ( "EXCEPCIÓN" $ cBuffer )  .Or. ( Val(cString) > 0 ) .Or. ;
	( "CANCELED" $ cBuffer .And. "FALSE" $ cBuffer )
		// Error
			Else
		lRet := .T.
		Endif
	Endif

cResultado := Alltrim(cLine)

Return 	lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función    ³ GrabaLog ³ Autor ³ Alberto Rodriguez    ³ Fecha³ 19/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Graba log de recibos no timbrados                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ GrabaLog( cRuta , aRecibos )                              ³±±
±±³           ³ [x,1] - Nombre del archivo xml                            ³±±
±±³           ³ [x,2] - *mensaje de error                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ CFDiRecNom       		                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GrabaLog(cRuta , aRecibos)
	Local cArchivo  := DtoS(dDataBase) + Strtran(GetRmtTime(), ":") + ".log"
	Local nHandle	:= FCreate(cRuta + cArchivo)
	Local nLoop	:= 0
	Local lRet		:= .F.

	If !(nHandle == -1)
		For nLoop := 1 to Len(aRecibos)
			FWrite(nHandle, aRecibos[nLoop,1] + " " + aRecibos[nLoop,2] + CRLF)
		Next
		FClose(nHandle)
		lRet := .T.
	EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpPDF      ºAutor  ³Luis Samaniego   º Data ³  17/10/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impresion pdf.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ImpPDF(cXmlNom, cPdfNom, cNomTmp)                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cXmlNom .- Archivo.xml                                     º±±
±±º          ³cPdfNom .- Archivo.pdf                                     º±±
±±º          ³cNomTmp .- Nombre del Archivo temporal                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAFIN/FISA815                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpPDF(cXmlNom, cPdfNom, cNomTmp, jData, aResponse)
	Local cCaminhoXML	:= ""
	Local cCaminhoPDF	:= ""
	Local cPath 		:= Replace( cDir, "\\", "\" )
	Local oXML			:= NIL
	Local oPrinter
	Local cError		:= ""
	Local cDetalle	:= ""
	Local cRutaSmr 	:= &(SuperGetmv( "MV_CFDSMAR" , .F. , "GetClientDir()" ))

	PRIVATE cBuffer	:= ""
	PRIVATE oFont		:= NIL
	PRIVATE oFont1	:= NIL
	PRIVATE oFont2	:= NIL
	PRIVATE oFont3	:= NIL
	PRIVATE oFont4	:= NIL
	PRIVATE oFont5	:= NIL
	PRIVATE oFont6	:= NIL
	PRIVATE oFont7	:= NIL
	PRIVATE cCadenaOr	:= "||"

	Default jData := JsonObject():New()
	Default aResponse := {}

	cCaminhoXML := Replace(cDir + cXmlNom, "\\", "\")
	cCaminhoPDF := Replace( (cPath + cPdfNom ), ".xml", ".pdf" )

	IF ISSRVUNIX()
		cCaminhoXML := Replace( cCaminhoXML, "\", "/" )
		cPath := Replace( cPath, "\", "/" )
	EndIf

	oPrinter := FWMsPrinter():New(AllTrim(cPdfNom), 6, .F., , .T.)

	oFont1 := TFont():New('Courier new', ,40,.T., .T.)
	oFont := TFont():New( "ARIAL", , 07, .T., .F.)
	oFont2 := TFont():New( "ARIAL", , 05, .T., .F.)
	oFont3 := TFont():New( "ARIAL", , 12, .T., .T.)
	oFont4 := TFont():New( "ARIAL", , 07, .T., .T.)
	oFont5 := TFont():New( "ARIAL", , 05, .T., .T.)
	oFont6 := TFont():New( "ARIAL", , 07, .T., .F.)
	oFont7 := TFont():New( "ARIAL", , 05, .T., .F.)
	oFont8 := TFont():New("Arial",,15,.T., .T.)
	If FILE(cCaminhoXML) //+ cfile/*/ + cFile + ".XML"/*/
		oXML := XmlParserFile(cCaminhoXML, "", @cError, @cDetalle )
	EndIf

	If oXML == NIL
		Return ""
	EndIf

	oPrinter:setDevice(IMP_PDF)
	oPrinter:cPathPDF := cRutaSmr

	oPrinter:StartPage()
	ImprRecNom(oPrinter, oXml, cNomTmp)
	oPrinter:EndPage()

	If jData['origin'] ==  "FINA998" .And. jData['imppdf'] != .F.
		oPrinter:SetViewPDF(.T.)
	Else
		oPrinter:SetViewPDF(.F.)
	EndIf


	oPrinter:Print()
	COPY FILE (cRutaSmr + cPdfNom ) TO (cPath + cPdfNom )


	FreeObj(oPrinter)
	oPrinter := Nil

	If jData['origin'] ==  "FINA998"
		IF jData['imppdf'] != .T.
				If File(cRutaSmr + replace(cXmlNom, ".xml", ".pdf"))
				Ferase(cRutaSmr + replace(cXmlNom, ".xml", ".pdf"))
		EndIf
		ENDIF
	else
			If File(cRutaSmr + replace(cXmlNom, ".xml", ".pdf"))
			Ferase(cRutaSmr + replace(cXmlNom, ".xml", ".pdf"))
		EndIf
	ENDIF

	If jData['origin'] ==  "FINA998" .and. jData['sendemail'] == .F.
		AADD(aResponse,{.T.,200,"Archivo PDF Generado"})
	EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función    ³fRmpCarac³ Autor ³ Alf. Medrano         ³ Data ³ 19/09/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Reemplaza caractres especiales a simbolo simple           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ ValidaCanc(cTexto )                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ fLanca                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fRmpCarac(cTexto)
	Default cTexto := ""

	cTexto := Replace(cTexto,'&#38;','&' )
	cTexto := Replace(cTexto,'&#39;', "'" )
	cTexto := Replace(cTexto,'&#34;', '"')
	cTexto := Replace(cTexto,'&#60;', '<')
	cTexto := Replace(cTexto,'&#62;', '>')

Return cTexto


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImprRecNom  ºAutor  ³Luis Samaniego   º Data ³  17/10/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impresion de encabezados.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ImprRecNom(oPrinter,oXml,cNomTmp)                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³oPrinter .- Objeto del informe.                            º±±
±±º          ³oXML     .- Archivo XML.                                   º±±
±±º          ³cNomTmp  .- Nombre del Archivo XML.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAFIN/FISA815                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImprRecNom(oPrinter,oXml,cNomTmp)
	Private li := 0
	Private cPict1 :=	"@E 999,999,999.99"
	Private cPict2 :=	"@E 99,999,999.99"
	Private cPict3 :=	"@E 999,999.99"
	Private nEsp1 := 10
	Private nEsp2 := 10
	Private nEsp3 := 15
	Private nEsp4 := 25
	Private nEspLi1 := 5
	Private nEspLi3 := 15
	Private nEspLi2 := 10

	ImpEnc(oPrinter,oXml)
	fLanca(oPrinter,oXML)
	fRodape(oPrinter,oXML,cNomTmp)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpEnc      ºAutor  ³Luis Samaniego   º Data ³  17/10/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impresion de encabezados.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ImpEnc(oPrinter,oXML)                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³oPrinter .- Objeto del informe.                            º±±
±±º          ³oXML     .- Archivo XML.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Nil                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAFIN/FISA815                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpEnc(oPrinter,oXml)
	Local cFileLogo	:= ""
	Local cSerie	:= ""

	oPrinter:Line(5, 5, 790, 5, , "-2") //Linea lateral izquierda
	oPrinter:Line(5, 585, 790, 585, , "-4") //Linea lateral derecha
	oPrinter:Line(5, 5, 5, 585, , "-4")//Linea horizontal de marco

	LI += 40
	oPrinter:Say(LI, 195, OemToAnsi(STR0025), oFont8) //Recibo Electrónico de Pago

	LI -= 20
	fCarLogo(@cFileLogo)
	If File(cFileLogo)
		oPrinter:SayBitmap(LI, 15, cFileLogo, 50, 50)
	Endif

	LI += 30
	oPrinter:Say(LI, 410, OemToAnsi(STR0026), oFont3) //Recibo no.:

	If XMLChildEX(oXml:_CFDI_COMPROBANTE, "_SERIE") <> Nil
		cSerie := AllTrim(oXml:_CFDI_COMPROBANTE:_SERIE:TEXT) + " "
	EndIf

	oPrinter:Say(LI, 520, cSerie + oXml:_CFDI_COMPROBANTE:_FOLIO:TEXT, oFont3)

	LI += 12
	oPrinter:Say(LI, 410, OemToAnsi(STR0076), oFont3) //Tipo de Comprobante
	oPrinter:Say(LI, 520, OemToAnsi(STR0051), oFont3) //"Pago "
	LI += 20
	oPrinter:Say(LI, 255, OemToAnsi(STR0077), oFont3) //Lugar, Fecha y hora de emisión
	oPrinter:Say(LI, 410, cLugarEmi + " " + oXml:_CFDI_COMPROBANTE:_FECHA:TEXT, oFont3)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fLanca      ºAutor  ³Luis Samaniego   º Data ³  17/10/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impresion de los lanzamientos.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³fLanca(oPrinter,oXML)                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³oPrinter .- Objeto del informe.                            º±±
±±º          ³oXML     .- Archivo XML.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Nil                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAFIN/FISA815                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fLanca(oPrinter,oXML)
	Local nI			:= 0
	Local nJ			:= 0
	Local cFormPag		:= ""
	LOcal cDesFrmPag	:= ""
	Local lParcialidad	:= .F.
	Local lTipoCambio	:= .F.
	Local cRegFis		:= "" //Regimen fiscal

	//Datos con la forma de pago cheque
	Local cRFCEmi:= "" //RFC Emisor Cta Ordenante
	Local cCtaOrd:= "" // Cuenta Ordenante
	Local cRFCBen:= "" // RCF Cuenta Beneficiario
	Local cCtaBen:= "" // Cuenta del beneficiario

	Local cDescrp := ""
	Local lTamNumOpe := .F.

	Local lVer2CRP	:= .F. //Version 2.0 Complemento
	Local cVPago	:= ""
	Local cNodPago	:= ""
	Local cNodPagos	:= ""
	Local cNodDcRel	:= ""
	Local nValIVA   := 0
	Local nValRIVA  := 0
	Local nMontoPag := 0

	lVer2CRP := (XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO,"_PAGO20_PAGOS") <> Nil)

	cVPago		:= IIf(lVer2CRP, "pago20", "pago10")
	cNodPago	:= IIf(lVer2CRP, "_PAGO20", "_PAGO10")+"_PAGO"
	cNodPagos	:= IIf(lVer2CRP, "_PAGO20", "_PAGO10")+"_PAGOS"
	cNodDcRel	:= IIf(lVer2CRP, "_PAGO20", "_PAGO10")+"_DOCTORELACIONADO"

	LI += nEspLi1
	oPrinter:Line(LI, 5, LI, 585, , "-4")

	LI += nEspli3
	oPrinter:Line(LI, 5, LI, 585, , "-4")
	oPrinter:Say(LI -= 5, 10, OemToAnsi(STR0028), oFont3)//Datos de identificación del emisor

	LI += 15
	oPrinter:Say(LI, 10, OemToAnsi(STR0029), oFont4) //Nombre o razon social
	oPrinter:Say(LI, 120, fRmpCarac(oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_NOMBRE:TEXT), oFont)

	oPrinter:Say(LI, 350, OemToAnsi(STR0030), oFont4)//RFC emisor
	oPrinter:Say(LI, 450, fRmpCarac(oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_RFC:TEXT), oFont)

	cRegFis := oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_REGIMENFISCAL:TEXT

	LI += 15
	oPrinter:Say(LI, 10, OemToAnsi(STR0031), oFont4) //Regimen fiscal
	oPrinter:Say(LI, 120, cRegFis + " - " + ObtColSAT("S010",cRegFis,1,3,4,80), oFont)

	oPrinter:Say(LI, 350, OemToAnsi(STR0096), oFont4)//Versión
	oPrinter:Say(LI, 450, oXml:_CFDI_COMPROBANTE:_VERSION:TEXT, oFont)

	LI += 15
	oPrinter:Say(LI, 10, OemToAnsi(STR0098), oFont4) //Num. Cert. Emisor
	oPrinter:Say(LI, 120, oXml:_CFDI_COMPROBANTE:_NOCERTIFICADO:TEXT, oFont)


	LI += nEspLi1
	oPrinter:Line(LI, 5, LI, 585, , "-4")

	LI += nEspli3
	oPrinter:Line(LI, 5, LI, 585, , "-4")
	oPrinter:Say(LI -= 5, 10, OemToAnsi(STR0032) ,oFont3)//Datos de identificacion del receptor

	LI += 15
	oPrinter:Say(LI, 10, OemToAnsi(STR0029), oFont4)//Nombre o razon social
	oPrinter:SAY(LI, 120, fRmpCarac(oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_NOMBRE:TEXT), oFont)

	oPrinter:Say(LI, 350, OemToAnsi(STR0033), oFont4)//RFC receptor
	oPrinter:SAY(LI, 450, fRmpCarac(oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_RFC:TEXT), oFont)

	LI += 15
	oPrinter:Say(LI, 10, OemToAnsi(STR0034), oFont4)//Uso CFDI
	oPrinter:SAY(LI, 120, oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_USOCFDI:TEXT, oFont)

	If lVer2CRP

		oPrinter:Say(LI, 350, OemToAnsi(STR0139), oFont4) //"Regimen Fiscal"
		oPrinter:Say(LI, 450, oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_REGIMENFISCALRECEPTOR:TEXT, oFont)

		LI += 15
		oPrinter:Say(LI, 10, OemToAnsi(STR0140), oFont4) //"Domicilio Fiscal"
		oPrinter:Say(LI, 120, oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_DOMICILIOFISCALRECEPTOR:TEXT, oFont)	
	EndIf

	If ObtUidXML(oXml, "ResidenciaFiscal")

		oPrinter:Say(LI, 350, OemToAnsi(STR0035), oFont4) //Residencia fiscal
		oPrinter:Say(LI, 450, oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_RESIDENCIAFISCAL:TEXT, oFont)
		
		If ObtUidXML(oXml, "NumRegIdTrib")
			LI += 15
			oPrinter:Say(LI, 10, OemToAnsi(STR0036), oFont4) //Registro de identidad fiscal
			oPrinter:Say(LI, 120, oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_NUMREGIDTRIB:TEXT, oFont)
		EndIf
	EndIf

	LI += nEspLi1
	oPrinter:Line(LI, 5, LI, 585, , "-4")

	If ProcName(1) == "NEWPAGE"
		Return
	EndIf

	LI += nEspli3
	oPrinter:Line(LI, 5, LI, 585, , "-4")
	oPrinter:Say(LI -= 5, 10, OemToAnsi(STR0037), oFont3)//Conceptos

	LI += 15
	oPrinter:Say(LI, 10, OemToAnsi(STR0038), oFont4)//Clave prod. servicio
	oPrinter:Say(LI, 110, oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO:_CLAVEPRODSERV:TEXT, oFont)

	oPrinter:Say(LI, 201, OemToAnsi(STR0039), oFont4)//Cant.
	oPrinter:Say(Li, 301, oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO:_CANTIDAD:TEXT, oFont)

	oPrinter:Say(LI, 392, OemToAnsi(STR0040), oFont4)//Clave unidad
	oPrinter:Say(Li, 492, oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO:_CLAVEUNIDAD:TEXT, oFont)

	LI += 15
	oPrinter:Say(LI, 10, OemToAnsi(STR0041), oFont4)//Descripcion
	oPrinter:Say(Li, 110, oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO:_DESCRIPCION:TEXT, oFont)

	oPrinter:Say(LI, 201, OemToAnsi(STR0042),oFont4)//Valor unitario
	oPrinter:Say(Li, 301, oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO:_VALORUNITARIO:TEXT, oFont)

	oPrinter:Say(LI, 392, OemToAnsi(STR0043), oFont4)//Importe
	oPrinter:Say(Li, 492, oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO:_IMPORTE:TEXT, oFont)

	//Valida que exista el nodo de complemento de recepcion de pagos
	LI += nEspLi1
	oPrinter:Line(LI, 5, LI, 585, , "-4")
	If ObtUidXML(oXml, cVPago+":Pagos")
		LI += nEspli3
		oPrinter:Line(LI, 5, LI, 585, , "-4")
		oPrinter:Say(LI -= 5, 10, OemToAnsi(STR0044), oFont3)//Pagos

		//Tratamiento para cuando existen varios pagos {Arreglo}
		If ValType(&("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago)) == "A"
			For nI := 1 To Len(&("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago))

				cFormPag	:= &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:_FORMADEPAGOP:TEXT")
				cDesFrmPag	:= RTrim(ObtColSAT("S005", cFormPag, 1, 2, 3, 40))

				If cFormPag $ "02|03|04|05|06|28|29" //Si las formas de pago, son bancarizadas.
					If XMLChildEx(&("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]"),"_RFCEMISORCTAORD") <> Nil
						cRFCEmi := &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:_RFCEMISORCTAORD:TEXT")
					EndIf
					If XMLChildEx(&("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]"),"_CTAORDENANTE") <> Nil
						cCtaOrd := &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:_CTAORDENANTE:TEXT")
					EndIf
					If XMLChildEx(&("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]"),"_RFCEMISORCTABEN") <> Nil
						cRFCBen := &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:_RFCEMISORCTABEN:TEXT")
					EndIf
					If XMLChildEx(&("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]"),"_CTABENEFICIARIO") <> Nil
						cCtaBen := &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:_CTABENEFICIARIO:TEXT")
					EndIf
				Endif

				LI += 15
				newPage(oPrinter, ,oXml)
				oPrinter:Say(LI, 10, OemToAnsi(STR0051) + AllTrim(Str(nI)), oFont4) //Pago 1

				LI += 15
				newPage(oPrinter, ,oXml)
				If XMLChildEx(&("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]"),"_NUMOPERACION") <> Nil
					oPrinter:Say(LI, 15, OemToAnsi(STR0052), oFont4) //Numero operacion
					oPrinter:Say(Li, 110, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:_NUMOPERACION:TEXT"), oFont)

					If Len(&("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:_NUMOPERACION:TEXT")) > 20
						LI += 15
						lTamNumOpe := .T.
					EndIf
				EndIf

				oPrinter:Say(LI, IIf(lTamNumOpe, 15, 201), OemToAnsi(STR0053), oFont4) //Fecha
				oPrinter:Say(Li, IIf(lTamNumOpe, 110, 301), &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:_FECHAPAGO:TEXT"), oFont)

				oPrinter:Say(LI, IIf(lTamNumOpe, 201, 392), OemToAnsi(STR0054), oFont4) //Forma de pago

				cDescrp := cFormPag + " - " + cDesFrmPag
				F815LinCar(oPrinter, LI, IIf(lTamNumOpe, 301, 450), cDescrp, 34, 10, 2, oFont)

				LI += 15
				newPage(oPrinter, ,oXml)
				oPrinter:Say(LI, 15, OemToAnsi(STR0055), oFont4) //Moneda
				oPrinter:Say(Li, 110, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:_MONEDAP:TEXT"), oFont)

				If ObtUidXML(&("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]"),"TipoCambioP")
					oPrinter:Say(LI, 201, OemToAnsi(STR0056), oFont4) //Tipo de cambio
					oPrinter:Say(Li, 301, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:_TIPOCAMBIOP:TEXT"), oFont)
					lTipoCambio := .T.
				EndIf

				oPrinter:Say(LI, Iif(lTipoCambio, 392, 201), OemToAnsi(STR0057), oFont4) //Monto
				oPrinter:Say(Li, Iif(lTipoCambio, 492, 301), &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:_MONTO:TEXT"), oFont)
				lTipoCambio := .F.

				If cFormPag $ "02|03|04|05|06|28|29" //Si las formas de pago, son bancarizadas.
					If !Empty(cRFCEmi) .Or. !Empty(cCtaOrd)
						LI += 15
						If !Empty(cRFCEmi)
							oPrinter:Say(LI, 15, OemToAnsi(STR0080), oFont4) //"RFC Emisor"
							oPrinter:Say(Li, 110, cRFCEmi, oFont)
						EndIf
						If !Empty(cCtaOrd)
							oPrinter:Say(LI, 201, OemToAnsi(STR0081), oFont4) //"Cuenta Ordenante"
							oPrinter:Say(Li, 301, cCtaOrd , oFont)
						EndIf
					EndIf
					If !Empty(cRFCBen) .Or. !Empty(cCtaBen)
						LI +=15
						If !Empty(cRFCBen)
							oPrinter:Say(LI, 15, OemToAnsi(STR0082), oFont4) //"RFC Beneficiario"
							oPrinter:Say(Li, 110, cRFCBen , oFont)
						EndIf
						If !Empty(cCtaBen)
							oPrinter:Say(LI, 201, OemToAnsi(STR0083), oFont4) //"Cuenta Beneficiario"
							oPrinter:Say(Li, 301, cCtaBen , oFont)
						EndIf
					EndIf
				EndIf
				//Si son multiples documentos relacionados, lo toma como un arreglo.
				If ValType(&("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:"+cNodDcRel)) == "A"
					//Impresion documentos relacionados por pago
					For nJ := 1 To Len(&("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:"+cNodDcRel))
						LI += 10
						newPage(oPrinter, ,oXml)
						oPrinter:Line(LI, 5, LI, 585, , "-4")

						LI += 10
						newPage(oPrinter, ,oXml)
						oPrinter:Say(LI ,10, OemToAnsi(STR0058) + AllTrim(Str(nJ)), oFont4) //Documento relacionado

						LI += 15
						newPage(oPrinter, ,oXml)
						oPrinter:Say(LI, 15, OemToAnsi(STR0059), oFont4) //Id Documento
						oPrinter:SAY(Li, 70, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:"+cNodDcRel+"[nJ]:_IDDOCUMENTO:TEXT"), oFont)

						oPrinter:Say(LI, 250, OemToAnsi(STR0060), oFont4) //Folio
						oPrinter:SAY(Li, 301, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:"+cNodDcRel+"[nJ]:_FOLIO:TEXT"), oFont)

						oPrinter:Say(LI, 392, OemToAnsi(STR0061), oFont4) //Serie
						oPrinter:SAY(Li, 492, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:"+cNodDcRel+"[nJ]:_SERIE:TEXT"), oFont)

						LI += 15
						newPage(oPrinter, ,oXml)
						If !lVer2CRP
							oPrinter:Say(LI, 15, OemToAnsi(STR0062), oFont4) //Metodo pago
							oPrinter:SAY(Li, 70, oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO10_PAGOS:_PAGO10_PAGO[nI]:_PAGO10_DOCTORELACIONADO[nJ]:_METODODEPAGODR:TEXT, oFont)
						EndIf

						If ObtUidXML(&("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:"+cNodDcRel+"[nJ]"), "NumParcialidad")
							oPrinter:Say(LI, 120, OemToAnsi(STR0063), oFont4) //Parcialidad
							oPrinter:SAY(Li, 200, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:"+cNodDcRel+"[nJ]:_NUMPARCIALIDAD:TEXT"), oFont)
							lParcialidad := .T.
						EndIf

						oPrinter:Say(LI, Iif(lParcialidad, 300, 120), OemToAnsi(STR0055), oFont4) //Serie
						oPrinter:SAY(Li, Iif(lParcialidad, 350, 200), &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:"+cNodDcRel+"[nJ]:_MONEDADR:TEXT"), oFont)

						If !lVer2CRP .And. ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO10_PAGOS:_PAGO10_PAGO[nI]:_PAGO10_DOCTORELACIONADO[nJ], "TipoCambioDR")
							oPrinter:Say(LI, Iif(lParcialidad, 400, 300), OemToAnsi(STR0056), oFont4) //Tipo de Cambio
							oPrinter:SAY(Li, Iif(lParcialidad, 450, 350), oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO10_PAGOS:_PAGO10_PAGO[nI]:_PAGO10_DOCTORELACIONADO[nJ]:_TIPOCAMBIODR:TEXT, oFont)
						ElseIf lVer2CRP .And. ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_PAGO[nI]:_PAGO20_DOCTORELACIONADO[nJ], "EquivalenciaDR")
							oPrinter:Say(LI, Iif(lParcialidad, 400, 300), OemToAnsi(STR0141), oFont4) //Equivalencia
							oPrinter:SAY(Li, Iif(lParcialidad, 450, 350), oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_PAGO[nI]:_PAGO20_DOCTORELACIONADO[nJ]:_EQUIVALENCIADR:TEXT, oFont)
						EndIf
						lParcialidad := .F.

						LI += 15
						newPage(oPrinter, ,oXml)
						oPrinter:Say(LI, 15, OemToAnsi(STR0064), oFont4) //Saldo
						oPrinter:SAY(Li, 110, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:"+cNodDcRel+"[nJ]:_IMPSALDOANT:TEXT"), oFont)

						oPrinter:Say(LI, 201, OemToAnsi(STR0065), oFont4) //Importe pagado
						oPrinter:SAY(Li, 301, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:"+cNodDcRel+"[nJ]:_IMPPAGADO:TEXT"), oFont)

						oPrinter:Say(LI, 392, OemToAnsi(STR0066), oFont4) //Saldo insoluto
						oPrinter:SAY(Li, 492, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:"+cNodDcRel+"[nJ]:_IMPSALDOINSOLUTO:TEXT"), oFont)
						If lVCFDi40
							F815IMPDR(oPrinter, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:"+cNodDcRel+"[nJ]"), oXml, @LI)
						EndIf
					Next nJ
				Else
					LI += 10
					newPage(oPrinter, ,oXml)
					oPrinter:Line(LI, 5, LI, 585, , "-4")

					LI += 10
					newPage(oPrinter, ,oXml)
					oPrinter:Say(LI ,10, OemToAnsi(STR0058) + "1", oFont4) //Documento relacionado

					LI += 15
					newPage(oPrinter, ,oXml)
					oPrinter:Say(LI, 15, OemToAnsi(STR0059), oFont4) //Id Documento
					oPrinter:SAY(Li, 70, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:"+cNodDcRel+":_IDDOCUMENTO:TEXT"), oFont)

					oPrinter:Say(LI, 250, OemToAnsi(STR0060), oFont4) //Folio
					oPrinter:SAY(Li, 301, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:"+cNodDcRel+":_FOLIO:TEXT"), oFont)

					oPrinter:Say(LI, 392, OemToAnsi(STR0061), oFont4) //Serie
					oPrinter:SAY(Li, 492, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:"+cNodDcRel+":_SERIE:TEXT"), oFont)

					LI += 15
					newPage(oPrinter, ,oXml)
					If !lVer2CRP
						oPrinter:Say(LI, 15, OemToAnsi(STR0062), oFont4) //Metodo pago
						oPrinter:SAY(Li, 70, oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO10_PAGOS:_PAGO10_PAGO[nI]:_PAGO10_DOCTORELACIONADO:_METODODEPAGODR:TEXT, oFont)
					EndIf

					If ObtUidXML(&("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:"+cNodDcRel), "NumParcialidad")
						oPrinter:Say(LI, 120, OemToAnsi(STR0063), oFont4) //Parcialidad
						oPrinter:SAY(Li, 200, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:"+cNodDcRel+":_NUMPARCIALIDAD:TEXT"), oFont)
						lParcialidad := .T.
					EndIf

					oPrinter:Say(LI, Iif(lParcialidad, 300, 120), OemToAnsi(STR0055), oFont4) //Serie
					oPrinter:SAY(Li, Iif(lParcialidad, 350, 200), &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:"+cNodDcRel+":_MONEDADR:TEXT"), oFont)

					If !lVer2CRP .And. ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO10_PAGOS:_PAGO10_PAGO[nI]:_PAGO10_DOCTORELACIONADO, "TipoCambioDR")
						oPrinter:Say(LI, Iif(lParcialidad, 400, 300), OemToAnsi(STR0056), oFont4) //Tipo de Cambio
						oPrinter:SAY(Li, Iif(lParcialidad, 450, 350), oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO10_PAGOS:_PAGO10_PAGO[nI]:_PAGO10_DOCTORELACIONADO:_TIPOCAMBIODR:TEXT, oFont)
					ElseIf lVer2CRP .And. ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_PAGO[nI]:_PAGO20_DOCTORELACIONADO, "EquivalenciaDR")
						oPrinter:Say(LI, Iif(lParcialidad, 400, 300), OemToAnsi(STR0141), oFont4) //Equivalencia
						oPrinter:SAY(Li, Iif(lParcialidad, 450, 350), oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_PAGO[nI]:_PAGO20_DOCTORELACIONADO:_EQUIVALENCIADR:TEXT, oFont)
					EndIf

					LI += 15
					newPage(oPrinter, ,oXml)
					oPrinter:Say(LI, 15, OemToAnsi(STR0064), oFont4) //Saldo
					oPrinter:SAY(Li, 110, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:"+cNodDcRel+":_IMPSALDOANT:TEXT"), oFont)

					oPrinter:Say(LI, 201, OemToAnsi(STR0065), oFont4) //Importe pagado
					oPrinter:SAY(Li, 301, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:"+cNodDcRel+":_IMPPAGADO:TEXT"), oFont)

					oPrinter:Say(LI, 392, OemToAnsi(STR0066), oFont4) //Saldo insoluto
					oPrinter:SAY(Li, 492, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+"[nI]:"+cNodDcRel+":_IMPSALDOINSOLUTO:TEXT"), oFont)
					If lVCFDi40
						F815IMPDR(oPrinter, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:" + cNodPagos + ":" + cNodPago + "[nI]:" + cNodDcRel), oXml, @LI)
					EndIf
				EndIf

				If nI < Len(&("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago))
					LI += 5
					newPage(oPrinter, ,oXml)
					oPrinter:Line(LI,5,LI,585,,"-4")
					LI += 1
					newPage(oPrinter, ,oXml)
					oPrinter:Line(LI,5,LI,585,,"-4")
				EndIf
			Next nI

		Else //Tratamiento para cuando existe un solo pago

			cFormPag	:= &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":_FORMADEPAGOP:TEXT")
			cDesFrmPag	:= RTrim(ObtColSAT("S005", cFormPag, 1, 2, 3, 40))

			If cFormPag $ "02|03|04|05|06|28|29" //Si las formas de pago, son bancarizadas.
				If XMLChildEx(&("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago), "_RFCEMISORCTAORD") <> Nil
					cRFCEmi := &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":_RFCEMISORCTAORD:TEXT")
				EndIf
				If XMLChildEx(&("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago), "_CTAORDENANTE") <> Nil
					cCtaOrd := &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":_CTAORDENANTE:TEXT")
				EndIf
				If XMLChildEx(&("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago), "_RFCEMISORCTABEN") <> Nil
					cRFCBen := &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":_RFCEMISORCTABEN:TEXT")
				EndIf
				If XMLChildEx(&("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago), "_CTABENEFICIARIO") <> Nil
					cCtaBen := &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":_CTABENEFICIARIO:TEXT")
				EndIf
			Endif

			LI += 15
			newPage(oPrinter, ,oXml)
			oPrinter:Say(LI, 10, OemToAnsi(STR0051) + "1", oFont4) //Pago "n"

			LI += 15
			newPage(oPrinter, ,oXml)
			If XMLChildEx(&("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago),"_NUMOPERACION") <> Nil
				oPrinter:Say(LI, 15, OemToAnsi(STR0052), oFont4) //Numero operacion
				oPrinter:Say(Li, 110, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":_NUMOPERACION:TEXT"), oFont)
				If Len(&("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":_NUMOPERACION:TEXT")) > 20
					LI += 15
					lTamNumOpe := .T.
				EndIf
			EndIf

			oPrinter:Say(LI, IIf(lTamNumOpe, 15, 201), OemToAnsi(STR0053), oFont4) //Fecha
			oPrinter:Say(Li, IIf(lTamNumOpe, 110, 301), &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":_FECHAPAGO:TEXT"), oFont)

			oPrinter:Say(LI, IIf(lTamNumOpe, 201, 392), OemToAnsi(STR0054), oFont4) //Forma de pago

			cDescrp := cFormPag + " - " + cDesFrmPag
			F815LinCar(oPrinter,LI, IIf(lTamNumOpe, 301, 450), cDescrp, 34, 10, 2, oFont)

			LI += 15
			newPage(oPrinter, ,oXml)
			oPrinter:Say(LI, 15, OemToAnsi(STR0055), oFont4) //Moneda
			oPrinter:Say(Li, 110, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":_MONEDAP:TEXT"), oFont)

			If ObtUidXML(&("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago),"TipoCambioP")
				oPrinter:Say(LI, 201, OemToAnsi(STR0056), oFont4) //Tipo de cambio
				oPrinter:Say(Li, 301, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":_TIPOCAMBIOP:TEXT"), oFont)
				lTipoCambio := .T.
			EndIf

			oPrinter:Say(LI, Iif(lTipoCambio, 392, 201), OemToAnsi(STR0057), oFont4) //Monto
			oPrinter:Say(Li, Iif(lTipoCambio, 492, 301), &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":_MONTO:TEXT"), oFont)
			lTipoCambio := .F.

			If cFormPag $ "02|03|04|05|06|28|29" //Si las formas de pago, son bancarizadas.
				If !Empty(cRFCEmi) .Or. !Empty(cCtaOrd)
					LI += 15
					If !Empty(cRFCEmi)
						oPrinter:Say(LI, 15, OemToAnsi(STR0080), oFont4) //"RFC Emisor"
						oPrinter:Say(Li, 110, cRFCEmi, oFont)
					EndIf
					If !Empty(cCtaOrd)
						oPrinter:Say(LI, 201, OemToAnsi(STR0081), oFont4) //"Cuenta Ordenante"
						oPrinter:Say(Li, 301, cCtaOrd , oFont)
					EndIf
				EndIf
				If !Empty(cRFCBen) .Or. !Empty(cCtaBen)
					Li+=15
					If !Empty(cRFCBen)
						oPrinter:Say(LI, 15, OemToAnsi(STR0082), oFont4) //"RFC Beneficiario"
						oPrinter:Say(Li, 110, cRFCBen, oFont)
					EndIf
					If !Empty(cCtaBen)
						oPrinter:Say(LI, 201, OemToAnsi(STR0083), oFont4) //"Cuenta Beneficiario"
						oPrinter:Say(Li, 301, cCtaBen , oFont)
					EndIf
				EndIf
			EndIf
			If ValType(&("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":"+cNodDcRel)) == "A"
				//Impresion documentos relacionados por pago
				For nJ := 1 To Len(&("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":"+cNodDcRel))
					LI += nEspLi1
					newPage(oPrinter, ,oXml)
					oPrinter:Line(LI, 5, LI, 585, , "-4")

					LI += 10
					newPage(oPrinter, ,oXml)
					oPrinter:Say(LI ,10, OemToAnsi(STR0058) + AllTrim(Str(nJ)), oFont4) //Documento relacionado

					LI += 15
					newPage(oPrinter, ,oXml)
					oPrinter:Say(LI, 15, OemToAnsi(STR0059), oFont4) //Id Documento
					oPrinter:SAY(Li, 70, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":"+cNodDcRel+"[nJ]:_IDDOCUMENTO:TEXT"), oFont)

					oPrinter:Say(LI, 250, OemToAnsi(STR0060), oFont4) //Folio
					oPrinter:SAY(Li, 301, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":"+cNodDcRel+"[nJ]:_FOLIO:TEXT"), oFont)

					oPrinter:Say(LI, 392, OemToAnsi(STR0061), oFont4) //Serie
					oPrinter:SAY(Li, 492, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":"+cNodDcRel+"[nJ]:_SERIE:TEXT"), oFont)

					LI += 15
					newPage(oPrinter, ,oXml)
					If !lVer2CRP
						oPrinter:Say(LI, 15, OemToAnsi(STR0062), oFont4) //Metodo pago
						oPrinter:SAY(Li, 70, oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO10_PAGOS:_PAGO10_PAGO:_PAGO10_DOCTORELACIONADO[nJ]:_METODODEPAGODR:TEXT, oFont)
					EndIf

					If ObtUidXML(&("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":"+cNodDcRel+"[nJ]"), "NumParcialidad")
						oPrinter:Say(LI, 120, OemToAnsi(STR0063), oFont4) //Parcialidad
						oPrinter:SAY(Li, 200, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":"+cNodDcRel+"[nJ]:_NUMPARCIALIDAD:TEXT"), oFont)
						lParcialidad := .T.
					EndIf

					oPrinter:Say(LI, Iif(lParcialidad, 300, 120), OemToAnsi(STR0055), oFont4) //Serie
					oPrinter:SAY(Li, Iif(lParcialidad, 350, 200), &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":"+cNodDcRel+"[nJ]:_MONEDADR:TEXT"), oFont)

					If !lVer2CRP .And. ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO10_PAGOS:_PAGO10_PAGO:_PAGO10_DOCTORELACIONADO[nJ], "TipoCambioDR")
						oPrinter:Say(LI, Iif(lParcialidad, 400, 300), OemToAnsi(STR0056), oFont4) //Tipo de Cambio
						oPrinter:SAY(Li, Iif(lParcialidad, 450, 350), oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO10_PAGOS:_PAGO10_PAGO:_PAGO10_DOCTORELACIONADO[nJ]:_TIPOCAMBIODR:TEXT, oFont)
					ElseIf lVer2CRP .And. ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_PAGO:_PAGO20_DOCTORELACIONADO[nJ], "EquivalenciaDR")
						oPrinter:Say(LI, Iif(lParcialidad, 400, 300), OemToAnsi(STR0141), oFont4) //Equivalencia
						oPrinter:SAY(Li, Iif(lParcialidad, 450, 350), oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_PAGO:_PAGO20_DOCTORELACIONADO[nJ]:_EQUIVALENCIADR:TEXT, oFont)
					EndIf
					lParcialidad := .F.

					LI += 15
					newPage(oPrinter, ,oXml)
					oPrinter:Say(LI, 15, OemToAnsi(STR0064), oFont4) //Saldo
					oPrinter:SAY(Li, 110, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":"+cNodDcRel+"[nJ]:_IMPSALDOANT:TEXT"), oFont)

					oPrinter:Say(LI, 201, OemToAnsi(STR0065), oFont4) //Importe pagado
					oPrinter:SAY(Li, 301, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":"+cNodDcRel+"[nJ]:_IMPPAGADO:TEXT"), oFont)

					oPrinter:Say(LI, 392, OemToAnsi(STR0066), oFont4) //Saldo insoluto
					oPrinter:SAY(Li, 492, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":"+cNodDcRel+"[nJ]:_IMPSALDOINSOLUTO:TEXT"), oFont)
					If lVCFDi40
						F815IMPDR(oPrinter, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:" + cNodPagos + ":" + cNodPago + ":" + cNodDcRel+ "[nJ]"), oXml, @LI)
					EndIf
				Next nJ
			Else
				LI += nEspLi1
				newPage(oPrinter, ,oXml)
				oPrinter:Line(LI, 5, LI, 585, , "-4")

				LI += 10
				newPage(oPrinter, ,oXml)
				oPrinter:Say(LI ,10, OemToAnsi(STR0058) + "1", oFont4) //Documento relacionado

				LI += 15
				newPage(oPrinter, ,oXml)
				oPrinter:Say(LI, 15, OemToAnsi(STR0059), oFont4) //Id Documento
				oPrinter:SAY(Li, 70, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":"+cNodDcRel+":_IDDOCUMENTO:TEXT"), oFont)

				oPrinter:Say(LI, 250, OemToAnsi(STR0060), oFont4) //Folio
				oPrinter:SAY(Li, 301, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":"+cNodDcRel+":_FOLIO:TEXT"), oFont)

				oPrinter:Say(LI, 392, OemToAnsi(STR0061), oFont4) //Serie
				oPrinter:SAY(Li, 492, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":"+cNodDcRel+":_SERIE:TEXT"), oFont)

				LI += 15
				newPage(oPrinter, ,oXml)
				If !lVer2CRP
					oPrinter:Say(LI, 15, OemToAnsi(STR0062), oFont4) //Metodo pago
					oPrinter:SAY(Li, 70, oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO10_PAGOS:_PAGO10_PAGO:_PAGO10_DOCTORELACIONADO:_METODODEPAGODR:TEXT, oFont)
				EndIf

				If ObtUidXML(&("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":"+cNodDcRel), "NumParcialidad")
					oPrinter:Say(LI, 120, OemToAnsi(STR0063), oFont4) //Parcialidad
					oPrinter:SAY(Li, 200, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":"+cNodDcRel+":_NUMPARCIALIDAD:TEXT"), oFont)
					lParcialidad := .T.
				EndIf

				oPrinter:Say(LI, Iif(lParcialidad, 300, 120), OemToAnsi(STR0055), oFont4) //Serie
				oPrinter:SAY(Li, Iif(lParcialidad, 350, 200), &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":"+cNodDcRel+":_MONEDADR:TEXT"), oFont)

				If !lVer2CRP .And. ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO10_PAGOS:_PAGO10_PAGO:_PAGO10_DOCTORELACIONADO, "TipoCambioDR")
					oPrinter:Say(LI, Iif(lParcialidad, 400, 300), OemToAnsi(STR0056), oFont4) //Tipo de Cambio
					oPrinter:SAY(Li, Iif(lParcialidad, 450, 350), oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO10_PAGOS:_PAGO10_PAGO:_PAGO10_DOCTORELACIONADO:_TIPOCAMBIODR:TEXT, oFont)
				ElseIf lVer2CRP .And. ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_PAGO:_PAGO20_DOCTORELACIONADO, "EquivalenciaDR")
					oPrinter:Say(LI, Iif(lParcialidad, 400, 300), OemToAnsi(STR0141), oFont4) //"Equivalencia"
					oPrinter:SAY(Li, Iif(lParcialidad, 450, 350), oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_PAGO:_PAGO20_DOCTORELACIONADO:_EQUIVALENCIADR:TEXT, oFont)
				EndIf

				LI += 15
				newPage(oPrinter, ,oXml)
				oPrinter:Say(LI, 15, OemToAnsi(STR0064), oFont4) //Saldo
				oPrinter:SAY(Li, 110, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":"+cNodDcRel+":_IMPSALDOANT:TEXT"), oFont)

				oPrinter:Say(LI, 201, OemToAnsi(STR0065), oFont4) //Importe pagado
				oPrinter:SAY(Li, 301, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":"+cNodDcRel+":_IMPPAGADO:TEXT"), oFont)

				oPrinter:Say(LI, 392, OemToAnsi(STR0066), oFont4) //Saldo insoluto
				oPrinter:SAY(Li, 492, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":"+cNodDcRel+":_IMPSALDOINSOLUTO:TEXT"), oFont)
				If lVCFDi40
					F815IMPDR(oPrinter, &("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:"+cNodPagos+":"+cNodPago+":"+cNodDcRel), oXml, @LI)
				EndIf
			EndIf
		EndIf
	EndIf

	LI += nEspLi1
	newPage(oPrinter, ,oXml)
	oPrinter:Line(LI, 5, LI, 585, , "-4")

	//CFDI Relacionados
	If XmlChildEx( oXml:_CFDI_COMPROBANTE, "_CFDI_CFDIRELACIONADOS" ) <> Nil
		LI += 10
		newPage(oPrinter, ,oXml)
		oPrinter:Say(LI ,10, OemToAnsi(STR0094), oFont4) //Pago sustituido

		LI += 15
		newPage(oPrinter, ,oXml)
		oPrinter:Say(LI, 15, OemToAnsi(STR0059), oFont4) //Id Documento
		oPrinter:SAY(Li, 70, oXml:_CFDI_COMPROBANTE:_CFDI_CFDIRELACIONADOS:_CFDI_CFDIRELACIONADO:_UUID:TEXT, oFont)

		oPrinter:Say(LI, 250, OemToAnsi(STR0095), oFont4) //Tipo Relación
		oPrinter:SAY(Li, 301, oXml:_CFDI_COMPROBANTE:_CFDI_CFDIRELACIONADOS:_TIPORELACION:TEXT, oFont)
	EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fRodape     ºAutor  ³Luis Samaniego   º Data ³  17/10/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pie de pagina del recibo.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³fRodape(oPrinter,oXML,cNomTmp)                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³oPrinter .- Objeto del informe.                            º±±
±±º          ³oXML     .- Archivo XML.                                   º±±
±±º          ³cNomTmp  .- Nombre del archivo temporal.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Nil                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAFIN/FISA815                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fRodape(oPrinter,oXML,cNomTmp)

	Local nI			 	:= 0
	Local nX				:= 0
	Local cCadAux		  	:= ""
	Local nLiaux			:= 0
	Local nLiAuxIzq 		:= 0

	Private cCadOriSAT := fCadComSAT(oXML)//Cadena original del complemento del certificado digital del SAT

	LI += nEspLi1
	newPage(oPrinter, ,oXml)
	oPrinter:Line(LI,5,LI,585,,"-4")

	newPage(oPrinter, ,oXml)

	oPrinter:Line(LI,5,LI,585,,"-4")
	LI += nEspLi2
	newPage(oPrinter, ,oXml)

	aBlock := LoadBlock(oXML)
	aBlock[1][1] := cCadOriSAT
	If aBlock[4][2] > 815 - LI
		newPage(oPrinter, .T., oXML)
	EndIf
	nLiaux	:= LI

	oPrinter:SAY(LI, 170, OemToAnsi(STR0067), oFont5) //Sello digital del emisor
	oPrinter:SAY(LI, 470, OemToAnsi(STR0068), oFont5) //Fecha de certificación
	nLiaux	:= LI
	LI += nEsp2

	If ObtUidXML(oXML,"SELLOCFD")
		nX := 1
		nLiAuxIzq := Li
		For nI := 1 To aBlock[2][2]
			cCadAux := SubStr(aBlock[2][1],nX,100)
			nX += 100
			oPrinter:SAY(LI, 170, cCadAux, oFont7)
			Li += nEsp1
		Next nI

		If !Empty(aBlock[5][1])
			nX := 1
			For nI := 1 To aBlock[5][2]//2
				cCadAux:= SubStr(aBlock[5][1],nX,100)
				nX += 100
				oPrinter:SAY(nLiAuxIzq,470 ,cCadAux,oFont7)
				nLiAuxIzq += nEsp1
			Next nI
		EndIf
	Else
		Li += nEsp2
	EndIf

	oPrinter:SAY(LI, 170, OemToAnsi(STR0069), oFont5) //Sello digital del SAT
	oPrinter:SAY(LI, 470, OemToAnsi(STR0070), oFont5) //Número fiscal
	LI += nEsp2

	If	ObtUidXML(oXML,"SELLOSAT")
		nX := 1
		nLiAuxIzq := Li
		For nI := 1 To aBlock[3][2]
			cCadAux:= SubStr(aBlock[3][1],nX,100)
			nX += 100
			oPrinter:SAY(LI, 170, cCadAux, oFont7)
			Li += nEsp1
		Next nI

		If lQrCode
			oPrinter:QRCode(nLiaux + 147, 10, aBlock[4][1], 150)
		Else
			oPrinter:QRCode(10, nLiaux + 110, aBlock[4][1], 150)
		EndIf

		If !Empty(aBlock[6][1])
			nX := 1
			For nI := 1 To aBlock[6][2]//2
				cCadAux:= SubStr(aBlock[6][1],nX,100)
				nX += 100
				oPrinter:SAY(nLiAuxIzq, 470, cCadAux, oFont7)
				nLiAuxIzq += nEsp1
			Next nI
		EndIf
	Else
		Li += nEsp1
	EndIF

	oPrinter:SAY(LI, 170, OemToAnsi(STR0075), oFont5) //Cadena Original del complemento de certificación digital del SAT
	oPrinter:SAY(LI, 470, OemToAnsi(STR0072), oFont5) //Núm. Certificado SAT
	LI += nEsp2

	If ObtUidXML(oXML,"tfd:TimbreFiscalDigital")
		nX := 1
		nLiAuxIzq := Li
		For nI := 1 To aBlock[1][2]
			cCadAux := Substr(aBlock[1][1],nX,100)
			nX += 100
			oPrinter:SAY(LI, 170,cCadAux, oFont7)
			Li += nEsp1
		Next nI

		If !Empty(aBlock[7][1])
			nX := 1
			For nI := 1 To aBlock[7][2]//2
				cCadAux := SubStr(aBlock[7][1], nX, 100)
				nX += 100
				oPrinter:SAY(nLiAuxIzq, 470, cCadAux, oFont7)
				nLiAuxIzq += nEsp1
			Next nI
		EndIf
	Else
		Li += nEsp2
	EndIf

	lI += 10
	oPrinter:SAY(lI, 10, OemToAnsi(STR0073), oFont5) //Este documento es una representación impresa de un CFDI
	oPrinter:Line(790, 5, 790, 585, , "-4")
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LoadBlock   ºAutor  ³Luis Samaniego   º Data ³  17/10/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime sello en informe.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³LoadBlock(oXML)                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³oXML  .- Archivo XML.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³aBlock                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAFIN/FISA815                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LoadBlock(oXML)
	Local aBlock	:= {{{}, {}}, {{}, {}}, {{}, {}}, {{}, {}}, {{}, {}}, {{}, {}},{{}, {}}}
	Local nLineas	:= 0
	Local cCadena	:= ""
	Local nX		:= 0
	Local nI		:= 0
	Local nTmp		:= 0
	Local nLiAux	:= 0
	Local cCertSAT	:= ""
	Local cPicture1	:= "999999999999999999.999999"

	nLineas += oFont5:NHEIGHT
	nLineas += nEsp2
	If !Empty(cCadOriSAT)
		nX := 1
		nTmp := (len(cCadOriSAT)/100)	+ 2

		For nI := 1 to nTmp
			cCadAux:= Substr(cCadOriSAT,nX,100)
			nX += 100
			nLineas += oFont7:NHEIGHT
			nLineas += nEsp2
		Next nI

		aBlock[1][1] := cCadOriSAT
		aBlock[1][2] := nTmp
	Else
		nLineas += nEsp2
	EndIf

	nLiAux += oFont5:NHEIGHT
	nLiAux += nEsp2
	If ObtUidXML(oXML,"SELLOCFD")
		cCadena := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_SELLOCFD:TEXT
		nX := 1
		nTmp := (len(cCadena)/100) + 1
		For nI := 1 to nTmp
			cCadAux := Substr(cCadena,nX,100)
			nX+=100
			nLiAux	+= oFont7:NHEIGHT
			nLiAux += nEsp1
		Next nI

		aBlock[2][1] := cCadena
		aBlock[2][2] := nTmp
	Else
		nLiAux += nEsp2
	EndIf

	nLiAux += oFont5:NHEIGHT
	nLiAux += nEsp2

	If ObtUidXML(oXML,"SELLOSAT")
		cCadena := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_SELLOSAT:TEXT

		cCertSAT := cURLValCFD
		cCertSAT += "?id=" + oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT
		cCertSAT += "&re=" + oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_RFC:TEXT
		cCertSAT += "&rr=" + oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_RFC:TEXT
		cCertSAT += "&tt=" + AllTrim(Transform(nValRecibo, cPicture1))
		cCertSAT += "&fe=" + Right(cCadena, 8)

		aBlock[4][1] := CarEspAns(cCertSAT, ,.F.)
		cCadena := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_SELLOSAT:TEXT
		nX := 1
		nTmp := (Len(cCadena) / 100) + 1

		For nI := 1 To  nTmp
			cCadAux := Substr(cCadena, nX, 100)
			nX += 100
			nLiAux += 	oFont7:NHEIGHT
			nLiAux += nEsp1
		Next nI

		aBlock[3][1] := cCadena
		aBlock[3][2] := nTmp
	Else
		nLiAux += nEsp1
	EndIf

	nLiAux += nEsp3
	nLiAux += oFont7:NHEIGHT

	If nLiAux <= 115
		nLineas += 120
	Else
		nLineas += nLiAux
	EndIf

	aBlock[4][2] := nLineas

	If ObtUidXML(oXML, "tfd:TimbreFiscalDigital")
		cCadena := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT
		nX := 1
		nTmp := (Len(cCadena) / 100)

		For nI := 1 to nTmp
			cCadAux := Substr(cCadena, nX, 100)
			nX += 100
			nLineas += oFont7:NHEIGHT
			nLineas += nEsp2
		Next nI

		aBlock[5][1] := cCadena
		aBlock[5][2] := Iif (nTmp>1,nTmp,1)

		cCadena := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT
		nX := 1
		nTmp := (Len(cCadena) / 100)

		For nI := 1 to nTmp
			cCadAux:= Substr(cCadena,nX,100)
			nX += 100
			nLineas += oFont7:NHEIGHT
			nLineas += nEsp2
		Next nI

		aBlock[6][1] := cCadena
		aBlock[6][2] := Iif (nTmp > 1, nTmp, 1)

		cCadena := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_NOCERTIFICADOSAT:TEXT
		nX := 1
		nTmp := (Len(cCadena) / 100)

		For nI := 1 To nTmp
			cCadAux := Substr(cCadena, nX, 100)
			nX += 100
			nLineas += oFont7:NHEIGHT
			nLineas += nEsp2
		End If

		aBlock[7][1] := cCadena
		aBlock[7][2] := Iif (nTmp>1,nTmp,1)
	EndIf

Return aBlock

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ObtUidXML   ºAutor  ³Luis Samaniego   º Data ³  17/10/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca nodo o elemento en el XML                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ObtUidXML(oXML,cNodo)                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³oXML  .- Archivo XML.                                      º±±
±±º          ³cNodo .- Nodo a buscar en XML.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³lRet                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAFIN/FISA815                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ObtUidXML(oXML,cNodo)
	Local cXML     := ""
	Local cError   := ""
	Local cDetalle := ""
	Local lRet     := .F.

	//Es un objeto
	If valType(oXml) == "O"
		SAVE oXML XMLSTRING cXML

		// El archivo tiene errores
		If At("ERROR", Upper(cXML)) > 0
			If 	ValType(oXml:_ERROR) == "O"
				cError := oXml:_ERROR:_CODIGO:TEXT
				cDetalle := oXml:_ERROR:_DESCRIPCIONERROR:TEXT
			Endif
			//Obtener identificador del certificado
		Else
			If At(UPPER(cNodo), Upper(cXml)) > 0
				lRet := .T.
			Endif
		Endif
	Endif
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³newPage     ºAutor  ³Luis Samaniego   º Data ³  17/10/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Comprueba el espacio restante en la pagina y crea el fin   º±±
±±º          ³de pagina y el inicio de la siguiente.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³newPage(oPrinter,lCheck)                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³oPrinter .- Objeto del informe.                            º±±
±±º          ³lCheck   .- Determina si se crea nueva pagina.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAFIN/FISA815                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static Function newPage(oPrinter,lCheck,oXml)
	Local lNewPage := .F.
	Default lCheck := .F.

	If lCheck
		lNewPage := .T.
	Else
		If li >= 790
			lNewPage := .T.
		EndIf
	EndIf

	If lNewPage
		oPrinter:Line(790,5,790,585,,"-4")
		oPrinter:EndPage()
		oPrinter:StartPage()
		LI := 0
		ImpEnc(oPrinter,oXml)
		fLanca(oPrinter,oXML)
		LI += nEspLi1
		oPrinter:Line(LI, 5, LI, 585, , "-4")
		LI += nEspli3
		oPrinter:Line(5,5,790,5,,"-4") //Linea lateral izquierda
		oPrinter:Line(5,585,790,585,,"-4") //Linea lateral derecha
		oPrinter:Line(5,5,5,585,,"-4")//Linea horizontal de marco
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fCarLogo    ºAutor  ³Luis Samaniego   º Data ³  17/10/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Obtiene ruta de la imagen del logo                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³fCarLogo(cLogo)                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cLogo .- Nombre de la imagen del logo                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³cLogo                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAFIN/FISA815                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fCarLogo(cLogo)
	Local cStartPath := GetSrvProfString("Startpath", "")

	cLogo	:= cStartPath + "\LGRL"+ SM0->M0_CODIGO + SM0->M0_CODFIL + ".BMP" // Empresa+Filial
	//-- Logotipo da Empresa
	If !File( cLogo )
		cLogo := cStartPath + "\LGRL" + SM0->M0_CODIGO + ".BMP" // Empresa
	Endif
Return cLogo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fCadComSAT  ºAutor  ³Luis Samaniego   º Data ³  17/10/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cadena original del complemento del certificado digital SATº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³fCadComSAT()                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³oXML .- Archivo XML                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³cCompSAT                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAFIN/FISA815                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fCadComSAT(oXML)
	Local cCompSAT := ""

	If ObtUidXML(oXML, "tfd:TimbreFiscalDigital")
		cCompSAT 	:= "||"
		cCompSAT 	+= oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_VERSION:TEXT + "|"
		cCompSAT 	+= oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT + "|"
		cCompSAT 	+= oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT + "|"
		cCompSAT 	+= oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_RFCPROVCERTIF:TEXT + "|"
		cCompSAT 	+= oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_SELLOCFD:TEXT + "|"
		cCompSAT 	+= oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_NOCERTIFICADOSAT:TEXT
		cCompSAT 	+= "||"
	Endif
Return cCompSAT

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGetDocs    ºAutor  ³Luis Samaniego   º Data ³  17/10/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Obtiene los titulos a saldar y valor del pago              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³fGetDocs()                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aPagos .- Documentos de Pago                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³aTitulos                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAFIN/FISA815                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGetDocs(aPagos)
	Local nI := 0
	Local nJ := 0
	Local nPos := 0
	Local aTitulos := {}

	For nI := 1 To Len(aPagos)
		For nJ := 1 To Len(aPagos[nI][14])
			nPos := aScan(aTitulos, {|x| x[1] == aPagos[nI][14][nJ][3]})
			If nPos == 0
				aAdd(aTitulos, {aPagos[nI][14][nJ][3], aPagos[nI][14][nJ][15], 0, .F.})//Documento, Total Pagado, Saldo Pendiente
			Else
				aTitulos[nPos][2] += aPagos[nI][14][nJ][15]
			EndIf
		Next nJ
	Next nI
Return aTitulos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fArrParce   ºAutor  ³Luis Enriquez    º Data ³  09/11/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carga arreglo en el cual serán buscadas las cuotas cuando  º±±
±±º          ³se utiliza configuracion alfanumerica.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³fArrParce()                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FISA815                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fArrParce()
	Local cAlfa := "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z"
	Local nTamPar := TamSX3("EL_PARCELA")[1]
	Local nTotVal := Val(Replicate('9',nTamPar))
	Local nCont := 0

	aPos := StrTokArr(cAlfa, ",")
	For nCont := 0 To nTotVal
		aAdd(aPos, Padl( Alltrim(str(nCont)), nTamPar, "0" ) )
	EndFor
Return Nil

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³FIS815PatCta³ Autor ³ Oscar Garcia          ³ Data ³ 28.08.18 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Valida que la Cta. Ordenante/Benficiaria cumpla con las cond-³±±
	±±³          ³ iciones del patrón especificado por el SAT. (MEXICO)         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ PatronCta(cCta,cFormaPago)                                   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ cCta .- Cta. a validar                                       ³±±
	±±³          ³ nTipo .- Ordenante o Benficiaria                             ³±±
	±±³          ³ cFPago .- Forma de Pago                                      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ lRet - Devuelve .T. si la cuenta cumple con la estructura    ³±±
	±±³          ³        indicada en la tabla F3I                              ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ FISA815                                                      ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FIS815PatCta(cCta, nTipo, cFPago)

	Local aAux1			:= {{},{},{}}
	Local aAux2			:= {}
	Local nPosIniPat	:= 0
	Local nPosFinPat	:= 0
	Local cPatron		:= ""
	Local cCar			:= ""
	Local aTipo			:= {}
	Local nPosIni		:= 1
	Local nPosFin		:= 0
	Local nPosIni2		:= 0
	Local nPosFin2		:= 0
	Local nX			:= 0
	Local nY			:= 0
	Local nLonCta		:= 0
	Local lRet			:= .F.
	Local lAux			:= .F.
	Local cRet			:= ""
	Local nNumAlf		:= 0
	Local nPosCta 		:= aScan(aCposSEL, IIf(nTipo == 1 , "EL_CTAORD", "EL_CTABEN"))
	Local cMPatron		:= OemToAnsi(STR0088) + " -> " + OemToAnsi(STR0089) + CRLF//" Caracteres "#" Tamaño "
	Local cMensaje		:= ""

	Default cCta		:= ""
	Default nTipo		:= 0
	Default cFPago		:= ""

	cMensaje	:= OemToAnsi(STR0087) + IIf(nTipo == 1, OemToAnsi(STR0081), OemToAnsi(STR0083)) //"Cuenta Ordenante"#"Cuenta Benficiario"
	nPosIniPat	:= IIf(nTipo == 1, 43, IIf(nTipo == 2, 98, 0))
	nPosFinPat	:= IIf(nTipo == 1, 97, IIf(nTipo == 2, 154, 0))
	cRet		:= AllTrim(cCta)
	cPatron		:= AllTrim(ObtColSAT("S005", cFPago, 1, 2, nPosIniPat, nPosFinPat - nPosIniPat))

	If Empty(cPatron) .Or. Empty(cRet)
		Return .T.
	EndIf

	While Len(cPatron) > 0 //Almacena las longitudes admitidas para los valores Numericos/Alfanumericos
		cCar := SubStr(cPatron,nPosIni,1)
		Do Case
		Case cCar == "["
			nPosIni		:= AT("[", cPatron) +1
			nPosFin		:= AT("]", cPatron) - nPosIni
			cMPatron	+= SubStr(cPatron, nPosIni, nPosFin)
			aTipo		:= {}
			aAux2		:= {}
			For nX := nPosIni to AT("]", cPatron)
				nPosIni2 := AT("{", cPatron) + 1
				nPosFin2 := AT("}", cPatron) - nPosIni2
				aAux2 := STRTOKARR(SubStr(cPatron, nPosIni2, nPosFin2),",")
				If IsDigit(SubStr(cPatron,nX,1)) .And. aScan(aTipo, 1) == 0
					aAdd(aAux1[1],STRTOKARR(SubStr(cPatron, nPosIni2, nPosFin2),","))
					aadd(aTipo,1)
				EndIf
				If IsAlpha(SubStr(cPatron,nX,1)) .And. aScan(aTipo, 2) == 0
					aAdd(aAux1[2],STRTOKARR(SubStr(cPatron, nPosIni2, nPosFin2),","))
					aadd(aTipo,2)
				EndIf
			Next
			cMPatron += "->" + aAux2[1] + IiF(Len(aAux2) > 1 ,OemToAnsi(STR0090) + aAux2[1],"") + CRLF
			cPatron := SubStr(cPatron, AT("}", cPatron)+1, Len(cPatron))
			nPosIni := 1
		Case cCar == "|"
			nPosIni++
		EndCase
	EndDo
	nLonCta := Len(cRet) //Longitud de la Cta.
	If IsNumeric(cRet)//Numerico o Alfanumerico
		nNumAlf := 1
	Else
		nNumAlf := 2
	EndIf

	If Len(aAux1[nNumAlf]) == 0
		cMensaje += STR0091 + CRLF //" no cumple con el patrón requerido. "
		cMensaje += cMPatron
		MsgInfo(cMensaje)
		Return lRet
	Else
		For nX := 1 to Len(cRet)
			If (!IsDigit(SubStr(cRet,nX,1)) .And. !IsAlpha(SubStr(cRet,nX,1)) .And. SubStr(cRet,nX,1) <> "_")//Se valida que la cuenta no contenga caracteres no permitidos
				cMensaje += OemToAnsi(STR0085) + CRLF //" contien caracteres no permitidos."
				cMensaje += SubStr(cRet,nX,1)
				cMensaje += cMPatron
				MsgInfo(cMensaje)
				Return lRet
			EndIf
		Next
	EndIf

	For nX := 1 to Len(aAux1[nNumAlf])//Se valida que cumpla la longitud, si es menor, llena con 0 a la izquierda hasta obtener una longitud válida
		If aScan(aAux1[nNumAlf][nX], alltrim(str(nLonCta))) <> 0 //Tamaño igual a alguno de los elementos del array?
			lAux := lRet := .T.
			Exit
		Else
			For nY := 1 To Len(aAux1[nNumAlf][nX])
				If nY > 1
					If Len(cRet) >= Val(aAux1[nNumAlf][nX][1]) .And. Len(cRet) <= Val(aAux1[nNumAlf][nX][2])//Se valida si la longitud se encuentra entre un rango, si es así, no se completa con 0s a la izquierda
						lAux := lRet := .T.
						Exit
					EndIf
				EndIf
				While Len(cRet) < Val(aAux1[nNumAlf][nX][nY]) //Se completa la Cta. con 0s a la izquierda
					cRet := "0" + cRet
					cCta := cRet
					lAux := lRet := .T.
				EndDo
			Next nY
			If lAux
				aCols[n][nPosCta] := cRet
				Exit
			EndIf
		EndIf
	Next nX
	If !lAux
		cMensaje += OemToAnsi(STR0086) + CRLF + cMPatron //" supera longitud máxima permitida."
		MsgInfo(cMensaje)
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGetFilOri  ºAutor  ³Alfredo Medrano  º Data ³  14/09/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Obtiene la Filial Origen del documento                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³fGetFilOri()                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cRecibo  .-  Número de Recibo                              º±±
±±ºParametros³cNum     .-  Número de Titulo                              º±±
±±ºParametros³cPrefix  .-  Prefijo del Titulo                            º±±
±±ºParametros³cParcela .-  Numero de la Cuota                            º±±
±±ºParametros³cTipo    .-  Clase del Titulo                              º±±
±±ºParametros³cSerie   .-  Serie del Documento                           º±±
±±ºParametros³cFilOri  .-  Filial Origen del documento                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Nil                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAFIN/FISA815                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGetFilOri(cRecibo,cNum,cPrefix,cParcela,cTipo,cSerie,cFilOri, lComp)
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local cTmpPer	:= CriaTrab(Nil,.F.)

	Default lComp := .F. //Complemento de tipo Compensacion

	cQuery := "SELECT E5_FILORIG FROM " + RetSqlName("SE5")
	cQuery += " WHERE E5_NUMERO  = '" + cNum + "' "
	cQuery += " AND E5_PREFIXO = '" + cPrefix + "' "
	cQuery += " AND E5_PARCELA = '" + cParcela + "' "
	cQuery += " AND E5_TIPO    = '" + cTipo + "' "
	cQuery += " AND E5_FILIAL  = '" + xFilial("SE5") + "'"
	If !lComp
		cQuery += " AND E5_ORDREC= '" + cRecibo + "' "
		cQuery += " AND E5_SERREC  = '" + cSerie + "' "
	EndIf
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpPer,.T.,.T.)

	If (cTmpPer)->(!EOF())
		cFilOri := (cTmpPer)->E5_FILORIG
	EndIf

	(cTmpPer)->( dbCloseArea())
	RestArea(aArea)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fObtFilSE4  ºAutor  ³Alfredo Medrano  º Data ³  21/09/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Obtiene Condicion de Pago en base a la filial origen       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³fObtFilSE4(cExp1, cExp2)                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cFilOri  .-  Filial Origen                                 º±±
±±ºParametros³cPagSat  .-  Form Pago SAT                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³DistSal                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fObtFilSE4(cFilOri, cPagSat)
	Local aArea		:= GetArea()
	Local cFilAct	:= ""

	Default cFilOri := cFilAnt

	cFilAct := cFilAnt
	cFilAnt := cFilOri

	DbSelectArea("SE4")
	SE4->(DbSetOrder(1)) //"E4_FILIAL+E4_CODIGO"
	If SE4->(DbSeek((xFilial("SE4") + SF2->F2_COND)))
		cPagSat := SE4->E4_MPAGSAT
	EndIf

	cFilAnt	:= cFilAct

	RestArea(aArea)
Return

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³CarEspAns  ³ Autor ³ Oscar Garcia         ³ Data ³ 07.11.18 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Control de caracteres especiales ANSI                      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³CFD - Mexico                                                ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CarEspAns(cTexto,lCodHtml, lConv)
	Local cRet := ""
	Local nChar := 0
	Local aCarEsp := {}
	Local x := 1
	Local y := 2

	Default lCodHtml := .T.
	Default lConv := .T.

	If !Empty(cTexto)
		cRet := cTexto
		If lCodHtml
			Aadd(aCarEsp,{"&","&#38;"})
			Aadd(aCarEsp,{'"',"&#34;"})
			Aadd(aCarEsp,{"<","&#60;"})
			Aadd(aCarEsp,{">","&#62;"})
			Aadd(aCarEsp,{"'","&#39;"})

			If !lConv
				x := 2
				y := 1
			EndIf

			For nChar := 1 To Len(aCarEsp)
				cRet := StrTran(cRet,aCarEsp[nChar,x],aCarEsp[nChar,y])
			Next
		EndIf
	EndIf

Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³F815OriSE1  ³ Autor ³ Luis Enríquez       ³ Fecha ³08/11/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Obtiene origen de la cuenta por cobrar (SE1). (MEX)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F815OriSE1(cPrefixo, cDoc)
	Local cOrigen := ""
	dbSelectArea("SE1")
	SE1->(DbSetOrder(1)) //E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
	If SE1->(DbSeek(xFilial("SE1") + cPrefixo + cDoc))
		cOrigen := SE1->E1_ORIGEM
	EndIf
Return cOrigen

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³F815UUIDRe  ³ Autor ³ Luis Enríquez       ³ Fecha ³29/11/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Obtiene UUID para recibo. (MEX)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F815UUIDRe(cSer, cRec)
	Local cUUID := ""

	DbSelectArea("SEL")
	SEL->(DbSetorder(8)) //EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
	If SEL->(dbSeek(xFilial("SEL") + cSer + cRec))
		If !Empty(SEL->EL_UUID)
			cUUID := SEL->EL_UUID
		EndIf
	EndIf
Return cUUID

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F815LinCar  ºAutor  ³Alfredo Medrano  º Data ³  19/12/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Recorta y divide en líneas impresión de texto FWMSPrinter  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³F815LinCar()                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³oPrinter .-  Objeto Printer                                º±±
±±ºParametros³nLiFP    .-  Posición inicial de la línea                  º±±
±±ºParametros³nColFP   .-  Columna en donde se imprimirá la línea        º±±
±±ºParametros³cDesFP   .-  Cadena Texto a dividir en lineas              º±±
±±ºParametros³nStr     .-  Numero de caracteres por línea                º±±
±±ºParametros³nSalto   .-  Numero de pixeles a imprimir entre líneas     º±±
±±ºParametros³nTotlin  .-  Total de lineas a imprimir                    º±±
±±ºParametros³oFont    .-  Fuente de texto                               º±±
±±ºParametros³nLiSal   .-  Lineas extras que fueron impresas             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Nil                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAFIN/FISA815/fLanca()                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function F815LinCar(oPrinter,nLiFP,nColFP,cDesFP,nStr, nSalto, nTotlin, oFont,nLiSal)
	Local x 		:= 0
	Local y 		:= 1
	Local lBan 		:= .F.
	Local nLineas   := 0
	Local nTamDes	:= 0
	Default nLiSal	:= 0
	Default nLiFP 	:= 0
	Default nColFP	:= 0
	Default nStr	:= 0
	Default nSalto 	:= 0
	Default nTotlin := 0
	nTamDes := LEN(cDesFP)
	If nTamDes > nStr
		For  x := nTamDes  to y step -1
			If  nLineas < nTotlin
				If  (x <= nStr .and. substr(cDesFP, x, 1) == " ")  .OR. (lBan == .T. .and. x <= y + nStr .and. substr(cDesFP, x, 1) == " ")
					If lBan == .T.
						nLineas++
						nLiFP += nSalto
						oPrinter:Say(nLiFP, nColFP, substr(cDesFP, y, x - y), oFont)
					Else
						oPrinter:Say(nLiFP, nColFP, substr(cDesFP, y, x), oFont)
						nLineas++
					EndIf
					y := x +1
					x:= nTamDes
					If Len(substr(cDesFP, y,x )) <= 34
						nLiFP += nSalto
						oPrinter:Say(nLiFP , nColFP, substr(cDesFP, y, x), oFont)
						Exit
					Else
						lBan := .T.
					EndIf
				EndIf
			EndIf
		Next
	Else
		oPrinter:Say(nLiFP, nColFP, cDesFP, oFont)
	EndIf

	nLiSal := nLineas

return

/*/{Protheus.doc} FA815Comp
//Lee movimiento de compensación entre carteras relacionado al título por cobrar.
@author arodriguez
@since 15/05/2019
@version 1.0
@return aCompensa, array, [Fecha, Moneda, Tasa, Valor, Valor moneda 2]
@param cFilDoc, characters, Filial Origen del Documento
@param cCliente, characters, Cliente
@param cLoja, characters, Tienda
@param cSer, characters, Serie
@param cDoc, characters, Documento
@param cParcela, characters, Parcialidad
@param cTipo, characters, Tipo
@param cNumero, characters, Recibo
@param cSerie, characters, Serie recibo
/*/
Static Function FA815Comp(cFilDoc, cCliente, cLoja, cSer, cDoc, cParcela, cTipo, cNumero, cSerie)
	Local aCompensa	:= { CtoD(""), "", 0, 0, 0, "" }
	Local aAreaSE5	:= SE5->(GetArea())
	Local aAreaSF2	:= SF2->(GetArea())
	Local cTemp		:= GetNextAlias()
	Local aStruSE5	:= SE5->(DbStruct())
	Local nX		:= 0
	Local nMonDoc   := 0

	//Moneda del documento
	dbSelectArea("SF2")
	SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	If SF2->(dbSeek(cFilDoc + cDoc + cSer + cCliente + cLoja))
		nMonDoc := SF2->F2_MOEDA
	EndIf

	// Busca registro generado por compensación entre carteras (E5_ORIGEM = 'FINA450')
	SE5->(dbSetOrder(2))	//E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DTOS(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ

	BEGINSQL ALIAS cTemp
		SELECT E5_DATA, E5_MOEDA, E5_TXMOEDA, E5_VALOR, E5_VLMOED2
		FROM %Table:SE5% SE5
        WHERE %notdel%
        AND E5_FILIAL = %xFilial:SE5%
        AND E5_TIPO = %exp:cTipo%
        AND E5_RECPAG = 'R'
        AND E5_TIPODOC = 'BA'
        AND E5_MOTBX = 'CEC'
        AND E5_SITUACA = ''
        AND E5_ORIGEM = 'FINA450'
        AND E5_CLIFOR = %exp:cCliente%
        AND E5_LOJA = %exp:cLoja%
        AND E5_PREFIXO = %exp:cSer%
        AND E5_NUMERO = %exp:cDoc%
        AND E5_PARCELA = %exp:cParcela%
        AND E5_SERCMP = %exp:cSerie%
        AND E5_RECCMP = %exp:cNumero%
	ENDSQL

	For nX := 1 To Len(aStruSE5)
		If Trim(aStruSE5[nX][1]) $ "E5_DATA|E5_TXMOEDA|E5_VALOR|E5_VLMOED2"
			TcSetField(cTemp, aStruSE5[nX][1], aStruSE5[nX][2], aStruSE5[nX][3], aStruSE5[nX][4])
		EndIf
	Next nX

	(cTemp)->(dbGoTop())

	While !(cTemp)->(EOF())
		aCompensa[1] := (cTemp)->E5_DATA
		aCompensa[2] := (cTemp)->E5_MOEDA //Moneda de la Compensación 
		aCompensa[3] := (cTemp)->E5_TXMOEDA
		aCompensa[4] += (cTemp)->E5_VALOR 
		aCompensa[5] += (cTemp)->E5_VLMOED2
		aCompensa[6] := Str(nMonDoc) //Moneda del Documento 
		(cTemp)->(dbSkip())
	EndDo

	(cTemp)->(dbCloseArea())
	SE5->(RestArea(aAreaSE5))
	SF2->(RestArea(aAreaSF2))
Return aCompensa

/*/{Protheus.doc} F815VldTim
Valida si existen recibos sin timbrar que afectan los documentos incluidos en el recibo a timbrar
@type
@author luis.enriquez
@since 05/06/2020
@version 1.0
@param aRegPro, array con los recibos de cobro a timbrar
@return Nil
@example
(examples)
@see (links_or_references)
/*/
Function F815VldTim(aRegPro,aResponse,jData)
	Local lRetVal  := .T.
	Local aArea	   := GetArea()
	Local aFilAct  := FWLoadSM0()
	Local aFilEmp  := {}
	Local aRecibos := {}
	Local nX       := 0
	Local nI       := 0
	Local nY       := 0
	Local cFilSEL  := xFilial("SEL")
	Local aDocRec  := {}
	Local aDocRAux := {}
	Local cAliasQry:= ""
	Local nPosProc := 0
	Local nPosRec  := 0
	Local nPosDoc  := 0
	Default aResponse := {}

	dbSelectArea("SEL")
	SEL->(DbSetOrder(8)) //EL_FILIAL + EL_SERIE + EL_RECIBO + EL_TIPODOC + EL_PREFIXO + EL_NUMERO + EL_PARCELA + EL_TIPO

	dbSelectArea("SE5")
	SE5->(dbSetOrder(7)) // E5_FILIAL + E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO + E5_CLIFOR + E5_LOJA + E5_SEQ

	For nI := 1 To Len(aFilAct)
		If aFilAct[nI][1] == cEmpAnt //Código de Grupo de Empresas
			Aadd(aFilEmp , aFilAct[nI][2])
		EndIf
	Next nI

	For nX := 1 To Len(aRegPro)
		cAliasQry := GetNextAlias()
		aDocRec := F815GetDos(cFilSEL, aRegPro[nX][2], aRegPro[nX][1])
		For nY := 1 To Len(aDocRec)
			BeginSql alias cAliasQry
				Select
					E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_SITUACA, E5_TIPO, E5_MOTBX, E5_ORIGEM, E5_SERREC, E5_ORDREC, E5_VALOR
				From %Table:SE5% SE5
				WHERE E5_FILIAL=%xFilial:SE5%
					AND E5_PREFIXO = %exp:aDocRec[nY][2]%
					AND E5_NUMERO = %exp:aDocRec[nY][3]%
					AND E5_CLIFOR = %exp:aDocRec[nY][4]%
					AND E5_LOJA = %exp:aDocRec[nY][5]%
					AND E5_SITUACA   <> 'C'
					AND E5_TIPO =  %exp:aDocRec[nY][7]%
					AND E5_MOTBX <> 'CEC'
					AND E5_ORIGEM <> 'FINA450'
					AND NOT (E5_SERREC = %exp:aDocRec[nY][8]% AND E5_ORDREC = %exp:aDocRec[nY][9]%)
					AND SE5.%notDel%
			EndSql

			dbselectarea(cAliasQry)
			(cAliasQry)->(dbGoTop())

			While (cAliasQry)->(!eof())
				If SEL->(DbSeek((cAliasQry)->E5_FILIAL + (cAliasQry)->E5_SERREC + (cAliasQry)->E5_ORDREC))
					nPosProc := aScan( aRegPro , {|x| x[2] + x[1] == SEL->EL_SERIE + SEL->EL_RECIBO } )
					If Empty(SEL->EL_FECTIMB) .And. Empty(SEL->EL_UUID) .And. (Dtoc(SEL->EL_DTDIGIT) + SEL->EL_HORA < Dtoc(aRegPro[nX][3]) + aRegPro[nX][4]) .And. nPosProc == 0 .And. !SEL->EL_CANCEL .And. !SEL->EL_GENCFD == 'N'
						aDocRAux := {(cAliasQry)->E5_PREFIXO,(cAliasQry)->E5_NUMERO,(cAliasQry)->E5_VALOR}
						nPosRec := aScan( aRecibos , {|x| x[1] + x[2] == SEL->EL_SERIE + SEL->EL_RECIBO } )
						If nPosRec == 0
							aAdd(aRecibos,{SEL->EL_SERIE,SEL->EL_RECIBO,SEL->EL_DTDIGIT,SEL->EL_HORA,{}})
							aAdd(aRecibos[Len(aRecibos)][5],aDocRAux)
						Else
							nPosDoc := aScan( aRecibos[nPosRec][5] , {|x| x[1] + x[2] == (cAliasQry)->E5_PREFIXO + (cAliasQry)->E5_NUMERO } )
							If nPosDoc == 0
								aAdd(aRecibos[nPosRec][5],aDocRAux)
							EndIf
						EndIf

					EndIf
				EndIf
				aDocRAux := {}
				(cAliasQry)->(dbskip())
			EndDo
			(cAliasQry)->(dbCloseArea())
		Next nY
		aDocRec := {}
	Next nX

	If Len(aRecibos) > 0
		F815MsgObs(aRecibos,@aResponse,jData)
		lRetVal := .F.
	EndIf

	RestArea(aArea)
Return lRetVal

/*/{Protheus.doc} F815GetDos
Obtiene los documentos por recibo
@type
@author luis.enriquez
@since 05/06/2020
@version 1.0
@param cFilSEL, Filial para tabla SEL
@param cSerie, Serie del Recibo de Cobro
@param cRecibo, Folio del Recibo de Cobro
@return aDoc, Array con documentos incluidos en el Recibo de Cobro
@example
(examples)
@see (links_or_references)
/*/
Function F815GetDos(cFilSEL, cSerie, cRecibo)
	Local aArea	   := GetArea()
	Local aDoc := {}
	Local cFilOri  := ""
	Local cAliasSEL := GetNextAlias()

	BeginSql alias cAliasSEL
		Select
			EL_PREFIXO,EL_NUMERO,EL_PARCELA,EL_CLIORIG,EL_LOJORIG,EL_VALOR,EL_TIPO,EL_SERIE,EL_RECIBO
		From %Table:SEL% SEL
		WHERE EL_FILIAL = %xFilial:SEL%
			AND EL_SERIE = %exp:cSerie%
			AND EL_RECIBO = %exp:cRecibo%
			AND EL_FORPGO = ''
			AND SEL.%notDel%
	EndSql

	dbselectarea(cAliasSEL)
	(cAliasSEL)->(dbGoTop())

	While (cAliasSEL)->(!eof())
		fGetFilOri((cAliasSEL)->EL_RECIBO,(cAliasSEL)->EL_NUMERO,(cAliasSEL)->EL_PREFIXO,(cAliasSEL)->EL_PARCELA,(cAliasSEL)->EL_TIPO,(cAliasSEL)->EL_SERIE,@cFilOri)
		If Empty(cFilOri)
			cFilOri := xFilial("SF2")
		EndIf
		aAdd(aDoc,{cFilOri,(cAliasSEL)->EL_PREFIXO,(cAliasSEL)->EL_NUMERO,(cAliasSEL)->EL_CLIORIG,(cAliasSEL)->EL_LOJORIG,(cAliasSEL)->EL_VALOR,(cAliasSEL)->EL_TIPO,(cAliasSEL)->EL_SERIE,(cAliasSEL)->EL_RECIBO})
		(cAliasSEL)->(dbskip())
	EndDo
	(cAliasSEL)->(dbCloseArea())
	RestArea(aArea)
Return aDoc

/*/{Protheus.doc} F815MsgObs
Muestra las observaciones en una lista de texto.
@type
@author luis.enriquez
@since 05/06/2020
@version 1.0
@param aObs, array que contiene las observaciones obtenidas del WS
@return Nil
@example
(examples)
@see (links_or_references)
/*/
Function F815MsgObs(aObs, aResponse, jData)
	Local nI       := 0
	Local nY       := 0
	Local oDlg     := Nil
	Local oSay     := Nil
	Local cMsg     := ""
	Local cEnc     := ""
	Local cFunName := FunName()
	Local cPict    := PesqPict("SE5","E5_VALOR")
	Local cCRLF	   := (chr(13)+chr(10))

	Default	jData  := JsonObject():New()

	CURSORWAIT()

	For nI:=1 to Len(aObs)
		If jData['origin'] ==  "FINA998"
			cEnc += StrTran( STR0101, '###', "" )  + cCRLF
		Else
			cEnc += StrTran( STR0101, '###', cCRLF ) //"Los siguientes recibos deben ser timbrados previamente, para evitar errores de saldos ### en la generación del CFDI:"
		EndIf
	For nI := 1 To Len(aObs)
				cMsg += STR0102 + aObs[nI][1] + "-" + aObs[nI][2] + STR0103 + Dtoc(aObs[nI][3]) + STR0104 + aObs[nI][4] + cCRLF //"Recibo: " # " Fecha: " # " Hora:"
			For nY := 1 To Len(aObs[nI][5])
				cMsg += STR0107 + Alltrim(aObs[nI][5][nY][1]) + "-" + aObs[nI][5][nY][2] + STR0108 +Transform(aObs[nI][5][nY][3],cPict) + cCRLF //"	Documento: " # " Valor: "
			Next nY
		Next nI
		If !(cFunName == "FINA088")
			IF jData['origin'] ==  "FINA998"
				cMsg += ''
			ELSE
				cMsg += cCRLF + STR0105 //"Realizar el proceso de Timbrado del Complemento de Pago desde rutina de Anulación de Cobros Diversos (FINA088)."
			ENDIF
		EndIf
	Next nI

	CURSORARROW()
	If jData['origin'] ==  "FINA998"
		AADD(aResponse,{.T.,400,cEnc,cMsg,jData['receipt']}) 
	Else
		DEFINE MSDIALOG oDlg FROM 0,0 TO 390,440 PIXEL TITLE STR0006 //"Atención"
		oDlg:lMaximized := .F.
		oSay := TSay():New(05,05,{||OemToAnsi(cEnc)},oDlg,,,,,,.T.)
		oMemo:= tMultiget():New(20,05,{|u|IIf(Pcount() > 0, cMsg:=u, cMsg)} ,oDlg,213,155,,.T.,,,,.T.,,,,,,.T.,,,,,.T.)
		oButton := TButton():New(177, 187,STR0106,oDlg,{||oDlg:End()},30,15,,,,.T.) //"Salir"
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf

Return Nil


/*/{Protheus.doc} FIS815ValHr
Valida la Hr introducida en el recibo de cobro.
@type
@author veronica.flores
@since 09/11/2020
@version 1.0
@param cHoraPag, caracter que contiene la hr indicada en el campo EL_HRPAGO
@return lRet .T. o .F.
@example
(examples)
@see (links_or_references)
/*/

Function FIS815ValHr(cHoraPag)
	Local lRet  	:= .T.
	Local cHora 	:= StrZero((Val(SubStr(cHoraPag,1,2))),2,0)
	Local cMin		:= StrZero((Val(SubStr(cHoraPag,4,2))),2,0)
	Local cSeg		:= StrZero((Val(SubStr(cHoraPag,7,2))),2,0)

	If cHora > "24" .Or. cMin > "59" .Or. cSeg > "59"
		MsgAlert(STR109 + cHora + ":" + cMin + ":" + cSeg + STR110) // "La hora indicada " ## " no es válida."
		M->EL_HRPAGO := "12:00:00"
		lRet := .F.
	Else
		M->EL_HRPAGO := cHora + ":" + cMin + ":" + cSeg
	EndIf

Return lRet

/*/{Protheus.doc} ObtClient
Función que retorna el Codigo y tienda del cliente de un recibo de cobro.
@type
@author eduardo.manriquez
@since 20/04/2021
@version 1.0
@param cNumero, caracter, Número de recibo de cobro
@param cSerie, caracter, Serie del recibo de cobro
@return aClient ,array , Arreglo que contiene el codigo y la tienda del cliente
@example
ObtClient(cNumero,cSerie)
@see (links_or_references)
/*/
Function ObtClient(cNumero,cSerie)
	Local aClient := {}
	Local aArea 	:= getArea()
	Default cSerie  := ""
	Default cNumero := ""

	dbSelectArea("SEL")
	SEL->(dbSetOrder(8)) //EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
	If SEL->(dbSeek(xFilial("SEL") + cSerie + cNumero))
		aAdd(aClient,SEL->EL_CLIENTE)
		aAdd(aClient,SEL->EL_LOJA)
	EndIf
	RestArea(aArea)
Return aClient

/*/{Protheus.doc} ObtEmail
Función que retorna el email de un cliente.
@type
@author eduardo.manriquez
@since 20/04/2021
@version 1.0
@param cCliente, caracter,Codigo del cliente
@param cLoja, caracter, Tienda a la que pertene el cliente
@return cEmailCli ,caracter , Email del cliente
@example
ObtEmail(cCliente,cLoja)
@see (links_or_references)
/*/
Function ObtEmail(cCliente,cLoja)
	Local cEmailCli := ""
	Local aArea 	:= getArea()
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	If SA1->(dbSeek(xFilial("SA1") + cCliente + cLoja))
		cEmailCli := SA1->A1_EMAIL
	EndIf
	RestArea(aArea)
Return cEmailCli

/*/{Protheus.doc} EnvRecMail
Función que envia correo electronico con XML y PDF.
@type
@author eduardo.manriquez
@since 20/04/2021
@version 1.0
@param cEmailC, caracter,Correo electronico del cliente
@param aAnexo, array, Arreglo que contiene los archivos XML y PDF
@return
@example
EnvRecMail(cEmailC,aAnexo)
@see (links_or_references)
/*/
Function EnvRecMail(cEmailC, aAnexo, jData,aResponse)
	Local lResult		:= .F.
	Local cServer		:= GetMV("MV_RELSERV",,"" ) //Nombre de servidor de envio de E-mail utilizado en los informes.
	Local cEmail		:= GetMV("MV_RELACNT",,"" ) //Cuenta a ser utilizada en el envio de E-Mail para los informes
	Local cPassword		:= GetMV("MV_RELPSW",,""  ) //Contrasena de cta. de E-mail para enviar informes
	Local lAuth			:= GetMv("MV_RELAUTH",,.F.)	//Servidor de E-Mail necessita de Autenticacao? Determina se o Servidor necessita de Autenticacao;
	Local lUseSSL		:= GetMv("MV_RELSSL",,.F.)	//Define se o envio e recebimento de E-Mail na rotina SPED utilizara conexao segura (SSL);
	Local lTls			:= GetMV("MV_RELTLS",,.F.)	//Informe si el servidor de SMTP tiene conexion del tipo segura ( SSL/TLS ).
	Local nPort			:= GetMv("MV_SRVPORT",,0)	//Puerto de conexion con el servidor de correo
	Local nErr			:= 0
	Local ctrErr		:= ""
	Local oMailServer	:= Nil
	Local cAttach		:= ""
	Local nI			:= 0
	Local cMsg			:= ""
	Local nX			:= 0
	Local cLetFac       := STR0123
	Local cLetPie       := STR0122 + cLetFac
	Local aNomEmp       := {}
	local aRec			:= {}
	local aBodyMail		:= {}

	Default lNoEnvZip	:= .F.
	Default jData		:= JsonObject():New()

	If alltrim(jData["origin"]) == "FINA998"
		aNomEmp := FWSM0Util():GetSM0Data( , alltrim(jData["filial"]) , { "M0_NOME" } )
		cLetFac := STR0150 + " " + jData["serie"] + "-" +jData["recibo"]
		cLetPie := ""
		cLetPie += STR0147
		cLetPie += "<br><br>"
		cLetPie += STR0148 + " " + jData["serie"] + "-" +jData["recibo"]
		cLetPie +=  "<br><br>"
		cLetPie += STR0149
		cLetPie += "<br><br>"
		cLetPie += aNomEmp [1][2]

	EndIf

	If ExistBlock("F998MAIL")

		AADD (aRec,alltrim(jData["serie"]))
		AADD (aRec,alltrim(jData["recibo"]))
		aBodyMail := Execblock("F998MAIL",.f.,.f.,aRec)
		cLetFac :=  aBodyMail[1]
		cLetPie :=  aBodyMail[2]

    EndIf

	If Empty(cServer)
		If jData['origin'] ==  "FINA998"
			cMsg += STR0111 +" - "+ STR0112 // //"Configure parámetro " "MV_RELSERV"
		Else
			cMsg += STR0111 + STR0112 + CHR(13) + CHR(10) //"Configure parámetro " "MV_RELSERV"
		EndIf
	EndIf
	If Empty(cEmail)
		If jData['origin'] ==  "FINA998"
			cMsg += " - "+ STR0111 +" - "+ STR0113 // //"Configure parámetro "  "MV_RELACNT"
		Else
			cMsg += STR0111 + STR0113 + CHR(13) + CHR(10) //"Configure parámetro " "MV_RELACNT"
		EndIf
	EndIf
	If Empty(cPassword)
		If jData['origin'] ==  "FINA998"
			cMsg +=" - "+ STR0111 +" - "+ STR0114 // //"Configure parámetro "  "MV_RELPSW"
		Else
			cMsg += STR0111 + STR0114 + CHR(13) + CHR(10) // "Configure parámetro " "MV_RELPSW"
		EndIf
	EndIf 
	If Empty(cEmailC)
		If jData['origin'] ==  "FINA998"
			cMsg += " - "+ STR0115 +" - "+ IIF(VAZIO(jData['client']),"",jData['client']) // "Configure email del cliente."
		Else
			cMsg += STR0115 + CHR(13) + CHR(10) // "Configure email del cliente."
		EndIf
	EndIf

	If !Empty(cMsg)
		If jData['origin'] ==  "FINA998"
			AADD(aResponse,{.f.,200,cMsg,""})
		Else
			ApMsgInfo(cMsg, STR0116) //"Configuración"
		EndIf
		Return .F.
	EndIf

	For nI:= 1 to Len(aAnexo)
		cAttach += aAnexo[nI] + "; "
	Next nI

	If !lAuth .And. !lUseSSL .And.!lTls
		CONNECT SMTP SERVER cServer ACCOUNT cEmail PASSWORD cPassword RESULT lResult

		If lResult
			SEND MAIL FROM cEmail ;
				TO      	cEmailC;
				BCC     	"";
				SUBJECT 	cLetFac;
				BODY    	cLetPie;
				ATTACHMENT  cAttach  ;
				RESULT lResult

			If !lResult
				//Erro no envio do email
				GET MAIL ERROR cError
				If jData['origin'] ==  "FINA998"
					AADD(aResponse,{.F.,200,STR0120 + cError,""})
				Else
					Help(" ",1,STR0120,,cError,4,5)
				EndIf

			EndIf

		Else
			//Erro na conexao com o SMTP Server
			GET MAIL ERROR cError
			If jData['origin'] ==  "FINA998"
				AADD(aResponse,{.F.,200,STR0120 + cError ,""})
			Else
				Help(" ",1,STR0120,,cError,4,5) //--- Aviso
			EndIf
		EndIf

		DISCONNECT SMTP SERVER

	Else
		//Instancia o objeto do MailServer
		oMailServer:= TMailManager():New()
		oMailServer:SetUseSSL(lUseSSL)    //Obs: Apenas se servidor de e-mail utiliza autenticacao SSL para envio
		oMailServer:SetUseTLS(lTls)       //Obs: Apenas se servidor de e-mail utiliza autenticacao TLS para recebimento

		If Empty(nPort)
			oMailServer:Init("",cServer,cEmail,cPassword,0)
		Else
			oMailServer:Init("",cServer,cEmail,cPassword,0,nPort)
		EndIf

		//Definição do timeout do servidor
		If oMailServer:SetSmtpTimeOut(120) != 0
			If jData['origin'] ==  "FINA998"
				AADD(aResponse,{.F.,200,STR0118,""})
			Else
				Help(" ",1,STR0121,,OemToAnsi(STR0118) ,4,5) //"Aviso" ## "Tiempo de Servidor"
			EndIf
			Return .F.
		EndIf

		//Conexão com servidor
		nErr := oMailServer:smtpConnect()
		If nErr <> 0
			cTrErr:= oMailServer:getErrorString(nErr)
			oMailServer:smtpDisconnect()

			// Intenta (varias veces) el envío a través de otra clase de conexión
			lResult := EnvioMail2(cServer, cEmail, cPassword, lAuth, cEmailC, cLetFac, cLetPie, aAnexo, @cTrErr)

			If !lResult
				If jData['origin'] ==  "FINA998"
					AADD(aResponse,{.F.,200,STR0118,""})
				Else
					Help(" ",1,STR0120,,ctrErr,4,5) //"Aviso"
				EndIf
			EndIf

			Return lResult
		EndIf

		//Autenticação com servidor smtp
		nErr := oMailServer:smtpAuth(cEmail, cPassword)
		If nErr <> 0
			cTrErr := OemToAnsi(STR0119) + CRLF + oMailServer:getErrorString(nErr)
			oMailServer:smtpDisconnect()

			// Intenta (varias veces) el envío a través de otra clase de conexión
			lResult := EnvioMail2(cServer, cEmail, cPassword, lAuth, cEmailC, cLetFac, cLetPie, aAnexo, @cTrErr)

			If !lResult
				If jData['origin'] ==  "FINA998"
					AADD(aResponse,{.F.,200,STR0119 +" : "+ oMailServer:getErrorString(nErr),""})
				Else
					Help(" ",1,STR0121,,cTrErr ,4,5)//"Aviso" ## "Autenticación con servidor smtp"
				EndIf
			EndIf

			Return lResult
		EndIf

		//Cria objeto da mensagem+
		oMessage := tMailMessage():new()
		oMessage:clear()
		oMessage:cFrom 	:= cEmail
		oMessage:cTo 	:= cEmailC
		If !VAZIO(jData['emailcc'])
			oMessage:cCC 	:= jData['emailcc']
		EndIf
		oMessage:cSubject :=  cLetFac
		oMessage:cBody := cLetPie

		For nX := 1 to Len(aAnexo)
			oMessage:AttachFile(aAnexo[nX]) //Adiciona um anexo, nesse caso a imagem esta no root
			oMessage:AddAttHTag("Content-ID: <" + aAnexo[nX] + ">") //Essa tag, é a referecia para o arquivo ser mostrado no corpo, o nome declarado nela deve ser o usado no HTML
		Next nX

		//Dispara o email
		nErr := oMessage:send(oMailServer)
		If nErr <> 0
			cTrErr := oMailServer:getErrorString(nErr)
			If jData['origin'] ==  "FINA998"
				AADD(aResponse,{.F.,200,STR0120+ STR0120,""})
			Else
				Help(" ",1,STR0121,,OemToAnsi(STR0120) + CRLF + STR0120 ,4,5)//"Aviso" ## "Error en el Envio del Email"
			EndIf
			oMailServer:smtpDisconnect()
			Return .F.
		Else
			lResult := .T.
		EndIf

		//Desconecta do servidor
		oMailServer:smtpDisconnect()
	EndIf

Return lResult

/*/{Protheus.doc} EnvioMail2
Función que realiza el reenvio de correo electronico.
@type function
@author eduardo.manriquez
@since 22/04/2021
@version 1.0
@return lógico, envío correcto
@param cMailServer, characters, dirección de servidor de correo
@param cMailConta, characters, usuario de conexión / cuenta de correo remitente
@param cMailSenha, characters, contraseña del usuario
@param lAutentica, logical, requiere autenticación?
@param cEmail, characters, correo destinatario (cliente)
@param cEMailAst, characters, asunto
@param cMensGral, characters, contenido
@param aAnexo, array, array de archivos anexos
@param cErr, characters, (@referencia) variable para mensaje de error
@example
EnvRecMail(cEmailC,aAnexo)
/*/
Static Function EnvioMail2(cMailServer, cMailConta, cMailSenha, lAutentica, cEmail, cEMailAst, cMensGral, aAnexo, cErr)
	Local cAcAut	:= GetMV("MV_RELAUSR",,"" )		//Usuario para autenticacion en el servidor de email
	Local cPwAut 	:= GetMV("MV_RELAPSW",,""  )	//Contraseña para autenticacion en servidor de email
	Local lResult	:= .F.
	Local nIntentos	:= 0

	If lAutentica .And. Empty(cAcAut+cPwAut)
		Return lResult
	EndIf

	Do While !lResult .And. nIntentos < 11
		nIntentos++
		lResult := MailSmtpOn(cMailServer,cMailConta,cMailSenha)

		// Verifica se o E-mail necessita de Autenticacao
		If lResult .And. lAutentica
			lResult := MailAuth(cAcAut,cPwAut)
		Endif

		If lResult
			lResult := MailSend(cMailConta, {cEmail}, {" "}, {" "}, cEMailAst, cMensGral, aAnexo)
		EndIf

		If !lResult
			cErr := MailGetErr()
		EndIf

		MailSmtpOff()
	EndDo

Return lResult

/*/{Protheus.doc} zh_FechaHoraUTC
	Determina fecha y hora en base a diferencia de zona horaria entre la sucursal que genera y la que emite el CFDI
	@type  Static Function
	@author ARodriguez
	@since 05/09/2021
	@version 1.0
	@param cCPGenera, C, CP de la sucursal que genera CFDI
	@param cCPEmite, C, CP de la sucursal que emite CFDI
	@param dFecha, D, Fecha base (dDatabase)
	@param cHora, C, Hora base (GetRmtTime())
	@param cTabela, C, Catálogo de códigos postales ("S004")
	@return return_var, C, Fecha y hora en formato UTC
/*/
Function zh_FechaHoraUTC(cCPGenera, cCPEmite, dFecha, cHora, cTabela)
Local aArea		:= GetArea()
Local cTrb		:= GetNextAlias()
Local cFilF3I	:= xFilial("F3I")
Local cSubstr	:= IIf(AllTrim(Upper(TCGetDB())) == "ORACLE", "SUBSTR", "SUBSTRING")
Local cQry		:= ""
Local cMes		:= ""
Local cDia		:= ""
Local cHra		:= ""
Local cDif		:= ""
Local cSeg		:= ""
Local dFec		:= CtoD("")
Local aFechas	:= {{},{}}

Default dFecha	:= dDataBase
Default cHora	:= GetRmtTime()
Default cTabela	:= "S004"

If !Empty(cCPGenera) .And. !Empty(cCPEmite) .And. !(cCPGenera == cCPEmite)
	// Leer registros de los CP de la sucursal que genera y de la que emite el CFDI
	cQry := " SELECT F3I_CODIGO,F3I_SEQUEN,F3I_CONTEU "
	cQry += " FROM " + RetsqlName("F3I") + " F3I "
	cQry += " WHERE F3I_FILIAL = '" + cFilF3I + "' "
	cQry += " AND F3I_CODIGO = '" + cTabela + "' "
	cQry += " AND " + cSubstr + "(F3I_CONTEU,1,5) IN ('" + Alltrim(cCPGenera) + "','" + Alltrim(cCPEmite) + "')"
	cQry += " AND F3I.D_E_L_E_T_='' "

	cQry := ChangeQuery(cQry)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQry ) ,cTrb, .T., .F.)

	dbSelectArea( cTrb )
	(cTrb)->(dbGoTop())

	While (cTrb)->(!Eof())
		// Fecha de inicio verano
		cMes := zh_ValCampo(cTabela,"MesVer" ,(cTrb)->F3I_CONTEU)
		cDia := zh_ValCampo(cTabela,"DiaVer" ,(cTrb)->F3I_CONTEU)
		cHra := zh_ValCampo(cTabela,"HoraVer",(cTrb)->F3I_CONTEU)
		cDif := zh_ValCampo(cTabela,"DifVer" ,(cTrb)->F3I_CONTEU)
		dFec := zh_FechaIni(cMes, cDia, dFecha)

		If Alltrim(Substr((cTrb)->F3I_CONTEU,1,5)) == Alltrim(cCPGenera)
			// Sucursal que genera
			aAdd( aFechas[1] , {dFec, cHra+":00", cDif} )
		Else
			// Sucursal que emite
			aAdd( aFechas[2] , {dFec, cHra+":00", cDif} )
		EndIf

		// Fecha de inicio invierno
		cMes := zh_ValCampo(cTabela,"MesInv" ,(cTrb)->F3I_CONTEU)
		cDia := zh_ValCampo(cTabela,"DiaInv" ,(cTrb)->F3I_CONTEU)
		cHra := zh_ValCampo(cTabela,"HoraInv",(cTrb)->F3I_CONTEU)
		cDif := zh_ValCampo(cTabela,"DifInv" ,(cTrb)->F3I_CONTEU)
		dFec := zh_FechaIni(cMes, cDia, dFecha)

		If Alltrim(Substr((cTrb)->F3I_CONTEU,1,5)) == Alltrim(cCPGenera)
			// Sucursal que genera
			aAdd( aFechas[1] , {dFec, cHra+":00", cDif} )
		Else
			// Sucursal que emite
			aAdd( aFechas[2] , {dFec, cHra+":00", cDif} )
		EndIf

		(cTrb)->(dBSkip())
	EndDo

	(cTrb)->(dbCloseArea())

	RestArea(aArea)

	/*	aFechas
		+-------------------------------------------------------+-------------------------------------------------------+
		| [1]		Sucursal que genera							| [2]		Sucursal que emite							|
		+-------------------------------------------------------+-------------------------------------------------------+
		| [1,1]		Inicio Verano	| [1,2]		Inicio Invierno	| [2,1]		Inicio Verano	| [2,2] 	Inicio Invierno	|
		+---------------------------+---------------------------+---------------------------+---------------------------+
		| [1,1,1]	Fecha			| [1,2,1]	Fecha			| [2,1,1]	Fecha			| [2,2,1]	Fecha			|
		| [1,1,2]	Hora			| [1,2,2]	Hora			| [2,1,2]	Hora			| [2,2,2]	Hora			|
		| [1,1,3]	Diferencia		| [1,2,3]	Diferencia		| [2,1,3]	Diferencia		| [2,2,3]	Diferencia		|
		+---------------------------+---------------------------+---------------------------+---------------------------+
	*/
	If aFechas[1,1,1] <> aFechas[2,1,1] .Or. aFechas[1,1,3] <> aFechas[2,1,3] .Or. ;
		aFechas[1,2,1] <> aFechas[2,2,1] .Or. aFechas[1,2,3] <> aFechas[2,2,3]
		// Zonas horarias distintas
		// Sucursal que genera
		If DtoS(dFecha)+cHora >= DtoS(aFechas[1,1,1])+aFechas[1,1,2] .And. DtoS(dFecha)+cHora < DtoS(aFechas[1,2,1])+aFechas[1,2,2]
			cHra := aFechas[1,1,3]	// Fecha en horario de verano
		Else
			cHra := aFechas[1,2,3]	// Fecha en horario de invierno
		EndIf
		// Sucursal que emite
		If DtoS(dFecha)+cHora >= DtoS(aFechas[2,1,1])+aFechas[2,1,2] .And. DtoS(dFecha)+cHora < DtoS(aFechas[2,2,1])+aFechas[2,2,2]
			cDif := aFechas[2,1,3]	// Fecha en horario de verano
		Else
			cDif := aFechas[2,2,3]	// Fecha en horario de invierno
		EndIf
		// Diferencia de zona horaria, relativa a UTC
		nDif := Abs(Val(cHra)) - Abs(Val(cDif))
		cSeg := Substr(cHora,6)

		If nDif > 0
			// Sumar horas
			SomaDiaHor( @dFecha, @cHora, nDif )
		ElseIf nDif < 0
			// Restar horas
			SubtDiaHor( @dFecha, @cHora, Abs(nDif) )
		EndIf

		If Len(cHora) == 5
			cHora += cSeg
		Endif
	Endif
EndIf

Return FWTimeStamp(3, dFecha, cHora)

/*/{Protheus.doc} zh_ValCampo
	Obtiene un valor a partir del contenido de un catálogo
	@type Static Function
	@author ARodriguez
	@since 04/09/2021
	@version 1.0
	@param cTabela, C, Catálogo
	@param cCampo, C, Campo
	@param cContenido, C, Contenido
	@return xValor, Variant, Valor del campo
/*/
Static Function zh_ValCampo(cTabela, cCampo, cContenido)
Local cFilF3H	:= xFilial("F3H")
Local nPosIni	:= 1
Local nPosTab	:= 0
Local xValor := ""

Static aTabF3H	:= {}

nPosTab := aScan( aTabF3H , { |x| x[1] == cTabela } )

If nPosTab == 0
	// Carga estructura del catálogo
	aAdd( aTabF3H, { cTabela , {} } )
	nPosTab := Len(aTabF3H)

	F3H->( dbSeek( cFilF3H + cTabela, .T.) )
	While F3H->( !Eof() .And. F3H_FILIAL + F3H_CODIGO == cFilF3H + cTabela )
		F3H->( aAdd( aTabF3H[nPosTab,2], { Upper(Trim(F3H_CAMPOS)), F3H_TIPO, F3H_TAMAN, F3H_DECIMA, nPosIni } ) )
		nPosIni += F3H->F3H_TAMAN
		F3H->( dbSkip() )
	End While
EndIf

nPosIni := aScan( aTabF3H[nPosTab,2], {|aSub| aSub[1]==Upper(cCampo)} )

If nPosIni > 0
	xValor := Substr(cContenido, aTabF3H[nPosTab,2,nPosIni,5], aTabF3H[nPosTab,2,nPosIni,3])

	Do Case
		Case aTabF3H[nPosTab,2,nPosIni,2] == "C"
			// Sin cast
		Case aTabF3H[nPosTab,2,nPosIni,2] == "N"
			xValor := Round(Val(xValor),aTabF3H[nPosTab,2,nPosIni,4])
		Case aTabF3H[nPosTab,2,nPosIni,2] == "D"
			xValor := StoD(xValor)
		Case aTabF3H[nPosTab,2,nPosIni,2] == "L"
			xValor := (xValor=="T" .Or. xValor=="1")
	End Case
EndIf

Return xValor

/*/{Protheus.doc} zh_FechaIni
	Determina fecha de inicio horario verano/invierno en base a parámetros del catálogo de códigos postales
	@type  Static Function
	@author ARodriguez
	@since 04/09/2021
	@version version
	@param cMes, C, Mes
	@param cSemana, C, Día que inicia el horario ("Primer Domingo", "Último Domingo",...)
	@param dFechaBase, D, Fecha para conocer año
	@return dFecha, D, Fecha de inicio de horario
/*/
Static Function zh_FechaIni(cMes, cSemana, dFechaBase)
Local aMeses		:= {"ENERO","FEBRERO","MARZO","ABRIL","MAYO","JUNIO","JULIO","AGOSTO","SEPTIEMBRE","OCTUBRE","NOVIEMBRE","DICIEMBRE"}
Local aSemana		:= {"PRIMER","SEGUNDO","TERCER","CUARTO","ÚLTIMO"}
Local aDias			:= {"DOMINGO","LUNES","MARTES","MIÉRCOLES","JUEVES","VIERNES","SÁBADO"}
Local nAnio			:= 0
Local nMes			:= 0
Local nDia			:= 0
Local nSemana		:= 0
Local nNumSem		:= 0
Local nFor			:= 0
Local dFecha		:= CtoD("")

Default dFechaBase	:= CtoD("")

cMes := Upper(Alltrim(cMes))
cSemana := Upper(Alltrim(cSemana))
nAnio := IIf(Empty(dFechaBase), Year(Date()), Year(dFechaBase))
nMes := aScan( aMeses , {|xMes| xMes==cMes} )
nDia := aScan( aDias , {|xDia| xDia$cSemana} )
nSemana := aScan( aSemana , {|xSemana| xSemana$cSemana} )

If nMes > 0 .And. nDia > 0 .And. nSemana > 0
	dFecha := CtoD( "01/" + StrZero(nMes,2) + "/" + StrZero(nAnio,4) )

	For nFor := 1 to 31
		If Dow(dFecha) == nDia
			nNumSem++
			If nNumSem == nSemana
				Exit
			EndIf
		EndIf
		dFecha++
	Next nFor

EndIf

Return dFecha


/*/{Protheus.doc} F815ElmEsp
Función que elimina los dobles espacios en blanco y saltos de línea.
@type function
@author veronica.flores
@since 14/09/2021
@version 1.0
@return cáracter, cadena de texto sin dobles espacios y saltos de linea
@param cTexto, caracter, cadena de texto que se realizara tratamiento.

/*/
Static Function F815ElmEsp(cTexto)
	Local cRet   := ""
	Default cTexto := ""

	cRet 	:= AllTrim(cTexto)
	cRet	:= Replace(cRet,(chr(13)+chr(10)),'')
	cRet	:= Replace(cRet,'  ',' ')

Return cRet

/*/{Protheus.doc} F815UPDCAN
Función que actualiza estatus de recibo al realizar la cancelación SEL->EL_RETGAN vacío
@type function
@author luis.enriquez
@since 16/02/2022
@version 1.0
@param cSerSus, caracter, Serie el Recibo cancelado.
@param cRecSus, caracter, Folio de Recibo cancelado.
/*/
Static Function F815UPDCAN(cSerSus,cRecSus)
	Local aSELArea := SEL->(GetArea())
	Local cFilSEL  := xFilial("SEL")

	Default cSerSus := ""
	Default cRecSus := ""

	DbSelectArea("SEL")
	SEL->(DbSetOrder(8))//EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
	SEL->(DbSeek(xFilial("SEL") + cSerSus + cRecSus))
		While !(SEL->(EOF())) .And. SEL->(EL_FILIAL + EL_SERIE + EL_RECIBO) == (cFilSEL + cSerSus + cRecSus)
		RecLock("SEL",.F.)
		SEL->EL_RETGAN := ""
		SEL->(MsUnLock())
		SEL->(DbSkip())
	Enddo
	RestArea(aSELArea)
Return Nil

/*/{Protheus.doc} F815ResCan
Lee respuesta/acuse de Cancelación de CFDI de Complemento de Recepción de Pago ante SAT
@type function
@author luis.enriquez
@since 23/02/2022
@version 1.0
@param cRutaSrv, cRutaSrv, Ruta y nombre del acuse de cancelación.
@param cError, caracter, Descripción del error de la lectura el archivo de acuse.
@param cCFDiPAC, caracter, PAC con el que se está realizando la cancelación.
@return lRet, lógico, cuando es .T. la cancelación ante SAT exitoso, en caso contrario .F.
/*/
Static Function F815ResCan(cRutaSrv,cError,cCFDiPAC)
	Local oXMLCan	:= Nil
	Local lRet		:= .F.
	Local cDetalle  := ""
	Local cEstado   := ""
	Local cStatus   := ""

	If Substr(cRutaSrv, 1, 1) == IIf(IsSrvUnix(), "/", "\")
		cRutaSrv := Substr(cRutaSrv, 2)
	Endif

	oXMLCan := XmlParserFile(cRutaSrv, "_", @cError,@cDetalle)

	If ValType(oXMLCan) == "O"
		If XmlChildEx(oXMLCan, "_CLSCANCELA") <> Nil
			If XmlChildEx(oXMLCan:_CLSCANCELA,"_FOLIOS") <> Nil
				If XmlChildEx(oXMLCan:_CLSCANCELA:_FOLIOS,"_FOLIO") <> Nil
					If XmlChildEx(oXMLCan:_CLSCANCELA:_FOLIOS:_FOLIO,"_ESTATUSUUID") <> Nil
						If oXMLCan:_CLSCANCELA:_FOLIOS:_FOLIO:_ESTATUSUUID:TEXT $ "201|202"
							lRet := .T.
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If !lRet .And. UPPER(cCFDiPAC) == "SOLUCIONFACTIBLE"
		// Consulta de estado
		If XmlChildEx(oXMLCan:_CLSESTADO, "_CODIGOESTATUS") <> Nil
			//XML generado por el ejecutable de timbrado
			cEstado := oXMLCan:_CLSESTADO:_ESTADO:Text
			cStatus := oXMLCan:_CLSESTADO:_ESTATUSCANCELACION:Text
		EndIf
		If "CANCELADO" $ Upper(cEstado)
			//"Cancelado"
			If "CANCELADO SIN" $ Upper(cStatus) .Or. "CANCELADO CON" $ Upper(cStatus) .Or. "PLAZO" $ Upper(cStatus)
				lRet := .T.
			EndIf
		EndIf	
	EndIf
	oXMLCan := Nil
Return lRet

/*/{Protheus.doc} F815MOTCAN
Obtiene motivo de Cancelación del Cobro Diverso
@type function
@author luis.enriquez
@since 23/02/2022
@version 1.0
@param cSerSEL, caracter, Serie el Recibo cancelado.
@param cRecSEL, caracter, Folio de Recibo cancelado.
@return cRetMot, caracter, Motivo de Cancelación del Cobro Diverso
/*/
Function F815MOTCAN(cSerSEL, cRecSEL)
	Local cFilSEL := xFilial("SEL")
	Local aSELArea := SEL->(GetArea())
	Local cRetMot := ""

	DbselectArea("SEL")
	SEL->(DbSetOrder(8)) //EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO

	If SEL->(MSseek(cFilSEL + cSerSEL + cRecSEL))
		cRetMot := (SEL->EL_TIPAGRO)
	EndIf
	RestArea(aSELArea)
Return cRetMot

/*/{Protheus.doc} DocsComp
	Obtiene los documentos relacionados a la compensación.
	@type Static Function
	@author oscar.lopez
	@since 11/05/2022
	@version 1.0
	@param aComp, arreglo, Arreglo con la información de la forma de pago de tipo Compensación.
	@param aDocs, arreglo, Arreglo para agregar los documentos relacionados a la compensación..
	@example
		DocsComp(aComp, aDocs)
	/*/
Static Function DocsComp(aComp, aDocs)
	Local cTipos    := "NF|NDC"
	Local cTipo		:= aComp[9]
	Local cPrefijo	:= aComp[6]
	Local cNumero	:= aComp[7]
	Local cFilOri	:= aComp[10]
	Local cClien	:= aComp[11]
	Local cLojClie	:= aComp[12]
	Local cPagSat	:= ""
	Local nValBru	:= 0
	Local nTasaD	:= 0

	If AllTrim(cTipo) $ cTipos
		DbSelectArea("SF2")
		SF2->(DbSetOrder(2)) //F2_FILIAL + F2_CLIENTE + F2_LOJA + F2_DOC + F2_SERIE
		If SF2->(DbSeek((cFilOri + cClien + cLojClie + cNumero + cPrefijo)))
			nTasaD := SF2->F2_TXMOEDA
			nValBru := SF2->F2_VALBRUT
			fObtFilSE4(cFilOri, @cPagSat)
		EndIf
		aAdd(aDocs,{SEL->EL_FILIAL,SEL->EL_RECIBO,aComp[7],aComp[6],aComp[8],aComp[9],SEL->EL_TIPODOC,SEL->EL_EMISSAO,aComp[11],aComp[12],aComp[2],aComp[5],{Iif(aComp[3] == 0, 1, aComp[3]),SEL->EL_TXMOE02,SEL->EL_TXMOE03,SEL->EL_TXMOE04,SEL->EL_TXMOE05},aComp[5],0,cPagSat,nValBru,SEL->EL_CLIENTE,SEL->EL_LOJA,nTasaD,0,Nil,Nil,cFilOri})
	EndIf

Return Nil

/*/{Protheus.doc} F815IMPDOC
	Genera los datos para impuestos del Documento Relacionado.
	@type Static Function
	@author luis.enriquez
	@since 26/08/2022
	@version 1.0
	@param cDoc, caracter, Folio del Documento
	@param cSerie, caracter, Serie del Documento
	@param cCliente, caracter, Código de Cliente del Documento
	@param cLoja, caracter, Código de Tienda del Documento
	@param nVlrBajaD, numérico, Valor de Baja del documento
	@param aNodoTras, arreglo, Arreglo con impuestos de traslado del Documento
	@param aNodoRet, arreglo, Arreglo con retenciones del Documento
	@param nMoedaP, numérico, Moneda del Pago
	@param nMoedaD, numérico, Moneda del Documento
	@param aPagos, arreglo, Arreglo con los datos del Pago
	@param nI, numérico, Posición del Pago
	@param cFilDoc, caracter, Sucursal Origen del Documento
	@param cMoedaSATP, caracter, Moneda SAT del Pago
	@param nTpCamP, numérico, Tipo de Cambio del Pago
	@param nDecPag, numérico, No de Decimales de acuerdo al parámetro MV_PACDEC (2 o 6)
	/*/
Function F815IMPDOC(cDoc, cSerie, cCliente, cLoja, nVlrBajaD, aNodoTras, aNodoRet, nMoedaP, nMoedaD, aPagos, nI, cFilDoc, cMoedaSATP, nTpCamP, nDecPag)
	Local cAliasImp := getNextAlias()
	Local cAliasDet := getNextAlias()
	Local nX        := 0
	Local aImpFact  := {}
	Local cCampos   := ""
	Local cTablas   := ""
	Local cCond     := ""
	Local cGroup    := ""
	Local cOrder    := ""
	Local cTipoImp  := ""
	Local lIncluido := .F.  
	Local nBasImp   := 0
	Local nValImp   := 0
	Local nTotBaseT := 0
	Local nTotImpT  := 0
	Local nTotBaseR := 0
	Local nTotImpR  := 0
	Local nVlrRef   := 0
	Local nVlrBaseP := 0
	Local nVlrImpP  := 0
	Local nPosReg   := 0
	Local cMoedaSATD  := ""
	Local nTasaRec    := 0
	Local nTasaDoc    := 0
	Local nEquiva     := 0
	Local nBaseExe    := 0
	Local nBasePago   := 0
	Local nVlrPago    := 0
	Local nBaseTot    := 0

	Private cRetIVA    := SuperGetMv("MV_RETIVAM",,"") //Retención de IVA - México
	Private cIVATras   := SuperGetMv("MV_IVATRAS",,"") //IVA Trasladado - México

	Default cDoc      := ""
	Default cSerie    := ""
	Default cCliente  := ""
	Default cLoja     := ""
	Default nVlrBajaD := 0
	Default aNodoTras := {} 
	Default aNodoRet  := {}
	Default nMoedaP   := 0
	Default nMoedaD   := 0
	Default aPagos    := {}
	Default nI        := 0
	Default cFilDoc   := xFilial("SD2")
	Default cMoedaSATP:= ""
	Default nTpCamP   := 0
	Default nDecPag   := 2

	aNodoTras := {}
	aNodoRet  := {}

	//Moneda SAT Documento
	cMoedaSATD := F815MOEDA(cFilCTO,StrZero(nMoedaD,2))
	If cMoedaSATP != cMoedaSATD
		nTasaRec := aPagos[nI][13][nMoedaP] //Tasa del recibo correspondiente a la moneda del recibo
		nTasaDoc := aPagos[nI][13][nMoedaD] //Tasa del recibo correspondiente a la moneda del documento relacionado
		If Alltrim(cMoedaSATD) != "MXN" .And. Alltrim(cMoedaSATP) != "MXN"
			nEquiva := nTasaRec/nTasaDoc
		ElseIf Alltrim(cMoedaSATD) != "MXN"
			nEquiva := 1/nTasaDoc
		Else
			nEquiva := nTasaRec
		EndIf
	Else
		nEquiva := 1
	EndIf

	//Impuestos de documento
	cCampos	:= "% SFB.FB_CODIGO, SFB.FB_CPOLVRO, SFB.FB_CLASSE, SFB.FB_IMPSAT, SFB.FB_DESCR, SFB.FB_ALIQ, SFC.FC_IMPOSTO, SFC.FC_INCDUPL  %"
	cTablas	:= "% " + RetSqlName("SD2") + " SD2, "  + RetSqlName("SFC") + " SFC, "  + RetSqlName("SFB") + " SFB %"

	cCond	:= "% SD2.D2_DOC = '" + cDoc + "' AND SD2.D2_SERIE = '" + cSerie + "'"
	cCond  	+= " AND SD2.D2_CLIENTE = '" + cCliente + "' AND SD2.D2_LOJA = '" + cLoja + "'"
	cCond  	+= " AND SD2.D2_TES = SFC.FC_TES "

	cCond 	+= " AND SFC.FC_IMPOSTO = SFB.FB_CODIGO"
	cCond	+= " AND SFC.FC_FILIAL = '" + xFilial("SFC") + "'"
	cCond	+= " AND SFB.FB_FILIAL = '" + xFilial("SFB") + "'"
	cCond	+= " AND SFC.D_E_L_E_T_  = ' ' "
	cCond	+= " AND SFB.D_E_L_E_T_  = ' ' %"
	cGroup 	:= "% SFB.FB_CODIGO, SFB.FB_CPOLVRO, SFB.FB_CLASSE, SFB.FB_IMPSAT, SFB.FB_DESCR, SFB.FB_ALIQ, SFC.FC_IMPOSTO, SFC.FC_INCDUPL %"
	cOrder 	:= "% SFB.FB_CODIGO, SFB.FB_CPOLVRO, SFB.FB_CLASSE, SFB.FB_IMPSAT, SFB.FB_DESCR, SFB.FB_ALIQ, SFC.FC_IMPOSTO, SFC.FC_INCDUPL %"

	BeginSql alias cAliasImp
		SELECT %exp:cCampos%
		FROM  %exp:cTablas%
		WHERE %exp:cCond%
		GROUP BY %exp:cGroup%
		ORDER BY %exp:cOrder%
	EndSql

	dbSelectArea(cAliasImp)
	(cAliasImp)->(DbGoTop())
	While (cAliasImp )->(!Eof())
		cTipoImp := ""
		If (cAliasImp)->FB_CODIGO $ cIVATras //Traslado
			cTipoImp := "T"
			If Alltrim((cAliasImp)->FC_INCDUPL) == "3" //Bandera para impuestos incluido.
				lIncluido := .T.
			EndIf
		ElseIf (cAliasImp)->FB_CODIGO $ cRetIVA //Retenciones
			cTipoImp := "R"
		EndIF
		aAdd(aImpFact,{(cAliasImp)->FB_CPOLVRO,;
		(cAliasImp)->FB_CLASSE,;
		0, ;
		(cAliasImp)->FB_CODIGO,;
		(cAliasImp)->FB_IMPSAT,;
		(cAliasImp)->FB_DESCR,;
		cTipoImp,;
		((cAliasImp)->FB_ALIQ/100),;
		lIncluido,;
		0,;
		0,; //11
		0,; //12
		})
		lIncluido := .F.
		(cAliasImp)->(dbskip())
	EndDo

	(cAliasImp)->(DBCloseArea())

	For nX := 1 To Len(aImpFact)
		//Items de documento
		cCampos	:= "% SD2.D2_COD, SD2.D2_ITEM, SD2.D2_QUANT, SD2.D2_UM, SD2.D2_PRCVEN, SD2.D2_TOTAL TOTAL, SD2.D2_DESCON, D2_PEDISAT, SD2.D2_TES TES"
		cCampos += F815GETCPOS("SD2")
		cCampos	+= " %"
		cTablas	:= "% " + RetSqlName("SD2") + " SD2 %"
		cCond	:= "% SD2.D2_FILIAL = '" + cFilDoc + "' "
		cCond	+= " AND SD2.D2_DOC  = '" + cDoc + "' "
		cCond	+= " AND SD2.D2_SERIE  = '" + cSerie + "' "
		cCond	+= " AND SD2.D2_CLIENTE  = '" + cCliente + "' "
		cCond	+= " AND SD2.D2_LOJA  = '" + cLoja + "' "
		cCond	+= " AND SD2.D_E_L_E_T_  = ' ' %"

		BeginSql alias cAliasDet
			SELECT %exp:cCampos%
			FROM  %exp:cTablas%
			WHERE %exp:cCond%
		EndSql

		dbSelectArea(cAliasDet)
		(cAliasDet)->(DbGoTop())
		While (cAliasDet)->(!Eof())
			//Valida si el impuesto existe en la TES o no tiene impuestos
			aResp := LxIMPTES(aImpFact[nX][4],(cAliasDet)->TES)
			If aResp[1] //Existe impuesto en la TES
				nBasImp := (cAliasDet)->(&("D2_BASIMP" + aImpFact[nX][1])) //Base del impuesto
				nValImp := (cAliasDet)->(&("D2_VALIMP" + aImpFact[nX][1])) //Valor del impuesto
				aImpFact[nX][3] += nValImp
				aImpFact[nX][10] += nBasImp
				If aImpFact[nX][7] == "T" //Traslados
					nTotBaseT += nBasImp
					nTotImpT += (nBasImp + nValImp)
				ElseIf aImpFact[nX][7] == "R" //Retenciones
					nTotBaseR += nBasImp
					nTotImpR += nValImp
				EndIf
			EndIf
			If aResp[2] //Exento
				nTotImpT += (cAliasDet)->TOTAL
				nPosReg := Ascan( aNodoTras, {|x| x[3]  == "Exento" } )
				If nPosReg == 0
					aAdd(aNodoTras,{(cAliasDet)->TOTAL, aImpFact[nX][5], "Exento", 0, 0})
				Else
					aNodoTras[nPosReg][1] += (cAliasDet)->TOTAL
				EndIf
			EndIf
			(cAliasDet)->(dbskip())
		EndDo

		(cAliasDet)->(DBCloseArea())
	Next nX

	If Len(aImpFact) == 0 //Documento sin Impuestos
			//Items de documento
		cCampos	:= "% SD2.D2_COD, SD2.D2_ITEM, SD2.D2_QUANT, SD2.D2_UM, SD2.D2_PRCVEN, SD2.D2_TOTAL TOTAL, SD2.D2_DESCON, D2_PEDISAT, SD2.D2_TES TES"
		cCampos += F815GETCPOS("SD2")
		cCampos	+= " %"
		cTablas	:= "% " + RetSqlName("SD2") + " SD2 %"
		cCond	:= "% SD2.D2_FILIAL = '" + cFilDoc + "' "
		cCond	+= " AND SD2.D2_DOC  = '" + cDoc + "' "
		cCond	+= " AND SD2.D2_SERIE  = '" + cSerie + "' "
		cCond	+= " AND SD2.D2_CLIENTE  = '" + cCliente + "' "
		cCond	+= " AND SD2.D2_LOJA  = '" + cLoja + "' "
		cCond	+= " AND SD2.D_E_L_E_T_  = ' ' %"

		BeginSql alias cAliasDet
			SELECT %exp:cCampos%
			FROM  %exp:cTablas%
			WHERE %exp:cCond%
		EndSql

		dbSelectArea(cAliasDet)
		(cAliasDet)->(DbGoTop())
		While (cAliasDet)->(!Eof())
				nTotImpT += (cAliasDet)->TOTAL
				nPosReg := Ascan( aNodoTras, {|x| x[3]  == "Exento" } )
				If nPosReg == 0
					aAdd(aNodoTras,{(cAliasDet)->TOTAL, "002", "Exento", 0, 0})
				Else
					aNodoTras[nPosReg][1] += (cAliasDet)->TOTAL
				EndIf
			(cAliasDet)->(dbskip())
		EndDo		
	EndIf

	nVlrRef := nVlrBajaD / (nTotImpT-nTotImpR)

	If Len(aNodoTras) > 0
		For nX := 1 To Len(aNodoTras)
			aNodoTras[nX][1] := nVlrRef * aNodoTras[nX][1]
			If nEquiva <> 1 .And. nTpCamP <> nEquiva
				nBaseExe := aNodoTras[nX][1]/Round(nEquiva,6)
			Else
				nBaseExe := xMoeda(aNodoTras[nX][1],nMoedaD,1,,6,nTpCamP)
			EndIf
			If nEquiva <> 1 .And. nTpCamP <> nEquiva
				nBaseTot := aNodoTras[nX][1]/Round(nEquiva,6)
			Else
				nBaseTot := xMoeda(Round(aNodoTras[nX][1],nDecPag),nMoedaD,nMoedaP,,6,,nTpCamP) 
			EndIf
			nPosReg := Ascan( aTotImpT, {|x| x[3]  == "Exento" } )
			If nPosReg == 0
				aAdd(aTotImpT,{nBaseTot, "002", "Exento", 0, 0})
			Else
				aTotImpT[nPosReg][1] += nBaseTot
			EndIf
		Next nX
	EndIF

	For nX := 1 To Len(aImpFact)
		nBasePago   := 0
	    nVlrPago    := 0
		nVlrBaseP := nVlrRef * aImpFact[nX][10] 
		nVlrImpP  := nVlrBaseP * aImpFact[nX][8]

		//Conversión de Monedas de Totales 
		If nEquiva <> 1 .And. nTpCamP <> nEquiva
			nBaseTot := nVlrBaseP/Round(nEquiva,6)
			nVlrTot  := nVlrImpP/Round(nEquiva,6)
		Else
			nBaseTot := xMoeda(Round(nVlrBaseP,6),nMoedaD,1,,6,nTpCamP)
			nVlrTot  := xMoeda(Round(nVlrImpP,6),nMoedaD,1,,6,nTpCamP)
		EndIf
		If nEquiva <> 1 .And. nTpCamP <> nEquiva
			nBasePago := Round(nVlrBaseP,6)/Round(nEquiva,6)
			nVlrPago  := Round(nVlrImpP,2)/Round(nEquiva,6)
		Else
			nBasePago := Round(xMoeda(Round(nVlrBaseP,6),nMoedaD,nMoedaP,,14,,nTpCamP),6)
			nVlrPago  := Round(xMoeda(Round(nVlrImpP,6),nMoedaD,nMoedaP,,14,,nTpCamP),2)
		EndIf

		If aImpFact[nX][7] == "T" //Traslados
			//Tasa Pago
			If nMoedaD <> nMoedaP
				nTasaPago :=  aPagos[nI][13][nMoedaP]
			Else
				nTasaPago := 1
			EndIf
			aAdd(aNodoTras,{nVlrBaseP, aImpFact[nX][5], "Tasa", aImpFact[nX][8], nVlrImpP})
			nPosReg := Ascan( aTotImpT, {|x| x[2] + x[3] + Str(x[4]) == aImpFact[nX][5] + "Tasa" + Str(aImpFact[nX][8])} )
			If nPosReg == 0
				aAdd(aTotImpT,{Round(nBasePago,6),aImpFact[nX][5], "Tasa", aImpFact[nX][8],nVlrPago})
			Else
				aTotImpT[nPosReg][1] += nBasePago
				aTotImpT[nPosReg][5] += nVlrPago
			EndIf
		ElseIf aImpFact[nX][7] == "R" //Retenciones
			aAdd(aNodoRet,{nVlrBaseP, aImpFact[nX][5], "Tasa", aImpFact[nX][8], nVlrImpP})
			nPosReg := Ascan( aTotImpR, {|x| x[2] + x[3] + Str(x[4]) == aImpFact[nX][5] + "Tasa" + Str(aImpFact[nX][8])} )
			If nPosReg == 0
				aAdd(aTotImpR,{Round(nBasePago,nDecPag), aImpFact[nX][5], "Tasa", aImpFact[nX][8],nVlrPago})
			Else
				aTotImpR[nPosReg][1] += Round(nVlrBaseP,6)
				aTotImpR[nPosReg][5] += Round(nVlrImpP,6)
			EndIf
		EndIf	
	Next nX
Return Nil

/*/{Protheus.doc} fGetCpo
  Obtiene los campos VALIMP,BASIMP Y ALQIMP de la tabla dada
  @type function
  @author mayra.camargo
  @since 23/08/2017
  @version 1.0
  @param cTabla, character, Tabla a la cuál se le buscará los campos VALIMP,BASEIMP Y ALQIMP
  @return cCPolvr, ${return_description}
  @example
  (examples)
  @see (links_or_references)
 /*/
Function F815GETCPOS(cTabla)
	Local aArea 	:= getArea()
	Local cCPolvr	:= ""

	dbSelectArea("SX3")
	SX3->(dbSetOrder(1)) // X3_ARQUIVO + X3_ORDEM

	If SX3->(dbSeek(cTabla))
		While SX3->(!eof())  .and. SX3->X3_ARQUIVO == cTabla
			If "_VALIMP" $ SX3->X3_CAMPO .OR. "_ALQIMP" $ SX3->X3_CAMPO .OR. "_BASIMP" $ SX3->X3_CAMPO
				cCPolvr	+= "," + X3_CAMPO
			EndIF
			SX3->(dbSkip())
		Enddo
	EndIF
	RestArea(aArea)
Return cCPolvr

/*/{Protheus.doc} F815MOEDA
  Obtiene la moneda SAT configurada para la moeneda en la tabla CTO
  @type function
  @author luis.enríquez
  @since 22/05/2022
  @version 1.0
  @param cFilCTO, Caracter, Filial de la tabla CTO
  @param cMoneda, Caracter, Código de la Moneda
  @return Nil
  @example
  (examples)
  @see (links_or_references)
 /*/
Function F815MOEDA(cFilCTO, cMoneda)
	Local aAreaCTO	:= CTO->(GetArea())
	Local cMonedaSAT := ""
    
	DbSelectArea("CTO")
	CTO->(DbSetOrder(1)) //CTO_FILIAL+CTO_MOEDA
	If CTO->(MsSeek(cFilCTO + cMoneda))
		cMonedaSAT := Alltrim(CTO->CTO_MOESAT)
	EndIf
	RestArea(aAreaCTO)
Return cMonedaSAT

/*/{Protheus.doc} F815IMPDR
  Imprime los impuestos que aplican para el Documento Relacionado al Pago
  @type function
  @author luis.enríquez
  @since 22/05/2022
  @version 1.0
  @param oPrinter, Objeto, Objeto de impresión FWMsPrinter
  @param oXMLDR, Objeto, Objeto con estructura de Pagos 2.0
  @param oXml, Objeto, Objeto de XML de Complemento de Recepción de Pago
  @param LI, Numérico, Número de Linea a imprimir
  @return Nil
  @example
  (examples)
  @see (links_or_references)
 /*/
Function F815IMPDR(oPrinter, oXMLDR, oXml, LI)
	Local nNetoDR   := 0
	Local nIVADR    := 0
	Local nRetIVADR := 0
	Local nY        := 0
	Local cImtoDR   := ""
	Local cTpoFacDR := ""

	//Impuestos DR
	If XMLChildEx(oXMLDR, "_PAGO20_IMPUESTOSDR") <> Nil
		//Traslados DR
		If XMLChildEx(oXMLDR:_PAGO20_IMPUESTOSDR, "_PAGO20_TRASLADOSDR") <> Nil
			If XMLChildEx(oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_TRASLADOSDR, "_PAGO20_TRASLADODR") <> Nil
				If ValType(oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_TRASLADOSDR:_PAGO20_TRASLADODR) == "A"
					For nY := 1 To Len(oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_TRASLADOSDR:_PAGO20_TRASLADODR)
						If XMLChildEx(oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_TRASLADOSDR:_PAGO20_TRASLADODR[nY], "_IMPUESTODR") <> Nil
							cImtoDR := oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_TRASLADOSDR:_PAGO20_TRASLADODR[nY]:_IMPUESTODR:TEXT
						EndIf 
						If XMLChildEx(oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_TRASLADOSDR:_PAGO20_TRASLADODR[nY], "_TIPOFACTORDR") <> Nil
							cTpoFacDR := oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_TRASLADOSDR:_PAGO20_TRASLADODR[nY]:_TIPOFACTORDR:TEXT
						EndIf
						If cImtoDR == "002" .And. cTpoFacDR == "Tasa".And. XMLChildEx(oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_TRASLADOSDR:_PAGO20_TRASLADODR[nY], "_IMPORTEDR") <> Nil
							nIVADR  += Val(oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_TRASLADOSDR:_PAGO20_TRASLADODR[nY]:_IMPORTEDR:TEXT)
						EndIf
						If cImtoDR == "002" .And. XMLChildEx(oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_TRASLADOSDR:_PAGO20_TRASLADODR[nY], "_BASEDR") <> Nil
							nNetoDR += Val(oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_TRASLADOSDR:_PAGO20_TRASLADODR[nY]:_BASEDR:TEXT)
						EndIf
					Next nY
				Else
					If XMLChildEx(oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_TRASLADOSDR:_PAGO20_TRASLADODR, "_IMPUESTODR") <> Nil
						cImtoDR := oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_TRASLADOSDR:_PAGO20_TRASLADODR:_IMPUESTODR:TEXT
					EndIf 
					If XMLChildEx(oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_TRASLADOSDR:_PAGO20_TRASLADODR, "_TIPOFACTORDR") <> Nil
						cTpoFacDR := oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_TRASLADOSDR:_PAGO20_TRASLADODR:_TIPOFACTORDR:TEXT
					EndIf
					If cImtoDR == "002" .And. cTpoFacDR == "Tasa".And. XMLChildEx(oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_TRASLADOSDR:_PAGO20_TRASLADODR, "_IMPORTEDR") <> Nil
						nIVADR  += Val(oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_TRASLADOSDR:_PAGO20_TRASLADODR:_IMPORTEDR:TEXT)
					EndIf
					If cImtoDR == "002" .And. XMLChildEx(oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_TRASLADOSDR:_PAGO20_TRASLADODR, "_BASEDR") <> Nil
						nNetoDR := Val(oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_TRASLADOSDR:_PAGO20_TRASLADODR:_BASEDR:TEXT)
					EndIf
				EndIf
			EndIf
		EndIf
		//Retenciones DR
		If XMLChildEx(oXMLDR:_PAGO20_IMPUESTOSDR, "_PAGO20_RETENCIONESDR") <> Nil
			If XMLChildEx(oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_RETENCIONESDR, "_PAGO20_RETENCIONDR") <> Nil
				If XMLChildEx(oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_RETENCIONESDR:_PAGO20_RETENCIONDR, "_IMPORTEDR") <> Nil
					nRetIVADR := Val(oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_RETENCIONESDR:_PAGO20_RETENCIONDR:_IMPORTEDR:TEXT)
				EndIf
			EndIf
		EndIf
	EndIf

	LI += 15
	newPage(oPrinter, ,oXml)
	oPrinter:Say(LI, 10, STR0151, oFont4) //"Información de Impuestos"

	LI += 15
	newPage(oPrinter, ,oXml)
	oPrinter:Say(LI, 15, STR0152, oFont4) //"Neto"
	oPrinter:SAY(LI, 110, Str(nNetoDR,18,6), oFont)

	oPrinter:Say(LI, 201, STR0153, oFont4) //"IVA"
	oPrinter:SAY(LI, 301, Str(nIVADR,18,6), oFont)

	oPrinter:Say(LI, 392, STR0154, oFont4) //"Retención de IVA"
	oPrinter:SAY(LI, 492, Str(nRetIVADR,18,6), oFont)
Return Nil

/*/{Protheus.doc} F015CARCHI
	Crea documentos .TXT con datos del archivo XML para validaciones de automatización
	@type  Function
	@author luis.enriquez
	@since 13/07/2022
	@param aRecibos, Arreglo, Arreglo con Datos del Documento.
	@return Nil
/*/
Function F015CARCHI(aRecibos)
	Local cRuta	  := "\baseline\"
	Local nTxt    := 0
	Local cNomTXT := ""
	Local oXMLAut := Nil
	Local cLinea  := ""
	Local cSepara := "|"
	Local nHdl    := 0
	Local cError  := ""
	Local cDetalle := ""
	Local cCRLF	   := (chr(13)+chr(10)) 
	Local nDR      := 0

	For nTxt := 1 To Len(aRecibos)
		cLinea := ""
		oXMLAut := XmlParserFile(cDir + aRecibos[nTxt, 1], "", @cError, @cDetalle )
		If oXMLAut <> Nil
			cNomTXT := Replace(aRecibos[nTxt, 1], ".xml", ".txt")

			nHdl := fCreate(cRuta + cNomTXT)
			If (nHdl >= 0)
				//Encabezado
				cLinea := "Recibo" + cSepara
				If XMLChildEX(oXMLAut:_CFDI_COMPROBANTE, "_SERIE") <> Nil
					cLinea += "Serie" + cSepara + AllTrim(oXMLAut:_CFDI_COMPROBANTE:_SERIE:TEXT) + cSepara
				EndIf
				If XMLChildEX(oXMLAut:_CFDI_COMPROBANTE, "_FOLIO") <> Nil
					cLinea += "Folio" + cSepara + AllTrim(oXMLAut:_CFDI_COMPROBANTE:_FOLIO:TEXT) + cSepara
				EndIf
				fWrite(nHdl,cLinea,Len(cLinea))
				//Pagos
				cLinea := cCRLF + "Pagos" + cSepara
				If XMLChildEX(oXMLAut:_CFDI_COMPROBANTE, "_CFDI_COMPLEMENTO") <> Nil
					If XMLChildEX(oXMLAut:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO, "_PAGO20_PAGOS") <> Nil
						
						If XMLChildEX(oXMLAut:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS, "_PAGO20_TOTALES") <> Nil
							//IVA 0%
							If XMLChildEX(oXMLAut:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_TOTALES, "_TOTALTRASLADOSBASEIVA0") <> Nil
								cLinea += "TotalTrasladosBaseIVA0" + cSepara + oXMLAut:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_TOTALES:_TOTALTRASLADOSBASEIVA0:TEXT + cSepara
							EndIf							

							If XMLChildEX(oXMLAut:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_TOTALES, "_TOTALTRASLADOSIMPUESTOIVA0") <> Nil
								cLinea += "TotalTrasladosImpuestoIVA0" + cSepara + oXMLAut:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_TOTALES:_TOTALTRASLADOSIMPUESTOIVA0:TEXT + cSepara
							EndIf
										
							//IVA 8%
							If XMLChildEX(oXMLAut:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_TOTALES, "_TOTALTRASLADOSBASEIVA8") <> Nil
								cLinea += "TotalTrasladosBaseIVA8" + cSepara + oXMLAut:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_TOTALES:_TOTALTRASLADOSBASEIVA8:TEXT + cSepara
							EndIf							

							If XMLChildEX(oXMLAut:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_TOTALES, "_TOTALTRASLADOSIMPUESTOIVA8") <> Nil
								cLinea += "TotalTrasladosImpuestoIVA8" + cSepara + oXMLAut:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_TOTALES:_TOTALTRASLADOSIMPUESTOIVA8:TEXT + cSepara
							EndIf

							//IVA 16%
							If XMLChildEX(oXMLAut:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_TOTALES, "_TOTALTRASLADOSBASEIVA16") <> Nil
								cLinea += "TotalTrasladosBaseIVA16" + cSepara + oXMLAut:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_TOTALES:_TOTALTRASLADOSBASEIVA16:TEXT + cSepara
							EndIf							
						
							If XMLChildEX(oXMLAut:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_TOTALES, "_TOTALTRASLADOSIMPUESTOIVA16") <> Nil
								cLinea += "TotalTrasladosImpuestoIVA16" + cSepara + oXMLAut:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_TOTALES:_TOTALTRASLADOSIMPUESTOIVA16:TEXT + cSepara
							EndIf

							//Exento
							If XMLChildEX(oXMLAut:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_TOTALES, "_TOTALTRASLADOSBASEIVAEXENTO") <> Nil
								cLinea += "TotalTrasladosBaseIVAExento" + cSepara + oXMLAut:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_TOTALES:_TOTALTRASLADOSBASEIVAEXENTO:TEXT + cSepara
							EndIf

							//Retención IVA
							If XMLChildEX(oXMLAut:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_TOTALES, "_TOTALRETENCIONESIVA") <> Nil
								cLinea += "TotalRetencionesIVA" + cSepara + oXMLAut:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_TOTALES:_TOTALRETENCIONESIVA:TEXT + cSepara
							EndIf
						EndIf
												
						//Monto Total
						If XMLChildEX(oXMLAut:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS, "_PAGO20_TOTALES") <> Nil
							If XMLChildEX(oXMLAut:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_TOTALES, "_MONTOTOTALPAGOS") <> Nil
								cLinea += "MontoTotalPagos" + cSepara + oXMLAut:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_TOTALES:_MONTOTOTALPAGOS:TEXT + cSepara
							EndIf
						EndIf						

						If ValType(oXMLAut:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_PAGO) == "A"
							For nDR := 1 To Len(oXMLAut:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_PAGO)
								F815PAGAUT(&("oXMLAut:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_PAGO[" + Alltrim(Str(nDR)) + "]"), cSepara, cCRLF, @cLinea)
							Next nDR
						Else
							F815PAGAUT(&("oXMLAut:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_PAGO20_PAGOS:_PAGO20_PAGO"), cSepara, cCRLF, @cLinea)
						EndIf
					EndIf
					fWrite(nHdl,cLinea,Len(cLinea))
				EndIf
			EndIf
			
			fClose(nHdl)
		Else
			//Para que entre aquí es mover el parámetro MV_CFDSMAR
			ConOut(STR0155 + cError) //"Ocurrió el siguiente error al leer el archivo XML: "
		EndIf
	Next nTxt
Return Nil

/*/{Protheus.doc} F815PAGAUT
	Obtienes Datos del Pago del Complemento de Recepción de Pago para generación de .TXT de automatización
	@type  Function
	@author luis.enriquez
	@since 13/07/2022
	@param oXMLPag, Objeto, Objeto con la ruta de los Pagos del Complemento de Recepción de Pago
	@param cSepara, String, Caracter de separación "|"
	@param cCRLF, String, Salto de línea
	@param cLinea, String, Contenido de la línea que será generada en archivo .TXT
	@return Nil
/*/
Function F815PAGAUT(oXMLPag, cSepara, cCRLF, cLinea)
	Local nDR := 0

	Default oXMLPag := Nil
	Default cSepara := ""
	Default cCRLF   := ""
	Default cLinea  := ""

	cLinea += cCRLF

	//Forma de Pago
	If XMLChildEX(oXMLPag, "_FORMADEPAGOP") <> Nil
		cLinea += "FormaDePagoP" + cSepara + oXMLPag:_FORMADEPAGOP:TEXT + cSepara
	EndIf
	//Moneda de Pago
	If XMLChildEX(oXMLPag, "_MONEDAP") <> Nil
		cLinea += "MonedaP" + cSepara + oXMLPag:_MONEDAP:TEXT + cSepara
	EndIf
	//Tipo Cambio Pago
	If XMLChildEX(oXMLPag, "_TIPOCAMBIOP") <> Nil
		cLinea += "TipoCambioP" + cSepara + oXMLPag:_TIPOCAMBIOP:TEXT + cSepara
	EndIf
	//Monto Pago
	If XMLChildEX(oXMLPag, "_MONTO") <> Nil
		cLinea += "Monto" + cSepara + oXMLPag:_MONTO:TEXT + cSepara
	EndIf
	If XMLChildEX(oXMLPag, "_NOMBANCOORDEXT") <> Nil
		cLinea += "NomBancoOrdExt" + cSepara + oXMLPag:_NOMBANCOORDEXT:TEXT + cSepara
	EndIf
	If XMLChildEX(oXMLPag, "_RFCEMISORCTABEN") <> Nil
		cLinea += "RfcEmisorCtaBen" + cSepara + oXMLPag:_RFCEMISORCTABEN:TEXT + cSepara
	EndIf
	If XMLChildEX(oXMLPag, "_RFCEMISORCTAORD") <> Nil
		cLinea += "RfcEmisorCtaOrd" + cSepara + oXMLPag:_RFCEMISORCTAORD:TEXT + cSepara
	EndIf
	
	//Saldos
	If XMLChildEX(oXMLPag, "_PAGO20_DOCTORELACIONADO") <> Nil
		If ValType(oXMLPag:_PAGO20_DOCTORELACIONADO) == "A"
			For nDR := 1 To Len(oXMLPag:_PAGO20_DOCTORELACIONADO)
				F815DOCREL(&("oXMLPag:_PAGO20_DOCTORELACIONADO[" + Alltrim(Str(nDR)) + "]"), cSepara, cCRLF, @cLinea)
			Next nDR
		Else
			F815DOCREL(&("oXMLPag:_PAGO20_DOCTORELACIONADO"), cSepara, cCRLF, @cLinea)
		EndIf
	EndIf

	//Impuestos del Pago
	If XMLChildEX(oXMLPag, "_PAGO20_IMPUESTOSP") <> Nil
		If XMLChildEX(oXMLPag:_PAGO20_IMPUESTOSP, "_PAGO20_TRASLADOSP") <> Nil
			If XMLChildEX(oXMLPag:_PAGO20_IMPUESTOSP:_PAGO20_TRASLADOSP, "_PAGO20_TRASLADOP") <> Nil
				If ValType(oXMLPag:_PAGO20_IMPUESTOSP:_PAGO20_TRASLADOSP:_PAGO20_TRASLADOP) == "A"
					For nDR := 1 To Len(oXMLPag:_PAGO20_IMPUESTOSP:_PAGO20_TRASLADOSP:_PAGO20_TRASLADOP)
						F815IMPREL(&("oXMLPag:_PAGO20_IMPUESTOSP:_PAGO20_TRASLADOSP:_PAGO20_TRASLADOP[" + Alltrim(Str(nDR)) + "]"), cSepara, cCRLF, @cLinea,2)
					Next nDR
				Else
					F815IMPREL(&("oXMLPag:_PAGO20_IMPUESTOSP:_PAGO20_TRASLADOSP:_PAGO20_TRASLADOP"), cSepara, cCRLF, @cLinea,2)
				EndIf
			EndIf
		EndIf
	EndIf
Return Nil

/*/{Protheus.doc} F815DOCREL
	Obtienes Datos de Documentos Relacionados del Complemento de Recepción de Pago para generación de .TXT de automatización
	@type  Function
	@author luis.enriquez
	@since 13/07/2022
	@param oXMLDR, Objeto, Objeto con la ruta de los Documentos Relacionados del Complemento de Recepción de Pago
	@param cSepara, String, Caracter de separación "|"
	@param cCRLF, String, Salto de línea
	@param cLinea, String, Contenido de la línea que será generada en archivo .TXT
	@return Nil
/*/
Function F815DOCREL(oXMLDR, cSepara, cCRLF, cLinea)
	Local nI        := 0

	Default oXMLDR  := Nil
	Default cSepara := ""
	Default cCRLF   := ""
	Default cLinea  := ""

	cLinea += cCRLF + "DoctoRelacionado" + cSepara

	If XMLChildEX(oXMLDR, "_SERIE") <> Nil
		cLinea += "Serie" + cSepara + oXMLDR:_SERIE:TEXT + cSepara
	EndIf
	If XMLChildEX(oXMLDR, "_FOLIO") <> Nil
		cLinea += "Folio" + cSepara + oXMLDR:_FOLIO:TEXT + cSepara
	EndIf
	If XMLChildEX(oXMLDR, "_IMPSALDOANT") <> Nil
		cLinea += "ImpSaldoAnt" + cSepara + oXMLDR:_IMPSALDOANT:TEXT + cSepara
	EndIf
	If XMLChildEX(oXMLDR, "_IMPPAGADO") <> Nil
		cLinea += "ImpPagado" + cSepara + oXMLDR:_IMPPAGADO:TEXT + cSepara
	EndIf
	If XMLChildEX(oXMLDR, "_IMPSALDOINSOLUTO") <> Nil
		cLinea += "ImpSaldoInsoluto" + cSepara + oXMLDR:_IMPSALDOINSOLUTO:TEXT + cSepara
	EndIf
	If XMLChildEX(oXMLDR, "_OBJETOIMPDR") <> Nil
		cLinea += "ObjetoImpDR" + cSepara + oXMLDR:_OBJETOIMPDR:TEXT + cSepara
	EndIf
	
	//Impuestos del Documento
	If XMLChildEX(oXMLDR, "_PAGO20_IMPUESTOSDR") <> Nil
		If XMLChildEX(oXMLDR:_PAGO20_IMPUESTOSDR, "_PAGO20_TRASLADOSDR") <> Nil
			If XMLChildEX(oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_TRASLADOSDR, "_PAGO20_TRASLADODR") <> Nil
				If ValType(oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_TRASLADOSDR:_PAGO20_TRASLADODR) == "A"
					For nI := 1 To Len(oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_TRASLADOSDR:_PAGO20_TRASLADODR)
						F815IMPREL(&("oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_TRASLADOSDR:_PAGO20_TRASLADODR[" + Alltrim(Str(nI)) + "]"), cSepara, cCRLF, @cLinea, 1)
					Next nI
				Else
					F815IMPREL(&("oXMLDR:_PAGO20_IMPUESTOSDR:_PAGO20_TRASLADOSDR:_PAGO20_TRASLADODR"), cSepara, cCRLF, @cLinea, 1)
				EndIf																																				
			EndIf
		EndIF
	EndIf
Return Nil

/*/{Protheus.doc} F815IMPREL
	Obtienes Datos de Impuestos del Complemento de Recepción de Pago para generación de .TXT de automatización
	@type  Function
	@author luis.enriquez
	@since 13/07/2022
	@param oXMLImpDR, Objeto, Objeto con la ruta de los impuestos del Documento Relacionado/Pago del Complemento de Recepción de Pago
	@param cSepara, String, Caracter de separación "|"
	@param cCRLF, String, Salto de línea
	@param cLinea, String, Contenido de la línea que será generada en archivo .TXT
	@param nOpc, Numérico, 1 - Impuestos Documento Relacionado y 2 - Impuestos de Pagos
	@return Nil
/*/
Function F815IMPREL(oXMLImpDR, cSepara, cCRLF, cLinea, nOpc)
	Default oXMLImpDR  := ""
	Default cSepara    := ""
	Default cCRLF      := ""
	Default cLinea     := ""
	Default nOpc       := 0

	If nOpc == 1 //Impuestos Documento Relacionado
		cLinea += cCRLF + "TrasladosDR" + cSepara
		If XMLChildEX(oXMLImpDR, "_BASEDR") <> Nil
			cLinea += "BaseDR" + cSepara + AllTrim(oXMLImpDR:_BASEDR:TEXT) + cSepara
		EndIf
		If XMLChildEX(oXMLImpDR, "_IMPORTEDR") <> Nil
			cLinea += "ImporteDR" + cSepara + AllTrim(oXMLImpDR:_IMPORTEDR:TEXT) + cSepara
		EndIf	
		If XMLChildEX(oXMLImpDR, "_IMPUESTODR") <> Nil
			cLinea += "ImpuestoDR" + cSepara + AllTrim(oXMLImpDR:_IMPUESTODR:TEXT) + cSepara
		EndIf	
		If XMLChildEX(oXMLImpDR, "_TASAOCUOTADR") <> Nil
			cLinea += "TasaoCuotaDR" + cSepara + AllTrim(oXMLImpDR:_TASAOCUOTADR:TEXT) + cSepara
		EndIf
		If XMLChildEX(oXMLImpDR, "_TIPOFACTORDR") <> Nil
			cLinea += "TipoFactorDR" + cSepara + AllTrim(oXMLImpDR:_TIPOFACTORDR:TEXT) + cSepara
		EndIf
	ElseIf nOpc == 2 //Impuestos Pago
		cLinea += cCRLF + "TrasladosP" + cSepara
		If XMLChildEX(oXMLImpDR, "_BASEP") <> Nil
			cLinea += "BaseP" + cSepara + Alltrim(oXMLImpDR:_BASEP:TEXT) + cSepara
		EndIf
		If XMLChildEX(oXMLImpDR, "_IMPORTEP") <> Nil
			cLinea += "ImporteP" + cSepara + Alltrim(oXMLImpDR:_IMPORTEP:TEXT) + cSepara
		EndIf		
		If XMLChildEX(oXMLImpDR, "_IMPUESTOP") <> Nil
			cLinea += "ImpuestoP" + cSepara + Alltrim(oXMLImpDR:_IMPUESTOP:TEXT) + cSepara
		EndIf
		If XMLChildEX(oXMLImpDR, "_TASAOCUOTAP") <> Nil
			cLinea += "TasaoCuotaP" + cSepara + Alltrim(oXMLImpDR:_TASAOCUOTAP:TEXT) + cSepara
		EndIf
		If XMLChildEX(oXMLImpDR, "_TIPOFACTORP") <> Nil
			cLinea += "TipoFactorP" + cSepara + Alltrim(oXMLImpDR:_TIPOFACTORP:TEXT) + cSepara
		EndIf
	EndIf	
Return Nil
