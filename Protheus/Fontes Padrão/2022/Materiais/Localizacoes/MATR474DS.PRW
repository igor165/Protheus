#include "protheus.ch"
#include "Birtdataset.ch"
#Include "MATR474.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR474DS³ Autor ³Mayra Camargo          ³ Data ³ 23/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Data set de nota de cargo en formato birt.   	           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±³            ³        ³      ³                                          ³±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
dataset m474ds
	Title STR0001// "Datos Nota Cargo"
	Description STR0002 // "Datos Nota Cargo"
	PERGUNTE "MATR474"

Columns
	define Column A1_NOME 		like A1_NOME
	define Column A1_END 		like A1_END
	define Column A1_NR_END		TYPE CHARACTER SIZE 10 DECIMALS 0 LABEL STR0015 // 'A1_NR_END'
	define Column A1_NROINT		TYPE CHARACTER SIZE 10 DECIMALS 0 LABEL STR0016 // 'A1_NROINT'
	define Column A1_BAIRRO		like A1_BAIRRO
	define Column A1_MUN			like A1_MUN
	define Column A1_PAISDES 	TYPE CHARACTER SIZE 40 DECIMALS 0 LABEL "A1_PAISDES"
	define Column A1_EST			TYPE CHARACTER SIZE 40 DECIMALS 0 LABEL "A1_EST"
	define column A1_CEP			like A1_CEP
	define Column A1_CGC			like A1_CGC
	define Column F2_DOC			like F2_DOC
	define Column F2_SERIE		TYPE CHARACTER size 03 label STR0009//"Serie: " //like F2_SERIE	alterado em 23/04/15 PRJ Chave Unica	
	define Column F2_CLIENTE		like F2_CLIENTE
	define Column F2_LOJA		like F2_LOJA
	define Column F2_EMISSA		TYPE CHARACTER SIZE	10	DECIMALS 0 LABEL STR0012
	define Column D2_QUANT		like D2_QUANT
	define column D2_UM			like D2_UM
	define column B1_COD			like B1_COD
	define Column B1_DESC		like B1_DESC
	define Column D2_NFORI		like D2_NFORI
	define Column D2_SERIORI	TYPE CHARACTER size 03 label STR0009 //"Serie: " //like D2_SERIORI	 alterado em 23/04/15 PRJ Chave Unica
	define Column D2_NUMLOTE		like D2_NUMLOTE
	define Column D2_LOTECTL 	like D2_LOTECTL
	define column D2_DTVALID		TYPE CHARACTER SIZE	10	DECIMALS 0
	define Column D2_PRCVEN		like D2_PRCVEN
	define Column D2_TOTAL		like D2_TOTAL
	define Column F2_VALMERC 	like F2_VALMERC
	define Column F2_VALBRUT		like F2_VALBRUT
	define Column TOTALCAR		TYPE CHARACTER SIZE 250 DECIMALS 0
	define Column Impuestos		TYPE CHARACTER SIZE 450 DECIMALS 0 label STR0013 	// 'IMPUESTOS'
	define column ValImp  		type CHARACTER size 450 decimals 0 label STR0014		// "VALIMP"
	define Column CERTSAT 		type CHARACTER size 100 decimals 0 label STR0017   // 'CERTSAT'
	define column CERTDIG		type CHARACTER size 100 decimals 0 label STR0018 	// 'CERTDIG'
	define column CADORI			type CHARACTER size 450 decimals 0 label STR0019		// 'CADORI'
	define column SELLOCFDI		type CHARACTER size 450 decimals 0 label STR0020		// 'SELLOCFDI'
	define column SELLOSAT		type CHARACTER size 450 decimals 0 label STR0021		// 'SELLOSAT'
	define column FECTIM			type CHARACTER size 10	decimals 0 label STR0022		// 'FECTIM'
	define column FOLIOFIS		type CHARACTER size 100	decimals 0 label STR0023		// 'FOLIOFIS'
	define column IMAGE         type character size 20   label "Imagen"

