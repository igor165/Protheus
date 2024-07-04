#INCLUDE "TOTVS.CH"
#INCLUDE "FISA065.CH"
#INCLUDE "Fileio.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFISA065   บAutor  ณmayra.camargo       บFecha ณ 22/07/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGenera en archivos de texto informaci๓n que serแ importada  บฑฑ
ฑฑบ          ณen el SiFere.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP11                                                       บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.         บฑฑ
ฑฑฬอออออออออออออัออออออออออัอออออออออัออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Programador ณ  Fecha   ณLlamado  ณ  Motivo da Alteracao               บฑฑ
ฑฑฬอออออออออออออุออออออออออุอออออออออุออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Dora Vega   ณ28/02/2017ณMMI-4658 ณMerge de Replica del llamado TWJQFP.บฑฑ
ฑฑบ             ณ          ณMMI-190  ณMerge de Replica del llamado TVYEIZ.บฑฑ
ฑฑบ             ณ          ณ         ณSe agrega a la rutina FISA065 la    บฑฑ
ฑฑบ             ณ          ณ         ณconsulta especifica CARPET y la pre-บฑฑ
ฑฑบ             ณ          ณ         ณgunta 06 del grupo FISA065. Agrupa  บฑฑ
ฑฑบ             ณ          ณ         ณpercepciones y retenciones.(ARG)    บฑฑ
ฑฑบRaul Ortiz M.ณ20/10/2017ณTSSERMI01ณReplica da issue MMI-5967           บฑฑ
ฑฑบ             ณ          ณ-206     ณ                                    บฑฑ
ฑฑศอออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FISA065()

Local aArea		:= getArea()   
Local oFld		:= Nil
	
Private _lRegs	:= .F.
Private oDlg1	:= Nil
Private oDialg  := Nil
Private aBrowse := {}
Private aListS  := {}
Private cFil := {} 
Private cProvi 	:= ""
Private lAuto065		:= isBlind()	

If !lAuto065	
	DEFINE MSDIALOG oDlg1 TITLE STR0001 FROM 0,0 TO 250,450 OF oDlg1 PIXEL //"Porcentaje de Exenci๓n de Percepci๓n y Retenci๓n del IVA"

	@ 020,006 FOLDER oFld OF oDlg1 PROMPT STR0002 PIXEL SIZE 165,075 	//"&Importa็ใo de Arquivo TXT"
			
		//+----------------
		//| Campos Folder
		//+----------------
	@ 005,005 SAY STR0003 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Esta rutina actualiza los porcentajes de exenci๓n de    "
	@ 015,005 SAY STR0004 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"percepci๓n y retenci๓n del IVA deacuerdo al padr๓n  "
	@ 025,005 SAY STR0005 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"emitido por la AFIP.   "                        "

		//+-------------------
		//| Boton de MSDialog
		//+-------------------
	@ 055,178 BUTTON STR0006 SIZE 036,016 PIXEL ACTION RunProc() 	//"&Exportar"
	@ 075,178 BUTTON STR0007 SIZE 036,016 PIXEL ACTION oDlg1:End() 	//"&Sair"	"
		
	ACTIVATE MSDIALOG oDlg1 CENTER
Else	
	RunProc() 
