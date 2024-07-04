#INCLUDE "LOJA900B.ch"
#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA900B
Função de teste integracao Protheus e-commerce CiaShop envio de Produtos
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample U_ECOM001
/*/
//-------------------------------------------------------------------

User Function ECOM004 //Teste e-commerce

	aParam := {"T1","D MG 01",,"DEBUG"}
	LOJA900B(aParam)
	
REturn

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA900B
Função de teste integracao Protheus e-commerce CiaShop envio de Produtos 
@param   	aParam - Array contendo os dados de execução em Schedule onde: [1] - Empresa, [2] - Filial, [4] - Tarefa
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample LOJA900A()
/*/
//-------------------------------------------------------------------
Function LOJA900B(aParam)
local _lJob := .F. //Execução em Job
Local _cEmp := nil //Empresa
Local _cFil := nil //Filial 
Local cFunction := "LOJA900B" //Rotina
Local lLock := .F. //Semaforo habilitado
Local oLJCLocker	:= Nil               		// Obj de Controle de Carga de dados
Local lCallStack := .F. 							//Chamada de uma pilha de chamadas (1 job que chama todas as rotinas)
Local cName := "" //Chave de travamento
Local cMessage := ""

If Valtype(aParam) != "A" 
	_cEmp := cEmpAnt
	_cFil := cFilant
	
	If Valtype(aParam) = "L"
		lCallStack := aParam
	EndIf
Else

	_lJob :=  .T.
	_cEmp := aParam[1]
	_cFil := aParam[2]
EndIf



If _lJob 
	RPCSetType(3)     
	RpcSetEnv(_cEmp, _cFil,,,"LOJ" ) 	// Seta Ambiente
EndIf

//Gera SEMAFORO - para não dar erro de execução simultanea
oLJCLocker  := LJCGlobalLocker():New()
cName := cFunction+cEmpAnt+cFilAnt

lLock := oLJCLocker:GetLock( cName )

If lLock

	If  ExistFunc("Lj904IntOk") //Verifica os parametros básicos da integração e-commerce CiaShop
		If  !lCallStack .AND. !Lj904IntOk(.T., @cMessage)
			Lj900XLg(cMessage,"") 	
		EndIf
	EndIf
	
	Lj900XLg(STR0001 + cFunction + "[" + cEmpAnt+cFilAnt + "]" + IIF(_lJob, STR0002 + aParam[4] , STR0003) + STR0004 + DTOC(Date()) + " - " + Time() ) //"INICIO DO PROCESSO "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "###" - EM: "
	
	LOJA900BPr(_lJob, lCallStack)
	
	Lj900XLg(STR0005 + cFunction + "[" + cEmpAnt+cFilAnt + "]" + IIF(_lJob, STR0002 + aParam[4] , STR0003) + STR0004 + DTOC(Date()) + STR0006 + Time()) //"FIM DO PROCESSO "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "###" - EM: "###" - "
	
Else
	If !IsBlind()
		MsgAlert(STR0006 + cFunction + "[" + cEmpAnt+cFilAnt + "]")
	EndIf

	Lj900XLg(STR0007 + cFunction + "[" + cEmpAnt+cFilAnt + "]" + IIF(_lJob, STR0002 + aParam[4], STR0003) )	 //"JÁ EXISTE EXECUÇÃO DA ROTINA "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "
EndIf

If lLock
	oLJCLocker:ReleaseLock( cName )
EndIf

If _lJob
	RPCClearEnv()