define query 	"SELECT A1_NOME,A1_END,A1_NR_END,A1_NROINT,A1_BAIRRO,A1_PAISDES,A1_EST,A1_CEP,A1_CGC,A1_MUN, " + ;
				"F2_DOC,F2_SERIE,F2_CLIENTE,F2_LOJA,F2_EMISSA,F2_VALMERC,F2_VALBRUT, IMAGE, "+;
				"D2_QUANT,D2_UM,B1_COD,B1_DESC,D2_NFORI,D2_SERIORI,D2_NUMLOTE,D2_LOTECTL, "+;
				"D2_DTVALID,D2_PRCVEN,D2_TOTAL,TOTALCAR,IMPUESTOS,VALIMP,CERTSAT,CERTDIG,CADORI,SELLOSAT,SELLOCFDI,FECTIM,FOLIOFIS " +;
				"FROM %WTable:1% "

process dataset
	local cWTabAlias
	local cnt     := 0
	local lRet 	:= .f.
	Local cExp    := ""
	Local cNotIni	:= self:execParamValue("MV_PAR01")
	Local cNotFin	:= self:execParamValue("MV_PAR02")
	Local cSerie	:= self:execParamValue("MV_PAR03")

   if ::isPreview()
       //utilize este método para verificar se esta em modo de preview
       //e assim evitar algum processamento, por exemplo atualização
       //em atributos das tabelas utilizadas durante o processamento
   endif

    //cria a tabela
   cWTabAlias := ::createWorkTable()
   chkFile("SA1")

	Processa({|_lEnd| lRet := X60NOT(cWTabAlias,cNotIni,cNotFin,cSerie)}, ::title())

	if !lRet
		cExp := STR0006 //"No existen dados para la condición de selección."
		MsgInfo(STR0006)
	ELSE
		MsgInfo(STR0024)
	endif

