#INCLUDE "TOTVS.CH"
#INCLUDE "FISA086.CH"   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FISA086   ºAutor  ³Emanuel Villicaña V.ºFecha ³ 01/10/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Replica de llamado TIIIS5 (P10)                             º±±
±±º          ³Genera en archivo de texto informacion que sera importada   º±±
±±º          ³AFIP -DGI - REGIMEN INFORMATIVO DE OPERACIONES EN EL        º±±
±±º          ³MERCADO INTERNO                                             º±±
±±º          ³en el aplicativo S.I.A.P.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P11                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FISA086()
	Local aArea	:= getArea()   
	Local oFld		:= Nil
	Private _lRegs	:= .F.
	Private oDial	:= Nil
	
	DEFINE MSDIALOG oDial TITLE STR0001 FROM 0,0 TO 250,450 OF oDial PIXEL //"Generacion de archivos de Operaciones del mercado interno"

		@ 020,006 FOLDER oFld OF oDial PROMPT STR0002 PIXEL SIZE 165,075 	//"&Geneneracion de archivo TXT
		
		//+----------------
		//| Campos Folder 
		//+----------------
		@ 005,005 SAY STR0003 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Exportación de Operaciones Mercado Interno - Regimen de Información"
		@ 015,005 SAY STR0004 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"para procesar en el aplicativo web S.I.A.P a traves de "
		@ 025,005 SAY STR0005 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"archivos de texto."		

		//+-------------------
		//| Boton de MSDialog
		//+-------------------
		@ 055,178 BUTTON STR0006 SIZE 036,016 PIXEL OF oDial ACTION RunProc() 	//"&Exportar"
		@ 075,178 BUTTON STR0007 SIZE 036,016 PIXEL OF oDial ACTION oDial:End() 	//"&Sair"

	 
	ACTIVATE MSDIALOG oDial CENTER
		
	Restarea(aArea)


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RunProc   ºAutor  ³Antonio Trejo       ºFecha ³ 28/08/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza el procesamiento según la o las opciones elegidas  º±±
±±º          ³ en el parámetro MV_05.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP11                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RunProc()
Local aDatos		:= {}  
Local aSX1   	:= {}
Local aEstrut	:= {}
Local nI      	:= 0
Local nJ      	:= 0
Local lSX1	 	:= .F.                              
Local nTamSx1Grp:= Len(SX1->X1_GRUPO)  

aEstrut:= {	"X1_GRUPO"  ,"X1_ORDEM"  ,"X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO"   ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL",;
	"X1_GSC"    ,"X1_VALID"  ,"X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01"  ,"X1_VAR02"  ,"X1_DEF02"  ,;
	"X1_DEFSPA2","X1_DEFENG2","X1_CNT02"  ,"X1_VAR03" ,"X1_DEF03"  ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03"  ,"X1_VAR04"  ,"X1_DEF04",;
	"X1_DEFSPA4","X1_DEFENG4","X1_CNT04"  ,"X1_VAR05" ,"X1_DEF05"  ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05"  ,"X1_F3"     ,"X1_GRPSXG","X1_PYME"}

	
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))                    
	If !dbSeek("FISA086")  
	
		aAdd (aSx1, {PadR("FISA086",nTamSx1Grp), "01", "De fecha?", "De Fecha?", "Date From?",;
			 "MV_CH1","D",8, 0, 0,"G","","MV_PAR01","","","","","","","","",;
			    	"","","","","","","","","","","","","","","","","","","" })
			    	
	   	aAdd (aSx1, {PadR("FISA086",nTamSx1Grp), "02", "Hasta Fecha?", "Hasta Fecha?", "Hasta Fecha?",;
			 "MV_CH2","D",8, 0, 0,"G","IIF(M->MV_PAR02<MV_PAR01,.F.,.T.) ","MV_PAR02","","","","","","","","",;
			    	"","","","","","","","","","","","","","","","","","","" })
			    	
		aAdd (aSx1, {PadR("FISA086",nTamSx1Grp), "03", "Ruta y Nombre de Archivo?", "Ruta y Nombre de Archivo?", "Ruta y Nombre de Archivo?",;
			 "MV_CH3","C",80, 8, 0,"G","NaoVazio()","MV_PAR03","","","","","","","","",;
			    	"","","","","","","","","","","","","","","","","","","" })
			    	
		aAdd (aSx1, {PadR("FISA086",nTamSx1Grp), "04", "Consolida Sucursales?", "Consolida Sucursales?", "Consolida Sucursales?",;
			 "MV_CH4","C",8, 0, 1,"C","","MV_PAR04","SI","SI","SI","","","NO","NO","NO",;
			    	"","","","","","","","","","","","","","","","","","","" })

	EndIf
	
ProcRegua(Len(aSX1))

dbSelectArea("SX1")
dbSetOrder(1)
For nI:= 1 To Len(aSX1)
	If !Empty(aSX1[nI][1])
		If !dbSeek(PADR(aSX1[nI,1],nTamSx1Grp)+aSX1[nI,2])
			lSX1	:= .T.
			RecLock("SX1",.T.)

			For nJ:=1 To Len(aSX1[nI])
				If !Empty(FieldName(FieldPos(aEstrut[nJ])))
					FieldPut(FieldPos(aEstrut[nJ]),aSX1[nI,nJ])
				EndIf
			Next nJ

			MsUnLock()
			IncProc("Atualizando Perguntas de Relatorios...")
		EndIf
	EndIf
Next nI
	
	
	IF Pergunte("FISA086",.T.)
		
		IF ValidParam()
			cFileNameTxt 	:= MV_PAR03		
			Processa( {|| GenArqRet(@aDatos)}		, STR0012,STR0010, .T. )
		Endif	
	Endif
Return

//+----------------------------------------------------------------------+
//|Valida parámetros de entrada											 |
//+----------------------------------------------------------------------+

Static Function ValidParam()
	Local lRet:=  .T.
	
	If Empty(MV_PAR01) .OR. Empty(MV_PAR02) .or. Empty(MV_PAR03)
		MSgAlert(STR0008) 		
		lRet := .F.
	ElseIF YEAR(MV_PAR01) <> YEAR(MV_PAR02) .AND. MONTH(MV_PAR01) <> MONTH(MV_PAR02)
		MsgAlert(STR0018)
	Endif		
	
	if Empty(MV_PAR03)
		lRet := .F.
		MsgAlert(STR0014)
	Endif
Return lRet

