#INCLUDE "PROTHEUS.CH"
#INCLUDE "TRYEXCEPTION.CH"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "ArrayfunC.CH"
#INCLUDE "RMIXFUNC.CH"

Static aWsdl        := {}		 // Carrega os objetos TWsdlManager ja utilizados para performance

//--------------------------------------------------------
/*/{Protheus.doc} GetImpPrd
Função para retorna conforme parametro usando MATXFIS

@param 		aItens     -> Array com produtos e Filiais a serem consultados (Obrigatorio)
@param 		aCampos    -> Array de campos retorno da MATXFIS exemplo: "IT_VALICM" ou "NF_" (Obrigatorio)
@param 		cCliente   -> Codigo do cliente (opcional)
@param 		cLojaCli   -> Loja do Cliente (opcional)
@author  	Varejo
@version 	1.0
@since      23/07/2020
@return	    aRet    -> Retorna com a informação
/*/
//--------------------------------------------------------
Function GetImpPrd(aItens,aCampos,cCliente,cLojaCli)
Local aArea 	:= GetArea()
Local nInd,nY   := 0
Local nTotItens := 0
Local aRet      := {}
Local nPreco    := 0
Local cTesProd  := ""
Local cFilbkp   := cFilAnt
Local xCampo1   := 0
Local nItem     := 0

Default cCliente:= GetMv( "MV_CLIPAD" )		// Cliente padrao 
Default cLojaCli:= GetMv( "MV_LOJAPAD" )   // Loja padrao
Default aItens  := {}
Default aCampos := {}


SB1->(DbSetOrder(1))
nTotItens 	:= Len(aItens)
If Len(aItens) > 0 .AND. Len(aItens[1]) > 1 .AND. Len(aCampos) > 0
    MaFisIni(cCliente ,cLojaCli	, "C"	,"S"	,;
                                'F'	,NIL		, NIL	,.F.	,;
                                "SB1"		,"LOJA701", "01"	,NIL	,;
                                NIL			,NIL		, NIL	,NIL	,;
                                NIL			,NIL		, .F.,.T.	)

    For nInd:=1 To nTotItens
        
        If aItens[nInd][2] != cFilAnt .AND. !Empty(aItens[nInd][2])
            RmiFilInt(aItens[nInd][2],.T.)//Atuliza cfilAnt .T. 
        EndIf
        
        If !SB1->(DBSeek(xFilial("SB1")+PadR(aItens[nInd][1],TamSx3("B1_COD")[1])))
            LjGrvLog("GetImpPrd", "GetImpPrd -> Produto não encontrado FILIAL|B1_COD  ", cFilAnt+"|"+aItens[nInd][1])
            Exit
        EndIf

        nPreco   := STWFormPr( SB1->B1_COD, cCliente, Nil, cLojaCli, 1)
        cTesProd := IIf(Empty(cTesProd := RetFldProd(SB1->B1_COD,"B1_TS")), GetMv("MV_TESSAI"), cTesProd)
        
        If Empty(cTesProd)
            LjGrvLog("GetImpPrd", "RetFldProd -> TES do Produto não encontrado e MV_TESSAI esta Vazio FILIAL|B1_COD  ", cFilAnt+"|"+aItens[nInd][1])
            Exit
        EndIf
        If !(nPreco > 0)
            LjGrvLog("GetImpPrd", "STWFormPr -> Preço do Produto não encontrado FILIAL|B1_COD  ", cFilAnt+"|"+aItens[nInd][1])
            Exit
        EndIf
        
        nItem := MaFisAdd(SB1->B1_COD, cTesProd, 1, nPreco,;
                                    0, ""	 		, ""    		,				,;
                                    0 /*Frete*/   								, 0 /*Despesa*/	, 0 /*Seguro*/	,0 ,;
                                    nPreco	, 0	 	)
        
        For nY := 1 To Len(aCampos)
            xCampo1   	:= IIF("IT" $ aCampos[nY][1] , MaFisRet(nItem,aCampos[nY][1] ),MaFisRet(,aCampos[nY][1]))
            Aadd(aRet,{cFilAnt,SB1->B1_COD,aCampos[nY][1],xCampo1})    
        Next    
       
        
    Next nInd
    MafisEnd()
    If !Empty(cFilbkp)
        RmiFilInt(cFilbkp,.T.)//Atuliza cfilAnt .T. 
    EndIf
    