EndIf		
Restarea(aArea)


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRunProc   บAutor  ณmayra.camargo       บFecha ณ 22/07/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza el procesamiento seg๚n la o las opciones elegidas  บฑฑ
ฑฑบ          ณ en el parแmetro MV_05.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP11                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RunProc()
	Local aDatos	:= {}
	
	Private aFilsCalc	:= {}
	Private dDeFech	:= CTOD("//")
	Private dAFech 	:= CTOD("//")
	//Private cProvi 	:= ""
	Private cRuta 	:= ""
	Private cArch	:= ""
	Private nSuc	:= 0
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ MV_PAR01 -> De Fecha                                      ณ
	//ณ MV_PAR02 -> Hasta Ficha                                   ณ
	//ณ MV_PAR03 -> De Provincia                                  ณ
	//ณ mv_par04 -> Ruta                                          ณ
	//ณ MV_PAR05 -> Tipo de Archivo                               ณ
	//ณ MV_PAR06 -> Selecciona Sucursales                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If !lAuto065
		IF Pergunte("FISA065",.T.)
			
			dDeFech	:= MV_PAR01
			dAFech 	:= MV_PAR02
			cProvi 	:= MV_PAR03
			cRuta 	:= MV_PAR04
			cArch	:= MV_PAR05
			nSuc	:= MV_PAR06
			
			IF ValidParam()
				aFilsCalc := MatFilCalc( nSuc == 1, , , .F., , .F.)
				If Empty( aFilsCalc )
					Return
				EndIf			
				If '1' $ cArch
					Processa( {|| GenArqRet(@aDatos)}		, STR0012,STR0010, .T. ) //Seleccionando registros...
					Processa( {|| genFile(aDatos,STR0014)}	, STR0012,STR0011, .T. ) //Creando archivo
				EndIF
				IF '2' $ cArch
					aDatos := {}
					Processa( {|| GenArqPer(1,@aDatos)}		, STR0012,STR0010, .T. )//Seleccionando registros...
					Processa( {|| genFile(aDatos,STR0015)}	, STR0012,STR0011, .T. )//Creando archivo
				EndIF
				IF '3' $ cArch
					aDatos := {}
					Processa( {|| GenArqPer(3,@aDatos)}		, STR0012,STR0010, .T. )//Seleccionando registros...
					Processa( {|| genFile(aDatos,STR0016)}	, STR0012,STR0011, .T. )//Creando archivo
				EndIF
				IF '4' $ cArch
					aDatos := {}
					Processa( {|| GenArqPer(4,@aDatos)}		, STR0012,STR0010, .T. )//Seleccionando registros...
					Processa( {|| genFile(aDatos,STR0017)}	, STR0012,STR0011, .T. )//Creando archivo
				End If
				
				MsgAlert(STR0021)
			EndIf
		EndIf
	Else
		dDeFech	:= MV_PAR01
		dAFech 	:= MV_PAR02
		cProvi 	:= MV_PAR03
		cRuta 	:= MV_PAR04
		cArch	:= MV_PAR05
		nSuc	:= MV_PAR06
		
		IF ValidParam()
			aFilsCalc := MatFilCalc( nSuc == 1, , , .F., , .F.)
			If Empty( aFilsCalc )
				Return
			EndIf			
			If '1' $ cArch
			GenArqRet(@aDatos)
			genFile(aDatos,STR0014)
			EndIF
			IF '2' $ cArch
				aDatos := {}
			 GenArqPer(1,@aDatos)
			genFile(aDatos,STR0015)
			EndIF
			IF '3' $ cArch
				aDatos := {}
			GenArqPer(3,@aDatos)
			genFile(aDatos,STR0016)
			EndIF
			IF '4' $ cArch
				aDatos := {}
				 GenArqPer(4,@aDatos)
			 genFile(aDatos,STR0017)
			EndIf
		EndIf

	EndIf
Return

//+----------------------------------------------------------------------+
//|Valida parแmetros de entrada											 |
//+----------------------------------------------------------------------+

Static Function ValidParam()
	Local lRet:=  .T.
	
	If Empty(dDeFech) .OR. Empty(dAFech) .or. Empty(cProvi) .or. Empty(cRuta) .or. Empty(cArch)
		MSgAlert(STR0008) 		
		lRet := .F.
	ElseIF YEAR(dDeFech) <> YEAR(dAFech) .AND. MONTH(dDeFech) <> MONTH(dAFech)
		MsgAlert(STR0023)
	End IF	
	
	
Return lRet