//+----------------------------------------------------------------------+
//|Obtiene los datos para generar archivo 					             |
//+----------------------------------------------------------------------+
Static Function GenArqRet(aDatos)
	Local cBkpFil	:= cFilAnt
	Local nProcFil := 0
	Local cFileNameTxt := mv_par03
	Local cCuit := ""
	Local lPvez := .F.
	Private aFilsCalc  := {}
	Private oTmpTable  := Nil
	

	aFilsCalc := MatFilCalc( mv_par04 == 1 )
	If mv_par04 == 1 // Ordeno Matriz por sucursal y Cuit
		aFilsCalc := asort(aFilsCalc,,,{|x,y|  x[4]+x[2] < y[4]+y[2] }) 
	Endif 
	aDatos := {}

	CriaCursor()
	If  mv_par04 <> 1 //Significa que sera consolidado y que hubo seleccion de Sucursales
		ExtraeCtes(@aDatos,cFilAnt)
		ExtraeProv(@aDatos,cFilAnt)
		ActArreglo(@aDatos)
		Processa( {|| genFile(aDatos,RTRIM(cFileNameTxt) + "-" + alltrim(cBkpFil) + ".txt")}	, STR0012,STR0011, .T. )
	Else
		For nProcFil:=1 to len(aFilsCalc)
			cFilAnt := aFilsCalc[nProcFil,2]
			If aFilsCalc[nProcFil,1] == .T.
				If Empty(cCuit)
					cCuit := Alltrim(aFilsCalc[nProcFil,4])
				ElseIf cCuit <> Alltrim(aFilsCalc[nProcFil,4])
					ActArreglo(@aDatos)
					Processa( {|| genFile(aDatos,RTRIM(cFileNameTxt) + "-" + cCuit + ".txt")}	, STR0012,STR0011, .T. )
					RIOMI-> (dbCloseArea())
					aDatos := {}					 
					CriaCursor()
					cCuit := Alltrim(aFilsCalc[nProcFil,4])
				Endif 
				ExtraeCtes(@aDatos,cFilAnt)
				ExtraeProv(@aDatos,cFilAnt)					
			Endif 
		Next nProcFil
		ActArreglo(@aDatos)
		Processa( {|| genFile(aDatos,RTRIM(cFileNameTxt) + "-" + cCuit + ".txt")}	, STR0012,STR0011, .T. )
	Endif 

	RIOMI-> (dbCloseArea()) 
	cFilAnt := cBkpFil
	
	If oTmpTable <> Nil
		oTmpTable:Delete()
		oTmpTable := Nil
	EndIf
Return


