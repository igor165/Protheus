#include "totvs.ch"
#include "protheus.ch"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSUA410
Gera arquivo PTU 410 Versao XML

@author    renan.almeida
@version   1.xx
@since     06/09/2019
/*/
//------------------------------------------------------------------------------------------
Function PLSUA410(lAuto,aParamAuto)
    Local aRetAuto  := {}
    Local oObj      := PLSXmlPTU():New()
        
    Local aPergs    := {}
    Local __aRet    := {}
    Local lRetParam := .T.
    Local lEnd      := .T.

    Private oProcess := Nil

    Default lAuto      := .F.
    Default aParamAuto := {}

    oObj:cLayPTU  := "00410"
    oObj:cSchema  := "ptu_A410.xsd"
    oObj:lAuto    := lAuto
    
    //Verifica se os alias novos existem na base
    if  !PLSALIASEXI("B5U") .Or. !PLSALIASEXI("B5V") .Or. !PLSALIASEXI("B5W") .Or. ;
        !PLSALIASEXI("B5X") .Or. !PLSALIASEXI("B5Y") .Or. !PLSALIASEXI("B5Z")
        
        if !oObj:lAuto
            Aviso( "Resumo processamento PTU A410","Para processar esta rotina, é necessário criar as tabelas B5U, B5V, B5W, B5X, B5Y e B5Z.",{ "OK"}, 2 )
        endIf

        aRetAuto := {.F.,"Resumo processamento PTU A410","Para processar esta rotina, é necessário criar as tabelas B5U, B5V, B5W, B5X, B5Y e B5Z."}
        Return iif(oObj:lAuto,aRetAuto,.T.)
    
    endIf    

    //Monta tela de parametros
    aadd(aPergs,{ 6,"Diretorio de gravacao" , Space(100),"@!","","",90,.t.,,,nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY )})
    aadd(aPergs,{ 1,"Rda De"                , Space(6)	,"@!",'.T.','BAUPLS',nil,40,.F. } )
    aadd(aPergs,{ 1,"Rda Ate"               , Space(6)	,"@!",'.T.','BAUPLS',nil,40,.T. } )
    aadd(aPergs,{ 1,"Operadora Destino"     , Space(4)	,"@!",'.T.','B39PLS',nil,40,.T. } )
    aadd(aPergs,{ 1,"Produto Intercambio"    , Space(4)	,"@!",'.T.','BIXPLS',nil,40,.T. } )
    aadd(aPergs,{ 1,"Versão Produto Interc. ", Space(3)	,"@!",'.T.','',nil,40,.T. } )

    if oObj:lAuto
        __aRet := aParamAuto     
    elseIf !paramBox( aPergs,"Parâmetros - PTU A410",__aRet,/*bOK*/,/*aButtons*/,/*lCentered*/.T.,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLUA410',/*lCanSave*/.T.,/*lUserSave*/.T. )
        lRetParam := .F.
    endIf

    if lRetParam

        if oObj:lAuto 
            geraArquiv(@lEnd,oObj,__aRet,@aRetAuto)
        else
            oProcess := MsNewProcess():New({|lEnd | geraArquiv(@lEnd,oObj,__aRet) }, "Aguarde...","Carregando dados...",lEnd )
            oProcess:Activate()
        endIf
    
    endIf
   
Return iif(oObj:lAuto,aRetAuto,.T.)



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} geraArquiv
Processa a geracao do arquivo A410

@author    renan.almeida
@version   1.xx
@since     06/09/2019
/*/
//------------------------------------------------------------------------------------------
Static Function geraArquiv(lEnd,oObj,__aRet,aRetAuto) 
    Local cSql   := ""
    local cMsgFinal := ""

    Local cFolder := allTrim( __aRet[ 1 ])
    Local cRdaDe  := iif(!empty(__aRet[ 2 ]),allTrim( __aRet[ 2 ]),' ')
    Local cRdaAte := allTrim( __aRet[ 3 ])
    Local cOpeDes := allTrim( __aRet[ 4 ])
    Local cErro   := ""
    
    cSql += " SELECT * FROM "+RetSqlName("BAU")+" BAU "
	
    cSql += " INNER JOIN "+RetSqlName("BAG")+" BAG "
	cSql += "   ON BAG_FILIAL = '"+xFilial("BAG")+"' "
    cSql += "   AND BAU_TIPPRE = BAG_CODIGO " 
	cSql += "   AND BAG_CODPT IN ('02','10') " 
	cSql += "   AND BAG.D_E_L_E_T_ = ' ' "

    cSql += " LEFT JOIN "+RetSqlName("B5X")+" B5X "
	cSql += "   ON B5X_FILIAL = '"+xFilial("B5X")+"' "
    cSql += "   AND BAU_CODIGO = B5X_CODRDA " 
	cSql += "   AND B5X.D_E_L_E_T_ = ' ' "

    cSql += " WHERE BAU_FILIAL = '"+xFilial("BAU") +"' "
    cSql += " AND BAU_CODIGO BETWEEN '"+cRdaDe+ "' AND '"+cRdaAte+ "' "
    cSql += " AND BAU_GUIMED = '1' " 

    cSql += " AND BAU.D_E_L_E_T_ = ' ' "  
    cSql += " ORDER BY BAU_CODIGO "

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBPRES",.F.,.T.)

    if TRBPRES->(eof()) 
        cErro := "Não foi encontrada nenhuma RDA com os parâmetros informados."
    else

        montaArq(oObj,cOpeDes,__aRet) //Monta arquivo XML
      
        //Valida arquivo gerado
        if Empty(oObj:aCriticas) .And. oObj:validXML()
            if oObj:lAuto
                aRetAuto := {.T.,oObj:cXml}
            else
                //Gera arquivo XML
                oObj:cFolder   := cFolder
                oObj:cFileName := "CR"+Substr(Dtos(dDataBase),7,2)+Substr(Dtos(dDataBase),5,2)+Substr(Dtos(dDataBase),3,2)+"."+Substr(PlsIntPad(),2,3)
                oObj:geraXML(.t.)
            endIf

        else
            cErro := iif(Empty(oObj:aCriticas),oObj:cErroXML + oObj:cAvisoXML,"Foram encontrados erros no processamento do arquivo.")
        endIf
    
    endIf

    TRBPRES->(dbCloseArea())

    aRetAuto := iif(Empty(cErro),{.T.,oObj:cXml},{.F.,cErro})

    //Se nao for automacao, mostra msg final
    if !oObj:lAuto
        //Monta grid de criticas no processamento
        if !Empty(oObj:aCriticas)
            oObj:exibeCrit()
            
        //Sucesso / Erro na geracao do arquivo XML
        else
            cMsgFinal := iif(Empty(cErro),"O arquivo "+oObj:cFileName+" foi gerado no diretório "+oObj:cFolder+" com sucesso.",cErro)
            Aviso( "Resumo processamento PTU A410",cMsgFinal,{"OK"}, 2 )
        endIf    
    endIf

Return 



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} montaArq
Monta a estrutura do arquivo A410

@author    renan.almeida
@version   1.xx
@since     06/09/2019
/*/
//------------------------------------------------------------------------------------------
Static Function montaArq(oObj,cOpeDes,__aRet)
    Local nTotal := 0

    oObj:IniFile('ptuA410','ISO-8859-1') //Inicia arquivo
    montaCabec(oObj,cOpeDes) //Monta cabecalho
    oObj:MontaTag(1,'arquivoA410',nil,nil,.T.) //Body

    If !oObj:lAuto
        TRBPRES->( dbEval( { || nTotal++ } ) )
        TRBPRES->(DBGoTop())
        oProcess:SetRegua2(nTotal)
    ENDIF

    //Percorre as Rdas encontradas
    while !TRBPRES->(eof()) 

        // Regua para contagem <espMedHopEsp>
        IF !oObj:lAuto

            //Para não cortar o nome do RDA na Primeira Barra
            oProcess:OMSG1:NHEIGHT  := 28
            oProcess:OMSG1:NBOTTOM  := 40
            OPROCESS:OMETER1:NTOP   := 40
            oProcess:IncRegua1("Gerando arquivo - " + TRBPRES->BAU_CODIGO + " - " + TRBPRES->BAU_NOME)
        ENDIF

        geraPrest(oObj,__aRet)
        TRBPRES->(dbSkip())
    endDo
    
    oObj:MontaTag(1,'arquivoA410',nil,nil,.F.,.T.) //Finaliza Body
    
    oObj:CalcHash() //Calcula Hash
    oObj:MontaTag(1,'hash',oObj:cHashMD5,nil,nil,nil,nil,nil,.F. ) //Gera tag de Hash
    oObj:MontaTag(0,'ptuA410',nil,nil,.F.,.T.) //Finaliza arquivo

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} montaCabec
Monta cabecalho do arquivo A410

