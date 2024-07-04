// ######################################################################################
// Projeto: BSC
// Modulo : BSC070_AreTra 
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.09-04 | 1776 Alexandre Silva 
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC070_AreTra.ch"
/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIEvtObject->TBIDataSet->TBITable->TBSC070
Criacao da classe de area de trabalho
@entity: Desktop
@table BSC070
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "DESKTOP"
#define TAG_GROUP  "DESKTOPS"
#define TEXT_ENTITY STR0001/*//"Desktop"*/
#define TEXT_GROUP  STR0002/*//"Desktops"*/

class TBSC070 from TBITable
	data cPessoas  //Codigo das pessoas
	data cNomeUsu  //Nome do usuario atual
	data aDeskProp //Propriedades default
	data aCmbItens //Itens que aparecerao na combo de organizacao estratégia.
	data aPesUsua  //Pessoas do usuario.	
	data nUsuAtual //Usuario atual
	data nEstAtual //Estrategia atual
	data nOrgAtual //Organzacao atual

	method New() constructor
	method NewBSC070()

	// diversos registros
	method oArvore()

	//Registro Unico
	method oToXMLNode()

	//Lista
	method oXMLListOrgEst()	
	
	//Gravacao
	method nUpdFromXML(oXML, cPath)

	//Nos Principais
	method incEstrategia(oNode)//Inclui as estrategias
	method incMensagem(oNode)//Inclui as mensagens
	method incObrigacao(oNode)//Inclui as obrigacoes
	method incResponsabilidade(oNode)//Inclui as resposabilidades
//	method incUtilidades(oNode) //Inclui as utilidades

	//Nos Auxiliares
	method incTarefa(oNodeObrig)//Inclui as tarefas
	method incReuniao(oNodeObrig)//Inclui as reunioes
	method incColeta(oNodeObrig)//Inclui as coletas
	method incObjetivos(oNodeResp) //Inclui os objetivos de responsabilidades da pessoa.
	method incIndicadores(oNodeResp) //Inclui os indicadores de responsabilidades da pessoa.
	method incRespItem(oNodeParent,oTable,cMainTag,cFiltro,aPropNode)
	method incMapaEst(oNodeParent)
		
endclass
	
method New() class TBSC070
	::NewBSC070()
return

method NewBSC070() class TBSC070
	// Tabela
	::NewTable("BSC070")
	::cEntity(TAG_ENTITY)

	// Campos
	::addField(TBIField():New("ID"				,"N"))
	::addField(TBIField():New("PARENTID"		,"N"))
	::addField(TBIField():New("CONTEXTID"		,"N"))
	::addField(TBIField():New("USUARIOID"		,"N"))
	::addField(TBIField():New("ATRIBUTO"		,"C",060))
	::addField(TBIField():New("VALATRIB"		,"C",255))

	// Indices
	::addIndex(TBIIndex():New("BSC070I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC070I02",	{"USUARIOID","ATRIBUTO","PARENTID"},.t.))

	//Arrays
	::aDeskProp := {;	
						{"DESKVIEWTYPE"	,"1"},;//1 - Vizao em janelas selecionada
						{"ORGVIEWTYPE"	,"1"},;//1 - Vizao em janelas selecionada
						{"USERVIEWTYPE"	,"1"},;//1 - Vizao em janelas selecionada
						{"INDICADOR_DET_TIPO_GRAPH"		,"2"},;//Tipo do grafico
						{"INDICADOR_DET_COR_GRAPH"		,"-12594"},;//Cor do grafico
						{"INDICADOR_DET_POS_DIV_VER"	,"260"},;//Posicao do split.
						{"INDICADOR_DET_POS_DIV_GRAPLA"	,"76"},;//Posicao do split.
						{"INDICADOR_DET_POS_DIV_OBJINI"	,"60"},;//Posicao do split.
						{"INDICADOR_DET_LIN_SEL"		,""};//Grava se a linha do grafico deve ser exibida.
					}                         

return

