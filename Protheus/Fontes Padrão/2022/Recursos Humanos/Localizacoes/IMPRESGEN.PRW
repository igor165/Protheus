#INCLUDE "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 05/07/00
#INCLUDE "IMPRESZ.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³RdMake    ³ ImpResGEN³ Autor ³ Leandro Drumond       ³ Data ³ 22.10.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao da Rescisao em Papel Zebrado para Costa Rica       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ImpResCos                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para armazenar as informacoes das perguntes:   ³
//³                                                                     ³
//³ nTipo 		- Tipo de Formulario ?                 					³ 
//³ cFilialDe	- De Sucursal ?                         				³
//³ cFilialAte	- Hasta Sucursal ?                      				³
//³ cMatDe		- De Matricula ?                        				³
//³ cMatAte		- Hasta Matricula ?                     				³
//³ cCCDe		- De Centro de Costo ?                  				³
//³ cCCAte		- Hasta Centro de Costo ?               				³
//³ cTipoRes	- Tipo de Liq. Final ?                  				³
//³ cImprCGC 	- Imprime Sello RFC ?                   				³
//³ dDtDemDe	- De Fecha Despido ?                    				³
//³ dDtDemAte	- Hasta Fecha Despido ?                 				³
//³ dDtGerDe	- De Fecha Generacion ?                 				³
//³ dDtGerAte	- Hasta Fecha Generacion ?              				³
//³ nImprDtHom	- Imprime Fecha Homologacion ?          				³
//³ nNumVias	- Numero de Copias ?                    				³
//³ cImprFerias	- Imprime Vacaciones ?              					³
//³ dDtHomDe	- De Fecha Homologa ?                   				³
//³ dDtHomAte	- Hasta Fecha Homologa ?                				³
//³ cImpr13Sal	- Imprime Aguinaldo ?                   				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

User Function ImpResGen()        // incluido pelo assistente de conversao do AP5 IDE em 05/07/00

Local aVerbas	:= {}  
Local nValor	:= 0
Local nReg		:= 0
Local nTot		:= 2

Private nPagina := 0     
Private cMensRec:= ""

//Definicao do array de Titulo aTitulos.
#Define CGC			1		
#Define FILIAL 		2
#Define CC     		3 
#Define NOME     	4
#Define MAT			5
#Define ENDERE		6
#Define BAIRRO		7
#Define MUNICIP		8
#Define ESTADO		9
#Define CEP			10
#Define CIC			11
#Define NASC    	12
#Define	 MAE		13
#Define SALMEN		14
#Define	 ADMISSA	15
#Define DTAVISO		16
#Define DTDEM		17
#Define RG			18
#Define CURP		19
#Define LOCALIDAD	20

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("LNULL,NCONTAR,NLI,DET,X,cCodSaqIOB")

lNull   := .F.
nContar := 0
nLi     := 0

nEpoca:= SET(5,1910)
//--MUDAR ANO PARA 4 DIGITOS
SET CENTURY ON
                  
fCabecalho()

// 1= Proventos
// 2= Descontos
If cPaisLoc == "ARG"
	nTot := 3
EndIf

For nReg := 1 to nTot
	aVerbas := IIF(nReg==1,aClone(aPdv),If(nTot == 3 .and. nReg == 2,aClone(aPdn),aClone(aPdd)))
	nValor := IIF(nReg==1, nProv, If(nTot == 3 .and. nReg == 2,nNProv,nDesc))
	fCabecVerbas(nReg)
	fDetalhe(nReg, aVerbas)	
	fRodapeVerbas(nReg, nValor)
	nLi++    
Next nReg

fRodape()

Set(5,nEpoca)
If nTdata > 8
	SET CENTURY ON
Else
	SET CENTURY OFF
Endif

Return Nil   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºfCabecalho    ³IMPRESZ   ºAutor  ³Microsiga       º Data ³  22/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.         ³fCabecalho - Impressao do Cabecalho da Rescisao.        º±±
±±º              ³                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso           ³ AP5                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fCabecalho()

Local nTam1 := 0
Local nTam2 := 0

nPagina++
If nPagina > 1
	@ 058,001 PSAY REPLICATE("_",131)
	@ 059,121 PSAY "CONTINUA..."
	@ 060,001 PSAY REPLICATE("_",131)
EndIf

nLi := 01
If cTipoRes == 1
	@ nLi,060 PSAY If(cPaisLoc == "ARG","RESCISION","FINIQUITO")
