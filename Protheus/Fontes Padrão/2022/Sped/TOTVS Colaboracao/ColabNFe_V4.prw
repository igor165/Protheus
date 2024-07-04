
#include 'totvs.ch'

//-----------------------------------------------------------
/*/{Protheus.doc} NFeV4Col()

Converte XML NFe leiaute TSS para NFe Sefaz 4.00

@param cIdEnt       Codigo da Entidade da NFe
@param oNFe         Objeto com XML da NFe leiaute
@param cNFMod       Modelo do XML. 55
@param cMail        Endereço de Email do Destinatário da NFe
@param cDoc_Chv     Chave da NFe
@param cModalidade  Modalidade da transmissão da NFe
@param nAmbiente    ambiente de transmissão da NFe: 1= produção; 2=homologação
@return	cNFeV4      XML Nfe Leiaute 4.00 da Sefaz

@author	Valter Silva
@since		21/02/2018
@version 	12.1.17
/*/
//----------------------------------------------------------
function NFeV4Col(cIdEnt, oNFe, cNfMod, nAmbiente)

	local cChave        := ""
	local cDoc_Chv      := ""
	local cMail         := ""
	local cModalidade   := ""
	local cNFeV4        := ""
	Local cVersaoTC     := "TC2.00"		//Versao Totvs Colaboracao (Client Neogrid)

	local lContingencia := .F.

	local nQtdProd      :=0

	local aProd
	local aImp		      := { {0,0,0,0,0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0,0,0,0,0,0,0,0,0}, {0,0,0}, {0,0}, {0}, {0, 0, 0} }
	local aTot		      := {0,0,0,0,0}
	local aTpEmis	      := {}
	Local lUsaColab  	  := ColUsaColab("1")

	Default cNFMod := "55"

	private oInfNFe := oNFe:_InfNFe

	aTpEmis	:= GetTpEmis(cIdEnt,cNFMod)
	cModalidade   := aTpEmis[1]
	lContingencia := aTpEmis[2]

	cChave += getUFCode(oInfNFe:_emit:_EnderEmit:_UF:text)
	cChave += substr(oInfNFe:_ide:_dHEmi:text,3,2)
	cChave += substr(oInfNFe:_ide:_dHEmi:text,6,2)
	if( type("oInfNFe:_emit:_CNPJ") <> "U" )
   		cChave += oInfNFe:_emit:_CNPJ:text + alltrim(cNFMod)
   	Else
   		if( type("oInfNFe:_emit:_CPF:text") <> "U" )
   			cChave += '000'+oInfNFe:_emit:_CPF:text + alltrim(cNFMod) 
   		endif
   	endif
	cChave += strZero(val(oInfNFe:_ide:_Serie:text),3)
	cChave += strZero(val(oInfNFe:_ide:_nNF:text),9)
	cChave += aTpEmis[1]
	cChave += strZero(val(oInfNFe:_ide:_cNF:text),8)
	cDoc_Chv	:= cChave + Modulo11(cChave)

    //MONTA ARRAY COM ITENS DA NFE
	if( valType(oInfNFe:_Det)=="A" )
		aProd := oInfNFe:_Det
	else
		aProd := {oInfNFe:_Det}
	endif

	cNFeV4 += '<infNFe versao="4.00" Id="NFe' + cDoc_Chv + '">'

	cNFeV4 += XmlNfeIde(cIdEnt, oInfNFe:_Ide, oInfNFe:_Emit, iif(type("oInfNFe:_Cobr") == "U", nil, oInfNFe:_Cobr), cNFMod, cChave, lContingencia, cModalidade,cVersaoTC,nAmbiente)
	cNFeV4 += XmlNfeEmit(oInfNFe:_Emit)
	cNFeV4 += XmlNfeDest( iif(type("oInfNFe:_Dest") == "U", Nil, oInfNFe:_Dest), @cMail, nAmbiente, cNFMod)
	cNFeV4 += XmlNfeRetirada( iif(type("oInfNFe:_Retirada") == "U", nil, oInfNFe:_Retirada) )
	cNFeV4 += XmlNfeEntrega( iif( type("oInfNFe:_Entrega") == "U", nil, oInfNFe:_Entrega) )
	cNFeV4 += autorizaDownloadNFe(oInfNFe)

	for nQtdProd := 1 to Len(aProd)
		cNFeV4 += XmlNfeItem(aProd[nQtdProd], @aImp, @aTot, lUsaColab, cNFMod, nQtdProd, nAmbiente)
	next nQtdProd

	cNFeV4 += XmlNfeTotal(oInfNFe:_Total, @aImp, @aTot)
	cNFeV4 += XmlNfeTransp(oInfNFe:_Transp)
	cNFeV4 += XmlNfeCob(iif(type("oInfNFe:_Cobr") == "U", nil, oInfNFe:_Cobr))
	cNFeV4 += XmlNfePag(oInfNFe:_pagamento)
	cNFeV4 += XmlNfeIntermed(iif(type("oInfNFe:_infIntermed") == "U", nil, oInfNFe:_infIntermed))
	cNFeV4 += XmlNfeInf(iif(type("oInfNFe:_InfAdic") == "U", nil, oInfNFe:_InfAdic), lUsaColab)
	cNFeV4 += XmlNfeExp(iif(type("oInfNFe:_exporta") == "U", nil, oInfNFe:_exporta))
	cNFeV4 += XmlNfeInfCompra(iif( type("oInfNFe:_Compra") == "U", nil, oInfNFe:_Compra))
	cNFeV4 += XmlNfeCana(iif(type("oInfNFe:_cana") == "U", nil, oInfNFe:_cana))
	cNFeV4 += "</infNFe>"
	cNFeV4 := '<NFe xmlns="http://www.portalfiscal.inf.br/nfe">' + cNFeV4
	cNFeV4 += "</NFe>"


    //Retira as tags infAdic/infAdFisco/infCpl vazias
	cNFeV4 := RetInfAdic(cNFeV4)
	aSize(aTpEmis, 0)
	aSize(aProd, 0)
	aSize(aImp, 0)
	aSize(aTot, 0)

return cNFeV4

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} XmlNfeIde()

Monta Grupo da Identificação da NFe 4.00

@param cIdEnt           Entidade da NFe
@param oIde             objeto com identificacao da NFe modelo TSS
@param oEmit            objeto com o emitente da NFe modelo TSS
@param oCobr            objeto com o grupo de cobranca da NFe modelo TSS
@param cNFMod           Modelo do XML(55=NFe, 65=NFCe)
@param cNFID            Id de identificação da NFe
@param cDoc_Chv         Referencia retorno da Chave da NFe

@return cString   XML com a Identificaçao da NFe

@author	Valter Silva
@since		21/02/2018
@version 	12.1.17

/*/
//------------------------------------------------------------------------------------------------------
static function XmlNfeIde(cIdEnt, oIde, oEmit, oCobr, cNFMod, cChave, lConting, cModalidade, cVersaoTC ,nAmbiente)

	local cString    := ""
	local cDhEmis	 := ""
	local cDhSaiEnt	 := ""
	local dDtEmis	 := CToD("")
	local dDtSaiEnt	 := CToD("")
	local cUF        := getUFCode(oEmit:_EnderEmit:_UF:text)
	local aData      :={} //Array da função FwTimeUF
	local nX         := 0

	private oXml  	 := oIde
	private oNFe_DPEC

	Default cNFMod   := "55"
	Default lConting := .F.


	cString += '<ide>'
	cString += '<cUF>' + cUF + '</cUF>'
	cString += '<cNF>' + convType(strZero(Val(oIde:_cNF:text),8,0),8,0) + '</cNF>'
	cString += '<natOp>' + oIde:_natOp:text + '</natOp>'
	cString += '<mod>' + alltrim(cNFMod) + '</mod>'
	cString += '<serie>' + oIde:_Serie:text + '</serie>'
	cString += '<nNF>' + oIde:_nNF:text + '</nNF>'

    // CASO SEJA TSS OFF-LINE IGNORA A BUSCA DA DATA DI EPEC

	if( empty(cDhEmis) )
		if( type("oXml:_dhEmi:text") <> "U" )
			dDtEmis := CToD(substr(oXml:_dhEmi:text, 9, 2) + "/" + substr(oXml:_dhEmi:text, 6, 2) + "/" + substr(oXml:_dhEmi:text, 1, 4))
			cDhEmis := colDtHrUTC(dDtEmis,substr(oXml:_dhEmi:text, 12, 8))
		else
			cDhEmis:= colDtHrUTC(dDtEmis,substr(oXml:_dhEmi:text, 12, 8))
		endif
	endif

	cString += '<dhEmi>' + cDhEmis + '</dhEmi>'

	if( type("oXml:_dhSaiEnt") <> "U" )
		dDtSaiEnt := CToD(substr(oXml:_dhSaiEnt:text,9,2)+"/"+substr(oXml:_dhSaiEnt:text,6,2)+"/"+substr(oXml:_dhSaiEnt:text,1,4))
		cDhSaiEnt := colDtHrUTC (dDtSaiEnt,substr(oXml:_dhSaiEnt:text,12,8))
		cString   += '<dhSaiEnt>' + cDhSaiEnt + '</dhSaiEnt>'
	endif

	cString += '<tpNF>' + oIde:_tpNF:text + '</tpNF>'
	cString += '<idDest>' + oIde:_idDest:text + '</idDest>'

	if( type("oXml:_cMunFG") <> "U" )
		cString += '<cMunFG>' + oIde:_cMunFG:text + '</cMunFG>'
	else
		cString += '<cMunFG>' + oEmit:_EnderEmit:_cMun:text + '</cMunFG>'
	endif

	if( type("oXml:_TpImp:text") == "U" )
		cString += '<tpImp>1</tpImp>'
	else
		cString += '<tpImp>'+oIde:_TpImp:text+'</tpImp>'
	endif

	cString += '<tpEmis>' + cModalidade + '</tpEmis>'
	cString += '<cDV>' + modulo11(cChave) + '</cDV>'
	cString += '<tpAmb>' + SubStr(ColGetPar("MV_AMBIENT","2"),1,1) + '</tpAmb>'
	cString += '<finNFe>' + oIde:_tpNFe:text + '</finNFe>'
	cString += '<indFinal>' + oIde:_indFinal:text + '</indFinal>'
	cString += '<indPres>' + oIde:_indPres:text + '</indPres>'

    if type("oXml:_indIntermed:text") == "C" .and. !empty(oXml:_indIntermed:text) //Indicador de intermediador/marketplace
        cString += '<indIntermed>' + oXml:_indIntermed:text + '</indIntermed>'
    endIf

	cString += '<procEmi>0</procEmi>'
	cString += '<verProc>' +cVersaoTC+ '</verProc>'

    If lConting 
		cString += '<dhCont>'+ColGetPar("MV_NFINCON")+'</dhCont>'
		cString += '<xJust>'+ColGetPar("MV_NFXJUST")+'</xJust>'
	EndIf
	
	/*--------------------------------------------------------------------------
                Monta o grupo NFRef
    ---------------------------------------------------------------------------*/
	cString += MontaNFRef( , cModalidade)

	cString += '</ide>'

	if(valType(oNFe_DPEC) == "O")
		freeObj(oNFe_DPEC)
		oNFe_DPEC := nil
	endif

	aSize(aData, 0)

return(cString)

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} XmlNfeEmit()

Monta Grupo da Identificação da NFe 4.00

@param oEmit        objeto com o emitente da NFe modelo TSS

@return cString     XML com o Emitente da NFe

@author	Valter Silva
@since		21/02/2018
@version 	12.1.17

/*/
//-----------------------------------------------------------------------------------------------------
static function XmlNfeEmit(oXml)

	local cString := ""

	private oEmit := oXml

	cString := '<emit>'

	if( type("oEmit:_CNPJ:text") <> "U" )
		cString += '<CNPJ>' + oEmit:_CNPJ:text + '</CNPJ>
	endif

	if( type("oEmit:_CPF:text") <> "U" )
		cString += '<CPF>' + oEmit:_CPF:text + '</CPF>
	endif

	cString += '<xNome>' + oEmit:_Nome:text + '</xNome>'
	cString += nfeTag('<xFant>', "oEmit:_Fant:text", .F.)

	cString += '<enderEmit>'
	cString += '<xLgr>' + oEmit:_EnderEmit:_Lgr:text + '</xLgr>'

	if( type("oEmit:_EnderEmit:_Nro:text") <> "U" )
		cString += nfeTag('<nro>', "oEmit:_EnderEmit:_Nro:text", .T.)
	else
		cString += '<nro>s/n</nro>'
	endif

	cString += nfeTag('<xCpl>', "oEmit:_EnderEmit:_Cpl:text")
	cString += '<xBairro>' + oEmit:_EnderEmit:_Bairro:text + '</xBairro>'
	cString += '<cMun>' + oEmit:_EnderEmit:_cMun:text + '</cMun>'
	cString += '<xMun>' + oEmit:_EnderEmit:_Mun:text + '</xMun>'
	cString += '<UF>' + oEmit:_EnderEmit:_UF:text + '</UF>'
	cString += nfeTag('<CEP>', "oEmit:_EnderEmit:_Cep:text")
	cString += nfeTag('<cPais>', "oEmit:_EnderEmit:_cPais:text")
	cString += nfeTag('<xPais>', "oEmit:_EnderEmit:_Pais:text")
	cString += nfeTag('<fone>', "convType(oEmit:_EnderEmit:_Fone:text,14,0)")
	cString += '</enderEmit>'

	cString += '<IE>' + oEmit:_IE:text + '</IE>'
	cString += nfeTag('<IEST>', "oEmit:_IEST:text", .F.)
	cString += nfeTag('<IM>'  ,"oEmit:_IM:text")
	cString += nfeTag('<CNAE>', "iif(!empty(oEmit:_IM:text),oEmit:_CNAE:text,'')")
	cString += '<CRT>' + oEmit:_CRT:text + '</CRT>'
	cString += '</emit>'

return cString

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} XmlNfeDest()

Monta Grupo do Destinatario da NFe 4.00

@param oDest            objeto com o Destinatario da NFe
@param cMail            endereço de Email para Distribuicao da NFe
@param nAmbiente        Ambiente de Emissao da NFe 1= produção; 2 = homologação
@param cNFMod           Modelo do XML 55= NFe 65= NCFe


@return cString         XML com o Destinatario da NFe

@author	Valter Silva
@since		21/02/2018
@version 	12.1.17

/*/
//-----------------------------------------------------------------------------------------------------
static function XmlNfeDest(oDest,cMail, nAmbiente,cNFMod)

	local cString := ""

	private oXml    := oDest

	if( oDest <> Nil )

		cString += '<dest>'

		if( type("oXml:_CNPJ:text") <> "U")
			if( !empty(oDest:_CNPJ:text) )
				cString += '<CNPJ>'+oDest:_CNPJ:text+'</CNPJ>'
			endif
		endif

		if(type("oXml:_CPF:text") <> "U")
			cString += nfeTag('<CPF>' ,"oXml:_CPF:text")
		endif

		if(type("oXml:_idEstrangeiro:text") <> "U")
			cString += nfeTag('<idEstrangeiro>',"convType(oXml:_idEstrangeiro:text,20)",.T.)
		endif


		if( nAmbiente == 2) // Nota Técnica 2011/002
			cString += "<xNome>NF-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL</xNome>"
		else
			if( cNFMod == "65" .and. type("oXml:_Nome:text") <> "U" )
				cString += nfeTag('<xNome>' ,"oXml:_Nome:text")
			else
				cString += '<xNome>'+oDest:_Nome:text+'</xNome>'
			endif
		endif

		/* Grupo opcional para NFCe na versão 3.10. Na NFe a obrigatoriedade continua*/
		if( type("oXml:_EnderDest") <> "U" )
			cString += '<enderDest>'
			cString += '<xLgr>' + oDest:_EnderDest:_Lgr:text + '</xLgr>'
			cString += nfeTag('<nro>', "oXml:_EnderDest:_nro:text", .T.)
			cString += nfeTag('<xCpl>', "oXml:_EnderDest:_Cpl:text")
			cString += '<xBairro>' + oDest:_EnderDest:_Bairro:text + '</xBairro>'
			cString += '<cMun>' + oDest:_EnderDest:_cMun:text+'</cMun>'
			cString += '<xMun>' + oDest:_EnderDest:_Mun:text+'</xMun>'
			cString += '<UF>' + oDest:_EnderDest:_UF:text + '</UF>'
			cString += nfeTag('<CEP>', "oXml:_EnderDest:_CEP:text")
			cString += nfeTag('<cPais>',"oXml:_EnderDest:_cPais:text")
			cString += nfeTag('<xPais>',"oXml:_EnderDest:_Pais:text")
			cString += nfeTag('<fone>',"convType(oXml:_EnderDest:_fone:text,14,0)")
			cString += '</enderDest>'
		endif

		cString += '<indIEDest>' + convType(oXml:_indIEDest:text, 1) + '</indIEDest>'

		if( type("oXml:_IE:text") <> "U" )
			cString += nfeTag('<IE>', "oXml:_IE:text")
		endif

		cString += nfeTag('<ISUF>', "oXml:_IESUF:text")
		cString += nfeTag('<IM>', "convType(oXml:_IM:text,15)")

		if( type("oXml:_eMail:text") <> "U" )
			cMail := oXml:_eMail:text
			cString += nfeTag('<email>' ,"convType(oXml:_eMail:text)")
		endif
		cString += '</dest>'

	endif

return cString

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} XmlNfeRetirada()

Monta Grupo do local de Retirada da Mercadoria

@param oRetira          objeto com dados da retirada da Mercadoria

@return cString         XML com dados da Retirada V4.00

