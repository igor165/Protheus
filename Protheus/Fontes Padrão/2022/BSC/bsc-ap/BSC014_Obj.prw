// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC014_Obj.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC014_Obj.ch"

/*--------------------------------------------------------------------------------------
@entity Objetivo
Objetivo no BSC. Contém as Indicadores, iniciativas e FCS (Fator Critico de Sucesso).
@table BSC014
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "OBJETIVO"
#define TAG_GROUP  "OBJETIVOS"
#define TEXT_ENTITY STR0001/*//"Objetivo"*/
#define TEXT_GROUP  STR0002/*//"Objetivos"*/

class TBSC014 from TBITable
	method New() constructor
	method NewBSC014()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID, lFeedBack)
	method oToXMLContextList(nContextID)

	// registro atual
	method oToXMLNode(nParentID, cLoadCmd)
	method oToXMLMapNode(aPessoas)
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)
	method oMakeCard(dDataAlvo, lParcelada)
	method oXMLCard()
	method nFeedBack()

	method nDuplicate(nParentID, nNewParentID, nNewContextID, aObjIDs, aIndIds)

endclass
	
method New() class TBSC014
	::NewBSC014()
return
method NewBSC014() class TBSC014
	local oField
	
	// Table
	::NewTable("BSC014")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(oField := TBIField():New("NOME",		"C",	60))
	oField:lSensitive(.f.)
	::addField(TBIField():New("RESPID",		"N"))
	::addField(TBIField():New("TIPOPESSOA",	"C",	1)) //G = Grupo, P = Individual
	::addField(TBIField():New("DESCRICAO",	"C",	255))
	::addField(TBIField():New("ORIGEM"	,	"C",	30))	
	// Posicao no mapa estrategico
	::addField(TBIField():New("MAPWIDTH",	"N"))
	::addField(TBIField():New("MAPHEIGHT",	"N"))
	::addField(TBIField():New("MAPCOLOR",	"N"))
	::addField(TBIField():New("MAPTYPE",	"N"))
	//Posicao no Mapa estrategico modelo 2
	::addField(TBIField():New("MP2WIDTH"	,"N"))
	::addField(TBIField():New("MP2HEIGHT"	,"N"))
	::addField(TBIField():New("MP2X"		,"N"))
	::addField(TBIField():New("MP2Y"		,"N"))
	::addField(TBIField():New("MP2FONTE"	,"C",30))//Fonte do titulo
	::addField(TBIField():New("MP2FONTAM"	,"N"))//Tamanho da fonte
	::addField(TBIField():New("MP2FONEST"	,"N"))//Estilo da fonte
	::addField(TBIField():New("MP2FONCOR"	,"N"))//Cor da fonte
	
	oField := TBIField():New("MAPX",	"N")
	oField:bDefault({|| -1})
	::addField(oField)
	// Posicao no mapa estrategico
	oField := TBIField():New("MAPY",	"N")
	oField:bDefault({|| -1})
	::addField(oField)

	// Indexes
	::addIndex(TBIIndex():New("BSC014I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC014I02",	{"NOME", "CONTEXTID"},	.t.))
	::addIndex(TBIIndex():New("BSC014I03",	{"PARENTID", "ID"},	.t.))
	::addIndex(TBIIndex():New("BSC014I04",	{"PARENTID", "NOME"},	.f.))

return

// nFeedBack
method nFeedBack() class TBSC014
return ::oMakeCard():fnFeedBack

// Arvore
method oArvore(nParentID) class TBSC014
	local oXMLArvore, oNode, oChild
	
	::SetOrder(2) // Por ordem de nome
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	if(!::lEof())
		// Tag conjunto
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", 1)
		oAttrib:lSet("TIPO", TAG_GROUP)
		oAttrib:lSet("NOME", TEXT_GROUP)
		oXMLArvore := TBIXMLNode():New(TAG_GROUP,"",oAttrib)
        // Nodes
		while(!::lEof())
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", ::nValue("ID"))
			oAttrib:lSet("NOME", alltrim(::cValue("NOME")))/*//"Nome"*/
			oAttrib:lSet("FEEDBACK", 0)
			oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
			oChild := ::oOwner():oGetTable("INDICADOR"):oArvore(::nValue("ID"))
			if(valtype(oChild) == "O")
				oNode:oAddChild(oChild) // Children (Indicadores)
			endif	
			oChild := ::oOwner():oGetTable("INICIATIVA"):oArvore(::nValue("ID"))
			if(valtype(oChild) == "O")
				oNode:oAddChild(oChild) // Children (Iniciativas)
			endif
			oChild := ::oOwner():oGetTable("FCS"):oArvore(::nValue("ID"))
			if(valtype(oChild) == "O")
				oNode:oAddChild(oChild) // Children (FCS - fator critico de sucesso)
			endif
			::_Next()
		enddo
	endif
	::cSQLFilter("") // Encerra filtro
