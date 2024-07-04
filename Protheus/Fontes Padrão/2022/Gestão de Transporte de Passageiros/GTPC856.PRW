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

/*/{Protheus.doc} G001CCe   
    Carta de correção de CTEOS
    @type  Static Function
    @author Fernando Amorim(Cafu)
    @since 02/10/2017
    @version version
   
    @example
    (examples)
    @see (links_or_references)
/*/
Function GTPC856CCE()

Local cStatus	:= GZH->GZH_STATUS
Local cRet	:= ''

If cStatus $ '3-5'

	cRet := GZHCteOSCCe()	

Else
	FwAlertHelp("CCE","Apenas CTEOS Autorizado podem ser corrigidos.") 		
Endif

Return()

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} GZHCCe
Carta de correção do CTeOS

@param	cAlias  Alias do Browse
@param	nReg    Recno do Registro
@param	nOpc    Opcao da operção

@return	nil

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function GZHCteOSCCe(cAlias, nReg, nOpc)

    local cError         := ""
    local cEntidade      := getCfgEntidade(@cError)
    local lContinua      := .T.
    local oCTeOS
    local oProtCteOS
    local cChaveCte
    local cProtocolo
    local oFont
    local oWizard
    local cLbStatus      := ""
    local oImgStatus
    local cCorrecao   := ""
    local cBtmStatus     := ""
    local cRetorno       := ""
    local oSay
    Local aItensAju := {}

    if(empty(cEntidade))
        lContinua := .F.
    endif

    cAmbiente :=  left(getCfgAmbiente(@cError), 1)

    if(empty(cAmbiente))
        lContinua := .F.
    endif
    if(lContinua)
        if(getCTeOS(@oCTeOS, @oProtCTeOS, @cError) .and.  oProtCTeOS <> nil )
            cChaveCte  := oProtCTeOS:_infProt:_chCTe:text
            cProtocolo := oProtCTeOS:_infProt:_nProt:text
        else
            lContinua := .F.
        endif
    endif

    if(lContinua)
        FwMsgRun( ,{||GTPA712LOA()},,"Carregando tabela de tags CT-e OS...")
        DEFINE FONT oFont NAME "Arial" SIZE 0, -13 BOLD
        cTexto := 'Informe os dados para correção.' + CRLF
        cTexto += 'As correções deverão ser informadas da seguinte forma:' + CRLF +CRLF
        cTexto += 'Grupo:Campo:Valor;Grupo:Campo:Valor' + CRLF +CRLF 
        cTexto += 'IMPORTANTE:' + CRLF 
        cTexto += 'No conteúdo a ser alterado, não poderá conter o caracter de dois pontos (:) '

        oWizard := APWizard():new( "Evento de Carta de Correção","Assistente para transmissão ",;
                                   "CTeOS - Carta de Correção "+CRLF,cTexto,,,,,,.F.)

        oWizard:NewPanel('Montagem','Atribuiç?es',{||.T.},{|| cCorrecao:=MontaStr(aItensAju),.T. },{||.T.},.T.,{||MontaTAG(oWizard:oMPanel[2],aItensAju)})                           

        oWizard:NewPanel ( "Dados para Correção" ,"" , {||.T.} ,;
            {|| processa({|| CTEOSProcCCe(cEntidade, cAmbiente ,cChaveCte, cProtocolo, cCorrecao, @cLbStatus, @oImgStatus, @cRetorno) }), .T.} , {|| .T.})

        @000,000 GET cCorrecao MEMO SIZE 299, 138 PIXEL OF oWizard:oMPanel[3] //2

        oWizard:NewPanel ( "Finalizado Processo de Carta de Correção" , cRetorno , {|| .T.} , {|| .T.} , {|| .T.})

        oImgStatus := TBitmap():New(010,010,260,184,,cBtmStatus,.T.,oWizard:oMPanel[4], {||},,.F.,.F.,,,.F.,,.T.,,.F.)  //3
        @012,025 SAY oSay PROMPT cLbStatus OF  oWizard:oMPanel[4] PIXEL FONT oFont SIZE 150, 015                        //3
        @032,010 GET cRetorno MEMO SIZE 290, 115 READONLY PIXEL OF oWizard:oMPanel[4]                                   //3

        ACTIVATE WIZARD oWizard CENTERED

        freeObj(oCteOS)
        oCteOS := nil
    else
        aviso("CTeOS - Carta de Correção", cError, {STR0004}, 3)
    endif

