#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FIVEWIN.CH'
#INCLUDE 'FISA814.CH'
#INCLUDE "FWLIBVERSION.CH"

#DEFINE _SEPARADOR "|"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FISA814    ºAutor³ Luis Samaniego     º Data ³  10/05/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Enviar informacoes de catalogos                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programador ³ Data   ³ BOPS/FNC  ³  Motivo da Alteracao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³A.Rodriguez ³17/04/18³DMINA-3107 ³Factura Electrónica Fac-e V2 Colombia³±±
±±³            ³        ³           ³Generación de tablas S0001 - S0016   ³±±
±±³LuisEnríquez³06/06/18³DMINA-2980 ³Se agrega generación de catálogo S015³±±
±±³            ³        ³           ³de Colonia para CFDI Com. Ext. (MEX) ³±±
±±³m.Camargo   ³06/04/18³DMINA-3465 ³En func f814CatMex se asigna la Tabla³±±
±±³            ³        ³(MEX)      ³alfanumérica S015 para el catálogo   ³±±
±±³            ³        ³           ³Tipo Cadena de pago                  ³±±
±±³            ³        ³           ³documenta STR0016 y 17 en f814CatMex ³±±
±±³Oscar Garcia³06/08/18³DMINA-3751 ³Se implementa uso de decodeutf al rea³±±
±±³            ³        ³           ³lizar la carga de catálogos SAT. Así ³±±
±±³            ³        ³           ³mismo si la conversión devuelve nil  ³±±
±±³            ³        ³           ³se toma la cadena tal como viene en  ³±±
±±³            ³        ³           ³el archivo CSV                       ³±±
±±³A.Rodriguez ³17/08/18³DMINA-3967 ³Factura Electrónica Fac-e V2 Colombia³±±
±±³            ³        ³           ³Tabla S0005 - Código a 5 caracteres  ³±±
±±³Oscar Garcia³28/08/18³DMINA-3765 ³En func f814CatMex se adicionan colu-³±±
±±³            ³        ³           ³nas para tabla S005 para patrón de   ³±±
±±³            ³        ³           ³Cta. Ordenante y Beneficiario        ³±±
±±³M.Camargo   ³26/10/18³DMINA-4575 ³Se incluye función f814catper para   ³±±
±±³            ³        ³           ³carga de Catalogos PERU UBL 2.1      ³±±
±±³LuisEnríquez³31/10/18³DMINA-4669 ³Se agrega carga de tabla S020 para   ³±±
±±³            ³        ³           ³carga de archivo 20TipoImpARetenerSRI³±±
±±³            ³        ³           ³de cód. de imp a retener  (EQU)      ³±±
±±³LuisEnríquez³08/08/19³DMINA-7002 ³Se realizan adecuaciones para proceso³±±
±±³            ³        ³           ³de FE Col. Val. Previa  (COL)        ³±±
±±³Alf. Medrano³04/12/19³DMINA-5912 ³Se incluye función f814catbol para   ³±±
±±³            ³        ³           ³carga de Catalogos Bolivia           ³±±
±±³LuisEnríquez³04/02/20³DMINA-8044 ³Se agrega catálogo para funcionalidad³±±
±±³            ³        ³           ³de referencias adicionales (COL)     ³±±
±±³LuisEnríquez³06/09/20³DMINA-9655 ³En func. f814ReadFile se corrige car-³±±
±±³            ³        ³           ³ga de descrip. con caracteres especi-³±±
±±³            ³        ³           ³ales (PER)                           ³±±
±±³ARodriguez  ³19/08/21³DMINA-12690³F814CatMex() Nuevo formato CP, cats. ³±±
±±³            ³        ³           ³Carta Porte S017-S027 (MEX)          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FISA814()
	Private cPath   := Alltrim(SuperGetMV("MV_PATH814",,"C:\Temp\FISA814\"))
	Private cLibVer := FWLibVersion() 

	If ( cPaisLoc == "MEX" )
		f814CatMex()
	ElseIf ( cPaisLoc == "COL" )
		f814CatCol()
	ElseIf ( cPaisLoc == "EQU" )
		f814CatEcu() //Generación de catálogos facturación electrónica Ecuador
	ElseIf ( cPaisLoc == "PER" )
		f814CatPer() //Generación de catálogos facturación electrónica Peru
	ElseIf ( cPaisLoc == "BOL" )
		f814CatBol() //Generación de catálogos facturación electrónica Bolivia
	ElseIf ( cPaisLoc == "PAR" )
		f814CatPar() //Generación de catálogos facturación electrónica Paraguay
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Gp310TABPTGºAutor³ Kelly Soares       º Data ³  30/06/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria e preenche tabelas auxiliares padroes.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PORTUGAL                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Rogerio     ³14/08/08³151449³Alteracao da GP310PTG p/preencher tabelas ³±±
±±³Melonio     ³        ³151451³padroes de Portugal-Relatorios Anuais.    ³±±
±±³            ³        ³151453³Quadro de Pessoal/Balanco Anual/Mod.10 IRS³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function f814CatMex()
Local nI		   :=	0
Local cAuxArch   := ""
Local aTamCpo    := {}

Private aTabela  := {}
Private cFilF3I  := xFilial("F3I")
Private cFilF3H  := xFilial("F3H")
Private cNomeArq :=	""


	DbSelectArea("F3H")
	F3H->(DbSetOrder(1))
	DbSelectArea("F3I")
	F3I->(DbSetOrder(1))

	/***	c_Aduana	***/
	cNomeArq := 'S001'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo de aduanas','01','Aduana' , 'Aduana'     ,'C', 2,0,'@!','NAOVAZIO()','','1'} )
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo de aduanas','02','Descrip', 'Descripción','C',60,0,'@!','NAOVAZIO()','','1'} )
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,60} //Tamaño de campos definidos en F3H
		cAuxArch := "c_Aduana.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0001, , .T. ) //"Catálogo de aduanas"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	Endif

	/***	c_ClaveProdServ	***/
	cNomeArq := 'S002'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo productos/servicios','01','Clave'  , 'ClaveProdServ','C', 8 ,0,'@!','NAOVAZIO()','','1'} )
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo productos/servicios','02','Descrip', 'Descripción'  ,'C',150,0,'@!','NAOVAZIO()','','1'} )
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {8,150} //Tamaño de campos definidos en F3H
		cAuxArch := "c_ClaveProdServ.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0002, , .T. ) //"Catálogo de Productos/Servicios"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	Endif

	/***	c_ClaveUnidad	***/
	cNomeArq := 'S003'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo unidades de medida','01','Clave'  , 'ClaveUnidad','C', 3 ,0,'@!','NAOVAZIO()','','1'} )
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo unidades de medida','02','Descrip', 'Descripción','C',100,0,'@!','NAOVAZIO()','','1'} )
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {3,100} //Tamaño de campos definidos en F3H
		cAuxArch := "c_ClaveUnidad.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0003, , .T. ) //"Catálogo de unidades de medida CFDi"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	Endif

	/***	c_CodigoPostal	***/
	cNomeArq := 'S004'
	cAuxArch := "c_CodigoPostal.csv"
	aTamCpo := {5,3,3,2,1,8,8,31,10,15,5,2,10,15,5,2} //Tamaño de campos definidos en F3H
	aSize(aTabela,0)
	aAdd( aTabela, { cFilF3H,cNomeArq,OemToAnsi(STR0004),'01',OemToAnsi(STR0019),OemToAnsi(STR0284),'C',aTamCpo[ 1],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de códigos postales"##"Codigo"##"Código Postal"
	aAdd( aTabela, { cFilF3H,cNomeArq,OemToAnsi(STR0004),'02',OemToAnsi(STR0268),OemToAnsi(STR0268),'C',aTamCpo[ 2],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de códigos postales"##"Estado"##"Estado"
	aAdd( aTabela, { cFilF3H,cNomeArq,OemToAnsi(STR0004),'03',OemToAnsi(STR0285),OemToAnsi(STR0270),'C',aTamCpo[ 3],0,'@!',''          ,'','' } )	//"Catálogo de códigos postales"##"Munic"##"Municipio"
	aAdd( aTabela, { cFilF3H,cNomeArq,OemToAnsi(STR0004),'04',OemToAnsi(STR0286),OemToAnsi(STR0267),'C',aTamCpo[ 4],0,'@!',''          ,'','' } )	//"Catálogo de códigos postales"##"Local"##"Localidad"
	aAdd( aTabela, { cFilF3H,cNomeArq,OemToAnsi(STR0004),'05',OemToAnsi(STR0287),OemToAnsi(STR0288),'C',aTamCpo[ 5],0,'@!',''          ,'','' } )	//"Catálogo de códigos postales"##"Estimulo"##"Estimulo F.F."
	aAdd( aTabela, { cFilF3H,cNomeArq,OemToAnsi(STR0004),'06',OemToAnsi(STR0224),OemToAnsi(STR0225),'D',aTamCpo[ 6],0,''  ,'NAOVAZIO()','','' } )	//"Catálogo de códigos postales"##"Inicio"##"Inicio Vigencia"
	aAdd( aTabela, { cFilF3H,cNomeArq,OemToAnsi(STR0004),'07',OemToAnsi(STR0226),OemToAnsi(STR0227),'D',aTamCpo[ 7],0,''  ,''          ,'','' } )	//"Catálogo de códigos postales"##"Fin"##"Fin Vigencia"
	aAdd( aTabela, { cFilF3H,cNomeArq,OemToAnsi(STR0004),'08',OemToAnsi(STR0289),OemToAnsi(STR0290),'C',aTamCpo[ 8],0,''  ,'NAOVAZIO()','','' } )	//"Catálogo de códigos postales"##"Horario"##"Huso Horario"
	aAdd( aTabela, { cFilF3H,cNomeArq,OemToAnsi(STR0004),'09',OemToAnsi(STR0291),OemToAnsi(STR0292),'C',aTamCpo[ 9],0,''  ,'NAOVAZIO()','','' } )	//"Catálogo de códigos postales"##"MesVer"##"Mes Verano"
	aAdd( aTabela, { cFilF3H,cNomeArq,OemToAnsi(STR0004),'10',OemToAnsi(STR0293),OemToAnsi(STR0294),'C',aTamCpo[10],0,''  ,'NAOVAZIO()','','' } )	//"Catálogo de códigos postales"##"DiaVer"##"Día Verano"
	aAdd( aTabela, { cFilF3H,cNomeArq,OemToAnsi(STR0004),'11',OemToAnsi(STR0295),OemToAnsi(STR0296),'C',aTamCpo[11],0,''  ,'NAOVAZIO()','','' } )	//"Catálogo de códigos postales"##"HoraVer"##"Hora Verano"
	aAdd( aTabela, { cFilF3H,cNomeArq,OemToAnsi(STR0004),'12',OemToAnsi(STR0297),OemToAnsi(STR0298),'C',aTamCpo[12],0,''  ,'NAOVAZIO()','','' } )	//"Catálogo de códigos postales"##"DifVer"##"Dif Verano"
	aAdd( aTabela, { cFilF3H,cNomeArq,OemToAnsi(STR0004),'13',OemToAnsi(STR0299),OemToAnsi(STR0300),'C',aTamCpo[13],0,''  ,'NAOVAZIO()','','' } )	//"Catálogo de códigos postales"##"MesInv"##"Mes Invierno"
	aAdd( aTabela, { cFilF3H,cNomeArq,OemToAnsi(STR0004),'14',OemToAnsi(STR0301),OemToAnsi(STR0302),'C',aTamCpo[14],0,''  ,'NAOVAZIO()','','' } )	//"Catálogo de códigos postales"##"DiaInv"##"Día Invierno"
	aAdd( aTabela, { cFilF3H,cNomeArq,OemToAnsi(STR0004),'15',OemToAnsi(STR0303),OemToAnsi(STR0304),'C',aTamCpo[15],0,''  ,'NAOVAZIO()','','' } )	//"Catálogo de códigos postales"##"HoraInv"##"Hora Invierno"
	aAdd( aTabela, { cFilF3H,cNomeArq,OemToAnsi(STR0004),'16',OemToAnsi(STR0305),OemToAnsi(STR0306),'C',aTamCpo[16],0,''  ,'NAOVAZIO()','','' } )	//"Catálogo de códigos postales"##"DifInv"##"Dif Invierno"

	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		F814ACTF3H(aTabela)
	Endif

	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0004, aTabela)

	/***	c_FormaPago	***/
	cNomeArq := 'S005'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo de formas de pago','01','FormaPago', 'FormaPago'   ,'C', 2, 0,'@!','NAOVAZIO()','','1'} )
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo de formas de pago','02','Descrip'  , 'Descripción' ,'C', 40,0,'@!','NAOVAZIO()','','1'} )
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo de formas de pago','03','PCtaOrd'  , 'PatronCuentaOrdenante' ,'C', 55,0,'@!',,'','1'} )
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo de formas de pago','04','PCtaBen'  , 'PatronCuentaBeneficiario' ,'C', 55,0,'@!',,'','1'} )
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,40} //Tamaño de campos definidos en F3H
		cAuxArch := "c_FormaPago.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0005, , .T. ) //"Catálogo de formas de pago"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	Endif

	/***	c_Impuesto	***/
	cNomeArq := 'S006'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo de impuestos','01','Impuesto', 'Impuesto'   ,'C', 3, 0,'@!','NAOVAZIO()','','1'} )
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo de impuestos','02','Descrip'  , 'Descripción' ,'C', 5,0,'@!','NAOVAZIO()','','1'} )
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {3,5} //Tamaño de campos definidos en F3H
		cAuxArch := "c_Impuesto.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0006, , .T. ) //"Catálogo de impuestos"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	Endif

	/***	c_MetodoPago	***/
	cNomeArq := 'S007'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo de Método de Pago','01','MetodoPago', 'MetodoPago'   ,'C', 3, 0,'@!','NAOVAZIO()','','1'} )
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo de Método de Pago','02','Descrip'  , 'Descripción'   ,'C', 35,0,'@!','NAOVAZIO()','','1'} )
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {3,35} //Tamaño de campos definidos en F3H
		cAuxArch := "c_MetodoPago.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0007, , .T. ) //"Catálogo de Método de Pago"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	Endif

	/***	c_Moneda	***/
	cNomeArq := 'S008'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo de moneda','01','Moneda'  , 'Moneda'       ,'C', 3, 0,'@!','NAOVAZIO()','','1'} )
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo de moneda','02','Descrip' , 'Descripción'  ,'C', 80,0,'@!','NAOVAZIO()','','1'} )
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {3,80} //Tamaño de campos definidos en F3H
		cAuxArch := "c_Moneda.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0008, , .T. ) //"Catálogo de moneda"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	Endif

	/***	c_Pais	***/
	cNomeArq := 'S009'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo de países','01','Pais'    , 'Pais'        ,'C', 3, 0,'@!','NAOVAZIO()','','1'} )
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo de países','02','Descrip' , 'Descripción' ,'C', 50,0,'@!','NAOVAZIO()','','1'} )
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {3,50} //Tamaño de campos definidos en F3H
		cAuxArch := "c_Pais.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0009, , .T. ) //"Catálogo de países"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	Endif

	/***	c_RegimenFiscal	***/
	cNomeArq := 'S010'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo de régimen fiscal','01','RegiFiscal' , 'RegimenFiscal' ,'C', 3, 0,'@!','NAOVAZIO()','','1'} )
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo de régimen fiscal','02','Descrip'    , 'Descripción'   ,'C', 80,0,'@!','NAOVAZIO()','','1'} )
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {3,80} //Tamaño de campos definidos en F3H
		cAuxArch := "c_RegimenFiscal.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0010, , .T. ) //"Catálogo de régimen fiscal"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	Endif

	/***	c_TipoDeComprobante	***/
	cNomeArq := 'S011'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo tipos de comprobante','01','TipoCompr' , 'TipoComprobante' ,'C', 1, 0,'@!','NAOVAZIO()','','1'} )
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo tipos de comprobante','02','Descrip'   , 'Descripción'     ,'C', 10,0,'@!','NAOVAZIO()','','1'} )
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {1,10} //Tamaño de campos definidos en F3H
		cAuxArch := "c_TipoDeComprobante.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0011, , .T. ) //"Catálogo de tipos de comprobante"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	Endif

	/***	c_TipoRelacion	***/
	cNomeArq := 'S012'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo tipos relación CFDI','01','TipoRelac' , 'TipoRelac'   ,'C', 2, 0,'@!','NAOVAZIO()','','1'} )
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo tipos relación CFDI','02','Descrip'   , 'Descripción' ,'C', 60,0,'@!','NAOVAZIO()','','1'} )
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,60} //Tamaño de campos definidos en F3H
		cAuxArch := "c_TipoRelacion.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0012, , .T. ) //"Catálogo de tipos de relación entre CFDI"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	Endif

	/***	c_UsoCFDI	***/
	cNomeArq := 'S013'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo uso de comprobantes','01','UsoCFDI' , 'UsoCFDI'     ,'C', 3, 0,'@!','NAOVAZIO()','','1'} )
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo uso de comprobantes','02','Descrip' , 'Descripción' ,'C', 90,0,'@!','NAOVAZIO()','','1'} )
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {3,90} //Tamaño de campos definidos en F3H
		cAuxArch := "c_UsoCFDI.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0013, , .T. ) //"Catálogo uso de comprobantes"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	Endif

	/***	c_FraccionArancelaria	***/
	cNomeArq := 'S014'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo Fraccion Arancelaria','01','FracAran' , 'FracAran'      ,'C', 8  , 0,'@!','NAOVAZIO()','','1'} )
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo Fraccion Arancelaria','02','UnidMedi' , 'Unidad Medida' ,'C', 2   , 0,'@!','NAOVAZIO()','','1'} )
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo Fraccion Arancelaria','03','Imp'      , 'Imp.'          ,'C', 5   , 0,'@!','','','1'} )
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo Fraccion Arancelaria','04','Exp'      , 'Exp.'          ,'C', 10  , 0,'@!','','','1'} )
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo Fraccion Arancelaria','05','Descrip'  , 'Descripción'   ,'C', 150 , 0,'@!','','','1'} )
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo Fraccion Arancelaria','06','NICO'  	  , 'Num.Ident.Comer','C', 2  , 0,'@!','','','1'} )
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {8,2,5,10,150,2} //Tamaño de campos definidos en F3H
		cAuxArch := "c_FraccionArancelaria.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0053, , .T. ) //"Catálogo Fracción Arancelaria"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	Endif

	/***	c_Colonia	***/
	cNomeArq := 'S015'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo de Colonias','01','Clave'  ,'Clave colonia' ,'C', 4, 0,'@!','NAOVAZIO()','','1'} )
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo de Colonias','02','CP'     ,'Código postal','C', 5, 0,'@!','NAOVAZIO()','','1'} )
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo de Colonias','03','Nombre' ,'Nombre'       ,'C', 50,0,'@!','NAOVAZIO()','','1'} )
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {4,5,50} //Tamaño de campos definidos en F3H
		cAuxArch := "c_Colonia.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0054, , .T. ) //"Catálogo de Colonias"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/***	c_TipoCadenaPago	***/
	cNomeArq := 'S016'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo Tipo Cadena de Pago','01','Cadena'  ,'Tipo Cadena' ,'C', 2, 0,'@!','NAOVAZIO()','','1'} )
		aAdd( aTabela, { cFilF3H,cNomeArq,'Catálogo Tipo Cadena de Pago','02','Descrip'  ,'Descripción','C', 90, 0,'@!','NAOVAZIO()','','1'} )
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,90} //Tamaño de campos definidos en F3H
		cAuxArch := "c_TipoCadenaPago.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0016, , .T. )  //Catálogo Tipo Cadena de Pago
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch)	//"No se encontró el archivo"
		EndIf
	Endif

	/***	c_CveTransporte	***/
	cNomeArq := 'S017'
	cAuxArch := "c_CveTransporte.csv"
	aTamCpo  := {2,30,8,8}
	aSize(aTabela,0)
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0221),'01',OemToAnsi(STR0222),OemToAnsi(STR0223),'C',aTamCpo[1],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Clave de Transporte"##"Transp"##"Clave de Transporte"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0221),'02',OemToAnsi(STR0021),OemToAnsi(STR0022),'C',aTamCpo[2],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Clave de Transporte"##"Descrip"##"Descripción"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0221),'03',OemToAnsi(STR0224),OemToAnsi(STR0225),'D',aTamCpo[3],0,''  ,'NAOVAZIO()','','' } )	//"Catálogo de Clave de Transporte"##"Inicio"##"Inicio Vigencia"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0221),'04',OemToAnsi(STR0226),OemToAnsi(STR0227),'D',aTamCpo[4],0,''  ,''          ,'','' } )	//"Catálogo de Clave de Transporte"##"Fin"##"Fin Vigencia"

	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		F814ACTF3H(aTabela)
	Endif

	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0221, aTabela) //"Catálogo de Clave de Transporte"

	/***	c_TipoEstacion	***/
	cNomeArq := 'S018'
	cAuxArch := "c_TipoEstacion.csv"
	aTamCpo  := {2,30,30,8,8}
	aSize(aTabela,0)
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0228),'01',OemToAnsi(STR0229),OemToAnsi(STR0230),'C',aTamCpo[1],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Tipo de Estación"##"Estacion"##"Clave de Estación"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0228),'02',OemToAnsi(STR0021),OemToAnsi(STR0022),'C',aTamCpo[2],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Tipo de Estación"##"Descrip"##"Descripción"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0228),'03',OemToAnsi(STR0222),OemToAnsi(STR0223),'C',aTamCpo[3],0,'@!','NAOVAZIO()','','' } )	//"Catálogo de Tipo de Estación"##"Transp"##"Clave de Transporte"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0228),'04',OemToAnsi(STR0224),OemToAnsi(STR0225),'D',aTamCpo[4],0,''  ,'NAOVAZIO()','','' } )	//"Catálogo de Tipo de Estación"##"Inicio"##"Inicio Vigencia"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0228),'05',OemToAnsi(STR0226),OemToAnsi(STR0227),'D',aTamCpo[5],0,''  ,''          ,'','' } )	//"Catálogo de Tipo de Estación"##"Fin"##"Fin Vigencia"

	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		F814ACTF3H(aTabela)
	Endif

	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0228, aTabela) //"Catálogo de Tipo de Estación"

	/***	c_ClaveProdServCP	***/
	cNomeArq := 'S019'
	cAuxArch := "c_ClaveProdServCP.csv"
	aTamCpo  := {8,100,80,3,8,8}
	aSize(aTabela,0)
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0231),'01',OemToAnsi(STR0232),OemToAnsi(STR0233),'C',aTamCpo[1],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Producto/Servicio CP"##"Producto"##"Clave Producto"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0231),'02',OemToAnsi(STR0021),OemToAnsi(STR0022),'C',aTamCpo[2],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Producto/Servicio CP"##"Descrip"##"Descripción"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0231),'03',OemToAnsi(STR0234),OemToAnsi(STR0235),'C',aTamCpo[3],0,'@!',''          ,'','1'} )	//"Catálogo de Producto/Servicio CP"##"Palabras"##"Palabras Similares"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0231),'04',OemToAnsi(STR0236),OemToAnsi(STR0237),'C',aTamCpo[4],0,''  ,'NAOVAZIO()','','' } )	//"Catálogo de Producto/Servicio CP"##"Peligroso"##"Material Peligroso" // Debería ser long: 1 y valida: Pertence("01")
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0231),'05',OemToAnsi(STR0224),OemToAnsi(STR0225),'D',aTamCpo[5],0,''  ,'NAOVAZIO()','','' } )	//"Catálogo de Producto/Servicio CP"##"Inicio"##"Inicio Vigencia"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0231),'06',OemToAnsi(STR0226),OemToAnsi(STR0227),'D',aTamCpo[6],0,''  ,''          ,'','' } )	//"Catálogo de Producto/Servicio CP"##"Fin"##"Fin Vigencia"

	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		F814ACTF3H(aTabela)
	Endif

	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0231, aTabela) //"Catálogo de Producto/Servicio CP"

	/***	c_MaterialPeligroso	***/
	cNomeArq := 'S020'
	cAuxArch := "c_MaterialPeligroso.csv"
	aTamCpo  := {5,120,5,3,3,3,6,4,20,16,16,16,8,8} // Máximos en CatalogosCartaPorte.xls: {5,100,5,15,3,60,35,35,70,25,15,25,8,8}
	aSize(aTabela,0)
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0238),'01',OemToAnsi(STR0239),OemToAnsi(STR0237),'C',aTamCpo[1 ],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Material Peligroso"##"Material"##"Material Peligroso"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0238),'02',OemToAnsi(STR0021),OemToAnsi(STR0022),'C',aTamCpo[2 ],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Material Peligroso"##"Descrip"##"Descripción"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0238),'03',OemToAnsi(STR0240),OemToAnsi(STR0241),'C',aTamCpo[3 ],0,'@!',''          ,'','' } )	//"Catálogo de Material Peligroso"##"Clase"##"Clase o Div."
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0238),'04',OemToAnsi(STR0242),OemToAnsi(STR0243),'C',aTamCpo[4 ],0,'@!',''          ,'','' } )	//"Catálogo de Material Peligroso"##"Secundario"##"Peligro Secundario"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0238),'05',OemToAnsi(STR0244),OemToAnsi(STR0245),'C',aTamCpo[5 ],0,'@!',''          ,'','' } )	//"Catálogo de Material Peligroso"##"Grupo"##"Grupo emb/env ONU"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0238),'06',OemToAnsi(STR0246),OemToAnsi(STR0247),'C',aTamCpo[6 ],0,'@!',''          ,'','' } )	//"Catálogo de Material Peligroso"##"Disp"##"Disp. Espec."
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0238),'07',OemToAnsi(STR0248),OemToAnsi(STR0249),'C',aTamCpo[7 ],0,'@!',''          ,'','' } )	//"Catálogo de Material Peligroso"##"CantLim"##"Cantidad Limitadas"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0238),'08',OemToAnsi(STR0250),OemToAnsi(STR0251),'C',aTamCpo[8 ],0,'@!',''          ,'','' } )	//"Catálogo de Material Peligroso"##"CantExcep"##"Cantidad Exceptuadas"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0238),'09',OemToAnsi(STR0252),OemToAnsi(STR0253),'C',aTamCpo[9 ],0,'@!',''          ,'','' } )	//"Catálogo de Material Peligroso"##"EmbInst"##"Embalajes Inst."
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0238),'10',OemToAnsi(STR0254),OemToAnsi(STR0255),'C',aTamCpo[10],0,'@!',''          ,'','' } )	//"Catálogo de Material Peligroso"##"EmbDist"##"Embalajes Disp. Espec."
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0238),'11',OemToAnsi(STR0256),OemToAnsi(STR0257),'C',aTamCpo[11],0,'@!',''          ,'','' } )	//"Catálogo de Material Peligroso"##"CistInst"##"Cisternas Inst.de Transp."
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0238),'12',OemToAnsi(STR0258),OemToAnsi(STR0259),'C',aTamCpo[12],0,'@!',''          ,'','' } )	//"Catálogo de Material Peligroso"##"CistDist"##"Cisternas Disp. Espec."
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0238),'13',OemToAnsi(STR0224),OemToAnsi(STR0225),'D',aTamCpo[13],0,''  ,'NAOVAZIO()','','' } )	//"Catálogo de Material Peligroso"##"Inicio"##"Inicio Vigencia"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0238),'14',OemToAnsi(STR0226),OemToAnsi(STR0227),'D',aTamCpo[14],0,''  ,''          ,'','' } )	//"Catálogo de Material Peligroso"##"Fin"##"Fin Vigencia"

	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		F814ACTF3H(aTabela)
	Endif

	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0238, aTabela) //"Catálogo de Material Peligroso"

	/***	c_TipoEmbalaje	***/
	cNomeArq := 'S021'
	cAuxArch := "c_TipoEmbalaje.csv"
	aTamCpo  := {5,100,8,8}
	aSize(aTabela,0)
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0260),'01',OemToAnsi(STR0261),OemToAnsi(STR0262),'C',aTamCpo[1],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Tipos de Embalaje"##"Embalaje"##"Clave de Designación"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0260),'02',OemToAnsi(STR0021),OemToAnsi(STR0022),'C',aTamCpo[2],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Tipos de Embalaje"##"Descrip"##"Descripción"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0260),'03',OemToAnsi(STR0224),OemToAnsi(STR0225),'D',aTamCpo[3],0,''  ,'NAOVAZIO()','','' } )	//"Catálogo de Tipos de Embalaje"##"Inicio"##"Inicio Vigencia"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0260),'04',OemToAnsi(STR0226),OemToAnsi(STR0227),'D',aTamCpo[4],0,''  ,''          ,'','' } )	//"Catálogo de Tipos de Embalaje"##"Fin"##"Fin Vigencia"

	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		F814ACTF3H(aTabela)
	Endif

	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0260, aTabela) //"Catálogo de Tipos de Embalaje"

	/***	c_TipoPermiso	***/
	cNomeArq := 'S022'
	cAuxArch := "c_TipoPermiso.csv"
	aTamCpo  := {6,100,10,8,8}
	aSize(aTabela,0)
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0263),'01',OemToAnsi(STR0264),OemToAnsi(STR0265),'C',aTamCpo[1],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Tipos de Permiso"##"Permiso"##"Tipo de Permiso"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0263),'02',OemToAnsi(STR0021),OemToAnsi(STR0022),'C',aTamCpo[2],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Tipos de Permiso"##"Descrip"##"Descripción"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0263),'03',OemToAnsi(STR0222),OemToAnsi(STR0223),'C',aTamCpo[3],0,'@!','NAOVAZIO()','','' } )	//"Catálogo de Tipos de Permiso"##"Transp"##""Clave de Transporte"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0263),'04',OemToAnsi(STR0224),OemToAnsi(STR0225),'D',aTamCpo[4],0,''  ,'NAOVAZIO()','','' } )	//"Catálogo de Tipos de Permiso"##"Inicio"##"Inicio Vigencia"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0263),'05',OemToAnsi(STR0226),OemToAnsi(STR0227),'D',aTamCpo[5],0,''  ,''          ,'','' } )	//"Catálogo de Tipos de Permiso"##"Fin"##"Fin Vigencia"

	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		F814ACTF3H(aTabela)
	Endif

	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0263, aTabela) //"Catálogo de Tipos de Permiso"

	/***	c_Localidad	***/
	cNomeArq := 'S023'
	cAuxArch := "c_Localidad.csv"
	aTamCpo  := {2,3,40}
	aSize(aTabela,0)
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0266),'01',OemToAnsi(STR0267),OemToAnsi(STR0267),'C',aTamCpo[1],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Localidades"##"Localidad"##"Localidad"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0266),'02',OemToAnsi(STR0268),OemToAnsi(STR0268),'C',aTamCpo[2],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Localidades"##"Estado"##"Estado"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0266),'03',OemToAnsi(STR0021),OemToAnsi(STR0022),'C',aTamCpo[3],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Localidades"##"Descrip"##"Descripción"

	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		F814ACTF3H(aTabela)
	Endif

	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0266, aTabela) //"Catálogo de Localidades"

	/***	c_Municipio	***/
	cNomeArq := 'S024'
	cAuxArch := "c_Municipio.csv"
	aTamCpo  := {3,3,40}
	aSize(aTabela,0)
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0269),'01',OemToAnsi(STR0270),OemToAnsi(STR0270),'C',aTamCpo[1],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Municipios"##"Municipio"##"Municipio"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0269),'02',OemToAnsi(STR0268),OemToAnsi(STR0268),'C',aTamCpo[2],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Municipios"##"Estado"##"Estado"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0269),'03',OemToAnsi(STR0021),OemToAnsi(STR0022),'C',aTamCpo[3],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Municipios"##"Descrip"##"Descripción"

	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		F814ACTF3H(aTabela)
	Endif

	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0269, aTabela) //"Catálogo de Municipios"

	/***	c_Estado	***/
	cNomeArq := 'S025'
	cAuxArch := "c_Estado.csv"
	aTamCpo  := {3,3,40}
	aSize(aTabela,0)
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0271),'01',OemToAnsi(STR0268),OemToAnsi(STR0268),'C',aTamCpo[1],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Estados"##"Estado"##"Estado"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0271),'02',OemToAnsi(STR0272),OemToAnsi(STR0273),'C',aTamCpo[2],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Estados"##"Pais"##"País"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0271),'03',OemToAnsi(STR0021),OemToAnsi(STR0022),'C',aTamCpo[3],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Estados"##"Descrip"##"Descripción"

	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		F814ACTF3H(aTabela)
	Endif

	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0271, aTabela) //"Catálogo de Estados"

	/***	c_ConfigAutotransporte	***/
	cNomeArq := 'S026'
	cAuxArch := "c_ConfigAutotransporte.csv"
	aTamCpo  := {7,155,2,6,8,8}
	aSize(aTabela,0)
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0274),'01',OemToAnsi(STR0275),OemToAnsi(STR0276),'C',aTamCpo[1],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Configuración Autotransporte Federal"##"Clave"##"Clave Nomenclatura"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0274),'02',OemToAnsi(STR0021),OemToAnsi(STR0022),'C',aTamCpo[2],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Configuración Autotransporte Federal"##"Descrip"##"Descripción"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0274),'03',OemToAnsi(STR0277),OemToAnsi(STR0278),'C',aTamCpo[3],0,'@!',''          ,'','' } )	//"Catálogo de Configuración Autotransporte Federal"##"Ejes"##"Número de Ejes"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0274),'04',OemToAnsi(STR0279),OemToAnsi(STR0280),'C',aTamCpo[4],0,'@!',''          ,'','' } )	//"Catálogo de Configuración Autotransporte Federal"##"Llantas"##"Número de Llantas"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0274),'05',OemToAnsi(STR0224),OemToAnsi(STR0225),'D',aTamCpo[5],0,''  ,'NAOVAZIO()','','' } )	//"Catálogo de Configuración Autotransporte Federal"##"Inicio"##"Inicio Vigencia"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0274),'06',OemToAnsi(STR0226),OemToAnsi(STR0227),'D',aTamCpo[6],0,''  ,''          ,'','' } )	//"Catálogo de Configuración Autotransporte Federal"##"Fin"##"Fin Vigencia"

	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		F814ACTF3H(aTabela)
	Endif

	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0274, aTabela) //"Catálogo de Configuración Autotransporte Federal"

	/***	c_SubTipoRem	***/
	cNomeArq := 'S027'
	cAuxArch := "c_SubTipoRem.csv"
	aTamCpo  := {6,40,8,8}
	aSize(aTabela,0)
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0281),'01',OemToAnsi(STR0282),OemToAnsi(STR0283),'C',aTamCpo[1],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Tipos de Remolque"##"Remolque"##"Tipo de Remolque"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0281),'02',OemToAnsi(STR0021),OemToAnsi(STR0022),'C',aTamCpo[2],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Tipos de Remolque"##"Descrip"##"Descripción"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0281),'03',OemToAnsi(STR0224),OemToAnsi(STR0225),'D',aTamCpo[3],0,''  ,'NAOVAZIO()','','' } )	//"Catálogo de Tipos de Remolque"##"Inicio"##"Inicio Vigencia
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0281),'04',OemToAnsi(STR0226),OemToAnsi(STR0227),'D',aTamCpo[4],0,''  ,''          ,'','' } )	//"Catálogo de Tipos de Remolque"##"Fin"##"Fin Vigencia"

	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		F814ACTF3H(aTabela)
	Endif

	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0281, aTabela) //"Catálogo de Tipos de Remolque"

	/***	c_ParteTransporte	***/
	
	cNomeArq := 'S028'
	cAuxArch := "c_ParteTransporte.csv"
	aTamCpo  := {4,30}
	aSize(aTabela,0)
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0319),'01',OemToAnsi(STR0019),OemToAnsi(STR0020),'C',aTamCpo[1],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Partes del Transporte"##"Codigo"##"Código"
	aAdd( aTabela, { cFilF3H,cNomeArq, OemToAnsi(STR0319),'02',OemToAnsi(STR0021),OemToAnsi(STR0022),'C',aTamCpo[2],0,'@!','NAOVAZIO()','','1'} )	//"Catálogo de Partes del Transporte"##"Descrip"##"Descripción"

	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		F814ACTF3H(aTabela)
	Endif

	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0319, aTabela) //"Catálogo de Partes del Transporte"
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ f814CatCol ºAutor³ A.Rodriguez        º Data ³  16/04/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria e preenche tabelas auxiliares padroes.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ COLOMBIA                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function f814CatCol()
	Local cAuxArch		:= ""
	Local aTamCpo		:= {}

	Private aTabela		:= {}
	Private cFilF3I		:= xFilial("F3I")
	Private cFilF3H		:= xFilial("F3H")
	Private cNomeArq	:= ""

	DbSelectArea("F3H")
	F3H->(DbSetOrder(1)) //F3H_FILIAL + F3H_CODIGO
	DbSelectArea("F3I")
	F3I->(DbSetOrder(1)) //F3I_FILIAL + F3I_CODIGO + F3I_SEQUEN

	/***	01TiposFactura	***/
	cNomeArq := 'S001'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0018,'01',STR0019,STR0020,'C', 1,0,'@!','NAOVAZIO()','','1'} ) //"Tipos de Factura" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0018,'02',STR0021,STR0022,'C',30,0,'@!','NAOVAZIO()','','1'} ) //"Tipos de Factura" //"Descrip" "Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {1,30} //Tamaño de campos definidos en F3H
		cAuxArch := "01TiposFactura.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0017, , .T. ) //"Catálogo de Tipos de Factura"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/***	02TiposDocIdentidad	***/
	cNomeArq := 'S002'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0024,'01',STR0019,STR0020,'C', 7,0,'@!','NAOVAZIO()','','1'} ) //"Tipos de Docs de Identidad" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0024,'02',STR0021,STR0022,'C',40,0,'@!','NAOVAZIO()','','1'} ) //"Tipos de Docs de Identidad" //"Descrip" "Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {7,40} //Tamaño de campos definidos en F3H
		cAuxArch := "02TiposDocIdentidad.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0023, , .T. ) //"Catálogo de Tipos de Documentos de Identidad"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/***	03ConceptoNotasCredito	***/
	cNomeArq := 'S003'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0026,'01',STR0019,STR0020,'C', 1,0,'@!','NAOVAZIO()','','1'} ) //"Conceptos de Notas de Crédito" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0026,'02',STR0021,STR0022,'C',80,0,'@!','NAOVAZIO()','','1'} ) //"Conceptos de Notas de Crédito" //"Descrip" "Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {1,80} //Tamaño de campos definidos en F3H
		cAuxArch := "03ConceptoNotasCredito.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0025, , .T. ) //"Catálogo de Conceptos de Notas de Crédito"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/***	04ConceptoNotasDebito	***/
	cNomeArq := 'S004'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0028,'01',STR0019,STR0020,'C', 1,0,'@!','NAOVAZIO()','','1'} ) //"Conceptos de Notas de Débito" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0028,'02',STR0021,STR0022,'C',30,0,'@!','NAOVAZIO()','','1'} ) //"Conceptos de Notas de Débito" //"Descrip" "Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {1,30} //Tamaño de campos definidos en F3H
		cAuxArch := "04ConceptoNotasDebito.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0027, , .T. ) //"Catálogo de Conceptos de Notas de Débito"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/***	05ImpuestosFE	***/
	cNomeArq := 'S005'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0030,'01',STR0019,STR0020,'C', 3,0,'@!','NAOVAZIO()','','1'} ) //"Impuestos Factura Electrónica" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0030,'02',STR0021,STR0022,'C',80,0,'@!','NAOVAZIO()','','1'} ) //"Impuestos Factura Electrónica" //"Descrip" "Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {3,80} //Tamaño de campos definidos en F3H
		cAuxArch := "05ImpuestosFE.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0029, , .T. ) //"Catálogo de Impuestos en la Factura Electrónica"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/***	06MediosPago	***/
	cNomeArq := 'S006'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0032,'01',STR0019,STR0020,'C', 2,0,'@!','NAOVAZIO()','','1'} ) //"Medios de Pago" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0032,'02',STR0021,STR0022,'C',30,0,'@!','NAOVAZIO()','','1'} ) //"Medios de Pago" //"Descrip" "Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,30} //Tamaño de campos definidos en F3H
		cAuxArch := "06MediosPago.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0031, , .T. ) //"Catálogo de Medios de Pago"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/***	07Monedas	***/
	cNomeArq := 'S007'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0034,'01',STR0019,STR0020,'C', 3,0,'@!','NAOVAZIO()','','1'} ) //"Monedas" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0034,'02',STR0021,STR0022,'C',40,0,'@!','NAOVAZIO()','','1'} ) //"Monedas" //"Descrip" "Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {3,40} //Tamaño de campos definidos en F3H
		cAuxArch := "07Monedas.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0033, , .T. ) //"Catálogo de Monedas"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/***	08Paises	***/
	cNomeArq := 'S008'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0036,'01',STR0019,STR0020,'C', 2,0,'@!','NAOVAZIO()','','1'} ) //"Países" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0036,'02',STR0021,STR0022,'C',60,0,'@!','NAOVAZIO()','','1'} ) //"Países" //"Descrip" "Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,60} //Tamaño de campos definidos en F3H
		cAuxArch := "08Paises.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0035, , .T. ) //"Catálogo de Países"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/***	09TiposOrganizacionJuridica	***/
	cNomeArq := 'S009'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0038,'01',STR0019,STR0020,'C', 1,0,'@!','NAOVAZIO()','','1'} ) //"Tipos de Org Jurídica; Adquir." //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0038,'02',STR0021,STR0022,'C',30,0,'@!','NAOVAZIO()','','1'} ) //"Tipos de Org Jurídica; Adquir." //"Descrip" "Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {1,30} //Tamaño de campos definidos en F3H
		cAuxArch := "09TiposOrganizacionJuridica.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0037, , .T. ) //"Catálogo de Tipos de Organización Jurídica; Adquiriente"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/***	10TiposRegimen	***/
	cNomeArq := 'S010'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0040,'01',STR0019,STR0020,'C', 2,0,'@!','NAOVAZIO()','','1'} ) //"Tipos de Régimen IVA" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0040,'02',STR0021,STR0022,'C',30,0,'@!','NAOVAZIO()','','1'} ) //"Tipos de Régimen IVA" //"Descrip" "Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,30} //Tamaño de campos definidos en F3H
		cAuxArch := "10TiposRegimen.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0039, , .T. ) //"Catálogo de Tipos de Régimen"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/***	11Incoterms	***/
	cNomeArq := 'S011'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0042,'01',STR0019,STR0020,'C', 3,0,'@!','NAOVAZIO()','','1'} ) //"Incoterms" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0042,'02',STR0021,STR0022,'C',60,0,'@!','NAOVAZIO()','','1'} ) //"Incoterms" //"Descrip" "Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {3,60} //Tamaño de campos definidos en F3H
		cAuxArch := "11Incoterms.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0041, , .T. ) //"Catálogo de Incoterms"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/***	12TiposPago	***/
	cNomeArq := 'S012'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0044,'01',STR0019,STR0020,'C', 2,0,'@!','NAOVAZIO()','','1'} ) //"Tipos de Pago" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0044,'02',STR0021,STR0022,'C',30,0,'@!','NAOVAZIO()','','1'} ) //"Tipos de Pago" //"Descrip" "Descripción"
		F814ACTF3H(aTabela)
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,30} //Tamaño de campos definidos en F3H
		cAuxArch := "12TiposPago.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0043, , .T. ) //"Catálogo de Tipos de Pago"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	Endif

	/***	13TiposRepresentacion	***/
	cNomeArq := 'S013'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0046,'01',STR0019,STR0020,'C', 7,0,'@!','NAOVAZIO()','','1'} ) //"Tipos de Representación" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0046,'02',STR0021,STR0022,'C',60,0,'@!','NAOVAZIO()','','1'} ) //"Tipos de Representación" //"Descrip" "Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {7,60} //Tamaño de campos definidos en F3H
		cAuxArch := "13TiposRepresentacion.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0045, , .T. ) //"Catálogo de Tipos de Representación"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/***	14TiposObligacionesResp	***/
	cNomeArq := 'S014'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0048,'01',STR0019,STR0020,'C', 4,0,'@!','NAOVAZIO()','','1'} ) //"Tipos de Obligaciones-Respon." //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0048,'02',STR0021,STR0022,'C',80,0,'@!','NAOVAZIO()','','1'} ) //"Tipos de Obligaciones-Respon." //"Descrip" "Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {4,80} //Tamaño de campos definidos en F3H
		cAuxArch := "14TiposObligacionesResp.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0047, , .T. ) //"Catálogo de Tipos de Obligaciones-Responsabilidades"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/***	15TiposUsuariosAduaneros	***/
	cNomeArq := 'S015'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0050,'01',STR0019,STR0020,'C',  4,0,'@!','NAOVAZIO()','','1'} ) //"Tipos de Usuarios Aduaneros" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0050,'02',STR0021,STR0022,'C',100,0,'@!','NAOVAZIO()','','1'} ) //"Tipos de Usuarios Aduaneros" //"Descrip" "Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {4,100} //Tamaño de campos definidos en F3H
		cAuxArch := "15TiposUsuariosAduaneros.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0049, , .T. ) //"Catálogo de Tipos de Usuarios Aduaneros"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/***	16TiposEstablecimientos	***/
	cNomeArq := 'S016'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0052,'01',STR0019,STR0020,'C', 4,0,'@!','NAOVAZIO()','','1'} ) //"Tipos de Establecimientos" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0052,'02',STR0021,STR0022,'C',80,0,'@!','NAOVAZIO()','','1'} ) //"Tipos de Establecimientos" //"Descrip" "Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {4,80} //Tamaño de campos definidos en F3H
		cAuxArch := "16TiposEstablecimientos.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0051, , .T. ) //"Catálogo de Tipos de Establecimientos"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/***	17TiposOperación	***/
	cNomeArq := 'S017'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0177,'01',STR0019,STR0020,'C', 4,0,'@!','NAOVAZIO()','','1'} ) //"Tipos de operación" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0177,'02',STR0021,STR0022,'C',80,0,'@!','NAOVAZIO()','','1'} ) //"Tipos de operación" //"Descrip" //"Descripción"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0177,'03',STR0203,STR0204,'C',3,0,'@!','NAOVAZIO()','','1'} )  //"Tipos de operación" //"Tipo Doc." //"Tipo de Documento"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0177,'04',STR0205,STR0206,'C',1,0,'@!','NAOVAZIO()','','1'} ) //"Tipos de operación" //"Tipo Validación" //"Tipo de Validación DIAN"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {4,80,3,1} //Tamaño de campos definidos en F3H
		cAuxArch := "17TiposOperacion.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0178, , .T. ) //"Catálogo de Tipos de Operación"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf
	/***	18CodigoReferenciaDocs	***/
	cNomeArq := 'S018'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0201,'01',STR0019,STR0020,'C', 4,0,'@!','NAOVAZIO()','','1'} )  //"Referencia a otros documentos" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0201,'02',STR0021,STR0022,'C',110,0,'@!','NAOVAZIO()','','1'} ) //"Referencia a otros documentos" //"Descrip" //"Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {4,110} //Tamaño de campos definidos en F3H
		cAuxArch := "18CodigoReferenciaDocs.csv"
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo)}, STR0202, , .T. ) //"Catálogo de Ref. a otros documentos"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf
Return

