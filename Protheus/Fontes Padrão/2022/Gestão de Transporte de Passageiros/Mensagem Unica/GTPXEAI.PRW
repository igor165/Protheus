#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPXEAI.CH'

#DEFINE TP_LOGIC_RET	1 // (.T. , .F.)
#DEFINE TP_CHAR1_RET	2 // ("1" = Sim, "2" = Não"
#DEFINE TP_CHAR2_RET	3 // ("SIM",NÃO") 
#DEFINE TP_CHAR3_RET	4 // ("TRUE","FALSE")
#DEFINE TP_CHAR4_RET	5 // ("VERDADEIRO","FALSO")
#DEFINE TP_NUMB_RET 	6 // ( 1 = SIM, 2 = NÃO)

/*/{Protheus.doc} GTPXErro
// GTPXErro- Função utilizada para retornar o erro da integração
@author jacomo.fernandes
@sample GTPXErro(oModel,"Registro não encontrado no De/Para")
@since 15/02/2017
@version 12.1.7
@param oModel, object, Modelo (MVC) Passado por referencia para buscar o erro 
@param cMsgErro, characters, Caso haja uma mensagem a parte do modelo, deverá retornar essa mensagem
@return characters, String contendo o erro da integração
@type function
/*/
Function GTPXErro(oModel,cMsgErro)
Local cErro as char
Local aErro as array
Local aArea as array
Default cMsgErro := ""

aArea := GetArea()

If !Empty(cMsgErro)
	cErro := chr(13)+chr(10)+STR0001+chr(13)+chr(10)//"A integração não foi bem sucedida."
	cErro += STR0002//"Foi retornado o seguinte erro: "
	cErro += cMsgErro+chr(13)+chr(10)
Elseif !Empty(aErro := oModel:GetErrorMessage())
	cErro := chr(13)+chr(10)+STR0001+chr(13)+chr(10) //"A integração não foi bem sucedida."
	cErro += STR0002//"Foi retornado o seguinte erro: "
	If !Empty(_NoTags(Alltrim(aErro[4])))
		SX3->(DBSETORDER(2))
		If SX3->(DBSEEK(Padr(aErro[4],10)))
			cErro += AllTrim(X3TITULO()) +'('+_NoTags(Alltrim(aErro[4]))+')' +chr(13)+chr(10)
		Endif
	Endif
	If !Empty(_NoTags(Alltrim(aErro[5]))) .or. !Empty(_NoTags(Alltrim(aErro[6])))
		cErro += _NoTags(Alltrim(aErro[5])+'-'+AllTrim(aErro[6])) +chr(13)+chr(10)
	Endif

	If !Empty(_NoTags(Alltrim(aErro[8])))
		cErro += STR0003+_NoTags(Alltrim(aErro[8]))+ chr(13)+chr(10) //'Referencia:'
	Endif
	If !Empty(Alltrim(strtran(aErro[7], chr(13)+chr(10), '')))
		cErro += STR0004+_NoTags(AllTrim(aErro[7]))//'Solução - '
	Endif
Else
	cErro := STR0005//"A integração não foi bem sucedida."
	cErro += STR0006//'Verifique os dados enviados'
	
Endif
GTPDestroy(aErro) //Destroy variavel
Return cErro

//------------------------------------------------------------------------------------------

/*/{Protheus.doc} GTPxMakeId
// GTPxMakeId- função utilizada para criar uma chave de InternalId
@author jacomo.fernandes
@sample GTPxMakeId("COD001","ZA1",NIL,"01")
@sample GTPxMakeId({"COD001","ITEM002"},"ZA2",NIL,"01")
@since 15/02/2017
@version 12.1.7
@param [xId], , String ou Array unidimencional contendo os códigos a serem utilizados para montar a chave 
@param [cAlias], characters, Alias da tabela onde montará a chave
@param [cEmp], characters, Empresa utilizada para montar a chave (Padrão cEmpAnt) 
@param [cFil], characters, Filial utilizada para montar a chave (Padrão xFilial(cAlias)) 
@return characters, String contendo a chave da InternalId Ex.: "EMP|FIL|CODIGO1|CODIGON"
@type function
/*/
Function GTPxMakeId(xId, cAlias, cEmp, cFil)
Local   cRet	as char
Local	n1		as numeric
Default cEmp	:= cEmpAnt
Default cFil	:= xFilial(cAlias)

