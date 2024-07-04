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

WSRESTFUL FINANCIALOURNUMBER DESCRIPTION "Servi�o de gera��o do nosso n�mero" 
	
	WSDATA sourceApp 				AS STRING
	WSDATA companyId 				AS STRING
	WSDATA branchId 				AS STRING	
	WSDATA documentId 				AS STRING //Chave do Protheus //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	
	WSMETHOD GET DESCRIPTION "Retorna o c�digo do nosso n�mero gerado pelo Backoffice Protheus" WSSYNTAX "/FINANCIALOURNUMBER"

END WSRESTFUL

WSMETHOD GET WSRECEIVE sourceApp, companyId, branchId, documentId  WSSERVICE FINANCIALOURNUMBER

Local result		:= .F.

Local cMarca		:= ""
Local cEEmpre		:= ""
Local cEBranc		:= ""
Local cIEmpre		:= ""
Local cIBranc		:= ""
Local cDocumentId   := ""
Local aEmpre        := {}

Local aJason        := {}
Local jsMovim		:= Nil
Local strJs			:= ""
Local cChaveTitulo  := ""
Local cNossoNumero  := ""

DEFAULT ::sourceApp	   := ""
DEFAULT ::companyId	   := ""
DEFAULT ::branchId	   := ""
DEFAULT ::documentId   := ""    


BEGIN SEQUENCE

	cMarca  := ::sourceApp
	cEEmpre := ::companyId
	cEBranc := ::branchId 
	cDocumentId := ::documentId	
	aEmpre := FWEAIEMPFIL(cEEmpre, cEBranc, cMarca)

	If Len (aEmpre) < 2
		SetRestFault(400, "Empresa: " + cEEmpre + " .Filial: " + cEBranc + " .N�o existem para o Produto: " + cMarca + " !")
		Return result
	Else
		cIEmpre := aEmpre[1]
		cIBranc := aEmpre[2] 
	EndIf
	
	//Valida informa��es obrigatorias
	If !VALIDAPARAMS(cMarca,cIEmpre,cIBranc,cDocumentId)
		Return result
	EndIf 
	
	If Len (aEmpre) > 1
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA cIEmpre FILIAL cIBranc TABLES "SE1" MODULO "FIN" 
	EndIf
	
	cChaveTitulo := GetChaveInternaPrt(cMarca, cDocumentId)	
	cNossoNumero := E1NUMBCO(cChaveTitulo)
	UpsertTitulo(cNossoNumero);
		
	::SetContentType("application/json")
	aJason := {}		
	jsMovim  := JsonObject():new()
	
	If ! Empty(cNossoNumero)
	 	jsMovim['nossonumero'] := cNossoNumero
	Else
	 	jsMovim['nossonumero'] := " "
	EndIf					
	AAdd(aJason, jsMovim) 		
	
	If Empty(aJason)
		jsMovim  := JsonObject():new()		
		jsMovim['noData'] := 'N�o existem retornos v�lidos para esta consulta!'		
		AAdd(aJason, jsMovim ) 
	EndIf

	strJs := FWJsonSerialize(aJason,.T.,.T.)	
    ::SetResponse(strJs)    
	result := .T.

RECOVER 	
	
	ErrorBlock(bErrorBlock)
	
	SetRestFault(400, "Ocorreu um problema na execucao do servico: "+ TAB + oError:Description)	
	result := .F.
	Return result

END SEQUENCE 

Return result 


Static Function GetChaveInternaPrt(cMarca, cChaveRM)
Local cChaveProtheus := ""
Local cIntVal := EXTTOINTVAL(cMarca, cChaveRM)
	
If Empty(cIntVal)
	SetRestFault(400, "N�o foi encontrada a chave do RM no De-Para: " + cChaveRM)
Else	
aAux:=Separa(cIntVal,'|')

cChaveProtheus  := padr(aAux[2],TamSx3("E1_FILIAL")[1])
cChaveProtheus  += padr(aAux[3],TamSx3("E1_PREFIXO")[1])
cChaveProtheus  += padr(aAux[4],TamSx3("E1_NUM")[1])
cChaveProtheus  += padr(aAux[5],TamSx3("E1_PARCELA")[1])
cChaveProtheus  += padr(aAux[6],TamSx3("E1_TIPO")[1])
Endif

Return cChaveProtheus


