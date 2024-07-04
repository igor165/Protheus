#INCLUDE 'FISR505.CH'

#DEFINE cCRLF CHR(13)+CHR(10)
/*/{Protheus.doc} FISR505
    Rutina de Generación Medios Magnéticos Distritales Articulos 2,3,4 y 6 
    @type  Function
    @author eduardo.manriquez
    @since 02/05/2022
    @version 1.0
    @param 
    @return 
    @example
    FISR505()
    @see (links_or_references)
    /*/
 Function FISR505()
    Local aSays     := {}
    Local aButtons  := {}
    Local cCadastro := STR0001	//"MEDIOS MAGNETICOS DISTRITALES (BOGOTA)"
    Local cDescr    := STR0002 	//"Generación de Medios Magneticos Distritales:"

    Private cPerg	:= "FISR505"
    Private lAutomato := isblind()
    Private lGerOk  := .F.
    Private aError  := {}

    Pergunte(cPerg,.F.)

    aSays :={cDescr,OemToAnsi(STR0003); // "Articulo 2 -Información de compras de bienes y/o servicios"
            ,OemToAnsi(STR0004); // "Articulo 3 - Ventas de bienes."
            ,OemToAnsi(STR0005); // "Articulo 4 - Información de retenciones ICA practicadas."
            ,OemToAnsi(STR0006)} // "Articulo 6 - Información de retenciones ICA que le practicaron."

    AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T.) } } )
    AADD(aButtons, { 1,.T.,{|| If( FSR505OK(), FechaBatch(), ) }} )
    AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )
    If !lAutomato
        FormBatch( cCadastro, aSays, aButtons )
    Else
        FSR505OK()
    EndIf
Return

/*/{Protheus.doc} FSR505OK
    Función que valida grupo de pregunta y ejecuta la generación de Archivos Magneticos
    @type  Function
    @author eduardo.manriquez
    @since 02/05/2022
    @version 1.0
    @param 
    @return 
    @example
    FSR505OK()
    @see (links_or_references)
    /*/
Function FSR505OK()
    Private nArch := MV_PAR01
    Private cAnio := MV_PAR02
    Private nMonto := MV_PAR03
    Private dFecIni := Ctod("01/01/" +Substr(cAnio,3,2)+"/")
	Private dFecFin := Ctod(StrZero(f_UltDia(dFecIni), 02) + "/12/" + SubStr(cAnio, 3, 2))
    Private cDir	 := Alltrim(MV_PAR07)
    Private cNomArch := Alltrim(MV_PAR08)
    Private nRegTot  := 0
    Private cStrArq  := ""

    If !ExistCpo("SX5","TJ")
        Alert(STR0034+ cCRLF+STR0035) //"La tabla genérica TJ – Relación Tipos de Documento vs Distritales no existe."
        Return(.F.)
    EndIf
    If Empty(MV_PAR02)
	    Alert(STR0007)	//"El año a presentar es requerido."
	    Return(.F.)
    Elseif (nArch == 1 .Or. nArch == 2) .And. Empty(nMonto)
         Alert(STR0008+STR0009)	//"Para los archivos del Art 2º y Art 3º " "la pregunta ¿Monto mayor a? debe informarse."
	    Return(.F.)
    EndIf
    if Empty(cNomArch)
        Alert(STR0014) // "El nombre del archivo es requerido."
        Return .F.
    Else
        cNomArch += ".csv"
    EndIf

    Do Case
		Case nArch == 1 
			cStrArq := STR0003 // "Articulo 2 -Información de compras de bienes y/o servicios"
		Case nArch == 2 
			cStrArq := STR0004 // "Articulo 3 - Ventas de bienes"
		Case nArch == 3 
			cStrArq := STR0005 // "Articulo 4 - Información de retenciones ICA practicadas"
		Case nArch == 4 
			cStrArq := STR0006 // "Articulo 6 - Información de retenciones ICA que le practicaron"
	EndCase

    If !lAutomato
	    Processa( {|lEnd| FSR505Proc(), STR0010 })	//"Gerando Arquivos... Aguarde!"
        If Len(aError) >0
            F505ImpLog()
        ElseIf nRegTot > 0
            MsgInfo(STR0046+cCRLF+cCRLF+STR0015 +cStrArq+STR0043+'"'+cDir+cNomArch+'"', STR0013) // ""Registros procesados con éxito." "El archivo correspondiente al " "se generó en la siguiente ruta: "" - "GENERACIÓN DE ARCHIVOS"
        Else
            MsgAlert(STR0047, STR0013) // "No se encontro información para procesar."- "GENERACIÓN DE ARCHIVOS"
        Endif
    Else
	    FSR505Proc()
        If nRegTot > 0
            CONOUT(STR0046+cCRLF+cCRLF+STR0015 +cStrArq+STR0043+'"'+cDir+cNomArch+'"') //""Registros procesados con éxito." "El archivo correspondiente al " "se generó en la siguiente ruta: ""
        Else
            CONOUT(STR0047)// "No se encontro información para procesar."
        Endif
	EndIf
Return .T.

/*/{Protheus.doc} FSR505Proc
    Función que detona el proceso de generación de los archivos magneticos.
    @type  Function
    @author eduardo.manriquez
    @since 02/05/2022
    @version version
    @param
    @return
    @example
    FSR505Proc()
    @see (links_or_references)
    /*/
