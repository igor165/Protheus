// ######################################################################################
// Projeto: BSC
// Modulo : Core
// Fonte  : BSC003_Sec.prw -Seguranca do sistema BSC. Atua junto com usuarios.
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC003_Sec.ch"

/*-------------------------------------------------------------------------------------
@class TBSC003
@entity Seguranca
Seguranca do sistema BSC. Atua junto com usuarios.
@table BSC003
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "REGRA"
#define TAG_GROUP  "REGRAS"
#define TEXT_ENTITY STR0001/*//"Regra"*/
#define TEXT_GROUP  STR0002/*//"Regras"*/

class TBSC003 from TBITable
	method New() constructor
	method NewBSC003() 

	method oToXMLNode(nIDOwner, cOwner)
	method nUpdFromXML(oXML, cPath, nIDOwner, cOwner)
	method GravaRegra(oXML, cPath, nIDOwner, cOwner, cEntity, nItem)

endclass
	
method New() class TBSC003
	::NewBSC003()
return
method NewBSC003() class TBSC003
	// Table
	::NewTable("BSC003")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID", 		"N"))
	::addField(TBIField():New("PARENTID", 	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("OWNER",		"C", 1))	// U = Usuário / G = Grupo
	::addField(TBIField():New("IDOWNER",	"N"))  		// ID do Usuário ou Grupo
	::addField(TBIField():New("ENTITY", 	"C", 30))	// Nome da Entidade
	::addField(TBIField():New("IDENT", 	"N"))		// ID da Entidade
	::addField(TBIField():New("IDOPERACAO","N"))		// ID da Operação
	::addField(TBIField():New("PERMITIDA",	"L"))		// Permite acesso a Operação

	// Indexes
	::addIndex(TBIIndex():New("BSC003I01",	{"ID"},	.t.))
	::addIndex(TBIIndex():New("BSC003I02",	{"CONTEXTID"}, .f.))
	::addIndex(TBIIndex():New("BSC003I03",	{"PARENTID", "ID"},	.t.))
	::addIndex(TBIIndex():New("BSC003I04",	{"OWNER", "IDOWNER", "ENTITY", "IDENT", "IDOPERACAO"}, .t.))
return

// Carregar
method oToXMLNode(nIDOwner, cOwner) class TBSC003
	local aFields, nInd
	local oXMLNode, oNode, oAttrib

	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .t.)
	// Operação
	oAttrib:lSet("TAG000", "IDOPERACAO")
	oAttrib:lSet("CAB000", STR0003)/*//"Operacao"*/
	oAttrib:lSet("CLA000", BSC_STRING)
	// Permitida
	oAttrib:lSet("TAG001", "PERMITIDA")
	oAttrib:lSet("CAB001", STR0004)/*//"Permitida"*/
	oAttrib:lSet("CLA001", BSC_BOOLEAN)
	oAttrib:lSet("EDT001", .t.)
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(2) // Por ordem de user/entidade
	::cSQLFilter("IDOWNER = " + cBISTR(nIDOwner) + " and OWNER = '" + cOwner + "'")
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID", "CONTEXTID"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro

return oXMLNode

// Atualiza e/ou Insere novas entidades
method nUpdFromXML(oXML, cPath, nIDOwner, cOwner) class TBSC003
	local nStatus := BSC_ST_OK
	//local cQuery,cMsg
	private oXMLInput := oXML
                                                                      
 	if(nIDOwner!=0)

		//cQuery:="DELETE FROM BSC003 WHERE IDOWNER = "+cBISTR(nIDOwner)+" AND OWNER = '"+cOwner+"'"
		//TCSQLEXEC(cBIParseSQL(cQuery, @cMsg))
		//TCREFRESH("BSC003")
		
	endif         

	// Grava
	::GravaRegra(oXML, cPath, nIDOwner, cOwner, "ORGANIZACAO")

return nStatus