/*
{Protheus.doc} EXTTOINTVAL
@Uso    Verifica as mensagem recebidas de acordo com a integra��o EAI para montagem de DE/PARA
@param  cMarca = Produto de Integracao; cTitulo = Campos recebidos da mensagem REST
@return	Array de informa��o de DE/PARA

@Autor  William Prado- TOTVS
*/
Static Function EXTTOINTVAL(cMarca,cTitulo)
 Local   aIntegra	:= {}
 Local   Teste    := {}
 Local   cAlias   := "SE1"
 Local   cField   := "E1_NUM"
 
 //SUPSETERRHDL("Erro no recebimneto da Referencia do lan�amento")

 //Busca InternalId do lan�amento financeiro
 aIntegra := CFGA070Int(cMarca, cAlias, cField, cTitulo) 
 
 If Empty(aIntegra)
	SetRestFault(400,  " Titulo N�o encontrado: " + cTitulo + " Marca: " + cMarca)
 EndIf

 //SUPRESERRHDL()

 Return (aIntegra)

/*
{Protheus.doc} VALIDAPARAMS
@Uso    Verifica os campos obrigat�rio no recebimento da mensagem REST
@param  Campos recebidos da mensagem REST
@return	.T. -> Processo validado ; .F. -> Processo Interrompido
@Autor  Cristiano Silva Faria - TOTVS
*/
Static Function VALIDAPARAMS(cMarca, cEmpre, cBranc, documentId)				

Local lRet := .T.

If Empty(cMarca) 
	SetRestFault(400, "N�o foi encontrada a informa��o, Aplica��o Solicitante: sourceApp !")
	lRet := .F.
EndIf

If Empty(cEmpre) 
	SetRestFault(400, "N�o foi encontrada a informa��o, Empresa do T�tulo: companyId !")
	lRet := .F.
EndIf

If Empty(cBranc) 
	SetRestFault(400, "N�o foi encontrada a informa��o, Filial do T�tulo: branchId !")
	lRet := .F.
EndIf

If Empty(documentId) 
	SetRestFault(400, "N�o foi encontrada a informa��o, Chave Interna : documentId !")
	lRet := .F.
EndIf

Return lRet

/*
{Protheus.doc} 
@Uso    Atualiza o Nosso N�mero do T�tulo
@Autor  cristiano.faria - TOTVS
@param  Nosso Numero novo gerado pelo Protheus
@return	.T. -> Processo validado ; .F. -> Processo Interrompido
*/
Static Function UpsertTitulo(cNossoNumero)
 
 Reclock("SE1")
 Replace E1_NUMBCO With  cNossoNumero 
 MsUnlock() 

return .T.

/*
{Protheus.doc} E1NUMBCO
@Uso Gera��o do Nosso Numero do t�tulo 
@param Chave do t�tulo para procurar o mesmo e se posicionar.
@return Se conseguiu gerar e o valor do nosso numero gerado
@Autor Cristiano Silva Faria - TOTVS
*/
Static Function E1NUMBCO(cChaveTitulo)
Local cNumBco := ""
//Posiciona do t�tulo que ter� o nosso n�mero gerado
DBSelectArea("SE1")
SE1->(DBSetOrder(1))
 
If SE1->(dbSeek(cChaveTitulo))
   cNumBco := NossoNum() 
Else
   SetRestFault(400, " N�o foi poss�vel localizar o titulo: " + cChaveTitulo )     
EndIf

Return cNumBco

/*
{Protheus.doc} TRATAVARIAVEISERRO
@Uso    Seta c�digo e mensagem de erro 
@param  Objeto de erro
@return	Nenhum
@Autor  Wesley Alves Pereira - TOTVS
*/
Static Function TRATAVARIAVEISERRO(cTitle)
	bError  := { |e| oError := e , oError:Description := cTitle + TAB + oError:Description, Break(e) }
	bErrorBlock    := ErrorBlock( bError )
Return(.T.)

/*
{Protheus.doc} PREPARAVARIAVEISERRO
@Uso    Seta c�digo e mensagem de erro 
@param  Objeto de erro
@return	Nenhum
@Autor  Wesley Alves Pereira - TOTVS
*/
Static Function PREPARAVARIAVEISERRO(cTitle)
	bError  := { |e| oError := e , Break(e) }
	bErrorBlock    := ErrorBlock( bError )
Return(.T.)