@author    renan.almeida
@version   1.xx
@since     06/09/2019
/*/
//------------------------------------------------------------------------------------------
Static Function montaCabec(oObj,cOpeDes)

    Local cNrVerPTU  := ''
    Local cUniOri    := ''
    Local cUniDes    := ''
    Local cDatGer    := ''
    Default cOpeDes  := ''
    
    //Variaveis Cabecalho
    cNrVerPTU := '02'        //nrVerTra_PTU - REV.06
    cUniOri   := PlsIntPad() //cd_Uni_Origem
    cUniDes   := cOpeDes     //cd_Uni_Destino
    cDatGer   := Dtos(dDataBase) //dt_geracao

    oObj:MontaTag(1,'cabecalho',nil,nil,.T.)
    oObj:MontaTag(2,'nrVerTra_PTU',cNrVerPTU,.T.)
    oObj:MontaTag(2,'cd_Uni_Origem',cUniOri,.T.)
    oObj:MontaTag(2,'cd_Uni_Destino',cUniDes,.T.)
    oObj:MontaTag(2,'dt_geracao',cDatGer,.T.)
    oObj:MontaTag(1,'cabecalho',nil,nil,.F.,.T.)

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} geraPrest
Gera dados de um prestador no arquivo

@author    renan.almeida
@version   1.xx
@since     06/09/2019
/*/
//------------------------------------------------------------------------------------------
Static Function geraPrest(oObj,__aRet)

    Local cCnpjCpf   := Alltrim(TRBPRES->BAU_CPFCGC)
    Local cCd_prest	 := Alltrim(TRBPRES->BAU_CODIGO)
    Local cIdNivDisp := Alltrim(TRBPRES->B5X_NIVDIS)
    Local cId_uti	 := Alltrim(TRBPRES->B5X_IDUTI)
    Local cId_sadt	 := 'S'
    local cTp_Acred  := Alltrim(TRBPRES->B5X_TPACRE)   
    local cCodOpe   := PlsIntPad()
    local aDadRDA := {}

    aDadRda := PLSDADRDA(cCodOpe, TRBPRES->BAU_CODIGO, "1", dDataBase,"","")
    if aDadRDA[1]
        oObj:MontaTag(2,'dados_prestador_a410',nil,nil,.T.)

        //Dados Prestador
        oObj:MontaTag(3,'nr_CNPJouCPF',nil,nil,.T.)
        oObj:MontaTag(4,iif(TRBPRES->BAU_TIPPE == "J",'cd_cnpj','cd_cpf'),cCnpjCpf,.T.)
        oObj:MontaTag(3,'nr_CNPJouCPF',nil,nil,.F.,.T.)
        oObj:MontaTag(3,'cd_prest',cCd_prest,.T.)
        oObj:MontaTag(3,'id_nivel_disp',cIdNivDisp,.T.)
        oObj:MontaTag(3,'id_uti',cId_uti,.T.)
        oObj:MontaTag(3,'id_sadt',cId_sadt,.T.)
        oObj:MontaTag(3,'tp_acreditacao',cTp_Acred,.T.)
        
        espMedHopEsp(oObj)  //Gera Tag especialidades médicas
        hospA410(oObj)      //Gera tags de hospitais  
        sadtA410(oObj)      //Gera Tag sadt_a410
        leitosA410(oObj)    //Gera tag leitos_a410
        criEcoA410(oObj)    //Gera tag criterios_economicos_a410
        diaTax410(oObj,__aRet,aDadRDA)     //Gera tag diarias_taxas_410
        
        //Finaliza
        oObj:MontaTag(2,'dados_prestador_a410',nil,nil,.F.,.T.)
    else 
        oObj:AddCritica("Prestador "+TRBPRES->BAU_CODIGO + " com a crítica: "+aDadRDA[2][1][2])
    ENDIF
Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} espMedHopEsp
Monta tag de especialidades médicas

