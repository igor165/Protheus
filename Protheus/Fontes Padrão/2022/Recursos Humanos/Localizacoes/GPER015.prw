#Include "PROTHEUS.CH" 
#Include "GPER015.CH"

/*
������������������������������������������������������������������������������������������
������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������ͻ��
���Programa  � GPER015  � Autor � Luis Samaniego                 � Fecha �  21/12/2015 ���
��������������������������������������������������������������������������������������͹��
���Desc.     �Libro de Sueldo Digital - Argentina                                      ���
��������������������������������������������������������������������������������������͹��
���Uso       � SIGAGPE                                                                 ���
��������������������������������������������������������������������������������������͹��
���                 ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                  ���
��������������������������������������������������������������������������������������͹��
���  Programador   �    Data    �   Issue    �  Motivo da Alteracao                    ���
��������������������������������������������������������������������������������������͹��
��� Marco A. Glez. � 12/04/2019 � DMINA-5689 �Se replica a V12.1.17 la solucion reali- ���
���                �            �            �zada en el llamado TTALKW de V11.8, que  ���
���                �            �            �consiste en la creacion del Libro de     ���
���                �            �            �Sueldo Digital para Argentina RG 3781.   ���
��������������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������������
������������������������������������������������������������������������������������������
*/
Function GPER015()
	
	Local oFld		:= Nil
	Local aCombo	:= {}

	Private cCombo	:= ""
	Private oDlg	:= Nil
	Private oCombo	:= Nil

	aAdd( aCombo, STR0003 ) //"1 - Conceptos"
	aAdd( aCombo, STR0004 ) //"2 - Detalle"

	DEFINE MSDIALOG oDlg TITLE STR0001 FROM 0,0 TO 125,450 OF oDlg PIXEL //"RG 3781-15 Libro de Sueldo Digital"

	@ 006,006 TO 045,170 LABEL STR0002 OF oDlg PIXEL //"Libro de Sueldo Digital"
	@ 020,010 COMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 100,8 PIXEL OF oFld

	@ 009,180 BUTTON STR0005 SIZE 036,016 PIXEL ACTION (oDlg:End(), IIf( Subs(cCombo,1,1) == "1", GPELibConc(), GPELibDet())) //"Aceptar"
	@ 029,180 BUTTON STR0006 SIZE 036,016 PIXEL ACTION oDlg:End() //"Salir"

	ACTIVATE MSDIALOG oDlg CENTER

Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �GPELibConc �Autor  �Luis Samaniego      �Fecha �  21/12/15   ���
��������������������������������������������������������������������������͹��
���Desc.     � Libro de Sueldo Digital - Conceptos                         ���
��������������������������������������������������������������������������͹��
���Uso       � SIGAGPE                                                     ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function GPELibConc()
	
	Local cPerg		:= "GPER015A"
	Local nOpcA		:= 0
	Local aSays		:= {}
	Local aButtons	:= {}

	Pergunte( cPerg, .F. )
	
	aAdd(aSays,OemToAnsi( STR0001 ) ) //"RG 3781-15 Libro de Sueldo Digital"
	aAdd(aButtons, { 5,.T.,{ || Pergunte(cPerg,.T. ) } } )
	aAdd(aButtons, { 1,.T.,{ |o| nOpcA := 1, o:oWnd:End() } } )
	aAdd(aButtons, { 2,.T.,{ |o| nOpcA := 2, o:oWnd:End() } } )             
	
	FormBatch( OemToAnsi(STR0002), aSays , aButtons ) //"Libro de Sueldo Digital"

	If nOpcA == 1 
		Processa({ || GpeProcSRV() })
	EndIf
	
Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �GpeProcSRV �Autor  �Luis Samaniego      �Fecha �  21/12/15   ���
��������������������������������������������������������������������������͹��
���Desc.     � Crea archivo de libro de sueldo digital - Conceptos         ���
��������������������������������������������������������������������������͹��
���Uso       � SIGAGPE                                                     ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function GpeProcSRV()
	
	Local cNomArch := AllTrim(MV_PAR01)
	Local cDirArch := AllTrim(MV_PAR02)
	Local nArchTXT := 0
	Local cLinea   := ""

	Makedir(cDirArch)
	IIf (!(Substr(cNomArch,Len(cNomArch) - 2, 3) $ "txt|TXT"), cNomArch += ".TXT", "")
	nArchTXT := CreaArch(cDirArch, cNomArch, ".TXT")

	If nArchTXT == -1
		Return
	EndIf

	dbSelectArea("SRV")
	SRV->(DBSetOrder(1)) //"RV_FILIAL+RV_COD"
	While SRV->(!EOF())
		If !Empty(SRV->RV_CONAFIP)
			cLinea := PADR(SRV->RV_CONAFIP, 6, " ")        //1 a 6
			cLinea += PADR(SRV->RV_COD, 10, " ")             //7 a 16 
			cLinea += PADR(SRV->RV_DESC, 150, " ")          //17 a 166
			cLinea += "1"                                   //167 a 167
			cLinea += IIf(SRV->RV_SIPAPOR == "S", "1", "0") //168 a 168
			cLinea += IIf(SRV->RV_SIPACON == "S", "1", "0") //169 a 169
			cLinea += IIf(SRV->RV_INSSPOR == "S", "1", "0") //170 a 170
			cLinea += IIf(SRV->RV_INSSCON == "S", "1", "0") //171 a 171
			cLinea += IIf(SRV->RV_OBRSPOR == "S", "1", "0") //172 a 172
			cLinea += IIf(SRV->RV_OBRSCON == "S", "1", "0") //173 a 173
			cLinea += IIf(SRV->RV_FONSPOR == "S", "1", "0") //174 a 174
			cLinea += IIf(SRV->RV_FONSCON == "S", "1", "0") //175 a 175
			cLinea += IIf(SRV->RV_RENAPOR == "S", "1", "0") //176 a 176
			cLinea += IIf(SRV->RV_RENACON == "S", "1", "0") //177 a 177
			cLinea += " "                                   //178 a 178
			cLinea += IIf(SRV->RV_ASIGCON == "S", "1", "0") //179 a 179
			cLinea += " "                                   //180 a 180
			cLinea += IIf(SRV->RV_FNECON == "S", "1", "0")  //181 a 181
			cLinea += " "                                   //182 a 182
			cLinea += IIf(SRV->RV_ARTCON == "S", "1", "0")  //183 a 183
			cLinea += IIf(SRV->RV_REDIPOR == "S", "1", "0") //184 a 184
			cLinea += " "                                   //185 a 185
			cLinea += IIf(SRV->RV_REESPOR == "S", "1", "0") //186 a 186
			cLinea += "         "                           //187 a 195
			cLinea += CRLF

			FWrite(nArchTXT, cLinea)
			cLinea := ""
		EndIf
		SRV->(dbSkip())
	EndDo

	FClose (nArchTXT)
	
Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �GPELibDet  �Autor  �Luis Samaniego      �Fecha �  21/12/15   ���
��������������������������������������������������������������������������͹��
���Desc.     � Libro de sueldo digital - Detalle                           ���
��������������������������������������������������������������������������͹��
���Uso       � SIGAGPE                                                     ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function GPELibDet()
	
	Local cPerg    := "GPER015B"
	Local nOpcA    := 0
	Local aSays    := {}
	Local aButtons := {}
	
	If  RCH->(ColumnPos("RCH_ORDLSD")) > 0

		Pergunte( cPerg, .F. )
		aAdd(aSays,OemToAnsi( STR0001 ) ) //"RG 3781-15 Libro de Sueldo Digital"
		aAdd(aButtons, { 5,.T.,{ || Pergunte(cPerg,.T. ) } } )
		aAdd(aButtons, { 1,.T.,{ |o| nOpcA := 1, o:oWnd:End() } } )
		aAdd(aButtons, { 2,.T.,{ |o| nOpcA := 2, o:oWnd:End() } } )             
		FormBatch( OemToAnsi(STR0002), aSays , aButtons ) //"Libro de Sueldo Digital"
	
		If nOpcA == 1 
			Processa({ || GpeProcDet() })
		EndIf
	
	Else
		Aviso( OemToAnsi(STR0007), OemToAnsi(STR0017), {STR0009} ) //"No se tiene creado el campo RCH_ORDLSD o la estructura correcta de las preguntas, verifique la documentaci�n."   
	Endif
	
Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �GpeProcDet �Autor  �Luis Samaniego      �Fecha �  21/12/15   ���
��������������������������������������������������������������������������͹��
���Desc.     � Libro de Sueldo Digital - Detalle                           ���
��������������������������������������������������������������������������͹��
���Uso       � SIGAGPE                                                     ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function GpeProcDet()
	
	Local aVerbas	:= {}
	Local cNomArch	:= AllTrim(MV_PAR07)
	Local cDirArch	:= AllTrim(MV_PAR08)
	Local nEmps		:= 0
	Local cLinea	:= ""
	Local aRCCE		:= {}
	Local lAcumula	:= .F.
	Local cOrdLSD	:= ""
	Local cRoteiros	:= ""
	Local aPerAcAbe		:= {} //Periodo Abierto
	Local aPerAcFec		:= {} //Periodo Cerrado
	Local aConcepEve	:= {} //Conceptos para eventuales
	Local lEventual		:= .F.
	Local aVerbasEve	:= {}

	Private aPerAbe		:= {} //Periodo Abierto
	Private aPerFec		:= {} //Periodo Cerrado

	Private cRoteiro	:= MV_PAR01 // Armazena o Roteiro selecionado
	Private cProcesso	:= MV_PAR02 // Armazena o processo selecionado
	Private cPeriod		:= MV_PAR03 // Armazena o Periodo selecionado
	Private cNumPago	:= MV_PAR04 // Armazena o Periodo selecionado
	Private nIdenEnv    := MV_PAR09 // Por default (SJ)
	Private nNumLiq     := MV_PAR05
	Private cTipoLiq	:= IIf(MV_PAR06 == 1, "M", IIf(MV_PAR06 == 2, "Q", "S"))
	Private aConceptos	:= {}
	Private aConcepSRV	:= {}
	Private nArchTXT	:= 0
	Private nArchOK		:= 0
	Private dFchPago	:= POSICIONE("RCH", 1, xFilial("RCH")+MV_PAR02+MV_PAR03+MV_PAR04+MV_PAR01 , "RCH_DTPAGO")
	Private dFchDia		:= Date()
	Private cPictHrs	:= "@E 999.99"  
	Private cPictVal	:= "@E 999999999999.99"
	Private aVerbasFunc	:= {} //Para uso nova funcao em modelo2
	Private aVerbasAFun	:= {} //Para conceptos que acumularon varias liquidaciones
	Private aRoteiros	:= {}	
	Private aTmpConce	:= {}
	
	//Orden de la liquidaci�n
	cOrdLSD	:= POSICIONE("RCH", 1, xFilial("RCH")+MV_PAR02+MV_PAR03+MV_PAR04+MV_PAR01 , "RCH_ORDLSD")
	
	//Array aRoteiros para excluir dos calculos os roteiros do tipo "4" (SRY->RY_TIPO=4)
	DbSelectArea("SRY")
	DbSetOrder(1)  
	dbSeek(xFilial("SRY"))
	While !Eof("SRY") .And. SRY->RY_FILIAL == xFilial("SRY") 
		if SRY->RY_TIPO <> ("4")
			Aadd(aRoteiros,{SRY->RY_CALCULO, RY_TIPO,0}) 
		Endif
		dbSkip()	
	EndDo
		
	If (len(aRoteiros) <= 0) 
		Aviso( OemToAnsi(STR0007), OemToAnsi(STR0016), {STR0009} ) //"Atencion" - "N�o existem procedimentos para os par�metros informados."   
		Return .F.
	EndIf

	Makedir(cDirArch)
	IIf (!(Substr(cNomArch,Len(cNomArch) - 2, 3) $ "txt|TXT"), cNomArch += ".TXT", "")
	nArchTXT := CreaArch(cDirArch, "Original_" + cNomArch, ".TXT")
	nArchOK  := CreaArch(cDirArch, cNomArch, ".TXT")

	If nArchTXT == -1
		Return
	EndIf

	RetPerAbertFech(MV_PAR02 ,; // Processo selecionado na Pergunte.
					MV_PAR01	,; // Roteiro selecionado na Pergunte.
					MV_PAR03	,; // Periodo selecionado na Pergunte.
					MV_PAR04		,; // Numero de Pagamento selecionado na Pergunte.
					NIL			,; // Periodo Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um periodo.
					NIL			,; // Numero de Pagamento Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um numero de pagamento.
					@aPerAbe	,; // Retorna array com os Periodos e NrPagtos Abertos
					@aPerFec ) // Retorna array com os Periodos e NrPagtos Fechados
	
	DbSelectArea("SRA")
	SRA->(dbsetOrder(1)) //RA_FILIAL+RA_MAT
	SRA->(dbGoTop())
	GrabaReg01()
	
	While !SRA->(EOF())
		If  nEmps == 0 //Cargar solo una vez el contenido de la tabla S042
						
			If  EmpEvent() //Verifica si tiene empleados eventuales
				If  !(SRA->(ColumnPos("RA_RFCLAB")) > 0 .And. SQ3->(ColumnPos("Q3_CATPROF")) > 0 .And. SQ3->(ColumnPos("Q3_PTODESE")) > 0 .And. SRV->(ColumnPos("RV_LSDEVEN")) > 0)
					Aviso( OemToAnsi(STR0007), OemToAnsi(STR0020), {STR0009} ) //"No se tiene creado el campo RA_RFCLAB, Q3_CATPROF, Q3_PTODESE o RV_LSDEVEN, verifique la documentaci�n."  
					Exit
				Endif
				lEventual := .T. 
			Endif
			
			GetConcep(lEventual,@aConcepEve)
			CargaTabAl(@aRCCE,@lAcumula) 
			
			If  lAcumula 
				If  Empty(cOrdLSD) 
					Aviso( OemToAnsi(STR0007), OemToAnsi(STR0018), {STR0009} ) //"El periodo no tiene un orden informado (RCH_ORDLSD), verifique!."  
					Exit
				Elseif Alltrim(cOrdLSD) != Alltrim(nNumLiq)
					Aviso( OemToAnsi(STR0007), OemToAnsi(STR0019), {STR0009} ) //"El orden informado es diferente al asignado en el Periodo (RCH_ORDLSD), verifique!."  
					Exit
				Endif	
				cRoteiros := ObtRoteiros(nNumLiq)
				ObtPeriodos(@aPerAcAbe,@aPerAcFec)
			Endif	
					
		Endif
		
		//Conceptos para registro 03 (solo aplica una liquidaci�n)
		aVerbas   := RetVerbas(SRA->RA_FILIAL,SRA->RA_MAT,aConceptos,aPerAbe,aPerFec,cRoteiro)
		
		//Conceptos para registro 04: aVerbasFunc y aVerbasAFun 
		//No acumulan y se requieren para los registros del 001 al 033 y del 034 al 047
		aVerbasFunc := RetVerbas(SRA->RA_FILIAL,SRA->RA_MAT,aTmpConce,aPerAbe,aPerFec,cRoteiro)
		
		//Acumula  varias liquidaciones y solo aplica si usan la funci�n ObtAcuLSD() del 034 al 047
		If lAcumula  
		   aVerbasAFun	:= RetVerbas(SRA->RA_FILIAL,SRA->RA_MAT,aTmpConce,aPerAcAbe,aPerAcFec,cRoteiros)           
		Endif

		If !Empty(aVerbas) 
			If  nEmps != 0
				cLinea += CRLF
				FWrite(nArchTXT, cLinea)
				cLinea := ""
			Endif
			If  nIdenEnv == 1 //1- SJ  y 2=RE
				GrabaReg02(aRCCE)
				GrabaReg03(aVerbas)
			Endif
			GrabaReg04(aRCCE)
			nEmps += 1
			
			If  SRA->RA_MODALID == '102' //Trabajador Eventual
				aVerbasEve   := RetVerbas(SRA->RA_FILIAL,SRA->RA_MAT,aConcepEve,aPerAbe,aPerFec,cRoteiro)	
				GrabaReg05(aVerbasEve)
			Endif			
		EndIf
		
		SRA->(DbSkip())
	EndDo

	FClose (nArchTXT)
	nArchTXT := FT_FUse(cDirArch + "Original_" + cNomArch)
	FT_FGoTop()

	Do While !FT_FEOF()
		cLinea := FT_FReadLn()
		If  Substr(cLinea, 30, 6) == "#nEmp#"
			cLinea := Replace(cLinea, "#nEmp#", PADL(AllTrim(Str(nEmps)), 6, "0"))
		Else 
			cLinea := CRLF + cLinea	
		EndIf
		FWrite(nArchOK, cLinea)
		FT_FSKIP()
	EndDo

	FT_FUSE()
	FClose(nArchOK)
	If File(cDirArch + "Original_" + cNomArch)
		FErase(cDirArch + "Original_" + cNomArch)
	EndIf
	
Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �GrabaReg01 �Autor  �Luis Samaniego      �Fecha �  21/12/15   ���
��������������������������������������������������������������������������͹��
���Desc.     � Libro de Sueldo Digital - Detalle | Renglon 01              ���
��������������������������������������������������������������������������͹��
���Uso       � SIGAGPE                                                     ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function GrabaReg01()
	
	Local cLinea	:= ""
	Local aFilAtu	:= FWArrFilAtu()

	cLinea := "01"
	cLinea += PADL(STRTRAN(aFilAtu[18],"-",""), 11, " ")
	cLinea += IIf(nIdenEnv == 1,"SJ","RE")
	cLinea += cPeriod
	cLinea += IIf(nIdenEnv == 1,cTipoLiq,Space(len(cTipoLiq)))
	cLinea += IIf(nIdenEnv == 1,PADL(nNumLiq, 5, " "),Space(5)) 
	cLinea += IIf(nIdenEnv == 1,"30",Space(2))
	cLinea += "#nEmp#"
	cLinea += CRLF
	FWrite(nArchTXT, cLinea)
	cLinea := ""
	
Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �GrabaReg02 �Autor  �Luis Samaniego      �Fecha �  21/12/15   ���
��������������������������������������������������������������������������͹��
���Desc.     � Libro de Sueldo Digital - Detalle | Renglon 02              ���
��������������������������������������������������������������������������͹��
���Uso       � SIGAGPE                                                     ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function GrabaReg02(aRCCE)
	
	Local cLinea	:= ""
	Local cCanHrsT	:= "000"
	Local nPosS042	:= 22
	
	Default aRCCE	:= {}
	
	If  Len(aRCCE) > 0  .And. !Empty(aRCCE[nPosS042][2]) 
		cCanHrsT := PADL(&(aRCCE[nPosS042][2]), 3, "0")
	Endif

	cLinea := "02"
	cLinea += PADL(SRA->RA_CIC, 11, " ")
	cLinea += PADR(SRA->RA_MAT, 10, " ")
	cLinea += PADR("", 50, " ")
	cLinea += PADR(SRA->RA_CBU, 22, " ")
	cLinea += cCanHrsT
	cLinea += DTOS(dFchPago)
	cLinea += Space(8)
	cLinea += IIf(Empty(SRA->RA_CBU), "2", "3")
	cLinea += CRLF
	FWrite(nArchTXT, cLinea)
	cLinea := ""
	
Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �GrabaReg03 �Autor  �Luis Samaniego      �Fecha �  21/12/15   ���
��������������������������������������������������������������������������͹��
���Desc.     � Libro de Sueldo Digital - Detalle | Renglon 03              ���
��������������������������������������������������������������������������͹��
���Uso       � SIGAGPE                                                     ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function GrabaReg03(aVerbas)
	
	Local nLoop		:= 0
	Local nPos		:= 0
	Local cLinea	:= ""
	Local cIndDyC   := " "
	
	For nLoop := 1 To Len(aVerbas)
		nPos  := aScan( aConcepSRV,{|x| x[1] == aVerbas[nLoop][03]} )
		cLinea := "03"
		cLinea += PADL(SRA->RA_CIC, 11, " ")
		cLinea += PADR(aVerbas[nLoop][03], 10, " ")
		cLinea += PADL(STRTRAN(AllTrim(STRTRAN(Transform(aVerbas[nLoop][06], cPictHrs),",","")),".",""), 5, "0") 
		cLinea += " "
		cLinea += PADL(STRTRAN(AllTrim(STRTRAN(Transform(ABS(aVerbas[nLoop][07]), cPictVal),",","")),".",""), 15, "0")
		If  nPos > 0 
			cIndDyC := IIf(aConcepSRV[nPos][3] == "1",IIF(aVerbas[nLoop][07]>0,"C","D"),IIF(aVerbas[nLoop][07]<0,"C","D"))		
		Endif
		cLinea += cIndDyC
		cLinea += Space(6)
		cLinea += CRLF
		FWrite(nArchTXT, cLinea)
		cLinea := ""
	Next
	
Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �GrabaReg04 �Autor  �Luis Samaniego      �Fecha �  21/12/15   ���
��������������������������������������������������������������������������͹��
���Desc.     � Libro de Sueldo Digital - Detalle | Renglon 04              ���
��������������������������������������������������������������������������͹��
���Uso       � SIGAGPE                                                     ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function GrabaReg04(aRCCE)
	
	Local cFormE		:= ""
	Local cFormEOK		:= ""
	Local cLinea		:= ""
	Local nLoop			:= 0

	Private cMes		:= "" 
	Private cAno		:= ""
	Private xQtdParC
	Private xQtdParF
	Private aPerFec		:= {}
	Private aPerAbe		:= {}

	Private cSit1		:= ""
	Private cDiaSit1	:= ""
	Private cSit2		:= ""
	Private cDiaSit2	:= ""
	Private cSit3		:= ""
	Private cDiaSit3	:= ""
	Private aDatasSR8	:= {}
	
	//Variables utilizadas por otras rutinas
	Private dDtIngresso	:= Ctod("  /  /  ")
	Private dDtDespido	:= Ctod("  /  /  ")
	Private dDtUltAfas	:= Ctod("  /  /  ")
	Private aRCMFields	:= {} // Estrutura da tabela RCM - direto do arquivo DBF
	
	//Posicao dos campos da tabela RCM
	Private nPosRCMFil	:= 0
	Private nPosRCMPd	:= 0
	Private nPosRCMTip	:= 0
	Private nPosRCMSic	:= 0
	Private aQtdAus		:= {} //array contem a quantidade de dias para desconto do total de dias trabalhados Sicoss campo 041
	
	Default aRCCE		:= {}

	cAno := Substr(cPeriod,1,4)
	cMes := Substr(cPeriod,5,2)

	If Val(GRAUPAR("C",.T.)) == 0   				 
		xQtdParC := "0" 
	Else
		xQtdParC := GRAUPAR("C",.T.)			 	 
	Endif

	If Val(GRAUPAR("F",.T.)) == 0
		xQtdParF :=	 "00"		
	Else
		xQtdParF :=	GRAUPAR("F",.T.)			
	Endif

	aDatasSR8 := {}
	cSit1 := Space(02)
	cSit2 := Space(02)
	cSit3 := Space(02)

	cDiaSit1 := Space(02)
	cDiaSit2 := Space(02)
	cDiaSit3 := Space(02)

	For nLoop := 1 To Len(aRCCE)	
		If nLoop != 1
			cFormE := &(aRCCE[nLoop][2])
		Else
			cFormE := (aRCCE[nLoop][2])
		EndIf
		If Type("cFormE") == "N"	
			cFormEOK := Str(cFormE)
		Elseif Type("cFormE") == "D"
			cFormEOK := DtoC(cFormE)
		Else
			cFormEOK := cFormE
		EndIf
		If aRCCE[nLoop,4] > 0
			cLinea += PADR(cFormEOK,aRCCE[nLoop,4])
		Endif
	Next
	FWrite(nArchTXT, cLinea)
	cLinea := ""

Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �RetVerbas  �Autor  �Luis Samaniego      �Fecha �  21/12/15   ���
��������������������������������������������������������������������������͹��
���Desc.     � Regresa conceptos por empleado                              ���
��������������������������������������������������������������������������͹��
���Uso       � SIGAGPE                                                     ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function RetVerbas(cFil,cMat,aConceptos,aPerAbe,aPerFec,cLiquid)
	
	Local aVerbasFunc	:= {}
	Local nLoop			:= 0
	
	Default cFil 		:= ""
	Default cMat		:= ""
	Default aConceptos  := {}
	Default aPerAbe		:= {}
	Default aPerFec		:= {}	
	Default cLiquid		:= ""

	aVerbasFunc	:= RetornaVerbasFunc(	cFil,;			// Filial do funcionario corrente
										cMat,;			// Matricula do funcionario corrente
										NIL,;			// 
										cLiquid,;		// Roteiro selecionado na pergunte
										aConceptos,;	// aVerbasFilter
										aPerAbe,;		// Array com os Periodos e Numero de pagamento abertos
										aPerFec)		// Array com os Periodos e Numero de pagamento fechados