EndIF

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA900BPr
Função de teste integracao Protheus e-commerce CiaShop envio de Categorias X Produtos
@param   	lAJob - Execução via Schedule - Default .f.
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample Lj900APr()
/*/
//-------------------------------------------------------------------
Function LOJA900BPr(lAJob, lCallStack) 

local cXML := "" //XML envio
Local oWS := NIL //WebService
Local cError   := "" //variavel de Erro
Local cWarning := "" //Variavel de Alerta
local oRetXML  := NIL //Objeto retorno XML
local cAlias   := "" //Alias da Consulta
local cSeq     := "" //Sequencia de execução
local lErro    := .F. //Erro na rotina
local cRetorno := ""//REtorno da Rotina
Local aRecACV := {} //Array de Atualização
Local nXML		 := 0 //XML Pai
Local cProduto := "" //Codigo do produto
Local dDataIni := Date() //Data Inicial do Job
Local cHoraIni := Time() //Hora Inicial do Job
Local nC := 0 //Contador de Categorias
Local lFunRec := FindFunction("Lj900XRL") //Função que realiza o travamento do registro
Local lLock := .F. //Verifica se o registro está bloqueado
Local cFilMGP  := xFilial("MGP")
Local aRegInc := {} //Registros Incluídos

Default lAJob := .F.
Default lCallStack := .F.


cAlias  := GetNextAlias()
//mandar com macrosubstituição
oWS := Lj904WS( )

//Consulta os vinculos que deverão ser enviados
Lj900BCE(cAlias, lCallStack, @aRegInc)

//Resultado da sincronização
cSeq := GETSXENUM("MGP","MGP_SEQ")
CONFIRMSX8()

while !(cAlias)->(EOF())

	If aScan( aRegInc, { |c| c[5] .AND. c[1] == (cAlias)->PRODUTO .AND. ;
										c[2] == (cAlias)->CATEGO  .AND. ;
										c[3] == (cAlias)->OPERACAO  .AND. ;
										c[4] = (cAlias)->ACV_REC } ) > 0 
		//Inclui na tabela SZ2 (Log)
		RecLock("MGP", .T.)
		MGP->MGP_FILIAL  := cFilMGP
		MGP->MGP_SEQ     := cSeq
		MGP->MGP_PRODUT := (cAlias)->PRODUTO
		MGP->MGP_CATEG   := (cAlias)->CATEGO
		MGP->MGP_OP      := (cAlias)->OPERACAO
		MGP->(MsUnLock())


		SB1->( dbSetOrder(1) )
		SB1->( dbSeek( xFilial("SB1") + (cAlias)->PRODUTO ) )
		
		cXML += '<dept_prod'
		
		//Reservado
		cXML += ' xmlns=""'
		
		//Operação: I - Incluir
		//          D - Deletar
		//          U - Atualizar
		cXML += ' op="' + (cAlias)->OPERACAO + '"'
		
		//Código da categoria
		cXML += ' dept_id="' + alltrim((cAlias)->CATEGO) + '"'
		
		//Código do produto
		IF Empty(SB1->B1_PRODPAI)
			cProduto := alltrim((cAlias)->PRODUTO)
			cXML += ' pf_id="' + alltrim((cAlias)->PRODUTO) + '"'
		Else
			cProduto := "VAR"+alltrim((cAlias)->PRODUTO)
			cXML += ' pf_id="' + "VAR"+alltrim((cAlias)->PRODUTO) + '"'
		EndIF
		
		cXML += '/>'
	
		ACU->( dbSetOrder(1) )
		ACU->( dbSeek( xFilial("ACU") + (cAlias)->CATEGO ) )
	
		If !empty(ACU->ACU_CODPAI)
			nXML := 0
			cXML += Lj900BXP((cAlias)->OPERACAO, ACU->ACU_CODPAI, cProduto,@nXML )
		EndIf
	
	EndIf
	
	aAdd(aRecACV, (cAlias)->ACV_REC)
	(cAlias)->(DBSkip())
	
	If len(cXML) >= 55000
		Exit
	EndIf
	
EndDo


(cAlias)->(DbCloseArea())

If !Empty(cXML)
	cXML := '<?xml version="1.0" encoding="ISO-8859-1" standalone="no" ?>' +;
	'<dept_prodList xmlns="dsReceipt.xsd">' +;
	cXML +;
	'</dept_prodList>'
EndIf

Memowrit('envioDptoProd.xml', cXML)


//Somente comunica se há vinculos para enviar
if !Empty(cXML)
	iif(!lAJob, Memowrit('envioDptoProd.xml', cXML), )
	
	//Consome método
	if !oWs:DepartamentosProdutos(, , cXML)
		lErro := .T.
		cRetorno := STR0009 //"Erro ao consumir o método 'DepartamentosProdutos do WebService!"
	else
		iif(!lAJob, MemoWrit('retornoDptoProd.xml', oWs:cXml), )
		
		//Retorna o XML parseado em um objeto com as tags em variáveis
		oRetXML := XmlParser(oWs:cXml, "_", @cError, @cWarning )
		
		if !Empty(cError)
			cRetorno := STR0010 + Chr(13) + cError //"Erro no método XmlParser: "
			cRetorno += Chr(13) + "XML: " + oWs:cXml
			lErro := .T.
		else
			cRetorno := oWs:cXml
			lErro := !oWs:lDepartamentosProdutosResult
		endif
	endif
		
	RecLock("MGM", .T.)
	MGM->MGM_FILIAL  := xFilial("MGM")
	MGM->MGM_SERVIC := "LOJA900B"
	MGM->MGM_SEQ     := cSeq
	MGM->MGM_DATA    := dDataIni
	MGM->MGM_HORAIN  := cHoraIni

	MGM->MGM_XMLENV := cXML
	
	MGM->MGM_XMLRET  := cRetorno
	MGM->MGM_HORAFI := Time()
	if !lErro
		MGM->MGM_RESULT := "1"
	Else
		MGM->MGM_RESULT  := "2"
	endif
	MGM->(msUnLock() )
EndIf



//Grava Flag Enviado
If !lErro	
	SET DELETED OFF 
	//Atualiza registros excluídos
	For nC := 1 to Len(aRecACV)
		ACV->(DbGoTo(aRecACV[nC]))

		lLock := .F.
		
		//Verifica o travamento para não ocorrer concorrência
		If lFunRec	 
			lLock := 	Lj900XRL("ACV", .F., "LOJA900B")
			
		Else
			lLock :=  RecLock("ACV", .F.)
		EndIf
					
		If lLock
			ACV->ACV_ECDTEX := Dtos(Date())
			ACV->ACV_ECSEQ := cSeq
			ACV->(MsUnLock() ) 
		EndIf
		
	Next nC 
	SET DELETED ON
EndIf     

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900BCE
Seleciona os relacionamentos categorias x Produtos a serem enviados 
@param   	cAAlias - Alias de Retorno
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample Lj900BCE(cAAlias)
/*/
//-------------------------------------------------------------------
Static Function Lj900BCE(cAAlias, lCallStack, aRegInc)