EndIf

RestArea(aArea)
Return aRet 
//-------------------------------------------------------------------
/*/{Protheus.doc} JsonImp
Função que gera o Json com os campos da tabela passada, 
no registro da SB1 que esta posicionado

@author  Everson S P Junior
@since   07/08/20
@version 1.0
/*/
//-------------------------------------------------------------------
Function JsonImp(cJson,cCliente,cLojaCli,cFilEnvia)
Local aArea 	:= GetArea()
Local nY   := 0
Local nPreco    := 0
Local cTesProd  := ""
Local cFilbkp   := cFilAnt
Local cFilProc  := ""
Local cSitTrib  := ""
Local xCampo1   := 0
Local nItem     := 0
Local cTesSai   := ""
Local aCampos := ACLONE( ArrayFis )//Campos da MatXfis definidos no include ArrayfunC.CH.

Default cCliente    := GetMv( "MV_CLIPAD" )		// Cliente padrao 
Default cLojaCli    := GetMv( "MV_LOJAPAD" )   // Loja padrao
Default cJson       := "" 
Default cFilEnvia   := ""

cCliente := Padr(cCliente,TamSX3("A1_COD")[1])
cLojaCli := Padr(cLojaCli,TamSX3("A1_LOJA")[1])

cFilProc := Iif(Empty(SB1->B1_FILIAL),cFilEnvia,SB1->B1_FILIAL)

cJson      := "{"

GeraJson(@cJson,"B1_FILIAL", cFilProc) //Gera campo da B1 no Json
GeraJson(@cJson,"B1_COD", SB1->B1_COD)
GeraJson(@cJson,"B1_CLASFIS", SB1->B1_CLASFIS)

If cFilProc != cFilAnt
    RmiFilInt(cFilProc,.T.)//Atuliza cfilAnt .T. 
EndIf

MaFisIni(cCliente ,cLojaCli	, "C"	,"S"	,;
                            'F'	,NIL		, NIL	,.F.	,;
                            "SB1"		,"LOJA701", "01"	,NIL	,;
                            NIL			,NIL		, NIL	,NIL	,;
                            NIL			,NIL		, .F.,.T.	) 

//nPreco   := STWFormPr( SB1->B1_COD, cCliente, Nil, cLojaCli, 1)
//Busca TES Inteligente.
cTesProd := MaTesInt(2,"01",cCliente, cLojaCli,"C", SB1->B1_COD,NIL)
cTesSai  := SuperGetMV("MV_TESSAI",.F.,"501",cFilAnt)

If Empty(cTesProd) //Procura Tes no Produto se não encontrar pega TES do Param MV_TESSAI
    cTesProd := If( Empty( RetFldProd( SB1->B1_COD,"B1_TS" ) ), cTesSai, RetFldProd( SB1->B1_COD,"B1_TS" ) )
Else
    LjGrvLog("JsonImp", "Cliente Utiliza configuracao Tes inteligente ", cTesProd)
EndIf

If Empty(cTesProd)
    LjGrvLog("JsonImp", "RetFldProd -> TES do Produto não encontrado e MV_TESSAI esta Vazio FILIAL|B1_COD  ", cFilAnt+"|"+SB1->B1_COD)
EndIf

If !(nPreco > 0)
    LjGrvLog("JsonImp", "STWFormPr -> Preço do Produto não encontrado FILIAL|B1_COD  ", cFilAnt+"|"+SB1->B1_COD)
EndIf
    
nItem := MaFisAdd(SB1->B1_COD, cTesProd, 1, nPreco,;
                    0, ""	 		, ""    		,				,;
                    0 /*Frete*/   								, 0 /*Despesa*/	, 0 /*Seguro*/	,0 ,;
                    nPreco	, 0	 	)
    
For nY := 1 To Len(aCampos)
    xCampo1   	:= IIF("IT" $ aCampos[nY] , MaFisRet(nItem,aCampos[nY] ),MaFisRet(,aCampos[nY]))
    GeraJson(@cJson,aCampos[nY], xCampo1)
Next

If Posicione("SA1",1,xFilial("SA1") + cCliente + cLojaCli,"A1_COD") <> ""
    cSitTrib := Lj7Strib( "", 0, 0, "", nItem ) 
    GeraJson(@cJson,"IT_SITTRIB", cSitTrib)