return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ X60NOT   ³ Autor ³ Mayra Camargo         ³ Data ³20/05/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Obtiene datos de la nota de cargo      					    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ X60NOT(cAliasMov, cFacIni,cFacFin,cSerie)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR474DS                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAliasMov.- Tabla temporal del DS                          ³±±
±±³          ³ cFacIni.- Nota Inicio                                      ³±±
±±³          ³ cFacFin.- Nota Fin                                         ³±±
±±³          ³ cSerie.- serie de la nota                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static function X60NOT(cAliasMov, cFacIni,cFacFin,cSerie)
	Local aArea   := getArea()
	local nCount 	:= 0
	LOCAL nI		:= 0
	local cFilSA1	:= xFilial("SA1")
	Local cFilSF2	:= xFilial("SF2")
	Local cfilSD2	:= xFilial("SD2")
	Local cFilSB1	:= xfilial("SB1")
	Local cAlias	:= getNextAlias()
	Local cCond	:= "%%"
	Local dFecEmi	:= CTOD(" / / ")
	Local dDtValid:= ddatabase
	Local cDesc	:= ""
	Local cVal	:= ""
	Local lImp := .F.
	Local cSelect	:= "%%"
	Local cFactAnt:= ""
	Local cFileN := ""
	Local oXML 	:= Nil
	Local cAviso := ""
	Local cErro	:= ""
	Local cCaminhoXML:= ""
	Local lTim	:= .F.
	Local cCerSAT	:= ""
	Local cCerEmi	:= ""
	Local cCadOri	:= ""
	Local cSelloCFD	:= ""
	Local cSelloSAT	:= ""
	Local cFechaTim	:= ""
	Local cUUIDTim 	:= ""
	Local cParName	:= "" //  Nombre XML de la factura de venta para México
	Local cSDoc	 := SerieNFID("SF2", 3, "F2_SERIE")//incluido em 23/04/2015 projeto chave unica

	//Pergunte("MATR552",.F.)
	cFacIni :=strtran(cFacIni,'"',"")
	cFacFin :=strtran(cFacFin,'"',"")
	cSerie  :=strtran(cSerie,'"',"")

	If cPaisLoc == "MEX"
		cCond 	:= "%AND SF2.F2_TIMBRE <> ' ' %"
		cSelecT:= "%SA1.A1_NR_END,SA1.A1_NROINT,%"
	EndIF

	BeginSql alias cAlias
		SELECT
			SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_EMISSAO,SF2.F2_CLIENTE,SF2.F2_LOJA,
			SF2.F2_EMISSAO,SF2.F2_VALBRUT,SF2.F2_VALMERC,F2_COND,SF2.F2_ESPECIE,
			SA1.A1_NOME,SA1.A1_END,%EXP:cSelect%
			SA1.A1_BAIRRO, SA1.A1_EST,SA1.A1_MUN,
			SA1.A1_PAIS,SA1.A1_CEP,SA1.A1_CGC,
			SD2.D2_QUANT, SD2.D2_UM,SD2.D2_PRCVEN,SD2.D2_TOTAL,
			SD2.D2_REMITO,SD2.D2_SERIREM,SD2.D2_COD,SD2.D2_NUMLOTE,
			SD2.D2_LOTECTL,SD2.D2_DTVALID,
			SB1.B1_DESC
		FROM %table:SA1% SA1 INNER JOIN %table:SF2% SF2 on
			SA1.A1_COD=SF2.F2_CLIENTE AND SA1.A1_LOJA=SF2.F2_LOJA
			INNER JOIN %table:SD2% SD2
			ON SF2.F2_DOC=SD2.D2_DOC AND SF2.F2_SERIE=SD2.D2_SERIE
			AND SF2.F2_CLIENTE=SD2.D2_CLIENTE AND SF2.F2_LOJA=SD2.D2_LOJA
			INNER JOIN %Table:SB1% SB1 on SD2.D2_COD=SB1.B1_COD
		WHERE SA1.A1_FILIAL=%exp:cFilSA1%
			AND SF2.F2_FILIAL=%exp:cFilSF2%
			AND SD2.D2_FILIAL=%exp:cFilSD2%
			AND SB1.B1_FILIAL=%exp:cFilSB1%
			AND SF2.F2_ESPECIE='NDC'
			AND SA1.%notDel%
			AND SF2.%notDel%
			AND SD2.%notDel% %exp:cCond%
			AND SB1.%notDel%
			AND SF2.%exp:cSDoc%=%exp:cSerie%
			AND SF2.F2_DOC>=%exp:cFacIni%
			AND SF2.F2_DOC<=%exp:cFacFin%
	EndSql

	Count to nCount
	//AND SF2.F2_SERIE=%exp:cSerie% linha origina da query, F2_SERIE substituido por cSDoc - PRJ CHAVE UNICA 23/04/15
	(cAlias)->(dbGotop())
	ProcRegua(nCount)

	While (cAlias)->(!EOF())

		dFecEmi 	:= stod((cAlias)->F2_EMISSAO)
		dDtValid	:= stod((cAlias)->D2_DTVALID)
		Incproc(STR0010 + (cAlias)->F2_DOC+substr((cAlias)->F2_SERIE,1,3)) // "Processando registro #" //(cAlias)->F2_SERIE) alterado 23/04/15 PRJ CHAVE UNICA

		cDesc 	:= ""
		cVal 	:= ""
		// Se obtienes impuestos
		lImp := GetImp((cAlias)->F2_CLIENTE+(cAlias)->F2_LOJA+(cAlias)->F2_DOC+(cAlias)->F2_SERIE , @cDesc, @cVal)

		If cFactAnt <> (cAlias)->F2_CLIENTE+(cAlias)->F2_LOJA+(cAlias)->F2_DOC+(cAlias)->F2_SERIE
			cFactAnt	:= (cAlias)->F2_CLIENTE+(cAlias)->F2_LOJA+(cAlias)->F2_DOC+(cAlias)->F2_SERIE

			// Solo para méxico obtener datos del timbrado del SAT
			IF cPaisLoc $ "MEX"
				//Datos del SAT CFD
				cCaminhoXML := &(GetMv("MV_CFDDOCS"))

				SF2->(dbSetOrder(2))
				SF2->(DbSeek(xFilial("SF2") + (cAlias)->F2_CLIENTE+(cAlias)->F2_LOJA+(cAlias)->F2_DOC+(cAlias)->F2_SERIE))

				cParName:= &(SuperGetmv( "MV_CFDNAF2" , .F. , "" ))
				cFileN	:= cCaminhoXML + cParName

				oXML := XmlParserFile(cFileN, "_", @cAviso,@cErro )

				if ( !Empty(cAviso) .or. !Empty(cErro) )
					lTim :=.F.
				Else
					// Verificar si está timbrado para obtener fecha del TFD.
					if ( XMLChildEx( oXML:_CFDI_COMPROBANTE, "_CFDI_COMPLEMENTO" ) == NIL )
						lTim := .F.
					else
						cFechaTim 	:= oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT
						cFechaTim	:= (SubStr(cFechaTim,9,2)+"-"+SubStr(cFechaTim,6,2)+"-"+SubStr(cFechaTim,1,4))//+" "+SubStr(cFechaTim,12,8))
						cCerSat	:= oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_NOCERTIFICADOSAT:TEXT
						cCerEmi	:= OemToAnsi(oXML:_CFDI_COMPROBANTE:_NOCERTIFICADO:TEXT) // Cer Dig
						cSelloSAT 	:= oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_SELLOSAT:TEXT
						cSelloCFD	:= oXML:_CFDI_COMPROBANTE:_SELLO:TEXT
						cUUIDTim	:= oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT
						cCadOri	:= 	CadCFDI(oXML)
						lTim := .T.
					endif

				endif
			Else

			// Para argentina no aplica por lo que siempre se imprime.
				lTim := .T.
			EndIF
		EndIF

		If lTim			// Si está timbrado se imprime
			RecLock(cAliasMov,.T.)

			(cAliasMov)->F2_CLIENTE	:= (cAlias)->F2_CLIENTE
			(cAliasMov)->F2_LOJA		:= (cAlias)->F2_LOJA
			(cAliasMov)->A1_NOME		:= (cAlias)->A1_NOME
			(cAliasMov)->A1_END		:= (cAlias)->A1_END
			(cAliasMov)->A1_NR_END	:= IIF(cPaisLoc $ "MEX",(cAlias)->A1_NR_END,"")
			(cAliasMov)->A1_NROINT	:= IIF(cPaisLoc $ "MEX",(cAlias)->A1_NROINT,"")
			(cAliasMov)->A1_BAIRRO	:= (cAlias)->A1_BAIRRO
			(cAliasMov)->A1_PAISDES	:= POSICIONE("SYA",1,XFILIAL("SYA")+(cAlias)->A1_PAIS,"YA_DESCR")
			(cAliasMov)->A1_EST		:= POSICIONE("SX5",1,XFILIAL("SX5")+"12"+(cAlias)->A1_EST,"X5_DESCSPA")
			(cAliasMov)->A1_CEP		:= (cAlias)->A1_CEP
			(cAliasMov)->A1_CGC		:= (cAlias)->A1_CGC
			(cAliasMov)->A1_MUN		:= (cAlias)->A1_MUN
			(cAliasMov)->F2_DOC		:= (cAlias)->F2_DOC
			(cAliasMov)->F2_SERIE	:= (cAlias)->F2_SERIE
			(cAliasMov)->F2_EMISSA	:= STRZERO(DAY(dFecEmi),2) + "-" + STRZERO(MONTH(dFecEmi),2) + "-" + STRZERO(YEAR(dFecEmi),4)
			(cAliasMov)->D2_QUANT	:= (cAlias)->D2_QUANT
			(cAliasMov)->D2_UM		:= (cAlias)->D2_UM
			(cAliasMov)->B1_COD		:= (cAlias)->D2_COD
			(cAliasMov)->B1_DESC		:= (cAlias)->B1_DESC
			(cAliasMov)->D2_PRCVEN	:= (cAlias)->D2_PRCVEN
			(cAliasMov)->D2_NFORI	:= (cAlias)->D2_REMITO
			(cAliasMov)->D2_SERIORI	:= (cAlias)->D2_SERIREM
			(cAliasMov)->D2_NUMLOTE	:= (cAlias)->D2_NUMLOTE
			(cAliasMov)->D2_LOTECTL 	:= (cAlias)->D2_LOTECTL
			(cAliasMov)->D2_TOTAL	:= (cAlias)->D2_TOTAL
			(cAliasMov)->D2_DTVALID	:= dtoc(dDtValid)
			(cAliasMov)->F2_VALMERC	:= (cAlias)->F2_VALMERC
			(cAliasMov)->F2_VALBRUT	:= (cAlias)->F2_VALBRUT
			(caliasMov)->TOTALCAR	:= Extenso((cAlias)->F2_VALBRUT,.f.,1)
			(cAliasMov)->IMPUESTOS	:= cDesc
			(cAliasMov)->VALIMP		:= cVal
			(caliasMov)->CERTSAT		:= cCerSat
			(caliasMov)->CERTDIG		:= cCerEmi
			(caliasMov)->CADORI		:= cCaDOri
			(caliasMov)->SELLOCFDI	:= cSelloCFD
			(caliasMov)->SELLOSAT	:= cSelloSAT
			(caliasMov)->FECTIM		:= cFechaTim
			(caliasMov)->FOLIOFIS	:= cUUIDTim
			(caliasMov)->IMAGE		:= "lgrl"+cEmpAnt+".bmp"
			(caliasMov)->(MsUnlock())

		EndIF
		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())
	RestArea(aArea)
