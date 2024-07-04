#include "protheus.CH"
#include "FINRETARG.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FINRETARG � Autor �  Bruno Schmidt     � Data �  14/08/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � Calculo Retencoes                        				  ���
�������������������������������������������������������������������������ͺ��
��� ArgRetIVA   - Calculo de Ret de IVA para NF               			  ���
��� ARGRetIV2   - Calculo de Ret de IVA para NCP               		      ���
��� ARGRetIB    - Calculo de Ret de IIB para NF                		      ���
��� ARGRetIB2   - Calculo de Ret de IIB para NCP               		      ���
��� ARGRetSUSS  - Calculo de Ret de SUSS para NF               		      ���
��� ARGRetSU2   - Calculo de Ret de SUSS para NCP              		      ���
��� ARGRetSLI   - Calculo de Ret de SLI para NF                		      ���
��� ARGRetSL2   - Calculo de Ret de SLI para NCP               		      ���
��� ARGRetGN    - Calculo de Ret de Ganancias                  		      ���
��� ARGRetGNMnt - Calculo de Ganancia para Monotributista      		      ���
��� ARGCpr      - Calculo de Ret de CPR para NF                		      ���
��� ARGCpr2     - Calculo de Ret de CPR para NCP               		      ���
��� ARGRetCmr   - Calculo de Ret de CMR para NF                		      ���
��� ARGRetCmr2  - Calculo de Ret de CMR para NCP               		      ���
��� ARGSegF1    - Calculo de Ret de Seguridad e Hig para NF    		      ���
��� ARGSegF2    - Calculo de Ret de Seguridad e Hig para NCP   		      ���
��� ARGRetIM    - Calculo de Ret de Iva Monotributista para NCP  		  ���
��� ARGRetIM2   - Calculo de Ret de Iva Monotributista para NCP   		  ���
��������������������������������������������������������������������������̱�
���PROGRAMADOR � DATA   � BOPS   �  MOTIVO DA ALTERACAO                   ���
��������������������������������������������������������������������������̱�
���Laura Medina�15/02/17�MMI-121 �Se realiza la replica del llamado TUCD44���
���            �        �        �para considerar en la generacion de la  ���
���            �        �        �OP el pago a trav�s de CBU.             ���
���Laura Medina�27/02/17�MMI-4160�Adecuacion para que haga retencion IVA  ���
���            �        �        �a NF/NCr�dito de diferentes sucursales. ���
���            �        �        �Se incluyo la solucion de issue MMI-4147���
���            �        �        �para la validacion del BCO que impacta  ���
���            �        �        �en la generacion de la OP.              ���
���Raul Ortiz  �28/02/17�MMI-4162�Adecuacion para que haga retencion IVA  ���
���            �        �        �Sobre el valor del documento para       ���
���            �        �        �empresas de Limpieza                    ���
���Laura Medina�01/03/17�MMI-4184�Realizar correctamente el calculo IIBB  ���
���            �        �        �cuando existe mas de un registro en la  ���
���            �        �        �SFF para mismo CFO y diferente tipo de  ���
���            �        �        �Contribuyente.                          ���
���Laura Medina�03/03/17�MMI-4166�En la funcion de Ret. de IVA, se cambia ���
���            �        �        �la validacion cAcmIVA <> "" por         ���
���            �        �        �!Empty(cAcmIVA).                        ���
���Raul Ortiz  �03/03/17�MMI-4148�Se incorpora funcionalidad para la RG   ���
���            �        �        �2854-11                                 ���
���Laura Medina�06/03/17�MMI-4168�Adecuacion para que haga retencion IIBB ���
���            �        �        �a NF/NCr�dito de diferentes sucursales. ���
���Raul Ortiz  �09/03/17�MMI-238 �Se guardar correctamente el importe     ���
���            �        �        �de deducci�n para condominios ganancias ���
���Raul Ortiz  �15/03/17�MMI-4182�Adecuaci�n para calcular correctamente  ���
���            �        �        �SUSS al ser el calculo por cuotas       ���
���Laura Medina�30/03/17�MMI-4533�Adecuaciones para las r�plicas de los   ���
���            �        �        �llamados: TTXJZP,TUVZY4,TUSJW3 y TUXRWJ.���
���Raul Ortiz  �23/03/17�MMI-4417�Adecuaci�n para calcular correctamente  ���
���            �        �        �IIBB a no Inscriptos                    ���
���Raul Ortiz  �28/03/17|MMI-4546�Se considera el calculo de m�nimos IIBB ���
���            �        �        �por Ordend de Pago y no por comprobante ���
���Raul Ortiz  �30/03/17|MMI-4938�Se consideran las retenciones generadas ���
���            �        �        �por las ordenes de Pago Previas         ���
���Laura Medina�19/05/17�MMI-5084�RG 032/2016 para SF, Tipo de Mi. (CCO_  ���
���            �        �        �TPMINR)3-Base Imponible M�nima+Impuesto,���
���            �        �        �se modifica la regla para tomar los m�- ���
���            �        �        �nimos con la nueva opci�n (3)...        ���
���Roberto Glez�19/05/17�MMI-5717�Correcci�n en calculo de retenci�n de   ���
���            �        �        �ganancias en un PA.                     ���
���Roberto Glez�02/06/17�MMI-5806�Modificaci�n de validaci�n para prov si ���
���            �        �        �es agente de retenci�n de IVA y evitar  ���
���            �        �        �la exlusi�n del calculo de otro proceso.���
���Laura Medina�29/05/17�MMI-5197�Se da el tratamiento  si es un PA, obte-���
���            �        �        �niendo de manera correcta la Retencion y���
���            �        �        �calculando la Ret. Ganancias para alma- ���
���            �        �        �cenar en los arreglos.                  ���
���Roberto Glez�08/06/17�MMI-5901�Cuando una NCP cuenta con m�s de un �tem���
���            �        �        �con la misma TES, considerar la al�cuota���
���            �        �        �correcta para el c�lculo.               ���
���Raul Ortiz  �08/06/17�MMI-5667� Modificaciones para mostrar las Ret.   ���
���            �        �        �en pantalla de las Ordenes de Pago      ���
���Laura Medina�15/06/17�MMI-5343�Adecuacion para que haga retencion IVA  ���
���            �        �        �correctamente y para que en Ret. de NCP ���
���            �        �        �considere la configuracion del par�metro���
���            �        �        �MV_AGENTE.                              ���
���Roberto Glez�06/10/17�DMICNS  �Considerar el codigo de impuesto en el  ���
���            �        �-292    �calculo de retencion de ganancias.      ���
���Jose Glez   �13/10/17�TSSERMI01�Se agrega la variable aImpInf a la     ���
���            �        �-189     �funcion ARGRetSLI                      ���
���Roberto Glz �24/07/17�DMICNS- �Para calculo de SUSS para NF y NCP,     ���
���            �        �108     �considerar las especificaciones de la RG���
���            �        �        �3983 para tomar el valor de F1/F2_VALSUS���
���            �        �        �en la orden de pago del documento.      ���
���Raul Ortiz M�20/12/17�DMICNS- �Cambios en calculo de retenciones de IB ���
���            �        �673     �en las 2 funciones para tomar en cuenta ���
���            �        �        �los limites de calculo por orden de pago���
���            �        �        �Argentina                               ���
���Raul Ortiz  �12/03/18�DMICNS- �Cambios para ganancias en condominios   ���
���            �        �1060    �conceptos diferentes a 04- Argentina    ���
���Marcos A    �27/03/18�DMICNS- �Se toma en cuenta tipo de m�nimo para   ���
���            �        � 1062   �retenciones de IIBB en base a la opcion ���
���            �        �        �3-Base Imponible+Impuestos (CCO_TPMINR).���
���            �        �        �Pais: Argentina (BA y CO).              ���
���Marco A. Glz�03/12/18�DMICNS- �Replica de issue DMICNS-4532 (11.8), que���
���            �        � 4603   �soluciona el calculo correcto de reten- ���
���            �        �        �ciones, cuando se ha superado el monto  ���
���            �        �        �minimo definido en el pago.             ���
���GSantacruz  �15/01/19�DMINA-  �ARGSegF2() - Ret Seguridad e Higiene NCP���
���            �        �    5674�Proceso correcto de aSFF, aCF y signo   ���
���            �        �        �de % FE_PORCRET.                        ���
���GSA/ARL     �07/03/19�DMINA-  �ARGRetIB()/ARGRetIB2() - Retenciones IB ���
���            �        �    5667�Procesar si hay mas de un item y es     ���
���            �        �        �proveedor no inscripto.                 ���
���Alf. Medrano�28/03/19�DMINA-  �se modifica fun ARGRetGN() se utiliza la���
���            �        �    5675�variable lRegOP que indica si restar�   ���
���            �        �        �valor del importe para obtener el impues���
���            �        �        �to de retenci�n                         ���
���Oscar G.    �04/04/19�DMINA-  �Se modifica fun ARGRetIB() inicia var.  ���
���            �        �    5708�nPercTot, se validan vigencias de regi- ���
���            �        �        �tros en SFH.                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������

�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ArgRetIVA � Autor �   Bruno Schmidt    � Data �  14/08/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � ArgRetIVA   - Calculo de Ret de IVA para NF                ���
�������������������������������������������������������������������������͹��
���Uso       � FINRETARG                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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
		cTxtRotAut += OemToAnsi(STR0003 + STR0005 + STR0007 +STR0004) //"Rutina de c�lculo de Retenci�n IVA (d�bito) desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0005 +STR0007 + STR0004),{OemToAnsi(STR0002)}) //"Rutina de c�lculo de Retenci�n IVA (d�bito) desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

RestArea(aArea)
Return aSFEIVA

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ARGRetIV2 � Autor �	Bruno Schmidt     � Data �  14/08/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � ArgRetIVA   - Calculo de Ret de IVA para NCP               ���
�������������������������������������������������������������������������͹��
���Uso       � FINRETARG                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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
		cTxtRotAut += OemToAnsi(STR0003 + STR0005 + STR0008 +STR0004) //"Rutina de c�lculo de Retenci�n de IVA (cr�dito) desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0005 + STR0008 + STR0004),{OemToAnsi(STR0002)}) //"Rutina de c�lculo de Retenci�n de IVA desactualizada (cr�dito), solicite paquete con actualizaciones." 
 	EndIf
