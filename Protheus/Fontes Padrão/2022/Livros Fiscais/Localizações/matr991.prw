#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#include "MATR991.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATR991   ºAutor  ³Ivan Haponczuk      º Data ³  14/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Certificado de IVA Bimestral y Anual                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5 - Colombia                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador º Data   º BOPS º  Motivo da Alteracao                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÃÍÍÍÍÍÍÍÍÃÍÍÍÍÍÍÅÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºLaura Medinaº15/03/13ºTFVWHCº Se agregaron y modificaron etiquetas.    º±±
±±ºLaura Medinaº26/03/13ºTFVWHCº Se agrego leyenda al pie del certificado.º±±
±±³Alf. Medranoº26/09/16ºTWGPRDº En Func PrintReport se agrega validacion º±±
±±³            º        º      º si A2_PFISICA es vacio toma A2_CGC para  º±±
±±³            º        º      º el NIT retenido                          º±±
±±³Alf. Medranoº08/11/16ºTWIPKTºMERGE 12.1.07 vs Main  COL                º±±
±±³LuisEnríquezº07/11/18ºDMINA-º Se agrega llamado a función FLgEmp() paraº±±
±±³            º        º4393  º impresión de logotipo de empresa (COL)   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */

Function Matr991(alDados)

	Private opReport	:= NIL
	Private apDados		:= aClone(alDados)

	If TRepInUse()	//verifica se relatorios personalizaveis esta disponivel
		opReport:=GeraReport()
		opReport:PrintDialog()
	Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GeraReportºAutor  ³Ivan Haponczuk      º Data ³  14/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria o objeto do relatorio e o configura.                  º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function GeraReport()

	Local olReport	:= NIL

	olReport:= TReport():New("Matr991",STR0001,,{|opReport|PrintReport(opReport)},"")
	olReport:lHeaderVisible		:= .F.	// Não imprime cabeçalho do protheus
	olReport:lFooterVisible		:= .F.	// Não imprime rodapé do protheus
	olReport:lParamPage			:= .F.	// Não imprime pagina de parametros
	olReport:oPage:nPaperSize	:= 9	// Impressão em papel A4
	olReport:nFontBody			:= 10 // Define o tamanho da fonte a ser impressa no relatorio

