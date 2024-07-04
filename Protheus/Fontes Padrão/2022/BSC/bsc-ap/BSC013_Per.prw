// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC013_Per.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC013_Per.ch"

/*--------------------------------------------------------------------------------------
Perspectivas contempladas no BSC.
@entity Perspectiva
Representa um angulo de visão sobre a estrategia.
Perspectivas cadastradas por default, durante a criação de um novo plano estratégico:
	- Financeira
	- Cliente
	- Processo Interno
	- Aprendizado e Crescimento
@table BSC013
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "PERSPECTIVA"
#define TAG_GROUP  "PERSPECTIVAS"
#define TEXT_ENTITY STR0001/*//"Perspectiva"*/
#define TEXT_GROUP  STR0002/*//"Perspectivas"*/

class TBSC013 from TBITable
	method New() constructor
	method NewBSC013()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)
	method oToXMLContextList(nContextID)      
	
	method nDelUserOptions(nParentID)
	method nReordena(nId, nParentID, nOrder, nOldOrder)

	// registro atual
	method oToXMLNode(nParentID)
	method oNodePersp()
	
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)
	
	method nDuplicate(nParentID, nNewParentID, nNewContextID, aObjIDs, aIndIds,aIndTemas)

endclass
	
method New() class TBSC013
	::NewBSC013()
return
method NewBSC013() class TBSC013
	local oField

	// Table
	::NewTable("BSC013")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("FEEDBACK",	"N"))
	::addField(TBIField():New("ORDEM",		"N"))
	::addField(oField := TBIField():New("NOME",		"C",	60))
	oField:lSensitive(.f.)
	::addField(TBIField():New("DESCRICAO",	"C",	255))
	::addField(TBIField():New("HEIGHT",		"N"))
	::addField(TBIField():New("BACKCOLOR",	"N"))	
	::addField(TBIField():New("OPERAC",		"L"))                  
	::addField(TBIField():New("ZERACUSTON"	,"C",01))//Indica se as customizações devem ou não ser zeradas
	//Inicio - Campos das propriedades do mapa estrategico 2. Sigla MP2
	::addField(TBIField():New("MP2HEIGHT"	,"N"))	
	::addField(TBIField():New("MP2WIDTH"	,"N"))
	::addField(TBIField():New("MP2X"		,"N"))	
	::addField(TBIField():New("MP2Y"		,"N"))		
	::addField(TBIField():New("MP2DEGRADE"	,"C",01))	
	::addField(TBIField():New("MP2TITCOR"	,"N"))//Cor do titulo da perspectiva
	::addField(TBIField():New("MP2FONTE"	,"C",30))//Fonte do titulo
	::addField(TBIField():New("MP2FONTAM"	,"N"))//Tamanho da fonte
	::addField(TBIField():New("MP2FONEST"	,"N"))//Estilo da fonte
	//Fim - Campos das propriedades do mapa estrategico 2. Sigla MP2
	
	// Indexes
	::addIndex(TBIIndex():New("BSC013I01",	{"ID"}, .T.))
	::addIndex(TBIIndex():New("BSC013I02",	{"NOME", "CONTEXTID"}, .T.))
	::addIndex(TBIIndex():New("BSC013I03",	{"PARENTID", "ID"},	.T.))
	::addIndex(TBIIndex():New("BSC013I04",	{"ORDEM", "CONTEXTID"},	.F.))
	::addIndex(TBIIndex():New("BSC013I05",	{"PARENTID"},	.F.))
return   

// Arvore
method oArvore(nParentID) class TBSC013
	local oXMLArvore, oNode
	
	::SetOrder(4) // Por ordem de perspectiva
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
			oAttrib:lSet("NOME", alltrim(::cValue("NOME")))      

			oAttrib:lSet("FEEDBACK", ::nValue("FEEDBACK"))
			oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
			oChild := ::oOwner():oGetTable("OBJETIVO"):oArvore(::nValue("ID"))
			if(valtype(oChild) == "O")
				oNode:oAddChild(oChild) // Children (Objetivos)
			endif	
			::_Next()
		enddo
	endif
	::cSQLFilter("") // Encerra filtro