EndIf

RestArea(aArea)
Return aSFEIVA

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ARGRetIB � Autor �	Bruno Schmidt     � Data �  14/08/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � ARGRetIB    - Calculo de Ret de IIB para NF                ���
�������������������������������������������������������������������������͹��
���Uso       � FINRETARG                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

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
 			cTxtRotAut += OemToAnsi(STR0003 + STR0009 + STR0007 +STR0004) //"Rutina de c�lculo de Retenci�n IIBB (d�bito) desactualizada, solicite paquete con actualizaciones."
 			lVldMsgIBB := .F. 
 		Endif
 		lMsErroAuto := .T.
 	Else
 		If  lVldMsgIBB
	 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0009 +STR0007 + STR0004),{OemToAnsi(STR0002)}) //"Rutina de c�lculo de Retenci�n IIBB (d�bito) desactualizada, solicite paquete con actualizaciones."
	 		lVldMsgIBB := .F. 
 		Endif 
 	EndIf
EndIf

RestArea(aArea)
Return aSFEIB

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ARGRetIB2 � Autor �	Bruno Schmidt     � Data �  14/08/14  ���
�������������������������������������������������������������������������͹��
���Desc.     � ARGRetIB2    - Calculo de Ret de IIB para NF               ���
�������������������������������������������������������������������������͹��
���Uso       � FINRETARG                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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
 			cTxtRotAut += OemToAnsi(STR0003 + STR0009 + STR0008 +STR0004) //"Rutina de c�lculo de Retenci�n IIBB (cr�dito) desactualizada, solicite paquete con actualizaciones."
 			lVldMsgIBB := .F.
 		Endif
 		lMsErroAuto := .T.
 	Else
 		If  lVldMsgIBB
	 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0009 +STR0008 + STR0004),{OemToAnsi(STR0002)}) //"Rutina de c�lculo de Retenci�n IIBB (cr�dito) desactualizada, solicite paquete con actualizaciones."
	 		lVldMsgIBB := .F. 
	 	Endif
 	EndIf