@author    renan.almeida
@version   1.xx
@since     06/09/2019
/*/
//------------------------------------------------------------------------------------------
Static Function espMedHopEsp(oObj)
    
    Local cCdServExi := ""
    Local cServDisp  := ""
    Local cIdItern   := ""
    Local cIdEleAmb  := ""
    Local cIdSobAvis := ""
    Local cIdHospEsp := ""
    Local cId_12h    := ""
    Local cId_24h    := ""
    Local aValidTag  := {}
    Local nX         := 0
    Local nQtdReg    := 0
    Local nTotal     := 0

    QryServ410("1")

    If !oObj:lAuto    
        TRBSERV->( dbEval( { || nTotal++ } ) )
        TRBSERV->(DBGoTop())
        oProcess:SetRegua2(nTotal)
    ENDIF

    while !TRBSERV->(eof()) 

        nQtdReg ++

        // Regua para contagem <espMedHopEsp>
        if !oObj:lAuto
            oProcess:IncRegua2("Registros para a tag <espMedHopEsp> " + cValToChar(nQtdReg) + " de " +  cValToChar(nTotal)  )
        ENDIF

        if nQtdReg > 500
            oObj:AddCritica("A quantidade máxima de registros para a tag <espMedHopEsp> é 500.")
        endIf

        cCdServExi := cValtoChar(TRBSERV->B5L_CODSW2)
        cServDisp  := iif(TRBSERV->B5L_SERDIS == "1","S","N")
        cIdItern   := TRBSERV->B5L_INT410
        cIdEleAmb  := TRBSERV->B5L_AMB410  
        cIdSobAvis := TRBSERV->B5L_SOB410
        cIdHospEsp := TRBSERV->B5L_HOSESP

        if TRBSERV->B5L_HOR410 == "1" //12 Horas
            cId_12h    := "01"
            cId_24h    := "02"
        elseIf TRBSERV->B5L_HOR410 == "2" //24 Horas
            cId_12h    := "02"
            cId_24h    := "01"
        elseIf TRBSERV->B5L_HOR410 == "3" //Nao se aplica
            cId_12h    := "03"
            cId_24h    := "03"
        elseIf TRBSERV->B5L_HOR410 == "4" //Nao atende 12h nem 24h
            cId_12h    := "02"
            cId_24h    := "02"
        endIf    

        //Valida preenchimento das tags
        aValidTag := {}
        Aadd(aValidTag,{"id_internacao",cIdItern})
        Aadd(aValidTag,{"cIdEleAmb",cIdEleAmb})
        Aadd(aValidTag,{"id_12h",cId_12h})
        Aadd(aValidTag,{"id_24h",cId_24h})
        Aadd(aValidTag,{"id_sobreaviso",cIdSobAvis})

        for nX := 1 to len(aValidTag)
            if aValidTag[nX,2] == "03" .Or. Empty(aValidTag[nX,2])
                oObj:AddCritica("Valor inválido para a tag <"+aValidTag[nX,1]+">. Prest: "+TRBPRES->BAU_CODIGO+" - Espec/Serv: " + cValtochar(TRBSERV->B5L_CODSW2))
            endIf    
        next

        oObj:MontaTag(3,'espMedHopEsp',nil,nil,.T.)    
        oObj:MontaTag(4,'cd_serv_exist',cCdServExi,.T.)
        oObj:MontaTag(4,'serv_disp',cServDisp,.T.)
        oObj:MontaTag(4,'id_internacao',cIdItern,.T.)
        oObj:MontaTag(4,'id_eletivo_amb',cIdEleAmb,.T.) 
        oObj:MontaTag(4,'id_12h',cId_12h,.T.)
        oObj:MontaTag(4,'id_24h',cId_24h,.T.)
        oObj:MontaTag(4,'id_sobreaviso',cIdSobAvis,.T.)
        oObj:MontaTag(4,'id_hosp_espec',cIdHospEsp,.T.)

        oObj:MontaTag(3,'espMedHopEsp',nil,nil,.F.,.T.)

        TRBSERV->(dbSkip())
    endDo
    TRBSERV->(dbCloseArea())

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} hospA410
Monta tag de serv_Hosp
@since     02/2020
/*/
//------------------------------------------------------------------------------------------
Static Function hospA410(oObj)
    Local cCdSerExi := ""
    Local cServDisp := ""
    Local nQtdReg   := 0
    Local nTotal    := 0

    QryServ410("2")
    If !oObj:lAuto
        TRBSERV->( dbEval( { || nTotal++ } ) )
        TRBSERV->(DBGoTop())
        oProcess:SetRegua2(nTotal)
    ENDIF

    //Gera Tags servico_a410
    while !TRBSERV->(eof()) 
        
        nQtdReg ++

        // Regua para contagem <espMedHopEsp>
        If !oObj:lAuto
            oProcess:IncRegua2("Registros para a tag <servHosp> " + cValToChar(nQtdReg) + " de " +  cValToChar(nTotal)  )
        ENDIF
        if nQtdReg > 500
            oObj:AddCritica("A quantidade máxima de registros para a tag <servHosp> é 500.")
        endIf

        cCdSerExi := cValtoChar(TRBSERV->B5L_CODSW2)
        cServDisp := iif(TRBSERV->B5L_SERDIS == "1","S","N")

        oObj:MontaTag(3,'servHosp',nil,nil,.T.)

        oObj:MontaTag(4,'cd_serv_exist',cCdSerExi,.T.)
        oObj:MontaTag(4,'serv_disp',cServDisp,.T.)

        oObj:MontaTag(3,'servHosp',nil,nil,.F.,.T.)

        TRBSERV->(dbSkip())
    endDo
    TRBSERV->(dbCloseArea())
 
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} sadtA410
Monta tag de sadt_a410