@author	Valter Silva
@since		21/02/2018
@version 	12.1.17
/*/
//-----------------------------------------------------------------------------------------------------
static function XmlNfeRetirada(oRetira)

	local cString := ""

	private oXml    := oRetira

	if( oRetira <> Nil )

		cString := '<retirada>'

		if( type("oXml:_CNPJ:text")<>"U" )
			cString += '<CNPJ>'+oXml:_CNPJ:text+'</CNPJ>'
		elseIf type("oXml:_CPF:text")<>"U"
			cString += nfeTag('<CPF>' ,"oXml:_CPF:text")
		else
			cString += '<CNPJ></CNPJ>'
		endif
		cString += nfeTag('<xNome>', "oXML:_Nome:text")
		cString += '<xLgr>' + oRetira:_Lgr:text + '</xLgr>'

		if( type("oXml:_nro:text") <> "U" )
			cString += nfeTag('<nro>', "oXml:_nro:text", .T.)
		else
			cString += '<nro>s/n</nro>'
		endif

		cString += nfeTag('<xCpl>', "oXml:_Cpl:text")
		cString += '<xBairro>'+ oRetira:_Bairro:text + '</xBairro>'
		cString += '<cMun>' + oRetira:_cMun:text + '</cMun>'
		cString += '<xMun>' + oRetira:_Mun:text + '</xMun>'
		cString += '<UF>' + oRetira:_UF:text + '</UF>'
		cString += nfeTag('<CEP>', "oXml:_CEP:text")
        cString += nfeTag('<cPais>', "oXML:_cPais:text")
        cString += nfeTag('<xPais>', "oXML:_Pais:text")
        cString += nfeTag('<fone>', "oXML:_fone:text")
        cString += nfeTag('<email>', "oXML:_email:text")
        cString += nfeTag('<IE>', "oXML:_IE:text")
		cString += '</retirada>'

	endif

return(cString)

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} XmlNfeEntrega()

Monta Grupo do local de Entrega da Mercadoria

@param oEntrega            Objeto com os dados do local de Entrega

@return cString            XML com os dados da entrega

@author	Valter Silva
@since		21/02/2018
@version 	12.1.17
/*/
//-----------------------------------------------------------------------------------------------------
static function XmlNfeEntrega(oEntrega)

	local cString := ""

	private oXml

	if( oEntrega <> Nil )

		oXml  := oEntrega

		cString := '<entrega>'

		if type("oXML:_CNPJ:text") <> "U" .and. !empty(oXML:_CNPJ:text)
			cString += '<CNPJ>' + oXml:_CNPJ:text + '</CNPJ>
		elseIf type("oXml:_CPF:text") <> "U" .and. !empty(oXml:_CPF:text)
			cString += '<CPF>' + oXml:_CPF:text + '</CPF>
		else
			cString += '<CNPJ></CNPJ>'
		endif
		
		cString += nfeTag('<xNome>', "oXML:_Nome:text")
		cString += '<xLgr>' + oXML:_Lgr:text + '</xLgr>'

		if type("oXml:_nro:text") <> "U"
			cString += nfeTag('<nro>', "oXml:_nro:text", .T.)
		else
			cString += '<nro>s/n</nro>'
		endif

		cString += nfeTag('<xCpl>', "oXml:_Cpl:text")
		cString += '<xBairro>' +oEntrega:_Bairro:text + '</xBairro>'
		cString += '<cMun>' + oEntrega:_cMun:text + '</cMun>'
		cString += '<xMun>' + oEntrega:_Mun:text + '</xMun>'
		cString += '<UF>' + oEntrega:_UF:text + '</UF>'
		cString += nfeTag('<CEP>', "oXml:_CEP:text")
        cString += nfeTag('<cPais>', "oXML:_cPais:text")
        cString += nfeTag('<xPais>', "oXML:_Pais:text")
        cString += nfeTag('<fone>', "oXML:_fone:text")
        cString += nfeTag('<email>', "oXML:_email:text")
        cString += nfeTag('<IE>', "oXML:_IE:text")
		cString += '</entrega>'

	endif

return cString


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} autorizaDownloadNFe()

Monta Grupo com  pessoas autorizadas a baixar o XML da NFe

@param oNFe        Objeto com os dados da NFe

@return cString    XML com a autorização

@author	Valter Silva
@since		21/02/2018
@version 	12.1.17

/*/
//-----------------------------------------------------------------------------------------------------
static function autorizaDownloadNFe(oNFe)

	local aAutXml := {}
	local nI
	local cString := ""

	private oXml := oNFe

	if( type("oXml:_autxml") <> "U" )

		if valType(oNFe:_autxml) == "A"
			aAutXml := oNFe:_autxml
		else
			aAutXml := {oNFe:_autxml}
		endif

		for nI := 1 To Len(aAutXml)
			cString += XmlNfeAut(aAutXml[nI])
		next nI

        /*NT2015/002 - Grupo Obrigatório para Sefaz BA -
        Caso o grupo não seja informado, será criado com o CNPJ da Sefaz BA

        Rejeicao 486: Não informado o Grupo de Autorização para UF que exige a
        identificação do Escritório de Contabilidade na Nota Fiscal
        */
	elseIf( type("oNFe:_autxml") == "U" ) .and. (oNFe:_Emit:_EnderEmit:_UF:text $ "29" )
		cString += '<autXML>'
		cString += '<CNPJ>13937073000156</CNPJ>'
		cString += '</autXML>'
	endif

	aSize(aAutXml, 0)

return cString

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} XmlNfeItem()

Monta Grupo com  os Itens da NFe/NFCe

@param oDet            Objeto com os Itens da NFe
@param aImp            Referencia para retorno dos impostos por item
@param aTot            Referencia para retorno da soma de valores dos itens
@param lUsaColab       Indica se a NFe é do modelo TOTVS Colaboração
@param cNFMod          Modelo do XML 55= NFe 65 = NFCe
@param nQtdProd        Total de Itens da Nota
@param nAmbiente       Ambiente de Transmissão da NFe



@return cString   XML com Itens da NFe