//+----------------------------------------------------------------------+
//|Obtiene los datos para generar archivo de retenciones.				 |
//+----------------------------------------------------------------------+
Static Function GenArqRet(aDatos)
	Local cQuery	:= ""
	Local cTmp		:= "TRD"
	Local nRegs		:= ""
	Local cCodJur	:= ""
	Local cProv	    := ""
	Local cProvs	:= ""
	Local nForFilial := 0
	Local cNroCert := ""
	Local nCont	:= 0
	Local aDatosAux := {}
	Local nPosCer	:= 0
	Local nPosRec	:= 0

	
	aDatos := {}
	cProvs := "'" + Strtran( Alltrim(cProvi) , "," , "','" ) + "'"
	
	For nForFilial := 1 To Len(aFilsCalc)
		cFil := aFilsCalc[ nForFilial, 2]
		If aFilsCalc[ nForFilial, 1]
	
			cQuery 	:= 	"SELECT "
			cQuery	+=		"FE_EMISSAO,"
			cQuery	+=		"FE_CLIENTE, "
			cQuery	+=		"FE_LOJCLI, "
			cQuery	+=		"FE_NROCERT,"
			cQuery	+=		"FE_NFISCAL,"
			cQuery	+=		"FE_RECIBO,"
			cQuery	+=		"SUM(FE_RETENC) AS FE_RETENC, "
			cQuery	+=		"FE_EST, "
			cQuery	+=		"A1_CGC, "
			cQuery	+=		"A1_EST "
			cQuery	+=	"FROM "
			cQuery	+=	RetSqlName("SFE")+ " SFE "			
			cQuery	+= " INNER JOIN "+RetSqlName("SA1")+" SA1"			
			cQuery	+= " ON SA1.A1_COD = FE_CLIENTE "			
			cQuery	+= " AND SA1.A1_LOJA = FE_LOJCLI "			
			If SA1->(ColumnPos("A1_MSFIL")) > 0 .AND. !Empty(SA1->A1_MSFIL)
				cQuery	+= " AND SA1.A1_MSFIL = '"+cFil+"'"
			Else
				cQuery	+= " AND SA1.A1_FILIAL = '"+xFilial("SA1",cFil)+"'"
			EndIf
			cQuery	+= " INNER JOIN "+RetSqlName("SEL")+" SEL"
			cQuery	+= " ON EL_CLIORIG = FE_CLIENTE "			
			cQuery	+= " AND EL_LOJORIG = FE_LOJCLI "
			If SEL->(ColumnPos("EL_MSFIL")) > 0 .AND. !Empty(SEL->EL_MSFIL)
				cQuery	+= " AND EL_MSFIL = '"+ cFil +"'"
			Else
				cQuery	+= " AND EL_FILIAL = '"+xFilial("SEL",cFil)+"'"
			EndIf				
			cQuery	+= " AND EL_RECIBO = FE_RECIBO "	
			cQuery	+= " AND EL_NUMERO = FE_NROCERT "
			cQuery	+=	"WHERE "
			If SFE->(ColumnPos("FE_MSFIL")) > 0 .AND. !Empty(SFE->FE_MSFIL)
				cQuery	+=		"FE_MSFIL='" + cFil+ "' AND "
			Else
				cQuery	+=		"FE_FILIAL='" + xFilial("SFE", cFil)+ "' AND "
			EndIf
			If SA1->(ColumnPos("A1_MSFIL")) > 0 .AND. !Empty(SA1->A1_MSFIL)
				cQuery	+=		"A1_MSFIL='" + cFil+ "' AND "
			Else
				cQuery	+=		"A1_FILIAL='" + xFilial("SA1", cFil)+ "' AND "
			EndIf
			cQuery	+=		"FE_CLIENTE<>' ' AND "
			cQuery	+=		"EL_DTDIGIT >='" + DTOS(MV_PAR01)+ "' AND "
			cQuery	+=		"EL_DTDIGIT <='" + DTOS(MV_PAR02)+ "' AND "
			cQuery	+=		"FE_TIPO='B' AND "
			cQuery	+=		"EL_TIPODOC = 'RB' AND "
			cQuery	+=		"FE_EST IN (" + cProvs + ") AND "
			cQuery	+=		"A1_COD=FE_CLIENTE AND "
			cQuery	+=		"A1_LOJA=FE_LOJCLI AND "
			cQuery	+= 		"(SFE.FE_DTESTOR <'" + DTOS(dDeFech)+ "' OR "
			cQuery	+=		" SFE.FE_DTESTOR >'" + DTOS(dAFech)+ "' OR "
			cQuery	+=		" SFE.FE_DTESTOR = ' ' OR "
			cQuery	+=		" SFE.FE_NRETORI <> ' ' "
			cQuery	+=		") AND "
			cQuery	+=		"( "
			cQuery	+=		"SFE.FE_DTRETOR <'" + DTOS(dDeFech)+ "' OR "
			cQuery	+=		"SFE.FE_DTRETOR >'" + DTOS(dAFech)+ "' OR "
			cQuery	+=		"SFE.FE_DTRETOR = ' ' OR "
			cQuery	+=		"SFE.FE_NRETORI = ' ' "
			cQuery	+=		") AND "
			cQuery	+=		"SA1.D_E_L_E_T_=' ' AND "	
			cQuery	+=		"SFE.D_E_L_E_T_=' ' AND "
			cQuery	+=		"SEL.D_E_L_E_T_=' ' "
			cQuery	+= 		"GROUP BY FE_EMISSAO, FE_CLIENTE, FE_LOJCLI, FE_NROCERT, FE_NFISCAL, FE_RECIBO, "
			cQuery	+=		"FE_EST, A1_CGC, A1_EST "
			cQuery += 		"ORDER BY FE_NROCERT"
	
			cQuery := ChangeQuery(cQuery)
		
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)
			TcSetField( cTmp, 'FE_EMISSAO', 'D', TamSX3('FE_EMISSAO')[1], 0 )
		
			Count to nRegs
		
			ProcRegua(nRegs)
			nRegs	:= 0
			(cTmp)->(dbGoTop())
		
			While (cTmp)-> (!Eof())
				nRegs++
				IncProc(STR0010 + str(nRegs))
		
				If (cTmp)->FE_EST <> cProv
					cProv := (cTmp)->FE_EST
					cCodJur	:=	POSICIONE("CCO",1,xFilial("CCO", cFil)+cProv,"CCO_CODJUR")
				Endif
				nPosCer := ASCAN(aDatosAux,{|x| x[1] == (cTmp)->FE_NROCERT .and. x[3] == (cTmp)->FE_CLIENTE .and. x[4] == "9" + cCodJur})
				
				If nPosCer == 0
					AADD(aDatos,	{ "9" + cCodJur,;
								  	TRANSFORM((cTmp)->A1_CGC,"@R 99-99999999-9"),;
								  	strZero(DAY((cTmp)->FE_EMISSAO),2)+"/"+strZero(month((cTmp)->FE_EMISSAO),2)+"/"+strZero(YEAR((cTmp)->FE_EMISSAO),4),;
								  	IIF(!Empty((cTmp)->FE_NROCERT),strZero(Val(Substr((cTmp)->FE_NROCERT,1,4)),4)	,strZero(0,4)),;
								  	IIF(!Empty((cTmp)->FE_NROCERT),strZero(Val(Substr((cTmp)->FE_NROCERT,5)),16)	,strZero(0,15)),;
								  	"R",;
								  	"C",;
								  	IIF(!Empty((cTmp)->FE_RECIBO),strZero(Val((cTmp)->FE_RECIBO),20),strZero(0,20)),;
								  	strTran(strZero((cTmp)->FE_RETENC,11,2),".",",") } )
					cNroCert := (cTmp)->FE_NROCERT
					AADD(aDatosAux,{(cTmp)->FE_NROCERT,{(cTmp)->FE_RECIBO},(cTmp)->FE_CLIENTE,"9" + cCodJur})
					nCont++			  	
				Else
					nPosRec := ASCAN(aDatosAux[nPosCer][2],{|x| x == (cTmp)->FE_RECIBO})
					If nPosRec == 0
						aDatos[nPosCer][9]:=  strTran(strZero(Val(aDatos[nPosCer][9]) + (cTmp)->FE_RETENC,11,2),".",",")
						AADD(aDatosAux[nPosCer][2],(cTmp)->FE_RECIBO)
					EndIF			
				Endif
				(cTmp)->(dbSkip())
			End Do
			(cTmp)->(dbCloseArea())
		EndIf
	Next		
		
	aSort(aDatos,,,{ | x,y | x[2] < y[2] })