@author    renan.almeida
@version   1.xx
@since     06/09/2019
/*/
//------------------------------------------------------------------------------------------
Static Function sadtA410(oObj)
    Local cCdSerExi := ""
    Local cServDisp := ""
    Local cTpConSad := ""
    Local cNomTer1  := ""
    Local cCNPJTer1 := ""
    Local cNomTer2  := ""
    Local cCNPJTer2 := ""
    Local nQtdReg   := 0
    Local nTotal    := 0

    QryServ410("3")
    
    If !oObj:lAuto
        TRBSERV->( dbEval( { || nTotal++ } ) )
        TRBSERV->(DBGoTop())
        oProcess:SetRegua2(nTotal)
    Endif

    //Gera Tags servico_a410
    while !TRBSERV->(eof()) 
        
        nQtdReg ++

        // Regua para contagem <espMedHopEsp>
        If !oObj:lAuto
            oProcess:IncRegua2("Registros para a tag <sadt_a410> " + cValToChar(nQtdReg) + " de " +  cValToChar(nTotal)  )
        ENDIF

        if nQtdReg > 200
            oObj:AddCritica("A quantidade máxima de registros para a tag <sadt_a410> é 200.")
        endIf

        cCdSerExi := cValtoChar(TRBSERV->B5L_CODSW2)
        cServDisp := iif(TRBSERV->B5L_SERDIS == "1","S","N")
        cTpConSad := TRBSERV->B5L_TPSADT 
        cNomTer1  := Alltrim(TRBSERV->B5L_NMTER1)
        cCNPJTer1 := Alltrim(TRBSERV->B5L_RGTER1)
        cNomTer2  := Alltrim(TRBSERV->B5L_NMTER2)
        cCNPJTer2 := Alltrim(TRBSERV->B5L_RGTER2)

        //Validacoes de tag
        if cTpConSad == "02" .And. (Empty(cNomTer1) .Or. Empty(cCNPJTer1))   
            oObj:AddCritica("As tags <sadt_nm_terc_1> e <sadt_cnpj_cpf_terc_1> são obrigatórias quando <tp_contrat_sadt> for '02'. Prest: "+TRBPRES->BAU_CODIGO+" - Espec: " + cValtochar(TRBSERV->B5L_CODSW2))
        endIf

        oObj:MontaTag(3,'sadt_a410',nil,nil,.T.)

        oObj:MontaTag(4,'cd_serv_exist',cCdSerExi,.T.)
        oObj:MontaTag(4,'serv_disp',cServDisp,.T.)
        oObj:MontaTag(4,'tp_contrat_sadt',cTpConSad,.T.)
        oObj:MontaTag(4,'sadt_nm_terc_1',cNomTer1)
        oObj:MontaTag(4,'sadt_cnpj_cpf_terc_1',cCNPJTer1)
        oObj:MontaTag(4,'sadt_nm_terc_2',cNomTer2)
        oObj:MontaTag(4,'sadt_cnpj_cpf_terc_2',cCNPJTer2)

        oObj:MontaTag(3,'sadt_a410',nil,nil,.F.,.T.)

        TRBSERV->(dbSkip())
    endDo
    TRBSERV->(dbCloseArea())
 
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} leitosA410
Monta tag de leitos_a410

@author    renan.almeida
@version   1.xx
@since     06/09/2019
/*/
//------------------------------------------------------------------------------------------
Static Function leitosA410(oObj)

    Local cNRLBER := ""
    Local cNRLPIS := ""
    Local cNRLINT := ""
    Local cNRLDIA := ""
    Local cNRLIND := ""
    Local cNRLCOL := ""
    Local cNRLISO := ""
    Local cNRLUCC := ""
    Local cNRLSEM := ""
    Local cNLNEOC := ""
    Local cNLNNCG := ""
    Local cNRLPED := ""
    Local cNRLADU := ""
    Local cNLCORO := ""
    Local cNRUTIP := ""
    Local cNRUTIA := ""
    Local cNRUTIN := ""
    Local cUTITP1 := ""
    Local cUTITP2 := ""
    Local cUTITP3 := ""
    Local cUTIPT1 := ""
    Local cUTIPT2 := ""
    Local cUTIPT3 := ""
    Local cUTINT1 := ""
    Local cUTINT2 := ""
    Local cUTINT3 := ""
    Local cUTIQUE := ""
    Local cUTICR2 := ""
    Local cNOBSPA := ""
    Local cNEMRPA := ""

    Local cNRLPISE := ""
    Local cNRLINTE := ""
    Local cNRLDIAE := ""
    Local cNRLBERE := ""
    Local cNRLINDE := ""
    Local cNRLCOLE := ""
    Local cNRLISOE := ""
    Local cNRLUCCE := ""
    Local cNRLSEME := ""
    Local cNLNEOCE := ""
    Local cNLNNCGE := ""
    Local cNRLPEDE := ""
    Local cNRLADUE := ""
    Local cNLCOROE := ""
    Local cNRUTIAE := ""
    Local cNRUTINE := ""
    Local cNRUTIPE := ""
    Local cUTITP1E := ""
    Local cUTITP2E := ""
    Local cUTITP3E := ""
    Local cUTIPT1E := ""
    Local cUTIPT2E := ""
    Local cUTIPT3E := ""
    Local cUTINT1E := ""
    Local cUTINT2E := ""
    Local cUTINT3E := ""
    Local cUTIQUEE := ""
    Local cUTICR2E := ""
    Local cNOBSPAE := ""
    Local cNEMRPAE := ""

    B5X->(DbSetOrder(1))//B5X_FILIAL+B5X_CODRDA

    //Gera Tags servico_a410
    if B5X->(DbSeek(xFilial("B5X")+Alltrim(TRBPRES->BAU_CODIGO))) 

        //Leitos Existentes
        cNRLPISE := iif(B5X->B5X_ERLPIS > 0, cValtoChar(B5X->B5X_ERLPIS),"")
        cNRLINTE := iif(B5X->B5X_ERLINT > 0, cValtoChar(B5X->B5X_ERLINT),"")
        cNRLDIAE := iif(B5X->B5X_ERLDIA > 0, cValtoChar(B5X->B5X_ERLDIA),"")
        cNRLBERE := iif(B5X->B5X_ERLBER > 0, cValtoChar(B5X->B5X_ERLBER),"")
        cNRLINDE := iif(B5X->B5X_ERLIND > 0, cValtoChar(B5X->B5X_ERLIND), "")
        cNRLCOLE := iif(B5X->B5X_ERLCOL > 0, cValtoChar(B5X->B5X_ERLCOL), "")
        cNRLISOE := iif(B5X->B5X_ERLISO > 0, cValtoChar(B5X->B5X_ERLISO), "")
        cNRLUCCE := iif(B5X->B5X_ERLUCC > 0, cValtoChar(B5X->B5X_ERLUCC), "")
        cNRLSEME := iif(B5X->B5X_ERLSEM > 0, cValtoChar(B5X->B5X_ERLSEM), "")
        cNLNEOCE := iif(B5X->B5X_ELNEOC > 0, cValtoChar(B5X->B5X_ELNEOC), "")
        cNLNNCGE := iif(B5X->B5X_ELNNCG > 0, cValtoChar(B5X->B5X_ELNNCG), "")
        cNRLPEDE := iif(B5X->B5X_ERLPED > 0, cValtoChar(B5X->B5X_ERLPED), "")
        cNRLADUE := iif(B5X->B5X_ERLADU > 0, cValtoChar(B5X->B5X_ERLADU), "")
        cNLCOROE := iif(B5X->B5X_ELCORO > 0, cValtoChar(B5X->B5X_ELCORO), "")
        cNRUTIAE := iif(B5X->B5X_ERUTIA > 0, cValtoChar(B5X->B5X_ERUTIA), "")
        cNRUTINE := iif(B5X->B5X_ERUTIN > 0, cValtoChar(B5X->B5X_ERUTIN), "")
        cNRUTIPE := iif(B5X->B5X_ERUTIP > 0, cValtoChar(B5X->B5X_ERUTIP), "")
        cUTITP1E := iif(B5X->B5X_ETITP1 > 0, cValtoChar(B5X->B5X_ETITP1), "")
        cUTITP2E := iif(B5X->B5X_ETITP2 > 0, cValtoChar(B5X->B5X_ETITP2), "")
        cUTITP3E := iif(B5X->B5X_ETITP3 > 0, cValtoChar(B5X->B5X_ETITP3), "")
        cUTIPT1E := iif(B5X->B5X_ETIPT1 > 0, cValtoChar(B5X->B5X_ETIPT1), "")
        cUTIPT2E := iif(B5X->B5X_ETIPT2 > 0, cValtoChar(B5X->B5X_ETIPT2), "")
        cUTIPT3E := iif(B5X->B5X_ETIPT3 > 0, cValtoChar(B5X->B5X_ETIPT3), "")
        cUTINT1E := iif(B5X->B5X_ETINT1 > 0, cValtoChar(B5X->B5X_ETINT1), "")
        cUTINT2E := iif(B5X->B5X_ETINT2 > 0, cValtoChar(B5X->B5X_ETINT2), "")
        cUTINT3E := iif(B5X->B5X_ETINT3 > 0, cValtoChar(B5X->B5X_ETINT3), "")
        cUTIQUEE := iif(B5X->B5X_ETIQUE > 0, cValtoChar(B5X->B5X_ETIQUE), "")
        cUTICR2E := iif(B5X->B5X_ETICR2 > 0, cValtoChar(B5X->B5X_ETICR2), "")
        cNOBSPAE := iif(B5X->B5X_EOBSPA > 0, cValtoChar(B5X->B5X_EOBSPA), "")
        cNEMRPAE := iif(B5X->B5X_EEMRPA > 0, cValtoChar(B5X->B5X_EEMRPA), "")

        //Leitos Contratados
        cNRLPIS := iif(B5X->B5X_NRLPIS > 0, cValtoChar(B5X->B5X_NRLPIS), "")
        cNRLINT := iif(B5X->B5X_NRLINT > 0, cValtoChar(B5X->B5X_NRLINT), "")
        cNRLDIA := iif(B5X->B5X_NRLDIA > 0, cValtoChar(B5X->B5X_NRLDIA), "")
        cNRLBER := iif(B5X->B5X_NRLBER > 0, cValtoChar(B5X->B5X_NRLBER), "")
        cNRLIND := iif(B5X->B5X_NRLIND > 0, cValtoChar(B5X->B5X_NRLIND), "")
        cNRLCOL := iif(B5X->B5X_NRLCOL > 0, cValtoChar(B5X->B5X_NRLCOL), "")
        cNRLISO := iif(B5X->B5X_NRLISO > 0, cValtoChar(B5X->B5X_NRLISO), "")
        cNRLUCC := iif(B5X->B5X_NRLUCC > 0, cValtoChar(B5X->B5X_NRLUCC), "")
        cNRLSEM := iif(B5X->B5X_NRLSEM > 0, cValtoChar(B5X->B5X_NRLSEM), "")
        cNLNEOC := iif(B5X->B5X_NLNEOC > 0, cValtoChar(B5X->B5X_NLNEOC), "")
        cNLNNCG := iif(B5X->B5X_NLNNCG > 0, cValtoChar(B5X->B5X_NLNNCG), "")
        cNRLPED := iif(B5X->B5X_NRLPED > 0, cValtoChar(B5X->B5X_NRLPED), "")
        cNRLADU := iif(B5X->B5X_NRLADU > 0, cValtoChar(B5X->B5X_NRLADU), "")
        cNLCORO := iif(B5X->B5X_NLCORO > 0, cValtoChar(B5X->B5X_NLCORO), "")
        cNRUTIA := iif(B5X->B5X_NRUTIA > 0, cValtoChar(B5X->B5X_NRUTIA), "")
        cNRUTIN := iif(B5X->B5X_NRUTIN > 0, cValtoChar(B5X->B5X_NRUTIN), "")
        cNRUTIP := iif(B5X->B5X_NRUTIP > 0, cValtoChar(B5X->B5X_NRUTIP), "")
        cUTITP1 := iif(B5X->B5X_UTITP1 > 0, cValtoChar(B5X->B5X_UTITP1), "")
        cUTITP2 := iif(B5X->B5X_UTITP2 > 0, cValtoChar(B5X->B5X_UTITP2), "")
        cUTITP3 := iif(B5X->B5X_UTITP3 > 0, cValtoChar(B5X->B5X_UTITP3), "")
        cUTIPT1 := iif(B5X->B5X_UTIPT1 > 0, cValtoChar(B5X->B5X_UTIPT1), "")
        cUTIPT2 := iif(B5X->B5X_UTIPT2 > 0, cValtoChar(B5X->B5X_UTIPT2), "")
        cUTIPT3 := iif(B5X->B5X_UTIPT3 > 0, cValtoChar(B5X->B5X_UTIPT3), "")
        cUTINT1 := iif(B5X->B5X_UTINT1 > 0, cValtoChar(B5X->B5X_UTINT1), "")
        cUTINT2 := iif(B5X->B5X_UTINT2 > 0, cValtoChar(B5X->B5X_UTINT2), "")
        cUTINT3 := iif(B5X->B5X_UTINT3 > 0, cValtoChar(B5X->B5X_UTINT3), "")
        cUTIQUE := iif(B5X->B5X_UTIQUE > 0, cValtoChar(B5X->B5X_UTIQUE), "")
        cUTICR2 := iif(B5X->B5X_UTICR2 > 0, cValtoChar(B5X->B5X_UTICR2), "")
        cNOBSPA := iif(B5X->B5X_NOBSPA > 0, cValtoChar(B5X->B5X_NOBSPA), "")
        cNEMRPA := iif(B5X->B5X_NEMRPA > 0, cValtoChar(B5X->B5X_NEMRPA), "")
     
        oObj:MontaTag(3,'leitos_a410',nil,nil,.T.)

        oObj:MontaTag(4,'nr_leitos_psiquiat_exist',	     cNRLPISE)
        oObj:MontaTag(4,'nr_leitos_psiquiat_disp',	     cNRLPIS)
        oObj:MontaTag(4,'nr_leitos_intermed_neo_exist',	 cNRLINTE)
        oObj:MontaTag(4,'nr_leitos_intermed_neo_disp',	 cNRLINT)
        oObj:MontaTag(4,'nr_leitos_hosp_dia_exist'  ,	 cNRLDIAE)
        oObj:MontaTag(4,'nr_leitos_hosp_dia_disp'   ,    cNRLDIA)
        oObj:MontaTag(4,'nr_leitos_bercario_exist'  ,	 cNRLBERE)
        oObj:MontaTag(4,'nr_leitos_bercario_disp' ,	     cNRLBER)
        oObj:MontaTag(4,'nr_leitos_individual_exist',	 cNRLINDE)
        oObj:MontaTag(4,'nr_leitos_individual_disp',	 cNRLIND)
        oObj:MontaTag(4,'nr_leitos_coletivo_exist',	     cNRLCOLE)
        oObj:MontaTag(4,'nr_leitos_coletivo_disp',	     cNRLCOL)
        oObj:MontaTag(4,'nr_leitos_isolamento_exist',	 cNRLISOE)
        oObj:MontaTag(4,'nr_leitos_isolamento_disp',	 cNRLISO)
        oObj:MontaTag(4,'nr_leitos_ucc_exist',	         cNRLUCCE)
        oObj:MontaTag(4,'nr_leitos_ucc_disp',	         cNRLUCC)
        oObj:MontaTag(4,'nr_leitos_semi_exist',	         cNRLSEME)
        oObj:MontaTag(4,'nr_leitos_semi_disp',	         cNRLSEM)
        oObj:MontaTag(4,'nr_leitos_uci_neo_conv_exist',	 cNLNEOCE)
        oObj:MontaTag(4,'nr_leitos_uci_neo_conv_disp',	 cNLNEOC)
        oObj:MontaTag(4,'nr_leitos_uci_neo_cang_exist',	 cNLNNCGE)
        oObj:MontaTag(4,'nr_leitos_uci_neo_cang_disp',   cNLNNCG)
        oObj:MontaTag(4,'nr_leitos_uci_pediatrico_exist',cNRLPEDE)
        oObj:MontaTag(4,'nr_leitos_uci_pediatrico_disp', cNRLPED)
        oObj:MontaTag(4,'nr_leitos_uci_adulto_exist',	 cNRLADUE)
        oObj:MontaTag(4,'nr_leitos_uci_adulto_disp',	 cNRLADU)
        oObj:MontaTag(4,'nr_leitos_coronariana_exist',	 cNLCOROE)
        oObj:MontaTag(4,'nr_leitos_coronariana_disp',	 cNLCORO)
        oObj:MontaTag(4,'nr_uti_adulto_exist',	         cNRUTIAE)
        oObj:MontaTag(4,'nr_uti_adulto_disp',	         cNRUTIA)
        oObj:MontaTag(4,'nr_uti_neonatal_exist',         cNRUTINE)
        oObj:MontaTag(4,'nr_uti_neonatal_disp',	         cNRUTIN)
        oObj:MontaTag(4,'nr_uti_pediatria_exist',	     cNRUTIPE)
        oObj:MontaTag(4,'nr_uti_pediatria_disp',	     cNRUTIP)
        oObj:MontaTag(4,'nr_uti_adulto_tp_1_exist',	     cUTITP1E)
        oObj:MontaTag(4,'nr_uti_adulto_tp_1_disp',	     cUTITP1)
        oObj:MontaTag(4,'nr_uti_adulto_tp_2_exist',	     cUTITP2E)
        oObj:MontaTag(4,'nr_uti_adulto_tp_2_disp',	     cUTITP2)
        oObj:MontaTag(4,'nr_uti_adulto_tp_3_exist',	     cUTITP3E)
        oObj:MontaTag(4,'nr_uti_adulto_tp_3_disp',	     cUTITP3)
        oObj:MontaTag(4,'nr_uti_pediatrica_tp_1_exist',	 cUTIPT1E)
        oObj:MontaTag(4,'nr_uti_pediatrica_tp_1_disp',   cUTIPT1)
        oObj:MontaTag(4,'nr_uti_pediatrica_tp_2_exist',	 cUTIPT2E)
        oObj:MontaTag(4,'nr_uti_pediatrica_tp_2_disp',	 cUTIPT2)
        oObj:MontaTag(4,'nr_uti_pediatrica_tp_3_exist',	 cUTIPT3E)
        oObj:MontaTag(4,'nr_uti_pediatrica_tp_3_disp',	 cUTIPT3)
        oObj:MontaTag(4,'nr_uti_neonatal_tp_1_exist',	 cUTINT1E)
        oObj:MontaTag(4,'nr_uti_neonatal_tp_1_disp',	 cUTINT1)
        oObj:MontaTag(4,'nr_uti_neonatal_tp_2_exist',    cUTINT2E)
        oObj:MontaTag(4,'nr_uti_neonatal_tp_2_disp',	 cUTINT2)
        oObj:MontaTag(4,'nr_uti_neonatal_tp_3_exist',	 cUTINT3E)
        oObj:MontaTag(4,'nr_uti_neonatal_tp_3_disp',	 cUTINT3)
        oObj:MontaTag(4,'nr_uti_queimados_exist',	     cUTIQUEE)
        oObj:MontaTag(4,'nr_uti_queimados_disp',	     cUTIQUE)
        oObj:MontaTag(4,'nr_uti_coronariana_tp_2_exist', cUTICR2E)
        oObj:MontaTag(4,'nr_uti_coronariana_tp_2_disp',  cUTICR2)
        oObj:MontaTag(4,'nr_obs_pa_exist',	             cNOBSPAE)
        oObj:MontaTag(4,'nr_obs_pa_disp',                cNOBSPA)
        oObj:MontaTag(4,'nr_emerg_pa_exist',	         cNEMRPAE)
        oObj:MontaTag(4,'nr_emerg_pa_disp',	             cNEMRPA)

        oObj:MontaTag(3,'leitos_a410',nil,nil,nil,.T.)

    else
        oObj:AddCritica("Não foi encontrado o cadastro de leitos (tabela B5X) para o prestador "+TRBPRES->BAU_CODIGO)
    endIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} criEcoA410
