#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FISA015.CH"
#INCLUDE 'FWLIBVERSION.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FISA015  ³ Autor ³ Hermes Ferreira          ³ Data ³16/12/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Permitir que seja gerado um certificado de retenção dos       ³±±
±±³          ³ impostos IVA,ICA ou na Fonte								     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FISA015                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gera Certificado de Retenção                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³  BOPS   ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÃÄÄÄÄÄÄÄÄÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Laura Medina³15/03/13³ TFVWHC  ³ Se agrego el campo F1_VALIMP1 para impre-³±±
±±³            ³        ³         ³ sion en el Certificado de Ret. IVA       ³±±
±±³Alf. Medrano³19/05/16³ TUMAXX  ³se agregan las Func. FISA15F2() que obtie ³±±
±±³            ³        ³         ³ne Nota Credito, FIS015GR() agrupa, suma  ³±±
±±³            ³        ³         ³y resta las Fact / notas credito FIS015VS ³±±
±±³            ³        ³         ³obtiene Relacion Cod Fiscales COLOMBIA    ³±±
±±³Alf. Medrano³02/06/16³ TUMAXX  ³se quita dbclosearea en fun FIS015VS      ³±±
±±³            ³        ³         ³ajuste de query en fun FISA15F2           ³±±
±±³Alf. Medrano³15/06/16³ TUMAXX  ³En la función FISA15F2() se asigna filtro ³±±
±±³            ³        ³         ³para que solo obtenga notas de Crédito del³±±
±±³            ³        ³         ³proveedor NCP. En la func FIS015GR() se   ³±±
±±³            ³        ³         ³agrega condición para Validar NCP         ³±±
±±³            ³        ³         ³En la func FISA015() se asigna el filtro  ³±±
±±³            ³        ³         ³de Especie para excluir de la consulta las³±±
±±³            ³        ³         ³Notas de Credito. En la func FGrvCrt() se ³±±
±±³            ³        ³         ³asigna la Especie al Array alCertRet      ³±±
±±³            ³        ³         ³COLOMBIA                                  ³±±
±±³Alf. Medrano³22/06/16³ TUMAXX  ³Se actualiza consulta en Func. FISA015    ³±±
±±³            ³        ³         ³mostraran solo las Fact y notas Créd/Deb  ³±±
±±³            ³        ³         ³con especie NF, NDP y NCI.                ³±±
±±³            ³        ³         ³En la func FISA15F2() se actualiza consul-³±±
±±³            ³        ³         ³ta para mostrar solo las  notas Créd/Deb  ³±±
±±³            ³        ³         ³con especie NCP y NDI. En Func. FIS015GR()³±±
±±³            ³        ³         ³se agrega condición para Validar NDI. COL ³±±
±±³Alf. Medrano³06/07/16³ TVOJAW  ³Merge v11 vs v12,se modifica fun. FIS015GR³±±
±±³            ³        ³         ³para FUENTE se  agrega el Num Docto   COL ³±±
±±³Alf. Medrano³19/10/16³ TWGPRD  ³Se suma y resta el Iva de Operación. IVA  ³±±
±±³Alf. Medrano³08/11/16³ TWIPKT  ³MERGE 12.1.07 vs 12.1.14  COL             ³±±
±±³Alf. Medrano³29/11/16³ MMI-34  ³se corrgige funcion FISA15F2 para esta    ³±±
±±³            ³        ³         ³version COL                               ³±±
±±³  Marco A.  ³16/12/16³SERINN001³Se aplica CTREE para evitar la creacion   ³±±
±±³            ³        ³-529     ³de tablas temporales de manera fisica     ³±±
±±³            ³        ³         ³en system.                                ³±±
±±³M.Camargo   ³13/02/18³DMINA-374|Réplica DMINA-74                          ³±±
±±³            ³        ³         ³Se modifica funcion FIS015GR para agregar ³±±
±±³            ³        ³         ³ordenado por tasa,y que se tome en cuenta ³±±
±±³            ³        ³         ³para acumulado. (COL)                     ³±±
±±³            ³        ³         ³En funcion FIS015GR se agrega bifurc. para³±±
±±³            ³        ³         ³ordenar por cliente + tienda + tasa + tipo³±±
±±³            ³        ³         ³de doc. y código fis. (IVA/ICA) (COL)     ³±±
±±³GSantacruz  ³27/02/18³DMINA-1987 Ajustes para retenciones de IVA e ISR    ³±±
±±³            ³        ³         ³para Venezuela.                           ³±±
±±³GSantacruz  ³03/05/18³           Para Venezuela evitar que genere CXP de  ³±±
±±³            ³        ³         ³Retenciones de IVA y Ret de ISR           ³±±
±±³GSantacruz  ³01/06/18³DMINA-3229 Venezuela pra generar retenciones de tipo³±±
±±³            ³        ³         ³"B" cuando el impuesto es BAR.            ³±±
±±³GSantacruz  ³04/07/18³DMINA-3573 Venezuela- Correccion al crear el arreglo ±±
±±³            ³        ³         ³aGerSD1, para el basimp2.                 ³±±
±±³Alf. Medrano³13/08/18³DMINA-3776³En Fun FISA015 y FISA15F2 se asigna al   ³±±
±±³            ³        ³         ³query relación SF1/SF2 con CC2 para cargar³±±
±±³            ³        ³         ³los datos de F1/F2_CODMUN y F1/F2_MUN     ³±±
±±³            ³        ³         ³En fun FGrvCrt se asignan los valores de  ³±±
±±³            ³        ³         ³Municipio al array alCertRet. En fun      ³±±
±±³            ³        ³         ³FIS015GR()se agrupan valores por Municipio³±±
±±³Alf. Medrano³13/08/18³         ³se quita el dbcloseArea de tabñas SF1,SF2 ³±±
±±³            ³        ³         ³y CC2 en funcion FISA015                  ³±±
±±³LuisEnríquez³28/02/19³DMINA-6063³Se agrega funcionalidad para retención de³±±
±±³            ³        ³         ³IVA con alícuota del 0%. (EQU)            ³±±
±±³Alf. Medrano³05/04/19³         ³En fun FGrvCrt se modifica query  para EQU³±±
±±³            ³        ³         ³en select se asgrega el campo D1/D2_ITEM  ³±±
±±³Oscar G.    ³27/06/19³DMINA-   ³En Fun. FISA015 se crea un indice para la ³±±
±±³            ³        ³ 6994    ³tabla temporal "TMP1". (COL)              ³±±
±±³Oscar G.    ³27/09/20³DMINA-   ³En Func. FISA015() se elimina el campo OK ³±±
±±³            ³        ³ 10186   ³del indice de las tablas temporales (EQU) ³±±
±±³  Marco A.  ³09/05/21³DMINA-   ³En la funcion FGrvCrt, se agrega la vali- ³±±
±±³            ³        ³ 12348   ³dacion para imprimir el impuesto RIR, si  ³±±
±±³            ³        ³         ³este tiene un valor de 0. (EQU)           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FISA015()

	Local lAviso1		:= .T.
	Local lAviso2		:= .T.
	Local lExc			:= .F.
	Local clPerg		:= IIf(cPaisLoc $ "EQU|VEN", "FISA015E", "FISA015")
	Local clQryTl		:= ""
	Local clDescImp		:= ""
	Local cPref			:= ""
	Local cArqTMP1		:= ""
	Local cNumDoc		:= ""                                               
	Local cSerie		:= ""
	Local cCliFor		:= ""
	Local cLoja			:= ""
	Local cEspecie		:= ""
	Local cConcept		:= ""
	Local cChave		:= ""
	Local cIndice		:= ""
	Local cTes			:= ""
	Local cEmissao		:= ""
	Local cDtDigit		:= ""
	Local cTipoC		:= ""
	Local aStrutTMP1	:= {}
	Local alCertRet		:= {}
	Local alDelTits		:= {}
	Local olDlg			:= Nil
	Local nlI			:= 0
	Local nOpcao		:= 0 
	Local nlOpc			:= 0 
	Local nValImp1		:= 0
	Local nValImp2		:= 0
	Local nValImp3		:= 0
	Local nValImp4		:= 0
	Local nValImp6		:= 0
	Local nBasImp2		:= 0
	Local nBasImp3		:= 0
	Local nBasImp4		:= 0
	Local nBasImp6		:= 0
	Local nAlqImp2		:= 0
	Local nAlqImp3		:= 0
	Local nAlqImp4		:= 0
	Local nAlqImp6		:= 0
	Local lSeek			:= .F.
	Local aOrdem		:= {}
	Local nX			:= 0
	Local cDesMun		:= ""
	Local cCodMun		:= ""
	Local cLvroRetC     := SuperGetMV("MV_LVRORIC",,"") //Número de libro para ret. de IVA al 0% (Ecuador)
	Local lCRTra        := .T. //Permite borrar si el certificado de retención no está transmitido (Ecuador)
	Local aTamSX3		:= {}
	Local cBajaSRI      := SuperGetMV("MV_BAJASRI",,"") //Consulta estatus del Certificado de Retención ante la SRI (Ecuador)
	Local cEstRet       := "" //Estatus ante la SRI del Certificado de Retención (Ecuador)
	Local aStaCR        := {} //Estatus FE de Certificado de Retención SRI (Ecuador) 
	Local aCRProc       := {}
	Local aCRAnul       := {}
	Local aCRBorra      := {}
	Local cCRMsg        := ""
	Local cProvFE       := SuperGetMV("MV_PROVFE",,"") //Parámetro de Porveedot Tecnologico de Facturación de Elecetrónica
	Local nPosCR        := 0
	Local cCtrl         := (chr(13)+chr(10))
	Local cMsgAviso     := ""
		
	Private dDtIni		:= Ctod("//")
	Private dDtFim		:= Ctod("//")
	Private cCodIni		:= ""
	Private cLojIni		:= ""
	Private cCodFim		:= ""
	Private cLojFim		:= ""
	Private cDocIni		:= ""
	Private cSerIni		:= ""
	Private cDocFim		:= ""
	Private cSerFim		:= ""
	Private cSDoc		:= ""
	Private lSDoc		:= SerieNFID("SD1", 3, "D1_SERIE") == "D1_SERIE"
	Private cpMarca		:= GetMark()
	Private nTipOpe		:= 0
	Private nTipImp		:= 0
	Private cNCertIni	:= 0
	Private cNCertFim	:= 0
	Private nMoeda		:= 1
	Private nTxMoeda	:= 1
	Private llMarc		:= .T.
	Private apCampos	:= {}
	Private aSize		:= MsAdvSize(.T.)
	Private oTmpTable	:= Nil
	Private oTmpTable2	:= Nil

	If Pergunte(clPerg, .T.)

		nTipOpe		:= IIf(cPaisLoc $ "EQU|VEN", MV_PAR01, "")			//Tipo de Operacao(Equador-Entrada|Saida)
		dDtIni  	:= IIf(cPaisLoc $ "EQU|VEN", MV_PAR03, MV_PAR02)	//Data Inicial
		dDtFim  	:= IIf(cPaisLoc $ "EQU|VEN", MV_PAR04, MV_PAR03)	//Data Final
		cCodIni		:= IIf(cPaisLoc $ "EQU|VEN", MV_PAR05, MV_PAR04)	//Cli/For Inicial|Fornecedor Inicial
		cLojIni		:= IIf(cPaisLoc $ "EQU|VEN", MV_PAR06, MV_PAR05)	//Loja Inicial
		cCodFim		:= IIf(cPaisLoc $ "EQU|VEN", MV_PAR07, MV_PAR06)	//Cli/For Final|Fornecedor Final
		cLojFim		:= IIf(cPaisLoc $ "EQU|VEN", MV_PAR08, MV_PAR07)	//Loja Final
		cDocIni		:= IIf(cPaisLoc $ "EQU|VEN", MV_PAR09, MV_PAR08)	//Documento Inicial
		cSerIni		:= IIf(cPaisLoc $ "EQU|VEN", MV_PAR10, MV_PAR09)	//Serie Inicial
		cDocFim		:= IIf(cPaisLoc $ "EQU|VEN", MV_PAR11, MV_PAR10)	//Documento Final
		cSerFim		:= IIf(cPaisLoc $ "EQU|VEN", MV_PAR12, MV_PAR11)	//Serie Final
		nOpcao  	:= IIf(cPaisLoc $ "EQU|VEN", MV_PAR13, MV_PAR12)	//Opcao(Equador-Cadastrar,Re-Imprimir,Excluir|Outros-Imprimir,Re-Imprimir,Excluir)
		nTipImp		:= IIf(cPaisLoc $ "EQU|VEN", MV_PAR02, MV_PAR01)	//Tipo de Imposto(Equador-IVA|IR|Ambos,Outros-IVA|ICA|Fonte)
		cNCertIni	:= IIf(cPaisLoc $ "EQU|VEN", MV_PAR14, MV_PAR13)	//Numero Certificado Inicial
		cNCertFim	:= IIf(cPaisLoc $ "EQU|VEN", MV_PAR15, MV_PAR13)	//Numero Certificado Final

		If cPaisLoc == "VEN"
			nOpcao := 3
		EndIf
		//Equador-Cadastrar|Outos Paises-Imprimir	
		If nOpcao == 1
			clQryTl := ""
			If cPaisLoc == "EQU"     
				//1-Entrada|2-Saida
				If nTipOpe == 1
					cPref := "D1"
					//Bruno Cremaschi - Projeto chave única.
					cSDoc := SerieNFID("SD1", 3, "D1_SERIE")
				Else
					cPref := "D2"
					//Bruno Cremaschi - Projeto chave única.
					cSDoc := SerieNFID("SD2", 3, "D2_SERIE")
				EndIf

				clQryTl += " SELECT DISTINCT '  ' AS OK "
				clQryTl += ", " + cPref + "_ITEM ITEM "
				clQryTl += ", " + cPref + "_CONCEPT CONCEPT "
				clQryTl += ", " + cPref + "_DOC DOC "
				clQryTl += ", " + cPref + "_SERIE SERIE "
				If !lSDoc
					clQryTl += ", " + cSDoc+" SDOC "
				EndIf

				If nTipOpe == 2 //Saida
					clQryTl += ", " + cPref + "_CLIENTE CLIFOR "
				Else
					clQryTl += ", " + cPref + "_FORNECE CLIFOR "
				EndIf

				clQryTl += ", " + cPref + "_LOJA LOJA "
				clQryTl += ", " + cPref + "_EMISSAO EMISSAO "
				clQryTl += ", " + cPref + "_DTDIGIT DTDIGIT "
				clQryTl += ", " + cPref + "_ESPECIE ESPECIE "
				clQryTl += ", " + cPref + "_TES TES "			

				If nTipImp == 1 .Or. nTipImp == 3
					clQryTl += ",  " + cPref + "_VALIMP2 VALIMP2 " //IVA 30%
					clQryTl += ",  " + cPref + "_VALIMP3 VALIMP3 " //IVA 70%
					clQryTl += ",  " + cPref + "_VALIMP4 VALIMP4 " //IVA 100%
					clQryTl += ",  " + cPref + "_BASIMP2 BASIMP2 " //IVA 30%
					clQryTl += ",  " + cPref + "_BASIMP3 BASIMP3 " //IVA 70%
					clQryTl += ",  " + cPref + "_BASIMP4 BASIMP4 " //IVA 100%
					clQryTl += ",  " + cPref + "_ALQIMP2 ALQIMP2 " //IVA 30%
					clQryTl += ",  " + cPref + "_ALQIMP3 ALQIMP3 " //IVA 70%
					clQryTl += ",  " + cPref + "_ALQIMP4 ALQIMP4 " //IVA 100%
					If !Empty(cLvroRetC) .And. !(AllTrim(cLvroRetC) $ "2|3|4")
						clQryTl += ",  " + cPref + "_VALIMP" + Alltrim(cLvroRetC) + " VALIMP" + Alltrim(cLvroRetC) + " " //RET IVA 0% (VALOR)
						clQryTl += ",  " + cPref + "_BASIMP" + Alltrim(cLvroRetC) + " BASIMP" + Alltrim(cLvroRetC) + " " //RET IVA 0% (BASE)
						clQryTl += ",  " + cPref + "_ALQIMP" + Alltrim(cLvroRetC) + " ALQIMP" + Alltrim(cLvroRetC) + " " //RET IVA 0% (ALÍCUOTA)
					EndIf
				EndIf

				If nTipImp == 2 .Or. nTipImp == 3
					clQryTl += ", " + cPref + "_VALIMP6 VALIMP6 "//IR
					clQryTl += ", " + cPref + "_BASIMP6 BASIMP6 "//IR
					clQryTl += ", CCR_ALIQ ALQIMP6 "
				EndIf

				clQryTl += ", " + cPref + "_TOTAL TOTAL "
				clQryTl += ", " + cPref + "_VALIMP1 VALIMP1 "			

				If nTipOpe == 2//Saida				           
					clQryTl += " FROM "+RetSqlName("SD2")+" SD2 "
				Else                                 
					clQryTl += " FROM "+RetSqlName("SD1")+" SD1 "			
				EndIf

				clQryTl += " LEFT JOIN "+RetSqlName("SFE")+" SFE"
				clQryTl += " ON SFE.D_E_L_E_T_ = ' '"
				clQryTl += " AND FE_FILIAL = '" + xFilial("SFE") + "'"

				If nTipOpe == 2//Saida
					clQryTl += " AND FE_CLIENTE	= " + cPref + "_CLIENTE "
					clQryTl += " AND FE_LOJCLI	= " + cPref + "_LOJA "				
				Else
					clQryTl += " AND FE_FORNECE	= " + cPref + "_FORNECE "
					clQryTl += " AND FE_LOJA	= " + cPref + "_LOJA "				
				EndIf

				If nTipImp == 1	 
					clQryTl += " AND FE_TIPO = 'I' "  
				ElseIf nTipImp == 2	
					clQryTl += " AND FE_TIPO = 'R' "  			
				EndIf
			clQryTl += " AND FE_NFISCAL	= "+cPref+"_DOC "
			clQryTl += " AND FE_SERIE	= "+cPref+"_SERIE "
			

				clQryTl += " AND FE_CONCEPT = " + cPref + "_CONCEPT "

				clQryTl += " AND FE_TES = " + cPref + "_TES "
				clQryTl += " INNER JOIN " + RetSqlName("SF3") + " SF3"
				clQryTl += " ON SF3.D_E_L_E_T_ = ' '"
				clQryTl += " AND F3_FILIAL = '" + xFilial("SF3") + "'"

				If nTipOpe == 2//Saida
					clQryTl += " AND F3_CLIEFOR = " + cPref + "_CLIENTE "
				Else
					clQryTl += " AND F3_CLIEFOR = " + cPref + "_FORNECE "			
				EndIf	

				clQryTl += " AND F3_ESPECIE	 NOT LIKE 'NC%'"			
				clQryTl += " AND F3_NFISCAL	= " + cPref + "_DOC "
				clQryTl += " AND F3_SERIE	= " + cPref + "_SERIE "

				If nTipImp == 2
					clQryTl += " AND F3_CONCEPT	= " + cPref + "_CONCEPT    
				EndIf

				clQryTl += " LEFT JOIN " + RetSqlName("SF4") + " SF4 "
				clQryTl += " ON SF4.D_E_L_E_T_ = ' ' "
				clQryTl += " AND F4_FILIAL	= F3_FILIAL "
				clQryTl += " AND F4_CODIGO	= F3_TES "
				clQryTl += " LEFT JOIN " + RetSqlName("CCR") + " CCR ON "
				clQryTl += " CCR.D_E_L_E_T_ = ' ' "  
				clQryTl += " AND CCR_CONCEP	= " + cPref + "_CONCEPT "
				clQryTl += " WHERE S" + cPref + ".D_E_L_E_T_ = ' '"
				clQryTl += " AND " + cPref + "_EMISSAO BETWEEN'" + DTOS(dDtIni) + "' AND '" + DTOS(dDtFim) + "'"
				clQryTl += " AND " + cPref + "_FILIAL = '" + xFilial("SF1") + "'"

				If nTipOpe == 2//Saida
					clQryTl += " AND " + cPref + "_CLIENTE BETWEEN '" + cCodIni + "' AND '" + cCodFim + "'"
				Else	                                                                
					clQryTl += " AND " + cPref + "_FORNECE BETWEEN '" + cCodIni + "' AND '" + cCodFim + "'"
				EndIf	

				clQryTl += " AND " + cPref + "_LOJA BETWEEN '" + cCodIni + "' AND '" + cLojFim + "'"
				clQryTl += " AND " + cPref + "_DOC BETWEEN '" + cDocIni + "' AND '" + cDocFim + "'"
				//Bruno Cremaschi - Projeto chave única.
				clQryTl += " AND " + cSDoc + " BETWEEN '" + cSerIni + "' AND '" + cSerFim + "'"				                          

				If nTipImp == 1
					clQryTl += " AND (" + cPref + "_BASIMP2 > 0 OR " + cPref + "_BASIMP3 > 0 OR " + cPref + "_BASIMP4 > 0 " + IIf(!Empty(cLvroRetC) .And. !(AllTrim(cLvroRetC) $ "2|3|4"), "OR " + cPref + "_BASIMP" + Alltrim(cLvroRetC) + " > 0 ", "") + ") "					
				ElseIf nTipImp == 2
					clQryTl += " AND " + cPref + "_VALIMP6 > 0 "
				ElseIf nTipImp == 3                 
					clQryTl += " AND (" + cPref + "_BASIMP2 > 0 OR " + cPref + "_BASIMP3 > 0 OR " + cPref + "_BASIMP4 > 0 OR " + cPref + "_VALIMP6 > 0 " + IIf(!Empty(cLvroRetC) .And. !(AllTrim(cLvroRetC) $ "2|3|4"), "OR " + cPref + "_BASIMP" + Alltrim(cLvroRetC) + " > 0 ", "") + ") " 
				EndIf

				If nTipOpe == 2//Saida
					clQryTl += " AND FE_CLIENTE IS NULL "                                                            
					clQryTl += " AND FE_LOJCLI IS NULL "
				Else
					clQryTl += " AND FE_FORNECE IS NULL "
					clQryTl += " AND FE_LOJA IS NULL "
				EndIf
				clQryTl += " AND FE_NFISCAL IS NULL "
				clQryTl += " AND FE_SERIE IS NULL "
				If nTipOpe == 2//Saida
					clQryTl += " ORDER BY " + cPref + "_CLIENTE "
				Else
					clQryTl += " ORDER BY " + cPref + "_FORNECE "
				EndIf
				clQryTl += ", " + cPref + "_LOJA "
				clQryTl += ", " + cPref + "_DOC "			
				clQryTl += ", " + cPref + "_SERIE "         
				clQryTl += ", " + cPref + "_EMISSAO "
				clQryTl += ", " + cPref + "_DTDIGIT "
				clQryTl += ", " + cPref + "_ESPECIE "

				cArqTMP1	:= ""
				aStrutTMP1	:= {}

				aAdd(aStrutTMP1, {"OK"					, "C", 002, 0})   
				aAdd(aStrutTMP1, {cPref + "_CONCEPT" 	, "C", TamSx3(cPref + "_CONCEPT")[1], 0})   
				aAdd(aStrutTMP1, {cPref + "_DOC" 		, "C", TamSx3(cPref + "_DOC")[1], 0})
				aAdd(aStrutTMP1, {cPref + "_SERIE"		, "C", TamSx3(cPref + "_SERIE")[1], 0})
				If !lSDoc
					aAdd(aStrutTMP1, {cSDoc, "C", TamSx3(cSDoc)[1], 0})
				EndIf
				aAdd(aStrutTMP1, {cPref + "_ESPECIE", "C", TamSx3(cPref + "_ESPECIE")[1], 0}) 
				If cPref == "D1"			
					aAdd(aStrutTMP1, {cPref + "_CLIFOR", "C", TamSx3("F1_FORNECE")[1], 0})
				Else
					aAdd(aStrutTMP1, {cPref + "_CLIFOR", "C", TamSx3("F2_CLIENTE")[1], 0})
				EndIf
				aAdd(aStrutTMP1, {cPref + "_LOJA"		, "C", TamSx3(cPref + "_LOJA")[1], 0})
				aAdd(aStrutTMP1, {cPref + "_EMISSAO"	, "C", TamSx3(cPref + "_EMISSAO")[1], 0})
				aAdd(aStrutTMP1, {cPref + "_DTDIGIT"	, "C", TamSx3(cPref + "_DTDIGIT")[1], 0})			
				aAdd(aStrutTMP1, {cPref + "_TES"	    , "C", TamSx3(cPref + "_TES")[1], 0})			
				aAdd(aStrutTMP1, {cPref + "_VALIMP1"	, "N", TamSx3(cPref + "_VALIMP1")[1], 2})
				If nTipImp == 1 .Or. nTipImp == 3
					aAdd(aStrutTMP1, {cPref + "_VALIMP2", "N", 014, 2})
					aAdd(aStrutTMP1, {cPref + "_VALIMP3", "N", 014, 2})
					aAdd(aStrutTMP1, {cPref + "_VALIMP4", "N", 014, 2})
					aAdd(aStrutTMP1, {cPref + "_BASIMP1", "N", 014, 2})
					aAdd(aStrutTMP1, {cPref + "_BASIMP2", "N", 014, 2})
					aAdd(aStrutTMP1, {cPref + "_BASIMP3", "N", 014, 2})
					aAdd(aStrutTMP1, {cPref + "_BASIMP4", "N", 014, 2})
					aAdd(aStrutTMP1, {cPref + "_ALQIMP2", "N", 006, 2})
					aAdd(aStrutTMP1, {cPref + "_ALQIMP3", "N", 006, 2})
					aAdd(aStrutTMP1, {cPref + "_ALQIMP4", "N", 006, 2})								
				EndIf
				If nTipImp == 2 .Or. nTipImp == 3			
					aAdd(aStrutTMP1, {cPref + "_VALIMP6", "N", 014, 2})
					aAdd(aStrutTMP1, {cPref + "_BASIMP6", "N", 014, 2})
					aAdd(aStrutTMP1, {cPref + "_ALQIMP6", "N", 006, 2})	
				EndIf	
				aAdd(aStrutTMP1, {cPref + "_TOTAL", "N", 013, 2})

			Else  // OUTROS PAISES

				cSDoc := SerieNFID("SF1", 3, "F1_SERIE")

				If cPaisLoc == 'COL'
					clQryTl := "SELECT '  ' AS OK, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_EMISSAO, F1_DTDIGIT, F1_VALBRUT, " 
					clQryTl += "F3_VALIMP1 F1_VALIMP1, F3_VALIMP2 F1_VALIMP2, F3_VALIMP7 F1_VALIMP7, "
					clQryTl += "F3_VALIMP4 F1_VALIMP4, F3_BASIMP1 F1_BASIMP1, F3_BASIMP4 F1_BASIMP4, F3_BASIMP7 F1_BASIMP7, F3_ALQIMP2, " 
					clQryTl += "F3_ALQIMP4, F3_ALQIMP7, F4_TIPORET, F3_CFO, F_TIPO, F3_ESPECIE "
					clQryTl += IIf( MV_PAR01 == 2, ",CC2_CODMUN, CC2_MUN","") //ICA
					clQryTl += " FROM ( "  
				Else
					clQryTl := ""
				EndIf
				clQryTl += " SELECT '  ' AS OK "
				clQryTl += ", F1_DOC "
				clQryTl += ", F1_SERIE "
				If !lSDoc
					clQryTl += ", " + cSDoc
				EndIf
				clQryTl += ", F1_FORNECE "
				clQryTl += ", F1_LOJA "
				clQryTl += ", F1_EMISSAO "
				clQryTl += ", F1_DTDIGIT "
				clQryTl += ", F1_VALBRUT "
				If cPaisLoc == 'COL'
					clQryTl += ", F3_VALIMP1 "
					clQryTl += ", F3_VALIMP2 "
					clQryTl += ", F3_VALIMP7 "
					clQryTl += ", F3_VALIMP4 "
					clQryTl += ", F3_BASIMP1 "
					clQryTl += ", F3_BASIMP4 "                                                                                   
					clQryTl += ", F3_BASIMP7 "
				Else   
					clQryTl += ", F1_VALIMP1 "
					clQryTl += ", F1_VALIMP2 "
					clQryTl += ", F1_VALIMP7 "
					clQryTl += ", F1_VALIMP4 "
					clQryTl += ", F1_BASIMP1 "
					clQryTl += ", F1_BASIMP4 "                                                                                   
					clQryTl += ", F1_BASIMP7 "
				EndIf

				clQryTl += ", F3_ALQIMP2 "
				clQryTl += ", F3_ALQIMP4 "
				clQryTl += ", F3_ALQIMP7 "

				clQryTl += ", F4_TIPORET "
				If cPaisLoc = 'COL'
					clQryTl += ", F3_CFO "
					clQryTl += ", '1' F_TIPO "
					clQryTl += ", F3_ESPECIE "
					If MV_PAR01 == 2 //ICA
						clQryTl += ", CC2_CODMUN "
						clQryTl += ", CC2_MUN "
					EndIf
				EndIf
				clQryTl += " FROM " + RetSqlName("SF1") + " SF1"
				clQryTl += " INNER JOIN " + RetSqlName("SF3") + " SF3"
				clQryTl += " ON SF3.D_E_L_E_T_ = ' '"
				clQryTl += " AND F3_FILIAL = '" + xFilial("SF3")+"'"
				clQryTl += " AND F3_CLIEFOR = F1_FORNECE "
				clQryTl += " AND F3_LOJA = F1_LOJA "
				clQryTl += " AND F3_NFISCAL	= F1_DOC "
				clQryTl += " AND F3_SERIE = F1_SERIE "

				If cPaisLoc == 'COL'
					//NDP = Nota de débito Proveedor. NCI = Nota de crédito Interna
					clQryTl += " AND F3_ESPECIE IN ('" + PADR("NF",TamSx3("F3_ESPECIE")[1]) + "','" + PADR("NDP", TamSx3("F3_ESPECIE")[1]) + "', '" + PADR("NCI",TamSx3("F3_ESPECIE")[1]) + "') "
				EndIf

				If MV_PAR01 == 1
					clQryTl += " AND F3_VALIMP2 > 0 "
				ElseIf MV_PAR01 == 2
					clQryTl += " AND F3_VALIMP7 > 0 "
				Else                                                    
					clQryTl += " AND F3_VALIMP4 > 0 "
				EndIf

				clQryTl += " LEFT JOIN "+RetSqlName("SFE")+" SFE"
				clQryTl += " ON SFE.D_E_L_E_T_ = ' '"
				clQryTl += " AND FE_FILIAL = '" + xFilial("SFE") + "'"        

				If MV_PAR01 == 1 .And. cPaisLoc == "COL"    
					clQryTl += " AND FE_TIPO = 'I' "
				ElseIf MV_PAR01 == 2 .And. cPaisLoc=="COL"    
					clQryTl += " AND FE_TIPO = 'C' "
				ElseIf MV_PAR01 == 3 .And. cPaisLoc=="COL"
					clQryTl += " AND FE_TIPO = 'F' "
				EndIf

				clQryTl += " AND FE_FORNECE	= F1_FORNECE "
				clQryTl += " AND FE_LOJA = F1_LOJA "
				clQryTl += " AND FE_NFISCAL	= F1_DOC "
				clQryTl += " AND FE_SERIE = F1_SERIE "   
				
				If cPaisLoc == "COL" .AND. MV_PAR01 == 2 //ICA
					clQryTl += " INNER JOIN " + RetSqlName("CC2") + " CC2 ON SF1.F1_CODMUN = CC2.CC2_CODMUN "
				EndIf
				
				clQryTl += " LEFT JOIN "+RetSqlName("SF4")+" SF4"
				clQryTl += " ON SF4.D_E_L_E_T_ = ' ' "
				clQryTl += " AND F4_FILIAL = F3_FILIAL " 
				clQryTl += " AND F4_CODIGO = F3_TES "
				// clQryTl += " AND F4_CF 		= F3_CFO "
				clQryTl += " WHERE SF1.D_E_L_E_T_ = ' '"
				clQryTl += " AND F1_EMISSAO BETWEEN'" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "'"
				clQryTl += " AND F1_FILIAL = '" + xFilial("SF1") + "'"
				If MV_PAR01 == 1
					clQryTl += " AND F1_VALIMP2 > 0 "  
				ElseIf MV_PAR01 == 2
					clQryTl += " AND F1_VALIMP7 > 0 "
				Else
					clQryTl += " AND F1_VALIMP4 > 0 "
				EndIf

				clQryTl += " AND F1_FORNECE >= '"	+ MV_PAR04 +"'"
				clQryTl += " AND F1_LOJA >= '" 		+ MV_PAR05 +"'"

				clQryTl += " AND F1_FORNECE <= '" 	+ MV_PAR06 +"'"
				clQryTl += " AND F1_LOJA <= '" 		+ MV_PAR07 +"'"

				clQryTl += " AND F1_DOC >= '" 	+ MV_PAR08 +"'"
				clQryTl += " AND F1_DOC <= '" 	+ MV_PAR10 +"'"

				//Bruno Cremaschi - Projetochave única.
				clQryTl += " AND " + cSDoc + " >= '" + MV_PAR09 + "'"
				clQryTl += " AND " + cSDoc + " <= '" + MV_PAR11 + "'"

				clQryTl += " AND FE_FORNECE IS NULL "
				clQryTl += " AND FE_LOJA IS NULL "
				clQryTl += " AND FE_NFISCAL IS NULL "
				clQryTl += " AND FE_SERIE IS NULL "
				If cPaisLoc == 'COL' // Asigna union a query
					clQryTl += FISA15F2()
				EndIf

				clQryTl += " ORDER BY F1_FORNECE "
				clQryTl += ", F1_LOJA "
				If MV_PAR01 == 1
					clQryTl += ", F3_ALQIMP2 "  
				ElseIf MV_PAR01 == 2
					clQryTl += IIF(cPaisLoc == 'COL', ", CC2_CODMUN", "")
					clQryTl += ", F3_ALQIMP7 "
				Else
					clQryTl += ", F3_ALQIMP4 "
				EndIf

				If cPaisLoc == 'COL'
					clQryTl += ", F_TIPO"
				EndIf

			EndIf		    

			clQryTl	:= ChangeQuery(clQryTl)

			If Select("TMP") > 0
				DbSelectArea("TMP")
				TMP->(dbCloseArea())
			EndIf

			TcQuery clQryTl New Alias "TMP"

			If TMP->(!Eof())
				If cPaisLoc == "EQU"

					aOrdem := {cPref + "_CONCEPT", cPref + "_DOC", cPref + "_SERIE"}

					oTmpTable := FWTemporaryTable():New("TMP1")
					oTmpTable:SetFields(aStrutTMP1)
					oTmpTable:AddIndex("I1", aOrdem)
					oTmpTable:Create()

					DbSelectArea("TMP")
					TMP->(DbGoTop())				
					Do While TMP->(!Eof())
						nMoeda	:= 1
						nTxMoeda:= 1
						If cPref == "D1"
							DbSelectArea("SF1")
							SF1->(DbSetOrder(1))//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA
							SF1->(DbGoTop())					
							If DbSeek(xFilial("SF1")+AvKey(TMP->DOC,"F1_DOC")+AvKey(TMP->SERIE,"F1_SERIE")+AvKey(TMP->CLIFOR,"F1_FORNECE")+AvKey(TMP->LOJA,"F1_LOJA"))
								nMoeda		:= SF1->F1_MOEDA
								nTxMoeda	:= SF1->F1_TXMOEDA
							EndIf
						Else
							DbSelectArea("SF2")
							SF2->(DbSetOrder(1))//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F1_LOJA
							SF2->(DbGoTop())						
							If DbSeek(xFilial("SF2")+AvKey(TMP->DOC,"F2_DOC")+AvKey(TMP->SERIE,"F2_SERIE")+AvKey(TMP->CLIFOR,"F2_CLIENTE")+AvKey(TMP->LOJA,"F2_LOJA"))
								nMoeda		:= SF2->F2_MOEDA
								nTxMoeda	:= SF2->F2_TXMOEDA
							EndIf
						EndIf

						cNumDoc	:= TMP->DOC
						cSerie	:= TMP->SERIE
						//Bruno Cremaschi - Projeto chave única.
						If !lSDoc
							cSerRea	:= TMP->SDOC
						EndIf
						cCliFor		:= TMP->CLIFOR
						cLoja		:= TMP->LOJA
						cEspecie	:= TMP->ESPECIE
						cConcept	:= TMP->CONCEPT
						cTes	    := TMP->TES
						cEmissao	:= Substr(TMP->EMISSAO, 7, 2) + "/" + Substr(TMP->EMISSAO, 5, 2) + "/" + Substr(TMP->EMISSAO, 1, 4)
						cDtDigit	:= Substr(TMP->DTDIGIT, 7, 2) + "/" + Substr(TMP->DTDIGIT, 5, 2) + "/" + Substr(TMP->DTDIGIT, 1, 4)
						nAlqImp2	:= 0
						nAlqImp3	:= 0
						nAlqImp4	:= 0
						nAlqImp6	:= 0
						nValImp1	:= 0
						nValImp2	:= 0
						nValImp3	:= 0
						nValImp4	:= 0
						nValImp6	:= 0
						nBasImp2	:= 0
						nBasImp3	:= 0
						nBasImp4	:= 0
						nBasImp6	:= 0
						nTotal		:= 0                   
						Do While TMP->(!Eof()) .And. ;
						Alltrim(cNumDoc) + Alltrim(cSerie) + Alltrim(cCliFor) + Alltrim(cLoja) + Alltrim(cConcept) == ;
						Alltrim(TMP->DOC) + Alltrim(TMP->SERIE) + Alltrim(TMP->CLIFOR) + Alltrim(TMP->LOJA) + Alltrim(TMP->CONCEPT)

							nValImp1 += TMP->VALIMP1
							If nTipImp == 1 .Or. nTipImp == 3			
								If TMP->VALIMP2 > 0 .Or. (cPaisLoc == "EQU" .And. TMP->BASIMP2 > 0)
									nAlqImp2 := TMP->ALQIMP2
									nValImp2 += TMP->VALIMP2 
									nBasImp2 += TMP->BASIMP2			                    
								EndIf          
								If TMP->VALIMP3 > 0 .Or. (cPaisLoc == "EQU" .And. TMP->BASIMP3 > 0)
									nAlqImp3 := TMP->ALQIMP3
									nValImp3 += TMP->VALIMP3			                    
									nBasImp3 += TMP->BASIMP3		                        
								EndIf    
								If TMP->VALIMP4 > 0 .Or. (cPaisLoc == "EQU" .And. TMP->BASIMP4 > 0)
									nAlqImp4 := TMP->ALQIMP4
									nValImp4 += TMP->VALIMP4         			           
									nBasImp4 += TMP->BASIMP4		           				
								EndIf   
							EndIf
							If nTipImp == 2 .Or. nTipImp == 3			
								nAlqImp6 := TMP->ALQIMP6
								nValImp6 += TMP->VALIMP6
								nBasImp6 += TMP->BASIMP6
							EndIf
							nTotal += TMP->TOTAL

							TMP->(DbSkip())
						End                

						RecLock("TMP1",.T.)
						TMP1->&(cPref+"_OK")	  := ' '
						TMP1->&(cPref+"_CONCEPT") := cConcept
						TMP1->&(cPref+"_DOC")     := cNumDoc
						//Bruno Cremaschi - Projeto chave única.
						TMP1->&(cPref+"_SERIE")   := cSerie
						If !lSDoc
							TMP1->&cSDoc := cSerRea
						EndIf		
						TMP1->&(cPref + "_ESPECIE") := cEspecie
						TMP1->&(cPref + "_CLIFOR")  := cCliFor
						TMP1->&(cPref + "_LOJA")    := cLoja
						TMP1->&(cPref + "_EMISSAO") := cEmissao
						TMP1->&(cPref + "_DTDIGIT") := cDtDigit
						TMP1->&(cPref + "_TES")		:= cTes
						TMP1->&(cPref + "_VALIMP1") := IIf(nTXMoeda == 1, nValImp1, xMoeda(nValImp1, nMoeda, 1, Stod(TMP->EMISSAO), 5, nTXMoeda,MsDecimais(1)))
						TMP1->&(cPref + "_VALIMP2") := IIf(nTXMoeda == 1, nValImp2, xMoeda(nValImp2, nMoeda, 1, Stod(TMP->EMISSAO), 5, nTXMoeda,MsDecimais(1)))
						TMP1->&(cPref + "_VALIMP3") := IIf(nTXMoeda == 1, nValImp3, xMoeda(nValImp3, nMoeda, 1, Stod(TMP->EMISSAO), 5, nTXMoeda,MsDecimais(1)))
						TMP1->&(cPref + "_VALIMP4") := IIf(nTXMoeda == 1, nValImp4, xMoeda(nValImp4, nMoeda, 1, Stod(TMP->EMISSAO), 5, nTXMoeda,MsDecimais(1)))
						TMP1->&(cPref + "_VALIMP6") := IIf(nTXMoeda == 1, nValImp6, xMoeda(nValImp6, nMoeda, 1, Stod(TMP->EMISSAO), 5, nTXMoeda,MsDecimais(1)))
						TMP1->&(cPref + "_BASIMP2") := IIf(nTXMoeda == 1, nBasImp2, xMoeda(nBasImp2, nMoeda, 1, Stod(TMP->EMISSAO), 5, nTXMoeda,MsDecimais(1)))
						TMP1->&(cPref + "_BASIMP3") := IIf(nTXMoeda == 1, nBasImp3, xMoeda(nBasImp3, nMoeda, 1, Stod(TMP->EMISSAO), 5, nTXMoeda,MsDecimais(1)))
						TMP1->&(cPref + "_BASIMP4") := IIf(nTXMoeda == 1, nBasImp4, xMoeda(nBasImp4, nMoeda, 1, Stod(TMP->EMISSAO), 5, nTXMoeda,MsDecimais(1)))
						TMP1->&(cPref + "_BASIMP6") := IIf(nTXMoeda == 1, nBasImp6, xMoeda(nBasImp6, nMoeda, 1, Stod(TMP->EMISSAO), 5, nTXMoeda,MsDecimais(1)))
						TMP1->&(cPref + "_ALQIMP2") := nAlqImp2
						TMP1->&(cPref + "_ALQIMP3") := nAlqImp3
						TMP1->&(cPref + "_ALQIMP4") := nAlqImp4
						TMP1->&(cPref + "_ALQIMP6") := IIf(nValImp6 > 0, nAlqImp6, 0)
						TMP1->&(cPref + "_TOTAL")   := IIf(nTXMoeda == 1, nTotal, xMoeda(nTotal, nMoeda, 1, Stod(TMP->EMISSAO), 5, nTXMoeda, MsDecimais(1)))
						TMP1->(MsUnlock())
					EndDo

					DbSelectArea("TMP1")
					TMP1->(DbGoTop())

					aAdd(apCampos, {cPref + "_OK"	, , ""		, "", , })				
					aAdd(apCampos, {cPref + "_DOC"	, , STR0001	, "", , }) // "Fatura"
					//Bruno Cremaschi - Projeto chave única.
					If lSDoc
						aAdd(apCampos, {cPref+"_SERIE", , STR0002, "", , }) // "Séire"
					Else
						aAdd(apCampos,{cSDoc, , STR0002, "", , }) // "Séire"
					EndIf
					aAdd(apCampos, {cPref + "_ESPECIE"	, , STR0022, "" ,,}) // "Especie"
					aAdd(apCampos, {cPref + "_CLIFOR"	, , IIf(nTipOpe == 1, STR0003, STR0023), "", ,})// "Fornecedor"|"Cliente"
					aAdd(apCampos, {cPref + "_LOJA"		, , STR0004, "", , }) // "Loja"
					aAdd(apCampos, {cPref + "_EMISSAO"	, , STR0005, "", , }) // "Emissão"
					aAdd(apCampos, {cPref + "_DTDIGIT"	, , STR0006, "", , }) // "Entrada"
					aAdd(apCampos, {cPref + "_CONCEPT"	, , STR0024, "", , }) // "Concepto"
					aAdd(apCampos, {cPref + "_TES"		, , STR0050, "", , }) // "Tes"				
					aAdd(apCampos, {cPref + "_TOTAL "	, , STR0007, Pesqpict(IIf(nTipOpe == 1, "SD1", "SD2"), cPref + "_TOTAL"), TamSx3(cPref + "_TOTAL")[1], TamSx3(cPref + "_TOTAL")[2]}) // "Valor Fatura"				
					clDescImp := ""
					If nTipImp == 1 .OR. nTipImp == 3
						clDescImp += STR0008	// "Retenção IVA"
						aAdd(apCampos, {cPref + "_BASIMP2", ,STR0026, Pesqpict(IIf(nTipOpe == 1, "SD1", "SD2"), cPref + "_BASIMP2"), TamSx3(cPref+"_BASIMP2")[1],TamSx3(cPref+"_BASIMP2")[2]	})//"Bs.IVA 30%" 
						aAdd(apCampos, {cPref + "_ALQIMP2", ,STR0027, Pesqpict(IIf(nTipOpe == 1, "SD1", "SD2"), cPref + "_ALQIMP2"), TamSx3(cPref+"_ALQIMP2")[1],TamSx3(cPref+"_ALQIMP2")[2]	})//"Alq.IVA 30%"
						aAdd(apCampos, {cPref + "_VALIMP2", ,STR0028, Pesqpict(IIf(nTipOpe == 1, "SD1", "SD2"), cPref + "_VALIMP2"), TamSx3(cPref+"_VALIMP2")[1],TamSx3(cPref+"_VALIMP2")[2]	})//"Vlr.IVA 30%"
						aAdd(apCampos, {cPref + "_BASIMP3", ,STR0029, Pesqpict(IIf(nTipOpe == 1, "SD1", "SD2"), cPref + "_BASIMP3"), TamSx3(cPref+"_BASIMP3")[1],TamSx3(cPref+"_BASIMP3")[2]	})//"Bs.IVA 70%" 
						aAdd(apCampos, {cPref + "_ALQIMP3", ,STR0030, Pesqpict(IIf(nTipOpe == 1, "SD1", "SD2"), cPref + "_ALQIMP3"), TamSx3(cPref+"_ALQIMP3")[1],TamSx3(cPref+"_ALQIMP3")[2]	})//"Alq.IVA 70%"
						aAdd(apCampos, {cPref + "_VALIMP3", ,STR0031, Pesqpict(IIf(nTipOpe == 1, "SD1", "SD2"), cPref + "_VALIMP3"), TamSx3(cPref+"_VALIMP3")[1],TamSx3(cPref+"_VALIMP3")[2]	})//"Vlr.IVA 70%"
						aAdd(apCampos, {cPref + "_BASIMP4", ,STR0032, Pesqpict(IIf(nTipOpe == 1, "SD1", "SD2"), cPref + "_BASIMP4"), TamSx3(cPref+"_BASIMP4")[1],TamSx3(cPref+"_BASIMP4")[2]	})//"Bs.IVA 100%" 
						aAdd(apCampos, {cPref + "_ALQIMP4", ,STR0033, Pesqpict(IIf(nTipOpe == 1, "SD1", "SD2"), cPref + "_ALQIMP4"), TamSx3(cPref+"_ALQIMP4")[1],TamSx3(cPref+"_ALQIMP4")[2]	})//"Alq.IVA 70%"
						aAdd(apCampos, {cPref + "_VALIMP4", ,STR0034, Pesqpict(IIf(nTipOpe == 1, "SD1", "SD2"), cPref + "_VALIMP4"), TamSx3(cPref+"_VALIMP4")[1],TamSx3(cPref+"_VALIMP4")[2]	})//"Vlr.IVA 100%"
					EndIf	
					If nTipImp == 2 .OR. nTipImp == 3
						If !Empty(clDescImp)
							clDescImp += Space(1) + "-" + Space(1)
						EndIf
						clDescImp	+= STR0025	// "Retenção IR"                                                                                                                  
						aAdd(apCampos, {cPref + "_BASIMP6", , STR0047, Pesqpict(IIf(nTipOpe == 1, "SD1", "SD2"), cPref + "_BASIMP6"), TamSx3(cPref + "_BASIMP6")[1], TamSx3(cPref + "_BASIMP6")[2]})//"Bs.IR%" 					
						aAdd(apCampos, {cPref + "_ALQIMP6", , STR0048, Pesqpict(IIf(nTipOpe == 1, "SD1", "SD2"), cPref + "_ALQIMP6"), TamSx3("CCR_ALIQ")[1], TamSx3("CCR_ALIQ")[2]})//"Alq.IR%" 
						aAdd(apCampos, {cPref + "_VALIMP6", , STR0049, Pesqpict(IIf(nTipOpe == 1, "SD1", "SD2"), cPref + "_VALIMP6"), TamSx3(cPref + "_VALIMP6")[1], TamSx3(cPref + "_VALIMP6")[2]})//"Vlr.IR%" 
					EndIf
				Else
					If Select("TMP1")>0
						DbSelectArea("TMP1")
						TMP1->(DbCloseArea())
					EndIf
					If cPaisLoc == "COL" .and. nTipImp == 2 // ICA
						aOrdem := {"F1_FORNECE", "F1_LOJA", "CC2_CODMUN", "F3_ALQIMP7"}
					Else
						aOrdem := {"F1_DOC", "F1_SERIE", "F1_FORNECE", "F1_LOJA"}
					EndIf
					aEstTMP := TMP->(DBSTRUCT())

					For nX := 1 to Len(aEstTMP)
						aTamSX3	:= TamSX3(aEstTMP[nX][1])
						If Len(aTamSX3) > 0
							aEstTMP[nX][3] := aTamSX3[1] //Tamaño
							aEstTMP[nX][4] := aTamSX3[2] //Decimales
						EndIf
					Next

					oTmpTable := FWTemporaryTable():New("TMP1")
					oTmpTable:SetFields(aEstTMP)
					oTmpTable:AddIndex("I1", aOrdem)
					oTmpTable:Create()

					DbSelectArea("TMP")
					TMP->(DbGoTop())				
					Do While TMP->(!Eof())
						RecLock("TMP1", .T.)
						For nX := 1 to Len(aEstTMP)   
						   TMP1->(&(aEstTMP[nX][1])) := TMP->(&(aEstTMP[nX][1]))
						Next
						TMP1->(MsUnlock())
						TMP->(dbSkip())
					EndDo
					TMP->(DbGoTop())	
					aAdd(apCampos, {"OK"		, , ""		, "", , })
					aAdd(apCampos, {"F1_DOC"	, , STR0001	, "", , }) // "Fatura"
					//Bruno Cremaschi - Projeto chave única.
					If lSDoc
						aAdd(apCampos, {"F1_SERIE", , STR0002, "", , }) // "Séire"
					Else
						aAdd(apCampos, {cSDoc, , STR0002, "", , }) // "Séire"
					EndIf
					aAdd(apCampos, {"F1_FORNECE"	, , STR0003, "", , }) // "Fornecedor"
					aAdd(apCampos, {"F1_LOJA"		, , STR0004, "", , }) // "Loja"
					If cPaisLoc == "COL" .and. nTipImp == 2 // ICA
						aAdd(apCampos, {"CC2_CODMUN" , , STR0051	, "", TamSx3("CC2_CODMUN")[1], TamSx3("CC2_CODMUN")[2]}) // "Cod. Mun"
						aAdd(apCampos, {"CC2_MUN" , , STR0052	, "", TamSx3("CC2_MUN")[1], TamSx3("CC2_MUN")[2]}) // " Municipio"
					EndIf
					aAdd(apCampos, {"F1_EMISSAO"	, , STR0005, "", , }) // "Emissão"
					aAdd(apCampos, {"F1_DTDIGIT"	, , STR0006, "", , }) // "Entrada"
					aAdd(apCampos, {"F1_VALBRUT"	, , STR0007, Pesqpict("SF1", "F1_VALBRUT"), TamSx3("F1_VALBRUT")[1], TamSx3("F1_VALBRUT")[2]}) // "Valor Fatura"
					If nTipImp == 1
						clDescImp	:= STR0008	// "Retenção IVA"
					ElseIf nTipImp == 2
						clDescImp	:= STR0009	// "Retenção ICA"
					Else
						clDescImp	:= STR0010	// "Retenção Fonte"
					EndIf
					aAdd(apCampos, {"F1_VALIMP2", , STR0008	, Pesqpict("SF1", "F1_VALIMP2"), TamSx3("F1_VALIMP2")[1], TamSx3("F1_VALIMP2")[2]}) // "Retenção IVA"
					aAdd(apCampos, {"F1_VALIMP7", , STR0009	, Pesqpict("SF1", "F1_VALIMP7"), TamSx3("F1_VALIMP7")[1], TamSx3("F1_VALIMP7")[2]}) // "Retenção ICA"
					aAdd(apCampos, {"F1_VALIMP4", , STR0010	, Pesqpict("SF1", "F1_VALIMP4"), TamSx3("F1_VALIMP4")[1], TamSx3("F1_VALIMP4")[2]}) // "Retenção Fonte"
				EndIf
			Else
				If cPaisLoc == "EQU" 
					If nTipOpe == 1//Entrada
						Aviso(STR0035, STR0037, {STR0021})//"Certificado de Retencao Entrada"###"As Notas Fiscais de acordo com os parametros nao foi encontrado na base de dados. "###"OK"
					Else
						Aviso(STR0036, STR0037, {STR0021})//"Certificado de Retencao Saida"###"As Notas Fiscais de acordo com os parametros nao foi encontrado na base de dados. "###"OK"
					EndIf
					Return         
				EndIf
			EndIf
			If Select("TMP1") > 0 
				aSize[2] := 6
				TMP1->(DbGoTop())				
				Define MsDialog olDlg Title STR0011 From aSize[1], aSize[2] TO aSize[1] + 600,aSize[2] + 788 Pixel // "Certificados de Retenção"
				@ aSize[1] + 5, aSize[2] Group oGrpImps To aSize[1] + 280, aSize[2] + 384 Label clDescImp Of olDlg Pixel

				oBtALL := tButton():New(aSize[1]+263,aSize[2]+3		,STR0012,olDlg,{|| FMarca( llMarc)},60,10,,,,.T.) // "Selecionar Todas"
				oBtOFF := tButton():New(aSize[1]+263,aSize[2]+070	,STR0013,olDlg,{|| FMarca(!llMarc)},60,10,,,,.T.) // "Desmarcar Todas"
				//Listagem das Notas Fiscais que estao pendentes de certificado de retencao
				If cPaisLoc == "EQU" .And. nTipOpe == 2
					oBtn01 := tButton():New(aSize[1]+263,aSize[2]+320,STR0038,olDlg,{||ImpCertPend()},60,10,,,,.T.)//"Pendentes"
				EndIf
				oBtn02 := SButton():New(aSize[1]+285,aSize[2]+320,1, {|| FGrvCrt(nTipOpe),olDlg:End()	},,.T.)
				oBtn03 := SButton():New(aSize[1]+285,aSize[2]+350,2, {|| olDlg:End()         		},,.T.)
	   
				olMark := MsSelect():New("TMP1", "OK", , apCampos, , @cpMarca, {aSize[1] + 15, aSize[2] + 3, aSize[1] + 255, aSize[2] + 379})
				olMark:oBrowse:lhasMark := .T.
				olMark:oBrowse:lCanAllmark := .F.			
				ACTIVATE MSDIALOG olDlg CENTERED
			Else 
				Aviso(STR0011,STR0037,{STR0021})
				Return
			EndIf	

			If oTmpTable <> Nil
				oTmpTable:Delete()
				oTmpTable := Nil
			EndIf

			//Re-Imprimir
		ElseIf nOpcao == 2
			
			clQry := FQrIEc()
            clQry	:= ChangeQuery(clQry)
			If Select("TMP") > 0
				DbSelectArea("TMP")
				TMP->(DbCloseArea())
			EndIf

			TcQuery clQry New Alias "TMP"

			TCSetField("TMP", "FE_VALBASE"	, "N", TamSx3("F1_BASIMP1")[1]	, TamSx3("F1_BASIMP1")[2])
			TCSetField("TMP", "FE_ALIQ"		, "N", TamSx3("FE_ALIQ")[1]		, TamSx3("FE_ALIQ")[2])
			TCSetField("TMP", "FE_VALIMP"	, "N", TamSx3("F1_VALIMP1")[1]	, TamSx3("F1_VALIMP1")[2])
			TCSetField("TMP", "FE_RETENC"	, "N", TamSx3("F1_VALIMP1")[1]	, TamSx3("F1_VALIMP1")[2])
			TCSetField("TMP", "FE_EMISSAO"	, "D")
			
			DbSelectArea("SF1")
			DbSelectArea("SF2")
			DbSelectArea("CC2")
			DbSelectArea("TMP")
			TMP->(dbGoTop())
			If TMP->(!EOF())
				//Bruno Cremaschi
				While TMP->(!EOF())
					cCodMun := ""
					cDesMun := ""
					If cPaisLoc == "COL" .AND. nTipImp == 2
						If TMP->FE_TIPDOC == "1" // Doc Entrada
							SF1->(DbSetOrder(1))//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO  
							If SF1->(dbSeek(xfilial("SF1")+TMP->FE_NFISCAL+TMP->FE_SERIE+TMP->FE_FORNECE+TMP->FE_LOJA))
							 	cCodMun := SF1->F1_CODMUN
							Endif
						ElseIf TMP->FE_TIPDOC == "2" // Doc Salida
							SF2->(DbSetOrder(1))//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO       
							If SF2->(dbSeek(xfilial("SF2")+TMP->FE_NFISCAL+TMP->FE_SERIE+TMP->FE_FORNECE+TMP->FE_LOJA))
							 	cCodMun := SF2->F2_CODMUN
							Endif
						EndIf
						
						If !EMPTY(cCodMun)
							CC2->(DbSetOrder(3))//CC2_FILIAL+CC2_CODMUN 
							If CC2->(dbSeek(xfilial("CC2")+cCodMun))
								cDesMun := CC2->CC2_MUN
							Endif
						EndIf
						
					EndIf
					
					aAdd(alCertRet,{TMP->FE_NROCERT,;	// [1]	Numero Certificado
					TMP->FE_EMISSAO,;	// [2]	Data Emissao
					IIf(cPaisLoc == "EQU", IIf(!Empty(TMP->FE_CLIENTE), TMP->FE_CLIENTE, TMP->FE_FORNECE), TMP->FE_FORNECE),; // [3]	Codigo do Fornecedor
					IIf(cPaisLoc == "EQU", IIf(!Empty(TMP->FE_CLIENTE), TMP->FE_LOJCLI , TMP->FE_LOJA), TMP->FE_LOJA),; // [4]	Loja
					TMP->FE_TIPO,;		// [5]	Tipo
					TMP->FE_NFISCAL,;	// [6]	Numero da fatura
					TMP->FE_SERIE,;		// [7]	Serie da fatura
					TMP->FE_VALBASE,;	// [8]	Base de calculo da retenção
					TMP->FE_ALIQ,;		// [9]	Aliquota para o Calculo
					TMP->FE_FILIAL,;	// [10]	Filial que está gerando o certificado
					TMP->FE_VALIMP,;	// [11]	Valor do imposto da retenção
					TMP->FE_RETENC,;	// [12]	Valor da retenção
					TMP->FE_CONCEPT,; 	// [13]	Codigo Fiscal da Operação
					IIf(cPaisLoc == "EQU", TMP->FE_CODRET, IIf(cPaisLoc == "COL", TMP->FE_CFO, "")),;	// [14]	Codigo Retencao / Colombia Codigo Fiscal
					IIf(cPaisLoc == "EQU", TMP->FE_NUMAUT, IIf(cPaisLoc == "COL", TMP->FE_TIPDOC, "")),; 	// [15]	Numero Autorizacao /Colombia Tipo doc 1= Entrada 2 =salida
					IIf(cPaisLoc == "EQU" .OR. cPaisLoc == "COL", TMP->FE_ESPECIE, ""),;   // [16] Espécie da nota
					IIf(cPaisLoc == "EQU", IIf(!Empty(TMP->FE_CLIENTE),"C","F"),"") ,;  // [17] Tipo (C-Cliente\F-Fornecedor)
					IIf(cPaisLoc == "COL" .AND. nTipImp == 2 ,cCodMun,""),; // [18] Cod. Municipio para ICA
					IIf(cPaisLoc == "COL" .AND. nTipImp == 2 ,cDesMun,"")})		// [19] Municipio para ICA
					TMP->(DbSkip())
				EndDo

				If cPaisLoc == "COL"
					alCertRet := FIS015GR(alCertRet)
				EndIf
				If cPaisLoc == "EQU"
					FISR014(alCertRet)
				Else
					If nTipImp == 1 		// IVA
						MATR991(alCertRet)
					ElseIf nTipImp == 2 	// ICA
						MATR993(alCertRet)
					Else 					//Fonte
						MATR992(alCertRet)
					EndIf
				EndIf
			Else
				Aviso(STR0011, STR0014 +;// "Certificados de Retenção"###"O certificado de retenção informado não foi encontrado na base de dados."###
				IIF(cPaisLoc == "EQU", STR0039, STR0015),;// "Informe um número de certificado existente ou selecione 'Impressão' para gerar um novo certificado"
				{STR0021})// "Ok"
			EndIf    
			//Excluir			
		Else
			clQry := FQrIEc()
			clQry	:= ChangeQuery(clQry)
			If Select("TMP") > 0
				DbSelectArea("TMP")
				TMP->(DbCloseArea())
			EndIf
			TcQuery clQry New Alias "TMP"

			If cPaisLoc $ "EQU|VEN"
				cArqTMP1   := ""
				aStrutTMP1 := {}
				apCampos   := {}

				aAdd(aStrutTMP1, {"OK"			, "C", 002, 0})   
				aAdd(aStrutTMP1, {"FE_NROCERT"	, "C", TamSx3("FE_NROCERT")[1], 0})
				aAdd(aStrutTMP1, {"FE_EMISSAO"	, "D", TamSx3("FE_EMISSAO")[1], 0})

				If nTipOpe == 1
					aAdd(aStrutTMP1,{"FE_FORNECE"	, "C", TamSx3("FE_FORNECE")[1], 0})
					aAdd(aStrutTMP1,{"FE_LOJA"		, "C", TamSx3("FE_LOJA")[1], 0})
				Else
					aAdd(aStrutTMP1,{"FE_CLIENTE"	, "C", TamSx3("FE_CLIENTE")[1], 0})
					aAdd(aStrutTMP1,{"FE_LOJCLI"	, "C", TamSx3("FE_LOJCLI")[1], 0})
				EndIf

				aAdd(aStrutTMP1, {"FE_NFISCAL" , "C", TamSx3("FE_NFISCAL")[1], 0})
				aAdd(aStrutTMP1, {"FE_SERIE"   , "C", TamSx3("FE_SERIE")[1], 0})
				aAdd(aStrutTMP1, {"FE_TIPO"    , "C", TamSx3("FE_TIPO")[1], 0})

				aOrdem2 := {"FE_NROCERT", "FE_EMISSAO"}

				oTmpTable2 := FWTemporaryTable():New("TMP1")
				oTmpTable2:SetFields(aStrutTMP1)
				oTmpTable2:AddIndex("I1", aOrdem2)
				oTmpTable2:Create()

				dbSelectArea("TMP")
				TMP->(dbGoTop())
				While TMP->(!EOF())
					If RecLock("TMP1",.T.)
						TMP1->OK         := ' '
						TMP1->FE_NROCERT := TMP->FE_NROCERT
						TMP1->FE_EMISSAO := STOD(TMP->FE_EMISSAO)
						If nTipOpe == 1
							TMP1->FE_FORNECE := TMP->FE_FORNECE
							TMP1->FE_LOJA    := TMP->FE_LOJA
						Else
							TMP1->FE_CLIENTE := TMP->FE_CLIENTE
							TMP1->FE_LOJCLI  := TMP->FE_LOJCLI
						EndIf
						TMP1->FE_NFISCAL := TMP->FE_NFISCAL
						//Bruno Cremaschi - Projeto chave única.
						TMP1->FE_SERIE   := TMP->FE_SERIE
						TMP1->FE_TIPO    := TMP->FE_TIPO
					EndIf
					TMP->(dbSkip())
				End
				TMP->(dbCloseArea())
				TMP1->(dbGoTop())

				If TMP1->(!EOF())
					aSize[2] := 6
					aAdd(apCampos, {"OK"			, , ""				, "", , })
					aAdd(apCampos, {"FE_NROCERT"	, , "Certificado"	, "", , })
					aAdd(apCampos, {"FE_EMISSAO"	, , "Emissao"		, "", , })
					If nTipOpe == 1
						aAdd(apCampos, {"FE_FORNECE"	, , "Fornecedor"	, "", , })
						aAdd(apCampos, {"FE_LOJA"		, , "Loja"			, "", , })
					Else
						aAdd(apCampos, {"FE_CLIENTE"	, , "Cliente"	, "", , })
						aAdd(apCampos, {"FE_LOJCLI"		, , "Loja"		, "", , })
					EndIf
					aAdd(apCampos, {"FE_NFISCAL"	, , "Nota Fiscal"	, "", , })
					aAdd(apCampos, {"FE_SERIE"		, , "Serie"			, "", , })

					Define MsDialog olDlg Title STR0011 From aSize[1],aSize[2] TO aSize[1]+600,aSize[2]+810 Pixel // "Certificados de Retenção"
					@ aSize[1]+5,aSize[2]+5 Group oGrpImps To aSize[1]+280,aSize[2]+395 Label clDescImp Of olDlg Pixel

					oBtALL := tButton():New(aSize[1] + 263, aSize[2] + 10 , STR0012, olDlg, {|| FMarca(llMarc)}, 60, 10, , , , .T.) // "Selecionar Todas"
					oBtOFF := tButton():New(aSize[1] + 263, aSize[2] + 75 , STR0013, olDlg, {|| FMarca(!llMarc)}, 60, 10, , , , .T.) // "Desmarcar Todas"
					oBtn02 := SButton():New(aSize[1] + 285, aSize[2] + 340, 1, {|| lExc := .T., olDlg:End()}, , .T.)
					oBtn03 := SButton():New(aSize[1] + 285, aSize[2] + 370, 2, {|| lExc := .F., olDlg:End()}, , .T.)

					olMark := MsSelect():New("TMP1","OK",,apCampos,,@cpMarca,{aSize[1]+15,aSize[2]+10,aSize[1]+255,aSize[2]+390})
					olMark:oBrowse:lhasMark := .T.
					olMark:oBrowse:lCanAllmark := .F.

					ACTIVATE MSDIALOG olDlg CENTERED
				Else
					lExc := .F.
					Aviso(STR0011, STR0014 + STR0015, {STR0021})	// "Certificados de Retenção"###
					// "O certificado de retenção informado não foi encontrado na base de dados."###
					// "Informe um número de certificado existente ou selecione 'Impressão' para gerar um novo certificado"
					// "Ok"
				EndIf

				If lExc
					lExc := .F.
					dbSelectArea("TMP1")
					TMP1->(dbGoTop())
					While TMP1->(!EOF())
						If !Empty(TMP1->OK)
							dbSelectArea("SFE")
							SFE->(dbGoTop())
							If nTipOpe == 1
								cIndice := 'xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE+SFE->FE_TIPO'
								cChave := xFilial("SFE")+TMP1->FE_FORNECE+TMP1->FE_LOJA+TMP1->FE_NFISCAL+TMP1->FE_SERIE+TMP1->FE_TIPO
								SFE->(dbSetOrder(4))//FE_FILIAL+FE_FORNECE+FE_LOJA+FE_NFISCAL+FE_SERIE+FE_TIPO
								SFE->(dbSeek(cChave))
							Else
								cIndice := 'xFilial("SFE")+SFE->FE_CLIENTE+SFE->FE_LOJCLI+SFE->FE_NFISCAL+SFE->FE_SERIE'
								cChave := xFilial("SFE")+TMP1->FE_CLIENTE+TMP1->FE_LOJCLI+TMP1->FE_NFISCAL+TMP1->FE_SERIE
								SFE->(dbSetOrder(8))//FE_FILIAL+FE_CLIENTE+FE_LOJCLI+FE_NFISCAL+FE_SERIE
								SFE->(dbSeek(cChave))
							EndIf

							While cChave == &(cIndice)
								If SubStr(Dtos(SFE->FE_EMISSAO),1,6) == SubStr(Dtos(dDataBase),1,6)
									If lAviso1
										nlOpc:= Aviso(STR0011,STR0016+STR0017,{STR0019,STR0020})	// "Certificados de Retenção"###
										// "Através desta Opção, a numeração será excluída e os documentos com retenção ficarão disponíveis para a emissão de um novo certificado"
										// " Confirma a exclusão do certificado selecionado?"
										// "Sim"###"Não"
										lAviso1 := .F.
									EndIf
								ElseIf SubStr(Dtos(SFE->FE_EMISSAO),1,6)<>SubStr(Dtos(dDataBase),1,6) 	
									If lAviso2
										nlOpc:= Aviso(STR0011,STR0040+STR0041,{STR0019,STR0020})	// "Certificados de Retenção"###
										// "O Certificado a ser excluido esta dentro de outro periodo fiscal e podera ja ter sido entregue ao fornecedor, ou ja ter sido considerado na apuracao do seu mes de emissao."
										// "Mesmo assim confirma a exclusão do certificado selecionado?"
										// "Sim"###"Não"
										lAviso2 := .F.
									EndIf
								EndIf	
								If nlOpc == 1
									If nTipOpe == 1 //1-Entrada|2-Saida
										If !(cPaisLoc == "VEN" .And. SFE->FE_ESPECIE == "NCP") 
											dbSelectArea("SE2")
											SE2->(dbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
											//Bruno Cremaschi - Projeto chave única.
											cSDoc := SerieNFID("SFE", 3, "FE_SERIE")
											If SE2->(dbSeek(xFilial("SE2")+AvKey(SFE->&cSDoc,"E2_PREFIXO")+AvKey(SFE->FE_NFISCAL,"E2_NUM")))

												alDelTits := {}
												// Verifica se algum título já está baixado
												//Bruno Cremaschi - Projeto chave única.
												Do While SE2->(!EOF()) .And. (SE2->E2_FILIAL == xFilial("SE2") .And. SE2->E2_PREFIXO == SFE->&cSDoc .And. SE2->E2_NUM == SFE->FE_NFISCAL)
													If SE2->E2_FORNECE == SFE->FE_FORNECE .And. SE2->E2_LOJA == SFE->FE_LOJA
														If SE2->E2_TIPO == IIf(Alltrim(SFE->FE_TIPO)=="I","IV-","IR-")
															If Empty(SE2->E2_BAIXA)
																aAdd(alDelTits,{SE2->E2_FORNECE;
																,SE2->E2_LOJA;
																,SE2->E2_PREFIXO;
																,SE2->E2_NUM;
																,SE2->E2_PARCELA;
																,SE2->E2_TIPO})
																lExc := .T.
															Else
																alDelTits := {}
																lExc := .F.
																Exit
															EndIf
														Else
															If cPaisLoc == "EQU"
																lExc := .T.
															EndIf
														EndIf
													EndIf
													SE2->(dbSkip())
												EndDo
												
												If cPaisLoc == "EQU"											
													If cBajaSRI <> "N" .And. (cProvFE == "STUPENDO")
														If !Empty(SFE->FE_STATUS)
															nPosCR := aScan( aStaCR , {|x| x[1] == SFE->FE_NROCERT} )
															If nPosCR == 0 
																Processa( {|| cEstRet := F015STCREQ(SFE->FE_NROCERT) }, STR0056 + Alltrim(SFE->FE_NROCERT), ,) //"Consultando estatus de Ceritificado de Retención con STUPENDO.."
																aAdd(aStaCR, {SFE->FE_NROCERT,SFE->FE_TIPO,cEstRet})
															Else
																cEstRet := aStaCR[nPosCR][3]
															EndIf
															
															If cEstRet <> "6"
																nPosCR := aScan( aCRProc , {|x| x[1] == SFE->FE_NROCERT} )
																If nPosCR == 0 
																	aAdd(aCRProc, {SFE->FE_NROCERT})
																EndIf										
																lExc   := .F.
																lCRTra := .F.															
															EndIf
														Else	
															lCRTra := .T.
														EndIf
													Else
														If !(Empty(SFE->FE_STATUS) .Or. SFE->FE_STATUS $ "0|3|5") //0-Errado e-billing 3-Recibido 5-Autorizado
															nPosCR := aScan( aCRAnul , {|x| x[1] == SFE->FE_NROCERT} )
															If nPosCR == 0

																cMsgAviso := StrTran(STR0060,"###",Alltrim(SFE->FE_NROCERT)) + cCtrl + STR0061 //"acción. ¿Desea continuar con el borrado?"
																If MsgYesNo(cMsgAviso,STR0011) //"Asegúrese de haber dado de baja el Certificado de Retención ### ""en el portal del SRI, antes de ejecutar esta acción. ¿Desea continuar con el borrado?" //"Certificados de Retencion"										
																	lExc   := .T.
																	lCRTra := .T.
																Else
																	aAdd(aCRAnul, {SFE->FE_NROCERT,.F.})
																	lExc   := .F.
																	lCRTra := .F.																	
																EndIF
															Else
																lExc   := aCRAnul[nPosCR][2]
																lCRTra := aCRAnul[nPosCR][2]
															EndIf
														Else
															lCRTra := .T.
														EndIf
													EndIf												
												EndIf
												
												If !lExc .And. lCRTra
													Aviso(STR0011,STR0042,{STR0021})	// "Certificados de Retenção"###"O Certificado selecionado nao podera ser excluido visto que o titulo de abatimento a que se refere, ja se encontra baixado pelo modulo financeiro?"
												Else
													//Deleta os títulos
													For nlI:=1 To Len(alDelTits)
														dbSelectArea("SE2")
														SE2->(dbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
														If SE2->(dbSeek(xFilial("SE2")+alDelTits[nlI,1]+alDelTits[nlI,2]+alDelTits[nlI,3]+;
														alDelTits[nlI,4]+alDelTits[nlI,5]+alDelTits[nlI,6]))
															RecLock("SE2",.F.)                                                       
															DbDelete()
															SE2->(MsUnLock())
														EndIf
													Next nlI
												EndIf
												SE2->(dbCloseArea())
											EndIf
										Else
											lExc := .T.
										EndIf
									Else
										dbSelectArea("SE1")
										//Bruno Cremaschi - Projeto chave única.
										cSDoc := SerieNFID("SFE", 3, "FE_SERIE")
										SE1->(dbSetOrder(2))//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
										If SE1->(dbSeek(xFilial("SE1")+AvKey(SFE->FE_CLIENTE,"E1_CLIENTE")+AvKey(SFE->FE_LOJCLI,"E1_LOJA")+;
										AvKey(SFE->&cSDoc,"E1_PREFIXO")+AvKey(SFE->FE_NFISCAL,"E1_NUM")))

											alDelTits := {}
											// Verifica se algum título já está baixado
											Do While SE1->(!EOF()) .Or. (SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_CLIENTE == SFE->FE_CLIENTE .And.;
											SE1->E1_LOJA == SFE->FE_LOJCLI .And. SE1->E1_PREFIXO == SFE->&cSDoc .And. SE1->E1_NUM == SFE->FE_NFISCAL)

												If SE1->E1_TIPO == IIf(Alltrim(SFE->FE_TIPO)=="I","IV-","IR-")
													If Empty(SE1->E1_BAIXA)
														aAdd(alDelTits,{SE1->E1_CLIENTE;
														,SE1->E1_LOJA;
														,SE1->E1_PREFIXO;
														,SE1->E1_NUM;
														,SE1->E1_PARCELA;
														,SE1->E1_TIPO})
														lExc := .T.
													Else
														alDelTits := {}
														lExc := .F.
														Exit
													EndIf
												EndIf
												SE1->(dbSkip())
											EndDo
											If !lExc
												Aviso(STR0011,STR0042,{STR0021})	// "Certificados de Retenção"###"O Certificado selecionado nao podera ser excluido visto que o titulo de abatimento a que se refere, ja se encontra baixado pelo modulo financeiro?"
											Else
												//Deleta os títulos
												For nlI:=1 To Len(alDelTits)
													dbSelectArea("SE1")
													SE1->(dbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
													If SE1->(dbSeek(xFilial("SE1")+alDelTits[nlI,1]+alDelTits[nlI,2]+alDelTits[nlI,3]+;
													alDelTits[nlI,4]+alDelTits[nlI,5]+alDelTits[nlI,6]))
														RecLock("SE1",.F.)                                                       
														DbDelete()
														SE1->(MsUnLock())
													EndIf
												Next nlI
											EndIf
											SE1->(dbCloseArea())
										EndIf
									EndIf    
									If lExc .And. lCRTra
										RecLock("SFE",.F.)
										dbDelete()
										SFE->(MsUnLock())										
										nPosCR := aScan( aCRBorra , {|x| x[1] == SFE->FE_NROCERT} )
										If nPosCR == 0 										
											aAdd(aCRBorra, {SFE->FE_NROCERT})
										EndIf
									EndIf
								EndIf
								SFE->(dbSkip())
							End
						EndIf
						TMP1->(dbSkip())
					End
					If lExc
						If cPaisLoc == "EQU"
							cCRMsg := F015GenMsg(aCRBorra,aCRProc,aCRAnul)
							If !Empty(cCRMsg)
								F015MsgObs(cCRMsg)
							EndIf	
						Else
						Aviso(STR0011,STR0018,{STR0021})	// "Certificados de Retenção"###
						// "Exclusão realizada com sucesso."###
						// "Ok"
						EndIf
					Else
						If cPaisLoc == "EQU"
							cCRMsg := F015GenMsg(aCRBorra,aCRProc,aCRAnul)
							If !Empty(cCRMsg)
								F015MsgObs(cCRMsg)
							EndIf	
						EndIf
					EndIf
				EndIf
				If oTmpTable2 <> Nil 
					oTmpTable2:Delete()
					oTmpTable2 := Nil
				EndIf

			Else // Se não for Equador

				If MV_PAR01 == 1 .And. cPaisLoc == "COL"    
					cTipoC := 'I'
				ElseIf MV_PAR01 == 2 .And. cPaisLoc == "COL"    
					cTipoC := 'C'	
				ElseIf MV_PAR01 == 3 .And. cPaisLoc == "COL"
					cTipoC := 'F'	
				EndIf
				dbSelectArea("TMP")
				TMP->(DbGoTop())
				If TMP->(!EOF())
					WHILE TMP->(!EOF())
						DbSelectArea("SFE")

						If cPaisLoc == 'COL' 
							SFE->(DbSetOrder(9))//FE_FILIAL+FE_NROCERT+FE_TIPO
							lSeek := DbSeek(xFilial("SFE")+AvKey(TMP->FE_NROCERT,"FE_NROCERT")+cTipoC)
							If lSeek
								lExc := .F.
								// " Confirma a exclusão do certificado selecionado?"
								nlOpc:= Aviso(STR0011,STR0016+STR0017,{STR0019,STR0020})	// "Certificados de Retenção"###
								Do While SFE->(!Eof()) .And. SFE->FE_NROCERT==TMP->FE_NROCERT .And. SFE->FE_TIPO == cTipoC 
									// "Através desta Opção, a numeração será excluída e os documentos com retenção ficarão disponíveis para a emissão de um novo certificado"
									// "Sim"###"Não"
									If nlOpc == 1
										lExc := .T.
										RecLock("SFE",.F.)
										dbDelete()
										MsUnLock()
									EndIf
									SFE->(DbSkip())
								EndDo
							EndIf
						Else
							SFE->(DbSetOrder(1))//FE_FILIAL+FE_NROCERT
							lSeek := DbSeek(xFilial("SFE")+AvKey(TMP->FE_NROCERT,"FE_NROCERT"))
							If lSeek
								lExc := .F.
								// " Confirma a exclusão do certificado selecionado?"
								nlOpc:= Aviso(STR0011,STR0016+STR0017,{STR0019,STR0020})	// "Certificados de Retenção"###
								Do While SFE->(!Eof()) .And. SFE->FE_NROCERT==TMP->FE_NROCERT
									// "Através desta Opção, a numeração será excluída e os documentos com retenção ficarão disponíveis para a emissão de um novo certificado"
									// "Sim"###"Não"
									If nlOpc == 1
										lExc := .T.
										RecLock("SFE",.F.)
										dbDelete()
										MsUnLock()
									EndIf
									SFE->(DbSkip())
								EndDo
							EndIf
						EndIf
						TMP->(dbSkip())
					EndDo 

					If lExc
						Aviso(STR0011,STR0018,{STR0021})	// "Certificados de Retenção"###
						// "Exclusão realizada com sucesso."###
						// "Ok"
					EndIf
				Else
					Aviso(STR0011, STR0014 + STR0015, {STR0021})	// "Certificados de Retenção"###
					// "O certificado de retenção informado não foi encontrado na base de dados."###
					// "Informe um número de certificado existente ou selecione 'Impressão' para gerar um novo certificado"
					// "Ok"
				EndIf
			EndIf
		EndIf
	EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FMarca   ³ Autor ³ Hermes Ferreira       ³ Data ³16/12/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca ou Desmarca todas as opções existentes no Browse     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FMarca                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ llMarc - Variavel logica, recebe o TRUE ao clicar no Marc, ³±±
±±³          ³ e FALSE ao desmarcar.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Marca/Desmarca Todos			                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FMarca(llMarc)

	dbSelectArea("TMP1")
	TMP1->(dbGoTop())

	If llMarc
		While TMP1->(!Eof()) 
			RecLock("TMP1",.F.)
			Replace TMP1->OK With cpMarca
			TMP1->(MsUnLock())
			TMP1->(dbSkip())
		EndDo
	Else
		While TMP1->(!Eof())
			RecLock("TMP1",.F.)
			Replace TMP1->OK With Space(2)
			TMP1->(MsUnLock())
			TMP1->(dbSkip())
		EndDo
	EndIf

	TMP1->(dbGoTop())
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FGrvCrt  ³ Autor ³ Hermes Ferreira       ³ Data ³16/12/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os titulos selecionados na tabela SFE, e chama os    ³±±
±±³          ³ Fontes reponsaveis por cada tipo de imposto para imprimir  ³±±
±±³          ³ a certificação de retenção                                 ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Grava SFE e Imprimi os Certificados de Retençao            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGrvCrt(nTipOpe, aGerSfe)

	Local clForn	:= ""
	Local clLoja	:= ""
	Local clImp		:= ""
	Local clDescX5	:= ""
	Local cMsgCert	:= ""
	Local cChvCert	:= ""
	Local cChvNota	:= ""
	Local cParcSE1	:=""
	Local nX		:= 0
	Local nCont		:= 0
	Local nVlrRent	:= 0 
	Local nPosNota	:= 0
	Local lIVA		:= .F.
	Local lRIR		:= .F.
	Local llImpri	:= .F.
	Local aGerSD1	:= {}
	Local aGerRet	:= {} 
	Local aImpRIR	:= {}
	Local aImpIVA	:= {}
	Local aVlrCP	:= {}
	Local alCertRet	:= {}  
	Local nI		:= 1     
	Local cNaturez	:= ""
	Local cTipoTit	:= ""
	Local lNumCert	:= .F.
	Local lNewCert	:= SuperGetMV("MV_CERTUNI",.F.,.F.)
	Local cImp		:= ''
	Local cLvroRetC := SuperGetMV("MV_LVRORIC",,"") //Número de libro para ret. de IVA al 0% (Ecuador)
	Local lOk		:= .F.
	Local lFchEmi	:= (cPaisLoc$"EQU" .And. FunName()$"MATA101N" .And. !IsBlind())
	Local lGenNumCer	:= .F.

	Default aGerSfe	:= {}

	If cPaisLoc $ "EQU|VEN"         
		If Len(aGerSfe) == 0      
			If Select("TMP1") > 0
				aImpIVA:={}
				aImpRIR:={}	
				cChvNota:="" 		
				llImpri := .T.
				DbSelectArea("TMP1")
				TMP1->(DbGoTop())              
				Do While TMP1->(!Eof())        
					If !Empty(TMP1->OK)                                     
						//1-Entrada|2-Saida
						If nTipOpe == 1
							If cChvNota <> TMP1->D1_DOC+TMP1->D1_SERIE+TMP1->D1_CLIFOR+TMP1->D1_LOJA
								aImpIVA := {}
								aImpRIR := {}	         
								cChvNota:=TMP1->D1_DOC+TMP1->D1_SERIE+TMP1->D1_CLIFOR+TMP1->D1_LOJA
								If nTipImp == 1 
									If (TMP1->D1_BASIMP2 + TMP1->D1_BASIMP3 + TMP1->D1_BASIMP4 + IIf(!Empty(cLvroRetC) .And. !(AllTrim(cLvroRetC) $ "2|3|4"), TMP1->&("D1_BASIMP" + Alltrim(cLvroRetC)), 0)) > 0
										aImpIVA := GerNumCert("IVA",1)
									EndIf
								EndIf	
								If nTipImp == 2 
									If TMP1->D1_VALIMP6>0
										aImpRIR := GerNumCert("RIR",1)
									EndIf
								EndIf
								If nTipImp == 3 
									If cPaisLoc == "EQU"
										aImpRIR := GerNumCert("CER",1)
									Else
										aImpRIR := GerNumCert("RIR",1)
									EndIf
									aImpIVA := aImpRIR
								EndIf
							EndIf	                
						Else
							If cChvNota <> TMP1->D2_DOC + TMP1->D2_SERIE + TMP1->D2_CLIFOR + TMP1->D2_LOJA
								aImpIVA		:= {}
								aImpRIR		:= {}	
								cChvNota	:= TMP1->D2_DOC + TMP1->D2_SERIE + TMP1->D2_CLIFOR + TMP1->D2_LOJA
								If nTipImp == 1							
									If (TMP1->D2_VALIMP2 + TMP1->D2_VALIMP3 + TMP1->D2_VALIMP4) > 0
										aImpIVA := GerNumCert("IVA", 2)
									EndIf   
								EndIf
								If nTipImp == 2 								
									If TMP1->D2_VALIMP6>0
										aImpRIR := GerNumCert("RIR", 2)
									EndIf
								EndIf           
								If nTipImp == 3
									If cPaisLoc == "EQU"
										aImpRIR := GerNumCert("CER", 2)
									Else
										aImpRIR := GerNumCert("RIR", 2)
									EndIf
									aImpIVA := aImpRIR
								EndIf
							EndIf						
						EndIf
						//1-Entrada|2-Saida
						If nTipOpe == 1
							//SD1-IVA RETENCAO
							If Len(aImpIVA) > 0
								//aImpRet[1]-Numero Certificado
								//aImpRet[1]-Numero Autorizacao           
								If TMP1->D1_VALIMP2 > 0 .Or. (cPaisLoc == "EQU" .And. TMP1->D1_BASIMP2 > 0)                           
									aAdd(aGerRet,{aImpIVA[1],aImpIVA[2],TMP1->D1_DOC,TMP1->D1_SERIE,TMP1->D1_CLIFOR,TMP1->D1_LOJA,"RV0",;
									TMP1->D1_CONCEPT,TMP1->D1_ALQIMP2,TMP1->D1_BASIMP2,TMP1->D1_VALIMP1,TMP1->D1_VALIMP2,TMP1->D1_ESPECIE,TMP1->D1_TES})
								EndIf	
								If TMP1->D1_VALIMP3 > 0 .Or. (cPaisLoc == "EQU" .And. TMP1->D1_BASIMP3 > 0)
									aAdd(aGerRet,{aImpIVA[1],aImpIVA[2],TMP1->D1_DOC,TMP1->D1_SERIE,TMP1->D1_CLIFOR,TMP1->D1_LOJA,"RV1",;
									TMP1->D1_CONCEPT,TMP1->D1_ALQIMP3,TMP1->D1_BASIMP3,TMP1->D1_VALIMP1,TMP1->D1_VALIMP3,TMP1->D1_ESPECIE,TMP1->D1_TES})
								EndIf	
								If TMP1->D1_VALIMP4 > 0 .Or. (cPaisLoc == "EQU" .And. TMP1->D1_BASIMP4 > 0)
									aAdd(aGerRet,{aImpIVA[1],aImpIVA[2],TMP1->D1_DOC,TMP1->D1_SERIE,TMP1->D1_CLIFOR,TMP1->D1_LOJA,"RV0",;
									TMP1->D1_CONCEPT,TMP1->D1_ALQIMP4,TMP1->D1_BASIMP4,TMP1->D1_VALIMP1,TMP1->D1_VALIMP4,TMP1->D1_ESPECIE,TMP1->D1_TES})
								EndIf 
								
								If cPaisLoc == "EQU" .And. !Empty(cLvroRetC) .And. !(AllTrim(cLvroRetC) $ "2|3|4")
									If TMP1->&("D1_BASIMP" + Alltrim(cLvroRetC)) > 0                           
										aAdd(aGerRet,{aImpIVA[1],aImpIVA[2],TMP1->D1_DOC,TMP1->D1_SERIE,TMP1->D1_CLIFOR,TMP1->D1_LOJA,"RV0",;
										TMP1->D1_CONCEPT,TMP1->&("D1_ALQIMP" + Alltrim(cLvroRetC)),TMP1->&("D1_BASIMP" + Alltrim(cLvroRetC)),TMP1->D1_VALIMP1,TMP1->&("D1_VALIMP" + Alltrim(cLvroRetC)),TMP1->D1_ESPECIE,TMP1->D1_TES})
									EndIf
								EndIf
								//Entrada - Gera titulo Abatimento IR(temporario)
								nPosNota := aScan(aVlrCP,{|x| x[1]+x[2]+x[3]+x[4]+x[6]+x[7] == TMP1->D1_DOC+TMP1->D1_SERIE+TMP1->D1_CLIFOR+TMP1->D1_LOJA+"I",TMP1->D1_ESPECIE})
								If nPosNota == 0
									aAdd(aVlrCP,{TMP1->D1_DOC,TMP1->D1_SERIE,TMP1->D1_CLIFOR,TMP1->D1_LOJA,TMP1->D1_VALIMP2+TMP1->D1_VALIMP3+TMP1->D1_VALIMP4,"I",TMP1->D1_ESPECIE})
								Else
									aVlrCp[nPosNota][5] += TMP1->D1_VALIMP2+TMP1->D1_VALIMP3+TMP1->D1_VALIMP4
								EndIf
							EndIf	                      
							//SD1-RIR RETENCAO
							If Len(aImpRIR) > 0
								If (TMP1->D1_VALIMP6 >= 0 .And. cPaisLoc == "EQU") .Or. (TMP1->D1_VALIMP6 > 0)
									//aImpRet[1]-Numero Certificado
									//aImpRet[1]-Numero Autorizacao
									aAdd(aGerRet,{aImpRIR[1],aImpRIR[2],TMP1->D1_DOC,TMP1->D1_SERIE,TMP1->D1_CLIFOR,TMP1->D1_LOJA,"RIR",;
									TMP1->D1_CONCEPT,TMP1->D1_ALQIMP6,TMP1->D1_BASIMP6,TMP1->D1_VALIMP6,TMP1->D1_VALIMP6,TMP1->D1_ESPECIE,TMP1->D1_TES})
								EndIf
								//Entrada - Gera titulo Abatimento IR(temporario)
								nPosNota := aScan(aVlrCP,{|x| x[1]+x[2]+x[3]+x[4]+x[6]+x[7] == TMP1->D1_DOC+TMP1->D1_SERIE+TMP1->D1_CLIFOR+TMP1->D1_LOJA+"R"+TMP1->D1_ESPECIE})
								If nPosNota == 0
									aAdd(aVlrCP,{TMP1->D1_DOC,TMP1->D1_SERIE,TMP1->D1_CLIFOR,TMP1->D1_LOJA,TMP1->D1_VALIMP6,"R",TMP1->D1_ESPECIE})
								Else
									aVlrCp[nPosNota][5] += TMP1->D1_VALIMP6
								EndIf
							EndIf
						Else    
							nVlrRent := 0
							//SD2-IVA RETENCAO
							If Len(aImpIVA) > 0
								//aImpRet[1]-Numero Certificado
								//aImpRet[1]-Numero Autorizacao
								If TMP1->D2_VALIMP2 > 0                           
									aAdd(aGerRet,{aImpIVA[1],aImpIVA[2],TMP1->D2_DOC,TMP1->D2_SERIE,TMP1->D2_CLIFOR,TMP1->D2_LOJA,"RV0",;
									TMP1->D2_CONCEPT,TMP1->D2_ALQIMP2,TMP1->D2_BASIMP2,TMP1->D2_VALIMP1,TMP1->D2_VALIMP2,TMP1->D2_ESPECIE,TMP1->D2_TES})
									nVlrRent += TMP1->D2_VALIMP2
								EndIf	
								If TMP1->D2_VALIMP3 > 0
									aAdd(aGerRet,{aImpIVA[1],aImpIVA[2],TMP1->D2_DOC,TMP1->D2_SERIE,TMP1->D2_CLIFOR,TMP1->D2_LOJA,"RV1",;
									TMP1->D2_CONCEPT,TMP1->D2_ALQIMP3,TMP1->D2_BASIMP3,TMP1->D2_VALIMP1,TMP1->D2_VALIMP3,TMP1->D2_ESPECIE,TMP1->D2_TES})
									nVlrRent += TMP1->D2_VALIMP3
								EndIf	
								If TMP1->D2_VALIMP4 > 0
									aAdd(aGerRet,{aImpIVA[1],aImpIVA[2],TMP1->D2_DOC,TMP1->D2_SERIE,TMP1->D2_CLIFOR,TMP1->D2_LOJA,"RV0",;
									TMP1->D2_CONCEPT,TMP1->D2_ALQIMP4,TMP1->D2_BASIMP4,TMP1->D2_VALIMP1,TMP1->D2_VALIMP4,TMP1->D2_ESPECIE,TMP1->D2_TES})
									nVlrRent += TMP1->D2_VALIMP4
								EndIf 
								cDescHist := aImpIVA[1]
								//Saida - Gera titulo Abatimento IVA
								If (TMP1->D2_VALIMP2+TMP1->D2_VALIMP3+TMP1->D2_VALIMP4) > 0
									nPosNota := aScan(aVlrCP,{|x| x[1]+x[2]+x[3]+x[4]+x[6]+x[7] == TMP1->D2_DOC+TMP1->D2_SERIE+TMP1->D2_CLIFOR+TMP1->D2_LOJA+"I"+TMP1->D2_ESPECIE})
									If nPosNota == 0
										aAdd(aVlrCP,{TMP1->D2_DOC,TMP1->D2_SERIE,TMP1->D2_CLIFOR,TMP1->D2_LOJA,TMP1->D2_VALIMP2+TMP1->D2_VALIMP3+TMP1->D2_VALIMP4,"I",TMP1->D2_ESPECIE})
									Else
										aVlrCp[nPosNota][5] += (TMP1->D2_VALIMP2+TMP1->D2_VALIMP3+TMP1->D2_VALIMP4)
									EndIf
								EndIf
							EndIf	
							//SD2-RIR RETENCAO        
							If Len(aImpRIR) > 0
								If TMP1->D2_VALIMP6 > 0
									//aImpRet[1]-Numero Certificado
									//aImpRet[1]-Numero Autorizacao
									aAdd(aGerRet,{aImpRIR[1],aImpRIR[2],TMP1->D2_DOC,TMP1->D2_SERIE,TMP1->D2_CLIFOR,TMP1->D2_LOJA,"RIR",;
									TMP1->D2_CONCEPT,TMP1->D2_ALQIMP6,TMP1->D2_BASIMP6,TMP1->D2_VALIMP1,TMP1->D2_VALIMP6,TMP1->D2_ESPECIE,TMP1->D2_TES})
									nVlrRent += TMP1->D2_VALIMP6
									cDescHist := aImpRIR[1]

									//Saida - Gera titulo Abatimento IR
									nPosNota := aScan(aVlrCP,{|x| x[1]+x[2]+x[3]+x[4]+x[6]+x[2] == TMP1->D2_DOC+TMP1->D2_SERIE+TMP1->D2_CLIFOR+TMP1->D2_LOJA+"R"+TMP1->D2_ESPECIE})
									If nPosNota == 0
										aAdd(aVlrCP,{TMP1->D2_DOC,TMP1->D2_SERIE,TMP1->D2_CLIFOR,TMP1->D2_LOJA,TMP1->D2_VALIMP6,"R",TMP1->D2_ESPECIE})
									Else
										aVlrCp[nPosNota][5] += TMP1->D2_VALIMP6
									EndIf
								EndIf
							EndIf
						EndIf	    
					EndIf    
					TMP1->(DbSkip())
				End
			EndIf
		Else     
			//Documento de Entrada
			//aGerSfe[01][01]- .T.-Inclusao|.F.-Exclusao
			//aGerSfe[01][02]- Codigo do Fornecedor
			//aGerSfe[01][03]- Loja
			//aGerSfe[01][04]- Numero da fatura
			//aGerSfe[01][05]- Serie
			//aGerSfe[01][06]- Valor Imposto IVA
			//aGerSfe[01][07]- Valor Imposto IR
			aGerRet := {}		                              
			If aGerSfe[1][1]
				DbSelectArea("SFE")                                               
				SFE->(DbSetOrder(4))//FE_FILIAL+FE_FORNECE+FE_LOJA+FE_NFISCAL+FE_SERIE
				If SFE->(DbSeek(xFilial("SFE")+Avkey(aGerSfe[nCont][2],"FE_FORNECE")+Avkey(aGerSfe[nCont][3],"FE_LOJA")+;
				Avkey(aGerSfe[nCont][4],"FE_NFISCAL")+Avkey(aGerSfe[nCont][5],"FE_SERIE")))
					Do While SFE->(!Eof()) .And. SFE->FE_FORNECE == aGerSfe[nCont][2] .And. SFE->FE_LOJA == aGerSfe[nCont][3] ;
					.And. SFE->FE_NFISCAL == aGerSfe[nCont][4] .And. SFE->FE_SERIE == aGerSfe[nCont][5] 
						RecLock("SFE",.F.) 
						Dbdelete()
						SFE->(MsUnLock())
						SFE->(DbSkip())
					End
				EndIf
			Else                      
				If SuperGetMv("MV_IMPCP",.F.,.F.)
					llImpri := .T.
				EndIf
				lIVA	:= .F.
				lRIR	:= .F.
				aGerSD1	:= {}
				aImpIVA	:= {}
				aImpRIR	:= {}			
				If cPaisLoc <> "VEN" .Or. (cPaisLoc == "VEN" .And. nTipOpe == 1 )
					DbSelectArea("SD1")
					SD1->(DbSetOrder(1))//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA
					SD1->(DbGoTop())
					If DbSeek(xFilial("SD1")+AvKey(aGerSfe[1][4],"D1_DOC")+AvKey(aGerSfe[1][5],"D1_SERIE")+AvKey(aGerSfe[1][2],"D1_FORNECE")+AvKey(aGerSfe[1][3],"D1_LOJA"))
						lNumCert:=.F.
						Do While SD1->(!Eof()) .And. Alltrim(SD1->D1_DOC) == Alltrim(aGerSfe[1][4]) .And. Alltrim(SD1->D1_SERIE) == Alltrim(aGerSfe[1][5]) ;
						.And. Alltrim(SD1->D1_FORNECE) == Alltrim(aGerSfe[1][2]) .And. Alltrim(SD1->D1_LOJA) == Alltrim(aGerSfe[1][3])
							nPosImp := 0
							//IVA RETENCAO
							If SD1->D1_VALIMP2 > 0 .Or. (cPaisLoc == "EQU" .And. SD1->D1_BASIMP2 > 0)
								lIVA := .T.
								nPosImp := aScan(aGerSD1,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6] == SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_ESPECIE+SD1->D1_TES+SD1->D1_CONCEPT+"RV0"})
								If nPosImp == 0
									aAdd(aGerSD1,{SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_ESPECIE,SD1->D1_TES,SD1->D1_CONCEPT,"RV0",;
									SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_ESPECIE,SD1->D1_BASIMP2,SD1->D1_ALQIMP2,SD1->D1_VALIMP2,SD1->D1_VALIMP1,SD1->D1_TES})
								Else
									aGerSD1[nPosImp][10] += SD1->D1_BASIMP2
									aGerSD1[nPosImp][12] += SD1->D1_VALIMP2
									aGerSD1[nPosImp][13] += SD1->D1_VALIMP1
								EndIf	
							EndIf
							
							If SD1->D1_VALIMP3 > 0 .Or. (cPaisLoc == "EQU" .And. SD1->D1_BASIMP3 > 0)
							   cImp:="RV1"
							    if cPaisLoc=="VEN" .AND. ImpBAR(SD1->D1_TES)//Impuesto Barcelona
							       cImp:="BAR"
							    endif
								lIVA := .T.					
								nPosImp := aScan(aGerSD1,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6] == SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_ESPECIE+SD1->D1_TES+SD1->D1_CONCEPT+cimp})
								If nPosImp == 0
									aAdd(aGerSD1,{SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_ESPECIE,SD1->D1_TES,SD1->D1_CONCEPT,cimp,;
									SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_ESPECIE,SD1->D1_BASIMP3,SD1->D1_ALQIMP3,SD1->D1_VALIMP3,SD1->D1_VALIMP1,SD1->D1_TES})
								Else
									aGerSD1[nPosImp][10] += SD1->D1_BASIMP3
									aGerSD1[nPosImp][12] += SD1->D1_VALIMP3
									aGerSD1[nPosImp][13] += SD1->D1_VALIMP1
								EndIf
							EndIf
							
							If SD1->D1_VALIMP4 > 0 .Or. (cPaisLoc == "EQU" .And. SD1->D1_BASIMP4 > 0)
								lIVA := .T.					
								nPosImp := aScan(aGerSD1,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6] == SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_ESPECIE+SD1->D1_TES+SD1->D1_CONCEPT+"RV2"})
								If nPosImp == 0
									aAdd(aGerSD1,{SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_ESPECIE,SD1->D1_TES,SD1->D1_CONCEPT,"RV2",;
									SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_ESPECIE,SD1->D1_BASIMP4,SD1->D1_ALQIMP4,SD1->D1_VALIMP4,SD1->D1_VALIMP1,SD1->D1_TES})
								Else
									aGerSD1[nPosImp][10] += SD1->D1_BASIMP4
									aGerSD1[nPosImp][12] += SD1->D1_VALIMP4
									aGerSD1[nPosImp][13] += SD1->D1_VALIMP1
								EndIf	
							EndIf  
							
							If !Empty(cLvroRetC) .And. !(AllTrim(cLvroRetC) $ "2|3|4") //Retención IVA al 0% (para núm . de libro diferente de 2,3 o 4)
									If SD1->&("D1_BASIMP" + Alltrim(cLvroRetC)) > 0
										lIVA := .T.					
										nPosImp := aScan(aGerSD1,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6] == SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_ESPECIE+SD1->D1_TES+SD1->D1_CONCEPT+"RV4"})
										If nPosImp == 0
											aAdd(aGerSD1,{SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_ESPECIE,SD1->D1_TES,SD1->D1_CONCEPT,"RV4",; 
											SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_ESPECIE,SD1->&("D1_BASIMP" + Alltrim(cLvroRetC)),SD1->&("D1_ALQIMP" + Alltrim(cLvroRetC)),SD1->&("D1_VALIMP" + Alltrim(cLvroRetC)),SD1->D1_VALIMP1,SD1->D1_TES})
										Else
											aGerSD1[nPosImp][10] += SD1->&("D1_BASIMP" + Alltrim(cLvroRetC))
											aGerSD1[nPosImp][12] += SD1->&("D1_VALIMP" + Alltrim(cLvroRetC))
											aGerSD1[nPosImp][13] += SD1->D1_VALIMP1
										EndIf	
									EndIf  
							EndIf 
							
							IF  cPaisLoc <> "VEN" //GSA            
								If (SD1->D1_VALIMP2+SD1->D1_VALIMP3+SD1->D1_VALIMP4)>0 
									//Entrada - Gera titulo Abatimento IR(temporario)
									nPosNota := aScan(aVlrCP,{|x| x[1]+x[2]+x[3]+x[4]+x[6]+x[7] == SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+"I"+SD1->D1_ESPECIE})
									If nPosNota == 0
										aAdd(aVlrCP,{SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_VALIMP2+SD1->D1_VALIMP3+SD1->D1_VALIMP4,"I",SD1->D1_ESPECIE})
									Else
										aVlrCp[nPosNota][5] += SD1->D1_VALIMP2+SD1->D1_VALIMP3+SD1->D1_VALIMP4
									EndIf
								EndIf
							ENDIF
							//RIR RETENCAO
							If (SD1->D1_VALIMP6 >= 0 .And. cPaisLoc == "EQU") .Or. (SD1->D1_VALIMP6 > 0)
								lRIR	:= .T.					
								nPosImp	:= aScan(aGerSD1,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6] == SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_ESPECIE+SD1->D1_TES+SD1->D1_CONCEPT+"RIR"})
								If nPosImp == 0
									If cPaisLoc == "VEN"
										dbSelectArea("SFF")
										SFF->(DBSetOrder(14)) //FF_FILIAL+FF_IMPOSTO+FF_REGIAO+FF_GRPPRD+
										If SFF->(DBSeek(xFilial("SFF") + "RIR" + SA2->A2_GRPTRIB + SD1->D1_CONCEPTO))
											aAdd(aGerSD1,{SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_ESPECIE,SD1->D1_TES,SFF->FF_CONCEPT,"RIR",;
											SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_ESPECIE,SD1->D1_BASIMP6,SFF->FF_ALIQ,SD1->D1_VALIMP6,SD1->D1_VALIMP6,SD1->D1_TES})
										EndIf
									Else
										DbSelectArea("CCR") 
										CCR->(DbSetOrder(1)) //CCR_FILIAL+CCR_CONCEP+CCR_PAIS
										CCR->(DbGoTop())
										If DbSeek(xFilial("CCR")+AvKey(SD1->D1_CONCEPT,"CCR_CONCEP"))
											aAdd(aGerSD1,{SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_ESPECIE,SD1->D1_TES,SD1->D1_CONCEPT,"RIR",;
											SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_ESPECIE,SD1->D1_BASIMP6,CCR->CCR_ALIQ,SD1->D1_VALIMP6,SD1->D1_VALIMP6,SD1->D1_TES})
										EndIf
									EndIf
								Else
									aGerSD1[nPosImp][10] += SD1->D1_BASIMP6
									aGerSD1[nPosImp][12] += SD1->D1_VALIMP6
									aGerSD1[nPosImp][13] += SD1->D1_VALIMP6
								EndIf	
								IF cPaisLoc <> "VEN" //GSA
									If SD1->D1_VALIMP6>0 .Or. (SD1->D1_VALIMP6 >= 0 .And. cPaisLoc == "EQU")
										//Entrada - Gera titulo Abatimento IR(temporario)
										nPosNota := aScan(aVlrCP,{|x| x[1]+x[2]+x[3]+x[4]+x[6] +x[7]== SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+"R"+SD1->D1_ESPECIE})
										If nPosNota == 0
											aAdd(aVlrCP,{SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_VALIMP6,"R",SD1->D1_ESPECIE})
										Else
											aVlrCp[nPosNota][5] += SD1->D1_VALIMP6
										EndIf
									EndIf
								ENDIF
							EndIf
							SD1->(DbSkip())                                   
						End
						If (cPaisLoc == "EQU" .And. !lNumCert .And. lNewCert) .And. (lIVA .Or. lRIR)
							lGenNumCer := Len(aGerSD1) > 0
							If lIVA .And. lGenNumCer
								aImpIVA := GerNumCert("CER",1)
								aImpRIR := aImpIVA
								If Len(aImpIVA) == 0
									lIVA := .F.
									lRIR := .F. 
								Else
									lNumCert := .T.	
								EndIf
							ElseIf lRIR .And. lGenNumCer
								aImpRIR := GerNumCert("CER",1)
								aImpIVA := aImpRIR
								If Len(aImpRIR) == 0
									lRIR := .F.
									lIVA := .F.
								Else
									lNumCert := .T.	
								EndIf
							EndIf
						Else
							If lIVA  .And. !lNumCert
								aImpIVA := GerNumCert("IVA",1)
								aImpRIR := aImpIVA
								If Len(aImpIVA) == 0
									lIVA := .F.
									lRIR := .F. 
								Else
									lNumCert := .T.	
								EndIf					
							EndIf
							If lRIR  .And. !lNumCert
								aImpRIR := GerNumCert("RIR",1)
								aImpIVA := aImpRIR
								If Len(aImpRIR) == 0
									lRIR := .F.
									lIVA := .F.
								Else
									lNumCert := .T.	
								EndIf
							EndIf 
						EndIf
						If lIVA .Or. lRIR	
							For nCont := 1 To Len(aGerSD1)
								If Alltrim(aGerSD1[nCont][6])=="RIR"   
									aAdd(aGerRet,{aImpRIR[1],aImpRIR[2],aGerSD1[nCont][1],aGerSD1[nCont][2],aGerSD1[nCont][7],aGerSD1[nCont][8],aGerSD1[nCont][6],;
									aGerSD1[nCont][5],aGerSD1[nCont][11],aGerSD1[nCont][10],aGerSD1[nCont][13],aGerSD1[nCont][12],aGerSD1[nCont][3],aGerSD1[nCont][14]})
								Else
									aAdd(aGerRet,{aImpIVA[1],aImpIVA[2],aGerSD1[nCont][1],aGerSD1[nCont][2],aGerSD1[nCont][7],aGerSD1[nCont][8],aGerSD1[nCont][6],;
									aGerSD1[nCont][5],aGerSD1[nCont][11],aGerSD1[nCont][10],aGerSD1[nCont][13],aGerSD1[nCont][12],aGerSD1[nCont][3],aGerSD1[nCont][14]})
								EndIf       
							Next		
						EndIf
					EndIf	

				ElseIf  cPaisLoc == "VEN" .And. nTipOpe == 2
					DbSelectArea("SD2")
					SD2->(DbSetOrder(3))//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA
					SD2->(DbGoTop())
					If DbSeek(xFilial("SD2")+AvKey(aGerSfe[1][4],"D2_DOC")+AvKey(aGerSfe[1][5],"D2_SERIE")+AvKey(aGerSfe[1][2],"D2_CLIENTE")+AvKey(aGerSfe[1][3],"D2_LOJA"))
						lNumCert := .F.
						Do While SD2->(!Eof()) .And. Alltrim(SD2->D2_DOC) == Alltrim(aGerSfe[1][4]) .And. Alltrim(SD2->D2_SERIE) == Alltrim(aGerSfe[1][5]) ;
						.And. Alltrim(SD2->D2_CLIENTE) == Alltrim(aGerSfe[1][2]) .And. Alltrim(SD2->D2_LOJA) == Alltrim(aGerSfe[1][3])
							nPosImp := 0
							//IVA RETENCAO
							If SD2->D2_VALIMP2 > 0
								lIVA := .T.
								nPosImp := aScan(aGerSD1,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6] == SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_ESPECIE+SD2->D2_TES+SD2->D2_CONCEPT+"RV0"})
								If nPosImp == 0
									aAdd(aGerSD1,{SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_ESPECIE,SD2->D2_TES,SD2->D2_CONCEPT,"RV0",;
									SD2->D2_CLIENTE,SD2->D2_LOJA,SD2->D2_ESPECIE,SD2->D2_BASIMP1,SD2->D2_ALQIMP2,SD2->D2_VALIMP2,SD2->D2_VALIMP2,SD2->D2_TES})
								Else
									aGerSD1[nPosImp][10] += SD2->D2_BASIMP2
									aGerSD1[nPosImp][12] += SD2->D2_VALIMP2
									aGerSD1[nPosImp][13] += SD2->D2_VALIMP1
								EndIf	
							EndIf
							If SD2->D2_VALIMP3 > 0
								lIVA := .T.					
								nPosImp := aScan(aGerSD1,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6] == SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_ESPECIE+SD2->D2_TES+""+"RV1"})
								If nPosImp == 0
									aAdd(aGerSD1,{SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_ESPECIE,SD2->D2_TES,"","RV1",;
									SD2->D2_CLIENTE,SD2->D2_LOJA,SD2->D2_ESPECIE,SD2->D2_BASIMP1,SD2->D2_ALQIMP2,SD2->D2_VALIMP2,SD2->D2_VALIMP2,SD2->D2_TES})
								Else
									aGerSD1[nPosImp][10] += SD2->D2_BASIMP3
									aGerSD1[nPosImp][12] += SD2->D2_VALIMP3
									aGerSD1[nPosImp][13] += SD2->D2_VALIMP1
								EndIf	
							EndIf
							If SD2->D2_VALIMP4 > 0
								lIVA := .T.					
								nPosImp := aScan(aGerSD1,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6] == SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_ESPECIE+SD2->D2_TES+SD2->D2_CONCEPT+"RV2"})
								If nPosImp == 0
									aAdd(aGerSD1,{SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_ESPECIE,SD2->D2_TES,SD2->D2_CONCEPT,"RV2",;
									SD2->D2_CLIENTE,SD2->D2_LOJA,SD2->D2_ESPECIE,SD2->D2_BASIMP1,SD2->D2_ALQIMP2,SD2->D2_VALIMP2,SD2->D2_VALIMP2,SD2->D2_TES})
								Else
									aGerSD1[nPosImp][10] += SD2->D2_BASIMP4
									aGerSD1[nPosImp][12] += SD2->D2_VALIMP4
									aGerSD1[nPosImp][13] += SD2->D2_VALIMP1
								EndIf	
							EndIf    
							IF cPaisLoc <> "VEN" //GSA           
								If (SD2->D2_VALIMP2+SD2->D2_VALIMP3+SD2->D2_VALIMP4)>0 
									//Entrada - Gera titulo Abatimento IR(temporario)
									nPosNota:= aScan(aVlrCP,{|x| x[1]+x[2]+x[3]+x[4]+x[6]+x[7] == SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA+"I"+SD2->D2_ESPECIE})
									If nPosNota == 0
										aAdd(aVlrCP,{SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_CLIENTE,SD2->D2_LOJA,SD2->D2_VALIMP2+SD2->D2_VALIMP3+SD2->D2_VALIMP4,"I",SD2->D2_ESPECIE})
									Else
										aVlrCp[nPosNota][5]+=SD2->D2_VALIMP2+SD2->D2_VALIMP3+SD2->D2_VALIMP4
									EndIf
								EndIf
							ENDIF
							//RIR RETENCAO
							If SD2->D2_VALIMP6>0
								lRIR := .T.					
								nPosImp := aScan(aGerSD1,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6] == SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_ESPECIE+SD2->D2_TES+""+"RIR"})
								If nPosImp == 0
									If cPaisLoc == "VEN"
										dbSelectArea("SFF")
										SFF->(DBSetOrder(14))//FF_FILIAL+FF_IMPOSTO+FF_REGIAO+FF_GRPPRD+
										If SFF->(DBSeek(xFilial("SFF") + "RIR" + SA2->A2_GRPTRIB + SD2->D2_CONCEPT))
											aAdd(aGerSD1,{SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_ESPECIE,SD2->D2_TES,SD2->D2_CONCEPT,"RIR",;
											SD2->D2_CLIENTE,SD2->D2_LOJA,SD2->D2_ESPECIE,SD2->D2_BASIMP6,SFF->FF_ALIQ,SD2->D2_VALIMP6,SD2->D2_VALIMP6,SD2->D2_TES})
										EndIf
									ELSE
										dbSelectArea("SFF")
										SFF->(DBSetOrder(14)) //FF_FILIAL+FF_IMPOSTO+FF_ZONFIS+FF_TIPO+FF_CFO_V 
										If SFF->(DBSeek(xFilial("SFF") + SFB->FB_CODIGO + SA2->A2_GRTRIB + SB1->B1_GRTRIB))
											aAdd(aGerSD1,{SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_ESPECIE,SD2->D2_TES,"","RIR",;
											SD2->D2_CLIENTE,SD2->D2_LOJA,SD2->D2_ESPECIE,SD2->D2_BASIMP6,SFF->FF_ALIQ,SD2->D2_VALIMP6,SD2->D2_VALIMP6,SD2->D2_TES})
										EndIf
									ENDIF
								Else
									aGerSD1[nPosImp][10] += SD2->D2_BASIMP6
									aGerSD1[nPosImp][12] += SD2->D2_VALIMP6
									aGerSD1[nPosImp][13] += SD2->D2_VALIMP6
								EndIf	
								IF cPaisLoc <> "VEN" //GSA
									If SD2->D2_VALIMP6>0
										//Entrada - Gera titulo Abatimento IR(temporario)
										nPosNota:= aScan(aVlrCP,{|x| x[1]+x[2]+x[3]+x[4]+x[6] +x[7]== SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA+"R"+SD2->D2_ESPECIE})
										If nPosNota == 0
											aAdd(aVlrCP,{SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_CLIENTE,SD2->D2_LOJA,SD2->D2_VALIMP6,"R",SD2->D2_ESPECIE})
										Else
											aVlrCp[nPosNota][5] += SD2->D2_VALIMP6
										EndIf
									EndIf
								ENDIF
							EndIf
							SD2->(DbSkip())                                   
						End
						If lIVA .And. !lNumCert
							aImpIVA := GerNumCert("IVA",2)
							aImpRIR := aImpIVA
							If Len(aImpIVA) == 0
								lIVA := .F.
								lRIR := .F. 
							Else
								lNumCert := .T.	
							EndIf					
						EndIf
						If lRIR .And. !lNumCert
							aImpRIR := GerNumCert("RIR",2)
							aImpIVA := aImpRIR
							If Len(aImpRIR) == 0
								lRIR := .F.
								lIVA := .F.
							Else
								lNumCert := .T.	
							EndIf
						EndIf 
						If lIVA .Or. lRIR	
							For nCont := 1 To Len(aGerSD1)
								If Alltrim(aGerSD1[nCont][6]) == "RIR"   
									aAdd(aGerRet,{aImpRIR[1],aImpRIR[2],aGerSD1[nCont][1],aGerSD1[nCont][2],aGerSD1[nCont][7],aGerSD1[nCont][8],aGerSD1[nCont][6],;
									aGerSD1[nCont][5],aGerSD1[nCont][11],aGerSD1[nCont][10],aGerSD1[nCont][13],aGerSD1[nCont][12],aGerSD1[nCont][3],aGerSD1[nCont][14]})
								Else
									aAdd(aGerRet,{aImpIVA[1],aImpIVA[2],aGerSD1[nCont][1],aGerSD1[nCont][2],aGerSD1[nCont][7],aGerSD1[nCont][8],aGerSD1[nCont][6],;
									aGerSD1[nCont][5],aGerSD1[nCont][11],aGerSD1[nCont][10],aGerSD1[nCont][13],aGerSD1[nCont][12],aGerSD1[nCont][3],aGerSD1[nCont][14]})
								EndIf       
							Next		
						EndIf
					EndIf     
				EndIf			
			EndIf	
		EndIf  
		If Len(aGerRet)>0      
			cMsgCert	:= ""
			cChvCert	:= ""
			alCertRet	:= {}                                   
			For nCont := 1 To Len(aGerRet)
				Begin Transaction
					DbSelectArea("SFE")
					RecLock("SFE",.T.)
					SFE->FE_FILIAL	:= xFilial("SFE")	                       //Filial que está gerando o certificado
					SFE->FE_NROCERT	:= aGerRet[nCont][1]                        //Numero Certificado								
					If cPaisLoc <> "VEN"
						SFE->FE_NUMAUT	:= aGerRet[nCont][2]							//Numero Autorizacao
						SFE->FE_TES		:= aGerRet[nCont][14]							//tes da Nota			
					EndIf
					SFE->FE_EMISSAO	:= IIf(lFchEmi, M->F1_EMISSAO, dDataBase)			//Data Emissao
					SFE->FE_NFISCAL	:= aGerRet[nCont][3]								//Numero da fatura
					//Bruno Cremaschi - Projeto chave única.
					//SFE->FE_SERIE	:= aGerRet[nCont][4]								//Serie da fatura
					SerieNFID("SFE", 1, "FE_SERIE",,,,aGerRet[nCont][4])
					If nTipOpe == 1 .Or. nTipOpe == 2 .And. cPaisLoc == "VEN"
						SFE->FE_FORNECE	:= aGerRet[nCont][5]							//Codigo do Fornecedor
						SFE->FE_LOJA   	:= aGerRet[nCont][6]							//Loja			
					Else
						SFE->FE_CLIENTE	:= aGerRet[nCont][5]							//Codigo do Cliente
						SFE->FE_LOJCLI 	:= aGerRet[nCont][6]							//Loja			
					EndIf
					SFE->FE_TIPO	:= IIF(aGerRet[nCont][7] == "BAR","B",IIf(aGerRet[nCont][7] == "RIR", "R", "I"))		//Tipo de Imposto
					SFE->FE_CONCEPT := aGerRet[nCont][8]								//Codigo Fiscal da Operação	
					SFE->FE_ALIQ	:= aGerRet[nCont][9]								//Aliquota para o Calculo
					SFE->FE_VALBASE	:= aGerRet[nCont][10]								//Base de calculo da retenção
					SFE->FE_VALIMP	:= aGerRet[nCont][11]								//Valor do imposto da retenção
					SFE->FE_RETENC	:= aGerRet[nCont][12]								//Valor da retenção
					SFE->FE_ESPECIE	:= aGerRet[nCont][13]								//Especie da Nota

					If SFE->(FieldPos("FE_CODRET")) > 0
						DbSelectArea("SFB") 
						SFB->(DbSetOrder(1)) //FB_FILIAL+FB_CODIGO                                 
						If SFB->(DbSeek(xFilial("SFB")+AvKey(aGerRet[nCont][7],"FB_CODIGO"))) 
							SFE->FE_CODRET	:= SFB->FB_CODRET
						EndIf					
					EndIf
					SFE->(MsUnLock())
					//Métrica
					LxMetFS015()

				End  Transaction					
				If cPaisLoc == "VEN"
					nX := aScan(alCertRet,{|x| Alltrim(x[1])+Alltrim(x[5])+Alltrim(Str(x[9])) == Alltrim(SFE->FE_NROCERT)+Alltrim(SFE->FE_TIPO)+Alltrim(Str(SFE->FE_ALIQ))})
				Else
					nX := aScan(alCertRet,{|x| Alltrim(x[1])+Alltrim(x[5])+Alltrim(Str(x[9]))+Alltrim(x[14])+Alltrim(x[15]) == Alltrim(SFE->FE_NROCERT)+Alltrim(SFE->FE_TIPO)+Alltrim(Str(SFE->FE_ALIQ))+Alltrim(SFE->FE_CODRET)+Alltrim(SFE->FE_NUMAUT)})
				EndIf
				If nX == 0
					aAdd(alCertRet,{SFE->FE_NROCERT,;	// [1]	Numero Certificado
					SFE->FE_EMISSAO,;	// [2]	Data Emissao
					IIf(cPaisLoc == "EQU",IIf(!Empty(SFE->FE_CLIENTE),SFE->FE_CLIENTE,SFE->FE_FORNECE),SFE->FE_FORNECE),;	// [3]	Codigo do Fornecedor
					IIf(cPaisLoc == "EQU",IIf(!Empty(SFE->FE_CLIENTE),SFE->FE_LOJCLI,SFE->FE_LOJA)    ,SFE->FE_LOJA),;    // [4]	Loja
					SFE->FE_TIPO,;		// [5]	Tipo
					SFE->FE_NFISCAL,;	// [6]	Numero da fatura
					SFE->FE_SERIE,;		// [7]	Serie da fatura
					SFE->FE_VALBASE,;	// [8]	Base de calculo da retenção
					SFE->FE_ALIQ,;		// [9]	Aliquota para o Calculo
					SFE->FE_FILIAL,;	// [10]	Filial que está gerando o certificado
					SFE->FE_VALIMP,;	// [11]	Valor do imposto da retenção
					SFE->FE_RETENC,;	// [12]	Valor da retenção 
					SFE->FE_CONCEPT,;	// [13]	Codigo Fiscal da Operação
					IIf(SFE->(FieldPos("FE_CODRET")) > 0, SFE->FE_CODRET, ""),;	// [14]	Codigo Retencao
					IIf(SFE->(FieldPos("FE_NUMAUT")) > 0, SFE->FE_NUMAUT, ""),;	// [15]	Numero Autorizacao
					IIf(cPaisLoc == "EQU", SFE->FE_ESPECIE, ""),; // [16] Espécie da nota
					IIf(cPaisLoc == "EQU", IIf(!Empty(SFE->FE_CLIENTE), "C", "F"), "")}) // [17] Tipo (C-Cliente\F-Fornecedor)
				Else
					alCertRet[nX][08] += SFE->FE_VALBASE
					alCertRet[nX][11] += SFE->FE_VALIMP
					alCertRet[nX][12] += SFE->FE_RETENC
				EndIf

				If cChvCert <> Alltrim(aGerRet[nCont][3]) + Alltrim(aGerRet[nCont][4]) + Alltrim(aGerRet[nCont][5]) + Alltrim(aGerRet[nCont][6])
					cMsgCert += STR0001 + ":" + Alltrim(aGerRet[nCont][3]) + '-' + Alltrim(aGerRet[nCont][4]) + Chr(13) + Chr(10)
					cMsgCert += "***" + STR0043 + Space(1) + Alltrim(aGerRet[nCont][1]) + "***" + Chr(13) + Chr(10)//Gerado o Numero de Certificado
					cChvCert := Alltrim(aGerRet[nCont][3]) + Alltrim(aGerRet[nCont][4]) + Alltrim(aGerRet[nCont][5]) + Alltrim(aGerRet[nCont][6])
				EndIf
			Next
			For nCont := 1 To Len(aVlrCP)
				cParcSE1 := ""
				If ((nTipOpe == 1 .And. Alltrim(aVlrCp[nCont][7]) <> "NDE") .Or.  Alltrim(aVlrCp[nCont][7]) == "NDI") .And. !("NC" $ aVlrCp[nCont][7])
					cPrefixo	:= IIf(Empty(aVlrCp[nCont][2]), &(SuperGetMV("MV_2DUPREF")), aVlrCp[nCont][2])
					aArea		:= GetArea()
					DbSelectArea("SE2")
					SE2->(DbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO     
					aTitulo := {}
					If SE2->(dbSeek(xFilial("SE2")+aVlrCp[nCont][3]+aVlrCp[nCont][4]+cPrefixo+aVlrCp[nCont][1]) )

						While SE2->(!Eof()) .And. xFilial("SE2")+aVlrCp[nCont][3]+aVlrCp[nCont][4]+cPrefixo+aVlrCp[nCont][1] ==  ;
						SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM
							If !(SE2->E2_TIPO$ MVIVABT) .And. !(SE2->E2_TIPO$ MVIRABT)
								aAdd(aTitulo,SE2->E2_PARCELA)              
								cNaturez:=SE2->E2_NATUREZ           
								cTipoTit:= SE2->E2_TIPO
							EndIf
							SE2->(DbSkip())
						EndDo 
					EndIf			
					//Entrada-Gera Titulo de Abatimento          
					nValor	:= 0
					nValorT	:= 0 

					RestArea(aArea)

					nI := 1
					lUnica := .T.

					DbSelectArea("SED")
					SED->(DbSetOrder(1)) //ED_FILIAL+ED_CODIGO     
					If (dbSeek(xFilial("SED")+cNaturez))
						lUnica:=IIf(SED->ED_RATRET =="1",.T.,.F.)
					EndIf

					RestArea(aArea)

					If Len(aTitulo) > 0
						If lUnica
							lOk := fGerAbatCP(aVlrCp[nCont][2], aVlrCp[nCont][1],aTitulo[1],cTipoTit, aVlrCp[nCont][3], aVlrCp[nCont][4],aVlrCp[nCont][5] ,aVlrCp[nCont][6])  
						Else
							For nI := 1 To Len(aTitulo)
								nValor:= Round((aVlrCp[nCont][5]/Len(aTitulo)),GetMV("MV_CENT"))

								If nI == Len(aTitulo)
									nValor:= aVlrCp[nCont][5] -  nValorT
								Else
									nValorT := nValorT + nValor
								EndIf
								lOk := fGerAbatCP(aVlrCp[nCont][2], aVlrCp[nCont][1],aTitulo[nI],cTipoTit, aVlrCp[nCont][3], aVlrCp[nCont][4], nValor ,aVlrCp[nCont][6])  
							Next
						EndIf
					EndIf	
				ElseIf !("NC" $ aVlrCp[nCont][7])   
					//Saida-Gera Titulo de Abatimento          
					cPrefixo	:= IIf(Empty (aVlrCp[nCont][2]), &(SuperGetMV ("MV_1DUPREF")), aVlrCp[nCont][2])
					aArea		:= GetArea()
					DbSelectArea("SE1")
					SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO     
					aTitulo := {}
					If SE1->(dbSeek(xFilial("SE1")+aVlrCp[nCont][3]+aVlrCp[nCont][4]+cPrefixo+aVlrCp[nCont][1]) )
						While SE1->(!Eof()) .And. xFilial("SE1")+aVlrCp[nCont][3]+aVlrCp[nCont][4]+cPrefixo+aVlrCp[nCont][1] ==  ;
						SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM
							If !(SE1->E1_TIPO$ MVIVABT) .And. !(SE1->E1_TIPO$ MVIRABT)
								aAdd(aTitulo,SE1->E1_PARCELA)              
								cNaturez:=SE1->E1_NATUREZ
								cTipoTit:= SE1->E1_TIPO
							EndIf
							SE1->(DbSkip())
						EndDo 
					EndIf
					//Entrada-Gera Titulo de Abatimento          
					nValor	:= 0
					nValorT	:= 0 
					nI		:= 1
					lUnica	:= .T.

					DbSelectArea("SED")
					SED->(DbSetOrder(1)) ////ED_FILIAL+ED_CODIGO   
					If (dbSeek(xFilial("SED")+cNaturez))
						lUnica:=IIf(SED->ED_RATRET =="1",.T.,.F.)
					EndIf

					RestArea(aArea)

					If lUnica
						lOk := fGerAbatCR(aVlrCp[nCont][2], aVlrCp[nCont][1],aTitulo[1], cTipoTit, aVlrCp[nCont][3], aVlrCp[nCont][4],aVlrCp[nCont][5],aVlrCp[nCont][6])  
					Else
						For nI := 1 To Len(aTitulo)
							nValor:= Round((aVlrCp[nCont][5]/Len(aTitulo)),GetMV("MV_CENT"))
							If nI == Len(aTitulo)
								nValor:= aVlrCp[nCont][5] -  nValorT     
							Else
								nValorT := nValorT + nValor	
							EndIf
							lOk := fGerAbatCR(aVlrCp[nCont][2], aVlrCp[nCont][1],aTitulo[nI],cTipoTit, aVlrCp[nCont][3], aVlrCp[nCont][4], nValor,aVlrCp[nCont][6])  
						Next
					EndIf    
				EndIf
			Next	                                                        
		EndIf     
		If cPaisLoc<>"EQU" .Or. lOk
			If llImpri
				If Len(alCertRet) > 0
					FISR014(alCertRet) 
				EndIf
			ElseIf !Empty(cMsgCert) 
				Aviso(STR0011,cMsgCert,{STR0021})	// "Certificados de Retenção"###
			EndIf
		EndIf

	Else   // OUTROS PAISES

		dbSelectArea("TMP1")
		TMP1->(dbGoTop())
		WHILE TMP1->(!EOF())
			If !Empty(TMP1->OK)
				If Alltrim(clForn)+Alltrim(clLoja) <> Alltrim(TMP1->F1_FORNECE)+Alltrim(TMP1->F1_LOJA)
					clForn	:= TMP1->F1_FORNECE
					clLoja	:= TMP1->F1_LOJA

					If MV_PAR01 == 1 		// IVA
						clImp := "RV0"
					ElseIf MV_PAR01 == 2 	// ICA
						clImp := "RC0"
					Else 					//Fonte
						clImp := "RF0"
					EndIf

					dbSelectArea("SX5")
					If dbSeek(xFilial("SX5")+"99"+clImp)

						clDescX5 := (X5Descri())
						clDescX5 := Alltrim(StrZero(Val(clDescX5)+1,TamSx3("FE_NROCERT")[1]))

						If RecLock("SX5",.F.)
							Replace X5_DESCRI	WITH clDescX5
							Replace X5_DESCSPA	WITH clDescX5
							Replace X5_DESCENG	WITH clDescX5
							MsUnLock()
						EndIf
					EndIf
				EndIf

				dbSelectArea("SFE")
				RecLock("SFE",.T.)
				SFE->FE_EMISSAO	:= dDataBase
				SFE->FE_FORNECE	:= TMP1->F1_FORNECE
				SFE->FE_LOJA	:= TMP1->F1_LOJA
				SFE->FE_NFISCAL	:= TMP1->F1_DOC
				//Bruno Cremaschi - Projeto chave única.
				//SFE->FE_SERIE	:= TMP1->F1_SERIE
				SerieNFID("SFE", 1, "FE_SERIE",,,,TMP1->F1_SERIE)
				SFE->FE_FILIAL	:= xFilial("SFE")
				SFE->FE_NROCERT := clDescX5
				SFE->FE_CONCEPT	:= TMP1->F4_TIPORET
				If MV_PAR01 == 1 		// IVA
					SFE->FE_TIPO	:= "I"
					SFE->FE_VALBASE	:= TMP1->F1_BASIMP1
					SFE->FE_VALIMP	:= TMP1->F1_VALIMP1  //IVA operacion
					SFE->FE_RETENC	:= TMP1->F1_VALIMP2
					SFE->FE_ALIQ	:= TMP1->F3_ALQIMP2
				ElseIf MV_PAR01 == 2 	// ICA
					SFE->FE_TIPO	:= "C"
					SFE->FE_VALBASE	:= TMP1->F1_BASIMP7
					SFE->FE_VALIMP	:= TMP1->F1_VALIMP7
					SFE->FE_RETENC	:= TMP1->F1_VALIMP7
					SFE->FE_ALIQ	:= TMP1->F3_ALQIMP7
				Else 					// Fonte
					SFE->FE_TIPO	:= "F"
					SFE->FE_VALBASE	:= TMP1->F1_BASIMP4
					SFE->FE_VALIMP	:= TMP1->F1_VALIMP4
					SFE->FE_RETENC	:= TMP1->F1_VALIMP4
					SFE->FE_ALIQ	:= TMP1->F3_ALQIMP4
				EndIf
				IIf(cPaisLoc=="COL",FE_CFO:= TMP1->F3_CFO,)
				IIf(cPaisLoc=="COL",FE_ESPECIE:= TMP1->F3_ESPECIE,)
				SFE->(MsUnLock())
				//Métrica 
				LxMetFS015()
				llImpri := .T.
				//Bruno Cremaschi - Projeto chave única.
				cSDoc := SerieNFID("SFE", 3, "FE_SERIE")
				aAdd(alCertRet,{SFE->FE_NROCERT,;	// [1]	Numero Certificado
				SFE->FE_EMISSAO,;	// [2]	Data Emissao
				SFE->FE_FORNECE,;	// [3]	Codigo do Fornecedor
				SFE->FE_LOJA,;		// [4]	Loja
				SFE->FE_TIPO,;		// [5]	Tipo
				SFE->FE_NFISCAL,;	// [6]	Numero da fatura
				SFE->&cSDoc,;		// [7]	Serie da fatura
				SFE->FE_VALBASE,;	// [8]	Base de calculo da retenção
				SFE->FE_ALIQ,;		// [9]	Aliquota para o Calculo
				SFE->FE_FILIAL,;	// [10]	Filial que está gerando o certificado
				SFE->FE_VALIMP,;	// [11]	Valor do imposto da retenção
				SFE->FE_RETENC,;	// [12]	Valor da retenção
				SFE->FE_CONCEPT,;   // [13]	Codigo Fiscal da Operação
				IIf(cPaisLoc=="COL",TMP1->F3_CFO,""),; // [14] Colombia Codigo Fiscal
				IIf(cPaisLoc=="COL",TMP1->F_TIPO,""),;  // [15] Equador-Codigo Retencao / Colombia Tipo docto 1= entrada 2 = Salida
				IIf(cPaisLoc=="COL",TMP1->F3_ESPECIE,""),;// [16] Espécie da nota
				"",;										// [17] Tipo (C-Cliente\F-Fornecedor)
				IIf(cPaisLoc=="COL" .AND. MV_PAR01 == 2,TMP1->CC2_CODMUN,""),; // [18] cod municipo
				IIf(cPaisLoc=="COL" .AND. MV_PAR01 == 2,TMP1->CC2_MUN,"")})  // [19] municipio
			EndIf
			TMP1->(dbSkip())
		EndDo               
		If llImpri
			If cPaisLoc=="COL"
				alCertRet := FIS015GR(alCertRet)
			EndIf
			If nTipImp == 1 		// IVA
				MATR991(alCertRet)
			ElseIf nTipImp == 2 	// ICA
				MATR993(alCertRet)
			Else 					//Fonte
				MATR992(alCertRet)
			EndIf
		EndIf
	EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GerNumCert³ Autor ³ Marcos Kato          ³ Data ³30/07/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica o proximo numero do certificado do imposto        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Retorna o numero de certificado e o Numero de Autorizacao  ³±±
±±³          ³ aArray[1] -> Numero Certificado                            ³±±
±±³          ³ aArray[2] -> Numero Autorizacao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Equador                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GerNumCert(cImp,nTipo)

	Local lCertOK	:= .F.
	Local cImpX5 	:= ""
	Local aCertRet	:= {}
	Local aAreaA	:= GetArea()

	Default cImp	:= ""                
	Default nTipo	:= 1

	If cPaisLoc == "VEN"
		If nTipo == 1
			cImp := Alltrim(Str(Year(F1_DTDIGIT)) + strzero(month(F1_DTDIGIT),2))
		Else	                                                               
			cImp := Alltrim(Str(Year(dDatabase)) + strzero(month(dDatabase),2))
		EndIf
	EndIf                    

	If !Empty(cImp) 
		aCertRet := {}
		//Pega o proximo Numero do Certificado de IR e verifica se a numeracao esta dentro do controle de folios tipo RIR		
		If cPaisLoc == "VEN"
			DbSelectArea("SX5")
			If dbSeek(xFilial("SX5")+"99"+cImp)
				cImpX5 := (X5Descri())
				cImpX5 := Alltrim(StrZero(Val(cImpX5)+1,TamSx3("FE_NROCERT")[1]- Len(cImp)))
				If RecLock("SX5",.F.)
					Replace X5_DESCRI	WITH cImpX5
					Replace X5_DESCSPA	WITH cImpX5
					Replace X5_DESCENG	WITH cImpX5
					SX5->(MsUnLock())
				EndIf
			Else
				RecLock("SX5", .T.)
				SX5->X5_TABELA 	:= '99'
				SX5->X5_FILIAL 	:= xFilial("SX5")
				SX5->X5_CHAVE  	:= cImp
				SX5->X5_DESCRI 	:= '00000001'
				SX5->X5_DESCSPA := '00000001'
				SX5->X5_DESCENG := '00000001'
				cImpX5       	:= '00000001'
				MsUnLock()
			EndIf
			aAdd(aCertRet,cImp+cImpX5)
			aAdd(aCertRet,"   ")							
			lCertOK:=.T.

		Else

			SX5->(DbSelectArea("SX5"))
			If SX5->(dbSeek(xFilial("SX5")+"99"+cImp))
				RecLock("SX5",.F.,,.T.)
				cImpX5 := (X5Descri())
				cImpX5 := Alltrim(StrZero(Val(cImpX5)+1,TamSx3("FE_NROCERT")[1]))
				
				If cPaisLoc == "EQU"
					Do While .T.
						If VerConsCER(cImpX5)
							Exit
						EndIf
						cImpX5 := Alltrim(StrZero(Val(cImpX5)+1,TamSx3("FE_NROCERT")[1]))
					EndDo
				EndIf

				DbSelectArea("SFP")
				SFP->(dbGoTop())
				SFP->(DbSetOrder(6)) //FP_FILIAL+FP_FILUSO+FP_ESPECIE+FP_SERIE+FP_NUMINI
				If DbSeek(xFilial("SFP")+cFilAnt+"6") .And. cPaisLoc <> "VEN"
					Do While SFP->FP_FILIAL == xFilial("SFP") .And. SFP->FP_FILUSO == cFilAnt .And. Alltrim(SFP->FP_ESPECIE) == "6" 
						If SFP->FP_NUMINI <= cImpX5 .And. SFP->FP_NUMFIM >= cImpX5
							If SFP->FP_ATIVO == "1"
								If dDataBase <= SFP->FP_DTAVAL
									aAdd(aCertRet,cImpX5)
									aAdd(aCertRet,SFP->FP_NUMAUT)							
									lCertOK:=.T.
									Exit
								EndIf 
							EndIf	
						EndIf
						SFP->(dbSkip())
					End
				Else
					aAdd(aCertRet,cImpX5)
					If nTipo == 1 .And. cPaisLoc=="EQU"
						aAdd(aCertRet,SF1->F1_NUMAUT)
					Else
						aAdd(aCertRet,"   ")							
					EndIf							
					lCertOK := .T.
				EndIf
				If lCertOK 	
					SX5->X5_DESCRI  := cImpX5
					SX5->X5_DESCSPA	:= cImpX5
					SX5->X5_DESCENG := cImpX5
				EndIf
				SX5->(MsUnLock())
			EndIf 				
		EndIf	
	EndIf

	RestArea(aAreaA)

Return aCertRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FQrIEc   ³ Autor ³ Hermes Ferreira       ³ Data ³16/12/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria a query para trazer os dados da SFE de acordo com o   ³±±
±±³          ³ Numero do certificado informado e o tipo de imposto        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ clQry - Query montada para criar o Alias                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Grava SFE e Imprimi os Certificados de Retençao            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FQrIEc()

	Local clQry	:= ""

	clQry := "SELECT FE_NROCERT"
	clQry += ", FE_EMISSAO "  
	clQry += ", FE_FORNECE "
	clQry += ", FE_LOJA "
	clQry += ", FE_TIPO "
	clQry += ", FE_NFISCAL "
	clQry += ", FE_SERIE "
	clQry += ", FE_VALBASE "
	clQry += ", FE_ALIQ "
	clQry += ", FE_FILIAL "
	clQry += ", FE_VALIMP "
	clQry += ", FE_RETENC "
	clQry += ", FE_CONCEPT "

	If cPaisLoc == "COL"
		cEspecE :="'" + PADR('NF',TamSx3("FE_ESPECIE")[1]) + "','" + PADR('NDP',TamSx3("FE_ESPECIE")[1])  + "','" + PADR('NCI',TamSx3("FE_ESPECIE")[1]) + "'"
		cEspecS :="'" + PADR('NDI',TamSx3("FE_ESPECIE")[1]) + "','" + PADR('NCP',TamSx3("FE_ESPECIE")[1]) + "'" 
		clQry += ", FE_ESPECIE "
		clQry += ", FE_CFO, CASE WHEN FE_ESPECIE IN (" + cEspecE + ") THEN '1' WHEN FE_ESPECIE IN (" + cEspecS + ") THEN '2' ELSE '' END FE_TIPDOC "
	EndIf

	If cPaisLoc == "EQU"
		clQry += ", FE_CLIENTE "
		clQry += ", FE_LOJCLI "
		clQry += ", FE_CODRET "	
		clQry += ", FE_NUMAUT "
		clQry += ", FE_ESPECIE "
	EndIf

	clQry += " FROM "+RetSqlName("SFE")+" SFE" 
	clQry += " WHERE SFE.D_E_L_E_T_ = ' ' "
	clQry += " AND FE_FILIAL = '" + xFilial("SFE") + "' "
	clQry += " AND FE_NROCERT >= '" +cNCertIni+"'"
	clQry += " AND FE_NROCERT <= '" +cNCertFim+"'"

	If cPaisLoc $ "EQU|VEN"
		If !Empty(dDtFim)
			clQry += " AND FE_EMISSAO BETWEEN'"+DTOS(dDtIni)+"' AND '"+DTOS(dDtFim)+"' "
		Else
			clQry += " AND FE_EMISSAO >= '"+DTOS(dDtIni)+"' "
		EndIf	
		If !Empty(cDocFim)
			clQry += " AND FE_NFISCAL BETWEEN '"+Alltrim(cDocIni)+"' AND '"+Alltrim(cDocFim)+"' "
		Else
			clQry += " AND FE_NFISCAL >= '"+Alltrim(cDocIni)+"' "		
		EndIf	
		If nTipOpe == 1//Entrada
			If !Empty(cCodFim)			
				clQry += " AND FE_FORNECE BETWEEN '"+Alltrim(cCodIni)+"' AND '"+Alltrim(cCodFim)+"' "
			Else
				clQry += " AND FE_FORNECE >= '"+Alltrim(cCodIni)+"' "
			EndIf	
			If !Empty(cLojFim)
				clQry += " AND FE_LOJA BETWEEN '"+Alltrim(cLojIni)+"' AND '"+Alltrim(cLojFim)+"' "
			Else
				clQry += " AND FE_LOJA >= '"+Alltrim(cLojIni)+"' "					
			EndIf
			clQry += " AND FE_FORNECE <> ''"
		Else//Saida       
			If !Empty(cCodFim)		
				clQry += " AND FE_CLIENTE BETWEEN '"+Alltrim(cCodIni)+"' AND '"+Alltrim(cCodFim)+"' "
			Else
				clQry += " AND FE_CLIENTE >= '"+Alltrim(cCodIni)+"' "
			EndIf
			If !Empty(cLojFim)
				clQry += " AND FE_LOJCLI BETWEEN '"+Alltrim(cLojIni)+"' AND '"+Alltrim(cLojFim)+"' "
			Else
				clQry += " AND FE_LOJCLI >= '"+Alltrim(cLojIni)+"' "					
			EndIf	
			clQry += " AND FE_CLIENTE <> ''"
		EndIf       

		//Bruno Cremaschi - Projeto chave única.
		cSDoc := SerieNFID("SFE", 3, "FE_SERIE")
		If !Empty(cSerFim)
			clQry += " AND " + cSDoc + " BETWEEN '"+Alltrim(cSerIni)+"' AND '"+Alltrim(cSerFim)+"' "
		Else
			clQry += " AND " + cSDoc + " >= '"+Alltrim(cSerIni)+"' "
		EndIf	
		If nTipImp == 1
			clQry += " AND FE_TIPO = 'I' "
		ElseIf nTipImp == 2
			clQry += " AND FE_TIPO = 'R' "
		EndIf
	Else
		If nTipImp == 1
			clQry += " AND FE_TIPO = 'I' "
		ElseIf nTipImp == 2
			clQry += " AND FE_TIPO = 'C' "
		Else
			clQry += " AND FE_TIPO = 'F' "
		EndIf
	EndIf

Return clQry

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³LocArgTRepº Autor ³ Marcos Kato        º Data ³  24/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Montagem do relatorio Certificados Pendentes        		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ EQUADOR                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ImpCertPend()

	Local oReport	:= Nil
	Local aArea		:= GetArea()
	Local aDadImp	:={}

	Private cPerg	:= ""    
	Private aOrd	:= {}              

	DbSelectArea("TMP1")
	TMP1->(DbGoTop())
	Do While TMP1->(!Eof())
		If !Empty(TMP1->OK)
			If nTipImp == 1                                                                                    
				aAdd(aDadImp,{TMP1->D2_CLIFOR,TMP1->D2_LOJA,TMP1->D2_ESPECIE,TMP1->D2_DOC,TMP1->D2_SERIE,TMP1->D2_EMISSAO,TMP1->D2_CONCEPT,;
				TMP1->D2_BASIMP2,TMP1->D2_ALQIMP2,TMP1->D2_VALIMP2,;
				TMP1->D2_BASIMP3,TMP1->D2_ALQIMP3,TMP1->D2_VALIMP3,;
				TMP1->D2_BASIMP4,TMP1->D2_ALQIMP4,TMP1->D2_VALIMP4,;
				0.00,0.00,0.00})
			ElseIf nTipImp == 2 
				aAdd(aDadImp,{TMP1->D2_CLIFOR,TMP1->D2_LOJA,TMP1->D2_ESPECIE,TMP1->D2_DOC,TMP1->D2_SERIE,TMP1->D2_EMISSAO,TMP1->D2_CONCEPT,;
				0.00,0.00,0.00,;
				0.00,0.00,0.00,;
				0.00,0.00,0.00,;
				TMP1->D2_BASIMP6,TMP1->D2_ALQIMP6,TMP1->D2_VALIMP6})
			ElseIf nTipImp == 3 
				aAdd(aDadImp,{TMP1->D2_CLIFOR,TMP1->D2_LOJA,TMP1->D2_ESPECIE,TMP1->D2_DOC,TMP1->D2_SERIE,TMP1->D2_EMISSAO,TMP1->D2_CONCEPT,;
				TMP1->D2_BASIMP2,TMP1->D2_ALQIMP2,TMP1->D2_VALIMP2,;
				TMP1->D2_BASIMP3,TMP1->D2_ALQIMP3,TMP1->D2_VALIMP3,;
				TMP1->D2_BASIMP4,TMP1->D2_ALQIMP4,TMP1->D2_VALIMP4,;
				TMP1->D2_BASIMP6,TMP1->D2_ALQIMP6,TMP1->D2_VALIMP6})
			EndIf
		EndIf
		TMP1->(DbSkip())
	End		
	If Len(aDadImp)>0
		oReport := CertPend(nTipImp,aDadImp)//TREPORT
		oReport:PrintDialog()
	EndIf

	RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CertPend ºAutor  ³Marcos Kato          º Data ³  16/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Estrutura do Relatorio em TREPORT                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ EQUADOR                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CertPend(nTipImp, aDadImp)

	Local oReport	:= Nil
	Local oSection1	:= Nil
	Local oSection2	:= Nil
	Local cTitulo	:= STR0044//"Certificado de Retencao Pendente"
	Local cPerg		:= "" 
	Local cDesc1	:= STR0044//"Certificado de Retencao Pendente"
	Local cNumDoc	:= ""
	Local cSerie	:= ""

	Private cCodigo	:= ""
	Private cLoja  	:= ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao dos componentes de impressao                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAlias1 := "SA2"
	cAlias2 := "SD1"
	If nTipImp == 1//IVA
		cDesc1	+= Space(1)+"IVA"
	ElseIf nTipImp == 2//IR
		cDesc1 += Space(1)+"IR"
	ElseIf nTipImp == 3//IVA e IR	   
		cDesc1 += Space(1) + "IVA" + "-" + "IR"
	EndIf	

	DEFINE REPORT oReport NAME "FISA015" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| Fisa15Imp(oReport,nTipImp,aDadImp)} DESCRIPTION cDesc1 TOTAL IN COLUMN
	oReport:SetPortrait(.T.)//Impressao Retrato
	oReport:DisableOrientation()//Desabilita a mudanca de impressao                    
	//-------------------------------------------------------------------------------------------------------
	// oSection1 = usado para montar o cabeçalho do relatorio
	//-------------------------------------------------------------------------------------------------------
	DEFINE SECTION oSection1 OF oReport TITLE OemToAnsi(STR0003) ORDERS aOrd TABLE cAlias1 TOTAL IN COLUMN//"Fornecedor"
	//oSection1:SetLineStyle()	// Impressao da descricao e conteudo do campo na mesma linha      
	DEFINE CELL NAME "cCodigo"	OF oSection1 TITLE STR0045	SIZE 10 ALIGN LEFT//Codigo
	DEFINE CELL NAME "cLoja"	OF oSection1 TITLE STR0004	SIZE  6 ALIGN LEFT//Loja

	TRPosition():New(oSection1,cAlias1,1,{||xFilial("SA2")+cCodigo+cLoja})
	//----------------------------------------------------------------------------------------------------
	// oSection2 = usado para fazer a segunda quebra no relatorio
	//----------------------------------------------------------------------------------------------------
	DEFINE SECTION oSection2 OF oReport TITLE OemToAnsi("Retencao") ORDERS aOrd TABLE cAlias2 TOTAL IN COLUMN     
	DEFINE CELL NAME "cEspecie"	OF oSection2	TITLE OemToAnsi(STR0022)	SIZE 10 ALIGN LEFT//"Especie"
	DEFINE CELL NAME "cNumDoc"	OF oSection2 	TITLE OemToAnsi(STR0046) 	SIZE 32 ALIGN LEFT//"Documento"
	//Bruno Cremaschi - Projeto chave única.
	DEFINE CELL NAME "cSerie"		OF oSection2 	TITLE OemToAnsi(STR0002)	SIZE 05 ALIGN LEFT    PICTURE "!!!"//"Serie"	
	DEFINE CELL NAME "cEmissao"		OF oSection2 	TITLE OemToAnsi(STR0005)	SIZE 14 ALIGN LEFT//"Emissao"	
	DEFINE CELL NAME "cConcepto"	OF oSection2 	TITLE OemToAnsi(STR0024)	SIZE 05 ALIGN LEFT//"Concepto"			

	If nTipImp == 1 .Or. nTipImp == 3	 	
		DEFINE CELL NAME "nBase2"	OF oSection2 	TITLE OemToAnsi(STR0026) 	SIZE 14 ALIGN RIGHT   PICTURE "@E 999,999,999.99"//"Bs.IVA 30%"
		DEFINE CELL NAME "nAlq2"	OF oSection2 	TITLE OemToAnsi(STR0027)  	SIZE 08 ALIGN RIGHT   PICTURE "@E 999.99"        //"Alq.IVA 30%"
		DEFINE CELL NAME "nValor2"	OF oSection2 	TITLE OemToAnsi(STR0028) 	SIZE 14 ALIGN RIGHT   PICTURE "@E 999,999,999.99"//"Vlr IVA 30%"
		DEFINE CELL NAME "nBase3"	OF oSection2 	TITLE OemToAnsi(STR0029) 	SIZE 14 ALIGN RIGHT   PICTURE "@E 999,999,999.99"//"Bs.IVA 70%" 
		DEFINE CELL NAME "nAlq3"	OF oSection2 	TITLE OemToAnsi(STR0030)  	SIZE 08 ALIGN RIGHT   PICTURE "@E 999.99"        //"Alq.IVA 70%"			
		DEFINE CELL NAME "nValor3"	OF oSection2 	TITLE OemToAnsi(STR0031) 	SIZE 14 ALIGN RIGHT   PICTURE "@E 999,999,999.99"//"Vlr IVA 70%"
		DEFINE CELL NAME "nBase4"	OF oSection2 	TITLE OemToAnsi(STR0032) 	SIZE 14 ALIGN RIGHT   PICTURE "@E 999,999,999.99"//"Bs.IVA 100%"
		DEFINE CELL NAME "nAlq4"	OF oSection2 	TITLE OemToAnsi(STR0033)  	SIZE 08 ALIGN RIGHT   PICTURE "@E 999.99"        //"Alq.IVA 100%"			
		DEFINE CELL NAME "nValor4"	OF oSection2 	TITLE OemToAnsi(STR0034)    SIZE 14 ALIGN RIGHT   PICTURE "@E 999,999,999.99"//"Vlr IVA 100%"
	EndIf

	If nTipImp == 2 .Or. nTipImp == 3	 			
		DEFINE CELL NAME "nBase6"	OF oSection2 	TITLE OemToAnsi(STR0047)	SIZE 14 ALIGN RIGHT   PICTURE "@E 999,999,999.99"//"Bs.IR"
		DEFINE CELL NAME "nAlq6"	OF oSection2 	TITLE OemToAnsi(STR0048)  	SIZE 08 ALIGN RIGHT   PICTURE "@E 999.99"        //"Alq.IR"			
		DEFINE CELL NAME "nValor6"	OF oSection2 	TITLE OemToAnsi(STR0049)	SIZE 14 ALIGN RIGHT   PICTURE "@E 999,999,999.99"//"Vlr.IR"
	EndIf

	TRPosition():New(oSection2,cAlias2,2,{||xFilial("SD1")+cCodigo+cLoja})

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R740Imp   ºAutor  ³SSERVICE            º Data ³  12/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao do Detalhe do Relatorio Grupo de Verba em TREPORT º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ EQUADOR                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fisa15Imp(oReport,nTipImp,aDadImp)

	Local oBreakVal	:= Nil
	Local oSection1	:= oReport:Section(1)
	Local oSection2	:= oReport:Section(2)  
	Local nCont		:= 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Estes DEFINE tem a finalidade de fazer a soma das colunas (SUM)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTipImp == 1 .Or. nTipImp == 3
		DEFINE FUNCTION FROM oSection2:Cell("nBase2"	)	FUNCTION SUM   BREAK oBreakVal PICTURE "@E 999,999,999.99"//NO END SECTION//NO END REPORT  // [No End Report] -  nao faz a impressao no final geral do relatgorio.
		DEFINE FUNCTION FROM oSection2:Cell("nValor2"	)	FUNCTION SUM   BREAK oBreakVal PICTURE "@E 999,999,999.99"//NO END SECTION//NO END REPORT  // [No End Report] -  nao faz a impressao no final geral do relatgorio.
		DEFINE FUNCTION FROM oSection2:Cell("nBase3"	)	FUNCTION SUM   BREAK oBreakVal PICTURE "@E 999,999,999.99"//NO END SECTION//NO END REPORT  // [No End Report] -  nao faz a impressao no final geral do relatgorio.
		DEFINE FUNCTION FROM oSection2:Cell("nValor3"	)	FUNCTION SUM   BREAK oBreakVal PICTURE "@E 999,999,999.99"//NO END SECTION//NO END REPORT  // [No End Report] -  nao faz a impressao no final geral do relatgorio.
		DEFINE FUNCTION FROM oSection2:Cell("nBase4"	)	FUNCTION SUM   BREAK oBreakVal PICTURE "@E 999,999,999.99"//NO END SECTION//NO END REPORT  // [No End Report] -  nao faz a impressao no final geral do relatgorio.
		DEFINE FUNCTION FROM oSection2:Cell("nValor4"	)	FUNCTION SUM   BREAK oBreakVal PICTURE "@E 999,999,999.99"//NO END SECTION//NO END REPORT  // [No End Report] -  nao faz a impressao no final geral do relatgorio.
	EndIf
	If nTipImp == 2 .Or. nTipImp == 3       
		DEFINE FUNCTION FROM oSection2:Cell("nBase6"	)	FUNCTION SUM   BREAK oBreakVal PICTURE "@E 999,999,999.99"//NO END SECTION//NO END REPORT  // [No End Report] -  nao faz a impressao no final geral do relatgorio.
		DEFINE FUNCTION FROM oSection2:Cell("nValor6"	)	FUNCTION SUM   BREAK oBreakVal PICTURE "@E 999,999,999.99"//NO END SECTION//NO END REPORT  // [No End Report] -  nao faz a impressao no final geral do relatgorio.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicio da impressao do fluxo do relatório ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:SetMeter(100)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Iniciando a oSection 1 com o Init()³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCodigo	:= aDadImp[1][1]
	cLoja   := aDadImp[1][2]
	oSection1:Init()
	oSection1:Cell("cCodigo"):SetBlock({||cCodigo})
	oSection1:Cell("cLoja"):SetBlock({||cLoja})
	oSection1:PrintLine()   
	oSection2:Init()

	For nCont := 1 To Len(aDadImp)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Movimenta Regua Processamento                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:IncMeter()
		If oReport:Cancel()
			Exit
		EndIf     

		If cCodigo + cLoja <> aDadImp[nCont][1] + aDadImp[nCont][2] 
			oSection2:Finish()
			oSection1:Finish()
			oSection1:Init()
			cCodigo	:= aDadImp[nCont][1]
			cLoja   := aDadImp[nCont][2]
			oSection1:Cell("cCodigo"):SetBlock({||cCodigo})
			oSection1:Cell("cLoja"):SetBlock({||cLoja})
			oSection1:PrintLine()   
			oSection2:Init()
		EndIf
		oSection2:Cell("cEspecie" ):SetBlock({||aDadImp[nCont][3]})	    
		oSection2:Cell("cNumDoc"  ):SetBlock({||aDadImp[nCont][4]})	    
		oSection2:Cell("cSerie"   ):SetBlock({||aDadImp[nCont][5]})	    
		oSection2:Cell("cEmissao" ):SetBlock({||aDadImp[nCont][6]})	    
		oSection2:Cell("cConcepto"):SetBlock({||aDadImp[nCont][7]})

		If nTipImp == 1 .Or. nTipImp == 3
			oSection2:Cell("nBase2"	):SetBlock({||aDadImp[nCont][8]})
			oSection2:Cell("nAlq2"	):SetBlock({||aDadImp[nCont][9]})
			oSection2:Cell("nValor2"):SetBlock({||aDadImp[nCont][10]})
			oSection2:Cell("nBase3"	):SetBlock({||aDadImp[nCont][11]})
			oSection2:Cell("nAlq3"	):SetBlock({||aDadImp[nCont][12]})	    
			oSection2:Cell("nValor3"):SetBlock({||aDadImp[nCont][13]})
			oSection2:Cell("nBase4"	):SetBlock({||aDadImp[nCont][14]})
			oSection2:Cell("nAlq4"	):SetBlock({||aDadImp[nCont][15]})	    
			oSection2:Cell("nValor4"):SetBlock({||aDadImp[nCont][16]})
		EndIf	

		If nTipImp == 2 .Or. nTipImp == 3		
			oSection2:Cell("nBase6"	):SetBlock({||aDadImp[nCont][17]})
			oSection2:Cell("nAlq6"	):SetBlock({||aDadImp[nCont][18]})	    
			oSection2:Cell("nValor6"):SetBlock({||aDadImp[nCont][19]})
		EndIf
		oSection2:PrintLine()
	Next

	oSection2:Finish()
	oSection1:Finish()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FISA15F2   ³ Autor ³ Alfredo Medrano       ³ Data ³18/05/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ consulta que incluye SF2 para las notas de credito Colombia  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FISA15F2()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ N/A                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ clQryTl = cadena con  Query                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³FISA015()                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FISA15F2()

	Local clQryTl	:= ""

	clQryTl := " UNION "
	clQryTl += " SELECT '  ' AS OK, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA "
	clQryTl += ", F2_EMISSAO, F2_DTDIGIT, F2_VALBRUT, F3_VALIMP1, F3_VALIMP2 "
	clQryTl += ", F3_VALIMP7, F3_VALIMP4, F3_BASIMP1, F3_BASIMP4, F3_BASIMP7 "
	clQryTl += ", F3_ALQIMP2, F3_ALQIMP4, F3_ALQIMP7, F4_TIPORET, F3_CFO, '2' F_TIPO, F3_ESPECIE "
	clQryTl += IIf( MV_PAR01 == 2,",CC2_CODMUN, CC2_MUN","") //ICA
	clQryTl += " FROM "+RetSqlName("SF2")+" SF2"
	clQryTl += " INNER JOIN "+RetSqlName("SF3")+" SF3"
	clQryTl += " ON SF3.D_E_L_E_T_ = ' ' AND F3_FILIAL = '" +xFilial("SF3")+"' AND F3_CLIEFOR = F2_CLIENTE "
	clQryTl += " AND F3_LOJA	= F2_LOJA AND F3_NFISCAL	= F2_DOC AND F3_SERIE = F2_SERIE "
	//NDI = Nota de débito interna. NCP = Nota de crédito proveedor
	clQryTl += " AND F3_ESPECIE IN ('"+PADR("NCP",TamSx3("F3_ESPECIE")[1])+"', '"+PADR("NDI",TamSx3("F3_ESPECIE")[1])+"')  "
	If MV_PAR01 == 1
		clQryTl += " AND F3_VALIMP2 >0 "
	ElseIf MV_PAR01 == 2
		clQryTl += " AND F3_VALIMP7 >0 "
	Else
		clQryTl += " AND F3_VALIMP4 >0 "
	EndIf
	clQryTl += " LEFT JOIN "+RetSqlName("SFE")+" SFE"
	clQryTl += " ON SFE.D_E_L_E_T_ = ' '"
	clQryTl += " AND FE_FILIAL = '" + xFilial("SFE") + "'"

	If MV_PAR01 == 1   
		clQryTl += " AND FE_TIPO = 'I' "
	ElseIf MV_PAR01 == 2    
		clQryTl += " AND FE_TIPO = 'C' "
	ElseIf MV_PAR01 == 3    
		clQryTl += " AND FE_TIPO = 'F' "
	EndIf

	clQryTl += " AND FE_FORNECE	= F2_CLIENTE "
	clQryTl += " AND FE_LOJA	= F2_LOJA "
	clQryTl += " AND FE_NFISCAL	= F2_DOC "
	clQryTl += " AND FE_SERIE	= F2_SERIE "			   
	
	clQryTl += IIf( MV_PAR01 == 2," INNER JOIN "+RetSqlName("CC2") + " CC2 ON SF2.F2_CODMUN = CC2.CC2_CODMUN ", "")//ICA
			
	clQryTl += " LEFT JOIN "+RetSqlName("SF4") + " SF4"
	clQryTl += " ON SF4.D_E_L_E_T_ = ' ' "
	clQryTl += " AND F4_FILIAL	= F3_FILIAL "
	clQryTl += " AND F4_CODIGO	= F3_TES "
	// clQryTl += " AND F4_CF 		= F3_CFO "
	clQryTl += " WHERE SF2.D_E_L_E_T_ = ' '"
	clQryTl += " AND F2_EMISSAO BETWEEN'" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "'"
	clQryTl += " AND F2_FILIAL = '" +xFilial("SF2")+"'"
	If MV_PAR01 == 1
		clQryTl += " AND F2_VALIMP2 > 0 "
	ElseIf MV_PAR01 == 2
		clQryTl += " AND F2_VALIMP7 > 0 "
	Else
		clQryTl += " AND F2_VALIMP4 > 0 "
	EndIf
	clQryTl += " AND F2_CLIENTE >= '"	+ MV_PAR04 + "'"
	clQryTl += " AND F2_LOJA >= '" 		+ MV_PAR05 + "'"
	clQryTl += " AND F2_CLIENTE <= '" 	+ MV_PAR06 + "'"
	clQryTl += " AND F2_LOJA <= '" 		+ MV_PAR07 + "'"
	clQryTl += " AND FE_FORNECE IS NULL "
	clQryTl += " AND FE_LOJA IS NULL "
	clQryTl += " AND FE_NFISCAL IS NULL "
	clQryTl += " AND FE_SERIE IS NULL "

	clQryTl += " ) UNQRY" //fin de Union