/*----------------------------------------------------------------------------------------------
Carrega as propriedades requisitadas.
Paremeters = aListLoad - Lista da propriedades que devem ser carregadas.
Return = oXMLNode - XML com as propriedades requisitadas;
-----------------------------------------------------------------------------------------------*/
method oToXMLNode(nParentID,aListLoad) class TBSC070
	local oXMLNode 		:=	TBIXMLNode():New(TAG_ENTITY)
	local cProp			:=	""
	local nIndProp 		:=	0	

	default nParentID	:=	0
	default aListLoad := {"DESKVIEWTYPE","ORGVIEWTYPE","USERVIEWTYPE"}
	
	::nUsuAtual	:= ::oOwner():foSecurity:oLoggedUser():nValue("ID")
	//Se nao existir carrega os registros defaults.
	for nIndProp := 1 to len(::aDeskProp)
		cProp := ::aDeskProp[nIndProp,1]
		//Verifica se o item atual deve ser atualizado.
		if(cProp != nil .and. ascan(aListLoad,cProp) > 0)
			if ::lSeek(2,{::nUsuAtual,::aDeskProp[nIndProp,1],nParentID})
				oXMLNode:oAddChild(TBIXMLNode():New(::aDeskProp[nIndProp,1],Alltrim(::cValue("VALATRIB")) ))
			else
				//Retorna a propriedade padrao quando nao a encontra no banco
				oXMLNode:oAddChild(TBIXMLNode():New(Alltrim(::aDeskProp[nIndProp,1]),Alltrim(::aDeskProp[nIndProp,2])))
			endif
		endif			
	next nIndProp

	oXMLNode:oAddChild(TBIXMLNode():New("ID"		,0	))
	oXMLNode:oAddChild(TBIXMLNode():New("CONTEXTID"	,0	))
	oXMLNode:oAddChild(TBIXMLNode():New("PARENTID"	,nParentID))

return oXMLNode

/*--------------------------------------------------------------------------------------------------
Atualiza as propriedades, requisitadas.
Parameters: oXML 		= No com os dados para serem atualizadas
			cPath 		= Caminho para acessar o XML.
			aLstItens   = Lista com os itens para serem atualizados.
Return 		nStatus		= Resultado da atualização.			
--------------------------------------------------------------------------------------------------*/
method nUpdFromXML(oXML, cPath, aLstItens) class TBSC070
	local nStatus 	:= 	BSC_ST_OK,nInd,nProp, nPosID
	local nPosParent:=	0
	local cProp := ""	
	
	private oXMLInput := oXML
	default aLstItens := {"DESKVIEWTYPE","ORGVIEWTYPE","USERVIEWTYPE"}//Lista dos itens que devem ser atualizados.

	aFields 	:= ::xRecord(RF_ARRAY, {})
	nPosID		:= ascan(aFields,{|x| x[1] == "ID"})
	nPosParent	:= ascan(aFields,{|x| x[1] == "PARENTID"})

	for nProp := 1 to len(::aDeskProp)
		cProp := ::aDeskProp[nProp,1]
		//Verifica se o item atual deve ser atualizado.
		if(cProp != nil .and. ascan(aLstItens,cProp) > 0)
			// Extrai valores do XML                     
			for nInd := 1 to len(aFields)
				if(aFields[nInd][1] == "USUARIOID")
					aFields[nInd][2] := ::nUsuAtual
				elseif(aFields[nInd][1] == "ATRIBUTO" )
					aFields[nInd][2] := cProp 
				elseif(aFields[nInd][1] == "VALATRIB" )
					aFields[nInd][2] :=	 &("oXMLInput:"+cPath+":_" + ::aDeskProp[nProp,1] + ":TEXT")
				elseif(aFields[nInd][1] == "ID" .or. aFields[nInd][1] == "CONTEXTID")
					//O ID sera acerto em baixo.
				else
					cType := ::aFields(aFields[nInd][1]):cType()
					aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
				endif	
			next nInd
			
			//Verificar se a propriedade ja existe.
			if(!::lSeek(2, {::nUsuAtual,::aDeskProp[nProp,1],aFields[nPosParent][2]}))
				aFields[nPosID,2] := ::nMakeID()
				// Grava
				if(!::lAppend(aFields))
					if(::nLastError()==DBERROR_UNIQUE)
						nStatus := BSC_ST_UNIQUE
					else
						nStatus := BSC_ST_INUSE
					endif
				endif
			else
				//Altera
				aFields[nPosID,2] := ::nValue("ID")
				if(!::lUpdate(aFields))
					if(::nLastError()==DBERROR_UNIQUE)
						nStatus := BSC_ST_UNIQUE
					else
						nStatus := BSC_ST_INUSE
					endif
				endif	 
			endif
	    endif
    Next nProp