Monta tag de criterios_economicos_a410

@author    renan.almeida
@version   1.xx
@since     06/09/2019
/*/
//------------------------------------------------------------------------------------------
Static Function criEcoA410(oObj)

    Local cTpNgDiaTx := ""
    Local cTpNgMatCo := ""
    Local cTpNgEquip := ""
    Local cTpNgOP    := ""
    Local cTxComerOP := ""
    Local cTpNgMatEs := ""
    Local cTxCmMatEs := ""
    Local cTpNgMed   := ""
    Local cTpNgDieta := ""
    Local cTpNgSadt  := ""
    Local cTpNgHM    := ""
    Local cAuxVal    := ""
    local cExcDiar   := ""
    Local nTotal     := 0

    B5X->(DbSetOrder(1))//B5X_FILIAL+B5X_CODRDA

    //Gera Tags criterios_economicos_a410
    if B5X->(DbSeek(xFilial("B5X")+Alltrim(TRBPRES->BAU_CODIGO))) 

        cTpNgDiaTx := B5X->B5X_NGDITX
        cExcDiar   := EncodeUTF8( fwcutoff(alltrim(substr(B5X->B5X_EXCDIA,1,1000)), .t.) )
        cTpNgMatCo := B5X->B5X_NGMTCS
        cTpNgEquip := B5X->B5X_NGEQUO
        cTpNgOP    := B5X->B5X_NGOPME
        
        cAuxVal    := cValtoChar(B5X->B5X_PCTXOP * 100)
        if cAuxVal == "0"
            cTxComerOP := ""
        else
            cTxComerOP := Substr(cAuxVal,1,len(cAuxVal)-2)+"."+Substr(cAuxVal,len(cAuxVal)-1,len(cAuxVal))
            cTxComerOP := iif(cTxComerOP == "100.00","100",cTxComerOP)
        endIf

        cTpNgMatEs := B5X->B5X_TPMTES
        
        cAuxVal    := cValtoChar(B5X->B5X_PCTXME * 100)
        if cAuxVal == "0"
            cTxCmMatEs := ""
        else
            cTxCmMatEs := Substr(cAuxVal,1,len(cAuxVal)-2)+"."+Substr(cAuxVal,len(cAuxVal)-1,len(cAuxVal))
            cTxCmMatEs := iif(cTxCmMatEs == "100.00","100",cTxCmMatEs)
        endIf      
        
        cTpNgMed   := B5X->B5X_NGMEDI
        cTpNgDieta := B5X->B5X_NGDIET
        cTpNgSadt  := B5X->B5X_NGSADT
        cTpNgHM    := B5X->B5X_NGHONM
        
        //Validacoes das tags

        oObj:MontaTag(3,'criterios_economicos_a410',nil,nil,.T.)

        oObj:MontaTag(4,'tp_negociacao_diarias_taxas'   , cTpNgDiaTx,.T.)
        oObj:MontaTag(4,'exec_diarias'                  , cExcDiar)
        oObj:MontaTag(4,'tp_negociacao_mat_consumo'     , cTpNgMatCo,.T.)
        oObj:MontaTag(4,'tp_negociacao_equipos'         , cTpNgEquip)
        oObj:MontaTag(4,'tp_negociacao_op'              , cTpNgOP)
        oObj:MontaTag(4,'tx_comercializacao_op'         , cTxComerOP)
        oObj:MontaTag(4,'tp_negociacao_mat_espec'       , cTpNgMatEs)
        oObj:MontaTag(4,'tx_comercializacao_mat_espec'  , cTxCmMatEs)
        oObj:MontaTag(4,'tp_negociacao_med'             , cTpNgMed,.T.)
        oObj:MontaTag(4,'tp_negociacao_dietas'          , cTpNgDieta)
        oObj:MontaTag(4,'tp_negociacao_sadt'            , cTpNgSadt)

        //-------------------------------------
        // excecao_prest_sadt - B5W 
        //-------------------------------------
        cSql := " SELECT B5W_CODSW2 FROM "+RetSqlName("B5W")+" B5W " 
        cSql += " WHERE B5W_FILIAL = '"+xFilial("B5W") +"' "
        cSql += " AND B5W_CODRDA = '"+Alltrim(TRBPRES->BAU_CODIGO)+"' "
        cSql += " AND B5W.D_E_L_E_T_ = ' ' "  
        dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBB5W",.F.,.T.)
        
        If !oObj:lAuto
            TRBB5W->( dbEval( { || nTotal++ } ) )
            TRBB5W->(DBGoTop())
            oProcess:SetRegua2(nTotal)
        ENDIF

        if !TRBB5W->(eof()) 
            nQtdReg := 0
            oObj:MontaTag(4,'excecao_prest_sadt',nil,nil,.T.)
            while !TRBB5W->(eof()) 

                nQtdReg ++

                // Regua para contagem <espMedHopEsp>
                If !oObj:lAuto
                    oProcess:IncRegua2("Registros para a tag <exc_prest_sadt> " + cValToChar(nQtdReg) + " de " +  cValToChar(nTotal)  )
                ENDIF

                if nQtdReg > 100
                    oObj:AddCritica("A quantidade máxima de registros para a tag <exc_prest_sadt> é 100.")
                endIf

                oObj:MontaTag(5,'exc_prest_sadt',cValtoChar(TRBB5W->B5W_CODSW2))  
                TRBB5W->(dbSkip())
            endDo
            oObj:MontaTag(4,'excecao_prest_sadt',nil,nil,nil,.T.)
        endIf    
        TRBB5W->(dbCloseArea())

        oObj:MontaTag(4,'tp_negociacao_hm',cTpNgHM,.T.)

        //-------------------------------------
        // excecao_prest_hm_espec - B5Y
        //-------------------------------------
        cSql := " SELECT B5Y_CODHME FROM "+RetSqlName("B5Y")+" B5Y " 
        cSql += " WHERE B5Y_FILIAL = '"+xFilial("B5Y") +"' "
        cSql += " AND B5Y_CODRDA = '"+Alltrim(TRBPRES->BAU_CODIGO)+"' "
        cSql += " AND B5Y.D_E_L_E_T_ = ' ' "  

        dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBB5Y",.F.,.T.)

        If !oObj:lAuto
            nTotal := 0
            TRBB5Y->( dbEval( { || nTotal++ } ) )
            TRBB5Y->(DBGoTop())
            oProcess:SetRegua2(nTotal)
        ENDIF

        if !TRBB5Y->(eof()) 
            nQtdReg := 0
            oObj:MontaTag(4,'excecao_prest_hm_espec',nil,nil,.T.)
            while !TRBB5Y->(eof()) 

                nQtdReg ++

                // Regua para contagem <espMedHopEsp>
                if !oObj:lAuto
                    oProcess:IncRegua2("Registros para a tag <exc_prest_hm_espec>  " + cValToChar(nQtdReg) + " de " +  cValToChar(nTotal)  )
                ENDIF

                if nQtdReg > 100
                    oObj:AddCritica("A quantidade máxima de registros para a tag <exc_prest_hm_espec> é 100.")
                endIf

                oObj:MontaTag(5,'exc_prest_hm_espec',cValtoChar(TRBB5Y->B5Y_CODHME))
                TRBB5Y->(dbSkip())
            endDo
            oObj:MontaTag(4,'excecao_prest_hm_espec',nil,nil,nil,.T.)
        endIf    
        TRBB5Y->(dbCloseArea())

        //-------------------------------------
        // excecao_prest_hm_area_atua - B5Z
        //-------------------------------------
        cSql := " SELECT B5Z_CODHMA FROM "+RetSqlName("B5Z")+" B5Z " 
        cSql += " WHERE B5Z_FILIAL = '"+xFilial("B5Z") +"' "
        cSql += " AND B5Z_CODRDA = '"+Alltrim(TRBPRES->BAU_CODIGO)+"' "
        cSql += " AND B5Z.D_E_L_E_T_ = ' ' "  

        dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBB5Z",.F.,.T.)

        If !oObj:lAuto
            nTotal := 0
            TRBB5Z->( dbEval( { || nTotal++ } ) )
            TRBB5Z->(DBGoTop())
            oProcess:SetRegua2(nTotal)
        ENDIF

        if !TRBB5Z->(eof()) 
            nQtdReg := 0
            oObj:MontaTag(4,'excecao_prest_hm_area_atua',nil,nil,.T.)
            while !TRBB5Z->(eof()) 
                
                nQtdReg ++

                // Regua para contagem <espMedHopEsp>
                If !oObj:lAuto
                  oProcess:IncRegua2("Registros para a tag <exc_prest_hm_area_atua> " + cValToChar(nQtdReg) + " de " +  cValToChar(nTotal)  )
                ENDIF

                if nQtdReg > 100
                    oObj:AddCritica("A quantidade máxima de registros para a tag <exc_prest_hm_area_atua> é 100.")
                endIf

                oObj:MontaTag(5,'exc_prest_hm_area_atua',cValtoChar(TRBB5Z->B5Z_CODHMA))     
                TRBB5Z->(dbSkip())
            endDo
            oObj:MontaTag(4,'excecao_prest_hm_area_atua',nil,nil,nil,.T.)
        endIf    
        TRBB5Z->(dbCloseArea())

        //Finaliza estrutura
        oObj:MontaTag(3,'criterios_economicos_a410',nil,nil,nil,.T.)
    endIf
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} diaTax410
Monta tag de diarias_taxas_a410

@author    renan.almeida
@version   1.xx
@since     06/09/2019
/*/
//------------------------------------------------------------------------------------------
Static Function diaTax410(oObj,__aRet,aDadRda)
    
    Local cAuxVal   := ""
    Local cCd_dth   := ""
    Local cVl_dth   := ""
    Local cSql      := ""
    Local cCodTISS  := ""
    local cMes      := ""
    local cAno      := ""
    local aValor    := {}
    local aPdeReal  := {}
    Local nTotal    := 0
    Local cCodLoc   := "001"
    Local cCodEsp   := ' '
    Local nAtual    := 0
    local cCodOpe   := PlsIntPad()
    Local lPLPT410B := ExistBlock("PLPT410B")
    Local lPLPT410A := ExistBlock("PLPT410A")
    Local aDadUsr   := PlsIntDad(__aRet)
    local nCount    := 0
    local cCodPro   := ""

    cMes := SubStr(DtoS(dDatabase), 5, 2)
    cAno := SubStr(DtoS(dDatabase), 1, 4)

	
	//Todos os procedimentos da tabela padrão, que estejam ativos e com tpproc igual diárias(4) e taxas(3)
    cSql := " SELECT BR8_CODPAD CODPAD, BR8_CODPSA CODOPC FROM " + RetSqlname("BR8")
    cSql += " WHERE BR8_FILIAL = '" + xfilial("BR8") + "' "
    cSql += " AND BR8_BENUTL = '1' "
    cSql += " AND BR8_TPPROC IN ('3','4') "
    cSql += " AND D_E_L_E_T_ = ' ' "

	BAU->(dbSetOrder(1))
	If BAU->BAU_CODIGO <> TRBPRES->BAU_CODIGO
		BAU->(MsSeek(xfilial("BAU") + TRBPRES->BAU_CODIGO))
	endIf

    if lPLPT410A
        cSql := ExecBlock("PLPT410A", .F., .F., {cSql})
    endIf
    
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBC0",.F.,.T.)

    If !oObj:lAuto
        TRBBC0->( dbEval( { || nTotal++ } ) )
        TRBBC0->(DBGoTop())
        oProcess:SetRegua2(nTotal)
    ENDIF

    //Gera Tags diarias_taxas_a410
    if TRBBC0->(eof())
        oObj:AddCritica("Não foram encontradas Diárias/Taxas para o prestador " + TRBPRES->BAU_CODIGO + ".")
    else
        while !TRBBC0->(eof())
         
            nAtual++

            // Regua para contagem <espMedHopEsp>
            If !oObj:lAuto
                oProcess:IncRegua2("Verificando Diárias/Taxas " + cValToChar(nAtual) + " de " +  cValToChar(nTotal)  )
            ENDIF

            aValor   := {}
            aPdeReal := {.f., ''}

            //Verifica se o procedimento pode ser realizado pela RDA
            aPdeReal := PLSTratExe(Alltrim(TRBBC0->CODPAD), allTrim(TRBBC0->CODOPC), .t., .t., .f., "2", "",{}, aDadRDA, aDadUsr,, dDatabase,,,,,,,,,)
            
            If !aPdeReal[1] 
                cCodPro := Alltrim(TRBBC0->CODOPC)  
	        	TRBBC0->(dbSkip())
	        	loop
	        endIf


            if len(aDadRDA) > 0	
				cCodLoc := aDadRDA[12]
                cCodEsp := aDadRDA[15]                
            endif

            if len(aPdeReal) > 2
                If aPdeReal[3] $ "BC0,BBI,BE9,BAX,BAU,BBN"
                    cCodLoc := substr(aPdeReal[4],11,3)
                    cCodEsp := substr(aPdeReal[4],14,3)
                elseif aPdeReal[3] $ "BBM
                    cCodEsp := substr(aPdeReal[4],5,3)
                endif
            endIf            

            aValor := PLSCALCEVE( Alltrim(TRBBC0->CODPAD), allTrim(TRBBC0->CODOPC),cMes,cAno,cCodOpe,TRBPRES->BAU_CODIGO,cCodEsp ,/*cSubEsp*/,cCodLoc, 1 /*nQtd*/,dDatabase,IIF(len(aDadUsr)>=48,aDadUsr[48],""),;
                                  "","",/*nValApr*/,aDadUsr,"",nil,"","",nil,nil,/*cHorario*/,{},.F.,"",0,{},.F.,dDatabase,/*cHorario*/,{},/*cTipGui*/ )
                
	        If aValor[2] <= 0
	        	TRBBC0->(dbSkip())
	        	loop
	        endIf

            cCodTISS := Alltrim(PLSGETVINC("BTU_CDTERM", "BR8",.F., TRBBC0->CODPAD,TRBBC0->CODOPC))
            cCd_dth  := iif(Empty(cCodTISS),Alltrim(TRBBC0->CODOPC),cCodTISS)
            
            cAuxVal := cValtoChar(aValor[2] * 100)
            cVl_dth := Substr(cAuxVal,1,len(cAuxVal)-2)+"."+Substr(cAuxVal,len(cAuxVal)-1,len(cAuxVal))

            if lPLPT410B
                aRetPE := ExecBlock("PLPT410B", .F., .F.,{Alltrim(TRBBC0->CODPAD),Alltrim(TRBBC0->CODOPC),cCd_dth,cVl_dth})
                if len(aRetPE) > 0 
                    cCd_dth  := aRetPE[1]
                    cVl_dth  := aRetPE[2]
                endIf
            endIf

            //Valida tags
            if cVl_dth == "0"
                oObj:AddCritica("O valor do evento é obrigatório. Prestador: "+Alltrim(TRBPRES->BAU_CODIGO) + ", Evento:" + cCd_dth)
            endIf

            oObj:MontaTag(3,'diarias_taxas_a410',nil,nil,.T.)

            oObj:MontaTag(4,'cd_dth', cCd_dth,.T.)
            oObj:MontaTag(4,'vl_dth', cVl_dth,.T.)

            oObj:MontaTag(3,'diarias_taxas_a410',nil,nil,nil,.T.)
            nCount++
            TRBBC0->(dbSkip())
        endDo
    endIf

     if(nCount == 0)
        oObj:AddCritica("Procedimento não autorizado para o Prestador: "+Alltrim(TRBPRES->BAU_CODIGO) + ", Procedimento: " + cCodPro)
    endif 
  
    TRBBC0->(dbCloseArea())

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} QryServ410
Query dos Serviços do PTU A410.
Parâmetros: "1" - Serviços (hospital /Especialidade) / "2" - SADT. Default "1"