EndIf

RestArea(aArea)
Return aSFEIB


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ARGRetSUSS� Autor �	Bruno Schmidt     � Data �  14/08/14  ���
�������������������������������������������������������������������������͹��
���Desc.     � ARGRetSUSS  - Calculo de Ret de SUSS para NF               ���
�������������������������������������������������������������������������͹��
���Uso       � FINRETARG                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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
		cTxtRotAut += OemToAnsi(STR0003 + STR0006 + STR0007 +STR0004) //"Rutina de c�lculo de Retenci�n de SUSS (d�bito) desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0006 + STR0007 +STR0004),{OemToAnsi(STR0002)}) //"Rutina de c�lculo de Retenci�n de SUSS (d�bito) desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

RestArea(aArea)
Return aSFESUSS



/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ARGRetSU2 � Autor �	Bruno Schmidt     � Data �  14/08/14  ���
�������������������������������������������������������������������������͹��
���Desc.     � ARGRetSU2   - Calculo de Ret de SUSS para NCP              ���
�������������������������������������������������������������������������͹��
���Uso       � FINRETARG                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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
		cTxtRotAut += OemToAnsi(STR0003 + STR0006 + STR0008 +STR0004) //"Rutina de c�lculo de Retenci�n de SUSS (cr�dito) desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0006 + STR0008 +STR0004),{OemToAnsi(STR0002)}) //"Rutina de c�lculo de Retenci�n de SUSS (cr�dito) desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

RestArea(aArea)
Return aSFESUSS 

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ARGRetSLI � Autor �	Bruno Schmidt     � Data �  14/08/14  ���
�������������������������������������������������������������������������͹��
���Desc.     � ARGRetSLI   - Calculo de Ret de SLI para NF                ���
�������������������������������������������������������������������������͹��
���Uso       � FINRETARG                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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
		cTxtRotAut += OemToAnsi(STR0003 + STR0012 + STR0007 +STR0004) //"Rutina de c�lculo de Retenci�n de SLI (d�bito) desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0012 + STR0007 +STR0004),{OemToAnsi(STR0002)}) //"Rutina de c�lculo de Retenci�n de SLI (d�bito) desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

RestArea(aArea)
Return aSFESLI

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ARGRetSL2 � Autor �	Bruno Schmidt     � Data �  14/08/14  ���
�������������������������������������������������������������������������͹��
���Desc.     � ARGRetSL2   - Calculo de Ret de SLI para NF                ���
�������������������������������������������������������������������������͹��
���Uso       � FINRETARG                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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
		cTxtRotAut += OemToAnsi(STR0003 + STR0012 + STR0008 +STR0004) //"Rutina de c�lculo de Retenci�n de SLI (cr�dito) desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0012 + STR0008 +STR0004),{OemToAnsi(STR0002)}) //"Rutina de c�lculo de Retenci�n de SLI (cr�dito) desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

RestArea(aArea)
Return aSFESLI



/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ARGRetGN � Autor �	Bruno Schmidt     � Data �  14/08/14  ���
�������������������������������������������������������������������������͹��
���Desc.     � ARGRetGN    - Calculo de Ret de Ganancias                  ���
�������������������������������������������������������������������������͹��
���Uso       � FINRETARG                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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
		cTxtRotAut += OemToAnsi(STR0003 + STR0010 + STR0004) //"Rutina de c�lculo de Retenci�n Ganancias desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0010 + STR0004),{OemToAnsi(STR0002)}) //"Rutina de c�lculo de Retenci�n Ganancias desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

