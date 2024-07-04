#include "protheus.CH"
#include "FINRETARG.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINRETARG บ Autor ณ  Bruno Schmidt     บ Data ณ  14/08/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calculo Retencoes                        				  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบ ArgRetIVA   - Calculo de Ret de IVA para NF               			  บฑฑ
ฑฑบ ARGRetIV2   - Calculo de Ret de IVA para NCP               		      บฑฑ
ฑฑบ ARGRetIB    - Calculo de Ret de IIB para NF                		      บฑฑ
ฑฑบ ARGRetIB2   - Calculo de Ret de IIB para NCP               		      บฑฑ
ฑฑบ ARGRetSUSS  - Calculo de Ret de SUSS para NF               		      บฑฑ
ฑฑบ ARGRetSU2   - Calculo de Ret de SUSS para NCP              		      บฑฑ
ฑฑบ ARGRetSLI   - Calculo de Ret de SLI para NF                		      บฑฑ
ฑฑบ ARGRetSL2   - Calculo de Ret de SLI para NCP               		      บฑฑ
ฑฑบ ARGRetGN    - Calculo de Ret de Ganancias                  		      บฑฑ
ฑฑบ ARGRetGNMnt - Calculo de Ganancia para Monotributista      		      บฑฑ
ฑฑบ ARGCpr      - Calculo de Ret de CPR para NF                		      บฑฑ
ฑฑบ ARGCpr2     - Calculo de Ret de CPR para NCP               		      บฑฑ
ฑฑบ ARGRetCmr   - Calculo de Ret de CMR para NF                		      บฑฑ
ฑฑบ ARGRetCmr2  - Calculo de Ret de CMR para NCP               		      บฑฑ
ฑฑบ ARGSegF1    - Calculo de Ret de Seguridad e Hig para NF    		      บฑฑ
ฑฑบ ARGSegF2    - Calculo de Ret de Seguridad e Hig para NCP   		      บฑฑ
ฑฑบ ARGRetIM    - Calculo de Ret de Iva Monotributista para NCP  		  บฑฑ
ฑฑบ ARGRetIM2   - Calculo de Ret de Iva Monotributista para NCP   		  บฑฑ
ฑฑฬฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฬฑฑ
ฑฑบPROGRAMADOR ณ DATA   ณ BOPS   ณ  MOTIVO DA ALTERACAO                   บฑฑ
ฑฑฬฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฬฑฑ
ฑฑบLaura Medinaณ15/02/17ณMMI-121 ณSe realiza la replica del llamado TUCD44บฑฑ
ฑฑบ            ณ        ณ        ณpara considerar en la generacion de la  บฑฑ
ฑฑบ            ณ        ณ        ณOP el pago a trav้s de CBU.             บฑฑ
ฑฑบLaura Medinaณ27/02/17ณMMI-4160ณAdecuacion para que haga retencion IVA  บฑฑ
ฑฑบ            ณ        ณ        ณa NF/NCr้dito de diferentes sucursales. บฑฑ
ฑฑบ            ณ        ณ        ณSe incluyo la solucion de issue MMI-4147บฑฑ
ฑฑบ            ณ        ณ        ณpara la validacion del BCO que impacta  บฑฑ
ฑฑบ            ณ        ณ        ณen la generacion de la OP.              บฑฑ
ฑฑบRaul Ortiz  ณ28/02/17ณMMI-4162ณAdecuacion para que haga retencion IVA  บฑฑ
ฑฑบ            ณ        ณ        ณSobre el valor del documento para       บฑฑ
ฑฑบ            ณ        ณ        ณempresas de Limpieza                    บฑฑ
ฑฑบLaura Medinaณ01/03/17ณMMI-4184ณRealizar correctamente el calculo IIBB  บฑฑ
ฑฑบ            ณ        ณ        ณcuando existe mas de un registro en la  บฑฑ
ฑฑบ            ณ        ณ        ณSFF para mismo CFO y diferente tipo de  บฑฑ
ฑฑบ            ณ        ณ        ณContribuyente.                          บฑฑ
ฑฑบLaura Medinaณ03/03/17ณMMI-4166ณEn la funcion de Ret. de IVA, se cambia บฑฑ
ฑฑบ            ณ        ณ        ณla validacion cAcmIVA <> "" por         บฑฑ
ฑฑบ            ณ        ณ        ณ!Empty(cAcmIVA).                        บฑฑ
ฑฑบRaul Ortiz  ณ03/03/17ณMMI-4148ณSe incorpora funcionalidad para la RG   บฑฑ
ฑฑบ            ณ        ณ        ณ2854-11                                 บฑฑ
ฑฑบLaura Medinaณ06/03/17ณMMI-4168ณAdecuacion para que haga retencion IIBB บฑฑ
ฑฑบ            ณ        ณ        ณa NF/NCr้dito de diferentes sucursales. บฑฑ
ฑฑบRaul Ortiz  ณ09/03/17ณMMI-238 ณSe guardar correctamente el importe     บฑฑ
ฑฑบ            ณ        ณ        ณde deducci๓n para condominios ganancias บฑฑ
ฑฑบRaul Ortiz  ณ15/03/17ณMMI-4182ณAdecuaci๓n para calcular correctamente  บฑฑ
ฑฑบ            ณ        ณ        ณSUSS al ser el calculo por cuotas       บฑฑ
ฑฑบLaura Medinaณ30/03/17ณMMI-4533ณAdecuaciones para las r้plicas de los   ณฑฑ
ฑฑบ            ณ        ณ        ณllamados: TTXJZP,TUVZY4,TUSJW3 y TUXRWJ.ณฑฑ
ฑฑบRaul Ortiz  ณ23/03/17ณMMI-4417ณAdecuaci๓n para calcular correctamente  บฑฑ
ฑฑบ            ณ        ณ        ณIIBB a no Inscriptos                    บฑฑ
ฑฑบRaul Ortiz  ณ28/03/17|MMI-4546ณSe considera el calculo de mํnimos IIBB บฑฑ
ฑฑบ            ณ        ณ        ณpor Ordend de Pago y no por comprobante บฑฑ
ฑฑบRaul Ortiz  ณ30/03/17|MMI-4938ณSe consideran las retenciones generadas บฑฑ
ฑฑบ            ณ        ณ        ณpor las ordenes de Pago Previas         บฑฑ
ฑฑบLaura Medinaณ19/05/17ณMMI-5084ณRG 032/2016 para SF, Tipo de Mi. (CCO_  บฑฑ
ฑฑบ            ณ        ณ        ณTPMINR)3-Base Imponible Mํnima+Impuesto,บฑฑ
ฑฑบ            ณ        ณ        ณse modifica la regla para tomar los mํ- บฑฑ
ฑฑบ            ณ        ณ        ณnimos con la nueva opci๓n (3)...        บฑฑ
ฑฑบRoberto Glezณ19/05/17ณMMI-5717ณCorrecci๓n en calculo de retenci๓n de   บฑฑ
ฑฑบ            ณ        ณ        ณganancias en un PA.                     บฑฑ
ฑฑบRoberto Glezณ02/06/17ณMMI-5806ณModificaci๓n de validaci๓n para prov si บฑฑ
ฑฑบ            ณ        ณ        ณes agente de retenci๓n de IVA y evitar  บฑฑ
ฑฑบ            ณ        ณ        ณla exlusi๓n del calculo de otro proceso.บฑฑ
ฑฑบLaura Medinaณ29/05/17ณMMI-5197ณSe da el tratamiento  si es un PA, obte-บฑฑ
ฑฑบ            ณ        ณ        ณniendo de manera correcta la Retencion yบฑฑ
ฑฑบ            ณ        ณ        ณcalculando la Ret. Ganancias para alma- บฑฑ
ฑฑบ            ณ        ณ        ณcenar en los arreglos.                  บฑฑ
ฑฑบRoberto Glezณ08/06/17ณMMI-5901ณCuando una NCP cuenta con mแs de un ํtemบฑฑ
ฑฑบ            ณ        ณ        ณcon la misma TES, considerar la alํcuotaบฑฑ
ฑฑบ            ณ        ณ        ณcorrecta para el cแlculo.               บฑฑ
ฑฑบRaul Ortiz  ณ08/06/17ณMMI-5667ณ Modificaciones para mostrar las Ret.   บฑฑ
ฑฑบ            ณ        ณ        ณen pantalla de las Ordenes de Pago      บฑฑ
ฑฑบLaura Medinaณ15/06/17ณMMI-5343ณAdecuacion para que haga retencion IVA  บฑฑ
ฑฑบ            ณ        ณ        ณcorrectamente y para que en Ret. de NCP บฑฑ
ฑฑบ            ณ        ณ        ณconsidere la configuracion del parแmetroบฑฑ
ฑฑบ            ณ        ณ        ณMV_AGENTE.                              บฑฑ
ฑฑบRoberto Glezณ06/10/17ณDMICNS  ณConsiderar el codigo de impuesto en el  บฑฑ
ฑฑบ            ณ        ณ-292    ณcalculo de retencion de ganancias.      บฑฑ
ฑฑบJose Glez   ณ13/10/17ณTSSERMI01ณSe agrega la variable aImpInf a la     บฑฑ
ฑฑบ            ณ        ณ-189     ณfuncion ARGRetSLI                      บฑฑ
ฑฑบRoberto Glz ณ24/07/17ณDMICNS- ณPara calculo de SUSS para NF y NCP,     บฑฑ
ฑฑบ            ณ        ณ108     ณconsiderar las especificaciones de la RGบฑฑ
ฑฑบ            ณ        ณ        ณ3983 para tomar el valor de F1/F2_VALSUSบฑฑ
ฑฑบ            ณ        ณ        ณen la orden de pago del documento.      บฑฑ
ฑฑบRaul Ortiz Mณ20/12/17ณDMICNS- ณCambios en calculo de retenciones de IB บฑฑ
ฑฑบ            ณ        ณ673     ณen las 2 funciones para tomar en cuenta บฑฑ
ฑฑบ            ณ        ณ        ณlos limites de calculo por orden de pagoบฑฑ
ฑฑบ            ณ        ณ        ณArgentina                               บฑฑ
ฑฑบRaul Ortiz  ณ12/03/18ณDMICNS- ณCambios para ganancias en condominios   บฑฑ
ฑฑบ            ณ        ณ1060    ณconceptos diferentes a 04- Argentina    บฑฑ
ฑฑบMarcos A    ณ27/03/18ณDMICNS- ณSe toma en cuenta tipo de mํnimo para   บฑฑ
ฑฑบ            ณ        ณ 1062   ณretenciones de IIBB en base a la opcion บฑฑ
ฑฑบ            ณ        ณ        ณ3-Base Imponible+Impuestos (CCO_TPMINR).บฑฑ
ฑฑบ            ณ        ณ        ณPais: Argentina (BA y CO).              บฑฑ
ฑฑบMarco A. Glzณ03/12/18ณDMICNS- ณReplica de issue DMICNS-4532 (11.8), queบฑฑ
ฑฑบ            ณ        ณ 4603   ณsoluciona el calculo correcto de reten- บฑฑ
ฑฑบ            ณ        ณ        ณciones, cuando se ha superado el monto  บฑฑ
ฑฑบ            ณ        ณ        ณminimo definido en el pago.             บฑฑ
ฑฑบGSantacruz  ณ15/01/19ณDMINA-  ณARGSegF2() - Ret Seguridad e Higiene NCPบฑฑ
ฑฑบ            ณ        ณ    5674ณProceso correcto de aSFF, aCF y signo   บฑฑ
ฑฑบ            ณ        ณ        ณde % FE_PORCRET.                        บฑฑ
ฑฑบGSA/ARL     ณ07/03/19ณDMINA-  ณARGRetIB()/ARGRetIB2() - Retenciones IB บฑฑ
ฑฑบ            ณ        ณ    5667ณProcesar si hay mas de un item y es     บฑฑ
ฑฑบ            ณ        ณ        ณproveedor no inscripto.                 บฑฑ
ฑฑบAlf. Medranoณ28/03/19ณDMINA-  ณse modifica fun ARGRetGN() se utiliza laบฑฑ
ฑฑบ            ณ        ณ    5675ณvariable lRegOP que indica si restarแ   บฑฑ
ฑฑบ            ณ        ณ        ณvalor del importe para obtener el impuesบฑฑ
ฑฑบ            ณ        ณ        ณto de retenci๓n                         บฑฑ
ฑฑบOscar G.    ณ04/04/19ณDMINA-  ณSe modifica fun ARGRetIB() inicia var.  บฑฑ
ฑฑบ            ณ        ณ    5708ณnPercTot, se validan vigencias de regi- บฑฑ
ฑฑบ            ณ        ณ        ณtros en SFH.                            บฑฑ
ฑฑศออออออออออออฯออออออออฯออออออออฯออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ

ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณArgRetIVA บ Autor ณ   Bruno Schmidt    บ Data ณ  14/08/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ ArgRetIVA   - Calculo de Ret de IVA para NF                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINRETARG                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function ArgRetIVA(cAgente,nSigno,nSaldo,lPa,cCF,nValor,nProp,cSerieNF,nA,aPagAux,naPagar,cChavePOP,cNFPOP,cSeriePOP,dEmissao,lOPRotAut)
Local aArea:=GetArea()
Local aSFEIVA:={}
DEFAULT lPa		 :=	.F.
DEFAULT cCF 	 := ""
DEFAULT nValor 	 := 0
DEFAULT nSigno	 := 1
DEFAULT naPagar	 := 0
DEFAULT cChavePOP:= ""
DEFAULT cNFPOP	 := ""
DEFAULT cSeriePOP:= ""
DEFAULT dEmissao := CTOD("//")
DEFAULT lOPRotAut:= .F. 