method GravaRegra(oXML, cPath, nIDOwner, cOwner, cEntity, nItem) class TBSC003
	local oTable, nInd, nI, nJ, nK, aEntidades, nPos, nTempo, nTempo1, nTempo2, nTempo3
	local cPathProp		:=	cPath
	local nRegra		:=	0
	local nProp			:=	0
	local cRegra		:=	""
	local cProp			:=	""    
	local cQuery		:=  ""
	local cMsg 			:=  ""
	local nIdRegra 		:=  0
	local aSystemRules	:= {}
	Private xNode
	Private oNoUserConfig	 	
	// Extrai e grava lista de seguranca
	oTable := ::oOwner():oGetTable("REGRA")

	// Por questões de performance esta rotina não utiliza algumas funções
	// da biblioteca de funções de BI
	dbselectarea("BSC003")

	//Gravacao de propriedades personalizadas por ususario	

	if(cEntity == "ORGANIZACAO")

		oNoUserConfig 	:= &("oXMLInput:"+cPath+":_ORGANIZACOES:_SIS_CONFIGS") 
		if(cOwner == "U")
			aRegras	:=  ::oOwner():oGetTable("USUARIO"):faRegra
		else
			aRegras	:=	::oOwner():oGetTable("GRUPO"):faRegra
		endif

		nRegra := ascan(aRegras,{|x| x[1] ==  "ACESSOS_ORGA" })

		if(nRegra != 0)
			aSystemRules:= aRegras[nRegra][2]
			cRegra		:= aRegras[nRegra,1]

			for nProp = 1 to len(aSystemRules)
				cProp		:=	aSystemRules[nProp][1]
	        	cAtributo	:= strzero(nProp-1,3)
				if(valtype(& ("oNoUserConfig:_SIS_ACESSO:_" + cRegra + ":_POPE" + cAtributo ) )!="U" )
					nIDOperacao		:= nBIVal( &("oNoUserConfig:_SIS_ACESSO:_"+ cRegra + ":_POPE"+cAtributo+":TEXT") )
					lPermitida  	:= xBIConvTo("L", &("oNoUserConfig:_SIS_ACESSO:_"+ cRegra + ":_PRETVAL"+cAtributo+":TEXT"))
		          	nIdRegra		:= nBIVal( &("oNoUserConfig:_SIS_ACESSO:_"+ cRegra + ":_IDREGRA"+cAtributo+":TEXT") )
                                
                    if nIdRegra <> 0 
                    	cQuery:="DELETE FROM BSC003 WHERE ID = "+cBISTR(nIdRegra)
						TCSQLEXEC(cBIParseSQL(cQuery, @cMsg))
						TCREFRESH("BSC003")
					endif     
		
					//Por questões de performance esta rotina não utiliza a função
					//lAppend() da biblioteca de funções de BI.
			        BSC003->(dbappend())
					BSC003->ID			:= oTable:nMakeID()
					BSC003->PARENTID	:= 0
					BSC003->CONTEXTID	:= 0
					BSC003->OWNER		:= cOwner
					BSC003->IDOWNER		:= nIDOwner
					BSC003->ENTITY		:= cRegra
					BSC003->IDENT		:= nProp
					BSC003->IDOPERACAO	:= nIDOperacao
					BSC003->PERMITIDA	:= lPermitida
				endif
			next nProp				
		endif			
	endif		


	aEntidades := ::oOwner():faTables
	
	if(nPos:=ascan(aEntidades,{|x| x[3] == cEntity }))!=0 
		if(valtype(XmlChildEx(&("oXMLInput:"+cPath+if(valtype(nItem)=="N","["+cBISTR(nItem)+"]","")), "_"+aEntidades[nPos,2]))!="U")
			if(valtype(XmlChildEx(&("oXMLInput:"+cPath+if(valtype(nItem)=="N","["+cBISTR(nItem)+"]","")+":_"+aEntidades[nPos,2]), "_"+aEntidades[nPos,3]))!="U")
				cPath += if(valtype(nItem)=="N","["+cBISTR(nItem)+"]","")+":_"+aEntidades[nPos,2]+":_"+aEntidades[nPos,3]
				xNode := &("oXMLInput:"+cPath)

				if(valtype(xNode)=="A")
					for nJ := 1 to len(xNode)
						for nK := 1 to 999                                              
				        	cAtributo := strzero(nK-1,3)
							if(valtype(XmlChildEx(&("xNode["+alltrim(str(nJ))+"]"),"_POPE"+cAtributo ))!="U")
							
								nIDOperacao := nBIVal(&("xNode["+alltrim(str(nJ))+"]:_POPE"+cAtributo+":TEXT"))
								lPermitida  := xBIConvTo("L",&("xNode["+alltrim(str(nJ))+"]:_PRETVAL"+cAtributo+":TEXT"))
								nIdRegra	:= nBIVal(&("xNode["+alltrim(str(nJ))+"]:_IDREGRA"+cAtributo+":TEXT"))
                                
                                if nIdRegra <> 0 
                                	cQuery:="DELETE FROM BSC003 WHERE ID = "+cBISTR(nIdRegra)
									TCSQLEXEC(cBIParseSQL(cQuery, @cMsg))
									TCREFRESH("BSC003")
                                endif      
								
								// Por questões de performance esta rotina não utiliza a função
								// lAppend() da biblioteca de funções de BI
								BSC003->(dbappend())
