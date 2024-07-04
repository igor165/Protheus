#DEFINE _NOMEIMPOS 01
#DEFINE _ALIQUOTA  02

#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _RATEOFRET 11
#DEFINE _RATEODESP 13
#DEFINE _IMPGASTOS 14
#DEFINE _IMPFLETE  12
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100EIC  ³ Autor ³ Bruno & Lucas          ³ Data ³ 20.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcoes para calculo dos impostos para integracao com       ³±±
±±³          ³ SIGAEIC x SIGACOM												         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ AP5			                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Lucas        ³01/06/01³XXXXXX³Impostos para o Chile                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

STATIC nAcumERC:= 0,nACumECC:= 0,nAcumETI:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Segundo Jonato Silva/Average sempre serao Calculados na   ³
//³ moeda 1, e pediu expressamente para arredondar os valores ³
//³ com as casas correspondentes. Bruno/Microsiga             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100EIV    ³ Autor ³ Lucas			        ³ Data ³ 01.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo do IVA para Importacion...				              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100EIV()
LOCAL cFunc, aRet:={}
cAliasRot:=Alias()
cOrdemRot:= IndexOrd()

If !M100CIMP()
	If MafisFound() 
		Return(0)
	Else
		Return(aRet)
    EndIf
EndIf


cFunc:="M100EIV"+left(cPaisLoc,2)
cFunc:=cFunc+"()"
aRet:=&(cFunc)
dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return( aRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100EDI    ³ Autor ³ Lucas			        ³ Data ³ 20.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo dos Direitos de Importacion...				           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100EDI()
LOCAL cFunc, aRet:={}
cAliasRot:=Alias()
cOrdemRot:= IndexOrd()

If !M100CIMP()
	If MafisFound() 
		Return(0)
	Else
		Return(aRet)
    EndIf
EndIf

cFunc:="M100EDI"+left(cPaisLoc,2)
cFunc:=cFunc+"()"
aRet:=&(cFunc)
dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return( aRet )

*****************************************************************************
**Impostos exclusivos da Argentina														**
*****************************************************************************
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100EIV    ³ Autor ³ Bruno			        ³ Data ³ 20.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo do IVA para o Paraguay... 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100EIVAR()
Local aItemINFO	
Local aImposto  
Local aDespesas 	:=	{}
Local cImpIncid 
Local cTec			:=	""
Local nE,nI
Local nDecs			:=	MsDecimais(1)
Local aRet:={}

If !M100CIMP()
	If MafisFound() 
		Return(0)
	Else
		Return(aRet)
    EndIf
EndIf


aItemINFO	:=	ParamIxb[1]
aImposto  	:=	AClone( ParamIxb[2] )
cImpIncid 	:=	aImposto[10]

If Len(ParamIxb[1]) >= 8
	cTec	:=	ParamIxb[1][8]
Endif
If Len(ParamIxb[1]) >= 9
	aDespesas	:=	ParamIxb[1][9]
Endif

DbSelectArea("SFF")
DbSetOrder(7)
DbSeek(xFilial()+ cTec + "EIV" )
If Found()
	aImposto[_ALIQUOTA]  := SFF->FF_ALIQ
Else
	aImposto[_ALIQUOTA]  := SFB->FB_ALIQ
Endif

aImposto[_RATEOFRET] := aItemINFO[_FLETE]      // Rateio do Frete
aImposto[_RATEODESP] := aItemINFO[_GASTOS]     // Rateio de Despesas
aImposto[_BASECALC]  := aItemINFO[_VLRTOTAL]+aItemINFO[_FLETE]+aItemINFO[_GASTOS] // Base de Cálculo

//Tira os descontos se for pelo liquido .Bruno
If Subs(aImposto[5],4,1) == "S"  .And. Len(AIMPOSTO) == 18 .And. ValType(aImposto[18])=="N"
	aImposto[_BASECALC]	-=	aImposto[18]
Endif

nI := At( ";",cImpIncid )
nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
While nI > 1
	nE := AScan( aItemINFO[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
	If nE > 0
		aImposto[3] := aImposto[3]+aItemINFO[6,nE,4]
	End

	cImpIncid := Stuff( cImpIncid,1,nI,"" )
	nI := At( ";",cImpIncid )
	nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
End

For nE	:=	1	To Len(aDespesas)
	If At("EIV",aDespesas[nE][3]) > 0
		aImposto[_BASECALC] += aDespesas[nE][2]
	Endif
Next nE

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto                                   ¦
//+---------------------------------------------------------------+
aImposto[_BASECALC]	:=	Round(aImposto[_BASECALC],nDecs)
aImposto[_IMPUESTO]  := ROUND(aImposto[_BASECALC] * aImposto[_ALIQUOTA]/100,nDecs)

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto sobre Frete                       ¦
//+---------------------------------------------------------------+
//   aImposto[_IMPFLETE]  := ROUND(aImposto[_RATEOFRET] * aImposto[_ALIQUOTA]/100,2)

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto sobre Despesas                    ¦
//+---------------------------------------------------------------+
// aImposto[_IMPGASTOS] := ROUND(aImposto[_RATEODESP] * aImposto[_ALIQUOTA]/100,2)

Return( aImposto )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100EDI    ³ Autor ³ Bruno/Lucas			  ³ Data ³ 20.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo dos Direitos de Importacao para Argentina...		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100EDIAR()
Local aItemINFO	:=	ParamIxb[1]
Local aImposto  	:=	AClone( ParamIxb[2] )
Local aDespesas 	:=	{}
Local	cImpIncid 	:=	aImposto[10]
Local cTec			:=	""
Local nE,nI

If Len(ParamIxb[1]) >= 8
	cTec	:=	ParamIxb[1][8]
Endif
If Len(ParamIxb[1]) >= 9
	aDespesas	:=	ParamIxb[1][9]
Endif

DbSelectArea("SFF")
DbSetOrder(7)
DbSeek(xFilial()+ cTec + "EDI" )
If Found()
	aImposto[_ALIQUOTA]  := SFF->FF_ALIQ
Else
	aImposto[_ALIQUOTA]  := SFB->FB_ALIQ
Endif
//+---------------------------------------------------------------+
//¦ Obter Base de Cálculo e Aliquota dos Impostos.                ¦
//+---------------------------------------------------------Lucas-+
aImposto[_RATEOFRET] := aItemINFO[_FLETE]      // Rateio do Frete
aImposto[_RATEODESP] := aItemINFO[_GASTOS]     // Rateio de Despesas
aImposto[_BASECALC]  := aItemINFO[_VLRTOTAL]+aItemINFO[_FLETE]+aItemINFO[_GASTOS] // Base de Cálculo

//Tira os descontos se for pelo liquido .Bruno
If Subs(aImposto[5],4,1) == "S"  .And. Len(AIMPOSTO) == 18 .And. ValType(aImposto[18])=="N"
	aImposto[_BASECALC]	-=	aImposto[18]
Endif

//+---------------------------------------------------------------+
//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
//+---------------------------------------------------------Lucas-+
nI := At( ";",cImpIncid )
nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
While nI > 1
	nE := AScan( aItemINFO[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
	If nE > 0
		aImposto[3] := aImposto[3]+aItemINFO[6,nE,4]
	End

	cImpIncid := Stuff( cImpIncid,1,nI,"" )
	nI := At( ";",cImpIncid )
	nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
End
For nE	:=	1	To Len(aDespesas)
	If At("EDI",aDespesas[nE][3]) > 0
		aImposto[_BASECALC] += aDespesas[nE][2]
	Endif
Next
//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto                                   ¦
//+---------------------------------------------------------------+
aImposto[_IMPUESTO]  := ROUND(aImposto[_BASECALC] * aImposto[_ALIQUOTA]/100,2)

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto sobre Frete                       ¦
//+---------------------------------------------------------------+
//   aImposto[_IMPFLETE]  := ROUND(aImposto[_RATEOFRET] * aImposto[_ALIQUOTA]/100,2)

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto sobre Despesas                    ¦
//+---------------------------------------------------------------+
// aImposto[_IMPGASTOS] := ROUND(aImposto[_RATEODESP] * aImposto[_ALIQUOTA]/100,2)

Return( aImposto )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100ETE    ³ Autor ³ Bruno/Lucas			  ³ Data ³ 20.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo da Taxa de Estatistica para Argentina...			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100ETE()
Local aItemINFO	
Local aImposto  
Local aDespesas 	:=	{}
Local cImpIncid 
Local cTec			:=	""
Local nE,nI
Local nLimite	:= 0
Local nMoedLim	:= 0
Local aRet:={}

If !M100CIMP()
	If MafisFound() 
		Return(0)
	Else
		Return(aRet)
    EndIf
EndIf

aItemINFO	:=	ParamIxb[1]
aImposto  	:=	AClone( ParamIxb[2] )
cImpIncid 	:=	aImposto[10]

If Len(ParamIxb[1]) >= 8
	cTec	:=	ParamIxb[1][8]
Endif
If Len(ParamIxb[1]) >= 9
	aDespesas	:=	ParamIxb[1][9]
Endif

nLimite:=0
nMoedLim:=1  

DbSelectArea("SFF")
DbSetOrder(7)
DbSeek(xFilial()+ cTec + "ETE" )
If Found()
	aImposto[_ALIQUOTA]  := SFF->FF_ALIQ
	nLimite := SFF->FF_IMPORTE
	nMoedLim:= SFF->FF_MOEDA
Else
	aImposto[_ALIQUOTA]  := SFB->FB_ALIQ
Endif

//+---------------------------------------------------------------+
//¦ Obter Base de Cálculo e Aliquota dos Impostos.                ¦
//+---------------------------------------------------------Lucas-+
aImposto[_RATEOFRET] := aItemINFO[_FLETE]      // Rateio do Frete
aImposto[_RATEODESP] := aItemINFO[_GASTOS]     // Rateio de Despesas
aImposto[_BASECALC]  := aItemINFO[_VLRTOTAL]+aItemINFO[_FLETE]+aItemINFO[_GASTOS] // Base de Cálculo

//Tira os descontos se for pelo liquido .Bruno
If Subs(aImposto[5],4,1) == "S"  .And. Len(AIMPOSTO) == 18 .And. ValType(aImposto[18])=="N"
	aImposto[_BASECALC]	-=	aImposto[18]
Endif

//+---------------------------------------------------------------+
//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
//+---------------------------------------------------------Lucas-+
nI := At( ";",cImpIncid )
nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
While nI > 1
	nE := AScan( aItemINFO[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
	If nE > 0
		aImposto[3] := aImposto[3]+aItemINFO[6,nE,4]
	End

	cImpIncid := Stuff( cImpIncid,1,nI,"" )
	nI := At( ";",cImpIncid )
	nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
End
For nE	:=	1	To Len(aDespesas)
	If At("ETE",aDespesas[nE][3]) > 0
		aImposto[_BASECALC] += aDespesas[nE][2]
	Endif
Next
//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto                                   ¦
//+---------------------------------------------------------------+
aImposto[_IMPUESTO]  := ROUND(aImposto[_BASECALC] * aImposto[_ALIQUOTA]/100,2)

//+---------------------------------------------------------------+
//¦ Verifcar o valor limite estabelecido pela AFIP para este      ¦
//¦ imposto.                                                      ¦
//+---------------------------------------------------------------+
If nLimite>0
	nLimite:=xMoeda(nLimite,nMoedLim,1,,2)
	aImposto[_IMPUESTO]  := Min(aImposto[_IMPUESTO],nLimite)
Endif

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto sobre Frete                       ¦
//+---------------------------------------------------------------+
//   aImposto[_IMPFLETE]  := ROUND(aImposto[_RATEOFRET] * aImposto[_ALIQUOTA]/100,2)

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto sobre Despesas                    ¦
//+---------------------------------------------------------------+
// aImposto[_IMPGASTOS] := ROUND(aImposto[_RATEODESP] * aImposto[_ALIQUOTA]/100,2)

Return( aImposto )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100EIA    ³ Autor ³ Bruno/Lucas			  ³ Data ³ 20.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo do IVA Adicional para Argentina...					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100EIA()
Local aItemINFO 
Local aImposto  
Local aDespesas :=	{}
Local cImpIncid 
Local cTec		 :=	""
Local nE,nI
Local aRet:={}

If !M100CIMP()
	If MafisFound() 
		Return(0)
	Else
		Return(aRet)
    EndIf
EndIf
                                    
aItemINFO :=	ParamIxb[1]
aImposto  :=	AClone( ParamIxb[2] )
cImpIncid :=	aImposto[10]

If Len(ParamIxb[1]) >= 8
	cTec	:=	ParamIxb[1][8]
Endif
If Len(ParamIxb[1]) >= 9
	aDespesas	:=	ParamIxb[1][9]
Endif

DbSelectArea("SFF")
DbSetOrder(7)
DbSeek(xFilial()+ cTec + "EIA" )
If Found()
	aImposto[_ALIQUOTA]  := SFF->FF_ALIQ
Else
	aImposto[_ALIQUOTA]  := SFB->FB_ALIQ
Endif

//+---------------------------------------------------------------+
//¦ Obter Base de Cálculo e Aliquota dos Impostos.                ¦
//+---------------------------------------------------------Lucas-+
aImposto[_RATEOFRET] := aItemINFO[_FLETE]      // Rateio do Frete
aImposto[_RATEODESP] := aItemINFO[_GASTOS]     // Rateio de Despesas
aImposto[_BASECALC]  := aItemINFO[_VLRTOTAL]+aItemINFO[_FLETE]+aItemINFO[_GASTOS] // Base de Cálculo

//Tira os descontos se for pelo liquido .Bruno
If Subs(aImposto[5],4,1) == "S"  .And. Len(AIMPOSTO) == 18 .And. ValType(aImposto[18])=="N"
	aImposto[_BASECALC]	-=	aImposto[18]
Endif

//+---------------------------------------------------------------+
//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
//+---------------------------------------------------------Lucas-+
nI := At( ";",cImpIncid )
nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
While nI > 1
	nE := AScan( aItemINFO[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
	If nE > 0
		aImposto[3] := aImposto[3]+aItemINFO[6,nE,4]
	End

	cImpIncid := Stuff( cImpIncid,1,nI,"" )
	nI := At( ";",cImpIncid )
	nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
End
For nE	:=	1	To Len(aDespesas)
	If At("EIA",aDespesas[nE][3] ) > 0
		aImposto[_BASECALC] += aDespesas[nE][2]
	Endif
Next
//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto                                   ¦
//+---------------------------------------------------------------+
aImposto[_IMPUESTO]  := ROUND(aImposto[_BASECALC] * aImposto[_ALIQUOTA]/100,2)

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto sobre Frete                       ¦
//+---------------------------------------------------------------+
//   aImposto[_IMPFLETE]  := ROUND(aImposto[_RATEOFRET] * aImposto[_ALIQUOTA]/100,2)

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto sobre Despesas                    ¦
//+---------------------------------------------------------------+
// aImposto[_IMPGASTOS] := ROUND(aImposto[_RATEODESP] * aImposto[_ALIQUOTA]/100,2)

Return( aImposto )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100EIG    ³ Autor ³ Bruno/Lucas			  ³ Data ³ 20.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo de Impostos de Ganancias para Argentina...			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100EIG()
Local aItemINFO	
Local aImposto  
Local aDespesas 	:=	{}
Local cImpIncid 
Local cTec			:=	""
Local nE,nI
Local aRet:={}              

If !M100CIMP()
	If MafisFound() 
		Return(0)
	Else
		Return(aRet)
    EndIf
EndIf
      
aItemINFO	:=	ParamIxb[1]
aImposto  	:=	AClone( ParamIxb[2] )
cImpIncid 	:=	aImposto[10]

If Len(ParamIxb[1]) >= 8
	cTec	:=	ParamIxb[1][8]
Endif
If Len(ParamIxb[1]) >= 9
	aDespesas	:=	ParamIxb[1][9]
Endif

DbSelectArea("SFF")
DbSetOrder(7)
DbSeek(xFilial()+ cTec + "EIG" )
If Found()
	aImposto[_ALIQUOTA]  := SFF->FF_ALIQ
Else
	aImposto[_ALIQUOTA]  := SFB->FB_ALIQ
Endif

//+---------------------------------------------------------------+
//¦ Obter Base de Cálculo e Aliquota dos Impostos.                ¦
//+---------------------------------------------------------Lucas-+
aImposto[_RATEOFRET] := aItemINFO[_FLETE]      // Rateio do Frete
aImposto[_RATEODESP] := aItemINFO[_GASTOS]     // Rateio de Despesas
aImposto[_BASECALC]  := aItemINFO[_VLRTOTAL]+aItemINFO[_FLETE]+aItemINFO[_GASTOS] // Base de Cálculo

//Tira os descontos se for pelo liquido .Bruno
If Subs(aImposto[5],4,1) == "S"  .And. Len(AIMPOSTO) == 18 .And. ValType(aImposto[18])=="N"
	aImposto[_BASECALC]	-=	aImposto[18]
Endif

//+---------------------------------------------------------------+
//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
//+---------------------------------------------------------Lucas-+
nI := At( ";",cImpIncid )
nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
While nI > 1
	nE := AScan( aItemINFO[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
	If nE > 0
		aImposto[3] := aImposto[3]+aItemINFO[6,nE,4]
	End

	cImpIncid := Stuff( cImpIncid,1,nI,"" )
	nI := At( ";",cImpIncid )
	nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
End
For nE	:=	1	To Len(aDespesas)
	If At("EIG",aDespesas[nE][3]) > 0
		aImposto[_BASECALC] += aDespesas[nE][2]
	Endif
Next
//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto                                   ¦
//+---------------------------------------------------------------+
aImposto[_IMPUESTO]  := ROUND(aImposto[_BASECALC] * aImposto[_ALIQUOTA]/100,2)

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto sobre Frete                       ¦
//+---------------------------------------------------------------+
//   aImposto[_IMPFLETE]  := ROUND(aImposto[_RATEOFRET] * aImposto[_ALIQUOTA]/100,2)

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto sobre Despesas                    ¦
//+---------------------------------------------------------------+
// aImposto[_IMPGASTOS] := ROUND(aImposto[_RATEODESP] * aImposto[_ALIQUOTA]/100,2)

Return( aImposto )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100EFC    ³ Autor ³ Bruno               ³ Data ³ 28.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo da taxa "Fator de conversao", taxa provisoria      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100EFC()
Local aItemINFO	
Local aImposto  
Local aDespesas 	:=	{}
Local cImpIncid
Local cTec			:=	""
Local nE,nI
Local aRet:={}              

If !M100CIMP()
	If MafisFound() 
		Return(0)
	Else
		Return(aRet)
    EndIf
EndIf

aItemINFO	:=	ParamIxb[1]
aImposto  	:=	AClone( ParamIxb[2] )
cImpIncid 	:=	aImposto[10]      

If SFF->(FieldPos("FF_DATA")) > 0

	If Len(ParamIxb[1]) >= 8
		cTec  := ParamIxb[1][8]
	Endif
	If Len(ParamIxb[1]) >= 9
		aDespesas   := ParamIxb[1][9]
	Endif

	DbSelectArea("SFF")
	DbSetOrder(8)
	DbSeek(xFilial()+"EFC"+DTOS(dDataBase))
	If Found()
		aImposto[_ALIQUOTA]  := SFF->FF_ALIQ * 100
	Else
		aImposto[_ALIQUOTA]  := SFB->FB_ALIQ * 100
	Endif
	//+---------------------------------------------------------------+
	//¦ Obter Base de Cálculo e Aliquota dos Impostos.                ¦
	//+---------------------------------------------------------Lucas-+
	aImposto[_RATEOFRET] := aItemINFO[_FLETE]      // Rateio do Frete
	aImposto[_RATEODESP] := aItemINFO[_GASTOS]     // Rateio de Despesas
	aImposto[_BASECALC]  := aItemINFO[_VLRTOTAL]+aItemINFO[_FLETE]+aItemINFO[_GASTOS] // Base de Cálculo

	//Tira os descontos se for pelo liquido .Bruno
	If Subs(aImposto[5],4,1) == "S" 
		aImposto[_BASECALC]	-=	aImposto[18]  // aImposto[18] = Desconto
	Endif

	//+---------------------------------------------------------------+
	//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
	//+---------------------------------------------------------Lucas-+
	nI := At( ";",cImpIncid )
	nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
	While nI > 1
		nE := AScan( aItemINFO[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
		If nE > 0
			aImposto[3] := aImposto[3]+aItemINFO[6,nE,4]
		End

		cImpIncid := Stuff( cImpIncid,1,nI,"" )
		nI := At( ";",cImpIncid )
		nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
	End
	For nE	:=	1	To Len(aDespesas)
		If At("EFC",aDespesas[nE][3]) > 0
			aImposto[_BASECALC] += aDespesas[nE][2]
		Endif
	Next
	//+---------------------------------------------------------------+
	//¦ Efetua o Cálculo do Imposto                                   ¦
	//+---------------------------------------------------------------+
	aImposto[_IMPUESTO]  := ROUND(aImposto[_BASECALC] * aImposto[_ALIQUOTA]/100,2)
Endif
Return( aImposto )

*****************************************************************************
**Impostos exclusivos do Paraguai                                          **
*****************************************************************************
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100EIV    ³ Autor ³ Bruno			        ³ Data ³ 20.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo do IVA para o Paraguay... 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100EIVPA()
Local aItemINFO	:=	ParamIxb[1]
Local aImposto  	:=	AClone( ParamIxb[2] )
Local aDespesas 	:=	{}
Local	cImpIncid 	:=	aImposto[10]
Local cTec			:=	""
Local nE,nI
Local nDecs			:=	MsDecimais(1)

If Len(ParamIxb[1]) >= 8
	cTec	:=	ParamIxb[1][8]
Endif
If Len(ParamIxb[1]) >= 9
	aDespesas	:=	ParamIxb[1][9]
Endif

DbSelectArea("SFF")
DbSetOrder(7)
DbSeek(xFilial()+ cTec + "EIV" )
If Found()
	aImposto[_ALIQUOTA]  := SFF->FF_ALIQ
Else
	aImposto[_ALIQUOTA]  := SFB->FB_ALIQ
Endif

aImposto[_RATEOFRET] := aItemINFO[_FLETE]      // Rateio do Frete
aImposto[_RATEODESP] := aItemINFO[_GASTOS]     // Rateio de Despesas
aImposto[_BASECALC]  := aItemINFO[_VLRTOTAL]+aItemINFO[_FLETE]+aItemINFO[_GASTOS] // Base de Cálculo

//Tira os descontos se for pelo liquido .Bruno
If Subs(aImposto[5],4,1) == "S"  .And. Len(AIMPOSTO) == 18 .And. ValType(aImposto[18])=="N"
	aImposto[_BASECALC]	-=	aImposto[18]
Endif

nI := At( ";",cImpIncid )
nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
While nI > 1
	nE := AScan( aItemINFO[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
	If nE > 0
		aImposto[3] := aImposto[3]+aItemINFO[6,nE,4]
	End

	cImpIncid := Stuff( cImpIncid,1,nI,"" )
	nI := At( ";",cImpIncid )
	nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
End

For nE	:=	1	To Len(aDespesas)
	If At("EIV",aDespesas[nE][3]) > 0
		aImposto[_BASECALC] += aDespesas[nE][2]
	Endif
Next nE

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto                                   ¦
//+---------------------------------------------------------------+
aImposto[_BASECALC]	:=	Round(aImposto[_BASECALC],nDecs)
aImposto[_IMPUESTO]  := ROUND(aImposto[_BASECALC] * aImposto[_ALIQUOTA]/100,nDecs)

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto sobre Frete                       ¦
//+---------------------------------------------------------------+
//   aImposto[_IMPFLETE]  := ROUND(aImposto[_RATEOFRET] * aImposto[_ALIQUOTA]/100,2)

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto sobre Despesas                    ¦
//+---------------------------------------------------------------+
// aImposto[_IMPGASTOS] := ROUND(aImposto[_RATEODESP] * aImposto[_ALIQUOTA]/100,2)

Return( aImposto )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100EI2    ³ Autor ³ Bruno/Lucas         ³ Data ³ 20.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo do IVA para o Paraguay...						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100EI2PA()
Local aItemINFO	
Local aImposto  
Local aDespesas 	:=	{}
Local cImpIncid 
Local cTec			:=	""
Local nE,nI
Local nDecs			:=	MsDecimais(1)
Local aRet:={}              

If !M100CIMP()
	If MafisFound() 
		Return(0)
	Else
		Return(aRet)
    EndIf
EndIf
      
aItemINFO	:=	ParamIxb[1]
aImposto  	:=	AClone( ParamIxb[2] )
cImpIncid 	:=	aImposto[10]

If Len(ParamIxb[1]) >= 8
	cTec	:=	ParamIxb[1][8]
Endif
If Len(ParamIxb[1]) >= 9
	aDespesas	:=	ParamIxb[1][9]
Endif

DbSelectArea("SFF")
DbSetOrder(7)
DbSeek(xFilial()+ cTec + "EI2" )
If Found()
	aImposto[_ALIQUOTA]  := SFF->FF_ALIQ
Else
	aImposto[_ALIQUOTA]  := SFB->FB_ALIQ
Endif

aImposto[_RATEOFRET] := aItemINFO[_FLETE]      // Rateio do Frete
aImposto[_RATEODESP] := aItemINFO[_GASTOS]     // Rateio de Despesas
aImposto[_BASECALC]  := aItemINFO[_VLRTOTAL]+aItemINFO[_FLETE]+aItemINFO[_GASTOS] // Base de Cálculo

//Tira os descontos se for pelo liquido .Bruno
If Subs(aImposto[5],4,1) == "S"  .And. Len(AIMPOSTO) == 18 .And. ValType(aImposto[18])=="N"
	aImposto[_BASECALC]	-=	aImposto[18]
Endif

nI := At( ";",cImpIncid )
nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
While nI > 1
	nE := AScan( aItemINFO[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
	If nE > 0
		aImposto[3] := aImposto[3]+aItemINFO[6,nE,4]
	End

	cImpIncid := Stuff( cImpIncid,1,nI,"" )
	nI := At( ";",cImpIncid )
	nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
End

For nE	:=	1	To Len(aDespesas)
	If At("EIV",aDespesas[nE][3]) > 0
		aImposto[_BASECALC] += aDespesas[nE][2]
	Endif
Next nE

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto                                   ¦
//+---------------------------------------------------------------+
aImposto[_BASECALC]	:=	Round(aImposto[_BASECALC],nDecs)
aImposto[_IMPUESTO]  := ROUND(aImposto[_BASECALC] * aImposto[_ALIQUOTA]/100,nDecs)

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto sobre Frete                       ¦
//+---------------------------------------------------------------+
//   aImposto[_IMPFLETE]  := ROUND(aImposto[_RATEOFRET] * aImposto[_ALIQUOTA]/100,2)

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto sobre Despesas                    ¦
//+---------------------------------------------------------------+
// aImposto[_IMPGASTOS] := ROUND(aImposto[_RATEODESP] * aImposto[_ALIQUOTA]/100,2)
Return( aImposto )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100EDI    ³ Autor ³ Bruno/Lucas			  ³ Data ³ 20.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo dos Direitos de Importacao para Paraguay...		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100EDIPA()
Local aItemINFO	:=	ParamIxb[1]
Local aImposto  	:=	AClone( ParamIxb[2] )
Local aDespesas 	:=	{}
Local	cImpIncid 	:=	aImposto[10]
Local cTec			:=	""
Local nE,nI

If Len(ParamIxb[1]) >= 8
	cTec	:=	ParamIxb[1][8]
Endif
If Len(ParamIxb[1]) >= 9
	aDespesas	:=	ParamIxb[1][9]
Endif

DbSelectArea("SFF")
DbSetOrder(7)
DbSeek(xFilial()+ cTec + "EDI" )
If Found()
	aImposto[_ALIQUOTA]  := SFF->FF_ALIQ
Else
	aImposto[_ALIQUOTA]  := SFB->FB_ALIQ
Endif
//+---------------------------------------------------------------+
//¦ Obter Base de Cálculo e Aliquota dos Impostos.                ¦
//+---------------------------------------------------------Lucas-+
aImposto[_RATEOFRET] := aItemINFO[_FLETE]      // Rateio do Frete
aImposto[_RATEODESP] := aItemINFO[_GASTOS]     // Rateio de Despesas
aImposto[_BASECALC]  := aItemINFO[_VLRTOTAL]+aItemINFO[_FLETE]+aItemINFO[_GASTOS] // Base de Cálculo

//Tira os descontos se for pelo liquido .Bruno
If Subs(aImposto[5],4,1) == "S"  .And. Len(AIMPOSTO) == 18 .And. ValType(aImposto[18])=="N"
	aImposto[_BASECALC]	-=	aImposto[18]
Endif

//+---------------------------------------------------------------+
//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
//+---------------------------------------------------------Lucas-+
nI := At( ";",cImpIncid )
nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
While nI > 1
	nE := AScan( aItemINFO[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
	If nE > 0
		aImposto[3] := aImposto[3]+aItemINFO[6,nE,4]
	End
	
	cImpIncid := Stuff( cImpIncid,1,nI,"" )
	nI := At( ";",cImpIncid )
	nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
End
For nE	:=	1	To Len(aDespesas)
	If At("EDI",aDespesas[nE][3]) > 0
		aImposto[_BASECALC] += aDespesas[nE][2]
	Endif
Next
//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto                                   ¦
//+---------------------------------------------------------------+
aImposto[_IMPUESTO]  := ROUND(aImposto[_BASECALC] * aImposto[_ALIQUOTA]/100,2)

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto sobre Frete                       ¦
//+---------------------------------------------------------------+
//   aImposto[_IMPFLETE]  := ROUND(aImposto[_RATEOFRET] * aImposto[_ALIQUOTA]/100,2)

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto sobre Despesas                    ¦
//+---------------------------------------------------------------+
// aImposto[_IMPGASTOS] := ROUND(aImposto[_RATEODESP] * aImposto[_ALIQUOTA]/100,2)

Return( aImposto )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100ETA    ³ Autor ³ Bruno/Lucas	        ³ Data ³ 20.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo do Tributo Aduanero para Paraguay...					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100ETA()
Local aItemINFO	
Local aImposto  
Local aDespesas 	:=	{}
Local cImpIncid
Local cTec			:=	""
Local nE,nI
Local nDecs			:=	MsDecimais(1)
Local aRet:={}

If !M100CIMP()
	If MafisFound() 
		Return(0)
	Else
		Return(aRet)
    EndIf
EndIf
      
aItemINFO	:=	ParamIxb[1]
aImposto  	:=	AClone( ParamIxb[2] )
cImpIncid 	:=	aImposto[10]

If Len(ParamIxb[1]) >= 8
	cTec	:=	ParamIxb[1][8]
Endif
If Len(ParamIxb[1]) >= 9
	aDespesas	:=	ParamIxb[1][9]
Endif

DbSelectArea("SFF")
DbSetOrder(7)
DbSeek(xFilial()+ cTec + "ETA" )
If Found()
	aImposto[_ALIQUOTA]  := SFF->FF_ALIQ
Else
	aImposto[_ALIQUOTA]  := SFB->FB_ALIQ
Endif

aImposto[_RATEOFRET] := aItemINFO[_FLETE]      // Rateio do Frete
aImposto[_RATEODESP] := aItemINFO[_GASTOS]     // Rateio de Despesas
aImposto[_BASECALC]  := aItemINFO[_VLRTOTAL]+aItemINFO[_FLETE]+aItemINFO[_GASTOS] // Base de Cálculo

//Tira os descontos se for pelo liquido .Bruno
If Subs(aImposto[5],4,1) == "S"  .And. Len(AIMPOSTO) == 18 .And. ValType(aImposto[18])=="N"
	aImposto[_BASECALC]  -= aImposto[18]
Endif

nI := At( ";",cImpIncid )
nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
While nI > 1
	nE := AScan( aItemINFO[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
	If nE > 0
		aImposto[3] := aImposto[3]+aItemINFO[6,nE,4]
	End
	
	cImpIncid := Stuff( cImpIncid,1,nI,"" )
	nI := At( ";",cImpIncid )
	nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
End
For nE   := 1  To Len(aDespesas)
	If At("ETA",aDespesas[nE][3]) > 0
		aImposto[_BASECALC] += aDespesas[nE][2]
	Endif
Next

aImposto[_BASECALC]	:=	Round(aImposto[_BASECALC],nDecs)
aImposto[_IMPUESTO]  := ROUND(aImposto[_BASECALC] * aImposto[_ALIQUOTA]/100,nDecs)

Return( aImposto )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100EVA    ³ Autor ³ Bruno/Lucas	        ³ Data ³ 20.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo de Valoriza‡ao Aduanera para Paraguay...			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100EVA()
Local aItemINFO	
Local aImposto  
Local aDespesas 	:=	{}
Local cImpIncid 
Local cTec			:=	""
Local nE,nI
Local nDecs			:=	MsDecimais(1)
Local aRet:={}

If !M100CIMP()
	If MafisFound() 
		Return(0)
	Else
		Return(aRet)
    EndIf
EndIf

aItemINFO	:=	ParamIxb[1]
aImposto  	:=	AClone( ParamIxb[2] )
cImpIncid 	:=	aImposto[10]      

If Len(ParamIxb[1]) >= 8
	cTec	:=	ParamIxb[1][8]
Endif
If Len(ParamIxb[1]) >= 9
	aDespesas	:=	ParamIxb[1][9]
Endif

DbSelectArea("SFF")
DbSetOrder(7)
DbSeek(xFilial()+ cTec + "EVA" )
If Found()
	aImposto[_ALIQUOTA]  := SFF->FF_ALIQ
Else
	aImposto[_ALIQUOTA]  := SFB->FB_ALIQ
Endif

//+---------------------------------------------------------------+
//¦ Obter Base de Cálculo e Aliquota dos Impostos.                ¦
//+---------------------------------------------------------Lucas-+
aImposto[_RATEOFRET] := aItemINFO[_FLETE]      // Rateio do Frete
aImposto[_RATEODESP] := aItemINFO[_GASTOS]     // Rateio de Despesas
aImposto[_BASECALC]  := aItemINFO[_VLRTOTAL]+aItemINFO[_FLETE]+aItemINFO[_GASTOS] // Base de Cálculo

//Tira os descontos se for pelo liquido .Bruno
If Subs(aImposto[5],4,1) == "S"  .And. Len(AIMPOSTO) == 18 .And. ValType(aImposto[18])=="N"
	aImposto[_BASECALC]  -= aImposto[18]
Endif

//+---------------------------------------------------------------+
//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
//+---------------------------------------------------------Lucas-+
nI := At( ";",cImpIncid )
nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
While nI > 1
	nE := AScan( aItemINFO[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
	If nE > 0
		aImposto[3] := aImposto[3]+aItemINFO[6,nE,4]
	End
	
	cImpIncid := Stuff( cImpIncid,1,nI,"" )
	nI := At( ";",cImpIncid )
	nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
End
For nE   := 1  To Len(aDespesas)
	If At("EVA",aDespesas[nE][3]) > 0
		aImposto[_BASECALC] += aDespesas[nE][2]
	Endif
Next
//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto                                   ¦
//+---------------------------------------------------------------+
aImposto[_BASECALC]	:=	Round(aImposto[_BASECALC],nDecs)
aImposto[_IMPUESTO]  := ROUND(aImposto[_BASECALC] * aImposto[_ALIQUOTA]/100,nDecs)

Return( aImposto )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100ERC    ³ Autor ³ Bruno/Lucas	        ³ Data ³ 20.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo de Reposicion Consular para Paraguay...				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100ERC()
Local aItemINFO	
Local aImposto  
Local aDespesas 	:=	{}
//Local cImpIncid 	:=	aImposto[10]
Local cTec			:=	""
Local nTotNot   
Local lLast       := .F.
Local nDecs       := MsDecimais(1)
Local aRet:={}

If !M100CIMP()
	If MafisFound() 
		Return(0)
	Else
		Return(aRet)
    EndIf
EndIf
                
aItemINFO	:= ParamIxb[1]
aImposto  	:= AClone( ParamIxb[2] )
nTotNot     := aItemINFO[_VLRTOTAL]

If Len(ParamIxb[1]) >= 8
	cTec	:=	ParamIxb[1][8]
Endif
If Len(ParamIxb[1]) >= 9
	aDespesas	:=	ParamIxb[1][9]
Endif
If Len(ParamIxb[1]) >= 10
	nTotNot   := ParamIxb[1][10]
Endif
If Len(ParamIxb[1]) >= 11
	lLast     := ParamIxb[1][11]
Endif

DbSelectArea("SFF")
DbSetOrder(7)
DbSeek(xFilial()+ cTec+"ERC" )
If Found()
	//+------------------------------------------------------------------------+
	// O valor fixo do SFF esta em dolares, por isso faco a conversao para a
	// moeda 1 segundo a taxa do desembaraco. (o desembaracao esta em moeda 1).
	// Pego o Valor rateado pois o FF_RETENC eh a base para o total da nota.
	//+-Bruno------------------------------------------------------------------+
	If !lLast
		nRateio  := aItemINFO[_VLRTOTAL]/nTotNot
		
		aImposto[_IMPUESTO]  := SW6->W6_TX_US_D * SFF->FF_RETENC * nRateio
		aImposto[_BASECALC]  := SW6->W6_TX_US_D * SFF->FF_RETENC * nRateio
		nAcumERC += aImposto[_BASECALC]
	Else
		aImposto[_BASECALC]  := SW6->W6_TX_US_D * SFF->FF_RETENC -nAcumERC
		aImposto[_IMPUESTO]  := SW6->W6_TX_US_D * SFF->FF_RETENC -nAcumERC
		nAcumERC             := 0
	Endif
	
	aImposto[_ALIQUOTA] := 100
Else
	//+-------------------------------------------------------------------+
	// Obter o valor das despesas com base no SWD cadastrado quando o 
	// imposto for baseado num valor fixo, mas o valor podera possuir 
	// divergencias entre Distritos Regionais, conforme legislacao local.
	//+-Lucas-------------------------------------------------------------+
	DbSelectArea("SWD")
	DbSetOrder(1)
	If DbSeek(xFilial("SWD")+SW6->W6_HAWB+"ERC")
		aImposto[_BASECALC]  := SWD->WD_VALOR_R
		aImposto[_IMPUESTO]  := SWD->WD_VALOR_R
		nAcumERC             := 0
	EndIf	
Endif
aImposto[_BASECALC]	:=	Round(aImposto[_BASECALC],nDecs)
aImposto[_IMPUESTO]	:=	Round(aImposto[_IMPUESTO],nDecs)
Return( aImposto )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100ETI    ³ Autor ³ Bruno/Lucas	        ³ Data ³ 20.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo do imposto Taxa Indigena para Paraguay...			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100ETI()
Local aItemINFO	
Local aImposto  
Local aDespesas 	:=	{}
Local cImpIncid 
Local cTec			:=	""
Local nE,nI
Local nTotNot   
Local lLast       := .F.
Local nDecs       := MsDecimais(1)
Local aRet:={}

If !M100CIMP()
	If MafisFound() 
		Return(0)
	Else
		Return(aRet)
    EndIf
EndIf
                
aItemINFO	:=	ParamIxb[1]
aImposto  	:=	AClone( ParamIxb[2] )
cImpIncid 	:=	aImposto[10]
nTotNot     := aItemINFO[_VLRTOTAL]

If Len(ParamIxb[1]) >= 8
	cTec	:=	ParamIxb[1][8]
Endif
If Len(ParamIxb[1]) >= 9
	aDespesas	:=	ParamIxb[1][9]
Endif
If Len(ParamIxb[1]) >= 10
	nTotNot   := ParamIxb[1][10]
Endif
If Len(ParamIxb[1]) >= 11
	lLast     := ParamIxb[1][11]
Endif

DbSelectArea("SFF")
DbSetOrder(7)
If DbSeek(xFilial()+cTec + "ETI" )
	//O valor fixo do SFF esta em dolares, por isso faco a conversao para a
	//moeda 1 segundo a taxa do desembaraco. (o desembaracao esta em moeda 1).
	//Bruno.
	
	If !lLast
		nRateio  := aItemINFO[_VLRTOTAL]/nTotNot
		//Pego o Valor rateado pois o FF_RETENC eh a base para o total da nota.
		//Bruno
		aImposto[_BASECALC]  := SW6->W6_TX_US_D * SFF->FF_RETENC * nRateio
		nAcumETI += aImposto[_BASECALC]
	Else
		aImposto[_BASECALC]  := (SW6->W6_TX_US_D * SFF->FF_RETENC) - nAcumETI
		nAcumETI             :=  0
	Endif
	aImposto[_ALIQUOTA]  := SFB->FB_ALIQ
	
	nI := At( ";",cImpIncid )
	nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
	While nI > 1
		nE := AScan( aItemINFO[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
		If nE > 0
			aImposto[3] := aImposto[3]+aItemINFO[6,nE,4]
		End
		
		cImpIncid := Stuff( cImpIncid,1,nI,"" )
		nI := At( ";",cImpIncid )
		nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
	End
	
	aImposto[_BASECALC]	:=	Round(aImposto[_BASECALC],nDecs)
	aImposto[_IMPUESTO]  := ROUND(aImposto[_BASECALC] * aImposto[_ALIQUOTA]/100,nDecs)
Else
	aImposto[_ALIQUOTA]  := SFB->FB_ALIQ
	//+-------------------------------------------------------------------+
	// Obter o valor das despesas com base no SWD cadastrado quando o 
	// imposto for baseado num valor fixo, mas o valor podera possuir 
	// divergencias entre Distritos Regionais, conforme legislacao local.
	//+-Lucas-------------------------------------------------------------+
	DbSelectArea("SWD")
	DbSetOrder(1)
	If DbSeek(xFilial("SWD")+SW6->W6_HAWB+"ERC")
		aImposto[_BASECALC]  := SWD->WD_VALOR_R
		aImposto[_IMPUESTO]  := SWD->WD_VALOR_R * aImposto[_ALIQUOTA]
		nAcumERC             := 0
	EndIf	
Endif
aImposto[_BASECALC]	:=	Round(aImposto[_BASECALC],nDecs)
aImposto[_IMPUESTO]	:=	Round(aImposto[_IMPUESTO],nDecs)	
Return( aImposto )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100EIS    ³ Autor ³ Bruno/Lucas	        ³ Data ³ 20.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo do Impuesto Selectivo al Consumo para Paraguay...  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100EIS()
Local aItemINFO	
Local aImposto  
Local aDespesas 	:=	{}
Local cImpIncid 
Local cTec			:=	""
Local nE,nI
Local nDecs			:=	MsDecimais(1)
Local aRet:={}

If !M100CIMP()
	If MafisFound() 
		Return(0)
	Else
		Return(aRet)
    EndIf
EndIf
                
aItemINFO	:=	ParamIxb[1]
aImposto  	:=	AClone( ParamIxb[2] )
cImpIncid 	:=	aImposto[10]

If Len(ParamIxb[1]) >= 8
	cTec	:=	ParamIxb[1][8]
Endif
If Len(ParamIxb[1]) >= 9
	aDespesas	:=	ParamIxb[1][9]
Endif

aImposto[_ALIQUOTA]  := SFB->FB_ALIQ

//+---------------------------------------------------------------+
//¦ Obter Base de Cálculo e Aliquota dos Impostos.                ¦
//+---------------------------------------------------------Lucas-+
aImposto[_RATEOFRET] := aItemINFO[_FLETE]      // Rateio do Frete
aImposto[_RATEODESP] := aItemINFO[_GASTOS]     // Rateio de Despesas
aImposto[_BASECALC]  := aItemINFO[_VLRTOTAL]+aItemINFO[_FLETE]+aItemINFO[_GASTOS] // Base de Cálculo

//Tira os descontos se for pelo liquido .Bruno
If Subs(aImposto[5],4,1) == "S"  .And. Len(AIMPOSTO) == 18 .And. ValType(aImposto[18])=="N"
	aImposto[_BASECALC]  -= aImposto[18]
Endif

//+---------------------------------------------------------------+
//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
//+---------------------------------------------------------Lucas-+
nI := At( ";",cImpIncid )
nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
While nI > 1
	nE := AScan( aItemINFO[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
	If nE > 0
		aImposto[3] := aImposto[3]+aItemINFO[6,nE,4]
	End
	
	cImpIncid := Stuff( cImpIncid,1,nI,"" )
	nI := At( ";",cImpIncid )
	nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
End
For nE   := 1  To Len(aDespesas)
	If At("EIS",aDespesas[nE][3]) > 0
		aImposto[_BASECALC] += aDespesas[nE][2]
	Endif
Next
//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto                                   ¦
//+---------------------------------------------------------------+
aImposto[_BASECALC]	:=	Round(aImposto[_BASECALC],nDecs)
aImposto[_IMPUESTO]  := ROUND(aImposto[_BASECALC] * aImposto[_ALIQUOTA]/100,nDecs)

Return( aImposto )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100EAR    ³ Autor ³ Bruno/Lucas	        ³ Data ³ 20.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo do Anticipo a la Renta...								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100EAR()
Local aItemINFO	
Local aImposto  
Local aDespesas 	:=	{}
Local cImpIncid
Local cTec			:=	""
Local nE,nI
Local nDecs			:=	MsDecimais(1)
Local aRet:={}              

If !M100CIMP()
	If MafisFound() 
		Return(0)
	Else
		Return(aRet)
    EndIf
EndIf
      
aItemINFO	:=	ParamIxb[1]
aImposto  	:=	AClone( ParamIxb[2] )
cImpIncid 	:=	aImposto[10]

If Len(ParamIxb[1]) >= 8
	cTec	:=	ParamIxb[1][8]
Endif
If Len(ParamIxb[1]) >= 9
	aDespesas	:=	ParamIxb[1][9]
Endif

aImposto[_ALIQUOTA]  := SFB->FB_ALIQ

//+---------------------------------------------------------------+
//¦ Obter Base de Cálculo e Aliquota dos Impostos.                ¦
//+---------------------------------------------------------Lucas-+
aImposto[_RATEOFRET] := aItemINFO[_FLETE]      // Rateio do Frete
aImposto[_RATEODESP] := aItemINFO[_GASTOS]     // Rateio de Despesas
aImposto[_BASECALC]  := aItemINFO[_VLRTOTAL]+aItemINFO[_FLETE]+aItemINFO[_GASTOS] // Base de Cálculo

//Tira os descontos se for pelo liquido .Bruno
If Subs(aImposto[5],4,1) == "S"  .And. Len(AIMPOSTO) == 18 .And. ValType(aImposto[18])=="N"
	aImposto[_BASECALC]  -= aImposto[18]
Endif

//+---------------------------------------------------------------+
//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
//+---------------------------------------------------------Lucas-+
nI := At( ";",cImpIncid )
nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
While nI > 1
	nE := AScan( aItemINFO[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
	If nE > 0
		aImposto[3] := aImposto[3]+aItemINFO[6,nE,4]
	End
	
	cImpIncid := Stuff( cImpIncid,1,nI,"" )
	nI := At( ";",cImpIncid )
	nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
End
For nE   := 1  To Len(aDespesas)
	If At("EAR",aDespesas[nE][3]) > 0
		aImposto[_BASECALC] += aDespesas[nE][2]
	Endif
Next
//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto                                   ¦
//+---------------------------------------------------------------+
aImposto[_BASECALC]	:=	Round(aImposto[_BASECALC],nDecs)
aImposto[_IMPUESTO]  := ROUND(aImposto[_BASECALC] * aImposto[_ALIQUOTA]/100,nDecs)

Return( aImposto )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100ECC    ³ Autor ³ Bruno/Lucas	        ³ Data ³ 20.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo do Arancel Consular Co-Visado para Paraguay...	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100ECC()
Local aItemINFO	
Local aImposto  
Local aDespesas 	:=	{}
Local	cImpIncid
Local cTec			:=	""
Local nE,nI
Local nTotNot    
Local lLast       := .F.
Local nDecs       := MsDecimais(1)
Local aRet:={}

If !M100CIMP()
	If MafisFound() 
		Return(0)
	Else
		Return(aRet)
    EndIf
EndIf

aItemINFO	:=	ParamIxb[1]
aImposto  	:=	AClone( ParamIxb[2] )
cImpIncid 	:=	aImposto[10]
nTotNot     :=  aItemINFO[_VLRTOTAL]

If Len(ParamIxb[1]) >= 8
	cTec	:=	ParamIxb[1][8]
Endif
If Len(ParamIxb[1]) >= 9
	aDespesas	:=	ParamIxb[1][9]
Endif
If Len(ParamIxb[1]) >= 10
	nTotNot   := ParamIxb[1][10]
Endif
If Len(ParamIxb[1]) >= 11
	lLast     := ParamIxb[1][11]
Endif

DbSelectArea("SFF")
DbSetOrder(7)
If DbSeek(xFilial()+cTec + "ECC" )
	//O valor fixo do SFF esta em dolares, por isso faco a conversao para a
	//moeda 1 segundo a taxa do desembaraco. (o desembaracao esta em moeda 1).
	//Bruno.
	If !lLast
		nRateio  := aItemINFO[_VLRTOTAL]/nTotNot
		//Pego o Valor rateado pois o FF_RETENC eh a base para o total da nota.
		//Bruno
		aImposto[_BASECALC]  := SW6->W6_TX_US_D * SFF->FF_RETENC * nRateio
		nAcumECC += aImposto[_BASECALC]
	Else
		aImposto[_BASECALC]  := SW6->W6_TX_US_D * SFF->FF_RETENC-nAcumECC
		nAcumECC             := 0
	Endif
	
	aImposto[_ALIQUOTA]  := SFB->FB_ALIQ
	//---------------------------
	
	//+---------------------------------------------------------------+
	//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
	//+---------------------------------------------------------Lucas-+
	nI := At( ";",cImpIncid )
	nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
	While nI > 1
		nE := AScan( aItemINFO[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
		If nE > 0
			aImposto[3] := aImposto[3]+aItemINFO[6,nE,4]
		End
		
		cImpIncid := Stuff( cImpIncid,1,nI,"" )
		nI := At( ";",cImpIncid )
		nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
	End
	//+---------------------------------------------------------------+
	//¦ Efetua o Cálculo do Imposto                                   ¦
	//+---------------------------------------------------------------+
	aImposto[_BASECALC]	:=	Round(aImposto[_BASECALC],nDecs)
	aImposto[_IMPUESTO]  := ROUND(aImposto[_BASECALC] * aImposto[_ALIQUOTA]/100,nDecs)
Endif
Return( aImposto )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100EAQ    ³ Autor ³ Bruno/Lucas	        ³ Data ³ 02.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo do Impuesto Analisis Quimica para Paraguay...	     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100EAQ()
Local aItemINFO	
Local aImposto  
Local aDespesas 	:=	{}
Local cImpIncid 
Local cTec			:=	""
Local nE,nI
Local nTotNot   
Local lLast       := .F.
Local nDecs       := MsDecimais(1)
Local nValorRef   := 0
Local nQtdePO     := 0
Local nQtdeBase   := 0
Local aRet:={}
     
If !M100CIMP()
	If MafisFound() 
		Return(0)
	Else
		Return(aRet)
    EndIf
EndIf
                
aItemINFO	:=	ParamIxb[1]
aImposto  	:=	AClone( ParamIxb[2] )
cImpIncid 	:=	aImposto[10]
nTotNot     := aItemINFO[_VLRTOTAL]

If Len(ParamIxb[1]) >= 8
	cTec	:=	ParamIxb[1][8]
Endif
If Len(ParamIxb[1]) >= 9
	aDespesas	:=	ParamIxb[1][9]
Endif
If Len(ParamIxb[1]) >= 10
	nTotNot   := ParamIxb[1][10]
Endif
If Len(ParamIxb[1]) >= 11
	lLast     := ParamIxb[1][11]
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Este imposto nao ‚ calculado atraves de aliquota e sim    ³
//³ por um valor minimo de referencia                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SFF")
DbSetOrder(7)
If DbSeek(xFilial("SFF") + cTec + "EAQ" )
	nValorRef := SFF->FF_IMPORTE
EndIf

//+---------------------------------------------------------------+
//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
//+---------------------------------------------------------Lucas-+
nI := At( ";",cImpIncid )
nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
While nI > 1
	nE := AScan( aItemINFO[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
	If nE > 0
		aImposto[3] := aImposto[3]+aItemINFO[6,nE,4]
	End
	
	cImpIncid := Stuff( cImpIncid,1,nI,"" )
	nI := At( ";",cImpIncid )
	nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
End
//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto                                   ¦
//+---------------------------------------------------------------+
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O imposto e Calculado a cada Caixa.							  ³
//³ O imposto sera Qtd de Caixa x Valor de Referencia			  ³
//³ * Onde Origem for USA      = Gs 2750  					 	  ³
//³ *                 MercoSul = Gs  800 	  						  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aImposto[_BASECALC] := nValorRef
aImposto[_IMPUESTO] := aItemINFO[1] * nValorRef
Return( aImposto )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100EMT    ³ Autor ³ Bruno/Lucas	        ³ Data ³ 20.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo do Impuesto Meti para Paraguay... 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100EMT()
Local aItemINFO	
Local aImposto  
Local aDespesas 	:=	{}
Local cImpIncid 
Local cTec			:=	""
Local nE,nI
Local nDecs			:=	MsDecimais(1)
Local aRet:={}

If !M100CIMP()
	If MafisFound() 
		Return(0)
	Else
		Return(aRet)
    EndIf
EndIf

aItemINFO	:=	ParamIxb[1]
aImposto  	:=	AClone( ParamIxb[2] )
cImpIncid 	:=	aImposto[10]

If Len(ParamIxb[1]) >= 8
	cTec	:=	ParamIxb[1][8]
Endif
If Len(ParamIxb[1]) >= 9
	aDespesas	:=	ParamIxb[1][9]
Endif

aImposto[_ALIQUOTA]  := SFB->FB_ALIQ

//+---------------------------------------------------------------+
//¦ Obter Base de Cálculo e Aliquota dos Impostos.                ¦
//+---------------------------------------------------------Lucas-+
aImposto[_RATEOFRET] := aItemINFO[_FLETE]      // Rateio do Frete
aImposto[_RATEODESP] := aItemINFO[_GASTOS]     // Rateio de Despesas
aImposto[_BASECALC]  := aItemINFO[_VLRTOTAL]+aItemINFO[_FLETE]+aItemINFO[_GASTOS] // Base de Cálculo

//Tira os descontos se for pelo liquido .Bruno
If Subs(aImposto[5],4,1) == "S"  .And. Len(AIMPOSTO) == 18 .And. ValType(aImposto[18])=="N"
	aImposto[_BASECALC]  -= aImposto[18]
Endif

//+---------------------------------------------------------------+
//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
//+---------------------------------------------------------Lucas-+
nI := At( ";",cImpIncid )
nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
While nI > 1
	nE := AScan( aItemINFO[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
	If nE > 0
		aImposto[3] := aImposto[3]+aItemINFO[6,nE,4]
	End
	
	cImpIncid := Stuff( cImpIncid,1,nI,"" )
	nI := At( ";",cImpIncid )
	nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
End
For nE   := 1  To Len(aDespesas)
	If At("EIS",aDespesas[nE][3]) > 0
		aImposto[_BASECALC] += aDespesas[nE][2]
	Endif
Next
//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto                                   ¦
//+---------------------------------------------------------------+
aImposto[_BASECALC]	:=	Round(aImposto[_BASECALC],nDecs)
aImposto[_IMPUESTO]  := ROUND(aImposto[_BASECALC] * aImposto[_ALIQUOTA]/100,nDecs)

Return( aImposto )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100IVT    ³ Autor ³ Bruno/Lucas	        ³ Data ³ 10.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo do Impuesto IVA Turismo para Paraguay...  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100IVT()
Local aItemINFO	
Local aImposto  
Local aDespesas 	:=	{}
Local cImpIncid 
Local cTec			:=	""
Local nE,nI
Local nDecs			:=	MsDecimais(1)
Local aRet:={}

If !M100CIMP()
	If MafisFound() 
		Return(0)
	Else
		Return(aRet)
    EndIf
EndIf

aItemINFO		:=	ParamIxb[1]
aImposto  	:=	AClone( ParamIxb[2] )
cImpIncid 	:=	aImposto[10]      

If Len(ParamIxb[1]) >= 8
	cTec	:=	ParamIxb[1][8]
Endif
If Len(ParamIxb[1]) >= 9
	aDespesas	:=	ParamIxb[1][9]
Endif

aImposto[_ALIQUOTA]  := SFB->FB_ALIQ

//+---------------------------------------------------------------+
//¦ Obter Base de Cálculo e Aliquota dos Impostos.                ¦
//+---------------------------------------------------------Lucas-+
aImposto[_RATEOFRET] := aItemINFO[_FLETE]      // Rateio do Frete
aImposto[_RATEODESP] := aItemINFO[_GASTOS]     // Rateio de Despesas
aImposto[_BASECALC]  := aItemINFO[_VLRTOTAL]+aItemINFO[_FLETE]+aItemINFO[_GASTOS] // Base de Cálculo

//Tira os descontos se for pelo liquido .Bruno
If Subs(aImposto[5],4,1) == "S"  .And. Len(AIMPOSTO) == 18 .And. ValType(aImposto[18])=="N"
	aImposto[_BASECALC] -= aImposto[18]
Endif

//+---------------------------------------------------------------+
//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
//+---------------------------------------------------------Lucas-+
nI := At( ";",cImpIncid )
nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
While nI > 1
	nE := AScan( aItemINFO[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
	If nE > 0
		aImposto[3] := aImposto[3]+aItemINFO[6,nE,4]
	End
	
	cImpIncid := Stuff( cImpIncid,1,nI,"" )
	nI := At( ";",cImpIncid )
	nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
End
For nE   := 1  To Len(aDespesas)
	If At("EIS",aDespesas[nE][3]) > 0
		aImposto[_BASECALC] += aDespesas[nE][2]
	Endif
Next
//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto                                   ¦
//+---------------------------------------------------------------+
aImposto[_BASECALC]	:=	Round(aImposto[_BASECALC],nDecs)
aImposto[_IMPUESTO]  := ROUND(aImposto[_BASECALC] * aImposto[_ALIQUOTA]/100,nDecs)

Return( aImposto )


/*/
*****************************************************************************
**Impostos exclusivos do Chile                                             **
*****************************************************************************

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100EIVCH  ³ Autor ³ Bruno			        ³ Data ³ 20.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo do IVA para Importacion para o Chile...            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100EIVCH()
Local aItemINFO	:=	ParamIxb[1]
Local aImposto  	:=	AClone( ParamIxb[2] )
Local aDespesas 	:=	{}
Local	cImpIncid 	:=	aImposto[10]
Local cTec			:=	""
Local nE,nI

If Len(ParamIxb[1]) >= 8
	cTec	:=	ParamIxb[1][8]
Endif
If Len(ParamIxb[1]) >= 9
	aDespesas	:=	ParamIxb[1][9]
Endif

DbSelectArea("SFF")
DbSetOrder(7)
DbSeek(xFilial("SFF") + cTec + "EIV" )
If Found()
	aImposto[_ALIQUOTA]  := SFF->FF_ALIQ
Else
	aImposto[_ALIQUOTA]  := SFB->FB_ALIQ
Endif

aImposto[_RATEOFRET] := aItemINFO[_FLETE]      // Rateio do Frete
aImposto[_RATEODESP] := aItemINFO[_GASTOS]     // Rateio de Despesas
aImposto[_BASECALC]  := aItemINFO[_VLRTOTAL]+aItemINFO[_FLETE]+aItemINFO[_GASTOS] // Base de Cálculo

//Tira os descontos se for pelo liquido .Bruno
If Subs(aImposto[5],4,1) == "S"
	aImposto[_BASECALC]	-=	aImposto[18]  // aImposto[18] = Desconto
Endif

//+---------------------------------------------------------------+
//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
//+---------------------------------------------------------Lucas-+
nI := At( ";",cImpIncid )
nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
While nI > 1
	nE := AScan( aItemINFO[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
	If nE > 0
		aImposto[3] := aImposto[3]+aItemINFO[6,nE,4]
	End
	
	cImpIncid := Stuff( cImpIncid,1,nI,"" )
	nI := At( ";",cImpIncid )
	nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
End
For nE	:=	1	To Len(aDespesas)
	If At("EIV",aDespesas[nE][3]) > 0
		aImposto[_BASECALC] += aDespesas[nE][2]
	Endif
Next
//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto                                   ¦
//+---------------------------------------------------------------+
aImposto[_IMPUESTO]  := ROUND(aImposto[_BASECALC] * aImposto[_ALIQUOTA]/100,2)

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto sobre Frete                       ¦
//+---------------------------------------------------------------+
//aImposto[_IMPFLETE]  := ROUND(aImposto[_RATEOFRET] * aImposto[_ALIQUOTA]/100,2)

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto sobre Despesas                    ¦
//+---------------------------------------------------------------+
//aImposto[_IMPGASTOS] := ROUND(aImposto[_RATEODESP] * aImposto[_ALIQUOTA]/100,2)
Return( aImposto )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100EDICH  ³ Autor ³ Lucas			        ³ Data ³ 01.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo dos Direitos de Importacao - EDI para o Chile...   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100EDICH()
Local aItemINFO	:=	ParamIxb[1]
Local aImposto  	:=	AClone( ParamIxb[2] )
Local aDespesas 	:=	{}
Local	cImpIncid 	:=	aImposto[10]
Local cTec			:=	""
Local nE,nI

If Len(ParamIxb[1]) >= 8
	cTec	:=	ParamIxb[1][8]
Endif
If Len(ParamIxb[1]) >= 9
	aDespesas	:=	ParamIxb[1][9]
Endif

DbSelectArea("SFF")
DbSetOrder(7)
DbSeek(xFilial("SFF") + cTec + "EDI" )
If Found()
	aImposto[_ALIQUOTA]  := SFF->FF_ALIQ
Else
	aImposto[_ALIQUOTA]  := SFB->FB_ALIQ
Endif

//+---------------------------------------------------------------+
//¦ Obter Base de Cálculo e Aliquota dos Impostos.                ¦
//+---------------------------------------------------------Lucas-+
aImposto[_RATEOFRET] := aItemINFO[_FLETE]      // Rateio do Frete
aImposto[_RATEODESP] := aItemINFO[_GASTOS]     // Rateio de Despesas
aImposto[_BASECALC]  := aItemINFO[_VLRTOTAL]+aItemINFO[_FLETE]+aItemINFO[_GASTOS] // Base de Cálculo

//Tira os descontos se for pelo liquido .Bruno
If Subs(aImposto[5],4,1) == "S"  
	aImposto[_BASECALC]	-=	aImposto[18]  // aImposto[18] = Desconto
Endif

//+---------------------------------------------------------------+
//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
//+---------------------------------------------------------Lucas-+
nI := At( ";",cImpIncid )
nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
While nI > 1
	nE := AScan( aItemINFO[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
	If nE > 0
		aImposto[3] := aImposto[3]+aItemINFO[6,nE,4]
	End
	
	cImpIncid := Stuff( cImpIncid,1,nI,"" )
	nI := At( ";",cImpIncid )
	nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
End
For nE	:=	1	To Len(aDespesas)
	If At("EDI",aDespesas[nE][3]) > 0
		aImposto[_BASECALC] += aDespesas[nE][2]
	EndIf
Next nE

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto                                   ¦
//+---------------------------------------------------------------+
aImposto[_IMPUESTO]  := ROUND(aImposto[_BASECALC] * aImposto[_ALIQUOTA]/100,2)

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto sobre Frete                       ¦
//+---------------------------------------------------------------+
//aImposto[_IMPFLETE]  := ROUND(aImposto[_RATEOFRET] * aImposto[_ALIQUOTA]/100,2)

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto sobre Despesas                    ¦
//+---------------------------------------------------------------+
//aImposto[_IMPGASTOS] := ROUND(aImposto[_RATEODESP] * aImposto[_ALIQUOTA]/100,2)

Return( aImposto )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100209    ³ Autor ³ Lucas			        ³ Data ³ 01.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo dos Taxa... (209)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100209()
Local aItemINFO	
Local aImposto  
Local aDespesas 	:=	{}
Local	cImpIncid 
Local cTec			:=	""
Local nE,nI
Local aRet:={}

If !M100CIMP()
	If MafisFound() 
		Return(0)
	Else
		Return(aRet)
    EndIf
EndIf
                  
aItemINFO	:=	ParamIxb[1]
aImposto  	:=	AClone( ParamIxb[2] )
cImpIncid 	:=	aImposto[10]

If Len(ParamIxb[1]) >= 8
	cTec	:=	ParamIxb[1][8]
Endif
If Len(ParamIxb[1]) >= 9
	aDespesas	:=	ParamIxb[1][9]
Endif

//+---------------------------------------------------------------+
//¦ Obter Base de Cálculo e Aliquota dos Impostos.                ¦
//+---------------------------------------------------------Lucas-+
aImposto[_RATEOFRET] := aItemINFO[_FLETE]      // Rateio do Frete
aImposto[_RATEODESP] := aItemINFO[_GASTOS]     // Rateio de Despesas
aImposto[_BASECALC]  := aItemINFO[_VLRTOTAL]+aItemINFO[_FLETE]+aItemINFO[_GASTOS] // Base de Cálculo

//Tira os descontos se for pelo liquido .Bruno
If Subs(aImposto[5],4,1) == "S"  
	aImposto[_BASECALC] -= aImposto[18]  // aImposto[18] = Desconto
Endif

//+---------------------------------------------------------------+
//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
//+---------------------------------------------------------Lucas-+
nI := At( ";",cImpIncid )
nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
While nI > 1
	nE := AScan( aItemINFO[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
	If nE > 0
		aImposto[3] := aImposto[3]+aItemINFO[6,nE,4]
	End
	
	cImpIncid := Stuff( cImpIncid,1,nI,"" )
	nI := At( ";",cImpIncid )
	nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
End
For nE	:=	1	To Len(aDespesas)
	If At("ETE",aDespesas[nE][3]) > 0
		aImposto[_BASECALC] += aDespesas[nE][2]
	Endif
Next nE

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto                                   ¦
//+---------------------------------------------------------------+
aImposto[_IMPUESTO]  := 0.00

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto sobre Frete                       ¦
//+---------------------------------------------------------------+
//aImposto[_IMPFLETE]  := ROUND(aImposto[_RATEOFRET] * aImposto[_ALIQUOTA]/100,2)

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto sobre Despesas                    ¦
//+---------------------------------------------------------------+
// aImposto[_IMPGASTOS] := ROUND(aImposto[_RATEODESP] * aImposto[_ALIQUOTA]/100,2)

Return( aImposto )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M100IVG    ³ Autor ³ Sergio S. Fuzinaka  ³ Data ³ 21.10.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ IVA														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100IVG()

Local aArea     := GetArea()
Local aItemINFO 
Local aImposto  
Local cImpIncid 
Local nAliquota := 0
Local nDecs		:= MsDecimais(1)
Local nI, nE
Local aRet:={}

If !M100CIMP()
	If MafisFound() 
		Return(0)
	Else
		Return(aRet)
    EndIf
EndIf           

aItemINFO := ParamIxb[1]
aImposto  := ParamIxb[2]
cImpIncid := aImposto[10]

dbSelectArea("SFH")
dbSetOrder(1)
If !dbSeek(xFilial() + SWD->WD_FORN + SWD->WD_LOJA + "IVG")
	nAliquota := SFB->FB_ALIQ
Else
	nAliquota := SFH->FH_ALIQ
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua o Calculo do Imposto                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aImposto[_ALIQUOTA] := nAliquota
aImposto[_BASECALC] := aItemINFO[_VLRTOTAL]
aImposto[_IMPUESTO] := Round(aImposto[_BASECALC] * (aImposto[_ALIQUOTA]/100), nDecs)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua os Descontos                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Subs(aImposto[5],4,1) == "S"  .And. Len(aImposto) == 18 .And. ValType(aImposto[18])=="N"
	aImposto[_BASECALC]	-=	aImposto[18]
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imposto Incidente                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nI := At(";", cImpIncid)
nI := If(nI==0, Len(AllTrim(cImpIncid)) + 1, nI)
While nI > 1
	nE := AScan(aItemINFO[6], {|x| x[1] == Left(cImpIncid,nI-1)})
	If nE > 0
		aImposto[_BASECALC] += aItemINFO[6,nE,4]
	Endif
	cImpIncid := Stuff(cImpIncid, 1, nI, "")
	nI        := At(";", cImpIncid)
	nI        := If(nI == 0, Len(AllTrim(cImpIncid)) + 1, nI)
Enddo
RestArea(aArea)

Return(aImposto)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M100IBG    ³ Autor ³ Sergio S. Fuzinaka  ³ Data ³ 21.10.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Percepcion de Ingressos Brutos							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100IBG()

Local aArea     := GetArea()
Local aItemINFO 
Local aImposto  
Local cImpIncid 
Local nAliquota := 0
Local nDecs		:= MsDecimais(1)
Local nI, nE
Local aRet:={}

If !M100CIMP()
	If MafisFound() 
		Return(0)
	Else
		Return(aRet)
    EndIf
EndIf
                
aItemINFO := ParamIxb[1]
aImposto  := ParamIxb[2]
cImpIncid := aImposto[10]

dbSelectArea("SFH")
dbSetOrder(1)
If !dbSeek(xFilial() + SWD->WD_FORN + SWD->WD_LOJA + "IBG")
	nAliquota := 0
Else
	nAliquota := SFH->FH_ALIQ
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua o Calculo do Imposto                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nAliquota == 0
	aImposto[_ALIQUOTA] := 0
	aImposto[_BASECALC] := 0
	aImposto[_IMPUESTO] := 0
Else
	aImposto[_ALIQUOTA] := nAliquota
	aImposto[_BASECALC] := aItemINFO[_VLRTOTAL]
	aImposto[_IMPUESTO] := Round(aImposto[_BASECALC] * (aImposto[_ALIQUOTA]/100), nDecs)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua os Descontos                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Subs(aImposto[5],4,1) == "S"  .And. Len(aImposto) == 18 .And. ValType(aImposto[18])=="N"
		aImposto[_BASECALC]	-=	aImposto[18]
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imposto Incidente                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nI := At(";",cImpIncid)
	nI := If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
	While nI > 1
		nE := AScan(aItemINFO[6], {|x| x[1] == Left(cImpIncid,nI-1)})
		If nE > 0
			aImposto[_BASECALC] += aItemINFO[6,nE,4]
		Endif
		cImpIncid := Stuff(cImpIncid, 1, nI, "")
		nI        := At(";", cImpIncid)
		nI        := If(nI == 0, Len(AllTrim(cImpIncid))+1, nI)
	Enddo
EndIf
RestArea(aArea)

Return(aImposto)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M100PVG    ³ Autor ³ Sergio S. Fuzinaka  ³ Data ³ 21.10.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Percepcion de IVA                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC e SIGACOM                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100PVG()

Local aArea     := GetArea()
Local aItemINFO 
Local aImposto  
Local cImpIncid 
Local nAliquota := 0
Local nDecs		:= MsDecimais(1)
Local nI, nE
Local aRet:={}

If !M100CIMP()
	If MafisFound() 
		Return(0)
	Else
		Return(aRet)
    EndIf
EndIf
                
aItemINFO := ParamIxb[1]
aImposto  := ParamIxb[2]
cImpIncid := aImposto[10]

dbSelectArea( "SFH" )
dbSetOrder( 1 )
If !dbSeek( xFilial() + SWD->WD_FORN + SWD->WD_LOJA + "PVG" )
	nAliquota := 0
Else
	nAliquota := SFH->FH_ALIQ
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua o Calculo do Imposto                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nAliquota == 0
	aImposto[_ALIQUOTA] := 0
	aImposto[_BASECALC] := 0
	aImposto[_IMPUESTO] := 0
Else
	aImposto[_ALIQUOTA] := nAliquota
	aImposto[_BASECALC] := aItemINFO[_VLRTOTAL]
	aImposto[_IMPUESTO] := Round(aImposto[_BASECALC] * (aImposto[_ALIQUOTA]/100), nDecs)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua os Descontos                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Subs(aImposto[5],4,1) == "S"  .And. Len(aImposto) == 18 .And. ValType(aImposto[18])=="N"
		aImposto[_BASECALC]	-= aImposto[18]
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imposto Incidente                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nI := At( ";",cImpIncid )
	nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
	While nI > 1
		nE := AScan(aItemINFO[6], {|x| x[1] == Left(cImpIncid,nI-1)})
		If nE > 0
			aImposto[_BASECALC] += aItemINFO[6,nE,4]
		Endif
		cImpIncid := Stuff(cImpIncid, 1, nI, "")
		nI        := At(";", cImpIncid)
		nI        := If(nI == 0, Len(AllTrim(cImpIncid))+1, nI)
	Enddo
Endif
RestArea(aArea)

Return(aImposto)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion     ³ M100EIB    ³ Autor ³ Alfio		          ³ Data ³ 11.07.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³ Calculo de Ingresos Brutos para Despacho 	                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100EIB()
Local aItemINFO	
Local aImposto  
Local aDespesas 	:=	{}
Local cImpIncid 
Local cTec			:=	""
Local nE,nI
Local nDecs			:=	MsDecimais(1)
Local aRet:={}

If !M100CIMP()
	If MafisFound() 
		Return(0)
	Else
		Return(aRet)
    EndIf
EndIf
      
aItemINFO	:=	ParamIxb[1]
aImposto  	:=	AClone( ParamIxb[2] )
cImpIncid 	:=	aImposto[10]

If Len(ParamIxb[1]) >= 8
	cTec	:=	ParamIxb[1][8]
Endif
If Len(ParamIxb[1]) >= 9
	aDespesas	:=	ParamIxb[1][9]
Endif

DbSelectArea("SFF")
DbSetOrder(7)
DbSeek(xFilial()+ cTec + "EIB" )
If Found()
	aImposto[_ALIQUOTA]  := SFF->FF_ALIQ
Else
	aImposto[_ALIQUOTA]  := SFB->FB_ALIQ
Endif

aImposto[_RATEOFRET] := aItemINFO[_FLETE]      // Rateio do Frete
aImposto[_RATEODESP] := aItemINFO[_GASTOS]     // Rateio de Despesas
aImposto[_BASECALC]  := aItemINFO[_VLRTOTAL]+aItemINFO[_FLETE]+aItemINFO[_GASTOS] // Base de Cálculo

//Tira os descontos se for pelo liquido .Bruno
If Subs(aImposto[5],4,1) == "S"  .And. Len(AIMPOSTO) == 18 .And. ValType(aImposto[18])=="N"
	aImposto[_BASECALC]	-=	aImposto[18]
Endif

nI := At( ";",cImpIncid )
nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
While nI > 1
	nE := AScan( aItemINFO[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
	If nE > 0
		aImposto[3] := aImposto[3]+aItemINFO[6,nE,4]
	End

	cImpIncid := Stuff( cImpIncid,1,nI,"" )
	nI := At( ";",cImpIncid )
	nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
End

For nE	:=	1	To Len(aDespesas)
	If At("EIB",aDespesas[nE][3]) > 0
		aImposto[_BASECALC] += aDespesas[nE][2]
	Endif
Next nE

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto                                   ¦
//+---------------------------------------------------------------+
aImposto[_BASECALC]	:=	Round(aImposto[_BASECALC],nDecs)
aImposto[_IMPUESTO]  := ROUND(aImposto[_BASECALC] * aImposto[_ALIQUOTA]/100,nDecs)

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto sobre Frete                       ¦
//+---------------------------------------------------------------+
//   aImposto[_IMPFLETE]  := ROUND(aImposto[_RATEOFRET] * aImposto[_ALIQUOTA]/100,2)

//+---------------------------------------------------------------+
//¦ Efetua o Cálculo do Imposto sobre Despesas                    ¦
//+---------------------------------------------------------------+
// aImposto[_IMPGASTOS] := ROUND(aImposto[_RATEODESP] * aImposto[_ALIQUOTA]/100,2)

Return( aImposto )



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion     ³ M100CIMP      ³ Autor ³ Paulo Augusto    ³ Data ³ 03.09.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³ Verifica a rotima para calculo do Imposto	                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100CIMP()
Local lCalcImp:= .F.
If UPPER(Subs(FunName(),1,3))== "EIC"
	lCalcImp:= .T.
EndIf

Return(lCalcImp)