@author	Valter Silva
@since		21/02/2018
@version 	12.1.17
/*/
//-----------------------------------------------------------------------------------------------------
static function XmlNfeItem(oDet, aImp, aTot, lUsaColab, cNFMod, nQtdProd, nAmbiente)

	local aNVE         := {}
	local cGrupo       := ""
	local nDI          := 0
	local nAdi         := 0
	local nArma		   := 0
	local nveicProd    := 0
	local nI		   := 0
	local nValPis      := 0
	local nValCof      := 0
	local nDetExp      := 0
	local lPIS         := .F.
	local lCofins      := .F.
	local nICMSDeson   := 0
	local nRastro

	Default lUsaColab  := .F.
	Default cNFMod     := ""
	Default nQtdProd   := 0
	Default nAmbiente  := 0

	private aImposto   := {}
	private aAdi       := {}
	private aDI        := {}
	private aArma      := {}
	private aveicProd  := {}
	private aDetExport := {}
	private oExpInd
	private oXml       := oDet
	private aRastro    := {}
	private cEAN       := ""
	private cString    := ""
	private nX	       := 0
	private nY	       := 0


    /*-------------------------------------------------------------------------------------------
                GRUPO PRODUTOS
    --------------------------------------------------------------------------------------------*/
	cString += '<det nItem="' + oDet:_nItem:text + '">'
	cString += '<prod>'
	cString += '<cProd>' + oDet:_Prod:_cprod:text + '</cProd>'

	cEAN := AllTrim(oDet:_Prod:_EAN:text)
	if empty(cEAN)
		cEAN := "SEM GTIN"
	endif
	cString += '<cEAN>'  +cEAN+'</cEAN>'
    if( !type("oXml:_Prod:_cBarra:text") == "U" .and. !empty(oXml:_Prod:_cBarra:text) )
        cString += nfeTag('<cBarra>',"convType(oXml:_Prod:_cBarra:text, 30)")
    endif

    /* Nota Técnica 2015/002
    Para a NFC-e, se ambiente de homologação:
    - Descrição do primeiro item da Nota Fiscal (tag:xProd) deve ser informada como
    “NOTA FISCAL EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL”*/
	if nAmbiente == 2 .and. cNFMod == "65" .and. nQtdProd = 1
		cString += "<xProd>NOTA FISCAL EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL</xProd>"
	else
		cString += '<xProd>' + oDet:_Prod:_prod:text + '</xProd>'
	endif

	cString += '<NCM>' + oXml:_Prod:_ncm:text + '</NCM>'

	if( type("oDet:_nve") <> "U" )

		if( valType(oDet:_nve) == "A" )
			aNVE := oDet:_nve
		else
			aNVE := {oDet:_nve}
		endif

		for nI := 1 To Len(aNVE)
			cNewXML += nfeTag('<NVE>', "convType(aNVE[nI]:text,6)")
		next nI

	endif

    //Nova Tag - Nota Técnica 2015/003_v1.10
	cString += nfeTag('<CEST>',"convType(oXml:_Prod:_CEST:text,7)")
	cString += nfeTag('<indEscala>', "oXml:_Prod:_indEscala:text", .F.)
	cString += nfeTag('<CNPJFab>', "oXml:_Prod:_CNPJFab:text")
	cString += nfeTag('<cBenef>',"oXml:_Prod:_cBenef:text",.T.)
	cString += nfeTag('<EXTIPI>',"oXml:_Prod:_extipi:text")
	cString += '<CFOP>'  +oDet:_Prod:_cfop:text+'</CFOP>'
	cString += nfeTag('<uCom>',"oXml:_Prod:_uCom:text", .T.)

	if type("oXml:_Prod:_qCom:text") <> "U"
		cString += nfeTag('<qCom>',"convType(Val(oXml:_Prod:_qCom:text),15,4)", .T.)
	else
		cString += "<qCom>0.0000</qCom>"
	endif

	if type("oXml:_Prod:_vUnCom:text") <> "U"
		cString += nfeTag('<vUnCom>', "convType(oXml:_Prod:_vUnCom:text,21,10,'N')" ,.T.)
	else
		cString += "<vUnCom>0.0000</vUnCom>"
	endif

	cString += '<vProd>' + convType(Val(oDet:_Prod:_vProd:text), 15, 2) + '</vProd>'

	if( type("oXml:_Prod:_EANTrib:text") <> "U"	)

		cEAN := AllTrim(oXml:_Prod:_EANTrib:text)

 		if empty(cEAN)
			cEAN := "SEM GTIN"
		endif
    Else
        cEAN := "SEM GTIN"
    endif

	cString += nfeTag('<cEANTrib>',"cEAN", .T.)
	if( !type("oXml:_Prod:_cBarraTrib:text") == "U" .and. !empty(oXml:_Prod:_cBarraTrib:text) )
		cString += nfeTag('<cBarraTrib>',"convType(oXml:_Prod:_cBarraTrib:text, 30)")
	endif

	cString += '<uTrib>' + oDet:_Prod:_uTrib:text + '</uTrib>'
	cString += '<qTrib>' + convType(Val(oDet:_Prod:_qTrib:text), 15, 4) + '</qTrib>'
	cString += nfeTag('<vUnTrib>',"convType(oXml:_Prod:_vUnTrib:text,21,10,'N')",.T.)
	cString += nfeTag('<vFrete>',"convType(Val(oXml:_Prod:_vFrete:text),15,2)")
	cString += nfeTag('<vSeg>'  ,"convType(Val(oXml:_Prod:_vSeg:text),15,2)")
	cString += nfeTag('<vDesc>' ,"convType(Val(oXml:_Prod:_vDesc:text),15,2)")
	cString += nfeTag('<vOutro>' ,"convType(Val(oXml:_Prod:_vOutro:text),15,2)")
	cString += '<indTot>'+oDet:_Prod:_indTot:text+'</indTot>'


    /*----------------------------------------------------------------------------
                Monta a tag de DI
    ------------------------------------------------------------------------------*/
	if( type("oXml:_Prod:_DI") <> "U" )

		if( valType(oXml:_Prod:_DI) == "A" )
			aDI := oXml:_Prod:_DI
		else
			aDI := {oXml:_Prod:_DI}
		endif

		if( valType(oXml:_Prod:_DI:_adicao) == "A" )
			aAdi := oXml:_Prod:_DI:_adicao
		else
			aAdi := {oXml:_Prod:_DI:_adicao}
		endif

		for nDI := 1 To Len(aDI)

			cString += '<DI>'
			cString += '<nDI>' +aDI[nDI]:_ndi:text+'</nDI>'
			cString += '<dDI>' +aDI[nDI]:_dtdi:text+'</dDI>'
			cString += '<xLocDesemb>' +aDI[nDI]:_LocDesemb:text+'</xLocDesemb>'
			cString += '<UFDesemb>' +aDI[nDI]:_UFDesemb:text+'</UFDesemb>'
			cString += '<dDesemb>' +aDI[nDI]:_dtDesemb:text+'</dDesemb>'

			cString += '<tpViaTransp>' + convType(aDI[nDI]:_viaTransp:text,2) + '</tpViaTransp>'

			if( Val( aDI[nDI]:_viaTransp:text ) == 1 )	// Via de Transporte Maritima

				if( type( "aDI["+cValToChar(nDI)+"]:_AFRMM:text" ) <> "U" .and. Val(aDI[nDI]:_AFRMM:text) > 0 )
					cString += '<vAFRMM>' + convType(Val(aDI[nDI]:_AFRMM:text),15,2) + '</vAFRMM>'
				else
					cString += '<vAFRMM>0</vAFRMM>'
				endif

			else
				cString +=  nfeTag('<vAFRMM>',"convType(Val(aDI["+Alltrim(str(nDI))+"]:_AFRMM:text),15,2)")
			endif

			cString += '<tpIntermedio>' + convType(aDI[nDI]:_Intermedio:text,2) + '</tpIntermedio>'
			cString +=  nfeTag('<CNPJ>',"convType(aDI["+Alltrim(str(nDI))+"]:_CNPJ:text,14)")
			cString +=  nfeTag('<UFTerceiro>',"convType(aDI["+Alltrim(str(nDI))+"]:_UFTerceiro:text,2)")

			cString += '<cExportador>' +aDI[nDI]:_Exportador:text+'</cExportador>'

			for nAdi := 1 To Len(aAdi)

				cString += '<adi>'
                if !empty(aAdi[nAdi]:_Adicao:text) .and. val(aAdi[nAdi]:_Adicao:text) > 0
					cString += '<nAdicao>' +aAdi[nAdi]:_Adicao:text+'</nAdicao>'
                endif
				cString += '<nSeqAdic>' +aAdi[nAdi]:_SeqAdic:text+'</nSeqAdic>'
				cString += '<cFabricante>' +aAdi[nAdi]:_Fabricante:text+'</cFabricante>'
				cString += nfeTag('<vDescDI>' ,"convType(Val(aAdi[nAdi]:_vDescDI:text),15,2)")

                cString += nfeTag('<nDraw>' ,"convType(aAdi["+Alltrim(str(nAdi))+"]:_Draw:text,20)")

				cString += '</adi>'
			next nAdi

			cString += '</DI>'

		next nDi

	endif


    /*----------------------------------------------------------------------------
                GRUPO DETALHES DA EXPORTACAO
    ------------------------------------------------------------------------------*/
	if( type("oXml:_Prod:_detExport") <> "U" )

		if( valType(oXml:_Prod:_detExport) == "A" )
			aDetExport := oXml:_Prod:_detExport
		else
			aDetExport := {oXml:_Prod:_detExport}
		endif

		for nDetExp := 1 To Len(aDetExport)

			cString += '<detExport>'
			cString += nfeTag('<nDraw>' ,"convType(aDetExport["+Alltrim(str(nDetExp))+"]:_Draw:text,20)")

			if( type("oXml:_Prod:_detExport:_exportInd") <> "U" )

				oExpInd := oXml:_Prod:_detExport:_exportInd
				cString += '<exportInd>'
				cString += '<nRE>' + convType(oExpInd:_nre:text,12) + '</nRE>'
				cString += '<chNFe>' + convType(oExpInd:_chNFe:text,44) + '</chNFe>'
				cString += '<qExport>' + convType(Val(oExpInd:_qExport:text),15,4) + '</qExport>'
				cString += '</exportInd>'

			elseIf type("oXml:_Prod:_detExport["+Alltrim(str(nDetExp))+"]:_exportInd")<>"U"

				oExpInd := oXml:_Prod:_detExport[nDetExp]:_exportInd
				cString += '<exportInd>'
				cString += '<nRE>' + convType(oExpInd:_nre:text,12) + '</nRE>'
				cString += '<chNFe>' + convType(oExpInd:_chNFe:text,44) + '</chNFe>'
				cString += '<qExport>' + convType(Val(oExpInd:_qExport:text),15,4) + '</qExport>'
				cString += '</exportInd>'
			endif

			cString +=	'</detExport>'

		next nDetExp
	endif


    /*--------------------------------------------------------------------------------
                TAGS PEDIDO DE COMPRA
    --------------------------------------------------------------------------------*/
	if type("oXml:_Prod:_xPed:text")<>"U"
		cString += '<xPed>' + oXml:_Prod:_xPed:text + '</xPed>'
	endif

	if type("oXml:_Prod:_nItemPed:text")<>"U"
		cString += '<nItemPed>' + oXml:_Prod:_nItemPed:text + '</nItemPed>'
	endif


    /*--------------------------------------------------------------------------------
                TAG FICHA DE CONTROLE DE IMPORTAÇÃO
    --------------------------------------------------------------------------------*/
	if type("oXml:_Prod:_nFCI:text") <> "U"
		cString += '<nFCI>'+oXml:_Prod:_nFCI:text + '</nFCI>'
	endif


    /*---------------------------------------------------------------------------------
                     GRUPO RASTRO DE PRODUTO //NFe 4.00
     ---------------------------------------------------------------------------------*/
	if( type("oXml:_Prod:_rastro")  == "O" )
		aRastro := {oXml:_Prod:_rastro}

	elseIf(type("oXml:_Prod:_rastro")  == "A")
		aRastro := oXml:_Prod:_rastro

	endif

	for nRastro := 1 to len(aRastro)
		cString += '<rastro>'
		cString += '<nLote>' + aRastro[nRastro]:_nLote:text + '</nLote>'
		cString += '<qLote>' + convType(aRastro[nRastro]:_qLote:text, 11, 3) + '</qLote>'
		cString += '<dFab>' + aRastro[nRastro]:_dFab:text + '</dFab>'
		cString += '<dVal>' + aRastro[nRastro]:_dVal:text + '</dVal>'
		cString += nfeTag('<cAgreg>',"aRastro[" + alltrim(str(nRastro)) +" ]:_cAgreg:text")
		cString += '</rastro>'
	next



    /*------------------------------------------------------------------------------------
                    GRUPO VEICULOS NOVOS
    -------------------------------------------------------------------------------------*/
	if(type("oXml:_Prod:_veicProd") == "O")
		aVeicProd := {oXml:_Prod:_veicProd}

	elseIf(type("oXml:_Prod:_veicProd") == "A")
		aVeicProd := oXml:_Prod:_veicProd

	endif

	for nveicProd := 1 To Len(aveicProd)

		nY := nveicProd

		cString += '<veicProd>'
		cString += nfeTag('<tpOp>'   ,"convType(aVeicProd[nY]:_tpOp:text,1)"   , .T.)
		cString += nfeTag('<chassi>' ,"convType(aVeicProd[nY]:_chassi:text,17)", .T.)
		cString += nfeTag('<cCor>'   ,"convType(aVeicProd[nY]:_cCor:text,4)"   , .T.)
		cString += nfeTag('<xCor>'   ,"convType(aVeicProd[nY]:_xCor:text,40)"  , .T.)
		cString += nfeTag('<pot>'    ,"convType(aVeicProd[nY]:_pot:text,4)"    , .T.)
		cString += nfeTag('<cilin>'    ,"convType(aVeicProd[nY]:_cilin:text,4)", .T.)
		cString += nfeTag('<pesoL>'  ,"convType(aVeicProd[nY]:_pesol:text,9)"  , .T.)
		cString += nfeTag('<pesoB>'  ,"convType(aVeicProd[nY]:_pesob:text,9)"  , .T.)
		cString += nfeTag('<nSerie>' ,"convType(aVeicProd[nY]:_nserie:text,9)" , .T.)
		cString += nfeTag('<tpComb>' ,"convType(aVeicProd[nY]:_tpcomb:text,2)" , .T.)
		cString += nfeTag('<nMotor>' ,"convType(aVeicProd[nY]:_nmotor:text,21)", .T.)
		cString += nfeTag('<CMT>'   ,"convType(aVeicProd[nY]:_CMT:text,9)"   , .T.)
		cString += nfeTag('<dist>'   ,"convType(aVeicProd[nY]:_dist:text,4)"   , .T.)
		cString += nfeTag('<anoMod>' ,"convType(aVeicProd[nY]:_anomod:text,4)" , .T.)
		cString += nfeTag('<anoFab>' ,"convType(aVeicProd[nY]:_anofab:text,4)" , .T.)
		cString += nfeTag('<tpPint>' ,"convType(aVeicProd[nY]:_tppint:text,1)" , .T.)
		cString += nfeTag('<tpVeic>' ,"convType(aVeicProd[nY]:_tpveic:text,2)" , .T.)
		cString += nfeTag('<espVeic>',"convType(aVeicProd[nY]:_espvei:text,1)" , .T.)
		cString += nfeTag('<VIN>'    ,"convType(aVeicProd[nY]:_vin:text,1)"    , .T.)
		cString += nfeTag('<condVeic>',"convType(aVeicProd[nY]:_condvei:text,1)", .T.)
		cString += nfeTag('<cMod>'   ,"convType(aVeicProd[nY]:_cmod:text,6)"   , .T.)
		cString += nfeTag('<cCorDENATRAN>'   ,"convType(aVeicProd[nY]:_cCorDENATRAN:text,2)"   ,.T.)
		cString += '<lota>'+aVeicProd[nY]:_lota:text+'</lota>'
		cString += nfeTag('<tpRest>'   ,"convType(aVeicProd[nY]:_tpRest:text,1)"   ,.T.)
		cString += '</veicProd>'

	next nveicProd

    /*--------------------------------------------------------------------------------------------------
                GRUPO MEDICAMENTOS
    ---------------------------------------------------------------------------------------------------*/
	if type("oXml:_Prod:_med") <> "U"
		cString += '<med>'
		cString += '<cProdANVISA>' + oXml:_Prod:_med:_cProdANVISA:text + '</cProdANVISA>'
		cString += nfeTag('<xMotivoIsencao>',"oXml:_Prod:_med:_MotivoIsencao:text")
		cString += '<vPMC>' + convType(val(oXml:_Prod:_med:_vPMC:text), 15, 2) + '</vPMC>'
		cString += '</med>'

	endif


    /*---------------------------------------------------------------------------------------------------
                GRUPO ARMAMENTOS
    ----------------------------------------------------------------------------------------------------*/
	if type("oXml:_Prod:_arma")<>"U"
		if 	valType(oXml:_Prod:_arma)=="A"
			aArma := oXml:_Prod:_arma
		else
			aArma := {oXml:_Prod:_arma}
		endif
		for nArma := 1 To Len(aArma)
			nY := nArma
			cString += '<arma>'
			cString += '<tpArma>' + aArma[nY]:_tpArma:text + '</tpArma>'
			cString += '<nSerie>' + aArma[nY]:_nSerie:text + '</nSerie>'
			cString += '<nCano>' + aArma[nY]:_nCano:text + '</nCano>'
			cString += '<descr>' + aArma[nY]:_descr:text + '</descr>'
			cString += '</arma>'
		next nArma
	endif


    /*------------------------------------------------------------------------------------------------------
                GRUPO COMBUSTIVEIS
    -------------------------------------------------------------------------------------------------------*/
	if type("oXml:_Prod:_comb") <> "U"
		cString += '<comb>'
		cString += '<cProdANP>' + oXml:_Prod:_comb:_cProdANP:text + '</cProdANP>'
		cString += '<descANP>' + oXml:_Prod:_comb:_descANP:text + '</descANP>'
		cString += nfeTag('<pGLP>',"convType(val(oXml:_Prod:_comb:_pGLP:text), 8, 4)")
		cString += nfeTag('<pGNn>',"convType(val(oXml:_Prod:_comb:_pGNn:text), 8, 4)")
		cString += nfeTag('<pGNi>',"convType(val(oXml:_Prod:_comb:_pGNi:text), 8, 4)")
		cString += nfeTag('<vPart>',"convType(val(oXml:_Prod:_comb:_vPart:text), 15, 2)")
		cString += nfeTag('<CODIF>',"oXml:_Prod:_comb:_CODIF:text")
		cString += nfeTag('<qTemp>',"convType(val(oXml:_Prod:_comb:_qTemp:text), 16, 4)")
		cString += '<UFCons>' + oXml:_Prod:_comb:_ICMSCons:_UFCons:text + '</UFCons>'

		if type("oXml:_Prod:_comb:_CIDE")<>"U"
			cString += '<CIDE>'
			cString += '<qBCProd>' + convType(val(oXml:_Prod:_comb:_CIDE:_qBCProd:text),16,4)+'</qBCProd>'
			cString += '<vAliqProd>'+convType(val(oXml:_Prod:_comb:_CIDE:_vAliqProd:text),15,4)+'</vAliqProd>'
			cString += '<vCIDE>'+ convType(val(oXml:_Prod:_comb:_CIDE:_vCIDE:text),15,2)+'</vCIDE>'
			cString += '</CIDE>'
		endif
        //Novo Grupo NT2015/002
		if type("oXml:_Prod:_comb:_encerrante") <> "U"
			cString += '<encerrante>'
			cString += '<nBico>'+oXml:_Prod:_comb:_encerrante:_nBico:text+'</nBico>'
			cString += nfeTag('<nBomba>',"oXml:_Prod:_comb:_encerrante:_nBomba:text")
			cString += '<nTanque>'+oXml:_Prod:_comb:_encerrante:_nTanque:text+'</nTanque>'
			cString += '<vEncIni>'+convType(Val(oXml:_Prod:_comb:_encerrante:_vEncIni:text),15,3)+'</vEncIni>'
			cString += '<vEncFin>'+convType(Val(oXml:_Prod:_comb:_encerrante:_vEncFin:text),15,3)+'</vEncFin>'
			cString += '</encerrante>'
		endif
		cString += '</comb>'
	endif


    /*-----------------------------------------------------------------------------------
                GRUPO RECOPI
    ------------------------------------------------------------------------------------*/
	if type("oXml:_Prod:_RECOPI:_nrecopi")<>"U"
		cString += '<nRECOPI>' + convType(oXml:_Prod:_RECOPI:_nrecopi:text) + '</nRECOPI>'
	endif

	cString += '</prod>'


    /*------------------------------------------------------------------------------------
                GRUPO IMPOSTOS
    --------------------------------------------------------------------------------------*/
	cString += '<imposto>'
	cString += nfeTag('<vTotTrib>' ,"convType(Val(oXml:_Prod:_vTotTrib:text),15,2)")
	if valType(oXml:_Imposto)=="A"
		aImposto := oXml:_Imposto
	else
		aImposto := {oXml:_Imposto}
	endif

    // Atribui os totais
	if oDet:_Prod:_indTot:text == "1"

		nX := Ascan(aImposto,{|o| o:_Codigo:text == "ISS"})

		if nX > 0 .and. cNFMod == "65"
			aTot[1] += 0
		else
			aTot[1] += Val(oDet:_Prod:_vProd:text)
		endif

	endif

	aTot[2] += Val(iif(type("oXml:_Prod:_vFrete:text")=="U","0",oDet:_Prod:_vFrete:text))
	aTot[3] += Val(iif(type("oXml:_Prod:_vSeg:text")  =="U","0",oDet:_Prod:_vSeg:text))
	aTot[4] += Val(iif(type("oXml:_Prod:_vDesc:text") =="U","0",oDet:_Prod:_vDesc:text))
	aTot[5] += Val(iif(type("oXml:_Prod:_vTotTrib:text") =="U","0",oDet:_Prod:_vTotTrib:text))

	nX := Ascan(aImposto,{|o| o:_Codigo:text == "ICMS"})

    	if( nX > 0 ) .And. !(aImposto[nX]:_Tributo:_CST:text == "60" .And.  type("oXml:_Prod:_comb") <> "U"  .And. Ascan(aImposto,{|o| o:_Codigo:text == "ICMSST60"}) > 0 )

		nY := aScan(aImposto,{|x| x:_codigo:text == "ICMSST"})
		aImposto[nX]:_Tributo:_CST:text := Alltrim( aImposto[nX]:_Tributo:_CST:text )
		cGrupo  := aImposto[nX]:_Tributo:_CST:text

		if( cGrupo $ "40,41,50" )
			cGrupo := "40"
		endif

		cString += '<ICMS>'
		cString += '<ICMS' +cGrupo + '>'
		cString += '<orig>' + aImposto[nX]:_Cpl:_orig:text + '</orig>'
		cString += '<CST>' + aImposto[nX]:_Tributo:_CST:text + '</CST>'

		if( aImposto[nX]:_Tributo:_CST:text$"00,10,20,70,90" .Or. (aImposto[nX]:_Tributo:_CST:text == "51") )

			if(	NfeDifSefaz( aImposto,'4.00',nX ) )
				cString += '<modBC>'  +aImposto[nX]:_Tributo:_MODBC:text+'</modBC>'
			endif

		endif

		if( aImposto[nX]:_Tributo:_CST:text $ "00,10" )
			cString += '<vBC>' + convType(Val(aImposto[nX]:_Tributo:_vBC:text), 15, 2) + '</vBC>'

		elseIf( aImposto[nX]:_Tributo:_CST:text$"20,70" .Or. (aImposto[nX]:_Tributo:_CST:text == "51") )

			if( NfeDifSefaz( aImposto,'4.00', nX ) )

				if (type("aImposto[nX]:_Tributo:_PREDBC") <> "U" )
					cString += nfeTag('<pRedBC>',"convType(Val(aImposto[nX]:_Tributo:_PREDBC:text),7,4)",.T.)
				endif
				
			endif

			if( NfeDifSefaz( aImposto,'4.00', nX ) )
				cString += '<vBC>'    +convType(Val(aImposto[nX]:_Tributo:_vBC:text),15,2)+'</vBC>'
			endif

		elseIf( aImposto[nX]:_Tributo:_CST:text$"90")
			cString += '<vBC>'    +convType(Val(aImposto[nX]:_Tributo:_vBC:text),15,2)+'</vBC>'
			cString += nfeTag('<pRedBC>',"convType(Val(aImposto[nX]:_Tributo:_PREDBC:text),7,4)")
		endif

		if( aImposto[nX]:_Tributo:_CST:text$"00,10,20,51,70,90" )

			if( NfeDifSefaz( aImposto,'4.00',nX ) )

				cString += '<pICMS>'  +convType(Val(aImposto[nX]:_Tributo:_Aliquota:text),7,4)+'</pICMS>'

				if aImposto[nX]:_Tributo:_CST:text == "51"

                    If Type("aImposto[nX]:_Tributo:_pDif:text") <> "U" .And. Type("aImposto[nX]:_Tributo:_vICMSDif:text") <> "U" .And. ;
                        Type("aImposto[nX]:_Tributo:_vICMSOp:text") <> "U" 

                        If aImposto[nX]:_Tributo:_MODBC:text == "2"//Caso os valores os valores estejam zerados, tambem deverao ser geradas as tags quando ModBc = 2
                            cString += '<vICMSOp>'  + convType(Val(aImposto[nX]:_Tributo:_vICMSOp:text),15,2)  + '</vICMSOp>'
                            cString += '<pDif>'     + convType(Val(aImposto[nX]:_Tributo:_pDif:text),8,4)      + '</pDif>'
                            cString += '<vICMSDif>' + convType(Val(aImposto[nX]:_Tributo:_vICMSDif:text),15,2) + '</vICMSDif>'
                        Else
                            cString += nfeTag('<vICMSOp>',"convType(Val(aImposto[nX]:_Tributo:_vICMSOp:text),15,2)",.F.)
                            cString += nfeTag('<pDif>',"convType(Val(aImposto[nX]:_Tributo:_pDif:text),8,4)",.T.)
                            cString += nfeTag('<vICMSDif>',"convType(Val(aImposto[nX]:_Tributo:_vICMSDif:text),15,2)",.T.)
                        EndIf    
                    EndIf
                endif

			endif

            /*Na versão 3.10, para CST=51, O Valor do ICMS(vICMS) deve ser a diferença do Valor do ICMS da Operação (vICMSOp) e o Valor do ICMS diferido (vICMSDif),
            para não apresentar a rejeição 353-Valor do ICMS no CST=51 não corresponde a diferença do ICMS operação e ICMS diferido*/
			if( NfeDifSefaz( aImposto,'4.00',nX ) )

				cString += '<vICMS>'  +convType(Val(aImposto[nX]:_Tributo:_Valor:text),15,2)+'</vICMS>'

				if type("aImposto[nX]:_Tributo:_pFCP:text") <> "U" .and. val(aImposto[nX]:_Tributo:_pFCP:text) > 0
					if(aImposto[nX]:_Tributo:_CST:text $ "10,20,51,70,90")
						cString += nfeTag('<vBCFCP>',"convType(val(aImposto[nX]:_Tributo:_vBCFCP:text), 16, 2)", .T.)
					endif

					if( type("aImposto[nX]:_Tributo:_vFCP:text") <> "U" )
						aImp[13][1] += val(aImposto[nX]:_Tributo:_vFCP:text)
					endif

					cString += nfeTag('<pFCP>', "convType(val(aImposto[nX]:_Tributo:_pFCP:text), 8, 4)", .T.)
					cString += nfeTag('<vFCP>', "convType(val(aImposto[nX]:_Tributo:_vFCP:text), 17, 2)", .T.)
				endif

                if (aImposto[nX]:_Tributo:_CST:text $ "51") .and. !type("aImposto[nX]:_Tributo:_pFCPDif:text") == "U" .and. !type("aImposto[nX]:_Tributo:_vFCPDif:text") == "U" .and. !type("aImposto[nX]:_Tributo:_vFCPEfet:text") == "U"
             		cString += '<pFCPDif>' + convType(val(aImposto[nX]:_Tributo:_pFCPDif:text), 8, 4) + '</pFCPDif>'
             		cString += '<vFCPDif>' + convType(val(aImposto[nX]:_Tributo:_vFCPDif:text), 16, 2) + '</vFCPDif>'
                    cString += '<vFCPEfet>' + convType(val(aImposto[nX]:_Tributo:_vFCPEfet:text), 16, 2) + '</vFCPEfet>'
                endif

            endif
			if( aImposto[nX]:_Tributo:_CST:text $ "20" )
                if type('aImposto[nX]:_Tributo:_vICMSDeson:text') <> "U" .and. type('aImposto[nX]:_Tributo:_motDesICMS:text') <> 'U'
                    cString += nfeTag('<vICMSDeson>' ,"convType(Val(aImposto[nX]:_Tributo:_vICMSDeson:text),15,2)",.T.)
                endif
				cString += nfeTag('<motDesICMS>' ,"aImposto[nX]:_Tributo:_motDesICMS:text")
				aImp[1][3] += Val(iif(type("aImposto[nX]:_Tributo:_vICMSDeson:text")=="U","0",aImposto[nX]:_Tributo:_vICMSDeson:text))
			endif

			if( aImposto[nX]:_Tributo:_CST:text <> "51" )

				if 	NfeDifSefaz( aImposto,'4.00',nX )
					aImp[1][1] += Val(iif(type("aImposto[nX]:_Tributo:_vBC:text")  =="U","0",aImposto[nX]:_Tributo:_vBC:text))
					aImp[1][2] += Val(iif(type("aImposto[nX]:_Tributo:_valor:text")=="U","0",aImposto[nX]:_Tributo:_valor:text))
				endif

			else

				aImp[1][1] += Val(iif(type("aImposto[nX]:_Tributo:_vBC:text")  =="U","0",aImposto[nX]:_Tributo:_vBC:text))

                /*Nesta versão, a tag vICMS no grupo de totais deve ser gerada quando a tag vICMSDif estiver preenchida
                para não apresentar a rejeição 532-Total do ICMS difere do somatório dos itens*/
				if type("aImposto[nX]:_Tributo:_vICMSDif:text") <> "U" .and. !empty(aImposto[nX]:_Tributo:_vICMSDif:text)
					aImp[1][2] += Val(iif(type("aImposto[nX]:_Tributo:_valor:text")=="U","0",aImposto[nX]:_Tributo:_valor:text))
				endif

			endif

		endif

		if( aImposto[nX]:_Tributo:_CST:text $ "40,41,50" )

            // Alterado o nome da tag vICMS para vICMSDeson no leiaute 3.10 para este grupo de tributação
            // Nota Tecnica 2013/005 - "Se informado tag:motDesICMS, o vICMSDeson deve ser maior do que zero"
			if( type( "aImposto[nX]:_Tributo:_motDesICMS:text" ) <> "U" .and. !empty( aImposto[nX]:_Tributo:_motDesICMS:text ) )

				nICMSDeson := Val(iif(type("aImposto[nX]:_Tributo:_Valor:text")=="U","0",aImposto[nX]:_Tributo:_Valor:text))

				aImp[1][3]	+= nICMSDeson
				if type('aImposto[nX]:_Tributo:_Valor:text') <> "U"
					cString 	+= nfeTag('<vICMSDeson>', "convType(Val(aImposto[nX]:_Tributo:_Valor:text),15,2)",.T.)
				endif
				cString 	+= nfeTag('<motDesICMS>', "aImposto[nX]:_Tributo:_motDesICMS:text")

			endif

		endif

		if( aImposto[nX]:_Tributo:_CST:text $ "10,30,70" .and. nY > 0 )
			cString += '<modBCST>' + aImposto[nY]:_Tributo:_MODBC:text + '</modBCST>'
			cString += nfeTag('<pMVAST>'  , "convType(Val(aImposto[nY]:_Cpl:_PMVAST:text),8,4)")
			cString += nfeTag('<pRedBCST>', "convType(Val(aImposto[nY]:_Tributo:_PREDBC:text),7,4)")
		endif

		if( aImposto[nX]:_Tributo:_CST:text $ "10,30,60,70" .and. nY > 0 )

			if( aImposto[nX]:_Tributo:_CST:text $ "60" )
			 	if  type("aImposto[nY]:_Tributo:_pST:text") <> "U"
					if type("aImposto[nY]:_Tributo:_vBC:text") <> "U"
						cString +=  '<vBCSTRet>' + convType(Val(aImposto[nY]:_Tributo:_vBC:text),15,2) + '</vBCSTRet>'
					endif
					cString += nfeTag('<pST>',"convType(Val(aImposto[nY]:_Tributo:_pST:text), 7, 4,'',.T.)",.T.) 
				endif
			else
				cString += '<vBCST>'  +convType(Val(aImposto[nY]:_Tributo:_vBC:text),15,2)+'</vBCST>'
			endif

		endif

		if( aImposto[nX]:_Tributo:_CST:text$"10,30,70" .and. nY > 0 )
			cString += '<pICMSST>'+convType(Val(aImposto[nY]:_Tributo:_Aliquota:text),7,4)+'</pICMSST>'
			aImp[2][1] += Val(iif(type("aImposto[nY]:_Tributo:_vBC:text")  =="U","0",aImposto[nY]:_Tributo:_vBC:text))
			aImp[2][2] += Val(iif(type("aImposto[nY]:_Tributo:_valor:text")=="U","0",aImposto[nY]:_Tributo:_valor:text))
		endif

		if( aImposto[nX]:_Tributo:_CST:text$"10,30,60,70" .and. nY > 0 )
			if( aImposto[nX]:_Tributo:_CST:text $ "60" )
				if  type("aImposto[nY]:_Tributo:_pST:text") <> "U"
					if( type("aImposto[nY]:_Tributo:_vICMSSubstituto:text") <> "U")
                 	    cString += nfeTag('<vICMSSubstituto>',"convType(val(aImposto[nY]:_Tributo:_vICMSSubstituto:text), 15, 2)",.T.)  
               	    endif
					cString += nfeTag('<vICMSSTRet>',"convType(val(aImposto[nY]:_Tributo:_valor:text), 15, 2)",.T.)
					if  type("aImposto[nY]:_Tributo:_pFCPSTRet:text") <> "U" .and. val(aImposto[nY]:_Tributo:_pFCPSTRet:text) > 0
						cString += nfeTag('<vBCFCPSTRet>',"convType(val(aImposto[nY]:_Tributo:_vBCFCPSTRet:text), 16, 2)",.T.)
						cString += nfeTag('<pFCPSTRet>',"convType(val(aImposto[nY]:_Tributo:_pFCPSTRet:text), 8, 4)",.T.)
						cString += nfeTag('<vFCPSTRet>',"convType(val(aImposto[nY]:_Tributo:_vFCPSTRet:text), 16, 2)",.T.)

						if( type("aImposto[nY]:_Tributo:_vFCPSTRet:text") <> "U")
							aImp[13][2] += val(aImposto[nY]:_Tributo:_vFCPSTRet:text)
						endif
					endif			
              endif
               if  type("aImposto[nY]:_Tributo:_pRedBCEfet:text") <> "U" //.and. val(aImposto[nY]:_Tributo:_pRedBCEfet:text) > 0
					cString += nfeTag('<pRedBCEfet>',"convType(val(aImposto[nY]:_Tributo:_pRedBCEfet:text), 8, 4,'',.T.)",.T.)
					cString += nfeTag('<vBCEfet>',"convType(val(aImposto[nY]:_Tributo:_vBCEfet:text), 16, 2,'',.T.)",.T.)
    				cString += nfeTag('<pICMSEfet>',"convType(val(aImposto[nY]:_Tributo:_pICMSEfet:text), 8, 4,'',.T.)",.T.)
    				cString += nfeTag('<vICMSEfet>',"convType(val(aImposto[nY]:_Tributo:_vICMSEfet:text), 16, 2,'',.T.)",.T.)
               endif
			else
				cString += '<vICMSST>'+convType(Val(aImposto[nY]:_Tributo:_valor:text),15,2)+'</vICMSST>'
			endif

		endif

        /*Chamado TUMGKU
        Só montar as tags do ICMS ST do grupo ICMS90 quando realmente possuir valores de ICMS ST.
        Alteração realizada pelo fato da Sefaz MG rejeitar a nota com "806-Operação com ICMS-ST
        sem informação do CEST" para uma NFe com CST90 sem ICMS ST.

        De acordo com uma das regras de validação desta rejeição o CEST é obrigatório
        quando possuir a tag vICMSST do grupo 90*/
		if( aImposto[nX]:_Tributo:_CST:text$"90"  .and. nY > 0 )

			if ( Val(aImposto[nY]:_Tributo:_vBC:text) > 0 .or. Val(aImposto[nY]:_Tributo:_Aliquota:text) > 0 .or. Val(aImposto[nY]:_Tributo:_valor:text) > 0 )
				cString += '<modBCST>'+aImposto[nY]:_Tributo:_MODBC:text+'</modBCST>'
				cString += nfeTag('<pMVAST>'  ,"convType(Val(aImposto[nY]:_Cpl:_PMVAST:text),8,4)")
				cString += nfeTag('<pRedBCST>',"convType(Val(aImposto[nY]:_Tributo:_PREDBC:text),7,4)")
				cString += '<vBCST>'  +convType(Val(aImposto[nY]:_Tributo:_vBC:text),15,2)+'</vBCST>'
				cString += '<pICMSST>'+convType(Val(aImposto[nY]:_Tributo:_Aliquota:text),7,4)+'</pICMSST>'
				cString += '<vICMSST>'+convType(Val(aImposto[nY]:_Tributo:_valor:text),15,2)+'</vICMSST>'

				aImp[2][1] += Val(iif(type("aImposto[nY]:_Tributo:_vBC:text")  =="U","0",aImposto[nY]:_Tributo:_vBC:text))
				aImp[2][2] += Val(iif(type("aImposto[nY]:_Tributo:_valor:text")=="U","0",aImposto[nY]:_Tributo:_valor:text))
			endif

		endif

		if( aImposto[nX]:_Tributo:_CST:text $ "10,30,70,90" .and. nY > 0 )
			if type("aImposto[nY]:_Tributo:_pFCPST:text") <> "U" .and. val(aImposto[nY]:_Tributo:_pFCPST:text) > 0
				cString += nfeTag('<vBCFCPST>',"convType(val(aImposto[nY]:_Tributo:_vBCFCPST:text), 16, 2)", .T.)
				cString += nfeTag('<pFCPST>',"convType(val(aImposto[nY]:_Tributo:_pFCPST:text), 8, 4)", .T.)
				cString += nfeTag('<vFCPST>',"convType(val(aImposto[nY]:_Tributo:_vFCPST:text), 16, 2)", .T.)

				if( type("aImposto[nY]:_Tributo:_vFCPST:text") <> "U")
					aImp[13][3] += val(aImposto[nY]:_Tributo:_vFCPST:text)
				endif
			endif

            if( aImposto[nX]:_Tributo:_CST:text $ "10,70,90" .and. nY > 0 )  .and. !type("aImposto[nY]:_Tributo:_vICMSSTDeson:text") == "U" .and. !type("aImposto[nY]:_Tributo:_motDesICMSST:text") == "U"
                cString += '<vICMSSTDeson>' + convType(val(aImposto[nY]:_Tributo:_vICMSSTDeson:text), 16, 2) + '</vICMSSTDeson>'
                cString += '<motDesICMSST>' + convType(aImposto[nY]:_Tributo:_motDesICMSST:text) + '</motDesICMSST>'
                aImp[1][3] += Val(iif(type("aImposto[nY]:_Tributo:_vICMSSTDeson:text")=="U","0",aImposto[nY]:_Tributo:_vICMSSTDeson:text))
			endif
			if( aImposto[nX]:_Tributo:_CST:text$"30" )
                if type('aImposto[nY]:_Tributo:_vICMSDeson:text') <> "U" .and. type('aImposto[nY]:_Tributo:_motDesICMS:text') <> 'U'
					cString += nfeTag('<vICMSDeson>' ,"convType(Val(aImposto[nY]:_Tributo:_vICMSDeson:text),15,2)",.T.)
				endif  
				cString += nfeTag('<motDesICMS>' ,"aImposto[nY]:_Tributo:_motDesICMS:text")
				aImp[1][3] += Val(iif(type("aImposto[nY]:_Tributo:_vICMSDeson:text")=="U","0",aImposto[nY]:_Tributo:_vICMSDeson:text))
			endif
		endif

		if( aImposto[nX]:_Tributo:_CST:text $ "70,90" )
            if type('aImposto[nX]:_Tributo:_vICMSDeson:text') <> "U" .and. type('aImposto[nX]:_Tributo:_motDesICMS:text') <> 'U'
                cString += nfeTag('<vICMSDeson>' ,"convType(Val(aImposto[nX]:_Tributo:_vICMSDeson:text),15,2)",.T.)
            endif
			cString += nfeTag('<motDesICMS>' ,"aImposto[nX]:_Tributo:_motDesICMS:text")
			aImp[1][3] += Val(iif(type("aImposto[nX]:_Tributo:_vICMSDeson:text")=="U","0",aImposto[nX]:_Tributo:_vICMSDeson:text))
		endif

		cString += '</ICMS'+cGrupo+'>'
		cString += '</ICMS>'

	endif

	nX := aScan(aImposto,{|x| x:_codigo:text == "ICMSPART"})

	if(  nX > 0 )

		aImposto[nX]:_Tributo:_CST:text := Alltrim( aImposto[nX]:_Tributo:_CST:text )

		if( aImposto[nX]:_Tributo:_CST:text$"10,90" )
			cString += '<ICMS>'
			cString += '<ICMSPart>'
			cString += '<orig>'   + aImposto[nX]:_Cpl:_orig:text + '</orig>'
			cString += '<CST>'    + aImposto[nX]:_Tributo:_CST:text + '</CST>'
			cString += '<modBC>'  + aImposto[nX]:_Tributo:_MODBC:text + '</modBC>'
			cString += '<vBC>'    + convType(Val(aImposto[nX]:_Tributo:_vBC:text), 15, 2) + '</vBC>'
			cString += nfeTag('<pRedBC>',"convType(Val(aImposto[nX]:_Tributo:_PREDBC:text),7,4)")
			cString += '<pICMS>'  + convType(Val(aImposto[nX]:_Tributo:_Aliquota:text), 7, 4) + '</pICMS>'
			cString += '<vICMS>'  + convType(Val(aImposto[nX]:_Tributo:_Valor:text), 15, 2)+'</vICMS>'
			cString += '<modBCST>' + aImposto[nX]:_Tributo:_MODBCST:text + '</modBCST>'
			cString += nfeTag('<pMVAST>'  ,"convType(Val(aImposto[nX]:_Cpl:_PMVAST:text),8,4)")
			cString += nfeTag('<pRedBCST>',"convType(Val(aImposto[nX]:_Tributo:_PREDBCST:text),6,2)")
			cString += '<vBCST>'  + convType(Val(aImposto[nX]:_Tributo:_vBCST:text),15,2) + '</vBCST>'
			cString += '<pICMSST>'+ convType(Val(aImposto[nX]:_Tributo:_AliquotaST:text), 7, 4)+'</pICMSST>'
			cString += '<vICMSST>'+ convType(Val(aImposto[nX]:_Tributo:_valorST:text), 15, 2) + '</vICMSST>'
			
			If type("aImposto[nX]:_Tributo:_pFCPST:text") <> "U" .And. val(aImposto[nX]:_Tributo:_pFCPST:text) > 0
            	cString += nfeTag('<vBCFCPST>',"convType(val(aImposto[nX]:_Tributo:_vBCFCPST:text), 16, 2)", .T.)
            	cString += nfeTag('<pFCPST>',"convType(val(aImposto[nX]:_Tributo:_pFCPST:text), 8, 4)", .T.)
            	cString += nfeTag('<vFCPST>',"convType(val(aImposto[nX]:_Tributo:_vFCPST:text), 16, 2)", .T.)
            EndIf

			cString += '<pBCOp>'+ convType(Val(aImposto[nX]:_Tributo:_pBCOp:text), 7, 4) + '</pBCOp>'
			cString += '<UFST>'	+ aImposto[nX]:_Tributo:_UFST:text + '</UFST>'
			cString += '</ICMSPart>'
			cString += '</ICMS>'

			aImp[1][1] += Val(iif(type("aImposto[nX]:_Tributo:_vBC:text")  =="U", "0", aImposto[nX]:_Tributo:_vBC:text))
			aImp[1][2] += Val(iif(type("aImposto[nX]:_Tributo:_valor:text")=="U","0", aImposto[nX]:_Tributo:_valor:text))
			aImp[2][1] += Val(iif(type("aImposto[nX]:_Tributo:_vBCST:text")  =="U","0", aImposto[nX]:_Tributo:_vBCST:text))
			aImp[2][2] += Val(iif(type("aImposto[nX]:_Tributo:_valorST:text")=="U","0", aImposto[nX]:_Tributo:_valorST:text))
			aImp[13][3]+= Val(iif(type("aImposto[nX]:_Tributo:_vFCPST:text")=="U","0",aImposto[nX]:_Tributo:_vFCPST:text))

		endif

	endif

	nX := aScan(aImposto,{|x| x:_codigo:text == "ICMSST41"})

	if( nX > 0 )

		aImposto[nX]:_Tributo:_CST:text := Alltrim( aImposto[nX]:_Tributo:_CST:text )

		if( aImposto[nX]:_Tributo:_CST:text$"41" )
			cString += '<ICMS>'
			cString += '<ICMSST>'
			cString += '<orig>'   + aImposto[nX]:_Cpl:_orig:text + '</orig>'
			cString += '<CST>'    + aImposto[nX]:_Tributo:_CST:text + '</CST>'
			cString += '<vBCSTRet>' + convType(Val(aImposto[nX]:_Tributo:_vBC:text),15,2) + '</vBCSTRet>'
			cString += nfeTag('<pST>',"convType(val(aImposto[nX]:_Tributo:_pST:text), 8, 4)")
			if( type("aImposto[nX]:_Tributo:_vICMSSubstituto:text") <> "U")
                cString += nfeTag('<vICMSSubstituto>',"convType(val(aImposto[nX]:_Tributo:_vICMSSubstituto:text), 16, 2)",.T.) 
            endif
			cString += '<vICMSSTRet>' + convType(Val(aImposto[nX]:_Tributo:_vICMSSTRet:text),15,2) + '</vICMSSTRet>'
			
			if  type("aImposto[nX]:_Tributo:_pFCPSTRet:text") <> "U" .and. val(aImposto[nX]:_Tributo:_pFCPSTRet:text) > 0
                cString += nfeTag('<vBCFCPSTRet>',"convType(val(aImposto[nX]:_Tributo:_vBCFCPSTRet:text), 16, 2)",.T.)
                cString += nfeTag('<pFCPSTRet>',"convType(val(aImposto[nX]:_Tributo:_pFCPSTRet:text), 8, 4)",.T.)
                cString += nfeTag('<vFCPSTRet>',"convType(val(aImposto[nX]:_Tributo:_vFCPSTRet:text), 16, 2)",.T.)
                
                if( type("aImposto[nX]:_Tributo:_vFCPSTRet:text") <> "U")
                    aImp[13][2] += val(aImposto[nX]:_Tributo:_vFCPSTRet:text)
                endif     
            endif		
			cString += '<vBCSTDest>' + convType(Val(aImposto[nX]:_Tributo:_vBCSTDest:text), 15, 2) + '</vBCSTDest>'
			cString += '<vICMSSTDest>' + convType(Val(aImposto[nX]:_Tributo:_vICMSSTDest:text), 15, 2) + '</vICMSSTDest>'
			
			if  type("aImposto[nX]:_Tributo:_pRedBCEfet:text") <> "U"
            	cString += nfeTag('<pRedBCEfet>',"convType(val(aImposto[nX]:_Tributo:_pRedBCEfet:text), 8, 4,'',.T.)",.T.)
				cString += nfeTag('<vBCEfet>',"convType(val(aImposto[nX]:_Tributo:_vBCEfet:text), 16, 2,'',.T.)",.T.)
    			cString += nfeTag('<pICMSEfet>',"convType(val(aImposto[nX]:_Tributo:_pICMSEfet:text), 8, 4,'',.T.)",.T.)
    			cString += nfeTag('<vICMSEfet>',"convType(val(aImposto[nX]:_Tributo:_vICMSEfet:text), 16, 2,'',.T.)",.T.)
            endif
            
			cString += '</ICMSST>'
			cString += '</ICMS>'
		endif
	endif
	
	nX := aScan(aImposto,{|x| x:_codigo:text == "ICMSST60"})

	if( nX > 0 )

		aImposto[nX]:_Tributo:_CST:text := Alltrim( aImposto[nX]:_Tributo:_CST:text )

		if( aImposto[nX]:_Tributo:_CST:text$"60" )
			cString += '<ICMS>'
			cString += '<ICMSST>'
			cString += '<orig>'   + aImposto[nX]:_Cpl:_orig:text + '</orig>'
			cString += '<CST>'    + aImposto[nX]:_Tributo:_CST:text + '</CST>'
			cString += '<vBCSTRet>' + convType(Val(aImposto[nX]:_Tributo:_vBC:text),15,2) + '</vBCSTRet>'
			cString += nfeTag('<pST>',"convType(val(aImposto[nX]:_Tributo:_pST:text), 8, 4)")
			if( type("aImposto[nX]:_Tributo:_vICMSSubstituto:text") <> "U")
                cString += nfeTag('<vICMSSubstituto>',"convType(val(aImposto[nX]:_Tributo:_vICMSSubstituto:text), 16, 2)",.T.) 
            endif
			cString += '<vICMSSTRet>' + convType(Val(aImposto[nX]:_Tributo:_valor:text),15,2) + '</vICMSSTRet>'
			
			if  type("aImposto[nX]:_Tributo:_pFCPSTRet:text") <> "U" .and. val(aImposto[nX]:_Tributo:_pFCPSTRet:text) > 0
                cString += nfeTag('<vBCFCPSTRet>',"convType(val(aImposto[nX]:_Tributo:_vBCFCPSTRet:text), 16, 2)",.T.)
                cString += nfeTag('<pFCPSTRet>',"convType(val(aImposto[nX]:_Tributo:_pFCPSTRet:text), 8, 4)",.T.)
                cString += nfeTag('<vFCPSTRet>',"convType(val(aImposto[nX]:_Tributo:_vFCPSTRet:text), 16, 2)",.T.)
            endif		
			cString += '<vBCSTDest>' + convType(Val(aImposto[nX]:_Tributo:_vBCSTDest:text), 15, 2) + '</vBCSTDest>'
			cString += '<vICMSSTDest>' + convType(Val(aImposto[nX]:_Tributo:_vICMSSTDest:text), 15, 2) + '</vICMSSTDest>'
			
			if  type("aImposto[nX]:_Tributo:_pRedBCEfet:text") <> "U"
            	cString += nfeTag('<pRedBCEfet>',"convType(val(aImposto[nX]:_Tributo:_pRedBCEfet:text), 8, 4,'',.T.)",.T.)
				cString += nfeTag('<vBCEfet>',"convType(val(aImposto[nX]:_Tributo:_vBCEfet:text), 16, 2,'',.T.)",.T.)
    			cString += nfeTag('<pICMSEfet>',"convType(val(aImposto[nX]:_Tributo:_pICMSEfet:text), 8, 4,'',.T.)",.T.)
    			cString += nfeTag('<vICMSEfet>',"convType(val(aImposto[nX]:_Tributo:_vICMSEfet:text), 16, 2,'',.T.)",.T.)
            endif
            
			cString += '</ICMSST>'
			cString += '</ICMS>'
		endif
	endif

	nX := aScan(aImposto,{|o| o:_Codigo:text == "ICMSSN"})

	if( nX > 0 )

		cGrupo  := aImposto[nX]:_Tributo:_CSOSN:text

		if( cGrupo $ "102,103,300,400")
			cGrupo := "102"
		elseIf cGrupo $ "202,203"
			cGrupo := "202"
		elseIf cGrupo $ "201"
			cGrupo := "201"
		endif

		cString += '<ICMS>'
		cString += '<ICMSSN'  +cGrupo+'>'
		cString += '<orig>'   +aImposto[nX]:_Cpl:_orig:text+'</orig>'
		cString += '<CSOSN>'    +aImposto[nX]:_Tributo:_CSOSN:text+'</CSOSN>'

		if( aImposto[nX]:_Tributo:_CSOSN:text $ "900" )

			if( type("aImposto[nX]:_Tributo:_modBC:text") <> "U" )
				cString += '<modBC>' + aImposto[nX]:_Tributo:_modBC:text + '</modBC>'
				cString += '<vBC>'  + convType(Val(aImposto[nX]:_Tributo:_vBC:text), 15, 2) + '</vBC>'
				cString += nfeTag('<pRedBC>'  ,"convType(Val(aImposto[nX]:_pRedBC:text),7,4)")
				cString += '<pICMS>' + convType(Val(aImposto[nX]:_Tributo:_pICMS:text), 7, 4) + '</pICMS>'
				cString += '<vICMS>' + convType(Val(aImposto[nX]:_Tributo:_vICMS:text), 15, 2) +'</vICMS>'
			endif

			aImp[1][1] += Val(iif(type("aImposto[nX]:_Tributo:_vBC:text")  == "U", "0", aImposto[nX]:_Tributo:_vBC:text))
			aImp[1][2] += Val(iif(type("aImposto[nX]:_Tributo:_vICMS:text") == "U", "0", aImposto[nX]:_Tributo:_vICMS:text))

			if( type("aImposto[nX]:_Tributo:_modBCST:text") <> "U" )

				cString += '<modBCST>'+aImposto[nX]:_Tributo:_modBCST:text+'</modBCST>'
				cString += nfeTag('<pMVAST>'  ,"convType(Val(aImposto[nX]:_pMVAST:text),8,4)")
				cString += nfeTag('<pRedBCST>'  ,"convType(Val(aImposto[nX]:_pRedBCST:text),7,4)")
				cString += '<vBCST>'  +convType(Val(aImposto[nX]:_Tributo:_vBCST:text),15,2)+  '</vBCST>'
				cString += '<pICMSST>'+convType(Val(aImposto[nX]:_Tributo:_pICMSST:text),7,4)+ '</pICMSST>'
				cString += '<vICMSST>'+convType(Val(aImposto[nX]:_Tributo:_vICMSST:text),15,2)+'</vICMSST>'
				if( type("aImposto[nX]:_Tributo:_pFCPST:text") <> "U" ).and. val(aImposto[nX]:_Tributo:_pFCPST:text) > 0
					cString += nfeTag('<vBCFCPST>',"convType(val(aImposto[nX]:_Tributo:_vBCFCPST:text), 16, 2)", .T.)
					cString += nfeTag('<pFCPST>',"convType(val(aImposto[nX]:_Tributo:_pFCPST:text), 8, 4)", .T.)
					cString += nfeTag('<vFCPST>',"convType(val(aImposto[nX]:_Tributo:_vFCPST:text), 16, 2)", .T.)
				endif
				if( type("aImposto[nX]:_Tributo:_vFCPST:text") <> "U")
					aImp[13][3] += val(aImposto[nX]:_Tributo:_vFCPST:text)
				endif

			endif

			aImp[2][1] += Val(iif(type("aImposto[nX]:_Tributo:_vBCST:text")  =="U","0",aImposto[nX]:_Tributo:_vBCST:text))
			aImp[2][2] += Val(iif(type("aImposto[nX]:_Tributo:_vICMSST:text")=="U","0",aImposto[nX]:_Tributo:_vICMSST:text))

			if( type("aImposto[nX]:_Tributo:_pCredSN:text") <> "U" )
				cString += '<pCredSN>'  +convType(Val(aImposto[nX]:_Tributo:_pCredSN:text),7,4)+ '</pCredSN>'
				cString += '<vCredICMSSN>'+convType(Val(aImposto[nX]:_Tributo:_vCredICMSSN:text),15,2)+'</vCredICMSSN>'
			endif

		endif

		if aImposto[nX]:_Tributo:_CSOSN:text$"201,202,203"

			cString += '<modBCST>' + aImposto[nX]:_Tributo:_modBCST:text + '</modBCST>'
			cString += nfeTag('<pMVAST>'  ,"convType(Val(aImposto[nX]:_Tributo:_pMVAST:text),8,4)")
			cString += nfeTag('<pRedBCST>'  ,"convType(Val(aImposto[nX]:_Tributo:_pRedBCST:text),7,4)")
			cString += '<vBCST>'  + convType(Val(aImposto[nX]:_Tributo:_vBCST:text), 15, 2) + '</vBCST>'
			cString += '<pICMSST>' + convType(Val(aImposto[nX]:_Tributo:_pICMSST:text), 7, 4) + '</pICMSST>'
			cString += '<vICMSST>' + convType(Val(aImposto[nX]:_Tributo:_vICMSST:text), 15, 2) + '</vICMSST>'

			if( type("aImposto[nX]:_Tributo:_pFCPST:text") <> "U" ) .and. val(aImposto[nX]:_Tributo:_pFCPST:text) > 0
				cString += nfeTag('<vBCFCPST>',"convType(val(aImposto[nX]:_Tributo:_vBCFCPST:text), 16, 2)", .T.)
				cString += nfeTag('<pFCPST>',"convType(val(aImposto[nX]:_Tributo:_pFCPST:text), 8, 4)", .T.)
				cString += nfeTag('<vFCPST>',"convType(val(aImposto[nX]:_Tributo:_vFCPST:text), 16, 2)", .T.)
			endif
			cString += nfeTag('<pCredSN>',"convType(val(aImposto[nX]:_Tributo:_pCredSN:text), 7, 4 )", .F.)
			cString += nfeTag('<vCredICMSSN>',"convType(val(aImposto[nX]:_Tributo:_vCredICMSSN:text), 15, 2 )", .F.)

			if( type("aImposto[nX]:_Tributo:_vFCPST:text") <> "U")
				aImp[13][3] += val(aImposto[nX]:_Tributo:_vFCPST:text)
			endif

			aImp[2][1] += Val(iif(type("aImposto[nX]:_Tributo:_vBCST:text")  =="U","0",aImposto[nX]:_Tributo:_vBCST:text))
			aImp[2][2] += Val(iif(type("aImposto[nX]:_Tributo:_vICMSST:text")=="U","0",aImposto[nX]:_Tributo:_vICMSST:text))

		endif

		if( aImposto[nX]:_Tributo:_CSOSN:text $ "500" )
			if type("aImposto[nX]:_Tributo:_pST:text") <> "U" 
				cString += nfeTag("<vBCSTRet>", "convType(val(aImposto[nX]:_Tributo:_vBCSTRet:text),16,2)",.T.)     
				cString += nfeTag('<pST>',"convType(val(aImposto[nX]:_Tributo:_pST:text), 8, 4,'',.T.)",.T.) 
				if( type("aImposto[nX]:_Tributo:_vICMSSubstituto:text") <> "U")
                	cString += nfeTag('<vICMSSubstituto>',"convType(val(aImposto[nX]:_Tributo:_vICMSSubstituto:text), 16, 2)",.T.)
            	endif
				cString += nfeTag('<vICMSSTRet>',"convType(val(aImposto[nX]:_Tributo:_vICMSSTRet:text), 16, 2)",.T.)
			endif
			if( type("aImposto[nX]:_Tributo:_pFCPSTRet:text") <> "U" ) .and.  val(aImposto[nX]:_Tributo:_pFCPSTRet:text) > 0
				cString += nfeTag('<vBCFCPSTRet>',"convType(val(aImposto[nX]:_Tributo:_vBCFCPSTRet:text), 16, 2)",.T.)
				cString += nfeTag('<pFCPSTRet>',"convType(val(aImposto[nX]:_Tributo:_pFCPSTRet:text), 8, 4)",.T.)
				cString += nfeTag('<vFCPSTRet>',"convType(val(aImposto[nX]:_Tributo:_vFCPSTRet:text), 16, 2)",.T.)

				if( type("aImposto[nX]:_Tributo:_vFCPSTRet:text") <> "U")
					aImp[13][2] += val(aImposto[nX]:_Tributo:_vFCPSTRet:text)
				endif
			endif
               if  type("aImposto[nY]:_Tributo:_pRedBCEfet:text") <> "U" //.and. val(aImposto[nY]:_Tributo:_pRedBCEfet:text) > 0
					cString += nfeTag('<pRedBCEfet>',"convType(val(aImposto[nY]:_Tributo:_pRedBCEfet:text), 8, 4,'',.T.)",.T.)
					cString += nfeTag('<vBCEfet>',"convType(val(aImposto[nY]:_Tributo:_vBCEfet:text), 16, 2,'',.T.)",.T.)
    				cString += nfeTag('<pICMSEfet>',"convType(val(aImposto[nY]:_Tributo:_pICMSEfet:text), 8, 4,'',.T.)",.T.)
    				cString += nfeTag('<vICMSEfet>',"convType(val(aImposto[nY]:_Tributo:_vICMSEfet:text), 16, 2,'',.T.)",.T.)
               endif
		endif

		if( aImposto[nX]:_Tributo:_CSOSN:text $ "101,151" )
			cString += '<pCredSN>'  +convType(Val(aImposto[nX]:_Tributo:_pCredSN:text),7,4)+ '</pCredSN>'
			cString += '<vCredICMSSN>'+convType(Val(aImposto[nX]:_Tributo:_vCredICMSSN:text),15,2)+'</vCredICMSSN>'
		endif

		cString += '</ICMSSN'+cGrupo+'>'
		cString += '</ICMS>'

	endif

    //Para a versão 3.10 é possível informar no mesmo item
    //a tributação de IPI e ISSQN
	nX := Ascan(aImposto,{|o| o:_Codigo:text == "IPI"})

	if( nX > 0 )
		aImposto[nX]:_Tributo:_CST:text := Alltrim( aImposto[nX]:_Tributo:_CST:text )
		cString += '<IPI>'
		// Exclusão do Campo clEnq (id:O02) “Classe de enquadramento do IPI para Cigarros e Bebidas”(Alterações introduzidas na versão 1.41)
		//cString += nfeTag('<clEnq>'   ,"aImposto[nX]:_Cpl:_clEnq:text")
		cString += nfeTag('<CNPJProd>',"aImposto[nX]:_Cpl:_CNPJProd:text")
		cString += nfeTag('<cSelo>'   ,"aImposto[nX]:_Cpl:_cSelo:text")
		cString += nfeTag('<qSelo>'   ,"aImposto[nX]:_Cpl:_qSelo:text")

		if( type("aImposto[nX]:_Cpl:_cEnq:text") == "U" )
			cString += '<cEnq>999</cEnq>'
		else
			cString += '<cEnq>' + aImposto[nX]:_Cpl:_cEnq:text + '</cEnq>'
		endif

		if( aImposto[nX]:_Tributo:_CST:text$"00,49,50,99" )

			cString += '<IPITrib>'
			cString += '<CST>'  +aImposto[nX]:_Tributo:_CST:text+'</CST>'

			if ((type("aImposto[nX]:_Tributo:_vlTrib:text")<>"U" .and. Val(aImposto[nX]:_Tributo:_vlTrib:text)==0) .Or. type("aImposto[nX]:_Tributo:_vlTrib:text")=="U"  )
				cString += '<vBC>'  +convType(Val(aImposto[nX]:_Tributo:_vBC:text),15,2)+'</vBC>'
				cString += nfeTag('<pIPI>' ,"convType(Val(aImposto[nX]:_Tributo:_Aliquota:text),7,4)",.T.)
			endif

			if (type("aImposto[nX]:_Tributo:_vlTrib:text")<>"U" .and. Val(aImposto[nX]:_Tributo:_vlTrib:text)>0 .and.;
					(type("aImposto[nX]:_Tributo:_modBC:text")=="U" .Or. empty(aImposto[nX]:_Tributo:_modBC:text)) .Or.;
					(type("aImposto[nX]:_Tributo:_modBC:text")<>"U" .and. AllTrim(aImposto[nX]:_Tributo:_modBC:text)$'12'))

				cString += nfeTag('<qUnid>',"convType(Val(aImposto[nX]:_Tributo:_qTrib:text),16,4)")
				cString += nfeTag('<vUnid>',"convType(Val(aImposto[nX]:_Tributo:_vlTrib:text),15,4)")
			endif

			cString += nfeTag('<vIPI>' ,"convType(Val(aImposto[nX]:_Tributo:_valor:text),15,2)",.T.)
			cString += '</IPITrib>'

			aImp[3][1] += Val(iif(type("aImposto[nX]:_Tributo:_vBC:text")  =="U","0",aImposto[nX]:_Tributo:_vBC:text))
			aImp[3][2] += Val(iif(type("aImposto[nX]:_Tributo:_valor:text")=="U","0",aImposto[nX]:_Tributo:_valor:text))

		else
			cString += '<IPINT>'
			cString += '<CST>'+aImposto[nX]:_Tributo:_CST:text+'</CST>'
			cString += '</IPINT>'
		endif

		cString += '</IPI>'

	endif

    //Para versão 2.00,o grupo ISSQN é mutuamente exclusivo
    //com os grupos ICMS,IPI e II, isto é se ISSQN for
    //informado os grupos ICMS, IPI e II não serão informados e viceversa
    //Caso o ERP envie as TAGS de ICMS e ISS, as duas serão geradas,
    //acusando rejeição de SCHEMA posteriormente.
	nX := Ascan(aImposto,{|o| o:_Codigo:text == "ISS"})

	if( nX > 0 )
		cString += '<ISSQN>'
		cString += '<vBC>'      +convType(Val(aImposto[nX]:_Tributo:_vBC:text),15,2)+'</vBC>'
		cString += '<vAliq>'    +convType(Val(aImposto[nX]:_Tributo:_Aliquota:text),7,4)+'</vAliq>'
		cString += '<vISSQN>'   +convType(Val(aImposto[nX]:_Tributo:_Valor:text),15,2)+'</vISSQN>'
		cString += '<cMunFG>'   +aImposto[nX]:_Cpl:_cMunFg:text+'</cMunFG>'
		cString += '<cListServ>'+aImposto[nX]:_Cpl:_cListServ:text+'</cListServ>'
		cString += nfeTag('<vDeducao>' ,"convType(Val(aImposto[nX]:_Tributo:_deducao:text),15,2)")
		cString += nfeTag('<vOutro>' ,"convType(Val(aImposto[nX]:_Tributo:_outro:text),15,2)")
		cString += nfeTag('<vDescIncond>' ,"convType(Val(aImposto[nX]:_Tributo:_descIncond:text),15,2)")
		cString += nfeTag('<vDescCond>' ,"convType(Val(aImposto[nX]:_Tributo:_descCond:text),15,2)")
		cString += nfeTag('<vISSRet>' ,"convType(Val(aImposto[nX]:_Tributo:_ISSRet:text),15,2)")

		if( type("aImposto[nX]:_Cpl:_indISS:text") <> "U" )
			cString += '<indISS>'+aImposto[nX]:_Cpl:_indISS:text+'</indISS>'
		endif

		cString += nfeTag('<cServico>' ,"aImposto[nX]:_Cpl:_codserv:text")
		cString += nfeTag('<cMun>' ,"aImposto[nX]:_Cpl:_cmunInc:text")
		cString += nfeTag('<cPais>' ,"aImposto[nX]:_Cpl:_codpais:text")
		cString += nfeTag('<nProcesso>' ,"aImposto[nX]:_Cpl:_Processo:text")

		if type("aImposto[nX]:_Cpl:_incentivo:text") <> "U"
			cString += '<indIncentivo>'+aImposto[nX]:_Cpl:_incentivo:text+'</indIncentivo>'
		endif

		cString += '</ISSQN>'

	endif

	nX := Ascan(aImposto,{|o| o:_Codigo:text == "II"})

	if( nX > 0	)
		cString += '<II>'
		cString += '<vBC>'      + convType(Val(aImposto[nX]:_Tributo:_vBC:text), 15, 2) + '</vBC>'
		cString += '<vDespAdu>' + convType(Val(aImposto[nX]:_Cpl:_vDespAdu:text), 15, 2) + '</vDespAdu>'
		cString += '<vII>'      + convType(Val(aImposto[nX]:_Tributo:_Valor:text), 15, 2) + '</vII>'
		cString += '<vIOF>'     + convType(Val(aImposto[nX]:_Cpl:_vIOF:text), 15, 2) + '</vIOF>'
		cString += '</II>'

		aImp[4][1] += Val(iif(type("aImposto[nX]:_Tributo:_vBC:text")  =="U","0",aImposto[nX]:_Tributo:_vBC:text))
		aImp[4][2] += Val(iif(type("aImposto[nX]:_Tributo:_valor:text")=="U","0",aImposto[nX]:_Tributo:_valor:text))

	endif

	nX := Ascan(aImposto,{|o| o:_Codigo:text == "PIS"})

	if( nX > 0 )

		lPIS := .T.
		cString += '<PIS>'
		aImposto[nX]:_Tributo:_CST:text := Alltrim( aImposto[nX]:_Tributo:_CST:text )

		if( aImposto[nX]:_Tributo:_CST:text $ "01,02" )

			cString += '<PISAliq>'
			cString += '<CST>'    +aImposto[nX]:_Tributo:_CST:text+'</CST>'
			cString += '<vBC>'    +convType(Val(aImposto[nX]:_Tributo:_VBC:text),15,2)+'</vBC>'
			cString += '<pPIS>'   +convType(Val(aImposto[nX]:_Tributo:_Aliquota:text),7,4)+'</pPIS>'
			cString += '<vPIS>'   +convType(Val(aImposto[nX]:_Tributo:_Valor:text),15,2)+'</vPIS>'
			cString += '</PISAliq>'

			if( !(oDet:_Prod:_indTot:text == "0") )

				aImp[5][1] += Val(iif(type("aImposto[nX]:_Tributo:_vBC:text")  =="U","0",aImposto[nX]:_Tributo:_vBC:text))

				if Ascan(aImposto,{|o| o:_Codigo:text == "ISS"}) > 0 .and. cNFMod == "65"
					aImp[5][2] += 0
				else
					aImp[5][2] += Val(iif(type("aImposto[nX]:_Tributo:_valor:text")=="U","0",aImposto[nX]:_Tributo:_valor:text))
				endif

			else
				aImp[10][1] += Val(iif(type("aImposto[nX]:_Tributo:_vBC:text")  =="U","0",aImposto[nX]:_Tributo:_vBC:text))
				aImp[10][2] += Val(iif(type("aImposto[nX]:_Tributo:_valor:text")=="U","0",aImposto[nX]:_Tributo:_valor:text))
			endif

			nValPis    := Val(iif(type("aImposto[nX]:_Tributo:_valor:text")=="U","0",aImposto[nX]:_Tributo:_valor:text))

		endif

		if aImposto[nX]:_Tributo:_CST:text $ "03"

			cString += '<PISQtde>'
			cString += '<CST>'      +aImposto[nX]:_Tributo:_CST:text+'</CST>'
			cString += '<qBCProd>'  +convType(Val(aImposto[nX]:_Tributo:_qTrib:text),16,4)+'</qBCProd>'
			cString += '<vAliqProd>'+convType(Val(aImposto[nX]:_Tributo:_VlTrib:text),15,4)+'</vAliqProd>'
			cString += '<vPIS>'     +convType(Val(aImposto[nX]:_Tributo:_Valor:text),15,2)+'</vPIS>'
			cString += '</PISQtde>'

			aImp[5][1] += Val(iif(type("aImposto[nX]:_Tributo:_vBC:text")  =="U","0",aImposto[nX]:_Tributo:_vBC:text))
			aImp[5][2] += Val(iif(type("aImposto[nX]:_Tributo:_valor:text")=="U","0",aImposto[nX]:_Tributo:_valor:text))
			nValPis    := Val(iif(type("aImposto[nX]:_Tributo:_valor:text")=="U","0",aImposto[nX]:_Tributo:_valor:text))

		endif

		if( aImposto[nX]:_Tributo:_CST:text $ "04,05,06,07,08,09" )
			cString += '<PISNT>'
			cString += '<CST>'    +aImposto[nX]:_Tributo:_CST:text+'</CST>'
			cString += '</PISNT>'
		endif

		if( aImposto[nX]:_Tributo:_CST:text $ "99,49,50,51,52,53,54,55,56,60,61,62,63,64,65,66,67,70,71,72,73,74,75,98" )
			cString += '<PISOutr>'
			cString += '<CST>'    +aImposto[nX]:_Tributo:_CST:text+'</CST>'

			if( (type("aImposto[nX]:_Tributo:_vlTrib:text")<>"U" .and. Val(aImposto[nX]:_Tributo:_vlTrib:text)>0 .and.;
					(type("aImposto[nX]:_Tributo:_modBC:text")=="U" .Or. empty(aImposto[nX]:_Tributo:_modBC:text)) .Or.;
					(type("aImposto[nX]:_Tributo:_modBC:text")<>"U" .and. AllTrim(aImposto[nX]:_Tributo:_modBC:text)$'12')) )

				cString += '<qBCProd>'  +convType(Val(aImposto[nX]:_Tributo:_qTrib:text),16,4)+'</qBCProd>'
				cString += '<vAliqProd>'+convType(Val(aImposto[nX]:_Tributo:_vlTrib:text),15,4)+'</vAliqProd>'

			else
				cString += '<vBC>'      +convType(Val(aImposto[nX]:_Tributo:_vBC:text),15,2)+'</vBC>'
				cString += '<pPIS>'     +convType(Val(aImposto[nX]:_Tributo:_Aliquota:text),7,4)+'</pPIS>'

			endif

			cString += '<vPIS>'   +convType(Val(aImposto[nX]:_Tributo:_Valor:text),15,2)+'</vPIS>'
			cString += '</PISOutr>'

			aImp[5][1] += Val(iif(type("aImposto[nX]:_Tributo:_vBC:text")  =="U","0",aImposto[nX]:_Tributo:_vBC:text))
			aImp[5][2] += Val(iif(type("aImposto[nX]:_Tributo:_valor:text")=="U","0",aImposto[nX]:_Tributo:_valor:text))
			nValPis    := Val(iif(type("aImposto[nX]:_Tributo:_valor:text")=="U","0",aImposto[nX]:_Tributo:_valor:text))

		endif

		cString += '</PIS>'

	endif

	if !lPIS
		cString += '<PIS>'
		cString += '<PISNT>'
		cString += '<CST>08</CST>'
		cString += '</PISNT>'
		cString += '</PIS>'
	endif

	nX := Ascan(aImposto,{|o| o:_Codigo:text == "PISST"})

	if( nX > 0 )

		if Val(aImposto[nX]:_Tributo:_Valor:text)<>0

			cString += '<PISST>'

			if( (type("aImposto[nX]:_Tributo:_vlTrib:text")<>"U" .and. Val(aImposto[nX]:_Tributo:_vlTrib:text)>0 .and.;
					(type("aImposto[nX]:_Tributo:_modBC:text")=="U" .Or. empty(aImposto[nX]:_Tributo:_modBC:text)) .Or.;
					(type("aImposto[nX]:_Tributo:_modBC:text")<>"U" .and. AllTrim(aImposto[nX]:_Tributo:_modBC:text)$'12')) )

				cString += '<qBCProd>'  +convType(Val(aImposto[nX]:_Tributo:_qTrib:text),16,4)+'</qBCProd>'
				cString += '<vAliqProd>'+convType(Val(aImposto[nX]:_Tributo:_vlTrib:text),15,4)+'</vAliqProd>

			else
				cString += '<vBC>'    +convType(Val(aImposto[nX]:_Tributo:_vBC:text),15,2)+'</vBC>'
				cString += '<pPIS>'   +convType(Val(aImposto[nX]:_Tributo:_Aliquota:text),7,4)+'</pPIS>'
			endif

			cString += '<vPIS>'+convType(Val(aImposto[nX]:_Tributo:_Valor:text),15,2)+'</vPIS>'
            if !type("aImposto[nX]:_Tributo:_indSomaPISST:text") == "U" .and. !empty(aImposto[nX]:_Tributo:_indSomaPISST:text)
                cString += '<indSomaPISST>' + convType(aImposto[nX]:_Tributo:_indSomaPISST:text) + '</indSomaPISST>'
			endif

			cString += '</PISST>'
			aImp[6][1] += Val(iif(type("aImposto[nX]:_Tributo:_vBC:text")  =="U","0",aImposto[nX]:_Tributo:_vBC:text))
			aImp[6][2] += Val(iif(type("aImposto[nX]:_Tributo:_valor:text")=="U","0",aImposto[nX]:_Tributo:_valor:text))

		endif

	endif

	nX := Ascan(aImposto,{|o| o:_Codigo:text == "COFINS"})

	if( nX > 0)

		lCofins := .T.
		cString += '<COFINS>'
		aImposto[nX]:_Tributo:_CST:text := Alltrim( aImposto[nX]:_Tributo:_CST:text )

		if( aImposto[nX]:_Tributo:_CST:text $ "01,02" )

			cString += '<COFINSAliq>'
			cString += '<CST>'       +aImposto[nX]:_Tributo:_CST:text+'</CST>'
			cString += '<vBC>'       +convType(Val(aImposto[nX]:_Tributo:_vBC:text),15,2)+'</vBC>'
			cString += '<pCOFINS>'   +convType(Val(aImposto[nX]:_Tributo:_Aliquota:text),7,4)+'</pCOFINS>'
			cString += '<vCOFINS>'   +convType(Val(aImposto[nX]:_Tributo:_Valor:text),15,2)+'</vCOFINS>'
			cString += '</COFINSAliq>'

			if( !(oDet:_Prod:_indTot:text == "0") )

				aImp[7][1] += Val(iif(type("aImposto[nX]:_Tributo:_vBC:text")  =="U","0",aImposto[nX]:_Tributo:_vBC:text))

				if Ascan(aImposto,{|o| o:_Codigo:text == "ISS"}) > 0 .and. cNFMod == "65"
					aImp[7][2] += 0
				else
					aImp[7][2] += Val(iif(type("aImposto[nX]:_Tributo:_valor:text")=="U","0",aImposto[nX]:_Tributo:_valor:text))
				endif

			else
				aImp[11][1] += Val(iif(type("aImposto[nX]:_Tributo:_vBC:text")  =="U","0",aImposto[nX]:_Tributo:_vBC:text))
				aImp[11][2] += Val(iif(type("aImposto[nX]:_Tributo:_valor:text")=="U","0",aImposto[nX]:_Tributo:_valor:text))
			endif

			nValCOF    := Val(iif(type("aImposto[nX]:_Tributo:_valor:text")=="U","0",aImposto[nX]:_Tributo:_valor:text))

		endif

		if( aImposto[nX]:_Tributo:_CST:text $ "03" )
			cString += '<COFINSQtde>'
			cString += '<CST>'      +aImposto[nX]:_Tributo:_CST:text+'</CST>'
			cString += '<qBCProd>'  +convType(Val(aImposto[nX]:_Tributo:_qTrib:text),16,4)+'</qBCProd>'
			cString += '<vAliqProd>'+convType(Val(aImposto[nX]:_Tributo:_vlTrib:text),15,4)+'</vAliqProd>'
			cString += '<vCOFINS>'  +convType(Val(aImposto[nX]:_Tributo:_Valor:text),15,2)+'</vCOFINS>'
			cString += '</COFINSQtde>'

			aImp[7][1] += Val(iif(type("aImposto[nX]:_Tributo:_vBC:text")  =="U","0",aImposto[nX]:_Tributo:_vBC:text))
			aImp[7][2] += Val(iif(type("aImposto[nX]:_Tributo:_valor:text")=="U","0",aImposto[nX]:_Tributo:_valor:text))
			nValCOF    := Val(iif(type("aImposto[nX]:_Tributo:_valor:text")=="U","0",aImposto[nX]:_Tributo:_valor:text))
		endif

		if( aImposto[nX]:_Tributo:_CST:text $ "04,05,06,07,08,09" )
			cString += '<COFINSNT>'
			cString += '<CST>'    +aImposto[nX]:_Tributo:_CST:text+'</CST>'
			cString += '</COFINSNT>'
		endif

		if( aImposto[nX]:_Tributo:_CST:text $ "99,49,50,51,52,53,54,55,56,60,61,62,63,64,65,66,67,70,71,72,73,74,75,98" )

			cString += '<COFINSOutr>'
			cString += '<CST>'    +aImposto[nX]:_Tributo:_CST:text+'</CST>'

			if( (type("aImposto[nX]:_Tributo:_vlTrib:text")<>"U" .and. Val(aImposto[nX]:_Tributo:_vlTrib:text)>0 .and.;
					(type("aImposto[nX]:_Tributo:_modBC:text")=="U" .Or. empty(aImposto[nX]:_Tributo:_modBC:text)) .Or.;
					(type("aImposto[nX]:_Tributo:_modBC:text")<>"U" .and. AllTrim(aImposto[nX]:_Tributo:_modBC:text)$'12')) )

				cString += '<qBCProd>'  +convType(Val(aImposto[nX]:_Tributo:_qTrib:text),16,4)+'</qBCProd>'
				cString += '<vAliqProd>'+convType(Val(aImposto[nX]:_Tributo:_vlTrib:text),15,4)+'</vAliqProd>

			else
				cString += '<vBC>'      +convType(Val(aImposto[nX]:_Tributo:_vBC:text), 15, 2) + '</vBC>'
				cString += '<pCOFINS>'  +convType(Val(aImposto[nX]:_Tributo:_Aliquota:text), 7, 4) + '</pCOFINS>'
			endif

			cString += '<vCOFINS>' + convType(Val(aImposto[nX]:_Tributo:_Valor:text),15,2) + '</vCOFINS>'
			cString += '</COFINSOutr>'

			aImp[7][1] += Val(iif(type("aImposto[nX]:_Tributo:_vBC:text")  =="U","0",aImposto[nX]:_Tributo:_vBC:text))
			aImp[7][2] += Val(iif(type("aImposto[nX]:_Tributo:_valor:text")=="U","0",aImposto[nX]:_Tributo:_valor:text))
			nValCOF    := Val(iif(type("aImposto[nX]:_Tributo:_valor:text")=="U","0",aImposto[nX]:_Tributo:_valor:text))

		endif

		cString += '</COFINS>'

	endif

	if( !lCofins )
		cString += '<COFINS>'
		cString += '<COFINSNT>'
		cString += '<CST>08</CST>'
		cString += '</COFINSNT>'
		cString += '</COFINS>'
	endif

	nX := Ascan(aImposto,{|o| o:_Codigo:text == "COFINSST"})

	if( nX > 0 )

		if( Val(aImposto[nX]:_Tributo:_Valor:text) <> 0 )
			cString += '<COFINSST>'
			if( (type("aImposto[nX]:_Tributo:_vlTrib:text")<>"U" .and. Val(aImposto[nX]:_Tributo:_vlTrib:text)>0 .and.;
					(type("aImposto[nX]:_Tributo:_modBC:text")=="U" .Or. empty(aImposto[nX]:_Tributo:_modBC:text)) .Or.;
					(type("aImposto[nX]:_Tributo:_modBC:text")<>"U" .and. AllTrim(aImposto[nX]:_Tributo:_modBC:text)$'12')) )

				cString += '<qBCProd>'+convType(Val(aImposto[nX]:_Tributo:_qTrib:text),16,4)+'</qBCProd>'
				cString += '<vAliqProd>'+convType(Val(aImposto[nX]:_Tributo:_vlTrib:text),15,4)+'</vAliqProd>'

			else
				cString += '<vBC>'+convType(Val(aImposto[nX]:_Tributo:_vBC:text),15,2)+'</vBC>'
				cString += '<pCOFINS>'+convType(Val(aImposto[nX]:_Tributo:_Aliquota:text),7,4)+'</pCOFINS>'

			endif

			cString += '<vCOFINS>'+convType(Val(aImposto[nX]:_Tributo:_Valor:text),15,2)+'</vCOFINS>'

            if !type("aImposto[nX]:_Tributo:_indSomaCOFINSST:text") == "U" .and. !empty(aImposto[nX]:_Tributo:_indSomaCOFINSST:text)
                cString += '<indSomaCOFINSST>' + convType(aImposto[nX]:_Tributo:_indSomaCOFINSST:text) + '</indSomaCOFINSST>'
            endif

	        cString += '</COFINSST>'			

			aImp[8][1] += Val(iif(type("aImposto[nX]:_Tributo:_vBC:text")  =="U","0" ,aImposto[nX]:_Tributo:_vBC:text))
			aImp[8][2] += Val(iif(type("aImposto[nX]:_Tributo:_valor:text")=="U","0",aImposto[nX]:_Tributo:_valor:text))

		endif

	endif

    /*NOTA TÉCNICA 2015/003 - ICMSUFDest
    Grupo a ser informado nas vendas interestaduais para consumidor final, não contribuinte do ICMS
    */
	nX := aScan(aImposto,{|x| x:_codigo:text == "ICMSUFDest"})

	if(  nX > 0 )

		cString += '<ICMSUFDest>'
		cString += '<vBCUFDest>'+convType(Val(aImposto[nX]:_Tributo:_vBC:text),15,2)+'</vBCUFDest>'
		cString += nfeTag('<vBCFCPUFDest>' ,"convType(val(aImposto[nX]:_Tributo:_vBCFCPUFDest:text),16,2)")
		cString += '<pFCPUFDest>'+convType(Val(aImposto[nX]:_Tributo:_pFCPUF:text),8,4)+'</pFCPUFDest>'
		cString += '<pICMSUFDest>'+convType(Val(aImposto[nX]:_Tributo:_Aliquota:text),8,4)+'</pICMSUFDest>'
		cString += '<pICMSInter>'+convType(Val(aImposto[nX]:_Tributo:_AliquotaInter:text),6,2)+'</pICMSInter>'
		cString += '<pICMSInterPart>'+convType(Val(aImposto[nX]:_Tributo:_pICMSInter:text),7,4)+'</pICMSInterPart>'
		cString += '<vFCPUFDest>'+convType(Val(aImposto[nX]:_Tributo:_ValorFCP:text),16,2)+'</vFCPUFDest>'
		cString += '<vICMSUFDest>'+convType(Val(aImposto[nX]:_Tributo:_ValorICMSDes:text),15,2)+'</vICMSUFDest>'
		cString += '<vICMSUFRemet>'+convType(Val(aImposto[nX]:_Tributo:_ValorICMSRem:text),15,2)+'</vICMSUFRemet>'
		cString += '</ICMSUFDest>'

		aImp[1][4] += Val(iif(type("aImposto[nX]:_Tributo:_ValorFCP:text")=="U","0",aImposto[nX]:_Tributo:_ValorFCP:text))
		aImp[1][5] += Val(iif(type("aImposto[nX]:_Tributo:_ValorICMSDes:text")=="U","0",aImposto[nX]:_Tributo:_ValorICMSDes:text))
		aImp[1][6] += Val(iif(type("aImposto[nX]:_Tributo:_ValorICMSRem:text")=="U","0",aImposto[nX]:_Tributo:_ValorICMSRem:text))

	endif

	nX := Ascan(aImposto,{|o| o:_Codigo:text == "ISS"})

	if( nX > 0 )

		aImp[9][1] += Val(iif(type("aImposto[nX]:_Tributo:_vBC:text")  =="U","0" ,aImposto[nX]:_Tributo:_vBC:text))
		aImp[9][2] += Val(iif(type("aImposto[nX]:_Tributo:_valor:text")=="U","0",aImposto[nX]:_Tributo:_valor:text))
		aImp[9][3] += Val(oDet:_Prod:_vProd:text)
		aImp[9][4] += nValPis
		aImp[9][5] += nValCof
		aImp[9][6] += Val(iif(type("aImposto[nX]:_Tributo:_deducao:text")  =="U","0" ,aImposto[nX]:_Tributo:_deducao:text))
		aImp[9][7] += Val(iif(type("aImposto[nX]:_Tributo:_outro:text")  =="U","0" ,aImposto[nX]:_Tributo:_outro:text))
		aImp[9][8] += Val(iif(type("aImposto[nX]:_Tributo:_descIncond:text")  =="U","0" ,aImposto[nX]:_Tributo:_descIncond:text))
		aImp[9][9] += Val(iif(type("aImposto[nX]:_Tributo:_descCond:text")  =="U","0" ,aImposto[nX]:_Tributo:_descCond:text))
		aImp[9][10] += Val(iif(type("aImposto[nX]:_Tributo:_ISSRet:text")  =="U","0" ,aImposto[nX]:_Tributo:_ISSRet:text))

	endif

	cString += '</imposto>'

    /* Incluído um novo grupo opcional na 3.10 para que as empresas possam
    informar o valor do IPI devolvido, para um determinado item da NF-e.
    Este novo grupo somente poderá ocorrer para NF-e de devolução (tag: Tpnfe =4).
    */
    /* Nota Técnica 2015/002
    Eliminada a possibilidade de informação do grupo de Devolução de Tributos na NFC-e (RV: UA01-20);
    */
	if( type("oXml:_IPIDEV") <> "U" .and. cNFMod <> "65" )

		cString += '<impostoDevol>'
		cString += '<pDevol>' + convType(Val(oXml:_IPIDEV:_pdevol:text),6,2) + '</pDevol>'
		cString += '<IPI>'
		cString += '<vIPIDevol>' + convType(Val(oXml:_IPIDEV:_vipidevol:text),15,2) + '</vIPIDevol>'
		cString += '</IPI>'
		cString += '</impostoDevol>'

		aImp[12][1] += val(oXml:_IPIDEV:_vipidevol:text)

	endif

    //ANFAVEA Informacoes adicionais do item
	if( type("oXml:_ANFAVEAPROD:text") <> "U" )

        //Se utiliza TOTVS Colaboração, o XML não é Assinado e não
        //passa pela função de Canonização da assinatura e não precisa
        //colocar 2 CDATA
		if( lUsaColab )

			cString += '<infAdProd>'+"<![CDATA["+oXml:_ANFAVEAPROD:text+"]]>"
			cString += iif(type("oXml:_infAdProd:text")=="U","",oXml:_infAdProd:text)
			cString +='</infAdProd>'

		else

			cString += '<infAdProd>'+"<![CDATA[<![CDATA["+oXml:_ANFAVEAPROD:text+"]]]]><![CDATA[>]]>"
			cString += iif(type("oXml:_infAdProd:text")=="U","",oXml:_infAdProd:text)
			cString +='</infAdProd>'

		endif

	elseIf( type("oXml:_infAdProd:text") <> "U" )

		if !empty(oXml:_infAdProd:text)
			cString += '<infAdProd>'+oXml:_infAdProd:text+'</infAdProd>'
		endif

	endif
    
	/*-------------------------------------------------------------------
     Grupo det/obsItem (VA01) - pode ter obsCont (VA02) e obsFisco (VA05)
    -------------------------------------------------------------------*/
    If type("oXml:_obsItem") <> "U"

        cString += '<obsItem>'
        
        if type("oXml:_obsItem:_obsCont") <> "U"
            cString += '<obsCont xCampo="'+ convType(oXml:_obsItem:_obsCont:_xCampo:text,20) +'">'
            cString += nfeTag('<xTexto>'  ,"convType(oXml:_obsItem:_obsCont:_xTexto:text, 60)")	
            cString += '</obsCont>'
        endif

        if type("oXml:_obsItem:_obsFisco") <> "U"
            cString += '<obsFisco xCampo="'+ convType(oXml:_obsItem:_obsFisco:_xCampo:text,20) +'">'            
            cString += nfeTag('<xTexto>'  ,"convType(oXml:_obsItem:_obsFisco:_xTexto:text, 60)")	
            cString += '</obsFisco>'
        endif
 
        cString += '</obsItem>'

    Endif

	cString += '</det>'

	aSize(aNVE, 0)
	aSize(aDI, 0)
	aSize(aAdi, 0)
	aSize(aDetExport, 0)
	aSize(aRastro, 0)
	aSize(aveicProd, 0)
	aSize(aArma, 0)
	aSize(aImposto, 0)

	aNVE       := nil
	aDI        := nil
	aAdi       := nil
	aDetExport := nil
	aRastro    := nil
	aVeicProd  := nil
	aArma      := nil
	aImposto   := nil

