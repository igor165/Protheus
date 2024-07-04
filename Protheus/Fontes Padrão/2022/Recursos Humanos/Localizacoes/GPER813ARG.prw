#INCLUDE "GPER813ARG.ch"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE 'TOPCONN.CH'    


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GPER813ARG  � Autor � Raul Ortiz            � Data � 18/10/15 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Reporte de Exceptciones de Loquidaci�n                        ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPER813ARG()                                                 ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function GPER813ARG()
Local oReport := nil
Local cPerg := Padr("GPER813ARG",10)

	Pergunte(cPerg,.F.)
	
	oReport := RptDef(cPerg)
	oReport:PrintDialog()

Return


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �RptDef      � Autor � Raul Ortiz            � Data � 18/10/15 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Definicni�n del reporte                                       ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � RptDef(cName)                                                ���
���������������������������������������������������������������������������Ĵ��
���Parametros�cName - Nombre del Reporte (Grupo de preguntas                ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function RptDef(cName)
Local oReport := Nil
Local oSection1 := Nil
Local oSection2 := Nil
Local oBreak 
Local oFunction

	oReport := TReport():New(cName,STR0001,cName,{|oReport| ReportPrint(oReport)},STR0002)
	oReport:SetPortrait
	oReport:SetTotalInLine(.F.)
	
	oSection1:= TRSection():New(oReport,"MAT" , {"SRA"}, , .F.,.T.)
	//If MV_PAR10 == 2
	TRCell():New(oSection1,"RA_MAT", "TRBNCM", STR0014, "@!",TamSX3("RA_MAT")[1] + 2)
	TRCell():New(oSection1,"RA_NOME", "TRBNCM", STR0020, "@!",TamSX3("RA_NOME")[1])
	TRCell():New(oSection1,"RA_SITFOLH", "TRBNCM", STR0021, "@!",30)
	//EndIf
	TRCell():New(oSection1,"PD", "TRBNCM", STR0012, "@!",3)
	TRCell():New(oSection1,"DESC", "TRBNCM", STR0013, "@!",30)
	//If MV_PAR10 == 1
	TRCell():New(oSection1,"LEJBASE", "TRBNCM", STR0014 + " " + STR0018 , "@!",6)
	//EndIf
	TRCell():New(oSection1,"CANTBASE", "TRBNCM", STR0008 + STR0018, "@! 999,999,999,999.99",15)
	TRCell():New(oSection1,"IMPBASE", "TRBNCM", STR0009 + STR0018, "@! 999,999,999,999.99",15)
	//If MV_PAR10 == 1
	TRCell():New(oSection1,"LEJCONT", "TRBNCM", STR0014 + " " + STR0017, "@!",6)
	//EndIf
	TRCell():New(oSection1,"CANTCONT", "TRBNCM", STR0008 + STR0017, "@! 999,999,999,999.99",15)
	TRCell():New(oSection1,"IMPCONT", "TRBNCM", STR0009 + STR0017, "@! 999,999,999,999.99",15)
	TRCell():New(oSection1,"DIFCANT", "TRBNCM", STR0019 + STR0015, "@! 999,999,999,999.99",15)
	TRCell():New(oSection1,"DIFIMP", "TRBNCM", STR0019 + STR0016, "@! 999,999,999,999.99",15)
	
	oSection1:SetTotalInLine(.F.)
	
	oSection1:SetPageBreak(.T.)
	oSection1:SetTotalText(" ")
Return(oReport)


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportPrint � Autor � Raul Ortiz            � Data � 18/10/15 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Rutina de impresi�n del reporte                               ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �ReportPrint(oReport)                                          ���
���������������������������������������������������������������������������Ĵ��
���Parametros�oReport - Objeto con la definici�n del reporte                ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport)
Local oSection1 := oReport:Section(1)
Local cQuery 	:= ""
Local cNcm		:= ""
Local nPrim	:= .T.
Local nRegs := 0
Local aPerAbeB	:= {} //Periodo Base Abierto
Local aPerFecB	:= {} //Periodo Base Cerrado
Local aPerAbeC	:= {} //Periodo Controlado Abierto
Local aPerFecC	:= {} //Periodo Controlado Cerrado
Local aMat := {}
Local nX := 0
Local aVerbasB   := {}
Local aVerbasC   := {}
Local aConceptos := {}
Local aCocepAcu := {}
Local aAcumulado := {}