return nStatus

// Arvore
method oArvore() class TBSC070
	local oXMLArvore, oNode,oAttrib,nEst
	local oPessoa		:= ::oOwner():oGetTable("PESSOA")
	local oOrganizacao 	:= ::oOwner():oGetTable("ORGANIZACAO")
	local nOrgKey		:= 0    
	local aPessoas		:= {}
	::aPesUsua			:= {}
	::aCmbItens 		:= {}	
	::nUsuAtual			:= ::oOwner():foSecurity:oLoggedUser():nValue("ID")
	::cNomeUsu			:= alltrim(::oOwner():foSecurity:oLoggedUser():cValue("NOME"))
	
	::cPessoas			:= ""

	// Organizações
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", 1)
	oAttrib:lSet("TIPO", "ORGANIZACOES")
	oAttrib:lSet("NOME", STR0003) //"Área de trabalho"
	oXMLArvore := TBIXMLNode():New("ORGANIZACOES","",oAttrib)
	
	//Ler as organizacoes
	oOrganizacao:SetOrder(2)// Alfabetica por nomes
	oOrganizacao:_First() // Não filtra organizações

	while(!oOrganizacao:lEof())
		::nOrgAtual := oOrganizacao:nValue("ID")		

		// Nao lista o ID 0, de inclusao
		if(oOrganizacao:nValue("ID")==0)
			oOrganizacao:_Next()
			loop
		endif			

		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", oOrganizacao:nValue("ID"))
		oAttrib:lSet("NOME", alltrim(oOrganizacao:cValue("NOME")))
		oNode := TBIXMLNode():New("ORGANIZACAO","",oAttrib)

		//Adicionar todas as pessoas da organização relacionado ao usuário logado.
		oPessoa:SetOrder(4)
		oPessoa:lSeek(4, {::nUsuAtual})
		
		//Reinicia as variáveis a cada troca de organização.
		::aPesUsua	:= {}
		aPessoas 	:= {}
		
		while(!oPessoa:lEof() .And. oPessoa:nValue("USERID") == ::nUsuAtual )
  			if oPessoa:nValue("PARENTID") == ::nOrgAtual
				// Nao lista o ID 0, de inclusao
				if(oPessoa:nValue("ID")==0)
					oPessoa:_Next()
					loop
				endif			
				
				aadd(::aPesUsua,{oPessoa:nValue("ID"),	oPessoa:cValue("NOME")})
				aadd(aPessoas,oPessoa:nValue("ID"))
			EndIf
			oPessoa:_Next()
		enddo                     
		::cPessoas := "("+	cBIConcatMacro(",", aPessoas ) + ")"
		
		::incEstrategia(oNode)
		
		//Se a organizacao nao esta vazia adiciona.
		if(len(oNode:FACHILDREN) > 0)
			oXMLArvore:oAddChild(oNode)
			//Carregamento dos itens para a "ComboBox"	
			for nEst := 1 to len(oNode:FACHILDREN[1]:FACHILDREN)
				if len(oNode:FACHILDREN[1]:FACHILDREN[nEst]:FACHILDREN[1]:FACHILDREN[1]:FACHILDREN) > 0
					aadd(::aCmbItens,{alltrim(str(nOrgKey)) + "|" + alltrim(str(nEst-1)),;
							+ "(" + alltrim(oOrganizacao:cValue("NOME"))+ ") " +;
							alltrim(oNode:FACHILDREN[1]:FACHILDREN[nEst]:FOATTRIB:FAFIELDS[2][2])})
				endif								
			next nEst					
			nOrgKey++
		endif				

		oOrganizacao:_Next()

	enddo

return oXMLArvore

//Lista das Organizacoes e estrategias
method oXMLListOrgEst() class TBSC070
	local oAttrib, oNode, oXMLOutput
	local nInd 

	// Atributos
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("RETORNA", .F.)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("CMBFILTROS",,oAttrib)
	
	for nInd := 1 to len(::aCmbItens)
		oNode := oXMLOutput:oAddChild(TBIXMLNode():New("CMBFILTRO"))
		oNode:oAddChild(TBIXMLNode():New("ID", 		::aCmbItens[nInd,1]))
		oNode:oAddChild(TBIXMLNode():New("NOME", 	::aCmbItens[nInd,2]))
	next
	