return(cString)

//-----------------------------------------------------------------------
/*/{Protheus.doc}	XmlNfeTotal
Monta Grupo com totalizador de valores e impostos da NFe

@param		oTotal	 Objeto com o total de valores da NFe
@param		aImp	 Referencia para retorno dos impostos
@param		aTot	 Referencia para reorno do Total da NFe

@return	cString	    Xml com total da NFe

@author Natalia Sartori
@since 20/05/2014
@version 1.0
/*/
//-----------------------------------------------------------------------
static function XmlNfeTotal(oTotal,aImp,aTot)

	local nX := 0
	local cString := ""
	local aTrib   := {}

	private aAux    := aImp
	private aAuxTot := aTot
	private oXml    := oTotal

	cString += '<total>'
	cString += '<ICMSTot>'
	cString += '<vBC>'    + convType(aImp[1][1], 15, 2) + '</vBC>'
	cString += '<vICMS>'  + convType(aImp[1][2], 15, 2) + '</vICMS>'
	cString += '<vICMSDeson>' + convType(aImp[1][3], 15, 2) + '</vICMSDeson>'

	/*NOTA TÉCNICA 2015/003_v1.10*/
	cString += '<vFCPUFDest>'  + convType(aImp[1][4], 16, 2) + '</vFCPUFDest>'
	cString += '<vICMSUFDest>'  + convType(aImp[1][5], 15, 2) + '</vICMSUFDest>'
	cString += '<vICMSUFRemet>'  + convType(aImp[1][6], 15, 2) + '</vICMSUFRemet>'
	cString += '<vFCP>'  + convType(aImp[13][1],16,2) + '</vFCP>'
	cString += '<vBCST>'  + convType(aImp[2][1],15,2) + '</vBCST>'
	cString += '<vST>'    + convType(aImp[2][2],15,2) + '</vST>'
	cString += '<vFCPST>' + convType(aImp[13][3],16,2) + '</vFCPST>'
	cString += '<vFCPSTRet>' + convType(aImp[13][2], 16, 2) + '</vFCPSTRet>'
	cString += '<vProd>'  + convType(aAuxTot[1],15,2)+'</vProd>'
	cString += '<vFrete>' + convType(aAuxTot[2],15,2)+'</vFrete>'
	cString += '<vSeg>'   + convType(aAuxTot[3],15,2)+'</vSeg>'
	cString += '<vDesc>'  + convType(aAuxTot[4],15,2)+'</vDesc>'
	cString += '<vII>'    + convType(aImp[4][2],15,2)+'</vII>'
	cString += '<vIPI>'   + convType(aImp[3][2],15,2)+'</vIPI>'
	cString += '<vIPIDevol>' + convType(aImp[12][1],15,2) + '</vIPIDevol>'
	cString += '<vPIS>'   + convType(aImp[5][2],15,2) + '</vPIS>'
	cString += '<vCOFINS>'+ convType(aImp[7][2],15,2) + '</vCOFINS>'
	cString += '<vOutro>' + convType(Val(oTotal:_Despesa:text),15,2)+'</vOutro>'
	cString += '<vNF>'    + convType(Val(oTotal:_vNF:text), 15, 2) + '</vNF>'
	cString += nfeTag('<vTotTrib>',"convType(aAuxTot[5],15,2)")
	cString += '</ICMSTot>'

	if( aImp[9][3]>0 )

		cString += '<ISSQNtot>'
		cString += nfeTag('<vServ>'  ,"convType(aAux[9][3],15,2)")
		cString += nfeTag('<vBC>'    ,"convType(aAux[9][1],15,2)")
		cString += nfeTag('<vISS>'   ,"convType(aAux[9][2],15,2)")
		cString += nfeTag('<vPIS>'   ,"convType(aAux[9][4],15,2)")
		cString += nfeTag('<vCOFINS>',"convType(aAux[9][5],15,2)")

		if( type("oXml:_dCompet:text") <> "U" )
			cString += '<dCompet>' + substr(oXml:_dCompet:text,1,4) + "-" + substr(oXml:_dCompet:text,5,2) + "-" + substr(oXml:_dCompet:text,7,2) +'</dCompet>'
		endif

		cString += nfeTag('<vDeducao>',"convType(aAux[9][6],15,2)")
		cString += nfeTag('<vOutro>',"convType(aAux[9][7],15,2)")
		cString += nfeTag('<vDescIncond>',"convType(aAux[9][8],15,2)")
		cString += nfeTag('<vDescCond>',"convType(aAux[9][9],15,2)")
		cString += nfeTag('<vISSRet>',"convType(aAux[9][10],15,2)")
		cString += nfeTag('<cRegTrib>',"oTotal:_cRegTrib:text")
		cString += '</ISSQNtot>'

	endif

	if( type("oXml:_TributoRetido") <> "U" )

		if( type("oXml:_TributoRetido") == "A" )
			aTrib := oTotal:_TributoRetido
		else
			aTrib := {oTotal:_TributoRetido}
		endif

		cString += '<retTrib>'
		nX := Ascan(aTrib,{|o| o:_Codigo:text == "PIS"})

		if( nX > 0 )
			cString += '<vRetPIS>'+convType(Val(aTrib[nX]:_Valor:text),15,2)+'</vRetPIS>'
		endif

		nX := Ascan(aTrib,{|o| o:_Codigo:text == "COFINS"})

		if( nX > 0 )
			cString += '<vRetCOFINS>'+convType(Val(aTrib[nX]:_Valor:text),15,2)+'</vRetCOFINS>'
		endif

		nX := Ascan(aTrib,{|o| o:_Codigo:text == "CSLL"})

		if( nX > 0 )
			cString += '<vRetCSLL>'+convType(Val(aTrib[nX]:_Valor:text),15,2)+'</vRetCSLL>'
		endif

		nX := Ascan(aTrib,{|o| o:_Codigo:text == "IRRF"})

		if( nX > 0 )
			cString += '<vBCIRRF>' + convType(Val(aTrib[nX]:_BC:text), 15, 2) + '</vBCIRRF>'
			cString += '<vIRRF>' + convType(Val(aTrib[nX]:_Valor:text), 15, 2) + '</vIRRF>'
		endif

		nX := Ascan(aTrib,{|o| o:_Codigo:text == "INSS"})

		if( nX > 0 )

			cString += '<vBCRetPrev>' + convType(Val(aTrib[nX]:_BC:text), 15, 2) + '</vBCRetPrev>'

			if type (aTrib[nX]:_Valor:text) <> "U"
				cString += '<vRetPrev>' + convType(Val(aTrib[nX]:_Valor:text), 15, 2) + '</vRetPrev>'
			endif

		endif

		cString += '</retTrib>'

	endif

	cString += '</total>'

	aSize(aAux, 0)
	aSize(aTrib, 0)
	aSize(aAuxTot, 0)

	aAux := nil
	aTrib := nil
	aAuxTot := nil