/*
Param1 - Nombre del archivo a procesar
Param2 - Tamaño de los campos (Configuración de Catálogos)
*/
Static Function f814ReadFile(cFile, aTamCpo, nTipo, aTabela)
	Local nHandle  := 0
	Local nFor     := 0
	Local nX       := 0
	Local nY       := 0
	Local cLinea   := ""
	Local aLinea   := {}
	Local cAux	   := ""
	Local cTxtUTF8 := ""
	Local nTamSeq := TamSX3("F3I_SEQUEN")[1]
	Local aFields := {}
	Local lCanUseBulk := .F.

	Default nTipo	:= 0
	Default aTabela	:= {}

	// -------------------Tratamiento para uso de la clase FWBulk ------------------------
	aAdd( aFields, { 'F3I_FILIAL', 'C',TamSX3("F3I_FILIAL")[1], 0 } )
    aAdd( aFields, { 'F3I_CODIGO', 'C', TamSX3("F3I_CODIGO")[1], 0 } )
    aAdd( aFields, { 'F3I_SEQUEN', 'C', TamSX3("F3I_SEQUEN")[1], 0 } )
	aAdd( aFields, { 'F3I_CONTEU', 'C', TamSX3("F3I_CONTEU")[1], 0 } )

    oBulk := FwBulk():New(RetSqlName("F3I"))
    lCanUseBulk := FwBulk():CanBulk()
    if lCanUseBulk
        oBulk:SetFields(aFields)
    endif

	nHandle := FT_FUse(cFile)
	If nHandle != -1
		If cPaisLoc == "BOL" .AND. nTipo != 0
			If nTipo== 1
				nX :=  m486xBoMax(cNomeArq) + 1
			EndIf
		Else
			nX := 1
		EndIf

		FT_FGoTop()
		nFor := FT_FLastRec()
		ProcRegua(nFor)

		While !FT_FEOF()

			IncProc(Str(nX))
			cLinea := ""
			aLinea := {}
			aLinea := Separa(FT_FREADLN(),_SEPARADOR)

			If  Empty(aLinea)
				FT_FSKIP()
				Loop
			Endif
			If cPaisLoc =='MEX' .AND. cNomeArq == 'S014'
				if Len(aLinea) > 0
					//aLinea[1] = Fraccion arancelaria y aTamCpo[1] = tamaño de Fraccion arancelaria
					If Len(aLinea[1]) > aTamCpo[1]
						// se extrae núm NICO y se agrega al array
						AADD(aLinea,substr(Alltrim(aLinea[1]),9,2))
						// se extrae y asigna la fraccion arancelaria de 8 digitos
						aLinea[1]:= substr(Alltrim(aLinea[1]),1,8)
					Endif
				Endif
			EndIf

			For nY := 1 To Len(aLinea)
				If cPaisLoc $ "PER|PAR|COL|BOL"
					cTxtUTF8 := Alltrim(aLinea[nY])
				Else
					cTxtUTF8 := DecodeUTF8(Alltrim(aLinea[nY]))
				EndIf

				If Len(aTabela) >= nY .And. aTabela[nY,7] == "D"
					// Campo tipo Fecha, convertir a AAAAMMDD
					// dar tratamiento según el país/legislación. Por ejemplo MEX-Carta Porte = "dd/mm/aaaa"
					If "/" $ cTxtUTF8 .And. Len(cTxtUTF8) == 10
						cTxtUTF8 := DtoS( CtoD(cTxtUTF8) )
					EndIf
				EndIf

				cAux := PADR(cTxtUTF8, aTamCpo[nY], " ")
				cAux := IIF(cAux <> Nil,cAux, PADR(Alltrim(aLinea[nY]), aTamCpo[nY], " "))
				cLinea += cAux
			Next

			If lCanUseBulk .And. cLibVer >= "20201009"
				 oBulk:AddData({cFilF3I,cNomeArq,Strzero(nX,nTamSeq),cLinea})
			Else
				RecLock('F3I',.T.)
					Replace F3I_FILIAL With cFilF3I
					Replace F3I_CODIGO With cNomeArq
					Replace F3I_SEQUEN With Strzero(nX,nTamSeq)
					Replace F3I_CONTEU With cLinea
				MsUnLock()
			EndIf

			FT_FSKIP()
			nX++
		EndDo
		FT_FUSE()
		if lCanUseBulk
			oBulk:Close()
			oBulk:Destroy()
			oBulk := nil
    	Endif
	Else
		MsgAlert(STR0015 + " " + cFile)
	EndIf
