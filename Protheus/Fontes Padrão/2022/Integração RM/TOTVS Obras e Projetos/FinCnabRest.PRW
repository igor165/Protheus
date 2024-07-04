#Include "RESTFUL.CH"
#Include "TOTVS.CH"
#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TopConn.ch"
#Include "FWAdapterEAI.ch"  
#Include "COLORS.CH"                                                                                                     
#Include "TBICONN.CH"
#Include "COMMON.CH"
#Include "XMLXFUN.CH"
#Include "fileio.ch" 


#DEFINE  TAB  CHR ( 13 ) + CHR ( 10 )

WSRESTFUL FINANCIALMOVEMENTSCNAB DESCRIPTION "Retorno financeiro de titulos baseado no ID Cnab" 

	WSDATA sourceApp AS STRING
	WSDATA companyId AS STRING
	WSDATA branchId AS STRING
	
	WSDATA CNABNumberID	AS STRING
	
	WSMETHOD GET DESCRIPTION "Retorna os titulos remetidos a banco baseado em um ID CNAB informado" WSSYNTAX "/FINANCIALMOVEMENTSCNAB || /FINANCIALMOVEMENTSCNAB/{id}"
		
END WSRESTFUL

WSMETHOD GET WSRECEIVE sourceApp, companyId, branchId, CNABNumberID WSSERVICE FINANCIALMOVEMENTSCNAB

Local lMetodo		:= .F.

Local cMarca		:= ""
Local cEEmpre		:= ""
Local cEBranc		:= ""
Local cIEmpre		:= ""
Local cIBranc		:= ""
Local cNumCNAB      := ""
Local aEmpre        := {}

Local aJason        := {}
Local jsMovim		:= Nil
Local strJs			:= ""

DEFAULT ::sourceApp	   := ""
DEFAULT ::companyId	   := ""
DEFAULT ::branchId	   := ""  

DEFAULT ::CNABNumberID := ""

BEGIN SEQUENCE

	cMarca := ::sourceApp
	cEEmpre := ::companyId
	cEBranc := ::branchId 
		  
	cNumCNAB := ::CNABNumberID 

    aEmpre:= FGETDEPARAEMP(cEEmpre, cMarca)
        
	If Len (aEmpre) < 1
		SetRestFault(400, "Empresa: " + cEEmpre + " Não existem para o Produto: " + cMarca + " !")
		Return lMetodo
	Else
		cIEmpre := aEmpre[1]
		If Len (aEmpre) > 1
		  cIBranc := aEmpre[2]
		Endif 
	EndIf
	
	//Valida informações obrigatorias
	If !SUPCPOOBR(cMarca,cIEmpre,cIBranc,cNumCNAB)
		Return lMetodo
	EndIf 

	If Len (aEmpre) > 1
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA cIEmpre FILIAL cIBranc TABLES "SE1", "SE5", "SEE", "SA1" MODULO "FIN" 
	EndIf
	
	//Reset o erro
	SUPRESERRHDL()
	
	//Deixa setado o erro, caso ocorra
	SUPSETERRHDL("Nao foi possivel acessar o banco de dados!")
	
	If !SUPREADSQL(cNumCNAB)
		Return (lMetodo)
	EndIf	

	SUPSETERRHDL("Problema na montagem do retorno REST/JASON")

	::SetContentType("application/json")
		
	DBSelectArea("FIN")
	FIN->(DBGoTop())
	
	aJason := {}
	
	Do While FIN->( !EOF() )
		
		jsMovim  := JsonObject():new()
		
		jsMovim['filial']	          := FIN->E1_FILIAL
		jsMovim['prefixo']            := FIN->E1_PREFIXO
		jsMovim['titulo'] 	          := FIN->E1_NUM
		jsMovim['parcela'] 	          := FIN->E1_PARCELA
		jsMovim['tipoParcela'] 	      := FIN->E1_TIPO
		jsMovim['cliente'] 	          := IntCliExt(, , FIN->E1_CLIENTE, FIN->E1_LOJA)[2]
		If ! Empty(FIN->E1_PORTADO)
		 	jsMovim['banco'] 	          := M70MontInt( cFilAnt, FIN->E1_PORTADO, FIN->E1_AGEDEP, FIN->E1_CONTA )
		Else
		 	jsMovim['banco'] 	          := " "
		EndIf
		jsMovim['documento']          := F55MontInt(,FIN->E1_PREFIXO,FIN->E1_NUM,FIN->E1_PARCELA,FIN->E1_TIPO,,,'SE1')		
		jsMovim['DataEmissao'] 	      := FIN->E1_EMISSAO 
		jsMovim['datavencimento'] 	  := FIN->E1_VENCTO 
		jsMovim['dataVencimentoReal'] := FIN->E1_VENCREA
		jsMovim['valor'] 	          := FIN->E1_VALOR 
		jsMovim['saldo'] 	          := FIN->E1_SALDO 
		jsMovim['acrescimo'] 	      := FIN->E1_ACRESC 
		jsMovim['saldoAcrescimo'] 	  := FIN->E1_SDACRES 
		jsMovim['decrescimo'] 	      := FIN->E1_DECRESC 
		jsMovim['saldoDecrescimo'] 	  := FIN->E1_SDDECRE 
		jsMovim['statusParcela'] 	  := FIN->E1_STATUS 
		jsMovim['origem'] 	          := FIN->E1_ORIGEM
		jsMovim['situacao'] 	      := FIN->E1_SITUACA 
		jsMovim['idcnab'] 	          := FIN->E1_IDCNAB 
		jsMovim['aglutinador'] 	      := FIN->E1_XTITAGL		 
		
		AAdd(aJason, jsMovim ) 
	
		FIN->(DBSkip())

	Enddo
	
	If Empty(aJason)

		jsMovim  := JsonObject():new()
		
		jsMovim['noData'] := 'Não existem retornos válidos para esta consulta!'
		
		AAdd(aJason, jsMovim ) 

	EndIf

	strJs := FWJsonSerialize(aJason,.T.,.T.)
	
    ::SetResponse(strJs)
    
	lMetodo := .T.