return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc}	XmlNfeTransp
Monta Grupo com daddos da Transportadora da NFe

@param oTransp      Objeto com dados do Transportador da NFe

@return	cString	    XML com Dados do transportador rda NFe

@author	Valter Silva
@since		21/02/2018
@version 	12.1.17
/*/
//-----------------------------------------------------------------------
static function XmlNfeTransp(oTransp)

	local cString    := ""
	local nZ         := 0
	local nY         := 0

	private aVol     := {}
	private nX       := 0
	private oXml     := oTransp
	private aReboque := {}


	cString += '<transp>'
	cString += '<modFrete>'+oXml:_ModFrete:text+'</modFrete>'

	if( type("oXml:_Transporta") <> "U" )

		cString += '<transporta>'
		cString += nfeTag('<CNPJ>'  ,"oXml:_Transporta:_CNPJ:text")
		cString += nfeTag('<CPF>'   ,"oXml:_Transporta:_CPF:text")
		cString += nfeTag('<xNome>' ,"oXml:_Transporta:_Nome:text")
		cString += nfeTag('<IE>'    ,"oXml:_Transporta:_IE:text")
		cString += nfeTag('<xEnder>',"oXml:_Transporta:_Ender:text")
		cString += nfeTag('<xMun>'  ,"oXml:_Transporta:_Mun:text")
		cString += nfeTag('<UF>'    ,"oXml:_Transporta:_UF:text")
		cString += '</transporta>'
	endif

	if type("oXml:_RetTransp")<>"U" .and. Val(oXml:_RetTransp:_Tributo:_Valor:text)>0

		cString += '<retTransp>'
		cString += '<vServ>'   +convType(Val(oXml:_RetTransp:_Cpl:_vServ:text),15,2)+'</vServ>'
		cString += '<vBCRet>'  +convType(Val(oXml:_RetTransp:_Tributo:_vBC:text),15,2)+'</vBCRet>'
		cString += '<pICMSRet>'+convType(Val(oXml:_RetTransp:_Tributo:_Aliquota:text),7,4)+'</pICMSRet>'
		cString += '<vICMSRet>'+convType(Val(oXml:_RetTransp:_Tributo:_Valor:text),15,2)+'</vICMSRet>'
		cString += '<CFOP>'    +oXml:_RetTransp:_Cpl:_CFOP:text+'</CFOP>'
		cString += '<cMunFG>'  +oXml:_RetTransp:_Cpl:_cMunFG:text+'</cMunFG>'
		cString += '</retTransp>'

	endif

	if( type("oXml:_Veictransp") <> "U" )
		cString += '<veicTransp>'
		cString += '<placa>'+oXml:_Veictransp:_Placa:text+'</placa>'
        if !type("oXml:_Veictransp:_UF:text") == "U" .and. !empty(oXml:_Veictransp:_UF:text)
			cString += '<UF>'   +oXml:_Veictransp:_UF:text+'</UF>'
        endif
		cString += nfeTag('<RNTC>',"oXml:_Veictransp:_RNTC:text")
		cString += '</veicTransp>'
	endif

	if( type("oXml:_Reboque") <> "U" )

		if type("oXml:_Reboque")=="A"
			aReboque := oXml:_Reboque
		else
			aReboque := {oXml:_Reboque}
		endif

		for nZ := 1 To Min(2,Len(aReboque))
			nX := nZ
			cString += '<reboque>'
			cString += '<placa>'+aReboque[nX]:_Placa:text+'</placa>'
            if !type("aReboque[nX]:_UF:text") == "U" .and. !empty(aReboque[nX]:_UF:text)
               	cString += '<UF>' + aReboque[nX]:_UF:text + '</UF>'
           	endif
			cString += nfeTag('<RNTC>',"aReboque[nX]:_RNTC:text")
			cString += '</reboque>'
		next nZ
	endif

	if( type("oXml:_vagao") <> "U" )
		cString += nfeTag('<vagao>',"oXml:_vagao:text")
	endif

	if( type("oXml:_balsa") <> "U" )
		cString += nfeTag('<balsa>',"oXml:_balsa:text")
	endif

	if( type("oXml:_Vol") <> "U" )

		if valType(oXml:_Vol)=="A"
			aVol := oXml:_Vol
		else
			aVol := {oXml:_Vol}
		endif

		for nZ := 1 To Len(aVol)
			nX := nZ
			cString += '<vol>'
			cString += nfeTag('<qVol>'  ,"convType(Val(aVol[nX]:_qVol:text),15,0)")
			cString += nfeTag('<esp>'   ,"NoAcento(aVol[nX]:_esp:text)")
			cString += nfeTag('<marca>' ,"aVol[nX]:_Marca:text")
			cString += nfeTag('<nVol>'  ,"aVol[nX]:_nVol:text")
			cString += nfeTag('<pesoL>' ,"convType(Val(aVol[nX]:_pesol:text),15,3)")
			cString += nfeTag('<pesoB>' ,"convType(Val(aVol[nX]:_pesob:text),15,3)")

			if( type("aVol[nX]:_Lacres") <> "U" )

				if( valType(aVol[nX]:_Lacres) == "A" )
					aLacres := aVol[nX]:_Lacres
				else
					aLacres := {aVol[nX]:_Lacres}
				endif

				for nY := 1 To Len(aLacres)
					cString += '<lacres>'
					cString += '<nLacre>'+aLacres[nY]:_LACRE:text+'</nLacre>'
					cString += '</lacres>'
				next nY

			endif

			cString += '</vol>'

		next nX

	endif

	cString += '</transp>'

	aSize(aReboque, 0)

return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc}	XmlNfeCob
Monta Grupo com dados da Duplicata da NFe

@param oDupl        Objeto com os dados da duplicata da NFe

@return	cString	    XML com dados da duplicata

@author	Valter Silva
@since		21/02/2018
@version 	12.1.17
/*/
//-----------------------------------------------------------------------
static function XmlNfeCob(oDupl)

	local cString := ""
	local nZ      := 0
	local aDupl  := {}
	private aFat  := {}
	private oXml  := oDupl
	private nX    := 0

	if(  oXml <> Nil )
		if( valType(oXml:_Dup) == "A" )
			aDupl := oXml:_Dup
		else
			aDupl := {oXml:_Dup}
		endif

		cString += '<cobr>'

		IF Type("oXml:_Fat") <> "U"

			if( valType(oXml:_Fat) == "A" )
          		aFat := oXml:_Fat
        	else
				aFat := {oXml:_Fat}
        	endif

        	If Len(aFat)>0
				cString += '<fat>'
				cString += '<nFat>'+aFat[01]:_nFatura:text+'</nFat>'
				cString += '<vOrig>'+convType(Val(aFat[01]:_vOriginal:text), 15, 2)+'</vOrig>'
				If type("aFat[01]:_vDesconto:text") <> "U"
			   		cString +=  '<vDesc>'+convType(val(aFat[01]:_vDesconto:text), 15, 2)+'</vDesc>'
				Else
			   		cString +=  '<vDesc>0</vDesc>'
				EndIf 
				cString += '<vLiq>' +convType(Val(aFat[01]:_vLiquido:text), 15, 2)+'</vLiq>'
				cString += '</fat>'
		 	EndIf
		 	aSize(aFat,0)
		 	aFat:= nil
		EndIf

		for nZ := 1 To Len(aDupl)
			nX := nZ
			cString += '<dup>'
			cString += '<nDup>' + aDupl[nX]:_Dup:text + '</nDup>'
			cString += '<dVenc>'+ aDupl[nX]:_dtVenc:text + '</dVenc>'
			cString += '<vDup>' + convType(Val(aDupl[nX]:_vDup:text), 15, 2) + '</vDup>'
			cString += '</dup>'
		next nX

		cString += '</cobr>'

	endif

