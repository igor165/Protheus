#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "ApWebSrv.ch"

/*
*   WebService: wsIpFluig 
*   Autor     : Daniel
*   Data 	  : 11/04/2011 
*   Descrição : Rotinas genéricas usadas no portal de vendas 
*
*/

user function wsIpFluig

return

wsStruct tableHeader

	wsData nome				as string
	wsData descricao		as string
	wsData tipo				as string
	wsData tamanho			as integer
	wsData decimal			as integer

endWsStruct

wsStruct tableFields

	wsData valor			as array of string

endWsStruct

wsStruct cField
	wsData cValor			as string OPTIONAL
endWsStruct

wsStruct soField
	wsData aField			as array of cField
endWsStruct

wsStruct resultSet

	wsData headerFld		as array of tableHeader optional
	wsData colsFld			as array of tableFields optional

endWsStruct

wsStruct campos

	wsData nomeCampo		as string
	wsData valor1			as string  
	wsData valor2			as string  OPTIONAL

endWsStruct

wsStruct soItem

	wsData linha			as array of campos

endWsStruct

wsStruct soHeader

	wsData soHd				as array of campos
	wsData soIt				as array of soItem OPTIONAL
	wsData aItAux		    as array of soItem OPTIONAL
	wsData cUserFluig		as string Optional

endWsStruct

wsStruct soLinha

	wsData soIt				as array of soItem OPTIONAL

endWsStruct

WsStruct WsGetFiliais

	WsData	cCodigoEmpresa		As	STRING	Optional
	WsData	cCodigoFilial		As	STRING	Optional
	WsData	cNomeFilial			As	STRING	Optional
	WsData	cNome				As	STRING	Optional
	WsData	cEnderecoCobranca	As	STRING	Optional
	WsData	cCidadeCobranca		As	STRING	Optional
	WsData	cEstadoCobranca		As	STRING	Optional
	WsData	cCepCobranca		As	STRING	Optional
	WsData	cResponsRA			As	STRING	Optional

EndWsStruct

WsStruct WsGetUserProt
	WsData	cUsuario		As	STRING	Optional
	WsData	cSuperior		As	STRING	Optional
	WsData	cEmailSuperior	As	STRING	Optional
EndWsStruct

WsStruct WsGetSubUser
	WsData	cUsuario		As	STRING	Optional
	WsData	cNome			As	STRING	Optional
	WsData	cMail			As	STRING	Optional
EndWsStruct

WsStruct WsProdutos
	WsData	cCodigo			As	STRING	
	WsData	cDescricao		As	STRING	
	WsData	cUM				As	STRING	
	WsData	cTipo			As	STRING	
	WsData	cPreco			As	STRING	
	WsData	cPrecoStd		As	STRING
	WsData	cUcom			As	STRING
	WsData	cLocPad			As	STRING					
EndWsStruct

WsStruct WsCCusto
	WsData	cCodigo			As	STRING	
	WsData	cDescricao		As	STRING					
EndWsStruct 

WsStruct WsArmazem
	WsData	cCodigo			As	STRING	
	WsData	cDescricao		As	STRING					
EndWsStruct 

WsStruct WsNegocio
	WsData	cCodigo			As	STRING	
	WsData	cDescricao		As	STRING					
EndWsStruct 

wsStruct ListMetas
	WsData Lista As Array of metas
EndWsStruct


wsStruct ListUsrMetas
	WsData Lista As Array of userMetas
EndWsStruct

wsStruct userMetas
	WsData	solicitacao		As	FLOAT	Optional
	WsData	colaborador		As	STRING	
	WsData	ano				As	STRING	
	WsData	meta			As	STRING	
	WsData	mes				As	STRING	
	WsData	nomeMes			As	STRING
	WsData	valor			As	FLOAT	
	WsData	percent			As	FLOAT	
	WsData	revisa			As	STRING	
	WsData	tipo			As	STRING	
	WsData	observacao		As	STRING	
	WsData	ativa			As	STRING		
	WsData	valpeso			As	float	
EndWsStruct


wsStruct estrutura
	WsData	quantidade		As	FLOAT	
	WsData	preco			As	FLOAT	
	WsData	cod				As	STRING	
	WsData	descricao		As	STRING	
	WsData	codPai			As	STRING	
	WsData	descricaoPai	As	STRING	
	WsData	nivel			As	STRING
	WsData	um				As	STRING	
	WsData	tipo			As	STRING	Optional
	WsData	total			As	FLOAT	
	WsData	base			As	FLOAT	

EndWsStruct

wsStruct metas
	WsData	solicitacao		As	FLOAT	Optional
	WsData	colaborador		As	STRING	
	WsData	ano				As	STRING	
	WsData	dtInicio		As	STRING	
	WsData	dtFim			As	STRING	
	WsData	userFluig		As	STRING	Optional
	WsData	gestor			As	STRING	
	WsData	gestorFluig		As	STRING	Optional
	WsData	meta			As	STRING	
	WsData	descricao		As	STRING	
	WsData	peso			As	FLOAT	
	WsData	valor			As	FLOAT	
	WsData	revisa			As	STRING	
	WsData	ativa			As	STRING	Optional
	WsData	tipo			As	STRING	
	WsData	metodo			As	STRING	
	WsData  mesref			As	STRING	Optional

	WsData	pesoQl			As	FLOAT	
	WsData	pesoQt			As	FLOAT	
EndWsStruct

wsStruct AtMetas
	WsData	ano				As	STRING
	WsData	meta			As	STRING		
EndWsStruct

wsStruct WsCliente
	WsData cod 		As STRING
	WsData loja		As STRING
	WsData nome 	As STRING
	WsData cgc 		As STRING
	WsData Cep 		As STRING 
	WsData Cid		As STRING
EndWsStruct

wsStruct WsCliProd
	WsData CodCli		As STRING
	WsData NomeCli 		As STRING
	WsData CodProd		As STRING
	WsData NomeProd		As STRING
	
