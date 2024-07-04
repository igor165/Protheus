#INCLUDE "Fina087a.ch"
#include "PROTHEUS.CH"
#include "FOLDER.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWLIBVERSION.CH"

#DEFINE 	_PL_	chr(13)+chr(10)

STATIC aCtbTmp
STATIC lLojxRMul  	:= ExistFunc("LojxRMul")
STATIC lExistFKD	:= ExistFunc("FAtuFKDBx")
STATIC lExistVa		:= ExistFunc("FValAcess")
Static __lF087EAI 	:= NIL
Static _aPesqPict	:= NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณFINA087A  ณAutor  ณGuilherme C. Leal       ณ Data ณ  05/27/01   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDesc.     ณ Rotina baseada na FINA087. Serve para gera็ใo de Recibos.      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ AP5                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.            	  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador  ณ Data   ณ   BOPS   ณ  Motivo da Alteracao                	  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณJ.Aurelio    ณ01/11/01ณNC001503  ณEm atualizacao bancaria, o "if" so a per-ณฑฑ
ฑฑณ             ณ        ณ          ณmite quando nTipo == 2, e a data de baixaณฑฑ
ฑฑณ             ณ        ณ          ณesta pegando do arquivo SEL.             ณฑฑ
ฑฑณJ.Aurelio    ณ03/12/01ณ11894     ณEm Fa087aTudoOk, nao permitit que se ava ณฑฑ
ฑฑณ             ณ        ณ          ณ-nce p/ segundo processo se data emissao ณฑฑ
ฑฑณ             ณ        ณ          ณestiver vazia.                           ณฑฑ
ฑฑณSergio F.    ณ20/02/02ณ13395     ณAjuste na emissao do Recibo com o tipo   ณฑฑ
ฑฑณ             ณ        ณ          ณ"EF".                                    ณฑฑ
ฑฑณPaulo Aug.   ณ07/08/02ณ          ณInclusao do Cobrador e Calculo da Comis. ณฑฑ
ฑฑณ             ณ        ณ          ณpara ele                                 ณฑฑ
ฑฑณC.Denardi    ณ19/08/03ณ66207     ณInclusao da opcao de modificar as colun. ณฑฑ
ฑฑณ             ณ        ณ          ณexibidas do SA1,SE1, gravando no profile ณฑฑ
ฑฑณC.Denardi    ณ11/09/03ณ66637     ณRetirar campo Memo do TwBrowse em SA1,SE1ณฑฑ
ฑฑณWagner       ณ08/06/10ณ          ณImplementado campo Naatureza no Recibo   ณฑฑ
ฑฑณMontenegro   ณ        ณ          ณImplementado tributa็ใo e contabiliza็ใo ณฑฑ
ฑฑณ             ณ        ณ          ณdo ITF.                                  ณฑฑ
ฑฑณ             ณ        ณ          ณImplementado consistencia na sele็ใo de  ณฑฑ
ฑฑณ             ณ        ณ          ณBancos X Natureza e Bancos X Tipo Valor  ณฑฑ
ฑฑณRenan        ณ14/03/11ณ          ณARG = Novo painel de resumo de reten็๕es ณฑฑ
ฑฑณGuedes       ณ        ณ          ณe simula็ใo da contabiliza็ใo.		      ณฑฑ
ฑฑณMarco A. Glz ณ06/04/17ณ MMI-4476 ณSe replica llamado(TTREB6 - V11.8), El   ณฑฑ
ฑฑณ             ณ        ณ          ณcual prevee la funcionalidad para Certi- ณฑฑ
ฑฑณ             ณ        ณ          ณficados de Retencion SUSS. (ARG)         ณฑฑ
ฑฑณMarco A. Glz ณ27/04/17ณ MMI-4152 ณSe replica llamado(TTXEFA - V11.8),      ณฑฑ
ฑฑณ             ณ        ณ          ณfuncionalidad de calculo de comisiones   ณฑฑ
ฑฑณ             ณ        ณ          ณpara vendedores en base al tipo de cambioณฑฑ
ฑฑณ             ณ        ณ          ณutilizado en la emision de factura. (MEX)ณฑฑ
ฑฑณMarco A. Glz ณ09/05/17ณ  MMI-143 ณSe replica llamado(TTDBMT - V11.8), Se   ณฑฑ
ฑฑณ             ณ        ณ          ณrealiza la denotacion de la rutina de    ณฑฑ
ฑฑณ             ณ        ณ          ณCobros Diversos desde MATA465N. (MEX)    ณฑฑ
ฑฑณL. Samaniego ณ27/09/17ณTSSERMI01 ณModificaciones para Mexico "Complemento  ณฑฑ
ฑฑณ             ณ        ณ-153      ณde Recepi๓n de Pagos                     ณฑฑ
ฑฑณL. Samaniego ณ21/12/17ณDMICNS-445ณSe modifica cuando pertenece a pais CHILEณฑฑ
ฑฑณ             ณ        ณ          ณy el arreglo anBaixa pierde Decimales aunณฑฑ
ฑฑณ             ณ        ณ          ณcuando no se contienen decimales en las  ณฑฑ
ฑฑณ             ณ        ณ          ณposiciones del Arreglo.                  ณฑฑ
ฑฑณ  Marco A.   ณ19/02/18ณDMINA-556 ณSe replican para V12.1.17, los issues:   ณฑฑ
ฑฑณ             ณ        ณ          ณ DMINA-385, DMINA-602,  DMINA-723,       ณฑฑ
ฑฑณ             ณ        ณ          ณ DMINA-814, DMINA-1171, DMINA-1223,      ณฑฑ
ฑฑณ             ณ        ณ          ณ DMINA-1255, DMINA-1166 y DMINA-1093;    ณฑฑ
ฑฑณ             ณ        ณ          ณ para Complemento de Pago CFDI 3.3 (MEX) ณฑฑ
ฑฑณMarcos Aur   ณ22/03/18ณDMICNS-   ณEfetuado ajustes para uso de tabelas     ณฑฑ
ฑฑณ             ณ        ณ  1588    ณtemporarias - Arg                        ณฑฑ
ฑฑณLuis Enriquezณ05/04/18ณDMINA-2437ณSe agregan cambios de soluci๓n del issue ณฑฑ
ฑฑณ             ณ        ณ          ณMMI-6165 error log recibos con ret. (PER)ณฑฑ
ฑฑณLuis Enriquezณ24/04/18ณDMINA-2636ณSe elimina paํs VEN de bifurcaci๓n en la ณฑฑ
ฑฑณ             ณ        ณ          ณfunc. Fa087aSalvar para permitir genera- ณฑฑ
ฑฑณ             ณ        ณ          ณci๓n de RA sin documentos. (VEN)         ณฑฑ
ฑฑณLuis Enriquezณ17/05/18ณDMINA-3080ณSe agrega funcionalidad a rutina para queณฑฑ
ฑฑณ             ณ        ณ          ณsea utilizada como Adapter de integraci๓nณฑฑ
ฑฑณ             ณ        ณ          ณEAI para baja de tํtulos generados desde ณฑฑ
ฑฑณ             ณ        ณ          ณotros sistemas marca Totvs (MEX)         ณฑฑ
ฑฑณOscar Garcia ณ31/05/18ณDMINA-3209ณSe muestra Serie2 en pantalla registro deณฑฑ
ฑฑณ           	ณ        ณ        	ณimportes de ret. y se guarda FE_SERIE2   ณฑฑ
ฑฑณ           	ณ        ณ        	ณcon valor de parแmetro MV_CRSERIE (PER)  ณฑฑ
ฑฑณOscar Garcia ณ23/06/18ณDMINA-2916ณCorreci๓n DMINA-2898 En func. Fa087aRet  ณฑฑ
ฑฑณ           	ณ        ณ        	ณse hace modificaci๓n para obtener serie 2ณฑฑ
ฑฑณ           	ณ        ณ        	ณde acuerdo a pos en aCposSE1 (PER)       ณฑฑ
ฑฑณ           	ณ        ณ       	ณvalide solo los doctos de tipo NF NCC NCDณฑฑ
ฑฑณM.Camargo 	ณ06/04/18ณDMINA-3465ณMex. func FA087aHead asigna Campos Memo  ณฑฑ
ฑฑณ           	ณ        ณ        	ณEn func Fa087aLinOk se validan campos CEPณฑฑ
ฑฑณ           	ณ        ณ        	ณSe agrega func FN087AWHEN que activa o   ณฑฑ
ฑฑณ           	ณ        ณ        	ณdesactiva los campos Relacionados al CEP ณฑฑ
ฑฑณ          	ณ        ณ        	ณSe documenta indice SX3 en Fa087aLinOk   ณฑฑ
ฑฑณ          	ณ        ณ        	ณSe modifica funci๓n Fa087aSalvar,        ณฑฑ
ฑฑณ          	ณ        ณ        	ณal momento de generar el registro en SEL ณฑฑ
ฑฑณ          	ณ        ณ        	ณpara el tํtulo en baja coloca el cliente ณฑฑ
ฑฑณ             ณ        ณ          ณy tienda origen en los campos EL_CLIENTE ณฑฑ
ฑฑณ             ณ        ณ          ณy EL_LOJA, y viceversa.                  ณฑฑ
ฑฑณGSantacruz	ณ03/07/18ณ        	ณVenezuela: Para pagos de tipo IR no debe ณฑฑ
ฑฑณ             ณ        ณ          ณguardar retenciones (SFE).               ณฑฑ
ฑฑณ  Marco A.   ณ11/07/18ณDMANSISTE-ณSe reliza replica de solucion realizada  ณฑฑ
ฑฑณ             ณ        ณ21        ณen issue DMINA-1340 (V12.1.14). Grabacionณฑฑ
ฑฑณ             ณ        ณ          ณcorrecta de E5_DOCUMEN. (MEX)            ณฑฑ
ฑฑณLuisEnrํquez ณ19/07/18ณDMINA-3630ณse modifica la funcion A087aPagtos para  ณฑฑ
ฑฑณ             ณ        ณ          ณgenerar la RA, al compensar el anticipo yณฑฑ
ฑฑณ             ณ        ณ          ณy se agrega la funcion fVerifImp la cual ณฑฑ
ฑฑณ             ณ        ณ          ณvalida la resta o no del IGV a generar laณฑฑ
ฑฑณ             ณ        ณ          ณRA del anticipo.                         ณฑฑ
ฑฑณ    Nancy    ณ24/07/18ณDMANSISTE-ณSe agrega validacion, para no solicitar  ณฑฑ
ฑฑณ             ณ        ณ36        ณel procedo de timbrado mas de una vez,   ณฑฑ
ฑฑณ             ณ        ณ          ณtras compensar NCC. (MEX)                ณฑฑ
ฑฑณLuis Enrํquezณ23/08/18ณDMINA-3641ณSe agrega validaci๓n para que s๓lo si se ณฑฑ
ฑฑณ             ณ        ณ          ณdan de baja titulos de origen FINI05 o   ณฑฑ
ฑฑณ             ณ        ณ          ณFINI040 se dispare integraci๓n EAI (MEX) ณฑฑ
ฑฑณOscar Garcia ณ03/09/18ณDMINA-3912ณSe llama la funci๓n FIS815PatCta() para  ณฑฑ
ฑฑณ           	ณ        ณ        	ณvalidar los campos EL_CTAORD y EL_CTABEN ณฑฑ
ฑฑณ           	ณ        ณ        	ณen funcion FN087AWHEN()                  ณฑฑ
ฑฑณ   Marco A.  ณ07/09/18ณDMINA-3961ณSe modifica Func FN087AWHEN()cuando Formaณฑฑ
ฑฑณ             ณ        ณ          ณPago = Cheque(02) se obtienen Valores delณฑฑ
ฑฑณ             ณ        ณ          ณBanco Cheque, si ้ste no tiene valores   ณฑฑ
ฑฑณ             ณ        ณ          ณse obtienen del Banco beneficiario veri- ณฑฑ
ฑฑณ             ณ        ณ          ณficando si el banco es Extranjero.  (MEX)ณฑฑ
ฑฑณOscar Garcia ณ21/09/18ณDMINA-3950ณSe modifica func Fa087aSalvar para no so-ณฑฑ
ฑฑณ             ณ        ณ          ณlicitar confirmacion al generar compleme-ณฑฑ
ฑฑณ             ณ        ณ          ณnto si parametro MV_CFDREC == 1          ณฑฑ
ฑฑณOscar Garcia ณ27/09/18ณDMINA-4214ณA la funciion GETUIID se le pasa como pa-ณฑฑ
ฑฑณ             ณ        ณMEX       ณrametro la filial de SE1, contenida en elณฑฑ
ฑฑณ             ณ        ณ          ณarreglo. Replica DMINA-4081              ณฑฑ
ฑฑณ  Marco A.   ณ01/10/18ณDMINA-4322ณSe replica a V12.1.17, la solucion reali-ณฑฑ
ฑฑณ             ณ        ณ          ณzada en DMINA-4354 de V11.8. (MEX)       ณฑฑ
ฑฑณVeronica F.  ณ19/10/18ณDMINA-3975ณSe replica a v12.1.17, la solucion reali-ณฑฑ
ฑฑณ             ณ        ณ          ณzada en DMINA-3439 y del DMINA-3969      ณฑฑ
ฑฑณ             ณ        ณ          ณde v12.1.14 (PER)                        ณฑฑ
ฑฑณLuis Enrํquezณ24/10/18ณDMINA-4839ณSe modifica GetUUID para tomar en cuenta  ฑฑ
ฑฑณ             ณR้plica ณDMINA-4615ณPE A087TIPTI para validar que docs se en-ณฑฑ
ฑฑณ             ณ        ณ        	ณcuentre timbrado, tipos FI (MEX)         ณฑฑ
ฑฑณM.Camargo    ณ07/11/18ณDMINA-4839ณSe modifica funci๓n MontaTela para quitar|ฑฑ
ฑฑณ             ณ        ณ        	ณcondici๓n de llenado de array aCposSE1   ณฑฑ
ฑฑณ             ณ        ณ        	ณpara que siempre considere campo filial  ณฑฑ
ฑฑณ             ณ        ณ        	ณindependiente del parแmetro MV_PAR09     ณฑฑ
ฑฑณ             ณ        ณ        	ณฟConsidera Filial?                       ณฑฑ
ฑฑณLuis Enrํquezณ08/11/18ณDMINA-5004ณSe modifica GetUUID para validar timbradoณฑฑ
ฑฑณ             ณ        ณ          ณde docs generados en SIGALOJA con usuarioณฑฑ
ฑฑณ             ณ        ณ          ณcaja y no caja.                  (MEX)   ณฑฑ
ฑฑณLuis Enrํquezณ29/11/18ณDMINA-4830ณSe activan campos EL_SERSUS y EL_RECSUS  ณฑฑ
ฑฑณ             ณ        ณ          ณy se agrega func. F87AValRec para funcio-ณฑฑ
ฑฑณ             ณ        ณ          ณde documentos relacionados CFDI 3.3 (MEX)ณฑฑ
ฑฑณM.Camargo    ณ06/12/18ณDMINA-5205ณSe agregan todas las formas de pago ban- ณฑฑ
ฑฑณ             ณ        ณ          ณcarizadas que indiques cuanta ordenante yณฑฑ
ฑฑณ             ณ        ณ          ณrfc cuenta ordenante igual que forma de  ณฑฑ
ฑฑณ             ณ        ณ          ณpago cheque en la funci๓n  FN087AWHEN    ณฑฑ
ฑฑณAlf. Medrano ณ08/01/19ณTSMI01_17 ณModifica GetUUID se asigna cFil en DbSeekณฑฑ
ฑฑณ             ณ        ณ          ณde SF1 y SF2                             ณฑฑ
ฑฑณVer๓nica F.  ณ10/01/19ณDMINA-5732ณSe replica a v12.1.17, la solucion       ณฑฑ
ฑฑณ             ณ        ณ          ณrealizada en DMINA-4824 de v.12.1.14(MEX)ณฑฑ
ฑฑณ   Marco A.  ณ18/01/19ณDMINA-5246ณSe agrega funcionalidad para definir si  ณฑฑ
ฑฑณLuis Enriquezณ        ณ          ณun recibo de cobro, genera CFDI. (MEX)   ณฑฑ
ฑฑณGsantacruz   ณ20/03/19ณDMINA-6348ณSe eliminan los cambios realizados en    ณฑฑ
ฑฑณ             ณ        ณ          ณDMINA-5732.   Mex.                       ณฑฑ
ฑฑณDouglas      ณ08/05/19ณ          ณFa087aLinOk() - No ejecuta TelaAdmCar()  ณฑฑ
ฑฑณGoncalves de Souza    ณ          ณsi no existe Banco de Caja.   Brasil.    ณฑฑ
ฑฑณGsantacruz   ณ08/05/19ณDMINA-6713ณfVldGenCFD() Comp NCC, aplica tasa cambioณฑฑ
ฑฑณ             ณ        ณ          ณCambia condici๓n de compensaci๓n.   Mex. ณฑฑ
ฑฑณARodriguez   ณ14/05/19ณDMINA-6586ณNuevo campo en Enc para identificar cobroณฑฑ
ฑฑณ             ณ        ณ          ณpor factoraje.   Mex.                    ณฑฑ
ฑฑณLuis Enrํquezณ15/05/19ณDMINA-6614ณSe agrega funcionalidad de generaci๓n de ณฑฑ
ฑฑณ             ณ        ณ          ณRA para baja de tํtulos de tipo DGA.(MEX)ณฑฑ
ฑฑณDiego Rivera ณ24/06/19ณDMINA-6898ณSe reasigna la funci๓n de avanzar a la   ณฑฑ
ฑฑณ             ณ        ณ          ณa la combinaci๓n de teclas Ctrl+A para   ณฑฑ
ฑฑณ             ณ        ณ          ณversiones de 12.1.23 y posteriores, para ณฑฑ
ฑฑณ             ณ        ณ          ณversiones anteriores la combinaci๓n per- ณฑฑ
ฑฑณ             ณ        ณ          ณmanece como Ctrl+W (MEX).                ณฑฑ
ฑฑณOscar Garcia ณ09/07/19ณDMINA-6961ณSe valida el timbrado del cobro diverso  ณฑฑ
ฑฑณ             ณ        ณ          ณantes de la genraci๓n de polizas. MEX    ณฑฑ
ฑฑณOscar Garcia ณ11/07/19ณDMINA-7022ณSe toma formato para campo E1_TXMOEDA en ณฑฑ
ฑฑณ             ณ        ณ          ณpantalla de tํtulos pendientes. MEX      ณฑฑ
ฑฑณAlf. Medrano ณ16/07/19ณDMINA-7074ณEn fun Fa087aSalvar()cuando lSolTimCFD=F ณฑฑ
ฑฑณ             ณ        ณ          ณse actualiza campo EL_GENCFD sin importarณฑฑ
ฑฑณ             ณ        ณ          ณla config. del parแmetro MV_CFDREC. MEX  ณฑฑ
ฑฑณAlf. Medrano ณ16/07/19ณDMINA-7074ณEn fun  fVldGenCFD dentro de validaci๓n  ณฑฑ
ฑฑณ             ณ        ณ          ณde msg para compensaciones tambi้n se    ณฑฑ
ฑฑณ             ณ        ณ          ณvalida que no existan ํtems de recibo.   ณฑฑ
ฑฑณVeronica Flo ณ15/10/19ณDMINA-7512ณEn fun A087aSugerir en el  PE-F087BTNSG  ณฑฑ
ฑฑณ             ณ        ณ          ณse cambian variable y condicion del arrayณฑฑ
ฑฑณLuis Enrํquezณ23/10/19ณDMINA-7506ณSe eliminan comillas con RemoveAsp() al  ณฑฑ
ฑฑณ             ณ        ณ          ณasignar A1_NOMCLI a E5_BENEF.            ณฑฑ
ฑฑณVeronica Flo ณ26/10/19ณDMINA-7526ณSe agrega funcion F087getFin (MEX)       ณฑฑ
ฑฑณ  Marco A.   ณ03/01/20ณDMINA-7751ณAjuste a la funcion FAPagtoAtu() para el ณฑฑ
ฑฑณ             ณ        ณ          ณcuadre de saldos el selecionar titulos   ณฑฑ
ฑฑณ             ณ        ณ          ณen monedas diferentes al recibo. (MEX)   ณฑฑ
ฑฑณ  Marco A.   ณ06/01/20ณDSERFINR- ณSe agrega la propiedad OBFUSCATED, para  ณฑฑ
ฑฑณ             ณ        ณ23258     ณlos campos A1_TEL, A1_NOME y A1_CGC; paraณฑฑ
ฑฑณ             ณ        ณ          ณel encabezado del recibo.                ณฑฑ
ฑฑณVeronica Flo ณ29/01/19ณDMINA-7961ณSe modifica en la fun A87VldRet para que ณฑฑ
ฑฑณ             ณ        ณ          ณsume el valor de los titulos segun su    ณฑฑ
ฑฑณ             ณ        ณ          ณtipo NCC /NF (PER)                       ณฑฑ
ฑฑณMarco A. Glezณ25/03/20ณDMINA-8497ณSe modifica la funcion fObtInfCon() para ณฑฑ
ฑฑณ             ณ        ณ          ณla busqueda correcta de la Condicion de  ณฑฑ
ฑฑณ             ณ        ณ          ณPago cuando se cuenta con Gestion de Emp.ณฑฑ
ฑฑณLuis Enrํquezณ27/03/20ณDMINA-8115ณEn funci๓n M087Comp se realiza ajuste pa-ณฑฑ
ฑฑณ             ณ        ณ          ณvalidar factoraje solo si E5_ORIGEM es   ณฑฑ
ฑฑณ             ณ        ณ          ณ'FINA450'. (MEX)                         ณฑฑ
ฑฑณJos้ Glz     ณ01/04/20ณDMINA-8613ณSe realiza ajuste para que func. GetUUID ณฑฑ
ฑฑณ             ณ        ณ(MEX)     ณuse E1_FILORIG en lugar de E1_FILIAL.    ณฑฑ
ฑฑณARodriguez   ณ14/05/20ณDMINA-8496ณAjustes por operaciones de factoraje fin.ณฑฑ
ฑฑณ             ณ        ณ          ณMontaTela(),RefData(),A087aPagtos(),     ณฑฑ
ฑฑณ             ณ        ณ          ณFa087aSalvar(),Fa087Comp(),+FA087SE5()   ณฑฑ
ฑฑณ             ณ        ณ          ณCorreccion error colateral generado en   ณฑฑ
ฑฑณ             ณ        ณ          ณDMINA-8613 MontaTela().  MEX             ณฑฑ
ฑฑณARodriguez   ณ03/06/20ณDMINA-9195ณPrevenir error al leer campo SERIE2 de   ณฑฑ
ฑฑณ             ณ        ณ          ณtํtulo sin SF1/SF2 en Fa087aRet().	PER   ณฑฑ
ฑฑณARodriguez   ณ04/06/20ณDMINA-9353ณFa087aLinOk() Usar variable de posici๓n  ณฑฑ
ฑฑณ             ณ        ณ          ณbanco en aCols para ejecutar lRetCkPG.PERณฑฑ
ฑฑณLuis Enrํquezณ08/06/20ณDMINA-9142ณEn funci๓n Fa087aSalvar se agrega llenadoณฑฑ
ฑฑณ             ณ        ณ          ณde campo EL_HORA, y llamado a la funci๓n ณฑฑ
ฑฑณ             ณ        ณ          ณF815VldTim() para validar timbrado de re-ณฑฑ
ฑฑณ             ณ        ณ          ณcibos previos sin timbrar (MEX)          ณฑฑ
ฑฑณMarco A. Glezณ23/06/20ณDMINA-9365ณEn funci๓n FAPagtoAtu, se agrega el uso  ณฑฑ
ฑฑณ             ณ        ณ          ณdel parametro MV_PGOAUTR, para activar elณฑฑ
ฑฑณ             ณ        ณ          ณcalculo automatico en ventana "Valores deณฑฑ
ฑฑณ             ณ        ณ          ณbaja". (MI)                              ณฑฑ
ฑฑณEduardo Prez ณ04/08/20ณDMINA-8308ณEn funci๓n MontaTela, se realiza ajuste  ณฑฑ
ฑฑณ             ณ        ณ          ณen el panel de Valores de baja(oPPagto)  ณฑฑ
ฑฑณ             ณ        ณ          ณpara que se visualice completamente al   ณฑฑ
ฑฑณ             ณ        ณ          ณusar SmarthClient Versi๓n WEB.(MI)       ณฑฑ
ฑฑณOscar Garcia ณ01/12/20ณDMINA-    ณSe bifurcan los mensajes de validacion deณฑฑ
ฑฑณ             ณ        ณ     10320ณtimbrado por compensacion. MEX           ณฑฑ
ฑฑณVer๓nica Flo ณ14/02/21ณDMINA-    ณEn la funci๓n FA087Integ se modifica el  ณฑฑ
ฑฑณ             ณ        ณ     10747ณllamado a funci๓n para adaptador EAI(MEX)ณฑฑ
ฑฑณMarco A. Glezณ21/09/21ณDMINA-    ณSe agrega el uso de M้tricas Adicionales ณฑฑ
ฑฑณ             ณ        ณ     13527ณpara MI.                                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fina087a(cNumFatAut,cDadosAdt,aRecAdt)
	Local lPanelFin		:= IsPanelFin()
	Local nOrdSE1		:= SE1->(IndexOrd())
	Local nRecSA1		:= SA1->(Recno())
	Local nOrdSA1		:= SA1->(IndexOrd())
	Local nRecSF1		:= SF1->(Recno())
	Local nOrdSF1		:= SF1->(IndexOrd())
	Local bRestSE1		:= { || SE1->(DbSetOrder(nOrdSE1)), SE1->(DbGoTo(nOrdSE1)), SA1->(DbSetOrder(nOrdSA1)), SA1->(DbGoTo(nOrdSA1))}
	Local bRestSF1		:= { || SF1->(DbSetOrder(nOrdSF1)), SF1->(DbGoTo(nRecSF1)), SA1->(DbSetOrder(nOrdSA1)), SA1->(DbGoTo(nRecSA1))}
	Local cCodCliTit	:= ""
	Local cLojCliTit	:= ""
	Local cCgcCPFTit	:= ""
	Local cNomCliTit	:= ""
	Local cTelCliTit	:= ""
	Local lIncAdt		:= .F.		//Angola
	Local nJ			:= 0
	Local nNumTb		:= 9 // Numero de tablas asignadas al arreglo aCtbTmp en funci๓n FA87aCtbA
	Local cFunName		:= FunName()
	Local nVersion      := 0
	Local nVersionRel   := 0
	Local cVersion := GetRpoRelease()

	Private aTotReceb	:= {}
	Private lDigita		:= .F.
	Private nAtraso		:= 0
	Private lGeraLanc	:= .F.
	Private lVenc		:= .F.
	Private cArqTrab	:= ""
	Private nFiltro		:= 0
	Private cPerg		:= ""
	Private lCancel		:= .F.
	Private lCarga		:= .F.
	Private lConsSaldo	:= .T.
	Private nRecnoSEY	:= 0
	Private nRecnoSAQ	:= 0
	Private nSaveSX8	:= GetSX8Len()
	Private aLinSE1_Ori	:= {}
	Private aLinSA1_Ori	:= {}
	Private cCliLoj_Ori	:= ""
	Private lTrocaDtRef	:= .F.
	Private lCobrador	:= GetNewPar("MV_UTILCOB",.F.)
	Private lGeraDCam	:= (GetNewPar("MV_DIFCAMR","N") == "S")
	Private lTemMon		:= .F.
	Private lPercRA		:= (GetNewPar("MV_PERRA","N") == "S")
	Private nItensC		:= GETNEWPAR("MV_ITENSC",1)
	Private lTitAd		:= .F.
	Private oPanel		:= Nil
	Private oObjBkp		:= Nil
	Private l087GrSE5	:= ExistBLock('F087GrSE5')
	Private cNomObjT	:= "oTmpTable"
	Private nTamVlMoed	:= TamSX3("EL_VLMOED1")[2]
	Private lSolTimCFD	:= .T.

	DEFAULT cNumFatAut	:= ""
	DEFAULT cDadosAdt	:= ""
	DEFAULT aRecAdt		:= {}

	If  cVersion >= "12.1.2210" .and. cpaisloc <> "BRA"
    	FWCallApp( "FINA998") 
	ElseIf cVersion <= "12.1.033" .and. cpaisloc <> "BRA"
		If FindFunction("ExpRot087a")
    	    ExpRot087a("FINA087A",; 
    	                "Cobros diversos (fina087a)",;
    	                "https://tdn.totvs.com/pages/releaseview.action?pageId=625965279" )
    	EndIf 
	EndIf

	if cPaisLoc == "ARG"
		Alert(STR0254)
		Return()
	endif

	//Declara las variables conforme el n๚mero de tablas asignadas al arreglo aCtbTmp en funci๓n FA840aCtbA
	For nJ := 1  to nNumTb
		Private &(cNomObjT + alltrim(str(nJ))) := NIL
	Next
	/*
	 * Verifica็ใo do processo que estแ configurado para ser utilizado no M๓dulo Financeiro (Argentina)
	 */
	If !FinModProc()
		Return()
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCaso seja passado um numero de titulo verifica sua existencia.     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ! Empty(cNumFatAut)
	   SE1->(DbSetOrder(1))
	   If ! SE1->(DbSeek(xFilial("SE1")+cNumFatAut))
	      Help(" ",1,"EXISTNUM")
	      Eval(bRestSE1)
	      Return
	   Else
	      SA1->(DbSetOrder(1))
	      If ! SA1->(DbSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA)))
	         Help(" ",1,"EXISTCLI")
	         Eval(bRestSE1)
	         Return
	      Else
	         cCodCliTit := SE1->E1_CLIENTE
	         cLojCliTit := SE1->E1_LOJA
	         cCgcCPFTit := SA1->A1_CGC
	         cNomCliTit := SA1->A1_NOME
	         cTelCliTit := SA1->A1_TEL
	      Endif
	   Endif
	   Eval(bRestSE1)
	ElseIf Type("cFunName") == "C" .and. cFunName $ "MATA465N" .and. cPaisLoc $ "MEX"
		SA1->(DbSetOrder(1))
		If !SA1->(DbSeek(xFilial("SA1")+SF1->(F1_FORNECE+F1_LOJA)))
			Help(" ",1,"EXISTCLI")
			Eval(bRestSF1)
	 		Return
		Else
			cCodCliTit := SF1->F1_FORNECE
			cLojCliTit := SF1->F1_LOJA
			cCgcCPFTit := SA1->A1_CGC
			cNomCliTit := SA1->A1_NOME
			cTelCliTit := Iif(SA1->(FieldPos("A1_TEL"))>0,SA1->A1_TEL	,Space(TamSX3("A1_TEL")[1]))
		Endif
	Endif

	//ANGOLA
	If !Empty(cDadosAdt)
		lIncAdt	:= .T.

		SA1->(DbSetOrder(1))
		If ! SA1->(DbSeek(xFilial("SA1")+cDadosAdt))
			Help(" ",1,"EXISTCLI")
	      Eval(bRestSE1)
			Return
		Else
			cCodCliTit := SA1->A1_COD
			cLojCliTit := SA1->A1_LOJA
			cCgcCPFTit := SA1->A1_CGC
			cNomCliTit := SA1->A1_NOME
			cTelCliTit := SA1->A1_TEL
			aRecAdt	  := {}
		Endif
	Endif

	cPerg := "FIN87A"

	If cPaisLoc $ "ARG|URU"
	    lTemMon	:=Iif(!Empty(SuperGetMV("MV_MDCFIN")),.T.,.F.)
	EndIf

	If cPaisLoc<>"BRA"
		lCobrador:= .T.
	EndIf
	// Verifica se pode ser incluido mov. com essa data
	If  !(dtMovFin(dDataBase,,"2") )
		Return  .F.
	EndIf

	//Carrega Pergunte
	If Empty(cNumFatAut) .and. !lIncAdt
		If lPanelFin
			If !PergInPanel(cPerg,.T.)
				Return .T.
			Endif
		ElseIf Type("cFunName") == "C" .and. cFunName $ "MATA465N" .and. cPaisLoc $ "MEX"
			pergunte(cPerg,.F.)
		ElseIf !pergunte(cPerg,.T.)
			Return .F.
		Endif
	Else
		Pergunte(cPerg,.F.)
	Endif

	SX3->(DbSetOrder(2))

	If  !SX3->(DBSeek("EL_PREFIXO")) .Or. !X3USO(SX3->X3_USADO) .Or. ;
		!SX3->(DBSeek("EL_NUMERO"))  .Or. !X3USO(SX3->X3_USADO) .Or. ;
		!SX3->(DBSeek("EL_PARCELA")) .Or. !X3USO(SX3->X3_USADO) .Or. ;
		!SX3->(DBSeek("EL_BANCO"))   .Or. !X3USO(SX3->X3_USADO) .Or. ;
		!SX3->(DBSeek("EL_AGENCIA")) .Or. !X3USO(SX3->X3_USADO) .Or. ;
		!SX3->(DBSeek("EL_CONTA"))   .Or. !X3USO(SX3->X3_USADO) .Or. ;
		!SX3->(DBSeek("EL_TIPODOC")) .Or. !X3USO(SX3->X3_USADO)

		Alert(STR0097 + CHR(10) + CHR(10) + ;
				"EL_PREFIXO" + CHR(10) + ;
				"EL_NUMERO"  + CHR(10) + ;
				"EL_PARCELA" + CHR(10) + ;
				"EL_BANCO"   + CHR(10) + ;
				"EL_AGENCIA" + CHR(10) + ;
				"EL_CONTA"   + CHR(10) + ;
				"EL_TIPODOC")

		lCancel:=.T.
		SX3->(DbSetOrder(1))
		Return  .F.
	EndIf

	SX3->(DbSetOrder(1))

	cDocCred:=IIf(Empty(mv_par05).Or. !(mv_par05$MV_CRNEG+"|"+MVRECANT),"NCC",mv_par05)

	//ANGOLA
	//Forco o tipo de titulo de adiantamento para o parametro
	If cPaisLoc == "ANG" .and. lIncAdt
		cDocCred := SuperGetMV("MV_TPADTCD",.T.,Substr(MVRECANT,1,3))
	ElseIf cPaisLoc $ "MEX|PER"
		cDocCred := Substr(MVRECANT,1,3) // Sempre sera tipo RA no mexico
	Endif

	lDigita  	:= If( mv_par01==1,.T.,.F.)  // Mostra Lanctos.
	lAglutina	:= If( mv_par02==1,.T.,.F.)  // Aglutina Lanctos.
	lGeraLanc	:= If( mv_par03==1,.T.,.F.)  // Lanctos. On-Line
	lTrocaDtRef := If( mv_par06==1,.T.,.F.)  // Altera Data
	nFiltro		:= mv_par04

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica no Sigamat.acs se o usuario tem acesso เ baixa de titulos.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	IF Versenha(30)
		While !lCancel
			lCancel := .T.
			MontaTela(cNumFatAut,cCodCliTit,cLojCliTit,cCgcCPFTit,cNomCliTit,cTelCliTit,lIncAdt,aRecAdt)
			If !lCancel .and. cFunName == "MATA465N"
				lCancel := .T.
			EndIf
			If ! Empty(cNumFatAut) .or. lIncAdt
			   lCancel := .T.
			Endif
			If lCarga
				If !SuperGetMv('MV_SERREC') .And. __lSX8
					While ( GetSX8Len() > nSaveSX8 )
						RollBackSX8()
					Enddo
				EndIf
				Return !lCancel
			EndIf
		Enddo
		If !SuperGetMv('MV_SERREC') .And. __lSX8
			While ( GetSX8Len() > nSaveSX8 )
				RollBackSX8()
			Enddo
		EndIf
	Else
		Alert(STR0001) //"Usuario sem permissใo para acesso เ essa rotina, verifique os acessos do usuario no Configurador."
	Endif
	// Desabilitar Teclas de Atalho

	Set KEY 17 To
	Set KEY 12 To
	Set KEY 13 To

	nVersion := Val(GetRPORelease())
	nVersionRel := Val(Right(GetRPORelease(),3))

	If(nVersion <= 12.1)
		If(nVersionRel < 23)
			Set KEY 23 To
		Else
			Set KEY 1 To
		EndIf
	Else
		Set KEY 1 To
	EndIf

Return .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMontaTela บAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta tela de operacao do Recibo.            			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC Function MontaTela(cNumFatAut,cCodCliTit,cLojCliTit,cCgcCPFTit,cNomCliTit,cTelCliTit,lIncAdt,aRecAdt)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Faz a montagem da tela e seus objetos.                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local nIndice		:= ""
Local cSeek			:= ""
Local cWhi			:= ""
Local cSelec		:= ""
Local cCondMca		:= ""
Local c_Alias		:= ""
Local nBase			:= 005
Local aGrid			:= {}
Local aCpos			:= {}
Local aTam			:= {}
Local nTop			:= 0
Local aCposExtra	:= {}
Local aCposNo		:= {}
Local cTitRec
Local cTitEmis
Local cTitCli
Local cTitLoja
Local cTitCGC
Local cTitNom
Local cTitTel
Local cTitCob
Local cTitProv
Local cTitFactor
Local lSalvou		:=	.F.
Local cWhenRec
Local aButtons		:= {}
Local nX
Local nI
Local nZ
Local aInfGet		:= Array(9)
Local cF3Cli		:= "SA1"
Local lPanelFin		:= IsPanelFin()
LOCAL lWhenCli		:= .T.
LOCAL bWhenCli		:= { || lWhenCli .And. nPanel==1  }
Local cMasc3		:=	fnPesqPict("SE1","E1_VALOR",18)
Local oSerie		:= Nil
Local oRecibo		:= Nil
Local oSerieS		:= Nil
Local oReciboS		:= Nil
local lRCOPGER		:= !cPaisLoc $ "BRA|VEM|URU|SAL|TRI"
Local lWhenCob		:= .T.
Local lF087Vlco		:= ExistBLock('F087VLCO')
Local oFactor		:= Nil
Local cNumer		:= ""
Local nVersion		:= 0
Local nVersionRel	:= 0
Local cPesqPict		:= ""
Local nPosBorde		:= 0

//////////////////////////////////////////
//       Descricao do array aInfGet     //
//////////////////////////////////////////
// 1 => Linha do Get                    //
// 2 => Coluna do Get                   //
// 3 => Largura do Get                  //
// 4 => Altura do Get                   //
// 5 => Obejto Pai (Macro Executavel)   //
// 6 => Valid do Get (Macro Executavel) //
// 7 => When do Get (Macro Executavel)  //
// 8 => Picture do Get                  //
// 9 => Inicializador Padrao            //
//////////////////////////////////////////


Private cFunName   := "FINA087A"    // Usado pelo Profile
Private cProfChave := "FINA087A01"  // Usado pelo Profile
Private aCposProf  := {}			// Lista de campos gravados no Profile
Private cTitSer
Private lPreRec:= .F.
Private nQtMoedas:=Moedfin()
Private aMask	:= Array(nQtMoedas)
Private aTitulo:={STR0002,STR0003,STR0004,STR0005,STR0171,STR0172}		//"Recibo [Resumo de Reten็๕es]"##"Resumo [Simula็ใo da Contabiliza็ใo]"
Private cTipos := ""
Private aRLocks	:=	{}
Private nPosCli	:= 0
Private nPosLoja	:= 0
Private nPosDesc	:= 0
Private nPosJuros	:= 0
Private nPosJurosC	:= 0
Private nPosMultaC	:= 0
Private nPosDescC	:= 0
Private nPosVA		:= 0
Private nPosSaldo	:= 0
Private nPosMulta	:= 0
Private nPosMotBx	:= 0
Private nPosImpRet  := 0
Private nPosTipo
Private anPosMoed := Array(nQtMoedas)
Private oValOrig
Private nValOrig :=0
Private oSaldo
Private nSaldo := 0
Private oMoedOri
Private cMoedOri:=""
Private oRetCfg
Private nRetCfg :=0
Private oParciais
Private nParciais :=0
Private oValAbat
Private nTotAbat  :=0
Private oDescont
Private nDescont	:=0
Private oMulta
Private nMulta		:=0
Private oJuros
Private oJurosC
Private nJuros		:=0
Private oValRec

Private oVA
Private nVA		:=0

Private nValRec	:=0
Private nValOri	:=0
Private oVlEstrang
Private nValEstr	:=0
Private oCorrec
Private nCorrec	:=0
Private aNomeMoed 	:={}
Private cOrdSEL
Private bSEL
Private aCabSEL
Private cOrdSA1
Private bSA1
Private aCabSA1
Private cOrdSE1
Private bSE1
Private aCabSE1
Private cMoed
Private aLinMoed  :=	Array(nQtMoedas)
Private nBaxTit
Private aLinBaixa
Private oLBBaixa
Private nPosBx
Private aTaxa	:= Array(nQtMoedas)
Private aoCB 	:= Array(3)
Private oOk		:= LoadBitMap(GetResources(), "LBOK")
Private oNo		:= LoadBitMap(GetResources(), "LBNO")
Private oNever	:= LoadBitMap(GetResources(), "DISABLE")
Private oDlgRecibo
Private oMasterPanel
Private oPanelTop
Private oLBMoed
Private nQtPassos:=	4
Private aHeader  :=	{}
Private aCols	 :=	{}
Private aLinRet	 :=	{}
Private oGetSEL
Private aHeadSE1
Private aHeadSA1
Private aCposSEL :=	{}
Private aCposSA1 :=	{}
Private aCposSE1 :=	{}
Private nPanel	 := 1
Private oPesq
Private cSerie  	:=	Criavar("EL_SERIE")
Private cRecibo  	:=	Criavar("EL_RECIBO")
Private cSerieS  	:=	IIf(cPaisLoc == "MEX" .And. SEL->(ColumnPos("EL_SERSUS")) > 0, Criavar("EL_SERSUS"), "")
Private cReciboS  	:=	IIf(cPaisLoc == "MEX" .And. SEL->(ColumnPos("EL_RECSUS")) > 0, Criavar("EL_RECSUS"), "")

Private cNatureza :=  Criavar("EL_NATUREZ")
Private lNatureza := .F.
Private dDataRef 	:=	dDatabase
Private cCliente 	:=	Space(TamSX3("EL_CLIENTE")[1])
Private cLoja		:=	Space(TamSX3("EL_LOJA")[1])
Private cCliOri 	:=	Space(TamSX3("EL_CLIENTE")[1])
Private cLojOri	:=	Space(TamSX3("EL_LOJA")[1])
Private cNome     :=	Space(TamSX3("A1_NOME")[1])
Private cCGC		:=	Space(TamSX3("A1_CGC")[1])
Private cContato	:=	Space(TamSX3("A1_CONTATO")[1])
Private cTel		:=	Space(TamSX3("A1_TEL")[1])

//Compensaci๓n
Private lComCart	:= (cPaisLoc == "MEX" .And. SEL->(ColumnPos("EL_IDENTEE")) > 0 .And. SEL->(ColumnPos("EL_FCHIDEN")) > 0)
Private cNoComp		:= IIf(lComCart, Space(GetSx3Cache("EL_IDENTEE","X3_TAMANHO")), "")
Private dFchComp	:= CTOD("  /  /  ")

// Cobrador
Private cCobrador	:=	Space(TamSX3("EL_COBRAD")[1])
Private cRecProv	:=	Space(TamSX3("EL_RECPROV")[1])
Private cPesq
Private aLinReceb	:={}
Private oLBReceb
Private aLinBX 	:={}
Private oLBBx
Private oMenu
Private cCredMed	:=	Iif(lRCOPGER, GetSESTipos({|| ES_RCOPGER == "1"},"1"), "")
Private cCredInm	:=	Iif(lRCOPGER, GetSESTipos({|| ES_RCOPGER == "2"},"1"), "")
Private cTiposAdm   :=  GetSAETipos()
Private oBtn		:=	Array(10)
Private lDecr:= .F.
Private aFiltros:={"","","",""}
Private oPDesc
Private nPercDesc:=0
Private nDescTot:=0
Private nPercGer:=0
Private nDescGer:=0
Private lConsFilial := If(mv_par09==1,.T.,.F.)
Private nMoedDesc:=1
Private cDiario	:=	""
Private oAPerc
Private nValPerc:=0
Private aPerc:={}
Private nAliqPerc:= 0
Private oCliente
Private oNumTit
Private nTitulo
Private cNomeCli := ""
Private cNum     := ""

cCredMed	:=	IIf(Empty(cCredMed),GetSESNew("CH|CC","3") ,cCredMed)
cCredInm	:=	IIf(Empty(cCredInm),"TF /EF /CC /CD ",cCredInm)
cTiposAdm   :=  IIf(Empty(cTiposAdm),"TJ|CC",cTiposAdm)

Private cMotBx := Space(TamSx3("E5_MOTBX")[1])
Private cMotBxSE1 := cMotBx
Private aDescMotbx:={}
Private aMotbx:={}
Private aDadosAdm:={}

Private nLastPan	:= 4  //ANGOLA - Numero do ultimo painel
Private cCalcITF   := SuperGetMv("MV_CALCITF",.F.,"2")

Private oRetTit
Private aColsSEL	:= {}
Private aHeaderSEL	:= {}
Private oRetRes
Private oDtCtb
Private oLtCtb
Private dDtCtb		:= ""
Private cLtCtb		:= ""
Private oSimCtb
Private oCtbDeb
Private oCtbCre
Private nCtbDeb		:= 0
Private nCtbCre		:= 0
Private oSize
Private cFactor		:= "2"
Private lFactor		:= (cPaisLoc == "MEX" .And. SuperGetMv("MV_CFDI33",.F.,.F.) .And. SEL->(FieldPos("EL_FACTOR")) > 0)
Private aFactorOps	:= {}
Private nCompensa	:= 0
Private aSE5Comp	:= {}
Private oCGC		:= Nil
Private oTel		:= Nil
Private oNome		:= Nil

DEFAULT cNumFatAut := ""
DEFAULT cCodCliTit := ""
DEFAULT cLojCliTit := ""
DEFAULT cCgcCPFTit := ""
DEFAULT cNomCliTit := ""
DEFAULT cTelCliTit := ""

//ANGOLA - Inclusao de adiantamento
DEFAULT lIncAdt	:= .F.
DEFAULT aRecAdt	:= {}

If ! Empty(cNumFatAut)
   lWhenCli := .F.
Endif

//ANGOLA - Inclusao de adiantamento
If lIncAdt
	nLastPan := 2
   lWhenCli := .F.
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณApos declaracao das variaveis, inicia montagem da tela.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

Posicione("SX3",2,"EL_SERIE"	,"X3_TITULO")
cTitSer := AllTrim(X3TITULO())
Posicione("SX3",2,"EL_RECIBO"	,"X3_TITULO")
cWhenRec:=If(Empty(SX3->X3_WHEN),".T.",SX3->X3_WHEN)

If cPaisLoc $ "BRA#PTG#ANG"
	cTitRec := STR0006 //Recibo
Else
	cTitRec := AllTrim(X3TITULO())
Endif

Posicione("SX3",2,"EL_EMISSAO"	,"X3_TITULO")
cTitEmis:= AllTrim(X3TITULO())
Posicione("SX3",2,"EL_CLIENTE"	,"X3_TITULO")
cTitCli := AllTrim(X3TITULO())
Posicione("SX3",2,"EL_LOJA"		,"X3_TITULO")
cTitLoja:= AllTrim(X3TITULO())
Posicione("SX3",2,"A1_CGC"		,"X3_TITULO")
cTitCGC := AllTrim(X3TITULO())
Posicione("SX3",2,"A1_NOME"		,"X3_TITULO")
cTitNom := AllTrim(X3TITULO())
Posicione("SX3",2,"A1_TEL"		,"X3_TITULO")
cTitTel := AllTrim(X3TITULO())
Posicione("SX3",2,"EL_COBRAD"	,"X3_TITULO")
cTitCob:= AllTrim(X3TITULO())
Posicione("SX3",2,"EL_RECPROV","X3_TITULO")
cTitProv:= AllTrim(X3TITULO())

If lFactor
	// Nuevo campo en encabezado: Factoraje?
	Posicione("SX3",2,"EL_FACTOR"	,"X3_TITULO")
	If X3Uso( SX3->X3_USADO )
		cTitFactor := AllTrim(X3TITULO())
		aFactorOps := StrTokArr( Trim(X3Cbox()), ";")
	Else
		lFactor := .F.
	EndIf
EndIf

aSize := MSADVSIZE()

	oSize := FwDefSize():New(.T.)

	oSize:lLateral := .F.

	oSize:AddObject("MASTER",100,100,.T.,.T.)

	oSize:lProp := .T.

	oSize:Process()

	DEFINE MSDIALOG oDlgRecibo TITLE STR0006 From oSize:aWindSize[1],oSize:aWindSize[2] To oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL //"Recibo"
odlgRecibo:lMaximized := .T.

If ExistBlock("F087AF3")
 	cF3Cli:=ExecBlock("F087AF3",.F.,.F.)
EndIf

	oMasterPanel := TPanel():New(oSize:GetDimension("MASTER","LININI"),;
									oSize:GetDimension("MASTER","COLINI"),;
									,oDlgRecibo,,,,,,oSize:GetDimension("MASTER","XSIZE"),;
														oSize:GetDimension("MASTER","YSIZE"),.F.,.F.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณCria campos do cabecalho.   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	oPanelTop := TPanel():New(000,000,,oMasterPanel,,,,,,370,70,.F.,.F.)
oPanelTop:Align := CONTROL_ALIGN_TOP
nPosBorde := IIf(!lComCart, 057, 68)
@ 001, 001 TO nPosBorde,390  OF oPanelTop  PIXEL //"Dados Gerais"
nTop+=003
If SuperGetMV('MV_SERREC')
	@ nTop+3,005 SAY STR0140 				Size 040,015 Pixel 	Of oPanelTop  //"Serie/Recibo"
	@ nTop+1,050 MSGET oSerie Var cSerie	Size 020,008 Pixel 	Of oPanelTop PICTURE fnPesqPict("SEL","EL_SERIE",TamSX3("EL_SERIE")[1]) F3 "RN"  Valid Fa087Ser(@cSerie, @cRecibo) HASBUTTON When nPanel==1
	@ nTop+3,085 SAY OemtoAnsi("-") 							Of oPanelTop PIXEL
	@ nTop+1,090 MSGET oRecibo Var cRecibo	Size 075,008 Pixel 	Of oPanelTop When (nPanel==1 .And. &(cWhenRec)) Valid {||FA087aVld('cRecibo',cNumFatAut)}
Else
	@ nTop+3,005 SAY cTitRec 				Size 040,015 Pixel 	Of oPanelTop  //"Recibo"
	@ nTop+1,045 MSGET oRecibo Var cRecibo	Size 075,008 Pixel 	Of oPanelTop When  (nPanel==1 .And. &(cWhenRec)) Valid {||FA087aVld('cRecibo',cNumFatAut)}
Endif

@ nTop+3,180 SAY cTitEmis 					SIZE 040,015 PIXEL OF oPanelTop   //"Emissao"
@ nTop+1,215 MSGET oDataRef Var dDataRef	Size 054,008 Pixel Of oPanelTop VALID IIf(dtMovFin(dDataRef,,"2") ,.T.,.F.)  When  lTrocaDtReF // VALID {|| FAMoedas(dDataRef),RefData(3),".T."}When nPanel==1

@ nTop+3,280 SAY STR0165 					SIZE 040,015 PIXEL OF oPanelTop   // "Natureza"
@ nTop+1,310 MSGET cNatureza F3 "SED"		SIZE 075,008 When nPanel==1 Valid FA087AVlNa() PIXEL of oPanelTop HASBUTTON

If ! Empty(cNumFatAut) .or. lIncAdt  //ANGOLA
	cCliente	:= cCodCliTit
	cLoja		:= cLojCliTit
	cCGC		:= cCgcCPFTit
	cNome		:= cNomCliTit
	cTel		:= cTelCliTit
ElseIf !Empty(cCodCliTit) .and. !Empty(cLojCliTit) .and. !Empty(cNomCliTit) .and. cPaisLoc $ "MEX"
	cCliente	:= cCodCliTit
	cLoja		:= cLojCliTit
	cCGC		:= cCgcCPFTit
	cNome		:= cNomCliTit
	cTel		:= cTelCliTit
Endif

nTop+=013
@ nTop+3,005 SAY cTitCli 					Size 040,015 Pixel Of oPanelTop		//"Cliente"
@ nTop+1,035 MSGET oCliente Var cCliente 	Size 050,008 Pixel Of oPanelTop PICTURE	 fnPesqPict("SEL","EL_CLIENTE",TamSX3("EL_CLIENTE")[1]) F3 cF3Cli VALID F087aValCli(@cCliente,@cLoja) HASBUTTON When Eval(bWhenCli)
@ nTop+3,090 SAY cTitLoja 					Size 040,015 Pixel Of oPanelTop		//"Loja"
@ nTop+1,120 MSGET oLoja Var cLoja			Size 020,008 Pixel Of oPanelTop PICTURE fnPesqPict("SEL","EL_LOJA",TamSX3("EL_LOJA")[1]) VALID IIf(ExistCpo("SA1",cCliente+cLoja), (F087aValCli(@cCliente,@cLoja) .And. FA087aAtuCli(cNumFatAut)),.F.) When Eval(bWhenCli)
@ nTop+3,180 SAY cTitCGC					Size 030,015 Pixel Of oPanelTop		//"CGC"
@ nTop+1,215 MSGET oCGC Var cCGC 			Size 055,008 Pixel Of oPanelTop	 PICTURE fnPesqPict("SA1","A1_CGC",TamSX3("A1_CGC")[1]) When IIf(cPaisLoc=="CHI" .and. nPanel==1,.T.,.F.) OBFUSCATED RetGlbLGPD('A1_CGC')
If cPaisLoc <> "BRA"
	@ nTop+3,280 SAY cTitProv				Size 040,015 Pixel Of oPanelTop		//Recibo Provisorio
	@ nTop+1,310 MSGET cRecProv				Size 075,008 Pixel Of oPanelTop	 PICTURE fnPesqPict("SEL","EL_RECPROV",TamSX3("EL_RECPROV")[1]) Valid {||FA087Cob("2")} When nPanel==1
EndIf
nTop+=013
@ nTop+3,005 SAY cTitNom 					Size 040,015 Pixel Of oPanelTop		//"Nome"
@ nTop+1,035 MSGET oNome Var cNome 			Size 235,008 Pixel Of oPanelTop	 When .F. OBFUSCATED RetGlbLGPD('A1_NOME')

If UsaSeqCor()
	SX3->(DbSetorder(2))
	SX3->(DbSeek("EL_DIACTB"))
	cDiario		:=	Criavar("EL_DIACTB",.T.)
	cTitDiar	:=	AllTrim(X3TITULO())
	@ nTop+3,280 SAY cTitDiar					Size 040,015 Pixel Of oPanelTop	//Cod. Diario
	@ nTop+1,310 MSGET cDiario F3 SX3->X3_F3	Size 020,008 Pixel Of oPanelTop HASBUTTON When CtbWdia() Valid CTBvldDiario(cDiario,dDataBase)
	SX3->(DbSetorder(1))
EndIf

nTop+=013
@ nTop+3,005 SAY cTitTel 					Size 040,015 Pixel Of oPanelTop		//"Tel. "
@ nTop+1,035 MSGET oTel Var cTel			Size 040,008 Pixel Of oPanelTop	 PICTURE fnPesqPict("SA1","A1_TEL",TamSX3("A1_TEL")[1]) When .F. OBFUSCATED RetGlbLGPD('A1_TEL')

If  lCobrador

	If lF087Vlco
		lWhenCob:= ExecBlock("F087VLCO",.F.,.F.)
	EndIf

	@ nTop+3,090 SAY cTitCob				Size 040,015 Pixel Of oPanelTop		//Cobrador
	@ nTop+1,120 MSGET cCobrador			Size 050,008 Pixel Of oPanelTop	PICTURE	fnPesqPict("SEL","EL_COBRAD",TamSX3("EL_COBRAD")[1])	F3 "SAQ" Valid {||FA087Cob("1")} HASBUTTON When lWhenCob .And. nPanel==1
EndIf

If cPaisLoc == "MEX"
	If SuperGetMV('MV_SERREC')
		If SEL->(ColumnPos("EL_SERSUS")) > 0
			@ nTop+3,180 SAY STR0243 				Size 060,015 Pixel 	Of oPanelTop	//"Ser/Rec Sust."
			@ nTop+1,215 MSGET oSerieS Var cSerieS	Size 020,008 Pixel 	Of oPanelTop PICTURE fnPesqPict("SEL","EL_SERIE",TamSX3("EL_SERSUS")[1]) F3 "SERSUS" HASBUTTON When nPanel==1
		EndIf
		If SEL->(ColumnPos("EL_RECSUS")) > 0
			@ nTop+3,245 SAY OemtoAnsi("-") 							Of oPanelTop PIXEL
			@ nTop+1,250 MSGET oReciboS Var cReciboS	Size 050,008 Pixel 	Of oPanelTop When (nPanel==1 .And. &(cWhenRec)) Valid {||F87AValRec(cSerieS,cReciboS)}
		EndIf
	Else
		If SEL->(ColumnPos("EL_RECSUS")) > 0
			@ nTop+3,180 SAY STR0244 					Size 040,015 Pixel 	Of oPanelTop	//"Recibo Sust."
			@ nTop+1,215 MSGET oReciboS Var cReciboS	Size 050,008 Pixel 	Of oPanelTop F3 "RECSUS" When (nPanel==1 .And. &(cWhenRec)) Valid {||F87AValRec(cSerieS,cReciboS)}
		EndIf
	EndIf

	If lFactor
		@ nTop+3,310 SAY cTitFactor									Size 040,015 Pixel Of oPanelTop		//Factoraje?
		@ nTop+1,340 COMBOBOX oFactor Var cFactor ITEMS aFactorOps	Size 035,010 Pixel Of oPanelTop Valid {||A87VFactor()}
	EndIf

	If lComCart
		nTop+=013
		@ nTop+3,005 SAY STR0270					Size 040,015 Pixel Of oPanelTop		//"Compensa."
		@ nTop+1,035 MSGET oNoComp Var cNoComp 		Size 035,008 Pixel Of oPanelTop F3 "CECCD" When (nPanel==1)
		@ nTop+3,090 SAY STR0271					Size 040,015 Pixel Of oPanelTop		//"Fch.Comp."
		@ nTop+1,120 MSGET oFchComp Var dFchComp 	Size 054,008 Pixel Of oPanelTop PICTURE "@D" When (nPanel==1)
	EndIf

EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณCria barra onde ficarao as informacoes referentes a cada Grid.  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
If lPanelFin
		oPanBut:= TPanel():New(055,000,,oMasterPanel,,,,,,570,15,.F.,.F.)
	oPanBut:Align := CONTROL_ALIGN_TOP
Else
		oPanBut:= TPanel():New(087,000,,oMasterPanel,,,,,,370,15,.F.,.F.)
	oPanBut:Align := CONTROL_ALIGN_TOP
Endif

@ 000,001 BITMAP oBmp RESNAME "TOOLBAR" SIZE (aSize[5]/2),25  NOBORDER PIXEL OF oPanBut
cPesq := Space(50)

@ 001,251 MSGET oPesq VAR cPesq Size 070,008 Pixel Of oPanBut ON CHANGE FA087aBuscar(lIncAdt) When (nPanel < nlastPan .And. nPanel < 4)
nBase:=001

@001,001 BTNBMP oBtn[1] RESOURCE "PREV" 		SIZE 25,25 ACTION (nPanel -= 1,FA87AValPan(nPanel,nLastPan),ShowPanel(nPanel, @oPanel,cNumFatAut,lIncAdt))				OF oPanBut WHEN nPanel > 1
@001,030 BTNBMP oBtn[2] RESOURCE "NEXT" 		SIZE 25,25 ACTION (IIF(Fa087aTudoOk(cNumFatAut,lIncAdt),(nPanel +=1,ShowPanel(nPanel, @oPanel,cNumFatAut,lIncAdt)),))	OF oPanBut WHEN nPanel < nLastPan
@001,070 BTNBMP oBtn[10] RESOURCE "BMPINCLUIR"	SIZE 25,25 ACTION (A087aMarca())		   																				OF oPanBut WHEN !lIncAdt .and. nPanel == 2
@001,105 BTNBMP oBtn[4] RESOURCE "BMPINCLUIR"	SIZE 25,25 ACTION (A087aSugerir())		   																				OF oPanBut WHEN nPanel == 3 .and. !lIncAdt .And. ValType(aLinSE1[1][Len(aLinSE1[1])-1]) == "N"
@001,155 BTNBMP oBtn[5] RESOURCE "PRECO"		SIZE 25,25 ACTION (A087Desconto())		 																				OF oPanBut WHEN (nPanel >= 3 .And. nPanel < 5) .and. !lIncAdt
@001,374 BTNBMP oBtn[6] RESOURCE "FILTRO"		SIZE 25,25 ACTION (A087aFiltrar(nPanel,cNumFatAut))																		OF oPanBut WHEN (nPanel > 1) .And. (nPanel < nLastPan .And. nPanel < 4)
@001,400 BTNBMP oBtn[7] RESOURCE "VCDOWN"		SIZE 25,25 ACTION (lDecr:=.F.,Fa087aOrd(nPanel),oBtn[7]:Hide(),oBtn[8]:Show())	   										OF oPanBut WHEN (nPanel < nLastPan .And. nPanel < 4)
@001,400 BTNBMP oBtn[8] RESOURCE "VCUP"			SIZE 25,25 ACTION (lDecr:=.T.,Fa087aOrd(nPanel),oBtn[8]:Hide(),oBtn[7]:Show())	   										OF oPanBut WHEN (nPanel < nLastPan .And. nPanel < 4)
@001,645 BTNBMP oBtn[9] RESOURCE "PESQUISA"		SIZE 25,25 ACTION (aoCB[1]:SetFocus(),FA087aBuscar(lIncAdt))	   														OF oPanBut WHEN (nPanel < nLastPan .And. nPanel < 4)

nVersion := Val(GetRPORelease())
nVersionRel := Val(Right(GetRPORelease(),3))

oBtn[1]:cToolTip := STR0022 //"Voltar   (Ctrl+Q)"

If(nVersion <= 12.1)
	If(nVersionRel < 23)
		oBtn[2]:cToolTip := STR0023 //"Avancar   (Ctrl+W)"
	Else
		oBtn[2]:cToolTip := STR0249 //"Avancar   (Ctrl+A)"
	EndIf
Else
	oBtn[2]:cToolTip := STR0249 //"Avancar   (Ctrl+A)"
EndIf

oBtn[4]:cToolTip := STR0064 //"Sugerir"
oBtn[5]:cToolTip := STR0065 //"Desconto Geral"
oBtn[6]:cToolTip := STR0066 //"Filtrar"
oBtn[7]:cToolTip := STR0067 //"Ordem Descrescente"
oBtn[8]:cToolTip := STR0068 //"Ordem Crescente"
oBtn[9]:cToolTip := STR0024 //"Buscar (Ctrl+L)"
oBtn[10]:cToolTip :=STR0111 // "Inverte Selecao (Ctrl+M)"
oBtn[7]:Hide()

if GetRemoteType() <> 5 //Tratamiento HTML
	SetKEY(17,oBtn[1]:bAction)
Endif
SetKEY(12,oBtn[9]:bAction)
SetKEY(13,oBtn[10]:bAction)

If(nVersion <= 12.1)
	If(nVersionRel < 23)
		SetKEY(23,oBtn[2]:bAction)
	Else
		SetKEY(1,oBtn[2]:bAction)
	EndIf
Else
	SetKEY(1,oBtn[2]:bAction)
EndIf

oPanel := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณDevolve todos os tipos de Titulos validos.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
If !cPaisLoc $ "BRA|VEM|URU|SAL|TRI"
	cTipos += GetSESTipos({|| ES_BXRCOP == "1"},"1")
EndIf
cTipos += "/"+MVNOTAFIS+"/"+MVRECANT+"/"+"DP /FT /NV /RTI /LTR/"
If Right(Trim(MV_CRNEG),1) == "," //Se encontrar uma virgula retira
	cTipos += Left(Trim(MV_CRNEG),Len(MV_CRNEG)-1)
Else
	ctipos += Trim(MV_CRNEG)
EndIf
If cPaisloc $ "BRA/PTG"
	cTipos += "/CH /LJ /"
Else
	cTipos += "/NDC"
Endif
If cPaisloc $ "COS"
	cTipos += "/LTR/"
EndIf

If cPaisloc $ "BRA"
	cTipos += "/VL /"
EndIf

If  ExistBLock('A087TIPTI')
	cTipos	+=	ExecBlock('A087TIPTI',.F.,.F.)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณCria um panel para cada passo.   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

//ANGOLA
//Nao mostrar a tela de selecao de titulos a baixar
//na inclusใo de adiantamento
If lIncAdt
	aoCB 	:= Array(1)
	nQtPassos := nLastPan
	nI:=1
	aNomeMoed := {}
	For nI := 1 To nQtMoedas
		cTitMoed:= SuperGetMv("MV_MOEDA"+Alltrim(Str(nI)))
		AAdd(aNomeMoed,cTitMoed)
	Next nI
Endif

nx:= 1
For nx:= 1 to nQtPassos
		Aadd(oPanel,TPanel():New(000,000,,oMasterPanel,,,,,,350,110,.F.,.F.))
	nPan:=nX
Next

//ฺฤฤฤฤฤฤฤฤฤฤ
//ณPANEL 1	 ณ
//ภฤฤฤฤฤฤฤฤฤฤ
c_Alias 	:= "SEL"
nIndice 	:= 1
cSeek		:= "ZZZZZZ"
cSelec	:= ".F."
cWhi  	:= ".F."
nPainel	:= 1

AAdd(aCposNo,"EL_FILIAL")
AAdd(aCposNo,"EL_SERIE")
AAdd(aCposNo,"EL_RECIBO")
AAdd(aCposNo,"EL_DTDIGIT")
AAdd(aCposNo,"EL_CANCEL")
AAdd(aCposNo,"EL_PREREC")
AAdd(aCposNo,"EL_CLIENTE")
AAdd(aCposNo,"EL_LOJA")
AAdd(aCposNo,"EL_VLMOED1")
AAdd(aCposNo,"EL_COBRAD")
AAdd(aCposNo,"EL_RECPROV")
AAdd(aCposNo,"EL_CLIORIG")
AAdd(aCposNo,"EL_LOJORIG")
AAdd(aCposNo,"EL_TIPO")

aGrid	:= FA087aHead(c_Alias,,.F.,aCposNo)   	//MOnta cabecalho

aHeader	:=	aClone(aGrid[1])			// Campo + Tamanho + Titulo + Descricoes, etc....
aCposSEL:=	aClone(aGrid[2])			// Somente campos validos
aCabSEL	:=	aClone(aGrid[3])			// Somente Titulo dos campos que estao no aCposSEL

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณMonta linhas de acordo com os campos acima definidos.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
aCols 	:= MontaGrid(c_Alias,cWhi,cSelec,.F.,".F.",cSeek,nIndice,aCposSEL)

Private aRotina := { { "RDMAKE" ,"SIGAIXB", 0 , 3}}
	AADD(aRotina,aClone(aRotina[1]))
	AADD(aRotina,aClone(aRotina[1]))

oPanel[nPainel]:Align := CONTROL_ALIGN_ALLCLIENT

oGetSEL	:= MSGetDados():New(000,000,109,331,Iif(lCarga,4,1),"Fa087aLinOk(.F.)","Fa087aTudoOk(cNumFatAut,lIncAdt)",,.T.,,,.F.,,"a087aFldOk()",,,"SELDelLin()",oPanel[nPainel])
oGetSel:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

cOrdSEL	:= aCabSEL[1]
bSEL		:= {|u| If( PCount() == 0, cOrdSEL, cOrdSEL:= u ) }

aoCB[1]	:= TComboBox():New(001,205,bSEL,aCabSEL,040,020,oPanBut, ,{||FA087aOrd(1)} , , , ,.t.,,,,)

//ฺฤฤฤฤฤฤฤฤฤฤ
//ณPANEL 2	 ณ
//ภฤฤฤฤฤฤฤฤฤฤ
//ANGOLA - Inclusao de adiantamentos nao tera a tela de selecao de titulosclientes
If !lIncAdt
	nIndice	:= 1
	c_Alias 	:= "SA1"
	cSeek	:= "ZZZZZZZZ"
	cWhi  	:= ".F."
	cSelec	:= ".F."
	cCondMca:= ".F."
	nPainel	:= 2

	///////////////////////////////////////////////////////
	// Verifica se existe lista de campos para cliente   //
	// no Profile do usuario, para que possa resgata-la  //
	///////////////////////////////////////////////////////
	If ( FindProfDef(cUserName,cFunName,cProfChave,c_Alias) )
		aCposProf := A087aProf(c_Alias)
		aGrid	  := FA087aHead(c_Alias,Aclone(aCposProf),.T.)   	//Monta cabecalho
	Else
		aGrid	:= FA087aHead(c_Alias,,.T.)   	//Monta cabecalho
	Endif
	aHeadSA1:= aClone(aGrid[1])
	aCposSA1:= aClone(aGrid[2])
	aCabSA1	:= aClone(aGrid[3])
	aTam	:= aClone(aGrid[4])

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//ณMonta linhas de acordo com os campos acima definidos.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	aLinSA1	:= MontaGrid(c_Alias,cWhi,cSelec,.T.,cCondMca,cSeek,nIndice,aCposSA1,lIncAdt)  //ANGOLA
	oPanel[nPainel]:Align := CONTROL_ALIGN_ALLCLIENT
	oLBCli	:= TwBrowse():New(000,000,000,000,,aCabSA1,aTam,oPanel[nPainel],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLBCli:Align := CONTROL_ALIGN_ALLCLIENT
	oLBCli:lColDrag	:= .T.
	oLBCli:nFreeze	:= 1
	oLBCli:SetArray(aLinSA1)

	If GetFinLGPD()
		oLBCli:aObfuscatedCols := FwProtectedDataUtil():SetObFuscatedFields(aCposSA1)
	EndIf

	cBLinSA1:= "{If(aLinSA1[oLBCli:nAt,1]>0,oOk,If(aLinSA1[oLBCli:nAt,1]<0,oNo,oNever))"
	oLBCli:bLDblClick :={ || aLinSA1[oLBCli:nAt,1] := aLinSA1[oLBCli:nAT,1] * -1}
	nI:=2
	For nI:= 2 to Len(aCposSA1)
		c_Picture:= Alltrim(Posicione("SX3",2,aCposSA1[nI],"X3_PICTURE"))
		cBLinSA1:= cBLinSA1 + ", Transform(aLinSA1[oLBCli:nAT][" + alltrim(Str(nI))+ "], '" + c_Picture + "')"
	Next nI
	oLBCli:bLine:= { || &(cBLinSA1 + "}") }

	cOrdSA1 := aCabSA1[2]
	bSA1	:= {|u| If( PCount() == 0, cOrdSA1, cOrdSA1:= u ) }
	aoCB[2]	:= TComboBox():New(001,205,bSA1,aCabSA1,040,020,oPanBut, ,{||FA087aOrd(2)} , , , ,.t.,,,,)

Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤ
//ณ PANEL 3	 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤ
//ANGOLA - Inclusao de adiantamentos nao tera a tela de selecao de titulos
If !lIncAdt

	c_Alias 	:= "SE1"
	nIndice 	:= 2
	cWhi  	:= ".F."
	cCondMca	:= ".F."
	cSelec	:= ".F."
	cSeek	:= "ZZZZZZZZ"
	nPainel	:= 3

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//ณExecblock para poder modificar os campos no Lisbox do SE1.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	If ExistBlock("FA087COL")
		aCpos := ExecBlock("FA087COL",.F.,.F.)
	Else
		///////////////////////////////////////////////////////
		// Verifica se existe lista de campos para titulo    //
		// no Profile do usuario, para que possa resgata-la  //
		///////////////////////////////////////////////////////
		If ( FindProfDef(cUserName,cFunName,cProfChave,c_Alias) )
			aCpos := A087aProf(c_Alias)
		Else
			aCpos	:= {	"E1_PREFIXO","E1_NUM"	,"E1_PARCELA"	,"E1_TIPO"		,"E1_EMISSAO", ;
			"E1_MOEDA"	,"E1_VALOR"	,"E1_SALDO"		,"E1_DESCONT"	,"E1_JUROS", ;
			"E1_MULTA" 	,"E1_VENCREA"}

			DbSelectArea("SX3")
			DbSetOrder(1)
			DbSeek(c_Alias,.F.)
			Do While !EOF() .And. X3_ARQUIVO == Alltrim(c_Alias)
				If x3uso(x3_usado) .And. cNivel >= X3_NIVEL .And. AScan(aCpos,Alltrim(X3_CAMPO))==0
					AAdd(aCpos,X3_CAMPO)
				Endif
				DbSkip()
			Enddo
		Endif
	Endif

	///////////////////////////////////////////////////
	// Rastreia aCpos para retirar campos do tipo MEMO
	// Necessario ser desta forma, devido ao ponto de
	//   entrada do usuario, que pode criar a aCols com
	//   campo tipo MEMO
	cAliasBM := Alias()
	DbSelectArea( "SX3" )
	DbSetOrder(2)
	For nZ := 1 to Len(aCpos)
		If nZ <= Len(aCpos) .And. DbSeek( Alltrim(aCpos[nZ]) )
			If ( X3_TIPO = "M" )
				Adel( aCpos, nZ )
				Asize( aCpos, Len(aCpos)-1 )
				nZ:= nZ-1
			Endif
		EndIf
	Next nZ
	SX3->(DbSetOrder(1))
	DbSelectArea( cAliasBM )

	aGrid	    := FA087aHead(c_Alias,Aclone(aCpos),.T.) //Monta cabecalho
	aHeadSE1	:= aClone(aGrid[1])
	aCposSE1	:= aClone(aGrid[2])
	aCabSE1		:= aClone(aGrid[3])
	aTam		:= aClone(aGrid[4])

	aAux:=CposToHead({"E1_FILIAL"})
	AEval(aAux,{|x| AAdd(aHeadSE1,x)})
	AAdd(aCposSE1,"E1_FILIAL")
	AAdd(aCabSE1 ,X3Titulo())
	AAdd(aTam    ,12)

	aAux:=CposToHead({"E1_FILORIG"})
	AEval(aAux,{|x| AAdd(aHeadSE1,x)})
	AAdd(aCposSE1,"E1_FILORIG")
	AAdd(aCabSE1 ,X3Titulo())
	AAdd(aTam    ,12)

	nI:=0
	for nI:=1 to nQtMoedas
		&("nBxMoeda" + Alltrim(Str(nI))) := 0
	Next nI
	nBaixar		:= 0
	nDescTot	:= 0
	nDescSE1	:= 0
	nJurSE1		:= 0
	nVASE1		:= 0
	nMultaSE1  	:= 0
	nImpRetSE1 	:= 0
	nJurosCalc 	:= 0
	nMultaCalc	:= 0
	nDescCalc	:= 0

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//ณApos montagem dos campos insere campos que sao|
	//ณindispensaveis para o funcionamento da rotina.|
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

	//				 Variavel			Titulo			 		 Tamanho
	AAdd(aCposExtra,{"nBaixar"		,STR0025				,25}) //"Vlr. Baixa"
	AAdd(aCposExtra,{"nDescTot"	,STR0069  			,25}) //Valor de desconto geral, rateado pelo item //"Desc. Geral"
	nI:=0
	for nI:=1 to nQtMoedas
		AAdd(aCposExtra,{"nBxMoeda" + Alltrim(Str(nI)),STR0026 + SuperGetMv("MV_MOEDA"+ Alltrim(Str(nI))),25}) //"Bx "
	Next nI
	AAdd(aCposExtra,{"nDescSE1"		,STR0027									,25,}) //"Descontos"
	AAdd(aCposExtra,{"nJurSE1"		,STR0028									,25,}) //"Juros"
	AAdd(aCposExtra,{"nMultaSE1"	,STR0029									,25,}) //"Multa"
	AAdd(aCposExtra,{"nVASE1"		,STR0200 									,25,}) //"Valores Acess๓rios"
	AAdd(aCposExtra,{"cMotBxSE1"	,Posicione("SX3",2,"E5_MOTBX","X3Titulo()")	,25}) //"Motivo da Baixa"
	AAdd(aCposExtra,{"nJurosCalc"	,STR0206		 							,25}) //"Juros Calc"
	AAdd(aCposExtra,{"nMultaCalc"	,STR0205									,25}) //"Multa Calc."
	AAdd(aCposExtra,{"nDescCalc"	,STR0204		 							,25}) //"Desc.Calc."

	if  cPaisLoc == "COS"
		AAdd(aCposExtra,{"nImpRetSE1"	,"Imp. Retido",25}) //"Reten็ใo"
	endif

	If lFactor
		// Columna en Grid de SE1 para valor de compensaci๓n entre carteras
		AAdd(aCposExtra,{"nCompensa"	,Posicione("SX3",2,"EL_COMPEN","X3Titulo()"),25}) //"Vlr Compensaci๓n"
	EndIf

	nI:=1
	For nI:=1 To Len(aCposExtra)
		AAdd(aCposSE1	,aCposExtra[nI][1])
		AAdd(aCabSE1	,aCposExtra[nI][2])
		AAdd(aTam		,aCposExtra[nI][3])
	Next nI

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//ณMonta linhas de acordo com os campos acima definidos.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	aLinSE1	:= MontaGrid(c_Alias,cWhi,cSelec,.T.,cCondMca,cSeek,nIndice,aCposSE1,.T.)
	oPanel[nPainel]:Align := CONTROL_ALIGN_ALLCLIENT
	oLBSE1	:= TwBrowse():New(000,000,000,000,,aCabSE1,aTam,oPanel[nPainel],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLBSE1:Align := CONTROL_ALIGN_ALLCLIENT
	oLBSE1:lColDrag	:= .T.
	oLBSE1:nFreeze	:= 1
	oLBSE1:SetArray(aLinSE1)

	If GetFinLGPD()
		oLBSE1:aObfuscatedCols := FwProtectedDataUtil():SetObFuscatedFields(aCposSE1)
	EndIf

	cBLinSE1 := "{If(aLinSE1[oLBSE1:nAt,1]>0,oOk,If(aLinSE1[oLBSE1:nAt,1]<0,oNo,oNever))"
	oLBSE1:bLDblClick :={ || A087aPagtos(oLBSE1:nAt,cNumFatAut)}

	nMx := AScan(aCposSE1,"E1_MOEDA")
	nI:=2
	For nI:= 2 to Len(aCposSE1)
		nX3:=AScan(aHeadSE1,{|x| Alltrim(x[2])==Alltrim(aCposSE1[nI])})
		If nX3>0 .And. aHeadSE1[nX3][8]=="N" .And. aHeadSE1[nX3][4]>=9
			cPesqPict := Iif(cPaisLoc $ "MEX" .And. Alltrim(aCposSE1[nI]) $ "E1_TXMOEDA", "",",18,IIf(nMx>0,aLinSE1[oLBSE1:nAT][" + Alltrim(Str(nMx)) + "],NIL)")
			cBLinSE1:= cBLinSE1 + ", Transform(aLinSE1[oLBSE1:nAT][" + Alltrim(Str(nI))+ "], fnPesqPict('SE1',aHeadSE1[" + alltrim(Str(nX3)) + "][2]" + cPesqPict + "))"
		ElseIf Substr(aCposSE1[nI],1,1) == 'n'
			cBLinSE1:= cBLinSE1 + ", Transform(aLinSE1[oLBSE1:nAT][" + Alltrim(Str(nI))+ "],'@R 999,999.99')"
	   Else
			cBLinSE1:= cBLinSE1 + ", aLinSE1[oLBSE1:nAT][" + alltrim(Str(nI))+ "]"
		Endif
	Next nI
	oLBSE1:bLine:= { || &(cBLinSE1 + "}") }

	cOrdSE1 := aCabSE1[2]
	bSE1	:= {|u| If( PCount() == 0, cOrdSE1, cOrdSE1:= u ) }
	aoCB[3]	:= TComboBox():New(001,205,bSE1,aCabSE1,040,020,oPanBut, ,{||FA087aOrd(3)} , , , ,.t.,,,,)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//ณMontagem do panel de pagto.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

	oPPagto:=TPanel():New(Iif(cPaisLoc != "BRA",Iif(GetRemoteType() <> 5,78,50),84),100,,oMasterPanel,,,,,,232,170,.F.,.T.)

	nT1:=03
	@ nT1,002 GROUP oGrp1 TO 127+if(cPaisLoc == "COS", 14,0), 116 LABEL OemToAnsi(STR0030) OF oPPagto  PIXEL //"Valores da Baixa" //"Valores da Baixa"
	@ nT1,115 GROUP oGrp1 TO 127+if(cPaisLoc == "COS", 14,0), 230 LABEL " " OF oPPagto  PIXEL
	aMotBx := ReadMotBx()
	For NI := 1 to Len(aMotBx)
		If substr(aMotBx[nI],34,01) == "A" .or. substr(aMotBx[nI],34,01) =="R"
			If !(substr(aMotBx[nI],01,03) $ "FAT|LOJ|LIQ|CEC|CMP|STP")
				AADD( aDescMotbx,substr(aMotBx[nI],07,10))
			EndIf
		EndIf
	Next
	bMotBx :={|u| If( PCount() == 0, cMotBx, cMotBx:= u ) }
	nT1+=09
	@ nT1,004 SAY OemToAnsi(STR0098) SIZE 53, 07 OF oPPagto PIXEL //"Motivo Baixa"
	oMotBx :=TComboBox():New(nT1,046,bMotBx,aDescMotbx,066,010,oPPagto, , ,{|| F087aMotBx()}, , ,.T.,,,,)

	@ nT1,120 SAY OemToAnsi( STR0032 )  SIZE 53,07 OF oPPagto PIXEL //"= a Receber"
	@ nT1,162 MSGET oSaldo VAR nSaldo 	SIZE 66, 10 OF oPPagto PIXEL HASBUTTON When .F.  Picture cMasc3
	nT1+=14
	@ nT1,004 SAY OemToAnsi( STR0031 ) SIZE 53, 10 OF oPPagto PIXEL //"Valor Original"
	@ nT1,046 MSGET oValOrig VAR nValorig 	SIZE 66, 10 OF oPPagto PIXEL HASBUTTON When .F.  Picture cMasc3

	@ nT1,120 SAY OemToAnsi( STR0033 ) SIZE 53, 07 OF oPPagto PIXEL //"Moeda Original"
	@ nT1,162 MSGET oMoedOri Var cMoedOri SIZE 66, 10 OF oPPagto PIXEL When .F.

	aCposBaixa	:={"cMoeda", "nBxMoed"}
	aCabBaixa	:={STR0034, STR0035} //"Moedas"###"Baixar"
	aTamBaixa	:={45,50}
	aLinBaixa	:=Array(nQtMoedas)

	nPosBx 		:= Ascan(aCposSE1,"nBaixar")
	nPosPre   	:= AScan(aCposSE1,"E1_PREFIXO")
	nPosNum		:= AScan(aCposSE1,"E1_NUM")
	nPosPar   	:= AScan(aCposSE1,"E1_PARCELA")
	nPosTp 		:= AScan(aCposSE1,"E1_TIPO")
	nPosNom		:= AScan(aCposSE1,"E1_NOMCLI")

	nValRec:= aLinSE1[oLBSE1:nAt][nPosBx]

 	cNum 	 := "aLinSE1[oLBSE1:nAt][nPosPre]+'/'+aLinSE1[oLBSE1:nAt][nPosNum]+'/'+aLinSE1[oLBSE1:nAt][nPosPar]+'/'+aLinSE1[oLBSE1:nAt][nPosTp] "
 	cNumer 	 := cNum
 	cNomeCli := "aLinSE1[oLBSE1:nAt][nPosNom] "

	nI:=1
	aNomeMoed := {}
	For nI := 1 To nQtMoedas
		cTitMoed:= SuperGetMv("MV_MOEDA"+Alltrim(Str(nI)))
		AAdd(aNomeMoed,cTitMoed)
		anPosMoed[nI]:=AScan(aCposSE1,"nBxMoeda" + Alltrim(Str(nI)))
		aLinBaixa[nI]:={SuperGetMV("MV_MOEDA"+Alltrim(Str(nI))),aLinSE1[oLBSE1:nAt][anPosMoed[nI]]}
	Next nI
	nT1+=14

	oLBBaixa:=TwBrowse():New(nT1,120,000,000,,aCabBaixa,aTamBaixa,oPPagto,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLBBaixa:lHScroll:=.F.
	oLBBaixa:lVScroll:= .T. //nQtMoedas>5
	oLBBaixa:nHeight	:=112
	oLBBaixa:nWidth	:=209
	oLBBaixa:SetArray(aLinBaixa)
	oLBBaixa:bLine 	:= { || {aLinBaixa[oLBBaixa:nAT][1],;
	Transform(aLinBaixa[oLBBaixa:nAT][2],fnPesqPict("SE1","E1_VALOR",18,oLBBaixa:nAT))}}
	oLBBaixa:bLDblClick := {|| DCLBBaixa()}

	nT1+=02
	@ nT1,004 SAY OemToAnsi( STR0102 ) SIZE 53, 10 OF oPPagto PIXEL //"- Abatimentos"
	@ nT1,046 MSGET oValAbat VAR nTotAbat SIZE 66, 10 OF oPPagto PIXEL HASBUTTON When .F. Picture cMasc3 //"@E 999,999,999,999.99"

	If cPaisLoc == "COS"
		nT1+=14
		@ nT1,004 SAY OemToAnsi( "- " + STR0173 ) SIZE 53, 07 OF oPPagto PIXEL  //"Reten็๕es"
		@ nT1,046 MSGET oRetCfg Var nRetCfg	SIZE 66, 10 OF oPPagto PIXEL HASBUTTON When .F.  Picture cMasc3
	EndIf

	nT1+=14
	@ nT1,004 SAY OemToAnsi( STR0036 ) SIZE 53, 07 OF oPPagto PIXEL  //"- Baixas Parciais"
	@ nT1,046 MSGET oParciais Var nParciais	SIZE 66, 10 OF oPPagto PIXEL HASBUTTON When .F.  Picture cMasc3
	nT1+=14
	@ nT1,004 SAY OemToAnsi( STR0037 ) SIZE 53, 07 OF oPPagto PIXEL  //"- Descontos"
	@ nT1,046 MSGET oDescont VAR nDescont	SIZE 66, 10 OF oPPagto PIXEL HASBUTTON ON CHANGE(FAPagtoAtu()) When !(aLinSE1[oLBSE1:nAt][AScan(aCposSE1,"E1_TIPO")]$MVRECANT+"/"+MV_CRNEG .Or. oMotBx:nAt>1) Picture cMasc3
	nT1+=14
	@ nT1,004 SAY OemToAnsi( STR0070 ) 	SIZE 53, 07 OF oPPagto PIXEL //"+ Multa"
	@ nT1,046 MSGET oMulta VAR nMulta  		SIZE 66, 10 OF oPPagto PIXEL HASBUTTON ON CHANGE(FAPagtoAtu()) When !(aLinSE1[oLBSE1:nAt][AScan(aCposSE1,"E1_TIPO")]$MVRECANT+"/"+MV_CRNEG .Or. oMotBx:nAt>1)Picture cMasc3
	nT1+=14
	@ nT1,004 SAY OemToAnsi( STR0038 ) 	SIZE 53, 07 OF oPPagto PIXEL //"+ Juros"
	@ nT1,046 MSGET oJuros VAR nJuros  		SIZE 66, 10 OF oPPagto PIXEL HASBUTTON ON CHANGE(FAPagtoAtu()) When !(aLinSE1[oLBSE1:nAt][AScan(aCposSE1,"E1_TIPO")]$MVRECANT+"/"+MV_CRNEG .Or. oMotBx:nAt>1)Picture cMasc3
	nT1+=14
	@ nT1,004 SAY OemToAnsi( STR0201  ) 	SIZE 53, 07 OF oPPagto PIXEL //"+ Valores Acess๓rios"
	@ nT1,046 MSGET oVA VAR nVA  		SIZE 66, 10 OF oPPagto PIXEL HASBUTTON When .F. Picture cMasc3

	@ nT1,120 SAY OemToAnsi( STR0039 )  SIZE 53,07 OF oPPagto PIXEL //"Valor a Baixar"
	@ nT1,162 MSGET oValRec VAR nValRec 	SIZE 66, 10 OF oPPagto PIXEL HASBUTTON  WHEN .F. Picture cMasc3
	nT1+=19
	@ nT1,004 SAY OemToAnsi( STR0202 )  SIZE 53,07 OF oPPagto PIXEL //"Nome Cliente"
	@ nT1,046 MSGET oCliente VAR &cNomeCli 	SIZE 115, 10 OF oPPagto PIXEL HASBUTTON  WHEN .F. OBFUSCATED RetGlbLGPD('A1_NOME') //Picture cMasc3
	nT1+=17
	@ nT1,004 SAY OemToAnsi( STR0203 )  SIZE 53,07 OF oPPagto PIXEL //"Titulo"
	@ nT1,046 MSGET oNumTit Var &cNumer	SIZE 115, 10 OF oPPagto PIXEL HASBUTTON WHEN .F. //Picture cMasc3

	oPPagto:NCLRPANE:= RGB(233,233,233) //13165800
	DEFINE SBUTTON FROM 130,170  TYPE 1  ACTION (Fa087aBaixaOK(cNumFatAut)) OF oPPagto When .T.
	DEFINE SBUTTON FROM 130,200  TYPE 2  ACTION (oPPagto:Hide(),oPanBut:lReadOnly:=.F.,oPanel[3]:lReadOnly:=.F.,a087Lock(oLBSE1:nAt,.F.)) OF oPPagto When .T.
	oPPagto:Hide()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//ณ Montagem do PANEL de Descontosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	oPDesc:=TPanel():New(84,00,,oMasterPanel,,,,,,127,117,.F.,.T.)

	@ 003,001 GROUP oGrp TO 103, 123 LABEL OemToAnsi(STR0027) OF oPDesc  PIXEL  //"Descontos"

	@ 015,005 SAY OemToAnsi( STR0045 ) SIZE 55, 07 OF oPDesc PIXEL  //"Valores expressos em "
 	oCBMoed1:= TComboBox():New(015,065,bSEL,aNomeMoed,055,020,oPDesc, ,{|| nMoedDesc:=oCBMoed1:nAt, aInfGet[8]:=fnPesqPict("SE1","E1_VALOR",18,nMoedDesc), F087Get(aInfGet,@nDescTot)} , , , ,.T.,,,,)

	@ 030,005 SAY OemToAnsi(STR0071) SIZE 60,07	OF oPDesc PIXEL //"Percentual"
	@ 030,065 MSGET oPercDesc Var nPercDesc	SIZE 55,09 	OF oPDesc PIXEL When nDescTot==0 Picture "@R 99.99" HASBUTTON

	@ 045,005 SAY OemToAnsi(STR0072) SIZE 60,07	OF oPDesc PIXEL //"Valor do Desconto"

	// Valoriza array aInfGet com os dados necessarios para a montagem do GET.
	aInfGet[1] := 045
	aInfGet[2] := 065
	aInfGet[3] := 55
	aInfGet[4] := 09
	aInfGet[5] := "oPDesc"
	aInfGet[6] := ".T."
	aInfGet[7] := "nPercDesc == 0"
   	aInfGet[8] := fnPesqPict("SE1","E1_VALOR",18,nMoedDesc)
	aInfGet[9] := nDescTot

	// Cria o get para o campo do desconto geral...
	F087Get(aInfGet,@nDescTot)

	oPDesc:NCLRPANE:= RGB(233,233,233) ///13165800
	DEFINE SBUTTON FROM 104,063  TYPE 1  ACTION (A087OKDesc(cNumFatAut)) OF oPDesc When .T.
	DEFINE SBUTTON FROM 104,093  TYPE 2  ACTION (oPDesc:Hide(),oPanBut:lReadOnly:=.F.,oPanel[nPainel]:lReadOnly:=.F.) OF oPDesc When .T.

	oPDesc:Hide()

Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ PANEL 4	- Resumo ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
nPainel	:= If(lIncAdt,2,4)
nT1		:= 003
aSize := MSADVSIZE()
nRight 	:= ((aSize[5]/2)-330)/2

@ nT1,001+nRight GROUP oGrp3 TO 085,168+nRight LABEL OemToAnsi(STR0040) OF OPANEL[nPainel]  PIXEL  //"Valores Recebidos"
@ nT1,172+nRight GROUP oGrp4 TO 085,340+nRight LABEL OemToAnsi(STR0041) OF OPANEL[nPainel]  PIXEL  //"Titulos Baixados"
@ 088,001+nRight GROUP oGrp5 TO 109,340+nRight 							OF OPANEL[nPainel]  PIXEL

aCabRec	:={STR0042, STR0043 } //"Tipo"###"Valor"
aTamRec	:={050,060}
AAdd(aLinReceb,{"",0})
oPanel[nPainel]:Align := CONTROL_ALIGN_ALLCLIENT
oLBReceb := TwBrowse():New(012,004+nRight,000,000,,aCabRec,aTamRec,OPANEL[nPainel],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLBReceb:SetArray(aLinReceb)
oLBReceb:bLine 	:= { ||{aLinReceb[oLBReceb:nAT][1], Transform(aLinReceb[oLBReceb:nAT][2],cMasc3) }}
oLBReceb:lHScroll	:= .F.
oLBReceb:nHeight	:= 140
oLBReceb:nWidth		:= 320

aCabBx	:={STR0042, STR0043 } //"Tipo"###"Valor"
aTamBx	:={050,060}
AAdd(aLinBX,{"",0})
oLBBx := TwBrowse():New(012,175+nRight,000,000,,aCabBx,aTamBx,OPANEL[nPainel],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLBBx:SetArray(aLinBx)
oLBBx:bLine 	:= { ||{aLinBX[oLBBx:nAT][1], Transform(aLinBX[oLBBx:nAT][2],cMasc3) }}
oLBBx:lHScroll	:= .F.
oLBBx:nHeight	:= 140
oLBBx:nWidth	:= 320

nTotal:=0
nTotalBx:=0
@ 096,005+nRight SAY OemToAnsi( STR0044 )	SIZE 020,007 OF OPANEL[nPainel] PIXEL  //"Saldo Final"
@ 093,035+nRight MSGET oTotal Var nTotal	SIZE 070,009 OF OPANEL[nPainel] PIXEL When .F.  Picture cMasc3
@ 096,175+nRight SAY OemToAnsi( STR0045 ) 	SIZE 040,007 OF OPANEL[nPainel] PIXEL  //"Valores expressos em "
FAMoedas(dDataRef,cNumFatAut)
oCBMoed:= TComboBox():New(090,220+nRight,bSEL,aNomeMoed,070,020,oPanel[nPainel], ,{||RefData(If(lIncAdt,2,4),cNumFatAut,lIncAdt)} , , , ,.t.,,,,)

//ฺฤฤฤฤฤฤฤฤฤฤ
//ณ PANEL 5 ณ
//ภฤฤฤฤฤฤฤฤฤฤ

OPANEL[nPainel]:NCLRPANE:= RGB(233,233,233) //13165800

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ INICIALIZA TELA	 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

ShowPanel(1,@oPanel,cNumFatAut,lIncAdt)

// Botoes
Aadd( aButtons, {"RPMDES",{ || A087aCFG() }, STR0128,STR0145} ) // "Configurador de campos" ###"Config."

If ! Empty(cNumFatAut)
   FA087aAtuCli(cNumFatAut)
Endif

If lPanelFin
	ACTIVATE DIALOG oDlgRecibo ON INIT (If(Type("bFunAuto")=="B",Eval(bFunAuto),),FaMyBar(oDlgRecibo,{|| MsAguarde({|| lSalvou := .T. .And. Fa087aSalvar(NIL,NIL,cNumFatAut,lIncAdt,aRecAdt)}),If(lSalvou,oDlgRecibo:End(),Nil) },{|| MsAguarde({|| Fa087aCancel(nPanel,nLastPan)}),oDlgRecibo:End()},aButtons))
Else
	ACTIVATE DIALOG oDlgRecibo ON INIT  (If(Type("bFunAuto")=="B",Eval(bFunAuto),), EnchoiceBar(oDlgRecibo,{|| MsAguarde({|| lSalvou := .T. .And. Fa087aSalvar(NIL,NIL,cNumFatAut,lIncAdt,aRecAdt)}),If(lSalvou,oDlgRecibo:End(),Nil) },{|| MsAguarde({|| Fa087aCancel(nPanel,nLastPan)}),oDlgRecibo:End()},,aButtons))
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณShowPanel บAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mostra o panel referente ao passo em questao.			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ShowPanel( nPan, oPanel,cNumFatAut,lIncAdt)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Parametros utilizados na funcao                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ nPan 	- Numero do panel a ser mostrado.             ณ
//ณ oPanel 	- Objeto recebido como referencia.            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local nX := 1
Local nLastPan := 4

DEFAULT lIncAdt := .F.

//Caso o objeto oPanel esteja sem valor, recupero atrav้s do
//objeto de backup
If oPanel == Nil
	oPanel := oObjBkp
EndIf

If lIncAdt
	nLastPan := 2 //ANGOLA tem menos paineis na inclusao de adiantamento
Endif

If ExistBlock("TelaCon")
	nLastPan:=ExecBlock("TelaCon",.F.,.F.,{nLastPan})
EndIf

If nPan != nLastPan
	//Atualiza taxas das moedas
	FaMoedas()
EndIf

If nPan > 0 .And. nPan <= nLastPan
	For nX:=1 To Len(oPanel)
		If ( nX!=nPan )
			IF nX <= Len(aoCB)
				aoCB[nX]:Hide()
				aoCB[nX]:Refresh()
			Endif
			oPanel[nX]:Hide()
			oPanel[nX]:Refresh()
		Else
			IF nX <= Len(aoCB)
				aoCB[nX]:Show()
				OBJRefresh(nPan)
			Endif
			oPanel[nX]:Show()
			oPanel[nX]:Refresh()
			oDlgRecibo:cCaption:=aTitulo[nX]
			If (nPan == nLastPan) .Or. (nPan > 4) .Or. (nPan == 4 .And. Ascan(aLinSE1, {|x| x[1] == 1 }) == 0 )
				RefData(nPan,cNumFatAut,lIncAdt)
			EndIf
		EndIf

	Next nX
	Do Case
		Case nPan == 2 .and. !lIncAdt
			oLBCli:SetFocus()
		Case nPan == 3 .and. !lIncAdt
			oLBSE1:SetFocus()
	End Case
	nPan:=nPanel
Else
	If nPanel <  1
		nPanel:=1
		nPan:=nPanel
	Else
		nPanel:= nLastPan
		nPan:= nPanel
	EndIf
EndIf

//Efetuo uma copia do objeto oPanel caso na pr๓xima chamada da fun็ใo
//o mesmo seja passado com valor NIL, preservando a integridade da rotina
oObjBkp := oPanel

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA087aVld บAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz a validacao de campos que nao estao no Browse.		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Parametros utilizados na funcao                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ cVar 	- Variavel a ser validada.			          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Retorna aRet, se .T. ้ que o conteudo e valido.		  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
Function FA087aVld(cVar , cNumFatAut , lIncAdt )

Local lRet 	:= .T.

DEFAULT cNumFatAut := ""
DEFAULT lIncAdt	   := .F.

Do Case
	Case cVar=="cRecibo"
		If Empty(cRecibo)
			MsgStop(STR0116)   //"Por favor, primero indique o campo de nr do recibo"
			Return (.F.)
		EndIf
		DbSelectArea("SEL")
		DbSetorder(8)
		If dbSeek(xFilial("SEL")+cSerie+cRecibo)
			Help(" ",1,"EXISTNUM")
			Return(.F.)
		EndIf

		//Ponto de Entrada F087ACOB
		//Usado no preenchimento automatico do cobrador, quando informado o n. do recibo
		If ExistBlock("F087ACOB")
			cCobrador:= ExecBlock("F087ACOB",.F.,.F.)
		Endif

		dDataRef	:= dDataBase
	OtherWise
		dDataRef	:= dDataBase
		cCliente	:=	Space(Len(SEL->EL_CLIENTE))
		cLoja		:=	Space(Len(SEL->EL_LOJA))
		cNome		:=	Space(TamSX3("A1_NOME")[1])
		cCGC		:=	Space(TamSX3("A1_CGC")[1])
		cContato	:=	Space(TamSX3("A1_CONTATO")[1])
		cTel		:=	Space(TamSX3("A1_TEL")[1])
		RefData(1,cNumFatAut,lIncAdt)
		OBJRefresh(1)
EndCase

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA087aOrd บAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ordena linhas do Grid de acordo com Combo.        		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Parametros utilizados na funcao                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ nCombo	- Qual combo deve ser considerado		      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
Static Function FA087aOrd(nCombo)
Local nPos

If nCombo==1
	nPos := Ascan(aCabSEL,cOrdSEL)
	If lDecr
		ASort(aCols,,,{|x,y| x[nPos]> y[nPos]})
	Else
		ASort(aCols,,,{|x,y| x[nPos]< y[nPos]})
    Endif
	oGetSEL:ForceRefresh()
Endif
If nCombo==2
	nPos := Ascan(aCabSA1,cOrdSA1)
	If lDecr
		ASort(aLinSA1,,,{|x,y| x[nPos]> y[nPos]})
	Else
		ASort(aLinSA1,,,{|x,y| x[nPos]< y[nPos]})
	Endif
	oLBCli:SetArray(aLinSA1)
	oLBCli:bLine:= { || &(cBLinSA1 + "}") }
	oLBCli:Refresh()
Endif
If nCombo==3
	nPos := Ascan(aCabSE1,cOrdSE1)
	If lDecr
		ASort(aLinSE1,,,{|x,y| x[nPos]> y[nPos]})
	Else
		ASort(aLinSE1,,,{|x,y| x[nPos]< y[nPos]})
	Endif
	oLBSE1:SetArray(aLinSE1)
	oLBSE1:bLine:= { || &(cBLinSE1 + "}") }
	oLBSE1:Refresh()
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA087aBuscar บAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca valor do campo cPesq de acordo com o combo. 			 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA087aBuscar(lIncAdt)

Local nX
Local nPos
Local nLin:=1
Local cTipo
Local aLin

//ANGOLA
DEFAULT lIncAdt := .F.

If nPanel==1
	oGetSEL:oBrowse:SetFocus()
	nPos	:= Ascan(aCabSEL,cOrdSEL)
	nPos	:= iif(nPos>0,nPos,1)
	aLin 	:= aClone(aCols)
	cTipo	:= Type(aCposSEL[nPos])
Endif
If nPanel==2
	oLBCli:SetFocus()
	nPos	:= Ascan(aCabSA1,cOrdSA1)
	nPos	:= iif(nPos>0,nPos,1)
	aLin	:= aClone(aLinSA1)
	cTipo	:= Type(aCposSA1[nPos])
Endif
If nPanel==3 .and. !lIncAdt
	oLBSE1:SetFocus()
	nPos	:= Ascan(aCabSE1,cOrdSE1)
	nPos	:= iif(nPos>0,nPos,1)
	aLin	:= aClone(aLinSE1)
	cTipo	:= Type(aCposSE1[nPos])
Endif

cText	:=cPesq
nX 		:= 1

If nPos > 0
	For nX:= 1 to Len(aLin)
		Do Case
			Case cTipo=="D"
				If CtoD(cText)=aLin[nX][nPos]
					nLin:=nX
					Exit
				Endif
			Case cTipo=="N"
				If Val(cText)=aLin[nX][nPos]
					nLin:=nX
					Exit
				Endif
			Case cTipo$"C|U"
				If Upper(Alltrim(cText)) $ Upper(Alltrim(aLin[nX][nPos]))
					nLin:=nX
					Exit
				Endif
		EndCase
	Next nX

	If nPanel==1
		aCols	:=	aClone(aLin)
		n:=nlin
		oGetSEL:oBrowse:nAt:=nLin
		oGetSEL:oBrowse:Refresh()
		oGetSEL:oBrowse:SetFocus()
	Endif
	If nPanel==2
		aLinSA1		:= aClone(aLin)
		oLBCli:nAt := nLin
		oLBCli:SetArray(aLinSA1)
		oLBCli:bLine:= { || &(cBLinSA1 + "}") }
		oLBCli:SetFocus()
	Endif
	If nPanel==3 .and. !lIncAdt
		aLinSE1 		:= aClone(aLin)
		oLBSE1:nAt := nLin
		oLBSE1:SetArray(aLinSE1)
		oLBSE1:bLine:= { || &(cBLinSE1 + "}") }
		oLBSE1:SetFocus()
	Endif
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRefData   บAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Remonta dados do Grid, de acordo com Panel.                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RefData(nPan,cNumFatAut,lIncAdt)

Local aRecs			:={}
Local nValDac		:= 0
Local lQuery		:= .F.
Local cQuery		:= ""
Local nI			:= 0
Local nCAsc			:= 0
Local cStrTipos		:= "'"
Local cCposSE1		:= ""
Local cCposSA1		:= ""
Local cFilClie		:= ""
Local nQtdCli		:= 0
Local nContCli		:= 0
Local lFiltSE1		:= ExistBlock("F087ASE1")
Local aCli			:= {}
Local nX			:= 0
LOCAL nTamPre
LOCAL nTamNum
LOCAL nTamParcel
LOCAL nTamTipTit
LOCAL nLastPanel	:= 4
Local lF087aFcl		:= Existblock("F087AFCL" )
Local nImpRet		:= 0
Local cLstNoBlq		:= FN022LSTCB(6,'0008')	//Lista das situacoes de cobranca (Nใo bloqueadas para determinado processo)
Local nValAux		:= 0
Local nValMon		:= 0

DEFAULT cNumFatAut	:= ""
DEFAULT lIncAdt		:= .F.

nPosDesc  			:= AScan(aCposSE1,"nDescSE1")
nPosJuros 			:= AScan(aCposSE1,"nJurSE1")
nPosJurosC 			:= AScan(aCposSE1,"nJurosCalc")
nPosMultaC 			:= AScan(aCposSE1,"nMultaCalc")
nPosDescC 			:= AScan(aCposSE1,"nDescCalc")
nPosVA 	 			:= AScan(aCposSE1,"nVASE1")
nPosMulta 			:= AScan(aCposSE1,"nMultaSE1")
nPosSaldo 			:= AScan(aCposSE1,"E1_SALDO")
nPosMotBx 			:= AScan(aCposSE1,"cMotBxSE1")
nPosImpRet			:= ASCAN(aCposSE1,"nImpRetSE1")

#IFDEF TOP
	If TCSrvType() != "AS/400"
		lQuery := .T.
	EndIf
#ENDIF

//Inclusao de adiantamentos tem menos paineis
If lIncAdt
	nLastPanel := 2
Endif

If nPan == 1
	c_Alias 	:= "SEL"
	nIndice := 8
	cSeek	:= xFilial("SEL")+cSerie+cRecibo
	cSelec	:= ".T."
	cWhi  	:= "(!EOF() .And. EL_FILIAL == '" + xFilial("SEL") +"' .And. SEL->EL_SERIE == '" + cSerie +"' .And. SEL->EL_RECIBO == '" + cRecibo + "')"
	aCols 	:= MontaGrid(c_Alias,cWhi,cSelec,.F.,".F.",cSeek,nIndice,aCposSEL)
Endif

//ANGOLA - Esta painel nao e habilitado na incusao de adiantamentos
//Painel de clientes
If nPan == 2 .and. !lIncAdt
	nIndice := 1
	c_Alias 	:= "SA1"
	cSeek	:=""

	If nFiltro==4
		aUserFilter := ExecBlock("F087AFIL",.F.,.F.)
		nIndice := aUserFilter[1]
		cSeek	:= aUserFilter[2]
		cSelec	:= aUserFilter[3]
		cWhi  	:= aUserFilter[4]
		If Len(aUserFilter) > 4
			cQuery  := aUserFilter[5]
		EndIf
	Endif
	If nFiltro==3  // melhorar performance para Query caso nao haja filtro de cliente
		If !lQuery
			cSeek	:= xFilial("SA1")
			cSelec	:= ".T."
			cWhi  	:= "(!EOF() .And. SA1->A1_FILIAL == '" + xFilial("SA1") + "')"
		Else
			//Determina os campos que serao selecionado na query...
			aEval(aCposSA1,{|x,y| cCposSA1 += Iif(Left(x,2)=="A1",AllTrim(x)+", ","")})
			cCposSA1 += "SA1.D_E_L_E_T_,SA1.R_E_C_N_O_"

			cQuery := "SELECT DISTINCT A1_FILIAL,"+cCposSA1
			cQuery += " FROM "+RetSQLName("SA1")+" SA1,"+RetSQLName("SE1")+" SE1"
			cQuery += " WHERE A1_FILIAL = '"+xFilial("SA1")+"' AND"
			cQuery += " A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND E1_SALDO > 0 AND"
			cQuery += " SA1.D_E_L_E_T_ <> '*'"
			cQuery += " ORDER BY "+SqlOrder(SA1->(IndexKey(nIndice)))

			If lF087aFcl

			   cQueryAnt := cQuery
			   cQuery := ExecBlock("F087aFcl", .f., .f., {cQuery,cCposSA1})

			   If Empty( cQuery)
			   	cQuery := cQueryAnt
			   EndIf

			EndIf

			cQuery := ChangeQuery(cQuery)

			cSeek  := ""
			cWhi   := "!EOF()"
		    cSelec := ".T."
		EndIf
	Endif
	If nFiltro==2
		cSeek	:= xFilial("SA1")+cCliente
		cSelec	:= "'" + xFilial("SA1")+cCliente+ "' == A1_FILIAL+A1_COD"
		cWhi  	:= "(!EOF() .And. SA1->A1_FILIAL == '" + xFilial("SA1") + "') .And. ('" + cCliente + "' == A1_COD)"
	Endif
	If nFiltro==1
		cSeek	:= xFilial("SA1")+cCliente+cLoja
		cSelec	:= "'" + xFilial("SA1")+cCliente+cLoja + "' == SA1->A1_FILIAL+SA1->A1_COD+SA1->A1_LOJA"
		cWhi  	:= "(!EOF() .And. SA1->A1_FILIAL == '" + xFilial("SA1") + "') .And. ('" + cCliente + cLoja + "' == A1_COD+A1_LOJA)"
	Endif
	cCondMca:= "(A1_COD == '" + cCliente + "' .And. A1_LOJA =='" + cLoja + "')"
    cSelec	+= IIf(!Empty(aFiltros[2])," .And. ("+aFiltros[2]+")","")
	aLinSA1	:= MontaGrid(c_Alias,cWhi,cSelec,.T.,cCondMca,cSeek,nIndice,aCposSA1,,cQuery)

	oLBCli:SetArray(aLinSA1)
	oLBCli:bLine:= { || &(cBLinSA1 + "}") }
	FaMoedas(NIL,cNumFatAut)
Endif

//ANGOLA - Esta painel nao e habilitado na incusao de adiantamentos
//Painel de titulos a baixar
If nPan == 3 .and. !lIncAdt
 ValAltArray(aLinSE1,@aLinSE1_Ori,aLinSA1,@aLinSA1_Ori,@cCliLoj_Ori)
	c_Alias	:= "SE1"
	nIndice := 2
	cCondMca:= ".F."
	cSelec  := ""
	aCli	:={}

	nPosCli	:= AScan(aCposSA1,"A1_COD")
	nPosLoja:= AScan(aCposSA1,"A1_LOJA")

	AEval(oLBCli:aARRAY, {|x,y| If(oLBCli:aARRAY[y][1] == 1, nQtdCli++,.T.)})//Qtd de Clientes selecionados

	If nQtdCli >= 300
	    // limite de selecao de clientes para que nao estoure a string a ser montada a seguir.
	    // a cQuery tem um limite de 15980 bytes, e o limite de 300 clientes garante que a string cQuery
	    // nao estoure, considerando os tamanhos "default" para os campos codigos e loja de cliente (6 e 2)
		Alert(STR0112) //"Limite de 300 clientes selecionados foi atingido. Por favor, verifique a selecao feita."
	Else
		nX:=1
		For nX:= 1 to Len(oLBCli:aARRAY) //ListBox de clientes
			If oLBCli:aARRAY[nX][1] == 1 // Cliente esta selecionado
				AAdd(aCli,{oLBCli:aARRAY[nX][nPosCli],oLBCli:aARRAY[nX][nPosLoja]})
				If !lQuery //Prepara a condicao de filtro para DBF
					cFilClie += oLBCli:aARRAY[nX][nPosCli] +  oLBCli:aARRAY[nX][nPosLoja] + "|"
				Else //Prepara a condicao de filtro para Bco de Dados
					cFilClie += "(E1_CLIENTE = '" + oLBCli:aARRAY[nX][nPosCli] + "' AND E1_LOJA = '" + oLBCli:aARRAY[nX][nPosLoja] + "')"
					nContCli++
					If nContCli != nQtdCli //Verifica se existem mais clientes para se adicionar a Query
						cFilClie  += " OR "
					Else
						cFilClie  += ") AND "
					EndIf
				EndIf
			Endif
		Next nX
		aSort(aCli ,,,{|x,y| x[1]+x[2] < y[1]+y[2]})
		cFilClie := Iif(lQuery,"("+cFilClie,cFilClie)
	EndIf

	If Len(aCli) > 0

		aSize( aLinSE1 , 0 )
		aSize( aSE5Comp , 0 )
		nCompensa := 0

		If lFiltSE1
			aUserFilSE1 := ExecBlock("F087ASE1",.F.,.F.)
			nIndice := aUserFilSE1[1]
			cSeek	:= aUserFilSE1[2]
			cSelec	:= aUserFilSE1[3]
			cWhi  	:= aUserFilSE1[4]
			If Len(aUserFilSE1) > 4
				cQuery  := aUserFilSE1[5]
			EndIf
		Else
			If !lQuery
				If lConsFilial
					ASort(aCli,,,{|x,y| x[1]+x[2] < y[1]+y[2]})
					cSeek := xFilial(c_Alias)+ aCli[1][1] + aCli[1][2]
					cWhi  := "(!EOF() .And. SE1->E1_FILIAL == '" + xFilial("SE1") + "') .AND."
					If Len(aCli) > 1
				      cWhi  += " (E1_CLIENTE+E1_LOJA  <= '" + aCli[Len(aCli)][1] +aCli[Len(aCli)][2] + "')"
				  	Else
					  	cWhi  += " (E1_CLIENTE+ E1_LOJA) $ '" + cFilClie + "'"
				   EndIf
				Else
					cSeek := ""
					cWhi  := "!EOF()"
				EndIf
			   cSelec:= IIf(!Empty(cSelec) .And. !Empty(aFiltros[3])," .And. ","") + IIf(!Empty(aFiltros[3]),Alltrim(aFiltros[3]),"")
				cSelec+= IIf(!Empty(cSelec)," .And. ","") + "E1_TIPO$'"+cTipos+"' .And. SE1->E1_EMISSAO <= dDataRef"

				If lConsFilial
					cSelec += IIf(!Empty(cSelec)," .And. ","")+"(E1_CLIENTE+E1_LOJA $ '" + cFilClie + "')"
				EndIf
				If lConsSaldo
					 cSelec+= " .And. SE1->E1_SALDO > 0"
				EndIf

				//PCREQ-3782 - Bloqueio por situa็ใo de cobran็a
				cSelec += '.And. SE1->E1_SITUACA $ "'+cLstNoBlq+'" '

			Else
				For nI := 1 To Len(cTipos)
					nCAsc := Asc(SubStr(cTipos,nI,1))
					If (nCAsc == 32) .Or. (nCAsc == 45) .Or.;
					   (nCAsc >= 48 .And. nCAsc <= 57 ) .Or.;
					   (nCAsc >= 65 .And. nCAsc <= 90 ) .Or.;
					   (nCAsc >= 97 .And. nCAsc <= 122)

						cStrTipos += (SubStr(cTipos,nI,1)+Iif(nI==Len(cTipos),	"'",""))
					Else
						cStrTipos += "','"
					EndIf
				Next nI

				cStrTipos	:=	IIf(Right(cStrTipos,2)==",'",Substr(cStrTipos,1,Len(cStrTipos)-2),cStrTipos)
				//Determina os campos que serao selecionado na query...
				aEval(aCposSE1,{|x,y| cCposSE1 += Iif(Left(x,2)=="E1",AllTrim(x)+", ","")})
				cCposSE1 += "D_E_L_E_T_, R_E_C_N_O_"

				cQuery := "SELECT "+cCposSE1
				cQuery += " FROM "+RetSQLName("SE1")
				If lConsFilial
					cQuery += " WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND"
					cQuery += cFilClie
				Else
					cQuery += " WHERE "+cFilClie+" "
				EndIf
			    cQuery += " E1_EMISSAO <= '"+Dtos(dDataRef)+"' AND"
			    cQuery += " E1_TIPO IN ("+cStrTipos+") AND"
				If lConsSaldo
					cQuery += " E1_SALDO > 0 AND"
				EndIf
				cQuery += " E1_NUM <> ' ' AND"

				If ! Empty(cNumFatAut)
                   nTamPre    := TamSX3("E1_PREFIXO")[1]
                   nTamNum    := TamSX3("E1_NUM")[1]
                   nTamParcel := TamSX3("E1_PARCELA")[1]
                   nTamTipTit := TamSX3("E1_TIPO")[1]

				   cQuery += "( E1_PREFIXO = '"+Subs(cNumFatAut,1,nTamPre)+"' AND E1_NUM = '"+Subs(cNumFatAut,nTamPre+1,nTamNum)+"' AND E1_PARCELA = '"+Subs(cNumFatAut,nTamPre+nTamNum+1,nTamParcel)+"' AND E1_TIPO = '"+Subs(cNumFatAut,nTamPre+nTamNum+nTamParcel+1,nTamTipTit)+"' ) AND "
				Endif

				//PCREQ-3782 - Bloqueio por situa็ใo de cobran็a
				cQuery += " E1_SITUACA IN "+FormatIn(cLstNoBlq,'|')+" AND "

				cQuery += " D_E_L_E_T_ = ' '"

				// Adicionado para atender a Shark 12/01/2010
				If ExistBlock("F087AQRY")
					cQuery += ExecBlock("F087AQRY",.F.,.F.)
				EndIf

				cQuery += " ORDER BY "+SqlOrder(SE1->(IndexKey(nIndice)))
				cQuery := ChangeQuery(cQuery)

				cSeek  := ""
				cWhi   := "!EOF()"
			    cSelec := ".T."
			    cSelec += IIf(!Empty(cSelec) .And. !Empty(aFiltros[3])," .And. ","") + IIf(!Empty(aFiltros[3]),Alltrim(aFiltros[3]),"")
			EndIf
		EndIf
		aLinSE1     := AClone(MontaGrid(c_Alias,cWhi,cSelec,.T.,cCondMca,cSeek,nIndice,aCposSE1,.T.,cQuery))
	Else
		cWhi	:=	'.F.'	// Se nenhum cliente estiver selecionado, cria o aLinhas em branco
		cSelec	:=	'.F.'	// Se nenhum cliente estiver selecionado, cria o aLinhas em branco
		cSeek	:= "ZZZZZZZZ"
		aLinSE1 := AClone(MontaGrid(c_Alias,cWhi,cSelec,.T.,cCondMca,cSeek,nIndice,aCposSE1,.T.))
	Endif

	oLBSE1:SetArray(aLinSE1)
	oLBSE1:nAt 	:= 1
	oLBSE1:bLine:= { || &(cBLinSE1 + "}") }
Endif

If	((nPan == nLastPanel) .And. lIncAdt) .Or. (nPan == 4)
	nPosTipo	:= AScan(aCposSEL,"EL_TIPODOC")
	nPosVal		:= AScan(aCposSEL,"EL_VALOR")
	nPosMoedTit	:= AScan(aCposSEL,"EL_MOEDA")
	aLinReceb	:= {}

	aRecs:=AClone(aCols)
	ASort(aRecs,,,{|x,y| x[nPosTipo] < y[nPosTipo]})
	cTipo:=NIL
	nX:=1
	For nX:= 1 To Len(aRecs)
		If cTipo!=aRecs[nX][nPosTipo] .and. !aRecs[nX][Len(aRecs[nX])]
			AAdd(aLinReceb,{aRecs[nX][nPosTipo],0})
			cTipo:=aRecs[nX][nPosTipo]
		Endif
		If aRecs[nX][nPosVal]!=Nil .and. !aRecs[nX][Len(aRecs[nX])]
			nM:=IIf(Empty(aRecs[nX][nPosMoedTit]).Or. Val(aRecs[nX][nPosMoedTit])<=1,1,Val(aRecs[nX][nPosMoedTit]))
			aLinReceb[Len(aLinReceb)][2]+=aRecs[nX][nPosVal]*(aTaxa[nM]/aTaxa[oCBMOed:nAt])
		Endif
	Next nX

	oLBReceb:SetArray(aLinReceb)
	oLBReceb:bLine := { ||{aLinReceb[oLBReceb:nAT][1],Transform(aLinReceb[oLBReceb:nAT][2],fnPesqPict("SEL","EL_VALOR",18,oCBMOed:nAt)) }}
	oLBReceb:Refresh()

	// Monta Resumo das baixas
	aLinBx := {}

	//Inclusao de adiantamento nao tem valor baixado
	If !lIncAdt
		nPosTipo	:= AScan(aCposSE1,"E1_TIPO")
		nPosVal		:= AScan(aCposSE1,"nBaixar")
		nPosMoedTit	:= AScan(aCposSE1,"E1_MOEDA")
		nPosDesc 	:= AScan(aCposSE1,"nDescSE1")
		nPosJuros	:= AScan(aCposSE1,"nJurSE1")
		nPosJurosC	:= AScan(aCposSE1,"nJurosCalc")
		nPosMultaC	:= AScan(aCposSE1,"nMultaCalc")
		nPosDescC	:= AScan(aCposSE1,"nDescCalc")
		nPosVA		:= AScan(aCposSE1,"nVASE1")
		nPosMulta	:= AScan(aCposSE1,"nMultaSE1")
		nPosImpRet	:= AScan(aCposSE1,"nImpRetSE1")

		aRecs:=AClone(aLinSE1)
		ASort(aRecs,,,{|x,y|  Str(x[1]) + x[nPosTipo] <  Str(y[1]) + y[nPosTipo]})
		cTipo:=Nil
		nX:=1
		For nX:= 1 To Len(aRecs)
			If aRecs[nX][1]<1
				Exit
			Endif
			If cTipo!=aRecs[nX][nPosTipo]
				AAdd(aLinBx,{aRecs[nX][nPosTipo],0})
				cTipo:=aRecs[nX][nPosTipo]
			Endif
			nM:=IIf(Empty(aRecs[nX][nPosMoedTit]).Or. aRecs[nX][nPosMoedTit]<=1,1,aRecs[nX][nPosMoedTit])
			If aRecs[nX][nPosTipo]$MVRECANT+"/"+MV_CRNEG
				If cPaisLoc == "URU" .And. (aRecs[nX][nPosVal]*(aTaxa[nM]/aTaxa[oCBMOed:nAt]) - nSaldo) > 0
					nValAux := (nSaldo / aTaxa[nM] )
					nValMon := Round((nValAux * aTaxa[nM]),MsDecimais(nM))
					If nValMon == nSaldo
						aLinBx[Len(aLinBx)][2]-= nValMon
					Endif
				Else
					aLinBx[Len(aLinBx)][2]-=aRecs[nX][nPosVal]*(aTaxa[nM]/aTaxa[oCBMOed:nAt])
				Endif
				If aRecs[nX][nPosMotBx]=="DAC"
					nValDac-=aRecs[nX][nPosVal]*(aTaxa[nM]/aTaxa[oCBMOed:nAt])
		        EndIf
			Else
				If cPaisloc<>"BRA"
					aLinBx[Len(aLinBx)][2]+=(aRecs[nX][nPosVal]-aRecs[nX][nPosDesc]+aRecs[nX][nPosJuros]+aRecs[nX][nPosMulta])*aTaxa[nM]/aTaxa[oCBMOed:nAt]
				Else
					aLinBx[Len(aLinBx)][2]+=Round((aRecs[nX][nPosVal]-aRecs[nX][nPosDesc]+aRecs[nX][nPosJuros]+aRecs[nX][nPosMulta])*aTaxa[nM]/aTaxa[oCBMOed:nAt],MsDecimais(nM))
				EndIf
				If aRecs[nX][nPosMotBx]=="DAC"
					nValDac+=aRecs[nX][nPosVal]*(aTaxa[nM]/aTaxa[oCBMOed:nAt])
		        EndIf
			Endif
			// Soma Reten็ใo de Impostos como Baixa
			if nPosImpRet > 0 .and. aRecs[nX, nPosImpRet] > 0
				nImpRet += aRecs[nX, nPosImpRet]
			endif
		Next nX

		If nValDac<>0
			Aadd(aLinBx,{"DAC",nValDac*(-1)})
		Endif
		If nDescGer>0
			Aadd(aLinBx,{"DC",nDescGer*(aTaxa[nMoedDesc]/aTaxa[oCBMoed:nAt])*(-1)})
		Endif
		If nPercGer>0
			nTotBx:=0
			AEval(aLinBx,{|x| If(!(x[1]$MVRECANT+"/"+MV_CRNEG+"/DAC"),nTotBx +=x[2],0)})
			AAdd(aLinBx,{"DC",nPercGer*nTotBx*0.01*(-1)})   // Aplica percentual de desconto
		Endif

    	// Percep็ใo de IGV - Peru
		If cPaisLoc $ "EQU|PER" .And. nValPerc > 0 .And. aPerc[1][8] //
			Aadd(aLinBx,{"P",nValPerc*(aTaxa[nMoedDesc]/aTaxa[oCBMoed:nAt])*(1)})
			cTipo:="P"
		EndIf

	Endif

	nTotBx:=0
	AEval(aLinBx,	{|x| nTotBx +=x[2]})
	nTotRec:=0
	AEval(aLinReceb,{|x| nTotRec += x[2]})

	oLBBx:SetArray(aLinBx)
	oLBBx:bLine := { ||{aLinBx[oLBBx:nAT][1],Transform(aLinBx[oLBBx:nAT][2],fnPesqPict("SE1","E1_VALOR",18,oCBMOed:nAt)) }}
	oLBBx:Refresh()
	nTotalBx := nTotBx
	nTotal:= Round(nTotRec-nTotBx,MsDecimais(oCBMOed:nAt))
	oTotal:Picture:=fnPesqPict("SE1","E1_VALOR",TamSX3("E1_VALOR")[1],oCBMOed:nAt)
	oTotal:Refresh()
EndIf


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA087aVld บAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz refresh dos objetos do Panel informado.        		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OBJRefresh(nPan)

If nPan==1
	oGetSEL:ForceRefresh()
	oGetSEL:oBrowse:Refresh()
	aDadosAdm:={}
Endif
If nPan==2
	oLBCli:Refresh()
Endif
If nPan==3
	oLBSE1:Refresh()
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFAMoedas  บAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta ListBox que contem as taxas das moedas.			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Parametros utilizados na funcao                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ dData	- Data para buscar no SM2, caso nao informada,ณ
//ณ nao monta taxas, somente Saldos.                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
Static Function FAMoedas(dData,cNumFatAut)

Local nI 		:= 1
Local aCabMoed	:=	{}
Local aTamMoed	:=	{}
Local aCpsMoed	:=	{}
Local anTotRec	:= {}
Local anTotBax	:= {}
Local nRec		:= 0
Local nBax		:= 0
Local lNovo		:= .F.
DEFAULT cNumFatAut := ""

aCpsMoed:={"cMoeda","nTaxa","nRecebido","nBxTotMoed"}

Posicione("SX3",2,"EL_MOEDA","X3_TITULO")
Aadd(aCabMoed,X3Titulo())
Posicione("SX3",2,"EL_TXMOEDA","X3_TITULO")
Aadd(aCabMoed,X3Titulo())
Aadd(aCabMoed,STR0047)
Aadd(aCabMoed,STR0048)

aTamMoed:={23,35,48,30}

If dData!=NIL						// Se a data for informada, remonta taxas das moedas
	For nI:= 1 to Len(aTaxa)
		aTaxa[nI]	:= xMoeda(1,nI,1,dData,TamSx3("M2_MOEDA"+Alltrim(Str(nI)))[2])
	Next nI
Else
	For nI:= 1 to Len(aTaxa)
		aTaxa[nI]	:= aLinMoed[nI][2]
	Next nI
Endif

anTotRec:=SomaReceb()
anTotBax:=SomaBaixa()

nI:=1
For nI := 1 To nQtMoedas
	nRec	:= anTotRec[nI]
	nBax 	:= anTotRec[nI] - anTotBax[nI]
	aLinMoed[nI]:={aNomeMoed[nI],aTaxa[nI],nRec,nBax}
Next nI
If oLBMoed==NIL
	aSize := MSADVSIZE()
	oLBMoed	:=TwBrowse():New(001,(aSize[5]/2)-200,000,000,,aCabMoed,aTamMoed,oPanelTop,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	lNovo	:=.T.
Endif

IF lNovo
	oLBMoed:SetArray(aLinMoed)
	oLBMoed:bLine 	:= { ||{aLinMoed[oLBMoed:nAT][1],;
	Transform(aLinMoed[oLBMoed:nAT][2],fnPesqPict("SM2","M2_MOEDA"+AllTrim(Str(oLBMoed:nAT)),TamSx3("M2_MOEDA"+AllTrim(Str(oLBMoed:nAT)))[1])),;
	Transform(aLinMoed[oLBMoed:nAT][3],fnPesqPict("SEL","EL_VALOR",TamSx3("EL_VALOR")[1]+6,oLBMoed:nAT)),;
	Transform(aLinMoed[oLBMoed:nAT][4],fnPesqPict("SEL","EL_VALOR",TamSx3("EL_VALOR")[1]+6,oLBMoed:nAT)) }}
	oLBMoed:bLDblClick := {|| DCLBMoed(cNumFatAut)}
	oLBMoed:lHScroll:=.F.
	oLBMoed:lVScroll:=.T.
	oLBMoed:nHeight:=112
	oLBMoed:nWidth	:=400
Else
	oLBMoed:Refresh()
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSomaReceb บAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Soma todos os recebimentos.                       		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SomaReceb()

Local nX:=1
Local nPosMoed
Local nPosVal
Local anRec := Array(nQtMoedas)
Local anR 	:= Array(nQtMoedas)

aFill(anRec,0)
aFill(anR,0)

nPosMoed:= AScan(aCposSEL,"EL_MOEDA")
nPosVal	:= AScan(aCposSEL,"EL_VALOR")

For nX:=1 to LEN(aCols)
	if !aCols[nX][Len(aCols[nX])] 		// Se o registro nao estiver deletado
		IF Empty(aCols[nX][nPosMoed]) .Or. aCols[nX][nPosMoed] <= "1"
			anRec[1] += aCols[nX][nPosVal]
		Else
			anRec[Val(aCols[nX][nPosMoed])]+=aCols[nX][nPosVal]
		Endif
	Endif
Next nX

Return(anRec)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSomaBaixa บAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Soma valores a serem baixados.                    		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SomaBaixa()
Local nX:=1
Local nPosMoed
Local nPosVal
Local anBaixa 	:= Array(nQtMoedas)
Local anB		:= Array(nQtMoedas)
Local nMoed
Local nModPos := 0

AFill(anBaixa,0)
AFill(anB,0)

nPosMoed:= AScan(aCposSE1,"E1_MOEDA")
nPosTipo:= AScan(aCposSE1,"E1_TIPO")
nPosVal	:= AScan(aCposSE1,"nBaixar")

//ANGOLA - Inclusao de Adiantamento nao tem tela de titulos a baixar
//Logo aLinSE1 nao vai existir para a soma de valores a baixar
aLinSE1 := If(Type("aLinSE1") != "A",{},aLinSE1)

For nX:=1 to LEN(aLinSE1)
	If aLinSE1[nX][1]== 1 // Esta Marcado
		For nMoed:=1 To nQtMoedas
			If aLinSE1[nX][nPosMotBx]=="DAC"
			// Nao deve fazer nada com os valores
			ElseIf aLinSE1[nX][nPosTipo]$MVRECANT+"/"+MV_CRNEG
				anBaixa[nMoed] -= aLinSE1[nX][anPosMoed[nMoed]]
			Else
				If cPaisloc <> "BRA"
					anBaixa[nMoed] 	+= aLinSE1[nX][anPosMoed[nMoed]]
					anB[nMoed]		+= aLinSE1[nX][anPosMoed[nMoed]]
				Else
					anBaixa[nMoed] 	+= Round(aLinSE1[nX][anPosMoed[nMoed]],MsDecimais(nMoed))
					anB[nMoed]		+= Round(aLinSE1[nX][anPosMoed[nMoed]],MsDecimais(nMoed))
				EndIf
			Endif
		Next nMoed
	Endif
Next nX
If cPaisLoc == "CHI"
	IF valtype(aLinMoed[1]) <> "U"
		nModPos := aScan(aLinMoed,{ |x| UPPER(alltrim(x[1])) == "PESO"})

		If nModPos > 0
			If  ABS(anBaixa[nModPos]) < 1 .AND. ABS(anBaixa[nModPos]) > 0
				anBaixa[nModPos] := round(anBaixa[nModPos],0)
			EndIF
		EndIf
	EndIF
EndIf
nTot:=0

If nDescGer>0
	anBaixa[nMoedDesc] -= nDescGer
Endif

If nPercGer>0
	nTot:=0
	nX:=0
    AEval(anB,{|x,y| nTot += x*aTaxa[y]})

	nTot:=nTot/aTaxa[nMoedDesc]
	anBaixa[nMoedDesc] -= nPercGer*nTot*0.01
Endif

Return(anBaixa)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSomatitBaixa บAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Soma valores a serem baixados sem considerar NEGATIVOS.       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SomaTitBaixa()
Local nX:=1
Local nPosMoed
Local nPosVal
Local anB		:= Array(nQtMoedas)
Local nMoed

AFill(anB,0)

nPosMoed:= AScan(aCposSE1,"E1_MOEDA")
nPosTipo:= AScan(aCposSE1,"E1_TIPO")
nPosVal	:= AScan(aCposSE1,"nBaixar")

For nX:=1 to LEN(aLinSE1)
	If aLinSE1[nX][1]== 1 // Esta Marcado
		For nMoed:=1 To nQtMoedas
			If aLinSE1[nX][nPosTipo]$MVRECANT+"/"+MV_CRNEG .Or. aLinSE1[nX][nPosMotBx]=="DAC"
			Else
				anB[nMoed]		+= aLinSE1[nX][anPosMoed[nMoed]]
			Endif
		Next nMoed
	Endif
Next nX

Return(anB)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA087aHeadบAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta ListBox que contem as taxas das moedas.     		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA087aHead(c_Alias,aCpos,lMark,aCposNo)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Parametros utilizados na funcao                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ c_Alias 	- Arquivo onde buscar as informacoes.     ณ
//ณ aCpos 	- Campos a serem utilizados no cabecalho,     ณ
//ณ caso nao seja informado, cria com base no SX3.        ณ
//ณ aCposNo	- Campos que NAO devem aparecer na Get Dados. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Retornos											  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ aRet[1]	- aHeader a ser utilizado na GetDados.			ณ
//ณ aRet[2]	- Array contendo campos validos.				ณ
//ณ aRet[3]	- Array contendo cabecalho dos campos validos.	ณ
//ณ aRet[4]	- Array contendo Tamanho dos campos validos.	ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local aRet	:= Array(4)
Local aH	:= {}
Local aTam	:= {}
Local aCab	:= {}
Local aSeq	:= {}
Local nX	:= 0
Local nS	:= 0
Local cCamp	:= "EL_CTAORD,EL_CEPCER,EL_CEPCAD,EL_CEPSEL,EL_CTABEN"

If aCpos == NIL .Or. Len(aCpos) == 0
	aCpos:={}
	If lMark
		Aadd(aCpos  ,"nSel")
		AAdd(aSeq	,"nSel")
		AADD(aCab	,"")
		AADD(aTam	,5)
	Endif
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(c_Alias,.F.)
	Do While !EOF() .And. X3_ARQUIVO == Alltrim(c_Alias)
		If x3uso(x3_usado) .And. cNivel >= X3_NIVEL .And. AScan(aCposNo,AllTrim(X3_CAMPO))==0
		    If c_Alias<>"SA1" .or. nFiltro<>3 .or. ;
		    	Alltrim(X3_CAMPO)$"A1_FILIAL,A1_COD,A1_LOJA,A1_NOME,A1_NREDUZ,A1_CGC" .or. ;
		    	(X3_PROPRI=="U" .And. X3_VISUAL!="V")
		    	// caso a selecao de clientes seja sem filtro, restringe a exibicao para aumentar a performance
		    	If X3_TIPO == "M"
			    	If cpaisloc == "MEX" .AND. AllTrim(X3_CAMPO) $ cCamp
			    		AAdd(aCpos,X3_CAMPO)
			    	EndIf
		    	Else
					AAdd(aCpos,X3_CAMPO)
				Endif
			EndIf
		Endif
		DbSkip()
	Enddo
Else
	If lMark
		Aadd(aCpos  ,"")
		AAdd(aSeq	,"")
		AADD(aCab	,"")
		AADD(aTam	,0)
		For nX:= Len(aCpos) To 2 Step -1
			aCpos[nX]	:= aCpos[nX-1]
		Next nX
		aCpos[1]		:= "nSel"
		aSeq[1]		:= "nSel"
		aCab[1]		:= ""
		aTam[1]		:= 5
	Endif
Endif

//No caso de usar marca no list, o primeiro campo nใo deve ser consistido.
If lMark
	nS:=2
Else
	nS:=1
Endif

DbSelectArea("SX3")
DbSetOrder(2)
For nX:=nS to Len(aCpos)
	If DbSeek(aCpos[nX],.F.) .And. x3uso(x3_usado) .And. cNivel >= X3_NIVEL .And. X3_CONTEXT!="V"  .And. IIF(cPaisLoc == "MEX",.t.,X3_TIPO <> "M")

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
		//ณSe o campo foi encontrado no X3 e esta disponivel, adiciona no aH     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
		AAdd(aH,{ TRIM(X3TITULO()), 	X3_CAMPO, 	X3_PICTURE,	X3_TAMANHO,	;
		X3_DECIMAL, X3_VALID,	X3_USADO,	;
		X3_TIPO, 	X3_ARQUIVO,	X3_CONTEXT } )
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
		//ณArmazena em um array separado as sequencias do aCpos que realmente serao utilizadas,ณ
		//ณpara depois poder se referenciar aos campos.                                        ณ
		//ณNao foi utilizado diretamente o aH pois esta rotina monta aHeader                   ณ
		//ณe Cabecalho do ListBox, e seriam posicoes distintas do Array.                       ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
		AADD(aCab,TRIM(X3Titulo()))
		AADD(aTam,iif(X3_TAMANHO > len(TRIM(X3Titulo())),X3_TAMANHO*4.1,len(TRIM(X3Titulo()))*4.1))

		AAdd(aSeq,X3_CAMPO)
	EndIf
	DbSkip()
Next nX

aRet[1]:=aH		// aHeader
aRet[2]:=aSeq		// Array contendo somente campos validos dos que foram passados.
aRet[3]:=aCab		// Array contendo Titulo dos campos validos.
aRet[4]:=aTam		// Array contendo Tamanho dos campos validos.

SX3->(DbSetOrder(1))

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMontaGrid บAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta linhas dos Grids                           		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MontaGrid(c_Alias,cWhile,cCond,lMark,cCMarca,cSeek,nInd,aCpos,lRecno,cQuery,lIncAdt,nPanel)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Parametros utilizados na funcao                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ c_Alias 	- Arquivo onde buscar as informacoes.     ณ
//ณ cWhile 	- Condicao inicial para o While.              ณ
//ณ cCond 	- Se .T. o registro sera inserido no aC.      ณ
//ณ lMark 	- Se usa Marca (somente para ListBox).        ณ
//ณ cCMarca - Se .T. o registro vem marcado.              ณ
//ณ cSeek 	- Registro inicial do while (performance).    ณ
//ณ nInd 	- Indice da Busca.                            ณ
//ณ aCpos 	- Campos utilizados (somente os validos).     ณ
//ณ lRecno	- Se TRUE, carregara o RECNO na penultima pos.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Retorna aC, que sera utilizado como aCols ou Linhas   ณ
//ณ do ListBox.											  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local lAchou:=.F.
Local aC	:= {}
Local nRecs
Local nS	:=1
Local nA	:=1
Local aStru := {}
Local aAreaAtu := GetArea()
Local nLin     := 0
Local nCol     := 0
Local cMvJurTipo 	:= SuperGetMv("MV_JURTIPO",,"")  // calculo de Multa do Loja , se JURTIPO == L
Local lMulLoj	  	:= SuperGetMv("MV_LJINTFS", ,.F.) //Calcula multa conforme regra do loja, se integra็ใo com financial estiver habilitada


DEFAULT lRecno	:=	.F.
DEFAULT cQuery  := ""

//ANGOLA
DEFAULT lIncAdt := .F.
DEFAULT nPanel	 := 0

Private nSel  :=0

nRecs	:=	If(lRecno,2,1)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณDe acordo com todos os parametros passados, monto o aC. 	ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
aC:={}
If Empty(cQuery)
	DbSelectArea(c_Alias)
	DbSetOrder(nInd)
	DbGotop()
	DbSeek(cSeek,.F.)
Else
	//Acerta os campos conforme o seu tipo...
	aStru  := (c_Alias)->(dbStruct())
	c_Alias:= c_Alias+"TMP"
	//Abre a area criada na query...
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), c_Alias, .F., .T.)

	For nA := 1 To Len(aStru)
		If aStru[nA][2] != "C" .And. aStru[nA][2] != "M" .And. FieldPos(aStru[nA][1]) != 0
			TCSetField(c_Alias, aStru[nA][1], aStru[nA][2], aStru[nA][3], aStru[nA][4])
		EndIf
	Next nA

	dbSelectArea(c_Alias)
	dbGoTop()
EndIf

If !Empty(cQuery)
	DbEval({|| A087Load(@aC, nRecs, cCond, @lAchou, lRecno, aCpos, c_Alias)})

//ANGOLA - Inclusao de adiantamento nao tera painel Clientes e Titulos para baixa
ElseIf lIncAdt .and. c_Aliasn $ "SA1#SE1"
	lAchou:=.F.

Else
	While &(cWhile)
		If &(cCond)
			If lMark .And. &cCMarca
				nSel:= 1
			Else
				nSel := -1
			Endif
			lAchou:=.T.
			AAdd(aC,Array(Len(aCpos)+nRecs))
			For nA:=1 to Len(aCpos)
				aC[Len(aC)][nA]   := &(aCpos[nA])
			Next
			If lRecno
				If Empty(cQuery)
					aC[Len(aC)][Len(aC[1])-1]:=(c_Alias)->(Recno())
				Else
					aC[Len(aC)][Len(aC[1])-1]:=(c_Alias)->R_E_C_N_O_
				EndIf
			Endif
			aC[Len(aC)][Len(aC[1])]:=.F.

			If c_Alias == "SE1"
				nLin := Len(aC)
				nCol := Len(aC[nLin])-1

				If !Empty(aC[nLin][nCol])
					aC[nLin][nPosDesc]  	:= FaDescFin(c_Alias,dDataRef,(c_Alias)->E1_SALDO,(c_Alias)->E1_MOEDA)
					aC[nLin][nPosDescC] 	:= aC[nLin][nPosDesc]
					aC[nLin][nPosJuros] 	:= fa070Juros(Max((c_Alias)->E1_MOEDA,1))
					aC[nLin][nPosJurosC] 	:= aC[nLin][nPosJuros]
					aC[nLin][nPosVA]	  	:= Iif(lExistVa,FValAcess((c_Alias)->E1_PREFIXO,(c_Alias)->E1_NUM,(c_Alias)->E1_PARCELA,(c_Alias)->E1_TIPO,(c_Alias)->E1_CLIENTE,(c_Alias)->E1_LOJA,(c_Alias)->E1_NATUREZ, /*lBaixados*/,/*cCodVa*/,"R",dDatabase),0)
				EndIf

				If ( cMvJurTipo == "L" .OR. lMulLoj ) .AND. !( (c_Alias)->E1_TIPO $ (MVRECANT+"/"+MV_CRNEG) )
					If lLojxRMul
						aC[nLin][nPosMulta] 	:=  LojxRMul( , , ,SE1->E1_SALDO, SE1->E1_ACRESC, SE1->E1_VENCREA, dDataBase , , SE1->E1_MULTA, ,;
			  									SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA, "SE1", .T.)
			  			aC[nLin][nPosMultaC] 	:=  aC[nLin][nPosMulta]
			  		EndIf
				EndIf

				//Monta arrays de controle de alteracoes...
				AAdd(aLinSE1_Ori,{aC[nLin][1],aC[nLin][2],aC[nLin][3]})
			EndIf
		Endif

		DbSelectArea(c_Alias)
		DbSkip()
	Enddo
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณSe nao encontrar nenhum registro, cria novamente em branco.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
If !lAchou
	aC := Array(1,Len(aCpos)+nRecs)
	If lMark
		aC[1][1] := 0
		nS:=2
	Else
		nS:=1
	Endif
	SX3->(DBSetOrder(2))
	For nA:=nS to Len(aCpos)
		If SX3->(DbSeek(aCpos[nA]))
			aC[Len(aC)][nA]   := CriaVar(aCpos[nA],.F.)
		Else
			aC[Len(aC)][nA]   := &(aCpos[nA])
		Endif
	Next
	aC[Len(aC)][Len(aC[1])]:=.F.
Endif

If !Empty(cQuery)
	(c_Alias)->(dbCloseArea())
	RestArea(aAreaAtu)
EndIf

SX3->(DbSetOrder(1))

Return(aC)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa087aFldOk  บAutor  ณGuilherme C. Leal   บ Data ณ  20010730   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz a valida็ใo por campo,  utilizada para atualizar moedas. บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function a087aFldOk()

Local cCampo:= Alltrim(ReadVar())
Local nPosMoed
Local nPosVal
Local lRet:=.T.
Local lBlockBco := SA6->A6_BLOCKED == "1"

Do Case
	Case cCampo=="M->EL_MOEDA"
		nPosMoed := AScan(aCposSEL,"EL_MOEDA")
		aCols[n][nPosMoed]:=&(cCampo)
		lRet:=Val(M->EL_MOEDA)<=nQtMoedas
	Case cCampo=="M->EL_VALOR"
		nPosVal	:= AScan(aCposSEL,"EL_VALOR")
		aCols[n][nPosVal]:=&(cCampo)
	Case cCampo=="M->EL_BANCO"
		nPosBco := AScan(aCposSEL,"EL_BANCO")
		aCols[n][nPosBco] := &(cCampo)

		DbSelectArea("SA6")
		DbSetOrder(1)//"A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON"
		If lBlockBco
			Help(" ",1,"CCBLOCKED")
			lRet := .f.
		Endif

EndCase
If (lRet,FaMoedas(),)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออหออออออออออออหอออออออหออออออออออออออออออออหออออออหอออออออออออออปฑฑ
ฑฑบPrograma  บFa087aLinOk บAutor  บGuilherme C. Leal   บ Data บ  05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออสออออออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDesc.     บ Monta ListBox que contem as taxas das moedas.     			บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosบ lTudo	- Indica se rotina esta sendo chamada pela TUDOOK() บฑฑ
ฑฑบ          บ nLinaCols - Linha do aCols a ser Validada.                   บฑฑ
ฑฑศออออออออออสออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa087aLinOk(lTudo,nLinaCols)

	Local nI			:= 0
	Local lRet			:= .T.
	Local nPosPref		:= 0
	Local nPosNum		:= 0
	Local nPosParc		:= 0
	Local nPosBcoDep	:= 0
	Local nPosAgeDep	:= 0
	Local nPosCtaDep	:= 0
	lOCAL nposTpDoc		:= 0
	Local aCaixaFin		:= xCxFina()
	Local nFormPag 		:= 0
	Local nCerCEP		:= 0
	Local nCadCEP		:= 0
	Local nSelloCEP		:= 0
	Local nCepTip		:= 0
	Local aCmps 		:= {}
	Local nNumC 		:= 0
	Local cCmpsCEP		:= ""
	Local cCom			:=""
	Local nPosSerRet	:= 0
	Local lMuestra		:= .T.
	Local nX			:= 0
	Local nTamACol		:= Len(aCols[n])
	Local nTotCom		:= 0
	Local nTotForPag	:= 0 

	If lTudo
		n := nLinaCols
	Endif

	nPosPref	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_PREFIXO"})
	nPosNum		:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_NUMERO" })
	nPosParc	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_PARCELA"})
	nPosBcoDep	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_BANCO"})
	nPosAgeDep	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_AGENCIA"})
	nPosCtaDep	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_CONTA"})
	nPosTpDoc 	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_TIPODOC"})
	nPosValor 	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_VALOR"})
	nPosMoeda 	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_MOEDA"})
	nPosVencto 	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_DTVCTO"})

	//Usuario nao digita o numero do documento, logo, supoe que nao houve nenhum recebimento e
	//serah feita compensacao de igual valor entre titulos a receber e RAs
	If lTudo .And. !(aCols[n][Len(aCols[n])])
	   If Empty(aCols[n][nPosNum]) .And. !(aCols[n][nPosValor] > 0)
	      aCols[n][Len(aCols[n])]  := .T.
	   EndIf
	EndIf

	IF !(aCols[n][Len(aCols[n])])    // Somente Linhas nใo Deletadas
		For nI:= 1 to Len(aHeader)
			&("M->"+aHeader[nI][2]):=""
			__readvar:="M->"+aHeader[nI][2]
			If !CheckSX3(aHeader[nI][2],aCols[n][nI])
				lRet:=.F.
				Exit
			EndIf
		Next nI
		If lCarga .And. lRet
			lRet:=(Upper(AllTrim(Posicione("DAP",1,xFilial("DAP")+cCarga+cSeqCar+aCols[n][nPosTpDoc],"DAP_CODGRU")))==Upper(AllTrim(aCols[n][nPosTpDoc])))
			If !lRet
				Alert(STR0101)   // Tipo de Valor nใo ingressado na conferencia da carga.
				Return lRet
			EndIf
			Iif(lRet,lRet:=(DAP->DAP_VALPRE+M->EL_VALOR<=DAP->DAP_REALIZ),)
			If !lRet
				Alert(STR0100) // Valor prestado ultrapassa o valor realizado para esta carga.
				Return lRet
			EndIf
		EndIf
		Iif(lRet .And. Val(M->EL_MOEDA)!=1 .And. aTaxa[Val(M->EL_MOEDA)]==0,leTaxa:=.T.,leTaxa:=.F.)
		Iif(lRet,lRet:=M->EL_DTVCTO>=M->EL_EMISSAO,)
		Iif(lRet,oLBMoed:Refresh(),)
		If lRet
			lRet:=Str(AScan(aCols,{|x| x[nPosTpDoc]+x[nPosPref]+x[nPosNum]+x[nPosParc]+Iif(x[len(aCols[n])],".T.",".F.")==aCols[n][nPosTpDoc]+aCols[n][nPosPref]+aCols[n][nPosNum]+aCols[n][nPosParc]+".F."}))$"0|" + Str(n)
			Iif(!lRet,Alert(OemToAnsi(STR0060)),)
		Endif
		//Validar o banco dependendo do tipo de titulo
		If lRet
			DbSelectArea("SA6")
			DbSetOrder(1)
			If aCols[n][nPosTpDoc] $ cCredMed+"/"+cCredInm .and. Subs(aCols[n][nPosTpDoc],1,2) != "EF"
				If Empty(aCols[n][nPosBcoDep]+aCols[n][nPosAgeDep]+aCols[n][nPosCtaDep]) .Or. !DbSeek(xFilial("SA6")+aCols[n][nPosBcoDep]+aCols[n][nPosAgeDep]+aCols[n][nPosCtaDep])
					Help("",1,"FA087BCO")  //"Caja no existente"
					lRet	:=	.F.
				Endif
			ElseIf aCols[n][nPosTpDoc] $ cCredMed+"/"+cCredInm .and. Subs(aCols[n][nPosTpDoc],1,2) == "EF".AND. Empty(aCols[n][nPosBcoDep]+aCols[n][nPosAgeDep]+aCols[n][nPosCtaDep])

				aCols[n][nPosBcoDep] := aCaixaFin[1]
				aCols[n][nPosAgeDep] := aCaixaFin[2]
				aCols[n][nPosCtaDep] := aCaixaFin[3]

			Endif
			If cPaisLoc =="MEX"
				If !(aCols[n][nPosTpDoc] $ "CC|CD")
					lMuestra:= .F.
				ElseIf SAE->(ColumnPos("AE_FINANCI")) > 0
					lMuestra:= F087getFin(aCols[n][nPosTpDoc])
				EndIf
			EndIf
			If lRet .and. (lTudo .and. (nPanel == 1) .and. aCols[n][nPosTpDoc] $ cTiposAdm .And. lMuestra)
				lRet := TelaAdmCar(	aCols[n][nPosPref],aCols[n][nPosNum],;
				        		   	aCols[n][nPosParc],aCols[n][nPosValor],;
				           			Val(aCols[n][nPosMoeda]),n)
			Endif
		Endif

		SE1->(DbSetOrder(1))
		If lRet .And. SE1->(DbSeek(xFilial("SE1")+aCols[n][nPosPref]+aCols[n][nPosNum]+aCols[n][nPosParc]+Padr(aCols[n][nPosTpDoc],TAMSX3("E1_TIPO")[1])))
			MsgAlert(STR0113)  //"Documento para recebimento ja existe. Verifique Tipo do Valor,Prefixo,Numero ou Parcela."
			lRet := .F.
		EndIf
		If cPaisLoc<> "BRA" .And. lRet .And. aCols[n][nPosTpDoc] $ cCredInm .And. aCols[n][nPosVencto] <> dDataBase
			Help(" ",1,"BLOQDTVENC")
			lRet:= .F.
		EndIf
		If lRet
		   lRet := lRetCkPG(0,aCols[n][1],aCols[n][nPosBcoDep],IF(aCols[n][1]$"TF",2,1))
		Endif
	Endif

	If lRet //Solo valide si las demas validaciones estan OK
		If  cPaisLoc == "MEX"
			nFormPag:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_FORPGO"})
			nCepTip:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_CEPTIP"})
			nCerCEP	:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_CEPCER"})
			nCadCEP	:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_CEPCAD"})
			nSelloCEP:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_CEPSEL"})

			If nCepTip > 0 .And. nCerCEP > 0 .And. nCadCEP > 0 .And. nSelloCEP > 0
				If !Empty(aCols[n][nCepTip])
					DbSelectArea("SX3")
					SX3 -> (DBSETORDER(2)) //CAMPO
					AADD(aCmps,{"EL_CEPCER","EL_CEPCA","EL_CEPSEL"})
					For nNumC:= 1 to Len(aCmps[1])
						If SX3->(dbSeek(aCmps[1][nNumC]))
							Iif(Len(aCmps[1]) > nNumC, cCom:=", " , cCom:=" " )
							cCmpsCEP += X3Titulo() + cCom
						Endif
					Next
				 	If Empty(aCols[n][nCerCEP]) .OR. Empty(aCols[n][nCadCEP]) .OR. Empty(aCols[n][nSelloCEP])
				 		Help( ,, STR0149,, STR0212 + alltrim(str(n)) + STR0213 + cCmpsCEP + STR0214 ,1, 0 )//"Atencion" //"En el ํtem " //" el campo Tipo CEP contiene informaci๓n, por lo tanto los campos "//" deben ser informados."
				 		lRet := .F.
				 	EndIf
			 	EndIf
			EndIf

			If lRet .And. lComCart .And. nPanel == 1
				If lRet .And. !Empty(cNoComp) .And. !Empty(dFchComp)
					lRet := F087InfCom(cNoComp, dFchComp)
				EndIf
				If lRet
					nTotCom		:= 0
					nTotForPag	:= 0
					For nX := 1 To Len(aCols)
						If !aCols[nX][nTamACol]
							IIf(aCols[nX][nPosTpDoc] == "CO", nTotCom++, nTotForPag++)
						EndIf
					Next nX
					If IsInCallStack("FA087ATUDOOK")
						If nTotCom == 0 .And. !Empty(cNoComp) .And. !Empty(dFchComp)
							Help(,,STR0149,, STR0272,1,0,,,,,,{STR0273}) //"Se han informado los datos de la Compensaci๓n en encabezado, pero no existe una forma de pago de tipo Compensaci๓n." # "Debe informar una forma de pago de tipo Compensaci๓n."
							lRet := .F.
						EndIf
						If lRet .And. nTotCom > 0 .And. (Empty(cNoComp) .Or. Empty(dFchComp))
							Help(,,STR0149,, STR0275,1,0,,,,,,{STR0276}) //"Se ha informado una forma de pago de tipo Compensaci๓n, pero no existe la informaci๓n de la Compensaci๓n en el encabezado." # "Debe informar en el encabezado la Compensaci๓n."
							lRet := .F.
						EndIf
					EndIf
					If lRet .And. ((nTotCom > 1 .And. nTotForPag == 0) .Or. (nTotCom > 0 .And. nTotForPag > 0))
						Help(,,STR0149,, STR0274,1,0,,,,,,{""}) //"Solo se permite realizar el uso de la Forma de Pago de tipo Compensaci๓n de manera individual."
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
		If cPaisLoc == "PER" .And. SEL->(FieldPos('EL_SERRET')) > 0
			nPosSerRet := AScan(aHeader,{|x|Alltrim(x[2]) == "EL_SERRET"})
			If aCols[n][nPosTpDoc] $ "RI" .And. Empty(aCols[n][nPosSerRet])
		 		Help( ,, STR0149,, STR0212 + alltrim(str(n)) + STR0225 ,1, 0 )//"Atencion" //"En el ํtem " //" el tipo de documento es Retenci๓n IGV, debe informar la serie del certificado de retenci๓n."
				lRet := .F.
			ElseIf !(aCols[n][nPosTpDoc] $ "RI") .And. !Empty(aCols[n][nPosSerRet])
		 		Help( ,, STR0149,, STR0212 + alltrim(str(n)) + STR0226 ,1, 0 )//"Atencion" //"En el ํtem " //" se inform๓ serie de certificado de retenci๓n pero el tipo de documento no es de Retenci๓n IGV."
				lRet := .F.
			Endif
		EndIf
	EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณFa087aTudoOk  บAutor  ณGuilherme C. Leal บ Data ณ05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Faz a validacao de todos os campos.               		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa087aTudoOk(cNumFatAut,lIncAdt)
Local nI			:= 0
Local nX			:= 0
Local lRet			:= .T.
Local lTemReceb		:= .F.
Local cErrMoed		:= ""
Local aArea			:= {}
Local nImpAuto		:= SuperGetMv("MV_CFDREC",.T.,0) //Generacion automatica complemneto de pago

Private leTaxa		:= .F.

DEFAULT cNumFatAut	:= ""
DEFAULT lIncAdt		:= .F. //Angola - Inclusao de Adiantamento

If Empty(cRecibo)
	MsgStop(STR0116)
	lRet:=.F.
	Return (lRet)
EndIf

If Empty(cCliente)
	Help(" ",1,"NUMCLI")
	lRet:=.F.
	Return (lRet)
EndIf

If Empty(cLoja)
	Help(" ",1,"NUMCLI")
	lRet:=.F.
	Return (lRet)
EndIf

If !(dtMovFin(dDataRef,,"2") )      // Verificar data do recibo com o parametro MV_DATAFIN
	lRet:=.F.
	Return (lRet)
EndIf
If Empty(dDataRef)
	MsgStop(STR0099)  //"Data de Emissao Invalida."
	lRet:=.F.
	Return (lRet)
EndIf

If !lIncAdt		//ANGOLA - Nao e inclusao de adiantamento
	If nPanel == 2
		MsAguarde({||RefData(3,cNumFatAut) })
	ElseIf nPanel == 3
	   For nX := 1 to Len(aCols)
	      If !aCols[nX][Len(aCols[nX])]
	         lTemReceb  := .T.
	         Exit
	      EndIf
	   Next nX
	   If !lTemReceb
	      For nX := 1 to Len(aLinMoed)
	         If aLinMoed[nX][4] > 0
	            Alert(STR0114) //"Para compensacoes sem recebimento de titulos, o saldo da operacao deve ser zero!"
	            lRet  := .F.
	            Return(lRet)
	         EndIf
	      Next nX
	      If cPaisLoc == "PER"
		      lRet := Fa087aIGV(cCliente,cLoja,cNumFatAut)
		  EndIf
	  ElseIf cPaisLoc $ "ARG|PER|PAR"
	    	// verifica se ha retencoes (para criar os gets dos valores rateados pelos titulos selecionados)
	 	  	lRet := Fa087aRet()
	  		If !lRet
		 		Return(lRet)
	 	  	Endif
	   EndIf
	   If cPaisLoc == "PER"
	   	lRet := Fa087aIGV(cCliente,cLoja,cNumFatAut)
	   EndIf
	EndIf
Endif

AEval(aLinMoed,{|x,y|If(x[4]<0,cErrMoed+=SuperGetmv("MV_MOEDA"+Alltrim(STR(y)))+", ",) })
cErrMoed:=Alltrim(cErrMoed)
If Len(cErrMoed)>0
	lRet:=.F.
	Alert(STR0050 + Left(cErrMoed,Len(cErrMoed)-1) + STR0051) //"Saldo em "###" insuficiente para efetuar a baixa. "
	Return(lRet)
Endif

If nPanel == 1
	For nI:= 1 to Len(aCols)
		lRet:=Fa087aLinOk(.T.,nI)
		If lRet .And. leTaxa
			Alert(STR0049) //"Informe todas as taxas das moedas que serใo utilizadas nos Documentos."
			lRet:=.F.
			Return(lRet)
		Endif
		If !lRet
			oGetSEL:oBrowse:nAt:=nI
			oGetSEL:oBrowse:Refresh()
			oGetSEL:oBrowse:SetFocus()
			Exit
		Endif
	Next nI

Endif

If cPaisLoc $ "ARG|COS"
	If (nPanel < 5) .And. (nPanel != nlastPan)
		FaMoedas()
	EndIf
Else
	If nPanel <> nlastPan
		FaMoedas()
	EndIf
EndIf

If lRet .And. !Empty(cCobrador)
	aArea:=GetArea()
	DbSelectArea("SAQ")
	DbSetOrder(1)
	If dbSeek(xFilial("SAQ")+cCobrador)
		cTipo:= SAQ->AQ_TIPOREC
	   If cTipo<> "3"
		lRet:= FA087Cob(cTipo)
   	EndIf
   EndIf
   RestArea(aArea)
EndIf
If lRet
	lRet:=IF(cPaisLoc $ "PER|BOL" .AND. AllTrim(cCalcITF) == '1', If(!Empty(cNatureza),CkNatureza(cNatureza,@lNatureza),Eval({||MsgAlert(STR0166,""),.F.})),.T.)
Endif

If lRet .And. ExistBLock('A087TUDOK')
	lRet := ExecBlock('A087TUDOK',.F.,.F.,nPanel)
Endif
If cPaisLoc == "MEX" .And. nPanel == 3 .And. (nImpAuto == 0 .Or. nImpAuto == 1 .Or. nImpAuto == 3 .Or. nImpAuto == 4) .And. lRet //Valida que se encuentre en panel de Seleccion de Documentos y que sea Mexico
	lSolTimCFD := .T.
	lRet := fVldGenCFD()
EndIf

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSELDelLin บAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SELDelLin()

FaMoedas()

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA087aPagtosบAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A087aPagtos(nLin,cNumFatAut)

Local nI			:= 0
Local nPosMoed		:= AScan(aCposSE1,"E1_MOEDA")
Local nPosValor		:= AScan(aCposSE1,"E1_VALOR")
Local aValores		:= Array(8)
Local nPosBaixa		:= Ascan(aCposSE1,"nBaixar")
Local nPosPref		:= Ascan( aCposSE1, "E1_PREFIXO")
Local nPosNum		:= Ascan( aCposSE1, "E1_NUM")
Local nPosParc		:= Ascan( aCposSE1, "E1_PARCELA")
Local nPosTipo		:= Ascan( aCposSE1, "E1_TIPO")
Local nPosCli		:= Ascan( aCposSE1, "E1_CLIENTE")
Local nPosLoja		:= Ascan( aCposSE1, "E1_LOJA")
Local nPosNATU		:= Ascan( aCposSE1, "E1_NATUREZ")
Local nPosOri	    := Ascan( aCposSE1, "E1_ORIGEM")
Local nPosImpRet	:= AScan(aCposSE1,"nImpRetSE1")
Local cCalcITF		:= SuperGetMv("MV_CALCITF",.F.,"2")
Local aConcepto		:= {}
Local cDocRA		:= SubStr(MVRECANT,1,3)
Local lRet			:= .T.
Local aRetMsg		:= {}
Local nQtdDRM		:= 0
Local nQtdDPro		:= 0
Local nQtdDGA		:= 0
Local nQtdDifDGA	:= 0
Local nPJurCalc		:= AScan(aCposSE1,"nJurosCalc")
Local nPMulCalc		:= AScan(aCposSE1,"nMultaCalc")
Local nPDescCalc	:= AScan(aCposSE1,"nDescCalc")
Local nPCompensa	:= AScan(aCposSE1,"nCompensa")

DEFAULT cNumFatAut	:= ""

//Se nao for um registro valido sai
If aLinSE1[oLBSE1:nAT,1]== 0
	Return
EndIf
If cPaisLoc $ "PER|BOL" .and. AllTrim(cCalcITF) == "1"
   If FinProcITF( ,1,,,,,aLinSE1[oLBSE1:nAT,10])
      If !lNatureza
	     MsgAlert(STR0159 + " ["+ cNatureza + "] " + STR0160)
	     Return
      Endif
     Else
      If lNatureza
		 MsgAlert(STR0159 + " [" + cNatureza + "] " + STR0161)
	     Return
      Endif
   EndIf
Endif
//Se esta marcado desmarca
If (aLinSE1[oLBSE1:nAT,1] * -1) != 1
	aLinSE1[oLBSE1:nAt,1] := aLinSE1[oLBSE1:nAT,1] * -1


	aLinSE1[oLBSE1:nAt][nPosDesc] 	:= aLinSE1[oLBSE1:nAt][nPDescCalc]//0
	aLinSE1[oLBSE1:nAt][nPosJuros]	:= aLinSE1[oLBSE1:nAt][nPJurCalc] //0
	//aLinSE1[oLBSE1:nAt][nPosVA]	:=0
	aLinSE1[oLBSE1:nAt][nPosMulta]	:= aLinSE1[oLBSE1:nAt][nPMulCalc] //0

	if nPosImpRet > 0
		aLinSE1[oLBSE1:nAt][nPosImpRet]	:=0
	endif

	If nPCompensa > 0
		// FACTORAJE: Actualizar arreglo de compensaciones referentes a la tabla de movimientos bancarios (SE5)
		aLinSE1[oLBSE1:nAt][nPCompensa]	:= 0
		nI := aScan( aSE5Comp , {|x| x[1]==aLinSE1[oLBSE1:nAt][nPosCli]+aLinSE1[oLBSE1:nAt][nPosLoja]+aLinSE1[oLBSE1:nAt][nPosPref]+aLinSE1[oLBSE1:nAt][nPosNum]+aLinSE1[oLBSE1:nAt][nPosParc]+aLinSE1[oLBSE1:nAt][nPosTipo] } )
		If nI > 0
			aDel( aSE5Comp , nI )
			aSize( aSE5Comp , Len(aSE5Comp)-1 )
		EndIf
	EndIf

	for nI:=1 to nQtMoedas
		&("nPosBx" + Alltrim(Str(nI))) := Ascan(aCposSE1,"nBxMoeda" + Alltrim(Str(nI)))
		aLinSE1[oLBSE1:nAt][&("nPosBx" + Alltrim(Str(nI)))] := 0
	Next nI
	aLinSE1[oLBSE1:nAt][nPosBaixa] := 0
	a087Lock(oLBSE1:nAt,.F.)

	FaMoedas()
	RefData(4,cNumFatAut)
	nValRec:= 0
	Return
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณO titulo que teve seu ajuste de saldo por dif. de cambio nao pode ser baixado emณ
	//ณdata anterior ao ajuste, porque senao o ajuste feito seria sobre o saldo errado ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If cPaisLoc $ "ARG|COS"
		SE1->(MsGoto(aLinSE1[oLBSE1:nAt][Len(aLinSE1[oLBSE1:nAt])-1]))
		If SE1->E1_DTDIFCA>= dDataBase
			Help('',1,'BXDIFCAMB')
			Return
		Endif
    Endif

	If cPaisLoc $ "MEX|PER" .And. X3Usado("ED_OPERADT")

		//----------------------------------------------------------------------------------
		// Nao permite a selecao de titulos tipo RA com opera็ใo de adiantamento habilitada
		//----------------------------------------------------------------------------------
		If aLinSE1[oLBSE1:nAt][nPosTipo] == cDocRA .And. GetAdvFVal("SED","ED_OPERADT",xFilial("SED")+aLinSE1[oLBSE1:nAt][nPosNATU],1,"") == "1"
			MsgAlert(STR0195) //"Nใo ้ possivel selecionar registros de recebimento antecipado que possuam natureza com opera็ใo de adiantamento habilitada."
			Return
		EndIf

		//---------------------------------------------------------------
		// Nao permite a selecao de titulo gerados pelo faturamento com
		// opera็ใo de adiantamento habilitada com outros titulos
		//---------------------------------------------------------------
		nTitSel := AScan(aLinSE1, {|x| x[1] == 1}) //Caso haja registro selecionado obtem a posicao

		If cPaisLoc == "MEX"
			If FWHasEAI("FINA087A",.T.,,.T.) //Valida que rutina se encuentre configurada como adapter para integraci๓n EAI
				If Alltrim(aLinSE1[oLBSE1:nAt][nPosOri]) $ "FINI055|FINI040"
					If !(FA087Integ(.F.))
						Return .F.
					EndIf
				EndIf
				AEval(oLBSE1:aARRAY, {|x,y| If(oLBSE1:aARRAY[y][1] == 1 .And. Alltrim(oLBSE1:aARRAY[y][nPosOri]) $ "FINI055|FINI040", nQtdDRM++,.T.)})  //Qtd de documentos RM seleccionados
				AEval(oLBSE1:aARRAY, {|x,y| If(oLBSE1:aARRAY[y][1] == 1 .And. !(Alltrim(oLBSE1:aARRAY[y][nPosOri]) $ "FINI055|FINI040"), nQtdDPro++,.T.)}) //Qtd de documentos Protheus seleccionados

				If nQtdDRM >= 1 .Or. (Alltrim(aLinSE1[oLBSE1:nAt][nPosOri]) $ "FINI055|FINI040" .And. nQtdDPro > 0)
					MsgAlert(STR0215) //"Para baja de tํtulos generados a partir de rutina FINI055 o FINI040 s๓lo se permite baja uno a uno, verifique seleccionados."
					Return
				EndIf
			EndIf
			//Validaci๓n para los DGA generados de manera directa desde Cuentas por Cobrar (FINA040)
			AEval(oLBSE1:aARRAY, {|x,y| If(oLBSE1:aARRAY[y][1] == 1 .And. Alltrim(oLBSE1:aARRAY[y][nPosOri]) == "FINA040" .And. Alltrim(oLBSE1:aARRAY[y][nPosTipo]) == "DGA", nQtdDGA++,.T.)})  //Qtd de DGA generados desde FINA040 (Cuentas por cobrar)
			AEval(oLBSE1:aARRAY, {|x,y| If(oLBSE1:aARRAY[y][1] == 1 .And. !(Alltrim(oLBSE1:aARRAY[y][nPosOri]) == "FINA040" .And. Alltrim(oLBSE1:aARRAY[y][nPosTipo]) == "DGA"), nQtdDifDGA++,.T.)})

			If (nQtdDGA > 0 .And. !(Alltrim(aLinSE1[oLBSE1:nAt][nPosOri]) == "FINA040" .And. Alltrim(aLinSE1[oLBSE1:nAt][nPosTipo]) == "DGA")) .Or. ;
			   (nQtdDifDGA > 0 .And. (Alltrim(aLinSE1[oLBSE1:nAt][nPosOri]) == "FINA040" .And. Alltrim(aLinSE1[oLBSE1:nAt][nPosTipo]) == "DGA"))
				MsgAlert(STR0248) //"Solo se permite seleccionar titulos de DGA generados a partir de la opci๓n de Cuentas por Cobrar (FINA040)"
				Return
			EndIf
			If lRet .And. !Empty(cNoComp) .And. !Empty(dFchComp)
				MsgAlert(STR0277) //"No se permite realizar la seleccion de tํtulos adicionales para formas de pago de tipo Compensaci๓n."
				Return
			EndIf
		EndIf

		If nTitSel > 0

			If GetAdvFVal("SED","ED_OPERADT",xFilial("SED")+aLinSE1[nTitSel][nPosNATU],1,"") !=;
				GetAdvFVal("SED","ED_OPERADT",xFilial("SED")+aLinSE1[oLBSE1:nAt][nPosNATU],1,"")
				Help(" ",1,"FA087NATTIT")
				Return
			EndIf

		EndIf

	EndIf

Endif

If !a087Lock(oLBSE1:nAt,.T.)
	Return
Endif

//Bloqueia o painel para exibir a tela de pagamentos
oPanel[nPanel]:lReadOnly:= .T.
oPanBut:lReadOnly:=.T.

nValOrig	:= aLinSE1[oLBSE1:nAt][nPosValor]
nTotAbat	:= SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"S",dDataRef)
nParciais:= aLinSE1[oLBSE1:nAt][nPosValor]-SE1->E1_SALDO

If cPaisLoc == "COS"
	If SE1->E1_VALOR == SE1->E1_SALDO
		// 840
		aConcepto := fa087Concept(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,Nil,{"2|3","2",SE1->E1_NATUREZ,SE1->E1_VALOR},,,.T.)
	Else
		aConcepto := fa087Concept(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,Nil,{"2|3","2",SE1->E1_NATUREZ,SE1->E1_SALDO},.T.)
	EndIf

	nRetCfg := 0
	aEval(aConcepto,{|x| nRetCfg += x[5] })
EndIf

nDescont:= aLinSE1[oLBSE1:nAt][nPosDesc]
nJuros	:= aLinSE1[oLBSE1:nAt][nPosJuros]
nMulta	:= aLinSE1[oLBSE1:nAt][nPosMulta]
nVA		:= Iif(lExistVa,aLinSE1[oLBSE1:nAt][nPosVA],0)
nValEstr:= 0
dnCorrec	:= 0
nSaldo	:= SE1->E1_SALDO - nTotAbat - nDescont + nMulta + nJuros - nRetCfg + nVA
nValRec	:= aLinSE1[oLBSE1:nAt][nPosBx] + nMulta - nDescont + nJuros  + nVA
nMotBx  := AScan(aMotBx,{|x| Substr(x,1,3)==aLinSE1[oLBSE1:nAt][nPosMotBx]})
cMotBx  := aDescMotBx[iif(nMotBx>0,nMotBx,1)]
oMotBx:Refresh()

If Empty(SE1->E1_MOEDA) .or. SE1->E1_MOEDA <= 1
	cM:="1"
Else
	cM:=Alltrim(Str(SE1->E1_MOEDA))
Endif
cMoedOri:=SuperGetMv("MV_MOEDA" + cM)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPonto de entrada antes da montagem da tela de baixas,	ณ
//ณpermite que o analista configue os valores para baixa.	ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ExistBlock("FA087ValBX")
	aValores[1] := nDescont
	aValores[2] := nJuros
	aValores[3] := nMulta
	aValores[4] := nValEstr
	aValores[5] := nCorrec
	aValores[6] := nSaldo
	aValores[7] := nValRec
	aValores[8] := Val(cM)
	aValores:=	ExecBlock("FA087ValBX",.F.,.F.,aValores)
	nDescont:=	aValores[1]
	nJuros	:=	aValores[2]
	nMulta	:=	aValores[3]
	nValEstr:=	aValores[4]
	nCorrec	:=	aValores[5]
	nSaldo	:=	aValores[6]-nTotAbat-nRetCfg
	nValRec	:=	aValores[7]
Endif

nI:=1
For nI := 1 To nQtMoedas
	aLinBaixa[nI]:={SuperGetMV("MV_MOEDA"+Alltrim(Str(nI))),aLinSE1[oLBSE1:nAt][anPosMoed[nI]]}
Next nI

//Caso a nValRec esteja zerada ou o valor do campo nBaixar (adicionado atraves da array aCposExtra depois do MontaGrid[2]) estiver zerado
If nValRec == 0 .OR. aLinSE1[oLBSE1:nAt][nPosBx] == 0
	nValRec := nSaldo +nRetCfg
	aLinBaixa[Val(cM)][2]:=nSaldo +nRetCfg
Endif

oLBBaixa:SetArray(aLinBaixa)
oLBBaixa:bLine	:= { || {aLinBaixa[oLBBaixa:nAT][1],;
Transform(aLinBaixa[oLBBaixa:nAT][2],fnPesqPict("SE1","E1_VALOR",18,oLBBaixa:nAT)) }}
oLBBaixa:Refresh()

cPictTit:=fnPesqPict("SE1","E1_VALOR",TamSX3("E1_VALOR")[1],aLinSE1[oLBSE1:nAT][nPosMoed])

oDescont:Picture:=cPictTit
oMulta:Picture:=cPictTit
oJuros:Picture:=cPictTit
oVA:Picture:=cPictTit
oValRec:Picture:=cPictTit
oValOrig:Picture:=cPictTit
oSaldo:Picture:=cPictTit
If oRetCfg != Nil	//protecao para nao ocorrer errorlog em localizacoes diferentes de COS.
	oRetCfg:Picture:=cPictTit
EndIf
oParciais:Picture:=cPictTit

oDescont:Refresh()
oMulta:Refresh()
oJuros:Refresh()
oValRec:Refresh()
oValOrig:Refresh()
oSaldo:Refresh()
oMoedOri:Refresh()
If oRetCfg != Nil	//protecao para nao ocorrer errorlog em localizacoes diferentes de COS.
	oRetCfg:Refresh()
EndIf
oParciais:Refresh()

If cPaisLoc == "MEX"
	If (AllTrim(SE1->E1_ORIGEM) $ "FINI055|FINI040" .And. lRet  .And. SE1->E1_SITUACA == "0")
		If FWHasEAI("FINI087A",.T.,,.T.) //Valida que rutina se encuentre configurada como adapter para integraci๓n EAI
			SE1->(msUnlock())
				SetRotInteg('FINI087A')
				MsgRun ( STR0216 + " " + RTrim(SE1->E1_NUM)+ " " + STR0217,STR0218,{||aRetMsg:=Fini087A()} ) //"Actualizando el titulo" "a valor presente..." "Valor Presente"
				SetRotInteg('FINA087A')
				RecLock("SE1",.F.)
				If ValType(aRetMsg) == "A" .And. Len(aRetMsg) > 0
					If ValType(aRetMSg[1]) <> "U" .and. !aRetMsg[1]
						If ValType (aRetMsg[2]) <> "U" .and. aRetMsg[2] <> Nil .and. !Empty (aRetMsg[2])
							MsgAlert(STR0219 + CRLF+aRetMsg[2]) //"Se realizo un intento de actualizacion del titulo, y devolvio el siguiente mensaje:"
						Else
							MsgAlert(STR0220 + " " + Rtrim(SE1->E1_NUM) + ". " + STR0221) //"Hubo un error inesperado en el intento de actualizacion del titulo " "Verifique las configuraciones de la integraciำn e intente nuevamente."
						EndIf
						lRet := .F.
					ElseIf Valtype (aRetMSg[1]) =="U"
						MsgAlert(STR0220 + " " + Rtrim(SE1->E1_NUM) + ". " + STR0221) //"Hubo un error inesperado en el intento de actualizacion del titulo " "Verifique las configuraciones de la integraciำn e intente nuevamente."
						lRet := .F.
					EndIf
				EndIf
		Else
			lRet := .F.
			MsgAlert(STR0222) //"Para realizar las bajas de integraciones como TIN, es necesario archivar el adapter de la rutina FINI087A - UPDATECONTRACTPARCEL."
		EndIf
	EndIf
EndIf

If lRet
	oPPagto:Show()
EndIf
oLbBaixa:SetFocus()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFAPagtoAtuบAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FAPagtoAtu()
	Local lAplClcAut	:= SuperGetMv("MV_PGOAUTR", .F., .F.)

	nSaldo := SE1->E1_SALDO - nTotAbat - nDescont + nMulta + nJuros - nRetCfg + nVA

	If cPaisLoc == "BRA" .Or. lAplClcAut
		AEval(aLinBaixa,{|x,y| IIf(y == SE1->E1_MOEDA, x[2] := nSaldo + nRetCfg, x[2] := 0)})
	EndIf

	oLBBaixa:bLine := { || {aLinBaixa[oLBBaixa:nAT][1],;
								Transform(aLinBaixa[oLBBaixa:nAT][2],fnPesqPict("SE1","E1_VALOR",18,oLBBaixa:nAT)) }}

	oLBBaixa:Refresh()
	oDescont:Refresh()
	oMulta:Refresh()
	oJuros:Refresh()
	oSaldo:Refresh()

	If cPaisLoc == "BRA" .Or. lAplClcAut
		nValRec := Round(nSaldo + nRetCfg, MsDecimais(SE1->E1_MOEDA))
	EndIf

	oValRec:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDCLBMoed  บAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DCLBMoed(cNumFatAut)
Local nPosCpo
Local nPosCpo1
Local lRet:=.T.
DEFAULT cNumFatAut := ""
If oLBMoed:nAT > 1
	nPosCpo:=Ascan(aCposSE1,"nBxMoeda" + Alltrim(Str(oLBMoed:nAT)))
	nPosCpo1:=Ascan(aCposSE1,"E1_MOEDA")
	AEval(aLinSE1,{|x| If(x[1]==1 .And. (x[nPosCpo1]==oLBMoed:nAT .Or. x[nPosCpo]>0),lRet:=.F.,) })
   If !lRet
		Alert(STR0063)
   Else
		lEditCell(@aLinMoed,oLBMoed,fnPesqPict("SM2","M2_MOEDA"+AllTrim(Str(oLBMoed:nAT)),TamSx3("M2_MOEDA"+AllTrim(Str(oLBMoed:nAT)))[1]),2)
	Endif
Endif
oLBMoed:SetFocus()
FAMoedas()
RefData(4,cNumFatAut)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDCLBBaixa บAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DCLBBaixa()
Local nValSDesc	:= 0
Local nDescFin	:= 0
Local nX		:= 1
Local lAdiant	:= (aLinSE1[oLBSE1:nAt][AScan(aCposSE1,"E1_TIPO")]$MVRECANT+"/"+MV_CRNEG .And. aLinSE1[oLBSE1:nAt][AScan(aCposSE1,"E1_MOEDA")] != oLBBaixa:nAT)
Local bValid	:= { || NIL }
Local nTxAux := 0
Local nValAux := 0
Local nValMon := 0

bValid := {|| a087VerPE(oLBBaixa:nAt,&(ReadVar()) ) }

If !lAdiant
	lEditCell(@aLinBaixa, oLBBaixa, fnPesqPict("SE1","E1_VALOR", TamSx3("E1_VALOR")[1], oLBBaixa:nAt), 2, , , bValid)
EndIf

nValRec := 0

nMoedTit := Iif(Empty(SE1->E1_MOEDA) .or. SE1->E1_MOEDA <= 1, 1, SE1->E1_MOEDA)

For nX := 1 to nQtMoedas
	If aLinMoed[nMoedTit][2] > 0 .And. aLinMoed[nX][2] > 0
		nValRec += aLinBaixa[nX][2] * (aLinMoed[nX][2] / aLinMoed[nMoedTit][2])
		If cPaisLoc == "URU" .And. aLinMoed[nX][2] <> 0
			nTxAux := aLinMoed[nMoedTit][2]
		Endif
	Endif
Next nX

If cPaisLoc == "URU" .And. (nValRec - (nSaldo *nTxAux)) > 0  .And. (nValRec < nSaldo )
	nValAux := (nSaldo / nTxAux )
	nValMon := Round((nValAux * nTxAux),MsDecimais(nMoedTit))
	If nTotal < nValmon
		If nValMon == nSaldo
			nValRec := nValMon
		Endif
	Endif
Endif

nValOri := nValRec

oDescont:Refresh()
oMulta:Refresh()
oJuros:Refresh()
oSaldo:Refresh()
oValRec:Refresh()
If SuperGetMV("MV_DESCFIN",,"I") == "P" //verifica se o desconto financeiro pode ser parcial "P" ou integral "I"
	nDescFin := FaDescFin("SE1", dDataRef, SE1->E1_SALDO, SE1->E1_MOEDA)
	If nDescFin <> 0
		nValSDesc := nValRec / ((100 - SE1->E1_DESCFIN) / 100)
		nDescFin := nDescFin * (nValSDesc / SE1->E1_SALDO)
		nDescont := nDescFin
		oDescont:Refresh()
	Endif
Endif

oLBBaixa:SetFocus()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณFa087aBaixaOKบAutor  ณMicrosiga           บ Data ณ 03/23/11 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fa087aBaixaOK(cNumFatAut)

Local nX			:= 0
Local nPosTpSE1		:= 0
Local lTemReceb		:= .F.
Local nI			:= 0
Local lRet			:= .T.
Local nValorBx		:= 0
Local nCliente		:= 0
Local nLoja			:= 0
Local nDoc			:= 0
Local nSerie		:= 0
Local nTipo			:= 0
Local nOrigem       := 0
Local lCfdi33		:= SuperGetMv("MV_CFDI33",.F.,.F.) .Or. SuperGetMV("MV_CFDI40", .F., .F.) 
Local nPosFil		:= 0
Local nPCompensa	:= AScan(aCposSE1,"nCompensa")

DEFAULT cNumFatAut := ""

F087aMotBx()
cMotBxSE1:=Substr(aMotBx[oMotBx:nAt],01,03)

nI:=0
for nI:=1 to nQtMoedas
	&("nPosBx" + Alltrim(Str(nI))) := Ascan(aCposSE1,"nBxMoeda" + Alltrim(Str(nI)))
Next nI
nPosBx :=	Ascan(aCposSE1,"nBaixar")
nPosTpSE1:=(AScan(aCposSE1,"E1_TIPO"))
nX:=1

//Verifica se tem recebimentos no Panel 1
//Caso nao tenha, avisa ao usuario para selecionar primeiro as NCCs e RAs, pois eh possivel compensar
//os titulos a receber com as RAs de mesmo valor sem a necessidade do recebimento de cheque, dinheiro etc.
For nX := 1 to Len(aCols)
   If !aCols[nX][Len(aCols[nX])]
      lTemReceb  := .T.
      Exit
   EndIf
Next nX

For nX:=1 To nQtMoedas
	If !(aLinSE1[oLBSE1:nAt][nPosTpSE1]$(MVRECANT+"/"+MV_CRNEG) .Or. cMotBxSE1=="DAC") .And. ;
		Round(aLinBaixa[nX][2],MsDecimais(nX)) > IIF(cPaisLoc $ "ARG|COS", (Round(aLinBaixa[nX][2],MsDecimais(nX)) + Round(aLinMoed[nX][4],MsDecimais(nX))), Round(aLinMoed[nX][4],MsDecimais(nX)))
		If lTemReceb
		   Alert(STR0050 + aLinMoed[nX][1] + STR0051) //"Saldo em "###" insuficiente para efetuar a baixa. "
		Else
		   //"Saldo em "###" insuficiente para efetuar a baixa. "
		   //"Como nao foram digitados recebimentos na tela inicial, selecione primeiro os documentos de credito do cliente(NCCs, RAs, etc.)"
		   Alert(STR0050 + aLinMoed[nX][1] + STR0051 + chr(13) + STR0115)
		EndIf
		Return .F.
	Endif
	If aLinBaixa[nX][2]>0 .And. aTaxa[nX]<=0
		Alert(STR0052) //"Informe todas as taxas das moedas que serใo utilizadas nas Baixas."
		Return .F.
	Endif
Next nX

nMoedTit:=Iif(Empty(SE1->E1_MOEDA) .or. SE1->E1_MOEDA <= 1,1,SE1->E1_MOEDA)
nDec:= SuperGetMV("MV_CENT" + Iif(nMoedTit==1,"", Alltrim(Str(nMoedTit)) ) )
If Round(nValRec,nDec)>Round(nSaldo+nRetCfg,nDec)
	Alert(STR0053) //"Valor Recebido nใo pode ser maior que o saldo a receber."
	Return .F.
Endif
If nValRec==0 .And. Ascan(aLinSE1, {|x| x[1] == 1 }) <> 0
	Alert(STR0054) //"Valor Recebido deve ser maior que zero."
	Return .F.
Endif

nCompensa := 0

If cPaisLoc == "MEX" .and. lCfdi33
	nCliente:= (AScan(aCposSE1,"E1_CLIENTE"))
	nLoja	:= (AScan(aCposSE1,"E1_LOJA"))
	nDoc	:= (AScan(aCposSE1,"E1_NUM"))
	nSerie	:= (AScan(aCposSE1,"E1_PREFIXO"))
	nTipo	:= (AScan(aCposSE1,"E1_TIPO"))
	nPosFil	:= AScan(aCposSE1,"E1_FILORIG")
	nOrigem	:= (AScan(aCposSE1,"E1_ORIGEM"))
	lRet	:= GetUUID(alinSE1[oLBSE1:nAt][nCliente], alinSE1[oLBSE1:nAt][nLoja], alinSE1[oLBSE1:nAt][nDoc], alinSE1[oLBSE1:nAt][nTipo], alinSE1[oLBSE1:nAt][nSerie],aLinSE1[oLBSE1:nAt][nPosFil], alinSE1[oLBSE1:nAt][nOrigem])
	If !lRet
		Alert(STR0211) // "El Documento no contiene Timbre Fiscal"
		Return .F.
	EndIf
EndIf

If ExistBlock("F087ABXOK")
	lRet:= ExecBlock("F087ABXOK",.F.,.F.)
EndIf

If lRet
	nX:=1
	For nX:=1 To nQtMoedas
		nBx:=&("nPosBx" + Alltrim(Str(nX)))
		aLinSE1[oLBSE1:nAt][nBx]	:= aLinBaixa[nX][2]
	Next nX

	nValorBx := nValRec-nMulta+nDescont-nJuros - nVA

	aLinSE1[oLBSE1:nAt][nPosDesc]	:= nDescont
	aLinSE1[oLBSE1:nAt][nPosJuros]	:= nJuros
	aLinSE1[oLBSE1:nAt][nPosVA]		:= nVA
	aLinSE1[oLBSE1:nAt][nPosMulta]	:= nMulta
	aLinSE1[oLBSE1:nAt][nPosBx]		:=  nValorBx //nValRec-nMulta+nDescont-nJuros
	aLinSE1[oLBSE1:nAt][nPosMotBx]	:= cMotBxSE1

	if nPosImpRet >0
		aLinSE1[oLBSE1:nAt][nPosImpRet]	:= nRetCfg
	endif

	If nValRec>0
		aLinSE1[oLBSE1:nAt,1] := 1
	Endif

	If nPCompensa > 0 .And. cFactor <> "2"
		// Valor de compensaci๓n entre carteras
		nCompensa := FA087Comp(nCliente, nLoja, nSerie, nDoc)
		aLinSE1[oLBSE1:nAt][nPCompensa]	:= nCompensa
	EndIf
EndIf

oLBSE1:Refresh()
RefData(4,cNumFatAut)
oPanBut:lReadOnly		:=.F.

If Type("oPanel") <> "U"
	oPanel[nPanel]:lReadOnly	:=.F.
EndIf

FaMoedas()
oPPagto:Hide()
oGetSel:oBrowse:SetFocus()

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณFA087aUnlockบAutor  ณMicrosiga           บ Data ณ 03/23/11  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA087aUnlock()
AEval(aRLocks,{|x,y| SE1->(MsRUnlock(x))})
aRLocks:={}
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณFA087aAtuCliบAutor  ณMicrosiga           บ Data ณ  03/23/11 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA087aAtuCli(cNumFatAut,lIncAdt)
DEFAULT cNumFatAut := ""

cNome		:= Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_NOME")
cCGC		:= SA1->A1_CGC
cTel		:= SA1->A1_TEL
cContato	:= SA1->A1_CONTATO
cCliori	:= cCliente
cLojOri	:= cLoja
RefData(2,cNumFatAut,lIncAdt)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณFa087aSalvarบAutor  ณMicrosiga           บ Data ณ  03/23/11 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa087aSalvar(lTela,lGerNCC,cNumFatAut,lIncAdt,aRecAdt)

Local nX			:= 1
Local nY			:= 1
Local nI			:= 1
Local aCposHead		:= {}
Local nTot			:= 0
Local nPosDados		:= 0
Local aSerRec		:= {}
Local cRecAnt		:= cRecibo
Local lOk			:= .T.
Local lExiste		:= .F.
Local nValMoed		:= 1
Local nVlrTit		:= 0
Local nPosTpDoc		:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_TIPODOC"})
Local nPosPrefixo	:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_PREFIXO"})
Local nPosNumero	:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_NUMERO"})
Local nPosParcela	:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_PARCELA"})
Local nPosCred		:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_TPCRED"})
Local nPosVal		:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_VALOR"})
Local nPosBco		:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_BANCO"})
Local nPosTp		:= AScan(aCposSE1,"E1_TIPO")
Local nPosValBx		:= AScan(aCposSE1,"nBaixar")
Local nPosDesc		:= AScan(aCposSE1,"nDescSE1")
Local nPosMoed		:= AScan(aCposSE1,"E1_MOEDA")
Local nPrefixPos	:= 0
Local nNumPos		:= 0
Local nParcelPos	:= 0
Local nTipoPos		:= 0
Local nClientPos	:= 0
Local nLojaPos		:= 0
Local nPosOri		:= AScan(aCposSE1,"E1_ORIGEM")
Local nDesc			:= 0
Local nDescRat		:= 0
Local nDias, dBase,aFeriados
Local nDescoSlv		:= 0
Local nMultaSlv		:= 0
Local nJurosSlv		:= 0
Local nVlLiqSlv		:= 0
Local nValMinRa		:= SuperGetMv("MV_VLMINRA")  // valor minimo para geracao do titulo de credito
Local lExterno		:= .F.
Local cSerieC		:= GETNEWPAR("MV_SERPERC","")
Local aCert			:= {}
Local aConcepto		:= {}
Local nCount		:= 0
Local nTotBx		:= 0
Local nTotRec		:= 0
Local nPosTpSEL		:= 0
Local nPosValSEL	:= 0
Local nPosMoedSEL	:= 0
Local aRecs			:= {}
Local nTotRat		:= 0
Local nDifDesc		:= 0
Local nPosUlt		:= 0
local nColig		:= GetNewPar("MV_RMCOLIG",0) //Verifica se a integra็ใo com o TOP estแ ativa
Local lMsgUnica		:= IsIntegTop()
Local aAreaAux		:= {}
Local cChaveAux		:= ""
Local nVrRetCfg		:= 0
Local aRep			:= {}
Local nImpAuto		:= SuperGetMv("MV_CFDREC",.T.,0) //Generacion automatica complemneto de pago
Local nPosSerRet	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_SERRET"})
Local cIdSEF		:= "" 		//Identificador unico do cheque
Local cProc			:= ""		//Numero do Processo Financeiro
Local aRecOrig		:= {cCliente,;
						cLoja,;
						cSerie,;
						cRecibo,;
						cCobrador,;
						cRecProv,;
						cCliOri,;
						cLojOri}
local cParcTx		:= ""
Local aDadosTit		:= {}
Local nIdxFRMAnt	:= 0
Local aAreaFRMat	:= {}
Local cTpFrmRetn	:= ""
Local cChaveTit		:= ""
Local cChaveFK7		:= ""
Local lCfdi33		:= SuperGetMv("MV_CFDI33",.F.,.F.) .Or. SuperGetMV("MV_CFDI40", .F., .F.)
Local nQtdF055		:= 0
Local nQtdDGA		:= 0
Local nQtdMrk		:= 0
Local nCompenPos	:= 0
Local nPosHora		:= 0
Local aRegPro		:= {}
Local cMotC         := ""
Local lGerComp		:= (cPaisLoc $ "MEX" .And. !Empty(cNoComp) .And. !Empty(dFchComp))

nTotalBx 	:= IIf( Type("nTotalBx")=="U",0,nTotalBx)  // Valor total dos titulos selecionados para baixa

Private aDiario		:= {}
Private aRecnoITF	:= {}
PRIVATE aRatAFT		:= {}
Private aDocument	:= {}
Private cTipDocRA	:= ""
Private nNumSE1		:= 1
Private lTimbraOk	:= .T.	//Valida timbrado desde FISA815
Private lConfTimb	:= .T.	//Valida confirmaci๓n de genraci๓n de Complemento
Private cHora		:= ""
Private lTimVld		:= .T.

DEFAULT lGerNCC		:= .F.
DEFAULT lTela		:=	.T.
DEFAULT cNumFatAut	:= ""
DEFAULT lIncAdt		:= .F.   //Angola
DEFAULT aRecAdt		:= {}

If cPaisLoc == "MEX"
	If nPosOri > 0
		AEval(aLinSE1, {|x,y| If(aLinSE1[y][1] == 1 .And. Alltrim(aLinSE1[y][nPosOri]) $ "FINI055|FINI040", nQtdF055++,.T.)})
		//Validaci๓n para los DGA generados de manera directa desde Cuentas por Cobrar (FINA040)
		AEval(aLinSE1, {|x,y| If(aLinSE1[y][1] == 1 .And. Alltrim(aLinSE1[y][nPosOri]) == "FINA040" .And. Alltrim(aLinSE1[y][nPosTp]) == "DGA", nQtdDGA++,.T.)})  //Qtd de DGA generados desde FINA040 (Cuentas por cobrar)
	EndIF
	AEval(aLinSE1, {|x,y| If(aLinSE1[y][1] == 1, nQtdMrk++,.T.)})  //Cantidad de documentos seleccionados
EndIf

If nPanel != nLastPan
	If Fa087aTudoOk(cNumFatAut,lIncAdt)
		nPanel +=1
		ShowPanel(nPanel, @oPanel,cNumFatAut,lIncAdt)
	EndIf
	Return .F.
EndIf

If cPaisLoc $ "ARG|COS"
	If nPanel == nLastPan
		lTela := .F.

		nPosTpSEL	:= ASCAN(aCposSEL,"EL_TIPODOC")
		nPosValSEL	:= ASCAN(aCposSEL,"EL_VALOR")
		nPosMoedSEL	:= ASCAN(aCposSEL,"EL_MOEDA")

		aLinReceb	:= {}

		aRecs := ACLONE(aCols)
		ASORT(aRecs,,,{|x,y| x[nPosTpSEL] < y[nPosTpSEL]})
		cTipo := Nil
		nX := 1
		For nX := 1 To Len(aRecs)
			If (cTipo != aRecs[nX][nPosTpSEL]) .And. !aRecs[nX][Len(aRecs[nX])]
				AAdd(aLinReceb,{aRecs[nX][nPosTpSEL],0})
				cTipo := aRecs[nX][nPosTpSEL]
			Endif
			If (aRecs[nX][nPosValSEL] != Nil) .And. !aRecs[nX][Len(aRecs[nX])]
				nM := IIf(Empty(aRecs[nX][nPosMoedSEL]) .Or. Val(aRecs[nX][nPosMoedSEL]) <= 1, 1, Val(aRecs[nX][nPosMoedSEL]))
				aLinReceb[Len(aLinReceb)][2] += aRecs[nX][nPosValSEL] * (aTaxa[nM]/aTaxa[oCBMOed:nAt])
			Endif
		Next nX

		AEVAL(aLinBx,	{|x| nTotBx +=x[2]	})
		AEVAL(aLinReceb,{|x| nTotRec += x[2]})

		nTotal:= Round(nTotRec - nTotBx, MsDecimais(oCBMOed:nAt))
	EndIf
	///////////////////////////////////
	// Inicializa integra็ใo com PCO //
	///////////////////////////////////
	PcoIniLan("000361")
Endif

AAdd(aCposHead,{"EL_FILIAL",xFilial("SEL")})
AAdd(aCposHead,{"EL_SERIE",cSerie})
AAdd(aCposHead,{"EL_RECIBO",cRecibo})

AAdd(aCposHead,{"EL_DTDIGIT",dDataBase})

AAdd(aCposHead,{"EL_CANCEL",.F.})
AAdd(aCposHead,{"EL_CLIENTE",cCliente})
AAdd(aCposHead,{"EL_LOJA",cLoja})
AAdd(aCposHead,{"EL_COBRAD",cCobrador})
AAdd(aCposHead,{"EL_RECPROV",cRecProv})
AAdd(aCposHead,{"EL_CLIORIG",cCliOri})
AAdd(aCposHead,{"EL_LOJORIG",cLojOri})

If !(Fa087aTudoOk(cNumFatAut,lIncAdt))
	Return .F.
Endif

If lTela
	Refdata(nPanel,cNumFatAut,lIncAdt)
Endif

//Verificar abatimentos atrav้s das Reten็๕es e validar totais
If lIncAdt .and. (nTotal > 0 .and.( nTotal >= nValMinRa))
	lGerNCC:= .T.
ElseIf !lGerNCC .And. (nTotal > 0 .and.( nTotal >= nValMinRa .or.nTotalBx  ==0 )) .And. !lGerComp
	lGerNCC := MsgYesNo(STR0055 + cDocCred + STR0056, STR0048) //"El valor cancelado es menor que el valor recibido. ฟConfirma la grabacion de una " //"/s del saldo pendiente?" "Saldo"
	If lGerNCC .And. nQtdMrk == 0
		lSolTimCFD := .F.
	EndIf
	If !lGerNCC
		Return .F.
	EndIf
EndIf

If nDescGer >0
	nDesc:=nDescGer*nMoedDesc
	nDescRat:=0
	// Totaliza valor das baixas em moeda 1
	anTotBx:=SomaTitBaixa()
	AEval(anTotBx,{|x,y| nTot += x*aTaxa[y]})
	// Faz rateio do desconto geral, por item.
  	If cPaisLoc == "BRA"
		AEval(aLinSE1,{|x| nDescRat:= iif (x[1]==1 .And. !(x[nPosTp]$MVRECANT+"/"+MV_CRNEG) .And. !(x[nPosMotBx]=="DAC"),((x[nPosValBx]/(nTot/aTaxa[x[nPosMoed]]))*(nDescGer*(aTaxa[nMoedDesc]/aTaxa[x[nPosMoed]]))),0),x[nPosDesc]+=nDescRat,nDesc -= nDescRat*(aTaxa[x[nPosMoed]]/aTaxa[nMoedDesc])})
  	Else
	  	// Tratamento para quando existir rateio e ao calcular o rateio do ultimo titulo o valor rateado nใo seja o valor total do
	  	// desconto informado, neste caso serแ ajustado o valor restante no ultimo titulo.
		For nX:=1 to Len(aLinSE1)
			If aLinSE1[nX][1] == 1 // Se estiver marcado
 				nDescRat:= Round(aLinSe1[nX][nPosValBx]/(nTot/aTaxa[aLinSe1[nX][nPosMoed]]) * (nDescGer*(aTaxa[nMoedDesc]/aTaxa[aLinSe1[nX][nPosMoed]])),MsDecimais(1))
				nTotRat += nDescRat
				aLinSe1[nX][nPosDesc] += nDescRat
				nPosUlt:=nX
			EndIf
		Next nX
		If nDescGer > nTotRat
			nDifDesc := (nDescGer - nTotRat)
			aLinSe1[nPosUlt][nPosDesc] += nDifDesc
		EndIF
	EndIf
Endif
If nPercGer >0
	nDescRat:=0
	// Faz rateio do desconto por item.
	AEval(aLinSE1,{|x| nDescRat:= iif (x[1]==1 .And. !(x[nPosTp]$MVRECANT+"/"+MV_CRNEG) .And. !(x[nPosMotBx]=="DAC"),(nPercGer*x[nPosValBx]*0.01),0),x[nPosDesc]+=nDescRat})
Endif

// verifica se o numero do recibo ja foi utilizado (e nao eh pre-recibo) antes do inicio da transacao de gravacao
lExiste := IIf(SEL->( dbSeek(xFilial("SEL")+cSerie+cRecibo) ) .or. !MayIUseCode( "SEL"+xFilial("SEL")+cSerie+cRecibo ),.T.,.F.)

If lExiste

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe utiliza controle de numeracao sem SERIE, estou utilizando        ณ
	//ณos semaforos, portanto nao posso simplesmente pegar o proximo numeroณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !SuperGetMv('MV_SERREC')
		Help(" ",1,"EXISTNUM")
		Return .F.
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe utiliza controle de numeracao COM SERIE, NAO estou utilizando os ณ
	//ณsemaforos, e sim o SX5, portanto posso pegar o proximo numero disp. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Else
		aSerRec := Fa087Ser(cSerie,cRecibo)
		If Len(aSerRec) > 0
			cSerie  :=aSerRec[1]
			cRecibo :=aSerRec[2]
		Else
			Return .F.
		EndIf

		While  SEL->( dbSeek(xFilial("SEL")+cSerie+cRecibo) )  .Or. !MayIUseCode( "SEL"+xFilial("SEL")+cSerie+cRecibo )
			cRecibo := StrZero(Val(cRecibo)+1,TamSx3("EL_RECIBO")[1])
		EndDo

		If cRecAnt  <> cRecibo
			lOk:= MsgYesNo(OemToAnsi(STR0117) + cRecAnt +OemToAnsi(STR0118) + cRecibo)
			If  (cPaisLoc == "CHI" .OR. cPaisLoc == "PAR" .OR. cPaisLoc == "URU" .OR. cPaisLoc == "BOL") .And. lOk  //Chile, paraguay, uruguay y Bolivia
				If  len(aRecOrig)>0
					aRecOrig[4]:= cRecibo
				Endif
			Endif
		EndIf

		If !lOK
			Return .F.
		EndIf
	Endif
Endif
If UsaSeqCor()
	If !CTBvldDiario(cDiario,dDataBase)
		Return .F.
	Endif
Endif

Begin Transaction

DbSelectArea("SE1")
SE1->(DbSetOrder(1)) //EL_FILIAL+EL_PREFIXO+EL_NUMERO

//ANGOLA - Inclusao de Adiantamento nao tem tela de titulos a baixar
//Logo aLinSE1 nao vai existir para a soma de valores a baixar
aLinSE1 := If(Type("aLinSE1") != "A",{},aLinSE1)
aSort(aLinSE1,,,{|x,y| x[1]>y[1]})
DbSelectArea("SEL")
SEL->(DbSetOrder(8)) //EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
SA1->(DbSeek(xFilial("SA1")+cCliente+cLoja))  // Posiciona SA1
//Verifica se nใo ha linhas repetidas com uma excluida e outra ativa e caso haja modifica para nใo gerar inconsistencia
For nX:=1 to Len(aCols)
	If aCols[nX][Len(aCols[nX])]
		For nY:=1 to Len(aCols)
			If nY==nX .OR. aCols[nY][Len(aCols[nY])]
				Loop
			ElseIf aCols[nX][nPosTpDoc]+aCols[nX][nPosPrefixo]+aCols[nX][nPosNumero]+aCols[nX][nPosParcela]==;
				   aCols[nY][nPosTpDoc]+aCols[nY][nPosPrefixo]+aCols[nY][nPosNumero]+aCols[nY][nPosParcela]
					AAdd(aRep,{aCols[nX][nPosNumero],nX}) //"Vlr. Baixa"
					aCols[nX][nPosNumero] :=PADR(" ",TamSX3("EL_NUMERO")[1])
					Exit
			Endif
		Next nY
	Endif
Next nX

//Gerar o n๚mero do processo do Recibo
cProc := FINFKSID('FKA','FKA_IDPROC')
nPosHora := AScan(aCposSEL,"EL_HORA")
If nPosHora > 0
	cHora := SubStr(GetRmtTime(),1,8)
	aCols[n][nPosHora]:= cHora
EndIf
For nX:=1 to Len(aCols)
	nPosDados:=0
	If	SEL->(DbSeek(xFilial("SEL")+cSerie+cRecibo+aCols[nX][nPosTpDoc]+aCols[nX][nPosPrefixo]+;
		aCols[nX][nPosNumero]+aCols[nX][nPosParcela]))
		RecLock("SEL",.F.)
		If aCols[nX][Len(aCols[nX])]
			DbDelete()
		Else
			nI:=1
			AEval(aCposHead,{|x,y| If(FieldPos(x[1])>0,FieldPut(FieldPos(ALLTRIM(x[1])),x[2]),)})
			FaGrv(aCposSEL,aCols[nX])
			If aCols[nX][nPosTpDoc] $ cTiposAdm
				nPosDados := aScan(aDadosAdm,{|x| x[5]==nX})
				If nPosDados >0
					SEL->EL_CLIENTE := aDadosAdm[nPosDados][01]
					SEL->EL_LOJA    := aDadosAdm[nPosDados][02]
					SEL->EL_TIPODOC := aDadosAdm[nPosDados][04]
				EndIF
			EndIf
			SEL->EL_VLMOED1	:=Round( SEL->EL_VALOR*aTaxa[Val(SEL->EL_MOEDA)], MsDecimais(1) )
			If !(cPaisLoc $ "ARG|COS")
				SEL->EL_TIPO	:=SEL->EL_TIPODOC
			EndIf
			IF !Empty(cNatureza)
				SEL->EL_NATUREZ	:= cNatureza
			Endif
			If cPaisLoc=="BRA" .And. Alltrim(SEL->EL_TIPODOC) == "CH"
				SEL->EL_NATUREZ	:= Iif( Empty(SA1->A1_NATUREZ), &(SuperGetMV("MV_1DUPNAT")) , SA1->A1_NATUREZ )
			EndIF
			F087AGrvTx( aTaxa )
			If lFactor
				SEL->EL_FACTOR := cFactor
			EndIf
		EndIf
		MsUnlock()
	Else
		If aCols[nX][Len(aCols[nX])]
			Loop
		Endif
		RecLock("SEL",.T.)
		nI:=1
		AEval(aCposHead,{|x,y| If(FieldPos(x[1])>0,FieldPut(FieldPos(ALLTRIM(x[1])),x[2]),)})
		FaGrv(aCposSEL,aCols[nX])
		If aCols[nX][nPosTpDoc] $ cTiposAdm
			nPosDados := aScan(aDadosAdm,{|x| x[5]==nX}) 
			If nPosDados > 0
				SEL->EL_CLIENTE := aDadosAdm[nPosDados][01]
				SEL->EL_LOJA    := aDadosAdm[nPosDados][02]
				SEL->EL_TIPODOC := aDadosAdm[nPosDados][04]
			EndIf
			If aCols[nX][nPosTpDoc] $ "CC|CD" .AND. cPaisLoc == 'BRA'
				SEL->EL_TIPODOC := aCols[nX][nPosTpDoc]
			EndIf
		EndIf
		SEL->EL_VLMOED1:= Round( SEL->EL_VALOR*aTaxa[Val(SEL->EL_MOEDA)] , MsDecimais(1))
		If !(cPaisLoc $ "ARG|COS")			
			SEL->EL_TIPO	:=SEL->EL_TIPODOC
		EndIf
		SEL->EL_RECIBO	:= cRecibo
		If cPaisLoc == "MEX"
			If SEL->(ColumnPos("EL_SERSUS")) > 0
				SEL->EL_SERSUS  := cSerieS
			EndIf
			If SEL->(ColumnPos("EL_RECSUS")) > 0
				SEL->EL_RECSUS  := cReciboS
			EndIf
			If lComCart
				SEL->EL_IDENTEE := cNoComp
				SEL->EL_FCHIDEN := dFchComp
			EndIf
		EndIf
		IF !Empty(cNatureza)
			SEL->EL_NATUREZ  	:= cNatureza
		Endif
		If cPaisLoc=="BRA" .And. Alltrim(SEL->EL_TIPODOC) == "CH"
			SEL->EL_NATUREZ:= Iif( Empty(SA1->A1_NATUREZ), &(SuperGetMV("MV_1DUPNAT")) , SA1->A1_NATUREZ )
		EndIF

		F087AGrvTx( aTaxa )

		If lFactor
			// Factoraje?
			SEL->EL_FACTOR := cFactor
		EndIf

		MsUnlock()

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Grava็ใo das Reten็๕es de IVA,Rentas ou ISRL - Equador                ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If cPaisLoc $ "EQU"

			If AllTrim(aCols[nX][nPosTpDoc]) $ "RI|RR"

				aConcepto := fa087Concept(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,aCols[nX][nPosTpDoc])
				// Grava Reten็ใo
	 			For nCount := 1 To Len(aConcepto)
		 			RecLock("SFE",.T.)
		    		FE_FILIAL   := xFilial("SFE")
					FE_NROCERT	:= SEL->EL_NUMERO
					FE_EMISSAO  := dDataRef
					FE_CLIENTE  := cCliente
					FE_LOJCLI 	:= cLoja
					FE_TIPO   	:= Subs(aCols[nX][nPosTpDoc],2,1)
					FE_RECIBO   := cRecibo
					FE_NFISCAL  := SE1->E1_NUM
					FE_SERIE    := SE1->E1_PREFIXO
					FE_CONCEPT 	:= aConcepto[nCount][1]
					FE_VALBASE	:= aConcepto[nCount][3]
					FE_ALIQ		:= aConcepto[nCount][4]
					FE_VALIMP	:= aConcepto[nCount][5]
					FE_TES		:= aConcepto[nCount][6]
					If aCols[nX][nPosVal] <> aConcepto[nCount][5]
						FE_RETENC	:= aConcepto[nCount][5]
					Else
						FE_RETENC	:= aCols[nX][nPosVal]
					EndIf
					If SFE->(FieldPos("FE_NUMAUT")) > 0 .and. SEL->(FieldPos("EL_UUID")) > 0
						FE_NUMAUT  := SEL->EL_UUID
					EndIf
					If SFE->(FieldPos("FE_TPCALR")) > 0 .and. SEL->(FieldPos("EL_PROVIN")) > 0
						FE_TPCALR  := SEL->EL_PROVIN
					Endif
					If SFE->(FieldPos("FE_RET_MUN")) > 0 .and. SEL->(FieldPos("EL_RET_MUN")) > 0
						FE_RET_MUN := SEL->EL_RET_MUN
					EndIf
					FE_ESPECIE	:= SF2->F2_ESPECIE
					dbSelectArea("SFB")
					SFB->(DbSetOrder(1))
					If SFB->(DbSeek(xFilial("SFB")+AvKey(aConcepto[nCount][2],"FB_CODIGO")))
						FE_CODRET := SFB->FB_CODRET
					Endif
					MsUnLock()
				Next nCount

			EndIf
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Grava็ใo da tabela de Cheques - Controle de Cheques - Equador.                ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If cPaisLoc $ "EQU|DOM|COS" .AND. SEL->EL_TIPODOC=="CH"
			cIdSEF := FWUUIDV4()
			nDias:=Val(SEL->EL_ACREBAN)
			dBase:=SEL->EL_DTVCTO
        	aFeriados:=RetFeriados()
        	While nDias > 0
           	dBase++
           	If Ascan(aFeriados,Dtos(dBase)) == 0 .And. Dow(dBase) <> 1 .And. Dow(dBase) <> 7
           		nDias--
           	EndIf
        	EndDo
		  	RecLock("SEF", .T.)
			Replace SEF->EF_FILIAL		WITH xFilial("SEF")
			Replace SEF->EF_BANCO		WITH SEL->EL_BCOCHQ
			Replace SEF->EF_AGENCIA		WITH SEL->EL_AGECHQ
			Replace SEF->EF_CONTA		WITH SEL->EL_CTACHQ
			Replace SEF->EF_NUM			WITH SEL->EL_NUMERO
			Replace SEF->EF_VALOR		WITH SEL->EL_VALOR
			Replace SEF->EF_DATA		WITH dDatabase
			Replace SEF->EF_VENCTO		WITH dBase //Clearing
			Replace SEF->EF_BENEF		WITH SM0->M0_NOMECOM
			Replace SEF->EF_CART		WITH "R"
			Replace SEF->EF_LA			WITH "S"
			Replace SEF->EF_LIBER		WITH "S"
			Replace SEF->EF_SEQUENC 	WITH "01"
			Replace SEF->EF_TEL			WITH SA1->A1_TEL
			Replace SEF->EF_PREFIXO		WITH SEL->EL_PREFIXO
			Replace SEF->EF_TITULO		WITH SEL->EL_RECIBO
			Replace SEF->EF_TIPO		WITH SEL->EL_TIPODOC
			Replace SEF->EF_PARCELA		WITH SEL->EL_PARCELA
			Replace SEF->EF_CLIENTE		WITH SEL->EL_CLIENTE
			Replace SEF->EF_LOJACLI		WITH SEL->EL_LOJA
			Replace SEF->EF_TERCEIR		WITH .F.
			Replace SEF->EF_EMITENT		WITH SA1->A1_NOME
			Replace SEF->EF_CPFCNPJ		WITH SA1->A1_CGC
			Replace SEF->EF_HIST    	WITH "Recibo "+SEL->EL_RECIBO
			Replace SEF->EF_ORIGEM		WITH "FINA087A"
			Replace SEF->EF_STATUS  	WITH "01" //Carteira
			Replace SEF->EF_PORTADO  	WITH SEL->EL_BANCO
			Replace SEF->EF_IDSEF 		WITH cIdSEF //Identificador Unico do Titulo
			SEF->(MSUnlock())
		Endif
	EndIf
	If lCarga .And. DAP->((Upper(AllTrim(Posicione("DAP",1,xFilial("DAP")+cCarga+cSeqCar+aCols[nX][nPosTpDoc],"DAP_CODGRU")))==Upper(Alltrim(aCols[nX][nPosTpDoc]))))
		RecLock("DAP",.F.)
		DAP->DAP_VALPRE:=DAP->DAP_VALPRE+SEL->EL_VALOR
		DAP->DAP_RECIBO:=cRecibo
		MsUnlock()
	EndIf
	If aCols[nX][nPosTpDoc] $ cCredMed

		//+------------------------------------------------------------------------------+
		//ฆ Gerar registro no SE1 se sao cheques ou pagtos sem movimenta็ใo imediata.    ฆ
		//+------------------------------------------------------------------------------+
		SE1->(DbSetOrder(2))
		If SE1->(DbSeek(xFilial("SE1")+cCliente+cLoja+SEL->EL_PREFIXO+SEL->EL_NUMERO+;
			SEL->EL_PARCELA+SEL->EL_TIPODOC))
			RecLock("SE1",.F.)
		Else
			RecLock("SE1",.T.)
		Endif
		SE1->E1_FILIAL := xFilial("SE1")
		SE1->E1_FILORIG := cFilant
		SE1->E1_SERREC := SEL->EL_SERIE
		SE1->E1_RECIBO := SEL->EL_RECIBO
		SE1->E1_PREFIXO:= SEL->EL_PREFIXO
		SE1->E1_NUM    := SEL->EL_NUMERO
		SE1->E1_PARCELA:= SEL->EL_PARCELA
		SE1->E1_TIPO   := SEL->EL_TIPODOC
		SE1->E1_PORTADO:= SEL->EL_BANCO
		SE1->E1_AGEDEP := SEL->EL_AGENCIA
		SE1->E1_CONTA  := SEL->EL_CONTA
		SE1->E1_BCOCHQ := SEL->EL_BCOCHQ
		SE1->E1_AGECHQ := SEL->EL_AGECHQ
		SE1->E1_CTACHQ := SEL->EL_CTACHQ
		SE1->E1_EMISSAO:= SEL->EL_EMISSAO   //dDataRef
		SE1->E1_EMIS1  := CtoD("")
		SE1->E1_VENCREA:= DATAVALIDA(SEL->EL_DTVCTO)
		SE1->E1_VENCTO := SEL->EL_DTVCTO
		SE1->E1_VENCORI:= SEL->EL_DTVCTO
		SE1->E1_NATUREZ:= SEL->EL_NATUREZ
		SE1->E1_MOEDA  := Val(SEL->EL_MOEDA)
		SE1->E1_CLIENTE:= SEL->EL_CLIENTE
		SE1->E1_LOJA   := SEL->EL_LOJA
		SE1->E1_VALOR  := SEL->EL_VALOR
		SE1->E1_SALDO  := SEL->EL_VALOR
		If ( cPaisLoc == "CHI" )
			SE1->E1_VLCRUZ := Round( SEL->EL_VALOR*aTaxa[SE1->E1_MOEDA], MsDecimais(1) )
		Else
			SE1->E1_VLCRUZ := SEL->EL_VALOR*aTaxa[SE1->E1_MOEDA]
		Endif
		SE1->E1_NOMCLI := Iif(nPosDados>0,aDadosAdm[nPosDados,3],SA1->A1_NOME)
		SE1->E1_EMIS1  := dDataBase
		SE1->E1_TXMOEDA:= aTaxa[SE1->E1_MOEDA]
		If cPaisLoc <> "BOL"
			If aCols[nX][nPosCred]$"1|2"
				SE1->E1_BAIXA 		  :=If(aCols[nX][nPosCred]=="1",dDatabase,DataValida(SEL->EL_DTVCTO))
				SE1->E1_LA          :='S'
				SE1->E1_MOTIVO      :=""
				SE1->E1_MOVIMEN     :=SE1->E1_BAIXA
				SE1->E1_SALDO       :=0
				SE1->E1_DESCONT     :=0
				SE1->E1_MULTA       :=0
				SE1->E1_JUROS       :=0
				SE1->E1_VALLIQ      :=SEL->EL_VALOR
				SE1->E1_SERREC      :=cSerie
				SE1->E1_RECIBO      :=cRecibo
				SE1->E1_DTACRED     :=SE1->E1_BAIXA
			EndIf
		EndIf

		//+--------------------------------------------------------------------------------+
		//ฆSi no se ingreso el banco o se ingreso en una caja, SITUACA es 0 (en cartera)   ฆ
		//+--------------------------------------------------------------------------------+
		If (Empty(SEL->EL_BANCO).And.Empty(SEL->EL_CONTA).And.Empty(SEL->EL_AGENCIA)).Or.;
			(SEL->EL_BANCO $ (GetNewPar("MV_CARTEIR","")+"/"+Left(GetNewPar("MV_CXFIN",""),TamSX3("A6_COD")[1])))
			SE1->E1_SITUACA:= "0"
		ElseIf SEL->EL_BANCO $ (GetNewPar("MV_CARTEIR","")+"/"+Left(GetNewPar("MV_CXFIN",""),TamSX3("A6_COD")[1]))
			SE1->E1_SITUACA:= "0"
		Else
			SE1->E1_SITUACA:= "1"
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCalculo para o tempo de Clearing, o tempo de Clearing estaณ
		//ณsendo calculado somente com dias uteis corridos.          ณ
		//ณSe o Tempo for de mais de uma semana, coloco uma data de  ณ
		//ณaqui a dez anos assim tem que ser acreditado manualmente. ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		If aCols[nX][nPosCred] == "1"
			SE1->E1_DTACRED:=dDatabase
		ElseIf aCols[nX][nPosCred] == "2"
			SE1->E1_DTACRED:=DataValida(SEL->EL_DTVCTO)
		ElseIf aCols[nX][nPosCred] == "3"
			nDias:=Val(SEL->EL_ACREBAN)
			dBase:=  SE1->E1_VENCREA
			If nDias > 5
           	dBase += 3650
        	Else
          	aFeriados:=RetFeriados()
           	While nDias > 0
              	dBase++
              	If Ascan(aFeriados,Dtos(dBase)) == 0 .And. Dow(dBase) <> 1 .And. Dow(dBase) <> 7
              		nDias--
              	EndIf
           	EndDo
        	Endif
        	SE1->E1_DTACRED:= dBase
     	EndIf
		SE1->E1_ORIGEM := "FINA087A"
		If ( cPaisLoc == "CHI" )
			SE1->E1_VLCRUZ := Round( SEL->EL_VLMOED1, MsDecimais(1) )
		Else
			SE1->E1_VLCRUZ := SEL->EL_VLMOED1
		Endif
		SE1->E1_LA     := "S"
		SE1->E1_STATUS := IF(SE1->E1_SALDO<=0,"B","A")
		SE1->E1_MOVIMEN:= SE1->E1_DTACRED
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณIntegracao com SigaLoja que grava o numero da NF no campo ณ
		//ณE1_NUM. Apos a emissao da NF, a referencia passa a ser o  ณ
		//ณnumero do cheque - Loc. Paraguai                          ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If cPaisLoc == "PAR" .And. ColumnPos("E1_NUMCHQ") > 0
           If AllTrim(SEL->EL_TIPODOC) == "CH"
		      SE1->E1_NUMCHQ := SE1->E1_NUM
           EndIf
		EndIf
		MsUnLock()
		FKCOMMIT()
		If SE1->E1_SITUACA=="1"
			SEA->(DbSetOrder(1))
			If SEA->(DbSeek(xFilial("SEA")+SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA))
				RecLock("SEA",.F.)
				SEA->EA_DATABOR := SEL->EL_DTVCTO
				SEA->EA_PORTADO := SEL->EL_BANCO
				SEA->EA_AGEDEP  := SEL->EL_AGENCIA
				SEA->EA_NUMCON  := SEL->EL_CONTA
				SEA->EA_TIPO    := SEL->EL_TIPODOC
				SEA->EA_CART    := "R"
				SEA->EA_SITUACA := "1"
				SEA->EA_FILORIG := SE1->E1_FILIAL
				MsUnlock()
				FKCOMMIT()
			Else
				If ! Empty(SEL->EL_BANCO)
					RecLock("SEA",.T.)
					SEA->EA_FILIAL  := xFilial("SEA")
					SEA->EA_DATABOR := SEL->EL_DTVCTO
					SEA->EA_PORTADO := SEL->EL_BANCO
					SEA->EA_AGEDEP  := SEL->EL_AGENCIA
					SEA->EA_NUMCON  := SEL->EL_CONTA
					SEA->EA_NUM     := SEL->EL_NUMERO
					SEA->EA_PARCELA := SEL->EL_PARCELA
					SEA->EA_PREFIXO := SEL->EL_PREFIXO
					SEA->EA_TIPO    := SEL->EL_TIPODOC
					SEA->EA_CART    := "R"
					SEA->EA_SITUACA := "1"
					SEA->EA_FILORIG := SE1->E1_FILIAL
					MsUnlock()
					FKCOMMIT()
				EndIf
			EndIf
		EndIf
	 	If !aCols[nX][nPosCred]$"1|2"
			AtuSalDup("+",SE1->E1_VALOR,SE1->E1_MOEDA,SE1->E1_TIPO,aTaxa[SE1->E1_MOEDA],SE1->E1_EMISSAO)
		EndIf
	Endif
	If aCols[nX][nPosCred] $ "1|2" .Or. aCols[nX][nPosTpDoc] $ cCredInm
		If !(cPaisLoc == 'BRA' .AND. aCols[nX][nPosCred] == '3' .AND. aCols[nX][nPosTpDoc] == 'CC')
			//Valida a grava็ใo do modelo de baixa ou movimento bancแrio.
			If !FaGrvSE5(2,aCols[nX][nPosCred],cNatureza,cProc)
				DisarmTransaction()
				Return .F.
			EndIf
			If cPaisLoc <> "BRA"
				If FinProcITF( SE5->(Recno()),1,,,,,cNatureza ) .AND. lRetCkPG(3,,aCols[nX][nPosBco])
					FinProcITF( SE5->(Recno()),3,SE5->E5_VALOR, .F.,,,cNatureza,@aRecnoITF)
				EndIf
			EndIf	
		EndIf
	EndIf
	If ExistBlock("FA087INC")
		ExecBlock("FA087INC",.F.,.F.)
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCalculo da Comissao do Cobrador caso o mesmo seja informado no Recibo e grava no ณ
	//ณarquivo SEX                                                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(cCobrador)
   	Fa087Com()
	EndIf
Next nX

For nX:=1 to Len(aRep)
	aCols[aRep[nX][2]][nPosNumero]:=aRep[nX][1]
Next nX

nX:=1

If !lIncAdt

	nPrefixPos  := AScan(aCposSE1,"E1_PREFIXO")
	nNumPos     := AScan(aCposSE1,"E1_NUM")
	nParcelPos  := AScan(aCposSE1,"E1_PARCELA")
	nTipoPos    := AScan(aCposSE1,"E1_TIPO")
	nClientPos  := AScan(aCposSE1,"E1_CLIENTE")
	nLojaPos    := AScan(aCposSE1,"E1_LOJA")
	nCompenPos  := AScan(aCposSE1,"nCompensa")

	SE1->(DbSetOrder(1))	//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	aSort(aLinSE1,,,{|x,y| x[1]>y[1]})	// Organiza aLinSE1 para que os marcados venham primeiro.
	For nX:=1 to Len(aLinSE1)
		If aLinSE1[nX][1]!=1
			Exit
		Else
			AADD(aDocument,{aLinSE1[nX][nPrefixPos]+aLinSE1[nX][nNumPos]+aLinSE1[nX][nParcelPos]+;
			                 aLinSE1[nX][nTipoPos]+aLinSE1[nX][nClientPos]+aLinSE1[nX][nLojaPos],+;
			                 aLinSE1[nX][nTipoPos],aLinSE1[nX][nNumPos],IIF( ALLTRIM (aLinSE1[nX][nTipoPos]) $ "RA|NCC",.F.,.T.)})
			If ALLTRIM (aLinSE1[nX][nTipoPos]) $ "RA|NCC"
				cTipDocRA += ALLTRIM(aLinSE1[nX][nTipoPos])+"|"
			EndIf
		Endif
	Next nX
	aSort(aDocument,,,{|x,y| x[2] $ cTipDocRA})

	For nX:=1 to Len(aLinSE1)
		If aLinSE1[nX][1]!=1
			Exit
		Endif

		SE1->(MsGoto(aLinSE1[nX][Len(aLinSE1[nX])-1]))

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Caso a Natureza do titulo for de adiatamento ED_OPERADT = 1    ณ
		//ณ gera o titulo do tipo "RA" com base no titulo de adiantamento. ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If cPaisLoc $ "MEX|PER" .And. X3Usado("ED_OPERADT")
			If GetAdvFVal("SED","ED_OPERADT",xFilial("SED")+SE1->E1_NATUREZ,1,"") == "1" .Or. (cPaisLoc $ "MEX" .And. Alltrim(aLinSE1[nX][nTipoPos]) == "DGA")
				Fa087aNFRA(aLinSE1[nX][nPosValBx])
			EndIf
		EndIf

		nVrRetCfg := 0
		If cPaisLoc == "COS" .And. SE1->E1_SALDO == SE1->E1_VALOR
			aAreaAux := {	SE1->(GetArea()),;
							SFE->(GetArea()),;
							GetArea()         }
			aConcepto := {}
			aConcepto := fa087Concept(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,Nil,{"2|3","2",SE1->E1_NATUREZ,SE1->E1_VALOR})

			//-- Grava Reten็ใo
 			For nCount := 1 To Len(aConcepto)
 				nVrRetCfg += aConcepto[nCount][5]
 	 			RecLock("SFE",.T.)
	    		FE_FILIAL   := xFilial("SFE")
				FE_EMISSAO  := dDataRef
				FE_CLIENTE  := SE1->E1_CLIENTE
				FE_LOJCLI 	:= SE1->E1_LOJA
				FE_TIPO   	:= "R"
				FE_RECIBO   := cRecibo
				FE_NFISCAL  := SE1->E1_NUM
				FE_SERIE    := SE1->E1_PREFIXO
				FE_PARCELA	:= SE1->E1_PARCELA
				FE_CONCEPT 	:= aConcepto[nCount][1]
				FE_VALBASE	:= aConcepto[nCount][3]
				FE_ALIQ		:= aConcepto[nCount][4]
				FE_VALIMP	:= aConcepto[nCount][5]
				FE_TES		:= aConcepto[nCount][6]
				FE_RETENC	:= aConcepto[nCount][5]

				FRM->(DbSetOrder(2)) //-- FRM_FILIAL+FRM_COD+FRM_SEQ+FRM_CARTEI
				If FRM->(MsSeek(xFilial("FRM") + aConcepto[nCount][7] + StrZero(0,Len(FRM_SEQ))))
					SFE->FE_SIGLA    := FRM->FRM_SIGLA
					SFE->FE_TPTIMP   := FRM->FRM_TPABT
					SFE->FE_TPTPAI   := SE1->E1_TIPO
					SFE->(MsUnLock())

					cChaveAux := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA)
					fGerAbatCR(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA, SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,SFE->FE_VALIMP, "R",FRM->FRM_TPABT)

					//-- Baixa o Tํtulo de Reten็ใo de Impostos
					SE1->(DbSetOrder(1)) //-- E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
					If SE1->(MsSeek(xFilial("SE1")+cChaveAux+FRM->FRM_TPABT))
						RecLock("SE1",.F.)
						SE1->E1_SALDO   := 0
						SE1->E1_BAIXA   := dDataBase
						SE1->E1_MOVIMEN := dDataBase
						SE1->(MsUnLock())
					EndIf
				Else
					SFE->(MsUnLock())
				EndIf

				aEval(aAreaAux, {|xArea| RestArea(xArea) })
			Next nCount
		ElseIf cPaisLoc == "COS" .And. !(SE1->E1_SALDO == SE1->E1_VALOR)

			aAreaAux := {	SE1->(GetArea()),;
							SFE->(GetArea()),;
							GetArea()         }
			aConcepto := {}
			aConcepto := fa087Concept(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,nil,{"2|3","2",SE1->E1_NATUREZ,SE1->E1_SALDO})

			//Guarda dados do titulo principal
			aDadosTit := {SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, SE1->E1_CLIENTE,;
			SE1->E1_LOJA, SE1->E1_VALOR, SE1->E1_VENCTO, SE1->E1_HIST, SE1->E1_EMISSAO, SE1->E1_MOEDA,;
			SE1->E1_FILORIG, SE1->E1_NOMCLI, SE1->E1_SITUACA, SE1->E1_STATUS, SE1->E1_FLUXO, SE1->E1_TIPODES,;
			SE1->E1_MULTNAT, SE1->E1_DESDOBR, SE1->E1_SCORGP, SE1->E1_TPDESC, SE1->E1_APLVLMN }

			//-- Grava Reten็ใo
 			For nCount := 1 To Len(aConcepto)

				//Verifica se jแ existe o tํtulo, e vai trocando a parcela
				cParcTx := aDadosTit[3]
				SE1->(dbSetOrder(1))
				cTpFrmRetn := FRM->FRM_TPABT

				//Necessแrio posicionar o tipo certo antes de procurar a parcela, quando existe mais de uma reten็ใo no documento
				If Len(aConcepto) > 1
					nIdxFRMAnt := FRM->(IndexOrd())
					aAreaFRMat := FRM->(GetArea())
					If FRM->(MsSeek(xFilial("FRM") + aConcepto[nCount][7] + StrZero(0,Len(FRM_SEQ))))
						cTpFrmRetn := FRM->FRM_TPABT
					EndIf
					FRM->(DbSetOrder(nIdxFRMAnt))
					RestArea(aAreaFRMat)
				EndIf

				While SE1->(dbSeek(xFilial("SE1")+aDadosTit[1]+aDadosTit[2]+cParcTx+cTpFrmRetn+aDadosTit[6]+aDadosTit[7]))
					cParcTx := Soma1(cParcTx)
				EndDo

 				nVrRetCfg += aConcepto[nCount][5]
 	 			RecLock("SFE",.T.)
	    		FE_FILIAL  := xFilial("SFE")
				FE_EMISSAO := dDataRef
				FE_CLIENTE := aDadosTit[6]
				FE_LOJCLI  := aDadosTit[7]
				FE_TIPO    := "R"
				FE_RECIBO  := cRecibo
				FE_NFISCAL := aDadosTit[2]
				FE_SERIE   := aDadosTit[1]
				FE_PARCELA := cParcTx
				FE_CONCEPT := aConcepto[nCount][1]
				FE_VALBASE := aConcepto[nCount][3]
				FE_ALIQ    := aConcepto[nCount][4]
				FE_VALIMP  := aConcepto[nCount][5]
				FE_TES     := aConcepto[nCount][6]
				FE_RETENC  := aConcepto[nCount][5]

				FRM->(DbSetOrder(2)) //-- FRM_FILIAL+FRM_COD+FRM_SEQ+FRM_CARTEI
				If FRM->(MsSeek(xFilial("FRM") + aConcepto[nCount][7] + StrZero(0,Len(FRM_SEQ))))
					SFE->FE_SIGLA  := FRM->FRM_SIGLA
					SFE->FE_TPTIMP := FRM->FRM_TPABT
					SFE->FE_TPTPAI := aDadosTit[4]
					SFE->(MsUnLock())
					//
					RecLock("SE1",.T.)
					E1_FILIAL  := xFilial("SE1")
					E1_PREFIXO := aDadosTit[1]
					E1_NUM     := aDadosTit[2]
					E1_PARCELA :=	cParcTx
				  	E1_TIPO    :=	FRM->FRM_TPABT
					E1_CLIENTE := aDadosTit[6]
					E1_LOJA    := aDadosTit[7]
					E1_VALOR   := SFE->FE_VALIMP
					E1_VLCRUZ  := SFE->FE_VALIMP
					E1_NATUREZ := aDadosTit[5]
					E1_EMISSAO := aDadosTit[11]
					E1_VENCTO  := aDadosTit[09]
					E1_VENCREA := DataValida(aDadosTit[09],.T.)
					E1_VENCORI := DataValida(aDadosTit[09],.T.)
					E1_EMIS1   := dDataBase
					E1_MOEDA   := aDadosTit[12]
					E1_HIST    := "ABATIMIENTO DE RETENCION"
					E1_ORIGEM  := "FINA087A"
					E1_TITPAI  := aDadosTit[1]+aDadosTit[2]+aDadosTit[3]+aDadosTit[4]+aDadosTit[6]+aDadosTit[7]
					E1_FILORIG := aDadosTit[13]
					E1_NOMCLI  := aDadosTit[14]
					E1_SITUACA := aDadosTit[15]
					E1_STATUS  := aDadosTit[16]
					E1_FLUXO   := aDadosTit[17]
					E1_TIPODES := aDadosTit[18]
					E1_MULTNAT := aDadosTit[19]
					E1_DESDOBR := aDadosTit[20]
					E1_SCORGP  := aDadosTit[21]
					E1_TPDESC  := aDadosTit[22]
					E1_APLVLMN := aDadosTit[23]
					SE1->(MsUnLock())

					//-- Baixa o Tํtulo de Reten็ใo de Impostos
					SE1->(DbSetOrder(1)) //-- E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
					If SE1->(MsSeek(xFilial("SE1")+aDadosTit[1]+aDadosTit[2]+cParcTx+FRM->FRM_TPABT))
						RecLock("SE1",.F.)
						SE1->E1_SALDO   := 0
						SE1->E1_BAIXA   := dDataBase
						SE1->E1_MOVIMEN := dDataBase
						SE1->(MsUnLock())
					EndIf
				Else
					SFE->(MsUnLock())
				EndIf

				aEval(aAreaAux, {|xArea| RestArea(xArea) })
			Next nCount
		EndIf

		RecLock("SE1",.F.)
		SE1->E1_BAIXA 	:=	dDataRef
		SE1->E1_MOTIVO	:=aLinSE1[nX][nPosMotBx]
		SE1->E1_MOVIMEN	:=dDataRef
		SE1->E1_SALDO	:=SE1->E1_SALDO - aLinSE1[nX][nPosValBx]
		nDescoSlv	:= SE1->E1_DESCONT
		nMultaSlv	:= SE1->E1_MULTA
		nJurosSlv	:= SE1->E1_JUROS
		nVlLiqSlv	:= SE1->E1_VALLIQ
		SE1->E1_DESCONT	:=aLinSE1[nX][nPosDesc]
		SE1->E1_MULTA		:=aLinSE1[nX][nPosMulta]
		SE1->E1_JUROS		:=aLinSE1[nX][nPosJuros]
		SE1->E1_VALLIQ	:=aLinSE1[nX][nPosValBx]-aLinSE1[nX][nPosDesc]+aLinSE1[nX][nPosJuros]+aLinSE1[nX][nPosMulta]+aLinSE1[nX][nPosVA]
		SE1->E1_SERREC   :=cSerie
		SE1->E1_RECIBO	:=cRecibo
		SE1->E1_DTACRED	:=dDataRef
		SE1->E1_STATUS	:= IF(SE1->E1_SALDO<=0,"B","A")
		//+--------------------------------------------------------------+
		//ฆ Baixar titulos de abatimento se for baixa total              ฆ
		//+--------------------------------------------------------------+
		IF SE1->E1_SALDO > 0 .And. SE1->E1_SALDO == nTotAbat .And. !(SE1->E1_TIPO$ MV_CPNEG)

			E1_SALDO := 0
		    E1_STATUS 	:= "B"
			cTitulo  := xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA
			aAreaSE1 := GetArea()
			SE1->(DbSetOrder(1))

			If DbSeek(cTitulo )
				While !SE1->(EOF()) .And. xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA==cTitulo
					If SE1->E1_TIPO $ MVABATIM
						RecLock("SE1",.F.)
						Replace E1_SALDO    With 0
						Replace E1_BAIXA    With dDataBase
						Replace E1_MOVIMEN  With dDataBase
						SE1->(MsUnLock())
					EndIf
					dbSkip()
				Enddo
			EndIf
			RestArea(aAreaSE1)
	    EndIf
		MsUnlock()

		//Valida a grava็ใo dos movimentos com uso do modelo de baixa ou movimento bancแrio.
		If !FaGrvSE5(1,,,cProc,nX)
			DisarmTransaction()
			Return .F.
		EndIf

		DbSelectArea("SEL")
		RecLock("SEL",.T.)
		EL_FILIAL   := xFilial("SEL") //SE1->E1_FILIAL
		EL_TIPODOC  := "TB"
		EL_PREFIXO  := SE1->E1_PREFIXO
		EL_NUMERO   := SE1->E1_NUM
		EL_PARCELA  := SE1->E1_PARCELA
		EL_TIPO   	:= SE1->E1_TIPO
		EL_BCOCHQ 	:= SE1->E1_BCOCHQ
		EL_AGECHQ   := SE1->E1_AGECHQ
		EL_CTACHQ   := SE1->E1_CTACHQ
		EL_EMISSAO  := SE1->E1_EMISSAO

		SEL->EL_DTDIGIT	:= dDataBase
		IIf(SEL->(ColumnPos("EL_HORA")) > 0,SEL->EL_HORA := cHora,"")

		EL_DTVCTO   := SE1->E1_VENCREA
		EL_NATUREZ  := SE1->E1_NATUREZ
		EL_MOEDA    := STRZERO(SE1->E1_MOEDA,2)
		EL_VLMOED1 	:= Round((SE1->E1_VALLIQ)*aTaxa[Max(1,SE1->E1_MOEDA)],MsDecimais(1))
		EL_DESCONT  := SE1->E1_DESCONT
   		EL_MULTA    := SE1->E1_MULTA
   		EL_JUROS    := SE1->E1_JUROS
		EL_VALOR    := SE1->E1_VALLIQ
		EL_CLIENTE 	:= cCliOri
		EL_LOJA	 	:= cLojOri
		EL_SERIE    := cSerie
		EL_RECIBO 	:= cRecibo
		EL_COBRAD	:= cCobrador
		EL_RECPROV	:= cRecProv
		EL_CLIORIG	:= SE1->E1_CLIENTE
		EL_LOJORIG	:= SE1->E1_LOJA
		If cPaisLoc == "MEX" .And. SEL->(ColumnPos("EL_SERSUS")) > 0
			EL_SERSUS   := cSerieS
		EndIf
		If cPaisLoc == "MEX" .And. SEL->(ColumnPos("EL_RECSUS")) > 0
			EL_RECSUS   := cReciboS
		EndIf

		If lFactor
			// Actualiza registros de documentos cobrados con marca si es factoraje y valor de compensaci๓n entre carteras que se haya encontrado
			// Se utiliza para nodo en el CFDI con complemento de recibo electr๓nico de pago
			EL_FACTOR := cFactor
			EL_COMPEN := aLinSE1[nX][nCompenPos]
		EndIf

		F087AGrvTx( aTaxa )
		MsUnlock()

		If cPaisLoc $ "ARG|COS"
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Grava os lancamentos nas contas orcamentarias SIGAPCO    ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			PcoDetLan("000361","06","FINA087A") // Cobran็as diversas - Transferencia Bancaria
		Endif

		SE1->(MsGoto(aLinSE1[nX][Len(aLinSE1[nX])-1]))
		RecLock("SE1",.F.)
		E1_DESCONT	+= nDescoSlv
		E1_MULTA	+= nMultaSlv
		E1_JUROS	+= nJurosSlv

		SE1->(MsUnlock())
		/*Atualiza o status do titulo no SERASA */
		If cPaisLoc == "BRA"
			If SE1->E1_SALDO <= 0
				cChaveTit := xFilial("SE1") + "|" +;
							SE1->E1_PREFIXO + "|" +;
							SE1->E1_NUM		+ "|" +;
							SE1->E1_PARCELA + "|" +;
							SE1->E1_TIPO	+ "|" +;
							SE1->E1_CLIENTE + "|" +;
							SE1->E1_LOJA
				cChaveFK7 := FINGRVFK7("SE1",cChaveTit)
				F770BxRen("1",TrazCodMot(cMotBx),cChaveFK7)
			Endif
		ElseIf cPaisloc=="MEX"
			Fa087GrvIVA()
			If lFactor
				// Actualiza registros de compensaci๓n entre carteras correspondientes a la NF
				FA087SE5( nX )
			EndIf
		Endif

		If ExistBlock("FA087BAIXA")
			ExecBlock("FA087BAIXA",.F.,.F.)
		Endif

		If cPaisLoc == "MEX" .And. nQtdF055 > 0
			If FWHasEAI("FINA087A",.T.,,.T.) //Valida que rutina se encuentre configurada como adapter para integraci๓n EAI
				cIntegSeq := SE5->E5_SEQ //utilizada na integdef. Nao transformar em local.
				INCLUI := .T.
				ALTERA := .T.
				aRetInteg := FwIntegDef( 'FINA087A' )
				//Se der erro no envio da integra็ใo, entใo faz rollback e apresenta mensagem em tela para o usuแrio
				If ValType(aRetInteg) == "A" .AND. Len(aRetInteg) >= 2 .AND. !aRetInteg[1]
					If ! IsBlind()
						Help( ,, "FINA087INTEG",, STR0220 + ": " + STR0223 + " - " + AllTrim( aRetInteg[2] ), 1, 0,,,,,, {STR0221} ) //"Hubo un error inesperado en el intento de actualizacion del titulo " "Baja de titulos" "Verifique las configuraciones de la integracion e intente nuevamente."
					EndIf
					DisarmTransaction()
					Return .F.
				EndIf
			EndIf
		EndIf
	Next nX
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Faz as gravacoes dos titulos que tem retencoes no SFE		 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If cPaisLoc = "PER" .And. Len(aCols) > 0
	DbSelectArea("SFE")
	For nI:= 1 to Len(aCols)
		If (aCols[nI][nPosTpDoc] $ "RI")
			SE1->(DbSetorder(1))
			For nX := 1 to Len(aLinRet)
				For nY := 1 to Len( aLinRet[nX])
					If aLinRet[nX][nY][7] == aCols[nI][nPosTpDoc]
						If (aLinRet[nX][nY][5] > 0) .And. ;
				  	       (SE1->( DbSeek(xFilial("SE1")+aLinRet[nX][nY][1]+aLinRet[nX][nY][2]+aLinRet[nX][nY][3]+aLinRet[nX][nY][4]) ))
					 		RecLock("SFE",.T.)
							FE_FILIAL   := xFilial('SFE')
							FE_NROCERT	:= aLinRet[nX][nY][6]
							FE_EMISSAO  := dDataRef
							FE_CLIENTE  := cCliente
							FE_LOJCLI 	:= cLoja
							FE_TIPO   	:= Subs( aLinRet[nX][nY][7] ,2 ,1) // I
							FE_RECIBO   := cRecibo
							FE_NFISCAL  := SE1->E1_NUM
							FE_SERIE    := SE1->E1_SERIE
							FE_RETENC 	:= aLinRet[nX][nY][5]
							FE_ESPECIE  := aLinRet[nX][nY][4]
							FE_SERIE2   := aCols[nI][nPosSerRet]
							MsUnlock()
						EndIf
					Endif
				Next nY
			Next nX
		EndIf
	Next nI
ElseIf cPaisLoc = "PAR" .And. Len(aCols) > 0
	DbSelectArea("SFE")
	For nI:= 1 to Len(aCols)
		If (aCols[nI][nPosTpDoc] $ "RI|RR")
			SE1->(DbSetorder(1))
			For nX := 1 to Len(aLinRet)
				For nY := 1 to Len( aLinRet[nX])
						If (aLinRet[nX][nY][4] > 0) .AND. aLinRet[nX][nY][6] == aCols[nI][nPosTpDoc]
					 		RecLock("SFE",.T.)
					 		FE_TIPO   	:= Iif(aLinRet[nX][nY][6]=="RI","I","R")
							FE_FILIAL   := xFilial('SE1')
							FE_EMISSAO  := dDataRef
							FE_CLIENTE  := cCliente
							FE_LOJCLI 	:= cLoja
							FE_RECIBO   := cRecibo
							FE_NFISCAL  := SE1->E1_NUM
							FE_SERIE    := SE1->E1_SERIE
							FE_RETENC 	:= aLinRet[nX][nY][4]
							FE_VALBASE  := aLinRet[nX][nY][2]
							FE_ALIQ	    := aLinRet[nX][nY][3]
							If SFE->(ColumnPos("FE_CFO")) > 0
								FE_CFO		:= aLinRet[nX][nY][1]
							EndIf
							FE_NROCERT  := aLinRet[nX][nY][5]
							MsUnlock()
						EndIf
					//Endif
				Next nY
			Next nX
		EndIf
	Next nI
EndIf

If cPaisLoc=="PER" .And. Len(aPerc) > 0
	cCert:= GetCertPer("P",cCliente+cLoja+"P")
	AADD(aCert,{cCert,cSerieC})
	nItem:=0
	For nX:= 1 to Len(aPerc)
		nItem+=1
		If nItem > nItensC  //  Gera novo numero de certificado de acordo com quantidade de itens no recibo
 			cCert:= GetCertPer("P",cCliente+cLoja+"P")
 			AADD(aCert,{cCert,cSerieC})
  			nItem:= 0
		EndIf
		RecLock("SFE",.T.)
		FE_FILIAL   := xFilial('SFE')
		FE_NROCERT	:= cCert
		FE_SERIEC	:= cSerieC
		FE_EMISSAO  := dDataRef
		FE_CLIENTE  := cCliente
		FE_LOJCLI 	:= cLoja
		FE_TIPO   	:= "P"
		FE_RECIBO   := cRecibo
		FE_NFISCAL  := Iif(aPerc[nX][8],cRecibo,aPerc[nX][4])
		FE_SERIE    := aPerc[nX][5]
		FE_VALIMP 	:= Round(xMoeda(aPerc[nX][1],nMoedDesc,1,3,,aTaxa[nMoedDesc]),2)//aPerc[nX][1]
		FE_VALBASE 	:= Round(xMoeda(aPerc[nX][3],nMoedDesc,1,3,,aTaxa[nMoedDesc]),2)//aPerc[nX][3]
		FE_ALIQ 	:= aPerc[nX][2]
		FE_ITEM		:= nItem
		FE_ESPECIE 	:= aPerc[nX][7]
		MsUnlock()
	Next
EndIf

If lGerNCC
	lGerNCC	:=.F.
	cParc	:= " "

	While SE1->(DbSeek(xFilial("SE1")+"REC"+Padr(cRecibo,TamSx3("E1_NUM")[1]," ")+Padr(cParc,TamSx3("E1_PARCELA")[1]," ")+cDocCred))
		cParc:=Soma1(cParc)
	Enddo

	For nValMoed := 1 to Len(aLinMoed)
		If cPaisLoc $ "EQU|PER" .And. lTitAd
			nValimp:= (nValPerc*(aTaxa[oCBMoed:nAt]/aTaxa[nValMoed])*(1))
			nVlrTit:= aLinMoed[nValMoed,4] - nValimp
		Else
			nVlrTit	:= aLinMoed[nValMoed,4]
		EndIf
		If nVlrTit > 0
			//-- Registro no SEL
			RecLock("SEL",.T.)
			SEL->EL_FILIAL		:= xFilial("SEL")
			SEL->EL_TIPODOC 	:= "RA"
			SEL->EL_PREFIXO  	:= "REC"
			SEL->EL_NUMERO   	:= cRecibo
			SEL->EL_PARCELA  	:= cParc
			SEL->EL_TIPO   	 	:= cDocCred
			SEL->EL_EMISSAO  	:= dDataRef

			SEL->EL_DTDIGIT	:= dDataBase

			SEL->EL_DTVCTO   	:= dDataRef
			If cPAISLOC $ "PER|COS"
				IF Empty(cNatureza)
					SEL->EL_NATUREZ  	:= Iif( Empty(SA1->A1_NATUREZ), &(SuperGetMV("MV_1DUPNAT")) , SA1->A1_NATUREZ )
				Else
					SEL->EL_NATUREZ  	:= cNatureza
				Endif
			Else
				SEL->EL_NATUREZ  	:= Iif( Empty(SA1->A1_NATUREZ), &(SuperGetMV("MV_1DUPNAT")) , SA1->A1_NATUREZ )
			EndIf
			SEL->EL_MOEDA    	:= StrZero(nValMoed,2)//Aqui representa qual e a moeda
			SEL->EL_VLMOED1  	:= Round( nVlrTit*aTaxa[nValMoed], MsDecimais(1))
			SEL->EL_VALOR    	:= nVlrTit
			SEL->EL_CLIENTE  	:= aRecOrig[01]
			SEL->EL_LOJA	 	:= aRecOrig[02]
			SEL->EL_SERIE 	 	:= aRecOrig[03]
			SEL->EL_RECIBO 	 	:= aRecOrig[04]
			SEL->EL_COBRAD		:= aRecOrig[05]
			SEL->EL_RECPROV		:= aRecOrig[06]
			SEL->EL_CLIORIG		:= aRecOrig[07]
			SEL->EL_LOJORIG		:= aRecOrig[08]
			F087AGrvTx( aTaxa )

			MsUnlock()

			If cPaisLoc $ "ARG|COS"
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Grava os lancamentos nas contas orcamentarias SIGAPCO    ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				PcoDetLan("000361","02","FINA087A") // "Cobran็as diversas - Recebimento Antecipado"
			Endif
			//-- Registro no SE1
			RecLock("SE1",.T.)
			SE1->E1_FILIAL   	:= xFILIAL("SE1")
			SE1->E1_FILORIG     := cFilAnt
			SE1->E1_PREFIXO  	:= "REC"
			SE1->E1_NUM			:= cRecibo
			SE1->E1_PARCELA		:= cParc
			SE1->E1_TIPO     	:= cDocCred
			SE1->E1_EMISSAO  	:= dDataRef
			SE1->E1_EMIS1    	:= dDataBase
			SE1->E1_VENCTO  	:= dDataRef
			SE1->E1_VENCREA 	:= DataValida(dDataRef)
			SE1->E1_NATUREZ  	:= SEL->EL_NATUREZ
			SE1->E1_MOEDA   	:= nValMoed
			If ( cPaisLoc == "CHI" )
				SE1->E1_VLCRUZ	:= Round( nVlrTit*aTaxa[nValMoed], MsDecimais(1) )
			Else
				SE1->E1_VLCRUZ	:= nVlrTit*aTaxa[nValMoed]
			Endif
			SE1->E1_VALOR   	:= nVlrTit
			If cPaisLoc $ "EQU|PER" .And. lTitAd
				SE1->E1_SALDO   := nVlrTit  - nValimp //actualizar valor del anticipo
			Else
				SE1->E1_SALDO   := nVlrTit
			EndIF
			SE1->E1_CLIENTE 	:= aRecOrig[01]
			SE1->E1_LOJA    	:= aRecOrig[02]
			SE1->E1_SERREC      := aRecOrig[03]
			SE1->E1_RECIBO  	:= aRecOrig[04]
			SE1->E1_NOMCLI   	:= SA1->A1_NOME
			SE1->E1_SITUACA  	:= "0"
			SE1->E1_ORIGEM   	:= "FINA087A"
			SE1->E1_LA       	:= "S"
			SE1->E1_STATUS   	:= "A"
			SE1->E1_TXMOEDA		:= aTaxa[nValMoed]
			If cPaisLoc == "CHI"
				SE1->E1_CGC			:= SA1->A1_CGC
			Endif
			//integra็ใo Protheus Argentina X TOP
			If !lMsgUnica
				If nColig >0 .and. IntePms().and. MsgYesNo (OemToAnsi(STR0192)+" "+"("+cDocCred+")"+" ";
				 +AllTrim(SE1->E1_NUM)+" " +OemToAnsi(STR0193)+" " +SuperGetMV("MV_SIMB1")+" " + AllTrim(Transform(SE1->E1_VLCRUZ,fnPesqPict("SE1","E1_VLCRUZ")))+" " +OemToAnsi(STR0194))//"Voc๊ deseja associar o tํtulo" "de valor" "a um projeto?"
					 PmsFi087a()
				Endif
			Endif
			MsUnlock()

			aadd(aRecAdt,{SE1->(RECNO()),SE1->E1_VALOR}) //Controle de inclusใo de adiantamentos

			AtuSalDup("-",SE1->E1_VALOR,SE1->E1_MOEDA,SE1->E1_TIPO,aTaxa[SE1->E1_MOEDA],SE1->E1_EMISSAO)
			cParc := Soma1(cParc)//Atualiza a proxima parcela

		EndIf
	Next nValMoed
EndIf

If !SuperGetMV('MV_SERREC')
	If  __lSX8
		While ( GetSX8Len() > nSaveSx8 )
			ConfirmSX8()
		End
	Endif
Else
	//Grava Nr do proximo Recibo da tabela RN no SX5.
	DbSelectArea("SX5")
	DbSetOrder(1)
	If DbSeek( xFilial("SX5")+"RN"+cSerie )
		//Verifica se nao foi atualizado com um numero de recibo mais novo (outra estacao)
		If X5_DESCRI <  StrZero((Val(cRecibo)+1),TamSX3("EL_RECIBO")[1])
			RecLock("SX5",.F.)
			Replace X5_DESCRI  With StrZero((Val(cRecibo)+1),TamSX3("EL_RECIBO")[1])
			Replace X5_DESCENG With StrZero((Val(cRecibo)+1),TamSX3("EL_RECIBO")[1])
			Replace X5_DESCSPA With StrZero((Val(cRecibo)+1),TamSX3("EL_RECIBO")[1])
			MsUnlock()
		Endif
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPonto de entrada depois da grava็ใo de TODOS os arquivos ณ
//ณe antes da contabilidade                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ExistBlock("FA087GRV")
	ExecBlock("FA087GRV",.F.,.F.)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualiza o cadastro de Recibo x Cobradores			    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nRecnoSEY>0
	SEY->(dbGoto(nRecnoSEY))
	RecLock("SEY")
	SEY->EY_RECPEND:=SEY->EY_RECPEND -1
	If SEY->EY_RECPEND<=0
  		SEY->EY_STATUS:="2"
 	EndIf
	SEY->(MsUnlock())
EndIf
lCancel := .F.

//ANGOLA - Inclusao de Adiantamento nao necessita calculo de diferenca de cambio
If !lIncAdt
	//Gera diferen็a de cambio automatica apos a grava็ใo do recebimento diversos
	aSort(aLinSE1,,,{|x,y| x[1]>y[1]})			// Organiza aLinSE1 para que os marcados venham primeiro.
	If lGeraDCam .And. cPaisLoc$"ARG|COS|URU" .And. lTemMon // verifica se a moeda eh maior que 1 e se irแ gerar diferen็a automatica
		DbSelectArea("SE1")
		For nI:=1 to Len(aLinSE1)
			If aLinSE1[nI][1]!=1
				Exit
			Endif
			cPrefixo := aLinSE1[nI][2]
			cNum := aLinSE1[nI][3]
			cParcela := aLinSE1[nI][4]
			cMoeda := aLinSE1[nI][7]
			SE1->(dbSetOrder(1))
			SE1->(dbSeek(xFilial("SE1")+cPrefixo+cNum+cParcela))
		  	If xFilial()==SE1->E1_FILIAL .And. cNum==SE1->E1_NUM .AND. cPrefixo==SE1->E1_PREFIXO .AND. SE1->(!EOF())
				lExterno:=.T.
				lExecCor:=.T.
				nPosIni:=1
				While lExecCor
					Pergunte("FIN74A",.F.)
					MV_PAR01:=0    // taxa

					MV_PAR07:=2                       // Gera para   saldo
					MV_PAR08:=1                         // Gera para pago
					aArea:=GetArea()
				  If!Empty(nMoedaCor:=Val(Subs(SuperGetMV("MV_MDCFIN"),nPosIni,2)))
						If !Empty(SuperGetMV("MV_MOEDA"+Alltrim(Str(nMoedaCor))))
							MV_PAR10:=nMoedaCor
							cMoeda := aLinSE1[nI][7]
							nTxaAtual:= aTaxa[nMoedaCor]
							nMdaTit=aTaxa[cmoeda]
							FA074GDif(.F.,,,lExterno)
						EndIf
				  		nPosIni:=nPosIni+3
				  		RestArea(aArea)
				 	Else
					 	lExecCor:=.F.
				 	EndIf
		      EndDo
			EndIf
		Next nI
	EndIf
Endif

If cPaisLoc == "PER" .And. Len(aCert) > 0
   	If MV_PAR07 == 1
		For nI:=1 to Len(aCert)
		  		bBlock := &("{||"+Alltrim(mv_par08)+"(aCert[nI][1],aCert[nI][2],.T.)"+"}")
		  		Eval(bBLock)
		Next nI
	EndIf
EndIf

If cPaisLoc $ "MEX/COL/PER/EQU" .And. VldLibMet() //Valida el uso de m้tricas
	F87AMetAvg(aHeader, aCols) //Se detona m้trica de Tipo Average
Endif

dbCommit()
ConfirmSX8()

End Transaction
//Libera codigo usado pela MayIUseCode
FreeUsedCode()
//Destrava os registros que tenham ficado travados
FA087aUnlock()

//Ponto de entrada ap๓s a grava็ใo da tabela SEL
If ExistBlock("FA087SEL")
	ExecBlock("FA087SEL",.F.,.F.)
Endif

If cPaisLoc == "MEX" .and. lCfdi33 .And. nQtdF055 == 0 .And. nQtdDGA == 0
	If lSolTimCFD .And. (nImpAuto == 0 .Or. nImpAuto == 1 .Or. nImpAuto == 3 .Or. nImpAuto == 4)
		If nImpAuto == 0 .Or. nImpAuto == 3
			lConfTimb := MSGYESNO( STR0210, STR0209 ) //"ฟDesea realizar el Complemento de Recepci๓n de Pago?" - "Complemento de Recepci๓n de Pagos"
		EndIf
		If lConfTimb
			If FindFunction("F815VldTim") .And. SEL->(ColumnPos("EL_HORA")) > 0
				aAdd(aRegPro,{cRecibo,cSerie,dDataBase,cHora})
				lTimVld := F815VldTim(aRegPro)
			EndIf

			If lTimVld
				cMotC := F087ObtMot(cSerieS,cReciboS)
				FISA815(cRecibo,cSerie,,,,,cSerieS,cReciboS,cMotC)
			EndIf
		EndIf
	EndIf

	If !lSolTimCFD //marcara el documento, para que no genere CFD.
		DBSelectArea("SEL")
		SEL->(DBSetOrder(8)) //EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
		If SEL->(MSSeek(xFilial("SEL") + cSerie + cRecibo))
			While !(SEL->(EOF())) .And. SEL->(EL_FILIAL + EL_SERIE + EL_RECIBO ) == xFilial("SEL") + cSerie + cRecibo
				RecLock("SEL", .F.)
				SEL->EL_GENCFD := "N"
				SEL->(MSUnlock())
				SEL->(DbSkip())
			EndDo

		EndIf
	EndIf

EndIf

//Contabiliza
Fa087Cont()

If cPaisLoc $ "ARG|COS"
	////////////////////////////////////////
	// Finaliza integra็ใo com M๓dulo PCO //
	////////////////////////////////////////
	PcoFinLan("000361")
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFaGrv     บAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FaGrv(aCampos,aLinha)
AEval(aCampos,{|x,y| If(FieldPos(x)>0,FieldPut(FieldPos(ALLTRIM(x)),aLinha[y]),)})
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFaGrvSE5  บAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FaGrvSE5(nTipo,cTpCred,cNatureza,cProc,nPosLin)
Local lAdiantamento:=.F.
Local nTxMoeda := 0
Local nMoedaF := 1
Local lGrvMov := .T.
/*
 * Reestrutura das tabelas do processo de movimento bancแrio
 */
Local oModelMov	:= FWLoadModel("FINM030") //Model de Mov. Bco.
Local oSubFKA		:= Nil	//RELACIONAMENTO
Local oSubFK5		:= Nil //MOVTO BANCARIO
Local oSubFK6     := Nil //MOVTO acessoorios
Local cFilSE5		:= FWxFilial("SE5")
Local cCamposE5	:= ""
Local cIdFK5		:= ""
Local cLog			:= ""
Local nTamHist    := TamSX3("FK5_HISTOR")[1]
Local cHistMov    	:= ""
Local lRet			:= .T. //Valida็ใo do Modelo
Local aAlt := {}
Local cFilFK6		:= FWxFilial("FK6")
Local cIdFK2		:= ''

Local nPJurCalc	:= AScan(aCposSE1,"nJurosCalc")
Local nPMulCalc	:= AScan(aCposSE1,"nMultaCalc")
Local nPDescCalc:= AScan(aCposSE1,"nDescCalc")

nJurosCalc 	:= 0
nMultaCalc	:= 0
nDescCalc	:= 0

Private aBaixas		:= {}

Default cProc 		:= ""
Default nPosLin		:= 0

If nTipo==1
	lAdiantamento := .F.
	If !(cPaisloc $ "BOL")
		nDescont	  := SE1->E1_DESCONT * aTaxa[Max(SE1->E1_MOEDA,1)]
		nJuros		  := SE1->E1_JUROS   * aTaxa[Max(SE1->E1_MOEDA,1)]
		nMulta		  := SE1->E1_MULTA   * aTaxa[Max(SE1->E1_MOEDA,1)]
		nValRec		  := SE1->E1_VALLIQ  * aTaxa[Max(SE1->E1_MOEDA,1)]
	Else
		nDescont	  := SE1->E1_DESCONT
		nJuros		  := SE1->E1_JUROS
		nMulta		  := SE1->E1_MULTA
		nValRec		  := SE1->E1_VALLIQ
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Taxa da moeda: calcula segundo valores do titulo SE1         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nTxMoeda := Round( SE1->E1_VLCRUZ/SE1->E1_VALOR , TamSx3("M2_MOEDA"+AllTrim(STR(SE1->E1_MOEDA)))[2] )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณA correcao monetaria nao deve ser gravada pois os pagamentos sao feitos em bloco,    ณ
	//ณe nao temos como saber se o titulo foi pago com a mesma moeda (neste caso nao existe ณ
	//ณcorrecao monetaria) ou com outra moeda diferente.                                    ณ
	//ณA correcao eh tratada nos relatorios.                                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nCM			:=	0
	nValToler	:=	0
	cLoteFin	:= GetSx8Num("SE5", "E5_LOTE", "E5_LOTE" + cEmpAnt)
	If lAdiantamento
		cBanco		:= SE1->E1_PORTADO
		cAgencia	:= SE1->E1_AGEDEP
		cConta		:= SE1->E1_CONTA
	Else
		cBanco		:= ""
		cAgencia	:= ""
		cConta		:= ""
	Endif
	nValEstrang	:= SE1->E1_VALLIQ
	dBaixa  	:= SE1->E1_DTACRED
	cMotBx		:= IF(Empty(SE1->E1_MOTIVO),"NOR",SE1->E1_MOTIVO)
	// Elimina espacios a la variable cMotBx para enviarla a la funcion MovBcobx()
	Iif(cPaisLoc=="CHI",cMotBx:= Alltrim(cMotBx),.F.)
	
	cHist070	:=STR0057+cRecibo+"-"+cSerie //"Valor recebido por Recibo "
	nMoedaF:= If(SA1->A1_MOEDALC > 0,SA1->A1_MOEDALC,Val(SuperGetMV("MV_MCUSTO")))

	//Atualiza saldo dos valores acess๓rios (FKD)
	If lExistFKD
		FAtuFKDBx(.F.)
	EndIf

	nDescCalc 	:= aLinSe1[nPosLin][nPDescCalc]
	nJurosCalc 	:= aLinSe1[nPosLin][nPJurCalc]
	nMultaCalc 	:= aLinSe1[nPosLin][nPMulCalc]

	FA070Mov(.T.,.T.,lAdiantamento,SE1->E1_DTACRED,@aBaixas,,,aTaxa[Max(SE1->E1_MOEDA,1)],,,,,cProc)
	ConfirmSX8()
	AtuSalDup(IIf(SE1->E1_TIPO$MV_CRNEG+"/"+MVRECANT,"+","-"),SE1->(E1_VALLIQ+E1_DESCONT-E1_JUROS-E1_MULTA),SE1->E1_MOEDA,SE1->E1_TIPO,aTaxa[nMoedaF],dDataBase)
	dbSelectArea("SE1")
	nSalvRec	:= SE1->(RecNo())
	cNum	  	:= SE1->E1_NUM
	cPrefixo	:= SE1->E1_PREFIXO
	cParcela	:= SE1->E1_PARCELA
	cCliente	:= SE1->E1_CLIENTE
	cLoja     	:= SE1->E1_LOJA
	cTipo   	:= ""
	If lCarga
		OmsGrvDAM(nSalvRec,SE5->E5_SEQ,cCarga,cSeqcar,cRecibo,"1")
	EndIf
	If SuperGETMV("MV_TPCOMIS") == "O"
		aBaixas:={}
		If UsaSeqCor()
			AAdd(aDiario,{"SE5",SE5->(Recno()),cDiario,"E5_NODIA","E5_DIACTB"})
  		EndIf
		AAdd(aBaixas,{SE5->E5_MOTBX,SE5->E5_SEQ,SE5->(Recno()),,SE1->E1_VEND1})
		Pergunte("AFI440",.F.)
		Fa440CalcB(aBaixas,.F.,.F.,"FINA087A",,,,.T.,SE1->(Recno()))
		Pergunte("FIN87A",.F.)
	Endif

	///numbor
	aAlt := {}
    aadd( aAlt,{ STR0198,'','','',STR0199 + Alltrim(Transform(nValEstrang,fnPesqPict("SE5","E5_VALOR"))) })
	///chamada da Fun็ใo que cria o Hist๓rico de Cobran็a
	FinaCONC(aAlt)

ElseIf nTipo==2

	If l087GrSE5
		lGrvMov := ExecBlock('F087GrSE5',.F.,.F.,{cTpCred})
	Endif

	If lGrvMov

		//Carrego model de movimento bancario
		oModelMov:SetOperation( MODEL_OPERATION_INSERT ) //Inclusao
		oModelMov:Activate()
		oModelMov:SetValue( "MASTER", "E5_GRV", .T. ) //habilita grava็ใo de SE5
		oModelMov:SetValue( "MASTER", "IDPROC", cProc )
		oModelMov:SetValue( "MASTER", "NOVOPROC", .F. ) //Informa que a inclusใo nใo serแ feita com um novo n๚mero de processo

		oSubFK5	:= oModelMov:GetModel("FK5DETAIL")
		oSubFK6    := oModelMov:GetModel("FK6DETAIL")
		oSubFKA	:= oModelMov:GetModel("FKADETAIL")

		//Reposiciono o banco informado no Recibo
		SA6->(DbSetOrder(1))
		SA6->(DbSeek(xFilial()+SEL->(EL_BANCO+EL_AGENCIA+EL_CONTA)))

		//Define os campos que nใo existem nas FKs e que serใo gravados apenas na E5, para que a grava็ใo da E5 continue igual
		cCamposE5 += " { "
		cCamposE5 += " {'E5_FILIAL'		,'" + cFilSE5 + "'}"
		cCamposE5 += ",{'E5_PREFIXO'	,'" + SEL->EL_PREFIXO + "'}"
		cCamposE5 += ",{'E5_NUMERO'		,'" + SEL->EL_NUMERO + "'}"
		cCamposE5 += ",{'E5_PARCELA'	,'" + SEL->EL_PARCELA + "'}"
		cCamposE5 += ",{'E5_CLIFOR'		,'" + SEL->EL_CLIENTE + "'}"
		cCamposE5 += ",{'E5_LOJA'		,'" + SEL->EL_LOJA + "'}"
		cCamposE5 += ",{'E5_BENEF'		,'" + RemoveAsp(SE1->E1_NOMCLI) + "'}"
		cCamposE5 += ",{'E5_TIPO'		,'" + SEL->EL_TIPODOC + "'}"
		cCamposE5 += ",{'E5_DTDIGIT'	, STOD('" + DTOS(dDataBase) + "')}"
		cCamposE5 += ",{'E5_SERREC', '" + cSerie + "'}"
		cCamposE5 += ",{'E5_VENCTO', STOD('" + DTOS(SEL->EL_DTVCTO) + "')}"

		//Os campos do Banco/Agencia/Conta do cheque estarใo apenas na tabela correspondente ao cheque (SEF)
		If cPaisLoc $ "EQU|DOM"
			cCamposE5 += ",{'E5_BCOCHQ','" +  SEL->EL_BCOCHQ + "'}"
			cCamposE5 += ",{'E5_AGECHQ','" +  SEL->EL_AGECHQ + "'}"
			cCamposE5 += ",{'E5_CTACHQ','" +  SEL->EL_CTACHQ + "'}"
		Endif

		If !oSubFKA:IsEmpty()
			oSubFKA:AddLine()
		EndIf
		cIdFK5 := FWUUIDV4()
		oSubFKA:SetValue( "FKA_IDORIG"  , cIdFK5 )
		oSubFKA:SetValue( "FKA_TABORI" , 'FK5' ) //Todo o recibo precisa do mesmo n๚mero de processo

		cHistMov := Left( STR0057 + cRecibo + "-" + cSerie, nTamHist )
		oSubFK5:SetValue( "FK5_RECPAG", "R" )
		oSubFK5:SetValue( "FK5_HISTOR", cHistMov ) //"Valor recebido por Recibo "
		oSubFK5:SetValue( "FK5_DATA", SEL->EL_EMISSAO )
		oSubFK5:SetValue( "FK5_DTDISP", IIf(cTpCred=="1",dDataRef,SEL->EL_DTVCTO) )	// 1-Imediato  2-Vencimento
		oSubFK5:SetValue( "FK5_TPDOC", "VL" )
		oSubFK5:SetValue( "FK5_VLMOE2", SEL->EL_VALOR )
		oSubFK5:SetValue( "FK5_ORDREC", cRecibo )
		oSubFK5:SetValue( "FK5_MOEDA", StrZero( SA6->A6_MOEDA, 2) )
		oSubFK5:SetValue( "FK5_VALOR", xMoeda(SEL->EL_VALOR,Val(SEL->EL_MOEDA),Max(SA6->A6_MOEDA,1),,,aTaxa[Val(SEL->EL_MOEDA)],aTaxa[Max(SA6->A6_MOEDA,1)]) )
		oSubFK5:SetValue( "FK5_BANCO", SEL->EL_BANCO )
		oSubFK5:SetValue( "FK5_AGENCI", SEL->EL_AGENCIA )
		oSubFK5:SetValue( "FK5_CONTA", SEL->EL_CONTA )
		oSubFK5:SetValue( "FK5_SEQ", PadL("1",TamSX3("E5_SEQ")[1],"0") )
		oSubFK5:SetValue( "FK5_LA", "S" )
		oSubFK5:SetValue( "FK5_NATURE", cNatureza )
		oSubFK5:SetValue( "FK5_TXMOED", aTaxa[Max(SA6->A6_MOEDA,1)] )
		oSubFK5:SetValue( "FK5_ORIGEM", FunName() )
		oSubFK5:SetValue( "FK5_FILORI", cFilAnt )

		// Grava o valor de corre็ใo monetแria no SE5 para ser visualizado na consulta
		If cPaisLoc $ "MEX|VEN" .And. SEL->EL_MOEDA <> "1"
			nTxCor:= Iif(SE1->E1_TXMOEDA > 0, SE1->E1_TXMOEDA, RecMoeda(SE1->E1_EMISSAO, SE1->E1_MOEDA))
			nValOrig:= xMoeda(SEL->EL_VALOR,Val(SEL->EL_MOEDA),1,,,nTxCor)
			nValAtu:= xMoeda(SEL->EL_VALOR,Val(SEL->EL_MOEDA),1,,,aTaxa[Val(SEL->EL_MOEDA)],aTaxa[Max(SA6->A6_MOEDA,1)])

			cCamposE5 += ",{'E5_VLCORRE'," + CVALTOCHAR(nValAtu - nValOrig) + "}"
			If nValAtu - nValOrig != 0
				/*
				 * Adicionando valores acess๓rios (Corre็ใo Monetแria)
				 */
				 cIdFK2		:= FWUUIDV4()
				If !oSubFK6:IsEmpty()
					oSubFK6:AddLine()
				EndIf
				oSubFK6:SetValue( 'FK6_FILIAL'	, cFilFK6 )
				oSubFK6:SetValue( 'FK6_IDFK6'	, GetSxEnum('FK6','FK6_IDFK6') )
				oSubFK6:SetValue( 'FK6_TABORI'	, 'SE2' )
				oSubFK6:SetValue( 'FK6_TPDOC'	, 'CM' )
				oSubFK6:SetValue( 'FK6_VALCAL'	, nValAtu - nValOrig  )
				oSubFK6:SetValue( 'FK6_VALMOV'	, nValAtu - nValOrig  )
				oSubFK6:SetValue( 'FK6_RECPAG'	, "R" )
				oSubFK6:SetValue( 'FK6_IDORIG'	, cIdFK2 )
				oSubFK6:SetValue( 'FK6_GRVSE5'	, .F.)
			Endif
		EndIf

		cCamposE5 += " } "

		//Informo os campos que devem ser gravados somente na SE5
		oModelMov:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 )

		If oModelMov:VldData()
			oModelMov:CommitData()
		Else
			lRet := .F.
			cLog := cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
			cLog += cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_ID]) + ' - '
			cLog += cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_MESSAGE])
			Help( ,,"MF087ASE5",,cLog, 1, 0 )
		Endif

		oModelMov:DeActivate()
		oModelMov:Destroy()
		oModelMov := NIL

		If UsaSeqCor()
			AAdd(aDiario,{"SE5",SE5->(Recno()),cDiario,"E5_NODIA","E5_DIACTB"})
		EndIf

		nValToler	:=0
		cBanco		:= SEL->EL_BANCO
		cAgencia	:= SEL->EL_AGENCIA
		cConta		:= SEL->EL_CONTA
		cLoteFin	:= ""
		nValEstrang	:= SE1->E1_VALLIQ

		If SEL->EL_TPCRED == "1"
			dBaixa := dDataBase
		Else
			dBaixa := SEL->EL_DTVCTO
		Endif

		cHist070:=STR0057+cRecibo+"-"+cSerie //"Valor recebido por Recibo "

		IF !EMPTY(SEL->EL_BANCO).And. MovBcoBx(cMotBx, .T.) .and. !lAdiantamento
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Gravar Saldo Banc rio	        ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			AtuSalBco(cBanco,cAgencia,cConta,dBaixa,SE5->E5_VALOR,"+")
		EndIf
	EndIf
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa087Cont บAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fa087Cont()
Local nHdlPrv:=0
Local cKeyImp 	:= ""
Local cAlias	:= ""
Local lAchou	:=.F.
Local aFlagCTB := {}
Local lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Local nXE5 :=0
Local cPadrao :=""
Local lValGenCTB:= .T.
Local cTextoAv	:= ""
nTotalLanc:=0
cArquivo:= ""
nLinha := 1

If lGeraLanc
	lLancPad70 := VerPadrao("575")
	cPadrao := "575"
Else
	Return
EndIf

If lLancPad70

	//+--------------------------------------------------------------+
	//ฆ Posiciona numero do Lote para Lancamentos do Financeiro      ฆ
	//+--------------------------------------------------------------+
	dbSelectArea("SX5")
	dbSeek(xFilial()+"09FIN")
	cLoteCom:=IIF(Found(),AllTrim(X5DESCRI()),"FIN")

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Inicializa Lancamento Contabil                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nHdlPrv := HeadProva( cLoteCom,;
		                      "FINA087a" /*cPrograma*/,;
		                      Substr( cUsuario, 7, 6 ),;
		                      @cArquivo )

	If nHdlPrv <= 0
		Help(" ",1,"A100NOPROV")
	EndIf
EndIf

If nHdlPrv > 0 .and. lLancPad70

	//+--------------------------------------------------+
	//ฆ Gera Lancamento Contab. para RECIBO.             ฆ
	//+--------------------------------------------------+
	If lLancPad70
		SEL->(DbSetOrder(8))
		SEL->(DbGotop())
		SEL->(DbSeek(xFilial("SEL")+cSerie+cRECIBO,.F.))
		Do while !SEL->(EOF()) .And. SEL->EL_SERIE==cSerie .And. SEL->EL_RECIBO==cRECIBO
			SA6->(DbsetOrder(1))
			SA6->(DbSeek(xFilial("SA6")+SEL->EL_BANCO+SEL->EL_AGENCIA+SEL->EL_CONTA,.F.))

			SE1->(DbsetOrder(2))
			SE1->(DbSeek(xFilial("SE1")+SEL->EL_CLIORIG+SEL->EL_LOJORIG+SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA+SEL->EL_TIPO,.F.))

			Do Case
				Case ( Alltrim(SEL->EL_TIPO) == Alltrim(GetSESnew("NCC")) )
					cAlias := "SF1"
				Case ( Alltrim(SEL->EL_TIPO) == Alltrim(GetSESnew("NDE")) )
					cAlias := "SF1"
				Otherwise
					cAlias := "SF2"
			EndCase
			cKeyImp := 	xFilial(cAlias)	+;
						SE1->E1_NUM		+;
						SE1->E1_PREFIXO	+;
						SE1->E1_CLIENTE	+;
						SE1->E1_LOJA
			If ( cAlias == "SF1" )
				cKeyImp += SE1->E1_TIPO
			Endif
			Posicione(cAlias,1,cKeyImp,"F"+SubStr(cAlias,3,1)+"_VALIMP1")
			lAchou:=.F.

			SE5->(DbSetOrder(2))
			//Nos casos de baixas parciais pelo recibo gera registros com a mesma chave.
			//A diferenca estah no campo E5_ORDREC(numero do recibo)
			If SE5->(DbSeek(xFilial("SE5")+"BA"+SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA+SEL->EL_TIPO))
				While xFilial("SE5") == SE5->E5_FILIAL .And. SEL->EL_PREFIXO == SE5->E5_PREFIXO .And.;
					SEL->EL_NUMERO == SE5->E5_NUMERO .And. SEL->EL_PARCELA == SE5->E5_PARCELA .And.;
					SEL->EL_TIPO == SE5->E5_TIPO .And. SE5->E5_TIPODOC == "BA" .And.!SE5->(Eof()) .And. !lAchou
					If (SE5->E5_ORDREC == cRECIBO .And. SE5->E5_SERREC== cSerie )
						lAchou:=.T.
					Else
						SE5->(DbSkip())
					EndIf

			   EndDo
    	    EndIf

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Prepara Lancamento Contabil                                      ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
					aAdd( aFlagCTB, {"EL_LA", "S", "SEL", SEL->( Recno() ), 0, 0, 0} )
				Endif
				nTotalLanc := nTotalLanc + DetProva( nHdlPrv,;
										                    "575",;
										                    "FINA087a" /*cPrograma*/,;
										                    cLoteCom,;
										                    @nLinha,;
										                    /*lExecuta*/,;
										                    /*cCriterio*/,;
										                    /*lRateio*/,;
										                    /*cChaveBusca*/,;
										                    /*aCT5*/,;
										                    /*lPosiciona*/,;
										                    @aFlagCTB,;
										                    {"SEL",SEL->(Recno())},;
										                    /*aDadosProva*/ )


			If UsaSeqCor()
				AAdd(aDiario,{"SEL",SEL->(Recno()),cDiario,"EL_NODIA","EL_DIACTB"})
			EndIf

			SEL->(DbSkip())
		EndDo
		If cPaisLoc $ "PER|BOL"
  		   For nXE5 := 1 to Len(aRecnoITF)
		       SE5->(DbGoto(aRecnoITF[nXE5]))
               FinProcITF( SE5->(Recno()),8,SE5->E5_VALOR,.F.,{nHdlPrv,cPadrao,"FINA087A","FINA087A",cLotecom})
           Next
		Endif
	Endif

	//+-----------------------------------------------------+
	//ฆ Envia para Lancamento Contabil, se gerado arquivo   ฆ
	//+-----------------------------------------------------+
	SEL->(DbSetOrder (8))
	SEL->(DbSeek(xFilial("SEL")+cSerie+cRecibo))

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Efetiva Lanamento Contabil                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		RodaProva(	nHdlPrv,;
						nTotalLanc )
	If cPaisLoc = "MEX" .And. !IsBlind()
		If !lConfTimb
			lValGenCTB := MsgYesNo(STR0250 + Chr(13) + STR0251, STR0230) //"Se seleccion๓ no generar el Complemento de Recepci๓n de Pago, por lo tanto," ## "ฟDesea continuar?" ## "Aviso"
		ElseIf PesqFFCT5("575") .Or. !lTimbraOk
			cTextoAv := IIf(!lTimbraOk, STR0252, STR0253) //"Ha ocurrido un error en el proceso de timbrado, ..." ## "El campo Folio Fiscal del Asiento Estแndar..."
			MsgAlert(cTextoAv, STR0230) //"Aviso"
		EndIf
	EndIf
	If lValGenCTB
		lLanctOk := cA100Incl(	cArquivo,;
										nHdlPrv,;
										3 /*nOpcx*/,;
										cLoteCom,;
										lDigita,;
										lAglutina,;
										/*cOnLine*/,;
										/*dData*/,;
										/*dReproc*/,;
										@aFlagCTB,;
										/*aDadosProva*/,;
										aDiario )
	Else
		lLanctOk := .F.
	EndIf
	aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento

	If lLanctOk
		SEL->(DbSetOrder (8))
		If SEL->(DbSeek(xFilial("SEL")+cSerie+cRecibo))
			Do while SEL->EL_SERIE==cSerie .And. SEL->EL_RECIBO==cRecibo
				RecLock("SEL",.F.)
				Replace EL_LA With "S"
				MsUnLock()
				SEL->(DbSkip())
			Enddo
		EndIf
	Endif
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa087aWhen บAutor  ณBruno Sobieski      บ Data ณ  07/30/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPermissao de digitacao dependendo de outros campos.		  บฑฑ
ฑฑบ          ณX3_WHEN                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA087A                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function a087aWhen(cCampo)
Local nPosTpDoc 	:=	Ascan(aHeader,{|x| x[2] == "EL_TIPODOC"})
Local nPosTpCred	:=	Ascan(aHeader,{|x| Alltrim(x[2]) == "EL_TPCRED"})
Local lRet	:=	.T.
If cCampo == "TPCRED"
	If Empty(aCols[n][nPosTpCred])
		MsgAlert(OemToAnsi(STR0061))
		lRet	:=	.F.
	ElseIf	!(aCols[n][nPosTpDoc] $ cCredMed) .Or. (aCols[n][nPosTpDoc] == "CHF")
		MsgAlert(OemToAnsi(STR0062))
		lRet	:=	.F.
		If (aCols[n][nPosTpDoc] $ cCredInm) .Or. (cPaisLoc == "BRA" .And. Alltrim(aCols[n][nPosTpDoc]) == "DC")
		    //Imediato
			aCols[n][nPosTpCred]	:=	"1"
		Else
			If (aCols[n][nPosTpDoc] == "CHF")
			    //Acreditacion
				aCols[n][nPosTpCred]	:=	"3"
			Else			
				//Fiscal
				aCols[n][nPosTpCred]	:=	"4"
			EndIF
		Endif
	Endif
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณFa087aCancelบAutor  ณMicrosiga           บ Data ณ 03/23/11  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fa087aCancel(nPan,nLPan)

FA087aUnlock()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa087Lock  บAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function a087Lock(nPos,lLock)
Local nPosRec	:=	0
Local lRet	:=	.T.
If aLinSE1[nPos,Len(aLinSE1[1])-1] <> Nil
	If lLock
		SE1->(DbGoTo(aLinSE1[nPos,Len(aLinSE1[1])-1]))
		If SE1->(MsRLock(RECNO()))
			AAdd(aRLocks,SE1->(RECNO()))
		Else
			Alert(OemToAnsi(STR0073)) //"El registro esta en uso por otra estacion"
			lRet	:=	.F.
		Endif
	Else
		SE1->(DbGoTo(aLinSE1[nPos,Len(aLinSE1[1])-1]))
		SE1->(MsRUnlock(RECNO()))
		nPosRec	:=	AScan(aRLocks,SE1->(RECNO()))
		If nPosRec != 0
			ADel(aRLocks,nPosRec)
			ASize(aRLocks,Len(aRLocks)-1)
		EndIf
	Endif
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณA087aSugerirบAutor  ณMicrosiga           บ Data ณ 03/23/11  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A087aSugerir()

Local nPosPref	:= AScan(aCposSE1,"E1_PREFIXO")
Local nPosNum 	:= AScan(aCposSE1,"E1_NUM")
Local nPosParc	:= AScan(aCposSE1,"E1_PARCELA")
Local nPosTipo	:= AScan(aCposSE1,"E1_TIPO")
Local nPosValor	:= AScan(aCposSE1,"E1_VALOR")
Local nJ			:= 0
Local aRet := {}

nPosBx :=	Ascan(aCposSE1,"nBaixar")

SE1->(DbSetorder(1))
For nJ:=1 to Len(aLinSE1)

	SE1->(DbSeek(xFilial("SE1")+aLinSE1[nJ][nPosPref]+aLinSE1[nJ][nPosNum]+;
	aLinSE1[nJ][nPosParc]+aLinSE1[nJ][nPosTipo]))
	If cPaisLoc $ "ARG|COS"
		If SE1->E1_DTDIFCA >= dDataBase
			nJ++
			Loop
		Endif
   Endif
	If !a087Lock(nJ,.T.)
		nJ++
		Loop
	Endif
	nValOrig	:= aLinSE1[nJ][nPosValor]
	nTotAbat	:= SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"S",dDataRef)
	nParciais	:= aLinSE1[nJ][nPosValor]-SE1->E1_SALDO

	nDescont	:= aLinSE1[nJ][nPosDesc]
	nJuros		:= aLinSE1[nJ][nPosJuros]
	nMulta		:= aLinSE1[nJ][nPosMulta]
	nValEstr	:= 0
	dnCorrec	:= 0
	nSaldo		:= SE1->E1_SALDO - nTotAbat - nRetCfg - nDescont + nMulta + nJuros + nVA
	nValRec		:= nSaldo  + nRetCfg

	nBx:=Ascan(aCposSE1,"nBxMoeda" + Alltrim(Str(SE1->E1_MOEDA)))

	If aLinMoed[SE1->E1_MOEDA][4] >= nValRec-nMulta+nDescont-nJuros - nVA .Or. aLinSE1[nj][nPosTipo]$MVRECANT+"/"+MV_CRNEG
		aLinSE1[nJ][nBx]		:= nValRec
		aLinSE1[nJ][nPosDesc]	:= nDescont
		aLinSE1[nJ][nPosJuros]	:= nJuros
		aLinSE1[nJ][nPosVA]		:= nVA
		aLinSE1[nJ][nPosMulta]	:= nMulta
		aLinSE1[nJ][nPosBx]		:= nValRec-nMulta+nDescont-nJuros - nVA
		aLinSE1[nJ][nPosMotBx] 	:= "NOR"
		If aLinSE1[nJ][nPosTipo] $ MVRECANT+"/"+MV_CRNEG
			aLinMoed[SE1->E1_MOEDA][4]+=nValRec-nMulta+nDescont-nJuros - nVA
		Else
			aLinMoed[SE1->E1_MOEDA][4]-=nValRec-nMulta+nDescont-nJuros - nVA
		Endif
		If nValRec>0
			aLinSE1[nJ,1] := 1
		Endif
    Endif
Next nJ

If ExistBlock("F087BTNSG")
	aRet := ExecBlock("F087BTNSG",.F.,.F.,{aLinSE1,aLinMoed})
	If ValType(aRet) == "A" .And. Len(aRet) == 2 //Se o retorno foi um array e se esta com duas dimensoes (aLinSE1 e aLinMoed)
		aLinSE1 := IIf(Len(aRet[1]) == Len(aLinSE1), aLinSE1,  aClone(aRet[1])) //Se estiver com o mesmo tamanho do array original, atribuo o novo array
		aLinMoed := IIf(Len(aRet[2]) == Len(aLinMoed), aLinMoed, aClone(aRet[2])) //Se estiver com o mesmo tamanho do array original, atribuo o novo array
	EndIf
EndIf

oLBSE1:SetArray(aLinSE1)
oLBSE1:bLine:= { || &(cBLinSE1 + "}") }
oLbSE1:Refresh()
FaMoedas()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณA087aFiltrarบAutor  ณMicrosiga           บ Data ณ  03/23/11 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A087aFiltrar(nPan,cNumFatAut)

Local aCpos:={}
Local ctitulo
Local oBtn
Local oBtnOp
Local cCampo := ""
Local aStrOp
Local cOper
Local oExpr
Local cExpr:=""
Local oCampo
Local aCampo:={}
Local cTxtFil := ""
Local cExpFil := ""
Local oTxtFil
Local oOper
Local oMatch
Local nMatch := 0
Local nI := 0

Private lMarca := -1

Default cNumFatAut :=""

oGetSEL:oBrowse:lDisablepaint:=.T.
If nPan==2
	aCpos:=aClone(aCabSA1)
	// Adiciona campo de Marca
	AADD(aCampo,{lMarca,STR0074,.F.,"01",1,Space(45),"N",0}) //"Selecionado"
	For nI:= 1 to Len(aHeadSA1)
		AADD(aCampo,{aHeadSA1[nI][2],aHeadSA1[nI][1],.T.,"01",aHeadSA1[nI][4],If(Empty(aHeadSA1[nI][3]),Space(45),aHeadSA1[nI][3]),aHeadSA1[nI][8],aHeadSA1[nI][5]})
	Next nI
Endif
If nPan==3
	aCpos:=aClone(aCabSE1)
	// Adiciona campo de Marca
	AADD(aCampo,{lMarca,STR0074,.F.,"01",1,Space(45),"N",0}) //"Selecionado"
	For nI:= 1 to Len(aHeadSE1)
		AADD(aCampo,{aHeadSE1[nI][2],aHeadSE1[nI][1],.T.,"01",aHeadSE1[nI][4],If(Empty(aHeadSE1[nI][3]),Space(45),aHeadSE1[nI][3]),aHeadSE1[nI][8],aHeadSE1[nI][5]})
	Next nI
Endif
nI:=1

cTitulo:=STR0066 //"Filtrar"

DEFINE MSDIALOG oDlgPesq TITLE OemToAnsi(cTitulo) FROM 000,000 TO 250,405 PIXEL OF oDlgRecibo

aStrOp := { OemToAnsi(STR0075),OemToAnsi(STR0076),OemToAnsi(STR0077),OemToAnsi(STR0078),OemToAnsi(STR0079),OemToAnsi(STR0080),OemToAnsi(STR0081),OemToANsi(STR0082 ),OemToANsi(STR0083),OemToAnsi(STR0084)}	//  //"Igual a"###"DIferente de"###"Menor que"###"Menor ou igual a"###"Maior que"###"Maior ou igual a"###"Contm a expresso"###"No contm"###"Est  contido em"###"No est  contido em"
@ 05,005 SAY OemToAnsi(STR0085) SIZE 20,8 PIXEL OF oDlgPesq //  //"Campo:"
@ 05,060 SAY OemToAnsi(STR0086) SIZE 30,8 PIXEL OF oDlgPesq   //  //"Operador:"
@ 05,115 SAY OemToAnsi(STR0087) SIZE 30,8 PIXEL OF oDlgPesq  //  //"Expresso:"
@ 50,005 SAY OemToAnsi(STR0088) SIZE 20,8 PIXEL OF oDlgPesq  //  //"Filtro:"

@ 35,005 BUTTON oBtna PROMPT OemToAnsi(STR0089) SIZE 35,10 OF oDlgPesq PIXEL ; //"&Adiciona"
	ACTION (cTxtFil := BuildTxt(cTxtFil,Trim(cCampo),cOper,cExpr,.t.,@cExpFil,aCampo,oCampo:nAt,oOper:nAt),cExpr := CalcField(oCampo:nAt,aCampo),BuildGet(oExpr,@cExpr,aCampo,oCampo,oDlgPesq),oTxtFil:Refresh(),oBtne:Enable(),oBtnOp:Disable(),oBtnOu:Enable(),oBtnExp:Disable(),oBtna:Disable(),oBtne:Refresh(),oBtnou:Refresh(),oBtna:Refresh()) ;
	FONT oDlgPesq:oFont //

@ 35,45 BUTTON oBtn PROMPT OemToAnsi(STR0090) SIZE 35,10 OF oDlgPesq PIXEL ; //"&Limpa Filtro"
	ACTION (cTxtFil := "",cExpFil := "",nMatch := 0,oTxtFil:Refresh(),oBtnExp:Enable(),oBtnA:Enable(),oBtnE:Disable(),oBtnOu:Disable(),oMatch:Disable(),oBtnOp:Enable()) ;
	FONT oDlgPesq:oFont //

@ 35,85 BUTTON oBtnExp PROMPT OemToAnsi(STR0091) SIZE 35,10 OF oDlgPesq PIXEL ; //"&Expresso"
	ACTION (lRet:=FilterExp(@cTxtFil,@cExpFil),oTxtFil:Refresh(),If(lRet,oBtnOp:Disable(),oBtnOp:Enable()),If(lRet,oBtnExp:Disable(),oBtnExp:Enable()),If(lRet,oBtna:Disable(),oBtna:Enable()),If(lRet,oBtnE:Enable(),oBtnE:Disable()),If(lRet,oBtnOu:Enable(),oBtnOu:Disable())) ;
	FONT oDlgPesq:oFont  //

@ 30,175 BUTTON oBtnOp PROMPT OemToAnsi("(") SIZE 12,12 OF oDlgPesq PIXEL FONT oDlgPesq:oFont ;
	ACTION (If(nMatch==0,oMatch:Enable(),nil),nMatch++,cTxtFil+= " ( ",cExpFil+="(",oTxtFil:Refresh()) ;

@ 30,190 BUTTON oMatch PROMPT OemToAnsi(")") SIZE 12,12 OF oDlgPesq PIXEL FONT oDlgPesq:oFont;
	ACTION (nMatch--,cTxtFil+= " ) ",cExpFil+=")",If(nMatch==0,oMatch:Disable(),nil),oTxtFil:Refresh()) ;

@ 45,175 BUTTON oBtne PROMPT OemToAnsi(STR0092) SIZE 12,12 OF oDlgPesq PIXEL FONT oDlgPesq:oFont; //" E "
	ACTION (cTxtFil+=STR0092,cExpFil += ".and.",oTxtFil:Refresh(),oBtne:Disable(),oBtnou:Disable(),oBtnExp:Enable(),oBtna:Enable(),oBtne:Refresh(),oBtnou:Refresh(),oBtna:Refresh(),oBtnOp:Enable()) ; //" e "

@ 45,190 BUTTON oBtnOu PROMPT OemToAnsi(STR0093) SIZE 12,12 OF oDlgPesq PIXEL FONT oDlgPesq:oFont; //" OU "
	ACTION (cTxtFil+=STR0093,cExpFil += ".or.",oTxtFil:Refresh(),oBtne:Disable(),oBtnou:Disable(),oBtnExp:Enable(),oBtna:Enable(),oBtne:Refresh(),oBtnou:Refresh(),oBtna:Refresh(),oBtnOp:Enable()) //" ou "
oMatch:Disable()

cCampo := aCpos[1]
@ 15,05 COMBOBOX oCampo VAR cCampo ITEMS aCpos SIZE 50,50 OF oDlgPesq PIXEL;
	ON CHANGE BuildGet(oExpr,@cExpr,aCampo,oCampo,oDlgPesq,,oOper:nAt)
cExpr := CalcField(oCampo:nAt,aCampo)
cOper := aStrOp[1]

@ 15,60 COMBOBOX oOper VAR cOper ITEMS aStrOp SIZE 50,50 OF oDlgPesq PIXEL;
	ON CHANGE BuildGet(oExpr,@cExpr,aCampo,oCampo,oDlgPesq,,oOper:nAt)

@ 15,115 MSGET oExpr VAR cExpr SIZE 85,10 PIXEL OF oDlgPesq PICTURE AllTrim(aCampo[oCampo:nAt,6]) FONT oDlgPesq:oFont

@ 60,05 GET oTxtFil VAR cTxtFil MEMO SIZE 195,40 PIXEL OF oDlgPesq READONLY
oTxtFil:bRClicked := {||AlwaysTrue()}

oBtne:Disable()
oBtnou:Disable()

DEFINE SBUTTON FROM 113,070  TYPE 1  ACTION (aFilOK(cExpFil,cNumFatAut),oDlgPesq:End()) OF oDlgPesq When .T.
DEFINE SBUTTON FROM 113,100  TYPE 2  ACTION (oDlgPesq:End()) OF oDlgPesq When .T.

ACTIVATE MSDIALOG oDlgPesq CENTERED

If nPan==2
	oLBCli:SetArray(aLinSA1)
	oLBCli:bLine:= { || &(cBLinSA1 + "}") }
	oLBCli:Refresh()
Endif
If nPan==3
	oLBSE1:SetArray(aLinSE1)
	oLBSE1:bLine:= { || &(cBLinSE1 + "}") }
	oLBSE1:Refresh()
Endif

oGetSEL:oBrowse:lDisablepaint:=.F.
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณCalcField  บAutor  ณMicrosiga           บ Data ณ  03/23/11  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CalcField(nAt,aCampo)
Local cRet

If aCampo[nAt,7] == "C"
	cRet := Space(aCampo[nAt,5])
ElseIf aCampo[nAt,7] == "N"
	cRet := 0
ElseIf aCampo[nAt,7] == "D"
	cRet := CTOD("  /  /  ")
EndIf
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBuildTxt  บAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BuildTxt(cTxtFil,cCampo,cOper,xExpr,lAnd,cExpFil,aCampo,nCpo,nOper)
Local cChar := OemToAnsi(CHR(39))
Local cType := ValType(xExpr)
Local aOper := { "==","!=","<","<=",">",">=","..","!.","$","!x"}

cTxtFil += cCampo+" "+cOper+" "+If(cType=="C",cChar,"")+cValToChar(xExpr)+If(cType=="C",cChar,"")

If cType == "C"
	#ifndef TOP
	If aOper[nOper] == "!."    //  Nao Contem
		cExpFil += '!('+'"'+AllTrim(cValToChar(xExpr))+'"'+' $ AllTrim('+aCampo[nCpo,1]+'))'   // Inverte Posicoes
	ElseIf aOper[nOper] == "!x"   // Nao esta contido
		cExpFil += '!(AllTrim('+aCampo[nCpo,1]+") $ " + '"'+AllTrim(cValToChar(xExpr))+'")'
	ElseIf aOper[nOper]	== ".."  // Contem a Expressao
		cExpFil += '"'+AllTrim(cValToChar(xExpr))+'"'+" $ AllTrim("+aCampo[nCpo,1] +" )"   // Inverte Posicoes
	#else
	If  aOper[nOper] == "!."    //  Nao Contem
		cExpFil += '!('+'"'+AllTrim(cValToChar(xExpr))+'"'+' $ '+aCampo[nCpo,1]+')'   // Inverte Posicoes
	ElseIf aOper[nOper] == "!x"   // Nao esta contido
		cExpFil += '!('+aCampo[nCpo,1]+" $ " + '"'+AllTrim(cValToChar(xExpr))+'")'
	ElseIf aOper[nOper]	== ".."  // Contem a Expressao
		cExpFil += '"'+AllTrim(cValToChar(xExpr))+'"'+" $ "+aCampo[nCpo,1] +" "   // Inverte Posicoes
	#endif
	Else
		#ifndef TOP
			If (aOper[nOper]=="==")
				cExpFil += aCampo[nCpo,1] +aOper[nOper]+" "
				cExpFil += '"'+cValToChar(xExpr)+'"'
			Else
				cExpFil += 'Alltrim('+aCampo[nCpo,1] +')' +aOper[nOper]+" "
				cExpFil += '"'+AllTrim(cValToChar(xExpr))+'"'
			EndIf
		#else
			If (aOper[nOper]=="==")
				cExpFil += aCampo[nCpo,1] +aOper[nOper]+" "
				cExpFil += '"'+cValToChar(xExpr)+'"'
			Else
				cExpFil += 'Alltrim('+aCampo[nCpo,1] +')' +aOper[nOper]+" "
				cExpFil += '"'+AllTrim(cValToChar(xExpr))+'"'
			EndIf
		#endif
	EndIf
ElseIf cType == "D"
	// Nao Mexer, deixar dToS pois e'a FLAG Para Limpeza do Filtro
	cExpFil += "dToS("+aCampo[nCpo,1]+") "+aOper[nOper]+' "'
	cExpFil += Dtos(CTOD(cValToChar(xExpr)))+'"'
Else
	cExpFil += aCampo[nCpo,1]+" "+aOper[nOper]+" "
	cExpFil += cValToChar(xExpr)
EndIf

Return cTxtFil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFilterExp บAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FilterExp(cTxtFil,cExpFil)

Local oDlg, oBtn, cExpr := Space(255), oPai
Local lProcess := .f.

oPai:= GetWndDefault()

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0094) FROM 0,0 TO 100,500 OF oPai PIXEL //"Expressใo:"

@ 10,10 MSGET oExpr VAR cExpr SIZE 230,10 OF oDlg PIXEL

@ 30,10 TO 30,240 OF oDlg PIXEL

@ 35,10 BUTTON oBtn PROMPT OemToAnsi(STR0089) SIZE 40,10 PIXEL ACTION (lProcess := .t.,oDlg:End()) //  //"&Adiciona"

@ 35,55 BUTTON oBtn PROMPT OemToAnsi(STR0095) SIZE 40,10 PIXEL ACTION oDlg:End() //  //"&Cancela"

ACTIVATE MSDIALOG oDlg CENTERED

If lProcess

	cTxtFil += Trim(cExpr)
	cExpFil += Trim(cExpr)

	// Retorno correto para o Enable/Disable dos botoes.
	If Empty(cExpr)
		lProcess:= .F.
	EndIf

EndIf
Return lProcess

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFilOk    บAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AFilOk(xExpr,cNumFatAut)

DEFAULT cNumFatAut := ""

aFiltros[nPanel]:=xExpr
Refdata(nPanel,cNumFatAut)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณA087DescontoบAutor  ณMicrosiga           บ Data ณ 03/23/11  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A087Desconto()
oPanel[nPanel]:lReadOnly:=.T.
oPanBut:lReadOnly:=.T.
oCBMoed1:nAt:=nMoedDesc
oPDesc:Show()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA087OKDescบAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A087OKDesc(cNumFatAut)
Local anTotBx
Local nX
DEFAULT cNumFatAut := ""

If aTaxa[nMoedDesc]<=0
	Alert(STR0052) //"Informe todas as taxas das moedas que serใo utilizadas nas Baixas."
	Return .F.
Endif

// Para poder fazer a valida็ใo do valor do desconto, transformo o valor
// total de baixas para a moeda em que o desconto foi dado, depois faco a comparacao.
nTot:=0
nX:=0
If nDescTot > 0
	anTotBx:=SomaBaixa()
	For nX := 1 to Len(anTotBx)
		nTot += anTotBx[nX]*aTaxa[nX]
	Next nX
	nTot:=nTot/aTaxa[nMoedDesc]
	If nDescTot > nTot
		Alert(STR0096)  //"Valor do desconto nใo pode ser maior que o valor a baixar."
		Return .F.
	Endif
EndIf

nDescGer:=nDescTot
nPercGer:=nPercDesc
oPDesc:Hide()
FaMoedas()
oPanBut:lReadOnly:=.F.
oPanel[nPanel]:lReadOnly:=.F.
RefData(4,cNumFatAut)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF087aMotBxบAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F087aMotBx()
If oMotBx:nAt>1
	nDescont:= aLinSE1[oLBSE1:nAt][nPosDesc]
	nJuros	:= aLinSE1[oLBSE1:nAt][nPosJuros]
	nJurosC	:= aLinSE1[oLBSE1:nAt][nPosJurosC]
	nVA		:= aLinSE1[oLBSE1:nAt][nPosVA]
	nMulta	:= aLinSE1[oLBSE1:nAt][nPosMulta]
	oDescont:Disable()
	oMulta:Disable()
	oJuros:Disable()
	oVA:Disable()
	If cPaisLoc <> "BOL"
		FAPagtoAtu()
	Endif
Else
	oDescont:Enable()
	oMulta:Enable()
	oJuros:Enable()
	oVA:Disable()
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa087VerPE บAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function a087VerPE(nMoeda,nValor)
Local lRet := .T.
Local cVar
Local aConcepto	:= {}

If ExistBlock("Fa087Pg")
	cVar := ReadVar()
	lRet := ExecBlock("Fa087Pg",.F.,.F.,{nMoeda,nValor})
	&(cVar) := aLinBaixa[nMoeda][2]
	oParciais:Refresh()
	oDescont:Refresh()
	oMulta:Refresh()
	If oRetCfg != Nil
		oRetCfg:Refresh()
	EndIf
	oJuros:Refresh()
	oLBBaixa:SetArray(aLinBaixa)
	oLBBaixa:bLine 	:= { || {aLinBaixa[oLBBaixa:nAT][1],;
						Transform(aLinBaixa[oLBBaixa:nAT][2],fnPesqPict("SE1","E1_VALOR",18,oLBBaixa:nAT)) }}
	oLBBaixa:Refresh()
EndIf

If cPaisLoc == "COS"

	aConcepto := fa087Concept(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,Nil,{"2|3","2",SE1->E1_NATUREZ,nValor},.T.)
	If oRetCfg != Nil
		If !Empty(aConcepto)
			nRetCfg := aConcepto[1][5]
		EndIf
		oRetCfg:Refresh()
	EndIf
	nSaldo	:= SE1->E1_SALDO-nTotAbat-nDescont+nMulta+nJuros-nRetCfg
	oDescont:Refresh()
	oMulta:Refresh()
	oJuros:Refresh()
	oSaldo:Refresh()
	oParciais:Refresh()
	oVA:Refresh()
	oLBBaixa:SetArray(aLinBaixa)
	oLBBaixa:bLine 	:= { || {aLinBaixa[oLBBaixa:nAT][1],;
						Transform(aLinBaixa[oLBBaixa:nAT][2],fnPesqPict("SE1","E1_VALOR",18,oLBBaixa:nAT)) }}
	oLBBaixa:Refresh()

EndIf

Return lRet

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณTelaAdmCarณ Autor ณ Fernando Machima      ณ Data ณ19/08/2001ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Mostra a tela para selecionar a administradora de cartao deณฑฑ
ฑฑณ          ณ credito                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ FINA087A                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TelaAdmCar(cPref,cNum,cParc,nValor,nMoeda,n)

Local oDlgAdm,oCbxAdm,olbl1,olbl2,oBtn1
Local cCodAdm  := ""
Local aAdm     := {}
Local aSAE     := {}
Local lRet     := .T.
Local aAreaAtu := GetArea()
Local aAreaSA1 := SA1->(GetArea())
Local aAreaSAE := SAE->(GetArea())

DEFINE FONT oFnt  NAME "Times New Roman" SIZE 7,15
DEFINE FONT oFntB NAME "Times New Roman" SIZE 7,15 BOLD

DbSelectArea("SAE")
DbSetOrder(1)
DbGoTop()
While !Eof() 
	If (AllTrim(SAE->AE_TIPO) == "CC") .or. (AllTrim(SAE->AE_TIPO) == "CD")
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+SAE->AE_COD))
			AAdd(aAdm,SAE->AE_COD +" - "+SAE->AE_DESC)
			AAdd(aSAE,{SA1->A1_COD,SA1->A1_LOJA,SubStr(SA1->A1_NOME,1,30),SAE->AE_TIPO})
		EndIF
	EndIf
	DbSkip()
End

If Len(aAdm) == 0
	MsgStop(OemToAnsi(STR0103)) //"Nao e possivel efetuar a baixa dos titulos porque nao existe uma Administradora Financeira de Cartao de Credito/Debito cadastrada"
	lRet := .F.
Else
	//Limpa o array para que sejam armazenados apenas os
	//dados mais recentes...

	DEFINE MSDIALOG oDlgAdm FROM  34,155 TO 275,510 ;
	TITLE STR0104 PIXEL //"Administradora de Cart๕es"

	@  05, 05 Group olbl1 TO 045,173 LABEL OemToAnsi(STR0105) OF oDlgAdm PIXEL //" Dados do Recebimento "

	@  15, 010 SAY STR0106       FONT oFnt  PIXEL SIZE 50,18 COLOR CLR_RED,CLR_WHITE //"Numero: "
	@  15, 040 SAY oNum VAR cNum FONT oFntB PIXEL SIZE 50,18 COLOR CLR_BLACK,CLR_WHITE

	@  15, 075 SAY STR0107         FONT oFnt  PIXEL SIZE 50,18 COLOR CLR_RED,CLR_WHITE //"Prefixo: "
	@  15, 110 SAY oPref VAR cPref FONT oFntB PIXEL SIZE 50,18 COLOR CLR_BLACK,CLR_WHITE

	@  25, 010 SAY STR0108         FONT oFnt  PIXEL SIZE 50,18 COLOR CLR_RED,CLR_WHITE //"Parcela: "
	@  25, 040 SAY oParc VAR cParc FONT oFntB PIXEL SIZE 50,18 COLOR CLR_BLACK,CLR_WHITE

	@  25, 075 SAY STR0109       FONT oFnt PIXEL SIZE 50,18 COLOR CLR_RED,CLR_WHITE //"Valor: "
	@  25, 110 SAY oValor VAR Transform(nValor,fnPesqPict("SEL","EL_VALOR",,nMoeda)) FONT oFntB PIXEL SIZE 50,18 COLOR CLR_BLACK,CLR_WHITE

	@  50, 005 Group olbl2 TO 75,173 LABEL OemToAnsi(STR0110) OF oDlgAdm PIXEL //" Administradora "

	@  60, 010 COMBOBOX oCbxAdm VAR cCodAdm ITEMS aAdm SIZE 70,35 OF oDlgAdm PIXEL

	DEFINE SBUTTON oBtn1 FROM 085,145 TYPE 1 ENABLE;
	ACTION (AAdd(aDadosAdm,{aSAE[oCbxAdm:nAt][01],aSAE[oCbxAdm:nAt][02],;
               	            aSAE[oCbxAdm:nAt][03],aSAE[oCbxAdm:nAt][04],n}),oDlgAdm:End());
               	            OF oDlgAdm PIXEL

	ACTIVATE DIALOG oDlgAdm CENTERED

EndIf

//Restaura as areas originais...
SAE->(RestArea(aAreaSAE))
SA1->(RestArea(aAreaSA1))
RestArea(aAreaAtu)

Return(lRet)

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณFA087COB  ณ Autor ณ Paulo Augusto         ณ Data ณ07/08/2002ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Valida para saber se o recibo pertence ao cobrador e tb se ณฑฑ
ฑฑณ          ณ esse talao ja esta fechado                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ FINA087A                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA087Cob(cTipo)
// Paulo
Local aArea:=GetArea()
Local lRet:=.F.
Local lValSer

lValSer := SuperGetMv('MV_SERREC') // Usando serie nos recibos

If !Empty(cCobrador)
	DbSelectArea("SAQ")
	DbSetOrder(1)
	If dbSeek(xFilial("SAQ")+cCobrador)
		nRecnoSAQ:=Recno()
		If SAQ->AQ_TIPOREC=="3" .or. cTipo <> SAQ->AQ_TIPOREC .or. cTipo= "3"
			lRet:=.T.
		Else
			cRecComp	:= Iif(SAQ->AQ_TIPOREC =="1",cRecibo,cRecProv)
			cTipo 	:= SAQ->AQ_TIPOREC // Valida Tipo do Recibo do Cobrador
			DbSelectArea("SEY")
			DbSetOrder(1)
			If dbSeek(xFilial("SEY")+cCobrador)
				//So validar a serie quando ้ um recibo definitivo, provisorio nao tem serie
				While !EOF() .and. cCobrador == SEY->EY_COBRAD
					If SEY->EY_STATUS<>"2" .and. cTipo == SEY->EY_TIPOREC .and. ;
						cRecComp  >= SEY->EY_RECINI .and. cRecComp <= SEY->EY_RECFIN .and.;
						If(lValser .And. cTipo == '1', cSerie== SEY->EY_SERIE .Or. Empty(SEY->EY_SERIE),.T.)
						lRet:=.T.
						nRecnoSEY:=Recno()
						Exit
					EndIf
					DbSkip()
				Enddo
		   EndIf
		   If !lRet
		   	HELP(" ",1,"A087NUMV")
		   EndIf
		EndIf
	Else
		Help(" ",1,"RECNO")
	EndIf
Else
	lRet:=.T.
EndIf
RestArea(aArea)
Return(lRet)

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณFa087Com  ณ Autor ณ Paulo Augusto         ณ Data ณ07/08/2002ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Grava o arquivo de comissoes  de cobrador                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ FINA087A                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fa087Com()

Local aCpoSEX:={}
SAQ->(dbGoto(nRecnoSAQ))
//SE MUDAR ALGUMA POSICAO DO ARRAY ABAIXO, PRECISA CORRIGIR TB NOS FONTES FINA016/FINA87A/FINA088.
AADD(aCpoSEX,SEL->EL_COBRAD )
AADD(aCpoSEX,SEL->EL_SERIE )
AADD(aCpoSEX,SEL->EL_RECIBO )
AADD(aCpoSEX,SEL->EL_DTDIGIT )
AADD(aCpoSEX,SEL->EL_CLIORIG)
AADD(aCpoSEX,SEL->EL_LOJORIG )
AADD(aCpoSEX,SEL->EL_VALOR  )
AADD(aCpoSEX, SAQ->AQ_COMIS)
AADD(aCpoSEX,Val(SEL->EL_MOEDA))
AADD(aCpoSEX,(SEL->EL_VALOR ) *(SAQ->AQ_COMIS/100) )
AADD(aCpoSEX,SEL->EL_TIPODOC )
AADD(aCpoSEX,SEL->EL_NUMERO)
//AADD(aCpoSEX,SEL->EL_PARCELA)
Fa016Calc(aCpoSEX)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A087aMarca() ณAutor ณ  Paulo Augusto       ณDataณ 19.02.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Inverte selecao na tela de clientes                        ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

STATIC FUNCTION A087aMarca()

Local nJ:=1

For nJ:=1 to Len(aLinSA1)
	aLinSA1[nJ,1] := aLinSA1[nJ,1] * -1
Next nJ
oLBCli:Refresh()

Return


Static Function A087Load(aC, nRecs, cCond, lAchou, lRecno, aCpos, c_Alias)

Local nLin    := 0
Local nCol    		:= 0
Local cMvJurTipo 	:= SuperGetMv("MV_JURTIPO",,"")  // calculo de Multa do Loja , se JURTIPO == L
Local lLojxRMul  	:= FindFunction("LojxRMul")
Local lMulLoj	  	:= SuperGetMv("MV_LJINTFS", ,.F.) //Calcula multa conforme regra do loja, se integra็ใo com financial estiver habilitada

If &(cCond)
	nSel:= -1
	lAchou:=.T.
	AAdd(aC,Array(Len(aCpos)+nRecs))
    aEval(aCpos,{|x,y| aC[Len(aC)][y] := &(x)})
	If lRecno
		aC[Len(aC)][Len(aC[1])-1]:=(c_Alias)->R_E_C_N_O_
	Endif
	aC[Len(aC)][Len(aC[1])]:=.F.
	If c_Alias == "SE1TMP"
		nLin     := Len(aC)
		nCol     := Len(aC[nLin])-1

		If !Empty(aC[nLin][nCol])
			SE1->(MsGoto(aC[nLin][nCol]))
			aC[nLin][nPosDesc]  	:= FaDescFin("SE1",dDataRef,SE1->E1_SALDO,SE1->E1_MOEDA)
			aC[nLin][nPosDescC]  	:= aC[nLin][nPosDesc]
			aC[nLin][nPosJuros] 	:= fa070Juros(Max(SE1->E1_MOEDA,1))
			aC[nLin][nPosJurosC] 	:= aC[nLin][nPosJuros]
			aC[nLin][nPosVA]		:= Iif(lExistVa,FValAcess(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_NATUREZ, /*lBaixados*/,/*cCodVa*/,"R",dDatabase),0)

			If ( cMvJurTipo == "L" .OR. lMulLoj ) .AND. !( (c_Alias)->E1_TIPO $ (MVRECANT+"/"+MV_CRNEG) )
				If lLojxRMul
					aC[nLin][nPosMulta] 	:=  LojxRMul( , , ,SE1->E1_SALDO, SE1->E1_ACRESC, SE1->E1_VENCREA, dDataBase , , SE1->E1_MULTA, ,;
		  									SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA, "SE1", .T.)
		  			aC[nLin][nPosMultaC] 	:=  aC[nLin][nPosMulta]
		  		EndIf
			EndIf
	    EndIf

		//Monta array de controle de alteracoes...
		AAdd(aLinSE1_Ori,{aC[nLin][1],aC[nLin][2],aC[nLin][3]})
	EndIf
Endif

Return Nil


Static Function ValAltArray(aArrayPanel,aArrayPanOri,aArrayAtu,aArrayOri,cCliOri)

Local lRet := .F.
Local nI   := 0
Local nPosOri	:= 0
Local nPosCod  :=	Ascan(aCposSA1,{|x| Alltrim(x)=="A1_COD"})
Local nPosLoj	:=	Ascan(aCposSA1,{|x| Alltrim(x)=="A1_LOJA"})
//O Array esta vazio e ainda nao valorizado...
If Len(aArrayPanel)==1 .And. Empty(aArrayPanel[1][2])
	lRet     := .T.
	cCliOri  := cCliente+cLoja
	//Monta de controle - Clientes...
	aArrayOri:= {}
	aEval(aLinSA1,{|x,y| AAdd(aArrayOri,{x[1],x[nPosCod],x[nPosLoj]})})
EndIf

//Verifica se foi alterado o cliente e a loja...
If !lRet .And. (cCliLoj_Ori <> cCliente+cLoja)
	lRet     := .T.
	cCliOri  := cCliente+cLoja
	//Monta de controle - Clientes...
	aArrayOri:= {}
	aEval(aLinSA1,{|x,y| AAdd(aArrayOri,{x[1],x[nPosCod],x[nPosLoj]})})
EndIf

//Verifica se existiu alguma alteracao no array...
If !lRet
	For nI := 1 To Len(aArrayOri)
		If (nPosOri	:=	AScan(aArrayAtu, {|x| x[nPosCod]+x[nPosLoj]==aArrayOri[nI][2]+aArrayOri[nI][3]}))==0 .Or.;
			aArrayAtu[nPosOri][01] != aArrayOri[nI][01]
			lRet := .T.
			//Monta de controle - Clientes...
			aArrayOri   := {}
			aEval(aLinSA1,{|x,y| AAdd(aArrayOri,{x[1],x[nPosCod],x[nPosLoj]})})
			aArrayPanOri:= {}
			Exit
		Endif
	Next nI
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFa087Ser  ณ Autor ณ Gilson da Silva       ณ Data ณ28.05.03  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Achoice para numero e serie do Recibo vindo do SX5         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ FINA087A                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa087Ser(cSerie,cRecibo)

Local aSerRec	:= {}
Local nOpcA    := 0
Local cNewRec	:=	'000001'
Local aAreaSEL	:=	{}

DbSelectArea("SX5")
DbSetOrder(1)
If DbSeek( xFilial("SX5")+"RN"+cSerie )
	AADD( aSerRec,{ Padr( X5_CHAVE, 3 ), StrZero( Val( X5Descri() ),TamSX3("EL_RECIBO")[1] ) } )
	cRecibo := aSerRec[1,2]
	cSerie  := aSerRec[1,1]
	nOpcA   := 1
Else
	If Empty(cSerie)
		aAreaSEL	:=	SEL->(GetArea())
		SEL->(DbSetOrder(8))
		SEL->(MsSeek(xFilial()+cSerie+'zzzzzz'))
		SEL->(DbSkip(-1))
		If SEL->EL_FILIAL+SEL->EL_SERIE==xFilial('SEL')+cSerie
			cNewRec	:=	Soma1(SEL->EL_RECIBO)
		Endif
		RestArea(aAreaSEL)
		RecLock('SX5',.T.)
		Replace X5_FILIAL		With xFilial('SX5')
		Replace X5_TABELA 	With 'RN'
		Replace X5_DESCRI  	With cNewRec
		Replace X5_DESCENG 	With cNewRec
		Replace X5_DESCSPA 	With cNewRec
		MsUnLock()
		AADD( aSerRec,{ Padr( X5_CHAVE, 3 ), StrZero( Val( X5Descri() ),TamSX3("EL_RECIBO")[1] ) } )
		cRecibo := aSerRec[1,2]
		cSerie  := aSerRec[1,1]
		nOpcA   := 1
	Else
		MsgStop(STR0119)
	   Return (.F.)
	Endif
EnDIf

Return { cSerie, cRecibo }
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณF087AGrvTx  บAutor  ณCristiano Denardi   บ Data ณ22.01.2004 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณGrava taxa da Moeda em SEL para qdo existirem campos        บฑฑ
ฑฑบDesc.     ณcorrespondentes ( da moeda 2 ate n informada)               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA087A                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F087AGrvTx( aTx )

Local nTx := 0

For nTx := 2 To Len(aTx)
	If ( SEL->(FieldPos("EL_TXMOE"+StrZero(nTx,2))) > 0 )
		SEL->&("EL_TXMOE"+StrZero(nTx,2)) := aTx[nTx]
	Endif
Next nTx

Return NIL
///////////////////////////////////////////////////////
//                                                   //
//    |  |       ---------------------------------   //
//   -    -      DAQUI PARA BAIXO ESTARAO            //
//   \    /      OS FONTES DO CONFIGURADOR           //
//    \  /       DOS CAMPOS DO BROWSE PARA RECIBOS   //
//     \/                                            //
//                                                   //
///////////////////////////////////////////////////////

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A087aProf()  ณAutor ณCristiano Denardi     ณDataณ 19.08.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Retorna Array contendo lista de campos gravados no Profile ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static FUNCTION A087aProf(cAlias)

Local aCposProfile 	:= {}
Local nTamLin		:= 10
Local cMemoPro		:= ""
Local nTamMemo		:= 0
Local nA			:= 0
Local cAliasBM		:= ""


cMemoPro := RetProfDef(cUserName,cFunName,cProfChave,cAlias)
nTamMemo := MLCount(cMemoPro,nTamLin)


For nA := 1 to nTamMemo
	Aadd( aCposProfile, Alltrim(MemoLine(cMemoPro,nTamLin,nA)) )
Next nA

///////////////////////////////////////////////////
// Rastreia aCpos para retirar campos do tipo MEMO
// Necessario ser desta forma, devido ao ponto de
//   entrada do usuario, que pode criar a aCols com
//   campo tipo MEMO
cAliasBM := Alias()
DbSelectArea( "SX3" )
DbSetOrder(2)
For nA := 1 to Len(aCposProfile)
  	If nA <= Len(aCposProfile)
		DbSeek( Alltrim(aCposProfile[nA]) )
		If ( X3_TIPO = "M" )
			Adel( aCposProfile, nA )
			Asize( aCposProfile, Len(aCposProfile)-1 )
		Endif
	EndIf
Next nA
SX3->(DbSetOrder(1))
DbSelectArea( cAliasBM )

RETURN( aCposProfile )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A087aCFG()   ณAutor ณCristiano Denardi     ณDataณ 19.08.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Configurador da ordem das colunas de recibo no Profile     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION A087aCFG()

Local	oFolder, oGet1, oGet2
Local aTitles 		:= {STR0018,STR0120} //"Cliente"###"Titulo"
Local	aPages  		:= Aclone(aTitles)
Local aTamFolder		:= {}
Local	lConfirm		:= .F.
Local aButtons		:= {}
Local cAlAnt			:= Alias()

Private oDlg
Private lCancel			:= .F.
Private cFunName  		:= "FINA087A"
Private cProfChave		:= "FINA087A01"
Private cAliasSA1 		:= "SA1"
Private cAliasSE1 		:= "SE1"
Private cAlias			:= ""
Private aCposCliente	:= {}
Private aCposTMPCli		:= {}
Private aCposTitulo		:= {}
Private aCposTMPTit		:= {}
Private aCols           := {}
Private aHeader 		:= {}

////////////////
// Monta aHeader
Aadd(aHeader,{""     ,"CHECKBOL","@BMP"    , 07, 00, , ,"C", ,"V", , , , "V", , , })
Aadd(aHeader,{""     ,"CHECK"   ,"@BMP"    , 05, 00, , ,"C", ,"V", , , , "V", , , })
Aadd(aHeader,{STR0137,"ORDEM"   ,"@E 9,999", 04, 00, , ,"N", ,"V", , , , "A", , , }) //"Ordem"
Aadd(aHeader,{STR0138,"NOMCAMPO", ""       , 12, 00, , ,"C", ,"V", , , , "V", , , }) //"Nome Campo"
Aadd(aHeader,{STR0139,"CAMPO"   , ""       , 10, 00, , ,"C", ,"V", , , , "V", , , }) //"Campo"


//////////////////////
// Campos Obrigatorios
aCposTMPCli := { 	"A1_COD"    , "A1_LOJA"   , "A1_NOME"   , "A1_CGC"   , "A1_CONTATO",	;
					"A1_TEL"    , "A1_NATUREZ"                								;
			   }
aCposTMPTit := {	"E1_PREFIXO", "E1_NUM"	  , "E1_PARCELA","E1_TIPO"	 , "E1_EMISSAO", 	;
		   			"E1_MOEDA"	, "E1_VALOR"  , "E1_SALDO"	,"E1_DESCONT", "E1_JUROS"  , 	;
					"E1_MULTA" 	, "E1_VENCREA" 												;
			   }


// Tela
DEFINE MSDIALOG oDlg TITLE STR0121 FROM 0,0 TO 285,620 OF oMainWnd PIXEL //"Configurador de ordem e campos para browse de Recibos"

	aTamFolder := {014,002,oDlg:nHeight-5,129}
	oFolder    := TFolder():New(aTamFolder[1],aTamFolder[2],aTitles,aPages,oDlg,,,,.T.,.F.,aTamFolder[3],aTamFolder[4])
	oFolder:bSetOption :={|nAt| nGot:=nAt,A087CFGfol(@oFolder,nGot,@oGet1,@oGet2) }

	// Alimenta pastas com os campos conforme Profile do Usuario
	A087aCFGCo(cAliasSA1,cAliasSE1)

	// Monta Tela
	nGetd := GD_UPDATE

	aCols :=  Aclone(aCposCliente)
	oGet1 := MsNewGetDados():New(0, 0, oFolder:aDialogs[1]:nClientHeight/2, oFolder:aDialogs[1]:nClientWidth/2,nGetd,,,,,,9999,,,,oFolder:aDialogs[1],aHeader,aCols)
 	oGet1:oBrowse:bEditCol   := {|| A087CFGOrd(oGet1:oBrowse:nAt,@oGet1,.T.) }
 	oGet1:oBrowse:blDblClick := {|| If( oGet1:oBrowse:nColPos == 3 , A087CFGOrd(oGet1:oBrowse:nAt,@oGet1,.F.), A087CFGbmp(oGet1:oBrowse:nAt,@oGet1) ) }

	aCols :=  Aclone(aCposTitulo)
	oGet2 := MsNewGetDados():New(0, 0, oFolder:aDialogs[2]:nClientHeight/2, oFolder:aDialogs[2]:nClientWidth/2,nGetd,,,,,,9999,,,,oFolder:aDialogs[2],aHeader,aCols)
 	oGet2:oBrowse:bEditCol   := {|| A087CFGOrd(oGet2:oBrowse:nAt,@oGet2,.T.) }
 	oGet2:oBrowse:blDblClick := {|| If( oGet2:oBrowse:nColPos == 3 , A087CFGOrd(oGet2:oBrowse:nAt,@oGet2,.F.), A087CFGbmp(oGet2:oBrowse:nAt,@oGet2) ) }

	Do Case
		Case oFolder:aDialogs[1]:lVisible // Folder 1 Ativo (Cliente)
			aCols :=  Aclone(aCposCliente)
		Case oFolder:aDialogs[2]:lVisible // Folder 2 Ativo (Titulo)
			aCols :=  Aclone(aCposTitulo)
	Endcase

	// Botoes
	Aadd( aButtons, {"BMPINCLUIR",{ || A087CFGlst(@oFolder,@oGet1,@oGet2)		},STR0122,STR0146} ) //"Refaz lista de campos."###"Refaz"
	Aadd( aButtons, {"SDUPROP",{ || A087CFGleg()                        		},STR0129} ) //"Legenda"
	Aadd( aButtons, {"CHECKED"   ,{ || A087CFGsel(@oFolder,@oGet1,@oGet2,1)	},STR0135,STR0147} ) //"Todos campos selecionados"###"Td.Cp.Sel"
	Aadd( aButtons, {"UNCHECKED" ,{ || A087CFGsel(@oFolder,@oGet1,@oGet2,2)	},STR0136,STR0148} ) //"Todos campos nao selecionados"###"Td.Cp.N.Sel"

If IsPanelFin()
	ACTIVATE MSDIALOG oDlg ON INIT ( FAMYBAR( oDlg,{|| lConfirm:=.T.,oDlg:End()} , {|| If(MsgYesNo(STR0123),oDlg:End(),) },aButtons )) CENTERED //"Deseja cancelar?"
Else
	ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar( oDlg,{|| lConfirm:=.T.,oDlg:End()} , {|| If(MsgYesNo(STR0123),oDlg:End(),) }, , aButtons )) CENTERED //"Deseja cancelar?"
Endif

// Grava em Profile
If lConfirm
	A087CFGgrv(oGet1,oGet2)
EndIf

DbSelectArea( cAlAnt )

RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A087aCFGCo() ณAutor ณCristiano Denardi     ณDataณ 19.08.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Verifica Profile e monta lista de campos                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static FUNCTION A087aCFGCo(cAliasSA1,cAliasSE1)

	Local aCposTMP 	:= {} // Campos obrigatorios, usuario nao pode deselecionar

	// CLIENTE
	aCposTMP := Aclone( aCposTMPCli )
	If FindProfDef( cUserName, cFunName, cProfChave, cAliasSA1 )
		// Resgata a lista do profile e mescla com campos de SX3
		A087aCFGPR(cAliasSA1,aCposTMP,"aCposCliente")
	Else
		// Cria Array com Lista nova de campos para Cliente
		A087aCFGNR(cAliasSA1,aCposTMP,"aCposCliente")
	Endif

	// TITULO
	aCposTMP := Aclone( aCposTMPTit )
	If FindProfDef( cUserName, cFunName, cProfChave, cAliasSE1 )
		// Resgata a lista do profile e mescla com campos de SX3
		A087aCFGPR(cAliasSE1,aCposTMP,"aCposTitulo")
	Else
		// Cria Array com Lista nova de campos para Titulo
		A087aCFGNR(cAliasSE1,aCposTMP,"aCposTitulo")
	Endif

RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A087aCFGPR() ณAutor ณCristiano Denardi     ณDataณ 19.08.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Resgata a lista do profile e mescla com campos de SX3      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static FUNCTION A087aCFGPR(c_alias,aCposTMP,cNomeArray)

Local aCposPro	:= {} // Campos que estao gravados no Profile
Local nTamLin	:= 10
Local cAliasAnt := Alias()
Local nOrdem	:= 0
Local lEnable	:= .F.
Local cBMP      := ""
Local cBMPBOL   := ""
Local cMemoProf	:= ""
Local nTamMemo	:= 0
Local nA		:= 0

cMemoProf := RetProfDef(cUserName,cFunName,cProfChave,c_alias)
nTamMemo  := MLCount(cMemoProf,nTamLin)

// Cria aCposPro
For nA := 1 to nTamMemo
	Aadd( aCposPro, Alltrim(MemoLine(cMemoProf,nTamLin,nA)) )
Next nA


// Pega a Lista de Campos de SX3
	DbSelectArea("SX3")
	DbSetOrder(2) // X3_CAMPO

	// Rastreia aCposPro
	For nA := 1 to nTamMemo

		nOrdem++

		DbSeek( Alltrim(aCposPro[nA]), .F. )

		lEnable := If( (AScan(aCposTMP,Alltrim(aCposPro[nA]))==0), .T., .F. )

		If lEnable
		    cBMPBOL	:= "ENABLE"
			cBMP	:= "LBTIK"
		Else
			cBMPBOL	:= "DISABLE"
			cBMP	:= "LBTIK"
		Endif

		Aadd(&cNomeArray,{cBMPBOL,cBMP,nOrdem,RetTitle(X3_CAMPO),X3_CAMPO,.F.})
	Next nA

	cBMPBOL	:= "ENABLE"
	cBMP	:= "LBNO"

	// Mescla com campos do SX3
	DbSetOrder(1) // X3_ARQUIVO + X3_ORDEM
	DbSeek(c_Alias,.F.)
	Do While !EOF() .And. X3_ARQUIVO == Alltrim(c_Alias)
		If ( x3uso(X3_USADO) ) .And. ( cNivel >= X3_NIVEL ) .And. ( AScan(aCposPro,Alltrim(X3_CAMPO))==0 )
			nOrdem++
			AAdd(&cNomeArray,{cBMPBOL,cBMP,nOrdem,RetTitle(X3_CAMPO),X3_CAMPO,.F.})
		Endif
		DbSkip()
	Enddo

DbSelectArea(cAliasAnt)

RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A087aCFGNR() ณAutor ณCristiano Denardi     ณDataณ 19.08.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cria a lista nova de campos                                ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static FUNCTION A087aCFGNR(c_alias,aCposTMP,cNomeArray)

Local cAliasAnt := Alias()
Local nOrdem	:= 0
Local lEnable	:= .F.
Local cBMP      := ""

// Pega a Lista de Campos de SX3
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek(c_Alias,.F.)
Do While !EOF() .And. X3_ARQUIVO == Alltrim(c_Alias)
	If ( x3uso(X3_USADO) ) .And. ( cNivel >= X3_NIVEL )

		nOrdem++

		lEnable := If((AScan(aCposTMP,Alltrim(X3_CAMPO))==0),.T.,.F.)

		cBMP	:= "LBTIK"

		If lEnable
			cBMPBOL	:= "ENABLE"
		Else
			cBMPBOL	:= "DISABLE"
		Endif

		AAdd(&cNomeArray,{cBMPBOL,cBMP,nOrdem,RetTitle(X3_CAMPO),X3_CAMPO,.F.})
	Endif
	DbSkip()
Enddo

DbSelectArea(cAliasAnt)

RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A087CFGlst() ณAutor ณCristiano Denardi     ณDataณ 19.08.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Desconsidera a lista atual e restaura a config. inicial    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static FUNCTION A087CFGlst(oFolder,oGet1,oGet2)

Local aCposTMP		:= {}
Local cNomeArray	:= ""
Local c_Alias		:= ""
Local cAliasAnt 	:= Alias()
Local nOrdem		:= 0
Local lEnable		:= .F.
Local cBMP      	:= ""
Local nA			:= 0
Local aFolders		:= {}
Local lRefaz		:= .F.

If MsgYesNo(STR0124) //"Deseja refazer a lista de campos para esta pasta?"
	lRefaz := .T.
Endif

If lRefaz

	// Pastas
	Aadd(aFolders, {"SA1","aCposCliente","aCposTMPCli"} )
	Aadd(aFolders, {"SE1","aCposTitulo" ,"aCposTMPTit"} )

	Do Case
		Case ( oFolder:aDialogs[1]:lVisible )
			aCposCliente 	:= {}
			nA 				:= 1

		Case ( oFolder:aDialogs[2]:lVisible )
			aCposTitulo := {}
			nA 			:= 2
	EndCase

	c_Alias		:= aFolders[nA][1]
	cNomeArray	:= aFolders[nA][2]
	aCposTMP 	:= Aclone( &(aFolders[nA][3]) )

	// Pega a Lista de Campos de SX3
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(c_Alias,.F.)
	Do While !EOF() .And. X3_ARQUIVO == Alltrim(c_Alias)
		If ( x3uso(X3_USADO) ) .And. ( cNivel >= X3_NIVEL )

			nOrdem++

			lEnable := If((AScan(aCposTMP,Alltrim(X3_CAMPO))==0),.T.,.F.)

			If lEnable
				cBMPBOL	:= "ENABLE"
				cBMP	:= "LBTIK"
			Else
				cBMPBOL	:= "DISABLE"
				cBMP	:= "LBTIK"
			Endif

			AAdd(&cNomeArray,{cBMPBOL,cBMP,nOrdem,RetTitle(X3_CAMPO),X3_CAMPO,.F.})
		Endif
		DbSkip()
	Enddo

	Do Case
		Case ( oFolder:aDialogs[1]:lVisible )
			oGet1:aCols := Aclone( aCposCliente )
			oGet1:oBrowse:Refresh()
			oGet1:ForceRefresh()

		Case ( oFolder:aDialogs[2]:lVisible )
			oGet2:aCols := Aclone( aCposTitulo )
			oGet2:oBrowse:Refresh()
			oGet2:ForceRefresh()
	EndCase

	oDlg:Refresh()

	DbSelectArea(cAliasAnt)

Endif

RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A087CFGbmp() ณAutor ณCristiano Denardi     ณDataณ 19.08.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Efetua a troca do BMP de aCOls                             ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static Function A087CFGbmp(nLin,oGet)


If ( oGet:aCols[nLin][1] = "ENABLE" )
	If     ( oGet:aCols[nLin][2] = "LBTIK" )
		oGet:aCols[nLin][2] := "LBNO"
	ElseIf ( oGet:aCols[nLin][2] = "LBNO" )
		oGet:aCols[nLin][2] := "LBTIK"
	Endif
Endif

RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A087CFGsel() ณAutor ณCristiano Denardi     ณDataณ 19.08.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Troca a selecao de campos para NAO SELECIONADOS            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static Function A087CFGsel(oFolder,oGet1,oGet2,nOpcBMP)

Local nFor 	:= 0
Local nA	:= 0

Do Case
	Case ( oFolder:aDialogs[1]:lVisible )
		nFor := Len(oGet1:aCols)
		For nA := 1 to nFor
			If ( oGet1:aCols[nA][1] = "ENABLE" )
				If     ( nOpcBMP = 1 )
					oGet1:aCols[nA][2] := "LBTIK"
				ElseIf ( nOpcBMP = 2 )
					oGet1:aCols[nA][2] := "LBNO"
				Endif
			Endif
		Next nA

	Case ( oFolder:aDialogs[2]:lVisible )
		nFor := Len(oGet2:aCols)
		For nA := 1 to nFor
			If ( oGet2:aCols[nA][1] == "ENABLE" )
				If     ( nOpcBMP = 1 )
					oGet2:aCols[nA][2] := "LBTIK"
				ElseIf ( nOpcBMP = 2 )
					oGet2:aCols[nA][2] := "LBNO"
				Endif
			Endif
		Next nA
EndCase

RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A087CFGOrd() ณAutor ณCristiano Denardi     ณDataณ 19.08.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Organiza aCols qdo e trocado a ordem de um campo           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static Function A087CFGOrd(nLin,oGet,lVld)

Local nPosNovo 	:= 0
Local nValNovo 	:= 0
Local nValAnti 	:= 0
Local nValMaior := Len(oGet:aCols)
Local nFor		:= 0
Local nA		:= 0
Local nOrdem	:= 0

If lVld
	nValNovo := M->ORDEM
	nValAnti := nLin
Else
	nValAnti := oGet:aCols[nLin][3]
	oGet:EditCell()
	nValNovo := oGet:aCols[nLin][3]
Endif

If ( nValNovo <= nValMaior ) .And. ( nValNovo > 0 )

	// Somente processa se valor for trocado
	If ( nValAnti <> nValNovo )

		If lVld
			nPosNovo := nValNovo
		Else
			nPosNovo := Ascan( oGet:aCols, {|aVal| aVal[3] == nValNovo } )
		Endif

		If ( nLin < nPosNovo )
			nFor := nPosNovo
			nLin++
			For nA := nLin to nFor
				nOrdem := nA
				nOrdem--
				oGet:aCols[nA][3] := nOrdem
			Next nA
		Else
			nFor := ( (nLin-nPosNovo) + nPosNovo ) - 1
			For nA := nPosNovo to nFor
				nOrdem := nA
				nOrdem++
				oGet:aCols[nA][3] := nOrdem
			Next nA
		Endif

		oGet:aCols := Asort( oGet:aCols,,, { |x,y| x[3] < y[3] } )

	Endif

Else
	oGet:aCols[nLin][3] := nValAnti
	If ( nValNovo <= 0 )
		Alert(STR0125) //"Valor nao pode ser menor ou igual a Zero"
	Else
		Alert(STR0126) //"Valor nao pode ser maior do que o numero maximo de campos"
	Endif
Endif

oGet:oBrowse:Refresh()
oGet:ForceRefresh()
oDlg:Refresh()

RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A087CFGgrv() ณAutor ณCristiano Denardi     ณDataณ 19.08.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Grava lista de campos no profile do usuario corrente	      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static Function A087CFGgrv(oGet1,oGet2)

Local cList := ""
Local nA	:= 0

// Atualiza Arrays auxiliares
aCposCliente := Aclone(oGet1:aCols)
aCposTitulo  := Aclone(oGet2:aCols)

// Grava Cliente
cList := ""
For nA := 1 to Len(aCposCliente)
	If ( aCposCliente[nA][2] == "LBTIK" )
		cList := cList + Alltrim( aCposCliente[nA][5] ) + _PL_
	Endif
Next nA
If FindProfDef( cUserName, cFunName, cProfChave, cAliasSA1 )
	WriteProfDef( cUserName, cFunName, cProfChave, cAliasSA1, cUserName, cFunName, cProfChave, cAliasSA1, cList )
Else
	WriteNewProf( cUserName, cFunName, cProfChave, cAliasSA1, cList )
Endif

// Grava Titulo
cList := ""
For nA := 1 to Len(aCposTitulo)
	If ( aCposTitulo[nA][2] == "LBTIK" )
		cList := cList + Alltrim( aCposTitulo[nA][5] ) + _PL_
	Endif
Next nA
If FindProfDef( cUserName, cFunName, cProfChave, cAliasSE1 )
	WriteProfDef( cUserName, cFunName, cProfChave, cAliasSE1, cUserName, cFunName, cProfChave, cAliasSE1, cList )
Else
	WriteNewProf( cUserName, cFunName, cProfChave, cAliasSE1, cList )
Endif

MsgInfo(STR0127) //"As alteracoes gravadas, so serao efetivadas na proxima abertura da rotina de Recibos!"

RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A087CFGfol() ณAutor ณCristiano Denardi     ณDataณ 19.08.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Trata a troca de folder, fazendo a troca do valor de aCols ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static Function A087CFGfol(oFolder,nGot,oGet1,oGet2)

//   nGot							-> Pasta que foi clicada   //
//   oFolder:aDialogs[n]:lVisible 	-> Ultima pasta ativa      //
//                                                             //

// Guarda valor de Arrays de auxilio do aCols
Do Case
	Case ( oFolder:aDialogs[1]:lVisible )
		aCposCliente := Aclone(oGet1:aCols)

	Case ( oFolder:aDialogs[2]:lVisible )
		aCposTitulo := Aclone(oGet2:aCols)
EndCase

// Ajusta aCols
Do Case
	Case ( nGot = 1 )
		oGet1:aCols := Aclone(aCposCliente)
	Case ( nGot = 2 )
		oGet2:aCols := Aclone(aCposTitulo)
EndCase

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A087CFGleg() ณAutor ณCristiano Denardi     ณDataณ 19.08.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Legenda                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static Function A087CFGleg()

BrwLegenda(STR0129, STR0130,{	{"DISABLE", STR0131} ,; //"Legenda"###"Status"###" Campo obrigatorio"
								{"ENABLE" , STR0132} ,; //" Campo opcional"
								{""		  , " ------------------------ "} ,;
								{"LBTIK"  , STR0133} ,; //" Selecionado"
								{"LBNO"	  , STR0134}  ; //" Nao selecionado"
							} )

RETURN Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ F087Get      ณAutor ณJulio Ceasr           ณDataณ 08.07.04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cria um get com os parametros informados.                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F087Get(aInfGet,uVarRet,oVarRet)

// Reinicializa a variavel.
If aInfGet[9] <> Nil
	uVarRet := aInfGet[9]
EndIf

@ aInfGet[1],aInfGet[2] MSGET oVarRet Var uVarRet SIZE aInfGet[3],aInfGet[4] OF &(aInfGet[5]) PIXEL Valid &(aInfGet[6]) When &(aInfGet[7]) Picture aInfGet[8] HasButton

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ Fa087aRet()  ณAutor ณSabrina Passini SoaresณDataณ 17.06.04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Funcao que verifica se ha retencoes recebidas e chama a    ณฑฑ
ฑฑณ          ณ montagem do panel correspondente para rateio dos valores   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fa087aRet()
Local lRet   	:= .T.
Local nI, nX	:= 1
Local nPos	 	:= 0
Local nNumRet	:= 0
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ StrTokArr: Esta funcao pega uma string com separadores e faz virar um array ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local aDesc  := StrTokArr(oGetsel:aInfo[AScan(aCposSEL,"EL_TIPODOC")][2], ';')

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Carrega array com os titulos (NF) selecionados para distribuir as retencoes ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local nPosPref  := Ascan( aCposSE1, "E1_PREFIXO")
Local nPosNum   := Ascan( aCposSE1, "E1_NUM")
Local nPosParc  := Ascan( aCposSE1, "E1_PARCELA")
Local nPosTipo  := Ascan( aCposSE1, "E1_TIPO")
Local nPosCli   := Ascan( aCposSE1, "E1_CLIENTE")
Local nPosLoja  := Ascan( aCposSE1, "E1_LOJA")
Local lSerie2   := .F.
Local lRatImp	:= SuperGetMV("MV_RATIMP",.F.,"0")=="0"
Local aCabRet   := {}
Local aRetTmp   := {}
Local cTabSF    := ""
Local cPrefSF   := ""
Local cSerie2   := ""
Private aLinTit := {}
aLinRet :={}

Posicione("SX3",2,"E1_PREFIXO","X3_TITULO")
Aadd( aCabRet, { SX3->(X3Titulo()), SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL} )
Posicione("SX3",2,"E1_NUM","X3_TITULO")
Aadd( aCabRet, { SX3->(X3Titulo()), SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL} )
Posicione("SX3",2,"E1_PARCELA","X3_TITULO")
Aadd( aCabRet, { SX3->(X3Titulo()), SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL} )
Posicione("SX3",2,"E1_TIPO","X3_TITULO")
Aadd( aCabRet, { SX3->(X3Titulo()), SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL} )
Posicione("SX3",2,"E1_VALOR","X3_TITULO")
Aadd( aCabRet, { SX3->(X3Titulo()), SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL} )
If cPaisLoc = "PER"
	If SF2->(ColumnPos("F2_SERIE2")) > 0  .And. SF1->(ColumnPos("F1_SERIE2"))
		Posicione("SX3",2,"F2_SERIE2","X3_TITULO")
		Aadd( aCabRet, { SX3->(X3Titulo()), SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL} )
		lSerie2 := .T.
	EndIf
EndIf

For nX:=1 To Len( aLinSE1 )
	If aLinSE1[nX][1]== 1 // Titulo selecionado
		cTabSF := ""
		If Alltrim(aLinSE1[nX][nPosTipo]) == "NCC" .AND. lSerie2
			cTabSF  := "SF1"
			cPrefSF := "F1_"
		ElseIf Alltrim(aLinSE1[nX][nPosTipo]) $ "NF|NDC" .AND. lSerie2
			cTabSF  := "SF2"
			cPrefSF := "F2_"
		EndIf
		If cPaisLoc $ "ARG|COS|PAR" .Or. (!Alltrim(aLinSE1[nX][nPosTipo]) $ MV_CRNEG .Or. Alltrim(aLinSE1[nX][nPosTipo])=="CC") .OR. (cPaisLoc == "PER" .AND.  Alltrim(aLinSE1[nX][nPosTipo])=="NCC")
			If lSerie2 .And. !Empty(cTabSF)
				cSerie2 := Posicione(cTabSF,1,xFilial(cTabSF)+aLinSE1[nX][nPosNum]+aLinSE1[nX][nPosPref]+aLinSE1[nX][nPosCli]+aLinSE1[nX][nPosLoja],cPrefSF+"SERIE2")
			Else
				cSerie2 := ""
   			EndIf
   			Aadd( aLinTit, { aLinSE1[nX][nPosPref], aLinSE1[nX][nPosNum], aLinSE1[nX][nPosParc], ;
   				aLinSE1[nX][nPosTipo], 0, "", "", cSerie2 } )
	   EndIf
	EndIf
Next

For nI:=1 To Len(aCols)
	If  !aCols[nI][Len(aHeader)+1] .And.  ((cPaisLoc $ "ARG|COS" .And. ( aCols[nI][AScan(aCposSEL,"EL_TIPODOC")] $ 'RB|RS|RL|RI|RG' )) ;
		.Or. (cPaisLoc == "PER" .And. ( aCols[nI][AScan(aCposSEL,"EL_TIPODOC")] $ 'RI' )) .Or. (cPaisLoc == "PAR" .And. ( aCols[nI][AScan(aCposSEL,"EL_TIPODOC")] $ 'RI|RR' )))
		If Len(aLinTit) > 0 .And.                        ((cPaisLoc $ "ARG|COS|PAR|" .And.aCols[nI][AScan(aCposSEL,"EL_TIPODOC")] $ "RB|RI|RS|RG|RR" ) .Or. ( cPaisLoc == "PER" .And. aCols[nI][AScan(aCposSEL,"EL_TIPODOC")] $ 'RI' ))
			nNumRet++
			If Len( aLinRet ) >= nNumRet
				aRetTmp := aClone(aLinRet[nNumRet])
			Else
				aRetTmp := aClone(aLinTit)
				For nX := 1 to Len( aLinTit)
					aRetTmp[nX][6] := aCols[nI][AScan(aCposSEL,"EL_NUMERO")]  //numero da retencao (nrocert)
					aRetTmp[nX][7] := aCols[nI][AScan(aCposSEL,"EL_TIPODOC")]  //tipo da retencao
					If Len(aLinTit) == 1 .And. (cPaisLoc == "PER" .Or. (cPaisLoc $ "ARG|COS|PAR" .And. aCols[nI][AScan(aCposSEL,"EL_TIPODOC")] $ 'RS|RL|RI|RR' ))
						aRetTmp[nX][5]:= aCols[nI][AScan(aCposSEL,"EL_VALOR")]
					EndIf
				Next nX
		    EndIf
	    	nPos := Ascan(aDesc,{|x| AllTrim(aCols[nI][AScan(aCposSEL,"EL_TIPODOC")]) $ x})

			If Len(aLinTit)> 1  .Or. (cPaisLoc $ "ARG|COS|PER|PAR" .And. (aCols[nI][AScan(aCposSEL,"EL_TIPODOC")] $ "RB|RI|RS|RG|RR|"))
				//Exibe a tela de rateio caso o parametro MV_RATIMP estiver configurado como "0"
				If cPaisLoc $ "ARG|COS"
					If (aCols[nI][AScan(aCposSEL,"EL_TIPODOC")] $ "RS|RL|RB|RI|RG") //.Or. (lRatImp .And. (aCols[nI][AScan(aCposSEL,"EL_TIPODOC")] $ "RI"))
						lRet := MostraRets( Subs( aDesc[nPos], At('=', aDesc[nPos])+1 ), aCols[nI][AScan(aCposSEL,"EL_VALOR")], aCols[nI][AScan(aCposSEL,"EL_NUMERO")], aCabRet, @aRetTmp,aCols[nI][AScan(aCposSEL,"EL_TIPODOC")] ,lRatImp)
					Else
						lRet := .T.
					Endif
				Elseif cPaisLoc == "PER"
					If (aCols[nI][AScan(aCposSEL,"EL_TIPODOC")] $ "RI")
						lRet := MostraRets( Subs( aDesc[nPos], At('=', aDesc[nPos])+1 ), aCols[nI][AScan(aCposSEL,"EL_VALOR")], aCols[nI][AScan(aCposSEL,"EL_NUMERO")], aCabRet, @aRetTmp,aCols[nI][AScan(aCposSEL,"EL_TIPODOC")] ,lRatImp)
					Else
						lRet := .T.
					Endif
				Elseif cPaisLoc == "PAR"
					If (aCols[nI][AScan(aCposSEL,"EL_TIPODOC")] $ "RI|RR")
						lRet := MostraRets( Subs( aDesc[nPos], At('=', aDesc[nPos])+1 ), aCols[nI][AScan(aCposSEL,"EL_VALOR")], aCols[nI][AScan(aCposSEL,"EL_NUMERO")], aCabRet, @aRetTmp,aCols[nI][AScan(aCposSEL,"EL_TIPODOC")],lRatImp,aCols[nI][AScan(aCposSEL,"EL_MOEDA")])
					Else
						lRet := .T.
					Endif
				Endif
			Else
	       		lRet := .T.
			Endif
		   If Len( aLinRet ) >= nNumRet
		    	aLinRet[nNumRet] := AClone(aRetTmp)
			Else
				Aadd( aLinRet, ACLone(aRetTmp)  )
			EndIf
    		If ( ! lRet )
				Exit
	    	EndIf
	   Else
	      Aviso(STR0149,STR0150,{STR0151}) // exibe mensagem que ha retencoes, porem nao foi selecionado nenhum item
	      lRet := .F.
	      Exit
	   EndIf
	EndIf
Next
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ MostraRets() ณAutor ณSabrina Passini SoaresณDataณ 18.06.04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Funcao que mostra os panel para digitacao dos rateios das  ณฑฑ
ฑฑณ          ณ retencoes recebidos pelos titulos selecionados             ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MostraRets( cRetText, nRetVal, cRetNum, aCab, aItRet,cRet ,lRatImp,nMoeda)
Local lRet			:= .T.
Local oDlgRet
Local oPanel
Local oPTop
Local oPCenter
Local oGTop
Local oGCenter
Local oBrw
Local oRetVal
Local oRetNum
Local cPict 		:= aCab[5][2]
Local nI
Local aHeaderRet	:= {}
Local aColsRet		:= {}
Local nX
Local nTipo
Local l087PRO		:= ExistBlock("F087PRO")
Local aRetCols		:= {}

Private oGetD

Default nMoeda := "1"

If Valtype(nMoeda) <> "C"
	nMoeda :=Alltrim((Str(nMoeda)))
EndIf


nRetVal:=Round(nRetVal,MsDecimais(Val(nMoeda)))

If cPaisLoc == "PAR"
	If !(Len(SFE->FE_RECIBO)==Len(SEL->EL_RECIBO))
		MsgInfo(STR0240,STR0241)
		Return .F.
	EndIf
EndIf
oDlgRecibo:readClientCoors(.T.)

DEFINE MSDIALOG oDlgRet TITLE cRetText FROM (oDlgRecibo:nTop+195), (oDlgRecibo:nLeft+270) TO oDlgRecibo:nBottom-50, oDlgRecibo:nRight-100 OF oDlgRecibo  PIXEL
DEFINE FONT oFnt NAME "Arial" SIZE 7,17
DEFINE FONT oFntB NAME "Arial" SIZE 7,17 BOLD

oPanel:=TPanel():New(001,001,,oDlgRet,,,,,,232,162,.F.,.F.)
oPanel:align:= CONTROL_ALIGN_ALLCLIENT
oPanel:NCLRPANE:= RGB(233,233,233) //13165800

oPTop:=TPanel():New(001,001,,oPanel,,,,,,200,040,.F.,.F.)
oPTop:align:= CONTROL_ALIGN_TOP
oPTop:NCLRPANE:= RGB(233,233,233) //13165800

@ 003, 001 GROUP oGTop TO 113, 116 OF oPTop PIXEL
oGTop:align:= CONTROL_ALIGN_ALLCLIENT

@ 005, 005 SAY STR0137 FONT oFntB SIZE 080, 010  PIXEL OF oGTop   // Certificado Num
@ 005, 065 SAY oRetNum VAR cRetNum FONT oFnt SIZE 080, 010 COLOR CLR_BLACK PIXEL OF oGTop
@ 005, 110 SAY STR0043 SIZE 080, 010 PIXEL OF oGTop   // Valor
@ 005, 135 GET oRetVal VAR nRetVal SIZE 080, 010 PICTURE cPict PIXEL OF oGTop READONLY

oPCenter:=TPanel():New(001,001,,oPanel,,,,,,200,050,.F.,.F.)
oPCenter:align:= CONTROL_ALIGN_ALLCLIENT
oPCenter:NCLRPANE:= RGB(233,233,233) //13165800

@ 003, 001 GROUP oGCenter TO 113, 116 OF oPCenter PIXEL
oGCenter:align:= CONTROL_ALIGN_ALLCLIENT

If (cPaisLoc $ "ARG|COS|PAR|PER")

	If lRatImp .And. cRet $ "RB"
		aCamposGet	:=	{"FE_SERIE","FE_NFISCAL","FE_PARCELA","E1_TIPO","FE_EST","FE_CFO","FE_VALBASE","FE_ALIQ","FE_RETENC"}
	Else
		If cRet $ "RB|RI" .and. cPaisLoc $ "ARG"
			aCamposGet	:=	{"FE_EST","FE_CFO","FE_VALBASE","FE_ALIQ","FE_RETENC"}
		ElseIf cRet $ "RS|RG"
			aCamposGet	:=	{"FE_EST","FE_CFO",Iif(cRet $ "RG","A2_AGREGAN","A2_CONCSUS"),"FE_VALBASE","FE_ALIQ","FE_RETENC"}
		ElseIf cRet $ "RI|RR" .and. cPaisLoc $ "PAR"
			aCamposGet	:=	{"FE_CFO","FE_VALBASE","FE_ALIQ","FE_RETENC","FE_NROCERT","E1_TIPO"}
		ElseIf cRet $ "RI" .and. cPaisLoc $ "PER"
			aCamposGet	:=	{"FE_SERIE","FE_NFISCAL","FE_PARCELA","E1_TIPO","FE_RETENC","FE_NROCERT","E1_TIPO","F2_SERIE2"}
		EndIf
	Endif
	DbSelectArea("SX3")
	DbSetOrder(2)
	For nX:=1 To Len(aCamposGet)
		DbSeek(aCamposGet[nX])
		AADD(aHeaderRet,{ TRIM(X3TITULO()), x3_campo, x3_picture,x3_tamanho, x3_decimal,x3_valid,x3_usado, x3_tipo, x3_F3, x3_context} )
	Next
	If cPaisLoc=="PER|PAR"
		aAlterGDa := {"FE_NFISCAL","FE_PARCELA","FE_RETENC"}
	Else
		aAlterGDa := {"FE_VALBASE","FE_ALIQ","FE_CFO","FE_EST","FE_RETENC","A2_AGREGAN","A2_CONCSUS"}
	EndIf
	nUsado	:=	Len(aCamposGet)
	aColsRet:={}
	If lRatImp .And. cRet $ "RB" //Rateio apenas para impostos provinciais
		For nX:= 1 To Len(aItRet)
			aadd(aColsRet,Array(nUsado+1))
			aColsRet[nX,nUsado+1]:=.F.
			aColsRet[nX,1]	:=	aItRet[nX,1]
			aColsRet[nX,2]	:=	aItRet[nX,2]
			aColsRet[nX,3]	:=	aItRet[nX,3]
			aColsRet[nX,4]	:=	aItRet[nX,4]
			For nI	:=	5 To Len(aHeaderRet)
				aColsRet[nX,nI]	:=	Criavar(aHeaderRet[nI,2],.F.)
			NExt
		Next
	ElseIf lRatImp .And. cRet $ "RI|RR" .and. cPaisLoc $ "PAR"
		For nX:= 1 To Len(aItRet)
		   	aadd(aColsRet,Array(nUsado+1))
			aColsRet[nX,nUsado+1]:=.F.
			aColsRet[nX,1]	:= Criavar(aHeaderRet[1,2],.F.)	//aItRet[nX,1]
			aColsRet[nX,2]	:= 0 	//	aItRet[nX,5]
			aColsRet[nX,3]	:= 0	//	aItRet[nX,3]
			aColsRet[nX,4]	:= 0 	//	aItRet[nX,4]
			aColsRet[nX,5]	:= cRetNum  	//	aItRet[nX,4]
			aColsRet[nX,6]	:= cRet  	//	aItRet[nX,4]
			For nI	:=	7 To Len(aHeaderRet)
				aColsRet[nX,nI]	:=	Criavar(aHeaderRet[nI,2],.F.)
			NExt
		Next
	ElseIf lRatImp .And. cRet $ "RI" .and. cPaisLoc $ "PER"
		For nX:= 1 To Len(aItRet)
		   	aadd(aColsRet,Array(nUsado+1))
			aColsRet[nX,nUsado+1]:=.F.
			aColsRet[nX,1]	:= aItRet[nX,1]//("FE_SERIE",.F.)
			aColsRet[nX,2]	:= aItRet[nX,2]//("FE_NFISCAL",.F.)
			aColsRet[nX,3]	:= aItRet[nX,3]//("FE_PARCELA",.F.)
			aColsRet[nX,4]	:= aItRet[nX,4]//("E1_TIPO",.F.)
			aColsRet[nX,5]	:= aItRet[nX,5]//0
			aColsRet[nX,6]	:= aItRet[nX,6]//("FE_NROCERT",.F.)
			aColsRet[nX,7]	:= aItRet[nX,7]//"RI"
			aColsRet[nX,8]	:= aItRet[nX,8]//"SERIE2"
			For nI := nUsado+1 To Len(aHeaderRet)
				aColsRet[nX,nI]	:=	Criavar(aHeaderRet[nI,2],.F.)
			NExt
		Next
	Else
		aadd(aColsRet,Array(nUsado+1))
		aColsRet[1,nUsado+1]:=.F.
		For nI	:=	1 To Len(aHeaderRet)
			aColsRet[1,nI]	:=	Criavar(aHeaderRet[nI,2],.F.)
		NExt
	Endif
	  If l087PRO
			aRetCols := aClone(ExecBlock('F087PRO',.F.,.F.,{aCols,aHeader,aColsRet,aHeaderRet,cRet}))
	     	If ValType(aRetCols) == "A" .And. Len(aRetCols) > 0
			  aColsRet := aClone(aRetCols)
	     	EndIf
	  EndIf
	oGetD:= MsNewGetDados():New(0/*nSuperior*/,0/*nEsquerda*/,100/*nInferior*/,100/*nDireita*/, GD_UPDATE,;
							"AllwaysTrue()"/*cLinOk*/,"AllwaysTrue()"/*cTudoOk*/,/*cIniCpos*/,aAlterGDa,/*nFreeze*/,/*nMax*/,IIf(lRatImp .And. cRet $ "RB",".F.",".T.")+".Or. A087aFillC(oGetd)"/*cFieldOk*/, /*cSuperDel*/,;
							/*cDelOk*/, oPCenter, aHeaderRet, aColsRet)
	oGetD:oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT
	nTipo	:=	2
Else
	oBrw := TcBrowse():New(01,01,500,600,,,,oPCenter,,,,,,,,,,,,.F.,,.T.,,.F.,,)
	oBrw:Align 	:= CONTROL_ALIGN_ALLCLIENT
	oBrw:bLDblClick:= { || DblClickBrow(oBrw, aItRet,,, cPict) }
	oBrw:SetArray(aItRet)

	oBrw:AddColumn(TCColumn():New(aCab[1][1],{|| aItRet[oBrw:nAt,1] }      ,,,,"LEFT",CalcFieldSize('C',aCab[1,3],aCab[1,4],aCab[1,2],aCab[1,1]),.F.,.F.,,,,.F.,))
	oBrw:AddColumn(TCColumn():New(aCab[2][1],{|| aItRet[oBrw:nAt,2] }      ,,,,"LEFT",CalcFieldSize('C',aCab[2,3],aCab[2,4],aCab[2,2],aCab[2,1]),.F.,.F.,,,,.F.,))
	oBrw:AddColumn(TCColumn():New(aCab[3][1],{|| aItRet[oBrw:nAt,3] }      ,,,,"LEFT",CalcFieldSize('C',aCab[3,3],aCab[3,4],aCab[3,2],aCab[3,1]),.F.,.F.,,,,.F.,))
	oBrw:AddColumn(TCColumn():New(aCab[4][1],{|| aItRet[oBrw:nAt,4] }      ,,,,"LEFT",CalcFieldSize('C',aCab[4,3],aCab[4,4],aCab[4,2],aCab[4,1]),.F.,.F.,,,,.F.,))
	oBrw:AddColumn(TCColumn():New(aCab[5][1],{|| Transform(aItRet[oBrw:nAt,5], cPict) },,,,"LEFT",CalcFieldSize('C',aCab[5,3],aCab[5,4],aCab[5,2],aCab[5,1]),.F.,.F.,,,,.F.,))
	nTipo	:=	1
Endif

ACTIVATE MSDIALOG oDlgRet ON INIT EnchoiceBar(oDlgRet, {||( If ( A87VldRet(aItRet, nRetVal,nTipo,oGetd), (lRet := .T.,If(cRet $ "RB|RI|RS|RG|RR|" , aItRet	:=	aClone(oGetD:aCols),Nil), oDlgRet:End()),.F.) )} , {||(lRet := .F., oDlgRet:End()) }) CENTERED

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณDblClickBrowบAutor  ณMicrosiga           บ Data ณ 03/24/11  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DblClickBrow(oBrw, aIt, nRow, nCol, cPict)
If ( oBrw:ColPos() == 5 )
	lEditCell(aIt, oBrw, cPict, nCol)
EndIf
Return

//----------------------------------------------------------------------------------------
/*/{Protheus.doc}A87VldRet
Valida็ใo Botใo OK - Tela MostraRets
@author Totvs
@since  26/06/2015
@version 12
/*/
//----------------------------------------------------------------------------------------
Static Function A87VldRet( aItems, nRetVal,nTipo,oGetd)
Local lRet 		:= .T.
Local nI  		:= 1
Local nTotal 	:= 0
Local nPosRet  	:=	0
Local nPosCFO  	:=	0
Local nPosEst  	:=	0
Local nPosAlq  	:=	0
Local nPosBas  	:=	0
Local nPosTipo 	:=	0
Local nTotalNC 	:=	0
Local nTotalNF	:= 	0

If nTipo == 1
	For nI := 1 To Len(aItems)
	    nTotal := nTotal + aItems[nI][5]
	Next
Else
	If cPaisLoc == "PAR"
		nPosCFO	:=	GdFieldPos("FE_CFO"	,oGetd:aHeader)
		nPosBas	:=	GdFieldPos("FE_VALBASE",oGetd:aHeader)
		nPosAlq	:=	GdFieldPos("FE_ALIQ" ,oGetd:aHeader)
		nPosRet	:=	GdFieldPos("FE_RETENC",oGetd:aHeader)
//		nPosNum	:=	cRetNum
	Else
	nPosRet	:=	GdFieldPos("FE_RETENC",oGetd:aHeader)
	nPosTipo:=	GdFieldPos("E1_TIPO",oGetd:aHeader)
	nPosCFO	:=	GdFieldPos("FE_CFO"	,oGetd:aHeader)
	nPosEst	:=	GdFieldPos("FE_EST"	,oGetd:aHeader)
	nPosAlq	:=	GdFieldPos("FE_ALIQ" ,oGetd:aHeader)
	nPosBas	:=	GdFieldPos("FE_VALBASE",oGetd:aHeader)
	EndIf
	If cPaisLoc == "PAR"
		For nI:=1 To Len(oGetd:aCols)
			If !oGetd:aCols[nI,Len(oGetd:aCols[nI])]
         	nTotal := nTotal + oGetd:aCols[nI,nPosRet] * IIf(nPosCFO>0 .And. oGetd:aCols[nI,nPosCFO]$MV_CRNEG+"|"+MVRECANT,-1,1)
			   	If oGetd:aCols[nI,nPosRet] <> 0 .And. ;
					(Empty(oGetd:aCols[nI,nPosCFO]) .Or. Empty(oGetd:aCols[nI,nPosBas]).Or. empty(oGetd:aCols[nI,nPosAlq]))
					Help("",1,"OBRIGAT")
					lRet	:=	.F.
					Exit
				Endif
			Endif
		Next
	ElseIf cPaisLoc == "PER"
		For nI:=1 To Len(oGetd:aCols)
			If !oGetd:aCols[nI,Len(oGetd:aCols[nI])]
         		If oGetd:aCols[nI,nPosTipo] == "NCC"
         			nTotalNC := nTotalNC + oGetd:aCols[nI,nPosRet] * IIf(nPosCFO>0 .And. oGetd:aCols[nI,nPosCFO]$MV_CRNEG+"|"+MVRECANT,-1,1)
         		Else
         		 	nTotalNF := nTotalNF + oGetd:aCols[nI,nPosRet] * IIf(nPosCFO>0 .And. oGetd:aCols[nI,nPosCFO]$MV_CRNEG+"|"+MVRECANT,-1,1)
         		EndIf
         		If oGetd:aCols[nI,nPosRet] <> 0 .and. Empty(oGetd:aCols[nI,nPosRet])
					Help("",1,"OBRIGAT")
					lRet	:=	.F.
					Exit
				Endif
			Endif
		Next
		nTotal := nTotalNF - nTotalNC
	Else
		For nI:=	1 To Len(oGetd:aCols)
			If !oGetd:aCols[nI,Len(oGetd:aCols[nI])]
	         nTotal := nTotal + oGetd:aCols[nI,nPosRet] * IIf(nPosTipo>0 .And. oGetd:aCols[nI,nPosTipo]$MV_CRNEG+"|"+MVRECANT,-1,1)
				If oGetd:aCols[nI,nPosRet] <> 0 .And. ;
					(Empty(oGetd:aCols[nI,nPosCFO]) .Or. Empty(oGetd:aCols[nI,nPosEST]).Or. empty(oGetd:aCols[nI,nPosBas]).Or.empty(oGetd:aCols[nI,nPosAlq]))
					Help("",1,"OBRIGAT")
					lRet	:=	.F.
					Exit
				Endif
			Endif
		Next
	EndIf
Endif
If lRet
If ( Round(nTotal,MsDecimais(oCBMOed:nAt)) > nRetVal )
	Aviso(STR0149,STR0152,{STR0151}) //'O valor digitado e maior que o valor da retencao'
		lRet	:=	.F.
  ElseIf ( Round(nTotal,MsDecimais(oCBMOed:nAt)) < nRetVal )
	Aviso(STR0149,STR0153,{STR0151})//'O valor digitado e menor que o valor da retencao'
		lRet	:=	.F.
	EndIf
Endif
Return lRet


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o	 ณFa087GrvIVA() ณ Autor ณ Paulo Augusto         ณ Data ณ 20/12/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Gravacao dos campos do Iva para o Mexico                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	 ณ Fa087GrvIVA()              								      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ FINA87a													      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function Fa087GrvIVA()

Local aArea      := GetArea()
LOCAL aAreaSE1   := SE1->( GetArea() )
LOCAL _ValorBx1  := 0
Local _ValorBx2  := 0
Local _ValorBx3  := 0
Local _ValorBx4  := 0
Local _ValorBx5  := 0
Local _ValorBx6  := 0
Local _PerBx     := 0
Local _PerDesc   := 0
Local _ValorDc1  := 0
Local _ValorDc2  := 0
Local _ValorDc3  := 0
Local _ValorDc4  := 0
Local _ValorDc5  := 0
Local _ValorDc6  := 0
//Local _nValPor1 := 0
LOCAL _BaseBx1  := 0
Local _BaseBx2  := 0
Local _BaseBx3  := 0
Local _BaseBx4  := 0
Local _BaseBx5  := 0
Local _BaseBx6  := 0
LOCAL _AliqBx1  := 0
Local _AliqBx2  := 0
Local _AliqBx3  := 0
Local _AliqBx4  := 0
Local _AliqBx5  := 0
Local _AliqBx6  := 0

Local aGrvSE   := {} //campos das tabelas SEL e SE5 a serem gravados.
Local nX

dbSelectArea("SE1")
dbSetOrder(1)
dbSeek(xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)
If Found()

	// Calcula el percentual de valor baixado
	_PerBx   := (SEL->EL_VALOR   * 100) / SE1->E1_VALOR

	// Calcula el percentual de valor de descuento
	_PerDesc := (SEL->EL_DESCONT * 100) / SE1->E1_VALOR

	If SE1->E1_VALIMP1 > 0
		_ValorBx1 := SE1->E1_VALIMP1 * (_PerBx / 100)
    	_AliqBx1 := SE1->E1_ALQIMP1
		_BaseBx1 := SE1->E1_BASIMP1 * (_PerBx / 100)

	EndIf
	If SE1->E1_VALIMP2 > 0
		_ValorBx2 := SE1->E1_VALIMP2 * (_PerBx / 100)
	  	_AliqBx2 := SE1->E1_ALQIMP2
		_BaseBx2 := SE1->E1_BASIMP2 * (_PerBx / 100)
	EndIf
	If SE1->E1_VALIMP3 > 0
		_ValorBx3 := SE1->E1_VALIMP3 * (_PerBx / 100)
  		_AliqBx3 := SE1->E1_ALQIMP3
		_BaseBx3 := SE1->E1_BASIMP3 * (_PerBx / 100)
	EndIf
	If SE1->E1_VALIMP4 > 0
		_ValorBx4 := SE1->E1_VALIMP4 * (_PerBx / 100)
	  	_AliqBx4 := SE1->E1_ALQIMP4
		_BaseBx4 := SE1->E1_BASIMP4 * (_PerBx / 100)
	EndIf
	If SE1->E1_VALIMP5 > 0
		_ValorBx5 := SE1->E1_VALIMP5 * (_PerBx / 100)
  		_AliqBx5 := SE1->E1_ALQIMP5
		_BaseBx5 := SE1->E1_BASIMP5 * (_PerBx / 100)
	EndIf
	If SE1->E1_VALIMP6 > 0
		_ValorBx6 := SE1->E1_VALIMP6 * (_PerBx / 100)
	  	_AliqBx6 := SE1->E1_ALQIMP6
		_BaseBx6 := SE1->E1_BASIMP6 * (_PerBx / 100)
	EndIf
	If SEL->EL_DESCONT > 0 .and. SE1->E1_VALIMP1 > 0
		_ValorDc1  := SE1->E1_VALIMP1 * (_PerDesc / 100)
	EndIf
	If SEL->EL_DESCONT > 0 .and. SE1->E1_VALIMP2 > 0
		_ValorDc2  := SE1->E1_VALIMP2 * (_PerDesc / 100)
	EndIf
	If SEL->EL_DESCONT > 0 .and. SE1->E1_VALIMP3 > 0
		_ValorDc3  := SE1->E1_VALIMP3 * (_PerDesc / 100)
	EndIf
	If SEL->EL_DESCONT > 0 .and. SE1->E1_VALIMP4 > 0
		_ValorDc4  := SE1->E1_VALIMP4 * (_PerDesc / 100)
	EndIf
	If SEL->EL_DESCONT > 0 .and. SE1->E1_VALIMP5 > 0
		_ValorDc5  := SE1->E1_VALIMP5 * (_PerDesc / 100)
	EndIf
	If SEL->EL_DESCONT > 0 .and. SE1->E1_VALIMP6 > 0
		_ValorDc6  := SE1->E1_VALIMP6 * (_PerDesc / 100)
	EndIf

	//Campos da tabela SEL
	//             Tab.      Campo        Valor
	Aadd(aGrvSE, {"SEL", "EL_VALIMP1", _ValorBx1})
	Aadd(aGrvSE, {"SEL", "EL_VALIMP2", _ValorBx2})
	Aadd(aGrvSE, {"SEL", "EL_VALIMP3", _ValorBx3})
	Aadd(aGrvSE, {"SEL", "EL_VALIMP4", _ValorBx4})
	Aadd(aGrvSE, {"SEL", "EL_VALIMP5", _ValorBx5})
	Aadd(aGrvSE, {"SEL", "EL_VALIMP6", _ValorBx6})
	Aadd(aGrvSE, {"SEL", "EL_BASIMP1", _BaseBx1})
	Aadd(aGrvSE, {"SEL", "EL_BASIMP2", _BaseBx2})
	Aadd(aGrvSE, {"SEL", "EL_BASIMP3", _BaseBx3})
	Aadd(aGrvSE, {"SEL", "EL_BASIMP4", _BaseBx4})
	Aadd(aGrvSE, {"SEL", "EL_BASIMP5", _BaseBx5})
	Aadd(aGrvSE, {"SEL", "EL_BASIMP6", _BaseBx6})
	Aadd(aGrvSE, {"SEL", "EL_ALQIMP1", _AliqBx1})
	Aadd(aGrvSE, {"SEL", "EL_ALQIMP2", _AliqBx2})
	Aadd(aGrvSE, {"SEL", "EL_ALQIMP3", _AliqBx3})
	Aadd(aGrvSE, {"SEL", "EL_ALQIMP4", _AliqBx4})
	Aadd(aGrvSE, {"SEL", "EL_ALQIMP5", _AliqBx5})
	Aadd(aGrvSE, {"SEL", "EL_ALQIMP6", _AliqBx6})
	Aadd(aGrvSE, {"SEL", "EL_IMPDES1", _ValorDc1})
	Aadd(aGrvSE, {"SEL", "EL_IMPDES2", _ValorDc2})
	Aadd(aGrvSE, {"SEL", "EL_IMPDES3", _ValorDc3})
	Aadd(aGrvSE, {"SEL", "EL_IMPDES4", _ValorDc4})
	Aadd(aGrvSE, {"SEL", "EL_IMPDES5", _ValorDc5})
	Aadd(aGrvSE, {"SEL", "EL_IMPDES6", _ValorDc6})

	//Campos da tabela SE5
	//             Tab.      Campo        Valor
	Aadd(aGrvSE, {"SE5", "E5_VALIMP1", _ValorBx1})
	Aadd(aGrvSE, {"SE5", "E5_VALIMP2", _ValorBx2})
	Aadd(aGrvSE, {"SE5", "E5_VALIMP3", _ValorBx3})
	Aadd(aGrvSE, {"SE5", "E5_VALIMP4", _ValorBx4})
	Aadd(aGrvSE, {"SE5", "E5_VALIMP5", _ValorBx5})
	Aadd(aGrvSE, {"SE5", "E5_VALIMP6", _ValorBx6})
	Aadd(aGrvSE, {"SE5", "E5_BASIMP1", _BaseBx1})
	Aadd(aGrvSE, {"SE5", "E5_BASIMP2", _BaseBx2})
	Aadd(aGrvSE, {"SE5", "E5_BASIMP3", _BaseBx3})
	Aadd(aGrvSE, {"SE5", "E5_BASIMP4", _BaseBx4})
	Aadd(aGrvSE, {"SE5", "E5_BASIMP5", _BaseBx5})
	Aadd(aGrvSE, {"SE5", "E5_BASIMP6", _BaseBx6})
	Aadd(aGrvSE, {"SE5", "E5_ALQIMP1", _AliqBx1})
	Aadd(aGrvSE, {"SE5", "E5_ALQIMP2", _AliqBx2})
	Aadd(aGrvSE, {"SE5", "E5_ALQIMP3", _AliqBx3})
	Aadd(aGrvSE, {"SE5", "E5_ALQIMP4", _AliqBx4})
	Aadd(aGrvSE, {"SE5", "E5_ALQIMP5", _AliqBx5})
	Aadd(aGrvSE, {"SE5", "E5_ALQIMP6", _AliqBx6})

	//verifica se o campo existe e grava o valor na tabela
	For nX := 1 to Len(aGrvSE)
		//aGrvSE[nX,1] = Tabela
		//aGrvSE[nX,2] = Campo
		//aGrvSE[nX,3] = Valor a ser atribuido no campo

		//verifica se o campo existe.
		If (aGrvSE[nX,1])->(FieldPos(aGrvSE[nX,2]))> 0
			RecLock(aGrvSE[nX,1], .F.)
			//atribui็ใo de valor no campo, caso o mesmo exista.
			(aGrvSE[nX,1])->&(aGrvSE[nX,2]) := aGrvSE[nX,3]
			MsUnlock()
		Endif
	Next nX

EndIf

RestArea( aAreaSE1)
RestArea( aArea )

RETURN ()

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFinA087AT  ณ Autor ณ Marcelo Celi Marques ณ Data ณ 15.05.08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Chamada semi-automatica utilizado pelo gestor financeiro   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ FINA087A                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function FinA087AT(aParam)

cRotinaExec := "FINA087A"
ReCreateBrow("SEL",FinWindow)
FinA087A()
dbSelectArea("SEL")
ReCreateBrow("SEL",FinWindow)
dbSelectArea("SEL")

INCLUI := .F.
ALTERA := .F.

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ Fa087aIGV()  ณAutor ณAna Paula					 03.11.09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Funcao que verifica se ha retencoes recebidas e chama a    ณฑฑ
ฑฑณ          ณ montagem do panel correspondente para rateio dos valores   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fa087aIGV(cCliente,cLoja,cNumFatAut)
Local lRet   	:= .T.
Local nX		:= 1
Local nPosPref  := Ascan( aCposSE1, "E1_PREFIXO")
Local nPosNum   := Ascan( aCposSE1, "E1_NUM")
Local nPosTipo  := Ascan( aCposSE1, "E1_TIPO")
Local nPosCli   := Ascan( aCposSE1, "E1_CLIENTE")
Local nPosLoja  := Ascan( aCposSE1, "E1_LOJA")
Local nPosValBx := Ascan( aCposSE1, "nBaixar")
Local nPosValTi := Ascan( aCposSE1, "E1_VALOR")
Local nPosMoeda := AScan(aCposSE1,"E1_MOEDA")
Local nPosVal	:= AScan(aCposSEL,"EL_VALOR")
Local lCalcPerc := .F.
Local cAgente	:= SuperGetMV("MV_AGENTE")
Local lPercRA	:= (GetNewPar("MV_PERRA","N") == "S")
Private aLinTit := {}

DEFAULT cNumFatAut := ""

If Subs(cAgente,1,1) == "N"
	SA1->(DbSetOrder(1))
	If SA1->(MSSEEK(xFilial("SA1")+cCliente+cLoja)) .And. SA1->A1_AGENTE="2"
		lCalcPerc:=.T.
	EndIf
EndIf

For nX:=1 To Len( aLinSE1 )
	If aLinSE1[nX][1]== 1 // Titulo selecionado
   		Aadd( aLinTit, { aLinSE1[nX][nPosPref], aLinSE1[nX][nPosNum], aLinSE1[nX][nPosCli], ;
	   					 aLinSE1[nX][nPosTipo], aLinSE1[nX][nPosLoja], aLinSE1[nX][nPosValBx],aLinSE1[nX][nPosValTi],aLinSE1[nX][nPosMoeda] } )

	EndIf
Next

If Len(aLinTit)< 1 .And. lCalcPerc  .And. lPercRA .And. aCols[1][nPosVal]>0
 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//ณ Montagem do PANEL de aliquotas para percep็ใoณ//
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	oAPerc:=TPanel():New(84,00,,oDlgRecibo,,,,,,127,117,.F.,.T.)

	@ 003,001 GROUP oGrp6 TO 103, 123 LABEL OemToAnsi(STR0157) OF oAPerc  PIXEL  //"Percep็ใo IGV"


	@ 015,005 SAY OemToAnsi(STR0155) SIZE 60,07	OF oAPerc PIXEL //"Aliquota"
	@ 015,065 MSGET oAliqPerc Var nAliqPerc	SIZE 55,09 	OF oAPerc PIXEL Valid Fa087CalcPer(@nAliqPerc,.T.) Picture "@R 99.99" HASBUTTON

	@ 030,005 SAY OemToAnsi(STR0156) SIZE 60,07	OF oAPerc PIXEL //"Valor Percep็ใo"
	@ 030,065 MSGET oVarPer Var nValPerc SIZE 055,009 OF oAPerc READONLY PIXEL Picture fnPesqPict("SE1","E1_VALOR",18,nMoedDesc) HasButton

	@ 045,005 SAY OemToAnsi( STR0045 ) SIZE 55, 07 OF oAPerc PIXEL  //"Valores expressos em "
	 	oCBMoed1:= TComboBox():New(045,065,bSEL,aNomeMoed,055,020,oAPerc, ,{|| nMoedDesc:=oCBMoed1:nAt,Fa087CalcPer(nAliqPerc,.T.)} , , , ,.T.,,,,)

	oAPerc:NCLRPANE:= RGB(233,233,233) ///13165800
	DEFINE SBUTTON FROM 104,063  TYPE 1  ACTION (F087aPerOk(@cNumFatAut)) OF oAPerc When .T.
	DEFINE SBUTTON FROM 104,093  TYPE 2  ACTION (oAPerc:Hide(),oPanBut:lReadOnly:=.F.,oPanel[nPainel]:lReadOnly:=.F.) OF oAPerc When .T.


Elseif lCalcPerc //Verifica percep็ใo de titulos gerados por faturamento
	Fa087CalcPer(nAliqPerc,.F.)
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ Fa087CalcPerบAutor  ณAna Paula           บ Data ณ 03/11/09  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณCalcula percep็ใo para RA e NFs geradas por faturamento(Peru)บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA087A                                                    บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa087CalcPer(nAliqPerc,lPercAdi)
Local nValRec:=0
Local nX:=1
Local nPosVal	:= AScan(aCposSEL,"EL_VALOR")
Local nPosMoedTit	:= AScan(aCposSEL,"EL_MOEDA")
Local nBasePerc:=0
//Local cCert:= ""
Local cNumTit
Local cSerieTit
Local cEmisTit
Local cEspecie

DEFAULT lPercAdi:= .F.
aPerc:={}
If lPercAdi    // Calcula percep็ใo para adiantamentos gerados direto por recibos

	For nX:=1 to Len(aCols)
		nMoedaTit:=Val(aCols[nX][nPosMoedTit])
		nBasePerc:=nBasePerc+(aCols[nX][nPosVal]*(aTaxa[nMoedaTit]/aTaxa[nMoedDesc])*(1))
	Next
	nValPerc := Round(nBasePerc*(nAliqPerc/100),MsDecimais(nMoedDesc))
	If nValPerc > 0
		lTitAd := .T. // Determina que ้ adiantamento
		Aadd(aPerc,{nValPerc,nAliqPerc,nBasePerc,,,,cDocCred,lTitAd})
	EndIf

Else    // Verifica a percep็ใo calculada na emissใo da nota
	aArea:=GetArea()
	nValPerc:=0
	For nX:=1 to Len(aLinTit)
		If !aLinTit[nX][4] $(MVRECANT+"/"+MV_CRNEG)
		// Verifica a percep็ใo calculada na emissใo de notas de //
		// credito e proporcionaliza caso seja uma baixa parcial //
			dbSelectArea("SF2")
			dbSetOrder(1)
			If dbSeek(xFilial("SF2")+aLinTit[nX][2]+aLinTit[nX][1]+aLinTit[nX][3]+aLinTit[nX][5])
				IF SF2->F2_VALIMP4 > 0
			 		nValRec:=Round(xMoeda(aLinTit[nX][6],aLinTit[nX][8],1,3,,aTaxa[aLinTit[nX][8]]),MsDecimais(oCBMOed:nAt)) //aLinTit[nX][6]
					nValTit:=Round(xMoeda(aLinTit[nX][7],aLinTit[nX][8],1,3,,aTaxa[aLinTit[nX][8]]),MsDecimais(oCBMOed:nAt))
					nVlPeOrig:= Round(xMoeda(SF2->F2_VALIMP4,aLinTit[nX][8],1,3,,aTaxa[aLinTit[nX][8]]),MsDecimais(oCBMOed:nAt))// Valor da percep็ใo calculado na emissao da nota
					nValProp := Round(nValRec/nValTit,6) // Valor proporcional
					nValMerc := Round(xMoeda(SF2->F2_VALMERC+SF2->F2_VALIMP1,aLinTit[nX][8],1,3,,aTaxa[aLinTit[nX][8]]),MsDecimais(oCBMOed:nAt)) // Valor da mercadoria + VALOR DE IGV
					nAliqPerc := Round((nVlPeOrig/nValMerc),MsDecimais(oCBMOed:nAt))*100 // Aliquota percep็ใo SD2->D2_ALIQMP4
					nBasePerc := Round((nValProp * nValMerc),MsDecimais(oCBMOed:nAt)) // Base percep็ใo
					nValPerc:=Round(nBasePerc*(nAliqPerc/100),MsDecimais(oCBMOed:nAt))
					cNumTit:= SF2->F2_DOC
					cSerieTit:=SF2->F2_SERIE
					cEmisTit := SF2->F2_EMISSAO
					cEspecie:= SF2->F2_ESPECIE
					lTitAd := .F. // Determina que nao ้ um adiantamento
				EndIf
				If nValPerc > 0
					Aadd(aPerc,{nValPerc,nAliqPerc,nBasePerc,cNumTit,cSerieTit,cEmisTit,cEspecie,lTitAd})
				EndIf
			EndIf
		Else
			// Verifica a percep็ใo calculada na emissใo de notas de //
			// debito e proporcionaliza caso seja uma baixa parcial //
			dbSelectArea("SF1")
		 	dbSetOrder(1)
		 	If dbSeek(xFilial("SF1")+aLinTit[nX][2]+aLinTit[nX][1]+aLinTit[nX][3]+aLinTit[nX][5])
				IF SF1->F1_VALIMP4 > 0
					nValRec:=Round(xMoeda(aLinTit[nX][6],aLinTit[nX][8],1,3,,aTaxa[aLinTit[nX][8]]),MsDecimais(oCBMOed:nAt))//aLinTit[nX][6]
					nValTit:=Round(xMoeda(aLinTit[nX][7],aLinTit[nX][8],1,3,,aTaxa[aLinTit[nX][8]]),MsDecimais(oCBMOed:nAt))//aLinTit[nX][7]
					nVlPeOrig:= Round(xMoeda(SF1->F1_VALIMP4,aLinTit[nX][8],1,3,,aTaxa[aLinTit[nX][8]]),MsDecimais(oCBMOed:nAt))// Valor da percep็ใo calculado na emissao da nota //SF1->F1_VALIMP4 // Valor da percep็ใo calculado na emissao da nota
					nValProp := Round(nValRec/nValTit,6) // Valor proporcional
					nValMerc := Round(xMoeda(SF1->F1_VALMERC+SF1->F1_VALIMP1,aLinTit[nX][8],1,3,,aTaxa[aLinTit[nX][8]]),MsDecimais(oCBMOed:nAt)) // Valor da mercadoria + VALOR DE IGV //SF1->F1_VALMERC+SF1->F1_VALIMP1 // Valor da mercadoria
					nAliqPerc := Round((nVlPeOrig/nValMerc),MsDecimais(oCBMOed:nAt))*100 // Aliquota percep็ใo SD1->D1_ALIQMP4
					nBasePerc := Round((nValProp * nValMerc),MsDecimais(oCBMOed:nAt)) // Base percep็ใo
					nValPerc:=Round(nBasePerc*(nAliqPerc/100),MsDecimais(oCBMOed:nAt))
					cNumTit:= SF1->F1_DOC
					cSerieTit:=SF1->F1_SERIE
					cEmisTit := SF1->F1_EMISSAO
					cEspecie:= SF1->F1_ESPECIE
					lTitAd := .F. // Determina que nao ้ um adiantamento
	 			EndIf
	 		If nValPerc > 0
				Aadd(aPerc,{nValPerc,nAliqPerc,nBasePerc,cNumTit,cSerieTit,cEmisTit,cEspecie,lTitAd})
			EndIf
	 		EndIF
		EndIf

	Next
	RestArea(aArea)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ F087aPerok บAutor  ณAna Paula           บ Data ณ  04 /11/09บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณvalida a inclusใo da aliquota de percep็ใo		          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA087A                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F087aPerok(cNumFatAut)
DEFAULT cNumFatAut := ""
oAPerc:Hide()
FaMoedas()
oPanBut:lReadOnly:=.F.
oPanel[nPanel]:lReadOnly:=.F.
RefData(4,cNumFatAut)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ GetCertPer บAutor  ณMicrosiga           บ Data ณ    /  /   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณPega os numeros de certificados de percep็ใo(Peru)          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA087A                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetCertPer(cImposto,cChave,lReUsa)
Local cNroCert	:=	""
Local nPosCert	:=	0
Local aCerts := {}

DEFAULT lReUsa	:=	.T.

If lReUsa
	nPosCert :=	Ascan(aCerts,{|x| X[1] == cChave } )
Endif
If nPosCert > 0
	Return  aCerts[nPosCert][2]
Endif

dbSelectArea("SX5")

If ! MsSeek(xFilial("SX5")+"99"+cImposto,.F.)
	RecLock("SX5", .T.)
	SX5->X5_TABELA 	:= '99'
	SX5->X5_FILIAL 	:= xFilial("SX5")
	SX5->X5_CHAVE  	:= cImposto
	SX5->X5_DESCRI 	:= '00000001'
	SX5->X5_DESCSPA := '00000001'
	SX5->X5_DESCENG := '00000001'
	cNroCert       	:= '00000001'
	MsUnLock()
Else
	cNroCert := StrZero(Val(X5DESCRI())+1,8)
	Reclock("SX5",.F.)
	SX5->X5_DESCRI 	:= StrZero(Val(cNroCert),8)
	SX5->X5_DESCSPA := StrZero(Val(cNroCert),8)
	SX5->X5_DESCENG := StrZero(Val(cNroCert),8)
	MsUnLock()
EndIf

AAdd(aCerts,{cChave,cNroCert})

Return cNroCert

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCkNaturezaบAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CkNatureza(cNatureza,lNatureza)
If FinProcITF(,1,,,,,cNatureza)
	lNatureza:=.T.
 else
	lNatureza:=.F.
Endif
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณlRetCkPG  บAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function lRetCkPG(n,cDebInm,cBanco,nPagar)
Local lRetCx:=.T.
If cPaisLoc="PER"
   If n==0
      If cBanco $ (Left(SuperGetMV("MV_CXFIN"),TamSX3("A6_COD")[1])+"/"+SuperGetMV("MV_CARTEIR")) .or. IsCaixaLoja(cBanco)
         If nPagar=2 //.and. cDebInm="TF"
            lRetCx:=.F.
            MsgAlert(STR0162+cBanco+STR0163)
         Endif
      Endif
     Elseif n==3
      If cBanco $ (Left(SuperGetMV("MV_CXFIN"),TamSX3("A6_COD")[1])+"/"+SuperGetMV("MV_CARTEIR"))  .or. IsCaixaLoja(cBanco)
         lRetCx:=.F.
      Endif
   Endif
Endif
Return(lRetCx)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณ fa087FilTipoบAutor  ณ Jos้ Lucas         บ Data ณ 02/12/10 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para cria็ใo de filtro no gatilho campo EL_TIPODOC. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA087A                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fa087FilTipo()
Local lTipoCred := .F.
If M->EL_TIPODOC $ "RG|RB|RS|RI|RR|"
	lTipoCred := .T.
EndIf
If ! lTipoCred
	If M->EL_TIPODOC $ cCredMed
		lTipoCred := .T.
	EndIf
EndIf
If ! lTipoCred
	If M->EL_TIPODOC $ cCredInM
		lTipoCred := .T.
	EndIf
EndIf
Return( lTipoCred )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณ fa087TipCredบAutor  ณ Jos้ Lucas         บ Data ณ 02/12/10 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para definir a regra do gatilho campo EL_TIPODOC.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA087A                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fa087TipCred()
Local cTipoCred		:= ""
Local nPosTpCred	:= Ascan(aHeader,{|x| Alltrim(x[2]) == "EL_TPCRED"})

If M->EL_TIPODOC $ "RG|RB|RS|RI|RR|"
	cTipoCred := "4"
EndIf
If M->EL_TIPODOC $ cCredMed
	cTipoCred := "3"
EndIf
If M->EL_TIPODOC $ cCredInM
	cTipoCred := "1"
EndIf
If !Empty(cTipoCred) .and. nPosTpCred > 0
	aCols[n][nPosTpCred] := cTipoCred
EndIf

oGetSEL:ForceRefresh()
Return( cTipoCred )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fa087Concept บAutor  ณ Jos้ Lucas     บ Data ณ  01/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retornar o array Concepto com informa็๕es das reten็oes.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA087A                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fa087Concept(cPrefixo,cNFiscal,cParcela,cTipo,cCliente,cLoja,cCodRet,aDadImp,lAtu,lGrava,lComparVlres)
Local aArea			:= GetArea()
Local aAreaFRN		:= {}
Local aAreaFRM		:= {}
Local aAreaCCR		:= {}
Local aConcepto		:= {}
Local aIVA			:= {}
Local aRIR			:= {}
Local nBaseImp		:= 0.00
Local nImposto		:= 0.00
Local nAliquota		:= 0.00
Local cCpoBase		:= ""
Local cCpoImp		:= ""
Local nCount		:= 0
Local cCarteira		:= ""
Local cFatoGerador	:= ""
Local cNatur		:= ""
Local nValBase		:= 0

Default aDadImp		:= {}
Default lAtu		:= .F.
Default lGrava		:= .F.
Default lComparVlres:= .F.

lConfImp := Len(aDadImp) >= 4

If !lConfImp
	SF2->(dbSetOrder(1))
	SF2->(dbSeek(xFilial("SF2")+cNFiscal+cPrefixo+cCliente+cLoja))

	SD2->(dbSetOrder(3))
	If SD2->(dbSeek(xFilial("SD2")+cNFiscal+cPrefixo+cCliente+cLoja))
	    While !Eof() .and. SD2->D2_DOC == cNFiscal .and. SD2->D2_SERIE == cPrefixo .and.;
			SD2->D2_CLIENTE == cCliente .and. SD2->D2_LOJA == cLoja
			If cCodRet == "RI"
			    SFB->(dbSeek(xFilial("SFB")+"RV0"))
				cCpoBase  := "SD2->D2_BASIMP"+If(Empty(SFB->FB_CPOLVRO),"1",SFB->FB_CPOLVRO)
				cCpoImp   := "SD2->D2_VALIMP"+If(Empty(SFB->FB_CPOLVRO),"1",SFB->FB_CPOLVRO)
				nBaseImp  := &(cCpoBase)
				nImposto  := &(cCpoImp)
	            nAliquota := If(Empty(SFB->FB_ALIQ),Round((nImposto/nBaseImp)*100,2),SFB->FB_ALIQ)
				AADD(aIVA,{SD2->D2_CONCEPT,"RV0",nBaseImp,nAliquota,nImposto,SD2->D2_TES})
	 		Else
			    SFB->(dbSeek(xFilial("SFB")+"RIR"))
				cCpoBase  := "SD2->D2_BASIMP"+If(Empty(SFB->FB_CPOLVRO),"6",SFB->FB_CPOLVRO)
				cCpoImp   := "SD2->D2_VALIMP"+If(Empty(SFB->FB_CPOLVRO),"6",SFB->FB_CPOLVRO)
				nBaseImp  := &(cCpoBase)
				nImposto  := &(cCpoImp)
	            nAliquota := If(Empty(SFB->FB_ALIQ),Round((nImposto/nBaseImp)*100,2),SFB->FB_ALIQ)
	            If !Empty(SD2->D2_CONCEPT) .And. CCR->(dbSeek(xFilial("CCR")+SD2->D2_CONCEPT))
	              	nAliquota := CCR->CCR_ALIQ
				EndIf
				AADD(aRIR,{SD2->D2_CONCEPT,"RIR",nBaseImp,nAliquota,nImposto,SD2->D2_TES})
			EndIf
			SD2->(dbSkip())
		End
	EndIf
	If cCodRet == "RI"
		For nCount := 1 To Len(aIVA)
	    	nPosConcept := Ascan(aConcepto,{|x| AllTrim(x[2]) == "RV0"})
	    	If nPosConcept == 0
				AADD(aConcepto,{aIVA[nCount][1],"RV0",aIVA[nCount][3],aIVA[nCount][4],aIVA[nCount][5],aIVA[nCount][6]})
			Else
				aConcepto[1][3] += aIVA[nCount][3]
				aConcepto[1][4] := aIVA[nCount][4]
				aConcepto[1][5] += aIVA[nCount][5]
				aConcepto[1][6] := aIva[nCount][6]
	    	EndIf
		Next nCount
	Else
		For nCount := 1 To Len(aRIR)
	    	nPosConcept := Ascan(aConcepto,{|x,y| AllTrim(x[1]) == AllTrim(aRIR[nCount][1])})
	    	If nPosConcept == 0
				AADD(aConcepto,{AllTrim(aRIR[nCount][1]),"RIR",aRIR[nCount][3],aRIR[nCount][4],aRIR[nCount][5],aRIR[nCount][6]})
			Else
				aConcepto[1][3] += aRIR[nCount][3]
				aConcepto[1][4] += aRIR[nCount][4]
				aConcepto[1][5] += aRIR[nCount][5]
				aConcepto[1][6] := aRIR[nCount][6]
	    	EndIf
		Next nCount
	EndIf
Else
	cCarteira		:= aDadImp[1]
	cFatoGerador	:= aDadImp[2]
	cNatur			:= aDadImp[3]
	nValBase		:= aDadImp[4]

	If cPaisLoc $ "COS|DOM|PAD|RUS"
		aAreaFRN  := FRN->(GetArea())
		aAreaFRM  := FRM->(GetArea())
	EndIf
	aAreaCCR  := CCR->(GetArea())

	Private aCerts	 := {} //-- Compatibiliza็ใo Configurador de Impostos Localizado - Rep.Dom.
	// Fato gerador => '2' (Baixa)
	If !lAtu
		If lComparVlres .And. !Empty(aLinBaixa[oLBBaixa:nAT][2]) .And. SE1->E1_SALDO <> aLinBaixa[oLBBaixa:nAT][2]
			FCalcImp(cCarteira,'2', cNatur, SE1->E1_VALOR, SE1->E1_PREFIXO, SE1->E1_NUM, cCliente,cLoja,"", lGrava ,0,, aConcepto)
		Else
			FCalcImp(cCarteira,'2', cNatur, SE1->E1_VALOR, SE1->E1_PREFIXO, SE1->E1_NUM, cCliente,cLoja,"", lGrava ,aLinBaixa[oLBBaixa:nAT][2],, aConcepto)
		EndIf
	Else
		FCalcImp(cCarteira,'2', cNatur, SE1->E1_SALDO, SE1->E1_PREFIXO, SE1->E1_NUM, cCliente,cLoja,"", lGrava ,&(ReadVar()),, aConcepto)
	EndIf

EndIf

RestArea(aArea)
Return aConcepto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ A087aFillC บAutor  ณBruno               บ Data ณ  22/09/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para recplicar os dados que devem ser iguais no acoolบฑฑ
ฑฑบ          ณdo detalhe das retencoes. (Argentina)                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA087A                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A087aFillC(oGetd)
Local xCont	:=	Nil
Local nX
If cPaisLoc=="PAR"
	IF "FE_CFO"$ ReadVar()
		 xCont	:=	  &(ReadVar())
		 For nX:= 1 To Len(oGetd:aCols)
			oGetD:aCols[nX,1]	:=	xCont
		 Next nX
	ElseIf "FE_ALIQ"$ ReadVar()
		 xCont	:=	  &(ReadVar())
		 For nX:= 1 To Len(oGetd:aCols)
			oGetD:aCols[nX,Len(aCols[nx])-3]	:=	xCont
			oGetD:aCols[nX,Len(aCols[nx])-2]	:=	oGetD:aCols[nX,Len(aCols[nx])-4] * oGetD:aCols[nX,Len(aCols[nx])-3] /100
	    Next nX
	 Endif
Else
IF "FE_CFO"$ ReadVar()
	 xCont	:=	  &(ReadVar())
	 For nX:= 1 To Len(oGetd:aCols)
		oGetD:aCols[nX,6]	:=	xCont
    Next nX
ElseIf "FE_EST"$ ReadVar()
	 xCont	:=	  &(ReadVar())
	 For nX:= 1 To Len(oGetd:aCols)
		oGetD:aCols[nX,5]	:=	xCont
    Next nX
ElseIf "FE_ALIQ"$ ReadVar()
	 xCont	:=	  &(ReadVar())
	 For nX:= 1 To Len(oGetd:aCols)
		oGetD:aCols[nX,Len(aCols[nx])-2]	:=	xCont
		oGetD:aCols[nX,Len(aCols[nx])-1]	:=	oGetD:aCols[nX,Len(aCols[nx])-3] * oGetD:aCols[nX,Len(aCols[nx])-2] /100
    Next nX
ElseIf "A2_AGREGAN"$ ReadVar()
	 xCont	:=	  &(ReadVar())
	 For nX:= 1 To Len(oGetd:aCols)
		oGetD:aCols[nX,7]	:=	xCont
    Next nX
ElseIf "A2_CONCSUS"$ ReadVar()
	 xCont	:=	  &(ReadVar())
	 For nX:= 1 To Len(oGetd:aCols)
		oGetD:aCols[nX,7]	:=	xCont
    Next nX
Endif
	Endif
oGetD:oBrowse:Refresh()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA87RetVldบAutor  ณRenan Guedes        บ Data ณ  03/28/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida็ใo da altera็ใo do campo VALOR do quadro de reten็๕esบฑฑ
ฑฑบ          ณdo painel 5. Esta fun็ใo chama as fun็๕es executadas nos 	  บฑฑ
ฑฑบ          ณpain้is anteriores.										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA87RetVld()

Local lRet	  		:= .T.
Local nX			:= 0
Local nY			:= 0
Local cCampo		:= AllTrim(ReadVar())
Local nPosVal1		:= 0
Local nPosVal2		:= 0
Local nPosTpDoc1	:= 0
Local nPosTpDoc2	:= 0
Local nPosPref1		:= 0
Local nPosPref2		:= 0
Local nPosNum1		:= 0
Local nPosNum2		:= 0
Local nPosPar1		:= 0
Local nPosPar2		:= 0
Local nPosEmis1		:= 0
Local nPosEmis2		:= 0
Local nPosVenc1		:= 0
Local nPosVenc2		:= 0
Local aColsRet		:= {}

If cPaisLoc $ "ARG|COS"
	aColsRet := ACLONE(aColsSEL)

	If cCampo == "M->EL_VALOR"
		//Posi็๕es dos campos no cabe็alho
		nPosVal1	:= ASCAN(aHeaderSEL,		{|aCpo| AllTrim(aCpo[2]) == "EL_VALOR"		})
		nPosVal2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) == "EL_VALOR"		})
		nPosTpDoc1	:= ASCAN(aHeaderSEL,		{|aCpo| AllTrim(aCpo[2]) == "EL_TIPODOC" 	})
		nPosTpDoc2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) == "EL_TIPODOC" 	})
		nPosPref1	:= ASCAN(aHeaderSEL,		{|aCpo| AllTrim(aCpo[2]) == "EL_PREFIXO" 	})
		nPosPref2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) == "EL_PREFIXO" 	})
		nPosNum1	:= ASCAN(aHeaderSEL,		{|aCpo| AllTrim(aCpo[2]) == "EL_NUMERO"		})
		nPosNum2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) == "EL_NUMERO" 	})
		nPosPar1	:= ASCAN(aHeaderSEL,		{|aCpo| AllTrim(aCpo[2]) == "EL_PARCELA" 	})
		nPosPar2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) == "EL_PARCELA" 	})
		nPosEmis1	:= ASCAN(aHeaderSEL,		{|aCpo| AllTrim(aCpo[2]) == "EL_EMISSAO"	})
		nPosEmis2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) == "EL_EMISSAO" 	})
		nPosVenc1	:= ASCAN(aHeaderSEL,		{|aCpo| AllTrim(aCpo[2]) == "EL_DTVCTO" 	})
		nPosVenc2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) == "EL_DTVCTO" 	})

		//Captura o novo valor
		nNewVal := &(ReadVar())

		//Atualiza a linha da reten็ใo com o novo valor
		oRetTit:aCols[oRetTit:nAt][nPosVal2] := nNewVal

		//Zera os valores do quadro de resumo de reten็๕es
		For nX := 1 To Len(oRetRes:aArray)
			oRetRes:aArray[nX,2] := 0
		Next nX

		For nX := 1 To Len(oRetTit:aCols)
			//Soma as reten็๕es e atualiza os valores do quadro de resumo de reten็๕es
			Do Case
				Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 1		//IVA
					oRetRes:aArray[1,2] += oRetTit:aCols[nX,nPosVal2]
				Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 2		//Ganancias
					oRetRes:aArray[2,2] += oRetTit:aCols[nX,nPosVal2]
				Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 3		//Ingressos Brutos
					oRetRes:aArray[3,2] += oRetTit:aCols[nX,nPosVal2]
				Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 4		//SUSS
					oRetRes:aArray[4,2] += oRetTit:aCols[nX,nPosVal2]
			EndCase
			oRetRes:aArray[5,2] += oRetTit:aCols[nX,nPosVal2]
		Next nX

		//Atualiza o quadro de resumo de reten็๕es
		oRetRes:Refresh()

		For nX := 1 To Len(aColsRet)
			If !(aColsRet[nX,Len(aHeaderSEL)+1])
				For nY := 1 To Len(oRetTit:aCols)
					//Procura a linha da aCols onde a reten็ใo se localiza
					If !(aColsRet[nX,Len(aHeaderSEL)+1])	 							.And.;
						(aColsRet[nX,nPosTpDoc1]	== oRetTit:aCols[nY][nPosTpDoc2])	.And.;
						(aColsRet[nX,nPosPref1]		== oRetTit:aCols[nY][nPosPref2])	.And.;
						(aColsRet[nX,nPosNum1]		== oRetTit:aCols[nY][nPosNum2])		.And.;
						(aColsRet[nX,nPosPar1]		== oRetTit:aCols[nY][nPosPar2])		.And.;
						(aColsRet[nX,nPosEmis1]		== oRetTit:aCols[nY][nPosEmis2])	.And.;
						(aColsRet[nX,nPosVenc1]		== oRetTit:aCols[nY][nPosVenc2])

						//Atualiza o valor da reten็ใo para possibilitar as valida็๕es
						aColsRet[nX,nPosVal1] := oRetTit:aCols[nY][nPosVal2]
					EndIf
				Next nY
			EndIf
		Next nX

		//Atribui a aCols o array aCSEL e atualiza o objeto da GetDados de reten็๕es (Painel 1)
		aCols	:= ACLONE(aColsRet)
		aHeader	:= ACLONE(aHeaderSEL)
		oGetSEL:ForceRefresh()

		//Atualiza taxas das moedas
		FaMoedas()

		//Valida a aCols inteira
		If Fa087aTudoOk()
			Fa087aBaixaOK()
		EndIf

		//Seta o aCols para o objeto do browse de reten็๕es
		aCols 		:= ACLONE(oRetTit:aCols)
		aHeader		:= ACLONE(oRetTit:aHeader)
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFA87AValPanบAutor  ณRenan Guedes        บ Data ณ 03/31/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณValida o refresh do painel 4 - Resumo                       บฑฑ
ฑฑบ          ณEsta fun็ใo forca a atualiza็ใo do painel 4 quando o		  บฑฑ
ฑฑบ          ณusuแrio estแ num painel posterior e volta para este.        บฑฑ
ฑฑบ          ณ															  บฑฑ
ฑฑบ          ณFecha e apaga os arquivos temporแrios da simula็ใo da 	  บฑฑ
ฑฑบ          ณcontabiliza็ใo, caso tenham sido criados					  บฑฑ
ฑฑบ          ณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParโmetrosณnPan = N๚mero do painel a ser exibido                       บฑฑ
ฑฑบ          ณ															  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA87AValPan(nPan,nLPan)

//Foi removida toda a execu็ใo para o paํs ARG e colocado um Return para que
//nใo haja nenhum efeito colateral para outros paํses

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA087A  บAutor  ณMicrosiga           บ Data ณ  04/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณDescricao ณFuncao que grava os campos no SA1 para avalia็ao de credito ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณcOper = Operando para calcular os campos de avlia็ao do 	  ณฑฑ
ฑฑบ          ณ        credito 											  ณฑฑ
ฑฑณ          ณnValor = Valor do campo que serแ calculado                  ณฑฑ
ฑฑณ          ณnMoeda = Moeda Forte do Cliente                             ณฑฑ
ฑฑณ          ณcTipoDoc = Tipo de Titulo(Docto)                            ณฑฑ
ฑฑณ          ณnTaxa  = Taxa de conversใo do Valor do campo para a Moeda   ณฑฑ
ฑฑบ          ณ         Forte 											  ณฑฑ
ฑฑณ          ณdData  = Data de conversใo do Valor do cmapo para a Moeda   ณฑฑ
ฑฑบ          ณ         Forte 											  ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบATENวรO   ณ ESTE PROGRAMA ษ UMA CำPIA E ADAPTAวรO DO AtuSalDup         บฑฑ
ฑฑบ          ณ CONTIDO NO FONTE MATXATU                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA87aAtSdDp(cOper,nValor,nMoeda,cTipoDoc,nTaxa,dData,nCm)

Local cCampo		:= ""									// Campo que terแ o saldo atualizado
Local cCampo1		:= ""									// Campo que terแ o saldo atualizado
Local cTpNaoAtu		:= Nil									// Tipos que nao atualizam saldo algum no cadastro de clientes
Local cTiposLC		:= Nil
Local nMCusto
Local nMoedaF		:= 0
Local nValorMoe1	:= 0
Local nValorMoeF	:= 0

nTaxa	:=  If(nTaxa	==	Nil,0,nTaxa)
nMoeda	:=	If(nMoeda	==	Nil,1,nMoeda)
dData	:=	If(dData	==	Nil,dDataBase,dData)

Default nCm := 0

If !cOper $ "+-="
	//MsgAlert(STR0044)  //"Operando incorreto, Verifique se ้ uma atribui็ใo, soma ou subtra็ใo"
	Return
Endif

If cTiposLC == Nil
	cTiposLC := ""
	cTiposLC := FA87aSESTp({ || ES_SALDUP == "2"},"1")
	nMCusto  :=	Val(SuperGetMV("MV_MCUSTO"))
Endif

// Tipos que nao atualizam nenhum dos saldos
If cTpNaoAtu == Nil
	cTpNaoAtu := ""
	cTpNaoAtu := FA87aSESTp({ || ES_SALDUP == "3"},"1")
Endif

If !(cTipoDoc $ cTpNaoAtu)
	If cTipoDoc $ cTiposLC
		cCampo	:=	"SA1->A1_SALFIN"
		cCampo1	:=	"SA1->A1_SALFINM"
	Else
		cCampo	:=	"SA1->A1_SALDUP"
		cCampo1	:=	"SA1->A1_SALDUPM"
	Endif
Else
	Return
Endif

nMoedaF		:= If(SA1->A1_MOEDALC > 0,SA1->A1_MOEDALC,nMCusto)

nValorMoe1	:= Round(xMoeda(nValor-nCm,nMoeda,1,dData,MsDecimais(1)+1),MsDecimais(1))
nValorMoeF  := Round(xMoeda(nValor,nMoeda,nMoedaF,dData,MsDecimais(nMoedaF)+1,,nTaxa),MsDecimais(nMoedaF))

RecLock("SA1",.F.)
If cOper == "+"
	&cCampo. 	+= nValorMoe1
	&cCampo1. 	+= nValorMoeF
ElseIf cOper == "-"
	&cCampo. 	-= nValorMoe1
	&cCampo1. 	-= nValorMoeF
ElseIf cOper == "="
	&cCampo. 	:= nValorMoe1
	&cCampo1.	:= nValorMoeF
EndIf
MsUnlock()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA87aSESTpบAutor  ณ Renan Guedes       บ Data ณ  04/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a os tipos de acordo com o bloco de codigo.         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ bProps    = Bloco de codigo com as propriedades a consultarบฑฑ
ฑฑบ          ณ cCarteira = Carteira a consultar (Default  ambas).        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบATENวรO   ณ ESTE PROGRAMA ษ UMA CำPIA E ADAPTAวรO DO GetSESTipos       บฑฑ
ฑฑบ          ณ CONTIDO NO FONTE MATXFUNC                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA87aSESTp(bProps,cCarteira)

Local aArea	:= {}
Local cRet

Default cCarteira 	:=	"3"

cRet	:=	Space(0)
aArea	:=	GetArea()

dbSelectArea("SES")
dbSetOrder(1)
dbSeek(xFilial())
While !EOF() .And. xFilial() == ES_FILIAL
	If EVAL(bProps) .And. ( cCarteira $ "3" .Or. ES_CARTEIR $ "3" ;
			.Or. ES_CARTEIR $ cCarteira)
		cRet +=	ES_TIPO + "|"
	Endif
	dbSkip()
EndDo

cRet :=	IIF(!Empty(cRet), Substr(cRet,1,Len(cRet)-1), cRet)

RestArea(aArea)

Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFINNextAliasบAutor  ณAlvaro Camillo Netoบ Data ณ  15/04/10  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณProte็ใo para retornar o pr๓ximo alias disponivel no Banco  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FINNextAlias()

Local cNextAlias := ""
Local aArea := GetArea()

While .T.
	cNextAlias := GetNextAlias()
	If !TCCanOpen(cNextAlias) .And. Select(cNextAlias) == 0
		Exit
	EndIf
EndDo

RestArea(aArea)

Return cNextAlias

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ F087aValCliบAutor  ณAna Paula           บ Data ณ  18/05/11 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณValida็ใo de clientes bloqueados							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA087A                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F087aValCli(cCliente,cLoja)
Local aArea:= GetArea()
Local lRet:= .T.
DEFAULT cCliente:= ""
DEFAULT cLoja:= ""

If SA1->(DbSeek(xFilial("SA1")+cCliente))
 	If cLoja <> "" .And. SA1->(DbSeek(xFilial("SA1")+cCliente+cLoja)) .And. SA1->A1_MSBLQL == "1"
		HELP(" ",1,"REGBLOQ")
		lRet:= .F.
	Endif
Else
 		lRet:= .F.
EndIf
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetIndicesบAutor  ณMicrosiga           บ Data ณ  22/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ OBTEM OS INDICES DAS TABELAS                               บฑฑ
ฑฑบ          ณ UTILIZADA PARA SIMULACAO DE LANCOS CONTABEIS (ARGENTTINA)  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetIndices(cAlias)

Local aIndices	:= {}

SIX->(dbSetOrder(1))
If SIX->(MsSeek(cAlias+"1"))
	aIndices := {}
	While !(SIX->(EOF())) .AND.  SIX->INDICE == cAlias
		AADD(aIndices, SIX->CHAVE)
		SIX->(DBSkip())
	Enddo

EndIf

Return (aIndices)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsFi087A บAutor  ณJandir Deodato      บFecha ณ 04/09/12    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Caso a integra็ใo com o Totvs Obras e Projetos esteja      บฑฑ
ฑฑบ              ligada chama a tela de rateio do projeto.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PmsFi087a()
Local aSave
Local bPMSDlg87 :={||PmsDlgRC(3,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_ORIGEM)}//integra็ใo com Totvs obras e projetos
aSave:=GetArea()
M->E1_NUM 		:=SE1->E1_NUM
M->E1_PREFIXO :=SE1->E1_PREFIXO
If cPaisLoc == "ARG"
	M->E1_FORNECE :=SE1->E1_FORNECE
EndIf
M->E1_LOJA		:=SE1->E1_LOJA
M->E1_ORIGEM	:=SE1->E1_ORIGEM
M->E1_VALOR	:=SE1->E1_VALOR
M->E1_MOEDA	:=SE1->E1_MOEDA
M->E1_TXMOEDA	:=SE1->E1_TXMOEDA
Eval (bPMSDlg87)
PMSWriteRC(1,"SE1")
RestArea(aSave)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa087aNFRAบAutor  ณMicrosiga           บ Data ณ  19/06/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Caso a natureza do titulo seja de adiantamento ED_OPERADT=1บฑฑ
ฑฑบ          ณ gera o titulo do tipo RA (E1_TIPODOC) com base no titulo   บฑฑ
ฑฑบ          ณ de adiantamento.                                           บฑฑ
ฑฑบ          ณ Esta rotina tem como base o processo de geracao de NCC     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN - MEXICO                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fa087aNFRA(nValBaixa)
Local cDocRA	:= Substr(MVRECANT,1,3) //"RA" no Mexico
Local cParcSE1	:= CriaVar("E1_PARCELA",.T.)
Local aSaveArea	:= GetArea()
Local aSaveSE1	:= SE1->(GetArea())
Local aSaveSEL	:= SEL->(GetArea())
Local nValImps  := 0

Default nValBaixa	:= 0

If SE1->(!EOF())

	RegToMemory("SE1",.F.) //Carrega o titulo base na mem๓ria

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Caso o titulo do tipo RA ja exista (processo de baixa ณ
	// ณparcial) o campo E1_PARCELA eh incrementado.          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	While  SE1->(DbSeek(XFilial("SE1")+M->E1_PREFIXO+M->E1_NUM+cParcSE1+cDocRA))
		cParcSE1 := Soma1(cParcSE1)
	SE1->(DbSkip())
	EndDo

	nValImps:= fVerifImp(M->E1_NUM, M->E1_PREFIXO,M->E1_TIPO,cCliente,cLoja)  // retorna el valor del Impuesto
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Gera o novo titulo do tipo RA                         ณ
	//ณ O conceito de criacao eh semelhante ao gerado na NCC. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	RecLock("SE1",.T.)
	SE1->E1_FILIAL   	:= XFilial("SE1")
	SE1->E1_PREFIXO  	:= M->E1_PREFIXO
	SE1->E1_NUM			:= M->E1_NUM
	SE1->E1_PARCELA		:= cParcSE1
	SE1->E1_TIPO     	:= cDocRA
	SE1->E1_EMISSAO  	:= dDataRef
	SE1->E1_EMIS1    	:= CtoD("")
	SE1->E1_VENCTO  	:= dDataRef
	SE1->E1_VENCREA 	:= DataValida(dDataRef)
	SE1->E1_NATUREZ  	:= M->E1_NATUREZ
	SE1->E1_MOEDA   	:= M->E1_MOEDA
	SE1->E1_VLCRUZ		:= nValBaixa * aTaxa[M->E1_MOEDA]
	SE1->E1_VALOR   	:= nValBaixa
	SE1->E1_SALDO   	:= nValBaixa - nValImps //Subtrai o valor referente ao IVA para compensacao no faturamento
	SE1->E1_CLIENTE 	:= cCliente
	SE1->E1_LOJA    	:= cLoja
	SE1->E1_SERREC      := cSerie
	SE1->E1_RECIBO  	:= cRecibo
	SE1->E1_NOMCLI   	:= SA1->A1_NOME
	SE1->E1_SITUACA  	:= "0"
	SE1->E1_ORIGEM   	:= "FINA087A"
	SE1->E1_LA       	:= "S"
	SE1->E1_STATUS   	:= "A"
	SE1->E1_TXMOEDA		:= M->E1_TXMOEDA
	If cPaisLoc == "CHI"
		SE1->E1_CGC			:= SA1->A1_CGC
	Endif
	SE1->(MsUnlock())

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Gera o recibo do titulo RA gerado acima ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	RecLock("SEL",.T.)
	EL_FILIAL   := XFilial("SEL")
	EL_TIPODOC  := "RA"
	EL_PREFIXO  := "REC"
	EL_NUMERO   := SE1->E1_NUM
	EL_PARCELA  := SE1->E1_PARCELA
	EL_TIPO   	:= cDocRA
	EL_EMISSAO  := dDataRef
	EL_DTDIGIT  := dDataBase
	EL_DTVCTO   := dDataRef
	EL_NATUREZ  := SE1->E1_NATUREZ
	EL_MOEDA    := StrZero(SE1->E1_MOEDA,2)
    EL_DESCONT  := SE1->E1_DESCONT
	EL_VLMOED1 	:= Round(nValBaixa * aTaxa[1], MsDecimais(nTamVlMoed))
	EL_VALOR    := nValBaixa
	EL_CLIENTE 	:= cCliente
	EL_LOJA	 	:= cLoja
	EL_SERIE    := cSerie
	EL_RECIBO 	:= cRecibo
	EL_COBRAD	:= cCobrador
	EL_RECPROV	:= cRecProv
	EL_CLIORIG	:= cCliOri
	EL_LOJORIG	:= cLojOri
	F087AGrvTx( aTaxa )
	SEL->(MsUnlock())

EndIf

RestArea(aSaveSEL)
RestArea(aSaveSE1)
RestArea(aSaveArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA087A  บAutor  ณMicrosiga           บ Data ณ  25/06/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a natureza selecionada para o recibo para nao per-  บฑฑ
ฑฑบ          ณ mitir a utilizacao de natureza de operacao de adiantamento บฑฑ
ฑฑบ          ณ ED_OPERADT == 1                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA087AVlNa()
Local aArea		:= GetArea()
Local aAreaSED	:= SED->(GetArea())
Local lRet		:= .T.
Local lVazio    := .F.

If cPaisLoc $ "PER|BOL" .And. AllTrim(cCalcITF) == "1"
	If !Empty(cNatureza)
		CkNatureza(cNatureza,@lNatureza)
	Else
		lRet := .F.
		MsgAlert(STR0166) //"O campo Natureza ้ obrigat๓rio!"
	EndIf
EndIf

If cPaisLoc $ "MEX|PER" .And. X3Usado("ED_OPERADT")
	If GetAdvFVal("SED","ED_OPERADT",xFilial("SED")+cNatureza,1,"") == "1"
		lRet := .F.
		Help(" ",1,"FA087VALNAT")
	EndIf
EndIf

//294 - Natureza sintetica/Analitica

If  ExistBLock('A087NATVAZ') .AND. cPaisLoc != "BRA"
	lVazio	:=	ExecBlock('A087NATVAZ',.F.,.F.)
Endif

SED->(DbSeek( xFilial( "SED" ) + cNatureza ) )

If SED->ED_USO == "3"
	If lRet .and. !FinVldNat( lVazio, cNatureza, 3 )
		lRet := .F.
	Endif
Else
	If lRet .and. !FinVldNat( lVazio, cNatureza, 1 )
		lRet := .F.
	Endif
EndIf

RestArea(aAreaSED)
RestArea(aArea)

Return lRet

/* Lmedina: Funcion para validar el certificado (25 posiciones) y que cotenga el CGC del cliente*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma    ณGetUUID     ณ Autor ณ Raul Ortiz  Medina  ณ Fecha ณ25/05/2017ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescripcion ณObtiene el Timbre Fiscal                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso         ณ SIGAFIN                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetUUID(cCte, cTda, cDoc, cTipo, cPrefixo, cFil, cOrigen)
	Local lRet     := .F.
	Local cTipoDoc := "NF|NDC"

	Default cCte		:= ""
	Default cTda		:= ""
	Default cDoc		:= ""
	Default cTipo		:= ""
	Default cPrefixo	:= ""
	Default cFil	    := ""
	Default cOrigen	    := ""

	If ExistBLock('A087TIPTI')
		cTipoDoc +=	ExecBlock('A087TIPTI',.F.,.F.)
	EndIf

	If AllTrim(cTipo) $ cTipoDoc
		If Alltrim(cOrigen) == "LOJA701" //	Documentos generados desde Ventas Asistidas (SIGALOJA)
			dbSelectArea("SF2")
			SF2->(DbSetOrder(1)) //F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO
			If SF2->(DbSeek(cFil + cDoc + cPrefixo))
				lRet := !Empty(SF2->F2_UUID)
			EndIf
			If !lRet
				dbSelectArea("SF2")
				SF2->(DbSetOrder(6)) //F2_FILIAL + F2_SERIORI + F2_NFORI
				If SF2->(DbSeek(cFil + cPrefixo + cDoc))
					lRet := !Empty(SF2->F2_UUID)
				EndIf
			EndIf
		Else
			dbSelectArea("SF2")
			SF2->(DbSetOrder(2)) //F2_FILIAL + F2_CLIENTE + F2_LOJA + F2_DOC + F2_SERIE
			If SF2->(DbSeek(cFil + cCte + Ctda + cDoc + cPrefixo))
				lRet := !Empty(SF2->F2_UUID)
			EndIf
		EndIf
		If !lRet .And. AllTrim(cTipo) $ "DGA"
			lRet := .T.
		EndIf
	Else
		If AllTrim(cTipo) $ "NCC"
			dbSelectArea("SF1")
			SF1->(DbSetOrder(1)) //"F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO")))
			If SF1->(DbSeek(cFil + cDoc + cPrefixo+cCte+cTda))
				lRet := !Empty(SF1->F1_UUID)
			EndIf
		Else
			lRet := .T.
		EndIf
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma    ณIntegDef   ณ Autor ณ Luis E. Enrํquez Mataณ Fecha ณ16/05/2018ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescripcion ณFunci๓n para integraci๓n EAI                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso         ณ FINA087A                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function IntegDef( cXml, nType, cTypeMsg)
	Local aRet      := {}
	Private aRetMsg	:= {}

	If Type("cIntegSeq")=="U"
		Private cIntegSeq := ""
	EndIf

	ALTERA := .T.
	aRet := FINI087( cXml, nType, cTypeMsg )

	If Len(aRet) > 0
		If !aRet[1]
			MsgAlert(aRet[2])
		EndIf
	EndIf
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma    ณFA087Integ ณ Autor ณ Luis E. Enrํquez Mataณ Fecha ณ16/05/2018ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescripcion ณValida existencia configuraci๓n de Adapter p/integraci๓n EAI ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso         ณ FINA087A                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA087Integ(lCancel,lMSG)
	Local aSave    := {}
	Local lRet     := .T.
	Local cMSg     := ""
	Local cRotina  := "FINA087A"
	Local aXX4     := {}

	Default lMSG  := .T.

	If !(Alltrim(SE1->E1_TIPO)=="PR")
		If lCancel
			cMSg:='REVERSALOFACCOUNTRECEIVABLEDOCUMENTDISCHARGE'
		Else
			cMsg:='ACCOUNTRECEIVABLEDOCUMENTDISCHARGE'
		Endif

	 	If __lF087EAI == NIL
	 		__lF087EAI := FWHasEAI("FINA087A",.T.,,.T.) //Valida que rutina se encuentre configurada como adapter para integraci๓n EAI
	 	Endif

		If __lF087EAI
			aSave := GetArea()
			If Len(aXX4:= FwAdapterInfo(cRotina,cMsg)) > 0
				If !(Alltrim(aXX4[5])=='1')
					If lMSG
						HELP(" ",1,"FA087INTEG",,STR0224,2,0) //"El adapter de Baja de cunetas porCobrar (FINA087A) estแ configurado como NO SINCRONIZADO en el configurador. Configurar como SINCRONIZADO."
					EndIf
					lRet := .F.
				EndIf
			EndIf
			RestArea(aSAve)
		EndIf
	EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma    ณFN087AWHEN    ณ Autor ณ Alfredo Medrano   ณ Fecha ณ06/04/2018ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescripcion ณactiva o desactiva los campos Relacionados al CEP            ณฑฑ
ฑฑณ            ณEL_CEPTIP, EL_CEPCER, EL_CEPCAD y EL_CEPSEL                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso         ณ SIGAFIN                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FN087AWHEN()
	Local lRet			:= .T.
	Local cFormPag		:= M->EL_FORPGO
	Local cPgoBan		:= "02,03,04,05,06,28,29"
	Local nPosRFC		:= aScan(aCposSEL,"EL_RFCEMI")
	Local nPosCTA		:= aScan(aCposSEL,"EL_CTAORD")
	Local nPosCTB		:= aScan(aCposSEL,"EL_CTABEN")
	Local nPosTIP		:= aScan(aCposSEL,"EL_CEPTIP")
	Local nPosBAN		:= IIf(cFormPag $ cPgoBan, aScan(aCposSEL,"EL_BCOCHQ"), aScan(aCposSEL,"EL_BANCO"))
	Local nPosAGE		:= IIf(cFormPag $ cPgoBan, aScan(aCposSEL,"EL_AGECHQ"), aScan(aCposSEL,"EL_AGENCIA"))
	Local nPosCON		:= IIf(cFormPag $ cPgoBan, aScan(aCposSEL,"EL_CTACHQ"), aScan(aCposSEL,"EL_CONTA"))
	Local nPosORD		:= aScan(aCposSEL,"EL_CTAORD")
	Local nPosBEN		:= aScan(aCposSEL,"EL_CTABEN")
	Local nPosCEP		:= aScan(aCposSEL,"EL_CEPCER")
	Local nPosCAD		:= aScan(aCposSEL,"EL_CEPCAD")
	Local nPosSEL		:= aScan(aCposSEL,"EL_CEPSEL")
	Local cCta			:= ""
	Local cCGCBanco		:= ""
	Local lCHVal		:= .F.
	Local cRFCExt		:= ""
	Local cFilSA6		:= xFilial("SA6")
	Local cPatCtaOrd	:= AllTrim(ObtColSAT("S005", cFormPag, 1, 2, 43, 97 - 43))
	Local cPatCtaBen	:= AllTrim(ObtColSAT("S005", cFormPag, 1, 2, 98, 154 - 98))

	If !Empty(cFormPag) .And. !(Upper(ProcName(2)) $ "FA087ALINOK")
		If cFormPag $ "01,08,12,13,14,15,17,23,24,25,26,27,30,31"
			aCols[n][nPosCEP] := ""
			aCols[n][nPosCAD] := ""
			aCols[n][nPosSEL] := ""
			aCols[n][nPosRFC] := Space(TamSx3("EL_RFCEMI")[1])
			aCols[n][nPosCTA] := ""
			aCols[n][nPosCTB] := ""
			aCols[n][nPosTIP] := Space(TamSx3("EL_CEPTIP")[1])
		Else
			If cFormPag == '02' //Cheque
				If !Empty(aCols[n][nPosBAN]) .AND. !Empty(aCols[n][nPosAGE]) .AND. !Empty(aCols[n][nPosCON])
					cCGCBanco := Posicione("SA6",1,cFilSA6+aCols[n][nPosBAN]+aCols[n][nPosAGE]+aCols[n][nPosCON],"A6_CGC")
					If AllTrim(SA6->A6_EST) == "EX"
						lCHVal := .F.
					Else
						lCHVal := IIf(Empty(cCGCBanco), .T., .F.)
					EndIf
				Else
					lCHVal := .T.
				EndIf
			EndIf

			If !(cFormPag $ cPgoBan) .or. lCHVal
				nPosBAN := AScan(aCposSEL,"EL_BANCO")
				nPosAGE := AScan(aCposSEL,"EL_AGENCIA")
				nPosCON := AScan(aCposSEL,"EL_CONTA")
			EndIf

			If AllTrim(aCols[n][nPosRFC]) == ""
				cRFCExt := Posicione("SA6",1,cFilSA6+aCols[n][nPosBAN]+aCols[n][nPosAGE]+aCols[n][nPosCON],"A6_EST")// A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
				If AllTrim(cRFCExt) == "EX"
					cCGCBanco := "XEXX010101000"
				Else
					cCGCBanco := Posicione("SA6",1,cFilSA6+aCols[n][nPosBAN]+aCols[n][nPosAGE]+aCols[n][nPosCON],"A6_CGC")// A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
				EndIf
				aCols[n][nPosRFC] := cCGCBanco
			EndIf

			If AllTrim(aCols[n][nPosORD]) == ""
				cCta := aCols[n][nPosCON]
				FIS815PatCta(@(cCta), 1, AllTrim(M->EL_FORPGO))
				aCols[n][nPosORD] := cCta
			EndIf

			If AllTrim(aCols[n][nPosBEN]) == ""
				nPosCON := aScan(aCposSEL, "EL_CONTA")
				cCta := aCols[n][nPosCON]
				FIS815PatCta(@(cCta), 2, AllTrim(M->EL_FORPGO))
				aCols[n][nPosBEN] := cCta
			EndIf
		EndIf
		If cFormPag $ "02,03,04,05,06,28,29"
			aCols[n][nPosCEP] := ""
			aCols[n][nPosCAD] := ""
			aCols[n][nPosSEL] := ""
			aCols[n][nPosTIP] :=  Space(TamSx3("EL_CEPTIP")[1])
			If Empty(cPatCtaOrd)
				aCols[n][nPosCTA] := ""
			EndIf
			If Empty(cPatCtaBen)
				aCols[n][nPosCTB] := ""
			EndIf
		EndIf
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma    ณFN087AWH    ณ Autor ณ Alfredo Medrano     ณ Fecha ณ09/04/2018ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescripcion ณactiva o desactiva los campos Relacionados al CEP EL_RFCEMI, ณฑฑ
ฑฑณ            ณEL_CTAORD,EL_CEPTIP, EL_CEPCER, EL_CEPCAD y EL_CEPSEL        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso         ณ SIGAFIN                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FN087AWH()

	Local lRet		:= .T.
	Local nPosFRP	:= 0
	Local nPosCepT	:= 0
	Local nPosCam	:= 0
	Local cFrmPag	:= ""
	Local cCepTip	:= ""
	Local cCamTip	:=  AllTrim(SubStr(ReadVar(), 4, Len(ReadVar())))

	nPosFRP := aScan(aCposSEL,"EL_FORPGO")
	cFrmPag := aCols[n][nPosFRP]

	If !Empty(cFrmPag)
		If cFrmPag $ "01,08,12,13,14,15,17,23,24,25,26,27,30,31"
			lRet := .F.
		Endif
		If cFrmPag $ "02,04,05,06,28,29" .And. lRet
			If !(cCamTip $ 'EL_RFCEMI|EL_CTAORD|EL_CTABEN') .Or. (cFrmPag $ "06" .And. cCamTip $ "EL_CTABEN")
				lRet := .F.
			Endif
		EndIf
		If cCamTip $ 'EL_CEPCER|EL_CEPCAD|EL_CEPSEL' .And. lRet
			nPosCepT := AScan(aCposSEL,"EL_CEPTIP ")
			cCepTip := aCols[n][nPosCepT]
			If Empty(cCepTip)
				nPosCam := AScan(aCposSEL,cCamTip)
				M->&(cCamTip):=""
				aCols[n][nPosCam] := ""
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma    ณfVerifImp   ณ Autor ณ Jonathan Gonzalez   ณ Fecha ณ25/05/2017ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescripcion ณObtiene el impuesto del Anticipo en cuentas por pagar        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso         ณ SIGAFIN                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fVerifImp(cNum,cPrefix,cTipo,cCliente, cLoja )

	Local aArea			:= GetArea()
	Local cNumVali		:= ""
	Local nValor		:= 0
	Local cImpAdi		:= ""
	Local cTESD2		:= ""
	Local lAplImpAdi	:= SuperGetMV("MV_ADIAPLI",.F.,.T.)

	If lAplImpAdi
		DBSelectArea("SD2")
		SD2->(DBSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		If DBSeek(xFilial("SD2")+M->E1_NUM+M->E1_PREFIXO+cCliente+cLoja,.F.)
			cTESD2 := &("SD2->D2_TES")
		EndIf

		DbSelectArea("SFC")
		SFC->(DBSetOrder(2)) //FC_FILIAL+FC_TES+FC_IMPOSTO
		If DBSeek(xFilial("SFC")+cTESD2)
			cImpAdi:= &("SFC->FC_IMPOSTO")
			cNumVali := POSICIONE("SFB",1,xFilial("SFB")+PADR(cImpAdi,TamSx3("FB_CODIGO")[1]) ,"FB_CPOLVRO")
        EndIf

		If !Empty(cNum) .and. !Empty(cNumVali)
			DBSelectArea("SF2")
			SF2->(DBSetOrder(2)) //F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE
			If DBSeek(xFilial("SF2")+cCliente+cLoja+M->E1_NUM+M->E1_PREFIXO)
				nValor := &("SF2->F2_VALIMP"+cNumVali)
			EndIf
		EndIf
	EndIF
	RestArea(aArea)

Return  nValor

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma    ณfValTipDoc  ณ Autor ณ Veronica Flo        ณ Fecha ณ19/10/2018ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescripcion ณSi tipo documento es RI, asigna default a Serie Retenci๓n.   ณฑฑ
ฑฑณ            ณPer๚                                                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso         ณ SIGAFIN                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fValTipDoc()
Local nPosSerRet	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_SERRET"})
Local lRet			:= .T.

If cPaisLoc $ "PER" .And. nPosSerRet > 0 .And. n > 0
	If M->EL_TIPODOC $ "RI"
		If Empty(aCols[n][nPosSerRet])
			aCols[n][nPosSerRet] := SuperGetMV("MV_CRSERIE", , Space( aHeader[nPosSerRet][4] ))
		Endif
	Else
		aCols[n][nPosSerRet] := Space( aHeader[nPosSerRet][4] )
	Endif
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma    ณF87AValRec  ณ Autor ณ Luis Enrํquez       ณ Fecha ณ29/11/2018ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescripcion ณValidaciones para recibo a sustituir. (MEX)                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso         ณ SIGAFIN                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F87AValRec(cSer, cRec)
	Local lRet := .F.
	Local lRecAnu := SEL->(ColumnPos("EL_RETGAN")) > 0
	Local cRecSus := ""

	If !Empty(cSer) .Or. !Empty(cRec)
		DbSelectArea("SEL")
		SEL->(DbSetorder(8)) //EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
		If SEL->(dbSeek(xFilial("SEL") + cSer + cRec))
			If SEL->EL_CANCEL .And. !Empty(SEL->EL_UUID) .And. !Empty(SEL->EL_FECTIMB)
				lRet := .T.
				If lRecAnu 
					If !(SEL->EL_RETGAN == "S")
						MsgAlert(STR0259, STR0230) //"Solo se permite sustituir Complementos de Recepci๓n de Pago de Recibos que fueron anulados previamente, pero que no se realiz๓ la solicitud de cancelaci๓n ante el SAT." //"Aviso"
						Return(.F.)
					Else
						If F087VldSus(cSer,cRec,@cRecSus)
							MsgAlert(STR0260 + cRecSus, STR0230) //"El Recibo a Sustituir ya se encuentra relacionado al Cobro Diverso " //"Aviso"
							Return(.F.)
						EndIf
					EndIf
				EndIf
			Else
				MsgAlert(STR0227, STR0230) //"Solo se permite sustituir complementoS para recepci๓n de pagos que ya fueron anulados y contienen un Timbre Fiscal." "Aviso"
				Return(.F.)
			EndIf
		Else
			MsgAlert(STR0228 + IIf(!Empty(cSer),Alltrim(cSer) + "-","") + IIf(!Empty(cRec),Alltrim(cRec),"") + STR0229, STR0230) //"El complemento para recepci๓n de pagos [" "] a sustituir no existe." "Aviso"
			Return(.F.)
		EndIf
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma    ณfActData    ณ Autor ณ Ver๓nica F.         ณ Fecha ณ09/01/2019ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescripcion ณActualiza la fecha de emisi๓n del pago a la fecha seleccionadaฑฑ
ฑฑณ            ณen el recibo. MEXICO                                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso         ณ SIGAFIN                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fActData()
Local nX := 0
Local nPosEmis	:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_EMISSAO"})
	For nX:=1 to Len(aCols)
		aCols[nX][nPosEmis]:= dDataRef
	next nX
	oGetSEL:Refresh()
Return .T.

/*
ฑฑบPrograma  ณfVldGenCFD  บ Autor ณ    Marco Augusto Glz   บ Data ณ  14/01/19   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncion utilizada para validar si el recibo generara CFDI.        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณfVldGenCFD()                                                      บฑฑ
*/
Static Function fVldGenCFD()
	Local lRet			:= .T.
	Local nPosPre		:= aScan(aCposSE1, "E1_PREFIXO"	)
	Local nPosNum		:= aScan(aCposSE1, "E1_NUM"		)
	Local nPosTp		:= aScan(aCposSE1, "E1_TIPO"	)
	Local nPosFil		:= aScan(aCposSE1, "E1_FILIAL"	)
	Local nPosCli		:= aScan(aCposSE1, "E1_CLIENTE"	)
	Local nPosLoja		:= aScan(aCposSE1, "E1_LOJA"	)
	Local nPosTx		:= aScan(aCposSE1, "E1_TXMOEDA"	)
	Local lCompen	    := .F.
	Local nI			:= 0
	Local nDocSonPUE	:= 0
	Local nDocSonPPD	:= 0
	Local cMetPagSAT	:= ""
	Local cMensaje		:= ""
	Local cAviso		:= ""
	Local cSaltoLin		:= Chr(10)+ Chr(13)
	Local nImpSum       := 0
	Local nImpRes       := 0
	Local nX 			:= 0
	Local lActSEL 		:= .F.
	Local nOpcMsj       := IIf(!Empty(MV_PAR10),MV_PAR10,2)

	Private cTipLoja 	:= ""

	If ExistBLock('A087TIPTI')
		cTipLoja :=	ExecBlock('A087TIPTI',.F.,.F.)
	Endif

	For nI := 1 To Len(aLinSE1) //Se recorre array de documentos
		If aLinSE1[nI][1] == 1 //Si el documento esta seleccionado
			If AllTrim(aLinSE1[nI][nPosTp]) $ "NF|NDC|" + cTipLoja //Si el documento es tipo NF o NDC
				nImpSum += aLinSE1[nI][nPosBx] * aLinSE1[nI][nPosTx]
				cMetPagSAT := ""
				           //Filial Origen       Num. Documento        Serie                 Cliente               Tienda                 Tipo de Documento (NF/NDC)    Metodo Pago
				fObtInfCon(aLinSE1[nI][nPosFil], aLinSE1[nI][nPosNum], aLinSE1[nI][nPosPre], aLinSE1[nI][nPosCli], aLinSE1[nI][nPosLoja], AllTrim(aLinSE1[nI][nPosTp]), @cMetPagSAT)

				If AllTrim(cMetPagSAT) != "PUE"
					nDocSonPPD += 1 //Incrementa contador de NF/NDC que tienen Metodo Pago PPD
				Else
					nDocSonPUE += 1 //Incrementa contador de NF/NDC que tienen Metodo Pago PUE
				EndIf
			ElseIf AllTrim(aLinSE1[nI][nPosTp]) $ "NCC|RA" //Si el documento es tipo NCC o RA
				nImpRes += aLinSE1[nI][nPosBx] * aLinSE1[nI][nPosTx]
				lCompen := .T.
			EndIf
		EndIf
	Next nI

	For nX:= 1 To Len(aCols)
		If aCols[nX,Len(aCols[1])-1] <> Nil
			If aCols[nX,Len(aCols[1])] == .F.
				lActSEL := .T.
				Exit
			EndIf
		EndIf
	Next

	If nImpRes > 0
		If lCompen .And. !lActSEL   //Compensaciones
			lSolTimCFD := .F.
			cMensaje += STR0235 + cSaltoLin //" - Es una compensaci๓n de documentos."
		ElseIf nDocSonPUE > 0 .And. nDocSonPPD == 0
			lSolTimCFD := .F.
			cMensaje += STR0235 + cSaltoLin //" - Es una compensaci๓n de documentos."
			cMensaje += STR0236 + cSaltoLin //" - Existen documentos seleccionados que fueron pagados en una sola exhibici๓n (PUE)."
		ElseIf nDocSonPUE == 0 .And. nDocSonPPD > 0
			cMensaje += STR0235 + cSaltoLin //" - Es una compensaci๓n de documentos."
			cMensaje += STR0237 + cSaltoLin //" - Existen documentos seleccionados que requieren generaci๓n de complemento de pago (con condici๓n de pago en parcialidades - PPD)."
			cMensaje += STR0238 + cSaltoLin //"   Soluci๓n: Realizar procesos por separado en diferentes recibos."
			lSolTimCFD := .F.
			lRet := .F.
		Else
			If nImpSum > 0
				lSolTimCFD := .F.
				cMensaje += STR0235 + cSaltoLin //" - Es una compensaci๓n de documentos."
				cMensaje += STR0236 + cSaltoLin //" - Existen documentos seleccionados que fueron pagados en una sola exhibici๓n (PUE)."
			EndIf
		EndIf
	Else
		If nDocSonPUE > 0 .And. nDocSonPPD == 0
			cMensaje += STR0236 + cSaltoLin //" - Existen documentos seleccionados que fueron pagados en una sola exhibici๓n (PUE)."
			lSolTimCFD := .F.
		ElseIf nDocSonPUE > 0 .And. nDocSonPPD > 0
			cMensaje += STR0239 + cSaltoLin //"Se estแ intenando dar de baja documentos con forma de pago en una sola exhibici๓n (PUE) y Parcialidades (PPD)."
			lSolTimCFD := .F.
			lRet := .F.
		EndIf
	EndIf

	If !Empty(cMensaje) //Si hay mensaje para mostrar
		If lRet
			If (nOpcMsj != 1)
				cAviso += STR0232 + cSaltoLin + cMensaje //"No se solicitarแ el timbrado del recibo, por las siguientes caracterํsticas:"
				MsgInfo(cAviso, STR0231) //"Observaciones"
			EndIf
		Else
			cAviso += STR0234 + cSaltoLin + cMensaje //"No se permitirแ el grabado del recibo, por las siguientes caracterํsticas:"
			MsgAlert(cAviso, STR0233) //"Atenci๓n"
		EndIf
	EndIf
Return lRet

/*
ฑฑบPrograma  ณfObtInfCon  บ Autor ณ    Marco Augusto Glz   บ Data ณ  14/01/19   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณObtiene informacion de Condici๓n de Pago para documentos tipo NF yบฑฑ
ฑฑบ          ณNDC, seleccionados en Cobros Diversos.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณfObtFilSE4(cExp1, cExp2, cExp3, cExp4, cExp5, cExp6, cExp7)       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcExp1 - Filial Origen                                             บฑฑ
ฑฑบ          ณcExp2 - Folio de Documento                                        บฑฑ
ฑฑบ          ณcExp3 - Serie                                                     บฑฑ
ฑฑบ          ณcExp4 - Cliente                                                   บฑฑ
ฑฑบ          ณcExp5 - Tienda                                                    บฑฑ
ฑฑบ          ณcExp6 - Tipo de Documento                                         บฑฑ
ฑฑบ          ณcExp7 - Metodo de Pago SAT                                        บฑฑ
*/
Static Function fObtInfCon(cFilOri, cNumDoc, cSerie, cCliente, cLoja, cTipoDoc, cMetPagSAT)
	Local aArea		:= GetArea()
	Local cCondPag	:= ""
	Local lModComp	:= IIf(FWSizeFilial() > 2, FWModeAccess("SE4", 1) == "E", FWModeAccess("SE4", 3) == "E") //Verifica el acceso a nivel empresa o a nivel filial
	Local cFilSE4	:= xFilial("SE4")

	Default cFilOri		:= xFilial("SF2")
	Default cNumDoc		:= ""
	Default cSerie		:= ""
	Default cCliente	:= ""
	Default cLoja		:= ""

	If AllTrim(cTipoDoc) $ "NF|NDC|" + cTipLoja
		DBSelectArea("SF2")
		SF2->(DBSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		If SF2->(MsSeek(cFilOri + cNumDoc + cSerie + cCliente + cLoja))
			cCondPag := SF2->F2_COND
		EndIf

		DbSelectArea("SE4")
		SE4->(DbSetOrder(1)) //"E4_FILIAL+E4_CODIGO"
		If SE4->(MsSeek((IIf(!lModComp, cFilSE4, cFilOri) + cCondPag)))
			cMetPagSAT	:= SE4->E4_MPAGSAT
		EndIf
	EndIf

	RestArea(aArea)
Return

/*
ฑฑบPrograma  ณA87VFactor  บ Autor ณ Alberto Rodriguez      บ Data ณ 14/05/2019  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida que campo EL_FACTOR sea 1 o 2                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณA87VFactor()                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ.T. = OK                                                          บฑฑ
ฑฑบ          ณ.F. = No vแlido                                                   บฑฑ
*/
Static Function A87VFactor()
	Local lRet	:= .T.

	If Empty(M->cFactor) .Or. !(M->cFactor $ "1|2|")
		Help( ,, STR0149,, STR0242,1 , 0 )//"Atencion" //"Debe especificar si se considera o no cobro mediante factoraje financiero."
		lRet := .F.
	EndIf

Return lRet

/*
ฑฑบPrograma  ณFA087Comp   บ Autor ณ Alberto Rodriguez      บ Data ณ 14/03/2019  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDetermina si el tํtulo por cobrar tiene relacionado un movimiento บฑฑ
ฑฑบ          ณde compensaci๓n entre carteras.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณFA087Comp(nExp1, nExp2, nExp3, nExp4)                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnExp1 - Posici๓n cliente en el grid                               บฑฑ
ฑฑบ          ณnExp2 - Posici๓n loja en el grid                                  บฑฑ
ฑฑบ          ณnExp3 - Posici๓n serie en el grid                                 บฑฑ
ฑฑบ          ณnExp4 - Posici๓n documento en el grid                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณValor de compensaci๓n entre carteras, o cero                      บฑฑ
*/
Static Function FA087Comp(nCliente, nLoja, nSerie, nDoc)
	Local aCompensa	:= {}
	Local aAreaSE5	:= SE5->(GetArea())
	Local cTemp		:= GetNextAlias()
	Local aStruSE5	:= SE5->(DbStruct())
	Local nPosParc	:= aScan(aCposSE1, "E1_PARCELA")
	Local nPosTipo	:= aScan(aCposSE1,"E1_TIPO")
	Local cPicComp := "@E 999,999,999,999.99"
	Local nCompen	:= 0
	Local cMsj		:= ""
	Local nX		:= 0
	Local oDlgComp
	Local oBrowse
	Local bDlgInit	:= { || EnchoiceBar( oDlgComp , {|| nOpc:=1, oDlgComp:End()} , {|| nOpc:=0, oDlgComp:End()} , Nil , Nil )}
	Local oOk	    := LoadBitmap(GetResources(),"LBOK")
	Local oNo	    := LoadBitmap(GetResources(),"LBNO")
	Local aCampos	:= {"E5_DATA", "E5_VALOR", "E5_IDENTEE", "E5_BENEF", "E5_PREFIXO", "E5_NUMERO", "E5_PARCELA"}
	Local aEncab	:= {}
	Local aLong		:= {}
	Local nOpc   	:= 0
	Local nMovs		:= 0
	Local aRecSE5	:= {}
	Local cWhereCom	:= "% %"

	If SEL->(ColumnPos('EL_IDENTEE')) > 0 .And. SEL->(ColumnPos('EL_FCHIDEN')) > 0
		cWhereCom := "% AND NOT EXISTS(SELECT NULL"
		cWhereCom += " FROM "+ RetSqlName("SEL") + " SEL"
		cWhereCom += " WHERE SEL.EL_IDENTEE = SE5.E5_IDENTEE"
		cWhereCom += " AND SEL.EL_FCHIDEN = SE5.E5_DATA"
		cWhereCom += " AND SEL.EL_CANCEL <> 'T'"
		cWhereCom += " AND SEL.D_E_L_E_T_ = '')%"
	EndIf

	If cCliente+cLoja == aLinSE1[oLBSE1:nAt][nCliente]+aLinSE1[oLBSE1:nAt][nLoja]
		// Cliente que paga y el de la factura es el mismo, no procede
		Return nCompen
	Endif

	CursorWait()

	// Busca registros generados por compensaci๓n entre carteras (E5_ORIGEM = 'FINA450')
	SE5->(dbSetOrder(2))	//E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DTOS(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ

	BEGINSQL ALIAS cTemp
		SELECT SE5.E5_DATA, SE5.E5_MOEDA, SE5.E5_TXMOEDA, SE5.E5_VALOR, SE5.E5_VLMOED2, SE5.E5_IDENTEE, CMP.E5_BENEF, CMP.E5_PREFIXO, CMP.E5_NUMERO, CMP.E5_PARCELA, SE5.R_E_C_N_O_
		FROM %Table:SE5% SE5
		INNER JOIN %Table:SE5% CMP
		ON CMP.%notdel%
		AND CMP.E5_FILIAL =  SE5.E5_FILIAL
		AND CMP.E5_TIPO =    SE5.E5_TIPO
		AND CMP.E5_RECPAG =  'P'
		AND CMP.E5_TIPODOC = SE5.E5_TIPODOC
		AND CMP.E5_MOTBX =   SE5.E5_MOTBX
		AND CMP.E5_SITUACA = SE5.E5_SITUACA
		AND CMP.E5_ORIGEM =  SE5.E5_ORIGEM
		AND CMP.E5_IDENTEE = SE5.E5_IDENTEE
		WHERE SE5.%notdel%
		AND SE5.E5_FILIAL = %xFilial:SE5%
		AND SE5.E5_TIPO = %exp:aLinSE1[oLBSE1:nAt][nPosTipo]%
		AND SE5.E5_RECPAG = 'R'
		AND SE5.E5_TIPODOC = 'BA'
		AND SE5.E5_MOTBX = 'CEC'
		AND SE5.E5_SITUACA = ''
		AND SE5.E5_ORIGEM = 'FINA450'
		AND SE5.E5_CLIFOR = %exp:aLinSE1[oLBSE1:nAt][nCliente]%
		AND SE5.E5_LOJA = %exp:aLinSE1[oLBSE1:nAt][nLoja]%
		AND SE5.E5_PREFIXO = %exp:aLinSE1[oLBSE1:nAt][nSerie]%
		AND SE5.E5_NUMERO = %exp:aLinSE1[oLBSE1:nAt][nDoc]%
		AND SE5.E5_PARCELA = %exp:aLinSE1[oLBSE1:nAt][nPosParc]%
		AND SE5.E5_RECCMP = ' '
		%Exp:cWhereCom%
		ORDER BY SE5.E5_IDENTEE
	ENDSQL

	For nX := 1 To Len(aStruSE5)
		If Trim(aStruSE5[nX][1]) $ "E5_DATA|E5_VALOR|E5_VLMOED2|E5_TXMOEDA"
			TcSetField(cTemp, aStruSE5[nX][1], aStruSE5[nX][2], aStruSE5[nX][3], aStruSE5[nX][4])
		EndIf
	Next nX

	(cTemp)->(dbGoTop())

	While !(cTemp)->(EOF())
		aAdd(aCompensa , { .F., (cTemp)->E5_DATA, (cTemp)->E5_VALOR, (cTemp)->E5_IDENTEE, (cTemp)->E5_BENEF, (cTemp)->E5_PREFIXO, (cTemp)->E5_NUMERO, (cTemp)->E5_PARCELA, (cTemp)->R_E_C_N_O_ })
		(cTemp)->(dbSkip())
	EndDo

	(cTemp)->(dbCloseArea())
	SE5->(RestArea(aAreaSE5))
	CursorArrow()

	If Len(aCompensa) == 0
		// Sin compensaciones
		Return nCompen
	EndIf

	// Encabezados y longitud de campos para browse
	aAdd(aEncab,"")
	aAdd(aLong,5)

	For nX := 1 to Len(aCampos)
		aAdd(aEncab,GetSx3Cache(aCampos[nX],"X3_TITULO"))
		aAdd(aLong,GetSx3Cache(aCampos[nX],"X3_TAMANHO"))
	Next nX

	Do While .T.
		// Browse para selecci๓n de compensaci๓n a vincular con el pago que se registra
		DEFINE MSDIALOG oDlgComp FROM 001,001 TO 300,600 TITLE STR0255 PIXEL   //"Operaciones de Factoraje Financiero - Compensaciones"

		@ 110,001 Say STR0256 OF oDlgComp PIXEL	//"Las compensaciones mostradas corresponden a la factura a la que se registra el pago."
		@ 120,001 Say STR0257 OF oDlgComp PIXEL	//"Marque la(s) compensaci๓n(es) que debe(n) complementar el CFDI de REP."
		@ 130,001 Say STR0258 OF oDlgComp PIXEL	//"Si se selecciona mแs de un movimiento, se generarแ un solo nodo Pago por el total de estas operaciones."

		oBrowse := TWBrowse():New(035,001,300,060,,aEncab,aLong,oDlgComp,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
		oBrowse:SetArray(aCompensa)
		oBrowse:bLine := {||{IIf(aCompensa[oBrowse:nAt,01],oOK,oNO),aCompensa[oBrowse:nAt,02],Transform(aCompensa[oBrowse:nAt,03],cPicComp),;
		aCompensa[oBrowse:nAt,04],aCompensa[oBrowse:nAt,05],aCompensa[oBrowse:nAt,06],aCompensa[oBrowse:nAt,07],aCompensa[oBrowse:nAt,08] } }
		// Troca a imagem no duplo click do mouse
		oBrowse:bLDblClick := {|| aCompensa[oBrowse:nAt][1] := !aCompensa[oBrowse:nAt][1],;
		oBrowse:DrawSelect()}

		ACTIVATE DIALOG oDlgComp ON INIT Eval(bDlgInit) CENTERED

		nCompen := 0
		nMovs := 0
		aSize( aRecSE5 ,0 )

		If nOpc == 1
			For nX := 1 to Len(aCompensa)
				If aCompensa[nX,01]
					nCompen += aCompensa[nX,03]
					nMovs++
					aAdd( aRecSE5 , aCompensa[nX,09] )
				EndIf
			Next nX
		EndIf

		If nMovs == 0
			cMsj := STR0245 // "No hay selecci๓n de compensaci๓n. En el CFDI de REP, no se generarแ nodo Pago por operaciones de factoraje financiero."
		ElseIf nMovs > 1
			cMsj := STR0246 // "Hay selecci๓n de mแs de una compensaci๓n. En el CFDI de REP, se generarแ un solo nodo Pago, del total, por operaciones de factoraje financiero."
		Else
			cMsj := STR0247 // "ฟEstแ de acuerdo en generar nodo Pago de la compensaci๓n en el CFDI de REP?"
		EndIf

		If MsgYesNo( OemToAnsi(cMsj) , OemToAnsi(STR0251) )
			If nMovs > 0
				aAdd( aSE5Comp , {aLinSE1[oLBSE1:nAt][nCliente]+aLinSE1[oLBSE1:nAt][nLoja]+aLinSE1[oLBSE1:nAt][nSerie]+aLinSE1[oLBSE1:nAt][nDoc]+aLinSE1[oLBSE1:nAt][nPosParc]+aLinSE1[oLBSE1:nAt][nPosTipo],aRecSE5})
			EndIf
			Exit
		EndIf
	Enddo

	DeleteObject(oOk)
	DeleteObject(oNo)
Return nCompen


/*/{Protheus.doc} F087getFin
Obtiene si debe mostrarse la pantalla Financiera en el m๓dulo o no
@type function
@author veronica.flores
@since 23/10/2019
@version 1.0
@param cTipo, String, Tipo de Valor de Cobro Diverso
@return lRet, Logico.
/*/
Static Function F087getFin(cTipo)
	Local lRet 		:= .F.
	Local cTempSAE 	:= getNextAlias()
	Local aAreaTMP := GetArea()
	BEGINSQL ALIAS cTempSAE
		SELECT AE_FINANCI
		FROM %TABLE:SAE% SAE
		WHERE AE_FILIAL+AE_TIPO=%EXP:xFilial("SAE")+ cTipo%
		AND SAE.%NOTDEL%
	ENDSQL
	TCSetField(cTempSAE,"AE_FINANCI","C")

	While (cTempSAE)->(!Eof())
		If (cTempSAE)->AE_FINANCI <> "2"
			lRet := .T.
		EndIf
		(cTempSAE )->(DBSKIP())
	EndDo
	(cTempSAE )->(dbCloseArea())
	RestArea(aAreaTMP)
Return lRet

/*/{Protheus.doc} FA087SE5
//Actualiza en tablas de movimientos bancarios los registros de compensaci๓n entre carteras relacionado al tํtulo por cobrar.
@author arodriguez
@since 11/05/2020
@version 1.0
@return Nil
@param nLin, numerico, numero de item del browse de titulos a cobrar
/*/
Static Function FA087SE5(nLin)
	Local aAreaAnt	:= GetArea()
	Local aAreaSE5	:= SE5->(GetArea())
	Local aAreaFK1	:= FK1->(GetArea())
	Local aAreaFK2	:= FK2->(GetArea())
	Local nPosCli	:= Ascan( aCposSE1, "E1_CLIENTE")
	Local nPosLoja	:= Ascan( aCposSE1, "E1_LOJA")
	Local nPosPref	:= Ascan( aCposSE1, "E1_PREFIXO")
	Local nPosNum	:= Ascan( aCposSE1, "E1_NUM")
	Local nPosParc	:= Ascan( aCposSE1, "E1_PARCELA")
	Local nPosTipo	:= Ascan( aCposSE1, "E1_TIPO")
	Local cIdOrig	:= ""
	Local cTabOri	:= ""
	Local nSE5		:= 0
	Local nX		:= 0

	nSE5 := aScan( aSE5Comp , {|x| x[1] == aLinSE1[nLin][nPosCli]+aLinSE1[nLin][nPosLoja]+aLinSE1[nLin][nPosPref]+aLinSE1[nLin][nPosNum]+aLinSE1[nLin][nPosParc]+aLinSE1[nLin][nPosTipo] } )

	If nSE5 > 0 .And. Len(aSE5Comp[nSE5][2]) > 0

		FK1->(DbSetorder(1))
		FK2->(DbSetorder(1))

	 	For nX := 1 to Len(aSE5Comp[nSE5][2])

	 		// Actualiza en SE5 serie y numero de recibo
			SE5->(MsGoto(aSE5Comp[nSE5][2][nX]))
			RecLock("SE5",.F.)
			SE5->E5_SERCMP := cSerie
			SE5->E5_RECCMP := cRecibo
			cIdOrig := SE5->E5_IDORIG
			cTabOri := SE5->E5_TABORI
			SE5->(MsUnlock())

			If (cTabOri)->(DbSeek(xFilial(cTabOri)+cIdOrig))
				// Actualiza en nueva tabla de movimientos bancarios (FK1/FK2) serie y numero de recibo
				// Usa E5_TABORI para confirmar la tabla a actualizar (FK1==CxC)
				RecLock(cTabOri,.F.)

				If cTabOri == "FK1"
					FK1->FK1_SERCMP := cSerie
					FK1->FK1_RECCMP := cRecibo
				ElseIf cTabOri == "FK2"
					FK2->FK2_SERCMP := cSerie
					FK2->FK2_RECCMP := cRecibo
				EndIf

				(cTabOri)->(MsUnlock())
			EndIf

		Next nX

		SE5->(RestArea(aAreaSE5))
		FK1->(RestArea(aAreaFK1))
		FK2->(RestArea(aAreaFK2))
		RestArea(aAreaAnt)

	EndIf

Return Nil

/*/{Protheus.doc} fnPesqPict
	Stack de PesqPict
	type  Funtion
	@since @23/02/2021
	@version v1
	@param cAlias, c, alias
	@param cCampo, c, campo
	@param nTamanho, n, longitud
	@param nMoeda, n, n๚mero moneda
	@return cPicture, c, Picture del cCampo
	@example
	fnPesqPict("SE1","E1_VALOR",18)
	@see (PesqPict())
/*/
Static Function fnPesqPict(cAlias, cCampo, nTamanho, nMoeda)

Local cPicture := ""
Local nPosPict := 0

If _aPesqPict == NIL
	_aPesqPict := {}
EndIf

nPosPict := aScan(_aPesqPict, {|x| x[1] == cAlias .And. x[2] == cCampo .And. x[3] == nTamanho .And. x[4] == nMoeda })

If nPosPict == 0  //se nao encontrou no array faz pesquisa picture - funcao de lib
	cPicture := PesqPict(cAlias, cCampo, nTamanho, nMoeda)
	aAdd(_aPesqPict, {cAlias, cCampo, nTamanho, nMoeda, cPicture})
Else
	cPicture := _aPesqPict[nPosPict, 5]
EndIf

Return(cPicture)

/*/{Protheus.doc} F87AMetAvg
	Funci๓n utilizada para incluir una m้trica de Tipo Average, que
	saca el promedio de Formas de Pago utilizadas en Cobros Diversos.

	@type Static Function
	@author marco.rivera
	@since 15/09/2021
	@version 1.0
	@param aCols, Array, Arreglo con las Formas de Pago utilizada en el Recibo.
	@param aHeader, Array, Arreglo con los campos del encabezado del aCols.
	@example
	F87AMetAvg(aCols)
	@see (links_or_references)
	/*/
Static Function F87AMetAvg(aHeader, aCols)
	
	Local aArea			:= GetArea()
	Local aTipForPgo	:= {}
	Local nPosForPgo	:= 0
	Local cIdMetAvg		:= "financiero-protheus_cantidad-cobros-diversos-mod1-registrados-por-tipo-de-formas-de-pago-por-recibo-por-pais-por-empresa_average"
	Local cSubRutina	:= ""
	Local cRutAutTIR	:= IIf(GetRemoteType() == 5, "_auto", "") //Si es ejecuci๓n automแtica con TIR agrega identificador
	Local nIteracion	:= 0
	Local nPosTpDoc		:= AScan(aHeader, {|x| Alltrim(x[2]) == "EL_TIPODOC"})

	Default aHeader		:= {}
	Default aCols		:= {}

	For	nIteracion := 1 To Len(aCols)
		If !(aCols[nIteracion][Len(aCols[nIteracion])]) //Descarta registros eliminados
			nPosForPgo := aScan(aTipForPgo, {|x| x[1] == aCols[nIteracion][nPosTpDoc] })
			If nPosForPgo == 0 //Se descartan Formas de Pago que no est้n en el arreglo
				aAdd(aTipForPgo, {aCols[nIteracion][nPosTpDoc], 1})
			Else
				aTipForPgo[nPosForPgo][2]++ //Se suma la cantidad de una misma Forma de Pago
			EndIf
		EndIf
	Next nIteracion

	For	nIteracion := 1 To Len(aTipForPgo)
		cSubRutina := "Forma_Pago_por_Recibo_" + AllTrim(cPaisLoc) + "_" + AllTrim(aTipForPgo[nIteracion][1]) + cRutAutTIR
        FWCustomMetrics():setAverageMetric(cSubRutina, cIdMetAvg, aTipForPgo[nIteracion][2], /*dDateSend*/, /*nLapTime*/, "FINA087A")
	Next nIteracion

	RestArea(aArea)

Return

/*/{Protheus.doc} VldLibMet
	Funci๓n utilizada para validar si el ambiente tiene la libreria para
	utilizaci๓n de Metrํcas Protheus.

	@type Static Function
	@author marco.rivera
	@since 15/09/2021
	@version 1.0
	@example
	VldLibMet()
	@see (links_or_references)
	/*/
Static Function VldLibMet()
	Local lRet	:= .F.

	lRet := (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')

Return lRet

/*/{Protheus.doc} F815UPDCAN
Funci๓n que obtiene el motivo del Cobro Diverso a sustituir.
@type function
@author luis.enriquez
@since 16/02/2022
@version 1.0
@param cSerSus, caracter, Serie el Recibo cancelado.
@param cRecSus, caracter, Folio de Recibo cancelado.
/*/
Static Function F087ObtMot(cSerSus,cRecSus)
	Local aSELArea := SEL->(GetArea())
	Local cFilSEL  := xFilial("SEL")
	Local cMotivo  := "01"
	
	Default cSerSus := ""
	Default cRecSus := ""

	DbSelectArea("SEL")
	SEL->(DbSetOrder(8)) //EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
	If SEL->(DbSeek(cFilSEL + cSerSus + cRecSus))
		cMotivo := SEL->EL_TIPAGRO
	EndIf
	RestArea(aSELArea)
Return cMotivo

/*/{Protheus.doc} F087VldSus
Funci๓n que e recibo a sustituir no se encuentre relacionado a otro Cobro Diverso.
@type function
@author luis.enriquez
@since 16/02/2022
@version 1.0
@param cSerSus, caracter, Serie el Recibo cancelado.
@param cRecSus, caracter, Folio de Recibo cancelado.
/*/
Static Function F087VldSus(cSerSus, cRecSus, cRecEx)
	Local cAliasSus := getNextAlias()
	Local lRet := .F.
	Local nCount := 0
	Local lUsoSer := SuperGetMV('MV_SERREC')
	
	Default cSerSus := ""
	Default cRecSus := ""
	Default cRecEx  := ""

	BeginSql alias cAliasSus
		SELECT EL_SERIE, EL_RECIBO
		FROM %table:SEL% SEL
		WHERE 
		EL_SERSUS = %exp:cSerSus%
		AND EL_RECSUS = %exp:cRecSus%
		AND SEL.%notDel%
	EndSql

	count to nCount

	If nCount > 0
		lRet := .T.
		DBSelectArea(cAliasSus)
		(cAliasSus)->(DbGoTop())
		While (cAliasSus)->(!Eof())
			If lUsoSer
				cRecEx := Alltrim((cAliasSus)->EL_SERIE) + "/" + Alltrim((cAliasSus)->EL_RECIBO)
			Else
				cRecEx :=  Alltrim((cAliasSus)->EL_RECIBO)
			EndIf
			(cAliasSus)->(DbSkip())
		EndDo
	EndIf

	(cAliasSus)->(dbCloseArea())
Return lRet

/*/{Protheus.doc} ExpRot087a
	Apresenta uma tela informando que a rotina sera descontinuada
	@type  Function
	@author jos้ Gonzalez
	@since 30/03/2022
	@version 1.0
	@param cExpirFunc, caracter, nombre de la rutina a interrumpir
	@param cDescrFunc, caracter, descricaod a rotina e nome da rotina que substitui a rotina descontinuada
	@param cExpiraData, caracter, La fecha de la experiencia para ser informado debe estar en formato AAAAMMDD
	@param cEndWeb, caracter, direcci๓n http que hace referencia a la rutina que se estแ descontinuando
/*/
Static Function ExpRot087a(cExpirFunc as character, cDescrFunc as character, cEndWeb as character, cExpiraData as character, nPauseDays as numeric, cBlocData as character)
Local dDate      as date
Local oProfile   as object
Local aLoad      as array
Local cShow      as character
Local lCheck     as logical


//Fecha de caducidad de rutina
DEFAULT cExpiraData := "20230701"

// n๚mero de dํas que el mensaje puede ser deshabilitado
DEFAULT nPauseDays := 30

//Fecha a partir de la cual se bloquea la rutina
Default cBlocData := '20230701'

dDate := dDataBase
oProfile := FwProFile():New()
oProfile:SetTask("ESTExpired") //nombre de la sesi๓n
oProfile:SetType(cExpirFunc) //Valor
aLoad := oProfile:Load()
If Empty(aLoad)
	cShow := "00000000"
Else
	cShow := aLoad[1]
Endif

// restablece el control de nPauseDays dํas y vuelve a mostrar la pantalla de advertencia
If cShow <> "00000000" .and. STOD(cShow) + nPauseDays <= dDate
	cShow := "00000000"
	oProfile:SetProfile({cShow})
	oProfile:Save()
ENDIF

If cShow == "00000000"
	lCheck := DlgExp087a(cExpiraData, nPauseDays, cDescrFunc, cEndWeb, cBlocData)

	If lCheck
		cShow := dtos(dDataBase)	
		oProfile:SetProfile({cShow})
		oProfile:Save()
	EndIf

EndIf

oProfile:Destroy()
oProfile := nil
aLoad := aSize(aLoad,0)
aLoad := nil

RETURN


/*/{Protheus.doc} DlgExp087a
	Presenta la pantalla de una rutina que serแ descontinuada
	@type  Function
	@author Jose Gonzalez
	@since 17/03/2022
	@version 1.0
	@param cExpiraData, caracter, La fecha de la experiencia para ser informado debe estar en formato AAAAMMDD
	@param nPauseDays, numeric, n๚mero de dํas que se puede ocultar el mensaje
	@param cDescrFunc, caracter, descripci๓n de la rutina y nombre de la rutina que reemplaza a la rutina descontinuada
	@param cEndWeb, caracter, direcci๓n http que hace referencia a la rutina que se estแ descontinuando
	@return lCheck, logico, Verdadero si elige deshabilitar el mensaje durante 30 dํas
/*/
Static Function DlgExp087a(cExpiraData as character, nPauseDays as numeric, cDescrFunc as character, cEndWeb as character, cBlocData as character)
local oSay1    as object
local oSay2    as object
local oSay3    as object
local oSay4    as object
local oCheck1  as object
local oModal   as object
Local cMsg1    as character
Local cMsg2    as character
Local cMsg3    as character
Local cMsg4    as character

Local cRelease as character
Local lCheck   as logical

cRelease := GetRPORelease() 

oModal := FWDialogModal():New()
oModal:SetCloseButton( .F. )
oModal:SetEscClose( .F. )
oModal:setTitle(STR0261) //"Comunicado Ciclo de Vida de Sofware - TOTVS Linha Protheus"

//establece la altura y el ancho de la ventana en pํxeles
oModal:setSize(180, 250)

oModal:createDialog()

oModal:AddButton( STR0262, {||oModal:DeActivate()}, STR0262, , .T., .F., .T., ) //"Confirmar"

oContainer := TPanel():New( ,,, oModal:getPanelMain() )
oContainer:Align := CONTROL_ALIGN_ALLCLIENT
If DToS(dDataBase) < cExpiraData
	cMsg1 := i18n(STR0263 ,{cValToChar(stod(cExpiraData))}) // ""Esta rutina se descontinuarแ el #1[01/07/2023]#.
EndIf

cMsg2 := i18n(STR0264, {cDescrFunc} ) //"La rutina que la sustituirแ es la de TOTVS Recibo (FINA998), ya disponible en nuestro producto desde la versi๓n 12.1.2210."
cMsg4 :=  STR0265//"Para mแs informaci๓n, por favor entre en contacto con el administrador del sistema o su ESN TOTVS."

oSay1 := TSay():New( 10,10,{||cMsg1 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)

oSay2 := TSay():New( 30,10,{||cMsg2 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)

cMsg3 := Alltrim(STR0266 )+space(01) //"Para conocer mแs sobre la convergencia entre estas rutinas,"
If ! Empty(cEndWeb)
	cMsg3 += "<b><a target='_blank' href='"+cEndWeb+"'> "
	cMsg3 += Alltrim(STR0267) // "haga clic aquํ"
	cMsg3 += " </a></b>."
	cMsg3 += "<span style='font-family: Verdana; font-size: 12px; color: #565759;' >" + ' ' +"</span>"
	oSay3 := TSay():New(50,10,{||cMsg3},oContainer,,,,,,.T.,,,220,20,,,,,,.T.)
	oSay3:bLClicked := {|| MsgRun( STR0268, "URL",{|| ShellExecute("open",cEndWeb,"","",1) } ) } // "Abriendo el enlace... Espere..."
EndIf
oSay4 := TSay():New( 70,10,{||cMsg4 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)

lCheck := .F.
oCheck1 := TCheckBox():New(90,10,i18n( STR0269 ,{strzero(nPauseDays,2)}) ,{|x|If(Pcount()==0,lCheck,lCheck:=x)},oContainer,220,21,,,,,,,,.T.,,,) // "No presentar este mensaje en los pr๓ximos #1[30]# dํas."

oModal:Activate()

Return lCheck

/*/{Protheus.doc} F087InfCom
	Funci๓n para validar la existencia y estado de la compensaci๓n informada
	@type  Function
	@author oscar.lopez
	@since 11/05/2022
	@version 1.0
	@param cNumComp, caracter, Numero de Identificaci๓n de Compensaci๓n
	@param dFechComp, fecha, Fecha del movimiento
	@param lConsult, caracter, Fecha del movimiento
	@param aCompensa, arreglo, Arreglo para a๑adir los documentos que serแn a๑adidos al XML.
	@return lRet, logico, Retorna .T. si se encuentra la compensaci๓n indicada
	@example
		F087InfCom(cNumComp, cFechComp)
	/*/
Function F087InfCom(cNumComp, dFechComp, lConsulta, aCompensa)

	Local lRet		:= .T.
	Local cTemp		:= ""
	Local aStruSE5	:= {}
	Local aArea		:= {}
	Local nX		:= 0
	Local cFecComp	:= ""

	Default lConsulta	:= .F.
	Default aCompensa	:= {}


	If !Empty(cNumComp) .And. !Empty(dFechComp)
		cTemp		:= GetNextAlias()
		aStruSE5	:= SE5->(DbStruct())
		aArea		:= GetArea()
		cFecComp	:= DtoS(dFechComp)

		BEGINSQL ALIAS cTemp
			SELECT E5_FILORIG, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_DATA, E5_TIPO, E5_MOEDA, E5_TXMOEDA, E5_VALOR, E5_VLMOED2, E5_CLIFOR, E5_LOJA
			FROM %Table:SE5%
			WHERE %notdel%
				AND E5_FILIAL = %xFilial:SE5%
				AND E5_RECPAG = 'R'
				AND E5_TIPODOC = 'BA'
				AND E5_MOTBX = 'CEC'
				AND E5_SITUACA = ''
				AND E5_ORIGEM = 'FINA450'
				AND E5_RECCMP = ' '
				AND E5_IDENTEE = %Exp:cNumComp%
				AND E5_DATA = %Exp:cFecComp%
			ORDER BY E5_FILIAL, E5_DATA, E5_IDENTEE
		ENDSQL

		(cTemp)->(dbGoTop())

		For nX := 1 To Len(aStruSE5)
			If Trim(aStruSE5[nX][1]) $ "E5_DATA|E5_TXMOEDA|E5_VALOR|E5_VLMOED2"
				TcSetField(cTemp, aStruSE5[nX][1], aStruSE5[nX][2], aStruSE5[nX][3], aStruSE5[nX][4])
			EndIf
		Next nX


		While !(cTemp)->(EOF())
			Aadd(aCompensa, {(cTemp)->E5_DATA, Iif((cTemp)->E5_VALOR == (cTemp)->E5_VLMOED2, (cTemp)->E5_MOEDA, "2"), (cTemp)->E5_TXMOEDA, (cTemp)->E5_VALOR, (cTemp)->E5_VLMOED2, (cTemp)->E5_PREFIXO, (cTemp)->E5_NUMERO, (cTemp)->E5_PARCELA, (cTemp)->E5_TIPO, (cTemp)->E5_FILORIG, (cTemp)->E5_CLIFOR, (cTemp)->E5_LOJA})
			(cTemp)->(dbSkip())
		EndDo

		If !lConsulta
			If Len(aCompensa) == 0
				Help(,,STR0149,, STR0278,1,0,,,,,,{STR0279}) //"No se ha encontrado la compensaci๓n informada." # "Valide la informaci๓n de la compensaci๓n informada en el encabezado e intente de nuevo."
				lRet := .F.
			Else
				lRet := F087AValCo(cNumComp, dFechComp)
			EndIf
		EndIf

		(cTemp)->(dbCloseArea())

		RestArea(aArea)
	EndIf

Return lRet

/*/{Protheus.doc} F087AValCo
	Valida si la compensaci๓n informada ya se encuentra relacionada a un Cobro Diverso.
	@type  Function
	@author oscar.lopez
	@since 11/05/2022
	@version 1.0
	@param cNumComp, caracter, Numero de Identificaci๓n de Compensaci๓n
	@param dFechComp, fecha, Fecha del movimiento
	@param lConsulta, caracter, Fecha del movimiento	@return return_var, return_type, return_description
	@return lRet, logico, Retorna .T. si se encuentra la compensaci๓n indicada
	@example
		F087AValCo(cNumComp, dFechComp, lConsulta)
	/*/
Function F087AValCo(cNumComp, dFechComp, lConsulta)
	Local lRet		:= .T.
	Local cTemp		:= ""
	Local aArea		:= {}
	Local cFecComp	:= ""

	Default lConsulta	:= .F.

	If !Empty(cNumComp) .And. !Empty(dFechComp)
		cTemp		:= GetNextAlias()
		aArea		:= GetArea()
		cFecComp	:= DtoS(dFechComp)

		BEGINSQL ALIAS cTemp
			SELECT EL_SERIE, EL_RECIBO, EL_FECTIMB, EL_UUID, EL_CANCEL, EL_GENCFD
			FROM %Table:SEL%
			WHERE %notdel%
				AND EL_FILIAL = %xFilial:SEL%
				AND EL_IDENTEE = %Exp:cNumComp%
				AND EL_FCHIDEN = %Exp:cFecComp%
				AND EL_CANCEL = 'F'
		ENDSQL

		(cTemp)->(dbGoTop())

		While (cTemp)->(!EOF())
			If lConsulta
				lRet := ((!EMPTY((cTemp)->EL_FECTIMB) .And. !EMPTY((cTemp)->EL_UUID)) .Or. (cTemp)->EL_GENCFD == 'N')
			Else
				Help(,,STR0149,, STR0282 + (cTemp)->(EL_SERIE+EL_RECIBO) + ".",1,0,,,,,,{""}) //"La compensaci๓n informada ya se encuentra relacionada al cobro diverso "
				lRet := .F.
			EndIf
			If !lRet
				Exit
			EndIf
			(cTemp)->(dbSkip())
		EndDo

		(cTemp)->(dbCloseArea())

		RestArea(aArea)
	EndIf
Return lRet

/*/{Protheus.doc} F087ACEC
	Generaci๓n de ventana para selecci๓n de Compensaci๓n.
	@type Function
	@author oscar.lopez
	@since 11/05/2022
	@version 1.0
	@return lRet, logico, Retorna .T. si se realiza la selecci๓n de una compensaci๓n
	@example
		F087ACEC()
	/*/
Function F087ACEC()
	Local lRet      	:= .F.
	Local aItems    	:= {}
	Local aControl  	:= {}
	Local oDlgRec		:= NIL
	Local oLbx1			:= NIL
	Local cTemp			:= GetNextAlias()
	Local cCampo		:= ReadVar()
	Local cClave		:= Upper(Trim(&(cCampo)))
	Local nPosLbx		:= 0
	Local nPos      	:= 0
	Local cTmp			:= ""
	Local nCont			:= 0
	Local nPosTipo		:= AScan(aCposSEL,"EL_TIPODOC")
	Local nPosValor		:= AScan(aCposSEL,"EL_VALOR")
	Local nPosMoneda	:= AScan(aCposSEL,"EL_MOEDA")
	Local nPosForPgo	:= AScan(aCposSEL,"EL_FORPGO")

	Private bLinea	:= {||Nil}

	CursorWait()

	//-- Filtra la informaci๓n
	BEGINSQL ALIAS cTemp
		SELECT
			SE5.E5_FILIAL, SE5.E5_DATA, SE5.E5_IDENTEE, SE5.E5_MOEDA, SE5.E5_VALOR, SE5.R_E_C_N_O_
		FROM
			%Table:SE5% SE5
		WHERE
			SE5.%notdel%
			AND     SE5.E5_FILIAL  = %xFilial:SE5%
			AND     SE5.E5_RECPAG  = 'R'
			AND     SE5.E5_TIPODOC = 'BA'
			AND     SE5.E5_MOTBX   = 'CEC'
			AND     SE5.E5_SITUACA = ' '
			AND     SE5.E5_ORIGEM  = 'FINA450'
			AND     SE5.E5_RECCMP  = ' '
			AND NOT EXISTS(SELECT NULL
				FROM %Table:SEL% SEL
				WHERE SEL.EL_IDENTEE = SE5.E5_IDENTEE
				AND SEL.EL_FCHIDEN = SE5.E5_DATA
				AND SEL.EL_CANCEL <> 'T'
				AND SEL.%notdel%)
		GROUP BY  
			SE5.E5_FILIAL, SE5.E5_DATA, SE5.E5_IDENTEE, SE5.E5_MOEDA, SE5.E5_VALOR, SE5.R_E_C_N_O_
		ORDER BY
			SE5.E5_FILIAL, SE5.E5_DATA, SE5.E5_IDENTEE, SE5.E5_MOEDA
	ENDSQL

	(cTemp)->(dbGoTop())
				
	//-- Genera arreglo con los registros filtrados
	Do While (cTemp)->(!EOF())
		If cTmp <> (cTemp)->(E5_FILIAL + E5_DATA + E5_IDENTEE + E5_MOEDA)
			aAdd(aItems,{(cTemp)->E5_FILIAL, STOD((cTemp)->E5_DATA), (cTemp)->E5_IDENTEE, Val((cTemp)->E5_MOEDA), (cTemp)->E5_VALOR, (cTemp)->R_E_C_N_O_})
			aAdd(aControl,{(cTemp)->E5_FILIAL, STOD((cTemp)->E5_DATA), (cTemp)->E5_IDENTEE, Val((cTemp)->E5_MOEDA), (cTemp)->E5_VALOR, (cTemp)->R_E_C_N_O_})
			cTmp := (cTemp)->(E5_FILIAL + E5_DATA + E5_IDENTEE + E5_MOEDA)
			nCont++
		Else
			aItems[nCont][5] += (cTemp)->E5_VALOR
			aControl[nCont][5] += (cTemp)->E5_VALOR
		EndIf
		(cTemp)->(DbSkip())
	EndDo

	(cTemp)->(dbCloseArea())
		
	CursorArrow()

	If Len(aItems) == 0
		Aviso(STR0283, STR0284, {STR0151})//"Atenci๓n" # "No hay informaci๓n para consultar." # "Ok"
		Return lRet
	Endif

	bLinea := {|| {	aItems[oLbx1:nAt,1],aItems[oLbx1:nAt,2],aItems[oLbx1:nAt,3],aItems[oLbx1:nAt,4],aItems[oLbx1:nAt,5]}}

	//-- Posicion en el arreglo donde esta la actual clave de producto
	If !Empty(cClave)
		nPos := aScan(aItems,{|x| x[1] = cClave}) //posiciona en el producto contenido en el campo ReadVar
	EndIf

	//-- Despliega consulta
	DEFINE MSDIALOG oDlgRec FROM 50,003 TO 295,730 TITLE STR0285 PIXEL //"Productos Activos"

	@ 05,05 LISTBOX oLbx1 VAR nPosLbx FIELDS HEADER STR0286, STR0287, STR0288,; //"Sucursal" # "Fecha" # "Compensaci๓n" 
			STR0289, STR0290 SIZE 355,103 OF oDlgRec PIXEL //"Moneda Comp." # "Valor Comp."

	oLbx1:SetArray(aItems)

	oLbx1:bLine:= bLinea
	oLbx1:BlDblClick := {||(lRet:= .T.,nPos:= oLbx1:nAt, oDlgRec:End())}
	oLbx1:Refresh()

	DEFINE SBUTTON FROM 110,300 TYPE 1 ENABLE OF oDlgRec ACTION (lRet:=.T.,nPos:=oLbx1:nAt,oDlgRec:End())
	DEFINE SBUTTON FROM 110,335 TYPE 2 ENABLE OF oDlgRec ACTION (lRet:= .F.,oDlgRec:End())

	ACTIVATE MSDIALOG oDlgRec CENTERED

	If lRet
		SE5->(DbGoTo(aControl[nPos,6]))
		dFchComp := aControl[nPos,2]
		aCols[n][nPosTipo] := "CO"
		aCols[n][nPosValor] := aControl[nPos,5]
		aCols[n][nPosMoneda] := AllTrim(Str(aControl[nPos,4]))
		aCols[n][nPosForPgo] := "17"
		oFchComp:Refresh()
		oGetSEL:Refresh()
		FaMoedas()	
	EndIf

Return lRet
