#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "SPEDNFE.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "BRWCTEOS.CH"

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} CTeOSimpressao
Impressão do CTeOS

@param	cAlias  Alias do Browse
@param	nReg    Recno do Registro
@param	nOpc    Opcao da operção

@return	nil

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
Function H61Print(cAlias, nReg, nOpc, lAut)

    local cError      := ""
    local cXml        := ""
    local cXmlCTe     :=  ""
    local cXmlProt    := ""
    local cErro       := ""
    local cAviso      := ""
    local oSetup
    local cFilePrint  := ""
    local lFrentVers  := .F.
    local lAuto       := .F.
    local cPrinter    := ""
    local cPathPDF    := ""
    Local cEveCteos   := ""
    local cEntidade   := getCfgEntidade(@cError)
    local cIdCteOS    := ""
    local oReq
    local oResp
    local aXmlDacteOS := {}
    private oXml
    Default lAut := .F.

    cFilePrint  := "DACTEOS_" + cEntidade + dtos( MSDate() ) + strTran( time(), ":", "") +".pdf"

    cIdCteOS := H61->H61_SERIE + H61->H61_NOTA

    //0=Normal;1=Complemento;2=Anulacao;3=Substituicao;4=Documento excluído;5=Cancelamento
    If H61->H61_STATUS == '0'
        cEveCteos := "00"
    //ElseIf H61->H61_STATUS == '1'
    //    cEveCteos := "03"
    //ElseIf H61->H61_STATUS == '2'
    //    cEveCteos := "01"
    //ElseIf H61->H61_STATUS == '3'
    //    cEveCteos := "02"
    EndIf

    H62->(DbSetOrder(1))
    H62->(DbSeek(H61->H61_FILIAL + H61->H61_CODIGO + cEveCteos))
    //Busca XML da Base do ERP
    cXml := alltrim(H62->H62_XMLCTE)

    if(!empty(cXml))

        oXml := XmlParser(cXml, "_", @cErro, @cAviso)

        if( type("oXml:_cteProc:_CTeOS") == "O" )
            cXmlCTe := XMLSaveStr(oXml:_cteProc:_CTeOS,.F.)
        elseif( type("oXml:_cteOSProc:_CTeOS") == "O" )
            cXmlCTe := XMLSaveStr(oXml:_cteOSProc:_CTeOS,.F.)
        endif

        if( type("oXml:_cteProc:_protCTe") == "O")
            cXMLProt := XMLSaveStr(oXml:_cteProc:_protCTe,.F.)
        elseif(type("oXml:_cteOSProc:_protCTe") == "O")
            cXMLProt := XMLSaveStr(oXml:_cteOSProc:_protCTe,.F.)
        endif

        if(valtype(oXml) == "O")
            freeObj(oXml)
            oXml := nil
        endif

    endif


    //Busca XML no TSS caso nao tenha encontrado no ERP
    if(empty(cXmlCTe) .or. empty(cXMLProt))

        cReq := '{ "msg": { "entidade": "' + cEntidade + '", "cteos": [ {"id":"' + alltrim(H61->H61_SERIE) + alltrim(H61->H61_NOTA) +'" }]}}'

        if(!fwJsonDeserialize(cReq, @oReq))
            aviso("CTeOS - Impressão", "Requisição Inválida" + cReq, {STR0004}, 3)
        else
            if( CTeOSRet(oReq, @oResp)) 
                if !lAut
                    if( len(oResp:response:cteos) > 0 )
                        aXmlDacteOS := { {decode64(oResp:response:cteos[1]:xml), decode64(oResp:response:cteos[1]:xmlProt)} }                
                    else
                        aviso("CTeOS - Impressão", "Documento não localizado no TSS.", {STR0004}, 3)    
                    endif
                endif    
            else
                aviso("CTeOS - Impressão", decode64(oResp:error), {STR0004}, 3)
            endif
        endif

    else
        aXmlDacteOS := { {cXmlCTe, cXmlProt} }
    endif

    if(!empty(aXmlDacteOS))

        //Setup de configuração
        oSetup := setupCTOS()

        //Impressao
        if( oSetup:Activate() == PD_OK )
        
            if(oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL)
                cPrinter := oSetup:aOptions[PD_VALUETYPE]
            ElseIf oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
                cPathPDF := oSetup:aOptions[PD_VALUETYPE]
            Endif    

            fwWriteProfString( GetPrinterSession(), "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )
	        fwWriteProfString( GetPrinterSession(), "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==2   ,"SPOOL"     ,"PDF"       ), .T. )
	        fwWriteProfString( GetPrinterSession(), "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )

            if( existBlock("DacteOS", , .T.) )
                aRetorno  := ExecBlock("DacteOS", .F., .F., {aXmlDacteOS, cPathPDF, cPrinter, lFrentVers, val(oSetup:cQtdCopia),;
                            lAuto, cFilePrint, oSetup:GetProperty(PD_PRINTTYPE), oSetup:GetProperty(PD_DESTINATION)==AMB_SERVER})
            endif

            //Definição do Status do CTeOS
            GTPA850MStatus("4")
            
        endif
    endif

return nil

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} setupCTOS
Setup de configuração da Impressão

@param	nil

@return	nil

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
static function setupCTOS()

    local nFlags       := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
    local aDevice      := {"DISCO", "SPOOL", "EMAIL", "EXCEL", "HTML", "PDF"}
    Local cSession     := GetPrinterSession()
    local nLocal       := If(fwGetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
    local nOrientation := If(fwGetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
    local cDevice      := If(Empty(fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)),"PDF",fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.))
    local nPrintType   := aScan(aDevice,{|x| x == cDevice })
    
    oSetup := FWPrintSetup():New(nFlags, "Setup para impressao DacteOS")

    oSetup:SetPropert(PD_DESTINATION , nLocal)
    oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
    oSetup:SetPropert(PD_ORIENTATION , nOrientation)
    oSetup:SetPropert(PD_PAPERSIZE   , 2)
    oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
    
return oSetup

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} getCTeOS
Retorna objeto Xml do CTeOS gravado na tabela H61

@param	oRetorno    Referencia para retorno do Objeto
@param	cChaveCTe   Referencia para retorno de error na execução

@return	lGet        Indica se o Objeto foi criado

@author  Renato Nagib
@since   30/09/2017
@version 12.1.18

/*/
//-----------------------------------------------------------------------------------------------
static function getCTeOS(oCTeOS, oProtCTeOS, cError)

    local cErro  := ""
    local cAviso := ""
    Local cEveCteos := ""
    Local lOk   := .F.
    private oXml

    //0=Normal;1=Complemento;2=Anulacao;3=Substituicao;4=Documento excluído;5=Cancelamento
    If H61->H61_STATUS == '0'
        cEveCteos := "00"
    //ElseIf H61->H61_STATUS == '1'
    //    cEveCteos := "03"
    //ElseIf H61->H61_STATUS == '2'
    //    cEveCteos := "01"
    //ElseIf H61->H61_STATUS == '3'
    //    cEveCteos := "02"
    EndIf

    H62->(DbSetOrder(1))
    H62->(DbSeek(H61->H61_FILIAL + H61->H61_CODIGO + cEveCteos))

    if(empty(H62->H62_XMLCTE))
        cError := "Protocolo não localizado"
    else
        oXml := XmlParser(H62->H62_XMLCTE, "_", @cErro, @cAviso)

        if(oXml <> nil)

            if( type("oXml:_cteProc:_protCTe:_infProt") <> "U")
                oProtCTeOS := oXml:_cteProc:_protCTe
                lOk := .T.
            elseif( type("oXml:_cteOsProc:_protCTe:_infProt") <> "U")
                oProtCTeOS := oXml:_cteOsProc:_protCTe
                lOk := .T.
            endif

            if( type("oXml:_cteProc:_CTEOS:_infCte") <> "U")
                oCTeOS := oXml:_cteProc:_CTEOS
                lOk := .T.
            elseif( type("oXml:_cteOsProc:_CTEOS:_infCte") <> "U")
                oCTeOS := oXml:_cteOsProc:_CTEOS
                lOk := .T.
            endif

        else
            cError := cErro + cAviso
        endif
    endif 
return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} CTeOSConfig
Configuração do CTeOS

@param	nil

@return	nil

@author  Renato Nagib
@since   22/09/2017
@version 12.1.18

/*/
//-------------------------------------------------------------------
function CTeOSCfg()
    
    local lPSW         := .F.
    local lAdminNfe    := getNewPar("MV_ADMNFE",.T.)
    local lOk          := .F.        
    local cError       := ""
    local cEntidade    := ""
    local cAmbiente    := ""
    local cModalidade  := ""    
    local cHrVerao     := "2"
    local cHorario     := "2"
    local nTempo       := 0
    local aCfgVerao    := {}
    local aAmbiente    := {STR0031, STR0032}    
    local aModalidade  := {STR0033}
    local aHrVerao     := {"1-Sim", "2-Nao"}
    local aHorario     := {"1-Fernando de Noronha", "2-Brasilia", "3-Manaus", "4-Acre"}    
    local cModelo      := "67"
    local aPerg        := {}    
	local cVersao      := ""
    local aVersao      := {"3.00"}		
    local aParam       := {"", "", "", "", "", 0}
    local CTeOSPar     := "CTEOS" + SM0->M0_CODIGO + SM0->M0_CODFIL
    
	
    lPSW := pswAdmin( /*cUser*/, /*cPsw*/, retCodUsr()) == 0 
    
    if( !lAdminNfe .or. lPSW )
        
        lOk := isConnTSS(@cError)
        
        if(lOk)
            cEntidade := getCfgEntidade(@cError)
            lOk := empty(@cError)
        endif    

        if(lOk)
            cAmbiente := getCfgAmbiente(@cError, cEntidade, cModelo)				        
        endif                
        
        if(empty(cError))
            cModalidade := PADR(getCfgModalidade(@cError, cEntidade, cModelo), 30)				
        endif
        
        if(empty(cError))
            cVersao := getCfgVersao(@cError, cEntidade, '67')	
        endif
        
        if(empty(cError))
            nTempo := getCfgEspera(@cError, cEntidade)				
        endif
        
        if(empty(cError))
            aCfgVerao := getCfgEpecCte(@cError)
            cHrVerao := aCfgVerao[12]
            cHorario := aCfgVerao[11]
        endif
        

        if(!empty(cError))
            Aviso("CTeOS", cError, {STR0114}, 3)
        else
        
            aadd(aPerg, {2, STR0035, cAmbiente, aAmbiente, 120, ".T.", .T., ".T." })
            aadd(aPerg, {2, STR0036, cModalidade, aModalidade, 120, ".T.", .T., ".T."})
            aadd(aPerg, {2, STR0037 + " CTe", cVersao, aVersao, 120, ".T.", .T., ".T."})        
            aadd(aPerg, {2, STR0369, cHrVerao, aHrVerao, 120, ".T.", .T., ".T."})                    
            aadd(aPerg, {2, "Horario", cHorario, aHorario, 120, ".T.", .T., ".T."})                    
            aadd(aPerg, {1, STR0071, nTempo, "99", ".T.", "", ".T.", 30, .F.})
        
            aParam := { subStr(cAmbiente, 1, 1), subStr(cModalidade, 1, 1),;
                        cVersao, cHrVerao, cHorario, nTempo}


            /*----------------------------------------------------------------------------------
                                    Atualiza configurações do TSS  
            ----------------------------------------------------------------------------------*/											
            if( paramBox(aPerg, "Parametros - CTeOS", aParam, , , , , , , CTeOSPar, .T., .F.) )

                if( aParam[1] <> cAmbiente)
                    cAmbiente := getCfgAmbiente(@cError, cEntidade, cModelo, aParam[1])				
                endif

                if( aParam[2] <> cModalidade)
                    cModalidade := PADR(getCfgModalidade(@cError, cEntidade, cModelo, aParam[2]),30)
                endif

                if( aParam[3] <> cVersao)
                    cVersao := getCfgVersaoCTe(@cError, cEntidade, "67", aParam[3])
                endif
                
                if( aParam[4] <> cHrVerao .or. aParam[5] <> cHorario)        
                     aCfgVerao :=  getCfgEpecCte(@cError, cEntidade, "3.00",;
                                                 "3.00", "3.00", "3.00", "3.00",;
                                                 "3.00", "3.00", "3.00", , aParam[4],;
                                                 aParam[5], "3.00", "3.00")
                     cHrVerao := aCfgVerao[12]
                     cHorario := aCfgVerao[11]
                endif   

                if( aParam[6] <> nTempo )
                    nTempo := getCfgEspera(@cError, cEntidade, aParam[6])
                endif   

            endIf
        
        endif
    elseif(!lPSW)
        help( "", 1, "SEMPERM" )
    endif	

return

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} H61ConsEvento
Função de Menu para Consulta de Eventos

