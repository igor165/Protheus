#Include "RESTFUL.CH"
#Include "TOTVS.CH"
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "FWAdapterEAI.ch"  
#Include "COLORS.CH"                                                                                                     
#Include "TBICONN.CH"
#Include "COMMON.CH" 
#Include "XMLXFUN.CH"
#Include "fileio.ch" 
#Include 'FWMVCDEF.CH'  


#DEFINE  TAB  CHR ( 13 ) + CHR ( 10 )
/**********************************************************\
Configuracao dos adapter 
/***********************************************************/
WSRESTFUL CONFIGADAPTERREST DESCRIPTION "ervico REST para configuraracao Adapter"     
  WSMETHOD POST DESCRIPTION "Servico REST para configuraracao Adapter" WSSYNTAX "/CONFIGADAPTERREST"
END WSRESTFUL

WSMETHOD POST WSSERVICE CONFIGADAPTERREST
Local lMetodo           := .f.
Local nCont             := 0
Local nX                := 0
Local aAdapter          := {}
Local aPrepareEAI       := {}

Local cJson             := Self:GetContent() // Pega a string do JSON
Local cJSONRet          := ""
Local oParseJSON        := Nil

Local aEmpre            := {}

Local lAdpterCriado     := .f.

Local cMarca	   	      := ""
Local cCompanyId		    := ""
local cPacote           := "" // definição dos pacotes/ adapter a serem criados
/*Inicio tratamento de Retorno Json */
Local vetJsRet          :={}  
Local vetAdapter        :={}

Local jsRet             :=NIL
Local jsAdapter         :=NIL
/*Fim tratamento de Retorno Json*/
DEFAULT cJson           := ""

BEGIN SEQUENCE

FWJsonDeserialize(cJson, @oParseJSON)

For nX := 1 to LEN(oParseJSON:EAI)
  cPacote    := oParseJSON:PACOTE
  cMarca     := oParseJSON:EAI[nX]:SOURCEAPP                
  cCompanyId := oParseJSON:EAI[nX]:COMPANYID
  cbranchId  := oParseJSON:EAI[nX]:BRANCHID 
 
  aEmpre := FWEAIEMPFIL(cCompanyId, cbranchId, cMarca)
  
  If (Len (aEmpre) < 2)
     SetRestFault(400, "Empresa: " + cCompanyId + " Filial: " + cbranchId + " Nao existem para o Produto: " + cMarca + " !")   
  else
    cEmpFilial := aEmpre[1] + aEmpre[2]
    if( aScan(aPrepareEAI , {|x| x[1] == cEmpFilial}) == 0 )     
       aadd(aPrepareEAI  , {cEmpFilial, aEmpre[1] , aEmpre[2] })
    Endif    
  EndIf 
Next

If (cPacote <> "TIN" .and. cPacote <> "TOP")
   SetRestFault(400, "Pacote nao informado ou invalido " + cPacote)   
   Return .f.
endif

//Reset o erro
SUPRESERRHDL()

For nX := 1 to len(aPrepareEAI)   
    
    RESET ENVIRONMENT
    RPCSetType(3)   
    PREPARE ENVIRONMENT EMPRESA aPrepareEAI[nX][2] FILIAL aPrepareEAI[nX][3] TABLES "XX4" MODULO "CFG" 
 
    jsRet := JsonObject():new()	
    jsRet['Grupo'] := " Empresa:" +  aPrepareEAI[nX][2] + " Filial:" + aPrepareEAI[nX][3]    
     
    //Deixa setado o erro, caso ocorra
    SUPSETERRHDL("Nao foi possivel acessar o banco de dados!")

    aAdapter := GetValAcess(cPacote)

    vetAdapter:={}
    For nCont := 1 to len (aAdapter)
        lAdpterCriado:= AddAdapter(aAdapter[nCont])    
        jsAdapter:= JsonObject():new()
        jsAdapter['Adapter'  ] := aAdapter[nCont][2][2]
        jsAdapter['resultado'] := lAdpterCriado       
        aadd(vetAdapter,jsAdapter)          
    Next
    jsRet['Adapters'] := vetAdapter   
    aadd(vetJsRet,jsRet)
 NEXT   

 /* RETORNO REST */
 //define o tipo de retorno do m�todo

 ::SetContentType("application/json")	 
 jsreturn        := JsonObject():new()     
 jsreturn['ListaAdapter']  := vetJsRet

 //--> Transforma o objeto em uma string json
 cJSONRet  := FWJsonSerialize(jsreturn,.T.,.T.)
 ::SetResponse(cJSONRet)

 /*FIM REST*/

 lMetodo :=.T.	

RECOVER 		   	
    ErrorBlock(bErrorBlock)
    SetRestFault(400, "Erro" + TAB + oError:Description)	
    lMetodo := .f.
    Return lMetodo
END SEQUENCE

Return lMetodo