return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC013
	local oNode, oAttrib, oXMLNode, nInd
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", BSC_STRING)
	// Ordem
	oAttrib:lSet("TAG001", "ORDEM")
	oAttrib:lSet("CAB001", STR0004)/*//"Ordem"*/
	oAttrib:lSet("CLA001", BSC_INT)
	// Operacional
	oAttrib:lSet("TAG002", "OPERAC")
	oAttrib:lSet("CAB002", STR0005)/*//"Operacional"*/
	oAttrib:lSet("CLA002", BSC_BOOLEAN)
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(4) // Por ordem de perspectiva
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","DESCRICAO","HEIGHT","BACKCOLOR"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Lista XML para anexar ao Contexto
method oToXMLContextList(nContextID) class TBSC013
	local oNode, oAttrib, oXMLNode, nInd
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", BSC_STRING)
	// Ordem
	oAttrib:lSet("TAG001", "ORDEM")
	oAttrib:lSet("CAB001", STR0004)/*//"Ordem"*/
	oAttrib:lSet("CLA001", BSC_INT)
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(4) // Por ordem de perspectiva
	::cSQLFilter("CONTEXTID = "+cBIStr(nContextID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","DESCRICAO","HEIGHT","BACKCOLOR"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode(nParentID) class TBSC013
	local nID, aFields, nInd, nRecCount := 1
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif	
	next
              
	/*Adiciona children (Objetivos)*/
	oXMLNode:oAddChild(::oOwner():oGetTable("OBJETIVO"):oToXMLList(nID) )
	oXMLNode:oAddChild(::oOwner():oContext(self,nParentID))

	::SetOrder(4) /*Filtra por ORDEM DE PERSPECTIVA*/
	::cSQLFilter("PARENTID = " + cBIStr(::nValue("PARENTID")))
	::lFiltered(.t.)

	/*Incrementa o contador de perspectivas.*/	        
	While !(::lEof())
	   	nRecCount++
		::_Next()
	Enddo
		
	/*Retorna a quantidade de perspectivas de um determinado objetivo.*/   
	oXMLNode:oAddChild(TBIXMLNode():New("PERSPCOUNT", nRecCount - 1))  
	
	::cSQLFilter("")	       
	
return oXMLNode

//Carregar
method oNodePersp(aExececao) class TBSC013
	local aExececao := {}
	local nID, aFields, nInd
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY,aExececao)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif	
	next

return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC013
	local aFields, nInd, nStatus := BSC_ST_OK
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID"})

	/*Extrai valores do XML*/
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		
		If (aFields[nInd][1] == "ORDEM")			       
			::SetOrder(4) 
			::cSQLFilter("PARENTID = " + cBIStr(&("oXMLInput:"+cPath+":_PARENTID:TEXT")))
			::lFiltered(.t.)
			::_Last() 	
			aFields[nInd][2] := (::nValue("ORDEM") + 1) 			
			::cSQLFilter("")
		Else
	    	aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
	    EndIf		
	
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
method nUpdFromXML(oXML, cPath) class TBSC013
	Local nInd, nStatus := BSC_ST_OK, nID    
	Local nParentID
	Local lZeraCustom
	Local nOldOrder
	Local nOrder
	
	Private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY)       

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		
		If(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif	
		
		If(aFields[nInd][1] == "PARENTID")
			nParentID := aFields[nInd][2]
		endif
		    
		If(aFields[nInd][1] == "ZERACUSTON")
			cZeraCustom := aFields[nInd][2]
		endif 
	      
		If(aFields[nInd][1] == "ORDEM")
			nOrder := int(aFields[nInd][2])
		endif
	next
     
	nOldOrder := val(&("oXMLInput:"+cPath+":_OLDORDER:TEXT"))

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
    
    // zera as customizações de posicionamento e dimensão de objetivos e perspectivas realizadas no mapa estrategico 2                                
	If (cZeraCustom == 'T')
		::nDelUserOptions(nParentID)    
		::nReordena(nID, nParentID, nOrder, nOldOrder)
	EndIF
	
return nStatus

// Excluir entidade do server
method nDelFromXML(nID) class TBSC013
	local nStatus := BSC_ST_OK, oTableChild
	Local nParentID
	Local nOrder 
	 
	               	
	::oOwner():oOltpController():lBeginTransaction()

	// Procura por children (Objetivos)
	oTableChild:= ::oOwner():oGetTable("OBJETIVO")
	oTableChild:SetOrder(3) // Por ordem de ParentId
	oTableChild:cSQLFilter("PARENTID = "+cBIStr(nID)) // Filtra pelo paI
	oTableChild:lFiltered(.t.)
	oTableChild:_First()
	while(!oTableChild:lEof() .and. nStatus == BSC_ST_OK)
		nStatus := ::oOwner():oGetTable("OBJETIVO"):nDelFromXML(oTableChild:nValue("ID"))
		oTableChild:_Next()
	enddo
	oTableChild:cSQLFilter("") // Limpa o filtro

	// Deleta o elemento
	if(nStatus == BSC_ST_OK)
		if(::lSeek(1, {nID})) 
		    
			nParentID 	:= ::nValue("PARENTID")
			nOrder		:= ::nValue("ORDEM") 		     
		
	     	if(!::lDelete())
				nStatus := BSC_ST_INUSE
			Else
				::nDelUserOptions(nParentID)	
				::nReordena(nID, nParentID, nOrder) 			
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
// aObjIDs - Deve ser passado por referencia
method nDuplicate(nParentID, nNewParentID, nNewContextID, aObjIDs, aIndIds,aIndTemas) class TBSC013
	local nStatus := BSC_ST_OK, aFields, nID
	
	::oOwner():oOltpController():lBeginTransaction()

	::SetOrder(1)
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof() .and. nStatus == BSC_ST_OK)
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
			// Children
			::restPos()
			nStatus := ::oOwner():oGetTable("OBJETIVO"):nDuplicate(::nValue("ID"), nID, nNewContextID, @aObjIDs, @aIndIds)
			if(nStatus == BSC_ST_OK)
				nStatus := ::oOwner():oGetTable("MAPATEMA"):nDuplicate(::nValue("ID"), nID, nNewContextID,aObjIDs,@aIndTemas)
			endif
			if(nStatus != BSC_ST_OK)
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

