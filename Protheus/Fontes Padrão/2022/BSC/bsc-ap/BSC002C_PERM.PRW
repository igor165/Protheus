// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC002C_Perm.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 04.03.2009 | 2516 Lucio Pelinson
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "BSCDefs.ch"


/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIEvtObject->TBIDataSet->TBITable->BSC002C_Perm
@entity Permissão
Permissão dos usuarios no sistema BSC.
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "USERPERM"
#define TAG_GROUP  "USERPERMS"
#define TEXT_ENTITY "PERMISSÃO"
#define TEXT_GROUP  "PERMISSÕES"

class TBSC002C from TBITable
	method New() constructor
	method NewBSC002C() 

	method oToXMLList()
	method oToXMLNode(nId,sCmd)
	method nUpdFromXML(oXML, cPath)
	
endclass
	
method New() class TBSC002C
	::NewBSC002C()
return      

method NewBSC002C() class TBSC002C
	::cEntity(TAG_ENTITY)
return

// Carregar
method oToXMLNode(nId,cLoadCMD) class TBSC002C
	local oNode		:= nil
	local oXMLNode 	:= TBIXMLNode():New(TAG_ENTITY)   
	local aLoadCMD  := {}
	local cOwnerId	:= ""
	local cOwner	:= ""
	local cCmd		:= ""
	local cIdEnt 	:= ""
	local cNomeEnt 	:= ""
	
	
    if len(alltrim(cLoadCMD)) > 0   
    	aLoadCMD  := aBIToken(cLoadCMD, "|", .f.)
    	cCmd  	  := aLoadCMD[1]
    	cOwner	  := aLoadCMD[2]
    	cOwnerId  := aLoadCMD[3]
		cOrganizacao  := aLoadCMD[4]

    	if cCmd == "ARVORE" 
		    oNode := oXMLNode:oAddChild(TBIXMLNode():New("ARVORES"))
			oNode:oAddChild(::oOwner():oArvore(,.f.,.t., cOrganizacao))   
	    elseif cCmd == "REGRA"
		    cIdEnt 	 := aLoadCMD[4]  
		    cNomeEnt := aLoadCMD[5]  
		    // Adiciona Regras para os node da arvore
			if cOwner == "G"     
				oXMLNode:oAddChild(::oOwner():oGetTable("GRUPO"):getRegra(val(cOwnerId),cNomeEnt,val(cIdEnt)))
			else                                                            
				oXMLNode:oAddChild(::oOwner():oGetTable("USUARIO"):getRegra(val(cOwnerId),cNomeEnt,val(cIdEnt)))
			endif
	    
	    endif
	endif

return oXMLNode

// Lista XML para anexar ao pai
method oToXMLList() class TBSC002C
	local nStatus := BSC_ST_OK
    conout("Not implemented...")
return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TBSC002C
	local nStatus 		:= BSC_ST_OK
	local nOwnerID 		:= 0
	local nRegraId		:= 0    
	local nIdEnt		:= 0 
	local nIdOper		:= 0 
	local nCount		:= 0
	local sNomeEnt		:= ""
	local sOwner		:= ""
	local bValue		:= .f. 
	local aFields		:= {}
	local oRegra		:= ::oOwner():oGetTable("REGRA")
	private oXMLInput 	:= oXML
     
	nOwnerID:= val(xBIConvTo("C",oXML:_REGISTROS:_USERPERM:_OWNERID:TEXT))
	sOwner  := alltrim(xBIConvTo("C",oXML:_REGISTROS:_USERPERM:_OWNER:TEXT))
	
	oNode	:=	oXML:_REGISTROS:_USERPERM:_REGRAS:_REGRA
	if !valtype(oNode) == "A"
		oNode := { oNode }
	endif
		
	for nCount := 1 to len(oNode)
		nRegraId 	:= val(oNode[nCount]:_IDREGRA:TEXT) 
		nIdOper		:= val(oNode[nCount]:_IDOPERACAO:TEXT) 
		nIdEnt 		:= val(oNode[nCount]:_IDENT:TEXT)
		sNomeEnt	:= oNode[nCount]:_NOMEENT:TEXT
		bValue		:= alltrim(oNode[nCount]:_VALOR:TEXT) == "T"  
				
		aFields := {}
		if nRegraId == 0   
			aadd(aFields,{"ID", 		oRegra:nMakeID()	})  
			aadd(aFields,{"PARENTID", 	0					})  
			aadd(aFields,{"CONTEXTID",  0					})    
			aadd(aFields,{"OWNER",  	sOwner				})    
			aadd(aFields,{"IDOWNER",  	nOwnerID			})    
			aadd(aFields,{"ENTITY",  	padr(sNomeEnt,30)	})  
			aadd(aFields,{"IDENT",  	nIdEnt				})  
			aadd(aFields,{"IDOPERACAO", nIdOper				})  
			aadd(aFields,{"PERMITIDA", 	bValue				})  
			oRegra:lAppend(aFields)
		else   
			if(!oRegra:lSeek(1, {nRegraId}))
				nStatus := BSC_ST_BADID
			else    
				aadd(aFields,{"PERMITIDA", 	bValue}) 
				if(!oRegra:lUpdate(aFields))
					if(oRegra:nLastError()==DBERROR_UNIQUE)
						nStatus := BSC_ST_UNIQUE
					else
						nStatus := BSC_ST_INUSE
					endif
				endif
			endif
		endif
	next 

return nStatus

function _BSC002c_Perm()
return