If  FindFunction("RetIVADeb")
	aSFEIVA:= RetIVADeb(cAgente,nSigno,nSaldo,lPa,cCF,nValor,nProp,cSerieNF,nA,aPagAux,naPagar,cChavePOP,cNFPOP,cSeriePOP,dEmissao,lOPRotAut)
Else
 	If  lOPRotAut
 		If  Valtype(cTxtRotAut) != "C"
 			cTxtRotAut := ""
 		Endif
		cTxtRotAut += OemToAnsi(STR0003 + STR0005 + STR0007 +STR0004) //"Rutina de cแlculo de Retenci๓n IVA (d้bito) desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0005 +STR0007 + STR0004),{OemToAnsi(STR0002)}) //"Rutina de cแlculo de Retenci๓n IVA (d้bito) desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

RestArea(aArea)
Return aSFEIVA

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณARGRetIV2 บ Autor ณ	Bruno Schmidt     บ Data ณ  14/08/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ ArgRetIVA   - Calculo de Ret de IVA para NCP               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINRETARG                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function ARGRetIV2(cAgente,nSigno,nSaldo,nProp,nA,cChavePOP,cNFPOP,cSeriePOP,dEmissao,lOPRotAut)
Local aArea:=GetArea()
Local aSFEIVA	:= {}
DEFAULT nSigno	:= -1
DEFAULT nProp 	:= 1
DEFAULT cChavePOP:= ""
DEFAULT cNFPOP	 := ""
DEFAULT cSeriePOP:= ""
DEFAULT dEmissao := CTOD("//")
DEFAULT lOPRotAut:= .F.

