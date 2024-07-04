#include 'totvs.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPXNFS.CH'

#DEFINE CAMPO       1
#DEFINE CONTEUDO    2

//------------------------------------------------------------------------------
/* /{Protheus.doc} GetStruArr

@type Static Function
@author jacomo.fernandes
@since 01/10/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GTPxNFS(cSerie,aDadosCab,aDadosItem,bFiscalSF2,cNumDoc,cOrigem)
Local cNumero       := ""
Local aStruSF2      := NIL
Local aStruSD2      := NIL
Local aDocOri       := {}
Local aCabs      	:= {}
Local aItem         := {}
Local aItens     	:= {}
Local nSF2          := 0
Local nSD2_1        := 0
Local nSD2_2        := 0

Default cNumDoc := ''
Default cOrigem := ''

AADD(aDocOri,0)

DbSelectArea('SF2')
DbSelectArea('SD2')

aStruSF2      :=  SF2->(dbStruct())
aStruSD2      :=  SD2->(dbStruct())
aCabs      	:= GetStruArr(aStruSF2)
For nSF2 := 1 To Len(aDadosCab)
    SetValArr(aStruSF2,aCabs,aDadosCab[nSF2,CAMPO]   ,aDadosCab[nSF2,CONTEUDO])    
Next

For nSD2_1 := 1 To Len(aDadosItem)
    aItem  := GetStruArr(aStruSD2)
    For nSD2_2 := 1 To Len(aDadosItem[nSD2_1])
        SetValArr(aStruSD2,aItem,aDadosItem[nSD2_1,nSD2_2,CAMPO]   ,aDadosItem[nSD2_1,nSD2_2,CONTEUDO])    
    Next
    aAdd(aItens,aItem)
Next

cNumero := MaNfs2Nfs(	"",;            //Serie do Documento de Origem
                        "",;            //Numero do Documento de Origem
                        "",;            //Cliente/Fornecedor do documento do origem
                        "",;            //Loja do Documento de origem
                        cSerie,;        //Serie do Documento a ser gerado
                        ,;              //Mostra Lct.Contabil (OPC)
                        ,;              //Aglutina Lct.Contabil (OPC)
                        ,;              //Contabiliza On-Line (OPC)
                        ,;              //Contabiliza Custo On-Line (OPC)
                        ,;              //Reajuste de preco na nota fiscal (OPC)
                        ,;              //Tipo de Acrescimo Financeiro (OPC)
                        ,;              //Tipo de Arredondamento (OPC)
                        ,;              //Atualiza Amarracao Cliente x Produto (OPC)
                        .F.,;           //Cupom Fiscal (OPC)
                        ,;              //CodeBlock de Selecao do SD2 (OPC)
                        ,;              //CodeBlock a ser executado para o SD2 (OPC)
                        ,;              //CodeBlock a ser executado para o SF2 (OPC)
                        ,;              //CodeBlock a ser executado no final da transacao (OPC)
                        aDocOri,;       //Array com os Recnos do SF2 (OPC)
                        aItens,;        //Array com os itens do SD2 (OPC)
                        aCabs,;         //Array com os dados do SF2 (OPC)
                        ,;              //Calculo Fiscal - Desabilita o calculo fiscal pois as informacoes ja foram passadas nos campos do SD2 e SF2 (OPC)
                        bFiscalSF2,;	//code block para tratamento do fiscal - SF2 (OPC)
                        ,;              //code block para tratamento do fiscal - SD2 (OPC)
                        ,;              //code block para tratamento do fiscal - SE1 (OPC)
                         IIf(!Empty(cNumDoc),cNumDoc,NIL))              //Numero do documento fiscal (OPC)

 If !Empty(cOrigem)
    SE1->(DbSetOrder(2))		//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
    If SE1->(DbSeek(xFilial("SE1")+SA1->A1_COD +SA1->A1_LOJA+cSerie+cNumero ))
        
        While  SE1->(!EOF()) .And. SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_PREFIXO == cSerie ;
                .And. SE1->E1_NUM == PadR(cNumero,TamSx3("E1_NUM")[1]) .And. SE1->E1_TIPO == PadR('NF',TamSx3("E1_TIPO")[1]);
                .And. SE1->E1_CLIENTE== SA1->A1_COD  .And. SE1->E1_LOJA== SA1->A1_LOJA
                        
            SE1->(RecLock(("SE1"),.F.))
            SE1->E1_ORIGEM := cOrigem
            SE1->(MsUnlock())
            
            PEGTPBOL() // Ponto de Entrada para impressao do boleto (customização de clientes)

            SE1->(DbSkip())

        EndDo

    EndIF
 EndIF

GtpDestroy(aStruSF2)
GtpDestroy(aStruSD2)

Return cNumero


//------------------------------------------------------------------------------
/* /{Protheus.doc} GetStruArr

@type Static Function
@author jacomo.fernandes
@since 01/10/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function GetStruArr(aDbStruct)
Local aRet      := {}
Local nX        := 0

For nX := 1 To Len(aDbStruct)
    Aadd(aRet,GTPCastType(,aDbStruct[nX][2]))
Next

Return aRet


//------------------------------------------------------------------------------
/* /{Protheus.doc} SetValArr

@type Static Function
@author jacomo.fernandes
@since 01/10/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetValArr(aDbStruct,aDados,cCampo,uVal)
Local nPos      := 0

If (nPos := Ascan(aDbStruct,{|x| AllTrim(x[1]) == cCampo	}) ) > 0
    aDados[nPos]   	:= uVal
Endif

Return


//------------------------------------------------------------------------------
/* /{Protheus.doc} GetValArr

@type Static Function
@author jacomo.fernandes
@since 01/10/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function GetValArr(aDbStruct,aDados,cCampo)
Local uVal      := nil
Local nPos      := 0


If (nPos := Ascan(aDbStruct,{|x| AllTrim(x[1]) == cCampo	}) ) > 0
    uVal := aDados[nPos]
Endif

Return uVal


//------------------------------------------------------------------------------
/* /{Protheus.doc} GTPBXTIT
//Função executada nas baixas de títulos de origem GTP
//SE1 E SE5 estão posicionadas neste momento
@type Function
@author 
@since 06/01/2020
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GTPBXTIT()
Local cAliasAux := GetNextAlias()
Local aAreaGIR  := GIR->(GetArea())
Local aAreaGIY  := GIY->(GetArea())
    
    BeginSQL Alias cAliasAux   

        SELECT GIS_FILIAL,GIS_CODIGO,GIW_FILORI,GIW_PREFIX,GIW_NUMTIT,GIW_PARCEL,GIW_TIPO, GIR_CODIGO, GIR_SEQ
        FROM %Table:GIS% GIS 
        INNER JOIN %Table:GIT% GIT  ON GIS_FILIAL= GIT_FILIAL AND GIS_CODIGO=GIT_CODFAT
        INNER JOIN %Table:GIW% GIW  ON GIT_FILIAL=GIW_FILIAL AND GIT_CODFAT=GIW_CODFAT
        INNER JOIN %Table:GIR% GIR  ON GIR_FILIAL=GIT_FILIAL AND GIR_CODIGO=GIT_CODG99
        WHERE 
        GIS_FILIAL = %xFilial:GIS% AND
        GIW_FILORI = %Exp:SE1->E1_FILIAL% AND
        GIW_PREFIX = %Exp:SE1->E1_PREFIXO% AND
        GIW_NUMTIT = %Exp:SE1->E1_NUM% AND
        GIW_PARCEL = %Exp:SE1->E1_PARCELA% AND 
        GIW_TIPO = %Exp:SE1->E1_TIPO% AND
        GIS_CLIENT = %Exp:SE1->E1_CLIENTE% AND 
        GIS_LOJA = %Exp:SE1->E1_LOJA% AND
        GIS.%NotDel% AND
        GIT.%NotDel% AND
        GIW.%NotDel% AND
        GIR.%NotDel%

    EndSQL
            
	If (cAliasAux)->(!Eof())
        While ( (cAliasAux)->(!Eof()) )	
          //FAZ GRAVAÇÃO DA GIY

            GIR->(dbSetOrder(2))
            If GIR->(MsSeek(xFilial("GIR") + (cAliasAux)->GIR_CODIGO + (cAliasAux)->GIR_SEQ))
                GIY->(RecLock("GIY",.T.))
                GIY->GIY_CODIGO     := xFilial("GIY")
                GIY->GIY_CODIGO     := (cAliasAux)->GIR_CODIGO
                GIY->GIY_SEQ        := (cAliasAux)->GIR_SEQ
                GIY->GIY_IDORIG     := FK1->FK1_IDFK1
                GIY->GIY_VALOR      := FK1->FK1_VALOR 
                GIY->GIY_DTBAIX     := dDataBase 
            	GIY->(MsUnlock())
            EndIf
            
            (cAliasAux)->(DbSkip())
		EndDo
	EndIf 
    (cAliasAux)->(DbCloseArea())
    
    RestArea(aAreaGIR)
    RestArea(aAreaGIY)

Return  

//------------------------------------------------------------------------------
/* /{Protheus.doc} GTPESTBX
//Função executada noestorno/cancelamento das baixas de títulos de origem GTP
//SE1 E SE5 estão posicionadas neste momento
@type Function
@author 
@since 06/01/2020
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GTPESTBX()
Local cAliasAux := GetNextAlias()
Local aAreaGIY  := GIY->(GetArea())
Local lRet      := .T.
 
    If ExcBXSimul(FK1->FK1_IDFK1)
       
        BeginSQL Alias cAliasAux   

            SELECT R_E_C_N_O_ RECNO
            FROM %Table:GIY% GIY
            WHERE 
            GIY_FILIAL = %xFilial:GIY% AND
            GIY_IDORIG = %Exp:FK1->FK1_IDFK1% AND
            GIY.%NotDel%

        EndSQL

        If (cAliasAux)->(!Eof())
            While ( (cAliasAux)->(!Eof()) )	
            //FAZ DELEÇÃO DA GIY
                
                    GIY->(dbGoTo((cAliasAux)->RECNO))
                    GIY->(RecLock("GIY",.F.))
                    GIY->(DbDelete())
                    GIY->(MsUnlock())
            
                (cAliasAux)->(DbSkip())
            EndDo
        EndIf 
        (cAliasAux)->(DbCloseArea())

    Else
        lRet := .F.    
    EndIf 
    
    RestArea(aAreaGIY)

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} ExcBXSimul
//Função para verificação de cancelamento
//SE1 E SE5 estão posicionadas neste momento
@type Function
@author 
@since 06/01/2020
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function ExcBXSimul(cIDORIG)
Local cAliasAux := GetNextAlias()
Local lRet := .T.

    BeginSQL Alias cAliasAux   

        SELECT GIX_CODGQ6 COMISSAO
        FROM %Table:GIX% GIX
        WHERE 
        GIX_FILIAL = %xFilial:GIX% AND
        GIX_CODGIY = %Exp:cIDORIG% AND
        GIX_SIMULA = %Exp:Space(TAMSX3("GIX_SIMULA")[1])% AND
        GIX.%NotDel%

    EndSQL

    If (cAliasAux)->(!Eof())
         lRet := .F.
         FwAlertHelp( STR0001 + ' ( '+COMISSAO+' ) - GTP.')  //'Não permitida a exclusão, já pertence a comissão( '+COMISSAO+' ) - GTP.'
    EndIf 
    (cAliasAux)->(DbCloseArea())

Return lRet 
