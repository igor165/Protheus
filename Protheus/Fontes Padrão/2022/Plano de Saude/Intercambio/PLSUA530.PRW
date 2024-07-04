#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PLSMCCR.CH"
#INCLUDE "PLSUA530.CH"

#define lLinux IsSrvUnix()
#IFDEF lLinux
	#define CRLF Chr(13) + Chr(10)
#ELSE
	#define CRLF Chr(10)
#ENDIF    

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSUA530
Envia arquivo com glosas totais/baixa do envio

@author  Renan Sakai
@version P12
@since   09/01/2017
/*/
//-------------------------------------------------------------------
Function PLSUA530(aDados,lMsg)
Local oObjXml	:= NIL
Local aRetDad	:= {}
Local aParam	:= {}
Local aRetSoap	:= {}
Local cRet		:= ""

Default lMsg	:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera arquivo XML                										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRetDad := GeraXml(aDados)
If aRetDad[1]

	//Ponto de entrada utilizada para testes internos
	If ExistBlock( "PLWSDPTU" )
		aRetAux := ExecBlock( "PLWSDPTU", .F., .F., {"baixarAvisoWS",aRetDad[2]} )
	Else
		aParam := { PLSMUDSIS("\plsptu\A530\certificados\certificado.p12"), ;	
					PLSMUDSIS("\plsptu\A530\certificados\cert.pem"), ;  
					PLSMUDSIS("\plsptu\A530\certificados\key.pem"), ;  
					GetNewPar("MV_P530SEN",""), ;
					GetNewPar("MV_PTGLOBX","https://cmbhml.unimed.coop.br/ws/inadimplencia/solicitarBaixa?wsdl"), ;
					"530" }
					
		//Realiza a comunicacao com o EndPoint da Unimed
		aRetAux := PLTWsdlMng(aRetDad[2],aParam)
		If !aRetAux[1]
			If !Empty(aRetAux[2])
				If lMsg
					MsgInfo(STR0001+aRetAux[2]) //"Não foi possível realizar a comunicação: "
				Else
					cRet := STR0001+aRetAux[2] //"Não foi possível realizar a comunicação: "
				EndIf
			ElseIf !Empty(aRetAux[3])
				If lMsg
					MsgInfo(STR0001+aRetAux[3]) //"Não foi possível realizar a comunicação: "
				Else
					cRet := STR0001+aRetAux[3] //"Não foi possível realizar a comunicação: "
				EndIf
			EndIf
		EndIf
	EndIf
	
	//Arquivo foi processado corretamente, vamos processar a resposta
	If aRetAux[1] 
		aRetSoap := PLVldXmlP2(aRetAux[2],"a530","nc_Transacoes-V1_00_00.xsd","V1_00_00","v1")
		If aRetSoap[1]
			oObjXml := aRetSoap[2]
			ProcesA535(oObjXml,aRetSoap[3],aRetSoap[5])  
		Else
			If lMsg   
				MsgInfo(STR0002+aRetSoap[4]) //"Erro ao processar a resposta: "
			Else
				cRet := STR0002+aRetSoap[4] //"Erro ao processar a resposta: "
			EndIf
		EndIf
	EndIf

//Nao foi possivel gerar o Soap de Envio
Else
	If lMsg
		MsgInfo(aRetDad[3])
	Else
		cRet := aRetDad[3]
	EndIf
EndIf

Return(cRet)
   

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraXml
Gera arquivo XML A530

@author  Renan Sakai
@since   09/01/2017
@version P12
/*/
//-------------------------------------------------------------------       
Static Function GeraXml(aDados,lEnvSoap)
Local cXml     	:= ""    
Local cErro    	:= ""
Local cAviso   	:= ""
Local cStrHash 	:= ""  
Local cSoap    	:= ""
Local cSchema  := GetNewPar("MV_P530XSD","mi_Transacoes-V1_00_00.xsd")    
Local lRet     := .T.

Default lEnvSoap   := .T.   

//Monta cabecalho   
cXml += PTXmlWbTag("cabecalhoTransacao","v1",nil,nil,nil,.T.,nil)   
cXml += PTXmlWbTag("tipoTransacao"              ,"v1","530"		 ,@cStrHash,.T.) 
cXml += PTXmlWbTag("codigoUnimedOrigemMensagem" ,"v1",cValToChar(Val(Substr(PlsIntPad(),2,3))),@cStrHash,.T.) 
cXml += PTXmlWbTag("codigoUnimedDestinoMensagem","v1",cValToChar(Val(aDados[03]))		 ,@cStrHash,.T.) 
cXml += PTXmlWbTag("versaoTransacao"            ,"v1","01"     	 ,@cStrHash,.T.) 