/* 	WsData loja		As STRING
	WsData cgc 		As STRING
	WsData Cep 		As STRING 
	WsData Cid		As STRING */
EndWsStruct

wsStruct WsProduto
	WsData CodProd		As STRING
	WsData NomeProd		As STRING
	
/* 	WsData loja		As STRING
	WsData cgc 		As STRING
	WsData Cep 		As STRING 
	WsData Cid		As STRING */
EndWsStruct

wsService wsIpFluig Description "Serviço de métodos genérico usados no Fluig" nameSpace "http://totvsip.com.br/wsIpFluig.apw"
	//Constantes
	wsData cFiltro			as string
	wsData cEmpresa			as string
	wsData cSql				as string
	wsData table			as resultSet
	wsData cMsg				as string
	wsData lMsg				as boolean
	wsData cAlias			as string
	wsData cEmail			as string
	wsData cColab			as string	
	wsData cCoord			as string
	wsData cAno				as string
	wsData cMes				as string
	wsData cRevisa			as string
	wsData cTipo			as string
	wsData nIndice			as integer
	wsData cChave			as string
	wsData cCampo			as string	
	wsData cRun				as string
	wsData cRevisao			as string
	wsData cProduto			as string
	wsData cEspecie			as string
	wsData cTxt				as string
	wsData nFluig			as float
	//objetos
	wsData objRot			as soHeader
	wsData nOpc				as float
	wsData cFil				as string
	wsData cTable			as string
	wsData objCampos		as soItem
	wsData cFuncao			as string
	wsData cEmp				as string
	wsData cKey				as string
	wsData oUser			as soItem
	WsData oUserProt		as  WsGetUserProt
	//Array de Objetos
	WsData aVetApont  		As  soField
	WsData aFiliais			As  Array of WsGetFiliais
	WsData aSubUsr			as  Array of WsGetSubUser
	WsData aProdutos		As  Array of WsProdutos
	WsData aArmazem			As  Array of WsArmazem
	WsData aNegocios		As  Array of WsNegocio
	WsData aCCusto	    	As  Array of WsCCusto
	WsData aMetas	    	As  Array of AtMetas
	WsData aFullMetas	    As  Array of metas
	WsData aPrcEst		    As  Array of estrutura
	WsData aClientes 		As  Array of WsCliente
	WsData aCliProd 		As  Array of WsCliProd
	WsData ItensMeta   	 	As  ListMetas  
	WsData ItensUsuario  	As  ListUsrMetas	

	//Descrição dos Metodos
	wsMethod execFunction			Description "Método responsável por executar função sem e com retorno"
	wsMethod execQuery				Description "Executa query's retornando seu resultSet "
	wsMethod rotAuto				Description "Método responsável por cadastrar registro via rotina automática. "
	wsMethod intGemba				Description "Método responsável por integrar registro com o Gemba. "
	WsMethod getEnd					Description "Metodo para retornar as filiais da Empresa selecionada."
	WsMethod getUsuarioProtheus		Description "Metodo para retornar usuario protheus / seu superior."
	WsMethod getSubordinados 		Description "Metodo para retornar usuarios subordinados, recebendo codigo de um usuario protheus"
	WsMethod putMetas 		 		Description "Inclui as metas preenchidas pelo coodenador."
	WsMethod validaInclusao  		Description "Valida inclusão de metas"
	WsMethod getMetas		 		Description "Retornas lista de Metas Ativas"
	WsMethod getFullMetas	 		Description "Retornas lista das metas de um ano passado por paremtros"
	WsMethod putPreenchimento   	Description "Inclui os valores das metas preenchidos pelo usuario."
	WsMethod validaPreenchimento 	Description "Valida inclusão de Prenchimento de metas"
	WsMethod getPrcEst 				Description "Consulta estrutura do produto + run ativo para formar preço do produto ou listar preco dos itens"
	WsMethod impEstTxt 				Description "Importa Estrutura Txt"
	WsMethod getClientes 			Description "Cliente"
	WsMethod GetProd 				Description "Produto"
	WsMethod GetCliProd 			Description "Clientes x Produto"
endWsService

WsMethod impEstTxt WsReceive cTxt, cEmp, cFil, nFluig WsSend cMsg WsService wsIpFluig
	local aArea		
	local oApoio	:=	ApoioWS()():New()
	
	RPCCLEARENV()
	rpcSetType(3)
	rpcSetEnv(cEmp, cFil)

	aArea		:=	getArea()	

	::cMsg := oApoio:impEstTxt(cTxt, cEmp, cFil, nFluig)


	restArea(aArea)
return (.T.)  

/* MB : 19.09.2022 */
WsMethod getClientes WsReceive cCod WsSend aClientes WsService wsIpFluig
	Local aArea 	:=	getArea()	
	Local oApoio	:=	ApoioWS():New()
	local nX 		:= 0
	
	RPCCLEARENV()
	rpcSetType(3)
	rpcSetEnv("01", "01")
	
	aDados := oApoio:getClientes()
	if len(aDados) > 0 
		for nX := 1 to len(aDados)
			aAdd(aClientes, WsClassNew("WsCliente"))

			aTail(aClientes):cod 	:= AllTrim(aDados[nX][1])
			aTail(aClientes):loja 	:= AllTrim(aDados[nX][1])
			aTail(aClientes):nome 	:= AllTrim(aDados[nX][2])
			aTail(aClientes):cgc 	:= AllTrim(aDados[nX][3])
			aTail(aClientes):Cep 	:= AllTrim(aDados[nX][4])
			aTail(aClientes):Cid 	:= AllTrim(aDados[nX][5])
		next nX
	endif 
	
	restArea(aArea)
Return .T.