@version   1.00
@since     12/2019
/*/
//------------------------------------------------------------------------------------------
static function QryServ410(cTpServ)
local cSql      := ""
default cTpServ := "1"

cSql := " SELECT * FROM " + RetSqlName("B5L") + " B5L " 
cSql += " INNER JOIN " +RetSqlName("B5V") + " B5V " 
cSql += " ON B5V_FILIAL = '" + xFilial("B5V") + "' "
cSql += "   AND B5V_CODIGO = B5L_CODSW2 "
cSql += " 	AND B5V.D_E_L_E_T_ = ' ' "  
cSql += " WHERE B5L_FILIAL = '" + xFilial("B5L") + "' "
cSql += "   AND B5L_CODRDA = '" + Alltrim(TRBPRES->BAU_CODIGO) + "' "
cSql += "   AND B5L_TPNOXM = '" + cTpServ + "' "
cSql += "   AND B5L.D_E_L_E_T_ = ' ' "  

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBSERV",.F.,.T.)

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlsIntDad
Retorna 
Parâmetros:  __aRet conteudo do pergunte

@version   1.00
@since     12/2019
/*/
//------------------------------------------------------------------------------------------
static function PlsIntDad(__aRet)
local cSql      := " "
local cCodOpe   := PlsIntPad()
Local cCodEmp   := Getnewpar("MV_PLSGEIN", "0050")
Local aRet      := {}
Local cMatricUsr:= ' '
Local cOracle   := ' '
Local cSqlTop   := ' '
Local lOracle   := substr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE" 