Function FSR505Proc()
    Local cAliasSF := Iif(nArch == 1 .Or. nArch == 3,"SF1","SF2")
    Local cCampos  := ""
    Local cTMPArq  := GetNextAlias()
    Local aTxtArq  := {}
    Local cLojaSig := ""
    Local cProvSig  := ""
    Local nMontBin := 0
    Local nMontServ:= 0
    Local nMontBS  := 0
    Local nMontRet := 0
    Local nMontBas := 0
    Local cCodProv := ""
    Local aQuery   := {}
    Local cProc    := ""
    Local cTipDoc   := ""
    Local cDoc      := ""
    Local cNome     := ""
    Local cDirecc   := ""
    Local cTelf     := ""
    Local cEmail    := ""
    Local cCodMun   := ""
    Local cTipPes   := ""
    Local cTpD      := ""
    Private cProv    := ""
    Private cClien    := ""
    Private cLoja    := ""

    MakeSqlExpr(cPerg)
    cProv    := MV_PAR04
    cClien    := MV_PAR05
    cLoja    := strTran(MV_PAR06, "A2_LOJA", " ")
    aQuery := F505QRY()
    cCampos := aQuery[1] // Campos para retornar en la consulta sql
    cJoin   := aQuery[2] // Tablas de la consulta
    cCond   := aQuery[3] // Condicion de la consulta
    cOrder  := aQuery[4] // Orden

	BeginSql alias cTMPArq
        SELECT %exp:cCampos%
        FROM  %exp:cJoin%
        WHERE %exp:cCond%
        Order by %exp:cOrder%
	EndSql

    (cTMPArq)->(DbGoTop())
    cProc    := IIF(cAliasSF== "SF1",STR0051,STR0052) // "Procesando información de los proveedores..." - "Procesando información de los clientes..." 
    // Generación de archivos Compras - Ventas
    If nArch == 1 .Or. nArch == 2
        IncProc(cProc)
        While (cTMPArq)->( !Eof() )
            cCodProv := (cTMPArq)->CODPRVCL
            cCodLoj  := (cTMPArq)->TIENDA

            If nArch == 1
                iF ((cTMPArq)->BIENES = "T" .And. (cTMPArq)->SERVICIOS = "T") .Or. (cTMPArq)->BIEN_SERV = "T"
                    nMontBS += xMoeda((cTMPArq)->VALBRUT,(cTMPArq)->MONEDA,1,NIL,NIL,(cTMPArq)->TXMOEDA)
                ElseIf ((cTMPArq)->BIENES <> "T" .AND. (cTMPArq)->BIEN_SERV <> "T" ) .And. (cTMPArq)->SERVICIOS = "T"
                    nMontServ += xMoeda((cTMPArq)->VALBRUT,(cTMPArq)->MONEDA,1,NIL,NIL,(cTMPArq)->TXMOEDA)
                ElseIf (cTMPArq)->BIENES = "T"
                    nMontBin += xMoeda((cTMPArq)->VALBRUT,(cTMPArq)->MONEDA,1,NIL,NIL,(cTMPArq)->TXMOEDA)
                Endif
            else
                nMontBin += xMoeda((cTMPArq)->VALBRUT,(cTMPArq)->MONEDA,1,NIL,NIL,(cTMPArq)->TXMOEDA)
            Endif 

            cTipPes := (cTMPArq)->PERSONA
            cTpD    := (cTMPArq)->TIPDOC
            cDoc    := (cTMPArq)->DOCUMENTO
            cNome   := (cTMPArq)->NOMBRE
            cDirecc := (cTMPArq)->DIRECCION
            cTelf   := (cTMPArq)->TELEFONO
            cEmail  := (cTMPArq)->CORREO
            cCodMun := (cTMPArq)->MUNICIPIO
            cDepto  := (cTMPArq)->DEPART
            (cTMPArq)->(DBSkip())
            cProvSig := (cTMPArq)->CODPRVCL
            cLojaSig :=  (cTMPArq)->TIENDA

            if !(( cProvSig+cLojaSig) == (cCodProv+cCodLoj))
                cTipDoc := F505VALSX5("TJ",cTpD)
                aDatProv := {cTipDoc,cDoc,cNome,cDirecc,cTelf,cEmail,cCodMun,cDepto,cTipPes,cCodProv,cCodLoj,cTpD}
                aMontDevol := F505DEVOL(cAliasSF,cCodProv,cCodLoj)
                If nMontBS > 0 .And. nMontBS > nMonto
                    F505GERREG(@aTxtArq,aDatProv,nMontBS,aMontDevol[3],"3")
                Endif
                If nMontServ > 0 .And. nMontServ > nMonto
                    F505GERREG(@aTxtArq,aDatProv,nMontServ,aMontDevol[2],"1")
                Endif
                If nMontBin > 0 .And. nMontBin > nMonto
                    F505GERREG(@aTxtArq,aDatProv,nMontBin,aMontDevol[1],"2")
                Endif
                nMontBS   := 0
                nMontServ := 0
                nMontBin  := 0
            Endif
        EndDo
        (cTMPArq)->(DbCloseArea())
    Endif

    // Generación de archivos de rentenciones Compras - Ventas
    If nArch == 3 .Or. nArch == 4
        IncProc(cProc)
        While (cTMPArq)->( !Eof() )
            cCodProv := (cTMPArq)->CODPRVCL
            cCodLoj  := (cTMPArq)->TIENDA

            nMontRet +=  xMoeda((cTMPArq)->VALIMP7,(cTMPArq)->MONEDA,1,NIL,NIL,(cTMPArq)->TXMOEDA) // Conversión a moneda 1
            nMontBas +=  xMoeda((cTMPArq)->BASIMP7,(cTMPArq)->MONEDA,1,NIL,NIL,(cTMPArq)->TXMOEDA) // Conversión a moneda 1 
            nAliq    := (cTMPArq)->ALQIMP7
            cTipPes := (cTMPArq)->PERSONA
            cTpD    := (cTMPArq)->TIPDOC
            cDoc    := (cTMPArq)->DOCUMENTO
            cNome   := (cTMPArq)->NOMBRE
            cDirecc := (cTMPArq)->DIRECCION
            cTelf   := (cTMPArq)->TELEFONO
            cEmail  := (cTMPArq)->CORREO
            cCodMun := (cTMPArq)->MUNICIPIO
            cDepto  := (cTMPArq)->DEPART
            (cTMPArq)->(DBSkip())
            cProvSig := (cTMPArq)->CODPRVCL
            cLojaSig := (cTMPArq)->TIENDA

            if !((cProvSig+cLojaSig) == (cCodProv+cCodLoj))
                cTipDoc := F505VALSX5("TJ",cTpD)
                aDatProv := {cTipDoc,cDoc,cNome,cDirecc,cTelf,cEmail,cCodMun,cDepto,cTipPes,cCodProv,cCodLoj,cTpD}
                If nMontRet > 0
                    F505GERREG(@aTxtArq,aDatProv,nMontBas,nMontRet,"",nAliq)
                Endif
                nMontRet   := 0
                nMontBas   := 0
            Endif
        EndDo
        (cTMPArq)->(DbCloseArea())
    Endif
    If !Empty(aTxtArq)
        F505GerArq(cNomArch,aTxtArq,cDir)
    EndIf