@param	cAlias  Alias do Browse
@param	nReg    Recno do Registro
@param	nOpc    Opcao da operção

@return	nil

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function H61EventCons(cAlias, nReg, nOpc)

    local cError   := ""
    local oCTeOS
    local oProtCTeOS
    local cRetorno :=  ""
    local aEventos := {"110110","110111"}
    local nEventos
    local cChaveCTe :=  ""
    local cEntidade := getCfgEntidade(@cError)
    local cReq
    local oReq
    local oResp

    If H61->H61_STATUS <> '8'
    
	    if(empty(cError))
	
	        if(getCTeOS(@oCTeOS, @oProtCTeOS, @cError))
	
	            if(oProtCteOS <> nil)
	                cChaveCTe := oProtCteOS:_infProt:_chCTe:text
	            elseif(oCteOS <> nil)
	                cChaveCTe := substr(oCTeOS:_infCte:_id:text, 4)
	            endif
	
	            for nEventos := 1 to len(aEventos)
	
	            	  if(!empty(cRetorno) )
	                   cRetorno += CRLF + replicate("*", 105) + CRLF + CRLF
	            	  endif
	
	                cReq := '{"msg": {"entidade": "' + cEntidade + '", "codEvento": "' + aEventos[nEventos] + '", "chaveCTe": "' + cChaveCTe + '"}}'
	
	                if(fwJsonDeserialize(cReq, @oReq))
	
	                    CTeOSConEv(oReq, @oResp)
	
	                    if( oResp:error == nil )
	
	                        if( oResp:response:status == 1 )
	                            cRetorno += "Evento: " + aEventos[nEventos] + " - " + getDescEvento(aEventos[nEventos]) + CRLF
	                            cRetorno += "Não Processado" + CRLF
	                            cRetorno += "Chave:" + cChaveCte
	
	                        elseif( oResp:response:status == 2 )
	                            cRetorno += "Evento: " + aEventos[nEventos] + " - " + getDescEvento(aEventos[nEventos]) + CRLF
	                            cRetorno += "Autorizado!" + CRLF
	                            cRetorno += "Protocolo: " + oResp:response:autorizacao:protocolo +CRLF
	                            cRetorno += "Chave:" + cChaveCte
	                            if aEventos[nEventos] == "110111"
	                            	GTPA850MStatus("2", "5")
	                            endif
	
	                        elseif( oResp:response:status == 3 )
	                            cRetorno += "Evento: " + aEventos[nEventos] + " - " + getDescEvento(aEventos[nEventos]) + CRLF
	                            cRetorno += "Rejeição: " + oResp:response:rejeicao:codigo + CRLF
	                            cRetorno += oResp:response:rejeicao:motivo + CRLF
	                            cRetorno += "Chave:" + cChaveCte
	
	                        endif
	
	                    elseif("003 - Faixa de Chave Invalida" $ decode64(oResp:error) ) //.or. (!empty(cRetorno) .and. ("Documento não possui evento." $ decode64(oResp:error)) ) )
	                        cError := ""
	                    else
	                    		cRetorno += "Evento: " + aEventos[nEventos] + " - " + getDescEvento(aEventos[nEventos]) + CRLF
	                        cRetorno += decode64(oResp:error)
	                    endif
	                endif
	            next
	
	            freeObj(oCteOS)
	            oCteOS := nil
	
	            if(oReq <> nil)
	                freeObj(oReq)
	                oReq := nil
	            endif
	
	        endif
	
	    endif
	
	    cRetorno += cError
	
	    if(empty(cRetorno))
	        cRetorno :=  STR0001 //"Nenhum Evento Emitido para o CTeOS Informado"
	    endif
	
	    aviso("CTeOS - Eventos", cRetorno, {STR0004}, 3)
    Else
    	Alert(STR0002) //'Cancelamento já autorizado.'
    
    endif