return cRetorno
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} getCTeOS
Retorna objeto Xml do CTeOS gravado na tabela GZH

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
    Local lOk   := .F.
    private oXml

    if(empty(GZH->GZH_XMLCTE))
        cError := "Protocolo não localizado"
    else
        oXml := XmlParser(GZH->GZH_XMLCTE, "_", @cErro, @cAviso)

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
/*/{Protheus.doc} MontaStr
Funcao responsavel por .

@param 	cGrupo		Grupo do Xml
		cTag			Tag a ser alterada
		cConteudo		Conteudo a ser alterado
        
@author  GTP
@since   27/05/2019
@version 12
/*/
//-------------------------------------------------------------------
Static Function MontaStr(aItensAju) 
Local nX := 0
Local Strtag := ''

For nX := 1 To Len(aItensAju)
    Strtag += aItensAju[nX][1]+':'+aItensAju[nX][2]+':'+aItensAju[nX][3]+';'
Next nX

Return Strtag

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaTAG
Funcao responsavel por .

@param 	cGrupo		Grupo do Xml
		cTag			Tag a ser alterada
		cConteudo		Conteudo a ser alterado
        
@author  GTP
@since   27/05/2019
@version 12
/*/
//-------------------------------------------------------------------
Static Function MontaTAG(oPanel,aItensAju)
Local aTagCpo := GrpCpo() 
Local aItens1 := iif(!IsBlind(),TagGrpCTE(@aTagCpo),{})
Local cGrupo  := iif(!IsBlind(),aItens1[1],'')
Local aItens2 := iif(!IsBlind(),TagGrpCPO(aTagCpo,cGrupo),{})
Local cCampo  := iif(!IsBlind(),aItens2[1],'')
Local oCboGrupo := Nil
Local oCboCampo := Nil
Local oSayDesc := Nil
Local oGetText := Nil
Local cTexto := SPACE(80)
Local oButInsere := Nil
Local oButExclui := Nil
Local oGrid := Nil

if !isBlind()
    oPanelGrid:= tPanel():New(045,005,,oPanel,,,,,,270,085)

   TSay():New(005,000,{||'Grupo'},oPanel,,,,,,.T.)

   oCboGrupo := TComboBox():New(000,020,{|u|if(PCount()>0,cGrupo:=u,cGrupo)},;
             aItens1,100,20,oPanel,,{|| oCboCampo:aItems:=TagGrpCPO(aTagCpo,cGrupo)  };
            ,,,,.T.,,,,,,,,,'cGrupo')

    TSay():New(005,130,{||'Campo'},oPanel,,,,,,.T.)
    
    oCboCampo := TComboBox():New(000,150,{|u|if(PCount()>0,cCampo:=u,cCampo)},;
             aItens2,100,20,oPanel,,{||oSayDesc:SetText( TagDescri(aTagCpo,cGrupo,cCampo) )  };
            ,,,,.T.,,,,,,,,,'cCampo')
    
    oSayDesc := TSay():New(020,020,{||TagDescri(aTagCpo,cGrupo,cCampo)},oPanel,,,,,,.T.)       

    oGetText := TGet():New( 030,020, { | u | If( PCount() == 0, cTexto, cTexto := u ) },oPanel,230,010, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cTexto",,,,  )

    oButInsere := TButton():Create( oPanel,030,255,"Adiciona",{||  SetaGrid(oGrid,aItensAju,cGrupo, cCampo,'1',cTexto)  }, 30,12,,,,.T.,,,,,,)

    oButExclui := TBtnBmp2():New( 120,560,26,26,'EXCLUIR',,,,{||  ExcluiItem(oGrid,aItensAju)  },oPanel,,,.T. )


    DEFINE FWBROWSE oGrid DATA ARRAY ARRAY aItensAju NO CONFIG  NO REPORT NO LOCATE OF oPanelGrid
        ADD COLUMN oColumn DATA { || aItensAju[oGrid:At(),1] } TITLE "Grupo" SIZE 070  OF oGrid
        ADD COLUMN oColumn DATA { || aItensAju[oGrid:At(),2] } TITLE "Campo" SIZE 070 OF oGrid
        ADD COLUMN oColumn DATA { || aItensAju[oGrid:At(),3] } TITLE "Texto" SIZE 100  OF oGrid
        oGrid:ACOLUMNS[1]:NALIGN := 1 //Alinhamento 
        oGrid:ACOLUMNS[2]:NALIGN := 1 //Alinhamento 
        oGrid:ACOLUMNS[3]:NALIGN := 1 //Alinhamento  
        oGrid:SetLineHeight(25) //Altura de cada linha
    ACTIVATE FWBROWSE oGrid
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} GrpCpo
Funcao responsavel por .

@param 	cGrupo		Grupo do Xml
		cTag			Tag a ser alterada
		cConteudo		Conteudo a ser alterado
        
@author  GTP
@since   27/05/2019
@version 12
/*/
//-------------------------------------------------------------------
Static Function GrpCpo()
Local aTagCPO := {}