Return clQryTl

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FIS015GR   ³ Autor ³ Alfredo Medrano       ³ Data ³18/05/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Agrupa y suma por Código Fiscal las Facturas y               ³±±
±±³          ³ notas de débito del proveedor, se restan las notas de Credito³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FIS015GR(ExpA1)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array con Facturas y notas obtenidas por el filtro   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aCeRetS = Array con Fact/notas debito y credito agrupadas    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³FGrvCrt() Y FISA015()                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FIS015GR(alDados)
	Local nTam 	:= 0
	Local nTamC	:= 0
	Local nX		:= 0
	Local nY		:= 0
	Local nlX 	:= 0
	Local nValT	:= 0
	Local nValR	:= 0
	Local nValOp := 0
	Local nPosVal	:= 0
	Local nTasa := 0
	Local cClien	:= ""
	Local cTiend	:= "" 
	Local cTipo	:= ""
	Local cCOF	:= ""
	Local clDatS	:= ""
	Local cEspec	:= ""
	Local cCodMun	:= ""
	Local aNCProv:= {}
	Local aCeRetS:= {}
	
	Default alDados := {}
	
	nTam := Len(alDados)
	
	If nTipImp == 1 //IVA
		ASORT(alDados,,,{|x,y| x[3]+x[4]+x[15]+Str(x[9])+x[14] < y[3]+y[4]+y[15]+Str(y[9])+y[14]})  //CLIENTE + TIENDA +  TASA + TIPO DOCTO (ENTRADA/SALIDA) + CODIGO FISCAL
	ElseIf nTipImp == 2 //ICA
		ASORT(alDados,,,{|x,y| x[3]+x[4]+x[18]+Str(x[9])+x[15]+x[14] < y[3]+y[4]+y[18]+Str(y[9])+y[15]+y[14]})  //CLIENTE + TIENDA + COD MUN + TASA + TIPO DOCTO (ENTRADA/SALIDA) + CODIGO FISCAL 
	Else //FUENTE				
		ASORT(alDados,,,{|x,y| x[3]+x[4]+x[15]+x[14] < y[3]+y[4]+y[15]+y[14]}) //ORDENA POR CLIENTE + TIENDA +  TIPO DOCTO (ENTRADA/SALIDA) + CODIGO FISCAL
	EndIf

	// AGRUPAN Y SUMAN POR CONCEPTO
	For nX := 1 to nTam
		clDatS	:= SubStr(DtoS(alDados[nX][2]),5,2)+"/"+SubStr(DtoS(alDados[nX][2]),1,4)
		cClien	:= alDados[nX][3]
		cTiend	:= alDados[nX][4] 
		cTipo	:= alDados[nX][15]
		cCOF	:= alDados[nX][14]
		nTasa	:= alDados[nX][9]
		cCodMun	:= alDados[nX][18]
		cEspec := PADR(alDados[nX][16],TamSx3("FE_ESPECIE")[1])
	
		If nTipImp == 1 //IVA 
	
			While cClien == alDados[nX][3] .and. cTiend == alDados[nX][4] .and. cTipo== alDados[nX][15] .and.  nTasa == alDados[nX][9]// verifica  CLIENTE, TIENDA Y  TIPO DOCTO (ENTRADA = 1 / SALIDA = 2)
				
					nValT := nValT + alDados[nX][8]
					nValR := nValR + alDados[nX][12]
					nValOp:= nValOp + alDados[nX][11]
			
				nlX++
				nX++
				
				If nX > Len(alDados)
			   		Exit
				EndIf
				
			EndDo
		
		ElseIf nTipImp == 2 // ICA
		
			While cClien == alDados[nX][3] .and. cTiend == alDados[nX][4] .and. cTipo== alDados[nX][15] .and. cCodMun == alDados[nX][18] .and.  nTasa == alDados[nX][9]  // verifica  CLIENTE, TIENDA MUNICIPIO Y  TIPO DOCTO (ENTRADA = 1 / SALIDA = 2)
				
					nValT := nValT + alDados[nX][8]
					nValR := nValR + alDados[nX][12]
					nValOp:= nValOp + alDados[nX][11]
			
				nlX++
				nX++
				
				If nX > Len(alDados)
			   		Exit
				EndIf
				
			EndDo

		Else // FUENTE
			While cClien == alDados[nX][3] .and. cTiend == alDados[nX][4] .and. cTipo== alDados[nX][15] .and. cCOF== alDados[nX][14]  // verifica  CLIENTE, TIENDA,  TIPO DOCTO (ENTRADA = 1 / SALIDA = 2) Y CODIGO FISCAL
			
				nValT := nValT + alDados[nX][8]
				nValR := nValR + alDados[nX][12]
				
				nlX++
				nX++
				
				If nX > Len(alDados)
			   		Exit
				EndIf
				
			EndDo
		EndIf
		nX := nlX
		// NCP = NOTA DE CREDITO DEL PROVEEDOR.  NDI = NOTA DE DEBITO INTERNA   	
		If PADR(alDados[nX][16],TamSx3("FE_ESPECIE")[1]) != PADR('NCP',TamSx3("FE_ESPECIE")[1]) .AND. PADR(alDados[nX][16],TamSx3("FE_ESPECIE")[1]) != PADR('NDI',TamSx3("FE_ESPECIE")[1])  
		// Factura entrada Proveedor y nota de debito
			aadd(aCeRetS,{alDados[nX][1],;	// [1]	Numero Certificado
			alDados[nX][2],;	// [2]	Data Emissao
			alDados[nX][3],;	// [3]	Codigo do Fornecedor
			alDados[nX][4],;	// [4]	Loja
			alDados[nX][5],;	// [5]	Tipo
			alDados[nX][6],;	// [6]	Numero da fatura
			alDados[nX][7],;	// [7]	Serie da fatura
			nValT,;			// [8]	Base de calculo da retenção
			alDados[nX][9],;	// [9]	Aliquota para o Calculo
			alDados[nX][10],;	// [10]Filial que está gerando o certificado
			nValOp,;			// [11]Valor do imposto da retenção
			nValR,;			// [12]Valor da retenção
			alDados[nX][13],;	// [13]Codigo Fiscal da Operação
			alDados[nX][14],;	// [14]Colombia Codigo Fiscal
			alDados[nX][15],;	// [15] Colombia Tipo doc 1= Entrada 2 =salida
			IIf(nTipImp == 3,FIS015VS(alDados[nX][14]), ""),;   // [16] Colombia Codigos Fiscales de Salida
			"",;  // [17] Tipo (C-Cliente\F-Fornecedor)
			alDados[nX][18],; //[18] Cod Munic
			alDados[nX][19]}) // [19] Municipio
			
		Else
		// Notas Credito
			aadd(aNCProv, {;
				alDados[nX][3],;	// [1]	Codigo do Fornecedor
				alDados[nX][15],;	// [2] Colombia Tipo doc 1= Entrada 2 =salida
				alDados[nX][4],; 	// [3]	Loja
				nValT,;			    // [4]	Base de calculo da retenção
				nValR,;			    // [5]	Valor da retenção
				alDados[nX][14],;   // [6] Colombia Codigo Fiscal
				alDados[nX][6],;    // [7] Numero da fatura
				nValOp,;			// [8]Valor do imposto da retenção
				alDados[nX][9],;	// [9]	Aliquota para o Calculo
				alDados[nX][18];	// [10]	Cod. Mun
				})	
		EndIf
	
		nValT := 0
		nValR := 0
		nValOp:= 0
	
	Next 

	nTam := Len(aCeRetS)
	nTamC := Len(aNCProv)
	nlX := 0
	If nTamC > 0 .and. nTam > 0 
			
		If nTipImp == 1 // IVA		
			For nX := 1 to nTam	
				cClien	:= aCeRetS[nX][3]
				cTiend	:= aCeRetS[nX][4] 
				nTasa   := aCeRetS[nX][9]
				For nY := 1 to nTamC
					If cClien == aNCProv[nY][1] .and. cTiend == aNCProv[nY][3] .and. nTasa == aNCProv[nY][9] 
						aCeRetS[nX][8] := aCeRetS[nX][8] - aNCProv[nY][4] //resta notas credito proveedor
						aCeRetS[nX][11] := aCeRetS[nX][11] - aNCProv[nY][8] //resta Iva Operacion, solo se mostrara en Reporte IVA
						aCeRetS[nX][12]:= aCeRetS[nX][12] - aNCProv[nY][5] 
					EndIf
				Next 				
			Next
		ElseIf nTipImp == 2  // ICA		
			For nX := 1 to nTam	
				cClien	:= aCeRetS[nX][3]
				cTiend	:= aCeRetS[nX][4] 
				nTasa   := aCeRetS[nX][9]
				cCodMun	:= aCeRetS[nX][18]
				For nY := 1 to nTamC
					If cClien == aNCProv[nY][1] .and. cTiend == aNCProv[nY][3] .and. nTasa == aNCProv[nY][9] .and. cCodMun == aNCProv[nY][10]
						aCeRetS[nX][8] := aCeRetS[nX][8] - aNCProv[nY][4] //resta notas credito proveedor
						aCeRetS[nX][11] := aCeRetS[nX][11] - aNCProv[nY][8] //resta Iva Operacion, solo se mostrara en Reporte IVA
						aCeRetS[nX][12]:= aCeRetS[nX][12] - aNCProv[nY][5] 
					EndIf
				Next 				
			Next									
		Else //FUENTE
		//Se Resta el valor de la Nota de Crédito mediante la configuración de la relación de códigos Fiscales	
			For nX := 1 to nTam
				cClien	:= aCeRetS[nX][3]
				cTiend	:= aCeRetS[nX][4] 
				For nY := 1 to nTamC
					If cClien == aNCProv[nY][1] .and. cTiend == aNCProv[nY][3]
						nPosVal:= aScan(aNCProv,{|x| x[1] == cClien .AND. x[3] == cTiend .AND. x[6] $ aCeRetS[nX][16] .AND. x[7] == aNCProv[nY][7]  }) //CLIENTE Y TIENDA Y COF SALIDA
						IF nPosVal > 0
							aCeRetS[nX][8] := aCeRetS[nX][8] - aNCProv[nPosVal][4]
							aCeRetS[nX][12]:= aCeRetS[nX][12] - aNCProv[nPosVal][5] 
						EndIF
					EndIf
				Next 				
			Next
	
		EndIf
			
	EndIf