Return 

/*/{Protheus.doc} F505DEVOL
    Función que retorna un arreglo con las devoluciones correspondientes
    a un proveedor.
    @type  Function
    @author eduardo.manriquez
    @since 02/05/2022
    @version 1.0
    @param cAliasSF, caracter, Alias de la tabla de documentos de salida o de entrada(SF2/SF1)
    @param cCodPC, caracter, Codigo de proveedor o cliente(SA2/SA1)
    @param cLoj, caracter, Codigo de la tienda del proveedor o cliente(SA2/SA1)
    @return aMontDv, array, Arreglo con 3 dimensiones que contiene lo siguiente:
    [1] = Monto devolución bienes
    [2] = Monto devolución servicios
    [3] = Monto devolución bienes/servicios
    @example
    F505DEVOL(cAliasSF,cCodPC,cLoj)
    @see (links_or_references)
    /*/
Function F505DEVOL(cAliasSF,cCodPC,cLoj)
    Local cCampos := ""
    Local cCond   := ""
    Local cJoin   := ""
    Local cOrder  := ""
    Local cTMTDV  := GetNextAlias()
    Local nMntDvB := 0
    Local nMntDvS := 0
    Local nMntDvBS := 0
    Local aMontDv := {}

    If cAliasSF == "SF1"
        cCampos := "% SF2.F2_CLIENTE,SF2.F2_DOC,SF2.F2_VALBRUT VALBRUT,SF2.F2_TXMOEDA TXMOEDA,SF2.F2_MOEDA MONEDA, "
        cCampos += " CASE WHEN SF2.F2_DOC IN (Select Distinct (D2_DOC) FROM "+ RetSqlName("SD2")
        cCampos += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON D2_COD=B1_COD LEFT JOIN " + RetSqlName("SBM")
        cCampos += " SBM ON SB1.B1_GRUPO=SBM.BM_GRUPO where BM_GDSSRV  = '2' AND D2_ESPECIE='NCP') then 'T' ELSE '' END AS BIENES," 
        cCampos += " CASE WHEN SF2.F2_DOC IN (Select  Distinct (D2_DOC) FROM "+ RetSqlName("SD2")
        cCampos += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON D2_COD=B1_COD LEFT JOIN " + RetSqlName("SBM")
        cCampos += " SBM ON SB1.B1_GRUPO=SBM.BM_GRUPO where BM_GDSSRV  = '1' AND D2_ESPECIE='NCP')  then 'T' ELSE '' END AS SERVICIOS, "
        cCampos += " CASE WHEN SF2.F2_DOC IN (Select  Distinct (D2_DOC) FROM "+ RetSqlName("SD2")
        cCampos += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON D2_COD=B1_COD LEFT JOIN " + RetSqlName("SBM")
        cCampos += " SBM ON SB1.B1_GRUPO=SBM.BM_GRUPO where BM_GDSSRV  = '3' AND D2_ESPECIE='NCP')  then 'T' ELSE '' END AS BIEN_SERV %"
        cCond	:= "% SF2.F2_FILIAL = '" + xFilial("SF2") + "'"
        cCond	+= " AND SF2.F2_EMISSAO BETWEEN "+DToS(dFecIni)+" And "+DToS(dFecFin)
        cCond	+= " AND SF2.F2_ESPECIE = 'NCP'"
        cCond   += Iif(!Empty(cCodPC)," AND SF2.F2_CLIENTE='"+cCodPC+"'","")
        cCond	+= Iif(!Empty(cLoj)," AND SF2.F2_LOJA= '"+cLoj+"'","")
        cCond	+= " AND SF2.D_E_L_E_T_  = ' ' %"
        cJoin   := "%" +RetSqlName("SF2") +" SF2 LEFT JOIN "+ RetSqlName("SA2") +" SA2 ON SF2.F2_CLIENTE=SA2.A2_COD %"
        cOrder  := "%  SF2.F2_CLIENTE,BIENES,SERVICIOS,BIEN_SERV %"
    Else
        cCampos := "% SF1.F1_FORNECE,SF1.F1_DOC,SF1.F1_LOJA,SF1.F1_VALBRUT VALBRUT,SF1.F1_TXMOEDA TXMOEDA,SF1.F1_MOEDA MONEDA, "
        cCampos += " CASE WHEN SF1.F1_DOC IN (Select Distinct (D1_DOC) FROM "+ RetSqlName("SD1")
        cCampos += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON D1_COD=B1_COD LEFT JOIN " + RetSqlName("SBM")
        cCampos += " SBM ON SB1.B1_GRUPO=SBM.BM_GRUPO where BM_GDSSRV  = '2' AND D1_ESPECIE='NCC') then 'T' ELSE '' END AS BIENES," 
        cCampos += " CASE WHEN SF1.F1_DOC IN (Select  Distinct (D1_DOC) FROM "+ RetSqlName("SD1")
        cCampos += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON D1_COD=B1_COD LEFT JOIN " + RetSqlName("SBM")
        cCampos += " SBM ON SB1.B1_GRUPO=SBM.BM_GRUPO where BM_GDSSRV  = '1' AND D1_ESPECIE='NCC')  then 'T' ELSE '' END AS SERVICIOS, "
        cCampos += " CASE WHEN SF1.F1_DOC IN (Select  Distinct (D1_DOC) FROM "+ RetSqlName("SD1")+""
        cCampos += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON D1_COD=B1_COD LEFT JOIN " + RetSqlName("SBM")
        cCampos += " SBM ON SB1.B1_GRUPO=SBM.BM_GRUPO where BM_GDSSRV  = '3' AND D1_ESPECIE='NCC')  then 'T' ELSE '' END AS BIEN_SERV %"
        cCond	:= "% SF1.F1_FILIAL = '" + xFilial("SF1") + "'"
		cCond	+= " AND SF1.F1_EMISSAO BETWEEN "+DToS(dFecIni)+" And "+DToS(dFecFin)
        cCond	+= " AND SF1.F1_ESPECIE = 'NCC'"
        cCond   += Iif(!Empty(cCodPC)," AND SF1.F1_FORNECE='"+cCodPC+"'","")
        cCond	+= Iif(!Empty(cLoj)," AND SF1.F1_LOJA= '"+cLoj+"'","")
		cCond	+= " AND SF1.D_E_L_E_T_  = ' ' AND SA1.D_E_L_E_T_  = ' ' %"
        cJoin   := "%" +RetSqlName("SF1") +" SF1 LEFT JOIN "+ RetSqlName("SA1") +" SA1 ON SF1.F1_FORNECE=SA1.A1_COD %"
        cOrder  := "%  SF1.F1_FORNECE,BIENES,SERVICIOS,BIEN_SERV %"
    Endif
    
    BeginSql alias cTMTDV
        SELECT %exp:cCampos%
		FROM  %exp:cJoin%
		WHERE %exp:cCond%
        Order by %exp:cOrder%
	EndSql

    (cTMTDV)->(DbGoTop())
    While (cTMTDV)->( !Eof() )
         iF ((cTMTDV)->BIENES = "T" .And. (cTMTDV)->SERVICIOS = "T") .Or. (cTMTDV)->BIEN_SERV = "T"
            nMntDvBS +=  xMoeda((cTMTDV)->VALBRUT,(cTMTDV)->MONEDA,1,NIL,NIL,(cTMTDV)->TXMOEDA)
        ElseIf (cTMTDV)->BIENES <> "T" .AND. (cTMTDV)->BIEN_SERV <> "T" .And. (cTMTDV)->SERVICIOS = "T"
            nMntDvS += xMoeda((cTMTDV)->VALBRUT,(cTMTDV)->MONEDA,1,NIL,NIL,(cTMTDV)->TXMOEDA)
        ElseIf (cTMTDV)->BIENES = "T"
            nMntDvB +=  xMoeda((cTMTDV)->VALBRUT,(cTMTDV)->MONEDA,1,NIL,NIL,(cTMTDV)->TXMOEDA)
        Endif
        (cTMTDV)->(DBSkip() )
    ENDDO

    (cTMTDV)->(DBCloseArea())
    aMontDv:= {nMntDvB,nMntDvS,nMntDvBS}