If ValType(xId) == "A" .and. Len(xId) > 0 //cEmp|cFil|cCod1|cCod2|cCodN
	cRet := RTrim(cEmp) + '|' + RTrim(cFil) 
	For n1 := 1 to Len(xId)
		cRet += '|' + RTrim(xId[n1])
	Next
Else//cEmp|cFil|cCod1
	If !Empty(xId)
		cRet := RTrim(cEmp) + '|' + RTrim(cFil) + '|' + RTrim(xId)
	Endif
Endif

Return cRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPxRetId
// GTPxRetId - Função utilizada para retorno da chave grava no de/para (XXF)
@author jacomo.fernandes
@sample GTPxRetId("LOGIX","ZA1","ZA1_COD","EXT0001",@cIntID,2,@lOk,@cErro,{"ZA1_FILIAL","ZA1_COD"},1)
@since 15/02/2017
@version 12.1.7
@param cMarca, characters, Referencia para buscar a origem da chave Ex.: PROTHEUS|LOGIX|DATASUL
@param cAlias, characters, Alias a qual está vinculada a chave
@param cCampo, characters, Campo a qual está vinculada a chave
@param cExtID, characters, Chave Externa da integração que será realizada a busca no de/para
@param cIntID, characters, Chave Interna da integração (pode ser passada por referencia)
@param nOrdem, numeric, Ordem do Array que deve-se buscar do array
@param lOk, logical, variavel passada por referencia para saber se a busca foi com sucesso
@param cErro, characters, Mensagem de erro dizendo que não foi possivel realizar a busca da chave
@param aCampos, array, array contendo os campos para realizar a busca da chave
@param nIndice, numeric, numero do indice a ser realizada a busca
@return xRet: Array ou String contendo o código interno 
@type function
/*/
Function GTPxRetId(cMarca, cAlias, cCampo, cExtID, cIntID, nOrdem,lOk,cErro,aCampos,nIndice)
Local	xRet	:= nil
Local	aIntId	:= nil
Local	cSeek	:= ""
Local	n1		:= 0
Local	aArea	:= GetArea()
Default	cMarca	:= "PROTHEUS"
Default	cAlias	:= Alias()
Default	nOrdem	:= 0
Default	nIndice	:= 0
cErro := ""
lOk := .T.
cIntID := AllTrim(CFGA070INT(cMarca, cAlias, cCampo, cExtID))
If !Empty(cIntID)
	aIntId := Separa(cIntID, '|' )
	lOk := .T.
	If ValType(aCampos) == "A" .and. Len(aCampos) > 0 .and. nIndice > 0
		For n1 := 1 to Len(aCampos)
			//Pula registro de Empresa e verifica apartir da filial 
			If ValType(aCampos[n1]) == "A"
				cSeek += Padr(aCampos[n1][2],TamSx3(aCampos[n1][1] ) [1] )
			Elseif '_FILIAL' $ aCampos[n1] 
				If Padr(aIntId[n1+1],TamSx3(aCampos[n1] ) [1] ) <> xFilial(cAlias)
					lOk := .F.
					cErro := 'Filial: '+aIntId[n1+1]+" Não pertence ao grupo de empresa logada na integração ("+cAlias+":"+RTrim(xFilial(cAlias))+"), favor enviar o registro para o grupo correto"
					Exit
				Else
					cSeek += Padr(aIntId[n1+1],TamSx3(aCampos[n1] ) [1] )
				Endif 
			Else
				cSeek += Padr(aIntId[n1+1],TamSx3(aCampos[n1] ) [1] )
			Endif
		Next
		(cAlias)->(DbSetOrder(nIndice))
		If lOk .and. !(cAlias)->(DbSeek(cSeek))
			lOk := .F.
			cErro := Alltrim(GTPSx2Name( cAlias ))+': '+cExtID + STR0008//' não encontrado, compare os dados de dê/para com o registro do protheus'
		Endif
	Endif
	If lOk
		If nOrdem > 0
			xRet := Alltrim(aIntId[nOrdem])
		Else
			xRet := aClone(aIntId)
		EndIf
	Else
		xRet := If(nOrdem > 0,'',{})
	Endif
	aSize(aIntId,0)
	aIntId := Nil
Else
	lOk		:= .F.
	cErro	:= Alltrim(GTPSx2Name( cAlias ))+': '+cExtID + STR0007// ' Não encontrado no Dê/Para'
	xRet := If(nOrdem > 0,'',{})
Endif
RestArea(aArea)
GTPDestroy(aArea) //Destroy variavel

Return xRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPSx2Name
// GTPSx2Name - Busca o nome da tabela
@author jacomo.fernandes
@Sample GTPSx2Name("ZA1")
@since 15/02/2017
@version 12.1.7
@param cAlias, characters, Tabela a ser posicionada 
@return cRet: Nome da tabela conforme o SX2
@type function
/*/
Function GTPSx2Name( cAlias )
Local cRet as char
Local aArea as array
aArea := GetArea()
If SX2->( DbSeek( cAlias ) )
	cRet := Capital( X2Nome() )
