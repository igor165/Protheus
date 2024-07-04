#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static lShowMsg     := .F.
Static lAllAppend   := .F.

Static cMsgValid    := ""
Static cMsgSoluc    := ""
Static cGetCFCTe    := ""

Static aCTeCFOP     := {}
Static aCTeOSCFOP   := {}

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPMsgSwitch()

Liga ou desliga os alertas de mensagens

@sample		GTPMsgSwitch(.T.,.T.)
@return		cMsgValid, caractere, mensagem de erro
@author	GTP
@since		27/06/2022
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPMsgSwitch(lTurnOn,lAllwaysAppend)

    Default lTurnOn := .T.
    Default lAllwaysAppend := .F.

    lShowMsg := lTurnOn
    GTPAppendSwitch(lAllwaysAppend)

Return(lShowMsg)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPResetMsg()

Reset da mensagem de erro

@sample		GTPResetMsg()
@params     
@return		
@author	GTP
@since		27/06/2022
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPResetMsg()

    cMsgValid   := ""
    cMsgSoluc   := ""

Return()


Function GTPSetMsg(cMsg,cSolucMsg,lAppend)

    Default lAppend     := lAllAppend
    Default cSolucMsg   := ""

    If ( lAppend )
        cMsgValid += IIf(Empty(cMsg), cMsg, chr(13)+chr(10) + cMsg)
        cMsgSoluc += IIf(Empty(cSolucMsg), cSolucMsg, chr(13)+chr(10) + cSolucMsg)
    Else
        cMsgValid := cMsg
        cMsgSoluc := cSolucMsg
    EndIf        

Return()


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPRetMsg()

Retorna a mensagem de erro

@sample		cMsg := GTPRetMsg()
@return		cMsgValid, caractere, mensagem de erro
@author	GTP
@since		27/06/2022
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPRetMsg()

Return({cMsgValid,cMsgSoluc})

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPAppendSwitch()

Liga ou desliga a anexa��o de mensagem de erro, na mensagem existente