dbSelectArea('G53')
G53->(DbSetOrder(1))
G53->(DbGoTop())

While G53->(!Eof())
    AADD(aTagCPO,{G53->G53_GRUPO,G53->G53_CAMPO,G53->G53_DESCCP})
    G53->(dbSkip())
END

Return aTagCPO

//-------------------------------------------------------------------
/*/{Protheus.doc} TagGrpCTE
Funcao responsavel por .

@param 	cGrupo		Grupo do Xml
		cTag			Tag a ser alterada
		cConteudo		Conteudo a ser alterado
        
@author  GTP
@since   27/05/2019
@version 12
/*/
//-------------------------------------------------------------------
Static Function TagGrpCTE(aTagCpo)
Local aGrupo := {}
Local cGrupo := ''
Local nX := 0

For nX := 1 to Len(aTagCpo)
    If cGrupo <> AllTrim(aTagCpo[nX][1])
        AADD(aGrupo, AllTrim( aTagCpo[nX][1] ) )
        cGrupo := AllTrim( aTagCpo[nX][1] )       
    EndIf
Next nX

Return aGrupo

//-------------------------------------------------------------------
/*/{Protheus.doc} TagGrpCPO
Funcao responsavel por .

@param 	cGrupo		Grupo do Xml
		cTag			Tag a ser alterada
		cConteudo		Conteudo a ser alterado
        
@author  GTP
@since   27/05/2019
@version 12
/*/
//-------------------------------------------------------------------
Static Function TagGrpCPO(aTagCpo,cGrupo)
Local aCampos := {}
Local nX := 0

For nX := 1 to Len(aTagCpo)
    If cGrupo == AllTrim(aTagCpo[nX][1])
        AADD(aCampos, AllTrim( aTagCpo[nX][2] ))             
    EndIf
Next nX

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} TagDescri
Funcao responsavel por .

@param 	cGrupo		Grupo do Xml
		cTag			Tag a ser alterada
		cConteudo		Conteudo a ser alterado
        