If  FindFunction("RetIVACre")
	aSFEIVA:= RetIVACre(cAgente,nSigno,nSaldo,nProp,nA,cChavePOP,cNFPOP,cSeriePOP,dEmissao,lOPRotAut)
Else
 	If  lOPRotAut
 		If  Valtype(cTxtRotAut) != "C"
 			cTxtRotAut := ""
 		Endif
		cTxtRotAut += OemToAnsi(STR0003 + STR0005 + STR0008 +STR0004) //"Rutina de cแlculo de Retenci๓n de IVA (cr้dito) desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0005 + STR0008 + STR0004),{OemToAnsi(STR0002)}) //"Rutina de cแlculo de Retenci๓n de IVA desactualizada (cr้dito), solicite paquete con actualizaciones." 
 	EndIf
EndIf

RestArea(aArea)
Return aSFEIVA

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ARGRetIB บ Autor ณ	Bruno Schmidt     บ Data ณ  14/08/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ ARGRetIB    - Calculo de Ret de IIB para NF                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINRETARG                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function ARGRetIB(cAgente,nSigno,nSaldo,cCF,cProv,lPA,nPropImp,aConfProv,lSUSSPrim,lIIBBTotal,aImpCalc,aSUSS,nLinha,lLimNRet,cChavePOP,cNFPOP,cSeriePOP,dEmissao,lOPRotAut)
Local aArea:=GetArea()
Local aSFEIB	:= {}
DEFAULT nSigno		:= 1
DEFAULT nPropImp	:= 1
DEFAULT aConfProv	:= {}
DEFAULT lSUSSPrim	:= .T.
DEFAULT lIIBBTotal:= .F.
DEFAULT aImpCalc	:= {}
DEFAULT aSUSS		:= {}
DEFAULT nLinha	:= 1
DEFAULT lLimNRet := .F.
DEFAULT cChavePOP:= ""
DEFAULT cNFPOP	 := ""
DEFAULT cSeriePOP:= ""
DEFAULT dEmissao := CTOD("//")
DEFAULT lOPRotAut:= .F.