@sample		GTPAppendSwitch(.t.)
@return		
@author	GTP
@since		27/06/2022
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPAppendSwitch(lTurnOn)

    Default lTurnOn := .T.

    lAllAppend := lTurnOn

Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPVldClient()
Valida��o de cliente para documentos fiscais (CTe, MDFe e CTe-OS)
@sample		GTPA903()
@return		lRet, L�gico, .t. valida��o efetuada com sucesso. .F. inv�lido
@author	GTP
@since		27/06/2022
@version	P12
/*/
//------------------------------------------------------------------------------------------

Function GTPVldClient(cFilCli,cCodCli,cLojaCli,cEspDoc)

    Local lRet  := .t.
    
    Local aCustomer := {;
        {"A1_FILIAL",;      //[01]
        "A1_COD",;          //[02]
        "A1_LOJA",;         //[03]
        "A1_NREDUZ",;       //[04]
        "A1_CGC",;          //[05]
        "A1_TIPO",;         //[06]
        "A1_PAIS",;         //[07]
        "A1_COD_MUN",;      //[08]
        "A1_BAIRRO",;       //[09]
        "A1_CEP",;          //[10]
        "A1_INSCR"}}        //[11]
    Local aSeek     := {}

    Local cMsg      := ""
    Local cSolucao  := ""

    aAdd(aSeek,{"A1_FILIAL",cFilCli})
    aAdd(aSeek,{"A1_COD",cCodCli})
    aAdd(aSeek,{"A1_LOJA",cLojaCli})

    GTPSeekTable("SA1",aSeek,aCustomer)

    If ( Len(aCustomer) > 1 )
    
        Do Case
        Case ( cEspDoc $ "CTE|MDF" )

            If ( Empty(aCustomer[2,05]) ) //Sem CNPJ ou CPF preenchido
                
                cMsg := "O cliente selecionado "     
                cMsg += Alltrim(aCustomer[2,04])
                cMsg += " est� sem informa��o de " 
                cMsg += Iif(aCustomer[2,06] == "F", "CPF "," CNPJ ")

                cSolucao := "Atualize o registro do cadastro de clientes, "
                cSolucao += "o referido campo, com o dado de CPF/CNPJ (campo A1_CGC)."
                
                lRet := .f.

                GtpSetMsg(cMsg,cSolucao)

            EndIf  
            
            If  ( (lRet .Or. (!lRet .And. lAllAppend )) .And. Empty(aCustomer[2,07]) ) //Sem c�digo de pa�s
                
                cMsg := " O cliente selecionado "
                cMsg += Alltrim(aCustomer[2,04])
                cMsg += " est� sem informa��o de" 
                cMsg += " c�digo de pa�s." 

                cSolucao := "Atualize o registro do cadastro de clientes, "
                cSolucao += "o referido campo, com o dado do c�digo de pa�s (campo A1_PAIS)."
                
                lRet := .f.

                GtpSetMsg(cMsg,cSolucao)

            EndIf  
            
            If  ( (lRet .Or. (!lRet .And. lAllAppend )) .And. Empty(aCustomer[2,08]) ) //Sem C�digo de Munic�pio
                
                cMsg := " O cliente selecionado "
                cMsg += Alltrim(aCustomer[2,04])
                cMsg += " est� sem informa��o de" 
                cMsg += " c�digo de munic�pio" 

                cSolucao := "Atualize o registro do cadastro de clientes, "
                cSolucao += "o referido campo, com o dado de c�digo de munic�pio (campo A1_COD_MUN)."
                
                lRet := .f.

                GtpSetMsg(cMsg,cSolucao)

            EndIf  
            
            If  ( (lRet .Or. (!lRet .And. lAllAppend )) .And. Empty(aCustomer[2,09]) ) //Sem Bairro
                
                cMsg := " O cliente selecionado "
                cMsg += Alltrim(aCustomer[2,04])
                cMsg += " est� sem informa��o de" 
                cMsg += " nome de bairro" 

                cSolucao := "Atualize o registro do cadastro de clientes, "
                cSolucao += "o referido campo, com o dado de bairro (campo A1_BAIRRO)."
                
                lRet := .f.

                GtpSetMsg(cMsg,cSolucao)

            EndIf  
            
            If  ( (lRet .Or. (!lRet .And. lAllAppend )) .And. Empty(aCustomer[2,10]) ) //Sem CEP
                
                cMsg := " O cliente selecionado "
                cMsg += Alltrim(aCustomer[2,04])
                cMsg += " est� sem informa��o de" 
                cMsg += " n�mero de CEP" 

                cSolucao := "Atualize o registro do cadastro de clientes, "
                cSolucao += "o referido campo, com o dado de CEP (campo A1_CEP)."

                lRet := .f.

                GtpSetMsg(cMsg,cSolucao)

            EndIf  
            
       /*     If  ( (lRet .Or. (!lRet .And. lAllAppend )) .And. Empty(aCustomer[2,11]) ) //Sem Inscri��o Estadual
                
                cMsg := " O cliente selecionado "
                cMsg += Alltrim(aCustomer[2,04])
                cMsg += " est� sem informa��o de" 
                cMsg += " n�mero de Inscri��o Estadual" 

                cSolucao := "Atualize o registro do cadastro de clientes, "
                cSolucao += "o referido campo, com o dado de Inscri��o Estadual (campo A1_INSCR)."

                lRet := .f.

                GtpSetMsg(cMsg,cSolucao)

            EndIf  */

        // Case ( cEspDoc == "CTEOS" )
        End Case
    
    EndIf

    If ( !lRet )
        
        GTPShowMsg()
        
    EndIf

