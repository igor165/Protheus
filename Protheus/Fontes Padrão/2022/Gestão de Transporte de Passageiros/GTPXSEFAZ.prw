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

Liga ou desliga a anexação de mensagem de erro, na mensagem existente

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
Validação de cliente para documentos fiscais (CTe, MDFe e CTe-OS)
@sample		GTPA903()
@return		lRet, Lógico, .t. validação efetuada com sucesso. .F. inválido
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
                cMsg += " está sem informação de " 
                cMsg += Iif(aCustomer[2,06] == "F", "CPF "," CNPJ ")

                cSolucao := "Atualize o registro do cadastro de clientes, "
                cSolucao += "o referido campo, com o dado de CPF/CNPJ (campo A1_CGC)."
                
                lRet := .f.

                GtpSetMsg(cMsg,cSolucao)

            EndIf  
            
            If  ( (lRet .Or. (!lRet .And. lAllAppend )) .And. Empty(aCustomer[2,07]) ) //Sem código de país
                
                cMsg := " O cliente selecionado "
                cMsg += Alltrim(aCustomer[2,04])
                cMsg += " está sem informação de" 
                cMsg += " código de país." 

                cSolucao := "Atualize o registro do cadastro de clientes, "
                cSolucao += "o referido campo, com o dado do código de país (campo A1_PAIS)."
                
                lRet := .f.

                GtpSetMsg(cMsg,cSolucao)

            EndIf  
            
            If  ( (lRet .Or. (!lRet .And. lAllAppend )) .And. Empty(aCustomer[2,08]) ) //Sem Código de Município
                
                cMsg := " O cliente selecionado "
                cMsg += Alltrim(aCustomer[2,04])
                cMsg += " está sem informação de" 
                cMsg += " código de município" 

                cSolucao := "Atualize o registro do cadastro de clientes, "
                cSolucao += "o referido campo, com o dado de código de município (campo A1_COD_MUN)."
                
                lRet := .f.

                GtpSetMsg(cMsg,cSolucao)

            EndIf  
            
            If  ( (lRet .Or. (!lRet .And. lAllAppend )) .And. Empty(aCustomer[2,09]) ) //Sem Bairro
                
                cMsg := " O cliente selecionado "
                cMsg += Alltrim(aCustomer[2,04])
                cMsg += " está sem informação de" 
                cMsg += " nome de bairro" 

                cSolucao := "Atualize o registro do cadastro de clientes, "
                cSolucao += "o referido campo, com o dado de bairro (campo A1_BAIRRO)."
                
                lRet := .f.

                GtpSetMsg(cMsg,cSolucao)

            EndIf  
            
            If  ( (lRet .Or. (!lRet .And. lAllAppend )) .And. Empty(aCustomer[2,10]) ) //Sem CEP
                
                cMsg := " O cliente selecionado "
                cMsg += Alltrim(aCustomer[2,04])
                cMsg += " está sem informação de" 
                cMsg += " número de CEP" 

                cSolucao := "Atualize o registro do cadastro de clientes, "
                cSolucao += "o referido campo, com o dado de CEP (campo A1_CEP)."

                lRet := .f.

                GtpSetMsg(cMsg,cSolucao)

            EndIf  
            
       /*     If  ( (lRet .Or. (!lRet .And. lAllAppend )) .And. Empty(aCustomer[2,11]) ) //Sem Inscrição Estadual
                
                cMsg := " O cliente selecionado "
                cMsg += Alltrim(aCustomer[2,04])
                cMsg += " está sem informação de" 
                cMsg += " número de Inscrição Estadual" 

                cSolucao := "Atualize o registro do cadastro de clientes, "
                cSolucao += "o referido campo, com o dado de Inscrição Estadual (campo A1_INSCR)."

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
Validação de cliente para documentos fiscais (CTe, MDFe e CTe-OS)
@sample		GTPA903()
@return		lRet, Lógico, .t. validação efetuada com sucesso. .F. inválido
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

            If ( aAgency[2,04] != "1" ) //Agência não é de Encomenda 
                
                cMsg := "A Agência selecionada "
                cMsg += Alltrim(aAgency[2,02]) + ": " + Alltrim(aAgency[2,03])
                cMsg += " não uma agência para encomendas. "                 

                cSolucao := "Atualize o registro do cadastro de agências, "
                cSolucao += "para ser uma agência de encomenda (GI6_ENCEXP = '1')."
                
                lRet := .f.

                GtpSetMsg(cMsg,cSolucao)

            EndIf  
            
            //Utilizar no futuro? Ou ficará obsoleto de vez, o uso de Filial de encomenda na Agência
            // If  ( (lRet .Or. (!lRet .And. lAllAppend )) .And. Empty(aAgency[2,05]) ) //Sem Filial de Encomenda
                
            //     cMsg := "A Agência selecionada "
            //     cMsg += Alltrim(aAgency[2,02]) + ": " + Alltrim(aAgency[2,03])
            //     cMsg += " não possui Filial de Encomendas." 

            //     cSolucao := "Atualize o registro do cadastro de agências, "
            //     cSolucao += "com a informação da Filial de Encomendas (campo GI6_ENCFIL)."
                
            //     lRet := .f.     

            //     GtpSetMsg(cMsg,cSolucao)

            // EndIf  
            
            If  ( (lRet .Or. (!lRet .And. lAllAppend )) .And. Len(Alltrim(aAgency[2,06])) != 8 ) //Sem Cep da Agência
                
                cMsg := "A Agência selecionada "
                cMsg += Alltrim(aAgency[2,02]) + ": " + Alltrim(aAgency[2,03])
                cMsg += " ou não possui CEP, ou é um CEP inválido." 

                cSolucao := "Atualize o registro do cadastro de agências, "
                cSolucao += "com a informação da CEP (campo GI6_CEPENC)."
                
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
Validação de CFOP  para documentos fiscais (CTe, MDFe e CTe-OS)
@sample		GTPA903()
@return		oBrowse  Retorna o Cadastro de Apuração de contrato
@author	GTP
@since		01/12/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPVldCFOP(cNumCFOP,cUFOrigem,cUFDestino,cTipoDoc,cEspDoc)

    Local lRet  := .T.

    Local cMsg  := ""
    Local cSolucao  := "Selecione o CFOP que se enquadre adequadamente à situação."

    Do Case 
    Case ( cEspDoc == "CTE" )
    
        //Tipos de CT-e
        //= 0 (Normal) 
        //= 1 (Complemento) 
        //= 2 (Anulação) 
        //= 3 (Substituição)
        //= 5 (FS-DA)
    
        GetCTeCFOP()
        
        If ( AScan(aCTeCFOP,{|x| x[1] == Alltrim(cNumCFOP) }) > 0 )
            
            If ( cTipoDoc <> "2" )  //Se não for anulação

                If ( cUFDestino != "EX" .And. cUFOrigem == cUFDestino .And. (SubStr(cNumCFOP,1,1) != "5") )
                    
                    lRet := .F.
                    
                    cMsg := "O Estado de origem e Estado de destino "
                    cMsg += "é o mesmo. Sendo assim, o CFOP utilizado "
                    cMsg += "deverá iniciar com 5. "
                    
                ElseIf ( cUFDestino != "EX" .And. cUFOrigem != cUFDestino .And. (SubStr(cNumCFOP,1,1) != "6") )    
                    
                    lRet := .F.

                    cMsg := "O Estado de origem e Estado de destino "
                    cMsg += "são distintos. Sendo assim, o CFOP utilizado "
                    cMsg += "deverá iniciar com 6. "
                                    
                ElseIf ( cUFDestino == "EX" .And. (SubStr(cNumCFOP,1,1) != "7") )    
                    
                    lRet := .F.

                    cMsg := "O Estado do destino é no Exterior. "
                    cMsg += "Sendo assim, o CFOP utilizado "
                    cMsg += "deverá iniciar com 7. "
                    
                EndIf
            
            Else
                
                If ( cUFDestino != "EX" .And.  cUFOrigem == cUFDestino .And. Alltrim(cNumCFOP) != "1206" )
                    
                    lRet := .F.                    
                    
                    cMsg := "Em CTe de anulação, "
                    cMsg += "quando o estado de origem e de destinos são os mesmos, "
                    cMsg += "o CFOP utilizado deve ser 1206. "
                                        
                ElseIf ( cUFDestino != "EX" .And.  cUFOrigem != cUFDestino .And. Alltrim(cNumCFOP) != "2206" )
                    
                    lRet := .F.                    
                    
                    cMsg := "Em CTe de anulação, "
                    cMsg += "quando o estado de origem e de destinos são diferentes, "
                    cMsg += "o CFOP utilizado deve ser 2206. "
                                                            
                ElseIf ( cUFDestino == "EX" .And. Alltrim(cNumCFOP) != "3206" )
                    
                    lRet := .F.                    

                    cMsg := "Em CTe de anulação, "
                    cMsg += "quando o destino é Exterior, "
                    cMsg += "o CFOP utilizado deve ser 3206. "
                                                            
                EndIf

            EndIf    
    
        Else
            
            lRet := .f.

            cMsg := "O CFOP utilizado não é aceito para estas espécies de documentos fiscais."

        EndIf

    // Case ( cEspDoc == "CTEOS" )

        // GetCTeOSCFOP()

        // If ( AScan(aCTeOSCFOP,{|x| x[1] == Alltrim(cNumCFOP) }) > 0 )
            
        //     If ( cTipoDoc <> "2" )  //Se não for anulação

        //         If ( cUFDestino != "EX" .And. cUFOrigem == cUFDestino .And. (SubStr(cNumCFOP,1,1) != "5") )
                    
        //             lRet := .F.
                    
        //             cMsg := "O Estado de origem e Estado de destino "
        //             cMsg += "é o mesmo. Sendo assim, o CFOP utilizado "
        //             cMsg += "deverá iniciar com 5. "

        //         ElseIf ( cUFDestino != "EX" .And. cUFOrigem != cUFDestino .And. (SubStr(cNumCFOP,1,1) != "6") )    
                    
        //             lRet := .F.

        //             cMsg := "O Estado de origem e Estado de destino "
        //             cMsg += "são distintos. Sendo assim, o CFOP utilizado "
        //             cMsg += "deverá iniciar com 6. "
                
        //         ElseIf ( cUFDestino == "EX" .And. (SubStr(cNumCFOP,1,1) != "7") )    
                    
        //             lRet := .F.

        //             cMsg := "O Estado do destino é no Exterior. "
        //             cMsg += "Sendo assim, o CFOP utilizado "
        //             cMsg += "deverá iniciar com 7. "

        //         EndIf
            
        //     Else
                
        //         If ( cUFDestino != "EX" .And.  cUFOrigem == cUFDestino .And. Alltrim(cNumCFOP) != "1206" )
                    
        //             lRet := .F.                    
        //             cMsg := "Em CTe de anulação, "
        //             cMsg += "quando o estado de origem e de destinos são os mesmos, "
        //             cMsg += "o CFOP utilizado deve ser 1206. "
                    
        //         ElseIf ( cUFDestino != "EX" .And.  cUFOrigem != cUFDestino .And. Alltrim(cNumCFOP) != "2206" )
                    
        //             lRet := .F.                    
        //             cMsg := "Em CTe de anulação, "
        //             cMsg += "quando o estado de origem e de destinos são diferentes, "
        //             cMsg += "o CFOP utilizado deve ser 2206. "
                    
        //         ElseIf ( cUFDestino == "EX" .And. Alltrim(cNumCFOP) != "3206" )
                    
        //             lRet := .F.                    
        //             cMsg := "Em CTe de anulação, "
        //             cMsg += "quando o destino é Exterior, "
        //             cMsg += "o CFOP utilizado deve ser 3206. "
                    
        //         EndIf

        //     EndIf    
    
        // Else
            
        //     lRet := .f.
        //     cMsg := "O CFOP utilizado não é aceito para estas espécies de documentos fiscais."
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

                cMsg := "Séries de CTe dentro da faixa 890 a 899 não podem ser "
                cMsg += "utilizadas porque são de uso reservado."

                cSolucao := "Não é possível utilizar uma série entre 890 a 899. "
                cSolucao += "Deve-se utilizar outra numeração."

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
				
                cMsg :=  "Série informada não cadastrada para " + Alltrim(cEspDoc) + ". Informe uma série correspondente"
				
                cSolucao := "Verifique o cadastro de parâmetros (SIGACFG: Configurador). "
                cSolucao += "Preencha o conteúdo de MV_ESPECIE com " 
                cSolucao += Alltrim(cSerieDoc) + "=" + Alltrim(cEspDoc) + "."
                
                lRet := .F.	

			Endif

			If lRet .AND. ( !(SX5->(DBSEEK(XFILIAL("SX5") + "01" + Alltrim(cSerieDoc) ))) )	

				cMsg := "Série informada não cadastrada em tabelas genéricas para " + Alltrim(cSerieDoc) + ". Informe uma série correspondente a CTEOS"
             
                cSolucao := "Verifique o cadastro de tabelas genéricas (SIGACFG: Configurador). "
                cSolucao += "Insira um novo registro para a tabela genérica '01' (SERIES DE N. FISCAIS). " 
				
				lRet := .F.	

			Endif
		
        Endif

	Else
		
        cMsg :=  "Parâmetro MV_ESPECIE não preenchido. Informe uma série correspondente a " + Alltrim(cSerieDoc) + " no parâmetro" 

        cSolucao := "Verifique o cadastro de parâmetros (SIGACFG: Configurador), "
        cSolucao += "preencha o conteúdo de MV_ESPECIE com " 
        cSolucao += Alltrim(cSerieDoc) + "=" + Alltrim(cEspDoc) + "."

		lRet := .F.	

	Endif

    GTPSetMsg(cMsg,cSolucao,.t.)

Return(lRet)

Static Function GetCTeCFOP()

    If ( Len(aCTeCFOP) == 0 )
    
        aAdd(aCTeCFOP,{"1206", "Anulação de valor relativo à prestação de serviço de transporte", .t.})
        aAdd(aCTeCFOP,{"2206", "Anulação de valor relativo à prestação de serviço de transporte", .t.})
        aAdd(aCTeCFOP,{"3206", "Anulação de valor relativo à prestação de serviço de transporte", .t.})
        aAdd(aCTeCFOP,{"5206", "Anulação de valor relativo a aquisição de serviço de transporte", .t.})
        aAdd(aCTeCFOP,{"5351", "Prestação de serviço de transporte para execução de serviço da mesma natureza", .t.})
        aAdd(aCTeCFOP,{"5352", "Prestação de serviço de transporte a estabelecimento industrial", .F.})
        aAdd(aCTeCFOP,{"5353", "Prestação de serviço de transporte a estabelecimento comercial", .F.})
        aAdd(aCTeCFOP,{"5354", "Prestação de serviço de transporte a estabelecimento de prestador de serviço de comunicação", .F.})
        aAdd(aCTeCFOP,{"5355", "Prestação de serviço de transporte a estabelecimento de geradora ou de distribuidora de energia elétrica", .F.})
        aAdd(aCTeCFOP,{"5356", "Prestação de serviço de transporte a estabelecimento de produtor rural", .F.})
        aAdd(aCTeCFOP,{"5357", "Prestação de serviço de transporte a não contribuinte", .t.})
        aAdd(aCTeCFOP,{"5359", "Prestação de serviço de transporte a contribuinte ou a não contribuinte quando a mercadoria transportada está dispensada de emissão de nota fiscal.", .t.})
        aAdd(aCTeCFOP,{"5360", "Prestação de serviço de transporte a contribuinte substituto em relação ao serviço de transporte", .t.})
        aAdd(aCTeCFOP,{"5601", "Transferência de crédito de ICMS acumulado", .t.})
        aAdd(aCTeCFOP,{"5602", "Transferência de saldo credor de ICMS para outro estabelecimento da mesma empresa, destinado à compensação de saldo devedor de ICMS", .t.})
        aAdd(aCTeCFOP,{"5603", "Ressarcimento de ICMS retido por substituição tributária", .t.})
        aAdd(aCTeCFOP,{"5605", "Transferência de saldo devedor de ICMS de outro estabelecimento da mesma empresa.", .t.})
        aAdd(aCTeCFOP,{"5606", "Utilização de saldo credor de ICMS para extinção por compensação de débitos fiscais.", .t.})
        aAdd(aCTeCFOP,{"5932", "Prestação de serviço de transporte iniciada em unidade da Federação diversa daquela onde inscrito o prestador", .t.})
        aAdd(aCTeCFOP,{"5949", "Outra saída de mercadoria ou prestação de serviço não especificado ", .t.})
        aAdd(aCTeCFOP,{"6206", "Anulação de valor relativo a aquisição de serviço de transporte", .t.})
        aAdd(aCTeCFOP,{"6351", "Prestação de serviço de transporte para execução de serviço da mesma natureza", .t.})
        aAdd(aCTeCFOP,{"6352", "Prestação de serviço de transporte a estabelecimento industrial", .F.})
        aAdd(aCTeCFOP,{"6353", "Prestação de serviço de transporte a estabelecimento comercial", .F.})
        aAdd(aCTeCFOP,{"6354", "Prestação de serviço de transporte a estabelecimento de prestador de serviço de comunicação", .F.})
        aAdd(aCTeCFOP,{"6355", "Prestação de serviço de transporte a estabelecimento de geradora ou de distribuidora de energia elétrica", .F.})
        aAdd(aCTeCFOP,{"6356", "Prestação de serviço de transporte a estabelecimento de produtor rural ", .F.})
        aAdd(aCTeCFOP,{"6357", "Prestação de serviço de transporte a não contribuinte", .t.})
        aAdd(aCTeCFOP,{"6359", "Prestação de serviço de transporte a contribuinte ou a não contribuinte quando a mercadoria transportada está dispensada de emissão de nota fiscal.", .t.})
        aAdd(aCTeCFOP,{"6360", "Prestação de serviço de transporte a contribuinte substituto em relação ao serviço de transporte.", .t.})
        aAdd(aCTeCFOP,{"6603", "Ressarcimento de ICMS retido por substituição tributária ", .t.})
        aAdd(aCTeCFOP,{"6932", "Prestação de serviço de transporte iniciada em unidade da Federação diversa daquela onde inscrito o prestador", .t.})
        aAdd(aCTeCFOP,{"6949", "Outra saída de mercadoria ou prestação de serviço não especificado", .t.})
        aAdd(aCTeCFOP,{"7206", "Anulação de valor relativo a aquisição de serviço de transporte", .t.})
        aAdd(aCTeCFOP,{"7358", "Prestação de serviço de transporte", .t.})
        aAdd(aCTeCFOP,{"7949", "Outra saída de mercadoria ou prestação de serviço não especificado", .t.})
    EndIf

Return(aCTeCFOP)

Static Function GetCTeOSCFOP()

    If ( Len(aCTeOSCFOP) == 0 )

        aAdd(aCTeOSCFOP,{"1206", "Anulação de valor relativo à prestação de serviço de transporte", .t.})
        aAdd(aCTeOSCFOP,{"2206", "Anulação de valor relativo à prestação de serviço de transporte", .t.})
        aAdd(aCTeOSCFOP,{"3206", "Anulação de valor relativo à prestação de serviço de transporte", .t.})
        aAdd(aCTeOSCFOP,{"5206", "Anulação de valor relativo a aquisição de serviço de transporte", .t.})
        aAdd(aCTeOSCFOP,{"5351", "Prestação de serviço de transporte para execução de serviço da mesma natureza", .t.})
        aAdd(aCTeOSCFOP,{"5352", "Prestação de serviço de transporte a estabelecimento industrial", .F.})
        aAdd(aCTeOSCFOP,{"5353", "Prestação de serviço de transporte a estabelecimento comercial", .F.})
        aAdd(aCTeOSCFOP,{"5354", "Prestação de serviço de transporte a estabelecimento de prestador de serviço de comunicação", .F.})
        aAdd(aCTeOSCFOP,{"5355", "Prestação de serviço de transporte a estabelecimento de geradora ou de distribuidora de energia elétrica", .F.})
        aAdd(aCTeOSCFOP,{"5356", "Prestação de serviço de transporte a estabelecimento de produtor rural", .F.})
        aAdd(aCTeOSCFOP,{"5357", "Prestação de serviço de transporte a não contribuinte", .t.})
        aAdd(aCTeOSCFOP,{"5601", "Transferência de crédito de ICMS acumulado", .t.})
        aAdd(aCTeOSCFOP,{"5602", "Transferência de saldo credor de ICMS para outro estabelecimento da mesma empresa, destinado à compensação de saldo devedor de ICMS", .t.})
        aAdd(aCTeOSCFOP,{"5603", "Ressarcimento de ICMS retido por substituição tributária", .t.})
        aAdd(aCTeOSCFOP,{"5605", "Transferência de saldo devedor de ICMS de outro estabelecimento da mesma empresa.", .t.})
        aAdd(aCTeOSCFOP,{"5606", "Utilização de saldo credor de ICMS para extinção por compensação de débitos fiscais.", .t.})
        aAdd(aCTeOSCFOP,{"5949", "Outra saída de mercadoria ou prestação de serviço não especificado ", .t.})
        aAdd(aCTeOSCFOP,{"6360", "Prestação de serviço de transporte a contribuinte substituto em relação ao serviço de transporte.", .t.})
        aAdd(aCTeOSCFOP,{"6603", "Ressarcimento de ICMS retido por substituição tributária ", .t.})
        aAdd(aCTeOSCFOP,{"6932", "Prestação de serviço de transporte iniciada em unidade da Federação diversa daquela onde inscrito o prestador", .t.})
        aAdd(aCTeOSCFOP,{"6949", "Outra saída de mercadoria ou prestação de serviço não especificado", .t.})
        aAdd(aCTeOSCFOP,{"7949", "Outra saída de mercadoria ou prestação de serviço não especificado", .t.})
    EndIf

Return(aCTeOSCFOP)

Function GTPShowMsg()

    If ( lShowMsg )
        //Apresentar a mensagem da variável cMsgValid
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

    oLookUp:AddIndice("Código Fiscal",  "CFOP")
    oLookUp:AddIndice("Descrição",      "DESCRICAO")

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