Return
//+----------------------------------------------------------------------+
//|Realiza el proceso para obtener los registrso de percepciones    	 |
//+----------------------------------------------------------------------+
//|Parแmetros	|nTipo:	Tipo de archivo a generar   					 |
//|				|	1.-Percepciones Clientes							 |
//|				|	2.-Percepciones Proveedores							 |
//|				|	3.-Percepciones Bancarias							 |
//|				|	3.-Percepciones Aduanas								 |
//|				|aDatos													 |
//|				|	Array en d๓nde serแn almacenados los datos antes     |
//|				|	de generar el txt.									 | 
//+-------------+--------------------------------------------------------+

Static Function GenArqPer(nTipo,aDatos)
	Local cCpo := ""
	Local aProv := separa(cProvi,",")
	Local cMsg := ""
	Local cCRLF := ( chr(13)+chr(10) )
	Local nI := 0
	Local aProvAux := {}
	Local cConD	:= ""
	Local nForFilial := 0
	
	For nForFilial := 1 To Len(aFilsCalc)
		cFil := aFilsCalc[ nForFilial, 2]
		If aFilsCalc[ nForFilial, 1]
			aProvAux := {}
	
			For nI := 1 to Len(aProv)
				cConD := "'" + aProv[nI] + "'" //Se asignan apostrofos para obtener
				cCpo := GetCpoImp(cConD)

				dbSelectArea("SX3")
				SX3->(dbSetOrder(2))
		
				If !SX3->(dbSeek("F3_VALIMP"+cCpo))
					cMsg += STR0019 + " F3_VALIMP" + cCpo + " " + STR0020 + cCRLF
				Else 
					Aadd(aProvAux, {aProv[nI], cCpo})
				EndIf
			Next nI
	
			IF cMsg == ""
				For nI := 1 to Len(aProvAux)
					Do Case
						Case nTipo < 3
							PerSF3(1,@aDatos,aProvAux[nI,2],aProvAux[nI,1])
							PerSF3(2,@aDatos,aProvAux[nI,2],aProvAux[nI,1])
						Case nTipo == 3
							PerSF3(3,@aDatos,aProvAux[nI,2],aProvAux[nI,1])
						Case nTipo == 4
							PerSF3(4,@aDatos,aProvAux[nI,2],aProvAux[nI,1])
					End Case
				Next nI
			Else
				MsgAlert(cMsg)
			EndIf
		EndIf
	Next nForFilial
	aSort(aDatos,,,{ | x,y | x[2] < y[2] })
Return