static Function GetValAcess(cPacote)
Local aAdapter :={}
IF (cPacote == "TIN")

    aadd(aAdapter,{{ "XX4_UNMESS" , "1"                       },; // Se o adapter cadastrado � do tipo Mensagem �nica TOTVS ou n�o.
                { "XX4_ROTINA" , "FINI035LST"              },; // Identifica qual rotina no Protheus � a respons�vel por realizar o processamento da mensagem. 
                { "XX4_MODEL"  , "LISTOFCOMPLEMENTARYVALUE"},; // O nome da mensagem que � processada por esta rotina.
                { "XX4_DESCRI" , "LISTOFCOMPLEMENTARYVALUE"},; // Descri��o da mensagem. Utilizada para facilitar o entendimento do processo;	  	
                { "XX4_SENDER" , "2"                       },; // Define se o adapter envia mensagens para outro sistema;
                { "XX4_RECEIV" , "1"                       },; // Define se o adapter pode receber mensagens de outro sistema.			
                { "XX4_METODO" , "1"                       },; // Define o m�todo de envio da mensagem.
                { "XX4_TPOPER" , "1"                       },; // Indica o tipo de opera��o utilizado na mensagem.		  
                { "XX4_CHANEL" , "2"                       },; // Indica o canal para o qual o EAI Protheus ir� enviar a mensagem.
                { "XX4_SNDVER" , "1.000"                   },; //Campo de vers�o da mensagem trafegada.			
                { "XX4_ALIASP" , ""                        },; //Este campo define o Alias principal da mensagem
                { "XX4_EXPFIL" , ""                        },; // Campo que pode receber uma express�o ou ainda uma fun��o advpl
                { "XX4_LOADRE" , ""                        }})

    aadd(aAdapter,{{ "XX4_UNMESS" , "1"                                 },; // Se o adapter cadastrado � do tipo Mensagem �nica TOTVS ou n�o.
                { "XX4_ROTINA" , "FINI070LST"                        },; // Identifica qual rotina no Protheus � a respons�vel por realizar o processamento da mensagem. 
                { "XX4_MODEL"  , "LISTOFACCOUNTRECEIVABLESETTLEMENTS"},; // O nome da mensagem que � processada por esta rotina.
                { "XX4_DESCRI" , "LISTOFACCOUNTRECEIVABLESETTLEMENTS"},; // Descri��o da mensagem. Utilizada para facilitar o entendimento do processo;	  	
                { "XX4_SENDER" , "1"                                 },; // Define se o adapter envia mensagens para outro sistema;
                { "XX4_RECEIV" , "1"                                 },; // Define se o adapter pode receber mensagens de outro sistema.			
                { "XX4_METODO" , "1"                                 },; // Define o m�todo de envio da mensagem.
                { "XX4_TPOPER" , "1"                                 },; // Indica o tipo de opera��o utilizado na mensagem.		  
                { "XX4_CHANEL" , "2"                                 },; // Indica o canal para o qual o EAI Protheus ir� enviar a mensagem.
                { "XX4_SNDVER" , "1.001"                             },; //Campo de vers�o da mensagem trafegada.			
                { "XX4_ALIASP" , ""                                  },; //Este campo define o Alias principal da mensagem
                { "XX4_EXPFIL" , ""                                  },; // Campo que pode receber uma express�o ou ainda uma fun��o advpl
                { "XX4_LOADRE" , ""                                  }})
else

Endif                
return aAdapter

/******************************************/
/*Criacao dos aadpter na base do Protheus */
/******************************************/
Static Function AddAdapter(aAdapter)
Local lRetorno    := .f.
local cCFilial    := ""
Local cIsMsgUnica :=aAdapter[01][02]   // Se o adapter cadastrado e do tipo Mensagem unica TOTVS ou n�o.
Local cRotina     :=aAdapter[02][02]   // Identifica qual rotina no Protheus � a respons�vel por realizar o processamento da mensagem.
Local cModel      :=aAdapter[03][02]   // O nome da mensagem que � processada por esta rotina.
Local cDescricao  :=aAdapter[04][02]   // Descricao da mensagem. Utilizada para facilitar o entendimento do processo;	  	
Local cIsSender   :=aAdapter[05][02]   // Define se o adapter envia mensagens para outro sistema;
Local cIsReceive	:=aAdapter[06][02]   // Define se o adapter pode receber mensagens de outro sistema.			
Local cMetodoSend :=aAdapter[07][02]   // Define o motodo de envio da mensagem.
Local cTipoOper   :=aAdapter[08][02]   // Indica o tipo de operacao utilizado na mensagem.		  
Local cChanal     :=aAdapter[09][02]   // Indica o canal para o qual o EAI Protheus ir� enviar a mensagem.
Local cVersao     :=aAdapter[10][02]   // Campo de versao da mensagem trafegada.			


///caso exista, Remove o Adapter
lRetorno:= DelAdapter(cRotina)
   
RecLock( "XX4", .T. )
 XX4->XX4_FILIAL := cCFilial
 XX4->XX4_ROTINA := cRotina
 XX4->XX4_MODEL  := cModel
 XX4->XX4_DESCRI := cDescricao
 XX4->XX4_SENDER := cIsSender
 XX4->XX4_RECEIV := cIsReceive
 XX4->XX4_METODO := cMetodoSend
 XX4->XX4_TPOPER := cTipoOper
 XX4->XX4_CHANEL := cChanal
 XX4->XX4_UNMESS := cIsMsgUnica
 XX4->XX4_SNDVER := cVersao
 MsUnLock()

 lRetorno:= .t.

Return lRetorno

/*********************************/
/*     Deleta o adapter          */
/*********************************/
Static Function DelAdapter(cMessage)
Local lRetorno := .f.
Local aArea    := GetArea()
IF FWXX4Seek(UPPER(cMessage),1)
 If RecLock("XX4",.F.)
   XX4->(dbDelete())
   XX4->(MsUnlock())
     lRetorno :=.t.
  EndIf
EndIf
RestArea( aArea )

Return lRetorno


/*
{Protheus.doc} SUPSETERRHDL
@Uso    Seta codigo e mensagem de erro 
@param  Objeto de erro
@return	Nenhum
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
*/
Static Function SUPRESERRHDL(cTitle)
	bError  := { |e| oError := e , Break(e) }
	bErrorBlock    := ErrorBlock( bError )
Return(.T.)