EndIf
RestArea(aArea)
GTPDestroy(aArea)
Return cRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPDestroy
// GTPDestroy- Destroi uma variavel, liberando da memoria
@author jacomo.fernandes
@Sample GTPDestroy(aArray)
@Sample GTPDestroy(oObj)
@since 15/02/2017
@version 12.1.7
@param xObj, , variavel a ser destruida
@type function
/*/
Function GTPDestroy(xObj)

Local cType := ValType(xObj)
Default xObj := nil
If cType == "O"
	FreeObj(xObj)
	xObj := nil
	DelClassIntf()
ElseIf cType == "A"
	aSize(xObj,0)
	xObj := Nil
Else
	xObj := nil
Endif
Return()
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GxSetNode
// GxSetNode - Função utiliza para montar uma Tag conforme regra
@author jacomo.fernandes
@Sample GxSetNode("InternalId","EMP|FIL|COD01",.T.,.T.)
@since 15/02/2017
@version 12.1.7
@param cNode, characters, Tag a ser criada
@param cValue, characters, valor a ser inputado na tag
@param lForce, logical, Se força a criação da tag mesmo que o cValue esteja vazio
@param lNoTags, logical, Se aplica ou não a Função _NoTags()
@type function
/*/
Function GxSetNode(cNode,cValue,lForce,lNoTags)
Local cRet := ""
Default cValue := ""
Default lForce := .F.
Default lNoTags:= .T.
cValue	:= RTrim(AllToChar(cValue))
If !Empty(cValue) 
	cRet := '<'+Alltrim(cNode)+'>' + If(lNoTags,_NoTags(cValue),cValue  ) +'</'+Alltrim(cNode)+'>'
ElseIf lForce
   cRet := '<'+Alltrim(cNode)+'/>' 
Endif