//								if(BSC003->(rlock()))
									BSC003->ID			:= oTable:nMakeID()
									BSC003->PARENTID	:= 0
									BSC003->CONTEXTID	:= 0
									BSC003->OWNER		:= cOwner
									BSC003->IDOWNER		:= nIDOwner
									BSC003->ENTITY		:= xNode[nJ]:REALNAME
									BSC003->IDENT		:= nBIVal(&(xNode[nJ]:_ID:TEXT))
									BSC003->IDOPERACAO	:= nIDOperacao
									BSC003->PERMITIDA	:= lPermitida 
//								endif
							else
								exit
							endif
						next  

						for nI := 1 to len(aEntidades)
							if(aEntidades[nI,4]==cEntity)
								::GravaRegra(oXML, cPath, nIDOwner, cOwner, aEntidades[nI,3], nJ)
							endif
						next

					next

				elseif(valtype(xNode)=="O")

					for nK := 1 to 999                                              

				        cAtributo := strzero(nK-1,3)

						if(valtype(XmlChildEx(&("xNode"),"_POPE"+cAtributo ))!="U")
							nIDOperacao := nBIVal(&("xNode:_POPE"+cAtributo+":TEXT"))
							lPermitida  := xBIConvTo("L",&("xNode:_PRETVAL"+cAtributo+":TEXT"))
							nIdRegra	:= nBIVal(&("xNode:_IDREGRA"+cAtributo+":TEXT"))
                                
                            if nIdRegra <> 0 
                            	cQuery:="DELETE FROM BSC003 WHERE ID = "+cBISTR(nIdRegra)
								TCSQLEXEC(cBIParseSQL(cQuery, @cMsg))
								TCREFRESH("BSC003")
                            endif      

							// Por questões de performance esta rotina não utiliza a função
							// lAppend() da biblioteca de funções de BI
                            BSC003->(dbappend())
//							if(BSC003->(rlock()))
								BSC003->ID			:= oTable:nMakeID()
								BSC003->PARENTID	:= 0
								BSC003->CONTEXTID	:= 0
								BSC003->OWNER		:= cOwner
								BSC003->IDOWNER		:= nIDOwner
								BSC003->ENTITY		:= xNode:REALNAME
								BSC003->IDENT		:= nBIVal(&(xNode:_ID:TEXT))
								BSC003->IDOPERACAO	:= nIDOperacao
								BSC003->PERMITIDA	:= lPermitida
//							endif         
						else
							exit
						endif
					next  
					for nI := 1 to len(aEntidades)
						if(aEntidades[nI,4]==cEntity)
							::GravaRegra(oXML, cPath, nIDOwner, cOwner, aEntidades[nI,3])
						endif
					next 
		        endif   
		    endif
	    endif
	endif
	
return             

function _BSC003_Sec()
return ::New()