Return aMontDv

/*/{Protheus.doc} F505GERREG
    Función encargada de generar los registros de los proveedores para los
    archivos magneticos.
    @type  Function
    @author user
    @since 27/04/2022
    @version version
    @param aTxtArq, array, Arreglo donde se guardara el registro generado
    @param aDatProv, array , Datos del proveedor/cliente(SA2/SA1)
    @param nMont1, númerico, para articulo 2 y 3 - Monto Compras Anual
    para articulo 4 y 5 - Base Retención
    @param nMont2, númerico, para articulo 2 y 3 - Monto de devoluciones
    para articulo 4 y 5 - Monto Retención Anual
    @param cConPag, caracter, Concepto de pago "1". Compra de servicios, "2". Compra de bienes
    "3". Compra de bienes y servicios
    @param nAliq, númerico, Alicuota de retención
    @return return_var, return_type, return_description
    @example
    F505GERREG(aTxtArq,aDatProv,nMont1,nMont2,cConPag,nAliq)
    @see (links_or_references)
    /*/
Function F505GERREG(aTxtArq,aDatProv,nMont1,nMont2,cConPag,nAliq)
    Local cSep := ";"
    Local lArchCV := (nArch == 1 .Or. nArch == 2)
    Local lNoDigVer := (Alltrim(aDatProv[12]) == "31" .and. nArch != 4)
    
    IncProc(STR0050) // Generando registro en archivo..
    AAdd(aTxtArq,cAnio+cSep+;
        Alltrim(PADR(aDatProv[1],4,' '))+cSep+;
        Alltrim(PADR(Iif(lNoDigVer,SubStr(aDatProv[2],1,9),aDatProv[2]),11,' '))+cSep+;
        Alltrim(PADR(Alltrim(aDatProv[3]),70,' '))+cSep+;
        Alltrim(PADR(Alltrim(aDatProv[4]),70,' ')) + cSep+;
        Alltrim(PADR(Alltrim(aDatProv[5]),10,' ')) +cSep+;
        Alltrim(PADR(Alltrim(aDatProv[6]),70,' '))+cSep+;
        Alltrim(PADR(Alltrim(aDatProv[7]),5,' '))+cSep+;
        Alltrim(PADR(Alltrim(aDatProv[8]),2,' '))+cSep+;
        Iif(lArchCV .And. nArch != 2,cConPag+cSep,"")+;
        AllTrim(Transform(Int(nMont1),"@")) +cSep+;
        Iif(!lArchCV,AllTrim(Transform(nAliq,"@999.99")) +cSep,"")+;
        AllTrim(Transform(Int(nMont2),"@"))   )
    nRegTot += 1
    F505VldReg(aDatProv)