RECOVER 	
	
	ErrorBlock(bErrorBlock)
	
	SetRestFault(400, "Ocorreu um problema na execucao do servico: "+ TAB + oError:Description)	
	lMetodo := .F.
	Return lMetodo

END SEQUENCE 

Return lMetodo 


/*
{Protheus.doc} FGETDEPARAEMP
@Uso    Retorna o De Para da Empresa
@param  Campos recebidos da mensagem REST Empresa e Marca
@return	Vetor com empresa e filial
@Autor  Wesley Alves Pereira - TOTVS
*/
static Function FGETDEPARAEMP(cEEmpre, cMarca)
Local aVet    := {}
Private cQry  := ""

SUPSETERRHDL("Problema na criação da query de retorno !")

If Select("FIN") > 0
	FIN->(DbCloseArea())
Endif

cQry +=  "   SELECT 					" + TAB 
cQry +=  "			XXD_REFER, 			" + TAB
cQry +=  "  		XXD_COMPA, 		    " + TAB
cQry +=  " 			XXD_BRANCH, 		" + TAB
cQry +=  " 			XXD_EMPPRO, 		" + TAB
cQry +=  " 			XXD_FILPRO          " + TAB
cQry +=  "   FROM  XXD                  " + TAB
cQry +=  "   WHERE D_E_L_E_T_ <> '*'	" + TAB
cQry +=  "   AND  XXD_REFER  ='" + ALLTRIM(cMarca)  + "'" + TAB
cQry +=  "   AND  XXD_COMPA = '" + ALLTRIM(cEEmpre) + "'" + TAB
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), "FIN", .T., .T. )
Do While FIN->( !EOF() )
  AADD(aVet , FIN->XXD_EMPPRO)
  AADD(aVet , FIN->XXD_FILPRO)
  FIN->(DBSkip())
EndDo
return aVet

/*
{Protheus.doc} SUPCPOOBR
@Uso    Verifica os campos obrigatório no recebimento da mensagem REST
@param  Campos recebidos da mensagem REST
@return	.T. -> Processo validado ; .F. -> Processo Interrompido
@Autor  Wesley Alves Pereira - TOTVS

*/

Static Function SUPCPOOBR(cMarca,cEmpre,cBranc,cNumCNAB)				

Local lRet := .T.

If Empty(cMarca) 
	SetRestFault(400, "Não foi encontrada a informação: sourceApp !")
	lRet := .F.
EndIf

If Empty(cEmpre) 
	SetRestFault(400, "Não foi encontrada a informação: companyId !")
	lRet := .F.
EndIf

If Empty(cBranc) 
	SetRestFault(400, "Não foi encontrada a informação: branchId !")
	lRet := .F.
EndIf

If Empty(cNumCNAB) 
	SetRestFault(400, "Não foi encontrada a informação: CNABNumberID !")
	lRet := .F.
EndIf

Return lRet

/*
{Protheus.doc} SUPREADSQL
@Uso    Prepara o arquivo de trabalho montado na query 
@param  Projeto, Revisao, Contrato
@return	Nenhum
@Autor  Wesley Alves Pereira - TOTVS
*/

Static Function SUPREADSQL(cNumCNAB)

Private cQry	:= ""  

SUPSETERRHDL("Problema na criação da query de retorno !")

DBSelectArea("SE1")
SE1->(DBSetOrder(1))

DBSelectArea("SE5")
SE5->(DBSetOrder(1))

DBSelectArea("SEE")
SEE->(DBSetOrder(1))

DBSelectArea("SA1")
SA1->(DBSetOrder(1))

If Select("FIN") > 0
	FIN->(DbCloseArea())
Endif

