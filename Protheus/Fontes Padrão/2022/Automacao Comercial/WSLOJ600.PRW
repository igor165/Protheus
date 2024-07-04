#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "AUTODEF.CH" 
#INCLUDE "WSLOJ600.CH"

#Define __L2_VLRITEM  05
#Define __L2_VRUNIT   04 
#Define __L2_PRODUTO  01 
#Define __L2_DESCRI   02 
#Define __L2_QUANT    03 


#Define __L4_DATA    01
#Define __L4_FORMA   02
#Define __L4_VALOR   03
#Define __PORTE      04 
#Define __L4_CHEQID  05
#Define __L4_NUMCART 06 
#Define __L4_ADMINIS 07 
#Define __L4_AGENCIA 08
#Define __L4_CONTA   09  
#Define __L4_COMP 	  10
#Define __L4_MOEDA   11
#Define __L4DATA     12 
#Define __L4_DOCTEF  13
#Define __L4_FORMAID 14 
#Define __L4lEstorn  15 
#Define __L4_DATATEF 16
#Define __L4_NSUTEF  17
#Define __L4_DOCCANC 18
#Define __L4_HORCANC 19
#Define __L4_DATCANC 20
#Define __E1_PARCELA 21 
#Define __L4_RECNO	 22 
#Define __L4_TAMANHO 22	  

#Define __L4_TAMANHO 21

#Define __L4_TAMANHO 19


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebService|LjEstOrc         ºAutor  ³Fabiana Cristina    º Data ³  22/11/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Classe de WebService para consulta do orçamento na retaguarda      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja                                                  		 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  

WSStruct tRetOrc
	WSData Orcamento     As String
	WsData Orc_Emissao   As String
	WsData Orc_Situa     As String 
	WsData Orc_StOrc     As String 
	WsData Orc_Tipo      As String  
	WsData Orc_Opera     As String
    WsData Orc_Pdv  	 As String
    WsData Orc_Cli       As String
    WsData Orc_Ven       As String                                                       
    WsData Orc_VlMer     As Float
    WsData Orc_Desc      As Float
    WsData Orc_VlLiq     As Float
    WsData Orc_Valid     As String  
    WsData Orc_Abat      As Float                                                
    WsData Orc_PedCli    As String
    WsData Orc_VlTot     As Float
    WsData Orc_Moeda     As Integer	
    WsData Orc_StatuEs   As String
    WsDAta Orc_Loja		 As String      
    WsData Orc_VendTEF   As String
	WsData Orc_DocCanc 	 As String
	WsDAta Orc_FormPg 	 As String 
	WsData Orc_DocTEF    As String    
	WsData Orc_MovFe     As Boolean                                                      //Forma de Pagamento do Orçamento
	WsData Orc_Institu   As String
	WsData Orc_Cupom 	 As String   
	WsData Serie         AS String
	WsData CliPad     As Boolean 
EndWSStruct



WSStruct tRet_Itens
	WSData L2_VlrItem   As Float
	WSData L2_VrUnit    As Float
	WSData L2_Produto   As String
	WSData L2_Descri    As String
	WSData L2_Quant     As Float
EndWSStruct



WsStruct tRetPgOrc
	WSData L4_Data As String
	WSData L4_Forma As String
	WSData L4_Valor As Float
	WSData Porte As String
	WSData L4_CheqId As String 
	WSData L4_NumCart As String 
	WSData L4_Adminis	As String 
	WSData L4_Agencia As String 
	WSData L4_Conta As String 
	WSData L4_Comp As String
	WSData L4_Moeda AS Integer 
	WSData L4Data As String 
	WsData L4_DATATEF As String
	WsData L4_DOCTEF  As String
	WsData L4_NSUTEF As String
	WsData L4_FORMAID As String
	WsData E1_PARCELA As String
	WSData L4_RECNO AS Integer	
EndWsStruct  

WsStruct tRetItOrc 
    WsData Orc_Imp As Float
   	WsData Orc_ImpIn As Float
	WsData Orc_Itens As Array Of tRet_Itens
EndWsStruct 

