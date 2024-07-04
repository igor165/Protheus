// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSCPERSP_DD.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 7.03.07 | 1776 Alexandre Silva
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSCPERSP_DD.ch"

/*--------------------------------------------------------------------------------------
@class TBSCMAPA_EST2
@entity MAPAEST2
Representacao do mapa estrategico modelo 2.
@table Nao existe tabela associada a esta entidade.
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "PERSP_DRILLD"
#define TAG_GROUP  "PERSPS_DRILLD"
#define TEXT_ENTITY STR0001/*//"Perspectiva Drill Down"*/
#define TEXT_GROUP  STR0002/*//"Perspectiva Drill Down"*/

class TBSCPERSP_DD from TBITable
	method New() constructor
	method NewBSCPERSP_DD()

	method oToXMLList(nParentID)
	method oToXMLNode(nParentID, cLoadCMD)
	
endclass

method New() class TBSCPERSP_DD
	::NewBSCPERSP_DD()
return

method NewBSCPERSP_DD() class TBSCPERSP_DD
	// Table
	::cEntity(TAG_ENTITY)
return

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSCPERSP_DD
	local oNode, oAttrib, oXMLNode, nInd
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", "MAPAREL")
	oAttrib:lSet("RETORNA", .f.)
	// Gera no principal
	oXMLNode := TBIXMLNode():New("MAPARELS",,oAttrib)
	
	// Gera recheio
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New("MAPAREL"))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID", "CONTEXTID"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro

return oXMLNode

// Carregar
method oToXMLNode(nID, cLoadCMD) class TBSCPERSP_DD
	local oTablePer :=	::oOwner():oGetTable("PERSPECTIVA")
	local oTableObj := 	::oOwner():oGetTable("OBJETIVO")
	local oTableInd := 	::oOwner():oGetTable("INDICADOR")
	local oAttrib	:=	TBIXMLAttrib():New()
	local oAttInd	:=	TBIXMLAttrib():New()
	local oPersp	:= 	nil
	local oNodePer	:=	nil
	local oInds		:=	nil
	local lFisrtReg := .t.	
	local oXMLNode 	:=	TBIXMLNode():New(TAG_ENTITY)
	local aPessoas 	:=	{}
    local lLoadObj 	:=	.f.
    local cParametro:=	""
    local cOrigem	:=	""
    local nPosID	:=	0
    local nObjID	:=	""

    if("OBJETIVO" $ cLoadCMD )
		lLoadObj:= .t. 
		nPosID	:=	at("OBJETIVO_ID=",cLoadCMD) + 12
		nObjID	:=	subs(cLoadCmd,nPosID,len(cLoadCmd))	
    endif

	//
	oXMLNode:oAddChild(TBIXMLNode():New("ID", nID))
	oXMLNode:oAddChild(TBIXMLNode():New("PARENTID", nID))
	oXMLNode:oAddChild(TBIXMLNode():New("CONTEXTID", nID))
	
	//Lista de Pessoas
	aPessoas := ::oOwner():aListPessoas(::oOwner():foSecurity:oLoggedUser():nValue("ID"))	
	
	oAttrib:lSet("TIPO", "PERSPECTIVA")
	oAttrib:lSet("RETORNA", .f.)

	oPersp := oXMLNode:oAddChild(TBIXMLNode():New("PERSPECTIVAS","",oAttrib))

	if( oTablePer:lSeek(1, {nID} ) .and. ! oTablePer:lValue("OPERAC"))
		oXMLNode:oAddChild(TBIXMLNode():New("NOME",oTablePer:cValue("NOME")))	
		oNodePer := oPersp:oAddChild(TBIXMLNode():New("PERSPECTIVA",oAttrib))
		oNodePer:oAddChild(TBIXMLNode():New("NOME",oTablePer:cValue("NOME")))
		// Objetivos
		if(lLoadObj)
			oTableObj:cSQLFilter("ID = " + cBIStr(nObjID))//Filtra um unico objetivo
		else
			oTableObj:cSQLFilter("PARENTID = " + oTablePer:cValue("ID"))//Filtra todos os objetivos desta perspectiva.
		endif			
		oTableObj:lFiltered(.t.)
		oTableObj:_First()

		//Criacao do vetor de indicadores
		oAttInd:lSet("TIPO", "INDICADOR")
		oAttInd:lSet("RETORNA", .f.)

		oAttInd:lSet("TAG000", "OBJETIVO")
		oAttInd:lSet("CAB000", STR0003) //"Parametro"
		oAttInd:lSet("CLA000", BSC_STRING)

		oAttInd:lSet("TAG001", "ORIGEM")
		oAttInd:lSet("CAB001", STR0004) //"Origem"
		oAttInd:lSet("CLA001", BSC_STRING)
	
		oAttInd:lSet("TAG002", "INDICADOR")
		oAttInd:lSet("CAB002", STR0005)//"Indicador"
		oAttInd:lSet("CLA002", BSC_STRING)

		oInds := oNodePer:oAddChild(TBIXMLNode():New("INDICADORES","",oAttInd))							
		
		while(! oTableObj:lEof())
			lFisrtReg := .t.
			oTableInd:SetOrder(2) // Por ordem de nome
			oTableInd:cSQLFilter("PARENTID = "+ cBIStr(oTableObj:cValue("ID"))) // Filtra pelo pai
			oTableInd:lFiltered(.t.)
			oTableInd:_First()
			
			if(! oTableInd:lEof())
				while(! oTableInd:lEof())
					oNode := oInds:oAddChild(TBIXMLNode():New("INDICADOR"))
					if(lFisrtReg)
						lFisrtReg	:= .f.
						cParametro	:= oTableObj:cValue("NOME")
						cOrigem		:= oTableObj:cValue("ORIGEM")
					else
						cParametro	:=	""
						cOrigem		:=	""
					endif
					oNode:oAddChild(TBIXMLNode():New("OBJETIVO",cParametro))
					oNode:oAddChild(TBIXMLNode():New("ORIGEM",cOrigem))					
					oNode:oAddChild(TBIXMLNode():New("INDICADOR",oTableInd:cValue("NOME")))
					oNode:oAddChild(TBIXMLNode():New("IND_ID",oTableInd:cValue("ID")))					
					oTableInd:_Next()
				end
			else
				oNode := oInds:oAddChild(TBIXMLNode():New("INDICADOR"))
				oNode:oAddChild(TBIXMLNode():New("OBJETIVO",oTableObj:cValue("NOME")))
				oNode:oAddChild(TBIXMLNode():New("ORIGEM",oTableObj:cValue("ORIGEM")))
				oNode:oAddChild(TBIXMLNode():New("IND_ID","0"))				
				oNode:oAddChild(TBIXMLNode():New("INDICADOR",""))					
			endif
			
			oTableInd:cSQLFilter("") // Encerra filtro
			oTableObj:_Next()
		enddo
		oTableObj:cSQLFilter("") // Encerra filtro
	endif
	
return oXMLNode   

function _BSCPersp_DD()
return