/* MB : 19.09.2022 */
WsMethod GetProd WsReceive cCod WsSend aProdutos WsService wsIpFluig
	Local aArea 	:=	getArea()	
	Local oApoio	:=	ApoioWS():New()
	local nX 		:= 0
	
	RPCCLEARENV()
	rpcSetType(3)
	rpcSetEnv("01", "01")
	
	aDados := oApoio:GetProd()
	if len(aDados) > 0 
		for nX := 1 to len(aDados)
			aAdd(aClientes, WsClassNew("WsCliente"))

			aTail(aProdutos):cCodigo 	:= AllTrim(aDados[nX][1])
			aTail(aProdutos):cDescricao := AllTrim(aDados[nX][1])
			aTail(aProdutos):cUM 		:= AllTrim(aDados[nX][2])
			aTail(aProdutos):cTipo 		:= AllTrim(aDados[nX][3])
			aTail(aProdutos):cPreco 	:= AllTrim(aDados[nX][4])
		next nX
	endif 
	
	restArea(aArea)
Return .T.

/* MB : 19.09.2022 */
WsMethod GetCliProd WsReceive cCod WsSend aCliProd WsService wsIpFluig
	Local aArea 	:=	getArea()	
	Local oApoio	:=	ApoioWS():New()
	local nX 		:= 0
	
	RPCCLEARENV()
	rpcSetType(3)
	rpcSetEnv("01", "01")
	
	aDados := oApoio:GetCliProd()
	if len(aDados) > 0 
		for nX := 1 to len(aDados)
			aAdd(aCliProd, WsClassNew("WsCliente"))

			aTail(aCliProd):CodCli 		:= AllTrim(aDados[nX][1])
			aTail(aCliProd):NomeCli 	:= AllTrim(aDados[nX][1])
			aTail(aCliProd):CodProd 	:= AllTrim(aDados[nX][2])
			aTail(aCliProd):NomeProd 	:= AllTrim(aDados[nX][3])
	
		next nX
	endif 

	restArea(aArea)
Return .T.


WsMethod getPrcEst WsReceive cRun, cRevisao, cProduto, cTipo,cEspecie WsSend aPrcEst WsService wsIpFluig
	local aArea		
	local oApoio	:=	ApoioWS()():New()
	local nX 		:= 0

	RPCCLEARENV()
	rpcSetType(3)
	rpcSetEnv("01", "01")

	aArea		:=	getArea()	

	aDados := oApoio:getPrcEst(cRun, cRevisao, cProduto, cTipo,cEspecie)

	nDados := len(aDados)	
	for nX:=1 to nDados

		aAdd(aPrcEst, WsClassNew("estrutura"))


		aTail(aPrcEst):quantidade		:=	aDados[nX][1]
		aTail(aPrcEst):preco			:=	aDados[nX][2]
		aTail(aPrcEst):cod				:=	aDados[nX][3]
		aTail(aPrcEst):descricao		:=	aDados[nX][4]
		aTail(aPrcEst):codPai			:=	aDados[nX][5]
		aTail(aPrcEst):descricaoPai		:=	aDados[nX][6]
		aTail(aPrcEst):nivel			:=	cValToChar(aDados[nX][7])
		aTail(aPrcEst):um				:=	aDados[nX][8]
		aTail(aPrcEst):tipo				:=	aDados[nX][9]
		aTail(aPrcEst):total			:=	aDados[nX][10]
		aTail(aPrcEst):base				:=	aDados[nX][11]

	next nX

	restArea(aArea)
return (.T.)  

WsMethod getFullMetas WsReceive cColab, cCoord, cAno WsSend aFullMetas WsService wsIpFluig
	local aArea		
	local oApoio	:=	ApoioWS()():New()
	local nX 		:= 0

	RPCCLEARENV()
	rpcSetType(3)
	rpcSetEnv("01", "01")

	aArea		:=	getArea()	

	aDados := oApoio:getFullMetas(cColab, cCoord, cAno)

	nDados := len(aDados)	
	for nX:=1 to nDados

		aAdd(aFullMetas, WsClassNew("metas"))


		aTail(aFullMetas):meta		:=	Alltrim(aDados[nX][1])
		aTail(aFullMetas):dtInicio	:=	Alltrim(aDados[nX][2])
		aTail(aFullMetas):dtFim		:=	Alltrim(aDados[nX][3])

		aTail(aFullMetas):ano		:=	Alltrim(aDados[nX][4])
		aTail(aFullMetas):descricao	:=	Alltrim(aDados[nX][5])
		aTail(aFullMetas):peso		:=	aDados[nX][6]
		aTail(aFullMetas):valor		:=	aDados[nX][7]
		aTail(aFullMetas):metodo	:=	Alltrim(aDados[nX][8])
		aTail(aFullMetas):tipo		:=	Alltrim(aDados[nX][9])
		aTail(aFullMetas):revisa	:=	Alltrim(aDados[nX][10])

		aTail(aFullMetas):gestor	  :=	cCoord
		aTail(aFullMetas):colaborador :=	cColab
		aTail(aFullMetas):mesref :=	Alltrim(aDados[nX][11])
		aTail(aFullMetas):pesoQt :=	aDados[nX][12]
		aTail(aFullMetas):pesoQl :=	aDados[nX][13]

	next nX

	restArea(aArea)
return (.T.)  

WsMethod getMetas WsReceive cColab, cCoord WsSend aMetas WsService wsIpFluig
	local aArea		
	local oApoio	:=	ApoioWS()():New()
	local nX 		:= 0
	aDados := oApoio:getMetas(cColab,cCoord)

	RPCCLEARENV()
	rpcSetType(3)
	rpcSetEnv("01", "01")

	aArea		:=	getArea()	

	nDados := len(aDados)	
	for nX:=1 to nDados

		aAdd(aMetas, WsClassNew("AtMetas"))

		aTail(aMetas):ano		:=	Alltrim(aDados[nX][1])
		aTail(aMetas):meta		:=	Alltrim(aDados[nX][2])

	next nX

	restArea(aArea)
return (.T.)  

