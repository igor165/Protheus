#include "protheus.ch"
#INCLUDE "IMPFTARG.CH"

/*/{Protheus.doc} ArQrAFIP
Clase para control y generacion de datos en impresion de QR
requerido por AFIP

@type Class
@version 
@author Francisco Guerrero
@since 21/5/2020
@return null
/*/
CLASS ArQrAFIP

	DATA cString
    DATA aDatosCMP
	DATA oJson
    DATA cUrlAfip
    	
	
	METHOD New() CONSTRUCTOR
    METHOD setString()
	METHOD setDatosCMP()
    METHOD setUrlAfip()
    METHOD getString()
    METHOD getDatosCMP()
    METHOD getUrlAfip()
	METHOD getJsonObject()
    METHOD getJsonString()
    METHOD getQrString()
    METHOD ConvStr()
    METHOD LayCodeQR()
	


	
ENDCLASS

/*/{Protheus.doc} New
Metodo constructor

@type metodo
@version 
@author Francisco Guerrero
@since 21/5/2020
@return null
/*/
METHOD New() CLASS ArQrAFIP
	
	Local nPosFin := 0  

    ::cString      := ""
	::aDatosCMP    := {}
	::oJson	       := JsonObject():New()
    ::cUrlAfip     := 'https://www.afip.gob.ar/fe/qr/'
    


RETURN SELF
/*/{Protheus.doc} setString
    Setea array con string que son fijos
    @type  Function
    @author user
    @since 06/01/2021
    @version version
    @param aTexto, array[String], Datos string fijos
    @return nil
    @example
    (examples)
    @see (links_or_references)
/*/
METHOD setString(cTexto) CLASS ArQrAfip
    
    ::cString := cTexto

Return nil


/*/{Protheus.doc} setDatosCMP
    Setea array con datos de comprobante segun necesidad de AFIP
    @type  Metodo
    @author Francisco Guerrero
    @since 06/01/2021
    @version version
    @param aDatos, array[String,xvalor], Datos en formato array de dos dimensiones (primer valor nombre y segundo contenido)
    @return nil
    @example
    setDatosCMP({{'ver',1},{'fecha',31/12/2020},{'cuit',33000000001},{'ptoVta',10},{'tipoCmp',1}
    {'nroCmp',94},{'importe',12100},{"moneda","DOL"},{"ctz",65},{"tipoDocRec",80},{"nroDocRec",20000000001}
    {"tipoCodAut","E"},{"codAut",70417054367476}})
    @see (links_or_references)
/*/
METHOD setDatosCMP(aDatos) CLASS ArQrAFIP
    
    Local cTextJson:=''
    Local j:=0
    
    ::aDatosCMP:=aDatos
    
    cTextJson:= '{'
    For j:=1 to len(aDatos)
        IF j>1
            cTextJson += ','
        Endif
        If ValType(aDatos[j]) == "A" .and. Len(aDatos[j]) == 2
            cTextJson += '"'+aDatos[j,1]+'"'
            cTextJson +=':'
            cTextJson += ::SELF:ConvStr(aDatos[j,2])

        EndIf

    Next j
    cTextJson+= '}'
    ::SELF:setString(cTextJson)
    ::SELF:oJson:FromJson(cTextJson)

Return nil



METHOD setUrlAfip(cUrl) CLASS ArQrAfip
    ::cUrlAfip := cUrl
Return Nil


METHOD getJsonObject() CLASS ArQrAfip

Return ::oJson

METHOD getJsonString() CLASS ArQrAfip

Return ::oJson:toJSON()



METHOD getUrlAfip() CLASS ArQrAfip

Return ::cUrlAfip

/*/{Protheus.doc} getQrString
   Retorna la informacion en el objeto con el formato que requiere AFIP en la impresion del QR
    QR : {URL}?p={DATOS_CMP_BASE_64}
    {URL} = https://www.afip.gob.ar/fe/ qr/
    {DATOS_CMP_BASE_64} = JSON con datos del comprobante codificado en Base64

    JSON con datos del comprobante:
    {"ver":1,"fecha":"2020-10-13","cuit":30000000007,"ptoVta":10,"tipoCmp":1,"nroCmp":94,"importe":12100
    ,"moneda":"DOL","ctz":65,"tipoDocRec":80,"nroDocRec":20000000001,"tipoCodAut":"E","codAut":70417054367476}


    @type  Method
    @author Francisco Guerrero
    @since 06/01/2021
    @version version
    @param cCliente, string(6), codigo cliente 

    @return String
    @example
    
    @see https://www.afip.gob.ar/fe/qr/especificaciones.asp
/*/

METHOD getQrString() CLASS ArQrAfip

    Local cRet:= ""

    cRet+= ::cUrlAfip
    cRet+= "?p="
    //cRet+= Encode64(::oJson:toJSON(),,,.F.)//encode64
    cRet+= Encode64(::cString,,,.F.)//encode64