return cRetorno

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} getDescEvento
Retorna a Descrição do Evento de acordo com o codigo

@param cTipoEvento     COdigo do Evento

@return	cRet        UTC

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
static function getDescEvento(cTipoEvento)

    local cEvento := ""

    do case
        case cTipoEvento == "110110"
            cEvento := "Carta de Correção"
        case cTipoEvento == "110111"
            cEvento := "Cancelamento"
    endcase

return cEvento

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} H61CTeOSStatus
Monitoramento e atualização do Status do CTeOS

@param nil

@return	nil

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function H61StsCTeOS()

    local cError :=  ""
    local cReq := ""
    local oReq
    local cRetorno := ""

    private oResp1

    cEntidade := getCfgEntidade(@cError)

    cReq := '{ "msg":{'
    cReq += ' "entidade": "' + cEntidade + '"'
    cReq += ', "modelo": "67"'
    cReq += ', "id": "' + alltrim(H61->H61_SERIE) + alltrim(H61->H61_NOTA) + '"'
    cReq += ', "serie": "'+ H61->H61_SERIE + '"'
    cReq += ', "nota": "'+ H61->H61_NOTA + '" }}'

    if(!fwJsonDeserialize(cReq, @oReq) )
        cRetorno := "Requisição inválida:" + CRLF + cReq
    endif

   if(oReq <> nil)

        CTeOSMnt(oReq, @oResp1)

        if(oResp1:error == nil)
            cRetorno := "Id: "           + oResp1:response:id + CRLF
            cRetorno += "Protocolo: "    + oResp1:response:protocolo + CRLF
            cRetorno += "Situação: "     + oResp1:response:situacao + CRLF
            cRetorno += "Status Sefaz: " + oResp1:response:statusSef
            cRetorno += " - "            + oResp1:response:descSef + CRLF
            cRetorno += "Chave Eletrônica: " + oResp1:response:chaveeletronica + CRLF


            if(oResp1:response:status == "2")

                if(H61->H61_STATUS < "5")
                    //GTPA850MStatus('2')
                endif

            elseif(oResp1:response:status == "3")

                //GTPA850MStatus('H61_STATUS', "8")

            elseif(oResp1:response:status == "4")

                //if(H61->H61_STATUS < "6")
                    //GTPA850MStatus('H61_STATUS', "4")
                //else
                    //GTPA850MStatus('H61_STATUS', "9")
                //endif

            endif

        else
            cRetorno := decode64(oResp1:error)
        endif
    endif

    //----------------------------------------------------
    // Realizo validacao para quando nao estiver retorno
    // no objeto, seja exibido Pendente de Transmissao
    //----------------------------------------------------
    if ( type("oResp1:response:status") == "U" .and. type("oResp1:response:descSef") == "U" )
      	viewCTeOS("1", "", cRetorno)	//Pendente de Transmissao
    else
    	viewCTeOS(oResp1:response:status, oResp1:response:descSef, cRetorno)
    endif