Return cRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GxDtStamp
// GxDtStamp - Função utilizada para converter uma data conforme o FwTimeStamp
@author jacomo.fernandes
@Sample GxDtStam("15/02/2017",.T.,.T.)
@Sample GxDtStam("2017-02-15",.F.,.T.)
@since 15/02/2017
@version 12.1.7
@param xInfo, , Valor a ser convertido, podendo ser uma Data ou uma String
@param lTipo, logical, Se .T. utiliza a funcionalidade do FwTimeStamp, Se .F. converte o Formato FwTimeStamp para Data
@param lOnlyDate, logical, Informa se irá utilizar somente a Data ou o formato completo "aaaa-mm-ddThh:mm:ss-FH:FH"
@Retorno xRet,, Retorna uma data conforme regra 
@type function
/*/
Function GxDtStamp(xInfo, lTipo, lOnlyDate)

Local xRet  := ""
Local nType := 3
Local cTime := Time()
Default xInfo     := Date()
Default lTipo     := .T.
Default lOnlyDate := .T.


If !Empty(xInfo)
	//lTipo = .T. -> Funcionalidade normal do TimeStampo. Retorno no formato "AAAA-MM-DDt00:00:00-03:00"
	If lTipo
	   If ValType(xInfo) == "C"
	       xInfo := cToD(xInfo)
	   EndIf
	   xRet := FWTimeStamp( nType, xInfo, cTime )
	   If lOnlyDate // Tratamento para retornar somente "AAAA-MM-DD"
	      xRet := SubStr(xRet , 1, At("T", xRet)-1 )
	   EndIf
	//Tipo = .F. -> Inverte o formato de TimeStamp para data Normal. Retorna uma data   
	Else
	   //Pegando a data:
	   If At("T", xInfo) > 0
	      xInfo := SubStr(xInfo , 1, At("T", xInfo)-1 ) //"2011-12-20T00:00:00-03:00" -> "2011-12-20"
	   EndIf
	   //Retirando os '-':
	   xInfo := StrTransf(xInfo,"-","") //"2011-12-20" -> "20111220"
	   //Formatando a data
	   xRet := SToD(xInfo) //"20111220" -> "20/12/2011"
	EndIf
Else
	xRet := If(!lTipo,SToD(xInfo),"")
EndIf

Return xRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPxRetVal
// GTPxRetVal - Função utilizada para retornar o valor conforme o tipo do campo
@author jacomo.fernandes
@Sample GTPxRetVal("2017-02-15","ZA1_DATA")
@since 15/02/2017
@version 12.1.7
@param xVal, , Valor a ser convertido
@param cCampo, characters, campo a ser comparado na conversão
@type function
/*/
Function GTPxRetVal(xVal,cCampo)
Local xRet  := nil
Local cType := FWSX3Util():GetFieldType(cCampo)

If !Empty(cType)
    If cType == 'C'
        If !("_MSBLQL" $ cCampo)
            xRet := Padr(Alltrim( AllToChar(xVal) ),TamSx3(cCampo)[1]  )	
        Else
            xRet := GTPXLogic(Alltrim(xVal), TP_CHAR1_RET)
        Endif
	ElseIf cType == 'D'
		xRet := GxDtStamp(Alltrim(xVal),.F.)
	ElseIf cType == 'N'
		xRet := Val(Alltrim(xVal))
	ElseIf cType == 'L'
		xRet := GTPXLogic(Alltrim(xVal), TP_LOGIC_RET) 
	ElseIf cType == 'M'
		xRet := Alltrim( xVal )	
	ENDIF