RestArea(aArea)
Return aSFEGN


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ARGRetGNMnt � Autor �  Bruno Schmidt   � Data �  14/08/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � Calculo de IVA para monotributista                         ���
�������������������������������������������������������������������������͹��
���Uso       � FINRETARG                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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
		cTxtRotAut += OemToAnsi(STR0003 + STR0010 + STR0011 + STR0004) //"Rutina de c�lculo de Retenci�n Ganancias para Monotributista desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0010 + STR0011 + STR0004),{OemToAnsi(STR0002)}) //"Rutina de c�lculo de Retenci�n Ganancias para Monotributista desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

RestArea(aArea)
Return aSFEGN

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �  ARGCpr  � Autor �	Bruno Schmidt     � Data �  14/08/14  ���
�������������������������������������������������������������������������͹��
���Desc.     � ARGCpr      - Calculo de Ret de CPR para NF                ���
�������������������������������������������������������������������������͹��
���Uso       � FINRETARG                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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
		cTxtRotAut += OemToAnsi(STR0003 + STR0014 + STR0007 + STR0004) //"Rutina de c�lculo de Retenci�n CPR (d�bito) desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0014 + STR0007 + STR0004),{OemToAnsi(STR0002)}) //"Rutina de c�lculo de Retenci�n CPR (d�bito)  desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

If Empty(aConCprRat)
	AAdd(aConCprRat, {,0,0,0,0,0,0,0,0,0,0})
EndIf

RestArea(aArea)
Return aConCprRat


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �  ARGCpr2 � Autor �	Bruno Schmidt     � Data �  14/08/14  ���
�������������������������������������������������������������������������͹��
���Desc.     � ARGCpr      - Calculo de Ret de CPR para NCP               ���
�������������������������������������������������������������������������͹��
���Uso       � FINRETARG                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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
		cTxtRotAut += OemToAnsi(STR0003 + STR0014 + STR0008 + STR0004) //"Rutina de c�lculo de Retenci�n de CPR (cr�dito) desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0014 + STR0008 + STR0004),{OemToAnsi(STR0002)}) //"Rutina de c�lculo de Retenci�n de CPR (cr�dito)  desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

If Empty(aConCprRat)
	AAdd(aConCprRat, {,0,0,0,0,0,0,0,0,0,0})
EndIf

RestArea(aArea)
Return aConCprRat


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ARGRetCmr � Autor �	Bruno Schmidt     � Data �  14/08/14  ���
�������������������������������������������������������������������������͹��
���Desc.     � ARGRetCmr   - Calculo de Ret de CMR para NF 		     	  ���
�������������������������������������������������������������������������͹��
���Uso       � FINRETARG                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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
		cTxtRotAut += OemToAnsi(STR0003 + STR0015 + STR0007 + STR0004) //"Rutina de c�lculo de Retenci�n de CMR (d�bito) desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0015 + STR0007 + STR0004),{OemToAnsi(STR0002)}) //"Rutina de c�lculo de Retenci�n de CMR (d�bito)  desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

If Empty(aConCmrRat)
	AAdd(aConCmrRat, {,0,0,0,0,0,0,0,0,0,0})
Endif

RestArea(aArea)
Return aConCmrRat

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ARGRetCmr2 � Autor �	Bruno Schmidt     � Data �  14/08/14  ���
�������������������������������������������������������������������������͹��
���Desc.     � ARGRetCmr2   - Calculo de Ret de CMR para NCP			  ���
�������������������������������������������������������������������������͹��
���Uso       � FINRETARG                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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
		cTxtRotAut += OemToAnsi(STR0003 + STR0015 + STR0008 + STR0004) //"Rutina de c�lculo de Retenci�n de CMR (cr�dito) desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0015 + STR0008 + STR0004),{OemToAnsi(STR0002)}) //"Rutina de c�lculo de Retenci�n de CMR (cr�dito)  desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