Return

/*/{Protheus.doc} f814CatEcu
Creación de tablas auxiliares estándar
@type function
@author luis.enriquez
@since 10/Septiembre/2018
@version 1.0
/*/
Function f814CatEcu()
	Local nI			:= 0
	Local cAuxArch		:= ""
	Local aTamCpo		:= {}

	Private aTabela		:= {}
	Private cFilF3I		:= xFilial("F3I")
	Private cFilF3H		:= xFilial("F3H")
	Private cNomeArq	:= ""

	DbSelectArea("F3H")
	F3H->(DbSetOrder(1)) //F3H_FILIAL + F3H_CODIGO
	DbSelectArea("F3I")
	F3I->(DbSetOrder(1)) //F3I_FILIAL + F3I_CODIGO + F3I_SEQUEN

	/*** 16Impuestos***/
	cNomeArq := 'S016'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0006,'01',STR0019,STR0020,'C', 1,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo de Impuestos" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0006,'02',STR0021,STR0022,'C',10,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo de Impuestos" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {1,10} //Tamaño de campos definidos en F3H
		cAuxArch := "16ImpuestosSRI.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0006, , .T. ) //"Catálogo de Impuestos"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** 17TarifaIVA***/
	cNomeArq := 'S017'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0056,'01',STR0019,STR0020,'C', 1,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo de Tarifa del IVA" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0056,'02',STR0021,STR0022,'C',30,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo de Tarifa del IVA" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {1,30} //Tamaño de campos definidos en F3H
		cAuxArch := "17TarifaIVASRI.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0056, , .T. ) //"Catálogo de Tarifa del IVA"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** 18TarifaICE***/
	cNomeArq := 'S018'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0057,'01',STR0019,STR0020,'C', 4,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo de Tarifa del ICE" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0057,'02',STR0058,STR0058,'C', 4,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo de Tarifa del ICE" //"% Tarifa" //"% Tarifa"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0057,'03',STR0058 + " " + STR0059,STR0058 + " " + STR0059,'C', 35,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo de Tarifa del ICE" //"% Tarifa Especifica" //"% Tarifa Especifica"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0057,'04',STR0021,STR0022,'C',200,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo de Tarifa del ICE" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {4,4,35,200} //Tamaño de campos definidos en F3H
		cAuxArch := "18TarifaICESRI.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0057, , .T. ) //"Catálogo de Tarifa del ICE"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** 19ImpuestosARetener ***/
	cNomeArq := 'S019'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0055,'01',STR0019,STR0020,'C', 1,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo de Impuestos a Retener" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0055,'02',STR0021,STR0022,'C',10,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo de Impuestos a Retener" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {1,10} //Tamaño de campos definidos en F3H
		cAuxArch := "19ImpuestosARetener.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0055, , .T. ) //"Catálogo de Impuestos a Retener"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** 20TipoImpARetenerSRI ***/
	cNomeArq := 'S020'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0116,'01',STR0117,STR0117,'C', 1,0,'@!','NAOVAZIO()','','1'} )  //"Catálogo Tipos Impuestos a Retener" //"Tipo" //"Tipo"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0116,'02',STR0019,STR0020,'C', 5,0,'@!','NAOVAZIO()','','1'} )  //"Catálogo Tipos Impuestos a Retener" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0116,'03',STR0021,STR0022,'C',170,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo Tipos Impuestos a Retener" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {1,5,170} //Tamaño de campos definidos en F3H
		cAuxArch := "20TipoImpARetenerSRI.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0061, , .T. ) //"Catálogo Tipos Impuestos a Retener"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** 24FormasPago ***/
	cNomeArq := 'S024'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0060,'01',STR0019,STR0020,'C', 2,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo Formas de Pago" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0060,'02',STR0021,STR0022,'C',50,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo Formas de Pago" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,50} //Tamaño de campos definidos en F3H
		cAuxArch := "24FormasPagoSRI.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0060, , .T. ) //"Catálogo Formas de Pago"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** 27TiposDeRegimenFiscalDelExterior ***/
	cNomeArq := 'S027'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0307,'01',STR0019,STR0020,'C', 2,0,'@!','NAOVAZIO()','','1'} ) //"Tipos de Regimen Fiscal del Exterior" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0307,'02',STR0021,STR0022,'C',60,0,'@!','NAOVAZIO()','','1'} ) //"Tipos de Regimen Fiscal del Exterior" //"Descrip" //"Descripción"
		F814CpsTab(aTabela) //Añade detalle a tabla F3H
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,60}
		cAuxArch := "27TiposRegimenFiscalExterior.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0307, , .T. ) //"Catalogo de Regimen Fiscal del Exterior"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** 28Paises***/
	cNomeArq := 'S028'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0308,'01',STR0019,STR0020,'C', 3,0,'@!','NAOVAZIO()','','1'} ) //"Catalogo de Paises" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0308,'02',STR0021,STR0022,'C',50,0,'@!','NAOVAZIO()','','1'} ) //"Catalogo de Paises" //"Descrip" //"Descripción"
		F814CpsTab(aTabela) //Añade detalle a tabla F3H
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {3,50}
		cAuxArch := "28Paises.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0308, , .T. ) //"Catalogo de Paises"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** 29ParaisosFiscales***/
	cNomeArq := 'S029'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0309,'01',STR0019,STR0020,'C',  2,0,'@!','NAOVAZIO()','','1'} ) //"Catalogo de Paraisos Fiscales" ## "Codigo" ## "Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0309,'02',STR0021,STR0022,'C',105,0,'@!','NAOVAZIO()','','1'} ) //"Catalogo de Paraisos Fiscales" ## "Descrip" ## "Descripción"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0309,'03',STR0313,STR0314,'C', 50,0,'@!','NAOVAZIO()','','1'} ) //"Catalogo de Paraisos Fiscales" ## "Pais a ligar" ## "País al que se debe ligar"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0309,'04',STR0315,STR0316,'C',  3,0,'@!','NAOVAZIO()','','1'} ) //"Catalogo de Paraisos Fiscales" ## "Cód. Pais" ## "Código de Pais"
		F814CpsTab(aTabela) //Añade detalle a tabla F3H
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,105,50,3}
		cAuxArch := "29ParaisosFiscales.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0309, , .T. ) //"Catalogo de Paraisos Fiscales"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** 30TipoDeExportacion/IngresoDelExterior***/
	cNomeArq := 'S030'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0310,'01',STR0019,STR0020,'C', 2,0,'@!','NAOVAZIO()','','1'} ) //"Catalogo de Tipo de Exportacion / Ingreso del Exterior" ## "Codigo" ## "Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0310,'02',STR0021,STR0022,'C',60,0,'@!','NAOVAZIO()','','1'} ) //"Catalogo de Tipo de Exportacion / Ingreso del Exterior" ## "Descrip" ## "Descripción"
		F814CpsTab(aTabela) //Añade detalle a tabla F3H
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,60}
		cAuxArch := "30TipoExportacionIngresoExterior.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0310, , .T. ) //"Catalogo de Tipo de Exportacion / Ingreso del Exterior"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** 31TiposDeIngresosDelExterior***/
	cNomeArq := 'S031'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0311,'01',STR0019,STR0020,'C',  3,0,'@!','NAOVAZIO()','','1'} ) //"Catalogo de Tipos de Ingresos del Exterior" ## "Codigo" ## "Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0311,'02',STR0021,STR0022,'C',100,0,'@!','NAOVAZIO()','','1'} ) //"Catalogo de Tipos de Ingresos del Exterior" ## "Descrip" ## "Descripción"
		F814CpsTab(aTabela) //Añade detalle a tabla F3H
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {3,100}
		cAuxArch := "31TiposIngresoExterior.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0311, , .T. ) //"Catalogo de Tipos de Ingresos del Exterior"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** 32TiposComprobantesAutorizados***/
	cNomeArq := 'S032'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0312,'01',STR0019,STR0020,'C',  3,0,'@!','NAOVAZIO()','','1'} ) //"Catalogo de Tipos de Comprobantes Autorizados" ## "Codigo" ## "Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0312,'02',STR0021,STR0022,'C',110,0,'@!','NAOVAZIO()','','1'} ) //"Catalogo de Tipos de Comprobantes Autorizados" ## "Descrip" ## "Descripción"
		F814CpsTab(aTabela) //Añade detalle a tabla F3H
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {3,110}
		cAuxArch := "32TiposComprobantesAutorizados.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0312, , .T. ) //"Catalogo de Tipos de Comprobantes Autorizados"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** 33DistrubuidoresAduaneros***/
	cNomeArq := 'S033'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0317,'01',STR0019,STR0020,'C',  3,0,'@!','NAOVAZIO()','','1'} ) //"Catalogo de Destritos Aduaneros" ## "Codigo" ## "Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0317,'02',STR0021,STR0022,'C', 20,0,'@!','NAOVAZIO()','','1'} ) //"Catalogo de Destritos Aduaneros" ## "Descrip" ## "Descripción"
		F814CpsTab(aTabela) //Añade detalle a tabla F3H
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {3,20}
		cAuxArch := "33DistritoAduanero.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0317, , .T. ) //"Catalogo de Destritos Aduaneros"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** 34CodigosRegimen***/
	cNomeArq := 'S034'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0318,'01',STR0019,STR0020,'C', 2,0,'@!','NAOVAZIO()','','1'} ) //"Catalogo de Codigos de Regimen" ## "Codigo" ## "Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0318,'02',STR0021,STR0022,'C',90,0,'@!','NAOVAZIO()','','1'} ) //"Catalogo de Codigos de Regimen" ## "Descrip" ## "Descripción"
		F814CpsTab(aTabela) //Añade detalle a tabla F3H
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,90}
		cAuxArch := "34CodigoRegimen.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0318, , .T. ) //"Catalogo de Codigos de Regimen"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