local cQuery := "" //String da Consutla
Local cChave := ""
Local aRegInc := {}
Local nPosAtu := 0 //Posicao do registro atual
Local nPos := 0
Local nTot := 0
Local nI := 0 

Default lCallStack := .F.


cQuery += " SELECT  X.* From ("

cQuery += " SELECT ACV_CATEGO CATEGO, ACV_CODPRO PRODUTO, 'U' OPERACAO, ACV.R_E_C_N_O_ AS ACV_REC "
cQuery += " FROM " + RetSqlName("ACV") + " ACV "     

cQuery += " INNER JOIN " + RetSqlName("SB5") + " SB5 "
cQuery += " ON B5_FILIAL = '" + xFilial("SB5") + "' "
cQuery += " AND B5_COD = ACV_CODPRO "
cQuery += " AND B5_ECFLAG = '1' "        //ATIVO
cQuery += " AND SB5.D_E_L_E_T_ <> '*' "  
cQuery += " AND SB5.B5_ECSEQ <> ' ' "   //PRODUTO ENVIADO PARA O SITE                       
cQuery += " AND ACV_ECDTEX = ' ' "

cQuery += " INNER JOIN " + RetSqlName("ACU") + " ACU "
cQuery += " ON ACU_FILIAL = '" + xFilial("ACU") + "' "
cQuery += " AND ACU_COD = ACV_CATEGO "           
cQuery += " AND ACU_ECFLAG = '1' "
cQuery += " AND ACU.D_E_L_E_T_ <> '*' "

cQuery += " WHERE ACV_FILIAL = '" + xFilial("ACV") + "' "
cQuery += " AND ACV.D_E_L_E_T_ <> '*' "


cQuery += " UNION ALL " //Exclui o relacionamento de Produto
    
cQuery += " SELECT ACV_CATEGO CATEGO, ACV_CODPRO PRODUTO, 'D' OPERACAO, ACV.R_E_C_N_O_ AS ACV_REC "
cQuery += " FROM " + RetSqlName("ACV") + " ACV "     

cQuery += " INNER JOIN " + RetSqlName("SB5") + " SB5 "
cQuery += " ON B5_FILIAL = '" + xFilial("SB5") + "' "
cQuery += " AND B5_COD = ACV_CODPRO "
cQuery += " AND B5_ECFLAG = '2' "     //INATIVO   
cQuery += " AND SB5.D_E_L_E_T_ <> '*' " 
cQuery += " AND SB5.B5_ECSEQ <> ' ' "   //PRODUTO ENVIADO PARA O SITE                  
cQuery += " AND ACV_ECDTEX = ' ' "

cQuery += " INNER JOIN " + RetSqlName("ACU") + " ACU "
cQuery += " ON ACU_FILIAL = '" + xFilial("ACU") + "' "
cQuery += " AND ACU_COD = ACV_CATEGO "           
cQuery += " AND ACU_ECFLAG = '1' "
cQuery += " AND ACU.D_E_L_E_T_ <> '*' "

cQuery += " WHERE ACV_FILIAL = '" + xFilial("ACV") + "' "
cQuery += " AND ACV.D_E_L_E_T_ <> '*' "

cQuery += " UNION ALL " //RELACIONAMENTO Prod X Cat EXCÚIDO EC
    