@author  GTP
@since   27/05/2019
@version 12
/*/
//-------------------------------------------------------------------
Static Function TagDescri(aTagCpo,cGrupo,cCampo)
Local cDescricao := ''
Local nX := 0

For nX := 1 to Len(aTagCpo)
    If cGrupo == AllTrim(aTagCpo[nX][1]) .AND. cCampo == AllTrim(aTagCpo[nX][2]) 
        cDescricao := AllTrim(aTagCpo[nX][3] )       
    EndIf
Next nX

Return cDescricao

//-------------------------------------------------------------------
/*/{Protheus.doc} SetaGrid
Funcao responsavel por .

@param 	cGrupo		Grupo do Xml
		cTag			Tag a ser alterada
		cConteudo		Conteudo a ser alterado
        
@author  GTP
@since   27/05/2019
@version 12
/*/
//-------------------------------------------------------------------
Static Function SetaGrid(oGrid,aItensAju,cGrupo, cCampo,cSeq,cTexto) 

If Len(aItensAju) < 19
    If aScan( aItensAju,{|x| x[1] == AllTrim(cGrupo) .AND. x[2] == AllTrim(cCampo) /*.AND. x[3] == AllTrim(cSeq)*/ }) == 0

        AADD( aItensAju ,{ cGrupo, cCampo/*,cSeq*/,Alltrim(cTexto) } )
        oGrid:SetArray(aItensAju)
        oGrid:Refresh()     

    EndIf
Else
    Alert('A limitaç?o de itens a serem corrigidos é de 20 itens')
EndIf        

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ExcluiItem
Funcao responsavel por .

@param 	cGrupo		Grupo do Xml
		cTag			Tag a ser alterada
		cConteudo		Conteudo a ser alterado
        
