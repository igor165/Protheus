#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"

Function LOJA1906C ; Return             

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJCCfgTefDiscado  ºAutor  ³VENDAS CRM  º Data ³  29/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega as configuracoes de TEF discador disponiveis 	      º±± 
±±º          ³para a aplicacao.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß     
*/
Class LJCCfgTefDiscado

	Data cGPAppPath			// Caminho Gerenciador
	Data cGPDirTx           // Arquivo de Envio
	Data cGPDirRx			// Arquivo de Resposta
	Data lGPCCCD			// Retorno CD e CC Habilitado
	Data lGPCheque 			// Retorno se cheque está Habilitado	
	Data cTECBANAppPath		// Caminho do Gerenciador TecBan
	Data cTECBANDirTx      	// Arquivo de Envio TecBan
	Data cTECBANDirRx		// Arquivo de Resposta TecBan
	Data lTECBANCCCD  		// Retorno CD e CC Habilitado TecBan
	Data lTECBANCheque     	// Retorno se cheque está Habilitado TecBan	
	Data cHIPERCDAppPath	// Caminho do Gerenciador HiperCard
	Data cHIPERCDDirTx		// Arquivo de Envio HiperCard
	Data cHIPERCDDirRx		// Arquivo de Envio HiperCard
	Data lHIPERCDCCCD      	// Retorno CD e CC Habilitado  HiperCard
	Data lHIPERCDCheque   	// Retorno se cheque está Habilitado HiperCard
	Data oConFig			// Configuracao
    Data lInfAdm			// Informa a administradora
    Data nVias				//Numero de Vias
    Data nTECVias			//Numero de Vias
    Data nHIPERVias			//Numero de Vias
	
	
	Method New()
	Method Carregar()
	Method Salvar()
	Method RedeDisc()

EndClass                

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³New          ºAutor  ³Vendas CRM       º Data ³  29/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo construtor da classe.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method New() Class LJCCfgTefDiscado
 
	Self:cGPAppPath 		:= ''
	Self:cGPDirTx 			:= ''
	Self:cGPDirRx 			:= ''
	Self:lGPCCCD			:= .F.
	Self:lGPCheque			:= .F.   
	Self:cTECBANAppPath 	:= ''
	Self:cTECBANDirTx 		:= ''
	Self:cTECBANDirRx 		:= ''
	Self:lTECBANCCCD		:= .F.
	Self:lTECBANCheque		:= .F. 
	Self:cHIPERCDAppPath 	:= ''
	Self:cHIPERCDDirTx 		:= ''
	Self:cHIPERCDDirRx 		:= ''
	Self:lHIPERCDCCCD		:= .F.
	Self:lHIPERCDCheque		:= .F.    
	Self:lInfAdm			:= .T. 
	Self:nVias				:= 0
	Self:nTECVias			:= 0
	Self:nHIPERVias			:= 0

Return Self 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Carregar     ºAutor  ³Vendas CRM       º Data ³  29/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega as configuracoes de TEF disponiveis.                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³EXPC1                                                       º±±
±±º          ³Alias da configuracao                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method Carregar(cAlias) Class LJCCfgTefDiscado

	Local lRet := .F.
	
	If Select(cAlias) > 0
		Self:cGPAppPath 		:= AllTrim((cAlias)->MDG_GPAPL)
		Self:cGPDirTx 			:= AllTrim((cAlias)->MDG_GPTX)
		Self:cGPDirRx 			:= AllTrim((cAlias)->MDG_GPRX)
		Self:lGPCCCD			:= IIf((cAlias)->MDG_CARGP=="1",.T.,.F.)
		Self:lGPCheque			:= IIf((cAlias)->MDG_CHQGP=="1",.T.,.F.)   
		Self:cTECBANAppPath 	:= AllTrim((cAlias)->MDG_TECAPL)
		Self:cTECBANDirTx 		:= AllTrim((cAlias)->MDG_TECTX)
		Self:cTECBANDirRx 		:= AllTrim((cAlias)->MDG_TECRX)
		Self:lTECBANCCCD		:= IIf((cAlias)->MDG_CARTEC=="1",.T.,.F.)
		Self:lTECBANCheque		:= IIf((cAlias)->MDG_CHQTEC=="1",.T.,.F.)
		Self:cHIPERCDAppPath 	:= AllTrim((cAlias)->MDG_HIPAPL)
		Self:cHIPERCDDirTx 		:= AllTrim((cAlias)->MDG_HIPTX )
		Self:cHIPERCDDirRx 		:= AllTrim((cAlias)->MDG_HIPRX )
		Self:lHIPERCDCCCD		:= IIf((cAlias)->MDG_CARHIP=="1",.T.,.F.)
		lRet := .T.
	EndIf

	Self:oConFig := LJCConfiguracoesGer():New()	

	If Self:lGPCCCD .OR. Self:lGPCheque

        Self:nVias := STFGetStat( "TEFVIAS" ) 

		Self:RedeDisc("CIELO")
		Self:RedeDisc("AMEX")
		Self:RedeDisc("REDECARD")
		Self:RedeDisc("VISANET")
		Self:RedeDisc("BANRISUL")
		Self:RedeDisc("GETNET")
		Self:RedeDisc("ELAVON")
		Self:RedeDisc("CSHOP")
		Self:RedeDisc("TRIBANCO")
		Self:RedeDisc("POLICARD")
		Self:RedeDisc("FANCARD")
		Self:RedeDisc("BCARD")
		Self:RedeDisc("COOPERCR")
		Self:RedeDisc("VLCARD")
		Self:RedeDisc("TKTCAR")
		Self:RedeDisc("STONE")

	EndIf		
	
	// HIPERCARD
	If Self:lHIPERCDCCCD
		Self:nHIPERVias := STFGetStat( "TEFVIAS" )
		
		Self:RedeDisc("HIPERCARD")
	EndIf
	
	// TECBAN
	If Self:lTECBANCCCD .OR. Self:lTECBANCheque	
		Self:nTECVias := STFGetStat( "TEFVIAS" ) 

		Self:RedeDisc("TECBAN")
	EndIf
	