WsStruct tRetSE5
	WsData Chave As String //Chave do SE5 E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ+E5_RECPAG                                                                                                                                                                                             
	WsData Indice As Integer //Indice da chave do SE5 := 7
	WsData E5_TIPODOC As String //Tipo do Documento
	WsData E5_DATA As Date //Data da movimentação
	WsData E5_AGENCIA  As String//Agencia da Conta
	WsData E5_TIPO As String //Tipo do Título  
	WsData E5_VALOR As Float//Valor do Lançamento        
	WsData E5_BANCO As String//Código do Banco   
	WsData E5_CONTA As String//Conta Corrente do Banco
	WsData E5_RECPAG As String//Recebimento ou Pagamento 
	WsData E5_MOTBX As String//Motivo da Baixa do Título
EndWsStruct

WsStruct tRetSE1
    WsData Chave As String //Chave do SE1E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO                                                                                                                  
	WsData Indice As Integer //Indice da chave do SE1 =:1
   	WsData E1_SITUACA As String//Situacao do titulo
	WsData E1_EMISSAO As Date//Emissão do título
	WsData E1_VENCTO As Date//Vencimento do tótulo
	WsData E1_BAIXA As Date//Data da Baixa do título
	WsData E1_STATUS AS String//Status do título
	WsData E1_PARCELA As String//Parcela do título
	WsData E1_TIPO   As String//Tipo do Título
	WsData E1_SALDO  As Float//Saldo do título
	WsData E1_ORIGEM As String//Origem do título    
	WsData E1_VALOR  As Float//Valor do título
	WsData E1_NUMCRD As String//Numero do Contrato de financiamento
	WsData E1_PORTADO As String//Portador do Título 
	WsData E1_VLRREAL AS Float//Valor Real do título
	WsData E1_FLUXO  As String//Fluxo de Caixa      
	WsData aSE5 as Array of tRetSE5 OPTIONAL      //Pagamentos do Título   
EndWsStruct         

WsStruct tRetSEF 
	WsData EF_BANCO	As String
	WsData EF_AGENCIA As String
	WsData EF_CONTA As String
	WsData EF_NUM As String
	WsDAta EF_VALOR As Float
EndWsStruct


WSService LjEstOrc DESCRIPTION STR0001 //"Serviço de consulta das informações do orçamento."
	
	WSData cNumCupom    As String  
	WSData cSerie       As String 
	WsData cPDV         As String
	WsData oOrcamento   As tRetOrc 
	WsData lOrcDev		As Boolean  
	WsData cOrc			As String  
	WsData oOcmtoIt     As tRetItOrc     
	WsData oOrc_Pg      As Array Of tRetPgOrc
	WsData nMoeda       As Integer   
	WsData lOrcRes	    As Boolean
	WsData aSE1		    As Array Of tRetSE1
	WsData lPorteCx		As Boolean
	WsData oSEF         As tRetSEF OPTIONAL  
	WsData cDataBase	AS String    
	WsData cEmpWs		As String
	WsData cFilWs		As String

	
	//Metodos que sao executados pelo WEBSERVICE 
	
	WSMethod LjEstOrcBus            DESCRIPTION STR0002 //"Consultar um orçamento."
	WsMethod LjEstOrcDev            DESCRIPTION STR0003 //"Verificar se o orçamento foi devolvido."
	WsMethod LjEstOrcIt             DESCRIPTION STR0004 //"Consultar os itens do orçamento."   
	WsMethod LjEstOrcPg             DESCRIPTION STR0005 //"Consultar os pagamentos do orçamento."  
	WsMethod LjEstOrcVRe            DESCRIPTION STR0006//"Validar o orçamento com reserva."   
	WsMethod LjEstOrcTit			DESCRIPTION STR0007 //"Buscar os titulos e baixas do orcamento."   
	WsMethod LjEstOrcChq			Description STR0008   //"Buscar os cheques do orçamento."
	
EndWSService
          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    |LjEstOrcBus      ºAutor  ³Fabiana Cristina    º Data ³  22/11/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo que busca um orcamento na retaguarda.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja                                                  		 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMethod LjEstOrcBus WSReceive cNumCupom, cSerie, cEmpWs, cFilWs WSSend oOrcamento WSService LjEstOrc

//Formata os parametros do Ponto de Entrada
Local oEstorno  := Nil 
Local oRetOrc   := Nil      
Local lPrepEnv	:= If(FindFunction('LjPreparaWs'),LjPreparaWs(cEmpWs, cFilWs), .F.)