Else
    LjGrvLog("JsonImp", "Cliente não posicionado ou não encontrado: ", cCliente+"|"+cLojaCli)    
EndIf


If SF4->(DbSeek(xFilial("SF4")+cTesProd))
    GeraJson(@cJson,"IT_CSTPIS", SF4->F4_CSTPIS)
    GeraJson(@cJson,"IT_CSTCOF", SF4->F4_CSTCOF)
Else
    LjGrvLog("JsonImp", "IT_CSTPIS -> IT_CSTCOF TES NAO ENCONTRADA  ", cFilAnt+"|"+cTesProd)    
EndIf    

 LjGrvLog("JsonImp", "Situacao Tributaria retornada na Função Lj7Strib ", cSitTrib)

cJson := SubStr(cJson, 1, Len(cJson)-1)
cJson += "}"

MafisEnd()
If !Empty(cFilbkp)
    RmiFilInt(cFilbkp,.T.)//Atuliza cfilAnt .T. 
EndIf

RestArea(aArea)
Return cJson

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraJson
Função que gera o Json com os campos da MATAXFIS, 
no registro que esta posicionado

@author  Rafael Tenorio da Costa
@since   30/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GeraJson(cJson,cCampo, xType)
 
    Local cTipo      := ""
    Local xConteudo  := ""
    
    Default cCampo := ""
    Default xType  := ""
    
    LjGrvLog(" GeraJsonImp "," Function GeraJson()")
    
    cTipo     := Valtype(xType)
    xConteudo := xType    
    
    Do Case
        Case cTipo $ "C|M"

            //Retira as "" ou '', pois ocorre erro ao realizar o Parse do Json
            xConteudo := StrTran(xConteudo,'"','')
            xConteudo := StrTran(xConteudo,"'","")
            
            xConteudo := '"' + AllTrim(xConteudo) + '"'

        Case cTipo == "N"
            xConteudo := cValToChar(xConteudo)

        Case cTipo == "D"
            xConteudo := '"' + DtoS(xConteudo) + '"'

        Case cTipo == "L"
            xConteudo := IIF(xConteudo, "true", "false")
        
        OTherWise
            xConteudo := '"Tipo do campo inválido"'
    End Case
    
    cJson += '"' + AllTrim( cCampo ) + '":' + xConteudo + ","

Return cJson

//-------------------------------------------------------------------
/*/{Protheus.doc} RMITImeStamp
Função que gera o numero para ser enviado para o live na tag Numero

@author  Danilo Rodrigues
@since   04/03/21
@version 1.0
/*/
//-------------------------------------------------------------------
Function RMITImeStamp()

Local cTime := FWTimeStamp(1)
LoCal cHora := TimeFull()
Local cHoraFinal := ""

    cTime := Substr(cTime,3,6)
    cHora:= StrTRan(StrTran(cHora,":",""),".","")

    cHoraFinal := "0" + cTime + cHora

Return cHoraFinal

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaTributo
Função que gera o bloco de tributo para processo Imposto Prod