return nCount > 0


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CadCFDI  ³ Autor ³ Mayra Camargo         ³ Data ³20/05/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Construye la cadena original del complemento de            ³±±
±±³          ³ certificación del SAT que en el caso de CFDI sustituye a la³±±
±±³          ³ cadena original en la impresión del CFDI.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CadCFDI(oXML)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cExp:= String cadena original                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR474DS                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oExp := Objeto con XML timbrado                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CadCFDI(oXML)
	Local cFechaTim	:= ""
	Local cUUIDTim	:= ""
	Local cCerTim		:= ""
	Local cSelloCFDI	:= ""

	if ( XMLChildEx( oXML:_CFDI_COMPROBANTE, "_CFDI_COMPLEMENTO" ) == NIL )
		cCadOrig := ""
	else
		cFechaTim 	:= oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT
		cUUIDTim 	:= oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT
		cCerTim 	:= oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_NOCERTIFICADOSAT:TEXT
		cSelloCFDI	:= oXML:_CFDI_COMPROBANTE:_SELLO:TEXT

		cCadOrig := "||"
		cCadOrig += "1.0|" 				//	Version
		cCadOrig += cUUIDTim + "|"		// 	UUID
		cCadOrig += cFechaTim + "|"		// 	Fecha y hora de certificación
		cCadOrig += cSelloCFDI + "|"	// 	Sello digital del CFDI
		cCadOrig += cCerTim + "||"		//	Número de certificado
	endif
