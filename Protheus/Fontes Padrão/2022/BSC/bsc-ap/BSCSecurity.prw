// ######################################################################################
// Projeto: BSC
// Modulo : Core
// Fonte  : BSCSecurity - Contem os metodos para verificação de segurança do BSC
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------

#include "BSCDefs.ch"
#include "BIDefs.ch"

/*--------------------------------------------------------------------------------------
@class: TBIObject->TBSCSecurity
Classe do gerenciador de segurança do BSC.
--------------------------------------------------------------------------------------*/
#define SECUR_ID 163264
class TBSCSecurity from TBIObject
	
	data fnUserCard		// Cartao do usuario.
	data foUserTable	// Tabela de usuarios do sistema.
	data foGroupTable	// Tabela de grupos do sistema.
	data foSecurTable	// Tabela de seguranca do sistema.
	
	method New(oBSCCore) constructor
	method NewBSCSecurity(oBSCCore)
    
	method nLogin(cUser, cPassword, cSessao)
	method lSetupCard(nCard)
	method cCriptog(cKey)
	
	method oLoggedUser()

	// metodos para trabalhar com a seguranca.
	method lHasAccess(cTipo, nID, cComando, nParentId)
	method lHasParentAccess(cTipo, nID, cComando)
	method lAccess(cTipo, nID, cComando)
	method lVerifUG(nIDUser,cEntidade,nEstID,nConstante)

endclass

/*--------------------------------------------------------------------------------------
@constructor New()
Constroe o objeto em memória.
@param oBSCCore
--------------------------------------------------------------------------------------*/
method New(oBSCCore) class TBSCSecurity
	::NewBSCSecurity(oBSCCore)
return
method NewBSCSecurity(oBSCCore) class TBSCSecurity
	::NewObject()
	::oOwner(oBSCCore)
	// Abrir a tabela de usuarios
	::foUserTable := ::oOwner():oGetTable("USUARIO")
	// Abrir a tabela de Grupos
	::foGroupTable := ::oOwner():oGetTable("GRPUSUARIO")
	// Abrir as tabelas de seguranca
	::foSecurTable := ::oOwner():oGetTable("REGRA")
return

/*-------------------------------------------------------------------------------------
@method nLogin(cUser, cPassword, cSessao)
Posiciona o objeto security com base no usuário logado.
@param cUser - Nome de usuario para o qual sera gerado o security.
@param cPassword - Senha de usuario para o qual sera gerado o security.
@return - Um ID UserCard se o usuario existe. NIL usuario nao cadastrado.
--------------------------------------------------------------------------------------*/
method nLogin(cUser, cPassword, cSessao) class TBSCSecurity
	::fnUserCard := 0
	if(!empty(cUser))
		if(::foUserTable:lSeek(2, {cUser, 0}))
			if(::foUserTable:lValue("USERPROT"))
				psworder(2)
				pswseek(cUser)
				if(empty(cSessao) .and. pswname(cPassword)) .or. (!empty(cSessao) .and. RpcSetEnv('99', '01', cSessao, , "FAT", "", {}, .f., .f.,.f.,.f. ))
		   	 		::fnUserCard := ::foUserTable:nValue("ID")+SECUR_ID
				endif
			else
				if(	alltrim(::foUserTable:cValue("SENHA")) == cBIStr2Hex(pswencript(cPassword)) ;
					.or. cBIStr2Hex(alltrim(::foUserTable:cValue("SENHA"))) == cBIStr2Hex(pswencript(cPassword)) )
		   	 		::fnUserCard := ::foUserTable:nValue("ID")+SECUR_ID
	   		 	endif	
	   		endif
		endif
	endif	
return ::fnUserCard

/*-------------------------------------------------------------------------------------
@property lSetupCard(nCard)
Define o id cartao do usuario desta working thread.
@param nCard - Cartao a ser inserido.
@return - .t. se o cartão válido. .f. cartão inválido.
--------------------------------------------------------------------------------------*/
method lSetupCard(nCard) class TBSCSecurity
	local lValid := ::foUserTable:lSeek(1, {nCard-SECUR_ID})
	::fnUserCard := iif(lValid, nCard, 0)