//+----------------------------------------------------------------------+
//|Obtiene informaci๓n de SF3 para archivo de percepciones				 |
//+----------------------------------------------------------------------+
//|Parแmetros	|nTipo:	Tipo de archivo a generar   					 |
//|				|	1.-Percepciones Clientes							 |
//|				|	2.-Percepciones Proveedores							 |
//|				|	3.-Percepciones Bancarias							 |
//|				|	3.-Percepciones Aduanas								 |
//|				|aDatos													 |
//|				|	Array en d๓nde serแn almacenados los datos antes     |
//|				|	de generar el txt.									 | 
//|				|cCpo												     |
//|				|	Campo configurado para obtener el valor del importe  |
//|				|	en SF3.												 | 
//+-------------+--------------------------------------------------------+
Static function PerSF3(nTipo,aData,cCpo,cProvn)
	
	Local aArea		:= getArea()
	Local aAreaSf1	:= SF1->(GetArea())
	Local cQuery	:= ""
	Local cTmp		:= "TRD"
	Local nRegs		:= ""
	Local cCodJur	:= ""
	Local cTipoCom	:= ""
	Local aSA6		:= {}
	Local _aArea	:= ""
	Local cClaveSA6	:= ""
	Local cDesp		:= ""
	Local nPosJur 	:= 0
	Local nTamSF1	:= TamSx3("F1_DOC")[1] //por disposici๓n de la AFIP al crear el archivo SIFERE el campo de "n๚mero fiscal" es considerado como tama๑o 12 o 13.
	Local cNfiscal	:= ""
	cCodJur	:=	POSICIONE("CCO",1,xFilial("CCO", cFil)+cProvn,"CCO_CODJUR")//MV_PAR03,"CCO_CODJUR")
	DbSelectArea("SF1")
	SF1->(DbSetOrder(2)) //F1_FILIAL+F1_FORNECE+F1_LOJA+F1_DOC
	SF1->(DbGoTop())
	RestArea(aArea)
	
	cQuery 	:= 	"SELECT "
	cQuery	+=		"F3_CLIEFOR, "
	cQuery	+=		"F3_LOJA, "
	cQuery	+=		"F3_EMISSAO, "
	cQuery	+=		"F3_ENTRADA, "
	cQuery	+=		"F3_NFISCAL, "
	cQuery	+=		"F3_ESPECIE, "
	cQuery	+=		"F3_SERIE, "
	cQuery	+=		"SUM(F3_VALIMP" + cCpo + ") AS F3_VALIMP" + cCpo + ", "
	If nTipo == 1
		cQuery	+=	"A1_CGC"
	Else
		cQuery +=	"A2_CGC, A2_TIPROV"
		If nTipo == 4
			cQuery += ", A2_BANCO, A2_AGENCIA, A2_NUMCON"
			 
		End If
	End IF
	cQuery +=	" FROM "
	cQuery	+=		RetSqlName("SF3")+ " SF3,"
	
	If nTipo == 1
		cQuery	+=		RetSqlName("SA1")+ " SA1 "
	Else
		cQuery	+=		RetSqlName("SA2")+ " SA2 "
	End IF
	
	cQuery	+=	"WHERE "
	cQuery	+=		"F3_FILIAL='" + xFilial("SF3", cFil)+ "' AND "
	
	If nTipo == 1
		cQuery	+=		"A1_FILIAL='" + xFilial("SA1", cFil)+ "' AND "
	Else
		cQuery	+=		"A2_FILIAL='" + xFilial("SA2", cFil)+ "' AND "
	End If
	
	cQuery	+=		"F3_ENTRADA >='" + DTOS(dDeFech)+ "' AND "
	cQuery	+=		"F3_ENTRADA <='" + DTOS(dAFech)+ "' AND "
	cQuery	+=		"F3_VALIMP"+cCpo+"<>0 AND "
	If nTipo == 1	// Percepciones Clientes
		cQuery	+=	"F3_TIPOMOV='V' AND "
		cQuery 	+=	"F3_ESPECIE IN ('NCE','NDE') AND "
		cQuery	+=	"A1_COD =F3_CLIEFOR  AND "
		cQuery	+=	"A1_LOJA=F3_LOJA  AND "
		cQuery	+=	"SA1.D_E_L_E_T_=' ' AND "
	Else
		cQuery 	+= 	"F3_TIPOMOV='C' AND "
		cQuery 	+=	"F3_ESPECIE IN ('NF','NDP','NCP') AND "
		
		Do Case
			Case nTipo == 2	// Percepciones Proveedores
				cQuery += "A2_TIPROV='P' AND "
			Case nTipo == 3 // Percepciones Aduanas
				cQuery += "A2_TIPROV='A' AND "			
			Case nTipo == 4 // Percepciones Bancarias
				cQuery += "A2_TIPROV='B' AND "					
		End Do
	
		cQuery	+=	"A2_COD =F3_CLIEFOR  AND "
		cQuery	+=	"A2_LOJA=F3_LOJA  AND "
		cQuery	+=	"SA2.D_E_L_E_T_=' ' AND "		
		
	End If
	cQuery	+= "SF3.D_E_L_E_T_=' ' "
	cQuery	+= "GROUP BY F3_CLIEFOR, F3_LOJA, F3_EMISSAO, F3_ENTRADA, F3_NFISCAL, F3_ESPECIE, F3_SERIE, "
	If nTipo == 1
		cQuery	+=	"A1_CGC"
	Else
		cQuery +=	"A2_CGC, A2_TIPROV"
		If nTipo == 4
			cQuery += ", A2_BANCO, A2_AGENCIA, A2_NUMCON"
		End If
	End IF
	
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)
	TcSetField( cTmp, 'F3_ENTRADA', 'D', TamSX3('F3_ENTRADA')[1], 0 )
	TcSetField( cTmp, 'F3_EMISSAO', 'D', TamSX3('F3_EMISSAO')[1], 0 )

	Count to nRegs
	
	ProcRegua(nRegs)
	nRegs	:= 0
	(cTmp)-> (dbgotop())
	While (cTmp)-> (!Eof())
		nRegs++
		IncProc(STR0010 + str(nRegs))
		IF nTipo ==1 .or. nTipo == 2			
			Do case
				Case alltrim((cTmp)->F3_ESPECIE) $ 'NF '
					cTipoCom:= 'F'			
				Case alltrim((cTmp)->F3_ESPECIE) $ 'NDE|NDP' 
					cTipoCom:= 'D'
				Case alltrim((cTmp)->F3_ESPECIE) $ 'NCP|NCE'
					cTipoCom:= 'C'
			End Do
			cNfiscal:= Right(PadL(ALLTRIM((cTmp)->F3_NFISCAL),nTamSF1,"0"),12) //Numero de doc a tama๑o 12
			AADD(aData,	{ "9" + cCodJur,;														//CodJur
			IIF(nTipo==1,	TRANSFORM((cTmp)->A1_CGC,"@R 99-99999999-9"),;		//cuit
			TRANSFORM((cTmp)->A2_CGC,"@R 99-99999999-9")),;
			strZero(DAY((cTmp)->F3_ENTRADA),2)+"/"+strZero(month((cTmp)->F3_ENTRADA),2)+"/"+strZero(YEAR((cTmp)->F3_ENTRADA),4),;//fecha
			IIF(!Empty(cNfiscal),strZero(Val(Substr(cNfiscal,1,4)),4),strZero(0,4)),;						//sucursal
			IIF(!Empty(cNfiscal),strZero(Val(Substr(cNfiscal,5)),8)	,strZero(0,8)),;							//constancia
			cTipoCom,;																												//tipo comprobante
			Substr((cTmp)->F3_SERIE,1,1),;																							//letra
			strTran(strZero(IIF(cTipoCom=="C",-1,1)*(cTmp)->&("F3_VALIMP"+cCpo),11,2),".",",")}) //importe	

		ElseIf nTipo==3
			cDesp := ""
			If	SF1->(FieldPos("F1_NUMDES")) > 0 .and. (cTmp)->A2_TIPROV == "A" 
				If SF1->(dbSeek( xFilial("SF1", cFil)+(cTmp)->F3_CLIEFOR+(cTmp)->F3_LOJA+(cTmp)->F3_NFISCAL ))
					If	SF1->(!Eof()) .and. ;
						!(Substr(Alltrim(SF1->F1_NUMDES),6,2) $ "|CO|IT|LA|LN|RE|RZ|TB|TG|TL|TR|TZ|") // Excluirse Importaciones no definitivas
						cDesp := Alltrim(SF1->F1_NUMDES)
					Endif
				Endif 
			Endif
				
			AADD(aData,{ "9" + cCodJur,;
			TRANSFORM((cTmp)->A2_CGC,"@R 99-99999999-9"),;
			strZero(DAY((cTmp)->F3_EMISSAO),2)+"/"+strZero(month((cTmp)->F3_EMISSAO),2)+"/"+strZero(YEAR((cTmp)->F3_EMISSAO),4),;
			strCar(cDesp,20),;
			strTran(strZero((cTmp)->&("F3_VALIMP"+cCpo),10,2),".",",")})
						 	
		ElseIf nTipo==4
			cClaveSA6	:= (cTmp)->A2_BANCO+(cTmp)->A2_AGENCIA+(cTmp)->A2_NUMCON
			
			_aArea:=getArea()
			aSA6:= GetAdvFVal("SA6", { "A6_CBU", "A6_MOEDA"},xFilial("SA6", cFil)+ cClaveSA6, 1)
			RestArea(_aArea)
			
			nPosJur := ASCAN(aData,{|x|x[1] + x[2] == "9" + cCodJur + TRANSFORM((cTmp)->A2_CGC,"@R 99-99999999-9")})
			If  nPosJur == 0
				AADD(aData,{ "9" + cCodJur,;
				TRANSFORM((cTmp)->A2_CGC,"@R 99-99999999-9"),;
				strZero(Year(dAFech),4)+"/"+strZero(month(dAFech),2),;
				strCar(aSA6[1],22),;
				STR0022,;
				IIF(aSA6[2]==1,'P','E'),;
				strTran(strZero((cTmp)->&("F3_VALIMP"+cCpo),10,2),".",",")})
			Else
				aData[nPosJur][7] := strTran(strZero(Val(strTran(aData[nPosJur][7],",",".")) + (cTmp)->&("F3_VALIMP"+cCpo),10,2),".",",")
			EndIf
		
		End IF
		(cTmp)-> (dbSkip())
	End Do
	(cTmp)-> (dbCloseArea())
	RestArea(aAreaSf1) 	
	RestArea(aArea)
