#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOCXMET.CH"
#INCLUDE 'FWLIBVERSION.CH' 

/*/{Protheus.doc} LocxMet
    Función para el uso de métricas.
    @type  Function
    @author raul.medina
    @since 10/08/2021
    @param 
        Caracter    - cRotina: Nombre de la rutina
                    - xValor: Valor para ser asignado a la metrica
        Fecha       - dDate: Fecha que telemetría debe ser sincronizada
                    - xLapTime: Tiempo de uso
        Logico      - lCustom: Metricas customizadas, 
        Caracter    - cTipo: A-Average, U-Unique, M-Metric, S-Sum
    /*/

Function LocxMet(cRotina, xValor, dDate, xLapTime, lCustom, cTipo)
Local lContinua		:= (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')
Local lAutomato		:= IsBlind()

Default cRotina     := ""
Default xValor      := ""
Default dDate       := Nil
Default nLapTime    := 0
Default lCustom     := .F.
Default cTipo       := ""

	If lContinua
        If lCustom
            If cTipo == "A"
                LocxMetAvg(cRotina, xValor, dDate, xLapTime, lAutomato)
            EndIf
        EndIf
	Endif

Return

/*/{Protheus.doc} LocxMetAvg
    Función para el uso de métricas de tipo Average
    @type  Function
    @author raul.medina
    @since 10/08/2021
    @param 
        Caracter    - cRotina: Nombre de la rutina
                    - xValor: Valor para ser asignado a la metrica
        Fecha       - dDate: Fecha que telemetría debe ser sincronizada
                    - xLapTime: Tiempo de uso
        Logico      - lAutomato: indica si es rutina automatizada 
    /*/
Function LocxMetAvg(cRotina, xValor, dDate, xLapTime, lAutomato)
Local cIdMetric		:= ""
Local cSubRoutine	:= ""

    If cRotina == "MATA467N"
        cSubRoutine := cRotina + "-media-items"
        If lAutomato
            cSubRoutine += "-auto" 
        EndIf
        cIdMetric	:= "facturacionprotheus_mediaitenesfacturasalidamanual_average"
        FWCustomMetrics():setAverageMetric(cSubRoutine, cIdMetric, xValor, /*dDateSend*/, /*nLapTime*/,cRotina)
    EndIf
Return

/*/{Protheus.doc} LOCXMETGRV
    Función para el uso de métricas, llamada al finalizar la grabación de los documentos
    @type  Function
    @author raul.medina
    @since 07/09/2021
    @param 
        Caracter    - cRotina: Nombre de la rutina
                    - cEspecie: Especie del documento.
    /*/
Function LOCXMETGRV(cRutina, cEspecie )
Local lContinua		:= (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')

Default cRutina     := ""
Default cEspecie    := ""

    If lContinua

        If cRutina == "MATA465N" .And. cEspecie = "NCC"
            MET465N()
        ElseIf cRutina == "MATA466N" 
            MET466N(cEspecie)
        ElseIf cRutina=="MATA101N"
            MET101N(cEspecie)
        EndIf
       
    EndIf

Return 

/*/{Protheus.doc} MET465N
    Metricas para la MATA465n
    @type  Function
    @author raul.medina
    @since 07/09/2021
    @param 

    /*/
Static Function MET465N()
Local cRutina       := "MATA465N"
Local cIdMetric     := ""
Local cSubRutina    := ""
Local xValor
Local lAutomato		:= IsBlind()


    //Media de items originales en NCC
    cIdMetric   := "faturamento-protheus_media-itenes-originales-ncc_average"
    cSubRutina  := "mata465n-media-items-orig"
    If lAutomato
        cSubRutina  += "-auto"
    EndIf
    xValor      := ItemOrig("NCC")
    FWCustomMetrics():setAverageMetric(cSubRutina, cIdMetric, xValor, /*dDateSend*/, /*nLapTime*/,cRutina)

Return

/*/{Protheus.doc} MET466N
    Metricas para la MATA466n
    @type  Function
    @author raul.medina
    @since 07/09/2021
    @param 

    /*/

Static Function MET466N(cEspecie)
Local cRutina       := "MATA466N"
Local cIdMetric     := ""
Local cSubRutina    := ""
Local xValor
Local lAutomato		:= IsBlind()
Local cEspe :=alltrim(Lower(cEspecie))
    IF cEspe == "ncp"
        //Media de items originales en NCP
        cIdMetric   := "compras-protheus_media-itenes-originales-ncp_average"
        cSubRutina  := "mata466n-media-items-orig"
        If lAutomato
            cSubRutina  += "-auto"
        EndIf
        xValor      := ItemOrig("NCP")
        FWCustomMetrics():setAverageMetric(cSubRutina, cIdMetric, xValor, /*dDateSend*/, /*nLapTime*/,cRutina)
    ENDIF

    IF Type( "lMetImpEdi" ) <> "U"
        //edicion de impuestos
        METEDITIMP(lMetImpEdi,cRutina,cEspe)
    ENDIF

Return

/*/{Protheus.doc} MET101N
    Función para   Metricas de  MATA101n
    @type  Function
    @author adrian.perez
    @since 06/09/2021
    @param 
        Caracter    - cEspecie: tipo de documento NF,NDP,NCP
    /*/


Static Function MET101N(cEspecie)
Local cRutina       := "MATA101N"
Local cEspe :=alltrim(Lower(cEspecie))

    IF cEspe == "nf"
        IF Type( "lMetImpEdi" ) <> "U"
            //edicion de impuestos
            METEDITIMP(lMetImpEdi,cRutina,cEspe)
        ENDIF
    ENDIF

Return

/*/{Protheus.doc} ItemOrig
    Función auxiliar para obtener el número de items asociados a un documento
    @type  Function
    @author raul.medina
    @since 07/09/2021
    @param 
        Caracter    - cEspecie: Especie del documento.
    /*/
Static Function ItemOrig(cEspecie)
Local nItemsOrig    := 0
Local cTemp         := GetNextAlias()
Local cQuery        := ""
Local lSD1          := cEspecie $ "NCC"


    cQuery := "Select " 
    If lSD1
        cQuery += "DISTINCT(D1_NFORI) "
    Else
        cQuery += "DISTINCT(D2_NFORI) "
    EndIf
    cQuery += "from "
    If lSD1
        cQuery += RetSqlName("SD1") + " SD1 "
        cQuery += "Where" 
        cquery += " D1_DOC = '"+ SF1->F1_DOC +"'" 
        cQuery += " AND D1_FORNECE = '" + SF1->F1_FORNECE + "'"
        cQuery += " AND D1_LOJA = '" + SF1->F1_LOJA + "'" 
        cQuery += " AND D1_NFORI <> ''" 
    Else
        cQuery += RetSqlName("SD2") + " SD2 "
        cQuery += "Where" 
        cquery += " D2_DOC = '"+ SF2->F2_DOC +"'" 
        cQuery += " AND D2_CLIENTE = '" + SF2->F2_CLIENTE + "'"
        cQuery += " AND D2_LOJA = '" + SF2->F2_LOJA + "'" 
        cQuery += " AND D2_NFORI <> ''" 
    EndIf

    cQuery := ChangeQuery(cQuery)                    
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.T.,.T.) 

	Count to nItemsOrig

    (cTemp)->(dbCloseArea()) 


Return nItemsOrig


/*/{Protheus.doc} METEDITIMP
    Función para la metrica de edicion de impuestos
    @type  Function
    @author adrian.perez
    @since 06/10/2021
    @param 
        Lógico      - lMetImpEdi: Indica si(True existió, false no existió) hubo edicion de impuestos por FISA081 O FISA084.
        Caracter    - cRutina: Rutina de donde se hizo la edicion de impuestos (MATA101N,MATA466N)
        Caracter    - cEspecie: tipo de documento NF,NDP,NCP
    /*/

Static Function METEDITIMP(lMetImpEdi,cRutina,cEspecie)

Local cIdMetric     := ""
Local cSubRutina    := ""
Local lAutomato		:= IsBlind()
Local nValor        :=IIF(lMetImpEdi,1,0)
    
    IF lMetImpEdi// si se edito el impuesto
        cIdMetric   := "compras-protheus_media-edicao-imposto-"+cEspecie+"_total"
        cSubRutina  := cRutina+"-media-edicao-imposto"
        If lAutomato
            cSubRutina  += "-auto"
        EndIf
    
        FWCustomMetrics():setSumMetric(cSubRutina, cIdMetric, nValor, /*dDateSend*/, /*nLapTime*/,cRutina)
    ENDIF
    lMetImpEdi:=.F.
RETURN