/*                                                                     
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion    ³ ActArreglo ³Autor ³ Emanuel Villicaña   ³ Fecha ³07/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion³ Actualizo la informacion que saldra                        ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ ExtraeCtes(aDatos)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ACTUALIZACIONES SUFRIDAS DESDE LA CONSTRUCCION INICIAL         ³±±                
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Fecha  ³ BOPS ³  Motivo de alteracion                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ActArreglo(aDatos)
	RIOMI->(dbSetOrder(2)) // RIM_PV + RIM_NUMCOM + RIM_ENC + RIM_FCOM + RIM_TREG  + RIM_ALIQ
	RIOMI->(dbGoTop())

	While RIOMI-> (!Eof())
		Do Case
		Case RIOMI->RIM_ENC = "T1"
			AADD(aDatos,{RIOMI->RIM_TMOV + RIOMI->RIM_TREG + RIOMI->RIM_TCOM + ;
				RIOMI->RIM_PV + RIOMI->RIM_NUMCOM + RIOMI->RIM_FCOM + RIOMI->RIM_MT + RIOMI->RIM_CUIT + RIOMI->RIM_RAZON + RIOMI->RIM_INTCU + ;
				STRZERO(RIOMI->RIM_TIOPE*100,15) + ; // IMPORTE TOTAL DE OPERACIÓN
				STRZERO(RIOMI->RIM_INOGR*100,15) + ; // IMPORTE NO. INTEGRAN EL NETO GRAVADO
				STRZERO(RIOMI->RIM_INGRA*100,15) + ; // IMPORTE NETO GRAVADO	
				STRZERO(RIOMI->RIM_IOPEX*100,15)})  // IMPORTE OPERACIONES EXENTAS		
		Case RIOMI->RIM_ENC = "T2"
			AADD(aDatos,{RIOMI->RIM_TMOV + RIOMI->RIM_TREG + RIOMI->RIM_TCOM + ;
				RIOMI->RIM_PV + RIOMI->RIM_NUMCOM + RIOMI->RIM_CUIT + ;
				RIOMI->RIM_ALIQ + ; // ALICUOTA
				STRZERO(RIOMI->RIM_ILIQ*100,15)})  // IMPUESTO LIQUIDADO
		Case RIOMI->RIM_ENC = "T3"	
			AADD(aDatos,{RIOMI->RIM_TMOV + RIOMI->RIM_TREG + RIOMI->RIM_TCOM + ;
				RIOMI->RIM_PV + RIOMI->RIM_NUMCOM + RIOMI->RIM_CUIT +  RIOMI->RIM_TOPE}) 
		EndCase
		RIOMI->(dbSkip())						
	EndDo
Return 

/*                                                                      
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion    ³ ExtraeCtes ³Autor ³ Emanuel Villicaña   ³ Fecha ³07/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion³ Extraccion de informacion de clientes                      ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ ExtraeCtes(aDatos)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ACTUALIZACIONES SUFRIDAS DESDE LA CONSTRUCCION INICIAL         ³±±                
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Fecha  ³ BOPS ³  Motivo de alteracion                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ExtraeCtes(aDatos,cFilAnt)
	Local cQuery	:= ""
	Local cTmp		:= "TRD"
	Local cQf3     := criatrab(nil,.F.)
	Local nRegs	:= 0
	Local aNrLvrPIG :={}
	Local nX 	:= 0
	Local cCampo := ""
	Local cCTmp := ""
	Local nIBasF3 := 0
	Local nIValF3 := 0
	Local nValBru := 0

	Local cCompr := ""
	Local cSerie := ""
	Local cEspec := ""
	Local cCte   := ""
	Local cLoja  := ""
	Local cCuit  := ""
	Local cNatu  := ""
	Local cEmiss := ""
	Local cCuitIn:= ""
	Local cFilSE1:= xFilial("SE1")
	Local cFilSF3:= xFilial("SF3")
	Local cFilSF2:= xFilial("SF2")
	Local aTES   := {}
	Local nPos   := 0
	Local nVImpNoG := 0
	
	Private aNrLvIVA := {}
	
	Default cFilAnt:= ""
	
	aNrLvrPIG = SiapImp('3',{'I', 'P'},IIf(Empty (cFilSF3), cFilAnt, cFilSF3)) //SFB - IMPUESTOS VARIABLES
	
	cQuery 	:= 	"SELECT E1_FILIAL,E1_FILORIG,E1_CLIENTE, E1_LOJA, E1_TIPO, E1_SERIE, E1_NUM, E1_EMISSAO, E1_VALOR, E1_NATUREZ,E1_VLCRUZ,E1_MOEDA, "
	cQuery	+=		"A1_COD, "
	cQuery	+=		"A1_CGC, "
	cQuery	+=		"A1_NOME, "
	cQuery	+=		"ISNULL((Select SUM(F3_EXENTAS) from "
	cQuery	+=		RetSqlName("SF3") + " SF3 "
	cQuery	+=	    "WHERE "	
	If Empty (cFilSF3)
		cQuery	+= "F3_MSFIL='" + cFilAnt+ "' AND "
	Else
		cQuery	+= "F3_FILIAL='" + cFilSF3+ "' AND "
	EndIf
	If Empty (cFilSE1)
		cQuery	+= "E1_MSFIL='" + cFilAnt+ "' AND "
	Else
		cQuery	+= "E1_FILIAL='" + cFilSE1+ "' AND "
		cQuery	+= "E1_FILORIG='" + cFilAnt+ "' AND " 
	EndIf	 
	cQuery	+=		"F3_CLIEFOR = E1_CLIENTE AND F3_LOJA = E1_LOJA AND "
	cQuery	+=		"F3_NFISCAL = E1_NUM AND F3_SERIE = E1_SERIE AND F3_ESPECIE = E1_TIPO),0 ) F3_EXENTAS, "
	cQuery	+=		"ISNULL((SELECT SF2.R_E_C_N_O_ FROM "
	cQuery	+=		RetSqlName("SF2") + " SF2 "
	cQuery	+=	    "WHERE "	
	If Empty (cFilSF2)
		cQuery	+= "F2_MSFIL='" + cFilAnt+ "' AND "
	Else
		cQuery	+= "F2_FILIAL='" + cFilSF2+ "' AND "
	EndIf
	If Empty (cFilSE1)
		cQuery	+= "E1_MSFIL='" + cFilAnt+ "' AND "
	Else
		cQuery	+= "E1_FILIAL='" + cFilSE1+ "' AND "
		cQuery	+= "E1_FILORIG='" + cFilAnt+ "' AND "  
	EndIf	  
	cQuery	+=		"F2_CLIENTE = E1_CLIENTE AND F2_LOJA = E1_LOJA "
	cQuery	+=		"AND F2_DOC = E1_NUM AND F2_SERIE = E1_SERIE AND F2_ESPECIE = E1_TIPO "
	cQuery	+=		"AND SF2. d_e_l_e_t_ = ' '),0 ) F2_REG, "
	cQuery	+=		"SE1 .R_E_C_N_O_ E1_REG "								
	cQuery 	+=	"FROM " 
	cQuery	+=		RetSqlName("SE1")+ " SE1,"
	cQuery	+=		RetSqlName("SA1")+ " SA1, "
	cQuery	+=		RetSqlName("AI0")+ " AI0 "	
	cQuery	+=	"WHERE "
	If Empty (cFilSE1)
		cQuery	+= "E1_MSFIL='" + cFilAnt+ "' AND "
	Else
		cQuery	+= "E1_FILIAL='" + cFilSE1+ "' AND "
		cQuery	+= "E1_FILORIG='" + cFilAnt+ "' AND "         
	EndIf	
	cQuery	+=		"A1_FILIAL='" + xFilial("SA1")+ "' AND "
	cQuery	+=		"E1_CLIENTE = A1_COD AND "
	cQuery	+=		"E1_LOJA = A1_LOJA AND "		
	cQuery	+= 		"E1_EMISSAO >='" + DTOS(MV_PAR01)+ "' AND "
	cQuery	+=		"E1_EMISSAO <='" + DTOS(MV_PAR02)+ "' AND "
	cQuery	+=		"AI0_FILIAL='" + xFilial("AI0")+ "' AND "
	cQuery	+=		"AI0_CODCLI = A1_COD AND "
	cQuery	+=		"AI0_LOJA = A1_LOJA AND "		
	cQuery	+=		"AI0_RG3572 = '1' AND " 		  
	cQuery	+=		"SA1.D_E_L_E_T_=' ' AND "
	cQuery	+=		"AI0.D_E_L_E_T_=' ' AND "
	cQuery	+=		"SE1.D_E_L_E_T_=' ' "
	cQuery	+=		"ORDER BY A1_CGC,E1_SERIE,E1_NUM"

	cQuery := ChangeQuery(cQuery)                    

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.) 
	TcSetField( cTmp, 'E1_EMISSAO', 'D', TamSX3('E1_EMISSAO')[1], 0 )

	Count to nRegs
	ProcRegua(nRegs)
	nRegs	:= 0
	(cTmp)->(dbGoTop())

	While (cTmp)->(!EOF())
	   cCompr := (cTmp)->E1_NUM
	   cSerie := (cTmp)->E1_SERIE
	   cEspec := (cTmp)->E1_TIPO
	   cCte   := (cTmp)->E1_CLIENTE
	   cLoja  := (cTmp)->E1_LOJA
	   cCuit  := PadR(Alltrim((cTmp)->A1_CGC), 11)
	   cCuitIn:= "00000000000"
	   cNatu  := (cTmp)->E1_NATUREZ
	   cEmiss := STR(YEAR((cTmp)->E1_EMISSAO),4) + STRZERO(MONTH((cTmp)->E1_EMISSAO),2) + STRZERO(DAY((cTmp)->E1_EMISSAO),2)
	   	
	   If ((cTmp)->F2_REG > 0) // Si existe informacion en Encabezado de factura
			SF2->(DBGOTO((cTmp)->F2_REG))
			cNatu  := iif(!empty(cNatu),cNatu,SF2->F2_NATUREZ)
	   Endif 

		// Verifico si documento maneja IVA - SF3
		If Select (cQf3)>0
			DbSelectArea (cQf3)
            (cQf3)->( DbCloseArea())
		Endif

		If  RIOMI->(DbSeek("T1" + "V" + cCuit + StrZero(Val(SUBSTR(cCompr,1,4)),4) + StrZero(Val(SUBSTR(cCompr,5,8)),20) + cEmiss))  
			RecLock("RIOMI",.F.)
			If SF2->F2_MOEDA <> 1
				RIOMI->RIM_TIOPE +=  (cTmp)->E1_VlCRUZ
			Else
				RIOMI->RIM_TIOPE +=  (cTmp)->E1_VALOR // IMPORTE TOTAL DE OPERACIÓN
			EndIF	
			RIOMI->(MsUnlock())
			(cTmp)->(DbSkip()) 
			Loop       
		Endif 

		cQuery	:= ""
		cQuery	+=	"Select * from "
		cQuery	+=	RetSqlName("SF3") + " SF3 "
		cQuery	+=	"WHERE "	
		cQuery	+=	"F3_FILIAL = '" + xFilial("SF3") + "' AND "
		cQuery	+=	"F3_CLIEFOR = '" + cCte + "' AND "
		cQuery	+=	"F3_LOJA = '" + cLoja + "' AND "
		cQuery	+=	"F3_NFISCAL = '" + cCompr + "' AND "
		cQuery	+=	"F3_SERIE = '" + cSerie + "' AND "
		cQuery	+=	"F3_ESPECIE = '" + cEspec + "' AND "
		cQuery	+=	"SF3.D_E_L_E_T_=' ' "
		
		cQuery := ChangeQuery(cQuery)                    
	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQf3,.T.,.T.) 
		
		While (cQf3)->(!EOF())
			nIBasF3 := 0
			nIValF3 := 0
			nVImpNoG := 0
			
			aTes := TesImpInf((cQf3)->F3_TES)
			
			For nX := 1 To Len(aTes)
				nPos := aScan(aNrLvrPIG,{|x| x[2] == aTES[nX][1]})
				If nPos > 0
					nVImpNoG += (cQf3)->&("F3_VALIMP" + aNrLvrPIG[nPos][1])
				EndIf
			Next nX
			
			nValBru := (cQf3)->F3_VALCONT
			
			For nX := 1 to Len(aNrLvIVA)
			   nIBasF3 := (cQf3)->&("F3_BASIMP" + aNrLvIVA[nX][1])
			   nIValF3 := (cQf3)->&("F3_VALIMP" + aNrLvIVA[nX][1])
			   cAlqImp :=  TpAlq((cQf3)->&("F3_ALQIMP" + aNrLvIVA[nX][1])) // Tabla de Alicuota
			   
			   If nIBasF3 <> 0 .Or. Len(aTes) == 0
					RIOMI->(dbSetOrder(1)) // RIM_ENC + RIM_TREG + RIM_CUIT + RIM_NUMCOM + RIM_FCOM + RIM_ALIQ
					
					If  RIOMI->(!DbSeek("T1" + "V" + cCuit + StrZero(Val(SUBSTR(cCompr,1,4)),4) + StrZero(Val(SUBSTR(cCompr,5,8)),20) + cEmiss)) 
						RecLock("RIOMI",.T.)
						RIOMI->RIM_ENC :=  "T1" // ENCABEZADO
						// T1
						ActRiomi("C","V",cCompr,cCuit,cSerie,cEspec,cNatu,cTmp,cCuitIn)
						RIOMI->RIM_FCOM 	:= cEmiss  // FECHA DEL COMPROBANTE FORMATO :AAAAMMDD
						RIOMI->RIM_MT 		:=  "N" // MARCA TITULO GRATUITO
						RIOMI->RIM_RAZON :=  Alltrim((cTmp)->A1_NOME) // APELLIDO Y NOMBRE O DENOMINACION
						RIOMI->RIM_INTCU := cCuitIn
						If nValBru <> 0
							RIOMI->RIM_TIOPE := nValBru
							nValBru := 0
						EndIf	
						If ((cTmp)->F2_REG > 0)
							RIOMI->RIM_INGRA :=  IIf(cAlqImp <> "0000", nIBasF3, 0) // IMPORTE NETO GRAVADO
							RIOMI->RIM_INOGR :=  IIf(Len(aTes) == 0,(cTmp)->F3_EXENTAS, 0) // IMPORTE NO. INTEGRAN EL NETO GRAVADO
							If nVImpNoG > 0
								RIOMI->RIM_INOGR += nVImpNoG
								nVImpNoG := 0
							EndIf
						Else
							RIOMI->RIM_INGRA :=  0  // IMPORTE NETO GRAVADO
							RIOMI->RIM_INOGR :=  0 // IMPORTE NO. INTEGRAN EL NETO GRAVADO
						Endif
						RIOMI->RIM_IOPEX :=  IIf(cAlqImp == "0000", nIBasF3, 0) // IMPORTE OPERACIONES EXENTAS
						RIOMI->(MsUnlock())
						// T3					
						RecLock("RIOMI",.T.)
						RIOMI->RIM_ENC :=  "T3" // ENCABEZADO
						ActRiomi("V","V",cCompr,cCuit,cSerie,cEspec,cNatu,cTmp,cCuitIn)

						If !empty(cNatu)
							CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
							CCP->(DbGoTop())    //SIPEIVA
							If CCP->(DbSeek(xFilial("CCP")+Avkey("RIOM","CCP_COD")+AvKey(ALLTRIM(cNatu),"CCP_VORIGE")))
							  RIOMI->RIM_TOPE := CCP->CCP_VDESTI
							Endif  
						Endif 
						RIOMI->(MsUnlock())
					Else
						RecLock("RIOMI",.F.)
							RIOMI->RIM_INGRA +=  IIf(cAlqImp <> "0000", nIBasF3, 0)
							RIOMI->RIM_IOPEX +=  IIf(cAlqImp == "0000", nIBasF3, 0)
							If nVImpNoG > 0
								RIOMI->RIM_INOGR += nVImpNoG
								nVImpNoG := 0
							EndIf
							If nValBru <> 0
								RIOMI->RIM_TIOPE += nValBru
								nValBru := 0
							EndIf
						RIOMI->(MsUnlock())
					Endif

					// T2					
					If RIOMI->(!DbSeek("T2" + "V" + cCuit + StrZero(Val(SUBSTR(cCompr,1,4)),4) + StrZero(Val(SUBSTR(cCompr,5,8)),20) + space(8) + cAlqImp ))
						RecLock("RIOMI",.T.)
						RIOMI->RIM_ENC :=  "T2" // ENCABEZADO
						ActRiomi("A","V",cCompr,cCuit,cSerie,cEspec,cNatu,cTmp,cCuitIn)
						RIOMI->RIM_ALIQ := cAlqImp
					Endif
					 RecLock("RIOMI",.F.)
					RIOMI->RIM_ILIQ += nIValF3
					RIOMI->(MsUnlock())
					
			   Endif 
			Next nX
			(cQf3)->(DbSkip())
		Enddo 
	   
		    
		(cTmp)->(DbSkip()) 
	Enddo
	(cTmp)->(dbCloseArea())

Return

/*                                                                      
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion    ³ ExtraeProv ³Autor ³ Emanuel Villicaña   ³ Fecha ³09/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion³ Extraccion de mov de proveedores                           ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ ExtraeProv(aDatos)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ACTUALIZACIONES SUFRIDAS DESDE LA CONSTRUCCION INICIAL         ³±±                
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Fecha  ³ BOPS ³  Motivo de alteracion                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/


Static Function ExtraeProv(aDatos,cFilAnt)
	Local cQuery	:= ""
	Local cTmp		:= "TRD"
	Local cQf3     := criatrab(nil,.F.)
	Local nRegs	:= 0
	Local aNrLvrPIG :={}
	Local nX 	:= 0
	Local cCampo := ""
	Local cCTmp := ""
	Local nIBasF3 := 0
	Local nIValF3 := 0
	Local cFilial1 := "0"
	Local nValBru := 0
	
	Local cCompr := ""
	Local cSerie := ""
	Local cEspec := ""
	Local cCte   := ""
	Local cLoja  := ""
	Local cCuit  := ""
	Local cCuitIn:= ""
	Local cNatu  := ""
	Local cEmiss := ""   
	Local nLivro := 0
	Local cFilSE2:= xFilial("SE2")
	Local cFilSF3:= xFilial("SF3")
	Local cFilSF1:= xFilial("SF1")
	Local aTES   := {}
	Local nPos   := 0
	Local nVImpNoG := 0
	
	Private aNrLvIVA := {}
	
	Default cFilAnt:= ""

	aNrLvrPIG = SiapImp('3',{'I', 'P'},IIf(Empty (cFilSF3), cFilAnt, cFilSF3)) //SFB - IMPUESTOS VARIABLES
	
	cQuery 	:= 	"SELECT E2_FILIAL,E2_FORNECE, E2_LOJA, E2_TIPO, E2_PREFIXO, E2_NUM, E2_EMISSAO, E2_VALOR, E2_NATUREZ,E2_VLCRUZ, "
	cQuery	+=		"A2_COD,A2_CGC,A2_NOME, "
	cQuery	+=		"ISNULL((Select SUM(F3_EXENTAS) from "
	cQuery	+=		RetSqlName("SF3") + " SF3 "
	cQuery	+=	    "WHERE "	
	If Empty (cFilSF3)
		cQuery	+= "F3_MSFIL='" + cFilAnt+ "' AND "
	Else
		cQuery	+= "F3_FILIAL='" + cFilSF3+ "' AND "
	EndIf
	If Empty (cFilSE2)
		cQuery	+= "E2_MSFIL='" + cFilAnt+ "' AND "
	Else
		cQuery	+= "E2_FILIAL='" + cFilSE2+ "' AND "
	EndIf	 
	cQuery	+=		"F3_CLIEFOR = E2_FORNECE AND F3_LOJA = E2_LOJA AND "
	cQuery	+=		"F3_NFISCAL = E2_NUM AND F3_SERIE = E2_PREFIXO AND F3_ESPECIE = E2_TIPO AND SF3.D_E_L_E_T_=' '),0 ) F3_EXENTAS, "
	cQuery	+=		"ISNULL((SELECT SF1.R_E_C_N_O_ FROM "
	cQuery	+=		RetSqlName("SF1") + " SF1 "
	cQuery	+=	    "WHERE "
	If Empty (cFilSF1)
		cQuery	+= "F1_MSFIL='" + cFilAnt+ "' AND "
	Else
		cQuery	+= "F1_FILIAL='" + cFilSF1+ "' AND "
	EndIf
	If Empty (cFilSE2)
		cQuery	+= "E2_MSFIL='" + cFilAnt+ "' AND "
	Else
		cQuery	+= "E2_FILIAL='" + cFilSE2+ "' AND "
	EndIf
   cQuery	+=		"	F1_FORNECE = E2_FORNECE AND F1_LOJA = E2_LOJA "
	cQuery	+=		"AND F1_DOC = E2_NUM AND F1_SERIE = E2_PREFIXO AND F1_ESPECIE = E2_TIPO "
	cQuery	+=		"AND SF1.D_E_L_E_T_ = ' '),0 ) F1_REG, "
	cQuery	+=		"SE2.R_E_C_N_O_ E2_REG "								
	cQuery 	+=	"FROM " 
	cQuery	+=		RetSqlName("SE2")+ " SE2,"
	cQuery	+=		RetSqlName("SA2")+ " SA2 "	
	cQuery	+=	"WHERE "
	If Empty (cFilSE2)
		cQuery	+= "E2_MSFIL='" + cFilAnt+ "' AND "
	Else
		cQuery	+= "E2_FILIAL='" + cFilSE2+ "' AND "
	EndIf	
	cQuery	+=		"A2_FILIAL='" + xFilial("SA2")+ "' AND "
	cQuery	+=		"E2_FORNECE = A2_COD AND "
	cQuery	+=		"E2_LOJA = A2_LOJA AND "		
	cQuery	+= 		"E2_EMISSAO >='" + DTOS(MV_PAR01)+ "' AND "
	cQuery	+=		"E2_EMISSAO <='" + DTOS(MV_PAR02)+ "' AND "
	cQuery	+=		"A2_RG3572 = '1' AND " 		  
	cQuery	+=		"SA2.D_E_L_E_T_=' ' AND "
	cQuery	+=		"SE2.D_E_L_E_T_=' ' "
	cQuery	+=		"ORDER BY A2_CGC,E2_PREFIXO,E2_NUM"
	cQuery := ChangeQuery(cQuery)                    

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.) 
	TcSetField( cTmp, 'E2_EMISSAO', 'D', TamSX3('E2_EMISSAO')[1], 0 )

	Count to nRegs
	ProcRegua(nRegs)
	nRegs	:= 0
	(cTmp)->(dbGoTop())

	While (cTmp)->(!EOF())
	   cCompr := (cTmp)->E2_NUM
	   cSerie := (cTmp)->E2_PREFIXO
	   cEspec := (cTmp)->E2_TIPO
	   cCte   := (cTmp)->E2_FORNECE
	   cLoja  := (cTmp)->E2_LOJA
	   cCuit  := PadR(Alltrim((cTmp)->A2_CGC), 11)
	   cCuitIn:= "00000000000"
	   cNatu  := (cTmp)->E2_NATUREZ
	   cEmiss := STR(YEAR((cTmp)->E2_EMISSAO),4) + STRZERO(MONTH((cTmp)->E2_EMISSAO),2) + STRZERO(DAY((cTmp)->E2_EMISSAO),2)
	   
	   If ((cTmp)->F1_REG > 0) // Si existe informacion en Encabezado de factura
			SF1->(DBGOTO((cTmp)->F1_REG))
			cNatu  := iif(!empty(cNatu),cNatu,SF1->F1_NATUREZ)
	   Endif 

		// Verifico si documento maneja IVA - SF3
		If Select (cQf3)>0
			DbSelectArea (cQf3)
            (cQf3)->( DbCloseArea())
		Endif

		If RIOMI->(DbSeek("T1" + "C" + cCuit + StrZero(Val(SUBSTR(cCompr,1,4)),4) + StrZero(Val(SUBSTR(cCompr,5,8)),20) + cEmiss)) .And. (cFilial1 == (cTmp)->E2_FILIAL)
			RecLock("RIOMI",.F.)
			If SF1->F1_MOEDA <> 1
				RIOMI->RIM_TIOPE +=  (cTmp)->E2_VlCRUZ
			Else
				RIOMI->RIM_TIOPE +=  (cTmp)->E2_VALOR // IMPORTE TOTAL DE OPERACIÓN
			EndIF			
			RIOMI->(MsUnlock())                             
			(cTmp)->(DbSkip()) 
			Loop 
		Endif 

		cQuery	:= ""
		cQuery	+=	"Select * from "
		cQuery	+=	RetSqlName("SF3") + " SF3 "
		cQuery	+=	"WHERE "	
		cQuery	+=	"F3_FILIAL = '" + xFilial("SF3") + "' AND "
		cQuery	+=	"F3_CLIEFOR = '" + cCte + "' AND "
		cQuery	+=	"F3_LOJA = '" + cLoja + "' AND "
		cQuery	+=	"F3_NFISCAL = '" + cCompr + "' AND "
		cQuery	+=	"F3_SERIE = '" + cSerie + "' AND "
		cQuery	+=	"F3_ESPECIE = '" + cEspec + "' AND "
		cQuery	+=	"SF3.D_E_L_E_T_=' ' "
		
		cQuery := ChangeQuery(cQuery)                    
	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQf3,.T.,.T.) 
		
		While (cQf3)->(!EOF())
			nIBasF3 := 0
			nIValF3 := 0
			nVImpNoG := 0
			
			aTes := TesImpInf((cQf3)->F3_TES)
			
			For nX := 1 To Len(aTes)
				nPos := aScan(aNrLvrPIG,{|x| x[2] == aTES[nX][1]})
				If nPos > 0
					nVImpNoG += (cQf3)->&("F3_VALIMP" + aNrLvrPIG[nPos][1])
				EndIf
			Next nX
			
			nValBru := (cQf3)->F3_VALCONT 
			
			For nX := 1 to Len(aNrLvIVA)
			   nIBasF3 := (cQf3)->&("F3_BASIMP" + aNrLvIVA[nX][1])
			   nIValF3 := (cQf3)->&("F3_VALIMP" + aNrLvIVA[nX][1])
			   cAlqImp :=  TpAlq((cQf3)->&("F3_ALQIMP" + aNrLvIVA[nX][1])) // Tabla de Alicuota
			   
			   If nIBasF3 <> 0 .Or. Len(aTes) == 0
					RIOMI->(dbSetOrder(1)) // RIM_ENC + RIM_TREG + RIM_CUIT + RIM_NUMCOM + RIM_FCOM + RIM_ALIQ
					
					If RIOMI->(!DbSeek("T1" + "C" + cCuit + StrZero(Val(SUBSTR(cCompr,1,4)),4) + StrZero(Val(SUBSTR(cCompr,5,8)),20) + cEmiss))
						RecLock("RIOMI",.T.)
						RIOMI->RIM_ENC :=  "T1" // ENCABEZADO
						RIOMI->RIM_ESP := AllTrim(cEspec)
						RIOMI->RIM_SERIE := allTrim(cSerie)
						// T1
						ActRiomi("C","C",cCompr,cCuit,cSerie,cEspec,cNatu,cTmp,cCuitIn)
						RIOMI->RIM_FCOM 	:= cEmiss  // FECHA DEL COMPROBANTE FORMATO :AAAAMMDD
						RIOMI->RIM_MT 		:=  "N" // MARCA TITULO GRATUITO
						RIOMI->RIM_RAZON :=  Alltrim((cTmp)->A2_NOME) // APELLIDO Y NOMBRE O DENOMINACION
						RIOMI->RIM_INTCU := cCuitIn
						If nValBru <> 0
							RIOMI->RIM_TIOPE := nValBru
							nValBru := 0
						EndIf
						If ((cTmp)->F1_REG > 0)
							RIOMI->RIM_INGRA :=  IIf(cAlqImp <> "0000", nIBasF3, 0)  // IMPORTE NETO GRAVADO
							RIOMI->RIM_INOGR :=  IIf(Len(aTes) == 0,(cTmp)->F3_EXENTAS, 0)		
							If nVImpNoG > 0
								RIOMI->RIM_INOGR += nVImpNoG
								nVImpNoG := 0
							EndIf							
						Else
							RIOMI->RIM_INGRA :=  0  // IMPORTE NETO GRAVADO
							RIOMI->RIM_INOGR :=  0 // IMPORTE NO. INTEGRAN EL NETO GRAVADO
						Endif 
						RIOMI->RIM_IOPEX :=  IIf(cAlqImp == "0000", nIBasF3, 0) // IMPORTE OPERACIONES EXENTAS
						RIOMI->(MsUnlock())
						// T3					
						RecLock("RIOMI",.T.)
						RIOMI->RIM_ENC :=  "T3" // ENCABEZADO
						RIOMI->RIM_ESP := AllTrim(cEspec)
						RIOMI->RIM_SERIE := allTrim(cSerie)
						ActRiomi("V","C",cCompr,cCuit,cSerie,cEspec,cNatu,cTmp,cCuitIn)

						If !empty(cNatu)
							CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
							CCP->(DbGoTop())    //SIPEIVA
							If CCP->(DbSeek(xFilial("CCP")+Avkey("RIOM","CCP_COD")+AvKey(ALLTRIM(cNatu),"CCP_VORIGE")))
							  RIOMI->RIM_TOPE := CCP->CCP_VDESTI
							Endif  
						Endif 
						RIOMI->(MsUnlock())
					Else
						RecLock("RIOMI",.F.)
							RIOMI->RIM_INGRA +=  IIf(cAlqImp <> "0000", nIBasF3, 0)
							RIOMI->RIM_IOPEX +=  IIf(cAlqImp == "0000", nIBasF3, 0)
							If nVImpNoG > 0
								RIOMI->RIM_INOGR += nVImpNoG
								nVImpNoG := 0
							EndIf
							If nValBru <> 0
								RIOMI->RIM_TIOPE += nValBru
								nValBru := 0
							EndIf
						RIOMI->(MsUnlock())
					Endif

					// T2					
					If  RIOMI->(!DbSeek("T2" + "C" + cCuit + StrZero(Val(SUBSTR(cCompr,1,4)),4) + StrZero(Val(SUBSTR(cCompr,5,8)),20) + space(8) + cAlqImp ))
						RecLock("RIOMI",.T.)
						RIOMI->RIM_ENC :=  "T2" // ENCABEZADO
						RIOMI->RIM_ESP := AllTrim(cEspec)
						RIOMI->RIM_SERIE := allTrim(cSerie)
						ActRiomi("A","C",cCompr,cCuit,cSerie,cEspec,cNatu,cTmp,cCuitIn)
						RIOMI->RIM_ALIQ := cAlqImp
					Endif
					RecLock("RIOMI",.F.)
					RIOMI->RIM_ILIQ += nIValF3
					RIOMI->(MsUnlock())
					
			   Endif 
			Next nX
			(cQf3)->(DbSkip())
		Enddo 
	   
	    cFilial1 := (cTmp)->E2_FILIAL
		    
		(cTmp)->(DbSkip()) 
	Enddo
	(cTmp)-> (dbCloseArea()) 

Return

//+----------------------------------------------------------------------+
//|Genera el archivo de texto 											 |
//+----------------------------------------------------------------------+
//|Parámetros	|aArq:	Array con los datos a registrar en el archivo	 |
//|				|	de Texto.											 |
//|				|cNameFile												 |
//|				|	Nombre del archivo que s erá generado.     			 |
//|				|	de generar el txt.									 |  
//+-------------+--------------------------------------------------------+
Static Function genFile(aArq,cNameFile)
	
	Local cLinea	:= ""
	Local nI		:= 0
	Local nJ		:= 0
	Local nArqLog	:= 0
	Local cFileName	:= ""
	
	if Len(aArq) > 0
	
		cFileName := cNameFile
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
		
		MSGINFO(STR0017)
	else
		MSGALERT(STR0019)
	end if	
Return .T. 

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºFun‡„o    ³SiapImp   º Autor ³ Emanuel Villicaña  º Data ³  21/01/14   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescri‡„o ³ IMPUESTOS VARIABLES                                        º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±º FB_CLASSIF                                                            º±±
	±±º FB_CLASSE                                                             º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Static Function SiapImp(cClasif,aClase, cFil)
	Local cQryNLvro	:=""
	Local cTRBLVRO  	:=""
	Local aNrLvrPIG 	:={}

	Default cClasif	:= ""
	Default aClase	:= {}
	
	cQryNLvro:=" SELECT DISTINCT FB_CPOLVRO NLIVRO, FB_CODIGO, FB_TIPO, FB_CLASSE, FB_CLASSIF"
	cQryNLvro+=" FROM "+RetsqlName("SFB")+" SFB "
	cQryNLvro+=" WHERE D_E_L_E_T_='' "
	cQryNLvro+=" AND FB_FILIAL = '" + xFilial("SFB", cFil) + "'"
	If !Empty(aClase) .And. !Empty(cClasif)
		cQryNLvro+=" AND (FB_CLASSE = '" + aClase[1] + "'"
		cQryNLvro+=" OR FB_CLASSE = '" + aClase[2] + "')"
	Endif
	
	If Select("TRBLVRO")>0
		DbSelectArea("TRBLVRO")
		TRBLVRO->(DbCloseArea())
	Endif
		
	cTRBLVRO := ChangeQuery(cQryNLvro)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRBLVRO ) ,"TRBLVRO", .T., .F.)

	aNrLvrPIG :={}

	DbSelectArea("TRBLVRO")
	TRBLVRO->(dbGoTop())
	If TRBLVRO->(!Eof())
		Do While TRBLVRO->(!Eof())
			If Alltrim(TRBLVRO->FB_CLASSE) == "I" .And. Alltrim(TRBLVRO->FB_CLASSIF) == '3'
				aAdd(aNrLvIVA,{TRBLVRO->NLIVRO, TRBLVRO->FB_CODIGO})
			Else
				aAdd(aNrLvrPIG,{TRBLVRO->NLIVRO, TRBLVRO->FB_CODIGO})
			EndIf
			TRBLVRO->(DbSkip())
		End
	Endif
	
Return aNrLvrPIG



	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºFun‡„o    ³CriaCursorº Autor ³ Emanuel Villicaña  º Data ³  21/01/14   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescri‡„o ³ Crea cursor temporal                                       º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±º FB_CLASSIF                                                            º±±
	±±º FB_CLASSE                                                             º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	
Static Function CriaCursor()
	Local aStrutSIA	:= {}
	Local aOrdem := {}
	
	AADD(aStrutSIA,{"RIM_ENC"		,"C",002,0}) // ENCABEZADO
	// T1
	AADD(aStrutSIA,{"RIM_CUIT"		,"C",011,0}) // CUIT 
	AADD(aStrutSIA,{"RIM_INTCU" 	,"C",011,0}) // CUIT INTERMEDIARIO 
	AADD(aStrutSIA,{"RIM_TMOV"		,"C",001,0}) // TIPO DE MOVIMIENTO
	AADD(aStrutSIA,{"RIM_TREG"		,"C",001,0}) // TIPO DE REGISTRO
	AADD(aStrutSIA,{"RIM_TCOM"		,"C",003,0}) // TIPO DE COMPROBANTE
	AADD(aStrutSIA,{"RIM_PV"		    ,"C",004,0}) // PUNTO DE VENTA
	AADD(aStrutSIA,{"RIM_NUMCOM"	,"C",020,0}) // No de COMPROBANTE
	AADD(aStrutSIA,{"RIM_FCOM"		,"C",008,0}) // FECHA DEL COMPROBANTE FORMATO :AAAAMMDD
	AADD(aStrutSIA,{"RIM_MT"		    ,"C",001,0}) // MARCA TITULO GRATUITO
	AADD(aStrutSIA,{"RIM_RAZON"		,"C",030,0}) // APELLIDO Y NOMBRE O DENOMINACION
	AADD(aStrutSIA,{"RIM_TIOPE"		,"N",015,2}) // IMPORTE TOTAL DE OPERACIÓN
	AADD(aStrutSIA,{"RIM_INOGR"		,"N",015,2}) // IMPORTE NO. INTEGRAN EL NETO GRAVADO
	AADD(aStrutSIA,{"RIM_INGRA"		,"N",015,2}) // IMPORTE NETO GRAVADO	
	AADD(aStrutSIA,{"RIM_IOPEX"		,"N",015,2}) // IMPORTE OPERACIONES EXENTAS		
	// T2
	AADD(aStrutSIA,{"RIM_ALIQ"		,"C",004,0}) // ALICUOTA
	AADD(aStrutSIA,{"RIM_ILIQ"		,"N",015,2}) // IMPUESTO LIQUIDADO
	// T3
	AADD(aStrutSIA,{"RIM_TOPE"		,"C",002,0}) // TIPO DE OPERACION
	AADD(aStrutSIA,{"RIM_ESP"		,"C",003,0}) // Especie
	AADD(aStrutSIA,{"RIM_SERIE"		,"C",003,0}) // Serie
	
	oTmpTable := FWTemporaryTable():New("RIOMI")
	oTmpTable:SetFields( aStrutSIA )
	aOrdem := {"RIM_ENC", "RIM_TREG", "RIM_CUIT", "RIM_PV", "RIM_NUMCOM", "RIM_FCOM", "RIM_ALIQ"}
	oTmpTable:AddIndex("RIOMI1", aOrdem)
	aOrdem := {"RIM_PV", "RIM_NUMCOM", "RIM_ENC", "RIM_FCOM", "RIM_TREG", "RIM_ALIQ"}
	oTmpTable:AddIndex("RIOMI2", aOrdem)
	oTmpTable:Create()
	
	RIOMI->(dbSetOrder(1))

Return


/*                                                                      
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion    ³ TpDocRET   ³Autor ³ Emanuel Villicaña   ³ Fecha ³07/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion³ Función para obtener el tipo de documento en base al tipo y³±± 
±±³           ³ la serie.                                                  ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ TpDocRET()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ACTUALIZACIONES SUFRIDAS DESDE LA CONSTRUCCION INICIAL         ³±±                
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Fecha  ³ BOPS ³  Motivo de alteracion                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TpDocRET(cSerie,cTipo,cTipReg,cNatu)
	Local cTipoDoc  := ""
	Default cNatu	:= ""
	Default cSerie	:= ""
	Default cTipo	:= ""  
	
	cTipo := ALLTRIM(UPPER(cTipo))

	Do Case
	Case Empty(cNatu) .And. cTipReg = "V" // C*C
		cTipoDoc="037"	
	Case Empty(cNatu) .And. cTipReg = "C" // C*P
		cTipoDoc="038"	
	Case cTipo == "NF"             .And. ("A" $ Alltrim(cSerie))
		cTipoDoc="001"
	Case cTipo $ "NDC|NCE|NDP|NCI" .And. ("A" $ Alltrim(cSerie))
		cTipoDoc="002"
	Case cTipo $ "NCC|NDE|NCP|NDI" .And. ("A" $ Alltrim(cSerie))
		cTipoDoc="003"
	Case cTipo == "NF"             .And. ("B" $ Alltrim(cSerie))
		cTipoDoc="006"
	Case cTipo $ "NDC|NDP|NCI"     .And. ("B" $ Alltrim(cSerie))
		cTipoDoc="007"
	Case cTipo $ "NCC|NCP|NDI"     .And. ("B" $ Alltrim(cSerie))
		cTipoDoc="008"
	Case cTipo $ "NCE|NDP"         .And. ("C" $ Alltrim(cSerie))
		cTipoDoc="012"
	Case cTipo $ "NDE|NCP"         .And. ("C" $ Alltrim(cSerie))
		cTipoDoc="013"
	Case cTipo == "NF"             .And. ("M" $ Alltrim(cSerie))
		cTipoDoc="051"
	Case cTipo == "NDP"            .And. ("M" $ Alltrim(cSerie))
		cTipoDoc="052"
	Case cTipo == "NCP"            .And. ("M" $ Alltrim(cSerie))
		cTipoDoc="053"
	EndCase

Return(cTipoDoc)

/*                                                                      
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion    ³ TpAlq      ³Autor ³ Emanuel Villicaña   ³ Fecha ³07/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion³ Función para obtener el tipo de Alicuota                   ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ TpDocRET()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ACTUALIZACIONES SUFRIDAS DESDE LA CONSTRUCCION INICIAL         ³±±                
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Fecha  ³ BOPS ³  Motivo de alteracion                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TpAlq(nAliq)
	Local   cAliq   := "0"
	Default nAliq	:= 0
	
	Do Case
	Case nAliq = 0
		cAliq := "0000"
	Case nAliq = 10.5
		cAliq := "1050"	 
	Case nAliq = 21 
		cAliq := "2100"	
	Case nAliq = 27 
		cAliq := "2700"	
	EndCase
		
Return(cAliq)

/*                                                                      
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion    ³ ActRiomi   ³Autor ³ Emanuel Villicaña   ³ Fecha ³07/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion³ Actualizar campos estandar de cursor temporal              ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ ActRiomi(cTMov,cTReg,cCompr,cCuit,cSerie,cEspec,cNatu)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ACTUALIZACIONES SUFRIDAS DESDE LA CONSTRUCCION INICIAL         ³±±                
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Fecha  ³ BOPS ³  Motivo de alteracion                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ActRiomi(cTMov,cTReg,cCompr,cCuit,cSerie,cEspec,cNatu,cTemm,cCuitIn)
	RIOMI->RIM_CUIT 	:= cCuit // CUIT 
	RIOMI->RIM_TMOV 	:= cTMov  // TIPO DE MOVIMIENTO
	RIOMI->RIM_TREG 	:= cTReg  // TIPO DE REGISTRO (V Ventas, C Compras)
	RIOMI->RIM_TCOM 	:= TpDocRET(cSerie,cEspec,cTReg,cNatu) // TIPO DE COMPROBANTE
	RIOMI->RIM_PV   	:=  StrZero(Val(SUBSTR(cCompr,1,4)),4) // PUNTO DE VENTA
	RIOMI->RIM_NUMCOM :=  StrZero(Val(SUBSTR(cCompr,5,8)),20) // No de COMPROBANTE
	RIOMI->RIM_INTCU := cCuitIn
Return