return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc}	XmlNfeCob
Monta Grupo com dados do tipo de pagamento da NFe

@param   aPgto	 Array com os dados de pagamento da NFe

@return	cString	 XML com dados do pagamento da NFe

@author	Valter Silva
@since		21/02/2018
@version 	12.1.17
/*/
//-----------------------------------------------------------------------
static function XmlNfePag(oPgto)

	local aDetPgto := {}
	local cString  := ""
	local nX

	private oXml := oPgto

	cString := '<pag>'

	if( type("oXml:_detPag") == "O")
		aDetPgto := {oXml:_detPag}
	elseIf( type("oXml:_detPag") == "A" )
		aDetPgto := oXml:_detPag
	endif

	for nX := 1 to len(aDetPgto)

		oXml := aDetPgto[nX]

		cString += '<detPag>'
		If Type("oXml:_indForma:text") <> "U"
        	cString += '<indPag>' + oXml:_indForma:text + '</indPag>'
       endif
		cString += '<tPag>' + oXml:_forma:text + '</tPag>'
        cString += nfeTag('<xPag>', "oXml:_xPag:text") // NT 2020.006 informar descr. meio de pag. qdo tPag = 99 - Outros
		cString += nfetag('<vPag>', "convType(val(oXml:_valor:text), 15, 2)",.T.)

		if( type("oXml:_cartoes") <> "U" ) // NT2015/002 campos do grupo "Card" não são mais obrigatórios
			cString += '<card>'
			cString += '<tpIntegra>' + oXml:_cartoes:_tpIntegra:text + '</tpIntegra>'
			cString += nfeTag('<CNPJ>',"oXml:_cartoes:_cnpj:text")
			cString += nfeTag('<tBand>',"oXml:_cartoes:_bandeira:text")
			cString += nfeTag('<cAut>',"oXml:_cartoes:_autorizacao:text")
			cString += '</card>'
		endif

		cString += '</detPag>'

	next

	oXml := oPgto

	cString += nfeTag("<vTroco>", "convType(val(oXml:_vTroco:text), 15, 2)", .F.)

	cString += '</pag>'

	aSize(aDetPgto, 0)
	aDetPgto := nil

return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc}	XmlNfeInf
Monta Grupo com dados das informações complementares da NFe

@param  oInf	  Objeto com os dados da informação adicional da NFe
@param  lUsaColab Indica se utiliza colaboração

@return	cString	 String contendo os dados adicionais da NFe

@author	Valter Silva
@since		21/02/2018
@version 	12.1.17
/*/
//-----------------------------------------------------------------------
static function XmlNfeInf(oInf, lUsaColab)

	local cString  := ""
	local aprocRef := {}
	local nZ       := 0

	Default lUsaColab	:=.F.

	private nX   := 0
	private oXml := oInf

	if( oInf <> Nil )

		cString += '<infAdic>'
		cString += nfeTag('<infAdFisco>',"convType(oXml:_FISCO:text,2000,0)")

		if( 	type("oXml:_ANFAVEACPL:text")=="U" .and. type("oXml:_Cpl")<>"U" .and. !empty("oXml:_Cpl:text") )
			cString += nfeTag('<infCpl>',"convType(oXml:_Cpl:text,5000,0)")

		elseIf( type("oXml:_ANFAVEACPL:text") <> "U" )

			if( lUsaColab )

				cString += '<infCpl>'
				cString +="<![CDATA["+oXml:_ANFAVEACPL:text+"]]>"
				cString += iif(type("oXml:_Cpl:text")=="U","",convType(oXml:_Cpl:text,5000,0))
				cString +='</infCpl>'
			else

				cString += '<infCpl>'
				cString +="<![CDATA[<![CDATA["+oXml:_ANFAVEACPL:text+"]]]]><![CDATA[>]]>"
				cString += iif(type("oXml:_Cpl:text")=="U","",convType(oXml:_Cpl:text,5000,0))
				cString +='</infCpl>'

			endif

		endif

		if( type("oXml:_obsCont") <> "U" )

			if( type("oXml:_obsCont") == "A" )
				aObsCont := oXml:_obsCont
			else
				aObsCont := {oXml:_obsCont}
			endif

			for nZ := 1 To Len(aObsCont) // conforme manual da SEFAZ possibilita ter informacoes somente 10 TAG's obsCont

				nX := nZ

				if nX <= 10
					cXcampo := convType(aObsCont[nX]:_xCampo:text,20)
					cString += '<obsCont xCampo="'+cXcampo+'">'
					cString += '<xTexto>'+convType(aObsCont[nX]:_xTexto:text,60)+'</xTexto>'
					cString += '</obsCont>'

				else
					Exit

				endif

			next nZ

		endif

		if( type("oXml:_procRef") <> "U" )

			if( type("oXml:_procRef") == "A")
				aprocRef := oXml:_procRef
			else
				aprocRef := {oXml:_procRef}
			endif

			for nZ := 1 To Len(aprocRef) // conforme manual da SEFAZ possibilita ter informacoes somente 10 TAG's obsCont
				cString += '<procRef>'
				cString += '<nProc>'+convType(aprocRef[nZ]:_nProc:text,60)+'</nProc>'
				cString += '<indProc>'+convType(aprocRef[nZ]:_indProc:text,1)+'</indProc>'
				cString += Iif(AttIsMemberOf(aprocRef[nZ], "_tpAto"), '<tpAto>' +convType(aprocRef[nZ]:_tpAto:text,2)+ '</tpAto>', '')
				cString += '</procRef>'
			next nZ

		endif

		cString += '</infAdic>'

	endif