Private cProcesso	:= MV_PAR05 // Armazena o processo selecionado na Pergunte GPR040 (MV_PAR05).
Private cRoteiro	:= MV_PAR04 // Armazena o Roteiro selecionado na Pergunte GPR040 (MV_PAR04).
Private cPeriodB	:= MV_PAR06 // Armazena o Periodo selecionado na Pergunte GPR040 (MV_PAR06).
Private cPeriodC	:= MV_PAR08 // Armazena o Periodo selecionado na Pergunte GPR040 (MV_PAR08).

	//Se busca si es periodo cerrado o abierto para el periodo Base
	RetPerio(@aPerAbeB,@aPerFecB,MV_PAR05,MV_PAR04,MV_PAR06,MV_PAR07)			
	//Se busca si es periodo cerrado o abierto para el periodo Controlado
	RetPerio(@aPerAbeC,@aPerFecC,MV_PAR05,MV_PAR04,MV_PAR08,MV_PAR09)
	
	aConceptos := GetConcep()
	
	If !Empty(aConceptos)
		DbSelectArea("SRA")
		SRA->(dbsetOrder(1))
		SRA->(dbGoTop())
		If !Empty(MV_PAR03)
			aMat := StrTokArr(SUBSTR(MV_PAR03,1,Iif(Substr(MV_PAR03,Len(AllTrim(MV_PAR03)), 1)==";",LEN(AllTrim(MV_PAR03))-1,LEN(AllTrim(MV_PAR03)))),";") //Iif(Substr(MV_PAR03,Len(AllTrim(MV_PAR03))-1, 1)==";",LEN(AllTrim(MV_PAR03))-1,LEN(AllTrim(MV_PAR03)))
			If !Empty(aMat)
				
				For nX := 1 To Len(aMat)
					If SRA->(dbSeek(xFilial("SRA")+aMat[nX]))
						aVerbasB   := RetVerbas(SRA->RA_FILIAL,SRA->RA_MAT,aPerAbeB,aPerFecB)
						aVerbasC   := RetVerbas(SRA->RA_FILIAL,SRA->RA_MAT,aPerAbeC,aPerFecC)
						If !Empty(aVerbasB) .or. !Empty(aVerbasC)
							VldLinea(oReport,@oSection1,aVerbasB,aVerbasC,aConceptos,@aAcumulado)
						EndIf
					EndIf
				Next
				If MV_PAR10 == 1
					ImpLiAcum(aAcumulado,oReport,@oSection1)
				EndIf
			EndIf
		Else
			While !SRA->(EOF())
				aVerbasB   := RetVerbas(SRA->RA_FILIAL,SRA->RA_MAT,aPerAbeB,aPerFecB)
				aVerbasC   := RetVerbas(SRA->RA_FILIAL,SRA->RA_MAT,aPerAbeC,aPerFecC)
				If !Empty(aVerbasB) .or. !Empty(aVerbasC)
					VldLinea(oReport,@oSection1,aVerbasB,aVerbasC,aConceptos,@aAcumulado)
				EndIf
				SRA->(DbSkip())
			EndDO
			If MV_PAR10 == 1
				ImpLiAcum(aAcumulado,oReport,@oSection1)
			EndIf
		EndIf
	EndIf
	
	oReport:ThinLine()
	oSection1:Finish()
Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �VldLinea    � Autor � Raul Ortiz            � Data � 18/10/15 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Validaci�n por linea de los conceptos encontrados             ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VldLinea(oReport,oSection1,aVerbasB, aVerbasC,aConceptos,aAcumulado)���
���������������������������������������������������������������������������Ĵ��
���Parametros�oReport - Objeto con la definici�n del reporte                ���
���          �oSection1 - Objeto con la secci�n de impresi�n                ���
���          �aVerbasB - Arreglo con los conceptos del periodo base         ���
���          �aVerbasC - Arreglo con los conceptos del periodo control      ���
���          �aConceptos - Arreglo con los conceptos de la matricula en     ���
���          �				preoceso                                        ���
���          �aAcumulado - Arreglo para acumulado cuando el proceso es por  ���
���          �				Concepto                                        |��
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function VldLinea(oReport,oSection1,aVerbasB, aVerbasC,aConceptos,aAcumulado)
Local nX := 0
Local nCantB := 0
Local nImpB := 0
Local nCantC := 0
Local nImpC := 0
Local nPosBase := 0
Local nPosCont := 0
Local aAcumMat := {}
Local cDescSit := ""
Local nDifCant :=  0  //Diferencia_Cantidad
Local nDifCanPor := 0 //Diferencia_Cantidad_Porcentaje
Local nDifImp :=  0  //Diferencia_Importe
Local nDifImpPor := 0 //Diferencia_Importe_Porcentaje
Local lCant := .F.
Local lImp := .F.


	For nX := 1 To Len(aConceptos)
		nPosBase := AScan(aVerbasB,{|aVal|aVal[3]==aConceptos[nX][1]})
		nPosCont := AScan(aVerbasC,{|aVal|aVal[3]==aConceptos[nX][1]})
		
		If nPosBase > 0 .or. nPosCont > 0
			If aConceptos[nX][11] == "1" .or. aConceptos[nX][11] == "3"
				nImpB := IIf(nPosBase > 0,aVerbasB[nPosBase][7],0)
				nImpC := IIf(nPosCont > 0,aVerbasC[nPosCont][7],0)
				nDifImp := nImpB - nImpC
				nDifImpPor := (nDifImp * 100) / nImpB
				If aConceptos[nX][4] <= nDifImp .and. aConceptos[nX][6] >= nDifImp .and. aConceptos[nX][3] <= nDifImpPor .and. aConceptos[nX][5] >= nDifImpPor
					lImp := .T.
				Else
					lImp := .F.
				EndIf
			Else
				nImpB := 0
				nImpC := 0
				lImp := .F.
			EndIf
			
			If aConceptos[nX][11] == "2" .or. aConceptos[nX][11] == "3"
				nCantB := IIf(nPosBase > 0,aVerbasB[nPosBase][6],0)
				nCantC := IIf(nPosCont > 0,aVerbasC[nPosCont][6],0)
				nDifCant := nCantB - nCantC
				nDifCanPor := (nDifCant * 100) / nCantB
				If aConceptos[nX][8] <= nDifCant .and. aConceptos[nX][10] >= nDifCant .and. aConceptos[nX][7] <= nDifCanPor .and. aConceptos[nX][9] >= nDifCanPor
					lCant := .T.
				Else
					lCant := .F.
				EndIf
			Else
				nCantB := 0
				nCantC := 0
				lCant := .F.
			EndIf
			
			//Validacione
			If (lCant .and. aConceptos[nX][11] == "2" ) .or. (lImp .and. aConceptos[nX][11] == "1") .or. (aConceptos[nX][11] == "3" .and. lImp .and. lCant) 
				If MV_PAR10 == 2
					cDescSit := AllTrim(POSICIONE("SX5", 1,xFilial("SX5")+ "31" + SRA->RA_SITFOLH, "X5_DESCSPA"))
					AcumMatr(cDescSit,aConceptos[nX][1],aConceptos[nX][2],nCantB,nImpB,nCantC,nImpC,@aAcumMat)
				Else
					Acumula(@aAcumulado,aConceptos[nX][1],aConceptos[nX][2],nPosBase,nPosCont,nCantB,nImpB,nCantC,nImpC)
				EndIf
			EndIf
		EndIf
	Next
	If MV_PAR10 == 2
		ImpLiMat(aAcumMat,oReport,@oSection1)
	EndIf

Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Acumula     � Autor � Raul Ortiz            � Data � 18/10/15 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Acumula los vales cuando el proceso es por concepto           ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Acumula()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�aAcumulado - Arreglo utilizado para acumular por proceso      ���
���          �cConcep - C�digo del concepto en proceso                      ���
���          �cDescPD - Descripci�n del concepto en proceso                 ���
���          �nPosBase - Utilizado para saber si sumariza en Legajo Base    ���
���          �nPosCont -  Utilizado para saber si sumariza en Legajo Control���
���          �nCantB - Cantidad del perido Base                             ���
���          �nImpB -  Importe del periodo Base                             ���
���          �nCantC - Cantidad del periodo Control                         ���
���          �nImpC -  Importe del periodo Control                          ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function Acumula(aAcumulado,cConcep,cDescPD,nPosBase,nPosCont,nCantB,nImpB,nCantC,nImpC)
Local nPosConcep := 0

	If Empty(aAcumulado)
		AADD(aAcumulado,{cConcep,cDescPD,IIf(nPosBase>0,1,0),nCantB,nImpB,IIf(nPosCont>0,1,0),nCantC,nImpC,nCantB-nCantC,nImpB-nImpC})
	Else
		nPosConcep := AScan(aAcumulado,{|aVal|aVal[1]==cConcep})
		If nPosConcep > 0
			aAcumulado[nPosConcep][3] += IIf(nPosBase>0,1,0)
			aAcumulado[nPosConcep][4] += nCantB
			aAcumulado[nPosConcep][5] += nImpB
			aAcumulado[nPosConcep][6] += IIf(nPosCont>0,1,0)
			aAcumulado[nPosConcep][7] += nCantC
			aAcumulado[nPosConcep][8] += nImpC
			aAcumulado[nPosConcep][9] += nCantB-nCantC
			aAcumulado[nPosConcep][10] += nImpB-nImpC
		Else
			AADD(aAcumulado,{cConcep,cDescPD,IIf(nPosBase>0,1,0),nCantB,nImpB,IIf(nPosCont>0,1,0),nCantC,nImpC,nCantB-nCantC,nImpB-nImpC})
		EndIf
	EndIf
Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �AcumMatr    � Autor � Raul Ortiz            � Data � 18/10/15 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Acumula los conceptos por matricula                           ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � AcumMatr (cDescSit,cConcep,cDescPD,nCantB,nImpB,nCantC,nImpC,aAcumMat)���
���������������������������������������������������������������������������Ĵ��
���Parametros�cDescSit - Descripci�n de la situaci�n del empleado           ���
���          �cConcep - C�digo del concepto en proceso                      ���
���          �cDescPD - Descripci�n del concepto en proceso                 ���
���          �nCantB - Cantidad del perido Base                             ���
���          �nImpB -  Importe del periodo Base                             ���
���          �nCantC - Cantidad del periodo Control                         ���
���          �nImpC -  Importe del periodo Control                          ���
���          �aAcumMat - Arreglo utilizado para acumular por matricula      ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function AcumMatr (cDescSit,cConcep,cDescPD,nCantB,nImpB,nCantC,nImpC,aAcumMat)
Local nPosConcep := 0
	If Empty(aAcumMat)
		AADD(aAcumMat,{cDescSit,cConcep,cDescPD,nCantB,nImpB,nCantC,nImpC,nCantB-nCantC,nImpB-nImpC})
	Else
		nPosConcep := AScan(aAcumMat,{|aVal|aVal[2]==cConcep})
		If nPosConcep > 0
			aAcumMat[nPosConcep][4] += nCantB
			aAcumMat[nPosConcep][5] += nImpB
			aAcumMat[nPosConcep][6] += nCantC
			aAcumMat[nPosConcep][7] += nImpC
			aAcumMat[nPosConcep][8] += nCantB-nCantC
			aAcumMat[nPosConcep][9] += nImpB-nImpC
		Else
			AADD(aAcumMat,{cDescSit,cConcep,cDescPD,nCantB,nImpB,nCantC,nImpC,nCantB-nCantC,nImpB-nImpC})
		EndIf
	EndIf
	
Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ImpLiMat    � Autor � Raul Ortiz            � Data � 18/10/15 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime por linea los acumulados por matricula                ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ImpLiMat(aConcep,oReport,oSection1)                          ���
���������������������������������������������������������������������������Ĵ��
���Parametros�aConcep - Arreglo con los conceptos a imprimir                ���
���          �oReport - Objeto con la definici�n del reporte                ���
���          �oSection1 - Objeto con la secci�n de impresi�n                ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ImpLiMat(aConcep,oReport,oSection1)
Local nX := 0
	//:Disable()
	For nX := 1 To Len(aConcep)
		oSection1:Init()
		oReport:IncMeter()
		oSection1:Cell("RA_MAT"):SetValue(SRA->RA_MAT)
		oSection1:Cell("RA_NOME"):SetValue(SRA->RA_NOME)
		oSection1:Cell("RA_SITFOLH"):SetValue(aConcep[nX][1])
		oSection1:Cell("PD"):SetValue(aConcep[nX][2])
		oSection1:Cell("DESC"):SetValue(aConcep[nX][3])
		oSection1:Cell("LEJBASE"):Disable()
		oSection1:Cell("CANTBASE"):SetValue(aConcep[nX][4])
		oSection1:Cell("IMPBASE"):SetValue(aConcep[nX][5])
		oSection1:Cell("LEJCONT"):Disable()
		oSection1:Cell("CANTCONT"):SetValue(aConcep[nX][6])
		oSection1:Cell("IMPCONT"):SetValue(aConcep[nX][7])
		oSection1:Cell("DIFCANT"):SetValue(aConcep[nX][8])
		oSection1:Cell("DIFIMP"):SetValue(aConcep[nX][9])
		oSection1:Printline()
	Next
Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ImpLiAcum   � Autor � Raul Ortiz            � Data � 18/10/15 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime por linea los acumulados                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ImpLiAcum(aConcep,oReport,oSection1)                         ���
���������������������������������������������������������������������������Ĵ��
���Parametros�aConcep - Arreglo con los conceptos a imprimir                ���
���          �oReport - Objeto con la definici�n del reporte                ���
���          �oSection1 - Objeto con la secci�n de impresi�n                ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ImpLiAcum(aConcep,oReport,oSection1)
Local nX := 0
	//:Disable()
	For nX := 1 To Len(aConcep)
		oSection1:Init()
		oReport:IncMeter()
		oSection1:Cell("RA_MAT"):Disable()
		oSection1:Cell("RA_NOME"):Disable()
		oSection1:Cell("RA_SITFOLH"):Disable()
		oSection1:Cell("PD"):SetValue(aConcep[nX][1])
		oSection1:Cell("DESC"):SetValue(aConcep[nX][2])
		oSection1:Cell("LEJBASE"):SetValue(aConcep[nX][3])
		oSection1:Cell("CANTBASE"):SetValue(aConcep[nX][4])
		oSection1:Cell("IMPBASE"):SetValue(aConcep[nX][5])
		oSection1:Cell("LEJCONT"):SetValue(aConcep[nX][6])
		oSection1:Cell("CANTCONT"):SetValue(aConcep[nX][7])
		oSection1:Cell("IMPCONT"):SetValue(aConcep[nX][8])
		oSection1:Cell("DIFCANT"):SetValue(aConcep[nX][9])
		oSection1:Cell("DIFIMP"):SetValue(aConcep[nX][10])
		oSection1:Printline()
	Next
Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �RetPerio    � Autor � Raul Ortiz            � Data � 18/10/15 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Obtiene los datos del periodo buscado                         ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � RetPerio(aPerAbe,aPerFec,cProc,cRot,cPer,cNumPag)            ���
���������������������������������������������������������������������������Ĵ��
���Parametros�aPerAbe - Arreglo para almacenar los datos del periodo Abierto���
���          �aPerFec - Arreglo para almacenar los datos del periodo cerrado���
���          �cProc - C�digo del proceso a busar                            ���
���          �cRot - C�digo del procedimiento a buscar                      ���
���          �cPer - Periodo a buscar                                       ���
���          �cNumPag - Numero de pago a bucar                              ���
���          �                                                              ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function RetPerio(aPerAbe,aPerFec,cProc,cRot,cPer,cNumPag)

	RetPerAbertFech(MV_PAR05 ,; // Processo selecionado na Pergunte.
							MV_PAR04	,; // Roteiro selecionado na Pergunte.
							cPer	,; // Periodo selecionado na Pergunte.
							cNumPag		,; // Numero de Pagamento selecionado na Pergunte.
							NIL			,; // Periodo Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um periodo.
							NIL			,; // Numero de Pagamento Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um numero de pagamento.
							@aPerAbe	,; // Retorna array com os Periodos e NrPagtos Abertos
							@aPerFec ) // Retorna array com os Periodos e NrPagtos Fechados

Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �RetVerbas   � Autor � Raul Ortiz            � Data � 18/10/15 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Obtiene datos del concepto del periodo cerrado                ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � RetVerbas(cFil,cMat,aPerAbe,aPerFec)                         ���
���������������������������������������������������������������������������Ĵ��
���Parametros�cFil - Filial del empleado                                    ���
���          �cMat - Matricula del empleado                                 ���
���          �aPerAbe - Arreglo con datos del periodo abierto               ���
���          �aPerFec - Arreglo con datos del periodo cerrado               ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function RetVerbas(cFil,cMat,aPerAbe,aPerFec)
Local aVerbasFunc := {}

	aVerbasFunc	:= RetornaVerbasFunc(	cFil					,; // Filial do funcionario corrente
												cMat	  					,; // Matricula do funcionario corrente
												NIL								,; // 
												cRoteiro	  					,; // Roteiro selecionado na pergunte
												NIL	,; //			  aVerbasFilter				 // Array com as verbas que dever鉶 ser listadas. Se NIL retorna todas as verbas.
												aPerAbe	  					,; // Array com os Periodos e Numero de pagamento abertos
												aPerFec	 	 				 ) // Array com os Periodos e Numero de pagamento fechados