If  FindFunction("RetIBBDeb")
	aSFEIB:= RetIBBDeb(cAgente,nSigno,nSaldo,cCF,cProv,lPA,nPropImp,aConfProv,lSUSSPrim,@lIIBBTotal,aImpCalc,aSUSS,nLinha,lLimNRet,cChavePOP,cNFPOP,cSeriePOP,dEmissao,lOPRotAut)
Else
	If  Valtype(lVldMsgIBB) != "L"
 		lVldMsgIBB := .T.
 	Endif
 	If  lOPRotAut
 		If  Valtype(cTxtRotAut) != "C"
 			cTxtRotAut := ""
 		Endif
 		If  lVldMsgIBB 
 			cTxtRotAut += OemToAnsi(STR0003 + STR0009 + STR0007 +STR0004) //"Rutina de cแlculo de Retenci๓n IIBB (d้bito) desactualizada, solicite paquete con actualizaciones."
 			lVldMsgIBB := .F. 
 		Endif
 		lMsErroAuto := .T.
 	Else
 		If  lVldMsgIBB
	 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0009 +STR0007 + STR0004),{OemToAnsi(STR0002)}) //"Rutina de cแlculo de Retenci๓n IIBB (d้bito) desactualizada, solicite paquete con actualizaciones."
	 		lVldMsgIBB := .F. 
 		Endif 
 	EndIf
EndIf

RestArea(aArea)
Return aSFEIB

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณARGRetIB2 บ Autor ณ	Bruno Schmidt     บ Data ณ  14/08/14  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ ARGRetIB2    - Calculo de Ret de IIB para NF               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINRETARG                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function ARGRetIB2(cAgente,nSigno,nSaldo,nPropImp,aConfProv,lSUSSPrim,lIIBBTotal,aImpCalc,aSUSS,nLinha,lLimNRet,cChavePOP,cNFPOP,cSeriePOP,dEmissao,lOPRotAut)
Local aArea			:=GetArea()
Local aSFEIB    	:= {}
DEFAULT nSigno		:= -1
DEFAULT nPropImp	:= 1
DEFAULT aConfProv	:= {}
DEFAULT lSUSSPrim	:= .T.
DEFAULT lIIBBTotal 	:= .F.
DEFAULT aImpCalc 	:= {}
DEFAULT aSUSS 		:= {}
DEFAULT nLinha		:= 0
DEFAULT lLimNRet 	:= .F.     
DEFAULT cChavePOP	:= ""
DEFAULT cNFPOP	 	:= ""
DEFAULT cSeriePOP	:= ""
DEFAULT dEmissao 	:= CTOD("//")
DEFAULT lOPRotAut	:= .F.

If  FindFunction("RetIBBCre")
	aSFEIB:= RetIBBCre(cAgente,nSigno,nSaldo,nPropImp,aConfProv,lSUSSPrim,@lIIBBTotal,aImpCalc,aSUSS,nLinha,lLimNRet,cChavePOP,cNFPOP,cSeriePOP,dEmissao,lOPRotAut)
Else
	If  Valtype(lVldMsgIBB) != "L"
 		lVldMsgIBB := .T.
 	Endif
 	If  lOPRotAut
 		If  Valtype(cTxtRotAut) != "C"
 			cTxtRotAut := ""
 		Endif
 		If  lVldMsgIBB
 			cTxtRotAut += OemToAnsi(STR0003 + STR0009 + STR0008 +STR0004) //"Rutina de cแlculo de Retenci๓n IIBB (cr้dito) desactualizada, solicite paquete con actualizaciones."
 			lVldMsgIBB := .F.
 		Endif
 		lMsErroAuto := .T.
 	Else
 		If  lVldMsgIBB
	 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0009 +STR0008 + STR0004),{OemToAnsi(STR0002)}) //"Rutina de cแlculo de Retenci๓n IIBB (cr้dito) desactualizada, solicite paquete con actualizaciones."
	 		lVldMsgIBB := .F. 
	 	Endif
 	EndIf
EndIf

RestArea(aArea)
Return aSFEIB


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณARGRetSUSSบ Autor ณ	Bruno Schmidt     บ Data ณ  14/08/14  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ ARGRetSUSS  - Calculo de Ret de SUSS para NF               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINRETARG                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function ARGRetSUSS(cAgente,nSigno,nSaldo,lRetPa,nProp,aSUSS,aImpCalc,nLinha,nControl,aSE2,cChavePOP,cNFPOP,cSeriePOP,dEmissao,lOPRotAut)
Local aSFESUSS  := {}
Local aArea     := GetArea()
DEFAULT nProp	:= 1
DEFAULT nSigno	:=	1
DEFAULT lRetPa 	:= .F.
DEFAULT aSUSS  	:= {}
DEFAULT aImpCalc:= {}
DEFAULT nLinha	:= 0 
DEFAULT nControl:= 0
DEFAULT cChavePOP:= ""
DEFAULT cNFPOP	 := ""
DEFAULT cSeriePOP:= ""
DEFAULT dEmissao := CTOD("//")
DEFAULT lOPRotAut:= .F.

If  FindFunction("RetSUSDeb")
	aSFESUSS:= RetSUSDeb(cAgente,nSigno,nSaldo,lRetPa,nProp,aSUSS,aImpCalc,nLinha,nControl,aSE2,cChavePOP,cNFPOP,cSeriePOP,dEmissao)
Else
 	If  lOPRotAut
 		If  Valtype(cTxtRotAut) != "C"
 			cTxtRotAut := ""
 		Endif
		cTxtRotAut += OemToAnsi(STR0003 + STR0006 + STR0007 +STR0004) //"Rutina de cแlculo de Retenci๓n de SUSS (d้bito) desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0006 + STR0007 +STR0004),{OemToAnsi(STR0002)}) //"Rutina de cแlculo de Retenci๓n de SUSS (d้bito) desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