return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc}	XmlNfeExp
Monta Grupo com dados de exportação da NFe

@param  oExp	 Objeto com dados da Exportação da NFe

@return	cString  XML com dados da exportação

@author	Valter Silva
@since		21/02/2018
@version 	12.1.17
/*/
//-----------------------------------------------------------------------
static function XmlNfeExp(oExp)

	local cString := ""

	private oXml := oExp

	if( oExp <> Nil )

		cString += '<exporta>'
		cString += '<UFSaidaPais>' + oXml:_UFEmbarq:text + '</UFSaidaPais>'
		cString += '<xLocExporta>' + convType(oXml:_locembarq:text,60) + '</xLocExporta>'
		cString += nfeTag('<xLocDespacho>',"convType(oXml:_locdespacho:text,60)")
		cString += '</exporta>'

	endif

return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc}	XmlNfeInfCompra
Monta Grupo com dados do pedido de compra da NFe

@param  oCompra	 Objeto com os dados do pedido de compra da NFe

@return	cString	 XML com os dados do pedido de compra da NFe

@author Reanto Nagib
@since 11/08/2017
@version 12.1.17
/*/
//-----------------------------------------------------------------------
static function XmlNfeInfCompra(oCompra)

	local cString := ""
	private oXml  := oCompra

	if( oCompra <> Nil )
		cString += '<compra>'
		cString += nfeTag('<xNEmp>',"oXml:_NEmp:text")
		cString += nfeTag('<xPed>',"oXml:_Pedido:text")
		cString += nfeTag('<xCont>',"oXml:_Contrato:text")
		cString += '</compra>'
	endif