WsMethod validaInclusao WsReceive cTipo , cAno, cColab, cRevisa  WsSend cMsg WsService wsIpFluig
	local aArea		
	local oApoio	:=	ApoioWS()():New()

	RPCCLEARENV()
	rpcSetType(3)
	rpcSetEnv("01", "01")

	aArea		:=	getArea()	

	//Verificando todas as filiais da cEmpresa informada
	::cMsg := oApoio:validaInclusao(cTipo , cAno, cColab, cRevisa)
return (.T.)  

WsMethod putMetas WsReceive cTipo, ItensMeta WsSend cMsg WsService wsIpFluig
	local aArea		
	local oApoio	:=	ApoioWS()():New()

	RPCCLEARENV()
	rpcSetType(3)
	rpcSetEnv("01", "01")

	aArea		:=	getArea()	
	//Verificando todas as filiais da cEmpresa informada
	::cMsg := oApoio:putMetas(cTipo, ItensMeta)
return (.T.)  

WsMethod validaPreenchimento WsReceive cTipo , cAno, cColab, cRevisa, cMes  WsSend cMsg WsService wsIpFluig
	local aArea		
	local oApoio	:=	ApoioWS()():New()

	RPCCLEARENV()
	rpcSetType(3)
	rpcSetEnv("01", "01")
	aArea		:=	getArea()	
	//Verificando todas as filiais da cEmpresa informada
	::cMsg := oApoio:validaPreenchimento(cTipo , cAno, cColab, cRevisa, cMes)
	//::cMsg := "NOK"
return (.T.)  

WsMethod putPreenchimento WsReceive cTipo, ItensUsuario WsSend cMsg WsService wsIpFluig
	local aArea		
	local oApoio	:=	ApoioWS()():New()

	RPCCLEARENV()
	rpcSetType(3)
	rpcSetEnv("01", "01")

	aArea		:=	getArea()	
	//Verificando todas as filiais da cEmpresa informada
	::cMsg := oApoio:putPreenchimento(cTipo, ItensUsuario)
	::cMsg := "OK"	
return (.T.)  

wsMethod intGemba wsReceive aVetApont, cTipo wsSend cMsg wsService wsIpFluig
	Local aArea	
	Local lRetorno	:= .t.
	Local cRotina	:= ""
	Local aVet	:= {}
	Local nI	:= 0

	RPCCLEARENV()
	rpcSetType(3)
	rpcSetEnv("01", "01")

	For nI:=1 to LEN(aVetApont:aFIELD)
		aADD(aVet,aVetApont:aFIELD[nI]:cValor)    
	Next

	aArea		:=	getArea()	

	do case
		case cTipo == "APONTAMENTO"
		cRotina	:= "APONTAMENTO"
		lRetorno := u_ApMod2(aVet)
		::cMsg := "OK"			
		case cTipo == "MOV_INTERNO"
		cRotina	:= "MOV_INTERNO"
		lRetorno := u_MovInt(aVet)
		::cMsg := "OK"			
		otherWise
		lRetorno := .f.
		::cMsg := "ERRO"
	endCase
	restArea(aArea)
return(lRetorno)

WsMethod getSubordinados WsReceive cFiltro WsSend aSubUsr WsService wsIpFluig

	Local aArea		
	local nX		:= 0
	local nDados	:= 0
	local aDados	:= {}
	local oApoio	:=	ApoioWS()():New()

	RPCCLEARENV()
	rpcSetType(3)
	rpcSetEnv("01", "01")

	aArea		:= getArea()

	//Verificando todas as filiais da cEmpresa informada
	aDados := oApoio:getSubordinados(cFiltro)

	nDados := len(aDados)

	//Setando todas as filiais de retorno nas variaveis para serem apresentadas no WS.		
	for nX:=1 to nDados

		aAdd(aSubUsr, WsClassNew("WsGetSubUser"))

		aTail(aSubUsr):cUsuario		:=	Alltrim(aDados[nX][1])
		aTail(aSubUsr):cNome		:=	Alltrim(aDados[nX][2])
		aTail(aSubUsr):cMail		:=	Alltrim(aDados[nX][3])		
	next nX

	restArea(aArea)

return (.T.) 

WsMethod getUsuarioProtheus WsReceive cEmail WsSend oUserProt WsService wsIpFluig

	Local aArea		
	local aDados	:= {}	
	local oApoio	:=	ApoioWS():New()

	RPCCLEARENV()
	rpcSetType(3)
	rpcSetEnv("01", "01")

	aArea	:= getArea()	

	//Verificando todas as filiais da cEmpresa informada
	aDados := oApoio:getUsuariosProtheus(cEmail)

	::oUserProt:cUsuario := aDados[1]
	::oUserProt:cSuperior := aDados[2]
	::oUserProt:cEmailSuperior := aDados[3]	

	restArea(aArea)

return (.T.) 

wsMethod execQuery wsReceive cSql, cEmp, cFil, cKey wsSend table wsService wsIpFluig

	local cAlias 
	local cCampo := ""
	local nI     := 0
	local nX     := 0

	RPCCLEARENV()
	rpcSetType(3)
	rpcSetEnv(::cEmp, ::cFil)

	cAlias := getNextAlias()

	if !checkKey(cKey)
		rpcClearEnv()
		setSoapFault("KEY", "Chave invalida !!")
		return(.f.)
	endIf

	if !empty(cSql)
		tcQuery ::cSql New ALIAS (cAlias)

		// carregar header
		for nI := 1 to (cAlias)->(fCount())
			cCampo := (cAlias)->(fieldName(nI))
			if !cCampo $ "D_E_L_E_T_*R_E_C_N_O_*R_E_C_D_E_L_"
				aAdd(::table:headerFld, wsClassNew("tableHeader"))
				::table:headerFld[nI]:nome      := cCampo
				::table:headerFld[nI]:descricao := retTitle(cCampo)
				::table:headerFld[nI]:tamanho   := (cAlias)->(dbFieldInfo(3, nI))
				::table:headerFld[nI]:decimal   := (cAlias)->(dbFieldInfo(4, nI))
				::table:headerFld[nI]:tipo      := (cAlias)->(dbFieldInfo(2, nI))
			endIf
		next nI

		do while (cAlias)->(!eof())
			aAdd(::table:colsFld, wsClassNew("tableFields"))
			nX ++
			::table:colsFld[nX]:valor := {}

			for nI := 1 to (cAlias)->(fCount())