Return

/*/{Protheus.doc} f814CatPer
Creación de tablas auxiliares estándar
@type function
@author m.camargo
@since 12/10/2018
@version 1.0
/*/
Function f814CatPer()
	Local nI			:= 0
	Local cAuxArch		:= ""
	Local aTamCpo		:= {}

	Private aTabela		:= {}
	Private cFilF3I		:= xFilial("F3I")
	Private cFilF3H		:= xFilial("F3H")
	Private cNomeArq	:= ""

	DbSelectArea("F3H")
	F3H->(DbSetOrder(1)) //F3H_FILIAL + F3H_CODIGO
	DbSelectArea("F3I")
	F3I->(DbSetOrder(1)) //F3I_FILIAL + F3I_CODIGO + F3I_SEQUEN

	/*** Catálogo No. 01: Código de Tipo de documento***/
	cNomeArq := 'S001'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0061,'01',STR0019,STR0020,'C', 2,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo No. 01: Código de Tipo de documento" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0061,'02',STR0021,STR0022,'C',50,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo No. 01: Código de Tipo de documento" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,50} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo01.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0061, , .T. ) //"Catálogo de Impuestos"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 02: Códigos de Tipo de Monedas***/
	cNomeArq := 'S002'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0062,'01',STR0019		,STR0020,'C',  3,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo No. 02: Códigos de Tipo de Monedas" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0062,'02','Numero'		,STR0096,'C',  7,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo No. 02: Códigos de Tipo de Monedas" //"Codigo" //"Núm."
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0062,'03','Decimales'	,STR0097,'C',  2,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo No. 02: Códigos de Tipo de Monedas" //"Descrip" //"Dec."
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0062,'04','Divisa'		,STR0098,'C', 70,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo No. 02: Códigos de Tipo de Monedas" //"Descrip" //"Divisa"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0062,'05','Paises'		,STR0099,'C',100,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo No. 02: Códigos de Tipo de Monedas" //"Descrip" //"Países"

		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {3,7,2,70,100} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo02.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0062, , .T. ) //"Catálogo No. 02: Códigos de Tipo de Monedas"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 03: Códigos de Tipo de Unidad de Medida Comercial***/
	cNomeArq := 'S003'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0063,'01',STR0019,STR0020,'C', 3,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo No. 03: Códigos de Tipo de Unidad de Medida Comercial" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0063,'02',STR0021,STR0022,'C',200,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo No. 03: Códigos de Tipo de Unidad de Medida Comercial" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {3,200} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo03.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0064, , .T. ) //"Cat No. 03: Tipo de Unidad de Medida Comercial"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 04: Códigos de Países ***/
	cNomeArq := 'S004'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0064,'01',STR0019		,STR0020,'C',  2,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo No. 04: Códigos de Países" //"Código" ,,,,
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0064,'02','Alfa3'		,STR0100,'C',  3,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo No. 04: Códigos de Países" //"Código alfa-3"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0064,'03','CodNum'		,STR0101,'C',  3,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo No. 04: Códigos de Países" //"Código numérico"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0064,'04',STR0021	   	,STR0102,'C', 50,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo No. 04: Códigos de Países" //"Nombre común"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0064,'05','NombreISO'	,STR0103,'C', 50,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo No. 04: Códigos de Países" //"Nombre ISO"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0064,'06','Obs'		,STR0104,'C', 30,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo No. 04: Códigos de Países" //"Observaciones"

		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,3,3,50,50,30} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo04.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0064, , .T. ) //"Catálogo No. 04: Códigos de Países"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 05: Códigos de Tipos de Tributos ***/
	cNomeArq := 'S005'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0065,'01',STR0019		,STR0020,'C', 4,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo No. 05: Códigos de Tipos de Tributos" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0065,'02',STR0021		,STR0022,'C',40,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo No. 05: Códigos de Tipos de Tributos" //"Descrip" //"Descripción"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0065,'03','NameCode'	,STR0105,'C', 3,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo No. 05: Códigos de Tipos de Tributos" //"Codigo" //"Código Internacional"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0065,'04','CatCode'	,STR0106,'C', 3,0,'@!','NAOVAZIO()','','1'} ) //"Catálogo No. 05: Códigos de Tipos de Tributos" //"Descrip" //"Nombre"

		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL 	With aTabela[nI][01]
			Replace F3H_CODIGO 	With aTabela[nI][02]
			Replace F3H_DESC  	With aTabela[nI][03]
			Replace F3H_ORDEM  	With aTabela[nI][04]
			Replace F3H_CAMPOS 	With aTabela[nI][05]
			Replace F3H_DESCPO 	With aTabela[nI][06]
			Replace F3H_TIPO   	With aTabela[nI][07]
			Replace F3H_TAMAN  	With aTabela[nI][08]
			Replace F3H_DECIMA 	With aTabela[nI][09]
			Replace F3H_PICTUR 	With aTabela[nI][10]
			Replace F3H_VALID  	With aTabela[nI][11]
			Replace F3H_VERSAO 	With aTabela[nI][12]
			Replace F3H_PESQ   	With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {4,40,3,3} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo05.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0065, , .T. ) //"Catálogo No. 05: Códigos de Tipos de Tributos"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 06: Códigos de Tipos de Documentos de Identidad***/
	cNomeArq := 'S006'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0066,'01',STR0019,STR0020,'C', 1,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 06: Códigos de Tipos de Documentos de Identidad" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0066,'02',STR0021,STR0022,'C',200,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 06: Códigos de Tipos de Documentos de Identidad" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {1,200} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo06.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0066, , .T. ) //"Cat No. 06: Tipos de Documentos de Identidad"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 07: Códigos de Tipo de Afectación del IGV***/
	cNomeArq := 'S007'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0067,'01',STR0019,STR0020,'C',  2,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 07: Códigos de Tipo de Afectación del IGV" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0067,'02',STR0021,STR0022,'C', 50,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 07: Códigos de Tipo de Afectación del IGV" //"Descrip" //"Descripción"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0067,'03','CodTributo',STR0114 ,'C', 4,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 07: Códigos de Tipo de Afectación del IGV" //"CodTributo" //"Código Tributo"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,50,4} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo07.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0067, , .T. ) //"Catálogo No. 07: Códigos de Tipo de Afectación del IGV"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 08: Códigos de Tipos de Sistema de Cálculo del ISC ***/
	cNomeArq := 'S008'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0068,'01',STR0019,STR0020,'C',  2,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 08: Códigos de Tipos de Sistema de Cálculo del ISC" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0068,'02',STR0021,STR0022,'C',100,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 08: Códigos de Tipos de Sistema de Cálculo del ISC" //"Descrip" //"Descripción"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0068,'03',STR0109 ,STR0109 ,'N',5,2,'@E 99.99','NAOVAZIO()','','1'} ) 	//"Catálogo No. 08: Códigos de Tipos de Sistema de Cálculo del ISC" //"Tasa" //"Tasa"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,100,5} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo08.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0068, , .T. ) //"Catálogo No. 07: Códigos de Tipo de Afectación del IGV"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 09: Códigos de Tipo de Nota de Crédito Electrónica ***/
	cNomeArq := 'S009'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0069,'01',STR0019,STR0020,'C',  2,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 09: Códigos de Tipo de Nota de Crédito Electrónica" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0069,'02',STR0021,STR0022,'C', 50,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 09: Códigos de Tipo de Nota de Crédito Electrónica" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,50} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo09.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0069, , .T. ) //"Catálogo No. 09: Códigos de Tipo de Nota de Crédito Electrónica"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 10: Códigos de Tipo de Nota de Débito Electrónica ***/
	cNomeArq := 'S010'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0070,'01',STR0019,STR0020,'C',  2,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 10: Códigos de Tipo de Nota de Débito Electrónica" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0070,'02',STR0021,STR0022,'C', 50,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 10: Códigos de Tipo de Nota de Débito Electrónica" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,50} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo10.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0070, , .T. ) //"Catálogo No. 10: Códigos de Tipo de Nota de Débito Electrónica"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 11: Resumen Diario de Boletas de Venta y Notas Electrónicas - Código de Tipo de Valor de Venta ***/
	cNomeArq := 'S011'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0107,'01',STR0019,STR0020,'C',  2,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 11: Código de Tipo de Valor de Venta" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0107,'02',STR0021,STR0022,'C', 12,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 11: Código de Tipo de Valor de Venta" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,12} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo11.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0071, , .T. ) //"Catálogo No. 11: Resumen Diario de Boletas de Venta y Notas Electrónicas - Código de Tipo de Valor de Venta"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 12: Códigos - Documentos Relacionados Tributarios ***/
	cNomeArq := 'S012'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0072,'01',STR0019,STR0020,'C',  2,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 12: Códigos - Documentos Relacionados Tributarios" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0072,'02',STR0021,STR0022,'C', 50,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 12: Códigos - Documentos Relacionados Tributarios" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,50} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo12.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0072, , .T. ) //"Catálogo No. 12: Códigos - Documentos Relacionados Tributarios"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf
	/*** Catálogo No. 13: Ubicación Geográfica (UBIGEO) ***/
		cNomeArq := 'S013'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}

		aAdd( aTabela, { cFilF3H,cNomeArq,STR0073,'01',STR0110,STR0110,'C',  6,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 13: Ubicación Geográfica (UBIGEO)" "Ubigeo"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0073,'02',STR0111,STR0111,'C', 50,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 13: Ubicación Geográfica (UBIGEO)" "Distrito"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0073,'03',STR0112,STR0112,'C', 30,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 13: Ubicación Geográfica (UBIGEO)" "Provincia"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0073,'04',STR0113,STR0113,'C', 30,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 13: Ubicación Geográfica (UBIGEO)" "Departamento"

		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {6,50,30,30} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo13.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0073, , .T. ) //"Catálogo No. 13: Ubicación Geográfica (UBIGEO)"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 14: Códigos - Otros conceptos tributarios ***/
	cNomeArq := 'S014'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0074,'01',STR0019,STR0020,'C',  4,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 14: Códigos - Otros conceptos tributarios" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0074,'02',STR0021,STR0022,'C', 50,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 14: Códigos - Otros conceptos tributarios"//"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {4,50} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo14.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0074, , .T. ) //"Catálogo No. 14: Códigos - Otros conceptos tributarios"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 15: Códigos - Elementos adicionales en la Factura Electrónica y/o Boleta de Venta Electrónica ***/
	cNomeArq := 'S015'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0075,'01',STR0019,STR0020,'C',  4,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 15: Códigos - Elementos adicionales en la Factura Electrónica y/o Boleta de Venta Electrónica" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0075,'02',STR0021,STR0022,'C', 50,0,'@!','NAOVAZIO()','','1'} ) 	//"CCatálogo No. 15: Códigos - Elementos adicionales en la Factura Electrónica y/o Boleta de Venta Electrónica" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {4,50} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo15.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0075, , .T. ) //"Catálogo No. 15: Códigos - Elementos adicionales en la Factura Electrónica y/o Boleta de Venta Electrónica"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf


	/*** Catálogo No. 16: Códigos – Tipo de Precio de Venta Unitario ***/
	cNomeArq := 'S016'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0076,'01',STR0019,STR0020,'C',  2,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 15: Códigos - Elementos adicionales en la Factura Electrónica y/o Boleta de Venta Electrónica" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0076,'02',STR0021,STR0022,'C', 50,0,'@!','NAOVAZIO()','','1'} ) 	//"CCatálogo No. 15: Códigos - Elementos adicionales en la Factura Electrónica y/o Boleta de Venta Electrónica" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,50} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo16.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0076, , .T. ) //"Catálogo No. 15: Códigos - Elementos adicionales en la Factura Electrónica y/o Boleta de Venta Electrónica"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 17: Códigos – Tipo de Operación ***/
	cNomeArq := 'S017'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0077,'01',STR0019,STR0020,'C',  2,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 17: Códigos – Tipo de Operación" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0077,'02',STR0021,STR0022,'C', 50,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 17: Códigos – Tipo de Operación" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,50} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo17.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0077, , .T. ) //"Catálogo No. 17: Códigos – Tipo de Operación"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 18: Códigos – Modalidad de Traslado ***/
	cNomeArq := 'S018'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0078,'01',STR0019,STR0020,'C',  2,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 17: Códigos – Tipo de Operación" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0078,'02',STR0021,STR0022,'C', 50,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 17: Códigos – Tipo de Operación" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,50} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo18.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0078, , .T. ) //"Catálogo No. 18: Códigos – Modalidad de Traslado"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 19: Resumen Diario de boletas de venta y notas electrónicas - Códigos de estado de ítem ***/
	cNomeArq := 'S019'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0079,'01',STR0019,STR0020,'C',  2,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 19: Resumen Diario de boletas de venta y notas electrónicas - Códigos de estado de ítem" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0079,'02',STR0021,STR0022,'C', 50,0,'@!','NAOVAZIO()','','1'} ) 	//"CCatálogo No. 19: Resumen Diario de boletas de venta y notas electrónicas - Códigos de estado de ítem" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,50} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo19.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0079, , .T. ) //"Catálogo No. 18: Códigos – Modalidad de Traslado"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 20: Códigos – Motivos de Traslado ***/
	cNomeArq := 'S020'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0080,'01',STR0019,STR0020,'C',  2,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 20: Códigos – Motivos de Traslado" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0080,'02',STR0021,STR0022,'C', 50,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 20: Códigos – Motivos de Traslado" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,50} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo20.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0080, , .T. ) //Catálogo No. 20: Códigos – Motivos de Traslado
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 21: Documentos Relacionados - aplicable solo para la Guía de remisión electrónica ***/
	cNomeArq := 'S021'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0081,'01',STR0019,STR0020,'C',  2,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 21: Documentos Relacionados - aplicable solo para la Guía de remisión electrónica" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0081,'02',STR0021,STR0022,'C', 50,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 21: Documentos Relacionados - aplicable solo para la Guía de remisión electrónica" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,50} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo21.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0081, , .T. ) //"Catálogo No. 21: Documentos Relacionados - aplicable solo para la Guía de remisión electrónica"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** "Catálogo No. 22: Regímenes de Percepción" ***/
	cNomeArq := 'S022'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0082,'01',STR0019,STR0020,'C',  2,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 22: Regímenes de Percepción" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0082,'02',STR0021,STR0022,'C', 70,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 22: Regímenes de Percepción" //"Descrip" //"Descripción"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0082,'03',STR0109,STR0109,'C', 15,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 22: Regímenes de Percepción" //"Descrip" //"Tasa"

		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,70,15} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo22.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0082, , .T. ) //"Catálogo No. 22: Regímenes de Percepción"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** "Catálogo No. 23: Regímenes de Retención" ***/
	cNomeArq := 'S023'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0083,'01',STR0019,STR0020,'C',  2,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 23: Regímenes de Retención" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0083,'02',STR0021,STR0022,'C', 50,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 23: Regímenes de Retención" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,50} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo23.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0083, , .T. ) //"Catálogo No. 23: Regímenes de Retención"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 24: Recibo Electrónico por Servicios Públicos ***/
	cNomeArq := 'S024'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0084,'01',STR0019,STR0020,'C',  2,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 24: Recibo Electrónico por Servicios Públicos" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0084,'02',STR0021,STR0022,'C', 20,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 24: Recibo Electrónico por Servicios Públicos" //"Descrip" //"Descripción"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0084,'02',STR0108,STR0108,'C', 10,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 24: Recibo Electrónico por Servicios Públicos" //"Descrip" //"Descripción"

		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,20,10} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo24.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0084, , .T. ) //Catálogo No. 24: Recibo Electrónico por Servicios Públicos
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 25: Código Producto SUNAT ***/
	cNomeArq := 'S025'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0085,'01',STR0019,STR0020,'C',  8,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 25: Código Producto SUNAT" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0085,'02',STR0021,STR0022,'C',200,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 25: Código Producto SUNAT" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {8,200} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo25.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0085, , .T. ) //"Catálogo No. 25: Código Producto SUNAT"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf
	/*** Catálogo No. 26: Tipo de préstamo ***/
	cNomeArq := 'S026'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0086,'01',STR0019,STR0020,'C',  4,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 26: Tipo de préstamo"//"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0086,'02',STR0021,STR0022,'C', 70,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 26: Tipo de préstamo" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {4,70} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo26.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0086, , .T. ) //"Catálogo No. 26: Tipo de préstamo"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 51: Código de tipo de factura***/
	cNomeArq := 'S051'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0088,'01',STR0019,STR0020,'C',  4,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 51: Código de tipo de factura" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0088,'02',STR0021,STR0022,'C', 50,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 51: Código de tipo de factura" //"Descrip" //"Descripción"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0088,'03','TpCompAsd',STR0115,'C', 18,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 51: Código de tipo de factura" //"TpCompAsd" //"Tipo Comprobante Asociado"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {4,50,18} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo51.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0088, , .T. ) //"Catálogo No. 51: Código de tipo de factura"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 52: Código de Leyendas ***/
	cNomeArq := 'S052'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0089,'01',STR0019,STR0020,'C',  4,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 52: Código de Leyendas" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0089,'02',STR0021,STR0022,'C',250,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 52: Código de Leyendas" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {4,50} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo52.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0089, , .T. ) //"Catálogo No. 51: Código de tipo de factura"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 53: Códigos de cargos o descuentos ***/
	cNomeArq := 'S053'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0090,'01',STR0019,STR0020,'C',  2,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 53: Códigos de cargos o descuentos" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0090,'02',STR0021,STR0022,'C',100,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 53: Códigos de cargos o descuentos" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {4,50} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo53.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0090, , .T. ) //"Catálogo No. 53: Códigos de cargos o descuentos"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 54: Códigos de bienes y servicios sujetos a detracción ***/
	cNomeArq := 'S054'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0091,'01',STR0019,STR0020,'C',  3,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 54: Códigos de bienes y servicios sujetos a detracción" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0091,'02',STR0021,STR0022,'C',100,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 54: Códigos de bienes y servicios sujetos a detracción" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {3,100} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo54.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0091, , .T. ) //"Catálogo No. 54: Códigos de bienes y servicios sujetos a detracción"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 55: Código de identificación del ítem ***/
	cNomeArq := 'S055'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0092,'01',STR0019,STR0020,'C',  4,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 55: Código de identificación del ítem" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0092,'02',STR0021,STR0022,'C',250,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 55: Código de identificación del ítem" //"Descrip" //"Descripción"
		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {4,250} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo55.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0092, , .T. ) //"Catálogo No. 55: Código de identificación del ítem"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 56: Código de tipo de servicio público ***/
	cNomeArq := 'S056'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0093,'01',STR0019,STR0020,'C',  1,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 56: Código de tipo de servicio público" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0093,'02',STR0021,STR0022,'C', 50,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 56: Código de tipo de servicio público" //"Descrip" //"Descripción"

		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {1,50} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo56.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0093, , .T. ) //"Catálogo No. 56: Código de tipo de servicio público"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 57: Código de tipo de servicios públicos - telecomunicaciones ***/
	cNomeArq := 'S057'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0094,'01',STR0019,STR0020,'C',  1,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 57: Código de tipo de servicios públicos - telecomunicaciones" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0094,'02',STR0021,STR0022,'C', 50,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 57: Código de tipo de servicios públicos - telecomunicaciones" //"Descrip" //"Descripción"

		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {1,50} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo57.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0094, , .T. ) //"Catálogo No. 57: Código de tipo de servicios públicos - telecomunicaciones"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 58: Código de tipo de medidor – recibo de luz ***/
	cNomeArq := 'S058'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0095,'01',STR0019,STR0020,'C',  1,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 57: Código de tipo de servicios públicos - telecomunicaciones" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0095,'02',STR0021,STR0022,'C', 50,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 57: Código de tipo de servicios públicos - telecomunicaciones" //"Descrip" //"Descripción"

		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {1,50} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo58.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0095, , .T. ) // Catálogo No. 58: Código de tipo de medidor – recibo de luz
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Catálogo No. 59: Medio de Pago ***/
	cNomeArq := 'S059'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0207,'01',STR0019,STR0020,'C',  3,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 59: Medios de Pago" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0207,'02',STR0021,STR0022,'C', 150,0,'@!','NAOVAZIO()','','1'} ) 	//"Catálogo No. 59: Medios de Pago" //"Descrip" //"Descripción"

		For nI := 1 To Len(aTabela)
			RecLock('F3H',.T.)
			Replace F3H_FILIAL With aTabela[nI][01]
			Replace F3H_CODIGO With aTabela[nI][02]
			Replace F3H_DESC   With aTabela[nI][03]
			Replace F3H_ORDEM  With aTabela[nI][04]
			Replace F3H_CAMPOS With aTabela[nI][05]
			Replace F3H_DESCPO With aTabela[nI][06]
			Replace F3H_TIPO   With aTabela[nI][07]
			Replace F3H_TAMAN  With aTabela[nI][08]
			Replace F3H_DECIMA With aTabela[nI][09]
			Replace F3H_PICTUR With aTabela[nI][10]
			Replace F3H_VALID  With aTabela[nI][11]
			Replace F3H_VERSAO With aTabela[nI][12]
			Replace F3H_PESQ   With aTabela[nI][13]
			MsUnLock()
		Next nI
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {3,150} //Tamaño de campos definidos en F3H
		cAuxArch := "CatalogoNo59.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0207, , .T. ) //"Catálogo No. 59: Medios de Pago"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf
