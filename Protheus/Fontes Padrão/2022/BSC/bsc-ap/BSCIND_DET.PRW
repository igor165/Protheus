// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSCPERSP_DD.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 13.03.07 | 1776 Alexandre Silva
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSCIND_DET.ch"
/*--------------------------------------------------------------------------------------
@class TBSCIND_DET
@entity MAPAEST2
Detalhe do indicador
@table Nao existe tabela associada a esta entidade.
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "INDICADOR_DET"
#define TAG_GROUP  "INDICADORES_DET"
#define TEXT_ENTITY STR0001/*//"Indicador Detalhe"*/
#define TEXT_GROUP  STR0002/*//"Indicador Detalhes"*/

class TBSCIND_DET from TBITable
	data aUptItens 

	method New() constructor
	method NewBSCIND_DET()

	method oToXMLNode(nID, cLoadCMD)
	method oInsIndicador(oXMLNode, nIndID)
	method oInsIniciativa(oXMLNode, nObjID)
	method lAddIndicador(cIdInd,oXMLColunas,lMesExtenso)
	method cSetLabelX(nFrequencia,oPlaValor,lMesExtenso)
	method nUpdFromXML(oXML, cPath)
		
endclass

method New() class TBSCIND_DET
	::NewBSCIND_DET()
return

method NewBSCIND_DET() class TBSCIND_DET
	// Table
	::cEntity(TAG_ENTITY)
	//Inicializando a propriedade referente as propriedades para este objeto.
	::aUptItens := {;
					"INDICADOR_DET_TIPO_GRAPH"		,;
					"INDICADOR_DET_COR_GRAPH"		,;
					"INDICADOR_DET_POS_DIV_VER"		,;
					"INDICADOR_DET_POS_DIV_GRAPLA"	,;
					"INDICADOR_DET_POS_DIV_OBJINI"	,;
					"INDICADOR_DET_LIN_SEL"	,;
					}
return

// Carregar
method oToXMLNode(nID, cLoadCMD) class TBSCIND_DET
	local oXMLNode 		:= 	TBIXMLNode():New(TAG_ENTITY)
	local oUserCofig	:= ::oOwner():oGetTable("DESKTOP")   
    local oXMLProp		:=	TBIXMLNode():New("PROPRIEDADES")
	local oNodeProp		:=	oUserCofig:oToXMLNode(nID,::aUptItens)

	//Adicionando o no de planilha ao no principal.
	oXMLNode:oAddChild(::oInsIndicador(@oXMLNode,nID,oNodeProp))

	//Adicionando as propriedades de visualizacao da tela.
	oXMLProp:oAddChild(oNodeProp)
	oXMLNode:oAddChild(oXMLProp)	
	
return oXMLNode

/*----------------------------------------------------------------------------------
Adiciona os valores ao XML, que serão usados na montagem do gráfico e da planilha de dados.
----------------------------------------------------------------------------------------*/
method oInsIndicador(oXMLNode, nIndID, oNodeProp) class TBSCIND_DET
	local oIndicador	:= 	::oOwner():oGetTable("INDICADOR")
	local oObjetivo		:=	::oOwner():oGetTable("OBJETIVO")
	local oAttrib		:= 	TBIXMLAttrib():New()
	local oXMLColunas	:=	TBIXMLNode():New("COLUNAS",,oAttrib)
	local cObjNome		:=	""
	local cObjDesc		:=	""
	local nLinVisivel	:= ascan(oNodeProp:FACHILDREN,{|x| x:FCTAGNAME ==  "INDICADOR_DET_LIN_SEL" })//Localiza o item no array.
	local cLinVisivel	:=	"" 
	local oCard			:= nil
	local dDataAlvo	:= nil
	local lParcelada:= nil	
	
	if(nLinVisivel > 0)
		cLinVisivel	:= oNodeProp:FACHILDREN[nLinVisivel]:FCVALUE
	endif

	//Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	
	//Selecionar grafico
	oAttrib:lSet("TAG000", "VER_GRAFICO")
	oAttrib:lSet("CAB000", STR0015) //"Ver no grafico"
	oAttrib:lSet("CLA000", BSC_BOOLEAN)
	oAttrib:lSet("EDT000", .t.)	
	oAttrib:lSet("CUM000", .f.)		

	//Periodo
	oAttrib:lSet("TAG001", "LABELX")
	oAttrib:lSet("CAB001", STR0012) //"Período"
	oAttrib:lSet("CLA001", BSC_STRING)
	
	//Valor
	oAttrib:lSet("TAG002", "VALOR")
	oAttrib:lSet("CAB002", STR0013) //"Valor"
	oAttrib:lSet("CLA002", BSC_FLOAT)

	//Montante
	oAttrib:lSet("TAG003", "MONTANTE")
	oAttrib:lSet("CAB003", STR0014) //"Montante"
	oAttrib:lSet("CLA003", BSC_FLOAT)

	//Adicionando as linhas para planilha e grafico.	
	if ( nIndID !=0 .and. oIndicador:lSeek(1,{nIndID}))
		::lAddIndicador(nIndID,@oXMLColunas,.f.,cLinVisivel)
		oXMLNode:oAddChild(TBIXMLNode():New("IND_NOME"	, oIndicador:cValue("NOME")))//"Indicador"
		oXMLNode:oAddChild(TBIXMLNode():New("INDICADOR"	, oIndicador:cValue("ID")))	//Id do Indicador
		
		dDataAlvo := ::oOwner():xSessionValue("DATAALVO")
		if(valtype(dDataAlvo)=="U")
			dDataAlvo := date()
		endif
		
		lParcelada := ::oOwner():xSessionValue("PARCELADA")
		if(empty(lParcelada))
			lParcelada := .f.
		endif
		
		//Adicionando dados do objetivo.
		if(oObjetivo:lSeek(1,{oIndicador:nValue("PARENTID")}))	
			cObjNome	:=	oObjetivo:cValue("NOME")
			cObjDesc	:=	oObjetivo:cValue("DESCRICAO")
			oCard  		:=	oObjetivo:oMakeCard(dDataAlvo,lParcelada)				
		endif       
		
		oXMLNode:oAddChild(TBIXMLNode():New("FAROL",oCard:FNFEEDBACK))
		oXMLNode:oAddChild(TBIXMLNode():New("OBJETIVO",cObjNome ))//Nome do objetivo
		oXMLNode:oAddChild(TBIXMLNode():New("OBJDESC", cObjDesc))	//Descrição do ojetivo

		//Adicinando dados das iniciativas.
		oXMLNode:oAddChild(::oInsIniciativa(oObjetivo:nValue("ID")))
	endif		