Return aVerbasFunc


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GetConcep   � Autor � Raul Ortiz            � Data � 18/10/15 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Obtiene los conceptos del para el reporte                     ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � GetConcep()                                                  ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function GetConcep()
Local aConceptos := {}
Local aConPerg := {}
Local nPosCod := 0

	If !Empty(MV_PAR02)
		aConPerg := StrTokArr(SUBSTR(MV_PAR02,1,Iif(Substr(MV_PAR02,Len(AllTrim(MV_PAR02)), 1)==";",LEN(AllTrim(MV_PAR02))-1,LEN(AllTrim(MV_PAR02)))),";") 
		aConPerg := VldConcep(aConPerg)
	EndIf

	DbSelectArea("SQK")
	SQK->(DbSetOrder(1))
	If SQK->(DbSeek(xFilial("SQK")+MV_PAR01))
		If !Empty(AllTrim(MV_PAR02)) .and. Empty(aConPerg)
			Return aConceptos
		Else
			While !SQK->(EOF())
				If SQK->QK_COD == MV_PAR01
					If !Empty(aConPerg)
						nPosCod := AScan(aConPerg,{|aVal|aVal[1]==SQK->QK_PD})
						If  nPosCod > 0
							AADD(aConceptos,{SQK->QK_PD,aConPerg[nPosCod][2],QK_IMINPOR,QK_IMINVAL,QK_IMAXPOR,QK_IMAXVAL,QK_CMINPOR,QK_CMINVAL,QK_CMAXPOR,QK_CMAXVAL,QK_TIPOCMP})
						EndIf
					Else
						AADD(aConceptos,{SQK->QK_PD,AllTrim(POSICIONE("SRV", 1,xFilial("SRV") + SQK->QK_PD , "RV_DESC")),QK_IMINPOR,QK_IMINVAL,QK_IMAXPOR,QK_IMAXVAL,QK_CMINPOR,QK_CMINVAL,QK_CMAXPOR,QK_CMAXVAL,QK_TIPOCMP})
					End
				EndIf
				SQK->(DbSkip())
			Enddo
		EndIf
	EndIf
	SQK->(DbCloseArea())