//				conOut("Campo " + (cAlias)->(fieldName(nI)))
				if !(cAlias)->(fieldName(nI)) $ "D_E_L_E_T_*R_E_C_N_O_*R_E_C_D_E_L_"
					do case
						case InfoSX3((cAlias)->(fieldName(nI)))[3] == "N"
//						conOut("Campo(Inteiro) " + (cAlias)->(fieldName(nI)))
						aAdd(::table:colsFld[nX]:valor, transform((cAlias)->(fieldGet(fieldPos((cAlias)->(fieldName(nI))))), PesqPictQt((cAlias)->(fieldName(nI)))))
						case InfoSX3((cAlias)->(fieldName(nI)))[3] == "D"
//						conOut("Campo(Data) " + (cAlias)->(fieldName(nI)))
						aAdd(::table:colsFld[nX]:valor, dToC(sToD((cAlias)->(fieldGet(fieldPos((cAlias)->(fieldName(nI))))))))
						otherWise
//						conOut("Campo(String) " + (cAlias)->(fieldName(nI)))
						aAdd(::table:colsFld[nX]:valor, (cAlias)->(fieldGet(fieldPos((cAlias)->(fieldName(nI))))))
					endCase
				endIf
			next nI

			(cAlias)->(dbSkip())
		endDo
	endIf

	(cAlias)->(dbCloseArea())

return(.t.)