If Empty(aConCmrRat)
	AAdd(aConCmrRat, {,0,0,0,0,0,0,0,0,0,0})
Endif

RestArea(aArea)
Return aConCmrRat



/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ARGSegF1 � Autor �	Bruno Schmidt     � Data �  14/08/14  ���
�������������������������������������������������������������������������͹��
���Desc.     � ARGSegF1    - Calculo de Ret de Seguridad e Hig para NF    ���
�������������������������������������������������������������������������͹��
���Uso       � FINRETARG                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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
		cTxtRotAut += OemToAnsi(STR0003 + STR0013 + STR0007 + STR0004) //"Rutina de c�lculo de Retenci�n de Seguridad e Hig (d�bito) desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0013 + STR0007 + STR0004),{OemToAnsi(STR0002)}) //"Rutina de c�lculo de Retenci�n de Seguridad e Hig (d�bito) desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

RestArea(aArea)
Return aSFEISI

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ARGSegF2 � Autor �	Bruno Schmidt     � Data �  14/08/14  ���
�������������������������������������������������������������������������͹��
���Desc.     � ARGSegF2    - Calculo de Ret de Seguridad e Hig para NCP   ���
�������������������������������������������������������������������������͹��
���Uso       � FINRETARG                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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
		cTxtRotAut += OemToAnsi(STR0003 + STR0013 + STR0008 + STR0004) //"Rutina de c�lculo de Retenci�n de Seguridad e Hig (cr�dito) desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0013 + STR0008 + STR0004),{OemToAnsi(STR0002)}) //"Rutina de c�lculo de Retenci�n de Seguridad e Hig (cr�dito) desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

RestArea(aArea)
Return aSFEISI

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ARGRetIM � Autor �	Bruno Schmidt     � Data �  14/08/14  ���
�������������������������������������������������������������������������͹��
���Desc.     � ARGRetIM    - Calculo de Ret de Iva Monotributista para NCP���
�������������������������������������������������������������������������͹��
���Uso       � FINRETARG                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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
		cTxtRotAut += OemToAnsi(STR0003 + STR0005 + STR0007 + STR0011 +STR0004) //"Rutina de c�lculo de Retenci�n IVA (d�bito) para monotributista desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0005 + STR0007 + STR0011 +STR0004),{OemToAnsi(STR0002)}) //"Rutina de c�lculo de Retenci�n IVA (d�bito) para monotributista desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

RestArea(aArea)
Return aSFEIVA

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ARGRetIM2� Autor �	Bruno Schmidt     � Data �  14/08/14  ���
�������������������������������������������������������������������������͹��
���Desc.     �ARGRetIM2 - Calculo de Ret de Iva Monotributista para NCP   ���
�������������������������������������������������������������������������͹��
���Uso       � FINRETARG                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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
		cTxtRotAut += OemToAnsi(STR0003 + STR0005 + STR0008 + STR0011 +STR0004) //"Rutina de c�lculo de Retenci�n IVA (cr�dito) para monotributista desactualizada, solicite paquete con actualizaciones."
 		lMsErroAuto := .T.
 	Else
 		Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003 + STR0005 + STR0008 + STR0011 +STR0004),{OemToAnsi(STR0002)}) //"Rutina de c�lculo de Retenci�n IVA (cr�dito) para monotributista desactualizada, solicite paquete con actualizaciones." 
 	EndIf
EndIf

RestArea(aArea)
Return aSFEIVA



/*
������������������������������������������������������������������������ͻ
�Programa  �ObtReten   �Autor  �Raul Ortiz Medina   � Data �  19/09/19   �
������������������������������������������������������������������������͹
�Desc.     � Realiza el acumulado de los valores de Retenciones de una   �
�          � Orden de Pago Previa                                        �
������������������������������������������������������������������������͹
�Uso       � FINA850                                                     �
������������������������������������������������������������������������ͼ
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