Endif
Return xRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPXLogic
// GTPXLogic - Função utilizada para retornar um valor logico conforme a regra passada no nTypeRet
@author jacomo.fernandes
@Sample GTPxLogic("SIM",TP_LOGIC_RET)
@since 15/02/2017
@version 12.1.7
@param xValue, , Valor a ser convertido conforme a regra passado pelo nTypeRet
@param nTypeRet, numeric, numero passado para informar qual tipo de conversão
@type function
/*/
Function GTPXLogic(xValue, nTypeRet)
Local xRet

If ValType(xValue) == "C"
	If upper(xValue) == "SIM" .Or. xValue == "1" .Or. upper(xValue) == "TRUE" .Or. upper(xValue) == "VERDADEIRO" .or.  xValue == "T" 
		if nTypeRet == TP_LOGIC_RET
			xRet := .T.
		ElseIf nTypeRet == TP_CHAR1_RET
			xRet := "1"
		ElseIf nTypeRet == TP_CHAR2_RET
			xRet := "SIM"
		ElseIf nTypeRet == TP_CHAR3_RET
			xRet := "TRUE"
		ElseIf nTypeRet == TP_CHAR4_RET
			xRet := "VERDADEIRO"
		Else
			xRet := 1
		Endif
	Else
		if nTypeRet == TP_LOGIC_RET
			xRet := .F.
		ElseIf nTypeRet == TP_CHAR1_RET
			xRet := "2"
		ElseIf nTypeRet == TP_CHAR2_RET
			xRet := "NÃO"
		ElseIf nTypeRet == TP_CHAR3_RET
			xRet := "FALSE"
		ElseIf nTypeRet == TP_CHAR4_RET
			xRet := "FALSO"
		Else
			xRet := 2
		Endif
	Endif
	
ElseIf ValType(xValue) == "L"
	IF xValue
		if nTypeRet == TP_LOGIC_RET
			xRet := .T.
		ElseIf nTypeRet == TP_CHAR1_RET
			xRet := "1"
		ElseIf nTypeRet == TP_CHAR2_RET
			xRet := "SIM"
		ElseIf nTypeRet == TP_CHAR3_RET
			xRet := "TRUE"
		ElseIf nTypeRet == TP_CHAR4_RET
			xRet := "VERDADEIRO"
		Else
			xRet := 1
		Endif
	Else
		if nTypeRet == TP_LOGIC_RET
			xRet := .F.
		ElseIf nTypeRet == TP_CHAR1_RET
			xRet := "2"
		ElseIf nTypeRet == TP_CHAR2_RET
			xRet := "NÃO"
		ElseIf nTypeRet == TP_CHAR3_RET
			xRet := "FALSE"
		ElseIf nTypeRet == TP_CHAR4_RET
			xRet := "FALSO"
		Else
			xRet := 2
		Endif
	Endif

ElseIf ValType(xValue) == "N"
	IF xValue == 1 
		if nTypeRet == TP_LOGIC_RET
			xRet := .T.
		ElseIf nTypeRet == TP_CHAR1_RET
			xRet := "1"
		ElseIf nTypeRet == TP_CHAR2_RET
			xRet := "SIM"
		ElseIf nTypeRet == TP_CHAR3_RET
			xRet := "TRUE"
		ElseIf nTypeRet == TP_CHAR4_RET
			xRet := "VERDADEIRO"
		Else
			xRet := 1
		Endif
	Else
		if nTypeRet == TP_LOGIC_RET
			xRet := .F.
		ElseIf nTypeRet == TP_CHAR1_RET
			xRet := "2"
		ElseIf nTypeRet == TP_CHAR2_RET
			xRet := "NÃO"
		ElseIf nTypeRet == TP_CHAR3_RET
			xRet := "FALSE"
		ElseIf nTypeRet == TP_CHAR4_RET
			xRet := "FALSO"
		Else
			xRet := 2
		Endif
	Endif
Endif

Return xRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GxResponse
// GxResponse - Função utilizada para ler a mensagem de Response da integração e fazer sua devida gravação de De/Para
@author jacomo.fernandes
@since 15/02/2017
@version 12.1.7
@param oXml, object, Objeto contendo o XML utilizado no Adapter
@param aMsgUnic, array, Array bidimencional contendo o Nome da Lista de IntId, Alias, Campo
@type function
/*/
Function GxResponse(oXml,aMsgUnic)
Local cMarca	:= oXml:xPathGetAtt('/TOTVSMessage/MessageInformation/Product','name')
Local cListId	:= "/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId"
Local cName		:= ""
Local cIntID	:= ""
Local cExtID	:= ""
Local nX		:= 0
Local nPos		:= 0
Local nName		:= 1
Local nAlias	:= 2
Local nCampo	:= 3
For nX := 1 to oXml:xPathChildCount(cListId)
	cName	:= Upper(oXml:xPathGetNodeValue(cListId+"/InternalId["+cValToChar(nX)+"]/Name"))
	cIntID 	:= oXml:xPathGetNodeValue(cListId+"/InternalId["+cValToChar(nX)+"]/Origin")
	cExtID	:= oXml:xPathGetNodeValue(cListId+"/InternalId["+cValToChar(nX)+"]/Destination")
	If !Empty(cIntID) .and. !Empty(cExtID)
		If (nPos := aScan(aMsgUnic,{|x| Upper(Alltrim(x[nName])) == AllTrim(cName) } ) ) > 0
			CFGA070MNT( cMarca, aMsgUnic[nPos][nAlias], aMsgUnic[nPos][nCampo], cExtID, cIntID)
		Endif
	Endif
Next