return oXMLOutput

//Inclui o no de mensagens
method incMensagem(oNode) class TBSC070
	Local oAttrib, oNodeMsg
	  
	//No de Mensagens
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", 0)
	oAttrib:lSet("TIPO", "DESKMENSAGENS")
	oAttrib:lSet("NOME", STR0013)//Mensagens
	oNodeMsg := TBIXMLNode():New("DESKMENSAGENS","",oAttrib)
	
	//Caixa de entrada
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", ::nOrgAtual)
	oAttrib:lSet("NOME", STR0017) //"Caixa de Entrada"
	oNodeEntrada :=  oNodeMsg:oAddChild(TBIXMLNode():New("MENSAGENS_RECEBIDAS", "", oAttrib))

	//Itens Enviados
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", ::nOrgAtual)
	oAttrib:lSet("NOME", STR0018) //"Itens Enviados"
	oNodeEnviados :=  oNodeMsg:oAddChild(TBIXMLNode():New("MENSAGENS_ENVIADAS", "", oAttrib))

	//Itens Excluidos
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", ::nOrgAtual)
	oAttrib:lSet("NOME", STR0019) //"Itens Excluídos"
	oNodeExcluidos :=  oNodeMsg:oAddChild(TBIXMLNode():New("MENSAGENS_EXCLUIDAS", "", oAttrib))

	oNode:oAddChild(oNodeMsg)

return .T. 

//Usado para incluir as estrategias
method incEstrategia(oNode) class TBSC070
	local oNode,oNodeUsa, oNodeDeskTop, oNodeDeskItem
	local oEstrategia, oNodeEstrategia, oNodeEstItem
	local nUsu := 0 ,lNew := .T.

	oEstrategia := ::oOwner():oGetTable("ESTRATEGIA")

	oEstrategia:SetOrder(2) // Alfabetica por nomes
	oEstrategia:cSqlFilter("PARENTID = " + cBIStr(::nOrgAtual)) // Filtra pelo pai
	oEstrategia:lFiltered(.t.)
	oEstrategia:_First()

	// Nodes
	while(!oEstrategia:lEof())
		lAcessaEstrategia := ::oOwner():foSecurity:lHasAccess("ESTRATEGIA", oEstrategia:nValue("ID"), "CARREGAR")
		if(lAcessaEstrategia)
 			if lNew
				// Tag conjunto
				oAttrib := TBIXMLAttrib():New()
				oAttrib:lSet("ID", 1)
				oAttrib:lSet("TIPO", "ESTRATEGIAS")
				oAttrib:lSet("NOME", STR0014)//Estrategia
				oNodeEstrategia := TBIXMLNode():New("ESTRATEGIAS","",oAttrib)
				lNew := .F.
			endif			

			::nEstAtual  := oEstrategia:nValue("ID")

			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", oEstrategia:nValue("ID"))
			oAttrib:lSet("NOME", alltrim(oEstrategia:cValue("NOME")))/*//"Nome"*/
			oNodeEstItem :=	oNodeEstrategia:oAddChild(TBIXMLNode():New("ESTRATEGIA", "", oAttrib))

			//Criacao das desktops
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", 1)
			oAttrib:lSet("TIPO", "DESKTOPS")
			oAttrib:lSet("NOME", "Balanced Scorecard")
			oNodeDeskTop := TBIXMLNode():New("DESKTOPS","",oAttrib)
							
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", 1)
			oAttrib:lSet("NOME", STR0003)/*//"Area de trabalho"*/
			oNodeDeskItem := oNodeDeskTop:oAddChild(TBIXMLNode():New("DESKTOP", "", oAttrib))
			
			//Adicionando o no com os usuarios.
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", 1)
			oAttrib:lSet("NOME", STR0015 + ::cNomeUsu + ")")/*"Pessoas ("*/
			oNodeUsa := oNodeDeskTop:oAddChild(TBIXMLNode():New("PESSOAS", "", oAttrib))
	
			for nUsu := 1 to len(::aPesUsua)
				oAttrib := TBIXMLAttrib():New()
				oAttrib:lSet("ID", ::aPesUsua[nUsu,1])
				oAttrib:lSet("TIPO","PESSOA")		
				oAttrib:lSet("NOME",::aPesUsua[nUsu,2])/*//"Nome"*/
				oNodeUsa:oAddChild(TBIXMLNode():New("PESSOA"+alltrim(str(::aPesUsua[nUsu,1])), "", oAttrib))
			next nUsu			
	
			//Carregando os dados de cada desktop;
			::incMensagem(oNodeDeskItem)
			::incObrigacao(oNodeDeskItem)
			::incResponsabilidade(oNodeDeskItem)
	//		::incUtilidades(oNodeDeskItem)
	//		::incConfiguracao(oNodeDeskItem)
			
			oNodeEstItem:oAddChild(oNodeDeskTop)
		endif				
		oEstrategia:_Next()	
	enddo

	oEstrategia:cSQLFilter("") // Encerra filtro

	if valtype(oNodeEstrategia)=="O"
		oNode:oAddChild(oNodeEstrategia)
	endif