return oXMLColunas

/*--------------------------------------------------------------------------------------
Metodo para inclusao das iniciativas
@param nObjID 			- ID da entidade.
----------------------------------------------------------------------------------------*/
method oInsIniciativa(nObjID) class TBSCIND_DET
	local oIniciativa		:=	::oOwner():oGetTable("INICIATIVA")
	local oXMLIniciativas	:=	oIniciativa:oToXMLList(nObjID)
	
return	oXMLIniciativas

/*-------------------------------------------------------------------------------------
Adiciona o indicador requisitado
@param cIdInd 			- ID da entidade.
@param oXMLPlanilha 	- XML onde sera adicionado, o indicador atual.
@param aPeriodo 		- Data de analise do indicador.
@return 				- status do processamento.
--------------------------------------------------------------------------------------*/
method lAddIndicador(nIndID,oXMLColunas,lMesExtenso,cLinVisivel)  class TBSCIND_DET
	local oPlaValor		:= ::oOwner():oGetTable("PLANILHA")
	local oIndicador	:= ::oOwner():oGetTable("INDICADOR")  
	local oEstrategia	:= ::oOwner():oGetTable("ESTRATEGIA")
	local aDataDe		:= {}
	local aDataAte		:= {}
	local nValor		:= 0,	nTotValor	:=	0
	local nMontante		:= 0,	nTotMontante:=	0
	local nCounLine		:= 0
	local cSqlCMD		:= ""
	local oNodeColuna	:= nil	
	local cTipoDB 		:= upper(tcgetdb())	
	local lShowLine		:=.t.
	

	if(oEstrategia:lSeek(1,{oIndicador:nValue("CONTEXTID")}))
		aDataDe	:=	oPlaValor:aDateConv(oEstrategia:dValue("DATAINI"), oIndicador:nValue("FREQ"))
		aDataAte:=	oPlaValor:aDateConv(oEstrategia:dValue("DATAFIN"), oIndicador:nValue("FREQ"))
		
		if(cTipoDB == "DB2")
			cSqlCMD +=	"PARENTID = " + cBIStr(nIndID) + " and "
			cSqlCMD +=	"ANO||MES||DIA >= '" + aDataDe[01] 	+ aDataDe[02] 	+ aDataDe[03] 	+ "' and "	
			cSqlCMD +=	"ANO||MES||DIA <= '" + aDataAte[01] + aDataAte[02] 	+ aDataAte[03] 	+ "' and "	
			cSqlCMD +=	"D_E_L_E_T_ <> '*'"			
		else
			cSqlCMD +=	"PARENTID = " + cBIStr(nIndID) + " and "
			cSqlCMD +=	"ANO+MES+DIA >= '" + aDataDe[01] 	+ aDataDe[02] 	+ aDataDe[03] 	+ "' and "	
			cSqlCMD +=	"ANO+MES+DIA <= '" + aDataAte[01] 	+ aDataAte[02] 	+ aDataAte[03] 	+ "' and "	
			cSqlCMD +=	"D_E_L_E_T_ <> '*'"
		endif
		
		oPlaValor:cSQLFilter(cSqlCMD) 
		oPlaValor:lFiltered(.t.)
		oPlaValor:_First()
		
		while(!oPlaValor:lEof())
			nCounLine++
			lShowLine := .t.
			oNodeColuna:= TBIXMLNode():New("COLUNA")//Cria um nova linha
			
			nValor 		:= oPlaValor:nValue("PARCELA")
			nMontante	:= oPlaValor:nValue("MONTANTE")
			if len(cLinVisivel) >= nCounLine .and. substr(cLinVisivel,nCounLine,1) == "F"
				lShowLine := .f.	
			endif
			oNodeColuna:oAddChild(TBIXMLNode():New("VER_GRAFICO",lShowLine))
			oNodeColuna:oAddChild(TBIXMLNode():New("DECIMAIS"	,oIndicador:nValue("DECIMAIS")))
			oNodeColuna:oAddChild(TBIXMLNode():New("VALOR"		,nValor))
			oNodeColuna:oAddChild(TBIXMLNode():New("MONTANTE"	,nMontante))
			oNodeColuna:oAddChild(TBIXMLNode():New("LABELX"		,::cSetLabelX(oIndicador:nValue("FREQ"),oPlaValor,lMesExtenso)))
	
			//Acumulando o valor total.
			nTotValor	+=	nValor 
			nTotMontante+=	nMontante
	
			oPlaValor:_Next()
			oXMLColunas:oAddChild(oNodeColuna)//Adicina a linha ao no principal
			
		end while
	
		oPlaValor:cSQLFilter("")	
		
		//Adicina a linha ao no principal
		if(oNodeColuna != nil)
			oXMLColunas:oAddChild(oNodeColuna)
		endif			
	endif	
	