return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc}	XmlNfeCana
Monta Grupo com dados de NFe referente a aquisição de cana de acucar

@param	oCana	 Objeto com os dados da aquisição de cana

@return	cString	 XML com os dados da aquisição de cana

@author Natalia Sartori
@since 20/05/2014
@version 1.0
/*/
//-----------------------------------------------------------------------
static function XmlNfeCana(oCana)

	local nZ :=0
	local cString := ""
	local aDeduc := {}

	private aForDia := {}

	private oXml    := oCana

	if oCana <> Nil

		cString += '<cana>'
		cString += '<safra>'+oXml:_safra:text+'</safra>'
		cString += '<ref>'+oXml:_ref:text+'</ref>'

		if(type("oXml:_forDia") <> "U" )

			if type("oXml:_forDia")=="A"
				aForDia := oXml:_forDia
			else
				aForDia := {oXml:_forDia}
			endif

			for nZ := 1 To Len(aForDia) // conforme manual da SEFAZ possibilita ter informacoes somente 31 TAG's forDia

				if( nZ <= 31   )
					cString += '<forDia dia="'+aForDia[nZ]:_dia:text+'">'
					cString += '<qtde>'+convType(Val(aForDia[nZ]:_qtde:text),21,10)+'</qtde>'
					cString += '</forDia>'
				else
					Exit
				endif

			next nZ
		endif

		cString += '<qTotMes>'+convType(Val(oXml:_qTotMes:text),21,10)+'</qTotMes>'
		cString += '<qTotAnt>'+convType(Val(oXml:_qTotAnt:text),21,10)+'</qTotAnt>'
		cString += '<qTotGer>'+convType(Val(oXml:_qTotGer:text),21,10)+'</qTotGer>'

		if( type("oXml:_deduc") <> "U" )

			if type("oXml:_deduc") == "A"
				aDeduc := oXml:_deduc
			else
				aDeduc := {oXml:_deduc}
			endif

			for nZ := 1 To Len(aDeduc) // conforme manual da SEFAZ possibilita ter informacoes somente 10 TAG's deduc

				if nZ <= 10
					cString += '<deduc>'
					cString += '<xDed>'+convType(aDeduc[nZ]:_xDed:text,60)+'</xDed>'
					cString += '<vDed>'+convType(Val(aDeduc[nZ]:_vDed:text),17,2)+'</vDed>'
					cString += '</deduc>'
				else
					Exit
				endif

			next nZ

		endif

		cString += '<vFor>'+convType(Val(oXml:_vFor:text),17,2)+'</vFor>'
		cString += '<vTotDed>'+convType(Val(oXml:_vTotDed:text),17,2)+'</vTotDed>'
		cString += '<vLiqFor>'+convType(Val(oXml:_vLiqFor:text),17,2)+'</vLiqFor>'
		cString += '</cana>'

	endif

	aSize(aForDia, 0)
	aSize(aDeduc, 0)

return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc}	RetInfAdic
Retira tags vazias das informações complementares

@param  cXml	 XML da NFe 4.00

@return	cXml	 XML formtado sem as tags vazias

@author	Valter Silva
@since		21/02/2018
@version 	12.1.17
/*/
//-----------------------------------------------------------------------
static function RetInfAdic(cXml)
	Local aRespNfe := {}
	Default cXml := ""

	nX := At("[CONTRTSS=",UPPER(cXml))
	If nX > 0
		cStr	:=	SubStr(cXml,nX+10)
		aAdd(aRespNfe,SToD(StrTran(SubStr(cStr,1,At("#",cStr)-1),"-","")))

		cStr	:=	SubStr(cStr,At("#",cStr)+1)
		aAdd(aRespNfe,SubStr(cStr,1,At("#",cStr)-1))

		cStr	:=	SubStr(cStr,At("#",cStr)+1)
		nStr	:=	At("]",cStr)
		aAdd(aRespNfe,SubStr(cStr,1,nStr-1))
		cXml	:= SubStr(cXml,1,nX-1)+SubStr(cStr,nStr+1)
		cXml 	:= StrTran(cXml,"<infAdic><infAdFisco></infAdFisco><infCpl></infCpl></infAdic>","")
		cXml 	:= StrTran(cXml,"<infAdic><infAdFisco></infAdFisco></infAdic>","")
		cXml 	:= StrTran(cXml,"<infAdic><infCpl></infCpl></infAdic>","")
		cXml 	:= StrTran(cXml,"<infAdic>></infCpl></infAdic>","")
		cXml 	:= StrTran(cXml,"<infAdic></infAdic>","")
		cXml 	:= StrTran(cXml,"<infCpl></infCpl>","")
	EndIf

return cXml

//-----------------------------------------------------------------------
/*/{Protheus.doc} XmlNfeAut
Função que monta o grupo autXML da NFe 3.10

@param		oAutXml	 grupo autXML

@return	cString	 String contendo o grupo autXML

@author Natalia Sartori
@since 20/05/2014
@version 1.0
/*/
//-----------------------------------------------------------------------

static Function XmlNfeAut(oAutXml)

	local cString := ""

	private oXml := oAutXml

	if( oAutXml <> nil )

		cString := '<autXML>'

		if( Type("oXml:_CNPJ:TEXT")<>"U" .And. !Empty(oXml:_CNPJ:TEXT))
			cString += '<CNPJ>' + oXml:_CNPJ:TEXT + '</CNPJ>'
		elseIf( Type("oXml:_CPF:TEXT")<>"U" .And. !Empty(oXml:_CPF:TEXT))
			cString += '<CPF>' + oXml:_CPF:TEXT + '</CPF>'
		endIf

		cString += '</autXML>'

	endIf

Return(cString)

//-----------------------------------------------------------------------
/*/{Protheus.doc}	convType
Formata conteudo

@param xValor   Valor do conteudo
@param nTam     tamanho da valor(Inteiro + decimais)
@param nDec     Numero de casas decimais
@param cTipo    Tipo do conteudo

@return	cNovo	 Conteudo formatado

@author	Valter Silva
@since		21/02/2018
@version 	12.1.17
/*/
//-----------------------------------------------------------------------
static function convType(xValor,nTam,nDec,cTipo,lMasc)

	local cNovo 	:= ""

	DEFAULT nDec 	:= 0
	DEFAULT cTipo 	:= ""
	DEFAULT lMasc   := .F.
	Do Case

	Case valType(xValor)=="N"

		if xValor <> 0 .or. lMasc
			cNovo := AllTrim(str(xValor,nTam+1,nDec))
			if Len(cNovo)>nTam
				cNovo := AllTrim(str(xValor,nTam+1,nDec-(Len(cNovo)-nDec)))
			endif

		else
			cNovo := "0"
		endif

	Case valType(xValor)=="D"
		cNovo := FsDateConv(xValor,"YYYYMMDD")
		cNovo := substr(cNovo,1,4)+"-"+substr(cNovo,5,2)+"-"+substr(cNovo,7)

	Case valType(xValor)=="C"

		if ( cTipo == "N" )
			cDecOk := substr(xValor,at(".",xValor)+1)

			if ( len(cDecOk) > nDec )
				xValor := substr(xValor,1,len(xValor)-(len(cDecOk)-nDec))
			endif

			if ( len(xValor) > nTam )
				nDesconto := len(xValor) - nTam
				xValor := substr(xValor,1,len(xValor)-nDesconto)
			endif

			if ( substr(xValor,len(xValor)) == "." )
				xValor := substr(xValor,1,len(xValor)-1)
			endif

			cNovo := allTrim(xValor)

		else

			if nTam==Nil
				xValor := AllTrim(xValor)
			endif

			DEFAULT nTam := 60
			cNovo := AllTrim(EnCodeUtf8(NoAcento(substr(xValor,1,nTam))))

		endif
	EndCase

return cNovo

//-----------------------------------------------------------------------
/*/{Protheus.doc}	nfeTag
Monta tag XML

@param cTag         Nome da Tag
@param nTam         Conteudo para a tag
@param lBranco      Considera montagem da TAG em caso de conteudo vazio

@return	cRetorno    TAG Montada com conteudo

@author	Valter Silva
@since		21/02/2018
@version 	12.1.17
/*/
//-----------------------------------------------------------------------
static function nfeTag(cTag,cConteudo,lBranco)

	local cRetorno := ""
	local lBreak   := .F.
	local bErro    := ErrorBlock({|e| , break(E),lBreak := .T. })
	local nFimTag  := 0

	DEFAULT lBranco := .F.

	Begin Sequence

		cConteudo := &(cConteudo)

		if lBreak
			BREAK
		endif

	Recover

		if lBranco
			cConteudo := ""
		else
			cConteudo := Nil
		endif

	End Sequence

	ErrorBlock(bErro)

	if( cConteudo <> Nil .and. ((!empty(allTrim(cConteudo)) .and. ( hasAlpha(allTrim(cConteudo))) .Or. Val(AllTrim(cConteudo))<>0) .Or. lBranco) )

		nFimTag :=At(" ",cTag)

		cRetorno := cTag+AllTrim(cConteudo)
		cRetorno +="</"

		if( nFimTag > 0)
			cRetorno+=substr(cTag,2,nFimTag-1)+">"
		else
			cRetorno+=substr(cTag,2)
		endif

	endif

return cRetorno

//-----------------------------------------------------------------------
/*/{Protheus.doc}	nfeTag
Verifica se o conteudo e AlphaNUmerico

@param cTexto   COnteudo a ser

@return	cRetorno    TAG Montada com conteudo

@author	Valter Silva
@since		21/02/2018
@version 	12.1.17
/*/
//-----------------------------------------------------------------------
static function hasAlpha(cTexto)

	local lRetorno := .F.
	local cAux     := ""

	while !empty(cTexto)
		cAux := substr(cTexto,1,1)
		if( (Asc(cAux) > 64 .and. Asc(cAux) < 123) .OR. cAux $ '|#' )
			lRetorno := .T.
			cTexto := ""
		endif

		cTexto := substr(cTexto,2)

	endDo

return lRetorno

//-----------------------------------------------------------------------
/*/{Protheus.doc} GetUFCode
Funcao de recuperacao dos codigos de UF do IBGE

@param ExpC1: Codigo do Estado ou UF
	   ExpC2: lForceUf

@return	cRetorno    TAG Montada com conteudo

@author		Eduardo Riera
@since		11.05.2007
@version 	12.1.17
/*/
//-----------------------------------------------------------------------
Static Function GetUFCode(cUF,lForceUF)

Local nX         := 0
Local cRetorno   := ""
Local aUF        := {}
DEFAULT lForceUF := .F.

aadd(aUF,{"RO","11"})
aadd(aUF,{"AC","12"})
aadd(aUF,{"AM","13"})
aadd(aUF,{"RR","14"})
aadd(aUF,{"PA","15"})
aadd(aUF,{"AP","16"})
aadd(aUF,{"TO","17"})
aadd(aUF,{"MA","21"})
aadd(aUF,{"PI","22"})
aadd(aUF,{"CE","23"})
aadd(aUF,{"RN","24"})
aadd(aUF,{"PB","25"})
aadd(aUF,{"PE","26"})
aadd(aUF,{"AL","27"})
aadd(aUF,{"SE","28"})
aadd(aUF,{"BA","29"})
aadd(aUF,{"MG","31"})
aadd(aUF,{"ES","32"})
aadd(aUF,{"RJ","33"})
aadd(aUF,{"SP","35"})
aadd(aUF,{"PR","41"})
aadd(aUF,{"SC","42"})
aadd(aUF,{"RS","43"})
aadd(aUF,{"MS","50"})
aadd(aUF,{"MT","51"})
aadd(aUF,{"GO","52"})
aadd(aUF,{"DF","53"})

If !Empty(cUF)
	nX := aScan(aUF,{|x| x[1] == cUF})
	If nX == 0
		nX := aScan(aUF,{|x| x[2] == cUF})
		If nX <> 0
			cRetorno := aUF[nX][1]
		EndIf
	Else
		cRetorno := aUF[nX][IIF(!lForceUF,2,1)]
	EndIf
Else
	cRetorno := aUF
EndIf
Return(cRetorno)

//-----------------------------------------------------------------------
/*/{Protheus.doc}	XmlNfeIntermed
Responsavel por criar o grupo Intermediador da Operacao, Marketplace e outros
(infIntermed)

@param  oInf	  Objeto com os dados da informação adicional da NFe
@return cString	 String contendo os dados adicionais da NFe

@author Felipe Sales Martinez
@since 18/01/2021
@version 12.1.27
/*/
//-----------------------------------------------------------------------
static function XmlNfeIntermed(oIntermed)
local cString   := ""

private oXml    := oIntermed 

if oIntermed <> Nil
    cString += '<infIntermed>'
    if type("oXml:_CNPJ:text") == "C"
        cString += '<CNPJ>' + oXml:_CNPJ:text + '</CNPJ>'
    endIf
    if type("oXml:_idCadIntTran:text") == "C"
        cString += '<idCadIntTran>' + oXml:_idCadIntTran:text + '</idCadIntTran>'
    endif
    cString += '</infIntermed>'
endIf

return cString