/*Realiza a reodenação das perspectivas.
@Param
	nId    		ID da perspectiva que dispara a reordenação.
	nParentID   PARENTID da perspectiva que dispara a reordenação.
	nOrder     	ORDEM corrente da perspectiva. 
	nOldOrder   ORDEM ANTERIOR da perspectiva.  
@Rerturn
	nStatus 	Status da operação de reordenação.*/
	
method nReordena(nID ,nParentID, nOrder, nOldOrder) class TBSC013
    Local nNewOrder  
    Local lReordena := .F.
    Local nStatus := BSC_ST_OK
 
    ::lSeek(5,{nParentID}) /*PARENTID*/     
    
	/*Itera por todas as perspectivas com o PARENTID informado.*/
	While (!::lEof() .And. ::cValue("PARENTID") == cBIStr(nParentID))		
		/*Em caso de DELETE de PERSPECTIVA.*/
		If (nOldOrder == Nil)		    
            /*Se a perspectiva que está sendo iterada tiver ordem MAIOR que a perspectiva deletada*/
			If (self:nValue("ORDEM") > nOrder)  
				/*Declementa em UM a ordem da perspectiva iterada.*/
				nNewOrder 	:= ::nValue("ORDEM") - 1 
				lReordena 	:= .T.
			EndIf
						
		Else  
            /*Se a nova ordem da perspectiva for MENOR que a ordem anterior.*/			
			If (nOldOrder > nOrder)
						
				If (::nValue("ORDEM") >= nOrder .And. ::nValue("ORDEM") <= nOldOrder );
				 	.And. !(::nValue("ID") == nID) //A ordem da própria perspectiva não pode ser alterada.
					/*Incrementa em UM a ordem da perspectiva iterada.*/
					nNewOrder 	:= ::nValue("ORDEM") + 1 
					lReordena 	:= .T.
				EndIf	 
			/*Se a nova ordem da perspectiva for MAIOR que a ordem anterior.*/		
			ElseIf (nOldOrder < nOrder)
			   
				If (::nValue("ORDEM") <= nOrder .And. ::nValue("ORDEM") >= nOldOrder );
					 .And. !(::nValue("ID") == nID) //A ordem da própria perspectiva não pode ser alterada.
					/*Declementa em UM a ordem da perspectiva iterada.*/
					nNewOrder 	:= ::nValue("ORDEM") - 1 
					lReordena 	:= .T.
				EndIf
			
			EndIf 
		 
		EndIf	
         
        /*Se TRUE atualiza a ordem das perspectiva de acordo com nNewOrder.*/     
		If (lReordena) 
		
			If(!::lUpdate({{"ORDEM", nNewOrder}})) 
			
				If(::nLastError()==DBERROR_UNIQUE)
					nStatus := BSC_ST_UNIQUE
				Else
					nStatus := BSC_ST_INUSE
				Endif  
				
			Endif 
			
			lReordena := .F.
		EndIf

		::_Next()
	End
 
return nStatus

/*Restaura as configurações do mapa estratégico, modelo 2, para DEFAULT.
@Param
	nParentID   PARENTID da perspectiva que dispara a reconfiguração.
@Rerturn
	nStatus 	Status da operação de reconfiguração.*/   
	                         
method nDelUserOptions(nParentID) class TBSC013 
    Local nStatus := BSC_ST_OK  
    
	::oOwner():oOltpController():lBeginTransaction()
     
	/*Restaura a configuração DEFAULT de posicionamento de PERSPECTIVAS.*/
	::SetOrder(4) /*Por ORDEM.*/
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) 
	::lFiltered(.t.)
	::_First()     
	
	While(!::lEof())
		If(!::lUpdate({{"MP2HEIGHT",0},{"MP2WIDTH",0},{"MP2X",0},{"MP2Y",0}}))
			If(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			Else
				nStatus := BSC_ST_INUSE
			Endif
		Endif      
	 	
	 	::_Next() 	 	
	End      

	::cSQLFilter("")       
      
    /*Restaura a configuração DEFAULT de posicionamento de OBJETIVOS.*/
	oObjetivo:= ::oOwner():oGetTable("OBJETIVO")
	oObjetivo:SetOrder(3) /*Por PARENTID.*/
	oObjetivo:cSQLFilter("CONTEXTID = "+cBIStr(nParentID)) 
	oObjetivo:lFiltered(.t.)
	oObjetivo:_First()     
	
	while(!oObjetivo:lEof())
		If(!oObjetivo:lUpdate({/*{"MAPWIDTH",0},{"MAPHEIGHT",0},*/{"MP2X",0},{"MP2Y",0},{"MP2WIDTH",0},{"MP2HEIGHT",0}}))
			If(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			Else
				nStatus := BSC_ST_INUSE
			Endif
    	endif
		oObjetivo:_Next()
	enddo

	oObjetivo:cSQLFilter("")	     
	         
	::oOwner():oOltpController():lEndTransaction()
    
return nStatus
                       
function _bsc013_per()
return