return .t.

method cSetLabelX(nFrequencia,oPlaValor,lMesExtenso)  class TBSCIND_DET
	local cLabelX := ""
	local dData		
	do case
		case nFrequencia == BSC_FREQ_DIARIA
			dData	:= cTod(oPlaValor:cValue("DIA")+ "/" + oPlaValor:cValue("MES") + "/"+ oPlaValor:cValue("ANO"))
			cLabelX := dtoC(dData)
		case nFrequencia == BSC_FREQ_SEMANAL//Semana
			cLabelX := oPlaValor:cValue("MES") + STR0005+ oPlaValor:cValue("ANO") //" semana de "
		case nFrequencia == BSC_FREQ_QUINZENAL//Quinzena
			cLabelX	:= oPlaValor:cValue("DIA")+ STR0006 + oPlaValor:cValue("MES") + STR0007+ oPlaValor:cValue("ANO") //" quinzena de "###" de "
		case nFrequencia == BSC_FREQ_MENSAL//Meses
			if(lMesExtenso)
				cLabelX	:=	MesExtenso(oPlaValor:nValue("MES")) + STR0007+ oPlaValor:cValue("ANO") //" de "
			else
				cLabelX	:=	strzero(oPlaValor:nValue("MES"),2) + "/" + oPlaValor:cValue("ANO") //
			endif				
		case nFrequencia == BSC_FREQ_BIMESTRAL//Bimestre
			cLabelX := oPlaValor:cValue("MES") + STR0008+ oPlaValor:cValue("ANO") //" bimestre de "
		case nFrequencia == BSC_FREQ_TRIMESTRAL//Trimestre
			cLabelX := oPlaValor:cValue("MES") + STR0009+ oPlaValor:cValue("ANO") //" trimestre de "
		case nFrequencia == BSC_FREQ_QUADRIMESTRAL//Quadrimestre
			cLabelX := oPlaValor:cValue("MES") + STR0010+ oPlaValor:cValue("ANO") //" quadrimestre de "
		case nFrequencia == BSC_FREQ_SEMESTRAL//Semestre
			cLabelX := oPlaValor:cValue("MES") + STR0011+ oPlaValor:cValue("ANO") //" semestre de "
		case nFrequencia == BSC_FREQ_ANUAL//Ano
			cLabelX := oPlaValor:cValue("ANO")
	endcase
	
return cLabelX	

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TBSCIND_DET
	local nStatus 		:= BSC_ST_OK
	local oUserCofig	:= ::oOwner():oGetTable("DESKTOP")   

	//Gravando os valores
	nStatus := oUserCofig:nUpdFromXML(oXML, cPath, ::aUptItens)
	
return nStatus  
                                                     
function _BSCInd_Det()
return