Return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPVldClient()
Valida��o de cliente para documentos fiscais (CTe, MDFe e CTe-OS)
@sample		GTPA903()
@return		lRet, L�gico, .t. valida��o efetuada com sucesso. .F. inv�lido
@author	GTP
@since		27/06/2022
@version	P12
/*/
//------------------------------------------------------------------------------------------

Function GTPVldAgency(cFilAge,cCodAg,cEspDoc)

    Local lRet  := .t.
    
    Local aAgency := {;
        {"GI6_FILIAL",;     //[01]
        "GI6_CODIGO",;      //[02]
        "GI6_DESCRI",;      //[03]
        "GI6_ENCEXP",;      //[04]
        "GI6_FILRES",;      //[05]
        "GI6_CEPENC"}}      //[06]
        
    Local aSeek     := {}

    Local cMsg      := ""
    Local cSolucao  := ""

    aAdd(aSeek,{"GI6_FILIAL",cFilAge})
    aAdd(aSeek,{"GI6_CODIGO",cCodAg})    

    GTPSeekTable("GI6",aSeek,aAgency)

    If ( Len(aAgency) > 1 )
    
        Do Case
        Case ( cEspDoc $ "CTE|MDF" )

            If ( aAgency[2,04] != "1" ) //Ag�ncia n�o � de Encomenda 
                
                cMsg := "A Ag�ncia selecionada "
                cMsg += Alltrim(aAgency[2,02]) + ": " + Alltrim(aAgency[2,03])
                cMsg += " n�o uma ag�ncia para encomendas. "                 

                cSolucao := "Atualize o registro do cadastro de ag�ncias, "
                cSolucao += "para ser uma ag�ncia de encomenda (GI6_ENCEXP = '1')."
                
                lRet := .f.

                GtpSetMsg(cMsg,cSolucao)

            EndIf  
            
            //Utilizar no futuro? Ou ficar� obsoleto de vez, o uso de Filial de encomenda na Ag�ncia
            // If  ( (lRet .Or. (!lRet .And. lAllAppend )) .And. Empty(aAgency[2,05]) ) //Sem Filial de Encomenda
                
            //     cMsg := "A Ag�ncia selecionada "
            //     cMsg += Alltrim(aAgency[2,02]) + ": " + Alltrim(aAgency[2,03])
            //     cMsg += " n�o possui Filial de Encomendas." 

            //     cSolucao := "Atualize o registro do cadastro de ag�ncias, "
            //     cSolucao += "com a informa��o da Filial de Encomendas (campo GI6_ENCFIL)."
                
            //     lRet := .f.     

            //     GtpSetMsg(cMsg,cSolucao)

            // EndIf  
            
            If  ( (lRet .Or. (!lRet .And. lAllAppend )) .And. Len(Alltrim(aAgency[2,06])) != 8 ) //Sem Cep da Ag�ncia
                
                cMsg := "A Ag�ncia selecionada "
                cMsg += Alltrim(aAgency[2,02]) + ": " + Alltrim(aAgency[2,03])
                cMsg += " ou n�o possui CEP, ou � um CEP inv�lido." 

                cSolucao := "Atualize o registro do cadastro de ag�ncias, "
                cSolucao += "com a informa��o da CEP (campo GI6_CEPENC)."
                
                lRet := .f.

                GtpSetMsg(cMsg,cSolucao)

            EndIf  
            

        // Case ( cEspDoc == "CTEOS" )
        End Case
    
    EndIf

    If ( !lRet )
        
        GTPShowMsg()
        
    EndIf

Return(lRet)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPVldCFOP()
Valida��o de CFOP  para documentos fiscais (CTe, MDFe e CTe-OS)
@sample		GTPA903()
@return		oBrowse  Retorna o Cadastro de Apura��o de contrato
@author	GTP
@since		01/12/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPVldCFOP(cNumCFOP,cUFOrigem,cUFDestino,cTipoDoc,cEspDoc)

    Local lRet  := .T.

    Local cMsg  := ""
    Local cSolucao  := "Selecione o CFOP que se enquadre adequadamente � situa��o."

    Do Case 
    Case ( cEspDoc == "CTE" )
    
        //Tipos de CT-e
        //= 0 (Normal) 
        //= 1 (Complemento) 
        //= 2 (Anula��o) 
        //= 3 (Substitui��o)
        //= 5 (FS-DA)
    
        GetCTeCFOP()
        
        If ( AScan(aCTeCFOP,{|x| x[1] == Alltrim(cNumCFOP) }) > 0 )
            
            If ( cTipoDoc <> "2" )  //Se n�o for anula��o

                If ( cUFDestino != "EX" .And. cUFOrigem == cUFDestino .And. (SubStr(cNumCFOP,1,1) != "5") )
                    
                    lRet := .F.
                    
                    cMsg := "O Estado de origem e Estado de destino "
                    cMsg += "� o mesmo. Sendo assim, o CFOP utilizado "
                    cMsg += "dever� iniciar com 5. "
                    
                ElseIf ( cUFDestino != "EX" .And. cUFOrigem != cUFDestino .And. (SubStr(cNumCFOP,1,1) != "6") )    
                    
                    lRet := .F.

                    cMsg := "O Estado de origem e Estado de destino "
                    cMsg += "s�o distintos. Sendo assim, o CFOP utilizado "
                    cMsg += "dever� iniciar com 6. "
                                    
                ElseIf ( cUFDestino == "EX" .And. (SubStr(cNumCFOP,1,1) != "7") )    
                    
                    lRet := .F.

                    cMsg := "O Estado do destino � no Exterior. "
                    cMsg += "Sendo assim, o CFOP utilizado "
                    cMsg += "dever� iniciar com 7. "
                    
                EndIf
            
            Else
                
                If ( cUFDestino != "EX" .And.  cUFOrigem == cUFDestino .And. Alltrim(cNumCFOP) != "1206" )
                    
                    lRet := .F.                    
                    
                    cMsg := "Em CTe de anula��o, "
                    cMsg += "quando o estado de origem e de destinos s�o os mesmos, "
                    cMsg += "o CFOP utilizado deve ser 1206. "
                                        
                ElseIf ( cUFDestino != "EX" .And.  cUFOrigem != cUFDestino .And. Alltrim(cNumCFOP) != "2206" )
                    
                    lRet := .F.                    
                    
                    cMsg := "Em CTe de anula��o, "
                    cMsg += "quando o estado de origem e de destinos s�o diferentes, "
                    cMsg += "o CFOP utilizado deve ser 2206. "
                                                            
                ElseIf ( cUFDestino == "EX" .And. Alltrim(cNumCFOP) != "3206" )
                    
                    lRet := .F.                    

                    cMsg := "Em CTe de anula��o, "
                    cMsg += "quando o destino � Exterior, "
                    cMsg += "o CFOP utilizado deve ser 3206. "
                                                            
                EndIf

            EndIf    
    
        Else
            
            lRet := .f.

            cMsg := "O CFOP utilizado n�o � aceito para estas esp�cies de documentos fiscais."

        EndIf

    // Case ( cEspDoc == "CTEOS" )

        // GetCTeOSCFOP()

        // If ( AScan(aCTeOSCFOP,{|x| x[1] == Alltrim(cNumCFOP) }) > 0 )
            
        //     If ( cTipoDoc <> "2" )  //Se n�o for anula��o

        //         If ( cUFDestino != "EX" .And. cUFOrigem == cUFDestino .And. (SubStr(cNumCFOP,1,1) != "5") )
                    
        //             lRet := .F.
                    
        //             cMsg := "O Estado de origem e Estado de destino "
        //             cMsg += "� o mesmo. Sendo assim, o CFOP utilizado "
        //             cMsg += "dever� iniciar com 5. "

        //         ElseIf ( cUFDestino != "EX" .And. cUFOrigem != cUFDestino .And. (SubStr(cNumCFOP,1,1) != "6") )    
                    
        //             lRet := .F.

        //             cMsg := "O Estado de origem e Estado de destino "
        //             cMsg += "s�o distintos. Sendo assim, o CFOP utilizado "
        //             cMsg += "dever� iniciar com 6. "
                
        //         ElseIf ( cUFDestino == "EX" .And. (SubStr(cNumCFOP,1,1) != "7") )    
                    
        //             lRet := .F.

        //             cMsg := "O Estado do destino � no Exterior. "
        //             cMsg += "Sendo assim, o CFOP utilizado "
        //             cMsg += "dever� iniciar com 7. "

        //         EndIf
            
        //     Else
                
        //         If ( cUFDestino != "EX" .And.  cUFOrigem == cUFDestino .And. Alltrim(cNumCFOP) != "1206" )
                    
        //             lRet := .F.                    
        //             cMsg := "Em CTe de anula��o, "
        //             cMsg += "quando o estado de origem e de destinos s�o os mesmos, "
        //             cMsg += "o CFOP utilizado deve ser 1206. "
                    
        //         ElseIf ( cUFDestino != "EX" .And.  cUFOrigem != cUFDestino .And. Alltrim(cNumCFOP) != "2206" )
                    
        //             lRet := .F.                    
        //             cMsg := "Em CTe de anula��o, "
        //             cMsg += "quando o estado de origem e de destinos s�o diferentes, "
        //             cMsg += "o CFOP utilizado deve ser 2206. "
                    
        //         ElseIf ( cUFDestino == "EX" .And. Alltrim(cNumCFOP) != "3206" )
                    
        //             lRet := .F.                    
        //             cMsg := "Em CTe de anula��o, "
        //             cMsg += "quando o destino � Exterior, "
        //             cMsg += "o CFOP utilizado deve ser 3206. "
                    
        //         EndIf

        //     EndIf    
    
        // Else
            
        //     lRet := .f.
        //     cMsg := "O CFOP utilizado n�o � aceito para estas esp�cies de documentos fiscais."
        // EndIf
        
    End Case

    If ( !lRet )

        GtpSetMsg(cMsg,cSolucao)
        GTPShowMsg()

    EndIf    

Return(lRet)

Function GTPVldDoc(cSerie,cEspDoc)

    Local lRet  := .T.
    
    Local cMsg      := ""
    Local cSolucao  := ""

    lRet := EspecieDoc(cSerie,cEspDoc)

    If ( lRet )

        Do Case
        Case ( cEspDoc == "CTE" )
            
            If ( IsDigit(cSerie) .And. Val(cSerie) >= 890 .And. Val(cSerie) <= 899  )

                lRet := .F.

                cMsg := "S�ries de CTe dentro da faixa 890 a 899 n�o podem ser "
                cMsg += "utilizadas porque s�o de uso reservado."

                cSolucao := "N�o � poss�vel utilizar uma s�rie entre 890 a 899. "
                cSolucao += "Deve-se utilizar outra numera��o."

            EndIf

        // Case ( cEspDoc == "MDF" )
        // Case ( cEspDoc == "CTEOS" )
        End Case

    EndIf

    If ( !lRet )

        GtpSetMsg(cMsg,cSolucao)
        GTPShowMsg()

    EndIf  

Return(lRet)

Static Function EspecieDoc(cSerieDoc,cEspDoc)

    Local cSerie	:= SuperGetMv("MV_ESPECIE")
    Local cMsg      := ""
    Local cSolucao  := ""
    
    Local aSeries   := {}

    Local lRet      := .T.

	If( !Empty(cSerie) )	
			
		aSeries := Separa(cSerie,";")
		
		If ( Len(aSeries) > 0 )

			nP := aScan(aSeries,{|x| (Alltrim(cSerieDoc) + "=" + Alltrim(cEspDoc))  $ x })

			If ( nP == 0 )	
				
                cMsg :=  "S�rie informada n�o cadastrada para " + Alltrim(cEspDoc) + ". Informe uma s�rie correspondente"
				
                cSolucao := "Verifique o cadastro de par�metros (SIGACFG: Configurador). "
                cSolucao += "Preencha o conte�do de MV_ESPECIE com " 
                cSolucao += Alltrim(cSerieDoc) + "=" + Alltrim(cEspDoc) + "."
                
                lRet := .F.	

			Endif

			If lRet .AND. ( !(SX5->(DBSEEK(XFILIAL("SX5") + "01" + Alltrim(cSerieDoc) ))) )	

				cMsg := "S�rie informada n�o cadastrada em tabelas gen�ricas para " + Alltrim(cSerieDoc) + ". Informe uma s�rie correspondente a CTEOS"
             
                cSolucao := "Verifique o cadastro de tabelas gen�ricas (SIGACFG: Configurador). "
                cSolucao += "Insira um novo registro para a tabela gen�rica '01' (SERIES DE N. FISCAIS). " 
				
				lRet := .F.	

			Endif
		
        Endif

	Else
		
        cMsg :=  "Par�metro MV_ESPECIE n�o preenchido. Informe uma s�rie correspondente a " + Alltrim(cSerieDoc) + " no par�metro" 

        cSolucao := "Verifique o cadastro de par�metros (SIGACFG: Configurador), "
        cSolucao += "preencha o conte�do de MV_ESPECIE com " 
        cSolucao += Alltrim(cSerieDoc) + "=" + Alltrim(cEspDoc) + "."

		lRet := .F.	

	Endif

    GTPSetMsg(cMsg,cSolucao,.t.)

Return(lRet)

Static Function GetCTeCFOP()

    If ( Len(aCTeCFOP) == 0 )
    
        aAdd(aCTeCFOP,{"1206", "Anula��o de valor relativo � presta��o de servi�o de transporte", .t.})
        aAdd(aCTeCFOP,{"2206", "Anula��o de valor relativo � presta��o de servi�o de transporte", .t.})
        aAdd(aCTeCFOP,{"3206", "Anula��o de valor relativo � presta��o de servi�o de transporte", .t.})
        aAdd(aCTeCFOP,{"5206", "Anula��o de valor relativo a aquisi��o de servi�o de transporte", .t.})
        aAdd(aCTeCFOP,{"5351", "Presta��o de servi�o de transporte para execu��o de servi�o da mesma natureza", .t.})
        aAdd(aCTeCFOP,{"5352", "Presta��o de servi�o de transporte a estabelecimento industrial", .F.})
        aAdd(aCTeCFOP,{"5353", "Presta��o de servi�o de transporte a estabelecimento comercial", .F.})
        aAdd(aCTeCFOP,{"5354", "Presta��o de servi�o de transporte a estabelecimento de prestador de servi�o de comunica��o", .F.})
        aAdd(aCTeCFOP,{"5355", "Presta��o de servi�o de transporte a estabelecimento de geradora ou de distribuidora de energia el�trica", .F.})
        aAdd(aCTeCFOP,{"5356", "Presta��o de servi�o de transporte a estabelecimento de produtor rural", .F.})
        aAdd(aCTeCFOP,{"5357", "Presta��o de servi�o de transporte a n�o contribuinte", .t.})
        aAdd(aCTeCFOP,{"5359", "Presta��o de servi�o de transporte a contribuinte ou a n�o contribuinte quando a mercadoria transportada est� dispensada de emiss�o de nota fiscal.", .t.})
        aAdd(aCTeCFOP,{"5360", "Presta��o de servi�o de transporte a contribuinte substituto em rela��o ao servi�o de transporte", .t.})
        aAdd(aCTeCFOP,{"5601", "Transfer�ncia de cr�dito de ICMS acumulado", .t.})
        aAdd(aCTeCFOP,{"5602", "Transfer�ncia de saldo credor de ICMS para outro estabelecimento da mesma empresa, destinado � compensa��o de saldo devedor de ICMS", .t.})
        aAdd(aCTeCFOP,{"5603", "Ressarcimento de ICMS retido por substitui��o tribut�ria", .t.})
        aAdd(aCTeCFOP,{"5605", "Transfer�ncia de saldo devedor de ICMS de outro estabelecimento da mesma empresa.", .t.})
        aAdd(aCTeCFOP,{"5606", "Utiliza��o de saldo credor de ICMS para extin��o por compensa��o de d�bitos fiscais.", .t.})
        aAdd(aCTeCFOP,{"5932", "Presta��o de servi�o de transporte iniciada em unidade da Federa��o diversa daquela onde inscrito o prestador", .t.})
        aAdd(aCTeCFOP,{"5949", "Outra sa�da de mercadoria ou presta��o de servi�o n�o especificado ", .t.})
        aAdd(aCTeCFOP,{"6206", "Anula��o de valor relativo a aquisi��o de servi�o de transporte", .t.})
        aAdd(aCTeCFOP,{"6351", "Presta��o de servi�o de transporte para execu��o de servi�o da mesma natureza", .t.})
        aAdd(aCTeCFOP,{"6352", "Presta��o de servi�o de transporte a estabelecimento industrial", .F.})
        aAdd(aCTeCFOP,{"6353", "Presta��o de servi�o de transporte a estabelecimento comercial", .F.})
        aAdd(aCTeCFOP,{"6354", "Presta��o de servi�o de transporte a estabelecimento de prestador de servi�o de comunica��o", .F.})
        aAdd(aCTeCFOP,{"6355", "Presta��o de servi�o de transporte a estabelecimento de geradora ou de distribuidora de energia el�trica", .F.})
        aAdd(aCTeCFOP,{"6356", "Presta��o de servi�o de transporte a estabelecimento de produtor rural ", .F.})
        aAdd(aCTeCFOP,{"6357", "Presta��o de servi�o de transporte a n�o contribuinte", .t.})
        aAdd(aCTeCFOP,{"6359", "Presta��o de servi�o de transporte a contribuinte ou a n�o contribuinte quando a mercadoria transportada est� dispensada de emiss�o de nota fiscal.", .t.})
        aAdd(aCTeCFOP,{"6360", "Presta��o de servi�o de transporte a contribuinte substituto em rela��o ao servi�o de transporte.", .t.})
        aAdd(aCTeCFOP,{"6603", "Ressarcimento de ICMS retido por substitui��o tribut�ria ", .t.})
        aAdd(aCTeCFOP,{"6932", "Presta��o de servi�o de transporte iniciada em unidade da Federa��o diversa daquela onde inscrito o prestador", .t.})
        aAdd(aCTeCFOP,{"6949", "Outra sa�da de mercadoria ou presta��o de servi�o n�o especificado", .t.})
        aAdd(aCTeCFOP,{"7206", "Anula��o de valor relativo a aquisi��o de servi�o de transporte", .t.})
        aAdd(aCTeCFOP,{"7358", "Presta��o de servi�o de transporte", .t.})
        aAdd(aCTeCFOP,{"7949", "Outra sa�da de mercadoria ou presta��o de servi�o n�o especificado", .t.})
    EndIf

Return(aCTeCFOP)

Static Function GetCTeOSCFOP()

    If ( Len(aCTeOSCFOP) == 0 )

        aAdd(aCTeOSCFOP,{"1206", "Anula��o de valor relativo � presta��o de servi�o de transporte", .t.})
        aAdd(aCTeOSCFOP,{"2206", "Anula��o de valor relativo � presta��o de servi�o de transporte", .t.})
        aAdd(aCTeOSCFOP,{"3206", "Anula��o de valor relativo � presta��o de servi�o de transporte", .t.})
        aAdd(aCTeOSCFOP,{"5206", "Anula��o de valor relativo a aquisi��o de servi�o de transporte", .t.})
        aAdd(aCTeOSCFOP,{"5351", "Presta��o de servi�o de transporte para execu��o de servi�o da mesma natureza", .t.})
        aAdd(aCTeOSCFOP,{"5352", "Presta��o de servi�o de transporte a estabelecimento industrial", .F.})
        aAdd(aCTeOSCFOP,{"5353", "Presta��o de servi�o de transporte a estabelecimento comercial", .F.})
        aAdd(aCTeOSCFOP,{"5354", "Presta��o de servi�o de transporte a estabelecimento de prestador de servi�o de comunica��o", .F.})
        aAdd(aCTeOSCFOP,{"5355", "Presta��o de servi�o de transporte a estabelecimento de geradora ou de distribuidora de energia el�trica", .F.})
        aAdd(aCTeOSCFOP,{"5356", "Presta��o de servi�o de transporte a estabelecimento de produtor rural", .F.})
        aAdd(aCTeOSCFOP,{"5357", "Presta��o de servi�o de transporte a n�o contribuinte", .t.})
        aAdd(aCTeOSCFOP,{"5601", "Transfer�ncia de cr�dito de ICMS acumulado", .t.})
        aAdd(aCTeOSCFOP,{"5602", "Transfer�ncia de saldo credor de ICMS para outro estabelecimento da mesma empresa, destinado � compensa��o de saldo devedor de ICMS", .t.})
        aAdd(aCTeOSCFOP,{"5603", "Ressarcimento de ICMS retido por substitui��o tribut�ria", .t.})
        aAdd(aCTeOSCFOP,{"5605", "Transfer�ncia de saldo devedor de ICMS de outro estabelecimento da mesma empresa.", .t.})
        aAdd(aCTeOSCFOP,{"5606", "Utiliza��o de saldo credor de ICMS para extin��o por compensa��o de d�bitos fiscais.", .t.})
        aAdd(aCTeOSCFOP,{"5949", "Outra sa�da de mercadoria ou presta��o de servi�o n�o especificado ", .t.})
        aAdd(aCTeOSCFOP,{"6360", "Presta��o de servi�o de transporte a contribuinte substituto em rela��o ao servi�o de transporte.", .t.})
        aAdd(aCTeOSCFOP,{"6603", "Ressarcimento de ICMS retido por substitui��o tribut�ria ", .t.})
        aAdd(aCTeOSCFOP,{"6932", "Presta��o de servi�o de transporte iniciada em unidade da Federa��o diversa daquela onde inscrito o prestador", .t.})
        aAdd(aCTeOSCFOP,{"6949", "Outra sa�da de mercadoria ou presta��o de servi�o n�o especificado", .t.})
        aAdd(aCTeOSCFOP,{"7949", "Outra sa�da de mercadoria ou presta��o de servi�o n�o especificado", .t.})
    EndIf

Return(aCTeOSCFOP)

Function GTPShowMsg()

    If ( lShowMsg )
        //Apresentar a mensagem da vari�vel cMsgValid
    EndIf

Return()


Function GTPCFCTeList()

    Local lRet := .T.

    Local cQuery    := ""
    Local cFields   := ""
    Local cAlias    := "CFOP"

    Local aIndex    := {}

    Local oLookUp

    cQuery := "SELECT  " + chr(13)
    cQuery += "    X5_CHAVE     CFOP, " + chr(13)
    cQuery += "    X5_DESCRI    DESCRICAO " + chr(13)
    cQuery += "FROM  " + chr(13)
    cQuery += "    " + RetSQLName("SX5") + " " + chr(13)
    cQuery += "WHERE  " + chr(13)
    cQuery += "    X5_TABELA = '13' " + chr(13)
    cQuery += "    AND X5_CHAVE IN " + chr(13)
    cQuery += "    ( " + chr(13)
    cQuery += "        '1206', " + chr(13)
    cQuery += "        '2206', " + chr(13)
    cQuery += "        '3206', " + chr(13)
    cQuery += "        '5206', " + chr(13)
    cQuery += "        '5351', " + chr(13)
    cQuery += "        '5352', " + chr(13)
    cQuery += "        '5353', " + chr(13)
    cQuery += "        '5354', " + chr(13)
    cQuery += "        '5355', " + chr(13)
    cQuery += "        '5356', " + chr(13)
    cQuery += "        '5357', " + chr(13)
    cQuery += "        '5359', " + chr(13)
    cQuery += "        '5360', " + chr(13)
    cQuery += "        '5601', " + chr(13)
    cQuery += "        '5602', " + chr(13)
    cQuery += "        '5603', " + chr(13)
    cQuery += "        '5605', " + chr(13)
    cQuery += "        '5606', " + chr(13)
    cQuery += "        '5932', " + chr(13)
    cQuery += "        '5949', " + chr(13)
    cQuery += "        '6206', " + chr(13)
    cQuery += "        '6351', " + chr(13)
    cQuery += "        '6352', " + chr(13)
    cQuery += "        '6353', " + chr(13)
    cQuery += "        '6354', " + chr(13)
    cQuery += "        '6355', " + chr(13)
    cQuery += "        '6356', " + chr(13)
    cQuery += "        '6357', " + chr(13)
    cQuery += "        '6359', " + chr(13)
    cQuery += "        '6360', " + chr(13)
    cQuery += "        '6603', " + chr(13)
    cQuery += "        '6932', " + chr(13)
    cQuery += "        '6949', " + chr(13)
    cQuery += "        '7206', " + chr(13)
    cQuery += "        '7358', " + chr(13)
    cQuery += "        '7949' " + chr(13)
    cQuery += "    ) " + chr(13)
    cQuery += "    AND D_E_L_E_T_ = ' ' " + chr(13)
    cQuery += "ORDER BY  " + chr(13)
    cQuery += "    X5_TABELA,  " + chr(13)
    cQuery += "    X5_CHAVE " + chr(13)

    oLookUp := GTPXLookUp():New(StrTran(cQuery, '#', '"'), {"CFOP","DESCRICAO"})

    oLookUp:AddIndice("C�digo Fiscal",  "CFOP")
    oLookUp:AddIndice("Descri��o",      "DESCRICAO")

    If oLookUp:Execute()

        lRet       := .T.
    
        aRetorno   := oLookUp:GetReturn()
        cGetCFCTe := aRetorno[1]
    
    EndIf   

    FreeObj(oLookUp)
    //Continuar a partir daqui - pegar como exemplo: a consulta GIIFIL

    // GTPTemporaryTable(cQuery,cAlias,aIndex,aFldConv,oTable)
Return(lRet)

Function GTPGetCFCte()

Return(cGetCFCTe)