Return

/*/{Protheus.doc} F505QRY
    Función que genera la consulta SQL para los archivos magneticos.
    @type  Function
    @author eduardo.manriquez
    @since 02/05/2022
    @version 1.0
    @param 
    @return 
    @example
    F505QRY()
    @see (links_or_references)
    /*/
Function F505QRY()
    Local aQry:={}
    Local cCampos:= ""
    Local cCond := ""
    Local cJoin := ""
    Local cOrder := ""

    If nArch == 1
            cCampos := "% SF1.F1_FORNECE CODPRVCL,SF1.F1_DOC NUMDOC,SF1.F1_LOJA TIENDA,SF1.F1_VALBRUT VALBRUT,SF1.F1_TXMOEDA TXMOEDA,SF1.F1_MOEDA MONEDA, "
            cCampos += "SA2.A2_NOME NOMBRE,SA2.A2_END DIRECCION,SA2.A2_TEL TELEFONO,SA2.A2_EMAIL CORREO,SA2.A2_COD_MUN MUNICIPIO,SA2.A2_EST DEPART,SA2.A2_PESSOA PERSONA, "
            cCampos += " Case WHEN A2_PESSOA='F' THEN A2_PFISICA ELSE A2_CGC END AS DOCUMENTO,SA2.A2_TIPDOC TIPDOC, "
            cCampos += " CASE WHEN SF1.F1_DOC IN (Select Distinct (D1_DOC) FROM "+ RetSqlName("SD1")
            cCampos += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON D1_COD=B1_COD LEFT JOIN " + RetSqlName("SBM")
            cCampos += " SBM ON SB1.B1_GRUPO=SBM.BM_GRUPO where BM_GDSSRV  = '2' AND D1_ESPECIE='NF') then 'T' ELSE '' END AS BIENES," 
            cCampos += " CASE WHEN SF1.F1_DOC IN (Select  Distinct (D1_DOC) FROM "+ RetSqlName("SD1")
            cCampos += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON D1_COD=B1_COD LEFT JOIN " + RetSqlName("SBM")
            cCampos += " SBM ON SB1.B1_GRUPO=SBM.BM_GRUPO where BM_GDSSRV  = '1' AND D1_ESPECIE='NF')  then 'T' ELSE '' END AS SERVICIOS, "
            cCampos += " CASE WHEN SF1.F1_DOC IN (Select  Distinct (D1_DOC) FROM "+ RetSqlName("SD1")+""
            cCampos += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON D1_COD=B1_COD LEFT JOIN " + RetSqlName("SBM")
            cCampos += " SBM ON SB1.B1_GRUPO=SBM.BM_GRUPO where BM_GDSSRV  = '3' AND D1_ESPECIE='NF')  then 'T' ELSE '' END AS BIEN_SERV %"
            cCond	:= "% SF1.F1_FILIAL = '" + xFilial("SF1") + "'"
		    cCond	+= " AND SF1.F1_EMISSAO BETWEEN "+DToS(dFecIni)+" And "+DToS(dFecFin)
            cCond	+= " AND SF1.F1_ESPECIE = 'NF' "
            cCond	+= " AND SA2.A2_EST != 'EX' "
            cCond   += Iif(!Empty(cProv)," AND "+strTran(cProv, "A2_COD", "SA2.A2_COD"),"")
            cCond	+= Iif(!Empty(cLoja)," AND "+strTran(cLoja, "(", "(SA2.A2_LOJA ",1,1),"")
		    cCond	+= " AND SF1.D_E_L_E_T_  = ' ' AND SA2.D_E_L_E_T_  = ' ' %"
            cJoin   := "%" +RetSqlName("SF1") +" SF1 LEFT JOIN "+ RetSqlName("SA2") +" SA2 ON SF1.F1_FORNECE=SA2.A2_COD %"
            cOrder  := "%  SF1.F1_FORNECE,BIENES,SERVICIOS,BIEN_SERV %"
    Endif
    If nArch == 3
        cCampos := "% DISTINCT(SF1.F1_DOC) NUMDOC,SF1.F1_FORNECE CODPRVCL,SF1.F1_LOJA TIENDA,SF1.F1_CODMUN CODMUN,SF1.F1_TPACTIV ACTIV,SF1.F1_VALIMP7 VALIMP7,SF1.F1_BASIMP7 BASIMP7,SF1.F1_TXMOEDA TXMOEDA,SF1.F1_MOEDA MONEDA,SF3.F3_ALQIMP7 ALQIMP7, "
        cCampos += "SA2.A2_NOME NOMBRE,SA2.A2_END DIRECCION,SA2.A2_TEL TELEFONO,SA2.A2_EMAIL CORREO,SA2.A2_COD_MUN MUNICIPIO,SA2.A2_EST DEPART,SA2.A2_PESSOA PERSONA, "
        cCampos += " Case WHEN A2_PESSOA='F' THEN A2_PFISICA ELSE A2_CGC END AS DOCUMENTO, SA2.A2_TIPDOC TIPDOC %"
        cCond	:= "% SF1.F1_FILIAL = '" + xFilial("SF1") + "'"
	    cCond	+= " AND SF1.F1_EMISSAO BETWEEN "+DToS(dFecIni)+" And "+DToS(dFecFin)
        cCond   += Iif(!Empty(cProv)," AND "+strTran(cProv, "A2_COD", "SA2.A2_COD"),"")
        cCond	+= Iif(!Empty(cLoja)," AND "+strTran(cLoja, "(", "(SA2.A2_LOJA ",1,1),"")
        cCond   += " AND SF1.F1_BASIMP7 > 0 AND SF1.F1_ESPECIE = 'NF' "
	    cCond	+= " AND SF1.D_E_L_E_T_  = ' ' AND SA2.D_E_L_E_T_ = ' ' %"
        cJoin   := "%" +RetSqlName("SF1") +" SF1 LEFT JOIN "+ RetSqlName("SA2") +" SA2 ON SF1.F1_FORNECE=SA2.A2_COD LEFT JOIN "
        cJoin   += RetSqlName("SF3") + " SF3 ON SF1.F1_DOC=SF3.F3_NFISCAL AND SF1.F1_SERIE=SF3.F3_SERIE %"
        cOrder  := "%  SF1.F1_FORNECE %"
    Endif

    If nArch == 2 .Or. nArch == 4
        cCond	:= "% SF2.F2_FILIAL = '" + xFilial("SF2") + "'"
        cCond	+= " AND SF2.F2_EMISSAO BETWEEN "+DToS(dFecIni)+" And "+DToS(dFecFin)
        cCond	+= " AND SF2.F2_ESPECIE = 'NF' "
        cCond   += Iif(!Empty(cClien)," AND "+strTran(cCLien, "A1_COD", "SA1.A1_COD"),"")
        cCond	+= Iif(!Empty(cLoja)," AND "+strTran(cLoja, "(", "(SA1.A1_LOJA ",1,1),"")
        If nArch == 2
            cCampos := "% SF2.F2_CLIENTE CODPRVCL,SF2.F2_DOC NUMDOC,F2_LOJA TIENDA,SF2.F2_VALBRUT VALBRUT,SF2.F2_TXMOEDA TXMOEDA,SF2.F2_MOEDA MONEDA, "
            cCond	+= " AND SA1.A1_EST != 'EX' "
            cCond   += " AND SF2.F2_DOC NOT IN (Select DISTINCT ( D2_DOC) FROM "+RetSqlName("SD2")+ " SD2 LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SD2.D2_COD=SB1.B1_COD LEFT JOIN "
            cCond   +=  RetSqlName("SBM")+ " SBM ON SB1.B1_GRUPO=SBM.BM_GRUPO where SBM.BM_GDSSRV  = '3' OR  BM_GDSSRV  = '1'  AND SD2.D2_ESPECIE='NF')"
        Else
            cCampos := "% DISTINCT(SF2.F2_DOC) NUMDOC,SF2.F2_CLIENTE CODPRVCL,SF2.F2_LOJA TIENDA,SF2.F2_CODMUN CODMUN,SF2.F2_TPACTIV ACTIV,SF2.F2_VALIMP7 VALIMP7,SF2.F2_BASIMP7 BASIMP7,SF2.F2_TXMOEDA TXMOEDA,SF2.F2_MOEDA MONEDA,SF3.F3_ALQIMP7 ALQIMP7, "
            cCond   += " AND SF2.F2_BASIMP7 > 0 "
        Endif
        cCampos += " SA1.A1_NOME NOMBRE,SA1.A1_END DIRECCION,SA1.A1_TEL TELEFONO,SA1.A1_EMAIL CORREO,SA1.A1_COD_MUN MUNICIPIO,SA1.A1_EST DEPART,SA1.A1_PESSOA PERSONA, "
        cCampos += " Case WHEN SA1.A1_PESSOA='F' THEN SA1.A1_PFISICA ELSE SA1.A1_CGC END AS DOCUMENTO,SA1.A1_TIPDOC TIPDOC %"
        cCond	+= " AND SF2.D_E_L_E_T_  = ' ' AND SA1.D_E_L_E_T_  = ' ' %"
        cJoin   := "%" +RetSqlName("SF2") +" SF2 LEFT JOIN "+ RetSqlName("SA1") +" SA1 ON SF2.F2_CLIENTE=SA1.A1_COD "
        cJoin   +=  Iif(nArch == 4,"LEFT JOIN "+RetSqlName("SF3") + " SF3 ON SF2.F2_DOC=SF3.F3_NFISCAL AND SF2.F2_SERIE=SF3.F3_SERIE ","")+ " %"
        cOrder  := "%  SF2.F2_CLIENTE%"
    Endif

    aQry := {cCampos,cJoin,cCond,cOrder}