return .T.

//Inclui o no de obrigacoes
method incObrigacao(oNode) class TBSC070
	Local oNodeObrig, oAttrib
	
	//No de Mensagens
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", 1)
	oAttrib:lSet("TIPO", "OBRIGACOES")
	oAttrib:lSet("NOME", STR0004) //"Obrigações"

	oNodeObrig := TBIXMLNode():New("OBRIGACOES","",oAttrib)
	::incTarefa(oNodeObrig)
	::incReuniao(oNodeObrig)
	::incColeta(oNodeObrig)

	//So adiciona se houverem sub itens
	if len(oNodeObrig:FACHILDREN)	> 0
		oNode:oAddChild(oNodeObrig)
	endif		

return .T.

//Inclui as tarefas                        
method incTarefa(oNodeObrig) class TBSC070
	local oNodeTarefa, oNodeTmp
	local tmpTarefas	:= {}     
	local nItem			:=	0
	local oTarCob 		:= ::oOwner():oGetTable("TARCOB")	
	local oTarefa 		:= ::oOwner():oGetTable("TAREFA")	

	//Ordem pessoa
	oTarCob:SetOrder(4)
	oTarCob:cSQLFilter("PESSOAID IN " + ::cPessoas + " and CONTEXTID = " +;
	  									cBIStr(::nEstAtual) ) // Filtra pelo pai
	oTarCob:lFiltered(.t.)
	oTarCob:_First()

	while(!oTarCob:lEof()) 
	   
		// Nao lista o ID 0, de inclusao
		if(oTarCob:nValue("ID")==0)
			oTarCob:_Next()
			loop
		endif			
		
		//Adicionando a tarefa
		if oTarefa:lSeek(1,{oTarCob:nValue("PARENTID")})		
			aadd(tmpTarefas, {oTarefa:nValue("ID"),oTarefa:dValue("DATAFIN"),oTarefa:cValue("NOME")})
	   	endif
		
		oTarCob:_Next()
	enddo

	oTarCob:cSQLFilter("")

	if len(tmpTarefas) > 0
		//Ordenando por data
		asort(tmpTarefas,,,{|x,y| x[2] < y[2]})

		//No de Tarefas
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", 1)
		oAttrib:lSet("NOME",STR0010)//"Tarefas" 
		oNodeTarefa := TBIXMLNode():New("TAREFAS","",oAttrib)		

		for nItem := 1 to len(tmpTarefas)	
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", tmpTarefas[nItem,1])
			oAttrib:lSet("TIPO", "TAREFA")
			oAttrib:lSet("NOME", tmpTarefas[nItem,3])
			oNodeTarefa:oAddChild(TBIXMLNode():New("TAREFA"+alltrim(str(tmpTarefas[nItem,1])),"",oAttrib))
		next nItem

		oNodeObrig:oAddChild(oNodeTarefa)		

	endif
return .T.