Return aVerbasFunc

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �GetConcep  �Autor  �Luis Samaniego      �Fecha �  21/12/15   ���
��������������������������������������������������������������������������͹��
���Desc.     � Obtiene conceptos a utilizar                                ���
��������������������������������������������������������������������������͹��
���Uso       � SIGAGPE                                                     ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function GetConcep(lEventual,aConcepEve)
	
	Local cFilSRV	:= xFilial("SRV")
	
	Default lEventual	:= .F.
	Default aConcepEve	:= {}
	
	SRV->(DBSetOrder(1)) //RV_FILIAL+RV_COD
	SRV->(MSSeek(cFilSRV))
	aConceptos := {}
	aConcepSRV := {}
	aConcepEve	:= {}
	aTmpConce	:= {}
	SRV->(DBEval( {|| IF(SRV->RV_TIPOCOD $ "1|2" .AND. !EMPTY(SRV->RV_CONAFIP), AAdd(aConceptos, {SRV->RV_COD}), NIL) }, {|| SRV->RV_FILIAL ==  cFilSRV} ) )
	SRV->(DBEval( {|| IF(SRV->RV_TIPOCOD $ "1|2" .AND. !EMPTY(SRV->RV_CONAFIP), AAdd(aConcepSRV, {SRV->RV_COD, RV_CONAFIP, RV_TIPOCOD}), NIL) }, {|| SRV->RV_FILIAL ==  cFilSRV} ) )
	If  lEventual  //Empleados eventuales: RV_TIPOCOD sea 1 - Remuneraci�n o 3 - Base (Remuneraci�n) y aplique para Eventuales (RV_LDSEVEN == "1")
		SRV->(DBEval( {|| IF(SRV->RV_TIPOCOD $ "1|3" .AND. SRV->RV_LSDEVEN == "1" , AAdd(aConcepEve, {SRV->RV_COD}), NIL) }, {|| SRV->RV_FILIAL ==  cFilSRV} ) )
	Endif
	
	SRV->(DBEval( {|| IF(SRV->RV_TIPOCOD $ "3|4" , AAdd(aTmpConce, {SRV->RV_COD}), NIL) }, {|| SRV->RV_FILIAL ==  cFilSRV} ) )
Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �GPER015Dir �Autor  �Luis Samaniego      �Fecha �  21/12/15   ���
��������������������������������������������������������������������������͹��
���Desc.     � Obtiene ruta donde sera creado archivo de texto             ���
��������������������������������������������������������������������������͹��
���Uso       � SIGAGPE                                                     ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function GPER015Dir(nOpc)
	
	Local lRuta	:= .F.
	Local cRuta	:= ""

	cRuta := cGetFile( '|(*.*)|' , STR0015, 0 , "C:\", .F., GETF_LOCALHARD + GETF_LOCALFLOPPY + GETF_RETDIRECTORY  ) //"Seleccione el directorio"
	If !Empty(cRuta)
		If nOpc = 1
			MV_PAR02 := cRuta
		Else
			MV_PAR08 := cRuta
		EndIf
		lRuta := .T.
	EndIf
	
Return lRuta

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �CreaArch   �Autor  �Luis Samaniego      �Fecha �  21/12/15   ���
��������������������������������������������������������������������������͹��
���Desc.     � Crea archivo de texto                                       ���
��������������������������������������������������������������������������͹��
���Uso       � SIGAGPE                                                     ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function CreaArch(cDir, cNomArch, cExt)
	
	Local nHdle		:= 0
	Local cDrive	:= ""
	Local cNewFile	:= cDir + cNomArch

	SplitPath(cNewFile,@cDrive,@cDir,@cNomArch,@cExt)
	cDir := cDrive + cDir
	Makedir(cDir)
	cNomArc := cDir + cNomArch + cExt   

	nHdle := FCreate (cNomArc,0)
	If nHdle == -1
		Aviso( OemToAnsi(STR0007), OemToAnsi(STR0008 + cNomArc), {STR0009} ) //"Atencion" - "No se pudo crear el archivo " - "OK"
	EndIf
	
Return nHdle

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
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function fVldNPgLi(nOpc)
	
	Local lRet		:= .T.
	Local cFilRCH	:= xFilial("RCH")

	DbSelectArea("RCH")
	RCH->(DbSetOrder(1)) //RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR
	If nOpc == 1
		If !Empty(AllTrim(MV_PAR04))
			If !RCH->(MSSeek(cFilRCH+MV_PAR02+MV_PAR03+MV_PAR04+MV_PAR01))
				lRet := .F.
				Alert(STR0010 + AllTrim(MV_PAR02) + STR0011 + AllTrim(MV_PAR01) + STR0012 + AllTrim(MV_PAR03) + STR0013 + AllTrim(MV_PAR04)) //"No existen datos para el Proceso " - " Procedimiento " - " con el Periodo " - " y Numero de Pago "
			EndIf
		Else
			lRet := .F.
			Alert(STR0014) //"Este dato debe informarse"
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
���Parametros�nOpc: 1 = Base, 2 = Control                                   ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function fVldPerLi(nOpc)
	
	Local lRet		:= .T.
	Local cFilRCH	:= xFilial("RCH")

	DbSelectArea("RCH")
	RCH->(DbSetOrder(4)) //RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG
	If nOpc == 1
		If !Empty(AllTrim(MV_PAR03))
			If !RCH->(MSSeek(cFilRCH+MV_PAR02+MV_PAR01+MV_PAR03))
				lRet := .F.
				Alert(STR0010 + AllTrim(MV_PAR02) + STR0011 + AllTrim(MV_PAR01) + STR0012 + AllTrim(MV_PAR03)) //"No existen datos para el Proceso " - " Procedimiento " - " con el Periodo "
			EndIf
		Else
			lRet := .F.
			Alert(STR0014) //"Este dato debe informarse"
		EndIf
	EndIf
	RCH->(dbCloseArea("RCH"))
	
Return lRet


/*/{Protheus.doc} CargaTabAl()
(Obtener el contenido de la tabla alfanumerica)
@type function
@author Laura Medina
@since 05/05/2022
@version 1.0
@param aRCCE, array, (Array para almacenar el contenido de la tabla)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function CargaTabAl(aRCCE,lAcumula)

	Local aArea			:= GetArea()	
	Local cFilRCB		:= xFilial("RCB")
	Local cFilRCC		:= xFilial("RCC")
	Local cNomeArq		:= "S042"
	Local cCpo			:= ""
	Local cFormula		:= ""
	Local cLectura		:= SPACE(1) 
	Local nInicio		:= 0
	Local nLongitude	:= 0
	Local nPoint		:= 0
	Local aPos			:= {,,,,}

	
	Default aRCCE		:= {}
	Default lAcumula	:= .F.

	DbSelectArea("RCB")
	RCB->(DbSetOrder(1)) //RCB_FILIAL+RCB_CODIGO
	nPoint := 1
	If RCB->(MSSeek(cFilRCB + cNomeArq))
		While cFilRCB == RCB->RCB_FILIAL .And. cNomeArq == RCB->RCB_CODIGO
			cCpo := AllTrim(RCB->RCB_CAMPOS)
			Do Case
				Case cCpo == "DESCRIPCIO"  
				aPos[1] := {nPoint, RCB_TAMAN}
				Case cCpo == "LECTURA"  
				aPos[2] := {nPoint, RCB_TAMAN}
				Case cCpo == "INICIO"  
				aPos[3] := {nPoint, RCB_TAMAN}
				Case cCpo == "LONGITUD"  
				aPos[4] := {nPoint, RCB_TAMAN}
				Case cCpo == "FORMULA"  
				aPos[5] := {nPoint, RCB_TAMAN}
			EndCase
			nPoint += RCB_TAMAN
			RCB->(DbSkip())
		EndDo
	EndIf

	DbSelectArea("RCC")
	RCC->(DbSetOrder(1)) //RCC_FILIAL+RCC_CODIGO+RCC_FIL+RCC_CHAVE+RCC_SEQUEN
	RCC->(MSSeek(cFilRCC+cNomeArq))
	Do While cFilRCC == RCC->RCC_FILIAL .And. cNomeArq == RCC->RCC_CODIGO
		cLectura	:= AllTrim(SubStr(RCC_CONTEU, aPos[2,1], aPos[2,2]))
		nInicio	:= Val(AllTrim(SubStr(RCC_CONTEU, aPos[3,1], aPos[3,2])))
		nLongitude	:= Val(AllTrim(SubStr(RCC_CONTEU, aPos[4,1], aPos[4,2])))
		cFormula	:= AllTrim(SubStr(RCC_CONTEU, aPos[5,1], aPos[5,2]))
		If  !lAcumula .And. ("OBTACULSD" $ UPPER(cFormula)) //Verificar si la formula usada acumula.
			lAcumula := .T.
		Endif
		AAdd(aRCCE,{cLectura,cFormula,nInicio,nLongitude})
		RCC->(DbSkip())	
	EndDo  

	RestArea(aArea)
	
Return

/*/{Protheus.doc} ObtRoteiros()
Obtener las liquidaciones que aplican para la acumulaci�n.
@type function
@author Laura Medina
@since 18/06/2022
@version 1.0
@param cOrdLSD, cCaracter, Orden para considerar en la acumulaci�n. 
@return cRoteiros,cCaracter, Liquidaciones a considerar
@example
(examples)
@see (links_or_references)
/*/
Static Function ObtRoteiros(cOrdLSD)
Local aAreaTmp	:= GetArea()
Local cTmpRCH	:= GetNextAlias()
Local cRoteiros	:= cRoteiro
Local cFilRCH	:= xFilial("RCH")
Local nLoop		:= 0

Default cOrdLSD	:= ""

	BeginSql alias cTmpRCH
		SELECT RCH.RCH_ROTEIR
		FROM %table:RCH% RCH
		WHERE RCH.RCH_FILIAL = %exp:cFilRCH% AND
			RCH.RCH_PROCES = %exp:cProcesso% AND
			RCH.RCH_PER = %exp:cPeriod% AND
			RCH.RCH_ORDLSD <> %exp:''% AND
			RCH.RCH_ORDLSD < %exp:cOrdLSD% AND
			RCH.%notDel%
		ORDER BY RCH.RCH_ORDLSD
	EndSql

DBSelectArea(cTmpRCH)
(cTmpRCH)->(DBGoTop())

While (cTmpRCH)->(!Eof())
	cRoteiros += "|" + (cTmpRCH)->RCH_ROTEIR 
	(cTmpRCH)->(DBSkip())
EndDo

(cTmpRCH)->(DbCloseArea())
RestArea(aAreaTmp)

Return cRoteiros
	

/*/{Protheus.doc} ObtPeriodos()
Obtener los periodos pero sin el numero de pago.
@type function
@author Laura Medina
@since 19/06/2022
@version 1.0
@param aPerAcAbe, array, copia del arreglo de periodos abiertos. 
@param aPerAcFec, array, copia del arreglo de periodos cerrados. 
@return variable, Tipo, Descripci�n
@example
(examples)
@see (links_or_references)
/*/
Static Function ObtPeriodos(aPerAcAbe,aPerAcFec)
Local aAreaTmp	:= GetArea()
Local nLoop		:= 0

Default aPerAcAbe := {}
Default aPerAcFec := {}

//Copia arreglos de periodos
aPerAcAbe := aPerAbe
aPerAcFec := aPerFec

//No aplica el numero de pago para la acumulaci�n (registro 4), se limpia la posici�n del arreglo.
If Len(aPerAcAbe) > 0
	For nLoop:= 1 to len (aPerAcAbe)
		aPerAcAbe[nLoop,2]:= ""  //No aplica nro de pago
	Next nLoop		
	If  Len(aPerAcFec) == 0
		aPerAcFec := aPerAcAbe
	Endif	
ElseIf Len(aPerAcFec) > 0
	For nLoop:= 1 to len (aPerAcFec)
		aPerAcFec[nLoop,2]:= ""  //No aplica nro de pago
	Next nLoop	
	If  Len(aPerAcAbe) == 0
		aPerAcAbe := aPerAcFec
	Endif		
Endif

RestArea(aAreaTmp)

Return 
	

/*/{Protheus.doc} ObtAcuLSD()
Obtener acumulado de las liquidaciones anteriores al orden.
@type function
@author Laura Medina
@since 18/06/2022
@version 1.0
@param cTipo, cCaracter, V o H= Valor u Horas. 
@return cVerba, cCaracter, Concepto.
@return nResult, numerico, Valos u Horas.
@example
(examples)
@see (links_or_references)
/*/
Function ObtAcuLSD(cTipo,cVerba)

Local aArea			:=	GetArea()
Local nResult		:= 0  
Local nX			:= 0 
Local nRetorno		:= 0
DEFAULT cTipo		:= NIL
DEFAULT cVerba		:= NIL

If (len(aVerbasAFun)>0) .AND. !empty(cVerba) .AND. !empty(cTipo) .AND. cTipo $ ("VH")
	For nX := 1 to Len(aVerbasAFun)
		nRetorno	:= aScan(aRoteiros,{|x|x[1]==aVerbasAFun[nX,11]})
		If aVerbasAFun[nX,3] == cVerba .and. nRetorno > 0
			If cTipo == "V"
				nResult +=  aVerbasAFun[nX,7]
			Else	
				nResult +=  aVerbasAFun[nX,6]
			Endif
	 	Endif
	Next nX                                      
EndIf

RestArea(aArea)
                                              
Return(nResult)


/*/{Protheus.doc} EmpEvent()
Verifica si se cuenta con empleados eventuales.
@type function
@author Laura Medina
@since 01/07/2022
@version 1.0
@param  variable, Tipo, Descripci�n
@return lRet, Logico, .T. si existen empleados eventuales, .F. NO existen.
@example
(examples)
@see (links_or_references)
/*/
Static Function EmpEvent()
Local aAreaTmp	:= GetArea()
Local cTmpSRA	:= GetNextAlias()
Local cEventual	:= '102'
Local lRet		:= .F.

	BeginSql alias cTmpSRA
		SELECT SRA.RA_MAT
		FROM %table:SRA% SRA
		WHERE SRA.RA_MODALID = %exp:cEventual% AND
			SRA.%notDel%
	EndSql

DBSelectArea(cTmpSRA)
(cTmpSRA)->(DBGoTop())

If  (cTmpSRA)->(!Eof())
	 lRet	:= .T.
Endif

(cTmpSRA)->(DbCloseArea())
RestArea(aAreaTmp)

Return lRet


/*/{Protheus.doc} GrabaReg05()
Genera el registro 05 para Empleados eventuales 
@type function
@author Laura Medina
@since 01/07/2022
@version 1.0
@param  variable, Tipo, Descripci�n
@return variable, Tipo, Descripci�n
@example
(examples)
@see (links_or_references)
/*/
Static Function GrabaReg05(aVerbasEve)	
Local cLinea	:= ""
Local cCatSQ3	:= ""
Local cPtoSQ3	:= ""
Local nLoop		:= 0
Local nRemunera	:= 0
Local nRetorno	:= 0

Default aVerbasEve	:= {}

	//Obtener el cargo y puesto para empleados eventuales	
	ObtCatyPto(SRA->RA_CARGO, @cCatSQ3, @cPtoSQ3)
	
	//Sumarizar los conceptos de remuneraci�n eventual
	If (len(aVerbasEve)>0)
		For nLoop := 1 to Len(aVerbasEve)
			nRetorno	:= aScan(aRoteiros,{|x|x[1]==aVerbasEve[nLoop,11]})
			If  nRetorno > 0
				nRemunera +=  aVerbasEve[nLoop,7]
		 	Endif
		Next nLoop                                      
	EndIf

	cLinea := CRLF
	cLinea += "05"
	cLinea += PADL(SRA->RA_CIC, 11, " ")
	cLinea += PADR(cCatSQ3, 6, " ")
	cLinea += PADR(cPtoSQ3, 4, " ")
	cLinea += DTOS(SRA->RA_ADMISSA)
	cLinea += DTOS(SRA->RA_DEMISSA)
	cLinea += PADL(STRTRAN(AllTrim(STRTRAN(Transform(ABS(nRemunera), cPictVal),",","")),".",""), 15, "0")
	cLinea += PADL(SRA->RA_RFCLAB, 11, " ")
	FWrite(nArchTXT, cLinea)
	cLinea := ""
	
Return

/*/{Protheus.doc} ObtCatyPto()
Obtener la categoria y el puesto AFIP.
@type function
@author Laura Medina
@since 01/07/2022
@version 1.0
@param  cCargo, caracter, cargo del empleado
@param  cCatSQ3, caracter, categoria AFIP
@param  cPtoSQ3, caracter, puesto AFIP
@return variable, Tipo, Descripci�n
@example
(examples)
@see (links_or_references)
/*/
Static Function ObtCatyPto(cCargo, cCatSQ3, cPtoSQ3)
Local aAreaTmp	:= GetArea()
Local cTmpSQ3	:= GetNextAlias()
Local cFilSQ3	:= xFilial("SQ3")

Default cCargo	:= ""
Default cCatSQ3	:= ""
Default cPtoSQ3	:= ""

	BeginSql alias cTmpSQ3
		SELECT SQ3.Q3_CATPROF, SQ3.Q3_PTODESE 
		FROM %table:SQ3% SQ3
		WHERE SQ3.Q3_FILIAL = %exp:cFilSQ3% AND 
			SQ3.Q3_CARGO = %exp:cCargo% AND
			SQ3.%notDel%
	EndSql

DBSelectArea(cTmpSQ3)
(cTmpSQ3)->(DBGoTop())

If  (cTmpSQ3)->(!Eof())
	cCatSQ3	:= (cTmpSQ3)->Q3_CATPROF
	cPtoSQ3	:= (cTmpSQ3)->Q3_PTODESE
Endif

(cTmpSQ3)->(DbCloseArea())
RestArea(aAreaTmp)

Return 