Return olReport

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrintReportºAutor  ³Ivan Haponczuk     º Data ³  14/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime o relatorio a partir do array.                     º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function PrintReport()

 	Local nlI       := 0
	Local nlX       := 0
	Local nlLin     := 0
	Local clFornec  := 0
	Local nlBase    := 0
	Local nlAlq     := 0
	Local nlValRet  := 0
	Local nlTotBase := 0
	Local nlTotRet  := 0 
	Local nlTotIVA  := 0
	Local alItens   := {}
	Local nSinal	:= 1  
	Local nlValIVA  := 0
    Local olFont 	:= TFont():New("Courier New",,-10,,)

	For nlX:=1 To Len(apDados)

		alItens := {} 

		opReport:SayBitmap(opReport:Row()+50,opReport:Col()+1050,FLgEmp(),330,170)

		opReport:Box(opReport:Row()+0250,opReport:Col()+0350,opReport:Row()+0250,opReport:Col()+2125)
	   	opReport:SkipLine(12)
		opReport:PrintText("",0100,0800)
		opReport:PrintText(STR0001,0290,0080) //CERTIFICADO DE RETENCION POR IVA 

		opReport:PrintText(STR0019,0350,0080) //RETENEDOR
		opReport:PrintText(STR0020+" "+dtoc(ddatabase),0290,1550) //FECHA DE EXPEDICION 

		opReport:PrintText(SM0->M0_NOMECOM,0390,0080)

		opReport:PrintText(AllTrim(SM0->M0_ENDENT)+", "+SM0->M0_CIDENT,0430,0080)

		opReport:PrintText(STR0006+" "+SM0->M0_CGC,0470,0080) //NIT:

		opReport:PrintText(STR0002+" "+DTOC(MV_PAR02)+" "+STR0003+" "+DTOC(MV_PAR03),0530,0080) //Periodo del - al
		opReport:PrintText(STR0004+" "+apDados[nlX,1]                                ,0470,1550) //CERTIFICADO No.:

		dbSelectArea("SA2")
		dbSetOrder(1)
		SA2->(dbGoTop())
		SA2->(dbSeek(xFilial("SA2")+PADR(apDados[nlX,3],TamSx3("A2_COD")[1])+PADR(apDados[nlX,4],TamSx3("A2_LOJA")[1])))

		opReport:PrintText(STR0005 + " " + SA2->A2_NOME                 	,0600,0080) //RETENIDO :
		opReport:PrintText(STR0006 + " " + IIf(Empty(SA2->A2_CGC),SA2->A2_PFISICA,SA2->A2_CGC) ,0600,1550) //NIT:
		opReport:PrintText(STR0007 + " " + Alltrim(SA2->A2_END) + ", " + Alltrim(SA2->A2_MUN),0640,0080) //DIRECCION:


		opReport:Say(0760,0080,STR0008,olFont,10,,) //Concepto
		opReport:Say(0760,0840,STR0009,olFont,10,,) //Valor Base
		opReport:Say(0760,1190,STR0010,olFont,10,,) //Base
		opReport:Say(0760,1635,STR0011,olFont,10,,) //% Aplicado
		opReport:Say(0760,1950,STR0012,olFont,10,,) //Total IVA Retenido

		opReport:Line(0820,0080,0820,0650)
		opReport:Line(0820,0675,0820,1135)
		opReport:Line(0820,1160,0820,1600)
		opReport:Line(0820,1625,0820,1925)
		opReport:Line(0820,1950,0820,2410)

		nlLin := 850

		nlBase   := 0
		nlValRet := 0
		nlValIVA := 0

		clFornec := apDados[nlX,3]
		clLoja   := apDados[nlX,4]
		nlAlq    := apDados[nlX,9]		
		Do While clFornec == apDados[nlX,3] .and. clLoja == apDados[nlX,4]
			If nlAlq == apDados[nlX,9]
				nlBase   += apDados[nlX,8]
				nlValRet += apDados[nlX,12]	
				nlValIVA += apDados[nlX,11] //IVA Operacion	
			Else
				aAdd(alItens,{nlBase,nlAlq,nlValRet,nlValIVA})
				nlBase   := apDados[nlX,8]
				nlAlq    := apDados[nlX,9]
				nlValRet := apDados[nlX,12]	  
				nlValIVA := apDados[nlX,11] //IVA Operacion	
			EndIf
			nlX++
			If nlX > Len(apDados)
				Exit
			EndIf
		EndDo
		nlX--

		aAdd(alItens,{nlBase,nlAlq,nlValRet,nlValIVA}) //IVA Operacion	

		nlTotBase := 0
		nlTotIVA  := 0 
		nlTotRet  := 0 
        If cPaisLoc<> "COL"
        	nSinal:= -1
		EndIf
		For nlI := 1 To Len(alItens)		

			opReport:Say(nlLin,0080,STR0013,olFont,10,,) //RETENCION FUENTE IVA
			opReport:Say(nlLin,0760,Transform((alItens[nlI,1]* nSinal)	,"@E 999,999,999.99"),olFont,10,,)
			opReport:Say(nlLin,1230,Transform((alItens[nlI,4]* nSinal)	,"@E 999,999,999.99"),olFont,10,,) //IVA Operacion	 
			opReport:Say(nlLin,1660,Transform(alItens[nlI,2]			,"@E %999.9999"),olFont,10,,)
			opReport:Say(nlLin,2050,Transform((alItens[nlI,3]* nSinal)	,"@E 999,999,999.99"),olFont,10,,)

			nlTotBase += alItens[nlI,1]
			nlTotRet  += alItens[nlI,3]
			nlTotIVA  += alItens[nlI,4]
			nlLin += 60
		Next nlI

		nlLin += 10
		opReport:Line(nlLin,0675,nlLin,1135)
		opReport:Line(nlLin,1160,nlLin,1600)
		opReport:Line(nlLin,1950,nlLin,2410)

		nlLin += 20
		opReport:Say(nlLin,0080,STR0014							,olFont,10,,)
		opReport:Say(nlLin,0760,Transform((nlTotBase*nSinal)	,"@E 999,999,999.99"),olFont,10,,)
		opReport:Say(nlLin,1230,Transform((nlTotIVA*nSinal)	,"@E 999,999,999.99"),olFont,10,,)
		opReport:Say(nlLin,2050,Transform((nlTotRet*nSinal)	,"@E 999,999,999.99"),olFont,10,,)

		nlLin += 120
		opReport:PrintText(STR0015,nlLin,0200) //SON:

		nlLin += 80
		nlLinhas := MLCOUNT(AllTrim(Extenso(nlTotRet)), 70, 3, .T.)

		If nlLinhas == 0
			nlLinhas := 1
		EndIf

		For nlI=1 TO nlLinhas 
			opReport:PrintText(MEMOLINE(AllTrim(Extenso(nlTotRet)), 70, nlI, 3, .T.),nlLin,0200)
			nlLin += 60
		Next nlI

		dbSelectArea("SFB")
		dbSetOrder(1)
		SFB->(dbGoTop())
		SFB->(dbSeek(xFilial("SFB")+"RV0"))

		nlLin += 60
		nlLinhas := MLCOUNT(SFB->FB_CERTIF, 80, 3, .T.)
		If nlLinhas == 0
			nlLinhas := 1
		ElseIf nlLinhas > 3
			nlLinhas := 3
		EndIf
		For nlI=1 TO nlLinhas 
			opReport:PrintText(MEMOLINE(SFB->FB_CERTIF, 80, nlI, 3, .T.),nlLin,0100)
			nlLin += 60
		Next nlI

		nlLin += 60
		opReport:PrintText(STR0021,nlLin,0100) //CIUDAD DONDE SE PRACTICO LA RETENCION
			
		nlLin += 60
		opReport:PrintText(AllTrim(SM0->M0_CIDENT)+", "+MesExtenso(Month(dDataBase))+" "+AllTrim(Str(Day(dDataBase)))+" "+STR0018+" "+AllTrim(Str(Year(dDataBase))),nlLin,0100) //de

		nlLin += 420
		opReport:Line(nlLin,0200,nlLin,0820)
		nlLin += 20
		opReport:PrintText(STR0016,nlLin,0360) //Firma y Sello
		nlLin += 180

		opReport:PrintText(MEMOLINE(STR0017, 075, 1, 2, .T.),nlLin,0100) //STR0017 ESTA CERTIFICACION SE EXPICE SIN FIRMA AUTOGRAFA DE ACUERDO A LO DISPUESTO EN EL ARTICULO 
		nlLin += 60
		opReport:PrintText(MEMOLINE(STR0017, 075, 2, 2, .T.),nlLin,0100) //STR0017 10 DEL DECRETO 836 DEL 26 DE MARZO DE 1991.

		nlLin += 180
		opReport:PrintText(MEMOLINE(STR0022, 075, 1, 2, .T.),nlLin,0100) //STR0022 Se expide este certificado para dar cumplimiento al Decreto 2300 Art. 23 de Dic1996 y según 
		nlLin += 60
		opReport:PrintText(MEMOLINE(STR0022, 075, 2, 2, .T.),nlLin,0100) //STR0022 especificacion del Decreto 380 Art. 7 del  27/02/1996.

		opReport:EndPage()

	Next nlX

Return