@author  Danilo Rodrigues
@since   04/03/21
@version 1.0
/*/
//-------------------------------------------------------------------
Function MontaTributo(cProcesso, oPublica)

Local cTributo  := ""
Local nX        := 0

If Alltrim(cProcesso) == "IMPOSTO PROD"

    If oPublica["IT_ALIQCOF"] > 0
        nX := nX + 1
        cTributo += "<LC_TributoProduto>" + Chr(10) + Chr(13)
        cTributo +=     "<NumeroSequencia>" + cValtoChar(nX) + "</NumeroSequencia>" + Chr(10) + Chr(13)
        cTributo +=     "<Ativo>true</Ativo>" + Chr(10) + Chr(13)
        cTributo +=     "<CodigoLoja>"+RmiDePaRet('LIVE', 'SM0',oPublica['B1_FILIAL'], .T.)+"</CodigoLoja>" + Chr(10) + Chr(13)
        cTributo +=     "<CodigoProduto>"+oPublica['B1_COD']+"</CodigoProduto>" + Chr(10) + Chr(13)
        cTributo +=     "<CST>"+ Iif(Empty(oPublica['IT_CSTCOF']),"00",oPublica['IT_CSTCOF']) +"</CST>" + Chr(10) + Chr(13)
        cTributo +=     "<CSTEntrada>0</CSTEntrada>" + Chr(10) + Chr(13)
        cTributo +=     "<TipoConfiguracao>PRODUTO</TipoConfiguracao>" + Chr(10) + Chr(13)
        cTributo +=     "<TipoTributo>COFINS</TipoTributo>" + Chr(10) + Chr(13)
        cTributo +=     "<AliquotaImposto>"+StrTran(Alltrim(Str(oPublica['IT_ALIQCOF'])),'.',',')+"</AliquotaImposto>" + Chr(10) + Chr(13)
        cTributo +=     "<CodigoNCM/>" + Chr(10) + Chr(13)
        cTributo += "</LC_TributoProduto>" + Chr(10) + Chr(13)
    EndIF
    
    If oPublica["IT_ALIQPIS"] > 0
        nX := nX + 1
        cTributo += "<LC_TributoProduto>" + Chr(10) + Chr(13)
        cTributo +=     "<NumeroSequencia>" + cValtoChar(nX) + "</NumeroSequencia>" + Chr(10) + Chr(13)
        cTributo +=     "<Ativo>true</Ativo>" + Chr(10) + Chr(13)
        cTributo +=     "<CodigoLoja>"+RmiDePaRet('LIVE', 'SM0',oPublica['B1_FILIAL'], .T.)+"</CodigoLoja>"+ Chr(10) + Chr(13)
        cTributo +=     "<CodigoProduto>"+oPublica['B1_COD']+"</CodigoProduto>" + Chr(10) + Chr(13)
        cTributo +=     "<CST>"+ Iif(Empty(oPublica['IT_CSTPIS']),"00",oPublica['IT_CSTPIS']) +"</CST>" + Chr(10) + Chr(13)
        cTributo +=     "<CSTEntrada>0</CSTEntrada>" + Chr(10) + Chr(13)
        cTributo +=     "<TipoConfiguracao>PRODUTO</TipoConfiguracao>" + Chr(10) + Chr(13)
        cTributo +=     "<TipoTributo>PIS</TipoTributo>" + Chr(10) + Chr(13)
        cTributo +=     "<AliquotaImposto>"+StrTran(Alltrim(Str(oPublica['IT_ALIQPIS'])),'.',',')+"</AliquotaImposto>" + Chr(10) + Chr(13)
        cTributo +=     "<CodigoNCM/>" + Chr(10) + Chr(13)
        cTributo += "</LC_TributoProduto>" + Chr(10) + Chr(13)
    EndIF
     
    If oPublica["IT_ALIQICM"] > 0
        nX := nX + 1
        cTributo += "<LC_TributoProduto>" + Chr(10) + Chr(13)
        cTributo +=     "<NumeroSequencia>" + cValtoChar(nX) + "</NumeroSequencia>" + Chr(10) + Chr(13)
        cTributo +=     "<Ativo>true</Ativo>" + Chr(10) + Chr(13)
        cTributo +=     "<CodigoLoja>"+RmiDePaRet('LIVE', 'SM0',oPublica['B1_FILIAL'], .T.)+"</CodigoLoja>" + Chr(10) + Chr(13)
        cTributo +=     "<CodigoProduto>"+oPublica['B1_COD']+"</CodigoProduto>" + Chr(10) + Chr(13)
        cTributo +=     "<CST>"+ Iif(Empty(oPublica['B1_CLASFIS']),"00",oPublica['B1_CLASFIS']) +"</CST>" + Chr(10) + Chr(13)
        cTributo +=     "<CSTEntrada>0</CSTEntrada>" + Chr(10) + Chr(13)
        cTributo +=     "<TipoConfiguracao>PRODUTO</TipoConfiguracao>" + Chr(10) + Chr(13)
        cTributo +=     "<TipoTributo>ICMS</TipoTributo>" + Chr(10) + Chr(13)
        cTributo +=     "<AliquotaImposto>"+StrTran(Alltrim(Str(oPublica['IT_ALIQICM'])),'.',',')+"</AliquotaImposto>" + Chr(10) + Chr(13)
        cTributo +=     "<CodigoNCM/>" + Chr(10) + Chr(13)
        cTributo += "</LC_TributoProduto>" + Chr(10) + Chr(13)
    EndIF
    
EndIF

Return cTributo
//---------------------------------------------------------------------
/*/{Protheus.doc} RmiRetIBGE
Retorna o codigo da UF segundo o IBGE ou a propria UF
@author  Everso Junior
@since   05/03/2021
@version 12.1.17