::oOrcamento := WSClassNew("tRetOrc")

//Instancia o Objeto estorno    
oEstorno := LjClEstVen():New(cSerie,"", "", dDataBase,0, .T.)   
   
oRetOrc := oEstorno:BuscaOrcamento(cNumCupom, cSerie)  

::oOrcamento:Orcamento   := oRetOrc:cOrcamento
::oOrcamento:Orc_Emissao := DtoS(oRetOrc:dOrc_Emissao)
::oOrcamento:Orc_Situa   := oRetOrc:cOrc_Situa 
::oOrcamento:Orc_StOrc   := oRetOrc:cOrc_StOrc  
::oOrcamento:Orc_Tipo    := oRetOrc:cOrc_Tipo   
::oOrcamento:Orc_Opera   := oRetOrc:cOrc_Opera                                                       //Operador do Orcamento
::oOrcamento:Orc_Pdv  	 := oRetOrc:cOrc_Pdv                                                    //Pdv do Orcamento
::oOrcamento:Orc_Cli     := oRetOrc:cOrc_Cli                                                        //Cliente do Orcamento
::oOrcamento:Orc_Ven     := oRetOrc:cOrc_Ven                                                        //Vendedor do Orcamento
::oOrcamento:Orc_VlMer   := oRetOrc:nOrc_VlMer                                                      //Total de Mercadoria
::oOrcamento:Orc_Desc    := oRetOrc:nOrc_Desc                                                       //Desconto
::oOrcamento:Orc_VlLiq   := oRetOrc:nOrc_VlLiq                                                      //Valor Liquido
::oOrcamento:Orc_Valid   := DtoS(oRetOrc:dOrc_Valid)                                                     //Validade do Orcamento     
::oOrcamento:Orc_Abat    := oRetOrc:nOrc_Abat                                                       //Total de abatimentos do orcamemto                                                   
::oOrcamento:Orc_PedCli  := oRetOrc:cOrc_PedCli 
::oOrcamento:Orc_VlTot   := oRetOrc:nOrc_VlTot
::oOrcamento:Orc_Moeda   := oRetOrc:nOrc_Moeda 
::oOrcamento:Orc_StatuEs := oRetOrc:cOrc_StatuES
::oOrcamento:Orc_Loja	 := oRetOrc:cOrc_loja 
::oOrcamento:Orc_VendTEF := oRetOrc:cOrc_VendTEF
::oOrcamento:Orc_DocCanc := oRetOrc:cOrc_DocCanc
::oOrcamento:Orc_FormPg	 := oRetOrc:cOrc_FormPg 
::oOrcamento:Orc_DocTEF  := oRetOrc:cOrc_DocTEF   
::oOrcamento:Orc_MovFe   := oRetOrc:lOrc_MovFe     
::oOrcamento:Orc_Institu := oRetOrc:cOrc_Institu   
::oOrcamento:Orc_Cupom	 := oRetOrc:cOrc_Cupom
::oOrcamento:Serie		 := oRetOrc:cSerie
::oOrcamento:CliPad      := oRetOrc:lCliPad 


Return .T.  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    |LjEstOrcDev      ºAutor  ³Fabiana Cristina    º Data ³  23/11/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo que verifica se o Orcamento foi devolvido                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja                                                  		 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMethod LjEstOrcDev WSReceive cOrc, cEmpWs, cFilWs WSSend lOrcDev WSService LjEstOrc      
//Formata os parametros do Ponto de Entrada
Local oEstorno  := Nil    
Local lPrepEnv	:= If (FindFunction('LjPreparaWs'),LjPreparaWs(cEmpWs, cFilWs), .F.)

::lOrcDev := .F.     

//Instancia o Objeto estorno    
oEstorno := LjClEstVen():New(nil,nil, nil,nil,nil, .T.) 