Return

/*/{Protheus.doc} F814ACTF3H
Actualización de tabla de configuración de catálogos (F3H)
@type
@author luis.enriquez
@since 03/04/2019
@version 1.0
@param aTabela, array, Arreglo con estructura para tablas auxiliares
@return Nil
@example
(examples)
@see (links_or_references)
/*/
Static Function F814ACTF3H(aTabela)
	Local nI := 0

	Default aTabela := Nil

	For nI := 1 To Len(aTabela)
		RecLock('F3H',.T.)
			F3H_FILIAL := aTabela[nI][01]
			F3H_CODIGO := aTabela[nI][02]
			F3H_DESC   := aTabela[nI][03]
			F3H_ORDEM  := aTabela[nI][04]
			F3H_CAMPOS := aTabela[nI][05]
			F3H_DESCPO := aTabela[nI][06]
			F3H_TIPO   := aTabela[nI][07]
			F3H_TAMAN  := aTabela[nI][08]
			F3H_DECIMA := aTabela[nI][09]
			F3H_PICTUR := aTabela[nI][10]
			F3H_VALID  := aTabela[nI][11]
			F3H_VERSAO := aTabela[nI][12]
			F3H_PESQ   := aTabela[nI][13]
		MsUnLock()
	Next nI
Return Nil
/*/{Protheus.doc} f814CatBol
Creación de tablas auxiliares estándar
@type function
@author alfredo.medrano
@since 03/07/2019
@version 1.0
/*/
Function f814CatBol()
	Local cAuxArch		:= ""
	Local aTamCpo		:= {}

	Private aTabela		:= {}
	Private cFilF3I		:= xFilial("F3I")
	Private cFilF3H		:= xFilial("F3H")
	Private cNomeArq	:= ""

	DbSelectArea("F3H")
	F3H->(DbSetOrder(1)) //F3H_FILIAL + F3H_CODIGO
	DbSelectArea("F3I")
	F3I->(DbSetOrder(1)) //F3I_FILIAL + F3I_CODIGO + F3I_SEQUEN

	/*** Tipo Ambiente**/
	cNomeArq := 'S001'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0179,'01',STR0019,STR0020,'C',1,0,'@!','NAOVAZIO()','','1'} ) //"Tipo Ambiente" //"Codigo"" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0179,'02',STR0021,STR0022,'C',50,0,'@!','NAOVAZIO()','','1'} ) //"Tipo Ambiente" //"Descrip" //"Descripción"
		F814ACTF3H(aTabela)
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {1,50} //Tamaño de campos definidos en F3H
		cAuxArch := "TipoAmbiente.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0179, , .T. ) //"Tipo Ambiente"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Tipo de Emisión***/
	cNomeArq := 'S002'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}

		aAdd( aTabela, { cFilF3H,cNomeArq,STR0180,'01',STR0019,STR0020,'C', 1,0,'@!','NAOVAZIO()','','1'} ) //"Tipos de Emisión" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0180,'02',STR0021,STR0022,'C',50,0,'@!','NAOVAZIO()','','1'} ) //"Tipos de Emisión" //"Descrip" //"Descripción"
		F814ACTF3H(aTabela)
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {1,50} //Tamaño de campos definidos en F3H
		cAuxArch := "TipoEmision.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0180, , .T. ) //"Tipo de Emisión"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Tipo Modalidad ***/
	cNomeArq := 'S003'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}

		aAdd( aTabela, { cFilF3H,cNomeArq,STR0181,'01',STR0019,STR0020,'C', 1,0,'@!','NAOVAZIO()','','1'} ) //"Tipo Modalidad" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0181,'02',STR0021,STR0022,'C',50,0,'@!','NAOVAZIO()','','1'} ) //"Tipo Modalidad" //"Descrip" //"Descripción"
		F814ACTF3H(aTabela)
	Endif

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {1,50} //Tamaño de campos definidos en F3H
		cAuxArch := "TipoModalidad.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0181, , .T. ) //"Tipo Modalidad"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Tipo Método de Pago ***/
	cNomeArq := 'S004'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq))) .or. (F3H->F3H_CODIGO == "S004" .and. F814ActVer('S004', '001', F3H->F3H_VERSAO))
		aTabela := {}
		aTamCpo := {}

		aAdd( aTabela, { cFilF3H,cNomeArq,STR0182,'01',STR0019,STR0020,'C', 3,0,'@!','NAOVAZIO()','001','1'} ) // "Tipo Método de Pago" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0182,'02',STR0021,STR0022,'C',50,0,'@!','NAOVAZIO()','001','1'} ) // "Tipo Método de Pago" //"Descrip" //"Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {3,50} //Tamaño de campos definidos en F3H
		cAuxArch := "TipoMetodoPago.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0182, , .T. ) //"Tipo Método de Pago"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Eventos Significativos ***/
	cNomeArq := 'S005'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq, STR0183,'01',STR0019,STR0020,'C', 4,0,'@!','NAOVAZIO()','','1'} ) //"Eventos Significativos" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq, STR0183,'02',STR0021,STR0022,'C',50,0,'@!','NAOVAZIO()','','1'} ) //"Eventos Significativos" //"Descrip" //"Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {4,50} //Tamaño de campos definidos en F3H
		cAuxArch := "EventosSignificativos.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)},  STR0183, , .T. ) //"Eventos Significativos"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Tipo Documento Fiscal ***/
	cNomeArq := 'S006'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}

		aAdd( aTabela, { cFilF3H,cNomeArq,STR0184,'01',STR0019,STR0020,'C', 1,0,'@!','NAOVAZIO()','','1'} ) //"Tipo Documento Fiscal" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0184,'02',STR0021,STR0022,'C',50,0,'@!','NAOVAZIO()','','1'} ) //"Tipo Documento Fiscal" //"Descrip" //"Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {1,50} //Tamaño de campos definidos en F3H
		cAuxArch := "TipoDocumentoFiscal.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0184, , .T. ) //"Tipo Documento Fiscal"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Tipo Documento de Identidad***/
	cNomeArq := 'S007'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}

		aAdd( aTabela, { cFilF3H,cNomeArq,STR0185,'01',STR0019,STR0020,'C',  1,0,'@!','NAOVAZIO()','','1'} ) 	//"Tipo Documento de Identidad" //"Codigo" //"Código"
	    aAdd( aTabela, { cFilF3H,cNomeArq,STR0185,'02',STR0021,STR0022,'C', 50,0,'@!','NAOVAZIO()','','1'} ) 	//"Tipo Documento de Identidad" //"Descrip" //"Descripción"
	    F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {1,50} //Tamaño de campos definidos en F3H
		cAuxArch := "TipoDocumentoIdentidad.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0185, , .T. ) //"Tipo Documento de Identidad"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Tipo Documento Sector ***/
	cNomeArq := 'S008'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}

		aAdd( aTabela, { cFilF3H,cNomeArq,STR0186,'01',STR0019,STR0020,'C',  2,0,'@!','NAOVAZIO()','','1'} ) //"Tipo Documento Sector" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0186,'02',STR0021,STR0022,'C', 50,0,'@!','NAOVAZIO()','','1'} ) //"Tipo Documento Sector" //"Descrip" //"Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,50} //Tamaño de campos definidos en F3H
		cAuxArch := "TipoDocumentoSector.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0186, , .T. ) //"Tipo Documento Sector"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** "Tipo Moneda" ***/
	cNomeArq := 'S009'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}

		aAdd( aTabela, { cFilF3H,cNomeArq,STR0187,'01',STR0019,STR0020,'C',  4,0,'@!','NAOVAZIO()','','1'} ) //"Tipo Moneda" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0187,'02',STR0021,STR0022,'C', 50,0,'@!','NAOVAZIO()','','1'} ) //"Tipo Moneda" //"Descrip" //"Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {4,50} //Tamaño de campos definidos en F3H
		cAuxArch := "TipoMoneda.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0187, , .T. ) //"Tipo Moneda"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** País Origen ***/
	cNomeArq := 'S010'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}

		aAdd( aTabela, { cFilF3H,cNomeArq,STR0192 ,'01',STR0019,STR0020,'C',  4,0,'@!','NAOVAZIO()','','1'} ) 	//"País Origen" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0192 ,'02',STR0021,STR0036,'C', 50,0,'@!','NAOVAZIO()','','1'} ) 	//"País Origen" //"Descrip" //"Paises"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {4,50} //Tamaño de campos definidos en F3H
		cAuxArch := "PaisOrigen.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0192, , .T. ) //"País Origen"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Tipo Componente ***/
	cNomeArq := 'S011'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0188,'01',STR0019,STR0020,'C',  4,0,'@!','NAOVAZIO()','','1'} ) 	//"Tipo Componente" //"Codigo" //"Codigo"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0188,'02',STR0021,STR0022,'C', 50,0,'@!','NAOVAZIO()','','1'} ) 	//"Tipo Componente" //"Descrip" //"Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {4,50} //Tamaño de campos definidos en F3H
		cAuxArch := "TipoComponente.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0188, , .T. ) //"Tipo Componente"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** Mensaje Servicio ***/
	cNomeArq := 'S012'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0189,'01',STR0019,STR0020,'C',  4,0,'@!','NAOVAZIO()','','1'} ) 	//"Mensaje Servicio " //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0189,'02',STR0021,STR0022,'C', 300,0,'@!','NAOVAZIO()','','1'} ) 	//"Mensaje Servicio " //"Descrip" //"Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {4,300} //Tamaño de campos definidos en F3H
		cAuxArch := "MensajeServicio.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0189, , .T. ) //"Mensaje Servicio"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** "Producto servicio"  ***/
	cNomeArq := 'S013'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq))) .or. (F3H->F3H_CODIGO == "S013" .and. F814ActVer('S013', '001', F3H->F3H_VERSAO))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0191,'01',STR0200,STR0199,'C',  8,0,'@!','NAOVAZIO()','001','1'} ) 	//""Productos y servicios"" //"CodAct"  //"Codigo Actividad"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0191,'02',STR0019,STR0020,'C',  8,0,'@!','NAOVAZIO()','001','1'} ) 	//""Productos y servicios"" //"Codigo"  //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0191,'03',STR0021,STR0022,'C',200,0,'@!','NAOVAZIO()','001','1'} ) 	//""Productos y servicios"" //"Descrip" //"Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {8,8,200} //Tamaño de campos definidos en F3H
		cAuxArch := "ProductoServicio.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0191, , .T. ) //"Productos y servicios"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** "Actividad" ***/
	cNomeArq := 'S014'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}

		aAdd( aTabela, { cFilF3H,cNomeArq,STR0193,'01',STR0019,STR0020,'C',  8,0,'@!','NAOVAZIO()','','1'} ) //"Actividad" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0193,'02',STR0021,STR0022,'C', 200,0,'@!','NAOVAZIO()','','1'} ) //"Actividad" //"Descrip" //"Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {8,200} //Tamaño de campos definidos en F3H
		cAuxArch := "Actividad.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0193, , .T. ) //"Actividad"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** "Leyendas de Factura" ***/
	cNomeArq := 'S015'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}

		aAdd( aTabela, { cFilF3H,cNomeArq,STR0194,'01',STR0019,STR0020,'C',  2,0,'@!','NAOVAZIO()','','1'} ) //"Leyendas de Factura" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0194,'02',STR0021,STR0022,'C', 350,0,'@!','NAOVAZIO()','','1'} ) //"Leyendas de Factura" //"Descrip" //"Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {2,350} //Tamaño de campos definidos en F3H
		cAuxArch := "LeyendasFactura.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0194, , .T. ) //"Leyendas de Factura"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** "Motivo Anulacion" ***/
	cNomeArq := 'S016'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}

		aAdd( aTabela, { cFilF3H,cNomeArq,STR0195,'01',STR0019,STR0020,'C',  4,0,'@!','NAOVAZIO()','','1'} ) //"Motivo Anulación" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0195,'02',STR0021,STR0022,'C', 50,0,'@!','NAOVAZIO()','','1'} ) //"Motivo Anulación" //"Descrip" //"Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {4,50} //Tamaño de campos definidos en F3H
		cAuxArch := "MotivoAnulacion.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0195, , .T. ) //"Motivo Anulación"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** "Tipo Departamento" ***/
	cNomeArq := 'S017'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}

		aAdd( aTabela, { cFilF3H,cNomeArq,STR0196,'01',STR0019,STR0020,'C',  4,0,'@!','NAOVAZIO()','','1'} ) //"Tipo Departamento" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0196,'02',STR0021,STR0022,'C', 50,0,'@!','NAOVAZIO()','','1'} ) //"Tipo Departamento" //"Descrip" //"Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {4,50} //Tamaño de campos definidos en F3H
		cAuxArch := "TipoDepartamento.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0196, , .T. ) //"Tipo Departamento"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** "Tipo Punto de Venta" ***/
	cNomeArq := 'S018'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}

		aAdd( aTabela, { cFilF3H,cNomeArq,STR0197,'01',STR0019,STR0020,'C',  1,0,'@!','NAOVAZIO()','','1'} ) //"Tipo Punto Venta" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0197,'02',STR0021,STR0022,'C', 50,0,'@!','NAOVAZIO()','','1'} ) //"Tipo Punto Venta" //"Descrip" //"Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {1,50} //Tamaño de campos definidos en F3H
		cAuxArch := "TipoPuntoVenta.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0197, , .T. ) //"Tipo Punto Venta"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** "Unidad de Medida" ***/
	cNomeArq := 'S019'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}

		aAdd( aTabela, { cFilF3H,cNomeArq,STR0198,'01',STR0019,STR0020,'C',  4,0,'@!','NAOVAZIO()','','1'} ) //"Unidad de Medida" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0198,'02',STR0021,STR0022,'C', 50,0,'@!','NAOVAZIO()','','1'} ) //"Unidad de Medida" //"Descrip" //"Descripción"
		F814ACTF3H(aTabela)
	EndIf

	If !(F3I->(dbSeek(cFilF3I + cNomeArq)))
		aTamCpo := {4,50} //Tamaño de campos definidos en F3H
		cAuxArch := "UnidadMedida.csv"
		If File(cPath + cAuxArch)
			Processa( {|| f814ReadFile(cPath + cAuxArch, aTamCpo)}, STR0198, , .T. ) //"Unidad de Medida"
		Else
			MsgAlert(STR0014 + " " + cPath + cAuxArch) //"No se encontró el archivo"
		EndIf
	EndIf

	/*** "URL Endpoints" ***/
	cNomeArq := 'S020'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}

		aAdd( aTabela, { cFilF3H,cNomeArq,STR0320,'01',STR0019,STR0020,'C', 26,0,'@!','NAOVAZIO()','','1'} ) //"URL Endpoints" //"Codigo" //"Código"
		aAdd( aTabela, { cFilF3H,cNomeArq,STR0320,'02',STR0321,STR0321,'C', 100,0,'','NAOVAZIO()','','1'} ) //"URL Endpoints" //"Endpoint" //"Endpoint"
		F814ACTF3H(aTabela)
	EndIf
