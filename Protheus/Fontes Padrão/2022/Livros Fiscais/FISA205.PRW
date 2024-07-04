#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISA205.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA205

Função para geração do arquivo para a prefeitura de Araucária de 
serviços prestados/tomados.

@author Eduardo Vicente da Silva
@since 28/03/2019

/*/
//-------------------------------------------------------------------
Function FISA205() 

Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)
Private lAutomato   := IiF(IsBlind(),.T.,.F.)
       
If lVerpesssen
    If !lAutomato
        If Pergunte('FISA205',.T.,STR0001)  //"Parâmetros de geração do arquivo"
                        
            FwMsgRun(,{|oSay| ProcArq(oSay) },STR0002,"")	  //"Processando do arquivo"
                    
        EndIf
    Else
        ProcArq()
    EndIf
EndIf 
    
Return

/*/{Protheus.doc} ProcArq

Rotina que chama as funções de cada registro

@author Eduardo Vicente da Silva
@since 28/03/2019

/*/
//-------------------------------------------------------------------
Static Function ProcArq(oSay)
    
Local cAlias        := GetNextAlias()
Local nHandle       := 0 
Local lHtml         := .F.
Local cArquivo      := ""
Local cMvSimples    := SuperGetMV('MV_SIMPLES')
Local dDataEmisDe   := MV_PAR01
Local dDataEmisAte  := MV_PAR02
Local cNFiscalDe    := MV_PAR03
Local cNFiscaAte    := MV_PAR04
Local cSerieDe      := MV_PAR05
Local cSerieAte     := MV_PAR06
Local cProdDe       := MV_PAR07
Local cProdAte      := MV_PAR08
Local cCodSerDe     := MV_PAR09
Local cCodSerAte    := MV_PAR10
Local cDiretorio    := AllTrim(MV_PAR11)
Local cNomeArq      := AllTrim(MV_PAR12)
Local nGeraMovto    := MV_PAR13
Local cWhere        := ""
Local cLib
Local nRetType      := 0
Local cCodISS       := ""

CDN->(DbSetOrder(1))

nRetType := GetRemoteType(@cLib)

If nRetType == 5 //"HTML" $ cLib
    lHtml := .T.
EndIf

AtualizaMsg( oSay, STR0003 )  //"Selecionando os registros"

If nGeraMovto == 1
    cWhere := "SFT.FT_TIPOMOV = 'E'"
ElseIf nGeraMovto == 2
    cWhere := "SFT.FT_TIPOMOV = 'S'"
Else 
    cWhere := "SFT.FT_TIPOMOV IN('E','S')"
EndIf

cWhere := "%" + cWhere + "%"

BeginSql Alias cAlias

    COLUMN FT_EMISSAO AS DATE
    COLUMN FT_DTCANC  AS DATE

    SELECT  SFT.FT_TIPOMOV,
            SFT.FT_ESPECIE,
            SFT.FT_NFISCAL,
            SFT.FT_EMISSAO,
            SFT.FT_ALIQICM,
            SFT.FT_BASEICM,
            SFT.FT_ICMSRET,
            SFT.FT_VALCONT,
            SFT.FT_DTCANC,
            SFT.FT_OBSERV,
            SFT.FT_CONTA,
            SFT.FT_ITEM,
            SFT.FT_PRODUTO,
            SFT.FT_CODISS,

            SB1.B1_MEPLES,

            CT1.CT1_DESC01,
            CT1.CT1_RES,

            SF4.F4_CSTISS, 
            SF4.F4_ISS, 
            SF4.F4_LFISS, 
            SF4.F4_ISSST,
            
            ISNULL(SA1.A1_PESSOA, SA2.A2_TIPO) TIPO,
            ISNULL(SA1.A1_NOME, SA2.A2_NOME) NOME,
            ISNULL(SA1.A1_CGC, SA2.A2_CGC) CNPJ,
            ISNULL(SA1.A1_CGC, SA2.A2_CGC) CNPJ,
            ISNULL(SA1.A1_END, SA2.A2_END) ENDERECO,
            ISNULL(SA1.A1_COMPLEM, SA2.A2_COMPLEM) COMPLEMENTO,
            ISNULL(SA1.A1_BAIRRO, SA2.A2_BAIRRO) BAIRRO,
            ISNULL(SA1.A1_MUN, SA2.A2_MUN) MUNICIPIO,
            ISNULL(SA1.A1_EST, SA2.A2_EST) ESTADO,
            ISNULL(SA1.A1_CEP, SA2.A2_CEP) CEP,
            ISNULL(SA1.A1_TEL, SA2.A2_TEL) TELEFONE,
            ISNULL(SA1.A1_FAX, SA2.A2_FAX) FAX,
            ISNULL(SA1.A1_COD_MUN, SA2.A2_COD_MUN) CODMUN,
            SA1.A1_TIPO,
            SA2.A2_SIMPNAC,
            ISNULL(D1_ABATISS, 0) D1_ABATISS,
            ISNULL(D2_ABATISS, 0) D2_ABATISS

    FROM 	%TABLE:SFT% SFT
    INNER JOIN %TABLE:SF4% SF4 ON(SF4.F4_FILIAL = %xFilial:SF4% AND SF4.F4_CODIGO = SFT.FT_TES AND SF4.%NOTDEL%)
    INNER JOIN %TABLE:SB1% SB1 ON(SB1.B1_FILIAL = %xFilial:SB1% AND SB1.B1_COD = SFT.FT_PRODUTO AND SB1.%NOTDEL%)
    LEFT JOIN %TABLE:SA1% SA1 ON(SA1.A1_FILIAL = %xFilial:SA1% AND SA1.A1_COD = SFT.FT_CLIEFOR AND SA1.A1_LOJA = SFT.FT_LOJA AND SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO NOT IN ('D','B') AND SA1.%NOTDEL%)
    LEFT JOIN %table:SD2% SD2 ON(SD2.D2_FILIAL  = %xFilial:SD2% AND SD2.D2_DOC = SFT.FT_NFISCAL AND SD2.D2_SERIE = SFT.FT_SERIE AND SD2.D2_CLIENTE = SFT.FT_CLIEFOR AND SD2.D2_LOJA = SFT.FT_LOJA AND SD2.D2_COD = SFT.FT_PRODUTO AND SD2.D2_ITEM = SFT.FT_ITEM AND SD2.%NotDel%)
    LEFT JOIN %TABLE:SA2% SA2 ON(SA2.A2_FILIAL = %xFilial:SA2% AND SA2.A2_COD = SFT.FT_CLIEFOR AND SA2.A2_LOJA = SFT.FT_LOJA AND SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') AND SA2.%NOTDEL%)
    LEFT JOIN %table:SD1% SD1 ON(SD1.D1_FILIAL  = %xFilial:SD1% AND SD1.D1_DOC = SFT.FT_NFISCAL AND SD1.D1_SERIE = SFT.FT_SERIE AND SD1.D1_FORNECE = SFT.FT_CLIEFOR AND SD1.D1_LOJA = SFT.FT_LOJA AND SD1.D1_COD = SFT.FT_PRODUTO AND SD1.D1_ITEM = SFT.FT_ITEM AND SD1.%NotDel%)
    LEFT JOIN %TABLE:CT1% CT1 ON(CT1.CT1_FILIAL = %xFilial:CT1% AND CT1.CT1_CONTA = SFT.FT_CONTA AND CT1.%NOTDEL%)

    WHERE   SFT.FT_FILIAL=%XFILIAL:SFT%
    AND     SFT.FT_EMISSAO BETWEEN %EXP:dDataEmisDe% AND %EXP:dDataEmisAte%
    AND     SFT.FT_NFISCAL BETWEEN %EXP:cNFiscalDe% AND %EXP:cNFiscaAte%
    AND     SFT.FT_SERIE   BETWEEN %EXP:cSerieDe% AND %EXP:cSerieAte%
    AND     SFT.FT_PRODUTO BETWEEN %EXP:cProdDe% AND %EXP:cProdAte%
    AND     SFT.FT_TIPO    = 'S'  
    AND     SFT.FT_CODISS <> ' ' 
    AND     %Exp:cWhere%
    AND     SFT.%NOTDEL%

EndSql

DbSelectArea(cAlias)

AtualizaMsg( oSay, STR0004 )  //"Gerando arquivo texto"

//Cria o arquivo texto para gravação dos registros.
CriaArq(lHtml, @nHandle, @cArquivo, cDiretorio, cNomeArq)

While !(cAlias)->(Eof())
    cCodISS := ""
    
    If CDN->(DbSeek( xFilial("CDN") + (cAlias)->FT_CODISS + (cAlias)->FT_PRODUTO ))
        cCodIss := CDN->CDN_CODLST
    Elseif CDN->(DbSeek( xFilial("CDN") + (cAlias)->FT_CODISS ) )
        cCodIss := CDN->CDN_CODLST
    EndIf

    If Empty(AllTrim( cCodISS ))
        (cAlias)->(dbSkip())
        Loop
    EndIf
    
    If  !(cCodIss >=  cCodSerDe .And.  cCodIss <= cCodSerAte)
        (cAlias)->(dbSkip())
        Loop
    EndIf


    GeraLinha(nHandle, cAlias, cMvSimples, cCodIss)

    (cAlias)->(dbSkip())

EndDo

(cAlias)->(dbCloseArea())

AtualizaMsg( oSay, STR0005 )  //"Processamento Concluído"

//Fecha o arquivo gerado.
FechaArq(lHtml, nHandle, cArquivo)

If !lAutomato
    Alert(STR0005) //"Processamento Concluído"
EndIf

Return
						
/*/{Protheus.doc} CriaArq