Return
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GxListOfId
// GxListOfId - Função utilizada para montar a lista de InternalId como retorno do recebimento
@author jacomo.fernandes
@since 15/02/2017
@version 12.1.7
@param aIntId, array, Array Bidimencional contendo o Nome da Integração, cExtID,cIntID,cMarca,cAlias,cCampo
@param lDelete, logical, Informa se é uma Operação de Delete
@return cRet, characters, xml de retorno contendo a Lista de InternalId
@type function
/*/
Function GxListOfId(aIntId,lDelete,lGrava)
Local cRet			:= ""
Local cXmlLstId	:= ""
Local cXmlIntId	:= ""
Local n1			:= 0
Default lGrava	:= .T.
/*
aIntID[n1][1] --> Name
aIntID[n1][2] --> cExtId
aIntID[n1][3] --> cIntId
aIntID[n1][4] --> cMarca
aIntID[n1][5] --> cAlias
aIntID[n1][6] --> cCampo
*/
For n1 := 1 to Len(aIntId)
	If !lDelete
		cXmlIntId := GxSetNode("Name",aIntID[n1][1])
		cXmlIntId += GxSetNode("Origin",aIntID[n1][2])
		cXmlIntId += GxSetNode("Destination",aIntID[n1][3])
		cXmlLstId += GxSetNode("InternalId",cXmlIntId,.T.,.F.)
	Endif
//	CFGA070MNT(cMarca,cAlias,cCampo,cExtID,cIntID,lDelete)
	If lGrava
		CFGA070MNT(aIntID[n1][4], aIntID[n1][5], aIntID[n1][6], aIntID[n1][2], aIntID[n1][3],lDelete)
	Endif
Next
If !lDelete
	cRet :=  GxSetNode("ListOfInternalId",cXmlLstId,.T.,.F.)
Endif
Return cRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GxGetNdXml
// GxGetNdXml - Função utilizada para Buscar o valor da Tag e preencher o Valor do Campo
@author jacomo.fernandes
@since 15/02/2017
@version 12.1.7
@param oModel, object, Objeto do Modelo a ser preenchido o Valor
@param oXml, object, Objeto contendo o Xml da integração
@param cCampo, characters, Campo a ser preenchido
@param xVal, , Valor a ser preenchido
@param cNode, characters, nome da Tag que ira ser buscada
@return lRet, logical, variavel que informará o sucesso da função
@type function
/*/
Function GxGetNdXml(oModel,oXml,cCampo,xVal,cNode,lForce )
Local lRet		:= .T.
Default xVal	:= nil 
Default lForce	:= .F.
If oXml:XPathHasNode( cNode ) .Or. lForce
	If Valtype(xVal) == 'U'
		xVal := GTPxRetVal(oXml:XPathGetNodeValue(cNode),cCampo)
	Endif
	lRet	:= GTPxSetVal(oModel,cCampo,xVal) 
Endif

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPxSetVal
// GTPxSetVal - Função utilizada para setar o valor do campo validando alterações
@author jacomo.fernandes
@since 15/02/2017
@version 12.1.7
@param oModel, object, Objeto do Modelo a ser preenchido o Valor
@param cCampo, characters, Campo a ser preenchido
@param xValue, , Valor a ser preenchido
@return lRet, logical, variavel que informará o sucesso da função
@type function
/*/
Function GTPxSetVal(oModel,cCampo,xValue)
Local lRet := .T.
If oModel:GetValue(cCampo) <> xValue 
	lRet := oModel:SetValue(cCampo,xValue)
Endif

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPxExcInt 
// GTPxExcInt - Função utilizada para Buscar o codigo externo referente a integração
@author GTP
@since 04/08/2020
@version 12.1.30
@param cAliasINT, characters, Alias de referencia
@param cCampo, characters, Campo de referencia
@param cCodigo, characters, Codigo de referencia
@return cRet, characters, codigo de referencia externa
@type function
/*/
Function GTPxExcInt(cAliasINT, cCampo, cCodigo)
Local cRet       := ''
Local cRefer     := GTPGetRules('XXFREFER',,,"TotalBus")
Local lRefer     := GTPGetRules('VALREFER',,,.T.)
Local cChavePesq := cEmpAnt + '|' + RTrim(FWxFilial(cAliasINT)) + '|' + RTrim(cCodigo)

If lRefer
	cRet := CFGA070Ext( cRefer, cAliasINT, cCampo, cChavePesq )
EndIf

Return cRet