Return aConceptos


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �VldConcep   � Autor � Raul Ortiz            � Data � 18/10/15 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Reporte de Exceptciones de Loquidaci�n                        ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VldConcep(aConcept)                                          ���
���������������������������������������������������������������������������Ĵ��
���Parametros�aConcept - Valida los conceptos y obtiene descripcion         ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function VldConcep(aConcept)
Local nX := 0
Local nNoValid := 0
Local aConVal := {}

	DBSelectArea("SRV")
	SRV->(DbSetOrder(1))
	For nX := 1 To Len(aConcept)
		If SRV->(DbSeek(xFilial("SRV")+aConcept[nX]))
			AADD(aConVal,{aConcept[nX],SRV->RV_DESC})
		EndIf
	Next
	SRV->(DbCloseArea())
Return aConVal


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �VldNPgLiq   � Autor � Raul Ortiz            � Data � 18/10/15 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Valida que esxita el n�mero de pago informado en parametros   ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VldNPgLiq(nOpc)                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros�nOpc - 1 = Base, 2 = Control                                  ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function VldNPgLiq(nOpc)
Local lRet := .T.
	
	DbSelectArea("RCH")
	RCH->(DbSetOrder(RETORDEM("RCH","RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR")))
	If nOpc == 1
		If !Empty(AllTrim(MV_PAR07))
			If !RCH->(dbSeek(xFilial("RCH")+MV_PAR05+MV_PAR06+MV_PAR07+MV_PAR04))
				lRet := .F.
				Alert(STR0004 + MV_PAR05 + STR0005 + MV_PAR04 + STR0006 + MV_PAR06 + STR0007 + MV_PAR07)
			EndIf
		Else
			lRet := .F.
			Alert(STR0003)
		EndIf
	ElseIf nOpc == 2
		If !Empty(AllTrim(MV_PAR09))
			If !RCH->(dbSeek(xFilial("RCH")+MV_PAR05+MV_PAR08+MV_PAR09+MV_PAR04))
				lRet := .F.
				Alert(STR0004 + MV_PAR05 + STR0005 + MV_PAR04 + STR0006 + MV_PAR08 + STR0007 + MV_PAR09)	
			Else
				If	MV_PAR06 + MV_PAR07 == MV_PAR08 + MV_PAR09
					lRet := .F.
					Alert(STR0010 + STR0011)
				EndIf		
			EndIf
		Else
			lRet := .F.
			Alert(STR0003)
		EndIf	
	EndIf
	RCH->(dbCloseArea("RCH"))