wsMethod rotAuto wsReceive objRot, nOpc, cTipo, cEmp, cFil wsSend cMsg wsService wsIpFluig

	local aHeader			:= {}
	local aCols				:= {}
	local aColsAux			:= {}	
	local aLinha			:= {}
	local nI				:= 0
	local nX				:= 0
	local nJ				:= 0
	local lRetorno			:= .t.
	local aRetorno			:= {}
	local cRotina			:= ""
	local cErro				:= ""
	local aErro				:= {}
	local aAreaATU			
	local nPos				:= 0
	local lPadBr            := .F.
	local cProd             := ""
	local cProdOri          := ""
	private cCod			:= ""

	Private lMsErroAuto		:= .f.		// Determina se houve algum tipo de erro durante a execucao do ExecAuto
	//Private lMsHelpAuto		:= .T.		// Define se mostra ou não os erros na tela (T = Nao mostra; F = Mostra)
	//Private lAutoErrNoFile	:= .t.		// Habilita a gravacao de erro da rotina automatica

	RPCCLEARENV()
	rpcSetType(3)
	rpcSetEnv(::cEmp, ::cFil)

  	aAreaATU			:= GetArea()
	
	If !EMPTY(::objRot:cUserFluig)			
		PswOrder(2)
		If PswSeek(::objRot:cUserFluig)
			CUSERNAME := ::objRot:cUserFluig
			oApp:cUserId := PswRet(1)[1][1]
		EndIf	
	EndIf		

	conOut(" Usuario conectado: -> " + oApp:cUserId + " - " + CUSERNAME)
	conOut(" Rotina: -> " + cTipo + " Opção: " + AllTrim(Str(nOpc)))

	// cabeçalho da rotina
	for nI := 1 to len(::objRot:soHd)
		if ::objRot:soHd[nI]:nomeCampo == "B1_COD"
			cProd := ::objRot:soHd[nI]:valor1
		endif
		if ::objRot:soHd[nI]:nomeCampo == "B5_COD"
			cProdOri := ::objRot:soHd[nI]:valor1
		endif
		if infoSx3(::objRot:soHd[nI]:nomeCampo)[3] == "N"
			IF "," $ ::objRot:soHd[nI]:valor1 
				lPadBr := .t.
			endif

			if lPadBr
				::objRot:soHd[nI]:valor1 := StrTran(::objRot:soHd[nI]:valor1,".","" )
				::objRot:soHd[nI]:valor1 := StrTran(::objRot:soHd[nI]:valor1,",","." )
			endif

			aAdd(aHeader, {::objRot:soHd[nI]:nomeCampo, val(::objRot:soHd[nI]:valor1), ::objRot:soHd[nI]:valor2})
		elseIf infoSx3(::objRot:soHd[nI]:nomeCampo)[3] == "D"
			aAdd(aHeader, {::objRot:soHd[nI]:nomeCampo, cToD(::objRot:soHd[nI]:valor1), ::objRot:soHd[nI]:valor2})
		elseIf infoSx3(::objRot:soHd[nI]:nomeCampo)[3] == "M"
			aAdd(aHeader, {::objRot:soHd[nI]:nomeCampo, ::objRot:soHd[nI]:valor1, ::objRot:soHd[nI]:valor2})
		else			
			if !allTrim(::objRot:soHd[nI]:nomeCampo) $ "AUTBANCO|AUTAGENCIA|AUTCONTA"
				aAdd(aHeader, {::objRot:soHd[nI]:nomeCampo, padR(::objRot:soHd[nI]:valor1, tamSx3(::objRot:soHd[nI]:nomeCampo)[1]), iif(empty(::objRot:soHd[nI]:valor2), nil, ::objRot:soHd[nI]:valor2)})
			else
				aAdd(aHeader, {::objRot:soHd[nI]:nomeCampo, ::objRot:soHd[nI]:valor1, ::objRot:soHd[nI]:valor2})
			endIf
		endIf		
		conOut("soHd -> Linha" + cValTochar(nI) + " -> Campo: " + ::objRot:soHd[nI]:nomeCampo + " := " + ::objRot:soHd[nI]:valor1)
	next nI
	conOut(" QTD CABEC -> " + str(len(AHEADER)))

	// item para rotina
	for nX := 1 to len(::objRot:soIt)
		for nJ := 1 to len(::objRot:soIt[nX]:linha)
					
			if InfoSX3(::objRot:soIt[nX]:linha[nJ]:nomeCampo)[3] == "N"

				IF "," $ ::objRot:soIt[nX]:linha[nJ]:valor1
					lPadBr := .t.
				endif

				if lPadBr
					::objRot:soIt[nX]:linha[nJ]:valor1 := StrTran(::objRot:soIt[nX]:linha[nJ]:valor1,".","" )
					::objRot:soIt[nX]:linha[nJ]:valor1 := StrTran(::objRot:soIt[nX]:linha[nJ]:valor1,",","." )
				endif

				aAdd(aLinha, {::objRot:soIt[nX]:linha[nJ]:nomeCampo, val(::objRot:soIt[nX]:linha[nJ]:valor1), iif(empty(::objRot:soIt[nX]:linha[nJ]:valor2), nil, ::objRot:soIt[nX]:linha[nJ]:valor2)})
			elseIf InfoSX3(::objRot:soIt[nX]:linha[nJ]:nomeCampo)[3] == "D"
				aAdd(aLinha, {::objRot:soIt[nX]:linha[nJ]:nomeCampo, cToD(::objRot:soIt[nX]:linha[nJ]:valor1), iif(empty(::objRot:soIt[nX]:linha[nJ]:valor2), nil, ::objRot:soIt[nX]:linha[nJ]:valor2)})
			else
				aAdd(aLinha, {::objRot:soIt[nX]:linha[nJ]:nomeCampo, padR(::objRot:soIt[nX]:linha[nJ]:valor1, tamSx3(::objRot:soIt[nX]:linha[nJ]:nomeCampo)[1]), iif(empty(::objRot:soIt[nX]:linha[nJ]:valor2), nil, ::objRot:soIt[nX]:linha[nJ]:valor2)})
			endIf
			conOut("soIt -> Linha" + cValTochar(nJ) + " -> Campo: " + ::objRot:soIt[nX]:linha[nJ]:nomeCampo + " := " + ::objRot:soIt[nX]:linha[nJ]:valor1)
		next nj

		aAdd(aCols, aLinha)
		aLinha := {}
	next nX
	conOut(" QTD ITENS -> " + str(len(aCols)))

	// Acols auxiliar
	for nX := 1 to len(::objRot:aItAux)
		for nJ := 1 to len(::objRot:aItAux[nX]:linha)

			if InfoSX3(::objRot:aItAux[nX]:linha[nJ]:nomeCampo)[3] == "N"
				IF "," $ ::objRot:aItAux[nX]:linha[nJ]:valor1
					lPadBr := .t.
				endif

				if lPadBr
					::objRot:aItAux[nX]:linha[nJ]:valor1 := StrTran(::objRot:aItAux[nX]:linha[nJ]:valor1,".","" )
					::objRot:aItAux[nX]:linha[nJ]:valor1 := StrTran(::objRot:aItAux[nX]:linha[nJ]:valor1,",","." )
				endif

				aAdd(aLinha, {::objRot:aItAux[nX]:linha[nJ]:nomeCampo, val(::objRot:aItAux[nX]:linha[nJ]:valor1), iif(empty(::objRot:aItAux[nX]:linha[nJ]:valor2), nil, ::objRot:aItAux[nX]:linha[nJ]:valor2)})
			elseIf InfoSX3(::objRot:aItAux[nX]:linha[nJ]:nomeCampo)[3] == "D"
				aAdd(aLinha, {::objRot:aItAux[nX]:linha[nJ]:nomeCampo, cToD(::objRot:aItAux[nX]:linha[nJ]:valor1), iif(empty(::objRot:aItAux[nX]:linha[nJ]:valor2), nil, ::objRot:aItAux[nX]:linha[nJ]:valor2)})
			else
				aAdd(aLinha, {::objRot:aItAux[nX]:linha[nJ]:nomeCampo, padR(::objRot:aItAux[nX]:linha[nJ]:valor1, tamSx3(::objRot:aItAux[nX]:linha[nJ]:nomeCampo)[1]), iif(empty(::objRot:aItAux[nX]:linha[nJ]:valor2), nil, ::objRot:aItAux[nX]:linha[nJ]:valor2)})
			endIf
			conOut("aItAux -> Linha" + cValTochar(nJ) + " -> Campo: " + ::objRot:aItAux[nX]:linha[nJ]:nomeCampo + " := " + ::objRot:aItAux[nX]:linha[nJ]:valor1)
		next nj

		aAdd(aColsAux, aLinha)
		aLinha := {}
	next nX
	conOut(" QTD ITENS AUX -> " + str(len(aColsAux)))
	
	do case
		case cTipo == "PV"
		cRotina	:= "PEDIDODEVENDA"
		MATA410(aHeader, aCols, nOpc)
		case cTipo == "CLI"
		cRotina	:= "CLIENTE"
		aRetorno := U_M030Clie(nOpc, aHeader)
		lRetorno := aRetorno[1]
		cErro := ''
		For nX:=1 to Len(aRetorno[2])		
			If !Empty(aRetorno[2][nX])
				cErro += aRetorno[2][nX] + " - "
			EndIf			
		Next nX			
		//MATA030(aHeader, nOpc)
		case cTipo == "TMKA260"
		cRotina	:= "PROSPECT"
		cCod := GETSXENUM('SUS','US_COD')
		aHeader[1][2] := cCod
		aHeader[1][3] := cCod 
		MSExecAuto({|x,y| TMKA260(x,y)},aHeader,3)
		case cTipo == "FOR"
		cRotina	:= "FORNECEDOR"
		aRetorno := U_M020FORN(nOpc, aHeader)
		lRetorno := aRetorno[1]
		cErro := ''
		For nX:=1 to Len(aRetorno[2])		
			If !Empty(aRetorno[2][nX]) .AND. !lRetorno
				cErro += aRetorno[2][nX] + " - "
			EndIf			
		Next nX

		case cTipo == "VEN"
		cRotina	:= "VENDEDOR"
		aRetorno := U_M040VEND(nOpc, aHeader)
		lRetorno := aRetorno[1]
		cErro := ''
		For nX:=1 to Len(aRetorno[2])		
			If !Empty(aRetorno[2][nX]) .AND. !lRetorno
				cErro += aRetorno[2][nX] + " - "
			EndIf			
		Next nX

		case cTipo == "TRANS"
		cRotina	:= "TRANSPORTADOR"
		aRetorno := U_M050TRAN(nOpc, aHeader)
		lRetorno := aRetorno[1]
		cErro := ''
		For nX:=1 to Len(aRetorno[2])		
			If !Empty(aRetorno[2][nX]) .AND. !lRetorno
				cErro += aRetorno[2][nX] + " - "
			EndIf			
		Next nX

		case cTipo == "FAB"
		cRotina	:= "FABRICANTE"
		U_PUTFABRI(aHeader, nOpc)
		case cTipo == "BLOQFAB"
		cRotina	:= "BLOQUEIRO FABRICANTE"
		U_BLFABRI(aHeader, nOpc)	
		case cTipo == "FABXPROD"
		cRotina	:= "FABRICANTE X PRODUTO"
		U_PUTPRFAB(aHeader, nOpc)
		case cTipo == "BLOQFABXPROD"
		cRotina	:= "BLOQUEIO FABRICANTE X PRODUTO"
		U_BLPRFAB(aHeader, nOpc)
		case cTipo == "LINHA"
		cRotina	:= "LINHA"
		u_putLinha(aHeader,aCols,nOpc)	
		case cTipo == "COMP_PROD"
		cRotina	:= "COMP_PROD"
		//MSExecAuto({|x,y| Mata180(x,y)},aHeader,nOpc)
		//lRetorno := U_M180Inc(aHeader)
		aRetorno := U_M180Inc(aHeader)
		lRetorno := aRetorno[1]
		cErro := ''
		For nX:=1 to Len(aRetorno[2])		
			If !Empty(aRetorno[2][nX])
				cErro += aRetorno[2][nX] + " - "
			EndIf			
		Next nX			
		 							
		case cTipo == "PRO"
		cRotina	:= "PRODUTO"
		dbSelectArea("SB1")
		if nOpc == 3 .OR. nOpc == 7
			if SB1->(DBSEEK(XFILIAL("SB1") + alltrim(cProd)  ) )
				::cMsg := "ERRO - PRODUTO JÁ CADASTRADO NO PROTHEUS"
				return .T.
			endif
		endif

		if nOpc == 7
			aHeader := getCopyHeader(cProdOri,aHeader)
			nOpc := 3
		endif
		aHeader	:= FWVetByDic( aHeader, "SB1", .F. ,  )
		aRetorno := U_M010Prod(nOpc, aHeader)
	
		lRetorno := aRetorno[1]
		cErro := ''
		For nX:=1 to Len(aRetorno[2])		
			If !Empty(aRetorno[2][nX])
				cErro += aRetorno[2][nX] + " - "
			EndIf			
		Next nX

		case cTipo == "MATA415"
		//cCod := GetSxeNum("SCJ","CJ_NUM")
		u_putOrcamento(aHeader,aCols,nOpc)
		case cTipo == "FINA050"
		cRotina	:= "FINA050"
		lRetorno := .T.
		nPos	:= aScan(aHeader, {|x| allTrim(x[1]) == "E2_EMISSAO"})
		if nPos > 0
			dDataBase := aHeader[nPos, 2]
		endIf
		//lRetorno := U_F050Inc(aHeader)
		lMsErroAuto := .F.
		
		if nOpc == 5
			nPos := aScan(aHeader, {|x| allTrim(x[1]) == "E2_NUM"})
			aHeader[nPos, 2] := strZero(val(aHeader[nPos,2]), tamSx3("E2_NUM")[1])
			MSExecAuto({|a, b, c, d, e, f, g| Fina050(a, b, c, d, e, f, g)}, aHeader,, 5,,, .t., .t.)
		else
			MSExecAuto({|a, b, c, d, e, f, g| FINA050(a, b, c, d, e, f, g)}, aHeader, nOpc, nil, nil, nil,.f.,.f.)
		endIf

		If lMsErroAuto
			aErro := getAutoGRLog()
			MostraErro("/System","FINA050")
			for nX := 1 to len(aErro)
				cErro += strTran(aErro[nX], CRLF, " ")
			next nX
			lRetorno := .f.
			//conout(MostraErro())
			conout(cErro)
			::cMsg := cErro
			//MostraErro()
		EndIf		

		case cTipo == "PEDIDODECOMPRA"
		cRotina	:= "PEDIDO DE COMPRA"		
		aRetorno := U_ThrPC(nOpc, {aHeader,aCols, aColsAux})
		lRetorno := aRetorno[1]
		aErro := aRetorno[2]
		for nX := 1 to len(aErro)
			cErro += strTran(aErro[nX], CRLF, " ")
		next nX
		case cTipo == "MATA110"
		MSExecAuto({|x,y,z| MATA110(x,y,z)},aHeader,aCols,3) 
		case cTipo == "MATA105"
		MSExecAuto({|x,y,z| MATA105(x,y,z)},aHeader,aCols,3) 
		case cTipo == "CTBA060"
		MSExecAuto({|x, y| CTBA060(x, y)}, aHeader, nOpc)
		otherWise
		lRetorno := .f.
	endCase	

	if lMsErroAuto 
		aErro := getAutoGRLog()
		for nX := 1 to len(aErro)
			cErro += strTran(aErro[nX], CRLF, " ")
		next nX
		//setSoapFault(cRotina, cErro)
		::cMsg := cErro
		if  cTipo == "PRO"
			if SB1->(DBSEEK(XFILIAL("SB1") + alltrim(cProd)  ) )
				::cMsg := "OK"
			endif
		endif
		lRetorno := .F.
	else
		If lRetorno 
			IF cTipo == "TMKA260"
				ConfirmSX8()
				::cMsg := "OK-" + cCod
			elseif cTipo == "MATA415"
				//ConfirmSX8()
				::cMsg := "OK-" + cCod
			else
				::cMsg := "OK"
			endif
		Else
			::cMsg  := cErro	
		endif
		//	lRetorno := .T.
	endIf

	//restArea(aAreaATU)
	if lRetorno
		conout("TRUE")
		::cMsg := "OK"
	else
		conout("FALSE")				
	endif
	conout(::cMsg)