Return aCeRetS

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FIS015VS   ³ Autor ³ Alfredo Medrano       ³ Data ³18/05/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Obtiene los Cod. Fiscales relacionados al Cod. Fiscal        ³±±
±±³          ³ de la Factura de Entrada.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FIS015VS(ExpC1)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo Fiscal de Entrada                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cCOFS = Cadena con Cod Fiscales                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³FGrvCrt() Y FISA015()                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FIS015VS(cConc)

	Local aArea		:= GetArea()
	Local cFilCWF	:= xFilial('CWF')
	Local cCOFS		:= ""

	If !Empty(cConc) 
		dbselectArea('CWF')
		CWF->(DbSetOrder(1))  
		CWF->(DbSeek(xFilial('CWF')+cConc)) //CWF_FILIAL+CWF_COFIEN+CWF_COFISA
		While CWF->(!Eof()) .And. cFilCWF == CWF->CWF_FILIAL .And. PADR(CWF->CWF_COFIEN, TamSx3("FE_CFO")[1]) == PADR(cConc, TamSx3("FE_CFO")[1])
			cCOFS += CWF->CWF_COFISA + "|"
			CWF->(DbSkip())
		EndDo
	EndIf

	RestArea(aArea)

Return cCOFS

//Si la tes contiene el impuesto Barcelona
 Static Function ImpBAR(cTes)
 Local lRet:= .f.
 Local cTmpFil:=''
 
 SFC->(DBSETORDER(1)) //FC_FILIAL+FC_TES+FC_SEQ+FC_IMPOSTO
 IF SFC->(MSSEEK(XFILIAL("SFC")+cTes))
    cTmpFil:=XFILIAL("SFC")
    DO WHILE XFILIAL("SFC")==cTmpFil .and. SFC->FC_TES==cTes
    	IF SFC->FC_IMPOSTO=="BAR"
    		lRet:= .T.
    		exit
    	ENDIF
    	SFC->(dbskip())
    ENDDO		
 ENDIF
 Return lRet