RestArea(aArea)
Return aSFESUSS



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณARGRetSU2 บ Autor ณ	Bruno Schmidt     บ Data ณ  14/08/14  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ ARGRetSU2   - Calculo de Ret de SUSS para NCP              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINRETARG                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function ARGRetSU2(cAgente,nSigno,nSaldo,nProp,aSUSS,aImpCalc,nLinha,cChavePOP,cNFPOP,cSeriePOP,dEmissao,lOPRotAut)
Local aArea		:= GetArea()
Local aSFESUSS  := {}
DEFAULT nSigno	:=	-1
DEFAULT aSUSS  	:= {}
DEFAULT aImpCalc	:= {}
DEFAULT nLinha	:= 0
DEFAULT cChavePOP:= ""
DEFAULT cNFPOP	 := ""
DEFAULT cSeriePOP:= ""
DEFAULT dEmissao := CTOD("//")
DEFAULT lOPRotAut:= .F.

If  FindFunction("RetSUSCre")
	aSFESUSS:= RetSUSCre(cAgente,nSigno,nSaldo,nProp,aSUSS,aImpCalc,nLinha,cChavePOP,cNFPOP,cSeriePOP,dEmissao,lOPRotAut)
Else
 	If  lOPRotAut
 		If  Valtype(cTxtRotAut) != "C"
 			cTxtRotAut := ""
 		Endif
		cTxtRotAut += OemToAnsi(STR0003 + STR0006 + STR0008 +STR0004) //"Rutina de cแlculo de Retenci๓n de SUSS (cr้dito) desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0006 + STR0008 +STR0004),{OemToAnsi(STR0002)}) //"Rutina de cแlculo de Retenci๓n de SUSS (cr้dito) desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

RestArea(aArea)
Return aSFESUSS 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณARGRetSLI บ Autor ณ	Bruno Schmidt     บ Data ณ  14/08/14  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ ARGRetSLI   - Calculo de Ret de SLI para NF                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINRETARG                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function ARGRetSLI(cAgente,nSigno,nSaldo,nA,cChavePOP,cNFPOP,cSeriePOP,lOPRotAut)
Local aSFESLI	:= {}
Local aArea		:= GetArea()
DEFAULT nSigno	:=	1
DEFAULT cChavePOP:= ""
DEFAULT cNFPOP	 := ""
DEFAULT cSeriePOP:= ""
DEFAULT lOPRotAut:= .F.

If  FindFunction("RetSLIDeb")
	aSFESLI:= RetSLIDeb(cAgente,nSigno,nSaldo,nA,cChavePOP,cNFPOP,cSeriePOP)
Else
 	If  lOPRotAut
 		If  Valtype(cTxtRotAut) != "C"
 			cTxtRotAut := ""
 		Endif
		cTxtRotAut += OemToAnsi(STR0003 + STR0012 + STR0007 +STR0004) //"Rutina de cแlculo de Retenci๓n de SLI (d้bito) desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0012 + STR0007 +STR0004),{OemToAnsi(STR0002)}) //"Rutina de cแlculo de Retenci๓n de SLI (d้bito) desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

RestArea(aArea)
Return aSFESLI

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณARGRetSL2 บ Autor ณ	Bruno Schmidt     บ Data ณ  14/08/14  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ ARGRetSL2   - Calculo de Ret de SLI para NF                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINRETARG                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function ARGRetSL2(cAgente,nSigno,nSaldo,nA,cChavePOP,cNFPOP,cSeriePOP,lOPRotAut)
Local aSFESLI 	:= {}
Local aArea		:= GetArea()
DEFAULT nSigno	:= -1
DEFAULT cChavePOP:= ""
DEFAULT cNFPOP	 := ""
DEFAULT cSeriePOP:= ""
DEFAULT lOPRotAut:= .F.

If  FindFunction("RetSLICre")
	aSFESLI:= RetSLICre(cAgente,nSigno,nSaldo,nA,cChavePOP,cNFPOP,cSeriePOP)
Else
 	If  lOPRotAut
 		If  Valtype(cTxtRotAut) != "C"
 			cTxtRotAut := ""
 		Endif
		cTxtRotAut += OemToAnsi(STR0003 + STR0012 + STR0008 +STR0004) //"Rutina de cแlculo de Retenci๓n de SLI (cr้dito) desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0012 + STR0008 +STR0004),{OemToAnsi(STR0002)}) //"Rutina de cแlculo de Retenci๓n de SLI (cr้dito) desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

RestArea(aArea)
Return aSFESLI



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ARGRetGN บ Autor ณ	Bruno Schmidt     บ Data ณ  14/08/14  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ ARGRetGN    - Calculo de Ret de Ganancias                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINRETARG                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function ARGRetGN(cAgente,nSigno,aConGan,cFornece,cLoja,cChavePOP,lOPRotAut,lPa, nValBase)
Local aSFEGn	:= {}
Local aArea		:=	GetArea()
DEFAULT nSigno	:= 1
DEFAULT cChavePOP	:= ""
DEFAULT lOPRotAut:= .F.
DEFAULT lPa      := .F.
DEFAULT nValBase := 0

If  FindFunction("RetGanDeb")
	aSFEGn:= RetGanDeb(cAgente,nSigno,aConGan,cFornece,cLoja,cChavePOP,lOPRotAut,lPa, nValBase)
Else
 	If  lOPRotAut
 		If  Valtype(cTxtRotAut) != "C"
 			cTxtRotAut := ""
 		Endif
		cTxtRotAut += OemToAnsi(STR0003 + STR0010 + STR0004) //"Rutina de cแlculo de Retenci๓n Ganancias desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0010 + STR0004),{OemToAnsi(STR0002)}) //"Rutina de cแlculo de Retenci๓n Ganancias desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