@author  GTP
@since   27/05/2019
@version 12
/*/
//-------------------------------------------------------------------
Static Function ExcluiItem(oGrid,aItensAju) 
Local nX := oGrid:nAt

IF !Empty(aItensAju)
    ADel(  aItensAju, nX )
    ASize( aItensAju, Len(aItensAju)-1 )
    oGrid:SetArray(aItensAju)
    oGrid:Refresh()    
EndIf

Return

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} procCCe
Processa correção do CTeOS

@param	cAlias  Alias do Browse
@param	nReg    Recno do Registro
@param	nOpc    Opcao da operção

@return	nil

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function CTEOSProcCCe(cEntidade, cAmbiente, cChaveCte, cProtocolo, cCorrecao, cLbStatus, oImgStatus, cRetorno, lAut)

    local oReq
    local oResp
    local cReq
    local lValid
    Default lAut := .F.

    lValid := validaCCeCTeOS(@cCorrecao, @cRetorno)

    if(lValid)
        cReq := '{ "msg": {"entidade": "' + cEntidade +'", "ambiente": "' + cAmbiente +'"'
        cReq += ', "cteos": [ {"chaveCTe": "' + cChaveCTe + '", "protocolo": "' + cProtocolo +  '",'
        cReq += cCorrecao + '}]}}'

        if(fwJsonDeserialize(cReq, @oReq) )

            TraCTeOSCCe(oReq, @oResp)

            if(oResp:error == nil)

                cReq := '{"msg": {"entidade": "' + cEntidade + '", "codEvento": "110110", "chaveCTe": "' + cChaveCte + '"}}'

                if(fwJsonDeserialize(cReq, @oReq))

                    CTeOSConEv(oReq, @oResp)

                    if(oResp:error == nil)
                        if(oResp:response:status == 1)
                            oImgStatus:setBmp("qmt_cond.png")
                            cLbStatus := "Carta de Correção não Processada!"
                            cRetorno += "Acompanhe o Status de Processamento atraves da opção 'Consultar Eventos'"
                        elseif(oResp:response:status == 2)
                            oImgStatus:setBmp("qmt_ok.png")
                            cLbStatus := "Carta de Correção Autorizada!"
                            cRetorno := oResp:response:details + CRLF + "Protocolo: " + oResp:response:autorizacao:protocolo

                        elseif(oResp:response:status == 3)
                            oImgStatus:setBmp("qmt_no.png")
                            cLbStatus := "Carta de Correção Rejeitada"
                            cRetorno := "Rejeição: " + oResp:RESPONSE:rejeicao:codigo
                            cRetorno += oResp:RESPONSE:rejeicao:motivo

                        endif

                    else
                        oImgStatus:setBmp("qmt_cond.png")
                        cLbStatus := "Carta de Correção não Autorizada."
                        cRetorno := decode64(oResp:error)
                    endif

                else
                    oImgStatus:setBmp("qmt_cond.png")
                    cLbStatus := "Carta de Correção não transmitido."
                    cRetorno := "Requisicao inválida:" +CRLF + cReq
                endif

            else
                oImgStatus:setBmp("qmt_cond.png")
                cLbStatus := "Carta de Correção não transmitido"
                cRetorno := decode64(oResp:error)
            endif
        else
            if !lAut
                oImgStatus:setBmp("qmt_no.png")
                cLbStatus := "Carta de Correção não transmitida."
                cRetorno := "Requisicao inválida:" +CRLF + cReq
            endif
        endif

        if !lAut
            oImgStatus:refresh()
        endif
    endif

return lvalid
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} validaCCeCTeOS
Valida e monta Mensagem da correção

@param cCorreção    Referencia com String com os dados para a correção

@return	nil

@author  Renato Nagib
@since   30/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
static function validaCCeCTeOS(cCorrecao, cRetorno)

	local lValid := .T.
	local nC
	
	private aValor
	
	cCorrecao := Alltrim(cCorrecao)
	cCorrecao := StrTran(cCorrecao,Chr(10),"")
	cCorrecao := StrTran(cCorrecao,Chr(13),"")
	cCorrecao := StrTran(cCorrecao,Chr(135),"&Amp;")
	cCorrecao := StrTran(cCorrecao,Chr(198),"&atilde;")

    aCorrecao := Strtokarr2( cCorrecao, ";", .F.)

    if(!empty(aCorrecao))

        cCorrecao := '"correcoes": ['

        for nC :=  1 to len(aCorrecao)

			aValor := Strtokarr2(aCorrecao[nC], ":", .T.)
			
			aRet := validDados( aValor )
	
			//----------------------------------
			// Processo executado com sucesso
			//----------------------------------
            
			if aRet[1]
				
				//cCorrecao := '"correcoes": ['
				if Len(aValor) >= 3
				    if(nC > 1)
				        cCorrecao += ','
				    endif
				
				    cCorrecao += '{"grupo":"' + aValor[1] +'", "campo": "' + aValor[2] + '", "valor": "' + aValor[3] + '"}'
				
			    endif
			   // cCorrecao += ']'
			//----------------------------------
			// Processo falhou
			//----------------------------------    
			else
				if Len(aRet) >= 2 
					if( len(aRet[2]) > 0 )
						lValid		:= aRet[1]
						cCorrecao := aRet[2]
					endif
				endif
			endif
        next
        
        cCorrecao += ']'  
         
        if(empty(cCorrecao))
            lValid := .F.
            cCorrecao := "Estrutura invalida" + cCorrecao
        endif
    else
        cCorrecao := "Estrutura invalida" + cCorrecao
    endif

	if(!lValid)
	    aviso("CTeOS - Carta de Correção", cCorrecao, {STR0004}, 3)
	endif
    
return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} validDados
Funcao responsavel por validar os dados recebidos.

@param 	aValid
		[1]cGrupo			Grupo do Xml
		[2]cTag			Tag a ser alterada
		[3]cConteudo		Conteudo a ser alterado

@return	lValid			Retorna processo executado com sucesso.
		cDescricao		Descricao do resultado.

@author  Douglas Parreja
@since   20/08/2018
@version 12
/*/
//-------------------------------------------------------------------
static function validDados( aValid )

	local aRet		:= {}
	default aValid 	:= {}
	private aDados 	:= aValid
	
	if( type("aDados[1]") <> "U" .and. type("aDados[2]") <> "U" .and. type("aDados[3]") <> "U" )
		aRet := validLen( aDados[1], aDados[2], aDados[3] )
	else
		aRet := { .F., "Estrutura invalida" }
	endif				