//Inclui as tarefas                        
method incReuniao(oNodeObrig) class TBSC070
	local nItem	:= 0
	local tmpReunioes := {}
	local oNodeReuniao
	local oPesCon 	:= ::oOwner():oGetTable("REUCON")	
	local oReunicao	:= ::oOwner():oGetTable("REUNIAO")	

	//Ordem de pessoa
	oPesCon:SetOrder(4)
	oPesCon:cSQLFilter("PESSOAID IN " + ::cPessoas) 
	oPesCon:lFiltered(.t.)
	oPesCon:_First()

	while( ! oPesCon:lEof()) 
	   
		// Nao lista o ID 0, de inclusao
		if(oPesCon:nValue("ID")==0)
			oPesCon:_Next()
			loop
		endif			
		
		//Adicionando a tarefa
		if oReunicao:lSeek(1,{oPesCon:nValue("PARENTID")});
				.And. oReunicao:nValue("PARENTID")	== ::nOrgAtual
			aadd(tmpReunioes,{oReunicao:nValue("ID"),oReunicao:dValue("DATAREU"),oReunicao:cValue("NOME")})										   	
	   	endif
		
		oPesCon:_Next()
	enddo

	oPesCon:cSQLFilter("")

	//No de Reunioes
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", 1)
	oAttrib:lSet("NOME", STR0005) //"Reuniões"
	oNodeReuniao := TBIXMLNode():New("REUNIOES","",oAttrib)		

	for nItem := 1 to len(tmpReunioes)	
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", tmpReunioes[nItem,1])
		oAttrib:lSet("TIPO", "REUNIAO")
		oAttrib:lSet("NOME", tmpReunioes[nItem,3])
		oNodeReuniao:oAddChild(TBIXMLNode():New("REUNIAO"+alltrim(str(tmpReunioes[nItem,1])),"",oAttrib))
	next nItem

	if len(tmpReunioes) > 0
 		oNodeObrig:oAddChild(oNodeReuniao)		
	endif 		

Return .T.

//Inclui as tarefas                        
method incColeta(oNodeObrig) class TBSC070
	local oNodeColeta,oNodeFreq,nItem,oFrequencia, lAddIndicador := .F.
	local oIndicador := ::oOwner():oGetTable("INDICADOR")	
	local nOrdem := 0 

    //Lendo os periodos para serem adicionados com itens dos nos		
	oFrequencia	:= oIndicador:oXMLFrequencia()

	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", 1)
	oAttrib:lSet("NOME", STR0006) //"Coletas"
	oNodeColeta := TBIXMLNode():New("COLETAS","",oAttrib)		

	for nItem :=len(oFrequencia:FACHILDREN) to 1 step -1
		nOrdem++
		cFreqCod 	:= oFrequencia:FACHILDREN[nItem]:FACHILDREN[1]:FCVALUE
		cFreqNome 	:= oFrequencia:FACHILDREN[nItem]:FACHILDREN[2]:FCVALUE
		                                                                      
		oIndicador:cSQLFilter("MEDRESPID IN " + ::cPessoas + " and FREQ = " +  cFreqCod;
												+ " and CONTEXTID = " +  cBIStr(::nEstAtual))
		oIndicador:lFiltered(.t.)
		oIndicador:_First()

		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", cFreqCod)
		oAttrib:lSet("NOME", alltrim(cFreqNome))                                  

		oNodeFreq := TBIXMLNode():New("COLETA"+str(nOrdem,1),"",oAttrib)		

		while(! oIndicador:lEof()) 
		    lAddIndicador := .T. 
	
			// Nao lista o ID 0, de inclusao
			if(oIndicador:nValue("ID")==0)
				oIndicador:_Next()
				loop
			endif			
		    
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", oIndicador:nValue("ID"))
			oAttrib:lSet("NOME", oIndicador:cValue("NOME"))
			oAttrib:lSet("TIPOIND", alltrim(oIndicador:cValue("TIPOIND")))
			oNodeFreq:oAddChild(TBIXMLNode():New("INDICADOR","",oAttrib))

			oIndicador:_Next()
			
		enddo
		
		if lAddIndicador
			oNodeColeta:oAddChild(oNodeFreq)		
		endif
				
		oIndicador:cSQLFilter("")		     
		lAddIndicador := .F.
		
	next nItem
	
	if len(oNodeColeta:FACHILDREN)> 0
		oNodeObrig:oAddChild(oNodeColeta)		
	endif		

Return .T.