RestArea(aArea)
Return aSFEGN


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณARGRetGNMnt บ Autor ณ  Bruno Schmidt   บ Data ณ  14/08/14   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calculo de IVA para monotributista                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINRETARG                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function ARGRetGNMnt(cAgente,nSigno,aConGan,cFornece,cLoja,cDoc,cSerie,lPa,nTTit,cChavePOP,lOPRotAut)
Local aSFEGn   	:= {}
Local aArea		:=	GetArea()
DEFAULT nSigno	:=	1
DEFAULT lPa 	:= .F.
DEFAULT cChavePOP	:= ""
DEFAULT lOPRotAut:= .F.

If  FindFunction("RetGanMnt")
	aSFEGn:= RetGanMnt(cAgente,nSigno,aConGan,cFornece,cLoja,cDoc,cSerie,lPa,nTTit,cChavePOP,lOPRotAut)
Else
 	If  lOPRotAut
 		If  Valtype(cTxtRotAut) != "C"
 			cTxtRotAut := ""
 		Endif
		cTxtRotAut += OemToAnsi(STR0003 + STR0010 + STR0011 + STR0004) //"Rutina de cแlculo de Retenci๓n Ganancias para Monotributista desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0010 + STR0011 + STR0004),{OemToAnsi(STR0002)}) //"Rutina de cแlculo de Retenci๓n Ganancias para Monotributista desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

RestArea(aArea)
Return aSFEGN

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ  ARGCpr  บ Autor ณ	Bruno Schmidt     บ Data ณ  14/08/14  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ ARGCpr      - Calculo de Ret de CPR para NF                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINRETARG                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function ARGCpr(cAgente,nSigno,nSaldo,lOPRotAut)
Local aConCprRat:= {}
Local aArea		:=	GetArea()
DEFAULT nSigno	:= 1
DEFAULT lOPRotAut:= .F.

If  !FindFunction("RetCprDeb")
 	If  lOPRotAut
 		If  Valtype(cTxtRotAut) != "C"
 			cTxtRotAut := ""
 		Endif
		cTxtRotAut += OemToAnsi(STR0003 + STR0014 + STR0007 + STR0004) //"Rutina de cแlculo de Retenci๓n CPR (d้bito) desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0014 + STR0007 + STR0004),{OemToAnsi(STR0002)}) //"Rutina de cแlculo de Retenci๓n CPR (d้bito)  desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

If Empty(aConCprRat)
	AAdd(aConCprRat, {,0,0,0,0,0,0,0,0,0,0})
EndIf

RestArea(aArea)
Return aConCprRat


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ  ARGCpr2 บ Autor ณ	Bruno Schmidt     บ Data ณ  14/08/14  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ ARGCpr      - Calculo de Ret de CPR para NCP               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINRETARG                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function ARGCpr2(cAgente,nSigno,nSaldo,lOPRotAut)
Local aConCprRat	:= {}
Local aArea			:=	GetArea()
DEFAULT nSigno		:=	1
DEFAULT lOPRotAut	:= .F.

If  !FindFunction("RetCprCre")
 	If  lOPRotAut
 		If  Valtype(cTxtRotAut) != "C"
 			cTxtRotAut := ""
 		Endif
		cTxtRotAut += OemToAnsi(STR0003 + STR0014 + STR0008 + STR0004) //"Rutina de cแlculo de Retenci๓n de CPR (cr้dito) desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0014 + STR0008 + STR0004),{OemToAnsi(STR0002)}) //"Rutina de cแlculo de Retenci๓n de CPR (cr้dito)  desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

If Empty(aConCprRat)
	AAdd(aConCprRat, {,0,0,0,0,0,0,0,0,0,0})
EndIf

RestArea(aArea)
Return aConCprRat


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณARGRetCmr บ Autor ณ	Bruno Schmidt     บ Data ณ  14/08/14  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ ARGRetCmr   - Calculo de Ret de CMR para NF 		     	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINRETARG                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function ARGRetCmr(cAgente,nSigno,nSaldo,lOPRotAut)
Local aConCmrRat:= {}
Local aArea		:=	GetArea()
DEFAULT nSigno	:=	1
DEFAULT lOPRotAut:= .F.

If  !FindFunction("RetCMrDeb")
 	If  lOPRotAut
 		If  Valtype(cTxtRotAut) != "C"
 			cTxtRotAut := ""
 		Endif
		cTxtRotAut += OemToAnsi(STR0003 + STR0015 + STR0007 + STR0004) //"Rutina de cแlculo de Retenci๓n de CMR (d้bito) desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0015 + STR0007 + STR0004),{OemToAnsi(STR0002)}) //"Rutina de cแlculo de Retenci๓n de CMR (d้bito)  desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

If Empty(aConCmrRat)
	AAdd(aConCmrRat, {,0,0,0,0,0,0,0,0,0,0})
Endif

RestArea(aArea)
Return aConCmrRat

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณARGRetCmr2 บ Autor ณ	Bruno Schmidt     บ Data ณ  14/08/14  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ ARGRetCmr2   - Calculo de Ret de CMR para NCP			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINRETARG                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function ARGRetCmr2(cAgente,nSigno,nSaldo,lOPRotAut)
Local aConCmrRat:= {}
Local aArea		:=	GetArea()
DEFAULT nSigno	:=	1
DEFAULT lOPRotAut:= .F.

If  !FindFunction("RetCmrCre")
 	If  lOPRotAut
 		If  Valtype(cTxtRotAut) != "C"
 			cTxtRotAut := ""
 		Endif
		cTxtRotAut += OemToAnsi(STR0003 + STR0015 + STR0008 + STR0004) //"Rutina de cแlculo de Retenci๓n de CMR (cr้dito) desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0015 + STR0008 + STR0004),{OemToAnsi(STR0002)}) //"Rutina de cแlculo de Retenci๓n de CMR (cr้dito)  desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