@param	 cParam - indica a informacao a ser pesquisada
@param	 cCodMun - XML transformado em objeto atraves da funcao XMLParser
/*/
//---------------------------------------------------------------------
Function RmiRetIBGE(cParam, cCodMun)

Local nPos		:= 0	//posição de um determinado elemento no array
Local aUF		:= {}	//array com os códigos das UF
Local cRet		:= ""

Default cParam	:= ""	//UF ou Codigo IBGE
Default cCodMun := ""	//Codigo do Municipio

Aadd( aUF, {"RO","11"} )
Aadd( aUF, {"AC","12"} )
Aadd( aUF, {"AM","13"} )
Aadd( aUF, {"RR","14"} )
Aadd( aUF, {"PA","15"} )
Aadd( aUF, {"AP","16"} )
Aadd( aUF, {"TO","17"} )
Aadd( aUF, {"MA","21"} )
Aadd( aUF, {"PI","22"} )
Aadd( aUF, {"CE","23"} )
Aadd( aUF, {"RN","24"} )
Aadd( aUF, {"PB","25"} )
Aadd( aUF, {"PE","26"} )
Aadd( aUF, {"AL","27"} )
Aadd( aUF, {"MG","31"} )
Aadd( aUF, {"ES","32"} )
Aadd( aUF, {"RJ","33"} )
Aadd( aUF, {"SP","35"} )
Aadd( aUF, {"PR","41"} )
Aadd( aUF, {"SC","42"} )
Aadd( aUF, {"RS","43"} )
Aadd( aUF, {"MS","50"} )
Aadd( aUF, {"MT","51"} )
Aadd( aUF, {"GO","52"} )
Aadd( aUF, {"DF","53"} )
Aadd( aUF, {"SE","28"} )
Aadd( aUF, {"BA","29"} )
Aadd( aUF, {"EX","99"} )

nPos := aScan( aUF, {|x| x[1] == cParam} )
If nPos > 0
	cRet := aUF[nPos][2]
 	cRet += AllTrim(cCodMun)
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ExtVendCan
Função que Retorna se existe a venda a ser cancelada
Utilizado no layout

@param cChave      - Chave da MHQ 
@param cOrigem     - Assinante

@return lRet       - Logico existe venda cancelada 

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Function ExtVendCan(cChave,cOrigem) 
Local lRet      := .F.
Local cQuery    := ""
Local cWhere    := ""
Local cAlias    := GetNextAlias()
Local cSGBD		:= Upper(AllTrim(TcGetDB()))

Default cChave  := ""
Default cOrigem := ""


If Alltrim(cOrigem) == "LIVE"
    
    If cSGBD $ "DB2*INFORMIX*ORACLE"  .OR. ( cSGBD == "DB2/400" .And. cSGBD == "ISERIES" )
	    cWhere += " AND SUBSTR(MHQ_CHVUNI,17,"+Alltrim(STR(TAMSX3('MHQ_CHVUNI')[1]))+") = '" +  SubStr(cChave, 17, TAMSX3('MHQ_CHVUNI')[1]) + "'"
    Else
	    cWhere += " AND SUBSTRING(MHQ_CHVUNI,17,"+Alltrim(STR(TAMSX3('MHQ_CHVUNI')[1]))+") = '" +  SubStr(cChave, 17, TAMSX3('MHQ_CHVUNI')[1]) + "'"
    EndIf
    
    cQuery := "SELECT MHQ_UUID,MHQ_CHVUNI, MHQ_EVENTO "
    cQuery += " FROM " + RetSqlName("MHQ")
    cQuery += " WHERE D_E_L_E_T_ = '' " 
    cQuery += cWhere
	cQuery += " ORDER BY MHQ_EVENTO "
    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)
    LjGrvLog("ExtVendCan","Query para verificar se existe a venda a ser cancelada -> ",cQuery)

    If !(cAlias)->( Eof() )
        If (cAlias)->MHQ_EVENTO == '1'
			lRet      := .T.
			LjGrvLog("ExtVendCan","Foi encontrado a venda a ser cancelada  ->",{MHQ_UUID,MHQ_CHVUNI})         
		EndIf	
    EndIf
    (cAlias)->( DbCloseArea() )
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} RMISUBSTR
Retorna cConteudo tratado conforme definido no cProcura substituindo por
cTroca é Utilizado no layout.

@param cConteudo      - Texto completo que será utilizado no tratamento 
@param cProcura       - Caracteres separados por | que serão encontrado no cConteudo
@param cTroca         - Caracteres separados por | que serão Substituidos no cConteudo

@return cConteudo     - Retorna Texto completo tratado conforme parametros

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Function RMISUBSTR(cConteudo,cProcura,cTroca)
Local aSubs         := {}
Local aTrans        := {}
Local nX            := 0

Default cConteudo   := ''
Default cProcura    := ''
Default cTroca      := ''

aTrans  := StrTokArr( cProcura, "|" )
aSubs   := StrTokArr( cTroca  , "|" )

If Len(aSubs) == Len(aTrans)//Varias substituições tem que ter sua correspondecia de tamanho igual exemplo '+|&|@' trocar por ' + |E|a' <- tamanho correspondente
    LjGrvLog("RMISUBSTR","Efetuando trocas no conteudo ",{cProcura,cTroca})
    For nX:= 1 To Len (aTrans)
        cConteudo := StrTran( cConteudo, aTrans[nX], aSubs[nX] )
    next
elseIf Len(aSubs) == 1 // Posso trocar varios caracteres por 1 substituição exemplo '+|&|@' trocar por '' <- espaço em branco
    LjGrvLog("RMISUBSTR","Efetuando trocas no conteudo ",{cProcura,cTroca})
    For nX:= 1 To Len (aTrans)//então caso encontre os caracteres troca por branco.
        cConteudo := StrTran( cConteudo, aTrans[nX], aSubs[1] )
    next    
EndIf

Return cConteudo

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiPagCred
Rotina para geração dos títulos de NCC, CR e compensação.
Utilizada para o processamento de vendas com pagamento L1_CREDITO
USO LjGrvFin - LjGrvBatch

@type   function
@param  aDadosBanc, Array, {"A6_AGENCIA", "A6_NUMCON"}
@param  cErro, Caractere, Retorna a descrição do erro para ser gravada na tabela MHL
@return Lógico, Define se a geração e compensação foi efetuada corretamente

@author  Rafael Tenorio da Costa
@since   21/10/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function RmiPagCred(aDadosBanc, cErro)

    Local aTitulo   := {}
    Local lRet      := .T.
    Local cParcela  := LjParcela( 1, SuperGetMv("MV_1DUP") )
    Local cHist     := STR0001  //"Integração - Venda Pagamento Crédito"
    Local cOrigem   := "RMIXFUNC"
    Local nRecnoNCC := 0
    Local nRecnoCR  := 0

    Private lMsErroAuto := .F.  //Variavel usada para o retorno da EXECAUTO

    LjGrvLog(SL1->L1_NUM, "Iniciando geração de pagamento com crédito.")

    //Inclui titulo NCC
    aAdd(aTitulo, { "E1_PREFIXO"    , SL1->L1_SERIE                                     , Nil} )
    aAdd(aTitulo, { "E1_NUM"        , SL1->L1_DOC 				                        , Nil} )
    aAdd(aTitulo, { "E1_PARCELA"    , cParcela					                        , Nil} )
    aAdd(aTitulo, { "E1_NATUREZ"    , LjMExeParam("MV_NATNCC")	                        , Nil} )
    aAdd(aTitulo, { "E1_TIPO" 	    , "NCC"						                        , Nil} )
    aAdd(aTitulo, { "E1_EMISSAO"    , SL1->L1_EMISSAO 			                        , Nil} )
    aAdd(aTitulo, { "E1_VALOR"	    , SL1->L1_CREDITO			                        , Nil} )
    aAdd(aTitulo, { "E1_VENCTO"     , SL1->L1_DTLIM				                        , Nil} )
    aAdd(aTitulo, { "E1_VENCREA"	, DataValida(SL1->L1_DTLIM, .T.)                    , Nil} )	
    aAdd(aTitulo, { "E1_VENCORI"	, SL1->L1_DTLIM					                    , Nil} )
    aAdd(aTitulo, { "E1_SALDO"	    , SL1->L1_CREDITO								    , Nil} )
    aAdd(aTitulo, { "E1_VLCRUZ"	    , xMoeda(SL1->L1_CREDITO, 1, 1, SL1->L1_EMISSAO)    , Nil} )
    aAdd(aTitulo, { "E1_CLIENTE"	, SL1->L1_CLIENTE							        , Nil} )
    aAdd(aTitulo, { "E1_LOJA"	    , SL1->L1_LOJA	   						            , Nil} )
    aAdd(aTitulo, { "E1_MOEDA"	    , SL1->L1_MOEDA							            , Nil} )
    aAdd(aTitulo, { "E1_ORIGEM"     , cOrigem   						                , Nil} )
    aAdd(aTitulo, { "E1_HIST"	    , cHist	                                            , Nil} )

    LjGrvLog(SL1->L1_NUM, "Gerando titulo NCC. [Fina040]", aTitulo)

    MsExecAuto( { |x, y| Fina040(x, y) }, aTitulo, 3)  

    If lMsErroAuto

        cErro := I18n(STR0002, {"NCC"}) + MostraErro("\")   //"Não foi possível gerar título #1: "

    //Inclui titulo CR
    Else

        nRecnoNCC := SE1->( Recno() )

        aSize(aTitulo, 0)

        aAdd(aTitulo, { "E1_PREFIXO"    , SL1->L1_SERIE                                     , Nil} )
        aAdd(aTitulo, { "E1_NUM"        , SL1->L1_DOC 				                        , Nil} )
        aAdd(aTitulo, { "E1_PARCELA"    , cParcela					                        , Nil} )
        aAdd(aTitulo, { "E1_NATUREZ"    , LjMExeParam("MV_NATCRED")	                        , Nil} )
        aAdd(aTitulo, { "E1_PORTADO"    , SL1->L1_OPERADO	                                , Nil} )
        aAdd(aTitulo, { "E1_AGEDEP" 	, aDadosBanc[1]	                                    , Nil} )
        aAdd(aTitulo, { "E1_CONTA" 		, aDadosBanc[2]	                                    , Nil} )
        aAdd(aTitulo, { "E1_TIPO" 	    , "CR"						                        , Nil} )
        aAdd(aTitulo, { "E1_EMISSAO"    , SL1->L1_EMISSAO 			                        , Nil} )
        aAdd(aTitulo, { "E1_VALOR"	    , SL1->L1_CREDITO			                        , Nil} )
        aAdd(aTitulo, { "E1_VENCTO"     , SL1->L1_DTLIM				                        , Nil} )
        aAdd(aTitulo, { "E1_VENCREA"	, DataValida(SL1->L1_DTLIM, .T.)                    , Nil} )
        aAdd(aTitulo, { "E1_VENCORI"	, SL1->L1_DTLIM					                    , Nil} )
        aAdd(aTitulo, { "E1_SALDO"	    , SL1->L1_CREDITO								    , Nil} )
        aAdd(aTitulo, { "E1_VLCRUZ"	    , xMoeda(SL1->L1_CREDITO, 1, 1, SL1->L1_EMISSAO)    , Nil} )
        aAdd(aTitulo, { "E1_CLIENTE"	, SL1->L1_CLIENTE							        , Nil} )
        aAdd(aTitulo, { "E1_LOJA"	    , SL1->L1_LOJA	   						            , Nil} )
        aAdd(aTitulo, { "E1_MOEDA"	    , SL1->L1_MOEDA							            , Nil} )
        aAdd(aTitulo, { "E1_ORIGEM"     , cOrigem						                    , Nil} )
        aAdd(aTitulo, { "E1_HIST"	    , cHist                     	                    , Nil} )

        LjGrvLog(SL1->L1_NUM, "Gerando titulo CR. [Fina040]", aTitulo)

        MsExecAuto( { |x, y| Fina040(x, y) }, aTitulo, 3) 

        If lMsErroAuto

            cErro := I18n(STR0002, {"CR"}) + MostraErro("\")    //"Não foi possível gerar título #1: "

        //Compensa NCC com CR
        Else

            nRecnoCR := SE1->( Recno() )

            LjGrvLog(SL1->L1_NUM, "Compensando NCC com CR. [MaIntBxCR]", {nRecnoNCC, nRecnoCR})

            If !MaIntBxCR(3, {nRecnoCR}, /*aBaixa*/, {nRecnoNCC}, /*aLiquidacao*/, {.T., .F., .F., .F., .F., .F.})
                lMsErroAuto := .T.            
                cErro       := I18n(STR0003, {"NCC", "CR"})     //"Não foi possível compensar título #1 com #2."
            EndIf
            
        EndIf

    EndIf

    //Grava log de erros
    If lMsErroAuto
        lRet := .F.
        LjxjMsgErr(cErro, /*cSolucao*/, SL1->L1_NUM)
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RMIRetApur
Função que verifica a configuração do cliente para preencher os impostos 
de Pis e Cofins dos tipos Apuração e Retenção