::lOrcDev := oEstorno:OrcDevolvido(cOrc) //método que estorna o orcamento 

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    |LjEstOrcIt       ºAutor  ³Fabiana Cristina    º Data ³  25/11/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo que retorna os itens do orcamento                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja                                                  		 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMethod LjEstOrcIt WSReceive cOrc, nMoeda, cEmpWs, cFilWs WSSend oOcmtoIt WSService LjEstOrc   
//Formata os parametros do Ponto de Entrada       
Local oEstorno  := Nil 
Local nC 		:= 0   
Local lPrepEnv	:= If (FindFunction('LjPreparaWs'),LjPreparaWs(cEmpWs, cFilWs), .F.)
 
	                       
::oOcmtoIt := WSClassNew("tRetItOrc")


//Instancia o Objeto estorno    
oEstorno := LjClEstVen():New(Nil,"", "", nil,0, .T.)   
oEstorno:nOrc_Moeda := nMoeda
   
oEstorno:BuscaItensOrcamento(cOrc)  


::oOcmtoIt:Orc_Imp := oEstorno:nOrc_Imp
::oOcmtoIt:Orc_ImpIn := oEstorno:nOrc_ImpIn
::oOcmtoIt:Orc_Itens := {}

For nC := 1 To Len(oEstorno:aOrc_Itens)
	aAdd(::oOcmtoIt:Orc_Itens, WSClassNew("tRet_Itens") )
   
	::oOcmtoIt:Orc_Itens[nC]:L2_VlrItem  := oEstorno:aOrc_Itens[nC, __L2_VLRITEM]
	::oOcmtoIt:Orc_Itens[nC]:L2_VrUnit   := oEstorno:aOrc_Itens[nC, __L2_VRUNIT]
	::oOcmtoIt:Orc_Itens[nC]:L2_Produto  := oEstorno:aOrc_Itens[nC, __L2_PRODUTO]
	::oOcmtoIt:Orc_Itens[nC]:L2_Descri   := oEstorno:aOrc_Itens[nC, __L2_DESCRI]
	::oOcmtoIt:Orc_Itens[nC]:L2_Quant    := oEstorno:aOrc_Itens[nC, __L2_QUANT]
Next nC

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    |LjEstOrcPg       ºAutor  ³Fabiana Cristina    º Data ³  26/11/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo que retorna os pagamentos do pedido                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja                                                  		 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMethod LjEstOrcPg WSReceive cOrc, cEmpWs, cFilWs WSSend oOrc_Pg WSService LjEstOrc   
//Formata os parametros do Ponto de Entrada
Local oEstorno  := Nil 
Local nC 		:= 0 
Local lPrepEnv	:= If (FindFunction('LjPreparaWs'),LjPreparaWs(cEmpWs, cFilWs), .F.)

::oOrc_Pg := {}

//Instancia o Objeto estorno    
oEstorno := LjClEstVen():New(Nil,"", "", nil,0, .T.)   
   
oEstorno:BuscaPagtosOrcamento(cOrc)  

For nC := 1 To Len(oEstorno:aOrc_Pagtos)
	aAdd(::oOrc_Pg, WSClassNew("tRetPgOrc") )       
	::oOrc_Pg[nC]:L4_Data    := DtoS(oEstorno:aOrc_Pagtos[nC, __L4_DATA])
	::oOrc_Pg[nC]:L4_Forma   := oEstorno:aOrc_Pagtos[nC, __L4_FORMA] 
	::oOrc_Pg[nC]:L4_Valor   := oEstorno:aOrc_Pagtos[nC, __L4_VALOR]
	::oOrc_Pg[nC]:Porte      := oEstorno:aOrc_Pagtos[nC, __PORTE]
	::oOrc_Pg[nC]:L4_CheqId  := oEstorno:aOrc_Pagtos[nC, __L4_CHEQID]
	::oOrc_Pg[nC]:L4_NumCart := oEstorno:aOrc_Pagtos[nC, __L4_NUMCART]   	
	::oOrc_Pg[nC]:L4_Adminis := oEstorno:aOrc_Pagtos[nC, __L4_ADMINIS]
	::oOrc_Pg[nC]:L4_Agencia := oEstorno:aOrc_Pagtos[nC, __L4_AGENCIA]
	::oOrc_Pg[nC]:L4_Conta   := oEstorno:aOrc_Pagtos[nC, __L4_CONTA]
	::oOrc_Pg[nC]:L4_Comp    := oEstorno:aOrc_Pagtos[nC, __L4_COMP]
	::oOrc_Pg[nC]:L4_Moeda   := oEstorno:aOrc_Pagtos[nC, __L4_MOEDA] 	
	::oOrc_Pg[nC]:L4Data     := IIF(!Empty(oEstorno:aOrc_Pagtos[nC, __L4DATA]), DtoS(oEstorno:aOrc_Pagtos[nC, __L4DATA]),"")
    ::oOrc_Pg[nC]:L4_DataTEF := oEstorno:aOrc_Pagtos[nC, __L4_DATATEF] 
    ::oOrc_Pg[nC]:L4_DocTEF	  := oEstorno:aOrc_Pagtos[nC, __L4_DOCTEF] 
    ::oOrc_Pg[nC]:L4_NSUTEF  := oEstorno:aOrc_Pagtos[nC, __L4_NSUTEF]
    ::oOrc_Pg[nC]:L4_FORMAID  := oEstorno:aOrc_Pagtos[nC, __L4_FORMAID]
    ::oOrc_Pg[nC]:E1_PARCELA  := oEstorno:aOrc_Pagtos[nC, __E1_PARCELA]  
    ::oOrc_Pg[nC]:L4_RECNO  := oEstorno:aOrc_Pagtos[nC, __L4_RECNO]