Return 

//+----------------------------------------------------------------------+
//|Obtiene el campo del cuแl se obtendrแ el importe de las percepciones	 |
//+----------------------------------------------------------------------+

Static Function GetCpoImp(cCon)

	Local aArea		:= getArea()
	Local cQuery	:= ""
	Local cTmp		:= "TRX"
	Local cCpo		:= ""
	
	cQuery	:= 	"SELECT " 
	cQuery	+=		"FB_CPOLVRO "
	cQuery	+=	"FROM "
	cQuery	+=		RetSqlName("SFB") + " SFB "
	cQuery	+=	"WHERE "
	cQuery	+=		"FB_FILIAL='"+ xFilial("SFB", cFil)+"' AND "
	cQuery	+=		"FB_ESTADO IN (" + cCon +") AND "
	cQuery	+=		"FB_CLASSIF='1' AND "
	cquery	+=		"FB_CLASSE='P' AND "
	cQuery	+=		"D_E_L_E_T_=' ' "
    cQuery +=   "ORDER BY FB_ESTADO"
	
	cQuery := ChangeQuery(cQuery)           

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)
		 
	While (cTmp)-> (!Eof())
		cCpo := (cTmp)->FB_CPOLVRO
		(cTmp)->(dbskip())
	EndDo
	(cTmp)->(dbCloseArea())
	
