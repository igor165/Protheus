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
/*
{Protheus.doc} 
@Uso    Serviço REST para convers?o dos títulos do Protheus de origem imobiliario
@Autor  William.Prado - TOTVS
*/
WSRESTFUL EaiGroupCompanyRest DESCRIPTION "Serviço REST para retornar informações de grupo empresa e filial do Protheus."     
  WSMETHOD GET;
  DESCRIPTION "Serviço REST para retornar informações de grupo empresa e filial do Protheus.";
  WSSYNTAX "/EaiGroupCompanyRest"  
END WSRESTFUL

 /*/{Protheus.doc} ShareModeRest
("Serviço REST para retornar informações de grupo empresa e filial do Protheus.")
@type  Function
@author William.Prado
@since 10/01/2020
@version version
@param Json Empresa e Grupo
@return Objeto convertido em Json 
/*/
WSMETHOD GET WSSERVICE EAIGroupCompanyRest
Local lMetodo          := .t.
Local vetGrp           := {}
Local jsGrp            := NIL
LOCAL aEmpresas        := {} // Carrega as informações das filiais disponíveis no arquivo
Local nCont            := 0
BEGIN SEQUENCE
 aEmpresas      := FWLoadSM0() 
 IF( len(aEmpresas) > 0)
    For nCont := 1 to len (aEmpresas)
        jsGrp := JsonObject():new()	
        jsGrp['SM0_GRPEMP' ]  := aEmpresas[nCont][01]  // Código do Grupo de Empresas      
        jsGrp['SM0_DESCGRP']  := aEmpresas[nCont][21]  // Descrição do Grupo
        jsGrp['SM0_LEIAUTE']  := aEmpresas[nCont][09]  // Leiaute do Grupo de Empresas
      
        jsGrp['SM0_EMPRESA']  := aEmpresas[nCont][03]  // Código da Empresa
        jsGrp['SM0_DESCEMP']  := aEmpresas[nCont][19]  // Descrição da Empresa
        jsGrp['SM0_LEIAEMP']  := aEmpresas[nCont][13]  // Leiaute da Empresa (EE)

        jsGrp['SM0_UNIDNEG']  := aEmpresas[nCont][04]  // Código  
        jsGrp['SM0_DESCUN' ]  := aEmpresas[nCont][20]  // Nome 
        jsGrp['SM0_LEIAUN' ]  := aEmpresas[nCont][14]  // Leiaute  

        jsGrp['SM0_FILIAL' ]  := aEmpresas[nCont][05]  // Código da Filial
        jsGrp['SM0_NOME'   ]  := aEmpresas[nCont][07]  // Nome da Filial
        jsGrp['SM0_LEIAFIL']  := aEmpresas[nCont][15]  // Leiaute da Filial (FFFF) 

        jsGrp['SM0_CODFIL' ]  := aEmpresas[nCont][02] //Código da Filial contendo todos os níveis (Empresa / Unidade de Negócio / Filial)
        aadd(vetGrp,jsGrp)
    Next
    /*RETORNO REST*/   
     oReturnJson := JsonObject():new()     
     oReturnJson['INFOGRUPOPROTHEUS'] := vetGrp
     ExportarJson(Self , oReturnJson, "EAIGroupCompanyRest")
     /*RETORNO REST*/     
  ELSE
      lMetodo:= .f.
      SetRestFault(400, "Ocorreu um problema na execucao do servico: Verifique se foi configurado o prepareIn no Protheus.")     
  ENDIF      
RECOVER   
  SetRestFault(400, "Erro" + TAB + oError:Description)	
  lMetodo := .f.
END SEQUENCE  

Return lMetodo


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