cQry +=  " WITH FIN1 AS ( 				" + TAB
cQry +=  "   SELECT 					" + TAB 
cQry +=  "			E1_FILIAL, 			" + TAB
cQry +=  "  		E1_PREFIXO, 		" + TAB
cQry +=  " 			E1_NUM, 			" + TAB
cQry +=  " 			E1_PARCELA, 		" + TAB
cQry +=  " 			E1_TIPO, 			" + TAB
cQry +=  " 			E1_CLIENTE, 		" + TAB
cQry +=  " 			E1_LOJA, 			" + TAB
cQry +=  " 			E1_EMISSAO, 		" + TAB
cQry +=  " 			E1_VENCTO, 			" + TAB
cQry +=  " 			E1_VENCREA, 		" + TAB
cQry +=  " 			E1_VALOR, 			" + TAB
cQry +=  " 			E1_SALDO, 			" + TAB
cQry +=  " 			E1_ACRESC, 			" + TAB
cQry +=  " 			E1_SDACRES, 		" + TAB
cQry +=  " 			E1_DECRESC, 		" + TAB
cQry +=  " 			E1_SDDECRE,			" + TAB
cQry +=  " 			E1_NUMBCO,			" + TAB
cQry +=  " 			E1_PORTADO,			" + TAB
cQry +=  " 			E1_AGEDEP,			" + TAB
cQry +=  " 			E1_CONTA,			" + TAB
cQry +=  " 			E1_STATUS,			" + TAB
cQry +=  " 			E1_ORIGEM,			" + TAB
cQry +=  " 			E1_SITUACA,			" + TAB
cQry +=  " 			E1_IDCNAB,			" + TAB
cQry +=  " 			E1_XTITAGL			" + TAB

cQry +=  "   FROM  " + RetSqlName("SE1") + " SE1 " + TAB
cQry +=  "   WHERE SE1.D_E_L_E_T_ <> '*'		 " + TAB
cQry +=  "   AND   SE1.E1_IDCNAB = '"+cNumCNAB+"'"  + TAB //0000007360

cQry +=  " )									" + TAB 

cQry +=  " SELECT * FROM FIN1					" + TAB
cQry +=  " UNION ALL							" + TAB
cQry +=  " SELECT								" + TAB 
cQry +=  " 			FIN2.E1_FILIAL,				" + TAB
cQry +=  " 			FIN2.E1_PREFIXO,			" + TAB
cQry +=  " 			FIN2.E1_NUM,				" + TAB
cQry +=  " 			FIN2.E1_PARCELA,			" + TAB
cQry +=  " 			FIN2.E1_TIPO,				" + TAB
cQry +=  " 			FIN2.E1_CLIENTE,			" + TAB
cQry +=  " 			FIN2.E1_LOJA,				" + TAB
cQry +=  " 			FIN2.E1_EMISSAO,			" + TAB
cQry +=  " 			FIN2.E1_VENCTO,				" + TAB
cQry +=  " 			FIN2.E1_VENCREA,			" + TAB
cQry +=  " 			FIN2.E1_VALOR,				" + TAB
cQry +=  " 			FIN2.E1_SALDO,				" + TAB
cQry +=  " 			FIN2.E1_ACRESC,				" + TAB
cQry +=  " 			FIN2.E1_SDACRES,			" + TAB
cQry +=  " 			FIN2.E1_DECRESC,			" + TAB
cQry +=  " 			FIN2.E1_SDDECRE,			" + TAB
cQry +=  " 			FIN2.E1_NUMBCO,				" + TAB
cQry +=  " 			FIN2.E1_PORTADO,			" + TAB
cQry +=  " 			FIN2.E1_AGEDEP,				" + TAB
cQry +=  " 			FIN2.E1_CONTA,				" + TAB
cQry +=  " 			FIN2.E1_STATUS,				" + TAB
cQry +=  " 			FIN2.E1_ORIGEM,				" + TAB
cQry +=  " 			FIN2.E1_SITUACA,			" + TAB
cQry +=  " 			FIN2.E1_IDCNAB,				" + TAB
cQry +=  " 			FIN2.E1_XTITAGL				" + TAB
cQry +=  " FROM FIN1, "+ RetSqlName("SE1") + " FIN2	" + TAB

cQry +=  " WHERE FIN2.D_E_L_E_T_ <> '*'			 " + TAB
cQry +=  " AND FIN1.E1_NUM = FIN2.E1_XTITAGL	 " + TAB

	
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), "FIN", .T., .T. )

SUPRESERRHDL()

Return (.T.)

/*
{Protheus.doc} SUPSETERRHDL
@Uso    Seta código e mensagem de erro 
@param  Objeto de erro
@return	Nenhum
@Autor  Wesley Alves Pereira - TOTVS
*/
Static Function SUPSETERRHDL(cTitle)
	bError  := { |e| oError := e , oError:Description := cTitle + TAB + oError:Description, Break(e) }
	bErrorBlock    := ErrorBlock( bError )
Return(.T.)

/*
{Protheus.doc} SUPRESERRHDL
@Uso    Seta código e mensagem de erro 
@param  Objeto de erro
@return	Nenhum
@Autor  Wesley Alves Pereira - TOTVS
*/
Static Function SUPRESERRHDL(cTitle)
	bError  := { |e| oError := e , Break(e) }
	bErrorBlock    := ErrorBlock( bError )
Return(.T.)