//Inclui o no de Responsabilidade
method incResponsabilidade(oNode) class TBSC070
	Local oNodeResp, oAttrib, aPropNode
	
	//No de Mensagens
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", 1)
	oAttrib:lSet("TIPO", "RESPONSABILIDAES")
	oAttrib:lSet("NOME", STR0007) //"Reponsabilidades"

	oNodeResp := TBIXMLNode():New("RESPONSABILIDADES","",oAttrib)

	//Inclui os objetivos
	oTable 		:= ::oOwner():oGetTable("OBJETIVO")
	aPropNode 	:= {{STR0012}}//"Objetivos"
	cFiltro		:= "RESPID IN " + ::cPessoas + " and CONTEXTID = " +  cBIStr(::nEstAtual)
	::incRespItem(oNodeResp,oTable,"OBJETIVO",cFiltro,aPropNode)

	//Inclui os indicadores
	oTable 		:= ::oOwner():oGetTable("INDICADOR")
	aPropNode 	:= {{STR0008}} //"Indicadores"
	cFiltro		:= "RESPID IN " + ::cPessoas + " and CONTEXTID = " +  cBIStr(::nEstAtual)
	::incRespItem(oNodeResp,oTable,"INDICADOR",cFiltro,aPropNode)

	//Inclui as Metas
	oTable 		:= ::oOwner():oGetTable("META")
	aPropNode 	:= {{STR0011}}//"Metas"
	cFiltro		:= "RESPID IN " + ::cPessoas + " and CONTEXTID = " +  cBIStr(::nEstAtual)
	::incRespItem(oNodeResp,oTable,"META",cFiltro,aPropNode)

	//Inclui as Iniciativas
	oTable 		:= ::oOwner():oGetTable("INICIATIVA")
	aPropNode 	:= {{STR0009}} //"Iniciativas"
	cFiltro		:= "RESPID IN " + ::cPessoas + " and CONTEXTID = " +  cBIStr(::nEstAtual)
	::incRespItem(oNodeResp,oTable,"INICIATIVA",cFiltro,aPropNode)

	//Inclui o Mapa estrategico.
	::incMapaEst(oNodeResp)	

	//So adiciona se houverem sub itens
	if len(oNodeResp:FACHILDREN)> 0
		oNode:oAddChild(oNodeResp)
	endif		

return .T.

method incRespItem(oNodeParent,oTable,cMainTag,cFiltro,aPropNode) class TBSC070
	local oAttrib, oNodeChild, lAdd := .F.

	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", 1)
	oAttrib:lSet("NOME", aPropNode[1,1])
	oNodeChild := TBIXMLNode():New(aPropNode[1,1],"",oAttrib)

	oTable:cSQLFilter(cFiltro)
	oTable:lFiltered(.t.)
	oTable:_First()
	
	while(!oTable:lEof())
		lAdd := .T.

		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", oTable:nValue("ID"))
		oAttrib:lSet("TIPO", cMainTag)
		oAttrib:lSet("NOME", alltrim(oTable:cValue("NOME")))
		if(cMainTag=="INDICADOR")
			oAttrib:lSet("TIPOIND", alltrim(oTable:cValue("TIPOIND")))
		endif
		oNodeChild:oAddChild(TBIXMLNode():New(cMainTag+alltrim(str(oTable:nValue("ID"))),"",oAttrib))
   
		oTable:_Next()
	enddo

	if lAdd 
		oNodeParent:oAddChild(oNodeChild)
	endif		

	oTable:cSQLFilter("")		     
	lAddInd := .F.

return .T.

//Inclui o no do mapa estrategico.
method incMapaEst(oNodeParent) class TBSC070
	local oNodeChild, oAttrib

	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", 1)
	oAttrib:lSet("NOME", STR0016)//"Mapa Estratégico"
	oNodeChild := TBIXMLNode():New("MAPAESTRATEGICO","",oAttrib)

	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", ::nEstAtual)
	oAttrib:lSet("TIPO", "MAPAEST")
	oAttrib:lSet("NOME", STR0016)//"Mapa estratégico"
	oNodeChild:oAddChild(TBIXMLNode():New("MAPAEST"+alltrim(str(::nEstAtual)),"",oAttrib))

	oNodeParent:oAddChild(oNodeChild)
	
return .T.

function _BSC070_Aretra()
return