Return cRet

/*/{Protheus.doc} ConvStr
   Recibe un dato y lo convierte en string siguiendo el formato que necesita AFIP en cada 
   tipo de dato destino numerico, fecha, string
    @type  Method
    @author Francisco Guerrero
    @since 06/01/2021
    @version version
    @param xDato, cualquier formato, Dato a convertir y formatear  en string 

    @return String
    @example
    
    @see (links_or_references)
/*/
METHOD ConvStr(xDato) CLASS ArQrAfip

    Local cRet :=""

    Do CASE 
        Case ValType(xDato)=="C"
            cRet := xDato
        Case ValType(xDato)=="N"
            cRet := Str(xDato)
            cRet := StrTran(cRet," ","")
            cRet := StrTran(cRet,",","")
            cRet := StrTran(cRet,".","")
        Case ValType(xDato)=="D"
            cRet := DTOS(xDato)
            cRet := Substr(cRet,1,4)+"-"+Substr(cRet,5,2)+"-"+Substr(cRet,7,2)
        Otherwise 
            cRet := AllTrim(STR0052)
    ENDCase

Return cRet

/*/{Protheus.doc} LayCodeQR
   Recibe datos del comprobante fiscal necesarios por AFIP para el QR y los formatea en un array
   que se envia al objeto ArQrAFIP
    @type  Method
    @author Francisco Guerrero
    @since 06/01/2021
    @version version
    @param cCliente, string(6), codigo cliente 
    @param cLoja, string(2), codigo tienda cliente
    @param nNroDoc, string(11), numero de documento de identificacion para el cliente
    @param cEspecie, string(3), Especie de comprobante en Protheus
    @param cCodComp, string(3), codigo de comprobante segun tabla de AFIP
    @param dEmision, date, fecha de emision del comprobante
    @param cDoc, string(12), numero de comprobante
    @param cCAE, string(13), numero de autorizacion electronica del comprobante
    @param cVctoCAE, date, fecha de vencimiento del CAE
    @param nMoeda, numerico(1), moneda del comprobante
    @param nTxmoeda, numerico(14,4), tasa de la moneda del comprobante
    @param nImporte, numerico (15,2) importe bruto del comprobante
    @return nil
    @example
    
    @see (links_or_references)
/*/
METHOD LayCodeQR(cCliente,cLoja,cNroDoc,cEspecie,cCodComp, dEmision,cDoc, cCAE,cVctoCae,nMoeda,nTxmoeda,nImporte) CLASS ArQrAFIP

    Local aArea := GetArea()
    Local cuit   := INT(VAL(Alltrim(SM0->M0_CGC)))
    Local aDatos := {}
    Local nroCmp := int(val(Right(cDoc,12)))
    Local ptoVta := int(val(LEFT(cDoc,(len(cDoc)-12))))
    Local tipoCmp:= int(val(cCodComp))
    Local cMoeda := ""
    Local moneda := ""
    Local ctz    := nTxmoeda
    Local importe    := int(nImporte*100)
    Local tipoDocRec := POSICIONE("SA1",1,XFILIAL("SA1")+cCliente,"A1_AFIP")
    Local codAut     := INT(VAL(cCAE))
    Local cNRODOC := POSICIONE("SA1",1,XFILIAL("SA1")+cCliente,"A1_CGC")
    Local nroDocRec  := INT(VAL(cNRODOC))

    tipoDocRec := LEFT(POSICIONE("SX5",1,XFILIAL("SX5")+tipoDocRec,"X5_DESCSPA"),2)
    tipoDocRec := INT(VAL(tipoDocRec))

    cMoeda:='GetMV("MV_SIMB'+Alltrim(str(nMoeda))+'")'
    If(SYF->(MsSeek(xFilial("SYF")+&cMoeda)) )
    moneda:=SYF->YF_COD_GI
    Else
        moneda:="01"
    EndIf                      



    aadd(aDatos,{'ver',1})//01
    aadd(aDatos,{'fecha',dEmision})//02
    aadd(aDatos,{'cuit',cuit})//03
    aadd(aDatos,{'ptoVta',ptoVta})//04
    aadd(aDatos,{'tipoCmp',tipoCmp})//05
    aadd(aDatos,{'nroCmp',nroCmp})//06
    aadd(aDatos,{'importe',importe})//07
    aadd(aDatos,{"moneda",moneda})//08
    aadd(aDatos,{"ctz",ctz})//09
    aadd(aDatos,{"tipoDocRec",80})//10
    aadd(aDatos,{"nroDocRec",nroDocRec})//11
    aadd(aDatos,{"tipoCodAut","E"})//12
    aadd(aDatos,{"codAut",codAut})//13

    ::SELF:setDatosCMP(aDatos)
    
    RestArea(aArea)

Return ::SELF:getQrString()