return lValid

/*-------------------------------------------------------------------------------------
@property oLoggedUser()
Retorna a tabela de usuarios posicionada no usuario atualmente logado.
@return - tabela posicionada.
--------------------------------------------------------------------------------------*/
method oLoggedUser() class TBSCSecurity
	::foUserTable:lSeek(1, {::fnUserCard-SECUR_ID})	
return ::foUserTable

/*-------------------------------------------------------------------------------------
@method lHasParentAccess(cTipo, nID, cComando)
Define se o usuario logado tem acesso a uma determinada entidade.
@param cTipo - Nome da entidade a ser pesquisada.
@param nID - ID da entidade a ser pesquisada.
@param cComando - Comando a ser executado.
@return - .t. usuario tem acesso a entidade. .f. acesso negado.
--------------------------------------------------------------------------------------*/
method lHasParentAccess(cTipo, nID, cComando) class TBSCSecurity
	local lGranted := .f., oUsuarios, oTable
                               
	default cComando := "ARVORE"

	// Posiciona no usuário que está atualmente logado.
	oUsuarios := ::oLoggedUser()

	if(::lSetupCard(::fnUserCard))
		do case
			case ::foUserTable:lValue("ADMIN")
				lGranted := .t.
			case cComando=="CORES" .or. cComando=="NUMEROS"
				oTable := ::oOwner():oGetTable(cTipo)
				if(valtype(oTable)=="O")
					oTable:SavePos()
					if(oTable:cEntity()!="ORGANIZACAO")
						// Verifica se o Usuário é "Arquiteto" da Organização ou Estratégia.
						if(oTable:lSeek(1,{nID}))
							if(!lGranted)
								oEstrategia := ::oOwner():oAncestor("ESTRATEGIA", oTable)
								nEstID 		:= oEstrategia:nValue("ID")
			    	            nOrgID 		:= oEstrategia:nValue("PARENTID")
								lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"ORGANIZACAO",nOrgID,BSC_SEC_ARQUITETURA)
								if(!lGranted)
									lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"ESTRATEGIA",nEstID,BSC_SEC_ARQUITETURA)
								endif	
			    			endif
						endif
						
						if(!lGranted)
							lGranted := ::lVerifUG(oUsuarios:nValue("ID"),cTipo,oTable:nValue("ID"),BSC_SEC_NUMEROS)
							if(!lGranted .and. cComando!="NUMEROS")
								lGranted := ::lVerifUG(oUsuarios:nValue("ID"),cTipo,oTable:nValue("ID"),BSC_SEC_CORES)
							endif
							if(!lGranted)                                       
								lGranted := ::lHasParentAccess(::oOwner():cGetParent(oTable), oTable:nValue("PARENTID"), cComando)
							endif
						endif
					endif
					oTable:RestPos()
				endif
		endcase
	endif
	
return lGranted                            