Return


/*/{Protheus.doc} fs814UpBol
Actualización de tabla de configuración de catálogos (F3I) (para Actualizacion catalogos SIN)
@type
@author Alfredo.Medrano
@since 22/11/2019
@version 1.0
@param cCodTab, tabla alfanumeria
@param nTipo, Tipo de descarga (solo para Tipo = 1 - Actualizacion )
@return Nil
@example
(examples)
@see (links_or_references)
/*/
Function fs814UpBol(cCodTab, nTipo)
Local Catalogos := {}
Local nT        :=0
Local cPath     := Alltrim(SuperGetMV("MV_PATH814",,"C:\Temp\FISA814\"))
Private aTabela		:= {}
Private cFilF3I		:= xFilial("F3I")
Private cFilF3H		:= xFilial("F3H")
Private cNomeArq	:= ""

If cCodTab != ""
	AADD(Catalogos, {"Actividad", "S014", {8,200} })
	AADD(Catalogos, {"LeyendasFactura", "S015", {2,350}})
	AADD(Catalogos, {"MensajeServicio", "S012", {4,300} })
	AADD(Catalogos, {"ProductoServicio", "S013", {8,5,200} })
	AADD(Catalogos, {"EventosSignificativos", "S005", {4,50} })
	AADD(Catalogos, {"MotivoAnulacion", "S016", {4,50} })
	AADD(Catalogos, {"PaisOrigen", "S010", {4,50} })
	AADD(Catalogos, {"TipoAmbiente", "S001", {1,50} })
	AADD(Catalogos, {"TipoComponente", "S011", {4,50} })
	AADD(Catalogos, {"TipoDepartamento", "S017", {4,50} })
	AADD(Catalogos, {"TipoDocumentoFiscal", "S006", {1,50} })
	AADD(Catalogos, {"TipoDocumentoIdentidad", "S007", {1,50} })
	AADD(Catalogos, {"TipoDocumentoSector", "S008", {2,50} })
	AADD(Catalogos, {"TipoEmision", "S002", {1,50} })
	AADD(Catalogos, {"TipoMetodoPago", "S004", {2,50} })
	AADD(Catalogos, {"TipoModalidad", "S003", {1,50} })
	AADD(Catalogos, {"TipoMoneda", "S009", {4,50} })
	AADD(Catalogos, {"TipoPuntoVenta", "S018", {1,50} })
	AADD(Catalogos, {"UnidadMedida", "S019", {4,50} })

	nT := ascan(Catalogos,{|x| x[2]= cCodTab})

	If nT > 0
		If File(cPath + Catalogos[nT][1] + ".csv")
			cNomeArq := Catalogos[nT][2]
			Processa( {|| f814ReadFile(cPath + Catalogos[nT][1] + ".csv", Catalogos[nT][3], nTipo)}, Catalogos[nT][1], , .T. ) //lee y carga los valores obtenidos del archivo .csv
		EndIf
	EndIf
EndIf
return

/*/{Protheus.doc} f814CatPAR
Actualización de tabla de catálogos (F3I)
@author raul.medina
@return Nil
/*/

Function f814CatPAR()
Local cAuxArch   	:= ""
Local aTamCpo    	:= {}
Local cPath     	:= Alltrim(SuperGetMV("MV_PATH814",,"C:\Temp\FISA814\"))

Private aTabela  	:= {}
Private cFilF3I  	:= xFilial("F3I")
Private cFilF3H  	:= xFilial("F3H")
Private cNomeArq 	:=	""


	/***	Tipo_Regimen	***/
	cNomeArq := 'S001'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0169, '01', STR0019, STR0020, 'C',  1, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0169, '02', STR0021, STR0022, 'C', 29, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {1,29} //Tamaño de campos definidos en F3H
	cAuxArch := "Tipo_Regimen.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0169)


	/***	Unidades_Medida	***/
	cNomeArq := 'S002'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0198, '01', STR0019, STR0020, 'C',   3, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0198, '02', STR0021, STR0022, 'C',  28, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0198, '03', STR0198, STR0198, 'C',   6, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {3,28,6} //Tamaño de campos definidos en F3H
	cAuxArch := "Unidades_Medida.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0198)


	/***	Departamentos	***/
	cNomeArq := 'S003'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0140, '01', STR0019, STR0020, 'C',   2, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0140, '02', STR0021, STR0022, 'C',  28, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {2,14} //Tamaño de campos definidos en F3H
	cAuxArch := "Departamentos.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0140)


	/***	Monedas	***/
	cNomeArq := 'S004'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0034, '01', STR0019, STR0020, 'C',   3, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0034, '02', STR0021, STR0022, 'C',  65, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {3,65}//{3,3,4,65,62} //Tamaño de campos definidos en F3H
	cAuxArch := "Monedas.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0034)

	/***	Países	***/
	cNomeArq := 'S005'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0036, '01', STR0019, STR0020, 'C',   3, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0036, '02', STR0021, STR0022, 'C',  52, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {3,52}//{2,3,3,41,54,336} //Tamaño de campos definidos en F3H
	cAuxArch := "Paises.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0036)

	/***	Actividad Económica	***/
	cNomeArq := 'S006'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0131, '01', STR0019, STR0020, 'C',   6, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0131, '02', STR0021, STR0022, 'C', 166, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {6,166} //Tamaño de campos definidos en F3H
	cAuxArch := "Act_Economica.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0131)

	/***	Afectaciones	***/
	cNomeArq := 'S007'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0132, '01', STR0019, STR0020, 'C',   1, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0132, '02', STR0021, STR0022, 'C',  24, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {1,24} //Tamaño de campos definidos en F3H
	cAuxArch := "Codigos_afectacion.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0132)

	/***	Categoría ISC	***/
	cNomeArq := 'S008'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0133, '01', STR0019, STR0020, 'C',   1, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0133, '02', STR0021, STR0022, 'C',  73, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {1,73} //Tamaño de campos definidos en F3H
	cAuxArch := "Categorias_isc.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0133)

	/***	Tasa ISC 	***/
	cNomeArq := 'S009'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0134, '01', STR0019, STR0020, 'C',   2, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0134, '02', STR0021, STR0022, 'C',   3, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {2,3} //Tamaño de campos definidos en F3H
	cAuxArch := "Tablas_isc.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0134)

	/***	Condiciones 	***/
	cNomeArq := 'S010'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0208, '01', STR0019, STR0020, 'C',   3, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0208, '02', STR0021, STR0022, 'C',   33, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {3,33} //Tamaño de campos definidos en F3H
	cAuxArch := "Condiciones.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0208)

	/***	Regímenes Aduaneros	***/
	cNomeArq := 'S011'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0136, '01', STR0019, STR0020, 'C',   4, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0136, '02', STR0021, STR0022, 'C',  59, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {4,59} //Tamaño de campos definidos en F3H
	cAuxArch := "reg_aduaneros.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0136)


	/***	Referencia Geográfica	***/
	cNomeArq := 'S012'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0137, '01', STR0139, STR0138, 'C',   2, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0137, '02', STR0141, STR0140, 'C',  13, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0137, '03', STR0142, STR0143, 'C',   3, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0137, '04', STR0144, STR0144, 'C',  29, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0137, '05', STR0019, STR0020, 'C',   4, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0137, '06', STR0147, STR0147, 'C',  30, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {2,13,3,29,4,30} //Tamaño de campos definidos en F3H
	cAuxArch := "refencia_geografica.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0137)

	/***	Tipos de Pago	***/
	cNomeArq := 'S013'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0044, '01', STR0019, STR0020, 'C',   2, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0044, '02', STR0021, STR0022, 'C',  30, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {2,30} //Tamaño de campos definidos en F3H
	cAuxArch := "Tipos_pago.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0044)

	/***	Denominación de Tarjeta	***/
	cNomeArq := 'S014'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0209, '01', STR0019, STR0020, 'C',   1, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0209, '02', STR0021, STR0022, 'C',  20, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {1,20} //Tamaño de campos definidos en F3H
	cAuxArch := "Denominacion_tarjeta.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0209)

	/***	Documento Electrónico	***/
	cNomeArq := 'S015'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0210, '01', STR0019, STR0020, 'C',   1, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0210, '02', STR0021, STR0022, 'C',  28, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {1,28} //Tamaño de campos definidos en F3H
	cAuxArch := "Documento_electronico.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0210)


	/***	Tipo de Transacción	***/
	cNomeArq := 'S016'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0211, '01', STR0019, STR0020, 'C',   2, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0211, '02', STR0021, STR0022, 'C',  36, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {2,36} //Tamaño de campos definidos en F3H
	cAuxArch := "tipo_transaccion.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0211)

	/***	Tipo Operación - Impuesto	***/
	cNomeArq := 'S017'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0164, '01', STR0019, STR0020, 'C',   1, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0164, '02', STR0021, STR0022, 'C',  11, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {1,11} //Tamaño de campos definidos en F3H
	cAuxArch := "Tipo_impuesto.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0164)

	/***	Documento Identidad	***/
	cNomeArq := 'S018'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0185, '01', STR0019, STR0020, 'C',   1, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0185, '02', STR0021, STR0022, 'C',  41, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {1,41} //Tamaño de campos definidos en F3H
	cAuxArch := "Documento_identidad.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0185)

	/***	Indicador de Presencia	***/
	cNomeArq := 'S019'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0212, '01', STR0019, STR0020, 'C',   1, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0212, '02', STR0021, STR0022, 'C',  30, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {1,30} //Tamaño de campos definidos en F3H
	cAuxArch := "Indicador_presencia.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0212)

	/***	Doc Identidad Ven/Tr	***/
	cNomeArq := 'S020'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0216, '01', STR0019, STR0020, 'C',   1, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0216, '02', STR0021, STR0022, 'C',  37, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {1,37} //Tamaño de campos definidos en F3H
	cAuxArch := "Identificacion_ven_tr.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0216)

	/***	Motivo de Emisión NC	***/
	cNomeArq := 'S021'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0213, '01', STR0019, STR0020, 'C',   1, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0213, '02', STR0021, STR0022, 'C',  30, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {1,30} //Tamaño de campos definidos en F3H
	cAuxArch := "Motivo_emision_NC.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0213)

	/***	Motivo de Emisión Re	***/
	cNomeArq := 'S022'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0214, '01', STR0019, STR0020, 'C',   2, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0214, '02', STR0021, STR0022, 'C',  60, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {2,60} //Tamaño de campos definidos en F3H
	cAuxArch := "Motivo_emision_RE.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0214)

	/***	Responsable de Emisión	***/
	cNomeArq := 'S023'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0158, '01', STR0019, STR0020, 'C',   2, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0158, '02', STR0021, STR0022, 'C',  60, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {2,60} //Tamaño de campos definidos en F3H
	cAuxArch := "Motivo_emision_RE.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0158)

	/***	Venta de Vehículos	***/
	cNomeArq := 'S024'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0159, '01', STR0019, STR0020, 'C',   1, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0159, '02', STR0021, STR0022, 'C',  50, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {1,50} //Tamaño de campos definidos en F3H
	cAuxArch := "Venta_vechiculos.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0159)

	/***	Tipo de Combustible	***/
	cNomeArq := 'S025'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0160, '01', STR0019, STR0020, 'C',   1, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0160, '02', STR0021, STR0022, 'C',  50, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {1,50} //Tamaño de campos definidos en F3H
	cAuxArch := "Tipo_combustible.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0160)

	/***	Modalidad de Transp	***/
	cNomeArq := 'S026'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0161, '01', STR0019, STR0020, 'C',   1, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0161, '02', STR0021, STR0022, 'C',  10, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {1,10} //Tamaño de campos definidos en F3H
	cAuxArch := "Modalidad_tansporte.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0161)

	/***	Responsable del Flete	***/
	cNomeArq := 'S027'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0162, '01', STR0019, STR0020, 'C',   1, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0162, '02', STR0021, STR0022, 'C',  55, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {1,55} //Tamaño de campos definidos en F3H
	cAuxArch := "Responsable_flete.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0162)

	/***	Documento Impreso	***/
	cNomeArq := 'S028'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0163, '01', STR0019, STR0020, 'C',   1, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0163, '02', STR0021, STR0022, 'C',  24, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {1,24} //Tamaño de campos definidos en F3H
	cAuxArch := "Documento_impreso.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0163)

	/***	Tipo de Operación	***/
	cNomeArq := 'S029'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0177, '01', STR0019, STR0020, 'C',   1, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0177, '02', STR0021, STR0022, 'C',   3, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {1,3} //Tamaño de campos definidos en F3H
	cAuxArch := "Tipo_operacion.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0177)

	/***	Información del emisor	***/
	cNomeArq := 'S030'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0217, '01', STR0218, STR0218, 'C',  10, 0, '@!', 'NAOVAZIO()', '', '1'} )  //CUIT
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0217, '02', STR0219, STR0219, 'C',   6, 0, '@!', 'NAOVAZIO()', '', '1'} )  //Numero casa
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0217, '03', STR0168, STR0169, 'C',   1, 0, '@!', 'NAOVAZIO()', '', '1'} )  //Tipo Reg.
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0217, '04', STR0141, STR0140, 'C',   2, 0, '@!', 'NAOVAZIO()', '', '1'} )  //Departamento
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0217, '05', STR0142, STR0144, 'C',   3, 0, '@!', 'NAOVAZIO()', '', '1'} )  //Distrito
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0217, '06', STR0145, STR0147, 'C',   4, 0, '@!', 'NAOVAZIO()', '', '1'} )  //Ciudad
		F814ACTF3H(aTabela)
	Endif

	/***	Distritos	***/
	cNomeArq := 'S031'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0144, '01', STR0019, STR0020, 'C',   3, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0144, '02', STR0021, STR0022, 'C',  30, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {3,30} //Tamaño de campos definidos en F3H
	cAuxArch := "Distritos.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0144)


	/***	Proc. de Pago	***/
	cNomeArq := 'S032'
	If !(F3H->(dbSeek(cFilF3H + cNomeArq)))
		aTabela := {}
		aTamCpo := {}
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0215, '01', STR0019, STR0020, 'C',   1, 0, '@!', 'NAOVAZIO()', '', '1'} )
		aAdd( aTabela, { cFilF3H, cNomeArq, STR0215, '02', STR0021, STR0022, 'C',  43, 0, '@!', 'NAOVAZIO()', '', '1'} )
		F814ACTF3H(aTabela)
	Endif

	aTamCpo := {1,43} //Tamaño de campos definidos en F3H
	cAuxArch := "Procesamiento_pago.csv"
	F814ACTF3I(cPath, cNomeArq, aTamCpo, cAuxArch, STR0215)