/*
Valida concurrencia en consecutivo de Certificado de retención
*/
Static Function VerConsCER(cImpX5)
Local aArea	:= GetArea()
Local lRet		:= .T.
Local cTipoPr 	:= "" 
Local cAliasQry	:= GetNextAlias()

If cImpX5 != "" 
	cTipoPr := "% FE_TIPO IN ('I','R')%"

	BeginSql Alias cAliasQry
		SELECT
			FE_NROCERT
		FROM
			%table:SFE% 
		WHERE
			FE_NROCERT =  %exp:cImpX5% AND %exp:cTipoPr% AND
			%notDel%
	EndSql

	If (cAliasQry)->(!Eof())
		lRet :=.F.
	EndIf
	(cAliasQry)->(DbCloseArea())
EndIf
RestArea(aArea)
Return lRet

/*/{Protheus.doc} LxMetFS015
Metríca para verificar cantidad de certificados registrados por país por empresa.
@type
@author Alfredo.Medrano
@since 25/11/2021
@version 1.0
@example
LxMetFS015()
@see (links_or_references)
/*/
Function LxMetFS015()
	Local cIdMetric	  := ""
	Local cSubRoutine := ""
	Local lMetVal     := (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')
	Local cAutomato   := IIf(GetRemoteType() == 5 .OR. IsBlind(), "_auto", "") //Si es ejecución automática con TIR agrega identificador
	Local cRotina := "FISA015"
	If lMetVal
		cSubRoutine :=  "Certificado_retencion_" + cPaisLoc + cAutomato
		cIdMetric	:= "fiscal-protheus_cantidad-de-certificados-de-retencios-registrados-por-FISA015-por-pais-por-empresa_total"
		FWCustomMetrics():setSumMetric(cSubRoutine, cIdMetric, 1,/*dDate*/, /*nLapTime*/,cRotina)
	EndIf

Return Nil

/*/{Protheus.doc} F015STCREQ
Consulta de estatus del Cert. de Retención ante SRI con Proveedor Tecnológico Stupendo.
@type
@author luis.enriquez
@since 10/03/2022
@version 1.0
@param cCerRet, Caracter - el Folio del Certificado de Retención
@return cStatusCR, Caracter - Código del estatus del Cert. de Retención ante SRI
@example
(examples)
@see (links_or_references)
/*/
Function F015STCREQ(cCerRet)
	Local oWS       := Nil
	Local aDatosSM0 := FWSM0Util():GetSM0Data( cEmpAnt, cFilAnt , {"M0_CGC","M0_DSCCNA"} ) 
	Local cEstabl   := Substr(Alltrim(aDatosSM0[2][2]),1,3)
	Local cPtoEmis  := Substr(Alltrim(aDatosSM0[2][2]),4,3)
	Local nTamDoc 	:= TamSX3("F2_DOC")[1]
	Local cUrl      := M486GETPAR(2)
	Local cStatusCR := ""   

	oWS := WSConsultaDocumentoSoap():NEW()
	oWS:cRucEmpresa := Alltrim(aDatosSM0[1][2])
	oWS:cTipoDocumento   := "07" //Certificado de Retención
	oWS:cEstablecimiento := cEstabl
	oWS:cPtoEmision      := cPtoEmis
	oWS:cSecuencial      := Alltrim(Substr(cCerRet,(nTamDoc-8),9))
	oWS:cNombreArchivo   := "RET" + Alltrim(aDatosSM0[2][2]) + cCerRet + ".XML"
	oWS:_URL		     := cURL
	If oWS:wsConsultaDocumento()
		cStatusCR := oWS:cEstado
	Else
		cMsj := GetWSCError()
		MsgAlert(cMsj,STR0055) //"Atención"
	EndIf
Return cStatusCR

/*/{Protheus.doc} F015MsgObs
Muestra las observaciones en una lista de texto.
@type
@author luis.enriquez
@since 05/06/2020
@version 1.0
@param cMsg, Caracter - Mensaje de Certificasdos borrados, que no se permite borrar o se anuló el proceso
@return Nil
@example
(examples)
@see (links_or_references)
/*/
Function F015MsgObs(cMsg)
	Local oDlg    := Nil
	Local oMemo   := Nil
	Local oButton := Nil

	Default cMsg := ""
	
	CURSORWAIT()
	
	CURSORARROW()
	DEFINE MSDIALOG oDlg FROM 0,0 TO 390,440 PIXEL TITLE STR0062 //"LOG DE PROCESO DE CERTIFICADOS DE RETENCIÓN"
	oDlg:lMaximized := .F.
	oMemo := tMultiget():New(20,05,{|u|IIf(Pcount() > 0, cMsg:=u, cMsg)} ,oDlg,213,155,,.T.,,,,.T.,,,,,,.T.,,,,,.T.)	
	oButton := TButton():New(177, 187,STR0063,oDlg,{||oDlg:End()},30,15,,,,.T.) //"Salir"
	ACTIVATE MSDIALOG oDlg CENTERED	
Return Nil

/*/{Protheus.doc} F015GenMsg
Genera string de mensaje para LOG del proceso de Borrado de Certificados de Retención
@type
@author luis.enriquez
@since 05/06/2020
@version 1.0
@param aCRBorra, array que contiene los Certificados de Retención Borrados
@param aCRProc, array que contiene los Certificados de Retención no anulados ante SRI
@param aCRAnul, array que contiene los Certificados de Retención que se canceló el proceso de borrado
@return cCRMsgRet, string con mensjae para log del proceso de Borrado de Certificados de Retención
@example
(examples)
@see (links_or_references)
/*/
Static Function F015GenMsg(aCRBorra,aCRProc,aCRAnul)
	Local cCRMsgRet := ""
	Local nP        := 0
	Local cCtrl     := (chr(13)+chr(10)) 

	Default aCRBorra := {}
	Default aCRProc  := {}
	Default aCRAnul  := {}

	If Len(aCRBorra) > 0
		cCRMsgRet += STR0057 + cCtrl //"Los siguientes Certificados de Retención fueron borrados con éxito:"
		For nP := 1 To Len(aCRBorra)
			cCRMsgRet += cCtrl + aCRBorra[nP][1] 
		Next nP	
	EndIf
	If Len(aCRProc) > 0
		cCRMsgRet += IIf(!Empty(cCRMsgRet),cCtrl + cCtrl,"") + STR0058 + cCtrl //"Los siguientes Certificados de Retención, no han sido dado de baja ante el SRI y no se permitirá darlos de baja en el sistema:"
		For nP := 1 To Len(aCRProc)
			cCRMsgRet += cCtrl + aCRProc[nP][1] 
		Next nP				
	EndIf
	If Len(aCRAnul) > 0 
		cCRMsgRet += IIf(!Empty(cCRMsgRet),cCtrl + cCtrl,"") + STR0059 + cCtrl //"Se anuló el proceso de Borrado de los siguientes Certificados de Retención:"
		For nP := 1 To Len(aCRAnul)
			cCRMsgRet += cCtrl + aCRAnul[nP][1] 
		Next nP							
	EndIf
Return cCRMsgRet