Return aQry

/*/{Protheus.doc} F505GerArq
    Función encargada de crear el archivo en el directorio informado.
    @type  Function
    @author eduardo.manriques
    @since 02/05/2022
    @version version
    @param cArq, caracter, Nombre del archivo
    @param aTxtArq, array, Arreglo que contiene los registros generados.
    @param cDir, caracter, Direcctorio donde se creara el archivo.
    @return 
    @example
    F505GerArq(cArq,aTxtArq,cDir)
    @see (links_or_references)
    /*/
Function F505GerArq(cArq,aTxtArq,cDir)
    Local nI        := 0
    Local nHdlArq	:= 0
    Local cArquivo  := cDir+cArq
    Local cTexto    := ""

    If File(cArquivo)
        FErase(cArquivo)
    Endif

    nHdlArq := fCreate(cArquivo)

    For nI := 1 to Len(aTxtArq)
        cTexto := aTxtArq[nI]+cCRLF
        fWrite(nHdlArq, cTexto, Len(cTexto))
    Next nI

    FClose(nHdlArq)

    lGerOk := .T.
Return

/*/{Protheus.doc} F505VALSX5
    Función que retorna la descripción para un registro de la tabla generica.
    @type  Function
    @author eduardo.manriques
    @since 02/05/2022
    @version version
    @param cTabela, caracter, Nombre de la tabla
    @param cClave, caracter, Clave de registro.
    @param cRet, caracter, Descripción del registro.
    @return 
    @example
    F505VALSX5(cTabela,cClave)    
    @see (links_or_references)
    /*/