return(.T.)

wsMethod execFunction wsReceive cFuncao, cEmp, cFil, cKey wsSend cMsg wsService wsIpFluig

	local xRet	:= nil
	local lRet	:= .t.
	rpcClearEnv()
	rpcSetType(3)
	rpcSetEnv(::cEmp, ::cFil)


	if !empty(cFuncao)
		xRet := &(::cFuncao)

		if valType(xRet) == "N"
			::cMsg := cValTochar(xRet)
		elseIf valType(xRet) == "D"
			::cMsg := dToC(xRet)
		elseIf valType(xRet) == "L"
			if xRet
				::cMsg := "T"
			else
				::cMsg := "F"
			endIf
		else
			::cMsg := allTrim(xRet)
		endIf
	else
		setSoapFault("ExecFunction", "Informe a função.")
		lRet := .f.
	endIf

return(lRet)

WsMethod getEnd WsReceive cEmpresa WsSend aFiliais WsService wsIpFluig

	Local aArea		
	local nX		:= 0
	local nDados	:= 0
	local aDados	:= {}

	local oApoio	:=	ApoioWS()():New()

	RPCCLEARENV()
	rpcSetType(3)
	rpcSetEnv("01", "01")

	aArea		:= getArea()
	//Verificando todas as filiais da cEmpresa informada
	aDados := oApoio:getFiliais(cEmpresa)

	nDados := len(aDados)

	//Setando todas as filiais de retorno nas variaveis para serem apresentadas no WS.		
	for nX:=1 to nDados

		aAdd(aFiliais, WsClassNew("WsGetFiliais"))

		aTail(aFiliais):cCodigoEmpresa		:=	Alltrim(aDados[nX][1])
		aTail(aFiliais):cCodigoFilial		:=	Alltrim(aDados[nX][2])
		aTail(aFiliais):cNomeFilial			:=	Alltrim(aDados[nX][3])
		aTail(aFiliais):cNome				:=	Alltrim(aDados[nX][4])
		aTail(aFiliais):cEnderecoCobranca	:=	Alltrim(aDados[nX][5])
		aTail(aFiliais):cCidadeCobranca		:=	Alltrim(aDados[nX][6])
		aTail(aFiliais):cEstadoCobranca		:=	Alltrim(aDados[nX][7])
		aTail(aFiliais):cCepCobranca		:=	Alltrim(aDados[nX][8])
		aTail(aFiliais):cResponsRA			:=	Alltrim(aDados[nX][9])

	next nX

	restArea(aArea)