If Empty(aConCmrRat)
	AAdd(aConCmrRat, {,0,0,0,0,0,0,0,0,0,0})
Endif

RestArea(aArea)
Return aConCmrRat



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ARGSegF1 บ Autor ณ	Bruno Schmidt     บ Data ณ  14/08/14  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ ARGSegF1    - Calculo de Ret de Seguridad e Hig para NF    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINRETARG                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function ARGSegF1(cAgente,nSigno,nSaldo,cChavePOP,cNFPOP,cSeriePOP,aSLIMIN,lOPRotAut)
Local aSFEISI  	:= {}
Local aArea		:=	GetArea()
DEFAULT nSigno	:=	1
DEFAULT cChavePOP:= ""
DEFAULT cNFPOP	 := ""
DEFAULT cSeriePOP:= ""
DEFAULT aSLIMIN := {}
DEFAULT lOPRotAut:= .F.

If  FindFunction("RetMunDeb")
	aSFEISI:= RetMunDeb(cAgente,nSigno,nSaldo,cChavePOP,cNFPOP,cSeriePOP,@aSLIMIN)
Else
 	If  lOPRotAut
 		If  Valtype(cTxtRotAut) != "C"
 			cTxtRotAut := ""
 		Endif
		cTxtRotAut += OemToAnsi(STR0003 + STR0013 + STR0007 + STR0004) //"Rutina de cแlculo de Retenci๓n de Seguridad e Hig (d้bito) desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0013 + STR0007 + STR0004),{OemToAnsi(STR0002)}) //"Rutina de cแlculo de Retenci๓n de Seguridad e Hig (d้bito) desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

RestArea(aArea)
Return aSFEISI

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ARGSegF2 บ Autor ณ	Bruno Schmidt     บ Data ณ  14/08/14  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ ARGSegF2    - Calculo de Ret de Seguridad e Hig para NCP   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINRETARG                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function ARGSegF2(cAgente,nSigno,nSaldo,cChavePOP,cNFPOP,cSeriePOP,aSLIMIN,lOPRotAut)
Local aSFEISI  	:= {}
Local aArea		:=	GetArea()
DEFAULT nSigno:= -1
DEFAULT cChavePOP:= ""
DEFAULT cNFPOP	 := ""
DEFAULT cSeriePOP:= ""
DEFAULT aSLIMIN := {}
DEFAULT lOPRotAut:= .F.

If  FindFunction("RetMunCre")
	aSFEISI:= RetMunCre(cAgente,nSigno,nSaldo,cChavePOP,cNFPOP,cSeriePOP,@aSLIMIN)
Else
 	If  lOPRotAut
 		If  Valtype(cTxtRotAut) != "C"
 			cTxtRotAut := ""
 		Endif
		cTxtRotAut += OemToAnsi(STR0003 + STR0013 + STR0008 + STR0004) //"Rutina de cแlculo de Retenci๓n de Seguridad e Hig (cr้dito) desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0013 + STR0008 + STR0004),{OemToAnsi(STR0002)}) //"Rutina de cแlculo de Retenci๓n de Seguridad e Hig (cr้dito) desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

RestArea(aArea)
Return aSFEISI

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ARGRetIM บ Autor ณ	Bruno Schmidt     บ Data ณ  14/08/14  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ ARGRetIM    - Calculo de Ret de Iva Monotributista para NCPบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINRETARG                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function ARGRetIM(cAgente,nSigno,nSaldo,lPa,cCF,nValor,nProp,lNNF,cSerieNF,cChavePOP,cNFPOP,cSeriePOP,dEmissao,lOPRotAut)
Local aSFEIVA  	:= {}
Local aArea		:=	GetArea()
DEFAULT lNNF 	:= .F.
DEFAULT lPa		:= .F.
DEFAULT cCF 	:= ""
DEFAULT nValor 	:= 0
DEFAULT nSigno	:= 1
DEFAULT cChavePOP:= ""
DEFAULT cNFPOP	 := ""
DEFAULT cSeriePOP:= ""
DEFAULT dEmissao := CTOD("//")
DEFAULT lOPRotAut:= .F.

If  FindFunction("RetIVAMDb")
	aSFEIVA:= RetIVAMDb(cAgente,nSigno,nSaldo,lPa,cCF,nValor,nProp,lNNF,cSerieNF,cChavePOP,cNFPOP,cSeriePOP,dEmissao,lOPRotAut)
Else
 	If  lOPRotAut
 		If  Valtype(cTxtRotAut) != "C"
 			cTxtRotAut := ""
 		Endif
		cTxtRotAut += OemToAnsi(STR0003 + STR0005 + STR0007 + STR0011 +STR0004) //"Rutina de cแlculo de Retenci๓n IVA (d้bito) para monotributista desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0005 + STR0007 + STR0011 +STR0004),{OemToAnsi(STR0002)}) //"Rutina de cแlculo de Retenci๓n IVA (d้bito) para monotributista desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

RestArea(aArea)
Return aSFEIVA

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ARGRetIM2บ Autor ณ	Bruno Schmidt     บ Data ณ  14/08/14  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณARGRetIM2 - Calculo de Ret de Iva Monotributista para NCP   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINRETARG                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function ARGRetIM2(cAgente,nSigno,nSaldo,nProp,cChavePOP,cNFPOP,cSeriePOP,dEmissao,lOPRotAut)
Local aSFEIVA	:= {} 
Local aArea		:=	GetArea()
DEFAULT nSigno	:= -1
DEFAULT nProp 	:= 1
DEFAULT cChavePOP:= ""
DEFAULT cNFPOP	 := ""
DEFAULT cSeriePOP:= ""
DEFAULT dEmissao := CTOD("//")
DEFAULT lOPRotAut:= .F.

