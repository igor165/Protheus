#include "PROTHEUS.CH" 
#DEFINE _DEBUG   .F.
#DEFINE _NOMIMPOST 01
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _IMPINCID  10
#DEFINE _RATEOFRET 11
#DEFINE _IMPFLETE  12
#DEFINE _RATEODESP 13
#DEFINE _IMPGASTOS 14
#DEFINE _RATEOSEGU	15
#DEFINE _IMPSEGU	16

#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5
#DEFINE _SEGURO		6


/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcion   ¦M100xiii  ¦ Autor ¦ William P. Alves       ¦Fecha ¦ 12.03.10¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descrip.  ¦ Programa que Calcula Imposto Interno Internacional	      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ MATA100, llamado por un punto de entrada                   ¦¦¦
¦¦+-----------------------------------------------------------------------¦¦¦
¦¦¦         ACTUALIZACIONES EFECTUADAS DESDE LA CODIFICACION INICIAL      ¦¦¦
¦¦+-----------------------------------------------------------------------¦¦¦
¦¦¦Programador ¦ Fecha  ¦ BOPS ¦  Motivo de la Alteracion                 ¦¦¦
¦¦+------------+--------+------+------------------------------------------¦¦¦
¦¦¦            ¦  /  /  ¦      ¦                                          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Function M100XIII(cCalculo,nItem,aInfo,cXFisRap)        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99

Local lXFis,xRet,nOrdSFC,nRegSFC
Local _nMoeda		:= 1
local _nBImpIII		:= 0 // Base Imponible del Impuesto Interno Internacional
Local _nAliqNominal := 0
local _nBaseCalculo := 0 // Base de Calculo
local _nImpuesto	:= 0 // Valor del impuesto
Local _nDecVal		:= TamSX3("D1_VALIMP"+aInfo[2])[2]
SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,AIMPOSTO,_CPROCNAME,_CZONCLSIGA")
SetPrvt("_LAGENTE,_LCALCULAR,_LESLEGAL,_NALICUOTA,_NVALORMIN")
SetPrvt("_NREDUCIR,")

Default cXFisRap := ""

lXfis:=(MaFisFound()  .And. ProcName(1)<>"EXECBLOCK")
cAliasRot  := Alias()
cOrdemRot  := IndexOrd()

If !lXFis
	aItemINFO  := ParamIxb[1]
	aImposto   := ParamIxb[2]
	xRet:=aImposto
Else
	xRet:=0
Endif

_cProcName := "U_M100III"

_cZonClSIGA:= SM0->M0_ESTCOB // Zona Fiscal del Cliente SIGA
_lAgente   := .F.     // En este impuesto el Proveedor Siempre cobra IVA.
_lExento   := .F.     // En esta empresa Siempre paga IVA Compras.

aFiscal    := ExecBlock("IMPGENER",.F.,.F.,{If(lXFis,{cCalculo,nItem,aInfo},ParamIxb), _cProcName, _lAgente,_cZonClSIGA,lXFis},.T.)

_lCalcular :=  aFiscal[1]
_lEsLegal  :=  aFiscal[2]
_nAlicuota :=  aFiscal[3]
_nValorMin :=  aFiscal[4]
_nReducir  :=  aFiscal[5]
_nMoeda    :=  aFiscal[7]

// Este imposto tem a taxa nominal e a taxa efetiva. A partir da taxa nominal chegamos na taxa efetiva
If SFB->(FieldPos("FB_PERCIII"))>0
	_nBImpIII		:= SFB->FB_PERCIII
EndIf
_nAliqNominal	:= _nAlicuota
_nAlicuota		:= Round((100 * _nAliqNominal)/(100-_nAliqNominal),_nDecVal)                                                        	

IF _DEBUG
	msgstop(_lCalcular, "Calcular - "+_cProcName)
	msgstop(_lEslegal , "Es Legal - "+_cProcName)
	msgstop(_nAlicuota, "Alicuota - "+_cProcName)
	msgstop(_nValorMin, "ValorMin - "+_cProcName)
	msgstop(_nReducir , "Reducir  - "+_cProcName)