Return lRet


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �VldPerLiq   � Autor � Raul Ortiz            � Data � 18/10/15 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Valida el periodo informado en los parametros                 ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VldPerLiq()                                                  ���
���������������������������������������������������������������������������Ĵ��
���Parametros�nOpc - 1 = Base, 2 = Control                                  ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function VldPerLiq(nOpc)
Local lRet := .T.
	DbSelectArea("RCH")
	RCH->(DbSetOrder(RETORDEM("RCH","RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG")))
	If nOpc == 1
		If !Empty(AllTrim(MV_PAR06))
			If !RCH->(dbSeek(xFilial("RCH")+MV_PAR05+MV_PAR04+MV_PAR06))
				lRet := .F.
				Alert(STR0004 + MV_PAR05 + STR0005 + MV_PAR04 + STR0006 + MV_PAR06)	
			EndIf
		Else
			lRet := .F.
			Alert(STR0003)
		EndIf
	ElseIf nOpc == 2
		If !Empty(AllTrim(MV_PAR09))
			If !RCH->(dbSeek(xFilial("RCH")+MV_PAR05+MV_PAR04+MV_PAR08))
				lRet := .F.
				Alert(STR0004 + MV_PAR05 + STR0005 + MV_PAR04 + STR0006 + MV_PAR08)		
			EndIf
		Else
			lRet := .F.
			Alert(STR0003)
		EndIf
	EndIf
	RCH->(dbCloseArea("RCH"))
Return lRet
