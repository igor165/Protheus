// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC045_DriObj.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 24.05.05 | 0739 Aline Correa do Vale
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"

/*--------------------------------------------------------------------------------------
@class TBSC045
@entity Drill
Drill down de Objetivos e Objetivos Desdobrados.
@table BSC045
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "DRILLOBJ"
#define TAG_GROUP  "DRILLOBJS"
#define TEXT_ENTITY "DrillObj"
#define TEXT_GROUP  "DrillObjs"

class TBSC045 from TBITable
	method New() constructor
	method NewBSC045()

	method oToXMLNode(nParentID)
	method nUpdFromXML(oXML, cPath, nParentID)
	method loadCausaEfeito(cCausa,oXMLOutput,oObjetivo,nEstratID,nParentID)  
	
endclass
	
method New() class TBSC045
	::NewBSC045()
return
method NewBSC045() class TBSC045
	// Table
	::NewTable("BSC045")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	// Indexes
	::addIndex(TBIIndex():New("BSC045I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC045I02",	{"CONTEXTID"},	.f.))
	::addIndex(TBIIndex():New("BSC045I03",	{"PARENTID", "ID"},	.t.))
return

// Carregar
method oToXMLNode(nParentID) class TBSC045
	local oXMLOutput, oXmlDesdob, oObjetivo,  oDesdobrado
	local nInd1, nLenDesdob, nEstratID, nObjetivoID, dDataAlvo
	local  oCardsNode, lParcelada
	
	// No principal
	oXMLOutput := TBIXMLNode():New(TAG_ENTITY)

	// Objetivo
	oObjetivo := ::oOwner():oGetTable("OBJETIVO")
	oObjetivo:lSeek(1, {nParentID})
    oXMLOutput:oAddChild(::oOwner():oContext(oObjetivo, nParentID))

	nEstratID := oObjetivo:nValue("CONTEXTID")

	// Cabecalho da central
	oXMLOutput:oAddChild(TBIXMLNode():New("ID", nEstratID))
	oXMLOutput:oAddChild(TBIXMLNode():New("NOME", oObjetivo:cValue("NOME")))
	oXMLOutput:oAddChild(TBIXMLNode():New("PARENTID", nEstratID))
	oXMLOutput:oAddChild(TBIXMLNode():New("CONTEXTID", nEstratID))

	// XML com cards do objetivo
	oCardsNode := oXMLOutput:oAddChild(TBIXMLNode():New("CARDS"))
	oNode := oCardsNode:oAddChild(oObjetivo:oXMLCard())
	oNode:oAddChild(TBIXMLNode():New("VISIVEL",.t.))
	
	// XML com cards do Objetivos desdobrados
	oDesdobrado	:= ::oOwner():oGetTable("DESDOB")
	oXmlDesdob	:= oDesdobrado:oToEntityList("OBJETIVO", nParentID)
	nLenDesdob	:= oXmlDesdob:nChildCount("DESDOB")
	for nInd1 := 1 to nLenDesdob
		oNode := oXmlDesdob:oChildByName("DESDOB", nInd1)
		nObjetivoID := oNode:oChildByName("ID"):nGetValue()
		oObjetivo:lSeek(1, {nObjetivoID})
		oNode := oCardsNode:oAddChild(oObjetivo:oXMLCard())
		oNode:oAddChild(TBIXMLNode():New("ID",nObjetivoID))
		oNode:oAddChild(TBIXMLNode():New("VISIVEL",.t.))
		oNode:oAddChild(TBIXMLNode():New("ORDEM", 0))
		oNode:oAddChild(TBIXMLNode():New("CARDX", 0))
		oNode:oAddChild(TBIXMLNode():New("CARDY", 0))
	next

	//Acrescemta os objetivos CausaXEfeito	
	::loadCausaEfeito("TENDENCIAS",@oXMLOutput,oObjetivo,nEstratID,nParentID)
	::loadCausaEfeito("INFLUENCIAS",@oXMLOutput,oObjetivo,nEstratID,nParentID)	 

 	dDataAlvo := ::oOwner():xSessionValue("DATAALVO")
	if(valtype(dDataAlvo)=="U")
		dDataAlvo := date()
	endif	     

	lParcelada := ::oOwner():xSessionValue("PARCELADA")
	if(empty(lParcelada))
		lParcelada := .f.
	endif	     

	// Acrescenta children
	oXMLOutput:oAddChild(TBIXMLNode():New("PARCELADA", lParcelada))
	oXMLOutput:oAddChild(TBIXMLNode():New("DATAALVO", dDataAlvo))
return oXMLOutput

//Baseando-se no objetivo carrega as causas e efeitos para este objetivo.
method loadCausaEfeito(cCausa,oXMLOutput,oObjetivo,nEstratID,nParentID)  class TBSC045
	Local cConexaoID,cDesConexaoID,cDesType, cCausaNode
	Local nConOrdem,nObjCod,nItem
	Local oTema_X_Objetivo, oCausaNode
	Local aLstObjInc := {}

	if cCausa == "TENDENCIAS"
		cCausaNode		:= "TENDENCIA"
		cConexaoID 		:= "SRCID"
		cDesConexaoID	:= "DESTID"
		cDesType		:= "DESTYPE"
		nConOrdem		:= 4
	elseif(cCausa == "INFLUENCIAS")
		cCausaNode		:= "INFLUENCIA"
		cConexaoID 		:= "DESTID"
		cDesConexaoID	:= "SRCID"
		cDesType		:= "SCRTYPE"
		nConOrdem		:= 5
	endif

	//Relacao Objetivo Tema
	oTema_X_Objetivo := ::oOwner():oGetTable("TEMAOBJETIVO")
	
	// Pegar tendencias no mapa-estratégico - Efeito
	oCausaNode := oXMLOutput:oAddChild(TBIXMLNode():New(cCausa))
	oMapaEst := ::oOwner():oGetTable("MAPAEST")
	oMapaEst:SetOrder(nConOrdem) // Por origem-destino
	oMapaEst:lSoftSeek(nConOrdem, {nEstratID, nParentID, 0})
	while(oMapaEst:nValue(cConexaoID)==nParentID)
		//Verifica se e um conexao entre Objetivos.
		nObjCod := oMapaEst:nValue(cDesConexaoID)
		if (oMapaEst:cValue(cDesType) != "T")
	        if(ascan(aLstObjInc,nObjCod) == 0)
				aadd(aLstObjInc,nObjCod) 
	        endif 
		elseif(oMapaEst:cValue(cDesType) == "T")
			//Adicionando os objetivos que estao dentro do tema.
			oTema_X_Objetivo:SetOrder(2) //Parent
			oTema_X_Objetivo:lSoftSeek(2, {nObjCod})
			while(oTema_X_Objetivo:nValue("PARENTID")==nObjCod)
		        if(ascan(aLstObjInc,oTema_X_Objetivo:nValue("OBJETIVOID")) == 0)
					aadd(aLstObjInc,oTema_X_Objetivo:nValue("OBJETIVOID")) 
		        endif 
				oTema_X_Objetivo:_Next()		
			end
		endif
		oMapaEst:_Next()		
	end
	
	//Verificar se o objetivo esta dentro de um agrupamento.
	oTema_X_Objetivo:SetOrder(3) //Parent
	if (oTema_X_Objetivo:lSeek(3, {nParentID}))
		//Esta dentro de um agrupamento.
		//Verifica se existe um conexão para este agrupamento.
		oMapaEst:lSoftSeek(nConOrdem, {nEstratID,oTema_X_Objetivo:nValue("PARENTID")})						
		while(oMapaEst:nValue(cConexaoID)==oTema_X_Objetivo:nValue("PARENTID"))
			//Verifica se e um conexao entre Objetivos.
			nObjCod := oMapaEst:nValue(cDesConexaoID)
			if (oMapaEst:cValue(cDesType) != "T")
		        if(ascan(aLstObjInc,nObjCod) == 0)
					aadd(aLstObjInc,nObjCod) 
		        endif 
			elseif(oMapaEst:cValue(cDesType) == "T")
				//Adicionando os objetivos que estao dentro do tema.
				oTema_X_Objetivo:SetOrder(2) //Parent
				oTema_X_Objetivo:lSoftSeek(2, {nObjCod})
				while(oTema_X_Objetivo:nValue("PARENTID")==nObjCod)
			        if(ascan(aLstObjInc,oTema_X_Objetivo:nValue("OBJETIVOID")) == 0)
						aadd(aLstObjInc,oTema_X_Objetivo:nValue("OBJETIVOID")) 
			        endif 
					oTema_X_Objetivo:_Next()		
				end
			endif
			oMapaEst:_Next()		
		end
	endif

	//Adicionar todos os objetivos
	for nItem := 1 to len(aLstObjInc)
		if(oObjetivo:lSeek(1, {aLstObjInc[nItem]})) 
			oNode := oCausaNode:oAddChild(TBIXMLNode():New(cCausa))
			oNode:oAddChild(TBIXMLNode():New("ID", oObjetivo:nValue("ID")))
			oNode:oAddChild(TBIXMLNode():New("NOME", oObjetivo:cValue("NOME")))
			oNode:oAddChild(TBIXMLNode():New("FEEDBACK", oObjetivo:nFeedBack()))
		endif
	next nItem		

return             

function _BSC045_DriObj()
return