Else   // Complementar
	@ nLi,060 PSAY If(cPaisLoc == "ARG","RESCISION ( COMPLEMENTAR )","FINIQUITO ( COMPLEMENTAR )")
Endif                       
@ 01,123 PSAY "PAG. " + AllTrim(Str(nPagina))

nLi := nLi + 2
If nPagina == 1
	@ nLi,001 PSAY "Recibi de: " + aInfo[3] + " La cantidad de: $ " + Transform((nProv + nNProv)- nDesc,"999,999,999.99")
	nLi++
	@ nLi,001 PSAY "Cantidad en letra: " + EXTENSO((nProv + nNProv)- nDesc)
	nLi++
	@ nLi,001 PSAY "Con motivo de " + AllTrim(cCausa) + ", en pago de los siguintes conceptos:"
	nLi := nLi + 2
EndIf

nTam1 := Max(Len(Alltrim(aTitulo[5])), Len(Alltrim(aTitulo[4])))
If cPaisLoc == "ARG"
	nTam1 := If(nTam1 > Max(Len(Alltrim(aTitulo[18])), Len(Alltrim(aTitulo[17]))), nTam1, Max(Len(Alltrim(aTitulo[18])), Len(Alltrim(aTitulo[17]))))
	nTam2 := Max(Len(Alltrim(aTitulo[11])), Len(Alltrim(aTitulo[18])))
Else
	nTam1 := If(nTam1 > Max(Len(Alltrim(aTitulo[20])), Len(Alltrim(aTitulo[17]))), nTam1, Max(Len(Alltrim(aTitulo[20])), Len(Alltrim(aTitulo[17]))))
	nTam2 := Max(Len(Alltrim(aTitulo[11])), Len(Alltrim(aTitulo[19])))
EndIf
nTam2 := If(nTam2 > Len(Alltrim(aTitulo[18])), nTam2, Len(Alltrim(aTitulo[18])))
                                   
nEspacos := nTam1 - Len(AllTrim(aTitulo[5]))
@ nLi,001 PSAY AllTrim(aTitulo[5])  + Space(nEspacos) + " : " + SRA->RA_MAT

nEspacos := nTam2 - Len(AllTrim(aTitulo[11]))
@ nLi,080 PSAY AllTrim(aTitulo[11]) + Space(nEspacos) + " : " + SRA->RA_CIC

nLi++
nEspacos := nTam1 - Len(AllTrim(aTitulo[4]))
@ nLi,001 PSAY AllTrim(aTitulo[4])  + Space(nEspacos) + " : " + SRA->RA_NOME

If cPaisLoc != "ARG"
	nLi++
	nEspacos := nTam1 - Len(AllTrim(aTitulo[20]))
	@ nLi,001 PSAY AllTrim(aTitulo[20]) + Space(nEspacos) + " : " + fDesc("RGC",SRA->RA_KEYLOC,"RGC_DESLOC")
EndIf

nEspacos := nTam2 - Len(AllTrim(aTitulo[18]))
@ nLi,080 PSAY AllTrim(aTitulo[18]) + Space(nEspacos) + " : " + SRA->RA_RG

nLi++
nEspacos := nTam1 - Len(AllTrim(aTitulo[17]))
@ nLi,001 PSAY AllTrim(aTitulo[17]) + Space(nEspacos) + " : " + DTOC(SRA->RA_DEMISSA)

nLi++
@ nLi,001 PSAY REPLICATE("_",131)

nLi++
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºfCabecVerbas  ³IMPRESZ   ºAutor  ³Microsiga       º Data ³  22/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.         ³fCabecVerbas - Impressao do Cabecalho da Rescisao.      º±±
±±º              ³                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso           ³ AP5                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fCabecVerbas(nReg)

If nLi > 55
	fCabecalho()     
EndIf
	
If nLi > 12
	nLi++
	@ nLi,001 PSAY REPLICATE("_",131)
	nLi++
EndIf

If cPaisLoc == "ARG"
	@ nLi,060 PSAY IIF(nReg==1, "REMUNERATIVOS", If(nReg == 2, "NO REMUNERATIVOS","DEDUCCIONES"))	
Else
	@ nLi,060 PSAY IIF(nReg==1, "PERCEPCIONES", "DEDUCCIONES")
EndIf

nLi++
@ nLi,001 PSAY REPLICATE("_",131)