Return cCadOrig

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ GetImp   ³ Autor ³ Mayra Camargo         ³ Data ³20/05/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Obtiene impuestos de la nota de cargo.						    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GetImp(cClave,cDesc,cVal)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR474DS                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1:= Clave de la factura                                ³±±
±±³          ³ cExp2:= Por referencia cadena con desccripción a retornar  ³±±
±±³          ³ cExp3:= Por referencia cadena con valores de imp a retornar³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static function GetImp(cClave,cDesc,cVal)
	Local aArea   := getArea()
	Local aImp    := {}
	Local nValImp := 0
	Local nPor    := 0
	Local nBasImp := 0
	Local cImp    := ""
	Local nX      := 0

		SF3->(dbSelectArea("SF3"))
		SFC->(dbSelectArea("SFC"))

		SF3->(dbSetOrder(4))
		SFC->(dbSetOrder(1))

		SF3->(dbGotop())

		IF SF3->(DbSeek(xFilial("SF3") + cClave))
			While SF3->(!EOF()) .and. SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE == cClave
				IF SFC->(DbSeek(xFilial("SFC") + SF3->F3_TES))
					While !(SFC->(Eof())) .and. SFC->FC_TES == SF3->F3_TES
						IF aScan(aImp,{|x| x == SFC->FC_IMPOSTO}) == 0
							AADD(aImp,SFC->FC_IMPOSTO)
						EndIF
						SFC->(DBSKIP())
					ENDDO
				ENDIF
				SFC->(dbGotop())
				SF3->(dbSkip())
			EndDo
		ENDIF

		SF3->(dbCloseArea())
		SFC->(dbCloseArea())

		//impuestos.
		SFB->(dbSelectArea("SFB"))
		SFB->(dbSetOrder(1))

		for nX :=1 to Len(aImp)
			SFB->(dbGotop())
			IF SFB->(DbSeek(xFilial("SFB") + aImp[nX]))
				cImp := SFB->FB_CPOLVRO
				nPor := SFB->FB_ALIQ
				nBasImp := POSICIONE("SF2",2,xfilial("SF2")+cClave,"F2_BASIMP" +cImp)
				nValImp := POSICIONE("SF2",2,xfilial("SF2")+cClave,"F2_VALIMP" +cImp)

				IF nBasImp > 0
					cDesc	+= alltrim(SFB->FB_CODIGO) + " " + TRANSFORM(nPor,"999.99")+ " % (" + STR0008 + TRANSFORM(nBasImp,"999,999.99") +")" +CHR(13)+CHR(10)
					cVal	+=  TRANSFORM(nValImp,"999,999.99") + CHR(13)+CHR(10)
				EndIF

			ENDIF
		next

		SFB->(dbCloseArea())

	RestArea(aArea)
return .T.