cXml += PTXmlWbTag("cabecalhoTransacao","v1",nil,nil,nil,nil,.T.)                

//Corpo Mensagem
cXml += PTXmlWbTag("dadosglosaoubaixa","v1",nil,nil,nil,.T.,nil)
                                          
cXml += PTXmlWbTag("tipoGlosaBaixa","v1",aDados[01],@cStrHash,.T.)
If aDados[02] <> "0"
	cXml += PTXmlWbTag("motivoBaixa","v1",aDados[02],@cStrHash,.T.)
EndIf	
cXml += PTXmlWbTag("codigoUnimedAviso","v1",cValToChar(Val(aDados[03])),@cStrHash,.T.)
cXml += PTXmlWbTag("dataConhecimento","v1",ajustaData(aDados[04]),@cStrHash,.T.)
cXml += PTXmlWbTag("numeroLotePrestador","v1",aDados[05],@cStrHash,.T.)
cXml += PTXmlWbTag("numeroGuiaTissPrestador","v1",aDados[06],@cStrHash,.T.)
cXml += PTXmlWbTag("codigoUnimedBeneficiario","v1",aDados[07],@cStrHash,.T.)
cXml += PTXmlWbTag("identificacaoBeneficiario","v1",aDados[08],@cStrHash,.T.,,,.T.)

cXml += PTXmlWbTag("dadosPrestador","v1",nil,nil,nil,.T.,nil)
	If aDados[09][1] == "1"
		cXml += PTXmlWbTag("cpfPrestador","v1",aDados[09][2],@cStrHash,.T.)
	Else
    	cXml += PTXmlWbTag("cnpjPrestador","v1",aDados[09][2],@cStrHash,.T.)
	EndIf	
cXml += PTXmlWbTag("dadosPrestador","v1",nil,nil,nil,nil,.T.)

cXml += PTXmlWbTag("dadosglosaoubaixa","v1",nil,nil,nil,nil,.T.)	

//Gera o hash
cXml += PTXmlWbTag("hash","v1",MD5(cStrHash,2),nil,.T.)

//Fecha o arquivo
cXml += PTXmlWbTag("baixarAvisoWS","v1",nil,nil,nil,nil,.T.)  

If lEnvSoap
	cSoap := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="http://nc.unimed.coop.br/schemas/V1_00_00">'+Chr(10) //cSoap := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="http://mi.unimed.coop.br/schemas/V1_00_00">'+Chr(10)     
	cSoap += '<soapenv:Header/>'+Chr(10)
	cSoap += '<soapenv:Body>'+Chr(10)  
	cSoap += '<v1:baixarAvisoWS>'
	cSoap += cXml+Chr(10)
	cSoap += '</soapenv:Body>'+Chr(10)
	cSoap += '</soapenv:Envelope>'+Chr(10)
EndIf 

aRet := PTVldXmlLy(cSoap,.T.,"nc_Transacoes-V1_00_00.xsd","V1_00_00","a530")
If !aRet[1]
	lRet := .F.
	cErro := aRet[2]
EndIf

Return {lRet,cSoap,cErro}  

//-------------------------------------------------------------------
/*/{Protheus.doc} ajustaData
Ajusta a data para o formato esperado no SOAP

@author  PLS TEAM
@version P11
@since   06.09.16       
/*/
//-------------------------------------------------------------------     
Static Function ajustaData(dData,cHorario)
Local cRet := ""                         
Default cHorario := Time()   

If !Empty(dData)
	cRet := Substr(Dtos(dData),1,4)+"-"+Substr(Dtos(dData),5,2)+"-"+Substr(Dtos(dData),7,2)//+"T"+cHorario
EndIf

Return cRet   


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcesA535
Processa resposta A535

@author  PLS TEAM
@version P11
@since   06.09.16       
/*/
//-------------------------------------------------------------------   
Static Function ProcesA535(oXml,cRootNS,cNameSpace)

cCodUniOri := PLRetTagW2(oXml,cRootNS,"cabecalhoTransacao\tipoTransacao",,4)
cStatRet := PLRetTagW2(oXml,cRootNS,"statusGlosaBaixa\statusRetorno",,)

MsgInfo(STR0003+" - " + cCodUniOri + " - " + cStatRet ) //"Processado Ok"
Return