Return(.T.)

static function checkKey(cKey)
	/*
	local lRet	:= .f.

	ZIP->(dbSetOrder(1))
	lRet := ZIP->(dbSeek(xFilial("ZIP") + padR(cKey, 100)))
	*/
return .T.

static function InfoSX3(cCampo)

	local aAliasSX3	:= SX3->(GetArea())
	local aRetorno	:= {0, 0, ""}

	SX3->(dbSetOrder(2))
	SX3->(dbSeek(cCampo))

	if SX3->(found())
		aRetorno[1]	:= SX3->X3_TAMANHO
		aRetorno[2] := SX3->X3_DECIMAL
		aRetorno[3] := SX3->X3_TIPO
	endIf

	restArea(aAliasSX3)

return(aRetorno)

static function getCopyHeader(cProd,aHeader)
	local aHeaderAux := {}
	local nI := 0
	local cListaCampos := getListaCAmpos(aHeader)
	local nJ := 0
	if SB1->(DBSEEK(XFILIAL("SB1") + alltrim(cProd)  ) )
		DbSelectArea("SX3")
		SX3->(DbSetOrder(1))
		if SX3->(dbSeek("SB1"))
			While SX3->(!Eof()) .AND. SX3->X3_ARQUIVO == "SB1"		
				IF ALLTRIM(SX3->X3_CONTEXT) == "R" .OR. ALLTRIM(SX3->X3_CONTEXT) == ""
					AADD(aHeaderAux,{SX3->X3_CAMPO,SB1->&(SX3->X3_CAMPO) ,NIL})				
				endif
				SX3->(DbSkip())
			EndDo		
		endif		

	endif

	for nI:= 1 to len(aHeaderAux)
		if alltrim(aHeaderAux[nI,1]) $ cListaCampos
			for nJ:= 1 to len(aHeader)
				if alltrim(aHeaderAux[nI,1]) == alltrim(aHeader[nJ,1])
					aHeaderAux[nI,2] := aHeader[nJ,2]
				endif
			next nJ
		endif

	next nI

return aHeaderAux


static function getListaCampos(aHeader)
	local cValor := ""
	local nI := 0

	for nI:= 1 to len(aHeader)
		if SUBSTR(aHeader[nI,1], 1, 2) == "B1"
			if empty(cValor)
				cValor := aHeader[nI,1]
			else
				cValor += "|" + aHeader[nI,1]
			endif
		endif

	next nI

return cValor