Rotina para criar o arquivo texto.

@author Eduardo Vicente da Silva
@since 28/03/2019

/*/
//-------------------------------------------------------------------
Static Function CriaArq(lHtml, nHandle, cArquivo, cDiretorio, cNomeArq)

If Substr(cDiretorio,Len(cDiretorio), 1) != "\"
	cDiretorio += "\"
EndIf

If lHtml
    cDirDest := GetSrvProfString("startpath","")
Else
    cDirDest := cDiretorio
EndIf
 
cArquivo := cDirDest+cNomeArq

nHandle := fCreate(cArquivo)

If nHandle = -1 .And. !lAutomato
    Alert(STR0006 + Str(Ferror())) //'Erro ao criar arquivo:'
EndIf

Return

/*/{Protheus.doc} FechaArq

Rotina para fechar o arquivo texto.

@author Eduardo Vicente da Silva
@since 28/03/2019

/*/
//-------------------------------------------------------------------
Static Function FechaArq(lHtml, nHandle, cArquivo)
nRet := 0

FClose(nHandle)

If lHtml
    nRet := CPYS2TW(cArquivo,.T.)

    If nRet == 0
        FErase (cArquivo)
    EndIf
EndIf
 
Return

/*/{Protheus.doc} GeraLinha

Rotina para gerar as linhas do arquivo texto.