If  FindFunction("RetIVAMCr")
	aSFEIVA:= RetIVAMCr(cAgente,nSigno,nSaldo,nProp,cChavePOP,cNFPOP,cSeriePOP,dEmissao,lOPRotAut)
Else
 	If  lOPRotAut
 		If  Valtype(cTxtRotAut) != "C"
 			cTxtRotAut := ""
 		Endif
		cTxtRotAut += OemToAnsi(STR0003 + STR0005 + STR0008 + STR0011 +STR0004) //"Rutina de cแlculo de Retenci๓n IVA (cr้dito) para monotributista desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0005 + STR0008 + STR0011 +STR0004),{OemToAnsi(STR0002)}) //"Rutina de cแlculo de Retenci๓n IVA (cr้dito) para monotributista desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

RestArea(aArea)
Return aSFEIVA



/*
ษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออป
บPrograma  ณObtReten   บAutor  ณRaul Ortiz Medina   บ Data ณ  19/09/19   บ
ฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออน
บDesc.     ณ Realiza el acumulado de los valores de Retenciones de una   บ
บ          ณ Orden de Pago Previa                                        บ
ฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน
บUso       ณ FINA850                                                     บ
ศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Function ObtReten(cChave, cNF, cSerie, cTipo, nSaldo, dEmissao, aConfProv, lReSaSus)
//Se cambia a Function y solo es usada en: FINRETIBB, FINRETIVA, FINRETMUN, FINRETGAN, FINRETSLI y FINRETSUSS
Local aReten := {}
Local cFil	 := xFilial("FVC")
DEFAULT cChave 		:= ""
DEFAULT cNF 		:= ""
DEFAULT cSerie		:= ""
DEFAULT cTipo 		:= ""
DEFAULT nSaldo 		:= 0
DEFAULT dEmissao 	:= CTOD("//")
DEFAULT aConfProv 	:= {}
DEFAULT	lReSaSus	:= .F.
 
	DBSELECTAREA("FVC")
	FVC->(DBSETORDER(2)) //FVC_FILIAL+FVC_PREOP+FVC_FORNEC+FVC_LOJA
	If FVC->(MsSeek(cFil + cChave))
		While FVC->(!Eof()) .and. FVC->(FVC_FILIAL+FVC_PREOP+FVC_FORNEC+FVC_LOJA) == cFil + cChave
			If cTipo == "G" .and. AllTrim(FVC->FVC_TIPO) == "G"
				aAdd(aReten,{"",FVC_VALBAS,FVC_ALIQ,FVC_RETENC,FVC_RETENC,FVC_DEDUC,FVC_CONCEP,FVC_PORCR,"",FVC_FORCON,FVC_LOJCON})
			Else
				If FVC->FVC_NFISC == cNF .and. FVC->FVC_SERIE == cSerie
					If AllTrim(FVC->FVC_TIPO) == "I" .and. cTipo == "I" //.and. cTipo == "I" //nf +serie
						aAdd(aReten,{FVC->FVC_NFISC,FVC->FVC_SERIE,FVC->FVC_VALBAS,FVC->FVC_RETENC,FVC->FVC_PORCR,FVC->FVC_RETENC,nSaldo,dEmissao,FVC->FVC_CFO,FVC->FVC_ALIQ,FVC->FVC_CFO,0})
					ElseIf AllTrim(FVC->FVC_TIPO) == "B" .and. cTipo == "B" .and. AllTrim(FVC->FVC_EST) == aConfProv[1]
						aAdd(aReten,{FVC->FVC_NFISC,FVC->FVC_SERIE,FVC->FVC_VALBAS,FVC->FVC_ALIQ,FVC->FVC_RETENC,FVC->FVC_RETENC,nSaldo,dEmissao,FVC->FVC_EST,SE2->E2_MOEDA,FVC->FVC_CFO,;
						FVC->FVC_CFO,SE2->E2_TIPO,FVC->FVC_CONCEP,FVC_DEDUC,FVC_PORCR,.F.,"",FVC->FVC_ALIQ,0,0,0,;
						0,0,"",0,0,0,aConfProv[6],.F.,0,0,0})				
					ElseIf cTipo == "S" .and. (AllTrim(FVC->FVC_TIPO) == "U" .or. AllTrim(FVC->FVC_TIPO) == "S")
						aAdd(aReten,{FVC->FVC_NFISC,FVC->FVC_SERIE,FVC->FVC_VALBAS,FVC->FVC_RETENC,FVC->FVC_PORCR,FVC->FVC_RETENC,FVC->FVC_ALIQ,FVC->FVC_CONCEP,FVC->FVC_EST,"",FVC_FORCON,FVC_LOJCON,Iif(lReSaSus,FVC_RETENC,0)})
					ElseIf cTipo == "L" .and. AllTrim(FVC->FVC_TIPO) == "L" 
						aAdd(aReten,{FVC->FVC_NFISC,FVC->FVC_SERIE,FVC->FVC_VALBAS,FVC->FVC_VALBAS,FVC_PORCR,FVC->FVC_RETENC})					
					ElseIf cTipo == "M" .and. AllTrim(FVC->FVC_TIPO) == "M" 
						aAdd(aReten,{FVC->FVC_NFISC,FVC->FVC_SERIE,FVC->FVC_VALBAS,FVC->FVC_RETENC,Round((FVC->FVC_RETENC*100)/nSaldo,2),FVC->FVC_RETENC,FVC->FVC_DEDUC,{{FVC->FVC_ALIQ,"",FVC->FVC_RETENC,""}},FVC->FVC_EST,FVC->FVC_RET_MN})
					EndIf
				EndIF
			EndIf
			FVC->(DbSkip())
		Enddo
	EndIF

Return aReten