return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList(nParentID, lFeedBack) class TBSC014
	local oNode, oAttrib, oXMLNode, nind
	default lFeedBack := .f.
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", BSC_STRING)
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(2) // Por ordem de nome
	if nBiVal(nParentID) > 0
		::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
		::lFiltered(.t.)
	endif
	::_First()
	while(!::lEof())
		// Nao lista o ID 0, de inclusao
		if(::nValue("ID")==0)
			::_Next()
			loop
		endif			
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","DESCRICAO"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		// Virtuals
		oNode:oAddChild(TBIXMLNode():New("FEEDBACK", if(lFeedBack,::nFeedBack(),0)))
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Lista XML para anexar ao Contexto
method oToXMLContextList(nContextID) class TBSC014
	local oNode, oAttrib, oXMLNode, nind
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", BSC_STRING)
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(2) // Por ordem de nome
	::cSQLFilter("CONTEXTID = "+cBIStr(nContextID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID", "CONTEXTID","DESCRICAO"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		// Virtuals
		oNode:oAddChild(TBIXMLNode():New("FEEDBACK", ::nFeedBack()))
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode(nParentID, cLoadCMD) class TBSC014
	local nID, aFields, nInd, cTipoPessoa, nRespID
	local oXMLNode,oTable
	
	if(!empty(cLoadCMD) .and. cLoadCMD == 'CARD')
		oXMLNode := ::oXMLCard()
	else
		//Recebe a lista com os usuarios

		oXMLNode := TBIXMLNode():New(TAG_ENTITY)
		// Acrescenta os valores ao XML
		aFields := ::xRecord(RF_ARRAY)
		for nInd := 1 to len(aFields)
			oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			if(aFields[nInd][1] == "ID")
				nID := aFields[nInd][2]
			elseif(aFields[nInd][1] == "RESPID")
				nRespId := aFields[nInd][2]
			elseif(aFields[nInd][1] == "TIPOPESSOA")
				cTipoPessoa := aFields[nInd][2]
			endif
		next         
		// Virtuais
		if(cTipoPessoa=="G")
			oTable := ::oOwner():oGetTable("PGRUPO")
		else
			oTable := ::oOwner():oGetTable("PESSOA")
		endif
		oTable:lSeek(1, {nRespId})    
		
		oXMLNode:oAddChild(TBIXMLNode():New("RESPONSAVEL", oTable:cValue("NOME")))

		//oXMLNode:oAddChild(TBIXMLNode():New("FEEDBACK", ::nFeedBack()))
	
		// Acrescenta children
		oXMLNode:oAddChild(::oOwner():oGetTable("INDICADOR"):oToXMLList(nID))
		oXMLNode:oAddChild(::oOwner():oGetTable("INICIATIVA"):oToXMLList(nID))
		oXMLNode:oAddChild(::oOwner():oGetTable("FCS"):oToXMLList(nID))
		oXMLNode:oAddChild(TBIXMLNode():New("ADMINISTRADOR",if(lAdmin := self:oOwner():foSecurity:oLoggedUser():lValue("ADMIN"),"T","F")))
		oXMLNode:oAddChild(::oOwner():oContext(self, nParentID))
	endif

return oXMLNode

// Carregar o no para o mapa estrategico.
method oToXMLMapNode(aPessoas) class TBSC014
	local nID, aFields, nInd, cTipoPessoa, nRespID
	local oXMLNode,oTable
	
	oXMLNode := TBIXMLNode():New(TAG_ENTITY)
	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		elseif(aFields[nInd][1] == "RESPID")
			nRespId := aFields[nInd][2]
		elseif(aFields[nInd][1] == "TIPOPESSOA")
			cTipoPessoa := aFields[nInd][2]
		endif
	next         

	// Virtuais
	if(cTipoPessoa=="G")
		oTable := ::oOwner():oGetTable("PGRUPO")
	else
		oTable := ::oOwner():oGetTable("PESSOA")
	endif
	oTable:lSeek(1, {nRespId})

	oXMLNode:oAddChild(TBIXMLNode():New("RESPONSAVEL", oTable:cValue("NOME")))
	oXMLNode:oAddChild(TBIXMLNode():New("FEEDBACK", ::nFeedBack()))

	// Acrescenta children
	oXMLNode:oAddChild(::oOwner():oGetTable("INDICADOR"):oToXMLList(nID))
	oXMLNode:oAddChild(::oOwner():oGetTable("INICIATIVA"):oToXMLList(nID))
	oXMLNode:oAddChild(::oOwner():oGetTable("FCS"):oToXMLList(nID))
	
	if ascan(aPessoas,::nValue("RESPID")) > 0 
		nUserOwner := 1	
	else
		nUserOwner := 0	
	endif

	//Usuado na area de trabalho.
	oXMLNode:oAddChild(TBIXMLNode():New("USEROWNER", nUserOwner))

return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC014
	local aFields, nInd, nStatus := BSC_ST_OK
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID", "MAPX", "MAPY","MAPWIDTH","MAPHEIGHT","MAPCOLOR","MAPTYPE"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
	next
	aAdd( aFields, {"ID", ::nMakeID()} )
	
	// Grava
	if(!::lAppend(aFields))
		if(::nLastError()==DBERROR_UNIQUE)
			nStatus := BSC_ST_UNIQUE
		else
			nStatus := BSC_ST_INUSE
		endif
	endif	
return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TBSC014
	local nStatus := BSC_ST_OK,	nID, nInd
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY)

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif	
	next

	// Verifica condições de gravação (append ou update)
	if(!::lSeek(1, {nID}))
		nStatus := BSC_ST_BADID
	else
		if(!::lUpdate(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
		endif	
	endif
return nStatus

// Excluir entidade do server
method nDelFromXML(nID) class TBSC014
	local nStatus := BSC_ST_OK, oTableChild
	
	::oOwner():oOltpController():lBeginTransaction()

	// Procura por children (Indicadores)
	oTableChild:= ::oOwner():oGetTable("INDICADOR")
	oTableChild:SetOrder(3) // Por ordem de ParentId
	oTableChild:cSQLFilter("PARENTID = "+cBIStr(nID)) // Filtra pelo paI
	oTableChild:lFiltered(.t.)
	oTableChild:_First()
	while(!oTableChild:lEof() .and. nStatus == BSC_ST_OK)
		nStatus := ::oOwner():oGetTable("INDICADOR"):nDelFromXML(oTableChild:nValue("ID"))
		oTableChild:_Next()
	enddo
	oTableChild:cSQLFilter("") // Limpa o filtro

	// Procura por children (Iniciativas)
	oTableChild:= ::oOwner():oGetTable("INICIATIVA")
	oTableChild:SetOrder(3) // Por ordem de ParentId
	oTableChild:cSQLFilter("PARENTID = "+cBIStr(nID)) // Filtra pelo paI
	oTableChild:lFiltered(.t.)
	oTableChild:_First()
	while(!oTableChild:lEof() .and. nStatus == BSC_ST_OK)
		nStatus := ::oOwner():oGetTable("INICIATIVA"):nDelFromXML(oTableChild:nValue("ID"))
		oTableChild:_Next()
	enddo
	oTableChild:cSQLFilter("") // Limpa o filtro

	// Procura por children (FCS = Fator Critico de Sucesso)
	oTableChild:= ::oOwner():oGetTable("FCS")
	oTableChild:SetOrder(3) // Por ordem de ParentId
	oTableChild:cSQLFilter("PARENTID = "+cBIStr(nID)) // Filtra pelo paI
	oTableChild:lFiltered(.t.)
	oTableChild:_First()
	while(!oTableChild:lEof() .and. nStatus == BSC_ST_OK)
		nStatus := ::oOwner():oGetTable("FCS"):nDelFromXML(oTableChild:nValue("ID"))
		oTableChild:_Next()
	enddo
	oTableChild:cSQLFilter("") // Limpa o filtro

	// Deleta o elemento
	if(nStatus == BSC_ST_OK)
		if(::lSeek(1, {nID}))
			if(!::lDelete())
				nStatus := BSC_ST_INUSE
			endif
		else
			nStatus := BSC_ST_BADID
		endif
    endif

	if(nStatus != BSC_ST_OK)
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()
return nStatus

// Duplica os registros filhos de nParentID, colocando-os como filhos de nNewParentID do contexto nNewContextID
// aObjIDs é recebido por referencia para armazenar os ids de todos os objetivos, recursivamente
method nDuplicate(nParentID, nNewParentID, nNewContextID, aObjIDs, aIndIds) class TBSC014
	local nStatus := BSC_ST_OK, aFields, nOldID, nID
	
	::oOwner():oOltpController():lBeginTransaction()

	::SetOrder(1) // Por ordem de id
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof() .and. nStatus == BSC_ST_OK)
		nOldID := ::nValue("ID")
		// Copia temporario
		aFields := ::xRecord(RF_ARRAY, {"ID", "PARENTID", "CONTEXTID"})
		aAdd( aFields, {"ID",  nID := ::nMakeID()} )
		aAdd( aFields, {"PARENTID", nNewParentID} )
		aAdd( aFields, {"CONTEXTID", nNewContextID} )

		// Grava
		::savePos()
		if(!::lAppend(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
			exit
		else
			// Mapa Estratégico
			aAdd( aObjIDs, {nOldID, nID})
			
			// Children
			::restPos()
			nStatus := ::oOwner():oGetTable("INDICADOR"):nDuplicate(nOldID, nID, nNewContextID, @aIndIds)
			if(nStatus == BSC_ST_OK)
				nStatus := ::oOwner():oGetTable("INICIATIVA"):nDuplicate(nOldID, nID, nNewContextID)
			else
				exit				
			endif
			if(nStatus == BSC_ST_OK)
				nStatus := ::oOwner():oGetTable("FCS"):nDuplicate(nOldID, nID, nNewContextID)
			else
				exit				
			endif
		endif

		::_Next()
	enddo
	::cSQLFilter("") // Zera filtro

	if(nStatus != BSC_ST_OK)
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()

return nStatus

// oMakeCard(dDataAlvo, lParcelada)
// Retorna um objeto TBSCScoreCard preenchido
// @param dDataAlvo - Data na qual o BSC se baseia para analisar os dados e gerar snapshot
method oMakeCard(dDataAlvo, lParcelada) class TBSC014
	local nFeedback 	:= 0
	local nInd 			:= 0
	local nPeso			:= 0
	local nValor 		:= 0
	local nMeta  		:= 0
	local nPesoTotal	:= 0 
	local nPercent 		:= 0
	local nPercentTotal := 0
	
	local oIndicador	:= ::oOwner():oGetTable("INDICADOR")
	local oIndCard 
	local oCard 		:= TBSCScoreCard():New()  
	
	local aIndCards 	:= {}
	local aPosicao		:= {}
	
	local lVerCores 	:= ::oOwner():foSecurity:lHasParentAccess("OBJETIVO", ::nValue("ID"), "NUMEROS")
	local lVerNumeros 	:= ::oOwner():foSecurity:lHasParentAccess("OBJETIVO", ::nValue("ID"), "CORES")
	local lSuperaObj	:= .T. 
	    
	//Guarda o posicionamento da tabela de indicadores.
	aPosicao 	:= oIndicador:SavePos()
    
    //Localiza os indicadores que pertencem ao objetivo.     
	oIndicador:lSeek(6, {::cValue("ID")})

	//Itera por todos os indicadores do objetivo.
	While(!oIndicador:lEof() .And. ( oIndicador:cValue("PARENTID") == ::cValue("ID") ) .And. ( Vazio(oIndicador:cValue("TIPOIND")) ) )
        
		//Recupera o card do indicador.
		oIndCard := oIndicador:oMakeCard(dDataAlvo, lParcelada) 
		
		If( oIndCard:fnFeedBack != BSC_FB_GRAY )
		    
		    //Atribui o objeto do indicador a um array para uso posterior.
		    aAdd(aIndCards, oIndCard)
			
			If(oIndCard:fnFeedback == BSC_FB_REDDN .or. oIndCard:fnFeedback == BSC_FB_YELLOWDN .or. oIndCard:fnFeedback == BSC_FB_GREENDN .or. oIndCard:fnFeedback == BSC_FB_BLUEDN)
				nFeedback -= 1 * oIndicador:nValue("PESO")
			ElseIf(oIndCard:fnFeedback == BSC_FB_REDUP .or. oIndCard:fnFeedback == BSC_FB_YELLOWUP .or. oIndCard:fnFeedback == BSC_FB_GREENUP .or. oIndCard:fnFeedback == BSC_FB_BLUEUP) 
				nFeedback += 1 * oIndicador:nValue("PESO")
			EndIf 
			       
			//Identifica se todos os indicadores atingiram a meta.
			If (nBIVal(oIndCard:fnAtual) <= nBIVal(oIndCard:fnRealVerde))
			   lSuperaObj := .F.
			EndIf

		EndIf 

		oIndicador:_Next()
	End 

	
	//Restaura o posicionamento da tabela de indicadores. 
	oIndicador:RestPos(aPosicao)

	//Inicia a montagem do card do objetivo.
	oCard:fcNome 		:= ::cValue("NOME") 	
	oCard:fcEntity 		:= TAG_ENTITY 	
	oCard:fnEntID 		:= ::nValue("ID")	
	oCard:fnPercMeta 	:= 0  	
	oCard:fnIndicador 	:= 0

	//Verifica se existem indicadores valorados.
	If( Len(aIndCards) > 0)

		//Itera por todos os indicadores.
		For nInd := 1 To Len(aIndCards)
			
			//Recupera o objeto de cada indicador do objetivo.
			oIndCard := aIndCards[nInd]      
            
			//Recupera os valores utilizados no cálculo.
			nValor		:= nBIVal(oIndCard:fnAtual)
			nMeta 		:= nBIVal(oIndCard:fnRealVerde) 
			nPeso 		:= nBIVal(oIndCard:fnPeso)
                 
           //---------------------------------------------------------------
			// Calcula o percentual de cada indicadicador. 
			// Verifica o tipo de indicador (Se é Ascendente ou Descendente)
			//---------------------------------------------------------------
          If ( oIndCard:flAscendente )
          		//---------------------------------------------------------------                  
	         	// Fórmula: ((Valor * 100) / Meta) * Peso
				//---------------------------------------------------------------
	   			If !( nMeta == 0 )
	   				nPercent 	:=  (( nValor * 100) / nMeta ) * nPeso
	   			Else
	   				//---------------------------------------------------------------
	   				// Fórmula: ((Valor + 1) * 100 ) * Peso  (Não existe divisão por zero)
	   				//---------------------------------------------------------------
	   				nPercent 	:=  ((nValor + 1) * 100) * nPeso 
	   			EndIf 
	   		Else
	   			//---------------------------------------------------------------
	   			// Para Indicadores Descendentes são feitas três fórmulas:
	   			// 1 - Quando o valor for maior do que a meta: ( ( ( ( Valor * 100 ) / Meta) * Peso) - 100 ) * -1
	   			// 2 - Quando o valor for menor/igual a meta: ( 100 - ( ( Valor * 100 ) / Meta ) )  + 100
	   			//---------------------------------------------------------------
	   			If ( nValor > nMeta )
		   			If !( nMeta == 0 )
		   				nPercent 	:=  ( ((( nValor * 100) / nMeta ) * nPeso ) - 100 ) * -1
		   			Else
		   				nPercent 	:=  ( (((nValor + 1) * 100) * nPeso ) - 100 ) * -1 
		   			EndIf  				
   				Else
		   			If !( nMeta == 0 )
		   				nPercent	:= ( 100 - ( ( nValor * 100 ) / nMeta ) )  + 100
		   			Else 
		   				nPercent 	:=  (((nValor + 1) * 100) * nPeso )
		   			EndIf  
   				EndIf
	   		EndIf

            //Acumula o peso de todos os indicadores.
   			nPesoTotal 	+= 	nPeso
            
			//Acumula o percentual de todos os indicadores.
   			nPercentTotal 	+=	nPercent
   		Next  

		oCard:fnPercMeta 	:= iif(!lVerNumeros, 0, Int( nPercentTotal / nPesoTotal) )
		oCard:fcPercMeta 	:= cBIStr(oCard:fnPercMeta) + "%"

		oCard:fnIndicador 	:= Int(oCard:fnPercMeta * 0.66)
		oCard:fnIndicador 	:= iif(oCard:fnIndicador < 0, 0, oCard:fnIndicador)
		oCard:fnIndicador 	:= iif(oCard:fnIndicador > 100, 100, oCard:fnIndicador)  
		
		oCard:fcUnidade   	:= "%"		
		oCard:fnInicial   	:= 0		
		oCard:fnFinal     	:= iif(!lVerNumeros, 0, iif(oCard:fnPercMeta <= 150, 150, oCard:fnPercMeta))		
		oCard:fnAtual     	:= iif(!lVerNumeros, 0, oCard:fnPercMeta)		
		oCard:fnAnterior 	:= 0	    

		oCard:fnVermelho 	:= 33
		oCard:fnAmarelo 	:= 33
		oCard:fnVerde 		:= 34
		oCard:fnAzul 		:= 0
		
		oCard:fnFeedback := BSC_FB_GRAY    
		
		If(lVerCores) 
		
			If(oCard:fnIndicador < oCard:fnVermelho) 
			
				If(nFeedback == 0)
					oCard:fnFeedback := BSC_FB_REDSM 					
				ElseIf(nFeedback > 0)
					oCard:fnFeedback := BSC_FB_REDUP 					
				Else
					oCard:fnFeedback := BSC_FB_REDDN					
				Endif	
				
			ElseIf(oCard:fnIndicador < oCard:fnAmarelo+oCard:fnVermelho) 
			
				If(nFeedback == 0)
					oCard:fnFeedback := BSC_FB_YELLOWSM
				ElseIf(nFeedback > 0)
					oCard:fnFeedback := BSC_FB_YELLOWUP
				Else
					oCard:fnFeedback := BSC_FB_YELLOWDN
				Endif	 
				
			ElseIf(oCard:fnIndicador < oCard:fnVerde+oCard:fnAmarelo+oCard:fnVermelho)   
			
				If(nFeedback == 0)
					oCard:fnFeedback := BSC_FB_GREENSM
				Elseif(nFeedback > 0)
					oCard:fnFeedback := BSC_FB_GREENUP
				Else
					oCard:fnFeedback := BSC_FB_GREENDN
				Endif	   
				
			Else     
			
				If(nFeedback == 0)
					oCard:fnFeedback := BSC_FB_GREENSM
				ElseIf(nFeedback > 0)
					oCard:fnFeedback := BSC_FB_GREENUP
				Else
					oCard:fnFeedback := BSC_FB_GREENDN
				Endif				
			Endif  			
		Endif	
	Else
	
		oCard:fnIndicador 	:= 0  		
		oCard:fnFeedback 	:= BSC_FB_GRAY
		oCard:fnVermelho 	:= 0
		oCard:fnAmarelo 	:= 0
		oCard:fnVerde 		:= 0
		oCard:fnAzul 		:= 0
		oCard:fnPercMeta 	:= 0
		oCard:fcPercMeta 	:= cBIStr(oCard:fnPercMeta)+ "%"
	Endif
	
return oCard

// oXMLCard()
// Retorna um no XML completo do card
method oXMLCard() class TBSC014

	local oXMLCard := ::oMakeCard():oToXMLCard()
	oXMLCard:oAddChild(TBIXMLNode():New("ID", ::nValue("ID")))
	oXMLCard:oAddChild(TBIXMLNode():New("ORDEM", 0))
	oXMLCard:oAddChild(TBIXMLNode():New("CARDX", 0))
	oXMLCard:oAddChild(TBIXMLNode():New("CARDY", 0))
	oXMLCard:oAddChild(::oOwner():oGetTable("INDICADOR"):oToXMLList(::nValue("ID")))

return oXMLCard         

function _bsc014_obj()
return