nLi := nLi + 2
@ nLi,012 PSAY "UNIDADES"
@ nLi,022 PSAY "CONCEPTOS"
@ nLi,047 PSAY "IMPORTE"

nLi++
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºfRodapeVerbas ³IMPRESZ   ºAutor  ³Microsiga       º Data ³  10/30/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.         ³fRodapeVerbas - Impressao do Rodape da Rescisao.        º±±
±±º              ³                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso           ³ AP5                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fRodapeVerbas(nReg, nValor)
Local cMoeda := SuperGetMv( "MV_MOEDA1" )

nLi++
If nLi > 57
	fCabecalho()     
	fCabecVerbas(nReg)
EndIf

If cPaisLoc == "ARG"
	@ nLI,014 PSAY "TOTAL DE " +  IIF(nReg==1, "REMUNERATIVOS", If(nReg == 2, "NÃO REMUNERATIVOS","DEDUCCIONES"))	
Else
	@ nLI,014 PSAY "TOTAL DE " + IIF(nReg==1, "PERCEPCIONES", "DEDUCCIONES")
EndIf

@ nLI,090 PSAY "$ " + Transform(nValor,"99,999,999.99") + " " + cMoeda

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºfDetalhe  ³IMPRESZ   ºAutor  ³Microsiga           º Data ³  10/30/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³fDetalhe - Impressao do Detalhe da Rescisao.                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fDetalhe(nReg, aVerbas)

Local Imprime	:= 0 

For Imprime := 1 to Len(aVerbas)
	If nLi > 57
		fCabecalho()     
		fCabecVerbas(nReg)
	EndIf
	@ nLi,014 PSAY aVerbas[Imprime]
	nLi++    
Next Imprime

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºfRodape   ³IMPRESZ   ºAutor  ³Microsiga           º Data ³  10/30/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³fRodape - Impressao do Rodape da Rescisao.                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fRodape()

Local bCabec 	:= {|| nLi++, If(nLi > 57, fCabecalho(), .T.) }
Local nCont		:= 0
Local nWord		:= 0
Local nRecc		:= 0
Local cWord		:= ""
nLi++

Eval(bCabec)
/*

	@ nLI,001 PSAY "    Mediante el recibo de la anterior cantidad hago constar que la empresa " + aInfo[3] 
	@ nLI,125 PSAY ", no me"
	Eval(bCabec)
	@ nLI,001 PSAY " adeuda cantidad alguna por concepto de trabajo,  que recibi el pago de todas las prestaciones legales y contractuales que devengue"
	Eval(bCabec)
	@ nLI,001 PSAY " y a que tuve derecho, que disfrute  de  los  descansos semanales  y  legales pagados,  que disfrute de las vacaciones y recibi los"
	Eval(bCabec)
	@ nLI,001 PSAY " periodo vacacional  y de la prima vacacional,  que me fueron pagados  los aguinaldos y asi como  los  salarios devengados,  que no"
	Eval(bCabec)
	@ nLI,001 PSAY " labore tiempo extra,  todo lo anterior en relacion con todo el  tiempo de servicos,  que ademas la empresa me afilio al  Instituto"
	Eval(bCabec)
	@ nLI,001 PSAY " Mexicano  del  Seguro Social  y  no  sufri accidente  ni  riesgo profesional alguno,  que tambien la empresa hizo aportaciones  al"
	Eval(bCabec)
	@ nLI,001 PSAY " INFONAVIT  y a la  Afore,  por lo que le otorgo  el  mas amplio y total finiquito que en derecho procede y no me reservo accion ni"
	Eval(bCabec)
	@ nLI,001 PSAY " derecho alguno de cualquier naturaleza que hacer valer en su contra."
*/

nLi++
Eval(bCabec)
@ nLi,060 PSAY "Recibi"+Space(10)+ Str(Day(SRA->RA_DEMISSA),2) + " de " + MesExtenso(Month(SRA->RA_DEMISSA)) + " de " + Str(Year(SRA->RA_DEMISSA),4)

nLi++
Eval(bCabec)
@ nLi,040 PSAY REPLICATE("_",80)
nLi++         
@ nLi,040 PSAY SRA->RA_NOME

If Type("cRodape") <> "U"
	
	nLi := nLi+2
	
	For nCont := 1 To Len(cRodape)
			@ nLi++,001 PSAY SubStr( cRodape, nCont,  132 )
			nCont := nCont+132
	Next
	
EndIf

Return Nil