@param cIdentCliente  - Codigo de Identificação Cliente vindo da integração

@return lRet          - Retorno logico

@author  Danilo Rodrigues
@version 1.0
/*/
//-------------------------------------------------------------------
Function RMIRetApur(cIdentCliente)

Local cCodCli       := ""
Local cCodLoja      := ""
Local lRet          := .T.

DEFAULT cIdentCliente := ""

    if Empty(cIdentCliente)
        cCodCli     := SuperGetMv('MV_CLIPAD', .F., '000001')
        cCodLoja    := SuperGetMv('MV_LOJPAD', .F., '01')       
        LjGrvLog("RMIRetApur", "Não identificado na integração o cliente, será usado o cliente padrão!", {cCodCli, cCodLoja})

        SA1->(DbSetOrder(1))
        If SA1->(DbSeek(xFilial("SA1") + cCodCli + cCodLoja ))

            //Apuração
            If SA1->A1_RECPIS $ " |N" .OR. SA1->A1_RECCOFI $ " |N"
                lRet := .T.
            else
                lRet := .F.
            ENDIF
            LjGrvLog("RMIRetApur", "Identificado cliente e retornado a configuração de PIS/Cofins", lRet)
        ENDIF

    ELSE

        LjGrvLog("RMIRetApur", "Identificado Cliente na integração, busca na SA1 por CPF/CNPJ", cIdentCliente)

        SA1->(DbSetOrder(3))
        If SA1->(DbSeek(xFilial("SA1") + cIdentCliente ))

            //Apuração
            IF SA1->A1_RECPIS $ " |N" .OR. SA1->A1_RECCOFI $ " |N"
                lRet := .T.
            else
                lRet := .F.
            ENDIF
            LjGrvLog("RMIRetApur", "Identificado cliente e retornado a configuração de PIS/Cofins", lRet)
        ENDIF

    ENDIF   

RETURN lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RMIConWsdl()
Cria o objeto TWsdlManager a partir da Url

@param  cUrl - String -  URL do Wsdl
@param  cErro - String - Variavel de erro, deve ser enviada como referencia
@return  oWsdl - objeto TWsdlManager

@author  Lucas Novais (lNovais@)
@since 	 05/04/22
@version 1.0
/*/
//-------------------------------------------------------------------
Function RMIConWsdl(cUrl, cErro)

	//Cria o objeto da classe TWsdlManager
	Local oWsdl := Nil
	Local nWsdl := 0

	//Limpa a variavel de referencia antes de executar
	cErro := ""

	//Valida se o objeto ja esta em cache
	If ( nWsdl := aScan(aWsdl, {|x| x[1] == AllTrim(cUrl)}) ) == 0

		oWsdl                    := TWsdlManager():New()
        oWsdl:nConnectionTimeout := 300
        oWsdl:nTimeout           := 300
		oWsdl:nSoapVersion       := 0
		oWsdl:bNoCheckPeerCert   := .T.

		//Faz o parse de uma URL
		If oWsdl:ParseURL(cUrl)
			cErro := ""
			Aadd(aWsdl, {AllTrim(cUrl), oWsdl})			//Cache do wsdl parseado
		Else
			cErro := oWsdl:cError	//Mensagem de erro não tratada, quem solicitou trata e da a visibilidade ao erro.
		EndIf
	Else
        If !Empty(aWsdl[nWsdl][2]:cError)
            
            // -- Destroi o objeto para remover a memoria alocada
            FreeObj(aWsdl[nWsdl][2])
            
            // -- Removo a posição do array e reorganizo 
            aDel(aWsdl,nWsdl)
            aSize(aWsdl,Len(aWsdl) - 1 )

            // -- Utilizo a função recursivamente para criar o objeto novamente.
            oWsdl := RMIConWsdl(cUrl, @cErro)
        Else
            oWsdl := aWsdl[nWsdl][2]
        EndIf 
	Endif

Return oWsdl