return nil

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} viewCTeOS
Visualização do Resultado da consulta

@param	lAutorizado Indica se o CTeOS está autorizado
@param	cRetorno    String com os dados para apresentação da View

@return	nil

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
Static function ViewCTeOS(cStatusProc, cLbStatus, cRetorno)

    local oDlg
    local oImgStatus
    local cImgStatus
    local oLbStatus
    local oBtExit

    Default lAut := .F.

    if(cStatusProc == "1")
        cImgStatus := "qmt_cond.png"
    elseif(cStatusProc $ "2|3")
        cImgStatus := "qmt_ok.png"
    elseif(cStatusProc == "4")
        cImgStatus := "qmt_no.png"
    else
        cImgStatus := "qmt_no.png"
    endif

    cLbStatus := iif(empty(cLbStatus), "Documento não Processado", cLbStatus)

    if !isBlind()
        DEFINE FONT oFont NAME "Arial" SIZE 0, -13 BOLD
        oDlg := TDialog():New(150,150,450,690,'',,,,,,,,,.T.)
        oImgStatus := TBitmap():New(010,010,260,184,,cImgStatus,.T.,oDlg, {||},,.F.,.F.,,,.F.,,.T.,,.F.)
        @012,025 SAY oLbStatus PROMPT cLbStatus OF  oDlg PIXEL FONT oFont SIZE 200, 015
        @032,010 GET cRetorno MEMO SIZE 254, 095 READONLY PIXEL OF oDlg
        oBtExit := TBtnBmp2():New( 265,473,60,25,'s4wb018n.png',,,,{|| oDlg:end() }, oDlg, "Sair", ,.T. )

        ACTIVATE MSDIALOG oDlg
    EndIf

return nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} G001MStatus
	Grava os campos que validam os status da CTEOS
	
@param cStatus    	status	

@author Fernando Amorim(Cafu)
@since		23/09/2017       
@version	P12
/*/
//------------------------------------------------------------------------------

Function GTPA850MStatus(cStaTra,cStatus)

DEFAULT cStatus       := H61->H61_STATUS

RecLock("H61",.F.)
H61->H61_STATRA := cStaTra
H61->H61_STATUS := cStatus
H61->( MsUnlock() )

AtualiSF3(cStatus,cStaTra)

Return()

/*/{Protheus.doc} AtualiSF3   
    Atualiza SF3 com ret da sefaz
    @type  Static Function
    @author GTP
    @since 30/07/2020
    @version version
    @param oModel, objeto, instância da Classe FwFormModel
    @return lRet, lógico, .t. - Efetuou o Commit com sucesso
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function AtualiSF3(cStatus,cStaTra)
Local cStatusF3 := GetTipoSt(cStatus)

If cStatus $ '5' .OR. cStaTra $ '2|4'
	SF3->(DbSetOrder(4)) //F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
    If SF3->( DbSeek(xFilial("SF3")+H61->H61_CLIENT+H61->H61_LOJA+H61->H61_NOTA+H61->H61_SERIE))
        RecLock("SF3")
            SF3->F3_CODRSEF := ALLTRIM(cStatusF3)
        SF3->( MsUnlock() )
    EndIf
EndIf
	
Return 

/*/{Protheus.doc} GetTipoSt   
    Retorna de/para tss
    @type  Static Function
    @author GTP
    @since 30/07/2020
    @version version
    @param oModel, objeto, instância da Classe FwFormModel
    @return lRet, lógico, .t. - Efetuou o Commit com sucesso
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GetTipoSt(cStatus)
Local cTipoStat := ''

Do Case
	Case cStatus $ "0|1|2|3"
		cTipoStat := "100"
	Case cStatus == "5"
		cTipoStat := "101"
END Case

Return cTipoStat