Function F505VALSX5(cTabela,cClave)
	Local cRet      := ""
    Local cFilX5    := xFilial("SX5")
	Local aArea 	:= getArea()

	dbSelectArea("SX5")
	SX5->(dbSetOrder(1)) //X5_FILIAL+X5_TABELA+X5_CHAVE
	If SX5->(dbSeek(cFilX5 + cTabela + cClave))
		cRet := X5Descri()
	EndIf
	RestArea(aArea)
Return cRet

/*/{Protheus.doc} F505VldReg
    Función que valida los datos de un proveedor/cliente.
    @type Static
    @author eduardo.manriques
    @since 02/05/2022
    @version 1.0
    @param aDatProv, arrat, Arreglo que contiene la información del proveedor/cliente:
    [1] - Descripción Tipo Documento, [2] - Número de Documento(NIT), [3] -Nombre, [4] -Dirección
    [5] - Telefono, [6] - Correo electronico, [7] - Código Municipio, [8] - Depatamento
    [9] - Tipo Persona, [10] - Código prov/cli, [11] -Tienda,[12] - Tipo Documento
    @example
    F505VldReg(aDatProv)
    @see (links_or_references)
    /*/
Static Function F505VldReg(aDatProv)
    Local cTipPesso := aDatProv[9]
    Local cPrvd := aDatProv[10]
    Local cTienda := aDatProv[11]
    Local lProv   := (nArch == 1 .Or. nArch == 3)
    Local cMsj    := ""

    If Empty(aDatProv[7])
        cMsj := Iif(lProv,STR0017,STR0026) // "El Cod. Municip(A2_COD_MUN) del proveedor esta vacío."-"El Cod. Municip(A1_COD_MUN) del cliente esta vacío."
		aAdd(aError, {Str(nRegTot,5),cPrvd,cTienda,cMsj}) 
	EndIf
    If Empty(aDatProv[8])
        cMsj := Iif(lProv,STR0018,STR0027) // "El Departamento(A2_EST) del proveedor esta vacío."- "El Departamento(A1_EST) del cliente esta vacío."
		aAdd(aError, {Str(nRegTot,5),cPrvd,cTienda,cMsj})
	EndIf
	If Empty(aDatProv[2])
        if cTipPesso == 'F'
            cMsj := Iif(lProv,STR0024,STR0033)// "El RG/Ced.Estr.(A2_PFISICA) del proveedor esta vacío." - "El RG/Ced.Estr.(A1_PFISICA) del cliente esta vacío."
        else
            cMsj := Iif(lProv,STR0023,STR0032) //"El NIT(A2_CGC) del proveedor esta vacío." - "El NIT(A1_CGC) del cliente esta vacío."
        Endif
		aAdd(aError, {Str(nRegTot,5),cPrvd,cTienda,cMsj})
	EndIf
	
	If Empty(aDatProv[4])
        cMsj := Iif(lProv,STR0019,STR0028) // "La Dirección(A2_END) del proveedor esta vacía."-"La Dirección(A1_END) del cliente esta vacía."
		aAdd(aError, {Str(nRegTot,5),cPrvd,cTienda,cMsj})
	EndIf

	If !Empty(aDatProv[12]) .And. Empty(aDatProv[1])
        cMsj := Iif(lProv,STR0016,STR0048) +STR0044//"El Tipo Documento(A2_TIPDOC) informado en el proveedor no existe en la tabla TJ-Relación Tipos de Documento vs Distritales" 
		aAdd(aError,  {Str(nRegTot,5),cPrvd,cTienda,cMsj}) 
	Elseif Empty(aDatProv[1])
        cMsj := Iif(lProv,STR0045,STR0049) // "El Tipo Documento(A2_TIPDOC) del proveedor esta vacio."-"El Tipo Documento(A1_TIPDOC) del cliente esta vacio."
        aAdd(aError,  {Str(nRegTot,5),cPrvd,cTienda,cMsj})
    EndIf

	If Empty(aDatProv[6])
        cMsj := Iif(lProv,STR0021,STR0030) //"El Correo electrónico(A2_EMAIL) del proveedor esta vacío." - "El Correo electrónico(A1_EMAIL) del cliente esta vacío."
		aAdd(aError, {Str(nRegTot,5),cPrvd,cTienda,cMsj})
	EndIf

	If Empty(aDatProv[5])
        cMsj := Iif(lProv,STR0020,STR0029) // "El Teléfono(A2_TEL) del proveedor esta vacío."-"El Teléfono(A1_TEL) del cliente esta vacío."
		aAdd(aError,  {Str(nRegTot,5),cPrvd,cTienda,cMsj})
	EndIf