@author Eduardo Vicente da Silva
@since 28/03/2019

/*/
//-------------------------------------------------------------------
Static Function GeraLinha(nHandle, cAlias, cMvSimples,cCodISS)
Local cLinha        := ""
Local cQuebra       := CHR(13)+CHR(10)
Local cReg10        := ""
Local cReg20        := ""
Local cReg30        := ""
Local cReg40        := ""
Local cTipoDoc      := Iif((cAlias)->FT_TIPOMOV == 'S', '01', '07') 
Local cTipoServ     := Iif((cAlias)->FT_TIPOMOV == 'S', '1', '2') // 1 - Saída; 2 - Entrada
Local cNumDoc       := PadL(AllTrim((cAlias)->FT_NFISCAL),15,'0') 
Local dDataEmis     := DtoC((cAlias)->FT_EMISSAO)
Local cPeriodo      := Substr(dDataEmis,4,2) + '/' + Substr(dDataEmis,7,4)
Local cTipoPrest    := ""
Local cCnpjPrest    := ""
Local cTipoTomad    := ""
Local cCnpjTomad    := ""
Local nValorContab  := PadL(Alltrim(Transform((cAlias)->FT_VALCONT * 100, '@E 9999999999999999,99')), 18, '0')
Local cSitDoc       := Iif(Empty((cAlias)->FT_DTCANC),"E","C") //E - Emitido, C - Cancelado
Local cObserv       := PadR((cAlias)->FT_OBSERV, 100, '')
Local cSimpNac      := ""
Local cCodIss116    := PadL(AllTrim(cCodISS), 7, '0')
Local nAlqIss       := PadL(Alltrim(Transform((cAlias)->FT_ALIQICM * 100, '@E 999999,99')), 6, '0')
Local nBaseIss      := PadL(Alltrim(Transform((cAlias)->FT_BASEICM * 100, '@E 9999999999999999,99')), 18, '0')
Local nIssAbat      := Iif((cAlias)->D1_ABATISS > 0, (cAlias)->D1_ABATISS, (cAlias)->D2_ABATISS)
Local nDeducao      := PadL(Alltrim(Transform(nIssAbat * 100, '@E 9999999999999999,99')), 18, '0') 
Local nIssRet       := PadL(Alltrim(Transform((cAlias)->FT_ICMSRET*100, '@E 9999999999999999,99')), 18, '0')
Local cCstIss       := PadL(AllTrim((cAlias)->F4_CSTISS),2,'0')
Local cIssTrib      := Iif((cAlias)->F4_LFISS == '1', 'S','N')
Local nIssRedObra   := StrZero(0, 10) 
Local cTipo         := (cAlias)->TIPO
Local cCnpj         := PadL(AllTrim((cAlias)->CNPJ),14,'0')
Local cNome         := SubStr((cAlias)->NOME, 1, 40)
Local cEndereco     := SubStr((cAlias)->ENDERECO, 1, 40)
Local cNumEnd       := AllTrim(Substr((cAlias)->ENDERECO, At(",",(cAlias)->ENDERECO)+1, Len(AllTrim((cAlias)->ENDERECO))))
Local nNumEnd       := Iif(Empty(cNumEnd),"00000000",PadL(cNumEnd,6,'0'))
Local cCompEnd      := PadR((cAlias)->COMPLEMENTO, 20, '') 
Local cBairro       := PadR((cAlias)->BAIRRO, 20,'')
Local cMunicipio    := PadR((cAlias)->MUNICIPIO, 30,'')  
Local cEstado       := PadR((cAlias)->ESTADO, 2,'') 
Local cCodMun       := ""
Local cCEP          := PadL(AllTrim((cAlias)->CEP), 8,'0') 
Local cTelefone     := PadR((cAlias)->TELEFONE, 12,'') 
Local cFax          := PadR((cAlias)->FAX, 12,'') 
Local cContaContab  := PadR((cAlias)->FT_CONTA, 50,'')
Local cDescConta    := PadR((cAlias)->CT1_DESC01, 100,'') 
Local cContaSint    := PadR((cAlias)->CT1_RES, 50,'') 
Local cItem         := PadL(AllTrim((cAlias)->FT_ITEM),7,'0')
Local cCosif        := Space(50) 

//Saída
If cTipoServ == "1"
    cTipoTomad  := Iif((cAlias)->A1_TIPO != "X", (cAlias)->TIPO, "F")
    cCnpjTomad  := Iif((cAlias)->A1_TIPO != "X", (cAlias)->CNPJ, Replicate("",14))

    cTipoPrest  := Iif(SM0->M0_TPINSC == 2, "J", "F")
    cCnpjPrest  := SM0->M0_CGC
    cSimpNac    := Iif(Empty(AllTrim(cMvSimples)), "N", cMvSimples)

    //Local de prestação do serviço 
    If (cAlias)->B1_MEPLES == "1" //EP - Estabelcimento do Prestador.
        cCodMun := Iif(Upper(SM0->M0_ESTENT) == "EX","",Iif(Len(Alltrim(SM0->M0_CODMUN))<=5,UfCodIBGE(SM0->M0_ESTENT),"")+SM0->M0_CODMUN)
    ElseIf (cAlias)->B1_MEPLES == "2" //LES - Local de Execução do Serviço. 
        cCodMun := PadL(UfCodIBGE(cEstado)+AllTrim((cAlias)->CODMUN),7,'0')
    EndIf

//Entrada
Else
    cTipoTomad  := Iif(SM0->M0_TPINSC == 2, "J", "F")
    cCnpjTomad  := SM0->M0_CGC

    cTipoPrest  := (cAlias)->TIPO
    cCnpjPrest  := (cAlias)->CNPJ
    cSimpNac    := Iif((cAlias)->A2_SIMPNAC == "1", "S", "N")

    //Local de prestação do serviço 
    If (cAlias)->B1_MEPLES == "1" //EP - Estabelcimento do Prestador.
        cCodMun := PadL(UfCodIBGE(cEstado)+AllTrim((cAlias)->CODMUN),7,'0')
    ElseIf (cAlias)->B1_MEPLES == "2" //LES - Local de Execução do Serviço. 
        cCodMun := Iif(Upper(SM0->M0_ESTENT) == "EX","",Iif(Len(Alltrim(SM0->M0_CODMUN))<=5,UfCodIBGE(SM0->M0_ESTENT),"")+SM0->M0_CODMUN)
    EndIf

EndIf

//Registro 10 - Identificação do Documento Fiscal 
cReg10 :=   "10;"           +;
            cTipoServ       +';'+;
            cTipoDoc        +';'+;
            cNumDoc         +';'+;
            cPeriodo        +';'+;
            cTipoPrest      +';'+;
            cCnpjPrest      +';'+;
            cTipoTomad      +';'+;
            cCnpjTomad      +';'+;
            dDataEmis       +';'+;
            nValorContab    +';'+;
            cSitDoc         +';'+;
            cObserv         +';'+;
            cSimpNac        +';'

//Registro 20 – Identificação dos serviços relacionados ao Documentos Fiscal
cReg20 :=   "20;"           +;
            cTipoServ       +';'+;
            cTipoDoc        +';'+;
            cNumDoc         +';'+;
            cPeriodo        +';'+;
            cTipoPrest      +';'+;
            cCnpjPrest      +';'+;
            cTipoTomad      +';'+;
            cCnpjTomad      +';'+;
            cCodIss116      +';'+;
            nAlqIss         +';'+;
            nBaseIss        +';'+;
            nDeducao        +';'+;
            nIssRet         +';'+;
            cCodMun         +';'+;
            cCstIss         +';'+;
            cIssTrib        +';'+;
            nIssRedObra     +';'

//Registro 30 – Identificação da pessoa relacionada ao Documento Fiscal
cReg30 :=   "30;"           +;
            cTipo           +';'+;
            cCnpj           +';'+;
            cNome           +';'+;
            cEndereco       +';'+;
            nNumEnd         +';'+;
            cCompEnd        +';'+;
            cBairro         +';'+;
            cMunicipio      +';'+;
            cEstado         +';'+; 
            cCEP            +';'+;
            cTelefone       +';'+;
            cFax            +';'

cLinha := cReg10 + cQuebra + cReg20 + cQuebra + cReg30 + cQuebra

//Registro 40 – Informações sobre o plano de contas da empresa
If !Empty(AllTrim(cContaContab))
    cReg40 :=   "40;"           +;
                cPeriodo        +';'+;
                cTipo           +';'+;
                cCnpj           +';'+;
                cContaContab    +';'+;
                cDescConta      +';'+;
                cContaSint      +';'+;
                cItem           +';'+;
                cCosif          +';'+;
                nValorContab    +';'

    cLinha := cLinha + cReg40 + cQuebra
EndIf

FWrite(nHAndle,cLinha)

Return

/*/{Protheus.doc} AtualizaMsg

Rotina para atualizar as mensagens durante o processamento.

@author Eduardo Vicente da Silva
@since 01/04/2019

/*/
//-------------------------------------------------------------------
Static Function AtualizaMsg(oSay,cMsg)
    If !lAutomato
        oSay:cCaption := (cMsg)
        ProcessMessages()
    EndIf
Return