cQuery += " SELECT ACV_CATEGO CATEGO, ACV_CODPRO PRODUTO, 'D' OPERACAO, ACV.R_E_C_N_O_ AS ACV_REC "
cQuery += " FROM " + RetSqlName("ACV") + " ACV "     

cQuery += " INNER JOIN " + RetSqlName("SB5") + " SB5 "
cQuery += " ON B5_FILIAL = '" + xFilial("SB5") + "' "
cQuery += " AND B5_COD = ACV_CODPRO "
cQuery += " AND B5_ECFLAG <> ' ' "
cQuery += " AND SB5.B5_ECSEQ <> ' ' "   //PRODUTO ENVIADO PARA O SITE       
cQuery += " AND SB5.D_E_L_E_T_ <> '*' "              

cQuery += " INNER JOIN " + RetSqlName("ACU") + " ACU "
cQuery += " ON ACU_FILIAL = '" + xFilial("ACU") + "' "
cQuery += " AND ACU_COD = ACV_CATEGO "           
cQuery += " AND ACU_ECFLAG = '1' "
cQuery += " AND ACU.D_E_L_E_T_ <> '*' "

cQuery += " WHERE ACV_FILIAL = '" + xFilial("ACV") + "' "
cQuery += " AND ACV_ECDTEX = ' ' "
cQuery += " AND ACV.D_E_L_E_T_ = '*' " //RELACIONAMENTO EXCLUÍDO ec

cQuery += " ) X  ORDER BY CATEGO, PRODUTO, OPERACAO, ACV_REC "

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cAAlias, .F., .T.)

//Processa as operações que estão repetidas  e mantém a ultima
Do While !(cAAlias)->(Eof())
	cChave := (cAAlias)->PRODUTO + (cAAlias)->CATEGO + (cAAlias)->OPERACAO
	If ( nPos :=  aScan( aRegInc , { |c|  c[5] .and. c[1] == (cAAlias)->PRODUTO  .AND. c[2] ==(cAAlias)->CATEGO .AND.  C[3] == (cAAlias)->OPERACAO  } ) ) > 0 //Existe uma mesma operação ativa
		nTot := Len(aRegInc)
		For nI := nPos to nTot	

			//Parou de processar o mesmo produto e categoria, sai do laço
			If !(aRegInc[nI, 1] == (cAAlias)->PRODUTO .AND. aRegInc[nI, 2] == (cAAlias)->CATEGO)
				Exit
				
			ElseIf aRegInc[nI, 5] .AND. (aRegInc[nI, 1] == (cAAlias)->PRODUTO .AND. ;
										aRegInc[nI, 2] == (cAAlias)->CATEGO .AND. ;
										aRegInc[nI, 3] == (cAAlias)->OPERACAO)
				aRegInc[nI, 5] := .F.
			
			EndIf

		Next nI 
	EndIf
	aAdd(aRegInc, { (cAAlias)->PRODUTO, ;
					(cAAlias)->CATEGO, ;
					(cAAlias)->OPERACAO, ;
					(cAAlias)->ACV_REC, ;
					.T. })
					
	(cAAlias)->(DbSkip(1))
EndDo

(cAAlias)->(DbGotop())
If lCallStack .AND. FindFunction("Lj900XRC")
	 Lj900XRC( cAAlias, "LOJA900B")
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900BXP
Gera o XML do Relacionamento Produto X Categoria-pai
@param   	cOperacao -  Operacao do XML (I, U,D)
@param   	cCategoria - Codigo da Categoria
@param   	cProduto - Codigo do Produto
@param   	nXML - Contador de Estruturas
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample Lj900BXP(cOperacao, cCategoria, cProduto, @nXML)
/*/
//-------------------------------------------------------------------
Static Function Lj900BXP(cOperacao, cCategoria, cProduto, nXML)

	Local cXML := "" //xml Envio

	nXML++
	IF nXML >= 10
		Return cXML
	EndIF
	
	cXML += '<dept_prod'
	
	//Reservado
	cXML += ' xmlns=""'
	
	//Operação: I - Incluir
	//          D - Deletar
	//          U - Atualizar
	cXML += ' op="' + cOperacao + '"'
	
	//Código da categoria
	cXML += ' dept_id="' + alltrim(cCategoria) + '"'
	
	//Código do produto
	cXML += ' pf_id="' + alltrim(cProduto) + '"'

	cXML += '/>'

	ACU->( dbSetOrder(1) )
	ACU->( dbSeek( xFilial("ACU") + cCategoria ) )

	IF !empty(ACU->ACU_CODPAI)
		cXML += Lj900BXP(cOperacao, ACU->ACU_CODPAI, cProduto, @nXml)
	EndIF


Return cXML