return aRet

/*/
* {Protheus.doc} validLen()
* Funcao responsavel por validar o tamanho do conteudo.
* type    Function
* author  Eduardo Ferreira
* since   16/08/2019
* version 12.25
* param   cGrupo, cTag, cConteudo
* return   lValid, cRet
/*/
static function validLen( cGrupo, cTag, cConteudo )	
local lValid := .T.
local cRet	 := ''

default cGrupo	  := ''
default cTag	  := ''
default cConteudo := ''
        
if ( !(empty(cGrupo)) .and. !(empty(cTag)) .and. !(empty(cConteudo)) )
    //---------------------------------------
    // Grupo IDE
    //---------------------------------------
    if alltrim(upper(cGrupo)) == "IDE"
        //---------------------------------------
        // Tag somente com 1 conteudo
        //---------------------------------------
        if( upper(cTag) $ "TPIMP|TPEMIS|CDV|TPAMB|TPCTE|PROCEMI|TPSERV|INDIETOMA" )
            if len(alltrim(cConteudo)) <> 1
                lValid 	:= .F.									
                cRet 	:= STR0070 + alltrim(cTag) + STR0069 //" deve ter o máximo de 1 caracter."
            endif
        endif
    //---------------------------------------
    // Grupo COMPLEMENTOS
    //---------------------------------------
    elseif alltrim(upper(cGrupo)) == "COMPL"
        if( len(alltrim(cConteudo)) < 15 ) 
            lValid	:= .F.
            cRet		:= STR0072 + alltrim(cTag) + STR0071 //" deve ter o mínimo de 15 caracteres."
        elseif( len(alltrim(cConteudo)) > 255)
            lValid 	:= .F.
            cRet		:= STR0072 + alltrim(cTag) + STR0073 //"A Correção para a tag "
        endif
    //---------------------------------------
    // Grupo EMITENTE
    //---------------------------------------
    elseif alltrim(upper(cGrupo)) == "EMIT"
        //---------------------------------------
        // Tag no minimo 1 conteudo
        //---------------------------------------
        if upper(cTag) $ "NRO"
            if len(alltrim(cConteudo)) == 0
                lValid := .F.									
                cRet := STR0070 + alltrim(cTag) + STR0074 //"A correção para a tag "
            endif
        endif
    //---------------------------------------
    // Grupo TOMADOR
    //---------------------------------------
    elseif alltrim(upper(cGrupo)) == "TOMA"
        //---------------------------------------
        // Tag no minimo 1 conteudo
        //---------------------------------------
        if upper(cTag) $ "NRO"
            if len(alltrim(cConteudo)) == 0
                lValid := .F.									
                cRet := STR0075 //"A correção deve ter o mínimo de 1 caracter"
            endif
        endif
    //---------------------------------------
    // Grupo IMPOSTOS
    //---------------------------------------
    elseif alltrim(upper(cGrupo)) == "IMP"
        //---------------------------------------
        // Valores nao podem serem alterados
        //---------------------------------------
        lValid := .F.									
        cRet := STR0070 + alltrim(cTag) + STR0076 //"A correção para a tag "
    endif
endif
                            
return { lValid, cRet }

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} CTeOSCCe
Transmite uma Carta de Correção de CTeOS para o TSS

@param	cEntidade       Codigo da Entidade
@param	cChaveCTe       Chave do CTeOS 
@param	cProtocolo      Protocolo do CTeOS
@param  cJustificativa  Justificativa do cancelamento
@param  cRetorno        String com Retorno da Transmissão

@return	Retorno logico indicando se o retorno foi gerado

@author  Renato Nagib
@since   30/09/2017
@version 12.1.18