Next nC

Return .T. 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    |LjEstOrcVRe      ºAutor  ³Fabiana Cristina    º Data ³  22/11/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo que valida o Orçamento com reserva.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja                                                  		 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMethod LjEstOrcVRe WSReceive cOrc, cEmpWs, cFilWs WSSend lOrcRes WSService LjEstOrc
Local oEstorno  := Nil 
Local lPrepEnv	:= If (FindFunction('LjPreparaWs'),LjPreparaWs(cEmpWs, cFilWs), .F.)

::lOrcRes := .T.

//Instancia o Objeto estorno    
oEstorno := LjClEstVen():New(Nil,"", "", nil,0, .T.)   
::lOrcRes := oEstorno:OrcValReserva(cOrc)



Return .T. 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    |LjEstOrcTit      ºAutor  ³Fabiana Cristina    º Data ³  06/12/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo que busca os titulos e baixas do Orcamento.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja                                                  		 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMethod LjEstOrcTit WSReceive cSerie, cNumCupom, cEmpWs, cFilWs WSSend aSE1 WSService LjEstOrc
Local oEstorno  := Nil   
Local nC := 0
Local nC2 := 0  
Local lPrepEnv	:= If (FindFunction('LjPreparaWs'),LjPreparaWs(cEmpWs, cFilWs), .F.)

oEstorno := LjClEstVen():New(cSerie,"", "", nil,0, .T.) 
oEstorno:cOrc_Cupom :=  cNumCupom   
oEstorno:cSerie := cSerie
oEstorno:BuscaTitulosOrcamento()

::aSE1  := {}  

conout(cnumcupom+ Str(len(oEstorno:aSE1))) 

