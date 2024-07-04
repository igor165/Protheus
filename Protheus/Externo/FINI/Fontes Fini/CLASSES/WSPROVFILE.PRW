#Include "PROTHEUS.CH"
#Include "TOTVS.CH"
#Include "RESTFUL.CH"
#Include "RWMAKE.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSPROVFILE

Webservice para o envio do arquivo para o fornecedor

@author CM Solutions - Allan Constantino Bonfim
@since   25/08/2020
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------

    //CM Solutions - Allan Constantino Bonfim - 16/09/2020 - Projeto Compras Técnicas
    // DECLARAÇÃO DO SERVIÇO REST
    WSRESTFUL WSPROVFILE DESCRIPTION "Serviço para envio de arquivo para o fornecedor"
        WSDATA cIdFile  as String

        // DECLARAÇÃO DO MÉTODO GET
        WSMETHOD GET DESCRIPTION "Retorna um arquivo do pedido de compras para o fornecedor" PATH "/WSPROVFILE/{cIdFile}"
    END WSRESTFUL

//----------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GET/WSPROVFILE

Retorna o arquivo do pedido de compras

@author CM Solutions - Allan Constantino Bonfim
@since   25/08/2020
@param  cIdPedido  	- caracter - Id do pedido criptografado
@version P12 
@return lReturn		- lógico   - Indica se a consulta foi bem sucedida ou não.
/*/
//---------------------------------------------------------------------------------------------------------------------
WSMETHOD GET WSRECEIVE cIdFile WSREST WSPROVFILE

    Local lSuccess      := .T.
    Local cSeek         := ""
    Local cFile         := ""
    Local oFile         := ""
	Local cArqCriado    := ""
    Local cPstArq		:= ""
    Local cEmpPrc       := ""
    Local cFilPrc       := ""
    Local cNumPed       := ""
    Local cIdPedido     := ""

    
    //CM Solutions - Allan Constantino Bonfim - 16/09/2020 - Projeto Compras Técnicas
    If Len(::aURLParms) > 0
        cIdPedido := ALLTRIM(::aURLParms[1])
    Else
        cIdPedido := ALLTRIM(::cIdFile)
    EndIf

    If !Empty(cIdPedido)
        cSeek := U_COMP20KEY(cIdPedido, .F.) //Alltrim(::cIdFile)

        cEmpPrc := Substr(cSeek, 1, 2)
        cFilPrc := Substr(cSeek, 3, 2)
        cNumPed := SUBSTR(cSeek, 7, 6)

        //seta o ambiente com a empresa 99 filial 01 com os direitos do usuário administrador, 
        RPCSetType(3)
        RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {"SC7"})

            cPstArq	    := GetNewPar("ZZ_CP20PST", "\ALLAN\")
            cArqCriado  := cSeek+".pdf"

            If !File(cPstArq+cArqCriado)        
                DbSelectArea("SC7")
                SC7->(DbSetOrder(1))
                If SC7->(DbSeek(cFilPrc+cNumPed))
                    U_SCRCOM01(cNumPed, cArqCriado, cPstArq)
                EndIf
            EndIf
           
            oFile := FwFileReader():New(cPstArq+cArqCriado) // CAMINHO ABAIXO DO ROOTPATH

            // SE FOR POSSÍVEL ABRIR O ARQUIVO, LEIA-O
            // SE NÃO, EXIBA O ERRO DE ABERTURA
            If oFile:Open()
                cFile := oFile:FullRead() // EFETUA A LEITURA DO ARQUIVO

                // RETORNA O ARQUIVO PARA DOWNLOAD
                Self:SetHeader("Content-Disposition", "inline; filename=\"+Alltrim(cArqCriado)+"\" )        
                Self:SetContentType("application/pdf") 
                Self:SetResponse(cFile)

                DbSelectArea("SC7")
                SC7->(DBORDERNICKNAME("ARQPEDCOMP"))
                cSeek := PADR(cSeek,TAMSX3("C7_ZZARQPC")[1])
                If SC7->(DbSeek(cSeek))
                    While !SC7->(EOF()) .AND. SC7->C7_FILIAL = cFilPrc .AND. SC7->C7_NUM = cNumPed .AND. SC7->C7_ZZARQPC == cSeek
                        If Empty(SC7->C7_ZZAPCLO)
                            Reclock("SC7", .F.)
                                SC7->C7_ZZAPCLO := DTOC(DATE())+" - "+TIME()
                            MsUnlock()
                        EndIf
                        SC7->(DbSkip())
                    EndDo
                Else
                    SetRestFault(502, "Pedido de compras não localizado. Favor entrar em contato para a verificação.", .F.) // GERA MENSAGEM DE ERRO CUSTOMIZADA
                    lSuccess := .F.                    
                EndIf
            Else
                SetRestFault(501, "Arquivo não localizado. Favor entrar em contato para a verificação.", .F.) // GERA MENSAGEM DE ERRO CUSTOMIZADA
                lSuccess := .F.
            EndIf
            
        RpcClearEnv() 
    Else
        SetRestFault(401, "Id não informado. Verifique os parâmetros da requisição.", .F.)
        lSuccess := .F.
    EndIf   

Return lSuccess