Return cCpo


//+----------------------------------------------------------------------+
//|Genera el archivo de texto 											 |
//+----------------------------------------------------------------------+
//|Parแmetros	|aArq:	Array con los datos a registrar en el archivo	 |
//|				|	de Texto.											 |
//|				|cNameFile												 |
//|				|	Nombre del archivo que s erแ generado.     			 |
//|				|	de generar el txt.									 |  
//+-------------+--------------------------------------------------------+
Static Function genFile(aArq,cNameFile)
	
	Local cLinea	:= ""
	Local nI		:= 0
	Local nJ		:= 0
	Local cFileName	:= ""
	
	If !ExistDir(cRuta)
		MsgAlert(STR0018) 
		Return	.F.
	End If 
	cFileName := alltrim(cRuta) + cNameFile
	If File(cNameFile)	
		FErase(cNameFile) 
	End If
	

	nArqLog	:= MSfCreate(cFileName, 0)
		
	ProcRegua(Len(aArq))		
	
	For nI:=1 To Len(aArq)
		
		IncProc(STR0013 + str(nI))	
		For nJ:= 1 to Len(aArq[nI])
			cLinea	+= aArq[nI,nJ]					
		Next nJ
		
		FWrite(nArqLog,cLinea+Chr(13)+Chr(10))		
		cLinea:= ""
	Next nI  

	FClose(nArqLog) 
	
Return .T. 


Static function strCar(cValImp,nTam)
	Local cRet
	cRet := Replicate("0",nTam-LEN(alltrim(cValImp))) + alltrim(cValImp)	
Return cRet