For nC := 1 to Len(oEstorno:aSE1)    
	    
	aAdd(::aSE1, WSClassNew("tRetSE1") ) 
	::aSE1[nC]:CHAVE := oEstorno:aSE1[nC]:cChave //Chave do SE1E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO                                                                                                                  
	::aSE1[nC]:Indice := oEstorno:aSE1[nC]:nIndice //Indice da chave do SE1 =:1
	::aSE1[nC]:E1_SITUACA := oEstorno:aSE1[nC]:cE1_SITUACA //Situacao do titulo
	::aSE1[nC]:E1_EMISSAO := oEstorno:aSE1[nC]:dE1_EMISSAO //Emissão do título
	::aSE1[nC]:E1_VENCTO := oEstorno:aSE1[nC]:dE1_VENCTO //Vencimento do tótulo
	::aSE1[nC]:E1_BAIXA := oEstorno:aSE1[nC]:dE1_BAIXA //Data da Baixa do título
	::aSE1[nC]:E1_STATUS := oEstorno:aSE1[nC]:cE1_STATUS //Status do título
	::aSE1[nC]:E1_PARCELA := oEstorno:aSE1[nC]:cE1_PARCELA //Parcela do título
	::aSE1[nC]:E1_TIPO := oEstorno:aSE1[nC]:cE1_TIPO   //Tipo do Título
	::aSE1[nC]:E1_SALDO := oEstorno:aSE1[nC]:nE1_SALDO  //Saldo do título
	::aSE1[nC]:E1_ORIGEM  := oEstorno:aSE1[nC]:cE1_ORIGEM //Origem do título    
	::aSE1[nC]:E1_VALOR := oEstorno:aSE1[nC]:nE1_VALOR  //Valor do título
	::aSE1[nC]:E1_NUMCRD := oEstorno:aSE1[nC]:cE1_NUMCRD //Numero do Contrato de financiamento
	::aSE1[nC]:E1_PORTADO := oEstorno:aSE1[nC]:cE1_PORTADO //Portador do Título 
	::aSE1[nC]:E1_VLRREAL := oEstorno:aSE1[nC]:nE1_VLRREAL //Valor Real do título
  	::aSE1[nC]:E1_FLUXO := oEstorno:aSE1[nC]:cE1_FLUXO  //Fluxo de Caixa      
	::aSE1[nC]:aSE5 := {}
	

	For nC2 := 1 to Len(oEstorno:aSE1[nC]:aSE5) 
		aAdd(::aSE1[nC]:aSE5, WSClassNew("tRetSE5") )
		::aSE1[nC]:aSE5[nC2]:Chave := oEstorno:aSE1[nC]:aSE5[nC2]:cChave                                                                                                                                                                                            
		::aSE1[nC]:aSE5[nC2]:Indice := oEstorno:aSE1[nC]:aSE5[nC2]:nIndice
		::aSE1[nC]:aSE5[nC2]:E5_TIPODOC := oEstorno:aSE1[nC]:aSE5[nC2]:cE5_TipoDoc
		::aSE1[nC]:aSE5[nC2]:E5_DATA := oEstorno:aSE1[nC]:aSE5[nC2]:dE5_DATA
		::aSE1[nC]:aSE5[nC2]:E5_AGENCIA := oEstorno:aSE1[nC]:aSE5[nC2]:cE5_AGENCIA
		::aSE1[nC]:aSE5[nC2]:E5_TIPO := oEstorno:aSE1[nC]:aSE5[nC2]:cE5_TIPO
		::aSE1[nC]:aSE5[nC2]:E5_VALOR := oEstorno:aSE1[nC]:aSE5[nC2]:nE5_VALOR       
		::aSE1[nC]:aSE5[nC2]:E5_BANCO := oEstorno:aSE1[nC]:aSE5[nC2]:cE5_BANCO   
		::aSE1[nC]:aSE5[nC2]:E5_CONTA := oEstorno:aSE1[nC]:aSE5[nC2]:cE5_CONTA
		::aSE1[nC]:aSE5[nC2]:E5_RECPAG := oEstorno:aSE1[nC]:aSE5[nC2]:cE5_RECPAG 
		::aSE1[nC]:aSE5[nC2]:E5_MOTBX := oEstorno:aSE1[nC]:aSE5[nC2]:cE5_MOTBX
	Next
Next

Return .t.       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    |LjEstOrcDev      ºAutor  ³Fabiana Cristina    º Data ³  23/11/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo que verifica se o Orcamento foi devolvido                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja                                                  		 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMethod LjEstOrcChq WSReceive cSerie, cNumCupom, lPorteCx, cEmpWs, cFilWs WSSend oSEF WSService LjEstOrc      
//Formata os parametros do Ponto de Entrada
Local oEstorno  := Nil 
Local aCheques := {}  
Local lPrepEnv	:= If (FindFunction('LjPreparaWs'),LjPreparaWs(cEmpWs, cFilWs), .F.)

//Instancia o Objeto estorno    
oEstorno := LjClEstVen():New(cSerie,nil, nil,nil,nil, .T.) 

aCheques := oEstorno:BuscaChequesOrcamento(cSerie, cCupom, lPorteCx) //método que estorna o orcamento  
If Len(aCheques) > 0 
	::oSEF := WSClassNew("tRetSEF")   
	::oSEF:EF_BANCO   := aCheques[01,01]
	::oSEF:EF_AGENCIA := aCheques[01,02]
	::oSEF:EF_CONTA   := aCheques[01,03]
	::oSEF:EF_NUM     := aCheques[01,04]   
	::oSEF:EF_VALOR   := aCheques[01,05]
EndIf	

Return .T.