Return 

/*/{Protheus.doc} F505ImpLog
    Función que se encarga de generar archivo log de errores
    de los registros procesados.
    @type
    @author eduardo.manriquez
    @since 02/05/2022
    @version 1.0
    @param 
    @return Nil
    @example
    F505ImpLog()
    @see (links_or_references)
/*/
Static Function F505ImpLog()
	Local aReturn	:= {"xxxx", 1, "yyy", 2, 2, 1, "",1 }	//"Zebrado"###"Administra‡„o"
	Local cTamanho	:= "G"
	Local cTitulo	:= STR0001	//"MEDIOS MAGNETICOS DISTRITALES (BOGOTA)"
	Local aLogTitle	:= Array(2)
	Local aLog	:= {}
    Local nLenReg   := 16
	Local nLenProv	:= Iif(nArch == 1 .Or. nArch == 3,Len(SA2->(A2_COD)),Len(SA1->(A1_COD)))  + 4
	Local nLenTda	:= Iif(nArch == 1 .Or. nArch == 3,Len(SA2->(A2_LOJA)),Len(SA1->(A1_LOJA))) + 6
    Local cStrPC    := Iif(nArch == 1 .Or. nArch == 3,STR0036,STR0037)
	Local nI		:= 1
    Local cArchivo  :='"'+cDir+cNomArch+'"'

	aLogTitle[1] := PadR(STR0041,nLenReg)+PadR(cStrPC,nLenProv)+PadR(STR0038,nLenTda)+STR0039	//"N° de Registro" # "Proveedor" # "Tienda" # "Mensaje"
	aLogTitle[2] := STR0015 +cStrArq+STR0043+cArchivo	//"El archivo correspondiente al " - "se generó en la siguiente ruta: "
	
	aAdd( aLog, {})

	For nI := 1 to Len(aError)
		aAdd( aLog[1],aError[nI][1] + space(12)+aError[nI][2] + space(4)+aError[nI][3];
         + space(6) + aError[nI][4] )////"N° de Registro" # "Proveedor" # "Tienda" # "Mensaje"
	Next nI
	aAdd( aLog, {})
	aAdd( aLog[2], "")
	aAdd( aLog[2], STR0040 + Str(nRegTot,5))	//"Total de registros procesados: "
	
	/*
		1 -	aLogFile 	//Array que contem os Detalhes de Ocorrencia de Log
		2 -	aLogTitle	//Array que contem os Titulos de Acordo com as Ocorrencias
		3 -	cPerg		//Pergunte a Ser Listado
		4 -	lShowLog	//Se Havera "Display" de Tela
		5 -	cLogName	//Nome Alternativo do Log
		6 -	cTitulo		//Titulo Alternativo do Log
		7 -	cTamanho	//Tamanho Vertical do Relatorio de Log ("P","M","G")
		8 -	cLandPort	//Orientacao do Relatorio ("P" Retrato ou "L" Paisagem )
		9 -	aRet		//Array com a Mesma Estrutura do aReturn
		10-	lAddOldLog	//Se deve Manter ( Adicionar ) no Novo Log o Log Anterior
	*/
	MsAguarde( { ||fMakeLog( aLog , aLogTitle , , .T. , FunName() , cTitulo , cTamanho , "P" , aReturn , .F. )}, STR0042) //"Generando Log de proceso..."	
Return

