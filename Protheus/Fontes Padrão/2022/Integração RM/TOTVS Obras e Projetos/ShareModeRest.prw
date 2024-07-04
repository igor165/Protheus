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

WSRESTFUL ShareModeRest DESCRIPTION "Serviço REST para retornar o modo de comparilhamento."       
   WSMETHOD POST ;
   DESCRIPTION "Serviço REST para retornar o modo de comparilhamento";
   WSSYNTAX "/ShareModeRest"
END WSRESTFUL

 /*/{Protheus.doc} ShareModeRest
("Serviço REST para retornar o modo de compartilhamento")
@type  Function
@author William.Prado
@since 10/01/2020
@version version
@param Json Empresa e Grupo
@return Objeto convertido em Json 
/*/
WSMETHOD POST WSSERVICE ShareModeRest
LOCAL cJson        := Self:GetContent() 
Local oJson        As Object
LOCAL cCatch       As Object


LOCAL lMetodo         := .t. // retorno da api 
LOCAL aEmpresas       := {} // Carrega as informações das filiais disponíveis no arquivo
LOCAL aVetAdapter     := {} // Adapters recebidos para checagem
LOCAL cCodGrupo       := '' // Código do Grupo de Empresas
LOCAL cCodFilial      := '' // Código da Filial contendo todos os níveis (Empresa / Unidade de Negócio / Filial)
LOCAL cDescricaoGrupo := '' // Descrição do Grupo

/*** inicio Auxiliares ****/
LOCAL nContGrupo := 0   // variacao de grupo
LOCAL nPosiGrupo := 0   // posicao do grupo no array de empresa
LOCAL nContAdpter:= 0   // variacao de adapter
LOCAL ncontAlias := 0   // variacao de alias
/*** fim Auxiliares  *****/ 


/*** inicio Json ****/
LOCAL oReturnJson      As Object
LOCAL jsShareMode      := NIL 
LOCAL jsGrp            := Nil
LOCAL vetJsShareMode   := {}
LOCAL vetGrp           := {} 
/*** fim Json  *****/ 

oJson              := JsonObject():New()
cCatch             := oJson:FromJSON(cJson)

IF cCatch == Nil   
   FOR nContGrupo := 1 to Len(oJson["Grupo"]) 
      cCodGrupo   := oJson["Grupo"][nContGrupo]
      aVetAdapter := oJson["Adapters"]
      aEmpresas   := FWLoadSM0()
      nPosiGrupo  := aScan(aEmpresas , {|x| x[1] == cCodGrupo})
    
      IF (nPosiGrupo > 0)
         cCodFilial      := aEmpresas[nPosiGrupo][02]
         cDescricaoGrupo := aEmpresas[nPosiGrupo][21]
          
         PrePareContexto(cCodGrupo,cCodFilial)

         vetJsShareMode :={}
         jsGrp := JsonObject():new()	
         jsGrp['Grupo']     := cCodGrupo
         jsGrp['descricao'] := alltrim(cDescricaoGrupo)
         
         FOR nContAdpter := 1 to LEN(aVetAdapter)
           cAdapter       := aVetAdapter[nContAdpter]["Adapter"]             
           avetInfoAdapter:= aVetAdapter[nContAdpter]["InfoAdapterProtheus"]            

           For ncontAlias := 1 to LEN(avetInfoAdapter)
                cAlias   := avetInfoAdapter[ncontAlias]["Alias" ]
                cRotina  := avetInfoAdapter[ncontAlias]["Rotina"]
                aVetMode = GetShareMode(cAlias)
                aVetModeUse := AdapterInUse(cRotina)
                
                jsShareMode:= JsonObject():new()
                jsShareMode['Alias'              ] := cAlias
                jsShareMode['AdapterName'        ] := cAdapter
                jsShareMode['Version'            ] := aVetModeUse[1][3]
                jsShareMode['Routine'            ] := cRotina
                jsShareMode['Ativo'              ] := aVetModeUse[1][2]

                jsShareMode['CompanySharedMode'  ] := aVetMode[1][1]   
                jsShareMode['UnitSharedMode'     ] := aVetMode[1][2]   
                jsShareMode['BranchSharedMode'   ] := aVetMode[1][3]
                aadd(vetJsShareMode,jsShareMode) 
            NEXT        
          NEXT
          jsGrp['itemsShareMode'] := vetJsShareMode            
          aadd(vetGrp,jsGrp)          
       ELSE
          lMetodo:= .f.
          SetRestFault(400, " Empresa/Grupo nao localizado, verifique codigo grupo informado.!")
       ENDIF
   NEXT
   /*RETORNO REST*/   
   oReturnJson := JsonObject():new()
   oReturnJson['ListShareMode'] := vetGrp
   ExportarJson(Self , oReturnJson, "ShareModeRest")
   /*RETORNO REST*/
   lMetodo := .t.
ELSE
  lMetodo := .f.
  SetRestFault(400, " Json Invalido!")
ENDIF	

Return lMetodo



/*/{Protheus.doc} nomeStaticFunction
    Indica o nível a ser avaliado (1=Empresa, 2=Unidade de Negócio e 3=Filial)
    @type  Static Function
    @author user
    @since 27/10/2019
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function GetShareMode(cAlias)
  Local aRet :={}
  Local CompanySharedMode := FWModeAccess(cAlias,1)
  Local UnitSharedMode    := FWModeAccess(cAlias,2)
  Local BranchSharedMode  := FWModeAccess(cAlias,3)
  aadd(aRet,{CompanySharedMode , UnitSharedMode , BranchSharedMode})
Return aRet


/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 27/10/2019
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function AdapterInUse(cMessage)
 Local aRet      := {}
 Local aArea    := GetArea()

 If (!EMPTY(cMessage) .and. (FWXX4Seek(UPPER(cMessage),1)))
    AADD(aRet,{cMessage , .T. ,ALLTRIM(cValToChar(XX4->XX4_SNDVER))})
 ELSE
    AADD(aRet,{cMessage , .F. , ""})
 ENDIF 
 RestArea( aArea )
Return aRet



 /*/{Protheus.doc} ExportarJson
(Prepara o contexto para empresa logada )
@type  Function
@author William.Prado
@since 13/05/2020
@version version
@param Sistema, Empresa, Filial
@return Prepare Enviromente
*/
Static Function PrePareContexto(cCodGrupo , cCodFilial)
   LOCAL lMetodo     := .f.
   RESET ENVIRONMENT
   RPCSetType(3)
   PREPARE ENVIRONMENT EMPRESA cCodGrupo FILIAL cCodFilial TABLES "XX4" MODULO "CFG" 		
  lMetodo := .t.
RETURN lMetodo
 


 /*/{Protheus.doc} ExportarJson
(Exporta o Json )
@type  Function
@author William.Prado
@since 13/05/2020
@version version
@param Contexto, Contexto, Contexto enviado para API
@return Objeto convertido em Json 
/*/
Static Function ExportarJson(Self , oReturnJson, cApi)
  LOCAL	lMetodo := .t.
  LOCAL oJson  As Object  
  ::SetContentType("application/json")  
  oJson := JsonObject():new()
  oJson := oReturnJson
  IF ValType(oJson) == "J"
	   Conout("Api:" + cApi + "-> Json gerado com sucesso. ")
  else		
       Conout("Api:" + cApi + "-> Falha ao gerar Json. ")   	   
  ENDIF  
  ::SetResponse(oJson:toJson())   
Return lMetodo