ENDIF

IF  _lEsLegal
	If !lXFis
		
		aImposto[_RATEOFRET]	:= aItemINFO[_FLETE]      // Rateio do Frete
		aImposto[_RATEODESP]	:= aItemINFO[_GASTOS]     // Rateio de Despesas
		aImposto[_RATEOSEGU]	:= aItemINFO[_SEGURO]	  // Rateio de Seguros
		
		aImposto[_ALIQUOTA]		:= 	_nAliqNominal // Alicuota de Zona Fiscal del Proveedor
		aImposto[_BASECALC]		:= 	aItemINFO[_VLRTOTAL] 	+;
									aItemINFO[_FLETE]		+;
									aItemINFO[_SEGURO]		+;
									aItemINFO[_GASTOS] 
		
		//Tira os descontos se for pelo liquido .Bruno
		If Subs(aImposto[5],4,1) == "S"  .And. Len(AIMPOSTO) >= 18 .And. ValType(aImposto[18])=="N"
			aImposto[_BASECALC]	-=	aImposto[18]
		Endif
		
		//+---------------------------------------------------------------+
		//¦ Efectua el Cálculo del Impuesto                               ¦
		//+---------------------------------------------------------------+  
		_nBaseCalculo			:= aImposto[_BASECALC]
		_nImpuesto				:= _nBaseCalculo * (_nAlicuota / 100) 						// Calculo de Impuesto con tasa efectiva
		_nBaseCalculo			:= (_nBaseCalculo + _nImpuesto) * (1 + (_nBImpIII/100)) 	// Recalculo de la base de impuesto com tasa imponible
		_nImpuesto				:= _nBaseCalculo * (_nAliqNominal / 100) 					// Calculo efectivo del impuesto con la base ajustada
		
		aImposto[_BASECALC]	:= _nBaseCalculo
		aImposto[_IMPUESTO]	:= _nImpuesto
		
		xRet:=aImposto
	Else
		xRet := {0,0,0}
		
		//+---------------------------------------------------------------+
		//¦ Efectua el Cálculo del Impuesto                               ¦
		//+---------------------------------------------------------------+
		_nBaseCalculo :=	MaFisRet(nItem,"IT_VALMERC")	+;
							MaFisRet(nItem,"IT_FRETE")		+;
							MaFisRet(nItem,"IT_SEGURO")		+;
							MaFisRet(nItem,"IT_DESPESA")
		
		//Tira os descontos se for pelo liquido
		nOrdSFC:=(SFC->(IndexOrd()))
		nRegSFC:=(SFC->(Recno()))
		SFC->(DbSetOrder(2))
		If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[1])))
			If SFC->FC_LIQUIDO=="S"
				_nBaseCalculo -= MaFisRet(nItem,"IT_DESCONTO")
			Endif
		Endif
		SFC->(DbSetOrder(nOrdSFC))
		SFC->(DbGoto(nRegSFC))
		
		_nImpuesto			:= _nBaseCalculo * (_nAlicuota / 100) 						// Calculo de Impuesto con tasa efectiva
		_nBaseCalculo		:= (_nBaseCalculo + _nImpuesto) * (1 + (_nBImpIII/100)) 	// Recalculo de la base de impuesto com tasa imponible
		_nImpuesto			:= _nBaseCalculo * (_nAliqNominal / 100) 					// Calculo efectivo del impuesto con la base ajustada
		
		xRet := { _nBaseCalculo , _nAliqNominal, _nImpuesto }
		
		If !Empty(cXFisRap)
			If "V" $ cXFisRap
				xRet[3] := NoRound( _nImpuesto ,MsDecimais(_nMoeda))
			Endif
		Else
			Do Case
				Case cCalculo=="A"
					xRet:=	_nAliqNominal
				Case cCalculo=="B"
					xRet:=	_nBaseCalculo
				Case cCalculo=="V"
					xRet:=	NoRound( _nImpuesto ,MsDecimais(_nMoeda))
			Endcase
		Endif
	Endif
ENDIF

dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return( xRet )        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99