/*-------------------------------------------------------------------------------------
@method lHasAccess(cTipo, nID, cComando)
Define se o usuario logado tem acesso a uma determinada entidade.
@param cTipo - Nome da entidade a ser pesquisada.
@param nID - ID da entidade a ser pesquisada.
@param cComando - Comando a ser executado.
@return - .t. usuario tem acesso a entidade. .f. acesso negado.
--------------------------------------------------------------------------------------*/
method lHasAccess(cTipo, nID, cComando, nParentId) class TBSCSecurity
	local lGranted := .f., oUsuarios, oTable, oEstrategia
	local nOrgId := 0, nEstId := 0, oTablePlanilha
                               
	default cComando := "ARVORE"

	// Posiciona no usuário atualmente logado.
	oUsuarios := ::oLoggedUser()

	if(::lSetupCard(::fnUserCard))
		do case
			case ::foUserTable:lValue("ADMIN")
				lGranted := .t.
			case (cComando=="EXECUTAR" .and. cTipo=="ESTRATEGIA") //Duplicador
				lGranted := ::foUserTable:lValue("ADMIN") 
			case cTipo=="DESKTOP"
				lGranted := .t.				
			case cTipo=="USUARIO" .or. cTipo=="GRUPO" .or. cTipo=="BSC"
				lGranted := .f.
			case substr(cTipo, 1, 6)=="MENSAG"
				lGranted := .t.				
			case cComando=="AJUDA"
				lGranted := .t.
			case cComando=="ARVORE"
				if(cTipo == "ORGANIZACAO")
					lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"ACESSOS_ORGA",1,BSC_SEC_ACESSAORG)
				else
					lGranted := .t.
				endif					
			case cTipo=="SYSTEMVAR"
				lGranted := .t.
			case cComando=="CARREGAR"
				if(cTipo=="MAPAEST" .or. cTipo=="CENTRAL")
					cTipo:="ESTRATEGIA"
				endif
				if(cTipo=="DRILL")
					cTipo:="OBJETIVO"
				endif
				if(cTipo=="PLANILHA" .or. cTipo=="RPLANILHA")
					cTipo:= "INDICADOR"
				endif
				oTable := ::oOwner():oGetTable(cTipo)
				oTable:SavePos()
				oTable:lSeek(1,{nID})
				if(cTipo=="PESSOA" .or. cTipo=="PGRUPO" .or. cTipo=="REUNIAO" .or. cTipo=="REURET" .or. cTipo=="REUPAU" .or. cTipo=="REUDOC")
					lGranted := .t.
				endif
				if(!lGranted .and. cTipo == "ORGANIZACAO")
					lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"ORGANIZACAO",nID,BSC_SEC_ARQUITETURA)
					if(!lGranted)
						oEstrategia := ::oOwner():oGetTable("ESTRATEGIA")
						oEstrategia:cSQLFilter("PARENTID = " + cBIStr(nID))
						oEstrategia:lFiltered(.t.)
						oEstrategia:_First()
						while(!oEstrategia:lEof() .and. !lGranted)
							lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"ESTRATEGIA",oEstrategia:nValue("ID"),BSC_SEC_ACESSOEST)
							oEstrategia:_Next()
						end
						oEstrategia:cSQLFilter("")
					endif
				endif
				if(!lGranted .and. cTipo != "ORGANIZACAO")
					// Instancia objeto de estrategia.
					oEstrategia := ::oOwner():oAncestor("ESTRATEGIA", oTable)
					nEstID 		:= oEstrategia:nValue("ID")
    	            nOrgID 		:= oEstrategia:nValue("PARENTID")
					lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"ORGANIZACAO",nOrgID,BSC_SEC_ARQUITETURA)
					if(!lGranted)
						lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"ESTRATEGIA",nEstID,BSC_SEC_ARQUITETURA)
					endif	
					if(!lGranted)
						lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"ESTRATEGIA",nEstID,BSC_SEC_ACESSOEST)
					endif
    			endif
				if(!lGranted)
					lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"ORGANIZACAO",nID,BSC_SEC_PESSOAS)
				endif
				if(!lGranted .and. (cTipo=="RELEST" .or. cTipo=="RELTAR" .or. cTipo=="RELIND" .or. cTipo=="REL5W2H"))
					lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"ESTRATEGIA",nId,BSC_SEC_RELATORIOS)
				endif
				oTable:RestPos()
			case cComando=="INCLUIR" .or. cComando=="ALTERAR" .or. cComando=="EXCLUIR"  .or. cComando=="EXECUTAR"
				lGranted := .f.
				oTable := ::oOwner():oGetTable(cTipo)
				oTable:SavePos()
				if(cComando=="INCLUIR")
					//retorno de reunião é liberado para Inclusao ou Retorno das Tarefas
					if(cTipo=="REURET" .or. cTipo=="RETORNO")
						lGranted := .t.
					endif
					//na inclusao o ID passado é o parentID
					if(cTipo == "REUNIAO" .or. cTipo == "PESSOA" .or. cTipo == "PGRUPO" .or. cTipo == "ORGANIZACAO" .or. cTipo == "ESTRATEGIA")
						lGranted := ::lVerifUG(oUsuarios:nValue("ID"), "ORGANIZACAO", nID, BSC_SEC_ARQUITETURA)
						nOrgId := nId
					endif
					
					if(!lGranted .and. !(cTipo == "REUNIAO" .or. cTipo == "PESSOA" .or. cTipo == "PGRUPO" .or. cTipo == "ORGANIZACAO") )
						lGranted := ::lVerifUG(oUsuarios:nValue("ID"), "ESTRATEGIA", nID, BSC_SEC_ARQUITETURA)
						nEstId := nId
						oEstrategia := ::oOwner():oGetTable("ESTRATEGIA")
						oEstrategia:lSeek(1,{nEstId})
	    	            nOrgID 	:= oEstrategia:nValue("PARENTID")
						if(!lGranted)
							lGranted := ::lVerifUG(oUsuarios:nValue("ID"), "ORGANIZACAO", nOrgID, BSC_SEC_ARQUITETURA)
						endif
					endif
				else
					if(cTipo=="PLANILHA" .or. cTipo=="RPLANILHA")
						oTablePlanilha := oTable
						oTable := ::oOwner():oGetTable("INDICADOR")
					endif
					if(cTipo=="MAPAEST")
						oTablePlanilha := oTable
						oTable := ::oOwner():oGetTable("ESTRATEGIA")
					endif
					if(oTable:lSeek(1,{nID}))
						if(cTipo == "REUNIAO" .or. cTipo == "PESSOA" .or. cTipo == "PGRUPO" .or. cTipo == "ORGANIZACAO")
							// Verifica permissoes SOMENTE para TIpo == Organizacao
							oOrganizacao := ::oOwner():oAncestor("ORGANIZACAO", oTable)
		    	            nOrgID 		 := oOrganizacao:nValue("ID")
							lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"ORGANIZACAO",nOrgID,BSC_SEC_ARQUITETURA)
						else
							// Verifica permissoes na Organizacao e Estrategia
							oEstrategia := ::oOwner():oAncestor("ESTRATEGIA", oTable)
							nEstID 		:= oEstrategia:nValue("ID")
		    	            nOrgID 		:= oEstrategia:nValue("PARENTID")
							lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"ORGANIZACAO",nOrgID,BSC_SEC_ARQUITETURA)
							if(!lGranted)
								lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"ESTRATEGIA",nEstID,BSC_SEC_ARQUITETURA)
							endif	
		    			endif
					endif
					if(cTipo=="PLANILHA" .or. cTipo=="RPLANILHA" .or. cTipo=="MAPAEST")
						oTable := oTablePlanilha
					endif
				endif

				if(!lGranted)
					if(cComando != "INCLUIR" .and. empty(nParentId))
						nParentId := oTable:nValue("PARENTID")
					endif
					// Organização
					if(cTipo=="REUNIAO")
						lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"ORGANIZACAO",nOrgID,BSC_SEC_REUNIOES)
					elseif(cTipo=="PESSOA" .or. cTipo=="PGRUPO")
						lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"ORGANIZACAO",nOrgID,BSC_SEC_PESSOAS)
					// Estratégia					
					elseif(cTipo=="DASHBOARD")
						lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"ESTRATEGIA",nEstID,BSC_SEC_PAINEIS)
					elseif(cTipo=="RELEST" .or. cTipo=="RELTAR" .or. cTipo=="RELIND" .or. cTipo=="REL5W2H" )
						lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"ESTRATEGIA",nParentId,BSC_SEC_RELATORIOS)
					elseif(cTipo=="GRAPH")
						lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"ESTRATEGIA",nEstID,BSC_SEC_GRAFICOS)
					// Indicador
					elseif(cTipo=="META")
						lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"INDICADOR",nParentId,BSC_SEC_METAS)
					elseif(cTipo=="AVALIACAO")
						lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"INDICADOR",nParentId,BSC_SEC_AVALIACOES)
					elseif(cTipo=="PLANILHA" .or. cTipo=="RPLANILHA")
						lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"INDICADOR",nParentId,BSC_SEC_PLANILHAS)
					elseif(cTipo=="DATASRC")
						lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"INDICADOR",nParentId,BSC_SEC_FONTEDADOS)
					elseif(cTipo=="INDDOC")
						lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"INDICADOR",nParentId,BSC_SEC_DOCUMENTOS)
					// Iniciativa
					elseif(cTipo=="TAREFA")
						lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"INICIATIVA",nParentId,BSC_SEC_TAREFAS)
					elseif(cTipo=="RETORNO")                                     
						oTarefa := ::oOwner():oGetTable("TAREFA")
						oTarefa:lSeek(1,{nParentId})
						lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"INICIATIVA",oTarefa:nValue("PARENTID"),BSC_SEC_RETORNOS)
					elseif(cTipo=="TARDOC")                                     
						oTarefa := ::oOwner():oGetTable("TAREFA")
						oTarefa:lSeek(1,{nParentId})
						lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"INICIATIVA",oTarefa:nValue("PARENTID"),BSC_SEC_TAREFAS)
					elseif(cTipo=="INIDOC")
						oTarefa := ::oOwner():oGetTable("TAREFA")
						oTarefa:lSeek(1,{nParentId})
						lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"INICIATIVA",oTarefa:nValue("PARENTID"),BSC_SEC_DOCUMENTOS)
					endif
				endif
				oTable:RestPos()
		endcase
	endif