if lOracle
    cOracle := " AND ROWNUM = 1 "
else
    cSqlTop := " TOP(1) "
endif

cSql := " SELECT " + cSqlTop+ " BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO FROM " + RetSqlName("BA1") + " BA1 " 
cSql += " INNER JOIN " +RetSqlName("BA3") + " BA3 " 
cSql += "   ON BA3.BA3_FILIAL  = '" + xFilial("BA3") + "' "
cSql += "   AND BA3.BA3_CODINT = '" + cCodOpe   + "'"
cSql += "   AND BA3.BA3_CODEMP = '" + cCodEmp   + "'"
cSql += "   AND BA3.BA3_CODPLA = '" + __aRet[5] + "'"
cSql += "   AND BA3.BA3_VERSAO = '" + __aRet[6] + "'"
cSql += "   AND BA3.BA3_DATBLO = ' '"
cSql += " 	AND BA3.D_E_L_E_T_ = ' ' "  
cSql += " WHERE BA1_FILIAL = '" + xFilial("BA1") + "' "
cSql += "   AND BA1.BA1_CODINT = BA3.BA3_CODINT "
cSql += "   AND BA1.BA1_CODEMP = BA3.BA3_CODEMP "
cSql += "   AND BA1.BA1_CONEMP = BA3.BA3_CONEMP "
cSql += "   AND BA1.BA1_VERCON = BA3.BA3_VERCON "
cSql += "   AND BA1.BA1_SUBCON = BA3.BA3_SUBCON "
cSql += "   AND BA1.BA1_VERSUB = BA3.BA3_VERSUB "
cSql += "   AND BA1.BA1_MATRIC = BA3.BA3_MATRIC " 
cSql += "   AND BA1.BA1_DATBLO = ' '"
cSql += "   AND (BA1.BA1_CODPLA = BA3.BA3_CODPLA "
cSql += "   OR BA1.BA1_CODPLA = ' ') "
cSql += "   AND (BA1.BA1_VERSAO = BA3.BA3_VERSAO "
cSql += "   OR BA1.BA1_VERSAO = ' ') "
cSql += "   AND BA1.D_E_L_E_T_ = ' ' "  
cSql += cOracle

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBUSR",.F.,.T.)

//Pegar um usuário "genérico" de intercâmbio
If !TRBUSR->(Eof()) 
    cMatricUsr := TRBUSR->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO)
Endif

aRet :=   PLSDADUSR(cMatricUsr, "1", .f., ddatabase, , , nil, nil)
TRBUSR->(dbCloseArea())

Return (aRet)