Return

/*/{Protheus.doc} F814ACTF3I
Actualización de tabla de configuración de catálogos (F3H)
@author raul.medina
@param cPath, caracter, Ruta de archivo
@param cNomeArch, caracter, Nombre tabla
@param aTamCpo, array, Arreglo de longitudes de campos
@param cAuxArch, caracter, Nombre del archivo
@param cTexto, caracter, Texto para mostrar durante la actualización
@param aTabela, array, Arreglo con estructura de campos
@return Nil
/*/
Static Function F814ACTF3I(cPath, cNomeArch, aTamCpo, cAuxArch, cTexto, aTabela)

	If !(F3I->(dbSeek(cFilF3I + cNomeArch)))
		If File(cPath+cAuxArch)
			Processa( {|| f814ReadFile(cPath+cAuxArch, aTamCpo, , aTabela)}, cTexto, , .T. ) //"Monedas"
		Else
			MsgAlert(STR0014 + " " + cPath+cAuxArch) //"No se encontró el archivo"
		EndIf
	Endif

Return

/*/{Protheus.doc} F814CpsTab
	Función para añadir los campos de un catálogo a crear en F3H.
	@type  Function
	@author oscar.lopez
	@since 18/10/2021
	@version version
	@param aTabela, array, Arreglo con información de los campos de la tabla a añadir
	@example
	F814CpsTab(aTabela)
	/*/