/*///////////////////////////////////////////////////////////////
///Funcion de la consulta especifica FI065P (se regresa .T.) ///
////////////////////////////////////////////////////////////////
*/
Function FI065P(aBrowse)
	Local cQuery  := ""

	Local bSetF4 := {|| MarcaTodos(oBrowse,@aBrowse)}
	Local bSetF5 := {|| DesMarcaTodos(oBrowse,@aBrowse)}
	Local bSetF6 := {|| InvSel(oBrowse,@aBrowse)}
	Local oOk    := LoadBitmap( GetResources(), "LBOK")
	Local oNo    := LoadBitmap( GetResources(), "LBNO")
	lOCAL cClv:= ""
	Local cProv := ""

	Private aCampos := {}
	Private cNom    := CriaTrab(Nil, .F.)

	if empty(aListS)
		aBrowse = {}
		cQuery := " SELECT"
		cQuery += "x5_CHAVE, X5_DESCSPA"
		cQuery += " FROM " + RetSQLName("SX5")
		cQuery += " WHERE x5_TABELA = '12' AND D_E_L_E_T_ <> '*' " 
		cQuery += "ORDER BY X5_CHAVE"

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNom,.F.,.T.)

		(cNom)->(dbGoTop())
		While !(cNom)->(EOF())
			AADD(aBrowse,{.f.,(cNom)->X5_CHAVE,(cNom)->X5_DESCSPA})
			(cNom)->(dbskip())
		Enddo
	else
		aBrowse := aListS
	endIf

	If Len(aBrowse)<> 0

		getCampos(aCampos)
		DEFINE DIALOG oDialg TITLE STR0024 FROM 180,180 TO 500,650 PIXEL //Provincias

		oBrowse := TCBrowse():New( 01 , 01, 237, 130,,;
		{'',aCampos[1],aCampos[2]},{40,30,140},;
		oDialg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

		oBrowse:SetArray(aBrowse)

		oBrowse:bLine      := {|| {IIf(aBrowse[oBrowse:nAt,1],oOk ,oNo ),;
		aBrowse[oBrowse:nAt,2],;
		aBrowse[oBrowse:nAt,3]}}

		oBrowse:bLDblClick   := {|| aBrowse[oBrowse:nAt][1] := !aBrowse[oBrowse:nAt][1], oBrowse:Refresh() }

		TButton():New( 146, 195, STR0025, oDialg,{|| aBrowse := {},ObtProv(aBrowse,cClv),oDialg:End(), MV_PAR10 := 1, aListS:= {}},40,010,,,.F.,.T.,.F.,,.F.,,,.F.)//Cancelar
		TButton():New( 146, 152, STR0026, oDialg,{|| cProvi := ObtProv(aBrowse,cClv),ValSelProv(@aBrowse,cClv),aListS := aBrowse},40, 010,,,.F.,.T.,.F.,,.F.,,,.F. )//Confirmar

		TButton():New( 146, 05, STR0027, oDialg,{|| Eval(bSetF4) },65,010,,,.F.,.T.,.F.,,.F.,,,.F.)//Marcar Todos
		TButton():New( 133, 05, STR0028, oDialg,{||  Eval(bSetF5)},65,010,,,.F.,.T.,.F.,,.F.,,,.F.)//Desmarcar Todos
		TButton():New( 146, 75, STR0029, oDialg,{|| Eval(bSetF6) },65,010,,,.F.,.T.,.F.,,.F.,,,.F.)//Invierte Seleccion
		ACTIVATE DIALOG oDialg CENTERED
	EndIf

	Return  .F.

static function getCampos(aCampos)
	Local cChave
	Local cDescri
		
	dbSelectArea("SX3")
	dbSetOrder(2)
	
	If dbSeek("X5_CHAVE")
		cChave := X3Titulo()
	EndIf
	If dbSeek("X5_DESCRI")
		cDescri := X3Titulo()
	EndIf
	
	AADD(aCampos,AllTrim(cChave))
	AADD(aCampos,AllTrim(cDescri))

Return aCampos

Static Function MarcaTodos(oListBox,aListBox)

	Local nI := 0

	For nI :=1 to len(aListBox)
		aListBox [nI][1] := .T.
	Next
	oListBox:nColPos := 1
	oListBox:Refresh()

Return

Static Function DesMarcaTodos(oListBox,aListBox)
	Local nI := 0

	For nI :=1 to len(aListBox)
		aListBox[nI][1] := .F.
	Next
	oListBox:nColPos := 1
	oListBox:Refresh()

Return

Static Function InvSel(oListBox,aListBox)
	Local nI := 0

	For nI :=1 to len(aListBox)
		aListBox[nI][1] := !aListBox[nI][1]
	Next
	oListBox:nColPos := 1
	oListBox:Refresh()

Return

Static Function ValSelProv(aListBox,cClv)
	Local nI := 0
	Local nE := 0

	For nI :=1 to len(aListBox)
		If aListBox[nI][1] = .F.
			nE := nE + 1
		EndIf
	Next

	If nE == LEN(aListBox)
		MsgAlert(STR0030)
	Else
		oDialg:End()
	EndIf

Return

Function ObtProv (aListBox,cClv)
	Local nI := 0

	If !Empty(aListBox)
		For nI :=1 to len(aListBox)
			If aListBox[nI][1] = .T.

				cClv+=  ALLTRIM(aListBox[nI][2]) += ","

			EndIf
		Next
		cClv := substr(cClv,1,len(cClv)-1)
		If !Empty(cClv)
			M->MV_PAR03:= cClv
		Else
			M->MV_PAR03:= cProvi
		Endif
	else
		cProvi := ALLTRIM(cProvi)
		M->MV_PAR03:= cProvi
	EndIF

Return   cClv
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณCarpeta     ณ Autor ณ ARodriguez          ณ Data ณ 18/01/17 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณConsulta especial, permite selecciona un directorio         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ.T.                                                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณProtheus - SXB                                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function Carpeta()
	Local cTipo		:= ""
	Local cCpoVld	:= ReadVar()
	
	&(cCpoVld) := cGetFile( cTipo , OemToAnsi(STR0031),,,.F.,GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_RETDIRECTORY)

Return(.T.)