/*/
//-----------------------------------------------------------------------------------------------
function TraCTeOSCCe(oReq, oResp, lAut)
    
    local cXml
    local cError := ""
    local lSend
    local aIds  := {}
    local cJsonRet
    local nItens
    Default lAut := .F.

    if !lAut
        cXml := xmlEvtCCe(oReq:msg:cteos[1]:chaveCte,;
            oReq:msg:ambiente, oReq:msg:cteos[1]:correcoes)
        
        lSend := transmiteEvento(oReq:msg:entidade, cXml, @aIds, @cError)
        
        if(lSend)        
            cJsonRet := '{ "motivo": "Carta de Correcao Transmitida com Sucesso", "idEvento": ['  
            
            for nItens := 1 to len(aIds)            
                cJsonRet += '{"id": "' + aIds[nItens] + '"}'
            next
            
            cJsonRet += ']}'
        
        endif    

        oResp :=  getJsonResponse(cJsonRet, cError) 
    endif
return (oResp <> nil)
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} xmlEvtCCe
Montagem do Xml de carta de correção

@param	cChaveCTe       Chave do CTeOS
@param  cAmbiente       Ambiente para transmissão do Evento
@param  aCorrecao       Informações das correções aCorrecao[x][1] = Grupo;  aCorrecao[x][2] = campo;aCorrecao[x][3] = valor

@return cXml            String com Xml do Evento

@author  Renato Nagib
@since   30/09/2017
@version 12.1.18

/*/
//-----------------------------------------------------------------------------------------------
static function xmlEvtCCe(cChaveCTe, cAmbiente, aCorrecao)
    
    local cXml := ""
    local nCorrecao
    local cTipoEvento := "110110"

    cXml +='<envEvento>'
    cXml +='<eventos>'
    cXml +='<detEvento>'
    cXml +='<tpEvento>' + cTipoEvento + '</tpEvento>'
    cXml +='<chnfe>' + cChaveCTe + '</chnfe>'
    cXml +='<ambiente>' + cAmbiente + '</ambiente>'      	
    for nCorrecao := 1 to len(aCorrecao)    
        cXml +='<Correcao>'
        cXml +='<grupo>'+ aCorrecao[nCorrecao]:grupo+ '</grupo>'
        cXml +='<campo>'+ aCorrecao[nCorrecao]:campo + '</campo>'
        cXml +='<valor>'+ aCorrecao[nCorrecao]:valor + '</valor>'
        cXml +='</Correcao>'
    next
    
    cXml +='</detEvento>'
    cXml +='</eventos>'
    cXml +='</envEvento>'

return cXml
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} transmiteEvento
Transmissão dos Eventos

@param	cEntidade       Codigo da Entidade
@param	cXml            Xml do Evento
@param  aIds            Referencia para retorno dos Ids dos eventos transmitidos
@param  cError          Referencia para retorno de erro na execução

@return lSend           Indica se o Evento foi Transmitido

@author  Renato Nagib
@since   30/09/2017
@version 12.1.18

/*/
//-----------------------------------------------------------------------------------------------
static function transmiteEvento(cEntidade, cXml, aIds, cError)

    local oWS
    Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
    local lSend := .F.
    local nEventos
    Default cEntidade := ''
    Default cXml      := ''

    oWS := wsNFeSBra():new()
    oWS:_URL := allTrim(cURL) + "/NFeSBRA.apw"			
    oWs:cUserToken := "TOTVS"
    oWS:cID_ENT    := cEntidade    
    oWS:cXml_lote  := cXml 

    if( oWS:remessaEvento() )
        
        for nEventos := 1 to len(oWS:oWSREMESSAEVENTORESULT:cString)
            aadd(aIds, oWS:oWSREMESSAEVENTORESULT:cString[nEventos])
        next    
        
        lSend := !empty(aIds)

    else
        cError := iif( empty( getWscError(3)), getWscError(1), getWscError(3))
    endif

return lSend