return lGranted

/*-------------------------------------------------------------------------------------
@method cCriptog(cKey)
Criptografa com função(1 way) própria do Protheus.
@param cKey - Chave a ser criptografada.
@return - Chave criptografada.
--------------------------------------------------------------------------------------*/
method cCriptog(cKey) class TBSCSecurity
	cKey := pswencript(cKey)
return cKey

/*-------------------------------------------------------------------------------------
@method lVerifUG(nIDUser,cEntidade,nEntID,nConstante)
Verifica acesso de usuários e grupos (função de uso interno)
@param nIDUser - ID do Usuário
@param cEntidade - Nome da Entidade
@param nEstID - ID da Estrategia
@param nConstante - Constante a ser pesquisada
@return - Permissão (.t./.f.)
--------------------------------------------------------------------------------------*/
method lVerifUG(nIDUser,cEntidade,nEstID,nConstante) class TBSCSecurity
	local lGranted, nI  
	local lExistUserProp := .f.

	//Verifica permissão de arquitetura na estrategia
	lGranted := ::foSecurTable:lSeek(4,{"U", nIDUser, cEntidade, nEstID, nConstante})

	if(lGranted)
		lGranted 		:= ::foSecurTable:lValue("PERMITIDA")
		lExistUserProp	:= .t.	
	endif

	//Se o usuario não tiver acesso, verifica se o mesmo esta inserido em algum grupo 
	//que tenha a permissão
	if(!lGranted)
		aGrupos := ::foGroupTable:aGroupsByUser(nIDUser)
		for nI := 1 to len(aGrupos)
			//Verifica na tabela de segurança, se o grupo tem acesso ao comando nesta entidade
			if(::foSecurTable:lSeek(4,{"G", aGrupos[nI],  cEntidade, nEstID, nConstante}))
				lGranted := ::foSecurTable:lValue("PERMITIDA")
				if(lGranted)
					exit
				endif
			endif
		next
		//Se estiver verificando o acesso as organizacoes o default para o usuario nao cadastrado e sim
		//compatibilizacao com as versoes instaladas.
		if(cEntidade == "ACESSOS_ORGA" .and. len(aGrupos) == 0 .and. ! lExistUserProp)
			lGranted := .t.
		endif
	endif         
return lGranted   

function _BSCSecurity()
return ::New()