Return lRet   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Salvar       ºAutor  ³Vendas CRM       º Data ³  29/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Salva as configuracoes de TEF disponiveis.                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³EXPC1                                                       º±±
±±º          ³Alias da configuracao                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method Salvar(cAlias) Class LJCCfgTefDiscado
	
	Local lRet := .F.
		
	If Select(cAlias) > 0
		REPLACE (cAlias)->MDG_GPAPL 	WITH AllTrim(Self:cGPAppPath) 	
		REPLACE (cAlias)->MDG_GPTX 		WITH AllTrim(Self:cGPDirTx) 		
		REPLACE (cAlias)->MDG_GPRX		WITH AllTrim(Self:cGPDirRx) 		
		REPLACE (cAlias)->MDG_CARGP		WITH IIf(Self:lGPCCCD,"1","2")
		REPLACE (cAlias)->MDG_CHQGP		WITH IIf(Self:lGPCheque,"1","2")
		REPLACE (cAlias)->MDG_TECAPL	WITH AllTrim(Self:cTECBANAppPath) 
		REPLACE (cAlias)->MDG_TECTX		WITH AllTrim(Self:cTECBANDirTx) 	
		REPLACE (cAlias)->MDG_TECRX		WITH AllTrim(Self:cTECBANDirRx) 	
		REPLACE (cAlias)->MDG_CARTEC	WITH IIf(Self:lTECBANCCCD,"1","2")	
		REPLACE (cAlias)->MDG_CHQTEC	WITH IIf(Self:lTECBANCheque,"1","2")
		REPLACE (cAlias)->MDG_HIPAPL	WITH AllTrim(Self:cHIPERCDAppPath) 
		REPLACE (cAlias)->MDG_HIPTX		WITH AllTrim(Self:cHIPERCDDirTx) 	
		REPLACE (cAlias)->MDG_HIPRX		WITH AllTrim(Self:cHIPERCDDirRx) 	
		REPLACE (cAlias)->MDG_CARHIP	WITH IIf(Self:lHIPERCDCCCD,"1","2")			
		lRet := .T.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RedeDisc
Carrega as redes do TefDiscado

@type method
@author eduardo.sales
@since 28/12/2018
@version P12
@param cRede, caracter, Nome da Rede Discada
@return 
/*/
//-------------------------------------------------------------------
Method RedeDisc(cRede) Class LJCCfgTefDiscado

Local oConFigGer := Nil

oConFigGer := LJCConfiguracaoGer():New()
oConFigGer:cAdmFin		:= cRede
oConFigGer:cDirTx		:= Self:cGPDirTx
oConFigGer:cDirRx      	:= Self:cGPDirRx
oConFigGer:cAplicacao  	:= Self:cGPAppPath
oConFigGer:lCheque   	:= Self:lGPCheque
Self:oConFig:Add(oConFigGer:cAdmFin, oConFigGer)

Return