Static Function F814CpsTab(aTabela)
	Local nI := 0

	For nI := 1 To Len(aTabela)
		RecLock('F3H',.T.)
		F3H_FILIAL	:= aTabela[nI][01]
		F3H_CODIGO	:= aTabela[nI][02]
		F3H_DESC	:= aTabela[nI][03]
		F3H_ORDEM	:= aTabela[nI][04]
		F3H_CAMPOS	:= aTabela[nI][05]
		F3H_DESCPO	:= aTabela[nI][06]
		F3H_TIPO	:= aTabela[nI][07]
		F3H_TAMAN	:= aTabela[nI][08]
		F3H_DECIMA	:= aTabela[nI][09]
		F3H_PICTUR	:= aTabela[nI][10]
		F3H_VALID	:= aTabela[nI][11]
		F3H_VERSAO	:= aTabela[nI][12]
		F3H_PESQ	:= aTabela[nI][13]
		MsUnLock()
	Next nI
Return

/*/{Protheus.doc} F814ActVer
Valida la versión actual de la tabla en F3H, si está desactualizada permite borrar la tabla para actualizar.
@type function
@author raul.medina
@since 04/2022
@version 1.0
@param cTabla,		Caracter, 	Codigo de la tabla.
@param cVerAct,		Caracter, 	Versión actual en el fuente.
@param cVerF3H,		Caracter, 	Versión en la tabla F3H.

*/
Static Function F814ActVer(cTabla, cVerAct, cVerF3H)
Local lRet	:= .F.

	If cVerF3H <> cVerAct
		lRet := MsgYesNo(OemToAnsi(STR0323 + cTabla + CRLF + STR0324 + cVerF3H + CRLF + STR0325 + cVerAct + CRLF + STR0326 + CRLF + STR0327), OemToAnsi(STR0322))
		If lRet
			lRet := F814DelReg(cTabla)
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} F814ActVer
Borra los registros de la tabla.
@type function
@author raul.medina
@since 04/2022
@version 1.0
@param cCodTab,		Caracter, 	Codigo de la tabla.

*/
Function F814DelReg(cCodTab)
Local lRet   	:= .F.
Local cQuery 	:= ""
Default cCodTab := ""

		cCodTab := Alltrim(cCodTab)
		If F3I->(dbSeek(xFilial("F3I") + cCodTab))
			cQuery := "DELETE FROM " + RetSqlName("F3I") + " WHERE F3I_CODIGO ='" + cCodTab +"'"
			If TcSqlExec(cQuery) == 0
				lRet := .T.
			EndIf
		EndIf
		If lRet .and. F3H->(dbSeek(xFilial("F3H") + cCodTab))
			cQuery := "DELETE FROM " + RetSqlName("F3H") + " WHERE F3H_CODIGO ='" + cCodTab +"'"
			If TcSqlExec(cQuery) == 0
				lRet := .T.
			EndIf
		EndIf

Return lRet
